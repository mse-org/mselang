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

procedure initparser(const info: pparseinfoty);

procedure push(const info: pparseinfoty; const avalue: real); overload;
procedure push(const info: pparseinfoty; const avalue: integer); overload;
procedure int32toflo64(const info: pparseinfoty; const index: integer);
 
procedure dummyhandler(const info: pparseinfoty);

procedure handleprogbegin(const info: pparseinfoty);

procedure handlecommentend(const info: pparseinfoty);

procedure handlecheckterminator(const info: pparseinfoty);
procedure handlestatementblock1(const info: pparseinfoty);

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
procedure handleterm1(const info: pparseinfoty);
procedure handlenegterm(const info: pparseinfoty);
procedure handleaddterm(const info: pparseinfoty);
procedure handlebracketend(const info: pparseinfoty);
procedure handlesimpexp(const info: pparseinfoty);
procedure handlesimpexp1(const info: pparseinfoty);
//procedure handleln(const info: pparseinfoty);
procedure handleparamstart0(const info: pparseinfoty);
procedure handleparam(const info: pparseinfoty);
procedure handleparamsend(const info: pparseinfoty);
//procedure handlecheckparams(const info: pparseinfoty);

//procedure handlestatement(const info: pparseinfoty);

procedure handleassignment(const info: pparseinfoty);
procedure handlestatement1(const info: pparseinfoty);
procedure handlecheckproc(const info: pparseinfoty);

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

implementation
uses
 msestackops,msestrings,mseelements,mseexpint,grammar,sysutils;

const
 reversestackdata = sdk_bool8rev;
 stacklinksize = 1;

type
 systypety = (st_integer);
 typedataty = record
  size: integer;
  case kind: datakindty of 
   dk_record: ();
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
 constdataty = record
  d: contextdataty;
 end;
 pconstdataty = ^constdataty;
 
 varflagty = (vf_global,vf_param);
 varflagsty = set of varflagty;

 vardataty = record
  address: ptruint;
  typerel: ptypedataty; //elementdata relative
  flags: varflagsty;
 end;
 pvardataty = ^vardataty;
 ppvardataty = ^pvardataty;
 
// keywordty = (kw_0,kw_1,kw_if,kw_begin,kw_procedure,kw_const,kw_var);
 sysfuncty = (sf_writeln);
 sysfuncdataty = record
  func: sysfuncty;
  op: opty;
 end;
 psysfuncdataty = ^sysfuncdataty;
 sysfuncinfoty = record
  name: string;
  data: sysfuncdataty;
 end;
 funcdataty = record
  address: opaddressty;
  paramcount: integer;
  paramsrel: record //array of relative pvardataty
  end;
 end;
 pfuncdataty = ^funcdataty;
   
const
 systypeinfos: array[systypety] of typeinfoty = (
   (name: 'integer'; data: (size: 4; kind: dk_int32))
  );
 sysconstinfos: array[0..1] of constinfoty = (
   (name: 'false'; data: (kind: ck_const; constval: (kind: dk_bool8; vbool8: 0))),
   (name: 'true'; data: (kind: ck_const; constval: (kind: dk_bool8; vbool8: -1)))
  );
 sysfuncinfos: array[sysfuncty] of sysfuncinfoty = (
   (name: 'writeln'; data: (func: sf_writeln; op: @writelnop))
  );

type
 errorty = (err_ok,err_duplicateidentifier,err_identifiernotfound,
            err_thenexpected,err_semicolonexpected,err_identifierexpected,
            err_booleanexpressionexpected,
            err_wrongnumberofparameters,err_incompatibletypeforarg,
            err_toomanyidentifierlevels,err_wrongtype);
 errorinfoty = record
  level: errorlevelty;
  message: string;
 end;
