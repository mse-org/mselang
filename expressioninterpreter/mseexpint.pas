{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseexpint;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes;

//todo: use efficient data structures, this is a proof of concept only

type
 opinfoty = record
 end;
 oparty = array of opinfoty;
 
function parse(const input: string; out errors: stringarty): oparty;

implementation
const
 stackdepht = 256;
type
 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure(const info: pparseinfoty);
 
 pcontextty = ^contextty;
 branchty = record
  t: char;
  c: pcontextty;
 end;
 pbranchty = ^branchty;
 
 contextty = record
  branch: pbranchty; //array
  handle: contexthandlerty;
  next: pcontextty;
//  single: boolean;
 end;

 contextkindty = (ck_intconst,ck_realconst);
 intconstty = record
  value: integer;
 end;
 realconstty = record
  value: double;
 end;
 contextitemty = record
  parent: integer;
  context: pcontextty;
  start: pchar;
  case kind: contextkindty of 
   ck_intconst:(
    intconst: intconstty;
   );
   ck_realconst:(
    realconst: realconstty;
   )
 end;
 
 parseinfoty = record
  source: pchar;
  consumed: pchar;
  contextstack: array[0..stackdepht] of contextitemty;
  stackindex: integer; 
  stacktop: integer; 
 end;
 
//procedure handledecnum(const info: pparseinfoty); forward;
//procedure handlefrac(const info: pparseinfoty); forward;

var
 num0co: contextty;
 numco: contextty;
 fracco: contextty;
 mulfactco: contextty;
 termco: contextty;
 term1co: contextty;
 simpexpco: contextty;
 simpexp1co: contextty;
 addtermco: contextty;
 
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
   (t:' ';c:@num0co),
   (t:#0;c:nil)
   );
{
 btermmul: array[0..11] of branchty =
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
   (t:' ';c:@termmulco),
   (t:#0;c:nil)
   );
}
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
   (t:#0;c:nil)
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
   (t:#0;c:nil)
  );
  
 bterm: array[0..11] of branchty =
  ((t:' ';c:@termco),
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
//   (t:'*';c:@termmulco),   
   (t:#0;c:nil)
  );
  
 bterm1: array[0..2] of branchty =
  ((t:' ';c:@term1co),
   (t:'*';c:@mulfactco),
   (t:#0;c:nil)
  );

 bsimpexp1: array[0..2] of branchty =
  ((t:' ';c:@simpexp1co),
   (t:'+';c:@addtermco),
   (t:#0;c:nil)
  );

 bsimpexp: array[0..0] of branchty =
  (
   (t:#0;c:@termco)
  );

const
 int32decdigits: array[0..9] of integer =
 (         1,
          10,
         100,
        1000,
       10000,
      100000,
     1000000,
    10000000,
   100000000,
  1000000000
 );

procedure outvalues(const info: pparseinfoty; const items: array of integer;
                      const text: string);
 procedure dump(const aitem: contextitemty);
 begin
  with aitem do begin
   case aitem.kind of
    ck_intconst: begin
     write(intconst.value,' ');
    end;
    ck_realconst: begin
     write(realconst.value,' ');
    end;
   end;
  end;
 end;
 
var
 int1: integer;
begin
 with info^ do begin
  for int1:= 0 to high(items) do begin
   dump(info^.contextstack[stackindex+items[int1]]);
  end;
 end;
 writeln(text);
end;

procedure handledecnum(const info: pparseinfoty);
var
 int1,int2: integer;
 po1: pchar;
begin
 with info^,contextstack[stacktop] do begin
  po1:= source;
  consumed:= po1;
  int2:= 0;
  dec(po1);
  int1:= po1-start;
  if int1 <= high(int32decdigits) then begin
   for int1:= 0 to int1 do begin
    int2:= int2 + (ord(po1^)-ord('0')) * int32decdigits[int1];
    dec(po1);
   end;
  end;
  kind:= ck_intconst;
  intconst.value:= int2;
  stackindex:= stacktop-1;
 end;
 outvalues(info,[1],'');
end;

const
 floatexps: array[0..19] of double = 
  (1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,
   1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19);
 
procedure handlefrac(const info: pparseinfoty);
 //todo: handle > 10 digits
var
 int1,int2: integer;
 po1: pchar;
 fraclen: integer;
begin
 with info^ do begin
  with contextstack[stacktop] do begin
   fraclen:= source-start-1;
  end;
  stacktop:= stacktop - 1;
  stackindex:= stacktop-1;
  with contextstack[stacktop] do begin
   po1:= source;
   consumed:= po1;
   int2:= 0;
   dec(po1);
   int1:= po1-start-1;
   if int1 <= high(int32decdigits) then begin
    for int1:= 0 to int1 do begin
     int2:= int2 + (ord(po1^)-ord('0')) * int32decdigits[int1];
     dec(po1);
     if po1^ = '.' then begin
      dec(po1);
     end;
    end;
   end;
   kind:= ck_realconst;
   realconst.value:= int2/floatexps[fraclen]; //todo: round lsb
  end;
 end;
 outvalues(info,[1],'');
end;

procedure handlemulfact(const info: pparseinfoty);
begin
 dec(info^.stacktop,3);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[1,3],'*');
end;

procedure handleaddterm(const info: pparseinfoty);
begin
 dec(info^.stacktop,3);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[1,3],'+');
end;

procedure handleterm(const info: pparseinfoty);
begin
 dec(info^.stacktop);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[],'TERM');
end;

procedure handleterm1(const info: pparseinfoty);
begin
 dec(info^.stacktop);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[],'TERM1');
end;

procedure handlesimpexp(const info: pparseinfoty);
begin
 dec(info^.stacktop);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[],'SIMPEXP');
end;

procedure handlesimpexp1(const info: pparseinfoty);
begin
 dec(info^.stacktop);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[],'SIMPEXP1');
