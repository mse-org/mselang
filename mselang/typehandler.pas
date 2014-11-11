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
unit typehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$coperators on}{$endif}
interface
uses
 parserglob;

procedure handletype();
procedure handlegettypetypestart();
procedure handlegetfieldtypestart();
procedure handlepointertype();
procedure handlechecktypeident();
procedure handlecheckrangetype();
 
procedure handlerecorddefstart();
procedure handlerecorddeferror();
procedure handlerecordtype();
procedure handlerecordfield();

procedure handlearraytype();
procedure handlearraydeferror1();
procedure handlearrayindexerror1();
procedure handlearrayindexerror2();

procedure handleindexstart();
procedure handleindex();

procedure handleenumdefentry();
procedure handleenumdef();
procedure handleenumitem();
procedure handleenumitemvalue();

procedure handlesettype();

procedure checkrecordfield(const avisibility: visikindsty;
                       const aflags: addressflagsty; var aoffset: dataoffsty;
                                                  var atypeflags: typeflagsty);

implementation
uses
 handlerglob,elements,errorhandler,handlerutils,parser,opcode,stackops,
 grammar,opglob,managedtypes;

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
 po1,po2: pelementinfoty;
 po3,po4: ptypedataty;
 idcontext: pcontextitemty;
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
  if findkindelements(1,[ek_type],allvisi,po2) then begin
   d.typ.typedata:= ele.eleinforel(po2);
   po3:= ptypedataty(@po2^.data);
   d.typ.flags:= po3^.flags;
   inc(d.typ.indirectlevel,po3^.indirectlevel);
   if d.kind = ck_typetype then begin
    idcontext:= @contextstack[s.stackindex-3];
    if idcontext^.d.kind = ck_ident then begin
     po1:= ele.addelement(idcontext^.d.ident.ident,ek_type,allvisi);
     if po1 <> nil then begin
      po4:= @po1^.data;
      po4^:= po3^;
      po4^.indirectlevel:= d.typ.indirectlevel;
      if po4^.indirectlevel > 0 then begin
       po4^.flags-= [tf_managed,tf_hasmanaged];
      end;
     end
     else begin //duplicate
      identerror(-3,err_duplicateidentifier);
     end;
  {$ifdef mse_checkinternalerror}
    end
    else begin
     internalerror(ie_type,'20140324B');
   {$endif}
    end;
   end;
   s.stacktop:= s.stackindex-1;
   s.stackindex:= contextstack[s.stackindex].parent;
  end
  else begin
   s.stackindex:= s.stackindex-1;
   s.stacktop:= s.stackindex;
  end;
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
    with po1^.infoint32 do begin
     //todo: check datasize
    {
//     flags:= [];
//     rtti:= 0;
     indirectlevel:= d.typ.indirectlevel;
     d.typ.indirectlevel:= 0;
     bitsize:= 32;
     bytesize:= 4;
     datasize:= das_32;
     parent:= 0;
     kind:= dk_integer;
    }
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
    kind:= dk_none; //inhibit dump
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
var
 po1: pfielddataty;
 po2: ptypedataty;
// ele1: elementoffsetty;
 size1: dataoffsty;
