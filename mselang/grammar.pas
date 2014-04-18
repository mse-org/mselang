{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
unit grammar;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob,elements;
 
function startcontext: pcontextty;

const
 tks_none = 0;
 tks_classes = $2468ACF1;
 tks_private = $48D159E3;
 tks_protected = $91A2B3C6;
 tks_public = $2345678C;
 tks_published = $468ACF19;
 tks_classimp = $8D159E33;
 tks_self = $1A2B3C66;
 tk_unit = $345678CD;
 tk_uses = $68ACF19B;
 tk_implementation = $D159E337;
 tk_const = $A2B3C66E;
 tk_var = $45678CDD;
 tk_type = $8ACF19BB;
 tk_procedure = $159E3376;
 tk_function = $2B3C66ED;
 tk_begin = $5678CDDB;
 tk_dumpelements = $ACF19BB7;
 tk_abort = $59E3376E;
 tk_include = $B3C66EDD;
 tk_out = $678CDDBA;
 tk_end = $CF19BB75;
 tk_with = $9E3376EB;
 tk_if = $3C66EDD6;
 tk_do = $78CDDBAD;
 tk_then = $F19BB75B;
 tk_else = $E3376EB7;
 tk_of = $C66EDD6E;
 tk_record = $8CDDBADC;
 tk_array = $19BB75B9;
 tk_class = $3376EB73;
 tk_private = $66EDD6E7;
 tk_protected = $CDDBADCE;
 tk_public = $9BB75B9C;
 tk_published = $376EB739;

 tokens: array[0..34] of string = ('',
  '.classes','.private','.protected','.public','.published','.classimp','.self',
  'unit','uses','implementation','const','var','type','procedure','function',
  'begin','dumpelements','abort','include','out','end','with','if','do','then',
  'else','of','record','array','class','private','protected','public',
  'published');

 tokenids: array[0..34] of identty = (
  $00000000,$2468ACF1,$48D159E3,$91A2B3C6,$2345678C,$468ACF19,$8D159E33,
  $1A2B3C66,$345678CD,$68ACF19B,$D159E337,$A2B3C66E,$45678CDD,$8ACF19BB,
  $159E3376,$2B3C66ED,$5678CDDB,$ACF19BB7,$59E3376E,$B3C66EDD,$678CDDBA,
  $CF19BB75,$9E3376EB,$3C66EDD6,$78CDDBAD,$F19BB75B,$E3376EB7,$C66EDD6E,
  $8CDDBADC,$19BB75B9,$3376EB73,$66EDD6E7,$CDDBADCE,$9BB75B9C,$376EB739);

var
 startco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'start');
 nounitco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'nounit');
 unit0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'unit0');
 nounitnameco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'nounitname');
 unit1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'unit1');
 unit2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'unit2');
 checksemicolonco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checksemicolon');
 checksemicolon1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checksemicolon1');
 checksemicolon2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checksemicolon2');
 semicolonexpectedco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'semicolonexpected');
 identexpectedco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identexpected');
 start1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'start1');
 uses0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'uses0');
 uses1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'uses1');
 useserrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'useserror');
 usesokco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'usesok');
 start2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'start2');
 commaidentsco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commaidents');
 commaidents1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commaidents1');
 commaidents2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commaidents2');
 commaidentsnoidenterrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commaidentsnoidenterror');
 noimplementationco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'noimplementation');
 implementationco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'implementation');
 implementationstartco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'implementationstart');
 mainco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'main');
 main1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'main1');
 comment0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'comment0');
 directiveco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'directive');
 directive1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'directive1');
 includeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'include');
 include1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'include1');
 dumpelementsco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'dumpelements');
 abortco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'abort');
 directiveendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'directiveend');
 linecomment0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'linecomment0');
 linecomment1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'linecomment1');
 progbeginco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'progbegin');
 progblockco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'progblock');
 paramsdef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramsdef0');
 paramsdef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramsdef1');
 paramsdef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramsdef2');
 paramsdef3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramsdef3');
 paramdef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef0');
 paramdef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef1');
 paramdef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef2');
 subfunctionheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subfunctionheader');
 subprocedureheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subprocedureheader');
 methfunctionheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'methfunctionheader');
 methprocedureheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'methprocedureheader');
 createsubheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'createsubheader');
 procfuncheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procfuncheader');
 functionco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'function');
 procedureco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure');
 procfuncco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procfunc');
 procedureaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedurea');
 procedure0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure0');
 procedure1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure1');
 procedure2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure2');
 functiontypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'functiontype');
 resultidentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'resultident');
 functiontypeaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'functiontypea');
 procedure4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure4');
 procedure5aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure5a');
 procedure5co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure5');
 procedure6co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'procedure6');
 checkterminatorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkterminator');
 terminatorokco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'terminatorok');
 checkterminatorpopco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkterminatorpop');
 terminatorokpopco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'terminatorokpop');
 statementstackco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementstack');
 statementco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statement');
 withco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with');
 with1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with1');
 with2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with2');
 with3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with3');
 endcontextco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'endcontext');
 blockendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'blockend');
 simplestatementco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'simplestatement');
 statementblockco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementblock');
 statementblock1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementblock1');
 statement0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statement0');
 statement1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statement1');
 assignmentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'assignment');
 if0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'if0');
 ifco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'if');
 thenco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then');
 then0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then0');
 then1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then1');
 then2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then2');
 else0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'else0');
 elseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'else');
 constco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'const');
 const0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'const0');
 const1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'const1');
 const2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'const2');
 const3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'const3');
 simpletypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: true; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'simpletype');
 typeidentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typeident');
 checktypeidentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checktypeident');
 rangetypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'rangetype');
 recorddefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recorddef');
 recorddef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recorddef0');
 recorddeferrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recorddeferror');
 recordfieldco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordfield');
 recorddefreturnco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'recorddefreturn');
 arraydefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arraydef');
 arraydef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arraydef1');
 arraydef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arraydef2');
 arrayindexco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arrayindex');
 arrayindex1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arrayindex1');
 arrayindex2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arrayindex2');
 getfieldtypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getfieldtype');
 gettypetypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'gettypetype');
 gettypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'gettype');
 varco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'var');
 var0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'var0');
 var1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'var1');
 var2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'var2');
 var3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'var3');
 vardefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'vardef');
 vardef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'vardef0');
 vardef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'vardef1');
 typeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'type');
 type0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'type0');
 type1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'type1');
 type2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'type2');
 type3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'type3');
 getrangeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getrange');
 getrange1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getrange1');
 getrange3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getrange3');
 classdefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdef');
 classdef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdef0');
 classdeferrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdeferror');
 classdefreturnco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'classdefreturn');
 classdefparamco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefparam');
 classdefparam1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefparam1');
 classdefparam2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefparam2');
 classdefparam2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefparam2a');
 classdefparam3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefparam3');
 classdefparam3aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefparam3a');
 classfieldco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classfield');
 statementendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: true; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementend');
 expco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'exp');
 exp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'exp1');
 equsimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'equsimpexp');
 simpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'simpexp1');
 simpexp1aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'simpexp1a');
 addtermco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'addterm');
 factco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fact');
 fact1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fact1');
 fact2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fact2');
 negfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'negfact');
 valueidentifierco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valueidentifier');
 valueidentifierwhiteco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valueidentifierwhite');
 checkvalueparamsco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkvalueparams');
 checkparamsco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkparams');
 params0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'params0');
 params1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'params1');
 params2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'params2');
 paramsendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramsend');
 getindexco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getindex');
 getindex1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getindex1');
 getindex2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getindex2');
 termco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'term');
 term1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'term1');
 illegalexpressionco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'illegalexpression');
 mulfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'mulfact');
 numco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'num');
 fracexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fracexp');
 checkfracco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: true; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkfrac');
 fracco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'frac');
 exponentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'exponent');
 numberco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'number');
 decnumco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'decnum');
 binnumco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'binnum');
 octnumco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'octnum');
 hexnumco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'hexnum');
 ordnumco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ordnum');
 stringco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'string');
 string1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'string1');
 apostropheco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'apostrophe');
 tokenco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'token');
 charco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'char');
 char1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'char1');
 char2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'char2');
 identco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ident');
 identpathcontinueco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identpathcontinue');
 identpathco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identpath');
 identpath1aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identpath1a');
 identpath1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identpath1');
 identpath2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identpath2a');
 identpath2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'identpath2');
 bracketstartco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'bracketend');
 numberexpectedco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'numberexpected');

