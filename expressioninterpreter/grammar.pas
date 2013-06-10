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
 keywords: array[0..7] of string = (
  'procedure','begin','const','var','end','if','then','else');

var
 mainco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'main');
 comment0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'comment0');
 comment1co: contextty = (branch: nil; handle: nil; 
               continue: true; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'comment1');
 linecomment0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'linecomment0');
 linecomment1co: contextty = (branch: nil; handle: nil; 
               continue: true; cut: true; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'linecomment1');
 main1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'main1');
 progbeginco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'progbegin');
 progblockco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'progblock');
 paramsdef0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramsdef0');
 paramsdef1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramsdef1');
 paramsdef2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramsdef2');
 paramsdef3co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'paramsdef3');
 paramdef0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramdef0');
 paramdef1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'paramdef1');
 paramdef2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'paramdef2');
 procedure0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure0');
 procedure1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure1');
 procedure2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure2');
 procedure3co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure3');
 procedure4co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure4');
 procedure5co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure5');
 procedure6co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'procedure6');
 checkterminatorco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'checkterminator');
 terminatorokco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'terminatorok');
 statementstackco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'statementstack');
 statementco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statement');
 endcontextco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'endcontext');
 blockendco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'blockend');
 simplestatementco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'simplestatement');
 statementblockco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statementblock');
 statementblock1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statementblock1');
 statement0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statement0');
 statement1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'statement1');
 checkprocco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'checkproc');
 assignmentco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'assignment');
 if0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'if0');
 ifco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'if');
 thenco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'then');
 then0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'then0');
 then1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'then1');
 then2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'then2');
 else0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'else0');
 elseco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'else');
 constco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const');
 const0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const0');
 const1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: true; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const1');
 const2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'const2');
 const3co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: true; next: nil;
               caption: 'const3');
 varco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var');
 var0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var0');
 var1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: true; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var1');
 var2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'var2');
 var3co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: true; next: nil;
               caption: 'var3');
 statementendco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: true; nexteat: false; next: nil;
               caption: 'statementend');
 expco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'exp');
 exp1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'exp1');
 equsimpexpco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'equsimpexp');
 simpexpco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'simpexp1');
 addtermco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'addterm');
 termco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'term');
 term1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'term1');
 negtermco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'negterm');
 mulfactco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'mulfact');
 num0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'frac');
 identco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'ident');
 identpathco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath');
 identpath1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath1');
 identpath2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath2');
 valueidentifierco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'valueidentifier');
 checkvalueparamsco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'checkvalueparams');
 checkparamsco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'checkparams');
 params0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'params0');
 params1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'params1');
 paramsendco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'paramsend');
 bracketstartco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'bracketend');
 exponentco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'exponent');
 negexponentco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'negexponent');

implementation

uses
 msehandler;
 
