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
unit opglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,msestrings,__mla__internaltypes;
 
type
 compilersubty = (
  cs_none,
  cs_personality,
  cs_malloc,
  cs_calloc,
  cs_realloc,
  cs_free,
  cs_zeropointerar,
  cs_increfsize,
  cs_increfsizeref,
  cs_increfsizedynar,
  cs_increfsizerefdynar,
  cs_decrefsize,
  cs_decrefsizeref,
  cs_decrefsizedynar,
  cs_finirefsize,
  cs_finirefsizear,
  cs_finirefsizedynar,
  cs_storenildynar,
  cs_setlengthdynarray,
  cs_setlengthincdecrefdynarray,
  cs_setlengthstring8,
  cs_setlengthstring16,
  cs_setlengthstring32,
  cs_copystring,
  cs_copydynarray,
  cs_uniquedynarray,
  cs_uniquestring8,
  cs_uniquestring16,
  cs_uniquestring32,
  cs_string8to16,cs_string8to32,
  cs_string16to8,cs_string16to32,
  cs_string32to8,cs_string32to16,
  cs_bytestostring,cs_stringtobytes,
  cs_concatstring8,cs_concatstring16,cs_concatstring32,
  cs_chartostring8,
  cs_chartostring16,
  cs_chartostring32,
  cs_compstring8eq,
  cs_compstring8ne,
  cs_compstring8gt,
  cs_compstring8lt,
  cs_compstring8ge,
  cs_compstring8le,
  cs_compstring16eq,
  cs_compstring16ne,
  cs_compstring16gt,
  cs_compstring16lt,
  cs_compstring16ge,
  cs_compstring16le,
  cs_compstring32eq,
  cs_compstring32ne,
  cs_compstring32gt,
  cs_compstring32lt,
  cs_compstring32ge,
  cs_compstring32le,
  cs_arraytoopenar,
  cs_dynarraytoopenar,
  cs_lengthdynarray,
  cs_lengthopenarray,
  cs_lengthstring,
  cs_highdynarray,
  cs_highopenarray,
  cs_highstring,
  cs_initobject,
//  cs_calliniobject,
  cs_getclassdef,
  cs_getclassrtti,
  cs_getallocsize,
  cs_classis,
  cs_checkclasstype,
  cs_checkexceptclasstype,
//  cs_initclass,
//  cs_finiclass,

  cs_int32tovarrecty,
  cs_int64tovarrecty,
  cs_card32tovarrecty,
  cs_card64tovarrecty,
  cs_pointertovarrecty,
  cs_flo64tovarrecty,
  cs_char32tovarrecty,
  cs_string8tovarrecty,
  cs_string16tovarrecty,
  cs_string32tovarrecty,

//  cs_setsetele,
  
  cs_halt,
  
  cs_raise,
  cs_finiexception,
  cs_unhandledexception,
  cs_continueexception,
  cs_writeenum,
  
  cs_frac64
 );

 backendty = (bke_direct,bke_llvm);

 addressbasety = (ab_segment,ab_local{ab_frame},ab_localindi,
                  ab_stack,ab_stackindi,ab_stackref,ab_tempvar);
{
 addressrefty = record
  address: dataoffsty;
  flags: addressflagsty;
  offset: dataoffsty;
  indirectlevel: int32;
  case base: addressbasety of
   ab_segment: (segment: segmentty);
 end;
}
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
  debuginfo: metavaluety;
 end;
 plocallocinfoty = ^locallocinfoty;
{ 
 tempallocinfoty = record
  next: dataoffsty;
  typeid: int32; //llvm
 end;
 ptempallocinfoty = ^tempallocinfoty;
} 
 parallocinfoty = record
  ssaindex: integer;
  size: typeallocinfoty;
 end;
 pparallocinfoty = ^parallocinfoty;
{
 concatparallocinfoty = record
  ssaindex: integer;
//  size: typeallocinfoty;
 end;
 pconcatparallocinfoty = ^concatparallocinfoty;
}
 nestedaddressty = record
  arrayoffset: dataoffsty;
  origin: dataoffsty;
  datatype: typeallocinfoty;
  nested: boolean;     //ref to nested frame
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

  oc_label,          //controlops
  oc_if,
  oc_ifnot,
  oc_while,  //todo: unify with if
  oc_until,  //todo: unify with if
  oc_decloop32,
  oc_decloop64,

  oc_raise,         //callops
  oc_finiexception,
  oc_unhandledexception,
  oc_continueexception,

  oc_call,
  oc_callfunc,
  oc_callout,
  oc_callfuncout,
  oc_callvirt,
  oc_callvirtclass,
  oc_callvirtfunc,
  oc_callvirtclassfunc,
  oc_callintf,
  oc_callintffunc,
  oc_virttrampoline,

  oc_callindi,
  oc_callfuncindi,

  oc_return,
  oc_returnfunc,

  oc_zeromem,
  oc_zeromemindi,
  oc_getobjectmem,
  oc_getobjectzeromem,
  oc_iniobject,       //classdef directly from typedataty.classinfo
