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

procedure handletype(const info: pparseinfoty);
procedure handlegettypetypestart(const info: pparseinfoty);
procedure handlegetfieldtypestart(const info: pparseinfoty);
procedure handlepointertype(const info: pparseinfoty);
procedure handlechecktypeident(const info: pparseinfoty);
procedure handlecheckrangetype(const info: pparseinfoty);
 
procedure handlerecorddefstart(const info: pparseinfoty);
procedure handlerecorddeferror(const info: pparseinfoty);
procedure handlerecordtype(const info: pparseinfoty);
procedure handlerecordfield(const info: pparseinfoty);

procedure handlearraydefstart(const info: pparseinfoty);
procedure handlearraytype(const info: pparseinfoty);
procedure handlearraydeferror1(const info: pparseinfoty);
procedure handlearrayindexerror1(const info: pparseinfoty);
procedure handlearrayindexerror2(const info: pparseinfoty);
//procedure handlearrayindex2(const info: pparseinfoty);

implementation
uses
 handlerglob,elements,errorhandler,handlerutils,parser;

procedure handletype(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'TYPE');
{$endif}
 with info^,contextstack[stacktop] do begin
  dec(stackindex);
  stacktop:= stackindex;
 end;
end;

procedure handlegetfieldtypestart(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'GETFIELDTYPESTART');
{$endif}
outinfo(info,'***');
 with info^,contextstack[stackindex] do begin
  d.kind:= ck_fieldtype;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
 end;
end;

procedure handlegettypetypestart(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'GETTYPETYPESTART');
{$endif}
outinfo(info,'***');
 with info^,contextstack[stackindex] do begin
  d.kind:= ck_typetype;
  d.typ.indirectlevel:= 0;
  d.typ.typedata:= 0;
 end;
end;

procedure handlepointertype(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'POINTERTYPE');
{$endif}
 with info^,contextstack[stackindex] do begin
  inc(d.typ.indirectlevel);
//  include(d.typ.flags,tf_reference);
 end;
end;

procedure handlechecktypeident(const info: pparseinfoty);
var
 po1,po2: pelementinfoty;
 idcontext: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'CHECKTYPEIDENT');
{$endif}
outinfo(info,'***');
 with info^,contextstack[stackindex-2] do begin
  if stackindex < 3 then begin
   internalerror(info,'H20140325A');
   exit;
  end;
  if findkindelements(info,1,[ek_type],vis_max,po2) then begin
//   d.kind:= ck_type;
   d.typ.typedata:= ele.eleinforel(po2);
//   d.typ.indirectlevel:= 0;
   if d.kind = ck_typetype then begin
    idcontext:= @contextstack[stackindex-3];
    if idcontext^.d.kind = ck_ident then begin
     po1:= ele.addelement(idcontext^.d.ident.ident,vis_max,ek_type);
     if po1 <> nil then begin
      ptypedataty(@po1^.data)^:= ptypedataty(@po2^.data)^;
      inc(ptypedataty(@po1^.data)^.indirectlevel,d.typ.indirectlevel);
     end
     else begin //duplicate
      identerror(info,-3,err_duplicateidentifier);
     end;
    end
    else begin
     internalerror(info,'H20140324B');
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

procedure handlecheckrangetype(const info: pparseinfoty);
var
 id1: identty;
 po1: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'CHECKRANGETYPE');
{$endif}
outinfo(info,'***');
 with info^ do begin
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
    if ele.addelement(id1,vis_max,ek_type,po1) then begin
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
     identerror(info,-1,err_duplicateidentifier,erl_fatal);
    end;
   end;
  end;
  stacktop:= stackindex-1;
  stackindex:= contextstack[stackindex].parent;
 end;
end;
 
procedure handlerecorddefstart(const info: pparseinfoty);
var
 po1: ptypedataty;
 id1: identty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'RECORDDEFSTART');
{$endif}
outinfo(info,'***');
 with info^ do begin
  if stackindex < 3 then begin
   internalerror(info,'H20140325D');
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
  contextstack[stackindex].elemark:= ele.elementparent;
  with contextstack[stackindex-1] do begin
//   kind:= ck_type;
   if not ele.pushelement(id1,vis_max,ek_type,d.typ.typedata) then begin
    identerror(info,stacktop-stackindex,err_duplicateidentifier,erl_fatal);
   end;
  end;
 end;
end;

procedure handlerecorddeferror(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'RECORDDEFERROR');
{$endif}
 with info^ do begin
  ele.elementparent:= contextstack[stackindex].elemark;
 end;
end;

procedure handlerecordfield(const info: pparseinfoty);
var
 po1: pfielddataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'RECORDFIELD');
{$endif}
outinfo(info,'***');
 with info^ do begin
  if (stacktop-stackindex < 3) or 
            (contextstack[stackindex+3].d.kind <> ck_fieldtype) then begin
   internalerror(info,'H20140325C');
   exit;
  end;
  if ele.addelement(contextstack[stackindex+2].d.ident.ident,
                                           vis_max,ek_field,po1) then begin
   ele1:= ele.elementparent;
   ele.elementparent:= contextstack[contextstack[stackindex].parent].elemark;
   with contextstack[stackindex+3] do begin
    po1^.typ:= d.typ.typedata;
    po1^.indirectlevel:= d.typ.indirectlevel;
   end;
   with contextstack[stackindex].d do begin
    kind:= ck_field;
    field.fielddata:= ele.eledatarel(po1);
   end;
   stacktop:= stackindex;
   ele.elementparent:= ele1;
  end
  else begin
   identerror(info,2,err_duplicateidentifier);
   stacktop:= stackindex-1;
  end;
 end;
