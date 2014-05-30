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
procedure handleofexpected();
procedure handlecolonexpected();
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

procedure handleofexpected();
begin
{$ifdef mse_debugparser}
 outhandle('OFEXPECTED');
{$endif}
end;

procedure handlecolonexpected();
begin
{$ifdef mse_debugparser}
 outhandle('COLONEXPECTED');
{$endif}
 tokenexpectederror(':');
end;

procedure handlecase();
begin
{$ifdef mse_debugparser}
 outhandle('CASE');
{$endif}
 with info do begin
  dec(stackindex);
 end;
end;

end.
