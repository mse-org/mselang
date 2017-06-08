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
unit classhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 globtypes,handlerglob,__mla__internaltypes,stackops,listutils;

type
 classintfnamedataty = record
  intftype: elementoffsetty;
  next: elementoffsetty;  //chain, root = infoclassty.interfacechain
 end;
 pclassintfnamedataty = ^classintfnamedataty;

 classintftypedataty = record
  intftype: elementoffsetty;
  intfindex: integer;
 end;
 pclassintftypedataty = ^classintftypedataty;
    
const 
 virtualtableoffset = sizeof(classdefheaderty);
 constructorstacksize = vpointersize;

var
 selfobjparams: linklistty;

procedure copyvirtualtable(const source,dest: segaddressty;
                                                 const itemcount: integer);
function getclassinterfaceoffset(const aclass: ptypedataty;
              const aintf: ptypedataty; out offset: integer): boolean;
                            //true if ok

procedure handleobjectdefstart();
procedure handleclassdefstart();
procedure handleclassdefforward();
procedure handleclassdeferror();
procedure handleclassdef0();
procedure handleclassdefreturn();
procedure handleclassdefparam2();
procedure handleclassdefparam3a();
procedure handleclassdefparam4entry();
procedure handleclassdefattach();

procedure handleclassprivate();
procedure handleclassprotected();
procedure handleclasspublic();
procedure handleclasspublished();
//procedure handleclassfield();
//procedure handleclassvariantentry();
//procedure handleclassvariant();

procedure handleclasubheaderentry();
procedure handleclassmethmethodentry();
procedure handleclassmethfunctionentry();
procedure handleclassmethprocedureentry();
procedure handlemethmethodentry();
procedure handlemethfunctionentry();
procedure handlemethprocedureentry();
procedure handlemethconstructorentry();
procedure handlemethdestructorentry();
procedure handleconstructorentry();
procedure handledestructorentry();
procedure classpropertyentry();
//procedure handleclasspropertytype();
procedure handlereadprop();
procedure handlewriteprop();
procedure handledefaultprop();
procedure handleclassproperty();

implementation
uses
 parserglob,elements,handler,errorhandler,unithandler,handlerutils,
 parser,typehandler,opcode,subhandler,segmentutils,interfacehandler,
 identutils,valuehandler,grammarglob;
{
const
 vic_private = vis_3;
 vic_protected = vis_2;
 vic_public = vis_1;
 vic_published = vis_0;
}
{
procedure classesscopeset();
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          ele.eleinfoabs(info.unitinfo^.classeselement))^.data;
 po2^.scopebefore:= ele.elementparent;
 ele.elementparent:= info.unitinfo^.classeselement;
end;

procedure classesscopereset();
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          ele.eleinfoabs(info.unitinfo^.classeselement))^.data;
 ele.elementparent:= po2^.scopebefore;
end;
}
procedure copyvirtualtable(const source,dest: segaddressty;
                                                 const itemcount: integer);
var
 ps,pd,pe: popaddressty;
begin
 ps:= getsegmentpo(seg_classdef,source.address + virtualtableoffset);
 pd:= getsegmentpo(seg_classdef,dest.address + virtualtableoffset);
 pe:= pd+itemcount;
 while pd < pe do begin
  if pd^ = 0 then begin
   pd^:= ps^;
  end;
  inc(ps);
  inc(pd);
 end;
end;

function getclassinterfaceoffset(const aclass: ptypedataty;
              const aintf: ptypedataty; out offset: integer): boolean;
                            //true if ok
var
 intfele: elementoffsetty;
 po1: pclassintftypedataty;
 
begin
 intfele:= ele.eledatarel(aintf);
 result:= ele.findchilddata(aclass^.infoclass.intftypenode,identty(intfele),
                                 [ek_classintftype],allvisi,pointer(po1));
 if result then begin
  offset:= aclass^.infoclass.allocsize - 
              (aclass^.infoclass.interfacecount-po1^.intfindex) * pointersize;
 end;
end;

procedure doclassdef(const isclass: boolean); //else object
var
 po1: ptypedataty;
 id1: identty;
 ele1,ele2,ele3: elementoffsetty;
 bo1: boolean;
begin
 with info do begin
 {$ifdef mse_checkinternalerror}
  if s.stackindex < 3 then begin
   internalerror(ie_handler,'20140325D');
  end;
 {$endif}
  if isclass then begin
   s.currentstatementflags:= s.currentstatementflags + [stf_objdef,stf_class];
   currentfieldflags:= [af_classfield];
  end
  else begin
   s.currentstatementflags:= s.currentstatementflags + [stf_objdef];
   currentfieldflags:= [af_objectfield];
  end;
  if sublevel > 0 then begin
   errormessage(err_localclassdef,[]);
  end;
  selfobjparamchain:= 0;
  with contextstack[s.stackindex] do begin
   d.kind:= ck_classdef;
   d.cla.rec.fieldoffset:= 0;
   d.cla.rec.fieldoffsetmax:= 0;
   include(d.handlerflags,hf_initvariant);
   d.cla.intfindex:= 0;
   if isclass then begin
    d.cla.flags:= [obf_class{,obf_zeroed,obf_virtual}];
    d.cla.visibility:= classpublishedvisi;
//    d.cla.fieldoffset:= pointersize; //pointer to virtual methodtable
   end
   else begin
    d.cla.flags:= [];
    d.cla.visibility:= classpublicvisi;
