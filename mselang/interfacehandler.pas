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

type
 intfitemty = record  //interface sub item
  instanceshift: integer; //offset from interface pointer to instance
  subad: opaddressty;
 end;
 pintfitemty = ^intfitemty;

procedure handleinterfacedefstart();
procedure handleinterfacedeferror();
procedure handleinterfacedefreturn();
procedure handleinterfaceparam2entry();
procedure handleinterfaceparam();

implementation
uses
 handlerutils,handlerglob,errorhandler,elements,grammar;

procedure handleinterfacedefstart();
var
 po1: ptypedataty;
 id1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEDEFSTART');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if stackindex < 3 then begin
   internalerror(ie_handler,'20140704A');
  end;
 {$endif}
  include(currentstatementflags,stf_interfacedef);
  currentsubchain:= 0;
  currentsubcount:= 0;
  with contextstack[stackindex] do begin
   d.kind:= ck_interfacedef;
  {
   d.cla.visibility:= classpublishedvisi;
   d.cla.fieldoffset:= pointersize; //pointer to virtual methodtable
   d.cla.virtualindex:= 0;
  }
  end;
  with contextstack[stackindex-2] do begin
   if (d.kind = ck_ident) and 
                  (contextstack[stackindex-1].d.kind = ck_typetype) then begin
    id1:= d.ident.ident; //typedef
   end
   else begin
    errormessage(err_anoninterfacedef,[]);
    exit;
   end;
  end;
  contextstack[stackindex].b.eleparent:= ele.elementparent;
  with contextstack[stackindex-1] do begin
   if not ele.pushelement(id1,ek_type,globalvisi,d.typ.typedata) then begin
    identerror(stacktop-stackindex,err_duplicateidentifier,erl_fatal);
   end;
   currentcontainer:= d.typ.typedata;
   po1:= ele.eledataabs(currentcontainer);
   inittypedatasize(po1^,dk_interface,d.typ.indirectlevel,das_pointer);
   with po1^.infointerface do begin
    ancestorchain:= 0;
   end;
  end;
 end;
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
 with info do begin
  with ptypedataty(ele.parentdata())^ do begin
   infointerface.subchain:= currentsubchain;
   infointerface.subcount:= currentsubcount;
  end;
  ele.elementparent:= contextstack[stackindex].b.eleparent;
  exclude(currentstatementflags,stf_interfacedef);
 end;
end;

procedure handleinterfaceparam2entry();
var
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEPARAM2ENTRY');
{$endif}
 with info do begin
  ele.decelementparent(); //interface or implementation
  if findkindelementsdata(1,[ek_type],allvisi,po1) then begin
   if po1^.kind <> dk_interface then begin
    errormessage(err_interfacetypeexpected,[]);
   end
   else begin
    with contextstack[stackindex] do begin
     d.kind:= ck_typeref;
     d.typeref:= ele.eledatarel(po1);
    end;
   end;
  end;
  stacktop:= stackindex;
  ele.elementparent:= currentcontainer;
 end;
end;

procedure handleinterfaceparam();
var
 int1: integer;
 ele1: elementoffsetty;
 po1: ptypedataty;
 po2: pintfancestordataty;
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACEPARAM');
{$endif}
 with info do begin
  ele.pushelement(tks_ancestors,ek_none,allvisi);
  ele.checkcapacity(ek_intfancestor,stacktop-stackindex);
  ele1:= 0;
  for int1:= stacktop downto stackindex + 1 do begin
              //todo: check recursion
   with contextstack[int1] do begin
    if not ele.addelementdata(identty(d.typeref),
                                  ek_intfancestor,allvisi,po2) then begin
     errormessage(err_duplicateancestortype,[]);
    end;
    currentsubcount:= currentsubcount + 
                ptypedataty(ele.eledataabs(d.typeref))^.infointerface.subcount;
    po2^.intftype:= d.typeref;
    po2^.next:= ele1;
    ele1:= ele.eledatarel(po2);
   end;
  end;
  ele.decelementparent();
  with ptypedataty(ele.parentdata)^ do begin
   infointerface.ancestorchain:= ele1;
  end;
 end;
end;

end.