const
 errorleveltext: array[errorlevelty] of string = (
  '','Fatal','Error'
 );
 errortext: array[errorty] of errorinfoty = (
  (level: erl_none; message: ''),
  (level: erl_error; message: 'Duplicate identifier "%s"'),
  (level: erl_error; message: 'Identifier not found "%s"'),
  (level: erl_fatal; message: 'Syntax error, "then" expected'),
  (level: erl_fatal; message: 'Syntax error, ";" expected'),
  (level: erl_fatal; message: 'Syntax error, "identifier" expected'),
  (level: erl_error; message: 'Boolean expression expected'),
  (level: erl_error; message: 
                    'Wrong number of parameters specified for call to "%s"'),
  (level: erl_error; message: 
                    'Incompatible type for arg no. %d: Got "%s", expected "%s"'),
  (level: erl_fatal; message:
                    'Too many identyfier levels'),
  (level: erl_error; message: 
                    'Wrong type')
 );

function typename(const ainfo: contextdataty): string;
begin
 result:= getenumname(typeinfo(datakindty),ord(ainfo.factkind));
end;

function typename(const atype: typedataty): string;
begin
 result:= getenumname(typeinfo(datakindty),ord(atype.kind));
end;
 
procedure errormessage(const info: pparseinfoty; const astackoffset: integer;
                   const aerror: errorty; const values: array of const;
                   const coloffset: integer = 0);
var
 po1: pchar;
 sourcepos: sourceinfoty;
 str1: string;
begin
 with info^ do begin
  if astackoffset < 0 then begin
   sourcepos:= source;
  end
  else begin
   sourcepos:= contextstack[stackindex+astackoffset].start;
  end;
  with sourcepos do begin
   if line > 0 then begin
    po1:= po;
    while po1^ <> c_linefeed do begin
     dec(po1);
    end;
   end
   else begin
    po1:= sourcestart-1;
   end;
   with errortext[aerror] do begin
    inc(errors[level]);
    str1:=filename+'('+inttostr(line+1)+','+inttostr(po-po1+coloffset)+') '+
        errorleveltext[level]+': '+format(message,values);
    command.writeln(str1);
    writeln('<<<<<<< '+str1);
   end;
  end;
 end;
end;

procedure identerror(const info: pparseinfoty; const astackoffset: integer;
                                                        const aerror: errorty);
begin
 with info^,contextstack[stackindex+astackoffset] do begin
  errormessage(info,astackoffset,aerror,
                     [lstringtostring(start.po,d.ident.len)],d.ident.len);
 end;
end;
{
procedure identexisterror(const info: contextitemty; const text: string);
begin
 writeln(' ***ERROR*** ident '+lstringtostring(info.start.po,info.d.identlen)+
                   ' exsts. '+text);
end;
}

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
//  inc(locdatapo,asize);
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

var
 sysdatatypes: array[systypety] of ptypedataty;
 
procedure initparser(const info: pparseinfoty);
var
// kw1: keywordty;
 ty1: systypety;
 sf1: sysfuncty;
 po1: pelementinfoty;
 po2: ptypedataty;
 int1: integer;
begin
// for kw1:= keywordty(2) to high(keywordty) do begin
//  getident(copy(getenumname(typeinfo(keywordty),ord(kw1)),4,bigint));
// end;
 for int1:= 0 to high(keywords) do begin
  getident(keywords[int1]);
 end;
 for ty1:= low(systypety) to high(systypety) do begin
  with systypeinfos[ty1] do begin
   po1:= elements.addelement(getident(name),ek_type,elesize+sizeof(typedataty));
   po2:= @po1^.data;
   po2^:= data;
  end;
  sysdatatypes[ty1]:= elements.eledatarel(po2);
 end;
 for int1:= low(sysconstinfos) to high(sysconstinfos) do begin
  with sysconstinfos[int1] do begin
   po1:= elements.addelement(getident(name),ek_const,
                                          elesize+sizeof(constdataty));
   pconstdataty(@po1^.data)^.d:= data;
  end;
 end;
 for sf1:= low(sysfuncty) to high(sysfuncty) do begin
  with sysfuncinfos[sf1] do begin
   po1:= elements.addelement(getident(name),ek_sysfunc,
                                    elesize+sizeof(sysfuncdataty));
   psysfuncdataty(@po1^.data)^:= data;
  end;
 end;
 writeop(info,@gotoop); //startup vector 
end;
(*
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
*)
function findkindelementdata(const aident: contextdataty;
              const akind: elementkindty; out ainfo: pointer): boolean;
var
 po1: pelementinfoty;
