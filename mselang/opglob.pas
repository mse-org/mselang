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
unit opglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,msestrings;
 
type
 addressbasety = (ab_segment,ab_frame,ab_reg0,ab_stack,ab_stackref);
 addressrefty = record
  offset: dataoffsty;
  case base: addressbasety of
   ab_segment: (segment: segmentty);
 end;

 globallocinfoty = record
  a: segaddressty;
  size: typeallocinfoty;
 end;
 pgloballocinfoty = ^globallocinfoty;

 locallocinfoty = record
//  a: addressvaluety;
  flags: addressflagsty;
  address: dataoffsty;
  size: typeallocinfoty;
 end;
 plocallocinfoty = ^locallocinfoty;
 
 parallocinfoty = record
  ssaindex: integer;
  size: typeallocinfoty;
 end;
 pparallocinfoty = ^parallocinfoty;

 nestedaddressty = record
  arrayoffset: dataoffsty;
  origin: dataoffsty;
  datatype: typeallocinfoty;
  nested: boolean;     //ref to neseted frame
 end;
 
 nestedallocinfoty = record
  address: nestedaddressty;
 end;
 pnestedallocinfoty = ^nestedallocinfoty;
  
 opprocty = procedure;

 op1infoty = record
  index0: integer;
 end;
{
 opninfoty = record
  paramcount: integer;
 end;
}
 opcodety = (        //order like optable.inc
  oc_none,
  oc_nop,

  oc_label,          //controlops
  oc_if,
  oc_while,
  oc_until,
  oc_decloop32,
  oc_decloop64,

  oc_raise,         //callops

  oc_call,
  oc_callfunc,
  oc_callout,
  oc_callfuncout,
  oc_callvirt,
  oc_callintf,
  oc_virttrampoline,

  oc_callindi,
  oc_callfuncindi,

  oc_initclass,
  oc_destroyclass,

  oc_beginparse,
  oc_main,
  oc_progend,
  oc_endparse,
  oc_halt,
  
  oc_movesegreg0,
  oc_moveframereg0,
  oc_popreg0,
  oc_increg0,

  oc_goto,
  oc_cmpjmpneimm4,
  oc_cmpjmpeqimm4,
  oc_cmpjmploimm4,
  oc_cmpjmpgtimm4,
  oc_cmpjmploeqimm4,

  
  oc_writeln,
  oc_writeboolean,
  oc_writecardinal,
  oc_writeinteger,
  oc_writefloat,
  oc_writestring8,
  oc_writepointer,
  oc_writeclass,
  oc_writeenum,

  oc_push,
  oc_pop,

  oc_pushimm1,
  oc_pushimm8,
  oc_pushimm16,
  oc_pushimm32,
  oc_pushimm64,
  oc_pushimmdatakind,
  
  oc_int32toflo64,
  oc_potoint32,
  oc_inttopo,

  oc_and1,
  oc_and32,
  oc_or1,
  oc_or32,
  
  oc_shl32,
  oc_shr32,
//  oc_shrint32,
  
  oc_card8tocard16,oc_card8tocard32,oc_card8tocard64,
  oc_card16tocard8,oc_card16tocard32,oc_card16tocard64,
  oc_card32tocard8,oc_card32tocard16,oc_card32tocard64,
  oc_card64tocard8,oc_card64tocard16,oc_card64tocard32,

  oc_int8toint16,oc_int8toint32,oc_int8toint64,
  oc_int16toint8,oc_int16toint32,oc_int16toint64,
  oc_int32toint8,oc_int32toint16,oc_int32toint64,
  oc_int64toint8,oc_int64toint16,oc_int64toint32,

  oc_card8toint8,oc_card8toint16,oc_card8toint32,oc_card8toint64,
  oc_card16toint8,oc_card16toint16,oc_card16toint32,oc_card16toint64,
  oc_card32toint8,oc_card32toint16,oc_card32toint32,oc_card32toint64,
  oc_card64toint8,oc_card64toint16,oc_card64toint32,oc_card64toint64,

  oc_int8tocard8,oc_int8tocard16,oc_int8tocard32,oc_int8tocard64,
  oc_int16tocard8,oc_int16tocard16,oc_int16tocard32,oc_int16tocard64,
  oc_int32tocard8,oc_int32tocard16,oc_int32tocard32,oc_int32tocard64,
  oc_int64tocard8,oc_int64tocard16,oc_int64tocard32,oc_int64tocard64,

  oc_not1,
  oc_not32,
  
  oc_negcard32,
  oc_negint32,
  oc_negflo64,

  oc_mulcard32,
  oc_mulint32,
  oc_mulflo64,
  oc_addint32,
  oc_subint32,
  oc_addpoint32,
  oc_subpo,
  oc_addflo64,
  oc_subflo64,

  oc_addimmint32,
  oc_mulimmint32,
  oc_offsetpoimm32,

  oc_incdecsegimmint32,
  oc_incdecsegimmpo32,

  oc_incdeclocimmint32,
  oc_incdeclocimmpo32,

  oc_incdecparimmint32,
  oc_incdecparimmpo32,

  oc_incdecparindiimmint32,
  oc_incdecparindiimmpo32,

  oc_incdecindiimmint32,
  oc_incdecindiimmpo32,

  oc_incsegint32,
  oc_incsegpo32,

  oc_inclocint32,
  oc_inclocpo32,

  oc_incparint32,
  oc_incparpo32,

  oc_incparindiint32,
  oc_incparindipo32,

  oc_incindiint32,
  oc_incindipo32,

  oc_decsegint32,
  oc_decsegpo32,

  oc_declocint32,
  oc_declocpo32,

  oc_decparint32,
  oc_decparpo32,

  oc_decparindiint32,
  oc_decparindipo32,

  oc_decindiint32,
  oc_decindipo32,

  oc_cmpeqpo,
  oc_cmpeqbool,
  oc_cmpeqint32,
  oc_cmpeqflo64,

  oc_cmpnepo,
  oc_cmpnebool,
  oc_cmpneint32,
  oc_cmpneflo64,

  oc_cmpgtpo,
  oc_cmpgtbool,
  oc_cmpgtcard32,
  oc_cmpgtint32,
  oc_cmpgtflo64,

  oc_cmpltpo,
  oc_cmpltbool,
  oc_cmpltcard32,
  oc_cmpltint32,
  oc_cmpltflo64,

  oc_cmpgepo,
  oc_cmpgebool,
  oc_cmpgecard32,
  oc_cmpgeint32,
  oc_cmpgeflo64,

  oc_cmplepo,
  oc_cmplebool,
  oc_cmplecard32,
  oc_cmpleint32,
  oc_cmpleflo64,

  oc_storesegnil,
  oc_storereg0nil,
  oc_storeframenil,
  oc_storestacknil,
  oc_storestackrefnil,
  oc_storesegnilar,
  oc_storeframenilar,
  oc_storereg0nilar,
  oc_storestacknilar,
  oc_storestackrefnilar,

  oc_finirefsizeseg,
  oc_finirefsizeframe,
  oc_finirefsizereg0,
  oc_finirefsizestack,
  oc_finirefsizestackref,
  oc_finirefsizeframear,
  oc_finirefsizesegar,
  oc_finirefsizereg0ar,
  oc_finirefsizestackar,
  oc_finirefsizestackrefar,

  oc_increfsizeseg,
  oc_increfsizeframe,
  oc_increfsizereg0,
  oc_increfsizestack,
  oc_increfsizestackref,
  oc_increfsizeframear,
  oc_increfsizesegar,
  oc_increfsizereg0ar,
  oc_increfsizestackar,
  oc_increfsizestackrefar,

  oc_decrefsizeseg,
  oc_decrefsizeframe,
  oc_decrefsizereg0,
  oc_decrefsizestack,
  oc_decrefsizestackref,
  oc_decrefsizeframear,
  oc_decrefsizesegar,
  oc_decrefsizereg0ar,
  oc_decrefsizestackar,
  oc_decrefsizestackrefar,

  oc_popseg8,
  oc_popseg16,
  oc_popseg32,
  oc_popseg64,
  oc_popsegpo,
  oc_popsegf16,
  oc_popsegf32,
  oc_popsegf64,
  oc_popseg,

  oc_poploc8,
  oc_poploc16,
  oc_poploc32,
  oc_poploc64,
  oc_poplocpo,
  oc_poplocf16,
  oc_poplocf32,
  oc_poplocf64,
  oc_poploc,

  oc_poplocindi8,
  oc_poplocindi16,
  oc_poplocindi32,
  oc_poplocindi64,
  oc_poplocindipo,
  oc_poplocindif16,
  oc_poplocindif32,
  oc_poplocindif64,
  oc_poplocindi,

  oc_poppar8,
  oc_poppar16,
  oc_poppar32,
  oc_poppar64,
  oc_popparpo,
  oc_popparf16,
  oc_popparf32,
  oc_popparf64,
  oc_poppar,

  oc_popparindi8,
  oc_popparindi16,
  oc_popparindi32,
  oc_popparindi64,
  oc_popparindipo,
  oc_popparindif16,
  oc_popparindif32,
  oc_popparindif64,
  oc_popparindi,

  oc_pushnil,
//  oc_pushsegaddress,

  oc_pushseg8,
  oc_pushseg16,
  oc_pushseg32,
  oc_pushseg64,
  oc_pushsegpo,
  oc_pushsegf16,
  oc_pushsegf32,
  oc_pushsegf64,
  oc_pushseg,

  oc_pushloc8,
  oc_pushloc16,
  oc_pushloc32,
  oc_pushloc64,
  oc_pushlocpo,
  oc_pushlocf16,
  oc_pushlocf32,
  oc_pushlocf64,
  oc_pushloc,

  oc_pushlocindi8,
  oc_pushlocindi16,
  oc_pushlocindi32,
  oc_pushlocindi64,
  oc_pushlocindipo,
  oc_pushlocindif16,
  oc_pushlocindif32,
  oc_pushlocindif64,
  oc_pushlocindi,

  oc_pushpar8,
  oc_pushpar16,
  oc_pushpar32,
  oc_pushpar64,
  oc_pushparpo,
  oc_pushparf16,
  oc_pushparf32,
  oc_pushparf64,
  oc_pushpar,

  oc_pushaddr,
  oc_pushlocaddr,
//  oc_pushlocaddrindi,
  oc_pushsegaddr,
//  oc_pushsegaddrindi,
  oc_pushstackaddr,
//  oc_pushstackaddrindi,

  oc_pushduppo,
  
  oc_indirect8,
  oc_indirect16,
  oc_indirect32,
  oc_indirect64,
  oc_indirectpo,
  oc_indirectf16,
  oc_indirectf32,
  oc_indirectf64,
  oc_indirectpooffs, //offset after indirect
  oc_indirectoffspo, //offset before indirect
  oc_indirect,

  oc_popindirect8,
  oc_popindirect16,
  oc_popindirect32,
  oc_popindirect64,
  oc_popindirectpo,
  oc_popindirectf16,
  oc_popindirectf32,
  oc_popindirectf64,
  oc_popindirect,

  oc_locvarpush,
  oc_locvarpop,

  oc_subbegin,
  oc_subend,
  oc_externalsub,
  oc_return,
  oc_returnfunc,

  oc_setlengthstr8,
  oc_setlengthdynarray,

  oc_pushcpucontext,
  oc_popcpucontext,
  oc_finiexception,
  oc_continueexception,
  
  oc_getmem,
  oc_getzeromem,
  oc_freemem,
  oc_setmem,

  oc_lineinfo,
    
//ssaonly
  ocssa_nestedvar,
  ocssa_popnestedvar,
//  ocssa_popsegaggregate,
  ocssa_pushnestedvar,  //per item
  ocssa_aggregate,
  ocssa_alloc,          //per item
  ocssa_nestedcallout,  //per level
  ocssa_hascallout,

  ocssa_pushsegaddrnil,
  ocssa_pushsegaddrglobvar,
  ocssa_pushsegaddrglobconst,
  ocssa_pushsegaddrclassdef
 );

 v8ty = array[0..0] of byte;
 pv8ty = ^v8ty;
 ppv8ty = ^pv8ty;
 v16ty = array[0..1] of byte;
 pv16ty = ^v16ty;
 ppv16ty = ^pv16ty;
 v32ty = array[0..3] of byte;
 pv32ty = ^v32ty;
 ppv32ty = ^pv32ty;
 v64ty = array[0..7] of byte;
 pv64ty = ^v64ty;
 ppv64ty = ^pv64ty;

   //todo: simplify nested procedure link handling

 virtcallinfoty = record
  selfinstance: dataoffsty; //stackoffset
  virtoffset: dataoffsty;   //offset in classdefinfoty
  typeid: int32; //for llvm
 end;
 
 indicallinfoty = record
  calladdr: dataoffsty; //stackoffset
  typeid: int32; //for llvm
 end;

 callinfoty = record
  ad: opaddressty;    //first!
  flags: subflagsty;
  linkcount: integer; //used in "for downto 0"
  params: dataoffsty;
  paramcount: integer;
  case opcodety of
   oc_callvirt,oc_callintf:(
    virt: virtcallinfoty;
   );
   oc_callindi,oc_callfuncindi:(
    indi: indicallinfoty;
   );
 end; 

 intfcallinfoty = record
  selfinstance: dataoffsty; 
    //stackoffset, points to interface item in obj instance.
  subindex: integer;   //sub item in interface list
 end;
  
 initclassinfoty = record
