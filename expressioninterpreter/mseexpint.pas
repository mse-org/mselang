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
  branch: pbranchty; //array of //nil -> leaf
  handle: contexthandlerty;
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
 
procedure handledecnum(const info: pparseinfoty); forward;
procedure handlefrac(const info: pparseinfoty); forward;

var
 startco: contextty;
 num0co: contextty;
 numco: contextty;
 fracco: contextty;
 termmulco: contextty;
 
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
  
 bstart: array[0..12] of branchty =
  ((t:' ';c:@startco),
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
   (t:'*';c:@termmulco),   
   (t:#0;c:nil)
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
   int1:= po1-start-3;
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

procedure handletermmul(const info: pparseinfoty);
begin
 dec(info^.stacktop,2);
 info^.stackindex:= info^.stacktop;
 outvalues(info,[2,0],'*');
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
begin
 with info do begin
  result:= nil;
  source:= pchar(input);
  with contextstack[0] do begin
   context:= @startco;
   start:= source;
  end;
  stackindex:= 0;
  stacktop:= 0;
  while source^ <> #0 do begin
   pc:= contextstack[stackindex].context;
   while source^ <> #0 do begin
    pb:= pc^.branch;
    while pb^.t <> #0 do begin
     if source^ = pb^.t then begin
      if pb^.c <> pc then begin
       pc:= pb^.c;
 //      if pc^.branch = nil then begin //leaf
 //       pc^.handle(@info);
 //      end
 //      else begin
        inc(stacktop);
        inc(stackindex);
        if stacktop = stackdepht then begin
         exit;
        end;
        with contextstack[stacktop] do begin
         context:= pb^.c;
         start:= source;
        end;
       //end;
      end;
      inc(source);
      pb:= pc^.branch;
      continue;
     end;
     inc(pb);
    end;  
    break;
 //   inc(source);
   end;
   pc^.handle(@info);
  end;
  while stackindex > 0 do begin
   contextstack[stackindex].context^.handle(@info);
  end;
  contextstack[0].context^.handle(@info);
 end;
end;

procedure init;
begin
 startco.branch:= @bstart;
 startco.handle:= @dummyhandler;
 num0co.branch:= @bnum0;
 num0co.handle:= @dummyhandler;
 numco.branch:= @bnum; 
 numco.handle:= @handledecnum;
 fracco.branch:= @bfrac;
 fracco.handle:= @handlefrac;
 termmulco.branch:= @bnum0;
 termmulco.handle:= @handletermmul;
end;
  
initialization
 init;
end.
