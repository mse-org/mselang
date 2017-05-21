{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtlfpccompatibility;
interface
//FPC compatibility
uses
 rtlsystem;
 
type
 sizeint = intptr;
 tdatetime = datetimety;
 
procedure move(const source; var dest; count: sizeint);
function now(): tdatetime;
function trunc(d: flo64): int64;
function round(d: flo64): int64;

implementation

procedure move(const source; var dest; count: sizeint);
begin
 memmove(@dest,@source,count);
end;

function now(): tdatetime;
begin
 result:= nowutc();
end;

function trunc(d: flo64): int64;
begin
 result:= trunci64(d);
end;

function round(d: flo64): int64;
begin
 result:= trunc(nearbyint(d));
end;

end.
