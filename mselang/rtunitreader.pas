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
unit rtunitreader;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
 
function readunitfile(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 filehandler,segmentutils,msestream,msestrings,msesys,msesystypes,globtypes;
 
function readunitfile(const aunit: punitinfoty): boolean; //true if ok
var
 stream1: tmsefilestream;
 fna1: filenamety;
begin
 result:= false;
 fna1:= getrtunitfile(aunit^.name);
 if (fna1 <> '') and 
       (tmsefilestream.trycreate(stream1,fna1,fm_read) = sye_ok) then begin    
  try
   resetsegment(seg_unitintf);
   result:= checksegmentdata(stream1,aunit^.filetimestamp) and
                               readsegmentdata(stream1,[seg_unitintf{,seg_op}]);
  finally
   stream1.destroy();
  end;
 end;
end;

end.
