{ MSEide Copyright (c) 2013 by Martin Schreiber
   
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
unit modulehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,mseparserglob;

function loadmoduleinterface(const info: pparseinfoty;
                                         const aindex: integer): boolean;
                    //true if ok
procedure init;
procedure deinit;

implementation

function loadmoduleinterface(const info: pparseinfoty;
                                         const aindex: integer): boolean;
                    //true if ok
begin
 result:= false; 
 with info^.contextstack[aindex] do begin
 end;
end;

procedure init;
begin
end;

procedure deinit;
begin
end;

end.