//  oc_iniobject1,      //classdef from ssas2
  oc_callclassdefproc,
  oc_callclassdefproc2,
  oc_destroyclass,
  oc_getclassdef, //from instance
  oc_getclassrtti,//from classdef
  oc_classis,
  oc_checkclasstype,
  oc_checkexceptclasstype,
  oc_cmpstring,

  oc_beginparse,
  oc_endparse,
  oc_beginunitcode,
  oc_endunit,
  oc_main,
  oc_progend,
  oc_progend1,
  oc_halt,
  oc_halt1,
  
  oc_movesegreg0,
  oc_moveframereg0,
  oc_popreg0,
  oc_increg0,

  oc_phi,
  
  oc_goto,
  oc_gotofalse,
  oc_gotofalseoffs,
  oc_gototrue,
  oc_gotonil, //pops address if goto taken
  oc_gotonilindirect, //pops address if goto taken
  oc_cmpjmpneimm,
  oc_cmpjmpeqimm,
  oc_cmpjmploimm,
  oc_cmpjmpgtimm,
  oc_cmpjmploeqimm,

  
  oc_writeln,
  oc_writeboolean,
  oc_writecardinal8,
  oc_writecardinal16,
  oc_writecardinal32,
  oc_writecardinal64,
  oc_writeinteger8,
  oc_writeinteger16,
  oc_writeinteger32,
  oc_writeinteger64,
  oc_writefloat32,
  oc_writefloat64,
  oc_writechar8,
  oc_writechar16,
  oc_writechar32,
  oc_writestring8,
  oc_writestring16,
  oc_writestring32,
  oc_writepointer,
  oc_writeclass,
  oc_writeenum,

  oc_nop,
  oc_nopssa,
  oc_push,
  oc_pop,
  oc_swapstack,
  oc_movestack,

  oc_pushimm1,
  oc_pushimm8,
  oc_pushimm16,
  oc_pushimm32,
  oc_pushimm64,
  oc_pushimmf32,
  oc_pushimmf64,
  oc_pushimmbigint,
  oc_pushimmdatakind,
  
  oc_card8toflo32,
  oc_card16toflo32,
  oc_card32toflo32,
  oc_card64toflo32,

  oc_int8toflo32,
  oc_int16toflo32,
  oc_int32toflo32,
  oc_int64toflo32,

  oc_card8toflo64,
  oc_card16toflo64,
  oc_card32toflo64,
  oc_card64toflo64,

  oc_int8toflo64,
  oc_int16toflo64,
  oc_int32toflo64,
  oc_int64toflo64,

  oc_potoint8,
  oc_potoint16,
  oc_potoint32,
  oc_potoint64,
  oc_inttopo,
  oc_potopo, //llvm typed->untyped pointer

  oc_and1,
  oc_and,
  oc_or1,
  oc_or,
  oc_xor1,
  oc_xor,
  
  oc_shl,
  oc_shr,
  //oc_shrint
    
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
  
  oc_flo32toflo64,oc_flo64toflo32,
  oc_truncint32flo64,oc_truncint32flo32,
  oc_truncint64flo64,
  oc_trunccard32flo64,oc_trunccard32flo32,
  oc_trunccard64flo64,

  oc_card1toint32,
  
  oc_string8to16,oc_string8to32,
  oc_string16to8,oc_string16to32,
  oc_string32to8,oc_string32to16,
  oc_bytestostring,oc_stringtobytes,
  
  oc_concatstring8,oc_concatstring16,oc_concatstring32,

  oc_chartostring8,
  oc_arraytoopenar,
  oc_arraytoopenarad,
  oc_dynarraytoopenar,
  oc_dynarraytoopenarad,
  oc_listtoopenar,
  oc_listtoopenarad,
  oc_listtoarrayofconst,
  oc_listtoarrayofconstad,
  
  oc_combinemethod,  //instance,subaddress -> methodty
  oc_getmethodcode,
  oc_getmethoddata,
  oc_getvirtsubad,   //read from vitualtable
  oc_getintfmethod,
  
  oc_not1,
  oc_not,
  
  oc_negcard,
  oc_negint,
  oc_negflo,

  oc_absint,
  oc_absflo,
  
  oc_mulcard,
  oc_mulint,
  oc_divcard,
  oc_divint,
  oc_modcard,
  oc_modint,
  oc_mulflo,
  oc_divflo,
  oc_addint,
  oc_subint,
  oc_addpoint,
  oc_subpoint,
  oc_subpo,
  oc_addflo,
  oc_subflo,
  oc_diffset,
  oc_xorset,

  oc_setbit,
  
  oc_addimmint,
  oc_mulimmint,
  oc_offsetpoimm,

  oc_incdecsegimmint,
  oc_incdecsegimmpo,

  oc_incdeclocimmint,
  oc_incdeclocimmpo,

  oc_incdecparimmint,
  oc_incdecparimmpo,

  oc_incdecparindiimmint,
  oc_incdecparindiimmpo,

  oc_incdecindiimmint,
  oc_incdecindiimmpo,

  oc_incsegint,
  oc_incsegpo,

  oc_inclocint,
  oc_inclocpo,

  oc_incparint,
  oc_incparpo,

  oc_incparindiint,
  oc_incparindipo,

  oc_incindiint,
  oc_incindipo,

  oc_decsegint,
  oc_decsegpo,

  oc_declocint,
  oc_declocpo,

  oc_decparint,
  oc_decparpo,

  oc_decparindiint,
  oc_decparindipo,

  oc_decindiint,
  oc_decindipo,

  oc_cmppo,
  oc_cmpbool,
  oc_cmpcard,
  oc_cmpint,
  oc_cmpflo,
{
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
}
  oc_setcontains,
  oc_setin,
  oc_setsetele,
  oc_setexpand,
  oc_include,
  oc_exclude,
  
  oc_storesegnil,
  oc_storelocnil,
  oc_storelocindinil,
  oc_storestacknil,
  oc_storestackindinil,
  oc_storestackindipopnil,
  oc_storestackrefnil,
  oc_storetempvarnil,

  oc_storesegnilar,
  oc_storelocnilar,
  oc_storelocindinilar,
  oc_storestacknilar,
  oc_storestackindinilar,
  oc_storestackrefnilar,
  oc_storetempvarnilar,

  oc_storesegnildynar,
  oc_storelocnildynar,
  oc_storelocindinildynar,
  oc_storestacknildynar,
  oc_storestackindinildynar,
  oc_storestackrefnildynar,
  oc_storetempvarnildynar,

  oc_finirefsizeseg,
  oc_finirefsizeloc,
  oc_finirefsizelocindi,
  oc_finirefsizestack,
  oc_finirefsizestackindi,
  oc_finirefsizestackref,
  oc_finirefsizetempvar,

  oc_finirefsizesegar,
  oc_finirefsizelocar,
  oc_finirefsizelocindiar,
  oc_finirefsizestackar,
  oc_finirefsizestackindiar,
  oc_finirefsizestackrefar,
  oc_finirefsizetempvarar,

  oc_finirefsizesegdynar,
  oc_finirefsizelocdynar,
  oc_finirefsizelocindidynar,
  oc_finirefsizestackdynar,
  oc_finirefsizestackindidynar,
  oc_finirefsizestackrefdynar,
  oc_finirefsizetempvardynar,

  oc_increfsizeseg,
  oc_increfsizeloc,
  oc_increfsizelocindi,
  oc_increfsizestack,
  oc_increfsizestackindi,
  oc_increfsizestackref,
  oc_increfsizetempvar,

  oc_increfsizesegar,
  oc_increfsizelocar,
  oc_increfsizelocindiar,
  oc_increfsizestackar,
  oc_increfsizestackindiar,
  oc_increfsizestackrefar,
  oc_increfsizetempvarar,

  oc_increfsizesegdynar,
  oc_increfsizelocdynar,
  oc_increfsizelocindidynar,
  oc_increfsizestackdynar,
  oc_increfsizestackindidynar,
  oc_increfsizestackrefdynar,
  oc_increfsizetempvardynar,

  oc_decrefsizeseg,
  oc_decrefsizeloc,
  oc_decrefsizelocindi,
  oc_decrefsizestack,
  oc_decrefsizestackindi,
  oc_decrefsizestackref,
  oc_decrefsizetempvar,

  oc_decrefsizesegar,
  oc_decrefsizelocar,
  oc_decrefsizelocindiar,
  oc_decrefsizestackar,
  oc_decrefsizestackindiar,
  oc_decrefsizestackrefar,
  oc_decrefsizetempvarar,

  oc_decrefsizesegdynar,
  oc_decrefsizelocdynar,
  oc_decrefsizelocindidynar,
  oc_decrefsizestackdynar,
  oc_decrefsizestackindidynar,
  oc_decrefsizestackrefdynar,
  oc_decrefsizetempvardynar,

  oc_highstring,
  oc_highdynar,
  oc_highopenar,
  oc_lengthstring,
  oc_lengthdynar,
  oc_lengthopenar,
  
  oc_popseg8,
  oc_popseg16,
  oc_popseg32,
  oc_popseg64,
  oc_popsegpo,
  oc_popsegf16,
  oc_popsegf32,
  oc_popsegf64,
  oc_popsegbigint,
  oc_popseg,

  oc_poploc8,
  oc_poploc16,
  oc_poploc32,
  oc_poploc64,
  oc_poplocpo,
  oc_poplocf16,
  oc_poplocf32,
  oc_poplocf64,
  oc_poplocbigint,
  oc_poploc,
  
  oc_storelocpo,

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
  oc_popparbigint,
  oc_poppar,

  oc_popparindi8,
  oc_popparindi16,
  oc_popparindi32,
  oc_popparindi64,
  oc_popparindipo,
  oc_popparindif16,
  oc_popparindif32,
  oc_popparindif64,
  oc_popparindibigint,
  oc_popparindi,

  oc_pushnil,
  oc_pushnilmethod,
