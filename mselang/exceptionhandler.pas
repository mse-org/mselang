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

implementation
uses
 handlerutils,errorhandler,handlerglob,elements,opcode,stackops,
 segmentutils,opglob,unithandler;
 
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
  linkresolveint(links,info.s.ssa.blockindex);
  with additem(oc_popcpucontext)^ do begin
   if info.s.trystacklevel > 1 then begin //restore parent landingpad
    with ptrystackitemty(
            getnextlistitem(trystacklist,info.s.trystack))^ do begin
     linkmark(links,getsegaddress(seg_op,@par.opaddress.bbindex));
    end;
   end
   else begin
    par.opaddress.bbindex:= 0;
   end;
  end;
 end;
end;

procedure tryexit();
begin
 with info do begin
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
 with info,contextstack[s.stackindex-1] do begin
  getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1;
  opmark.address:= opcount-2; //gotoop
 end;
end;

procedure handleexcept();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPT');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1; 
                                      //skip exception handling code
  addlabel();
  with additem(oc_finiexception)^ do begin
  end;
//  dec(s.stackindex,1);
 end; 
 tryexit();
end;

procedure handleraise();
var
 bo1: boolean;
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('RAISE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  bo1:= (s.stacktop-s.stackindex = 1) and (d.kind in datacontexts) and
                     getvalue(1,das_none) and (d.dat.datatyp.indirectlevel = 1);
  if bo1 then begin
   po1:= ele.eledataabs(d.dat.datatyp.typedata);
   bo1:= po1^.h.kind = dk_class;
  end;
  if bo1 then begin
//   with addcontrolitem(oc_raise)^ do begin
   with additem(oc_raise)^ do begin
    par.ssas1:= d.dat.fact.ssaindex;
   end;
  end
  else begin
   errormessage(err_classinstanceexpected,[]);
  end;
  dec(s.stackindex);
 end; 
end;

end.
