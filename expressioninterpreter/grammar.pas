{ MSEide Copyright (c) 2013 by Martin Schreiber
   
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
 mseparserglob;
 
function startcontext: pcontextty;

const
 identchars: array[char] of boolean = (
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  true,true,true,true,true,true,true,true,
  true,true,false,false,false,false,false,false,
  false,true,true,true,true,true,true,true,
  true,true,true,true,true,true,true,true,
  true,true,true,true,true,true,true,true,
  true,true,true,false,false,false,false,true,
  false,true,true,true,true,true,true,true,
  true,true,true,true,true,true,true,true,
  true,true,true,true,true,true,true,true,
  true,true,true,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false,
  false,false,false,false,false,false,false,false);

var
 mainco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'main');
 exeblockco: contextty = (branch: nil; handle: nil; 
               cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'exeblock');
 statement0co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statement0');
 statement1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statement1');
 assignmentco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'assignment');
 ifco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'if');
 thenco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'then');
 constco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const');
 const0co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const0');
 const1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: true; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const1');
 const2co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const2');
 const3co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: true; next: nil;
               caption: 'const3');
 varco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var');
 var0co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var0');
 var1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: true; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var1');
 var2co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var2');
 var3co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: true; next: nil;
               caption: 'var3');
 statementendco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: true; popexe: true; nexteat: false; next: nil;
               caption: 'statementend');
 expco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'exp');
 exp1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'exp1');
 equsimpexpco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'equsimpexp');
 simpexpco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'simpexp1');
 addtermco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'addterm');
 termco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'term');
 term1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'term1');
 negtermco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'negterm');
 mulfactco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'mulfact');
 num0co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'frac');
 identco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'ident');
 identpathco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath');
 identpath1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath1');
 identpath2co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath2');
 valueidentifierco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'valueidentifier');
 checkparamsco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'checkparams');
 paramsstart0co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramsstart0');
 paramsstartco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramsstart');
 paramsendco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramsend');
 paramsco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'params');
 params1co: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'params1');
 bracketstartco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'bracketend');
 lnco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'ln');
 exponentco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'exponent');
 negexponentco: contextty = (branch: nil; handle: nil; 
               cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'negexponent');

implementation

uses
 msehandler;
 
