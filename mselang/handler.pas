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
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
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
procedure handleaddress(const info: pparseinfoty);
procedure handledereference(const info: pparseinfoty);
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

procedure handleassignmententry(const info: pparseinfoty);
procedure handleassignment(const info: pparseinfoty);
procedure handlestatement0entry(const info: pparseinfoty);
procedure handlestatement1(const info: pparseinfoty);
procedure handlecheckproc(const info: pparseinfoty);
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
 stackops,msestrings,elements,grammar,sysutils,handlerutils,
 unithandler,errorhandler;

const
 reversestackdata = sdk_bool8rev;
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
   (name: 'bool8'; data: (bitsize: 8; bytesize: 1; datasize: das_8;
     flags: []; kind: dk_boolean; dummy: 0)),
   (name: 'int32'; data: (bitsize: 32; bytesize: 4; datasize: das_32;
     flags: []; kind: dk_integer; infoint32:(min: minint; max: maxint))),
   (name: 'flo64'; data: (bitsize: 64; bytesize: 8; datasize: das_64;
     flags: []; kind: dk_float; infofloat64:(min: mindouble; max: maxdouble)))
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
  sysdatatypes[ty1].flags:= [];
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
{$ifdef mse_debugparser}
 outhandle(info,'CNUM');
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

const
 floatexps: array[0..32] of double = 
  (1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,
   1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19,
   1e20,1e21,1e22,1e23,1e24,1e25,1e26,1e27,1e28,1e29,1e30,1e31,1e32);

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
 dofrac(info,info^.source.po,neg,mant,fraclen);
 with info^,contextstack[stacktop].d.constval do begin
  vfloat:= mant/floatexps[fraclen]; //todo: round lsb;   
  if neg then begin
   vfloat:= -vfloat; 
  end;
  consumed:= source.po;
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
 with info^ do begin
  exp:= contextstack[stacktop].d.constval.vinteger;
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
    vfloat:= mant*do1;
    if neg then begin
     vfloat:= -vfloat; 
    end;
   end;
  end;
 end;
end;

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

const
 resultdatakinds: array[stackdatakindty] of datakindty =
            //sdk_bool8,sdk_int32,sdk_flo64,
           (dk_boolean,dk_integer,dk_float,
            //sdk_bool8rev,sdk_int32rev,sdk_flo64rev);
            dk_boolean,dk_integer,dk_float);
 resultdatatypes: array[stackdatakindty] of systypety =
            //sdk_bool8,sdk_int32,sdk_flo64,
           (st_bool8,st_int32,st_float64,
            //sdk_bool8rev,sdk_int32rev,sdk_flo64rev);
            st_bool8,st_int32,st_float64);

function pushvalues(const info: pparseinfoty): stackdatakindty;
//todo: don't convert inplace, stack items will be of variable size
var
 reverse,negative: boolean;
 kinda,kindb: datakindty;
begin
 with info^ do begin
  reverse:= (contextstack[stacktop].d.kind = ck_const) xor 
                           (contextstack[stacktop-2].d.kind = ck_const);
  kinda:= ptypedataty(ele.eleinfoabs(
                     contextstack[stacktop].d.datatyp.typedata))^.kind;
  kindb:= ptypedataty(ele.eleinfoabs(
                     contextstack[stacktop-2].d.datatyp.typedata))^.kind;
  if (kinda = dk_float) or (kindb = dk_float) then begin
   result:= sdk_flo64;
   with contextstack[stacktop].d do begin
    if kind = ck_const then begin
     case constval.kind of
      dk_integer: begin
       push(info,real(constval.vinteger));
      end;
      dk_float: begin
       push(info,constval.vfloat);
      end;
     end;
    end
    else begin //ck_fact
     case kinda of
      dk_integer: begin
       int32toflo64(info,0);
      end;
     end;
    end;
   end;
   with contextstack[stacktop-2].d do begin
    if kind = ck_const then begin
     case kindb of
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
     case kindb of
      dk_integer: begin
        int32toflo64(info,-1);
      end;
     end;
    end;
   end;
  end
  else begin
   if kinda = dk_boolean then begin
    result:= sdk_bool8;
    with contextstack[stacktop-2].d do begin
     if kind = ck_const then begin
      case kindb of
       dk_boolean: begin
        push(info,constval.vboolean);
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
    with contextstack[stacktop-2].d do begin
     if kind = ck_const then begin
      case kindb of
       dk_integer: begin
        push(info,constval.vinteger);
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
  if reverse then begin
   result:= stackdatakindty(ord(result)+ord(reversestackdata));
  end;
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
          (@dummyop,@mulint32,@mulflo64,
           @dummyop,@mulint32,@mulflo64);
 
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
                    (@dummyop,@addint32,@addflo64,
                     @dummyop,@addint32,@addflo64);

