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
unit inifini;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 handlerutils;
 
type
 managedvaritemty = record
  header: linkheaderty;
 end;
 pmangedvaritemty = ^managedvaritemty;

 managedtypeitemty = record
  header: linkheaderty;
 end;
 pmangedtypeitemty = ^managedtypeitemty;
 
//function addiniitem(var aitem: listadty): piniitemty;
//function  deleteinilist(

procedure markmanagedblock();
procedure releasemanagedblock();

procedure init;
procedure deinit;

implementation

type
 managedblockitemty = record
  header: linkheaderty;
 end;
 pmangedblockitemty = ^managedblockitemty;

var
 managedblocklist: linklistty;
 managedvarlist: linklistty;
 managedtypelist: linklistty;

procedure markmanagedblock();
begin
end;

procedure releasemanagedblock();
begin
end;
 
procedure clear();
begin
 clearlist(managedblocklist,sizeof(managedblockitemty),256); 
 clearlist(managedvarlist,sizeof(managedvaritemty),1024); 
 clearlist(managedtypelist,sizeof(managedtypeitemty),1024); 
end;

procedure init;
begin
 clear();
end;

procedure deinit;
begin
 clear();
end;

end.
