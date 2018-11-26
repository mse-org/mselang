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
//oc_none
  (ssa: nonessa; proc: nil; flags: []), 

//oc_label                                           //controlops
  (ssa: labelssa; proc: @labelop; flags: [of_control]),           
//oc_if
  (ssa: ifssa; proc: @ifop; flags: [of_control]), 
//oc_ifnot
  (ssa: ifnotssa; proc: @ifnotop; flags: [of_control]), 
//oc_while
  (ssa: whilessa; proc: @whileop; flags: [of_control]), 
//oc_until
  (ssa: untilssa; proc: @untilop; flags: [of_control]), 
//oc_decloop32
  (ssa: decloop32ssa; proc: @decloop32op; flags: [of_control]), 
//oc_decloop64
  (ssa: decloop64ssa; proc: @decloop64op; flags: [of_control]), 

                                                   //callops
//oc_raise
  (ssa: raisessa; proc: @raiseop; flags: [of_bbinc1]), 
//oc_finiexception
  (ssa: finiexceptionssa; proc: @finiexceptionop; flags: [of_bbinc1]), 
//oc_unhandledexception
  (ssa: unhandledexceptionssa; proc: @unhandledexceptionop; flags: [of_bbinc1]), 
//oc_continueexception
  (ssa: continueexceptionssa; proc: @continueexceptionop; flags: [of_bbinc1]), 

//oc_call
  (ssa: callssa; proc: @callop; flags: [of_bbinc1,of_sub]),
//oc_callfunc
  (ssa: callfuncssa; proc: @callfuncop; flags: [of_bbinc1,of_sub]), 
//oc_callout
  (ssa: calloutssa; proc: @calloutop; flags: [of_bbinc1,of_sub]), 
//oc_callfuncout
  (ssa: callfuncoutssa; proc: @callfuncoutop; flags: [of_bbinc1,of_sub]), 
//oc_callvirt
  (ssa: callvirtssa; proc: @callvirtop; flags: [of_bbinc1,of_sub]), 
//oc_callvirtclass
  (ssa: callvirtclassssa; proc: @callvirtclassop; flags: [of_bbinc1,of_sub]), 
//oc_callvirtfunc
  (ssa: callvirtfuncssa; proc: @callvirtfuncop; flags: [of_bbinc1,of_sub]), 
//oc_callvirtclassfunc
  (ssa: callvirtclassfuncssa; proc: @callvirtclassfuncop;
                                                flags: [of_bbinc1,of_sub]), 
//oc_callintf
  (ssa: callintfssa; proc: @callintfop; flags: [of_bbinc1,of_sub]), 
//oc_callintffunc
  (ssa: callintffuncssa; proc: @callintffuncop; flags: [of_bbinc1,of_sub]), 
//oc_virttrampoline
  (ssa: virttrampolinessa; proc: @virttrampolineop; flags: [of_bbinc1]), 

//oc_callindi
  (ssa: callindissa; proc: @callindiop; flags: [of_bbinc1,of_sub]), 
//oc_callfuncindi
  (ssa: callfuncindissa; proc: @callfuncindiop; flags: [of_bbinc1,of_sub]), 

//oc_return
  (ssa: returnssa; proc: @returnop; flags: [of_control]), 
//oc_returnfunc
  (ssa: returnfuncssa; proc: @returnfuncop; flags: [of_control]), 

//oc_zeromem
  (ssa: zeromemssa; proc: @zeromemop; flags: [of_bbinc1]), 
//oc_zeromemindi
  (ssa: zeromemindissa; proc: @zeromemindiop; flags: [of_bbinc1]), 
//oc_getobjectmem
  (ssa: getobjectmemssa; proc: @getobjectmemop; flags: [of_bbinc1]), 
//oc_getobjectzeromem
  (ssa: getobjectzeromemssa; proc: @getobjectzeromemop; flags: [of_bbinc1]), 
//oc_iniobject
  (ssa: iniobjectssa; proc: @iniobjectop; flags: [of_bbinc1]), 
//oc_iniobject1
//  (ssa: iniobject1ssa; proc: @iniobject1op; flags: []), 
//oc_callclassdefproc
  (ssa: callclassdefprocssa; proc: @callclassdefprocop; flags: [of_bbinc1]), 
//oc_callclassdefproc2
  (ssa: callclassdefproc2ssa; proc: @callclassdefproc2op; flags: [of_bbinc1]), 
//oc_destroyclass
  (ssa: destroyclassssa; proc: @destroyclassop; flags: [of_bbinc1]), 
//oc_getclassdef,
  (ssa: getclassdefssa; proc: @getclassdefop; flags: [of_bbinc1]), 
//oc_getclassrtti,
  (ssa: getclassrttissa; proc: @getclassrttiop; flags: [of_bbinc1]), 
//oc_classis,
  (ssa: classisssa; proc: @classisop; flags: [of_bbinc1]), 
//oc_checkclasstype,
  (ssa: checkclasstypessa; proc: @checkclasstypeop; flags: [of_bbinc1]), 
//oc_checkexceptclasstype,
  (ssa: checkexceptclasstypessa; proc: @checkexceptclasstypeop;
                                                         flags: [of_bbinc1]), 
//oc_cmpstring
  (ssa: cmpstringssa; proc: @cmpstringop; flags: [of_bbinc1]), 

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
  (ssa: progendssa; proc: @progendop; flags: [of_control]), 
//oc_progend1
  (ssa: progend1ssa; proc: @progend1op; flags: []), 
//oc_halt
  (ssa: haltssa; proc: @haltop; flags: [of_bbinc1,of_bbinc2]), 
//oc_halt1
  (ssa: halt1ssa; proc: @halt1op; flags: [of_bbinc1]), 

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
  (ssa: gotossa; proc: @gotoop; flags: [of_control]), 
//oc_gotofalse
  (ssa: gotofalsessa; proc: @gotofalseop; flags: [of_control]), 
//oc_gotofalseoffs
  (ssa: gotofalseoffsssa; proc: @gotofalseoffsop; flags: [of_control]), 
//oc_gototrue
  (ssa: gototruessa; proc: @gototrueop; flags: [of_control]), 
//oc_gotonil
  (ssa: gotonilssa; proc: @gotonilop; flags: [of_control]), 
