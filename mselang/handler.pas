{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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

procedure init;
procedure deinit;
procedure initparser(const info: pparseinfoty);

procedure push(const info: pparseinfoty; const avalue: real); overload;
procedure push(const info: pparseinfoty; const avalue: integer); overload;
procedure int32toflo64(const info: pparseinfoty; const index: integer);
 
procedure dummyhandler(const info: pparseinfoty);

procedure handlenoimplementationerror(const info: pparseinfoty);

procedure checkstart(const info: pparseinfoty);
procedure handlenouniterror(const info: pparseinfoty);
procedure handlenounitnameerror(const info: pparseinfoty);
procedure handlesemicolonexpected(const info: pparseinfoty);
procedure handleidentexpected(const info: pparseinfoty);
procedure handleillegalexpression(const info: pparseinfoty);

procedure handleuseserror(const info: pparseinfoty);
procedure handleuses(const info: pparseinfoty);
procedure handlenoidenterror(const info: pparseinfoty);

procedure handleprogbegin(const info: pparseinfoty);
procedure handleprogblock(const info: pparseinfoty);

procedure handlecommentend(const info: pparseinfoty);

procedure handlecheckterminator(const info: pparseinfoty);
procedure handlestatementblock1(const info: pparseinfoty);

procedure handleconst(const info: pparseinfoty);
procedure handleconst0(const info: pparseinfoty);
procedure handleconst3(const info: pparseinfoty);

procedure handlevar(const info: pparseinfoty);
procedure handlevar1(const info: pparseinfoty);
procedure handlevar3(const info: pparseinfoty);
procedure handlepointervar(const info: pparseinfoty);

procedure handletype(const info: pparseinfoty);
procedure handletypedefstart(const info: pparseinfoty);
procedure handletype3(const info: pparseinfoty);
procedure handlepointertype(const info: pparseinfoty);

procedure handledecnum(const info: pparseinfoty);
procedure handlenumberentry(const info: pparseinfoty);
procedure handlenumber(const info: pparseinfoty);
procedure posnumber(const info: pparseinfoty);
procedure negnumber(const info: pparseinfoty);
procedure handlenumberexpected(const info: pparseinfoty);

procedure handlefrac(const info: pparseinfoty);
procedure handleexponent(const info: pparseinfoty);

procedure handlestatementend(const info: pparseinfoty);
procedure handleblockend(const info: pparseinfoty);
procedure handleident(const info: pparseinfoty);
procedure handleidentpath1a(const info: pparseinfoty);
procedure handleidentpath2a(const info: pparseinfoty);
procedure handleidentpath2(const info: pparseinfoty);
procedure handlevalueidentifier(const info: pparseinfoty);

procedure handleexp(const info: pparseinfoty);
procedure handleequsimpexp(const info: pparseinfoty);

procedure handlemain(const info: pparseinfoty);
procedure handlemain1(const info: pparseinfoty);
procedure handlekeyword(const info: pparseinfoty);

procedure handlemulfact(const info: pparseinfoty);
procedure handleterm(const info: pparseinfoty);
procedure handleaddress(const info: pparseinfoty);
procedure handledereference(const info: pparseinfoty);
procedure handleterm1(const info: pparseinfoty);
procedure handlenegterm(const info: pparseinfoty);
procedure handleaddterm(const info: pparseinfoty);
procedure handlebracketend(const info: pparseinfoty);
procedure handlesimpexp(const info: pparseinfoty);
procedure handlesimpexp1(const info: pparseinfoty);
//procedure handleln(const info: pparseinfoty);

procedure handleparams0(const info: pparseinfoty);
procedure handleparamsend(const info: pparseinfoty);
procedure handleprocedureheader(const info: pparseinfoty);

{
procedure handleparamstart0(const info: pparseinfoty);
procedure handleparam(const info: pparseinfoty);
procedure handleparamsend(const info: pparseinfoty);
}
//procedure handlecheckparams(const info: pparseinfoty);

//procedure handlestatement(const info: pparseinfoty);

procedure handlestatement0entry(const info: pparseinfoty);
procedure handleleftside(const info: pparseinfoty);
//procedure handlestatement1(const info: pparseinfoty);
//procedure handlecheckproc(const info: pparseinfoty);
procedure handleassignmententry(const info: pparseinfoty);
procedure handleassignment(const info: pparseinfoty);
//procedure setleftreference(const info: pparseinfoty);

procedure handleif(const info: pparseinfoty);
procedure handlethen(const info: pparseinfoty);
procedure handlethen0(const info: pparseinfoty);
procedure handlethen1(const info: pparseinfoty);
procedure handlethen2(const info: pparseinfoty);
procedure handleelse0(const info: pparseinfoty);
procedure handleelse(const info: pparseinfoty);

procedure handleprocedure3(const info: pparseinfoty);
procedure handleprocedure6(const info: pparseinfoty);

procedure handledumpelements(const info: pparseinfoty);
procedure handleabort(const info: pparseinfoty);

implementation
uses
 stackops,msestrings,elements,grammar,sysutils,handlerutils,mseformatstr,
 unithandler,errorhandler,{$ifdef mse_debugparser}parser{$endif};

const
// reversestackdata = sdk_bool8rev;
 stacklinksize = 1;

type
 systypety = (st_bool8,st_int32,st_float64);
 systypeinfoty = record
  name: string;
  data: typedataty;
 end;
 sysconstinfoty = record
  name: string;
  ctyp: systypety;
  cval: dataty;
 end;
  
 sysfuncinfoty = record
  name: string;
  data: sysfuncdataty;
 end;
   
const
 mindouble = -1.7e308;
 maxdouble = 1.7e308; //todo: use exact values
 
  //will be replaced by systypes.mla
 systypeinfos: array[systypety] of systypeinfoty = (
   (name: 'bool8'; data: (indirectlevel: 0;
       bitsize: 8; bytesize: 1; datasize: das_8; kind: dk_boolean; dummy: 0)),
   (name: 'int32'; data: (indirectlevel: 0;
       bitsize: 32; bytesize: 4; datasize: das_32;
                 kind: dk_integer; infoint32:(min: minint; max: maxint))),
   (name: 'flo64'; data: (indirectlevel: 0;
       bitsize: 64; bytesize: 8; datasize: das_64;
                 kind: dk_float; infofloat64:(min: mindouble; max: maxdouble)))
  );
 sysconstinfos: array[0..1] of sysconstinfoty = (
   (name: 'false'; ctyp: st_bool8; cval:(kind: dk_boolean; vboolean: false)),
   (name: 'true'; ctyp: st_bool8; cval:(kind: dk_boolean; vboolean: true))
  );
 sysfuncinfos: array[sysfuncty] of sysfuncinfoty = (
   (name: 'writeln'; data: (func: sf_writeln; op: @writelnop))
  );

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
 
function getglobvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
begin
 with info^ do begin
  result:= globdatapo;
  inc(globdatapo,asize);
 end;
end;

function getlocvaraddress(const info: pparseinfoty;
                                        const asize: integer): ptruint;
begin
 with info^ do begin
  result:= locdatapo;
  inc(locdatapo);
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

function insertitem(const info: pparseinfoty; 
                                   const insertad: opaddressty): popinfoty;
begin
 with info^ do begin
  if high(ops) < opcount then begin
   setlength(ops,(high(ops)+257)*2);
  end;
  move(ops[insertad],ops[insertad+1],(opcount-insertad)*sizeof(ops[0]));
  result:= @ops[insertad];
  inc(opcount);
 end;
end;

procedure writeop(const info: pparseinfoty; const operation: opty); inline;
begin
 with additem(info)^ do begin
  op:= operation
 end;
end;

var
 sysdatatypes: array[systypety] of typeinfoty;
 
procedure initparser(const info: pparseinfoty);
begin
 writeop(info,@gotoop); //startup vector 
end;

procedure init;
var
 ty1: systypety;
 sf1: sysfuncty;
 po1: pelementinfoty;
 po2: ptypedataty;
 int1: integer;
begin
 for ty1:= low(systypety) to high(systypety) do begin
  with systypeinfos[ty1] do begin
   po1:= ele.addelement(getident(name),vis_max,ek_type);
   po2:= @po1^.data;
   po2^:= data;
  end;
  sysdatatypes[ty1].typedata:= ele.eleinforel(po1);
//  sysdatatypes[ty1].flags:= [];
 end;
 for int1:= low(sysconstinfos) to high(sysconstinfos) do begin
  with sysconstinfos[int1] do begin
   po1:= ele.addelement(getident(name),vis_max,ek_const);
   with pconstdataty(@po1^.data)^ do begin
    val.d:= cval;
    val.typ:= sysdatatypes[ctyp];
   end;
  end;
 end;
 for sf1:= low(sysfuncty) to high(sysfuncty) do begin
  with sysfuncinfos[sf1] do begin
   po1:= ele.addelement(getident(name),vis_max,ek_sysfunc);
   psysfuncdataty(@po1^.data)^:= data;
  end;
 end;
end;

procedure deinit;
begin
end;

procedure pushinsertconst(const info: pparseinfoty;
                                              const avalue: contextitemty);
begin
 with insertitem(info,avalue.opmark.address)^ do begin
  case avalue.d.constval.kind of
   dk_boolean: begin
    op:= @push8;
    d.d.vboolean:= avalue.d.constval.vboolean;
   end;
   dk_integer: begin
    op:= @push32;
    d.d.vinteger:= avalue.d.constval.vinteger;
   end;
   dk_float: begin
    op:= @push64;
    d.d.vfloat:= avalue.d.constval.vfloat;
   end;
   else begin
    internalerror(info,'P20131121A');
   end;
  end;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: boolean); overload;
