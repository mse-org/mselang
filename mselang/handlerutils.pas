{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
unit handlerutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 handlerglob,parserglob,elements,msestrings;

type
 comperrorty = (ce_invalidfloat,ce_expressionexpected,ce_startbracketexpected,
               ce_endbracketexpected);
const
 errormessages: array[comperrorty] of msestring = (
  'Invalid Float',
  'Expression expected',
  '''('' expected',
  ''')'' expected'
 );

type
 varinfoty = record
  flags: varflagsty;
  address: ptruint;
  typ: typedataty;
 end;
 
procedure error(const info: pparseinfoty; const error: comperrorty;
                   const pos: pchar=nil);
procedure parsererror(const info: pparseinfoty; const text: string);
procedure identnotfounderror(const info: contextitemty; const text: string);
procedure wrongidentkinderror(const info: contextitemty; 
       wantedtype: elementkindty; const text: string);
procedure outcommand(const info: pparseinfoty; const items: array of integer;
                     const text: string);
 
function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty; const visibility: vislevelty;
                                    out ainfo: pointer): boolean;
function findkindelements(const info: pparseinfoty;
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty;
           out lastident: integer; out idents: identvecty): boolean;
function findkindelements(const info: pparseinfoty;
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty): boolean;
function findkindelementsdata(const info: pparseinfoty;
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer;
              out lastident: integer; out idents: identvecty): boolean;
function findkindelementsdata(const info: pparseinfoty;
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer): boolean;

function findvar(const info: pparseinfoty; const astackoffset: integer; 
                const visibility: vislevelty; out varinfo: varinfoty): boolean;
                           
implementation
uses
 errorhandler,typinfo;
 
procedure error(const info: pparseinfoty; const error: comperrorty;
                   const pos: pchar=nil);
begin
 outcommand(info,[],'*ERROR* '+errormessages[error]);
end;


function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer): boolean;
var
 po1: pelementinfoty;
 ele1: elementoffsetty;
begin
 result:= false;
 if aident.kind = ck_ident then begin
  if ele.findcurrent(aident.ident.ident,akinds,visibility,ele1) then begin
   po1:= ele.eleinfoabs(ele1);
   ainfo:= @po1^.data;
   result:= true;
  end;
 end;
end;

function findkindelementdata(const info: pparseinfoty;
              const astackoffset: integer;
              const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer): boolean;
begin
 with info^ do begin
  result:= findkindelementdata(contextstack[stackindex+astackoffset].d,
                                                      akinds,visibility,ainfo);
 end;
end;

function getidents(const info: pparseinfoty; const astackoffset: integer;
                     out idents: identvecty): boolean;
var
 po1: pcontextitemty;
 int1: integer;
begin
 with info^ do begin
  po1:= @contextstack[stackindex+astackoffset];
  identcount:= -1;
  for int1:= 0 to high(idents.d) do begin
   idents.d[int1]:= po1^.d.ident.ident;
   if not po1^.d.ident.continued then begin
    identcount:= int1;
    break;
   end;
   inc(po1);
  end;
  idents.high:= identcount;
  inc(identcount);
  result:= true;
  if identcount = 0 then begin
   errormessage(info,astackoffset+identcount,err_toomanyidentifierlevels,[]);
   result:= false;
  end;
 end;
end;

function findkindelements(const info: pparseinfoty;
            const astackoffset: integer; const akinds: elementkindsty; 
            const visibility: vislevelty;
            out aelement: pelementinfoty;
            out lastident: integer; out idents: identvecty): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents(info,astackoffset,idents) then begin
  with info^ do begin
   result:= ele.findupward(idents,akinds,visibility,eleres,lastident);
   if not result then begin //todo: use cache
    ele2:= ele.elementparent;
    for int1:= 0 to high(info^.unitinfo^.implementationuses) do begin
     ele.elementparent:=
       info^.unitinfo^.implementationuses[int1]^.interfaceelement;
     result:= ele.findupward(idents,akinds,visibility,eleres,lastident);
     if result then begin
      break;
     end;
    end;
    if not result then begin
     for int1:= 0 to high(info^.unitinfo^.interfaceuses) do begin
      ele.elementparent:=
        info^.unitinfo^.interfaceuses[int1]^.interfaceelement;
      result:= ele.findupward(idents,akinds,visibility,eleres,lastident);
      if result then begin
       break;
      end;
     end;
    end;
    ele.elementparent:= ele2;
   end;
  end;
 end;
 if result then begin
  aelement:= ele.eleinfoabs(eleres);
 end;
end;

