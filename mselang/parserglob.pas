{ MSElang Copyright (c) 2013-2015 by Martin Schreiber
   
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
 globtypes,msestream,msestrings,msetypes,msertti,listutils,llvmlists,
 segmentutils;
const
 firstident = 256;
 includemax = 31;

 bitoptypes: array[databitsizety] of typeallocinfoty = (
  (kind: das_none; size: 0; listindex: -1; flags: []),
  (kind: das_1; size: 1; listindex: ord(das_1); flags: []),
  (kind: das_2_7; size: 7; listindex: ord(das_2_7); flags: []),
  (kind: das_8; size: 8; listindex: ord(das_8); flags: []),
  (kind: das_9_15; size: 15; listindex: ord(das_9_15); flags: []),
  (kind: das_16; size: 16; listindex: ord(das_16); flags: []),
  (kind: das_17_31; size: 31; listindex: ord(das_17_31); flags: []),
  (kind: das_32; size: 32; listindex: ord(das_32); flags: []),
  (kind: das_33_63; size: 63; listindex: ord(das_33_63); flags: []),
  (kind: das_64; size: 64; listindex: ord(das_64); flags: []),
  (kind: das_pointer; size: pointerbitsize;
                                   listindex: ord(das_pointer); flags: []),
  (kind: das_f16; size: 16; listindex: ord(das_f16); flags: []),
  (kind: das_f32; size: 32; listindex: ord(das_f32); flags: []),
  (kind: das_f64; size: 64; listindex: ord(das_f64); flags: []),
  (kind: das_sub; size: pointerbitsize; listindex: -1; flags: []),
  (kind: das_meta; size: 0; listindex: -1; flags: [])
 );

 bitopsizes: array[databitsizety] of int32 = (
  0,             //das_none
  1,             //das_1
  7,             //das_2_7
  8,             //das_8
  15,            //das_9_15
  16,            //das_16
  31,            //das_17_31
  32,            //das_32
  63,            //das_33_63
  64,            //das_64
  pointerbitsize,//das_pointer
  16,            //das_f16
  32,            //das_f32
  64,            //das_f64
  pointerbitsize,//das_sub
  0              //das_meta
 );
 
type
 movesizety = (mvs_8,mvs_16,mvs_32,mvs_bytes);

 visikindty = (vik_global,vik_sameunit,vik_descendent,
               vik_published,vik_ancestor,vik_units);
 visikindsty = set of visikindty;
 
// vislevelty = (vis_0,vis_1,vis_2,vis_3,vis_4,vis_5,vis_6,vis_7,vis_8,vis_9);

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
 contextkindty = (ck_none,ck_error,
                  ck_interface,ck_implementation,ck_prog,
                  ck_end,ck_ident,ck_number,ck_str,{ck_opmark,}ck_subdef,
                  ck_const,ck_range,{ck_refconst,}ck_ref,ck_fact,ck_reffact,
                  ck_subres,ck_subcall,ck_controltoken,ck_getfact,
                  ck_typedata,ck_typeref,
                  ck_typetype,ck_fieldtype,ck_typearg,ck_var,ck_field,
                  ck_statement,ck_control,
                  ck_recorddef,ck_classdef,ck_interfacedef,ck_enumdef,
                  ck_paramsdef,ck_params,ck_index);
 stackdatakindty = (sdk_none,
                    sdk_pointer,
                    sdk_bool1,
                    sdk_card32,
                    sdk_int32,
                    sdk_flo64);
 stackdatakindsty = set of stackdatakindty;

const
 dataaddresssize = sizeof(dataaddressty);
 opaddresssize = sizeof(opaddressty);
 datacontexts = [ck_const,ck_fact,ck_subres,ck_ref,ck_reffact];
 typecontexts = [ck_typetype,ck_fieldtype,ck_typearg];
 factcontexts = [ck_fact,ck_reffact,ck_subres];

type 
 backendty = (bke_direct,bke_llvm);
 compileoptionty = (co_mlaruntime, //mla interpreter
                    co_llvm,co_hasfunction,
                    co_writertunits,     //write unitfiles with rt-code
                    co_readrtunits       //read unitfiles with rt-code
                    );
 compileoptionsty = set of compileoptionty;
const
 mlaruntimecompileoptions = [co_mlaruntime];
 llvmcompileoptions = [co_llvm,co_hasfunction];
 
type
 debugoptionty = (do_lineinfo);
 debugoptionsty = set of debugoptionty;

 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure({const info: pparseinfoty});

 branchflagty = (bf_nt,bf_emptytoken,
             bf_keyword,bf_handler,
             bf_nostartbefore,bf_nostartafter,bf_eat,bf_push,
             {bf_setpc,}bf_continue,
             bf_setparentbeforepush,bf_setparentafterpush,
             bf_changeparentcontext);
 branchflagsty = set of branchflagty;

 markinfoty = record
  hashref: ptruint;
  bufferref: ptruint;
 end;

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
                    stf_loop,
                    stf_classdef,stf_classimp,stf_interfacedef,
                    stf_implementation,
                    stf_getaddress,stf_addressop,
                    stf_hasmanaged,stf_newlineposted);
 statementflagsty = set of statementflagty;

 varinfoty = record
  indirectlevel: indirectlevelty;
 end;

 refconstvaluety = record
  address: addressvaluety;  //indirectlevel = additional
  varele: elementoffsetty;
 end;
   
 refvaluety = record
  c: refconstvaluety;
  case contextkindty of
   ck_ref:(
    offset: dataoffsty;
   );
 end;
 
