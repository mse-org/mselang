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
 globtypes,parserglob,handlerglob;

procedure handletypedefentry();
procedure handletype();
procedure handlegettypetypestart();
procedure handlegetfieldtypestart();
procedure handletrygetfieldtypestart();
procedure handlepointertype();
procedure handlechecktypeident();
procedure handlecheckrangetype();
procedure handlenamedtype();
 
procedure handlerecorddefstart();
procedure handlerecorddeferror();
procedure handlerecordtype();
procedure handlerecordfield();
procedure handlerecordcasestart();
procedure handlerecordcase1();
procedure handlerecordcasetype();
procedure handlecaseofexpected();
procedure handlerecordcase4();
procedure handlerecordcase5();
procedure handlerecordcase6();
procedure handlerecordcase7();
procedure handlerecordcaseitementry();
procedure handlerecordcaseitem();
procedure handlerecordcase();

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
               var atypeflags: typeflagsty; const iscasekey: boolean = false);
procedure setsubtype(atypetypecontext: int32;
                                           const asub: elementoffsetty);
procedure checkpendingmanagehandlers();
procedure reversefieldchain(const atyp: ptypedataty);
procedure reversesubchain(const atyp: ptypedataty);
procedure createrecordmanagehandler(const atyp: elementoffsetty);
function gettypeident(): identty;

implementation
uses
 elements,errorhandler,handlerutils,parser,opcode,stackops,
 opglob,managedtypes,unithandler,identutils,valuehandler,subhandler,llvmlists,
 segmentutils,__mla__internaltypes,grammarglob;

procedure handletypedefentry();
begin
{$ifdef mse_debugparser}
 outhandle('TYPEDEFENTRY');
{$endif}
 with info,contextstack[s.stacktop] do begin
  d.kind:= ck_typedef;
 end;
end;

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

procedure initypecontext(const akind: contextkindty);
begin
 with info,contextstack[s.stackindex] do begin
  d.kind:= akind;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
  d.typ.forwardident:= 0;
  d.typ.flags:= [];
 end;
end;

procedure handlegetfieldtypestart();
begin
{$ifdef mse_debugparser}
 outhandle('GETFIELDTYPESTART');
{$endif}
 initypecontext(ck_fieldtype);
end;

procedure handletrygetfieldtypestart();
begin
{$ifdef mse_debugparser}
 outhandle('TRYGETFIELDTYPESTART');
{$endif}
 initypecontext(ck_fieldtype);
 with info,contextstack[s.stackindex] do begin
  d.typ.flags:= [tf_canforward];
 end;
end;

procedure handlegettypetypestart();
begin
{$ifdef mse_debugparser}
 outhandle('GETTYPETYPESTART');
{$endif}
 initypecontext(ck_typetype);
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
  currenttypedef:= 0;
  ele.checkcapacity(ek_type);
  bo1:= ((d.typ.indirectlevel > 0) or (tf_canforward in d.typ.flags)) and
                                               (s.stacktop-s.stackindex = 1);
                                        //simple type name only
  if (stf_paramsdef in info.s.currentstatementflags) and
                (s.stacktop-s.stackindex = 1) and (d.typ.indirectlevel = 0) and
                 (contextstack[s.stacktop].d.ident.ident = tk_const) then begin
   po2:= ele.eleinfoabs(getsystypeele(st_none));
   bo2:= true;
  end
  else begin
   bo2:= findkindelements(1,[{ek_type}],allvisi,po2,bo1);
   if bo2 and (po2^.header.kind <> ek_type) then begin
    errormessage(err_typeidentexpected,[],1);
    bo2:= false;
   end;
  end;
  forward1:= not bo2 and bo1;
  if forward1 then begin
   if tf_canforward in d.typ.flags then begin
   {$ifdef mse_checkinternalerror}
    if contextstack[s.stacktop].d.kind <> ck_ident then begin
     internalerror(ie_handler,'20171020A');
    end;
   {$endif}
    d.typ.forwardident:= contextstack[s.stacktop].d.ident.ident;
   end
   else begin //forward pointer
    po2:= ele.eleinfoabs(getsystypeele(st_forward));
    bo2:= true;
   end;
  end;
  if bo2 then begin
   d.typ.typedata:= ele.eleinforel(po2);
   currenttypedef:= d.typ.typedata;
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
     if forward1 or (tf_forward in po3^.h.flags) then begin
      markforwardtype(po4,contextstack[s.stacktop].d.ident.ident);
     end
     else begin
      resolveforwardtype(po4);
     end;
     currenttypedef:= ele.eledatarel(po4);
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
 id1: identty;
 bo1: boolean;