//    d.cla.fieldoffset:= 0;
   end;
   d.cla.virtualindex:= 0;
  end;
  with contextstack[s.stackindex-2] do begin
   if (d.kind = ck_ident) and 
                  (contextstack[s.stackindex-1].d.kind = ck_typetype) then begin
    id1:= d.ident.ident; //typedef
   end
   else begin
    errormessage(err_anonclassdef,[]);
    exit;
   end;
  end;
  contextstack[s.stackindex].b.eleparent:= ele.elementparent;
  with contextstack[s.stackindex-1] do begin
   bo1:= ele.addelementdata(id1,ek_type,globalvisi,po1);
   d.typ.typedata:= ele.eledatarel(po1);
   currentcontainer:= d.typ.typedata;
   ele.elementparent:= d.typ.typedata;
//   inittypedatasize(po1^,dk_class,d.typ.indirectlevel,das_pointer);
   resolveforwardtype(po1);
   if not bo1 then begin
    if icf_defvalid in po1^.infoclass.flags then begin
     identerror(s.stacktop-s.stackindex,err_duplicateidentifier,erl_fatal);
    end;
//    else begin
//     resolveforwardtype(po1);
//    end;
   end
   else begin
    ele1:= ele.addelementduplicate1(tks_classintfname,
                                           ek_classintfnamenode,globalvisi);
    ele2:= ele.addelementduplicate1(tks_classintftype,
                                    ek_classintftypenode,globalvisi);
    ele3:= ele.addelementduplicate1(tks_classimp,ek_classimpnode,globalvisi);
    po1:= ele.eledataabs(currentcontainer); //could be moved by list size change
    if isclass then begin
     inittypedatasize(po1^,dk_class,d.typ.indirectlevel,das_pointer);
    end
    else begin
     inittypedatasize(po1^,dk_object,d.typ.indirectlevel,das_none,
                                                          [tf_sizeinvalid]);
    end;
    with po1^ do begin
     fieldchain:= 0;
     infoclass.intfnamenode:= ele1;
     infoclass.intftypenode:= ele2;
     infoclass.implnode:= ele3;
     infoclass.defs.address:= 0;
     if isclass then begin
      infoclass.flags:= [icf_class];
     end
     else begin
      infoclass.flags:= [];
     end;
     infoclass.virttaboffset:= 0;
     infoclass.pendingdescends:= 0;
     infoclass.interfaceparent:= 0;
     infoclass.interfacecount:= 0;
     infoclass.interfacechain:= 0;
     infoclass.interfacesubcount:= 0;
     fillchar(infoclass.subattach,sizeof(infoclass.subattach),0);
    end;
   end;
  end;
 end;
end;

procedure handleobjectdefstart();
begin
{$ifdef mse_debugparser}
 outhandle('OBJECTDEFSTART');
{$endif}
 doclassdef(false);
end;

procedure handleclassdefstart();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFSTART');
{$endif}
 doclassdef(true);
end;

procedure handleclassdefforward();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFFORWARD');
{$endif}
 with info do begin
  currentfieldflags:= [];
  with ptypedataty(ele.parentdata)^ do begin
   if icf_forward in infoclass.flags then begin
    identerror(s.stacktop-s.stackindex,err_duplicateidentifier,erl_error);
   end;
   include(infoclass.flags,icf_forward);
   if not (icf_class in infoclass.flags) then begin
    errormessage(err_objectforwardnotallowed,[]);
   end;
  end;
  markforwardtype(ele.parentdata,ele.parentelement^.header.name);
  ele.elementparent:= contextstack[s.stackindex].b.eleparent;
  currentcontainer:= 0;
  dec(s.stackindex);
  s.stackindex:= contextstack[s.stackindex].parent;
  s.stacktop:= s.stackindex;
 end;
end;

procedure classheader(const ainterface: boolean);
var
 po1,po2: ptypedataty;
 po3: pclassintfnamedataty;
 po4: pclassintftypedataty;
 ele1: elementoffsetty;
 ki1: datakindty;
