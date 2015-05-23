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
unit rtunitwriter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
 
function writertunit(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 elements,segmentutils,globtypes,errorhandler,msestrings;
{
type
 unitrecheaderty = record
  kind: elementkindty;
  size: int32;
 end;
 punitrecheaderty = ^unitrecheaderty;
 
 unitrecty = record
  header: unitrecheaderty;
  data: record
  end;
 end;
 punitrecty = ^unitrecty;
} 

type
 identstringty = packed record
  len: byte;
  data: record //max 255 characters
  end;
 end;
 pidentstringty = ^identstringty;
 
 identbufferdataty = record
  header: identheaderty;
  nameindex: int32;
 end;
 pidentbufferdataty = ^identbufferdataty;
 
 tidentlist = class(tidenthashdatalist)
  private
  public
   constructor create();
 end;

{ tidentlist }

constructor tidentlist.create;
begin
 inherited create(sizeof(identbufferdataty));
end;
 
function writertunit(const aunit: punitinfoty): boolean; //true if ok
var
 s1: ptrint;
 ps,pd,pe: pelementinfoty;
 identlist: tidentlist;
 po1: pidentbufferdataty;
 nameindex1: int32;
 lstr1: lstringty;
begin
 result:= false;
 ps:= ele.eleinfoabs(aunit^.interfacestart.bufferref);
 s1:= aunit^.implementationstart.bufferref - aunit^.interfacestart.bufferref;
 pd:= allocsegmentpo(seg_unitintf,s1);
 move(ps^,pd^,s1);
 identlist:= tidentlist.create;
 try
  pe:= pointer(pd) + s1;
  nameindex1:= 0;
  while pd < pe do begin
   with pd^ do begin
    if identlist.adduniquedata(header.name,po1) then begin
     if getidentname(header.name,lstr1) then begin
      with pidentstringty(allocsegmentpo(seg_unitidents,lstr1.len+1))^ do begin
       len:= lstr1.len;
       move(lstr1.po^,data,lstr1.len);
      end;
      po1^.nameindex:= nameindex1;
      inc(nameindex1);
     end
     else begin
      po1^.nameindex:= -1;
     end;
    end;
    case pd^.header.kind of
     ek_var: begin
     end
     else begin
      internalerror1(ie_module,'20150523A');
     end;
    end;
    inc(pointer(pd),elesizes[header.kind]);
   end;
  end;
  result:= true;
 finally
  identlist.destroy();
 end;
end;

end.
