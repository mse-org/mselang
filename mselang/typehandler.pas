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
procedure closesquarebracketexpected();
procedure closeroundbracketexpected();

procedure checkrecordfield(const avisibility: visikindsty;
                       const aflags: addressflagsty; var aoffset: dataoffsty;
                                                  var atypeflags: typeflagsty);

implementation
uses
 handlerglob,elements,errorhandler,handlerutils,parser,opcode,stackops,
 grammar;

procedure handletype();
begin
{$ifdef mse_debugparser}
 outhandle('TYPE');
{$endif}
 with info,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlegetfieldtypestart();
begin
{$ifdef mse_debugparser}
 outhandle('GETFIELDTYPESTART');
{$endif}
 with info,contextstack[stackindex] do begin
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
 with info,contextstack[stackindex] do begin
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
 with info,contextstack[stackindex] do begin
  inc(d.typ.indirectlevel);
 end;
end;

procedure handlechecktypeident();
var
 po1,po2: pelementinfoty;
 po3: ptypedataty;
 idcontext: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKTYPEIDENT');
{$endif}
 with info,contextstack[stackindex-2] do begin
  if stackindex < 3 then begin
   internalerror('H20140325A');
   exit;
  end;
  if findkindelements(1,[ek_type],allvisi,po2) then begin
   d.typ.typedata:= ele.eleinforel(po2);
   d.typ.flags:= ptypedataty(@po2^.data)^.flags;
   if d.kind = ck_typetype then begin
    idcontext:= @contextstack[stackindex-3];
    if idcontext^.d.kind = ck_ident then begin
     po1:= ele.addelement(idcontext^.d.ident.ident,allvisi,ek_type);
     if po1 <> nil then begin
      po3:= @po1^.data;
      po3^:= ptypedataty(@po2^.data)^;
      inc(po3^.indirectlevel,d.typ.indirectlevel);
      if po3^.indirectlevel > 0 then begin
       po3^.flags-= [tf_managed,tf_hasmanaged];
      end;
     end
     else begin //duplicate
      identerror(-3,err_duplicateidentifier);
     end;
    end
    else begin
     internalerror('H20140324B');
    end;
   end;
   stacktop:= stackindex-1;
   stackindex:= contextstack[stackindex].parent;
  end
  else begin
   stackindex:= stackindex-1;
   stacktop:= stackindex;
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
  if stacktop-stackindex = 3 then begin
   with contextstack[stackindex-2] do begin
    if (d.kind = ck_ident) and 
                   (contextstack[stackindex-1].d.kind = ck_typetype) then begin
     id1:= d.ident.ident; //typedef
    end
    else begin
     id1:= getident();
    end;
   end;
   with contextstack[stackindex-1] do begin
    if ele.addelement(id1,allvisi,ek_type,po1) then begin
     d.typ.typedata:= ele.eledatarel(po1);
     with po1^ do begin
      //todo: check datasize
      flags:= [];
      indirectlevel:= d.typ.indirectlevel;
      d.typ.indirectlevel:= 0;
      bitsize:= 32;
      bytesize:= 4;
      datasize:= das_32;
      kind:= dk_integer;
      with infoint32 do begin
       min:= contextstack[stackindex+2].d.constval.vinteger;
       max:= contextstack[stackindex+3].d.constval.vinteger;
      end;
     end;
    end
    else begin
     identerror(-1,err_duplicateidentifier,erl_fatal);
    end;
   end;
  end;
  stacktop:= stackindex-1;
  stackindex:= contextstack[stackindex].parent;
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
  if stackindex < 3 then begin
   internalerror('H20140325D');
   exit;
  end;
  with contextstack[stackindex-2] do begin
   if (d.kind = ck_ident) and 
                  (contextstack[stackindex-1].d.kind = ck_typetype) then begin
    id1:= d.ident.ident; //typedef
   end
   else begin
    id1:= getident();
   end;
  end;
  with contextstack[stackindex] do begin
   b.eleparent:= ele.elementparent;
   d.kind:= ck_recorddef;
   d.rec.fieldoffset:= 0;
  end;
  with contextstack[stackindex-1] do begin
   if not ele.pushelement(id1,allvisi,ek_type,d.typ.typedata) then begin
    identerror(stacktop-stackindex,err_duplicateidentifier,erl_fatal);
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
  ele.elementparent:= contextstack[stackindex].b.eleparent;
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
  if (stacktop-stackindex < 3) or 
            (contextstack[stackindex+3].d.kind <> ck_fieldtype) then begin
   internalerror('H20140325C');
   exit;
  end;
  if ele.addelement(contextstack[stackindex+2].d.ident.ident,
                                           avisibility,ek_field,po1) then begin
   po1^.flags:= aflags;
   po1^.offset:= aoffset;
   po1^.vf.flags:= [];
   with ptypedataty(ele.parentdata)^ do begin
    po1^.vf.next:= fieldchain;
    fieldchain:= ele.eledatarel(po1);
   end;
   with contextstack[stackindex+3] do begin
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
   with contextstack[stackindex].d do begin
    kind:= ck_field;
    field.fielddata:= ele.eledatarel(po1);
   end;
   stacktop:= stackindex;
