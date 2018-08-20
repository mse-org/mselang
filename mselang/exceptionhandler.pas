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
unit exceptionhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 globtypes,listutils,parserglob,msetypes,opglob;

type
 trystackitemty = record
  header: linkheaderty;
//  entry: int32;  //index of op_pushcpucontext
  links: linkindexty;
 end;
 ptrystackitemty = ^trystackitemty;
var
 trystacklist: linklistty;

procedure handlefinallyexpected();
procedure handletryentry();
procedure handlefinallyentry();
procedure handlefinally();
procedure handleexceptentry();
procedure handleexceptelse();
procedure handleexcept();
procedure handleraise();
procedure handleraise1();
procedure handlegetexceptobj(const paramco: int32);

procedure tryblockbegin();
function tryhandle(const stackoffset: integer = bigint;
                   const aopoffset: int32 = -1 //-1 -> at end  
                                                         ): landingpadty;
procedure tryblockend();

implementation
uses
 handlerutils,errorhandler,handlerglob,elements,opcode,stackops,
 segmentutils,unithandler,classhandler,syssubhandler,llvmlists,
 __mla__internaltypes;
 
procedure handlefinallyexpected();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLYEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('finally');
  dec(s.stackindex);
 end; 
end;

//todo: no memoryleaks by exceptions in except and finally block

procedure tryblockbegin();
begin
 with info do begin
  inc(s.trystacklevel);
  with ptrystackitemty(addlistitem(trystacklist,s.trystack))^ do begin
   links:= 0;
   with additem(oc_pushcpucontext)^ do begin
    linkmark(links,getsegaddress(seg_op,@par.opaddress.bbindex));
   end;
  end;
 end;
end;

procedure tryblockend();
begin
 with info do begin
  deletelistitem(trystacklist,s.trystack);
  dec(s.trystacklevel);
 end;
end;

procedure handletryentry();
begin
{$ifdef mse_debugparser}
 outhandle('TRYYENTRY');
{$endif}
 initblockcontext(0,ck_block);
 tryblockbegin();
end;

function tryhandle(const stackoffset: integer = bigint;
                          const aopoffset: int32 = -1 //-1 -> at end  
                                                           ): landingpadty;
begin                      
 with ptrystackitemty(getlistitem(trystacklist,info.s.trystack))^ do begin
  linkresolveint(links,info.s.ssa.bbindex);
//  addlabel();
  with insertitem(oc_popcpucontext,stackoffset,aopoffset)^ do begin
   if co_llvm in info.o.compileoptions then begin
    result.tempval:= allocllvmtemp(
                             info.s.unitinfo^.llvmlists.typelist.landingpad);
    par.popcpucontext.landingpad:= result;
   end
   else begin
    result.tempval:= -1;
   end;
   if info.s.trystacklevel > 1 then begin //restore parent landingpad
    with ptrystackitemty(
            getnextlistitem(trystacklist,info.s.trystack))^ do begin
     linkmark(links,getsegaddress(seg_op,@par.opaddress.bbindex));
    end;
   end
   else begin
    par.opaddress.bbindex:= 0;
   end;
   newblockcontext(0);
//   info.contextstack[info.s.stackindex].d.block.landingpad:= 
//                                    par.popcpucontext.landingpadalloc;
  end;
 end;
end;

procedure tryexit();
begin
 finiblockcontext(0);
 tryblockend();
end;
var testvar: popinfoty;
procedure handlefinallyentry();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLYENTRY');
{$endif}
 with info do begin
  if not (co_llvm in o.compileoptions) then begin
   notimplementederror('20180814A');
  end;
  with additem(oc_storelocnil,getssa(ocssa_aggregate))^ do begin 
                  //set exception temp to nil
   par.memop.locdataaddress.a.address:= tempvarcount; //alloced by tryhandle()
   par.memop.locdataaddress.a.framelevel:= -1;
   par.memop.locdataaddress.offset:= 0;
   par.memop.t:= bitoptypes[das_pointer];
   include(par.memop.t.flags,af_aggregate);
  end;
  with additem(oc_goto)^ do begin
   par.opaddress.opaddress:= opcount+1-1; //label after landingpad
  end;
  with contextstack[s.stackindex-1] do begin
   b.flags:= s.currentstatementflags;
   include(s.currentstatementflags,stf_finally);
   d.kind:= ck_finallyblock;
   d.block.landingpad:= tryhandle();           //add landingpad
