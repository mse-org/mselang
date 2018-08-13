{ MSElang Copyright (c) 2015-2018 by Martin Schreiber
   
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
unit unitwriter;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 parserglob,unitglob;
  
function writeunitfile(const aunit: punitinfoty): boolean; //true if ok

implementation
uses
 msetypes,elements,segmentutils,globtypes,errorhandler,msestrings,handlerglob,
 msestream,opglob,compilerunit,mseprocutils,unithandler,
 msefileutils,msesys,msesystypes,filehandler,handlerutils,identutils,
 sysutils,llvmbcwriter,llvmops,elementcache;
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
//  header: identheaderty;
  nameindex: int32;
 end;
 pidentbufferdataty = ^identbufferdataty;
 identbufferhashdataty = record
  header: identhashdataty;
  data: identbufferdataty;
 end;
 
 tidentlist = class(tidenthashdatalist)
  private
  protected
   function getrecordsize(): int32 override;
  public
//   constructor create();
 end;

{ tidentlist }
{
constructor tidentlist.create;
begin
 inherited create(sizeof(identbufferdataty));
end;
}

function tidentlist.getrecordsize(): int32;
begin
 result:= sizeof(identbufferhashdataty);
end;

function putunit(const aunit: punitinfoty): boolean; 
//true if ok
var
 s1,s2: ptrint;
 ps,pd,pe: pelementinfoty;
 identlist: tidentlist;
 po2: punitintfinfoty;
 po: pointer;
 nameindex1,anonindex1: int32;
 elestart,eleend: elementoffsetty;
 deststart: pointer;

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
 end; //updateident()

 procedure putdata(var po: pointer; const adata: unitinfopoarty);
 var
  pd,pe: pusesitemty;
  ps: ppunitinfoty;
 begin
  pint32(po)^:= length(adata);
  pd:= pointer(pint32(po)+1);
  pe:= pd+length(adata);
  ps:= pointer(adata);
  while pd < pe do begin
   with ps^^ do begin
    pd^.id:= updateident(key);
    pd^.reloc:= reloc;
    pd^.filematchx:= filematch;
   end;
   inc(ps);
   inc(pd);
  end;
  po:= pe;
 end; //putdata()

var
 mainparentref: elementoffsetty;

 procedure updateref(var ref: elementoffsetty);
          //>= 0 -> relative offset, -seg_unitlinks offset - 1 otherwise
 var
  po1: punitlinkty;
  po2,pe: pidentty;
  po3: pelementinfoty;
  i1: int32;
 begin
  if ref <> 0 then begin
   if (ref >= elestart) and (ref < eleend) then begin
    ref:= ref - elestart+1;
   end
   else begin //not in streamed segment
    if ref = mainparentref then begin
     ref:= -1;
    end
    else begin
     po1:= checksegmentcapacity(seg_unitlinks,sizeof(unitlinkty) +
                              (maxidentvector+1)*sizeof(identty));
     po2:= @po1^.ids;
     po3:= ele.eleinfoabs(ref);
     if mainparentref = -1 then begin
      mainparentref:= ref;
     {$ifdef mse_checkinternalerror}
      if (po3^.header.kind <> ek_unit) or 
                            (po3^.header.parentlevel <> 2) then begin
       internalerror(ie_module,'20180513A');
      end;
     {$endif}
     end;
     while true do begin
      po2^:= updateident(po3^.header.name);
      inc(po2);
      if po3^.header.parentlevel <= 0 then begin
       break;
      end;
      po3:= ele.eleinfoabs(po3^.header.parent);
     end;
     po1^.len:= po2 - pidentty(@po1^.ids);
     setsegmenttop(seg_unitlinks,po2);
     ref:= -getsegmentoffset(seg_unitlinks,po1)-1;
    end;
   end;
  end;
 end; //updateref()

 procedure puteledata(ps,pd: pelementinfoty; const s1: int32);
 var
  pe: pelementinfoty;
  pe1,pee: pelementoffsetty;
  mop1: managedopty;
  sa1: objsubattachty;
  po: pointer;
 begin
  move(ps^,pd^,s1);
  deststart:= pd;
  pe:= pointer(pd) + s1;
  while pd < pe do begin
   with pd^ do begin
    header.name:= updateident(header.name);
    header.defunit:= pointer(ptrint(header.defunit^.key));
   {$ifdef mse_debugparser}
    dec(header.next,elestart);
   {$endif}
    updateref(header.parent);
    po:= @data;
    case header.kind of
     ek_type: begin
      with ptypedataty(po)^ do begin
       updateref(h.base);
       updateref(h.ancestor);
       case h.kind of
        dk_enum: begin
         updateref(infoenum.first);
         updateref(infoenum.last);
        end;
        dk_enumitem: begin
         updateref(infoenumitem.enum);
         updateref(infoenumitem.next);
        end;
        dk_set: begin
         updateref(infoset.itemtype);
        end;
        dk_array: begin
         updateref(infoarray.i.itemtypedata);
         updateref(infoarray.indextypedata);
        end;
        dk_dynarray,dk_openarray: begin
         updateref(infodynarray.i.itemtypedata);
        end;
        dk_record,dk_class,dk_object: begin
//         if (tf_needsmanage in h.flags) or (h.kind <> dk_record) then begin
         if tf_managehandlervalid in h.flags then begin
          for mop1:= low(mop1) to high(mop1) do begin
           updateref(recordmanagehandlers[mop1]);
          end;
         end;
         updateref(fieldchain);
         case h.kind of
          dk_class,dk_object: begin
           for sa1:= low(infoclass.subattach) to 
                          high(infoclass.subattach) do begin
            updateref(infoclass.subattach[sa1]);
           end;
           updateref(infoclass.subchain);
          end;
         end;
        end;
        dk_sub,dk_method: begin
         updateref(infosub.sub);
        end;
       end;
      end;
     end;
     ek_field: begin
      with pfielddataty(po)^ do begin
       updateref(vf.typ);
       updateref(vf.next);
      end;
     end;
     ek_var: begin
      with pvardataty(po)^ do begin
       updateref(vf.typ);
       updateref(vf.defaultconst);
       updateref(vf.next);
      end;
     end;
     ek_property: begin
      with ppropertydataty(po)^ do begin
       updateref(typ);
       updateref(readele);
       updateref(writeele);
//       updateref(defaultconst);
      end;
     end;
     ek_const: begin
      with pconstdataty(po)^ do begin
      end;
     end;
     ek_ref: begin
      with prefdataty(po)^ do begin
       updateref(ref);
      end;
     end;
     ek_sub: begin
      with psubdataty(po)^ do begin
       updateref(next);
       updateref(nextoverload);
       updateref(typ);
       updateref(resulttype.typeele);
       pe1:= @paramsrel;
       pee:= pe1+paramcount;
       while pointer(pe1) < pointer(pee) do begin
        updateref(pe1^);
        inc(pe1);
       end;
       inc(pointer(pd),paramcount*sizeof(elementoffsetty));
      end;
     end;
     ek_unit: begin
     end;
     ek_uses: begin
     end;
     ek_implementation: begin
      with pimplementationdataty(po)^ do begin
      end;
     end;
     ek_classintfnamenode: begin
      with pclassintfnamenodedataty(po)^ do begin
      end;
     end;
     ek_classintftypenode: begin
      with pclassintftypenodedataty(po)^ do begin
      end;
     end;
     ek_classimpnode: begin
      with pclassimpnodedataty(po)^ do begin
      end;
     end;
     ek_internalsub: begin
      with pinternalsubdataty(po)^ do begin
      end;
     end;
     ek_alias: begin
      with paliasdataty(po)^ do begin
      end;
     end;
     ek_operator: begin
      with poperatordataty(po)^ do begin
       updateref(methodele);
      end;
     end;
     ek_condition: begin
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
 end; //puteledata()

begin
 result:= false;
{
 if info.modularllvm then begin
  aunit^.globidbasex:= info.globidcountx;
  aunit^.reloc.globidcountx:= aunit^.nameid - aunit^.globidbasex;
  info.globidcountx:= info.globidcountx + aunit^.reloc.globidcountx;
                  //for unique linklist key
 end;
} 
 elestart:= aunit^.interfacestart.bufferref;
 s1:= aunit^.interfaceend.bufferref - aunit^.interfacestart.bufferref;
 eleend:= elestart + s1;
 s2:= 2*sizeof(lenitemty) + 
       (length(aunit^.interfaceuses)+length(aunit^.implementationuses)) * 
                                                            sizeof(usesitemty);
 resetunitsegments();
 
 po2:= allocsegmentpo(seg_unitintf,sizeof(unitintfheaderty)+s1+s2);
 nameindex1:= 0;
 anonindex1:= -1;
 mainparentref:= -1;
 identlist:= tidentlist.create;
 try
  updateident(idstart);
  with po2^ do begin
   header.key:= updateident(aunit^.key);
   header.mainad:= aunit^.mainad; //todo: relocate
   header.reloc:= aunit^.reloc;
   header.implementationglobstart:= aunit^.implementationglobstart;
   header.implementationglobsize:= aunit^.implementationglobsize;
   po:= @interfaceuses;
   putdata(po,{pdi,}aunit^.interfaceuses);
   putdata(po,{pdi,}aunit^.implementationuses);
   pd:= po;
  end;
  ps:= ele.eleinfoabs(elestart);
  puteledata(ps,pd,s1);
  with po2^.header do begin
   filematch:= aunit^.filematch;
   namecount:= nameindex1;
   anoncount:= -anonindex1 - 1;
   internalsubnames:= aunit^.internalsubnames;
  end;
  result:= true;
{$ifdef mse_debugparser}
  with po2^.header,reloc do begin
   writeln('** write unit '+aunit^.namestring,
//          ' intfb:',interfaceglobstart,' intfs:',interfaceglobsize,
          ' implb:',implementationglobstart,' impls:',implementationglobsize);
  end;
{$endif}
 finally
  identlist.destroy();
 end;
end;

function compileobjmodule(const aunit: punitinfoty): boolean; //true if ok
//todo: use threads for multicore systems
var
 fna1,fna1no: filenamety;
 fna2: filenamety;
label
 errlab1;
begin
 result:= false;
 if aunit^.bcfilepath = '' then begin
  internalerror1(ie_unit,'20180424A');
 end;
 fna1:= tosysfilepath(aunit^.bcfilepath);
 fna1no:= fna1;
 with info.buildoptions do begin
  if co_compilefileinfo in info.o.compileoptions then begin
   write(fna1+' ');
  end;
  if llvmoptcommand <> '' then begin
   if co_compilefileinfo in info.o.compileoptions then begin
    write('llvm-opt ');
   end;
   fna1:= fna1 + '.opt';
   result:= execwaitmse(llvmoptcommand+' -o '+fna1+' '+fna1no) = 0;
   deletetempfile(fna1no);
   if not result then begin
    goto errlab1;
   end;
  end;
  fna2:= tosysfilepath(replacefileext(aunit^.bcfilepath,'s'));
  aunit^.objfilepath:= getobjunitfilename(aunit^.filepath);
  if co_compilefileinfo in info.o.compileoptions then begin
   write('llc ');
  end;
  result:= execwaitmse(llccommand+' -o '+fna2+' '+fna1) = 0;
  if result then begin
   if co_compilefileinfo in info.o.compileoptions then begin
    write('as');
   end;
   result:= execwaitmse(ascommand+' -o '+
                    tosysfilepath(aunit^.objfilepath)+' '+ fna2) = 0;
  end;
  deletetempfile(fna2); 
errlab1:
  if co_compilefileinfo in info.o.compileoptions then begin
   writeln;
  end;
  deletetempfile(fna1); 
 end;
end;

function writeunitfile(const aunit: punitinfoty): boolean; //true if ok
var
// stat1: subsegmentstatety;
 stream1: tmsefilestream;
 fna1: filenamety;
 llvmout1: tllvmbcwriter = nil;
 segs1: segmentsty;
 ps1: psubdataty;
 sub1: compilersubty;
 cu1: compilerunitty;

begin
 result:= putunit(aunit);
 if result then begin
  fna1:= getcompunitfilename(aunit^.filepath);
  if tmsefilestream.trycreate(stream1,fna1,fm_create) = sye_ok then begin
   try
    aunit^.rtfilepath:= fna1;
    segs1:= [seg_unitintf,seg_unitidents,seg_unitlinks,seg_op];
    if co_llvm in info.o.compileoptions then begin
     segs1:= segs1 - [seg_op,seg_classdef];
    end;
//    stat1:= setsubsegment(aunit^.opseg,-startupoffset);
//    opsegstart:= stat1.state.data;
    writesegmentdata(stream1,getfilekind(mlafk_rtunit),segs1,
                                                     aunit^.filematch.timestamp);
                               //todo: complete
   {$ifdef mse_debugparser}
    writeln('   '+fna1);
   {$endif}
   finally
    stream1.destroy();
   end;
   if co_llvm in info.o.compileoptions then begin
   {
    if info.modularllvm then begin
     for cu1:= succ(low(cu1)) to high(cu1) do begin
      with compilerunitdefs[cu1] do begin
       if name <> aunit^.namestring then begin
        for sub1:= first to last do begin
         if compilersubs[sub1] <> 0 then begin
          ps1:= ele.eledataabs(compilersubs[sub1]);
          compilersubids[sub1]:= 
                     info.s.unitinfo^.llvmlists.globlist.addsubvalue(ps1,true);
         end;
        end;
       end
       else begin
        for sub1:= first to last do begin
         if compilersubs[sub1] <> 0 then begin
          ps1:= ele.eledataabs(compilersubs[sub1]);
          compilersubids[sub1]:= ps1^.globid;
         end;
        end;
       end;
      end;
     end;
    end;
   }
    fna1:= getbcunitfilename(aunit^.rtfilepath);
    result:= tllvmbcwriter.trycreate(
                            tmsefilestream(llvmout1),fna1,fm_create) = sye_ok;
   {$ifdef mse_debugparser}
    writeln('   '+fna1);
   {$endif}
    if result then begin
     aunit^.bcfilepath:= fna1;
     try
      llvmops.run(llvmout1,info.unitlevel = 1,aunit^.mainfini,aunit^.opseg);
     finally
      llvmout1.free();
      if co_llvm in info.o.compileoptions then begin
       freebuffer(info.s.unitinfo^.segments[seg_classdef]); //not used anymore
      end;
     end;
    end
    else begin
     filewriteerror(fna1);
    end;
   end;
//   restoresubsegment(stat1);
   if info.modularllvm then begin
    resetsegment(seg_op);
    info.opcount:= 0;
   {
    setsegmenttop(seg_op,aunit^.opseg.start);
    info.opcount:= aunit^.opstart;
   }
    if result and (co_objmodules in info.o.compileoptions) then begin
     result:= compileobjmodule(aunit);
    {$ifdef mse_debugparser}
     if result then begin
      writeln('   '+aunit^.objfilepath);
     end;
    {$endif}
    end;
   end;
  end
  else begin
   filewriteerror(fna1);
  end;
 end;
 resetunitsegments();
end;

end.
