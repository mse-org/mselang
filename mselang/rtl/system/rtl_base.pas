//rtl_base
{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtl_base;
//base functions, preliminary ad-hoc implementation
interface

type
 pcard8 = ^card8;
 pchar8 = ^char8;
 
 filenamety = string16;

 tbase = class() [virtual]
  destructor destroy() [virtual];
 end;
  
function inttostr(const value: integer): string;
function random(const limit: int32): int32;
function random(const limit: int64): int64;

implementation

function inttostr(const value: integer): string;
var
 buffer: array[0..22] of char;
 int1,int2: integer;
 lwo1,lwo2: longword;
begin
 lwo1:= abs(value);
 if lwo1 = 0 then begin
  result:= '0';
  exit;
 end;
 int1:= high(buffer);
 while lwo1 > 0 do begin
  lwo2:= lwo1 div 10;
  buffer[int1]:= char(card8(lwo1 - lwo2 * 10 + ord('0')));
  lwo1:= lwo2;
  dec(int1);
 end;
 if value < 0 then begin
  buffer[int1]:= char('-');
  dec(int1);
 end;
 int2:= (high(buffer))-int1;
 setlength(result,int2);
 memcpy(pointer(result),@buffer[int1+1],int2*sizeof(char));
end;

const
 defaultmwcseedw = 521288629;
 defaultmwcseedz = 362436069;

var
 fw: card32;
 fz: card32;

function mwcnoise: card32;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 result:= fz shl 16 + fw;
end;

//todo: use mersenne twister

function random(const limit: int32): int32;
begin
 result:= mwcnoise();
 if limit > 0 then begin
  result:= card32(result) mod card32(limit);
 end
 else begin
  result:= 0;
 end;
end;

function random(const limit: int64): int64;
begin
 result:= (int64(mwcnoise()) shl 32) or mwcnoise();
 if limit > 0 then begin
  result:= card64(result) mod card64(limit);
 end
 else begin
  result:= 0;
 end;
end;

{ tbase }

destructor tbase.destroy();
begin
end;

initialization
 fw:= defaultmwcseedw;
 fz:= defaultmwcseedz;
end.