//   d.block.exceptiontemp:= tryhandle();           //add landingpad
testvar:= getoppo(contextstack[s.stackindex-1].opmark.address);
   getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1;
  end;
  tryexit();
  addlabel();
 end;
end;

procedure handlefinally();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLY');
{$endif}
// tryexit();
 with info,contextstack[s.stackindex-1] do begin
  with additem(oc_continueexception)^ do begin
   par.landingpad:= d.block.landingpad;//exceptiontemp;
  end;
  s.currentstatementflags:= b.flags;
//  dec(s.stackindex,1);
 end; 
end;

procedure handleexceptentry();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPTENTRY');
{$endif}
 with additem(oc_goto)^ do begin
 end;
 with info do begin
  with contextstack[s.stackindex] do begin
   d.block.landingpad:= tryhandle();
   dec(s.trystacklevel); //no LLVM invoke
   b.flags:= s.currentstatementflags;
   include(s.currentstatementflags,stf_except);
   d.kind:= ck_exceptblock;
   d.block.casechain:= 0;
   d.block.caseflags:= [caf_first];
  end;
  with contextstack[s.stackindex-1] do begin
   getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1;
   opmark.address:= opcount-2; //gotoop
  end;
 end;
end;

procedure handleexceptelse();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPTELSE');
{$endif}
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_exceptblock then begin
   internalerror(ie_handler,'20170727A');
  end;
 {$endif}
  if d.block.casechain <> 0 then begin //else no labels
   additem(oc_goto);                       //op -1
     //jump to except end, address set later     
   with pclasspendingitemty(addlistitem(pendingclassitems,
                                           d.block.casechain))^ do begin
    exceptcase.startop:= opcount;
    exceptcase.first:= true;
    exceptcase.last:= true;
    exceptcase.elsefla:= true;
   end;
   addlabel();
  end;
  include(d.block.caseflags,caf_else);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleexcept();
var
 i1: int32;
 p1: pclasspendingitemty;
 op1: popinfoty;
 nextcaseop: int32;
 caseopstart: int32;
 endop: int32;
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPT');
{$endif}
 with info do begin
  with contextstack[s.stackindex] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_exceptblock then begin
    internalerror(ie_handler,'20170725A');
   end;
  {$endif}
   if d.block.casechain <> 0 then begin
    endop:= opcount;
    addlabel();
    nextcaseop:= endop;
    i1:= d.block.casechain;
    while true do begin
     p1:= getlistitem(pendingclassitems,i1);
     if p1^.exceptcase.elsefla then begin
      i1:= p1^.header.next;
     {$ifdef mse_checkinternalerror}
      if i1 = 0 then begin
       internalerror(ie_handler,'20170727B');
      end;
      op1:= getoppo(p1^.exceptcase.startop,-1);
     {$ifdef mse_checkinternalerror}
      if op1^.op.op <> oc_goto then begin
       internalerror(ie_handler,'20170725C');
      end;
     {$endif}
      op1^.par.opaddress.opaddress:= endop-1;
      nextcaseop:= p1^.exceptcase.startop;
     {$endif}
     end
     else begin
      op1:= getoppo(p1^.exceptcase.startop,5);
     {$ifdef mse_checkinternalerror}
      if op1^.op.op <> oc_gotofalse then begin
       internalerror(ie_handler,'20170725C');
      end;
     {$endif}
      op1^.par.opaddress.opaddress:= nextcaseop - 1;
      nextcaseop:= p1^.exceptcase.startop;
      i1:= p1^.header.next;
      op1:= getoppo(nextcaseop,6);
      if p1^.exceptcase.last then begin
       caseopstart:= getopindex(op1);
      end
      else begin
      {$ifdef mse_checkinternalerror}
       if op1^.op.op <> oc_goto then begin
        internalerror(ie_handler,'20170725C');
       end;
      {$endif}
       op1^.par.opaddress.opaddress:= caseopstart-1;
      end;
      if (i1 <> 0) then begin                  //not first
       if p1^.exceptcase.first then begin 
        op1:= getoppo(p1^.exceptcase.startop,-1);
       {$ifdef mse_checkinternalerror}
        if op1^.op.op <> oc_goto then begin
         internalerror(ie_handler,'20170725C');
        end;
       {$endif}
        op1^.par.opaddress.opaddress:= endop-1;
       end;
      end
      else begin
       break;
      end;
     end;
    end;
    deletelistchain(pendingclassitems,d.block.casechain);
   end;
   s.currentstatementflags:= b.flags;
  end;
  with contextstack[s.stackindex-1] do begin
   with additem(oc_finiexception)^ do begin
    par.landingpad:= contextstack[s.stackindex].d.block.landingpad;
   end;
   getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1; 
                                       //skip exception handling code
   addlabel();
 {
   with additem(oc_finiexception)^ do begin
    par.finiexception.landingpadalloc:= 
                     contextstack[s.stackindex].d.block.landingpad;
   end;
 }
 //  dec(s.stackindex,1);
  end;
  inc(s.trystacklevel); //restore
 end;
 tryexit();
