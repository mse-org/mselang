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
unit syssubhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 handlerglob,opglob,managedtypes,msetypes;
type
 syssubty = procedure (const paramco: integer);
 
procedure handlewriteln(const paramco: integer);
procedure handlewrite(const paramco: integer);
procedure handlesizeof(const paramco: integer);

const
 sysfuncs: array[sysfuncty] of syssubty = (
  //sf_write,   sf_writeln,    sf_setlength,   sf_sizeof
  @handlewrite,@handlewriteln,@handlesetlength,@handlesizeof);
  
procedure init();
procedure deinit();

implementation
uses
 elements,parserglob,handlerutils,opcode,stackops,errorhandler,rttihandler,
 segmentutils;

procedure handlesizeof(const paramco: integer);
var
 int1: integer;
begin
 case paramco of
  0: begin
   errormessage(err_illegalexpression,[]);
  end;
  1: begin
   with info,contextstack[stackindex] do begin
    d.kind:= ck_const;
    d.dat.indirection:= 0;
    d.dat.datatyp:= sysdatatypes[st_int32];
    d.dat.constval.kind:= dk_integer;
    with contextstack[stacktop] do begin
     case d.kind of
      ck_const,ck_fact,ck_subres,ck_ref,ck_reffact: begin
       if d.dat.datatyp.indirectlevel > 0 then begin
        int1:= pointersize;
       end
       else begin
        int1:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.bytesize;
       end;
      end;
      ck_typetype,ck_fieldtype,ck_typearg: begin
       if d.typ.indirectlevel > 0 then begin
        int1:= pointersize;
       end
       else begin
        int1:= ptypedataty(ele.eledataabs(d.typ.typedata))^.bytesize;
       end;
      end;
      else begin
       int1:= 0;
       errormessage(err_cannotgetsize,[]);
      end;
     end;
    end;      
    d.dat.constval.vinteger:= int1;
   end;
  end;
  else begin
   errormessage(err_tokenexpected,[')']);
  end;
 end;
end;

procedure handlewrite(const paramco: integer);
var
 int1,int3: integer;
 stacksize1: datasizety;
 po1: popinfoty; 
 po2: ptypedataty;
begin
 stacksize1:= 0;
 with info do begin
  int3:= 0;
  for int1:= stacktop-paramco+1 to stacktop do begin
   getvalue(int1-stackindex);
  end;
  for int1:= stacktop-paramco+1 to stacktop do begin
//   with additem()^ do begin
   with contextstack[int1] do begin //todo: indirection, use table
    po2:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata));
    case po2^.kind of
     dk_boolean: begin
      po1:= additem(oc_writeboolean);
      po1^.par.voffset:= alignsize(sizeof(boolean));
     end;
     dk_integer: begin
      po1:= additem(oc_writeinteger);
      po1^.par.voffset:= alignsize(sizeof(int32));
     end;
     dk_float: begin
      po1:=  additem(oc_writefloat);
      po1^.par.voffset:= alignsize(sizeof(float64));
     end;
     dk_string8: begin
      po1:= additem(oc_writestring8);
      po1^.par.voffset:= alignsize(pointersize);
     end;
     dk_class: begin
      po1:= additem(oc_writeclass);
      po1^.par.voffset:= alignsize(pointersize);
     end;
     dk_enum: begin
      po1:= additem(oc_writeenum);
      po1^.par.voffset:= alignsize(pointersize);
      po1^.par.voffsaddress:= getrtti(po2);
     end;
     else begin
      errormessage(err_cantreadwritevar,[],int1-stackindex);
      po1:= additem(oc_none);
      po1^.par.voffset:= 0;         //dummy
      po1^.par.voffsaddress:= getrtti(po2);
     end;
    end;
    po1^.par.ssas1:= d.dat.fact.ssaindex;
   end;
  end;
  po1:= getoppo(opcount);
  int3:= 0;
  for int1:= paramco-1 downto 0 do begin
   dec(po1);
   int3:= int3-po1^.par.voffset;
   po1^.par.voffset:= int3;
  end;
 end;
end;

procedure handlewriteln(const paramco: integer);
begin
 handlewrite(paramco);
 with additem(oc_writeln)^ do begin
 end;
end;

(*
procedure handlewriteln(const paramco: integer);
var
 int1: integer;
 stacksize1: datasizety;
begin
 stacksize1:= 0;
 with info do begin
  for int1:= stacktop-paramco+1 to stacktop do begin
   getvalue(int1-stackindex{,true});
  end;
  for int1:= stacktop-paramco+1 to stacktop do begin
   with contextstack[int1] do begin
    with ptypedataty(ele.eledataabs(d.datatyp.typedata))^ do begin
     push(kind);
     stacksize1:= stacksize1 + alignsize(bytesize);
    end;
   end;
  end;
  with additem()^ do begin
   op:= @writelnop;
   par.paramcount:= paramco;
   par.paramsize:= stacksize1;
  end;
 end;
end;
*)

procedure handlesetlength(const paramco: integer);
begin
end;
 
type
 sysfuncinfoty = record
  name: string;
  data: sysfuncdataty;
 end;
const
 sysfuncinfos: array[sysfuncty] of sysfuncinfoty = (
   (name: 'write'; data: (func: sf_write)),
   (name: 'writeln'; data: (func: sf_writeln)),
   (name: 'setlength'; data: (func: sf_setlength)),
   (name: 'sizeof'; data: (func: sf_sizeof))
  );

procedure init();
var
 sf1: sysfuncty;
 po1: pelementinfoty;
begin
 for sf1:= low(sysfuncty) to high(sysfuncty) do begin
  with sysfuncinfos[sf1] do begin
   po1:= ele.addelement(getident(name),ek_sysfunc,globalvisi);
   psysfuncdataty(@po1^.data)^:= data;
  end;
 end;
end;

procedure deinit();
begin
end;

end.
