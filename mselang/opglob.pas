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
unit opglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
 
type
 globallocinfoty = record
  a: segaddressty;
  bitsize: integer;
 end;
 pgloballocinfoty = ^globallocinfoty;

 locallocinfoty = record
//  a: addressvaluety;
  flags: addressflagsty;
  address: dataoffsty;
  bitsize: integer;
 end;
 plocallocinfoty = ^locallocinfoty;
 
 parallocinfoty = record
  ssaindex: integer;
  bitsize: integer;
 end;
 pparallocinfoty = ^parallocinfoty;

 nestedaddressty = record
  address: dataoffsty;
  size: integer;
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
 opcodety = (        //order as optable.inc
  oc_none,
  oc_nop,

  oc_beginparse,
  oc_main,
  oc_progend,
  oc_endparse,
  
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

  oc_if,
  oc_writeln,
  oc_writeboolean,
  oc_writeinteger,
  oc_writefloat,
  oc_writestring8,
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

  oc_negcard32,
  oc_negint32,
  oc_negflo64,

  oc_mulint32,
  oc_mulflo64,
  oc_addint32,
  oc_addflo64,

  oc_addimmint32,
  oc_mulimmint32,
  oc_offsetpoimm32,

  oc_cmpequbool,
  oc_cmpequint32,
  oc_cmpequflo64,

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
  oc_popseg,

  oc_poploc8,
  oc_poploc16,
  oc_poploc32,
  oc_poploc,

  oc_poplocindi8,
  oc_poplocindi16,
  oc_poplocindi32,
  oc_poplocindi,

  oc_poppar8,
  oc_poppar16,
  oc_poppar32,
  oc_poppar,

  oc_popparindi8,
  oc_popparindi16,
  oc_popparindi32,
  oc_popparindi,

  oc_pushnil,
//  oc_pushsegaddress,

  oc_pushseg8,
  oc_pushseg16,
  oc_pushseg32,
  oc_pushseg,

  oc_pushloc8,
  oc_pushloc16,
  oc_pushloc32,
  oc_pushlocpo,
  oc_pushloc,

  oc_pushlocindi8,
  oc_pushlocindi16,
  oc_pushlocindi32,
  oc_pushlocindi,

  oc_pushpar8,
  oc_pushpar16,
  oc_pushpar32,
  oc_pushparpo,
  oc_pushpar,

  oc_pushaddr,
  oc_pushlocaddr,
  oc_pushlocaddrindi,
  oc_pushsegaddr,
  oc_pushsegaddrindi,
  oc_pushstackaddr,
  oc_pushstackaddrindi,

  oc_indirect8,
  oc_indirect16,
  oc_indirect32,
  oc_indirectpo,
  oc_indirectpooffs, //offset after indirect
  oc_indirectoffspo, //offset before indirect
  oc_indirect,

  oc_popindirect8,
  oc_popindirect16,
  oc_popindirect32,
  oc_popindirect,

  oc_call,
  oc_callfunc,
  oc_callout,
  oc_callfuncout,
  oc_callvirt,
  oc_callintf,
  oc_virttrampoline,

  oc_locvarpush,
  oc_locvarpop,

  oc_subbegin,
  oc_subend,
  oc_return,
  oc_returnfunc,

  oc_initclass,
  oc_destroyclass,

  oc_decloop32,
  oc_decloop64,

  oc_setlengthstr8,

  oc_raise,
  oc_pushcpucontext,
  oc_popcpucontext,
  oc_finiexception,
  oc_continueexception,
  
//ssaonly
  ocssa_nestedvar,
  ocssa_popnestedvar,
  ocssa_pushnestedvar,  //per item
  ocssa_nestedcallout,  //per level
  ocssa_hascallout
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

 callinfoty = record
  ad: opaddressty;    //first!
  flags: subflagsty;
  linkcount: integer; //used in "for downto 0"
  params: dataoffsty;
  paramcount: integer;
 end; 

 virtcallinfoty = record
  selfinstance: dataoffsty; //stackoffset
  virtoffset: dataoffsty;   //offset in classdefinfoty
 end;

 virttrampolineinfoty = record
  selfinstance: dataoffsty; //frameoffset
  virtoffset: dataoffsty;   //offset in classdefinfoty
 end;

 intfcallinfoty = record
  selfinstance: dataoffsty; 
    //stackoffset, points to interface item in obj instance.
  subindex: integer;   //sub item in interface list
 end;
  
 initclassinfoty = record
  selfinstance: dataoffsty; //stackoffset
//  classdef: dataoffsty;
  result: dataoffsty;   //stackoffset to result pointer
 end;

 destroyclassinfoty = record
  selfinstance: dataoffsty; //stackoffset
 end;

 destroyclassinfo = record
 end;

  immty = record
//   ssaindex: integer;
   datasize: integer;
   case integer of               //todo: use target size
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
 end;  

 stackopty = record
  databitsize: integer;
//  destssaindex: integer;
//  source1ssaindex: integer;
//  case opcodety of
//   oc_mulint32,oc_mulflo64,oc_addint32,oc_addflo64:(
//    source2ssaindex: integer;
//   );
 end;
 
 memopty = record
  datacount: datasizety;         //bit size or item count
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
   oc_pushsegaddr,oc_pushsegaddrindi,
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

 suballocinfoty = record
  allocs: dataoffsty;
  alloccount: integer;
  nestedallocs: dataoffsty;
  nestedalloccount: integer;
//  parallocs: dataoffsty;
//  paralloccount: integer;
//  varallocs: dataoffsty;
//  varalloccount: integer;
 end;

 subbeginty = record
  subname: opaddressty;
  flags: subflagsty;
//  varchain: elementoffsetty;
  allocs: suballocinfoty;
 end;

 subendty = record
  flags: subflagsty;
  allocs: suballocinfoty;
 end;

 returnfuncinfoty = record
  flags: subflagsty;
  allocs: suballocinfoty;
 end;
 
                 //todo: unify
 opparamty = record
  ssad: integer;
  ssas1: integer;
  ssas2: integer;
  case opcodety of 
   oc_beginparse: (
    beginparse: beginparseinfoty;
   );
   oc_none,oc_nop: (
    dummy: record
    end;
   );
   oc_push,
   oc_pushimm1,oc_pushimm8,oc_pushimm16,oc_pushimm32,oc_pushimm64,
   oc_pushimmdatakind,
   oc_pushaddr,
   oc_increg0,oc_mulimmint32,oc_addimmint32,oc_offsetpoimm32,
   oc_pop: (
    imm: immty;
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
   {oc_pushsegaddress,}oc_pushsegaddr,oc_pushsegaddrindi,
   oc_storesegnil,oc_finirefsizeseg,oc_increfsizeseg,oc_decrefsizeseg:(
    vsegaddress: segdataaddressty;
   );
   oc_pushlocaddr,oc_pushlocaddrindi:(
    vlocaddress: locdataaddressty;
   );
   oc_increg0,oc_writeboolean,oc_writeinteger,oc_writefloat,oc_writestring8,
   oc_writeclass,oc_writeenum,oc_pushstackaddr,oc_pushstackaddrindi,
   oc_indirectpooffs,oc_indirectoffspo:(
    voffset: dataoffsty;
    case opcodety of
     oc_writeenum,oc_pushstackaddrindi:(
      voffsaddress: dataaddressty;
     );
   );
   oc_negcard32,oc_negint32,oc_negflo64,
   oc_mulint32,oc_mulflo64,oc_addint32,oc_addflo64,
   oc_cmpequbool,oc_cmpequint32,oc_cmpequflo64:(
    stackop: stackopty;
   );
   oc_storesegnilar,oc_storeframenilar,oc_storereg0nilar,oc_storestacknilar,
   oc_storestackrefnilar,oc_popseg,oc_pushseg,
   oc_poploc8,oc_poploc16,oc_poploc32,oc_poploc,
   oc_poppar8,oc_poppar16,oc_poppar32,oc_poppar,
   oc_poplocindi8,oc_poplocindi16,oc_poplocindi32,oc_poplocindi,
   oc_pushpar8,oc_pushpar16,oc_pushpar32,oc_pushpar,
   oc_pushloc,oc_pushlocindi,
   oc_indirect,oc_popindirect,
   oc_finirefsizesegar,oc_finirefsizeframe,oc_finirefsizereg0ar,
   oc_finirefsizestackar,oc_finirefsizestackrefar,oc_increfsizesegar,
   oc_increfsizeframear,oc_increfsizereg0ar,oc_increfsizestackar,
   oc_increfsizestackrefar,oc_decrefsizesegar,oc_decrefsizeframear,
   oc_decrefsizereg0ar,oc_decrefsizestackar,oc_decrefsizestackrefar:(
    memop: memopty;
   );
   oc_goto,oc_if,oc_decloop32,oc_decloop64,oc_pushcpucontext:(
    opaddress: opaddressty; //first!
   );   
   oc_subbegin:(
    subbegin: subbeginty;
   );
   oc_subend:(
    subend: subendty;
   );
   oc_call,oc_callfunc,oc_callout:(
    callinfo: callinfoty;
   );
   oc_callvirt,oc_callintf:(
    virtcallinfo: virtcallinfoty;
   );
   oc_virttrampoline:(
    virttrampolineinfo: virttrampolineinfoty;
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
  end;

 opflagty = (opf_label);
 opflagsty = set of opflagty;
 
 opty = record
//  proc: opprocty;
  op: opcodety;
  flags: opflagsty;
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
