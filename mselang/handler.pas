{ MSElang Copyright (c) 2013-2016 by Martin Schreiber
   
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
 globtypes,parserglob,opglob,typinfo,msetypes,handlerglob;

procedure beginparser(const aoptable: poptablety);
procedure endparser();

//procedure push(const avalue: real); overload;
//procedure push(const avalue: integer); overload;
//procedure int32toflo64();
 
//procedure dummyhandler();
procedure dummyhandler();
procedure handlenoimplementationerror();

procedure checkstart();
procedure handlenouniterror();
procedure handlenounitnameerror();
procedure handlesemicolonexpected();
procedure handlecolonexpected();
procedure handlecloseroundbracketexpected();
procedure handleclosesquarebracketexpected();
procedure handleequalityexpected();
procedure handleidentexpected();
procedure handlereservedword();
procedure handleillegalexpression();

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
procedure handleidentstart();
procedure handleident();
procedure handleidentpathstart();
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
procedure handleinsimpexp();

procedure handlecommaseprange();

procedure handlemain();
procedure handledotexpected();
procedure handlekeyword();

procedure handlefactentry();
//procedure handlefact();
procedure handleaddressfactentry();
procedure handleaddressopfactentry();
//procedure handleaddressfact();
procedure handlefact1();

procedure andopentry();
procedure oropentry();

procedure handleandfact();
procedure handleshlfact();
procedure handleshrfact();

//procedure handlefactadentry();
procedure handlenegfact();
procedure handlenotfact();
procedure handlemulfact();
procedure handledivfact();
procedure handledivisionfact();
procedure handlelistfact();

procedure handlefact2entry();
//procedure handlefact2();
{
procedure handleterm();
}
procedure handledereference();
procedure handleaddterm();
procedure handlesubterm();
procedure handleorterm();
procedure handlexorterm();
procedure handlexorsetterm();
procedure handlebracketend();
{
procedure handlesimpexp();
procedure handlesimpexp1();
}
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
 subhandler,managedtypes,syssubhandler,valuehandler,segmentutils,listutils,
 llvmlists,llvmbitcodes,identutils;

procedure beginparser(const aoptable: poptablety);

var
 po1: pvardataty;
 ele1: elementoffsetty;
begin
 setoptable(aoptable);
{
 addvar(tk_exitcode,allvisi,info.s.unitinfo^.varchain,po1);
 ele.findcurrent(getident('int32'),[ek_type],allvisi,po1^.vf.typ);
 po1^.address.indirectlevel:= 0;
 po1^.address.flags:= [];
 info.s.globlinkage:= li_internal; //todo
 po1^.address.segaddress:= getglobvaraddress(das_32,4,po1^.address.flags);
                                                               //i32 exitcode
}
 info.s.globlinkage:= li_internal; //todo ???
 with additem(oc_beginparse)^ do begin
  with par.beginparse do begin
//   exitcodeaddress:= po1^.address.segaddress;
   finisub:= 0;
  end;
 end;
end;

procedure endparser();
var
 ele1: elementoffsetty;
begin
 with getoppo(startupoffset)^.par.beginparse do begin
  unitinfochain:= info.unitinfochain;
 end;
 with additem(oc_endparse)^ do begin
 end;
end;

procedure handleprogbegin();
var
 ad1: listadty;
 ad2: opaddressty;
 i1: int32;
 n1: identnamety;
begin
{$ifdef mse_debugparser}
 outhandle('PROGBEGIN');
{$endif}
 with info do begin
  if stf_needsmanage in s.currentstatementflags then begin
   if getinternalsub(isub_ini,ad2) then begin //no initialization
    writemanagedvarop(mo_ini,info.s.unitinfo^.varchain);
    endsimplesub(false);
   end;
   if getinternalsub(isub_fini,ad2) then begin  //no finalization
    writemanagedvarop(mo_fini,info.s.unitinfo^.varchain);
    endsimplesub(false);
   end;
  end;
  s.unitinfo^.mainad:= opcount;
  with getoppo(startupoffset)^ do begin
   par.beginparse.mainad:= opcount;
  end;
  resetssa();
  with contextstack[s.stackindex] do begin
   d.kind:= ck_prog;
   d.prog.blockcountad:= info.opcount;
  end;
  with additem(oc_main)^ do begin
   //blockcount set in handleprogblock() 
   par.main.exitcodeaddress:= getexitcodeaddress();
  end;
  if co_llvm in compileoptions then begin
   n1:= getidentname2(getident('main'));
   i1:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(nil,n1);
//   m1.value.typeid:= info.s.unitinfo^.llvmlists.globlist.
//                                          gettype(m1.value.listid);
//   m1.flags:= [mvf_globval,mvf_pointer];
   if do_proginfo in info.s.debugoptions then begin
    with info.s.unitinfo^ do begin
     mainsubmeta:= llvmlists.metadatalist.adddisubprogram(
           info.{s.}currentscopemeta,
           n1,info.s.currentfilemeta,
           info.contextstack[info.s.stackindex].start.line+1,i1,
           llvmlists.metadatalist.adddisubroutinetype(nil{,
                      filepathmeta,s.currentscopemeta}),[flagprototyped],false);
     pushcurrentscope(mainsubmeta);
//     setcurrentscope(mainsubmeta);
    end;
   end;
  end;
  with unitlinklist do begin
   ad1:= unitchain;
   while ad1 <> 0 do begin         //insert ini calls
    with punitlinkinfoty(list+ad1)^ do begin
     with ref^ do begin
      if internalsubs[isub_ini] <> 0 then begin
       callinternalsub(internalsubs[isub_ini],false);
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
 hasfini: boolean;
 finicall: opaddressty;
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('PROGBLOCK');
{$endif}
// writeop(nil); //endmark
 handleunitend();
 invertlist(unitlinklist,unitchain);
 hasfini:= false;
 with unitlinklist do begin
  ad1:= unitchain;
  while ad1 <> 0 do begin         //insert fini calls
   with punitlinkinfoty(list+ad1)^,ref^ do begin
    if internalsubs[isub_fini] <> 0 then begin
     hasfini:= true;
     break;
    end;
    ad1:= header.next;
   end;
  end;
 end;
 if hasfini then begin
  finicall:= info.opcount;
            //todo: what about precompiled units with halt()?
  with additem(oc_call)^.par.callinfo do begin
   flags:= [];
   linkcount:= -1;
   params:= 0;
   paramcount:= 0;
  end;
 end;
 updateprogend(additem(oc_progend));
 if do_proginfo in info.s.debugoptions then begin
  popcurrentscope();
 end;
 with info.contextstack[info.s.stackindex] do begin
  with getoppo(d.prog.blockcountad)^ do begin
   par.main.blockcount:= info.s.ssa.bbindex+1;
  end;  
 end;
 
 if hasfini then begin
  with getoppo(startupoffset)^ do begin
   par.beginparse.finisub:= info.opcount;
  end;
  i1:= startsimplesub(tks_fini,false);
  with getoppo(finicall)^.par.callinfo do begin
   ad.globid:= getoppo(i1)^.par.subbegin.globid;
   ad.ad:= i1-1;
  end;
  with unitlinklist do begin
   ad1:= unitchain;
   while ad1 <> 0 do begin         //insert fini calls
    with punitlinkinfoty(list+ad1)^ do begin
     with ref^ do begin
      if internalsubs[isub_fini] <> 0 then begin
       callinternalsub(internalsubs[isub_fini],false);
      end;
     end;
     ad1:= header.next;
    end;
   end;
  end;
  endsimplesub(false);
 end;
 with info do begin
  dec(s.stackindex);
 end;
end;

procedure setnumberconst(const aitem: pcontextitemty; const avalue: card64);
begin
 with aitem^ do begin
  initdatacontext(d,ck_const);
  if (int64(avalue) <= high(int8)) and 
                            (int64(avalue) >= low(int8)) then begin
   d.dat.datatyp:= sysdatatypes[st_int8];
  end
  else begin
   if (int64(avalue) <= high(int16)) and 
                            (int64(avalue) >= low(int16)) then begin
    d.dat.datatyp:= sysdatatypes[st_int16];
   end
   else begin
    if (int64(avalue) <= high(int32)) and 
                            (int64(avalue) >= low(int32)) then begin
     d.dat.datatyp:= sysdatatypes[st_int32];
    end
    else begin
     d.dat.datatyp:= sysdatatypes[st_int64];
    end;
   end;
  end;
  d.dat.constval.kind:= dk_integer;
  d.dat.constval.vinteger:= int64(avalue);   
 end;
end;

procedure handleint();
var
 int1,c1: card64;
 po1: pchar;
 poitem: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('INT');
{$endif}
 with info do begin
  poitem:= @contextstack[s.stacktop];
  with poitem^ do begin
   consumed:= s.source.po;
   po1:= start.po;
   while (po1^ = '0') do begin
    inc(po1);
   end;
   c1:= 0;
 //  18446744073709551615
   int1:= 20-(consumed-po1);
   if (int64(int1) < 0) or (int1 = 0) and (po1^ > '1') then begin
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
   setnumberconst(poitem,c1);
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
 po2: pcontextitemty;
begin
 with info do begin
  with contextstack[s.stacktop] do begin
   fraclen:= asource-start.po;
  end;
  s.stacktop:= s.stacktop - 1;
  s.stackindex:= s.stacktop-1;
  po2:= @contextstack[s.stacktop];
  initdatacontext(po2^.d,ck_const);
  with po2^ do begin
   d.dat.datatyp:= sysdatatypes[st_flo64];
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
    if (int1 = 20) and (lint2 < qword($8AC7230489E80000)) then begin 
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
 mulops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,  sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_mulcard32,oc_mulint32,oc_mulflo64,
       //sdk_set32
         oc_and32);
   wantedtype: st_none; opname: '*');

 divops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,  sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_divcard32,oc_divint32,oc_none,
       //sdk_set32
         oc_none);
   wantedtype: st_none; opname: 'div');

 divisionops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,  sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_none,     oc_none,    oc_divflo64,
       //sdk_set32
         oc_none);
   wantedtype: st_flo64; opname: '/');

 andops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
  (ops: (oc_none, oc_none,    oc_and1,  oc_and32,  oc_and32, oc_none,
       //sdk_set32
         oc_none);
   wantedtype: st_none; opname: 'and');
 shlops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_shl32,  oc_shl32, oc_none,
       //sdk_set32
         oc_none);
   wantedtype: st_none; opname: 'shl');
 shrops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_shr32,  oc_shr32, oc_none,
       //sdk_set32
         oc_none);
   wantedtype: st_none; opname: 'shr');
 