end;

procedure handlegetexceptobj(const paramco: int32);
           //getexceptobj(out obj; const acquire = false)
var
 i1,i2{,i3}: int32;
 landingpad1: landingpadty;
 typ1: ptypedataty;
 b1: boolean;
 ptop,p1: pcontextitemty;
 acquiressa: int32;
label
 errlab;
begin
{$ifdef mse_debugparser}
 outhandle('GETEXCEPTOBJ');
{$endif}
 with info do begin
  if paramco < 1 then begin
   checkparamco(1,paramco);
   goto errlab;
  end
  else begin
   if paramco > 2 then begin
    checkparamco(2,paramco);
    goto errlab;
   end
   else begin
    ptop:= @contextstack[s.stacktop];
    if paramco = 2 then begin
     if not getvalue(ptop,das_1) then begin
      goto errlab;
     end;
     if (ptypedataty(ele.eledataabs(ptop^.d.dat.datatyp.typedata))^.h.kind <> 
                         dk_boolean) or
                            (ptop^.d.dat.datatyp.indirectlevel <> 0) then begin
      errormessage(err_booleanexpressionexpected,[]);
      goto errlab;
     end;
     ptop:= getpreviousnospace(ptop-1);
    end;
   end;
  end;
  b1:= false;
  with ptop^ do begin
   if (d.kind in datacontexts) and (d.dat.datatyp.indirectlevel = 1) then begin
    typ1:= ele.eledataabs(d.dat.datatyp.typedata);
    if (typ1^.h.kind = dk_class) and 
                  (icf_except in typ1^.infoclass.flags) then begin
     b1:= true;
     if s.currentstatementflags * [stf_except,stf_finally] = [] then begin
      errormessage(err_noexceptavailable,[]);
     end
     else begin
      p1:= @contextstack[s.stackindex-1];
      while not (p1^.d.kind in [ck_exceptblock,ck_finallyblock]) do begin
      {$ifdef mse_checkinternalerror}
       if p1 <= pointer(contextstack) then begin
        internalerror(ie_handler,'20180816B');
       end;
      {$endif}
       dec(p1);
      end;
      if getaddress(ptop,true) then begin
       if paramco = 1 then begin
        with additem(oc_pushimm1)^.par do begin //acquire default false
         setimmboolean(false,imm);
         acquiressa:= ssad;
        end;
       end
       else begin
       {$ifdef mse_checkinternalerror}
        if not (contextstack[s.stacktop].d.kind in factcontexts) then begin
         internalerror(ie_handler,'20170728A');
        end;
       {$endif}
        acquiressa:= contextstack[s.stacktop].d.dat.fact.ssaindex;
       end;
      {
       with additem(oc_pushduppo)^.par do begin
        voffset:= -(2*targetpointersize);
        ssas1:= ptop^.d.dat.fact.ssaindex;
        i2:= ssad;
       end;
      }
       landingpad1:= p1^.d.block.landingpad;
      {
       with additem(oc_pushexception)^.par do begin
        finiexception.landingpadalloc:= i3;
        i1:= ssad;
       end;
       with additem(oc_popindirectpo)^.par do begin //store exceptobj
        ssas2:= i2; //address
        ssas1:= i1; //data
        memop.t:= bitoptypes[das_pointer];
       end;
       with additem(oc_push)^ do begin
        par.imm.vsize:= targetpointersize; //address still valid
       end;
      }
       with additem(oc_pushclassdef)^.par do begin
        if co_llvm in o.compileoptions then begin
         classdefid:= getclassdefid(typ1);
        end
        else begin
         classdefstackops:= typ1^.infoclass.defs.address;
        end;
        i2:= ssad;
       end;
       with additem(oc_checkexceptclasstype)^.par do begin 
                   //returns instance or nil in par 2 if no match
        ssas1:= i2; //classdef
        ssas2:= ptop^.d.dat.fact.ssaindex; //dest address
        landingpad:= landingpad1;
        i1:= ssad;
       end;
       with additem(oc_gotofalseoffs)^.par do begin //op -3
                          //checkclasstype result
        ssas1:= i1;
        gotostackoffs:= -(alignsize(sizeof(vbooleanty)));
       end;
       with additem(oc_gotofalseoffs)^.par do begin //op -2
        ssas1:= acquiressa;
        gotostackoffs:= -2*(alignsize(sizeof(vbooleanty)));
       end;
       with additem(oc_nilexception)^.par do begin        //op -1
        landingpad:= landingpad1;
       end;
       getoppo(opcount,-2)^.par.opaddress.opaddress:= opcount - 1;
       getoppo(opcount,-3)^.par.opaddress.opaddress:= opcount - 1;
       addlabel();                                        //op 0
       i2:= alignsize(sizeof(vbooleanty)) + targetpointersize;
       with additem(oc_movestack)^.par do begin //checkclasstype result
        swapstack.size:= alignsize(sizeof(vbooleanty));
        swapstack.offset:= -i2;
       end;
       with additem(oc_pop)^ do begin
        par.imm.vsize:= i2; //remove address and acquire
       end;
       initfactcontext(0);
       with contextstack[s.stackindex] do begin
        d.kind:= ck_subres;
        d.dat.fact.ssaindex:= i1;
        d.dat.datatyp:= sysdatatypes[st_bool1];
        d.dat.fact.opdatatype:= getopdatatype(d.dat.datatyp.typedata,0);
       end;
      end;
     end;
    end;
   end;
  end;
  if not b1 then begin
   errormessage(err_exceptvarexpected,[]);
  end;
 end;
