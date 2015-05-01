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

procedure handlefinallyexpected();
procedure handletryentry();
procedure handlefinallyentry();
procedure handlefinally();
procedure handleexceptentry();
procedure handleexcept();
procedure handleraise();

implementation
uses
 handlerutils,errorhandler,parserglob,handlerglob,elements,opcode,stackops,
 segmentutils,opglob;
 
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
              //todo: don't use push/pop stack
begin
{$ifdef mse_debugparser}
 outhandle('TRYYENTRY');
{$endif}
 with additem(oc_pushcpucontext)^ do begin
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
  with additem(oc_popcpucontext)^ do begin
  end;
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
end;

procedure handleexceptentry();
begin
{$ifdef mse_debugparser}
 outhandle('EXCEPTENTRY');
{$endif}
 with additem(oc_goto)^ do begin
 end;
 with info,contextstack[s.stackindex-1] do begin
  getoppo(opmark.address)^.par.opaddress.opaddress:= opcount-1;
  opmark.address:= opcount-1; //gotoop
 end;
 with additem(oc_popcpucontext)^ do begin
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
  with additem(oc_finiexception)^ do begin
  end;
//  dec(s.stackindex,1);
 end; 
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