const
 bmain: array[0..9] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:#2{'procedure'}; x: false; k:true; c:@procedure0co; e:true; p:true; s: false; sb:false; sa:false),
  (t:#3{'begin'}; x: false; k:true; c:@progbeginco; e:true; p:false; s: false; sb:false; sa:false),
  (t:#4{'const'}; x: false; k:true; c:@constco; e:true; p:true; s: false; sb:false; sa:false),
  (t:#5{'var'}; x: false; k:true; c:@varco; e:true; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bcomment0: array[0..2] of branchty = (
  (t:'}'; x: false; k:false; c:@comment1co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 blinecomment0: array[0..2] of branchty = (
  (t:#$0a; x: false; k:false; c:@linecomment1co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bprogblock: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statementblockco; e:true; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparamsdef0: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'('; x: false; k:false; c:@paramsdef1co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparamsdef1: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@paramdef0co; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparamsdef2: array[0..7] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:';'; x: false; k:false; c:@paramsdef1co; e:true; p:false; s: false; sb:false; sa:false),
  (t:')'; x: false; k:false; c:@paramsdef3co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparamdef0: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'a'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'b'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'c'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'d'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'e'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'f'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'g'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'h'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'i'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'j'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'k'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'l'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'m'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'n'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'o'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'p'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'r'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'s'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'t'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'u'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'v'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'w'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'x'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'A'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'B'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'C'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'D'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'E'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'F'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'G'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'H'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'I'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'J'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'K'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'L'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'M'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'N'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'O'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'P'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'R'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'S'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'T'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'U'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'V'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'W'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'X'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparamdef1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:':'; x: false; k:false; c:@paramdef2co; e:false; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparamdef2: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'a'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'b'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'c'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'d'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'e'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'f'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'g'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'h'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'i'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'j'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'k'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'l'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'m'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'n'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'o'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'p'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'r'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'s'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'t'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'u'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'v'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'w'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'x'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'A'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'B'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'C'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'D'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'E'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'F'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'G'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'H'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'I'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'J'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'K'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'L'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'M'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'N'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'O'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'P'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'R'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'S'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'T'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'U'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'V'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'W'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'X'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bprocedure0: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'a'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'b'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'c'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'d'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'e'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'f'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'g'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'h'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'i'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'j'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'k'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'l'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'m'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'n'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'o'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'p'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'r'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'s'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'t'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'u'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'v'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'w'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'x'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'A'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'B'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'C'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'D'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'E'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'F'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'G'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'H'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'I'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'J'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'K'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'L'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'M'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'N'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'O'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'P'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'R'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'S'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'T'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'U'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'V'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'W'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'X'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bprocedure1: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@paramsdef0co; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bprocedure2: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:';'; x: false; k:false; c:@procedure3co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bprocedure4: array[0..8] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:#3; x: false; k:true; c:@procedure5co; e:false; p:false; s: false; sb:false; sa:false),
  (t:#4; x: false; k:true; c:@constco; e:true; p:true; s: false; sb:false; sa:false),
  (t:#5; x: false; k:true; c:@varco; e:true; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bprocedure5: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statementblockco; e:true; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bcheckterminator: array[0..6] of branchty = (
  (t:';'; x: false; k:false; c:@terminatorokco; e:true; p:false; s: false; sb:false; sa:false),
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bstatementstack: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statementco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bstatement: array[0..9] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:';'; x: false; k:false; c:@endcontextco; e:false; p:false; s: false; sb:false; sa:false),
  (t:#3; x: false; k:true; c:@statementblockco; e:true; p:true; s: false; sb:false; sa:false),
  (t:#6{'end'}; x: false; k:true; c:@endcontextco; e:false; p:false; s: false; sb:false; sa:false),
  (t:#7{'if'}; x: false; k:true; c:@if0co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bsimplestatement: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statement0co; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bstatementblock: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statementco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bstatementblock1: array[0..7] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:';'; x: false; k:false; c:@statementblockco; e:true; p:false; s: false; sb:false; sa:false),
  (t:#6; x: false; k:true; c:@blockendco; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bstatement0: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bstatement1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:':='; x: false; k:false; c:@assignmentco; e:false; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bcheckproc: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@checkparamsco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bassignment: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@expco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bif0: array[0..5] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bif: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@expco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bthen: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:#8{'then'}; x: false; k:true; c:@then0co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bthen1: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statementstackco; e:false; p:true; s: true; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bthen2: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:#9{'else'}; x: false; k:true; c:@else0co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 belse: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@statementstackco; e:false; p:true; s: true; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bconst: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@const0co; e:false; p:true; s: false; sb:false; sa:true),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bconst0: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'a'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'b'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'c'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'d'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'e'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'f'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'g'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'h'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'i'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'j'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'k'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'l'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'m'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'n'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'o'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'p'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'r'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'s'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'t'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'u'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'v'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'w'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'x'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'A'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'B'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'C'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'D'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'E'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'F'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'G'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'H'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'I'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'J'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'K'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'L'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'M'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'N'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'O'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'P'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'R'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'S'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'T'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'U'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'V'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'W'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'X'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bconst1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'='; x: false; k:false; c:@const2co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bconst2: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@expco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bconst3: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:';'; x: false; k:false; c:@statementendco; e:true; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bvar: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@var0co; e:false; p:true; s: false; sb:false; sa:true),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bvar0: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'a'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'b'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'c'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'d'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'e'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'f'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'g'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'h'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'i'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'j'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'k'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'l'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'m'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'n'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'o'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'p'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'r'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'s'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'t'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'u'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'v'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'w'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'x'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'A'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'B'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'C'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'D'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'E'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'F'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'G'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'H'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'I'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'J'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'K'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'L'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'M'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'N'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'O'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'P'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'R'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'S'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'T'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'U'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'V'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'W'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'X'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bvar1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:':'; x: false; k:false; c:@var2co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bvar2: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'a'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'b'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'c'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'d'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'e'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'f'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'g'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'h'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'i'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'j'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'k'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'l'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'m'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'n'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'o'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'p'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'r'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'s'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'t'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'u'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'v'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'w'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'x'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'A'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'B'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'C'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'D'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'E'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'F'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'G'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'H'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'I'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'J'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'K'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'L'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'M'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'N'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'O'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'P'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Q'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'R'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'S'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'T'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'U'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'V'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'W'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'X'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Y'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:'Z'; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bvar3: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:';'; x: false; k:false; c:@statementendco; e:true; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bexp: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@simpexpco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bexp1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'='; x: false; k:false; c:@equsimpexpco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bequsimpexp: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@simpexpco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bsimpexp: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@termco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bsimpexp1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'+'; x: false; k:false; c:@addtermco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 baddterm: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@termco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bterm: array[0..71] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'+'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'-'; x: false; k:false; c:@negtermco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'('; x: false; k:false; c:@bracketstartco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'0'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'1'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'2'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'3'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'4'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'5'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'6'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'7'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'8'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'9'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'_'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'a'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'b'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'c'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'d'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'e'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'f'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'g'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'h'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'i'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'j'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'k'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'l'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'m'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'n'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'o'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'p'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'q'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'r'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'s'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'t'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'u'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'v'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'w'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'x'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'y'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'z'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'A'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'B'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'C'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'D'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'E'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'F'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'G'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'H'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'I'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'J'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'K'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'L'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'M'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'N'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'O'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'P'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'Q'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'R'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'S'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'T'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'U'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'V'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'W'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'X'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'Y'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'Z'; x: false; k:false; c:@valueidentifierco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bterm1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'*'; x: false; k:false; c:@mulfactco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bmulfact: array[0..18] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'+'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'-'; x: false; k:false; c:@negtermco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'('; x: false; k:false; c:@bracketstartco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'0'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'1'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'2'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'3'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'4'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'5'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'6'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'7'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'8'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'9'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bnum0: array[0..11] of branchty = (
  (t:'0'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'1'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'2'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'3'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'4'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'5'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'6'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'7'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'8'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'9'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bnum: array[0..11] of branchty = (
  (t:'0'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'1'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'2'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'3'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'4'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'5'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'6'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'7'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'8'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'9'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'.'; x: false; k:false; c:@fracco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bfrac: array[0..12] of branchty = (
  (t:'0'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'1'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'2'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'3'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'4'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'5'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'6'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'7'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'8'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'9'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'e'; x: false; k:false; c:@exponentco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'E'; x: false; k:false; c:@exponentco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bident: array[0..63] of branchty = (
  (t:'_'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'a'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'b'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'c'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'d'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'e'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'f'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'g'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'h'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'i'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'j'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'k'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'l'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'m'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'n'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'o'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'p'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'q'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'r'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'s'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'t'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'u'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'v'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'w'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'x'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'y'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'z'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'A'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'B'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'C'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'D'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'E'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'F'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'G'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'H'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'I'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'J'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'K'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'L'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'M'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'N'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'O'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'P'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'Q'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'R'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'S'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'T'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'U'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'V'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'W'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'X'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'Y'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'Z'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'0'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'1'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'2'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'3'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'4'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'5'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'6'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'7'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'8'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'9'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bidentpath: array[0..63] of branchty = (
  (t:'_'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'a'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'b'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'c'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'d'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'e'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'f'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'g'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'h'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'i'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'j'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'k'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'l'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'m'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'n'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'o'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'p'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'q'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'r'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'s'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'t'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'u'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'v'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'w'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'x'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'y'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'z'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'A'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'B'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'C'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'D'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'E'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'F'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'G'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'H'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'I'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'J'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'K'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'L'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'M'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'N'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'O'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'P'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'Q'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'R'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'S'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'T'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'U'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'V'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'W'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'X'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'Y'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'Z'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'0'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'1'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'2'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'3'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'4'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'5'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'6'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'7'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'8'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'9'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bidentpath1: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'.'; x: false; k:false; c:@identpath2co; e:false; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bidentpath2: array[0..58] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'_'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'a'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'b'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'c'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'d'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'e'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'f'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'g'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'h'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'i'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'j'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'k'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'l'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'m'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'n'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'o'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'p'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'q'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'r'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'s'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'t'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'u'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'v'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'w'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'x'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'y'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'z'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'A'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'B'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'C'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'D'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'E'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'F'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'G'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'H'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'I'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'J'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'K'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'L'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'M'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'N'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'O'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'P'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'Q'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'R'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'S'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'T'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'U'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'V'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'W'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'X'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'Y'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'Z'; x: false; k:false; c:@identpathco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bvalueidentifier: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@identco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bcheckvalueparams: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'('; x: false; k:false; c:@params0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bcheckparams: array[0..6] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'('; x: false; k:false; c:@params0co; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparams0: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@expco; e:false; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bparams1: array[0..7] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:','; x: false; k:false; c:@params0co; e:true; p:false; s: false; sb:false; sa:false),
  (t:')'; x: false; k:false; c:@paramsendco; e:true; p:false; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bbracketstart: array[0..1] of branchty = (
  (t:''; x: false; k:false; c:@simpexpco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bbracketend: array[0..5] of branchty = (
  (t:' '; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0d; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:#$0a; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'{'; x: false; k:false; c:@comment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:'//'; x: false; k:false; c:@linecomment0co; e:true; p:true; s: false; sb:true; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bexponent: array[0..12] of branchty = (
  (t:'+'; x: false; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false),
  (t:'-'; x: false; k:false; c:@negexponentco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'0'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'1'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'2'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'3'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'4'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'5'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'6'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'7'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'8'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'9'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

 bnegexponent: array[0..10] of branchty = (
  (t:'0'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'1'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'2'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'3'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'4'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'5'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'6'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'7'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'8'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:'9'; x: false; k:false; c:@numco; e:false; p:true; s: false; sb:false; sa:false),
  (t:''; x:true; k:false; c:nil; e:false; p:false; s: false; sb:false; sa: false)
 );

procedure init;
begin
 mainco.branch:= @bmain;
 mainco.next:= @main1co;
 mainco.handle:= @handlemain;
 comment0co.branch:= @bcomment0;
 comment1co.branch:= nil;
 comment1co.handle:= @handlecommentend;
 linecomment0co.branch:= @blinecomment0;
 linecomment1co.branch:= nil;
 linecomment1co.handle:= @handlecommentend;
 main1co.branch:= nil;
 main1co.next:= @mainco;
 main1co.handle:= @handlemain1;
 progbeginco.branch:= nil;
 progbeginco.next:= @progblockco;
 progbeginco.handle:= @handleprogbegin;
 progblockco.branch:= @bprogblock;
 paramsdef0co.branch:= @bparamsdef0;
 paramsdef1co.branch:= @bparamsdef1;
 paramsdef1co.next:= @paramsdef2co;
 paramsdef2co.branch:= @bparamsdef2;
 paramsdef3co.branch:= nil;
 paramdef0co.branch:= @bparamdef0;
 paramdef0co.next:= @paramdef1co;
 paramdef1co.branch:= @bparamdef1;
 paramdef2co.branch:= @bparamdef2;
 procedure0co.branch:= @bprocedure0;
 procedure0co.next:= @procedure1co;
 procedure1co.branch:= @bprocedure1;
 procedure1co.next:= @procedure2co;
 procedure2co.branch:= @bprocedure2;
 procedure3co.branch:= nil;
 procedure3co.next:= @procedure4co;
 procedure3co.handle:= @handleprocedure3;
 procedure4co.branch:= @bprocedure4;
 procedure4co.next:= @checkterminatorco;
 procedure5co.branch:= @bprocedure5;
 procedure5co.next:= @procedure6co;
 procedure6co.branch:= nil;
 procedure6co.next:= @checkterminatorco;
 procedure6co.handle:= @handleprocedure6;
 checkterminatorco.branch:= @bcheckterminator;
 checkterminatorco.handle:= @handlecheckterminator;
 terminatorokco.branch:= nil;
 statementstackco.branch:= @bstatementstack;
 statementco.branch:= @bstatement;
 statementco.next:= @simplestatementco;
 statementco.handle:= @handlestatement;
 endcontextco.branch:= nil;
 blockendco.branch:= nil;
 blockendco.handle:= @handleblockend;
 simplestatementco.branch:= @bsimplestatement;
 statementblockco.branch:= @bstatementblock;
 statementblockco.next:= @statementblock1co;
 statementblock1co.branch:= @bstatementblock1;
 statementblock1co.handle:= @handlestatementblock1;
 statement0co.branch:= @bstatement0;
 statement0co.next:= @statement1co;
 statement1co.branch:= @bstatement1;
 statement1co.next:= @checkprocco;
 checkprocco.branch:= @bcheckproc;
 checkprocco.handle:= @handlecheckproc;
 assignmentco.branch:= @bassignment;
 assignmentco.handle:= @handleassignment;
 if0co.branch:= @bif0;
 if0co.next:= @ifco;
 ifco.branch:= @bif;
 ifco.next:= @thenco;
 ifco.handle:= @handleif;
 thenco.branch:= @bthen;
 thenco.handle:= @handlethen;
 then0co.branch:= nil;
 then0co.next:= @then1co;
 then0co.handle:= @handlethen0;
 then1co.branch:= @bthen1;
 then1co.next:= @then2co;
 then1co.handle:= @handlethen1;
 then2co.branch:= @bthen2;
 then2co.handle:= @handlethen2;
 else0co.branch:= nil;
 else0co.next:= @elseco;
 else0co.handle:= @handleelse0;
 elseco.branch:= @belse;
 elseco.handle:= @handleelse;
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
 valueidentifierco.next:= @checkvalueparamsco;
 valueidentifierco.handle:= @handlevalueidentifier;
 checkvalueparamsco.branch:= @bcheckvalueparams;
 checkvalueparamsco.handle:= @handlevalueidentifier;
 checkparamsco.branch:= @bcheckparams;
 params0co.branch:= @bparams0;
 params0co.next:= @params1co;
 params1co.branch:= @bparams1;
 paramsendco.branch:= nil;
 bracketstartco.branch:= @bbracketstart;
 bracketstartco.next:= @bracketendco;
 bracketstartco.handle:= @dummyhandler;
 bracketendco.branch:= @bbracketend;
 bracketendco.handle:= @handlebracketend;
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

