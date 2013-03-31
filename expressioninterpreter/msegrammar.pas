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
unit msegrammar;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseparserglob;
 
function startcontext: pcontextty;

implementation

uses
 msehandler;
 
var
 num0co: contextty = (branch: nil; handle: nil; next: nil; caption: 'num0');
 numco: contextty = (branch: nil; handle: nil; next: nil; caption: 'num');
 fracco: contextty = (branch: nil; handle: nil; next: nil; caption: 'frac');
 mulfactco: contextty = (branch: nil; handle: nil; next: nil; caption: 'mulfact');
 termco: contextty = (branch: nil; handle: nil; next: nil; caption: 'term');
 negtermco: contextty = (branch: nil; handle: nil; next: nil; caption: 'negterm');
 term1co: contextty = (branch: nil; handle: nil; next: nil; caption: 'term1');
 simpexpco: contextty = (branch: nil; handle: nil; next: nil; caption: 'simpexp');
 simpexp1co: contextty = (branch: nil; handle: nil; next: nil; caption: 'simpexp1');
 addtermco: contextty = (branch: nil; handle: nil; next: nil; caption: 'addterm');
 bracketstartco: contextty = (branch: nil; handle: nil; next: nil; caption: 'bracketstart');
 bracketendco: contextty = (branch: nil; handle: nil; next: nil; caption: 'bracketend');
 lnco: contextty = (branch: nil; handle: nil; next: nil; caption: 'ln');
 paramsstartco: contextty = (branch: nil; handle: nil; next: nil; caption: 'paramsstart');
 paramsendco: contextty = (branch: nil; handle: nil; next: nil; caption: 'paramsend');
 paramsco: contextty = (branch: nil; handle: nil; next: nil; caption: 'params');
 params1co: contextty = (branch: nil; handle: nil; next: nil; caption: 'params1');
 
 
const
 bnum0: array[0..11] of branchty =
  ((t:'0';c:@numco),
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

 bnum: array[0..11] of branchty =
  ((t:'0';c:@numco),
   (t:'1';c:@numco),
   (t:'2';c:@numco),
   (t:'3';c:@numco),
   (t:'4';c:@numco),
   (t:'5';c:@numco),
   (t:'6';c:@numco),
   (t:'7';c:@numco),
   (t:'8';c:@numco),
   (t:'9';c:@numco),
   (t:'.';c:@fracco),
   (t:'';c:nil)
   );

 bfrac: array[0..10] of branchty =
  ((t:'0';c:@fracco),
   (t:'1';c:@fracco),
   (t:'2';c:@fracco),
   (t:'3';c:@fracco),
   (t:'4';c:@fracco),
   (t:'5';c:@fracco),
   (t:'6';c:@fracco),
   (t:'7';c:@fracco),
   (t:'8';c:@fracco),
   (t:'9';c:@fracco),
   (t:'';c:nil)
  );
  
 bterm: array[0..15] of branchty =
  ((t:' ';c:nil),
   (t:'+';c:@termco),
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

 bfunc: array[0..2] of branchty =  
  ((t:' ';c:nil),
   (t:'(';c:@paramsstartco),
   (t:'';c:nil)
  );

 bparams: array[0..0] of branchty =
  (
   (t:'';c:@simpexpco)
  );
 bparams1: array[0..1] of branchty =
  (
   (t:' ';c:nil),
   (t:',';c:@paramsco)
  );
    
 bparamsstart: array[0..0] of branchty =
  (
   (t:'';c:@paramsco)
  );

 bparamsend: array[0..1] of branchty =
  ((t:' ';c:nil),
   (t:'';c:nil)
  );

 bterm1: array[0..2] of branchty =
  ((t:' ';c:nil),
   (t:'*';c:@mulfactco),
   (t:'';c:nil)
  );

 bsimpexp1: array[0..2] of branchty =
  ((t:' ';c:nil),
   (t:'+';c:@addtermco),
   (t:'';c:nil)
  );

 bsimpexp: array[0..0] of branchty =
  (
   (t:'';c:@termco)
  );

 baddterm: array[0..0] of branchty =
  (
   (t:'';c:@termco)
  );

 bbracketstart: array[0..0] of branchty =
  (
   (t:'';c:@simpexpco)
  );

 bbracketend: array[0..1] of branchty =
  ((t:' ';c:nil),
   (t:'';c:nil)
  );
 
procedure init;
begin
 num0co.branch:= @bnum0;
 num0co.handle:= @dummyhandler;
 numco.branch:= @bnum; 
 numco.handle:= @handledecnum;
 fracco.branch:= @bfrac;
 fracco.handle:= @handlefrac;

 mulfactco.branch:= @bterm;
 mulfactco.handle:= @handlemulfact;
// mulfactco.next:= @mulfactco;
 
 termco.branch:= @bterm;
 termco.handle:= @handleterm;
 termco.next:= @term1co;
 negtermco.branch:= nil; //immediate
 negtermco.handle:= @handlenegterm;
 negtermco.next:= @termco;
 term1co.branch:= @bterm1;
 term1co.handle:= @handleterm1;
 term1co.next:= @term1co;
 
 bracketstartco.branch:= @bbracketstart;
 bracketstartco.handle:= @dummyhandler;
 bracketstartco.next:= @bracketendco;
 bracketendco.branch:= @bbracketend;
 bracketendco.handle:= @handlebracketend;

 addtermco.branch:= @baddterm;
 addtermco.handle:= @handleaddterm;
// addtermco.next:= @addtermco;

 simpexpco.branch:= @bsimpexp;
 simpexpco.handle:= @handlesimpexp;
 simpexpco.next:= @simpexp1co;
 simpexp1co.branch:= @bsimpexp1;
 simpexp1co.handle:= @handlesimpexp1;
 simpexp1co.next:= @simpexp1co;
 
 lnco.branch:= @bfunc;
 lnco.handle:= @handleln;
 paramsstartco.branch:= @bparamsstart;
 paramsstartco.next:= @paramsendco;
 paramsstartco.handle:= @dummyhandler;
 paramsstartco.next:= @paramsendco;
 paramsendco.branch:= @bparamsend;
 paramsendco.handle:= @handleparamsend;

 paramsco.branch:= @bparams;
 paramsco.handle:= @handleparam;
 paramsco.next:= @params1co;
 params1co.branch:= @bparams1;
 params1co.handle:= @handleparam;
 
end;

function startcontext: pcontextty;
begin
 result:= @simpexpco;
end;

initialization
 init;
end.
