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
unit listutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
 
type
 linkheaderty = record
  next: listadty; //offset from list
 end;
 plinkheaderty = ^linkheaderty;
 linkdataty = record
  header: linkheaderty;
  data: record
  end;
 end;
 plinkdataty = ^linkdataty;

 linklistty = record
  itemsize: integer;
  mincapacity: integer;
  list: pointer;
  current: listadty;  //offset from list
  capacity: listadty; //offset from list
  deleted: listadty;
 end;

 resolvehandlerty = procedure(var item);
 resolvehandlerdataty = procedure(var item; var data);

procedure clearlist(var alist: linklistty; const aitemsize: integer;
                                              const amincapacity: integer);
function addlistitem(var alist: linklistty; var aitem: listadty): pointer;
procedure deletelistchain(var alist: linklistty; const achain: listadty);
procedure invertlist(const alist: linklistty; var achain: listadty);
procedure resolvelist(var alist: linklistty; const handler: resolvehandlerty;
                                                         var achain: listadty);
procedure foralllistitems(var alist: linklistty;
                    const handler: resolvehandlerty; const achain: listadty);
procedure foralllistitemsdata(var alist: linklistty;
                    const handler: resolvehandlerdataty; const achain: listadty;
                    const data: pointer);
implementation

procedure clearlist(var alist: linklistty; const aitemsize: integer;
                                                 const amincapacity: integer);
begin
 with alist do begin
  itemsize:= aitemsize;
  mincapacity:= amincapacity*aitemsize;
  if list <> nil then begin
   freemem(list);
  end;
  list:= nil;
  current:= 0;
  capacity:= 0;
  deleted:= 0;  
 end;
end;

function addlistitem(var alist: linklistty; var aitem: listadty): pointer;
var
 li1: listadty;
begin
 with alist do begin
  li1:= deleted;
  if li1 = 0 then begin
   current:= current + itemsize;
   if current >= capacity then begin
    capacity:= 2*capacity + mincapacity;
    reallocmem(list,capacity);
   end;
   li1:= current;
   result:= list+li1;
  end
  else begin
   result:= list+li1;
   deleted:= plinkheaderty(result)^.next;
  end;
  plinkheaderty(result)^.next:= aitem;
  aitem:= li1;  
 end; 
end; 

procedure deletelistchain(var alist: linklistty; const achain: listadty);
begin
 with alist do begin
  plinkheaderty(list+achain)^.next:= deleted;
  deleted:= achain;
 end; 
end;

procedure invertlist(const alist: linklistty; var achain: listadty);
var
 s,s1,d: listadty;
begin
 if achain <> 0 then begin
  d:= 0;
  s:= achain;
  repeat
   with plinkheaderty(alist.list+s)^ do begin
    s1:= next;
    next:= d;
   end;
   d:= s;
   s:= s1;
  until s = 0;
  achain:= d;
 end;
end;
 
procedure resolvelist(var alist: linklistty; const handler: resolvehandlerty;
                                                         var achain: listadty);
var
 ad1: listadty;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  with alist do begin
   while ad1 <> 0 do begin
    po1:= alist.list+ad1;
    handler(po1^);
    ad1:= po1^.next;
   end;
   plinkheaderty(list+achain)^.next:= deleted;
   deleted:= achain;
   achain:= 0;
  end;
 end;
end;

procedure foralllistitems(var alist: linklistty;
                    const handler: resolvehandlerty; const achain: listadty);
var
 ad1: listadty;
 po2: pointer;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  po2:= alist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   handler(po1^);
   ad1:= po1^.next;
  end;
 end;
end;

procedure foralllistitemsdata(var alist: linklistty;
                    const handler: resolvehandlerdataty; const achain: listadty;
                    const data: pointer);
var
 ad1: listadty;
 po2: pointer;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  po2:= alist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   handler(po1^,data^);
   ad1:= po1^.next;
  end;
 end;
end;

end.
