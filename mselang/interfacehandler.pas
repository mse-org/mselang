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
unit interfacehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;

procedure handleinterfacedefstart();
procedure handleinterfacedeferror();
procedure handleinterfacedefreturn();
procedure handleinterfacedefparam2();
procedure handleinterfacedefparam3a();

implementation
uses
 handlerutils;
procedure handleinterfacedefstart();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEDEFSTART');
{$endif}
end;

procedure handleinterfacedeferror();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEDEFERROR');
{$endif}
end;

procedure handleinterfacedefreturn();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEDEFRETURN');
{$endif}
end;

procedure handleinterfacedefparam2();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEDEFPSTART');
{$endif}
end;

procedure handleinterfacedefparam3a();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEDEFSTART');
{$endif}
end;

end.