begin
 with info do begin
  atypetypecontext:= atypetypecontext+s.stackindex;
  bo1:= contextstack[atypetypecontext].d.kind = ck_fieldtype;
  if bo1 then begin
   id1:= getident(); //anomymous type
  end
  else begin
  {$ifdef mse_checkinternalerror}
   if (contextstack[atypetypecontext].d.kind <> ck_typetype) or
    (contextstack[atypetypecontext-1].d.kind <> ck_ident) then begin
    internalerror(ie_handler,'20150425A');
   end;
  {$endif}
   id1:= contextstack[atypetypecontext-1].d.ident.ident;
  end;
  if not ele.addelementdata(id1,ek_type,allvisi,po1) then begin
   identerror(atypetypecontext-1,err_duplicateidentifier);
  end
  else begin
   with contextstack[atypetypecontext] do begin
//    inc(d.typ.indirectlevel);
    if sf_ofobject in psubdataty(ele.eledataabs(asub))^.flags then begin
     inittypedatasize(po1^,dk_method,d.typ.indirectlevel,das_none);
    end
    else begin
     inittypedatasize(po1^,dk_sub,d.typ.indirectlevel,das_pointer);
    end;
    po1^.infosub.sub:= asub;
    d.typ.typedata:= ele.eledatarel(po1);
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
 poa,pob: pcontextitemty;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKRANGETYPE');
{$endif}
 with info do begin
  if getnextnospace(s.stackindex+2,poa) and 
                                getnextnospace(poa+1,pob) then begin
   if poa^.d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[],poa);
    goto endlab;
   end;
   if pob^.d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[],pob);
    goto endlab;
   end;
   if poa^.d.dat.constval.kind = dk_string then begin
    tryconvert(poa,st_char32);
   end;
   if pob^.d.dat.constval.kind = dk_string then begin
    tryconvert(pob,st_char32);
   end;
   if not (poa^.d.dat.constval.kind in rangedatakinds) then begin
    errormessage(err_ordinalconstexpected,[],poa);
    goto endlab;
   end;
   if (poa^.d.dat.constval.kind <> pob^.d.dat.constval.kind) then begin
    errormessage(err_typemismatch,[],pob);
    goto endlab;
   end;
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
    inittypedatasize(po1^,poa^.d.dat.constval.kind,d.typ.indirectlevel,das_32);
                                                       //todo: other datasizes
    include(po1^.h.flags,tf_subrange);
    case poa^.d.dat.constval.kind of
     dk_integer: begin
      with po1^.infoint32 do begin  
       min:= poa^.d.dat.constval.vinteger;
       max:= pob^.d.dat.constval.vinteger;
      end;
     end;
     dk_cardinal: begin
      with po1^.infocard32 do begin  
       min:= poa^.d.dat.constval.vcardinal;
       max:= pob^.d.dat.constval.vcardinal;
      end;
     end;
     dk_character: begin
      with po1^.infochar32 do begin  
       min:= poa^.d.dat.constval.vcharacter;
       max:= pob^.d.dat.constval.vcharacter;
      end;
     end;
    end;
   end;
  end;
endlab:
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
   d.rec.fieldoffsetmax:= 0;
   include(d.handlerflags,hf_initvariant);
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
    fieldcount:= 0;
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
  currenttypedef:= 0;
 end;
end;

procedure checkrecordfield(const avisibility: visikindsty;
           const aflags: addressflagsty; var aoffset: dataoffsty;
                      var atypeflags: typeflagsty; const iscasekey: boolean);
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
  if iscasekey then begin
   elecount:= 1;
   i1:= s.stackindex+1;
  end
  else begin
   elecount:= s.stacktop-s.stackindex-3;
   i1:= s.stackindex+3;
  end;
  if (elecount < 1) or 
               (contextstack[s.stacktop].d.kind <> ck_fieldtype) then begin
   errormessage(err_fieldtypeexpected,[]);
   exit;
  end;
  for i1:= i1 to i1 + elecount - 1 do begin
  {$ifdef mse_checkinternalerror}
   if contextstack[i1].d.kind <> ck_ident then begin
    internalerror(ie_type,'20151016');
   end;
  {$endif}
   if not ele.addelementduplicatedata(contextstack[i1].d.ident.ident,
                                            ek_field,avisibility,po1) then begin
    identerror(2,err_duplicateidentifier);
   end;
   po1^.flags:= aflags;
   po1^.offset:= aoffset;
   po1^.vf.flags:= [];
   with ptypedataty(ele.parentdata)^ do begin
    inc(fieldcount);
    po1^.vf.next:= fieldchain;
    fieldchain:= ele.eledatarel(po1);
   end;
   with contextstack[s.stacktop] do begin
    po1^.vf.typ:= d.typ.typedata;
    po1^.indirectlevel:= d.typ.indirectlevel;
    po2:= ptypedataty(ele.eledataabs(po1^.vf.typ));
    if po1^.indirectlevel = 0 then begin      //todo: alignment
     if tf_needsmanage in po2^.h.flags then begin
      include(atypeflags,tf_needsmanage);
      include(po1^.vf.flags,tf_needsmanage);
     end;
     if [tf_hascomplexini,tf_complexini] * po2^.h.flags <> [] then begin
      include(atypeflags,tf_hascomplexini);
      include(po1^.vf.flags,tf_hascomplexini);
     end;
     size1:= po2^.h.bytesize;
    end
    else begin
     size1:= targetpointersize;
    end;
   end;
   aoffset:= aoffset+size1;
   if not iscasekey then begin
    with contextstack[i1-3].d do begin
     kind:= ck_field;
     field.fielddata:= ele.eledatarel(po1);
    end;
   end;
  end;
  if not iscasekey then begin
   s.stacktop:= s.stackindex+elecount;
  end;
 end;
