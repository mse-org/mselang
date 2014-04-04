{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
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
unit handler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 parserglob,typinfo,msetypes,handlerglob;

procedure initparser();

//procedure push(const avalue: real); overload;
//procedure push(const avalue: integer); overload;
//procedure int32toflo64();
 
procedure dummyhandler();

procedure handlenoimplementationerror();

procedure checkstart();
procedure handlenouniterror();
procedure handlenounitnameerror();
procedure handlesemicolonexpected();
procedure handleequalityexpected();
procedure handleidentexpected();
procedure handleillegalexpression();

procedure handleuseserror();
procedure handleuses();
procedure handlenoidenterror();

procedure handleprogbegin();
procedure handleprogblock();

procedure handlecommentend();

procedure handlecheckterminator();
procedure handlestatementblock1();

//procedure handleconst();
//procedure handleconst0();
procedure handleconst3();

//procedure handlevar();
procedure handlevardefstart();
procedure handlevar3();
procedure handlepointervar();

procedure handlenumberentry();
procedure handleint();

procedure handlerange1();
procedure handlerange3();

procedure handlebinnum();
procedure handleoctnum();
procedure handledecnum();
procedure handlehexnum();

procedure posnumber();
procedure negnumber();
procedure handlenumberexpected();

procedure handlefrac();
procedure handleexponent();

procedure handlestatementend();
procedure handleblockend();
procedure handleident();
procedure handleidentpath1a();
procedure handleidentpath2a();
procedure handleidentpath2();
procedure handlevalueidentifier();

procedure handleexp();
procedure handleequsimpexp();

procedure handlemain();
procedure handlekeyword();

procedure handlefactstart();
procedure handlenegfact();
procedure handleaddressfact();
procedure handlefact();
procedure handlemulfact();

procedure handleterm();
procedure handledereference();
procedure handleaddterm();
procedure handlebracketend();
procedure handlesimpexp();
procedure handlesimpexp1();

procedure handleparamsdef0entry();
procedure handleparams0entry();
procedure setconstparam();
procedure setvarparam();
procedure setoutparam();
procedure handleparamdef2();
procedure handleparamsend();
procedure handleprocedureheader();

procedure handlefunctionentry();
procedure handleprocedureentry();

procedure checkfunctiontype();
procedure handleprocedure3();
procedure handleprocedure5a();
procedure handleprocedure6();

procedure handlestatement0entry();
procedure handleleftside();
procedure handlestatementexit();
procedure handleassignmententry();
procedure handleassignment();

procedure handleif0();
procedure handleif();
procedure handlethen();
procedure handlethen0();
procedure handlethen1();
procedure handlethen2();
procedure handleelse0();
procedure handleelse();

procedure handledumpelements();
procedure handleabort();

procedure stringlineenderror();
procedure handlestringstart();
procedure handlestring();
procedure copystring();
procedure copyapostrophe();
procedure handlechar();

implementation
uses
 stackops,msestrings,elements,grammar,sysutils,handlerutils,mseformatstr,
 unithandler,errorhandler,{$ifdef mse_debugparser}parser{$endif},opcode;

const
 stacklinksize = sizeof(frameinfoty);


function typename(const ainfo: contextdataty): string;
var
 po1: ptypedataty;
begin
 po1:= ele.eledataabs(ainfo.datatyp.typedata);
 result:= getenumname(typeinfo(datakindty),ord(po1^.kind));
end;

function typename(const atype: typedataty): string;
begin
 result:= getenumname(typeinfo(datakindty),ord(atype.kind));
end;
  
procedure initparser({var info: parseinfoty});
begin
 writeop(@gotoop); //startup vector 
end;

procedure handleint();
var
 int1,c1: card64;
 po1: pchar;
begin
{$ifdef mse_debugparser}
 outhandle('INT');
{$endif}
outinfo('***');
 with info do begin
  with contextstack[stacktop] do begin
   consumed:= source.po;
   po1:= start.po;
   while (po1^ = '0') do begin
    inc(po1);
   end;
   c1:= 0;
 //  18446744073709551615
   int1:= 20-(consumed-po1);
   if (int1 < 0) or (int1 = 0) and (po1^ > '1') then begin
    errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
   end
   else begin
    while po1 < source.po do begin
     c1:= c1*10 + (ord(po1^)-ord('0'));
     inc(po1);
    end;
    if (int1 = 0) and (c1 < 10000000000000000000) then begin
     errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
    end;
   end;
   stackindex:= stacktop-1;
   d.kind:= ck_const;
   d.indirection:= 0;
   d.datatyp:= sysdatatypes[st_int32];
   d.constval.kind:= dk_integer;
   d.constval.vinteger:= int64(c1);     //todo: handle cardinals and 64 bit
  end;
 end;
end;

procedure handlerange1();
begin
{$ifdef mse_debugparser}
 outhandle('RANGE1');
{$endif}
 with info do begin
  errormessage(err_errintypedef,[]);
  stackindex:= stackindex-1;
  stacktop:= stackindex;
 end;
end;

procedure handlerange3();
begin
{$ifdef mse_debugparser}
 outhandle('RANGE3');
{$endif}
outinfo('***');
 with info do begin
  if stacktop-stackindex = 2 then begin
   if contextstack[stackindex+1].d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[],1);
   end
   else begin
    if contextstack[stackindex+2].d.kind <> ck_const then begin
     errormessage(err_constexpressionexpected,[],2);
    end
    else begin
     if contextstack[stackindex+1].d.constval.kind <> 
              contextstack[stacktop].d.constval.kind then begin
      incompatibletypeserror(contextstack[stackindex+1].d,
                                              contextstack[stacktop].d);
//     errormessage(info,err
     end
     else begin
      with contextstack[stackindex] do begin
       d.kind:= ck_range;
      end;
     end;
    end;
   end;
  end;
//  stacktop:= stackindex;
 end;
end;

procedure handlenumberentry();
begin
{$ifdef mse_debugparser}
 outhandle('NUMBERENTRY');
{$endif}
 with info,contextstack[stacktop].d do begin
  kind:= ck_number;
  number.flags:= [];
 end;
end;

procedure posnumber();
begin
{$ifdef mse_debugparser}
 outhandle('POSNUMBER');
{$endif}
 with info,contextstack[stacktop].d do begin
  if number.flags <> [] then begin
   illegalcharactererror(true);
  end;
  include(number.flags,nuf_pos);
 end;
end;

procedure negnumber();
begin
{$ifdef mse_debugparser}
 outhandle('NEGNUMBER');
{$endif}
 with info,contextstack[stacktop].d do begin
  if number.flags <> [] then begin
   illegalcharactererror(true);
  end;
  include(number.flags,nuf_neg);
 end;
end;

procedure handlebinnum();
var
 c1: card64;
 po1: pchar;
 ch1: char;
begin
{$ifdef mse_debugparser}
 outhandle('BINNUM');
{$endif}
 with info,contextstack[stacktop] do begin
  consumed:= source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
  if consumed-po1 > 64 then begin
   errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
  end
  else begin
   while po1 < source.po do begin
    c1:= c1*2 + (ord(po1^)-ord('0'));
    inc(po1);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(stackindex);
 end;
end;

procedure handleoctnum();
var
 int1: integer;
 c1: card64;
 po1: pchar;
begin
{$ifdef mse_debugparser}
 outhandle('OCTNUM');
{$endif}
 with info,contextstack[stacktop] do begin
  consumed:= source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
//  1777777777777777777777
  int1:= 22-(consumed-po1);
  if (int1 < 0) or (int1 = 0) and (po1^ > '1') then begin
   errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
  end
  else begin
   while po1 < source.po do begin
    c1:= c1*8 + (ord(po1^)-ord('0'));
    inc(po1);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(stackindex);
 end;
end;

procedure handledecnum();
var
 int1: integer;
 c1: card64;
 po1: pchar;
begin
{$ifdef mse_debugparser}
 outhandle('DECNUM');
{$endif}
 with info,contextstack[stacktop] do begin
  consumed:= source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
//  18446744073709551615
  int1:= 20-(consumed-po1);
  if (int1 < 0) or (int1 = 0) and (po1^ > '1') then begin
   errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
  end
  else begin
   while po1 < source.po do begin
    c1:= c1*10 + (ord(po1^)-ord('0'));
    inc(po1);
   end;
   if (int1 = 0) and (c1 < 10000000000000000000) then begin
    errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(stackindex);
 end;
end;

procedure handlehexnum();
var
 c1: card64;
 po1: pchar;
