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
 mseparserglob,typinfo,msetypes;

procedure initparser;

procedure push(const info: pparseinfoty; const avalue: real); overload;
procedure push(const info: pparseinfoty; const avalue: integer); overload;
procedure int32toflo64(const info: pparseinfoty; const index: integer);
 
procedure dummyhandler(const info: pparseinfoty);

procedure handleconst(const info: pparseinfoty);
procedure handleconst0(const info: pparseinfoty);
procedure handleconst3(const info: pparseinfoty);

procedure handlevar(const info: pparseinfoty);
procedure handlevar0(const info: pparseinfoty);
procedure handlevar3(const info: pparseinfoty);

procedure handledecnum(const info: pparseinfoty);
procedure handlefrac(const info: pparseinfoty);
procedure handleexponent(const info: pparseinfoty);
procedure handlenegexponent(const info: pparseinfoty);

procedure handlestatementend(const info: pparseinfoty);
procedure handleident(const info: pparseinfoty);
procedure handlevalueidentifier(const info: pparseinfoty);

procedure handleexp(const info: pparseinfoty);
procedure handlemain(const info: pparseinfoty);
procedure handleequsimpexp(const info: pparseinfoty);

procedure handlemulfact(const info: pparseinfoty);
procedure handleterm(const info: pparseinfoty);
procedure handleterm1(const info: pparseinfoty);
procedure handlenegterm(const info: pparseinfoty);
procedure handleaddterm(const info: pparseinfoty);
procedure handlebracketend(const info: pparseinfoty);
procedure handlesimpexp(const info: pparseinfoty);
procedure handlesimpexp1(const info: pparseinfoty);
procedure handleln(const info: pparseinfoty);
procedure handleparamstart0(const info: pparseinfoty);
procedure handleparam(const info: pparseinfoty);
procedure handleparamsend(const info: pparseinfoty);
//procedure handlecheckparams(const info: pparseinfoty);

procedure handleassignment(const info: pparseinfoty);
procedure handlestatement1(const info: pparseinfoty);

implementation
uses
 msestackops,msestrings,mseelements,mseexpint,grammar;

const
 valuecontext = ck_bool8const;
 reversestackdata = sdk_bool8rev;
 bool8kinds = [ck_bool8const,ck_bool8fact];
 int32kinds = [ck_int32const,ck_int32fact];
 flo64kinds = [ck_flo64const,ck_flo64fact];

type
 systypesty = (st_integer);
 typedataty = record
  size: integer;
 end;
 ptypedataty = ^typedataty;
 typeinfoty = record
  name: string;
  data: typedataty;
 end;
 constinfoty = record
  name: string;
  data: contextdataty;
 end;
 keywordty = (kw_0,kw_1,kw_if);
  
const
 systypeinfos: array[systypesty] of typeinfoty = (
   (name: 'integer'; data: (size: 4))
  );
 sysconstinfos: array[0..1] of constinfoty = (
   (name: 'false'; data: (kind: ck_bool8const; bool8const: (value: false))),
   (name: 'true'; data: (kind: ck_bool8const; bool8const: (value: true)))
  );
  
function getglobvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
begin
 with info^ do begin
  result:= globdatapo;
  inc(globdatapo,asize);
 end;
end;
 
procedure initparser;
var
 kw1: keywordty;
 ty1: systypesty;
 po1: pelementinfoty;
 int1: integer;
begin
 for kw1:= keywordty(2) to high(keywordty) do begin
  getident(copy(getenumname(typeinfo(keywordty),ord(kw1)),4,bigint));
 end;
 for ty1:= low(systypesty) to high(systypesty) do begin
  with systypeinfos[ty1] do begin
   po1:= addelement(getident(name),ek_type,elesize+sizeof(typedataty));
   ptypedataty(@po1^.data)^:= data;
  end;
 end;
 for int1:= low(sysconstinfos) to high(sysconstinfos) do begin
  with sysconstinfos[int1] do begin
   po1:= addelement(getident(name),ek_context,elesize+sizeof(contextdataty));
   pcontextdataty(@po1^.data)^:= data;
  end;
 end;
end;

function findcontextelement(const aident: contextdataty;
              const akind: contextkindty; out ainfo: pcontextdataty): boolean;
var
 po1: pelementinfoty;
begin
 result:= false;
 if aident.kind = ck_ident then begin
  po1:= findelement(aident.ident);
  if (po1 <> nil) and (po1^.header.kind = ek_context) then begin
   ainfo:= @po1^.data;
   result:= ainfo^.kind = akind;
  end;
 end;
end;

function findkindelement(const aident: contextdataty;
              const akind: elementkindty; out ainfo: pointer): boolean;
