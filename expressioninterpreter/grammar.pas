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
 mainco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'main');
 constco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'const');
 const0co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'const0');
 const1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'const1');
 const2co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'const2');
 expco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'exp');
 exp1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'exp1');
 equsimpexpco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'equsimpexp');
 simpexpco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'simpexp1');
 addtermco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'addterm');
 termco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'term');
 term1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'term1');
 negtermco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'negterm');
 mulfactco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'mulfact');
 num0co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'frac');
 identifierco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'identifier');
 identifier1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'identifier1');
 identifier2co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'identifier2');
 valueidentifierco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'valueidentifier');
 checkparamsco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'checkparams');
 paramsstart0co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'paramsstart0');
 paramsstartco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'paramsstart');
 paramsendco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'paramsend');
 paramsco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'params');
 params1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'params1');
 bracketstartco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'bracketend');
 lnco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'ln');
 exponentco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'exponent');
 negexponentco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'negexponent');

const
 bmain: array[0..5] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'begin';c:@expco;e:true;p:true),
  (t:'const';c:@constco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bconst: array[0..1] of branchty = (
  (t:'';c:@const0co;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bconst0: array[0..56] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'_';c:@identifierco;e:false;p:true),
  (t:'a';c:@identifierco;e:false;p:true),
  (t:'b';c:@identifierco;e:false;p:true),
  (t:'c';c:@identifierco;e:false;p:true),
  (t:'d';c:@identifierco;e:false;p:true),
  (t:'e';c:@identifierco;e:false;p:true),
  (t:'f';c:@identifierco;e:false;p:true),
  (t:'g';c:@identifierco;e:false;p:true),
  (t:'h';c:@identifierco;e:false;p:true),
  (t:'i';c:@identifierco;e:false;p:true),
  (t:'j';c:@identifierco;e:false;p:true),
  (t:'k';c:@identifierco;e:false;p:true),
  (t:'l';c:@identifierco;e:false;p:true),
  (t:'m';c:@identifierco;e:false;p:true),
  (t:'n';c:@identifierco;e:false;p:true),
  (t:'o';c:@identifierco;e:false;p:true),
  (t:'p';c:@identifierco;e:false;p:true),
  (t:'q';c:@identifierco;e:false;p:true),
  (t:'r';c:@identifierco;e:false;p:true),
  (t:'s';c:@identifierco;e:false;p:true),
  (t:'t';c:@identifierco;e:false;p:true),
  (t:'u';c:@identifierco;e:false;p:true),
  (t:'v';c:@identifierco;e:false;p:true),
  (t:'w';c:@identifierco;e:false;p:true),
  (t:'x';c:@identifierco;e:false;p:true),
  (t:'y';c:@identifierco;e:false;p:true),
  (t:'z';c:@identifierco;e:false;p:true),
  (t:'A';c:@identifierco;e:false;p:true),
  (t:'B';c:@identifierco;e:false;p:true),
  (t:'C';c:@identifierco;e:false;p:true),
  (t:'D';c:@identifierco;e:false;p:true),
  (t:'E';c:@identifierco;e:false;p:true),
  (t:'F';c:@identifierco;e:false;p:true),
  (t:'G';c:@identifierco;e:false;p:true),
  (t:'H';c:@identifierco;e:false;p:true),
  (t:'I';c:@identifierco;e:false;p:true),
  (t:'J';c:@identifierco;e:false;p:true),
  (t:'K';c:@identifierco;e:false;p:true),
  (t:'L';c:@identifierco;e:false;p:true),
  (t:'M';c:@identifierco;e:false;p:true),
  (t:'N';c:@identifierco;e:false;p:true),
  (t:'O';c:@identifierco;e:false;p:true),
  (t:'P';c:@identifierco;e:false;p:true),
  (t:'Q';c:@identifierco;e:false;p:true),
  (t:'R';c:@identifierco;e:false;p:true),
  (t:'S';c:@identifierco;e:false;p:true),
  (t:'T';c:@identifierco;e:false;p:true),
  (t:'U';c:@identifierco;e:false;p:true),
  (t:'V';c:@identifierco;e:false;p:true),
  (t:'W';c:@identifierco;e:false;p:true),
  (t:'X';c:@identifierco;e:false;p:true),
  (t:'Y';c:@identifierco;e:false;p:true),
  (t:'Z';c:@identifierco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bconst1: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'=';c:@const2co;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bconst2: array[0..1] of branchty = (
  (t:'';c:@expco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bexp: array[0..1] of branchty = (
  (t:'';c:@simpexpco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bexp1: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'=';c:@equsimpexpco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bequsimpexp: array[0..1] of branchty = (
  (t:'';c:@simpexpco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bsimpexp: array[0..1] of branchty = (
  (t:'';c:@termco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bsimpexp1: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'+';c:@addtermco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 baddterm: array[0..1] of branchty = (
  (t:'';c:@termco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bterm: array[0..69] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'+';c:nil;e:false;p:false),
  (t:'-';c:@negtermco;e:false;p:true),
  (t:'(';c:@bracketstartco;e:false;p:true),
  (t:'0';c:@numco;e:false;p:true),
  (t:'1';c:@numco;e:false;p:true),
  (t:'2';c:@numco;e:false;p:true),
  (t:'3';c:@numco;e:false;p:true),
  (t:'4';c:@numco;e:false;p:true),
  (t:'5';c:@numco;e:false;p:true),
  (t:'6';c:@numco;e:false;p:true),
  (t:'7';c:@numco;e:false;p:true),
  (t:'8';c:@numco;e:false;p:true),
  (t:'9';c:@numco;e:false;p:true),
  (t:'_';c:@valueidentifierco;e:false;p:true),
  (t:'a';c:@valueidentifierco;e:false;p:true),
  (t:'b';c:@valueidentifierco;e:false;p:true),
  (t:'c';c:@valueidentifierco;e:false;p:true),
  (t:'d';c:@valueidentifierco;e:false;p:true),
  (t:'e';c:@valueidentifierco;e:false;p:true),
  (t:'f';c:@valueidentifierco;e:false;p:true),
  (t:'g';c:@valueidentifierco;e:false;p:true),
  (t:'h';c:@valueidentifierco;e:false;p:true),
  (t:'i';c:@valueidentifierco;e:false;p:true),
  (t:'j';c:@valueidentifierco;e:false;p:true),
  (t:'k';c:@valueidentifierco;e:false;p:true),
  (t:'l';c:@valueidentifierco;e:false;p:true),
  (t:'m';c:@valueidentifierco;e:false;p:true),
  (t:'n';c:@valueidentifierco;e:false;p:true),
  (t:'o';c:@valueidentifierco;e:false;p:true),
  (t:'p';c:@valueidentifierco;e:false;p:true),
  (t:'q';c:@valueidentifierco;e:false;p:true),
  (t:'r';c:@valueidentifierco;e:false;p:true),
  (t:'s';c:@valueidentifierco;e:false;p:true),
  (t:'t';c:@valueidentifierco;e:false;p:true),
  (t:'u';c:@valueidentifierco;e:false;p:true),
  (t:'v';c:@valueidentifierco;e:false;p:true),
  (t:'w';c:@valueidentifierco;e:false;p:true),
  (t:'x';c:@valueidentifierco;e:false;p:true),
  (t:'y';c:@valueidentifierco;e:false;p:true),
  (t:'z';c:@valueidentifierco;e:false;p:true),
  (t:'A';c:@valueidentifierco;e:false;p:true),
  (t:'B';c:@valueidentifierco;e:false;p:true),
  (t:'C';c:@valueidentifierco;e:false;p:true),
  (t:'D';c:@valueidentifierco;e:false;p:true),
  (t:'E';c:@valueidentifierco;e:false;p:true),
  (t:'F';c:@valueidentifierco;e:false;p:true),
  (t:'G';c:@valueidentifierco;e:false;p:true),
  (t:'H';c:@valueidentifierco;e:false;p:true),
  (t:'I';c:@valueidentifierco;e:false;p:true),
  (t:'J';c:@valueidentifierco;e:false;p:true),
  (t:'K';c:@valueidentifierco;e:false;p:true),
  (t:'L';c:@valueidentifierco;e:false;p:true),
  (t:'M';c:@valueidentifierco;e:false;p:true),
  (t:'N';c:@valueidentifierco;e:false;p:true),
  (t:'O';c:@valueidentifierco;e:false;p:true),
  (t:'P';c:@valueidentifierco;e:false;p:true),
  (t:'Q';c:@valueidentifierco;e:false;p:true),
  (t:'R';c:@valueidentifierco;e:false;p:true),
  (t:'S';c:@valueidentifierco;e:false;p:true),
  (t:'T';c:@valueidentifierco;e:false;p:true),
  (t:'U';c:@valueidentifierco;e:false;p:true),
  (t:'V';c:@valueidentifierco;e:false;p:true),
  (t:'W';c:@valueidentifierco;e:false;p:true),
  (t:'X';c:@valueidentifierco;e:false;p:true),
  (t:'Y';c:@valueidentifierco;e:false;p:true),
  (t:'Z';c:@valueidentifierco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bterm1: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'*';c:@mulfactco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bmulfact: array[0..17] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'+';c:nil;e:false;p:false),
  (t:'-';c:@negtermco;e:false;p:true),
  (t:'(';c:@bracketstartco;e:false;p:true),
  (t:'0';c:@numco;e:false;p:true),
  (t:'1';c:@numco;e:false;p:true),
  (t:'2';c:@numco;e:false;p:true),
  (t:'3';c:@numco;e:false;p:true),
  (t:'4';c:@numco;e:false;p:true),
  (t:'5';c:@numco;e:false;p:true),
  (t:'6';c:@numco;e:false;p:true),
  (t:'7';c:@numco;e:false;p:true),
  (t:'8';c:@numco;e:false;p:true),
  (t:'9';c:@numco;e:false;p:true),
  (t:'ln';c:@lnco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bnum0: array[0..11] of branchty = (
  (t:'0';c:@numco;e:false;p:true),
  (t:'1';c:@numco;e:false;p:true),
  (t:'2';c:@numco;e:false;p:true),
  (t:'3';c:@numco;e:false;p:true),
  (t:'4';c:@numco;e:false;p:true),
  (t:'5';c:@numco;e:false;p:true),
  (t:'6';c:@numco;e:false;p:true),
  (t:'7';c:@numco;e:false;p:true),
  (t:'8';c:@numco;e:false;p:true),
  (t:'9';c:@numco;e:false;p:true),
  (t:' ';c:nil;e:false;p:false),
  (t:'';c:nil;e:false;p:false)
 );

 bnum: array[0..11] of branchty = (
  (t:'0';c:nil;e:false;p:false),
  (t:'1';c:nil;e:false;p:false),
  (t:'2';c:nil;e:false;p:false),
  (t:'3';c:nil;e:false;p:false),
  (t:'4';c:nil;e:false;p:false),
  (t:'5';c:nil;e:false;p:false),
  (t:'6';c:nil;e:false;p:false),
  (t:'7';c:nil;e:false;p:false),
  (t:'8';c:nil;e:false;p:false),
  (t:'9';c:nil;e:false;p:false),
  (t:'.';c:@fracco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bfrac: array[0..12] of branchty = (
  (t:'0';c:nil;e:false;p:false),
  (t:'1';c:nil;e:false;p:false),
  (t:'2';c:nil;e:false;p:false),
  (t:'3';c:nil;e:false;p:false),
  (t:'4';c:nil;e:false;p:false),
  (t:'5';c:nil;e:false;p:false),
  (t:'6';c:nil;e:false;p:false),
  (t:'7';c:nil;e:false;p:false),
  (t:'8';c:nil;e:false;p:false),
  (t:'9';c:nil;e:false;p:false),
  (t:'e';c:@exponentco;e:false;p:true),
  (t:'E';c:@exponentco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bidentifier: array[0..63] of branchty = (
  (t:'_';c:nil;e:false;p:false),
  (t:'a';c:nil;e:false;p:false),
  (t:'b';c:nil;e:false;p:false),
  (t:'c';c:nil;e:false;p:false),
  (t:'d';c:nil;e:false;p:false),
  (t:'e';c:nil;e:false;p:false),
  (t:'f';c:nil;e:false;p:false),
  (t:'g';c:nil;e:false;p:false),
  (t:'h';c:nil;e:false;p:false),
  (t:'i';c:nil;e:false;p:false),
  (t:'j';c:nil;e:false;p:false),
  (t:'k';c:nil;e:false;p:false),
  (t:'l';c:nil;e:false;p:false),
  (t:'m';c:nil;e:false;p:false),
  (t:'n';c:nil;e:false;p:false),
  (t:'o';c:nil;e:false;p:false),
  (t:'p';c:nil;e:false;p:false),
  (t:'q';c:nil;e:false;p:false),
  (t:'r';c:nil;e:false;p:false),
  (t:'s';c:nil;e:false;p:false),
  (t:'t';c:nil;e:false;p:false),
  (t:'u';c:nil;e:false;p:false),
  (t:'v';c:nil;e:false;p:false),
  (t:'w';c:nil;e:false;p:false),
  (t:'x';c:nil;e:false;p:false),
  (t:'y';c:nil;e:false;p:false),
  (t:'z';c:nil;e:false;p:false),
  (t:'A';c:nil;e:false;p:false),
  (t:'B';c:nil;e:false;p:false),
  (t:'C';c:nil;e:false;p:false),
  (t:'D';c:nil;e:false;p:false),
  (t:'E';c:nil;e:false;p:false),
  (t:'F';c:nil;e:false;p:false),
  (t:'G';c:nil;e:false;p:false),
  (t:'H';c:nil;e:false;p:false),
  (t:'I';c:nil;e:false;p:false),
  (t:'J';c:nil;e:false;p:false),
  (t:'K';c:nil;e:false;p:false),
  (t:'L';c:nil;e:false;p:false),
  (t:'M';c:nil;e:false;p:false),
  (t:'N';c:nil;e:false;p:false),
  (t:'O';c:nil;e:false;p:false),
  (t:'P';c:nil;e:false;p:false),
  (t:'Q';c:nil;e:false;p:false),
  (t:'R';c:nil;e:false;p:false),
  (t:'S';c:nil;e:false;p:false),
  (t:'T';c:nil;e:false;p:false),
  (t:'U';c:nil;e:false;p:false),
  (t:'V';c:nil;e:false;p:false),
  (t:'W';c:nil;e:false;p:false),
  (t:'X';c:nil;e:false;p:false),
  (t:'Y';c:nil;e:false;p:false),
  (t:'Z';c:nil;e:false;p:false),
  (t:'0';c:nil;e:false;p:false),
  (t:'1';c:nil;e:false;p:false),
  (t:'2';c:nil;e:false;p:false),
  (t:'3';c:nil;e:false;p:false),
  (t:'4';c:nil;e:false;p:false),
  (t:'5';c:nil;e:false;p:false),
  (t:'6';c:nil;e:false;p:false),
  (t:'7';c:nil;e:false;p:false),
  (t:'8';c:nil;e:false;p:false),
  (t:'9';c:nil;e:false;p:false),
  (t:'';c:nil;e:false;p:false)
 );

 bidentifier1: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'.';c:@identifier2co;e:false;p:false),
  (t:'';c:nil;e:false;p:false)
 );

 bidentifier2: array[0..56] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'_';c:@identifierco;e:false;p:true),
  (t:'a';c:@identifierco;e:false;p:true),
  (t:'b';c:@identifierco;e:false;p:true),
  (t:'c';c:@identifierco;e:false;p:true),
  (t:'d';c:@identifierco;e:false;p:true),
  (t:'e';c:@identifierco;e:false;p:true),
  (t:'f';c:@identifierco;e:false;p:true),
  (t:'g';c:@identifierco;e:false;p:true),
  (t:'h';c:@identifierco;e:false;p:true),
  (t:'i';c:@identifierco;e:false;p:true),
  (t:'j';c:@identifierco;e:false;p:true),
  (t:'k';c:@identifierco;e:false;p:true),
  (t:'l';c:@identifierco;e:false;p:true),
  (t:'m';c:@identifierco;e:false;p:true),
  (t:'n';c:@identifierco;e:false;p:true),
  (t:'o';c:@identifierco;e:false;p:true),
  (t:'p';c:@identifierco;e:false;p:true),
  (t:'q';c:@identifierco;e:false;p:true),
  (t:'r';c:@identifierco;e:false;p:true),
  (t:'s';c:@identifierco;e:false;p:true),
  (t:'t';c:@identifierco;e:false;p:true),
  (t:'u';c:@identifierco;e:false;p:true),
  (t:'v';c:@identifierco;e:false;p:true),
  (t:'w';c:@identifierco;e:false;p:true),
  (t:'x';c:@identifierco;e:false;p:true),
  (t:'y';c:@identifierco;e:false;p:true),
  (t:'z';c:@identifierco;e:false;p:true),
  (t:'A';c:@identifierco;e:false;p:true),
  (t:'B';c:@identifierco;e:false;p:true),
  (t:'C';c:@identifierco;e:false;p:true),
  (t:'D';c:@identifierco;e:false;p:true),
  (t:'E';c:@identifierco;e:false;p:true),
  (t:'F';c:@identifierco;e:false;p:true),
  (t:'G';c:@identifierco;e:false;p:true),
  (t:'H';c:@identifierco;e:false;p:true),
  (t:'I';c:@identifierco;e:false;p:true),
  (t:'J';c:@identifierco;e:false;p:true),
  (t:'K';c:@identifierco;e:false;p:true),
  (t:'L';c:@identifierco;e:false;p:true),
  (t:'M';c:@identifierco;e:false;p:true),
  (t:'N';c:@identifierco;e:false;p:true),
  (t:'O';c:@identifierco;e:false;p:true),
  (t:'P';c:@identifierco;e:false;p:true),
  (t:'Q';c:@identifierco;e:false;p:true),
  (t:'R';c:@identifierco;e:false;p:true),
  (t:'S';c:@identifierco;e:false;p:true),
  (t:'T';c:@identifierco;e:false;p:true),
  (t:'U';c:@identifierco;e:false;p:true),
  (t:'V';c:@identifierco;e:false;p:true),
  (t:'W';c:@identifierco;e:false;p:true),
  (t:'X';c:@identifierco;e:false;p:true),
  (t:'Y';c:@identifierco;e:false;p:true),
  (t:'Z';c:@identifierco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bvalueidentifier: array[0..63] of branchty = (
  (t:'_';c:nil;e:false;p:false),
  (t:'a';c:nil;e:false;p:false),
  (t:'b';c:nil;e:false;p:false),
  (t:'c';c:nil;e:false;p:false),
  (t:'d';c:nil;e:false;p:false),
  (t:'e';c:nil;e:false;p:false),
  (t:'f';c:nil;e:false;p:false),
  (t:'g';c:nil;e:false;p:false),
  (t:'h';c:nil;e:false;p:false),
  (t:'i';c:nil;e:false;p:false),
  (t:'j';c:nil;e:false;p:false),
  (t:'k';c:nil;e:false;p:false),
  (t:'l';c:nil;e:false;p:false),
  (t:'m';c:nil;e:false;p:false),
  (t:'n';c:nil;e:false;p:false),
  (t:'o';c:nil;e:false;p:false),
  (t:'p';c:nil;e:false;p:false),
  (t:'q';c:nil;e:false;p:false),
  (t:'r';c:nil;e:false;p:false),
  (t:'s';c:nil;e:false;p:false),
  (t:'t';c:nil;e:false;p:false),
  (t:'u';c:nil;e:false;p:false),
  (t:'v';c:nil;e:false;p:false),
  (t:'w';c:nil;e:false;p:false),
  (t:'x';c:nil;e:false;p:false),
  (t:'y';c:nil;e:false;p:false),
  (t:'z';c:nil;e:false;p:false),
  (t:'A';c:nil;e:false;p:false),
  (t:'B';c:nil;e:false;p:false),
  (t:'C';c:nil;e:false;p:false),
  (t:'D';c:nil;e:false;p:false),
  (t:'E';c:nil;e:false;p:false),
  (t:'F';c:nil;e:false;p:false),
  (t:'G';c:nil;e:false;p:false),
  (t:'H';c:nil;e:false;p:false),
  (t:'I';c:nil;e:false;p:false),
  (t:'J';c:nil;e:false;p:false),
  (t:'K';c:nil;e:false;p:false),
  (t:'L';c:nil;e:false;p:false),
  (t:'M';c:nil;e:false;p:false),
  (t:'N';c:nil;e:false;p:false),
  (t:'O';c:nil;e:false;p:false),
  (t:'P';c:nil;e:false;p:false),
  (t:'Q';c:nil;e:false;p:false),
  (t:'R';c:nil;e:false;p:false),
  (t:'S';c:nil;e:false;p:false),
  (t:'T';c:nil;e:false;p:false),
  (t:'U';c:nil;e:false;p:false),
  (t:'V';c:nil;e:false;p:false),
  (t:'W';c:nil;e:false;p:false),
  (t:'X';c:nil;e:false;p:false),
  (t:'Y';c:nil;e:false;p:false),
  (t:'Z';c:nil;e:false;p:false),
  (t:'0';c:nil;e:false;p:false),
  (t:'1';c:nil;e:false;p:false),
  (t:'2';c:nil;e:false;p:false),
  (t:'3';c:nil;e:false;p:false),
  (t:'4';c:nil;e:false;p:false),
  (t:'5';c:nil;e:false;p:false),
  (t:'6';c:nil;e:false;p:false),
  (t:'7';c:nil;e:false;p:false),
  (t:'8';c:nil;e:false;p:false),
  (t:'9';c:nil;e:false;p:false),
  (t:'';c:nil;e:false;p:false)
 );

 bcheckparams: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'(';c:@paramsstart0co;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bparamsstart: array[0..1] of branchty = (
  (t:'';c:@paramsco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bparamsend: array[0..3] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'';c:nil;e:false;p:false)
 );

 bparams: array[0..1] of branchty = (
  (t:'';c:@simpexpco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bparams1: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:',';c:@paramsco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bbracketstart: array[0..1] of branchty = (
  (t:'';c:@simpexpco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bbracketend: array[0..3] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'';c:nil;e:false;p:false)
 );

 bln: array[0..4] of branchty = (
  (t:' ';c:nil;e:false;p:false),
  (t:#$0d;c:nil;e:false;p:false),
  (t:#$0a;c:nil;e:false;p:false),
  (t:'(';c:@paramsstartco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bexponent: array[0..12] of branchty = (
  (t:'+';c:nil;e:false;p:false),
  (t:'-';c:@negexponentco;e:false;p:true),
  (t:'0';c:@numco;e:false;p:true),
  (t:'1';c:@numco;e:false;p:true),
  (t:'2';c:@numco;e:false;p:true),
  (t:'3';c:@numco;e:false;p:true),
  (t:'4';c:@numco;e:false;p:true),
  (t:'5';c:@numco;e:false;p:true),
  (t:'6';c:@numco;e:false;p:true),
  (t:'7';c:@numco;e:false;p:true),
  (t:'8';c:@numco;e:false;p:true),
  (t:'9';c:@numco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
 );

 bnegexponent: array[0..10] of branchty = (
  (t:'0';c:@numco;e:false;p:true),
  (t:'1';c:@numco;e:false;p:true),
  (t:'2';c:@numco;e:false;p:true),
  (t:'3';c:@numco;e:false;p:true),
  (t:'4';c:@numco;e:false;p:true),
  (t:'5';c:@numco;e:false;p:true),
  (t:'6';c:@numco;e:false;p:true),
  (t:'7';c:@numco;e:false;p:true),
  (t:'8';c:@numco;e:false;p:true),
  (t:'9';c:@numco;e:false;p:true),
  (t:'';c:nil;e:false;p:false)
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
 simpexp1co.handle:= @handlesimpexp1;
 addtermco.branch:= @baddterm;
 addtermco.next:= @simpexp1co;
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
 identifierco.branch:= @bidentifier;
 identifierco.next:= @identifier1co;
 identifier1co.branch:= @bidentifier1;
 identifier2co.branch:= @bidentifier2;
 valueidentifierco.branch:= @bvalueidentifier;
 valueidentifierco.next:= @checkparamsco;
 valueidentifierco.handle:= @handleidentifier;
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

