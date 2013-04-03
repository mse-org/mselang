{ MSEide Copyright (c) 2013 by Martin Schreiber
   
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
unit mseparserglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream;
 
const
 stackdepht = 256;

type 
 contextkindty = (ck_none,ck_neg,ck_int32const,ck_flo64const,
                  ck_int32fact,ck_flo64fact);
 stackdatakindty = (sdk_int32,sdk_flo64,sdk_int32rev,sdk_flo64rev);

 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure(const info: pparseinfoty);

 pcontextty = ^contextty;
 branchty = record
  t: string;
  c: pcontextty;
 end;
 pbranchty = ^branchty;

 contextty = record
  branch: pbranchty; //array
  handle: contexthandlerty;
  next: pcontextty;
//  setstackmark: boolean;
  caption: string;
 end;
 int32constty = record
  value: integer;
 end;
 flo64constty = record
  value: double;
 end;
 contextitemty = record
  parent: integer;
  context: pcontextty;
  start: pchar;
  case kind: contextkindty of 
   ck_int32const:(
    int32const: int32constty;
   );
   ck_flo64const:(
    flo64const: flo64constty;
   )
 end;

 opty = procedure;

 op1infoty = record
  index0: integer;
 end;

 opkindty = (ok_none,ok_pushint32,ok_pushflo64,ok_pop,ok_op,ok_op1);
 opinfoty = record
//todo: variable item size, immediate data
  op: opty;
  case opkindty of 
   ok_pushint32: (
    vint32: integer;
   );
   ok_pushflo64: (
    vflo64: real;
   );
   ok_pop: (
    count: integer;
   );
   ok_op1: (
    op1: op1infoty;
   )
 end;
 popinfoty = ^opinfoty;
 
 opinfoarty = array of opinfoty;
 
 parseinfoty = record
  source: pchar;
  consumed: pchar;
  contextstack: array[0..stackdepht] of contextitemty;
  stackindex: integer; 
  stacktop: integer; 
  command: ttextstream;
  ops: opinfoarty;
  opcount: integer;
 end;

implementation
end.