//  selfinstance: dataoffsty; //stackoffset
  classdef: dataoffsty;
//  result: dataoffsty;   //stackoffset to result pointer
 end;

 destroyclassinfoty = record
  selfinstance: dataoffsty; //stackoffset
 end;
  llvmconstty = record
   typeid: int32;        //order fix because of metadata bcwriter
   listid: int32;        //
  end;
  immty = record
//   ssaindex: integer;
   datasize: integer;            //todo: remove, not necessary for bitcode
   case integer of               //todo: use target size
    0: (llvm: llvmconstty);
    1: (vboolean: boolean);
    2: (vcard8: card8);
    3: (vcard16: card16);
    4: (vcard32: card32);
    5: (vcard64: card64);
    6: (vint8: int8);
    7: (vint16: int16);
    8: (vint32: int32);
    9: (vint64: int64);
   10: (vfloat64: float64);
   11: (vsize: datasizety);
   12: (vpointer: dataaddressty);
   13: (voffset: dataoffsty);
   14: (vdatakind: datakindty);
 end;  

 ordimmty = record
  case integer of
   1: (vboolean: boolean);
   2: (vcard32: card32);
   3: (vint32: int32);
 end;

 segdataaddressty = record
  a: segaddressty;
  offset: dataoffsty;
//  datasize: integer;         //>0 = bits, 0 = pointer, <0 = bytes
 end;
   
 locdataaddressty = record
  a: locaddressty;
  offset: dataoffsty;
 end;
{ 
 vpushty = record
  ssaindex: integer;
  case opcodety of
   oc_push8:(
    v8: v8ty;
   );
   oc_push16:(
    v16: v16ty;
   );
   oc_push32:(
    v32: v32ty;
   );
   oc_push64:(
    v64: v64ty;
   );
   oc_pushdatakind:(
    vdatakind: datakindty;
   );
 end;
} 
 beginparseinfoty = record
