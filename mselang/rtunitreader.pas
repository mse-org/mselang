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
{$goto on}
 
function readunitfile(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 filehandler,segmentutils,msestream,msestrings,msesys,msesystypes,globtypes,
 msearrayutils,elements,sysutils,handlerglob,handlerutils,unithandler;
 
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
 baseoffset: elementoffsetty;
 linksstart,linksend: pointer;
 
 function updateident(var aident: int32): boolean;
 begin
  result:= false;
  if (aident < idmin1) or (aident > idmax1) then begin
   exit;
  end;
  if aident >= 0 then begin
   aident:= names1[aident];
  end
  else begin
   aident:= anons1[-1-aident];
  end;
  result:= true;
 end; //updateident

 function getdata(var source: plenidentty; out dest: identarty): boolean;
 var
  ps,pd,pe: pidentty;
 begin
  result:= false;
  allocuninitedarray(source^.len,sizeof(identty),dest);
  ps:= @source^.data;
  pe:= ps+source^.len;
  if pointer(pe) > poend then begin
   exit;
  end;
  pd:= pointer(dest);
  while ps < pe do begin
   pd^:= ps^;
   if not updateident(int32(pd^)) then begin
    exit;
   end;
   inc(pd);
   inc(ps);
  end;
  source:= pointer(pe);
  result:= true;
 end; //getdata

 function updateref(var ref: elementoffsetty; out path: identty): boolean;
 var
  po1: punitlinkty;
  po2,pe: pidentty;
  po3: pelementinfoty;
 begin
  result:= false;
  if ref >= 0 then begin
   ref:= ref + baseoffset;
   path:= ele.eleinfoabs(ref)^.header.path;
  end
  else begin
   po1:= linksstart - ref - 1;
   if po1 >= linksend then begin
    exit;
   end;
   po2:= @po1^.ids;
   pe:= po2+po1^.len;
   if pe > linksend then begin
    exit;
   end;
   path:= 0;
   while po2 < pe do begin
    if not updateident(int32(po2^)) then begin
     exit;
    end;
    path:= path + po2^;
    inc(po2);
   end;
   po2:= @po1^.ids;
   if not ele.findreverse(po1^.len,po2,ref) then begin
    exit();
   end;
  end;
  result:= true;
 end;
 
var
 interfaceuses1,implementationuses1: identarty;
 pele1: pelementinfoty;
 po: pointer;
 i1: int32;
 startref: markinfoty;
label
 errorlab,oklab;
begin
 result:= false;
 fna1:= getrtunitfile(aunit^.name);
 if (fna1 <> '') and 
       (tmsefilestream.trycreate(stream1,fna1,fm_read) = sye_ok) then begin    
  try
   resetunitsegments();
   result:= checksegmentdata(stream1,getfilekind(mlafk_rtunit),
                                              aunit^.filetimestamp) and
             readsegmentdata(stream1,getfilekind(mlafk_rtunit),
                         [seg_unitintf,seg_unitlinks,seg_unitidents{,seg_op}]);
   if result then begin
    if getsegmentsize(seg_unitintf) < sizeof(unitintfinfoty) then begin
     exit; //invalid
    end;
    linksstart:= getsegmentbase(seg_unitlinks);
    linksend:= linksstart + getsegmentsize(seg_unitlinks);
    po1:= getsegmentbase(seg_unitintf);
    if po1^.header.anoncount < 1 then begin
     exit; //invalid, no parserglob.idstart
    end;
    allocuninitedarray(po1^.header.anoncount,sizeof(identty),anons1);
    pd:= pointer(anons1);
    pe:= pd + length(anons1);
    pd^:= idstart;
    inc(pd);
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
    po3:= @po1^.interfaceuses; //todo: don't read the whole file before loading
                               //uses units
    if not getdata(po3,interfaceuses1) then begin
     exit;
    end;
    for i1:= 0 to high(interfaceuses1) do begin
     loadunitbyid(interfaceuses1[i1]);
    end;
    if not getdata(po3,implementationuses1) then begin
     exit;
    end;
    baseoffset:= ele.eletopoffset;
    i1:= getsegmentsize(seg_unitintf) + 
                        (getsegmentbase(seg_unitintf)-pointer(po3));
//dumpelements();
    ele.markelement(startref);
    pele1:= ele.addbuffer(i1);
    poend:= pointer(pele1) + i1;
    move(po3^,pele1^,i1); //todo: read segment data directly to ele buffer
    while pele1 < poend do begin
     with pele1^ do begin
      if not updateident(int32(header.name)) then begin
       goto errorlab;
      end;
     {$ifdef mse_debugparser}
      inc(header.next,baseoffset);
     {$endif}
      if (header.parentlevel >= maxidentvector) or 
                         (header.parentlevel < 0) then begin
       goto errorlab; //invalid
      end;
      if not updateref(header.parent,header.path) then begin
       goto errorlab;
      end;
      ele.enterbufferitem(pele1); //enter in hash and data table
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
         inc(pointer(pele1),paramcount*sizeof(elementoffsetty));
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
        goto errorlab;
       end;
      end;
      inc(pointer(pele1),elesizes[header.kind]);
     end;     
    end;
    if pele1 = poend then begin //ok
    end;
   end;
   goto oklab;
errorlab:
   ele.releaseelement(startref);
oklab:
//dumpelements();
  finally
   stream1.destroy();
   resetunitsegments();
  end;
  result:= true;
 end;
end;

end.
