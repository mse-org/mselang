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

procedure beginparser(const aoptable: poptablety; const assatable: pssatablety);
procedure endparser();

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
procedure handleexp1();
procedure handleeqsimpexp();
procedure handlenesimpexp();
procedure handlegtsimpexp();
procedure handleltsimpexp();
procedure handlegesimpexp();
procedure handlelesimpexp();

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
procedure handlesubterm();
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
procedure handledumpopcode();
procedure handleabort();
procedure handlestoponerror();
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
 subhandler,managedtypes,syssubhandler,valuehandler,segmentutils,listutils;

procedure beginparser(const aoptable: poptablety; const assatable: pssatablety);

var
 po1: pvardataty;
 ele1: elementoffsetty;
begin
 setoptable(aoptable,assatable);
// info.allocproc:= aallocproc;
 addvar(tk_exitcode,allvisi,info.s.unitinfo^.varchain,po1);
 ele.findcurrent(getident('int32'),[ek_type],allvisi,po1^.vf.typ);
 po1^.address.indirectlevel:= 0;
 po1^.address.flags:= [];
 po1^.address.segaddress:= getglobvaraddress(das_32,4,po1^.address.flags);
                                                               //i32 exitcode

// info.beginparseop:= info.opcount; 
 with additem(oc_beginparse)^ do begin
  with par.beginparse do begin //startup vector 
   exitcodeaddress:= po1^.address.segaddress;
  end;
 end;
end;

procedure endparser();
begin
 with getoppo(startupoffset)^.par.beginparse do begin
  unitinfochain:= info.unitinfochain;
//  globallocstart.segment:= seg_globalloc;
//  globallocstart.address:= 0;
//  globalloccount:= info.globallocid;
 end;
 with additem(oc_endparse)^ do begin
                    //startup vector 
 end;
end;

procedure handleprogbegin();
var
 ad1: listadty;
 ad2: opaddressty;
begin
{$ifdef mse_debugparser}
 outhandle('PROGBEGIN');
{$endif}
 with info do begin
  if stf_hasmanaged in s.currentstatementflags then begin
   if getinternalsub(isub_ini,ad2) then begin //no initialization
    writemanagedvarop(mo_ini,info.s.unitinfo^.varchain,true,0);
    endinternalsub();
   end;
   if getinternalsub(isub_fini,ad2) then begin  //no finalization
    writemanagedvarop(mo_fini,info.s.unitinfo^.varchain,true,0);
    endinternalsub();
   end;
  end;
  
  with getoppo(startupoffset)^ do begin
   par.beginparse.mainad:= opcount;
  end;
  resetssa();
  with info.contextstack[info.s.stackindex] do begin
   d.kind:= ck_prog;
   d.prog.blockcountad:= info.opcount;
  end;
  with additem(oc_main)^ do begin
   //blockcount set in handleprogblock() 
  end;
  with unitlinklist do begin
   ad1:= unitchain;
   while ad1 <> 0 do begin         //insert ini calls
    with punitlinkinfoty(list+ad1)^ do begin
     with ref^ do begin
      if internalsubs[isub_ini] <> 0 then begin
       callinternalsub(internalsubs[isub_ini]);
      end;
     end;
     ad1:= header.next;
    end;
   end;
  end;
 end;
end;

procedure handleprogblock();
var
 ad1: listadty;
 ad2: opaddressty;
begin
{$ifdef mse_debugparser}
 outhandle('PROGBLOCK');
{$endif}
// writeop(nil); //endmark
 handleunitend();
 invertlist(unitlinklist,unitchain);
 with unitlinklist do begin
  ad1:= unitchain;
  while ad1 <> 0 do begin         //insert ini calls
   with punitlinkinfoty(list+ad1)^ do begin
    with ref^ do begin
     if internalsubs[isub_fini] <> 0 then begin
      callinternalsub(internalsubs[isub_fini]);
     end;
    end;
    ad1:= header.next;
   end;
  end;
 end;
 with additem(oc_progend)^ do begin 
  //endmark, will possibly replaced by goto if there is fini code
 end;
 with info.contextstack[info.s.stackindex] do begin
  with getoppo(d.prog.blockcountad)^ do begin
   par.main.blockcount:= info.s.ssa.blockindex+1;
  end;  
 end;
 with info do begin
  dec(s.stackindex);
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
  with contextstack[s.stacktop] do begin
   consumed:= s.source.po;
   po1:= start.po;
   while (po1^ = '0') do begin
    inc(po1);
   end;
   c1:= 0;
 //  18446744073709551615
   int1:= 20-(consumed-po1);
   if (int1 < 0) or (int1 = 0) and (po1^ > '1') then begin
    errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
   end
   else begin
    while po1 < s.source.po do begin
     c1:= c1*10 + (ord(po1^)-ord('0'));
     inc(po1);
    end;
    if (int1 = 0) and (c1 < 10000000000000000000) then begin
     errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
    end;
   end;
   s.stackindex:= s.stacktop-1;
   d.kind:= ck_const;
   d.dat.indirection:= 0;
   d.dat.datatyp:= sysdatatypes[st_int32];
   d.dat.constval.kind:= dk_integer;
   d.dat.constval.vinteger:= int64(c1);     //todo: handle cardinals and 64 bit
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
  s.stackindex:= s.stackindex-1;
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlerange3();
begin
{$ifdef mse_debugparser}
 outhandle('RANGE3');
{$endif}
 with info do begin
  if s.stacktop-s.stackindex = 2 then begin
   if contextstack[s.stackindex+1].d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[],1);
   end
   else begin
    if contextstack[s.stackindex+2].d.kind <> ck_const then begin
     errormessage(err_constexpressionexpected,[],2);
    end
    else begin
     if contextstack[s.stackindex+1].d.dat.constval.kind <> 
              contextstack[s.stacktop].d.dat.constval.kind then begin
      incompatibletypeserror(contextstack[s.stackindex+1].d,
                                              contextstack[s.stacktop].d);
