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
unit msertti;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
type
 datatypety = (dt_none,dt_enum);
 
 rttiheaderty = record
  kind: datatypety;
 end;
 prttiheaderty = ^rttiheaderty;

 namelistty = record     //{charcount (byte), {char (byte)}}
 end;
 
 enumitemrttity = record
  value: integer;
  name: integer; //offset to name, base = record start
 end;
 penumitemrttity = ^enumitemrttity;

 enumrttiflagty = (erf_contiguous);
 enumrttiflagsty = set of enumrttiflagty;
  
 enumrttity = record
  itemcount: integer;
  flags: enumrttiflagsty;
  items: record end; //array of enumitemrttity
  names: namelistty;
 end;
 penumrttity = ^enumrttity;
  
 rttity = record
  header: rttiheaderty;
  data: record end;
 end;
 prttity = ^rttity;

implementation
end.