end;

procedure handlerecordfield();
var
 i1: int32;
 f1: typeflagsty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDFIELD');
{$endif}
 with info do begin
  with contextstack[s.stackindex-1] do begin
   f1:= [];
   if d.kind <> ck_recordcase then begin
    d.rec.fieldoffset:= d.rec.fieldoffsetmax;
   end;
   checkrecordfield(allvisi,currentfieldflags,d.rec.fieldoffset,f1);
   i1:= s.stackindex-2;
   if d.kind = ck_recordcase then begin
    dec(i1);
    if f1*managedtypeflags <> [] then begin
     errormessage(err_managednotallowed,[]);
    end;
   end
   else begin
    d.rec.fieldoffsetmax:= d.rec.fieldoffset;
    include(d.handlerflags,hf_initvariant);
   end;
   contextstack[i1].d.typ.flags:= contextstack[i1].d.typ.flags + f1;
  end;
 end;
end;

procedure handlerecordcasetype();
var
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASETYPE');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (d.typ.indirectlevel <> 0) or 
         not (ptypedataty(ele.eledataabs(d.typ.typedata))^.h.kind 
                                           in ordinaldatakinds) then begin
   errormessage(err_ordinaltypeexpected,[],s.stacktop-s.stackindex);
  end
  else begin
   if idf_continued in contextstack[s.stackindex+1].d.ident.flags then begin
    errormessage(err_illegalqualifier,[],2);
   end
   else begin
    with contextstack[s.stackindex-1] do begin
     checkrecordfield(allvisi,[],d.rec.fieldoffset,d.typ.flags,true);
    end;
   end;
  end;
 end;
end;

procedure handlerecordcasestart();
var
 p1: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASESTART');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_recordcase;
  p1:= @contextstack[s.stackindex-1];
  d.rec:= p1^.d.rec;
  exclude(d.handlerflags,hf_initvariant);
  if hf_initvariant in p1^.d.handlerflags then begin
   exclude(p1^.d.handlerflags,hf_initvariant);
   d.rec.fieldoffsetmax:= d.rec.fieldoffset;
  end;
 end;
end;

procedure handlerecordcase1();
var
 p1: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASE1');
{$endif}
 with info do begin
  if findkindelements(1,[ek_type],allvisi,p1) and 
      not (ptypedataty(eletodata(p1))^.h.kind in ordinaldatakinds) then begin
   errormessage(err_ordinaltypeexpected,[],s.stacktop-s.stackindex);
  end;
 end;
end;

procedure handlecaseofexpected();
begin
{$ifdef mse_debugparser}
 outhandle('CASEOFEXPECTED');
{$endif}
 with info do begin
  errormessage(err_syntax,['of']);
  dec(s.stackindex);
 end;
end;

procedure handlerecordcase4();
var
 p1,pe: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASE4');
{$endif}
 with info do begin
  p1:= @contextstack[s.stackindex+2]; //skip ck_recordcase and ck_fieldtype;
  pe:= @contextstack[s.stacktop];
  while (p1 <= pe) and (p1^.d.kind <> ck_space) do begin //skip ck_ident
   inc(p1);
  end;
  while p1 <= pe do begin
   while (p1^.d.kind = ck_space) and (p1 <= pe) do begin
    inc(p1);
   end;
   if p1 <= pe then begin
    if (p1^.d.kind = ck_const) and 
       ((p1^.d.dat.datatyp.indirectlevel <> 0) or
        not(ptypedataty(ele.eledataabs(p1^.d.dat.datatyp.typedata))^.h.kind in 
                                          ordinaldatakinds)) or 
                                            (p1^.d.kind <> ck_const) then begin
     errormessage(err_illegalexpression,[],p1);
    end;
    inc(p1);
   end;
  end;
 end;
