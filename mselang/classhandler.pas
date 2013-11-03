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
 parserglob;

procedure handleclassdefstart(const info: pparseinfoty);
procedure handleclassdeferror(const info: pparseinfoty);
procedure handleclassdefreturn(const info: pparseinfoty);
procedure handleclassprivate(const info: pparseinfoty);
procedure handleclassprotected(const info: pparseinfoty);
procedure handleclasspublic(const info: pparseinfoty);
procedure handleclasspublished(const info: pparseinfoty);
procedure handleclassfield(const info: pparseinfoty);

implementation
uses
 elements,handler,errorhandler,unithandler,grammar,handlerglob,handlerutils;

const
 vic_private = vis_3;
 vic_protected = vis_2;
 vic_public = vis_1;
 vic_published = vis_0;
 
procedure classesscopeset(const info: pparseinfoty);
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          ele.eledataabs(info^.unitinfo^.classeselement))^.data;
 po2^.scopebefore:= ele.elementparent;
 ele.elementparent:= info^.unitinfo^.classeselement;
end;

procedure classesscopereset(const info: pparseinfoty);
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          ele.eledataabs(info^.unitinfo^.classeselement))^.data;
 ele.elementparent:= po2^.scopebefore;
end;

procedure handleclassdefstart(const info: pparseinfoty);
var
 po1: ptypedataty;
 po2: pclassdataty;
 po3: pvisibledataty;
 id1: identty;
begin
 with info^ do begin
  id1:= contextstack[stacktop].d.ident.ident;
  if not ele.addelement(id1,vis_max,ek_type,po1) then begin
   identerror(info,stacktop-stackindex,err_duplicateidentifier,erl_fatal);
  end
  else begin
   classesscopeset(info);
   ele.pushelement(id1,vis_max,ek_class,po2);
   currentclass:= ele.eledatarel(po2);
   currentclassvislevel:= vic_published; //default
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
// ele.popelement;
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

procedure handleclassprivate(const info: pparseinfoty);
begin
 info^.currentclassvislevel:= vic_private;
{$ifdef mse_debugparser}
 outhandle(info,'CLASSPRIVATE');
{$endif}
end;

procedure handleclassprotected(const info: pparseinfoty);
begin
 info^.currentclassvislevel:= vic_protected;
{$ifdef mse_debugparser}
 outhandle(info,'CLASSPROTECTED');
{$endif}
end;

procedure handleclasspublic(const info: pparseinfoty);
begin
 info^.currentclassvislevel:= vic_public;
{$ifdef mse_debugparser}
 outhandle(info,'CLASSPUBLIC');
{$endif}
end;

procedure handleclasspublished(const info: pparseinfoty);
begin
 info^.currentclassvislevel:= vic_published;
{$ifdef mse_debugparser}
 outhandle(info,'CLASSPUBLISHED');
{$endif}
end;

procedure handleclassfield(const info: pparseinfoty);
var
 po1: pvardataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
begin
 with info^ do begin
  ele.addelement(contextstack[stackindex+2].d.ident.ident,
       currentclassvislevel,ek_var,po1);
  if po1 = nil then begin
   identerror(info,2,err_duplicateidentifier);   
  end;
  ele1:= ele.elementparent;
  classesscopereset(info);
  if findkindelementsdata(info,3,[ek_type],vis_max,po2) then begin
  end
  else begin
   identerror(info,stacktop-stackindex,err_identifiernotfound);
  end;
  ele.elementparent:= ele1;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'CLASSFIELD');
{$endif}
end;

end.
