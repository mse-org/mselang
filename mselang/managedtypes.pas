{ MSElang Copyright (c) 2014 by Martin Schreiber
   
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
unit managedtypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

procedure writemanagedini();
procedure writemanagedfini();

implementation
uses
 elements,grammar,parserglob;

procedure writeini(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
begin
end;

procedure writefini(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
begin
end;

procedure writemanagedini();
begin
 ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],@writeini,nil^);
end;

procedure writemanagedfini();
begin
 ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],@writefini,nil^);
end;

end.
