{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
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
 msestream,msestrings,msetypes,msertti;
const
 firstident = 256;
 includemax = 31;

type
 segmentty = (seg_nil,seg_stack,seg_globvar,seg_globconst,
              seg_op,seg_rtti,seg_intf,seg_alloc);

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
               dk_address,dk_record,dk_string8,dk_array,dk_class,dk_interface,
               dk_enum,dk_enumitem,dk_set);
 pdatakindty = ^datakindty;
 
const
 ordinaldatakinds = [dk_boolean,dk_cardinal,dk_integer];
 ancestordatakinds = [dk_class];
 ancestorchaindatakinds = [dk_interface];
 
type
 databitsizety = (das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
                  das_33_63,das_64,das_pointer);

 visikindty = (vik_global,vik_sameunit,vik_descendent,
               vik_published,vik_ancestor,vik_units);
 visikindsty = set of visikindty;
 
// vislevelty = (vis_0,vis_1,vis_2,vis_3,vis_4,vis_5,vis_6,vis_7,vis_8,vis_9);

 indexty = integer;
 linkindexty = indexty;
 forwardindexty = indexty;
 listadty = longword;

const
// vis_max = vis_0;
// vis_min = vis_9;
 nonevisi = [];
 allvisi = [vik_global{,vik_sameunit},vik_ancestor];
 globalvisi = [vik_global,vik_sameunit,vik_ancestor];
 implementationvisi = [vik_sameunit];
 classprivatevisi = [vik_sameunit];
 classprotectedvisi = classprivatevisi+[vik_descendent];
 classpublicvisi = classprotectedvisi+[vik_global];
 classpublishedvisi = classpublicvisi+[vik_published];
 
 defaultstackdepth = 256;
 defaultconstsegsize = 256;
 defaultrttibuffersize = 256;
 
 
 branchkeymaxcount = 4;
 dummyaddress = 0;
 idstart = $12345678;

type 
 contextkindty = (ck_none,ck_error,ck_implementation,
                  ck_end,ck_ident,ck_number,ck_str,{ck_opmark,}ck_subdef,
                  ck_const,ck_range,ck_ref,ck_fact,ck_reffact,
                  ck_subres,ck_subcall,ck_getfact,
                  ck_typedata,ck_typeref,
                  ck_typetype,ck_fieldtype,ck_var,ck_field,ck_statement,
                  ck_recorddef,ck_classdef,ck_interfacedef,ck_enumdef,
                  ck_paramsdef,ck_params,ck_index);
 stackdatakindty = (sdk_none,sdk_bool8,sdk_int32,sdk_flo64);
 stackdatakindsty = set of stackdatakindty;

 opaddressty = ptruint;         //todo: use target size
 popaddressty = ^opaddressty;
 dataaddressty = ptruint;
 pdataaddressty = ^dataaddressty;
 dataoffsty = ptrint;
 pdataoffsty = ^dataoffsty;
 datasizety = ptruint;
 loopcountty = ptrint;
 
const
 dataaddresssize = sizeof(dataaddressty);
 datacontexts = [ck_const,ck_fact,ck_subres,ck_ref,ck_reffact];
 typecontexts = [ck_typetype,ck_fieldtype];