begin
{$ifdef mse_debugparser}
 outhandle('HEXNUM');
{$endif}
 with info,contextstack[stacktop] do begin
  consumed:= source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
  if consumed-po1 > 16 then begin
   errormessage(err_invalidintegerexpression,[],stacktop-stackindex);
  end
  else begin
   while po1 < source.po do begin
    c1:= c1*$10 + hexchars[po1^];
    inc(po1);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(stackindex);
 end;
end;

procedure handlenumberexpected();
begin
{$ifdef mse_debugparser}
 outhandle('NUMBEREXPECTED');
{$endif}
 with info do begin
  illegalcharactererror(false);
//  errormessage(info,stacktop-stackindex,err_numberexpected,[]);
  dec(stackindex);
 end;
end;

const
 floatexps: array[0..32] of double = 
  (1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,
   1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19,
   1e20,1e21,1e22,1e23,1e24,1e25,1e26,1e27,1e28,1e29,1e30,1e31,1e32);
 floatnegexps: array[0..32] of double = 
  (1e0,1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8,1e-9,
   1e-10,1e-11,1e-12,1e-13,1e-14,1e-15,1e-16,1e-17,1e-18,1e-19,
   1e-20,1e-21,1e-22,1e-23,1e-24,1e-25,1e-26,1e-27,1e-28,1e-29,1e-30,1e-31,1e-32);

procedure dofrac(const asource: pchar;
                {out neg: boolean;} out mantissa: qword; out fraclen: integer);
var
 int1: integer;
 lint2: qword;
 po1: pchar;
// fraclen: integer;
 rea1: real;
begin
 with info do begin
  with contextstack[stacktop] do begin
   fraclen:= asource-start.po;
  end;
  stacktop:= stacktop - 1;
  stackindex:= stacktop-1;
  with contextstack[stacktop] do begin
   d.kind:= ck_const;
   d.indirection:= 0;
   d.datatyp:= sysdatatypes[st_float64];
   d.constval.kind:= dk_float;
   lint2:= 0;
   po1:= start.po;
   int1:= asource-po1-1;
   if int1 > 20 then begin
    error(ce_invalidfloat,asource);
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
     error(ce_invalidfloat,asource);
     mantissa:= 0;
//     neg:= false;
    end
    else begin
     mantissa:= lint2;
     {
     with contextstack[stackindex] do begin
      if d.kind <> ck_getfact then begin
       internalerror('H20140403B');
      end;
      neg:= odd(d.getfact.negcount);
      d.getfact.negcount:= 0;
     end;
     }
    end;
   end;
  end;
 end;
end;
 
procedure handlefrac();
var
 mant: qword;
 fraclen: integer;
// neg: boolean;
begin
{$ifdef mse_debugparser}
 outhandle('FRAC');
{$endif}
outinfo('***');
 with info do begin
//  if stacktop > stackindex then begin //no exponent number error otherwise
   dofrac(source.po,{neg,}mant,fraclen);
   with contextstack[stacktop].d.constval do begin
  //  vfloat:= mant/floatexps[fraclen]; //todo: round lsb;   
    vfloat:= mant*floatnegexps[fraclen]; //todo: round lsb;   
{
    if neg then begin
     vfloat:= -vfloat; 
    end;
}
    consumed:= source.po;
   end;
//  end
//  else begin
//   dec(stackindex);
//   stacktop:= stackindex;
//  end;
 end;
end;

procedure handleexponent();
var
 mant: qword;
 exp,fraclen: integer;
 neg: boolean;
 do1: double;
begin
{$ifdef mse_debugparser}
 outhandle('EXPONENT');
{$endif}
outinfo('*****');
 with info do begin
  with contextstack[stacktop].d.number do begin
   exp:= value;
   if nuf_neg in flags then begin
    exp:= -exp;
   end;
  end;
  dec(stacktop,2);
  dofrac(contextstack[stackindex].start.po-1,{neg,}mant,fraclen);
  if fraclen < 0 then begin
   fraclen:= 0;  //no frac 123e4
  end;
  exp:= exp-fraclen;
  with contextstack[stacktop] do begin
   consumed:= source.po; //todo: overflow check
   if exp < 0 then begin
    exp:= -exp;
    do1:= floatnegexps[exp and $1f];
    while exp >= 32 do begin
     do1:= do1*floatnegexps[32];
     exp:= exp - 32;
    end;
   end
   else begin
    do1:= floatexps[exp and $1f];
    while exp >= 32 do begin
     do1:= do1*floatexps[32];
     exp:= exp - 32;
    end;
   end;
   with d.constval do begin
    vfloat:= mant*do1;
{
    if neg then begin
     vfloat:= -vfloat; 
    end;
}
   end;
  end;
 end;
end;

(*
procedure handlenegexponent();
var
 mant: qword;
 exp,fraclen: integer;
 neg: boolean;
 do1: double;
begin
 with info^ do begin
  exp:= contextstack[stacktop].d.constval.vinteger;
  dec(stacktop,3);
  dofrac(info,contextstack[stackindex-1].start.po,neg,mant,fraclen);
  exp:= exp+fraclen;
  with contextstack[stacktop] do begin
   consumed:= source.po; //todo: overflow check
   do1:= floatexps[exp and $1f];
   while exp >= 32 do begin
    do1:= do1*floatexps[32];
    exp:= exp - 32;
   end;
   with d.constval do begin
    vfloat:= mant/do1;
    if neg then begin
     vfloat:= -vfloat; 
    end;
   end;
  end;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'NEGEXPONENT');
{$endif}
end;
*)

const
 mulops: opinfoty = (ops: (nil,nil,@mulint32,@mulflo64);
                     opname: '*');
 
procedure handlemulfact();
begin
{$ifdef mse_debugparser}
 outhandle('MULFACT');
{$endif}
 updateop(mulops);
end;

const
 addops: opinfoty = (ops: (nil,nil,@addint32,@addflo64);
                     opname: '+');

procedure handleaddterm();
 
var 
 dk1: stackdatakindty;
begin
{$ifdef mse_debugparser}
 outhandle('ADDTERM');
{$endif}
 with info,contextstack[stacktop-2] do begin
  if (contextstack[stacktop].d.kind = ck_const) and 
              (d.kind = ck_const) then begin
   dk1:= convertconsts();
   case dk1 of
    sdk_int32: begin
     d.constval.vinteger:= d.constval.vinteger + 
               contextstack[stacktop].d.constval.vinteger;
    end;
    sdk_flo64: begin
     d.constval.vfloat:= d.constval.vfloat + 
                            contextstack[stacktop].d.constval.vfloat;
    end;
    else begin
     operationnotsupportederror(d,contextstack[stacktop].d,'+');
    end;
   end;
   dec(stacktop,2);
   stackindex:= stacktop-1;
  end
  else begin
   updateop(addops);
  end;
 end;
end;

procedure handleterm();
begin
{$ifdef mse_debugparser}
 outhandle('TERM');
outinfo('***');
 with info do begin
  if stacktop-stackindex = 1 then begin
   contextstack[stackindex].d:= contextstack[stackindex+1].d;
  end;
  stacktop:= stackindex;
  dec(stackindex);
 end;
{$endif}
end;

procedure handledereference();
var
 po1: ptypedataty;
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('DEREFERENCE');
{$endif}
 with info,contextstack[stacktop] do begin
  if d.datatyp.indirectlevel <= 0 then begin
   errormessage(err_illegalqualifier,[]);
  end
  else begin
   dec(d.datatyp.indirectlevel);
   dec(d.indirection);
   case d.kind of
    ck_ref: begin
    end;
    ck_const: begin
     if d.constval.kind <> dk_address then begin
      errormessage(err_cannotderefnonpointer,[],stacktop-stackindex);
     end
     else begin
      internalerror('N20140402B'); //todo
     end;
    end;
    ck_fact,ck_subres: begin
     internalerror('H20140404C'); //todo
    end;
    else begin
     internalerror('H20140402A'); //todo
    end;
   end;
(*  
   if currentstatementflags * [stf_rightside,stf_params] = [] then begin
    if kind = ck_const then begin
     pushdata(constval.vaddress,0,dataaddresssize);
     kind:= ck_fact;
    end;
   end
   else begin
    po1:= ele.eledataabs(datatyp.typedata);    
    with additem({info})^ do begin //todo: use table
     case po1^.bytesize of
      1: begin
       op:= @indirect8;
      end;
      2: begin
       op:= @indirect16;
      end;
      4: begin
       op:= @indirect32;
      end;
      else begin
       op:= @indirect;
       d.datasize:= po1^.bytesize;      
      end;
     end;
    end;   
   end;
*)
  end;
 end;
