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
unit mserttiutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msertti;

function getenumname(const enumvalue: integer; const rtti: pcomprttity): string;

implementation

function getenumname(const enumvalue: integer; const rtti: pcomprttity): string;
var
 po1: penumrttity;
 po2: penumitemrttity;

 procedure doname();
 var
  po3: pbyte;
 begin
  po3:= pointer(po2)+po2^.name;
  setlength(result,po3^);
  move((po3+1)^,pointer(result)^,po3^);
end; //doname

var
 int1: integer;
  
begin
 result:= '';
 if rtti^.header.kind = dt_enum then begin
  po1:= @rtti^.data;
  po2:= @po1^.items;
  if erf_contiguous in po1^.flags then begin
   if (enumvalue >= 0) and (enumvalue < po1^.itemcount) then begin
    inc(po2,enumvalue);
    doname();
   end;
  end
  else begin
   for int1:= 0 to po1^.itemcount - 1 do begin
    if po2^.value = enumvalue then begin
     doname();
     break;
    end;
    inc(po2);
   end;
  end;
 end;
end;

end.