{
 factflagty = (ff_address,ff_addressfact);
 factflagsty = set of factflagty;
} 
 getfactinfoty = record
//  flags: factflagsty;
 end;
 
 factinfoty = record
  ssaindex: integer;
  opdatatype: typeallocinfoty;
//  databitsize: integer;
 {
  case contextkindty of
   ck_subres:(
    datasize: integer;
   );
 }
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
 
 identflagty = (idf_continued,idf_inherited);
 identflagsty = set of identflagty;
 
// identkindty = (ik_param); 
 identinfoty = record
  ident: identty;
  len: integer;
  flags: identflagsty;
//  continued: boolean;
 end;

 opmarkty = record
  address: opaddressty;
 end;

 ssainfoty = record
  index: int32;
  nextindex: int32;
  blockindex: int32;
 end;
  
 subinfoty = record
  frameoffsetbefore: ptruint;
  parambase: ptruint;
  paramsize: integer; //params+stacklinksize
  locallocidbefore: integer;
  varsize: integer;
  ssabefore: ssainfoty;
  ref: elementoffsetty;
  match: elementoffsetty;
  error: boolean;
  flags: subflagsty;
 end;

 paramkindty = (pk_value,pk_const,pk_var,pk_out);
 
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

 controlkindty = (cok_none,cok_loop);
 controlinfoty = record
  opmark1: opmarkty;
  links: linkindexty;
  kind: controlkindty;
 end;
  
 implcontinfoty = record
