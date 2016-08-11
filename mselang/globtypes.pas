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
unit globtypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
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
 dataaddressty = ptruint;
 pdataaddressty = ^dataaddressty;
 pdataoffsty = ^dataoffsty;
 datasizety = ptruint;
 loopcountty = ptrint;
 indirectlevelty = int32;
 framelevelty = int32;

   segmentty = (seg_nil,seg_stack,seg_globvar,seg_globconst,
              seg_op,seg_classdef,seg_rtti,seg_intf,
              seg_localloc,
              seg_classintfcount,seg_intfitemcount,
              seg_unitintf,seg_unitidents,seg_unitlinks,seg_unitimpl);
 segmentsty = set of segmentty;
 
const
 branchkeymaxcount = 4;
 firstident = 256;
 idstart = $12345678;
 storedsegments = [seg_globconst,seg_classdef,seg_op,seg_rtti,seg_intf,
                   seg_classintfcount,seg_intfitemcount];
type
 addressflagty = (af_nil,af_segment,af_local,af_temp,af_param,
                  af_paramindirect,af_const,
                  af_paramconst,af_paramvar,af_paramout, 
                                              //for paramkindty match test
                  af_openarray,
                  af_withindirect,
                  af_classfield,af_stack,af_segmentpo,af_aggregate,
                  af_startoffset, //for indirection
                  af_arrayop //typeallocinfoty.size = count
                  {af_getaddress}
                  );
 addressflagsty = set of addressflagty;

const
 compatibleparamflags = [af_paramconst,af_paramvar,af_paramout];
 addresskindflags = [af_stack,af_local,af_segment,af_aggregate];
 addresscompflags = addresskindflags + [af_nil];

type 
 propflagty = (pof_readfield,pof_readsub,pof_writefield,pof_writesub,
                       pof_default);
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
 niladdress: addressvaluety = (flags: [af_nil]; indirectlevel: 1);

type 
 databitsizety = (das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
                  das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,
                  das_sub,das_meta);
 systypety = (st_none,st_pointer,{st_method,}st_bool1,
              st_int8,st_int16,st_int32,st_int64,
              st_card8,st_card16,st_card32,st_card64,
              st_flo64,
              st_char8,st_char16,st_char32,
              st_string8);
const
 pointersize = sizeof(pointer); //todo: use target size
 pointerbitsize = pointersize*8;
 dataoffssize = das_32;
{$if pointersize = 8}
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
                  das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64];
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
  //das_pointer,das_f16, das_f32, das_f64, das_sub, das_meta);
    ibs_none,   ibs_none,ibs_none,ibs_none,ibs_none,ibs_none
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

 subflagty = (sf_function,sf_method,sf_constructor,sf_destructor,
              sf_functiontype,sf_hasnestedaccess,sf_hasnestedref,sf_hascallout,
              sf_header,sf_forward,sf_external,sf_typedef,sf_ofobject,
              sf_named, //has llvm name
              sf_nolineinfo, //for llvm
              sf_vararg,sf_proto, //for llvm
              sf_virtual,sf_override,sf_interface,
              sf_intfcall); //called by interface
 subflagsty = set of subflagty;
 
 datakindty = (dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,
               dk_kind,
               dk_address,dk_record,dk_string8,dk_dynarray,dk_openarray,
               dk_array,dk_class,dk_interface,dk_sub,dk_method,
               dk_enum,dk_enumitem,dk_set,dk_character,
               dk_data);
 pdatakindty = ^datakindty;

const
 compatiblesubflags = [sf_function,sf_method,sf_constructor,sf_destructor];
 ordinaldatakinds = [dk_boolean,dk_cardinal,dk_integer,dk_enum];
 pointerdatakinds = [dk_pointer,dk_dynarray,{dk_openarray,}
                     dk_interface,dk_class,dk_string8];
 ancestordatakinds = [dk_class];
 ancestorchaindatakinds = [dk_interface];
 stringdatakinds = [dk_string8];
// dynardatakinds = [dk_string8,dk_dynarray];
type
 enumflagty = (enf_contiguous);
 enumflagsty = set of enumflagty;

 typeflagty = (tf_managed,     //field iniproc/finiproc valid in typedataty
               tf_needsmanage, //has nested tf_managed or tf_managed set
               tf_lower,       //in range expression
               tf_upper,       //in range expression
               tf_subad,       //sub address
               tf_subrange
               ); 
 typeflagsty = set of typeflagty;   
 
 typeinfoty = record
  flags: typeflagsty;
  typedata: elementoffsetty;
  indirectlevel: indirectlevelty; //total
 end;
 ptypeinfoty = ^typeinfoty;

 stringflagty = (strf_empty);
 stringflagsty = set of stringflagty;
 
 stringvaluety = record
  offset: ptruint; //offset in string buffer
  flags: stringflagsty;
 // len: databytesizety;
 end;

 enumvaluety = record
  value: integer;
  enum: elementoffsetty;
 end; 

 setvaluety = record
  value: int32;  //todo: use arbitrary size
 // settype: elementoffsetty; //0 for empty set
 end; 

 openarrayvaluety = record
  address: segaddressty;
  size: int32; //byte size
  high: int32; //item count - 1
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
   dk_string8:(
    vstring: stringvaluety;
   );
   dk_character:(
    vcharacter: card32;
   );
   dk_enum:(
    venum: enumvaluety;
   );
   dk_set:(
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
          nco_pointer,nco_method);
 maxconstty = (mco_none = 0,
               mco_i1 = ord(high(nullconstty))+1, mco_i8=255,
                              mco_i16=ord(mco_i1)+1,mco_i32, mco_i64);
 oneconstty = (oco_none = 0,
               oco_i1 = ord(mco_i1), oco_i8=1,
                              oco_i16=ord(high(maxconstty))+1,oco_i32, oco_i64);
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
{$if pointersize = 64}
 sizetype = ord(das_64);
{$else}
 sizetype = ord(das_32);
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