end;

procedure handlefactstart();
begin
{$ifdef mse_debugparser}
 outhandle('FACTSTART');
{$endif}
 with info,contextstack[stacktop] do begin
  stringbuffer:= '';
  d.kind:= ck_getfact;
  with d.getfact do begin
   flags:= [];
//   negcount:= 0;
//   indicount:= 0;
//   derefcount:= 0;
  end;
 end;
end;
(*
procedure handlenegfact();
begin
{$ifdef mse_debugparser}
 outhandle('NEGFACT');
{$endif}
 with info,contextstack[stacktop] do begin
  inc(d.getfact.negcount);
  if d.getfact.indicount <> 0 then begin
   errormessage(err_illegalexpression,[]);
  end;
 end;
end;
*)
procedure handleaddressfact();
begin
{$ifdef mse_debugparser}
 outhandle('ADRESSFACT');
{$endif}
 with info,contextstack[stacktop].d.getfact do begin
  if ff_address in flags then begin
   errormessage(err_cannotassigntoaddr,[]);
  end;
  include(flags,ff_address);
 end;
end;

const
 negops: array[datakindty] of opty = (
 //dk_none, dk_boolean,dk_cardinal,dk_integer,dk_float,
   nil,     nil,       @negcard32, @negint32, @negflo64,
 //dk_kind, dk_address,dk_record,dk_string,dk_array
   nil,     nil,       nil,      nil,      nil
 );

procedure handlefact();
var
 int1: integer;
 c1: card64;
 fl1: factflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('FACT');
{$endif}
outinfo('****');
 with info do begin
  if stackindex < stacktop then begin
   with contextstack[stacktop] do begin
    case d.kind of
     ck_str: begin
      d.kind:= ck_const;
      d.indirection:= 0;
      d.datatyp:= sysdatatypes[st_string8];
      d.constval.kind:= dk_string8;
      d.constval.vstring:= newstring({info});
     end;
     ck_number: begin
      c1:= d.number.value;
      d.kind:= ck_const;
      d.indirection:= 0;
      d.datatyp:= sysdatatypes[st_int32];
      d.constval.kind:= dk_integer;
      d.constval.vinteger:= int64(c1); 
          //todo: handle cardinals and 64 bit
     end;
    end;
   end;
   with contextstack[stackindex] do begin
    fl1:= d.getfact.flags;
    d:= contextstack[stacktop].d;
    if ff_address in fl1 then begin
     case d.kind of
      ck_const: begin
       errormessage(err_cannotaddressconst,[],1);
      end;
      ck_ref: begin
       inc(d.indirection);
       inc(d.datatyp.indirectlevel);
      end;
      ck_fact: begin
       errormessage(err_cannotaddressexp,[],1);
      end;
      else begin
       internalerror('H20140403C');
      end;
     end;
    end;
   end;
  end
  else begin
   errormessage(err_illegalexpression,[],stacktop-stackindex);
  end;
  stacktop:= stackindex;
  dec(stackindex);
 end;
end;

procedure handlenegfact;
var
 po1: ptypedataty;
 op1: opty;
begin
// handlefact;
{$ifdef mse_debugparser}
 outhandle('NEGFACT');
{$endif}
outinfo('****');
 with info,contextstack[stacktop] do begin
  if stacktop-stackindex <> 1 then begin
   internalerror('H20140404A');
   exit;
  end;
  if d.kind = ck_const then begin
   with d.constval do begin
    case kind of
     dk_integer: begin
      vinteger:= -vinteger;
     end;
     dk_float: begin
      vfloat:= -vfloat;
     end;
     else begin
      errormessage(err_negnotpossible,[],1);
     end;
    end;
   end;
  end
  else begin
   if getvalue(1{,false}) then begin
    po1:= ele.eledataabs(d.datatyp.typedata);
    op1:= negops[po1^.kind];
    if op1 = nil then begin
     errormessage(err_negnotpossible,[],1);
    end
    else begin
     writeop(op1);
    end;
   end;
  end;
  contextstack[stackindex].d:= d;
  stacktop:= stackindex;
  dec(stackindex);
 end;
end;

procedure handlesimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('SIMPEXP');
{$endif}
 with info do begin
  contextstack[stacktop-1]:= contextstack[stacktop];
  dec(stacktop);
  stackindex:= stacktop;
  dec(stackindex);
 end;
end;

procedure handlesimpexp1();
begin
{$ifdef mse_debugparser}
 outhandle('SIMPEXP1');
{$endif}
 with info do begin
  if stacktop > stackindex then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end;
  dec(stacktop);
  dec(stackindex);
 end;
end;

