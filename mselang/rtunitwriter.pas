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
 parserglob,rtunitglob;
  
function putunitintf(const aunit: punitinfoty): boolean; //true if ok
function writeunitfile(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 elements,segmentutils,globtypes,errorhandler,msestrings,handlerglob,msestream,
 msefileutils,msesys,msesystypes,filehandler,handlerutils;
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
 
function putunitintf(const aunit: punitinfoty): boolean; //true if ok
var
 s1,s2: ptrint;
 ps,pd,pe: pelementinfoty;
 identlist: tidentlist;
 po2: punitintfinfoty;
 po: pointer;
 nameindex1,anonindex1: int32;
 baseoffset: elementoffsetty;

 function updateident(const aident: identty): identty;
 var
  po1: pidentbufferdataty;
  lstr1: lstringty;
 begin
  if identlist.adduniquedata(aident,po1) then begin
   if getidentname(aident,lstr1) then begin
    with pidentstringty(allocsegmentpounaligned(seg_unitidents,
                       lstr1.len + sizeof(identstringty)))^ do begin
     len:= lstr1.len;
     move(lstr1.po^,data,lstr1.len);
    end;
    po1^.nameindex:= nameindex1;
    inc(nameindex1);
   end
   else begin
    po1^.nameindex:= anonindex1;
    dec(anonindex1);
   end;
  end;
  result:= po1^.nameindex;
 end; //updateident

 procedure putdata(var po: pointer; const adata: unitinfopoarty);
 var
  pd,pe: pidentty;
  ps: ppunitinfoty;
 begin
  pint32(po)^:= length(adata);
  pd:= pointer(pint32(po)+1);
  pe:= pd+length(adata);
  ps:= pointer(adata);
  while pd < pe do begin
   pd^:= updateident(ps^^.key);
   inc(ps);
   inc(pd);
  end;
  po:= pe;
 end; //putdata

begin
//dumpelements();
 result:= false;
 baseoffset:= aunit^.interfacestart.bufferref;
 s1:= aunit^.implementationstart.bufferref - aunit^.interfacestart.bufferref;
 s2:= 2*sizeof(lenidentty) + 
       (length(aunit^.interfaceuses)+length(aunit^.implementationuses)) * 
                                                               sizeof(identty);
 resetsegment(seg_unitintf);
 resetsegment(seg_unitidents);
 po2:= allocsegmentpo(seg_unitintf,sizeof(unitintfheaderty)+s1+s2);
 nameindex1:= 0;
 anonindex1:= -1;
 identlist:= tidentlist.create;
 try
  with po2^ do begin
   po:= @interfaceuses;
   putdata(po,aunit^.interfaceuses);
   putdata(po,aunit^.implementationuses);
   pd:= po;
  end;
  ps:= ele.eleinfoabs(baseoffset);
  move(ps^,pd^,s1);
  pe:= pointer(pd) + s1;
  while pd < pe do begin
   with pd^ do begin
    header.name:= updateident(header.name);
    po:= @data;
    case header.kind of
     ek_type: begin
      with ptypedataty(po)^ do begin
      end;
     end;
     ek_field: begin
      with pfielddataty(po)^ do begin
      end;
     end;
     ek_var: begin
      with pvardataty(po)^ do begin
      end;
     end;
     ek_const: begin
      with pconstdataty(po)^ do begin
      end;
     end;
     ek_ref: begin
      with prefdataty(po)^ do begin
      end;
     end;
     ek_sub: begin
      with psubdataty(po)^ do begin
       inc(pointer(pd),paramcount*sizeof(elementoffsetty));
      end;
     end;
     ek_unit: begin
     end;
     ek_implementation: begin
      with pimplementationdataty(po)^ do begin
      end;
     end;
     ek_none: begin
     end;
     else begin
      internalerror1(ie_module,'20150523A');
     end;
    end;
    inc(pointer(pd),elesizes[header.kind]);
   end;
  end;
  with po2^.header do begin
   sourcetimestamp:= aunit^.filetimestamp;
   namecount:= nameindex1;
   anoncount:= -anonindex1 - 1;
  end;
  result:= true;
 finally
  identlist.destroy();
 end;
end;

function writeunitfile(const aunit: punitinfoty): boolean; //true if ok
var
 stat1: segmentstatety;
 stream1: tmsefilestream;
 fna1: filenamety;
begin
 result:= false;
 fna1:= getrtunitfilename(aunit^.filepath);
 if tmsefilestream.trycreate(stream1,fna1,fm_create) = sye_ok then begin
  stat1:= setsubsegment(aunit^.opseg);
  try
   writesegmentdata(stream1,[seg_unitintf,seg_unitidents,seg_op],
                                                   aunit^.filetimestamp);
                              //todo: complete 
  finally
   setsegment(stat1);
   stream1.destroy();
  end;
 end
 else begin
  filewriteerror(fna1);
 end;
end;

end.
