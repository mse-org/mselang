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
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$coperators on}
            {$implicitexceptions off}{$endif}
interface
uses
 parserglob,opglob,typinfo,msetypes,handlerglob;

procedure initparser();

//procedure push(const avalue: real); overload;
//procedure push(const avalue: integer); overload;
//procedure int32toflo64();
 
//procedure dummyhandler();

procedure handlenoimplementationerror();

procedure checkstart();
procedure handlenouniterror();
procedure handlenounitnameerror();
procedure handlesemicolonexpected();
procedure handlecloseroundbracketexpected();
procedure handleclosesquarebracketexpected();
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

procedure handleexp();
procedure handleequsimpexp();
procedure handlecommaseprange();

procedure handlemain();
procedure handlekeyword();

procedure handlefactstart();
procedure handlenegfact();
procedure handleaddressfact();
procedure handlefact();
procedure handlemulfact();

procedure handlefact2entry();
//procedure handlefact2();

procedure handleterm();
procedure handledereference();
procedure handleaddterm();
procedure handlebracketend();
procedure handlesimpexp();
procedure handlesimpexp1();

procedure handlestatement0entry();
//procedure handleleftside();
procedure handlestatementexit();
procedure handleassignmententry();
procedure handleassignment();

procedure handledoexpected();
procedure handlewithentry();
procedure handlewith2entry();
//procedure handlewith3entry();
procedure handlewith3();

procedure handledumpelements();
procedure handleabort();
procedure handlenop();

procedure stringlineenderror();
procedure handlestringstart();
//procedure handlestring();
procedure copystring();
procedure copyapostrophe();
procedure copytoken();
procedure handlechar();

implementation
uses
 stackops,msestrings,elements,grammar,sysutils,handlerutils,mseformatstr,
 unithandler,errorhandler,{$ifdef mse_debugparser}parser,{$endif}opcode,
 subhandler,managedtypes,syssubhandler,valuehandler,segmentutils;

procedure initparser({var info: parseinfoty});
begin
 with additem()^ do begin
  setop(op,oc_goto); //startup vector 
 end;
end;

procedure handleint();
var
 int1,c1: card64;
 po1: pchar;
begin
{$ifdef mse_debugparser}
 outhandle('INT');
{$endif}
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
    errormessage(err_invalidfloat,[],stacktop-stackindex);
//    error(ce_invalidfloat,asource);
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
     errormessage(err_invalidfloat,[],stacktop-stackindex);
//     error(ce_invalidfloat,asource);
     mantissa:= 0;
//     neg:= false;
    end
    else begin
     mantissa:= lint2;
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
 mulops: opsinfoty = (ops: (oc_none,oc_none,oc_mulint32,oc_mulflo64);
                     opname: '*');
 
procedure handlemulfact();
begin
{$ifdef mse_debugparser}
 outhandle('MULFACT');
{$endif}
 updateop(mulops);
end;