//oc_gotonilindirect
  (ssa: gotonilindirectssa; proc: @gotonilindirectop; flags: [of_control]), 
//oc_cmpjmpneimm
  (ssa: cmpjmpneimmssa; proc: @cmpjmpneimmop; flags: [of_control]), 
//oc_cmpjmpeqimm
  (ssa: cmpjmpeqimmssa; proc: @cmpjmpeqimmop; flags: [of_control]), 
//oc_cmpjmploimm
  (ssa: cmpjmploimmssa; proc: @cmpjmploimmop; flags: [of_control]), 
//oc_cmpjmpgtimm
  (ssa: cmpjmpgtimmssa; proc: @cmpjmpgtimmop; flags: [of_control]), 
//oc_cmpjmploeqimm
  (ssa: cmpjmploeqimmssa; proc: @cmpjmploeqimmop; flags: [of_control]), 

//oc_writeln
  (ssa: writelnssa; proc: @writelnop; flags: [of_bbinc1,of_bbinc2]), 
//oc_writeboolean
  (ssa: writebooleanssa; proc: @writebooleanop; flags: [of_bbinc1]), 
//oc_writecardinal8
  (ssa: writecardinal8ssa; proc: @writecardinal8op; flags: [of_bbinc1]), 
//oc_writecardinal16
  (ssa: writecardinal16ssa; proc: @writecardinal16op; flags: [of_bbinc1]), 
//oc_writecardinal32
  (ssa: writecardinal32ssa; proc: @writecardinal32op; flags: [of_bbinc1]), 
//oc_writecardinal64
  (ssa: writecardinal64ssa; proc: @writecardinal64op; flags: [of_bbinc1]), 
//oc_writeinteger8
  (ssa: writeinteger8ssa; proc: @writeinteger8op; flags: [of_bbinc1]), 
//oc_writeinteger16
  (ssa: writeinteger16ssa; proc: @writeinteger16op; flags: [of_bbinc1]), 
//oc_writeinteger32
  (ssa: writeinteger32ssa; proc: @writeinteger32op; flags: [of_bbinc1]), 
//oc_writeinteger64
  (ssa: writeinteger64ssa; proc: @writeinteger64op; flags: [of_bbinc1]), 
//oc_writefloat32
  (ssa: writefloat32ssa; proc: @writefloat32op; flags: [of_bbinc1]), 
//oc_writefloat64
  (ssa: writefloat64ssa; proc: @writefloat64op; flags: [of_bbinc1]), 
//oc_writechar8
  (ssa: writechar8ssa; proc: @writechar8op; flags: [of_bbinc1]), 
//oc_writechar16
  (ssa: writechar16ssa; proc: @writechar16op; flags: [of_bbinc1]), 
//oc_writechar32
  (ssa: writechar32ssa; proc: @writechar32op; flags: [of_bbinc1]), 
//oc_writestring8
  (ssa: writestring8ssa; proc: @writestring8op; flags: [of_bbinc1]), 
//oc_writestring16
  (ssa: writestring16ssa; proc: @writestring16op;
                            flags: [of_bbinc1,of_bbinc2,of_bbinc3]), 
//oc_writestring32
  (ssa: writestring32ssa; proc: @writestring32op;
                            flags: [of_bbinc1,of_bbinc2,of_bbinc3]), 
//oc_writepointer
  (ssa: writepointerssa; proc: @writepointerop; flags: [of_bbinc1]), 
//oc_writeclass
  (ssa: writeclassssa; proc: @writeclassop; flags: [of_bbinc1]), 
//oc_writeenum
  (ssa: writeenumssa; proc: @writeenumop; flags: [of_bbinc1]), 

//oc_nop
  (ssa: nopssa; proc: @nopop; flags: []),
//oc_nopssa
  (ssa: nopssassa; proc: @nopssaop; flags: []), 

//oc_push
  (ssa: pushssa; proc: @pushop; flags: []), 
//oc_pop
  (ssa: popssa; proc: @popop; flags: []),
//oc_swapstack
  (ssa: swapstackssa; proc: @swapstackop; flags: []),
//oc_movestack
  (ssa: movestackssa; proc: @movestackop; flags: []),

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
//oc_pushimmpo
  (ssa: pushimmpossa; proc: @pushimmpoop; flags: []), 
//oc_pushimmf32
  (ssa: pushimmf32ssa; proc: @pushimmf32op; flags: []), 
//oc_pushimmf64
  (ssa: pushimmf64ssa; proc: @pushimmf64op; flags: []), 
//oc_pushimmbigint
  (ssa: pushimmbigintssa; proc: @pushimmbigintop; flags: []), 
//oc_pushimmbigintindi
  (ssa: pushimmbigintindissa; proc: @pushimmbigintindiop; flags: []), 
//oc_pushimmdatakind
  (ssa: pushimmdatakindssa; proc: @pushimmdatakindop; flags: []), 
  
//oc_card8toflo32,
  (ssa: card8toflo32ssa; proc: @card8toflo32op; flags: []), 
//oc_card16toflo32,
  (ssa: card16toflo32ssa; proc: @card16toflo32op; flags: []), 
//oc_card32toflo32,
  (ssa: card32toflo32ssa; proc: @card32toflo32op; flags: []), 
//oc_card64toflo32,
  (ssa: card64toflo32ssa; proc: @card64toflo32op; flags: []), 

//oc_int8toflo32,
  (ssa: int8toflo32ssa; proc: @int8toflo32op; flags: []), 
//oc_int16toflo32,
  (ssa: int16toflo32ssa; proc: @int16toflo32op; flags: []), 
//oc_int32toflo32,
  (ssa: int32toflo32ssa; proc: @int32toflo32op; flags: []), 
//oc_int64toflo32,
  (ssa: int64toflo32ssa; proc: @int64toflo32op; flags: []), 

//oc_card8toflo64,
  (ssa: card8toflo64ssa; proc: @card8toflo64op; flags: []), 
//oc_card16toflo64,
  (ssa: card16toflo64ssa; proc: @card16toflo64op; flags: []), 
//oc_card32toflo64,
  (ssa: card32toflo64ssa; proc: @card32toflo64op; flags: []), 