begin
 with info do begin
  ele.checkcapacity(elesizes[ek_classintfname]+elesizes[ek_classintftype]);
  po1:= ele.eledataabs(currentcontainer);
  ele1:= ele.elementparent;
  ele.decelementparent(); //interface or implementation scope
  if (ainterface or (contextstack[s.stackindex+1].d.ident.ident <> tk_nil)) and 
                       findkindelementsdata(1,[ek_type],allvisi,po2) then begin
   if ainterface then begin
    if po2^.h.kind <> dk_interface then begin
     errormessage(err_interfacetypeexpected,[]);
    end
    else begin
     ele.elementparent:= 
                 ptypedataty(ele.eledataabs(ele1))^.infoclass.intfnamenode;
     if ele.addelementduplicatedata(
           contextstack[s.stackindex+1].d.ident.ident,
           ek_classintfname,[vik_global],po3,allvisi-[vik_ancestor]) then begin
      with po3^ do begin
       intftype:= ele.eledatarel(po2);
       next:= po1^.infoclass.interfacechain;
       po1^.infoclass.interfacechain:= ele.eledatarel(po3);
      end;
      ele.elementparent:= 
                 ptypedataty(ele.eledataabs(ele1))^.infoclass.intftypenode;
      po4:= ele.addelementduplicatedata1(identty(po3^.intftype),
                   ek_classintftype,[vik_global]);
      with po4^ do begin
       intftype:= po3^.intftype;
       with contextstack[s.stackindex-2] do begin
        intfindex:= d.cla.intfindex;
        inc(d.cla.intfindex);
       end;
      end;
     end
     else begin
      identerror(1,err_duplicateidentifier);
     end;
    end;
   end
   else begin
    if stf_class in s.currentstatementflags then begin
     ki1:= dk_class;
    end
    else begin
     ki1:= dk_object;
    end;
    if (ki1 <> dk_class) and (po2^.h.kind <> ki1) then begin
     errormessage(err_objecttypeexpected,[]);
    end
    else begin
     if not (icf_defvalid in po2^.infoclass.flags) then begin
      errormessage(err_classnotresolved,[]);
     end;
     po1^.h.ancestor:= ele.eledatarel(po2);
     po1^.h.flags:= po1^.h.flags + 
                     po2^.h.flags * [tf_needsmanage,tf_needsini,tf_needsfini];
     po1^.infoclass.flags:= po1^.infoclass.flags + 
              po2^.infoclass.flags * [icf_zeroinit,icf_nozeroinit,icf_virtual];
     po1^.infoclass.virttaboffset:= po2^.infoclass.virttaboffset;
     po1^.infoclass.subattach:= po2^.infoclass.subattach;
     if po2^.infoclass.interfacecount > 0 then begin
      po1^.infoclass.interfaceparent:= po1^.h.ancestor;
     end
     else begin
      po1^.infoclass.interfaceparent:= po2^.infoclass.interfaceparent;
     end;
//     po1^.infoclass.interfacecount:= po2^.infoclass.interfacecount;
//     po1^.infoclass.interfacesubcount:= po2^.infoclass.interfacesubcount;
     with contextstack[s.stackindex-2] do begin
      d.cla.rec.fieldoffset:= po2^.infoclass.allocsize;
      d.cla.rec.fieldoffsetmax:= d.cla.rec.fieldoffset;
      d.cla.virtualindex:= po2^.infoclass.virtualcount;
     end;
    end;
   end;
  end;
  ele.elementparent:= ele1;
 end;
end;

procedure handleclassdef0();
var
 typ1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEF0');
{$endif}
 with info do begin
  typ1:= ptypedataty(ele.eledataabs(
                     contextstack[s.stackindex-1].d.typ.typedata));
  with typ1^,contextstack[s.stackindex] do begin
   if obf_zeroinit in d.cla.flags then begin
    include(infoclass.flags,icf_zeroinit);
//    include(h.flags,tf_needsini);
   end;
   if obf_nozeroinit in d.cla.flags then begin
    include(infoclass.flags,icf_nozeroinit);
   end;
   if (obf_virtual in d.cla.flags) and 
              not (icf_virtual in infoclass.flags) then begin
    infoclass.virttaboffset:= d.cla.rec.fieldoffset;
    include(infoclass.flags,icf_virtual);
    d.cla.rec.fieldoffset:= d.cla.rec.fieldoffset + pointersize;
    d.cla.rec.fieldoffsetmax:= d.cla.rec.fieldoffset;
                      //pointer to virtual methodtable
    include(h.flags,tf_needsini);
   end;
   if (d.cla.intfindex > 0) and 
               not (icf_virtual in infoclass.flags) then begin
    errormessage(err_missingobjectattachment,['virtual']);
   end;
  end;
 end;
end;

procedure handleclassdefparam2();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFPARAM2');
{$endif}
 classheader(false); //ancestordef
end;

procedure handleclassdefparam3a();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFPARAM3A');
{$endif}
 classheader(true); //interfacedef
 with info do begin
//  dec(s.stackindex);
 end;
end;

procedure handleclassdefparam4entry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFPARAM4ENTRY');
{$endif}
 with info do begin
  s.stackindex:= s.stackindex-2;
  s.stacktop:= s.stackindex;
 {$ifdef checkinternalerror}
  if info.contextstack[s.stackindex].d.kind <> ck_classdef then begin
   internalerror('20170503A');
  end;
 {$endif}
 end;
end;

procedure handleclassdefattach();
var
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFATTACH');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_classdef then begin
   internalerror(ie_handler,'20170501A');
  end;
 {$endif}
  for i1:= s.stackindex+3 to s.stacktop do begin
  {$ifdef mse_checkinternalerror}
   if contextstack[i1].d.kind <> ck_ident then begin
    internalerror(ie_handler,'20170501A');
   end;
  {$endif}
   case contextstack[i1].d.ident.ident of
    tk_zeroinit: begin
     include(d.cla.flags,obf_zeroinit);
    end;
    tk_nozeroinit: begin
     include(d.cla.flags,obf_nozeroinit);
    end;
    tk_virtual: begin
     include(d.cla.flags,obf_virtual);
    end;
    else begin
     identerror(i1-s.stackindex,contextstack[i1].d.ident.ident,
                                                err_invalidattachment);
    end;
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

function checkinterface(const ainstanceoffset{,avirttaboffset}: int32;
                        const ainterface: pclassintfnamedataty): dataoffsty;
             //todo: name alias, delegation and the like

