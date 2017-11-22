{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
procedure handleopenroundbracketexpected();
procedure handlecloseroundbracketexpected();
procedure handleclosesquarebracketexpected();
procedure handleequalityexpected();
procedure handleidentexpected();
procedure handlereservedword();
procedure handleillegalexpression();

procedure handlenoidenterror();
procedure handleattachitemsentry();
procedure handleattachvalue();
procedure handlestringattach();
procedure handlestringexpected();
procedure handlenoattachitemerror();

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
//procedure handleblockend();
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
procedure handleissimpexp();

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
procedure handlemodfact();
procedure handledivisionfact();
procedure handlelistfact();

procedure fact1entry();
procedure fact2entry();
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

procedure setconstcontext(const aitem: pcontextitemty; const avalue: dataty);
function getpoptempop(const asize: databitsizety): opcodety;
procedure concatterms(const wanted,terms: pcontextitemty); 
        //wanted = nil -> use first term

implementation
uses
 stackops,msestrings,elements,sysutils,handlerutils,mseformatstr,
 unithandler,errorhandler,parser,opcode,
 subhandler,managedtypes,syssubhandler,valuehandler,segmentutils,listutils,
 llvmlists,llvmbitcodes,identutils,__mla__internaltypes,elementcache,
 grammarglob,gramse,grapas;

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
 initsubstartinfo();
 with info do begin
  frameoffset:= 0;
  stacktempoffset:= 0;
 {
  managedtempcount:= 0;
  managedtempref:= 0;
  managedtemparrayid:= 0;
 }
  if s.currentstatementflags*[stf_needsmanage,stf_needsini] <> [] then begin
   if getinternalsub(isub_ini,ad2) then begin //no initialization
    writemanagedvarop(mo_ini,info.s.unitinfo^.varchain,s.stacktop);
    endsimplesub(false);
   end;
  end;
  if s.currentstatementflags*[stf_needsmanage,stf_needsfini] <> [] then begin
   if getinternalsub(isub_fini,ad2) then begin  //no finalization
    writemanagedvarop(mo_fini,info.s.unitinfo^.varchain,s.stacktop);
    endsimplesub(false);
   end;
  end;

  if co_llvm in o.compileoptions then begin
   n1:= getidentname2(getident('main'));
   i1:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(nil,n1);
   if do_proginfo in info.s.debugoptions then begin
    with info.s.unitinfo^ do begin
     mainsubmeta:= llvmlists.metadatalist.adddisubprogram(
           info.s.currentscopemeta,
           n1,info.s.currentfilemeta,
           info.contextstack[info.s.stackindex].start.line+1,i1,
           llvmlists.metadatalist.adddisubroutinetype(nil{,
                      filepathmeta,s.currentscopemeta}),[flagprototyped],false);
     pushcurrentscope(mainsubmeta);
    end;
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
  begintempvars();
(*
  if co_llvm in o.compileoptions then begin
   n1:= getidentname2(getident('main'));
   i1:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(nil,n1);
   if do_proginfo in info.s.debugoptions then begin
    with info.s.unitinfo^ do begin
     mainsubmeta:= llvmlists.metadatalist.adddisubprogram(
           info.{s.}currentscopemeta,
           n1,info.s.currentfilemeta,
           info.contextstack[info.s.stackindex].start.line+1,i1,
           llvmlists.metadatalist.adddisubroutinetype(nil{,
                      filepathmeta,s.currentscopemeta}),[flagprototyped],false);
     pushcurrentscope(mainsubmeta);
    end;
   end;
  end;
*) 
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
 hasfini: boolean;
 finicall: opaddressty;
 i1: int32;
 managedtempsize1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('PROGBLOCK');
{$endif}
// writeop(nil); //endmark
{$ifdef mse_checkinternalerror}
 if ele.parentelement^.header.kind <> ek_implementation then begin
  internalerror(ie_handler,'20170821B');
 end;
{$endif}
 with info do begin
  addlabel();
  linkresolveopad(pimplementationdataty(ele.parentdata)^.exitlinks,
                                                       opcount-1);
  invertlist(tempvarlist,tempvarchain);
  writemanagedtempvarop(mo_decref,tempvarchain,s.stacktop);
  writemanagedtempop(mo_decref,managedtempchain,s.stacktop);
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
   finicall:= opcount;
             //todo: what about precompiled units with halt()?
   with additem(oc_call)^.par.callinfo do begin
    flags:= [];
    linkcount:= -1;
    params:= 0;
    paramcount:= 0;
   end;
  end;
  updateprogend(addcontrolitem(oc_progend));
  endtempvars();
  with additem(oc_progend1)^ do begin
   par.progend1.submeta:= s.currentscopemeta;
  end;
  
  if do_proginfo in info.s.debugoptions then begin
   popcurrentscope();
  end;
  managedtempsize1:= managedtempcount*sizeof(pointer);
   //todo: target pointersize
  with contextstack[s.stackindex] do begin
   with getoppo(d.prog.blockcountad)^ do begin
 //   invertlist(tempvarlist,tempvarchain);
    if co_llvm in o.compileoptions then begin
     settempvars(par.main.llvm.allocs);
 //    par.main.llvm.tempcount:= info.llvmtempcount;
 //    par.main.llvm.firsttemp:= info.firstllvmtemp;
     par.main.llvm.allocs.blockcount:= s.ssa.bbindex;
     if managedtempsize1 > 0 then begin
      par.main.llvm.allocs.managedtemptypeid:=
         s.unitinfo^.llvmlists.typelist.addaggregatearrayvalue(
                                                   managedtempsize1,ord(das_8));
      setimmint32(managedtempcount,par.main.llvm.allocs.managedtempcount);
     end
     else begin
      par.main.llvm.allocs.managedtemptypeid:= 0;
     end;
    end
    else begin
     par.main.stackop.managedtempsize:= managedtempsize1;
     par.main.stackop.tempsize:= locdatapo;
    end;
    deletelistchain(tempvarlist,tempvarchain);
   end;  
  end;
  
  if hasfini then begin
   with getoppo(startupoffset)^ do begin
    par.beginparse.finisub:= opcount;
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
        callinternalsub(internalsubs[isub_fini]);
       end;
      end;
      ad1:= header.next;
     end;
    end;
   end;
   endsimplesub(false);
  end;
  dec(s.stackindex);
 end;
end;

procedure setnumberconst(const aitem: pcontextitemty; const avalue: card64);
begin
 with aitem^ do begin
//  initdatacontext(d,ck_const);
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

procedure setconstcontext(const aitem: pcontextitemty; const avalue: dataty);
begin
 with aitem^ do begin
  initdatacontext(d,ck_const);
  d.dat.constval:= avalue;
  case avalue.kind of
   dk_boolean: begin
    d.dat.datatyp:= sysdatatypes[st_bool1];
   end;
   dk_integer: begin
    setnumberconst(aitem,avalue.vinteger);
   end;
   dk_cardinal: begin
    if (avalue.vcardinal) <= high(card8) then begin
     d.dat.datatyp:= sysdatatypes[st_card8];
    end
    else begin
     if (avalue.vcardinal) <= high(card16) then begin
      d.dat.datatyp:= sysdatatypes[st_card16];
     end
     else begin
      if (avalue.vcardinal) <= high(card32) then begin
       d.dat.datatyp:= sysdatatypes[st_card32];
      end
      else begin
       d.dat.datatyp:= sysdatatypes[st_card64];
      end;
     end;
    end;
   end;
   dk_float: begin
    d.dat.datatyp:= sysdatatypes[st_flo64];
   end;
   dk_address: begin
    d.dat.datatyp:= sysdatatypes[st_pointer];
   end;
   dk_string{8,dk_string16,dk_string32}: begin
    d.dat.datatyp:= sysdatatypes[st_string8];
   end;
   dk_character: begin
    d.dat.datatyp:= sysdatatypes[st_char32];
   end;
   dk_none: begin
    if stf_condition in info.s.currentstatementflags then begin
     d.dat.datatyp:= sysdatatypes[st_none];
    end
    else begin
     internalerror1(ie_handler,'20160720A');
    end;
   end;
   else begin
    internalerror1(ie_handler,'20160704A');
   end;
  end;
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
   initdatacontext(poitem^.d,ck_const);
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
  (ops: (oc_none, oc_none,    oc_none,  oc_mulcard,oc_mulint,oc_mulflo,
       //sdk_set32,sdk_string8
         oc_and,oc_none);
   wantedtype: st_none; opname: '*'; objop: oa_mul);

 divops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,  sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_divcard,oc_divint,oc_none,
       //sdk_set32,sdk_string8
         oc_none,  oc_none);
   wantedtype: st_none; opname: 'div'; objop: oa_none);

 modops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,  sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_modcard,oc_modint,oc_none,
       //sdk_set32,sdk_string8
         oc_none,  oc_none);
   wantedtype: st_none; opname: 'mod'; objop: oa_none);

 divisionops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,  sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_none,     oc_none,    oc_divflo,
       //sdk_set32,sdk_string8
         oc_none,  oc_none);
   wantedtype: st_flo64; opname: '/'; objop: oa_div);

 andops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
  (ops: (oc_none, oc_none,    oc_and1,  oc_and,  oc_and, oc_none,
       //sdk_set32,sdk_string8
         oc_none,  oc_none);
   wantedtype: st_none; opname: 'and'; objop: oa_and);
 shlops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_shl,  oc_shl, oc_none,
       //sdk_set32,sdk_string8
         oc_none,  oc_none);
   wantedtype: st_none; opname: 'shl'; objop: oa_shl);
 shrops: opsinfoty = 
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
  (ops: (oc_none, oc_none,    oc_none,  oc_shr,  oc_shr, oc_none,
       //sdk_set32,sdk_string8
         oc_none,  oc_none);
   wantedtype: st_none; opname: 'shr'; objop: oa_shr);
 
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