//oc_card64toflo64,
  (ssa: card64toflo64ssa; proc: @card64toflo64op; flags: []), 

//oc_int8toflo64,
  (ssa: int8toflo64ssa; proc: @int8toflo64op; flags: []), 
//oc_int16toflo64,
  (ssa: int16toflo64ssa; proc: @int16toflo64op; flags: []), 
//oc_int32toflo64,
  (ssa: int32toflo64ssa; proc: @int32toflo64op; flags: []), 
//oc_int64toflo64,
  (ssa: int64toflo64ssa; proc: @int64toflo64op; flags: []), 

//oc_potoint8
  (ssa: potoint8ssa; proc: @potoint8op; flags: []), 
//oc_potoint16
  (ssa: potoint16ssa; proc: @potoint16op; flags: []), 
//oc_potoint32
  (ssa: potoint32ssa; proc: @potoint32op; flags: []), 
//oc_potoint64
  (ssa: potoint64ssa; proc: @potoint64op; flags: []), 

//oc_inttopo
  (ssa: inttopossa; proc: @inttopoop; flags: []), 
//oc_potopo
  (ssa: potopossa; proc: @potopoop; flags: []), 

//oc_and1
  (ssa: and1ssa; proc: @and1op; flags: []), 
//oc_and
  (ssa: andssa; proc: @andop; flags: []), 
//oc_or1
  (ssa: or1ssa; proc: @or1op; flags: []), 
//oc_or
  (ssa: orssa; proc: @orop; flags: []), 
//oc_xor1
  (ssa: xor1ssa; proc: @xor1op; flags: []), 
//oc_xor
  (ssa: xorssa; proc: @xorop; flags: []), 

//oc_shl
  (ssa: shlssa; proc: @shlop; flags: []), 
//oc_shr
  (ssa: shrssa; proc: @shrop; flags: []), 
//oc_shrint
  
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

//oc_flo32toflo64
  (ssa: flo32toflo64ssa; proc: @flo32toflo64op; flags: []), 
//oc_flo64toflo32
  (ssa: flo64toflo32ssa; proc: @flo64toflo32op; flags: []), 
//oc_truncint32flo64
  (ssa: truncint32flo64ssa; proc: @truncint32flo64op; flags: []), 
//oc_truncint32flo32
  (ssa: truncint32flo32ssa; proc: @truncint32flo32op; flags: []), 
//oc_truncint64flo64
  (ssa: truncint64flo64ssa; proc: @truncint64flo64op; flags: []), 
//oc_trunccard32flo64
  (ssa: trunccard32flo64ssa; proc: @trunccard32flo64op; flags: []), 
//oc_truncint32flo32
  (ssa: trunccard32flo32ssa; proc: @trunccard32flo32op; flags: []), 
//oc_truncint64flo64
  (ssa: trunccard64flo64ssa; proc: @trunccard64flo64op; flags: []), 

//oc_card1toint32
  (ssa: card1toint32ssa; proc: @card1toint32op; flags: []), 

//oc_string8to16
  (ssa: string8to16ssa; proc: @string8to16op; flags: [of_bbinc1]), 
//oc_string8to32
  (ssa: string8to32ssa; proc: @string8to32op; flags: [of_bbinc1]), 
//oc_string16to8
  (ssa: string16to8ssa; proc: @string16to8op; flags: [of_bbinc1]), 
//oc_string16to32
  (ssa: string16to32ssa; proc: @string16to32op; flags: [of_bbinc1]), 
//oc_string32to8
  (ssa: string32to8ssa; proc: @string32to8op; flags: [of_bbinc1]), 
//oc_string32to16
  (ssa: string32to16ssa; proc: @string32to16op; flags: [of_bbinc1]), 
//oc_bytestostring
  (ssa: bytestostringssa; proc: @bytestostringop; flags: [of_bbinc1]), 
//oc_stringtobytes
  (ssa: stringtobytesssa; proc: @stringtobytesop; flags: [of_bbinc1]), 

//oc_concatstring8
  (ssa: concatstring8ssa; proc: @concatstring8op; flags: [of_bbinc1,of_list]), 
//oc_concatstring16
  (ssa: concatstring16ssa; proc: @concatstring16op; flags: [of_bbinc1,of_list]), 
//oc_concatstring32
  (ssa: concatstring32ssa; proc: @concatstring32op; flags: [of_bbinc1,of_list]), 
  
//oc_chartostring8
  (ssa: chartostring8ssa; proc: @chartostring8op; flags: [of_bbinc1]),
//oc_chartostring16
  (ssa: chartostring16ssa; proc: @chartostring16op; flags: [of_bbinc1]),
//oc_chartostring32
  (ssa: chartostring32ssa; proc: @chartostring32op; flags: [of_bbinc1]),
//oc_arraytoopenar
  (ssa: arraytoopenarssa; proc: @arraytoopenarop; flags: [of_bbinc1]), 
//oc_arraytoopenarad
  (ssa: arraytoopenaradssa; proc: @arraytoopenaradop; flags: [of_bbinc1]), 
//oc_dynarraytoopenar
  (ssa: dynarraytoopenarssa; proc: @dynarraytoopenarop; flags: [of_bbinc1]), 
//oc_dynarraytoopenarad
  (ssa: dynarraytoopenaradssa; proc: @dynarraytoopenaradop; flags: [of_bbinc1]), 
//oc_listtoopenar
  (ssa: listtoopenarssa; proc: @listtoopenarop; flags: [of_list,of_bbinc1]), 
//oc_listtoopenarad
  (ssa: listtoopenaradssa; proc: @listtoopenaradop; flags: [of_list,of_bbinc1]), 
//oc_listtoarrayofconst
  (ssa: listtoarrayofconstssa; proc: @listtoarrayofconstop;
                                          flags: [of_list,of_bbinc1{,of_bbinc2}]), 
//oc_listtoarrayofconstad
  (ssa: listtoarrayofconstadssa; proc: @listtoarrayofconstadop;
                                         flags: [of_list,of_bbinc1{,of_bbinc2}]), 

//oc_combinemethod
  (ssa: combinemethodssa; proc: @combinemethodop; flags: []), 
//oc_getmethodcode
  (ssa: getmethodcodessa; proc: @getmethodcodeop; flags: []), 
