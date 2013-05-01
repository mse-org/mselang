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

implementation

uses
 msehandler;
 
var
 mainco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'main');
 constco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'const');
 const0co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'const0');
 const1co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'const1');
 const2co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'const2');
 const3co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'const3');
 statementendco: contextty = (branch: nil; handle: nil; pop: true; popexe: true; next: nil;
               caption: 'statementend');
 expco: contextty = (branch: nil; handle: nil; pop: true; popexe: false; next: nil;
               caption: 'exp');
 exp1co: contextty = (branch: nil; handle: nil; pop: true; popexe: false; next: nil;
               caption: 'exp1');
 equsimpexpco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'equsimpexp');
 simpexpco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'simpexp1');
 addtermco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'addterm');
 termco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'term');
 term1co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'term1');
 negtermco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'negterm');
 mulfactco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'mulfact');
 num0co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'frac');
 identco: contextty = (branch: nil; handle: nil; pop: true; popexe: false; next: nil;
               caption: 'ident');
 identpathco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'identpath');
 identpath1co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'identpath1');
 identpath2co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'identpath2');
 valueidentifierco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'valueidentifier');
 checkparamsco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'checkparams');
 paramsstart0co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'paramsstart0');
 paramsstartco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'paramsstart');
 paramsendco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'paramsend');
 paramsco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'params');
 params1co: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'params1');
 bracketstartco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'bracketend');
 lnco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'ln');
 exponentco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'exponent');
 negexponentco: contextty = (branch: nil; handle: nil; pop: false; popexe: false; next: nil;
               caption: 'negexponent');

