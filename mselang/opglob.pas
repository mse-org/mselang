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
 opprocty = procedure;

 op1infoty = record
  index0: integer;
 end;

 opninfoty = record
  paramcount: integer;
 end;

 opcodety = (
  oc_none,
  oc_nop,

  oc_beginparse,
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

  oc_push8,
  oc_push16,
  oc_push32,
  oc_push64,

  oc_pushdatakind,
  oc_int32toflo64,
  oc_mulint32,
  oc_mulimmint32,
  oc_mulflo64,
  oc_addint32,
  oc_addimmint32,
  oc_addflo64,
  oc_negcard32,
  oc_negint32,
  oc_negflo64,

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

  oc_pushnil,
  oc_pushsegaddress,

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
  oc_callout,
  oc_callvirt,
  oc_callintf,
  oc_virttrampoline,

  oc_locvarpush,
  oc_locvarpop,
  oc_return,

  oc_initclass,
  oc_destroyclass,

  oc_decloop32,
  oc_decloop64,

  oc_setlengthstr8,

  oc_raise,
  oc_pushcpucontext,
  oc_popcpucontext,
  oc_finiexception,
  oc_continueexception
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
  linkcount: integer; //used in "for downto 0"
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
  case integer of               //todo: use target size
   1: (vboolean: boolean);
   2: (vcard32: card32);
   3: (vint32: int32);
   4: (vint64: int64);
   5: (vfloat64: float64);
   6: (vsize: ptrint);
   7: (vpointer: ptruint);
   8: (voffset: ptrint);
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
 
 beginparseinfoty = record
  exitcodeaddress: segaddressty;
 end;  

 stackopty = record
  datasize: datasizety;
  ssaindex: integer;
  case opcodety of
   oc_poploc8,oc_poploc16,oc_poploc32,oc_poploc,
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

                 //todo: unify
 opparamty = record
  case opcodety of 
   oc_beginparse: (
    beginparse: beginparseinfoty;
   );
   oc_none,oc_nop: (
    dummy: record
    end;
   );
   oc_increg0,oc_push,oc_pop,oc_mulimmint32,oc_addimmint32,oc_offsetpoimm32,
   oc_pushaddr: (
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
   oc_push8,oc_push16,oc_push32,oc_push64,oc_pushdatakind:(
    vpush: vpushty;
   );
   oc_storeframenil,oc_storereg0nil,oc_storestacknil,oc_storestackrefnil,
   oc_finirefsizeframe,oc_finirefsizereg0,oc_finirefsizestack,
   oc_finirefsizestackref,oc_increfsizeframe,oc_increfsizereg0,
   oc_increfsizestack,oc_increfsizestackref,oc_decrefsizeframe,
   oc_decrefsizereg0,oc_decrefsizestack,oc_decrefsizestackref:(
    vaddress: dataaddressty;
   );
   oc_pushsegaddress,oc_storesegnil,oc_finirefsizeseg,oc_increfsizeseg,
   oc_decrefsizeseg:(
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
   oc_storesegnilar,oc_storeframenilar,oc_storereg0nilar,oc_storestacknilar,
   oc_storestackrefnilar,oc_popseg,oc_pushseg,oc_poploc,oc_poplocindi,
   oc_pushloc,oc_pushlocindi,oc_indirect,oc_popindirect,
   oc_finirefsizesegar,oc_finirefsizeframe,oc_finirefsizereg0ar,
   oc_finirefsizestackar,oc_finirefsizestackrefar,oc_increfsizesegar,
   oc_increfsizeframear,oc_increfsizereg0ar,oc_increfsizestackar,
   oc_increfsizestackrefar,oc_decrefsizesegar,oc_decrefsizeframear,
   oc_decrefsizereg0ar,oc_decrefsizestackar,oc_decrefsizestackrefar:(
    stackop: stackopty;
   );
   {
   oc_op1:(
    op1: op1infoty;
   );
   oc_opn:(
    opn: opninfoty;
   );
   }
   oc_goto,oc_if,oc_decloop32,oc_decloop64,oc_pushcpucontext:(
    opaddress: opaddressty; //first!
   );
   {
   oc_params:(
    paramsize: datasizety;
    paramcount: integer;
   );
   }
   oc_call,oc_callout:(
    callinfo: callinfoty;
   );
   oc_callvirt,oc_callintf:(
    virtcallinfo: virtcallinfoty;
   );
   oc_virttrampoline:(
    virttrampolineinfo: virttrampolineinfoty;
   );
   {
   oc_intfcall:(
    intfcallinfo: intfcallinfoty;
   );
   }
   oc_locvarpush,oc_locvarpop,oc_return:(
    stacksize: datasizety;
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
  proc: opprocty;
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

const
 startupoffset = (sizeof(startupdataty)+sizeof(opinfoty)-1) div 
                                                         sizeof(opinfoty);
function checkop(var aop: opty; const aopcode: opcodety): boolean;
                       {$ifndef mse_debugparser} inline;{$endif}

procedure setoptable(const atable: poptablety);

procedure setop(var aop: opty; const aopcode: opcodety;
                                   const aflags: opflagsty = []);
                       {$ifndef mse_debugparser} inline;{$endif}
implementation

var
 optable: poptablety;
 
procedure setop(var aop: opty; const aopcode: opcodety;
                                             const aflags: opflagsty);
                       {$ifndef mse_debugparser} inline;{$endif}
begin
 aop.proc:= optable^[aopcode];
 aop.flags:= aflags;
end;

function checkop(var aop: opty; const aopcode: opcodety): boolean;
                       {$ifndef mse_debugparser} inline;{$endif}
begin
 result:= aop.proc = optable^[aopcode];
end;

procedure setoptable(const atable: poptablety);
begin
 optable:= atable;
end;

end.
