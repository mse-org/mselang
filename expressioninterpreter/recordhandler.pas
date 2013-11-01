{ MSEide Copyright (c) 2013 by Martin Schreiber
   
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
unit recordhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
 
procedure handlerecorddefstart(const info: pparseinfoty);
procedure handlerecorddeferror(const info: pparseinfoty);
procedure handlerecorddefreturn(const info: pparseinfoty);
procedure handlerecordfield(const info: pparseinfoty);

implementation
uses
 handlerglob,elements,errorhandler,handlerutils;
 
procedure handlerecorddefstart(const info: pparseinfoty);
var
 po1: ptypedataty;
 id1: identty;
begin
 with info^ do begin
  id1:= contextstack[stacktop].d.ident.ident;
  contextstack[stackindex].d.elemark:= ele.elementparent;  
  if not ele.pushelement(id1,vis_max,ek_type,sizeof(typedataty),po1) then begin
   identerror(info,stacktop-stackindex,err_duplicateidentifier,erl_fatal);
  end;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'RECORDDEFSTART');
{$endif}
end;

procedure handlerecorddeferror(const info: pparseinfoty);
begin
 with info^ do begin
  ele.elementparent:= contextstack[stackindex].d.elemark;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'RECORDDEFERROR');
{$endif}
end;

procedure handlerecorddefreturn(const info: pparseinfoty);
begin
 with info^ do begin
  ele.elementparent:= contextstack[stackindex].d.elemark;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'RECORDDEFRETURN');
{$endif}
end;

procedure handlerecordfield(const info: pparseinfoty);
var
 po1: pvardataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
begin
 with info^ do begin
  ele.addelement(contextstack[stackindex+2].d.ident.ident,
       vis_max,ek_var,sizeof(vardataty),po1);
  if po1 = nil then begin
   identerror(info,2,err_duplicateidentifier);
   stacktop:= stackindex-1;
  end;
  ele1:= ele.elementparent;
  ele.elementparent:= contextstack[stackindex-2].d.elemark;
  if findkindelementsdata(info,3,vis_max,ek_type,po2) then begin
   with contextstack[stackindex].d do begin
    kind:= ck_field;
    field.typedata:= ele.eledatarel(po2);
   end;
   stacktop:= stackindex;
  end
  else begin
   identerror(info,stacktop-stackindex,err_identifiernotfound);
   stacktop:= stackindex-1;
  end;
  ele.elementparent:= ele1;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'RECORDFIELD');
{$endif}
end;

end.