const
 addops: opsinfoty = (ops: (oc_none,oc_none,oc_addint32,oc_addflo64);
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
      internalerror1(ie_notimplemented,'20140402B'); //todo
     end;
    end;
    ck_fact,ck_subres: begin
     //nothing to do
    end;
    else begin
     internalerror1(ie_notimplemented,'20140402A'); //todo
    end;
   end;
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
 negops: array[datakindty] of opcodety = (
 //dk_none, dk_boolean,dk_cardinal,dk_integer,dk_float,
   oc_none, oc_none,   oc_negcard32, oc_negint32, oc_negflo64,
 //dk_kind, dk_address,dk_record,dk_string,dk_array,dk_class,dk_interface,
   oc_none, oc_none,   oc_none,  oc_none,  oc_none, oc_none, oc_none,
 //dk_enum,dk_enumitem,dk_set
   oc_none,oc_none,    oc_none
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
 with info do begin
  if stackindex < stacktop then begin
   with contextstack[stacktop] do begin
    case d.kind of
     ck_str: begin
      d.kind:= ck_const;
      d.indirection:= 0;
      d.datatyp:= sysdatatypes[st_string8];
      d.constval.kind:= dk_string8;
      d.constval.vstring:= newstring();
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
    fl1:= [];
    if d.kind = ck_getfact then begin
     fl1:= d.getfact.flags;
    end;
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
     {$ifdef mse_checkinternalerror}
      else begin
       internalerror(ie_handler,'20140403C');
      end;
     {$endif}
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

procedure handlefact2entry();
begin
{$ifdef mse_debugparser}
 outhandle('FACT2ENTRY');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if stacktop-stackindex <> 1 then begin
   internalerror(ie_handler,'20140406B');
  end;
 {$endif}
  contextstack[stackindex].d:= contextstack[stackindex+1].d;
  dec(stacktop);
 end;
end;

procedure handlenegfact;
var
 po1: ptypedataty;
// op1: opty;
begin
// handlefact;
{$ifdef mse_debugparser}
 outhandle('NEGFACT');
{$endif}
 with info,contextstack[stacktop] do begin
 {$ifdef mse_checkinternalerror}
  if stacktop-stackindex <> 1 then begin
   internalerror(ie_handler,'20140404A');
  end;
 {$endif}
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
    with additem()^ do begin
     setop(op,negops[po1^.kind]);
     if op.proc = nil then begin
      errormessage(err_negnotpossible,[],1);
     end;
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
   tokenexpectederror(')',erl_error);
//   error(ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source.po);
  end;
  if stackindex < stacktop then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   errormessage(err_expressionexpected,[]);
//   error(ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
  end;
  dec(stacktop);
  dec(stackindex);
 end;
end;

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
  if ident.len = 0 then begin
   errormessage(err_identexpected,[]);
  end;
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
  if ident.len = 0 then begin
   errormessage(err_identexpected,[]);
  end;
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

procedure dummyhandler();
begin
{$ifdef mse_debugparser}
 outhandle('DUMMY');
{$endif}
end;
*)

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

procedure handleclosesquarebracketexpected();
begin
{$ifdef mse_debugparser}
 outhandle('CLOSESQUAREBRACKETEXPECTED');
{$endif}
 tokenexpectederror(']',erl_fatal);
end;

procedure handlecloseroundbracketexpected();
begin
{$ifdef mse_debugparser}
 outhandle('CLOSESROUNDBRACKETEXPECTED');
{$endif}
 tokenexpectederror(')',erl_fatal);
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
// offs1: elementoffsetty;
 po1: ppunitinfoty;
 ar1: elementoffsetarty;
begin
{$ifdef mse_debugparser}
 outhandle('USES');
{$endif}
 with info do begin
  int2:= stacktop-stackindex-1;
  setlength(ar1,int2);
  for int1:= 0 to int2-1 do begin
   if not ele.addelement(contextstack[stackindex+int1+2].d.ident.ident,
                                    ek_uses,[vik_global],ar1[int1]) then begin
    identerror(int1+2,err_duplicateidentifier);
   end;
  end;
//  offs1:= ele.decelementparent;
  with unitinfo^ do begin
   if us_interfaceparsed in state then begin
//    ele.decelementparent;
    setlength(implementationuses,int2);
    po1:= pointer(implementationuses);
   end
   else begin
    setlength(interfaceuses,int2);
    po1:= pointer(interfaceuses);
   end;
  end;
  inc(po1,int2);
  int2:= 0;
  for int1:= stackindex+2 to stacktop do begin
   dec(po1);
   po1^:= loadunit(int1);
   if po1^ = nil then begin
    stopparser:= true;
    break;
   end;
   if ar1[int2] <> 0 then begin
    with pusesdataty(ele.eledataabs(ar1[int2]))^ do begin
     ref:= po1^^.interfaceelement;
    end;
   end;
   inc(int2);
  end;
//  ele.elementparent:= offs1;
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
 with info,getoppo(startupoffset)^ do begin
  par.opaddress:= opcount-1;
 end;
end;

procedure handleprogblock();
begin
{$ifdef mse_debugparser}
 outhandle('PROGBLOCK');
{$endif}
// writeop(nil); //endmark
 handleunitend();
 with additem()^ do begin //endmark, will possibly replaced by goto if there 
  setop(op,oc_none);               //is fini code
 end;
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
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (stacktop-stackindex <> 2) or 
            (contextstack[stackindex+1].d.kind <> ck_ident) then begin
   internalerror(ie_handler,'20140326C');
  end;
 {$endif}
  if contextstack[stacktop].d.kind <> ck_const then begin
   errormessage(err_constexpressionexpected,[],stacktop-stackindex);
  end
  else begin
   if not ele.addelementdata(contextstack[stackindex+1].d.ident.ident,
                                            ek_const,allvisi,po1) then begin
    identerror(1,err_duplicateidentifier);
   end
   else begin
    with contextstack[stacktop].d do begin
     po1^.val.typ:= datatyp;
     po1^.val.d:= constval;
    end;
   end;
  end;
  stackindex:= stackindex;
  stacktop:= stackindex;
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
 handleunitend();
// checkforwarderrors(info.unitinfo^.forwardlist);
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
 cmpequops: opsinfoty = (ops: (oc_none,oc_cmpequbool,oc_cmpequint32,
                        oc_cmpequflo64);
                        opname: '=');

procedure handleequsimpexp();
var
 dk1:stackdatakindty;
begin
{$ifdef mse_debugparser}
 outhandle('EQUSIMPEXP');
{$endif}
 with info,contextstack[stacktop-2] do begin
  if (contextstack[stacktop].d.kind = ck_const) and 
                                               (d.kind = ck_const) then begin
   dk1:= convertconsts();
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

procedure handlecommaseprange();
begin
{$ifdef mse_debugparser}
 outhandle('COMMASEPRANGE');
{$endif}
 with info do begin
  if stacktop-stackindex = 2 then begin
   include(contextstack[stacktop].d.datatyp.flags,tf_upper);
   include(contextstack[stacktop-1].d.datatyp.flags,tf_lower);
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
 typematch,indi,isconst: boolean;
 si1: integer;
 int1: integer;
 offs1: dataoffsty;
 ad1: addressrefty;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENT');
{$endif}
 with info do begin       //todo: use direct move if possible
  if (stacktop-stackindex = 2) and not errorfla then begin
   isconst:= contextstack[stackindex+2].d.kind = ck_const;
   if not getaddress(1,false) or not getvalue(2) then begin
    goto endlab;
   end;
   with contextstack[stackindex+1] do begin //address
    typematch:= false;
    indi:= false;
    dest.typ:= ele.eledataabs(d.datatyp.typedata);
    dec(d.datatyp.indirectlevel);
   {$ifdef mse_checkinternalerror}
    if d.datatyp.indirectlevel < 0 then begin
     internalerror(ie_handler,'20131126B');
    end;
   {$endif}
    if d.datatyp.indirectlevel > 0 then begin
     si1:= pointersize;
    end
    else begin
     si1:= dest.typ^.bytesize;
    end;
    case d.kind of
     ck_const: begin
      if d.constval.kind <> dk_address then begin
       errormessage(err_argnotassign,[],0);
      end
      else begin
       dest.address:= d.constval.vaddress;
       typematch:= true;
      end;
     end;
     ck_fact,ck_subres: begin
      dest.address.flags:= [];
      typematch:= true;
      indi:= true;
     end;
    {$ifdef mse_checkinternalerror}
     else begin
      internalerror(ie_handler,'20131117A');
     end;
    {$endif}
    end;
    dest.address.indirectlevel:= d.datatyp.indirectlevel;
   end;
   if typematch and not errorfla then begin
    int1:= dest.address.indirectlevel;
    if af_paramindirect in dest.address.flags then begin
     dec(int1);
    end;
                         //todo: use destinationaddress directly
    typematch:= tryconvert(stacktop-stackindex,dest.typ,int1);
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
     if (int1 = 0) and (tf_hasmanaged in dest.typ^.flags) then begin
      ad1.base:= ab_stack;
      ad1.offset:= -si1;
      if not isconst then begin
       writemanagedtypeop(mo_incref,dest.typ,ad1);
      end;
      if indi then begin
       dec(ad1.offset,si1);
       ad1.base:= ab_stackref;
      end
      else begin
       ad1.offset:= dest.address.poaddress;
       if af_segment in dest.address.flags then begin
        ad1.base:= ab_segment;
        ad1.segment:= dest.address.segaddress.segment;
       end
       else begin
        ad1.base:= ab_frame;
       end;
      end;
      writemanagedtypeop(mo_decref,dest.typ,ad1);
     end;

     with additem()^ do begin
      par.datasize:= si1;
      if indi then begin
       case si1 of
        1: begin
         setop(op,oc_popindirect8);
        end;
        2: begin
         setop(op,oc_popindirect16);
        end;
        4: begin
         setop(op,oc_popindirect32);
        end;
        else begin
         setop(op,oc_popindirect);
        end;
       end;
      end
      else begin
       if af_segment in dest.address.flags then begin
        case si1 of
         1: begin 
          setop(op,oc_popseg8);
         end;
         2: begin
          setop(op,oc_popseg16);
         end;
         4: begin
          setop(op,oc_popseg32);
         end;
         else begin
          setop(op,oc_popseg);
         end;
        end;
        par.segdataaddress.a:= dest.address.segaddress;
        par.segdataaddress.offset:= 0;
       end
       else begin
        if af_paramindirect in dest.address.flags then begin
         case si1 of
          1: begin 
           setop(op,oc_poplocindi8);
          end;
          2: begin
           setop(op,oc_poplocindi16);
          end;
          4: begin
           setop(op,oc_poplocindi32);
          end;
          else begin
           setop(op,oc_poplocindi);
          end;
         end;
        end
        else begin
         case si1 of
          1: begin 
           setop(op,oc_poploc8);
          end;
          2: begin
           setop(op,oc_poploc16);
          end;
          4: begin
           setop(op,oc_poploc32);
          end;
          else begin
           setop(op,oc_poploc);
          end;
         end;
        end;
        par.locdataaddress.a:= dest.address.locaddress;
        par.locdataaddress.a.framelevel:= sublevel -
                                           dest.address.locaddress.framelevel-1;
        par.locdataaddress.offset:= 0;
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

procedure handledoexpected();
begin
{$ifdef mse_debugparser}
 outhandle('DOEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('do');
  dec(stackindex);
 end;
end;

procedure handlewithentry();
begin
{$ifdef mse_debugparser}
 outhandle('WITHENTRY');
{$endif}
 ele.pushscopelevel();
end;
(*
procedure handlewith3entry();
begin
{$ifdef mse_debugparser}
 outhandle('WITH3ENTRY');
{$endif}
 with info do begin
 end;
end;
*)

procedure handlewith2entry();
var
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('WITH1');
{$endif}
 with info,contextstack[stacktop] do begin
  case d.kind of
   ck_ref: begin
    po1:= ele.eledataabs(d.datatyp.typedata);
    if (d.datatyp.indirectlevel = 0) and 
                         (po1^.kind in [dk_record,dk_class]) then begin

     with pvardataty(ele.addscope(ek_var,d.datatyp.typedata))^ do begin
      address:= d.ref.address;
      address.poaddress:= address.poaddress + d.ref.offset;
      vf.typ:= d.datatyp.typedata;
      vf.next:= 0;
     end;
    end
    else begin
     errormessage(err_expmustbeclassorrec,[]);
    end;
   end;
   ck_none: begin //error in fact
   end;
   else begin
    internalerror1(ie_notimplemented,'20140407A');
   end;
  end;
  stacktop:= stackindex;
 end;
end;

procedure handlewith3();
begin
{$ifdef mse_debugparser}
 outhandle('WITH3');
{$endif}
 with info do begin
  ele.popscopelevel();
  dec(stackindex);
 end;
end;

procedure handlestatement0entry();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENT0ENTRY');
{$endif}
 with info do begin
//  opshift:= 0;
  currentstatementflags-= [stf_rightside,stf_params,
                           stf_leftreference,stf_proccall];
  with contextstack[stacktop].d,statement do begin
   kind:= ck_statement;
//   flags:= [];
  end;
 end;
end;

procedure handlestatementexit();
begin
{$ifdef mse_debugparser}
 outhandle('HANDLESTATEMENTEXIT');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if stacktop-stackindex <> 1 then begin
   internalerror(ie_handler,'20140216A');
  end;
 {$endif}
  with contextstack[stacktop].d do begin
   case kind of
    ck_subres: begin
     with additem()^ do begin
      setop(op,oc_pop);
      par.imm.vsize:= fact.datasize; //todo: alignment
     end;    
    end;
    ck_subcall: begin
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

procedure opgoto(const aaddress: dataaddressty);
begin
 with additem()^ do begin
  op:= @gotoop;
  par.opaddress:= aaddress;
 end;
end;
*)

{
procedure testxx(const info1: pparseinfoty); forward;
procedure testxx();
begin
end;
}

procedure handlecheckterminator();
begin
{$ifdef mse_debugparser}
 outhandle('CHECKTERMINATOR');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
  dec(stackindex);
 end;
end;

procedure handlestatementblock1();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENTBLOCK1');
{$endif}
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
 with info do begin
  dec(stackindex);
 end;
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
  dec(stackindex);
 end;
end;

procedure handlenop();
begin
{$ifdef mse_debugparser}
 outhandle('NOP');
{$endif}
 with additem()^ do begin
  setop(op,oc_nop);
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
 with info do begin
  with contextstack[stacktop] do begin
   d.kind:= ck_str;
   d.str.start:= source.po;
  end;
 end;
end;

procedure copystring();
begin
{$ifdef mse_debugparser}
 outhandle('COPYSTRING');
{$endif}
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
 with info do begin
  with contextstack[stacktop] do begin
   stringbuffer:= stringbuffer+'''';
   d.str.start:= source.po;
  end;
 end;
end;

procedure copytoken();
begin
{$ifdef mse_debugparser}
 outhandle('COPYTOKEN');
{$endif}
 with info,contextstack[stacktop] do begin
  stringbuffer:= stringbuffer+psubstr(d.str.start,source.po);
  dec(stackindex);
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
 with info do begin
  with contextstack[stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_number then begin
    internalerror(ie_handler,'20140220A');
   end;
  {$endif}
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