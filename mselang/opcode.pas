{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit opcode;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
type
 addressbasety = (ab_frame,ab_reg0,ab_stack,ab_stackref,ab_segment);
 
type
 addressrefty = record
  offset: dataoffsty;
  case base: addressbasety of
   ab_segment: (segment: segmentty);
 end;

 loopinfoty = record
  start: opaddressty;
  size: databitsizety;
 end;
  
function getglobvaraddress(const asize: integer;
                                    var aflags: addressflagsty): segaddressty;
procedure inclocvaraddress(const asize: integer);
function getlocvaraddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): locaddressty;
function getglobconstaddress(const asize: integer): dataoffsty;

function additem(): popinfoty;
function insertitem(const stackoffset: integer;
                              const before: boolean): popinfoty;
procedure writeop(const operation: opty); inline;

procedure inipointer(const aaddress: addressrefty; const count: datasizety);
procedure finirefsize(const aaddress: addressrefty; const count: datasizety);
procedure increfsize(const aaddress: addressrefty; const count: datasizety);
procedure decrefsize(const aaddress: addressrefty; const count: datasizety);

procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
procedure endforloop(const ainfo: loopinfoty);

implementation
uses
 stackops,handlerutils,errorhandler;
 
type
 opadsty = array[addressbasety] of opty;
 aropadsty = array[boolean] of opadsty; 
 
const
 storenilops: aropadsty = (
  (
  //ab_segment,   ab_frame,      ab_reg0,
   @storesegnil,@storeframenil,@storereg0nil,
  //ab_stack,      ab_stackref
   @storestacknil,@storestackrefnil),
  (
  //ab_segment,     ab_frame,        ab_reg0,
   @storesegnilar,@storeframenilar,@storereg0nilar,
  //ab_stack,       ab_stackref
   @storestacknilar,@storestackrefnilar)
 );

 finirefsizeops: aropadsty = (
  (
  //ab_segment,         ab_frame,            ab_reg0,
   @finirefsizeseg,@finirefsizeframe,@finirefsizereg0,
  //ab_stack,           ab_stackref
   @finirefsizestack,@finirefsizestackref),
  (
  //ab_segment,           ab_frame,              ab_reg0,
   @finirefsizesegar,@finirefsizeframear,@finirefsizereg0ar,
  //ab_stack,             ab_stackref
   @finirefsizestackar,@finirefsizestackrefar)
 );

 increfsizeops: aropadsty = (
  (
  //ab_segment,         ab_frame,            ab_reg0,
   @increfsizeseg,@increfsizeframe,@increfsizereg0,
  //ab_stack,           ab_stackref
   @increfsizestack,@increfsizestackref),
  (
  //ab_segment,           ab_frame,              ab_reg0,
   @increfsizesegar,@increfsizeframear,@increfsizereg0ar,
  //ab_stack,             ab_stackref
   @increfsizestackar,@increfsizestackrefar)
 );

 decrefsizeops: aropadsty = (
  (
  //ab_segment,         ab_frame,            ab_reg0,
   @decrefsizeseg,@decrefsizeframe,@decrefsizereg0,
  //ab_stack,           ab_stackref
   @decrefsizestack,@decrefsizestackref),
  (
  //ab_global,           ab_frame,              ab_reg0,
   @decrefsizesegar,@decrefsizeframear,@decrefsizereg0ar,
  //ab_stack,             ab_stackref
   @decrefsizestackar,@decrefsizestackrefar)
 );

procedure addmanagedop(const opsar: aropadsty; 
               const aaddress: addressrefty; const count: datasizety);
begin
 with additem^ do begin
  if count > 1 then begin
   op:= opsar[true][aaddress.base];
   par.datasize:= count;
   if aaddress.base = ab_segment then begin
    par.segdataaddress.a.address:= aaddress.offset;
    par.segdataaddress.a.segment:= aaddress.segment;
    par.segdataaddress.offset:= 0;
   end
   else begin
    par.podataaddress:= aaddress.offset;
   end;
  end
  else begin
   op:= opsar[false][aaddress.base];
   if aaddress.base = ab_segment then begin
    par.vsegaddress.a.address:= aaddress.offset;
    par.vsegaddress.a.segment:= aaddress.segment;
    par.vsegaddress.offset:= 0;
   end
   else begin
    par.vaddress:= aaddress.offset;
   end;
//   par.vaddress:= aaddress.offset;
  end;
 end;
end;

