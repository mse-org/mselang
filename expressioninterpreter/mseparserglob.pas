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
 msestream,mseelements,msestrings;

type
 uint8 = byte; 
 uint16 = word;
 uint32 = longword;
 sint8 = shortint; 
 sint16 = smallint;
 sint32 = integer;

 puint8 = ^uint8; 
 puint16 = ^uint16;
 puint32 = ^uint32;
 psint8 = ^sint8; 
 psint16 = ^sint16;
 psint32 = ^sint32;
 
 datakindty = (dk_none,dk_bool8,dk_int32,dk_flo64,dk_kind,dk_address,dk_record);

const
 defaultstackdepht = 256;
 branchkeymaxcount = 4;
 dummyaddress = 0;

type 
 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure(const info: pparseinfoty);

 contextkindty = (ck_none,ck_error,
                  ck_end,ck_ident,ck_opmark,ck_proc,
                  ck_neg,ck_const,ck_fact);
 stackdatakindty = (sdk_bool8,sdk_int32,sdk_flo64,
                    sdk_bool8rev,sdk_int32rev,sdk_flo64rev);
 opaddressty = ptruint;
 dataaddressty = ptruint;
 
 branchflagty = (bf_nt,bf_emptytoken,
             bf_keyword,bf_eat,bf_push,bf_setpc,
             bf_setparentbeforepush,bf_setparentafterpush);
 branchflagsty = set of branchflagty;
 keywordty = identty;
 charsetty = set of char;
 charset32ty = array[0..7] of uint32;
 branchkeykindty = (bkk_none,bkk_char,bkk_charcontinued{,bkk_keyword});
 
 branchkeyinfoty = record
  case kind: branchkeykindty of
   bkk_char,bkk_charcontinued: (
    chars: charsetty;
   );
//   bkk_keyword: (
//    keyword: keywordty;
//   );
 end;
  
 pcontextty = ^contextty;

 branchty = record
  flags: branchflagsty;
  dest: pcontextty;
  push: pcontextty; //nil = current
  case integer of
   0: (keyword: keywordty);
   1: (keys: array[0..branchkeymaxcount-1] of branchkeyinfoty);
 end; //todo: use variable size array
{
 branchty = record
  t: string;
  x: boolean; //exit
  k: boolean; //keyword
  c: pcontextty;
  e: boolean; //eat flag
  p: boolean; //push flag
  s: boolean; //set ck_pc
  sb: boolean; //setparent before push flag
  sa: boolean; //setparent after push flag
 end;
}
 pbranchty = ^branchty;

 contextty = record
  branch: pbranchty; //array
  handle: contexthandlerty;
  continue: boolean;
  cut: boolean;
  restoresource: boolean;
  pop: boolean;
  popexe: boolean;
  nexteat: boolean;
  next: pcontextty;
  caption: string;
 end;
 datainfoty = record
  case kind: datakindty of //first, maps ck_fact: factkind
   dk_bool8: (
    vbool8: integer;
   );
   dk_int32: (
    vint32: integer;
   );
   dk_flo64: (
    vflo64: double;
   );
 end;
 identinfoty = record
  ident: identty;
  len: integer;
  continued: boolean;
 end;
 opmarkty = record
  address: opaddressty;
 end;
 procinfoty = record
  paramcount: integer;
  elementmark: markinfoty;
 end;

 contextdataty = record
  case kind: contextkindty of 
   ck_ident:(
    ident: identinfoty;
   );
   ck_const:(
    constval: datainfoty;
   );
   ck_fact:(
    factkind: datakindty; 
   );
   ck_proc:(
    proc: procinfoty;
   );
   ck_opmark:(
    opmark: opmarkty;
   )
 end;

 sourceinfoty = record
  po: pchar;
  line: integer;
 end;
  
 pcontextdataty = ^contextdataty;
 contextitemty = record
  parent: integer;
  context: pcontextty;
  returncontext: pcontextty;
  start: sourceinfoty;
  debugstart: pchar;
  d: contextdataty;
 end;
 pcontextitemty = ^contextitemty;

 opty = procedure;

 op1infoty = record
  index0: integer;
 end;

 opninfoty = record
  paramcount: integer;
 end;

 startupdataty = record
  globdatasize: ptruint;
//  startaddress: opaddressty;
 end;
 pstartupdataty = ^startupdataty;
 
 opkindty = (ok_none,ok_startup,ok_pushbool8,ok_pushint32,ok_pushflo64,
             ok_pushdatakind,
             ok_pop,ok_op,ok_op1,ok_opn,ok_var,ok_opaddress);
 
 opdataty = record
  case opkindty of 
   ok_pushbool8: (
    vbool8: boolean;
   );
   ok_pushint32: (
    vint32: integer;
   );
   ok_pushflo64: (
    vflo64: real;
   );
   ok_pushdatakind: (
    vdatakind: datakindty;
   );
   ok_pop: (
    count: integer;
   );
   ok_op1: (
    op1: op1infoty;
   );
   ok_opn: (
    opn: opninfoty;
   );
   ok_var: (
    dataaddress: dataaddressty;
    datasize: ptruint;
   );
   ok_opaddress: (
    opaddress: opaddressty;
   );
  end;

 opinfoty = record
//todo: variable item size, immediate data
  op: opty;
  d: opdataty;
 end;
 popinfoty = ^opinfoty;

 opinfoarty = array of opinfoty;
 errorlevelty = (erl_none,erl_fatal,erl_error);

 unitstatety = (us_interface,us_interfaceparsed);
 unitstatesty = set of unitstatety;
 
 unitinfoty = record
  key: identty;
  filepath: filenamety;
  state: unitstatesty;
 end;
 punitinfoty = ^unitinfoty;

 parseinfoty = record
  unitinfo: punitinfoty;
  pb: pbranchty;
  pc: pcontextty;
  stophandle: boolean;
  stopparser: boolean;
  filename: filenamety;
  sourcestart: pchar; //todo: use file cache for include files
  source: sourceinfoty;
  debugsource: pchar;
  consumed: pchar;
  contextstack: array of contextitemty;
  stackdepht: integer;
  stackindex: integer; 
  stacktop: integer; 
  identcount: integer;
  funclevel: integer;
  command: ttextstream;
  errors: array[errorlevelty] of integer;
  ops: opinfoarty;
  opcount: integer;
  start: integer;
  globdatapo: ptruint;
  locdatapo: ptruint;
  frameoffset: ptruint;
 end;

const
 startupoffset = (sizeof(startupdataty)+sizeof(opinfoty)-1) div 
                                                         sizeof(opinfoty);

procedure outhandle(const info: pparseinfoty; const text: string);

implementation

procedure outhandle(const info: pparseinfoty; const text: string);
begin
 writeln(' !!!handle!!! ',text);
end;

end.