function findkindelements(const info: pparseinfoty;
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
 idents: identvecty;
 lastident: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents(info,astackoffset,idents) then begin
  with info^ do begin
   result:= ele.findupward(idents,[],visibility,eleres,lastident); //exact
   if not result then begin //todo: use cache
    ele2:= ele.elementparent;
    for int1:= 0 to high(info^.unitinfo^.implementationuses) do begin
     ele.elementparent:=
       info^.unitinfo^.implementationuses[int1]^.interfaceelement;
     result:= ele.findupward(idents,[],visibility,eleres,lastident); //exact
     if result then begin
      break;
     end;
    end;
    if not result then begin
     for int1:= 0 to high(info^.unitinfo^.interfaceuses) do begin
      ele.elementparent:=
        info^.unitinfo^.interfaceuses[int1]^.interfaceelement;
      result:= ele.findupward(idents,[],visibility,eleres,lastident); //exact
      if result then begin
       break;
      end;
     end;
    end;
    ele.elementparent:= ele2;
   end;
  end;
 end;
 if result then begin
  aelement:= ele.eleinfoabs(eleres);
  result:= (akinds = []) or (aelement^.header.kind in akinds);
 end;
end;

function findkindelementsdata(const info: pparseinfoty;
             const astackoffset: integer;
             const akinds: elementkindsty; const visibility: vislevelty; 
             out ainfo: pointer; out lastident: integer;
             out idents: identvecty): boolean;
begin
 result:= findkindelements(info,astackoffset,akinds,visibility,ainfo,
                                lastident,idents);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

function findkindelementsdata(const info: pparseinfoty;
             const astackoffset: integer;
             const akinds: elementkindsty; const visibility: vislevelty; 
             out ainfo: pointer): boolean;
begin
 result:= findkindelements(info,astackoffset,akinds,visibility,ainfo);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

function findvar(const info: pparseinfoty; const astackoffset: integer; 
                   const visibility: vislevelty;
                           out varinfo: varinfoty): boolean;
var
 idents,types: identvecty;	
 po1: pvardataty;
 po2: ptypedataty;
 po3: pfielddataty;
 ele1,ele2: elementoffsetty;
 int1: integer;
begin
 result:= false;
 if getidents(info,astackoffset,idents) then begin
  result:= ele.findupward(idents,[ek_var],visibility,ele1,int1);
  if result then begin
   po1:= ele.eledataabs(ele1);
   varinfo.flags:= po1^.flags;
   varinfo.address:= po1^.address;
   ele2:= po1^.typ;
   if int1 < idents.high then begin
    for int1:= int1+1 to idents.high do begin //fields
     result:= ele.findchild(ele2,idents.d[int1],[ek_field],visibility,ele2);
     if not result then begin
      identerror(info,astackoffset+int1,err_identifiernotfound);
      exit;
     end;
     po3:= ele.eledataabs(ele2);
     varinfo.address:= varinfo.address + po3^.offset;
    end;
    po2:= ele.eledataabs(po3^.typ);
    varinfo.typ:= po2^;
   end
   else begin
    po2:= ele.eledataabs(ele2);
    varinfo.typ:= po2^;
   end;
  end
  else begin
   identerror(info,astackoffset,err_identifiernotfound);
  end;
 end;
end;                           

procedure parsererror(const info: pparseinfoty; const text: string);
begin
 with info^ do begin
  contextstack[stackindex].d.kind:= ck_error;
  writeln(' ***ERROR*** '+text);
 end; 
end;

procedure identnotfounderror(const info: contextitemty; const text: string);
begin
 writeln(' ***ERROR*** ident '+lstringtostring(info.start.po,info.d.ident.len)+
                   ' not found. '+text);
end;

procedure wrongidentkinderror(const info: contextitemty; 
       wantedtype: elementkindty; const text: string);
begin
 writeln(' ***ERROR*** wrong ident kind '+
               lstringtostring(info.start.po,info.d.ident.len)+
                   ', expected '+
         getenumname(typeinfo(elementkindty),ord(wantedtype))+'. '+text);
end;
 
procedure outcommand(const info: pparseinfoty; const items: array of integer;
                     const text: string);
var
 int1: integer;
begin
 with info^ do begin
  for int1:= 0 to high(items) do begin
   with contextstack[stacktop+items[int1]].d do begin
    command.write([getenumname(typeinfo(kind),ord(kind)),': ']);
    case kind of
     ck_const: begin
      with constval.d do begin
       case kind of
        dk_bool8: begin
         command.write(longbool(vbool8));
        end;
        dk_sint32: begin
         command.write(vsint32);
        end;
        dk_flo64: begin
         command.write(vflo64);
        end;
       end;
      end;
     end;
    end;
    command.write(',');
   end;
  end;
  command.writeln([' ',text]);
 end;
end;

end.