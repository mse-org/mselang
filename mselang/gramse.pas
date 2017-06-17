{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
unit gramse;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,parserglob,elements;
 
function startcontext: pcontextty;

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
 program0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'program0');
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
 unit3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'unit3');
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
 checksemicolon1aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checksemicolon1a');
 checksemicolon2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checksemicolon2');
 checksemicolon2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checksemicolon2a');
 semicolonexpectedco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'semicolonexpected');
 colonexpectedco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'colonexpected');
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
 start2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'start2a');
 start2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'start2');
 start2classco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'start2class');
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
 implementation1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'implementation1');
 initializationco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'initialization');
 initialization1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'initialization1');
 finalizationco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'finalization');
 finalization1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'finalization1');
 implementationendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'implementationend');
 implementationend1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'implementationend1');
 mainco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'main');
 implusesco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'impluses');
 main1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'main1');
 main1classco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'main1class');
 curlycomment0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'curlycomment0');
 bracecomment0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'bracecomment0');
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
 ignoreddirectiveco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ignoreddirective');
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
 dumpopcodeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'dumpopcode');
 nopco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'nop');
 abortco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'abort');
 stoponerrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'stoponerror');
 modeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'mode');
 defineco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'define');
 define1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'define1');
 define2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'define2');
 undefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'undef');
 ifdefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifdef');
 ifdef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifdef1');
 ifndefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifndef');
 ifndef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifndef1');
 ifcondco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifcond');
 ifcond1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifcond1');
 skipifco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipif');
 skipif0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipif0');
 skipif1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipif1');
 skipifelseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipifelse');
 elseifco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'elseif');
 skipelseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipelse');
 skipelse0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipelse0');
 skipelse1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'skipelse1');
 endifco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'endif');
 compilerswitchco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'compilerswitch');
 compilerswitch1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'compilerswitch1');
 compilerswitch2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'compilerswitch2');
 directiveendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'directiveend');
 linecomment0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'linecomment0');
 linecomment1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
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
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef1');
 untypedparamco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'untypedparam');
 paramdef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef2');
 paramdef3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef3');
 paramdef4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef4');
 subclassfunctionheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subclassfunctionheader');
 subclassprocedureheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subclassprocedureheader');
 subclassmethodheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subclassmethodheader');
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
 submethodheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'submethodheader');
 subsubheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subsubheader');
 classmethmethodheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classmethmethodheader');
 classmethfunctionheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classmethfunctionheader');
 classmethprocedureheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classmethprocedureheader');
 methmethodheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'methmethodheader');
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
 methconstructorheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'methconstructorheader');
 methdestructorheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'methdestructorheader');
 proceduretypedefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'proceduretypedef');
 functiontypedefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'functiontypedef');
 subsubtypedefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subsubtypedef');
 methodtypedefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'methodtypedef');
 clasubheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheader');
 callclasubheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'callclasubheader');
 clasubheader0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheader0');
 clasubheader1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheader1');
 clasubheader2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheader2');
 clasubheader3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheader3');
 clasubheader4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheader4');
 virtualco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'virtual');
 overrideco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'override');
 overloadco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'overload');
 clasubheaderattachco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'clasubheaderattach');
 subtypedefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subtypedef');
 subtypedef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subtypedef0');
 subheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader');
 subheaderaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheadera');
 classfunctionco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classfunction');
 classprocedureco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classprocedure');
 classclamethodco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classclamethod');
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
 methodco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'method');
 subsubco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subsub');
 constructorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'constructor');
 destructorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'destructor');
 subco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'sub');
 sub1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'sub1');
 callsubheaderco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'callsubheader');
 subaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'suba');
 suba1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'suba1');
 subheader0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader0');
 subheader1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader1');
 subheader2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader2');
 subheader2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader2a');
 subofco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subof');
 subheader3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader3');
 subheader4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: true; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader4');
 externalco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'external');
 forwardco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forward');
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
 subbody4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subbody4');
 subbody5aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subbody5a');
 subbody5co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subbody5');
 subbody5bco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subbody5b');
 subbody6co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subbody6');
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
 compoundstatementco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'compoundstatement');
 tryco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'try');
 try1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'try1');
 finallyco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'finally');
 finally1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'finally1');
 exceptco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'except');
 except1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'except1');
 raiseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'raise');
 gotoco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'goto');
 checkendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkend');
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
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with3');
 with3aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with3a');
 with3bco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'with3b');
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
 labelcaseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'labelcase');
 checkcaselabelco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkcaselabel');
 checkcaselabel1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkcaselabel1');
 assignmentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'assignment');
 labelco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'label');
 statementco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statement');
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
 statementstackco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementstack');
 if0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'if0');
 thenco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then');
 statementgroupco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementgroup');
 then0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then0');
 then2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then2');
 then2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'then2a');
 elseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'else');
 else1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'else1');
 else1aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'else1a');
 whileco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'while');
 whiledoco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'whiledo');
 whiledo0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'whiledo0');
 whiledo0aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'whiledo0a');
 whiledo0bco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'whiledo0b');
 repeatco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'repeat');
 repeatuntil0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'repeatuntil0');
 forco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'for');
 forvarco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forvar');
 forstartco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forstart');
 fortoco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forto');
 downtoco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'downto');
 forstopco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forstop');
 fordoco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fordo');
 forbodyco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forbody');
 forbodyaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forbodya');
 forbodybco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forbodyb');
 casestatementgroupco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'casestatementgroup');
 caseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'case');
 caseofco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'caseof');
 casebranchco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'casebranch');
 casebranch1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'casebranch1');
 casebranch2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'casebranch2');
 casebranchrestartco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'casebranchrestart');
 casebranch3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'casebranch3');
 caseelseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'caseelse');
 checkcaseendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'checkcaseend');
 caseendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'caseend');
 commasepexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commasepexp');
 commasepexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commasepexp1');
 commasepexp2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commasepexp2');
 commasepexp3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'commasepexp3');
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
 setdefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'setdef');
 setdef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'setdef1');
 recorddefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recorddef');
 recorddef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recorddef1');
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
 recordcaseco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase');
 recordcase1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase1');
 recordcase2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase2');
 recordcase3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase3');
 recordcase4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase4');
 recordcase5co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase5');
 recordcase6co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase6');
 recordcase7co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase7');
 recordcase8co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcase8');
 recordcaseendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcaseend');
 recordca6aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordca6a');
 recordca7co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordca7');
 recordca8co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordca8');
 recordca9co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordca9');
 recordcaendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'recordcaend');
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
 enumdefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'enumdef');
 enumdef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'enumdef1');
 enumdef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'enumdef2');
 enumdef3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'enumdef3');
 getenumitemco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getenumitem');
 getenumitem1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getenumitem1');
 getenumitem2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getenumitem2');
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
 arrayindex3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'arrayindex3');
 getnamedtypeco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'getnamedtype');
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
 typedefreturnco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedefreturn');
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
 labeldefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'labeldef');
 labeldef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'labeldef0');
 labeldef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'labeldef1');
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
 typedconstco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconst');
 typedconst1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconst1');
 typedconst2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconst2');
 typedconst3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconst3');
 typedconstarrayco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconstarray');
 typedconstarray0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconstarray0');
 typedconstarray0aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconstarray0a');
 typedconstarray1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconstarray1');
 typedconstarray1aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconstarray1a');
 typedconstarray2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'typedconstarray2');
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
 fielddefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fielddef');
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
 vardef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'vardef2');
 vardef3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'vardef3');
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
 objectdefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'objectdef');
 classdefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdef');
 classdefaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefa');
 classdefforwardco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefforward');
 classdef0aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdef0a');
 classdef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdef0');
 classdef0bco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdef0b');
 classmethodco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classmethod');
 classdeferrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
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
               continue: false; restoresource: false; cutafter: true; 
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
 classdefattachco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classdefattach');
 attachitemsco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attachitems');
 attachidentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attachident');
 attachitems2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attachitems2');
 attachitems3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attachitems3');
 stringvalueco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'stringvalue');
 attachitems2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attachitems2a');
 attachitemsnoitemerrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attachitemsnoitemerror');
 attachco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attach');
 attach1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'attach1');
 classfieldco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classfield');
 propinddef1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'propinddef1');
 propinddef2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'propinddef2');
 propinddef3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'propinddef3');
 propind0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'propind0');
 propind1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'propind1');
 propind2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'propind2');
 classpropertyco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty');
 classproperty1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty1');
 classproperty2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty2a');
 classproperty2bco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty2b');
 classproperty2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty2');
 classproperty3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty3');
 readpropco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'readprop');
 readpropaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'readpropa');
 writepropco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'writeprop');
 writepropaco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'writepropa');
 defaultpropco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: true; nexteat: false; next: nil;
               caption: 'defaultprop');
 classproperty4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'classproperty4');
 interfacedefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfacedef');
 interfacedef0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfacedef0');
 interfacedeferrorco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfacedeferror');
 interfacedefreturnco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfacedefreturn');
 interfacedefparamco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfacedefparam');
 interfaceparam1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfaceparam1');
 interfaceparam2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfaceparam2');
 interfaceparam3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'interfaceparam3');
 statementendco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: true; cutbefore: false; nexteat: false; next: nil;
               caption: 'statementend');
 expco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'exp');
 callexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'callexp');
 exp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'exp1');
 callexppopco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'callexppop');
 exp1popco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'exp1pop');
 mulfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'mulfact');
 divfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'divfact');
 modfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'modfact');
 divisionfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'divisionfact');
 andfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'andfact');
 shlfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'shlfact');
 shrfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'shrfact');
 addtermco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'addterm');
 addterm1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'addterm1');
 subtermco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subterm');
 subterm1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subterm1');
 ortermco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'orterm');
 orterm1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'orterm1');
 xortermco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'xorterm');
 xorterm1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'xorterm1');
 xorsettermco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'xorsetterm');
 xorsetterm1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'xorsetterm1');
 eqsimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'eqsimpexp');
 eqsimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'eqsimpexp1');
 nesimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'nesimpexp');
 nesimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'nesimpexp1');
 gtsimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'gtsimpexp');
 gtsimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'gtsimpexp1');
 ltsimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ltsimpexp');
 ltsimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ltsimpexp1');
 gesimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'gesimpexp');
 gesimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'gesimpexp1');
 lesimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'lesimpexp');
 lesimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'lesimpexp1');
 insimpexpco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'insimpexp');
 insimpexp1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'insimpexp1');
 addressfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'addressfact');
 addressopfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'addressopfact');
 factco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fact');
 fact0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'fact0');
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
 notfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'notfact');
 listfactco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'listfact');
 listfact1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'listfact1');
 listfact2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'listfact2');
 listfact3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'listfact3');
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
 illegalexpressionco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'illegalexpression');
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
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ident');
 reservedwordco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'reservedword');
 ident0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ident0');
 getidentco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getident');
 getidentpathco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'getidentpath');
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
 valuepathcontinueco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: true; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepathcontinue');
 valuepathco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepath');
 valuepath0co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: true; next: nil;
               caption: 'valuepath0');
 valuepath0aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepath0a');
 valuepath1aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepath1a');
 valuepath1co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepath1');
 valuepath2aco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepath2a');
 valuepath2co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: true; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'valuepath2');
 numberexpectedco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'numberexpected');
