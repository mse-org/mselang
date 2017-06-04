{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
unit elementcache;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msehash,msetypes;

const
 maxidentvector = 200;

type
// elementoffsetty = ptrint;
 elementoffsetty = int32; //same size for 64 and 32 bit compilers because of
                          //dump in unit files
 elementsizety = uint32;

 identarty = integerarty;
 identvecty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;

 cachedataty = record
  key: identty;
  high: int32;
  data: elementoffsetty; //offset in identtdata
  element: elementoffsetty;
  firstnotfound: int32;
 end;
 cachehashdataty = record
  header: hashheaderty;
  data: cachedataty;
 end;
 pcachehashdataty = ^cachehashdataty;
  
 telementcache = class(thashdatalist)
  private
   fidentdata: pidentty;
   fidentcapacity: int32;
   fidentcount: int32;
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey;
                  const aitem: phashdataty): boolean override;
   function getrecordsize(): int32 override;
  public
   destructor destroy(); override;
   procedure clear override;
   procedure add(const aidents: identvecty;
                                const aelement: elementoffsetty; 
                                          const afirstnotfound: int32);
   function find(const aidents: identvecty; 
                           out aelement: elementoffsetty;
                                    out afirstnotfound: int32): boolean;
 end;
 
implementation

{ telementcache }

destructor telementcache.destroy();
begin
 inherited;
 if fidentdata <> nil then begin
  freemem(fidentdata);
 end;
end;

procedure telementcache.clear;
begin
 inherited; //todo: do not free buffer memory for implementation uses
 fidentcount:= 0;
end;

function telementcache.hashkey(const akey): hashvaluety;
var
 h1: hashvaluety;
 p1,pe: pidentty;
begin
 with identvecty(akey) do begin
  p1:= @d[0];
  pe:= p1+high;
  h1:= 0;
  while p1 <= pe do begin
   h1:= h1+p1^;
   inc(p1);
  end;
  result:= h1;
 end;
end;

function telementcache.checkkey(const akey; const aitem: phashdataty): boolean;
var
 p1,p2,pe: pidentty;
begin
 with identvecty(akey),pcachehashdataty(aitem)^ do begin
  result:= high = data.high;
  if result then begin
   p1:= @d[0];
   pe:= p1+high;
   p2:= pointer(fidentdata) + data.data;
   while p1 <= pe do begin
    if p1^ <> p2^ then begin
     result:= false;
     break;
    end;
    inc(p2);
    inc(p1);
   end;
  end;
 end;
end;

function telementcache.getrecordsize(): int32;
begin
 result:= sizeof(cachehashdataty);
end;

procedure telementcache.add(const aidents: identvecty;
                            const aelement: elementoffsetty; 
                            const afirstnotfound: int32);
var
 p1,p2,pe: pidentty;
 p0: pointer;
 h1: hashvaluety;
begin
 p2:= fidentdata + fidentcount;
 fidentcount:= fidentcount+aidents.high+1;
 if fidentcount > fidentcapacity then begin
  fidentcapacity:= fidentcapacity*2+256;
  reallocmem(fidentdata,fidentcapacity*sizeof(identty));
  p2:= fidentdata + (fidentcount-aidents.high-1);
 end;
 p1:= @aidents.d[0];
 pe:= p1 + aidents.high;
 h1:= 0;
 p0:= p2;
 while p1 <= pe do begin
  h1:= h1 + p1^;
  p2^:= p1^;
  inc(p2);
  inc(p1);
 end;
 with pcachehashdataty(internaladdhash(h1))^ do begin
  data.key:= h1;
  data.high:= aidents.high;
  data.data:= p0 - pointer(fidentdata);
  data.element:= aelement;
  data.firstnotfound:= afirstnotfound;
 end;
end;

function telementcache.find(const aidents: identvecty;
           out aelement: elementoffsetty; out afirstnotfound: int32): boolean;
var
 p1: pcachehashdataty;
begin
 result:= false;
 p1:= pcachehashdataty(internalfind(aidents));
 if p1 <> nil then begin
  result:= true;
  aelement:= p1^.data.element;
  afirstnotfound:= p1^.data.firstnotfound;
 end;
end;

end.
