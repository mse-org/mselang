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
unit controlhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

procedure handleif0();
//procedure handleif();
procedure handlethen();
procedure handlethen0();
//procedure handlethen1();
procedure handlethen2();
procedure handleelse0();
procedure handleelse();

procedure handlewhilestart();
procedure handlewhileexpression();
procedure handlewhileend();

procedure handlerepeatstart();
procedure handleuntilexpected();
procedure handleuntilentry();
procedure handlerepeatend();

procedure handleforvar();
procedure handleassignmentexpected();
procedure handleforstart();
procedure handletoexpected();
procedure handledownto();
procedure handleforheader();
procedure handleforend();

procedure handlecasestart();
procedure handlecaseexpression();
procedure handleofexpected();
procedure handlecheckcaselabel();
procedure handleexceptlabel();
procedure handleexceptlabel1();
procedure handlecasebranch1entry();
procedure handlecasebranchentry();
procedure handlecasebranch();
procedure handlecasebranch2entry();
procedure handlecase();
procedure handlecasestatementgroupstart();
//procedure handlecasestatementgroup();

procedure handlelabeldef();
procedure handlelabel();
procedure handlegoto();

function checkloopcommand(): boolean; //true if ok

implementation
uses
 globtypes,handlerutils,parserglob,errorhandler,handlerglob,elements,
 opcode,stackops,segmentutils,opglob,unithandler,handler,grammarglob,
 gramse,parser,listutils,classhandler,__mla__internaltypes,llvmlists,
 valuehandler;
 
function conditionalcontrolop(const aopcode: opcodety): popinfoty;
begin
 with info do begin
  getvalue(@contextstack[s.stacktop],das_none);
  with contextstack[s.stacktop] do begin
   if (d.dat.datatyp.indirectlevel <> 0) or (ptypedataty(ele.eledataabs(
                      d.dat.datatyp.typedata))^.h.kind <> dk_boolean) then begin
    errormessage(err_booleanexpressionexpected,[],s.stacktop-s.stackindex);
    result:= nil;
   end;
   result:= additem(aopcode);
   with result^ do begin
    par.ssas1:= d.dat.fact.ssaindex;
   end;
  end;
 end;
end;

procedure handleif0();
begin
{$ifdef mse_debugparser}
 outhandle('IF0');
{$endif}
 with info do begin
  include(s.currentstatementflags,stf_rightside);
 end;
end;
(*
procedure handleif();          //not used???? todo: remove it
begin
{$ifdef mse_debugparser}
 outhandle('IF');
{$endif}
 with info do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;
*)
procedure handlethen();
begin
{$ifdef mse_debugparser}
 outhandle('THEN');
{$endif}
 tokenexpectederror(tk_then);
 with info do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlethen0();
begin
{$ifdef mse_debugparser}
 outhandle('THEN0');
{$endif}
 with info do begin
  conditionalcontrolop(oc_if);
//  s.stacktop:= s.stackindex;
 end;
end;
(*
procedure handlethen1();
begin
{$ifdef mse_debugparser}
 outhandle('THEN1');
{$endif}
 with info do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;
*)
procedure handlethen2();
      //-1      stacktop
begin //boolexp,thenmark
{$ifdef mse_debugparser}
 outhandle('THEN2');
{$endif}
 with info do begin
  addlabel();
  setcurrentlocbefore(s.stacktop-s.stackindex); //set gotoaddress
 // addlabel();
  with info do begin
   dec(s.stackindex);
   s.stacktop:= s.stackindex;
  end;
 end;
end;

procedure handleelse0();
begin
{$ifdef mse_debugparser}
 outhandle('ELSE0');
{$endif}
 with additem(oc_goto)^ do begin  
 end;
end;

procedure handleelse();
      //1       2        3
var
 i1: int32;
begin //boolexp,thenmark,elsemark
{$ifdef mse_debugparser}
 outhandle('ELSE');
{$endif}
 with info do begin
 // addlabel();
 {$ifdef mse_checkinternalerror}
  if s.stacktop-s.stackindex - getspacecount(s.stackindex+1) < 3 then begin
   internalerror(ie_parser,'20150918B');
  end;
 {$endif}
