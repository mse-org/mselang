{ MSEgui Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit __mla__debugmemhandler;
interface

type
 size_t = int32; //todo: 64 bit
 
function __mla__malloc(size: size_t): pointer;
function __mla__calloc(nmemb: size_t; size: size_t): pointer;
procedure __mla__free(ptr: pointer);

function malloc(size: size_t): pointer external;
function calloc(nmemb: size_t; size: size_t): pointer external;
procedure free(ptr: pointer) external;

implementation
var
 alloccount: int32;
//{$internaldebug on}
function __mla__malloc(size: size_t): pointer;
begin
 result:= malloc(size);
 inc(alloccount);
end;

function __mla__calloc(nmemb: size_t; size: size_t): pointer;
begin
 result:= calloc(nmemb,size);
 inc(alloccount);
end;

procedure __mla__free(ptr: pointer);
begin
 free(ptr);
 dec(alloccount);
end;

finalization
 if alloccount <> 0 then begin
  writeln('********** Memory alloc error ',alloccount,' blocks');
 end;
end.
