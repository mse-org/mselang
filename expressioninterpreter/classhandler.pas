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
unit classhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseparserglob;

procedure handleclassdefstart(const info: pparseinfoty);
procedure handleclassdeferror(const info: pparseinfoty);
procedure handleclassdefreturn(const info: pparseinfoty);

implementation
uses
 mseelements,msehandler,errorhandler,unithandler,grammar;
type
 classdataty = record
 end;
 pclassdataty = ^classdataty;
 
procedure classesscopeset(const info: pparseinfoty);
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          elements.eledataabs(info^.unitinfo^.classeselement))^.data;
 po2^.scopebefore:= elements.elementparent;
 elements.elementparent:= info^.unitinfo^.classeselement;
end;

procedure classesscopereset(const info: pparseinfoty);
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          elements.eledataabs(info^.unitinfo^.classeselement))^.data;
 elements.elementparent:= po2^.scopebefore;
end;

procedure handleclassdefstart(const info: pparseinfoty);
var
 po1: ptypedataty;
 po2: pclassdataty;
 id1: identty;
begin
 with info^ do begin
  with contextstack[stacktop].d do begin
   id1:= ident.ident;
   if not elements.addelement(id1,ek_type,sizeof(typedataty),po1) then begin
    identerror(info,stacktop-stackindex,err_duplicateidentifier,erl_fatal);
   end
   else begin
    classesscopeset(info);
    elements.addelement(id1,ek_class,sizeof(classdataty),po2);
    kind:= ck_class;
    classinfo.classdata:= elements.eledatarel(po2);
   end;
  end;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'CLASSDEFSTART');
{$endif}
end;

procedure handleclassdefreturn(const info: pparseinfoty);
var
 po2: pclassesdataty;
begin
 classesscopereset(info);
{$ifdef mse_debugparser}
 outhandle(info,'CLASSDEFRETURN');
{$endif}
end;

procedure handleclassdeferror(const info: pparseinfoty);
begin
 tokenexpectederror(info,tk_end);
{$ifdef mse_debugparser}
 outhandle(info,'CLASSDEFERROR');
{$endif}
end;

end.
