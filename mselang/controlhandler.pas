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
unit controlhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

procedure handleif0();
procedure handleif();
procedure handlethen();
procedure handlethen0();
procedure handlethen1();
procedure handlethen2();
procedure handleelse0();
procedure handleelse();

procedure handlecasestart();
procedure handlecaseexpression();
procedure handleofexpected();
procedure handlecolonexpected();
procedure handlecasebranchentry();
procedure handlecasebranch();
procedure handlecase();

implementation
uses
 handlerutils,parserglob,errorhandler,grammar,handlerglob,elements,opcode,
 stackops,segmentutils,opglob;
 
procedure handleif0();
begin
{$ifdef mse_debugparser}
 outhandle('IF0');
{$endif}
 with info do begin
  include(s.currentstatementflags,stf_rightside);
 end;
end;

procedure handleif();
begin
{$ifdef mse_debugparser}
 outhandle('IF');
{$endif}
 with info do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

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
  getvalue(s.stacktop-s.stackindex);
  with contextstack[s.stacktop] do begin
   if not (ptypedataty(ele.eledataabs(
                      d.dat.datatyp.typedata))^.kind = dk_boolean) then begin
    errormessage(err_booleanexpressionexpected,[],s.stacktop-s.stackindex);
   end;
  {
  if d.kind = ck_const then begin
   push(d.dat.constval.vboolean); //todo: use compiletime branch
  end;
  }
   with additem(oc_if)^ do begin
    par.ssas1:= d.dat.fact.ssaindex;
   end;
   inc(info.s.ssa.blockindex);
  end;
 end;
end;

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

procedure handlethen2();
      //1       2        
begin //boolexp,thenmark
{$ifdef mse_debugparser}
 outhandle('THEN2');
{$endif}
 setcurrentlocbefore(2); //set gotoaddress
 addlabel();
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
 with additem(oc_goto)^ do begin
 end;
 inc(info.s.ssa.blockindex);
end;

procedure handleelse();
      //1       2        3
begin //boolexp,thenmark,elsemark
{$ifdef mse_debugparser}
 outhandle('ELSE');
{$endif}
 setlocbefore(2,3);      //set gotoaddress for handlethen0
 setcurrentlocbefore(3); //set gotoaddress for handleelse0
 addlabel();
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
begin
{$ifdef mse_debugparser}
 outhandle('CASEEXPRESSION');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (s.stacktop-s.stackindex = 1) and getvalue(1,true) and 
                 (d.dat.datatyp.indirectlevel = 0) and 
         (ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.kind in 
                                                 ordinaldatakinds) then begin
   if d.kind = ck_const then begin //todo: optimize const case switch
    getvalue(1);
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
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCHENTRY');
{$endif}
 with info do begin
  last:= s.stackindex-1;
  itemcount:= s.stackindex - contextstack[last].parent - 1;
  
  for int1:= s.stackindex - itemcount to last do begin
   with contextstack[int1] do begin
    if (d.kind = ck_const) and (d.dat.datatyp.indirectlevel = 0) and
                          (d.dat.constval.kind in ordinaldatakinds) then begin
            //todo: signed/unsigned, use table
     if tf_lower in d.dat.datatyp.flags then begin
      po1:= additem(oc_cmpjmploimm4);
      if int1 <> last-1 then begin
       po1^.par.immgoto:= opcount; //next check
      end;
     end
     else begin
      if tf_upper in d.dat.datatyp.flags then begin
       if int1 = last then begin
        po1:= additem(oc_cmpjmpgtimm4);
       end
       else begin
        po1:= additem(oc_cmpjmploeqimm4);
        po1^.par.immgoto:= opcount+last-int1-1;
       end;
      end
      else begin
       if int1 = last then begin
        po1:= additem(oc_cmpjmpneimm4);
       end
       else begin
        po1:= additem(oc_cmpjmpeqimm4);
        po1^.par.immgoto:= opcount+last-int1-1;
       end;
      end;
     end;
     opmark.address:= opcount-1;
     po1^.par.ordimm.vint32:= d.dat.constval.vinteger;
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
 with additem(oc_goto)^ do begin
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
     po1^.par.immgoto:= opmark.address-1;
     if isrange then begin
     {$ifdef mse_checkinternalerror}
      if not checkop((po1-1)^.op,oc_cmpjmploimm4) then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      (po1-1)^.par.immgoto:= opmark.address-1; //tf_lower
     end;
     with getoppo(opmark.address-1)^ do begin
     {$ifdef mse_checkinternalerror}
      if not checkop(op,oc_goto) then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      par.lab.opaddress:= endad;
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
     op.op:= oc_nop;
//     setop(op,oc_nop);
    end;
   end;
   with additem(oc_pop)^ do begin
    setimmsize(sizeof(int32),par);
   end;
  end;
  dec(s.stackindex);
 end;
end;

end.
