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
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
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

//procedure handlearraydefstart();
procedure handlearraytype();
procedure handlearraydeferror1();
procedure handlearrayindexerror1();
procedure handlearrayindexerror2();
//procedure handlearrayindex2();

procedure handleindexstart();
procedure handleindex();
procedure closesquarebracketexpected();
procedure closeroundbracketexpected();

procedure checkrecordfield(const avisibility: visikindsty;
                       const aflags: varflagsty; var aoffset: dataoffsty);

implementation
uses
 handlerglob,elements,errorhandler,handlerutils,parser,opcode,stackops;

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
outinfo('***');
 with info,contextstack[stackindex] do begin
  d.kind:= ck_fieldtype;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
 end;
end;

procedure handlegettypetypestart();
begin
{$ifdef mse_debugparser}
 outhandle('GETTYPETYPESTART');
{$endif}
outinfo('***');
 with info,contextstack[stackindex] do begin
  d.kind:= ck_typetype;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
 end;
end;

procedure handlepointertype();
begin
{$ifdef mse_debugparser}
 outhandle('POINTERTYPE');
{$endif}
 with info,contextstack[stackindex] do begin
  inc(d.typ.indirectlevel);
//  include(d.typ.flags,tf_reference);
 end;
end;

procedure handlechecktypeident();
var
 po1,po2: pelementinfoty;
 idcontext: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('CHECKTYPEIDENT');
{$endif}
outinfo('***');
 with info,contextstack[stackindex-2] do begin
  if stackindex < 3 then begin
   internalerror('H20140325A');
   exit;
  end;
  if findkindelements(1,[ek_type],allvisi,po2) then begin
//   d.kind:= ck_type;
   d.typ.typedata:= ele.eleinforel(po2);
//   d.typ.indirectlevel:= 0;
   if d.kind = ck_typetype then begin
    idcontext:= @contextstack[stackindex-3];
    if idcontext^.d.kind = ck_ident then begin
     po1:= ele.addelement(idcontext^.d.ident.ident,allvisi,ek_type);
     if po1 <> nil then begin
      ptypedataty(@po1^.data)^:= ptypedataty(@po2^.data)^;
      inc(ptypedataty(@po1^.data)^.indirectlevel,d.typ.indirectlevel);
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
outinfo('***');
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
outinfo('***');
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
   elemark:= ele.elementparent;
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
  ele.elementparent:= contextstack[stackindex].elemark;
 end;
end;

procedure checkrecordfield(const avisibility: visikindsty;
                       const aflags: varflagsty; var aoffset: dataoffsty);
var
 po1: pfielddataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
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
   ele1:= ele.elementparent;
              //???? not used
   ele.elementparent:= contextstack[contextstack[stackindex].parent].elemark;
   po1^.flags:= aflags;
   po1^.offset:= aoffset;
   with contextstack[stackindex+3] do begin
    po1^.typ:= d.typ.typedata;
    po1^.indirectlevel:= d.typ.indirectlevel;
   end;
   if po1^.indirectlevel = 0 then begin      //todo: alignment
    size1:= ptypedataty(ele.eledataabs(po1^.typ))^.bytesize;
   end
   else begin
    size1:= pointersize;
   end;
   aoffset:= aoffset+size1;
   with contextstack[stackindex].d do begin
    kind:= ck_field;
    field.fielddata:= ele.eledatarel(po1);
   end;
   stacktop:= stackindex;
   ele.elementparent:= ele1;
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
outinfo('***');
 with info do begin
  checkrecordfield(allvisi,[],contextstack[stackindex-1].d.rec.fieldoffset);
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
outinfo('****');
 with info do begin
  ele.elementparent:= contextstack[stackindex].elemark; //restore
{
  int2:= 0;
  for int1:= stackindex+1 to stacktop do begin
   with contextstack[int1].d do begin
    po1:= ele.eledataabs(field.fielddata);
    po1^.offset:= int2;
    if po1^.indirectlevel = 0 then begin
     size1:= ptypedataty(ele.eledataabs(po1^.typ))^.bytesize;
    end
    else begin
     size1:= pointersize;
    end;
    int2:= int2 + size1;
                //todo: alignment
   end;
  end;
}
  with contextstack[stackindex-1],ptypedataty(ele.eledataabs(
                                                d.typ.typedata))^ do begin
   kind:= dk_record;
   datasize:= das_none;
   bytesize:= contextstack[stackindex].d.rec.fieldoffset;
   bitsize:= bytesize*8;
   indirectlevel:= d.typ.indirectlevel;
  end;
 end;