var
 po1: pelementinfoty;
begin
 result:= false;
 if aident.kind = ck_ident then begin
  po1:= findelement(aident.ident);
  if (po1 <> nil) and (po1^.header.kind = akind) then begin
   ainfo:= @po1^.data;
   result:= true;
  end;
 end;
end;


procedure parsererror(const info: pparseinfoty; const text: string);
begin
 with info^ do begin
  contextstack[stackindex].d.kind:= ck_error;
  writeln(' ***ERROR*** '+text);
 end; 
end;

procedure identexisterror(const info: contextitemty; const text: string);
begin
 writeln(' ***ERROR*** ident '+lstringtostring(info.start,info.d.identlen)+
                   ' exsts. '+text);
end;

procedure identnotfounderror(const info: contextitemty; const text: string);
begin
 writeln(' ***ERROR*** ident '+lstringtostring(info.start,info.d.identlen)+
                   ' not found. '+text);
end;

procedure wrongidentkinderror(const info: contextitemty; 
       wantedtype: elementkindty; const text: string);
begin
 writeln(' ***ERROR*** wrong ident kind '+lstringtostring(info.start,info.d.identlen)+
                   ', expected '+
         getenumname(typeinfo(elementkindty),ord(wantedtype))+'. '+text);
end;

 
procedure outhandle(const info: pparseinfoty; const text: string);
begin
 writeln(' !!!handle!!! ',text);
end;

procedure outcommand(const info: pparseinfoty; const items: array of integer;
                     const text: string);
var
 int1: integer;
begin
 with info^ do begin
  for int1:= 0 to high(items) do begin
   with contextstack[stacktop+items[int1]].d do begin
    command.write([getenumname(typeinfo(kind),ord(kind)),': ']);
    case kind of
     ck_bool8const: begin
      command.write(bool8const.value);
     end;
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

procedure push(const info: pparseinfoty; const avalue: boolean); overload;
begin
 with additem(info)^ do begin
  op:= @pushbool8;
  d.vbool8:= avalue;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: integer); overload;
begin
 with additem(info)^ do begin
  op:= @pushint32;
  d.vint32:= avalue;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: real); overload;
begin
 with additem(info)^ do begin
  op:= @pushflo64;
  d.vflo64:= avalue;
 end;
end;

procedure pushconst(const info: pparseinfoty; const avalue: contextdataty);
//todo: optimize
begin
 with avalue do begin
  case kind of
   ck_bool8const: begin
    push(info,bool8const.value);
   end;
   ck_int32const: begin
    push(info,int32const.value);
   end;
   ck_flo64const: begin
    push(info,flo64const.value);
   end;
  end;
 end;
end;

procedure int32toflo64(const info: pparseinfoty; const index: integer);
begin
 with additem(info)^ do begin
  op:= @msestackops.int32toflo64;
  with d.op1 do begin
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
  if contextstack[stackindex].d.kind = ck_neg then begin
   contextstack[stackindex].d.kind:= ck_none;
   int2:= -int2;
  end;
  d.int32const.value:= int2;
  d.kind:= ck_int32const;
//  context:= nil;
 end;
 outhandle(info,'CNUM');
end;

const
 floatexps: array[0..32] of double = 
  (1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,
   1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19,
   1e20,1e21,1e22,1e23,1e24,1e25,1e26,1e27,1e28,1e29,1e30,1e31,1e32);

type
 comperrorty = (ce_invalidfloat,ce_expressionexpected,ce_startbracketexpected,
               ce_endbracketexpected);
const
 errormessages: array[comperrorty] of msestring = (
  'Invalid Float',
  'Expression expected',
  '''('' expected',
  ''')'' expected'
 );
 
procedure error(const info: pparseinfoty; const error: comperrorty;
                   const pos: pchar=nil);
begin
 outcommand(info,[],'*ERROR* '+errormessages[error]);
end;

procedure dofrac(const info: pparseinfoty; const asource: pchar;
                 out neg: boolean; out mantissa: qword; out fraclen: integer);
var
 int1: integer;
 lint2: qword;
 po1: pchar;
// fraclen: integer;
 rea1: real;
