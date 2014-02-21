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
procedure handletypedefstart(const info: pparseinfoty);
procedure handletype3(const info: pparseinfoty);
procedure handlepointertype(const info: pparseinfoty);
 
procedure handlerecorddefstart(const info: pparseinfoty);
procedure handlerecorddeferror(const info: pparseinfoty);
procedure handlerecorddefreturn(const info: pparseinfoty);
procedure handlerecordfield(const info: pparseinfoty);

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

procedure handletypedefstart(const info: pparseinfoty);
begin
{$ifdef mse_debugparser}
 outhandle(info,'TYPEDEFSTART');
{$endif}
 with info^,contextstack[stackindex] do begin
  d.kind:= ck_type;
  d.typ.indirectlevel:= 0;
//  d.typ.flags:= [];
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

procedure handletype3(const info: pparseinfoty);
var
 po1,po2: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'TYPE3');
{$endif}
 with info^ do begin
  if (stacktop-stackindex = 2) and 
       (contextstack[stacktop].d.kind = ck_ident) and
       (contextstack[stacktop-1].d.kind = ck_ident) then begin
   po1:= ele.addelement(contextstack[stacktop-1].d.ident.ident,vis_max,ek_type);
   if po1 = nil then begin //duplicate
    identerror(info,stacktop-1-stackindex,err_duplicateidentifier);
   end
   else begin //todo: multi level type
    if findkindelements(info,stacktop-stackindex,
                       [ek_type],vis_max,po2) then begin
     ptypedataty(@po1^.data)^:= ptypedataty(@po2^.data)^;
     with contextstack[stackindex].d do begin
      inc(ptypedataty(@po1^.data)^.indirectlevel,typ.indirectlevel);
     end;
    end
    else begin
     identerror(info,stacktop-stackindex,err_identifiernotfound);
    end;
   end;
  end
  else begin
   internalerror(info,'H131024A');
  end;
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
 with info^ do begin
  id1:= contextstack[stacktop].d.ident.ident;
  with contextstack[stackindex],d do begin
   elemark:= ele.elementparent;
   kind:= ck_type;
   if not ele.pushelement(id1,vis_max,ek_type,typ.typedata) then begin
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
 with info^ do begin
  if ele.addelement(contextstack[stackindex+2].d.ident.ident,
                                           vis_max,ek_field,po1) then begin
   ele1:= ele.elementparent;
   ele.elementparent:= contextstack[contextstack[stackindex].parent].elemark;
                                                           //record def
   if findkindelementsdata(info,3,[ek_type],vis_max,po2) then begin
    po1^.typ:= ele.eledatarel(po2);
    with contextstack[stackindex].d do begin
     kind:= ck_field;
     field.fielddata:= ele.eledatarel(po1);
    end;
    stacktop:= stackindex;
   end
   else begin
    identerror(info,stacktop-stackindex,err_identifiernotfound);
    stacktop:= stackindex-1;
   end;
   ele.elementparent:= ele1;
  end
  else begin
   identerror(info,2,err_duplicateidentifier);
   stacktop:= stackindex-1;
  end;
 end;
end;

procedure handlerecorddefreturn(const info: pparseinfoty);
var
 int1,int2: integer;
 po1: pfielddataty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'RECORDDEFRETURN');
{$endif}
outinfo(info,'****');
 with info^ do begin
  ele.elementparent:= contextstack[stackindex].elemark; //restore
  int2:= 0;
  for int1:= stackindex+2 to stacktop do begin
   with contextstack[int1].d do begin
    po1:= ele.eledataabs(field.fielddata);
    po1^.offset:= int2;
    int2:= int2 + ptypedataty(ele.eledataabs(po1^.typ))^.bytesize;
                //todo: alignment
   end;
  end;
  with ptypedataty(ele.eledataabs(
               contextstack[stackindex].d.typ.typedata))^ do begin
   kind:= dk_record;
   datasize:= das_none;
   bytesize:= int2;
   bitsize:= int2*8;
  end;
 end;
end;

end.