//  oc_pushsegaddress,
{
  oc_pushstack8,
  oc_pushstack16,
  oc_pushstack32,
  oc_pushstack64,
  oc_pushstackpo,
  oc_pushstackindi8,
  oc_pushstackindi16,
  oc_pushstackindi32,
  oc_pushstackindi64,
  oc_pushstackindipo,
}
  oc_pushseg8,
  oc_pushseg16,
  oc_pushseg32,
  oc_pushseg64,
  oc_pushsegpo,
  oc_pushsegf16,
  oc_pushsegf32,
  oc_pushsegf64,
  oc_pushsegbigint,
  oc_pushseg,
//  oc_pushsegopenar,
  
  oc_pushloc8,
  oc_pushloc16,
  oc_pushloc32,
  oc_pushloc64,
  oc_pushlocpo,
  oc_pushlocf16,
  oc_pushlocf32,
  oc_pushlocf64,
  oc_pushlocbigint,
  oc_pushloc,

  oc_pushlocindi8,
  oc_pushlocindi16,
  oc_pushlocindi32,
  oc_pushlocindi64,
  oc_pushlocindipo,
  oc_pushlocindif16,
  oc_pushlocindif32,
  oc_pushlocindif64,
  oc_pushlocindibigint,
  oc_pushlocindi,

  oc_pushpar8,
  oc_pushpar16,
  oc_pushpar32,
  oc_pushpar64,
  oc_pushparpo,
  oc_pushparf16,
  oc_pushparf32,
  oc_pushparf64,
  oc_pushparbigint,
  oc_pushpar,

  oc_pushaddr,
  oc_pushlocaddr,
//  oc_pushlocaddrindi,
  oc_pushtempaddr,
  oc_pushsegaddr,
//  oc_pushsegaddrindi,
  oc_pushstackaddr,
  oc_pushallocaddr,
