{ MSElang Copyright (c) 2014-2018 by Martin Schreiber
   
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
unit llvmlists;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 msetypes,msehash,globtypes,handlerglob,mselist,msestrings,llvmbitcodes,
 opglob,__mla__internaltypes,identutils;

const
 maxparamcount = 512;
 typeindexstep = 3;   //type list stack =   basetype [0]
                      //                   *basetype [1]
                      //                  **basetype [2]
 constlinkage = li_internal;


type
 bufferdataty = record
  listindex: int32;
  buffersize: int32;
  buffer: ptruint{card32}; 
             //direct data or buffer offset if buffersize > sizeof(ptruint)
 end;
 
 bufferhashdataty = record
  header: hashheaderty;
  data: bufferdataty;
 end;
 pbufferhashdataty = ^bufferhashdataty;
 
 bufferallocdataty = record
  data: pointer; //first!
  size: int32;
 end;

 buffermarkinfoty = record
  hashref: hashoffsetty;
  bufferref: ptruint;
 end;
 
 tbufferhashdatalist = class(thashdatalist)
  private
   fbuffer: pointer;
   fbuffersize: int32;
   fbuffercapacity: int32;
  protected
   procedure checkbuffercapacity(const asize: int32);
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
   function doadd(const adata: bufferallocdataty;
                out res: pbufferhashdataty; const unique: boolean): boolean;
   procedure addnotunique(const adata: bufferallocdataty;
                                          out res: pbufferhashdataty);
   function addunique(const adata: bufferallocdataty;
                       out res: pbufferhashdataty): boolean; //true if new
   function addunique(const adata: card32;
                       out res: pbufferhashdataty): boolean; //true if new
   function addunique(const adata; const size: integer;
                       out res: pbufferhashdataty): boolean; //true if new
   function getrecordsize(): int32 override;
  public
//   constructor create(const datasize: integer);
   procedure clear(); override;
   procedure mark(out ref: buffermarkinfoty);
   procedure release(const ref: buffermarkinfoty);
   function absdata(const aoffset: int32): pointer; inline;
   property buffer: pointer read fbuffer;
   property buffersize: int32 read fbuffersize;
   function getitemdata(aid: int32): pointer;
 end;


 keybufferdataty = record
  buffersize: int32;
  buffer: ptruint; //buffer offset
 end;
 pkeybufferdataty = ^keybufferdataty;
 
 keybufferhashdataty = record
  header: hashheaderty;
  data: keybufferdataty;
 end;
 pkeybufferhashdataty = ^keybufferhashdataty;

 tkeybufferhashdatalist = class(thashdatalist)
  private
   fbuffer: pointer;
   fbuffersize: integer;
   fbuffercapacity: integer;
  protected
   procedure checkbuffercapacity(const asize: integer);
   function addunique(const key; const abufferdata; const size: int32;
                      out res: pointer): boolean;
                    //true if new
   function getrecordsize(): int32 override;
  public
//   constructor create(const datasize: integer);
   procedure clear(); override;
   procedure mark(out ref: buffermarkinfoty);
   procedure release(const ref: buffermarkinfoty);
   function absdata(const aoffset: int32): pointer; inline;
 end;
  
 int32bufferdataty = record
  key: int32;
  data: record
  end;
 end;
 int32keybufferhashdataty = record
  header: keybufferhashdataty;
  data: int32bufferdataty;
 end;
 pint32keybufferhashdataty = ^int32keybufferhashdataty;
 
 tint32bufferhashdatalist = class(tkeybufferhashdatalist)
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
   function addunique(const akey: int32; const adata; const size: integer;
                       out res: pkeybufferdataty): boolean; //true if new
   function getrecordsize(): int32 override;
  public
//   constructor create(const datasize: integer);
 end;

 typelistdataty = record
  header: bufferdataty; //header.buffer -> alloc size if size = -1
  kind: databitsizety;
//  typealloc: typeallocinfoty;
 end;
 ptypelistdataty = ^typelistdataty;
 
 typelisthashdataty = record
  header: hashheaderty;
  data: typelistdataty;
 end;
 ptypelisthashdataty = ^typelisthashdataty;

 aggregatekindty = (ak_none,ak_pointerarray,ak_struct,ak_aggregatearray);
 typeallocdataty = record
  header: bufferallocdataty; //header.data -> alloc size if size = -1
  kind: databitsizety; //aggregatekindty if negative
 end;

 subtypeheaderty = record
  flags: subflagsty;
  paramcount: integer;
 end;
 psubtypeheaderty = ^subtypeheaderty;

 paramitemflagty = (pif_dumy{,pif_vararg});
 paramitemflagsty = set of paramitemflagty;
 paramitemty = record
  typelistindex: int32;
  flags: paramitemflagsty;
 end;
 pparamitemty = ^paramitemty;

 subtypedataty = record
  header: subtypeheaderty;
  params: record           //array of paramitemty
  end;
 end;
 psubtypedataty = ^subtypedataty;

 paramsty = record
  count: int32;
  items: pparamitemty;
 end;
 pparamsty = ^paramsty;

 aggregatearraytypedataty = record
  size: int32;
  typ: int32;
 end;
 paggregatearraytypedataty = ^aggregatearraytypedataty;
 
const
 noparams: paramsty = (
  count: 0;
  items: nil;
 );
 parampo: paramitemty = (
  typelistindex: ord(das_pointer);
  flags: [];
 );
  
 params1po: paramsty = (
  count: 1;
  items: @parampo;
 );
 
type
 ttypehashdatalist = class(tbufferhashdatalist)
  private
  protected
   fclassdef: int32;
   fopenarray: int32;
//   fmethod: int32;
   fintfitem: int32;
   flandingpad: int32;
   fsimplesub: int32;
   fpointerproc: int32;
   fmetadata: int32;
   fvoid: int32;
//   fpointerid: int32;
//   fsimplesub: int32;
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
   function addvalue(var avalue: typeallocdataty): ptypelisthashdataty; inline;
   function getrecordsize(): int32 override;
  public
   constructor create();
   procedure clear(); override; //automatic entries for bitsize optypes...
   function addbitvalue(const asize: databitsizety): integer; //returns listid
   function addbytevalue(const asize: integer): integer; //returns listid
   function addpointerarrayvalue(const asize: int32): integer;
   function addaggregatearrayvalue(const asize: int32;
                                            const atype: int32): integer;
   function addstructvalue(const atypes: array of int32): integer;
   function addstructvalue(const asize: int32; const atypes: pint32): integer;
   function addtypevalue(const atype: ptypedataty): integer; //returns listid
   function addvarvalue(const avalue: pvardataty): integer; //returns listid
   function addsubvalue(const avalue: psubdataty): integer; //returns listid
                         //nil -> main sub
   function addsubvalue(const aflags: subflagsty; 
                                          const aparams: paramsty): int32;
            //first item can be result type, returns listid
   function first: ptypelistdataty;
   function next: ptypelistdataty;
   property classdef: int32 read fclassdef;
   property openarray: int32 read fopenarray;
//   property method: int32 read fmethod;
   property intfitem: int32 read fintfitem;
   property landingpad: int32 read flandingpad;
   property pointerproc: int32 read fpointerproc;
   property metadata: int32 read fmetadata;
   property void: int32 read fvoid;
//   property pointerid: int32 read fpointerid;
   property simplesub: int32 read fsimplesub; //no params, 
//                                         //for initialization, finalizition
 end;

 consttypety = (ct_none,ct_null,ct_pointercast,ct_address,
                ct_pointerarray,ct_aggregatearray,ct_aggregate{,ct_intfitem});
                                            //stored as negative typeid

 constlistdataty = record
  header: bufferdataty;
  typeid: integer; // < 0 -> consttypety
 end;
 pconstlistdataty = ^constlistdataty;
 
 constlisthashdataty = record
  header: hashheaderty;
  data: constlistdataty;
 end;
 pconstlisthashdataty = ^constlisthashdataty;

 constallocdataty = record
  header: bufferallocdataty;  //header.data = ord value if size = -1
  typeid: integer;
 end;

//const
// nullconst = 256;
 
type
 aggregateconstheaderty = record
  typeid: int32;
  itemcount: int32;
 end;
 aggregateconstty = record
  header: aggregateconstheaderty;
  items: record //array[count] of int32
  end;
 end;
 paggregateconstty = ^aggregateconstty;
 
 addressconstty = record
  addressid: int32;
  offsetid: int32;
 end;
 paddressconstty = ^addressconstty;
{ 
 intfitemconstty = record
  instanceshiftid: int32;
  subid: int32;
 end;
 pintfitemconstty = ^intfitemconstty;
}

const
 aglocitemhigh = 0;
type
 aglocty = record
  ag: paggregateconstty;
  li,li1: pint32;
  ty,ty1: pint32;
  header: aggregateconstty;                       
  items: array[0..aglocitemhigh] of int32; //constlist ids
  types: array[0..aglocitemhigh] of int32;
 end;
 
 tgloballocdatalist = class;
 
 tconsthashdatalist = class(tbufferhashdatalist)
  private
   ftypelist: ttypehashdatalist;
//   fgloblist: tgloballocdatalist;
   fpointersize: int32;
   fvarrectysize: int32;
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
//   function addintfitem(const aitem: intfitemconstty): int32;
   function getrecordsize(): int32 override;
  public
   constructor create(const atypelist: ttypehashdatalist);
   procedure clear(); override; //init first entries with 0..255
   function addi1(const avalue: boolean): llvmvaluety;
   function addi8(const avalue: int8): llvmvaluety;
   function addi16(const avalue: int16): llvmvaluety;
   function addi32(const avalue: int32): llvmvaluety;
   function addi64(const avalue: int64): llvmvaluety;
   function addipo(const avalue: int64): llvmvaluety;
   function addf32(const avalue: flo32): llvmvaluety;
   function addf64(const avalue: flo64): llvmvaluety;
   function adddataoffs(const avalue: dataoffsty): llvmvaluety;
   function addvalue(const avalue; const asize: int32): llvmvaluety;
   function addvalue(const avalue: segaddressty;
                              const asize: int32): llvmvaluety;
   function addpointerarray(const alength: int32; const ids: pint32;
                                 const unique: boolean = true): llvmvaluety;
               //ids[asize] used for type id, restored
   function addaggregatearray(const asize: int32; const atype: int32; 
                                              const ids: pint32): llvmvaluety;
               //ids[asize] used for type id not restored
   function addpointercast(const aid: int32): llvmvaluety;
   function addaddress(const aid: int32; const aoffset: int32): llvmvaluety;
   function addaggregate(const avalue: paggregateconstty;
                                 const unique: boolean = true): llvmvaluety;
   function addtypedconst(const atype: elementoffsetty;
                                     var adata: pointer): llvmvaluety;
                                   //increments adata to next item
//   function addrtti(const artti: pcrttity): llvmvaluety;
   function addclassdef(const aclassdef: classdefpoty; 
                                        const aintfcount: int32): llvmvaluety;
                        //virtualsubconsts[virtualcount] used for typeid
   function addintfdef(const aintf: pintfdefinfoty;
                                       const acount: int32): llvmvaluety;
                                                   //overwrites aintf data
   function addagloc(const agloc: aglocty): llvmvaluety; //frees agloc
                                 //negative items -> seg_llvmconst linkindex
   function addnullvalue(const atypeid: int32): llvmvaluety;

   property typelist: ttypehashdatalist read ftypelist;
   function first(): pconstlisthashdataty;
   function next(): pconstlisthashdataty;
   function pointeroffset(const aindex: int32): int32; //offset in pointer array
   function i8(const avalue: int8): int32; //returns id
   function i8const(const avalue: int8): llvmvaluety;
   function nilpointer(): llvmvaluety;
   function gettype(const aindex: int32): int32;
   property pointersize: int32 read fpointersize; //type = pointerint
   property varrectysize: int32 read fvarrectysize;
 end;

 unitnamety = record //same layout as identnamety, used in tglobnamelist
  destindex: int32;
  po: pointer;   //punitinfoty;
 end;
  
 globnamedataty = record
  listindex: integer;
  case int32 of
   0: (name: identnamety);
   1: (nameunit: unitnamety);
 end;
 pglobnamedataty = ^globnamedataty;
 tglobnamelist = class(trecordlist)
  public
   constructor create;
   procedure addname(const aname: identnamety; const alistindex: integer);
   procedure addname(const aunit: pointer; //punitinfoty
                       const adestindex: integer; const alistindex: int32);
 end;
 
 linkdataty = record
  globid: int32;
 end;
 plinkdataty = ^linkdataty;
 linkhashdataty = record
  header: doubleintegerhashdataty;
  data: linkdataty;
 end;
 plinkhashdataty = ^linkhashdataty;
 
 tlinklist = class(tdoubleintegerhashdatalist)
  protected
   function getrecordsize(): int32 override;
  public
//   constructor create();
   procedure addlink(const adata: pointer; const aglobid: int32);
                         //element data
   procedure addlink(const extunit: pointer; //punitinfoty
                             const extglobid: int32; const locglobid: int32);
   function find(const aunit: pointer; //punitinfoty, nil -> element data
                 const akey: integer): plinkhashdataty;
 end;
 
 globallockindty = (gak_var,gak_const,gak_sub,gak_alias);
 globallocdataty = record
  typeindex: int32;
  initconstindex: int32; //aliasee for gak_alias
  linkage: linkagety;
  debuginfo: metavaluety;
  case kind: globallockindty of
   gak_sub: (flags: subflagsty;)
 end;
 pgloballocdataty = ^globallocdataty;
 
 tgloballocdatalist = class(trecordlist)
  private
   ftypelist: ttypehashdatalist;
   fconstlist: tconsthashdatalist;
   fnamelist: tglobnamelist;
   flinklist: tlinklist;
   flastitem: pgloballocdataty;
//   fgetexceptionpointer: int32;
  protected
   fdestroying: boolean;
   procedure inccount();
   function addnoinit(const atyp: int32; const alinkage: linkagety;
                      const externunit: boolean): int32;
   function addexternalsimplesub1({const aunit: pointer; //punitinfoty
          const anameid: int32;} const aflags: internalsubflagsty): int32;
                                                            //returns listid
  public
   constructor create(const atypelist: ttypehashdatalist;
                          const aconstlist: tconsthashdatalist);
   destructor destroy(); override;
   procedure clear(); override;
   function addvalue(const avalue: pvardataty; const alinkage: linkagety; 
                                    const externunit: boolean): int32;
                                                            //returns listid
   function addalias(const aliasee: int32; const name: identty): int32;
                                                            //returns listid
   function addbitvalue(const asize: databitsizety; const alinkage: linkagety; 
                                     const externunit: boolean): int32;
                                                            //returns listid
   function addbytevalue(const asize: integer;
                               const alinkage: linkagety; 
                                     const externunit: boolean): int32;
                                                            //returns listid
   function addexternalvalue(const avalue: pointer{pelementinfoty};
                                         //todo: fix circular unit reference
                                  const anameid: int32; const atype: int32;
                                         const alinkage: linkagety): int32;
                                                            //returns listid
   function addexternalvalue(const aname: identty; const atype: int32): int32;
                                                            //returns listid
   function addsubvalue(const avalue: psubdataty; //nil -> main sub
                              const externunit: boolean): int32; 
                                                            //returns listid
   function addexternalsimplesub(const asub: pinternalsubdataty): int32;
                                                            //returns listid
   function addexternalsimplesub(const aunit: pointer; //punitinfoty
          const anameid: int32; const aflags: internalsubflagsty): int32;
                                                            //returns listid
   function addexternalsimplesub(const aname: identty;
                               const aflags: internalsubflagsty): int32;
                                                            //returns listid
   function addsubvalue(const avalue: psubdataty;
                           const aname: identnamety): int32;  //returns listid
                               //nil -> main sub
   function addsubvalue(const aflags: subflagsty; const alinkage: linkagety; 
                             const aparams: paramsty): int32; 
                                                             //returns listid
   function addinternalsubvalue(const aflags: subflagsty; 
                                   const aparams: paramsty): int32; 
                                                             //returns listid
   function addexternalsubvalue(const aflags: subflagsty; 
                       const aparams: paramsty;
                           const aname: identnamety): int32;  //returns listid
   function addexternalsubvalue(const afunction : boolean;
                                 const aparamtypes: array of int32;
                           const aname: identnamety): int32;  
               //returns listid, for llvm functions like llvm.dbg.declare()

   procedure updatesubtype(const avalue: psubdataty); 
   function addinitvalue(const akind: globallockindty;
              const aconstlistindex: integer;
                const alinkage: linkagety; const nameid: int32 = -1): int32;
                                           //-1 -> unitnameid, returns listid
   function addidentconst(const aident: identty): llvmvaluety;
                                                    //string8 pointer
   function addrtticonst(const atype: ptypedataty): llvmvaluety; //prtti
//   function addclassdefconst(const atype: ptypedataty): llvmvaluety; 
                                                    //pclassdefinfoty
                        //too complicated because of forward definitions
   function addtypecopy(const alistid: int32): int32;
   function getinitconst(const alistid: int32): int32; //returns const listid
   function gettype(const alistid: int32): int32; //returns type listid
   function gettype1(const alistid: int32): metavaluety;
   property namelist: tglobnamelist read fnamelist;
   property linklist: tlinklist read flinklist;
   property lastitem: pgloballocdataty read flastitem;
//   property getexceptionpointer: int32 read fgetexceptionpointer;
       //"token" and llvm.eh.padparam.pNi8 seem not to work with llvm 3.8
 end;

const
 dummymeta: metavaluety = (id: -1);
type
 digenericdebugty = record
  tag: int32;
  len: int32;
  data: record  //array of metavaluety
  end;
 end;
 pdigenericdebugty = ^digenericdebugty;

 nodemetaty = record
  len: int32;
  data: record  //array of metavaluety
  end;
 end;
 pnodemetaty = ^nodemetaty;

 namednodemetaty = record
  len: int32;
  namelen: int32;
  data: record  //array of int32 metavalue index,name
  end;
 end;
 pnamednodemetaty = ^namednodemetaty;
 
 stringmetaty = record
  len: int32;
  data: record  //array of card8
  end;
 end;
 pstringmetaty = ^stringmetaty;

 valuemetaty = record
  value: llvmvaluety
 end;
 pvaluemetaty = ^valuemetaty;
 
 identmetaty = record
  name: identnamety;
 end;
 pidentmetaty = ^identmetaty;
 
 difilety = record
  filename: metavaluety;
  dirname: metavaluety;
 end;
 pdifilety = ^difilety;
{ 
 discopety = record
  difile: metavaluety;
 end;
 pdiscopety = ^discopety;
} 
 dicompileunitty = record
  difile: metavaluety;
  sourcelanguage: int32;
  producer: metavaluety;
  subprograms: metavaluety;
  globalvariables: metavaluety;
  emissionkind: debugemissionkind;
 end;
 pdicompileunitty = ^dicompileunitty;
 
 disubprogramty = record
  scope: metavaluety;
  _file: metavaluety;
  line: int32;
  _function: metavaluety;
  _type: metavaluety;
  localtounit: boolean;
  name: metavaluety;
  flags: dwsubflagsty;
  variables: metavaluety;
 end;
 pdisubprogramty = ^disubprogramty;

 disubroutinetypety = record
  params: metavaluety;
 end;
 pdisubroutinetypety = ^disubroutinetypety;

 dibasictypety = record
  tag: int32;
  name: metavaluety;
  sizeinbits: int32;
  aligninbits: int32;
  flags: int32;
  encoding: int32;
 end;
 pdibasictypety = ^dibasictypety;

 dienumeratorty = record
  name: metavaluety;
  value: int32;
 end;
 pdienumeratorty = ^dienumeratorty;
  
 disubrangety = record
  range: ordrangety;
 end;
 pdisubrangety = ^disubrangety;

 diderivedtypekindty = (didk_pointertype,didk_referencetype,didk_member);
 
 diderivedtypety = record
  kind: diderivedtypekindty;
  name: metavaluety;
  _file: metavaluety;
  line: int32;
  scope: metavaluety;
  basetype: metavaluety;
  sizeinbits: int32;
  aligninbits: int32;
  offsetinbits: int32;
  flags: int32;
 end;
 pdiderivedtypety = ^diderivedtypety;
 
 dicompositetypekindty = (dick_structuretype,dick_arraytype,dick_enumtype);

 dicompositetypety = record
  kind: dicompositetypekindty;
  name: metavaluety;
  _file: metavaluety;
  line: int32;
  scope: metavaluety;
  basetype: metavaluety;
  sizeinbits: int32;
  aligninbits: int32;
  offsetinbits: int32;
  flags: int32;
  elements: metavaluety;
 end;
 pdicompositetypety = ^dicompositetypety;

 dicharkindty = (dichk_char8,dichk_char16,dichk_char32);
 
 direfstringtypety = record
  name: metavaluety;
  chartype: dicharkindty;
 end;
 pdirefstringtypety = ^direfstringtypety;

 dilocvariablekindty = (divk_autovariable,divk_argvariable);
 
 dilocvariablety = record
  kind: dilocvariablekindty;
  scope: metavaluety;
  name: metavaluety;
  _file: metavaluety;
  linenumber: int32;
  _type: metavaluety;
  arg: int32;
  flags: int32;
 end;
 pdilocvariablety = ^dilocvariablety;

 diglobvariablety = record
  scope: metavaluety;
  name: metavaluety;        
  _file: metavaluety;       
  line: int32;       
  _type: metavaluety;
  variable: metavaluety;
  islocaltounit: boolean;
         //todo: declaration-defintion... flags
 end;
 pdiglobvariablety = ^diglobvariablety;

 expitemarty = array[0..3] of int32;
 diexpressionty = record
  count: int32;
  items: expitemarty;
 end;
 pdiexpressionty = ^diexpressionty;
{   
 metaiddataty = record
  id: int32;
 end;
 pmetaiddataty = ^metaiddataty;
} 
 typemetahashdataty = record
  header: tripleintegerhashdataty;
  data: metavaluety;
 end;
 ptypemetahashdataty = ^typemetahashdataty;

 ttypemetahashdatalist = class(ttripleintegerhashdatalist)
  protected
   function getrecordsize(): int32 override;
  public
//   constructor create();
 end;

 constmetahashdataty = record
  header: integerhashdataty;
  data: metavaluety;
 end;
 pconstmetahashdataty = ^constmetahashdataty;
 
 tconstmetahashdatalist = class(tintegerhashdatalist)
  protected
   function getrecordsize(): int32 override;
  public
//   constructor create();
 end;
 
 
 metadatakindty = (mdk_none,{mdk_void,}mdk_digenericdebug,
                   mdk_node,mdk_namednode,
                   mdk_string,mdk_ident,mdk_constvalue,mdk_globvalue,
                   mdk_difile,mdk_dibasictype,mdk_disubrange,mdk_dienumerator,
                   mdk_diderivedtype,mdk_dicompositetype,mdk_direfstringtype,
                   {mdk_discope,}
                   mdk_dicompileunit,mdk_disubprogram,mdk_disubroutinetype,
                   mdk_dilocvariable,mdk_diglobvariable,mdk_diexpression);
 
 metadataheaderty = record
  kind: metadatakindty;
 end;
 pmetadataheaderty = ^metadataheaderty;
 
 metadataty = record
  header: metadataheaderty;
  data: record
  end;
 end;
 pmetadataty = ^metadataty;

 tmetadatalist = class(tindexbufferdatalist)
  private
   femptynode: metavaluety;
   ftypelist: ttypehashdatalist;
   fconstlist: tconsthashdatalist;
   fgloblist: tgloballocdatalist;
   funitlist: tpointerint32hashdatalist;
   ftypemetalist: ttypemetahashdatalist;
   fconstmetalist: tconstmetahashdatalist;
   fsyscontext: metavaluety;
   fsysfile: metavaluety;
   fsysname: metavaluety;
   fcompileunit: metavaluety;
   fcompilefile: metavaluety;
   fdbgdeclare: int32;
   femptystringconst: metavaluety;
   fhasmoduleflags: boolean;
   fdummyaddrexp: metavaluety;
   fderefaddrexp: metavaluety;
   fopenarrayaddrexp: metavaluety;
   fnoparams: metavaluety;
   fpointertyp: metavaluety;
   fbytetyp: metavaluety;
   fparams1po: metavaluety;
   fparams1posubtyp: metavaluety;
   fnoparamssubtyp: metavaluety;
   fdynarrayindex: metavaluety;
   function getparams1po: metavaluety;
   function getpointertyp: metavaluety;
   function getbytetyp: metavaluety;
   function getparams1posubtyp: metavaluety;
   function getdynarrayindex: metavaluety;
   function getnoparamssubtyp: metavaluety;
   function getnoparams: metavaluety;
  protected
   function adddata(const akind: metadatakindty;
       const adatasize: int32; out avalue: metavaluety): pointer; reintroduce;
  public
   constructor create(const atypelist: ttypehashdatalist;
                          const aconstlist: tconsthashdatalist;
                          const agloblist: tgloballocdatalist);
   destructor destroy(); override;
   procedure clear(); override;
   procedure beginunit();
   function i8const(const avalue: int8): metavaluety;
   function i32const(const avalue: int32): metavaluety;
   property emptynode: metavaluety read femptynode;

   function addconst(const constid: int32): metavaluety;
   function addglobvalue(const globid: int32): metavaluety;

   function adddigenericdebug(const atag: int32; const avalues: pmetavaluety;
                                     const acount: int32): metavaluety;
                                     //not finished
   function adddigenericdebug(const atag: int32; 
                             const avalues: array of metavaluety): metavaluety;
                                     //not finished
   
   function addnode(const avalues: pmetavaluety;
                                     const acount: int32): metavaluety;
   function addnode(const valuesa: pmetavaluety; const counta: int32;
                const valuesb: pmetavaluety; const countb: int32): metavaluety;
   function addnode(const avalues: array of metavaluety): metavaluety;
   function addnode(const avalues: metavaluesty): metavaluety;
   function addnodereverse(const avalues: pmetavaluety;
                                        const acount: int32): metavaluety;
   function addnodereverse(const valuesa: pmetavaluety; const counta: int32;
                const valuesb: pmetavaluety; const countb: int32): metavaluety;

   procedure addnamednode(const aname: lstringty;
                                const avalues: array of int32);
   function addident(const aident: identnamety): metavaluety;
   function addstring(const avalue: lstringty): metavaluety;
   function addstring(const avalue: string): metavaluety;
   function addstringornull(const avalue: lstringty): metavaluety;
   function adddifile(const afilename: filenamety): metavaluety;

   function adddibasictype(const aname: lstringty;
           const asizeinbits: int32; const aaligninbits: int32;
           const aflags: int32; const aencoding: int32): metavaluety;
   function adddienumerator(const aname: lstringty;
                                  const avalue: int32): metavaluety;
   function adddisubrange(const arange: ordrangety): metavaluety;
   function adddiderivedtype(const akind: diderivedtypekindty;
           const adifile: metavaluety;
           const ascope: metavaluety; const aname: lstringty;
           const aline: int32;
           const asizeinbits: int32; const aaligninbits: int32;
           const aoffsetinbits: int32;
           const aflags: int32; const abasetype: metavaluety): metavaluety;
   function adddicompositetype(const akind: dicompositetypekindty; 
           const aname: lstringty;
           const adifile: metavaluety;
           const aline: int32;
           const ascope: metavaluety;
           const abasetype: metavaluety;
           const asizeinbits: int32; const aaligninbits: int32;
           const aoffsetinbits: int32;
           const aflags: int32;
           const aelements: metavaluety): metavaluety;
   function adddirefstringtype(const aname: lstringty;
                                const akind: dicharkindty): metavaluety;
   function addtype(atype: elementoffsetty; //0 -> untyped pointer
                         aindirection: int32;
                              const subrange: boolean = false): metavaluety;
   function addtype(const avariable: vardataty): metavaluety;
   function adddicompileunit(const afile: metavaluety; 
          const asourcelanguage: int32; const aproducer: string;
          const asubprograms: metavaluety; const aglobalvariables: metavaluety;
                           const aemissionkind: DebugEmissionKind): metavaluety;
   function adddisubroutinetype(const asub: psubdataty{;
                     const afile: metavaluety;
                                 const acontext: metavaluety}): metavaluety;
   function adddisubprogram(
          const ascope: metavaluety; const aname: identnamety;
          const afile: metavaluety; const aline: int32;
          const afunction: int32; //global id
          const atype: metavaluety; const aflags: dwsubflagsty;
          const alocaltounit: boolean): metavaluety;
   function adddivariable(const aname: lstringty;
                       const alinenumber: int32; const argnumber: int32;
          const avariable: vardataty; const atype: metavaluety): metavaluety;
   function adddivariable(const aname: lstringty;
           const alinenumber: int32; const argnumber: int32;
                                 const avariable: vardataty): metavaluety;
   function adddiexpression(
                        const aexpression: array of int32): metavaluety;   
  {
   function adddicompositetype(const atag: int32; 
                       const aitems: array of metavaluety): metavaluety;
  }
   function getdata(const avalue: metavaluety): pointer;
   function getstringvalue(const avalue: metavaluety): lstringty;
   function first: pmetadataty; //nil if none
   function next: pmetadataty;  //nil if none
//   property subprograms: metavaluesty read getsubprograms;
//   property globalvariables: metavaluesty read getglobalvariables;
//   property voidconst: metavaluety read fvoidconst;
//   property nullintconst: metavaluety read fnullintconst;

   property emptystringconst: metavaluety read femptystringconst;
//   property voidtyp: metavaluety read getvoidtyp;
   property pointertyp: metavaluety read getpointertyp;
   property bytetyp: metavaluety read getbytetyp;
   property noparams: metavaluety read getnoparams; //[dummymeta]
   property params1po: metavaluety read getparams1po; 
                                             //[dummymeta,pointertype]
   property noparamssubtyp: metavaluety read getnoparamssubtyp;
   property params1posubtyp: metavaluety read getparams1posubtyp;
   property dynarrayindex: metavaluety read getdynarrayindex; //[0..-1]

//   property wdstringconst: metavaluety read fwdstringconst; //'./'
   property dbgdeclare: int32 read fdbgdeclare; //globvalue id
   property dummyaddrexp: metavaluety read fdummyaddrexp;
   property derefaddrexp: metavaluety read fderefaddrexp;
   property openarrayaddrexp: metavaluety read fopenarrayaddrexp;
   property hasmoduleflags: boolean read fhasmoduleflags write fhasmoduleflags;
 end;

 tllvmlists = class
  private
   ftypelist: ttypehashdatalist;
   fconstlist: tconsthashdatalist;
   fgloblist: tgloballocdatalist;
   fmetadatalist: tmetadatalist;
  public
   constructor create();
   destructor destroy(); override;
   procedure clear();
   property typelist: ttypehashdatalist read ftypelist;
   property constlist: tconsthashdatalist read fconstlist;
   property globlist: tgloballocdatalist read fgloblist;
   property metadatalist: tmetadatalist read fmetadatalist;
 end; 

const
 nullconsts: array[databitsizety] of nullconstty = (
//das_none,das_1, das_2_7, das_8, das_9_15, das_16, das_17_31,das_32,
  nco_none,nco_i1,nco_none,nco_i8,nco_none, nco_i16,nco_none, nco_i32,               
//das_33_63,das_64, das_pointer,das_f16, das_f32, das_f64,
  nco_none, nco_i64,nco_none,   nco_none,nco_f32,nco_f64,
//das_sub, das_meta
  nco_none,nco_none);

 oneconsts: array[databitsizety] of oneconstty = (
//das_none,das_1, das_2_7, das_8, das_9_15, das_16, das_17_31,das_32,
  oco_none,oco_i1,oco_none,oco_i8,oco_none, oco_i16,oco_none, oco_i32,               
//das_33_63,das_64, das_pointer,das_f16, das_f32, das_f64,
  oco_none, oco_i64,oco_none,   oco_none,oco_f32,oco_f64,
//das_sub, das_meta
  oco_none,oco_none);

 maxconsts: array[databitsizety] of maxconstty = (
//das_none,das_1, das_2_7, das_8, das_9_15, das_16, das_17_31,das_32,
  mco_none,mco_i1,mco_none,mco_i8,mco_none, mco_i16,mco_none, mco_i32,               
//das_33_63,das_64, das_pointer,das_f16, das_f32, das_f64,
  mco_none, mco_i64,mco_none,   mco_none,mco_none,mco_none,
//das_sub, das_meta
  mco_none,mco_none);

 ashrconsts: array[databitsizety] of ashrconstty = (
//das_none,das_1, das_2_7, das_8, das_9_15, das_16, das_17_31,das_32,
  asco_none,asco_i1,asco_none,asco_i8,asco_none, asco_i16,asco_none, asco_i32,               
//das_33_63,das_64, das_pointer,das_f16, das_f32, das_f64,
  asco_none, asco_i64,asco_none,   asco_none,asco_none,asco_none,
//das_sub, das_meta
  asco_none,asco_none);

procedure addmetaitem(var alist: metavaluesty; const aitem: metavaluety);
procedure updatellvmclassdefs(const updatesubs: boolean);
function getclassdefid(const atype: ptypedataty): int32;

implementation
uses
 parserglob,errorhandler,elements,segmentutils,msefileutils,msearrayutils,
 opcode,handlerutils,compilerunit,typehandler,rttihandler,unithandler;

function getclassid(var asegoffset: int32): int32;
var
 typ1: ptypedataty;
begin
 if asegoffset < 0 then begin
  typ1:= ele.eledataabs(-asegoffset);
 {$ifdef mse_checkinternalerror}
  if (datatoele(typ1)^.header.kind <> ek_type) or 
           not (typ1^.h.kind in [dk_object,dk_class]) then begin
   internalerror(ie_llvmlist,'201810716A');
  end;
 {$endif}
 {$ifdef mse_checkinternalerror}
  if (typ1^.infoclass.defsid < 0) and (typ1^.infoclass.nameid < 0) then begin
   internalerror(ie_llvmlist,'20180716B');
//   result:= -1; //not ready;
  end;
 {$endif}
  result:= trackaccess(typ1);
  asegoffset:= -1;
 end
 else begin
  result:= (pclassdefconstheaderty(getsegmentpo(seg_classdef,asegoffset))-1)^.
                                                                        defsid;
                                             //header in negative offset
 end;
end;

procedure updatellvmclassdefs(const updatesubs: boolean);

var
 {offss,}offse: int32;
 
 procedure setvirtsubs(const atyp: ptypedataty; const offss: int32);
 var
  ele1: elementoffsetty;
  sub1: psubdataty;
  v1: llvmvaluety;
  i1,i2: int32;
 begin
  if atyp^.h.ancestor > 0 then begin
   setvirtsubs(ele.eledataabs(atyp^.h.ancestor),offss);
  end;
  ele1:= atyp^.infoclass.subchain;
  while ele1 <> 0 do begin
   sub1:= ele.eledataabs(ele1);
(*
   if sf_virtual in sub1^.flags then begin
   {$ifdef mse_checkinternalerror}
    if offs >= offse then begin
     internalerror(ie_llvmlist,'20180506A');
    end;
   {$endif}
    i1:= trackaccess(sub1);
   {$ifdef mse_checkinternalerror}
    if i1 < 0 then begin
     internalerror(ie_llvmlist,'20190703A');
    end;
   {$endif}
    with info.s.unitinfo^.llvmlists.constlist do begin
     v1:= addpointercast(i1);
     pint32(absdata(offs))^:= v1.listid;
    end;
    inc(offs,sizeof(int32));
   end;
*)
   if sub1^.flags * [sf_virtual,sf_override] <> [] then begin
    i1:= offss + sub1^.tableindex * sizeof(int32);
   {$ifdef mse_checkinternalerror}
    if i1 >= offse then begin
     internalerror(ie_llvmlist,'20180508A');
    end;
   {$endif}
    i2:= trackaccess(sub1);
   {$ifdef mse_checkinternalerror}
    if i2 < 0 then begin
     internalerror(ie_llvmlist,'20190703A');
    end;
   {$endif}
    with info.s.unitinfo^.llvmlists.constlist do begin
     v1:= addpointercast(i2);
     pint32(absdata(i1))^:= v1.listid;
    end;
   end;
   ele1:= sub1^.next;
  end;
 end; //setvirtsubs()

var
 poclassdef,peclassdef: ^classdefty;
 header1: pclassdefconstheaderty;
 i1,i2,i3: int32;
 typ1: ptypedataty;
 globdat1: pgloballocdataty;
 bufdat1: paggregateconstty;
 p1: pointer;
 li1: linkagety;
label
 loopend;
begin
//  checkpendingmanagehandlers();
 poclassdef:= getsegmentbase(seg_classdef) + sizeof(classdefconstheaderty);
 peclassdef:= getsegmenttop(seg_classdef);
// countpo:= getsegmentbase(seg_classintfcount);
 while poclassdef < peclassdef do begin   //classes
  header1:= pclassdefconstheaderty(poclassdef)-1; //header in negative offset
  typ1:= ele.eledataabs(header1^.typedata);
  i1:= header1^.intfcount;
  if typ1^.infoclass.defsid < 0 then begin
   if not updatesubs and 
           not (us_implementationblock in info.s.unitinfo^.state) and 
                                                  info.modularllvm then begin
    typ1^.infoclass.nameid:= getunitnameid(); //in interface part
    goto loopend;
   end;
   li1:= constlinkage;
   if vik_global in datatoele(typ1)^.header.visibility then begin
    li1:= li_external;
   end;
{
   if (icf_rtti in typ1^.infoclass.flags) then begin
    poclassdef^.header.rtti:= info.s.unitinfo^.
                        llvmlists.globlist.addrtticonst(typ1).listid;
   end;
}
   typ1^.infoclass.defsid:= info.s.unitinfo^.llvmlists.globlist.
          addinitvalue(gak_const,
              info.s.unitinfo^.llvmlists.constlist.addclassdef(
                                              poclassdef,i1).listid,
                                                 li1,typ1^.infoclass.nameid);
   if (li1 = li_external) and (typ1^.infoclass.nameid < 0) then begin
    typ1^.infoclass.nameid:= info.s.unitinfo^.nameid;
   end;
   header1^.defsid:= typ1^.infoclass.defsid;
  {$ifdef mse_checkinternalerror}
   if not (typ1^.h.kind in [dk_object,dk_class]) then begin
    internalerror(ie_llvmlist,'20171118A');
   end;
  {$endif}
{
   if typ1^.h.llvmrtticonst > 0 then begin
    i3:= getrtti(typ1);
    with info.s.unitinfo^.llvmlists.constlist do begin
     bufdat1:= getitemdata(typ1^.h.llvmrtticonst);
     pint32(@bufdat1^.items)[classrttidefindex]:= i3;
//     pint32(@bufdat1^.items)[classrttidefindex]:= 
//                            addpointercast(pint32(poclassdef)^).listid;
              //todo: hide for search because hash is wrong
    end;
   end;
}
  end;
  if updatesubs then begin
  (*
   if poclassdef^.header.parentclass < -1 then begin
    i1:= getclassid(poclassdef^.header.parentclass);
   {$ifdef mse_checkinternalerror}
    if i1 < 0 then begin
     internalerror(ie_llvmlist,'20180716B');
    end;
   {$endif}
    with info.s.unitinfo^.llvmlists do begin
     i3:= constlist.addpointercast(i1).listid;
     bufdat1:= constlist.getitemdata(
               globlist.getinitconst(typ1^.infoclass.defsid));
     pint32(@bufdat1^.items)[classparentindex]:= i3;
    end;
   end;
  *)
   if typ1^.h.llvmrtticonst > 0 then begin
 //   i3:= getrtti(typ1);
    with info.s.unitinfo^.llvmlists,constlist do begin
     i3:= addpointercast(typ1^.infoclass.defsid).listid;
     bufdat1:= getitemdata(typ1^.h.llvmrtticonst);
     pint32(@bufdat1^.items)[classrttidefindex]:= i3;
 //     pint32(@bufdat1^.items)[classrttidefindex]:= 
 //                            addpointercast(pint32(poclassdef)^).listid;
              //todo: hide for search because hash is wrong
    end;
   end;
   if (typ1^.infoclass.virtualcount > 0) then begin
    with info.s.unitinfo^.llvmlists do begin
     bufdat1:= constlist.getitemdata(
                       globlist.getinitconst(typ1^.infoclass.defsid));
     i2:= constlist.getitemdata(pint32(@bufdat1^.items)[classvirttabindex]) -
                                                               constlist.buffer;
 //    pd:= @bufdat2.
    end;
//    offss:= i2;
    offse:= i2 + typ1^.infoclass.virtualcount * sizeof(int32);
    setvirtsubs(typ1,i2);
(*
   {$ifdef mse_checkinternalerror}
    if i2 <> offse then begin
     internalerror(ie_llvmlist,'20180506B');
    end;
   {$endif}
*)
   end;
  end;
loopend:
  poclassdef:= pointer(poclassdef) + sizeof(classdefconstheaderty) +
                       poclassdef^.header.allocs.classdefinterfacestart +
                                                          i1*targetpointersize;
 end;
end;

function getclassdefid(const atype: ptypedataty): int32;
begin
 if atype^.infoclass.defsid < 0 then begin
  updatellvmclassdefs(false);
  if atype^.infoclass.defsid < 0 then begin
   internalerror1(ie_handler,'20180503');
  end;
 end;
 result:= trackaccess(atype);
// result:= atype^.infoclass.defsid;
end;
  
procedure addmetaitem(var alist: metavaluesty; const aitem: metavaluety);
begin
 with alist do begin
  if count >= high(data) then begin
   reallocuninitedarray(count*2+32,sizeof(metavaluety),data);
  end;
  data[count]:= aitem;
  inc(count);
 end;
end;

{ tbufferhashdatalist }
{
constructor tbufferhashdatalist.create(const datasize: integer);
begin
 inherited create(sizeof(bufferhashdataty)-sizeof(hashheaderty)+datasize);
end;
}
function tbufferhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(bufferhashdataty);
end;

procedure tbufferhashdatalist.checkbuffercapacity(const asize: int32);
begin
 fbuffersize:= ((fbuffersize + asize)+3) and -4;
 if fbuffersize > fbuffercapacity then begin
  fbuffercapacity:= fbuffersize*2 + 1024;
  reallocmem(fbuffer,fbuffercapacity);
 end;
end;

procedure tbufferhashdatalist.clear;
begin
 inherited;
 if fbuffer <> nil then begin
  freemem(fbuffer);
  fbuffer:= nil;
  fbuffercapacity:= 0;
 end;
 fbuffersize:= 0;
end;

procedure tbufferhashdatalist.mark(out ref: buffermarkinfoty);
begin
 inherited mark(ref.hashref);
 ref.bufferref:= fbuffersize;
end;

procedure tbufferhashdatalist.release(const ref: buffermarkinfoty);
begin
 inherited release(ref.hashref);
 fbuffersize:= ref.bufferref;
end;

function tbufferhashdatalist.hashkey(const akey): hashvaluety;
begin
 with bufferallocdataty(akey) do begin
  if size < 0 then begin
   result:= scramble(hashvaluety(ptruint(pointer(data))));
  end
  else begin
   result:= datahash2(data^,size);
  end;
 end;
end;

function tbufferhashdatalist.checkkey(const akey; 
                                     const aitem: phashdataty): boolean;
var
 po1,po2,pe: pcard8;
begin
 result:= true;
 with pbufferhashdataty(aitem)^.data do begin
  if buffersize <> bufferallocdataty(akey).size then begin
   result:= false;
  end
  else begin
   if buffersize < 0 then begin
    result:= ptruint(akey) = buffer;
   end
   else begin
    po1:= bufferallocdataty(akey).data;
    pe:= po1 + buffersize;
    po2:= fbuffer + buffer;
    while po1 < pe do begin
     if po1^ <> po2^ then begin
      result:= false;
      exit;
     end;
     inc(po1);
     inc(po2);
    end;
   end;
  end
 end;
end;

function tbufferhashdatalist.doadd(const adata: bufferallocdataty;
                   out res: pbufferhashdataty; const unique: boolean): boolean;
var
 po1: pbufferhashdataty;
begin
 result:= true;
 if unique then begin
  po1:= pointer(internalfind(adata));
  result:= po1 = nil;
 end;
 if result then begin
  po1:= pointer(internaladd(adata));
  if adata.size < 0 then begin
   po1^.data.buffersize:= -1;
   po1^.data.buffer:= ptruint(adata.data);
  end
  else begin
   po1^.data.buffer:= fbuffersize;
   checkbuffercapacity(adata.size);
   po1^.data.buffersize:= adata.size;
   move(adata.data^,(fbuffer+po1^.data.buffer)^,adata.size);
  end;
  po1^.data.listindex:= count-1;
 end;
 res:= po1;
end;

procedure tbufferhashdatalist.addnotunique(const adata: bufferallocdataty;
               out res: pbufferhashdataty);
begin
 doadd(adata,res,false);
end;

function tbufferhashdatalist.addunique(const adata: bufferallocdataty;
               out res: pbufferhashdataty): boolean;
begin
 result:= doadd(adata,res,true);
end;

function tbufferhashdatalist.addunique(const adata: card32;
                                     out res: pbufferhashdataty): boolean;
var
 a1: bufferallocdataty;
 po1: pbufferhashdataty;
begin
 a1.size:= -1;
 a1.data:= pointer(ptruint(adata));
 result:= addunique(a1,res);
end;

function tbufferhashdatalist.addunique(const adata;  const size: integer;
                              out res: pbufferhashdataty): boolean;
var
 a1: bufferallocdataty;
 po1: pbufferhashdataty;
begin
 a1.size:= size;
 a1.data:= @adata;
 result:= addunique(a1,res);
end;

function tbufferhashdatalist.absdata(const aoffset: int32): pointer; inline;
begin
 result:= fbuffer+aoffset;
end;

function tbufferhashdatalist.getitemdata(aid: int32): pointer;
var
 p1: pbufferhashdataty;
begin
 inc(aid);
{$ifdef mse_checkinternalerror}
 if (aid < 1) or (aid > count) then begin
  internalerror(ie_llvmlist,'20171119A');
 end;
{$endif}
 p1:= fdata + aid * recsize;
 if p1^.data.buffersize < 0 then begin
  result:= @p1^.data.buffer;
 end
 else begin
  result:= fbuffer+p1^.data.buffer;
 end;
end;

{ tkeybufferhashdatalist }
{
constructor tkeybufferhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(keybufferdataty));
end;
}
function tkeybufferhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(keybufferhashdataty);
end;

