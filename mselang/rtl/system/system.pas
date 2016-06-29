{ MSEpas Copyright (c) 2014-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit system;
interface

type
 boolean = bool1;
 
 byte = card8;
 word = card16;
 longword = card32;
 qword = card64;

 shortint = int8;
 smallint = int16;
 longint = int32;
// int64 is internaltype

 integer = longint;
 cardinal = longword;

 char = char8;
 string = string8;

var
 exitcode: int32;
 
begin
end; 
