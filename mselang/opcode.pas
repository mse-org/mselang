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
 parserglob,opglob;
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
function getglobconstaddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): segaddressty;

function additem(const aopcode: opcodety): popinfoty;
function insertitem(const aopcode: opcodety; const stackoffset: integer;
                                             const before: boolean): popinfoty;
//procedure writeop(const operation: opty); inline;

procedure inipointer(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
procedure finirefsize(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
procedure increfsize(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
procedure decrefsize(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);

procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
procedure endforloop(const ainfo: loopinfoty);

procedure setoptable(const aoptable: poptablety; const assatable: pssatablety);

implementation
uses
 stackops,handlerutils,errorhandler,segmentutils;
 
type
 opadsty = array[addressbasety] of opcodety;
 aropadsty = array[boolean] of opadsty; 

var
 optable: poptablety;
 ssatable: pssatablety;
 
procedure setoptable(const aoptable: poptablety; const assatable: pssatablety);
begin
 optable:= aoptable;
 ssatable:= assatable;
end;
 
const
 storenilops: aropadsty = (
  (
  //ab_segment,   ab_frame,      ab_reg0,
   oc_storesegnil,oc_storeframenil,oc_storereg0nil,
  //ab_stack,      ab_stackref
   oc_storestacknil,oc_storestackrefnil),
  (
  //ab_segment,     ab_frame,        ab_reg0,
   oc_storesegnilar,oc_storeframenilar,oc_storereg0nilar,
  //ab_stack,       ab_stackref
   oc_storestacknilar,oc_storestackrefnilar)
 );

 finirefsizeops: aropadsty = (
  (
  //ab_segment,         ab_frame,            ab_reg0,
   oc_finirefsizeseg,oc_finirefsizeframe,oc_finirefsizereg0,
  //ab_stack,           ab_stackref
   oc_finirefsizestack,oc_finirefsizestackref),
  (
  //ab_segment,           ab_frame,              ab_reg0,
   oc_finirefsizesegar,oc_finirefsizeframear,oc_finirefsizereg0ar,
  //ab_stack,             ab_stackref
   oc_finirefsizestackar,oc_finirefsizestackrefar)
 );

 increfsizeops: aropadsty = (
  (
  //ab_segment,         ab_frame,            ab_reg0,
   oc_increfsizeseg,oc_increfsizeframe,oc_increfsizereg0,
  //ab_stack,           ab_stackref
   oc_increfsizestack,oc_increfsizestackref),
  (
  //ab_segment,           ab_frame,              ab_reg0,
   oc_increfsizesegar,oc_increfsizeframear,oc_increfsizereg0ar,
  //ab_stack,             ab_stackref
   oc_increfsizestackar,oc_increfsizestackrefar)
 );

 decrefsizeops: aropadsty = (
  (
  //ab_segment,         ab_frame,            ab_reg0,
   oc_decrefsizeseg,oc_decrefsizeframe,oc_decrefsizereg0,
  //ab_stack,           ab_stackref
   oc_decrefsizestack,oc_decrefsizestackref),
  (
  //ab_global,           ab_frame,              ab_reg0,
   oc_decrefsizesegar,oc_decrefsizeframear,oc_decrefsizereg0ar,
  //ab_stack,             ab_stackref
   oc_decrefsizestackar,oc_decrefsizestackrefar)
 );

procedure addmanagedop(const opsar: aropadsty; 
               const aaddress: addressrefty; const count: datasizety;
               const ssaindex: integer);
begin
 if count > 1 then begin
  with additem(opsar[true][aaddress.base])^ do begin
   par.memop.datasize:= count;
   if aaddress.base = ab_segment then begin
    par.memop.segdataaddress.a.address:= aaddress.offset;
    par.memop.segdataaddress.a.segment:= aaddress.segment;
    par.memop.segdataaddress.offset:= 0;
   end
   else begin
    par.memop.podataaddress:= aaddress.offset;
   end;
  end;
 end
 else begin
  with additem(opsar[false][aaddress.base])^ do begin
   if aaddress.base = ab_segment then begin
    par.vsegaddress.a.address:= aaddress.offset;
    par.vsegaddress.a.segment:= aaddress.segment;
    par.vsegaddress.offset:= 0;
   end
   else begin
    par.vaddress:= aaddress.offset;
   end;
  end;
 end;
end;

procedure inipointer(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
begin
 addmanagedop(storenilops,aaddress,count,ssaindex);
end;

procedure finirefsize(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
begin
 addmanagedop(finirefsizeops,aaddress,count,ssaindex);
end;

procedure increfsize(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
begin
 addmanagedop(increfsizeops,aaddress,count,ssaindex);
end;

procedure decrefsize(const aaddress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);
begin
 addmanagedop(decrefsizeops,aaddress,count,ssaindex);
end;

function getglobvaraddress(const asize: integer;
                                    var aflags: addressflagsty): segaddressty;
begin
 with info do begin
  result.address:= globdatapo;
  globdatapo:= globdatapo + alignsize(asize);
  result.segment:= seg_globvar;
  include(aflags,af_segment);
  trackalloc({asize,}result);
//  inc(allocid);
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

function getglobconstaddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): segaddressty;
begin
 result:= allocsegment(seg_globconst,asize);
// alignsegment(result);
 result.address:= result.address + shift;
 include(aflags,af_segment);
{ 
 with info do begin
  result.address:= constsize+shift;
  result.segment:= seg_globconst;
  include(aflags,af_segment);
  constsize:= constsize+asize;
  alignsize(constsize);
  if constsize > constcapacity then begin
   constcapacity:= 2*constsize;
   setlength(constseg,constcapacity);
  end;
 end;
}
end;
{
function getglobopaddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): segaddressty;
begin
 result:= allocsegment(seg_globconst,asize);
 result.address:= result.address + shift;
 include(aflags,af_segment);
end;
} 
procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
begin  //todo: ssaindex
 ainfo.size:= getdatabitsize(count);
 if ainfo.size > das_32 then begin
  with additem(oc_pushimm64)^ do begin
   par.imm.vint64:= count;
   ainfo.start:= info.opcount;
   with additem(oc_decloop64)^ do begin
   end;
  end;
 end
 else begin
  with additem(oc_pushimm32)^ do begin
   par.imm.vint32:= count;
   ainfo.start:= info.opcount;
   with additem(oc_decloop32)^ do begin
   end;
  end;
 end;
end;

procedure endforloop(const ainfo: loopinfoty);
begin
 with additem(oc_goto)^ do begin
  par.opaddress:= ainfo.start-1;
 end;
 with getoppo(ainfo.start)^ do begin
  par.opaddress:= info.opcount-1;
 end;
 with additem(oc_locvarpop)^ do begin
  if ainfo.size > das_32 then begin
   par.stacksize:= 8;
  end
  else begin
   par.stacksize:= 4;
  end;
 end;
end;

function additem(const aopcode: opcodety): popinfoty;
begin
 with info do begin
  ssa.index:= ssa.nextindex;
  inc(ssa.nextindex,ssatable^[aopcode]);
  result:= allocsegmentpo(seg_op,sizeof(opinfoty));
  with result^ do begin
   op.op:= aopcode;
   op.flags:= [];
   par.ssad:= ssa.index;
  end;
  inc(opcount);
 end;
end;

function insertitem(const aopcode: opcodety; const stackoffset: integer;
                                            const before: boolean): popinfoty;
var
 int1: integer;
 ad1: opaddressty;
 po1: popinfoty;
 poend: pointer;
 ssadelta: integer;
begin
 with info do begin
  int1:= stackoffset+stackindex;
  if (int1 > stacktop) or not before and (int1 = stacktop) then begin
   result:= additem(aopcode);
  end
  else begin
   ssadelta:= ssatable^[aopcode];
   allocsegmentpo(seg_op,sizeof(opinfoty));
   {
   if high(ops) < opcount then begin
    setlength(ops,(high(ops)+257)*2);
   end;
   }
   if before then begin
    ad1:= contextstack[int1].opmark.address;
   end
   else begin
    ad1:= contextstack[int1+1].opmark.address
   end;
   result:= getoppo(ad1);
   move(result^,(result+1)^,(opcount-ad1)*sizeof(opinfoty));
   inc(opcount);
   po1:= result+1;
   poend:= po1+opcount-ad1;
   int1:= po1^.par.ssad;
   while po1 <= poend do begin
    inc(po1^.par.ssad,ssadelta);
    if po1^.par.ssas1 <= int1 then begin
     inc(po1^.par.ssas1,ssadelta);
    end;
    if po1^.par.ssas2 <= int1 then begin
     inc(po1^.par.ssas2,ssadelta);
    end;
    inc(po1);
   end;
   for int1:= int1+1 to stacktop do begin
    with contextstack[int1] do begin
     inc(opmark.address);
     if d.kind = ck_fact then begin
      inc(d.dat.fact.ssaindex,ssadelta);
     end;
    end;
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
{
procedure writeop(const operation: opty); inline;
begin
 with additem()^ do begin
  op:= operation
 end;
end;
}
end.