//  globallocstart: segaddressty;
//  globalloccount: integer;
  unitinfochain: elementoffsetty;
  exitcodeaddress: segaddressty;
  mainad: opaddressty;
  finisub: opaddressty; //0 -> none
 end;  

 stackopty = record
  t: typeallocinfoty;
 end;
{
 stackimmopty = record
  t: typeallocinfoty;
  case opcodety of
   oc_incdecindimmint32,oc_incdecindimmpo32:(
    vint32: int32;
   );
 end;
}
 memopty = record
  t: typeallocinfoty;
//  ssaindex: integer;
  case opcodety of
   oc_poploc8,oc_poploc16,oc_poploc32,oc_poploc,
   oc_poppar8,oc_poppar16,oc_poppar32,oc_poppar,
   oc_poplocindi8,oc_poplocindi16,oc_poplocindi32,oc_poplocindi,
   oc_pushloc8,oc_pushloc16,oc_pushloc32,oc_pushlocpo,oc_pushloc,
   oc_pushlocindi8,oc_pushlocindi16,oc_pushlocindi32,oc_pushlocindi:(
    locdataaddress: locdataaddressty;
   );
   oc_storesegnilar,
   oc_popseg8,oc_popseg16,oc_popseg32,oc_popseg,
   oc_pushseg8,oc_pushseg16,oc_pushseg32,oc_pushseg,
   oc_pushsegaddr,{oc_pushsegaddrindi,}
   oc_finirefsizesegar,oc_increfsizesegar,oc_decrefsizesegar:(
    segdataaddress: segdataaddressty;
   );
   oc_storeframenilar,oc_storereg0nilar,oc_storestacknilar,
   oc_storestackrefnilar,oc_finirefsizeframear,oc_finirefsizereg0ar,
   oc_finirefsizestackar,oc_finirefsizestackrefar,oc_increfsizeframear,
   oc_increfsizereg0ar,oc_increfsizestackar,oc_increfsizestackrefar,
   oc_decrefsizeframear,oc_decrefsizereg0ar,oc_decrefsizestackar,
   oc_decrefsizestackrefar:(
    podataaddress: dataaddressty;
   );
 end;

 memimmopty = record
  mem: memopty;
  case opcodety of
   oc_none:(
    llvm: llvmconstty;
   );
   oc_incdecsegimmint32,oc_incdecsegimmpo32,
   oc_incdeclocimmint32,oc_incdeclocimmpo32,
   oc_incdecparimmint32,oc_incdecparimmpo32,
   oc_incdecparindiimmint32,oc_incdecparindiimmpo32,
   oc_incdecindiimmint32,oc_incdecindiimmpo32:(
    vint32: int32;
   );
 end;
 
 setlengthty = record
  itemsize: integer;
 end;
 
 suballocinfoty = record
  allocs: dataoffsty;
  alloccount: int32;
  paramcount: int32;
  nestedallocs: dataoffsty;
  nestedalloccount: int32;
  nestedallocstypeindex: int32;
