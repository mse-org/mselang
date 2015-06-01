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
type
 unitintfheaderty = record
  sourcetimestamp: tdatetime;
  namecount: int32; //idents
  anoncount: int32; //idents without name
 end;
 unitintfinfoty = record
  header: unitintfheaderty;
  data: record  //dump of elements
  end;
 end;
 punitintfinfoty = ^unitintfinfoty;

implementation
end.