//   ele.elementparent:= ele1;
  end
  else begin
   identerror(2,err_duplicateidentifier);
   stacktop:= stackindex-1;
  end;
 end;
end;

procedure handlerecordfield();
begin
{$ifdef mse_debugparser}
 outhandle('RECORDFIELD');
{$endif}
 with info do begin
  checkrecordfield(allvisi,[],contextstack[stackindex-1].d.rec.fieldoffset,
                            contextstack[stackindex-2].d.typ.flags);
 end;
end;

procedure handlerecordtype();
var
 int1: integer;
 int2: dataoffsty;
 po1: pfielddataty;
 size1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('RECORDTYPE');
{$endif}
 with info do begin
  ele.elementparent:= contextstack[stackindex].b.eleparent; //restore
  with contextstack[stackindex-1],ptypedataty(ele.eledataabs(
                                                d.typ.typedata))^ do begin
   kind:= dk_record;
   fieldchain:= 0;
   datasize:= das_none;
   bytesize:= contextstack[stackindex].d.rec.fieldoffset;
   bitsize:= bytesize*8;
   indirectlevel:= d.typ.indirectlevel;
   flags:= d.typ.flags;
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
   errormessage(aerror,[],int1-stackindex); 
   if arty <> nil then begin
    ele.hideelementdata(arty);
   end;
   contextstack[stackindex-1].d.kind:= ck_none;
  end;
 end;

var
 range: ordrangety;
 flags1: typeflagsty;
 
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYTYPE');
{$endif}
 with info do begin
  int1:= stacktop-stackindex-2;
  if (int1 > 0) and (contextstack[stacktop].d.kind = ck_fieldtype) then begin
   arty:= nil;
   with contextstack[stacktop] do begin
    itemtyoffs:= d.typ.typedata;
    with ptypedataty(ele.eledataabs(itemtyoffs))^ do begin;
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
   int2:= stackindex + 2;
   for int1:= stacktop-1 downto int2 do begin
    with contextstack[int1] do begin
     if d.kind <> ck_fieldtype then begin
      internalerror('H20140327A');
      exit;
     end;
     po1:= ele.eledataabs(d.typ.typedata);
     if (d.typ.indirectlevel <> 0) or (po1^.indirectlevel <> 0) or
       not (po1^.kind in ordinaldatakinds) or (po1^.bitsize > 32) then begin
      err(err_ordtypeexpected);
      goto endlab;
     end;
     if int1 = int2 then begin //first dimension
      with contextstack[stackindex-2] do begin
       if (d.kind = ck_ident) and 
                  (contextstack[stackindex-1].d.kind = ck_typetype) then begin
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
     if not ele.addelement(id1,allvisi,ek_type,arty) then begin
      identerror(stacktop-stackindex,err_duplicateidentifier);
      goto endlab;
     end;
     arty^.flags:= flags1;
     if indilev > 0 then begin
      flags1-= [tf_managed,tf_hasmanaged];
     end;
     with arty^.infoarray do begin
      itemtypedata:= itemtyoffs;
      itemindirectlevel:= indilev;
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
      errormessage(err_highlowerlow,[],int1-stackindex);
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
   with contextstack[stackindex-1] do begin
    arty^.indirectlevel:= d.typ.indirectlevel;
    d.typ.indirectlevel:= 0;
    d.typ.typedata:= ele.eledatarel(arty);
   end;
  end;