procedure handlemulfact();
begin
{$ifdef mse_debugparser}
 outhandle('MULFACT');
{$endif}
 updateop(mulops);
end;

procedure handledivfact();
begin
{$ifdef mse_debugparser}
 outhandle('DIVFACT');
{$endif}
 updateop(divops);
end;

procedure handledivisionfact();
begin
{$ifdef mse_debugparser}
 outhandle('DIVISIONFACT');
{$endif}
 updateop(divisionops);
end;

const 
 shortcutops: array[shortcutopty] of opcodety = (
 //sco_none,sco_and,sco_or
   oc_none, oc_gotofalse,oc_gototrue
 );
 
 
procedure boolexpentry(const aop: shortcutopty);
var
 op1: opcodety;
 po1: popinfoty;
 poa,pob: pcontextitemty;
begin
 with info do begin
  pob:= @contextstack[s.stackindex-1];
  poa:= getpreviousnospace(pob-1);
  with pob^ do begin
  {$ifdef mse_debugparser}
   if not (d.kind in datacontexts) then begin
    internalerror(ie_parser,'20151016A');
   end;
  {$endif}
   if (d.dat.datatyp.indirectlevel = 0) and 
             (ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.kind = 
                                                         dk_boolean) then begin
    with poa^ do begin
    {$ifdef mse_debugparser}
     if not (d.kind in [ck_none,ck_shortcutexp]) then begin
      internalerror(ie_parser,'20151016A');
     end;
    {$endif}
     if d.kind = ck_none then begin
      d.kind:= ck_shortcutexp;
      d.shortcutexp.shortcuts:= 0;
      d.shortcutexp.op:= aop;
     end
     else begin
      if d.shortcutexp.op <> aop then begin
       resolveshortcuts(poa,pob);
       d.shortcutexp.op:= aop;
      end;
     end;
     if not (cos_booleval in s.compilerswitches) then begin
      if getvalue(pob,das_1) then begin
       op1:= shortcutops[aop];
       if op1 = oc_none then begin
        notimplementederror('20151016B');
       end;
       po1:= addcontrolitem(op1);
       with po1^ do begin
        par.ssas1:= pob^.d.dat.fact.ssaindex;
        linkmarkphi(d.shortcutexp.shortcuts,
                getsegmentoffset(seg_op,@par.opaddress),par.ssas1);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure andopentry();
begin
{$ifdef mse_debugparser}
 outhandle('ANDOPENTRY');
{$endif}
 boolexpentry(sco_and);
end;

procedure oropentry();
begin
{$ifdef mse_debugparser}
 outhandle('OROPENTRY');
{$endif}
 boolexpentry(sco_or);
end;

procedure handleandfact();
begin
{$ifdef mse_debugparser}
 outhandle('ANDFACT');
{$endif}
 updateop(andops);  //todo: optimize constants
end;

procedure handleshlfact();
begin
{$ifdef mse_debugparser}
 outhandle('SHLFACT');
{$endif}
 updateop(shlops);  //todo: optimize constants
end;

procedure handleshrfact();
begin
{$ifdef mse_debugparser}
 outhandle('SHRFACT');
{$endif}
 updateop(shrops);  //todo: optimize constants
end;

//todo: different datasizes
const
 addops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32, sdk_int32,  sdk_flo64)
 (ops: (oc_none, oc_none,    oc_none,  oc_addint32,oc_addint32,oc_addflo64,
      //sdk_set32
        oc_or32);
  wantedtype: st_none; opname: '+');
 subops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32, sdk_int32,  sdk_flo64)
 (ops: (oc_none, oc_subpo,   oc_none,  oc_subint32,oc_subint32,oc_subflo64,
       //sdk_set32
         oc_diffset);
  wantedtype: st_none; opname: '-');
 orops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
 (ops: (oc_none, oc_none,   oc_or1,    oc_or32,   oc_or32,  oc_none,
      //sdk_set32
        oc_none);
  wantedtype: st_none; opname: 'or');

 xorops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
 (ops: (oc_none, oc_none,    oc_xor1,  oc_xor32,  oc_xor32, oc_none,
      //sdk_set32
        oc_none);
  wantedtype: st_none; opname: 'xor');

 xorsetops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
 (ops: (oc_none, oc_none,    oc_none,  oc_none,  oc_none, oc_none,
      //sdk_set32
        oc_xorset);
  wantedtype: st_none; opname: '><');

procedure addsubterm(const issub: boolean);
             //special inc(), dec(), pointer arithmetic
var
 poa,pob: pcontextitemty; 
 procedure opnotsupported();
 var
  ch1: char;
 begin
  if issub then begin
   ch1:= '-';
  end
  else begin
   ch1:= '+';
  end;
  operationnotsupportederror(poa^.d,pob^.d,ch1);
 end; //opnotsupported
                                         //todo: operand size 