procedure tkeybufferhashdatalist.checkbuffercapacity(const asize: integer);
begin
 fbuffersize:= fbuffersize + asize;
 if fbuffersize > fbuffercapacity then begin
  fbuffercapacity:= fbuffersize*2 + 1024;
  reallocmem(fbuffer,fbuffercapacity);
 end;
end;

function tkeybufferhashdatalist.addunique(const key; const abufferdata;
               const size: int32; out res: pointer): boolean;
var
 po1: pkeybufferhashdataty;
begin
 po1:= pointer(internalfind(key));
 result:= po1 = nil;
 if result then begin
  po1:= pointer(internaladd(key));
  po1^.data.buffer:= fbuffersize;
  checkbuffercapacity(size);
  po1^.data.buffersize:= size;
  move(abufferdata,(fbuffer+po1^.data.buffer)^,size);
 end;
 res:= po1;
end;

procedure tkeybufferhashdatalist.clear();
begin
 inherited;
 if fbuffer <> nil then begin
  freemem(fbuffer);
  fbuffer:= nil;
  fbuffercapacity:= 0;
 end;
 fbuffersize:= 0;
end;

procedure tkeybufferhashdatalist.mark(out ref: buffermarkinfoty);
begin
 inherited mark(ref.hashref);
 ref.bufferref:= fbuffersize;