//  parallocs: dataoffsty;
//  paralloccount: integer;
//  varallocs: dataoffsty;
//  varalloccount: integer;
 end;

const
 nullallocs: suballocinfoty = (
  allocs: 0;
  alloccount: 0;
  paramcount: 0;
  nestedallocs: 0;
  nestedalloccount: 0;
  nestedallocstypeindex: -1;
);
 
type
 virttrampolineinfoty = record
  selfinstance: dataoffsty; //frameoffset
  virtoffset: dataoffsty;   //offset in classdefinfoty
  typeid: int32;
 end;
 
 subbegininfoty = record
  flags: subflagsty;
  allocs: suballocinfoty;
  blockcount: int32;
 end;

 subbeginty = record
  subname: opaddressty;
  globid: int32;
  case integer of
   0: (sub: subbegininfoty);
   1: (trampoline: virttrampolineinfoty);
 end;

 subendty = record
  flags: subflagsty;
  allocs: suballocinfoty;
 end;

 returnfuncinfoty = record
  flags: subflagsty;
  allocs: suballocinfoty;
 end;

 debuglocty = record
  line: int32;  //llvm constlistid
  col: int32;   //llvm constlistid
  scope: int32; //llvm file
 end;
 
 lineinfoty = record
//  line: lstringty;
  loc: debuglocty;