begin
 with additem(info)^ do begin
  op:= @push8;
  d.d.vboolean:= avalue;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: integer); overload;
begin
 with additem(info)^ do begin
  op:= @push32;
  d.d.vinteger:= avalue;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: real); overload;
begin
 with additem(info)^ do begin
  op:= @push64;
  d.d.vfloat:= avalue;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: addressinfoty); overload;
begin
 with additem(info)^ do begin
  if vf_global in avalue.flags then begin
   op:= @pushglobaddr;
  end
  else begin
   op:= @pushlocaddr;
  end;
  d.vaddress:= avalue.address;
 end;
end;

procedure push(const info: pparseinfoty; const avalue: datakindty); overload;
begin
 with additem(info)^ do begin
  op:= @pushdatakind;
  d.vdatakind:= avalue;
 end;
end;

procedure pushconst(const info: pparseinfoty; const avalue: contextdataty);
//todo: optimize
begin
 with avalue do begin
  case constval.kind of
   dk_boolean: begin
    push(info,constval.vboolean);
   end;
   dk_integer: begin
    push(info,constval.vinteger);
   end;
   dk_float: begin
    push(info,constval.vfloat);
   end;
   dk_address: begin
    push(info,constval.vaddress);
   end;
  end;
 end;
end;

procedure int32toflo64(const info: pparseinfoty; const index: integer);
begin
 with additem(info)^ do begin
  op:= @stackops.int32toflo64;
  with d.op1 do begin
   index0:= index;
  end;
 end;
end;

procedure setcurrentloc(const info: pparseinfoty; const indexoffset: integer);
begin 
 with info^ do begin
  ops[contextstack[stackindex+indexoffset].opmark.address].d.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setcurrentlocbefore(const info: pparseinfoty;
                                             const indexoffset: integer);
begin 
 with info^ do begin
  ops[contextstack[stackindex+indexoffset].opmark.address-1].d.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setlocbefore(const info: pparseinfoty;
       const destindexoffset,sourceindexoffset: integer);
begin
 with info^ do begin
  ops[contextstack[stackindex+destindexoffset].opmark.address-1].
                                                               d.opaddress:=
         contextstack[stackindex+sourceindexoffset].opmark.address-1;
 end; 
end;

procedure setloc(const info: pparseinfoty;
       const destindexoffset,sourceindexoffset: integer);
begin
 with info^ do begin
  ops[contextstack[stackindex+destindexoffset].opmark.address].
                                                               d.opaddress:=
         contextstack[stackindex+sourceindexoffset].opmark.address-1;
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
{$ifdef mse_debugparser}
 outhandle(info,'DECNUM');
{$endif}
 with info^,contextstack[stacktop] do begin
  po1:= source.po;
  consumed:= po1;
  int2:= 0;
  dec(po1);
  int1:= po1-start.po;
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
  d.kind:= ck_const;
  d.datatyp:= sysdatatypes[st_int32];
  d.constval.kind:= dk_integer;
  d.constval.vinteger:= int2;
 end;
end;

