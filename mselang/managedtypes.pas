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
 parserglob,handlerglob,opcode;

procedure writemanagedvarop(const op: managedopty; const chain: elementoffsetty;
                                                        const global: boolean);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                                                 const aaddress: addressinfoty);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                                                 const aaddress: addressrefty);

//procedure writemanagedfini(global: boolean);
procedure handlesetlength(const paramco: integer);

procedure managestring8(const op: managedopty; const aaddress: addressrefty;
                                                      const count: datasizety);
implementation
uses
 elements,grammar,errorhandler,handlerutils,
 stackops;
const
 setlengthops: array[datakindty] of opty = (
  //dk_none,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    nil,    nil,       nil,        nil,       nil,     nil,
  //dk_address,dk_record,dk_string8,     dk_array,dk_class,
    nil,       nil,      @setlengthstr8, nil,     nil,     
  //dk_enum,dk_enumitem
    nil,    nil
 );

procedure managestring8(const op: managedopty; const aaddress: addressrefty;
                                                      const count: datasizety);
begin
 case op of 
  mo_ini: begin
   inipointer(aaddress,count);
  end;
  mo_fini: begin
   finirefsize(aaddress,count);
  end;
  mo_incref: begin
   increfsize(aaddress,count);
  end;
  mo_decref: begin
   decrefsize(aaddress,count);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;
 
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

procedure writemanagedtypeop(const op: managedopty;
                       const atype: ptypedataty; const aaddress: addressrefty);
var
 po2,po4: ptypedataty;
 po3: pfielddataty;
 parentbefore: elementoffsetty;
 loopinfo: loopinfoty;
 bo1: boolean;
 ad1: addressrefty;
 ele1: elementoffsetty;
begin
 if tf_managed in atype^.flags then begin
  if atype^.kind = dk_array then begin
   ptypedataty(ele.eledataabs(atype^.infoarray.itemtypedata))^.manageproc(
         op,aaddress,getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
  end
  else begin
   atype^.manageproc(op,aaddress,1);
  end;
 end
 else begin
  if atype^.kind = dk_array then begin
   ad1.base:= ab_reg0;
   with additem^ do begin
    if aaddress.base = ab_global then begin
     op:= @moveglobalreg0;
    end
    else begin
     op:= @moveframereg0;
    end;
   end;
   beginforloop(loopinfo,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
   po2:= ele.eledataabs(atype^.infoarray.itemtypedata);
  end
  else begin
   ad1.base:= aaddress.base;
   po2:= atype;
  end;

  ele1:= po2^.fieldchain;
 {$ifdef mse_checkinternalerror}                             
  if ele1 = 0 then begin
   internalerror(ie_managed,'20140512A');
  end;
 {$endif}
  repeat
   po3:= ele.eledataabs(ele1);
   po4:= ele.eledataabs(po3^.vf.typ);
   if po4^.flags * [tf_managed,tf_hasmanaged] <> [] then begin
    ad1.offset:= aaddress.offset + po3^.offset;
    writemanagedtypeop(op,po4,ad1);
   end;
   ele1:= po3^.vf.next;
  until ele1 = 0;

  if atype^.kind = dk_array then begin
   with additem^ do begin
    op:= @increg0;
    par.imm.voffset:= po2^.bytesize;
   end;
   endforloop(loopinfo);
   with additem^ do begin
    op:= @popreg0;
   end;
  end;
 end;
end;

procedure writemanagedvarop(const op: managedopty;
                         const chain: elementoffsetty; const global: boolean);
var
 ad1: addressrefty;
 ele1: elementoffsetty;
 po1: pvardataty;
begin
 if chain <> 0 then begin
  if global then begin
   ad1.base:= ab_global;
  end
  else begin
   ad1.base:= ab_frame;
  end;
  ele1:= chain;
  repeat
   po1:= ele.eledataabs(ele1);
   if tf_hasmanaged in po1^.vf.flags then begin
    ad1.offset:= po1^.address.address;
    writemanagedtypeop(op,ele.eledataabs(po1^.vf.typ),ad1);
   end;
   ele1:= po1^.vf.next;
  until ele1 = 0;
 end;
end;

procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                                                 const aaddress: addressinfoty);
var
 ad1: addressrefty;
begin
 if af_global in aaddress.flags then begin
  ad1.base:= ab_global;
 end
 else begin
  if af_stack in aaddress.flags then begin
   ad1.base:= ab_stack;
  end
  else begin
   ad1.base:= ab_frame;
  end;
 end;
 ad1.offset:= aaddress.address;
 writemanagedtypeop(op,atype,ad1);
end;

{
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
}
end.