procedure handlemodfact();
begin
{$ifdef mse_debugparser}
 outhandle('MODFACT');
{$endif}
 updateop(modops);
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
  if not getfactstart(s.stackindex-1,pob) or
                not getfactstart(getstackindex(pob)-1,poa) then begin
   exit;
  end;
//  pob:= @contextstack[s.stackindex-1];
//  poa:= getpreviousnospace(pob-1);
  with pob^ do begin
  {$ifdef mse_checkinternalerror}
   if not (d.kind in datacontexts) then begin
    internalerror(ie_parser,'20151016A');
   end;
  {$endif}
   if (d.dat.datatyp.indirectlevel = 0) and 
             (ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.kind = 
                                                         dk_boolean) then begin
    with poa^ do begin
    {$ifdef mse_checkinternalerror}
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
     if not (stf_condition in s.currentstatementflags) and 
                        not (cos_booleval in s.compilerswitches) then begin
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
 (ops: (oc_none, oc_none,    oc_none,  oc_addint,oc_addint,oc_addflo,
      //sdk_set32,sdk_string8
        oc_or,  oc_none);
  wantedtype: st_none; opname: '+'; objop: oa_add);
 subops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32, sdk_int32,  sdk_flo64)
 (ops: (oc_none, oc_subpo,   oc_none,  oc_subint,oc_subint,oc_subflo,
       //sdk_set32, sdk_string8
         oc_diffset,oc_none);
  wantedtype: st_none; opname: '-'; objop: oa_sub);
 orops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
 (ops: (oc_none, oc_none,   oc_or1,    oc_or,   oc_or,  oc_none,
      //sdk_set32,sdk_string8
        oc_none,  oc_none);
  wantedtype: st_none; opname: 'or'; objop: oa_or);

 xorops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
 (ops: (oc_none, oc_none,    oc_xor1,  oc_xor,  oc_xor, oc_none,
      //sdk_set32,sdk_string8
        oc_none,  oc_none);
  wantedtype: st_none; opname: 'xor'; objop: oa_xor);

 xorsetops: opsinfoty = 
      //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64)
 (ops: (oc_none, oc_none,    oc_none,  oc_none,  oc_none, oc_none,
      //sdk_set32,sdk_string8
        oc_xorset,oc_none);
  wantedtype: st_none; opname: '><'; objop: oa_none);

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
 pta,ptb: ptypedataty;
label
 errlab,endlab;
begin
 with info do begin
  if not getfactstart(s.stackindex-1,poa) or
                not getfactstart(s.stacktop,pob) then begin
   goto errlab;
  end;
  with poa^ do begin
   if (pob^.d.kind = ck_const) and 
               (d.kind = ck_const) then begin
    dk1:= convertconsts(poa,pob);
    case dk1 of
     sdk_cardinal,sdk_integer: begin
      if issub then begin
       d.dat.constval.vinteger:= d.dat.constval.vinteger -
                pob^.d.dat.constval.vinteger;
      end
      else begin
       d.dat.constval.vinteger:= d.dat.constval.vinteger + 
                pob^.d.dat.constval.vinteger;
      end;
     end;
     sdk_float: begin
      if issub then begin
       d.dat.constval.vfloat:= d.dat.constval.vfloat -
                             pob^.d.dat.constval.vfloat;
      end
      else begin
       d.dat.constval.vfloat:= d.dat.constval.vfloat + 
                             pob^.d.dat.constval.vfloat;
      end;
     end;
     sdk_string: begin
      concatstringconsts(d.dat.constval.vstring,pob^.d.dat.constval.vstring);
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
    if not (d.kind in alldatacontexts) or 
              not (pob^.d.kind in alldatacontexts)then begin
     errormessage(err_illegalexpression,[]);
     goto errlab;
    end;
//    india:= d.dat.datatyp.indirectlevel;
//    i1:= india;
//    if (d.kind = ck_ref) and 
//              (af_paramindirect in d.dat.ref.c.address.flags) then begin
//     dec(india);
//    end;
    if not getvalue(poa,das_none) then begin //call possible pending conversions
//    if not getvalue(poa,ptypedataty(
//            ele.eledataabs(pob^.d.dat.datatyp.typedata))^.h.datasize) then begin
                             //call possible pending conversions
     goto errlab;
    end;
//    india:= india + d.dat.datatyp.indirectlevel - i1; 
                                        //track changes by conversions
    india:= d.dat.datatyp.indirectlevel;
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
       i1:= s.stackindex;
       i2:= s.stacktop;
       updateop(subops);
       with poa^ do begin
        d.dat.datatyp:= sysdatatypes[ptrintsystype];
        d.dat.fact.opdatatype:= getopdatatype(d.dat.datatyp);
       end;
       with pob^ do begin //still valid
        ptb:= ele.eledataabs(d.dat.datatyp.typedata);
        if ptb^.h.bytesize <> 1 then begin
         d.kind:= ck_const;
         d.dat.indirection:= 0;
         d.dat.datatyp:= sysdatatypes[ptrintsystype]; //??? necessary
         d.dat.constval.kind:= dk_integer;
         d.dat.constval.vinteger:= ptb^.h.bytesize;
         s.stackindex:= i1;
         s.stacktop:= i2;
         updateop(divops);
        end;
       end;
       goto endlab;
      end;
     end
     else begin
      if india > 1 then begin
       i2:= targetpointersize;
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
//         getvalue(poa,das_none);
         i1:= d.dat.fact.ssaindex;
         with additem(oc_offsetpoimm)^ do begin
          if co_llvm in o.compileoptions then begin
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
        if {getvalue(poa,das_pointer) and} getvalue(pob,das_32) then begin
         if tryconvert(pob,st_int32) then begin //todo: data size
          i1:= pob^.d.dat.fact.ssaindex;
          if i2 <> 1 then begin
           with additem(oc_mulimmint)^ do begin
            setimmint32(i2,par.imm);
{
            if co_llvm in o.compileoptions then begin
             par.imm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(i2);
            end
            else begin
             par.imm.vint32:= i2;
            end;
}
            par.ssas1:= i1;
           end;
           i1:= s.ssa.nextindex-1;
          end;
          if issub then begin
           op1:= oc_subpoint;
          end
          else begin
           op1:= oc_addpoint;
          end;
          with additem(op1)^ do begin
           par.ssas1:= d.dat.fact.ssaindex;
           par.ssas2:= i1;
           par.stackop.t:= bitoptypes[das_32];
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
      pta:= ele.eledataabs(poa^.d.dat.datatyp.typedata);
      ptb:= ele.eledataabs(pob^.d.dat.datatyp.typedata);
      if (pta^.h.kind = dk_string) and (ptb^.h.kind = dk_string) then begin
       if poa^.d.dat.termgroupstart = 0 then begin
        poa^.d.dat.termgroupstart:= poa-pcontextitemty(pointer(contextstack));
                                         //init
       end;
       pob^.d.dat.termgroupstart:= poa^.d.dat.termgroupstart;
       contextstack[s.stackindex].d.kind:= ck_space;
       s.stackindex:= getpreviousnospace(poa^.d.dat.termgroupstart)-2;
       goto endlab; //for concatmulty
      end
      else begin
       updateop(addops);
      end;
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
   if d.kind = ck_typearg then begin
    if d.typ.indirectlevel <= 0 then begin
     errormessage(err_illegalqualifier,[]);
    end
    else begin
     dec(d.typ.indirectlevel);
    end;
   end
   else begin
    if (d.kind = ck_prop) then begin
     getvalue(potop,das_none);
    end
    else begin
     if hf_propindex in d.handlerflags then begin
      getnextnospace(s.stackindex+1,poa);
     {$ifdef mse_checkinternalerror}
      if poa^.d.kind <> ck_prop then begin
       internalerror(ie_handler,'20160214A');
      end;
     {$endif}
      if getvalue(poa,das_none) then begin
       s.stacktop:= getstackindex(poa);
       potop:= poa;
      end
      else begin
       exit;
      end;
     end
     else begin
