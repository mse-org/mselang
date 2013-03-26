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
 msetypes,msestream,msestackops;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

//type
 
function parse(const input: string; const acommand: ttextstream): opinfoarty;

implementation
uses
 typinfo;
 
type
 contextkindty = (ck_none,ck_neg,ck_int32const,ck_flo64const,
                  ck_int32fact,ck_flo64fact);
 stackdatakindty = (sdk_int32,sdk_flo64,sdk_int32rev,sdk_flo64rev);
const
 valuecontext = ck_int32const;
 reversestackdata = sdk_int32rev;
 stackdepht = 256;
 int32kinds = [ck_int32const,ck_int32fact];
 flo64kinds = [ck_flo64const,ck_flo64fact];
type
 pparseinfoty = ^parseinfoty;
 contexthandlerty = procedure(const info: pparseinfoty);
 
 pcontextty = ^contextty;
 branchty = record
  t: string;
  c: pcontextty;
 end;
 pbranchty = ^branchty;
 
 contextty = record
  branch: pbranchty; //array
  handle: contexthandlerty;
  next: pcontextty;
  caption: string;
 end;

 int32constty = record
  value: integer;
 end;
 flo64constty = record
  value: double;
 end;
 contextitemty = record
  parent: integer;
  context: pcontextty;
  start: pchar;
  case kind: contextkindty of 
   ck_int32const:(
    int32const: int32constty;
   );
   ck_flo64const:(
    flo64const: flo64constty;
   )
 end;
 
 parseinfoty = record
  source: pchar;
  consumed: pchar;
  contextstack: array[0..stackdepht] of contextitemty;
  stackindex: integer; 
  stacktop: integer; 
  command: ttextstream;
  ops: opinfoarty;
  opcount: integer;
 end;
 
//procedure handledecnum(const info: pparseinfoty); forward;
//procedure handlefrac(const info: pparseinfoty); forward;

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

procedure outhandle(const info: pparseinfoty; const text: string);
begin
 writeln(' *handle* ',text);
end;

procedure outinfo(const info: pparseinfoty; const text: string);
var
 int1: integer;
