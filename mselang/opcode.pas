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
 addressbasety = (ab_global,ab_frame,ab_reg0);
 addressrefty = record
  offset: dataoffsty;
  base: addressbasety;
 end;

 loopinfoty = record
  start: opaddressty;
  size: databitsizety;
 end;
  
function getglobvaraddress(const asize: integer): dataoffsty;
function getlocvaraddress(const asize: integer): dataoffsty;
function getglobconstaddress(const asize: integer): dataoffsty;

function additem(): popinfoty;
function insertitem(const stackoffset: integer;
                              const before: boolean): popinfoty;
procedure writeop(const operation: opty); inline;

procedure inipointer(const aaddress: addressrefty; const count: integer);
procedure finirefsize(const aaddress: addressrefty; const count: integer);

procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
procedure endforloop(const ainfo: loopinfoty);

implementation
uses
 stackops,handlerutils;

procedure inipointer(const aaddress: addressrefty; const count: integer);
begin
 with additem^ do begin
  if count = 1 then begin
   case aaddress.base of
    ab_global: begin
     op:= @storeglobnil;
    end;
    ab_frame: begin
     op:= @storelocnil;
    end;
    else begin
     op:= @storereg0nil;
    end;
   end;
  end
  else begin
   case aaddress.base of
    ab_global: begin
     op:= @storeglobnilar;
    end;
    ab_frame: begin
     op:= @storelocnilar;
    end;
    else begin
     op:= @storereg0nilar;
    end;
   end;
  end;
  par.datasize:= count;
  par.dataaddress:= aaddress.offset;
 end;
end;

procedure finirefsize(const aaddress: addressrefty; const count: integer);
begin
 with additem^ do begin
  if count = 1 then begin
   case aaddress.base of
    ab_global: begin
     op:= @finirefsizeglob;
    end;
    ab_frame: begin
     op:= @finirefsizeloc;
    end;
    else begin
     op:= @finirefsizereg0;
    end;
   end;
  end
  else begin
   case aaddress.base of
    ab_global: begin
     op:= @finirefsizeglobar;
    end;
    ab_frame: begin
     op:= @finirefsizelocar;
    end;
    else begin
     op:= @finirefsizereg0ar;
    end;
   end;
  end;
  par.datasize:= count;
  par.dataaddress:= aaddress.offset;
 end;
end;

function getglobvaraddress(const asize: integer): dataoffsty;
begin
 with info do begin
  result:= globdatapo;
  globdatapo:= globdatapo + alignsize(asize);
 end;
end;

function getlocvaraddress(const asize: integer): dataoffsty;
begin
 with info do begin
  result:= locdatapo;
  locdatapo:= locdatapo + alignsize(asize);
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