implementation
uses
 handler,unithandler,classhandler,typehandler,subhandler,varhandler,exceptionhandler,controlhandler,handlerutils,valuehandler,interfacehandler,directivehandler;
const
 bstart: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @unit0co); stack: nil; 
     keyword: $A1C3D92B{'unit'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @program0co); stack: nil; 
     keyword: $4387B257{'program'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bunit0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bunit2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @unit3co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bunit3: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @start1co); stack: nil; 
     keyword: $870F64AE{'interface'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationco); stack: nil; 
     keyword: $0E1EC95D{'implementation'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon1a: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchecksemicolon2a: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstart1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @uses0co); stack: @start2aco; 
     keyword: $1C3D92BB{'uses'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
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
 bstart2: array[0..14] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationco); stack: nil; 
     keyword: $0E1EC95D{'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @typeco); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @constco); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @varco); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @labeldefco); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @start2classco); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @submethodheaderco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @subsubheaderco); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @subsubheaderco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstart2class: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentafterpush];
     dest: (context: @subclassprocedureheaderco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentafterpush];
     dest: (context: @subclassfunctionheaderco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentafterpush];
     dest: (context: @subclassmethodheaderco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bimplementation: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @mainco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bimplementation1: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @initializationco); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @finalizationco); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binitialization: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binitialization1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @finalizationco); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfinalization: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfinalization1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bimplementationend1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler,bf_push];
     dest: (handler: @handledotexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmain: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implusesco); stack: nil; 
     keyword: $1C3D92BB{'uses'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bimpluses: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push];
     dest: (context: @uses0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmain1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @typeco); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @constco); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @varco); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @labeldefco); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @main1classco); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @methodco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @subsubco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @subsubco); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @constructorco); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @destructorco); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @progbeginco); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmain1class: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @classprocedureco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @classfunctionco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @classclamethodco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcurlycomment0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bbracecomment0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['*']),
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdirective: array[0..21] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @modeco); stack: nil; 
     keyword: $64AEDF59{'mode'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @dumpelementsco); stack: nil; 
     keyword: $C95DBEB3{'dumpelements'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @dumpopcodeco); stack: nil; 
     keyword: $92BB7D66{'dumpopcode'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @abortco); stack: nil; 
     keyword: $2576FACC{'abort'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @stoponerrorco); stack: nil; 
     keyword: $4AEDF598{'stoponerror'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @nopco); stack: nil; 
     keyword: $95DBEB31{'nop'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @includeco); stack: nil; 
     keyword: $2BB7D662{'include'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @defineco); stack: nil; 
     keyword: $576FACC5{'define'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @undefco); stack: nil; 
     keyword: $AEDF598A{'undef'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @ifdefco); stack: nil; 
     keyword: $5DBEB315{'ifdef'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @ifndefco); stack: nil; 
     keyword: $BB7D662B{'ifndef'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @ifcondco); stack: nil; 
     keyword: $76FACC56{'if'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @elseifco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @endifco); stack: nil; 
     keyword: $DBEB3159{'endif'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @endifco); stack: nil; 
     keyword: $B7D662B3{'ifend'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: @ignoreddirectiveco); stack: nil; 
     keyword: $6FACC566{'h'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: @ignoreddirectiveco); stack: nil; 
     keyword: $64AEDF59{'mode'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: @ignoreddirectiveco); stack: nil; 
     keyword: $DF598ACD{'inline'}),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @compilerswitchco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bignoreddirective: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmode: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdefine: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdefine1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @define2co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdefine2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bundef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bifdef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: @ifdef1co; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bifndef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: @ifndef1co; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bifcond: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: @ifcond1co; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bskipif: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @skipif0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bskipif0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_continue];
     dest: (context: @skipif1co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bskipif1: array[0..5] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @skipifelseco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @directiveendco); stack: nil; 
     keyword: $DBEB3159{'endif'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @directiveendco); stack: nil; 
     keyword: $B7D662B3{'ifend'}),
   (flags: [bf_nt,bf_eat];
     dest: (context: @skipif0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bskipelse: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @skipelse0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bskipelse0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_continue];
     dest: (context: @skipelse1co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bskipelse1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @directiveendco); stack: nil; 
     keyword: $DBEB3159{'endif'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @directiveendco); stack: nil; 
     keyword: $B7D662B3{'ifend'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcompilerswitch: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcompilerswitch1: array[0..3] of branchty = (
   (flags: [bf_nt,bf_handler,bf_eat,bf_push];
     dest: (handler: @setcompilerswitch); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat,bf_push];
     dest: (handler: @unsetcompilerswitch); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @compilerswitch2co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcompilerswitch2: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_push];
     dest: (handler: @setlongcompilerswitch); stack: nil; 
     keyword: $BEB3159B{'on'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_push];
     dest: (handler: @unsetlongcompilerswitch); stack: nil; 
     keyword: $7D662B37{'off'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_push];
     dest: (handler: @setdefaultcompilerswitch); stack: nil; 
     keyword: $FACC566E{'default'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat,bf_push];
     dest: (handler: @setlongcompilerswitch); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_eat,bf_push];
     dest: (handler: @unsetlongcompilerswitch); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
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
   (flags: [bf_nt,bf_emptytoken,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bprogblock: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamsdef0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamsdef2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bparamdef0: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setconstparam); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setconstrefparam); stack: nil; 
     keyword: $F598ACDD{'constref'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setvarparam); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setoutparam); stack: nil; 
     keyword: $EB3159BB{'out'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @untypedparamco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef3: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @paramdef4co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparamdef4: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclasubheader: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @callclasubheaderco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcallclasubheader: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @clasubheader0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclasubheader0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bclasubheader1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @paramsdef0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclasubheader2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @functiontypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclasubheader3: array[0..11] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handlevirtual); stack: nil; 
     keyword: $85A1C3D9{'virtual'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleoverride); stack: nil; 
     keyword: $D662B376{'override'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleoverload); stack: nil; 
     keyword: $ACC566EC{'overload'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @clasubheaderattachco); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @clasubheader4co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @semicolonexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclasubheader4: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @virtualco); stack: nil; 
     keyword: $85A1C3D9{'virtual'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @overrideco); stack: nil; 
     keyword: $D662B376{'override'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @overloadco); stack: nil; 
     keyword: $ACC566EC{'overload'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler,bf_push];
     dest: (handler: @handlesubheader); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclasubheaderattach: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @attachco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubtypedef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @subtypedef0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheader: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @callsubheaderco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheadera: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsub: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @callsubheaderco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsub1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcallsubheader: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @subheader0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsuba: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsuba1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @subbody4co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheader0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bsubheader1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @paramsdef0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheader2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @functiontypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheader2a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @subofco); stack: nil; 
     keyword: $598ACDD8{'of'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubof: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @subheader3co); stack: nil; 
     keyword: $B3159BB1{'object'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheader3: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleexternal); stack: nil; 
     keyword: $662B3762{'external'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleforward); stack: nil; 
     keyword: $CC566EC4{'forward'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_nostartafter,bf_eat];
     dest: (context: @subheader4co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubheader4: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @externalco); stack: nil; 
     keyword: $662B3762{'external'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forwardco); stack: nil; 
     keyword: $CC566EC4{'forward'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfunctiontype: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @resultidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bresultident: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfunctiontypea: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bsubbody4: array[0..13] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @typeco); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @constco); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @varco); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @labeldefco); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @procedureco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @functionco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @subsubco); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @subbody5aco); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubbody5: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubbody5b: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @subbody6co); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckterminator: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckterminatorpop: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcompoundstatement: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btry: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btry1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @finallyco); stack: nil; 
     keyword: $3159BB13{'finally'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @exceptco); stack: nil; 
     keyword: $62B37626{'except'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfinally: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfinally1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @checkendco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexcept: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexcept1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @checkendco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 braise: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgoto: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckend: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler,bf_push];
     dest: (handler: @handleendexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwith1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @addressfactco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwith2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @with3co); stack: nil; 
     keyword: $C566EC4C{'do'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementgroupco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwith3a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @with3bco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsimplestatement: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statement0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatement0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatement1: array[0..9] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt];
     dest: (context: @checkcaselabelco); stack: nil; keys: (
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @labelcaseco); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @checkcaselabelco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bassignment: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatement: array[0..23] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @compoundstatementco); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $0B4387B2{ 'end'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $3159BB13{'finally'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $62B37626{'except'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @withco); stack: nil; 
     keyword: $8ACDD898{'with'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @if0co); stack: nil; 
     keyword: $76FACC56{'if'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @caseco); stack: nil; 
     keyword: $159BB130{'case'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @whileco); stack: nil; 
     keyword: $2B376261{'while'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @repeatco); stack: nil; 
     keyword: $566EC4C3{'repeat'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forco); stack: nil; 
     keyword: $ACDD8987{'for'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @tryco); stack: nil; 
     keyword: $59BB130E{'try'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @raiseco); stack: nil; 
     keyword: $B376261D{'raise'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @gotoco); stack: nil; 
     keyword: $66EC4C3A{'goto'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatementblock: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatementblock1: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $0B4387B2{ 'end'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $3159BB13{'finally'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $62B37626{'except'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bstatementstack: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bif0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @then0co); stack: nil; 
     keyword: $CDD89874{'then'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstatementgroup: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementgroupco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @then2aco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @elseco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 belse: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementgroupco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 belse1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @else1aco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwhile: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwhiledo: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @whiledo0co); stack: nil; 
     keyword: $C566EC4C{'do'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwhiledo0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementgroupco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwhiledo0a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @whiledo0bco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brepeat: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @repeatuntil0co); stack: nil; 
     keyword: $9BB130E8{'until'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_continue];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brepeatuntil0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfor: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforvar: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @forstartco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: [':']),
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforstart: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforto: array[0..2] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forstopco); stack: nil; 
     keyword: $376261D1{'to'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @downtoco); stack: nil; 
     keyword: $6EC4C3A3{'downto'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforstop: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfordo: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forbodyco); stack: nil; 
     keyword: $C566EC4C{'do'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforbody: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementgroupco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforbodya: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forbodybco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcasestatementgroup: array[0..4] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_eat,bf_continue];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcase: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcaseof: array[0..2] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @casebranchco); stack: nil; 
     keyword: $598ACDD8{'of'}),
   (flags: [bf_nt,bf_emptytoken,bf_handler,bf_push];
     dest: (handler: @handleofexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcasebranch: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @caseelseco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @caseendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @commasepexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcasebranch1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @casebranch2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcasebranch2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @casestatementgroupco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcasebranch3: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @casebranchco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcaseelse: array[0..2] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @caseendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementblockco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckcaseend: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @checkendco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommasepexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommasepexp1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @commasepexp2co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['.']),
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @commasepexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommasepexp2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommasepexp3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @commasepexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brangetype: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getrangeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsetdef: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @setdef1co); stack: nil; 
     keyword: $598ACDD8{'of'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsetdef1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecorddef1: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @recordcaseco); stack: nil; 
     keyword: $159BB130{'case'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @recorddefreturnco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @recordca6aco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordfield: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @fielddefco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordcase2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase3: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @recordcase4co); stack: nil; 
     keyword: $598ACDD8{'of'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase4: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword];
     dest: (context: @recordcaseendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @recordcaseendco); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @commasepexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase5: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordcase6co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase6: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordcase7co); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase7: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @recordcaseco); stack: nil; 
     keyword: $159BB130{'case'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordcase8co); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordcase8: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordcase4co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordca7: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordca8co); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @recordca6aco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordca8: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword];
     dest: (context: @recordcaendco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordca9co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @recordcaendco); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordca9: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @recordca7co); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barraydef: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @arraydef2co); stack: nil; 
     keyword: $598ACDD8{'of'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @arrayindexco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barraydef1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @arraydef2co); stack: nil; 
     keyword: $598ACDD8{'of'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 benumdef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getenumitemco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 benumdef1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @enumdef3co); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @enumdef2co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 benumdef2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getenumitemco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetenumitem: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetenumitem1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @getenumitem2co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetenumitem2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
   (flags: [bf_nt,bf_eat];
     dest: (context: @arrayindex3co); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_handler,bf_push];
     dest: (handler: @handlearrayindexerror2); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barrayindex3: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @arrayindex1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetnamedtype: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgettype: array[0..18] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @setdefco); stack: nil; 
     keyword: $DD898746{'set'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @recorddefco); stack: nil; 
     keyword: $BB130E8C{'record'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @arraydefco); stack: nil; 
     keyword: $76261D18{'array'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @objectdefco); stack: nil; 
     keyword: $B3159BB1{'object'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @classdefco); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @interfacedefco); stack: nil; 
     keyword: $870F64AE{'interface'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @proceduretypedefco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @functiontypedefco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @subtypedefco); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @methodtypedefco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @enumdefco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @simpletypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype: array[0..22] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0E1EC95D{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush];
     dest: (context: @type0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
 btype1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btype3: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blabeldef: array[0..22] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0E1EC95D{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @labeldef0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blabeldef0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @identexpectedco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blabeldef1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst: array[0..22] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0E1EC95D{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @const0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst0: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @handleidentexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat];
     dest: (context: @typedconstco); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bconst3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @checksemicolon1co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconst: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @gettypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconst1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @typedconst2co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconst2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconst3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken];
     dest: (context: @checksemicolon1co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconstarray: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @typedconstarray0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconstarray0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @typedconstarray1co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconstarray0a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @checksemicolon2aco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconstarray1a: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @typedconstarray1co); stack: @typedconstarray2co; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 btypedconstarray2: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
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
   (flags: [bf_nt,bf_eat];
     dest: (context: @typedconstarray1aco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @handlecloseroundbracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar: array[0..22] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0E1EC95D{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush];
     dest: (context: @var0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvar1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfielddef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvardef0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvardef2: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword];
     dest: (context: @vardef3co); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @vardef3co); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @vardef3co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetrange: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetrange1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefa: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @classdefparamco); stack: @classdef0aco; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @classdefattachco); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @classdefforwardco); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdef0a: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @classdefattachco); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdef0b: array[0..19] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclassprivate); stack: nil; 
     keyword: $EC4C3A30{'private'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclassprotected); stack: nil; 
     keyword: $D8987460{'protected'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclasspublic); stack: nil; 
     keyword: $B130E8C1{'public'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclasspublished); stack: nil; 
     keyword: $6261D183{'published'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @classmethodco); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methmethodheaderco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methprocedureheaderco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methfunctionheaderco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methconstructorheaderco); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methdestructorheaderco); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @classpropertyco); stack: nil; 
     keyword: $C4C3A306{'property'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @classdefreturnco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @recordca6aco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassmethod: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentafterpush];
     dest: (context: @classmethmethodheaderco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentafterpush];
     dest: (context: @classmethprocedureheaderco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentafterpush];
     dest: (context: @classmethfunctionheaderco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
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
     dest: (handler: @handlecloseroundbracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam2a: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @handlecloseroundbracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefparam3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdefattach: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @attachco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battachitems: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @attachidentco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battachident: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battachitems2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @attachitemsco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @attachitems3co); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battachitems3: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @stringvalueco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bstringvalue: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
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
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battachitems2a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: @attachitemsco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battach: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @attachitemsco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 battach1: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @handleclosesquarebracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassfield: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @fielddefco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bpropinddef1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @propind0co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bpropinddef2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @propinddef1co); stack: nil; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @propinddef3co); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bpropind0: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setconstparam); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bpropind1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @propind2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bpropind2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @getfieldtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @classproperty2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @classproperty2aco); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty2a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @propinddef1co); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty2b: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @classproperty2co); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getnamedtypeco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty3: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @readpropco); stack: nil; 
     keyword: $8987460D{'read'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @writepropco); stack: nil; 
     keyword: $130E8C1A{'write'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @defaultpropco); stack: nil; 
     keyword: $FACC566E{'default'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 breadprop: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 breadpropa: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_changeparentcontext];
     dest: (context: @getidentpathco); stack: @writepropco; 
     keyword: $130E8C1A{'write'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush,bf_changeparentcontext];
     dest: (context: @expco); stack: @defaultpropco; 
     keyword: $FACC566E{'default'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwriteprop: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bwritepropa: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush,bf_changeparentcontext];
     dest: (context: @expco); stack: @defaultpropco; 
     keyword: $FACC566E{'default'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdefaultprop: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassproperty4: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_emptytoken,bf_handler];
     dest: (handler: @handlesemicolonexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binterfacedef: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @interfacedefparamco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binterfacedef0: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methmethodheaderco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methprocedureheaderco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methfunctionheaderco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @interfacedefreturnco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binterfacedefparam: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentbeforepush];
     dest: (context: @interfaceparam1co); stack: nil; keys: (
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
     dest: (handler: @handlecloseroundbracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binterfaceparam1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binterfaceparam2: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @interfaceparam3co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
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
     dest: (handler: @handlecloseroundbracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binterfaceparam3: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: @interfaceparam1co); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @callexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcallexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexp1: array[0..24] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @insimpexpco); stack: nil; 
     keyword: $0E8C1A1B{'in'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @nesimpexpco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['<']),
    (kind: bkk_char; chars: ['>']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @gesimpexpco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @lesimpexpco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @eqsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @gtsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['>']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @ltsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['<']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcallexppop: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bexp1pop: array[0..24] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @insimpexpco); stack: nil; 
     keyword: $0E8C1A1B{'in'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @nesimpexpco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['<']),
    (kind: bkk_char; chars: ['>']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @gesimpexpco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @lesimpexpco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @eqsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @gtsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['>']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @ltsimpexpco); stack: nil; keys: (
    (kind: bkk_char; chars: ['<']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmulfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdivfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bmodfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bdivisionfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bandfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bshlfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bshrfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 baddterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 baddterm1: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bsubterm1: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 borterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 borterm1: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bxorterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bxorterm1: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bxorsetterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bxorsetterm1: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 beqsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 beqsimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnesimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnesimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgtsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgtsimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bltsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bltsimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgesimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgesimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blesimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blesimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 binsimpexp1: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $261D1834{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @modfactco); stack: nil; 
     keyword: $4C3A3068{'mod'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @xorsettermco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['>']),
    (kind: bkk_char; chars: ['<']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @mulfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @divisionfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @addtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_continue];
     dest: (context: @subtermco); stack: nil; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfact0: array[0..27] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @notfactco); stack: nil; 
     keyword: $1D183437{'not'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $987460D0{'and'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $30E8C1A1{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $61D18343{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $C3A30686{'or'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $87460D0D{'xor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0E8C1A1B{'in'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $3A30686F{'is'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $7460D0DE{'as'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @addressopfactco); stack: nil; keys: (
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
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: @listfactco); stack: nil; keys: (
    (kind: bkk_char; chars: ['[']),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bfact1: array[0..9] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnegfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bnotfact: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @factco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blistfact: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @listfact3co); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blistfact1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 blistfact2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @listfact1co); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @listfact3co); stack: nil; keys: (
    (kind: bkk_char; chars: [']']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bbracketstart: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @callexpco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bbracketend: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvalueidentifier: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @valuepathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvalueidentifierwhite: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @valuepathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcheckvalueparams: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bcheckparams: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bparams0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bparams2: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetindex1: array[0..8] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
     dest: (handler: @handleclosesquarebracketexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetindex2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @expco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bchar: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @ordnumco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bident: array[0..19] of branchty = (
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $0E1EC95D{'implementation'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $387B2576{'type'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $70F64AED{'const'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $E1EC95DB{'var'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $C3D92BB7{'label'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $B2576FAC{'begin'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $87B2576F{'class'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $3D92BB7D{'method'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $98ACDD89{'sub'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $0F64AEDF{'procedure'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $1EC95DBE{'function'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $EC95DBEB{'constructor'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $D92BB7D6{'destructor'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $0B4387B2{'end'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $EDF598AC{'else'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $7B2576FA{'initialization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $F64AEDF5{'finalization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $3159BB13{'finally'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $62B37626{'except'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bident0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetident: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @identco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler,bf_push];
     dest: (handler: @handleidentexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bgetidentpath: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken,bf_handler,bf_push];
     dest: (handler: @handleidentexpected); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommaidents: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcommaidents2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat];
     dest: (context: @commaidentsco); stack: nil; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bidentpathcontinue: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @identpathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
 bidentpath1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bidentpath2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
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
 bvaluepathcontinue: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @valuepathco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvaluepath0: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handlevalueinherited); stack: nil; 
     keyword: $E8C1A1BD{'inherited'}),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvaluepath0a: array[0..1] of branchty = (
   (flags: [bf_nt,bf_eat];
     dest: (context: nil); stack: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvaluepath1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_nostartbefore,bf_eat];
     dest: (context: @valuepath2aco); stack: nil; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bvaluepath2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @directiveco); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @bracecomment0co); stack: nil; keys: (
    (kind: bkk_charcontinued; chars: ['(']),
    (kind: bkk_char; chars: ['*']),
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
     dest: (context: @curlycomment0co); stack: nil; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push];
     dest: (context: @valuepathco); stack: nil; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
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
 program0co.branch:= nil;
 program0co.next:= @unit0co;
 program0co.handleentry:= @handleprogramentry;
 unit0co.branch:= @bunit0;
 unit0co.next:= @nounitnameco;
 nounitnameco.branch:= nil;
 nounitnameco.handleentry:= @handlenounitnameerror;
 unit1co.branch:= nil;
 unit1co.next:= @unit2co;
 unit1co.handleexit:= @setunitname;
 unit2co.branch:= @bunit2;
 unit2co.next:= @semicolonexpectedco;
 unit3co.branch:= @bunit3;
 unit3co.next:= @implementationco;
 unit3co.handleexit:= @handleafterintfuses;
 checksemicolonco.branch:= @bchecksemicolon;
 checksemicolon1co.branch:= @bchecksemicolon1;
 checksemicolon1aco.branch:= @bchecksemicolon1a;
 checksemicolon2co.branch:= @bchecksemicolon2;
 checksemicolon2aco.branch:= @bchecksemicolon2a;
 semicolonexpectedco.branch:= nil;
 semicolonexpectedco.handleexit:= @handlesemicolonexpected;
 colonexpectedco.branch:= nil;
 colonexpectedco.handleexit:= @handlecolonexpected;
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
 start2aco.branch:= nil;
 start2aco.next:= @start2co;
 start2co.branch:= @bstart2;
 start2co.next:= @noimplementationco;
 start2co.handleentry:= @handleafterintfuses;
 start2classco.branch:= @bstart2class;
 start2classco.next:= @start2co;
 noimplementationco.branch:= nil;
 noimplementationco.next:= @implementationco;
 noimplementationco.handleentry:= @handlenoimplementationerror;
 implementationco.branch:= @bimplementation;
 implementationco.next:= @implementation1co;
 implementationco.handleentry:= @handleimplementationentry;
 implementation1co.branch:= @bimplementation1;
 implementation1co.handleexit:= @handleendexpected;
 initializationco.branch:= @binitialization;
 initializationco.next:= @initialization1co;
 initializationco.handleentry:= @handleinitializationstart;
 initialization1co.branch:= @binitialization1;
 initialization1co.handleentry:= @handleinitialization;
 initialization1co.handleexit:= @handleendexpected;
 finalizationco.branch:= @bfinalization;
 finalizationco.next:= @finalization1co;
 finalizationco.handleentry:= @handlefinalizationstart;
 finalization1co.branch:= @bfinalization1;
 finalization1co.handleentry:= @handlefinalization;
 finalization1co.handleexit:= @handleendexpected;
 implementationendco.branch:= nil;
 implementationendco.next:= @implementationend1co;
 implementationendco.handleexit:= @handleimplementation;
 implementationend1co.branch:= @bimplementationend1;
 mainco.branch:= @bmain;
 mainco.next:= @main1co;
 mainco.handleexit:= @handleafterimpluses;
 implusesco.branch:= @bimpluses;
 implusesco.next:= @main1co;
 implusesco.handleentry:= @handleimplusesentry;
 implusesco.handleexit:= @handleafterimpluses;
 main1co.branch:= @bmain1;
 main1co.handleexit:= @handlemain;
 main1classco.branch:= @bmain1class;
 main1classco.next:= @main1co;
 curlycomment0co.branch:= @bcurlycomment0;
 curlycomment0co.handleexit:= @handlecommentend;
 bracecomment0co.branch:= @bbracecomment0;
 bracecomment0co.handleexit:= @handlecommentend;
 directiveco.branch:= @bdirective;
 directiveco.next:= @directive1co;
 directiveco.handleentry:= @handledirectiveentry;
 directive1co.branch:= @bdirective1;
 ignoreddirectiveco.branch:= @bignoreddirective;
 ignoreddirectiveco.next:= @directiveendco;
 ignoreddirectiveco.handleexit:= @handleignoreddirective;
 includeco.branch:= @binclude;
 includeco.next:= @include1co;
 include1co.branch:= @binclude1;
 include1co.handleexit:= @handleinclude;
 dumpelementsco.branch:= nil;
 dumpelementsco.next:= @directiveendco;
 dumpelementsco.handleentry:= @handledumpelements;
 dumpopcodeco.branch:= nil;
 dumpopcodeco.next:= @directiveendco;
 dumpopcodeco.handleentry:= @handledumpopcode;
 nopco.branch:= nil;
 nopco.next:= @directiveendco;
 nopco.handleentry:= @handlenop;
 abortco.branch:= nil;
 abortco.next:= @directiveendco;
 abortco.handleentry:= @handleabort;
 stoponerrorco.branch:= nil;
 stoponerrorco.next:= @directiveendco;
 stoponerrorco.handleentry:= @handlestoponerror;
 modeco.branch:= @bmode;
 modeco.next:= @directiveendco;
 modeco.handleexit:= @handlemode;
 defineco.branch:= @bdefine;
 defineco.next:= @define1co;
 define1co.branch:= @bdefine1;
 define1co.next:= @directiveendco;
 define1co.handleexit:= @handledefine;
 define2co.branch:= @bdefine2;
 define2co.next:= @directiveendco;
 define2co.handleexit:= @handledefinevalue;
 undefco.branch:= @bundef;
 undefco.next:= @directiveendco;
 undefco.handleexit:= @handleundef;
 ifdefco.branch:= @bifdef;
 ifdefco.next:= @skipifco;
 ifdef1co.branch:= nil;
 ifdef1co.next:= @directiveendco;
 ifdef1co.handleexit:= @handleifdef;
 ifndefco.branch:= @bifndef;
 ifndefco.next:= @skipifco;
 ifndef1co.branch:= nil;
 ifndef1co.next:= @directiveendco;
 ifndef1co.handleexit:= @handleifndef;
 ifcondco.branch:= @bifcond;
 ifcondco.next:= @skipifco;
 ifcondco.handleentry:= @ifcondentry;
 ifcond1co.branch:= nil;
 ifcond1co.next:= @directiveendco;
 ifcond1co.handleexit:= @handleifcond;
 skipifco.branch:= @bskipif;
 skipifco.next:= @directiveendco;
 skipif0co.branch:= @bskipif0;
 skipif1co.branch:= @bskipif1;
 skipifelseco.branch:= nil;
 skipifelseco.next:= @directiveendco;
 skipifelseco.handleentry:= @handleskipifelseentry;
 elseifco.branch:= nil;
 elseifco.next:= @skipelseco;
 elseifco.handleexit:= @handleelseif;
 skipelseco.branch:= @bskipelse;
 skipelseco.next:= @directiveendco;
 skipelse0co.branch:= @bskipelse0;
 skipelse1co.branch:= @bskipelse1;
 endifco.branch:= nil;
 endifco.next:= @directiveendco;
 endifco.handleentry:= @handleendif;
 compilerswitchco.branch:= @bcompilerswitch;
 compilerswitchco.next:= @compilerswitch1co;
 compilerswitchco.handleentry:= @handlecompilerswitchentry;
 compilerswitch1co.branch:= @bcompilerswitch1;
 compilerswitch1co.next:= @directiveendco;
 compilerswitch1co.handleexit:= @handlecompilerswitch;
 compilerswitch2co.branch:= @bcompilerswitch2;
 compilerswitch2co.next:= @directiveendco;
 compilerswitch2co.handleentry:= @handlelongcompilerswitchentry;
 compilerswitch2co.handleexit:= @handlecompilerswitch;
 directiveendco.branch:= @bdirectiveend;
 directiveendco.handleentry:= @handledirective;
 linecomment0co.branch:= @blinecomment0;
 linecomment1co.branch:= nil;
 linecomment1co.handleexit:= @handlecommentend;
 progbeginco.branch:= nil;
 progbeginco.next:= @progblockco;
 progbeginco.handleentry:= @handleprogbegin;
 progblockco.branch:= @bprogblock;
 progblockco.handleexit:= @handleprogblock;
 paramsdef0co.branch:= @bparamsdef0;
 paramsdef0co.handleentry:= @handleparamsdefentry;
 paramsdef1co.branch:= @bparamsdef1;
 paramsdef1co.next:= @paramsdef2co;
 paramsdef2co.branch:= @bparamsdef2;
 paramsdef3co.branch:= nil;
 paramsdef3co.handleexit:= @handleparamsdef;
 paramdef0co.branch:= @bparamdef0;
 paramdef0co.next:= @paramdef1co;
 paramdef0co.handleentry:= @handleparamdef0entry;
 paramdef1co.branch:= @bparamdef1;
 untypedparamco.branch:= nil;
 untypedparamco.handleexit:= @handleuntypedparam;
 paramdef2co.branch:= @bparamdef2;
 paramdef2co.next:= @paramdef3co;
 paramdef3co.branch:= @bparamdef3;
 paramdef3co.handleexit:= @handleparamdef3;
 paramdef4co.branch:= @bparamdef4;
 paramdef4co.handleexit:= @handleparamdefault;
 subclassfunctionheaderco.branch:= nil;
 subclassfunctionheaderco.next:= @subheaderco;
 subclassfunctionheaderco.handleentry:= @handleclassfunctionentry;
 subclassprocedureheaderco.branch:= nil;
 subclassprocedureheaderco.next:= @subheaderco;
 subclassprocedureheaderco.handleentry:= @handleclassprocedureentry;
 subclassmethodheaderco.branch:= nil;
 subclassmethodheaderco.next:= @subheaderco;
 subclassmethodheaderco.handleentry:= @handleclassmethodentry;
 subfunctionheaderco.branch:= nil;
 subfunctionheaderco.next:= @subheaderco;
 subfunctionheaderco.handleentry:= @handlefunctionentry;
 subprocedureheaderco.branch:= nil;
 subprocedureheaderco.next:= @subheaderco;
 subprocedureheaderco.handleentry:= @handleprocedureentry;
 submethodheaderco.branch:= nil;
 submethodheaderco.next:= @subheaderco;
 submethodheaderco.handleentry:= @handlemethodentry;
 subsubheaderco.branch:= nil;
 subsubheaderco.next:= @subheaderco;
 subsubheaderco.handleentry:= @handlesubentry;
 classmethmethodheaderco.branch:= nil;
 classmethmethodheaderco.next:= @clasubheaderco;
 classmethmethodheaderco.handleentry:= @handleclassmethmethodentry;
 classmethfunctionheaderco.branch:= nil;
 classmethfunctionheaderco.next:= @clasubheaderco;
 classmethfunctionheaderco.handleentry:= @handleclassmethfunctionentry;
 classmethprocedureheaderco.branch:= nil;
 classmethprocedureheaderco.next:= @clasubheaderco;
 classmethprocedureheaderco.handleentry:= @handleclassmethprocedureentry;
 methmethodheaderco.branch:= nil;
 methmethodheaderco.next:= @clasubheaderco;
 methmethodheaderco.handleentry:= @handlemethmethodentry;
 methfunctionheaderco.branch:= nil;
 methfunctionheaderco.next:= @clasubheaderco;
 methfunctionheaderco.handleentry:= @handlemethfunctionentry;
 methprocedureheaderco.branch:= nil;
 methprocedureheaderco.next:= @clasubheaderco;
 methprocedureheaderco.handleentry:= @handlemethprocedureentry;
 methconstructorheaderco.branch:= nil;
 methconstructorheaderco.next:= @clasubheaderco;
 methconstructorheaderco.handleentry:= @handlemethconstructorentry;
 methdestructorheaderco.branch:= nil;
 methdestructorheaderco.next:= @clasubheaderco;
 methdestructorheaderco.handleentry:= @handlemethdestructorentry;
 proceduretypedefco.branch:= nil;
 proceduretypedefco.next:= @subtypedefco;
 proceduretypedefco.handleentry:= @handleproceduretypedefentry;
 functiontypedefco.branch:= nil;
 functiontypedefco.next:= @subtypedefco;
 functiontypedefco.handleentry:= @handlefunctiontypedefentry;
 subsubtypedefco.branch:= nil;
 subsubtypedefco.next:= @subtypedefco;
 subsubtypedefco.handleentry:= @handlesubtypedefentry;
 methodtypedefco.branch:= nil;
 methodtypedefco.next:= @subtypedefco;
 methodtypedefco.handleentry:= @handlemethodtypedefentry;
 clasubheaderco.branch:= @bclasubheader;
 clasubheaderco.handleentry:= @handleclasubheaderentry;
 callclasubheaderco.branch:= @bcallclasubheader;
 callclasubheaderco.next:= @subaco;
 callclasubheaderco.handleentry:= @callsubheaderentry;
 clasubheader0co.branch:= @bclasubheader0;
 clasubheader0co.next:= @clasubheader1co;
 clasubheader1co.branch:= @bclasubheader1;
 clasubheader1co.next:= @clasubheader2co;
 clasubheader1co.handleentry:= @handlesub1entry;
 clasubheader2co.branch:= @bclasubheader2;
 clasubheader2co.next:= @clasubheader3co;
 clasubheader3co.branch:= @bclasubheader3;
 clasubheader4co.branch:= @bclasubheader4;
 virtualco.branch:= nil;
 virtualco.next:= @clasubheader3co;
 virtualco.handleentry:= @handlevirtual;
 overrideco.branch:= nil;
 overrideco.next:= @clasubheader3co;
 overrideco.handleentry:= @handleoverride;
 overloadco.branch:= nil;
 overloadco.next:= @clasubheader3co;
 overloadco.handleentry:= @handleoverload;
 clasubheaderattachco.branch:= @bclasubheaderattach;
 clasubheaderattachco.handleexit:= @handleclasubheaderattach;
 subtypedefco.branch:= @bsubtypedef;
 subtypedef0co.branch:= nil;
 subtypedef0co.next:= @subheader1co;
 subtypedef0co.handleentry:= @handlesubtypedef0entry;
 subheaderco.branch:= @bsubheader;
 subheaderco.next:= @subheaderaco;
 subheaderaco.branch:= @bsubheadera;
 classfunctionco.branch:= nil;
 classfunctionco.next:= @subco;
 classfunctionco.handleentry:= @handleclassfunctionentry;
 classprocedureco.branch:= nil;
 classprocedureco.next:= @subco;
 classprocedureco.handleentry:= @handleclassprocedureentry;
 classclamethodco.branch:= nil;
 classclamethodco.next:= @subco;
 classclamethodco.handleentry:= @handleclassmethodentry;
 functionco.branch:= nil;
 functionco.next:= @subco;
 functionco.handleentry:= @handlefunctionentry;
 procedureco.branch:= nil;
 procedureco.next:= @subco;
 procedureco.handleentry:= @handleprocedureentry;
 methodco.branch:= nil;
 methodco.next:= @subco;
 methodco.handleentry:= @handlemethodentry;
 subsubco.branch:= nil;
 subsubco.next:= @subco;
 subsubco.handleentry:= @handlesubentry;
 constructorco.branch:= nil;
 constructorco.next:= @subco;
 constructorco.handleentry:= @handleconstructorentry;
 destructorco.branch:= nil;
 destructorco.next:= @subco;
 destructorco.handleentry:= @handledestructorentry;
 subco.branch:= @bsub;
 subco.next:= @sub1co;
 sub1co.branch:= @bsub1;
 callsubheaderco.branch:= @bcallsubheader;
 callsubheaderco.next:= @subaco;
 callsubheaderco.handleentry:= @callsubheaderentry;
 subaco.branch:= @bsuba;
 subaco.next:= @suba1co;
 suba1co.branch:= @bsuba1;
 subheader0co.branch:= @bsubheader0;
 subheader0co.next:= @subheader1co;
 subheader1co.branch:= @bsubheader1;
 subheader1co.next:= @subheader2co;
 subheader1co.handleentry:= @handlesub1entry;
 subheader2co.branch:= @bsubheader2;
 subheader2co.next:= @subheader2aco;
 subheader2aco.branch:= @bsubheader2a;
 subheader2aco.next:= @subheader3co;
 subofco.branch:= @bsubof;
 subofco.handleentry:= @subofentry;
 subofco.handleexit:= @handleofobjectexpected;
 subheader3co.branch:= @bsubheader3;
 subheader4co.branch:= @bsubheader4;
 subheader4co.handleexit:= @handlesubheader;
 externalco.branch:= nil;
 externalco.next:= @subheader3co;
 externalco.handleentry:= @handleexternal;
 forwardco.branch:= nil;
 forwardco.next:= @subheader3co;
 forwardco.handleentry:= @handleforward;
 functiontypeco.branch:= @bfunctiontype;
 resultidentco.branch:= @bresultident;
 resultidentco.handleentry:= @checkfunctiontype;
 functiontypeaco.branch:= @bfunctiontypea;
 subbody4co.branch:= @bsubbody4;
 subbody4co.handleexit:= @handlebeginexpected;
 subbody5aco.branch:= nil;
 subbody5aco.next:= @subbody5co;
 subbody5aco.handleentry:= @handlesubbody5a;
 subbody5co.branch:= @bsubbody5;
 subbody5co.next:= @subbody5bco;
 subbody5bco.branch:= @bsubbody5b;
 subbody5bco.handleexit:= @handleendexpected;
 subbody6co.branch:= nil;
 subbody6co.next:= @checkterminatorpopco;
 subbody6co.handleentry:= @handlesubbody6;
 checkterminatorco.branch:= @bcheckterminator;
 checkterminatorco.handleexit:= @handlecheckterminator;
 terminatorokco.branch:= nil;
 checkterminatorpopco.branch:= @bcheckterminatorpop;
 checkterminatorpopco.handleexit:= @handlecheckterminator;
 terminatorokpopco.branch:= nil;
 compoundstatementco.branch:= @bcompoundstatement;
 compoundstatementco.next:= @checkendco;
 tryco.branch:= @btry;
 tryco.next:= @try1co;
 tryco.handleentry:= @handletryentry;
 try1co.branch:= @btry1;
 try1co.handleexit:= @handlefinallyexpected;
 finallyco.branch:= @bfinally;
 finallyco.next:= @finally1co;
 finallyco.handleentry:= @handlefinallyentry;
 finally1co.branch:= @bfinally1;
 finally1co.handleentry:= @handlefinally;
 exceptco.branch:= @bexcept;
 exceptco.next:= @except1co;
 exceptco.handleentry:= @handleexceptentry;
 except1co.branch:= @bexcept1;
 except1co.handleentry:= @handleexcept;
 raiseco.branch:= @braise;
 raiseco.handleexit:= @handleraise;
 gotoco.branch:= @bgoto;
 gotoco.handleexit:= @handlegoto;
 checkendco.branch:= @bcheckend;
 withco.branch:= nil;
 withco.next:= @with1co;
 withco.handleexit:= @handlewithentry;
 with1co.branch:= @bwith1;
 with1co.next:= @with2co;
 with2co.branch:= @bwith2;
 with2co.handleentry:= @handlewith2entry;
 with2co.handleexit:= @handledoexpected;
 with3co.branch:= @bwith3;
 with3co.next:= @with3aco;
 with3aco.branch:= @bwith3a;
 with3aco.handleexit:= @handleendexpected;
 with3bco.branch:= nil;
 with3bco.handleexit:= @handlewith3;
 endcontextco.branch:= nil;
 blockendco.branch:= nil;
 simplestatementco.branch:= @bsimplestatement;
 statement0co.branch:= @bstatement0;
 statement0co.next:= @statement1co;
 statement0co.handleentry:= @handlestatement0entry;
 statement1co.branch:= @bstatement1;
 statement1co.handleexit:= @handlestatementexit;
 labelcaseco.branch:= nil;
 labelcaseco.next:= @labelco;
 labelcaseco.handleexit:= @handlecheckcaselabel;
 checkcaselabelco.branch:= nil;
 checkcaselabelco.next:= @checkcaselabel1co;
 checkcaselabelco.handleexit:= @handlecheckcaselabel;
 checkcaselabel1co.branch:= nil;
 checkcaselabel1co.handleexit:= @handlestatementexit;
 assignmentco.branch:= @bassignment;
 assignmentco.handleentry:= @handleassignmententry;
 assignmentco.handleexit:= @handleassignment;
 labelco.branch:= nil;
 labelco.handleexit:= @handlelabel;
 statementco.branch:= @bstatement;
 statementblockco.branch:= @bstatementblock;
 statementblockco.next:= @statementblock1co;
 statementblock1co.branch:= @bstatementblock1;
 statementblock1co.handleexit:= @handlestatementblock1;
 statementstackco.branch:= @bstatementstack;
 if0co.branch:= @bif0;
 if0co.next:= @thenco;
 if0co.handleentry:= @handleif0;
 thenco.branch:= @bthen;
 thenco.handleexit:= @handlethen;
 statementgroupco.branch:= @bstatementgroup;
 then0co.branch:= @bthen0;
 then0co.next:= @then2co;
 then0co.handleentry:= @handlethen0;
 then2co.branch:= @bthen2;
 then2co.handleexit:= @handleendexpected;
 then2aco.branch:= nil;
 then2aco.handleexit:= @handlethen2;
 elseco.branch:= @belse;
 elseco.next:= @else1co;
 elseco.handleentry:= @handleelse0;
 else1co.branch:= @belse1;
 else1co.handleexit:= @handleendexpected;
 else1aco.branch:= nil;
 else1aco.handleexit:= @handleelse;
 whileco.branch:= @bwhile;
 whileco.next:= @whiledoco;
 whileco.handleentry:= @handlewhilestart;
 whiledoco.branch:= @bwhiledo;
 whiledoco.handleexit:= @handledoexpected;
 whiledo0co.branch:= @bwhiledo0;
 whiledo0co.next:= @whiledo0aco;
 whiledo0co.handleentry:= @handlewhileexpression;
 whiledo0aco.branch:= @bwhiledo0a;
 whiledo0aco.handleexit:= @handleendexpected;
 whiledo0bco.branch:= nil;
 whiledo0bco.handleexit:= @handlewhileend;
 repeatco.branch:= @brepeat;
 repeatco.handleentry:= @handlerepeatstart;
 repeatco.handleexit:= @handleuntilexpected;
 repeatuntil0co.branch:= @brepeatuntil0;
 repeatuntil0co.handleentry:= @handleuntilentry;
 repeatuntil0co.handleexit:= @handlerepeatend;
 forco.branch:= @bfor;
 forco.next:= @forvarco;
 forvarco.branch:= @bforvar;
 forvarco.handleentry:= @handleforvar;
 forvarco.handleexit:= @handleassignmentexpected;
 forstartco.branch:= @bforstart;
 forstartco.next:= @fortoco;
 forstartco.handleexit:= @handleforstart;
 fortoco.branch:= @bforto;
 fortoco.handleexit:= @handletoexpected;
 downtoco.branch:= nil;
 downtoco.next:= @forstopco;
 downtoco.handleexit:= @handledownto;
 forstopco.branch:= @bforstop;
 forstopco.next:= @fordoco;
 fordoco.branch:= @bfordo;
 fordoco.handleexit:= @handledoexpected;
 forbodyco.branch:= @bforbody;
 forbodyco.next:= @forbodyaco;
 forbodyco.handleentry:= @handleforheader;
 forbodyaco.branch:= @bforbodya;
 forbodyaco.handleexit:= @handleendexpected;
 forbodybco.branch:= nil;
 forbodybco.handleexit:= @handleforend;
 casestatementgroupco.branch:= @bcasestatementgroup;
 casestatementgroupco.handleentry:= @handlecasestatementgroupstart;
 caseco.branch:= @bcase;
 caseco.next:= @caseofco;
 caseco.handleentry:= @handlecasestart;
 caseofco.branch:= @bcaseof;
 caseofco.handleentry:= @handlecaseexpression;
 caseofco.handleexit:= @handlecase;
 casebranchco.branch:= @bcasebranch;
 casebranchco.next:= @casebranch1co;
 casebranchco.handleentry:= @handlecasebranch1entry;
 casebranch1co.branch:= @bcasebranch1;
 casebranch1co.handleexit:= @handlecolonexpected;
 casebranch2co.branch:= @bcasebranch2;
 casebranch2co.next:= @casebranch3co;
 casebranch2co.handleentry:= @handlecasebranchentry;
 casebranchrestartco.branch:= nil;
 casebranchrestartco.next:= @casebranch3co;
 casebranch3co.branch:= @bcasebranch3;
 casebranch3co.next:= @casebranchco;
 casebranch3co.handleentry:= @handlecasebranch;
 caseelseco.branch:= @bcaseelse;
 caseelseco.next:= @checkcaseendco;
 checkcaseendco.branch:= @bcheckcaseend;
 checkcaseendco.next:= @caseendco;
 caseendco.branch:= nil;
 commasepexpco.branch:= @bcommasepexp;
 commasepexpco.next:= @commasepexp1co;
 commasepexp1co.branch:= @bcommasepexp1;
 commasepexp2co.branch:= @bcommasepexp2;
 commasepexp2co.next:= @commasepexp3co;
 commasepexp3co.branch:= @bcommasepexp3;
 commasepexp3co.handleentry:= @handlecommaseprange;
 simpletypeco.branch:= @bsimpletype;
 simpletypeco.next:= @rangetypeco;
 typeidentco.branch:= @btypeident;
 typeidentco.next:= @checktypeidentco;
 checktypeidentco.branch:= nil;
 checktypeidentco.handleexit:= @handlechecktypeident;
 rangetypeco.branch:= @brangetype;
 rangetypeco.handleexit:= @handlecheckrangetype;
 setdefco.branch:= @bsetdef;
 setdefco.handleexit:= @handleofexpected;
 setdef1co.branch:= @bsetdef1;
 setdef1co.handleexit:= @handlesettype;
 recorddefco.branch:= nil;
 recorddefco.next:= @recorddef1co;
 recorddefco.handleentry:= @handlerecorddefstart;
 recorddef1co.branch:= @brecorddef1;
 recorddef1co.next:= @recorddeferrorco;
 recorddeferrorco.branch:= nil;
 recorddeferrorco.handleexit:= @handlerecorddeferror;
 recordfieldco.branch:= @brecordfield;
 recordfieldco.handleexit:= @handlerecordfield;
 recorddefreturnco.branch:= nil;
 recorddefreturnco.handleentry:= @handlerecordtype;
 recordcaseco.branch:= @brecordcase;
 recordcaseco.next:= @recordcase1co;
 recordcaseco.handleentry:= @handlerecordcasestart;
 recordcase1co.branch:= @brecordcase1;
 recordcase1co.next:= @recordcase3co;
 recordcase1co.handleexit:= @handlerecordcase1;
 recordcase2co.branch:= @brecordcase2;
 recordcase2co.next:= @recordcase3co;
 recordcase2co.handleexit:= @handlerecordcasetype;
 recordcase3co.branch:= @brecordcase3;
 recordcase3co.next:= @recorddefco;
 recordcase3co.handleexit:= @handlecaseofexpected;
 recordcase4co.branch:= @brecordcase4;
 recordcase4co.next:= @recordcase5co;
 recordcase4co.handleexit:= @handlerecordcase4;
 recordcase5co.branch:= @brecordcase5;
 recordcase5co.handleexit:= @handlerecordcase5;
 recordcase6co.branch:= @brecordcase6;
 recordcase6co.handleexit:= @handlerecordcase6;
 recordcase7co.branch:= @brecordcase7;
 recordcase7co.handleentry:= @handlerecordcaseitementry;
 recordcase7co.handleexit:= @handlerecordcase7;
 recordcase8co.branch:= @brecordcase8;
 recordcase8co.next:= @recordcase4co;
 recordcase8co.handleentry:= @handlerecordcaseitem;
 recordcaseendco.branch:= nil;
 recordcaseendco.handleexit:= @handlerecordcase;
 recordca6aco.branch:= nil;
 recordca6aco.next:= @recordca7co;
 recordca6aco.handleentry:= @handlerecordcasestart;
 recordca7co.branch:= @brecordca7;
 recordca7co.handleentry:= @handlerecordcaseitementry;
 recordca7co.handleexit:= @handlerecordcase7;
 recordca8co.branch:= @brecordca8;
 recordca8co.handleentry:= @handlerecordcaseitem;
 recordca8co.handleexit:= @handlesemicolonexpected;
 recordca9co.branch:= @brecordca9;
 recordca9co.next:= @recordcaendco;
 recordcaendco.branch:= nil;
 recordcaendco.handleexit:= @handlerecordcase;
 arraydefco.branch:= @barraydef;
 arraydefco.next:= @arraydef1co;
 arraydef1co.branch:= @barraydef1;
 arraydef1co.handleexit:= @handlearraydeferror1;
 arraydef2co.branch:= @barraydef2;
 arraydef2co.handleexit:= @handlearraytype;
 enumdefco.branch:= @benumdef;
 enumdefco.next:= @enumdef1co;
 enumdefco.handleentry:= @handleenumdefentry;
 enumdef1co.branch:= @benumdef1;
 enumdef1co.handleexit:= @handlecloseroundbracketexpected;
 enumdef2co.branch:= @benumdef2;
 enumdef2co.next:= @enumdef1co;
 enumdef3co.branch:= nil;
 enumdef3co.handleexit:= @handleenumdef;
 getenumitemco.branch:= @bgetenumitem;
 getenumitemco.next:= @getenumitem1co;
 getenumitem1co.branch:= @bgetenumitem1;
 getenumitem1co.handleexit:= @handleenumitem;
 getenumitem2co.branch:= @bgetenumitem2;
 getenumitem2co.handleexit:= @handleenumitemvalue;
 arrayindexco.branch:= @barrayindex;
 arrayindexco.handleexit:= @handlearrayindexerror1;
 arrayindex1co.branch:= @barrayindex1;
 arrayindex1co.next:= @arrayindex2co;
 arrayindex2co.branch:= @barrayindex2;
 arrayindex3co.branch:= @barrayindex3;
 getnamedtypeco.branch:= @bgetnamedtype;
 getnamedtypeco.handleexit:= @handlenamedtype;
 getfieldtypeco.branch:= nil;
 getfieldtypeco.next:= @gettypeco;
 getfieldtypeco.handleentry:= @handlegetfieldtypestart;
 gettypetypeco.branch:= nil;
 gettypetypeco.next:= @gettypeco;
 gettypetypeco.handleentry:= @handlegettypetypestart;
 gettypeco.branch:= @bgettype;
 typedefreturnco.branch:= nil;
 typeco.branch:= @btype;
 typeco.handleexit:= @handletype;
 type0co.branch:= @btype0;
 type0co.next:= @type1co;
 type1co.branch:= @btype1;
 type1co.handleexit:= @handleequalityexpected;
 type2co.branch:= @btype2;
 type2co.next:= @type3co;
 type3co.branch:= @btype3;
 labeldefco.branch:= @blabeldef;
 labeldefco.next:= @identexpectedco;
 labeldef0co.branch:= @blabeldef0;
 labeldef0co.next:= @labeldef1co;
 labeldef1co.branch:= @blabeldef1;
 labeldef1co.handleentry:= @handlelabeldef;
 constco.branch:= @bconst;
 const0co.branch:= @bconst0;
 const0co.next:= @const1co;
 const1co.branch:= @bconst1;
 const1co.handleexit:= @handleequalityexpected;
 const2co.branch:= @bconst2;
 const2co.next:= @const3co;
 const3co.branch:= @bconst3;
 const3co.handleentry:= @handleconst3;
 typedconstco.branch:= @btypedconst;
 typedconstco.next:= @typedconst1co;
 typedconst1co.branch:= @btypedconst1;
 typedconst1co.handleexit:= @handleequalityexpected;
 typedconst2co.branch:= @btypedconst2;
 typedconst2co.next:= @typedconst3co;
 typedconst2co.handleentry:= @handletypedconst2entry;
 typedconst2co.handleexit:= @handletypedconst;
 typedconst3co.branch:= @btypedconst3;
 typedconstarrayco.branch:= @btypedconstarray;
 typedconstarrayco.handleexit:= @handleopenroundbracketexpected;
 typedconstarray0co.branch:= @btypedconstarray0;
 typedconstarray0co.next:= @typedconstarray0aco;
 typedconstarray0aco.branch:= @btypedconstarray0a;
 typedconstarray0aco.handleexit:= @handletypedconstarray;
 typedconstarray1co.branch:= nil;
 typedconstarray1co.next:= @typedconstarray1aco;
 typedconstarray1co.handleentry:= @handletypedconstarraylevelentry;
 typedconstarray1aco.branch:= @btypedconstarray1a;
 typedconstarray1aco.next:= @typedconstarray2co;
 typedconstarray1aco.handleexit:= @handletypedconstarrayitem;
 typedconstarray2co.branch:= @btypedconstarray2;
 typedconstarray2co.handleexit:= @handletypedconstarraylevel;
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
 fielddefco.branch:= @bfielddef;
 fielddefco.next:= @vardef0co;
 vardef0co.branch:= @bvardef0;
 vardef0co.handleentry:= @handlevardefstart;
 vardef1co.branch:= @bvardef1;
 vardef1co.next:= @vardef2co;
 vardef2co.branch:= @bvardef2;
 vardef2co.next:= @checksemicolonco;
 vardef3co.branch:= nil;
 getrangeco.branch:= @bgetrange;
 getrangeco.next:= @getrange1co;
 getrange1co.branch:= @bgetrange1;
 getrange1co.handleexit:= @handlerange1;
 getrange3co.branch:= @bgetrange3;
 getrange3co.handleexit:= @handlerange3;
 objectdefco.branch:= nil;
 objectdefco.next:= @classdefaco;
 objectdefco.handleentry:= @handleobjectdefstart;
 classdefco.branch:= nil;
 classdefco.next:= @classdefaco;
 classdefco.handleentry:= @handleclassdefstart;
 classdefaco.branch:= @bclassdefa;
 classdefaco.next:= @classdef0co;
 classdefforwardco.branch:= nil;
 classdefforwardco.handleexit:= @handleclassdefforward;
 classdef0aco.branch:= @bclassdef0a;
 classdef0aco.next:= @classdef0co;
 classdef0co.branch:= nil;
 classdef0co.next:= @classdef0bco;
 classdef0co.handleexit:= @handleclassdef0;
 classdef0bco.branch:= @bclassdef0b;
 classdef0bco.next:= @classdeferrorco;
 classmethodco.branch:= @bclassmethod;
 classmethodco.next:= @classdef0bco;
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
 classdefattachco.branch:= @bclassdefattach;
 classdefattachco.handleexit:= @handleclassdefattach;
 attachitemsco.branch:= @battachitems;
 attachitemsco.next:= @attachitemsnoitemerrorco;
 attachitemsco.handleentry:= @handleattachitemsentry;
 attachidentco.branch:= @battachident;
 attachidentco.next:= @attachitems2co;
 attachitems2co.branch:= @battachitems2;
 attachitems3co.branch:= @battachitems3;
 attachitems3co.next:= @attachitems2aco;
 attachitems3co.handleexit:= @handleattachvalue;
 stringvalueco.branch:= @bstringvalue;
 attachitems2aco.branch:= @battachitems2a;
 attachitemsnoitemerrorco.branch:= nil;
 attachitemsnoitemerrorco.handleexit:= @handlenoattachitemerror;
 attachco.branch:= @battach;
 attachco.next:= @attach1co;
 attach1co.branch:= @battach1;
 classfieldco.branch:= @bclassfield;
 classfieldco.handleexit:= @handlerecordfield;
 propinddef1co.branch:= @bpropinddef1;
 propinddef1co.next:= @propinddef2co;
 propinddef2co.branch:= @bpropinddef2;
 propinddef3co.branch:= nil;
 propind0co.branch:= @bpropind0;
 propind0co.next:= @propind1co;
 propind0co.handleentry:= @handleparamdef0entry;
 propind1co.branch:= @bpropind1;
 propind2co.branch:= @bpropind2;
 propind2co.handleexit:= @handleparamdef3;
 classpropertyco.branch:= @bclassproperty;
 classpropertyco.next:= @classproperty1co;
 classpropertyco.handleentry:= @classpropertyentry;
 classproperty1co.branch:= @bclassproperty1;
 classproperty1co.handleexit:= @handlecolonexpected;
 classproperty2aco.branch:= @bclassproperty2a;
 classproperty2aco.next:= @classproperty2bco;
 classproperty2bco.branch:= @bclassproperty2b;
 classproperty2bco.handleexit:= @handlecolonexpected;
 classproperty2co.branch:= @bclassproperty2;
 classproperty2co.next:= @classproperty3co;
 classproperty3co.branch:= @bclassproperty3;
 classproperty3co.next:= @classproperty4co;
 readpropco.branch:= @breadprop;
 readpropco.next:= @readpropaco;
 readpropco.handleexit:= @handlereadprop;
 readpropaco.branch:= @breadpropa;
 readpropaco.next:= @classproperty4co;
 writepropco.branch:= @bwriteprop;
 writepropco.next:= @writepropaco;
 writepropco.handleexit:= @handlewriteprop;
 writepropaco.branch:= @bwritepropa;
 writepropaco.next:= @classproperty4co;
 defaultpropco.branch:= @bdefaultprop;
 defaultpropco.next:= @classproperty4co;
 defaultpropco.handleexit:= @handledefaultprop;
 classproperty4co.branch:= @bclassproperty4;
 classproperty4co.handleexit:= @handleclassproperty;
 interfacedefco.branch:= @binterfacedef;
 interfacedefco.next:= @interfacedef0co;
 interfacedefco.handleentry:= @handleinterfacedefstart;
 interfacedef0co.branch:= @binterfacedef0;
 interfacedef0co.next:= @interfacedeferrorco;
 interfacedeferrorco.branch:= nil;
 interfacedeferrorco.handleentry:= @handleinterfacedeferror;
 interfacedefreturnco.branch:= nil;
 interfacedefreturnco.handleentry:= @handleinterfacedefreturn;
 interfacedefparamco.branch:= @binterfacedefparam;
 interfacedefparamco.handleexit:= @handleinterfaceparam;
 interfaceparam1co.branch:= @binterfaceparam1;
 interfaceparam1co.next:= @interfaceparam2co;
 interfaceparam2co.branch:= @binterfaceparam2;
 interfaceparam2co.handleentry:= @handleinterfaceparam2entry;
 interfaceparam3co.branch:= @binterfaceparam3;
 interfaceparam3co.handleexit:= @handleidentexpected;
 statementendco.branch:= nil;
 statementendco.handleexit:= @handlestatementend;
 expco.branch:= @bexp;
 expco.handleexit:= @handleexp;
 callexpco.branch:= @bcallexp;
 callexpco.next:= @exp1co;
 exp1co.branch:= @bexp1;
 exp1co.handleexit:= @handleexp1;
 callexppopco.branch:= @bcallexppop;
 callexppopco.next:= @exp1popco;
 exp1popco.branch:= @bexp1pop;
 exp1popco.handleexit:= @handleexp1;
 mulfactco.branch:= @bmulfact;
 mulfactco.handleexit:= @handlemulfact;
 divfactco.branch:= @bdivfact;
 divfactco.handleexit:= @handledivfact;
 modfactco.branch:= @bmodfact;
 modfactco.handleexit:= @handlemodfact;
 divisionfactco.branch:= @bdivisionfact;
 divisionfactco.handleexit:= @handledivisionfact;
 andfactco.branch:= @bandfact;
 andfactco.handleentry:= @andopentry;
 andfactco.handleexit:= @handleandfact;
 shlfactco.branch:= @bshlfact;
 shlfactco.handleexit:= @handleshlfact;
 shrfactco.branch:= @bshrfact;
 shrfactco.handleexit:= @handleshrfact;
 addtermco.branch:= @baddterm;
 addtermco.next:= @addterm1co;
 addterm1co.branch:= @baddterm1;
 addterm1co.handleexit:= @handleaddterm;
 subtermco.branch:= @bsubterm;
 subtermco.next:= @subterm1co;
 subterm1co.branch:= @bsubterm1;
 subterm1co.handleexit:= @handlesubterm;
 ortermco.branch:= @borterm;
 ortermco.next:= @orterm1co;
 ortermco.handleentry:= @oropentry;
 orterm1co.branch:= @borterm1;
 orterm1co.handleexit:= @handleorterm;
 xortermco.branch:= @bxorterm;
 xortermco.next:= @xorterm1co;
 xortermco.handleentry:= @oropentry;
 xorterm1co.branch:= @bxorterm1;
 xorterm1co.handleexit:= @handlexorterm;
 xorsettermco.branch:= @bxorsetterm;
 xorsettermco.next:= @xorsetterm1co;
 xorsetterm1co.branch:= @bxorsetterm1;
 xorsetterm1co.handleexit:= @handlexorsetterm;
 eqsimpexpco.branch:= @beqsimpexp;
 eqsimpexpco.next:= @eqsimpexp1co;
 eqsimpexp1co.branch:= @beqsimpexp1;
 eqsimpexp1co.handleexit:= @handleeqsimpexp;
 nesimpexpco.branch:= @bnesimpexp;
 nesimpexpco.next:= @nesimpexp1co;
 nesimpexp1co.branch:= @bnesimpexp1;
 nesimpexp1co.handleexit:= @handlenesimpexp;
 gtsimpexpco.branch:= @bgtsimpexp;
 gtsimpexpco.next:= @gtsimpexp1co;
 gtsimpexp1co.branch:= @bgtsimpexp1;
 gtsimpexp1co.handleexit:= @handlegtsimpexp;
 ltsimpexpco.branch:= @bltsimpexp;
 ltsimpexpco.next:= @ltsimpexp1co;
 ltsimpexp1co.branch:= @bltsimpexp1;
 ltsimpexp1co.handleexit:= @handleltsimpexp;
 gesimpexpco.branch:= @bgesimpexp;
 gesimpexpco.next:= @gesimpexp1co;
 gesimpexp1co.branch:= @bgesimpexp1;
 gesimpexp1co.handleexit:= @handlegesimpexp;
 lesimpexpco.branch:= @blesimpexp;
 lesimpexpco.next:= @lesimpexp1co;
 lesimpexp1co.branch:= @blesimpexp1;
 lesimpexp1co.handleexit:= @handlelesimpexp;
 insimpexpco.branch:= @binsimpexp;
 insimpexpco.next:= @insimpexp1co;
 insimpexp1co.branch:= @binsimpexp1;
 insimpexp1co.handleexit:= @handleinsimpexp;
 addressfactco.branch:= nil;
 addressfactco.next:= @fact0co;
 addressfactco.handleentry:= @handleaddressfactentry;
 addressopfactco.branch:= nil;
 addressopfactco.next:= @fact0co;
 addressopfactco.handleentry:= @handleaddressopfactentry;
 factco.branch:= nil;
 factco.next:= @fact0co;
 factco.handleentry:= @handlefactentry;
 fact0co.branch:= @bfact0;
 fact0co.next:= @fact1co;
 fact1co.branch:= @bfact1;
 fact1co.handleentry:= @fact1entry;
 fact1co.handleexit:= @handlefact1;
 fact2co.branch:= @bfact2;
 fact2co.next:= @fact1co;
 fact2co.handleentry:= @fact2entry;
 negfactco.branch:= @bnegfact;
 negfactco.handleexit:= @handlenegfact;
 notfactco.branch:= @bnotfact;
 notfactco.handleexit:= @handlenotfact;
 listfactco.branch:= @blistfact;
 listfactco.next:= @listfact1co;
 listfact1co.branch:= @blistfact1;
 listfact1co.next:= @listfact2co;
 listfact2co.branch:= @blistfact2;
 listfact3co.branch:= nil;
 listfact3co.handleexit:= @handlelistfact;
 bracketstartco.branch:= @bbracketstart;
 bracketstartco.next:= @bracketendco;
 bracketendco.branch:= @bbracketend;
 bracketendco.handleexit:= @handlebracketend;
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
 getindex1co.handleentry:= @handleindexitem;
 getindex1co.handleexit:= @handleindex;
 getindex2co.branch:= @bgetindex2;
 getindex2co.next:= @getindex1co;
 getindex2co.handleentry:= @handleindexitemstart;
 illegalexpressionco.branch:= nil;
 illegalexpressionco.handleexit:= @handleillegalexpression;
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
 identco.next:= @ident0co;
 reservedwordco.branch:= nil;
 reservedwordco.handleexit:= @handlereservedword;
 ident0co.branch:= @bident0;
 ident0co.handleentry:= @handleidentstart;
 ident0co.handleexit:= @handleident;
 getidentco.branch:= @bgetident;
 getidentpathco.branch:= @bgetidentpath;
 commaidentsco.branch:= @bcommaidents;
 commaidentsco.next:= @commaidentsnoidenterrorco;
 commaidents1co.branch:= @bcommaidents1;
 commaidents1co.next:= @commaidents2co;
 commaidents2co.branch:= @bcommaidents2;
 commaidentsnoidenterrorco.branch:= nil;
 commaidentsnoidenterrorco.handleexit:= @handlenoidenterror;
 identpathcontinueco.branch:= @bidentpathcontinue;
 identpathco.branch:= @bidentpath;
 identpathco.next:= @identpath1aco;
 identpathco.handleentry:= @handleidentpathstart;
 identpath1aco.branch:= nil;
 identpath1aco.next:= @identpath1co;
 identpath1aco.handleentry:= @handleidentpath1a;
 identpath1co.branch:= @bidentpath1;
 identpath2aco.branch:= nil;
 identpath2aco.next:= @identpath2co;
 identpath2aco.handleentry:= @handleidentpath2a;
 identpath2co.branch:= @bidentpath2;
 identpath2co.handleexit:= @handleidentpath2;
 valuepathcontinueco.branch:= @bvaluepathcontinue;
 valuepathco.branch:= nil;
 valuepathco.next:= @valuepath0co;
 valuepath0co.branch:= @bvaluepath0;
 valuepath0co.next:= @valuepath0aco;
 valuepath0co.handleentry:= @handlevaluepathstart;
 valuepath0aco.branch:= @bvaluepath0a;
 valuepath0aco.next:= @valuepath1aco;
 valuepath1aco.branch:= nil;
 valuepath1aco.next:= @valuepath1co;
 valuepath1aco.handleentry:= @handlevaluepath1a;
 valuepath1co.branch:= @bvaluepath1;
 valuepath2aco.branch:= nil;
 valuepath2aco.next:= @valuepath2co;
 valuepath2aco.handleentry:= @handlevaluepath2a;
 valuepath2co.branch:= @bvaluepath2;
 valuepath2co.handleexit:= @handlevaluepath2;
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