//  oc_pushstackaddrindi,
  oc_pushstack,
  oc_pushclassdef,
  oc_pushrtti,
  oc_pushallocsize,

  oc_pushduppo,
  oc_storemanagedtemp,
  oc_loadalloca,
  
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
  oc_tempalloc,  //alloca for llvm
  oc_pushtemp,   //for llvm

  oc_subbegin,
  oc_subend,
  oc_externalsub,

  oc_copystring,
  oc_copydynar,
  
  oc_setlengthstr8,
  oc_setlengthstr16,
  oc_setlengthstr32,
  oc_setlengthdynarray,
  oc_setlengthincdecrefstring,
  oc_setlengthincdecrefdynarray,

  oc_uniquestr8,
  oc_uniquestr8a,
  oc_uniquestr16,
  oc_uniquestr16a,
  oc_uniquestr32,
  oc_uniquestr32a,
  oc_uniquedynarray,
  oc_uniquedynarraya,

  oc_pushcpucontext,
  oc_pushcpucontextdummy,
  oc_popcpucontext,
  oc_pushexception,
  oc_iniexception,
  oc_nilexception,
  
  oc_getmem,
  oc_getzeromem,
  oc_freemem,
  oc_reallocmem,
  oc_setmem,
  oc_memcpy,
  oc_memmove,
  
  oc_ln64,
  oc_exp64,
  oc_sin64,
  oc_cos64,
  oc_sqrt64,
  oc_floor64,
  oc_frac64,
  oc_round64,
  oc_nearbyint64,

  oc_lineinfo,
    
//ssaonly
  ocssa_nestedvar,
  ocssa_nestedvarad,
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
  ocssa_pushsegaddrclassdef,
  ocssa_listtoopenaritem, //per item
  ocssa_listtoarrayofconstitem, //per item
  ocssa_concattermsitem  //per item
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
 vpoty = array[0..sizeof(pointer)-1] of byte;
 pvpoty = ^vpoty;

   //todo: simplify nested procedure link handling

 virtcallinfoty = record
  selfinstance: dataoffsty; //stackoffset
  virttaboffset: dataoffsty;//offset in instance
  virtoffset: dataoffsty;   //offset in classdefinfoty
  typeid: int32; //for llvm
 end;
 
 indicallinfoty = record
  calladdr: dataoffsty; //stackoffset
  typeid: int32; //for llvm
 end;

 calladdressty = record
  ad: opaddressty;    //first!
  globid: int32;      //for llvm
 end;
 pcalladdressty = ^calladdressty;
 callinfoty = record
  ad: calladdressty;    //first!
//  globid: int32;      //for llvm
  flags: subflagsty;
  linkcount: integer; //used in "for downto 0"
  params: dataoffsty;
  paramcount: integer;
  case opcodety of
   oc_callvirt,oc_callvirtclass,oc_callvirtfunc,oc_callvirtclassfunc,
   oc_callintf,oc_callintffunc:(
    virt: virtcallinfoty;
   );
   oc_callindi,oc_callfuncindi:(
    indi: indicallinfoty;
   );
 end; 
 
 classdefcallty = record
  procoffset: int32;
  case opcodety of
   oc_callclassdefproc:(
    virttaboffset: int32;
   );
 end;
 
 intfcallinfoty = record
  selfinstance: dataoffsty; 
    //stackoffset, points to interface item in obj instance.
  subindex: integer;   //sub item in interface list
 end;
  
 initclassinfoty = record
  classdef: dataoffsty;
 {
  case boolean of
   false:(           //stackops
    classdefstackops: dataoffsty;
   );
   true:(            //llvm
    classdefid: int32;
   );
  }
 end;

 destroyclassflagty = (dcf_nofreemem); //for object destroy
 destroyclassflagsty = set of destroyclassflagty;
 
 destroyclassinfoty = record
  selfinstance: dataoffsty; //stackoffset
  flags: destroyclassflagsty;
 end;

 getvirtsubadinfoty = record
  virtoffset: dataoffsty;
 end;
 
 segdataaddressty = record
  a: segaddressty;
  offset: dataoffsty;
 {
  case opcodety of
   oc_pushsegopenar:(
    openarhigh: int32;
   );
 }
//  datasize: integer;         //>0 = bits, 0 = pointer, <0 = bytes
 end;
   
 locdataaddressty = record
  a: locaddressty;
  offset: dataoffsty;
 end;

 tempdataaddressty = record
  a: tempaddressty;
  offset: dataoffsty;
 end;
{
 openarvaluety = record
  high: int32;
  case opcodety of
   oc_pushsegopenar:(
    segdataaddress: segdataaddressty;
   );
 end;
}
 immty = record
  datasize: databitsizety;
  case integer of               //todo: use target size
   0: (llvm: llvmvaluety);
   1: (vboolean: boolean);
   2: (vcard8: card8);
   3: (vcard16: card16);
   4: (vcard32: card32);
   5: (vcard64: card64);
   6: (vint8: int8);
   7: (vint16: int16);
   8: (vint32: int32);
   9: (vint64: int64);
  10: (vflo32: flo32);
  11: (vflo64: flo64);
  12: (vsize: datasizety);
  13: (vpointer: dataaddressty);
  14: (voffset: dataoffsty);
  15: (vdatakind: datakindty);
 end;
 
 swapstackty = record
  offset,size: int32;
 end;
{
 ordimmty = record
  case integer of
   0: (llvm: llvmvaluety);
   1: (vboolean: boolean);
   2: (vcard32: card32);
   3: (vint32: int32);
 end;
}
 labty = record
  opaddress: opaddressty; //first! dummy for oc_label 
  case integer of
   0: (bbindex: int32);         //llvm basic block for label
   1: (blockid: int32);         //origin block id for goto statement
 end;
 
 phity = record
  t: typeallocinfoty;
  philist: dataoffsty; //in seg_localloc
 end;
 
 cmpjmpimmty = record
  destad: labty; //first!
  imm: immty;
