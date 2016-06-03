{ MSElang Copyright (c) 2013-2015 by Martin Schreiber
   
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
procedure handlecasebranchentry();
procedure handlecasebranch();
procedure handlecase();

procedure handlelabeldef();
procedure handlelabel();
procedure handlegoto();

function checkloopcommand(): boolean; //true if ok

implementation
uses
 globtypes,handlerutils,parserglob,errorhandler,grammar,handlerglob,elements,
 opcode,stackops,segmentutils,opglob,unithandler,handler;
 
function conditionalcontrolop(const aopcode: opcodety): popinfoty;
begin
 with info do begin
  getvalue(s.stacktop-s.stackindex,das_none);
  with contextstack[s.stacktop] do begin
   if (d.dat.datatyp.indirectlevel <> 0) or (ptypedataty(ele.eledataabs(
                      d.dat.datatyp.typedata))^.h.kind <> dk_boolean) then begin
    errormessage(err_booleanexpressionexpected,[],s.stacktop-s.stackindex);
    result:= nil;
   end;
   result:= addcontrolitem(aopcode);
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
 conditionalcontrolop(oc_if);
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
 with addcontrolitem(oc_goto)^ do begin  
 end;
end;

procedure handleelse();
      //1       2        3
begin //boolexp,thenmark,elsemark
{$ifdef mse_debugparser}
 outhandle('ELSE');
{$endif}
 with info do begin
 // addlabel();
 {$ifdef mse_checkinternalerror}
  if s.stacktop-s.stackindex < 3 then begin
   internalerror(ie_parser,'20150918B');
  end;
 {$endif}
  setlocbefore(2,3);      //set gotoaddress for handlethen0
  setcurrentlocbefore(3); //set gotoaddress for handleelse0
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
        with addcontrolitem(oc_goto)^ do begin
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
  with addcontrolitem(oc_goto)^ do begin
   par.opaddress.opaddress:= d.control.opmark1.address-1; //label
  end;
  setcurrentlocbefore(2); //dest for oc_while
  endloop();
  addlabel();
  linkresolveopad(d.control.linkscontinue,d.control.opmark1.address);
  linkresolveopad(d.control.linksbreak,opcount-1);
  dec(s.stackindex);
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
 end;
end;

procedure handleforvar();
var
 po1: ptypedataty;
 
 procedure err(const aerror: errorty);
 begin
  errormessage(aerror,[],1);
  sethandlererror();
 end; //err
 
begin
{$ifdef mse_debugparser}
 outhandle('FORVAR');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_control;
  d.control.kind:= cok_for;
  if getassignaddress(1,true) then begin
   d.control.forinfo.varad:= getpointertempaddress();
   with contextstack[s.stackindex+1].d.dat do begin
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
   if getvalue(2,d.control.forinfo.alloc.kind) then begin
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
 op1,op2: opcodety;
 po2: popinfoty;
 step: int32;
 i1,i2: int32;
begin
{$ifdef mse_debugparser}
 outhandle('FORHEADER');
{$endif}
 with info do begin
  if (s.stacktop-s.stackindex = 3) then begin
   flags1:= contextstack[s.stackindex].d.handlerflags;
   if not (hf_error in flags1) then begin
    with info,contextstack[s.stackindex],d.control.forinfo do begin
     if getvalue(3,alloc.kind) then begin
      stop:= gettempaddress(alloc.kind);
      pushtemp(start,alloc);
      pushtemp(stop,alloc);
      if hf_down in flags1 then begin        //todo: different types
       op1:= oc_cmpgeint32;
       step:= -1;
      end
      else begin
       op1:= oc_cmpleint32;
       step:= 1;
      end;
      with additem(op1)^.par do begin
       ssas1:= start.tempaddress.ssaindex;
       ssas2:= stop.tempaddress.ssaindex;
       i1:= ssad;
      end;
      checkopcapacity(10);
      po2:= addcontrolitem(oc_if); //jump to loop end
      po2^.par.ssas1:= i1;

      i1:= pushtemppo(varad);
      i2:= pushtemp(start,alloc);
      with additem(popindioptable[alloc.kind])^ do begin
       par.memop.t:= alloc;
       par.ssas1:= i2; //source
       par.ssas2:= i1; //dest
      end;
      i1:= pushtemppo(varad);
      with additem(oc_incdecindiimmint32)^ do begin
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
      with additem(oc_incdecindiimmint32)^ do begin
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
{
    with contextstack[s.stackindex+1].d.dat do begin
     po1:= ele.eledataabs(datatyp.typedata);
     if (datatyp.indirectlevel <> 1) or 
         not (po1^.h.kind in ordinaldatakinds) then begin
      errormessage(err_ordinalexpexpected,[],1);
      sethandlererror();
     end
     else begin
      if not getvalue(2,po1^.h.datasize) or 
                        not getvalue(3,po1^.h.datasize) then begin
       sethandlererror();
      end
      else begin
       pushinsertstackindi(1,false,-(pointersize+2*4)); //counter value
      end;
     end;
    end;
}
   end;
  end;
 end;
end;

procedure handleforend();
var
 op1: opcodety;
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
     op1:= oc_cmpleint32;
    end
    else begin
     op1:= oc_cmpgeint32;
    end;
    addlabel();
    with d.control do begin
     linkresolveopad(linkscontinue,opcount-1);
     i1:= pushtempindi(forinfo.varad,forinfo.alloc);
     i2:= pushtemp(forinfo.stop,forinfo.alloc);
     with additem(op1)^.par do begin
      ssas1:= i1;
      ssas2:= i2;
      i1:= ssad;
     end;    
     with addcontrolitem(oc_if)^ do begin //jump to loop start
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
 end;
end;

procedure handlecasestart();
begin
{$ifdef mse_debugparser}
 outhandle('CASESTART');
{$endif}
end;

procedure handlecaseexpression();
begin
{$ifdef mse_debugparser}
 outhandle('CASEEXPRESSION');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (s.stacktop-s.stackindex = 1) and getvalue(1,das_none,true) and 
                 (d.dat.datatyp.indirectlevel = 0) and 
         (ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.kind in 
                                                 ordinaldatakinds) then begin
   if d.kind = ck_const then begin //todo: optimize const case switch
    getvalue(1,das_none);
   end;
  end
  else begin
   errormessage(err_ordinalexpexpected,[]);
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

procedure handlecasebranchentry();
var
 int1: integer;
 itemcount,last: integer;
 po1: popinfoty;
 expssa: int32;
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCHENTRY');
{$endif}
 with info do begin
  last:= s.stackindex-1;
  itemcount:= s.stackindex - contextstack[last].parent - 1;
 {$ifdef mse_checkinternalerror}
  if contextstack[contextstack[s.stackindex].parent+1].d.kind <> 
                                                        ck_fact then begin
   internalerror(ie_parser,'20150909A');
  end;
 {$endif}
  expssa:= contextstack[
                 contextstack[s.stackindex].parent+1].d.dat.fact.ssaindex;
  
  for int1:= s.stackindex - itemcount to last do begin
   with contextstack[int1] do begin
    if (d.kind = ck_const) and (d.dat.datatyp.indirectlevel = 0) and
                          (d.dat.constval.kind in ordinaldatakinds) then begin
            //todo: signed/unsigned, use table
     if tf_lower in d.dat.datatyp.flags then begin
      po1:= addcontrolitem(oc_cmpjmploimm4);
      if int1 <> last-1 then begin
       po1^.par.cmpjmpimm.destad.opaddress:= opcount; //next check
      end;
     end
     else begin
      if tf_upper in d.dat.datatyp.flags then begin
       if int1 = last then begin
        po1:= addcontrolitem(oc_cmpjmpgtimm4);
       end
       else begin
        po1:= addcontrolitem(oc_cmpjmploeqimm4);
        po1^.par.cmpjmpimm.destad.opaddress:= opcount+last-int1-1;
       end;
      end
      else begin
       if int1 = last then begin
        po1:= addcontrolitem(oc_cmpjmpneimm4);
       end
       else begin
        po1:= addcontrolitem(oc_cmpjmpeqimm4);
        po1^.par.cmpjmpimm.destad.opaddress:= opcount+last-int1-1;
       end;
      end;
     end;
     opmark.address:= opcount-1;
     if co_llvm in info.compileoptions then begin
//      po1^.par.ssas1:= 
             //todo: cardinal
      with po1^.par do begin
       cmpjmpimm.imm.llvm:= s.unitinfo^.llvmlists.constlist.addi32(
                                                      d.dat.constval.vinteger);
       ssas1:= expssa;
      end;
     end
     else begin
      po1^.par.cmpjmpimm.imm.vint32:= d.dat.constval.vinteger;
     end;
    end
    else begin
     errormessage(err_ordinalconstexpected,[],-1);
    end;
   end;
  end;
 end;
end;

procedure handlecasebranch();
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCH');
{$endif}
 with addcontrolitem(oc_goto)^ do begin
    //goto casend
 end;
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
   int1:= s.stackindex + 5;
   while int1 <= s.stacktop do begin
    while contextstack[int1].d.kind = ck_const do begin
     inc(int1);
    end;
    with contextstack[int1-1] do begin
     po1:= getoppo(opmark.address); //last compare
     isrange:= tf_upper in d.dat.datatyp.flags;
    end;
   {$ifdef mse_checkinternalerror}
    if not checkop(po1^.op,oc_cmpjmpneimm4) and 
                         not checkop(po1^.op,oc_cmpjmpgtimm4) then begin
     internalerror(ie_handler,'20140530A');
    end;
   {$endif}
    with contextstack[int1] do begin
     po1^.par.cmpjmpimm.destad.opaddress:= opmark.address-1;
     if isrange then begin
     {$ifdef mse_checkinternalerror}
      if not checkop((po1-1)^.op,oc_cmpjmploimm4) then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      (po1-1)^.par.cmpjmpimm.destad.opaddress:= opmark.address-1; //tf_lower
     end;
     with getoppo(opmark.address-1)^ do begin
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
    with getoppo(opcount-1)^ do begin
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
    setimmsize(sizeof(int32),par);
   end;
  end;
  dec(s.stackindex);
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
begin
{$ifdef mse_debugparser}
 outhandle('LABEL');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (s.stacktop-s.stackindex <> 1) or (s.stackindex < 2) then begin
   internalerror(ie_handler,'20150916D');
  end;
 {$endif}
  with contextstack[s.stacktop] do begin
   if d.kind <> ck_label then begin
    handlesemicolonexpected();
   end
   else begin
    po1:= ele.eledataabs(contextstack[s.stacktop].d.dat.lab);
    if po1^.address <> 0 then begin
     errormessage(err_labelalreadydef,[],1);
    end
    else begin
     po1^.address:= opcount;
     po1^.blockid:= currentblockid;
     linkresolvegoto(po1^.adlinks,opcount-1,currentblockid);
                 //todo: check blockid
     forwardresolve(po1^.mark);
    end;
    addlabel();
   end;
  end;
  dec(s.stackindex,2);
 end;
end;

procedure handlegoto();
var
 po1: plabeldefdataty;
begin
{$ifdef mse_debugparser}
 outhandle('LABEL');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (s.stacktop-s.stackindex <> 1) or 
          (contextstack[s.stacktop].d.kind <> ck_ident) then begin
   internalerror(ie_handler,'20150918A');
  end;
 {$endif}
  if ele.findcurrent(contextstack[s.stacktop].d.ident.ident,
                         [ek_labeldef],allvisi,po1) <> ek_labeldef then begin
   identerror(1,err_labelnotfound);
  end
  else begin
   with addcontrolitem(oc_goto)^ do begin
    if po1^.address <> 0 then begin
     par.opaddress.opaddress:= po1^.address-1;
     par.opaddress.blockid:= currentblockid;
     if currentblockid <> po1^.blockid then begin
      errormessage(err_invalidgototarget,[]);
     end;
    end
    else begin
     if po1^.mark = 0 then begin
      forwardmark(po1^.mark,s.source); //todo: use label specific list
     end;
     linkmark(po1^.adlinks,getsegaddress(seg_op,@par.opaddress));
    end;
   end;
  end;
  dec(s.stackindex);
 end;
end;

end.