//     errormessage(info,err
     end
     else begin
      with contextstack[s.stackindex] do begin
       d.kind:= ck_range;
      end;
     end;
    end;
   end;
  end;
//  s.stacktop:= s.stackindex;
 end;
end;

procedure handlenumberentry();
begin
{$ifdef mse_debugparser}
 outhandle('NUMBERENTRY');
{$endif}
 with info,contextstack[s.stacktop].d do begin
  kind:= ck_number;
  number.flags:= [];
 end;
end;

procedure posnumber();
begin
{$ifdef mse_debugparser}
 outhandle('POSNUMBER');
{$endif}
 with info,contextstack[s.stacktop].d do begin
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
 with info,contextstack[s.stacktop].d do begin
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
 with info,contextstack[s.stacktop] do begin
  consumed:= s.source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
  if consumed-po1 > 64 then begin
   errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
  end
  else begin
   while po1 < s.source.po do begin
    c1:= c1*2 + (ord(po1^)-ord('0'));
    inc(po1);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(s.stackindex);
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
 with info,contextstack[s.stacktop] do begin
  consumed:= s.source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
//  1777777777777777777777
  int1:= 22-(consumed-po1);
  if (int1 < 0) or (int1 = 0) and (po1^ > '1') then begin
   errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
  end
  else begin
   while po1 < s.source.po do begin
    c1:= c1*8 + (ord(po1^)-ord('0'));
    inc(po1);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(s.stackindex);
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
 with info,contextstack[s.stacktop] do begin
  consumed:= s.source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
//  18446744073709551615
  int1:= 20-(consumed-po1);
  if (int1 < 0) or (int1 = 0) and (po1^ > '1') then begin
   errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
  end
  else begin
   while po1 < s.source.po do begin
    c1:= c1*10 + (ord(po1^)-ord('0'));
    inc(po1);
   end;
   if (int1 = 0) and (c1 < 10000000000000000000) then begin
    errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(s.stackindex);
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
 with info,contextstack[s.stacktop] do begin
  consumed:= s.source.po;
  po1:= start.po;
  while (po1^ = '0') do begin
   inc(po1);
  end;
  c1:= 0;
  if consumed-po1 > 16 then begin
   errormessage(err_invalidintegerexpression,[],s.stacktop-s.stackindex);
  end
  else begin
   while po1 < s.source.po do begin
    c1:= c1*$10 + hexchars[po1^];
    inc(po1);
   end;
  end;
  d.kind:= ck_number;
  d.number.value:= c1;
  dec(s.stackindex);
 end;
end;

procedure handlenumberexpected();
begin
{$ifdef mse_debugparser}
 outhandle('NUMBEREXPECTED');
{$endif}
 with info do begin
  illegalcharactererror(false);
//  errormessage(info,s.stacktop-s.stackindex,err_numberexpected,[]);
  dec(s.stackindex);
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
  with contextstack[s.stacktop] do begin
   fraclen:= asource-start.po;
  end;
  s.stacktop:= s.stacktop - 1;
  s.stackindex:= s.stacktop-1;
  with contextstack[s.stacktop] do begin
   d.kind:= ck_const;
   d.dat.indirection:= 0;
   d.dat.datatyp:= sysdatatypes[st_float64];
   d.dat.constval.kind:= dk_float;
   lint2:= 0;
   po1:= start.po;
   int1:= asource-po1-1;
   if int1 > 20 then begin
    errormessage(err_invalidfloat,[],s.stacktop-s.stackindex);
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
     errormessage(err_invalidfloat,[],s.stacktop-s.stackindex);
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
//  if s.stacktop > s.stackindex then begin //no exponent number error otherwise
   dofrac(s.source.po,{neg,}mant,fraclen);
   with contextstack[s.stacktop].d.dat.constval do begin
  //  vfloat:= mant/floatexps[fraclen]; //todo: round lsb;   
    vfloat:= mant*floatnegexps[fraclen]; //todo: round lsb;   
{
    if neg then begin
     vfloat:= -vfloat; 
    end;
}
    consumed:= s.source.po;
   end;
//  end
//  else begin
//   dec(s.stackindex);
//   s.stacktop:= s.stackindex;
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
  with contextstack[s.stacktop].d.number do begin
   exp:= value;
   if nuf_neg in flags then begin
    exp:= -exp;
   end;
  end;
  dec(s.stacktop,2);
  dofrac(contextstack[s.stackindex].start.po-1,{neg,}mant,fraclen);
  if fraclen < 0 then begin
   fraclen:= 0;  //no frac 123e4
  end;
  exp:= exp-fraclen;
  with contextstack[s.stacktop] do begin
   consumed:= s.source.po; //todo: overflow check
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
   with d.dat.constval do begin
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
  exp:= contextstack[s.stacktop].d.constval.vinteger;
  dec(s.stacktop,3);
  dofrac(info,contextstack[s.stackindex-1].start.po,neg,mant,fraclen);
  exp:= exp+fraclen;
  with contextstack[s.stacktop] do begin
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
 mulops: opsinfoty = (ops: (oc_none,oc_none,oc_none,oc_mulint32,oc_mulflo64);
                     opname: '*');
 
procedure handlemulfact();
begin
{$ifdef mse_debugparser}
 outhandle('MULFACT');
{$endif}
 updateop(mulops);
end;
//todo: different datasizes
const
 addops: opsinfoty = (ops: (oc_none,oc_none,oc_none,oc_addint32,oc_addflo64);
                     opname: '+');
 subops: opsinfoty = (ops: (oc_none,oc_none,oc_none,oc_subint32,oc_subflo64);
                     opname: '-');

procedure addsubterm(const issub: boolean);
 
 procedure opnotsupported();
 var
  ch1: char;
 begin
  with info,contextstack[s.stacktop-2] do begin
   if issub then begin
    ch1:= '-';
   end
   else begin
    ch1:= '+';
   end;
   operationnotsupportederror(d,contextstack[s.stacktop].d,ch1);
  end;
 end; //opnotsupported
 
