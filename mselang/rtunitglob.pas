{ MSElang Copyright (c) 2015 by Martin Schreiber
   
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
unit rtunitglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes;
 
type
 identstringty = packed record
  len: byte;
  data: record //max 255 characters
  end;
 end;
 pidentstringty = ^identstringty;

 lenitemty = record
  len: int32;
  data: record //array of items
  end;
 end;
 plenitemty = ^lenitemty;

 usesitemty = record
  id: identty;
 end;
 pusesitemty = ^usesitemty;
 usesitemarty = array of usesitemty;
 
 unitintfheaderty = record
  sourcetimestamp: tdatetime;
  key: identty;
  mainad: card32;
  interfaceglobstart: card32;
  interfaceglobsize: card32;
  implementationglobstart: card32;
  implementationglobsize: card32;
  namecount: int32; //idents
  anoncount: int32; //idents without name, first item is parserglob.idstart
 end;
 
 unitintfinfoty = record
  header: unitintfheaderty;
  interfaceuses: lenitemty;
  implementationuses: lenitemty;
  data: record  //dump of elements
  end;
 end;
 punitintfinfoty = ^unitintfinfoty;

 unitlinkty = record
//  dest: elementoffsetty;
  len: int32;
  ids: record //array of identty in reverse order
  end;
 end;
 punitlinkty = ^unitlinkty;

implementation
  
end.