procedure inipointer(const aaddress: addressrefty; const count: datasizety);
begin
 addmanagedop(storenilops,aaddress,count);
end;

procedure finirefsize(const aaddress: addressrefty; const count: datasizety);
begin
 addmanagedop(finirefsizeops,aaddress,count);
end;

procedure increfsize(const aaddress: addressrefty; const count: datasizety);
begin
 addmanagedop(increfsizeops,aaddress,count);
end;

procedure decrefsize(const aaddress: addressrefty; const count: datasizety);
begin
 addmanagedop(decrefsizeops,aaddress,count);
end;

function getglobvaraddress(const asize: integer;
                                    var aflags: addressflagsty): segaddressty;
begin
 with info do begin
  result.address:= globdatapo;
  globdatapo:= globdatapo + alignsize(asize);
  result.segment:= seg_globvar;
  include(aflags,af_segment);
 end;
end;

procedure inclocvaraddress(const asize: integer);
begin
 with info do begin
  locdatapo:= locdatapo + alignsize(asize);
 end;
end;

function getlocvaraddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): locaddressty;
begin
 with info do begin
  result.address:= locdatapo+shift;
  locdatapo:= locdatapo + alignsize(asize);
  result.framelevel:= info.sublevel;
  exclude(aflags,af_segment);
 end;
end;

function getglobconstaddress(const asize: integer): dataoffsty;
begin
 with info do begin
  result:= constsize;
  constsize:= constsize+asize;
  alignsize(constsize);
  if constsize > constcapacity then begin
   constcapacity:= 2*constsize;
   setlength(constseg,constcapacity);
  end;
 end;
end;

function getglobopaddress(const asize: integer): dataoffsty;
begin
 with info do begin
  result:= constsize;
  constsize:= constsize+asize;
  alignsize(constsize);
  if constsize > constcapacity then begin
   constcapacity:= 2*constsize;
   setlength(constseg,constcapacity);
  end;
 end;
end;
 
procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
begin
 ainfo.size:= getdatabitsize(count);
 with additem()^ do begin
  if ainfo.size > das_32 then begin
   op:= @push64;
   par.imm.vint64:= count;
   ainfo.start:= info.opcount;
   with additem^ do begin
    op:= @decloop64;
   end;
  end
  else begin
   op:= @push32;
   par.imm.vint32:= count;
   ainfo.start:= info.opcount;
   with additem^ do begin
    op:= @decloop32;
   end;
  end;
 end;
end;

procedure endforloop(const ainfo: loopinfoty);
begin
 with additem^ do begin
  op:= @gotoop;
  par.opaddress:= ainfo.start-1;
 end;
 with info.ops[ainfo.start] do begin
  par.opaddress:= info.opcount-1;
 end;
 with additem^ do begin
  op:= @locvarpopop;
  if ainfo.size > das_32 then begin
   par.stacksize:= 8;
  end
  else begin
   par.stacksize:= 4;
  end;
 end;
end;

function additem(): popinfoty;
begin
 with info do begin
  if high(ops) < opcount then begin
   setlength(ops,(high(ops)+257)*2);
  end;
  result:= @ops[opcount];
  inc(opcount);
 end;
end;

function insertitem(const stackoffset: integer;
                                            const before: boolean): popinfoty;
var
 int1: integer;
 ad1: opaddressty;
begin
 with info do begin
  int1:= stackoffset+stackindex;
  if (int1 > stacktop) or not before and (int1 = stacktop) then begin
   result:= additem;
  end
  else begin
   if high(ops) < opcount then begin
    setlength(ops,(high(ops)+257)*2);
   end;
   if before then begin
    ad1:= contextstack[int1].opmark.address;
   end
   else begin
    ad1:= contextstack[int1+1].opmark.address
   end;
   move(ops[ad1],ops[ad1+1],(opcount-ad1)*sizeof(ops[0]));
   result:= @ops[ad1];
   inc(opcount);
   for int1:= int1+1 to stacktop do begin
    inc(contextstack[int1].opmark.address);
   end;
  end;
 end;
end;
{
function insertitemafter(const stackoffset: integer;
                                         const shift: integer=0): popinfoty;
begin
 with info do begin
  if stackoffset+stackindex > stacktop then begin
   result:= additem;
  end
  else begin
   result:= insertitem(
                 contextstack[stackindex+stackoffset+1].opmark.address+shift);
  end;
 end;
end;
}
procedure writeop(const operation: opty); inline;
begin
 with additem()^ do begin
  op:= operation
 end;
end;

end.