end;

procedure handlerecordcase5();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASE5');
{$endif}
 with info do begin
  tokenexpectederror(':',erl_fatal);
  dec(s.stackindex);
 end;
end;

procedure handlerecordcase6();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASE6');
{$endif}
 with info do begin
  tokenexpectederror('(',erl_fatal);
  dec(s.stackindex);
 end;
end;

procedure handlerecordcase7();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASE7');
{$endif}
 with info do begin
  tokenexpectederror(')',erl_fatal);
  dec(s.stackindex);
 end;
end;

procedure handlerecordcaseitementry();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASEITEMENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.rec.fieldoffset:= contextstack[s.stackindex-1].d.rec.fieldoffset;
 end;
end;

procedure handlerecordcaseitem();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASEITEM');
{$endif}
 with info,contextstack[s.stackindex] do begin
  if d.rec.fieldoffset > d.rec.fieldoffsetmax then begin
   d.rec.fieldoffsetmax:= d.rec.fieldoffset;
   d.rec.fieldoffset:= contextstack[s.stackindex-1].d.rec.fieldoffset;
  end;
 end;
end;

procedure handlerecordcase();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDCASE');
{$endif}
 with info do begin
  contextstack[s.stackindex-1].d.rec.fieldoffsetmax:= 
        contextstack[s.stackindex].d.rec.fieldoffsetmax;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure createrecordmanagehandlersubs(const atyp: elementoffsetty);

var
 ad1: addressrefty;
 baseadssa: int32;

 procedure handlefields(const op: managedopty;
                       const atyp: elementoffsetty; var fieldoffset: int32);
 var
  ele1: elementoffsetty;
  field1: pfielddataty;
  typ2: ptypedataty;
 begin
  with ptypedataty(ele.eledataabs(atyp))^ do begin
   if (h.kind in [dk_object,dk_class]) and (h.ancestor <> 0) then begin
    handlefields(op,h.ancestor,fieldoffset);
   end;
   ele1:= ptypedataty(ele.eledataabs(atyp))^.fieldchain;
   while ele1 <> 0 do begin
    field1:= ele.eledataabs(ele1);
    typ2:= ele.eledataabs(field1^.vf.typ);
    if typ2^.h.manageproc <> nil then begin
     if (op <> mo_inizeroed) or 
            (typ2^.h.flags * [tf_complexini,tf_hascomplexini] <> []) then begin
      fieldoffset:= field1^.offset - fieldoffset;
      if fieldoffset > 0 then begin
       with additem(oc_offsetpoimm)^ do begin
        setimmint32(fieldoffset,par.imm);
        par.ssas1:= baseadssa;
        baseadssa:= par.ssad;
       end;
      end;
      ad1.typ:= typ2;
      ad1.ssaindex:= info.s.ssa.nextindex-1;
      ad1.contextindex:= info.s.stacktop;
      typ2^.h.manageproc(op,{typ2,}ad1);
      fieldoffset:= field1^.offset; 
     end;
    end;
    ele1:= field1^.vf.next;
   end;
  end;
 end;//handlefields

var
 op1: managedopty;
 ele1,typele1: elementoffsetty;
 typ1,typ2: ptypedataty;
 sub1: pinternalsubdataty;
 locad1: memopty;
 i1: int32;
 startssa: int32;
 b1: boolean;
begin
 with info do begin
  with locad1 do begin
   t:= bitoptypes[das_pointer];
   with locdataaddress do begin
    if co_llvm in o.compileoptions then begin
     a.address:= 0; //first param
    end
    else begin
     a.address:= -targetpointersize-stacklinksize; //single pointer param
    end;
    a.framelevel:= -1;    
    offset:= 0;
   end;
  end;
//  ad1.kind:= ark_stackref;
  ad1.kind:= ark_stackindi;
  ad1.address:= -targetpointersize; //pointer to var
  ad1.offset:= 0;
  ad1.isclass:= false;
//  ele.checkcapacity(ek_internalsub,ord(high(op1))+1); //used in startsimplesub()
  for op1:= low(op1) to mo_decref do begin //mo_decrefindi?
   typ1:= ele.eledataabs(atyp); //can be changed because of added items
   sub1:= ele.eledataabs(typ1^.recordmanagehandlers[op1]);
   sub1^.address:= startsimplesub(sub1,true,
             modularllvm and not (us_implementationblock in s.unitinfo^.state));
   if sub1^.calllinks <> 0 then begin
    linkresolvecall(sub1^.calllinks,sub1^.address,-1); 
                                //fetch globid from subbegin op
   end;
   with additem(oc_pushlocpo)^.par do begin
    memop:= locad1; 
   end;
