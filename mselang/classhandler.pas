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
unit classhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob,handlerglob,__mla__internaltypes;

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

procedure copyvirtualtable(const source,dest: segaddressty;
                                                 const itemcount: integer);
function getclassinterfaceoffset(const aclass: ptypedataty;
              const aintf: ptypedataty; out offset: integer): boolean;
                            //true if ok

procedure handleclassdefstart();
procedure handleclassdeferror();
procedure handleclassdefreturn();
procedure handleclassdefparam2();
procedure handleclassdefparam3a();
procedure handleclassprivate();
procedure handleclassprotected();
procedure handleclasspublic();
procedure handleclasspublished();
procedure handleclassfield();
procedure handlemethfunctionentry();
procedure handlemethprocedureentry();
procedure handlemethconstructorentry();
procedure handlemethdestructorentry();
procedure handleconstructorentry();
procedure handledestructorentry();

implementation
uses
 elements,handler,errorhandler,unithandler,grammar,handlerutils,
 parser,typehandler,opcode,subhandler,segmentutils,interfacehandler;
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
  offset:= po1^.intfindex*pointersize + aclass^.infoclass.fieldsize;
 end;
end;

procedure handleclassdefstart();
var
 po1: ptypedataty;
 id1: identty;
 ele1,ele2,ele3: elementoffsetty;
 
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFSTART');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if s.stackindex < 3 then begin
   internalerror(ie_handler,'20140325D');
  end;
 {$endif}
  include(s.currentstatementflags,stf_classdef);
  if sublevel > 0 then begin
   errormessage(err_localclassdef,[]);
  end;
  with contextstack[s.stackindex] do begin
   d.kind:= ck_classdef;
   d.cla.visibility:= classpublishedvisi;
   d.cla.intfindex:= 0;
   d.cla.fieldoffset:= pointersize; //pointer to virtual methodtable
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
   if not ele.pushelement(id1,ek_type,globalvisi,d.typ.typedata) then begin
    identerror(s.stacktop-s.stackindex,err_duplicateidentifier,erl_fatal);
   end;
   ele1:= ele.addelementduplicate1(tks_classintfname,
                                          ek_classintfnamenode,globalvisi);
   ele2:= ele.addelementduplicate1(tks_classintftype,
                                   ek_classintftypenode,globalvisi);
   ele3:= ele.addelementduplicate1(tks_classimp,ek_classimpnode,globalvisi);

   currentcontainer:= d.typ.typedata;
   po1:= ele.eledataabs(currentcontainer);
   inittypedatasize(po1^,dk_class,d.typ.indirectlevel,das_pointer);
   with po1^ do begin
    fieldchain:= 0;
    infoclass.intfnamenode:= ele1;
    infoclass.intftypenode:= ele2;
    infoclass.implnode:= ele3;
    infoclass.defs.address:= 0;
    infoclass.flags:= [];
    infoclass.pendingdescends:= 0;
    infoclass.interfacecount:= 0;
    infoclass.interfacechain:= 0;
    infoclass.interfacesubcount:= 0;
   end;
  end;
 end;
end;

procedure classheader(const ainterface: boolean);
var
 po1,po2: ptypedataty;
 po3: pclassintfnamedataty;
 po4: pclassintftypedataty;
 ele1: elementoffsetty;
begin
 with info do begin
  ele.checkcapacity(elesizes[ek_classintfname]+elesizes[ek_classintftype]);
  po1:= ele.eledataabs(currentcontainer);
  ele1:= ele.elementparent;
  ele.decelementparent(); //interface or implementation scope
  if findkindelementsdata(1,[ek_type],allvisi,po2) then begin
   if ainterface then begin
    if po2^.kind <> dk_interface then begin
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
    if po2^.kind <> dk_class then begin
     errormessage(err_classtypeexpected,[]);
    end
    else begin
     po1^.ancestor:= ele.eledatarel(po2);
     po1^.infoclass.interfacecount:= po2^.infoclass.interfacecount;
     po1^.infoclass.interfacesubcount:= po2^.infoclass.interfacesubcount;
     with contextstack[s.stackindex-2] do begin
      d.cla.fieldoffset:= po2^.infoclass.allocsize;
      d.cla.virtualindex:= po2^.infoclass.virtualcount;
     end;
    end;
   end;
  end;
  ele.elementparent:= ele1;
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

