{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtlsystem;
//system functions, preliminary ad-hoc implementation
interface

function timeutc(): datetimety;

implementation

function timeutc(): datetimety;
begin
var
 ti: timeval;
begin
 gettimeofday(@ti,nil);
{$ifdef FPC}
 result:= ti.tv_sec / (double(24.0)*60.0*60.0) + 
          ti.tv_usec / (double(24.0)*60.0*60.0*1e6) - unidatetimeoffset;
{$else}
 result:= ti.tv_sec / (24.0*60.0*60.0) + 
          ti.tv_usec / (24.0*60.0*60.0*1e6) - unidatetimeoffset;
{$endif}
end;

end.