var 
 dk1: stackdatakindty;
 i1,i2: int32;
 india,indib: int32;
 op1: opcodety;
label
 errlab,endlab;
begin
 with info do begin
  poa:= @contextstack[s.stackindex-1];
  pob:= @contextstack[s.stacktop];
  with poa^ do begin
   if (pob^.d.kind = ck_const) and 
               (d.kind = ck_const) then begin
    dk1:= convertconsts(poa,pob);
    case dk1 of
     sdk_card32,sdk_int32: begin
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
       d.dat.constval.vfloat:= d.dat.constval.vfloat -
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
    s.stacktop:= s.stackindex-1;
    s.stackindex:= getpreviousnospace(s.stackindex-2);
//    dec(s.stacktop,2);
//    s.stackindex:= s.stacktop-1;
   end
   else begin
    if (d.kind in [ck_none,ck_error,ck_space]) or
              (pob^.d.kind in [ck_none,ck_error,ck_space]) then begin
     goto errlab;
    end;
   {$ifdef mse_checkinternalerror}
    if not (d.kind in alldatacontexts) or 
              not (pob^.d.kind in alldatacontexts)then begin
     internalerror(ie_handler,'20150320B');
    end;
   {$endif}
    india:= d.dat.datatyp.indirectlevel;
    if (d.kind = ck_ref) and 
              (af_paramindirect in d.dat.ref.c.address.flags) then begin
     dec(india);
    end;
    indib:= pob^.d.dat.datatyp.indirectlevel;
    if (pob^.d.kind = ck_ref) and 
              (af_paramindirect in pob^.d.dat.ref.c.address.flags) then begin
     dec(indib);
    end;
    if india > 0 then begin //pointer math
     if india = indib then begin
                                                                 //pointer diff
      if not issub then begin
       opnotsupported();
      end
      else begin
       updateop(subops); //todo: div by pointed size
       with poa^ do begin
        d.dat.datatyp:= sysdatatypes[ptrintsystype];
        d.dat.fact.opdatatype:= getopdatatype(d.dat.datatyp);
       end;
       goto endlab;
      end;
     end
     else begin
      if india > 1 then begin
       i2:= pointersize;
      end
      else begin
       with ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^ do begin
        if h.datasize = das_pointer then begin
         i2:= 1;
        end
        else begin
         i2:= h.bytesize;
        end;
       end;
      end;
      if indib = 0 then begin  //inc/dec
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
//         i2:= s.stacktop-s.stackindex-2;
         getvalue(poa,das_none);
         i1:= d.dat.fact.ssaindex;
         with additem(oc_offsetpoimm32)^ do begin
          if co_llvm in compileoptions then begin
           par.imm.llvm:= info.s.unitinfo^.llvmlists.constlist.
                                        addi32(pob^.d.dat.constval.vinteger);
          end
          else begin
           par.imm.vint32:= pob^.d.dat.constval.vinteger;
          end;
          par.ssas1:= i1;
         end;
         d.dat.fact.ssaindex:= s.ssa.nextindex-1;
        end;
       end
       else begin
//        i1:= s.stacktop-s.stackindex;
        if getvalue(poa,das_pointer) and getvalue(pob,das_32) then begin
         if tryconvert(pob,st_int32) then begin //todo: data size
          i1:= pob^.d.dat.fact.ssaindex;
          if i2 <> 1 then begin
           with additem(oc_mulimmint32)^ do begin
            if co_llvm in compileoptions then begin
             par.imm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(i2);
            end
            else begin
             par.imm.vint32:= i2;
            end;
            par.ssas1:= i1;
           end;
           i1:= s.ssa.nextindex-1;
          end;
          if issub then begin
           op1:= oc_subpoint32;
          end
          else begin
           op1:= oc_addpoint32;
          end;
          with additem(op1)^ do begin
           par.ssas1:= d.dat.fact.ssaindex;
           par.ssas2:= i1;
          end;
          d.dat.fact.ssaindex:= s.ssa.nextindex-1;
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
     s.stacktop:= s.stackindex-1;
     s.stackindex:= getpreviousnospace(s.stacktop-1);
//     dec(s.stacktop,2);
//     s.stackindex:= s.stacktop-1;
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
endlab:
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

procedure handleorterm(); //todo: optimize constants
begin
{$ifdef mse_debugparser}
 outhandle('ORTERM');
{$endif}
 updateop(orops);
end;

procedure handlexorterm(); //todo: optimize constants
begin
{$ifdef mse_debugparser}
 outhandle('XORTERM');
{$endif}
 updateop(xorops);
end;

procedure handlexorsetterm(); //todo: optimize constants
begin
{$ifdef mse_debugparser}
 outhandle('XORSETTERM');
{$endif}
 updateop(xorsetops);
end;
(*
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
*)
procedure handledereference();
var
 po1: ptypedataty;
 int1: integer;
 poa,potop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('DEREFERENCE');
{$endif}
// if hf_propindex in info.contextstack[info.s.stacktop].handlerflags then begin
//  getpropvalue(info.s.stacktop-info.s.stackindex,das_none);
// end;
 with info do begin
  potop:= @contextstack[s.stacktop];
  with potop^ do begin
   if (d.kind = ck_prop) then begin
    getvalue(potop,das_none);
   end
   else begin
    if hf_propindex in d.handlerflags then begin
     getnextnospace(s.stackindex,poa);
    {$ifdef mse_checkinternalerror}
     if poa^.d.kind <> ck_prop then begin
      internalerror(ie_handler,'20160214A');
     end;
    {$endif}
     if getvalue(poa,das_none) then begin
      s.stacktop:= s.stackindex+1;
     end
     else begin
      exit;
     end;
    end;
   end;
   if d.dat.datatyp.indirectlevel <= 0 then begin
    errormessage(err_illegalqualifier,[]);
   end
   else begin
    dec(d.dat.datatyp.indirectlevel);
    dec(d.dat.indirection);
    case d.kind of
     ck_ref: begin        //todo: make universal
      if not (stf_getaddress in s.currentstatementflags) then begin
       include(d.dat.ref.c.address.flags,af_startoffset);
      end;
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
     ck_none,ck_error: begin
      exit;
     end;
     else begin
      internalerror1(ie_notimplemented,'20140402A'); //todo
     end;
    end;
   end;
  end;
 end;
end;

(*
procedure handlefactadentry();
begin
{$ifdef mse_debugparser}
 outhandle('FACTADENTRY');
{$endif}
 handlefactentry();
 with info,contextstack[s.stacktop].d.getfact do begin
  include(flags,ff_addressfact);
 end;
end;
*)
const
 negops: array[datakindty] of opcodety = (
 //dk_none, dk_pointer,dk_boolean,dk_cardinal, dk_integer, dk_float,
   oc_none, oc_none,   oc_none,   oc_negcard32,oc_negint32,oc_negflo64,
 //dk_kind, dk_address,dk_record,dk_string8,dk_dynarray,dk_openarray,
   oc_none, oc_none,   oc_none,  oc_none,   oc_none,    oc_none,
 //dk_array,dk_class,dk_interface,dk_sub
   oc_none, oc_none, oc_none,     oc_none,
 //dk_enum,dk_enumitem,dk_set, dk_character
   oc_none,oc_none,    oc_none,oc_none
 );

 notops: array[datakindty] of opcodety = (
 //dk_none, dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,
   oc_none, oc_none,   oc_not1,   oc_not32,   oc_not32,  oc_none,
 //dk_kind, dk_address,dk_record,dk_string8,dk_dynarray,dk_openarray,
   oc_none, oc_none,   oc_none,  oc_none,   oc_none,    oc_none,
 //dk_array,dk_class,dk_interface,dk_sub
   oc_none, oc_none, oc_none,     oc_none,
 //dk_enum,dk_enumitem,dk_set, dk_character
   oc_none,oc_none,    oc_none,oc_none
 );

