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
 bool8 = boolean;
 bool16 = wordbool;
 bool32 = longbool;
 card8 = byte; 
 card16 = word;
 card32 = longword;
 card64 = qword;
 int8 = shortint; 
 int16 = smallint;
 int32 = integer;
 float32 = single;
 float64 = double;

 pcard8 = ^card8; 
 ppcard8 = ^pcard8;
 pcard16 = ^card16;
 ppcard16 = ^pcard16;
 pcard32 = ^card32;
 ppcard32 = ^pcard32;
 pcard64 = ^card64;
 ppcard64 = ^pcard64;
 pint8 = ^int8;
 ppint8 = ^pint8;
 pint16 = ^int16;
 ppint16 = ^pint16;
 pint32 = ^int32;
 ppint32 = ^int32;
 
 datakindty = (dk_none,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
               dk_address,dk_record{,dk_reference});
 datasizety = (das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
               das_33_63,das_64);
 vislevelty = (vis_0,vis_1,vis_2,vis_3,vis_4,vis_5,vis_6,vis_7,vis_8,vis_9);

 indexty = integer;
 linkindexty = indexty;
 forwardindexty = indexty;

const
 vis_max = vis_0;
 vis_min = vis_9;
 defaultstackdepht = 256;
 branchkeymaxcount = 4;
 dummyaddress = 0;
 idstart = $12345678;

type 
 contextkindty = (ck_none,ck_error,
                  ck_end,ck_ident,ck_number,{ck_opmark,}ck_proc,
                  ck_neg,ck_const,ck_fact,
                  ck_type,ck_var,ck_field,ck_statement,ck_params);
 stackdatakindty = (sdk_bool8,sdk_int32,sdk_flo64{,
                    sdk_bool8rev,sdk_int32rev,sdk_flo64rev});
 opaddressty = ptruint;         //todo: use target size
 popaddressty = ^opaddressty;
 dataaddressty = ptruint;
 pdataaddressty = ^dataaddressty;
 databytesizety = ptruint;
const
 dataaddresssize = sizeof(dataaddressty);