var 
 dk1: stackdatakindty;
 i1,i2: int32;
 poa,pob: pcontextitemty;
label
 errlab;
begin
 with info do begin
  poa:= @contextstack[s.stacktop-2];
  pob:= @contextstack[s.stacktop];
  with poa^ do begin
   if (pob^.d.kind = ck_const) and 
               (d.kind = ck_const) then begin
    dk1:= convertconsts();
    case dk1 of
     sdk_int32: begin
      if issub then begin
       d.dat.constval.vinteger:= d.dat.constval.vinteger -
                pob^.d.dat.constval.vinteger;
      end
      else begin
       d.dat.constval.vinteger:= d.dat.constval.vinteger + 
                pob^.d.dat.constval.vinteger;
      end;
     end;
     sdk_flo64: begin
      if issub then begin
       d.dat.constval.vfloat:= d.dat.constval.vfloat + 
                             pob^.d.dat.constval.vfloat;
      end
      else begin
       d.dat.constval.vfloat:= d.dat.constval.vfloat + 
                             pob^.d.dat.constval.vfloat;
      end;
     end;
     else begin
      opnotsupported();
     end;
    end;
    dec(s.stacktop,2);
    s.stackindex:= s.stacktop-1;
   end
   else begin
   {$ifdef mse_debugparser}
    if not (d.kind in datacontexts) or 
              not (pob^.d.kind in datacontexts)then begin
     internalerror(ie_handler,'20150320B');
    end;
   {$endif}
    if d.dat.datatyp.indirectlevel > 0 then begin //pointer math
     i1:= pob^.d.dat.datatyp.indirectlevel;
     if d.dat.datatyp.indirectlevel = i1 then begin
                                                                 //pointer diff
      if not issub then begin
       opnotsupported();
      end
      else begin
       notimplementederror('20150320D');
      end;
     end
     else begin
      if d.dat.datatyp.indirectlevel > 1 then begin
       i2:= pointersize;
      end
      else begin
       with ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^ do begin
        if datasize = das_pointer then begin
         i2:= 1;
        end
        else begin
         i2:= bytesize;
        end;
       end;
      end;
      if i1 = 0 then begin  //inc/dec
       if pob^.d.kind = ck_const then begin
        if pob^.d.dat.constval.kind <> dk_integer then begin
         opnotsupported();
         goto errlab;
        end
        else begin
         if issub then begin
          pob^.d.dat.constval.vinteger:= -pob^.d.dat.constval.vinteger;
         end;
         pob^.d.dat.constval.vinteger:= pob^.d.dat.constval.vinteger*i2;
         i2:= s.stacktop-s.stackindex-2;
         getvalue(i2);
         i1:= d.dat.fact.ssaindex;
         with additem(oc_offsetpoimm32)^ do begin
          par.imm.vint32:= pob^.d.dat.constval.vinteger;
          if backend = bke_llvm then begin
           par.imm.llvm:= constlist.addi32(par.imm.vint32);
          end;
          par.ssas1:= i1;
         end;
        end;
       end
       else begin
        i1:= s.stacktop-s.stackindex;
        if getvalue(s.stacktop-s.stackindex-2) and getvalue(i1) then begin
         if tryconvert(i1,st_int32) then begin //todo: data size
          i1:= pob^.d.dat.fact.ssaindex;
          if i2 <> 1 then begin
           with additem(oc_mulimmint32)^ do begin
            par.imm.vint32:= i2;
            par.ssas1:= i1;
           end;
           i1:= s.ssa.nextindex-1;
          end;
          with additem(oc_addpoint32)^ do begin
           par.ssas1:= d.dat.fact.ssaindex;
           par.ssas2:= i1;
          end;
          pob^.d.dat.fact.ssaindex:= s.ssa.nextindex-1;
         end
         else begin
          opnotsupported();
         end;
        end;
       end;
      end
      else begin
       opnotsupported();
      end;
     end;
 errlab:
     dec(s.stacktop,2);
     s.stackindex:= s.stacktop-1;
    end
    else begin
     if issub then begin
      updateop(subops);
     end
     else begin
      updateop(addops);
     end;
    end;
   end;
  end;
 end;
// outhandle('ADDSUBTERM2');
end;

procedure handleaddterm();
begin
{$ifdef mse_debugparser}
 outhandle('ADDTERM');
{$endif}
 addsubterm(false);
end;

procedure handlesubterm();
begin
{$ifdef mse_debugparser}
 outhandle('SUBTERM');
{$endif}
 addsubterm(true);
end;

procedure handleterm();
begin
{$ifdef mse_debugparser}
 outhandle('TERM');
{$endif}
 with info do begin
  if s.stacktop-s.stackindex = 1 then begin
   contextstack[s.stackindex].d:= contextstack[s.stackindex+1].d;
  end;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
 end;
end;