//  setlocbefore(2,3);      //set gotoaddress for handlethen0
//  setcurrentlocbefore(3); //set gotoaddress for handleelse0
  i1:= s.stacktop-s.stackindex;
  setlocbefore(i1-1,i1);      //set gotoaddress for handlethen0
  setcurrentlocbefore(i1); //set gotoaddress for handleelse0
  addlabel();
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure startlabel(const akind: controlkindty = cok_none);
begin
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_control;
  d.control.opmark1.address:= opcount; //label address
  d.control.kind:= akind;
  d.control.linkscontinue:= 0;
  d.control.linksbreak:= 0;
 end;
 addlabel();
end;

procedure beginloop();
begin
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_control then begin
   internalerror(ie_handler,'20150511A');
  end;
 {$endif}
  b.flags:= s.currentstatementflags;
  include(s.currentstatementflags,stf_loop);
 end;
end;

procedure endloop();
begin
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_control then begin
   internalerror(ie_handler,'20150511A');
  end;
 {$endif}
  s.currentstatementflags:= b.flags;
 end;
end;

function checkloopcommand(): boolean; //true if ok
var
 i1: int32;
 ident1: identty;
begin
 result:= false;
 with info do begin
  with contextstack[s.stackindex+1] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_ident then begin
    internalerror(ie_handler,'20150511B');
   end;
  {$endif}
   if not (idf_continued in d.ident.flags) then begin 
                                 //todo: check 'system.' prefix
    ident1:= d.ident.ident;
    if (ident1 = tk_break) or (ident1 = tk_continue) then begin
     for i1:= s.stackindex downto 0 do begin
      with contextstack[i1] do begin
       if (d.kind = ck_control) and (d.control.kind in loopcontrols) then begin
        with additem(oc_goto)^ do begin
         if ident1 = tk_continue then begin
          linkmark(d.control.linkscontinue,
                       getsegaddress(seg_op,@par.opaddress.opaddress));
//          par.opaddress.opaddress:= d.control.opmark1.address-1; //label
         end
         else begin
          linkmark(d.control.linksbreak,
                       getsegaddress(seg_op,@par.opaddress.opaddress));
         end;
        end;
        contextstack[s.stackindex].d.kind:= ck_controltoken;
        result:= true;
        exit;
       end;
      end;
     end;
     internalerror1(ie_handler,'20150511C');
    end;
   end;
  end;
 end;
end;

procedure handlewhilestart();   //todo: check abort at end -> single jump
begin
{$ifdef mse_debugparser}
 outhandle('WHILESTART');
{$endif}
 startlabel(cok_loop);
end;

procedure handlewhileexpression();
begin
{$ifdef mse_debugparser}
 outhandle('WHILEEXPRESSION');
{$endif}
 beginloop();
 conditionalcontrolop(oc_while);
end;

procedure handlewhileend();
begin
{$ifdef mse_debugparser}
 outhandle('WHILEEND');
{$endif}
 with info,contextstack[s.stackindex] do begin
  with additem(oc_goto)^ do begin
   par.opaddress.opaddress:= d.control.opmark1.address-1; //label
  end;
  setcurrentlocbefore(s.stacktop-s.stackindex); //dest for oc_while
//  setcurrentlocbefore(2); //dest for oc_while
  endloop();
  addlabel();
  linkresolveopad(d.control.linkscontinue,d.control.opmark1.address);
  linkresolveopad(d.control.linksbreak,opcount-1);
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlerepeatstart();
begin
{$ifdef mse_debugparser}
 outhandle('REPEATSTART');
{$endif}
 startlabel(cok_loop);
 beginloop();
end;