//oc_getmethoddata
  (ssa: getmethoddatassa; proc: @getmethoddataop; flags: []), 
//oc_getvirtsubad
  (ssa: getvirtsubadssa; proc: @getvirtsubadop; flags: []), 
//oc_getintfmethod
  (ssa: getintfmethodssa; proc: @getintfmethodop; flags: []), 

//oc_not1
  (ssa: not1ssa; proc: @not1op; flags: []), 
//oc_not
  (ssa: notssa; proc: @notop; flags: []), 

//oc_negcard
  (ssa: negcardssa; proc: @negcardop; flags: []), 
//oc_negint
  (ssa: negintssa; proc: @negintop; flags: []), 
//oc_negflo
  (ssa: negflossa; proc: @negfloop; flags: []), 
//oc_absint
  (ssa: absintssa; proc: @absintop; flags: []), 
//oc_absflo
  (ssa: absflossa; proc: @absfloop; flags: []), 

//oc_mulcard
  (ssa: mulcardssa; proc: @mulcardop; flags: []), 
//oc_mulint
  (ssa: mulintssa; proc: @mulintop; flags: []), 
//oc_divcard
  (ssa: divcardssa; proc: @divcardop; flags: []), 
//oc_divint
  (ssa: divintssa; proc: @divintop; flags: []), 
//oc_modcard
  (ssa: modcardssa; proc: @modcardop; flags: []), 
//oc_modint
  (ssa: modintssa; proc: @modintop; flags: []), 
//oc_mulflo
  (ssa: mulflossa; proc: @mulfloop; flags: []), 
//oc_divflo
  (ssa: divflossa; proc: @divfloop; flags: []), 
//oc_addint
  (ssa: addintssa; proc: @addintop; flags: []), 
//oc_subint
  (ssa: subintssa; proc: @subintop; flags: []), 
//oc_addpoint
  (ssa: addpointssa; proc: @addpointop; flags: []), 
//oc_subpoint
  (ssa: subpointssa; proc: @subpointop; flags: []), 
//oc_subpo
  (ssa: subpossa; proc: @subpoop; flags: []), 
//oc_addflo
  (ssa: addflossa; proc: @addfloop; flags: []), 
//oc_subflo
  (ssa: subflossa; proc: @subfloop; flags: []), 
//oc_diffset
  (ssa: diffsetssa; proc: @diffsetop; flags: []), 
//oc_xorset
  (ssa: xorsetssa; proc: @xorsetop; flags: []), 

//oc_setbit
  (ssa: setbitssa; proc: @setbitop; flags: []), 
//oc_setbitrange
  (ssa: setbitrangessa; proc: @setbitrangeop; flags: []), 

//oc_addimmint
  (ssa: addimmintssa; proc: @addimmintop; flags: []), 
//oc_mulimmint
  (ssa: mulimmintssa; proc: @mulimmintop; flags: []), 
//oc_offsetpoimm
  (ssa: offsetpoimmssa; proc: @offsetpoimmop; flags: []), 

//oc_incdecsegimmint
  (ssa: incdecsegimmintssa; proc: @incdecsegimmintop; flags: [of_relocseg]), 
//oc_incdecsegimmpo
  (ssa: incdecsegimmpossa; proc: @incdecsegimmpoop; flags: [of_relocseg]), 

//oc_incdeclocimmint
  (ssa: incdeclocimmintssa; proc: @incdeclocimmintop; flags: []), 
//oc_incdeclocimmpo
  (ssa: incdeclocimmpossa; proc: @incdeclocimmpoop; flags: []), 

//oc_incdecparimmint
  (ssa: incdecparimmintssa; proc: @incdecparimmintop; flags: []), 
//oc_incdecparimmpo
  (ssa: incdecparimmpossa; proc: @incdecparimmpoop; flags: []), 

//oc_incdecparindiimmint
  (ssa: incdecparindiimmintssa; proc: @incdecparindiimmintop; flags: []), 
//oc_incdecparindiimmpo
  (ssa: incdecparindiimmpossa; proc: @incdecparindiimmpoop; flags: []), 

//oc_incdecindiimmint
  (ssa: incdecindiimmintssa; proc: @incdecindiimmintop; flags: []), 
//oc_incdecindiimmpo
  (ssa: incdecindiimmpossa; proc: @incdecindiimmpoop; flags: []), 

//oc_incsegint
  (ssa: incsegintssa; proc: @incsegintop; flags: []), 
//oc_incsegpo
  (ssa: incsegpossa; proc: @incsegpoop; flags: []), 

//oc_inclocint
  (ssa: inclocintssa; proc: @inclocintop; flags: []), 
//oc_inclocpo
  (ssa: inclocpossa; proc: @inclocpoop; flags: []), 

//oc_incparint
  (ssa: incparintssa; proc: @incparintop; flags: []), 
//oc_incparpo
  (ssa: incparpossa; proc: @incparpoop; flags: []), 

//oc_incparindiint
  (ssa: incparindiintssa; proc: @incparindiintop; flags: []), 
//oc_incparindipo
  (ssa: incparindipossa; proc: @incparindipoop; flags: []), 

//oc_incindiint
  (ssa: incindiintssa; proc: @incindiintop; flags: []), 
//oc_incindipo
  (ssa: incindipossa; proc: @incindipoop; flags: []), 

//oc_decsegint
  (ssa: decsegintssa; proc: @decsegintop; flags: []), 
//oc_decsegpo
  (ssa: decsegpossa; proc: @decsegpoop; flags: []), 

//oc_declocint
  (ssa: declocintssa; proc: @declocintop; flags: []), 
//oc_declocpo
  (ssa: declocpossa; proc: @declocpoop; flags: []), 

//oc_decparint
  (ssa: decparintssa; proc: @decparintop; flags: []), 
//oc_decparpo
  (ssa: decparpossa; proc: @decparpoop; flags: []), 

//oc_decparindiint
  (ssa: decparindiintssa; proc: @decparindiintop; flags: []), 
//oc_decparindipo
  (ssa: decparindipossa; proc: @decparindipoop; flags: []), 

//oc_decindiint
  (ssa: decindiintssa; proc: @decindiintop; flags: []), 
