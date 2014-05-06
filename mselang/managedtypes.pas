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
unit managedtypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation

procedure checkvarmanagedtype(const avar: vardataty);

type
 varprocty = procedure();

const
 systypeini = array[systypety] of varprocty = (
  //st_none,st_bool8,st_int32,st_float64,st_string8
    nil,    nil,     nil,     nil,       nil
 );

 systypefini = array[systypety] of varprocty = (
  //st_none,st_bool8,st_int32,st_float64,st_string8
    nil,    nil,     nil,     nil,       nil
 );

procedure checkvarmanagedtype(const avar: vardataty);
begin
end;

end.
