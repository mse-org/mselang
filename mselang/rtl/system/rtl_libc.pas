//rtl_libc
{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtl_libc;
//libc bindings, preliminary ad-hoc implementation

interface
{$define linux}

type
 cint = int32;
 pcchar = ^char8;
 
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
 
 size_t = card32;
 ssize_t = int32;
  
const
{$ifdef linux}   
   O_ACCMODE  = $00003;
   O_RDONLY   = $00000;
   O_WRONLY   = $00001;
   O_RDWR     = $00002;
   O_CREAT    = $00040;//&00100;
   O_EXCL     = $00080;//&00200;
   O_NOCTTY   = $00100;//&00400;
   O_TRUNC    = $00200;//&01000;
   O_APPEND   = $00400;//&02000;
   O_NONBLOCK = $00800;//&04000;
   O_NDELAY   = O_NONBLOCK;
   O_SYNC     = $01000;//&010000;
   O_FSYNC    = O_SYNC;
   O_ASYNC    = $02000;//&020000;
   O_CLOEXEC  = $80000;

   O_DIRECT    = $04000;//&0040000;
   O_DIRECTORY = $10000;//&0200000;
   O_NOFOLLOW  = $20000;//&0400000;

   O_DSYNC = O_SYNC;
   O_RSYNC = O_SYNC;

   O_LARGEFILE = $08000;//&0100000;

{$else}
   O_RDONLY = $0000;   //* open for reading only */
   O_WRONLY = $0001;   //* open for writing only */
   O_RDWR = $0002;     //* open for reading and writing */
   O_ACCMODE = $0003;  //* mask for above modes */

   O_NONBLOCK = $0004; //* no delay */
   O_APPEND = $0008;   //* set append mode */
   O_SHLOCK = $0010;   //* open with shared file lock */
   O_EXLOCK = $0020;   //* open with exclusive file lock */
   O_ASYNC = $0040;    //* signal pgrp when data ready */
   O_FSYNC = $0080;    //* synchronous writes */
   O_SYNC = $0080;     //* POSIX synonym for O_FSYNC */
   O_NOFOLLOW = $0100; //* don't follow symlinks */
   O_CREAT = $0200;    //* create if nonexistent */
   O_TRUNC = $0400;    //* truncate to zero length */
   O_EXCL = $0800;     //* error if already exists */

//* Defined by POSIX 1003.1; BSD default, but must be distinct from O_RDONLY. */
   O_NOCTTY = $8000;   //* don't assign controlling terminal */

//* Attempt to bypass buffer cache */
   O_DIRECT = $00010000;

//* Defined by POSIX Extended API Set Part 2 */
   O_DIRECTORY = $00020000; //* Fail if not directory */
   O_EXEC = $00040000; //* Open for execute only */

//* Defined by POSIX 1003.1-2008; BSD default, but reserve for future use. */
   O_TTY_INIT = $00080000; //* Restore default termios attributes */

   O_CLOEXEC = $00100000;

{$endif}

function gettimeofday(__tv: ptimeval; __tz: ptimezone): cint external;
function open(__file:  pcchar; __oflag: cint;
                                 args:array of const): cint external;
function close(fd: cint): cint external;

function write(fd: cint; buffer: pointer; count: size_t): ssize_t external;
function read(fd: cint; buffer: pointer; count: size_t): ssize_t external;

implementation
end.