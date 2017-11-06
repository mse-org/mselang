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
 __mla__internaltypes,globtypes;
 
function getenumname(const enumvalue: integer; const rtti: pcrttity): string;

implementation
uses
 segmentutils;
 
function getenumname(const enumvalue: integer; const rtti: pcrttity): string;
var
 po1: ^enumrttity;
 po2: ^enumitemrttity;

 procedure doname();
 var
  po3: pstringheaderty;
 begin
  po3:= getsegmentpo(seg_globconst,po2^.name);
  setlength(result,(po3)^.len);
  move((po3+1)^,pointer(result)^,length(result));
 end; //doname

var
 int1: integer;
  
begin
 result:= '';
 if rtti^.kind = rtk_enum then begin
  po1:= pointer(rtti);
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