type
 scaninfoty = record
  intfele: elementoffsetty;
  sub: pintfitemty;
  seg: segaddressty;
 end;
              
 procedure dointerface(var scaninfo: scaninfoty);
 var
  intftype: ptypedataty;
  ele1: elementoffsetty;
  po1: pelementinfoty;
  po2: psubdataty;
  po3: pancestorchaindataty;
 begin
  with scaninfo do begin
   intftype:= ele.eledataabs(intfele);
   ele1:= intftype^.infointerface.subchain;
   while ele1 <> 0 do begin
    dec(sub);
    dec(seg.address,sizeof(intfitemty));
    po1:= ele.eleinfoabs(ele1);
                    //todo: overloaded subs
    if (ele.findcurrent(po1^.header.name,[ek_sub],allvisi,po2) <> ek_sub)
                                or not checkparams(@po1^.data,po2) then begin
               //todo: compose parameter message
     errormessage(err_nomatchingimplementation,[
         getidentname(ele.eleinfoabs(ainterface^.intftype)^.header.name)+'.'+
         getidentname(po1^.header.name)]);
    end
    else begin
     include(po2^.flags,sf_intfcall);
     if sf_virtual in po2^.flags then begin
      if po2^.trampolineaddress = 0 then begin
       linkmark(po2^.trampolinelinks,seg{,sizeof(intfitemty.instanceshift)});
      end                                               //offset
      else begin
       sub^.subad:= po2^.trampolineaddress-1;
      end;
     end
     else begin
      if po2^.address = 0 then begin
       linkmark(po2^.adlinks,seg{,sizeof(intfitemty.instanceshift)});
      end                                     //offset
      else begin
       sub^.subad:= po2^.address-1;
      end;
     end;
    end;
//    sub^.instanceshift:= instanceshift;
    ele1:= psubdataty(@po1^.data)^.next;
   end;
   ele1:= intftype^.h.ancestor;
//   ele1:= intftype^.infointerface.ancestorchain;
   while ele1 <> 0 do begin
    po3:= ele.eledataabs(ele1);
    intfele:= po3^.intftype;
    dointerface(scaninfo);
    ele1:= po3^.next;
   end;
  end;
 end;
 
var
 intftypepo: ptypedataty;
 int1: integer;
 scaninfo: scaninfoty;
 
begin
 scaninfo.intfele:= ainterface^.intftype;
 intftypepo:= ptypedataty(ele.eledataabs(scaninfo.intfele));
 pint32(allocsegmentpo(seg_intfitemcount,sizeof(int32)))^:= 
                                           intftypepo^.infointerface.subcount;
// int1:= intftypepo^.infointerface.subcount*sizeof(intfitemty);
 int1:= sizeof(intfdefheaderty)+
                       intftypepo^.infointerface.subcount*sizeof(intfitemty);
 result:= allocsegmentoffset(seg_intf,int1);
 with scaninfo do begin
  seg.address:= result+int1;       //top-down
  sub:= getsegmentpo(seg_intf,seg.address);
  seg.segment:= seg_intf;
 end;
 dointerface(scaninfo); 
 with pintfdefheaderty(pointer(scaninfo.sub)-
                             sizeof(intfdefheaderty))^ do begin
  instanceoffset:= ainstanceoffset;
//  virttaboffset:= avirttaboffset;
 end;
end;

procedure updateobjalloc(const atyp: ptypedataty; 
                                    const aclassinfo: pclassinfoty); 
var
 ele1: elementoffsetty;
 intfcount: integer;
 intfsubcount: integer;
 interfacealloc: int32;
begin
 with atyp^ do begin
  include(infoclass.flags,icf_allocvalid);
  intfcount:= 0;
  intfsubcount:= 0;
  ele1:= infoclass.interfacechain;
  while ele1 <> 0 do begin          //count interfaces
   with pclassintfnamedataty(ele.eledataabs(ele1))^ do begin
    intfsubcount:= intfsubcount + 
           ptypedataty(ele.eledataabs(intftype))^.infointerface.subcount;
    ele1:= next;
   end;
   inc(intfcount);
  end;
  infoclass.interfacecount:= {infoclass.interfacecount +} intfcount;
  infoclass.interfacesubcount:= {infoclass.interfacesubcount +} intfsubcount;

        //alloc classinfo
  interfacealloc:= infoclass.interfacecount*pointersize;
  infoclass.allocsize:= aclassinfo^.rec.fieldoffsetmax + interfacealloc;
  if not (icf_class in infoclass.flags) then begin
   updatetypedatabyte(atyp^,infoclass.allocsize);
  end;
 end;
end;

//class instance layout:
// header, pointer to virtual table
// fields
// interface table  <- fieldsize
//                  <- allocsize

var
 realobjsize: int32;
 
procedure resolveselfobjparam(var item);
var
 i1,i2,i3: int32;
 p1: psubdataty;
 p2: pvardataty;
 p3: pelementoffsetty;
begin
 with selfobjparamitemty(item) do begin
  i3:= realobjsize-paramsize;
  p1:= ele.eledataabs(methodelement);
  inc(p1^.paramsize,i3);
  p3:= @p1^.paramsrel;
  for i1:= paramindex+1 to p1^.paramcount-1 do begin
   p2:= ele.eledataabs(p3[i1]);
   inc(p2^.address.locaddress.address,i3);
  end;
 end;
end;

procedure handleclassdefreturn();
var
 ele1: elementoffsetty;
 classdefs1: segaddressty;
 classinfo1: pclassinfoty;
 parentinfoclass1: pinfoclassty;