const
 bmain: array[0..5] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'begin'; c:@expco; e:true; p:true; sb:false; sa:false),
  (t:'const'; c:@constco; e:true; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst: array[0..1] of branchty = (
  (t:''; c:@const0co; e:false; p:true; sb:false; sa:true),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst0: array[0..56] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'_'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'a'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'b'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'c'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'d'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'e'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'f'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'g'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'h'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'i'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'j'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'k'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'l'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'m'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'n'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'o'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'p'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'q'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'r'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'s'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'t'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'u'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'v'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'w'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'x'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'y'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'z'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'A'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'B'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'C'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'D'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'E'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'F'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'G'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'H'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'I'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'J'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'K'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'L'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'M'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'N'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'O'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'P'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'R'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'S'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'T'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'U'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'V'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'W'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'X'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; c:@identco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst1: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'='; c:@const2co; e:false; p:false; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst2: array[0..1] of branchty = (
  (t:''; c:@expco; e:false; p:true; sb:true; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bconst3: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:';'; c:@statementendco; e:true; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexp: array[0..1] of branchty = (
  (t:''; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexp1: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'='; c:@equsimpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bequsimpexp: array[0..1] of branchty = (
  (t:''; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bsimpexp: array[0..1] of branchty = (
  (t:''; c:@termco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bsimpexp1: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'+'; c:@addtermco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 baddterm: array[0..1] of branchty = (
  (t:''; c:@termco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bterm: array[0..69] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'+'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'-'; c:@negtermco; e:false; p:true; sb:false; sa:false),
  (t:'('; c:@bracketstartco; e:false; p:true; sb:false; sa:false),
  (t:'0'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'_'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'a'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'b'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'c'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'d'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'e'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'f'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'g'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'h'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'i'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'j'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'k'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'l'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'m'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'n'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'o'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'p'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'q'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'r'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'s'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'t'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'u'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'v'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'w'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'x'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'y'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'z'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'A'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'B'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'C'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'D'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'E'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'F'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'G'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'H'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'I'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'J'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'K'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'L'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'M'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'N'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'O'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'P'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'R'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'S'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'T'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'U'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'V'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'W'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'X'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; c:@valueidentifierco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bterm1: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'*'; c:@mulfactco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bmulfact: array[0..17] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'+'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'-'; c:@negtermco; e:false; p:true; sb:false; sa:false),
  (t:'('; c:@bracketstartco; e:false; p:true; sb:false; sa:false),
  (t:'0'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'ln'; c:@lnco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bnum0: array[0..11] of branchty = (
  (t:'0'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bnum: array[0..11] of branchty = (
  (t:'0'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'.'; c:@fracco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bfrac: array[0..12] of branchty = (
  (t:'0'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; c:@exponentco; e:false; p:true; sb:false; sa:false),
  (t:'E'; c:@exponentco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bident: array[0..63] of branchty = (
  (t:'_'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'a'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'b'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'c'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'d'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'f'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'g'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'h'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'i'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'j'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'k'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'l'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'m'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'n'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'o'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'p'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'q'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'r'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'s'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'t'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'u'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'v'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'w'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'x'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'y'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'z'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'A'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'B'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'C'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'D'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'E'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'F'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'G'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'H'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'I'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'J'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'K'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'L'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'M'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'N'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'O'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'P'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Q'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'R'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'S'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'T'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'U'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'V'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'W'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'X'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Y'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Z'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'0'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bidentpath: array[0..63] of branchty = (
  (t:'_'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'a'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'b'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'c'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'d'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'f'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'g'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'h'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'i'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'j'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'k'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'l'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'m'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'n'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'o'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'p'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'q'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'r'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'s'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'t'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'u'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'v'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'w'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'x'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'y'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'z'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'A'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'B'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'C'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'D'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'E'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'F'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'G'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'H'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'I'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'J'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'K'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'L'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'M'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'N'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'O'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'P'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Q'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'R'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'S'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'T'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'U'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'V'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'W'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'X'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Y'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Z'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'0'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bidentpath1: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'.'; c:@identpath2co; e:false; p:false; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bidentpath2: array[0..56] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'_'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'a'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'b'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'c'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'d'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'e'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'f'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'g'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'h'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'i'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'j'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'k'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'l'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'m'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'n'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'o'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'p'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'q'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'r'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'s'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'t'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'u'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'v'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'w'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'x'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'y'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'z'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'A'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'B'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'C'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'D'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'E'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'F'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'G'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'H'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'I'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'J'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'K'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'L'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'M'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'N'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'O'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'P'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'Q'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'R'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'S'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'T'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'U'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'V'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'W'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'X'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'Y'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:'Z'; c:@identpathco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bvalueidentifier: array[0..63] of branchty = (
  (t:'_'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'a'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'b'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'c'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'d'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'e'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'f'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'g'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'h'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'i'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'j'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'k'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'l'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'m'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'n'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'o'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'p'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'q'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'r'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'s'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'t'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'u'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'v'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'w'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'x'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'y'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'z'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'A'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'B'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'C'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'D'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'E'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'F'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'G'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'H'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'I'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'J'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'K'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'L'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'M'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'N'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'O'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'P'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Q'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'R'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'S'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'T'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'U'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'V'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'W'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'X'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Y'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'Z'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'0'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'1'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'2'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'3'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'4'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'5'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'6'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'7'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'8'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'9'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bcheckparams: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'('; c:@paramsstartco; e:false; p:true; sb:false; sa:true),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparamsstart: array[0..1] of branchty = (
  (t:''; c:@paramsco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparamsend: array[0..3] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparams: array[0..1] of branchty = (
  (t:''; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bparams1: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:','; c:@paramsco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bbracketstart: array[0..1] of branchty = (
  (t:''; c:@simpexpco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bbracketend: array[0..3] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bln: array[0..4] of branchty = (
  (t:' '; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0d; c:nil; e:false; p:false; sb:false; sa: false),
  (t:#$0a; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'('; c:@paramsstartco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bexponent: array[0..12] of branchty = (
  (t:'+'; c:nil; e:false; p:false; sb:false; sa: false),
  (t:'-'; c:@negexponentco; e:false; p:true; sb:false; sa:false),
  (t:'0'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

 bnegexponent: array[0..10] of branchty = (
  (t:'0'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'1'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'2'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'3'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'4'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'5'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'6'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'7'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'8'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:'9'; c:@numco; e:false; p:true; sb:false; sa:false),
  (t:''; c:nil; e:false; p:false; sb:false; sa: false)
 );

procedure init;
begin
 mainco.branch:= @bmain;
 mainco.handle:= @handlemain;
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
 valueidentifierco.handle:= @handleidentpath;
 checkparamsco.branch:= @bcheckparams;
 checkparamsco.handle:= @handlecheckparams;
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

