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
 handlerglob,managedtypes,msetypes;
type
 syssubty = procedure (const paramco: integer);
 
procedure handlewriteln(const paramco: integer);
procedure handlewrite(const paramco: integer);

const
 sysfuncs: array[sysfuncty] of syssubty = (
  //sf_write,   sf_writeln,    sf_setlength
  @handlewrite,@handlewriteln,@handlesetlength);
  
procedure init();
procedure deinit();

implementation
uses
 elements,parserglob,handlerutils,opcode,stackops,errorhandler,rttihandler,
 segmentutils;

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
   with additem()^ do begin
    with contextstack[int1] do begin //todo: indirection, use table
     po2:= ptypedataty(ele.eledataabs(d.datatyp.typedata));
     case po2^.kind of
      dk_boolean: begin
       op:= @writebooleanop;
       par.voffset:= alignsize(sizeof(boolean));
      end;
      dk_integer: begin
       op:= @writeintegerop;
       par.voffset:= alignsize(sizeof(int32));
      end;
      dk_float: begin
       op:= @writefloatop;
       par.voffset:= alignsize(sizeof(float64));
      end;
      dk_string8: begin
       op:= @writestring8op;
       par.voffset:= alignsize(pointersize);
      end;
      dk_class: begin
       op:= @writeclassop;
       par.voffset:= alignsize(pointersize);
      end;
      dk_enum: begin
       op:= @writeenumop;
       par.voffset:= alignsize(pointersize);
       par.voffsaddress:= getrtti(po2);
      end;
      else begin
       errormessage(err_cantreadwritevar,[],int1-stackindex);
       op:= nil;
       par.voffset:= 0;
       par.voffsaddress:= getrtti(po2);
      end;
     end;
    end;
   end;
  end;
  po1:= getoppo(opcount);
  int3:= 0;
  for int1:= paramco-1 downto 0 do begin
   dec(po1);
   int3:= int3-po1^.par.imm.voffset;
   po1^.par.imm.voffset:= int3;
  end;
 end;
end;

procedure handlewriteln(const paramco: integer);
begin
 handlewrite(paramco);
 with additem()^ do begin
  op:= @writelnop;
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
   (name: 'setlength'; data: (func: sf_setlength))
  );

procedure init();
var
 sf1: sysfuncty;
 po1: pelementinfoty;
begin
 for sf1:= low(sysfuncty) to high(sysfuncty) do begin
  with sysfuncinfos[sf1] do begin
   po1:= ele.addelement(getident(name),globalvisi,ek_sysfunc);
   psysfuncdataty(@po1^.data)^:= data;
  end;
 end;
end;

procedure deinit();
begin
end;

end.
