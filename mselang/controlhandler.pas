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
 stackops;
 
procedure handleif0();
begin
{$ifdef mse_debugparser}
 outhandle('IF0');
{$endif}
 with info do begin
  include(currentstatementflags,stf_rightside);
 end;
end;

procedure handleif();
begin
{$ifdef mse_debugparser}
 outhandle('IF');
{$endif}
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen();
begin
{$ifdef mse_debugparser}
 outhandle('THEN');
{$endif}
 tokenexpectederror(tk_then);
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen0();
begin
{$ifdef mse_debugparser}
 outhandle('THEN0');
{$endif}
 with info,contextstack[stacktop] do begin
  if not (ptypedataty(ele.eledataabs(
                         d.datatyp.typedata))^.kind = dk_boolean) then begin
   errormessage(err_booleanexpressionexpected,[],stacktop-stackindex);
  end;
  if d.kind = ck_const then begin
   push(d.constval.vboolean); //todo: use compiletime branch
  end;
 end;
 with additem()^ do begin
  op:= @ifop;   
 end;
end;

procedure handlethen1();
begin
{$ifdef mse_debugparser}
 outhandle('THEN1');
{$endif}
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlethen2();
      //1       2        
begin //boolexp,thenmark
{$ifdef mse_debugparser}
 outhandle('THEN2');
{$endif}
 setcurrentlocbefore(2); //set gotoaddress
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handleelse0();
begin
{$ifdef mse_debugparser}
 outhandle('ELSE0');
{$endif}
 with additem()^ do begin
  op:= @gotoop;
 end;
end;

procedure handleelse();
      //1       2        3
begin //boolexp,thenmark,elsemark
{$ifdef mse_debugparser}
 outhandle('ELSE');
{$endif}
 setlocbefore(2,3);      //set gotoaddress for handlethen0
 setcurrentlocbefore(3); //set gotoaddress for handleelse0
 with info do begin
  dec(stackindex);
  stacktop:= stackindex;
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
 with info,contextstack[stacktop] do begin
  if (stacktop-stackindex = 1) and getvalue(1,true) and 
                 (d.datatyp.indirectlevel = 0) and 
         (ptypedataty(ele.eledataabs(d.datatyp.typedata))^.kind in 
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
begin
{$ifdef mse_debugparser}
 outhandle('CASEBRANCHENTRY');
{$endif}
 with info do begin
  last:= stackindex-1;
  itemcount:= stackindex - contextstack[last].parent - 1;
  
  for int1:= stackindex - itemcount to last do begin
   with contextstack[int1] do begin
    if (d.kind = ck_const) and (d.datatyp.indirectlevel = 0) and
                              (d.constval.kind in ordinaldatakinds) then begin
     with additem()^ do begin       //todo: signed/unsigned, use table
      if tf_lower in d.datatyp.flags then begin
       op:= @cmpjmploimm4;
       if int1 <> last-1 then begin
        par.immgoto:= opcount; //next check
       end;
      end
      else begin
       if tf_upper in d.datatyp.flags then begin
        if int1 = last then begin
         op:= @cmpjmpgtimm4;
        end
        else begin
         op:= @cmpjmploeqimm4;
         par.immgoto:= opcount+last-int1-1;
        end;
       end
       else begin
        if int1 = last then begin
         op:= @cmpjmpneimm4;
        end
        else begin
         op:= @cmpjmpeqimm4;
         par.immgoto:= opcount+last-int1-1;
        end;
       end;
      end;
      opmark.address:= opcount-1;
      par.ordimm.vint32:= d.constval.vinteger;
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
 with additem()^ do begin
  op:= @gotoop;  //goto casend
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
   int1:= stackindex + 5;
   while int1 <= stacktop do begin
    while contextstack[int1].d.kind = ck_const do begin
     inc(int1);
    end;
    with contextstack[int1-1] do begin
     po1:= @ops[opmark.address]; //last compare
     isrange:= tf_upper in d.datatyp.flags;
    end;
   {$ifdef mse_checkinternalerror}
    if (po1^.op <> @cmpjmpneimm4) and (po1^.op <> @cmpjmpgtimm4) then begin
     internalerror(ie_handler,'20140530A');
    end;
   {$endif}
    with contextstack[int1] do begin
     po1^.par.immgoto:= opmark.address-1;
     if isrange then begin
     {$ifdef mse_checkinternalerror}
      if ((po1-1)^.op <> @cmpjmploimm4) then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      (po1-1)^.par.immgoto:= opmark.address-1; //tf_lower
     end;
     with ops[opmark.address-1] do begin
     {$ifdef mse_checkinternalerror}
      if op <> @gotoop then begin
       internalerror(ie_handler,'20140530A');
      end;
     {$endif}
      par.opaddress:= endad;
     end;
    end;
    inc(int1,3);
   end;
   if int1 - stacktop = 3 then begin
    with ops[opcount-1] do begin
    {$ifdef mse_checkinternalerror}
     if op <> @gotoop then begin
      internalerror(ie_handler,'20140530B');
     end;
    {$endif}
     op:= @nop;
    end;
   end;
   with additem()^ do begin
    op:= @popop;
    par.imm.vsize:= sizeof(int32);
   end;
  end;
  dec(stackindex);
 end;
end;

end.
