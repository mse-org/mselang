{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
 
function getglobvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
function getlocvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
function additem(const info: pparseinfoty): popinfoty;
function insertitem(const info: pparseinfoty; 
                                   const insertad: opaddressty): popinfoty;
procedure writeop(const info: pparseinfoty; const operation: opty); inline;

implementation

function getglobvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
begin
 with info^ do begin
  result:= globdatapo;
  inc(globdatapo,asize);
 end;
end;

function getlocvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
begin
 with info^ do begin
  result:= locdatapo;
  inc(locdatapo);
 end;
end;
 
function additem(const info: pparseinfoty): popinfoty;
begin
 with info^ do begin
  if high(ops) < opcount then begin
   setlength(ops,(high(ops)+257)*2);
  end;
  result:= @ops[opcount];
  inc(opcount);
 end;
end;

function insertitem(const info: pparseinfoty; 
                                   const insertad: opaddressty): popinfoty;
begin
 with info^ do begin
  if high(ops) < opcount then begin
   setlength(ops,(high(ops)+257)*2);
  end;
  move(ops[insertad],ops[insertad+1],(opcount-insertad)*sizeof(ops[0]));
  result:= @ops[insertad];
  inc(opcount);
 end;
end;

procedure writeop(const info: pparseinfoty; const operation: opty); inline;
begin
 with additem(info)^ do begin
  op:= operation
 end;
end;

end.