//oc_decindipo
  (ssa: decindipossa; proc: @decindipoop; flags: []), 

//oc_cmppo
  (ssa: cmppossa; proc: @cmppoop; flags: []), 
//oc_cmpbool
  (ssa: cmpboolssa; proc: @cmpboolop; flags: []), 
//oc_cmpcard
  (ssa: cmpcardssa; proc: @cmpcardop; flags: []), 
//oc_cmpint
  (ssa: cmpintssa; proc: @cmpintop; flags: []), 
//oc_cmpflo
  (ssa: cmpflossa; proc: @cmpfloop; flags: []), 

{
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
}
//oc_setcontains,
  (ssa: setcontainsssa; proc: @setcontainsop; flags: []), 
//oc_setin,
  (ssa: setinssa; proc: @setinop; flags: []), 
//oc_setinindi,
  (ssa: setinindissa; proc: @setinindiop; flags: [of_bbinc1]), 
//oc_setsetele
  (ssa: setsetelessa; proc: @setseteleop;flags: []),
//oc_setexpand
  (ssa: setexpandssa; proc: @setexpandop;flags: []),
//oc_include
  (ssa: includessa; proc: @includeop;flags: []), 
//oc_exclude
  (ssa: excludessa; proc: @excludeop;flags: []), 

//oc_storesegnil
  (ssa: storesegnilssa; proc: @storesegnilop; flags: [of_relocseg]), 
//oc_storelocnil
  (ssa: storelocnilssa; proc: @storelocnilop; flags: []), 
//oc_storelocindinil
  (ssa: storelocindinilssa; proc: @storelocindinilop; flags: []), 
//oc_storestacknil
  (ssa: storestacknilssa; proc: @storestacknilop; flags: []), 
//oc_storestackindinil
  (ssa: storestackindinilssa; proc: @storestackindinilop; flags: []), 
//oc_storestackindpopinil
  (ssa: storestackindipopnilssa; proc: @storestackindipopnilop; flags: []), 
//oc_storestackrefnil
  (ssa: storestackrefnilssa; proc: @storestackrefnilop; flags: []), 
//oc_storetempvarnil
  (ssa: storetempvarnilssa; proc: @storetempvarnilop; flags: []), 

//oc_storesegnilar
  (ssa: storesegnilarssa; proc: @storesegnilarop; flags: [of_relocseg]), 
//oc_storelocnilar
  (ssa: storelocnilarssa; proc: @storelocnilarop; flags: []), 
//oc_storelocindinilar
  (ssa: storelocindinilarssa; proc: @storelocindinilarop; flags: []), 
//oc_storestacknilar
  (ssa: storestacknilarssa; proc: @storestacknilarop; flags: []), 
//oc_storestackindinilar
  (ssa: storestackindinilarssa; proc: @storestackindinilarop; flags: []), 
//oc_storestackrefnilar
  (ssa: storestackrefnilarssa; proc: @storestackrefnilarop; flags: []), 
//oc_storetempvarnilar
  (ssa: storetempvarnilarssa; proc: @storetempvarnilarop; flags: []), 

//oc_storesegnildynar
  (ssa: storesegnildynarssa; proc: @storesegnildynarop; flags: [of_relocseg]), 
//oc_storelocnilar
  (ssa: storelocnildynarssa; proc: @storelocnildynarop; flags: []), 
//oc_storelocindinilar
  (ssa: storelocindinildynarssa; proc: @storelocindinildynarop; flags: []), 
//oc_storestacknilar
  (ssa: storestacknildynarssa; proc: @storestacknildynarop; flags: []), 
//oc_storestackindinilar
  (ssa: storestackindinildynarssa; proc: @storestackindinildynarop; flags: []), 
//oc_storestackrefnilar
  (ssa: storestackrefnildynarssa; proc: @storestackrefnildynarop; flags: []), 
//oc_storetempvarnilar
  (ssa: storetempvarnildynarssa; proc: @storetempvarnildynarop; flags: []), 


//oc_finirefsizeseg
  (ssa: finirefsizesegssa; proc: @finirefsizesegop; 
                                    flags: [of_bbinc1,of_relocseg]), 
//oc_finirefsizeloc
  (ssa: finirefsizelocssa; proc: @finirefsizelocop; flags: [of_bbinc1]), 
//oc_finirefsizelocindi
  (ssa: finirefsizelocindissa; proc: @finirefsizelocindiop; flags: [of_bbinc1]), 
//oc_finirefsizestack
  (ssa: finirefsizestackssa; proc: @finirefsizestackop; flags: [of_bbinc1]), 
//oc_finirefsizestackindi
  (ssa: finirefsizestackindissa; proc: @finirefsizestackindiop;
                                                        flags: [of_bbinc1]), 
//oc_finirefsizestackref
  (ssa: finirefsizestackrefssa; proc: @finirefsizestackrefop;
                                                        flags: [of_bbinc1]), 
//oc_finirefsizetempvar
  (ssa: finirefsizetempvarssa; proc: @finirefsizetempvarop;
                                                        flags: [of_bbinc1]), 

//oc_finirefsizesegar
  (ssa: finirefsizesegarssa; proc: @finirefsizesegarop;
                                              flags: [of_bbinc1,of_relocseg]), 
//oc_finirefsizelocar
  (ssa: finirefsizelocarssa; proc: @finirefsizelocarop; flags: [of_bbinc1]), 
//oc_finirefsizelocindiar
  (ssa: finirefsizelocindiarssa; proc: @finirefsizelocindiarop;
                                                        flags: [of_bbinc1]), 
//oc_finirefsizestackar
  (ssa: finirefsizestackarssa; proc: @finirefsizestackarop;
                                                        flags: [of_bbinc1]), 
//oc_finirefsizestackindiar
  (ssa: finirefsizestackindiarssa; proc: @finirefsizestackindiarop;
                                                        flags: [of_bbinc1]), 
//oc_finirefsizestackrefar
  (ssa: finirefsizestackrefarssa; proc: @finirefsizestackrefarop;
                                                        flags: [of_bbinc1]), 
//oc_finirefsizetempvarar
  (ssa: finirefsizetempvararssa; proc: @finirefsizetempvararop;
                                                        flags: [of_bbinc1]), 