begin
 with info^ do begin
  with contextstack[stacktop] do begin
   fraclen:= asource-start-1;
  end;
  stacktop:= stacktop - 1;
  stackindex:= stacktop-1;
  with contextstack[stacktop] do begin
   d.kind:= ck_flo64const;
   lint2:= 0;
   po1:= start;
   int1:= asource-po1-1;
   if int1 > 20 then begin
    error(info,ce_invalidfloat,asource);
   end
   else begin
    while po1 < asource do begin
     lint2:= lint2*10 + (ord(po1^)-ord('0'));
     inc(po1);
     if po1^ = '.' then begin
      inc(po1);
     end;
    end;
    if (int1 = 20) and (lint2 < $8AC7230489E80000) then begin 
                                            //todo: check correctness
     error(info,ce_invalidfloat,asource);
     mantissa:= 0;
     neg:= false;
    end
    else begin
     mantissa:= lint2;
     neg:= contextstack[stackindex].d.kind = ck_neg;
     if neg then begin
      contextstack[stackindex].d.kind:= ck_none;
     end;
    end;
   end;
  end;
 end;
end;
 
procedure handlefrac(const info: pparseinfoty);
var
 mant: qword;
 fraclen: integer;
 neg: boolean;
begin
 dofrac(info,info^.source,neg,mant,fraclen);
 with info^,contextstack[stacktop].d do begin
  flo64const.value:= mant/floatexps[fraclen]; //todo: round lsb;   
  if neg then begin
   flo64const.value:= -flo64const.value; 
  end;
  consumed:= source;
 end;
 outhandle(info,'FRAC');
end;

procedure handleexponent(const info: pparseinfoty);
var
 mant: qword;
 exp,fraclen: integer;
 neg: boolean;
 do1: double;
begin
 with info^ do begin
  exp:= contextstack[stacktop].d.int32const.value;
  dec(stacktop,2);
  dofrac(info,contextstack[stackindex].start,neg,mant,fraclen);
  exp:= exp-fraclen;
  with contextstack[stacktop] do begin
   consumed:= source; //todo: overflow check
   do1:= floatexps[exp and $1f];
   while exp >= 32 do begin
    do1:= do1*floatexps[32];
    exp:= exp - 32;
   end;
   d.flo64const.value:= mant*do1;
   if neg then begin
    d.flo64const.value:= -d.flo64const.value; 
   end;
  end;
 end;
 outhandle(info,'EXPONENT');
end;

procedure handlenegexponent(const info: pparseinfoty);
var
 mant: qword;
 exp,fraclen: integer;
 neg: boolean;
 do1: double;
begin
 with info^ do begin
  exp:= contextstack[stacktop].d.int32const.value;
  dec(stacktop,3);
  dofrac(info,contextstack[stackindex-1].start,neg,mant,fraclen);
  exp:= exp+fraclen;
  with contextstack[stacktop] do begin
   consumed:= source; //todo: overflow check
   do1:= floatexps[exp and $1f];
   while exp >= 32 do begin
    do1:= do1*floatexps[32];
    exp:= exp - 32;
   end;
   d.flo64const.value:= mant/do1;
   if neg then begin
    d.flo64const.value:= -d.flo64const.value; 
   end;
  end;
 end;
 outhandle(info,'NEGEXPONENT');
end;

const
 resultdatakinds: array[stackdatakindty] of contextkindty =
           (ck_bool8fact,ck_int32fact,ck_flo64fact,
            ck_bool8fact,ck_int32fact,ck_flo64fact);

function pushvalues(const info: pparseinfoty): stackdatakindty;
//todo: don't convert inplace, stack items will be of variable size
var
 reverse,negative: boolean;
begin
 reverse:= false;
 with info^ do begin
  if (contextstack[stacktop].d.kind in flo64kinds) or 
             (contextstack[stacktop-2].d.kind in flo64kinds) then begin
   result:= sdk_flo64;
   with contextstack[stacktop].d do begin
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
   with contextstack[stacktop-2].d do begin
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
   if contextstack[stacktop].d.kind in bool8kinds then begin
    result:= sdk_bool8;
    with contextstack[stacktop-2].d do begin
     case kind of
      ck_bool8const: begin
       push(info,bool8const.value);
       reverse:= true;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     case kind of
      ck_bool8const: begin
       push(info,bool8const.value);
       reverse:= not reverse;
      end;
     end;
    end;
   end
   else begin
    result:= sdk_int32;
    with contextstack[stacktop-2].d do begin
     case kind of
      ck_int32const: begin
       push(info,int32const.value);
       reverse:= true;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     case kind of
      ck_int32const: begin
       push(info,int32const.value);
       reverse:= not reverse;
      end;
     end;
    end;
   end;
  end;
  if reverse then begin
   result:= stackdatakindty(ord(result)+ord(reversestackdata));
  end;
  dec(stacktop,2);
  with contextstack[stacktop] do begin
   d.kind:= resultdatakinds[result];
   context:= nil;
  end;
  stackindex:= stacktop-1;
 end;
end;