procedure handlebracketend();
begin
{$ifdef mse_debugparser}
 outhandle('BRACKETEND');
{$endif}
 with info do begin
  if source.po^ <> ')' then begin
   error(ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source.po);
  end;
  if stackindex < stacktop then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   error(ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
  end;
  dec(stacktop);
  dec(stackindex);
 end;
end;

procedure handleparamsdef0entry();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSDEF0ENTRY');
{$endif}
 with info,contextstack[stackindex].d do begin
  kind:= ck_paramsdef;
  paramsdef.kind:= pk_value;
 end;
end;

procedure handleparams0entry();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMS0ENTRY');
{$endif}
outinfo('***');
 with info do begin
  with contextstack[stackindex].d do begin
   kind:= ck_params;
   params.flagsbefore:= currentstatementflags;
   include(currentstatementflags,stf_params);
  end;
 end;
end;

procedure setconstparam();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTPARAM');
{$endif}
 with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_const;
 end;
end;

procedure setvarparam();
begin
{$ifdef mse_debugparser}
 outhandle('VARPARAM');
{$endif}
outinfo('***');
 with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_var;
 end;
end;

procedure setoutparam();
begin
{$ifdef mse_debugparser}
 outhandle('OUTPARAM');
{$endif}
 with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_out;
 end;
end;

procedure handleparamdef2();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMDEF2');
{$endif}
outinfo('***');
 with info do begin
  if stacktop-stackindex <> 2 then begin
   errormessage(err_typeidentexpected,[]);
  end
  else begin
 {
   with contextstack[stacktop-1] do begin
    d.ident.paramkind:= 
             contextstack[contextstack[stackindex].parent].d.paramsdef.kind;
   end;
  }
  end;
 end;
end;

procedure handleparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
 with info do begin
  with contextstack[stackindex].d do begin
   currentstatementflags:= params.flagsbefore;
  end;
 end;
end;

procedure handleprocedureheader();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDUREHEADER');
{$endif}
 with info do begin
  dec(stackindex);
 end;
end;

procedure handleprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDUREENTRY');
{$endif}
 with info,contextstack[stackindex].d do begin
  kind:= ck_proc;
  proc.flags:= [];
 end;
end;

procedure handlefunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONENTRY');
{$endif}
outinfo('****');
 with info,contextstack[stackindex].d do begin
  kind:= ck_proc;
  proc.flags:= [pf_function];
 end;
end;
(*
procedure handlefunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONENTRY');
{$endif}
end;
*)
(*
procedure handleparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
 with info^ do begin
  if source.po^ <> ')' then begin
   error(info,ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source.po);
  end;
  dec(stackindex);
 end;
end;
*)
procedure handleident();
begin
{$ifdef mse_debugparser}
 outhandle('IDENT');
{$endif}
 with info,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  ident.continued:= false;
 end;
end;

procedure handleidentpath1a();
begin
{$ifdef mse_debugparser}
 outhandle('IDENTPATH1A');
{$endif}
 with info,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  ident.continued:= false;
 end;
end;

procedure handleidentpath2a();
begin
{$ifdef mse_debugparser}
 outhandle('IDENTPATH2A');
{$endif}
 with info,contextstack[stacktop],d do begin
  ident.continued:= true;
 end;
end;

procedure handleidentpath2();
begin
{$ifdef mse_debugparser}
 outhandle('IDENTPATH2');
{$endif}
 errormessage(err_syntax,['identifier'],0);
end;

function tryconvert(var context: contextitemty;
          const dest: ptypedataty; const destindirectlevel: integer): boolean;
var
 po1: ptypedataty;
begin
 po1:= ele.eledataabs(context.d.datatyp.typedata);
 result:= destindirectlevel = context.d.datatyp.indirectlevel;
 if result then begin
  result:= dest^.kind = po1^.kind;
  if not result then begin
   case context.d.kind of
    ck_const: begin
     case dest^.kind of //todo: use table
      dk_float: begin
       case po1^.kind of
        dk_integer: begin //todo: adjust data size
         with context.d,constval do begin
 //         datatyp.typedata:= ele.eledatarel(dest);
          kind:= dk_float;
          vfloat:= vinteger;
         end;
         result:= true;
        end;
       end;
      end;
     end;
    end;
    ck_fact: begin
     case dest^.kind of //todo: use table
      dk_float: begin
       case po1^.kind of
        dk_integer: begin //todo: adjust data size
         with additem({info})^ do begin
          op:= @stackops.int32toflo64;
          with d.op1 do begin
           index0:= 0;
          end;
         end;
         result:= true;
        end;
       end;
      end;
     end;
    end;
    else begin
     internalerror('H20131121B');
    end;
   end;
   if result then begin
    context.d.datatyp.typedata:= ele.eledatarel(dest);
   end;
  end;
 end;
end;
{
procedure t(var a: integer);
begin
 t(1);
end;
}
procedure handlevalueidentifier();
var
 paramco: integer;

 function checknoparam: boolean;
 begin
  result:= paramco = 0;
  if not result then begin
   with info,contextstack[stackindex].d do begin
    errormessage(err_syntax,[';'],1,ident.len);
   end;
  end;
 end;
 
var
 po1: pelementinfoty;
 po2: pointer;
 po3: ptypedataty;
 po4: pfielddataty;
 po5: pelementoffsetty;
 po6: pvardataty;
 po7: pointer;
 lastident: integer;
 idents: identvecty;
 ele1: elementoffsetty;
 int1,int2,int3: integer;
 si1: databytesizety;
 offs1: dataoffsty;
 indirect1: indirectlevelty;
 stacksize1: databytesizety;
 paramco1: integer;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('VALUEIDENTIFIER');
{$endif}
outinfo('***');
 with info do begin
  if findkindelements(1,[ek_var,ek_const,ek_sysfunc,ek_sub,ek_type],
                                vis_max,po1,lastident,idents) then begin
   paramco:= stacktop-stackindex-2-idents.high;
   if paramco < 0 then begin
    paramco:= 0; //no paramsend context
   end;
   po2:= @po1^.data;
   with contextstack[stackindex] do begin
    d.indirection:= 0;
    case po1^.header.kind of
     ek_var: begin
      if checknoparam then begin     
       offs1:= 0;
       ele1:= pvardataty(po2)^.typ;
       if lastident < idents.high then begin
        for int1:= lastident+1 to idents.high do begin //fields
         if not ele.findchild(ele1,idents.d[int1],[ek_field],
                                                     vis_max,ele1) then begin
          identerror(1+int1,err_identifiernotfound);
          goto endlab;
         end;
         po4:= ele.eledataabs(ele1);
         offs1:= offs1 + po4^.offset;
         ele1:= po4^.typ;
        end;
        ele1:= po4^.typ;
        po3:= ele.eledataabs(ele1);
       end;
       d.kind:= ck_ref;
       d.ref.address:= pvardataty(po2)^.address;
       d.datatyp.typedata:= ele1;
       d.datatyp.indirectlevel:= d.ref.address.indirectlevel;
       d.ref.offset:= offs1;
      end;
     end;
     ek_const: begin
      if checknoparam then begin
       d.kind:= ck_const;
       d.indirection:= 0;
       d.datatyp:= pconstdataty(po2)^.val.typ;
       d.constval:= pconstdataty(po2)^.val.d;
      end;
     end;
     ek_sub: begin
      po5:= @pfuncdataty(po2)^.paramsrel;
      paramco1:= paramco;
      if pf_function in pfuncdataty(po2)^.flags then begin
       inc(paramco1);
      end;
      if paramco1 <> pfuncdataty(po2)^.paramcount then begin
       identerror(1,err_wrongnumberofparameters);
      end
      else begin
       for int1:= stackindex+3+idents.high to stacktop do begin
        po6:= ele.eledataabs(po5^);
        with contextstack[int1] do begin
         if vf_paramindirect in po6^.address.flags then begin
          case d.kind of
           ck_const: begin
            if not (vf_const in po6^.address.flags) then begin
             errormessage(err_variableexpected,[],int1-stackindex);
            end
            else begin
            end;
           end;
           ck_ref: begin
            pushinsertaddress(int1-stackindex,false);
           end;
          end;
         end
         else begin
          case d.kind of
           ck_const: begin
            pushinsertconst(int1-stackindex,false);
           end;
           ck_ref: begin
            getvalue(int1-stackindex{,true});
           end;
          end;
         end;
         if d.datatyp.typedata <> po6^.typ then begin
          errormessage(err_incompatibletypeforarg,
                      [int1-stackindex-3,typename(d),
                      typename(ptypedataty(ele.eledataabs(po6^.typ))^)],
                                                           int1-stackindex);
         end;
        end;
        inc(po5);
       end;
       with contextstack[stackindex] do begin //result data
        if pf_function in pfuncdataty(po2)^.flags then begin
         po6:= ele.eledataabs(po5^);
         po3:= ptypedataty(ele.eledataabs(po6^.typ));
         int1:= pushinsertvar(0,false,po3);
         d.fact.datasize:= int1;
         d.kind:= ck_subres;
         d.datatyp.indirectlevel:= po6^.address.indirectlevel-1;
         d.datatyp.typedata:= po6^.typ;        
         with additem()^ do begin //result var param
          op:= @pushstackaddr;
          d.voffset:= -pfuncdataty(po2)^.paramsize+stacklinksize-int1;
         end;
        end
        else begin
         d.kind:= ck_sub;
        end;
       end;
      end;
      if pfuncdataty(po2)^.address = 0 then begin //unresolved header
       linkmark(pfuncdataty(po2)^.links,opcount);
      end;
      with additem()^ do begin
       d.callinfo.ad:= pfuncdataty(po2)^.address-1; //possibly invalid
       if (pfuncdataty(po2)^.nestinglevel = 0) or 
                        (pfuncdataty(po2)^.nestinglevel = funclevel) then begin
        op:= @callop;
        d.callinfo.linkcount:= -1;
       end
       else begin
        op:= @calloutop;
        d.callinfo.linkcount:= funclevel-pfuncdataty(po2)^.nestinglevel-2;
                                                                //for downto 0
       end;
      end;
     end;
     ek_sysfunc: begin
      with contextstack[stackindex] do begin
       d.kind:= ck_sub;
      end;
      with psysfuncdataty(po2)^ do begin
       case func of
        sf_writeln: begin //todo: use open array of constrec
         int2:= stacktop-stackindex-2-idents.high; //count
         stacksize1:= 0;
         int3:= int2+2+stackindex+idents.high;
         for int1:= 3+stackindex+idents.high to int3 do begin
          with contextstack[int1] do begin
           getvalue(int1-stackindex{,true});
           with ptypedataty(ele.eledataabs(d.datatyp.typedata))^ do begin
            push(kind);
            stacksize1:= stacksize1 + alignsize(bytesize);
           end;
          end;
         end;
         with additem()^ do begin
          op:= sysop;
          d.paramcount:= int2;
          d.paramsize:= stacksize1;
         end;
         //todo: handle function
        end;
       end;
      end;
     end;
     ek_type: begin
      if paramco = 0 then begin
       errormessage(err_illegalexpression,[],stacktop-stackindex);
      end
      else begin
       if paramco > 1 then begin
        errormessage(err_closeparentexpected,[],4,-1);
       end
       else begin
        if not tryconvert(contextstack[stacktop],po2,
                                     ptypedataty(po2)^.indirectlevel) then begin
         illegalconversionerror(contextstack[stacktop].d,po2,
                                     ptypedataty(po2)^.indirectlevel);
        end
        else begin
         contextstack[stackindex].d:= contextstack[stacktop].d;
        end;
       end;
      end;
     end;
     else begin
      errormessage(err_wrongtype,[],0);
     end;
    end;
   end;
  end
  else begin
   identerror(1,err_identifiernotfound);
  end;
endlab:
  stacktop:= stackindex;
  dec(stackindex);
 end;
end;

procedure handlestatementend();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENTEND');
{$endif}
 with info,contextstack[stacktop],d do begin
  kind:= ck_end;
 end;
end;

procedure handleblockend();
begin
{$ifdef mse_debugparser}
 outhandle('BLOCKEND');
{$endif}
// with info^ do begin
//  stackindex:= stackindex-2;
// end;
end;
(*
procedure handleparamstart0();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSTART0');
{$endif}
 with info^,contextstack[stacktop] do begin
  parent:= stacktop;
 end;
end;

procedure handleparam();
begin
{$ifdef mse_debugparser}
 outhandle('PARAM');
{$endif}
 with info^,contextstack[stacktop] do begin
  stackindex:= parent+1;
 end;
end;
*)
procedure dummyhandler();
begin
{$ifdef mse_debugparser}
 outhandle('DUMMY');
{$endif}
end;

procedure handlenoimplementationerror();
begin
{$ifdef mse_debugparser}
 outhandle('NOIMPLEMENTATIONERROR');
{$endif}
 tokenexpectederror(tk_implementation);
 with info do begin
  stackindex:= -1;
 end;
end;

procedure checkstart();
begin
{$ifdef mse_debugparser}
 outhandle('CHECKSTART');
{$endif}
end;

procedure handlenouniterror();
begin
{$ifdef mse_debugparser}
 outhandle('NOUNITERROR');
{$endif}
 with info do begin
  tokenexpectederror(tk_unit);
 end;
end;

procedure handlenounitnameerror();
begin
{$ifdef mse_debugparser}
 outhandle('NOUNITNAMEERROR');
{$endif}
 with info do begin
  errormessage(err_syntax,['identifier']);
 end;
end;

procedure handlesemicolonexpected();
begin
{$ifdef mse_debugparser}
 outhandle('SEMICOLONEXPECTED');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
 end;
end;

procedure handleequalityexpected();
begin
{$ifdef mse_debugparser}
 outhandle('EQUALITYEXPECTED');
{$endif}
 with info do begin
  errormessage(err_syntax,['=']);
 end;
end;

procedure handleidentexpected();
begin
{$ifdef mse_debugparser}
 outhandle('IDENTEXPECTED');
{$endif}
 with info do begin
  errormessage(err_identexpected,[],minint,0,erl_fatal);
 end;
end;

procedure handleillegalexpression();
begin
{$ifdef mse_debugparser}
 outhandle('ILLEGALEXPRESSION');
{$endif}
 with info do begin
  errormessage(err_illegalexpression,[]);
  dec(stackindex);
 end;
end;

procedure handleuseserror();
begin
{$ifdef mse_debugparser}
 outhandle('USESERROR');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleuses();
var
 int1,int2: integer;
 offs1: elementoffsetty;
 po1: ppunitinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('USES');
{$endif}
 outinfo('***');
 with info do begin
  offs1:= ele.decelementparent;
  int2:= stacktop-stackindex-1;
  with unitinfo^ do begin
   if us_interfaceparsed in state then begin
    ele.decelementparent;
    setlength(implementationuses,int2);
    po1:= pointer(implementationuses);
   end
   else begin
    setlength(interfaceuses,int2);
    po1:= pointer(interfaceuses);
   end;
  end;
  inc(po1,int2);
  for int1:= stackindex+2 to stacktop do begin
   dec(po1);
   po1^:= loadunit(int1);
   if po1^ = nil then begin
    stopparser:= true;
    break;
   end;
  end;
  ele.elementparent:= offs1;
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlenoidenterror();
begin
{$ifdef mse_debugparser}
 outhandle('NOIDENTERROR');
{$endif}
 errormessage(err_identexpected,[],minint,0,erl_fatal);
end;

procedure handleprogbegin();
begin
{$ifdef mse_debugparser}
 outhandle('PROGBEGIN');
{$endif}
 with info,ops[startupoffset] do begin
  d.opaddress:= opcount-1;
 end;
end;

procedure handleprogblock();
begin
{$ifdef mse_debugparser}
 outhandle('PROGBLOCK');
{$endif}
outinfo('****');
 writeop(nil); 
 checkforwarderrors(info.unitinfo^.forwardlist);
 with info do begin
  dec(stackindex);
 end;
end;

procedure handlecommentend();
begin
{$ifdef mse_debugparser}
 outhandle('COMMENTEND');
{$endif}
{
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
}
end;
(*
procedure handleconst();
begin
{$ifdef mse_debugparser}
 outhandle('CONST');
{$endif}
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleconst0();
begin
{$ifdef mse_debugparser}
 outhandle('CONST0');
{$endif}
// with info^,contextstack[stacktop] do begin
//  dec(stackindex);
//  stacktop:= stackindex;
// end;
end;
*)
procedure handleconst3();
var
 po1: pconstdataty;
begin
{$ifdef mse_debugparser}
 outhandle('CONST3');
{$endif}
outinfo('***');
 with info do begin
  if (stacktop-stackindex <> 2) or 
            (contextstack[stackindex+1].d.kind <> ck_ident) then begin
   internalerror('H20140326C');
   exit;
  end
  else begin
   if contextstack[stacktop].d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[],stacktop-stackindex);
   end
   else begin
    if not ele.addelement(contextstack[stackindex+1].d.ident.ident,vis_max,
                  ek_const,po1) then begin
     identerror(1,err_duplicateidentifier);
    end
    else begin
     with contextstack[stacktop].d do begin
      po1^.val.typ:= datatyp;
      po1^.val.d:= constval;
     end;
    end;
   end;
  end;
  stackindex:= stackindex;
  stacktop:= stackindex;
 end;
