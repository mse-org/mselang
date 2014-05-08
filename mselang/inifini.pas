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
 parserglob,handlerutils;
(* not used 
procedure regmanagedvar(const avar: elementoffsetty);
procedure markmanagedblock(out aitem: listadty);
procedure releasemanagedblock(const aitem: listadty);
procedure writemanagedini();
procedure writemanagedfini();
*)
procedure init;
procedure deinit;

implementation
uses
 listutils,handlerglob,elements;
 
type
 managedblockitemty = record
  header: linkheaderty;
 end;
 pmangedblockitemty = ^managedblockitemty;

 managedvaritemty = record
  header: linkheaderty;
  varele: elementoffsetty;
 end;
 pmanagedvaritemty = ^managedvaritemty;

 managedtypeitemty = record
  header: linkheaderty;
 end;
 pmangedtypeitemty = ^managedtypeitemty;

var
 currentmanagedvar: listadty;
 managedblocklist: linklistty;
 managedvarlist: linklistty;
 managedtypelist: linklistty;

procedure writemanagedvarini(var itemdata);
var
 po1: pvardataty;
 po2: ptypedataty;
 po3: pointer;
 po4: plinkdataty;
begin
 with managedvaritemty(itemdata) do begin
  po1:= ele.eledataabs(varele);
  po2:= ele.eledataabs(po1^.vf.typ);
  po3:= managedtypelist.list;
//  po4:= po3+po2^.iniproc;
  ///////////////7..........
 end;
end;

procedure writemanagedini();
begin
 foralllistitems(managedvarlist,@writemanagedvarini,currentmanagedvar);
end;

procedure writemanagedfini();
begin
end;

procedure markmanagedblock(out aitem: listadty);
begin
end;

procedure releasemanagedblock(const aitem: listadty);
begin
end;

procedure regmanagedvar(const avar: elementoffsetty);
begin
 with pmanagedvaritemty(addlistitem(managedvarlist,currentmanagedvar))^ do begin
  varele:= avar;
 end;
end;
 
procedure clear();
begin
 clearlist(managedblocklist,sizeof(managedblockitemty),256); 
 clearlist(managedvarlist,sizeof(managedvaritemty),1024); 
 clearlist(managedtypelist,sizeof(managedtypeitemty),1024); 
 currentmanagedvar:= 0;
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