end;

procedure handlerecordtype(const info: pparseinfoty);
var
 int1,int2: integer;
 po1: pfielddataty;
 size1: integer;
begin
{$ifdef mse_debugparser}
 outhandle(info,'RECORDTYPE');
{$endif}
outinfo(info,'****');
  with info^ do begin
  ele.elementparent:= contextstack[stackindex].elemark; //restore
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
  with contextstack[stackindex-1],ptypedataty(ele.eledataabs(
                                                d.typ.typedata))^ do begin
   kind:= dk_record;
   datasize:= das_none;
   bytesize:= int2;
   bitsize:= int2*8;
   indirectlevel:= d.typ.indirectlevel;
  end;
 end;
end;

procedure handlearraydefstart(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYDEFSTART');
{$endif}
outinfo(info,'****');
end;
//type t1 = array[1..0] of integer; 
procedure handlearraytype(const info: pparseinfoty);
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
 min,max,totsize,si1: int64;
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYTYPE');
{$endif}
outinfo(info,'****');
 with info^ do begin
  int1:= stacktop-stackindex-2;
  if (int1 > 0) and (contextstack[stacktop].d.kind = ck_fieldtype) then begin
//   ele.checkcapacity(int1*elesizes[ek_arraydim]+elesizes[ek_type]);
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
      internalerror(info,'H20140327A');
      exit;
     end;
     po1:= ele.eledataabs(d.typ.typedata);
     if (d.typ.indirectlevel <> 0) or (po1^.indirectlevel <> 0) or
       not (po1^.kind in ordinaldatakinds) or (po1^.bitsize > 32) then begin
      errormessage(info,err_ordtypeexpected,[],int1-stackindex);
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
     if not ele.addelement(id1,vis_max,ek_type,arty) then begin
      identerror(info,stacktop-stackindex,err_duplicateidentifier);
      goto endlab;
     end;
     with arty^.infoarray do begin
      itemtypedata:= itemtyoffs;
      itemindirectlevel:= indilev;
      indextypedata:= d.typ.typedata;
     end;
     indilev:= 0; //no indirectlevel for multi dimensions
     with po1^ do begin
      case kind of
       dk_cardinal: begin
        if datasize <= das_8 then begin
         min:= infocard8.min;
         max:= infocard8.max;
        end
        else begin
         if po1^.datasize <= das_16 then begin
          min:= infocard16.min;
          max:= infocard16.max;
         end
         else begin
          min:= infocard32.min;
          max:= infocard32.max;
         end;
        end;
       end;
       dk_integer: begin
        if datasize <= das_8 then begin
         min:= infoint8.min;
         max:= infoint8.max;
        end
        else begin
         if po1^.datasize <= das_16 then begin
          min:= infoint16.min;
          max:= infoint16.max;
         end
         else begin
          min:= infoint32.min;
          max:= infoint32.max;
         end;
        end;
       end;
       dk_boolean: begin
        min:= 0;
        max:= 1;
       end;
       else begin
        internalerror(info,'H20120327B');
        exit;
       end;
      end;
     end;
     si1:= max-min+1;
     if (si1 > maxint) and (totsize > maxint) then begin
      errormessage(info,err_dataeletoolarge,[],int1-stackindex);
      ele.hideelementdata(arty);
      goto endlab;
     end;
     if max < min then begin
      errormessage(info,err_highlowerlow,[],int1-stackindex);
      ele.hideelementdata(arty);
      goto endlab;     
     end;
     totsize:= si1*totsize;
     if totsize > maxint then begin
      errormessage(info,err_dataeletoolarge,[],int1-stackindex);
      ele.hideelementdata(arty);
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
   arty^.indirectlevel:= contextstack[stackindex-1].d.typ.indirectlevel;
  end;
endlab:
  stacktop:= stackindex-1;
  stackindex:= contextstack[stackindex-1].parent;  
 end;
end;

procedure handlearraydeferror1(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYDEFERROR1');
{$endif}
 tokenexpectederror(info,'of',erl_fatal);
end;

procedure handlearrayindexerror1(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYINDEXERROR1');
{$endif}
 tokenexpectederror(info,'[',erl_fatal);
end;

procedure handlearrayindexerror2(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYINDEXERROR2');
{$endif}
 tokenexpectederror(info,']',erl_fatal);
end;
(*
procedure handlearrayindex2(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYINDEX');
{$endif}
outinfo(info,'***');
 with info^,contextstack[stacktop] do begin
  if d.kind <> ck_fieldtype then begin
   internalerror(info,'H20140327A');
   exit;
  end;
  if not (d.typ.kind in ordinalk
  dec(stackindex,1);
 end;
end;
*)
//type
// t = array [0..2];
end.