procedure handleaddterm(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ADDTERM');
{$endif}
 outcommand(info,[-2,0],'+');
 writeop(info,addops[pushvalues(info)]);
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
  if findkindelements(info,stacktop-stackindex,[ek_var],vis_max,po1) then begin
   po2:= @po1^.data;
   inc(info^.stackindex);
   with contextstack[stackindex] do begin
    d.kind:= ck_const;
    d.datatyp.typedata:= po2^.typ;
    d.datatyp.flags:= [tf_reference];
    with d.constval do begin
     kind:= dk_address;
     vaddress.address:= po2^.address;
     vaddress.flags:= po2^.flags;
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

procedure handledereference(const info: pparseinfoty);
var
 po1: ptypedataty;
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle(info,'DEREFERENCE');
{$endif}
 with info^,contextstack[stacktop].d do begin
  int1:= -1;
  po1:= ele.eledataabs(datatyp.typedata);
  if po1^.kind = dk_reference then begin
   int1:= po1^.reflevel;
  end;
  if tf_reference in datatyp.flags then begin
   inc(int1);
  end;
  if int1 < 0 then begin
   errormessage(info,-1,err_illegalqualifier,[]);
  end
  else begin
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
 //dk_kind, dk_address,dk_record,dk_reference
   @dummyop,@dummyop,  @dummyop, @dummyop
 );

procedure handleterm1(const info: pparseinfoty);
var
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'TERM1');
{$endif}
 with info^ do begin
  if stackindex < stacktop then begin
   if contextstack[stackindex].d.kind = ck_neg then begin
    po1:= ele.eledataabs(contextstack[stacktop].d.datatyp.typedata);
    writeop(info,negops[po1^.kind]);
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

procedure handlevalueidentifier(const info: pparseinfoty);
var
 po1: pelementinfoty;
 po2: pointer;
 po3: ptypedataty;
 po4: pfielddataty;
 lastident: integer;
 idents: identvecty;
 ele1: elementoffsetty;
 int1: integer;
 si1,addr1: ptruint;
 fl1: typeflagsty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'VALUEIDENTIFIER');
{$endif}
 with info^ do begin
  if findkindelements(info,1,[ek_var,ek_const],vis_max,po1,lastident,
                                                         idents) then begin
   dec(stacktop,identcount);
   po2:= @po1^.data;
   case po1^.header.kind of
    ek_var: begin
     fl1:= [];
     addr1:= pvardataty(po2)^.address;
     ele1:= pvardataty(po2)^.typ;
     if vf_reference in pvardataty(po2)^.flags then begin
      include(fl1,tf_reference);
      si1:= pointersize;
     end
     else begin
      if lastident < identcount-1 then begin
       for int1:= lastident+1 to idents.high do begin //fields
        if not ele.findchild(ele1,idents.d[int1],[ek_field],
                                                    vis_max,ele1) then begin
         identerror(info,1+int1,err_identifiernotfound);
         exit;
        end;
        po4:= ele.eledataabs(ele1);
        addr1:= addr1 + po4^.offset;
       end;
       po3:= ele.eledataabs(po4^.typ);
       si1:= po3^.bytesize;      
      end
      else begin
       si1:= ptypedataty(ele.eledataabs(pvardataty(po2)^.typ))^.bytesize;
      end;
     end;
     with additem(info)^ do begin //todo: use table
      if vf_global in pvardataty(po2)^.flags then begin
       case si1 of
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
       d.dataaddress:= addr1;
      end
      else begin
       case si1 of
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
       d.count:= addr1 - frameoffset;
      end;
      d.datasize:= si1;
     end;
     with contextstack[stacktop].d do begin
      kind:= ck_fact;
      datatyp.typedata:= ele1;
      datatyp.flags:= fl1;
     end;
    end;
    ek_const: begin
     with contextstack[stacktop].d do begin
      kind:= ck_const;
      datatyp:= pconstdataty(po2)^.val.typ;
      constval:= pconstdataty(po2)^.val.d;
     end;
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
//   writeln(' ',contextstack[int1].d.ident.ident);
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
  d.vari.flags:= [];
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
      address:= getglobvaraddress(info,ptypedataty(@po2^.data)^.bytesize);
      flags:= [vf_global];
     end
     else begin
      address:= getlocvaraddress(info,ptypedataty(@po2^.data)^.bytesize);
      flags:= []; //local
     end;
     if tf_reference in contextstack[stackindex].d.vari.flags then begin
      include(flags,vf_reference);
     end;
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
  if tf_reference in flags then begin
   errormessage(info,-1,err_typeidentexpected,[]);
  end;
  include(flags,tf_reference);
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
  d.typ.flags:= [];
 end;
