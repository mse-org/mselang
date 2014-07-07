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
 handlerutils,handlerglob,errorhandler,elements;

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
   if not ele.pushelement(id1,globalvisi,ek_type,d.typ.typedata) then begin
    identerror(stacktop-stackindex,err_duplicateidentifier,erl_fatal);
   end;
   currentcontainer:= d.typ.typedata;
   po1:= ele.eledataabs(currentcontainer);
   inittypedatasize(po1^,dk_interface,d.typ.indirectlevel,das_pointer);
{
   with po1^ do begin
    kind:= dk_class;
    fieldchain:= 0;
    bytesize:= pointersize;
    bitsize:= pointersize*8;
    datasize:= das_pointer;
    ancestor:= 0;
    infoclass.impl:= 0;
    infoclass.defs:= 0;
    infoclass.flags:= [];
    infoclass.pendingdescends:= 0;
   end;
}
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
  ptypedataty(ele.parentdata())^.infointerface.subchain:= currentsubchain;
  ele.elementparent:= contextstack[stackindex].b.eleparent;
 end;
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
