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
 rtlsystem,rtllibc;
 
type
 pchar = ^char8;
 sizeint = intptr;
 tdatetime = datetimety;
 tsize = size_t;
 tssize = ssize_t;
 
procedure move(const source; var dest; count: sizeint);
function now(): tdatetime;
function trunc(d: flo64): int64;
function round(d: flo64): int64;
function fpopen(path: pchar; flags: cint):cint;
function fpwrite(fd: cint; buf: pchar; nbytes: tsize): tssize;
function fpclose(fd: cint): cint;

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

function fpopen (path : pchar; flags : cint):cint;
begin
 result:= open(path,flags,[]);
end;

function fpwrite(fd: cint; buf: pchar; nbytes: tsize): tssize;
begin
 result:= write(fd,buf,nbytes);
end;

function fpclose(fd: cint): cint;
begin
 result:= close(fd);
end;

end.