implementation

uses
 handler,unithandler,classhandler,typehandler;
 
const
 bstart: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @unit0co); stack: nil; 
     keyword: $345678CD{'unit'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bunit0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: @unit1co; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bunit2: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @start1co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @semicolonexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @semicolonexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @semicolonexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstart1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @uses0co); stack: @start2co; 
     keyword: $68ACF19B{'uses'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 buses0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 buses1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @usesokco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstart2: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationco); stack: nil; 
     keyword: $D159E337{'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @constco); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @varco); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @typeco); stack: nil; 
     keyword: $8ACF19BB{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @subprocedureheaderco); stack: nil; 
     keyword: $159E3376{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @subfunctionheaderco); stack: nil; 
     keyword: $2B3C66ED{'function'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommaidents: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @commaidents1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommaidents1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommaidents2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmain: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @uses0co); stack: nil; 
     keyword: $68ACF19B{'uses'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmain1: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @procedureco); stack: nil; 
     keyword: $159E3376{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @functionco); stack: nil; 
     keyword: $2B3C66ED{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @progbeginco); stack: nil; 
     keyword: $5678CDDB{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @constco); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @varco); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcomment0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdirective: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @dumpelementsco); stack: nil; 
     keyword: $ACF19BB7{'dumpelements'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @abortco); stack: nil; 
     keyword: $59E3376E{'abort'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @includeco); stack: nil; 
     keyword: $B3C66EDD{'include'}),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdirective1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binclude: array[0..3] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @stringco); stack: nil; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @tokenco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binclude1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdirectiveend: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blinecomment0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @linecomment1co); stack: nil; keys: (
    (kind: bkk_char; chars: [#10]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprogblock: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamsdef0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramsdef1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamsdef1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @paramdef0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamsdef2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramsdef1co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramsdef3co); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef0: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setconstparam); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setvarparam); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setoutparam); stack: nil; 
     keyword: $678CDDBA{'out'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramdef2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocfuncheader: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @procedure0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocfunc: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @procedure0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocedurea: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @procedure4co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocedure0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocedure1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @paramsdef0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocedure2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @functiontypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat,bf_push];
     dest: (handler: @handleprocedure3); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @semicolonexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfunctiontype: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @resultidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bresultident: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfunctiontypea: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocedure4: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @procedure5aco); stack: nil; 
     keyword: $5678CDDB{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @constco); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @varco); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @procedureco); stack: nil; 
     keyword: $159E3376{'procedure'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprocedure5: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckterminator: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @terminatorokco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckterminatorpop: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @terminatorokpopco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatementstack: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatement: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; 
     keyword: $5678CDDB{'begin'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @endcontextco); stack: nil; 
     keyword: $CF19BB75{'end'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @withco); stack: nil; 
     keyword: $9E3376EB{'with'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @if0co); stack: nil; 
     keyword: $3C66EDD6{'if'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @endcontextco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @simplestatementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwith1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwith2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @with3co); stack: nil; 
     keyword: $78CDDBAD{'do'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @with1co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwith3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsimplestatement: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statement0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatementblock: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatementblock1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @blockendco); stack: nil; 
     keyword: $CF19BB75{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatement0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatement1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @assignmentco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: [':']),
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bassignment: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bif0: array[0..4] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bif: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @then0co); stack: nil; 
     keyword: $F19BB75B{'then'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementstackco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen2: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @else0co); stack: nil; 
     keyword: $E3376EB7{'else'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 belse: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementstackco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D159E337{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $8ACF19BB{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $5678CDDB{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @const0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @const2co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @checksemicolon1co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsimpletype: array[0..1] of branchty = (
   (flags: [bf_nt,bf_push];
     dest: (context: @typeidentco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypeident: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brangetype: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getrangeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecorddef0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @recorddefreturnco); stack: nil; 
     keyword: $CF19BB75{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @recordfieldco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordfield: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @vardefco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barraydef: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @arrayindexco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barraydef1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @arraydef2co); stack: nil; 
     keyword: $C66EDD6E{'of'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barraydef2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barrayindex: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @arrayindex1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barrayindex1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barrayindex2: array[0..3] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_push];
     dest: (handler: @handlearrayindexerror2); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgettype: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @recorddefco); stack: nil; 
     keyword: $8CDDBADC{'record'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @arraydefco); stack: nil; 
     keyword: $19BB75B9{'array'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @classdefco); stack: nil; 
     keyword: $3376EB73{'class'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat];
     dest: (handler: @handlepointertype); stack: nil; keys: (
    (kind: bkk_char; chars: ['^']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @simpletypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D159E337{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $8ACF19BB{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $5678CDDB{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush];
     dest: (context: @var0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @var2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvardef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvardef0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @vardef1co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvardef1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D159E337{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $45678CDD{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $8ACF19BB{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $A2B3C66E{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $5678CDDB{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush];
     dest: (context: @type0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @type2co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @gettypetypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype3: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @semicolonexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetrange: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetrange1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @getrange3co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['.']),
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetrange3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdef: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @classdefparamco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdef0: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclassprivate); stack: nil; 
     keyword: $66EDD6E7{'private'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclassprotected); stack: nil; 
     keyword: $CDDBADCE{'protected'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclasspublic); stack: nil; 
     keyword: $9BB75B9C{'public'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclasspublished); stack: nil; 
     keyword: $376EB739{'published'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methprocedureheaderco); stack: nil; 
     keyword: $159E3376{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methfunctionheaderco); stack: nil; 
     keyword: $2B3C66ED{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @classdefreturnco); stack: nil; 
     keyword: $CF19BB75{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @classfieldco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_continue];
     dest: (context: @classdefparam1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @closeroundbracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam2a: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @classdefparam3co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassfield: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @vardefco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @simpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexp1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @equsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bequsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @simpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @termco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsimpexp1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @simpexp1aco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 baddterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @termco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfact: array[0..16] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @negfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat];
     dest: (handler: @handleaddressfact); stack: nil; keys: (
    (kind: bkk_char; chars: ['@']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @bracketstartco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: @numco); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @binnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['%']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @octnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['&']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @hexnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @stringco); stack: nil; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @charco); stack: nil; keys: (
    (kind: bkk_char; chars: ['#']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: @valueidentifierco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @illegalexpressionco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfact1: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['.']),
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat];
     dest: (handler: @handledereference); stack: nil; keys: (
    (kind: bkk_char; chars: ['^']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @getindexco); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @fact2co); stack: nil; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfact2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @valueidentifierwhiteco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnegfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvalueidentifier: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvalueidentifierwhite: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckvalueparams: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @params0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckparams: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @params0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparams0: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramsendco); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparams1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparams2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @params1co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramsendco); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetindex: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetindex1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @getindex2co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @closesquarebracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetindex2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bterm1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmulfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnum: array[0..3] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_nostartafter,bf_eat,bf_push];
     dest: (context: @checkfracco); stack: nil; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @fracexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['E','e']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfracexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @exponentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckfrac: array[0..1] of branchty = (
   (flags: [bf_nt];
     dest: (context: @fracco); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfrac: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @exponentco); stack: nil; keys: (
    (kind: bkk_char; chars: ['E','e']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexponent: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @numberco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnumber: array[0..4] of branchty = (
   (flags: [bf_nt,bf_handler,bf_eat];
     dest: (handler: @posnumber); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat];
     dest: (handler: @negnumber); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @decnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @numberexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdecnum: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bbinnum: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'1']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 boctnum: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'7']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bhexnum: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'F','a'..'f']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bordnum: array[0..5] of branchty = (
   (flags: [bf_nt];
     dest: (context: @decnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @binnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['%']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @octnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['&']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @hexnumco); stack: nil; keys: (
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @numberexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstring: array[0..3] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @string1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat,bf_push];
     dest: (handler: @stringlineenderror); stack: nil; keys: (
    (kind: bkk_char; chars: [#10]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstring1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @apostropheco); stack: nil; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @charco); stack: nil; keys: (
    (kind: bkk_char; chars: ['#']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bapostrophe: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @string1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @stringco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btoken: array[0..2] of branchty = (
   (flags: [bf_nt,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ','}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchar: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @ordnumco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchar1: array[0..3] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @stringco); stack: nil; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @charco); stack: nil; keys: (
    (kind: bkk_char; chars: ['#']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @char2co); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bident: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bidentpathcontinue: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bidentpath: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bidentpath1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['.']),
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_nostartbefore,bf_eat];
     dest: (context: @identpath2aco); stack: nil; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bidentpath2: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bbracketstart: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @simpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bbracketend: array[0..4] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @linecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @comment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
procedure init;
begin
 startco.branch:= @bstart;
 startco.next:= @nounitco;
 nounitco.branch:= nil;
 nounitco.handleexit:= @handlenouniterror;
 unit0co.branch:= @bunit0;
 unit0co.next:= @nounitnameco;
 nounitnameco.branch:= nil;
 nounitnameco.handleentry:= @handlenounitnameerror;
 unit1co.branch:= nil;
 unit1co.next:= @unit2co;
 unit1co.handleexit:= @setunitname;
 unit2co.branch:= @bunit2;
 unit2co.next:= @semicolonexpectedco;
 checksemicolonco.branch:= @bchecksemicolon;
 checksemicolon1co.branch:= @bchecksemicolon1;
 checksemicolon2co.branch:= @bchecksemicolon2;
 semicolonexpectedco.branch:= nil;
 semicolonexpectedco.handleexit:= @handlesemicolonexpected;
 identexpectedco.branch:= nil;
 identexpectedco.handleexit:= @handleidentexpected;
 start1co.branch:= @bstart1;
 start1co.next:= @start2co;
 uses0co.branch:= @buses0;
 uses0co.next:= @uses1co;
 uses1co.branch:= @buses1;
 uses1co.next:= @useserrorco;
 useserrorco.branch:= nil;
 useserrorco.handleexit:= @handleuseserror;
 usesokco.branch:= nil;
 usesokco.handleexit:= @handleuses;
 start2co.branch:= @bstart2;
 start2co.next:= @noimplementationco;
 commaidentsco.branch:= @bcommaidents;
 commaidentsco.next:= @commaidentsnoidenterrorco;
 commaidents1co.branch:= @bcommaidents1;
 commaidents1co.next:= @commaidents2co;
 commaidents2co.branch:= @bcommaidents2;
 commaidentsnoidenterrorco.branch:= nil;
 commaidentsnoidenterrorco.handleexit:= @handlenoidenterror;
 noimplementationco.branch:= nil;
 noimplementationco.handleexit:= @handlenoimplementationerror;
 implementationco.branch:= nil;
 implementationco.next:= @implementationstartco;
 implementationco.handleentry:= @interfacestop;
 implementationstartco.branch:= nil;
 implementationstartco.next:= @mainco;
 implementationstartco.handleentry:= @implementationstart;
 mainco.branch:= @bmain;
 mainco.next:= @main1co;
 main1co.branch:= @bmain1;
 main1co.handleexit:= @handlemain;
 comment0co.branch:= @bcomment0;
 comment0co.handleexit:= @handlecommentend;
 directiveco.branch:= @bdirective;
 directiveco.next:= @directive1co;
 directive1co.branch:= @bdirective1;
 includeco.branch:= @binclude;
 includeco.next:= @include1co;
 include1co.branch:= @binclude1;
 include1co.handleexit:= @handleinclude;
 dumpelementsco.branch:= nil;
 dumpelementsco.next:= @directiveendco;
 dumpelementsco.handleentry:= @handledumpelements;
 abortco.branch:= nil;
 abortco.next:= @directiveendco;
 abortco.handleentry:= @handleabort;
 directiveendco.branch:= @bdirectiveend;
 linecomment0co.branch:= @blinecomment0;
 linecomment1co.branch:= nil;
 linecomment1co.handleexit:= @handlecommentend;
 progbeginco.branch:= nil;
 progbeginco.next:= @progblockco;
 progbeginco.handleentry:= @handleprogbegin;
 progblockco.branch:= @bprogblock;
 progblockco.handleexit:= @handleprogblock;
 paramsdef0co.branch:= @bparamsdef0;
 paramsdef1co.branch:= @bparamsdef1;
 paramsdef1co.next:= @paramsdef2co;
 paramsdef2co.branch:= @bparamsdef2;
 paramsdef3co.branch:= nil;
 paramdef0co.branch:= @bparamdef0;
 paramdef0co.next:= @paramdef1co;
 paramdef0co.handleentry:= @handleparamsdef0entry;
 paramdef1co.branch:= @bparamdef1;
 paramdef2co.branch:= @bparamdef2;
 paramdef2co.handleexit:= @handleparamdef2;
 subfunctionheaderco.branch:= nil;
 subfunctionheaderco.next:= @procfuncheaderco;
 subfunctionheaderco.handleentry:= @handlefunctionentry;
 subprocedureheaderco.branch:= nil;
 subprocedureheaderco.next:= @procfuncheaderco;
 subprocedureheaderco.handleentry:= @handleprocedureentry;
 methfunctionheaderco.branch:= nil;
 methfunctionheaderco.next:= @procfuncheaderco;
 methfunctionheaderco.handleentry:= @handlemethfunctionentry;
 methprocedureheaderco.branch:= nil;
 methprocedureheaderco.next:= @procfuncheaderco;
 methprocedureheaderco.handleentry:= @handlemethprocedureentry;
 createsubheaderco.branch:= nil;
 createsubheaderco.next:= @procfuncheaderco;
 createsubheaderco.handleentry:= @handlecreatesubentry;
 procfuncheaderco.branch:= @bprocfuncheader;
 procfuncheaderco.handleexit:= @handlesubheader;
 functionco.branch:= nil;
 functionco.next:= @procfuncco;
 functionco.handleentry:= @handlefunctionentry;
 procedureco.branch:= nil;
 procedureco.next:= @procfuncco;
 procedureco.handleentry:= @handleprocedureentry;
 procfuncco.branch:= @bprocfunc;
 procfuncco.next:= @procedureaco;
 procedureaco.branch:= @bprocedurea;
 procedure0co.branch:= @bprocedure0;
 procedure0co.next:= @procedure1co;
 procedure1co.branch:= @bprocedure1;
 procedure1co.next:= @procedure2co;
 procedure1co.handleentry:= @handleprocedure1entry;
 procedure2co.branch:= @bprocedure2;
 functiontypeco.branch:= @bfunctiontype;
 resultidentco.branch:= @bresultident;
 resultidentco.handleentry:= @checkfunctiontype;
 functiontypeaco.branch:= @bfunctiontypea;
 procedure4co.branch:= @bprocedure4;
 procedure4co.next:= @checkterminatorco;
 procedure5aco.branch:= nil;
 procedure5aco.next:= @procedure5co;
 procedure5aco.handleentry:= @handleprocedure5a;
 procedure5co.branch:= @bprocedure5;
 procedure5co.next:= @procedure6co;
 procedure6co.branch:= nil;
 procedure6co.next:= @checkterminatorpopco;
 procedure6co.handleentry:= @handleprocedure6;
 checkterminatorco.branch:= @bcheckterminator;
 checkterminatorco.handleexit:= @handlecheckterminator;
 terminatorokco.branch:= nil;
 checkterminatorpopco.branch:= @bcheckterminatorpop;
 checkterminatorpopco.handleexit:= @handlecheckterminator;
 terminatorokpopco.branch:= nil;
 statementstackco.branch:= @bstatementstack;
 statementco.branch:= @bstatement;
 withco.branch:= nil;
 withco.next:= @with1co;
 withco.handleexit:= @handlewithentry;
 with1co.branch:= @bwith1;
 with1co.next:= @with2co;
 with2co.branch:= @bwith2;
 with2co.handleentry:= @handlewith2entry;
 with2co.handleexit:= @handledoexpected;
 with3co.branch:= @bwith3;
 with3co.handleexit:= @handlewith3;
 endcontextco.branch:= nil;
 blockendco.branch:= nil;
 blockendco.handleexit:= @handleblockend;
 simplestatementco.branch:= @bsimplestatement;
 statementblockco.branch:= @bstatementblock;
 statementblockco.next:= @statementblock1co;
 statementblock1co.branch:= @bstatementblock1;
 statementblock1co.handleexit:= @handlestatementblock1;
 statement0co.branch:= @bstatement0;
 statement0co.next:= @statement1co;
 statement0co.handleentry:= @handlestatement0entry;
 statement1co.branch:= @bstatement1;
 statement1co.handleexit:= @handlestatementexit;
 assignmentco.branch:= @bassignment;
 assignmentco.handleentry:= @handleassignmententry;
 assignmentco.handleexit:= @handleassignment;
 if0co.branch:= @bif0;
 if0co.next:= @ifco;
 if0co.handleentry:= @handleif0;
 ifco.branch:= @bif;
 ifco.next:= @thenco;
 ifco.handleentry:= @handleif;
 thenco.branch:= @bthen;
 thenco.handleexit:= @handlethen;
 then0co.branch:= nil;
 then0co.next:= @then1co;
 then0co.handleentry:= @handlethen0;
 then1co.branch:= @bthen1;
 then1co.next:= @then2co;
 then1co.handleentry:= @handlethen1;
 then2co.branch:= @bthen2;
 then2co.handleexit:= @handlethen2;
 else0co.branch:= nil;
 else0co.next:= @elseco;
 else0co.handleentry:= @handleelse0;
 elseco.branch:= @belse;
 elseco.handleexit:= @handleelse;
 constco.branch:= @bconst;
 const0co.branch:= @bconst0;
 const0co.next:= @const1co;
 const0co.handleexit:= @handleidentexpected;
 const1co.branch:= @bconst1;
 const1co.handleexit:= @handleequalityexpected;
 const2co.branch:= @bconst2;
 const2co.next:= @const3co;
 const3co.branch:= @bconst3;
 const3co.handleentry:= @handleconst3;
 simpletypeco.branch:= @bsimpletype;
 simpletypeco.next:= @rangetypeco;
 typeidentco.branch:= @btypeident;
 typeidentco.next:= @checktypeidentco;
 checktypeidentco.branch:= nil;
 checktypeidentco.handleexit:= @handlechecktypeident;
 rangetypeco.branch:= @brangetype;
 rangetypeco.handleexit:= @handlecheckrangetype;
 recorddefco.branch:= nil;
 recorddefco.next:= @recorddef0co;
 recorddefco.handleentry:= @handlerecorddefstart;
 recorddef0co.branch:= @brecorddef0;
 recorddef0co.next:= @recorddeferrorco;
 recorddeferrorco.branch:= nil;
 recorddeferrorco.handleexit:= @handlerecorddeferror;
 recordfieldco.branch:= @brecordfield;
 recordfieldco.handleexit:= @handlerecordfield;
 recorddefreturnco.branch:= nil;
 recorddefreturnco.handleentry:= @handlerecordtype;
 arraydefco.branch:= @barraydef;
 arraydefco.next:= @arraydef1co;
 arraydef1co.branch:= @barraydef1;
 arraydef1co.handleexit:= @handlearraydeferror1;
 arraydef2co.branch:= @barraydef2;
 arraydef2co.handleexit:= @handlearraytype;
 arrayindexco.branch:= @barrayindex;
 arrayindexco.handleexit:= @handlearrayindexerror1;
 arrayindex1co.branch:= @barrayindex1;
 arrayindex1co.next:= @arrayindex2co;
 arrayindex2co.branch:= @barrayindex2;
 getfieldtypeco.branch:= nil;
 getfieldtypeco.next:= @gettypeco;
 getfieldtypeco.handleentry:= @handlegetfieldtypestart;
 gettypetypeco.branch:= nil;
 gettypetypeco.next:= @gettypeco;
 gettypetypeco.handleentry:= @handlegettypetypestart;
 gettypeco.branch:= @bgettype;
 varco.branch:= @bvar;
 var0co.branch:= @bvar0;
 var0co.next:= @var1co;
 var1co.branch:= @bvar1;
 var1co.handleentry:= @handlevardefstart;
 var2co.branch:= @bvar2;
 var2co.next:= @var3co;
 var3co.branch:= nil;
 var3co.next:= @checksemicolon2co;
 var3co.handleexit:= @handlevar3;
 vardefco.branch:= @bvardef;
 vardefco.next:= @vardef0co;
 vardef0co.branch:= @bvardef0;
 vardef0co.handleentry:= @handlevardefstart;
 vardef1co.branch:= @bvardef1;
 vardef1co.next:= @checksemicolonco;
 typeco.branch:= @btype;
 typeco.handleexit:= @handletype;
 type0co.branch:= @btype0;
 type0co.next:= @type1co;
 type1co.branch:= @btype1;
 type1co.handleexit:= @handleequalityexpected;
 type2co.branch:= @btype2;
 type2co.next:= @type3co;
 type3co.branch:= @btype3;
 getrangeco.branch:= @bgetrange;
 getrangeco.next:= @getrange1co;
 getrange1co.branch:= @bgetrange1;
 getrange1co.handleexit:= @handlerange1;
 getrange3co.branch:= @bgetrange3;
 getrange3co.handleexit:= @handlerange3;
 classdefco.branch:= @bclassdef;
 classdefco.next:= @classdef0co;
 classdefco.handleentry:= @handleclassdefstart;
 classdef0co.branch:= @bclassdef0;
 classdef0co.next:= @classdeferrorco;
 classdeferrorco.branch:= nil;
 classdeferrorco.handleentry:= @handleclassdeferror;
 classdefreturnco.branch:= nil;
 classdefreturnco.handleentry:= @handleclassdefreturn;
 classdefparamco.branch:= @bclassdefparam;
 classdefparam1co.branch:= @bclassdefparam1;
 classdefparam1co.next:= @classdefparam2co;
 classdefparam2co.branch:= nil;
 classdefparam2co.next:= @classdefparam2aco;
 classdefparam2co.handleexit:= @handleclassdefparam2;
 classdefparam2aco.branch:= @bclassdefparam2a;
 classdefparam3co.branch:= @bclassdefparam3;
 classdefparam3co.next:= @classdefparam3aco;
 classdefparam3aco.branch:= nil;
 classdefparam3aco.next:= @classdefparam2aco;
 classdefparam3aco.handleexit:= @handleclassdefparam3a;
 classfieldco.branch:= @bclassfield;
 classfieldco.handleexit:= @handleclassfield;
 statementendco.branch:= nil;
 statementendco.handleexit:= @handlestatementend;
 expco.branch:= @bexp;
 expco.next:= @exp1co;
 exp1co.branch:= @bexp1;
 exp1co.handleexit:= @handleexp;
 equsimpexpco.branch:= @bequsimpexp;
 equsimpexpco.handleexit:= @handleequsimpexp;
 simpexpco.branch:= @bsimpexp;
 simpexpco.next:= @simpexp1co;
 simpexp1co.branch:= @bsimpexp1;
 simpexp1co.next:= @simpexp1co;
 simpexp1aco.branch:= nil;
 simpexp1aco.handleexit:= @handlesimpexp1;
 addtermco.branch:= @baddterm;
 addtermco.handleexit:= @handleaddterm;
 factco.branch:= @bfact;
 factco.next:= @fact1co;
 factco.handleentry:= @handlefactstart;
 fact1co.branch:= @bfact1;
 fact1co.handleexit:= @handlefact;
 fact2co.branch:= @bfact2;
 fact2co.next:= @fact1co;
 fact2co.handleentry:= @handlefact2entry;
 negfactco.branch:= @bnegfact;
 negfactco.handleexit:= @handlenegfact;
 valueidentifierco.branch:= @bvalueidentifier;
 valueidentifierco.next:= @checkvalueparamsco;
 valueidentifierwhiteco.branch:= @bvalueidentifierwhite;
 valueidentifierwhiteco.next:= @checkvalueparamsco;
 checkvalueparamsco.branch:= @bcheckvalueparams;
 checkvalueparamsco.handleexit:= @handlevalueidentifier;
 checkparamsco.branch:= @bcheckparams;
 params0co.branch:= @bparams0;
 params0co.next:= @params1co;
 params0co.handleentry:= @handleparams0entry;
 params1co.branch:= @bparams1;
 params1co.next:= @params2co;
 params2co.branch:= @bparams2;
 paramsendco.branch:= nil;
 paramsendco.handleentry:= @handleparamsend;
 getindexco.branch:= @bgetindex;
 getindexco.next:= @getindex1co;
 getindexco.handleentry:= @handleindexstart;
 getindex1co.branch:= @bgetindex1;
 getindex1co.handleexit:= @handleindex;
 getindex2co.branch:= @bgetindex2;
 getindex2co.next:= @getindex1co;
 termco.branch:= @bterm;
 termco.next:= @term1co;
 term1co.branch:= @bterm1;
 term1co.handleexit:= @handleterm;
 illegalexpressionco.branch:= nil;
 illegalexpressionco.handleexit:= @handleillegalexpression;
 mulfactco.branch:= @bmulfact;
 mulfactco.handleexit:= @handlemulfact;
 numco.branch:= @bnum;
 numco.handleexit:= @handleint;
 fracexpco.branch:= @bfracexp;
 fracexpco.next:= @fracco;
 checkfracco.branch:= @bcheckfrac;
 fracco.branch:= @bfrac;
 fracco.handleexit:= @handlefrac;
 exponentco.branch:= @bexponent;
 exponentco.handleexit:= @handleexponent;
 numberco.branch:= @bnumber;
 numberco.handleentry:= @handlenumberentry;
 decnumco.branch:= @bdecnum;
 decnumco.handleexit:= @handledecnum;
 binnumco.branch:= @bbinnum;
 binnumco.handleexit:= @handlebinnum;
 octnumco.branch:= @boctnum;
 octnumco.handleexit:= @handleoctnum;
 hexnumco.branch:= @bhexnum;
 hexnumco.handleexit:= @handlehexnum;
 ordnumco.branch:= @bordnum;
 stringco.branch:= @bstring;
 stringco.handleentry:= @handlestringstart;
 string1co.branch:= @bstring1;
 string1co.handleentry:= @copystring;
 apostropheco.branch:= @bapostrophe;
 apostropheco.handleentry:= @copyapostrophe;
 tokenco.branch:= @btoken;
 tokenco.handleentry:= @handlestringstart;
 tokenco.handleexit:= @copytoken;
 charco.branch:= @bchar;
 charco.next:= @char1co;
 charco.handleentry:= @handlestringstart;
 char1co.branch:= @bchar1;
 char1co.next:= @stringco;
 char1co.handleentry:= @handlechar;
 char2co.branch:= nil;
 identco.branch:= @bident;
 identco.handleexit:= @handleident;
 identpathcontinueco.branch:= @bidentpathcontinue;
 identpathco.branch:= @bidentpath;
 identpathco.next:= @identpath1aco;
 identpath1aco.branch:= nil;
 identpath1aco.next:= @identpath1co;
 identpath1aco.handleentry:= @handleidentpath1a;
 identpath1co.branch:= @bidentpath1;
 identpath2aco.branch:= nil;
 identpath2aco.next:= @identpath2co;
 identpath2aco.handleentry:= @handleidentpath2a;
 identpath2co.branch:= @bidentpath2;
 identpath2co.handleexit:= @handleidentpath2;
 bracketstartco.branch:= @bbracketstart;
 bracketstartco.next:= @bracketendco;
 bracketendco.branch:= @bbracketend;
 bracketendco.handleexit:= @handlebracketend;
 numberexpectedco.branch:= nil;
 numberexpectedco.handleexit:= @handlenumberexpected;
end;

function startcontext: pcontextty;
begin
 result:= @startco;
end;

initialization
 init;
end.

