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
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;

procedure handletype(const info: pparseinfoty);
procedure handlegettypetypestart(const info: pparseinfoty);
procedure handlegetfieldtypestart(const info: pparseinfoty);
procedure handlechecktypeident(const info: pparseinfoty);
procedure handlepointertype(const info: pparseinfoty);
 
procedure handlerecorddefstart(const info: pparseinfoty);
procedure handlerecorddeferror(const info: pparseinfoty);
procedure handlerecordtype(const info: pparseinfoty);
procedure handlerecordfield(const info: pparseinfoty);

procedure handlearraydefstart(const info: pparseinfoty);
procedure handlearraydefreturn(const info: pparseinfoty);
procedure handlearraydeferror1(const info: pparseinfoty);
procedure handlearrayindexerror1(const info: pparseinfoty);
procedure handlearrayindexerror2(const info: pparseinfoty);
procedure handlearrayindex(const info: pparseinfoty);

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
  end;
//  else begin
//   identerror(info,stacktop-stackindex,err_identifiernotfound);
//  end;
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
 
procedure handlearraydefreturn(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYDEFRETURN');
{$endif}
outinfo(info,'****');
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

procedure handlearrayindex(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'ARRAYINDEX');
{$endif}
outinfo(info,'***');
 with info^ do begin
  dec(stackindex,1);
 end;
end;

//type
// t = array [0..2];
end.