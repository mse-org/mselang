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
 
function getglobvaraddress(const asize: integer): ptruint;
function getlocvaraddress(const asize: integer): ptruint;
function additem(): popinfoty;
function insertitem(const insertad: opaddressty): popinfoty;
function insertitemafter(const stackoffset: integer;
                                       const shift: integer=0): popinfoty;
procedure writeop(const operation: opty); inline;

implementation
uses
 stackops;
 
function getglobvaraddress(const asize: integer): ptruint;
begin
 with info do begin
  result:= globdatapo;
  globdatapo:= globdatapo + alignsize(asize);
 end;
end;

function getlocvaraddress(const asize: integer): ptruint;
begin
 with info do begin
  result:= locdatapo;
  locdatapo:= locdatapo + alignsize(asize);
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

function insertitem(const insertad: opaddressty): popinfoty;
var
 ad1: opaddressty;
begin
 with info do begin
  if high(ops) < opcount then begin
   setlength(ops,(high(ops)+257)*2);
  end;
  ad1:= insertad+opshift;
  move(ops[ad1],ops[ad1+1],(opcount-ad1)*sizeof(ops[0]));
  result:= @ops[ad1];
  inc(opcount);
  inc(opshift);
 end;
end;

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

procedure writeop(const operation: opty); inline;
begin
 with additem()^ do begin
  op:= operation
 end;
end;

end.
