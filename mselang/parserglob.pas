{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
unit parserglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream,msestrings;

type
 uint8 = byte; 
 uint16 = word;
 uint32 = longword;
 sint8 = shortint; 
 sint16 = smallint;
 sint32 = integer;
 float64 = double;

 puint8 = ^uint8; 
 puint16 = ^uint16;
 puint32 = ^uint32;
 psint8 = ^sint8; 
 psint16 = ^sint16;
 psint32 = ^sint32;
 
 datakindty = (dk_none,dk_bool8,dk_sint32,dk_flo64,dk_kind,dk_address,
               dk_record,dk_reference);
 vislevelty = (vis_0,vis_1,vis_2,vis_3,vis_4,vis_5,vis_6,vis_7,vis_8,vis_9);

const
 vis_max = vis_0;
 vis_min = vis_9;
 defaultstackdepht = 256;
 branchkeymaxcount = 4;
 dummyaddress = 0;
 idstart = $12345678;

type 
 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure(const info: pparseinfoty);

 contextkindty = (ck_none,ck_error,
                  ck_end,ck_ident,ck_opmark,ck_proc,
                  ck_neg,ck_const,ck_fact,
                  ck_type,ck_var,ck_field);
 stackdatakindty = (sdk_bool8,sdk_sint32,sdk_flo64,
                    sdk_bool8rev,sdk_sint32rev,sdk_flo64rev);
 opaddressty = ptruint;
 dataaddressty = ptruint;
 
 branchflagty = (bf_nt,bf_emptytoken,
             bf_keyword,bf_handler,bf_nostart,bf_eat,bf_push,bf_setpc,
             bf_setparentbeforepush,bf_setparentafterpush,
             bf_changeparentcontext);
 branchflagsty = set of branchflagty;
 identty = uint32;
 pidentty = ^identty;
 keywordty = identty;

 markinfoty = record
  hashref: ptruint;
  dataref: ptruint;
 end;

 elementoffsetty = integer;
 pelementoffsetty = ^elementoffsetty;
 
 charsetty = set of char;
 charset32ty = array[0..7] of uint32;
 branchkeykindty = (bkk_none,bkk_char,bkk_charcontinued);
 
 branchkeyinfoty = record
  case kind: branchkeykindty of
   bkk_char,bkk_charcontinued: (
    chars: charsetty;
   );
 end;
  
 pcontextty = ^contextty;

 branchdestty = record
  case integer of
   0: (context: pcontextty);
   1: (handler: contexthandlerty);
 end;
 branchty = record
  flags: branchflagsty;
  dest: branchdestty;
  stack: pcontextty; //nil = current
  case integer of
   0: (keyword: keywordty);
   1: (keys: array[0..branchkeymaxcount-1] of branchkeyinfoty);
 end; //todo: use variable size array
 pbranchty = ^branchty;

 contextty = record
  branch: pbranchty; //array
  handleentry: contexthandlerty;
  handleexit: contexthandlerty;
  continue: boolean;
  cut: boolean;
  restoresource: boolean;
  pop: boolean;
  popexe: boolean;
  nexteat: boolean;
  next: pcontextty;
  caption: string;
 end;

 typeflagty = (tf_pointer);
 typeflagsty = set of typeflagty;
 typeinfoty = record
  typedata: elementoffsetty;
  flags: typeflagsty;
 end;

 varinfoty = record
  flags: typeflagsty;
 end;
 
 dataty = record
  case kind: datakindty of
   dk_bool8: (
    vbool8: uint32;
   );
   dk_sint32: (
    vsint32: sint32;
   );
   dk_flo64: (
    vflo64: float64;
   );
 end;
 
 datainfoty = record
  typ: typeinfoty; //first, maps ck_fact facttyp
  d: dataty;
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
 classinfoty = record
  ident: identinfoty;
  classdata: elementoffsetty;
 end;
 
 fieldinfoty = record
  fielddata: elementoffsetty;
 end;

 contextdataty = record
  elemark: elementoffsetty;
  case kind: contextkindty of 
   ck_ident:(
    ident: identinfoty;
   );
   ck_const:(             ////
    constval: datainfoty;   //
   );                       // same startlayout
   ck_fact:(                //
    facttyp: typeinfoty;    //
   );                     ////
   ck_proc:(
    proc: procinfoty;
   );
   ck_opmark:(
    opmark: opmarkty;
   );
   ck_type:(
    typ: typeinfoty;
   );
   ck_var:(
    vari: varinfoty;
   );
   ck_field:(
    field: fieldinfoty;
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

 punitinfoty = ^unitinfoty;
 unitinfopoarty = array of punitinfoty;
 unitinfoty = record
  key: identty;
  filepath: filenamety;
  state: unitstatesty;
  interfaceelement,classeselement: elementoffsetty;
  interfaceuses,implementationuses: unitinfopoarty;
 end;
 ppunitinfoty = ^punitinfoty;
 
 parseinfoty = record
  unitinfo: punitinfoty;
  pb: pbranchty;
  pc: pcontextty;
//  stophandle: boolean;
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
  currentclass: elementoffsetty;
  currentclassvislevel: vislevelty
 end;

const
 startupoffset = (sizeof(startupdataty)+sizeof(opinfoty)-1) div 
                                                         sizeof(opinfoty);
{$ifdef mse_debugparser}
procedure outhandle(const info: pparseinfoty; const text: string);
{$endif}

implementation

procedure outhandle(const info: pparseinfoty; const text: string);
begin
 writeln(' !!!handle!!! ',text);
end;

end.