function checkinterface(const ainstanceoffset: int32;
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
       linkmark(po2^.links,seg{,sizeof(intfitemty.instanceshift)});
      end                                     //offset
      else begin
       sub^.subad:= po2^.address-1;
      end;
     end;
    end;
//    sub^.instanceshift:= instanceshift;
    ele1:= psubdataty(@po1^.data)^.next;
   end;
   ele1:= intftype^.ancestor;
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
 end;
end;

//class instance layout:
// header, pointer to virtual table
// fields
// interface table  <- fieldsize
//                  <- allocsize

procedure handleclassdefreturn();
var
 ele1: elementoffsetty;
 classdefs1: segaddressty;
 classinfo1: pclassinfoty;
 parentinfoclass1: pinfoclassty;
 intfcount: integer;
 intfsubcount: integer;
 fla1: addressflagsty;
 int1: integer;
 po1: pdataoffsty;
 
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFRETURN');
{$endif}
 with info do begin
  exclude(s.currentstatementflags,stf_classdef);
  with contextstack[s.stackindex-1],ptypedataty(ele.eledataabs(
                                                d.typ.typedata))^ do begin
   regclass(d.typ.typedata);
   flags:= d.typ.flags;
   indirectlevel:= d.typ.indirectlevel;
   classinfo1:= @contextstack[s.stackindex].d.cla;

                     
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
   infoclass.interfacecount:= infoclass.interfacecount + intfcount;
   infoclass.interfacesubcount:= infoclass.interfacesubcount + intfsubcount;

         //alloc classinfo
   infoclass.fieldsize:= classinfo1^.fieldoffset;
   infoclass.allocsize:= infoclass.fieldsize +  
                                  infoclass.interfacecount*pointersize;
   infoclass.virtualcount:= classinfo1^.virtualindex;
   int1:= sizeof(classdefinfoty)+ pointersize*infoclass.virtualcount;
                    //interfacetable start
//   classdefs1:= getglobconstaddress(int1 +
//                                   pointersize*infoclass.interfacecount,fla1);
   classdefs1:= getclassinfoaddress(int1 +pointersize*infoclass.interfacecount,
                                                      infoclass.interfacecount);
   infoclass.defs:= classdefs1;   
   with pclassdefinfoty(getsegmentpo(classdefs1))^ do begin
    header.parentclass:= 0;
    header.allocsize:= infoclass.allocsize;
    header.fieldsize:= infoclass.fieldsize;
    header.interfacestart:= int1;
    if ancestor <> 0 then begin 
     parentinfoclass1:= @ptypedataty(ele.eledataabs(ancestor))^.infoclass;
     header.parentclass:= parentinfoclass1^.defs.address; //todo: relocate
     if parentinfoclass1^.virtualcount > 0 then begin
      fillchar(virtualmethods,parentinfoclass1^.virtualcount*pointersize,0);
      if icf_virtualtablevalid in parentinfoclass1^.flags then begin
       copyvirtualtable(infoclass.defs,classdefs1,
                                       parentinfoclass1^.virtualcount);
      end
      else begin
       regclassdescendent(d.typ.typedata,ancestor);
      end;
     end;
    end;
    if intfcount <> 0 then begin       //alloc interface table
     po1:= pointer(@header) + header.interfacestart;
     inc(po1,infoclass.interfacecount); //top - down
     int1:= -infoclass.allocsize; 
     ele1:= infoclass.interfacechain;
     while ele1 <> 0 do begin
      inc(int1,pointersize);
      dec(po1);
      po1^:= checkinterface(int1,ele.eledataabs(ele1));
      ele1:= pclassintfnamedataty(ele.eledataabs(ele1))^.next;
     end;
    end;
   end;
  {
   ele1:= ele.addelementduplicate1(tks_classimp,globalvisi,ek_classimp);
   ptypedataty(ele.eledataabs(d.typ.typedata))^.infoclass.impl:= ele1;
              //possible capacity change
  }
  end;
    
  ele.elementparent:= contextstack[s.stackindex].b.eleparent;
  currentcontainer:= 0;
 end;
end;

procedure handleclassdeferror();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFERROR');
{$endif}
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

procedure handleclassfield();
var
 po1: pvardataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSFIELD');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  checkrecordfield(d.cla.visibility,[af_classfield],d.cla.fieldoffset,
                                   contextstack[s.stackindex-2].d.typ.flags);
 end;
end;

procedure handlemethprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHPROCEDUREENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_header,sf_method];
 end;
end;

procedure handlemethfunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHFUNCTIONENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_function,sf_header,sf_method];
 end;
end;

procedure handlemethconstructorentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHCONSTRUCTORENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_header,sf_method,sf_constructor];
 end;
end;

procedure handlemethdestructorentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHDESTRUCTORENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_header,sf_method,sf_destructor];
 end;
end;

procedure handleconstructorentry();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTRUCTORENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_method,sf_constructor];
 end;
end;

procedure handledestructorentry();
begin
{$ifdef mse_debugparser}
 outhandle('DESTRUCTORENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_method,sf_destructor];
 end;
end;

end.
