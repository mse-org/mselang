{ MSElang Copyright (c) 2013-2015 by Martin Schreiber
   
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
unit typehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$coperators on}{$endif}
interface
uses
 globtypes,parserglob;

procedure handletype();
procedure handlegettypetypestart();
procedure handlegetfieldtypestart();
procedure handlepointertype();
procedure handlechecktypeident();
procedure handlecheckrangetype();
procedure handlenamedtype();
 
procedure handlerecorddefstart();
procedure handlerecorddeferror();
procedure handlerecordtype();
procedure handlerecordfield();

procedure handlearraytype();
procedure handlearraydeferror1();
procedure handlearrayindexerror1();
procedure handlearrayindexerror2();

procedure handleindexstart();
procedure handleindexitemstart();
procedure handleindexitem();
procedure handleindex();

procedure handleenumdefentry();
procedure handleenumdef();
procedure handleenumitem();
procedure handleenumitemvalue();

procedure handlesettype();

procedure checkrecordfield(const avisibility: visikindsty;
                       const aflags: addressflagsty; var aoffset: dataoffsty;
                                                  var atypeflags: typeflagsty);
procedure setsubtype(atypetypecontext: int32;
                                           const asub: elementoffsetty);
procedure checkpendingmanagehandlers();

implementation
uses
 handlerglob,elements,errorhandler,handlerutils,parser,opcode,stackops,
 grammar,opglob,managedtypes,unithandler,identutils,valuehandler,subhandler,
 segmentutils,__mla__internaltypes;

