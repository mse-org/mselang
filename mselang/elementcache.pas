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
 identarty = integerarty;
 identvecty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;

 cachedataty = record
  key: identty;
 end;
 cachehashdataty = record
  header: hashheaderty;
  data: cachedataty;
 end;
  
 telementcache = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey;
                  const aitem: phashdataty): boolean override;
   function getrecordsize(): int32 override;
  public
   procedure add(const aidents: identvecty);
 end;
 
implementation

{ telementcache }

function telementcache.hashkey(const akey): hashvaluety;
begin
end;

function telementcache.checkkey(const akey; const aitem: phashdataty): boolean;
begin
end;

function telementcache.getrecordsize(): int32;
begin
 result:= sizeof(cachehashdataty);
end;

procedure telementcache.add(const aidents: identvecty);
begin
end;

end.
