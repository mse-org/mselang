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
procedure handlefinally();
procedure handleraise();

implementation
uses
 handlerutils,errorhandler,parserglob,handlerglob,elements,opcode,stackops;
 
procedure handlefinallyexpected();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLYEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('finally');
  dec(stackindex);
 end; 
end;

procedure handletryentry();
begin
{$ifdef mse_debugparser}
 outhandle('TRYYENTRY');
{$endif}
end;

procedure handlefinally();
begin
{$ifdef mse_debugparser}
 outhandle('FINALLY');
{$endif}
 with info do begin
  dec(stackindex);
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
 with info,contextstack[stacktop] do begin
  bo1:= (stacktop-stackindex <> 1) or not(d.kind in datacontexts) or
      not getvalue(1) or (d.datatyp.indirectlevel <> 0);
  if bo1 then begin
   po1:= ele.eledataabs(d.datatyp.typedata);
   bo1:= po1^.kind = dk_class;
  end;
  if bo1 then begin
   with additem^ do begin
    op:= @raiseop;
   end;
  end
  else begin
   errormessage(err_classinstanceexpected,[]);
  end;
  dec(stackindex);
 end; 
end;

end.
