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
 globtypes,parserglob,elements;
 
function startcontext: pcontextty;

const
 tks_none = 0;
 tks_classes = $2468ACF1;
 tks_private = $48D159E3;
 tks_protected = $91A2B3C6;
 tks_public = $2345678C;
 tks_published = $468ACF19;
 tks_classintfname = $8D159E33;
 tks_classintftype = $1A2B3C66;
 tks_classimp = $345678CD;
 tks_self = $68ACF19B;
 tks_units = $D159E337;
 tks_ancestors = $A2B3C66E;
 tks_nestedvarref = $45678CDD;
 tks_defines = $8ACF19BB;
 tks_ini = $159E3376;
 tks_fini = $2B3C66ED;
 tks_incref = $5678CDDB;
 tks_decref = $ACF19BB7;
 tks_decrefindi = $59E3376E;
 tk_result = $B3C66EDD;
 tk_exitcode = $678CDDBA;
 tk_sizeof = $CF19BB75;
 tk_break = $9E3376EB;
 tk_continue = $3C66EDD6;
 tk_self = $78CDDBAD;
 tk_b = $F19BB75B;
 tk_booleval = $E3376EB7;
 tk_internaldebug = $C66EDD6E;
 tk_unit = $8CDDBADC;
 tk_program = $19BB75B9;
 tk_interface = $3376EB73;
 tk_implementation = $66EDD6E7;
 tk_uses = $CDDBADCE;
 tk_type = $9BB75B9C;
 tk_const = $376EB739;
 tk_var = $6EDD6E73;
 tk_label = $DDBADCE6;
 tk_procedure = $BB75B9CC;
 tk_function = $76EB7398;
 tk_end = $EDD6E730;
 tk_initialization = $DBADCE61;
 tk_finalization = $B75B9CC3;
 tk_constructor = $6EB73986;
 tk_destructor = $DD6E730C;
 tk_begin = $BADCE618;
 tk_dumpelements = $75B9CC31;
 tk_dumpopcode = $EB739862;
 tk_abort = $D6E730C4;
 tk_stoponerror = $ADCE6188;
 tk_nop = $5B9CC311;
 tk_include = $B7398622;
 tk_define = $6E730C44;
 tk_undef = $DCE61888;
 tk_ifdef = $B9CC3111;
 tk_ifndef = $73986223;
 tk_if = $E730C447;
 tk_else = $CE61888E;
 tk_endif = $9CC3111C;
 tk_ifend = $39862239;
 tk_h = $730C4472;
 tk_mode = $E61888E5;
 tk_inline = $CC3111CB;
 tk_on = $98622397;
 tk_off = $30C4472F;
 tk_default = $61888E5F;
 tk_out = $C3111CBE;
 tk_virtual = $8622397D;
 tk_override = $0C4472FA;
 tk_overload = $1888E5F4;
 tk_external = $3111CBE8;
 tk_forward = $622397D0;
 tk_finally = $C4472FA0;
 tk_except = $888E5F41;
 tk_do = $111CBE83;
 tk_with = $22397D07;
 tk_case = $4472FA0E;
 tk_while = $88E5F41C;
 tk_repeat = $11CBE839;
 tk_for = $2397D073;
 tk_try = $472FA0E7;
 tk_raise = $8E5F41CE;
 tk_goto = $1CBE839C;
 tk_then = $397D0738;
 tk_until = $72FA0E70;
 tk_to = $E5F41CE0;
 tk_downto = $CBE839C1;
 tk_of = $97D07383;
 tk_set = $2FA0E707;
 tk_record = $5F41CE0F;
 tk_array = $BE839C1E;
 tk_class = $7D07383D;
 tk_private = $FA0E707A;
 tk_protected = $F41CE0F5;
 tk_public = $E839C1EA;
 tk_published = $D07383D4;
 tk_property = $A0E707A9;
 tk_read = $41CE0F52;
 tk_write = $839C1EA5;
 tk_div = $07383D4B;
 tk_and = $0E707A96;
 tk_shl = $1CE0F52D;
 tk_shr = $39C1EA5A;
 tk_or = $7383D4B4;
 tk_xor = $E707A969;
 tk_in = $CE0F52D2;
 tk_not = $9C1EA5A4;
 tk_is = $383D4B49;
 tk_as = $707A9693;
 tk_inherited = $E0F52D27;

 tokens: array[0..108] of string = ('',
  '.classes','.private','.protected','.public','.published','.classintfname',
  '.classintftype','.classimp','.self','.units','.ancestors','.nestedvarref',
  '.defines','.ini','.fini','.incref','.decref','.decrefindi',
  'result','exitcode','sizeof','break','continue','self','b','booleval',
  'internaldebug','unit','program','interface','implementation','uses','type',
  'const','var','label','procedure','function','end','initialization',
  'finalization','constructor','destructor','begin','dumpelements','dumpopcode',
  'abort','stoponerror','nop','include','define','undef','ifdef','ifndef','if',
  'else','endif','ifend','h','mode','inline','on','off','default','out',
  'virtual','override','overload','external','forward','finally','except','do',
  'with','case','while','repeat','for','try','raise','goto','then','until','to',
  'downto','of','set','record','array','class','private','protected','public',
  'published','property','read','write','div','and','shl','shr','or','xor','in',
  'not','is','as','inherited');

 tokenids: array[0..108] of identty = (
  $00000000,$2468ACF1,$48D159E3,$91A2B3C6,$2345678C,$468ACF19,$8D159E33,
  $1A2B3C66,$345678CD,$68ACF19B,$D159E337,$A2B3C66E,$45678CDD,$8ACF19BB,
  $159E3376,$2B3C66ED,$5678CDDB,$ACF19BB7,$59E3376E,$B3C66EDD,$678CDDBA,
  $CF19BB75,$9E3376EB,$3C66EDD6,$78CDDBAD,$F19BB75B,$E3376EB7,$C66EDD6E,
  $8CDDBADC,$19BB75B9,$3376EB73,$66EDD6E7,$CDDBADCE,$9BB75B9C,$376EB739,
  $6EDD6E73,$DDBADCE6,$BB75B9CC,$76EB7398,$EDD6E730,$DBADCE61,$B75B9CC3,
  $6EB73986,$DD6E730C,$BADCE618,$75B9CC31,$EB739862,$D6E730C4,$ADCE6188,
  $5B9CC311,$B7398622,$6E730C44,$DCE61888,$B9CC3111,$73986223,$E730C447,
  $CE61888E,$9CC3111C,$39862239,$730C4472,$E61888E5,$CC3111CB,$98622397,
  $30C4472F,$61888E5F,$C3111CBE,$8622397D,$0C4472FA,$1888E5F4,$3111CBE8,
  $622397D0,$C4472FA0,$888E5F41,$111CBE83,$22397D07,$4472FA0E,$88E5F41C,
  $11CBE839,$2397D073,$472FA0E7,$8E5F41CE,$1CBE839C,$397D0738,$72FA0E70,
  $E5F41CE0,$CBE839C1,$97D07383,$2FA0E707,$5F41CE0F,$BE839C1E,$7D07383D,
  $FA0E707A,$F41CE0F5,$E839C1EA,$D07383D4,$A0E707A9,$41CE0F52,$839C1EA5,
  $07383D4B,$0E707A96,$1CE0F52D,$39C1EA5A,$7383D4B4,$E707A969,$CE0F52D2,
  $9C1EA5A4,$383D4B49,$707A9693,$E0F52D27);

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
 defineco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'define');
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
 ifndefco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifndef');
 ifcondco: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'ifcond');
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
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'paramdef1');
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
 subheader3co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'subheader3');
 subheader4co: contextty = (branch: nil; 
               handleentry: nil; handleexit: nil; 
               continue: false; restoresource: false; cutafter: false; 
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
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'whiledo0');
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
               continue: false; restoresource: false; cutafter: true; 
               pop: false; popexe: false; cutbefore: false; nexteat: false; next: nil;
               caption: 'forbody');
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
               continue: false; restoresource: false; cutafter: true; 
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
     keyword: $8CDDBADC{'unit'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @program0co); stack: nil; 
     keyword: $19BB75B9{'program'}),
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
     keyword: $3376EB73{'interface'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationco); stack: nil; 
     keyword: $66EDD6E7{'implementation'}),
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
 bstart1: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @uses0co); stack: @start2aco; 
     keyword: $CDDBADCE{'uses'}),
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
 bstart2: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationco); stack: nil; 
     keyword: $66EDD6E7{'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @typeco); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @constco); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @varco); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @labeldefco); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @subprocedureheaderco); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @subfunctionheaderco); stack: nil; 
     keyword: $76EB7398{'function'}),
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
     keyword: $EDD6E730{'end'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @initializationco); stack: nil; 
     keyword: $DBADCE61{'initialization'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @finalizationco); stack: nil; 
     keyword: $B75B9CC3{'finalization'}),
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
     keyword: $B75B9CC3{'finalization'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @implementationendco); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
     keyword: $EDD6E730{'end'}),
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
     keyword: $CDDBADCE{'uses'}),
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
 bmain1: array[0..14] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @typeco); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @constco); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @varco); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @labeldefco); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @procedureco); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @functionco); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @constructorco); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @destructorco); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @progbeginco); stack: nil; 
     keyword: $BADCE618{'begin'}),
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
 bdirective: array[0..20] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @dumpelementsco); stack: nil; 
     keyword: $75B9CC31{'dumpelements'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @dumpopcodeco); stack: nil; 
     keyword: $EB739862{'dumpopcode'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @abortco); stack: nil; 
     keyword: $D6E730C4{'abort'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @stoponerrorco); stack: nil; 
     keyword: $ADCE6188{'stoponerror'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @nopco); stack: nil; 
     keyword: $5B9CC311{'nop'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @includeco); stack: nil; 
     keyword: $B7398622{'include'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @defineco); stack: nil; 
     keyword: $6E730C44{'define'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @undefco); stack: nil; 
     keyword: $DCE61888{'undef'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @ifdefco); stack: nil; 
     keyword: $B9CC3111{'ifdef'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @ifndefco); stack: nil; 
     keyword: $73986223{'ifndef'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @ifcondco); stack: nil; 
     keyword: $E730C447{'if'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @elseifco); stack: nil; 
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @endifco); stack: nil; 
     keyword: $9CC3111C{'endif'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @endifco); stack: nil; 
     keyword: $39862239{'ifend'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: @ignoreddirectiveco); stack: nil; 
     keyword: $730C4472{'h'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: @ignoreddirectiveco); stack: nil; 
     keyword: $E61888E5{'mode'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: @ignoreddirectiveco); stack: nil; 
     keyword: $CC3111CB{'inline'}),
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
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bifndef: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @getidentco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bifcond: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @callexpco); stack: nil; keys: (
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
 bskipif1: array[0..4] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @skipifelseco); stack: nil; 
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @directiveendco); stack: nil; 
     keyword: $9CC3111C{'endif'}),
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
 bskipelse1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @directiveendco); stack: nil; 
     keyword: $9CC3111C{'endif'}),
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
     keyword: $98622397{'on'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_push];
     dest: (handler: @unsetlongcompilerswitch); stack: nil; 
     keyword: $30C4472F{'off'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_push];
     dest: (handler: @setdefaultcompilerswitch); stack: nil; 
     keyword: $61888E5F{'default'}),
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
 bparamdef0: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setconstparam); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setvarparam); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat,bf_continue];
     dest: (handler: @setoutparam); stack: nil; 
     keyword: $C3111CBE{'out'}),
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
 bparamdef1: array[0..6] of branchty = (
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
 bclasubheader3: array[0..10] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handlevirtual); stack: nil; 
     keyword: $8622397D{'virtual'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleoverride); stack: nil; 
     keyword: $0C4472FA{'override'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleoverload); stack: nil; 
     keyword: $1888E5F4{'overload'}),
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
     keyword: $8622397D{'virtual'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @overrideco); stack: nil; 
     keyword: $0C4472FA{'override'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @overloadco); stack: nil; 
     keyword: $1888E5F4{'overload'}),
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
 bsuba: array[0..1] of branchty = (
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
 bsubheader3: array[0..9] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleexternal); stack: nil; 
     keyword: $3111CBE8{'external'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleforward); stack: nil; 
     keyword: $622397D0{'forward'}),
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
     dest: (context: @subheader4co); stack: nil; keys: (
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
 bsubheader4: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @externalco); stack: nil; 
     keyword: $3111CBE8{'external'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forwardco); stack: nil; 
     keyword: $622397D0{'forward'}),
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
 bsubbody4: array[0..12] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @typeco); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @constco); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @varco); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @labeldefco); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @procedureco); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentbeforepush];
     dest: (context: @functionco); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @subbody5aco); stack: nil; 
     keyword: $BADCE618{'begin'}),
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
     keyword: $EDD6E730{'end'}),
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
     keyword: $C4472FA0{'finally'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @exceptco); stack: nil; 
     keyword: $888E5F41{'except'}),
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
     keyword: $EDD6E730{'end'}),
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
     keyword: $111CBE83{'do'}),
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
   (flags: [bf_nt,bf_emptytoken,bf_push];
     dest: (context: @statementco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
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
 bstatement1: array[0..7] of branchty = (
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
     dest: (context: @labelco); stack: nil; keys: (
    (kind: bkk_char; chars: [':']),
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
     keyword: $BADCE618{'begin'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $EDD6E730{ 'end'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $DBADCE61{'initialization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $B75B9CC3{'finalization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $C4472FA0{'finally'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $888E5F41{'except'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @withco); stack: nil; 
     keyword: $22397D07{'with'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @if0co); stack: nil; 
     keyword: $E730C447{'if'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @caseco); stack: nil; 
     keyword: $4472FA0E{'case'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @whileco); stack: nil; 
     keyword: $88E5F41C{'while'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @repeatco); stack: nil; 
     keyword: $11CBE839{'repeat'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @forco); stack: nil; 
     keyword: $2397D073{'for'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @tryco); stack: nil; 
     keyword: $472FA0E7{'try'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @raiseco); stack: nil; 
     keyword: $8E5F41CE{'raise'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @gotoco); stack: nil; 
     keyword: $1CBE839C{'goto'}),
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
     keyword: $EDD6E730{ 'end'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $DBADCE61{'initialization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $B75B9CC3{'finalization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $C4472FA0{'finally'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @blockendco); stack: nil; 
     keyword: $888E5F41{'except'}),
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
     keyword: $397D0738{'then'}),
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
 bthen0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementstackco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bthen2: array[0..6] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @else0co); stack: nil; 
     keyword: $CE61888E{'else'}),
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
     dest: (context: @statementstackco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
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
     keyword: $111CBE83{'do'}),
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
     dest: (context: @statementstackco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brepeat: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @repeatuntil0co); stack: nil; 
     keyword: $72FA0E70{'until'}),
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
     keyword: $E5F41CE0{'to'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @downtoco); stack: nil; 
     keyword: $CBE839C1{'downto'}),
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
     keyword: $111CBE83{'do'}),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bforbody: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @statementstackco); stack: nil; keys: (
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
     keyword: $97D07383{'of'}),
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
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @caseendco); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
     dest: (context: @statementstackco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bcasebranch3: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push];
     dest: (context: @caseelseco); stack: nil; 
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @caseendco); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
     keyword: $EDD6E730{'end'}),
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
     keyword: $97D07383{'of'}),
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
 brecorddef1: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @recorddefreturnco); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 brecordfield: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @vardefco); stack: nil; keys: (
    (kind: bkk_char; chars: [#0..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 barraydef: array[0..7] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @arraydef2co); stack: nil; 
     keyword: $97D07383{'of'}),
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
     keyword: $97D07383{'of'}),
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
   (flags: [bf_nt,bf_eat,bf_push];
     dest: (context: nil); stack: nil; keys: (
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
 bgettype: array[0..14] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @setdefco); stack: nil; 
     keyword: $2FA0E707{'set'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @recorddefco); stack: nil; 
     keyword: $5F41CE0F{'record'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @arraydefco); stack: nil; 
     keyword: $BE839C1E{'array'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @classdefco); stack: nil; 
     keyword: $7D07383D{'class'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush];
     dest: (context: @interfacedefco); stack: nil; 
     keyword: $3376EB73{'interface'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_changeparentcontext];
     dest: (context: @proceduretypedefco); stack: @typedefreturnco; 
     keyword: $BB75B9CC{'procedure'}),
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
 btype: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $66EDD6E7{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BADCE618{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
 blabeldef: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $66EDD6E7{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BADCE618{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
 bconst: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $66EDD6E7{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BADCE618{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
 bconst1: array[0..6] of branchty = (
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
 bvar: array[0..17] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $66EDD6E7{ 'implementation'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BADCE618{'begin'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
 bvardef: array[0..1] of branchty = (
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
 bclassdef: array[0..6] of branchty = (
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
     dest: (context: @classdefparamco); stack: nil; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: (context: nil); stack: nil; keyword: 0)
   );
 bclassdef0: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclassprivate); stack: nil; 
     keyword: $FA0E707A{'private'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclassprotected); stack: nil; 
     keyword: $F41CE0F5{'protected'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclasspublic); stack: nil; 
     keyword: $E839C1EA{'public'}),
   (flags: [bf_nt,bf_keyword,bf_handler,bf_eat];
     dest: (handler: @handleclasspublished); stack: nil; 
     keyword: $D07383D4{'published'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methprocedureheaderco); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methfunctionheaderco); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methconstructorheaderco); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methdestructorheaderco); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @classpropertyco); stack: nil; 
     keyword: $A0E707A9{'property'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @classdefreturnco); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
 bclassfield: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush];
     dest: (context: @vardefco); stack: nil; keys: (
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
     keyword: $376EB739{'const'}),
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
     keyword: $41CE0F52{'read'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @writepropco); stack: nil; 
     keyword: $839C1EA5{'write'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @defaultpropco); stack: nil; 
     keyword: $61888E5F{'default'}),
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
     keyword: $839C1EA5{'write'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_setparentbeforepush,bf_changeparentcontext];
     dest: (context: @expco); stack: @defaultpropco; 
     keyword: $61888E5F{'default'}),
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
     keyword: $61888E5F{'default'}),
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
 binterfacedef0: array[0..8] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methprocedureheaderco); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue,bf_setparentafterpush];
     dest: (context: @methfunctionheaderco); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword,bf_eat];
     dest: (context: @interfacedefreturnco); stack: nil; 
     keyword: $EDD6E730{'end'}),
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
 bexp1: array[0..23] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @insimpexpco); stack: nil; 
     keyword: $CE0F52D2{'in'}),
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
 baddterm1: array[0..11] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
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
 bsubterm1: array[0..11] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
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
 borterm1: array[0..11] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
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
 bxorterm1: array[0..11] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
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
 bxorsetterm1: array[0..11] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
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
 beqsimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
 bnesimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
 bgtsimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
 bltsimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
 bgesimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
 blesimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
 binsimpexp1: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @divfactco); stack: nil; 
     keyword: $07383D4B{'div'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @andfactco); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shlfactco); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @shrfactco); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @ortermco); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_eat,bf_push,bf_continue];
     dest: (context: @xortermco); stack: nil; 
     keyword: $E707A969{'xor'}),
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
     keyword: $9C1EA5A4{'not'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $0E707A96{'and'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $1CE0F52D{'shl'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $39C1EA5A{'shr'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $7383D4B4{'or'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $E707A969{'xor'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $CE0F52D2{'in'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $383D4B49{'is'}),
   (flags: [bf_nt,bf_keyword,bf_push];
     dest: (context: nil); stack: nil; 
     keyword: $707A9693{'as'}),
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
 bident: array[0..16] of branchty = (
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $66EDD6E7{'implementation'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $9BB75B9C{'type'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $376EB739{'const'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $6EDD6E73{'var'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $DDBADCE6{'label'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $BADCE618{'begin'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $BB75B9CC{'procedure'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $76EB7398{'function'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $6EB73986{'constructor'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $DD6E730C{'destructor'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $EDD6E730{'end'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $CE61888E{'else'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $DBADCE61{'initialization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $B75B9CC3{'finalization'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $C4472FA0{'finally'}),
   (flags: [bf_nt,bf_keyword];
     dest: (context: @reservedwordco); stack: nil; 
     keyword: $888E5F41{'except'}),
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
     keyword: $E0F52D27{'inherited'}),
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
 curlycomment0co.branch:= @bcurlycomment0;
 curlycomment0co.handleexit:= @handlecommentend;
 bracecomment0co.branch:= @bbracecomment0;
 bracecomment0co.handleexit:= @handlecommentend;
 directiveco.branch:= @bdirective;
 directiveco.next:= @directive1co;
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
 defineco.branch:= @bdefine;
 defineco.next:= @directiveendco;
 defineco.handleexit:= @handledefine;
 undefco.branch:= @bundef;
 undefco.next:= @directiveendco;
 undefco.handleexit:= @handleundef;
 ifdefco.branch:= @bifdef;
 ifdefco.next:= @directiveendco;
 ifdefco.handleexit:= @handleifdef;
 ifndefco.branch:= @bifndef;
 ifndefco.next:= @directiveendco;
 ifndefco.handleexit:= @handleifndef;
 ifcondco.branch:= @bifcond;
 ifcondco.next:= @directiveendco;
 ifcondco.handleentry:= @ifcondentry;
 ifcondco.handleexit:= @handleifcond;
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
 paramdef2co.branch:= @bparamdef2;
 paramdef2co.next:= @paramdef3co;
 paramdef3co.branch:= @bparamdef3;
 paramdef3co.handleexit:= @handleparamdef3;
 paramdef4co.branch:= @bparamdef4;
 paramdef4co.handleexit:= @handleparamdefault;
 subfunctionheaderco.branch:= nil;
 subfunctionheaderco.next:= @subheaderco;
 subfunctionheaderco.handleentry:= @handlefunctionentry;
 subprocedureheaderco.branch:= nil;
 subprocedureheaderco.next:= @subheaderco;
 subprocedureheaderco.handleentry:= @handleprocedureentry;
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
 clasubheaderco.branch:= @bclasubheader;
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
 subtypedefco.branch:= @bsubtypedef;
 subtypedef0co.branch:= nil;
 subtypedef0co.next:= @subheader1co;
 subtypedef0co.handleentry:= @handlesubtypedef0entry;
 subheaderco.branch:= @bsubheader;
 functionco.branch:= nil;
 functionco.next:= @subco;
 functionco.handleentry:= @handlefunctionentry;
 procedureco.branch:= nil;
 procedureco.next:= @subco;
 procedureco.handleentry:= @handleprocedureentry;
 constructorco.branch:= nil;
 constructorco.next:= @subco;
 constructorco.handleentry:= @handleconstructorentry;
 destructorco.branch:= nil;
 destructorco.next:= @subco;
 destructorco.handleentry:= @handledestructorentry;
 subco.branch:= @bsub;
 callsubheaderco.branch:= @bcallsubheader;
 callsubheaderco.next:= @subaco;
 callsubheaderco.handleentry:= @callsubheaderentry;
 subaco.branch:= @bsuba;
 subheader0co.branch:= @bsubheader0;
 subheader0co.next:= @subheader1co;
 subheader1co.branch:= @bsubheader1;
 subheader1co.next:= @subheader2co;
 subheader1co.handleentry:= @handlesub1entry;
 subheader2co.branch:= @bsubheader2;
 subheader2co.next:= @subheader3co;
 subheader3co.branch:= @bsubheader3;
 subheader4co.branch:= @bsubheader4;
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
 subbody4co.handleentry:= @subbody4entry;
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
 with3co.handleexit:= @handlewith3;
 endcontextco.branch:= nil;
 blockendco.branch:= nil;
 blockendco.handleexit:= @handleblockend;
 simplestatementco.branch:= @bsimplestatement;
 statement0co.branch:= @bstatement0;
 statement0co.next:= @statement1co;
 statement0co.handleentry:= @handlestatement0entry;
 statement1co.branch:= @bstatement1;
 statement1co.handleexit:= @handlestatementexit;
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
 then0co.branch:= @bthen0;
 then0co.next:= @then2co;
 then0co.handleentry:= @handlethen0;
 then2co.branch:= @bthen2;
 then2co.handleexit:= @handlethen2;
 else0co.branch:= nil;
 else0co.next:= @elseco;
 else0co.handleentry:= @handleelse0;
 elseco.branch:= @belse;
 elseco.handleexit:= @handleelse;
 whileco.branch:= @bwhile;
 whileco.next:= @whiledoco;
 whileco.handleentry:= @handlewhilestart;
 whiledoco.branch:= @bwhiledo;
 whiledoco.handleexit:= @handledoexpected;
 whiledo0co.branch:= @bwhiledo0;
 whiledo0co.handleentry:= @handlewhileexpression;
 whiledo0co.handleexit:= @handlewhileend;
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
 forbodyco.handleentry:= @handleforheader;
 forbodyco.handleexit:= @handleforend;
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
 mulfactco.branch:= @bmulfact;
 mulfactco.handleexit:= @handlemulfact;
 divfactco.branch:= @bdivfact;
 divfactco.handleexit:= @handledivfact;
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
 fact1co.handleexit:= @handlefact1;
 fact2co.branch:= @bfact2;
 fact2co.next:= @fact1co;
 fact2co.handleentry:= @handlefact2entry;
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