//  elemark: markinfoty;
 end;
 
 progcontinfoty = record
  blockcountad: integer;
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
   {ck_refconst,}ck_ref:(
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
   ck_typetype,ck_fieldtype,ck_typearg:(
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
   ck_control:(
    control: controlinfoty;
   );
   ck_implementation:(
    impl: implcontinfoty;
   );
   ck_prog:(
    prog: progcontinfoty;
   )
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
 errorlevelty = (erl_none,erl_fatal,erl_error,erl_note);
{
 implinfoty = record
  sourceoffset: integer;
  sourceline: integer;
  context: pcontextty;
  eleparent: elementoffsetty;
 end;
}
 parsercontextty = record
  source: string;
  sourceoffset: integer;
  sourceline: integer;
  eleparent: elementoffsetty;
  stackindex: int32;
  stacktop: int32;
  stackcount: int32;
  contextstack: record    //array of contextdataty
  end;
 end;
 pparsercontextty = ^parsercontextty;
 
 unitstatety = ({us_interface,}us_interfaceparsed,
                     us_implementation,us_implementationparsed,
                     us_end //pendings resolved
                     );
 unitstatesty = set of unitstatety;

 internalsubty = (isub_ini,isub_fini);

 punitinfoty = ^unitinfoty;
 unitinfopoarty = array of punitinfoty;
 unitinfoty = record
  key: identty;
  name: string;      //todo: use lstringty
  prev: punitinfoty; //current uses compiled item
  filepath: filenamety; //todo: use lstringty
  filetimestamp: tdatetime;
  
  filepathmeta: metavaluety;
  debugfilemeta: metavaluety;
  compileunitmeta: metavaluety;
  mainsubmeta: metavaluety;

  opseg: subsegmentty;
  mainad: int32;
    
  state: unitstatesty;
  interfaceelement: elementoffsetty;
  implementationelement: elementoffsetty;
  interfacestart: markinfoty;
  interfaceglobstart: ptruint;
  interfaceglobsize: ptruint;
  implementationstart: markinfoty;
  implementationglobstart: ptruint;
  implementationglobsize: ptruint;

  interfaceuses,implementationuses: unitinfopoarty;
  forwardlist: forwardindexty;
  forwardtypes: listadty;
  metadatalist: tmetadatalist;

  pendingcount: integer;
  pendingcapacity: integer;
  pendings: pendinginfoarty;
  varchain: elementoffsetty;
//  impl: implinfoty; //start of implementation parsing
  implstart: pparsercontextty; //start of implementation parsing
  internalsubs: array[internalsubty] of opaddressty;
  codestop: opaddressty;
  stoponerror: boolean;
 end;
 ppunitinfoty = ^punitinfoty;

 includeinfoty = record
  sourcebefore: sourceinfoty;
  sourcestartbefore: pchar;
  filenamebefore: filenamety;
  input: string;
 end;

 allocprocty = procedure(const asize: integer; var address: segaddressty);  

 savedparseinfoty = record
  filename: filenamety;
  input: string;
  source: sourceinfoty;
{$ifdef mse_debugparser}
  debugsource: pchar;
{$endif}
  sourcestart: pchar; //todo: use file cache for include files
  stackindex: integer; 
  stacktop: integer; 
  unitinfo: punitinfoty;
  ssa: ssainfoty;
  pc: pcontextty;
  stopparser: boolean;
  stoponerror: boolean;
  interfaceonly: boolean;
  currentstatementflags: statementflagsty;
  trystack: listadty;
  trystacklevel: int32;
  debugoptions: debugoptionsty;
  currentcompileunitmeta: int32;
  currentfilemeta: int32;
  currentscopemeta: int32;
 end;
  
 parseinfoty = record
  s: savedparseinfoty;
//  backend: backendty;
//  backendhasfunction: boolean;
  compileoptions: compileoptionsty;
  debugoptions: debugoptionsty;
  unitinfochain: elementoffsetty;
  locallocid: integer;
  pb: pbranchty;
  
  beforeeat: pchar;
  consumed: pchar;
  contextstack: array of contextitemty;
  stackdepth: integer;
  sublevel: integer;
  unitlevel: integer;
  outputstream: ttextstream;
  outputwritten: boolean;
  errorstream: ttextstream;
  errorwritten: boolean;
  errorfla: boolean;
  errors: array[errorlevelty] of integer; //total count
  opcount: int32;
  start: int32;
  globdatapo: targetcard;
  locdatapo: targetcard;
  frameoffset: targetcard;
  currentsubchain: elementoffsetty;
  currentsubcount: integer;
  currentcontainer: elementoffsetty;
  currentclassvislevel: visikindsty;
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
 nilopad: addressvaluety = (
  flags: [af_segment];
  indirectlevel: 0;
  segaddress: (address: 0; segment: seg_op; element: 0)
 );
 

var
 info: parseinfoty;
 
implementation

end.