procedure handletype();
begin
{$ifdef mse_debugparser}
 outhandle('TYPE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handlegetfieldtypestart();
begin
{$ifdef mse_debugparser}
 outhandle('GETFIELDTYPESTART');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_fieldtype;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
  d.typ.flags:= [];
 end;
end;

procedure handlegettypetypestart();
begin
{$ifdef mse_debugparser}
 outhandle('GETTYPETYPESTART');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_typetype;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
  d.typ.flags:= [];
 end;
end;

procedure handlepointertype();
begin
{$ifdef mse_debugparser}
 outhandle('POINTERTYPE');
{$endif}
 with info,contextstack[s.stackindex] do begin
  inc(d.typ.indirectlevel);
 end;
end;

procedure handlechecktypeident();
var
 {po1,}po2: pelementinfoty;
 po3,po4: ptypedataty;
 idcontext: pcontextitemty;
 bo1,bo2: boolean;
 forward1: boolean;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKTYPEIDENT');
{$endif}
 with info,contextstack[s.stackindex-2] do begin
 {$ifdef mse_checkinternalerror}
  if s.stackindex < 3 then begin
   internalerror(ie_type,'20140325A');
  end;
 {$endif}
  ele.checkcapacity(ek_type);
  bo1:= (d.typ.indirectlevel > 0) and (s.stacktop-s.stackindex = 1);
                                        //simple type name only
  bo2:= findkindelements(1,[ek_type],allvisi,po2,bo1);
  forward1:= not bo2 and bo1;
  if forward1 then begin //forward pointer
   po2:= ele.eleinfoabs(getsystypeele(st_none));
   bo2:= true;
  end;
  if bo2 then begin
   d.typ.typedata:= ele.eleinforel(po2);
   po3:= ptypedataty(@po2^.data);
   d.typ.flags:= po3^.h.flags;
   inc(d.typ.indirectlevel,po3^.h.indirectlevel);
   if d.kind = ck_typetype then begin
    idcontext:= @contextstack[s.stackindex-3];
   {$ifdef mse_checkinternalerror}
    if idcontext^.d.kind <> ck_ident then begin
     internalerror(ie_type,'20140324B');
    end;
   {$endif}
    if ele.addelementdata(idcontext^.d.ident.ident,
                                          ek_type,allvisi,po4) then begin
     po4^:= po3^;
     if po3^.h.base = 0 then begin
      po4^.h.base:= d.typ.typedata;
     end;
     po4^.h.indirectlevel:= d.typ.indirectlevel;
     if po4^.h.indirectlevel > 0 then begin
      po4^.h.flags-= [tf_managed,tf_needsmanage];
     end;
     if forward1 then begin
      markforwardtype(po4,contextstack[s.stacktop].d.ident.ident);
     end
     else begin
      resolveforwardtype(po4);
     end;
    end
    else begin //duplicate
     identerror(-3,err_duplicateidentifier);
    end;
   end;
//   s.stacktop:= s.stackindex-1;
//   s.stackindex:= contextstack[s.stackindex].parent;
  end
  else begin
   d.typ.typedata:= 0;
//   s.stackindex:= s.stackindex-1;
//   s.stacktop:= s.stackindex;
  end;
  s.stacktop:= s.stackindex-1;
  s.stackindex:= contextstack[s.stackindex].parent;
 end;
end;

procedure handlenamedtype();
var
 po1: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('NAMEDTYPE');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_typeref;
  if not findkindelements(1,[ek_type],allvisi,po1,true) then begin
   errormessage(err_typeidentexpected,[]);
   d.typeref:= 0;
  end
  else begin
   d.typeref:= ele.eleinforel(po1);
  end;
 end;
end;

procedure setsubtype(atypetypecontext: int32; 
                                          const asub: elementoffsetty);
var
 po1: ptypedataty;
begin
 with info do begin
  atypetypecontext:= atypetypecontext+s.stackindex;
 {$ifdef mse_checkinternalerror}
  if (contextstack[atypetypecontext].d.kind <> ck_typetype) or
   (contextstack[atypetypecontext-1].d.kind <> ck_ident) then begin
   internalerror(ie_handler,'20150425A');
  end;
 {$endif}
  if not ele.addelementdata(contextstack[atypetypecontext-1].d.ident.ident,
                                                 ek_type,allvisi,po1) then begin
   identerror(atypetypecontext-1,err_duplicateidentifier);
  end
  else begin
   with contextstack[atypetypecontext] do begin
    inittypedatasize(po1^,dk_sub,d.typ.indirectlevel+1,das_pointer);
    po1^.infosub.sub:= asub;
   end;
  end;
//  s.stackindex:= contextstack[atypetypecontext].parent-1;//todo: record field?
//  s.stacktop:= s.stackindex;
 end;
end;

procedure handlecheckrangetype();
var
 id1: identty;
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKRANGETYPE');
{$endif}
 with info do begin
  if s.stacktop-s.stackindex = 3 then begin
   with contextstack[s.stackindex-2] do begin
    if (d.kind = ck_ident) and 
                (contextstack[s.stackindex-1].d.kind = ck_typetype) then begin
     id1:= d.ident.ident; //typedef
    end
    else begin
     id1:= getident();
    end;
   end;
   with contextstack[s.stackindex-1] do begin
    if not ele.addelementduplicatedata(id1,ek_type,allvisi,po1) then begin
     identerror(-1,err_duplicateidentifier);
    end;
    d.typ.typedata:= ele.eledatarel(po1);
    inittypedatasize(po1^,dk_integer,d.typ.indirectlevel,das_32);
    include(po1^.h.flags,tf_subrange);
    with po1^.infoint32 do begin     //todo: other datasizes
     //todo: check datasize
     min:= contextstack[s.stackindex+2].d.dat.constval.vinteger;
     max:= contextstack[s.stackindex+3].d.dat.constval.vinteger;
    end;
   end;
  end;
  s.stacktop:= s.stackindex-1;
  s.stackindex:= contextstack[s.stackindex].parent;
 end;
end;

function gettypeident(): identty;
begin
 with info,contextstack[s.stackindex-2] do begin
  if (d.kind = ck_ident) and 
                 (contextstack[s.stackindex-1].d.kind = ck_typetype) then begin
   result:= d.ident.ident; //typedef
  end
  else begin
   result:= getident();
  end;
 end;
end;
 
procedure handlerecorddefstart();
var
 po1: ptypedataty;
 id1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDDEFSTART');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if s.stackindex < 3 then begin
   internalerror(ie_type,'20140325D');
  end;
 {$endif}
  with contextstack[s.stackindex] do begin
   b.eleparent:= ele.elementparent;
   d.kind:= ck_recorddef;
   d.rec.fieldoffset:= 0;
  end;
  with contextstack[s.stackindex-1] do begin
   if not ele.pushelementduplicatedata(
                      gettypeident(),ek_type,allvisi,po1) then begin
    identerror(s.stacktop-s.stackindex,err_duplicateidentifier);
   end;
   d.typ.typedata:= ele.eledatarel(po1);
   with po1^ do begin
//    flags:= [];
//    datasize:= das_none;
    h.kind:= dk_none; //inhibit dump
    fieldchain:= 0;  //used in checkrecordfield()
   end;
  end;
 end;
end;

procedure handlerecorddeferror();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDDEFERROR');
{$endif}
 with info do begin
  ele.elementparent:= contextstack[s.stackindex].b.eleparent;
 end;
end;

procedure checkrecordfield(const avisibility: visikindsty;
           const aflags: addressflagsty; var aoffset: dataoffsty;
                                      var atypeflags: typeflagsty);
 //callstack:  |stackindex 1              2            3        3+identcount
 //            recordfield,checksemicolon,commaidents2,ident...,gettype
 //            |result ck_field...
 //            |------------------3--------------------|
var
 po1: pfielddataty;
 po2: ptypedataty;
// ele1: elementoffsetty;
 size1: dataoffsty;
 i1,elecount: int32;
begin 
 with info do begin
  elecount:= s.stacktop-s.stackindex-3;
 {$ifdef mse_checkinternalerror}
  if (elecount < 1) or 
               (contextstack[s.stacktop].d.kind <> ck_fieldtype) then begin
   internalerror(ie_type,'20140325C');
  end;
 {$endif}
  for i1:= s.stackindex to s.stackindex + elecount - 1 do begin
  {$ifdef mse_checkinternalerror}
   if contextstack[i1+3].d.kind <> ck_ident then begin
    internalerror(ie_type,'20151016');
   end;
  {$endif}
   if not ele.addelementduplicatedata(contextstack[i1+3].d.ident.ident,
                                            ek_field,avisibility,po1) then begin
    identerror(2,err_duplicateidentifier);
   end;
   po1^.flags:= aflags;
   po1^.offset:= aoffset;
   po1^.vf.flags:= [];
   with ptypedataty(ele.parentdata)^ do begin
    po1^.vf.next:= fieldchain;
    fieldchain:= ele.eledatarel(po1);
   end;
   with contextstack[s.stacktop] do begin
    po1^.vf.typ:= d.typ.typedata;
    po1^.indirectlevel:= d.typ.indirectlevel;
    po2:= ptypedataty(ele.eledataabs(po1^.vf.typ));
    if po1^.indirectlevel = 0 then begin      //todo: alignment
//     if po2^.h.flags * [tf_managed,tf_hasmanaged] <> [] then begin
     if tf_needsmanage in po2^.h.flags then begin
      include(atypeflags,tf_needsmanage);
      include(po1^.vf.flags,tf_needsmanage);
      {
      with pmanageddataty(
              pointer(ele.addelementduplicate(tks_managed,[vik_managed],
                                                                ek_managed))+
                                             sizeof(elementheaderty))^ do begin
       managedele:= ele.eledatarel(po1);
      end;
      }
     end;
     size1:= po2^.h.bytesize;
    end
    else begin
     size1:= pointersize;
    end;
   end;
   aoffset:= aoffset+size1;
   with contextstack[i1].d do begin
    kind:= ck_field;
    field.fielddata:= ele.eledatarel(po1);
   end;
  end;
  s.stacktop:= s.stackindex+elecount;
 end;
end;

procedure handlerecordfield();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDFIELD');
{$endif}
 with info do begin
  checkrecordfield(allvisi,[],contextstack[s.stackindex-1].d.rec.fieldoffset,
                            contextstack[s.stackindex-2].d.typ.flags);
 end;
end;
var testvar1: elementoffsetty; testvar2: pinternalsubdataty;
procedure createrecordmanagehandlersubs(const atyp: elementoffsetty);
var
 ele1,typele1: elementoffsetty;
 field1: pfielddataty;
 typ1,typ2: ptypedataty;
 sub1: pinternalsubdataty;
 op1: managedopty;
 ad1: addressrefty;
 locad1: memopty;
 i1,i2: int32;
begin
 with info do begin
  with locad1 do begin
   t:= bitoptypes[das_pointer];
   with locdataaddress do begin
    if co_llvm in compileoptions then begin
     a.address:= 0; //first param
    end
    else begin
     a.address:= -pointersize-stacklinksize; //single pointer param
    end;
    a.framelevel:= -1;    
    offset:= 0;
   end;
  end;
  ad1.kind:= ark_stackref;
  ad1.address:= -pointersize; //pointer to var
  ad1.offset:= 0;
//  ele.checkcapacity(ek_internalsub,ord(high(op1))+1); //used in startsimplesub()
  typ1:= ele.eledataabs(atyp);
  for op1:= low(op1) to mo_decref do begin //mo_decrefindi?
   sub1:= ele.eledataabs(typ1^.recordmanagehandlers[op1]);
testvar1:= ele.eledatarel(sub1);
   sub1^.address:= startsimplesub(datatoele(sub1)^.header.name,true);
   if sub1^.calllinks <> 0 then begin
    linkresolvecall(sub1^.calllinks,sub1^.address,-1); 
                                //fetch globid from subbegin op
   end;
   ele1:= ptypedataty(ele.eledataabs(atyp))^.fieldchain;
   with additem(oc_pushlocpo)^.par do begin
    memop:= locad1; 
   end;
//   pushtemppo(locad1);
   i1:= 0; //field offset
   while ele1 <> 0 do begin
    field1:= ele.eledataabs(ele1);
    typ2:= ele.eledataabs(field1^.vf.typ);
    if typ2^.h.manageproc <> nil then begin
     i1:= field1^.offset - i1;
     if i1 > 0 then begin
      i2:= s.ssa.nextindex-1;
      with additem(oc_offsetpoimm32)^ do begin
       setimmint32(i1,par);
       par.ssas1:= i2;
      end;
     end;
     ad1.typ:= typ2;
     ad1.ssaindex:= s.ssa.nextindex-1;
     typ2^.h.manageproc(op1,{typ2,}ad1);
     i1:= field1^.offset; 
    end;
    ele1:= field1^.vf.next;
   end;
   poptemp(pointersize);
   endsimplesub(true);
  end;
 end;
(*
 with info do begin
  with locad1 do begin
   t:= bitoptypes[das_pointer];
   with locdataaddress do begin
    if co_llvm in compileoptions then begin
     a.address:= 0; //first param
    end
    else begin
     a.address:= -pointersize-stacklinksize; //single pointer param
    end;
    a.framelevel:= -1;    
    offset:= 0;
   end;
  end;
  ad1.base:= ab_stackref;
  ad1.address:= -pointersize; //pointer to var
  ad1.offset:= 0;
  ad1.flags:= [];
//  ele.checkcapacity(ek_internalsub,ord(high(op1))+1); //used in startsimplesub()
  typ1:= ele.eledataabs(atyp);
  for op1:= low(op1) to mo_decref do begin //mo_decrefindi?
   sub1:= ele.eledataabs(typ1^.recordmanagehandlers[op1]);
testvar1:= ele.eledatarel(sub1);
   sub1^.address:= startsimplesub(datatoele(sub1)^.header.name,true);
   if sub1^.calllinks <> 0 then begin
    linkresolvecall(sub1^.calllinks,sub1^.address,-1); 
                                //fetch globid from subbegin op
   end;
   ele1:= ptypedataty(ele.eledataabs(atyp))^.fieldchain;
   with additem(oc_pushlocpo)^.par do begin
    memop:= locad1; 
   end;
//   pushtemppo(locad1);
   i1:= 0; //field offset
   while ele1 <> 0 do begin
    field1:= ele.eledataabs(ele1);
    typ2:= ele.eledataabs(field1^.vf.typ);
    if typ2^.h.manageproc <> nil then begin
     i1:= field1^.offset - i1;
     if i1 > 0 then begin
      i2:= s.ssa.nextindex-1;
      with additem(oc_offsetpoimm32)^ do begin
       setimmint32(i1,par);
       par.ssas1:= i2;
      end;
     end;
     typ2^.h.manageproc(op1,typ2,ad1,s.ssa.nextindex-1);
     i1:= field1^.offset; 
    end;
    ele1:= field1^.vf.next;
   end;
   poptemp(pointersize);
   endsimplesub(true);
  end;
 end;
*)
end;
var testvar3: popinfoty;
procedure createrecordmanagehandler(const atyp: elementoffsetty);
var
 op1: managedopty;
 ele1: elementoffsetty;
 sub1: pinternalsubdataty;
 typ1: ptypedataty;
begin
 with info do begin
  ptypedataty(ele.eledataabs(atyp))^.h.manageproc:= @managerecord;
  ele1:= ele.elementparent;
  with s.unitinfo^ do begin
   if us_implementation in state then begin
    ele.elementparent:= implementationelement;
   end
   else begin
    ele.elementparent:= interfaceelement;
   end;
  end;
  ele.checkcapacity(ek_internalsub,ord(high(op1))+1);
  typ1:= ele.eledataabs(atyp);
  for op1:= low(op1) to high(op1) do begin
   sub1:= ele.addelementdata(managedopids[op1],ek_internalsub,allvisi);
testvar1:= ele.eledatarel(sub1);
   sub1^.address:= 0;
   sub1^.calllinks:= 0;
   typ1^.recordmanagehandlers[op1]:= ele.eledatarel(sub1);
  end;
testvar1:= ptypedataty(ele.eledataabs(atyp))^.recordmanagehandlers[low(op1)];
  ele.elementparent:= ele1;
  if (sublevel = 0) and
            (stf_implementation in s.currentstatementflags) then begin
   createrecordmanagehandlersubs(atyp);
  end
  else begin
   typ1^.h.next:= s.unitinfo^.pendingmanagechain;
   s.unitinfo^.pendingmanagechain:= atyp;
                           //add to pending list
  end;
testvar2:= ele.eledataabs(
      ptypedataty(ele.eledataabs(atyp))^.recordmanagehandlers[low(op1)]);
testvar3:= getoppo(testvar2^.address);
 end;
end;

procedure checkpendingmanagehandlers();
var
 ele1,ele2: elementoffsetty;
 typ1: ptypedataty;
begin
 with info do begin
  ele1:= s.unitinfo^.pendingmanagechain;
  while ele1 <> 0 do begin
   typ1:= ele.eledataabs(ele1);
   ele2:= ele1;
   ele1:= typ1^.h.next;
   case typ1^.h.kind of
    dk_record: begin
     createrecordmanagehandlersubs(ele2);
    end;
    else begin
     notimplementederror('20160314D');
    end;
   end;
  end;
  s.unitinfo^.pendingmanagechain:= 0;
 end;
end;

procedure handlerecordtype();
var
 int1: integer;
 int2: dataoffsty;
 ty1: ptypedataty;
 offs1,offs2,offs3: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDTYPE');
{$endif}
 with info do begin
  ele.elementparent:= contextstack[s.stackindex].b.eleparent; //restore
  with contextstack[s.stackindex-1] do begin
   ty1:= ptypedataty(ele.eledataabs(d.typ.typedata));
   inittypedatabyte(ty1^,dk_record,d.typ.indirectlevel,
                     contextstack[s.stackindex].d.rec.fieldoffset,d.typ.flags);
   resolveforwardtype(ty1);
   offs1:= ty1^.fieldchain;
   offs3:= 0;
   while offs1 <> 0 do begin      //reverse order
    with pfielddataty(ele.eledataabs(offs1))^ do begin
     offs2:= vf.next;
     vf.next:= offs3;
    end;
    offs3:= offs1;
    offs1:= offs2;
   end;
   ty1^.fieldchain:= offs3;
   with ty1^ do begin
    if tf_needsmanage in h.flags then begin
     createrecordmanagehandler(d.typ.typedata);
    end;
   end;
  end;
 end;
end;

procedure handlesettype();
var
 po1: ptypedataty;
 ele1: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('SETTYPE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (s.stacktop-s.stackindex = 1) and (d.typ.typedata <> 0) then begin
   ele1:= d.typ.typedata;
   po1:= ele.eledataabs(ele1);
   if d.typ.indirectlevel = 0 then begin
    case po1^.h.kind of        //todo: check size and offset
     dk_boolean,dk_integer,dk_cardinal: begin
     end;
     dk_enum: begin
      if not (enf_contiguous in po1^.infoenum.flags) then begin
                            //todo: remove this constraint
       errormessage(err_setelemustbecontiguous,[],1);
       exit;
      end
      else begin
      end; 
     end;
     else begin
      errormessage(err_illegalsetele,[],1);
      exit;
     end;
    end;
    if not ele.addelementdata(gettypeident(),ek_type,allvisi,po1) then begin
     identerror(-2,err_duplicateidentifier);
     exit;
    end;
    inittypedatasize(po1^,dk_set,
           contextstack[s.stackindex-1].d.typ.indirectlevel,das_32);
    with {contextstack[s.stackindex-1],}po1^ do begin
    {
     kind:= dk_set; //fieldchain set in handlerecorddefstart()
     datasize:= das_32;
     bytesize:= 4;
     bitsize:= 32;
     indirectlevel:= d.typ.indirectlevel;
    }
     infoset.itemtype:= ele1;
     resolveforwardtype(po1);
    end;
   end
   else begin
    errormessage(err_illegalsetele,[],1);
   end;
  end;
 end;
end;

procedure handlearraytype();
var
 int1,int2: integer;
 arty: ptypedataty;
 itemtyoffs1: elementoffsetty;
 indilev: integer;
 po1: ptypedataty;
 id1: identty;
 totsize,si1: int64;

 procedure err(const aerror: errorty);
 begin
  with info do begin
   errormessage(aerror,[],int1-s.stackindex); 
   if arty <> nil then begin
    ele.hideelementdata(arty);
   end;
   contextstack[s.stackindex-1].d.kind:= ck_none;
  end;
 end;

var
 range: ordrangety;
 flags1: typeflagsty;
 itemcount1: int32;
// itemtype1: ptypedataty;
 manageproc1: managedtypeprocty;
 isopenarray: boolean;
 
label
 endlab;
 
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYTYPE');
{$endif}
 with info do begin
  int1:= s.stacktop-s.stackindex-2;
  itemcount1:= 1;
  if (contextstack[s.stacktop].d.kind = ck_fieldtype) then begin
   arty:= nil;
   with contextstack[s.stacktop] do begin //item type
    itemtyoffs1:= d.typ.typedata;
    with ptypedataty(ele.eledataabs(itemtyoffs1))^ do begin
     flags1:= h.flags;
     indilev:= d.typ.indirectlevel;
//     if indilev + h.indirectlevel > 0 then begin //??? why addition?
     if indilev > 0 then begin
      totsize:= pointersize;
      flags1:= flags1 - [tf_managed,tf_needsmanage];
     end
     else begin
      totsize:= h.bytesize;
      if h.kind = dk_array then begin
       itemcount1:= infoarray.i.totitemcount;
      end;
     end;
    end;
   end;  //todo: alignment
   if (int1 > 0) then begin  //static array
    manageproc1:= nil;
    po1:= ele.eledataabs(itemtyoffs1);
    if tf_needsmanage in po1^.h.flags then begin
     while po1^.h.kind = dk_array do begin
      po1:= ele.eledataabs(po1^.infoarray.i.itemtypedata);
     end;
     case po1^.h.kind of  
                //optimized versions for single level nesting
      dk_dynarray: begin
       if tf_needsmanage in ptypedataty(ele.eledataabs(
              po1^.infodynarray.i.itemtypedata))^.h.flags then begin
        notimplementederror('20160312C');
       end
       else begin
        manageproc1:= @managearraydynar;
       end;
      end;
      dk_string8: begin
       manageproc1:= @managearraystring8;
      end;
      else begin
       notimplementederror('20160312D');
      end;
     end;
    end;
    int2:= s.stackindex + 2;
    
    for int1:= s.stacktop-1 downto int2 do begin
     with contextstack[int1] do begin
     {$ifdef mse_checkinternalerror}
      if d.kind <> ck_fieldtype then begin
       internalerror(ie_type,'20140327A');
      end;
     {$endif}
      po1:= ele.eledataabs(d.typ.typedata);
      if (d.typ.indirectlevel <> 0) or (po1^.h.indirectlevel <> 0) or
        not (po1^.h.kind in ordinaldatakinds) or 
                                         (po1^.h.bitsize > 32) then begin
       err(err_ordtypeexpected);
       goto endlab;
      end;
      if (po1^.h.kind = dk_enum) and 
                   not (enf_contiguous in po1^.infoenum.flags) then begin
       err(err_enumnotcontiguous);
       goto endlab;       
      end;
      if int1 = int2 then begin //first dimension
       with contextstack[s.stackindex-2] do begin
        if (d.kind = ck_ident) and 
                   (contextstack[s.stackindex-1].d.kind = ck_typetype) then begin
         id1:= d.ident.ident; //typedef
        end
        else begin
         id1:= getident();    //fielddef
        end;
       end;
      end
      else begin
       id1:= getident(); //multi dimension
      end;
      if not ele.addelementdata(id1,ek_type,allvisi,arty) then begin
       identerror(s.stacktop-s.stackindex,err_duplicateidentifier);
       goto endlab;
      end;
      exclude(flags1,tf_managed); //only item type can be managed
//      if indilev > 0 then begin
//       flags1:= flags1 - [tf_managed,tf_needsmanage];
//      end;
//      arty^.h.flags:= flags1;
      inittypedata(arty^,dk_array,0,flags1,0,0);
//      arty^.h.manageproc:= manageproc1;
      with arty^.infoarray do begin
       i.itemtypedata:= itemtyoffs1;
       i.itemindirectlevel:= indilev;
       indextypedata:= d.typ.typedata;
      end;
      indilev:= 0; //no indirectlevel for multi dimensions
      getordrange(po1,range);
      si1:= range.max-range.min+1;
      if (si1 > maxint) and (totsize > maxint) then begin
       err(err_dataeletoolarge);
       goto endlab;
      end;
      if range.max < range.min then begin
       errormessage(err_highlowerlow,[],int1-s.stackindex);
       ele.hideelementdata(arty);
       goto endlab;     
      end;
      totsize:= si1*totsize;
      itemcount1:= itemcount1*si1;
      if totsize > maxint then begin
       err(err_dataeletoolarge);
       goto endlab;
      end;
      with arty^ do begin
//       h.indirectlevel:= 0;
       h.bitsize:= totsize*8;
       h.bytesize:= totsize;
       infoarray.i.totitemcount:= itemcount1;
       h.datasize:= das_none;
//       h.kind:= dk_array;
       h.manageproc:= manageproc1;
      end;
      itemtyoffs1:= ele.eledatarel(arty);
//      indilev:= 0;
     end;
    end;
   end
   else begin //dynamic or open array
    if int1 = -1 then begin
     with contextstack[s.stackindex-2] do begin
      if (d.kind = ck_ident) and 
                 (contextstack[s.stackindex-1].d.kind = ck_typetype) then begin
       id1:= d.ident.ident; //typedef
      end
      else begin
       id1:= getident();    //fielddef
      end;
     end;
     if not ele.addelementdata(id1,ek_type,allvisi,arty) then begin
      identerror(s.stacktop-s.stackindex,err_duplicateidentifier);
      goto endlab;
     end;
     if stf_paramsdef in s.currentstatementflags then begin
      inittypedatabyte(arty^,dk_openarray,0,sizeof(openarrayty),[]);
      isopenarray:= true;
     end
     else begin
      inittypedatasize(arty^,dk_dynarray,0,das_pointer,
                                      [tf_managed,tf_needsmanage]);
      isopenarray:= false;
     end;
     with arty^ do begin
      po1:= ele.eledataabs(itemtyoffs1);
      if tf_needsmanage in po1^.h.flags then begin
       case po1^.h.kind of  //optimized versions for single level nesting
        dk_dynarray: begin
         if tf_needsmanage in ptypedataty(ele.eledataabs(
                po1^.infodynarray.i.itemtypedata))^.h.flags then begin
          notimplementederror('20160312A');
         end
         else begin
          h.manageproc:= @managedynarraydynar;
         end;
        end;
        dk_string8: begin
         h.manageproc:= @managedynarraystring8;
        end;
        else begin
         notimplementederror('20160312B');
        end;
       end;
      end
      else begin
       h.manageproc:= @managedynarray;
      end;
      itemsize:= totsize;
      infodynarray.i.itemtypedata:= itemtyoffs1;
      infodynarray.i.itemindirectlevel:= indilev;
     end;
    end
    else begin
{$ifdef mse_checkinternalerror}                             
     internalerror(ie_type,'20140915A');
{$endif}
    end;
   end;
   with contextstack[s.stackindex-1] do begin
    arty^.h.indirectlevel:= d.typ.indirectlevel;
    d.typ.indirectlevel:= 0;
    d.typ.typedata:= ele.eledatarel(arty);
   end;
   resolveforwardtype(arty);
  end
  else begin
{$ifdef mse_checkinternalerror}                             
   internalerror(ie_type,'20140915B');
{$endif}
  end;
endlab:
  s.stacktop:= s.stackindex-1;
  s.stackindex:= contextstack[s.stackindex-1].parent;  
 end;
end;

procedure handlearraydeferror1();
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYDEFERROR1');
{$endif}
 tokenexpectederror('of',erl_fatal);
end;

procedure handlearrayindexerror1();
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYINDEXERROR1');
{$endif}
 tokenexpectederror('[',erl_fatal);
end;

procedure handlearrayindexerror2();
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYINDEXERROR2');
{$endif}
 tokenexpectederror(']',erl_fatal);
end;

procedure handleindexstart();
begin
{$ifdef mse_debugparser}
 outhandle('INDEXSTART');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if d.kind = ck_prop then begin
   with contextstack[s.stackindex] do begin
    d.kind:= ck_index;
   end;
  end
  else begin
   getaddress(-1,true);
   handleindexitemstart();
  end;
 end;
end;

procedure handleindexitemstart();
var
 kind1: datakindty;
 i1: int32;
 t1: typeinfoty;
 po1: pcontextdataty;
begin
{$ifdef mse_debugparser}
 outhandle('INDEXITEMSTART');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if d.kind <> ck_prop then begin
 {$ifdef msecheckinternalerror}
   if (d.kind <> ck_fact) or (d.dat.datatyp.indirectlevel <> 1) then begin
    internalerror(ie_handler,'20160227D');
   end;
 {$endif}
   po1:= @contextstack[s.stackindex].d;
   po1^.kind:= ck_getindex;
   kind1:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.kind;
   exclude(d.handlerflags,hf_needsunique);
   case kind1 of
    dk_openarray: begin
     i1:= s.ssa.nextindex-1;
     with insertitem(oc_offsetpoimm32,-1,-1)^ do begin //at end of context
      setimmint32(sizeof(openarrayty.high),par); //pointer to openarrayty.data
      par.ssas1:= i1;
     end;
     i1:= s.ssa.nextindex-1;
     with insertitem(oc_indirectpo,-1,-1)^ do begin //at end of context
                     //openarray.data
      par.ssas1:= i1;
     end;
     dec(d.dat.datatyp.indirectlevel);
    end;
    dk_dynarray,dk_string8: begin
     if kind1 = dk_string8 then begin
      include(d.handlerflags,hf_needsunique);
      d.dat.fact.opoffset:= getcontextopoffset(-1); //for needsunique call
     end;
     dec(d.dat.indirection);
     dec(d.dat.datatyp.indirectlevel);
     getvalue(-1,das_none);
    end;
   end;
  end;
 end;
end;

procedure handleindexitem();
var
 lastssa: int32;
 itemtype,indextype: ptypedataty;
 isdynarray: boolean;
 range: ordrangety;
 li1: int64;
label
 errorlab;
begin
{$ifdef mse_debugparser}
 outhandle('INDEXITEM');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if d.kind <> ck_prop then begin //no array property
  {$ifdef mse_checkinternalerror}
   if contextstack[s.stackindex].d.kind <> ck_getindex then begin
    internalerror(ie_handler,'20160527');
   end;
  {$endif}
   itemtype:= ele.eledataabs(d.dat.datatyp.typedata);
   isdynarray:= true;
   case itemtype^.h.kind of
    dk_dynarray,dk_openarray: begin
     if d.dat.datatyp.indirectlevel <> 0 then begin
      errormessage(err_illegalqualifier,[],1);
      goto errorlab;
     end;
     itemtype:= ele.eledataabs(itemtype^.infodynarray.i.itemtypedata);
     range.min:= 0;
    end;
    dk_string8: begin
     if d.dat.datatyp.indirectlevel <> 0 then begin
      errormessage(err_illegalqualifier,[],1);
      goto errorlab;
     end;
     range.min:= 1;
     itemtype:= ele.eledataabs(sysdatatypes[st_char8].typedata);
    end;
    dk_array: begin
     if d.dat.datatyp.indirectlevel <> 1 then begin
      errormessage(err_illegalqualifier,[],1);
      goto errorlab;
     end;
     isdynarray:= false;
    end;
    else begin
     isdynarray:= false;
    end;
   end;
   if isdynarray then begin
    if not tryconvert(1,st_int32) then begin
     errormessage(err_illegalqualifier,[],1);
     goto errorlab;
    end;
   end
   else begin
    indextype:= ele.eledataabs(itemtype^.infoarray.indextypedata);
    getordrange(ele.eledataabs(itemtype^.infoarray.indextypedata),range);
    itemtype:= ele.eledataabs(itemtype^.infoarray.i.itemtypedata); 
    if not tryconvert(1,indextype,0,[]) then begin
     errormessage(err_illegalqualifier,[],1);
     goto errorlab;
    end;
   end;
   with contextstack[s.stacktop] do begin
    if d.kind = ck_const then begin
     li1:= getordconst(d.dat.constval);
     if (li1 < range.min) or 
                       not isdynarray and (li1 > range.max) then begin
      rangeerror(range,1);
      goto errorlab;
     end;
     
    end;
    getvalue(1,das_32);
    if not tryconvert(1,st_int32) then begin
     errormessage(err_illegalqualifier,[],1);
     goto errorlab;
    end;
    if range.min <> 0 then begin
     lastssa:= d.dat.fact.ssaindex;
     with insertitem(oc_addimmint32,1,-1)^ do begin
      par.ssas1:= lastssa;
      setimmint32(-range.min,par);
     end;
    end;
    lastssa:= d.dat.fact.ssaindex;
    with insertitem(oc_mulimmint32,1,-1)^ do begin
     par.ssas1:= lastssa;
     setimmint32(itemtype^.h.bytesize,par);
    end;
   end;
                                                        //next dimension
   with additem(oc_addpoint32)^ do begin
    par.ssas1:= d.dat.fact.ssaindex;
    par.ssas2:= contextstack[s.stacktop].d.dat.fact.ssaindex;
    d.dat.fact.ssaindex:= par.ssad; //new pointer
   end;
   d.dat.datatyp.typedata:= ele.eledatarel(itemtype);
   d.dat.datatyp.indirectlevel:= itemtype^.h.indirectlevel+1; //pointer
           //opdatatype is already pointer
errorlab:
   dec(s.stacktop);
  end;
 end;
end;

procedure handleindex();
begin
{$ifdef mse_debugparser}
 outhandle('INDEX');
{$endif}
 with info,contextstack[s.stackindex] do begin
  if d.kind = ck_index then begin //for indexed property
   include(contextstack[s.stacktop].d.handlerflags,hf_propindex);
  end
  else begin
   s.stacktop:= s.stackindex-1;
   with contextstack[s.stacktop] do begin
    dec(d.dat.indirection);
    dec(d.dat.datatyp.indirectlevel);
   end;
  end;
  s.stackindex:= parent;
 end;
end;


procedure handleenumdefentry();
var
 po1: ptypedataty;
 ele1: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('ENUMDEFENTRY');
{$endif}
 with info do begin
 {$ifdef mse_checkinternalerror}
  if contextstack[s.stackindex-2].d.kind <> ck_ident then begin
   internalerror(ie_type,'20140603A');
  end;
  if contextstack[s.stackindex-1].d.kind <> ck_typetype then begin
   internalerror(ie_type,'20140603B');
  end;
 {$endif}
  if not ele.pushelementduplicatedata(contextstack[s.stackindex-2].d.ident.ident,
                                               ek_type,allvisi,po1) then begin
   identerror(-2,err_duplicateidentifier);
  end;
  ele1:= ele.eledatarel(po1);
  with contextstack[s.stackindex-1] do begin
   d.typ.typedata:= ele1;
  end;
  with contextstack[s.stackindex] do begin
   d.kind:= ck_enumdef;
   d.enu.value:= 0;
   d.enu.enum:= ele1;
   d.enu.first:= 0;
   d.enu.flags:= [enf_contiguous];
  end;
  with po1^ do begin
   h.kind:= dk_none; //incomplete
  end;
 end;
end;

procedure handleenumdef();
var
 po1: ptypedataty;
 int1: integer;
 ele1,ele2,ele3: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('ENUMDEF');
{$endif}
 with info do begin
  ele2:= contextstack[s.stackindex].d.enu.first;
  ele1:= 0;
  ele3:= 0;
  int1:= 0;
  while ele2 <> 0 do begin
   inc(int1);
   with ptypedataty(ele.eledataabs(ele2))^.infoenumitem do begin
                       //reverse order
    ele3:= ele2;
    ele2:= next;
    next:= ele1;
    ele1:= ele3;
   end;
  end;
  with contextstack[s.stackindex-1] do begin
   po1:= ptypedataty(ele.eledataabs(d.typ.typedata));
   inittypedatasize(po1^,dk_enum,d.typ.indirectlevel,das_32);
   with po1^.infoenum do begin
    with contextstack[s.stackindex] do begin
     flags:= d.enu.flags;
     last:= d.enu.first;
    end;
    first:= ele3;
    itemcount:= int1;
   end;
  end;
  ele.popelement();
 end;
end;

procedure doenumitem(const avalue: integer);
var
 po1: ptypedataty;
 po2: prefdataty;
 ele1: elementoffsetty;
 ident1: identty;
begin
 with info,contextstack[s.stackindex] do begin
  ident1:= contextstack[s.stackindex+1].d.ident.ident;
  ele.checkcapacity(elesizes[ek_type]+elesizes[ek_ref]); //ensure valid po1
  if ele.addelementdata(ident1,ek_type,allvisi,po1) then begin
   inittypedatasize(po1^,dk_enumitem,0,das_32);
   with po1^ do begin
    infoenumitem.value:= avalue;
    with contextstack[parent] do begin
     infoenumitem.enum:= d.enu.enum;
     if d.enu.value <> avalue then begin
      exclude(d.enu.flags,enf_contiguous);
     end;
     d.enu.value:= avalue+1;
     infoenumitem.next:= d.enu.first;
     d.enu.first:= ele.eledatarel(po1);
    end;
   end;
   ele1:= ele.decelementparent();
   if ele.addelementdata(ident1,ek_ref,allvisi,po2) then begin
    po2^.ref:= ele.eledatarel(po1);    //non qualified name copy
   end
   else begin
    identerror(1,err_duplicateidentifier);
   end;
   ele.elementparent:= ele1;
  end
  else begin
   identerror(1,err_duplicateidentifier);
  end;
 end;
end;

procedure handleenumitem();
begin
{$ifdef mse_debugparser}
 outhandle('ENUMITEM');
{$endif}
 with info do begin
  doenumitem(contextstack[contextstack[s.stackindex].parent].d.enu.value);
 end;
end;

procedure handleenumitemvalue();
begin
{$ifdef mse_debugparser}
 outhandle('ENUMITEMVALUE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (d.kind <> ck_const) or (d.dat.constval.kind <> dk_integer) then begin
                            //todo: check already defined enum
   errormessage(err_ordinalconstexpected,[]);
   dec(s.stackindex);
   s.stacktop:= s.stackindex;
  end
  else begin
   dec(s.stacktop);
   doenumitem(d.dat.constval.vinteger);
  end;
 end;
end;
{
type
 enuty = (en_0,en_1,en_2);
var
 en1: enuty;
initialization
 writeln(en_1);
 en1:= en_1;
 writeln(en1);
}
end.