begin
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (s.stacktop-s.stackindex < 3) or 
            (contextstack[s.stackindex+3].d.kind <> ck_fieldtype) then begin
   internalerror(ie_type,'20140325C');
  end;
 {$endif}
  if not ele.addelementduplicatedata(contextstack[s.stackindex+2].d.ident.ident,
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
  with contextstack[s.stackindex+3] do begin
   po1^.vf.typ:= d.typ.typedata;
   po1^.indirectlevel:= d.typ.indirectlevel;
   po2:= ptypedataty(ele.eledataabs(po1^.vf.typ));
   if po1^.indirectlevel = 0 then begin      //todo: alignment
    if po2^.flags * [tf_managed,tf_hasmanaged] <> [] then begin
     include(atypeflags,tf_hasmanaged);
     include(po1^.vf.flags,tf_hasmanaged);
     {
     with pmanageddataty(
             pointer(ele.addelementduplicate(tks_managed,[vik_managed],
                                                               ek_managed))+
                                            sizeof(elementheaderty))^ do begin
      managedele:= ele.eledatarel(po1);
     end;
     }
    end;
    size1:= po2^.bytesize;
   end
   else begin
    size1:= pointersize;
   end;
  end;
  aoffset:= aoffset+size1;
  with contextstack[s.stackindex].d do begin
   kind:= ck_field;
   field.fielddata:= ele.eledatarel(po1);
  end;
  s.stacktop:= s.stackindex;
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

procedure handlerecordtype();
var
 int1: integer;
 int2: dataoffsty;
 po1: ptypedataty;
 size1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDTYPE');
{$endif}
 with info do begin
  ele.elementparent:= contextstack[s.stackindex].b.eleparent; //restore
  with contextstack[s.stackindex-1] do begin
   po1:= ptypedataty(ele.eledataabs(d.typ.typedata));
   inittypedatabyte(po1^,dk_record,d.typ.indirectlevel,
                       contextstack[s.stackindex].d.rec.fieldoffset,d.typ.flags);
{   
   kind:= dk_record; //fieldchain set in handlerecorddefstart()
   datasize:= das_none;
   bytesize:= contextstack[s.stackindex].d.rec.fieldoffset;
   bitsize:= bytesize*8;
   indirectlevel:= d.typ.indirectlevel;
   flags:= d.typ.flags;
}
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
    case po1^.kind of        //todo: check size and offset
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
 itemtyoffs: elementoffsetty;
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
                              //todo: indirection? 
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYTYPE');
{$endif}
 with info do begin
  int1:= s.stacktop-s.stackindex-2;
  if (contextstack[s.stacktop].d.kind = ck_fieldtype) then begin
   arty:= nil;
   with contextstack[s.stacktop] do begin
    itemtyoffs:= d.typ.typedata;
    with ptypedataty(ele.eledataabs(itemtyoffs))^ do begin
     flags1:= flags;
     indilev:= d.typ.indirectlevel;
     if indilev + indirectlevel > 0 then begin
      totsize:= pointersize;
      flags1-= [tf_managed,tf_hasmanaged];
     end
     else begin
      totsize:= bytesize;
     end;
    end;
   end;  //todo: alignment
   if (int1 > 0) then begin  //static array
    int2:= s.stackindex + 2;
    for int1:= s.stacktop-1 downto int2 do begin
     with contextstack[int1] do begin
     {$ifdef mse_checkinternalerror}
      if d.kind <> ck_fieldtype then begin
       internalerror(ie_type,'20140327A');
      end;
     {$endif}
      po1:= ele.eledataabs(d.typ.typedata);
      if (d.typ.indirectlevel <> 0) or (po1^.indirectlevel <> 0) or
        not (po1^.kind in ordinaldatakinds) or (po1^.bitsize > 32) then begin
       err(err_ordtypeexpected);
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
      arty^.flags:= flags1;
      if indilev > 0 then begin
       flags1-= [tf_managed,tf_hasmanaged];
      end;
      with arty^.infoarray do begin
       i.itemtypedata:= itemtyoffs;
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
      if totsize > maxint then begin
       err(err_dataeletoolarge);
       goto endlab;
      end;
      with arty^ do begin
       indirectlevel:= 0;
       bitsize:= 0;
       bytesize:= totsize;
       datasize:= das_none;
       kind:= dk_array;
      end;
      itemtyoffs:= ele.eledatarel(arty);
     end;
    end;
   end
   else begin //dynamic array
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
     inittypedatasize(arty^,dk_dynarray,0,das_pointer,
                                     [tf_managed,tf_hasmanaged]);
     with arty^ do begin
      manageproc:= @managedynarray;
      itemsize:= totsize;
      infodynarray.i.itemtypedata:= itemtyoffs;
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
    arty^.indirectlevel:= d.typ.indirectlevel;
    d.typ.indirectlevel:= 0;
    d.typ.typedata:= ele.eledatarel(arty);
   end;
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
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_index;
 end;
end;

procedure handleindex();
var
 itemtype,indextype: ptypedataty;
 range: ordrangety;
 li1: int64;
 offs: dataoffsty;
 int1,lastssa: integer;
 fullconst: boolean;
 isdynarray: boolean;
label
 errlab;
                              //todo: nested dynarray
begin
{$ifdef mse_debugparser}
 outhandle('INDEX');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if s.stacktop - s.stackindex > 0 then begin
   offs:= 0;
   case d.kind of
    ck_ref: begin
     itemtype:= ele.eledataabs(d.dat.datatyp.typedata);
     fullconst:= true;
     for int1:= s.stackindex+1 to s.stacktop do begin
      isdynarray:= itemtype^.kind = dk_dynarray;
      if not (isdynarray or (itemtype^.kind = dk_array)) then begin
       errormessage(err_illegalqualifier,[],0);
       goto errlab;
      end;
      if isdynarray then begin
       itemtype:= ele.eledataabs(itemtype^.infodynarray.i.itemtypedata);
       range.min:= 0;
      end
      else begin
       indextype:= ele.eledataabs(itemtype^.infoarray.indextypedata);
       itemtype:= ele.eledataabs(itemtype^.infoarray.i.itemtypedata);
       getordrange(indextype,range);
      end;
      with contextstack[int1] do begin
       case d.kind of
        ck_const: begin
         if not (contextstack[int1].d.dat.constval.kind in 
                                              ordinaldatakinds) then begin
          errormessage(err_ordtypeexpected,[],s.stacktop-s.stackindex);
          goto errlab;
         end;
         li1:= getordconst(contextstack[int1].d.dat.constval);
         if (li1 < range.min) or 
                           not isdynarray and (li1 > range.max) then begin
          rangeerror(range,s.stacktop-s.stackindex);
          goto errlab;
         end;
        end;
        ck_ref,ck_fact: begin //todo: check type
         li1:= 0;
         if d.kind = ck_ref then begin
          getvalue(int1-s.stackindex{,true});
         end;
         lastssa:= d.dat.fact.ssaindex;
         with insertitem(oc_mulimmint32,int1-s.stackindex,false)^ do begin
          par.ssas1:= lastssa;
          setimmint32(itemtype^.bytesize,par);
         end;
         if not fullconst then begin
          with insertitem(oc_addint32,int1-s.stackindex,false)^ do begin
           //todo
          end;         
         end
         else begin
          fullconst:= false;
         end;
        end;
       {$ifdef mse_checkinternalerror}
        else begin
         internalerror(ie_type,'20140328B');
        end;
       {$endif}
       end;
      end;
      offs:= offs + li1*gettypesize(itemtype^);
     end;
     d.dat.ref.offset:= d.dat.ref.offset + offs;
     d.dat.datatyp.typedata:= ele.eledatarel(itemtype);
     d.dat.datatyp.indirectlevel:= itemtype^.indirectlevel;
     if not fullconst then begin
      if isdynarray then begin //todo: nested, move to index loop
       getvalue(-1);
      end
      else begin
       pushinsertaddress(-1,true);
      end;
      lastssa:= contextstack[int1].d.dat.fact.ssaindex;
      with insertitem(oc_addpoint32,int1-s.stackindex,false)^ do begin
       par.ssas1:= d.dat.fact.ssaindex;
       par.ssas2:= lastssa;
      end;         
      d.kind:= ck_reffact;
      d.dat.fact.ssaindex:= contextstack[int1].d.dat.fact.ssaindex;
     end;
    end;
   {$ifdef mse_checkinternalerror}
    else begin
     internalerror(ie_type,'20140328A');
    end;
   {$endif}
   end;
  end
  else begin
errlab:
   d.kind:= ck_none;
  end;
  s.stacktop:= s.stackindex-1;
  s.stackindex:= contextstack[s.stackindex].parent;
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
   d.enu.enum:= ele1;
   d.enu.first:= 0;
   d.enu.flags:= [enf_contiguous];
  end;
  with po1^ do begin
   kind:= dk_none; //incomplete
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
   {
    kind:= dk_enum;
    datasize:= das_32;
    bytesize:= 4;
    bitsize:= 32;
    indirectlevel:= d.typ.indirectlevel;
   }
    flags:= contextstack[s.stackindex].d.enu.flags;
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
  if ele.addelementdata(ident1,ek_type,allvisi,po1) then begin
   inittypedatasize(po1^,dk_enumitem,0,das_32);
   with po1^ do begin
   {
    indirectlevel:= 0;
    bitsize:= 32;
    bytesize:= 4;
    datasize:= das_32;
    kind:= dk_enumitem;
   }
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