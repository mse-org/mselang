{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
unit handlerglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,{opcode,}opglob,listutils,llvmbitcodes,__mla__internaltypes;
const
 maxidentvector = 200;

type
 ordrangety = record
  min: int64;
  max: int64;
 end;
 card8infoty = record
  min: card8;
  max: card8;
 end;
 card16infoty = record
  min: card16;
  max: card16;
 end;
 card32infoty = record
  min: card32;
  max: card32;
 end;
 card64infoty = record
  min: card64;
  max: card64;
 end;

 int8infoty = record
  min: int8;
  max: int8;
 end;
 int16infoty = record
  min: int16;
  max: int16;
 end;
 int32infoty = record
  min: int32;
  max: int32;
 end;
 int64infoty = record
  min: int64;
  max: int64;
 end;
 float32infoty = record
  min: single;
  max: single;
 end;
 float64infoty = record
  min: double;
  max: double;
 end;
 char8infoty = record
  min: card8;
  max: card8;
 end;
 char16infoty = record
  min: card16;
  max: card16;
 end;
 char32infoty = record
  min: card32;
  max: card32;
 end;

 identvecty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;
 
 identsourceinfoty = record
  ident: identty;
  source: sourceinfoty;
 end;
 identsourcevecty = record
  high: integer;
  d: array[0..maxidentvector] of identsourceinfoty;
 end;

 arrayiteminfoty = record
  itemtypedata: elementoffsetty;
  itemindirectlevel: integer;
  totitemcount: int32; //includes itemcount of nested arrays
 end;
 infoarrayty = record
  i: arrayiteminfoty;
  indextypedata: elementoffsetty;
 end;

 infodynarrayty = record
  i: arrayiteminfoty;
 end;
 objsubattachty = (osa_new,osa_dispose,osa_ini,osa_fini,osa_afterconstruct,
                   osa_beforedestruct,osa_incref,osa_decref,osa_destroy,
                   osa_assign);
 subattachty = array[objsubattachty] of elementoffsetty;
{
 subattachty = record
  new,dispose,ini,fini,afterconstruct,beforedestruct,incref,decref,destroy,
  assign: elementoffsetty;
 end;
}
 infoclassflagty = (icf_class,icf_virtualtablevalid,icf_allocvalid,icf_defvalid,
                    icf_forward,
                    icf_zeroinit,icf_nozeroinit,icf_virtual,icf_except,
                    icf_rtti);
 infoclassflagsty = set of infoclassflagty;  
 infoclassty = record
  intfnamenode: elementoffsetty;
  intftypenode: elementoffsetty;
  implnode: elementoffsetty;
  objpotyp: elementoffsetty; //^object, 0 for ck_class
  classoftyp: elementoffsetty;
  defs: segaddressty; //classdefinfoty in target const
  defsid: int32;      //for llvm
  rttiid: int32;      //for llvm
  nameid: int32; //for llvm
  pendingdescends: listadty;
//  fieldsize: dataoffsty;
  allocsize: dataoffsty;
  propertycount: int32;
  propertychain: elementoffsetty; //0 -> none
  subchain: elementoffsetty; //0 ->none
  virttaboffset: int32;
  virtualcount: int32;
  flags: infoclassflagsty;
  instanceinterfacestart: int32;
  interfaceparent: elementoffsetty; //last parent with interface items
  interfacecount: integer;
  interfacechain: elementoffsetty;
  interfacesubcount: integer;
  subattach: subattachty;
 end;
 pinfoclassty = ^infoclassty;

 selfobjparamty = record
  methodelement: elementoffsetty;
  paramindex: int32;
  paramsize: int32;
 end;
 forwardpropty = record
  resinfo: dataoffsty;
  propele: elementoffsetty;
 end;
 exceptcasety = record
  startop: dataoffsty;
  first: boolean;
  last: boolean;
  elsefla: boolean;
 end;
  
 classpendingitemty = record
  header: linkheaderty;
  case int32 of
   0: (selfobjparam: selfobjparamty);
   1: (forwardprop: forwardpropty);
   2: (exceptcase: exceptcasety);
 end;
 pclasspendingitemty = ^classpendingitemty;

 ancestorchaindataty = record
  next: elementoffsetty;  //chain, root = typedataty.ancestor
  intftype: elementoffsetty;
 end;
 pancestorchaindataty = ^ancestorchaindataty;

 infointerfacety = record
//  ancestorchain: elementoffsetty; //-> infoancestordataty
  subchain: elementoffsetty;      //->
  subcount: integer;  
 end;
 pinfointerfacety = ^infointerfacety;

 infoclassofty = record
  classtyp: elementoffsetty;
 end;
 pinfoclassofty = ^infoclassofty;
 infosubty = record
  sub: elementoffsetty;
 end;
 pinfosubty = ^infosubty;
 
 infoenumitemty = record
  value: integer;
  enum: elementoffsetty;
  next: elementoffsetty;
 end;
 pinfoenumitemty = ^infoenumitemty;

 infoenumty = record
  itemcount: integer;
  first: elementoffsetty;
  last: elementoffsetty;
  min: elementoffsetty;
  max: elementoffsetty;
  flags: enumflagsty;
 end;
 
 infosetty = record
  itemtype: elementoffsetty;
 end;

 infoaddressty = record
  case integer of
   0: (sub: elementoffsetty);
 end;

 ptypedataty = ^typedataty; 

// writeiniprocty = procedure (const address: dataoffsty);
// writefiniprocty = procedure (const address: dataoffsty);
 addresskindty = boolean;{(adk_local,adk_global)}

 addressrefkindty = (ark_vardata,ark_vardatanoaggregate,ark_contextdata,
                     ark_local,ark_managedtemp,
                     ark_stack,ark_stackindi,ark_stackref,ark_tempvar);
 addressrefty = record //todo: resolve circular dependency, use real types
  offset: dataoffsty;
  ssaindex: int32;
  contextindex: int32; //for managedtypes
  isclass: boolean;
  case kind: addressrefkindty of
   ark_vardata,ark_vardatanoaggregate: (
    vardata: pointer;     //pvardataty //todo: use real type
   );         
   ark_contextdata: (
    contextdata: pointer; //pcontextdataty //todo: use real type
   ); 
   ark_stack,ark_stackref,ark_local,ark_tempvar: (
    typ: ptypedataty;
    case addressrefkindty of
     ark_stack,ark_stackref,ark_local: (
      address: dataoffsty;
     );
    ark_tempvar: (
     tempaddress: tempaddressty;
    );
   );
 end;
 managedopty = (mo_ini,mo_inizeroed,mo_fini,mo_incref,mo_decref,mo_decrefindi,
                mo_destroy);
 
 manageddataty = record
  managedele: elementoffsetty;
 end;
 pmanageddataty = ^manageddataty;

 refdataty = record
  ref: elementoffsetty;
 end;
 prefdataty = ^refdataty;

 managedtypeprocty = procedure(const op: managedopty; 
                                          const aadress: addressrefty);
 manageprockindty = (mpk_none,mpk_record,mpk_managearraydynar,
                     mpk_managearraystring,mpk_managedynarraydynar,
                     mpk_managedynarraystring,mpk_managedynarray,
                     mpk_managestring);
 
 typedataheaderty = record
  ancestor: elementoffsetty; //first, 
            //valid for ancestordatakinds and ancestorchaindatakinds
  kind: datakindty;
  base: elementoffsetty; //base type, ex: precordty = ^recordty -> recordty type
                         //used for addressing record fields or typex = typey
  rtti: dataaddressty; //0 -> none
  llvmrtticonst: int32; //listid in constlist
  llvmrttivar: int32; //listid in globlist
  rttinameid: int32;    //for external link
  manageproc: manageprockindty;
  flags: typeflagsty;
  indirectlevel: indirectlevelty; //total indirection count
  bitsize: integer;
  bytesize: integer;
  datasize: databitsizety;
  next: elementoffsetty; //for pending manageproc chain
  signature: card32;    //for operator overload
 end;

 stringflagty = (strf_bytes);
 stringflagsty = set of stringflagty;
 
 infostringty = record
  flags: stringflagsty;
 end;

 infooperatorty = record
 end;
  
 typedataty = record
  h: typedataheaderty;
  case datakindty of 
   dk_boolean:(
    dummy1: byte //for systypeinfos list
   );
   dk_cardinal:(
    case databitsizety of
     das_1,das_2_7,das_8: (infocard8: card8infoty);
     das_9_15,das_16: (infocard16: card16infoty);
     das_17_31,das_32: (infocard32: card32infoty);
     das_33_63,das_64: (infocard64: card64infoty);
   );
   dk_integer:(
    case databitsizety of  
     das_1,das_2_7,das_8: (infoint8: int8infoty);
     das_9_15,das_16: (infoint16: int16infoty);
     das_17_31,das_32: (infoint32: int32infoty);
     das_33_63,das_64: (infoint64: int64infoty);
   );
   dk_float:(
    case databitsizety of
     das_32:(infofloat32: float32infoty);
     das_64:(infofloat64: float64infoty);
   );
   dk_character:(
    case databitsizety of
     das_8: (infochar8: char8infoty);
     das_16: (infochar16: char16infoty);
     das_32: (infochar32: char32infoty);
   );
   dk_string,dk_dynarray,dk_openarray:(
//    manageproc: managedtypeprocty;
    itemsize: integer; //bytes
    case datakindty of
     dk_string:(
      infostring: infostringty;
     );
     dk_dynarray,dk_openarray:(
      infodynarray: infodynarrayty;
     );
   );
   dk_array:(
    infoarray: infoarrayty;
   );
   dk_address:(
    infoaddress: infoaddressty;
   );
   dk_record,dk_object,dk_class:(
    fieldcount: int32; //including ancestors
    fieldchain: elementoffsetty;
    case datakindty of
     dk_record,dk_class,dk_object:(
      recordmanagehandlers: array[managedopty] of elementoffsetty;
                    //offset to handler subinfoty,
      case datakindty of
       dk_class,dk_object:(
  //      classancestor: elementoffsetty;
        infoclass: infoclassty;
      );
     );
   );
   dk_interface:(
    infointerface: infointerfacety;
   );
   dk_classof:(
    infoclassof: infoclassofty;
   );
   dk_sub,dk_method:(
    infosub: infosubty;
   );
   dk_enum:(
    infoenum: infoenumty;
   );
   dk_enumitem:(
    infoenumitem: infoenumitemty;
   );
   dk_set:(
    infoset: infosetty;
   );
 end;
// ptypedataty = ^typedataty;
 
 vardestinfoty = record
  address: addressvaluety;
  offset: dataoffsty;
  typ: ptypedataty;
 end;
 
 constdataty = record
//  typ: elementoffsetty; //typedataty
  val: datainfoty;
//  d: contextdataty;
 end;
 pconstdataty = ^constdataty;

 vfinfoty = record
  typ: elementoffsetty;   //elementdata relative typedataty
  flags: typeflagsty;
  defaultconst: elementoffsetty;
  next: elementoffsetty;  //chain in same scope, used for ini, fini
                          //root = typedataty.fieldchain
 end;
 vardataty = record
  vf: vfinfoty;           //same layout as fielddataty
  address: addressvaluety; //indirectlevel = total
  nameid: int32; //for llvm
 end;
 pvardataty = ^vardataty;
 ppvardataty = ^pvardataty;

// vardatapoaty = array[0..0] of pvardataty;
// pvardatapoaty = ^vardatapoaty;

 fielddataty = record
  vf: vfinfoty;           //same layout as vardataty
  offset: dataoffsty;
  flags: addressflagsty;
  indirectlevel: integer; //total
 end;
 pfielddataty = ^fielddataty;

 propertydataty = record
  flags: propflagsty;
  typ: elementoffsetty;
  readele: elementoffsetty;
  readoffset: dataoffsty;
  writeele: elementoffsetty;
  writeoffset: dataoffsty;
  defaultconst: datainfoty;
  next: elementoffsetty;
 end;
 ppropertydataty = ^propertydataty;
 
 labeldefdataty = record
  adlinks: linkindexty;    //calls which need to be resolved
                           //by linkresolvegoto()
  blockid: int32; //with and try blocks
  address: opaddressty; //dest
  mark: forwardindexty;
 end;
 plabeldefdataty = ^labeldefdataty;
 
 nestedvardataty = record
  next: elementoffsetty; //chain, root = subdataty nestedvarchain
//  nestedindex: integer;
  address: nestedaddressty;
 end;
 pnestedvardataty = ^nestedvardataty;

 resulttypety = record
  typeele: elementoffsetty;
  indirectlevel: int32; //total
 end;
 subdataty = record
  next: elementoffsetty; //for subchain
  nextoverload: elementoffsetty; //0 = none
  impl: elementoffsetty; //pfuncdataty
  typ: elementoffsetty;  //typedataty dk_sub or dk_method for stf_getaddress
  calllinks: linkindexty;  //calls which need to be resolved 
                           //by linkresolvecall()
  adlinks: linkindexty;    //calls which need to be resolved
                           //by linkresolveopad()
  exitlinks: linkindexty;  //for exit statement, resolved by linkresolveopad
  mark: forwardindexty;
  flags: subflagsty;
  flags1: subflags1ty;
  tableindex: integer; //-1 = none
  address: opaddressty;
  trampolinelinks: linkindexty;   //for virtual interface items
  trampolineaddress: opaddressty;
  nestinglevel: integer;
  nestedvarele: elementoffsetty;
  nestedvarchain: elementoffsetty;
  nestedvarcount: integer;
  varchain: elementoffsetty;
//  varallocs: dataoffsty;
//  varalloccount: integer;
//  paramfinichain: elementoffsetty;
  resulttype: resulttypety;
  allocs: suballocinfoty;
  paramsize: integer;
  paramcount: integer;
  defaultparamcount: int32;
  globid: int32; //for llvm
  nameid: int32; //for llvm
  trampolineid: int32; //for llvm
  submeta: metavaluety; //for llvm
  linkage: linkagety;
  libname,funcname: identty;
  paramsrel: record //array of relative pvardataty (elementoffsetty)
  end;
 end;
 psubdataty = ^subdataty;

 internalsubflagty = (isf_pointerpar,
                      isf_ancestor,       //address is ancestor ele
                      isf_globalheader);  //use existing nameid
 internalsubflagsty = set of internalsubflagty;
  
 internalsubdataty = record
  address: opaddressty;
  globid: int32; //for llvm
  nameid: int32; //for llvm
  calllinks: linkindexty;
  flags: internalsubflagsty;
 end;
 pinternalsubdataty = ^internalsubdataty;

 sysfuncty = (syf_exit,syf_write,syf_writeln,
              syf_setlength,syf_unique,
              syf_initialize,syf_finalize,syf_incref,syf_decref,
              syf_sizeof,syf_classof,syf_typeinfo,
              syf_ord,
              syf_inc,syf_dec,syf_abs,
              syf_getmem,syf_getzeromem,syf_freemem,syf_reallocmem,syf_setmem,
              syf_memcpy,syf_memmove,
              syf_halt,
              syf_low,syf_high,syf_length,
              syf_ln,syf_exp,
              syf_sin,syf_cos,syf_sqrt,
              syf_floor,syf_frac,syf_round,syf_nearbyint,
              syf_truncint32,syf_truncint64,
              syf_trunccard32,syf_trunccard64,
              syf_getexceptobj,
              syf_copy);

 sysfuncdataty = record
  func: sysfuncty;
//  sysop: opty;
 end;
 psysfuncdataty = ^sysfuncdataty;

 operatordataty = record
  methodele: elementoffsetty;
 end;
 poperatordataty = ^operatordataty;
 
 globaldataty = record
 end;
 pglobaldataty = ^globaldataty;
 unitdataty = record
  varchain: elementoffsetty;
  next: elementoffsetty;
 end;
 punitdataty = ^unitdataty;
 implementationdataty = record
  exitlinks: linkindexty;  //for exit statement, resolved by linkresolveopad
 end;
 pimplementationdataty = ^implementationdataty;

 usesdataty = record
  ref: elementoffsetty;
 end;
 pusesdataty = ^usesdataty;
 
 conditiondataty = record
  deleted: boolean;
  value: dataty;
 end;
 pconditiondataty = ^conditiondataty;
 
 classimpnodedataty = record
 end;
 pclassimpnodedataty = ^classimpnodedataty;
 
 classintfnamenodedataty = record
 end;
 pclassintfnamenodedataty = ^classintfnamenodedataty;
 
 classintftypenodedataty = record
 end;
 pclassintftypenodedataty = ^classintftypenodedataty;
 
{
 classdataty = record
 end;
 pclassdataty = ^classdataty;
}
{
 classesdataty = record
  scopebefore: elementoffsetty;
 end;
 pclassesdataty = ^classesdataty;
}
 visibledataty = record
 end;
 pvisibledataty = ^visibledataty;
const 
 datasizes: array[0..64] of databitsizety = (
 //   0        1     2       3       4       5       6       7
  das_none,das_1,das_2_7,das_2_7,das_2_7,das_2_7,das_2_7,das_2_7,
 //   8     9        10       11       12       13       14       15   
  das_8,das_9_15,das_9_15,das_9_15,das_9_15,das_9_15,das_9_15,das_9_15,
 //   16     17        18        19        20        21        22        23 
  das_16,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,
 //   24        25        26        27        28           29        30        31
  das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,
 //   32     33        34        35        36        37        38        39 
  das_32,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   40        41        42        43        44        45        46        47
  das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   48        49        50        51        52        53        54        55
  das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   56        57        58        59        60        61        62        64
  das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   64 
  das_64);
  
 bitsizes: array[databitsizety] of integer =
//das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
 (    0,       1,      7,    8,      15,    16,       31,    32,
//das_33_63,das_64,das_pointer,         das_f16,das_f32,das_f64,
         63,    64,targetpointerbitsize,     16,     32,     64,
//das_sub,             das_meta
  targetpointerbitsize,0);
         
 bytesizes: array[databitsizety] of integer =
//das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
 (    0,       1,      1,    1,       2,     2,        4,     4,
//das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,
          8,     8,targetpointersize,2,      4,      8,
//das_sub,          das_meta
  targetpointersize,0);
 
function gettypesize(const typedata: typedataty): datasizety; inline;
function basetype(const atype: ptypedataty): elementoffsetty;
function basetype1(const atype: ptypedataty): ptypedataty;
function basetype(const atype: elementoffsetty): elementoffsetty;

procedure inittypedata(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; aflags: typeflagsty;
            {artti: dataaddressty;} aancestor: elementoffsetty); inline;
procedure inittypedatabit(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abitsize: integer;
            aflags: typeflagsty = [];
            {artti: dataaddressty = 0;} aancestor: elementoffsetty = 0); inline;
procedure inittypedatabyte(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abytesize: integer;
            aflags: typeflagsty = [];
            {artti: dataaddressty = 0;} aancestor: elementoffsetty = 0); inline;
procedure inittypedatasize(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; adatasize: databitsizety;
            aflags: typeflagsty = [];
            {artti: dataaddressty = 0;} aancestor: elementoffsetty = 0); inline;
procedure updatetypedatabyte(var atype: typedataty; abytesize: integer); inline;

procedure callmanageproc(const akind: manageprockindty; const op: managedopty; 
                                          const aadress: addressrefty);

implementation
uses
 elements,identutils,managedtypes,unithandler;

const
 manageprocs: array[manageprockindty] of managedtypeprocty = (
  //mpk_none,mpk_record,  mpk_managearraydynar,mpk_managearraystring
  nil,      @managerecord,@managearraydynar,   @managearraystring,
  //mpk_managedynarraydynar,mpk_managedynarraystring,mpk_managedynarray
  @managedynarraydynar,     @managedynarraystring,   @managedynarray,
  //mpk_managestring
  @managestring
 );

procedure callmanageproc(const akind: manageprockindty; const op: managedopty; 
                                          const aadress: addressrefty);
begin
 if akind <> mpk_none then begin
  manageprocs[akind](op,aadress);
 end;
end;
  
function gettypesize(const typedata: typedataty): datasizety; inline;
begin
 result:= typedata.h.bytesize;
 if typedata.h.indirectlevel <> 0 then begin
  result:= targetpointersize;
 end;
end;

function basetype(const atype: ptypedataty): elementoffsetty;
begin
 result:= atype^.h.base;
 if result = 0 then begin
  result:= ele.eledatarel(atype);
 end;
end;

function basetype(const atype: elementoffsetty): elementoffsetty;
begin
 result:= ptypedataty(ele.eledataabs(atype))^.h.base;
 if result = 0 then begin
  result:= atype;
 end;
end;

function basetype1(const atype: ptypedataty): ptypedataty;
begin
 if atype^.h.base = 0 then begin
  result:= atype;
 end
 else begin
  result:= ele.eledataabs(atype^.h.base);
 end;
end;

procedure inittypedata(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; aflags: typeflagsty;
            {artti: dataaddressty;} aancestor: elementoffsetty); inline;
begin
 atype.h.base:= 0;
 atype.h.rtti:= 0;//artti;
 atype.h.llvmrtticonst:= -1;
 atype.h.llvmrttivar:= -1;
 atype.h.rttinameid:= -1;
 atype.h.flags:= aflags;
 atype.h.indirectlevel:= aindirectlevel;
 atype.h.ancestor:= aancestor;
 atype.h.kind:= akind;
 atype.h.manageproc:= mpk_none;
 atype.h.signature:= getident();
end;

procedure inittypedatabit(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abitsize: integer;
            aflags: typeflagsty = [];
            {artti: dataaddressty = 0;} aancestor: elementoffsetty = 0); inline;
begin
 inittypedata(atype,akind,aindirectlevel,aflags,{artti,}aancestor);
 atype.h.bitsize:= abitsize;
 atype.h.bytesize:= (abitsize+7) div 8;
 if atype.h.bitsize >= 64 then begin
  atype.h.datasize:= das_none;
 end
 else begin
  atype.h.datasize:= datasizes[atype.h.bitsize];
 end;
end;

procedure inittypedatabyte(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abytesize: integer;
            aflags: typeflagsty = [];
            {artti: dataaddressty = 0;} aancestor: elementoffsetty = 0); inline;
begin
 inittypedata(atype,akind,aindirectlevel,aflags,{artti,}aancestor);
 atype.h.bytesize:= abytesize;
 atype.h.bitsize:= abytesize*8;
 if abytesize >= targetpointersize then begin
  atype.h.datasize:= das_none;
//  atype.h.bitsize:= 0;
 end
 else begin
  atype.h.datasize:= datasizes[atype.h.bitsize];
 end;  
end;

procedure updatetypedatabyte(var atype: typedataty; abytesize: integer); inline;
begin
 atype.h.bytesize:= abytesize;
 atype.h.bitsize:= abytesize*8;
 if (abytesize >= targetpointersize) or (atype.h.kind = dk_object) then begin
  atype.h.datasize:= das_none;
 end
 else begin
  atype.h.datasize:= datasizes[atype.h.bitsize];
 end;  
end;

procedure inittypedatasize(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; adatasize: databitsizety;
            aflags: typeflagsty = [];
            {artti: dataaddressty = 0;} aancestor: elementoffsetty = 0); inline;
begin
 inittypedata(atype,akind,aindirectlevel,aflags,{artti,}aancestor);
 atype.h.datasize:= adatasize;
 if akind = dk_method then begin
  atype.h.bytesize:= 2*targetpointersize;
  atype.h.bitsize:= 8*2*targetpointersize;
 end
 else begin
  atype.h.bytesize:= bytesizes[adatasize];
  atype.h.bitsize:= bitsizes[adatasize];
 end;
end;

end.