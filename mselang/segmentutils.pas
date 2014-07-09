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
unit segmentutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob,msetypes;
 
type
 segmentty = (seg_globvar,seg_locvar,seg_globconst,seg_op);

function getsegmentaddress(const asegment: segmentty;
                                    const asize: integer): dataoffsty;
function getsegmentpo(const asegment: segmentty;
                                    const aoffset: dataoffsty): pointer;
procedure init();
procedure deinit();

implementation
type
 segmentinfoty = record
  count: integer;
  capacity: integer;
  data: bytearty;
 end;
 
var
 segments: array[segmentty] of segmentinfoty;
 
procedure init();
begin
end;

procedure deinit();
begin
end;

function getsegmentaddress(const asegment: segmentty;
                                    const asize: integer): dataoffsty;
begin
end;

function getsegmentpo(const asegment: segmentty;
                                    const aoffset: dataoffsty): pointer;
begin
end;

end.