errlab:
end;

procedure handleraise();
var
 bo1: boolean;
 po1: ptypedataty;
 ptop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('RAISE');
{$endif}
 with info do begin
  ptop:= @contextstack[s.stacktop];
  with ptop^ do begin
   bo1:= (getitemcount(s.stackindex+1) = 1) and (d.kind in datacontexts) and
                      getvalue(ptop,das_none) and 
                                           (d.dat.datatyp.indirectlevel = 1);
   if bo1 then begin
    po1:= ele.eledataabs(d.dat.datatyp.typedata);
    bo1:= (po1^.h.kind = dk_class) and (icf_except in po1^.infoclass.flags);
   end;
   if bo1 then begin
 //   with addcontrolitem(oc_raise)^ do begin
    with additem(oc_raise)^ do begin
     par.ssas1:= d.dat.fact.ssaindex;
    end;
   end
   else begin
    errormessage(err_exceptclassinstanceexpected,[]);
   end;
   dec(s.stackindex);
   s.stacktop:= s.stackindex;
  end;
 end;
end;

procedure handleraise1();
var
 p1: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('RAISE1');
{$endif}
 with info do begin
  if not (stf_except in s.currentstatementflags) then begin
   errormessage(err_classinstanceexpected,[]);
  end
  else begin
   p1:= @contextstack[s.stackindex];
   while p1^.d.kind <> ck_exceptblock do begin
   {$ifdef mse_checkinternalerror}
    if p1 = pointer(contextstack) then begin
     internalerror(ie_handler,'20180816A');
    end;
   {$endif}
    dec(p1);
   end;
   with additem(oc_continueexception)^ do begin
    par.landingpad:= p1^.d.block.landingpad;//exceptiontemp;
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

end.