begin
 with info^ do begin
  writeln('**',text,' T:',stacktop,' I:',stackindex,' ''',source,'''');
  for int1:= stacktop downto 0 do begin
   write(int1);
   if int1 = stackindex then begin
    write('*');
   end
   else begin
    write(' ');
   end;
   with contextstack[int1] do begin
    write(getenumname(typeinfo(kind),ord(kind)),' ');
    case kind of
     ck_int32const: begin
      write(int32const.value,' ');
     end;
     ck_flo64const: begin
      write(flo64const.value,' ');
     end;
    end;
    if context <> nil then begin
     write(context^.caption);
    end
    else begin
     write('NIL');
    end;
    writeln(' ''',start,'''');
   end;
  end;
 end;
end;

procedure outcommand(const info: pparseinfoty; const items: array of integer;
                     const text: string);
var
 int1: integer;
begin
 with info^ do begin
  for int1:= 0 to high(items) do begin
   with contextstack[stacktop+items[int1]] do begin
    command.write([getenumname(typeinfo(kind),ord(kind)),': ']);
    case kind of
     ck_int32const: begin
      command.write(int32const.value);
     end;
     ck_flo64const: begin
      command.write(flo64const.value);
     end;
    end;
    command.write(',');
   end;
  end;
  command.writeln([' ',text]);
 end;
end;

function additem(const info: pparseinfoty): popinfoty;
begin
 with info^ do begin
  if high(ops) < opcount then begin
   setlength(ops,(high(ops)+257)*2);
  end;
  result:= @ops[opcount];
  inc(opcount);
 end;
end;

procedure push(const info: pparseinfoty; const avalue: integer); overload;
begin
 with additem(info)^ do begin
  op:= @pushint32;
  vint32:= avalue;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: real); overload;
begin
 with additem(info)^ do begin
  op:= @pushflo64;
  vflo64:= avalue;
 end;
end;

procedure int32toflo64(const info: pparseinfoty; const index: integer);
begin
 with additem(info)^ do begin
  op:= @msestackops.int32toflo64;
  with op1 do begin
   index0:= index;
  end;
 end;
end;

const
 resultdatakinds: array[stackdatakindty] of contextkindty =
                         (ck_int32fact,ck_flo64fact,ck_int32fact,ck_flo64fact);

function pushvalues(const info: pparseinfoty): stackdatakindty;
//todo: don't convert inplace, stack items will be of variable size
var
 reverse,negative: boolean;
begin
 reverse:= false;
 with info^ do begin
  if (contextstack[stacktop].kind in flo64kinds) or 
             (contextstack[stacktop-2].kind in flo64kinds) then begin
   result:= sdk_flo64;
   with contextstack[stacktop] do begin
    case kind of
     ck_int32const: begin
      push(info,real(int32const.value));
      reverse:= true;
     end;
     ck_flo64const: begin
      push(info,flo64const.value);
      reverse:= true;
     end;
     ck_int32fact: begin
      int32toflo64(info,0);
     end;
    end;
   end;
   with contextstack[stacktop-2] do begin
    case kind of
     ck_int32const: begin
      push(info,real(int32const.value));
      reverse:= not reverse;
     end;
     ck_flo64const: begin
      push(info,real(flo64const.value));
      reverse:= not reverse;
     end;
     ck_int32fact: begin
      int32toflo64(info,-1);
     end;
    end;
   end;
  end
  else begin
   result:= sdk_int32;
   with contextstack[stacktop-2] do begin
    case kind of
     ck_int32const: begin
      push(info,int32const.value);
      reverse:= true;
     end;
    end;
   end;
   with contextstack[stacktop] do begin
    case kind of
     ck_int32const: begin
      push(info,int32const.value);
      reverse:= not reverse;
     end;
    end;
   end;
  end;
  if reverse then begin
   result:= stackdatakindty(ord(result)+ord(reversestackdata));
  end;
  dec(stacktop,2);
  with contextstack[stacktop] do begin
   kind:= resultdatakinds[result];
   context:= nil;
  end;
  stackindex:= stacktop-1;
 end;
end;

procedure writeop(const info: pparseinfoty; const operation: opty); inline;
begin
 with additem(info)^ do begin
  op:= operation
 end;
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
  stackindex:= stacktop-1;
  if contextstack[stackindex].kind = ck_neg then begin
   int2:= -int2;
  end;
  int32const.value:= int2;
  kind:= ck_int32const;
 end;
 outhandle(info,'CNUM');
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
 rea1: real;
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
   kind:= ck_flo64const;
   if contextstack[stackindex].kind = ck_neg then begin
    int2:= -int2;
   end;
   flo64const.value:= int2/floatexps[fraclen]; //todo: round lsb;   
  end;
 end;
 outhandle(info,'FRAC');
end;

const
 mulops: array[stackdatakindty] of opty =
                            (@mulint32,@mulflo64,@mulint32,@mulflo64);
 
procedure handlemulfact(const info: pparseinfoty);
begin
 outcommand(info,[-2,0],'*');
 writeop(info,mulops[pushvalues(info)]);
 outhandle(info,'MULFACT');
end;

const
 addops: array[stackdatakindty] of opty =
                            (@addint32,@addflo64,@addint32,@addflo64);

procedure handleaddterm(const info: pparseinfoty);
begin
 outcommand(info,[-2,0],'+');
 writeop(info,addops[pushvalues(info)]);
 outhandle(info,'ADDTERM');
end;

procedure handleterm(const info: pparseinfoty);
begin
 dec(info^.stacktop);
 info^.stackindex:= info^.stacktop;
 outhandle(info,'TERM');
end;

procedure handlenegterm(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop] do begin
  if kind = ck_none then begin
   kind:= ck_neg;
  end
  else begin
   kind:= ck_none;
  end;
 end;
 outhandle(info,'NEGTERM');
end;

const
 negops: array[contextkindty] of opty = (
  //ck_none,ck_neg,ck_int32const,ck_flo64const,
    @dummyop,    @dummyop,   @negint32,    @negflo64,
  //ck_int32fact,ck_flo64fact
    @negint32,   @negflo64
 );

procedure handleterm1(const info: pparseinfoty);
begin
 with info^ do begin
  if stackindex < stacktop then begin
   if contextstack[stackindex].kind = ck_neg then begin
    writeop(info,negops[contextstack[stacktop].kind]);
   end;
   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   outcommand(info,[],'*ERROR* Expression expected');
  end;
  dec(stacktop);
  dec(stackindex);
 end;
 outhandle(info,'TERM1');
end;

procedure handlesimpexp(const info: pparseinfoty);
begin
 with info^ do begin
  contextstack[stacktop-1]:= contextstack[stacktop];
  dec(info^.stacktop);
  info^.stackindex:= info^.stacktop;
 end;
 outhandle(info,'SIMPEXP');
end;

procedure handlesimpexp1(const info: pparseinfoty);
begin
 with info^ do begin
  contextstack[stacktop-1]:= contextstack[stacktop];
  dec(stacktop);
  dec(stackindex);
 end;
 outhandle(info,'SIMPEXP1');
end;

procedure handlebracketend(const info: pparseinfoty);
begin
 with info^ do begin
  if source^ <> ')' then begin
   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source);
  end;
  if stackindex < stacktop then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   outcommand(info,[],'*ERROR* Expression expected');
  end;
  dec(stacktop);
  dec(stackindex);
 end;
 outhandle(info,'BRACKETEND');
end;

procedure handleln(const info: pparseinfoty);
begin
 outcommand(info,[0],'ln()');
 with info^ do begin
  stacktop:= stackindex;
  dec(stackindex);
  with contextstack[stacktop] do begin
   kind:= ck_int32fact;
   context:= nil;
  end;
 end;
 outhandle(info,'LN');
end;

procedure handleparamsend(const info: pparseinfoty);
begin
 with info^ do begin
  if source^ <> ')' then begin
   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source);
  end;
  dec(stackindex);
 end;
 outhandle(info,'PARAMSEND');
end;

procedure handleparam(const info: pparseinfoty);
begin
 dec(info^.stackindex);
 outhandle(info,'PARAM');
end;

procedure dummyhandler(const info: pparseinfoty);
begin
 //dummy
 outhandle(info,'DUMMY');
end;

//
// todo: optimize, this is a proof of concept only
//

function parse(const input: string; const acommand: ttextstream): opinfoarty;
var
 pb: pbranchty;
 pc: pcontextty;
 info: parseinfoty;

 function pushcontext: boolean;
 begin
  result:= true;
  with info do begin
   pc:= pb^.c;
   if pc^.branch = nil then begin
    pc^.handle(@info);
    pc:= pc^.next;
   end
   else begin
    inc(stacktop);
    stackindex:= stacktop;
    if stacktop = stackdepht then begin
     result:= false;
     exit;
    end;
    with contextstack[stacktop] do begin
     kind:= ck_none;
     context:= pb^.c;
     start:= source;
    end;
   end;
   pb:= pc^.branch;
  end;
  outinfo(@info,'push');
 end;

var
 po1,po2: pchar; 
begin
 result:= nil;
 with info do begin
  command:= acommand;
  source:= pchar(input);
  with contextstack[0] do begin
   kind:= ck_none;
   context:= @simpexpco;
   start:= source;
  end;
  stackindex:= 0;
  stacktop:= 0;
  opcount:= 0;
  pc:= contextstack[stackindex].context;
  while source^ <> #0 do begin
   while source^ <> #0 do begin
    pb:= pc^.branch;
    if pointer(pb^.t) = nil then begin
     if not pushcontext then begin
      exit;
     end;
    end
    else begin
     while pointer(pb^.t) <> nil do begin
      po1:= source;
      po2:= pointer(pb^.t);
      while po1^ = po2^ do begin
       inc(po1);
       inc(po2);
       if po1^ = #0 then begin
        break;
       end;
      end;
      if po2^ = #0 then begin
       if (pb^.c <> nil) and (pb^.c <> pc) then begin
        repeat
         if not pushcontext then begin
          exit
         end;
        until pointer(pb^.t) <> nil;
       end;
       source:= po1;
//       pb:= pc^.branch;
       continue;
      end;
      inc(pb);
     end;  
     break;
    end;
 //   inc(source);
   end;
   writeln('***');
   repeat
    pc^.handle(@info);
    pc:= contextstack[stackindex].context;
    if pc^.next = nil then begin
     outinfo(@info,'after0');
    end;
   until pc^.next <> nil;
   pc:= pc^.next;
   with contextstack[stackindex] do begin
    context:= pc;
//    kind:= ck_none;
   end;
   outinfo(@info,'after1');
  end;
  while stackindex > 0 do begin
   contextstack[stackindex].context^.handle(@info);
   outinfo(@info,'after2');
  end;
  contextstack[0].context^.handle(@info);
  with contextstack[0] do begin
   case kind of
    ck_int32const: begin
     push(@info,real(int32const.value));
    end;   
    ck_flo64const: begin
     push(@info,flo64const.value);
    end;
    ck_int32fact: begin
     int32toflo64(@info,0);
    end;
   end;
  end;   
  outinfo(@info,'after3');
  setlength(ops,opcount);
  result:= ops;
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
  
initialization
 init;
end.