//      if not getvalue(potop,das_none) then begin
//       exit;
//      end;
     end;
    end;
    with potop^ do begin //could be changed
     if not (d.kind in datacontexts) or 
                    (d.dat.datatyp.indirectlevel <= 0) then begin
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
   oc_none, oc_none,   oc_none,   oc_negcard,oc_negint,oc_negflo,
 //dk_kind, dk_address,dk_record,dk_string8,dk_dynarray,dk_openarray,
   oc_none, oc_none,   oc_none,  oc_none,   oc_none,    oc_none,
 //dk_array,dk_object,dk_objectpo,dk_class,dk_interface,
   oc_none, oc_none,  oc_none,    oc_none, oc_none,
 //dk_classof,dk_sub, dk_method
   oc_none,   oc_none,oc_none,
 //dk_enum,dk_enumitem,dk_set, dk_character,dk_data
   oc_none,oc_none,    oc_none,oc_none,     oc_none
 );

 notops: array[datakindty] of opcodety = (
 //dk_none, dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,
   oc_none, oc_none,   oc_not1,   oc_not,   oc_not,  oc_none,
 //dk_kind, dk_address,dk_record,dk_string8,dk_dynarray,dk_openarray,
   oc_none, oc_none,   oc_none,  oc_none,   oc_none,    oc_none,
 //dk_array,dk_object,dk_objectpo,dk_class,dk_interface,
   oc_none, oc_none,  oc_none,    oc_none, oc_none,
 //dk_classof,dk_sub,  dk_method
   oc_none,   oc_none, oc_none,
 //dk_enum,dk_enumitem,dk_set, dk_character,dk_data
   oc_none,oc_none,    oc_none,oc_none,     oc_none
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
      d.dat.constval.kind:= dk_string;
      d.dat.constval.vstring:= newstringconst();
     end;
     ck_number: begin
      initdatacontext(toppo^.d,ck_const);
      setnumberconst(toppo,d.number.value);
     end;
    end;
   end;
   indpo:= @contextstack[s.stackindex];
   indpo^.d.kind:= ck_space;
   if hf_propindex in toppo^.d.handlerflags then begin //
    if stf_getaddress in s.currentstatementflags then begin
     errormessage(err_varidentexpected,[],1);
    end
    else begin
    end;
    goto endlab1;
   end
   else begin
    with toppo^ do begin
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

procedure fact1entry();
begin
{$ifdef mse_debugparser}
 outhandle('FACT1ENTRY');
{$endif}
 with info do begin
  exclude(s.currentstatementflags,stf_cutvalueident);
 end;
end;

procedure fact2entry();
begin
{$ifdef mse_debugparser}
 outhandle('FACT2ENTRY');
{$endif}
 with info do begin
  include(s.currentstatementflags,stf_cutvalueident);
//  contextstack[s.stacktop].context:= @dummyco; //remove checkvalueparams
(*
 {$ifdef mse_checkinternalerror}
  if s.stacktop-s.stackindex <> 1 then begin
   internalerror(ie_handler,'20140406B');
  end;
 {$endif}
  contextstack[s.stackindex].d:= contextstack[s.stackindex+1].d;
  dec(s.stacktop);
*)
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
function checkunioperator(const aop: objectoperatorty;
           const acontext: pcontextitemty; const atype: ptypedataty): boolean;
var
 operatorsig: identvecty;
 oper1: poperatordataty;
 i1,i2,i3: int32;
 sub1: psubdataty;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKUNIOPERATOR');
{$endif}
 result:= false;
 if (atype^.h.kind = dk_object) and 
                      (acontext^.d.dat.datatyp.indirectlevel = 0) then begin
  operatorsig.d[0]:= tks_operators;
  operatorsig.d[1]:= objectoperatoridents[aop];
  setoperparamid(@operatorsig.d[2],0,nil); //no return value
  operatorsig.high:= 3;

  if ele.findchilddata(basetype(ele.eledatarel(atype)),
                          operatorsig,[ek_operator],allvisi,oper1) then begin
  {$ifdef mse_checkinternalerror}
   if not (acontext^.d.kind in factcontexts) then begin
    internalerror(ie_handler,'20170528A');
   end;
  {$endif}
   i1:= acontext^.d.dat.fact.ssaindex;
   i2:= getstackindex(acontext);
   with insertitem(oc_pushstackaddr,i2-info.s.stackindex,-1)^.par do begin
    memop.tempdataaddress.offset:= 0;
    memop.tempdataaddress.a.address:= -alignsize(atype^.h.bytesize);
    ssas1:= i1;
    memop.t:= getopdatatype(atype,0);
   end;
   sub1:= ele.eledataabs(oper1^.methodele);
   callsub(i2,sub1,i2,0,[dsf_instanceonstack]);
   with additem(oc_loadalloca)^ do begin
    par.ssas1:= i1+1; //ssa of alloca
    acontext^.d.kind:= ck_subres;
    acontext^.d.dat.fact.ssaindex:= par.ssad;
   end;
   result:= true;
  end;
 end;
end;

procedure handlenegfact();
var
 po1: ptypedataty;
 i1: int32;
 poa: pcontextitemty;
 op1: opcodety;
label
 errlab;
begin
// handlefact;
{$ifdef mse_debugparser}
 outhandle('NEGFACT');
{$endif}
 with info do begin
  if not getfactstart(s.stacktop,poa) then begin
   goto errlab;
  end;
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
     op1:= negops[po1^.h.kind];
     if op1 = oc_none then begin
      if not checkunioperator(oa_sub,poa,po1) then begin
       errormessage(err_negnotpossible,[],s.stacktop-s.stackindex);
      end;
     end
     else begin
      i1:= d.dat.fact.ssaindex;
      with insertitem(op1,s.stacktop-s.stackindex,-1)^ do begin
       par.ssas1:= i1;
       par.stackop.t:= getopdatatype(d.dat.datatyp.typedata,
                                               d.dat.datatyp.indirectlevel);
      end;
     end;
    end;
   end;
errlab:
   contextstack[s.stackindex].d.kind:= ck_space;
   dec(s.stackindex);
  end;
 end;
end;

procedure handlenotfact;
var
 po1: ptypedataty;
 i1: int32;
 poa: pcontextitemty;
 op1: opcodety;
label
 errlab;
begin
// handlefact;
{$ifdef mse_debugparser}
 outhandle('NOTFACT');
{$endif}
 with info do begin
  if not getfactstart(s.stacktop,poa) then begin
   goto errlab;
  end;
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
     op1:= notops[po1^.h.kind];
     if op1 = oc_none then begin
      if not checkunioperator(oa_not,poa,po1) then begin
       errormessage(err_notnotpossible,[],s.stacktop-s.stackindex);
      end;
     end
     else begin
      i1:= d.dat.fact.ssaindex;
      with insertitem(op1,s.stacktop-s.stackindex,-1)^ do begin
       par.ssas1:= i1;
       par.stackop.t:= getopdatatype(d.dat.datatyp.typedata,
                                               d.dat.datatyp.indirectlevel);
      end;
     end;
    end;
   end;
errlab:
   contextstack[s.stackindex].d.kind:= ck_space;
   dec(s.stackindex);
  end;
 end;
end;

procedure handlelistfact(); //not finished
var
 po1,pe: pcontextitemty;
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('LISTFACT');
{$endif}
 with info do begin
  with contextstack[s.stackindex] do begin
   d.kind:= ck_list;
   d.list.contextcount:= s.stacktop - s.stackindex;
   po1:= @contextstack[s.stackindex+1];
   pe:= po1 + d.list.contextcount;
   inc(d.list.contextcount);
   d.list.flags:= [lf_allconst];
   i1:= 0;
   while po1 < pe do begin
    if po1^.d.kind <> ck_space then begin
     inc(i1);
     include(po1^.d.handlerflags,hf_listitem);
     if po1^.d.kind <> ck_const then begin
      exclude(d.list.flags,lf_allconst);
     end;
    end;
    inc(po1);
   end;
   d.list.itemcount:= i1;
  end;
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
   with contextstack[s.stackindex] do begin
    d.kind:= ck_space;
    context:= nil;
//////////////////////    context:= @dummyco;
   end;
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
(*
procedure handleblockend();
begin
{$ifdef mse_debugparser}
 outhandle('BLOCKEND');
{$endif}
// with info^ do begin
//  s.stackindex:= s.stackindex-2;
// end;
end;
*)
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

procedure handleopenroundbracketexpected();
begin
{$ifdef mse_debugparser}
 outhandle('OPENROUNDBRACKETEXPECTED');
{$endif}
 tokenexpectederror(')',erl_fatal);
end;

procedure handlecloseroundbracketexpected();
begin
{$ifdef mse_debugparser}
 outhandle('CLOSEROUNDBRACKETEXPECTED');
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

procedure handleattachitemsentry();
begin
{$ifdef mse_debugparser}
 outhandle('ATTACHITEMENTRY');
{$endif}
 info.stringbuffer:= '';
end;

procedure handleattachvalue();
begin
{$ifdef mse_debugparser}
 outhandle('ATTACHVALUE');
{$endif}
 with info do begin
  if contextstack[s.stacktop].d.kind = ck_str then begin
   with contextstack[s.stacktop-1] do begin
    d.kind:= ck_stringident;
    d.ident.ident:= getident(info.stringbuffer); 
   end;
  end;
  s.stacktop:= s.stacktop-1;
 end;
end;

procedure handlestringattach();
begin
{$ifdef mse_debugparser}
 outhandle('STRINGATTACH');
{$endif}
 with info,contextstack[s.stacktop] do begin
  d.kind:= ck_stringident;
  d.ident.ident:= getident(info.stringbuffer);
 end;
end;

procedure handlestringexpected();
begin
{$ifdef mse_debugparser}
 outhandle('STRINGEXPECTED');
{$endif}
 with info do begin
  errormessage(err_stringexpected,[],s.stacktop-s.stackindex);
 end;
end;

procedure handlenoattachitemerror();
begin
{$ifdef mse_debugparser}
 outhandle('NOATTACHITEMERROR');
{$endif}
 errormessage(err_attachitemexpected,[],minint,0,erl_fatal);
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

procedure addsimpleconst();
var
 po1: pconstdataty;
begin
 with info do begin
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
     if dat.constval.kind = dk_string then begin
      trackstringref(dat.constval.vstring);
     end;
     po1^.val.d:= dat.constval;
    end;
   end;
  end;
 end;
end;

procedure handleconst3();
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
  addsimpleconst();
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
  if (stf_params in s.currentstatementflags) and 
                               (toppo^.d.kind in datacontexts) then begin
   concatterms(nil,toppo);
  end;
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
 {$ifdef mse_checkinternalerror}
  if not (contextstack[s.stackindex].d.kind in [ck_none,ck_space]) then begin
   internalerror(ie_handler,'20160708A');
  end;
 {$endif}
  contextstack[s.stackindex].d.kind:= ck_space;
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

//type
// cmpopty = (cmpo_eq,cmpo_ne,cmpo_gt,cmpo_lt,cmpo_ge,cmpo_le{,cmpo_in});

const
 cmpops: array[compopkindty] of opsinfoty = (
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,   sdk_int32,
  (ops: (oc_none, oc_cmppo, oc_cmpbool,oc_cmpint,oc_cmpint,                        
       //sdk_flo64,    sdk_set32,    sdk_string8
         oc_cmpflo,oc_cmpint,oc_cmpstring);
   wantedtype: st_none; opname: '='; objop: oa_eq),
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,   sdk_int32,
  (ops: (oc_none, oc_cmppo, oc_cmpbool,oc_cmpint,oc_cmpint,
       //sdk_flo64,    sdk_set32,    sdk_string8
         oc_cmpflo,oc_cmpint,oc_cmpstring);
   wantedtype: st_none; opname: '<>'; objop: oa_ne),
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,    sdk_int32,
  (ops: (oc_none, oc_cmppo, oc_cmpbool,oc_cmpcard,oc_cmpint,
       //sdk_flo64,    sdk_set32,sdk_string8
         oc_cmpflo,oc_none,  oc_cmpstring);
   wantedtype: st_none; opname: '>'; objop: oa_gt),
       //sdk_none,sdk_pointer,sdk_bool1,   sdk_card32,    sdk_int32,
  (ops: (oc_none, oc_cmppo, oc_cmpbool,oc_cmpcard,oc_cmpint,
       //sdk_flo64,    sdk_set32,sdk_string8
         oc_cmpflo,oc_none,  oc_cmpstring);
   wantedtype: st_none; opname: '<'; objop: oa_lt),
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,
  (ops: (oc_none,oc_cmppo,oc_cmpbool,oc_cmpcard,oc_cmpint,
       //sdk_flo64,    sdk_set32,sdk_string8
         oc_cmpflo,oc_none,  oc_cmpstring);
   wantedtype: st_none; opname: '>='; objop: oa_ge),
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,
  (ops: (oc_none,oc_cmppo,oc_cmpbool,oc_cmpcard,oc_cmpint,
       //sdk_flo64,    sdk_set32,    sdk_string8
         oc_cmpflo,oc_setcontains,oc_cmpstring);
   wantedtype: st_none; opname: '<='; objop: oa_le){,
       //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,  sdk_int32,
  (ops: (oc_none, oc_none,    oc_none,  oc_none,     oc_none,
       //sdk_flo64,    sdk_set32,sdk_string8
         oc_none,      oc_none,  oc_none); //special handling
   wantedtype: st_none; opname: 'in')}
 );

function compstring8(const a,b: stringvaluety): stringsizety;
var
 sa,sb: lstringty;
 poa,poe,pob: pint8;
 i1: int8;
begin
 result:= 0;
 sa:= getstringconst(a);
 sb:= getstringconst(b);
 if sa.po <> sb.po then begin
  poa:= pointer(sa.po);
  pob:= pointer(sb.po);
  if sa.len < sb.len then begin
   poe:= poa + sa.len;
  end
  else begin
   poe:= poa + sb.len;
  end;
  while poa < poe do begin
   i1:= poa^ - pob^;
   if i1 <> 0 then begin
    result:= i1;
    break;
   end;
   inc(poa);
   inc(pob);
  end;
  if result = 0 then begin
   result:= sa.len - sb.len;
  end;
 end;
end;

procedure concatterms(const wanted,terms: pcontextitemty); 
        //wanted = nil -> use first term

 procedure doconcat(wanted,terms: pcontextitemty);
 var
  wantedtype: systypety;
  pa: ptypedataty;
  pt,p1,pe: pcontextitemty;
  i1,i2,i3: int32;
  palloc: plistitemallocinfoty;
  op1: opcodety;
//  termsindex: int32;
 begin
//  termsindex:= terms-pcontextitemty(pointer(info.contextstack));
  pt:= @info.contextstack[terms^.d.dat.termgroupstart];
  if wanted = nil then begin
   wanted:= pt;
  end;
 {$ifdef mse_checkinternalerror}
  if not (pt^.d.kind in datacontexts) then begin
   internalerror(ie_handler,'20170427B');
  end;
 {$endif}
  pe:= terms;

//  if wanted <> nil then begin
 {$ifdef mse_checkinternalerror}
  if not (wanted^.d.kind in datacontexts) then begin
   internalerror(ie_handler,'20170405B');
  end;
 {$endif}
  if wanted^.d.kind = ck_const then begin
   pa:= ele.eledataabs(pt^.d.dat.datatyp.typedata);
  {$ifdef mse_checkinternalerror}
   if pa^.h.kind <> dk_string then begin
    internalerror(ie_handler,'20170406C');
   end;
  {$endif}
   case pa^.itemsize of
    1: begin
     wantedtype:= st_string8;
    end;
    2: begin
     wantedtype:= st_string16;
    end;
    4: begin
     wantedtype:= st_string32;
    end
    else begin
     internalerror1(ie_handler,'20170405G');
    end;
   end;
   if not tryconvert(wanted,wantedtype,[]) then begin
    internalerror1(ie_handler,'20170406A');
   end;
  end
  else begin
   pa:= ele.eledataabs(pe^.d.dat.datatyp.typedata);
  {$ifdef mse_checkinternalerror}
   if pa^.h.kind <> dk_string then begin
    internalerror(ie_handler,'20170406B');
   end;
  {$endif}
   case pa^.itemsize of
    1: begin
     wantedtype:= st_string8;
    end;
    2: begin
     wantedtype:= st_string16;
    end;
    4: begin
     wantedtype:= st_string32;
    end
    else begin
     internalerror1(ie_handler,'20170405G');
    end;
   end;
  end;
//  end;
 (*
  else begin
   pa:= ele.eledataabs(pt^.d.dat.datatyp.typedata);
  {$ifdef mse_checkinternalerror}
   if pa^.h.kind <> dk_string then begin
    internalerror(ie_handler,'20170406B');
   end;
  {$endif}
   case pa^.itemsize of
    1: begin
     wantedtype:= st_string8;
    end;
    2: begin
     wantedtype:= st_string16;
    end;
    4: begin
     wantedtype:= st_string32;
    end
    else begin
     internalerror(ie_handler,'20170405G');
    end;
   end;
  end;
 *)
  case wantedtype of 
   st_string8: begin
    op1:= oc_concatstring8;
   end;
   st_string16: begin
    op1:= oc_concatstring16;
   end;
   st_string32: begin
    op1:= oc_concatstring32;
   end;
  end;
  p1:= pt;
  i1:= 0;
  while p1 <= pe do begin
   if p1^.d.kind <> ck_space then begin
   {$ifdef mse_checkinternalerror}
    if not (p1^.d.kind in datacontexts) then begin
     internalerror(ie_handler,'20170405D');
    end;
   {$endif}
    if not tryconvert(p1,wantedtype,[]) then begin
     internalerror1(ie_handler,'20170405E');
    end;
    getvalue(p1,das_none);
    inc(i1);
   end;
   inc(p1);
  end;
 {$ifdef mse_checkinternalerror}
  if not (terms^.d.kind in factcontexts) then begin
   internalerror(ie_handler,'20170428A');
  end;
 {$endif}
  p1:= pt;
  if co_llvm in info.o.compileoptions then begin
   i2:= terms^.d.dat.fact.ssaindex;
   i3:= allocsegmentoffset(seg_localloc,sizeof(listitemallocinfoty)*i1,palloc);
   while p1 <= pe do begin
    if p1^.d.kind <> ck_space then begin
     palloc^.ssaoffs:= p1^.d.dat.fact.ssaindex-i2;
     inc(palloc);
     if p1 <> pe then begin
      p1^.d.kind:= ck_space;
     end;
    end;
    inc(p1);
   end;
  end
  else begin
   while p1 < pe do begin
    p1^.d.kind:= ck_space;
    inc(p1);
   end;
  end;
  with insertitem(op1,terms,-1,getssa(ocssa_concattermsitem)*i1)^ do begin
   par.listinfo.alloccount:= i1;
   if co_llvm in info.o.compileoptions then begin
    setimmint32(i1,par.concatstring.alloccount);
    par.concatstring.arraytype:= info.s.unitinfo^.
            llvmlists.typelist.addbytevalue(i1*targetpointersize);
    par.listinfo.allocs:= i3;
   end;
   addmanagedtemp(terms);
   terms^.d.dat.termgroupstart:= 0;
  end;
 end;//doconcat
 
begin
{$ifdef mse_checkinternalerror}
 if (wanted <> nil) and not (wanted^.d.kind in datacontexts) or 
                          not (terms^.d.kind in datacontexts) then begin
  internalerror(ie_handler,'20170405A');
 end;
{$endif}
 if (wanted <> nil) and (wanted^.d.dat.termgroupstart <> 0) then begin
  doconcat(terms,wanted);
 end;
 if terms^.d.dat.termgroupstart <> 0 then begin
  doconcat(wanted,terms);
//  info.s.stacktop:= terms^.d.dat.termgroupstart;
 end;
end;

procedure handlecomparison(const aop: compopkindty);

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
 op1: popinfoty;
label
 errlab;
begin
 with info do begin
  if not getfactstart(s.stackindex-1,poa) or 
                              not getfactstart(s.stacktop,pob) then begin
   goto errlab;
  end;
  concatterms(poa,pob);
  with poa^ do begin
   if (pob^.d.kind = ck_const) and (d.kind = ck_const) then begin
    dk1:= convertconsts(poa,pob);
    case aop of
     cok_eq: begin
      case dk1 of
       sdk_cardinal,sdk_integer: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger = 
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_float: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat = 
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_boolean: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean =
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_pointer: begin
        d.dat.constval.vboolean:= compaddress(d.dat.constval.vaddress,
                                             pob^.d.dat.constval.vaddress) = 0;
       end;
       sdk_set: begin
        d.dat.constval.vboolean:= tintegerset(d.dat.constval.vset) =
                                         tintegerset(pob^.d.dat.constval.vset);
       end;
       sdk_string: begin
        d.dat.constval.vboolean:= compstring8(d.dat.constval.vstring,
                                          pob^.d.dat.constval.vstring) = 0;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cok_ne: begin
      case dk1 of
       sdk_cardinal,sdk_integer: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger <>
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_float: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat <>
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_boolean: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean <>
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_set: begin
        d.dat.constval.vboolean:= tintegerset(d.dat.constval.vset) <>
                                         tintegerset(pob^.d.dat.constval.vset);
       end;
       sdk_string: begin
        d.dat.constval.vboolean:= compstring8(d.dat.constval.vstring,
                                          pob^.d.dat.constval.vstring) <> 0;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cok_gt: begin
      case dk1 of
       sdk_cardinal,sdk_integer: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger >
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_float: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat >
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_boolean: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean >
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_string: begin
        d.dat.constval.vboolean:= compstring8(d.dat.constval.vstring,
                                          pob^.d.dat.constval.vstring) > 0;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cok_lt: begin
      case dk1 of
       sdk_cardinal,sdk_integer: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger <
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_float: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat <
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_boolean: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean <
                                                  pob^.d.dat.constval.vboolean;
       end;
      end;
     end;
     cok_ge: begin
      case dk1 of
       sdk_cardinal,sdk_integer: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger >=
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_float: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat >=
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_boolean: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean >=
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_string: begin
        d.dat.constval.vboolean:= compstring8(d.dat.constval.vstring,
                                          pob^.d.dat.constval.vstring) >= 0;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
     cok_le: begin
      case dk1 of
       sdk_cardinal,sdk_integer: begin
        d.dat.constval.vboolean:= d.dat.constval.vinteger <=
                                                  pob^.d.dat.constval.vinteger;
       end;
       sdk_float: begin
        d.dat.constval.vboolean:= d.dat.constval.vfloat <=
                                                    pob^.d.dat.constval.vfloat;
       end;
       sdk_boolean: begin
        d.dat.constval.vboolean:= d.dat.constval.vboolean <=
                                                  pob^.d.dat.constval.vboolean;
       end;
       sdk_set: begin
        d.dat.constval.vboolean:= tintegerset(d.dat.constval.vset) <=
                                         tintegerset(pob^.d.dat.constval.vset);
       end;
       sdk_string: begin
        d.dat.constval.vboolean:= compstring8(d.dat.constval.vstring,
                                          pob^.d.dat.constval.vstring) <= 0;
       end;
       else begin
        notsupported();
       end;
      end;
     end;
    end;
    d.dat.constval.kind:= dk_boolean;
    d.dat.datatyp:= sysdatatypes[st_bool1];
errlab:
    s.stacktop:= getpreviousnospace(s.stackindex - 1);
    s.stackindex:= getpreviousnospace(s.stacktop-1);
   end
   else begin
    op1:= updateop(cmpops[aop]);
    if op1 = nil then begin
     exit; //error state
    end;
    with op1^.par do begin
     stackop.compkind:= aop;
    end;
    with info,poa^ do begin
//     d.dat.datatyp:= sysdatatypes[resultdatatypes[sdk_boolean]];
     d.dat.datatyp:= sysdatatypes[st_bool1];
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
 handlecomparison(cok_eq);
end;

procedure handlenesimpexp();
var
 dk1:stackdatakindty;
begin
{$ifdef mse_debugparser}
 outhandle('NESIMPEXP');
{$endif}
 handlecomparison(cok_ne);
end;

procedure handlegtsimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('GTSIMPEXP');
{$endif}
 handlecomparison(cok_gt);
end;

procedure handleltsimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('LTSIMPEXP');
{$endif}
 handlecomparison(cok_lt);
end;

procedure handlegesimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('GESIMPEXP');
{$endif}
 handlecomparison(cok_ge);
end;

procedure handlelesimpexp();
begin
{$ifdef mse_debugparser}
 outhandle('LESIMPEXP');
{$endif}
 handlecomparison(cok_le);
end;

procedure handleinsimpexp();
var
// baseoffset: int32;
 poa,pob: pcontextitemty;
label
 errlab;
begin
{$ifdef mse_debugparser}
 outhandle('INSIMPEXP');
{$endif}
 with info do begin
  if not getfactstart(s.stackindex-1,poa) or 
                              not getfactstart(s.stacktop,pob) then begin
   goto errlab;
  end;
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
   operationnotsupportederror(poa^.d,pob^.d,'in');
  end;
errlab:
  s.stacktop:= getpreviousnospace(s.stackindex-1);
  s.stackindex:= getpreviousnospace(s.stacktop-1);
 end;
end;

procedure handleissimpexp();

 function gettyp(const acontext: pcontextitemty; out atyp: ptypedataty; 
                                               out aindilev: int32): boolean;
 begin
  result:= false;
  atyp:= nil;
  if acontext^.d.kind in datacontexts then begin
   atyp:= ele.eledataabs(acontext^.d.dat.datatyp.typedata);
   aindilev:= acontext^.d.dat.datatyp.indirectlevel;
//   if atyp^.h.kind = dk_class then begin
//    dec(aindilev); //implicit dereference
//   end;
  end
  else begin
   if acontext^.d.kind = ck_typearg then begin
    atyp:= ele.eledataabs(acontext^.d.typ.typedata);
    aindilev:= atyp^.h.indirectlevel;
   end
  end;
  if atyp <> nil then begin
   if (atyp^.h.kind = dk_classof) and (aindilev = 1) then begin
    atyp:= ele.eledataabs(atyp^.infoclassof.classtyp);
    result:= true;
   end
   else begin
    if (atyp^.h.kind = dk_class) and (aindilev = 1) or
       (atyp^.h.kind = dk_object) and ((aindilev = 0) or 
                                   (aindilev = 1)) then begin
     result:= true;
    end;
   end;
  end;
  if not result then begin
   errormessage(err_objectorclasstypeexpected,[],acontext);
  end;
 end; //gettyp()
 
 function getclassdef(const acontext: pcontextitemty): boolean;
 var
  typ1: ptypedataty;
  i1: int32;
 begin
  result:= false;
  if acontext^.d.kind = ck_typearg then begin
   typ1:=  ptypedataty(ele.eledataabs(acontext^.d.typ.typedata));
   with insertitem(oc_pushsegaddr,acontext,-1,
                                    pushsegaddrssaar[seg_classdef])^ do begin
    par.memop.segdataaddress.a:= typ1^.infoclass.defs;
    par.memop.segdataaddress.offset:= 0;
    par.memop.t:= bitoptypes[das_pointer];
   end;
   initfactcontext(acontext);
   result:= true;
  end
  else begin
  {$ifdef mse_checkinternalerror}
   if not (acontext^.d.kind in datacontexts) then begin
    internalerror(ie_handler,'20170717A');
   end;
  {$endif}
   typ1:= ptypedataty(ele.eledataabs(
                             acontext^.d.dat.datatyp.typedata));
   if acontext^.d.dat.datatyp.indirectlevel > 0 then begin
    if getvalue(acontext,das_none) then begin
     result:= true;
    end;
    if typ1^.h.kind = dk_classof then begin
     exit;
    end;
   end
   else begin
    if getaddress(acontext,true) then begin
     result:= true;
    end;
   end;
   if not (tf_classdef in acontext^.d.dat.datatyp.flags) then begin
    if not (icf_virtual in typ1^.infoclass.flags) then begin
     result:= false;
     errormessage(err_objectorclassvirtual,[],acontext);   
    end
    else begin
     i1:= acontext^.d.dat.fact.ssaindex;
     with insertitem(oc_getclassdef,acontext,-1)^.par do begin
      ssas1:= i1;
      setimmint32(typ1^.infoclass.virttaboffset,imm);
     end;
    end;
   end;
  end;
 end; //getclassdef();
 
var
 poa,pob: pcontextitemty;
 typa,typb,typ1: ptypedataty;
 indileva,indilevb: int32;
 ele1: elementoffsetty;
 i1,i2: int32;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ISSIMPEXP');
{$endif}
 with info do begin           //todo: class of, object of
  if not getfactstart(s.stackindex-1,poa) or 
                              not getfactstart(s.stacktop,pob) then begin
   goto endlab;
  end;
  if not gettyp(poa,typa,indileva) or not gettyp(pob,typb,indilevb) then begin
   goto endlab;
  end;
  if (typa^.h.kind <> typb^.h.kind) or (indileva <> indilevb) then begin
   errormessage(err_isopnomatch,[],pob);
   goto endlab;
  end;
  ele1:= ele.eledatarel(typb);
  typ1:= typa;
  if (poa^.d.kind = ck_typearg) and (pob^.d.kind = ck_typearg) then begin
   while true do begin
    if ele.eledatarel(typ1) = ele1 then begin
     setconstcontext(poa,valuetrue);
     goto endlab;
    end;
    ele1:= typ1^.h.ancestor;
    if ele1 = 0 then begin
     break;
    end;
    typ1:= ele.eledataabs(ele1);
   end;
   setconstcontext(poa,valuefalse);
   goto endlab;
  end;    
  ele1:= ele.eledatarel(typa);
  typ1:= typb;
  while true do begin
   if ele.eledatarel(typ1) = ele1 then begin
    break; //common ancestor, "is" possible
   end;
   ele1:= typ1^.h.ancestor;
   if ele1 = 0 then begin
    setconstcontext(poa,valuefalse); //no common ancestor
    goto endlab;
   end;
   typ1:= ele.eledataabs(ele1);
  end;
  {
  if not (icf_virtual in typa^.infoclass.flags) then begin
   errormessage(err_objectorclassvirtual,[],poa);
   goto endlab;
  end;
  if not (icf_virtual in typb^.infoclass.flags) then begin
   errormessage(err_objectorclassvirtual,[],pob);
   goto endlab;
  end;
  }
  if getclassdef(poa) then begin
   i1:= poa^.d.dat.fact.ssaindex;
   if getclassdef(pob) then begin
    i2:= pob^.d.dat.fact.ssaindex;
    with insertitem(oc_classis,pob,-1)^.par do begin
     ssas1:= i1;
     ssas2:= i2;
     poa^.d.dat.fact.ssaindex:= ssad;
    end;
    poa^.d.dat.datatyp:= sysdatatypes[st_bool1];
    poa^.d.dat.fact.opdatatype:= getopdatatype(poa^.d.dat.datatyp);
    exclude(poa^.d.dat.fact.flags,faf_classele);
   end;
  end;
endlab:
  s.stacktop:= getpreviousnospace(s.stackindex-1);
  s.stackindex:= getpreviousnospace(s.stacktop-1);
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

 //das_none, das_1,     das_2_7,   das_8,                  //mdv_segment
  (oc_popseg,oc_popseg8,oc_popseg8,oc_popseg8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_popseg16,oc_popseg16,oc_popseg32,oc_popseg32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_popseg64,oc_popseg64,oc_popsegpo,oc_popsegf16,oc_popsegf32,oc_popsegf64,
 //das_sub,    das_meta
   oc_popsegpo,oc_none), 
 //das_none, das_1,     das_2_7,   das_8,                  //mdv_local
  (oc_poploc,oc_poploc8,oc_poploc8,oc_poploc8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_poploc16,oc_poploc16,oc_poploc32,oc_poploc32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_poploc64,oc_poploc64,oc_poplocpo,oc_poplocf16,oc_poplocf32,oc_poplocf64,
 //das_sub,   ,das_meta
   oc_poplocpo,oc_none), 
 //das_none, das_1,     das_2_7,   das_8,                  //mdv_param
  (oc_poppar,oc_poppar8,oc_poppar8,oc_poppar8,
 //das_9_15,   das_16,     das_17_31,  das_32,     
   oc_poppar16,oc_poppar16,oc_poppar32,oc_poppar32,
 //das_33_63,  das_64,     das_pointer,das_f16,     das_f32,     das_f64
   oc_poppar64,oc_poppar64,oc_popparpo,oc_popparf16,oc_popparf32,oc_popparf64,
 //das_sub,    das_meta
   oc_popparpo,oc_none
   ), 
 //das_none, das_1,     das_2_7,   das_8,                  //mdv_paramindi
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

function getpoptempop(const asize: databitsizety): opcodety;
begin
 result:= popoptable[mvd_local,asize];
end;
 
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

function canvarresult(const source,dest: pcontextitemty;
                                     const indirectlevel: int32): boolean;
begin
{$ifdef mse_checkinternalerror}
 if not (source^.d.kind in datacontexts) or not 
                             (dest^.d.kind in datacontexts) then begin
  internalerror(ie_handler,'20170828A');;
 end;
{$endif}
 result:= (source^.d.dat.datatyp.indirectlevel = indirectlevel) and
           issamebasetype(source^.d.dat.datatyp.typedata,
                                            dest^.d.dat.datatyp.typedata);
end;

procedure directvarresult(const source,dest: pcontextitemty);
var
 p1: popinfoty;
begin
{$ifdef mse_checkinternalerror}
 if not (co_llvm in info.o.compileoptions) then begin
  notimplementederror('20170828C');
 end;
 if (source^.d.kind <> ck_subres) or 
               not(faf_varsubres in source^.d.dat.fact.flags) then begin
  internalerror(ie_handler,'20170828B');;
 end;
{$endif}
 p1:= getoppo(source^.d.dat.fact.varsubres.startopoffset +
                                             source^.opmark.address);
{$ifdef mse_checkinternalerror}
 if (p1^.op.op <> oc_pushtempaddr) then begin
  internalerror(ie_handler,'20170828D');
 end;
{$endif}
 setnopop(p1^);
(*
 p1:= getoppo(source^.d.dat.fact.varsubres.endopoffset + 
                                            source^.opmark.address-1);
{$ifdef mse_checkinternalerror}
 if p1^.op.op <> oc_pushtemp then begin
  internalerror(ie_handler,'20170828E');
 end;
{$endif}
 setnopop(p1^);
*)
 if not (dest^.d.kind in factcontexts) then begin
  if not getaddress(dest,true) then begin
   exit;
  end;
 end;
 with ptempvaritemty(getlistitem(tempvarlist,
                     source^.d.dat.fact.varsubres.tempvar))^ do begin
  typeid:= -1; //not used
 end;
 with pparallocinfoty(
   getsegmentpo(seg_localloc,source^.d.dat.fact.varsubres.varparam))^ do begin
  ssaindex:= dest^.d.dat.fact.ssaindex; //use dest address directly
 end;
end;

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
 needsmanage,needsincref,needsdecref,needstempini: boolean;

 procedure decref(const aop: managedopty);
 var
  i1: int32;
 begin
//  ad1.contextindex:= getstackindex(dest);
  ad1.offset:= 0;
  if indi then begin
   ad1.kind:= ark_stackindi;
   ad1.address:= ad1.address-targetpointersize;
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
// potop: pcontextitemty;
 i2: int32;
 flags1: dosubflagsty;
 sourcessa1: int32;
 sourcetyp: ptypedataty;
 b1: boolean;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENT');
{$endif}
 with info do begin       //todo: use direct move if possible
//  potop:= @contextstack[s.stacktop];
  if not errorfla then begin
   ad1.contextindex:= s.stacktop;
   ad1.isclass:= false;
   if not getnextnospace(s.stackindex+1,dest) or 
          not getpreviousnospace(s.stacktop,source) then begin
//                               not getnextnospace(dest+1,source) then begin
    internalerror1(ie_handler,'20160607A');
   end;
//   if (source^.d.kind = ck_list) and not listtoset(source) then begin
//    goto endlab;
//   end;
   if not (dest^.d.kind in datacontexts) then begin
    errormessage(err_argnotassign,[],dest);
    goto endlab;
   end;
   if (source^.d.kind <> ck_list) and (source^.d.kind in datacontexts) then begin
    concatterms(dest,source);
   end;
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
        getnextnospace(dest+1,source);
        if source^.d.kind = ck_index then begin
         source^.d.kind:= ck_space;
         i1:= getstackindex(source);
         while getnextnospace(source+1,source) and 
                                (source^.parent = i1) do begin
          inc(i2);
         end;
        end;
        getclassvalue(dest);
        ele.pushelementparent(writeele);
        getvalue(source,das_none);
        i1:= s.stackindex;
        s.stackindex:= getstackindex(dest);
        callsub(s.stackindex,psubdataty(ele.eledataabs(writeele)),
                   s.stackindex+1,i2,[dsf_indexedsetter,dsf_writesub]{flags1});
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
    if not getnextnospace(dest+1,source) then begin
     internalerror1(ie_handler,'20160607B');
    end;
    isconst:= (source^.d.kind = ck_const) or 
          (source^.d.kind = ck_list) and (lf_allconst in source^.d.list.flags);
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
     sourcetyp:= ele.eledataabs(source^.d.dat.datatyp.typedata);
     
     if (source^.d.kind = ck_ref) and 
            (source^.d.dat.ref.castchain <> 0) then begin
      if not checkdatatypeconversion(source) then begin 
                                          //faf_varsubres must be valid
       goto endlab;
      end;
     end;
     if af_paramindirect in destvar.address.flags then begin
      dec(indilev1);
     end;

     if (co_llvm in o.compileoptions) and (source^.d.kind = ck_subres) and
              (faf_varsubres in source^.d.dat.fact.flags) and
                       canvarresult(source,dest,indilev1) then begin
      directvarresult(source,dest); //remove temp variable
      goto endlab;
     end;

     if (indilev1 = 0) and ((destvar.typ^.h.kind = dk_object) or
                                   (sourcetyp^.h.kind = dk_object)) then begin
                        //todo: allow compatible descendants

      if not tryconvert(source,destvar.typ,indilev1,[]) then begin
       assignmenterror(source^.d,destvar);
       goto endlab;
      end;

      i1:= basetype(destvar.typ);
      if (i1 = basetype(source^.d.dat.datatyp.typedata)) and
         (source^.d.dat.datatyp.indirectlevel = 0) and
              (sourcetyp^.infoclass.subattach.assign <> 0) and
          ((currentobject = 0) or (basetype(currentobject) <> i1)) then begin
       if not (dest^.d.kind in factcontexts) and 
                            not getaddress(dest,true) then begin
        goto endlab;
       end;
       if (source^.d.kind = ck_ref) or 
                            (source^.d.dat.indirection < 0) then begin
        if not getaddress(source,true) then begin
         goto endlab;
        end;
        i1:= -targetpointersize;
        i2:= source^.d.dat.fact.ssaindex;
       end
       else begin
        if not getvalue(source,das_none) then begin
         goto endlab;
        end;
        i1:= -alignsize(sourcetyp^.h.bytesize);
        i2:= source^.d.dat.fact.ssaindex;
        with insertitem(oc_pushstackaddr,source,-1)^.par do begin //instance
         memop.tempdataaddress.offset:= 0;
         memop.tempdataaddress.a.address:= i1;
         ssas1:= i2;
         memop.t:= getopdatatype(sourcetyp,0);
        end;
        i2:= source^.d.dat.fact.ssaindex;
        i1:= i1-targetpointersize;
       end;
       flags1:= [dsf_instanceonstack,dsf_noinstancecopy,
                           dsf_nooverloadcheck,dsf_objassign,dsf_useobjssa];
       if co_mlaruntime in o.compileoptions then begin
        with additem(oc_pushduppo)^ do begin       //dest
         par.voffset:= i1-targetpointersize;
        end;
        flags1:= flags1 + [dsf_noparams];
       end;
       callsub(s.stacktop,ele.eledataabs(sourcetyp^.infoclass.subattach.assign),
                                              getstackindex(dest),1,flags1,i2);
       if co_mlaruntime in o.compileoptions then begin
        with additem(oc_pop)^ do begin
         par.imm.vsize:= -i1-targetpointersize; //compensate instance pop
        end;
       end;
       goto endlab;
      end;
      {
      if not tryconvert(source,destvar.typ,indilev1,[]) then begin
       assignmenterror(source^.d,destvar);
       goto endlab;
      end;
      }
     end;
     if (co_llvm in o.compileoptions) and (source^.d.kind = ck_subres) and
              (faf_varsubres in source^.d.dat.fact.flags) and
                       canvarresult(source,dest,indilev1) then begin
      directvarresult(source,dest); //remove temp variable
      goto endlab;
     end;
     if destvar.typ^.h.kind = dk_class then begin
      needsmanage:= (indilev1 = 1) and (tf_managed in destvar.typ^.h.flags);
      ad1.isclass:= true;
     end
     else begin
      needsmanage:= (indilev1 = 0) and (tf_needsmanage in destvar.typ^.h.flags)
     end;
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
      assignmenterror(source^.d,destvar);
      goto endlab;
     end;
     if needsmanage then begin
      if source^.d.kind in factcontexts then begin
       sourcessa1:= source^.d.dat.fact.ssaindex;
      end;
      b1:= (source^.d.kind in [ck_subres]);
      needstempini:= b1 and 
                      (faf_varsubres in source^.d.dat.fact.flags); //has tempvar
      needsincref:= not isconst and not needstempini and 
                   not (b1 and (faf_create in source^.d.dat.fact.flags));
      needsdecref:= true;
      if needsincref and issametype(ele.eledataabs(d.dat.datatyp.typedata),
                                                         sourcetyp) then begin
       ad1.kind:= ark_contextdata;
       ad1.contextdata:= @source^.d;
       ad1.offset:= 0;
       if source^.d.kind = ck_ref then begin
        if source^.d.dat.indirection <> 0 then begin
         if not getvalue(source,das_none) then begin
          goto endlab;
         end;
         sourcessa1:= source^.d.dat.fact.ssaindex;
        end;
        writemanagedtypeop(mo_incref,destvar.typ,ad1);
        needsincref:= false;
       end
       else begin
        if (source^.d.kind in factcontexts) and 
                            (source^.d.dat.indirection = -1) then begin
                                   //address on stack
         if datasi1 = das_pointer then begin
          ad1.offset:= -targetpointersize;
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
      if source^.d.kind in factcontexts then begin
       source^.d.dat.fact.ssaindex:= sourcessa1; 
                     //restore, could be changed by manage ops
      end;
     end;
     if not getvalue(source,datasi1) then begin //todo: conversion operator
                                                //without loading of the object
      goto endlab;
     end;
     if faf_classele in source^.d.dat.fact.flags then begin
      errormessage(err_cannotaccessinclassmethod,[],source);
     end;
    end
    else begin
     goto endlab;
    end;
   end;
   
   if typematch and not errorfla then begin
                         //todo: use destinationaddress directly
    typematch:= isconst or tryconvert(source,destvar.typ,indilev1,[]); 
                            //todo: tryconvert already called for objects?
    if not typematch then begin
     assignmenterror(source^.d,destvar);
    end
    else begin
     ssa1:= source^.d.dat.fact.ssaindex; //source

     if needsmanage then begin
     {
      ad1.kind:= ark_stack;
      if datasi1 = das_pointer then begin
       ad1.address:= -pointersize;
      end
      else begin
       ad1.address:= -destvar.typ^.h.bytesize;
      end;
      ad1.offset:= 0;
      ad1.ssaindex:= ssa1;
//      ad1.typ:= destvar.typ; //done in writemanagedtypeop
      }
      ad1.kind:= ark_contextdata;
      ad1.contextdata:= @source^.d;
      ad1.offset:= 0;
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
     po1^.par.ssas1:= ssa1;                       //source
     if indi then begin
      po1^.par.ssas2:= dest^.d.dat.fact.ssaindex; //dest
     end;
     if needsmanage and needstempini then begin
      ad1.kind:= ark_tempvar;
      ad1.typ:= sourcetyp;
      ad1.tempaddress:= lasttempvar;
      writemanagedtypeop(mo_ini,sourcetyp,ad1);
     end;
    end;
   end;
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
  initblockcontext(0,ck_block);
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
     if po1^.h.kind = dk_class then begin //implicit dereference
      dec(d.dat.datatyp.indirectlevel);
      dec(d.dat.indirection);
     end;
     if (d.dat.datatyp.indirectlevel = 1) and 
                  (po1^.h.kind in [dk_record,dk_object,dk_class]) then begin
      if d.kind = ck_ref then begin
       dec(d.dat.datatyp.indirectlevel);
       dec(d.dat.indirection);
       if not getaddress(ptop,true) then begin
        goto errlab;
       end;
      end;
      with pvardataty(ele.addscope(ek_var,basetype(po1)))^ do begin
       address:= getpointertempaddress();
       if po1^.h.kind <> dk_class then begin
        include(address.flags,af_withindirect);
       end;
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
  s.stacktop:= s.stackindex;
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
  linkresolve(s.currentopcodemarkchain); //delete chain
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
      setimmsize(getbytesize(dat.fact.opdatatype),par.imm); //todo: alignment
//      setimmsize((dat.fact.databitsize+7) div 8,par); //todo: alignment
     end;    
    end;
    ck_space,ck_subcall,ck_controltoken: begin
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