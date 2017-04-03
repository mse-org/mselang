{ MSElang Copyright (c) 2013-2016 by Martin Schreiber
   
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
 segmentutils,llvmbitcodes,opglob,msehash;

type
 compilerswitchty = (cos_none,cos_booleval,cos_internaldebug);
 compilerswitchesty = set of compilerswitchty;
const
 defaultcompilerswitches = [];

 maxidentlen = 256;
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
 //allvisi = [vik_global{,vik_sameunit},vik_ancestor];
 allvisi = [vik_global,vik_sameunit,vik_ancestor];
 globalvisi = [vik_global,vik_sameunit,vik_ancestor];
 implementationvisi = [vik_sameunit];
 classprivatevisi = [vik_sameunit];
 classprotectedvisi = classprivatevisi+[vik_descendent];
 classpublicvisi = classprotectedvisi+[vik_global];
 classpublishedvisi = classpublicvisi+[vik_published];
 
 defaultstackdepth = 256;
 defaultconstsegsize = 256;
 defaultrttibuffersize = 256;
 
 
 dummyaddress = 0;

type 
 contextkindty = (ck_none,ck_error,ck_space,
                  ck_interface,ck_implementation,ck_prog,
                  ck_block,ck_end,
                  ck_ident,ck_number,ck_str,ck_subdef,ck_list,
                  ck_const,ck_range,ck_ref,ck_fact,ck_reffact,ck_prop,
                  ck_subres,ck_subcall,ck_controltoken,
                  ck_getfact,ck_getindex,ck_label,
                  ck_typedata,ck_typeref,
                  ck_typetype,ck_fieldtype,ck_typearg,ck_var,ck_field,
                  ck_statement,ck_control,ck_shortcutexp,
                  ck_recorddef,ck_classdef,ck_classprop,
                  ck_interfacedef,ck_enumdef,
                  ck_paramdef,ck_params,ck_index,ck_casebranch);
 stackdatakindty = (sdk_none,
                    sdk_pointer,
                    sdk_boolean,
                    sdk_cardinal,
                    sdk_integer,
                    sdk_float,
                    sdk_set,
                    sdk_string);
 stackdatakindsty = set of stackdatakindty;

const
 dataaddresssize = sizeof(dataaddressty);
 opaddresssize = sizeof(opaddressty);
 datacontexts = [ck_const,ck_fact,ck_subres,ck_ref,ck_prop,ck_reffact];
 alldatacontexts = datacontexts + [ck_prop];
 typecontexts = [ck_typetype,ck_fieldtype,ck_typearg];
 factcontexts = [ck_fact,ck_reffact,ck_subres];

type 
 compileoptionty = (co_mlaruntime, //mla interpreter
                    co_nocompilerunit,
                    co_llvm,co_hasfunction,
                    co_writeunits,     //write unitfiles
                    co_readunits,      //read unitfiles
                    co_build,          //compile all unit files
                    co_lineinfo,co_proginfo,co_names //debug
                    );
 compileoptionsty = set of compileoptionty;
const
 defaultcompileoptions = [];
 mlaruntimecompileoptions = [co_mlaruntime];
 llvmcompileoptions = [co_llvm,co_hasfunction];
 
type
 debugoptionty = (do_lineinfo,do_proginfo,
                  do_names);  //use source names
 debugoptionsty = set of debugoptionty;
const
 defaultdebugoptions = [];
 
type
// pparseinfoty = ^parseinfoty;

 markinfoty = record
  hashref: hashoffsetty;
  bufferref: ptruint;
 end;


 statementflagty = (stf_rightside,stf_params,stf_paramsdef,stf_cutvalueident,
                    stf_condition,stf_invalidcondition,
                    stf_leftreference,stf_proccall,
                    stf_loop,{stf_propindex,}
                    stf_classdef,stf_classimp,stf_interfacedef,
                    stf_implementation,
                    stf_getaddress,stf_addressop,
                    stf_needsmanage,stf_newlineposted);
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
  castchain: linkindexty;
  case contextkindty of
   ck_ref,ck_prop:(
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

 getindexinfoty = record
//  arraytype: elementoffsetty;
 end;
 
 factinfoty = record
  ssaindex: int32;
//  bbindex: int32;
  opdatatype: typeallocinfoty;
  case integer of
   0: (
    opoffset: int32; //for hf_needsunique
   );
 end;

 propinfoty = record
  propele: elementoffsetty;
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
 blockinfoty = record
  blockidbefore: int32;
 end;
 
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
  bbindex: int32;
//  blockindex: int32;
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
//  scopemetabefore: metavaluety;
 end;
 psubinfoty = ^subinfoty;

 paramkindty = (pk_value,pk_const,pk_var,pk_out);

const
 paramkinds: array[paramkindty] of addressflagsty = (
   //pk_value, pk_const,       pk_var,       pk_out
   [],        [af_paramconst],[af_paramvar],[af_paramout]
 );
 paramflagsmask = [af_paramconst,af_paramvar,af_paramout];

type 
 paramdefinfoty = record
  kind: paramkindty;
  defaultconst: elementoffsetty;
 end;
 
 paramsinfoty = record
  tempsize: int32;
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
 
 classpropinfoty = record
  errorref: int32;
  flags: propflagsty;
  readele: elementoffsetty;
  readoffset: int32;
  writeele: elementoffsetty;
  writeoffset: int32;
 end;
 pclasspropinfoty = ^classpropinfoty;

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

 controlkindty = (cok_none,cok_loop,cok_for);
const
 loopcontrols = [cok_loop,cok_for];
 
type
 forinfoty = record
  alloc: typeallocinfoty;
  varad: addressvaluety; //temp vars
  start: addressvaluety;
  stop: addressvaluety;
 end;
 
 controlinfoty = record
  opmark1: opmarkty;
  linksbreak: linkindexty;
  linkscontinue: linkindexty;
  case kind: controlkindty of
   cok_for:(
    forinfo: forinfoty;
   );
 end;

 shortcutopty = (sco_none,sco_and,sco_or);
 shortcutexpty = record
  shortcuts: linkindexty; //resolved by linkresolveopad
  op: shortcutopty;
 end;
 
 implcontinfoty = record
//  elemark: markinfoty;
 end;
 
 progcontinfoty = record
  blockcountad: integer;
 end;
 
 listflagty = (lf_allconst);
 listflagsty = set of listflagty;
 
 listinfoty = record
  itemcount: int32;
  contextcount: int32;
  flags: listflagsty;
 end;
 
 indexinfoty = record
//  opshiftmark: integer;
  count: int32;
 end;
 
// datacontextflagty = (dcf_listitem);
// datacontextflagsty = set of datacontextflagty;
 
 datacontextty = record
//  flags: datacontextflagsty;
  indirection: integer; //pending
  datatyp: typeinfoty;
  case contextkindty of
   ck_const:(
    constval: dataty;
   );
   ck_fact,ck_subres:(
    fact: factinfoty;
   );
   ck_ref,ck_prop:(
    ref: refvaluety;
    case contextkindty of ck_prop:(
     prop: propinfoty;
    );
   );
   ck_label:(
    lab: elementoffsetty;
   );
 end;
 pdatacontextty = ^datacontextty;

 handlerflagty = (hf_listitem,hf_error,hf_down,hf_default,
                  hf_set,hf_clear,hf_long,hf_longset,hf_longclear,
                  hf_propindex,hf_needsunique);
 handlerflagsty = set of handlerflagty;
   
 contextdataty = record
//  elemark: elementoffsetty;
  handlerflags: handlerflagsty;
  case kind: contextkindty of
   ck_block:(
    block: blockinfoty;
   );
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
   ck_getindex:(
    getindex: getindexinfoty;
   );
   ck_list:(
    list: listinfoty;
   );
   ck_const,ck_fact,ck_subres,ck_prop,ck_ref,ck_reffact:( //datacontexts
    dat: datacontextty;
   );
   ck_index:(
    index: indexinfoty;
   );
   ck_subdef:(
    subdef: subinfoty;
   );
   ck_paramdef:(
    paramdef: paramdefinfoty;
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
   ck_classprop:(
    classprop: classpropinfoty;
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
   ck_shortcutexp:(
    shortcutexp: shortcutexpty;
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
//  handlerflags: handlerflagsty;
  transitionflags: branchflagsty;
  opmark: opmarkty;
//  bbindex: int32; //used in linkmarkphi
  b: contextbackupty;
  d: contextdataty;
 end;
 pcontextitemty = ^contextitemty;


// opinfoarty = array of opinfoty;
 errorlevelty = (erl_none,erl_fatal,erl_error,erl_warning,erl_note,erl_hint);
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
 
 unitstatety = ({us_interface,}us_program,us_interfaceparsed,
                     us_implementation,us_implementationparsed,
                     us_end, //pendings resolved
                     us_invalidunitfile
                     );
 unitstatesty = set of unitstatety;

 internalsubty = (isub_ini,isub_fini);
 internalsubarty = array[internalsubty] of opaddressty;
 
 unitrelocty = record
  interfaceelestart: elementoffsetty;
  interfaceelesize: elementsizety;
  interfaceglobstart: targetadty;
  interfaceglobsize: targetsizety;
  opstart: targetadty;
  opsize: targetsizety;
 end;

 punitinfoty = ^unitinfoty;
 unitinfopoarty = array of punitinfoty;
 unitinfoty = record
  key: identty;
  name: lstringty;
  namestring: string;
  prev: punitinfoty; //current uses compiled item

  filepath: filenamety; //todo: use lstringty
  filematch: filematchinfoty;
  rtfilepath: filenamety; //elements and opcode (interpreter only)
  bcfilepath: filenamety; //llvm bitcode
  bcfilename: filenamety;
  
  dwarflangid: int32;
  filepathmeta: metavaluety;
  debugfilemeta: metavaluety;
  compileunitmeta: metavaluety;
  mainsubmeta: metavaluety;
  subprograms: metavaluesty;
  globalvariables: metavaluesty;
//  param1poallocs: suballocinfoty;
  
  opseg: subsegmentty;
  mainad: int32;
    
  state: unitstatesty;
  interfaceelement: elementoffsetty;
  implementationelement: elementoffsetty;
  interfacestart: markinfoty;
  interfaceend: markinfoty;
  reloc: unitrelocty;
  
  implementationstart: markinfoty;
  implementationglobstart: targetadty;
  implementationglobsize: targetadty;
  globallocstart: int32; //first index in llvm globallocdatalist

  interfaceuses,implementationuses: unitinfopoarty;
  forwardlist: forwardindexty;
  forwardtypes: listadty;
  llvmlists: tllvmlists;
  nameid: int32;

  pendingcount: integer;
  pendingcapacity: integer;
  pendings: pendinginfoarty;
  varchain: elementoffsetty;
  pendingmanagechain: elementoffsetty;
  implstart: pparsercontextty; //start of implementation parsing
  internalsubs: internalsubarty;
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

 defineinfoty = record
  name: string;
  deleted: boolean;
//  id: identty;
 end;
 defineinfoarty = array of defineinfoty;
 
 parseoptionsty = record
  compileoptions: compileoptionsty;
  debugoptions: debugoptionsty;
  compilerswitches: compilerswitchesty;
  unitdirs: filenamearty;
  defines: defineinfoarty;
 end;
 
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
  stackref1: int32; //for directiveentryhandler()/directivehandler()
  unitinfo: punitinfoty;
  ssa: ssainfoty;
  pc: pcontextty;
  stopparser: boolean;
  stoponerror: boolean;
  interfaceonly: boolean;
  currentstatementflags: statementflagsty;
  currentopcodemarkchain: linkindexty;
  trystack: listadty;
  trystacklevel: int32;
  debugoptions: debugoptionsty;
  compilerswitches: compilerswitchesty;
  currentcompileunitmeta: metavaluety;
  currentfilemeta: metavaluety;
 // currentscopemeta: metavaluety;
  globlinkage: linkagety;
  blockid: int32;
 end;
  
 parseinfoty = record
  s: savedparseinfoty;
  o: parseoptionsty;
  rootelement: elementoffsetty;
  currentscopemeta: metavaluety;
  scopemetastack: metavaluearty;
  scopemetaindex: int32;
//  compilerswitches: compilerswitchesty;
  modularllvm: boolean;

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
  globdatapo: targetadty;
  locdatapo: targetadty;
  frameoffset: targetcardty;
  
  currentblockid: int32; //with and try blocks 
  currentsubchain: elementoffsetty;
  currentsubcount: integer;
  currentcontainer: elementoffsetty;
  currentclassvislevel: visikindsty;
  stringbuffer: string; //todo: use faster type
  includestack: array[0..includemax] of includeinfoty;
  includeindex: integer;
  systemunit: punitinfoty;
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
initialization
 info.o.compileoptions:= defaultcompileoptions;
 info.o.debugoptions:= defaultdebugoptions;
 info.o.compilerswitches:= defaultcompilerswitches;
end.