type 
 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure({const info: pparseinfoty});

 branchflagty = (bf_nt,bf_emptytoken,
             bf_keyword,bf_handler,
             bf_nostartbefore,bf_nostartafter,bf_eat,bf_push,
             {bf_setpc,}bf_continue,
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
 elementoffsetarty = array of elementoffsetty;
 
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
  restoresource: boolean;
  cutafter: boolean;
  pop: boolean;
  popexe: boolean;
  cutbefore: boolean;
  nexteat: boolean;
  next: pcontextty;
  caption: string;
 end;

 statementflagty = (stf_rightside,stf_params,stf_leftreference,stf_proccall,
                    stf_classdef,stf_classimp,stf_interfacedef,
                    stf_implementation,
                    stf_hasmanaged);
 statementflagsty = set of statementflagty;

 addressflagty = (af_nil,af_segment,af_param,af_paramindirect,af_const,
                  af_classfield,af_stack);
 addressflagsty = set of addressflagty;

 indirectlevelty = integer;
 framelevelty = integer;

 typeflagty = (tf_managed,     //field iniproc/finiproc valid in typedataty
               tf_hasmanaged,  //has nested tf_managed
               tf_lower,       //in range expression
               tf_upper        //in range expression
               ); 
 typeflagsty = set of typeflagty;   
 
 typeinfoty = record
  flags: typeflagsty;
  typedata: elementoffsetty;
  indirectlevel: indirectlevelty; //total
 end;

 varinfoty = record
  indirectlevel: indirectlevelty;
 end;

 segaddressty = record
  address: dataoffsty;
  segment: segmentty;
 end;
 
 locaddressty = record
  address: dataoffsty;
  framelevel: integer;
 end;
 
 addressvaluety = record
  flags: addressflagsty;
  indirectlevel: indirectlevelty;
  case integer of
   0: (poaddress: dataoffsty);
   1: (segaddress: segaddressty);
   2: (locaddress: locaddressty);
 end;
 paddressvaluety = ^addressvaluety;

 stringvaluety = record
  offset: ptruint; //offset in string buffer
 // len: databytesizety;
 end;

 enumvaluety = record
  value: integer;
  enum: elementoffsetty;
 end; 

 refvaluety = record
  address: addressvaluety;  //indirectlevel = additional
  offset: dataoffsty;
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
    vaddress: addressvaluety;
   );
   dk_string8:(
    vstring: stringvaluety;
   );
   dk_enum:(
    venum: enumvaluety;
   );
 end;
 
 datainfoty = record
  typ: typeinfoty;
  d: dataty;
 end;

 factflagty = (ff_address);
 factflagsty = set of factflagty;
 
 getfactinfoty = record
  flags: factflagsty;
 end;
 
 factinfoty = record
  ssaindex: integer;
  case contextkindty of
   ck_subres:(
    datasize: integer;
   );
 end;

 numflagty = (nuf_pos,nuf_neg);
 numflagsty = set of numflagty;
 
 numberinfoty = record
  flags: numflagsty;
  value: card64;
 end;

 strinfoty = record
  start: pchar;
 end;
 
 paramkindty = (pk_value,pk_const,pk_var,pk_out);

 identkindty = (ik_param); 
 identinfoty = record
  ident: identty;
  len: integer;
  continued: boolean;
  {
  case identkindty of
   ik_param:(
    paramkind: paramkindty;
   )
   }
 end;
 opmarkty = record
  address: opaddressty;
 end;
 
 subflagty = (sf_function,sf_method,sf_constructor,sf_destructor,
              sf_functiontype,sf_header,
              sf_virtual,sf_override,sf_interface,
              sf_intfcall); //called by interface
 subflagsty = set of subflagty;
 subinfoty = record
  frameoffsetbefore: ptruint;
  parambase: ptruint;
  paramsize: integer; //params+stacklinksize
  varsize: integer;
  ssaindexbefore: integer;
  ref: elementoffsetty;
  match: elementoffsetty;
  error: boolean;
  flags: subflagsty;
 end;
 
 paramsdefinfoty = record
  kind: paramkindty;
 end;
 
 paramsinfoty = record
//  flagsbefore: statementflagsty;
 end;
{
 classinfoty = record
  ident: identinfoty;
  classdata: elementoffsetty;
 end;
}
 recordinfoty = record
  fieldoffset: dataoffsty;
 end;
 classinfoty = record
  visibility: visikindsty;
  intfindex: integer;
  fieldoffset: dataoffsty;
  virtualindex: integer;
//  parentclass: elementoffsetty;
 end;
 pclassinfoty = ^classinfoty;

 interfaceinfoty = record
//  intfindex: integer;
 end;
 pinterfaceinfoty = ^interfaceinfoty;
 
 enumflagty = (enf_contiguous);
 enumflagsty = set of enumflagty;
   
 enuminfoty = record
  value: integer;
  enum: elementoffsetty;
  first: elementoffsetty;
  flags: enumflagsty;
 end;
 penuminfoty = ^enuminfoty;

 fieldinfoty = record
  fielddata: elementoffsetty;
 end;

 statementinfoty = record
//  flags: statementflagsty;
 end;
 
 implcontinfoty = record
  elemark: markinfoty;
 end;
 
 datacontextty = record
  indirection: integer; //pending
  datatyp: typeinfoty;
  case contextkindty of
   ck_const:(
    constval: dataty;
   );
   ck_fact,ck_subres:(
    fact: factinfoty;
   );
   ck_ref:(
    ref: refvaluety;
   );
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
   ck_str:(
    str: strinfoty;
   );
   ck_getfact:(
    getfact: getfactinfoty;
   );
   ck_const,ck_fact,ck_subres,ck_ref,ck_reffact:( //datacontexts
    dat: datacontextty;
   );
   ck_index:(
    opshiftmark: integer;
   );
   ck_subdef:(
    subdef: subinfoty;
   );
   ck_paramsdef:(
    paramsdef: paramsdefinfoty;
   );
   ck_params:(
    params: paramsinfoty;
   );