// intfcount: integer;
// intfsubcount: integer;
 fla1: addressflagsty;
 int1: integer;
 po1: pdataoffsty;
// interfacealloc: int32;
 typ1: ptypedataty;
 
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFRETURN');
{$endif}
 with info do begin
  with contextstack[s.stackindex-1] do begin
   classinfo1:= @contextstack[s.stackindex].d.cla;
   typ1:= ptypedataty(ele.eledataabs(d.typ.typedata));
   s.currentstatementflags:= s.currentstatementflags - [stf_objdef,stf_class];
   with typ1^ do begin
    exclude(h.flags,tf_sizeinvalid);
    include(infoclass.flags,icf_defvalid);
    if (icf_zeroinit in infoclass.flags) or 
                   not (icf_nozeroinit in infoclass.flags) and 
                                    (classinfo1^.rec.fieldoffsetmax > 0) then begin
     include(h.flags,tf_needsini);
    end;

   {
    with contextstack[s.stackindex] do begin
     if obf_zeroed in d.cla.flags then begin
      include(infoclass.flags,icf_zeroed);
     end;
    end;
   }
    regclass(d.typ.typedata);
    h.flags:= h.flags+d.typ.flags;
    h.indirectlevel:= d.typ.indirectlevel;
    if not (icf_allocvalid in infoclass.flags) or 
             (typ1^.h.bytesize <> classinfo1^.rec.fieldoffsetmax) then begin
                          //there are fields after methods
     updateobjalloc(typ1,classinfo1);
    end;
    infoclass.virtualcount:= classinfo1^.virtualindex;
    int1:= sizeof(classdefinfoty)+ pointersize*infoclass.virtualcount;
                     //interfacetable start
    classdefs1:= getclassinfoaddress(
            int1+infoclass.interfacecount*pointersize,infoclass.interfacecount);
    infoclass.defs:= classdefs1;
    with classdefinfopoty(getsegmentpo(classdefs1))^ do begin
     header.allocs.size:= infoclass.allocsize;
     header.allocs.instanceinterfacestart:= classinfo1^.rec.fieldoffsetmax;
     header.allocs.classdefinterfacestart:= int1;
     header.parentclass:= -1;
     header.interfaceparent:= -1;
     if h.ancestor <> 0 then begin 
      parentinfoclass1:= @ptypedataty(ele.eledataabs(h.ancestor))^.infoclass;
      header.parentclass:= 
                      parentinfoclass1^.defs.address; //todo: relocate
      if parentinfoclass1^.virtualcount > 0 then begin
       fillchar(virtualmethods,parentinfoclass1^.virtualcount*pointersize,0);
       if icf_virtualtablevalid in parentinfoclass1^.flags then begin
        copyvirtualtable(infoclass.defs,classdefs1,
                                        parentinfoclass1^.virtualcount);
       end
       else begin
        regclassdescendent(d.typ.typedata,h.ancestor);
       end;
      end;
     end;
     if infoclass.interfaceparent <> 0 then begin
      header.interfaceparent:= ptypedataty(ele.eledataabs(
             infoclass.interfaceparent))^.infoclass.defs.address;
                                                          //todo: relocate
     end;
     if infoclass.interfacecount <> 0 then begin       //alloc interface table
      po1:= pointer(@header) + header.allocs.classdefinterfacestart;
      inc(po1,infoclass.interfacecount); //top - down
      int1:= -infoclass.allocsize; 
      ele1:= infoclass.interfacechain;
      while ele1 <> 0 do begin
       inc(int1,pointersize);
       dec(po1);
       po1^:= checkinterface(int1,{infoclass.virttaboffset,}
                                                 ele.eledataabs(ele1));
       ele1:= pclassintfnamedataty(ele.eledataabs(ele1))^.next;
      end;
     end;
    end;
//    if not (icf_class in infoclass.flags) then begin
//     updatetypedatabyte(typ1^,infoclass.allocsize);
//    end;
    reversefieldchain(typ1);
    if h.flags * [tf_needsmanage,tf_needsini,tf_needsfini] <> [] then begin
     createrecordmanagehandler(d.typ.typedata);
    end;
   end;
  end;
  realobjsize:= alignsize(typ1^.h.bytesize);
  resolvelist(selfobjparams,@resolveselfobjparam,selfobjparamchain);
  ele.elementparent:= contextstack[s.stackindex].b.eleparent;
  currentcontainer:= 0;
  currentfieldflags:= [];
 end;
end;

procedure handleclassdeferror();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFERROR');
{$endif}
 info.currentfieldflags:= [];
 tokenexpectederror(tk_end);
end;

procedure handleclassprivate();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPRIVATE');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.cla.visibility:= classprivatevisi;
 end;
end;

procedure handleclassprotected();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPROTECTED');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.cla.visibility:= classprotectedvisi;
 end;
end;

procedure handleclasspublic();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPUBLIC');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.cla.visibility:= classpublicvisi;
 end;
end;

procedure handleclasspublished();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPUBLISHED');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.cla.visibility:= classpublishedvisi;
 end;
