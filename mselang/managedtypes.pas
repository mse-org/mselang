{ MSElang Copyright (c) 2014-2016 by Martin Schreiber
   
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
 globtypes,parserglob,handlerglob,opglob,opcode,grammar;
 
const
 managedopids: array[managedopty] of identty = (
               //mo_ini, mo_fini, mo_incref, mo_decref, mo_decrefindi
                tks_ini,tks_fini,tks_incref,tks_decref,tks_decrefindi
               );
              //todo: check ssaindex
procedure writemanagedvarop(const op: managedopty; const chain: elementoffsetty;
                              {const global: boolean;} const ssaindex: integer);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                      const aaddress: addressvaluety; const ssaindex: integer);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                       const aref: addressrefty; const ssaindex: integer);

//procedure writemanagedfini(global: boolean);
procedure handlesetlength(const paramco: integer);

procedure managestring8(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
procedure managedynarray(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
procedure managedynarraydynar(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
procedure managedynarraystring8(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
procedure managearraydynar(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
procedure managearraystring8(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
procedure managerecord(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);

implementation
uses
 elements,errorhandler,handlerutils,llvmlists,subhandler,
 stackops,unithandler,segmentutils;
 
const
 setlengthops: array[datakindty] of opcodety = (
  //dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    oc_none,oc_none,   oc_none,   oc_none,    oc_none,   oc_none, oc_none,
  //dk_address,dk_record,dk_string8,      dk_dynarray,         
    oc_none,   oc_none,  oc_setlengthstr8,oc_setlengthdynarray,
  //dk_array,dk_class,dk_interface,dk_sub,
    oc_none, oc_none, oc_none,     oc_none,
  //dk_enum,dk_enumitem,dk_set, dk_character
    oc_none,oc_none,    oc_none,oc_none
 );

procedure managestring8(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aro_none,{atype,}aref,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_incref: begin
   increfsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aro_none,{atype,}aref,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarray(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aro_none,{atype,}aref,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_incref: begin
   increfsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aro_none,{atype,}aref,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarraydynar(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aro_dynamic,{atype,}aref,ssaindex);
   inipointer(aro_none,{atype,}aref,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aro_dynamic,{atype,}aref,ssaindex);
   finirefsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_incref: begin
   increfsize(aro_dynamic,{atype,}aref,ssaindex);
   increfsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aro_dynamic,{atype,}aref,ssaindex);
   decrefsize(aro_none,{atype,}aref,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarraystring8(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aro_dynamic,{atype,}aref,ssaindex);
   inipointer(aro_none,{atype,}aref,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aro_dynamic,{atype,}aref,ssaindex);
   finirefsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_incref: begin
   increfsize(aro_dynamic,{atype,}aref,ssaindex);
   increfsize(aro_none,{atype,}aref,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aro_dynamic,{atype,}aref,ssaindex);
   decrefsize(aro_none,{atype,}aref,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managearraydynar(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aro_static,{atype,}aref,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aro_static,{atype,}aref,ssaindex);
  end;
  mo_incref: begin
   increfsize(aro_static,{atype,}aref,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aro_static,{atype,}aref,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managearraystring8(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty; const ssaindex: integer);
begin
 case op of 
  mo_ini: begin
   inipointer(aro_static,{atype,}aref,ssaindex);
  end;
  mo_fini: begin
   finirefsize(aro_static,{atype,}aref,ssaindex);
  end;
  mo_incref: begin
   increfsize(aro_static,{atype,}aref,ssaindex);
  end;
  mo_decref: begin
   decrefsize(aro_static,{atype,}aref,ssaindex);
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managerecord(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty; const ssaindex: integer);
var
 sub1: pinternalsubdataty;
 op1: popinfoty;
begin
 with info do begin
  sub1:= ele.eledataabs(getaddreftype(aref)^.recordmanagehandlers[op]);
  pushaddr(aref,{atype,}ssaindex);
  op1:= callinternalsub(sub1^.address,true);
  if (sub1^.address = 0) and 
                (not modularllvm or 
                 (s.unitinfo = datatoele(sub1)^.header.defunit)) then begin 
                                          //unresolved
   linkmark(sub1^.calllinks,getsegaddress(seg_op,@op1^.par.callinfo.ad));
  end;
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
     {$ifdef mse_checkinternalerror}
      if (contextstack[s.stacktop].d.kind <> ck_fact) or 
                     (contextstack[s.stacktop-1].d.kind <> ck_fact) then begin
       internalerror(ie_handler,'20160228A');
      end;
     {$endif}
      with contextstack[s.stacktop-1] do begin
       with ptypedataty(ele.eledataabs(
                  d.dat.datatyp.typedata))^ do begin
        with additem(setlengthops[h.kind])^ do begin
         if op.op = oc_none then begin
          errormessage(err_typemismatch,[]);
         end
         else begin
          if co_llvm in compileoptions then begin
           par.ssas1:= d.dat.fact.ssaindex; //result
           par.ssas2:= contextstack[s.stacktop].d.dat.fact.ssaindex;
           par.setlength.itemsize:= 
                  info.s.unitinfo^.llvmlists.constlist.addi32(itemsize).listid;
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
 end;
end;

procedure writemanagedtypeop(const op: managedopty;
                const atype: ptypedataty; const aref: addressrefty;
                                                   const ssaindex: integer);
var
 po2,po4: ptypedataty;
 po3: pfielddataty;
 parentbefore: elementoffsetty;
 loopinfo: loopinfoty;
 bo1: boolean;
 ad1: addressrefty;
 ele1: elementoffsetty;
 i1: int32;
begin
 atype^.h.manageproc(op,{atype,}aref,ssaindex);
(*
 case atype^.h.kind of
  dk_array: begin
   i1:= 1;
   po2:= atype;
   while po2^.h.kind = dk_array do begin
    i1:= i1 * getordcount(ele.eledataabs(po2^.infoarray.indextypedata));
    po2:= ele.eledataabs(po2^.infoarray.i.itemtypedata);
   end;
   if tf_managed in po2^.h.flags then begin
    case po2^.h.kind of
     dk_dynarray: begin
      po4:= ele.eledataabs(po2^.infodynarray.i.itemtypedata);
      if not (tf_needsmanage in po4^.h.flags) then begin
       po2^.manageproc(op,aaddress,i1,ssaindex);
      end
      else begin
       notimplementederror('20160309A');
      end;
     end;
     dk_string8: begin
      po2^.manageproc(op,aaddress,i1,ssaindex);
     end;
     else begin
      notimplementederror('20160309B');
     end;
    end;
   end
   else begin
    notimplementederror('20160309C');
   end;
  end;
  dk_dynarray: begin
   po4:= ele.eledataabs(atype^.infodynarray.i.itemtypedata);
  end;
  else begin
   internalerror1(ie_managed,'20160308A');
  end;
 end;
*)
(*
 if tf_managed in atype^.h.flags then begin
  case atype^.h.kind of
   dk_array: begin
    ptypedataty(ele.eledataabs(atype^.infoarray.i.itemtypedata))^.
      manageproc(op,aaddress,
           getordcount(ele.eledataabs(atype^.infoarray.indextypedata)),
                                                                     ssaindex);
   end;
   dk_dynarray: begin
    ptypedataty(ele.eledataabs(atype^.infodynarray.i.itemtypedata))^.
                             manageproc(op,aaddress,datasizety(0),ssaindex);
   end;
   else begin
    atype^.manageproc(op,aaddress,1,ssaindex);
   end;
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
//   if po4^.h.flags * [tf_managed,tf_hasmanaged] <> [] then begin
   if tf_needsmanage in po4^.h.flags then begin
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
*)
end;

procedure writemanagedvarop(const op: managedopty;
             const chain: elementoffsetty;{ const global: boolean;}
                                               const ssaindex: integer);
var
 ad1: addressrefty;
 ele1: elementoffsetty;
 po1: pvardataty;
begin
 if chain <> 0 then begin
  ad1.kind:= ark_vardatanoaggregate;
  ad1.offset:= 0;
  ele1:= chain;
  repeat
   po1:= ele.eledataabs(ele1);
   if tf_needsmanage in po1^.vf.flags then begin
    ad1.vardata:= po1;
    writemanagedtypeop(op,ele.eledataabs(po1^.vf.typ),ad1,ssaindex);
   end;
   ele1:= po1^.vf.next;
  until ele1 = 0;
 end;
(*
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
   if tf_needsmanage in po1^.vf.flags then begin
    ad1.flags:= po1^.address.flags - [af_aggregate];
    ad1.address:= po1^.address.poaddress;
    ad1.offset:= 0;
    writemanagedtypeop(op,ele.eledataabs(po1^.vf.typ),ad1,ssaindex);
   end;
   ele1:= po1^.vf.next;
  until ele1 = 0;
 end;
*)
end;

procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                      const aaddress: addressvaluety; const ssaindex: integer);
var
 ad1: addressrefty;
begin
 {$ifdef mse_checkinternalerror}
  if af_aggregate in aaddress.flags then begin
   internalerror(ie_handler,'20160322B');
  end;
 {$endif}
notimplementederror('');
(*
 ad1.flags:= aaddress.flags;
 ad1.offset:= 0;
 ad1.address:= aaddress.poaddress; //matches all address types
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
 writemanagedtypeop(op,atype,ad1,ssaindex);
*)
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