end;

(*
procedure handlevar();
begin
{$ifdef mse_debugparser}
 outhandle('VAR');
{$endif}
outinfo('***');
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;
*)

procedure handlevardefstart();
begin
{$ifdef mse_debugparser}
 outhandle('VARDEFSTART');
{$endif}
 with info,contextstack[stackindex] do begin
  d.kind:= ck_var;
  d.vari.indirectlevel:= 0;
//  d.vari.flags:= [];
 end;
end;

procedure handlevar3();
var
 po1,po2: pelementinfoty;
 size1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('VAR3');
{$endif}
outinfo('***');
 with info do begin
  if (stacktop-stackindex < 2) or 
            (contextstack[stackindex+2].d.kind <> ck_fieldtype) then begin
   internalerror('H20140325B');
   exit;
  end;
  po1:= ele.addelement(contextstack[stackindex+1].d.ident.ident,vis_max,ek_var);
  if po1 = nil then begin //duplicate
   identerror(1,err_duplicateidentifier);
  end
  else begin
   with pvardataty(@po1^.data)^ do begin
    typ:= contextstack[stackindex+2].d.typ.typedata;
    po2:= ele.eleinfoabs(typ);
    address.indirectlevel:= contextstack[stackindex+2].d.typ.indirectlevel;
    with ptypedataty(@po2^.data)^ do begin
     address.indirectlevel:= address.indirectlevel+indirectlevel;
     if address.indirectlevel = 0 then begin
      size1:= bytesize;
     end
     else begin
      size1:= pointersize;
     end;
    end;
    if funclevel = 0 then begin
     address.address:= getglobvaraddress(size1);
     address.flags:= [vf_global];
     address.framelevel:= 0;
    end
    else begin
     address.address:= getlocvaraddress(size1)-frameoffset;
     address.flags:= []; //local
     address.framelevel:= funclevel;
    end;
   end;
  end;
 end;
end;

procedure handlepointervar();
begin
{$ifdef mse_debugparser}
 outhandle('POINTERVAR');
{$endif}
 with info,contextstack[stackindex].d.vari do begin
//  if tf_reference in flags then begin
  if indirectlevel > 0 then begin
   errormessage(err_typeidentexpected,[]);
  end;
  inc(indirectlevel);
//  include(flags,tf_reference);
 end;
end;

procedure handleexp();
begin
{$ifdef mse_debugparser}
 outhandle('EXP');
{$endif}
 with info do begin
  contextstack[stacktop-1].d:= contextstack[stacktop].d;
  dec(stacktop);
 end;
end;

procedure handlemain();
begin
{$ifdef mse_debugparser}
 outhandle('MAIN');
{$endif}
 checkforwarderrors(info.unitinfo^.forwardlist);
 with info do begin
  if unitlevel = 1 then begin
   errormessage(err_syntax,['begin']);
  end;
  dec(stackindex);
 end;