procedure handleuntilexpected();
begin
{$ifdef mse_debugparser}
 outhandle('UNTILEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('tk_until');
  dec(s.stackindex);
 end;
end;

procedure handleuntilentry();
begin
{$ifdef mse_debugparser}
 outhandle('UNTILENTRY');
{$endif}
 endloop();
end;

procedure handlerepeatend();
var
 po1: popinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('REPEATEND');
{$endif}
 with info,contextstack[s.stackindex] do begin
  po1:= conditionalcontrolop(oc_until);
  if po1 <> nil then begin
   po1^.par.opaddress.opaddress:= d.control.opmark1.address-1; //label
  end;
  addlabel();
  linkresolveopad(d.control.linkscontinue,d.control.opmark1.address);
  linkresolveopad(d.control.linksbreak,opcount-1);
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleforvar();

 procedure err(const aerror: errorty);
 begin
  errormessage(aerror,[],1);
  sethandlererror();
 end; //err

var
 po1: ptypedataty;
 ptop: pcontextitemty; 
begin
{$ifdef mse_debugparser}
 outhandle('FORVAR');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_control;
  d.control.kind:= cok_for;
  ptop:= @contextstack[s.stacktop];
  if getassignaddress(ptop,true) then begin
   d.control.forinfo.varad:= getpointertempaddress();
   with ptop^.d.dat do begin
    po1:= ele.eledataabs(datatyp.typedata);
    if (datatyp.indirectlevel <> 1) or 
        not (po1^.h.kind in ordinaldatakinds) then begin
     err(err_ordinalexpexpected);
     exit;
    end;
    if (po1^.h.kind = dk_enum) and 
                 not (enf_contiguous in po1^.infoenum.flags) then begin
     err(err_enumnotcontiguous);
     exit;
    end;
   end;
   d.control.forinfo.alloc:= getopdatatype(po1,0);
  end
  else begin
   sethandlererror();
  end;
 end;
end;

procedure handleassignmentexpected();
begin
{$ifdef mse_debugparser}
 outhandle('ASSIGNMENTEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror(':=');
  dec(s.stackindex);
 end;
end;

procedure handleforstart();
begin
{$ifdef mse_debugparser}
 outhandle('FORSTART');
{$endif}
 with info do begin
  with info,contextstack[s.stackindex] do begin
   if getvalue(@contextstack[s.stacktop],
                                     d.control.forinfo.alloc.kind) then begin
    d.control.forinfo.start:= gettempaddress(d.control.forinfo.alloc.kind);
   end
   else begin
    sethandlererror();
   end;
  end;
 end;
end;

procedure handledownto();
begin
{$ifdef mse_debugparser}
 outhandle('DOWNTO');
{$endif}
 sethandlerflag(hf_down);
end;

procedure handletoexpected();
begin
{$ifdef mse_debugparser}
 outhandle('TOEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('to');
  dec(s.stackindex);
 end;
end;

procedure handleforheader();
var
 flags1: handlerflagsty;
 initcheckad: int32;
 po1: ptypedataty;
 cok1: compopkindty;
 op2: opcodety;
 po2: popinfoty;
 step: int32;
 i1,i2: int32;
 poa,pob,poc: pcontextitemty;
 typ1: ptypedataty;
 indilev1: int32;
 
begin
{$ifdef mse_debugparser}
 outhandle('FORHEADER');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (s.stacktop - s.stackindex - getspacecount(s.stackindex+1) <> 3) then begin
   internalerror(ie_handler,'20160604');
  end;
 {$endif}
  poc:= @contextstack[s.stacktop];
  pob:= getpreviousnospace(poc-1);
  poa:= getpreviousnospace(pob-1);
 {$ifdef mse_checkinternalerror}
  if not (poa^.d.kind in datacontexts) or not (pob^.d.kind in datacontexts) or
          not (poc^.d.kind in datacontexts) then begin
   internalerror(ie_handler,'20180615A');
  end;
 {$endif}
  flags1:= contextstack[s.stackindex].d.handlerflags;
  if not (hf_error in flags1) then begin
   with info,contextstack[s.stackindex],d.control.forinfo do begin
    typ1:= ele.eledataabs(poa^.d.dat.datatyp.typedata);
    indilev1:= poa^.d.dat.datatyp.indirectlevel-1;
    if tryconvert(pob,typ1,indilev1,[coo_errormessage]) and
       tryconvert(poc,typ1,indilev1,[coo_errormessage]) and
       getvalue(pob,das_none) and getvalue(poc,das_none) then begin
     start.tempaddress.ssaindex:= pob^.d.dat.fact.ssaindex;
     stop:= gettempaddress(alloc.kind);
     stop.tempaddress.ssaindex:= poc^.d.dat.fact.ssaindex;
     if not (co_llvm in info.o.compileoptions) then begin
      pushtemp(start,alloc);
      pushtemp(stop,alloc);
     end;
     if hf_down in flags1 then begin        //todo: different types
      cok1:= cok_ge;
      step:= -1;
     end
     else begin
      cok1:= cok_le;
      step:= 1;
     end;
     with additem(oc_cmpint)^.par do begin
      ssas1:= start.tempaddress.ssaindex;
      ssas2:= stop.tempaddress.ssaindex;
      i1:= ssad;
      stackop.compkind:= cok1;
      stackop.t:= alloc;
     end;
     checkopcapacity(10);
     po2:= additem(oc_if); //jump to loop end
     po2^.par.ssas1:= i1;

     i1:= pushtemppo(varad);
     i2:= pushtemp(start,alloc);
     with additem(popindioptable[alloc.kind])^ do begin
      par.memop.t:= alloc;
      par.ssas1:= i2; //source
      par.ssas2:= i1; //dest
     end;
     i1:= pushtemppo(varad);
     with additem(oc_incdecindiimmint)^ do begin
      par.memimm.mem.t:= alloc;
//       par.memimm.mem.t.flags:= varad.flags;
//       par.memimm.mem.tempaddress:= varad.tempaddress;
      setmemimm(-step,par);
      par.ssas1:= i1;
     end;
     startlabel(cok_for);
     linkmark(d.control.linksbreak,
                      getsegaddress(seg_op,@po2^.par.opaddress.opaddress));
     i1:= pushtemppo(varad);
     with additem(oc_incdecindiimmint)^ do begin
      par.memimm.mem.t:= alloc;
//       par.memimm.mem.t.flags:= varad.flags;
//       par.memimm.mem.tempaddress:= varad.tempaddress;
      setmemimm(step,par);
      par.ssas1:= i1;
     end;
     beginloop();
    end
    else begin
     sethandlererror();
    end;
   end;
  end;
 end;
end;

procedure handleforend();
var
 cok1: compopkindty;
 flags1: handlerflagsty;
 po1: popinfoty;
 i1,i2: int32;
begin
{$ifdef mse_debugparser}
 outhandle('FOREND');
{$endif}
 with info do begin
  with info,contextstack[s.stackindex] do begin
   flags1:= d.handlerflags;
   if not (hf_error in d.handlerflags) then begin
    if hf_down in flags1 then begin        //todo: different types
     cok1:= cok_le;
    end
    else begin
     cok1:= cok_ge;
    end;
    addlabel();
    with d.control do begin
     linkresolveopad(linkscontinue,opcount-1);
     i1:= pushtempindi(forinfo.varad,forinfo.alloc);
     i2:= pushtemp(forinfo.stop,forinfo.alloc);
     with additem(oc_cmpint)^.par do begin
      ssas1:= i1;
      ssas2:= i2;
      i1:= ssad;
      stackop.compkind:= cok1;
      stackop.t:= forinfo.alloc;
     end;    
     with additem(oc_if)^ do begin //jump to loop start
      par.opaddress.opaddress:= d.control.opmark1.address;
      par.ssas1:= i1;
     end;
     addlabel();
     linkresolveopad(linksbreak,opcount-1);
     releasetempaddress([das_pointer,forinfo.alloc.kind,forinfo.alloc.kind]);
    end;      
    endloop();
   end;
  end;
 end;
 with info do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlecasestart();
begin
{$ifdef mse_debugparser}
 outhandle('CASESTART');
{$endif}
end;

procedure handlecaseexpression();
var
 poa: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('CASEEXPRESSION');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if s.stacktop - s.stackindex - 
                      getspacecount(s.stackindex + 1) <> 1 then begin
   internalerror(ie_handler,'20160604B');
  end;
 {$endif}
  poa:= @contextstack[s.stacktop];
  with poa^ do begin
   if getvalue(poa,das_none) and (d.dat.datatyp.indirectlevel = 0) and 
          (ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.kind in 
                                                  rangedatakinds) then begin
   end
   else begin
    errormessage(err_ordinalexpexpected,[]);
   end;
  end;
 end;
end;

procedure handleofexpected();
begin
{$ifdef mse_debugparser}
 outhandle('OFEXPECTED');
{$endif}
 tokenexpectederror(tk_of);
end;

procedure handlecasebranch1entry();
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCH1ENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_casebranch;
  opmark.address:= opcount;
 end;
end;

procedure handlecasebranchentry();
var
 int1: integer;
 {itemcount,}last: integer;
 po1: popinfoty;
 poexp,polast,poitem: pcontextitemty;
 expssa: int32;
 si1: databitsizety;
 b1: boolean;
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCHENTRY');
{$endif}
 with info do begin
  poexp:= @contextstack[s.stacktop]; //@contextstack[pitem^.parent];
  poexp:= @contextstack[poexp^.parent];
  poexp:= getnextnospace(poexp+1);
  polast:= @contextstack[s.stackindex-1];
  poitem:= @contextstack[polast^.parent];
  poitem:= getnextnospace(poitem+1);
//  last:= s.stackindex-1;
//  itemcount:= s.stackindex - contextstack[last].parent - 1;
 {$ifdef mse_checkinternalerror}
  if not (poexp^.d.kind in factcontexts) then begin
   internalerror(ie_parser,'20150909A');
  end;
 {$endif}
  expssa:= poexp^.d.dat.fact.ssaindex;
  last:= getitemcount(poitem)-2;
  
  for int1:= 0 to last do begin
   with poitem^ do begin
//todo: check correct datatype
    b1:= (d.kind = ck_const) and (d.dat.datatyp.indirectlevel = 0);
    if b1 then begin
     b1:= d.dat.constval.kind in rangedatakinds;
     if not b1 and (d.dat.constval.kind in stringdatakinds) then begin
      b1:= tryconvert(poitem,st_char32,[]);
     end;
    end;
    if b1 then begin
     si1:= ptypedataty(ele.eledataabs(
                              poexp^.d.dat.datatyp.typedata))^.h.datasize;
            //todo: signed/unsigned, use table
     if tf_lower in d.dat.datatyp.flags then begin
      po1:= additem(oc_cmpjmploimm);
      if int1 <> last-1 then begin
       po1^.par.cmpjmpimm.destad.opaddress:= opcount; //next check
      end;
     end
     else begin
      if tf_upper in d.dat.datatyp.flags then begin
       if int1 = last then begin
        po1:= additem(oc_cmpjmpgtimm);
       end
       else begin
        po1:= additem(oc_cmpjmploeqimm);
        po1^.par.cmpjmpimm.destad.opaddress:= opcount+last-int1-1;
       end;
      end
      else begin
       if int1 = last then begin
        po1:= additem(oc_cmpjmpneimm);
       end
       else begin
        po1:= additem(oc_cmpjmpeqimm);
        po1^.par.cmpjmpimm.destad.opaddress:= opcount+last-int1-1;
       end;
      end;
     end;
     opmark.address:= opcount-1;
     po1^.par.cmpjmpimm.imm.datasize:= si1;
     if co_llvm in info.o.compileoptions then begin
//      po1^.par.ssas1:= 
             //todo: cardinal
      with po1^.par do begin
       case si1 of
        das_1: begin
         cmpjmpimm.imm.llvm:= s.unitinfo^.llvmlists.constlist.addi1(
                                                      d.dat.constval.vboolean);
        end;
        das_8: begin
         cmpjmpimm.imm.llvm:= s.unitinfo^.llvmlists.constlist.addi8(
                                                      d.dat.constval.vinteger);
        end;
        das_16: begin
         cmpjmpimm.imm.llvm:= s.unitinfo^.llvmlists.constlist.addi16(
                                                      d.dat.constval.vinteger);
        end;
        das_32: begin
         cmpjmpimm.imm.llvm:= s.unitinfo^.llvmlists.constlist.addi32(
                                                      d.dat.constval.vinteger);
        end;
        das_64: begin
         cmpjmpimm.imm.llvm:= s.unitinfo^.llvmlists.constlist.addi64(
                                                      d.dat.constval.vinteger);
        end;
        else begin
         internalerror1(ie_handler,'20170611A');
        end;
       end;
       ssas1:= expssa;
      end;
     end
     else begin
      case si1 of
       das_1: begin
        po1^.par.cmpjmpimm.imm.vboolean:= d.dat.constval.vboolean;
       end;
       das_8: begin
        po1^.par.cmpjmpimm.imm.vint8:= d.dat.constval.vinteger;
       end;
       das_16: begin
        po1^.par.cmpjmpimm.imm.vint16:= d.dat.constval.vinteger;
       end;
       das_32: begin
        po1^.par.cmpjmpimm.imm.vint32:= d.dat.constval.vinteger;
       end;
       das_64: begin
        po1^.par.cmpjmpimm.imm.vint64:= d.dat.constval.vinteger;
       end;
      end;
     end;
    end
    else begin
     errormessage(err_ordinalconstexpected,[],-1);
    end;
   end;
   poitem:= getnextnospace(poitem+1);
  end;
 end;
end;

procedure handlecasebranch();
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCH');
{$endif}
 with additem(oc_goto)^ do begin
    //goto casend
 end;
end;

procedure handlecasebranch2entry();
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCH2ENTRY');
{$endif}
 handlecasebranch();
 with info do begin
  s.stacktop:= s.stackindex;
 end; 
end;

procedure handlecasestatementgroupstart();
begin
{$ifdef mse_debugparser}
 outhandle('CASESTATEMENTGROUPSTART');
{$endif}
 with info do begin
  contextstack[s.stackindex].d.kind:= ck_caseblock;
 end;
end;
(*
procedure handlecasestatementgroup();
begin
{$ifdef mse_debugparser}
 outhandle('CASESTATEMENTGROUP');
{$endif}
 with info do begin
  dec(s.stackindex);
 end;
end;
*)
procedure handlecheckcaselabel();
var
 p1: pcontextitemty;
 typ1: ptypedataty;
 b1: boolean;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKCASELABEL');
{$endif}
 with info do begin
  if (contextstack[s.stacktop].d.kind <> ck_label) then begin
   if contextstack[s.stackindex-2].d.kind = ck_caseblock then begin
    s.stackindex:= s.stackindex - 3; //casebranch2
    p1:= @contextstack[s.stackindex+2]; //statementstart
    cutopend(p1^.opmark.address);
    with contextstack[s.stackindex] do begin
     start:= p1^.start; //restart case label
     s.source:= start;
     debugstart:= p1^.debugstart;
    end;
   end
   else begin
    if (s.dialect = dia_mse) and 
            (contextstack[s.stackindex-3].d.kind = ck_exceptblock) then begin
     if not (caf_else in contextstack[s.stackindex-3].
                                              d.block.caseflags) then begin
      
      b1:= false;
      with contextstack[s.stacktop] do begin
       if d.kind = ck_typearg then begin
        typ1:= ele.eledataabs(d.typ.typedata);
        if (typ1^.h.kind = dk_class) and 
                          (icf_except in typ1^.infoclass.flags) then begin
         b1:= true;
        end;
       end;
       contextstack[s.stackindex].d.statement.excepttype:= d.typ.typedata;
      end;
      if not b1 then begin
       errormessage(err_exceptclassexpected,[]);
      end;
      switchcontext(@gramse.exceptlabelco,true);
      s.stacktop:= s.stackindex;
     end
     else begin
      errormessage(err_exceptlabelafterelse,[]);
     end;
    end;
   end;
  end;
 end;
end;

procedure exceptlabel(const last: boolean);
var
 i1,i2: int32;
 typ1: ptypedataty;
begin
 with info do begin
//  dec(s.trystacklevel); //no LLVM invoke
  with contextstack[contextstack[contextstack[s.stackindex].parent].
                                                          parent] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_exceptblock then begin
    internalerror(ie_handler,'20170725B');
   end;
  {$endif}
   if (caf_first in d.block.caseflags) and (d.block.casechain <> 0) then begin
    additem(oc_goto);                       //op -1
     //jump to except end, address set later     
   end;
   with pclasspendingitemty(addlistitem(pendingclassitems,
                                           d.block.casechain))^ do begin
    exceptcase.startop:= opcount;
    exceptcase.first:= caf_first in d.block.caseflags;
    exceptcase.last:= last;
    exceptcase.elsefla:= false;
   end;
   addlabel();                                     //op 0
   with additem(oc_pushexception)^.par do begin    //op 1
    landingpad:= d.block.landingpad;
    i1:= ssad;
   end;
   with additem(oc_getclassdef)^.par do begin      //op 2
    ssas1:= i1;
    setimmint32(0,imm);
    i1:= ssad;
   end;                                            //op 3
   typ1:= ele.eledataabs(contextstack[s.stackindex].d.statement.excepttype);
   with additem(oc_pushclassdef)^.par do begin
    if co_llvm in info.o.compileoptions then begin
     classdefid:= getclassdefid(typ1);
    end
    else begin
     classdefstackops:= typ1^.infoclass.defs.address;
    end;
    i2:= ssad;
   end;
{
   with additem(oc_pushsegaddr,pushsegaddrssaar[seg_classdef])^.par do begin
    memop.segdataaddress.a:= ptypedataty(ele.eledataabs(
          contextstack[s.stackindex].d.statement.excepttype))^.infoclass.defs;
    memop.segdataaddress.offset:= 0;
    memop.t:= bitoptypes[das_pointer];
    i2:= ssad;
   end;
}
   with additem(oc_classis)^.par do begin          //op 4
    ssas1:= i1;
    ssas2:= i2;
    i1:= ssad;
   end;
   with additem(oc_gotofalse)^.par do begin //op 5
    ssas1:= i1;
                      //jump to next case label, address set in handleexcept
   end;
   if last then begin
    addlabel();                                    //op 6
   end
   else begin
    additem(oc_goto);                      //op 6
                      //jump to except code, address set in handleexcept
   end;
   if last then begin
    include(d.block.caseflags,caf_first);
   end
   else begin
    exclude(d.block.caseflags,caf_first);
   end;
  end;
//  inc(s.trystacklevel); //restore
 end;
end;

procedure handleexceptlabel();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPTLABEL');
{$endif}
 exceptlabel(true);
 with info do begin
  dec(s.stackindex,2);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleexceptlabel1();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPTLABEL1');
{$endif}
 exceptlabel(false);
end;

procedure handlecase(); //todo: use jumptable and the like
                        //todo: check overlap and range direction
var
 int1: integer;
 endad: opaddressty;
 po1: popinfoty;
 isrange: boolean;
begin
{$ifdef mse_debugparser}
 outhandle('CASE');
{$endif}
 with info do begin
  if errors[erl_error] = 0 then begin
   endad:= opcount - 1;
   int1:= getnextnospace(s.stackindex+1) + 3;
   while int1 <= s.stacktop do begin
    while contextstack[int1].d.kind <> ck_casebranch do begin
     inc(int1);
    end;
    with contextstack[int1-1] do begin
     po1:= getoppo(opmark.address); //last compare
     isrange:= tf_upper in d.dat.datatyp.flags;
    end;
   {$ifdef mse_checkinternalerror}
    if not checkop(po1^.op,oc_cmpjmpneimm) and 
                         not checkop(po1^.op,oc_cmpjmpgtimm) then begin
     internalerror(ie_handler,'20140530A');
    end;
   {$endif}
    with contextstack[int1] do begin
     po1^.par.cmpjmpimm.destad.opaddress:= opoffset(opmark.address,-1);
     if isrange then begin
     {$ifdef mse_checkinternalerror}
      if not checkop((po1-1)^.op,oc_cmpjmploimm) then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      (po1-1)^.par.cmpjmpimm.destad.opaddress:= opoffset(opmark.address,-1);
                                                     //tf_lower
     end;
     with getoppo(opmark.address,-1)^ do begin
     {$ifdef mse_checkinternalerror}
      if not checkop(op,oc_goto) then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      par.opaddress.opaddress:= endad;
     end;
    end;
    inc(int1,3);
   end;
   if int1 - s.stacktop = 3 then begin
    with getoppo(opcount,-1)^ do begin
    {$ifdef mse_checkinternalerror}
     if not checkop(op,oc_goto) then begin
      internalerror(ie_handler,'20140530B');
     end;
    {$endif}
     op.op:= oc_label;
//     op.op:= oc_nop;
//     setop(op,oc_nop);
    end;
   end;
   addlabel();
   with additem(oc_pop)^ do begin
    setimmsize(sizeof(int32),par.imm);
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlelabeldef();
var
 i1,i2: int32;
 po1: plabeldefdataty;
begin
{$ifdef mse_debugparser}
 outhandle('LABELDEF');
{$endif}
 with info do begin
  i2:= s.stackindex + 2;
 {$ifdef mse_checkinternalerror}
  if i2 > s.stacktop then begin
   internalerror(ie_handler,'20150917A');
  end;
 {$endif}
  for i1:= i2 to s.stacktop do begin
   with contextstack[i1] do begin
   {$ifdef mse_checkinternalerror}
    if d.kind <> ck_ident then begin
     internalerror(ie_handler,'20150917B');
    end;
   {$endif}
    if not ele.addelementdata(
                 d.ident.ident,ek_labeldef,[vik_sameunit],po1) then begin
     identerror(i1-s.stackindex,err_duplicateidentifier);
    end
    else begin
     with po1^ do begin //init
      adlinks:= 0;
//      blockid:= 0; //with and try blocks 
      address:= 0; //blockid invalid
      mark:= 0;
     end;
    end;
   end;
  end;
 end;
end;

procedure handlelabel();
var
 po1: plabeldefdataty;
 potop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('LABEL');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (s.stacktop-s.stackindex-getspacecount(s.stackindex) <> 1) or
                                                (s.stackindex < 2) then begin
   internalerror(ie_handler,'20150916D');
  end;
 {$endif}
  potop:= @contextstack[s.stacktop];
  with potop^ do begin
   if d.kind <> ck_label then begin
    if contextstack[contextstack[s.stackindex].parent].d.kind = 
                                                 ck_caseblock then begin
    end
    else begin
     if contextstack[s.stackindex-3].d.kind = ck_exceptblock then begin
     end
     else begin
      handlesemicolonexpected();
     end;
    end;
   end
   else begin
    po1:= ele.eledataabs(d.dat.lab);
    if po1^.address <> 0 then begin
     errormessage(err_labelalreadydef,[],1);
    end
    else begin
     po1^.address:= opcount;
     po1^.blockid:= currentblockid;
     linkresolvegoto(po1^.adlinks,opcount{-1},currentblockid);
                 //todo: check blockid
     forwardresolve(po1^.mark);
    end;
    addlabel();
   end;
  end;
  dec(s.stackindex,2);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlegoto();
var
 po1: plabeldefdataty;
begin
{$ifdef mse_debugparser}
 outhandle('GOTO');
{$endif}
 with info,contextstack[s.stacktop] do begin
 {$ifdef mse_checkinternalerror}
  if (s.stacktop-s.stackindex <> 1) or 
          (d.kind <> ck_ident) then begin
   internalerror(ie_handler,'20150918A');
  end;
 {$endif}
  if ele.findcurrent(d.ident.ident,
                         [ek_labeldef],allvisi,po1) <> ek_labeldef then begin
   identerror(1,err_labelnotfound);
  end
  else begin
   with additem(oc_goto)^ do begin
    if po1^.address <> 0 then begin
     par.opaddress.opaddress:= po1^.address-1;
     par.opaddress.blockid:= currentblockid;
     if currentblockid <> po1^.blockid then begin
      errormessage(err_invalidgototarget,[]);
     end;
    end
    else begin
     if po1^.mark = 0 then begin
      forwardmark(po1^.mark,s.source,d.ident.ident); 
                               //todo: use label specific list
     end;
     linkmark(po1^.adlinks,getsegaddress(seg_op,@par.opaddress));
    end;
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

end.