begin
 result:= false;
 if aident.kind = ck_ident then begin
  po1:= elements.findelement(aident.ident.ident);
  if (po1 <> nil) and (akind = ek_none) or (po1^.header.kind = akind) then begin
   ainfo:= @po1^.data;
   result:= true;
  end;
 end;
end;

function findkindelementdata(const info: pparseinfoty;
              const astackoffset: integer;
              const akind: elementkindty; out ainfo: pointer): boolean;
begin
 with info^ do begin
  result:= findkindelementdata(contextstack[stackindex+astackoffset].d,
                                                                 akind,ainfo);
 end;
end;

function findkindelements(const info: pparseinfoty;
            const astackoffset: integer; const akind: elementkindty; 
                                          out aelement: pelementinfoty): boolean;
var
 int1: integer;
 idents: identvectorty;
 po1: pcontextitemty;
// po2: pelementinfoty;
 ele1: elementoffsetty;
begin
 result:= false;
 with info^ do begin
  po1:= @contextstack[stackindex+astackoffset];
  identcount:= -1;
  for int1:= 0 to high(idents.d) do begin
   idents.d[int1]:= po1^.d.ident.ident;
   if not po1^.d.ident.continued then begin
    identcount:= int1;
    break;
   end;
   inc(po1);
  end;
  idents.high:= identcount;
  inc(identcount);
  if identcount = 0 then begin
   errormessage(info,astackoffset+identcount,err_toomanyidentifierlevels,[]);
  end
  else begin
   aelement:= elements.findelementsupward(idents,ele1);
   if (aelement <> nil) and ((akind = ek_none) or 
                             (aelement^.header.kind = akind)) then begin
    result:= true;
   end;
  end;
 end;
end;

function findkindelementsdata(const info: pparseinfoty; const astackoffset: integer;
              const akind: elementkindty; out ainfo: pointer): boolean;
begin
 result:= findkindelements(info,astackoffset,akind,ainfo);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

procedure parsererror(const info: pparseinfoty; const text: string);
begin
 with info^ do begin
  contextstack[stackindex].d.kind:= ck_error;
  writeln(' ***ERROR*** '+text);
 end; 
end;

procedure identnotfounderror(const info: contextitemty; const text: string);
begin
 writeln(' ***ERROR*** ident '+lstringtostring(info.start.po,info.d.ident.len)+
                   ' not found. '+text);
end;

procedure wrongidentkinderror(const info: contextitemty; 
       wantedtype: elementkindty; const text: string);
