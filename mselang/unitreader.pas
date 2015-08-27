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
unit unitreader;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob,unitglob;
{$goto on}
 
function readunitfile(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 filehandler,segmentutils,msestream,msestrings,msesys,msesystypes,globtypes,
 msearrayutils,elements,sysutils,handlerglob,handlerutils,unithandler,
 identutils,opglob,opcode,errorhandler;

type
 relocinfoty = record
  base: targetadty; //first!
  offset: targetoffsty;
  size: targetsizety;
 end;
 prelocinfoty = ^relocinfoty;
 relocinfoarty = array of relocinfoty;
  
{$if sizeof(targetadty) = 4}
function cmpreloc(const l,r): integer;
begin
 result:= relocinfoty(l).base-relocinfoty(r).base;
end;
{$endif}
{
function reloc(const list: relocinfoarty; var ad: targetadty): boolean;
                 //list <> nil
var
 ilo,ihi,i1: int32;
begin
 result:= false;
 ilo:= 0;
 ihi:= high(list);
 while ilo <= ihi do begin
  i1:= (ilo+ihi+1) div 2;
  with list[i1] do begin
   if ad >= base then begin
    ilo:= i1;
    if ihi = ilo then begin
     break;
    end;
   end
   else begin
    ihi:= i1-1;
   end;
  end;
 end;
 if (ihi >= 0) then begin
  with list[ihi] do begin
   result:= ad < base + size;
   ad:= ad + offset;
  end;
 end;
end;
}
procedure reloc(const list: relocinfoarty; var ad: targetadty);
                 //list <> nil
var
 ilo,ihi,i1: int32;
begin
 ilo:= 0;
 ihi:= high(list);
 while ilo <= ihi do begin
  i1:= (ilo+ihi+1) div 2;
  with list[i1] do begin
   if ad >= base then begin
    ilo:= i1;
    if ihi = ilo then begin
     break;
    end;
   end
   else begin
    ihi:= i1-1;
   end;
  end;
 end;
 if (ihi >= 0) then begin
  with list[ihi] do begin
   if ad < base + size then begin
    ad:= ad + offset;
   end;
  end;
 end;
end;

function readunitfile(const aunit: punitinfoty): boolean; //true if ok
var
 names1,anons1: identarty;
 pd,pe: pint32;
 ns,ne: pchar;
 poend: pointer;
 po3: plenitemty;
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

 function getdata(var source: plenitemty; out dest: usesitemarty): boolean;
 var
  ps,pd,pe: pusesitemty;
 begin
  result:= false;
  allocuninitedarray(source^.len,sizeof(usesitemty),dest);
  ps:= @source^.data;
  pe:= ps+source^.len;
  if pointer(pe) > poend then begin
   exit;
  end;
  pd:= pointer(dest);
  while ps < pe do begin
   pd^:= ps^;
   if not updateident(int32(pd^.id)) then begin
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

type
 relocinfoarty = array of relocinfoty;

 function dosort(var ar: relocinfoarty): boolean;
 var
  i1: int32;
 begin
  result:= true;
  if ar <> nil then begin
   sortarray(ar,sizeof(ar[0]),@cmpreloc);
   for i1:= 0 to high(ar) - 1 do begin
    with ar[i1] do begin
     if base + size > ar[i1+1].base then begin
      result:= false;
      break;
     end;
    end;
   end;
  end;
 end;

 procedure addrelocitem(const abase: targetadty; const aref: targetadty;
                            const asize: targetadty; 
                                 var alist: relocinfoarty; var acount: int32);
 begin
  with alist[acount] do begin
   offset:= aref-abase;
   if offset <> 0 then begin
    size:= asize;
    base:= abase;
    inc(acount);
   end;
  end;
 end;

var
 globreloc1: relocinfoarty;
 opreloc1: relocinfoarty;
 elereloc1: relocinfoarty;
 globvarreloccount: int32;
 opreloccount: int32;
 elereloccount: int32;

 procedure addrelocs(const aunit: punitinfoty; const auses: unitrelocty);
 begin
  with auses do begin
   addrelocitem(interfaceglobstart,
        aunit^.reloc.interfaceglobstart,aunit^.reloc.interfaceglobsize,
        globreloc1,globvarreloccount);
   addrelocitem(opstart,
        aunit^.reloc.opstart,aunit^.reloc.opsize,
        opreloc1,opreloccount);
  end;
 end;
 
var
 stream1: tmsefilestream;
 fna1: filenamety;
 intf: punitintfinfoty;
 interfaceuses1,implementationuses1: usesitemarty;
 interfaceunits1: unitinfopoarty;
 pele1: pelementinfoty;
 po: pointer;
 i1,i2: int32;
 startref: markinfoty;
 unitsegments1: unitsegmentsstatety;
 segstate1: segmentstatety;
// globpobefore: targetcardty;
 haselereloc: boolean;
 unit1: punitinfoty;
// needsreloc: boolean;
 globvaroffset: elementoffsetty;
 opoffset: targetoffsty;
 op1,ope: popinfoty;
 isub1: internalsubty;
 selfident: int32;
 
label
 errorlab,oklab,endlab;
begin
 result:= false;
 fna1:= getrtunitfile(aunit);
{$ifdef mse_debugparser}
 writeln('***** reading unit '+fna1);
{$endif}
 if (fna1 <> '') and 
       (tmsefilestream.trycreate(stream1,fna1,fm_read) = sye_ok) then begin   
  try
//   globpobefore:= info.globdatapo;
   resetunitsegments();
   result:= checksegmentdata(stream1,getfilekind(mlafk_rtunit),
                                              aunit^.filetimestamp) and
             readsegmentdata(stream1,getfilekind(mlafk_rtunit),
                         [seg_unitintf,seg_unitlinks,seg_unitidents]);
   if result then begin
    result:= false;
    if getsegmentsize(seg_unitintf) < sizeof(unitintfinfoty) then begin
     goto endlab; //invalid
    end;
    linksstart:= getsegmentbase(seg_unitlinks);
    linksend:= linksstart + getsegmentsize(seg_unitlinks);
    intf:= getsegmentbase(seg_unitintf);
    if intf^.header.anoncount < 1 then begin
     goto endlab; //invalid, no parserglob.idstart
    end;
    allocuninitedarray(intf^.header.anoncount,sizeof(identty),anons1);
    pd:= pointer(anons1);
    pe:= pd + length(anons1);
    pd^:= idstart;
    inc(pd);
    while pd < pe do begin
     pd^:= getident();
     inc(pd);
    end;
    allocuninitedarray(intf^.header.namecount,sizeof(identty),names1);
    pd:= pointer(names1);
    pe:= pd + length(names1);
    ne:= getsegmentbase(seg_unitidents);
    poend:= pointer(ne) + getsegmentsize(seg_unitidents);     
    while pd < pe do begin
     ns:= @pidentstringty(ne)^.data;
     ne:= ns + pidentstringty(ne)^.len;
     if ne > poend then begin
      goto endlab; //invalid
     end;
     pd^:= getident(ns,ne);
     inc(pd);
    end;
    idmin1:= -length(anons1);
    idmax1:= high(names1);
    po3:= @intf^.interfaceuses;
    poend:= getsegmenttop(seg_unitintf);
    if not getdata(po3,interfaceuses1) or
                              not getdata(po3,implementationuses1) then begin
     goto endlab;
    end;
    setlength(globreloc1,length(interfaceuses1)+length(implementationuses1)+3);
         //max, + own interface and implementation globvar block,
         //exitcode todo: remove this
    setlength(opreloc1,length(globreloc1)); //max
    setlength(elereloc1,length(globreloc1)); //max
    globvarreloccount:= 0;
    opreloccount:= 0;
    elereloccount:= 0;

    include(aunit^.state,us_interfaceparsed);
    saveunitsegments(unitsegments1);
    setlength(interfaceunits1,length(interfaceuses1));
    for i1:= 0 to high(interfaceuses1) do begin
     unit1:= loadunitbyid(interfaceuses1[i1].id);
     interfaceunits1[i1]:= unit1;
     with interfaceuses1[i1] do begin
      if (unit1 = nil) or (unit1^.filetimestamp <> filetimestamp) or
       (unit1^.reloc.interfaceglobsize <> reloc.interfaceglobsize) or 
       (unit1^.reloc.opsize <> reloc.opsize) then begin
       restoreunitsegments(unitsegments1);
       goto endlab;
      end;
     end;
     addrelocs(unit1,interfaceuses1[i1].reloc);
    end;
    for i1:= 0 to high(implementationuses1) do begin
     with implementationuses1[i1] do begin
      if getunittimestamp(id) <> filetimestamp then begin
       goto endlab; //needs recompilation
      end;
     end;
    end;
    restoreunitsegments(unitsegments1);

    inc(info.globdatapo,intf^.header.reloc.interfaceglobsize); 

    ele.markelement(startref);
    selfident:= int32(ptrint(intf^.header.key));
    if not updateident(int32(ptrint(intf^.header.key))) then begin
     goto errorlab;
    end;
    beginunit(intf^.header.key,true);

    baseoffset:= ele.eletopoffset;

    aunit^.reloc:= intf^.header.reloc;
    aunit^.reloc.interfaceglobstart:= info.globdatapo;
    aunit^.reloc.interfaceelestart:= baseoffset;
    with intf^.header.reloc do begin       
     addrelocitem(interfaceglobstart,info.globdatapo,interfaceglobsize,
                                                 globreloc1,globvarreloccount);
                                                 //own interface globvars
     globvaroffset:= info.globdatapo-interfaceglobstart;
     addrelocitem(interfaceelestart,aunit^.reloc.interfaceelestart,
                   interfaceelesize,elereloc1,elereloccount);
                                                 //own interface elements
    end;
    for i1:= 0 to high(interfaceunits1) do begin
     with interfaceunits1[i1]^ do begin
      addrelocitem(interfaceuses1[i1].reloc.interfaceelestart,
           reloc.interfaceelestart,reloc.interfaceelesize,
           elereloc1,elereloccount);
     end;
    end;
    setlength(elereloc1,elereloccount);
    haselereloc:= elereloc1 <> nil;
    if not dosort(elereloc1) then begin
     goto errorlab;
    end;
    i1:= getsegmentsize(seg_unitintf) + 
                        (getsegmentbase(seg_unitintf)-pointer(po3));
    pele1:= ele.addbuffer(i1);
    poend:= pointer(pele1) + i1;
    move(po3^,pele1^,i1); //todo: read segment data directly to ele buffer
    while pele1 < poend do begin
     with pele1^ do begin
      if not updateident(int32(header.name)) then begin
       goto errorlab;
      end;
      if int32(ptrint(ptruint(header.defunit))) = selfident then begin
       header.defunit:= aunit;
      end
      else begin
//      tz etrz e6ru e6ue6t
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
         if haselereloc then begin
          reloc(elereloc1,targetadty(vf.typ)); //todo: 64 bit
         end;
         if af_segment in address.flags then begin
          inc(address.segaddress.address,globvaroffset);
         end;
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
       ek_uses: begin
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
    if pele1 <> poend then begin
     goto errorlab;
    end;

    saveunitsegments(unitsegments1);
    for i1:= 0 to high(implementationuses1) do begin
     unit1:= loadunitbyid(implementationuses1[i1].id);
     with implementationuses1[i1] do begin
      if (unit1 = nil) or (unit1^.filetimestamp <> filetimestamp) or
         (unit1^.reloc.interfaceglobsize <> reloc.interfaceglobsize) or
                          (unit1^.reloc.opsize <> reloc.opsize) then begin
       restoreunitsegments(unitsegments1);
                   //todo: try restart instead of fatal error
       if unit1 <> nil then begin
        errormessage(err_invalidunitfile,[unit1^.filepath]);
       end
       else begin
        errormessage(err_invalidunitfile,
                                    [getidentname(implementationuses1[i1].id)]);
       end;
       goto errorlab;
      end;
     end;
     addrelocs(unit1,implementationuses1[i1].reloc);
    end;
    restoreunitsegments(unitsegments1);
    aunit^.implementationglobstart:= info.globdatapo;
    with intf^.header do begin            
     addrelocitem(implementationglobstart,info.globdatapo,
                          implementationglobsize,globreloc1,globvarreloccount);
                                      //own implementation globvars
     addrelocitem(reloc.opstart,info.opcount,reloc.opsize,
                                                    opreloc1,opreloccount);
                                      //own op segment
     opoffset:= info.opcount-reloc.opstart;
     aunit^.internalsubs:= internalsubs;
    end;
    setlength(globreloc1,globvarreloccount);
    setlength(opreloc1,opreloccount);
    aunit^.implementationglobsize:= intf^.header.implementationglobsize;
    inc(info.globdatapo,intf^.header.implementationglobsize);
    if not dosort(globreloc1) or not dosort(opreloc1) then begin
     goto errorlab;
    end;
    goto oklab;
errorlab:
    ele.releaseelement(startref);
    goto endlab;
oklab:
    with aunit^ do begin
     mainad:= intf^.header.mainad + opoffset;
     for isub1:= low(internalsubs) to high(internalsubs) do begin
      if internalsubs[isub1] <> 0 then begin
       inc(internalsubs[isub1],opoffset);
      end;
     end;
    end;
    stream1.position:= 0;           //todo: reduce file seeking
    segstate1:= savesegment(seg_op);
    op1:= getsegmenttop(seg_op);
    result:= readsegmentdata(stream1,getfilekind(mlafk_rtunit),[seg_op]);
    if (globreloc1 <> nil) and result then begin
     pointer(op1):= pointer(op1)+(getsegmentbase(seg_op)-segstate1.data);
     ope:= getsegmenttop(seg_op);
     while op1 < ope do begin
      with optable^[op1^.op.op] do begin
       if of_relocseg in flags then begin
        reloc(globreloc1,targetadty(op1^.par.memop.segdataaddress.a.address));
       end;
      end;
      inc(op1);
     end;
    end;
    if result then begin
     inc(info.opcount,intf^.header.reloc.opsize);
    end
    else begin
     restoresegment(segstate1);
    end;
endlab:
   end;
  except //catch all exceptions of an invalid unit file
  end;
  stream1.destroy();
  resetunitsegments();
  if not result then begin
//   info.globdatapo:= globpobefore; not possible because of uses modules
   exclude(aunit^.state,us_interfaceparsed);
  end;
 end;
{$ifdef mse_debugparser}
 if result then begin
  writeln('** read unit '+fna1+' OK');
 end
 else begin
  writeln('** read unit '+fna1+' ***ERROR***');
 end;
{$endif}
 end;

end.
