{ MSElang Copyright (c) 2014 by Martin Schreiber
   
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
unit managedtypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

procedure writemanagedini(const global: boolean);
procedure writemanagedfini(const global: boolean);

implementation
uses
 elements,grammar,parserglob,handlerglob,errorhandler,handlerutils,opcode;

var
 currentwriteinifini: procedure (const address: dataoffsty;
                                       const atype: ptypedataty);

procedure doitem(aaddress: dataoffsty; const atyp: elementoffsetty); forward;

procedure writeinifiniitem(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
var
 po1: pelementinfoty;
begin
 po1:= ele.eleinfoabs(pmanageddataty(@aelement^.data)^.managedele);
 case po1^.header.kind of
  ek_field: begin
   with pfielddataty(@po1^.data)^ do begin
    doitem(offset+dataoffsty(adata),vf.typ);
   end;
  end;
  else begin
   internalerror('M20140509C');
  end;
 end;
end;

procedure doitem(aaddress: dataoffsty; const atyp: elementoffsetty);
var
 po1: ptypedataty;
 parentbefore: elementoffsetty;
 loopinfo: loopinfoty;
begin
 po1:= ele.eledataabs(atyp);
 if tf_managed in po1^.flags then begin
  currentwriteinifini(aaddress,po1);
 end
 else begin
  if not (tf_hasmanaged in po1^.flags) then begin
   internalerror('M20140509B');
  end;
  if po1^.kind = dk_array then begin
   beginforloop(loopinfo,
               getordcount(ele.eledataabs(po1^.infoarray.indextypedata)));
  end;
  parentbefore:= ele.elementparent;
  ele.elementparent:= atyp;
  ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],
                                               @writeinifiniitem,aaddress);
  ele.elementparent:= parentbefore;
  if po1^.kind = dk_array then begin
   endforloop(loopinfo);
  end;
 end;
end;
                                       
procedure writeinifini(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
var
 po1: pelementinfoty;
 po3: ptypedataty;
begin
 po1:= ele.eleinfoabs(pmanageddataty(@aelement^.data)^.managedele);
 case po1^.header.kind of
  ek_var: begin
   with pvardataty(@po1^.data)^ do begin
    po3:= ele.eledataabs(vf.typ);
    doitem(address.address,vf.typ);
   end;
  end;
  else begin
   internalerror('M20140509A');
  end;
 end;
end;

procedure writeinilocal(const aadress: dataoffsty; const atype: ptypedataty);
var
 po1: ptypedataty;
begin
 if atype^.kind = dk_array then begin
  po1:= ele.eledataabs(atype^.infoarray.itemtypedata);
  po1^.iniproc(aadress,false,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
 end
 else begin
  atype^.iniproc(aadress,false,1);
 end;
end;

procedure writeiniglobal(const aadress: dataoffsty; const atype: ptypedataty);
var
 po1: ptypedataty;
begin
 if atype^.kind = dk_array then begin
  po1:= ele.eledataabs(atype^.infoarray.itemtypedata);
  po1^.iniproc(aadress,true,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
 end
 else begin
  atype^.iniproc(aadress,true,1);
 end;
end;

procedure writefinilocal(const aadress: dataoffsty; const atype: ptypedataty);
var
 po1: ptypedataty;
begin
 if atype^.kind = dk_array then begin
  po1:= ele.eledataabs(atype^.infoarray.itemtypedata);
  po1^.finiproc(aadress,false,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
 end
 else begin
  atype^.finiproc(aadress,false,1);
 end;
end;

procedure writefiniglobal(const aadress: dataoffsty; const atype: ptypedataty);
var
 po1: ptypedataty;
begin
 if atype^.kind = dk_array then begin
  po1:= ele.eledataabs(atype^.infoarray.itemtypedata);
  po1^.finiproc(aadress,true,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
 end
 else begin
  atype^.finiproc(aadress,true,1);
 end;
end;

procedure writemanagedini(const global: boolean);
begin
 if global then begin
  currentwriteinifini:= @writeiniglobal;
 end
 else begin
  currentwriteinifini:= @writeinilocal;
 end;
 ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],@writeinifini,nil^);
end;

procedure writemanagedfini(const global: boolean);
begin
 if global then begin
  currentwriteinifini:= @writefiniglobal;
 end
 else begin
  currentwriteinifini:= @writefinilocal;
 end;
 ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],@writeinifini,nil^);
end;

end.