end;
{
const
 mainkeywords: array[keywordty] of pcontextty = (
 //kw_0,kw_1,kw_if,kw_begin,    kw_procedure, kw_const,kw_var
   nil, nil, nil,  @progbeginco,@procedure0co,@constco,@varco
  );
 } 
 (*
procedure handlemain1();
var
 po1: pcontextty;
 ident1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('MAIN1');
{$endif}
{
 with info^,contextstack[stacktop],d do begin
  ident1:= ident;
  stacktop:= stackindex;
  if ident1 <= ord(high(keywordty)) then begin
   po1:= mainkeywords[keywordty(ident)];
   if po1 <> nil then begin
    pushcontext(info,po1);
   end;       
  end;
 end;
}
end;
*)
procedure handlekeyword();
begin
{$ifdef mse_debugparser}
 outhandle('KEYWORD');
{$endif}
 with info,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
 end;
end;

const
 cmpequops: opinfoty = (ops: (nil,@cmpequbool,@cmpequint32,@cmpequflo64);
                        opname: '=');

procedure handleequsimpexp();
var
 dk1:stackdatakindty;
begin
{$ifdef mse_debugparser}
 outhandle('EQUSIMPEXP');
{$endif}
outinfo('***');
 with info,contextstack[stacktop-2] do begin
  if (contextstack[stacktop].d.kind = ck_const) and 
                                               (d.kind = ck_const) then begin
   dk1:= convertconsts({info});
   d.constval.kind:= dk_boolean;
   d.datatyp:= sysdatatypes[st_bool8];
   case dk1 of
    sdk_int32: begin
     d.constval.vboolean:= d.constval.vinteger = 
               contextstack[stacktop].d.constval.vinteger;
    end;
    sdk_flo64: begin
     d.constval.vboolean:= d.constval.vfloat = 
                            contextstack[stacktop].d.constval.vfloat;
    end;
    sdk_bool8: begin
     d.constval.vboolean:= d.constval.vboolean =
                            contextstack[stacktop].d.constval.vboolean;
    end;
    else begin
     operationnotsupportederror(d,contextstack[stacktop].d,'=');
    end;
   end;
   dec(stacktop,2);
   stackindex:= stacktop-1;
  end
  else begin
   updateop(cmpequops);
   with info,contextstack[stacktop] do begin
    d.datatyp:= sysdatatypes[resultdatatypes[sdk_bool8]];
   end;
  end;
 end;
end;
{
procedure handlestatement();
begin
 outhandle('HANDLESTATEMENT');
end;
}
{
function tryconvert(var data: contextdataty;
                            const dest: vardestinfoty): boolean;
var
 po1: ptypedataty;
 pi: ^integer;
 i: integer;
begin
// i^:= 123;
 po1:= ele.eledataabs(data.datatyp.typedata);
 result:= dest.typ^.kind = po1^.kind;

end;
}
procedure handleassignmententry();
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENTENTRY');
{$endif}
 with info do begin
//  opshift:= 0;
  include(currentstatementflags,stf_rightside);
 end;
end;

procedure handleassignment();
var
 dest: vardestinfoty;
 typematch,indi: boolean;
 si1: integer;
 int1: integer;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENT');
{$endif}
outinfo('*****');
 with info do begin
  if (stacktop-stackindex = 2) and not errorfla then begin
   if not getaddress(1) or not getvalue(2{,false}) then begin
    goto endlab;
   end;
   with contextstack[stackindex+1].d do begin //address
    typematch:= false;
    indi:= false;
    dest.typ:= ele.eledataabs(datatyp.typedata);
    dec(datatyp.indirectlevel);
    if datatyp.indirectlevel < 0 then begin
     internalerror('H20131126B');
    end
    else begin
     if datatyp.indirectlevel > 0 then begin
      si1:= pointersize;
     end
     else begin
      si1:= dest.typ^.bytesize;
     end;
     case kind of
      ck_const: begin
       if constval.kind <> dk_address then begin
        errormessage(err_argnotassign,[],0);
       end
       else begin
        dest.address:= constval.vaddress;
        typematch:= true;
       end;
      end;
      ck_fact: begin
       dest.address.flags:= [];
       typematch:= true;
       indi:= true;
      end;
      else begin
       internalerror('H20131117A');
       exit;
      end;
     end;
    end;
    dest.address.indirectlevel:= datatyp.indirectlevel;
   end;
   if typematch and not errorfla then begin
    int1:= dest.address.indirectlevel;
    if vf_paramindirect in dest.address.flags then begin
     dec(int1);
    end;
    typematch:= tryconvert(contextstack[stacktop],dest.typ,int1);
    if not typematch then begin
     assignmenterror(contextstack[stacktop].d,dest);
    end
    else begin
    {
     with contextstack[stacktop] do begin
      if d.kind = ck_const then begin
       pushconst(d);
       outcommand([0],'push');
      end;
     end;
     }
     with additem()^ do begin
      d.datasize:= si1;
      if indi then begin
       case si1 of
        1: begin
         op:= @popindirect8;
        end;
        2: begin
         op:= @popindirect16;
        end;
        4: begin
         op:= @popindirect32;
        end;
        else begin
         op:= @popindirect;
        end;
       end;
      end
      else begin
       if vf_global in dest.address.flags then begin
        case si1 of
         1: begin 
          op:= @popglob8;
         end;
         2: begin
          op:= @popglob16;
         end;
         4: begin
          op:= @popglob32;
         end;
         else begin
          op:= @popglob;
         end;
        end;
        d.dataaddress:= dest.address.address;
       end
       else begin
        if vf_paramindirect in dest.address.flags then begin
         case si1 of
          1: begin 
           op:= @poplocindi8;
          end;
          2: begin
           op:= @poplocindi16;
          end;
          4: begin
           op:= @poplocindi32;
          end;
          else begin
           op:= @poplocindi;
          end;
         end;
        end
        else begin
         case si1 of
          1: begin 
           op:= @poploc8;
          end;
          2: begin
           op:= @poploc16;
          end;
          4: begin
           op:= @poploc32;
          end;
          else begin
           op:= @poploc;
          end;
         end;
        end;
        d.locdataaddress.offset:= dest.address.address;
        d.locdataaddress.linkcount:= funclevel-dest.address.framelevel-1;
       end;
      end;
     end;
    end;
   end;
  end
  else begin
   errormessage(err_illegalexpression,[]);
  end;
endlab:
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlestatement0entry();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENT0ENTRY');
{$endif}
 with info do begin
//  opshift:= 0;
  currentstatementflags:= [];
  with contextstack[stacktop].d,statement do begin
   kind:= ck_statement;
//   flags:= [];
  end;
 end;
end;

procedure handleleftside();
begin
{$ifdef mse_debugparser}
 outhandle('HANDLELEFTSIDE');
{$endif}
outinfo('***');
 with info do begin
 end;
end;

procedure handlestatementexit();
begin
{$ifdef mse_debugparser}
 outhandle('HANDLESTATEMENTEXIT');
{$endif}
outinfo('***');
 with info do begin
  if stacktop-stackindex <> 1 then begin
   internalerror('H20140216A');
  end;
  with contextstack[stacktop].d do begin
   case kind of
    ck_subres: begin
     with additem({info})^ do begin
      op:= @popop;
      d.d.vsize:= fact.datasize; //todo: alignment
     end;    
    end;
    ck_sub: begin
    end;
    else begin
     errormessage(err_illegalexpression,[],1);
    end;
   end;
  end;
  dec(stackindex);
 end;
end;