//   ck_opmark:(
//    opmark: opmarkty;
//   );
   ck_typedata:(
    typedata: pointer;
   );
   ck_typeref:(
    typeref: elementoffsetty;
   );
   ck_typetype,ck_fieldtype:(
    typ: typeinfoty;
   );
   ck_recorddef:(
    rec: recordinfoty;
   );
   ck_classdef:(
    cla: classinfoty;
   );
   ck_interfacedef:(
    intf: interfaceinfoty;
   );
   ck_enumdef:(
    enu: enuminfoty;
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
   ck_implementation:(
    impl: implcontinfoty;
   );
 end;

 contextbackupty = record
  elemark: markinfoty;
  eleparent: elementoffsetty;
  flags: statementflagsty;
//  managedblock: listadty;
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
  opmark: opmarkty;
  b: contextbackupty;
  d: contextdataty;
 end;
 pcontextitemty = ^contextitemty;


// opinfoarty = array of opinfoty;
 errorlevelty = (erl_none,erl_fatal,erl_error);

 unitstatety = ({us_interface,}us_interfaceparsed,
                     us_implementation,us_implementationparsed,
                     us_end //pendings resolved
                     );
 unitstatesty = set of unitstatety;

 implinfoty = record
  sourceoffset: integer;
  sourceline: integer;
  context: pcontextty;
  eleparent: elementoffsetty;
 end;
 
 pendinginfoty = record
  ref: elementoffsetty;
//  ancestor: elementoffsetty;
 end;
 pendinginfoarty = array of pendinginfoty;
 
 punitinfoty = ^unitinfoty;
 unitinfopoarty = array of punitinfoty;
 unitinfoty = record
  key: identty;
  name: string;      //todo: use lstringty
  prev: punitinfoty; //current uses compiled item
  filepath: filenamety; //todo: use lstringty
  state: unitstatesty;
  interfaceelement: elementoffsetty;
  interfaceuses,implementationuses: unitinfopoarty;
  forwardlist: forwardindexty;
  pendingcount: integer;
  pendingcapacity: integer;
  pendings: pendinginfoarty;
  varchain: elementoffsetty;
  impl: implinfoty;
  codestop: opaddressty;
  initializationstart: opaddressty;  //0 if none
  initializationstop: opaddressty;   //0 if none, last op is goto
  finalizationstart: opaddressty;    //0 if none
  finalizationstop: opaddressty;     //0 if none, last op is goto
  inistart: opaddressty;   //0 if none
  inistop: opaddressty;    //-> gotoop
  finistart: opaddressty;  //0 if none
  finistop: opaddressty;   //-> gotoop
 end;
 ppunitinfoty = ^punitinfoty;

 includeinfoty = record
  sourcebefore: sourceinfoty;
  sourcestartbefore: pchar;
  filenamebefore: filenamety;
  input: string;
 end;

 allocprocty = procedure(const asize: integer; var address: segaddressty);  

 backendty = (bke_direct,bke_llvm);
 
 parseinfoty = record
  backend: backendty;
  unitinfo: punitinfoty;
  allocproc: allocprocty;
  allocid: integer;
  pb: pbranchty;
  pc: pcontextty;
  stopparser: boolean;
  filename: filenamety;
  sourcestart: pchar; //todo: use file cache for include files
  source{,sourcebef}: sourceinfoty;
  beforeeat: pchar;
{$ifdef mse_debugparser}
  debugsource: pchar;
{$endif}
  consumed: pchar;
  contextstack: array of contextitemty;
  stackdepth: integer;
  stackindex: integer; 
  stacktop: integer; 
  sublevel: integer;
  ssaindex: integer;
  unitlevel: integer;
  errorstream: ttextstream;
  errorfla: boolean;
  errors: array[errorlevelty] of integer;
//  constseg: bytearty;
//  constsize: integer;
//  constcapacity: integer;
//  ops: opinfoarty;
  opcount: integer;
//  opshift: integer;
  start: integer;
  globdatapo: ptruint;
  locdatapo: ptruint;
  frameoffset: ptruint;
  currentsubchain: elementoffsetty;
  currentsubcount: integer;
  currentcontainer: elementoffsetty;
//  currentclassvislevel: vislevelty;
  currentclassvislevel: visikindsty;
  currentstatementflags: statementflagsty;
  stringbuffer: string; //todo: use faster type
  includestack: array[0..includemax] of includeinfoty;
  includeindex: integer;
 end;

const
 nilad: addressvaluety = (
  flags: [af_nil];
  indirectlevel: 0;
  poaddress: 0;
 );

var
 info: parseinfoty;
 
implementation

end.