end;

procedure tkeybufferhashdatalist.release(const ref: buffermarkinfoty);
begin
 inherited release(ref.hashref);
 fbuffersize:= ref.bufferref;
end;

function tkeybufferhashdatalist.absdata(const aoffset: int32): pointer;
begin
 result:= fbuffer+aoffset;
end;

{ ttypehashdatalist }

constructor ttypehashdatalist.create();
begin
// inherited create(sizeof(typeallocinfoty));
// inherited create(sizeof(typelisthashdataty)-sizeof(bufferhashdataty));
 inherited;
 clear();
end;

function ttypehashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(typelisthashdataty);
end;

const
 simpleprocparams: paramsty = (count: 0; items: nil);
 pointerprocpar: array[0..0] of paramitemty = (
              (typelistindex: pointertype; flags: [])
 );
 pointerprocparams: paramsty = (count: 1; items: @pointerprocpar);

procedure ttypehashdatalist.clear;
var
 k1: databitsizety;
 t1: typeallocdataty;
// params1: paramsty;
begin
 inherited;
 if not (hls_destroying in fstate) then begin
  for k1:= low(databitsizety) to lastdatakind do begin
   addbitvalue(k1);
  end;
//  addstructvalue([pointertype,pointertype]); //method, bittypemax+1
  addbytevalue(2*targetpointersize); //method, bittypemax+1
  fmetadata:= addbitvalue(das_meta);
  fclassdef:= addbytevalue(sizeof(classdefheaderty));
  fopenarray:= addbytevalue(sizeof(openarrayty));
  fintfitem:= addstructvalue([inttype,pointertype]);
  flandingpad:= addstructvalue([pointertype,inttype]);
  fsimplesub:= addsubvalue([],simpleprocparams);
  fpointerproc:= addsubvalue([],pointerprocparams);
  fvoid:= 0;
{
  t1.header.size:= -1;
  t1.header.data:= pointer(ptrint(-1)); //nil;
//  t1.header.data:= pointer(ptrint(0)); //nil;
  t1.kind:= das_none;
  fvoid:= addvalue(t1)^.data.header.listindex;
}
{
  params1.count:= 0;
  params1.items:= nil;
  fsimplesub:= addsubvalue([],params1);
}
 end;
 {
 t1.header.size:= -1;
 t1.header.data:= nil;
 t1.kind:= das_none;
 addvalue(t1);        //void
 }
end;

function ttypehashdatalist.addvalue(
                 var avalue: typeallocdataty): ptypelisthashdataty; inline;
begin
 if addunique(bufferallocdataty((@avalue)^),pointer(result)) then begin
  result^.data.kind:= avalue.kind;
 end;
end;