//oc_finirefsizesegdynar
  (ssa: finirefsizesegdynarssa; proc: @finirefsizesegdynarop;
                                            flags: [of_bbinc1,of_relocseg]), 
//oc_finirefsizelocdynar
  (ssa: finirefsizelocdynarssa; proc: @finirefsizelocdynarop; 
                                                    flags: [of_bbinc1]), 
//oc_finirefsizelocindidynar
  (ssa: finirefsizelocindidynarssa; proc: @finirefsizelocindidynarop;
                                                    flags: [of_bbinc1]), 
//oc_finirefsizestackdynar
  (ssa: finirefsizestackdynarssa; proc: @finirefsizestackdynarop;
                                                    flags: [of_bbinc1]), 
//oc_finirefsizestackindidynar
  (ssa: finirefsizestackindidynarssa; proc: @finirefsizestackindidynarop;
                                                    flags: [of_bbinc1]), 
//oc_finirefsizestackrefdynar
  (ssa: finirefsizestackrefdynarssa; proc: @finirefsizestackrefdynarop;
                                                         flags: [of_bbinc1]), 
//oc_finirefsizetempvardynar
  (ssa: finirefsizetempvardynarssa; proc: @finirefsizetempvardynarop;
                                                         flags: [of_bbinc1]), 

//oc_increfsizeseg
  (ssa: increfsizesegssa; proc: @increfsizesegop; 
                                 flags: [of_bbinc1,of_relocseg]),
//oc_increfsizeloc
  (ssa: increfsizelocssa; proc: @increfsizelocop; flags: [of_bbinc1]), 
//oc_increfsizelocindi
  (ssa: increfsizelocindissa; proc: @increfsizelocindiop; flags: [of_bbinc1]), 
//oc_increfsizestack
  (ssa: increfsizestackssa; proc: @increfsizestackop; flags: [of_bbinc1]), 
//oc_increfsizestackindi
  (ssa: increfsizestackindissa; proc: @increfsizestackindiop;
                                                      flags: [of_bbinc1]), 
//oc_increfsizestackref
  (ssa: increfsizestackrefssa; proc: @increfsizestackrefop; flags: [of_bbinc1]), 
//oc_increfsizetempvar
  (ssa: increfsizetempvarssa; proc: @increfsizetempvarop; flags: [of_bbinc1]), 

//oc_increfsizesegar
  (ssa: increfsizesegarssa; proc: @increfsizesegarop; 
                                            flags: [of_bbinc1,of_relocseg]),
//oc_increfsizelocar
  (ssa: increfsizelocarssa; proc: @increfsizelocarop; flags: [of_bbinc1]), 
//oc_increfsizelocindiar
  (ssa: increfsizelocindiarssa; proc: @increfsizelocindiarop; 
                                                     flags: [of_bbinc1]), 
//oc_increfsizestackar
  (ssa: increfsizestackarssa; proc: @increfsizestackarop; flags: [of_bbinc1]), 
//oc_increfsizestackindiar
  (ssa: increfsizestackindiarssa; proc: @increfsizestackindiarop;
                                                          flags: [of_bbinc1]), 
//oc_increfsizestackrefar
  (ssa: increfsizestackrefarssa; proc: @increfsizestackrefarop;
                                                          flags: [of_bbinc1]), 
//oc_increfsizetemparar
  (ssa: increfsizetempvararssa; proc: @increfsizetempvararop;
                                                          flags: [of_bbinc1]), 

//oc_increfsizesegar
  (ssa: increfsizesegdynarssa; proc: @increfsizesegdynarop; 
                                               flags: [of_bbinc1,of_relocseg]),
//oc_increfsizelocar
  (ssa: increfsizelocdynarssa; proc: @increfsizelocdynarop; flags: [of_bbinc1]), 
//oc_increfsizelocindiar
  (ssa: increfsizelocindidynarssa; proc: @increfsizelocindidynarop;
                                                            flags: [of_bbinc1]), 
//oc_increfsizestackar
  (ssa: increfsizestackdynarssa; proc: @increfsizestackdynarop; 
                                                     flags: [of_bbinc1]), 
//oc_increfsizestackindiar
  (ssa: increfsizestackindidynarssa; proc: @increfsizestackindidynarop;
                                                        flags: [of_bbinc1]), 
//oc_increfsizestackrefar
  (ssa: increfsizestackrefdynarssa; proc: @increfsizestackrefdynarop;
                                                        flags: [of_bbinc1]), 
//oc_increfsizetempvardynar
  (ssa: increfsizetempvardynarssa; proc: @increfsizetempvardynarop;
                                                        flags: [of_bbinc1]), 

//oc_decrefsizeseg
  (ssa: decrefsizesegssa; proc: @decrefsizesegop; 
                                      flags: [of_bbinc1,of_relocseg]),
//oc_decrefsizeloc
  (ssa: decrefsizelocssa; proc: @decrefsizelocop; flags: [of_bbinc1]), 
//oc_decrefsizelocindi
  (ssa: decrefsizelocindissa; proc: @decrefsizelocindiop; flags: [of_bbinc1]), 
//oc_decrefsizestack
  (ssa: decrefsizestackssa; proc: @decrefsizestackop; flags: [of_bbinc1]), 
//oc_decrefsizestackindi
  (ssa: decrefsizestackindissa; proc: @decrefsizestackindiop;
                                                   flags: [of_bbinc1]), 
//oc_decrefsizestackref
  (ssa: decrefsizestackrefssa; proc: @decrefsizestackrefop; flags: [of_bbinc1]), 
//oc_decrefsizetempvar
  (ssa: decrefsizetempvarssa; proc: @decrefsizetempvarop; flags: [of_bbinc1]), 

//oc_decrefsizesegar
  (ssa: decrefsizesegarssa; proc: @decrefsizesegarop; 
                                       flags: [of_bbinc1,of_relocseg]),
//oc_decrefsizelocar
  (ssa: decrefsizelocarssa; proc: @decrefsizelocarop; flags: [of_bbinc1]), 
//oc_decrefsizelocindiar
  (ssa: decrefsizelocindiarssa; proc: @decrefsizelocindiarop;
                                                      flags: [of_bbinc1]), 
