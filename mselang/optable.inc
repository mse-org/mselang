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
{
 ssatable: ssatablety = (
  nonessa,
  nopssa,

  labelssa,          //controlops
  ifssa,
  whilessa,
  untilssa,
  decloop32ssa,
  decloop64ssa,

  raisessa,         //callops

  callssa,
  callfuncssa,
  calloutssa,
  callfuncoutssa,
  callvirtssa,
  callintfssa,
  virttrampolinessa,

  callindissa,
  callfuncindissa,

  initclassssa,
  destroyclassssa,

  beginparsessa,
  mainssa,
  progendssa,  
  endparsessa,
  haltssa,

  movesegreg0ssa,
  moveframereg0ssa,
  popreg0ssa,
  increg0ssa,

  gotossa,
  cmpjmpneimm4ssa,
  cmpjmpeqimm4ssa,
  cmpjmploimm4ssa,
  cmpjmpgtimm4ssa,
  cmpjmploeqimm4ssa,

  writelnssa,
  writebooleanssa,
  writecardinalssa,
  writeintegerssa,
  writefloatssa,
  writestring8ssa,
  writepointerssa,
  writeclassssa,
  writeenumssa,

  pushssa,
  popssa,

  pushimm1ssa,
  pushimm8ssa,
  pushimm16ssa,
  pushimm32ssa,
  pushimm64ssa,
  pushimmdatakindssa,
  
  int32toflo64ssa,
  potoint32ssa,
  inttopossa,

  and1ssa,
  and32ssa,
  or1ssa,
  or32ssa,

  shl32ssa,
  shr32ssa,
//  shrint32ssa,
  
  card8tocard16ssa,card8tocard32ssa,card8tocard64ssa,
  card16tocard8ssa,card16tocard32ssa,card16tocard64ssa,
  card32tocard8ssa,card32tocard16ssa,card32tocard64ssa,
  card64tocard8ssa,card64tocard16ssa,card64tocard32ssa,

  int8toint16ssa,int8toint32ssa,int8toint64ssa,
  int16toint8ssa,int16toint32ssa,int16toint64ssa,
  int32toint8ssa,int32toint16ssa,int32toint64ssa,
  int64toint8ssa,int64toint16ssa,int64toint32ssa,

  card8toint8ssa,card8toint16ssa,card8toint32ssa,card8toint64ssa,
  card16toint8ssa,card16toint16ssa,card16toint32ssa,card16toint64ssa,
  card32toint8ssa,card32toint16ssa,card32toint32ssa,card32toint64ssa,
  card64toint8ssa,card64toint16ssa,card64toint32ssa,card64toint64ssa,

  int8tocard8ssa,int8tocard16ssa,int8tocard32ssa,int8tocard64ssa,
  int16tocard8ssa,int16tocard16ssa,int16tocard32ssa,int16tocard64ssa,
  int32tocard8ssa,int32tocard16ssa,int32tocard32ssa,int32tocard64ssa,
  int64tocard8ssa,int64tocard16ssa,int64tocard32ssa,int64tocard64ssa,

  not1ssa,
  not32ssa,
  
  negcard32ssa,
  negint32ssa,
  negflo64ssa,

  mulcard32ssa,
  mulint32ssa,
  mulflo64ssa,
  addint32ssa,
  subint32ssa,
  addpoint32ssa,
  subpossa,
  addflo64ssa,
  subflo64ssa,

  addimmint32ssa,
  mulimmint32ssa,
  offsetpoimm32ssa,

  incdecsegimmint32ssa,
  incdecsegimmpo32ssa,

  incdeclocimmint32ssa,
  incdeclocimmpo32ssa,

  incdecparimmint32ssa,
  incdecparimmpo32ssa,

  incdecparindiimmint32ssa,
  incdecparindiimmpo32ssa,

  incdecindiimmint32ssa,
  incdecindiimmpo32ssa,

  incsegint32ssa,
  incsegpo32ssa,

  inclocint32ssa,
  inclocpo32ssa,

  incparint32ssa,
  incparpo32ssa,

  incparindiint32ssa,
  incparindipo32ssa,

  incindiint32ssa,
  incindipo32ssa,

  decsegint32ssa,
  decsegpo32ssa,

  declocint32ssa,
  declocpo32ssa,

  decparint32ssa,
  decparpo32ssa,

  decparindiint32ssa,
  decparindipo32ssa,

  decindiint32ssa,
  decindipo32ssa,

  cmpeqpossa,
  cmpeqboolssa,
  cmpeqint32ssa,
  cmpeqflo64ssa,

  cmpnepossa,
  cmpneboolssa,
  cmpneint32ssa,
  cmpneflo64ssa,

  cmpgtpossa,
  cmpgtboolssa,
  cmpgtcard32ssa,
  cmpgtint32ssa,
  cmpgtflo64ssa,

  cmpltpossa,
  cmpltboolssa,
  cmpltcard32ssa,
  cmpltint32ssa,
  cmpltflo64ssa,

  cmpgepossa,
  cmpgeboolssa,
  cmpgecard32ssa,
  cmpgeint32ssa,
  cmpgeflo64ssa,

  cmplepossa,
  cmpleboolssa,
  cmplecard32ssa,
  cmpleint32ssa,
  cmpleflo64ssa,

  storesegnilssa,
  storereg0nilssa,
  storeframenilssa,
  storestacknilssa,
  storestackrefnilssa,
  storesegnilarssa,
  storeframenilarssa,
  storereg0nilarssa,
  storestacknilarssa,
  storestackrefnilarssa,

  finirefsizesegssa,
  finirefsizeframessa,
  finirefsizereg0ssa,
  finirefsizestackssa,
  finirefsizestackrefssa,
  finirefsizeframearssa,
  finirefsizesegarssa,
  finirefsizereg0arssa,
  finirefsizestackarssa,
  finirefsizestackrefarssa,

  increfsizesegssa,
  increfsizeframessa,
  increfsizereg0ssa,
  increfsizestackssa,
  increfsizestackrefssa,
  increfsizeframearssa,
  increfsizesegarssa,
  increfsizereg0arssa,
  increfsizestackarssa,
  increfsizestackrefarssa,

  decrefsizesegssa,
  decrefsizeframessa,
  decrefsizereg0ssa,
  decrefsizestackssa,
  decrefsizestackrefssa,
  decrefsizeframearssa,
  decrefsizesegarssa,
  decrefsizereg0arssa,
  decrefsizestackarssa,
  decrefsizestackrefarssa,

  popseg8ssa,
  popseg16ssa,
  popseg32ssa,
  popseg64ssa,
  popsegpossa,
  popsegf16ssa,
  popsegf32ssa,
  popsegf64ssa,
  popsegssa,

  poploc8ssa,
  poploc16ssa,
  poploc32ssa,
  poploc64ssa,
  poplocpossa,
  poplocf16ssa,
  poplocf32ssa,
  poplocf64ssa,
  poplocssa,

  poplocindi8ssa,
  poplocindi16ssa,
  poplocindi32ssa,
  poplocindi64ssa,
  poplocindipossa,
  poplocindif16ssa,
  poplocindif32ssa,
  poplocindif64ssa,
  poplocindissa,

  poppar8ssa,
  poppar16ssa,
  poppar32ssa,
  poppar64ssa,
  popparpossa,
  popparf16ssa,
  popparf32ssa,
  popparf64ssa,
  popparssa,

  popparindi8ssa,
  popparindi16ssa,
  popparindi32ssa,
  popparindi64ssa,
  popparindipossa,
  popparindif16ssa,
  popparindif32ssa,
  popparindif64ssa,
  popparindissa,

  pushnilssa,
//  pushsegaddressssa,

  pushseg8ssa,
  pushseg16ssa,
  pushseg32ssa,
  pushseg64ssa,
  pushsegpossa,
  pushsegf16ssa,
  pushsegf32ssa,
  pushsegf64ssa,
  pushsegssa,

  pushloc8ssa,
  pushloc16ssa,
  pushloc32ssa,
  pushloc64ssa,
  pushlocpossa,
  pushlocf16ssa,
  pushlocf32ssa,
  pushlocf64ssa,
  pushlocssa,

  pushlocindi8ssa,
  pushlocindi16ssa,
  pushlocindi32ssa,
  pushlocindi64ssa,
  pushlocindipossa,
  pushlocindi16ssa,
  pushlocindi32ssa,
  pushlocindi64ssa,
  pushlocindissa,

  pushpar8ssa,
  pushpar16ssa,
  pushpar32ssa,
  pushpar64ssa,
  pushparpossa,
  pushparf16ssa,
  pushparf32ssa,
  pushparf64ssa,
  pushparssa,

  pushaddrssa,
  pushlocaddrssa,
//  pushlocaddrindissa,
  pushsegaddrssa,
//  pushsegaddrindissa,
  pushstackaddrssa,
//  pushstackaddrindissa,
  
  pushduppossa,

  indirect8ssa,
  indirect16ssa,
  indirect32ssa,
  indirect64ssa,
  indirectpossa,
  indirectf16ssa,
  indirectf32ssa,
  indirectf64ssa,
  indirectpooffsssa,
  indirectoffspossa,
  indirectssa,

  popindirect8ssa,
  popindirect16ssa,
  popindirect32ssa,
  popindirect64ssa,
  popindirectpossa,
  popindirectf16ssa,
  popindirectf32ssa,
  popindirectf64ssa,
  popindirectssa,

  locvarpushssa,
  locvarpopssa,

  subbeginssa,
  subendssa,
  externalsubssa,
  returnssa,
  returnfuncssa,

  setlengthstr8ssa,
  setlengthdynarrayssa,

  pushcpucontextssa,
  popcpucontextssa,
  finiexceptionssa,
  continueexceptionssa,
  getmemssa,
  getzeromemssa,
  freememssa,
  setmemssa,
  lineinfossa,

//ssaonly
  nestedvarssa,
  popnestedvarssa,
//  popsegaggregatessa,
  pushnestedvarssa,
  aggregatessa,
  allocssa,
  nestedcalloutssa,
  hascalloutssa,
  pushsegaddrnilssa,
  pushsegaddrglobvarssa,
  pushsegaddrglobconstssa,
  pushsegaddrclassdefssa
 );

 optable: optablety = ( //order as opcodety
  nil,  //oc_none
  @nopop,

  @labelop,       //controlops
  @ifop,
  @whileop,
  @untilop,
  @decloop32op,
  @decloop64op,

  @raiseop,      //callops

  @callop,
  @callfuncop,
  @calloutop,
  @callfuncoutop,
  @callvirtop,
  @callintfop,
  @virttrampolineop,

  @callindiop,
  @callfuncindiop,

  @initclassop,
  @destroyclassop,

  @beginparseop,
  @mainop,
  @progendop,  
  @endparseop,
  @haltop,

  @movesegreg0op,
  @moveframereg0op,
  @popreg0op,
  @increg0op,

  @gotoop,
  @cmpjmpneimm4op,
  @cmpjmpeqimm4op,
  @cmpjmploimm4op,
  @cmpjmpgtimm4op,
  @cmpjmploeqimm4op,

  @writelnop,
  @writebooleanop,
  @writecardinalop,
  @writeintegerop,
  @writefloatop,
  @writestring8op,
  @writepointerop,
  @writeclassop,
  @writeenumop,

  @pushop,
  @popop,

  @pushimm1op,
  @pushimm8op,
  @pushimm16op,
  @pushimm32op,
  @pushimm64op,
  @pushimmdatakindop,
  
  @int32toflo64op,
  @potoint32op,
  @inttopoop,
  
  @and1op,
  @and32op,
  @or1op,
  @or32op,
  
  @shl32op,
  @shr32op,
//  @shrint32op,

  @card8tocard16op,
  @card8tocard32op,
  @card8tocard64op,
  @card16tocard8op,
  @card16tocard32op,
  @card16tocard64op,
  @card32tocard8op,
  @card32tocard16op,
  @card32tocard64op,
  @card64tocard8op,
  @card64tocard16op,
  @card64tocard32op,

  @int8toint16op,
  @int8toint32op,
  @int8toint64op,
  @int16toint8op,
  @int16toint32op,
  @int16toint64op,
  @int32toint8op,
  @int32toint16op,
  @int32toint64op,
  @int64toint8op,
  @int64toint16op,
  @int64toint32op,

  @card8toint8op,
  @card8toint16op,
  @card8toint32op,
  @card8toint64op,
  @card16toint8op,
  @card16toint16op,
  @card16toint32op,
  @card16toint64op,
  @card32toint8op,
  @card32toint16op,
  @card32toint32op,
  @card32toint64op,
  @card64toint8op,
  @card64toint16op,
  @card64toint32op,
  @card64toint64op,

  @int8tocard8op,
  @int8tocard16op,
  @int8tocard32op,
  @int8tocard64op,
  @int16tocard8op,
  @int16tocard16op,
  @int16tocard32op,
  @int16tocard64op,
  @int32tocard8op,
  @int32tocard16op,
  @int32tocard32op,
  @int32tocard64op,
  @int64tocard8op,
  @int64tocard16op,
  @int64tocard32op,
  @int64tocard64op,
  
  @not1op,
  @not32op,
  
  @negcard32op,
  @negint32op,
  @negflo64op,

  @mulcard32op,
  @mulint32op,
  @mulflo64op,
  @addint32op,
  @subint32op,
  @addpoint32op,
  @subpoop,
  @addflo64op,
  @subflo64op,

  @addimmint32op,
  @mulimmint32op,
  @offsetpoimm32op,

  @incdecsegimmint32op,
  @incdecsegimmpo32op,

  @incdeclocimmint32op,
  @incdeclocimmpo32op,

  @incdecparimmint32op,
  @incdecparimmpo32op,

  @incdecparindiimmint32op,
  @incdecparindiimmpo32op,

  @incdecindiimmint32op,
  @incdecindiimmpo32op,

  @incsegint32op,
  @incsegpo32op,

  @inclocint32op,
  @inclocpo32op,

  @incparint32op,
  @incparpo32op,

  @incparindiint32op,
  @incparindipo32op,

  @incindiint32op,
  @incindipo32op,

  @decsegint32op,
  @decsegpo32op,

  @declocint32op,
  @declocpo32op,

  @decparint32op,
  @decparpo32op,

  @decparindiint32op,
  @decparindipo32op,

  @decindiint32op,
  @decindipo32op,

  @cmpeqpoop,
  @cmpeqboolop,
  @cmpeqint32op,
  @cmpeqflo64op,

  @cmpnepoop,
  @cmpneboolop,
  @cmpneint32op,
  @cmpneflo64op,

  @cmpgtpoop,
  @cmpgtboolop,
  @cmpgtcard32op,
  @cmpgtint32op,
  @cmpgtflo64op,

  @cmpltpoop,
  @cmpltboolop,
  @cmpltcard32op,
  @cmpltint32op,
  @cmpltflo64op,

  @cmpgepoop,
  @cmpgeboolop,
  @cmpgecard32op,
  @cmpgeint32op,
  @cmpgeflo64op,

  @cmplepoop,
  @cmpleboolop,
  @cmplecard32op,
  @cmpleint32op,
  @cmpleflo64op,

  @storesegnilop,
  @storereg0nilop,
  @storeframenilop,
  @storestacknilop,
  @storestackrefnilop,
  @storesegnilarop,
  @storeframenilarop,
  @storereg0nilarop,
  @storestacknilarop,
  @storestackrefnilarop,

  @finirefsizesegop,
  @finirefsizeframeop,
  @finirefsizereg0op,
  @finirefsizestackop,
  @finirefsizestackrefop,
  @finirefsizeframearop,
  @finirefsizesegarop,
  @finirefsizereg0arop,
  @finirefsizestackarop,
  @finirefsizestackrefarop,

  @increfsizesegop,
  @increfsizeframeop,
  @increfsizereg0op,
  @increfsizestackop,
  @increfsizestackrefop,
  @increfsizeframearop,
  @increfsizesegarop,
  @increfsizereg0arop,
  @increfsizestackarop,
  @increfsizestackrefarop,

  @decrefsizesegop,
  @decrefsizeframeop,
  @decrefsizereg0op,
  @decrefsizestackop,
  @decrefsizestackrefop,
  @decrefsizeframearop,
  @decrefsizesegarop,
  @decrefsizereg0arop,
  @decrefsizestackarop,
  @decrefsizestackrefarop,

  @popseg8op,
  @popseg16op,
  @popseg32op,
  @popseg64op,
  @popsegpoop,
  @popsegf16op,
  @popsegf32op,
  @popsegf64op,
  @popsegop,

  @poploc8op,
  @poploc16op,
  @poploc32op,
  @poploc64op,
  @poplocpoop,
  @poplocf16op,
  @poplocf32op,
  @poplocf64op,
  @poplocop,

  @poplocindi8op,
  @poplocindi16op,
  @poplocindi32op,
  @poplocindi64op,
  @poplocindipoop,
  @poplocindif16op,
  @poplocindif32op,
  @poplocindif64op,
  @poplocindiop,

  @poppar8op,
  @poppar16op,
  @poppar32op,
  @poppar64op,
  @popparpoop,
  @popparf16op,
  @popparf32op,
  @popparf64op,
  @popparop,

  @popparindi8op,
  @popparindi16op,
  @popparindi32op,
  @popparindi64op,
  @popparindipoop,
  @popparindif16op,
  @popparindif32op,
  @popparindif64op,
  @popparindiop,

  @pushnilop,
//  @pushsegaddressop,

  @pushseg8op,
  @pushseg16op,
  @pushseg32op,
  @pushseg64op,
  @pushsegpoop,
  @pushsegf16op,
  @pushsegf32op,
  @pushsegf64op,
  @pushsegop,

  @pushloc8op,
  @pushloc16op,
  @pushloc32op,
  @pushloc64op,
  @pushlocpoop,
  @pushlocf16op,
  @pushlocf32op,
  @pushlocf64op,
  @pushlocop,

  @pushlocindi8op,
  @pushlocindi16op,
  @pushlocindi32op,
  @pushlocindi64op,
  @pushlocindipoop,
  @pushlocindif16op,
  @pushlocindif32op,
  @pushlocindif64op,
  @pushlocindiop,

  @pushpar8op,
  @pushpar16op,
  @pushpar32op,
  @pushpar64op,
  @pushparpoop,
  @pushparf16op,
  @pushparf32op,
  @pushparf64op,
  @pushparop,

  @pushaddrop,
  @pushlocaddrop,
//  @pushlocaddrindiop,
  @pushsegaddrop,
//  @pushsegaddrindiop,
  @pushstackaddrop,
//  @pushstackaddrindiop,
  
  @pushduppoop,

  @indirect8op,
  @indirect16op,
  @indirect32op,
  @indirect64op,
  @indirectpoop,
  @indirectf16op,
  @indirectf32op,
  @indirectf64op,
  @indirectpooffsop, //offset after indirect
  @indirectoffspoop, //offset before indirect
  @indirectop,

  @popindirect8op,
  @popindirect16op,
  @popindirect32op,
  @popindirect64op,
  @popindirectpoop,
  @popindirectf16op,
  @popindirectf32op,
  @popindirectf64op,
  @popindirectop,

  @locvarpushop,
  @locvarpopop,

  @subbeginop,
  @subendop,
  @externalsubop,
  @returnop,
  @returnfuncop,

  @setlengthstr8op,
  @setlengthdynarrayop,

  @pushcpucontextop,
  @popcpucontextop,
  @finiexceptionop,
  @continueexceptionop,

  @getmemop,
  @getzeromemop,
  @freememop,
  @setmemop,
 
  @lineinfoop,
   
   //ssa only
  nil,
  nil,
  nil,
  nil,
  nil,
  nil,
  nil,
  
  nil,
  nil,
  nil,
  nil
 );
}

 optable: optablety = (
//oc_none
  (ssa: nonessa; proc: nil; flags: []), 
//oc_nop
  (ssa: nopssa; proc: @nopop; flags: []),

//oc_label                                           //controlops
  (ssa: labelssa; proc: @labelop; flags: []),           
//oc_if
  (ssa: ifssa; proc: @ifop; flags: []), 
//oc_while
  (ssa: whilessa; proc: @whileop; flags: []), 
//oc_until
  (ssa: untilssa; proc: @untilop; flags: []), 
//oc_decloop32
  (ssa: decloop32ssa; proc: @decloop32op; flags: []), 
//oc_decloop64
  (ssa: decloop64ssa; proc: @decloop64op; flags: []), 

//oc_raise
  (ssa: raisessa; proc: @raiseop; flags: []), 

                                                   //callops
//oc_call
  (ssa: callssa; proc: @callop; flags: []), 
//oc_callfunc
  (ssa: callfuncssa; proc: @callfuncop; flags: []), 
//oc_callout
  (ssa: calloutssa; proc: @calloutop; flags: []), 
//oc_callfuncout
  (ssa: callfuncoutssa; proc: @callfuncoutop; flags: []), 
//oc_callvirt
  (ssa: callvirtssa; proc: @callvirtop; flags: []), 
//oc_callvirtfunc
  (ssa: callvirtfuncssa; proc: @callvirtfuncop; flags: []), 
//oc_callintf
  (ssa: callintfssa; proc: @callintfop; flags: []), 
//oc_callintffunc
  (ssa: callintffuncssa; proc: @callintffuncop; flags: []), 
//oc_virttrampoline
  (ssa: virttrampolinessa; proc: @virttrampolineop; flags: []), 

//oc_callindi
  (ssa: callindissa; proc: @callindiop; flags: []), 
//oc_callfuncindi
  (ssa: callfuncindissa; proc: @callfuncindiop; flags: []), 

//oc_initclass
  (ssa: initclassssa; proc: @initclassop; flags: []), 
//oc_destroyclass
  (ssa: destroyclassssa; proc: @destroyclassop; flags: []), 

//oc_beginparse
  (ssa: beginparsessa; proc: @beginparseop; flags: []), 
//oc_endparse
  (ssa: endparsessa; proc: @endparseop; flags: []), 
//oc_beginunitcode
  (ssa: beginunitcodessa; proc: @beginunitcodeop; flags: []), 
//oc_endunit
  (ssa: endunitssa; proc: @endunitop; flags: []), 
//oc_main
  (ssa: mainssa; proc: @mainop; flags: []), 
//oc_progend
  (ssa: progendssa; proc: @progendop; flags: []), 
//oc_halt
  (ssa: haltssa; proc: @haltop; flags: []), 

//oc_movesegreg0
  (ssa: movesegreg0ssa; proc: @movesegreg0op; flags: []), 
//oc_moveframereg0
  (ssa: moveframereg0ssa; proc: @moveframereg0op; flags: []), 
//oc_popreg0
  (ssa: popreg0ssa; proc: @popreg0op; flags: []), 
//oc_increg0
  (ssa: increg0ssa; proc: @increg0op; flags: []), 

//oc_phi
  (ssa: phissa; proc: @phiop; flags: []), 

//oc_goto
  (ssa: gotossa; proc: @gotoop; flags: []), 
//oc_gotofalse
  (ssa: gotofalsessa; proc: @gotofalseop; flags: []), 
//oc_gototrue
  (ssa: gototruessa; proc: @gototrueop; flags: []), 
//oc_cmpjmpneimm4
  (ssa: cmpjmpneimm4ssa; proc: @cmpjmpneimm4op; flags: []), 
//oc_cmpjmpeqimm4
  (ssa: cmpjmpeqimm4ssa; proc: @cmpjmpeqimm4op; flags: []), 
//oc_cmpjmploimm4
  (ssa: cmpjmploimm4ssa; proc: @cmpjmploimm4op; flags: []), 
//oc_cmpjmpgtimm4
  (ssa: cmpjmpgtimm4ssa; proc: @cmpjmpgtimm4op; flags: []), 
//oc_cmpjmploeqimm4
  (ssa: cmpjmploeqimm4ssa; proc: @cmpjmploeqimm4op; flags: []), 

//oc_writeln
  (ssa: writelnssa; proc: @writelnop; flags: []), 
//oc_writeboolean
  (ssa: writebooleanssa; proc: @writebooleanop; flags: []), 
//oc_writecardinal8
  (ssa: writecardinal8ssa; proc: @writecardinal8op; flags: []), 
//oc_writecardinal16
  (ssa: writecardinal16ssa; proc: @writecardinal16op; flags: []), 
//oc_writecardinal32
  (ssa: writecardinal32ssa; proc: @writecardinal32op; flags: []), 
//oc_writecardinal64
  (ssa: writecardinal64ssa; proc: @writecardinal64op; flags: []), 
//oc_writeinteger8
  (ssa: writeinteger8ssa; proc: @writeinteger8op; flags: []), 
//oc_writeinteger16
  (ssa: writeinteger16ssa; proc: @writeinteger16op; flags: []), 
//oc_writeinteger32
  (ssa: writeinteger32ssa; proc: @writeinteger32op; flags: []), 
//oc_writeinteger64
  (ssa: writeinteger64ssa; proc: @writeinteger64op; flags: []), 
//oc_writefloat64
  (ssa: writefloat64ssa; proc: @writefloat64op; flags: []), 
//oc_writestring8
  (ssa: writestring8ssa; proc: @writestring8op; flags: []), 
//oc_writepointer
  (ssa: writepointerssa; proc: @writepointerop; flags: []), 
//oc_writeclass
  (ssa: writeclassssa; proc: @writeclassop; flags: []), 
//oc_writeenum
  (ssa: writeenumssa; proc: @writeenumop; flags: []), 

//oc_push
  (ssa: pushssa; proc: @pushop; flags: []), 
//oc_pop
  (ssa: popssa; proc: @popop; flags: []),
//oc_swapstack
  (ssa: swapstackssa; proc: @swapstackop; flags: []),

//oc_pushimm1
  (ssa: pushimm1ssa; proc: @pushimm1op; flags: []), 
//oc_pushimm8
  (ssa: pushimm8ssa; proc: @pushimm8op; flags: []), 
//oc_pushimm16
  (ssa: pushimm16ssa; proc: @pushimm16op; flags: []), 
//oc_pushimm32
  (ssa: pushimm32ssa; proc: @pushimm32op; flags: []), 
//oc_pushimm64
  (ssa: pushimm64ssa; proc: @pushimm64op; flags: []), 
//oc_pushimmf64
  (ssa: pushimmf64ssa; proc: @pushimmf64op; flags: []), 
//oc_pushimmdatakind
  (ssa: pushimmdatakindssa; proc: @pushimmdatakindop; flags: []), 
  
//oc_int32toflo64
  (ssa: int32toflo64ssa; proc: @int32toflo64op; flags: []), 
//oc_potoint32
  (ssa: potoint32ssa; proc: @potoint32op; flags: []), 
//oc_inttopo
  (ssa: inttopossa; proc: @inttopoop; flags: []), 

//oc_and1
  (ssa: and1ssa; proc: @and1op; flags: []), 
//oc_and32
  (ssa: and32ssa; proc: @and32op; flags: []), 
//oc_or1
  (ssa: or1ssa; proc: @or1op; flags: []), 
//oc_or32
  (ssa: or32ssa; proc: @or32op; flags: []), 
//oc_xor1
  (ssa: xor1ssa; proc: @xor1op; flags: []), 
//oc_xor32
  (ssa: xor32ssa; proc: @xor32op; flags: []), 

//oc_shl32
  (ssa: shl32ssa; proc: @shl32op; flags: []), 
//oc_shr32
  (ssa: shr32ssa; proc: @shr32op; flags: []), 
//  shrint32
  
//oc_card8tocard16
  (ssa: card8tocard16ssa; proc: @card8tocard16op; flags: []), 
//oc_card8tocard32
  (ssa: card8tocard32ssa; proc: @card8tocard32op; flags: []), 
//oc_card8tocard64
  (ssa: card8tocard64ssa; proc: @card8tocard64op; flags: []), 
//oc_card16tocard8
  (ssa: card16tocard8ssa; proc: @card16tocard8op; flags: []), 
//oc_card16tocard32
  (ssa: card16tocard32ssa; proc: @card16tocard32op; flags: []), 
//oc_card16tocard64
  (ssa: card16tocard64ssa; proc: @card16tocard64op; flags: []), 
//oc_card32tocard8
  (ssa: card32tocard8ssa; proc: @card32tocard8op; flags: []), 
//oc_card32tocard16
  (ssa: card32tocard16ssa; proc: @card32tocard16op; flags: []), 
//oc_card32tocard64
  (ssa: card32tocard64ssa; proc: @card32tocard64op; flags: []), 
//oc_card64tocard8
  (ssa: card64tocard8ssa; proc: @card64tocard8op; flags: []), 
//oc_card64tocard16
  (ssa: card64tocard16ssa; proc: @card64tocard16op; flags: []), 
//oc_card64tocard32
  (ssa: card64tocard32ssa; proc: @card64tocard32op; flags: []), 

//oc_int8toint16
  (ssa: int8toint16ssa; proc: @int8toint16op; flags: []), 
//oc_int8toint32
  (ssa: int8toint32ssa; proc: @int8toint32op; flags: []), 
//oc_int8toint64
  (ssa: int8toint64ssa; proc: @int8toint64op; flags: []), 
//oc_int16toint8
  (ssa: int16toint8ssa; proc: @int16toint8op; flags: []), 
//oc_int16toint32
  (ssa: int16toint32ssa; proc: @int16toint32op; flags: []), 
//oc_int16toint64
  (ssa: int16toint64ssa; proc: @int16toint64op; flags: []), 
//oc_int32toint8
  (ssa: int32toint8ssa; proc: @int32toint8op; flags: []), 
//oc_int32toint16
  (ssa: int32toint16ssa; proc: @int32toint16op; flags: []), 
//oc_int32toint64
  (ssa: int32toint64ssa; proc: @int32toint64op; flags: []), 
//oc_int64toint8
  (ssa: int64toint8ssa; proc: @int64toint8op; flags: []), 
//oc_int64toint16
  (ssa: int64toint16ssa; proc: @int64toint16op; flags: []), 
//oc_int64toint32
  (ssa: int64toint32ssa; proc: @int64toint32op; flags: []), 

//oc_card8toint8
  (ssa: card8toint8ssa; proc: @card8toint8op; flags: []), 
//oc_card8toint16
  (ssa: card8toint16ssa; proc: @card8toint16op; flags: []), 
//oc_card8toint32
  (ssa: card8toint32ssa; proc: @card8toint32op; flags: []), 
//oc_card8toint64
  (ssa: card8toint64ssa; proc: @card8toint64op; flags: []), 
//oc_card16toint8
  (ssa: card16toint8ssa; proc: @card16toint8op; flags: []), 
//oc_card16toint16
  (ssa: card16toint16ssa; proc: @card16toint16op; flags: []), 
//oc_card16toint32
  (ssa: card16toint32ssa; proc: @card16toint32op; flags: []), 
//oc_card16toint64
  (ssa: card16toint64ssa; proc: @card16toint64op; flags: []), 
//oc_card32toint8
  (ssa: card32toint8ssa; proc: @card32toint8op; flags: []), 
//oc_card32toint16
  (ssa: card32toint16ssa; proc: @card32toint16op; flags: []), 
//oc_card32toint32
  (ssa: card32toint32ssa; proc: @card32toint32op; flags: []), 
//oc_card32toint64
  (ssa: card32toint64ssa; proc: @card32toint64op; flags: []), 
//oc_card64toint8
  (ssa: card64toint8ssa; proc: @card64toint8op; flags: []), 
//oc_card64toint16
  (ssa: card64toint16ssa; proc: @card64toint16op; flags: []), 
//oc_card64toint32
  (ssa: card64toint32ssa; proc: @card64toint32op; flags: []), 
//oc_card64toint64
  (ssa: card64toint64ssa; proc: @card64toint64op; flags: []), 

//oc_int8tocard8
  (ssa: int8tocard8ssa; proc: @int8tocard8op; flags: []), 
//oc_int8tocard16
  (ssa: int8tocard16ssa; proc: @int8tocard16op; flags: []), 
//oc_int8tocard32
  (ssa: int8tocard32ssa; proc: @int8tocard32op; flags: []), 
//oc_int8tocard64
  (ssa: int8tocard64ssa; proc: @int8tocard64op; flags: []), 
//oc_int16tocard8
  (ssa: int16tocard8ssa; proc: @int16tocard8op; flags: []), 
//oc_int16tocard16
  (ssa: int16tocard16ssa; proc: @int16tocard16op; flags: []), 
//oc_int16tocard32
  (ssa: int16tocard32ssa; proc: @int16tocard32op; flags: []), 
//oc_int16tocard64
  (ssa: int16tocard64ssa; proc: @int16tocard64op; flags: []), 
//oc_int32tocard8
  (ssa: int32tocard8ssa; proc: @int32tocard8op; flags: []), 
//oc_int32tocard16
  (ssa: int32tocard16ssa; proc: @int32tocard16op; flags: []), 
//oc_int32tocard32
  (ssa: int32tocard32ssa; proc: @int32tocard32op; flags: []), 
//oc_int32tocard64
  (ssa: int32tocard64ssa; proc: @int32tocard64op; flags: []), 
//oc_int64tocard8
  (ssa: int64tocard8ssa; proc: @int64tocard8op; flags: []), 
//oc_int64tocard16
  (ssa: int64tocard16ssa; proc: @int64tocard16op; flags: []), 
//oc_int64tocard32
  (ssa: int64tocard32ssa; proc: @int64tocard32op; flags: []), 
//oc_int64tocard64
  (ssa: int64tocard64ssa; proc: @int64tocard64op; flags: []), 

//oc_not1
  (ssa: not1ssa; proc: @not1op; flags: []), 
//oc_not32
  (ssa: not32ssa; proc: @not32op; flags: []), 

//oc_negcard32
  (ssa: negcard32ssa; proc: @negcard32op; flags: []), 
//oc_negint32
  (ssa: negint32ssa; proc: @negint32op; flags: []), 
//oc_negflo64
  (ssa: negflo64ssa; proc: @negflo64op; flags: []), 

//oc_mulcard32
  (ssa: mulcard32ssa; proc: @mulcard32op; flags: []), 
//oc_mulint32
  (ssa: mulint32ssa; proc: @mulint32op; flags: []), 
//oc_divcard32
  (ssa: divcard32ssa; proc: @divcard32op; flags: []), 
//oc_divint32
  (ssa: divint32ssa; proc: @divint32op; flags: []), 
//oc_mulflo64
  (ssa: mulflo64ssa; proc: @mulflo64op; flags: []), 
//oc_divflo64
  (ssa: divflo64ssa; proc: @divflo64op; flags: []), 
//oc_addint32
  (ssa: addint32ssa; proc: @addint32op; flags: []), 
//oc_subint32
  (ssa: subint32ssa; proc: @subint32op; flags: []), 
//oc_addpoint32
  (ssa: addpoint32ssa; proc: @addpoint32op; flags: []), 
//oc_subpoint32
  (ssa: subpoint32ssa; proc: @subpoint32op; flags: []), 
//oc_subpo
  (ssa: subpossa; proc: @subpoop; flags: []), 
//oc_addflo64
  (ssa: addflo64ssa; proc: @addflo64op; flags: []), 
//oc_subflo64
  (ssa: subflo64ssa; proc: @subflo64op; flags: []), 
//oc_diffset
  (ssa: diffsetssa; proc: @diffsetop; flags: []), 
//oc_xorset
  (ssa: xorsetssa; proc: @xorsetop; flags: []), 

//oc_addimmint32
  (ssa: addimmint32ssa; proc: @addimmint32op; flags: []), 
//oc_mulimmint32
  (ssa: mulimmint32ssa; proc: @mulimmint32op; flags: []), 
//oc_offsetpoimm32
  (ssa: offsetpoimm32ssa; proc: @offsetpoimm32op; flags: []), 

//oc_incdecsegimmint32
  (ssa: incdecsegimmint32ssa; proc: @incdecsegimmint32op; flags: [of_relocseg]), 
//oc_incdecsegimmpo32
  (ssa: incdecsegimmpo32ssa; proc: @incdecsegimmpo32op; flags: [of_relocseg]), 

//oc_incdeclocimmint32
  (ssa: incdeclocimmint32ssa; proc: @incdeclocimmint32op; flags: []), 
//oc_incdeclocimmpo32
  (ssa: incdeclocimmpo32ssa; proc: @incdeclocimmpo32op; flags: []), 

//oc_incdecparimmint32
  (ssa: incdecparimmint32ssa; proc: @incdecparimmint32op; flags: []), 
//oc_incdecparimmpo32
  (ssa: incdecparimmpo32ssa; proc: @incdecparimmpo32op; flags: []), 

//oc_incdecparindiimmint32
  (ssa: incdecparindiimmint32ssa; proc: @incdecparindiimmint32op; flags: []), 
//oc_incdecparindiimmpo32
  (ssa: incdecparindiimmpo32ssa; proc: @incdecparindiimmpo32op; flags: []), 

//oc_incdecindiimmint32
  (ssa: incdecindiimmint32ssa; proc: @incdecindiimmint32op; flags: []), 
//oc_incdecindiimmpo32
  (ssa: incdecindiimmpo32ssa; proc: @incdecindiimmpo32op; flags: []), 

//oc_incsegint32
  (ssa: incsegint32ssa; proc: @incsegint32op; flags: []), 
//oc_incsegpo32
  (ssa: incsegpo32ssa; proc: @incsegpo32op; flags: []), 

//oc_inclocint32
  (ssa: inclocint32ssa; proc: @inclocint32op; flags: []), 
//oc_inclocpo32
  (ssa: inclocpo32ssa; proc: @inclocpo32op; flags: []), 

//oc_incparint32
  (ssa: incparint32ssa; proc: @incparint32op; flags: []), 
//oc_incparpo32
  (ssa: incparpo32ssa; proc: @incparpo32op; flags: []), 

//oc_incparindiint32
  (ssa: incparindiint32ssa; proc: @incparindiint32op; flags: []), 
//oc_incparindipo32
  (ssa: incparindipo32ssa; proc: @incparindipo32op; flags: []), 

//oc_incindiint32
  (ssa: incindiint32ssa; proc: @incindiint32op; flags: []), 
//oc_incindipo32
  (ssa: incindipo32ssa; proc: @incindipo32op; flags: []), 

//oc_decsegint32
  (ssa: decsegint32ssa; proc: @decsegint32op; flags: []), 
//oc_decsegpo32
  (ssa: decsegpo32ssa; proc: @decsegpo32op; flags: []), 

//oc_declocint32
  (ssa: declocint32ssa; proc: @declocint32op; flags: []), 
//oc_declocpo32
  (ssa: declocpo32ssa; proc: @declocpo32op; flags: []), 

//oc_decparint32
  (ssa: decparint32ssa; proc: @decparint32op; flags: []), 
//oc_decparpo32
  (ssa: decparpo32ssa; proc: @decparpo32op; flags: []), 

//oc_decparindiint32
  (ssa: decparindiint32ssa; proc: @decparindiint32op; flags: []), 
//oc_decparindipo32
  (ssa: decparindipo32ssa; proc: @decparindipo32op; flags: []), 

//oc_decindiint32
  (ssa: decindiint32ssa; proc: @decindiint32op; flags: []), 
//oc_decindipo32
  (ssa: decindipo32ssa; proc: @decindipo32op; flags: []), 

//oc_cmpeqpo
  (ssa: cmpeqpossa; proc: @cmpeqpoop; flags: []), 
//oc_cmpeqbool
  (ssa: cmpeqboolssa; proc: @cmpeqboolop; flags: []), 
//oc_cmpeqint32
  (ssa: cmpeqint32ssa; proc: @cmpeqint32op; flags: []), 
//oc_cmpeqflo64
  (ssa: cmpeqflo64ssa; proc: @cmpeqflo64op; flags: []), 

//oc_cmpnepo
  (ssa: cmpnepossa; proc: @cmpnepoop; flags: []), 
//oc_cmpnebool
  (ssa: cmpneboolssa; proc: @cmpneboolop; flags: []), 
//oc_cmpneint32
  (ssa: cmpneint32ssa; proc: @cmpneint32op; flags: []), 
//oc_cmpneflo64
  (ssa: cmpneflo64ssa; proc: @cmpneflo64op; flags: []), 

//oc_cmpgtpo
  (ssa: cmpgtpossa; proc: @cmpgtpoop; flags: []), 
//oc_cmpgtbool
  (ssa: cmpgtboolssa; proc: @cmpgtboolop; flags: []), 
//oc_cmpgtcard32
  (ssa: cmpgtcard32ssa; proc: @cmpgtcard32op; flags: []), 
//oc_cmpgtint32
  (ssa: cmpgtint32ssa; proc: @cmpgtint32op; flags: []), 
//oc_cmpgtflo64
  (ssa: cmpgtflo64ssa; proc: @cmpgtflo64op; flags: []), 

//oc_cmpltpo
  (ssa: cmpltpossa; proc: @cmpltpoop; flags: []), 
//oc_cmpltbool
  (ssa: cmpltboolssa; proc: @cmpltboolop; flags: []), 
//oc_cmpltcard32
  (ssa: cmpltcard32ssa; proc: @cmpltcard32op; flags: []), 
//oc_cmpltint32
  (ssa: cmpltint32ssa; proc: @cmpltint32op; flags: []), 
//oc_cmpltflo64
  (ssa: cmpltflo64ssa; proc: @cmpltflo64op; flags: []), 

//oc_cmpgepo
  (ssa: cmpgepossa; proc: @cmpgepoop; flags: []), 
//oc_cmpgebool
  (ssa: cmpgeboolssa; proc: @cmpgeboolop; flags: []), 
//oc_cmpgecard32
  (ssa: cmpgecard32ssa; proc: @cmpgecard32op; flags: []), 
//oc_cmpgeint32
  (ssa: cmpgeint32ssa; proc: @cmpgeint32op; flags: []), 
//oc_cmpgeflo64
  (ssa: cmpgeflo64ssa; proc: @cmpgeflo64op; flags: []), 

//oc_cmplepo
  (ssa: cmplepossa; proc: @cmplepoop; flags: []), 
//oc_cmplebool
  (ssa: cmpleboolssa; proc: @cmpleboolop; flags: []), 
//oc_cmplecard32
  (ssa: cmplecard32ssa; proc: @cmplecard32op; flags: []), 
//oc_cmpleint32
  (ssa: cmpleint32ssa; proc: @cmpleint32op; flags: []), 
//oc_cmpleflo64
  (ssa: cmpleflo64ssa; proc: @cmpleflo64op; flags: []), 
//oc_setcontains,
  (ssa: setcontainsssa; proc: @setcontainsop; flags: []), 
//oc_setin,
  (ssa: setinssa; proc: @setinop; flags: []), 

//oc_storesegnil
  (ssa: storesegnilssa; proc: @storesegnilop; flags: [of_relocseg]), 
//oc_storereg0nil
  (ssa: storereg0nilssa; proc: @storereg0nilop; flags: []), 
//oc_storeframenil
  (ssa: storeframenilssa; proc: @storeframenilop; flags: []), 
//oc_storestacknil
  (ssa: storestacknilssa; proc: @storestacknilop; flags: []), 
//oc_storestackrefnil
  (ssa: storestackrefnilssa; proc: @storestackrefnilop; flags: []), 
//oc_storesegnilar
  (ssa: storesegnilarssa; proc: @storesegnilarop; flags: [of_relocseg]), 
//oc_storeframenilar
  (ssa: storeframenilarssa; proc: @storeframenilarop; flags: []), 
//oc_storereg0nilar
  (ssa: storereg0nilarssa; proc: @storereg0nilarop; flags: []), 
//oc_storestacknilar
  (ssa: storestacknilarssa; proc: @storestacknilarop; flags: []), 
//oc_storestackrefnilar
  (ssa: storestackrefnilarssa; proc: @storestackrefnilarop; flags: []), 

//oc_finirefsizeseg
  (ssa: finirefsizesegssa; proc: @finirefsizesegop; flags: [of_relocseg]), 
//oc_finirefsizeframe
  (ssa: finirefsizeframessa; proc: @finirefsizeframeop; flags: []), 
//oc_finirefsizereg0
  (ssa: finirefsizereg0ssa; proc: @finirefsizereg0op; flags: []), 
//oc_finirefsizestack
  (ssa: finirefsizestackssa; proc: @finirefsizestackop; flags: []), 
//oc_finirefsizestackref
  (ssa: finirefsizestackrefssa; proc: @finirefsizestackrefop; flags: []), 
//oc_finirefsizeframear
  (ssa: finirefsizeframearssa; proc: @finirefsizeframearop; flags: []), 
//oc_finirefsizesegar
  (ssa: finirefsizesegarssa; proc: @finirefsizesegarop; flags: [of_relocseg]), 
//oc_finirefsizereg0ar
  (ssa: finirefsizereg0arssa; proc: @finirefsizereg0arop; flags: []), 
//oc_finirefsizestackar
  (ssa: finirefsizestackarssa; proc: @finirefsizestackarop; flags: []), 
//oc_finirefsizestackrefar
  (ssa: finirefsizestackrefarssa; proc: @finirefsizestackrefarop; flags: []), 

//oc_increfsizeseg
  (ssa: increfsizesegssa; proc: @increfsizesegop; flags: [of_relocseg]),
//oc_increfsizeframe
  (ssa: increfsizeframessa; proc: @increfsizeframeop; flags: []), 
//oc_increfsizereg0
  (ssa: increfsizereg0ssa; proc: @increfsizereg0op; flags: []), 
//oc_increfsizestack
  (ssa: increfsizestackssa; proc: @increfsizestackop; flags: []), 
//oc_increfsizestackref
  (ssa: increfsizestackrefssa; proc: @increfsizestackrefop; flags: []), 
//oc_increfsizeframear
  (ssa: increfsizeframearssa; proc: @increfsizeframearop; flags: []), 
//oc_increfsizesegar
  (ssa: increfsizesegarssa; proc: @increfsizesegarop; flags: [of_relocseg]),
//oc_increfsizereg0ar
  (ssa: increfsizereg0arssa; proc: @increfsizereg0arop; flags: []), 
//oc_increfsizestackar
  (ssa: increfsizestackarssa; proc: @increfsizestackarop; flags: []), 
//oc_increfsizestackrefar
  (ssa: increfsizestackrefarssa; proc: @increfsizestackrefarop; flags: []), 

//oc_decrefsizeseg
  (ssa: decrefsizesegssa; proc: @decrefsizesegop; flags: [of_relocseg]),
//oc_decrefsizeframe
  (ssa: decrefsizeframessa; proc: @decrefsizeframeop; flags: []), 
//oc_decrefsizereg0
  (ssa: decrefsizereg0ssa; proc: @decrefsizereg0op; flags: []), 
//oc_decrefsizestack
  (ssa: decrefsizestackssa; proc: @decrefsizestackop; flags: []), 
//oc_decrefsizestackref
  (ssa: decrefsizestackrefssa; proc: @decrefsizestackrefop; flags: []), 
//oc_decrefsizeframear
  (ssa: decrefsizeframearssa; proc: @decrefsizeframearop; flags: []), 
//oc_decrefsizesegar
  (ssa: decrefsizesegarssa; proc: @decrefsizesegarop; flags: [of_relocseg]),
//oc_decrefsizereg0ar
  (ssa: decrefsizereg0arssa; proc: @decrefsizereg0arop; flags: []), 
//oc_decrefsizestackar
  (ssa: decrefsizestackarssa; proc: @decrefsizestackarop; flags: []), 
//oc_decrefsizestackrefar
  (ssa: decrefsizestackrefarssa; proc: @decrefsizestackrefarop; flags: []), 

//oc_popseg8
  (ssa: popseg8ssa; proc: @popseg8op; flags: [of_relocseg]), 
//oc_popseg16
  (ssa: popseg16ssa; proc: @popseg16op; flags: [of_relocseg]), 
//oc_popseg32
  (ssa: popseg32ssa; proc: @popseg32op; flags: [of_relocseg]), 
//oc_popseg64
  (ssa: popseg64ssa; proc: @popseg64op; flags: [of_relocseg]), 
//oc_popsegpo
  (ssa: popsegpossa; proc: @popsegpoop; flags: [of_relocseg]), 
//oc_popsegf16
  (ssa: popsegf16ssa; proc: @popsegf16op; flags: [of_relocseg]), 
//oc_popsegf32
  (ssa: popsegf32ssa; proc: @popsegf32op; flags: [of_relocseg]), 
//oc_popsegf64
  (ssa: popsegf64ssa; proc: @popsegf64op; flags: [of_relocseg]), 
//oc_popseg
  (ssa: popsegssa; proc: @popsegop; flags: [of_relocseg]), 

//oc_poploc8
  (ssa: poploc8ssa; proc: @poploc8op; flags: []), 
//oc_poploc16
  (ssa: poploc16ssa; proc: @poploc16op; flags: []), 
//oc_poploc32
  (ssa: poploc32ssa; proc: @poploc32op; flags: []), 
//oc_poploc64
  (ssa: poploc64ssa; proc: @poploc64op; flags: []), 
//oc_poplocpo
  (ssa: poplocpossa; proc: @poplocpoop; flags: []), 
//oc_poplocf16
  (ssa: poplocf16ssa; proc: @poplocf16op; flags: []), 
//oc_poplocf32
  (ssa: poplocf32ssa; proc: @poplocf32op; flags: []), 
//oc_poplocf64
  (ssa: poplocf64ssa; proc: @poplocf64op; flags: []), 
//oc_poploc
  (ssa: poplocssa; proc: @poplocop; flags: []), 

//oc_poplocindi8
  (ssa: poplocindi8ssa; proc: @poplocindi8op; flags: []), 
//oc_poplocindi16
  (ssa: poplocindi16ssa; proc: @poplocindi16op; flags: []), 
//oc_poplocindi32
  (ssa: poplocindi32ssa; proc: @poplocindi32op; flags: []), 
//oc_poplocindi64
  (ssa: poplocindi64ssa; proc: @poplocindi64op; flags: []), 
//oc_poplocindipo
  (ssa: poplocindipossa; proc: @poplocindipoop; flags: []), 
//oc_poplocindif16
  (ssa: poplocindif16ssa; proc: @poplocindif16op; flags: []), 
//oc_poplocindif32
  (ssa: poplocindif32ssa; proc: @poplocindif32op; flags: []), 
//oc_poplocindif64
  (ssa: poplocindif64ssa; proc: @poplocindif64op; flags: []), 
//oc_poplocindi
  (ssa: poplocindissa; proc: @poplocindiop; flags: []), 

//oc_poppar8
  (ssa: poppar8ssa; proc: @poppar8op; flags: []), 
//oc_poppar16
  (ssa: poppar16ssa; proc: @poppar16op; flags: []), 
//oc_poppar32
  (ssa: poppar32ssa; proc: @poppar32op; flags: []), 
//oc_poppar64
  (ssa: poppar64ssa; proc: @poppar64op; flags: []), 
//oc_popparpo
  (ssa: popparpossa; proc: @popparpoop; flags: []), 
//oc_popparf16
  (ssa: popparf16ssa; proc: @popparf16op; flags: []), 
//oc_popparf32
  (ssa: popparf32ssa; proc: @popparf32op; flags: []), 
//oc_popparf64
  (ssa: popparf64ssa; proc: @popparf64op; flags: []), 
//oc_poppar
  (ssa: popparssa; proc: @popparop; flags: []), 

//oc_popparindi8
  (ssa: popparindi8ssa; proc: @popparindi8op; flags: []), 
//oc_popparindi16
  (ssa: popparindi16ssa; proc: @popparindi16op; flags: []), 
//oc_popparindi32
  (ssa: popparindi32ssa; proc: @popparindi32op; flags: []), 
//oc_popparindi64
  (ssa: popparindi64ssa; proc: @popparindi64op; flags: []), 
//oc_popparindipo
  (ssa: popparindipossa; proc: @popparindipoop; flags: []), 
//oc_popparindif16
  (ssa: popparindif16ssa; proc: @popparindif16op; flags: []), 
//oc_popparindif32
  (ssa: popparindif32ssa; proc: @popparindif32op; flags: []), 
//oc_popparindif64
  (ssa: popparindif64ssa; proc: @popparindif64op; flags: []), 
//oc_popparindi
  (ssa: popparindissa; proc: @popparindiop; flags: []), 

//oc_pushnil
  (ssa: pushnilssa; proc: @pushnilop; flags: []), 
//  pushsegaddress
{
//oc_pushstack8
  (ssa: pushstack8ssa; proc: @pushstackindi8op; flags: []), 
//oc_pushstack16
  (ssa: pushstack16ssa; proc: @pushstackindi16op; flags: []), 
//oc_pushstack32
  (ssa: pushstack32ssa; proc: @pushstackindi32op; flags: []), 
//oc_pushstack64
  (ssa: pushstack64ssa; proc: @pushstackindi64op; flags: []), 
//oc_pushstackpo
  (ssa: pushstackpossa; proc: @pushstackindipoop; flags: []), 
//oc_pushstackindi8
  (ssa: pushstackindi8ssa; proc: @pushstackindi8op; flags: []), 
//oc_pushstack16
  (ssa: pushstackindi16ssa; proc: @pushstackindi16op; flags: []), 
//oc_pushstack32
  (ssa: pushstackindi32ssa; proc: @pushstackindi32op; flags: []), 
//oc_pushstack64
  (ssa: pushstackindi64ssa; proc: @pushstackindi64op; flags: []), 
//oc_pushstackpo
  (ssa: pushstackindipossa; proc: @pushstackindipoop; flags: []), 
}
//oc_pushseg8
  (ssa: pushseg8ssa; proc: @pushseg8op; flags: [of_relocseg]), 
//oc_pushseg16
  (ssa: pushseg16ssa; proc: @pushseg16op; flags: [of_relocseg]),
//oc_pushseg32
  (ssa: pushseg32ssa; proc: @pushseg32op; flags: [of_relocseg]),
//oc_pushseg64
  (ssa: pushseg64ssa; proc: @pushseg64op; flags: [of_relocseg]),
//oc_pushsegpo
  (ssa: pushsegpossa; proc: @pushsegpoop; flags: [of_relocseg]),
//oc_pushsegf16
  (ssa: pushsegf16ssa; proc: @pushsegf16op; flags: [of_relocseg]),
//oc_pushsegf32
  (ssa: pushsegf32ssa; proc: @pushsegf32op; flags: [of_relocseg]),
//oc_pushsegf64
  (ssa: pushsegf64ssa; proc: @pushsegf64op; flags: [of_relocseg]),
//oc_pushseg
  (ssa: pushsegssa; proc: @pushsegop; flags: [of_relocseg]),

//oc_pushloc8
  (ssa: pushloc8ssa; proc: @pushloc8op; flags: []), 
//oc_pushloc16
  (ssa: pushloc16ssa; proc: @pushloc16op; flags: []), 
//oc_pushloc32
  (ssa: pushloc32ssa; proc: @pushloc32op; flags: []), 
//oc_pushloc64
  (ssa: pushloc64ssa; proc: @pushloc64op; flags: []), 
//oc_pushlocpo
  (ssa: pushlocpossa; proc: @pushlocpoop; flags: []), 
//oc_pushlocf16
  (ssa: pushlocf16ssa; proc: @pushlocf16op; flags: []), 
//oc_pushlocf32
  (ssa: pushlocf32ssa; proc: @pushlocf32op; flags: []), 
//oc_pushlocf64
  (ssa: pushlocf64ssa; proc: @pushlocf64op; flags: []), 
//oc_pushloc
  (ssa: pushlocssa; proc: @pushlocop; flags: []), 

//oc_pushlocindi8
  (ssa: pushlocindi8ssa; proc: @pushlocindi8op; flags: []), 
//oc_pushlocindi16
  (ssa: pushlocindi16ssa; proc: @pushlocindi16op; flags: []), 
//oc_pushlocindi32
  (ssa: pushlocindi32ssa; proc: @pushlocindi32op; flags: []), 
//oc_pushlocindi64
  (ssa: pushlocindi64ssa; proc: @pushlocindi64op; flags: []), 
//oc_pushlocindipo
  (ssa: pushlocindipossa; proc: @pushlocindipoop; flags: []), 
//oc_pushlocindi16
  (ssa: pushlocindi16ssa; proc: @pushlocindi16op; flags: []), 
//oc_pushlocindi32
  (ssa: pushlocindi32ssa; proc: @pushlocindi32op; flags: []), 
//oc_pushlocindi64
  (ssa: pushlocindi64ssa; proc: @pushlocindi64op; flags: []), 
//oc_pushlocindi
  (ssa: pushlocindi64ssa; proc: @pushlocindi64op; flags: []), 

//oc_pushpar8
  (ssa: pushpar8ssa; proc: @pushpar8op; flags: []), 
//oc_pushpar16
  (ssa: pushpar16ssa; proc: @pushpar16op; flags: []), 
//oc_pushpar32
  (ssa: pushpar32ssa; proc: @pushpar32op; flags: []), 
//oc_pushpar64
  (ssa: pushpar64ssa; proc: @pushpar64op; flags: []), 
//oc_pushparpo
  (ssa: pushparpossa; proc: @pushparpoop; flags: []), 
//oc_pushparf16
  (ssa: pushparf16ssa; proc: @pushparf16op; flags: []), 
//oc_pushparf32
  (ssa: pushparf32ssa; proc: @pushparf32op; flags: []), 
//oc_pushparf64
  (ssa: pushparf64ssa; proc: @pushparf64op; flags: []), 
//oc_pushpar
  (ssa: pushparssa; proc: @pushparop; flags: []), 

//oc_pushaddr
  (ssa: pushaddrssa; proc: @pushaddrop; flags: []), 
//oc_pushlocaddr
  (ssa: pushlocaddrssa; proc: @pushlocaddrop; flags: []), 
//oc_pushsegaddr
  (ssa: pushsegaddrssa; proc: @pushsegaddrop; flags: [of_relocseg]),
//oc_pushstackaddr
  (ssa: pushstackaddrssa; proc: @pushstackaddrop; flags: []), 

//oc_pushduppo
  (ssa: pushduppossa; proc: @pushduppoop; flags: []), 

//oc_indirect8
  (ssa: indirect8ssa; proc: @indirect8op; flags: []), 
//oc_indirect16
  (ssa: indirect16ssa; proc: @indirect16op; flags: []), 
//oc_indirect32
  (ssa: indirect32ssa; proc: @indirect32op; flags: []), 
//oc_indirect64
  (ssa: indirect64ssa; proc: @indirect64op; flags: []), 
//oc_indirectpo
  (ssa: indirectpossa; proc: @indirectpoop; flags: []), 
//oc_indirectf16
  (ssa: indirectf16ssa; proc: @indirectf16op; flags: []), 
//oc_indirectf32
  (ssa: indirectf32ssa; proc: @indirectf32op; flags: []), 
//oc_indirectf64
  (ssa: indirectf64ssa; proc: @indirectf64op; flags: []), 
//oc_indirectpooffs
  (ssa: indirectpooffsssa; proc: @indirectpooffsop; flags: []), 
//oc_indirectoffspo
  (ssa: indirectoffspossa; proc: @indirectoffspoop; flags: []), //oc_indirectoffspo
//oc_indirect
  (ssa: indirectssa; proc: @indirectop; flags: []), 

//oc_popindirect8
  (ssa: popindirect8ssa; proc: @popindirect8op; flags: []), 
//oc_popindirect16
  (ssa: popindirect16ssa; proc: @popindirect16op; flags: []), 
//oc_popindirect32
  (ssa: popindirect32ssa; proc: @popindirect32op; flags: []), 
//oc_popindirect64
  (ssa: popindirect64ssa; proc: @popindirect64op; flags: []), 
//oc_popindirectpo
  (ssa: popindirectpossa; proc: @popindirectpoop; flags: []), 
//oc_popindirectf16
  (ssa: popindirectf16ssa; proc: @popindirectf16op; flags: []), 
//oc_popindirectf32
  (ssa: popindirectf32ssa; proc: @popindirectf32op; flags: []), 
//oc_popindirectf64
  (ssa: popindirectf64ssa; proc: @popindirectf64op; flags: []), 
//oc_popindirect
  (ssa: popindirectssa; proc: @popindirectop; flags: []), 

//oc_locvarpush
  (ssa: locvarpushssa; proc: @locvarpushop; flags: []), 
//oc_locvarpop
  (ssa: locvarpopssa; proc: @locvarpopop; flags: []), 

//oc_subbegin
  (ssa: subbeginssa; proc: @subbeginop; flags: []), 
//oc_subend
  (ssa: subendssa; proc: @subendop; flags: []), 
//oc_externalsub
  (ssa: externalsubssa; proc: @externalsubop; flags: []), 
//oc_return
  (ssa: returnssa; proc: @returnop; flags: []), 
//oc_returnfunc
  (ssa: returnfuncssa; proc: @returnfuncop; flags: []), 

//oc_setlengthstr8
  (ssa: setlengthstr8ssa; proc: @setlengthstr8op; flags: []), 
//oc_setlengthdynarray
  (ssa: setlengthdynarrayssa; proc: @setlengthdynarrayop; flags: []), 

//oc_pushcpucontext
  (ssa: pushcpucontextssa; proc: @pushcpucontextop; flags: []), 
//oc_popcpucontext
  (ssa: popcpucontextssa; proc: @popcpucontextop; flags: []), 
//oc_finiexception
  (ssa: finiexceptionssa; proc: @finiexceptionop; flags: []), 
//oc_continueexception
  (ssa: continueexceptionssa; proc: @continueexceptionop; flags: []), 
//oc_getmem
  (ssa: getmemssa; proc: @getmemop; flags: []), 
//oc_getzeromem
  (ssa: getzeromemssa; proc: @getzeromemop; flags: []), 
//oc_freemem
  (ssa: freememssa; proc: @freememop; flags: []), 
//oc_setmem
  (ssa: setmemssa; proc: @setmemop; flags: []), 
  
//oc_sin64
  (ssa: sin64ssa; proc: @sin64op; flags: []), 
  
//oc_lineinfo
  (ssa: lineinfossa; proc: @lineinfoop; flags: []), 

//ssaonly
//oc_nestedvar
  (ssa: nestedvarssa; proc: nil; flags: []), 
//oc_popnestedvar
  (ssa: popnestedvarssa; proc: nil; flags: []), 
//oc_pushnestedvar
  (ssa: pushnestedvarssa; proc: nil; flags: []), 
//oc_aggregate
  (ssa: aggregatessa; proc: nil; flags: []), 
//oc_alloc
  (ssa: allocssa; proc: nil; flags: []), 
//oc_nestedcallout
  (ssa: nestedcalloutssa; proc: nil; flags: []), 
//oc_hascallout
  (ssa: hascalloutssa; proc: nil; flags: []), 
//oc_pushsegaddrnil
  (ssa: pushsegaddrnilssa; proc: nil; flags: []), 
//oc_pushsegaddrglobvar
  (ssa: pushsegaddrglobvarssa; proc: nil; flags: []), 
//oc_pushsegaddrglobconst
  (ssa: pushsegaddrglobconstssa; proc: nil; flags: []), 
//oc_pushsegaddrclassdef
  (ssa: pushsegaddrclassdefssa; proc: nil; flags: []) 
 );
