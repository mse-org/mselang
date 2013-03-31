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
unit msehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseparserglob,typinfo;

procedure push(const info: pparseinfoty; const avalue: real); overload;
procedure push(const info: pparseinfoty; const avalue: integer); overload;
procedure int32toflo64(const info: pparseinfoty; const index: integer);
 
procedure dummyhandler(const info: pparseinfoty);
procedure handledecnum(const info: pparseinfoty);
procedure handlefrac(const info: pparseinfoty);
procedure handlemulfact(const info: pparseinfoty);
procedure handleterm(const info: pparseinfoty);
procedure handleterm1(const info: pparseinfoty);
procedure handlenegterm(const info: pparseinfoty);
procedure handleaddterm(const info: pparseinfoty);
procedure handlebracketend(const info: pparseinfoty);
procedure handlesimpexp(const info: pparseinfoty);
procedure handlesimpexp1(const info: pparseinfoty);
procedure handleln(const info: pparseinfoty);
procedure handleparam(const info: pparseinfoty);
procedure handleparamsend(const info: pparseinfoty);

implementation
uses
 msestackops;

const
 valuecontext = ck_int32const;
 reversestackdata = sdk_int32rev;
 int32kinds = [ck_int32const,ck_int32fact];
 flo64kinds = [ck_flo64const,ck_flo64fact];
 
procedure outhandle(const info: pparseinfoty; const text: string);
begin
 writeln(' *handle* ',text);
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

procedure writeop(const info: pparseinfoty; const operation: opty); inline;
begin
 with additem(info)^ do begin
  op:= operation
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
   contextstack[stackindex].kind:= ck_none;
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
    contextstack[stackindex].kind:= ck_none;
    int2:= -int2;
   end;
   flo64const.value:= int2/floatexps[fraclen]; //todo: round lsb;   
  end;
 end;
 outhandle(info,'FRAC');
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

end.