begin
 writeln(' ***ERROR*** wrong ident kind '+
               lstringtostring(info.start.po,info.d.ident.len)+
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
     ck_const: begin
      with constval do begin
       case kind of
        dk_bool8: begin
         command.write(longbool(vbool8));
        end;
        dk_int32: begin
         command.write(vint32);
        end;
        dk_flo64: begin
         command.write(vflo64);
        end;
       end;
      end;
     end;
    end;
    command.write(',');
   end;
  end;
  command.writeln([' ',text]);
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
   dk_bool8: begin
    push(info,constval.vbool8);
   end;
   dk_int32: begin
    push(info,constval.vint32);
   end;
   dk_flo64: begin
    push(info,constval.vflo64);
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

procedure setcurrentloc(const info: pparseinfoty; const indexoffset: integer);
begin 
 with info^ do begin
  ops[contextstack[stackindex+indexoffset].d.opmark.address].d.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setcurrentlocbefore(const info: pparseinfoty;
                                             const indexoffset: integer);
begin 
 with info^ do begin
  ops[contextstack[stackindex+indexoffset].d.opmark.address-1].d.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setlocbefore(const info: pparseinfoty;
       const destindexoffset,sourceindexoffset: integer);
begin
 with info^ do begin
  ops[contextstack[stackindex+destindexoffset].d.opmark.address-1].
                                                               d.opaddress:=
         contextstack[stackindex+sourceindexoffset].d.opmark.address-1;
 end; 
end;

procedure setloc(const info: pparseinfoty;
       const destindexoffset,sourceindexoffset: integer);
begin
 with info^ do begin
  ops[contextstack[stackindex+destindexoffset].d.opmark.address].
                                                               d.opaddress:=
         contextstack[stackindex+sourceindexoffset].d.opmark.address-1;
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
  d.constval.kind:= dk_int32;
  d.constval.vint32:= int2;
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
   fraclen:= asource-start.po-1;
  end;
  stacktop:= stacktop - 1;
  stackindex:= stacktop-1;
  with contextstack[stacktop] do begin
   d.kind:= ck_const;
   d.constval.kind:= dk_flo64;
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
 dofrac(info,info^.source.po,neg,mant,fraclen);
 with info^,contextstack[stacktop].d.constval do begin
  vflo64:= mant/floatexps[fraclen]; //todo: round lsb;   
  if neg then begin
   vflo64:= -vflo64; 
  end;
  consumed:= source.po;
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
  exp:= contextstack[stacktop].d.constval.vint32;
  dec(stacktop,2);
  dofrac(info,contextstack[stackindex].start.po,neg,mant,fraclen);
  exp:= exp-fraclen;
  with contextstack[stacktop] do begin
   consumed:= source.po; //todo: overflow check
   do1:= floatexps[exp and $1f];
   while exp >= 32 do begin
    do1:= do1*floatexps[32];
    exp:= exp - 32;
   end;
   with d.constval do begin
    vflo64:= mant*do1;
    if neg then begin
     vflo64:= -vflo64; 
    end;
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
  exp:= contextstack[stacktop].d.constval.vint32;
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
    vflo64:= mant/do1;
    if neg then begin
     vflo64:= -vflo64; 
    end;
   end;
  end;
 end;
 outhandle(info,'NEGEXPONENT');
end;

const
 resultdatakinds: array[stackdatakindty] of datakindty =
           (dk_bool8,dk_int32,dk_flo64,
            dk_bool8,dk_int32,dk_flo64);

function pushvalues(const info: pparseinfoty): stackdatakindty;
//todo: don't convert inplace, stack items will be of variable size
var
 reverse,negative: boolean;
begin
 with info^ do begin
  reverse:= (contextstack[stacktop].d.kind = ck_const) xor 
                           (contextstack[stacktop-2].d.kind = ck_const);
  if (contextstack[stacktop].d.factkind = dk_flo64) or 
             (contextstack[stacktop-2].d.factkind = dk_flo64) then begin
   result:= sdk_flo64;
   with contextstack[stacktop].d do begin
    if kind = ck_const then begin
     case factkind of
      dk_int32: begin
       push(info,real(constval.vint32));
      end;
      dk_flo64: begin
       push(info,constval.vflo64);
      end;
     end;
    end
    else begin //ck_fact
     case factkind of
      dk_int32: begin
       int32toflo64(info,0);
      end;
     end;
    end;
   end;
   with contextstack[stacktop-2].d do begin
    if kind = ck_const then begin
     case factkind of
      dk_int32: begin
       push(info,real(constval.vint32));
      end;
      dk_flo64: begin
       push(info,real(constval.vflo64));
       reverse:= not reverse;
      end;
     end;
    end
    else begin
     case factkind of
      dk_int32: begin
        int32toflo64(info,-1);
      end;
     end;
    end;
   end;
  end
  else begin
   if contextstack[stacktop].d.factkind = dk_bool8 then begin
    result:= sdk_bool8;
    with contextstack[stacktop-2].d do begin
     if kind = ck_const then begin
      case factkind of
       dk_bool8: begin
        push(info,constval.vbool8);
       end;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     if kind = ck_const then begin
      case factkind of
       dk_bool8: begin
        push(info,constval.vbool8);
       end;
      end;
     end;
    end;
   end
   else begin
    result:= sdk_int32;
    with contextstack[stacktop-2].d do begin
     if kind = ck_const then begin
      case factkind of
       dk_int32: begin
        push(info,constval.vint32);
       end;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     if kind = ck_const then begin
      case factkind of
       dk_int32: begin
        push(info,constval.vint32);
       end;
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
   d.kind:= ck_fact;
   d.factkind:= resultdatakinds[result];
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
 negops: array[datakindty] of opty = (
 //dk_none,dk_bool8,dk_int32,dk_flo64,dk_kind,dk_address,dk_record
   @dummyop,@dummyop,@negint32,@negflo64,@dummyop,@dummyop,@dummyop
 );

procedure handleterm1(const info: pparseinfoty);
begin
 with info^ do begin
  if stackindex < stacktop then begin
   if contextstack[stackindex].d.kind = ck_neg then begin
    writeop(info,negops[contextstack[stacktop].d.factkind]);
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
 outhandle(info,'BRACKETEND');
end;
{
procedure handleln(const info: pparseinfoty);
begin
 outcommand(info,[0],'ln()');
 with info^ do begin
  stacktop:= stackindex;
  dec(stackindex);
  with contextstack[stacktop] do begin
   d.kind:= ck_fact;
   context:= nil;
  end;
 end;
 outhandle(info,'LN');
end;
}
procedure handleparamsend(const info: pparseinfoty);
begin
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
 outhandle(info,'PARAMSEND');
end;
{
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
}
procedure handleident(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  ident.continued:= false;
 end;
 outhandle(info,'IDENT');
end;

procedure handleidentpath1a(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  ident.continued:= false;
 end;
 outhandle(info,'IDENTPATH1A');
end;

procedure handleidentpath2a(const info: pparseinfoty);
begin
 with info^,contextstack[stacktop],d do begin
  ident.continued:= true;
 end;
 outhandle(info,'IDENTPATH2A');
end;

procedure handleidentpath2(const info: pparseinfoty);
begin
 errormessage(info,0,err_identifierexpected,[]);
 outhandle(info,'IDENTPATH2');
end;

procedure handlevalueidentifier(const info: pparseinfoty);
var
 po1: pelementinfoty;
 po2: pointer;
 si1: ptruint;
begin
 with info^ do begin
//  po1:= elements.findelement(contextstack[stacktop].d.ident.ident);
  if findkindelements(info,1,ek_none,po1) then begin
   dec(stacktop,identcount);
   po2:= @po1^.data;
   case po1^.header.kind of
    ek_var: begin
     si1:= ptypedataty(elements.eledataabs(pvardataty(po2)^.typerel))^.size;
     with additem(info)^ do begin //todo: use table
      if vf_global in pvardataty(po2)^.flags then begin
       case si1 of
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
       d.dataaddress:= pvardataty(po2)^.address;
      end
      else begin
       case si1 of
        1: begin 
         op:= @pushloc1;
        end;
        2: begin
         op:= @pushloc2;
        end;
        4: begin
         op:= @pushloc4;
        end;
        else begin
         op:= @pushloc;
        end;
       end;
//       if vf_param in pvardataty(po2)^.flags then begin
        d.count:= pvardataty(po2)^.address - frameoffset{ - stacklinksize};
//       end
//       else begin
        //todo
//       end;
      end;
      d.datasize:= si1;
     end;
     with contextstack[stacktop].d do begin
      kind:= ck_fact;
      factkind:= dk_int32;
     end;
    end;
    ek_const: begin
     contextstack[stacktop].d:= pcontextdataty(po2)^;
    end;
    else begin
     errormessage(info,0,err_wrongtype,[]);
    end;
   end;
  end
  else begin
   identerror(info,1,err_identifiernotfound);
//   identnotfounderror(contextstack[stacktop],'valueidentifier');
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

procedure handleblockend(const info: pparseinfoty);
begin
// with info^ do begin
//  stackindex:= stackindex-2;
// end;
 outhandle(info,'BLOCKEND');
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

procedure handleprogbegin(const info: pparseinfoty);
begin
 with info^,ops[startupoffset] do begin
  d.opaddress:= opcount-1;
 end;
 outhandle(info,'PROGBEGIN');
end;

procedure handlecommentend(const info: pparseinfoty);
begin
{
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
}
 outhandle(info,'COMMENTEND');
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
       (contextstack[stacktop-1].d.kind = ck_const) and
       (contextstack[stacktop-2].d.kind = ck_ident) then begin
   with contextstack[stacktop-2].d do begin
    po1:= elements.addelement(ident.ident,ek_const,elesize+sizeof(constdataty));
    if po1 = nil then begin
     identerror(info,stacktop-2-stackindex,err_duplicateidentifier);
    end
    else begin
     pconstdataty(@po1^.data)^.d:= contextstack[stacktop-1].d;
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
   po1:= elements.addelement(contextstack[stacktop-2].d.ident.ident,ek_var,
                                        elesize+sizeof(vardataty));
   if po1 = nil then begin
    identerror(info,stacktop-2-stackindex,err_duplicateidentifier);
   end
   else begin //todo: multi level type
    if findkindelements(info,stacktop-1-stackindex,ek_type,po2) then begin
     with pvardataty(@po1^.data)^ do begin
      typerel:= elements.eledatarel(po2);
      if funclevel = 0 then begin
       address:= getglobvaraddress(info,ptypedataty(po2)^.size);
       flags:= [vf_global];
      end
      else begin
       address:= getlocvaraddress(info,ptypedataty(po2)^.size);
       flags:= []; //local
      end;
     end;
    end
    else begin
     identerror(info,stacktop-1-stackindex,err_identifiernotfound);
//     parsererror(info,'type not found. VAR3');
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
  dec(stacktop);
//  dec(stackindex);
  with contextstack[stacktop] do begin
   if d.kind = ck_const then begin
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
 outhandle(info,'MAIN1');
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
 with info^,contextstack[stacktop],d do begin
  kind:= ck_ident;
  ident.len:= source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
 end;
 outhandle(info,'KEYWORD');
end;

procedure handleequsimpexp(const info: pparseinfoty);
begin
 outcommand(info,[-2,0],'=');
 writeop(info,addops[pushvalues(info)]);
 outhandle(info,'EQUSIMPEXP');
end;
{
procedure handlestatement(const info: pparseinfoty);
begin
 outhandle(info,'HANDLESTATEMENT');
end;
}
procedure handleassignment(const info: pparseinfoty); 
var
 po1: pvardataty;
 si1: ptruint;
begin
 with info^ do begin
  if (stacktop-stackindex > 0) and //todo: multi level var name
   findkindelementsdata(info,1,ek_var,po1) then begin
   si1:= ptypedataty(elements.eledataabs(po1^.typerel))^.size;
   with additem(info)^ do begin
    if vf_global in po1^.flags then begin
     case si1 of
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
     d.dataaddress:= po1^.address;
    end
    else begin
     case si1 of
      1: begin 
       op:= @poploc1;
      end;
      2: begin
       op:= @poploc2;
      end;
      4: begin
       op:= @poploc4;
      end;
      else begin
       op:= @poploc;
      end;
     end;
     d.count:= po1^.address;
    end;
    d.datasize:= si1;
   end;
  end
  else begin
   identerror(info,1,err_identifiernotfound);
  end;                  
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'ASSIGNMENT');
end;

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
 po3: ppvardataty;
 po4: pvardataty;
 po1: psysfuncdataty;
 int1,int2: integer;
 paramco: integer;
begin
 with info^ do begin
  if findkindelementsdata(info,1,ek_func,po2) then begin
   paramco:= stacktop-stackindex-1-identcount;
   if paramco <> po2^.paramcount then begin
    identerror(info,1,err_wrongnumberofparameters);
   end
   else begin
    po3:= @po2^.paramsrel;
    for int1:= stackindex+3 to stacktop do begin
     po4:= elements.eledataabs(po3^);
     with contextstack[int1] do begin
      if d.factkind <> 
               ptypedataty(elements.eledataabs(po4^.typerel))^.kind then begin
       errormessage(info,int1-stackindex,err_incompatibletypeforarg,
         [int1-stackindex-2,typename(d),
                    typename(ptypedataty(elements.eledataabs(po4^.typerel))^)]);
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
   if findkindelementsdata(info,1,ek_sysfunc,po1) then begin
    with po1^ do begin
     case func of
      sf_writeln: begin
       int2:= stacktop-stackindex-2;
       for int1:= 3+stackindex to int2+2+stackindex do begin
        push(info,contextstack[int1].d.factkind);
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
 outhandle(info,'CHECKPROC');
end;

procedure opgoto(const info: pparseinfoty; const aaddress: dataaddressty);
begin
 with additem(info)^ do begin
  op:= @gotoop;
  d.opaddress:= aaddress;
 end;
end;

procedure handleif(const info: pparseinfoty);
begin
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'IF');
end;

procedure handlethen(const info: pparseinfoty);
begin
 errormessage(info,-1,err_thenexpected,[]);
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'THEN');
end;

