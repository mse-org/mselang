{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtllibc;
//libc bindings, preliminary ad-hoc implementation

interface

type
 __time_t = int32;
 __suseconds_t = int32;

 timezone = record
  tz_minuteswest: int32;
  tz_dsttime: int32;
 end;
 ptimezone = ^timezone;

 timeval = record
  tv_sec : __time_t;
  tv_usec : __suseconds_t;
 end;
 ptimeval = ^timeval;

function gettimeofday(__tv: ptimeval; __tz: ptimezone): int32 external;

implementation
end.