end;
(*
procedure handleclassfield();
var
 po1: pvardataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
 af1: addressflagsty;
 tf1: typeflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSFIELD');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   af1:= [af_classfield];
  end
  else begin
   af1:= [af_objectfield];
  end;
  tf1:= [];
  checkrecordfield(d.cla.visibility,af1,d.cla.rec.fieldoffset,tf1);
{
  if obf_variant in d.cla.flags then begin
   if not (obf_variantitem in d.cla.flags) then begin
    errormessage(err_tokenexpected,['('],0);
   end
   else begin
    if tf1 * managedtypeflags <> [] then begin
     errormessage(err_managednotallowed,[]);
    end;
   end;
  end;
}
  contextstack[s.stackindex-2].d.typ.flags:= 
            contextstack[s.stackindex-2].d.typ.flags + tf1;
 end;
end;
*)
(*
procedure handleclassvariantentry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSVARIANTENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  if not (obf_variant in d.cla.flags) then begin
   include(d.cla.flags,obf_variant);
   d.cla.variantstart:= d.cla.fieldoffset;
   d.cla.fieldoffsetmax:= d.cla.fieldoffset;
  end;
  d.cla.fieldoffset:= d.cla.variantstart;
  d.cla.flags:= d.cla.flags+[obf_variant,obf_variantitem];
 end;
end;

procedure handleclassvariant();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSVARIANT');
{$endif}
 with info,contextstack[s.stackindex] do begin
  exclude(d.cla.flags,obf_variantitem);
  if d.cla.fieldoffset > d.cla.fieldoffsetmax then begin
   d.cla.fieldoffsetmax:= d.cla.fieldoffset;
  end;
  d.cla.fieldoffset:= d.cla.fieldoffsetmax;
 end;
end;
*)
procedure handleclasubheaderentry();
var
 p1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASUBHEADERENTRY');
{$endif}
 with info do begin
  p1:= ele.eledataabs(currentcontainer);
  if (p1^.h.kind in [dk_object,dk_class]) and 
                   not (icf_allocvalid in p1^.infoclass.flags) then begin
   updateobjalloc(p1,@contextstack[s.stackindex-1].d.cla);
  end;
 end;
end;

procedure handleclassmethmethodentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSMETHFUNCTIONENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_methodtoken,sf_header,sf_method,sf_classmethod];
  end
  else begin
   sf1:= [sf_methodtoken,sf_header,sf_method,sf_classmethod];
  end;
 end;
 initsubdef(sf1);
end;

procedure handleclassmethfunctionentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSMETHPROCEDUREENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_header,sf_method,sf_classmethod];
  end
  else begin
   sf1:= [sf_header,sf_method,sf_classmethod];
  end;
 end;
 initsubdef(sf1);
end;

procedure handleclassmethprocedureentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSMETHFUNCTIONENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_function,sf_header,sf_method,sf_classmethod];
  end
  else begin
   sf1:= [sf_function,sf_header,sf_method,sf_classmethod];
  end;
 end;
 initsubdef(sf1);
end;