//  destad: opaddressty
 end;
{
 stackaddressty = record
  address: dataoffsty;
 end;
} 
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
//  exitcodeaddress: segaddressty;
  mainad: opaddressty;
  finisub: opaddressty; //0 -> none
 end;  

 beginunitcodeinfoty = record
 end;
 
 progendty = record
  exitcodeaddress: segaddressty;
 end;
 progend1ty = record
  submeta: metavaluety;
 end;
 compopkindty = (cok_eq,cok_ne,cok_gt,cok_lt,cok_ge,cok_le);

 opsetflagty = (osf_extend,osf_trunc);
 opsetflagsty = set of opsetflagty;
 setopinfoty = record
  flags: opsetflagsty;
  listindex: int32; //llvm type index for set int bits
 end;
 
 stackopty = record
  t: typeallocinfoty;
  case opcodety of
   oc_cmppo,oc_cmpbool,oc_cmpcard,oc_cmpint,oc_cmpflo,oc_cmpstring:(
    compkind: compopkindty;
   );
   oc_include,oc_exclude,oc_setbit:(
    setinfo: setopinfoty;
   );
 end;
 {
 concatopty = record
  count: int32; 
  countid: int32;//llvm const id
  allocs: dataoffsty;
  arraytype: int32; //llvm type id
 end;
 }
{
 stackimmopty = record
  t: typeallocinfoty;
  case opcodety of
   oc_incdecindimmint32,oc_incdecindimmpo32:(
    vint32: int32;
   );
 end;
}
 podataaddressty = record
  address: dataoffsty;
  offset: dataoffsty;
 end;
 
 memopty = record
  t: typeallocinfoty;
  operanddatasize: databitsizety;
//  ssaindex: integer;
  case opcodety of
   oc_poploc8,oc_poploc16,oc_poploc32,oc_poploc,
   oc_poppar8,oc_poppar16,oc_poppar32,oc_poppar,
   oc_poplocindi8,oc_poplocindi16,oc_poplocindi32,oc_poplocindi,
   oc_pushloc8,oc_pushloc16,oc_pushloc32,oc_pushlocpo,oc_pushloc,
   oc_pushlocaddr,oc_pushstackaddr,
   oc_pushlocindi8,oc_pushlocindi16,oc_pushlocindi32,oc_pushlocindi,
   oc_incdeclocimmint,oc_incdeclocimmpo,
   oc_storelocnilar,oc_storelocnildynar,oc_storelocpo,
   oc_finirefsizelocar,oc_increfsizelocar,oc_decrefsizelocar:(
    case integer of
     0:(locdataaddress: locdataaddressty;);
     1:(tempdataaddress: tempdataaddressty);
   );
   oc_storesegnil,oc_storesegnilar,oc_storesegnildynar,
   oc_popseg8,oc_popseg16,oc_popseg32,oc_popseg,
   oc_pushseg8,oc_pushseg16,oc_pushseg32,oc_pushseg,
   oc_pushsegaddr,{oc_pushsegaddrindi,}
   oc_finirefsizeseg,oc_increfsizeseg,oc_decrefsizeseg,
   oc_finirefsizesegdynar,oc_increfsizesegar,oc_increfsizesegdynar,
   oc_decrefsizesegar,oc_decrefsizesegdynar,
   oc_incdecsegimmint,oc_incdecsegimmpo:(
    segdataaddress: segdataaddressty;
   );
{   
   oc_pushstack8,oc_pushstack16,oc_pushstack32,oc_pushstack64,oc_pushstackpo:(
    stackaddress: stackaddressty;
   );
}
   {oc_storelocnilar,}oc_storelocindinilar,oc_storestacknilar,
   oc_storestackrefnilar,{oc_finirefsizelocar,}oc_finirefsizelocindiar,
   oc_finirefsizestackar,oc_finirefsizestackrefar,{oc_increfsizelocar,}
   oc_increfsizelocindiar,oc_increfsizestackar,oc_increfsizestackrefar,
   {oc_decrefsizelocar,}oc_decrefsizelocindiar,oc_decrefsizestackar,
   oc_decrefsizestackrefar:(
    podataaddress: podataaddressty;
   );
 end;

 memimmopty = record
  mem: memopty;
  case opcodety of
   oc_none:(
    llvm: llvmvaluety;
   );
   oc_incdecsegimmint,oc_incdecsegimmpo,
   oc_incdeclocimmint,oc_incdeclocimmpo,
   oc_incdecparimmint,oc_incdecparimmpo,
   oc_incdecparindiimmint,oc_incdecparindiimmpo,
   oc_incdecindiimmint,oc_incdecindiimmpo{,
   oc_pushsegopenar}:(
    vint32: int32;
   );
 end;
 
 managedtempopty = record
 end;

 tempaddrty = record
  a: tempaddressty;
  case opcodety of
   oc_pushtemp: ( //also for array of managed ops
    bytesize: int32;
   );
 end;

 landingpadty = record
  tempval: int32; //tempval ssa
 end;
  
 popcpucontextty = record
  landingpad: landingpadty;
 end;

 setlengthty = record
  itemsize: int32;
 end;

 copyty = record
  itemsize: int32;
 end;
 
 suballocllvmty = record
  tempcount: int32;
  tempvars: dataoffsty; //in seg_localloc
  managedtemptypeid: int32;
  managedtempcount: int32; //constid
  blockcount: int32;
 end;
 suballocstackopty = record
  varsize: int32; //includes managed temp and temp
  tempsize: int32;
  managedtempsize: int32;
 end;
 
 tempallocty = record
  typid: int32;
 end;
 
 suballocinfoty = record
  allocs: dataoffsty;
  alloccount: int32;
  paramcount: int32;
  nestedallocs: dataoffsty;
  nestedalloccount: int32;
  nestedallocstypeindex: int32;
  case integer of
   0: (
    stackop:suballocstackopty;
   );
   1: ( //llvm
    llvm: suballocllvmty;
   );
   3: (
    dummy: record
    end;
   );
 end;

 listitemallocinfoty = record
  ssaoffs: int32;
 end;
 plistitemallocinfoty = ^listitemallocinfoty;
 
 listinfoty = record
  alloccount: int32;
  itemsize: int32; //in byte, constid for llvm
  case backendty of
   bke_llvm: (
    allocs: dataoffsty;
   );
   bke_direct: (
    tempad: tempaddressty; //frame relative
   );
 end;
 listtoopenarty = record
  arraytype: int32; //llvm type id
  itemtype: typeallocinfoty;
  allochigh: int32; //llvm constid
 end;
 arrayofconstitemallocinfoty = record
  ssaoffs: int32;
  typid: int32;
  valuefunc: compilersubty;
 end;
 parrayofconstitemallocinfoty = ^arrayofconstitemallocinfoty;
 listtoarrayofconstty = record
  arraytype: int32; //llvm type id