procedure handlethen0(const info: pparseinfoty);
begin
 with info^ do begin
  if not (contextstack[stacktop].d.factkind = dk_bool8) then begin
   errormessage(info,stacktop-stackindex,err_booleanexpressionexpected,[]);
  end;
 end;
 with additem(info)^ do begin
  op:= @ifop;   
 end;
 outhandle(info,'THEN0');
end;

procedure handlethen1(const info: pparseinfoty);
begin
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'THEN1');
end;

procedure handlethen2(const info: pparseinfoty);
      //1       2        
begin //boolexp,thenmark
 setcurrentlocbefore(info,2); //set gotoaddress
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'THEN2');
end;

procedure handleelse0(const info: pparseinfoty);
begin
 opgoto(info,dummyaddress);
 outhandle(info,'ELSE0');
end;

procedure handleelse(const info: pparseinfoty);
      //1       2        3
begin //boolexp,thenmark,elsemark
 setlocbefore(info,2,3);      //set gotoaddress for handlethen0
 setcurrentlocbefore(info,3); //set gotoaddress for handleelse0
 with info^ do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
 outhandle(info,'ELSE');
end;

procedure handleprocedure3(const info: pparseinfoty);
var
 po1: pfuncdataty;
 po2: pvardataty;
 po3: ptypedataty;
 po4: ppointeraty;
 int1,int2: integer;
 paramco: integer;
 err1: boolean;
