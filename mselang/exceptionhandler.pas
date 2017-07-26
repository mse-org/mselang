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
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,listutils,parserglob;

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
procedure handleexcept();
procedure handleraise();
procedure handlegetexceptobj(const paramco: int32);

implementation
uses
 handlerutils,errorhandler,handlerglob,elements,opcode,stackops,
 segmentutils,opglob,unithandler,classhandler,syssubhandler;
 
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

procedure handletryentry();
begin
{$ifdef mse_debugparser}
 outhandle('TRYYENTRY');
{$endif}
 with info do begin
  initblockcontext(0,ck_block);
  inc(s.trystacklevel);
  with ptrystackitemty(addlistitem(trystacklist,s.trystack))^ do begin
   links:= 0;
   with additem(oc_pushcpucontext)^ do begin
    linkmark(links,getsegaddress(seg_op,@par.opaddress.bbindex));
   end;
  end;
 end;
end;

procedure tryhandle();
begin
 with ptrystackitemty(getlistitem(trystacklist,info.s.trystack))^ do begin
  linkresolveint(links,info.s.ssa.bbindex);
//  addlabel();
  with additem(oc_popcpucontext)^ do begin
   if co_llvm in info.o.compileoptions then begin
    par.popcpucontext.landingpadalloc:= 
                 allocllvmtemp(info.s.unitinfo^.llvmlists.typelist.landingpad);
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
   info.contextstack[info.s.stackindex].d.block.landingpad:= 
                                    par.popcpucontext.landingpadalloc;
  end;
 end;
end;

procedure tryexit();
begin
 with info do begin
  finiblockcontext(0);  
  deletelistitem(trystacklist,s.trystack);
  dec(s.trystacklevel);
 end;
end;

procedure handlefinallyentry();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLYENTRY');
{$endif}
 with info do begin
  getoppo(contextstack[s.stackindex-1].opmark.address)^.
                                          par.opaddress.opaddress:= opcount-1;
  tryhandle();
 end;
end;

procedure handlefinally();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLY');
{$endif}
 with info do begin
  with additem(oc_continueexception)^ do begin
  end;
//  dec(s.stackindex,1);
 end; 
 tryexit();
end;

procedure handleexceptentry();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPTENTRY');
{$endif}
 with addcontrolitem(oc_goto)^ do begin
 end;
 tryhandle();
 with info do begin
  with contextstack[s.stackindex] do begin
   d.kind:= ck_exceptblock;
   d.block.casechain:= 0;
   d.block.casefirst:= true;
  end;
  with contextstack[s.stackindex-1] do begin
   getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1;
   opmark.address:= opcount-2; //gotoop
  end;
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
    deletelistchain(pendingclassitems,d.block.casechain);
   end;
  end;
  with contextstack[s.stackindex-1] do begin
   with additem(oc_finiexception)^ do begin
    par.finiexception.landingpadalloc:= 
                     contextstack[s.stackindex].d.block.landingpad;
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
 end;
 tryexit();
end;

procedure handlegetexceptobj(const paramco: int32);
var
 i1,i2: int32;
 typ1: ptypedataty;
 b1: boolean;
 ptop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('GETEXCEPTOBJ');
{$endif}
 with info do begin
  if checkparamco(1,paramco) then begin
   b1:= false;
   ptop:= @contextstack[s.stacktop];
   with ptop^ do begin
    if (d.kind in datacontexts) and (d.dat.datatyp.indirectlevel = 1) then begin
     typ1:= ele.eledataabs(d.dat.datatyp.typedata);
     if (typ1^.h.kind = dk_class) and 
                   (icf_except in typ1^.infoclass.flags) then begin
      b1:= true;
      i1:= s.stackindex-1;
      while i1 >= 0 do begin
       if contextstack[i1].d.kind = ck_exceptblock then begin
        break;
       end;
       dec(i1);
      end;
      if i1 < 0 then begin
       errormessage(err_noexceptavailable,[]);
      end
      else begin
       if getaddress(ptop,true) then begin
        with additem(oc_pushexception)^.par do begin
         finiexception.landingpadalloc:= contextstack[i1].d.block.landingpad;
         i1:= ssad;
        end;
        with additem(oc_pushsegaddr,pushsegaddrssaar[seg_classdef])^.par do begin
         memop.segdataaddress.a:= typ1^.infoclass.defs;
         memop.segdataaddress.offset:= 0;
         memop.t:= bitoptypes[das_pointer];
         i2:= ssad;
        end;
        with additem(oc_checkclasstype)^.par do begin //returns nil if no match
         ssas1:= i1;
         ssas2:= i2;
         i1:= ssad;
        end;
        with additem(oc_popindirectpo)^.par do begin
         ssas2:= ptop^.d.dat.fact.ssaindex;
         ssas1:= i1;
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
 end;
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
  end;
 end;
end;

end.
