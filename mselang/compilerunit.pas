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
 globtypes,parserglob,msetypes;
const
// systemunitname = '__mla__system';
// systemunitname = 'system';
 memhandlerunitname = '__mla__debugmemhandler';
 compilerunitname = '__mla__compilerunit';
 rtlunitnames: array[rtlunitty] of msestring = 
            ('system','rtl_base','rtl_fpccompatibility');
 
type
 compilersubty = (
  cs_none,
  cs_malloc,
  cs_calloc,
  cs_free,
  cs_zeropointerar,
  cs_increfsize,
  cs_increfsizeref,
  cs_decrefsize,
  cs_decrefsizeref,
  cs_finirefsize,
  cs_finirefsizear,
  cs_finirefsizedynar,
  cs_storenildynar,
  cs_setlengthdynarray,
  cs_setlengthstring8,
  cs_setlengthstring16,
  cs_setlengthstring32,
  cs_uniquedynarray,
  cs_uniquestring8,
  cs_uniquestring16,
  cs_uniquestring32,
  cs_string8to16,cs_string8to32,
  cs_string16to8,cs_string16to32,
  cs_string32to8,cs_string32to16,
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
  cs_getallocsize,
  cs_classis,
  cs_checkclasstype,
//  cs_initclass,
//  cs_finiclass,
  cs_raise,
  cs_personality,
  cs_finiexception,
  cs_writeenum
 );
const
 compilersubnames: array[compilersubty] of string = (
  '',
  '__mla__malloc',
  '__mla__calloc',
  '__mla__free',
  '__mla__zeropointerar',
  '__mla__increfsize',
  '__mla__increfsizeref',
  '__mla__decrefsize',
  '__mla__decrefsizeref',
  '__mla__finirefsize',
  '__mla__finirefsizear',
  '__mla__finirefsizedynar',
  '__mla__storenildynar',
  '__mla__setlengthdynarray',
  '__mla__setlengthstring8',
  '__mla__setlengthstring16',
  '__mla__setlengthstring32',
  '__mla__uniquedynarray',
  '__mla__uniquestring8',
  '__mla__uniquestring16',
  '__mla__uniquestring32',
  '__mla__string8to16','__mla__string8to32',
  '__mla__string16to8','__mla__string16to32',
  '__mla__string32to8','__mla__string32to16',
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
  '__mla__getallocsize',
  '__mla__classis',
  '__mla__checkclasstype',
//  '__mla__initclass',
//  '__mla__finiclass',
  '__mla__raise',
  '__mla__personality',
  '__mla__finiexception',
  '__mla__writeenum'
 );

type
 internaltypety = (it_rtti,it_enumitemrtti);
const
 internaltypenames : array[internaltypety] of string =  (
  'rttity','enumitemrttity'
 );
type
 compilerunitty = (cu_none,cu_memhandler,cu_compilerunit);
 compilerunitdefty = record
  name: filenamety;
  first,last: compilersubty;
 end;
 compilerunitinfoty = record
  unitpo: punitinfoty;
 end;
 
const
 compilerunitdefs: array[compilerunitty] of compilerunitdefty = (
  (name: ''; first: cs_none; last: cs_none),
  (name: memhandlerunitname; first: cs_malloc; last: cs_free),
  (name: compilerunitname; first: cs_zeropointerar; last: high(compilersubty))
 );
var
 compilerunits: array[compilerunitty] of compilerunitinfoty;
    
var
 compilersubs: array[compilersubty] of elementoffsetty;
 compilersubids: array[compilersubty] of int32;
 internaltypes: array[internaltypety] of elementoffsetty;
  
procedure initcompilersubs(const aunit: punitinfoty);

implementation
uses
 elements,errorhandler,handlerglob,identutils;
 
procedure initcompilersubs(const aunit: punitinfoty);
var
 s1,se: compilersubty;
 t1: internaltypety;
 cu1: compilerunitty; 
begin
 cu1:= cu_none;
 if aunit^.namestring = compilerunitname then begin
  cu1:= cu_compilerunit;
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
 end
 else begin
  if aunit^.namestring = memhandlerunitname then begin
   cu1:= cu_memhandler;
  end;
 end;
 if cu1 <> cu_none then begin
  with compilerunitdefs[cu1] do begin
   s1:= first;
   se:= last;
  end;
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

end.
