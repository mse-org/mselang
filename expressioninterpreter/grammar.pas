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
 simpexpco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'simpexp1');
 num0co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'frac');
 identifierco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'identifier');
 checkparamsco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'checkparams');
 paramsstart0co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'paramsstart0');
 termco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'term');
 negtermco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'negterm');
 mulfactco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'mulfact');
 paramsco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'params');
 params1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'params1');
 paramsstartco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'paramsstart');
 paramsendco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'paramsend');
 term1co: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'term1');
 addtermco: contextty = (branch: nil; handle: nil; next: nil;
               caption: 'addterm');
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
 bsimpexp: array[0..1] of branchty = (
  (t:'';c:@termco),
  (t:'';c:nil)
 );

 bsimpexp1: array[0..2] of branchty = (
  (t:' ';c:nil),
  (t:'+';c:@addtermco),
  (t:'';c:nil)
 );

 bnum0: array[0..11] of branchty = (
  (t:'0';c:@numco),
  (t:'1';c:@numco),
  (t:'2';c:@numco),
  (t:'3';c:@numco),
  (t:'4';c:@numco),
  (t:'5';c:@numco),
  (t:'6';c:@numco),
  (t:'7';c:@numco),
  (t:'8';c:@numco),
  (t:'9';c:@numco),
  (t:' ';c:nil),
  (t:'';c:nil)
 );

 bnum: array[0..11] of branchty = (
  (t:'0';c:nil),
  (t:'1';c:nil),
  (t:'2';c:nil),
  (t:'3';c:nil),
  (t:'4';c:nil),
  (t:'5';c:nil),
  (t:'6';c:nil),
  (t:'7';c:nil),
  (t:'8';c:nil),
  (t:'9';c:nil),
  (t:'.';c:@fracco),
  (t:'';c:nil)
 );

 bfrac: array[0..12] of branchty = (
  (t:'0';c:nil),
  (t:'1';c:nil),
  (t:'2';c:nil),
  (t:'3';c:nil),
  (t:'4';c:nil),
  (t:'5';c:nil),
  (t:'6';c:nil),
  (t:'7';c:nil),
  (t:'8';c:nil),
  (t:'9';c:nil),
  (t:'e';c:@exponentco),
  (t:'E';c:@exponentco),
  (t:'';c:nil)
 );

 bidentifier: array[0..63] of branchty = (
  (t:'0';c:nil),
  (t:'1';c:nil),
  (t:'2';c:nil),
  (t:'3';c:nil),
  (t:'4';c:nil),
  (t:'5';c:nil),
  (t:'6';c:nil),
  (t:'7';c:nil),
  (t:'8';c:nil),
  (t:'9';c:nil),
  (t:'_';c:nil),
  (t:'a';c:nil),
  (t:'b';c:nil),
  (t:'c';c:nil),
  (t:'d';c:nil),
  (t:'e';c:nil),
  (t:'f';c:nil),
  (t:'g';c:nil),
  (t:'h';c:nil),
  (t:'i';c:nil),
  (t:'j';c:nil),
  (t:'k';c:nil),
  (t:'l';c:nil),
  (t:'m';c:nil),
  (t:'n';c:nil),
  (t:'o';c:nil),
  (t:'p';c:nil),
  (t:'q';c:nil),
  (t:'r';c:nil),
  (t:'s';c:nil),
  (t:'t';c:nil),
  (t:'u';c:nil),
  (t:'v';c:nil),
  (t:'w';c:nil),
  (t:'x';c:nil),
  (t:'y';c:nil),
  (t:'z';c:nil),
  (t:'A';c:nil),
  (t:'B';c:nil),
  (t:'C';c:nil),
  (t:'D';c:nil),
  (t:'E';c:nil),
  (t:'F';c:nil),
  (t:'G';c:nil),
  (t:'H';c:nil),
  (t:'I';c:nil),
  (t:'J';c:nil),
  (t:'K';c:nil),
  (t:'L';c:nil),
  (t:'M';c:nil),
  (t:'N';c:nil),
  (t:'O';c:nil),
  (t:'P';c:nil),
  (t:'Q';c:nil),
  (t:'R';c:nil),
  (t:'S';c:nil),
  (t:'T';c:nil),
  (t:'U';c:nil),
  (t:'V';c:nil),
  (t:'W';c:nil),
  (t:'X';c:nil),
  (t:'Y';c:nil),
  (t:'Z';c:nil),
  (t:'';c:nil)
 );

 bcheckparams: array[0..2] of branchty = (
  (t:' ';c:nil),
  (t:'(';c:@paramsstart0co),
  (t:'';c:nil)
 );

 bterm: array[0..67] of branchty = (
  (t:' ';c:nil),
  (t:'+';c:nil),
  (t:'-';c:@negtermco),
  (t:'(';c:@bracketstartco),
  (t:'0';c:@numco),
  (t:'1';c:@numco),
  (t:'2';c:@numco),
  (t:'3';c:@numco),
  (t:'4';c:@numco),
  (t:'5';c:@numco),
  (t:'6';c:@numco),
  (t:'7';c:@numco),
  (t:'8';c:@numco),
  (t:'9';c:@numco),
  (t:'_';c:@identifierco),
  (t:'a';c:@identifierco),
  (t:'b';c:@identifierco),
  (t:'c';c:@identifierco),
  (t:'d';c:@identifierco),
  (t:'e';c:@identifierco),
  (t:'f';c:@identifierco),
  (t:'g';c:@identifierco),
  (t:'h';c:@identifierco),
  (t:'i';c:@identifierco),
  (t:'j';c:@identifierco),
  (t:'k';c:@identifierco),
  (t:'l';c:@identifierco),
  (t:'m';c:@identifierco),
  (t:'n';c:@identifierco),
  (t:'o';c:@identifierco),
  (t:'p';c:@identifierco),
  (t:'q';c:@identifierco),
  (t:'r';c:@identifierco),
  (t:'s';c:@identifierco),
  (t:'t';c:@identifierco),
  (t:'u';c:@identifierco),
  (t:'v';c:@identifierco),
  (t:'w';c:@identifierco),
  (t:'x';c:@identifierco),
  (t:'y';c:@identifierco),
  (t:'z';c:@identifierco),
  (t:'A';c:@identifierco),
  (t:'B';c:@identifierco),
  (t:'C';c:@identifierco),
  (t:'D';c:@identifierco),
  (t:'E';c:@identifierco),
  (t:'F';c:@identifierco),
  (t:'G';c:@identifierco),
  (t:'H';c:@identifierco),
  (t:'I';c:@identifierco),
  (t:'J';c:@identifierco),
  (t:'K';c:@identifierco),
  (t:'L';c:@identifierco),
  (t:'M';c:@identifierco),
  (t:'N';c:@identifierco),
  (t:'O';c:@identifierco),
  (t:'P';c:@identifierco),
  (t:'Q';c:@identifierco),
  (t:'R';c:@identifierco),
  (t:'S';c:@identifierco),
  (t:'T';c:@identifierco),
  (t:'U';c:@identifierco),
  (t:'V';c:@identifierco),
  (t:'W';c:@identifierco),
  (t:'X';c:@identifierco),
  (t:'Y';c:@identifierco),
  (t:'Z';c:@identifierco),
  (t:'';c:nil)
 );

 bmulfact: array[0..15] of branchty = (
  (t:' ';c:nil),
  (t:'+';c:nil),
  (t:'-';c:@negtermco),
  (t:'(';c:@bracketstartco),
  (t:'0';c:@numco),
  (t:'1';c:@numco),
  (t:'2';c:@numco),
  (t:'3';c:@numco),
  (t:'4';c:@numco),
  (t:'5';c:@numco),
  (t:'6';c:@numco),
  (t:'7';c:@numco),
  (t:'8';c:@numco),
  (t:'9';c:@numco),
  (t:'ln';c:@lnco),
  (t:'';c:nil)
 );

 bparams: array[0..1] of branchty = (
  (t:'';c:@simpexpco),
  (t:'';c:nil)
 );

 bparams1: array[0..2] of branchty = (
  (t:' ';c:nil),
  (t:',';c:@paramsco),
  (t:'';c:nil)
 );

 bparamsstart: array[0..1] of branchty = (
  (t:'';c:@paramsco),
  (t:'';c:nil)
 );

 bparamsend: array[0..1] of branchty = (
  (t:' ';c:nil),
  (t:'';c:nil)
 );

 bterm1: array[0..2] of branchty = (
  (t:' ';c:nil),
  (t:'*';c:@mulfactco),
  (t:'';c:nil)
 );

 baddterm: array[0..1] of branchty = (
  (t:'';c:@termco),
  (t:'';c:nil)
 );

 bbracketstart: array[0..1] of branchty = (
  (t:'';c:@simpexpco),
  (t:'';c:nil)
 );

 bbracketend: array[0..1] of branchty = (
  (t:' ';c:nil),
  (t:'';c:nil)
 );

 bln: array[0..2] of branchty = (
  (t:' ';c:nil),
  (t:'(';c:@paramsstartco),
  (t:'';c:nil)
 );

 bexponent: array[0..12] of branchty = (
  (t:'+';c:nil),
  (t:'-';c:@negexponentco),
  (t:'0';c:@numco),
  (t:'1';c:@numco),
  (t:'2';c:@numco),
  (t:'3';c:@numco),
  (t:'4';c:@numco),
  (t:'5';c:@numco),
  (t:'6';c:@numco),
  (t:'7';c:@numco),
  (t:'8';c:@numco),
  (t:'9';c:@numco),
  (t:'';c:nil)
 );

 bnegexponent: array[0..10] of branchty = (
  (t:'0';c:@numco),
  (t:'1';c:@numco),
  (t:'2';c:@numco),
  (t:'3';c:@numco),
  (t:'4';c:@numco),
  (t:'5';c:@numco),
  (t:'6';c:@numco),
  (t:'7';c:@numco),
  (t:'8';c:@numco),
  (t:'9';c:@numco),
  (t:'';c:nil)
 );