procedure handlefact1();
var
 i1: integer;
 c1: card64;
 indpo,toppo: pcontextitemty;
// fl1: factflagsty;
label
 endlab,endlab1;
begin
{$ifdef mse_debugparser}
 outhandle('FACT1');
{$endif}
 with info do begin
  if s.stackindex < s.stacktop then begin
   toppo:= @contextstack[s.stacktop];
   with toppo^ do begin
    case d.kind of
     ck_str: begin
      initdatacontext(toppo^.d,ck_const);
      d.dat.datatyp:= sysdatatypes[st_string8];
      d.dat.constval.kind:= dk_string8;
      d.dat.constval.vstring:= newstringconst();
     end;
     ck_number: begin
      setnumberconst(toppo,d.number.value);
     end;
    end;
   end;
(*
  {$ifdef mse_checkinternalerror}
   if not (toppo^.d.kind in datacontexts) then begin
    internalerror(ie_handler,'20160602B');
   end;
  {$endif}
   if dcf_listitem in toppo^.d.dat.flags then begin
    repeat
     dec(pointer(toppo),sizeof(contextitemty));
    until toppo^.d.kind = ck_list;
   end;
*)
   indpo:= @contextstack[s.stackindex];
   indpo^.d.kind:= ck_space;
   if hf_propindex in toppo^.d.handlerflags then begin //
    if stf_getaddress in s.currentstatementflags then begin
     errormessage(err_varidentexpected,[],1);
    end
    else begin
{
     if stf_rightside in s.currentstatementflags then begin
      getvalue(toppo,das_none);
//      indpo^.d:= (indpo+1)^.d;
//     end
//     else begin
//      goto endlab1;
     end;
}
    end;
    goto endlab1;
   end
   else begin
    with toppo^ do begin
//     d:= toppo^.d;
     if stf_getaddress in s.currentstatementflags
                {fl1 * [ff_address,ff_addressfact] <> []} then begin
      case d.kind of
       ck_const: begin
        errormessage(err_cannotaddressconst,[],1);
       end;
       ck_ref: begin
        if af_paramindirect in d.dat.ref.c.address.flags then begin
         exclude(d.dat.ref.c.address.flags,af_paramindirect);
        end
        else begin
         inc(d.dat.indirection);
         inc(d.dat.datatyp.indirectlevel);
        end;
        if (stf_addressop in s.currentstatementflags)
                    {not (ff_addressfact in fl1)} and
                    not (tf_subad in d.dat.datatyp.flags) then begin
         d.dat.datatyp:= sysdatatypes[st_pointer]; //untyped pointer
        end;
       end;
       ck_fact: begin
        if d.dat.indirection = -1 then begin
         d.dat.indirection:= 0;
         inc(d.dat.datatyp.indirectlevel);
        end
        else begin
         errormessage(err_cannotaddressexp,[],1);
        end;
       end;
       ck_typearg: begin
        errormessage(err_cannotaddresstype,[],1);
       end;
       ck_controltoken: begin
        errormessage(err_invalidcontroltoken,[],1);
       end;
       ck_none,ck_error,ck_space,ck_subcall: begin //todo: stop error earlier
        goto endlab;
       end;
      {$ifdef mse_checkinternalerror}
       else begin
        internalerror(ie_handler,'20140403C');
       end;
      {$endif}
      end;
     end;
    end;
    s.currentstatementflags:= indpo^.b.flags;
    goto endlab1; //no stacktop release
   end;
  end
  else begin
   errormessage(err_illegalexpression,[],s.stacktop-s.stackindex);
  end;
endlab:
  s.stacktop:= s.stackindex;
endlab1: //for property setter with index
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

procedure dofactentry();
begin
 with info,contextstack[s.stacktop] do begin
  b.flags:= s.currentstatementflags;
  s.currentstatementflags-= [stf_getaddress,stf_addressop,stf_params];
  stringbuffer:= '';
  d.kind:= ck_getfact;
 {
  with d.getfact do begin
   flags:= [];
  end;
 }
 end;
end;

procedure handlefactentry();
begin
{$ifdef mse_debugparser}
 outhandle('FACTENTRY');
{$endif}
 dofactentry();
end;

procedure handleaddressfactentry();
begin
{$ifdef mse_debugparser}
 outhandle('ADRESSFACTENTRY');
{$endif}
 dofactentry();
 include(info.s.currentstatementflags,stf_getaddress);
end;

procedure handleaddressopfactentry();
begin
{$ifdef mse_debugparser}
 outhandle('ADRESSOPFACTENTRY');
{$endif}
 dofactentry();
 info.s.currentstatementflags:= info.s.currentstatementflags + 
                                       [stf_getaddress,stf_addressop];
end;

(*
procedure handleaddressfact();
begin
{$ifdef mse_debugparser}
 outhandle('ADRESSFACT');
{$endif}
 with info,contextstack[s.stackindex] do begin
 {
  if ff_address in flags then begin
   errormessage(err_cannotassigntoaddr,[]);
  end;
  include(flags,ff_address);
 }
  d:= contextstack[s.stacktop].d;
  s.currentstatementflags:= b.flags;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
 end;
end;

procedure handleadfact();
begin
{$ifdef mse_debugparser}
 outhandle('FACT');
{$endif}
 with info,contextstack[s.stackindex] do begin
 {
  if ff_address in flags then begin
   errormessage(err_cannotassigntoaddr,[]);
  end;
  include(flags,ff_address);
 }
  d:= contextstack[s.stacktop].d;
  s.currentstatementflags:= b.flags;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
 end;
end;
*)
procedure handlenegfact();
var
 po1: ptypedataty;
 i1: int32;
 poa: pcontextitemty;
begin
// handlefact;
{$ifdef mse_debugparser}
 outhandle('NEGFACT');
{$endif}
 with info do begin
  poa:= @contextstack[s.stacktop];
  with poa^ do begin
  {$ifdef mse_checkinternalerror}
   if s.stacktop-s.stackindex - getspacecount(s.stackindex+1) <> 1 then begin
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
    if getvalue(poa,das_none) then begin
     po1:= ele.eledataabs(d.dat.datatyp.typedata);
     i1:= d.dat.fact.ssaindex;
     with insertitem(negops[po1^.h.kind],s.stacktop-s.stackindex,-1)^ do begin
      if op.op = oc_none then begin
       errormessage(err_negnotpossible,[],s.stacktop-s.stackindex);
      end;
      par.ssas1:= i1;
     end;
    end;
   end;
   contextstack[s.stackindex].d.kind:= ck_space;
//   contextstack[s.stackindex].d:= d;
//   s.stacktop:= s.stackindex;
   dec(s.stackindex);
  end;
 end;
end;

procedure handlenotfact;
var
 po1: ptypedataty;
 i1: int32;
 poa: pcontextitemty;