//  nr: integer;
 end;

 labty = record
  opaddress: opaddressty; //first! dummy for oc_label 
  bbindex: int32;         //llvm basic block
 end;
 
 mainty = record
  blockcount: int32;
 end;

const
 controlops = [
  oc_label,
  oc_goto,
  oc_if,
  oc_while,
  oc_until,
  oc_decloop32,
  oc_decloop64];

 callops = [
  oc_raise,
  oc_writeln,
  oc_writeboolean,
  oc_writecardinal,
  oc_writeinteger,
  oc_writefloat,
  oc_writestring8,
  oc_writepointer,
  oc_writeclass,
  oc_writeenum,
  oc_call,
  oc_callfunc,
  oc_callout,
  oc_callfuncout,
  oc_callvirt,
  oc_callintf,
  oc_virttrampoline,

  oc_callindi,
  oc_callfuncindi,

  oc_initclass,
  oc_destroyclass
 ];

type
                 //todo: unify, variable size
 opparamty = record
  ssad: int32;
  ssas1: int32;
  ssas2: int32;
  case opcodety of 
   oc_label,oc_goto,oc_if,oc_while,oc_until,
   oc_decloop32,oc_decloop64, //controlops
   oc_pushcpucontext,oc_popcpucontext:(
    opaddress: labty; //first!
   );   
   oc_setmem: (
    ssas3: int32;
   );
   oc_beginparse: (
    beginparse: beginparseinfoty;
   );
   oc_none,oc_nop: (
    dummy: record
    end;
   );
   oc_main: (
    main: mainty;
   );
   oc_push,
   oc_pushimm1,oc_pushimm8,oc_pushimm16,oc_pushimm32,oc_pushimm64,
   oc_pushimmdatakind,
   oc_pushaddr,
   oc_increg0,oc_mulimmint32,oc_addimmint32,oc_offsetpoimm32,
   oc_pop: (
    imm: immty;
   );
   oc_incdecsegimmint32,oc_incdecsegimmpo32,
   oc_incdeclocimmint32,oc_incdeclocimmpo32,
   oc_incdecparimmint32,oc_incdecparimmpo32,
   oc_incdecparindiimmint32,oc_incdecparindiimmpo32,
   oc_incdecindiimmint32,oc_incdecindiimmpo32:(
    memimm: memimmopty;
   );
  
   oc_cmpjmpneimm4,oc_cmpjmpeqimm4,oc_cmpjmploimm4,oc_cmpjmploeqimm4,
   oc_cmpjmpgtimm4: (
    ordimm: ordimmty;
    immgoto: opaddressty
   );
   oc_movesegreg0:(
    vsegment: segmentty;
   );
   oc_storeframenil,oc_storereg0nil,oc_storestacknil,oc_storestackrefnil,
   oc_finirefsizeframe,oc_finirefsizereg0,oc_finirefsizestack,
   oc_finirefsizestackref,oc_increfsizeframe,oc_increfsizereg0,
   oc_increfsizestack,oc_increfsizestackref,oc_decrefsizeframe,
   oc_decrefsizereg0,oc_decrefsizestack,oc_decrefsizestackref:(
    vaddress: dataaddressty;
   );
   oc_increg0,oc_writeboolean,oc_writeinteger,oc_writefloat,oc_writestring8,
   oc_writepointer,oc_writeclass,oc_writeenum,
   oc_pushstackaddr,{oc_pushstackaddrindi,}
   oc_indirectpooffs,oc_indirectoffspo:(
    voffset: dataoffsty;
    case opcodety of
     oc_writeenum{,oc_pushstackaddrindi}:(
      voffsaddress: dataaddressty;
     );
   );

   oc_card8tocard16,oc_card8tocard32,oc_card8tocard64,
   oc_card16tocard8,oc_card16tocard32,oc_card16tocard64,
   oc_card32tocard8,oc_card32tocard16,oc_card32tocard64,
   oc_card64tocard8,oc_card64tocard16,oc_card64tocard32,

   oc_int8toint16,oc_int8toint32,oc_int8toint64,
   oc_int16toint8,oc_int16toint32,oc_int16toint64,
   oc_int32toint8,oc_int32toint16,oc_int32toint64,
   oc_int64toint8,oc_int64toint16,oc_int64toint32,

   oc_card8toint8,oc_card8toint16,oc_card8toint32,oc_card8toint64,
   oc_card16toint8,oc_card16toint16,oc_card16toint32,oc_card16toint64,
   oc_card32toint8,oc_card32toint16,oc_card32toint32,oc_card32toint64,
   oc_card64toint8,oc_card64toint16,oc_card64toint32,oc_card64toint64,

   oc_int8tocard8,oc_int8tocard16,oc_int8tocard32,oc_int8tocard64,
   oc_int16tocard8,oc_int16tocard16,oc_int16tocard32,oc_int16tocard64,
   oc_int32tocard8,oc_int32tocard16,oc_int32tocard32,oc_int32tocard64,
   oc_int64tocard8,oc_int64tocard16,oc_int64tocard32,oc_int64tocard64,
   
   oc_negcard32,oc_negint32,oc_negflo64,
   oc_mulint32,oc_mulflo64,oc_addint32,oc_addflo64,
   oc_addpoint32,
   oc_cmpeqbool,oc_cmpeqint32,oc_cmpeqflo64,
   oc_cmpnebool,oc_cmpneint32,oc_cmpneflo64,
   oc_cmpgtbool,oc_cmpgtint32,oc_cmpgtflo64,
   oc_cmpltbool,oc_cmpltint32,oc_cmpltflo64,
   oc_cmpgebool,oc_cmpgeint32,oc_cmpgeflo64,
   oc_cmplebool,oc_cmpleint32,oc_cmpleflo64:(
    stackop: stackopty;
   );
   oc_pushsegaddr,{oc_pushsegaddrindi,}
   oc_storesegnil,oc_finirefsizeseg,oc_increfsizeseg,oc_decrefsizeseg,
   oc_pushlocaddr,{oc_pushlocaddrindi,}
   oc_storesegnilar,oc_storeframenilar,oc_storereg0nilar,oc_storestacknilar,
   oc_storestackrefnilar,oc_popseg,oc_pushseg,
   oc_poploc8,oc_poploc16,oc_poploc32,oc_poploc,
   oc_poppar8,oc_poppar16,oc_poppar32,oc_poppar,
   oc_poplocindi8,oc_poplocindi16,oc_poplocindi32,oc_poplocindi,
   oc_pushpar8,oc_pushpar16,oc_pushpar32,oc_pushpar,
   oc_pushloc,oc_pushlocindi,
   oc_indirect,oc_popindirect8,oc_popindirect16,oc_popindirect32,oc_popindirect,
   oc_finirefsizesegar,oc_finirefsizeframe,oc_finirefsizereg0ar,
   oc_finirefsizestackar,oc_finirefsizestackrefar,oc_increfsizesegar,
   oc_increfsizeframear,oc_increfsizereg0ar,oc_increfsizestackar,
   oc_increfsizestackrefar,oc_decrefsizesegar,oc_decrefsizeframear,
   oc_decrefsizereg0ar,oc_decrefsizestackar,oc_decrefsizestackrefar,
   oc_getmem,
   oc_incsegint32,oc_incsegpo32,
   oc_inclocint32,oc_inclocpo32,
   oc_incparint32,oc_incparpo32,
   oc_incparindiint32,oc_incparindipo32,
   oc_incindiint32,oc_incindipo32,
   oc_decsegint32,oc_decsegpo32,
   oc_declocint32,oc_declocpo32, 
   oc_decparint32,oc_decparpo32,
   oc_decparindiint32,oc_decparindipo32,
   oc_decindiint32,oc_decindipo32:(
    memop: memopty;
   );
   oc_setlengthstr8,oc_setlengthdynarray:(
    setlength: setlengthty;
   );
   oc_subbegin,oc_virttrampoline,oc_externalsub:(
    subbegin: subbeginty;
   );
   oc_subend:(
    subend: subendty;
   );
   oc_call,oc_callfunc,oc_callout,oc_callvirt,oc_callintf,
   oc_callindi,oc_callfuncindi:(
    callinfo: callinfoty;
   );
   oc_locvarpush,oc_locvarpop,oc_return,oc_returnfunc:(
    stacksize: datasizety;
    case opcodety of
     oc_returnfunc:(
      returnfuncinfo: returnfuncinfoty;
     );
   );
   oc_initclass:(
    initclass: initclassinfoty;
   );
   oc_destroyclass:(
    destroyclass: destroyclassinfoty;
   );
   oc_lineinfo:(
    lineinfo: lineinfoty;
   )
  end;

