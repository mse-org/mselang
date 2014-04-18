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
unit classhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;

procedure handleclassdefstart();
procedure handleclassdeferror();
procedure handleclassdefreturn();
procedure handleclassdefparam2();
procedure handleclassdefparam3a();
procedure handleclassprivate();
procedure handleclassprotected();
procedure handleclasspublic();
procedure handleclasspublished();
procedure handleclassfield();
procedure handlemethfunctionentry();
procedure handlemethprocedureentry();
procedure handlecreatesubentry();
procedure handledestroysubentry();

implementation
uses
 elements,handler,errorhandler,unithandler,grammar,handlerglob,handlerutils,
 parser,typehandler;
{
const
 vic_private = vis_3;
 vic_protected = vis_2;
 vic_public = vis_1;
 vic_published = vis_0;
}
{
procedure classesscopeset();
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          ele.eleinfoabs(info.unitinfo^.classeselement))^.data;
 po2^.scopebefore:= ele.elementparent;
 ele.elementparent:= info.unitinfo^.classeselement;
end;

procedure classesscopereset();
var
 po2: pclassesdataty;
begin
 po2:= @pelementinfoty(
          ele.eleinfoabs(info.unitinfo^.classeselement))^.data;
 ele.elementparent:= po2^.scopebefore;
end;
}
procedure handleclassdefstart();
var
// po1: ptypedataty;
// po2: pclassdataty;
// po3: pvisibledataty;
 id1: identty;

begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFSTART');
{$endif}
outinfo('***');
 with info do begin
  if stackindex < 3 then begin
   internalerror('H20140325D');
   exit;
  end;
  include(currentstatementflags,stf_classdef);
  with contextstack[stackindex] do begin
   d.kind:= ck_classdef;
   d.cla.visibility:= classpublishedvisi;
   d.cla.fieldoffset:= 0;
  end;
  with contextstack[stackindex-2] do begin
   if (d.kind = ck_ident) and 
                  (contextstack[stackindex-1].d.kind = ck_typetype) then begin
    id1:= d.ident.ident; //typedef
   end
   else begin
    errormessage(err_anonclassdef,[]);
    exit;
   end;
  end;
  contextstack[stackindex].elemark:= ele.elementparent;
  with contextstack[stackindex-1] do begin
   if not ele.pushelement(id1,globalvisi,ek_type,d.typ.typedata) then begin
    identerror(stacktop-stackindex,err_duplicateidentifier,erl_fatal);
   end;
   currentclass:= d.typ.typedata;
  end;
{
  if not ele.addelement(id1,vis_max,ek_type,po1) then begin
   identerror(stacktop-stackindex,err_duplicateidentifier,erl_fatal);
  end
  else begin
   classesscopeset();
   ele.pushelement(id1,vis_max,ek_class,po2);
   currentclass:= ele.eledatarel(po2);
   currentclassvislevel:= vic_published; //default
  end;
 }
 end;
end;

procedure handleclassdefparam2();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFPARAM2');
{$endif}
outinfo('***');
 with info do begin
//  dec(stackindex);
 end;
end;

procedure handleclassdefparam3a();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFPARAM3A');
{$endif}
outinfo('***');
 with info do begin
//  dec(stackindex);
 end;
end;

procedure handleclassdefreturn();
var
 po2: pclassesdataty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFRETURN');
{$endif}
outinfo('***');
// classesscopereset();
 with info do begin
  exclude(currentstatementflags,stf_classdef);
  with contextstack[stackindex-1],ptypedataty(ele.eledataabs(
                                                d.typ.typedata))^ do begin
   kind:= dk_class;
   datasize:= das_pointer;
   bytesize:= pointersize;
   bitsize:= pointersize*8;
   indirectlevel:= d.typ.indirectlevel;
   
   if not ele.addelement(tks_classimp,globalvisi,ek_classimp,
                                                 infoclass.impl) then begin
    internalerror('C20140415B');
   end;
  end;
  ele.elementparent:= contextstack[stackindex].elemark;
  currentclass:= 0;
 end;
end;

procedure handleclassdeferror();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSDEFERROR');
{$endif}
 tokenexpectederror(tk_end);
end;

procedure handleclassprivate();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPRIVATE');
{$endif}
outinfo('***');
 with info,contextstack[stackindex] do begin
  d.cla.visibility:= classprivatevisi;
 end;
end;

procedure handleclassprotected();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPROTECTED');
{$endif}
 with info,contextstack[stackindex] do begin
  d.cla.visibility:= classprotectedvisi;
 end;
end;

procedure handleclasspublic();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPUBLIC');
{$endif}
 with info,contextstack[stackindex] do begin
  d.cla.visibility:= classpublicvisi;
 end;
end;

procedure handleclasspublished();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPUBLISHED');
{$endif}
 with info,contextstack[stackindex] do begin
  d.cla.visibility:= classpublishedvisi;
 end;
end;

procedure handleclassfield();
var
 po1: pvardataty;
 po2: ptypedataty;
 ele1: elementoffsetty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASSFIELD');
{$endif}
outinfo('***');
 with info,contextstack[stackindex-1] do begin
  checkrecordfield(d.cla.visibility,[vf_classfield],d.cla.fieldoffset);
 end;
 {
 with info do begin
  ele.addelement(contextstack[stackindex+2].d.ident.ident,
       currentclassvislevel,ek_var,po1);
  if po1 = nil then begin
   identerror(2,err_duplicateidentifier);   
  end;
  ele1:= ele.elementparent;
  classesscopereset();
  if findkindelementsdata(3,[ek_type],vis_max,po2) then begin
  end
  else begin
   identerror(stacktop-stackindex,err_identifiernotfound);
  end;
  ele.elementparent:= ele1;
 end;
 }
end;

procedure handlemethprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHPROCEDUREENTRY');
{$endif}
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_header,sf_method];
 end;
end;

procedure handlemethfunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHFUNCTIONENTRY');
{$endif}
outinfo('****');
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_function,sf_header,sf_method];
 end;
end;

procedure handlecreatesubentry();
begin
{$ifdef mse_debugparser}
 outhandle('CREATEENTRY');
{$endif}
outinfo('****');
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_function,sf_header,sf_method];
 end;
end;

procedure handledestroysubentry();
begin
{$ifdef mse_debugparser}
 outhandle('DESTROYENTRY');
{$endif}
outinfo('****');
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_header,sf_method];
 end;
end;

end.