procedure handlenumberentry(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NUMBERENTRY');
{$endif}
 with info^,contextstack[stacktop].d do begin
  kind:= ck_number;
  number.flags:= [];
 end;
end;

procedure posnumber(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'POSNUMBER');
{$endif}
 with info^,contextstack[stacktop].d do begin
  if number.flags <> [] then begin
   illegalcharactererror(info,true);
  end;
  include(number.flags,nuf_pos);
 end;
end;

procedure negnumber(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NEGNUMBER');
{$endif}
 with info^,contextstack[stacktop].d do begin
  if number.flags <> [] then begin
   illegalcharactererror(info,true);
  end;
  include(number.flags,nuf_neg);
 end;
end;

const
 card32decdigits: array[0..9] of card32 =
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

procedure handlenumber(const info: pparseinfoty);
var
 int1: integer;
 c1: card32;
 po1: pchar;
begin
{$ifdef mse_debugparser}
 outhandle(info,'NUMBER');
{$endif}
 with info^,contextstack[stacktop] do begin
  po1:= source.po;
  consumed:= po1;
  c1:= 0;
  dec(po1);
  int1:= po1-start.po;
  if int1 <= high(card32decdigits) then begin
   for int1:= 0 to int1 do begin
    c1:= c1 + (ord(po1^)-ord('0')) * card32decdigits[int1];
    dec(po1);
   end;
  end;
  d.number.value:= c1;
  dec(stackindex);
 end;
end;

procedure handlenumberexpected(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NUMBEREXPECTED');
{$endif}
 with info^ do begin
  illegalcharactererror(info,false);
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
   fraclen:= asource-start.po;
  end;
  stacktop:= stacktop - 1;
  stackindex:= stacktop-1;
  with contextstack[stacktop] do begin
   d.kind:= ck_const;
   d.datatyp:= sysdatatypes[st_float64];
   d.constval.kind:= dk_float;
   lint2:= 0;
   po1:= start.po;
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
{$ifdef mse_debugparser}
 outhandle(info,'FRAC');
{$endif}
 with info^ do begin
//  if stacktop > stackindex then begin //no exponent nuber error otherwise
   dofrac(info,info^.source.po,neg,mant,fraclen);
   with info^,contextstack[stacktop].d.constval do begin
  //  vfloat:= mant/floatexps[fraclen]; //todo: round lsb;   
    vfloat:= mant*floatnegexps[fraclen]; //todo: round lsb;   
    if neg then begin
     vfloat:= -vfloat; 
    end;
    consumed:= source.po;
   end;
//  end
//  else begin
//   dec(stackindex);
//   stacktop:= stackindex;
//  end;
 end;
end;

procedure handleexponent(const info: pparseinfoty);
var
 mant: qword;
 exp,fraclen: integer;
 neg: boolean;
 do1: double;
begin
{$ifdef mse_debugparser}
 outhandle(info,'EXPONENT');
{$endif}
outinfo(info,'*****');
 with info^ do begin
  with contextstack[stacktop].d.number do begin
   exp:= value;
   if nuf_neg in flags then begin
    exp:= -exp;
   end;
  end;
  dec(stacktop,2);
  dofrac(info,contextstack[stackindex].start.po-1,neg,mant,fraclen);
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
    if neg then begin
     vfloat:= -vfloat; 
    end;
   end;
  end;
 end;
end;

(*
procedure handlenegexponent(const info: pparseinfoty);
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
 resultdatakinds: array[stackdatakindty] of datakindty =
            //sdk_bool8,sdk_int32,sdk_flo64
           (dk_boolean,dk_integer,dk_float);
 resultdatatypes: array[stackdatakindty] of systypety =
            //sdk_bool8,sdk_int32,sdk_flo64
           (st_bool8,st_int32,st_float64);

function pushvalues(const info: pparseinfoty): stackdatakindty;
//todo: don't convert inplace, stack items will be of variable size
var
 reverse,negative: boolean;
 kinda,kindb: datakindty;
 po1: pelementinfoty;
begin
 with info^ do begin
//  reverse:= (contextstack[stacktop].d.kind = ck_const) xor 
//                           (contextstack[stacktop-2].d.kind = ck_const);
  reverse:= false;
  po1:= ele.eleinfoabs(contextstack[stacktop].d.datatyp.typedata);
  kinda:= ptypedataty(@po1^.data)^.kind;
  po1:= ele.eleinfoabs(contextstack[stacktop-2].d.datatyp.typedata);
  kindb:= ptypedataty(@po1^.data)^.kind;
  if (kinda = dk_float) or (kindb = dk_float) then begin
   result:= sdk_flo64;
   with contextstack[stacktop-2],d do begin
    if kind = ck_const then begin
     with insertitem(info,opmark.address)^ do begin
      op:= @push64;
      case constval.kind of
       dk_integer: begin
        d.d.vfloat:= real(constval.vinteger);
       end;
       dk_float: begin
        d.d.vfloat:= constval.vfloat;
       end;
      end;
     end;
    end
    else begin //ck_fact
     case kinda of
      dk_integer: begin
       with insertitem(info,opmark.address)^ do begin
        op:= @stackops.int32toflo64;
        with d.op1 do begin
         index0:= 0;
        end;
       end;
      end;
     end;
    end;
   end;
   with contextstack[stacktop].d do begin
    if kind = ck_const then begin
     case kinda of
      dk_integer: begin
       push(info,real(constval.vinteger));
      end;
      dk_float: begin
       push(info,real(constval.vfloat));
       reverse:= not reverse;
      end;
     end;
    end
    else begin
     case kinda of
      dk_integer: begin
        int32toflo64(info,0);
      end;
     end;
    end;
   end;
  end
  else begin
   if kinda = dk_boolean then begin
    result:= sdk_bool8;
    with contextstack[stacktop-2],d do begin
     if kind = ck_const then begin
      case kindb of
       dk_boolean: begin
        with insertitem(info,opmark.address)^ do begin
         op:= @push8;
         d.d.vboolean:= constval.vboolean;
        end;        
//        push(info,constval.vboolean);
       end;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     if kind = ck_const then begin
      case kinda of
       dk_boolean: begin
        push(info,constval.vboolean);
       end;
      end;
     end;
    end;
   end
   else begin
    result:= sdk_int32;
    with contextstack[stacktop-2],d do begin
     if kind = ck_const then begin
      with insertitem(info,opmark.address)^ do begin
       case kindb of
        dk_integer: begin
         op:= @push32;
         d.d.vinteger:= constval.vinteger;
        end;
       end;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     if kind = ck_const then begin
      case kinda of
       dk_integer: begin
        push(info,constval.vinteger);
       end;
      end;
     end;
    end;
   end;
  end;
//  if reverse then begin
//   result:= stackdatakindty(ord(result)+ord(reversestackdata));
//  end;
  dec(stacktop,2);
  with contextstack[stacktop] do begin
   d.kind:= ck_fact;
   d.datatyp:= sysdatatypes[resultdatatypes[result]];
   context:= nil;
  end;
  stackindex:= stacktop-1;
 end;
end;

const
 mulops: array[stackdatakindty] of opty =
          (@dummyop,@mulint32,@mulflo64);
 
procedure handlemulfact(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'MULFACT');
{$endif}
 outcommand(info,[-2,0],'*');
 writeop(info,mulops[pushvalues(info)]);
end;

const
 addops: array[stackdatakindty] of opty =
                    (@dummyop,@addint32,@addflo64);

procedure handleaddterm(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ADDTERM');
{$endif}
 with info^ do begin
  if (contextstack[stacktop].d.kind = ck_const) and 
                (contextstack[stacktop-2].d.kind = ck_const) then begin
   case contextstack[stacktop].d.constval.kind of
    dk_float: begin
     with contextstack[stacktop-2],d,constval do begin
      case kind of
       dk_float: begin
        vfloat:= vfloat + contextstack[stacktop].d.constval.vfloat;
       end;
       dk_integer: begin
        vfloat:= vinteger + contextstack[stacktop].d.constval.vfloat;
        kind:= dk_float;
        datatyp:= contextstack[stacktop].d.datatyp;
       end;
       else begin
        incompatibletypeserror(info,contextstack[stacktop-2].d,
                                            contextstack[stacktop].d);
       end;
      end;
     end;
    end;
    dk_integer: begin
     with contextstack[stacktop-2].d,constval do begin
      case kind of
       dk_integer: begin
        vinteger:= vinteger + contextstack[stacktop].d.constval.vinteger;
       end;
       dk_float: begin
        vfloat:= vfloat + contextstack[stacktop].d.constval.vfloat;
        kind:= dk_float;
        datatyp:= contextstack[stacktop].d.datatyp;
       end;
       else begin
        incompatibletypeserror(info,contextstack[stacktop-2].d,
                                            contextstack[stacktop].d);
       end;
      end;
     end;
    end;
    else begin
     operationnotsupportederror(info,contextstack[stacktop-2].d,
                                            contextstack[stacktop].d,'+');
    end;
   end;
   dec(stacktop,2);
   stackindex:= stacktop-1;
  end
  else begin
   outcommand(info,[-2,0],'+');
   writeop(info,addops[pushvalues(info)]);
  end;
 end;
end;

procedure handleterm(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'TERM');
{$endif}
 dec(info^.stacktop);
 info^.stackindex:= info^.stacktop;
end;

procedure handleaddress(const info: pparseinfoty);
var
 po1: pelementinfoty;
 po2: pvardataty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'ADDRESS');
{$endif}
 with info^ do begin
  if findkindelements(info,1,[ek_var],vis_max,po1) then begin
   po2:= @po1^.data;
   inc(info^.stackindex);
   with contextstack[stackindex] do begin
    d.kind:= ck_const;
    d.datatyp.typedata:= po2^.typ;
//    d.datatyp.flags:= [tf_reference];
    with d.constval do begin
     kind:= dk_address;
     vaddress:= po2^.address;
     inc(vaddress.indirectlevel);
     d.datatyp.indirectlevel:= vaddress.indirectlevel;
    end;
   end;
  end
  else begin
   errormessage(info,-1,err_varidentexpected,[]);
   dec(info^.stackindex);
  end;
 end;
 info^.stacktop:= info^.stackindex;
end;

procedure pushdata(const info: pparseinfoty; 
         const flags: varflagsty;
         const address: dataaddressty; const size: databytesizety);
begin
 with additem(info)^ do begin //todo: use table
  if vf_global in flags then begin
   case size of
    1: begin 
     op:= @pushglob8;
    end;
    2: begin
     op:= @pushglob16;
    end;
    4: begin
     op:= @pushglob32;
    end;
    else begin
     op:= @pushglob;
    end;
   end;
   d.dataaddress:= address;
  end
  else begin
   case size of
    1: begin 
     op:= @pushloc8;
    end;
    2: begin
     op:= @pushloc16;
    end;
    4: begin
     op:= @pushloc32;
    end;
    else begin
     op:= @pushloc;
    end;
   end;
   d.count:= address - info^.frameoffset;
  end;
  d.datasize:= size;
 end;
end;

procedure handledereference(const info: pparseinfoty);
var
 po1: ptypedataty;
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle(info,'DEREFERENCE');
{$endif}
 with info^,contextstack[stacktop].d do begin
 {
  int1:= -1;
  po1:= ele.eledataabs(datatyp.typedata);
  if po1^.kind = dk_reference then begin
   int1:= po1^.indirectlevel;
  end;
  if tf_reference in datatyp.flags then begin
   inc(int1);
  end;
  }
  //todo: handle const
  if datatyp.indirectlevel <= 0 then begin
   errormessage(info,-1,err_illegalqualifier,[]);
  end
  else begin
   dec(datatyp.indirectlevel);
   if currentstatementflags * [stf_rightside,stf_params] = [] then begin
    if kind = ck_const then begin
     pushdata(info,constval.vaddress.flags,constval.vaddress.address,
                                                           dataaddresssize);
//     push(info,constval.vaddress);
     kind:= ck_fact;
    end;
   end
   else begin
    po1:= ele.eledataabs(datatyp.typedata);
    with additem(info)^ do begin //todo: use table
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
  end;
 end;
end;

procedure handlenegterm(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NEGTERM');
{$endif}
 with info^,contextstack[stacktop].d do begin
  if kind = ck_none then begin
   kind:= ck_neg;
  end
  else begin
   kind:= ck_none;
  end;
 end;
end;

const
 negops: array[datakindty] of opty = (
 //dk_none, dk_boolean,dk_cardinal,dk_integer,dk_float,
   @dummyop,@dummyop,  @negcard32, @negint32, @negflo64,
 //dk_kind, dk_address,dk_record
   @dummyop,@dummyop,  @dummyop
 );

procedure handleterm1(const info: pparseinfoty);
var
 po1: ptypedataty;
 bo1: boolean;
begin
{$ifdef mse_debugparser}
 outhandle(info,'TERM1');
{$endif}
 with info^ do begin
  if stackindex < stacktop then begin
   with contextstack[stackindex] do begin
    bo1:= d.kind = ck_neg;
    d:= contextstack[stacktop].d;
    if bo1 then begin
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
         errormessage(info,1,err_negnotpossible,[]);
        end;
       end;
      end;
     end
     else begin
      po1:= ele.eledataabs(d.datatyp.typedata);
      writeop(info,negops[po1^.kind]);
     end;
    end;
   end;
//   contextstack[stacktop-1]:= contextstack[stacktop];
  end
  else begin
   error(info,ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
  end;
  dec(stacktop);
  dec(stackindex);
 end;
end;

procedure handlesimpexp(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'SIMPEXP');
{$endif}
 with info^ do begin
  contextstack[stacktop-1]:= contextstack[stacktop];
  dec(info^.stacktop);
  info^.stackindex:= info^.stacktop;
  dec(stackindex);
 end;
end;

procedure handlesimpexp1(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'SIMPEXP1');
{$endif}
 with info^ do begin
  if stacktop > stackindex then begin
   contextstack[stacktop-1]:= contextstack[stacktop];
  end;
  dec(stacktop);
  dec(stackindex);
 end;
end;

procedure handlebracketend(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'BRACKETEND');
{$endif}
 with info^ do begin
  if source.po^ <> ')' then begin
   error(info,ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source.po);
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
end;

procedure handleparams0(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PARAMS0');
{$endif}
 with info^ do begin
  with contextstack[stackindex].d do begin
   kind:= ck_params;
   params.flagsbefore:= currentstatementflags;
   include(currentstatementflags,stf_params);
  end;
 end;
end;

procedure handleparamsend(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PARAMSEND');
{$endif}
 with info^ do begin
  with contextstack[stackindex].d do begin
   currentstatementflags:= params.flagsbefore;
  end;
 end;
end;

procedure handleprocedureheader(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PROCEDUREHEADER');
{$endif}
 with info^ do begin
  dec(stackindex);
 end;
end;

(*
procedure handleparamsend(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PARAMSEND');
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
procedure handleident(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'IDENT');
{$endif}
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  ident.continued:= false;
 end;
end;

procedure handleidentpath1a(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'IDENTPATH1A');
{$endif}
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  ident.continued:= false;
 end;
end;

procedure handleidentpath2a(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'IDENTPATH2A');
{$endif}
 with info^,contextstack[stacktop],d do begin
  ident.continued:= true;
 end;
end;

procedure handleidentpath2(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'IDENTPATH2');
{$endif}
 errormessage(info,0,err_identifierexpected,[]);
end;

function tryconvert(const info: pparseinfoty; var context: contextitemty;
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
         with additem(info)^ do begin
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
     internalerror(info,'P20131121B');
    end;
   end;
   if result then begin
    context.d.datatyp.typedata:= ele.eledatarel(dest);
   end;
  end;
 end;
end;

procedure handlevalueidentifier(const info: pparseinfoty);
var
 paramco: integer;

 function checknoparam: boolean;
 begin
  result:= paramco = 0;
  if not result then begin
   with info^,contextstack[stackindex].d do begin
    errormessage(info,1,err_semicolonexpected,[],ident.len);
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
 lastident: integer;
 idents: identvecty;
 ele1: elementoffsetty;
 int1,int2: integer;
 si1: databytesizety;
 addr1: dataaddressty;
 indirect1: indirectlevelty;
// fl1: typeflagsty;
 opshift: opaddressty;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle(info,'VALUEIDENTIFIER');
{$endif}
 with info^ do begin
  if findkindelements(info,1,[ek_var,ek_const,ek_sysfunc,ek_func,ek_type],
                                vis_max,po1,lastident,idents) then begin
   paramco:= stacktop-stackindex-2-idents.high;
   if paramco < 0 then begin
    paramco:= 0; //no paramsend context
   end;
   po2:= @po1^.data;
   case po1^.header.kind of
    ek_var: begin
     if checknoparam then begin     
      addr1:= pvardataty(po2)^.address.address;
      ele1:= pvardataty(po2)^.typ;
      indirect1:= pvardataty(po2)^.address.indirectlevel;
      if indirect1 > 0 then begin
       si1:= pointersize;
      end
      else begin
       if lastident < idents.high then begin
        for int1:= lastident+1 to idents.high do begin //fields
         if not ele.findchild(ele1,idents.d[int1],[ek_field],
                                                     vis_max,ele1) then begin
          identerror(info,1+int1,err_identifiernotfound);
          goto endlab;
         end;
         po4:= ele.eledataabs(ele1);
         addr1:= addr1 + po4^.offset;
         ele1:= po4^.typ;
        end;
        ele1:= po4^.typ;
        po3:= ele.eledataabs(ele1);
        si1:= po3^.bytesize;      
       end
       else begin
        si1:= ptypedataty(ele.eledataabs(pvardataty(po2)^.typ))^.bytesize;
       end;
      end;
      if currentstatementflags * [stf_rightside,stf_params] <> [] then begin
       pushdata(info,pvardataty(po2)^.address.flags,addr1,si1);
       with contextstack[stackindex].d do begin
        kind:= ck_fact;
        datatyp.typedata:= ele1;
        datatyp.indirectlevel:= indirect1;
       end;
      end
      else begin  //todo: handle dereference and the like
       with contextstack[stackindex].d do begin
        kind:= ck_const;
        datatyp.typedata:= ele1;
        datatyp.indirectlevel:= indirect1+1;
        constval.kind:= dk_address;
        constval.vaddress.address:= addr1;
        constval.vaddress.flags:= pvardataty(po2)^.address.flags;
       end;
      end;
     end;
    end;
    ek_const: begin
     if checknoparam then begin
      with contextstack[stackindex].d do begin
       kind:= ck_const;
       datatyp:= pconstdataty(po2)^.val.typ;
       constval:= pconstdataty(po2)^.val.d;
      end;
     end;
    end;
    ek_func: begin
     if paramco <> pfuncdataty(po2)^.paramcount then begin
      identerror(info,1,err_wrongnumberofparameters);
     end
     else begin
      po5:= @pfuncdataty(po2)^.paramsrel;
      opshift:= 0;
      for int1:= stackindex+3+idents.high to stacktop do begin
       po6:= ele.eledataabs(po5^);
       with contextstack[int1] do begin
        if d.kind = ck_const then begin
         opmark.address:= opmark.address + opshift;
         inc(opshift);
         pushinsertconst(info,contextstack[int1]);
        end;
        if d.datatyp.typedata <> po6^.typ then begin
         errormessage(info,int1-stackindex,err_incompatibletypeforarg,
           [int1-stackindex-3,typename(d),
                      typename(ptypedataty(ele.eledataabs(po6^.typ))^)]);
        end;
       end;
       inc(po5);
      end;
     end;
     if pfuncdataty(po2)^.address = 0 then begin //unresolved header
      linkmark(info,pfuncdataty(po2)^.links,opcount);
     end;
     with additem(info)^ do begin
      op:= @callop;
      d.opaddress:= pfuncdataty(po2)^.address-1; //possibly invalid
     end;
    end;
    ek_sysfunc: begin
     with psysfuncdataty(po2)^ do begin
      case func of
       sf_writeln: begin
        int2:= stacktop-stackindex-2-idents.high;
        opshift:= 0;
        for int1:= 3+stackindex+idents.high to 
                                 int2+2+stackindex+idents.high do begin
         with contextstack[int1] do begin
          if d.kind = ck_const then begin
           opmark.address:= opmark.address + opshift;
           inc(opshift);
           pushinsertconst(info,contextstack[int1]);
          end;
          push(info,ptypedataty(ele.eledataabs(d.datatyp.typedata))^.kind);
         end;
        end;
        push(info,int2);
        writeop(info,op);
        //todo: handle function
       end;
      end;
     end;
    end;
    ek_type: begin
     if paramco = 0 then begin
      errormessage(info,stacktop-stackindex,err_illegalexpression,[]);
     end
     else begin
      if paramco > 1 then begin
       errormessage(info,4,err_closeparentexpected,[],-1);
      end
      else begin
       if not tryconvert(info,contextstack[stacktop],po2,
                                    ptypedataty(po2)^.indirectlevel) then begin
        illegalconversionerror(info,contextstack[stacktop].d,po2,
                                    ptypedataty(po2)^.indirectlevel);
       end
       else begin
        contextstack[stackindex].d:= contextstack[stacktop].d;
       end;
      end;
     end;
    end;
    else begin
     errormessage(info,0,err_wrongtype,[]);
    end;
   end;
  end
  else begin
   identerror(info,1,err_identifiernotfound);
  end;
endlab:
  stacktop:= stackindex;
  dec(stackindex);
 end;
end;

procedure handlestatementend(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'STATEMENTEND');
{$endif}
 with info^,contextstack[stacktop],d do begin
  kind:= ck_end;
 end;
end;

procedure handleblockend(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'BLOCKEND');
{$endif}
// with info^ do begin
//  stackindex:= stackindex-2;
// end;
end;
(*
procedure handleparamstart0(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PARAMSTART0');
{$endif}
 with info^,contextstack[stacktop] do begin
  parent:= stacktop;
 end;
end;

procedure handleparam(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PARAM');
{$endif}
 with info^,contextstack[stacktop] do begin
  stackindex:= parent+1;
 end;
end;
*)
procedure dummyhandler(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'DUMMY');
{$endif}
end;

procedure handlenoimplementationerror(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NOIMPLEMENTATIONERROR');
{$endif}
 tokenexpectederror(info,tk_implementation);
 with info^ do begin
  stackindex:= -1;
 end;
end;

procedure checkstart(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'CHECKSTART');
{$endif}
end;

procedure handlenouniterror(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NOUNITERROR');
{$endif}
 with info^ do begin
  tokenexpectederror(info,tk_unit);
 end;
end;

procedure handlenounitnameerror(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NOUNITNAMEERROR');
{$endif}
 with info^ do begin
  errormessage(info,-1,err_identifierexpected,[]);
 end;
end;

procedure handlesemicolonexpected(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'SEMICOLONEXPECTED');
{$endif}
 with info^ do begin
  errormessage(info,-1,err_semicolonexpected,[]);
 end;
end;

procedure handleidentexpected(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'IDENTEXPECTED');
{$endif}
 with info^ do begin
  errormessage(info,-1,err_identexpected,[]);
 end;
end;

procedure handleillegalexpression(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ILLEGALEXPRESSION');
{$endif}
 with info^ do begin
  errormessage(info,-1,err_illegalexpression,[]);
  dec(stackindex);
 end;
end;

procedure handleuseserror(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'USESERROR');
{$endif}
 with info^ do begin
  errormessage(info,-1,err_semicolonexpected,[]);
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleuses(const info: pparseinfoty);
var
 int1,int2: integer;
 offs1: elementoffsetty;
 po1: ppunitinfoty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'USES');
{$endif}
 with info^ do begin
  offs1:= ele.decelementparent;
  int2:= stacktop-stackindex-1;
  with unitinfo^ do begin
   if us_interfaceparsed in state then begin
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
   po1^:= loadunitinterface(info,int1);
   if po1^ = nil then begin
    stopparser:= true;
    break;
   end;
  end;
  ele.elementparent:= offs1;
  stacktop:= stackindex;
 end;
end;

procedure handlenoidenterror(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'NOIDENTERROR');
{$endif}
 errormessage(info,-1,err_identexpected,[],0,erl_fatal);
end;

procedure handleprogbegin(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PROGBEGIN');
{$endif}
 with info^,ops[startupoffset] do begin
  d.opaddress:= opcount-1;
 end;
end;

procedure handleprogblock(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PROGBLOCK');
{$endif}
outinfo(info,'****');
 writeop(info,nil); 
 checkforwarderrors(info,info^.unitinfo^.forwardlist);
 with info^ do begin
  dec(stackindex);
 end;
end;

procedure handlecommentend(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'COMMENTEND');
{$endif}
{
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
}
end;

procedure handleconst(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'CONST');
{$endif}
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleconst0(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'CONST0');
{$endif}
// with info^,contextstack[stacktop] do begin
//  dec(stackindex);
//  stacktop:= stackindex;
// end;
end;

procedure handleconst3(const info: pparseinfoty);
var
 po1: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'CONST3');
{$endif}
 with info^ do begin
  if (stacktop-stackindex = 3) and (contextstack[stacktop].d.kind = ck_end) and
       (contextstack[stacktop-1].d.kind = ck_const) and
       (contextstack[stacktop-2].d.kind = ck_ident) then begin
   with contextstack[stacktop-2].d do begin
    po1:= ele.addelement(ident.ident,vis_max,ek_const);
    if po1 = nil then begin
     identerror(info,stacktop-2-stackindex,err_duplicateidentifier);
    end
    else begin
     with contextstack[stacktop-1].d do begin
      pconstdataty(@po1^.data)^.val.typ:= datatyp;
      pconstdataty(@po1^.data)^.val.d:= constval;
     end;
    end;
   end;
  end
  else begin
   parsererror(info,'CONST3');
  end;
  stacktop:= stackindex;
 end;
end;


procedure handlevar(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'VAR');
{$endif}
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;
 
procedure handlevar1(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'VAR1');
{$endif}
 with info^,contextstack[stackindex] do begin
  d.kind:= ck_var;
  d.vari.indirectlevel:= 0;
//  d.vari.flags:= [];
 end;
end;

procedure handlevar3(const info: pparseinfoty);
var
 po1,po2: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'VAR3');
{$endif}
 with info^ do begin
  po1:= ele.addelement(contextstack[stackindex+1].d.ident.ident,vis_max,ek_var);
  if po1 = nil then begin //duplicate
   identerror(info,1,err_duplicateidentifier);
  end
  else begin //todo: multi level type
   if findkindelements(info,2,[ek_type],vis_max,po2) then begin
    with pvardataty(@po1^.data)^ do begin
     typ:= ele.eleinforel(po2);
     if funclevel = 0 then begin
      address.address:= getglobvaraddress(info,ptypedataty(@po2^.data)^.bytesize);
      address.flags:= [vf_global];
     end
     else begin
      address.address:= getlocvaraddress(info,ptypedataty(@po2^.data)^.bytesize);
      address.flags:= []; //local
     end;
     address.indirectlevel:= contextstack[stackindex].d.vari.indirectlevel;
     with ptypedataty(@po2^.data)^ do begin
//      if kind = dk_reference then begin
       address.indirectlevel:= address.indirectlevel+indirectlevel;
//      end;
     end;
//     if tf_reference in contextstack[stackindex].d.vari.flags then begin
//      include(address.flags,vf_reference);
//     end;
    end;
   end
   else begin
    identerror(info,2,err_identifiernotfound);
   end;
  end;
 end;
end;

procedure handlepointervar(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'POINTERVAR');
{$endif}
 with info^,contextstack[stackindex].d.vari do begin
//  if tf_reference in flags then begin
  if indirectlevel > 0 then begin
   errormessage(info,-1,err_typeidentexpected,[]);
  end;
  inc(indirectlevel);
//  include(flags,tf_reference);
 end;
end;

procedure handletype(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'TYPE');
{$endif}
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handletypedefstart(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'TYPEDEFSTART');
{$endif}
 with info^,contextstack[stackindex] do begin
  d.kind:= ck_type;
  d.typ.indirectlevel:= 0;
//  d.typ.flags:= [];
 end;
end;

procedure handlepointertype(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'POINTERTYPE');
{$endif}
 with info^,contextstack[stackindex] do begin
  inc(d.typ.indirectlevel);
//  include(d.typ.flags,tf_reference);
 end;
end;

procedure handletype3(const info: pparseinfoty);
var
 po1,po2: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'TYPE3');
{$endif}
 with info^ do begin
  if (stacktop-stackindex = 2) and 
       (contextstack[stacktop].d.kind = ck_ident) and
       (contextstack[stacktop-1].d.kind = ck_ident) then begin
   po1:= ele.addelement(contextstack[stacktop-1].d.ident.ident,vis_max,ek_type);
   if po1 = nil then begin //duplicate
    identerror(info,stacktop-1-stackindex,err_duplicateidentifier);
   end
   else begin //todo: multi level type
    if findkindelements(info,stacktop-stackindex,
                       [ek_type],vis_max,po2) then begin
     ptypedataty(@po1^.data)^:= ptypedataty(@po2^.data)^;
//     if tf_reference in contextstack[stackindex].d.typ.flags then begin
     with contextstack[stackindex].d do begin
      inc(ptypedataty(@po1^.data)^.indirectlevel,typ.indirectlevel);
      {
      if typ.indirectlevel > 0 then begin
       with ptypedataty(@po1^.data)^ do begin
        if ptypedataty(@po1^.data)^.kind = dk_reference then begin
         indirectlevel:= indirectlevel + typ.indirectlevel;
        end
        else begin
         bytesize:= pointersize;
         kind:= dk_reference;
         target:= ele.eleinforel(po2);
         indirectlevel:= 1;
        end;
       end;
      end;
      }
     end;
    end
    else begin
     identerror(info,stacktop-stackindex,err_identifiernotfound);
    end;
   end;
  end
  else begin
   internalerror(info,'H131024A');
  end;
  stacktop:= stackindex;
 end;
end;

procedure handleexp(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'EXP');
{$endif}
 with info^ do begin
  contextstack[stacktop-1].d:= contextstack[stacktop].d;
  dec(stacktop);
  //todo: handle dereference and the like
 {
  if currentstatementflags * [stf_rightside,stf_params] <> [] then begin
   with contextstack[stacktop] do begin
    if d.kind = ck_const then begin
     pushconst(info,d);
     outcommand(info,[0],'push');
    end;
   end;
  end;
 }
 end;
end;

procedure handlemain(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'MAIN');
{$endif}
 checkforwarderrors(info,info^.unitinfo^.forwardlist);
 with info^ do begin
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
procedure handlemain1(const info: pparseinfoty);
var
 po1: pcontextty;
 ident1: identty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'MAIN1');
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

procedure handlekeyword(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'KEYWORD');
{$endif}
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
 end;
end;

procedure handleequsimpexp(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'EQUSIMPEXP');
{$endif}
 outcommand(info,[-2,0],'=');
 writeop(info,addops[pushvalues(info)]);
end;
{
procedure handlestatement(const info: pparseinfoty);
begin
 outhandle(info,'HANDLESTATEMENT');
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
procedure handleassignmententry(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ASSIGNMENTENTRY');
{$endif}
 with info^ do begin
  include(currentstatementflags,stf_rightside);
 end;
end;

procedure handleassignment(const info: pparseinfoty);
var
 dest: vardestinfoty;
 typematch,indi: boolean;
 si1: integer;
begin
{$ifdef mse_debugparser}
 outhandle(info,'ASSIGNMENT');
{$endif}
outinfo(info,'*****');
 with info^ do begin
  if (stacktop-stackindex = 2) and not errorfla then begin
   with contextstack[stackindex+1].d do begin
   //todo: handle dereference and the like
    typematch:= false;
    indi:= false;
    dest.typ:= ele.eledataabs(datatyp.typedata);
    dec(datatyp.indirectlevel);
    if datatyp.indirectlevel < 0 then begin
     internalerror(info,'P20131126B');
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
        errormessage(info,0,err_argnotassign,[]);
       end
       else begin
        dest.address:= constval.vaddress;
        typematch:= true;
       end;
      end;
      ck_fact: begin
       typematch:= true;
       indi:= true;
      end;
      else begin
       internalerror(info,'P20131117A');
       exit;
      end;
     end;
    end;
    dest.address.indirectlevel:= datatyp.indirectlevel;
   end;
   if typematch and not errorfla then begin
    typematch:= tryconvert(info,contextstack[stacktop],dest.typ,
                                              dest.address.indirectlevel);
    if not typematch then begin
     assignmenterror(info,contextstack[stacktop].d,dest);
    end
    else begin
     with contextstack[stacktop] do begin
      if d.kind = ck_const then begin
       pushconst(info,d);
       outcommand(info,[0],'push');
      end;
     end;
     with additem(info)^ do begin
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
        d.count:= dest.address.address;
       end;
      end;
     end;
    end;
   end;
  end
  else begin
   errormessage(info,-1,err_illegalexpression,[]);
  end;
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlestatement0entry(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'STATEMENT0ENTRY');
{$endif}
 with info^ do begin
  currentstatementflags:= [];
  with contextstack[stacktop].d,statement do begin
   kind:= ck_statement;
//   flags:= [];
  end;
 end;
end;

procedure handleleftside(const info: pparseinfoty);
var
 pi: pinteger;
begin
 (pi):= nil;
{$ifdef mse_debugparser}
 outhandle(info,'HANDLELEFTSIDE');
{$endif}
 with info^ do begin
 end;
end;

(*
procedure handlestatement1(const info: pparseinfoty);
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

procedure handlecheckproc(const info: pparseinfoty);
var
 po2: pfuncdataty;
 po3: pelementoffsetty;
 po4: pvardataty;
 po1: psysfuncdataty;
 int1,int2: integer;
 paramco: integer;
begin
{$ifdef mse_debugparser}
 outhandle(info,'CHECKPROC');
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
       errormessage(info,int1-stackindex,err_incompatibletypeforarg,
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
procedure setleftreference(const info: pparseinfoty);
//called by i1po^:= 123;
var
 pi: ^pinteger;
begin
// pi(^)^:= 123;
{$ifdef mse_debugparser}
 outhandle(info,'SETDESTREFERENCE');
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
procedure opgoto(const info: pparseinfoty; const aaddress: dataaddressty);
begin
 with additem(info)^ do begin
  op:= @gotoop;
  d.opaddress:= aaddress;
 end;
end;

procedure handleif(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'IF');
{$endif}
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'THEN');
{$endif}
 tokenexpectederror(info,tk_then);
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen0(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'THEN0');
{$endif}
 with info^ do begin
  if not (ptypedataty(ele.eledataabs(
       contextstack[stacktop].d.datatyp.typedata))^.kind = dk_boolean) then begin
   errormessage(info,stacktop-stackindex,err_booleanexpressionexpected,[]);
  end;
 end;
 with additem(info)^ do begin
  op:= @ifop;   
 end;
end;

procedure handlethen1(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'THEN1');
{$endif}
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen2(const info: pparseinfoty);
      //1       2        
begin //boolexp,thenmark
{$ifdef mse_debugparser}
 outhandle(info,'THEN2');
{$endif}
 setcurrentlocbefore(info,2); //set gotoaddress
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleelse0(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ELSE0');
{$endif}
 opgoto(info,dummyaddress);
end;

procedure handleelse(const info: pparseinfoty);
      //1       2        3
begin //boolexp,thenmark,elsemark
{$ifdef mse_debugparser}
 outhandle(info,'ELSE');
{$endif}
 setlocbefore(info,2,3);      //set gotoaddress for handlethen0
 setcurrentlocbefore(info,3); //set gotoaddress for handleelse0
 with info^ do begin
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
procedure testxx(const info: pparseinfoty);
begin
end;
}
procedure handleprocedure3(const info: pparseinfoty);
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

begin
{$ifdef mse_debugparser}
 outhandle(info,'PROCEDURE3');
{$endif}
//0          1     2          3          4    5
//procedure2,ident,paramsdef3{,paramdef2,name,type}
              //todo: multi level type
outinfo(info,'****');
 with info^ do begin
  paramco:= (stacktop-stackindex-2) div 3;
  po1:= addr(ele.pushelementduplicate(
                      contextstack[stackindex+1].d.ident.ident,
                      vis_max,ek_func,paramco*sizeof(pvardataty))^.data);
  po1^.paramcount:= paramco;
  po1^.links:= 0;
  po4:= @po1^.paramsrel;
  int1:= 4;
  err1:= false;
  impl1:= us_implementation in unitinfo^.state; //todo: check forward modifier
  for int2:= 0 to paramco-1 do begin
   if ele.addelement(contextstack[int1+stackindex].d.ident.ident,vis_max,
                                                        ek_var,po2) then begin
    po4^[int2]:= ele.eledatarel(po2);
    if findkindelementsdata(info,int1+1,[ek_type],vis_max,po3) then begin
     with po2^ do begin
      if impl1 then begin
       address.address:= getlocvaraddress(info,po3^.bytesize);
       address.flags:= [vf_param];
      end;
      typ:= ele.eledatarel(po3);
     end;
    end
    else begin
     identerror(info,int1+1-stackindex,err_identifiernotfound);
     err1:= true;
    end;
   end
   else begin
    identerror(info,int1,err_duplicateidentifier);
    err1:= true;
   end;
   int1:= int1+3;
  end;
  
  parent1:= ele.decelementparent; //check params duplicate
  with paramdata do begin
   ref:= po1;
  end;
  if ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_func],
                            vis_max,@checkequalparam,paramdata) then begin
   err1:= true;
   errormessage(info,-1,err_sameparamlist,[]);
  end;
  
  if impl1 then begin //implementation
   with po1^ do begin
    address:= opcount;
   end;
   if funclevel = 0 then begin //todo: check forward modifier
    ele.decelementparent; //interface
    if ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_func],
                                vis_max,@checkequalparam,paramdata) then begin
     with paramdata.match^ do begin
      forwardresolve(info,mark);
      impl:= ele.eledatarel(po1);
      pointer(parref):= @paramsrel;
      pointer(par1):= @po1^.paramsrel;
      for int1:= 0 to paramco-1 do begin
       if ele.eleinfoabs(parref^[int1])^.header.name <> 
                 ele.eleinfoabs(par1^[int1])^.header.name then begin
        errormessage(info,stacktop-stackindex-3*(paramco-int1-1)-1,
             err_functionheadernotmatch,
                [getidentname(ele.eleinfoabs(parref^[int1])^.header.name),
                     getidentname(ele.eleinfoabs(par1^[int1])^.header.name)]);
       end;
      end;
      address:= po1^.address;
      linkresolve(info,paramdata.match^.links,opcount);
     end;
    end;
   end;
   ele.elementparent:= parent1;
   inc(funclevel);
   frameoffset:= locdatapo; //todo: nested procedures
   getlocvaraddress(info,stacklinksize);
   stacktop:= stackindex;
   with contextstack[stackindex] do begin
    d.kind:= ck_proc;
    d.proc.paramcount:= paramco;
    d.proc.error:= err1;
    ele.markelement(d.proc.elementmark); 
   end;
  end
  else begin
   po1^.address:= 0;
   forwardmark(info,po1^.mark,source);
  end;
 end;
end;

procedure handleprocedure6(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PROCEDURE6');
{$endif}
outinfo(info,'*****');
 with info^,contextstack[stackindex-1],d do begin
  ele.decelementparent;
  ele.releaseelement(proc.elementmark); 
                                            //remove local definitions
  with additem(info)^ do begin
   op:= @returnop;
   d.count:= proc.paramcount+1;
  end;
  dec(funclevel);
 end;
end;

procedure handlecheckterminator(const info: pparseinfoty);
begin
 with info^ do begin
  errormessage(info,-1,err_semicolonexpected,[]);
  dec(stackindex);
 end;
end;

procedure handlestatementblock1(const info: pparseinfoty);
begin
 with info^ do begin
  errormessage(info,-1,err_semicolonexpected,[]);
  dec(stackindex);
 end;
end;

procedure handledumpelements(const info: pparseinfoty);
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

procedure handleabort(const info: pparseinfoty);
var
 ar1: msestringarty;
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle(info,'ABORT');
{$endif}
 with info^ do begin
  stopparser:= true;
  errormessage(info,-1,err_abort,[]);
 end;
end;

end.