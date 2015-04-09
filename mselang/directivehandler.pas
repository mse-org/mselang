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
unit directivehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

procedure handledumpelements();
procedure handledumpopcode();
procedure handleabort();
procedure handlestoponerror();
procedure handlenop();

procedure handledefine();

procedure handleifdef();
procedure handleelseif();
procedure handleendif();
procedure handleskipifelseentry();

implementation
uses
 msestrings,elements,parserglob,opcode,opglob,handlerutils,errorhandler,
 parser,grammar;
 
procedure handledumpelements();
{$ifdef mse_debugparser}
var
 ar1: msestringarty;
 int1: integer;
{$endif}
begin
{$ifdef mse_debugparser}
 writeln('--ELEMENTS---------------------------------------------------------');
 ar1:= ele.dumpelements;
 for int1:= 0 to high(ar1) do begin
  writeln(ar1[int1]);
 end;
 writeln('-------------------------------------------------------------------');
{$endif}
 with info do begin
  dec(s.stackindex);
 end;
end;

procedure handledumpopcode();
begin
{$ifdef mse_debugparser}
 dumpops();
{$endif}
 with info do begin
  dec(s.stackindex);
 end;
end;

procedure handleabort();
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  s.stopparser:= true;
  errormessage(err_abort,[]);
  dec(s.stackindex);
 end;
end;

procedure handlestoponerror();
var
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  s.unitinfo^.stoponerror:= true;
  dec(s.stackindex);
 end;
end;

procedure handlenop();
begin
{$ifdef mse_debugparser}
 outhandle('NOP');
{$endif}
 additem(oc_nop);
end;

procedure handledefine();
var
 po1: pointer;
begin
{$ifdef mse_debugparser}
 outhandle('DEFINE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  ele.adduniquechilddata(s.unitinfo^.interfaceelement,
                             [tks_defines,d.ident.ident],ek_none,allvisi,po1);
 end;
end;

procedure handleifdef();
var
 ele1: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('IFDEF');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if not ele.findchild(s.unitinfo^.interfaceelement,
               [tks_defines,d.ident.ident],[],allvisi,ele1) then begin
   switchcontext(@skipifco);
  end;
 end;
end;

procedure handleelseif();
begin
{$ifdef mse_debugparser}
 outhandle('ELSEIF');
{$endif}
end;

procedure handleendif();
begin
{$ifdef mse_debugparser}
 outhandle('ENDIF');
{$endif}
end;

procedure handleskipifelseentry();
begin
{$ifdef mse_debugparser}
 outhandle('SKIPIFELSENTRY');
{$endif}
end;

end.
