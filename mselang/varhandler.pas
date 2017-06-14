{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
unit varhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 globtypes,parserglob;
 
const 
 pointervarkinds = [dk_class,dk_interface];
 
procedure handlevardefstart();
procedure handlevar3();
procedure handlepointervar();

procedure handletypedconst2entry();
procedure handletypedconst();
procedure handletypedconstarraylevelentry();
procedure handletypedconstarraylevel();
procedure handletypedconstarrayitem();
procedure handletypedconstarray();

implementation
uses
 handlerutils,elements,errorhandler,handlerglob,opcode,llvmlists,segmentutils,
 identutils,msestrings,gramse,grapas,parser,valuehandler,mseformatstr,
 msetypes,llvmbitcodes;
 
procedure handlevardefstart();
begin
{$ifdef mse_debugparser}
 outhandle('VARDEFSTART');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_var;
  d.vari.indirectlevel:= 0;
//  d.vari.flags:= [];
 end;
end;

procedure handlevar3();
var
 po1: pvardataty;
 po2: pelementinfoty;
 po3: pelementoffsetty;
 datasize1: databitsizety;
 size1: integer;
 ident1: identty;
 ele1: elementoffsetty;
 bo1: boolean;
 i1: int32;
 n1: identnamety;
begin
{$ifdef mse_debugparser}
 outhandle('VAR3');
{$endif}
 with info do begin
  if (s.stacktop-s.stackindex < 3) or 
            (contextstack[s.stacktop].d.kind <> ck_fieldtype) or
                       (contextstack[s.stacktop].d.typ.typedata = 0) then begin
   exit; //type not found
  end;
  for i1:= s.stackindex+2 to s.stacktop - 1 do begin
 {$ifdef mse_checkinternalerror}
   if contextstack[i1].d.kind <> ck_ident then begin
    internalerror(ie_handler,'20150320A0');
   end;
 {$endif}
   ident1:= contextstack[i1].d.ident.ident;
   bo1:= false;
   if (currentcontainer = 0) or not ele.findchild(info.currentcontainer,ident1,
                                                    [],allvisi,ele1) then begin
    if sublevel > 0 then begin
     ele.checkcapacity(elesizes[ek_var]); //no change by addvar
     po3:= @(psubdataty(ele.parentdata)^.varchain);
    end
    else begin
     po3:= @s.unitinfo^.varchain;
    end;
    bo1:= addvar(ident1,allvisi,po3^,po1);
   end;
   if not bo1 then begin //duplicate
    identerror(i1-s.stackindex,err_duplicateidentifier);
   end
   else begin
    with po1^ do begin
     address.flags:= [];
     vf.typ:= contextstack[s.stacktop].d.typ.typedata;
     po2:= ele.eleinfoabs(vf.typ);
     address.indirectlevel:= contextstack[s.stacktop].d.typ.indirectlevel;
     with ptypedataty(@po2^.data)^ do begin
      datasize1:= h.datasize;
      if h.kind in pointervarkinds then begin
       inc(address.indirectlevel);
      end;
      if address.indirectlevel = 0 then begin
       size1:= h.bytesize;
       vf.flags:= vf.flags + 
                   h.flags * [tf_needsmanage,tf_needsini,tf_needsfini];
       if tf_needsmanage in h.flags then begin
        include(s.currentstatementflags,stf_needsmanage);
       end;
       if tf_needsini in h.flags then begin
        include(s.currentstatementflags,stf_needsini);
       end;
       if tf_needsfini in h.flags then begin
        include(s.currentstatementflags,stf_needsfini);
       end;
      end
      else begin
       size1:= pointersize;
      end;
      nameid:= -1;
      if sublevel = 0 then begin //global variable
       if address.indirectlevel > 0 then begin
        datasize1:= das_pointer;
        include(address.flags,af_segmentpo);
       end;
       address.segaddress:= getglobvaraddress(datasize1,size1,address.flags);
       if not (us_implementation in s.unitinfo^.state) then begin
        nameid:= s.unitinfo^.nameid; //for llvm
       end;
       if (info.o.debugoptions*[do_proginfo,do_names] <> []) and 
                          (co_llvm in info.o.compileoptions) then begin
        getidentname(ident1,n1);
        if do_names in info.o.debugoptions then begin

         s.unitinfo^.llvmlists.globlist.namelist.addname(
                                              n1,address.segaddress.address);
        end;
        if do_proginfo in info.o.debugoptions then begin
         s.unitinfo^.llvmlists.globlist.lastitem^.debuginfo:= 
                  s.unitinfo^.llvmlists.metadatalist.adddivariable(
                       nametolstring(n1),contextstack[i1].start.line,0,po1^);
        end;
       end;
      end
      else begin                //local variable
       address.locaddress:= getlocvaraddress(datasize1,size1,address.flags,
                                                                  -frameoffset);
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure handlepointervar();
begin
{$ifdef mse_debugparser}
 outhandle('POINTERVAR');
{$endif}
 with info,contextstack[s.stackindex].d.vari do begin
  if indirectlevel > 0 then begin
   errormessage(err_typeidentexpected,[]);
  end;
  inc(indirectlevel);
 end;
end;

procedure handletypedconst2entry();
var
 p1: ptypedataty;
 cont1: pcontextty;
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDCONST2ENTRY');
{$endif}
 with info do begin
  if currenttypedef <> 0 then begin
   p1:= ele.eledataabs(currenttypedef);
   if p1^.h.indirectlevel = 0 then begin
    cont1:= nil;
    case p1^.h.kind of
     dk_array: begin
      case s.dialect of
       dia_mse: cont1:= @gramse.typedconstarrayco;
       dia_pas: cont1:= @grapas.typedconstarrayco;
       else internalerror1(ie_dialect,'20170612B');
      end;
      with contextstack[s.stackindex] do begin
       d.kind:= ck_arrayconst;
       d.arrayconst.itemtype:= currenttypedef;
       d.arrayconst.datapopo:= @d.arrayconst.datapo;
       d.arrayconst.itemcount:= 0; //dummy
       d.arrayconst.curindex:= 0;
      end;
      s.stacktop:= s.stackindex;
     end;
    end;
    switchcontext(cont1,false);
   end
   else begin
    internalerror1(ie_notimplemented,'20170512A');
    //todo: handle addresses
   end;
  end;
 end;
end;

procedure handletypedconst();
var
 p1: ptypedataty;
 p2: pvardataty;
 p3: pointer;
 datasize1: databitsizety;
 size1: int32;
 ident1: identty;
 n1: identnamety;
 i1: int32;
 linkage1: linkagety;
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDCONST');
{$endif}
 with info do begin
  if (currenttypedef <> 0) then begin
   p1:= ele.eledataabs(currenttypedef);
  {$ifdef mse_checkinternalerror}
   if (s.stacktop <= s.stackindex) or 
          (contextstack[s.stackindex+1].d.kind <> ck_ident) then begin
    internalerror(ie_handler,'20170613C');
   end;
  {$endif}
   if p1^.h.indirectlevel <> 0 then begin
    notimplementederror('20170613D');
   end;   
   ident1:= contextstack[s.stackindex+1].d.ident.ident;
   if tryconvert(@contextstack[s.stacktop],p1,p1^.h.indirectlevel,[]) then begin
    with contextstack[s.stacktop],d.dat.constval do begin
     if d.kind <> ck_const then begin
      errormessage(err_constexpressionexpected,[]);
     end
     else begin
      case p1^.h.kind of
       dk_boolean: begin
       end;
       dk_integer: begin
        case p1^.h.datasize of
         das_8: begin
          with p1^.infoint8 do begin
           if (vinteger < min) or (vinteger > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
         das_16: begin
          with p1^.infoint16 do begin
           if (vinteger < min) or (vinteger > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
         das_32: begin
          with p1^.infoint32 do begin
           if (vinteger < min) or (vinteger > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
         das_64: begin
          with p1^.infoint64 do begin
           if (vinteger < min) or (vinteger > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
        end;
       end;
       dk_cardinal: begin
        case p1^.h.datasize of
         das_8: begin
          with p1^.infocard8 do begin
           if (vcardinal < min) or (vcardinal > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
         das_16: begin
          with p1^.infocard16 do begin
           if (vcardinal < min) or (vcardinal > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
         das_32: begin
          with p1^.infocard32 do begin
           if (vcardinal < min) or (vcardinal > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
         das_64: begin
          with p1^.infocard64 do begin
           if (vcardinal < min) or (vinteger > max) then begin
            errormessage(err_valuerange,[inttostrmse(min),inttostrmse(max)],
                                                        minint,0,erl_warning);
           end;
          end;
         end;
        end;
       end;
       dk_float: begin
        case p1^.h.datasize of
         das_f32: begin
          with p1^.infofloat32 do begin
           if (vfloat < min) or (vfloat > max) then begin
            errormessage(err_valuerange,[realtostrmse(min),
                                realtostrmse(max)],minint,0,erl_warning);
           end;
          end;
         end;
         das_f64: begin
          with p1^.infofloat64 do begin
           if (vfloat < min) or (vfloat > max) then begin
            errormessage(err_valuerange,[realtostrmse(min),
                                realtostrmse(max)],minint,0,erl_warning);
           end;
          end;
         end;
        end;
       end;
       else begin
        notimplementederror('20170613E');
       end;
      end;
      p2:= ele.addelementdata(ident1,ek_var,allvisi);
      if p2 = nil then begin
       identerror(1,err_duplicateidentifier);
      end
      else begin
       with p2^ do begin
        vf.typ:= currenttypedef;
        vf.flags:= p1^.h.flags;
        vf.defaultconst:= 0;
        vf.next:= 0;
        address.indirectlevel:= p1^.h.indirectlevel;
        nameid:= -1;
        datasize1:= p1^.h.datasize;
        if address.indirectlevel > 0 then begin
         datasize1:= das_pointer;
         include(address.flags,af_segmentpo);
         size1:= pointersize;
        end
        else begin
         size1:= p1^.h.bytesize;
        end;
        address.flags:= [af_segment,af_const];
        if datasize1 = das_none then begin
         include(address.flags,af_aggregate);
        end;
        if co_llvm in info.o.compileoptions then begin
         with contextstack[s.stacktop],d.dat.constval do begin
          case datasize1 of
           das_1: begin
            i1:= info.s.unitinfo^.llvmlists.constlist.addi1(vboolean).listid;
           end;
           das_8: begin
            i1:= info.s.unitinfo^.llvmlists.constlist.addi8(vinteger).listid;
           end;
           else begin
            internalerror(ie_handler,'20170614A');
           end;
          end;
         end;
         if sublevel > 0 then begin
          linkage1:= li_internal;
         end
         else begin
          linkage1:= info.s.globlinkage;
         end;
         address.segaddress.address:=
            info.s.unitinfo^.llvmlists.globlist.addinitvalue(
                                                 gak_const,i1,linkage1);
         
  {
         if datasize1 = das_none then begin
          address.segaddress.address:= info.s.unitinfo^.llvmlists.globlist.
                                      addbytevalue(size1,info.s.globlinkage);
         end
         else begin
          address.segaddress.address:= info.s.unitinfo^.llvmlists.globlist.
                                   addbitvalue(datasize1,info.s.globlinkage);
         end;
  }
  //       address.segaddress:= getglobvaraddress(datasize1,size1,address.flags);
         if not (us_implementation in s.unitinfo^.state) then begin
          nameid:= s.unitinfo^.nameid; //for llvm
         end;
         if (info.o.debugoptions*[do_proginfo,do_names] <> []) then begin
          getidentname(ident1,n1);
          if do_names in info.o.debugoptions then begin
  
           s.unitinfo^.llvmlists.globlist.namelist.addname(
                                                n1,address.segaddress.address);
          end;
          if do_proginfo in info.o.debugoptions then begin
           s.unitinfo^.llvmlists.globlist.lastitem^.debuginfo:= 
            s.unitinfo^.llvmlists.metadatalist.adddivariable(
                     nametolstring(n1),contextstack[s.stackindex+1].start.line,
                                                                          0,p2^);
          end;
         end;
        end
        else begin
         address.segaddress:= allocsegment(seg_globconst,p1^.h.bytesize,p3);
         with contextstack[s.stacktop],d.dat.constval do begin
          case p1^.h.datasize of
           das_1: begin
            pboolean(p3)^:= vboolean;
           end;
           das_8: begin
            pint8(p3)^:= vinteger;
           end;
           das_16: begin
            pint16(p3)^:= vinteger;
           end;
           das_32: begin
            pint32(p3)^:= vinteger;
           end;
           das_64: begin
            pint64(p3)^:= vinteger;
           end;
           das_f32: begin
            pflo32(p3)^:= vfloat;
           end;
           das_f64: begin
            pflo64(p3)^:= vfloat;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end
   else begin
    typeconversionerror(contextstack[s.stacktop].d,p1,p1^.h.indirectlevel,
                                                       err_incompatibletypes);
   end;
  end;
//  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handletypedconstarraylevelentry();
var
 p1,p2: ptypedataty;
 i1: int32;
 context1: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDCONSTARRAYLEVELENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if contextstack[s.stackindex-1].d.kind <> ck_arrayconst then begin
   internalerror(ie_handler,'20170613A');
  end;
 {$endif}
  d.kind:= ck_arrayconst;
  context1:= @contextstack[s.stackindex-1];
  p1:= ele.eledataabs(context1^.d.arrayconst.itemtype);
  d.arrayconst.datapopo:= context1^.d.arrayconst.datapopo;
  d.arrayconst.curindex:= 0;
  if p1^.h.kind <> dk_array then begin
   tokenexpectederror(';',erl_fatal);
  end
  else begin
   d.arrayconst.itemtype:= p1^.infoarray.i.itemtypedata;
   d.arrayconst.itemcount:= p1^.infoarray.i.totitemcount;
   p2:= ele.eledataabs(p1^.infoarray.i.itemtypedata);
   if (p2^.h.kind = dk_array) then begin
    if (p2^.infoarray.i.totitemcount <> 0) then begin
     d.arrayconst.itemcount:= d.arrayconst.itemcount div
                                     p2^.infoarray.i.totitemcount;
    end;
    d.arrayconst.itemsize:= 0;
   end
   else begin
    d.arrayconst.itemsize:= p2^.h.bytesize; //todo: alignment
   end;
  end;
 end;
end;

procedure handletypedconstarraylevel();
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDCONSTARRAYLEVEL');
{$endif}
 with info,contextstack[s.stackindex] do begin
  with d.arrayconst do begin
   if curindex < itemcount then begin
    errormessage(err_moreitemsexpected,[inttostrmse(itemcount-curindex)]);
   end;
  end;
  dec(s.stackindex);
 end;
end;

procedure handletypedconstarrayitem();
var
 p1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDCONSTARRAYITEM');
{$endif}
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_arrayconst then begin
   internalerror(ie_handler,'20170613B');
  end;
 {$endif}
  with d.arrayconst do begin
   inc(curindex);
   if curindex > itemcount then begin
    errormessage(err_toomanyarrayitems,[]);
   end
   else begin
    if itemsize <> 0 then begin
     inc(datapopo^,itemsize);
    end;
   end;
  end;
  s.stacktop:= s.stackindex;
 end;
end;

procedure handletypedconstarray();
var
 p1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDCONSTARRAY');
{$endif}
 with info do begin
  dec(s.stackindex);
//  with contextstack[s.stackindex] do begin
//   include(transitionflags,bf_continue);
//  end;
 end;
end;

end.