begin
// handlefact;
{$ifdef mse_debugparser}
 outhandle('NOTFACT');
{$endif}
 with info do begin
  poa:= @contextstack[s.stacktop];
  with poa^ do begin
  {$ifdef mse_checkinternalerror}
   if s.stacktop-s.stackindex - getspacecount(s.stackindex+1) <> 1 then begin
    internalerror(ie_handler,'20140404A');
   end;
  {$endif}
   if d.kind = ck_const then begin
    with d.dat.constval do begin
     case kind of
      dk_integer: begin
       vinteger:= not vinteger;
      end;
      dk_boolean: begin
       vboolean:= not vboolean;
      end;
      else begin
       errormessage(err_notnotpossible,[],1);
      end;
     end;
    end;
   end
   else begin
    if getvalue(poa,das_none) then begin
     po1:= ele.eledataabs(d.dat.datatyp.typedata);
     i1:= d.dat.fact.ssaindex;
     with insertitem(notops[po1^.h.kind],s.stacktop-s.stackindex,-1)^ do begin
      if op.op = oc_none then begin
       errormessage(err_notnotpossible,[],s.stacktop-s.stackindex);
      end;
      par.ssas1:= i1;
     end;
    end;
   end;
   contextstack[s.stackindex].d.kind:= ck_space;
//   contextstack[s.stackindex].d:= d;
//   s.stacktop:= s.stackindex;
   dec(s.stackindex);
  end;
 end;
end;

(*
procedure handlelistfact(); //not finished
var
 po1,pe: pdatacontextty;
begin
{$ifdef mse_debugparser}
 outhandle('LISTFACT');
{$endif}
 with info do begin
  with contextstack[s.stackindex] do begin
   d.kind:= ck_list;
   d.list.count:= s.stacktop - s.stackindex;
   po1:= @contextstack[s.stackindex+1].d.dat;
   pe:= pointer(po1) + d.list.count * sizeof(contextitemty);
   while po1 < pe do begin
    include(po1^.flags,dcf_listitem);
    inc(pointer(po1),sizeof(contextitemty));
   end;
  end;
  dec(s.stackindex);
 end;
end;
*)

procedure handlelistfact(); //not finished
var
 allconst: boolean;
 i1,i2: int32;
 po1,po2: ptypedataty;
 ca1,ca2: card32;
 op1: popinfoty;
 indpo,potop,poitem: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('LISTFACT');
{$endif}
 with info do begin
  indpo:= @contextstack[s.stackindex];
  ele.checkcapacity(ek_type);
  if s.stacktop = s.stackindex then begin //empty set
   initdatacontext(indpo^.d,ck_const);
   with indpo^ do begin
    d.dat.datatyp:= emptyset;
    d.dat.constval.kind:= dk_set;
//    d.dat.constval.vset.settype:= 0; 
   end;
  end
  else begin
   potop:= @contextstack[s.stacktop];
   po2:= nil;
   ca1:= 0;          //todo: arbitrary size, ranges
   allconst:= true;
   poitem:= indpo;
   while true do begin
    if not getnextnospacex(poitem+1,poitem) then begin
     break;
    end;
    with poitem^ do begin
     if d.kind <> ck_space then begin
     {$ifdef mse_checkinternalerror}
      if not (d.kind in datacontexts) then begin
       internalerror(ie_handler,'20151007A');
      end;
     {$endif}
      po1:= ele.eledataabs(basetype(d.dat.datatyp.typedata));
      if po2 = nil then begin
       po2:= po1;
      end;
      if not (po1^.h.kind in ordinaldatakinds) or 
                                   (po1^.h.indirectlevel <> 0) then begin
       errormessage(err_ordinalexpexpected,[],getstackoffset(poitem));
      end
      else begin
       if (po1 <> po2) then begin //todo: try to convert ordinals
        incompatibletypeserror(po2,po1,getstackoffset(poitem));
       end;
      end;
      case d.kind of 
       ck_const: begin
        ca2:= 1 shl d.dat.constval.vcardinal;
        if ca1 and ca2 <> 0 then begin
         errormessage(err_duplicatesetelement,[],getstackoffset(poitem));
        end;
        ca1:= ca1 or ca2;
       end
       else begin
        allconst:= false;
        getvalue(poitem,das_32);
       end;
      end; 
     end;
    end;
   end;
   po1:= ele.addelementdata(getident(),ek_type,[]); //anonymous set type
   inittypedatasize(po1^,dk_set,0,das_32);
   with po1^ do begin
    infoset.itemtype:= ele.eledatarel(po2);
   end;
   with indpo^ do begin
    d.dat.datatyp.flags:= [];
    d.dat.datatyp.typedata:= ele.eledatarel(po1);
    d.dat.datatyp.indirectlevel:= 0;
    if allconst then begin
     initdatacontext(indpo^.d,ck_const);
     d.dat.constval.kind:= dk_set;
     d.dat.constval.vset.value:= ca1;
    end
    else begin
     initdatacontext(indpo^.d,ck_fact);
     with insertitem(oc_pushimm32,1,0)^ do begin //first op
      setimmint32(ca1,par);
      i2:= par.ssad;
     end;
     for i1:= s.stackindex+1 to s.stacktop do begin
      if contextstack[i1].d.kind <> ck_const then begin
       op1:= insertitem(oc_setbit,i1-s.stackindex,-1);
       with op1^ do begin //last op
        par.ssas1:= i2;
        par.ssas2:= (op1-1)^.par.ssad;
       end;
      end;
     end;
     d.dat.fact.ssaindex:= s.ssa.nextindex-1;
    end;
   end;
  end;
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
 end;
end;

(*
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
*)
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
  if (s.stackindex < s.stacktop) and 
              (contextstack[s.stacktop].d.kind <> ck_space) then begin
   contextstack[s.stackindex].d.kind:= ck_space;
  end
  else begin
   errormessage(err_expressionexpected,[]);
//   error(ce_expressionexpected);
//   outcommand(info,[],'*ERROR* Expression expected');
  end;
//  dec(s.stacktop);
  dec(s.stackindex);
 end;
end;

procedure handleidentstart();
begin
 with info,contextstack[s.stacktop],d do begin
  ident.flags:= [];
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
  exclude(ident.flags,idf_continued);
//  ident.continued:= false;
  if ident.len = 0 then begin
   errormessage(err_identexpected,[]);
  end;
 end;
end;

procedure handleidentpathstart();
begin
 with info,contextstack[s.stacktop],d do begin
  ident.flags:= [];
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
  exclude(ident.flags,idf_continued);
//  ident.continued:= false;
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
  include(ident.flags,idf_continued);
//  ident.continued:= true;
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
 tokenexpectederror(';');
{
 with info do begin
  errormessage(err_syntax,[';']);
 end;
}
end;

procedure handlecolonexpected();
begin
{$ifdef mse_debugparser}
 outhandle('COLONEXPECTED');
{$endif}
 tokenexpectederror(':');
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

procedure handlereservedword();
begin
{$ifdef mse_debugparser}
 outhandle('RESERVEDWORD');
{$endif}
 handleidentexpected();
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
  if (s.stacktop-s.stackindex - getspacecount(s.stackindex+2) <> 2) or 
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
  contextstack[s.stackindex].d.kind:= ck_space;
 end;
{
 with info,contextstack[s.stacktop] do begin
  if not (hf_propindex in d.handlerflags) then begin
   contextstack[s.stackindex].d.kind:= ck_space;
//   contextstack[s.stacktop-1].d:= d;
//   dec(s.stacktop);
  end;
 end;
}
end;

procedure handleexp1();
var
 toppo: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('EXP1');
{$endif}
 with info do begin
  toppo:= @contextstack[s.stacktop];
  with toppo^ do begin
   if not (hf_propindex in d.handlerflags) then begin
 //   resolveshortcuts(0,1); //todo: ck_space handling
    resolveshortcuts(@contextstack[s.stackindex],toppo);
 //   contextstack[s.stacktop-1].d:= contextstack[s.stacktop].d;
 //   s.stacktop:= s.stackindex;
   end;
  end;
  contextstack[s.stackindex].d.kind:= ck_space;
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
 with info,s.unitinfo^ do begin
  if (unitlevel = 1) and (us_program in state) and (mainad = 0) then begin
   errormessage(err_syntax,['begin']);
  end;
  dec(s.stackindex);
 end;
