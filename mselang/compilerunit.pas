{ MSElang Copyright (c) 2014-2017 by Martin Schreiber
   
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
unit compilerunit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,parserglob,msetypes,opglob;

const
// systemunitname = '__mla__system';
// systemunitname = 'system';
 memhandlerunitname = '__mla__debugmemhandler';
 internaltypesunitname = '__mla__internaltypes';
 personalityunitname = '__mla__personality';
 compilerunitname = '__mla__compilerunit';
// sysintfunitname = '__mla__sysintf';
 rtlunitnames: array[rtlunitty] of string = 
            ('system','rtl_base','rtl_fpccompatibility');

type
 compilersubflagty = (csf_dummy);
 compilersubflagsty = set of compilersubflagty;
 compilersubinfoty = record
  name: string;
  flags: compilersubflagsty;
 end;
 
const
 compilersubnames: array[compilersubty] of compilersubinfoty = (
  (name: ''; flags: []),
  (name: '__mla__personality'; flags: []),
  (name: '__mla__malloc'; flags: []),
  (name: '__mla__calloc'; flags: []),
  (name: '__mla__realloc'; flags: []),
  (name: '__mla__free'; flags: []),
  (name: '__mla__zeropointerar'; flags: []),
  (name: '__mla__increfsize'; flags: []),
  (name: '__mla__increfsizeref'; flags: []),
  (name: '__mla__increfsizedynar'; flags: []),
  (name: '__mla__increfsizerefdynar'; flags: []),
  (name: '__mla__decrefsize'; flags: []),
  (name: '__mla__decrefsizeref'; flags: []),
  (name: '__mla__decrefsizedynar'; flags: []),
  (name: '__mla__finirefsize'; flags: []),
  (name: '__mla__finirefsizear'; flags: []),
  (name: '__mla__finirefsizedynar'; flags: []),
  (name: '__mla__storenildynar'; flags: []),
  (name: '__mla__setlengthdynarray'; flags: []),
  (name: '__mla__setlengthincdecrefdynarray'; flags: []),
  (name: '__mla__setlengthstring8'; flags: []),
  (name: '__mla__setlengthstring16'; flags: []),
  (name: '__mla__setlengthstring32'; flags: []),
  (name: '__mla__copystring'; flags: []),
  (name: '__mla__copydynarray'; flags: []),
  (name: '__mla__uniquedynarray'; flags: []),
  (name: '__mla__uniquestring8'; flags: []),
  (name: '__mla__uniquestring16'; flags: []),
  (name: '__mla__uniquestring32'; flags: []),
  (name: '__mla__string8to16'; flags: []),
  (name: '__mla__string8to32'; flags: []),
  (name: '__mla__string16to8'; flags: []),
  (name: '__mla__string16to32'; flags: []),
  (name: '__mla__string32to8'; flags: []),
  (name: '__mla__string32to16'; flags: []),
  (name: '__mla__bytestostring'; flags: []),
  (name: '__mla__stringtobytes'; flags: []),
  (name: '__mla__concatstring8'; flags: []),
  (name: '__mla__concatstring16'; flags: []),
  (name: '__mla__concatstring32'; flags: []),
  (name: '__mla__chartostring8'; flags: []),
  (name: '__mla__chartostring16'; flags: []),
  (name: '__mla__chartostring32'; flags: []),
  (name: '__mla__compstring8eq'; flags: []),
  (name: '__mla__compstring8ne'; flags: []),
  (name: '__mla__compstring8gt'; flags: []),
  (name: '__mla__compstring8lt'; flags: []),
  (name: '__mla__compstring8ge'; flags: []),
  (name: '__mla__compstring8le'; flags: []),
  (name: '__mla__compstring16eq'; flags: []),
  (name: '__mla__compstring16ne'; flags: []),
  (name: '__mla__compstring16gt'; flags: []),
  (name: '__mla__compstring16lt'; flags: []),
  (name: '__mla__compstring16ge'; flags: []),
  (name: '__mla__compstring16le'; flags: []),
  (name: '__mla__compstring32eq'; flags: []),
  (name: '__mla__compstring32ne'; flags: []),
  (name: '__mla__compstring32gt'; flags: []),
  (name: '__mla__compstring32lt'; flags: []),
  (name: '__mla__compstring32ge'; flags: []),
  (name: '__mla__compstring32le'; flags: []),
  (name: '__mla__arraytoopenar'; flags: []),
  (name: '__mla__dynarraytoopenar'; flags: []),
  (name: '__mla__lengthdynarray'; flags: []),
  (name: '__mla__lengthopenarray'; flags: []),
  (name: '__mla__lengthstring'; flags: []),
  (name: '__mla__highdynarray'; flags: []),
  (name: '__mla__highopenarray'; flags: []),
  (name: '__mla__highstring'; flags: []),
  (name: '__mla__initobject'; flags: []),
//  '__mla__calliniobject',
  (name: '__mla__getclassdef'; flags: []),
  (name: '__mla__getclassrtti'; flags: []),
  (name: '__mla__getallocsize'; flags: []),
  (name: '__mla__classis'; flags: []),
  (name: '__mla__checkclasstype'; flags: []),
  (name: '__mla__checkexceptclasstype'; flags: []),
//  '__mla__initclass',
//  '__mla__finiclass',

  (name: '__mla__int32tovarrecty'; flags: []),
  (name: '__mla__int64tovarrecty'; flags: []),
  (name: '__mla__card32tovarrecty'; flags: []),
  (name: '__mla__card64tovarrecty'; flags: []),
  (name: '__mla__pointertovarrecty'; flags: []),
  (name: '__mla__flo64tovarrecty'; flags: []),
  (name: '__mla__char32tovarrecty'; flags: []),
  (name: '__mla__string8tovarrecty'; flags: []),
  (name: '__mla__string16tovarrecty'; flags: []),
  (name: '__mla__string32tovarrecty'; flags: []),

//  (name: '__mla__setsetele'; flags: []),

  (name: '__mla__halt'; flags: []),
  
  (name: '__mla__raise'; flags: []),
  (name: '__mla__finiexception'; flags: []),
  (name: '__mla__unhandledexception'; flags: []),
  (name: '__mla__continueexception'; flags: []),
  (name: '__mla__writeenum'; flags: []),
  (name: '__mla__frac64'; flags: [])
 );

type
 internaltypety = (it_rtti,it_prtti,it_enumitemrtti,it_varrec,
                   it_pclassdefinfo);
const
 internaltypenames : array[internaltypety] of string =  (
  'rttity','prttity','enumitemrttity','varrecty','pclassdefty'
 );
type
 compilerunitty = (cu_none,cu_personality,cu_internaltypes,
                   cu_memhandler,cu_compilerunit{,cu_sysintf});
 compilerunitdefty = record
  name: string;
  firstsub,lastsub: compilersubty;
//  firsttype,lasttype: compilertypety;
 end;
 compilerunitinfoty = record
  unitpo: punitinfoty;
 end;
 
const
 compilerunitdefs: array[compilerunitty] of compilerunitdefty = (
  (name: ''; firstsub: cs_none; lastsub: cs_none),
  (name: personalityunitname; firstsub: cs_personality;
                                          lastsub: cs_personality),
  (name: internaltypesunitname; firstsub: cs_none;
                                          lastsub: cs_none),
  (name: memhandlerunitname; firstsub: cs_malloc; lastsub: cs_free),
  (name: compilerunitname; firstsub: cs_zeropointerar;
                                          lastsub: high(compilersubty))
//  (name: sysintfunitname; firstsub: cs_none; lastsub: cs_none) //no subs
 );
var
 compilerunits: array[compilerunitty] of compilerunitinfoty;
    
var
 compilersubs: array[compilersubty] of elementoffsetty;
 compilersubids: array[compilersubty] of int32;
 internaltypes: array[internaltypety] of elementoffsetty;
  
procedure initcompilersubs(const aunit: punitinfoty);
procedure reset();

implementation
uses
 elements,errorhandler,handlerglob,identutils;
var testvar,testvar1: psubdataty;
procedure initcompilersubs(const aunit: punitinfoty);
var
 s1,se: compilersubty;
 t1: internaltypety;
 cu1,cu2: compilerunitty;
begin
 cu1:= cu_none;
 for cu2:= succ(cu1) to high(cu2) do begin
  if aunit^.namestring = compilerunitdefs[cu2].name then begin
   cu1:= cu2;
   break;
  end;
 end;
 if cu1 = cu_internaltypes then begin
  ele.pushelementparent(aunit^.interfaceelement);
  for t1:= low(internaltypety) to high(internaltypety) do begin
   if not ele.findcurrent(getident(internaltypenames[t1]),[ek_type],
                                          allvisi,internaltypes[t1]) then begin
    internalerror1(ie_parser,'20171106B');
   end;
  end;
  ele.popelementparent();
 end;
(*
 if cu1 = cu_compilerunit then begin
 {$ifdef mse_checkinternalerror}
  if (high(aunit^.interfaceuses) <= 0) or 
     (aunit^.interfaceuses[1]^.namestring <> '__mla__internaltypes') then begin
   internalerror(ie_parser,'20171106A');
  end;
 {$endif}
  ele.pushelementparent(aunit^.interfaceuses[1]^.interfaceelement);
  for t1:= low(internaltypety) to high(internaltypety) do begin
   if not ele.findcurrent(getident(internaltypenames[t1]),[ek_type],
                                          allvisi,internaltypes[t1]) then begin
    internalerror(ie_parser,'20171106B');
   end;
  end;
  ele.popelementparent();
 end;
*)
 if cu1 <> cu_none then begin
  with compilerunitdefs[cu1] do begin
   s1:= firstsub;
   se:= lastsub;
  end;
  if s1 <> cs_none then begin
   ele.pushelementparent(aunit^.interfaceelement);
   for s1:= s1 to se do begin
    if not ele.findcurrent(getident(compilersubnames[s1].name),[ek_sub],allvisi,
                                                compilersubs[s1]) then begin
     internalerror1(ie_parser,'20141031A');
    end
    else begin
testvar:= ele.eledataabs(compilersubs[s1]);
testvar1:= ele.eledataabs(testvar^.impl);
     compilersubids[s1]:= psubdataty(ele.eledataabs(compilersubs[s1]))^.globid;
//     compilersubids[s1]:= psubdataty(ele.eledataabs(
//         psubdataty(ele.eledataabs(compilersubs[s1]))^.impl))^.globid;
    end;
   end;
   ele.popelementparent();
  end;
 end;
end;

procedure reset();
begin
 fillchar(compilersubs,sizeof(compilersubs),0);
 fillchar(compilersubids,sizeof(compilersubids),0);
 fillchar(internaltypes,sizeof(internaltypes),0);
end;

end.