procedure handlemethmethodentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('METHFUNCTIONENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_methodtoken,sf_header,sf_method];
  end
  else begin
   sf1:= [sf_methodtoken,sf_header,sf_method];
  end;
 end;
 initsubdef(sf1);
end;

procedure handlemethprocedureentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('METHPROCEDUREENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_header,sf_method];
  end
  else begin
   sf1:= [sf_header,sf_method];
  end;
 end;
 initsubdef(sf1);
end;

procedure handlemethfunctionentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('METHFUNCTIONENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_function,sf_header,sf_method];
  end
  else begin
   sf1:= [sf_function,sf_header,sf_method];
  end;
 end;
 initsubdef(sf1);
end;

procedure handlemethconstructorentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('METHCONSTRUCTORENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_header,sf_method,sf_constructor];
  end
  else begin
   sf1:= [sf_header,sf_method,sf_constructor];
  end;
 end;
 initsubdef(sf1);
end;

procedure handlemethdestructorentry();
var
 sf1: subflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('METHDESTRUCTORENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if obf_class in d.cla.flags then begin
   sf1:= [sf_class,sf_header,sf_method,sf_destructor];
  end
  else begin
   sf1:= [sf_header,sf_method,sf_destructor];
  end;
 end;
 initsubdef(sf1);
end;

procedure handleconstructorentry();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTRUCTORENTRY');
{$endif}
 initsubdef([sf_method,sf_constructor]);
end;

procedure handledestructorentry();
begin
{$ifdef mse_debugparser}
 outhandle('DESTRUCTORENTRY');
{$endif}
 initsubdef([sf_method,sf_destructor]);
end;

procedure classpropertyentry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPROPERTYENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_classprop;
  if obf_class in contextstack[s.stackindex-1].d.cla.flags then begin
   d.classprop.flags:= [pof_class];
  end
  else begin
   d.classprop.flags:= [];
  end;
  d.classprop.errorref:= errors[erl_error];
 end;
end;
(*
procedure handleclasspropertytype();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPROPERTYTYPE');
{$endif}
 with info do begin
  if s.stacktop > s.stackindex+1 then begin
  end;
  s.stacktop:= s.stackindex+2;
 end;
end;
*)

function checkpropaccessor(const awrite: boolean): boolean;

 procedure illegalsymbol();
 begin
  errormessage(err_illegalpropsymbol,[]);
  result:= false;
 end; //illegalsymbol

 function checkindex({const indexcount: int32;} const sub: psubdataty): boolean;
 var
  popar,pe: pelementoffsetty;
  pocontext: pcontextitemty;
  po1,po2: pcontextitemty;
 begin
  result:= false;
//  if indexcount > 0 then begin
  pocontext:= @info.contextstack[info.s.stackindex+3];
  po1:= pocontext + 2; //first ident
  popar:= pelementoffsetty(@sub^.paramsrel);
  pe:= popar + sub^.paramcount;
  inc(popar,2); //first index param
  while true do begin
  {$ifdef checkinternalerror}
   if pocontext^.d.kind <> ck_paramsdef then begin
    internalerror(ie_parser,'20160222B');
   end;
   if po1^.d.kind <> ck_ident then begin
    internalerror(ie_parser,'20160106A');
   end;
  {$endif}
   po2:= po1;
   while po1^.d.kind = ck_ident do begin
    inc(po1);
   end;
  {$ifdef checkinternalerror}
   if (po1^.d.kind <> ck_fieldtype) then begin
    internalerror(ie_parser,'20160222A');
   end;
  {$endif}
   while po2 < po1 do begin
    if (popar >= pe) then begin //not enough index parameters
     illegalsymbol();
     exit;
    end;
    with pvardataty(ele.eledataabs(popar^))^ do begin
     if ((po1)^.d.typ.typedata <> vf.typ) or 
       ((paramkinds[pocontext^.d.paramdef.kind] >< address.flags) * 
                                               paramflagsmask <> []) then begin
      illegalsymbol();
      exit;
     end;
    end;
    inc(po2);
    inc(popar);
   end;
   pocontext:= po1+1;
   if pocontext^.d.kind <> ck_paramdef then begin
    break;
   end;
   po1:= pocontext + 2; //first ident
  end;
  result:= popar = pe; //correct param count
  if not result then begin
   illegalsymbol();
  end;
 (*
  while popar < pe do begin
  {$ifdef checkinternalerror}
   if (pocontext^.d.kind <> ck_paramsdef) or 
                       ((pocontext+2)^.d.kind <> ck_fieldtype) then begin
    internalerror(ie_parser,'20160106A');
   end;
   if (
  {$endif}
   with pvardataty(ele.eledataabs(popar^))^ do begin
    if ((pocontext+2)^.d.typ.typedata <> vf.typ) or 
      ((paramkinds[pocontext^.d.paramsdef.kind] >< address.flags) * 
                                              paramflagsmask <> []) then begin
     illegalsymbol();
     result:= false;
     exit;
    end;
   end;
   inc(popar);
   inc(pocontext,3);
  end;
 *)
// end;
 end;  //checkindex
 
var
 po1: pointer;
 elekind1: elementkindty;
 typeele1: elementoffsetty;
 indi1: int32;
 ele1: elementoffsetty;
 i1: int32;
 offs1: int32;
 idstart1: int32;
 hasindex: boolean;
// indexcount1: int32;
label
 endlab;
begin
 result:= false;
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if contextstack[s.stackindex].d.kind <> ck_classprop then begin
   internalerror(ie_handler,'20151214A');
  end;
  if contextstack[s.stackindex+1].d.kind <> ck_ident then begin
   internalerror(ie_handler,'20151201A');
  end;
  if contextstack[s.stacktop].d.kind <> ck_ident then begin
   internalerror(ie_handler,'20151214B');
  end;
 {$endif}
  idstart1:= s.stacktop;
  while contextstack[idstart1].d.kind = ck_ident do begin
   dec(idstart1);
  end;
 {$ifdef mse_checkinternalerror}
  if contextstack[idstart1].d.kind <> ck_typeref then begin
   internalerror(ie_handler,'20151201B');
  end;
 {$endif}
  typeele1:= contextstack[idstart1].d.typeref;
  indi1:= ptypedataty(ele.eledataabs(typeele1))^.h.indirectlevel;
  i1:= s.stackindex + 3;
  hasindex:= (i1 <= s.stacktop) and (contextstack[i1].d.kind = ck_paramdef);
{  
  indexcount1:= 0;
  if idstart1 - s.stackindex >= 5 then begin
   for i1:= s.stackindex + 5 to idstart1-2 do begin
    if contextstack[i1].d.kind = ck_ident then begin
     inc(indexcount1);
    end;
//   indexcount1:= (i1 - 3) div 3;
   end;
  end;
}
  inc(idstart1);
  elekind1:= ele.findcurrent(contextstack[idstart1].d.ident.ident,[],
                                                           [vik_ancestor],po1);
  ele1:= ele.eledatarel(po1);
  case elekind1 of
   ek_none: begin
    identerror(s.stacktop-s.stackindex,err_identifiernotfound);
   end;
   ek_field: begin
    if hasindex then begin
     illegalsymbol();
     goto endlab;
    end;
    offs1:= pfielddataty(po1)^.offset;
    for i1:= idstart1+1 to s.stacktop do begin
     if ele.findchild(pfielddataty(po1)^.vf.typ,contextstack[i1].d.ident.ident,
                            [ek_field],allvisi,ele1,po1) <> ek_field then begin
      identerror(i1-s.stackindex,err_unknownrecordfield);
      goto endlab;
     end;
     offs1:= offs1 + pfielddataty(po1)^.offset;
    end;
    with pfielddataty(po1)^ do begin
     if (vf.typ = typeele1) and (indirectlevel = indi1) then begin
      if awrite then begin
       d.classprop.writeele:= ele1;
       d.classprop.writeoffset:= offs1;
       include(d.classprop.flags,pof_writefield);
      end
      else begin
       d.classprop.readele:= ele1;
       d.classprop.readoffset:= offs1;
       include(d.classprop.flags,pof_readfield);
      end;
      result:= true;
     end
     else begin
      incompatibletypeserror(typeele1,vf.typ);
     end;
    end;
   end;
   ek_sub: begin   //todo: index option
    with psubdataty(po1)^ do begin
     if (sf_method in flags) then begin
      if awrite then begin
       if not (sf_function in flags) and ((paramcount = 2) or 
                                       (paramcount > 2) and hasindex) and
         (pvardataty(ele.eledataabs(
                 pelementoffsetty(@paramsrel)[1]))^.vf.typ = typeele1) then begin
        d.classprop.writeele:= ele1;
        d.classprop.writeoffset:= 0;
        include(d.classprop.flags,pof_writesub);
        result:= not hasindex or checkindex(po1);
       end
       else begin
        illegalsymbol();
       end;
      end
      else begin
       if (sf_function in flags) and ((paramcount = 2) or 
                                     (paramcount > 2) and hasindex) and 
            (resulttype.typeele = typeele1) and 
                            (resulttype.indirectlevel = indi1) then begin
                            //necessary?
        d.classprop.readele:= ele1;
        d.classprop.readoffset:= 0;
        include(d.classprop.flags,pof_readsub);
        result:= (paramcount = 2) or checkindex({indexcount1,}po1);
       end
       else begin
        illegalsymbol();
       end;
      end;
     end
     else begin
      illegalsymbol();
     end;
    end;
   end;
   else begin
    identerror(s.stacktop-s.stackindex,err_unknownfieldormethod);
   end;
  end;
endlab:
  s.stacktop:= idstart1-1;
 end;
end;

procedure handlereadprop();
begin
{$ifdef mse_debugparser}
 outhandle('READPROP');
{$endif}
 with info,contextstack[s.stackindex] do begin  
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_classprop then begin
   internalerror(ie_handler,'20151201A');
  end;
 {$endif}
  if checkpropaccessor(false) then begin
  end;
 end;
end;

procedure handlewriteprop();
begin
{$ifdef mse_debugparser}
 outhandle('WRITEPROP');
{$endif}
 with info,contextstack[s.stackindex] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_classprop then begin
   internalerror(ie_handler,'20151201A');
  end;
 {$endif}
  if checkpropaccessor(true) then begin
  end;
 end;
end;

procedure handledefaultprop();
var
 po1: ptypedataty;
 poa,potop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('DEFAULTPROP');
{$endif}
 with info do begin
  potop:= @contextstack[s.stacktop];
  poa:= getpreviousnospace(potop-1);
 {$ifdef mse_checkinternalerror}
  if poa^.d.kind <> ck_typeref then begin
   internalerror(ie_handler,'20151202C');
  end;
 {$endif}
  with potop^ do begin
   if d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[]);
   end
   else begin
    po1:= ele.eledataabs(poa^.d.typeref);
    if not tryconvert(potop,po1,po1^.h.indirectlevel,[]) then begin
     incompatibletypeserror(poa^.d.typeref,d.dat.datatyp.typedata);
    end
    else begin
     include(contextstack[s.stackindex].d.classprop.flags,pof_default);
    end;
   end;
  end;
 end; 
end;

procedure handleclassproperty();
var
 po1: ppropertydataty;
 typeeleid1: int32;
 poa,potop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPROPERTY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  potop:= @contextstack[s.stacktop];
  poa:= getpreviousnospace(potop-1);
  if d.classprop.errorref = errors[erl_error] then begin //no error
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_classprop then begin
    internalerror(ie_handler,'20151202B');
   end;
   if contextstack[s.stackindex+1].d.kind <> ck_ident then begin
    internalerror(ie_handler,'20151202C');
   end;
  {$endif}
   if not ele.addelementdata(contextstack[s.stackindex+1].d.ident.ident,
                           ek_property,[vik_ancestor],po1) then begin
    identerror(1,err_duplicateidentifier);
   end
   else begin
    with po1^ do begin
     flags:= d.classprop.flags;
     if pof_default in flags then begin
     {$ifdef mse_checkinternalerror}
      if potop^.d.kind <> ck_const then begin
       internalerror(ie_handler,'20151202D');
      end;
      if poa^.d.kind <> ck_typeref then begin
       internalerror(ie_handler,'20151207A');
      end;
     {$endif}
      with potop^ do begin
       defaultconst.typ:= d.dat.datatyp;
       defaultconst.d:= d.dat.constval;
      end;
      typ:= poa^.d.typeref;
     end
     else begin
     {$ifdef mse_checkinternalerror}
      if potop^.d.kind <> ck_typeref then begin
       internalerror(ie_handler,'20151207A');
      end;
     {$endif}
      typ:= potop^.d.typeref;
     end;
     if flags * canreadprop <> [] then begin
      readele:= d.classprop.readele;
      readoffset:= d.classprop.readoffset;
     end
     else begin
      readele:= 0;
      readoffset:= 0;
     end;
     if flags * canwriteprop <> [] then begin
      writeele:= d.classprop.writeele;
      writeoffset:= d.classprop.writeoffset;
     end
     else begin
      writeele:= 0;
      writeoffset:= 0;
     end;
    end;     
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

end.