//oc_decrefsizestackar
  (ssa: decrefsizestackarssa; proc: @decrefsizestackarop; flags: [of_bbinc1]), 
//oc_decrefsizestackindiar
  (ssa: decrefsizestackindiarssa; proc: @decrefsizestackindiarop;
                                                          flags: [of_bbinc1]), 
//oc_decrefsizestackrefar
  (ssa: decrefsizestackrefarssa; proc: @decrefsizestackrefarop;
                                                          flags: [of_bbinc1]), 
//oc_decrefsizetempvarar
  (ssa: decrefsizetempvararssa; proc: @decrefsizetempvararop;
                                                          flags: [of_bbinc1]), 

//oc_decrefsizesegdynar
  (ssa: decrefsizesegdynarssa; proc: @decrefsizesegdynarop;
                                             flags: [of_bbinc1,of_relocseg]),
//oc_decrefsizelocdynar
  (ssa: decrefsizelocdynarssa; proc: @decrefsizelocdynarop; flags: [of_bbinc1]), 
//oc_decrefsizelocindidynar
  (ssa: decrefsizelocindidynarssa; proc: @decrefsizelocindidynarop;
                                                         flags: [of_bbinc1]), 
//oc_decrefsizestackdynar
  (ssa: decrefsizestackdynarssa; proc: @decrefsizestackdynarop;
                                                         flags: [of_bbinc1]), 
//oc_decrefsizestackindidynar
  (ssa: decrefsizestackindidynarssa; proc: @decrefsizestackindidynarop;
                                                         flags: [of_bbinc1]), 
//oc_decrefsizestackrefdynar
  (ssa: decrefsizestackrefdynarssa; proc: @decrefsizestackrefdynarop;
                                                         flags: [of_bbinc1]), 
//oc_decrefsizetempvardynar
  (ssa: decrefsizetempvardynarssa; proc: @decrefsizetempvardynarop;
                                                     flags: [of_bbinc1]), 

//oc_highstring,
  (ssa: highstringssa; proc: @highstringop; flags: [of_bbinc1]), 
//oc_highdynar,
  (ssa: highdynarssa; proc: @highdynarop; flags: [of_bbinc1]), 
//oc_highopenar,
  (ssa: highopenarssa; proc: @highopenarop; flags: [of_bbinc1]), 
//oc_lengthstring,
  (ssa: lengthstringssa; proc: @lengthstringop; flags: [of_bbinc1]), 
//oc_lengthdynar,
  (ssa: lengthdynarssa; proc: @lengthdynarop; flags: [of_bbinc1]), 
//oc_lengthopenar,
  (ssa: lengthopenarssa; proc: @lengthopenarop; flags: [of_bbinc1]), 

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
//oc_popsegbigint
  (ssa: popsegbigintssa; proc: @popsegbigintop; flags: [of_relocseg]), 
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
//oc_poplocbigint
  (ssa: poplocbigintssa; proc: @poplocbigintop; flags: []), 
//oc_poploc
  (ssa: poplocssa; proc: @poplocop; flags: []), 

//oc_storelocpo
  (ssa: storelocpossa; proc: @storelocpoop; flags: []), 

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
//oc_popparbigint
  (ssa: popparbigintssa; proc: @popparbigintop; flags: []), 
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
//oc_popparindibigint
  (ssa: popparindibigintssa; proc: @popparindibigintop; flags: []), 
//oc_popparindi
  (ssa: popparindissa; proc: @popparindiop; flags: []), 

//oc_pushnil
  (ssa: pushnilssa; proc: @pushnilop; flags: []), 
//oc_pushnilmethod
  (ssa: pushnilmethodssa; proc: @pushnilmethodop; flags: []), 

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
//oc_pushsegbigint
  (ssa: pushsegbigintssa; proc: @pushsegbigintop; flags: [of_relocseg]),
//oc_pushseg
  (ssa: pushsegssa; proc: @pushsegop; flags: [of_relocseg]),
{
//oc_pushsegopenar
  (ssa: pushsegopenarssa; proc: @pushsegopenarop; flags: [of_relocseg]),
}
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
//oc_pushlocbigint
  (ssa: pushlocbigintssa; proc: @pushlocbigintop; flags: []), 
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
//oc_pushlocindif32
  (ssa: pushlocindif32ssa; proc: @pushlocindif32op; flags: []), 
//oc_pushlocindif64
  (ssa: pushlocindif64ssa; proc: @pushlocindif64op; flags: []), 
//oc_pushlocindibigint
  (ssa: pushlocindibigintssa; proc: @pushlocindibigintop; flags: []), 
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
//oc_pushparbigint
  (ssa: pushparbigintssa; proc: @pushparbigintop; flags: []), 
//oc_pushpar
  (ssa: pushparssa; proc: @pushparop; flags: []), 

//oc_pushaddr
  (ssa: pushaddrssa; proc: @pushaddrop; flags: []), 
//oc_pushlocaddr
  (ssa: pushlocaddrssa; proc: @pushlocaddrop; flags: []), 
//oc_pushtempaddr
  (ssa: pushtempaddrssa; proc: @pushtempaddrop; flags: []), 
//oc_pushsegaddr
  (ssa: pushsegaddrssa; proc: @pushsegaddrop; flags: [of_relocseg]),
//oc_pushstackaddr
  (ssa: pushstackaddrssa; proc: @pushstackaddrop; flags: []), 
//oc_pushallocaddr
  (ssa: pushallocaddrssa; proc: @pushallocaddrop; flags: []), 
//oc_pushstack
  (ssa: pushstackssa; proc: @pushstackop; flags: []), 
//oc_pushclassdef
  (ssa: pushclassdefssa; proc: @pushclassdefop; flags: []), 
//oc_pushrtti
  (ssa: pushrttissa; proc: @pushrttiop; flags: []), 
//oc_pushallocsize
  (ssa: pushallocsizessa; proc: @pushallocsizeop; flags: [of_bbinc1]),

//oc_pushduppo
  (ssa: pushduppossa; proc: @pushduppoop; flags: []), 
//oc_storemanagedtemp
  (ssa: storemanagedtempssa; proc: @storemanagedtempop; flags: []), 