end;

procedure handledotexpected();
begin
{$ifdef mse_debugparser}
 outhandle('DOTEXPECTED');
{$endif}
 errormessage(err_syntax,['.']);
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
 cmpopty = (cmpo_eq,cmpo_ne,cmpo_gt,cmpo_lt,cmpo_ge,cmpo_le,cmpo_in);
const
 cmpops: array[cmpopty] of opsinfoty = (
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,   sdk_int32,
  (ops: (oc_none, oc_cmpeqpo, oc_cmpeqbool,oc_cmpeqint32,oc_cmpeqint32,                        
       //sdk_flo64,    sdk_set32
         oc_cmpeqflo64,oc_cmpeqint32);
   wantedtype: st_none; opname: '='),
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,   sdk_int32,
  (ops: (oc_none, oc_cmpnepo, oc_cmpnebool,oc_cmpneint32,oc_cmpneint32,
       //sdk_flo64,    sdk_set32
         oc_cmpneflo64,oc_cmpneint32);
   wantedtype: st_none; opname: '<>'),
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,    sdk_int32,
  (ops: (oc_none, oc_cmpgtpo, oc_cmpgtbool,oc_cmpgtcard32,oc_cmpgtint32,
       //sdk_flo64,    sdk_set32
         oc_cmpgtflo64,oc_none);
   wantedtype: st_none; opname: '>'),
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,    sdk_int32,
  (ops: (oc_none, oc_cmpltpo, oc_cmpltbool,oc_cmpltcard32,oc_cmpltint32,
       //sdk_flo64,    sdk_set32
         oc_cmpltflo64,oc_none);
   wantedtype: st_none; opname: '<'),
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,
  (ops: (oc_none,oc_cmpgepo,oc_cmpgebool,oc_cmpgecard32,oc_cmpgeint32,
       //sdk_flo64,    sdk_set32
         oc_cmpgeflo64,oc_none);
   wantedtype: st_none; opname: '>='),
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,
  (ops: (oc_none,oc_cmplepo,oc_cmplebool,oc_cmplecard32,oc_cmpleint32,
       //sdk_flo64,    sdk_set32
         oc_cmpleflo64,oc_setcontains);
   wantedtype: st_none; opname: '<='),
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,
  (ops: (oc_none, oc_none,    oc_none,  oc_none,     oc_none,
       //sdk_flo64,    sdk_set32
         oc_none,      oc_none); //special handling
   wantedtype: st_none; opname: 'in')
 );

procedure handlecomparison(const aop: cmpopty);

var
 poa,pob: pcontextitemty;

 procedure notsupported();
 begin
  with info,poa^ do begin
   operationnotsupportederror(d,pob^.d,cmpops[aop].opname);
  end;
 end;

var
 dk1:stackdatakindty;
 int1: integer;
begin
 with info do begin
  poa:= @contextstack[s.stackindex-1];
  pob:= @contextstack[s.stacktop];
  with poa^ do begin
   if (pob^.d.kind = ck_const) and (d.kind = ck_const) then begin
    dk1:= convertconsts(poa,pob);
    d.dat.constval.kind:= dk_boolean;
    d.dat.datatyp:= sysdatatypes[st_bool1];
    case aop of
     cmpo_eq: begin
      case dk1 of
       sdk_card32,sdk_int32: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger = 
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_flo64: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat = 
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_bool1: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean =
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_pointer: begin
        d.dat.constval.vboolean:= compaddress(d.dat.constval.vaddress,
                                             pob^.d.dat.constval.vaddress) = 0;
       end;
       sdk_set32: begin
        d.dat.constval.vboolean:= tintegerset(d.dat.constval.vset) =
                                         tintegerset(pob^.d.dat.constval.vset);
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cmpo_ne: begin
      case dk1 of
       sdk_card32,sdk_int32: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger <>
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_flo64: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat <>
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_bool1: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean <>
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_set32: begin
        d.dat.constval.vboolean:= tintegerset(d.dat.constval.vset) <>
                                         tintegerset(pob^.d.dat.constval.vset);
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cmpo_gt: begin
      case dk1 of
       sdk_card32,sdk_int32: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger >
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_flo64: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat >
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_bool1: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean >
                                                  pob^.d.dat.constval.vboolean;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cmpo_lt: begin
      case dk1 of
       sdk_card32,sdk_int32: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger <
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_flo64: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat <
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_bool1: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean <
                                                  pob^.d.dat.constval.vboolean;
       end;
      end;
     end;
     cmpo_ge: begin
      case dk1 of
       sdk_card32,sdk_int32: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger >=
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_flo64: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat >=
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_bool1: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean >=
                                                  pob^.d.dat.constval.vboolean;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cmpo_le: begin
      case dk1 of
       sdk_card32,sdk_int32: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger <=
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_flo64: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat <=
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_bool1: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean <=
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_set32: begin
        d.dat.constval.vboolean:= tintegerset(d.dat.constval.vset) <=
                                         tintegerset(pob^.d.dat.constval.vset);
       end;
       else begin
        notsupported();
       end;
      end;
     end;
    end;
    s.stacktop:= s.stackindex - 1;
    s.stackindex:= getpreviousnospace(s.stacktop-1);
   end
   else begin
    updateop(cmpops[aop]);
    with info,poa^ do begin
     d.dat.datatyp:= sysdatatypes[resultdatatypes[sdk_bool1]];
     d.dat.fact.opdatatype:= bitoptypes[das_1];
    end;
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

procedure handleinsimpexp();
var
// baseoffset: int32;
 poa,pob: pcontextitemty; 
begin
{$ifdef mse_debugparser}
 outhandle('INSIMPEXP');
{$endif}
 with info do begin
  poa:= @contextstack[s.stackindex-1];
  pob:= @contextstack[s.stacktop];
 {$ifdef mse_checkinternalerror}
 {$endif}