procedure init;
begin
 simpexpco.branch:= @bsimpexp;
 simpexpco.next:= @simpexp1co;
 simpexpco.handle:= @handlesimpexp;
 simpexp1co.branch:= @bsimpexp1;
 simpexp1co.handle:= @handlesimpexp1;
 num0co.branch:= @bnum0;
 num0co.handle:= @dummyhandler;
 numco.branch:= @bnum;
 numco.handle:= @handledecnum;
 fracco.branch:= @bfrac;
 fracco.handle:= @handlefrac;
 identifierco.branch:= @bidentifier;
 identifierco.next:= @checkparamsco;
 identifierco.handle:= @handleidentifier;
 checkparamsco.branch:= @bcheckparams;
 checkparamsco.handle:= @handlecheckparams;
 paramsstart0co.branch:= nil;
 paramsstart0co.next:= @paramsstartco;
 paramsstart0co.handle:= @handleparamstart0;
 termco.branch:= @bterm;
 termco.next:= @term1co;
 termco.handle:= @handleterm;
 negtermco.branch:= nil;
 negtermco.next:= @termco;
 negtermco.handle:= @handlenegterm;
 mulfactco.branch:= @bmulfact;
 mulfactco.handle:= @handlemulfact;
 paramsco.branch:= @bparams;
 paramsco.next:= @params1co;
 paramsco.handle:= @handleparam;
 params1co.branch:= @bparams1;
 params1co.handle:= @handleparam;
 paramsstartco.branch:= @bparamsstart;
 paramsstartco.next:= @paramsendco;
 paramsstartco.handle:= @dummyhandler;
 paramsendco.branch:= @bparamsend;
 paramsendco.handle:= @handleparamsend;
 term1co.branch:= @bterm1;
 term1co.next:= @term1co;
 term1co.handle:= @handleterm1;
 addtermco.branch:= @baddterm;
 addtermco.handle:= @handleaddterm;
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
 result:= @simpexpco;
end;

initialization
 init;
end.

