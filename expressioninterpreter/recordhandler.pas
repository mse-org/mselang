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
 handlerglob,elements,errorhandler;
 
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
begin
{$ifdef mse_debugparser}
 outhandle(info,'RECORDFIELD');
{$endif}
end;

end.