//  itemtype: typeallocinfoty;
  allochigh: int32; //llvm constid
 end;

 concatstringty = record
  arraytype: int32; //llvm type id
  alloccount: int32; //llvm constid
 end;
 
const
 nullallocs: suballocinfoty = (
  allocs: 0;
  alloccount: 0;
  paramcount: 0;
  nestedallocs: 0;
  nestedalloccount: 0;
  nestedallocstypeindex: -1;
  dummy: ();
 );
 param1poallocs: suballocinfoty = (
  allocs: -1;       //must be set individually
  alloccount: 1;
  paramcount: 1;
  nestedallocs: 0;
  nestedalloccount: 0;
  nestedallocstypeindex: -1;
  dummy: ();
 );
 par0name: lstringty = (
  po: '.par0';
  len: 5;
 );
  
type
 virttrampolineinfoty = record
  selfinstance: dataoffsty;  //frameoffset
  virttaboffset: dataoffsty; //from instance start
  virtoffset: dataoffsty;    //offset in classdefinfoty
//  typeid: int32;
 end;

 subbegininfoty = record
  flags: subflagsty;
  allocs: suballocinfoty;
 {
  case integer of
   0: (
    stackop:subbeginstackopty;
   );
   1: ( //llvm
    llvm: subbeginllvmty;
   );
 }
 end;

 subbeginty = record
  subname: opaddressty;
  globid: int32;
  typeid: int32;
  case integer of
   0: (sub: subbegininfoty);
   1: (trampoline: virttrampolineinfoty);
 end;

 subendty = record
  flags: subflagsty;
  submeta: metavaluety;
  allocs: suballocinfoty;
 end;
{
 returnfuncinfoty = record
  flags: subflagsty;
  allocs: suballocinfoty;
 end;
}
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

 mainllvmty = record
 {
  tempcount: int32;
  firsttemp: dataoffsty;
  managedtemptypeid: int32;
  managedtempcount: int32; //constid
  blockcount: int32;
 }
  allocs: suballocllvmty;
 end;
 mainstackopty = record
  managedtempsize: int32;
  tempsize: int32;
 end;
 mainty = record
  exitcodeaddress: segaddressty;
  case integer of
   0: (
    stackop: mainstackopty;
   );
   1: (
    llvm: mainllvmty;
   );
 end;

(*
const
 controlops = [
  oc_label,
  oc_return,
  oc_returnfunc,
  oc_progend,
  oc_goto,
  oc_gotofalse,
  oc_gotofalseoffs,
  oc_gototrue,
  oc_gotonil,
  oc_gotonilindirect,
  oc_cmpjmpneimm,
  oc_cmpjmpeqimm,
  oc_cmpjmploimm,
  oc_cmpjmpgtimm,
  oc_cmpjmploeqimm,
  oc_if,
  oc_ifnot,
  oc_while,
  oc_until,
  oc_decloop32,
  oc_decloop64];

 subops = [oc_call,
           oc_callfunc,
           oc_callout,
           oc_callfuncout,
           oc_callvirt,
           oc_callvirtclass,
           oc_callvirtfunc,
           oc_callvirtclassfunc,
           oc_callintf,
           oc_callindi,
           oc_callfuncindi];
                                    //have subinfo record
 callops = subops + [      //ops with call, increment bbindex
  oc_halt1,
  oc_raise,
  oc_finiexception,
  oc_unhandledexception,
  oc_continueexception,
  
  oc_writeln,
  oc_writeboolean,
  oc_writecardinal8,
  oc_writecardinal16,
  oc_writecardinal32,
  oc_writecardinal64,
  oc_writeinteger8,
  oc_writeinteger16,
  oc_writeinteger32,
  oc_writeinteger64,
  oc_writefloat32,
  oc_writefloat64,
  oc_writestring8,
  oc_writestring16,
  oc_writestring32,
  oc_writechar8,
  oc_writepointer,
  oc_writeclass,
  oc_writeenum,

  oc_string8to16,
  oc_string8to32,
  oc_string16to8,
  oc_string16to32,
  oc_string32to8,
  oc_string32to16,
  oc_bytestostring,
  oc_stringtobytes,
  
  oc_concatstring8,
  oc_concatstring16,
  oc_concatstring32,
  
  oc_cmpstring,
  oc_virttrampoline,
{
  oc_getmem,
  oc_getzeromem,
  oc_freemem,
  oc_reallocmem,
  oc_setmem,
  oc_memcpy,
  oc_memmove,
  oc_getobjectmem,
  oc_getobjectzeromem,
  oc_zeromem,
}
  oc_iniobject,
//  oc_iniobject1,
  oc_callclassdefproc,
  oc_callclassdefproc2,
  oc_destroyclass,
  oc_getclassdef,
  oc_getclassrtti,
  oc_classis,
  oc_checkclasstype,
  oc_checkexceptclasstype
 ];
 call2ops = [oc_writeln]; //ops with 2 calls, increment bbindex twice
 
 listops = [oc_listtoopenar,
            oc_listtoarrayofconst,
            oc_concatstring8,
            oc_concatstring16,
            oc_concatstring32];  
                    //have listinfo record
*)
 
