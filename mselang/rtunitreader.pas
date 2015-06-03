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
 parserglob,rtunitglob;
 
function readunitfile(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 filehandler,segmentutils,msestream,msestrings,msesys,msesystypes,globtypes,
 msearrayutils,elements,sysutils;
 
function readunitfile(const aunit: punitinfoty): boolean; //true if ok
var
 stream1: tmsefilestream;
 fna1: filenamety;
 po1: punitintfinfoty;
 names1,anons1: identarty;
 pd,pe: pint32;
 ns,ne: pchar;
 poend: pointer;
 po3: plenidentty;
 idmin1,idmax1: int32;
 
 procedure updateident(var aident: int32);
 begin
  if (aident < idmin1) or (aident > idmax1) then begin
   abort();
  end;
  if aident >= 0 then begin
   aident:= names1[aident];
  end
  else begin
   aident:= anons1[1-aident];
  end;
 end; //updateident

 procedure getdata(var source: plenidentty; out dest: identarty);
 var
  ps,pd,pe: pidentty;
 begin
  allocuninitedarray(source^.len,sizeof(identty),dest);
  ps:= @source^.data;
  pe:= ps+source^.len;
  if pointer(pe) > poend then begin
   abort();
  end;
  pd:= pointer(dest);
  while ps < pe do begin
   pd^:= ps^;
   updateident(int32(pd^));
   inc(pd);
   inc(ps);
  end;
  source:= pointer(pe);
 end; //getdata

var
 interfaceuses1,implementationuses1: identarty;
begin
 result:= false;
 fna1:= getrtunitfile(aunit^.name);
 if (fna1 <> '') and 
       (tmsefilestream.trycreate(stream1,fna1,fm_read) = sye_ok) then begin    
  try
   try
    resetsegment(seg_unitintf);
    resetsegment(seg_unitidents);
    result:= checksegmentdata(stream1,aunit^.filetimestamp) and
              readsegmentdata(stream1,[seg_unitintf,seg_unitidents{,seg_op}]);
    if result then begin
     if getsegmentsize(seg_unitintf) < sizeof(unitintfinfoty) then begin
      exit; //invalid
     end;
     po1:= getsegmentbase(seg_unitintf);
     allocuninitedarray(po1^.header.anoncount,sizeof(identty),anons1);
     pd:= pointer(anons1);
     pe:= pd + length(anons1);
     while pd < pe do begin
      pd^:= getident();
      inc(pd);
     end;
     allocuninitedarray(po1^.header.namecount,sizeof(identty),names1);
     pd:= pointer(names1);
     pe:= pd + length(names1);
     ne:= getsegmentbase(seg_unitidents);
     poend:= pointer(ne) + getsegmentsize(seg_unitidents);     
     while pd < pe do begin
      ns:= @pidentstringty(ne)^.data;
      ne:= ns + pidentstringty(ne)^.len;
      if ne > poend then begin
       exit; //invalid
      end;
      pd^:= getident(ns,ne);
      inc(pd);
     end;
     idmin1:= -length(anons1);
     idmax1:= high(names1);
     po3:= @po1^.interfaceuses;
     getdata(po3,interfaceuses1);
     getdata(po3,implementationuses1);
    end;
   finally
    stream1.destroy();
    resetsegment(seg_unitintf);
    resetsegment(seg_unitidents);
   end;
  except
  end;
 end;
end;

end.