//  baseoffset:= s.stacktop-s.stackindex-2;
  if getvalue(poa,das_32,true) and getvalue(pob,das_none,true) and 
     tryconvert(poa,st_card32,[coo_enum]) and 
     (pob^.d.dat.datatyp.indirectlevel = 0) and 
     (ptypedataty(ele.eledataabs(
                      pob^.d.dat.datatyp.typedata))^.h.kind = dk_set) then begin
   if (poa^.d.kind = ck_const) and (pob^.d.kind = ck_const) then begin
    poa^.d.dat.constval.kind:= dk_boolean;
    poa^.d.dat.datatyp:= sysdatatypes[st_bool1];
    poa^.d.dat.constval.vboolean:= poa^.d.dat.constval.vinteger in
                    tintegerset(pob^.d.dat.constval.vset);
   end
   else begin
    if getvalue(poa,das_32) and getvalue(pob,das_none) then begin
     addfactbinop(poa,pob,oc_setin);
     setsysfacttype(poa^.d,st_bool1);
    end;
   end;
  end
  else begin
   operationnotsupportederror(poa^.d,pob^.d,cmpops[cmpo_in].opname);
  end;
  s.stacktop:= s.stackindex - 1;
  s.stackindex:= getpreviousnospace(s.stacktop-1); //necessary? indexbefore?
 end;
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
  checkneedsunique(s.stacktop-s.stackindex);
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
 //das_sub,    das_meta
   oc_popsegpo,oc_none), 
 //das_none, das_1,     das_2_7,   das_8,                  //pd_local
  (oc_poploc,oc_poploc8,oc_poploc8,oc_poploc8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_poploc16,oc_poploc16,oc_poploc32,oc_poploc32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_poploc64,oc_poploc64,oc_poplocpo,oc_poplocf16,oc_poplocf32,oc_poplocf64,
 //das_sub,   ,das_meta
   oc_poplocpo,oc_none), 
 //das_none, das_1,     das_2_7,   das_8,                  //pd_param
  (oc_poppar,oc_poppar8,oc_poppar8,oc_poppar8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_poppar16,oc_poppar16,oc_poppar32,oc_poppar32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_poppar64,oc_poppar64,oc_popparpo,oc_popparf16,oc_popparf32,oc_popparf64,
 //das_sub,    das_meta
   oc_popparpo,oc_none
   ), 
 //das_none, das_1,     das_2_7,   das_8,                  //pd_paramindi
  (oc_popparindi,oc_popparindi8,oc_popparindi8,oc_popparindi8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_popparindi16,oc_popparindi16,oc_popparindi32,oc_popparindi32,
 //das_33_63,      das_64,         das_pointer,
   oc_popparindi64,oc_popparindi64,oc_popparindipo,
 //das_f16,         das_f32,          das_f64
   oc_popparindif16,oc_popparindif32,oc_popparindif64,
 //das_sub,        das_meta
   oc_popparindipo,oc_none
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

//todo: indirection needs rewrite, simplify and make universal

procedure handleassignment();
var
 destvar: vardestinfoty;
 typematch,indi,isconst: boolean;
 datasi1: databitsizety;
 indilev1: int32;
 i1: int32;
 offs1: dataoffsty;
 ad1: addressrefty;
 ssa1: integer;
 po1: popinfoty;
 ssaextension1: integer;
// si1: databitsizety;
 dest,source: pcontextitemty;
 destkind: contextkindty;
 needsmanage,needsincref,needsdecref: boolean;

 procedure decref(const aop: managedopty);
 begin
  if indi then begin
   ad1.kind:= ark_stackref;
   ad1.address:= ad1.address-pointersize;
   ad1.offset:= 0;
  end
  else begin
   ad1.kind:= ark_contextdata;
   ad1.contextdata:= @dest^.d;
  end;
  i1:= -1;
  if destkind in factcontexts then begin
   i1:= dest^.d.dat.fact.ssaindex;
  end;
  ad1.ssaindex:= i1;
  writemanagedtypeop(aop,destvar.typ,ad1);
 end; //decref

var
 potop: pcontextitemty;
 i2: int32;
 flags1: dosubflagsty;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENT');
{$endif}
 with info do begin       //todo: use direct move if possible
  potop:= @contextstack[s.stacktop];
  if not errorfla then begin
   if not getnextnospace(s.stackindex+1,dest) or 
                               not getnextnospacex(dest+1,source) then begin
    internalerror1(ie_handler,'20160607A');
   end;
   
//   if source <> potop then begin //property
//    getvalue(source,das_none);
//   end;
//   if source = potop then begin //simple assignment
//    dest:= @contextstack[s.stackindex+1];
//    source:= @contextstack[s.stackindex+2];
    with dest^ do begin
     if d.kind = ck_prop then begin
      
      with ppropertydataty(ele.eledataabs(d.dat.prop.propele))^ do begin
       if pof_writefield in flags then begin
        d.dat.ref.offset:= d.dat.ref.offset + writeoffset;
        d.kind:= ck_ref;
       end
       else begin
        if pof_writesub in flags then begin
         i2:= 1; //value
         getnextnospacex(dest+1,source);
         if source^.d.kind = ck_index then begin
          source^.d.kind:= ck_space;
          i1:= getstackindex(source);
          while getnextnospacex(source+1,source) and 
                                 (source^.parent = i1) do begin
           inc(i2);
          end;
         end;
         getclassvalue(dest);
         ele.pushelementparent(writeele);
         getvalue(source,das_none);
         i1:= s.stackindex;
//         inc(s.stackindex); //class instance
         s.stackindex:= getstackindex(dest);
{
         flags1:= [];
         if i2 > 1 then begin
          flags1:= [dsf_indexedsetter];
         end;
}
         dosub(psubdataty(ele.eledataabs(writeele)),i2,[dsf_indexedsetter]{flags1});
         s.stackindex:= i1;
         ele.popelementparent();
        end
        else begin
         errormessage(err_nomemberaccessproperty,[],1);
        end;
        goto endlab;
       end;
      end;
     end;
    end;
    with dest^ do begin
     if not getnextnospacex(dest+1,source) then begin
      internalerror1(ie_handler,'20160607B');
     end;
     isconst:= source^.d.kind = ck_const;
//     getvalue(source,das_none);
     if getassignaddress(dest,false) then begin
      destkind:= d.kind;
      typematch:= false;
      indi:= false;
      dec(d.dat.datatyp.indirectlevel);
     {$ifdef mse_checkinternalerror}
      if d.dat.datatyp.indirectlevel < 0 then begin
       internalerror(ie_handler,'20131126B');
      end;
     {$endif}
      destvar.offset:= 0;
      destvar.typ:= ele.eledataabs(d.dat.datatyp.typedata);
      case destkind of
       ck_const: begin
        if d.dat.constval.kind <> dk_address then begin
         errormessage(err_argnotassign,[],0);
        end
        else begin
         destvar.address:= d.dat.constval.vaddress;
         typematch:= true;
        end;
       end;
       ck_ref{const}: begin
        destvar.address:= d.dat.ref.c.address;
        destvar.offset:= d.dat.ref.offset;
        typematch:= true;
       end;
       ck_fact,ck_subres: begin
        destvar.address.flags:= [];
        typematch:= true;
        indi:= true;
       end;
      {$ifdef mse_checkinternalerror}
       else begin
        internalerror(ie_handler,'20131117A');
       end;
      {$endif}
      end;
 
      destvar.address.indirectlevel:= d.dat.datatyp.indirectlevel;
      indilev1:= destvar.address.indirectlevel;
      if af_paramindirect in destvar.address.flags then begin
       dec(indilev1);
      end;

      needsmanage:= (indilev1 = 0) and (tf_needsmanage in destvar.typ^.h.flags);
      if needsmanage and isconst and 
        ((destvar.typ^.h.kind = dk_dynarray) and
               (source^.d.dat.constval.kind = dk_pointer) and 
               (af_nil in source^.d.dat.constval.vaddress.flags) or
         (destvar.typ^.h.kind in stringdatakinds) and
               (source^.d.dat.constval.kind in stringdatakinds) and 
               (strf_empty in source^.d.dat.constval.vstring.flags)) then begin
       ad1.offset:= 0;
       decref(mo_fini);
       goto endlab;
      end;
 
      datasi1:= destvar.typ^.h.datasize;
      if d.dat.datatyp.indirectlevel >= 1 then begin
       datasi1:= das_pointer;
      end;
      if isconst and not tryconvert(source,destvar.typ,indilev1,[]) then begin
       assignmenterror(contextstack[s.stacktop].d,destvar);
       goto endlab;
      end;
      
      if needsmanage then begin
       needsincref:= not isconst;
       needsdecref:= true;
       if needsincref and issametype(ele.eledataabs(d.dat.datatyp.typedata),
                      ele.eledataabs(source^.d.dat.datatyp.typedata)) then begin
        ad1.kind:= ark_contextdata;
        ad1.contextdata:= @source^.d;
        ad1.offset:= 0;
        if source^.d.kind = ck_ref then begin
         writemanagedtypeop(mo_incref,destvar.typ,ad1);
         needsincref:= false;
        end
        else begin
         if (source^.d.kind in factcontexts) and 
                             (source^.d.dat.indirection = -1) then begin
                                    //address on stack
          if datasi1 = das_pointer then begin
           ad1.offset:= -pointersize;
          end
          else begin
           ad1.offset:= -destvar.typ^.h.bytesize;
          end;
          ad1.ssaindex:= source^.d.dat.fact.ssaindex;
          writemanagedtypeop(mo_incref,destvar.typ,ad1);
          needsincref:= false;
         end;
        end;
       end;
       if not needsincref then begin
        if source^.d.kind in [ck_ref,ck_const] then begin
         ad1.address:= 0; //no source on stack for indi
        end
        else begin
         ad1.address:= ad1.offset;
        end;
        ad1.offset:= 0;
        decref(mo_decref); //before loading source for source = dest case
        needsdecref:= false;
       end;
      end;
      if not getvalue(source,datasi1) then begin
       goto endlab;
      end;
     end
     else begin
      goto endlab;
     end;
    end;
    
    if typematch and not errorfla then begin
                          //todo: use destinationaddress directly
     typematch:= isconst or 
                    tryconvert(s.stacktop-s.stackindex,destvar.typ,indilev1,[]);
     if not typematch then begin
      assignmenterror(contextstack[s.stacktop].d,destvar);
     end
     else begin
      ssa1:= source^.d.dat.fact.ssaindex; //source

      if needsmanage then begin
       ad1.kind:= ark_stack;
       if datasi1 = das_pointer then begin
        ad1.address:= -pointersize;
       end
       else begin
        ad1.address:= -destvar.typ^.h.bytesize;
       end;
       ad1.offset:= 0;
       ad1.ssaindex:= ssa1;
       if needsincref then begin
        writemanagedtypeop(mo_incref,destvar.typ,ad1);
       end;
       if needsdecref then begin
        decref(mo_decref);
       end;
      end;
 
      if indi then begin
       po1:= additem(popindioptable[datasi1]);
      end
      else begin
       if af_aggregate in destvar.address.flags then begin
        ssaextension1:= getssa(ocssa_aggregate);
       end
       else begin
        ssaextension1:= 0;
       end;
       if not (af_segment in destvar.address.flags) then begin
        i1:= sublevel - destvar.address.locaddress.framelevel-1;
        if i1 >= 0 then begin
         ssaextension1:= ssaextension1 + getssa(ocssa_popnestedvar);
        end;
       end;
       po1:= additem(popoptable[
                      getmovedest(destvar.address.flags)][datasi1],
                      ssaextension1);
       if af_segment in destvar.address.flags then begin
        po1^.par.memop.segdataaddress.a:= destvar.address.segaddress;
        po1^.par.memop.segdataaddress.offset:= destvar.offset;
 //       po1^.par.memop.segdataaddress.datasize:= 0;
       end
       else begin
        po1^.par.memop.locdataaddress.a:= destvar.address.locaddress;
        po1^.par.memop.locdataaddress.a.framelevel:= i1;
        po1^.par.memop.locdataaddress.offset:= destvar.offset;
       end;
      end;
      po1^.par.memop.t:= getopdatatype(destvar);
      po1^.par.ssas1:= ssa1;                //source
      po1^.par.ssas2:= dest^.d.dat.fact.ssaindex; //dest
     end;
    end;
 (*
   end
   else begin //source <> potop
    if hf_propindex in potop^.d.handlerflags then begin
    {$ifdef mse_checkinternalerror}
     if source^.d.kind <> ck_prop then begin
      internalerror(ie_handler,'20160211A');
     end;
     if pcontextitemty(@contextstack[potop^.parent])^.d.kind <>
                                                     ck_index then begin
      internalerror(ie_handler,'20160211B');
     end;
    {$endif}
     getclassvalue(source);
     with ppropertydataty(ele.eledataabs(source^.d.dat.prop.propele))^ do begin
      if not (pof_readsub in flags) then begin
       errormessage(err_nomemberaccessproperty,[],5);
      end
      else begin
       ele.pushelementparent(readele);
       i1:= s.stackindex;
       s.stackindex:= getstackindex(source);
       i2:= 1;
       while getnextnospace(source+1,source) do begin
        inc(i2);
       end;
       dosub(psubdataty(ele.eledataabs(writeele)),i1,[dsf_indexedsetter]); 
                                                      //swap first/last param
       s.stackindex:= i2;
       ele.popelementparent();
      end;
     end;
    end
    else begin
     errormessage(err_illegalexpression,[]);
    end;
   end;
*)
  end; //errorfla
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
  tokenexpectederror('tk_do');
  dec(s.stackindex);
 end;
end;

procedure handlewithentry();
begin
{$ifdef mse_debugparser}
 outhandle('WITHENTRY');
{$endif}
 with info do begin
  initblockcontext(0);
 end;
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
 ele1: elementoffsetty;
 ptop: pcontextitemty;
label
 errlab;
begin
{$ifdef mse_debugparser}
 outhandle('WITH2ENTRY');
{$endif}
 with info do begin
  ptop:= @contextstack[s.stacktop];
  with ptop^ do begin
   case d.kind of
    ck_ref,ck_fact: begin
     po1:= ele.eledataabs(d.dat.datatyp.typedata);
     if (d.dat.datatyp.indirectlevel = 1) and 
                          (po1^.h.kind in [dk_record,dk_class]) then begin
      if d.kind = ck_ref then begin
       dec(d.dat.datatyp.indirectlevel);
       dec(d.dat.indirection);
       if not getaddress(ptop,true) then begin
        goto errlab;
       end;
      end;
      with pvardataty(ele.addscope(ek_var,basetype(po1)))^ do begin
       address:= getpointertempaddress();
       include(address.flags,af_withindirect);
       vf.typ:= d.dat.datatyp.typedata;
       vf.flags:= [];
       vf.next:= 0;
      end;
     end
     else begin
      errormessage(err_expmustbeclassorrec,[]);
     end;
    end;
    ck_none,ck_error,ck_space: begin //error in fact
    end;
    else begin
     internalerror1(ie_notimplemented,'20140407A');
    end;
   end;
 errlab:
   s.stacktop:= s.stackindex;
  end;
 end;
end;

procedure handlewith3();
begin
{$ifdef mse_debugparser}
 outhandle('WITH3');
{$endif}
 with info do begin
  ele.popscopelevel();
  finiblockcontext(0);
  dec(s.stackindex);
  releasepointertempaddress();
 end;
end;

procedure handlestatement0entry();
begin
{$ifdef mse_debugparser}
 outhandle('STATEMENT0ENTRY');
{$endif}
 with info do begin
//  opshift:= 0;
  s.currentstatementflags-= [stf_rightside,{stf_params,}
                           stf_leftreference,stf_proccall];
  with contextstack[s.stacktop].d,statement do begin
   kind:= ck_statement;
//   flags:= [];
  end;
 end;
end;

procedure handlestatementexit();
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('HANDLESTATEMENTEXIT');
{$endif}
 with info do begin
  with contextstack[s.stacktop].d do begin
   case kind of
    ck_subres: begin
     with additem(oc_pop)^ do begin
      setimmsize(getbytesize(dat.fact.opdatatype),par); //todo: alignment
//      setimmsize((dat.fact.databitsize+7) div 8,par); //todo: alignment
     end;    
    end;
    ck_subcall,ck_controltoken: begin
    end;
    else begin
     errormessage(err_illegalexpression,[],s.stacktop-s.stackindex);
     goto endlab;
    end;
   end;
  end;
 {$ifdef mse_checkinternalerror}
  if s.stacktop-s.stackindex-getspacecount(s.stackindex+1) <> 1 then begin
   internalerror(ie_handler,'20140216A');
  end;
 {$endif}
endlab:
  dec(s.stackindex);
 end;
end;

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