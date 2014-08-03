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

 ssatable: ssatablety = (
  nonessa,
  nopssa,

  beginparsessa,
  mainssa,
  progendssa,  
  endparsessa,

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

  ifssa,
  writelnssa,
  writebooleanssa,
  writeintegerssa,
  writefloatssa,
  writestring8ssa,
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
  
  negcard32ssa,
  negint32ssa,
  negflo64ssa,

  mulint32ssa,
  mulflo64ssa,
  addint32ssa,
  addflo64ssa,

  addimmint32ssa,
  mulimmint32ssa,
  offsetpoimm32ssa,

  cmpequboolssa,
  cmpequint32ssa,
  cmpequflo64ssa,

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
  popsegssa,

  poploc8ssa,
  poploc16ssa,
  poploc32ssa,
  poplocssa,

  poplocindi8ssa,
  poplocindi16ssa,
  poplocindi32ssa,
  poplocindissa,

  poppar8ssa,
  poppar16ssa,
  poppar32ssa,
  popparssa,

  popparindi8ssa,
  popparindi16ssa,
  popparindi32ssa,
  popparindissa,

  pushnilssa,
//  pushsegaddressssa,

  pushseg8ssa,
  pushseg16ssa,
  pushseg32ssa,
  pushsegssa,

  pushloc8ssa,
  pushloc16ssa,
  pushloc32ssa,
  pushlocpossa,
  pushlocssa,

  pushlocindi8ssa,
  pushlocindi16ssa,
  pushlocindi32ssa,
  pushlocindissa,

  pushpar8ssa,
  pushpar16ssa,
  pushpar32ssa,
  pushparpossa,
  pushparssa,

  pushaddrssa,
  pushlocaddrssa,
  pushlocaddrindissa,
  pushsegaddrssa,
  pushsegaddrindissa,
  pushstackaddrssa,
  pushstackaddrindissa,

  indirect8ssa,
  indirect16ssa,
  indirect32ssa,
  indirectpossa,
  indirectpooffsssa,
  indirectoffspossa,
  indirectssa,

  popindirect8ssa,
  popindirect16ssa,
  popindirect32ssa,
  popindirectssa,

  callssa,
  calloutssa,
  callvirtssa,
  callintfssa,
  virttrampolinessa,

  locvarpushssa,
  locvarpopssa,

  subbeginssa,
  subendssa,
  returnssa,
  returnfuncssa,

  initclassssa,
  destroyclassssa,

  decloop32ssa,
  decloop64ssa,

  setlengthstr8ssa,

  raisessa,
  pushcpucontextssa,
  popcpucontextssa,
  finiexceptionssa,
  continueexceptionssa
 );
 optable: optablety = ( //order as opcodety
  nil,  //oc_none
  @nopop,

  @beginparseop,
  @mainop,
  @progendop,  
  @endparseop,

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

  @ifop,
  @writelnop,
  @writebooleanop,
  @writeintegerop,
  @writefloatop,
  @writestring8op,
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
  
  @negcard32op,
  @negint32op,
  @negflo64op,

  @mulint32op,
  @mulflo64op,
  @addint32op,
  @addflo64op,

  @addimmint32op,
  @mulimmint32op,
  @offsetpoimm32op,

  @cmpequboolop,
  @cmpequint32op,
  @cmpequflo64op,

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
  @popsegop,

  @poploc8op,
  @poploc16op,
  @poploc32op,
  @poplocop,

  @poplocindi8op,
  @poplocindi16op,
  @poplocindi32op,
  @poplocindiop,

  @poppar8op,
  @poppar16op,
  @poppar32op,
  @popparop,

  @popparindi8op,
  @popparindi16op,
  @popparindi32op,
  @popparindiop,

  @pushnilop,
//  @pushsegaddressop,

  @pushseg8op,
  @pushseg16op,
  @pushseg32op,
  @pushsegop,

  @pushloc8op,
  @pushloc16op,
  @pushloc32op,
  @pushlocpoop,
  @pushlocop,

  @pushlocindi8op,
  @pushlocindi16op,
  @pushlocindi32op,
  @pushlocindiop,

  @pushpar8op,
  @pushpar16op,
  @pushpar32op,
  @pushparpoop,
  @pushparop,

  @pushaddrop,
  @pushlocaddrop,
  @pushlocaddrindiop,
  @pushsegaddrop,
  @pushsegaddrindiop,
  @pushstackaddrop,
  @pushstackaddrindiop,

  @indirect8op,
  @indirect16op,
  @indirect32op,
  @indirectpoop,
  @indirectpooffsop, //offset after indirect
  @indirectoffspoop, //offset before indirect
  @indirectop,

  @popindirect8op,
  @popindirect16op,
  @popindirect32op,
  @popindirectop,

  @callop,
  @calloutop,
  @callvirtop,
  @callintfop,
  @virttrampolineop,

  @locvarpushop,
  @locvarpopop,

  @subbeginop,
  @subendop,
  @returnop,
  @returnfuncop,

  @initclassop,
  @destroyclassop,

  @decloop32op,
  @decloop64op,

  @setlengthstr8op,

  @raiseop,
  @pushcpucontextop,
  @popcpucontextop,
  @finiexceptionop,
  @continueexceptionop
 );
