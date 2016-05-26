{ MSElang Copyright (c) 2014 by Martin Schreiber
   
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
 globtypes,parserglob;
 
type
 compilersubty = (
  cs_zeropointerar,
  cs_increfsize,
  cs_decrefsize,
  cs_finifrefsize,
  cs_finirefsizear,
  cs_setlengthdynarray,
  cs_setlengthstring8,
  cs_uniquedynarray,
  cs_uniquestring8,
  cs_chartostring8,
  cs_arraytoopenar,
  cs_lengthdynarray,
  cs_lengthstring,
  cs_highdynarray,
  cs_highstring,
  cs_initclass,
  cs_raise,
  cs_personality
 );
const
 compilersubnames: array[compilersubty] of string = (
  '__mla__zeropointerar',
  '__mla__increfsize',
  '__mla__decrefsize',
  '__mla__finirefsize',
  '__mla__finirefsizear',
  '__mla__setlengthdynarray',
  '__mla__setlengthstring8',
  '__mla__uniquedynarray',
  '__mla__uniquestring8',
  '__mla__chartostring8',
  '__mla__arraytopenar',
  '__mla__lengthdynarray',
  '__mla__lengthstring',
  '__mla__highdynarray',
  '__mla__highstring',
  '__mla__initclass',
  '__mla__raise',
  '__mla__personality'
 );
 
var
 compilersubs: array[compilersubty] of elementoffsetty;
 compilersubids: array[compilersubty] of int32;
 
procedure initcompilersubs(const aunit: punitinfoty);

implementation
uses
 elements,errorhandler,handlerglob,identutils;
 
procedure initcompilersubs(const aunit: punitinfoty);
var
 sub1: compilersubty;
begin
 ele.pushelementparent(aunit^.interfaceelement);
 for sub1:= low(compilersubty) to high(compilersubty) do begin
  if not ele.findcurrent(getident(compilersubnames[sub1]),[ek_sub],allvisi,
                                              compilersubs[sub1]) then begin
   internalerror1(ie_parser,'20141031A');
  end;
  compilersubids[sub1]:= psubdataty(ele.eledataabs(
       psubdataty(ele.eledataabs(compilersubs[sub1]))^.impl))^.globid;  
 end;
 ele.popelementparent();
end;

end.