(*
procedure handlestatement1();
 procedure error(const atext: string);
 begin
  parsererror(info,atext+' HANDLESTATEMENT1');
 end; //error
 
begin
 with info^ do begin
 {
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
  }
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlecheckproc();
var
 po2: pfuncdataty;
 po3: pelementoffsetty;
 po4: pvardataty;
 po1: psysfuncdataty;
 int1,int2: integer;
 paramco: integer;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKPROC');
{$endif}
 with info^ do begin
  if findkindelementsdata(info,1,[ek_func],vis_max,po2) then begin
   paramco:= stacktop-stackindex-1-identcount;
   if paramco <> po2^.paramcount then begin
    identerror(info,1,err_wrongnumberofparameters);
   end
   else begin
    po3:= @po2^.paramsrel;
    for int1:= stackindex+3 to stacktop do begin
     po4:= ele.eledataabs(po3^);
     with contextstack[int1] do begin
      if d.datatyp.typedata <> po4^.typ then begin
       errormessage(int1-stackindex,err_incompatibletypeforarg,
         [int1-stackindex-2,typename(d),
                    typename(ptypedataty(ele.eledataabs(po4^.typ))^)]);
      end;
     end;
     inc(po3);
    end;
   end;
   with additem(info)^ do begin
    op:= @callop;
    d.opaddress:= po2^.address-1;
   end;
   dec(stackindex);
   stacktop:= stackindex;
  end
  else begin
   if findkindelementsdata(info,1,[ek_sysfunc],vis_max,po1) then begin
    with po1^ do begin
     case func of
      sf_writeln: begin
       int2:= stacktop-stackindex-2;
       for int1:= 3+stackindex to int2+2+stackindex do begin
        push(info,ptypedataty(
                ele.eledataabs(contextstack[int1].d.datatyp.typedata))^.kind);
       end;
       push(info,int2);
       writeop(info,op);
      end;
     end;
    end;
   end
   else begin
    identerror(info,1,err_identifiernotfound); 
     //todo: use first missing identifier in error message
   end;
   dec(stackindex);
   stacktop:= stackindex;
  end;
 end;
end;
*)
(*
procedure setleftreference();
//called by i1po^:= 123;
var
 pi: ^pinteger;
begin
// pi(^)^:= 123;
{$ifdef mse_debugparser}
 outhandle('SETDESTREFERENCE');
{$endif}
 with info^,contextstack[stackindex].d.statement do begin
  if sf_leftreference in flags then begin
   
  end
  else begin
   include(flags,sf_leftreference);
  end;
 end;
end;
*)
procedure opgoto(const aaddress: dataaddressty);
begin
 with additem({info})^ do begin
  op:= @gotoop;
  d.opaddress:= aaddress;
 end;
end;

procedure handleif0();
begin
{$ifdef mse_debugparser}
 outhandle('IF0');
{$endif}
 with info do begin
  include(currentstatementflags,stf_rightside);
 end;
end;

procedure handleif();
begin
{$ifdef mse_debugparser}
 outhandle('IF');
{$endif}
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen();
begin
{$ifdef mse_debugparser}
 outhandle('THEN');
{$endif}
 tokenexpectederror(tk_then);
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen0();
begin
{$ifdef mse_debugparser}
 outhandle('THEN0');
{$endif}
 with info,contextstack[stacktop] do begin
  if not (ptypedataty(ele.eledataabs(
                         d.datatyp.typedata))^.kind = dk_boolean) then begin
   errormessage(err_booleanexpressionexpected,[],stacktop-stackindex);
  end;
  if d.kind = ck_const then begin
   push(d.constval.vboolean); //todo: use compiletime branch
  end;
 end;
 with additem({info})^ do begin
  op:= @ifop;   
 end;
end;

procedure handlethen1();
begin
{$ifdef mse_debugparser}
 outhandle('THEN1');
{$endif}
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen2();
      //1       2        
begin //boolexp,thenmark
{$ifdef mse_debugparser}
 outhandle('THEN2');
{$endif}
 setcurrentlocbefore(2); //set gotoaddress
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleelse0();
begin
{$ifdef mse_debugparser}
 outhandle('ELSE0');
{$endif}
 opgoto(dummyaddress);
end;

procedure handleelse();
      //1       2        3
begin //boolexp,thenmark,elsemark
{$ifdef mse_debugparser}
 outhandle('ELSE');
{$endif}
 setlocbefore(2,3);      //set gotoaddress for handlethen0
 setcurrentlocbefore(3); //set gotoaddress for handleelse0
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

type
 equalparaminfoty = record
  ref: pfuncdataty;
  match: pfuncdataty;
 end;

procedure checkequalparam(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
var
 po1: pfuncdataty;
 int1: integer;
 par1,parref: pelementoffsetaty;
 offs1: elementoffsetty;
 var1,varref: pvardataty;
begin
 po1:= @aelement^.data;
 with equalparaminfoty(adata) do begin
  if (po1 <> ref) and (po1^.paramcount = ref^.paramcount) then begin
   offs1:= ele.eledataoffset;
   pointer(par1):= @po1^.paramsrel;
   pointer(parref):= @ref^.paramsrel;
   for int1:= 0 to po1^.paramcount-1 do begin
    var1:= pointer(par1^[int1]+offs1);
    varref:= pointer(parref^[int1]+offs1);
    if var1^.typ <> varref^.typ then begin
     exit;
    end;
   end;
   terminate:= true;
   match:= po1;
  end;
 end;
end;
{
procedure testxx(const info1: pparseinfoty); forward;
procedure testxx();
begin
end;
}

procedure checkfunctiontype();
begin
{$ifdef mse_debugparser}
 outhandle('CHECKFUNCTIONTYPE');
{$endif}
outinfo('****');
 with info,contextstack[stackindex-1] do begin
  d.kind:= ck_paramsdef;
  d.paramsdef.kind:= pk_var;
 end;
 with info,contextstack[stackindex] do begin
  d.kind:= ck_ident;
//  d.ident.paramkind:= pk_var;
  d.ident.ident:= resultident;
  with contextstack[parent-1] do begin
   if pf_functiontype in d.proc.flags then begin
    errormessage(err_syntax,[';']);
   end;
   include(d.proc.flags,pf_functiontype);
  end;
 end;
outinfo('****');
end;

procedure handleprocedure3();
var
 po1: pfuncdataty;
 po2: pvardataty;
 po3: ptypedataty;
 po4: pelementoffsetaty;
 int1,int2: integer;
 paramco: integer;
 err1: boolean;
 impl1: boolean;
 parent1: elementoffsetty;
 paramdata: equalparaminfoty;
 par1,parref: pelementoffsetaty;
 eledatabase: ptruint;
 procflags: procflagsty;
// parambase: ptruint;
 si1: integer;
 paramkind1: paramkindty; 

begin
{$ifdef mse_debugparser}
 outhandle('PROCEDURE3');
{$endif}
//0          1     2          3          4    5      6           7
//procedure2,ident,paramsdef3{,paramdef2,name,type}[functiontype,ident]
              //todo: multi level type
outinfo('****');
 with info do begin
  procflags:= contextstack[stackindex-1].d.proc.flags;
  with contextstack[stackindex] do begin
   d.proc.flags:= procflags;
   d.proc.parambase:= locdatapo;
  end;
  if (pf_function in procflags) and 
                      not (pf_functiontype in procflags) then begin
   tokenexpectederror(':');
  end;
  {
  if pf_functiontype in procflags then begin
   if pf_function in procflags then begin
    with contextstack[stacktop-1].d do begin
     kind:= ck_ident;
     ident.paramkind:= pk_var;
     ident.ident:= resultident;
    end;
    paramco:= (stacktop-stackindex-2-2) div 3+1;
   end
   else begin
    errormessage(err_syntax,[';'],stacktop-stackindex-1);    
   end;
  end
  else begin
   if pf_function in procflags then begin
    tokenexpectederror(':');
   end;
  end;
  }
outinfo('****');
  paramco:= (stacktop-stackindex-2) div 3;
  int2:= paramco*(sizeof(pvardataty)+elesizes[ek_var])+elesizes[ek_sub];
  ele.checkcapacity(int2); //absolute addresses can be used
  eledatabase:= ele.eledataoffset();
  po1:= addr(ele.pushelementduplicate(
                      contextstack[stackindex+1].d.ident.ident,
                      vis_max,ek_sub,paramco*sizeof(pvardataty))^.data);
  po1^.paramcount:= paramco;
  po1^.links:= 0;
  po1^.nestinglevel:= funclevel;
  po1^.flags:= procflags;
  po4:= @po1^.paramsrel;
  int1:= 4;
  err1:= false;
  impl1:= us_implementation in unitinfo^.state; //todo: check forward modifier
  for int2:= 0 to paramco-1 do begin
   paramkind1:= contextstack[int1+stackindex-1].d.paramsdef.kind;
   with contextstack[int1+stackindex] do begin
    if ele.addelement(d.ident.ident,vis_max,ek_var,po2) then begin
     po4^[int2]:= elementoffsetty(po2); //absoluteaddress
     with contextstack[int1+stackindex+1] do begin
      if d.kind = ck_fieldtype then begin
       po3:= ele.eledataabs(d.typ.typedata);
       with po2^ do begin
        if impl1 then begin
         address.indirectlevel:= d.typ.indirectlevel;
         if address.indirectlevel > 0 then begin
          si1:= pointersize;
         end
         else begin
          si1:= po3^.bytesize;
         end;
         address.address:= getlocvaraddress(si1);
         address.framelevel:= funclevel+1;
         address.flags:= [vf_param];
         if paramkind1 = pk_const then begin
          if si1 > pointersize then begin
           inc(address.indirectlevel);
           include(address.flags,vf_paramindirect);
          end;
          include(address.flags,vf_const);
         end
         else begin
          if paramkind1 in [pk_var,pk_out] then begin
           inc(address.indirectlevel);
           include(address.flags,vf_paramindirect);
          end;
         end;
        end;
        typ:= d.typ.typedata;
       end;
      end
      else begin
//       identerror(int1+1-stackindex,err_identifiernotfound);
       err1:= true;
      end;
     end;
    end
    else begin
     identerror(int1,err_duplicateidentifier);
     err1:= true;
    end;
   end;
   int1:= int1+3;
  end;
  parent1:= ele.decelementparent; //check params duplicate
  with paramdata do begin
   ref:= po1;
   match:= nil;
  end;
  if ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                            vis_max,@checkequalparam,paramdata) then begin
   err1:= true;
   errormessage(err_sameparamlist,[]);
  end;

  po1^.address:= 0; //init
  if impl1 then begin //implementation
   if funclevel = 0 then begin //todo: check forward modifier
    ele.decelementparent; //interface
    if ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                                vis_max,@checkequalparam,paramdata) then begin
     with paramdata.match^ do begin
      forwardresolve(mark);
      impl:= ele.eledatarel(po1);
      pointer(parref):= @paramsrel;
      pointer(par1):= @po1^.paramsrel;
      for int1:= 0 to paramco-1 do begin
       if ele.eleinfoabs(parref^[int1])^.header.name <> 
                 ele.eleinfoabs(par1^[int1])^.header.name then begin
        errormessage(
             err_functionheadernotmatch,
                [getidentname(ele.eleinfoabs(parref^[int1])^.header.name),
                     getidentname(ele.eleinfoabs(par1^[int1])^.header.name)],
                                      stacktop-stackindex-3*(paramco-int1-1)-1);
       end;
      end;
     end;
    end;
   end;
   ele.elementparent:= parent1;
   inc(funclevel);
   getlocvaraddress(stacklinksize);
   with contextstack[stackindex] do begin
    d.kind:= ck_proc;
    d.proc.frameoffsetbefore:= frameoffset;
    frameoffset:= locdatapo; //todo: nested procedures
    stacktop:= stackindex;
    d.proc.paramsize:= locdatapo - d.proc.parambase;
    po1^.paramsize:= d.proc.paramsize;
    d.proc.error:= err1;
    d.proc.ref:= ele.eledatarel(po1);
    if paramdata.match <> nil then begin
     d.proc.match:= ele.eledatarel(paramdata.match);
    end
    else begin
     d.proc.match:= 0;
    end;
    for int2:= 0 to paramco-1 do begin
     po2:= pointer(po4^[int2]);
     dec(po2^.address.address,frameoffset);
     po4^[int2]:= ptruint(po2)-eledatabase;
    end;
    ele.markelement(d.proc.elementmark); 
   end;
  end
  else begin
   for int2:= 0 to paramco-1 do begin
    dec(po4^[int2],eledatabase); //relative address
   end;
   forwardmark(po1^.mark,source);
  end;
 end;