//   pushtemppo(locad1);
   i1:= 0; //field offset
   startssa:= info.s.ssa.nextindex-1;
   baseadssa:= startssa;
   if typ1^.h.kind = dk_record then begin
    handlefields(op1,atyp,i1);
   end
   else begin //dk_object, dk_class
    b1:= true;
    case op1 of
     mo_ini,mo_inizeroed: begin
      if (op1 <> mo_inizeroed) and ((icf_zeroinit in typ1^.infoclass.flags) or 
                     not (icf_nozeroinit in typ1^.infoclass.flags)) then begin
       with additem(oc_zeromem)^ do begin
        par.ssas1:= baseadssa;//info.s.ssa.nextindex-1;
        setimmint32(typ1^.infoclass.allocsize,par.imm);
       end;
       b1:= false; //fields zeroed
//       if tf_hascomplexini in typ1^.h.flags then begin
//        handlefields(mo_inizeroed,atyp,i1);
//       end;
       if(icf_virtual in typ1^.infoclass.flags) then begin
        with additem(oc_iniobject)^.par do begin
         ssas1:= baseadssa;
         initclass.classdef:= typ1^.infoclass.defs.address;
{
         if co_llvm in o.compileoptions then begin
          initclass.classdefid:= getclassdefid(typ1);
         end
         else begin
          initclass.classdefstackops:= typ1^.infoclass.defs.address;
         end;
}
        end;
       end;
       if tf_hascomplexini in typ1^.h.flags then begin
        handlefields(mo_inizeroed,atyp,i1);
       end;
      end
      else begin
       if(icf_virtual in typ1^.infoclass.flags) then begin
        with additem(oc_iniobject)^.par do begin
         ssas1:= baseadssa;
//         setimmint32(typ1^.infoclass.virttaboffset,initclass.virttaboffset);
         initclass.classdef:= typ1^.infoclass.defs.address;
{
         if co_llvm in o.compileoptions then begin
          initclass.classdefid:= getclassdefid(typ1);
         end
         else begin
          initclass.classdefstackops:= typ1^.infoclass.defs.address;
         end;
}
        end;
       end;
       handlefields(op1,atyp,i1); //does not touch vitual table address
       b1:= false;
      end;
      with typ1^.infoclass.subattach do begin
       if ini <> 0 then begin
        if (i1 > 0) and (co_mlaruntime in o.compileoptions) then begin
         with additem(oc_offsetpoimm)^ do begin
          setimmint32(-i1,par.imm);
         end;
        end;
        callsub(s.stacktop,ele.eledataabs(ini),s.stacktop,0,
                                  [dsf_objini,dsf_noparams],baseadssa,0,typ1);
       end;
      end;
     end;
     mo_fini: begin
      with typ1^.infoclass.subattach do begin
       if fini <> 0 then begin
        callsub(s.stacktop,ele.eledataabs(fini),s.stacktop,0,
                                 [dsf_objfini,dsf_noparams],baseadssa,0,typ1);
       end;
      end;
     end;
//     {          //for classes only
     mo_incref: begin
      with typ1^.infoclass.subattach do begin
       if incref <> 0 then begin
        callsub(s.stacktop,ele.eledataabs(incref),s.stacktop,0,
                                  [dsf_objini,dsf_noparams],baseadssa,0,typ1);
       end;
      end;
     end;
     mo_decref: begin
      with typ1^.infoclass.subattach do begin
       if decref <> 0 then begin
        handlefields(op1,atyp,i1);
        b1:= false;
        callsub(s.stacktop,ele.eledataabs(decref),s.stacktop,0,
                                 [dsf_objfini,dsf_noparams],baseadssa,0,typ1);
       end;
      end;
     end;
