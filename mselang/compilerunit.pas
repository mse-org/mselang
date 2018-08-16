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
 
 compilersubnames: array[compilersubty] of string = (
  '',
  '__mla__personality',
  '__mla__malloc',
  '__mla__calloc',
  '__mla__free',
  '__mla__zeropointerar',
  '__mla__increfsize',
  '__mla__increfsizeref',
  '__mla__increfsizedynar',
  '__mla__increfsizerefdynar',
  '__mla__decrefsize',
  '__mla__decrefsizeref',
  '__mla__decrefsizedynar',
  '__mla__finirefsize',
  '__mla__finirefsizear',
  '__mla__finirefsizedynar',
  '__mla__storenildynar',
  '__mla__setlengthdynarray',
  '__mla__setlengthincdecrefdynarray',
  '__mla__setlengthstring8',
  '__mla__setlengthstring16',
  '__mla__setlengthstring32',
  '__mla__copystring',
  '__mla__copydynarray',
  '__mla__uniquedynarray',
  '__mla__uniquestring8',
  '__mla__uniquestring16',
  '__mla__uniquestring32',
  '__mla__string8to16','__mla__string8to32',
  '__mla__string16to8','__mla__string16to32',
  '__mla__string32to8','__mla__string32to16',
  '__mla__bytestostring','__mla__stringtobytes',
  '__mla__concatstring8','__mla__concatstring16','__mla__concatstring32',
  '__mla__chartostring8',
  '__mla__chartostring16',
  '__mla__chartostring32',
  '__mla__compstring8eq',
  '__mla__compstring8ne',
  '__mla__compstring8gt',
  '__mla__compstring8lt',
  '__mla__compstring8ge',
  '__mla__compstring8le',
  '__mla__compstring16eq',
  '__mla__compstring16ne',
  '__mla__compstring16gt',
  '__mla__compstring16lt',
  '__mla__compstring16ge',
  '__mla__compstring16le',
  '__mla__compstring32eq',
  '__mla__compstring32ne',
  '__mla__compstring32gt',
  '__mla__compstring32lt',
  '__mla__compstring32ge',
  '__mla__compstring32le',
  '__mla__arraytoopenar',
  '__mla__dynarraytoopenar',
  '__mla__lengthdynarray',
  '__mla__lengthopenarray',
  '__mla__lengthstring',
  '__mla__highdynarray',
  '__mla__highopenarray',
  '__mla__highstring',
  '__mla__initobject',
//  '__mla__calliniobject',
  '__mla__getclassdef',
  '__mla__getclassrtti',
  '__mla__getallocsize',
  '__mla__classis',
  '__mla__checkclasstype',
  '__mla__checkexceptclasstype',
//  '__mla__initclass',
//  '__mla__finiclass',

  '__mla__int32tovarrecty',
  '__mla__int64tovarrecty',
  '__mla__card32tovarrecty',
  '__mla__card64tovarrecty',
  '__mla__pointertovarrecty',
  '__mla__flo64tovarrecty',
  '__mla__char32tovarrecty',
  '__mla__string8tovarrecty',
 '__mla__string16tovarrecty',
 '__mla__string32tovarrecty',

  '__mla__halt',
  
  '__mla__raise',
  '__mla__finiexception',
  '__mla__continueexception',
  '__mla__writeenum',
  '__mla__frac64'
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
    if not ele.findcurrent(getident(compilersubnames[s1]),[ek_sub],allvisi,
                                                compilersubs[s1]) then begin
     internalerror1(ie_parser,'20141031A');
    end
    else begin
     compilersubids[s1]:= psubdataty(ele.eledataabs(
         psubdataty(ele.eledataabs(compilersubs[s1]))^.impl))^.globid;
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