end;

procedure handleprocedure5a();
var
 po1,po2: pfuncdataty;
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDURE5A');
{$endif}
outinfo('*****');
 with info,contextstack[stackindex-1].d do begin
  proc.varsize:= locdatapo - proc.parambase - proc.paramsize;
  po1:= ele.eledataabs(proc.ref);
  with po1^ do begin
   address:= opcount;
  end;
  if proc.varsize <> 0 then begin
   with additem({info})^ do begin
    op:= @locvarpushop;
    d.stacksize:= proc.varsize;
   end;
  end;
  if proc.match <> 0 then begin
   po2:= ele.eledataabs(proc.ref);    
   po2^.address:= opcount;
   linkresolve(po2^.links,opcount);
  end;
 end;
end;

procedure handleprocedure6();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDURE6');
{$endif}
outinfo('*****');
 with info do begin
  with contextstack[stackindex-1],d do begin
   //todo: check local forward
   ele.decelementparent;
   ele.releaseelement(proc.elementmark); 
                                             //remove local definitions
   if proc.varsize <> 0 then begin
    with additem({info})^ do begin
     op:= @locvarpopop;
     d.stacksize:= proc.varsize;
    end;
   end;
   with additem({info})^ do begin
    op:= @returnop;
    d.stacksize:= proc.paramsize;
   end;
   locdatapo:= proc.parambase;
   frameoffset:= proc.frameoffsetbefore;
  end;
  dec(funclevel);
 end;
end;

procedure handlecheckterminator();
begin
 with info do begin
  errormessage(err_syntax,[';']);
  dec(stackindex);
 end;
end;

procedure handlestatementblock1();
begin
 with info do begin
  errormessage(err_syntax,[';']);
  dec(stackindex);
 end;
end;

procedure handledumpelements();
{$ifdef mse_debugparser}
var
 ar1: msestringarty;
 int1: integer;
{$endif}
begin
{$ifdef mse_debugparser}
 writeln('--ELEMENTS---------------------------------------------------------');
 ar1:= ele.dumpelements;
 for int1:= 0 to high(ar1) do begin
  writeln(ar1[int1]);
 end;
 writeln('-------------------------------------------------------------------');
{$endif}
end;

procedure handleabort();
var
 ar1: msestringarty;
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  stopparser:= true;
  errormessage(err_abort,[]);
 end;
end;

procedure stringlineenderror();
begin
{$ifdef mse_debugparser}
 outhandle('STRINGLINEENDERROR');
{$endif}
 errormessage(err_stringexeedsline,[]);
end;

procedure handlestringstart();
begin
{$ifdef mse_debugparser}
 outhandle('STRINGSTART');
{$endif}
outinfo('****');
 with info do begin
  with contextstack[stacktop] do begin
   d.kind:= ck_str;
   d.str.start:= source.po;
  end;
 end;
end;

procedure handlestring();
begin
{$ifdef mse_debugparser}
 outhandle('STRING');
{$endif}
outinfo('****');
 with info do begin
  dec(stackindex);
 end;
end;

procedure copystring();
begin
{$ifdef mse_debugparser}
 outhandle('COPYSTRING');
{$endif}
outinfo('****');
 with info do begin
  with contextstack[stacktop] do begin
   stringbuffer:= stringbuffer+psubstr(d.str.start,source.po-1);
   d.str.start:= source.po;
  end;
 end;
end;

procedure copyapostrophe();
begin
{$ifdef mse_debugparser}
 outhandle('COPYAPOSTROPHE');
{$endif}
outinfo('****');
 with info do begin
  with contextstack[stacktop] do begin
   stringbuffer:= stringbuffer+'''';
   d.str.start:= source.po;
  end;
 end;
end;

procedure handlechar();
var
 i1,i2: int32;
 s1: string[4];
begin
{$ifdef mse_debugparser}
 outhandle('CHAR');
{$endif}
outinfo('****');
 with info do begin
  with contextstack[stacktop] do begin
   if d.kind <> ck_number then begin
    internalerror('H20140220A');
   end;
   if d.number.value > $10ffff then begin
    errormessage(err_illegalcharconst,[],stacktop-stackindex);
   end
   else begin //todo: optimize
    i2:= 1;
    i1:= d.number.value;
    if i1 < $80 then begin
     s1[0]:= #1;
     s1[1]:= char(i1);
    end
    else begin
     if i1 < $0800 then begin
      s1[0]:= #2;
      s1[1]:= char((i1 shr 6) and %00011111 or %11000000);
      s1[2]:= char(byte(i1) and %00111111 or %10000000);
     end
     else begin
      if i1 < $10000 then begin
       s1[0]:= #3;
       s1[1]:= char((i1 shr 12) and %00001111 or %11100000);
       s1[2]:= char((i1 shr 6) and %00111111 or %10000000);
       s1[3]:= char(byte(i1) and %00111111 or %10000000);
      end
      else begin
       s1[0]:= #4;
       s1[1]:= char((i1 shr 18) and %00000111 or %11110000);
       s1[2]:= char((i1 shr 12) and %00111111 or %10000000);
       s1[3]:= char((i1 shr 6) and %00111111 or %10000000);
       s1[4]:= char(byte(i1) and %00111111 or %10000000);
      end;
     end;
    end;
    stringbuffer:= stringbuffer+s1;
   end;
   dec(stacktop);
  end;
 end;
end;
const
 s = #$ffff;
 f = 1.;
var
 r: real;
type
 a = array[1..2] of integer;
procedure t;
var
 f: real;
begin
 f:= 1.;
end;
end.