{ MSElang Copyright (c) 2013-2018 by Martin Schreiber
   
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
unit globtypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 __mla__internaltypes;
 
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
 flo32 = single;
 flo64 = double;

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
 ppint32 = ^pint32;
 pint64 = ^int64;
 ppint64 = ^pint64;

// elementoffsetty = ptrint;
 elementoffsetty = int32; //same size for 64 and 32 bit compilers because of
                          //dump in unit files
 elementsizety = uint32;
 
 pelementoffsetty = ^elementoffsetty;
 elementoffsetarty = array of elementoffsetty;

 identty = uint32;
 pidentty = ^identty;
 keywordty = identty;
 targetcardty = card32;
 targetadty = card32;
 targetoffsty = int32;
 targetsizety = int32;

 indexty = int32;
 linkindexty = indexty;
 forwardindexty = indexty;

 listadty = longword;

 dataoffsty = int32;

 opaddressty = ptruint;         //todo: use target size
 popaddressty = ^opaddressty;
 dataaddressty = ptruint;       //todo: use target size
 pdataaddressty = ^dataaddressty;
 pdataoffsty = ^dataoffsty;
 datasizety = ptruint;
 loopcountty = ptrint;
 indirectlevelty = int32;
 framelevelty = int32;

 segmentty = ({seg_constdef,}seg_classdef,
              seg_nil,seg_stack,seg_globvar,seg_globconst,
              seg_reloc,
              seg_op,{seg_classdef,}seg_rtti,seg_intf,
              seg_localloc,
              {seg_classintfcount,}seg_intfitemcount,
              seg_unitintf,seg_unitidents,seg_unitlinks,seg_unitimpl,
              seg_unitconstbuf,
              seg_temp,
              seg_llvmconst);
const
 lastdatasegment = seg_temp;
type
 segmentsty = set of segmentty;
 unitsegmentty = low(segmentty)..seg_classdef;
 
 sourceinfoty = record
  po: pchar;
  line: integer;
 end;

const
 branchkeymaxcount = 4;
 noident = 0;
 firstident = 256;
// idstart = $12345678;
 idstart = firstident;
 storedsegments = [seg_globconst,seg_reloc,seg_classdef,seg_op,seg_rtti,
                   seg_intf,{seg_classintfcount,}seg_intfitemcount,
                   seg_unitconstbuf];
type
 dataflagty = (df_typeconversion,df_setelement);
 dataflagsty = set of dataflagty;
 
 addressflagty = (af_nil,af_segment,af_local,af_stacktemp,af_tempvar,
                  af_external,
                  af_ssas2, 
                          //use par.ssas2 instead of tempdataaddress.a.ssaindex
                  af_managedtemp,
                  af_param,af_paramindirect,af_const,af_resultvar,
                  af_paramconst,af_paramconstref,af_paramvar,af_paramout, 
                                              //for paramkindty match test
                  af_self,
//                  af_managedtemp,
                  af_openarray,af_listitem,af_vararg,
                  af_withindirect,
                  af_classfield,af_objectfield,
                  af_classele, //found by class method
                  af_stack,af_segmentpo,af_aggregate,
                  af_startoffset, //for indirection
                  af_nostartoffset, //was af_paramindirect,af_withindirect
                  af_dereferenced,
                  af_arrayop, //typeallocinfoty.size = count
                  af_untyped  //for array of const
                  {af_getaddress}
                  );
 addressflagsty = set of addressflagty;

const
 compatibleparamflags = [af_paramconst,af_paramconstref,af_paramvar,
                                                              af_paramout];
 addresskindflags = [af_stack,af_local,af_segment,af_aggregate];
 addresscompflags = addresskindflags + [af_nil];

type 
 propflagty = (pof_class,
               pof_readfield,pof_readsub,
               pof_writefield,pof_writesub,
               pof_default,
               pof_indexvalid,pof_readforward,pof_writeforward);
 propflagsty = set of propflagty;
const
 canreadprop = [pof_readfield,pof_readsub];
 canwriteprop = [pof_writefield,pof_writesub];

type
 segaddressty = record
  address: dataoffsty; //first, must map poaddress
  segment: segmentty;
  element: elementoffsetty; //for unresoved address
 end;
 
 locaddressty = record
  address: dataoffsty; //first, must map poaddress
  framelevel: integer;
 end;
 
 tempaddressty = record
  address: dataoffsty; //first, must map poaddress
  ssaindex: int32; //for llvm temp var 
 end;
  
 addressvaluety = record
  flags: addressflagsty;
  indirectlevel: indirectlevelty;
  case integer of
   0: (poaddress: dataoffsty);
   1: (segaddress: segaddressty);
   2: (locaddress: locaddressty);
   3: (tempaddress: tempaddressty);
 end;
 paddressvaluety = ^addressvaluety;
const
 niladdress: addressvaluety = (flags: [af_nil]; indirectlevel: 1;
                                                       poaddress: 0);

type 
 databitsizety = (das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
                  das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,
                  das_bigint, //size variable
                  das_sub,das_meta);
 systypety = (st_none,st_nil,st_forward,
              st_pointer,{st_method,}st_bool1,
              st_int8,st_int16,st_int32,st_int64,st_intpo,
              st_card8,st_card16,st_card32,st_card64,st_cardpo,
              st_flo32,st_flo64,
              st_char8,st_char16,st_char32,
              st_bytestring,st_string8,st_string16,st_string32);
const
 firstrealsystype = st_pointer;
 simpledatasizes = [das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
                  das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64];
 targetpointersize = sizeof(pointer); //todo: use target size
 targetpointerbitsize = targetpointersize*8;
 dataoffssize = das_32;
{$if targetpointersize = 8}
 ptrcardsystype = st_card64;
 ptrintsystype = st_int64;
 pointerintsize = das_64;
 target64 = true;
 target32 = false;
type
 targetptrint = int64;
{$else}
 pointerintsize = das_32;
 ptrcardsystype = st_card32;
 ptrintsystype = st_int32;
 target64 = false;
 target32 = true;
type
 targetptrint = int32;
{$endif} 
const
 lastdatakind = das_f64;
 alldatakinds = [das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
               das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,das_bigint];
 databytesizes = [das_none];
 byteopdatakinds = databytesizes;
 bitopdatakinds = alldatakinds-byteopdatakinds;
 floatopdatakinds = [das_f16,das_f32,das_f64];
 ordinalopdatakinds = bitopdatakinds-floatopdatakinds;

type
 intbitsizety = (ibs_none,ibs_8,ibs_16,ibs_32,ibs_64);

const
 intbits: array[databitsizety] of intbitsizety = (
  //das_none, das_1,   das_2_7, das_8,das_9_15,das_16,das_17_31,
    ibs_none, ibs_none,ibs_none,ibs_8,ibs_none,ibs_16,ibs_none,
  //das_32,das_33_63,das_64,
    ibs_32,ibs_none, ibs_64,
  //das_pointer,das_f16, das_f32, das_f64,das_bigint, das_sub, das_meta);
    ibs_none,   ibs_none,ibs_none,ibs_none,ibs_none,  ibs_none,ibs_none
 );

type
 typeallocinfoty = record
  kind: databitsizety;
  size: integer;        //bits or bytes, count for array managed ops,
                        //high for openarray conversion
  listindex: integer;
  flags: addressflagsty;
 end; 
 ptypeallocinfoty = ^typeallocinfoty;

 subflagty = (sf_functionx,sf_functioncall,//result not by pointer
              sf_method,sf_classmethod,sf_class,
              sf_constructor,sf_destructor,
              sf_methodtoken,sf_subtoken,sf_operator,sf_operatorright,
              sf_functiontype,sf_hasnestedaccess,sf_hasnestedref,sf_hascallout,
              sf_header,sf_forward,sf_external,sf_typedef,sf_ofobject,
              sf_overload,
              sf_named, //has llvm name
              sf_nolineinfo, //for llvm
              sf_vararg,sf_proto, //for llvm
              sf_virtual,sf_abstract,sf_override,sf_interface,
//              sf_intfcall, //called by interface
              sf_hasmanagedparam,
              sf_intrinsic,sf_noimplicitexception);
 subflagsty = set of subflagty;

 subflag1ty = (sf1_intfcall, //called by interface
               //object sub attachments
               sf1_ini,sf1_fini,sf1_afterconstruct,sf1_new,sf1_dispose,
               sf1_beforedestruct,sf1_incref,sf1_decref,
              {sf1_params,}sf1_default //for destructor
              );
 subflags1ty = set of subflag1ty;

 datakindty = (dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,
               dk_kind,
               dk_address,dk_record,dk_string,
               dk_dynarray,dk_openarray,dk_array,
               dk_object,dk_objectpo,dk_class,dk_interface,
               dk_classof,
               dk_sub,dk_method,
               dk_enum,dk_enumitem,dk_set,{dk_bigset,}
               dk_character,
               dk_data);
 pdatakindty = ^datakindty;
 
const
 compatiblesubflags = [sf_functionx,
                       sf_method,sf_class,sf_constructor,sf_destructor];
 ordinaldatakinds = [dk_boolean,dk_cardinal,dk_integer,dk_enum];
 rangedatakinds = ordinaldatakinds + [dk_character];
 arrayindexdatakinds = rangedatakinds;
 numericdatakinds = [dk_cardinal,dk_integer,dk_float];
 pointerdatakinds = [dk_pointer,dk_dynarray,{dk_openarray,}
                     dk_interface,dk_class,dk_string];
 nilpointerdatakinds = pointerdatakinds+[dk_sub];
 structdatakinds = [dk_array,dk_dynarray,dk_record,
                                    dk_object,dk_class,dk_method];
 ancestordatakinds = [dk_object,dk_class];
 ancestorchaindatakinds = [dk_interface];
 stringdatakinds = [dk_string];
// dynardatakinds = [dk_string8,dk_string16.dk_string32,dk_dynarray];
type
 enumflagty = (enf_contiguous,enf_ascending);
 enumflagsty = set of enumflagty;

 typeflagty = (tf_managed,     //field iniproc/finiproc valid in typedataty
               tf_needsmanage, //has nested tf_managed or tf_managed set
               tf_needsini,tf_hascomplexini,tf_complexini,tf_needsfini,
               tf_managehandlervalid,
               tf_lower,       //in range expression
               tf_upper,       //in range expression
               tf_subad,       //sub address
               tf_method,      //method
               tf_subrange,tf_derefop,tf_typeconversion,tf_resource,
               tf_untyped,tf_forward,tf_sizeinvalid,tf_canforward,
               tf_classdef, //dk_class,dk_object acually is a classdef pointer
               tf_rtti
               ); 
 typeflagsty = set of typeflagty;   
const
 managedtypeflags = [tf_managed,tf_needsmanage,tf_needsini,
                     tf_hascomplexini,tf_complexini,
                     tf_needsfini];
type
 typeinfoty = record
  flags: typeflagsty;
  typedata: elementoffsetty;
  indirectlevel: indirectlevelty; //total
  forwardident: identty;
 end;
 ptypeinfoty = ^typeinfoty;

 stringflagty = (strf_empty,strf_16,strf_32,strf_set,strf_ele,strf_address);
 stringflagsty = set of stringflagty;
 
 stringvaluety = record
  offset: int32; //stringbufhashdataty offset in string buffer or
                 //ele offs for constdef if strf_ele is set
  flags: stringflagsty;
 // len: databytesizety;
 end;
 pstringvaluety = ^stringvaluety;

 enumvaluety = record
  value: int32;
  enum: elementoffsetty;
 end; 

 setvaluety = record
  min,max: int32;
  case kind: databitsizety of
   das_8,das_16,das_32:(
    setvalue: int32;
   );
   das_bigint:(
    bigsetvalue: stringvaluety; //strf_empty -> empty set, offset = bitcount
   );
 end;
 psetvaluety = ^setvaluety;

 openarrayvaluety = record
  address: segaddressty;
  size: int32; //byte size
  high: int32; //item count - 1
  itemkind: datakindty;
 end;
  
 dataty = record
  case kind: datakindty of
   dk_none:(
    vdummy: record
    end;
   );
   dk_boolean:(
    vboolean: bool8;
   );
   dk_integer:(
    vinteger: int64;
   );
   dk_cardinal:(
    vcardinal: card64;
   );
   dk_float:(
    vfloat: flo64;
   );
   dk_address,dk_pointer,dk_method:(
    vaddress: addressvaluety;
   {
    case datakindty of
     dk_method: begin
      vinstance:
     end;
   }
   );
   dk_string:(
    vstring: stringvaluety;
   );
   dk_character:(
    vcharacter: card32;
   );
   dk_enum:(
    venum: enumvaluety;
   );
   dk_set{,dk_bigset}:(
    vset: setvaluety;
   );
   dk_openarray:(
    vopenarray: openarrayvaluety;
   );
 end;

 datainfoty = record
  typ: typeinfoty;
  d: dataty;
 end;
   
 pendinginfoty = record
  ref: elementoffsetty;
 end;
 pendinginfoarty = array of pendinginfoty;

 filematchinfoty = record
  timestamp: tdatetime;
  guid: tguid;
 end;

 contexthandlerty = procedure({const info: pparseinfoty});

 branchflagty = (bf_nt,bf_emptytoken,
             bf_keyword,bf_handler,
             bf_nostartbefore,bf_nostartafter,bf_eat,bf_push,
             {bf_setpc,}bf_continue,
             bf_setparentbeforepush,bf_setparentafterpush,
             bf_changeparentcontext
             );
 branchflagsty = set of branchflagty;

 charsetty = set of char;
 charset32ty = array[0..7] of uint32;
 branchkeykindty = (bkk_none,bkk_char,bkk_charcontinued);
 
 branchkeyinfoty = record
  case kind: branchkeykindty of
   bkk_char,bkk_charcontinued: (
    chars: charsetty;
   );
 end;

type  
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
                         //llvm lists
const
 maxpointeroffset = 32; //preallocated pointeroffset values
 nullpointeroffset = high(card8)+1; //constlist index

type 
 nullconstty = (nco_none = 0,
          nco_i1 = 256+maxpointeroffset+1, nco_i8, nco_i16, nco_i32, nco_i64,
          nco_f32,nco_f64,
          nco_pointer,nco_method);
 maxconstty = (mco_none = 0,
               mco_i1 = ord(high(nullconstty))+1, mco_i8=255,
                          mco_i16=ord(mco_i1)+1, mco_i32, mco_i64);
 oneconstty = (oco_none = 0,
               oco_i1 = ord(mco_i1), oco_i8=1,
                          oco_i16=ord(high(maxconstty))+1, oco_i32, oco_i64,
                          oco_f32,oco_f64);
 ashrconstty = (asco_none = 0,
               asco_i1 = ord(nco_i1), asco_i8=7,
                          asco_i16=ord(high(oneconstty))+1, asco_i32, asco_i64);
 pointeroffsetconstty = 
       (poc_0=256,poc_1,poc_2,poc_3,poc_4,poc_5,poc_6,poc_7,poc_8,poc_9,
        poc_10,poc_11,poc_12,poc_13,poc_14,poc_15,poc_16,poc_17,poc_18,poc_19,
        poc_20,poc_21,poc_22,poc_23,poc_24,poc_25,poc_26,poc_27,poc_28,poc_29,
        poc_30,poc_31,poc_32);

 llvmvaluety = record
  typeid: int32;        //order fix because of metadata bcwriter
  listid: int32;        //
 end;

const
 bittypemax = ord(lastdatakind);
 voidtype = ord(das_none);
 pointertype = ord(das_pointer);
 methodtype = bittypemax+1;
 bytetype = ord(das_8);
 inttype = ord(das_32);
{$if targetpointersize = 64}
 sizetype = ord(das_64);
 pointerintnull = nco_i64;
{$else}
 sizetype = ord(das_32);
 pointerintnull = nco_i32;
{$endif}
 floattype = ord(das_f64);

 nullpointer = ord(nco_pointer);
 nullconst: llvmvaluety = (
             typeid: pointertype;
             listid: nullpointer;
            ); 
 nullmethod = ord(nco_method);
 nullmethodconst: llvmvaluety = (
             typeid: methodtype;
             listid: nullmethod;
            ); 

type
 metavalueflagty = (mvf_globval,mvf_pointer,mvf_meta,mvf_dummy);
 metavalueflagsty = set of metavalueflagty;
 
 metavaluety = record
  id: int32;             //-1 -> none
//  value: llvmvaluety;
 // flags: metavalueflagsty;
 end;
 pmetavaluety = ^metavaluety;
 metavaluearty = array of metavaluety;
 
 metavaluesty = record
  count: int32;
  data: metavaluearty;
 end;

implementation
end.