end;
(*
procedure handlearraydefstart();
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYDEFSTART');
{$endif}
outinfo('****');
end;
*)
procedure getordrange(const typedata: ptypedataty; out range: ordrangety);
begin
 with typedata^ do begin
  case kind of
   dk_cardinal: begin
    if datasize <= das_8 then begin
     range.min:= infocard8.min;
     range.max:= infocard8.max;
    end
    else begin
     if datasize <= das_16 then begin
      range.min:= infocard16.min;
      range.max:= infocard16.max;
     end
     else begin
      range.min:= infocard32.min;
      range.max:= infocard32.max;
     end;
    end;
   end;
   dk_integer: begin
    if datasize <= das_8 then begin
     range.min:= infoint8.min;
     range.max:= infoint8.max;
    end
    else begin
     if datasize <= das_16 then begin
      range.min:= infoint16.min;
      range.max:= infoint16.max;
     end
     else begin
      range.min:= infoint32.min;
      range.max:= infoint32.max;
     end;
    end;
   end;
   dk_boolean: begin
    range.min:= 0;
    range.max:= 1;
   end;
   else begin
    internalerror('H20120327B');
   end;
  end;
 end;
end;

function getordconst(const avalue: dataty): int64;
begin
 with avalue do begin
  case kind of
   dk_integer: begin
    result:= vinteger;
   end;
   dk_boolean: begin
    if vboolean then begin
     result:= 1;
    end
    else begin
     result:= 0;
    end;
   end;
   else begin
    internalerror('H20140329A');
   end;
  end;
 end;
end;

//type t1 = array[1..0] of integer; 
procedure handlearraytype();
var
 int1,int2: integer;
// po2: pelementoffsetty;
 arty: ptypedataty;
// itemty: ptypedataty;
 itemtyoffs: elementoffsetty;
// itemsize: integer;
 indilev: integer;
 po1: ptypedataty;
 id1: identty;
 {min,max,}totsize,si1: int64;

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
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYTYPE');
{$endif}
outinfo('****');
 with info do begin
  int1:= stacktop-stackindex-2;
  if (int1 > 0) and (contextstack[stacktop].d.kind = ck_fieldtype) then begin
   arty:= nil;
   with contextstack[stacktop] do begin
    itemtyoffs:= d.typ.typedata;
    with ptypedataty(ele.eledataabs(itemtyoffs))^ do begin;
     indilev:= d.typ.indirectlevel;
     if indilev + indirectlevel > 0 then begin
      totsize:= pointersize;
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
(*
procedure handlearrayindex2();
begin
{$ifdef mse_debugparser}
 outhandle('ARRAYINDEX');
{$endif}
outinfo('***');
 with info^,contextstack[stacktop] do begin
  if d.kind <> ck_fieldtype then begin
   internalerror('H20140327A');
   exit;
  end;
  if not (d.typ.kind in ordinalk
  dec(stackindex,1);
 end;
end;
*)

procedure handleindexstart();
begin
{$ifdef mse_debugparser}
 outhandle('INDEXSTART');
{$endif}
outinfo('***');
 with info,contextstack[stackindex] do begin
  d.kind:= ck_index;
//  d.opshiftmark:= opshift;
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
// opshiftcorr: integer;
label
 errlab;
begin
// v2[4]:= 1;
{$ifdef mse_debugparser}
 outhandle('INDEX');
{$endif}
outinfo('***');
 with info,contextstack[stackindex-1] do begin
  if stacktop - stackindex > 0 then begin
   offs:= 0;
//   opshiftcorr:= opshift-contextstack[stackindex].d.opshiftmark;
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
          d.d.vinteger:= itemtype^.bytesize;
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
//      inc(d.datatyp.indirectlevel)
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