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
uses
 parserglob;
procedure writemanagedini(const chain: elementoffsetty; global: boolean);
procedure writemanagedfini(global: boolean);
procedure handlesetlength(const paramco: integer);

implementation
uses
 elements,grammar,handlerglob,errorhandler,handlerutils,opcode,
 stackops;
const
 setlengthops: array[datakindty] of opty = (
  //dk_none,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    nil,    nil,       nil,        nil,       nil,     nil,
  //dk_address,dk_record,dk_string8,dk_array,dk_class
    nil,       nil,      @setlengthstr8,       nil,     nil
 );
 
procedure handlesetlength(const paramco: integer);
var
 len: integer;
 po1: ptypedataty;
begin
 with info do begin
  if paramco <> 2 then begin
   errormessage(err_wrongnumberofparameters,['setlength'],
                                     stacktop-paramcount-stackindex);
  end;
  if getvalue(stacktop-stackindex) then begin
   with contextstack[stacktop] do begin
    po1:= ele.eledataabs(d.datatyp.typedata);
    if (d.datatyp.indirectlevel <> 0) or (po1^.kind <> dk_integer) then begin
     incompatibletypeserror(2,'dk_integer',d);
    end
    else begin
     if getaddress(stacktop-stackindex-1,true) then begin
      with ptypedataty(ele.eledataabs(
                 contextstack[stacktop-1].d.datatyp.typedata))^ do begin
       with additem^ do begin
        op:= setlengthops[kind];
        if op = nil then begin
         errormessage(err_typemismatch,[]);
        end;
       end;
      end;
     end;
    end;     
   end;   
  end;
 end;
end;

var
 currentwriteinifini: procedure (const address: addressrefty;
                                                const atype: ptypedataty);

procedure doitem(var aaddress: addressrefty;
                              atyp: elementoffsetty); forward;

procedure writeinifiniitem(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
var
 po1: pelementinfoty;
 ad1: addressrefty;
begin
 po1:= ele.eleinfoabs(pmanageddataty(@aelement^.data)^.managedele);
 ad1:= addressrefty(adata);
 case po1^.header.kind of
  ek_field: begin
   with pfielddataty(@po1^.data)^ do begin
    inc(ad1.offset,offset);
    doitem(ad1,vf.typ);
   end;
  end;
  else begin
   internalerror('M20140509C');
  end;
 end;
end;

procedure doitem(var aaddress: addressrefty; atyp: elementoffsetty);
var
 po1: ptypedataty;
 parentbefore: elementoffsetty;
 loopinfo: loopinfoty;
 bo1: boolean;
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
   bo1:= aaddress.base = ab_global;
   aaddress.base:= ab_reg0;
   with additem^ do begin
    if bo1 then begin
     op:= @moveglobalreg0;
    end
    else begin
     op:= @moveframereg0;
    end;
   end;
   beginforloop(loopinfo,
               getordcount(ele.eledataabs(po1^.infoarray.indextypedata)));
   atyp:= po1^.infoarray.itemtypedata;
  end;
  parentbefore:= ele.elementparent;
  ele.elementparent:= atyp;
  ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],
                                               @writeinifiniitem,aaddress);
  ele.elementparent:= parentbefore;
  if po1^.kind = dk_array then begin
   with additem^ do begin
    op:= @increg0;
    par.imm.voffset:= ptypedataty(ele.eledataabs(atyp))^.bytesize;
   end;
   endforloop(loopinfo);
   if bo1 then begin              //restore
    aaddress.base:= ab_global;
   end
   else begin
    aaddress.base:= ab_frame;
   end;
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
    addressrefty(adata).offset:= address.address;
    doitem(addressrefty(adata),vf.typ);
   end;
  end;
  else begin
   internalerror('M20140509A');
  end;
 end;
end;

procedure writeini(const aadress: addressrefty; const atype: ptypedataty);
var
 po1: ptypedataty;
begin
 if atype^.kind = dk_array then begin
  po1:= ele.eledataabs(atype^.infoarray.itemtypedata);
  po1^.iniproc(aadress,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
 end
 else begin
  atype^.iniproc(aadress,1);
 end;
end;

procedure writefini(const aadress: addressrefty; const atype: ptypedataty);
var
 po1: ptypedataty;
begin
 if atype^.kind = dk_array then begin
  po1:= ele.eledataabs(atype^.infoarray.itemtypedata);
  po1^.finiproc(aadress,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
 end
 else begin
  atype^.finiproc(aadress,1);
 end;
end;

(*
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
*)
procedure writemanagedini(const chain: elementoffsetty; global: boolean);
var
 ad1: addressrefty;
 ele1: elementoffsetty;
 po1: pvardataty;
begin
 ele1:= chain;
 while ele1 <> 0 do begin
  po1:= ele.eledataabs(ele1);
  ele1:= po1^.next;
 end;
 currentwriteinifini:= @writeini;
 if global then begin
  ad1.base:= ab_global;
 end
 else begin
  ad1.base:= ab_frame;
 end;
 ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],@writeinifini,ad1);
end;

procedure writemanagedfini(global: boolean);
var
 ad1: addressrefty;
begin
 currentwriteinifini:= @writefini;
 if global then begin
  ad1.base:= ab_global;
 end
 else begin
  ad1.base:= ab_frame;
 end;
 ele.forallcurrent(tks_managed,[ek_managed],[vik_managed],@writeinifini,ad1);
end;

end.