begin
//0          1     2          3          4    5
//procedure2,ident,paramsdef3{,paramdef2,name,type}
              //todo: multi level type
 with info^ do begin
  err1:= false;
  inc(funclevel);
  paramco:= (stacktop-stackindex-2) div 3;
  if elements.pushelement(contextstack[stackindex+1].d.ident.ident,ek_func,
              elesize+sizeof(funcdataty)+
                        paramco*sizeof(pvardataty),po1) then begin
   po1^.paramcount:= paramco;
   po4:= @po1^.paramsrel;
   int1:= 4;
   for int2:= 0 to paramco-1 do begin
    if elements.addelement(contextstack[int1+stackindex].d.ident.ident,ek_var,
                                  elesize+sizeof(vardataty),po2) then begin
     po4^[int2]:= elements.eledatarel(po2);
     if findkindelementsdata(info,int1+1,ek_type,po3) then begin
      with po2^ do begin
       address:= getlocvaraddress(info,po3^.size);
       typerel:= elements.eledatarel(po3);
       flags:= [vf_param];
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
   with po1^ do begin
    address:= opcount;
   end;
  end;
  if err1 then begin
   //todo: delete procedure definition
   dec(funclevel);
  end;
  frameoffset:= locdatapo; //todo: nested procedures
  getlocvaraddress(info,stacklinksize);
  stacktop:= stackindex;
  with contextstack[stackindex] do begin
   d.kind:= ck_proc;
   d.proc.paramcount:= paramco;
   elements.markelement(d.proc.elementmark); 
  end;
//  elements.popelement;
 end;
 outhandle(info,'PROCEDURE3');
end;

procedure handleprocedure6(const info: pparseinfoty);
begin
 with info^ do begin
  elements.releaseelement(contextstack[stackindex].d.proc.elementmark); 
                                            //remove local definitions
  with additem(info)^ do begin
   op:= @returnop;
   d.count:= contextstack[stackindex].d.proc.paramcount+1;
  end;
  dec(funclevel);
 end;
 outhandle(info,'PROCEDURE6');
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
var
 ar1: msestringarty;
 int1: integer;
begin
 writeln('--------------------ELEMENTS----------------------------------------');
 ar1:= elements.dumpelements;
 for int1:= 0 to high(ar1) do begin
  writeln(ar1[int1]);
 end;
 writeln('--------------------------------------------------------------------');
 with info^ do begin
 end;
end;

end.