end;

procedure handlepointertype(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'POINTERTYPE');
{$endif}
 with info^,contextstack[stackindex] do begin
  include(d.typ.flags,tf_reference);
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
     if tf_reference in contextstack[stackindex].d.typ.flags then begin
      with ptypedataty(@po1^.data)^ do begin
       bytesize:= pointersize;
       kind:= dk_reference;
       target:= ele.eleinforel(po2);
       reflevel:= 0;
       if ptypedataty(@po2^.data)^.kind = dk_reference then begin
        reflevel:= ptypedataty(@po2^.data)^.reflevel + 1;
       end;
      end;
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
//  dec(stackindex);
  with contextstack[stacktop] do begin
   if d.kind = ck_const then begin
    pushconst(info,d);
    outcommand(info,[0],'push');
   end;
  end;
 end;
end;

procedure handlemain(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'MAIN');
{$endif}
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
 varinfo1: vardestinfoty;
 bo1: boolean;
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'ASSIGNMENT');
{$endif}
 with info^ do begin
  if (stacktop-stackindex > 1) then begin
   if findvar(info,1,vis_max,varinfo1) and not errorfla then begin
    bo1:= true;
    po1:= ele.eledataabs(contextstack[stacktop].d.datatyp.typedata);
    if varinfo1.typ^.kind <> po1^.kind then begin
     bo1:= false;
    end;
    if (vf_reference in varinfo1.flags) and 
        not (tf_reference in contextstack[stacktop].d.datatyp.flags) then begin
     bo1:= false;
    end;
    if not bo1 then begin
     assignmenterror(info,contextstack[stacktop].d,varinfo1);
    end
    else begin
     with additem(info)^ do begin
      if vf_global in varinfo1.flags then begin
       case varinfo1.typ^.bytesize of
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
       d.dataaddress:= varinfo1.address;
      end
      else begin
       case varinfo1.typ^.bytesize of
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
       d.count:= varinfo1.address;
      end;
      d.datasize:= varinfo1.typ^.bytesize;
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

procedure handleprocedure3(const info: pparseinfoty);
var
 po1: pfuncdataty;
 po2: pvardataty;
 po3: ptypedataty;
 po4: pelementoffsetaty;
 int1,int2: integer;
 paramco: integer;
 err1: boolean;
begin
{$ifdef mse_debugparser}
 outhandle(info,'PROCEDURE3');
{$endif}
//0          1     2          3          4    5
//procedure2,ident,paramsdef3{,paramdef2,name,type}
              //todo: multi level type
 with info^ do begin
  err1:= false;
  inc(funclevel);
  paramco:= (stacktop-stackindex-2) div 3;
  if ele.pushelement(contextstack[stackindex+1].d.ident.ident,vis_max,
                    ek_func,
                        paramco*sizeof(pvardataty),po1) then begin
   po1^.paramcount:= paramco;
   po4:= @po1^.paramsrel;
   int1:= 4;
   for int2:= 0 to paramco-1 do begin
    if ele.addelement(contextstack[int1+stackindex].d.ident.ident,vis_max,
                               ek_var,po2) then begin
     po4^[int2]:= ele.eledatarel(po2);
     if findkindelementsdata(info,int1+1,[ek_type],vis_max,po3) then begin
      with po2^ do begin
       address:= getlocvaraddress(info,po3^.bytesize);
       typ:= ele.eledatarel(po3);
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
   ele.markelement(d.proc.elementmark); 
  end;
//  ele.popelement;
 end;
end;

procedure handleprocedure6(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'PROCEDURE6');
{$endif}
 with info^ do begin
  ele.releaseelement(contextstack[stackindex].d.proc.elementmark); 
                                            //remove local definitions
  with additem(info)^ do begin
   op:= @returnop;
   d.count:= contextstack[stackindex].d.proc.paramcount+1;
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