endlab:
  stacktop:= stackindex-1;
  stackindex:= contextstack[stackindex-1].parent;  
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
 with info,contextstack[stackindex] do begin
  d.kind:= ck_index;
 end;
end;

procedure handleindex();
var
 itemtype,indextype: ptypedataty;
 range: ordrangety;
 li1: int64;
 offs: dataoffsty;
 int1: integer;
 fullconst: boolean;
label
 errlab;
begin
{$ifdef mse_debugparser}
 outhandle('INDEX');
{$endif}
 with info,contextstack[stackindex-1] do begin
  if stacktop - stackindex > 0 then begin
   offs:= 0;
   case d.kind of
    ck_ref: begin
     itemtype:= ele.eledataabs(d.datatyp.typedata);
     fullconst:= true;
     for int1:= stackindex+1 to stacktop do begin
      if itemtype^.kind <> dk_array then begin
       errormessage(err_illegalqualifier,[],0);
       goto errlab;
      end;
      indextype:= ele.eledataabs(itemtype^.infoarray.indextypedata);
      itemtype:= ele.eledataabs(itemtype^.infoarray.itemtypedata);
      getordrange(indextype,range);
      with contextstack[int1] do begin
       case d.kind of
        ck_const: begin
         if not (contextstack[int1].d.constval.kind in 
                                              ordinaldatakinds) then begin
          errormessage(err_ordtypeexpected,[],stacktop-stackindex);
          goto errlab;
         end;
         li1:= getordconst(contextstack[int1].d.constval);
         if (li1 < range.min) or (li1 > range.max) then begin
          rangeerror(range,stacktop-stackindex);
          goto errlab;
         end;
        end;
        ck_ref,ck_fact: begin //todo: check type
         li1:= 0;
         if d.kind = ck_ref then begin
          getvalue(int1-stackindex{,true});
         end;
         with insertitem(int1-stackindex+1,false)^ do begin
          op:= @mulimmint32;
          par.imm.vint32:= itemtype^.bytesize;
         end;
         if not fullconst then begin
          with insertitem(int1-stackindex+1,false)^ do begin
           op:= @addint32;
          end;         
         end
         else begin
          fullconst:= false;
         end;
        end;
        else begin
         internalerror('N20140328B');
         exit;
        end;
       end;
      end;
      offs:= offs + li1*gettypesize(itemtype^);
     end;
     d.ref.offset:= d.ref.offset + offs;
     d.datatyp.typedata:= ele.eledatarel(itemtype);
     d.datatyp.indirectlevel:= itemtype^.indirectlevel;
     if not fullconst then begin
      pushinsertaddress(-1,true);
      with additem^ do begin
       op:= @addint32;
      end;
      d.kind:= ck_reffact;
     end;
    end;
    else begin
     internalerror('N20140328A');
     exit;
    end;
   end;
  end
  else begin
errlab:
   d.kind:= ck_none;
  end;
  stacktop:= stackindex-1;
  stackindex:= contextstack[stackindex].parent;
 end;
end;

procedure closesquarebracketexpected();
begin
 tokenexpectederror(']',erl_fatal);
end;

procedure closeroundbracketexpected();
begin
 tokenexpectederror(')',erl_fatal);
end;

end.