//     }
    end;
    if b1 then begin //not handled aready
     handlefields(op1,atyp,i1);
    end;
   end;
   poptemp(targetpointersize);
   endsimplesub(true);
  end;
  typ1:= ele.eledataabs(atyp); //can be changed because of added items
  if (typ1^.h.kind in [dk_object,dk_class]) and
     (typ1^.infoclass.subattach.destroy <> 0) then begin
   typ2:= nil;
   if typ1^.h.ancestor <> 0 then begin
    typ2:= ele.eledataabs(typ1^.h.ancestor);
    if typ2^.infoclass.subattach.destroy <> 
                       typ1^.infoclass.subattach.destroy then begin
     typ2:= nil;
    end;
   end;
   sub1:= ele.eledataabs(typ1^.recordmanagehandlers[mo_destroy]);
   if typ2 = nil then begin
    sub1^.address:= startsimplesub(sub1,true);
    if sub1^.calllinks <> 0 then begin
     linkresolvecall(sub1^.calllinks,sub1^.address,-1); 
                                 //fetch globid from subbegin op
    end;
    with additem(oc_pushlocpo)^.par do begin
     memop:= locad1;
     i1:= ssad;
    end;                    //??? invalid stackindex
    callsub(s.stacktop,ele.eledataabs(typ1^.infoclass.subattach.destroy),
             s.stacktop,0,[dsf_instanceonstack,dsf_noparams,
               dsf_useobjssa,dsf_usedestinstance,dsf_useinstancetype,
               dsf_attach,dsf_destroy,dsf_noinstancecopy],i1,0,typ1);
 //   startssa:= info.s.ssa.nextindex-1;
 //   baseadssa:= startssa;
//    poptemp(pointersize);
    endsimplesub(true);
   end
   else begin
    sub1^.address:= pinternalsubdataty(ele.eledataabs(
                          typ2^.recordmanagehandlers[mo_destroy]))^.address;
   end;
  end;
 end;
end;

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
  ele.elementparent:= atyp;
  ele.checkcapacity(ek_internalsub,ord(high(op1))+1);
  typ1:= ele.eledataabs(atyp);
  for op1:= low(op1) to high(op1) do begin
   ele.addelementduplicatedata(managedopids[op1],ek_internalsub,allvisi,sub1);
   sub1^.address:= 0;
   sub1^.calllinks:= 0;
   sub1^.flags:= [isf_pointerpar];
   typ1^.recordmanagehandlers[op1]:= ele.eledatarel(sub1);
  end;
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
 end;
end;

procedure checkpendingmanagehandlers();
var
 ele1,ele2: elementoffsetty;
 typ1: ptypedataty;
 p1: classdefinfopoty;
begin
 with info do begin
  ele1:= s.unitinfo^.pendingmanagechain;
  while ele1 <> 0 do begin
   typ1:= ele.eledataabs(ele1);
   ele2:= ele1;
   ele1:= typ1^.h.next;
   case typ1^.h.kind of
    dk_record,dk_object,dk_class: begin
     createrecordmanagehandlersubs(ele2);
     typ1:= ele.eledataabs(ele2); //can be moved
     if typ1^.h.kind in [dk_object,dk_class] then begin
      p1:= getsegmentpo(typ1^.infoclass.defs);
      p1^.header.procs[cdp_ini]:= pinternalsubdataty(
              ele.eledataabs(typ1^.recordmanagehandlers[mo_ini]))^.address;
      p1^.header.procs[cdp_fini]:= pinternalsubdataty(
              ele.eledataabs(typ1^.recordmanagehandlers[mo_fini]))^.address;
      if typ1^.infoclass.subattach.destroy <> 0 then begin
       p1^.header.procs[cdp_destruct]:= pinternalsubdataty(
               ele.eledataabs(typ1^.recordmanagehandlers[mo_destroy]))^.address;
      end;

     end;
    end;
    else begin
     notimplementederror('20160314D');
    end;
   end;
  end;
  s.unitinfo^.pendingmanagechain:= 0;
 end;
end;

procedure reversefieldchain(const atyp: ptypedataty);
var
 offs1,offs2,offs3: elementoffsetty;
begin
 offs1:= atyp^.fieldchain;
 offs3:= 0;
 while offs1 <> 0 do begin      //reverse order
  with pfielddataty(ele.eledataabs(offs1))^ do begin
   offs2:= vf.next;
   vf.next:= offs3;
  end;
  offs3:= offs1;
  offs1:= offs2;
 end;
 atyp^.fieldchain:= offs3;
end;

procedure reversesubchain(const atyp: ptypedataty);
var
 offs1,offs2,offs3: elementoffsetty;
begin
 offs1:= atyp^.infoclass.subchain;
 offs3:= 0;
 while offs1 <> 0 do begin      //reverse order
  with psubdataty(ele.eledataabs(offs1))^ do begin
   offs2:= next;
   next:= offs3;
  end;
  offs3:= offs1;
  offs1:= offs2;
 end;
 atyp^.infoclass.subchain:= offs3;
end;