procedure handledereference();
var
 po1: ptypedataty;
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('DEREFERENCE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if d.dat.datatyp.indirectlevel <= 0 then begin
   errormessage(err_illegalqualifier,[]);
  end
  else begin
   dec(d.dat.datatyp.indirectlevel);
   dec(d.dat.indirection);
   case d.kind of
    ck_ref: begin
    end;
    ck_const: begin
     if d.dat.constval.kind <> dk_address then begin
      errormessage(err_cannotderefnonpointer,[],s.stacktop-s.stackindex);
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
 with info,contextstack[s.stacktop] do begin
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
 with info,contextstack[s.stacktop] do begin
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
 with info,contextstack[s.stacktop].d.getfact do begin
  if ff_address in flags then begin
   errormessage(err_cannotassigntoaddr,[]);
  end;
  include(flags,ff_address);
 end;
end;

const
 negops: array[datakindty] of opcodety = (
 //dk_none, dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,
   oc_none, oc_none,   oc_none,   oc_negcard32, oc_negint32, oc_negflo64,
 //dk_kind, dk_address,dk_record,dk_string8,dk_dynarray,
   oc_none, oc_none,   oc_none,  oc_none,   oc_none,
 //dk_array,dk_class,dk_interface,
   oc_none, oc_none, oc_none,
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
  if s.stackindex < s.stacktop then begin
   with contextstack[s.stacktop] do begin
    case d.kind of
     ck_str: begin
      d.kind:= ck_const;
      d.dat.indirection:= 0;
      d.dat.datatyp:= sysdatatypes[st_string8];
      d.dat.constval.kind:= dk_string8;
      d.dat.constval.vstring:= newstring();
     end;
     ck_number: begin
      c1:= d.number.value;
      d.kind:= ck_const;
      d.dat.indirection:= 0;
      d.dat.datatyp:= sysdatatypes[st_int32];
      d.dat.constval.kind:= dk_integer;
      d.dat.constval.vinteger:= int64(c1); 
          //todo: handle cardinals and 64 bit
     end;
    end;
   end;
   with contextstack[s.stackindex] do begin
    fl1:= [];
    if d.kind = ck_getfact then begin
     fl1:= d.getfact.flags;
    end;
    d:= contextstack[s.stacktop].d;
    if ff_address in fl1 then begin
     case d.kind of
      ck_const: begin
       errormessage(err_cannotaddressconst,[],1);
      end;
      ck_ref: begin
       inc(d.dat.indirection);
       inc(d.dat.datatyp.indirectlevel);
      end;
      ck_fact: begin
       errormessage(err_cannotaddressexp,[],1);
      end;
      ck_typearg: begin
       errormessage(err_cannotaddresstype,[],1);
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
   errormessage(err_illegalexpression,[],s.stacktop-s.stackindex);
  end;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
 end;
end;

procedure handlefact2entry();
begin
{$ifdef mse_debugparser}
 outhandle('FACT2ENTRY');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if s.stacktop-s.stackindex <> 1 then begin
   internalerror(ie_handler,'20140406B');
  end;
 {$endif}
  contextstack[s.stackindex].d:= contextstack[s.stackindex+1].d;
  dec(s.stacktop);
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
 with info,contextstack[s.stacktop] do begin
 {$ifdef mse_checkinternalerror}
  if s.stacktop-s.stackindex <> 1 then begin
   internalerror(ie_handler,'20140404A');
  end;
 {$endif}
  if d.kind = ck_const then begin
   with d.dat.constval do begin
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
    po1:= ele.eledataabs(d.dat.datatyp.typedata);
    with additem(negops[po1^.kind])^ do begin
     if op.op = oc_none then begin
      errormessage(err_negnotpossible,[],1);
     end;
    end;
   end;
  end;
  contextstack[s.stackindex].d:= d;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
 end;
end;

procedure handlesimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('SIMPEXP');
{$endif}
 with info do begin
  contextstack[s.stacktop-1]:= contextstack[s.stacktop];
  dec(s.stacktop);
  s.stackindex:= s.stacktop;
  dec(s.stackindex);
 end;
end;

procedure handlesimpexp1();
begin
{$ifdef mse_debugparser}
 outhandle('SIMPEXP1');
{$endif}
 with info do begin
  if s.stacktop > s.stackindex then begin
   contextstack[s.stacktop-1]:= contextstack[s.stacktop];
  end;
  dec(s.stacktop);
  dec(s.stackindex);
 end;
end;

procedure handlebracketend();
begin
{$ifdef mse_debugparser}
 outhandle('BRACKETEND');
{$endif}
 with info do begin
  if s.source.po^ <> ')' then begin
   tokenexpectederror(')',erl_error);
//   error(ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(s.source.po);
  end;
  if s.stackindex < s.stacktop then begin
   contextstack[s.stacktop-1]:= contextstack[s.stacktop];
  end
  else begin
   errormessage(err_expressionexpected,[]);
//   error(ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
  end;
  dec(s.stacktop);
  dec(s.stackindex);
 end;
end;

procedure handleident();
begin
{$ifdef mse_debugparser}
 outhandle('IDENT');
{$endif}
 with info,contextstack[s.stacktop],d do begin
  kind:= ck_ident;
  ident.len:= s.source.po-start.po;
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
 with info,contextstack[s.stacktop],d do begin
  kind:= ck_ident;
  ident.len:= s.source.po-start.po;
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
 with info,contextstack[s.stacktop],d do begin
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
 with info,contextstack[s.stacktop],d do begin
  kind:= ck_end;
 end;
end;

procedure handleblockend();
begin
{$ifdef mse_debugparser}
 outhandle('BLOCKEND');
{$endif}
// with info^ do begin
//  s.stackindex:= s.stackindex-2;
// end;
end;
(*
procedure handleparamstart0();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSTART0');
{$endif}
 with info^,contextstack[s.stacktop] do begin
  parent:= s.stacktop;
 end;
end;

procedure handleparam();
begin
{$ifdef mse_debugparser}
 outhandle('PARAM');
{$endif}
 with info^,contextstack[s.stacktop] do begin
  s.stackindex:= parent+1;
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
 with info do begin
  if s.unitinfo^.prev <> nil then begin
   tokenexpectederror(tk_implementation);
  end;
  //  s.stackindex:= -1;
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
  dec(s.stackindex);
 end;
end;

procedure handleuseserror();
begin
{$ifdef mse_debugparser}
 outhandle('USESERROR');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
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
  int2:= s.stacktop-s.stackindex-1;
  setlength(ar1,int2);
  for int1:= 0 to int2-1 do begin
   if not ele.addelement(contextstack[s.stackindex+int1+2].d.ident.ident,
                                    ek_uses,[vik_global],ar1[int1]) then begin
    identerror(int1+2,err_duplicateidentifier);
   end;
  end;
//  offs1:= ele.decelementparent;
  with s.unitinfo^ do begin
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
  for int1:= s.stackindex+2 to s.stacktop do begin
   dec(po1);
   po1^:= loadunit(int1);
   if po1^ = nil then begin
    s.stopparser:= true;
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
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlenoidenterror();
begin
{$ifdef mse_debugparser}
 outhandle('NOIDENTERROR');
{$endif}
 errormessage(err_identexpected,[],minint,0,erl_fatal);
end;

procedure handlecommentend();
begin
{$ifdef mse_debugparser}
 outhandle('COMMENTEND');
{$endif}
 with info do begin
  dec(s.stacktop);
 end;
end;
(*
procedure handleconst();
begin
{$ifdef mse_debugparser}
 outhandle('CONST');
{$endif}
 with info^,contextstack[s.stacktop] do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleconst0();
begin
{$ifdef mse_debugparser}
 outhandle('CONST0');
{$endif}
// with info^,contextstack[s.stacktop] do begin
//  dec(s.stackindex);
//  s.stacktop:= s.stackindex;
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
  if (s.stacktop-s.stackindex <> 2) or 
            (contextstack[s.stackindex+1].d.kind <> ck_ident) then begin
   internalerror(ie_handler,'20140326C');
  end;
 {$endif}
  if contextstack[s.stacktop].d.kind <> ck_const then begin
   errormessage(err_constexpressionexpected,[],s.stacktop-s.stackindex);
  end
  else begin
   if not ele.addelementdata(contextstack[s.stackindex+1].d.ident.ident,
                                            ek_const,allvisi,po1) then begin
    identerror(1,err_duplicateidentifier);
   end
   else begin
    with contextstack[s.stacktop].d do begin
     po1^.val.typ:= dat.datatyp;
     po1^.val.d:= dat.constval;
    end;
   end;
  end;
  s.stackindex:= s.stackindex;
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleexp();
begin
{$ifdef mse_debugparser}
 outhandle('EXP');
{$endif}
 with info do begin
  contextstack[s.stacktop-1].d:= contextstack[s.stacktop].d;
  dec(s.stacktop);
 end;
end;

procedure handleexp1();
begin
{$ifdef mse_debugparser}
 outhandle('EXP1');
{$endif}
 with info do begin
  contextstack[s.stacktop-1].d:= contextstack[s.stacktop].d;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
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
//  if unitlevel = 1 then begin
//   errormessage(err_syntax,['begin']);
//  end;
  dec(s.stackindex);
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
 with info^,contextstack[s.stacktop],d do begin
  ident1:= ident;
  s.stacktop:= s.stackindex;
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
 with info,contextstack[s.stacktop],d do begin
  kind:= ck_ident;
  ident.len:= s.source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
 end;
end;

type
 cmpopty = (cmpo_eq,cmpo_ne,cmpo_gt,cmpo_lt,cmpo_ge,cmpo_le);
const
 cmpops: array[cmpopty] of opsinfoty = (
  (ops: (oc_none,oc_cmpeqpo,oc_cmpeqbool,oc_cmpeqint32,
                        oc_cmpeqflo64);
                        opname: '='),
  (ops: (oc_none,oc_cmpnepo,oc_cmpnebool,
                        oc_cmpneint32,oc_cmpneflo64);
                        opname: '<>'),
  (ops: (oc_none,oc_cmpgtpo,oc_cmpgtbool,
                        oc_cmpgtint32,oc_cmpgtflo64);
                        opname: '>'),
  (ops: (oc_none,oc_cmpltpo,oc_cmpltbool,
                        oc_cmpltint32,oc_cmpltflo64);
                        opname: '<'),
  (ops: (oc_none,oc_cmpgepo,oc_cmpgebool,
                        oc_cmpgeint32,oc_cmpgeflo64);
                        opname: '>='),
  (ops: (oc_none,oc_cmplepo,oc_cmplebool,
                        oc_cmpleint32,oc_cmpleflo64);
                        opname: '<=')
 );

procedure handlecomparison(const aop: cmpopty);

 procedure notsupported();
 begin
  with info,contextstack[s.stacktop-2] do begin
   operationnotsupportederror(d,contextstack[s.stacktop].d,cmpops[aop].opname);
  end;
 end;

var
 dk1:stackdatakindty;
 int1: integer;
begin
 with info,contextstack[s.stacktop-2] do begin
  if (contextstack[s.stacktop].d.kind = ck_const) and 
                                               (d.kind = ck_const) then begin
   dk1:= convertconsts();
   d.dat.constval.kind:= dk_boolean;
   d.dat.datatyp:= sysdatatypes[st_bool1];
   case aop of
    cmpo_eq: begin
     case dk1 of
      sdk_int32: begin
       d.dat.constval.vboolean:= d.dat.constval.vinteger = 
                 contextstack[s.stacktop].d.dat.constval.vinteger;
      end;
      sdk_flo64: begin
       d.dat.constval.vboolean:= d.dat.constval.vfloat = 
                              contextstack[s.stacktop].d.dat.constval.vfloat;
      end;
      sdk_bool1: begin
       d.dat.constval.vboolean:= d.dat.constval.vboolean =
                              contextstack[s.stacktop].d.dat.constval.vboolean;
      end;
      sdk_pointer: begin
       d.dat.constval.vboolean:= compaddress(d.dat.constval.vaddress,
                  contextstack[s.stacktop].d.dat.constval.vaddress) = 0;
      end;
      else begin
       notsupported();
      end;
     end;
    end;
    cmpo_ne: begin
     case dk1 of
      sdk_int32: begin
       d.dat.constval.vboolean:= d.dat.constval.vinteger <>
                 contextstack[s.stacktop].d.dat.constval.vinteger;
      end;
      sdk_flo64: begin
       d.dat.constval.vboolean:= d.dat.constval.vfloat <>
                              contextstack[s.stacktop].d.dat.constval.vfloat;
      end;
      sdk_bool1: begin
       d.dat.constval.vboolean:= d.dat.constval.vboolean <>
                              contextstack[s.stacktop].d.dat.constval.vboolean;
      end;
      else begin
       notsupported();
      end;
     end;
    end;
    cmpo_gt: begin
     case dk1 of
      sdk_int32: begin
       d.dat.constval.vboolean:= d.dat.constval.vinteger >
                 contextstack[s.stacktop].d.dat.constval.vinteger;
      end;
      sdk_flo64: begin
       d.dat.constval.vboolean:= d.dat.constval.vfloat >
                              contextstack[s.stacktop].d.dat.constval.vfloat;
      end;
      sdk_bool1: begin
       d.dat.constval.vboolean:= d.dat.constval.vboolean >
                              contextstack[s.stacktop].d.dat.constval.vboolean;
      end;
      else begin
       notsupported();
      end;
     end;
    end;
    cmpo_lt: begin
     case dk1 of
      sdk_int32: begin
       d.dat.constval.vboolean:= d.dat.constval.vinteger <
                 contextstack[s.stacktop].d.dat.constval.vinteger;
      end;
      sdk_flo64: begin
       d.dat.constval.vboolean:= d.dat.constval.vfloat <
                              contextstack[s.stacktop].d.dat.constval.vfloat;
      end;
      sdk_bool1: begin
       d.dat.constval.vboolean:= d.dat.constval.vboolean <
                              contextstack[s.stacktop].d.dat.constval.vboolean;
      end;
     end;
    end;
    cmpo_ge: begin
     case dk1 of
      sdk_int32: begin
       d.dat.constval.vboolean:= d.dat.constval.vinteger >=
                 contextstack[s.stacktop].d.dat.constval.vinteger;
      end;
      sdk_flo64: begin
       d.dat.constval.vboolean:= d.dat.constval.vfloat >=
                              contextstack[s.stacktop].d.dat.constval.vfloat;
      end;
      sdk_bool1: begin
       d.dat.constval.vboolean:= d.dat.constval.vboolean >=
                              contextstack[s.stacktop].d.dat.constval.vboolean;
      end;
      else begin
       notsupported();
      end;
     end;
    end;
    cmpo_le: begin
     case dk1 of
      sdk_int32: begin
       d.dat.constval.vboolean:= d.dat.constval.vinteger <=
                 contextstack[s.stacktop].d.dat.constval.vinteger;
      end;
      sdk_flo64: begin
       d.dat.constval.vboolean:= d.dat.constval.vfloat <=
                              contextstack[s.stacktop].d.dat.constval.vfloat;
      end;
      sdk_bool1: begin
       d.dat.constval.vboolean:= d.dat.constval.vboolean <=
                              contextstack[s.stacktop].d.dat.constval.vboolean;
      end;
      else begin
       notsupported();
      end;
     end;
    end;
   end;
   dec(s.stacktop,2);
   s.stackindex:= s.stacktop-1;
  end
  else begin
   updateop(cmpops[aop]);
   with info,contextstack[s.stacktop] do begin
    d.dat.datatyp:= sysdatatypes[resultdatatypes[sdk_bool1]];
   end;
  end;
 end;
end;

procedure handleeqsimpexp();
var
 dk1:stackdatakindty;
begin
{$ifdef mse_debugparser}
 outhandle('EQSIMPEXP');
{$endif}
 handlecomparison(cmpo_eq);
end;

procedure handlenesimpexp();
var
 dk1:stackdatakindty;
begin
{$ifdef mse_debugparser}
 outhandle('NESIMPEXP');
{$endif}
 handlecomparison(cmpo_ne);
end;

procedure handlegtsimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('GTSIMPEXP');
{$endif}
 handlecomparison(cmpo_gt);
end;

procedure handleltsimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('LTSIMPEXP');
{$endif}
 handlecomparison(cmpo_lt);
end;

procedure handlegesimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('GESIMPEXP');
{$endif}
 handlecomparison(cmpo_ge);
end;

procedure handlelesimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('LESIMPEXP');
{$endif}
 handlecomparison(cmpo_le);
end;

procedure handlecommaseprange();
begin
{$ifdef mse_debugparser}
 outhandle('COMMASEPRANGE');
{$endif}
 with info do begin
  if s.stacktop-s.stackindex = 2 then begin
   include(contextstack[s.stacktop].d.dat.datatyp.flags,tf_upper);
   include(contextstack[s.stacktop-1].d.dat.datatyp.flags,tf_lower);
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
  include(s.currentstatementflags,stf_rightside);
 end;
end;

type
 movedestty = (mvd_segment,mvd_local,mvd_param,mvd_paramindi);
 
const                //todo: segment and local indirect
 popoptable: array[movedestty] of array [databitsizety] of opcodety = (

 //das_none, das_1,     das_2_7,   das_8,                  //pd_segment
  (oc_popseg,oc_popseg8,oc_popseg8,oc_popseg8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_popseg16,oc_popseg16,oc_popseg32,oc_popseg32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_popseg64,oc_popseg64,oc_popsegpo,oc_popsegf16,oc_popsegf32,oc_popsegf64,
 //das_sub
   oc_popsegpo), 
 //das_none, das_1,     das_2_7,   das_8,                  //pd_local
  (oc_poploc,oc_poploc8,oc_poploc8,oc_poploc8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_poploc16,oc_poploc16,oc_poploc32,oc_poploc32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_poploc64,oc_poploc64,oc_poplocpo,oc_poplocf16,oc_poplocf32,oc_poplocf64,
 //das_sub
   oc_poplocpo), 
 //das_none, das_1,     das_2_7,   das_8,                  //pd_param
  (oc_poppar,oc_poppar8,oc_poppar8,oc_poppar8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_poppar16,oc_poppar16,oc_poppar32,oc_poppar32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_poppar64,oc_poppar64,oc_popparpo,oc_popparf16,oc_popparf32,oc_popparf64,
 //das_sub
   oc_popparpo
   ), 
 //das_none, das_1,     das_2_7,   das_8,                  //pd_paramindi
  (oc_popparindi,oc_popparindi8,oc_popparindi8,oc_popparindi8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_popparindi16,oc_popparindi16,oc_popparindi32,oc_popparindi32,
 //das_33_63,      das_64,         das_pointer,
   oc_popparindi64,oc_popparindi64,oc_popparindipo,
 //das_f16,         das_f32,          das_f64
   oc_popparindif16,oc_popparindif32,oc_popparindif64,
 //das_sub
   oc_popparindipo
   ) 
 );
 
{
function getmovesize(const asize: integer): movesizety; inline;
begin
 case asize of
  1: begin
   result:= mvs_8;
  end;
  2: begin
   result:= mvs_16;
  end;
  3,4: begin
   result:= mvs_32;
  end;
  else begin
   result:= mvs_bytes;
  end;
 end; 
end;
}
function getmovedest(const aflags: addressflagsty): movedestty; inline;
            //todo: use table
begin
 result:= mvd_local;
 if af_segment in aflags then begin
  result:= mvd_segment;
 end
 else begin
  if af_param in aflags then begin
   if af_paramindirect in aflags then begin
    result:= mvd_paramindi;
   end
   else begin
    result:= mvd_param;
   end;
  end;
 end;
end;

const
 popindioptable: array[databitsizety] of opcodety = (
 //das_none,      das_1,          das_2_7,        das_8,
   oc_popindirect,oc_popindirect8,oc_popindirect8,oc_popindirect8,
 //das_9_15,        das_16,          das_17_31,       das_32,
   oc_popindirect16,oc_popindirect16,oc_popindirect32,oc_popindirect32,
 //das_33_63,       das_64,          das_pointer
   oc_popindirect64,oc_popindirect64,oc_popindirectpo,
 //das_f16,          das_f32,          das_f64
   oc_popindirectf16,oc_popindirectf32,oc_popindirectf64,
 //das_sub
   oc_popindirectpo
   );

procedure handleassignment();
var
 dest: vardestinfoty;
 typematch,indi,isconst: boolean;
 datasi1: databitsizety;
 int1: integer;
 offs1: dataoffsty;
 ad1: addressrefty;
 ssa1: integer;
 po1: popinfoty;
 ssaextension1: integer;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENT');
{$endif}
 with info do begin       //todo: use direct move if possible
  if (s.stacktop-s.stackindex = 2) and not errorfla then begin
   isconst:= contextstack[s.stackindex+2].d.kind = ck_const;
   if not getaddress(1,false) or not getvalue(2) then begin
    goto endlab;
   end;
   with contextstack[s.stackindex+1] do begin //dest address
    typematch:= false;
    indi:= false;
    dest.offset:= 0;
    dest.typ:= ele.eledataabs(d.dat.datatyp.typedata);
    dec(d.dat.datatyp.indirectlevel);
   {$ifdef mse_checkinternalerror}
    if d.dat.datatyp.indirectlevel < 0 then begin
     internalerror(ie_handler,'20131126B');
    end;
   {$endif}
    datasi1:= dest.typ^.datasize;
    if d.dat.datatyp.indirectlevel >= 1 then begin
     datasi1:= das_pointer;
    end;
    case d.kind of
     ck_const: begin
      if d.dat.constval.kind <> dk_address then begin
       errormessage(err_argnotassign,[],0);
      end
      else begin
       dest.address:= d.dat.constval.vaddress;
       typematch:= true;
      end;
     end;
     ck_ref{const}: begin
      dest.address:= d.dat.ref.c.address;
      dest.offset:= d.dat.ref.offset;
      typematch:= true;
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
    dest.address.indirectlevel:= d.dat.datatyp.indirectlevel;
   end;
   if typematch and not errorfla then begin
    int1:= dest.address.indirectlevel;
    if af_paramindirect in dest.address.flags then begin
     dec(int1);
    end;
                         //todo: use destinationaddress directly
    typematch:= tryconvert(s.stacktop-s.stackindex,dest.typ,int1);
    if not typematch then begin
     assignmenterror(contextstack[s.stacktop].d,dest);
    end
    else begin
     ssa1:= contextstack[s.stacktop].d.dat.fact.ssaindex; //source
     if (int1 = 0) and (tf_hasmanaged in dest.typ^.flags) then begin
      ad1.base:= ab_stack;
      if datasi1 = das_pointer then begin
       ad1.offset:= -pointersize;
      end
      else begin
       ad1.offset:= -dest.typ^.bytesize;
      end;
//      ad1.offset:= -((si1+7) div 8); //bytes
      if not isconst then begin
       writemanagedtypeop(mo_incref,dest.typ,ad1,ssa1);
      end;
      if indi then begin
//       dec(ad1.offset,si1);
       ad1.offset:= 0;
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
      writemanagedtypeop(mo_decref,dest.typ,ad1,0);
     end;

     if indi then begin
      po1:= additem(popindioptable[datasi1]);
     end
     else begin
      if af_aggregate in dest.address.flags then begin
       ssaextension1:= getssa(ocssa_aggregate);
      end
      else begin
       ssaextension1:= 0;
      end;
      if not (af_segment in dest.address.flags) then begin
       int1:= sublevel - dest.address.locaddress.framelevel-1;
       if int1 >= 0 then begin
        ssaextension1:= ssaextension1 + getssa(ocssa_popnestedvar);
       end;
      end;
      po1:= additem(popoptable[
                     getmovedest(dest.address.flags)][datasi1],
                     ssaextension1);
      if af_segment in dest.address.flags then begin
       po1^.par.memop.segdataaddress.a:= dest.address.segaddress;
       po1^.par.memop.segdataaddress.offset:= dest.offset;
//       po1^.par.memop.segdataaddress.datasize:= 0;
      end
      else begin
       po1^.par.memop.locdataaddress.a:= dest.address.locaddress;
       po1^.par.memop.locdataaddress.a.framelevel:= int1;
       po1^.par.memop.locdataaddress.offset:= dest.offset;
      end;
     end;
     po1^.par.memop.t:= getopdatatype(dest);
     po1^.par.ssas1:= ssa1;                                         //source
     po1^.par.ssas2:= contextstack[s.stacktop-1].d.dat.fact.ssaindex; //dest
    end;
   end;
  end
  else begin
   errormessage(err_illegalexpression,[]);
  end;
endlab:
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handledoexpected();
begin
{$ifdef mse_debugparser}
 outhandle('DOEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('do');
  dec(s.stackindex);
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
 with info,contextstack[s.stacktop] do begin
  case d.kind of
   ck_ref: begin
    po1:= ele.eledataabs(d.dat.datatyp.typedata);
    if (d.dat.datatyp.indirectlevel = 0) and 
                         (po1^.kind in [dk_record,dk_class]) then begin

     with pvardataty(ele.addscope(ek_var,d.dat.datatyp.typedata))^ do begin
      address:= d.dat.ref.c.address;
      address.poaddress:= address.poaddress + d.dat.ref.offset;
      vf.typ:= d.dat.datatyp.typedata;
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
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlewith3();
begin
{$ifdef mse_debugparser}
 outhandle('WITH3');
{$endif}
 with info do begin
  ele.popscopelevel();
  dec(s.stackindex);
 end;
end;

procedure handlestatement0entry();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENT0ENTRY');
{$endif}
 with info do begin
//  opshift:= 0;
  s.currentstatementflags-= [stf_rightside,stf_params,
                           stf_leftreference,stf_proccall];
  with contextstack[s.stacktop].d,statement do begin
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
  if s.stacktop-s.stackindex <> 1 then begin
   internalerror(ie_handler,'20140216A');
  end;
 {$endif}
  with contextstack[s.stacktop].d do begin
   case kind of
    ck_subres: begin
     with additem(oc_pop)^ do begin      
      setimmsize(getbytesize(dat.fact.opdatatype),par); //todo: alignment
//      setimmsize((dat.fact.databitsize+7) div 8,par); //todo: alignment
     end;    
    end;
    ck_subcall: begin
    end;
    else begin
     errormessage(err_illegalexpression,[],1);
    end;
   end;
  end;
  dec(s.stackindex);
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
  if (s.stacktop - s.stackindex = 1) then begin
   with contextstack[s.stacktop] do begin
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
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
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
   paramco:= s.stacktop-s.stackindex-1-identcount;
   if paramco <> po2^.paramcount then begin
    identerror(info,1,err_wrongnumberofparameters);
   end
   else begin
    po3:= @po2^.paramsrel;
    for int1:= s.stackindex+3 to s.stacktop do begin
     po4:= ele.eledataabs(po3^);
     with contextstack[int1] do begin
      if d.datatyp.typedata <> po4^.typ then begin
       errormessage(int1-s.stackindex,err_incompatibletypeforarg,
         [int1-s.stackindex-2,typename(d),
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
   dec(s.stackindex);
   s.stacktop:= s.stackindex;
  end
  else begin
   if findkindelementsdata(info,1,[ek_sysfunc],vis_max,po1) then begin
    with po1^ do begin
     case func of
      sf_writeln: begin
       int2:= s.stacktop-s.stackindex-2;
       for int1:= 3+s.stackindex to int2+2+s.stackindex do begin
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
   dec(s.stackindex);
   s.stacktop:= s.stackindex;
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
 with info^,contextstack[s.stackindex].d.statement do begin
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
  dec(s.stackindex);
 end;
end;

procedure handlestatementblock1();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENTBLOCK1');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
  dec(s.stackindex);
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
  dec(s.stackindex);
 end;
end;

procedure handledumpopcode();
begin
{$ifdef mse_debugparser}
 dumpops();
{$endif}
 with info do begin
  dec(s.stackindex);
 end;
end;

procedure handleabort();
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  s.stopparser:= true;
  errormessage(err_abort,[]);
  dec(s.stackindex);
 end;
end;

procedure handlestoponerror();
var
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  s.unitinfo^.stoponerror:= true;
  dec(s.stackindex);
 end;
end;

procedure handlenop();
begin
{$ifdef mse_debugparser}
 outhandle('NOP');
{$endif}
 additem(oc_nop);
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
  with contextstack[s.stacktop] do begin
   d.kind:= ck_str;
   d.str.start:= s.source.po;
  end;
 end;
end;

procedure copystring();
begin
{$ifdef mse_debugparser}
 outhandle('COPYSTRING');
{$endif}
 with info do begin
  with contextstack[s.stacktop] do begin
   stringbuffer:= stringbuffer+psubstr(d.str.start,s.source.po-1);
   d.str.start:= s.source.po;
  end;
 end;
end;

procedure copyapostrophe();
begin
{$ifdef mse_debugparser}
 outhandle('COPYAPOSTROPHE');
{$endif}
 with info do begin
  with contextstack[s.stacktop] do begin
   stringbuffer:= stringbuffer+'''';
   d.str.start:= s.source.po;
  end;
 end;
end;

procedure copytoken();
begin
{$ifdef mse_debugparser}
 outhandle('COPYTOKEN');
{$endif}
 with info,contextstack[s.stacktop] do begin
  stringbuffer:= stringbuffer+psubstr(d.str.start,s.source.po);
  dec(s.stackindex);
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
  with contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_number then begin
    internalerror(ie_handler,'20140220A');
   end;
  {$endif}
   if d.number.value > $10ffff then begin
    errormessage(err_illegalcharconst,[],s.stacktop-s.stackindex);
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
   dec(s.stacktop);
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