//oc_loadalloca
  (ssa: loadallocassa; proc: @loadallocaop; flags: []), 

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
//oc_tempalloc
  (ssa: tempallocssa; proc: @tempallocop; flags: []), 
//oc_pushtemp
  (ssa: pushtempssa; proc: @pushtempop; flags: []), 

//oc_subbegin
  (ssa: subbeginssa; proc: @subbeginop; flags: []), 
//oc_subend
  (ssa: subendssa; proc: @subendop; flags: []), 
//oc_externalsub
  (ssa: externalsubssa; proc: @externalsubop; flags: []), 

//oc_copystring
  (ssa: copystringssa; proc: @copystringop; flags: [of_bbinc1]),
//oc_copysdynar
  (ssa: copydynarssa; proc: @copydynarop; flags: [of_bbinc1]), 

//oc_setlengthstr8
  (ssa: setlengthstr8ssa; proc: @setlengthstr8op; flags: [of_bbinc1]), 
//oc_setlengthstr16
  (ssa: setlengthstr16ssa; proc: @setlengthstr16op; flags: [of_bbinc1]), 
//oc_setlengthstr32
  (ssa: setlengthstr32ssa; proc: @setlengthstr32op; flags: [of_bbinc1]), 
//oc_setlengthdynarray
  (ssa: setlengthdynarrayssa; proc: @setlengthdynarrayop; flags: [of_bbinc1]), 
//oc_setlengthincdecrefstring
  (ssa: setlengthincdecrefstringssa; proc: @setlengthincdecrefstringop;
                                                           flags: [of_bbinc1]), 
//oc_setlengthincdecrefdynarray
  (ssa: setlengthincdecrefdynarrayssa; proc: @setlengthincdecrefdynarrayop;
                                                           flags: [of_bbinc1]), 

//oc_uniquestr8
  (ssa: uniquestr8ssa; proc: @uniquestr8op; flags: [of_bbinc1]), 
//oc_uniquestr8a
  (ssa: uniquestr8assa; proc: @uniquestr8aop; flags: [of_bbinc1]), 
//oc_uniquestr16
  (ssa: uniquestr16ssa; proc: @uniquestr16op; flags: [of_bbinc1]), 
//oc_uniquestr16a
  (ssa: uniquestr16assa; proc: @uniquestr16aop; flags: [of_bbinc1]), 
//oc_uniquestr32
  (ssa: uniquestr32ssa; proc: @uniquestr32op; flags: [of_bbinc1]), 
//oc_uniquestr32a
  (ssa: uniquestr32assa; proc: @uniquestr32aop; flags: [of_bbinc1]), 
//oc_uniquedynarray
  (ssa: uniquedynarrayssa; proc: @uniquedynarrayop; flags: [of_bbinc1]), 
//oc_uniquedynarraya
  (ssa: uniquedynarrayassa; proc: @uniquedynarrayaop; flags: [of_bbinc1]), 

//oc_pushcpucontext
  (ssa: pushcpucontextssa; proc: @pushcpucontextop; flags: []), 
//oc_pushcpucontextdummy
  (ssa: pushcpucontextdummyssa; proc: @pushcpucontextdummyop; flags: []), 
//oc_popcpucontext
  (ssa: popcpucontextssa; proc: @popcpucontextop; flags: []), 
//oc_pushexception
  (ssa: pushexceptionssa; proc: @pushexceptionop; flags: []), 
//oc_iniexception
  (ssa: iniexceptionssa; proc: @iniexceptionop; flags: []), 
//oc_nilexception
  (ssa: nilexceptionssa; proc: @nilexceptionop; flags: []), 
//oc_getmem
  (ssa: getmemssa; proc: @getmemop; flags: [of_bbinc1]), 
//oc_getzeromem
  (ssa: getzeromemssa; proc: @getzeromemop; flags: [of_bbinc1]), 
//oc_freemem
  (ssa: freememssa; proc: @freememop; flags: [of_bbinc1]), 
//oc_reallocmem
  (ssa: reallocmemssa; proc: @reallocmemop; flags: [of_bbinc1]), 
//oc_setmem
  (ssa: setmemssa; proc: @setmemop; flags: [of_bbinc1]), 
//oc_memcpy
  (ssa: memcpyssa; proc: @memcpyop; flags: [{of_bbinc1}]), 
//oc_memmove
  (ssa: memmovessa; proc: @memmoveop; flags: [{of_bbinc1}]), 
  
//oc_ln64
  (ssa: ln64ssa; proc: @ln64op; flags: [{of_bbinc1}]), 
//oc_exp64
  (ssa: exp64ssa; proc: @exp64op; flags: [{of_bbinc1}]), 
//oc_sin64
  (ssa: sin64ssa; proc: @sin64op; flags: [{of_bbinc1}]), 
//oc_cos64
  (ssa: cos64ssa; proc: @cos64op; flags: [{of_bbinc1}]), 
//oc_sqrt64
  (ssa: sqrt64ssa; proc: @sqrt64op; flags: [{of_bbinc1}]), 
//oc_floor64
  (ssa: floor64ssa; proc: @floor64op; flags: [{of_bbinc1}]), 
//oc_frac64
  (ssa: frac64ssa; proc: @frac64op; flags: [of_bbinc1]), 
//oc_round64
  (ssa: round64ssa; proc: @round64op; flags: [{of_bbinc1}]), 
//oc_nearbyint64
  (ssa: nearbyint64ssa; proc: @nearbyint64op; flags: [{of_bbinc1}]), 
  
//oc_lineinfo
  (ssa: lineinfossa; proc: @lineinfoop; flags: []), 

//ssaonly
//oc_nestedvar
  (ssa: nestedvarssa; proc: nil; flags: []), 
//oc_nestedvarad
  (ssa: nestedvaradssa; proc: nil; flags: []), 
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
  (ssa: pushsegaddrclassdefssa; proc: nil; flags: []),
//ocssa_listtoopenaritem
  (ssa: listtoopenaritemssa; proc: nil; flags: []),
//ocssa_listtoarrayofconstitem
  (ssa: listtoarrayofconstitemssa; proc: nil; flags: []),
//ocssa_concattermsitem
  (ssa: concattermsitemssa; proc: nil; flags: []) 
 );