const
 bmain: array[0..6] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'begin'; k:true; c:@exeblockco; e:true; p:true; sb:false; sa:false),
  (t:'const'; k:true; c:@constco; e:true; p:true; sb:false; sa:false),
  (t:'var'; k:true; c:@varco; e:true; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexeblock: array[0..59] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:';'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'end'; k:true; c:nil; e:false; p:true; sb:false; sa:false),
  (t:'if'; k:true; c:@ifco; e:false; p:true; sb:false; sa:false),
  (t:'_'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'a'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'b'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'c'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'d'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'e'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'f'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'g'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'h'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'i'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'j'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'k'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'l'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'m'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'n'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'o'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'p'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'q'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'r'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'s'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'t'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'u'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'v'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'w'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'x'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'y'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'z'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'A'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'B'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'C'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'D'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'F'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'G'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'H'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'I'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'J'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'K'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'L'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'M'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'N'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'O'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'P'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'Q'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'R'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'S'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'T'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'U'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'V'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'W'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'X'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'Y'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:'Z'; k:false; c:@statement0co; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bstatement0: array[0..1] of branchty = (
  (t:''; k:false; c:@identco; e:false; p:true; sb:true; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bstatement1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:':='; k:false; c:@assignmentco; e:false; p:false; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bassignment: array[0..1] of branchty = (
  (t:''; k:false; c:@expco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bif: array[0..1] of branchty = (
  (t:''; k:false; c:@expco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bthen: array[0..1] of branchty = (
  (t:''; k:false; c:@identco; e:false; p:true; sb:true; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst: array[0..1] of branchty = (
  (t:''; k:false; c:@const0co; e:false; p:true; sb:false; sa:true),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst0: array[0..56] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'_'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'a'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'b'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'c'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'d'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'e'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'f'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'g'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'h'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'i'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'j'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'k'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'l'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'m'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'n'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'o'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'p'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'q'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'r'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'s'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'t'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'u'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'v'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'w'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'x'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'y'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'z'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'A'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'B'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'C'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'D'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'F'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'G'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'H'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'I'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'J'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'K'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'L'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'M'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'N'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'O'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'P'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'R'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'S'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'T'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'U'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'V'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'W'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'X'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'='; k:false; c:@const2co; e:true; p:false; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst2: array[0..1] of branchty = (
  (t:''; k:false; c:@expco; e:false; p:true; sb:true; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst3: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:';'; k:false; c:@statementendco; e:true; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvar: array[0..1] of branchty = (
  (t:''; k:false; c:@var0co; e:false; p:true; sb:false; sa:true),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvar0: array[0..56] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'_'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'a'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'b'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'c'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'d'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'e'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'f'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'g'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'h'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'i'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'j'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'k'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'l'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'m'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'n'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'o'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'p'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'q'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'r'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'s'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'t'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'u'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'v'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'w'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'x'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'y'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'z'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'A'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'B'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'C'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'D'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'F'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'G'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'H'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'I'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'J'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'K'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'L'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'M'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'N'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'O'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'P'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'R'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'S'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'T'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'U'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'V'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'W'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'X'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvar1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:':'; k:false; c:@var2co; e:true; p:false; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvar2: array[0..56] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'_'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'a'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'b'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'c'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'d'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'e'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'f'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'g'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'h'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'i'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'j'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'k'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'l'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'m'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'n'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'o'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'p'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'q'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'r'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'s'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'t'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'u'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'v'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'w'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'x'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'y'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'z'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'A'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'B'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'C'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'D'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'F'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'G'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'H'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'I'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'J'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'K'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'L'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'M'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'N'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'O'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'P'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'R'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'S'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'T'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'U'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'V'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'W'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'X'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; k:false; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvar3: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:';'; k:false; c:@statementendco; e:true; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexp: array[0..1] of branchty = (
  (t:''; k:false; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexp1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'='; k:false; c:@equsimpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bequsimpexp: array[0..1] of branchty = (
  (t:''; k:false; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bsimpexp: array[0..1] of branchty = (
  (t:''; k:false; c:@termco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bsimpexp1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'+'; k:false; c:@addtermco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 baddterm: array[0..1] of branchty = (
  (t:''; k:false; c:@termco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bterm: array[0..69] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'+'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'-'; k:false; c:@negtermco; e:false; p:true; sb:false; sa:false),
  (t:'('; k:false; c:@bracketstartco; e:false; p:true; sb:false; sa:false),
  (t:'0'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'_'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'a'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'b'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'c'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'d'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'e'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'f'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'g'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'h'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'i'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'j'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'k'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'l'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'m'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'n'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'o'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'p'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'q'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'r'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'s'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'t'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'u'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'v'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'w'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'x'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'y'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'z'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'A'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'B'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'C'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'D'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'F'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'G'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'H'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'I'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'J'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'K'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'L'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'M'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'N'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'O'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'P'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'R'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'S'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'T'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'U'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'V'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'W'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'X'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; k:false; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bterm1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'*'; k:false; c:@mulfactco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bmulfact: array[0..17] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'+'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'-'; k:false; c:@negtermco; e:false; p:true; sb:false; sa:false),
  (t:'('; k:false; c:@bracketstartco; e:false; p:true; sb:false; sa:false),
  (t:'0'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'ln'; k:false; c:@lnco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bnum0: array[0..11] of branchty = (
  (t:'0'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bnum: array[0..11] of branchty = (
  (t:'0'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'.'; k:false; c:@fracco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bfrac: array[0..12] of branchty = (
  (t:'0'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; k:false; c:@exponentco; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@exponentco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bident: array[0..63] of branchty = (
  (t:'_'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'a'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'b'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'c'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'d'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'f'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'g'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'h'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'i'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'j'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'k'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'l'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'m'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'n'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'o'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'p'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'q'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'r'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'s'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'t'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'u'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'v'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'w'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'x'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'y'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'z'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'A'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'B'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'C'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'D'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'E'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'F'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'G'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'H'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'I'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'J'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'K'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'L'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'M'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'N'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'O'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'P'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Q'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'R'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'S'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'T'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'U'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'V'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'W'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'X'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Y'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Z'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'0'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bidentpath: array[0..63] of branchty = (
  (t:'_'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'a'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'b'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'c'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'d'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'f'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'g'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'h'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'i'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'j'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'k'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'l'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'m'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'n'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'o'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'p'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'q'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'r'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'s'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'t'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'u'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'v'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'w'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'x'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'y'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'z'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'A'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'B'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'C'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'D'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'E'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'F'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'G'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'H'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'I'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'J'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'K'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'L'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'M'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'N'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'O'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'P'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Q'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'R'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'S'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'T'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'U'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'V'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'W'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'X'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Y'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Z'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'0'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bidentpath1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'.'; k:false; c:@identpath2co; e:false; p:false; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bidentpath2: array[0..56] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'_'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'a'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'b'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'c'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'d'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'e'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'f'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'g'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'h'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'i'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'j'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'k'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'l'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'m'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'n'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'o'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'p'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'q'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'r'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'s'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'t'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'u'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'v'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'w'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'x'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'y'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'z'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'A'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'B'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'C'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'D'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'E'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'F'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'G'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'H'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'I'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'J'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'K'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'L'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'M'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'N'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'O'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'P'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'R'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'S'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'T'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'U'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'V'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'W'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'X'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; k:false; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvalueidentifier: array[0..1] of branchty = (
  (t:''; k:false; c:@identco; e:false; p:true; sb:true; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bcheckparams: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'('; k:false; c:@paramsstartco; e:false; p:true; sb:false; sa:true),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparamsstart: array[0..1] of branchty = (
  (t:''; k:false; c:@paramsco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparamsend: array[0..3] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparams: array[0..1] of branchty = (
  (t:''; k:false; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparams1: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:','; k:false; c:@paramsco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bbracketstart: array[0..1] of branchty = (
  (t:''; k:false; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bbracketend: array[0..3] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bln: array[0..4] of branchty = (
  (t:' '; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'('; k:false; c:@paramsstartco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexponent: array[0..12] of branchty = (
  (t:'+'; k:false; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'-'; k:false; c:@negexponentco; e:false; p:true; sb:false; sa:false),
  (t:'0'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bnegexponent: array[0..10] of branchty = (
  (t:'0'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; k:false; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:''; k:false; c:nil; e:false; p:false; sb:false; sa: false)
 );

procedure init;
begin
 mainco.branch:= @bmain;
 mainco.next:= @mainco;
 mainco.handle:= @handlemain;
 exeblockco.branch:= @bexeblock;
 exeblockco.next:= @exeblockco;
 statement0co.branch:= @bstatement0;
 statement0co.next:= @statement1co;
 statement1co.branch:= @bstatement1;
 statement1co.handle:= @handlestatement1;
 assignmentco.branch:= @bassignment;
 assignmentco.handle:= @handleassignment;
 ifco.branch:= @bif;
 ifco.next:= @thenco;
 thenco.branch:= @bthen;
 constco.branch:= @bconst;
 constco.handle:= @handleconst;
 const0co.branch:= @bconst0;
 const0co.next:= @const1co;
 const1co.branch:= @bconst1;
 const2co.branch:= @bconst2;
 const2co.next:= @const3co;
 const3co.branch:= @bconst3;
 const3co.next:= @const0co;
 const3co.handle:= @handleconst3;
 varco.branch:= @bvar;
 varco.handle:= @handlevar;
 var0co.branch:= @bvar0;
 var0co.next:= @var1co;
 var1co.branch:= @bvar1;
 var2co.branch:= @bvar2;
 var2co.next:= @var3co;
 var3co.branch:= @bvar3;
 var3co.next:= @var0co;
 var3co.handle:= @handlevar3;
 statementendco.branch:= nil;
 statementendco.handle:= @handlestatementend;
 expco.branch:= @bexp;
 expco.next:= @exp1co;
 expco.handle:= @handleexp;
 exp1co.branch:= @bexp1;
 exp1co.handle:= @handleexp;
 equsimpexpco.branch:= @bequsimpexp;
 equsimpexpco.handle:= @handleequsimpexp;
 simpexpco.branch:= @bsimpexp;
 simpexpco.next:= @simpexp1co;
 simpexpco.handle:= @handlesimpexp;
 simpexp1co.branch:= @bsimpexp1;
 simpexp1co.next:= @simpexp1co;
 simpexp1co.handle:= @handlesimpexp1;
 addtermco.branch:= @baddterm;
 addtermco.handle:= @handleaddterm;
 termco.branch:= @bterm;
 termco.next:= @term1co;
 termco.handle:= @handleterm;
 term1co.branch:= @bterm1;
 term1co.next:= @term1co;
 term1co.handle:= @handleterm1;
 negtermco.branch:= nil;
 negtermco.next:= @termco;
 negtermco.handle:= @handlenegterm;
 mulfactco.branch:= @bmulfact;
 mulfactco.handle:= @handlemulfact;
 num0co.branch:= @bnum0;
 num0co.handle:= @dummyhandler;
 numco.branch:= @bnum;
 numco.handle:= @handledecnum;
 fracco.branch:= @bfrac;
 fracco.handle:= @handlefrac;
 identco.branch:= @bident;
 identco.handle:= @handleident;
 identpathco.branch:= @bidentpath;
 identpathco.next:= @identpath1co;
 identpath1co.branch:= @bidentpath1;
 identpath2co.branch:= @bidentpath2;
 valueidentifierco.branch:= @bvalueidentifier;
 valueidentifierco.next:= @checkparamsco;
 valueidentifierco.handle:= @handlevalueidentifier;
 checkparamsco.branch:= @bcheckparams;
 checkparamsco.handle:= @handlevalueidentifier;
 paramsstart0co.branch:= nil;
 paramsstart0co.next:= @paramsstartco;
 paramsstart0co.handle:= @handleparamstart0;
 paramsstartco.branch:= @bparamsstart;
 paramsstartco.next:= @paramsendco;
 paramsstartco.handle:= @dummyhandler;
 paramsendco.branch:= @bparamsend;
 paramsendco.handle:= @handleparamsend;
 paramsco.branch:= @bparams;
 paramsco.next:= @params1co;
 paramsco.handle:= @handleparam;
 params1co.branch:= @bparams1;
 params1co.handle:= @handleparam;
 bracketstartco.branch:= @bbracketstart;
 bracketstartco.next:= @bracketendco;
 bracketstartco.handle:= @dummyhandler;
 bracketendco.branch:= @bbracketend;
 bracketendco.handle:= @handlebracketend;
 lnco.branch:= @bln;
 lnco.handle:= @handleln;
 exponentco.branch:= @bexponent;
 exponentco.handle:= @handleexponent;
 negexponentco.branch:= @bnegexponent;
 negexponentco.handle:= @handlenegexponent;
end;

function startcontext: pcontextty;
begin
 result:= @mainco;
end;

initialization
 init;
end.