// opflagty = (opf_label);
// opflagsty = set of opflagty;
 
 opty = record
//  proc: opprocty;
  op: opcodety;
//  flags: opflagsty;
 end;
 
 opinfoty = record
//todo: variable item size, immediate data
  op: opty;
  par: opparamty;
 end;
 popinfoty = ^opinfoty;

 startupdataty = record
  globdatasize: ptruint;
//  startaddress: opaddressty;
 end;
 pstartupdataty = ^startupdataty;

 optablety = array[opcodety] of opprocty;
 poptablety = ^optablety;
 ssatablety = array[opcodety] of integer;
 pssatablety = ^ssatablety;
 
const
 startupoffset = (sizeof(startupdataty)+sizeof(opinfoty)-1) div 
                                                         sizeof(opinfoty);

function checkop(var aop: opty; const aopcode: opcodety): boolean;
                       {$ifndef mse_debugparser} inline;{$endif}

(*
procedure setop(var aop: opty; const aopcode: opcodety;
                                   const aflags: opflagsty = []);
                       {$ifndef mse_debugparser} inline;{$endif}
*)
implementation
 

(* 
procedure setop(var aop: opty; const aopcode: opcodety;
                                             const aflags: opflagsty);
                       {$ifndef mse_debugparser} inline;{$endif}
begin
 aop.proc:= optable^[aopcode];
 aop.flags:= aflags;
end;
*)
function checkop(var aop: opty; const aopcode: opcodety): boolean;
                       {$ifndef mse_debugparser} inline;{$endif}
begin
 result:= aop.op = aopcode;
end;

end.