type
     //todo: unify, variable size, maybe use objects instead of records
 opparamty = record
  ssad: int32; //updated by op insertions
  ssas1: int32;//updated by op insertions
  ssas2: int32;//updated by op insertions
  ssas3: int32;//updated by op insertions
  case opcodety of 
   oc_label,oc_goto,oc_gotofalse,oc_gotofalseoffs,oc_gototrue,
   oc_gotonilindirect,
   oc_if,oc_ifnot,oc_while,oc_until,
   oc_decloop32,oc_decloop64, //controlops
   oc_pushcpucontext,oc_popcpucontext: (
    opaddress: labty; //first!
    case opcodety of
     oc_popcpucontext: (
      popcpucontext: popcpucontextty;
     );
     oc_gotofalseoffs: (
      gotostackoffs: int32;
     )
   );
   oc_phi: (
    phi: phity;
   );
{
   oc_setmem,oc_memcpy: (
    ssas3: int32;
   );
}
   oc_beginparse: (
    beginparse: beginparseinfoty;
   );
   oc_beginunitcode: (
    beginunitcode: beginunitcodeinfoty;
   );
   oc_none,oc_nop: (
    dummy: record
    end;
   );
   oc_nopssa: (
    ssacount: int32;
   );
   oc_progend,oc_halt: (
    progend: progendty;
   );
   oc_progend1: (
    progend1: progend1ty;
   );
   oc_swapstack,oc_movestack: (
    swapstack: swapstackty;
   );
   oc_push,
   oc_pushimm1,oc_pushimm8,oc_pushimm16,oc_pushimm32,oc_pushimm64,
   oc_pushimmdatakind,
   oc_pushaddr,
   oc_increg0,oc_mulimmint,oc_addimmint,oc_offsetpoimm,
   oc_pop,
   oc_arraytoopenar,
   oc_getobjectmem,oc_getobjectzeromem,
   oc_zeromem,oc_getclassdef: (
    imm: immty;
   );
   oc_pushtempaddr,oc_pushtemp:(
    tempaddr: tempaddrty;
   );
   oc_incdecsegimmint,oc_incdecsegimmpo,
   oc_incdeclocimmint,oc_incdeclocimmpo,
   oc_incdecparimmint,oc_incdecparimmpo,
   oc_incdecparindiimmint,oc_incdecparindiimmpo,
   oc_incdecindiimmint,oc_incdecindiimmpo{,
   oc_pushsegopenar}:(
    memimm: memimmopty;
   );
  
   oc_cmpjmpneimm,oc_cmpjmpeqimm,oc_cmpjmploimm,oc_cmpjmploeqimm,
   oc_cmpjmpgtimm: (
    cmpjmpimm: cmpjmpimmty;
   );
   oc_movesegreg0: (
    vsegment: segmentty;
   );
   oc_storelocnil,oc_storelocindinil,oc_storestacknil,oc_storestackrefnil,
   oc_finirefsizeloc,oc_finirefsizelocindi,oc_finirefsizestack,
   oc_finirefsizestackref,oc_increfsizeloc,oc_increfsizelocindi,
   oc_increfsizestack,oc_increfsizestackref,oc_decrefsizeloc,
   oc_decrefsizelocindi,oc_decrefsizestack,oc_decrefsizestackref,
   {:(
    vaddress: dataaddressty;
   );}
   oc_increg0,oc_writeboolean,oc_writeinteger8,oc_writeinteger16,
   oc_writeinteger32,oc_writeinteger64,oc_writefloat32,oc_writefloat64,
   oc_writechar8,oc_writestring8,oc_writestring16,oc_writestring32,
   oc_writepointer,oc_writeclass,oc_writeenum,
   {oc_pushstackaddrindi,}oc_pushduppo,oc_storemanagedtemp,
   oc_indirectpooffs,oc_indirectoffspo: (
    voffset: dataoffsty;
    case opcodety of
     oc_writeenum{,oc_pushstackaddrindi}: (
      voffsaddress: dataaddressty;
     );
     oc_storemanagedtemp: (
      managedtemparrayid: int32;
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

   oc_flo32toflo64,oc_flo64toflo32,
   oc_truncint32flo64,oc_truncint64flo64,
   
   oc_card1toint32,
   
   oc_string8to16,oc_string8to32,
   oc_string16to8,oc_string16to32,
   oc_string32to8,oc_string32to16,
   oc_bytestostring,oc_stringtobytes,
   
   oc_chartostring8,
   
   oc_negcard,oc_negint,oc_negflo,
   oc_absint,oc_absflo,
   oc_mulcard,oc_mulint,oc_mulflo,
   oc_divcard,oc_divint,oc_divflo,
   oc_addint,oc_addflo,
   oc_subint,oc_subflo,oc_diffset,oc_xorset,
   oc_addpoint,oc_subpoint,
   oc_cmppo,oc_cmpbool,oc_cmpcard,oc_cmpint,oc_cmpflo,oc_cmpstring,
   {
   oc_cmpeqbool,oc_cmpeqint32,oc_cmpeqflo64,
   oc_cmpnebool,oc_cmpneint32,oc_cmpneflo64,
   oc_cmpgtbool,oc_cmpgtint32,oc_cmpgtflo64,
   oc_cmpltbool,oc_cmpltint32,oc_cmpltflo64,
   oc_cmpgebool,oc_cmpgeint32,oc_cmpgeflo64,
   oc_cmplebool,oc_cmpleint32,oc_cmpleflo64,
   }
   oc_setcontains,oc_setin,oc_include,oc_exclude,
   oc_setsetele,oc_setexpand,oc_setbit: (
    stackop: stackopty;
   );
{
    oc_concatstring8,oc_concatstring16,oc_concatstring32: (
     concatop: concatopty;
    );
}
   {oc_pushstack8,oc_pushstack16,oc_pushstack32,oc_pushstack64,oc_pushstackpo,}
   oc_pushsegaddr,{oc_pushsegaddrindi,}
   oc_storesegnil,oc_finirefsizeseg,oc_increfsizeseg,oc_decrefsizeseg,
   oc_pushlocaddr,{oc_pushlocaddrindi,}
   oc_storesegnilar,oc_storelocnilar,oc_storelocindinilar,oc_storestacknilar,
   oc_storestackrefnilar,
   oc_storesegnildynar,oc_storelocnildynar,oc_storelocindinildynar,
   oc_storestacknildynar,oc_storestackrefnildynar,
   oc_popseg,oc_pushseg,
   oc_poploc8,oc_poploc16,oc_poploc32,oc_poploc,
   oc_poppar8,oc_poppar16,oc_poppar32,oc_poppar,
   oc_poplocindi8,oc_poplocindi16,oc_poplocindi32,oc_poplocindi,
   oc_pushpar8,oc_pushpar16,oc_pushpar32,oc_pushpar,
   oc_pushloc,oc_pushlocindi,
   oc_indirect,oc_popindirect8,oc_popindirect16,oc_popindirect32,oc_popindirect,
   oc_finirefsizesegar,oc_finirefsizelocar,oc_finirefsizelocindiar,
   oc_finirefsizestackar,oc_finirefsizestackrefar,
   oc_finirefsizesegdynar,oc_finirefsizelocdynar,oc_finirefsizelocindiar,
   oc_finirefsizestackdynar,oc_finirefsizestackrefdynar,
   oc_increfsizesegar,oc_increfsizelocar,oc_increfsizelocindiar,
   oc_increfsizestackar,oc_increfsizestackrefar,
   oc_increfsizesegdynar,oc_increfsizelocdynar,oc_increfsizelocindidynar,
   {oc_increfsizestackdynar,}oc_increfsizestackrefdynar,
   oc_decrefsizesegar,oc_decrefsizelocar,
   oc_decrefsizelocindiar,oc_decrefsizestackar,oc_decrefsizestackrefar,
   oc_decrefsizesegdynar,oc_decrefsizelocdynar,
   oc_decrefsizelocindidynar,oc_decrefsizestackdynar,oc_decrefsizestackrefdynar,
   oc_getmem,oc_getzeromem, //ssas1 = dest, ssas2 = size
   oc_memcpy,
   oc_incsegint,oc_incsegpo,
   oc_inclocint,oc_inclocpo,
   oc_incparint,oc_incparpo,
   oc_incparindiint,oc_incparindipo,
   oc_incindiint,oc_incindipo,
   oc_decsegint,oc_decsegpo,
   oc_declocint,oc_declocpo, 
   oc_decparint,oc_decparpo,
   oc_decparindiint,oc_decparindipo,
   oc_decindiint,oc_decindipo:(
    memop: memopty;
   );
   oc_setlengthstr8,oc_setlengthdynarray:(
    setlength: setlengthty;
   );
   oc_copystring,oc_copydynar:(
    copy: copyty;
   );
   oc_main: (
    main: mainty;
   );
   oc_subbegin,oc_virttrampoline,oc_externalsub:(
    subbegin: subbeginty;
   );
   oc_subend:(
    subend: subendty;
   );
   oc_call,oc_callfunc,oc_callout,oc_callvirt,oc_callintf,
   oc_callindi,oc_callfuncindi:(                               //subops
    callinfo: callinfoty;
   );
   oc_callclassdefproc,    //ssas1 instance, classdef from instance
    oc_callclassdefproc2:( //ssas1 instance, ssas2 classdef
    classdefcall: classdefcallty;
   );
   oc_locvarpush,oc_locvarpop,oc_return,oc_returnfunc:(
    stacksize: datasizety;
//    case opcodety of
//     oc_returnfunc:(
//      returnfuncinfo: returnfuncinfoty;
//     );
   );
   oc_tempalloc:(
    tempalloc: tempallocty;
   );
   oc_listtoopenar,oc_listtoarrayofconst,
   oc_concatstring8,oc_concatstring16,oc_concatstring32:(                                           //listops
    listinfo: listinfoty;
    case opcodety of
     oc_listtoopenar:(
      listtoopenar: listtoopenarty;
     );
     oc_listtoarrayofconst:(
      listtoarrayofconst: listtoarrayofconstty;
     );
     oc_concatstring8,oc_concatstring16,oc_concatstring32:(
      concatstring: concatstringty;
     );
   );
   oc_pushclassdef:(
    case boolean of
     false:(
      classdefstackops: dataoffsty; //stackops
     );
     true:(              //llvm
      classdefid: int32;
     );
   );
   oc_pushrtti:(
    case boolean of
     false:(
      rttistackops: dataoffsty //stackops
     );
     true:(
      rttiid: int32; //llvm
     );
    );
   {oc_initclass,}oc_iniobject:(
    initclass: initclassinfoty;
   );
   oc_destroyclass:(
    destroyclass: destroyclassinfoty;
   );
   oc_finiexception,oc_unhandledexception,oc_pushexception,
   oc_iniexception,oc_nilexception,oc_continueexception,
                                                oc_checkexceptclasstype:(
    landingpad: landingpadty;
   );
   oc_getvirtsubad,oc_getintfmethod:(
    getvirtsubad: getvirtsubadinfoty;
   );
   oc_lineinfo:(
    lineinfo: lineinfoty;
   );
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

// optablety = array[opcodety] of opprocty;
// poptablety = ^optablety;
// ssatablety = array[opcodety] of integer;
// pssatablety = ^ssatablety;

 opflagty = (of_relocseg,of_bbinc1,of_bbinc2,of_bbinc3,
             of_sub,of_control,of_list);
 opflagsty = set of opflagty;

 opdefty = record
  ssa: int32;
  proc: opprocty;
  flags: opflagsty;
 end;
 optablety = array[opcodety] of opdefty;
 poptablety = ^optablety;
 
const
// startupoffset = (sizeof(startupdataty)+sizeof(opinfoty)-1) div 
//                                                         sizeof(opinfoty);
 startupoffsetnum = 
     ((sizeof(startupdataty)+sizeof(opinfoty)-1) div sizeof(opinfoty));
                            //round up
 startupoffset = startupoffsetnum * sizeof(opinfoty);

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