type 
 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure(const info: pparseinfoty);

 branchflagty = (bf_nt,bf_emptytoken,
             bf_keyword,bf_handler,bf_nostart,bf_eat,bf_push,
             bf_setpc,bf_continue,
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

 elementoffsetty = ptrint;
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

 statementflagty = (stf_rightside,stf_params,stf_leftreference,stf_proccall);
 statementflagsty = set of statementflagty;

 varflagty = (vf_global,vf_param{,vf_reference});
 varflagsty = set of varflagty;

 indirectlevelty = integer;
 
// typeflagty = (tf_reference);
// typeflagsty = set of typeflagty;
 typeinfoty = record
  typedata: elementoffsetty;
  indirectlevel: indirectlevelty;
//  flags: typeflagsty;
 end;

 varinfoty = record
  indirectlevel: indirectlevelty;
//  flags: typeflagsty;
 end;
 
 addressinfoty = record
  address: dataaddressty;
  flags: varflagsty;
  indirectlevel: indirectlevelty;
 end; 
 dataty = record
  case kind: datakindty of
   dk_boolean:(
    vboolean: bool8;
   );
   dk_integer:(
    vinteger: int32;
   );
   dk_float:(
    vfloat: float64;
   );
   dk_address:(
    vaddress: addressinfoty;
   );
 end;
 
 datainfoty = record
  typ: typeinfoty;
  d: dataty;
 end;

 factinfoty = record
 end;

 numflagty = (nuf_pos,nuf_neg);
 numflagsty = set of numflagty;
 
 numberinfoty = record
  flags: numflagsty;
  value: card32;
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
  error: boolean;
 end;
 paramsinfoty = record
  flagsbefore: statementflagsty;
 end;
 classinfoty = record
  ident: identinfoty;
  classdata: elementoffsetty;
 end;
 
 fieldinfoty = record
  fielddata: elementoffsetty;
 end;

 statementinfoty = record
//  flags: statementflagsty;
 end;
 
 contextdataty = record
//  elemark: elementoffsetty;
  case kind: contextkindty of 
   ck_ident:(
    ident: identinfoty;
   );
   ck_number:(
    number: numberinfoty;
   );
   ck_const,ck_fact:(
    datatyp: typeinfoty;
    case contextkindty of
     ck_const:(
      constval: dataty;
     );
     ck_fact:(
      fact: factinfoty;
     );
   );
   ck_proc:(
    proc: procinfoty;
   );
   ck_params:(
    params: paramsinfoty;
   );
//   ck_opmark:(
//    opmark: opmarkty;
//   );
   ck_type:(
    typ: typeinfoty;
   );
   ck_var:(
    vari: varinfoty;
   );
   ck_field:(
    field: fieldinfoty;
   );
   ck_statement:(
    statement: statementinfoty;
   );
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
  transitionflags: branchflagsty;
  elemark: elementoffsetty;
  opmark: opmarkty;
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
 
 opkindty = (ok_none,ok_startup,ok_push8,ok_push16,ok_push32,ok_push64,
             ok_pushdatakind,ok_pushaddress,
             ok_pop,ok_op,ok_op1,ok_opn,ok_var,ok_opaddress);

 v8ty = array[0..0] of byte;
 pv8ty = ^v8ty;
 v16ty = array[0..1] of byte;
 pv16ty = ^v16ty;
 v32ty = array[0..3] of byte;
 pv32ty = ^v32ty;
 v64ty = array[0..7] of byte;
 pv64ty = ^v64ty;
 
 opdataty = record
  case opkindty of 
   ok_none: (
    d: record
     case integer of
      1: (vboolean: boolean);
      2: (vcardinal: card32);
      3: (vinteger: int32);
      4: (vfloat: float64);
    end;
   );
   ok_push8:(
    v8: v8ty;
   );
   ok_push16:(
    v16: v16ty;
   );
   ok_push32:(
    v32: v32ty;
   );
   ok_push64:(
    v64: v64ty;
   );
   ok_pushdatakind:(
    vdatakind: datakindty;
   );
   ok_pushaddress:(
    vaddress: dataaddressty;
   );
   ok_pop:(
    count: integer;
   );
   ok_op1:(
    op1: op1infoty;
   );
   ok_opn:(
    opn: opninfoty;
   );
   ok_var:(
    dataaddress: dataaddressty;
    datasize: ptruint;
   );
   ok_opaddress:(
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

 unitstatety = ({us_interface,}us_interfaceparsed,
                     us_implementation,us_implementationparsed);
 unitstatesty = set of unitstatety;

 implinfoty = record
  sourceoffset: integer;
  sourceline: integer;
  context: pcontextty;
  eleparent: elementoffsetty;
 end;
 
 punitinfoty = ^unitinfoty;
 unitinfopoarty = array of punitinfoty;
 unitinfoty = record
  key: identty;
  name: string;      //todo: use lstringty
  prev: punitinfoty; //current uses compiled item
  filepath: filenamety; //todo: use lstringty
  state: unitstatesty;
  interfaceelement,classeselement: elementoffsetty;
  interfaceuses,implementationuses: unitinfopoarty;
  forwardlist: forwardindexty;
  impl: implinfoty;
 end;
 ppunitinfoty = ^punitinfoty;

 parseinfoty = record
  unitinfo: punitinfoty;
  pb: pbranchty;
  pc: pcontextty;
  stopparser: boolean;
  filename: filenamety;
  sourcestart: pchar; //todo: use file cache for include files
  source: sourceinfoty;
{$ifdef mse_debugparser}
  debugsource: pchar;
{$endif}
  consumed: pchar;
  contextstack: array of contextitemty;
  stackdepht: integer;
  stackindex: integer; 
  stacktop: integer; 
  funclevel: integer;
  unitlevel: integer;
  command: ttextstream;
  errorfla: boolean;
  errors: array[errorlevelty] of integer;
  ops: opinfoarty;
  opcount: integer;
  start: integer;
  globdatapo: ptruint;
  locdatapo: ptruint;
  frameoffset: ptruint;
  currentclass: elementoffsetty;
  currentclassvislevel: vislevelty;
  currentstatementflags: statementflagsty;
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