end;

procedure dummyhandler(const info: pparseinfoty);
begin
 //dummy
end;
  
function parse(const input: string; out errors: stringarty): oparty;
var
 pb: pbranchty;
 pc: pcontextty;
 info: parseinfoty;

 function push: boolean;
 begin
  result:= true;
  with info do begin
   pc:= pb^.c;
   inc(stacktop);
   stackindex:= stacktop;
   if stacktop = stackdepht then begin
    result:= false;
    exit;
   end;
   with contextstack[stacktop] do begin
    context:= pb^.c;
    start:= source;
   end;
  end;
 end;
 
begin
 with info do begin
  result:= nil;
  source:= pchar(input);
  with contextstack[0] do begin
   context:= @simpexpco;
   start:= source;
  end;
  stackindex:= 0;
  stacktop:= 0;
  pc:= contextstack[stackindex].context;
  while source^ <> #0 do begin
   while source^ <> #0 do begin
    pb:= pc^.branch;
    if pb^.t = #0 then begin
     if not push then begin
      exit;
     end;
    end
    else begin
     while pb^.t <> #0 do begin
      if source^ = pb^.t then begin
       if pb^.c <> pc then begin
        if not push then begin
         exit
        end;
       end;
       inc(source);
       pb:= pc^.branch;
       continue;
      end;
      inc(pb);
     end;  
     break;
    end;
 //   inc(source);
   end;
   repeat
    pc^.handle(@info);
    pc:= contextstack[stackindex].context;
   until pc^.next <> nil;
   pc:= pc^.next;
  end;
  while stackindex > 0 do begin
   contextstack[stackindex].context^.handle(@info);
  end;
  contextstack[0].context^.handle(@info);
 end;
end;

procedure init;
begin
 num0co.branch:= @bnum0;
 num0co.handle:= @dummyhandler;
 numco.branch:= @bnum; 
 numco.handle:= @handledecnum;
 fracco.branch:= @bfrac;
 fracco.handle:= @handlefrac;

 mulfactco.branch:= @bnum0;
 mulfactco.handle:= @handlemulfact;
 mulfactco.next:= @mulfactco;
 
 termco.branch:= @bterm;
 termco.handle:= @handleterm;
 termco.next:= @term1co;
 term1co.branch:= @bterm1;
 term1co.handle:= @handleterm1;
 term1co.next:= @term1co;

 addtermco.branch:= @bnum0;
 addtermco.handle:= @handleaddterm;
 addtermco.next:= @addtermco;

 simpexpco.branch:= @bsimpexp;
 simpexpco.handle:= @handlesimpexp;
 simpexpco.next:= @simpexp1co;
 simpexp1co.branch:= @bsimpexp1;
 simpexp1co.handle:= @handlesimpexp1;
 simpexp1co.next:= @simpexp1co;
 
end;
  
initialization
 init;
end.
