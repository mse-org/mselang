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
 keywords: array[0..8] of string = (
  'procedure','begin','const','var','dumpelements','end','if','then','else');

var
 mainco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'main');
 main1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'main1');
 comment0co: contextty = (branch: nil; handle: nil; 
               continue: true; cut: true; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'comment0');
 directiveco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'directive');
 dumpelementsco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'dumpelements');
 directiveendco: contextty = (branch: nil; handle: nil; 
               continue: true; cut: true; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'directiveend');
 linecomment0co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: true; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'linecomment0');
 linecomment1co: contextty = (branch: nil; handle: nil; 
               continue: true; cut: true; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'linecomment1');
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
               continue: false; cut: true; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
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
               continue: true; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
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
               continue: true; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
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
 identpath1aco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath1a');
 identpath1co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
               caption: 'identpath1');
 identpath2aco: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: false; popexe: false; nexteat: false; next: nil;
               caption: 'identpath2a');
 identpath2co: contextty = (branch: nil; handle: nil; 
               continue: false; cut: false; restoresource: false; pop: true; popexe: false; nexteat: false; next: nil;
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
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @procedure0co; keys: (
    (kind: bkk_char; chars: ['''']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @procedure0co; 
     keyword: 2{'procedure'}),
   (flags: [bf_nt,bf_eat]; dest: @progbeginco; 
     keyword: 3{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @constco; 
     keyword: 4{'const'}),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @varco; 
     keyword: 5{'var'}),
   (flags: []; dest: nil; keyword: 0)
   );
 bcomment0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push]; dest: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken]; dest: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bdirective: array[0..3] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push]; dest: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken]; dest: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @dumpelementsco; 
     keyword: 6{'dumpelements'}),
   (flags: []; dest: nil; keyword: 0)
   );
 bdirectiveend: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat,bf_push]; dest: nil; keys: (
    (kind: bkk_char; chars: ['}']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken]; dest: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 blinecomment0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_eat]; dest: @linecomment1co; keys: (
    (kind: bkk_char; chars: [#10]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken]; dest: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bprogblock: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentafterpush]; dest: @statementblockco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparamsdef0: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @paramsdef1co; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparamsdef1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @paramdef0co; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparamsdef2: array[0..6] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @paramsdef1co; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @paramsdef3co; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparamdef0: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentafterpush]; dest: @identco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparamdef1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: @paramdef2co; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparamdef2: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentafterpush]; dest: @identco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bprocedure0: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentafterpush]; dest: @identco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bprocedure1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @paramsdef0co; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bprocedure2: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @procedure3co; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bprocedure4: array[0..7] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: @procedure5co; 
     keyword: 3{'begin'}),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @constco; 
     keyword: 4{'const'}),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @varco; 
     keyword: 5{'var'}),
   (flags: []; dest: nil; keyword: 0)
   );
 bprocedure5: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_eat,bf_push,bf_setparentafterpush]; dest: @statementblockco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bcheckterminator: array[0..5] of branchty = (
   (flags: [bf_nt,bf_eat]; dest: @terminatorokco; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bstatementstack: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @statementco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bstatement: array[0..9] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: @endcontextco; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_emptytoken]; dest: @simplestatementco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @statementblockco; 
     keyword: 3{'begin'}),
   (flags: [bf_nt]; dest: @endcontextco; 
     keyword: 7{'end'}),
   (flags: [bf_nt,bf_eat]; dest: @if0co; 
     keyword: 8{'if'}),
   (flags: []; dest: nil; keyword: 0)
   );
 bsimplestatement: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @statement0co; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bstatementblock: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @statementco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bstatementblock1: array[0..6] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @statementblockco; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @blockendco; 
     keyword: 7{'end'}),
   (flags: []; dest: nil; keyword: 0)
   );
 bstatement0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @identpathco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bstatement1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: @assignmentco; keys: (
    (kind: bkk_charcontinued; chars: [':']),
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bcheckproc: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @checkparamsco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bassignment: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @expco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bif0: array[0..4] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bif: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @expco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bthen: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @then0co; 
     keyword: 9{'then'}),
   (flags: []; dest: nil; keyword: 0)
   );
 bthen1: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setpc,bf_setparentafterpush]; dest: @statementstackco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bthen2: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @else0co; 
     keyword: 10{'else'}),
   (flags: []; dest: nil; keyword: 0)
   );
 belse: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setpc,bf_setparentafterpush]; dest: @statementstackco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bconst: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush]; dest: @const0co; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bconst0: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentafterpush]; dest: @identco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bconst1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @const2co; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bconst2: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @expco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bconst3: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @statementendco; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bvar: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentbeforepush]; dest: @var0co; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bvar0: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentafterpush]; dest: @identco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bvar1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @var2co; keys: (
    (kind: bkk_char; chars: [':']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bvar2: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push,bf_setparentafterpush]; dest: @identco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bvar3: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push]; dest: @statementendco; keys: (
    (kind: bkk_char; chars: [';']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @simpexpco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bexp1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @equsimpexpco; keys: (
    (kind: bkk_char; chars: ['=']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bequsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @simpexpco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bsimpexp: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @termco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bsimpexp1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @addtermco; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 baddterm: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @termco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bterm: array[0..9] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @negtermco; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @bracketstartco; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @numco; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @valueidentifierco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bterm1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @mulfactco; keys: (
    (kind: bkk_char; chars: ['*']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bmulfact: array[0..8] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @negtermco; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @bracketstartco; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @numco; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bnum0: array[0..2] of branchty = (
   (flags: [bf_nt,bf_push]; dest: @numco; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bnum: array[0..2] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @fracco; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bfrac: array[0..2] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @exponentco; keys: (
    (kind: bkk_char; chars: ['E','e']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bident: array[0..1] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bidentpath: array[0..1] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['0'..'9','A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bidentpath1: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @identpath2aco; keys: (
    (kind: bkk_char; chars: ['.']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bidentpath2: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @identpathco; keys: (
    (kind: bkk_char; chars: ['A'..'Z','_','a'..'z']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bvalueidentifier: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @identpathco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bcheckvalueparams: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @params0co; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bcheckparams: array[0..5] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @params0co; keys: (
    (kind: bkk_char; chars: ['(']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparams0: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push,bf_setparentafterpush]; dest: @expco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bparams1: array[0..6] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @params0co; keys: (
    (kind: bkk_char; chars: [',']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat]; dest: @paramsendco; keys: (
    (kind: bkk_char; chars: [')']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bbracketstart: array[0..1] of branchty = (
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: @simpexpco; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bbracketend: array[0..4] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: [#10,#13,' ']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @directiveco; keys: (
    (kind: bkk_charcontinued; chars: ['{']),
    (kind: bkk_char; chars: ['$']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @comment0co; keys: (
    (kind: bkk_char; chars: ['{']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_eat,bf_push,bf_setparentafterpush]; dest: @linecomment0co; keys: (
    (kind: bkk_charcontinued; chars: ['/']),
    (kind: bkk_char; chars: ['/']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bexponent: array[0..3] of branchty = (
   (flags: [bf_nt]; dest: nil; keys: (
    (kind: bkk_char; chars: ['+']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @negexponentco; keys: (
    (kind: bkk_char; chars: ['-']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: [bf_nt,bf_push]; dest: @numco; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
 bnegexponent: array[0..1] of branchty = (
   (flags: [bf_nt,bf_push]; dest: @numco; keys: (
    (kind: bkk_char; chars: ['0'..'9']),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )),
   (flags: []; dest: nil; keyword: 0)
   );
procedure init;
begin
 mainco.branch:= @bmain;
 mainco.next:= @main1co;
 mainco.handle:= @handlemain;
 main1co.branch:= nil;
 main1co.next:= @mainco;
 main1co.handle:= @handlemain1;
 comment0co.branch:= @bcomment0;
 comment0co.handle:= @handlecommentend;
 directiveco.branch:= @bdirective;
 dumpelementsco.branch:= nil;
 dumpelementsco.next:= @directiveendco;
 dumpelementsco.handle:= @handledumpelements;
 directiveendco.branch:= @bdirectiveend;
 linecomment0co.branch:= @blinecomment0;
 linecomment1co.branch:= nil;
 linecomment1co.handle:= @handlecommentend;
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
 identpathco.next:= @identpath1aco;
 identpath1aco.branch:= nil;
 identpath1aco.next:= @identpath1co;
 identpath1aco.handle:= @handleidentpath1a;
 identpath1co.branch:= @bidentpath1;
 identpath2aco.branch:= nil;
 identpath2aco.next:= @identpath2co;
 identpath2aco.handle:= @handleidentpath2a;
 identpath2co.branch:= @bidentpath2;
 identpath2co.handle:= @handleidentpath2;
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