function ttypehashdatalist.addbitvalue(const asize: databitsizety): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= -1;
 t1.header.data:= pointer(ptruint(bitopsizes[asize]));
 t1.kind:= asize;
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addbytevalue(const asize: integer): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= -1;
 t1.header.data:= pointer(ptruint(asize));
 t1.kind:= das_none;
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addpointerarrayvalue(const asize: int32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= -1;
 t1.header.data:= pointer(ptruint(asize));
 t1.kind:= databitsizety(-(ord(ak_pointerarray)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addaggregatearrayvalue(const asize: int32;
                                                  const atype: int32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
 info1: aggregatearraytypedataty;
begin
 info1.size:= asize;
 info1.typ:= atype;
 t1.header.size:= sizeof(info1);
 t1.header.data:= @info1;
 t1.kind:= databitsizety(-(ord(ak_aggregatearray)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addstructvalue(
              const atypes: array of int32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= length(atypes)*sizeof(int32);
 t1.header.data:= @atypes[0];
 t1.kind:= databitsizety(-(ord(ak_struct)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addstructvalue(const asize: int32;
                                               const atypes: pint32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= asize*sizeof(int32);
 t1.header.data:= atypes;
 t1.kind:= databitsizety(-(ord(ak_struct)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;


type
 subtypebufferty = record
  header: subtypeheaderty;
  params: array[0..maxparamcount-1] of paramitemty;
 end;

function ttypehashdatalist.addsubvalue(const avalue: psubdataty): integer;

var
 alloc1: typeallocdataty;
 po1: ptypelisthashdataty;
 parbuf: subtypebufferty;
 po2: pelementoffsetty;
 i1: int32;
 var1: pvardataty;
begin
 if avalue = nil then begin //main()
  with parbuf do begin
   header.flags:= [sf_functionx,sf_functioncall];
   header.paramcount:= 1;
   with params[0] do begin
    flags:= [];
    typelistindex:= ord(das_32);
   end;
  end;
 end
 else begin
  with parbuf do begin
   header.flags:= avalue^.flags;
   header.paramcount:= avalue^.paramcount;
   if sf_vararg in header.flags then begin
    dec(header.paramcount);
   end;
   i1:= avalue^.allocs.nestedalloccount+1; 
            //first item is possible pointer to outer frame
   if i1 > 1 then begin
    avalue^.allocs.nestedallocstypeindex:= addbytevalue(i1*targetpointersize);
   end
   else begin
    avalue^.allocs.nestedallocstypeindex:= -1;
   end;
   if header.paramcount > maxparamcount-1 then begin 
                                    //1 reserve for nestedacces
    header.paramcount:= 0;
    errormessage(err_toomanyparams,[]);
   end;
   po2:= @avalue^.paramsrel;
   i1:= 0; 
   if sf_functioncall in header.flags then begin
    with params[0] do begin
     flags:= [];
     typelistindex:= addvarvalue(ele.eledataabs(po2^));
    end;
    inc(i1);
    inc(po2);
   end;
   if sf_hasnestedaccess in header.flags then begin
                   //array of pointer for pointer to nested vars
    with parbuf.params[i1] do begin
     flags:= [];
     typelistindex:= ord(das_pointer);
    end;
    inc(i1);
    inc(header.paramcount);
   end;
   for i1:= i1 to header.paramcount - 1 do begin
    with params[i1] do begin
     flags:= [];
     var1:= ele.eledataabs(po2^);
     {
     if af_vararg in var1^.address.flags then begin
      include(flags,pif_vararg);
     end
     else begin
     }
      typelistindex:= addvarvalue(var1);
//     end;
    end;
    inc(po2);
   end;
  end;
 end;
 alloc1.kind:= das_sub;
 alloc1.header.size:= sizeof(subtypeheaderty) + 
             parbuf.header.paramcount * sizeof(paramitemty);
 alloc1.header.data:= @parbuf;
 result:= addvalue(alloc1)^.data.header.listindex;
end;

function ttypehashdatalist.addsubvalue(const aflags: subflagsty; 
                                             const aparams: paramsty): int32;
var
 alloc1: typeallocdataty;
 po1: ptypelisthashdataty;
 parbuf: subtypebufferty;
 i1,i2: int32;
begin
 with parbuf do begin
  header.flags:= aflags;
  header.paramcount:= aparams.count;
  for i1:= 0 to aparams.count - 1 do begin
   params[i1]:= aparams.items[i1];
  end;
 end;
 alloc1.kind:= das_sub;
 alloc1.header.size:= sizeof(subtypeheaderty) + 
             aparams.count * sizeof(paramitemty);
 alloc1.header.data:= @parbuf;
 result:= addvalue(alloc1)^.data.header.listindex;
end;

function ttypehashdatalist.addtypevalue(const atype: ptypedataty): integer;
begin
 if (atype^.h.indirectlevel > 0) then begin
  result:= pointertype;
 end
 else begin
  if atype^.h.datasize = das_none then begin
   result:= addbytevalue(atype^.h.bytesize);
  end
  else begin
   result:= addbitvalue(atype^.h.datasize);
  end;
 end;
end;

function ttypehashdatalist.addvarvalue(const avalue: pvardataty): integer;
var
 po1: ptypedataty;
begin 
 po1:= ele.eledataabs(avalue^.vf.typ);
 if (af_paramindirect in avalue^.address.flags) or 
      (po1^.h.indirectlevel+avalue^.address.indirectlevel > 0) then begin
  result:= pointertype;
 end
 else begin
  result:= addtypevalue(po1);
 {
  if po1^.h.datasize = das_none then begin
   result:= addbytevalue(po1^.h.bytesize);
  end
  else begin
   result:= addbitvalue(po1^.h.datasize);
  end;
 }
 end;
end;

function ttypehashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= inherited hashkey(akey) xor 
               scramble(ord(typeallocdataty(akey).kind));
end;

function ttypehashdatalist.checkkey(const akey;
                                 const aitem: phashdataty): boolean;
begin
 result:= (typeallocdataty(akey).kind = 
                ptypelisthashdataty(aitem)^.data.kind) and
                                        inherited checkkey(akey,aitem);
end;

function ttypehashdatalist.first: ptypelistdataty;
begin
 result:= @ptypelisthashdataty(internalfirstx())^.data;;
end;

function ttypehashdatalist.next: ptypelistdataty;
begin
 result:= @ptypelisthashdataty(internalnextx())^.data;
end;

{ tconsthashdatalist }

constructor tconsthashdatalist.create(const atypelist: ttypehashdatalist);

begin
 ftypelist:= atypelist;
// fgloblist:= agloblist; //set by tllvmlists
 inherited create();
// inherited create(sizeof(constlisthashdataty)-sizeof(bufferhashdataty));
// inherited create(sizeof(constallocdataty));
// clear(); //create default entries
end;

function tconsthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(constlisthashdataty);
end;

procedure tconsthashdatalist.clear;
var
 c1: card8;
 po1: pconstlisthashdataty;
 alloc1: constallocdataty;
 i1: int32;
begin
 inherited;
 if not (hls_destroying in fstate) then begin
  for c1:= low(c1) to high(c1) do begin
   addi8(int8(c1));                   //0..127,-128..-1
  end;
  for i1:= 0 to maxpointeroffset do begin
   addi32(i1*globtypes.targetpointersize);
  end;
  addnullvalue(ord(das_1));         //nco_i1
  addnullvalue(ord(das_8));         //nco_i8
  addnullvalue(ord(das_16));        //nco_i16
  addnullvalue(ord(das_32));        //nco_i32
  addnullvalue(ord(das_64));        //nco_i64
  addnullvalue(ord(das_f32));       //nco_f32
  addnullvalue(ord(das_f64));       //nco_f64
  addnullvalue(ord(das_pointer));   //nco_pointer
  addnullvalue(methodtype);         //nco_method
  addi1(true); //mc_i1                   
  addi8(-1);   //mc_i8
  addi16(-1);  //mc_i16
  addi32(-1);  //mc_i32
  addi64(-1);  //mc_i64
  addi1(true); //oc_i1
  addi8(1);    //oc_i8
  addi16(1);   //oc_i16
  addi32(1);   //oc_i32
  addi64(1);   //oc_i64
  addf32(1);   //oc_f32
  addf64(1);   //oc_f64
//  addi1(false);//asco_i1
//  addi8(7);    //asco_i8
  addi16(15);  //asco_i16
  addi32(31);  //asco_i32
  addi64(65);  //asco_i64
  if target64 then begin
   fpointersize:= addi64(globtypes.targetpointersize).listid;
   fvarrectysize:= addi32(sizeof(varrecty64)).listid;
  end
  else begin
   fvarrectysize:= addi32(sizeof(varrecty32)).listid;
   fpointersize:= addi32(globtypes.targetpointersize).listid;
  end;
 end;
end;

function tconsthashdatalist.pointeroffset(const aindex: int32): int32;
begin
 if aindex <= maxpointeroffset then begin
  result:= high(card8)+1+aindex
 end
 else begin
  result:= addi32(aindex*pointersize).listid;
  if result = count-1 then begin
   internalerror1(ie_llvmlist,'20150225');
  end;
 end;
end;

function tconsthashdatalist.i8(const avalue: int8): int32;
begin
 result:= card8(avalue);
end;

function tconsthashdatalist.i8const(const avalue: int8): llvmvaluety;
begin
 result.listid:= card8(avalue);
 result.typeid:= ord(das_8);
end;

function tconsthashdatalist.nilpointer(): llvmvaluety;
begin
 result.listid:= ord(nco_pointer);
 result.typeid:= ord(das_pointer);
end;

function tconsthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= inherited hashkey(akey) xor scramble(constallocdataty(akey).typeid);
end;

function tconsthashdatalist.checkkey(const akey;
                                         const aitem: phashdataty): boolean;
begin
 result:= (pconstlisthashdataty(aitem)^.data.typeid = 
                           constallocdataty(akey).typeid) and 
                                    inherited checkkey(akey,aitem);
end;

function tconsthashdatalist.addi1(const avalue: boolean): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 if avalue then begin
  alloc1.header.data:= pointer(ptruint(-1));
 end
 else begin
  alloc1.header.data:= pointer(ptruint(0));
 end;
 alloc1.typeid:= ord(das_1);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi8(const avalue: int8): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_8);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi16(const avalue: int16): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_16);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi32(const avalue: int32): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_32);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi64(const avalue: int64): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
{$ifdef cpu64}
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_64);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
{$else}
 alloc1.header.size:= 8;
 alloc1.header.data:= @avalue;
 alloc1.typeid:= ord(das_64);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
// result:= addvalue(avalue,8);
{$endif}
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addipo(const avalue: int64): llvmvaluety;
begin
 if info.target64bit then begin
  result:= addi64(avalue);
 end
 else begin
  result:= addi32(avalue);
 end;
end;

function tconsthashdatalist.addf32(const avalue: flo32): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= ppointer(@avalue)^;
 alloc1.typeid:= ord(das_f32);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addf64(const avalue: flo64): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
{$ifdef cpu64}
 alloc1.header.size:= -1;
 alloc1.header.data:= ppointer(@avalue)^;
 alloc1.typeid:= ord(das_f64);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
{$else}
 alloc1.header.size:= 8;
 alloc1.header.data:= @avalue;
 alloc1.typeid:= ord(das_f64);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
// result:= addvalue(avalue,8);
{$endif}
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.adddataoffs(const avalue: dataoffsty): llvmvaluety;
begin
 if info.target64bit then begin
  result:= addi64(avalue);
 end
 else begin
  result:= addi32(avalue);
 end;
end;

function tconsthashdatalist.addvalue(const avalue;
                                            const asize: int32): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= asize;
 alloc1.header.data:= @avalue;
 alloc1.typeid:= ftypelist.addbytevalue(asize);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addvalue(const avalue: segaddressty;
                              const asize: int32): llvmvaluety;
begin
 result:= addvalue(getsegmentpo(avalue)^,asize);
end;

function tconsthashdatalist.addnullvalue(const atypeid: int32): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptrint(atypeid));
 alloc1.typeid:= -ord(ct_null);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.header.buffer;
end;

function tconsthashdatalist.addpointercast(const aid: int32): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 if aid < 0 then begin
  result:= addnullvalue(ord(das_pointer));
 end
 else begin
 {$ifdef mse_checkinternalerror}
  if aid >= info.s.unitinfo^.llvmlists.globlist.count then begin
   internalerror(ie_llvmlist,'20180702A');
  end;
 {$endif}
  alloc1.header.size:= -1;
  alloc1.header.data:= pointer(ptrint(aid));
  alloc1.typeid:= -ord(ct_pointercast);
  if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
   po1^.data.typeid:= alloc1.typeid;
  end;
  result.listid:= po1^.data.header.listindex;
  result.typeid:= pointertype;
 end;
end;

function tconsthashdatalist.addaddress(const aid: int32;
               const aoffset: int32): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
 ac1: addressconstty;
begin
 result:= addpointercast(aid);
 if aoffset <> 0 then begin
  ac1.addressid:= result.listid;
  ac1.offsetid:= addi32(aoffset).listid;
  alloc1.header.size:= sizeof(ac1);
  alloc1.header.data:= @ac1;
  alloc1.typeid:= -ord(ct_address);
  if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
   po1^.data.typeid:= alloc1.typeid;
  end;
  result.listid:= po1^.data.header.listindex;
//  result.typeid:= po1^.data.typeid;
 end;
end;

function tconsthashdatalist.addpointerarray(const alength: int32;
                                              const ids: pint32;
                                 const unique: boolean = true): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
 i1: int32;
 b1: boolean;
begin
 alloc1.header.size:= (alength+1)*sizeof(int32);
 alloc1.header.data:= ids;
 i1:= ids[alength]; //backup
 ids[alength]:= ftypelist.addpointerarrayvalue(alength);
 alloc1.typeid:= -ord(ct_pointerarray);
 if unique then begin
  b1:= addunique(bufferallocdataty((@alloc1)^),pointer(po1));
 end
 else begin
  addnotunique(bufferallocdataty((@alloc1)^),pointer(po1));
  b1:= true;
 end;
 if b1 then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= ids[alength];
 ids[alength]:= i1; //restore
end;

function tconsthashdatalist.addaggregatearray(const asize: int32;
                           const atype: int32; const ids: pint32): llvmvaluety;
                                     //ids[asize] used for type id
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= (asize+1)*sizeof(int32);
 alloc1.header.data:= ids;
 ids[asize]:= ftypelist.addaggregatearrayvalue(asize,atype);
 alloc1.typeid:= -ord(ct_aggregatearray);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= ids[asize];
end;

function tconsthashdatalist.addaggregate(const avalue: paggregateconstty; 
                                   const unique: boolean = true): llvmvaluety;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
 b1: boolean;
begin
 alloc1.header.size:= sizeof(avalue^)+avalue^.header.itemcount*sizeof(int32);
 alloc1.header.data:= avalue;
 alloc1.typeid:= -ord(ct_aggregate);
 if unique then begin
  b1:= addunique(bufferallocdataty((@alloc1)^),pointer(po1));
 end
 else begin
  addnotunique(bufferallocdataty((@alloc1)^),pointer(po1));
  b1:= true;
 end;
 if b1 then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= avalue^.header.typeid;
end;

procedure initagloc(var agloc: aglocty; const count: int32);
begin
 with agloc do begin
  if count > length(aglocty.items) then begin
   ag:= getmem(sizeof(agloc.header)+count*sizeof(int32));
   ty:= getmem(count*sizeof(int32));
  end
  else begin
   ag:= @agloc.header;
   ty:= @agloc.types;
  end;
  li:= @ag^.items;
  ty1:= ty;
  li1:= li;
  ag^.header.itemcount:= count;
 end;
end;

procedure putagitem(var agloc: aglocty; const avalue: llvmvaluety);
begin
 with agloc do begin
  ty1^:= avalue.typeid;
  li1^:= avalue.listid;
  inc(ty1);
  inc(li1);
 end;
end;

procedure putagpointer(var agloc: aglocty; const constid: int32);
var
 m1: llvmvaluety;
begin
 m1.listid:= constid;
 m1.typeid:= ord(das_pointer);
 putagitem(agloc,m1);
end;

procedure putagsub(var agloc: aglocty; const avalue: opaddressty);
var
 pop1: popinfoty;
begin
 if avalue = 0 then begin
  putagitem(agloc,info.s.unitinfo^.llvmlists.constlist.nilpointer);
 end
 else begin
  pop1:= getoppo(avalue);
 {$ifdef mse_checkinternalerror}
  if pop1^.op.op <> oc_subbegin then begin
   internalerror(ie_llvmlist,'20171116A');
  end;
 {$endif}
  putagitem(agloc,info.s.unitinfo^.llvmlists.constlist.
                                addpointercast(pop1^.par.subbegin.globid));
 end;
end;

procedure freeagloc(const agloc: aglocty);
begin
 if (agloc.ag <> nil) and (agloc.ag <> @agloc.header) then begin
  freemem(agloc.ag);
  freemem(agloc.ty);
 end;
end;

function tconsthashdatalist.addagloc(const agloc: aglocty): llvmvaluety;
var
 p0,p1,pe: pint32;
begin
 agloc.ag^.header.typeid:= typelist.addstructvalue(
                                  agloc.ag^.header.itemcount,agloc.ty);
 result:= addaggregate(agloc.ag);
 p1:= @agloc.ag^.items;
 p0:= p1;
 pe:= p1 + agloc.ag^.header.itemcount;
 while p1 < pe do begin
  if p1^ < 0 then begin
   linksetconstref(-p1^,result.listid,p1-p0);
  end;
  inc(p1);
 end;
 freeagloc(agloc);
end;

function tconsthashdatalist.addtypedconst(const atype: elementoffsetty;
                                         var adata: pointer): llvmvaluety;
                        //todo: alignment
var
 agloc1: aglocty;
 typ1: ptypedataty;
 ele1: elementoffsetty;
 field1: pfielddataty;
 p1: pointer;
 m1: llvmvaluety; 
begin
 typ1:= ele.eledataabs(basetype(atype));
{$ifdef mse_checkinternalerror}
 if datatoele(typ1)^.header.kind <> ek_type then begin
  internalerror(ie_parser,'20171106B');
 end;
{$endif}
 if (typ1^.h.indirectlevel > 0) then begin
  result:= addpointercast(ptargetptrintty(adata)^);
  inc(adata,sizeof(targetptrintty));
 end
 else begin
  case typ1^.h.kind of
   dk_integer,dk_cardinal: begin
    case typ1^.h.datasize of
     das_8: begin
      result:= addi8(pint8(adata)^);
     end;
     das_16: begin
      result:= addi16(pint16(adata)^);
     end;
     das_32: begin
      result:= addi32(pint32(adata)^);
     end;
     das_64: begin
      result:= addi64(pint64(adata)^);
     end;
     else begin
      internalerror1(ie_parser,'20171106D');
     end;
    end;
   end;
   dk_string: begin
    result:= addaddress(ptargetptrintty(adata)^,sizeof(stringheaderty));
    inc(adata,sizeof(targetptrintty));
   end;
   dk_dynarray: begin
    result:= addaddress(ptargetptrintty(adata)^,sizeof(dynarrayheaderty));
    inc(adata,sizeof(targetptrintty));
   end;
   dk_record: begin
    initagloc(agloc1,typ1^.fieldcount);
    ele1:= typ1^.fieldchain;
    while ele1 > 0 do begin
     field1:= ele.eledataabs(ele1);
     p1:= adata + field1^.offset;
     if field1^.indirectlevel > 0 then begin
      putagitem(agloc1,addpointercast(ptargetptrintty(p1)^));
     end
     else begin
      putagitem(agloc1,addtypedconst(field1^.vf.typ,p1));
     end;
     ele1:= field1^.vf.next;
    end;
    result:= addagloc(agloc1);
   end;
   else begin
    internalerror1(ie_parser,'20171106C');
   end;
  end;
  inc(adata,typ1^.h.bytesize);
 end;
end;
(*
function tconsthashdatalist.addrtti(const artti: pcrttity): llvmvaluety;
var
 agloc1: aglocty;
// ag1: paggregateconstty;
// pi1: pint32; //items
 
 procedure initmainagloc(const count: int32);
 begin
  initagloc(agloc1,count+2);
  putagitem(agloc1,addi32(artti^.size));      //1
  putagitem(agloc1,addi32(ord(artti^.kind))); //2
 end;
 
var
 p1,pe: pointer;
begin
// ag1:= nil;
 case artti^.kind of
  rtk_enum: begin
   with pcenumrttity(artti)^ do begin
    initmainagloc(itemcount+2);
    putagitem(agloc1,addi32(itemcount));
    putagitem(agloc1,addi32(int32(flags)));
    p1:= @items;
    pe:= pcenumitemrttity(p1)+itemcount;
    while p1 < pe do begin
     putagitem(agloc1,addtypedconst(internaltypes[it_enumitemrtti],p1));
//     inc(pi1);
//     inc(pcenumitemrttity(p1));
    end;
    result:= addagloc(agloc1);
   end;
  end
  else begin
   internalerror(ie_llvm,'20171105A');
  end;
 end;
end;
*)

function tconsthashdatalist.addclassdef(const aclassdef: classdefpoty;
                                          const aintfcount: int32): llvmvaluety;

 function getrttiid(const asegoffset: int32): int32;
 begin
  result:= pint32(getsegmentpo(seg_rtti,asegoffset))^;
 end; //getrttiid()

type
 classdefty = record
  header: aggregateconstty;                       
  //0           1               2             3
  //parentclass,interfaceparent,virttaboffset,rtti,
  //4..4+high(procs)
  //procs iniproc,
  //                optional        optional
  //4+high(procs)+1 4+high(procs)+2 4+high(procs)+3
  //allocs,         virtualmethods, interfaces
  items: array[0..7+ord(high(classdefprocty))] of int32; //constlist ids
 end;

var
 pd,pe: pint32;
 
 co1: llvmvaluety;
 
 classdef1: classdefty;
 types1: array[0..high(classdefty.items)] of int32;
 i1,i2: int32;
 ps1,ps,pe1: popaddressty;
 po1: pointer;
 pop1: popinfoty;
 proc1: classdefprocty;
 typ1: ptypedataty;
 sub1: psubdataty;
 ele1: elementoffsetty;
begin
 typ1:= ele.eledataabs((pclassdefconstheaderty(aclassdef)-1)^.typedata);
 types1[0]:= pointertype;
 types1[1]:= pointertype;
 if aclassdef^.header.parentclass = -1 then begin
  classdef1.items[0]:= nullpointer;
  classdef1.items[1]:= nullpointer;
 end
 else begin
  classdef1.items[0]:= addpointercast(
                          getclassid(aclassdef^.header.parentclass)).listid;
  if aclassdef^.header.interfaceparent = -1 then begin
   classdef1.items[1]:= nullpointer;
  end
  else begin
   classdef1.items[1]:= addpointercast(
                    getclassid(aclassdef^.header.interfaceparent)).listid;
  end;
 end;
 types1[2]:= ord(das_32);
 classdef1.items[2]:= addi32(aclassdef^.header.virttaboffset).listid;
 types1[3]:= ord(das_pointer);
 if aclassdef^.header.rtti < 0 then begin
  classdef1.items[3]:= nullpointer;
 end
 else begin
  classdef1.items[3]:= aclassdef^.header.rtti;
 end;
 
 i2:= 4;
 for proc1:= low(proc1) to high(proc1) do begin
  types1[i2]:= pointertype;
//  if aclassdef^.header.procs[proc1] <= 0 then begin
//   classdef1.items[i2]:= nullpointer;
//  end
//  else begin
  i1:= aclassdef^.header.procs[proc1];
  if i1 > 0 then begin //opcode in current module, globid otherwise
   pop1:= getoppo(i1);
  {$ifdef mse_checkinternalerror}
   if pop1^.op.op <> oc_subbegin then begin
    internalerror(ie_llvmlist,'20170721A');
   end;
  {$endif}
   i1:= pop1^.par.subbegin.globid;
  end
  else begin //globid or nil
   i1:= -i1 - 1;
  end;
  classdef1.items[i2]:= addpointercast(i1).listid;
(*
   pop1:= getoppo(aclassdef^.header.procs[proc1]);
  {$ifdef mse_checkinternalerror}
   if pop1^.op.op <> oc_subbegin then begin
    internalerror(ie_llvmlist,'20170721A');
   end;
  {$endif}
   classdef1.items[i2]:= addpointercast(pop1^.par.subbegin.globid).listid;
*)
//  end;
  inc(i2);
 end;
 co1:= addvalue(aclassdef^.header.allocs,sizeof(aclassdef^.header.allocs));
 types1[i2]:= co1.typeid;             
 classdef1.items[i2]:= co1.listid;
 inc(i2);
 
 pd:= @aclassdef^.virtualmethods;
 pe:= pd+typ1^.infoclass.virtualcount;
 i1:= pe - pd;
 if i1 > 0 then begin
  while pd < pe do begin
   pd^:= nullpointer;
   inc(pd);
  end;
{
  while ps < pe do begin
   pd^:= addpointercast(ps^).listid;
   inc(pd);
   inc(ps);
  end;
}
  co1:= addpointerarray(i1,@aclassdef^.virtualmethods,false);
  types1[i2]:= co1.typeid;
  classdef1.items[i2]:= co1.listid;
  inc(i2);
 end;
 if aintfcount > 0 then begin
  po1:= getsegmentbase(seg_intf);
  ps:= @aclassdef^.virtualmethods;
  inc(ps,typ1^.infoclass.virtualcount);
  pd:= pointer(ps);
  ps1:= ps;
  pe1:= ps+aintfcount;
  while ps < pe1 do begin
   pd^:= addpointercast(pint32(po1+ps^)^).listid;
   inc(pd);
   inc(ps);
  end;
  co1:= addpointerarray(aintfcount,pointer(ps1));
  classdef1.items[i2]:= co1.listid;
  types1[i2]:= co1.typeid;
  inc(i2);
 end;
 classdef1.header.header.itemcount:= i2;
 classdef1.header.header.typeid:= ftypelist.addstructvalue(
                                  classdef1.header.header.itemcount,@types1);
 result:= addaggregate(@classdef1,false);
end;

function tconsthashdatalist.addintfdef(const aintf: pintfdefinfoty;
               const acount: int32): llvmvaluety;
                //overwrites aintf data
var
 intfpo,intfe: popaddressty;
 oppo: popinfoty;
 pi1: pint32;
 agg1: record
  header: aggregateconstheaderty;
  offs: int32;
  items: int32;
 end;
 co1,offs1: llvmvaluety;
begin
 offs1:= addi32(aintf^.header.instanceoffset);
 intfpo:= @aintf^.items;
 intfe:= intfpo+acount;
 pi1:= pointer(aintf);
 while intfpo < intfe do begin
  oppo:= getoppo(intfpo^+1);
 {$ifdef mse_checkinternalerror}
  if not ((oppo^.op.op = oc_subbegin) or
                             (oppo^.op.op = oc_virttrampoline)) then begin
   internalerror(ie_llvm,'20150404A');
  end;
 {$endif}
  pi1^:= addpointercast(oppo^.par.subbegin.globid).listid;
  inc(pi1);
  inc(intfpo);  
 end;
 co1:= addpointerarray(acount,pint32(aintf));
 agg1.header.itemcount:= 2;
 agg1.header.typeid:= ftypelist.addstructvalue([offs1.typeid,co1.typeid]);
 agg1.offs:= offs1.listid;
 agg1.items:= co1.listid;
 result:= addaggregate(@agg1);
end;

function tconsthashdatalist.first: pconstlisthashdataty;
begin
 result:= pconstlisthashdataty(internalfirstx());
end;

function tconsthashdatalist.next: pconstlisthashdataty;
begin
 result:= pconstlisthashdataty(internalnextx());
end;

function tconsthashdatalist.gettype(const aindex: int32): int32;
begin
{$ifdef mse_checkintrnalerror}
 if (aindex < 0) or (aindex >= fcount - 2) then begin
  internalerror(ie_llvmlist,'20151117A');
 end;
{$endif}
 result:= pconstlisthashdataty(fdata)[aindex+1].data.typeid;
end;

{ tglobnamelist }

constructor tglobnamelist.create;
begin
 inherited create(sizeof(globnamedataty));
end;

procedure tglobnamelist.addname(const aname: identnamety;
               const alistindex: integer);
begin
 inccount();
 with (pglobnamedataty(fdata)+fcount-1)^ do begin
  name:= aname;
  listindex:= alistindex;
 end;
end;

procedure tglobnamelist.addname(const aunit: pointer; //punitinfoty
                             const adestindex: int32; const alistindex: int32);
begin
 inccount();
 with (pglobnamedataty(fdata)+fcount-1)^ do begin
  nameunit.po:= aunit;
  nameunit.destindex:= -adestindex;
  listindex:= alistindex;
 end;
end;

{ tgloballocdatalist }

constructor tgloballocdatalist.create(const atypelist: ttypehashdatalist;
                                       const aconstlist: tconsthashdatalist);
begin
 ftypelist:= atypelist;
 fconstlist:= aconstlist;
 fnamelist:= tglobnamelist.create;
 flinklist:= tlinklist.create;
 inherited create(sizeof(globallocdataty));
end;

destructor tgloballocdatalist.destroy();
begin
 fdestroying:= true;
 inherited;
 fnamelist.free();
 flinklist.free();
end;

procedure tgloballocdatalist.clear;
begin
 inherited;
 fnamelist.clear();
{
       //"token" and llvm.eh.padparam.pNi8 seem not to work with llvm 3.8
 if not fdestroying then begin
  fgetexceptionpointer:= addexternalsubvalue(true,
                 [ord(das_pointer),ftypelist.landingpad],
                              getidentname('llvm.eh.padparam.pNi8'));
 end;
}
end;

procedure tgloballocdatalist.inccount();
begin
 count:= fcount+1;
 flastitem:= pgloballocdataty(fdata)+count-1;
end;

function tgloballocdatalist.addnoinit(const atyp: int32;
                const alinkage: linkagety;
                const externunit: boolean): int32;
var
 dat1: globallocdataty;
begin
 fillchar(dat1,sizeof(dat1),0);
 dat1.typeindex:= atyp;
 dat1.linkage:= alinkage;
 dat1.kind:= gak_var;
 result:= fcount;
 if externunit then begin
  dat1.initconstindex:= -1;
 end
 else begin
  dat1.initconstindex:= fconstlist.addnullvalue(atyp).listid;
  if alinkage = li_external then begin
//   inc(info.s.unitinfo^.nameid);
   fnamelist.addname(info.s.unitinfo,getunitnameid(),result);
  end;
 end;
 inccount();
 flastitem^:= dat1;
end;

function tgloballocdatalist.addvalue(const avalue: pvardataty;
                              const alinkage: linkagety;
                              const externunit: boolean): int32;
begin
 result:= addnoinit(ftypelist.addvarvalue(avalue),alinkage,externunit);
 if externunit then begin
  fnamelist.addname(datatoele(avalue)^.header.defunit,avalue^.nameid,result);
  flinklist.addlink(avalue,result);
 end;
end;

function tgloballocdatalist.addexternalvalue(
                     const avalue: pointer{pelementinfoty};
                                const anameid: int32; const atype: int32;
                                             const alinkage: linkagety): int32;
begin
 result:= addnoinit(atype,alinkage,true);
 fnamelist.addname(pelementinfoty(avalue)^.header.defunit,anameid,result);
 flinklist.addlink(pelementinfoty(avalue)^.header.defunit,anameid,result);
end;

function tgloballocdatalist.addalias(const aliasee: int32;
               const name: identty): int32;
begin
 result:= fcount;
 inccount();
 with flastitem^ do begin;
  typeindex:= pgloballocdataty(getitempo(aliasee))^.typeindex;
  initconstindex:= aliasee;
  linkage:= li_external;
  debuginfo:= dummymeta;
  kind:= gak_alias;
 end;
end;

function tgloballocdatalist.addbytevalue(const asize: integer; 
                                       const alinkage: linkagety; 
                                     const externunit: boolean): int32;
begin 
 result:= addnoinit(ftypelist.addbytevalue(asize),alinkage,externunit);
end;

function tgloballocdatalist.addexternalvalue(const aname: identty;
               const atype: int32): int32;
begin
 result:= addnoinit(atype,li_external,true);
 namelist.addname(getidentname2(aname),result);
end;

function tgloballocdatalist.addbitvalue(const asize: databitsizety; 
                                       const alinkage: linkagety;
                                       const externunit: boolean): int32;
begin 
 result:= addnoinit(ftypelist.addbitvalue(asize),alinkage,externunit);
end;

function tgloballocdatalist.addinitvalue(const akind: globallockindty;
              const aconstlistindex: integer; const alinkage: linkagety;
                               const nameid: int32 = -1): int32;
var
 dat1: globallocdataty;
 po1: pconstlisthashdataty;
 po2: pint32;
 i1: int32;
begin
 fillchar(dat1,sizeof(dat1),0);
 po1:= pconstlisthashdataty(fconstlist.fdata)+aconstlistindex+1;
 if po1^.data.typeid < 0 then begin
  case consttypety(-po1^.data.typeid) of
   ct_null: begin       
    dat1.typeindex:= int32(po1^.data.header.buffer);
   end;
   ct_pointercast,ct_address: begin
    dat1.typeindex:= pointertype;
   end;
   ct_pointerarray,ct_aggregatearray: begin
    dat1.typeindex:= pint32(fconstlist.absdata(po1^.data.header.buffer))
                           [po1^.data.header.buffersize div sizeof(int32) - 1];
                                       //last item is type
   end;
   ct_aggregate: begin
    dat1.typeindex:= paggregateconstty(
                 fconstlist.absdata(po1^.data.header.buffer))^.header.typeid;
   end;
   else begin
    internalerror1(ie_bcwriter,'20150328C');
   end;
  end;
 end
 else begin
  dat1.typeindex:= po1^.data.typeid;
 end;
 dat1.kind:= akind;
 dat1.initconstindex:= aconstlistindex; 
 dat1.linkage:= alinkage;
 result:= fcount;
 inccount();
 flastitem^:= dat1;
 if alinkage = li_external then begin
  if nameid >= 0 then begin
   i1:= nameid;
  end
  else begin
   i1:= getunitnameid();
  end;
  fnamelist.addname(info.s.unitinfo,i1,result);
 end;
end;

function tgloballocdatalist.addsubvalue(const avalue: psubdataty;
                                  const externunit: boolean): int32;
var
 dat1: globallocdataty;
 i1: int32;
begin
 result:= fcount;
 if avalue <> nil then begin
  with avalue^ do begin
   if externunit then begin
    dat1.flags:= flags+[sf_proto];
    dat1.linkage:= li_external;
    if flags * [sf_external,sf_proto] = [sf_external,sf_proto] then begin
     i1:= funcname;
     if i1 = 0 then begin
      i1:= datatoele(avalue)^.header.name;
     end;
     fnamelist.addname(getidentname2(i1),result);
    end
    else begin
     fnamelist.addname(datatoele(avalue)^.header.defunit,nameid,result);
    end;
    flinklist.addlink(avalue,result);
   end
   else begin
    if sf_named in flags then begin
     fnamelist.addname(datatoele(avalue)^.header.defunit,nameid,result);
    end;
    dat1.flags:= flags;
    dat1.linkage:= linkage;
   end;
   if sf_proto in dat1.flags then begin
    dat1.typeindex:= ftypelist.addsubvalue(avalue);
   end;
  end;
 end
 else begin //main
  dat1.typeindex:= ftypelist.addsubvalue(avalue);
  dat1.flags:= [sf_external];
  dat1.linkage:= li_external;
 end;
 dat1.kind:= gak_sub;
 dat1.initconstindex:= -1;
 inccount();
 flastitem^:= dat1;
end;

function tgloballocdatalist.addexternalsimplesub1({const aunit: pointer;
             const anameid: int32;} const aflags: internalsubflagsty): int32;
var
 dat1: globallocdataty;
begin
 result:= fcount;
 dat1.flags:= [sf_proto];
 dat1.linkage:= li_external;
 if isf_pointerpar in aflags then begin
  dat1.typeindex:= ftypelist.pointerproc;
 end
 else begin
  dat1.typeindex:= ftypelist.simplesub;
 end;
{
 fnamelist.addname(aunit,anameid,result);
 flinklist.addlink(anameid+punitinfoty(aunit)^.globidbasex,result);
}
 dat1.kind:= gak_sub;
 dat1.initconstindex:= -1;
 inccount();
 flastitem^:= dat1;
end;

function tgloballocdatalist.addexternalsimplesub(const aunit: pointer;
             const anameid: int32; const aflags: internalsubflagsty): int32;
begin
 result:= addexternalsimplesub1(aflags);
 fnamelist.addname(aunit,anameid,result);
 flinklist.addlink(aunit,anameid{+punitinfoty(aunit)^.globidbasex},result);
end;

function tgloballocdatalist.addexternalsimplesub(
                                const asub: pinternalsubdataty): int32;
begin
 result:= addexternalsimplesub1(asub^.flags);
 fnamelist.addname(datatoele(asub)^.header.defunit,asub^.nameid,result);
 flinklist.addlink(asub,result);
end;

function tgloballocdatalist.addexternalsimplesub(const aname: identty;
               const aflags: internalsubflagsty): int32;
begin
 result:= addexternalsimplesub1(aflags);
 fnamelist.addname(getidentname2(aname),result);
// flinklist.addlink(anameid+punitinfoty(aunit)^.globidbasex,result);
end;

procedure tgloballocdatalist.updatesubtype(const avalue: psubdataty);
var
 po1: psubtypeheaderty;
 i1: int32;
begin
 i1:= ftypelist.addsubvalue(avalue);
 with pgloballocdataty(fdata)[avalue^.globid] do begin
  typeindex:= i1;
 end;
 if avalue^.trampolineid >= 0 then begin
 with pgloballocdataty(fdata)[avalue^.trampolineid] do begin
  typeindex:= i1;
 end;
 end;
 with opcode.getoppo(avalue^.address)^ do begin
  par.subbegin.typeid:= i1;
  par.subbegin.sub.allocs:= avalue^.allocs;
 end;
end;

function tgloballocdatalist.addsubvalue(const avalue: psubdataty;
                                             const aname: identnamety): int32;
begin
 if avalue <> nil then begin //main() otherwise
  exclude(avalue^.flags,sf_named);
 end;
 result:= addsubvalue(avalue,false);
 fnamelist.addname(aname,result);
 if avalue <> nil then begin //main() otherwise
  include(avalue^.flags,sf_named);
 end;
end;

function tgloballocdatalist.addsubvalue(const aflags: subflagsty; 
                             const alinkage: linkagety; 
                             const aparams: paramsty): int32; 
                                                             //returns listid
begin
 result:= fcount;
 inccount();
 with flastitem^ do begin
  linkage:= alinkage;
  flags:= aflags;
  kind:= gak_sub;
  typeindex:= ftypelist.addsubvalue(aflags,aparams);
  initconstindex:= -1;
 end;
end;

function tgloballocdatalist.addinternalsubvalue(const aflags: subflagsty; 
                                              const aparams: paramsty): int32;
begin
 result:= addsubvalue(aflags,li_internal,aparams);
end;

function tgloballocdatalist.addexternalsubvalue(const aflags: subflagsty; 
                      const aparams: paramsty; const aname: identnamety): int32;
begin
 result:= addsubvalue(aflags,li_external,aparams);
 fnamelist.addname(aname,result);
end;

function tgloballocdatalist.addexternalsubvalue(const afunction : boolean;
           const aparamtypes: array of int32; const aname: identnamety): int32;
var
 params1: paramsty;
 parar1: array[0..15] of paramitemty;
 i1: int32;
 f1: subflagsty;
begin
{$ifdef mse_checkinternalerror}
 if high(aparamtypes) > high(parar1) then begin
  internalerror(ie_llvm,'20151108');
 end;
{$endif}
 params1.count:= length(aparamtypes);
 params1.items:= @parar1;
 for i1:= 0 to high(aparamtypes) do begin
  parar1[i1].flags:= [];
  parar1[i1].typelistindex:= aparamtypes[i1];
 end;
 if afunction then begin
  f1:= [sf_proto,sf_functionx,sf_functioncall];
 end
 else begin
  f1:= [sf_proto];
 end;
 result:= addexternalsubvalue(f1,params1,aname);
end;

function tgloballocdatalist.getinitconst(const alistid: int32): int32;
begin
 result:= (pgloballocdataty(fdata) + alistid)^.initconstindex;
end;

function tgloballocdatalist.gettype(const alistid: int32): int32;
begin
 result:= (pgloballocdataty(fdata) + alistid)^.typeindex;
end;

function tgloballocdatalist.gettype1(const alistid: int32): metavaluety;
begin
 result:= metavaluety((pgloballocdataty(fdata) + alistid)^.typeindex);
end;

function tgloballocdatalist.addidentconst(const aident: identty): llvmvaluety;
var
 buf1: record
  header: stringheaderty;
  data: array[0..maxidentlen+1] of byte;
 end;
 ls1: lstringty;
 m1: llvmvaluety;
 i1: int32;
begin
 with fconstlist do begin
  getidentname(aident,ls1);
  if ls1.len = 0 then begin
   result:= nilpointer();
  end
  else begin
   buf1.header.ref.count:= -1;
   buf1.header.len:= ls1.len;
   move(ls1.po^,buf1.data,ls1.len);
   buf1.data[ls1.len]:= 0;
   m1:= addvalue(buf1,sizeof(stringheaderty)+ls1.len+1);
   i1:= self.addinitvalue(gak_const,m1.listid,info.s.globlinkage);
   result:= addaddress(i1,sizeof(stringheaderty)); //string8 pointer
  end;
 end;
end;

procedure initlistagloc(const constlist: tconsthashdatalist;
                   var agloc: aglocty; const count: int32; const asize: int32);
begin
 initagloc(agloc,count+listrttifieldcount);
 with constlist do begin
   //size: int32;            //0
  putagitem(agloc,addi32(asize));
 end;
end;

const
 datakindtorttikind: array[datakindty] of rttikindty = (
//dk_none,  dk_pointer, dk_boolean, dk_cardinal, dk_integer, dk_float,
  rtk_none,rtk_pointer,rtk_boolean,rtk_cardinal,rtk_integer,rtk_float,
// dk_kind,
  rtk_none,   
// dk_address,dk_record,dk_string,
  rtk_none,  rtk_none, rtk_string,
// dk_dynarray,dk_openarray,dk_array,
  rtk_none,  rtk_none,    rtk_none,
// dk_object,dk_objectpo,dk_class,dk_interface,
  rtk_none, rtk_none,   rtk_none,rtk_none,
// dk_classof,
  rtk_none,
// dk_sub, dk_method,
  rtk_none,rtk_none,
// dk_enum, dk_enumitem, dk_set, dk_character,
  rtk_enum,rtk_enumitem,rtk_set,rtk_character,
// dk_data
  rtk_none
 );

 datasizetorttisize: array[databitsizety] of bitsizety = (
//das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
   bs_none, bs_1, bs_8,   bs_8,   bs_16, bs_16,    bs_32, bs_32,
//das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,
      bs_64, bs_64, bs_po,      bs_16,   bs_32, bs_64,
//das_sub,das_meta 
   bs_none,bs_none
 );
 
//todo: use single rtti instances in program
function tgloballocdatalist.addrtticonst(const atype: ptypedataty): llvmvaluety;
var
 agloc1: aglocty;
const
 datarttikinds = [rtk_integer,rtk_cardinal,rtk_enum,rtk_string]; 
 procedure initmainagloc(count: int32; const asize: int32;
                                                      const akind: rttikindty);
 var
  b1: boolean;
 begin
  b1:= akind in datarttikinds;
  if b1 then begin
   count:= count + datarttifieldcount;
  end;
  initagloc(agloc1,count+rttifieldcount);
  with fconstlist do begin
    //size: int32;            //0
   putagitem(agloc1,addi32(asize));
    //kind: rttikindty;       //1
   putagitem(agloc1,addi32(ord(akind)));
    //typename: string8;      //2
   putagitem(agloc1,self.addidentconst(datatoele(atype)^.header.name));
   if b1 then begin
    putagitem(agloc1,addi32(ord(datasizetorttisize[atype^.h.datasize]))); //0
   end;
  end;
 end; //initmainagloc()

 function checkpropertymethod(const sub: psubdataty; 
                                      var value: llvmvaluety): boolean;
 begin
  result:= false;
  if sub <> nil then begin
   if sub^.tableindex >= 0 then begin
    value:= fconstlist.addi32(sub^.tableindex);
   end
   else begin
    value:= fconstlist.addpointercast(trackaccess(sub));
    if sub^.globid < 0 then begin
     linkmarkllvmconst(sub^.calllinks,-1);  //dummy, updated in addagloc
     value.listid:= -sub^.calllinks;
    end;
   end;
   result:= true;
  end;
 end; //checkpropertymethod()
 
var
 p1,pe: pointer;
 enuflags1: enumrttiflagsty;
 ele1: elementoffsetty;
 i1,i2,i3: int32;
 m1: llvmvaluety;
 intmin1,intmax1: int64;
 cardmin1,cardmax1: card64;
 agloc2: aglocty;
 typ1: ptypedataty;
 b1,b2: boolean;
 link1: linkagety;
 propflags1: propertyflagsty;
 v1: llvmvaluety;
 readsub1,writesub1: psubdataty;
 stringkind1: stringkindty;

begin
 with fconstlist do begin
  case atype^.h.kind of
   dk_integer: begin
    case atype^.h.datasize of
     das_1,das_2_7,das_8: begin
      with atype^.infoint8 do begin
       intmin1:= min;
       intmax1:= max;
      end;
     end;
     das_9_15,das_16: begin
      with atype^.infoint16 do begin
       intmin1:= min;
       intmax1:= max;
      end;
     end;
     das_17_31,das_32: begin
      with atype^.infoint32 do begin
       intmin1:= min;
       intmax1:= max;
      end;
     end;
     das_33_63,das_64: begin
      with atype^.infoint64 do begin
       intmin1:= min;
       intmax1:= max;
      end;
     end;
    end;
    initmainagloc(4,sizeof(intrttity),rtk_integer);
    putagitem(agloc1,addi32(atype^.h.bytesize));                  //0
    putagitem(agloc1,addi32(atype^.h.bitsize));                   //1
    putagitem(agloc1,addi64(intmin1));                            //2
    putagitem(agloc1,addi64(intmax1));                            //3
   end;
   dk_cardinal: begin
    case atype^.h.datasize of
     das_1,das_2_7,das_8: begin
      with atype^.infocard8 do begin
       cardmin1:= min;
       cardmax1:= max;
      end;
     end;
     das_9_15,das_16: begin
      with atype^.infocard16 do begin
       cardmin1:= min;
       cardmax1:= max;
      end;
     end;
     das_17_31,das_32: begin
      with atype^.infocard32 do begin
       cardmin1:= min;
       cardmax1:= max;
      end;
     end;
     das_33_63,das_64: begin
      with atype^.infocard64 do begin
       cardmin1:= min;
       cardmax1:= max;
      end;
     end;
    end;
    initmainagloc(4,sizeof(intrttity),rtk_cardinal);
    putagitem(agloc1,addi32(atype^.h.bytesize));                   //0
    putagitem(agloc1,addi32(atype^.h.bitsize));                    //1
    putagitem(agloc1,addi64(cardmin1));                            //2
    putagitem(agloc1,addi64(cardmax1));                            //3
   end;
   dk_enum: begin
    with atype^.infoenum do begin
     initmainagloc(4+itemcount*2,sizeof(enumrttity)+
                               itemcount*sizeof(enumitemrttity),rtk_enum);
      //itemcount: integer;
     putagitem(agloc1,addi32(itemcount));                         //0
     putagitem(agloc1,addi32(
          ptypedataty(ele.eledataabs(min))^.infoenumitem.value)); //1
     putagitem(agloc1,addi32(
          ptypedataty(ele.eledataabs(max))^.infoenumitem.value)); //2
     enuflags1:= [];
     if enf_contiguous in flags then begin
      include(enuflags1,erf_contiguous);
     end;
     if enf_ascending in flags then begin
      include(enuflags1,erf_ascending);
     end;
      //flags: enumrttiflagsty;
     putagitem(agloc1,addi32(int32(enuflags1)));                  //3
     ele1:= first;
      //items: record end; //array of enumitemrttity
     while ele1 <> 0 do begin
      with ptypedataty(ele.eledataabs(ele1))^.infoenumitem do begin
       putagitem(agloc1,addi32(value));            //0
       putagitem(agloc1,self.addidentconst(ele.eleinfoabs(ele1)^.header.name)); 
                                                   //1
       ele1:= next;
      end;
     end;
    end;
   end;
   dk_string: begin
    case atype^.itemsize of
     1: begin
      if strf_bytes in atype^.infostring.flags then begin
       stringkind1:= stk_byte;
      end
      else begin
       stringkind1:= stk_8;
      end;
     end;
     2: begin
      stringkind1:= stk_16;
     end;
     4: begin
      stringkind1:= stk_32;
     end;
     else begin
      internalerror1(ie_rtti,'20180908A');
     end;
    end;
    initmainagloc(1,sizeof(stringrttity),rtk_string);
    putagitem(agloc1,addi32(ord(stringkind1)));       //0
   end;
   dk_class,dk_object: begin
    i1:= 0;
    i2:= 1; //objectrttity fieldcount
    with atype^.infoclass do begin
     inc(i2);
     i1:= propertycount * sizeof(propertyrttity);
     initlistagloc(fconstlist,agloc2,propertycount*propertyrttifieldcount,i1);
     ele1:= propertychain;
     while ele1 > 0 do begin
      with ppropertydataty(ele.eledataabs(ele1))^ do begin
       typ1:= ele.eledataabs(typ);
       readsub1:= nil;
       writesub1:= nil;
       propflags1:= [];
       if pof_readfield in flags then begin
        include(propflags1,prf_readfield);
       end;
       if pof_readsub in flags then begin
        include(propflags1,prf_readproc);
        readsub1:= ele.eledataabs(readele);
        if readsub1^.flags * [sf_virtual,sf_override] <> [] then begin
         include(propflags1,prf_virtualread);
        end;
       end;
       if pof_writefield in flags then begin
        include(propflags1,prf_writefield);
       end;
       if pof_writesub in flags then begin
        include(propflags1,prf_writeproc);
        writesub1:= ele.eledataabs(writeele);
        if writesub1^.flags * [sf_virtual,sf_override] <> [] then begin
         include(propflags1,prf_virtualwrite);
        end;
       {$ifdef mse_checkinternalerror}
        if writesub1^.paramcount <> 2 then begin
         internalerror(ie_llvmlist,'20180918A');
        end;
       {$endif}
        with pvardataty(ele.eledataabs(
                   (pelementoffsetty(@writesub1^.paramsrel)+1)^))^ do begin
         if af_paramconst in address.flags then begin
          include(propflags1,prf_writeprocconst);
         end;
        end;
       end;
      {$ifdef mse_checkinternalerror}
       if datakindtorttikind[typ1^.h.kind] = rtk_none then begin
        internalerror(ie_llvmlist,'20180711A');
       end;
       if datasizetorttisize[typ1^.h.datasize] = bs_none then begin
        internalerror(ie_llvmlist,'20180711B');
       end;
      {$endif}
       v1.listid:= getrtti(typ1);
       v1.typeid:= pointertype;
       putagitem(agloc2,v1);                                               //0
       putagitem(agloc2,addidentconst(ele.eleinfoabs(ele1)^.header.name)); //1
       putagitem(agloc2,addi32(int32(propflags1)));                        //2
       if not checkpropertymethod(readsub1,v1) then begin
        v1:= addi32(readoffset);
       end;
       putagitem(agloc2,v1);                                               //3
       if not checkpropertymethod(writesub1,v1) then begin
        v1:= addi32(writeoffset);
       end;
       putagitem(agloc2,v1);                                               //4
       ele1:= next;
      end;
     end;
    end;
    initmainagloc(i2,sizeof(objectrttity)+i1,rtk_object);
     //classdef: pclassdefinfoty;
    putagitem(agloc1,nilpointer); //dummy          //0
    putagitem(agloc1,addagloc(agloc2));            //1
   end;
   else begin
    internalerror1(ie_llvm,'20171107A');
   end;
  end;
  m1:= addagloc(agloc1);
  with datatoele(atype)^ do begin
   b2:= header.defunit = info.s.unitinfo;
   b1:= b2 and (vik_interfacedef in header.visibility);
  end;
  if b1 then begin
   link1:= li_external;
  end
  else begin
   link1:= li_internal;
  end;
  i1:= self.addinitvalue(gak_const,m1.listid,link1);
  result:= addpointercast(i1); //prtti
  if b2 then begin //type define unit
   atype^.h.llvmrttivar:= i1;
   atype^.h.llvmrtticonst:= m1.listid;
   atype^.h.rtti:= result.listid;
  end;
  if b1 then begin
   atype^.h.rttinameid:= getunitnameid();
   namelist.addname(info.s.unitinfo,atype^.h.rttinameid,atype^.h.llvmrttivar);
  end;
 end;
end;
(*
function tgloballocdatalist.addclassdefconst(
                                const atype: ptypedataty): llvmvaluety;
var
 agloc1: aglocty;
 
 procedure putvirttab(atype: ptypedataty);
 var
  typ1: ptypedataty;
  i1: int32;
 begin
  if atype^.h.ancestor <> 0 then begin
   typ1:= ele.eledataabs(atype^.h.ancestor);
   if typ1^.infoclass.virtualcount > 0 then begin
    putvirttab(typ1);
   end;
   //todo
  end;
 end;//putvirttab
 
 procedure putinterface(atype: ptypedataty);
 begin
  //todo
 end;
var
 m1: llvmvaluety;
 i1: int32;
  
begin
 with fconstlist,atype^ do begin
  infoclass.defs.address:= -1;
  createrecordmanagehandler(ele.eledatarel(atype));

  initagloc(agloc1,10+infoclass.virtualcount+infoclass.interfacecount);

   //parentclass: pclassdefinfoty;
  if h.ancestor <> 0 then begin
   putagpointer(agloc1,ptypedataty(
                      ele.eledataabs(h.ancestor))^.infoclass.defs.address);
                                                              //1
  end
  else begin
   putagitem(agloc1,nilpointer);                              //1
  end;
   //interfaceparent: pclassdefinfoty; //last parent class with interfaces
  if infoclass.interfaceparent <> 0 then begin
   putagpointer(agloc1,ptypedataty(
          ele.eledataabs(infoclass.interfaceparent))^.infoclass.defs.address); 
                                                              //2
  end
  else begin
   putagitem(agloc1,nilpointer);                              //2
  end;
   //virttaboffset: int32;             //field offset in instance
  putagitem(agloc1,addi32(infoclass.virttaboffset));          //3
   //typeinfo: prttity;
  putagitem(agloc1,addpointercast(infoclass.rttiid));         //4
   //procs: array[classdefprocty] of classprocty;
  putagsub(agloc1,pinternalsubdataty(
                ele.eledataabs(recordmanagehandlers[mo_ini]))^.address);
                                                              //5
  putagsub(agloc1,pinternalsubdataty(
                ele.eledataabs(recordmanagehandlers[mo_fini]))^.address);
                                                              //6
  putagsub(agloc1,pinternalsubdataty(
             ele.eledataabs(recordmanagehandlers[mo_destroy]))^.address);
                                                              //7
   //allocs: allocsinfoty;
    //size: int32;
  putagitem(agloc1,addi32(infoclass.allocsize));              //8
    //instanceinterfacestart: int32; //offset in instance record
  putagitem(agloc1,addi32(infoclass.instanceinterfacestart)); //9
    //classdefinterfacestart: int32; //offset in classdefheaderty
  putagitem(agloc1,addi32(sizeof(classdefinfoty) + 
             targetpointersize*infoclass.virtualcount));      //10

  putvirttab(atype);
  putinterface(atype);
  m1:= addagloc(agloc1);
  i1:= self.addinitvalue(gak_const,m1.listid,info.s.globlinkage);
  result:= addpointercast(i1); //pclassdefinfoty
  infoclass.defs.address:= result.listid;
 end;
end;
*)
function tgloballocdatalist.addtypecopy(const alistid: int32): int32;
begin
 result:= fcount;
 inccount();
 flastitem^:= (pgloballocdataty(fdata) + alistid)^; 
end;

{ ttypemetahashdatalist }
{
constructor ttypemetahashdatalist.create();
begin
 inherited create(sizeof(metavaluety));
end;
}

function ttypemetahashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(typemetahashdataty);
end;
{ tconstmetahashdatalist }
{
constructor tconstmetahashdatalist.create();
begin
 inherited create(sizeof(metavaluety));
end;
}

function tconstmetahashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(tconstmetahashdatalist);
end;

{ tmetadatalist }

constructor tmetadatalist.create(const atypelist: ttypehashdatalist;
               const aconstlist: tconsthashdatalist;
                          const agloblist: tgloballocdatalist);
begin
 ftypelist:= atypelist;
 fconstlist:= aconstlist;
 fgloblist:= agloblist;
 ftypemetalist:= ttypemetahashdatalist.create();
 fconstmetalist:= tconstmetahashdatalist.create();
 funitlist:= tpointerint32hashdatalist.create();
 inherited create();
end;

destructor tmetadatalist.destroy();
begin
 inherited;
 ftypemetalist.free();
 fconstmetalist.free();
 funitlist.free();
end;

procedure tmetadatalist.clear;
begin
 inherited;
 if not (bdls_destroying in fstate) then begin
  fhasmoduleflags:= false;
  if info.o.debugoptions <> [] then begin
   femptystringconst:= addstring('');
   with pnodemetaty(adddata(mdk_node,sizeof(nodemetaty),femptynode))^ do begin
    len:= 0;
   end;
   ftypemetalist.clear();
   fconstmetalist.clear();
   funitlist.clear();
   fsysfile:= adddifile('system');
   fsyscontext:= fsysfile;
   fsysname:= addstring('system');
   fdbgdeclare:= fgloblist.addexternalsubvalue(false,
            [ftypelist.metadata,ftypelist.metadata,ftypelist.metadata],
                                            getidentname('llvm.dbg.declare'));
   fdummyaddrexp:= adddiexpression([]);
   fderefaddrexp:= adddiexpression([DW_OP_deref]);
   fopenarrayaddrexp:= adddiexpression([DW_OP_plus,sizeof(openarrayty.high)]);
   fpointertyp.id:= 0;      //initialized in getter func
   fbytetyp.id:= 0;         //initialized in getter func
   fnoparams.id:= 0;        //initialized in getter func
   fnoparamssubtyp.id:= 0;    //initialized in getter func
   fparams1po.id:= 0;       //initialized in getter func
   fparams1posubtyp.id:= 0; //initialized in getter func
  end;
 end;
end;


function tmetadatalist.getpointertyp: metavaluety;
begin
 if fpointertyp.id = 0 then begin
  fpointertyp:= addtype(0,1); //untyped pointer
 end;
 result:= fpointertyp;
end;

function tmetadatalist.getbytetyp: metavaluety;
begin
 if fbytetyp.id = 0 then begin
  fbytetyp:= addtype(sysdatatypes[st_card8].typedata,0);
 end;
 result:= fbytetyp;
end;
{
function tmetadatalist.getvoidtyp: metavaluety;
begin
 if fvoidtyp.id = 0 then begin
  fvoidtyp:= addtype(ftypelist.void,0); wrong!
 end;
 result:= fvoidtyp;
end;
}
function tmetadatalist.getnoparams: metavaluety;
begin
 if fnoparams.id = 0 then begin
  fnoparams:= addnode([dummymeta]);
 end;
 result:= fnoparams;
end;

function tmetadatalist.getparams1po: metavaluety;
begin
 if fparams1po.id = 0 then begin
  fparams1po:= addnode([dummymeta,pointertyp]);
 end;
 result:= fparams1po;
end;

function tmetadatalist.getnoparamssubtyp: metavaluety;
var
 m1: metavaluety;
begin
 if fnoparamssubtyp.id = 0 then begin
  m1:= noparams;
  with pdisubroutinetypety(
   adddata(mdk_disubroutinetype,sizeof(disubroutinetypety),
                                            fnoparamssubtyp))^ do begin
   params:= m1;
  end;
 end;
 result:= fnoparamssubtyp;
end;

function tmetadatalist.getparams1posubtyp: metavaluety;
var
 m1: metavaluety;
begin
 if fparams1posubtyp.id = 0 then begin
  m1:= params1po;
  with pdisubroutinetypety(
   adddata(mdk_disubroutinetype,sizeof(disubroutinetypety),
                                            fparams1posubtyp))^ do begin
   params:= m1;
  end;
 end;
 result:= fparams1posubtyp;
end;

function tmetadatalist.getdynarrayindex: metavaluety;
var
 ra1: ordrangety;
 m1: metavaluety;
begin
 if fdynarrayindex.id = 0 then begin
  ra1.min:= 0;
  ra1.max:= 0; //todo: dynarray debug info
  m1:= adddisubrange(ra1);
  fdynarrayindex:= addnode([m1]);
 end;
 result:= fdynarrayindex;
end;

procedure tmetadatalist.beginunit;
begin
// fsubprogramcount:= 0;
end;

function tmetadatalist.first: pmetadataty;
begin
 result:= firstdata();
end;

function tmetadatalist.next: pmetadataty;
begin
 result:= nextdata();
end;

function tmetadatalist.adddata(const akind: metadatakindty; 
               const adatasize: int32; out avalue: metavaluety): pointer;
begin
// avalue.value.typeid:= ftypelist.metadata;
 avalue.id:= fcount;
// avalue.flags:= [mvf_meta];
 result:= inherited adddata(adatasize+sizeof(metadataheaderty));
 with pmetadataheaderty(result)^ do begin
  kind:= akind;
 end;
 inc(result,sizeof(metadataheaderty));
end;

function tmetadatalist.getdata(const avalue: metavaluety): pointer;
begin
 result:= items[avalue.id]+sizeof(metadataheaderty);
end;

function tmetadatalist.getstringvalue(const avalue: metavaluety): lstringty;
var
 po1: pstringmetaty;
begin
 po1:= getdata(avalue);
{$ifdef mse_checkinternalerror}
 if pmetadataty(pointer(po1)-sizeof(metadataheaderty))^.header.kind <> 
                                                    mdk_string then begin
  internalerror(ie_llvmmeta,'20151108A');
 end;
{$endif}
 with po1^ do begin
  result.len:= len;
  result.po:= @data;
 end;
end;

function tmetadatalist.i8const(const avalue: int8): metavaluety;
begin
 result:= addconst(fconstlist.i8(avalue));
end;

function tmetadatalist.i32const(const avalue: int32): metavaluety;
begin
 result:= addconst(fconstlist.addi32(avalue).listid);
end;

function tmetadatalist.addconst(const constid: int32): metavaluety;
var
 po1: pconstmetahashdataty;
 m1: metavaluety;
begin
 if fconstmetalist.addunique(constid,pintegerhashdataty(po1)) then begin
  with pvaluemetaty(adddata(mdk_constvalue,
                            sizeof(valuemetaty),m1))^ do begin
   value.listid:= constid;
   value.typeid:= fconstlist.gettype(constid);;
  end;
  po1^.data.id:= m1.id;
 end;
// result.value.typeid:= ftypelist.metadata;
 result.id:= po1^.data.id;
// result.flags:= [mvf_meta];
end;

function tmetadatalist.addglobvalue(const globid: int32): metavaluety;
begin
 with pvaluemetaty(adddata(mdk_globvalue,
                           sizeof(valuemetaty),result))^ do begin
  value.listid:= globid;
  value.typeid:= fgloblist.gettype(globid);;
 end;
end;

function tmetadatalist.adddigenericdebug(const atag: int32;
               const avalues: pmetavaluety; const acount: int32): metavaluety;
var
 i1: int32;
begin
 i1:= acount*sizeof(avalues^);
 with pdigenericdebugty(adddata(mdk_digenericdebug,
                          sizeof(digenericdebugty)+i1,result))^ do begin
  tag:= atag;
  len:= acount;
  move(avalues^,data,i1);
 end;
end;

function tmetadatalist.adddigenericdebug(const atag: int32;
               const avalues: array of metavaluety): metavaluety;
begin
 result:= adddigenericdebug(atag,@avalues,length(avalues));
end;

function tmetadatalist.addnode(const avalues: pmetavaluety;
                                     const acount: int32): metavaluety;
var
 i1: int32;
begin
 if acount = 0 then begin
  result:= femptynode;
 end
 else begin
  i1:= acount*sizeof(avalues^);
  with pnodemetaty(adddata(mdk_node,sizeof(nodemetaty)+i1,result))^ do begin
   len:= acount;
   move(avalues^,data,i1);
  end;
 end;
end;

function tmetadatalist.addnode(
                        const avalues: array of metavaluety): metavaluety;
begin
 result:= addnode(@avalues,length(avalues));
end;

function tmetadatalist.addnode(const avalues: metavaluesty): metavaluety;
begin
 result:= addnode(pointer(avalues.data),avalues.count);
end;

function tmetadatalist.addnodereverse(const avalues: pmetavaluety;
               const acount: int32): metavaluety;
var
 ps,pd: pmetavaluety;
begin
 if acount = 0 then begin
  result:= femptynode;
 end
 else begin
  with pnodemetaty(adddata(
          mdk_node,sizeof(nodemetaty)+acount*sizeof(avalues^),result))^ do begin
   len:= acount;
   pd:= @data;
   ps:= avalues+acount;
   while ps > avalues do begin
    dec(ps);
    pd^:= ps^;
    inc(pd);
   end;
  end;
 end;
end;

function tmetadatalist.addnode(const valuesa: pmetavaluety; const counta: int32;
               const valuesb: pmetavaluety; const countb: int32): metavaluety;
var
 i1: int32;
 ps,pd,pe: pmetavaluety;
begin
 i1:= counta + countb;
 if i1 = 0 then begin
  result:= femptynode;
 end
 else begin
  with pnodemetaty(adddata(
               mdk_node,sizeof(nodemetaty)+i1*sizeof(valuesa^),result))^ do begin
   len:= i1;
   pd:= @data;
   ps:= valuesa;
   pe:= ps+counta;
   while ps < pe do begin
    pd^:= ps^;
    inc(pd);
    inc(ps);
   end;
   ps:= valuesb;
   pe:= ps+countb;
   while ps < pe do begin
    pd^:= ps^;
    inc(pd);
    inc(ps);
   end;
  end;
 end;
end;

function tmetadatalist.addnodereverse(const valuesa: pmetavaluety;
               const counta: int32; const valuesb: pmetavaluety;
               const countb: int32): metavaluety;
var
 i1: int32;
 ps,pd: pmetavaluety;
begin
 i1:= counta + countb;
 if i1 = 0 then begin
  result:= femptynode;
 end
 else begin
  with pnodemetaty(adddata(
               mdk_node,sizeof(nodemetaty)+i1*sizeof(valuesa^),result))^ do begin
   len:= i1;
   pd:= @data;
   ps:= valuesb+countb;
   while ps > valuesb do begin
    dec(ps);
    pd^:= ps^;
    inc(pd);
   end;
   ps:= valuesa+counta;
   while ps > valuesa do begin
    dec(ps);
    pd^:= ps^;
    inc(pd);
   end;
  end;
 end;
end;

procedure tmetadatalist.addnamednode(const aname: lstringty;
                                         const avalues: array of int32);
var
 i1: int32;
 m1: metavaluety;
begin
 i1:= length(avalues)*sizeof(avalues[0]);
 with pnamednodemetaty(adddata(mdk_namednode,
                       sizeof(namednodemetaty)+i1+aname.len,m1))^ do begin
  len:= length(avalues);
  move(avalues,data,i1);
  namelen:= aname.len;
  move(aname.po^,(@data+i1)^,aname.len);
 end;
 dec(fcount); //has no index
end;

function tmetadatalist.addident(const aident: identnamety): metavaluety;
begin
 with pidentmetaty(adddata(mdk_ident,sizeof(identmetaty),result))^ do begin
  name:= aident;
 end;
end;

function tmetadatalist.addstring(const avalue: lstringty): metavaluety;
begin
 if avalue.len = 0 then begin
  result:= emptystringconst;
 end
 else begin
  with pstringmetaty(
           adddata(mdk_string,sizeof(stringmetaty)+avalue.len,result))^ do begin
   len:= avalue.len;
   move(avalue.po^,data,len);
  end;
 end;
end;

function tmetadatalist.addstring(const avalue: string): metavaluety;
begin
 result:= addstring(stringtolstring(avalue));
end;

function tmetadatalist.addstringornull(const avalue: lstringty): metavaluety;
begin
 if avalue.len = 0 then begin
  result:= dummymeta;
 end
 else begin
  result:= addstring(avalue);
 end;
end;

function tmetadatalist.adddifile(const afilename: filenamety): metavaluety;
var
 m1,m2: metavaluety;
 dir,na: filenamety;
begin
 splitfilepath(afilename,dir,na);
 if dir = '' then begin
  m1:= dummymeta; //fwdstringconst;
 end
 else begin
  m1:= addstring(stringtolstring(string(dir)));
 end;
 m2:= addstring(stringtolstring(string(na)));
 with pdifilety(adddata(mdk_difile,sizeof(difilety),result))^ do begin
  dirname:= m1;
  filename:= m2;
 end;
end;
{
function tmetadatalist.dwarftag(const atag: int32): metavaluety;
begin
 result.value:= fconstlist.addi32(atag or LLVMDebugVersion);
 result.flags:= [];
end;
}
{
function tmetadatalist.adddifile(const afile: metavaluety): metavaluety;
begin
 result:= addnode([dwarftag(DW_TAG_FILE_TYPE),afile]);
end;
}
{
function tmetadatalist.adddiscope(const afile: metavaluety): metavaluety;
begin
 with pdiscopety(adddata(mdk_discope,
                    sizeof(discopety),result))^ do begin
  difile:= afile;
 end;
end;
}
function tmetadatalist.adddicompileunit(const afile: metavaluety; 
              const asourcelanguage: int32; const aproducer: string; 
          const asubprograms: metavaluety; const aglobalvariables: metavaluety;
                          const aemissionkind: DebugEmissionKind): metavaluety;
var
 m1: metavaluety;
begin
 m1:= addstring(stringtolstring(aproducer));
 with pdicompileunitty(adddata(mdk_dicompileunit,
                    sizeof(dicompileunitty),result))^ do begin
  difile:= afile;
  sourcelanguage:= asourcelanguage;
  producer:= m1;
  subprograms:= asubprograms;
  globalvariables:= aglobalvariables;
  emissionkind:= aemissionkind;
  fcompileunit:= result;
  fcompilefile:= afile;
 end;
end;

function tmetadatalist.adddisubprogram(const ascope: metavaluety;
          const aname: identnamety;
          const afile: metavaluety; const aline: int32;
          const afunction: int32;
          const atype: metavaluety; const aflags: dwsubflagsty;
          const alocaltounit: boolean): metavaluety;
var
 m1: metavaluety;
 m2: metavaluety;
begin
 m1:= addident(aname);
 if afunction >= 0 then begin
  m2:= addglobvalue(afunction);
 end
 else begin
  m2:= dummymeta;
 end;
 with pdisubprogramty(adddata(mdk_disubprogram,
                    sizeof(disubprogramty),result))^ do begin
  scope:= ascope;
  _file:= afile;
  line:= aline;
  _function:= m2;
  name:= m1;
  _type:= atype;
  flags:= aflags;
  localtounit:= alocaltounit;
  variables:= dummymeta;
 end;
 addmetaitem(info.s.unitinfo^.subprograms,result);
end;

function tmetadatalist.adddisubroutinetype(const asub: psubdataty{;
          const afile: metavaluety; const acontext: metavaluety}): metavaluety;
var
 m1: metavaluety;
 params1: array[0..maxparamcount] of metavaluety;
 i1: int32;
 parcount1: int32;
 po1: pelementoffsetty;
 po2,pe: pmetavaluety;
 po3: pvardataty;
begin
 if asub = nil then begin //main
  parcount1:= 1;
  params1[0]:= addtype(sysdatatypes[st_int32].typedata,0{,false});
 end
 else begin
  if (asub^.paramcount > maxparamcount) then begin
   parcount1:= 0;
   m1:= femptynode;
  end
  else begin
   parcount1:= asub^.paramcount;
   po1:= @asub^.paramsrel;
   po2:= @params1;
   if not (sf_functioncall in asub^.flags) then begin //todo: handle result deref
    if parcount1 = 0 then begin
     m1:=  noparams;
    end
    else begin
     po2^:= dummymeta;
     inc(po2);
    end;
   end;
   pe:= po2 + parcount1;
   while po2 < pe do begin
    po3:= ele.eledataabs(po1^);
    po2^:= addtype(po3^);
    inc(po1);
    inc(po2);
   end;
   parcount1:= pe-pmetavaluety(@params1);
  end;
 end;
 if parcount1 > 0 then begin
  m1:= addnode(@params1,parcount1);
 end;
 with pdisubroutinetypety(adddata(mdk_disubroutinetype,
                    sizeof(disubroutinetypety),result))^ do begin
//  difile:= afile;
//  context:= acontext;
  params:= m1;
 end;
end;
{
function tmetadatalist.getsubprograms: metavaluesty;
begin
 result.count:= fsubprogramcount;
 result.data:= pointer(fsubprograms);
end;

function tmetadatalist.getglobalvariables: metavaluesty;
begin
 result.count:= fglobalvariablecount;
 result.data:= pointer(fglobalvariables);
end;
}
function tmetadatalist.adddibasictype(const aname: lstringty;
           const asizeinbits: int32; const aaligninbits: int32;
           const aflags: int32; const aencoding: int32): metavaluety;
var
 m1{,m2}: metavaluety;
begin
 m1:= addstringornull(aname);
 with pdibasictypety(adddata(mdk_dibasictype,
                    sizeof(dibasictypety),result))^ do begin
  name:= m1;
  sizeinbits:= asizeinbits;
  aligninbits:= aaligninbits;
  flags:= aflags;
  encoding:= aencoding;
 end;
end;

function tmetadatalist.adddirefstringtype(const aname: lstringty;
                                const akind: dicharkindty): metavaluety;
var
 m1: metavaluety;
begin
 m1:= addstringornull(aname);
 with pdirefstringtypety(adddata(mdk_direfstringtype,
                    sizeof(direfstringtypety),result))^ do begin
  name:= m1;
  chartype:= akind;
 end;
end;

function tmetadatalist.adddienumerator(const aname: lstringty;
               const avalue: int32): metavaluety;
var
 m1: metavaluety;
begin
 m1:= addstringornull(aname);
 with pdienumeratorty(adddata(mdk_dienumerator,
                    sizeof(dienumeratorty),result))^ do begin
  name:= m1;
  value:= avalue;
 end;
end;

function tmetadatalist.adddisubrange(const arange: ordrangety): metavaluety;
begin
 with pdisubrangety(adddata(mdk_disubrange,
                    sizeof(disubrangety),result))^ do begin
  range:= arange;
 end;
end;

function tmetadatalist.adddiderivedtype(const akind: diderivedtypekindty;
           const adifile: metavaluety;
           const ascope: metavaluety; const aname: lstringty;
           const aline: int32;
           const asizeinbits: int32; const aaligninbits: int32;
           const aoffsetinbits: int32;
           const aflags: int32; const abasetype: metavaluety): metavaluety;
var
 m1: metavaluety;
begin
 m1:= addstringornull(aname);
 with pdiderivedtypety(adddata(mdk_diderivedtype,
                    sizeof(diderivedtypety),result))^ do begin
  kind:= akind;
  name:= m1;
  _file:= adifile;
  line:= aline;
  scope:= ascope;
  basetype:= abasetype;
  sizeinbits:= asizeinbits;
  aligninbits:= aaligninbits;
  offsetinbits:= aoffsetinbits;
  flags:= aflags;
 end;
end;

function tmetadatalist.adddicompositetype(const akind: dicompositetypekindty; 
           const aname: lstringty;
           const adifile: metavaluety;
           const aline: int32;
           const ascope: metavaluety;
           const abasetype: metavaluety;
           const asizeinbits: int32; const aaligninbits: int32;
           const aoffsetinbits: int32;
           const aflags: int32;
           const aelements: metavaluety): metavaluety;
var
 m1: metavaluety;
begin
 m1:= addstringornull(aname);
 with pdicompositetypety(adddata(mdk_dicompositetype,
                    sizeof(dicompositetypety),result))^ do begin
  kind:= akind;
  name:= m1;
  _file:= adifile;
  line:= aline;
  scope:= ascope;
  basetype:= abasetype;
  sizeinbits:= asizeinbits;
  aligninbits:= aaligninbits;
  offsetinbits:= aoffsetinbits;
  flags:= aflags;
  elements:= aelements;
 end;
end;

const
 name_code: lstringty = (po: 'code'; len: length('code'));
 name_data: lstringty = (po: 'data'; len: length('data'));

function tmetadatalist.addtype(atype: elementoffsetty;
                      aindirection: int32;
                                const subrange: boolean = false): metavaluety;
          //todo: use correct alignment
const
 metabuffersize = 1;
 
var
 metabuffer: array[0..metabuffersize-1] of metavaluety;
 metabufferpo,pb,pe: pmetavaluety;

 procedure initmetabuffer();
 begin
  pb:= @metabuffer;
  metabufferpo:= pb;
  pe:= metabufferpo+metabuffersize;
 end; //initmetabuffer

 procedure addbufferitem(const aitem: metavaluety);
 var
  i1: int32;
 begin
  metabufferpo^:= aitem;
  inc(metabufferpo);
  if metabufferpo = pe then begin
   if pb = @metabuffer then begin
    i1:= 2*metabuffersize*sizeof(metavaluety);
    getmem(pb,i1);
    metabufferpo:= pb;
    pe:= pointer(pb)+i1;
   end
   else begin
    i1:= 2*(pointer(pe)-pointer(pb));
    reallocmem(pb,i1);
    pe:= pointer(pb)+i1;
    metabufferpo:= pointer(pb) + i1 div 2;
   end;
  end;
 end; //addmetabufferitem

 function addbuffer(): metavaluety;
 begin
  if pb <> @metabuffer then begin
   result:= addnode(@metabuffer,metabuffersize,pb,metabufferpo-pb);
   freemem(pb);
  end
  else begin
   result:= addnode(@metabuffer,pb-pmetavaluety(@metabuffer));
  end;
 end; //addbuffer

 function addbufferreverse(): metavaluety;
 begin
  if pb <> @metabuffer then begin
   result:= addnodereverse(@metabuffer,metabuffersize,pb,metabufferpo-pb);
   freemem(pb);
  end
  else begin
   result:= addnodereverse(@metabuffer,pb-pmetavaluety(@metabuffer));
  end;
 end; //addbufferreverse
 
var
 po2: ptypedataty;
 po3: pfielddataty;
 po4: ptypedataty;
 offs1: card32;
 lstr1: lstringty;
 file1: metavaluety;
 m1,m2,m3,context1: metavaluety;
 i1: int32;
 typekind1: diderivedtypekindty;
 ele1: elementoffsetty;
 p0: pointer;
 po1: pmetavaluety;
 st1: systypety;
 unit1: punitinfoty;
 unitkey1: identty;
begin
 if atype = 0 then begin //untyped pointer
  atype:= getbasetypeele(das_8);
 end;
 po2:= ele.eledataabs(atype);
 unitkey1:= 0; //system
 unit1:= datatoele(po2)^.header.defunit;
 if unit1 <> nil then begin
  unitkey1:= unit1^.key;
 end;
// if po2^.h.kind = dk_sub then begin
//  inc(aindirection);
// end;
 i1:= aindirection;
 if subrange then begin
  i1:= i1 or $80000000;
 end;
 if ftypemetalist.addunique(atype,i1,unitkey1,p0) then begin
  po1:= @ptypemetahashdataty(p0)^.data;
  offs1:= ftypemetalist.getdataoffs(po1); //relative backup
  with datatoele(po2)^.header do begin
   if defunit = info.s.unitinfo then begin
    file1:= defunit^.filepathmeta;
    context1:= file1;
   end
   else begin
    if not funitlist.find(defunit,file1.id) then begin
     if defunit = nil then begin
      file1:= adddifile('system');
     end
     else begin
      file1:= adddifile(defunit^.filepath);
     end;
     funitlist.add(defunit,file1.id);
    end;
    context1:= file1;
   end;
  end;
  if (aindirection > 0) then begin 
                                              //todo: set identname
   typekind1:= didk_pointertype;
   m2:= addtype(atype,aindirection-1); //next base type
   m1:= adddiderivedtype(typekind1,file1,context1,
             emptylstring,0,targetpointerbitsize,targetpointerbitsize,0,0,m2);
  end
  else begin
   getidentname(datatoele(po2)^.header.name,lstr1);
   if po2^.h.indirectlevel > 0 then begin
    m1:= adddiderivedtype(didk_pointertype,file1,context1,
              lstr1,0,targetpointerbitsize,targetpointerbitsize,0,0,dummymeta);
                 //preliminary for forward pointer
    po1:= ftypemetalist.getdatapo(offs1); //possibly moved
    po1^.id:= m1.id;
    m2:= addtype(po2^.h.base,0);
    with pdiderivedtypety(getdata(m1))^ do begin
     basetype:= m2;
    end;
   end
   else begin
    case po2^.h.kind of
     dk_integer,dk_cardinal,dk_boolean: begin
      if subrange and (tf_subrange in po2^.h.flags) then begin
       m1:= adddisubrange(getordrange(po2));
      end
      else begin
       case po2^.h.kind of
        dk_integer: i1:= DW_ATE_signed;
        dk_cardinal: i1:= DW_ATE_unsigned;
        dk_boolean: i1:= DW_ATE_boolean;
       end;
       m1:= adddibasictype(lstr1,po2^.h.bitsize,po2^.h.bitsize,0,i1);
      end;
     end;
     dk_character: begin
       m1:= adddibasictype(lstr1,po2^.h.bitsize,po2^.h.bitsize,0,
                                                  DW_ATE_unsigned_char);
     end;
     dk_float: begin
      m1:= adddibasictype(lstr1,po2^.h.bitsize,po2^.h.bitsize,0,DW_ATE_float);      
     end;
     dk_enum: begin
      ele1:= po2^.infoenum.first;
      initmetabuffer();
      while ele1 <> 0 do begin
       po4:= ele.eledataabs(ele1);
       addbufferitem(adddienumerator(
              getidentname1(datatoele(po4)^.header.name),
                                               po4^.infoenumitem.value));
       ele1:= po4^.infoenumitem.next;
      end;
      m2:= addbuffer();
      m1:= adddicompositetype(dick_enumtype,lstr1,file1,0,context1,
                                   dummymeta,po2^.h.bitsize,0,0,0,m2);      
     end;
     dk_set: begin
       m1:= adddibasictype(lstr1,po2^.h.bitsize,po2^.h.bitsize,0,
                                                     DW_ATE_unsigned);
                  //todo!
     end;
     dk_array: begin
      po4:= ele.eledataabs(po2^.infoarray.i.itemtypedata);
      i1:= po2^.infoarray.i.itemindirectlevel;
      if po4^.h.kind = dk_sub then begin
       inc(i1);
      end;
      m2:= addtype(po2^.infoarray.i.itemtypedata,i1);
      m3:= addnode([addtype(po2^.infoarray.indextypedata,0,true)]);
      m1:= adddicompositetype(dick_arraytype,lstr1,file1,0,context1,
                                   m2,po2^.h.bitsize,0,0,0,m3);
                                        //todo: use correct alignment
     end;
     dk_dynarray: begin
      m2:= addtype(po2^.infodynarray.i.itemtypedata,
                                   po2^.infodynarray.i.itemindirectlevel);
      m1:= adddiderivedtype(didk_pointertype,file1,context1,
                      lstr1,0,targetpointerbitsize,targetpointerbitsize,0,0,m2);
                       //todo
     end;
     dk_openarray: begin
      m2:= addtype(po2^.infodynarray.i.itemtypedata,
                                   po2^.infodynarray.i.itemindirectlevel);
      m1:= adddiderivedtype(didk_pointertype,file1,context1,
                      lstr1,0,targetpointerbitsize,targetpointerbitsize,0,0,m2);
     end;
     dk_string: begin         //todo: use refstringtype
      case po2^.itemsize of
       2: begin
        st1:= st_char16;
       end;
       4: begin
        st1:= st_char32;
       end;
       else begin
        st1:= st_char8;
       end;
      end;
      m2:= addtype(sysdatatypes[st1].typedata,0);
      m1:= adddiderivedtype(didk_pointertype,file1,context1,
                      lstr1,0,targetpointerbitsize,targetpointerbitsize,0,0,m2);
     end;
     dk_method: begin
      initmetabuffer();
      addbufferitem(adddiderivedtype(didk_member,file1,context1,name_data,0,
           targetpointerbitsize,0,targetpointerbitsize,0,pointertyp));
      addbufferitem(adddiderivedtype(didk_member,file1,context1,name_code,0,
           targetpointerbitsize,0,0,0,pointertyp));

      m2:= addbufferreverse();
      m1:= adddicompositetype(dick_structuretype,lstr1,file1,0,context1,
                                     dummymeta,2*targetpointerbitsize,0,0,0,m2);
                                        //todo: use correct alignment
     end;
     dk_record,dk_object,dk_class,dk_objectpo: begin
      if po2^.h.kind = dk_objectpo then begin
       po2:= ele.eledataabs(po2^.h.base);
      end;
      m1:= adddicompositetype(dick_structuretype,lstr1,file1,0,context1,
                                   dummymeta,po2^.h.bitsize,0,0,0,dummymeta);
                                        //todo: use correct alignment
                                         //preliminary for forward pointer
      po1:= ftypemetalist.getdatapo(offs1); //possibly moved
      po1^.id:= m1.id;
      initmetabuffer();
      ele1:= po2^.fieldchain;
      while ele1 <> 0 do begin
       po3:= ele.eledataabs(ele1);
       po4:= ele.eledataabs(po3^.vf.typ);
       i1:= po3^.indirectlevel-po4^.h.indirectlevel;
       if po4^.h.kind = dk_sub then begin
        inc(i1);
       end;
       addbufferitem(adddiderivedtype(didk_member,file1,context1,
           getidentname1(pointer(po3)),0,po4^.h.bitsize,0,po3^.offset*8,
                                                   0,addtype(po3^.vf.typ,i1)));
       ele1:= po3^.vf.next;
      end;
      m2:= addbuffer();
      with pdicompositetypety(getdata(m1))^ do begin
       elements:= m2;
      end;
     end;
     dk_interface: begin
      m2:= addtype(0,0);        //todo
      m1:= adddiderivedtype(didk_pointertype,file1,context1,
                      lstr1,0,targetpointerbitsize,targetpointerbitsize,0,0,m2);
     end;
     dk_classof: begin
      m2:= bytetyp;        //todo
      m1:= adddiderivedtype(didk_pointertype,file1,context1,
                      lstr1,0,targetpointerbitsize,targetpointerbitsize,0,0,m2);
     end;
     dk_sub: begin
      m1.id:= -1;
     end;
     dk_none: begin
     {$ifdef msechckinternalerror}
      if not (tf_untyped in po2^.h.flags) then begin
       internalerror(ie_llvmmeta,'20170425');
      end;
     {$endif}
      m1:= bytetyp;
     end;
     else begin
      internalerror1(ie_llvmmeta,'20151026A');
     end;
    end;
   end;
  end;
  po1:= ftypemetalist.getdatapo(offs1); //possibly moved
  po1^.id:= m1.id;
 end
 else begin
  po1:= @ptypemetahashdataty(p0)^.data;
 end;
 result.id:= po1^.id;
end;

function tmetadatalist.addtype(const avariable: vardataty): metavaluety;
var
 i1: int32;
 p1: ptypedataty;
begin
 i1:= 0;
 p1:= ele.eledataabs(avariable.vf.typ);
 if (af_paramindirect in avariable.address.flags) and 
          not (tf_untyped in p1^.h.flags) then begin
  i1:= -1;
 end;
 if p1^.h.kind = dk_sub then begin
  inc(i1);
 end;
 result:= addtype(avariable.vf.typ,avariable.address.indirectlevel-
         ptypedataty(ele.eledataabs(avariable.vf.typ))^.h.indirectlevel + i1);
end;

function tmetadatalist.adddivariable(const aname: lstringty;
                       const alinenumber: int32; const argnumber: int32;
          const avariable: vardataty;const atype: metavaluety): metavaluety;
var
 m1,{m2,}m3,m4: metavaluety;
begin
 m1:= addstring(aname);
// m2:= addtype(avariable);
 if af_segment in avariable.address.flags then begin
  m3:= addglobvalue(avariable.address.segaddress.address);
  with pdiglobvariablety(adddata(mdk_diglobvariable,
                     sizeof(diglobvariablety),result))^ do begin
   scope:= info.s.currentcompileunitmeta;
   name:= m1;
   _file:= info.s.currentfilemeta;
   line:= alinenumber;
   _type:= atype;
   variable:= m3;
   islocaltounit:= us_implementation in info.s.unitinfo^.state;
  end;
  addmetaitem(info.s.unitinfo^.globalvariables,result);
 end
 else begin
  with pdilocvariablety(adddata(mdk_dilocvariable,
                     sizeof(dilocvariablety),result))^ do begin
   if af_param in avariable.address.flags then begin
    kind:= divk_argvariable;
    arg:= argnumber+1;
   end
   else begin
    kind:= divk_autovariable;
    arg:= 0;
   end;
   scope:= info.s.currentscopemeta;
   name:= m1;
   _file:= info.s.currentfilemeta;
   linenumber:= alinenumber;
   _type:= atype;
   flags:= 0;
  end;
 end;
end;

function tmetadatalist.adddivariable(const aname: lstringty;
                       const alinenumber: int32; const argnumber: int32;
          const avariable: vardataty): metavaluety;
begin
 result:= adddivariable(
                    aname,alinenumber,argnumber,avariable,addtype(avariable));
end;

function tmetadatalist.adddiexpression(
              const aexpression: array of int32): metavaluety;
var
 i1: int32;
begin
{$ifdef mse_checkinternalerror}
 if high(aexpression) > high(diexpressionty.items) then begin
  internalerror(ie_llvmlist,'20151122A');
 end;
{$endif}
 with pdiexpressionty(adddata(mdk_diexpression,
                     sizeof(diexpressionty),result))^ do begin
  count:= length(aexpression);
  for i1:= 0 to high(aexpression) do begin
   items[i1]:= aexpression[i1];
  end;
 end;
end;

{
function tmetadatalist.adddicompositetype(const atag: int32;
               const aitems: array of metavaluety): metavaluety;
begin
 result:= addnode([dwarftag(atag)],aitems);
end;
}

{ tllvmlists }

constructor tllvmlists.create;
begin
 ftypelist:= ttypehashdatalist.create();
 fconstlist:= tconsthashdatalist.create(ftypelist);
 fgloblist:= tgloballocdatalist.create(ftypelist,fconstlist);
// fconstlist.fgloblist:= fgloblist;
 fmetadatalist:= tmetadatalist.create(ftypelist,fconstlist,fgloblist);
end;

destructor tllvmlists.destroy;
begin
 inherited;
 fmetadatalist.free();
 fgloblist.free();
 fconstlist.free();
 ftypelist.free();
end;

procedure tllvmlists.clear;
begin
 ftypelist.clear();
 fconstlist.clear();
 fgloblist.clear();
 fmetadatalist.clear();
end;

{ tlinklist }
{
constructor tlinklist.create;
begin
 inherited create(sizeof(linkdataty));
end;
}
function tlinklist.getrecordsize(): int32;
begin
 result:= sizeof(linkhashdataty);
end;

procedure tlinklist.addlink(const adata: pointer; const aglobid: int32);
begin
 with plinkhashdataty(add(0,ele.eledatarel(adata)))^ do begin
  data.globid:= aglobid;
 end;
end;

procedure tlinklist.addlink(const extunit: pointer; //punitinfoty
                               const extglobid: int32; const locglobid: int32);
begin
 with plinkhashdataty(add(punitinfoty(extunit)^.key,-extglobid))^ do begin
  data.globid:= locglobid;
 end;
end;

function tlinklist.find(const aunit: pointer; //punitinfoty, nil -> element data
                        const akey: integer): plinkhashdataty;
var
 i1: int32;
begin
 i1:= 0;
 if aunit <> nil then begin
  i1:= punitinfoty(aunit)^.key;
 end;
 result:= pointer(inherited find(i1,akey));
end;

{ tint32bufferhashdatalist }
{
constructor tint32bufferhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize+sizeof(int32bufferdataty));
end;
}
function tint32bufferhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(int32keybufferhashdataty);
end;

function tint32bufferhashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= scramble((integer(akey) xor (integer(akey) shr 2)));
end;

function tint32bufferhashdatalist.checkkey(const akey;
                                    const aitem: phashdataty): boolean;
begin
 result:= integer(akey) = pint32keybufferhashdataty(aitem)^.data.key;
end;

function tint32bufferhashdatalist.addunique(const akey: int32; const adata;
               const size: integer; out res: pkeybufferdataty): boolean;
begin
 result:= addunique(akey,adata,size,res);
end;

{ tconstcache }
{
constructor tconstcache.create();
begin
 inherited create(sizeof(constcachedataty);
end;
}

end.

