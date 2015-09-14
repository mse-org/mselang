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
procedure handlecolonexpected();
procedure handlecasebranchentry();
procedure handlecasebranch();
procedure handlecase();

function checkloopcommand(): boolean; //true if ok

implementation
uses
 globtypes,handlerutils,parserglob,errorhandler,grammar,handlerglob,elements,
 opcode,stackops,segmentutils,opglob,unithandler;
 
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
      //1       2        
begin //boolexp,thenmark
{$ifdef mse_debugparser}
 outhandle('THEN2');
{$endif}
 addlabel();
 setcurrentlocbefore(2); //set gotoaddress
// addlabel();
 with info do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
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
// addlabel();
 setlocbefore(2,3);      //set gotoaddress for handlethen0
 setcurrentlocbefore(3); //set gotoaddress for handleelse0
 addlabel();
 with info do begin
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
  d.control.links:= 0;
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
          par.opaddress.opaddress:= d.control.opmark1.address-1; //label
         end
         else begin
          linkmark(d.control.links,
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
  linkresolveopad(d.control.links,opcount-1);
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
  linkresolveopad(d.control.links,opcount-1);
  dec(s.stackindex);
 end;
end;

procedure handleforvar();
var
 po1: ptypedataty;
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
     errormessage(err_ordinalexpexpected,[],1);
     sethandlererror();
     exit;
    end;
   end;
   d.control.forinfo.varsize:= po1^.h.datasize;
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
   if getvalue(2,d.control.forinfo.varsize) then begin
    d.control.forinfo.start:= gettempaddress(d.control.forinfo.varsize);
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
 
begin
{$ifdef mse_debugparser}
 outhandle('FORHEADER');
{$endif}
 with info do begin
  if (s.stacktop-s.stackindex = 3) then begin
   flags1:= contextstack[s.stackindex].handlerflags;
   if not (hf_error in flags1) then begin
    with info,contextstack[s.stackindex] do begin
     if getvalue(3,d.control.forinfo.varsize) then begin
      d.control.forinfo.stop:= gettempaddress(d.control.forinfo.varsize);
      
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
 beginloop();
end;

procedure handleforend();
begin
{$ifdef mse_debugparser}
 outhandle('FOREND');
{$endif}
 with info do begin
  with info,contextstack[s.stackindex].d.control.forinfo do begin
   releasetempaddress([das_pointer,varsize,varsize]);
  end;
 end;
 endloop();
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

procedure handlecolonexpected();
begin
{$ifdef mse_debugparser}
 outhandle('COLONEXPECTED');
{$endif}
 tokenexpectederror(':');
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

end.
