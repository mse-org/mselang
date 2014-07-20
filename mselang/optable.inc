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

 optable: optablety = (
  nil,  //oc_none
  @nop,

  @beginparseop,
  @progendop,  //oc_progend
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

  @push8op,
  @push16op,
  @push32op,
  @push64op,
  @pushdatakindop,
  
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

  @pushnilop,
  @pushsegaddressop,

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
  @returnop,

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
