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

// elementoffsetty = ptrint;
 elementoffsetty = int32; //same size for 64 and 32 bit compilers because of
                          //dump in unit files
 pelementoffsetty = ^elementoffsetty;
 elementoffsetarty = array of elementoffsetty;

 identty = uint32;
 pidentty = ^identty;
 keywordty = identty;
 targetcard = card32;

 indexty = integer;
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
              seg_unitintf,seg_unitidents,seg_unitlinks);
 segmentsty = set of segmentty;
 
const
 storedsegments = [seg_globconst,seg_classdef,seg_op,seg_rtti,seg_intf,
                   seg_classintfcount,seg_intfitemcount];
type
 addressflagty = (af_nil,af_segment,af_local,af_temp,af_param,
                  af_paramindirect,af_const,af_withindirect,
                  af_classfield,af_stack,af_segmentpo,af_aggregate,
                  af_startoffset{, //for indirection
                  af_getaddress}
                  );
 addressflagsty = set of addressflagty;

const
 addresskindflags = [af_local,af_segment,af_aggregate];
 addresscompflags = addresskindflags + [af_nil];

type
 segaddressty = record
  address: dataoffsty; //first, must map poaddress
  segment: segmentty;
  element: elementoffsetty; //for unresoved address
 end;
 
 locaddressty = record
  address: dataoffsty; //first, must map poaddress
  framelevel: integer;
  ssaindex: integer; //for llvm temp var
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
 
 databitsizety = (das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
                  das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,
                  das_sub,das_meta);
 systypety = (st_none,st_pointer,st_bool1,st_int8,st_int16,st_int32,st_int64,
              st_card8,st_card16,st_card32,st_card64,
              st_float64,st_string8);
const
 pointersize = sizeof(pointer); //todo: use target size
 pointerbitsize = pointersize*8;
{$if pointersize = 8}
 ptrcardsystype = st_card64;
 ptrintsystype = st_int64;
 pointerintsize = das_64;
{$else}
 pointerintsize = das_32;
 ptrcardsystype = st_card32;
 ptrintsystype = st_int32;
{$endif} 
 
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
  size: integer;        //bits or bytes
  listindex: integer;
  flags: addressflagsty;
 end; 
 ptypeallocinfoty = ^typeallocinfoty;

 subflagty = (sf_function,sf_method,sf_constructor,sf_destructor,
              sf_functiontype,sf_hasnestedaccess,sf_hasnestedref,sf_hascallout,
              sf_header,sf_external,sf_typedef,
              sf_vararg,sf_proto, //for llvm
              sf_virtual,sf_override,sf_interface,
              sf_intfcall); //called by interface
 subflagsty = set of subflagty;
 
 datakindty = (dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,
               dk_kind,
               dk_address,dk_record,dk_string8,dk_dynarray,
               dk_array,dk_class,dk_interface,dk_sub,
               dk_enum,dk_enumitem,dk_set);
 pdatakindty = ^datakindty;

const
 ordinaldatakinds = [dk_boolean,dk_cardinal,dk_integer];
 pointerdatakinds = [dk_pointer,dk_dynarray,dk_interface,dk_class,dk_string8];
 ancestordatakinds = [dk_class];
 ancestorchaindatakinds = [dk_interface];
type
 enumflagty = (enf_contiguous);
 enumflagsty = set of enumflagty;

 typeflagty = (tf_managed,     //field iniproc/finiproc valid in typedataty
               tf_hasmanaged,  //has nested tf_managed
               tf_lower,       //in range expression
               tf_upper,       //in range expression
               tf_subad        //sub address
               ); 
 typeflagsty = set of typeflagty;   
 
 typeinfoty = record
  flags: typeflagsty;
  typedata: elementoffsetty;
  indirectlevel: indirectlevelty; //total
 end;

 stringvaluety = record
  offset: ptruint; //offset in string buffer
 // len: databytesizety;
 end;

 enumvaluety = record
  value: integer;
  enum: elementoffsetty;
 end; 

 dataty = record
  case kind: datakindty of
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
   
 pendinginfoty = record
  ref: elementoffsetty;
 end;
 pendinginfoarty = array of pendinginfoty;

implementation
end.
