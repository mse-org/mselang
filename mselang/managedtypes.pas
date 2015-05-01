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
 parserglob,handlerglob,opglob,opcode;
              //todo: check ssaindex
procedure writemanagedvarop(const op: managedopty; const chain: elementoffsetty;
                               const global: boolean; const ssaindex: integer);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                      const aaddress: addressvaluety; const ssaindex: integer);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                       const aaddress: addressrefty; const ssaindex: integer);

//procedure writemanagedfini(global: boolean);
procedure handlesetlength(const paramco: integer);

procedure managestring8(const op: managedopty; const aaddress: addressrefty;
                             const count: datasizety; const ssaindex: integer);
procedure managedynarray(const op: managedopty; const aaddress: addressrefty;
                             const count: datasizety; const ssaindex: integer);
implementation
uses
 elements,grammar,errorhandler,handlerutils,
 stackops;
const
 setlengthops: array[datakindty] of opcodety = (
  //dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    oc_none,oc_none,   oc_none,   oc_none,    oc_none,   oc_none, oc_none,
  //dk_address,dk_record,dk_string8,      dk_dynarray,         
    oc_none,   oc_none,  oc_setlengthstr8,oc_setlengthdynarray,
  //dk_array,dk_class,dk_interface,dk_sub,
    oc_none, oc_none, oc_none,     oc_none,
  //dk_enum,dk_enumitem,dk_set
    oc_none,oc_none,    oc_none
 );

procedure managestring8(const op: managedopty; const aaddress: addressrefty;
                             const count: datasizety; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aaddress,count,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aaddress,count,ssaindex);
  end;
  mo_incref: begin
   increfsize(aaddress,count,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aaddress,count,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarray(const op: managedopty; const aaddress: addressrefty;
                             const count: datasizety; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aaddress,count,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aaddress,count,ssaindex);
  end;
  mo_incref: begin
   increfsize(aaddress,count,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aaddress,count,ssaindex);
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
                                     s.stacktop-paramcount-s.stackindex);
  end;
  if getvalue(s.stacktop-s.stackindex,das_32) then begin
   with contextstack[s.stacktop] do begin
    po1:= ele.eledataabs(d.dat.datatyp.typedata);
    if (d.dat.datatyp.indirectlevel <> 0) or 
                                    (po1^.h.kind <> dk_integer) then begin
     incompatibletypeserror(2,'dk_integer',d);
    end
    else begin
     if getaddress(s.stacktop-s.stackindex-1,true) then begin
      with ptypedataty(ele.eledataabs(
                 contextstack[s.stacktop-1].d.dat.datatyp.typedata))^ do begin
       with additem(setlengthops[h.kind])^ do begin
        if op.op = oc_none then begin
         errormessage(err_typemismatch,[]);
        end
        else begin
         par.setlength.itemsize:= itemsize;
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
                const atype: ptypedataty; const aaddress: addressrefty;
                                                   const ssaindex: integer);
var
 po2,po4: ptypedataty;
 po3: pfielddataty;
 parentbefore: elementoffsetty;
 loopinfo: loopinfoty;
 bo1: boolean;
 ad1: addressrefty;
 ele1: elementoffsetty;
begin
 if tf_managed in atype^.h.flags then begin
  if atype^.h.kind = dk_array then begin
   ptypedataty(ele.eledataabs(atype^.infoarray.i.itemtypedata))^.manageproc(
         op,aaddress,
         getordcount(ele.eledataabs(atype^.infoarray.indextypedata)),ssaindex);
  end
  else begin
   atype^.manageproc(op,aaddress,1,ssaindex);
  end;
 end
 else begin
  if atype^.h.kind = dk_array then begin
   ad1.base:= ab_reg0;
   if aaddress.base = ab_segment then begin
    with additem(oc_movesegreg0)^ do begin
     par.vsegment:= aaddress.segment;
    end;
   end
   else begin
    with additem(oc_moveframereg0)^ do begin
    end;
   end;
   beginforloop(loopinfo,
               getordcount(ele.eledataabs(atype^.infoarray.indextypedata)));
   po2:= ele.eledataabs(atype^.infoarray.i.itemtypedata);
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
   if po4^.h.flags * [tf_managed,tf_hasmanaged] <> [] then begin
    ad1.offset:= aaddress.offset + po3^.offset;
    writemanagedtypeop(op,po4,ad1,ssaindex);
   end;
   ele1:= po3^.vf.next;
  until ele1 = 0;

  if atype^.h.kind = dk_array then begin
   with additem(oc_increg0)^ do begin
    setimmoffset(po2^.h.bytesize,par);
   end;
   endforloop(loopinfo);
   with additem(oc_popreg0)^ do begin
   end;
  end;
 end;
end;

procedure writemanagedvarop(const op: managedopty;
             const chain: elementoffsetty; const global: boolean;
                                               const ssaindex: integer);
var
 ad1: addressrefty;
 ele1: elementoffsetty;
 po1: pvardataty;
begin
 if chain <> 0 then begin
  if global then begin
   ad1.base:= ab_segment;
   ad1.segment:= seg_globvar;
  end
  else begin
   ad1.base:= ab_frame;
  end;
  ele1:= chain;
  repeat
   po1:= ele.eledataabs(ele1);
   if tf_hasmanaged in po1^.vf.flags then begin
    ad1.offset:= po1^.address.poaddress;
    writemanagedtypeop(op,ele.eledataabs(po1^.vf.typ),ad1,ssaindex);
   end;
   ele1:= po1^.vf.next;
  until ele1 = 0;
 end;
end;

procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                      const aaddress: addressvaluety; const ssaindex: integer);
var
 ad1: addressrefty;
begin
 if af_segment in aaddress.flags then begin
  ad1.base:= ab_segment;
  ad1.segment:= aaddress.segaddress.segment;
 end
 else begin
  if af_stack in aaddress.flags then begin
   ad1.base:= ab_stack;
  end
  else begin
   ad1.base:= ab_frame;
  end;
 end;
 ad1.offset:= aaddress.poaddress;
 writemanagedtypeop(op,atype,ad1,ssaindex);
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