const
 mulops: array[stackdatakindty] of opty =
          (@dummyop,@mulint32,@mulflo64,
           @dummyop,@mulint32,@mulflo64);
 
procedure handlemulfact(const info: pparseinfoty);
begin
 outcommand(info,[-2,0],'*');
 writeop(info,mulops[pushvalues(info)]);
 outhandle(info,'MULFACT');
end;

const
 addops: array[stackdatakindty] of opty =
                    (@dummyop,@addint32,@addflo64,
                     @dummyop,@addint32,@addflo64);

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
 with info^,contextstack[stacktop].d do begin
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
  //ck_none, ck_error,ck_end,  ck_ident,ck_var,  ck_neg, 
    @dummyop,@dummyop,@dummyop,@dummyop,@dummyop,@dummyop,
  //ck_bool8const,ck_int32const,ck_flo64const,
    @dummyop,     @negint32,    @negflo64,
  //ck_boo8fact,ck_int32fact,ck_flo64fact
    @dummyop,   @negint32,   @negflo64
 );

procedure handleterm1(const info: pparseinfoty);
begin
 with info^ do begin
  if stackindex < stacktop then begin
   if contextstack[stackindex].d.kind = ck_neg then begin
    writeop(info,negops[contextstack[stacktop].d.kind]);
   end;
   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   error(info,ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
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
  dec(stackindex);
 end;
 outhandle(info,'SIMPEXP');
end;

procedure handlesimpexp1(const info: pparseinfoty);
begin
 with info^ do begin
  if stacktop > stackindex then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end;
  dec(stacktop);
  dec(stackindex);
 end;
 outhandle(info,'SIMPEXP1');
end;

procedure handlebracketend(const info: pparseinfoty);
begin
 with info^ do begin
  if source^ <> ')' then begin
   error(info,ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source);
  end;
  if stackindex < stacktop then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   error(info,ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
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
   d.kind:= ck_int32fact;
   context:= nil;
  end;
 end;
 outhandle(info,'LN');
end;

procedure handleparamsend(const info: pparseinfoty);
begin
 with info^ do begin
  if source^ <> ')' then begin
   error(info,ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source);
  end;
  dec(stackindex);
 end;
 outhandle(info,'PARAMSEND');
end;

procedure handlecheckparams(const info: pparseinfoty);
begin
 with info^ do begin
  if stacktop = stackindex then begin //no params
  end
  else begin
   dec(stackindex);
   stacktop:= stackindex;
   with contextstack[stacktop] do begin
    d.kind:= ck_int32const;
    context:= nil;
    d.int32const.value:= 42;
   end;  
   dec(stackindex);
  end;
 end;
 outhandle(info,'CHECKPARAMS');
end;

procedure handleident(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  identlen:= source-start;
  ident:= getident(start,identlen);
//  dec(stackindex);
 end;
 outhandle(info,'IDENT');
end;

procedure handlevalueidentifier(const info: pparseinfoty);
var
 po1: pelementinfoty;
 po2: pcontextdataty;
begin
 with info^ do begin
  po1:= findelement(contextstack[stacktop].d.ident);
  dec(stacktop);
  if po1 <> nil then begin
   if po1^.header.kind = ek_context then begin
    po2:= @po1^.data;
    with po2^ do begin
     if kind = ck_var then begin
      with po1^ do begin
       with additem(info)^ do begin
        case varsize of
         1: begin 
          op:= @pushglob1;
         end;
         2: begin
          op:= @pushglob2;
         end;
         4: begin
          op:= @pushglob4;
         end;
         else begin
          op:= @pushglob;
         end;
        end;
        d.address:= varaddress;
        d.size:= varsize;
       end;
      end;
      contextstack[stacktop].d.kind:= ck_int32fact;
     end
     else begin
      if kind in constkinds then begin
       contextstack[stacktop].d:= po2^;
      end
      else begin
       parsererror(info,'wrong kind');
      end;
     end;
    end;
   end;
  end
  else begin
   identnotfounderror(contextstack[stacktop],'valueidentifier');
  end;
  dec(stackindex);
 end;
 outhandle(info,'VALUEIDENTIFIER');
end;

procedure handlestatementend(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop],d do begin
  kind:= ck_end;
 end;
 outhandle(info,'STATEMENTEND');
end;

procedure handleparamstart0(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop] do begin
  parent:= stacktop;
 end;
 outhandle(info,'PARAMSTART0');
end;

procedure handleparam(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop] do begin
  stackindex:= parent+1;
 end;
 outhandle(info,'PARAM');
end;

procedure dummyhandler(const info: pparseinfoty);
begin
 outhandle(info,'DUMMY');
end;

procedure handleconst(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'CONST');
end;

procedure handleconst0(const info: pparseinfoty);
begin
// with info^,contextstack[stacktop] do begin
//  dec(stackindex);
//  stacktop:= stackindex;
// end;
 outhandle(info,'CONST0');
end;

procedure handleconst3(const info: pparseinfoty);
var
 po1: pelementinfoty;
begin
 with info^ do begin
  if (stacktop-stackindex = 3) and (contextstack[stacktop].d.kind = ck_end) and
       (contextstack[stacktop-1].d.kind in constkinds) and
       (contextstack[stacktop-2].d.kind = ck_ident) then begin
   with contextstack[stacktop-2].d do begin
    po1:= addelement(ident,ek_context,elesize+sizeof(contextdataty));
    if po1 = nil then begin
     identexisterror(contextstack[stacktop-2],'CONST3');
    end
    else begin
     pcontextdataty(@po1^.data)^:= contextstack[stacktop-1].d;
    end;
   end;
  end
  else begin
   parsererror(info,'CONST3');
  end;
  stacktop:= stackindex;
 end;
 outhandle(info,'CONST3');
end;


procedure handlevar(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'VAR');
end;

procedure handlevar0(const info: pparseinfoty);
begin
 outhandle(info,'VAR0');
end;

procedure handlevar3(const info: pparseinfoty);
var
 po1,po2: pelementinfoty;
begin
 with info^ do begin
  if (stacktop-stackindex = 3) and (contextstack[stacktop].d.kind = ck_end) and
       (contextstack[stacktop-1].d.kind = ck_ident) and
       (contextstack[stacktop-2].d.kind = ck_ident) then begin
   po1:= addelement(contextstack[stacktop-2].d.ident,ek_context,
                                        elesize+sizeof(contextdataty));
   if po1 = nil then begin
    identexisterror(contextstack[stacktop-2],'VAR3');
   end
   else begin
    if findkindelement(contextstack[stacktop-1].d,ek_type,po2) then begin
     with pcontextdataty(@po1^.data)^ do begin
      kind:= ck_var;
      varsize:= ptypedataty(po2)^.size;
      varaddress:= getglobvaraddress(info,varsize);
     end;
    end
    else begin
     parsererror(info,'type not found. VAR3');
    end;
   end;
  end
  else begin
   parsererror(info,'VAR3');
  end;
  stacktop:= stackindex;
 end;
 outhandle(info,'VAR3');
end;

procedure handleexp(const info: pparseinfoty);
begin
 with info^ do begin
  contextstack[stacktop-1].d:= contextstack[stacktop].d;
  dec(info^.stacktop);
  with contextstack[stacktop] do begin
   if d.kind in constkinds then begin
    pushconst(info,d);
    outcommand(info,[0],'push');
   end;
  end;
 end;
 outhandle(info,'EXP');
end;

procedure handlemain(const info: pparseinfoty);
begin
 with info^ do begin
  dec(stackindex);
 end;
 outhandle(info,'MAIN');
end;

procedure handleequsimpexp(const info: pparseinfoty);
begin
 outcommand(info,[-2,0],'=');
 writeop(info,addops[pushvalues(info)]);
 outhandle(info,'EQUSIMPEXP');
end;

procedure handleassignment(const info: pparseinfoty);
 procedure varexpected;
 begin
  parsererror(info,'variable expected HANDLEASSIGNMENT');
 end; //varexpected
 
var
 po1: pcontextdataty;
begin
 with info^ do begin
  if (stacktop-stackindex > 0) and
         findcontextelement(contextstack[stackindex+1].d,ck_var,po1) then begin
   with po1^ do begin
    with additem(info)^ do begin
     case varsize of
      1: begin 
       op:= @popglob1;
      end;
      2: begin
       op:= @popglob2;
      end;
      4: begin
       op:= @popglob4;
      end;
      else begin
       op:= @popglob;
      end;
     end;
     d.address:= varaddress;
     d.size:= varsize;
    end;
   end;
  end
  else begin
   varexpected;
  end;                  
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlestatement1(const info: pparseinfoty);
 procedure error(const atext: string);
 begin
  parsererror(info,atext+' HANDLESTATEMENT1');
 end; //error
 
begin
 with info^ do begin
  if (stacktop - stackindex = 1) then begin
   with contextstack[stacktop] do begin
    if d.kind = ck_ident then begin
     case d.ident of 
      ord(kw_if): begin
       pushcontext(info,@ifco)
      end;
      else begin
       error('wrong ident');
      end;
     end;
    end
    else begin
     error('not ident');
    end;
   end;
  end
  else begin
   error('stacksize');
  end;
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

end.