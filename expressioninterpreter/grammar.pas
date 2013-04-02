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
 simpexpco: contextty = (branch: nil; handle: nil; next: nil; caption: 'simpexp');
 num0co: contextty = (branch: nil; handle: nil; next: nil; caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; next: nil; caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; next: nil; caption: 'frac');
 termco: contextty = (branch: nil; handle: nil; next: nil; caption: 'term');
 negtermco: contextty = (branch: nil; handle: nil; next: nil; caption: 'negterm');
 mulfactco: contextty = (branch: nil; handle: nil; next: nil; caption: 'mulfact');
 paramsco: contextty = (branch: nil; handle: nil; next: nil; caption: 'params');
 params1co: contextty = (branch: nil; handle: nil; next: nil; caption: 'params1');
 paramsstartco: contextty = (branch: nil; handle: nil; next: nil; caption: 'paramsstart');
 paramsendco: contextty = (branch: nil; handle: nil; next: nil; caption: 'paramsend');
 term1co: contextty = (branch: nil; handle: nil; next: nil; caption: 'term1');
 simpexp1co: contextty = (branch: nil; handle: nil; next: nil; caption: 'simpexp1');
 addtermco: contextty = (branch: nil; handle: nil; next: nil; caption: 'addterm');
 bracketstartco: contextty = (branch: nil; handle: nil; next: nil; caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; handle: nil; next: nil; caption: 'bracketend');
 lnco: contextty = (branch: nil; handle: nil; next: nil; caption: 'ln');
 exponentco: contextty = (branch: nil; handle: nil; next: nil; caption: 'exponent');
 negexponentco: contextty = (branch: nil; handle: nil; next: nil; caption: 'negexponent');

const
 bsimpexp: array[0..1] of branchty = (
  (t:'';c:@termco),
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

 bterm: array[0..15] of branchty = (
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

 bsimpexp1: array[0..2] of branchty = (
  (t:' ';c:nil),
  (t:'+';c:@addtermco),
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
 num0co.branch:= @bnum0;
 num0co.handle:= @dummyhandler;
 numco.branch:= @bnum;
 numco.handle:= @handledecnum;
 fracco.branch:= @bfrac;
 fracco.handle:= @handlefrac;
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
 simpexp1co.branch:= @bsimpexp1;
 simpexp1co.next:= @simpexp1co;
 simpexp1co.handle:= @handlesimpexp1;
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