procedure handlerecordtype();
var
 int1: integer;
 int2: dataoffsty;
 ty1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDTYPE');
{$endif}
 with info do begin
  ele.elementparent:= contextstack[s.stackindex].b.eleparent; //restore
  with contextstack[s.stackindex-1] do begin
   currenttypedef:= d.typ.typedata;
   ty1:= ptypedataty(ele.eledataabs(d.typ.typedata));
   inittypedatabyte(ty1^,dk_record,d.typ.indirectlevel,
              contextstack[s.stackindex].d.rec.fieldoffsetmax,d.typ.flags);
   resolveforwardtype(ty1);
   reversefieldchain(ty1);
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
     currenttypedef:= 0;
     identerror(-2,err_duplicateidentifier);
     exit;
    end;
    currenttypedef:= ele.eledatarel(po1);
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
      totsize:= targetpointersize;
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
      dk_string: begin
       manageproc1:= @managearraystring;
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
        not (po1^.h.kind in arrayindexdatakinds) or 
                                         (po1^.h.bitsize > 32) then begin
       err(err_ordinaltypeexpected);
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
       currenttypedef:= 0;
       identerror(s.stacktop-s.stackindex,err_duplicateidentifier);
       goto endlab;
      end;
      currenttypedef:= ele.eledatarel(arty);
      exclude(flags1,tf_managed); //only item type can be managed
      inittypedata(arty^,dk_array,0,flags1,0,0);
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
        dk_string: begin
         h.manageproc:= @managedynarraystring;
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
//   {
   with contextstack[s.stackindex-1] do begin
   {$ifdef mse_checkinternalerror}
    if not (d.kind in [ck_typetype,ck_fieldtype]) then begin
     internalerror(ie_handler,'20171121');
    end;
   {$endif}
    arty^.h.indirectlevel:= d.typ.indirectlevel;
    d.typ.indirectlevel:= 0;
    d.typ.typedata:= ele.eledatarel(arty);
   end;
//   }
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
var
 po1,po2: pcontextitemty;
 b1: boolean;
begin
{$ifdef mse_debugparser}
 outhandle('INDEXSTART');
{$endif}
 with info do begin
  po2:= @contextstack[s.stackindex];
  po1:= getpreviousnospace(po2-1);
  with info,po1^ do begin
   if d.kind = ck_prop then begin
    with po2^ do begin
     d.kind:= ck_index;
     d.index.count:= 0;
    end;
   end
   else begin
    if d.dat.datatyp.indirectlevel = 1 then begin
     getvalue(po1,das_none); //pointer arithmetic
    end
    else begin
     getaddress(po1,true);
    end;
    handleindexitemstart();
   end;
  end;
 end;
end;

procedure handleindexitemstart();
var
 kind1: datakindty;
 i1: int32;
 t1: typeinfoty;
 poa,po1: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('INDEXITEMSTART');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if d.kind <> ck_prop then begin
 {$ifdef mse_checkinternalerror}
   if (d.kind <> ck_fact) or (d.dat.datatyp.indirectlevel <> 1) then begin
    internalerror(ie_handler,'20160227D');
   end;
 {$endif}
   po1:= @contextstack[s.stackindex];
   poa:= getpreviousnospace(po1-1);
   po1^.d.kind:= ck_getindex;
   kind1:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.kind;
   exclude(d.handlerflags,hf_needsunique);
   case kind1 of
    dk_openarray: begin
     i1:= s.ssa.nextindex-1;
     with insertitem(oc_offsetpoimm,-1,-1)^ do begin //at end of context
      setimmint32(sizeof(openarrayty.high),par.imm); //pointer to openarrayty.data
      par.ssas1:= i1;
     end;
     i1:= s.ssa.nextindex-1;
     with insertitem(oc_indirectpo,-1,-1)^ do begin //at end of context
                     //openarray.data
      par.ssas1:= i1;
     end;
     dec(d.dat.datatyp.indirectlevel);
    end;
    dk_dynarray,dk_string: begin
     if kind1 = dk_string then begin
      include(d.handlerflags,hf_needsunique);
      d.dat.fact.opoffset:= getcontextopcount(-1); //for needsunique call
     end;
     dec(d.dat.indirection);
     dec(d.dat.datatyp.indirectlevel);
     getvalue(poa,das_none);
    end;
   end;
  end;
 end;
end;

procedure handleindexitem();
var
 lastssa: int32;
 itemtype,indextype: ptypedataty;
 isdynarray,ispointer: boolean;
 range: ordrangety;
 li1: int64;
 ptop: pcontextitemty;
 topoffset: int32;
label
 errorlab;
begin
{$ifdef mse_debugparser}
 outhandle('INDEXITEM');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
