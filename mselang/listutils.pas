{ MSElang Copyright (c) 2013-2016 by Martin Schreiber
   
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
 globtypes;
 
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
 checkresolvehandlerty = procedure(var item; var data; var resolved: boolean);

procedure clearlist(var alist: linklistty; const aitemsize: integer;
                                              const amincapacity: integer);
procedure freelist(var alist: linklistty);
function addlistitem(var alist: linklistty; var achain: listadty): pointer;
function getlistitem(const alist: linklistty; const aitem: listadty): pointer;
function getnextlistitem(const alist: linklistty;
                                              const aitem: listadty): pointer;
                                               //nil if there is none
function steplistitem(const alist: linklistty;
                                              var aitem: listadty): pointer;
                                               //nil if there is none
procedure deletelistitem(var alist: linklistty; var achain: listadty);
procedure deletelistchain(var alist: linklistty; var achain: listadty);
procedure invertlist(const alist: linklistty; var achain: listadty);
procedure resolvelist(var alist: linklistty; const handler: resolvehandlerty;
                                                         var achain: listadty);
procedure checkresolve(var alist: linklistty; 
                   const handler: checkresolvehandlerty; var achain: listadty;
                   const data: pointer);
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

procedure freelist(var alist: linklistty);
begin
 with alist do begin
  if list <> nil then begin
   freemem(list);
  end;
  fillchar(alist,sizeof(alist),0);
 end;
end;

function addlistitem(var alist: linklistty; var achain: listadty): pointer;
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
  plinkheaderty(result)^.next:= achain;
  achain:= li1;  
 end; 
end; 

function getlistitem(const alist: linklistty; const aitem: listadty): pointer;
begin
 result:= alist.list+aitem;
end;

function getnextlistitem(const alist: linklistty;
                                 const aitem: listadty): pointer;
var
 i1: listadty;
begin
 result:= alist.list+aitem;
 i1:= plinkdataty(result)^.header.next;
 if i1 = 0 then begin
  result:= nil;
 end
 else begin
  result:= alist.list+i1;
 end;
end;

function steplistitem(const alist: linklistty;
                                              var aitem: listadty): pointer;
begin
 result:= alist.list+aitem;
 aitem:= plinkdataty(result)^.header.next;
 if aitem = 0 then begin
  result:= nil;
 end
 else begin
  result:= alist.list+aitem;
 end;
end;

procedure deletelistitem(var alist: linklistty; var achain: listadty);
var
 next1: listadty;
begin
 if achain <> 0 then begin
  with alist do begin
   next1:= plinkheaderty(list+achain)^.next;
   plinkheaderty(list+achain)^.next:= deleted;
   deleted:= achain;
  end;
  achain:= next1;
 end;
end;

procedure deletelistchain(var alist: linklistty; var achain: listadty);
var
 ad1: listadty;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  with alist do begin
   ad1:= achain;
   repeat
    po1:= alist.list+ad1;
    ad1:= po1^.next;
   until ad1 = 0;
   po1^.next:= deleted;
   deleted:= achain;
  end;
  achain:= 0;
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

procedure checkresolve(var alist: linklistty; 
                   const handler: checkresolvehandlerty; var achain: listadty;
                   const data: pointer);
var
 ad1: listadty;
 po2: pointer;
 po1,po3: plinkheaderty;
 bo1: boolean;
begin
 if achain <> 0 then begin
  po3:= nil;
  ad1:= achain;
  po2:= alist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   bo1:= false;
   handler(po1^,data^,bo1);
   if bo1 then begin
    if po3 <> nil then begin
     po3^.next:= po1^.next;
    end
    else begin
     achain:= po1^.next;
    end;
    if alist.deleted <> 0 then begin
     plinkheaderty(alist.list+alist.deleted)^.next:= ad1;
    end;
    alist.deleted:= ad1;
    ad1:= po1^.next;
    po1^.next:= 0;
   end
   else begin
    ad1:= po1^.next;
   end;
   po3:= po1;
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