//  getnextnospace(s.stackindex+1,poa);
  inc(contextstack[s.stackindex].d.index.count);
  ptop:= @contextstack[s.stacktop];
  topoffset:= s.stacktop-s.stackindex;
  if d.kind <> ck_prop then begin //no array property
  {$ifdef mse_checkinternalerror}
   if contextstack[s.stackindex].d.kind <> ck_getindex then begin
    internalerror(ie_handler,'20160527');
   end;
  {$endif}
   itemtype:= ele.eledataabs(d.dat.datatyp.typedata);
   isdynarray:= true;
   ispointer:= false;
   case itemtype^.h.kind of
    dk_dynarray,dk_openarray: begin
     if d.dat.datatyp.indirectlevel <> 0 then begin
      errormessage(err_illegalqualifier,[],topoffset);
      goto errorlab;
     end;
     itemtype:= ele.eledataabs(itemtype^.infodynarray.i.itemtypedata);
     range.min:= 0;
    end;
    dk_string: begin
     if d.dat.datatyp.indirectlevel <> 0 then begin
      errormessage(err_illegalqualifier,[],topoffset);
      goto errorlab;
     end;
     range.min:= 1;
     case itemtype^.itemsize of
      2: begin
       itemtype:= ele.eledataabs(sysdatatypes[st_char16].typedata);
      end;
      4: begin
       itemtype:= ele.eledataabs(sysdatatypes[st_char32].typedata);
      end;
      else begin
       itemtype:= ele.eledataabs(sysdatatypes[st_char8].typedata);
      end;
     end;
    end;
    dk_array: begin
     if d.dat.datatyp.indirectlevel <> 1 then begin
      errormessage(err_illegalqualifier,[],topoffset);
      goto errorlab;
     end;
     isdynarray:= false;
    end;
    else begin
     if d.dat.datatyp.indirectlevel > 0 then begin
      ispointer:= true;
      isdynarray:= false;
     end
     else begin
      errormessage(err_illegalqualifier,[],1);
      goto errorlab;
     end;
    end;
   end;
   if isdynarray then begin
    if not tryconvert(ptop,st_int32) then begin
     errormessage(err_illegalqualifier,[],1);
     goto errorlab;
    end;
   end
   else begin
    if ispointer then begin
     indextype:= ele.eledataabs(sysdatatypes[st_int32].typedata);
                                            //todo: pointer size
     range.min:= 0;
     range.max:= indextype^.infoint32.max;
    end
    else begin
     indextype:= ele.eledataabs(itemtype^.infoarray.indextypedata);
     getordrange(ele.eledataabs(itemtype^.infoarray.indextypedata),range);
     itemtype:= ele.eledataabs(itemtype^.infoarray.i.itemtypedata); 
    end;
    if not tryconvert(ptop,indextype,0,[]) then begin
     errormessage(err_illegalqualifier,[],topoffset);
     goto errorlab;
    end;
   end;
   with ptop^ do begin
    if (d.kind = ck_const) and not ispointer then begin
     li1:= getordconst(d.dat.constval);
     if (li1 < range.min) or 
                       not isdynarray and (li1 > range.max) then begin
      rangeerror(range,topoffset);
      goto errorlab;
     end;
     
    end;
    getvalue(ptop,das_32);
    if not tryconvert(ptop,st_int32,[coo_enum,coo_character]) then begin  
                                                   //pointer size?
     errormessage(err_illegalqualifier,[],topoffset);
     goto errorlab;
    end;
    if range.min <> 0 then begin
     lastssa:= d.dat.fact.ssaindex;
     with insertitem(oc_addimmint,topoffset,-1)^ do begin
      par.ssas1:= lastssa;
      setimmint32(-range.min,par.imm);
     end;
    end;
    lastssa:= d.dat.fact.ssaindex;
    with insertitem(oc_mulimmint,topoffset,-1)^ do begin
     par.ssas1:= lastssa;
     setimmint32(itemtype^.h.bytesize,par.imm);
    end;
   end;
                                                        //next dimension
   with additem(oc_addpoint)^ do begin
    par.ssas1:= d.dat.fact.ssaindex;
    par.ssas2:= contextstack[s.stacktop].d.dat.fact.ssaindex;
    par.stackop.t:= bitoptypes[
       ptypedataty(ele.eledataabs(ptop^.d.dat.datatyp.typedata))^.h.datasize];
    d.dat.fact.ssaindex:= par.ssad; //new pointer
   end;
   d.dat.datatyp.typedata:= ele.eledatarel(itemtype);
   d.dat.datatyp.indirectlevel:= itemtype^.h.indirectlevel; //pointer
   if not ispointer then begin
    inc(d.dat.datatyp.indirectlevel);
   end;
           //opdatatype is already pointer
errorlab:
   s.stacktop:= s.stackindex;
//   dec(s.stacktop);
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
//   d.kind:= ck_space;
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
   currenttypedef:= 0;
   identerror(-2,err_duplicateidentifier);
  end
  else begin
   currenttypedef:= ele.eledatarel(po1);
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