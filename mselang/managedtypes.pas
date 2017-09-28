{ MSElang Copyright (c) 2014-2017 by Martin Schreiber
   
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
 globtypes,parserglob,handlerglob,opglob,opcode,listutils,grammarglob;
 
type
 managedtempitemty = record
  header: linkheaderty;
  typ: elementoffsetty;
  index: int32;
//  entry: int32;  //index of op_pushcpucontext
//  links: linkindexty;
 end;
 pmanagedtempitemty = ^managedtempitemty;
var
 managedtemplist: linklistty;
 
const
 managedopids: array[managedopty] of identty = (
               //mo_ini, mo_inizeroed, mo_fini, mo_incref, 
                tks_ini,tks_inizeroed,tks_fini,tks_incref,
               //mo_decref, mo_decrefindi,
                tks_decref,tks_decrefindi,
               //mo_destroy
                tks_destroy
               );

              //todo: check ssaindex
procedure writemanagedvarop(const op: managedopty; const avar: pvardataty;
                                                  const acontextindex: int32);
procedure writemanagedvarop(const op: managedopty;
                            const chain: elementoffsetty; //vardataty
                                                    const acontextindex: int32);
procedure writemanagedtempop(const op: managedopty;
                            const achain: listadty; //managettempitem
                                                    const acontextindex: int32);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                    const aaddress: addressvaluety; const acontextindex: int32);
procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                                                     var aref: addressrefty);
function writemanagedtempvarop(const op: managedopty;
                 const aitem: listadty; const acontextindex: int32): boolean;
                              //uses tempvarlist, false if none

//procedure writemanagedfini(global: boolean);
procedure handlesetlength(const paramco: integer);
procedure handleunique(const paramco: integer);
procedure handleinitialize(const paramco: integer);
procedure handlefinalize(const paramco: integer);
procedure handleincref(const paramco: integer);
procedure handledecref(const paramco: integer);

procedure managestring(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
procedure managedynarray(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
procedure managedynarraydynar(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
procedure managedynarraystring(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
procedure managearraydynar(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
procedure managearraystring(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
procedure managerecord(const op: managedopty;{ const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});

implementation
uses
 elements,errorhandler,handlerutils,llvmlists,subhandler,syssubhandler,
 stackops,unithandler,segmentutils,valuehandler,msetypes;
{ 
const
 setlengthops: array[datakindty] of opcodety = (
  //dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    oc_none,oc_none,   oc_none,   oc_none,    oc_none,   oc_none, oc_none,
  //dk_address,dk_record,dk_string,      dk_dynarray,         dk_openarray,
    oc_none,   oc_none,  oc_setlengthstr8,oc_setlengthdynarray,oc_none,
  //dk_array,dk_class,dk_interface,dk_sub, dk_method
    oc_none, oc_none, oc_none,     oc_none,oc_none,
  //dk_enum,dk_enumitem,dk_set, dk_character,dk_data
    oc_none,oc_none,    oc_none,oc_none,     oc_none
 );
}
{
 uniqueops: array[datakindty] of opcodety = (
  //dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    oc_none,oc_none,   oc_none,   oc_none,    oc_none,   oc_none, oc_none,
  //dk_address,dk_record,dk_string8,      dk_dynarray,   dk_openarray,
    oc_none,   oc_none,  oc_uniquestr8,oc_uniquedynarray,oc_none,
  //dk_array,dk_class,dk_interface,dk_sub, dk_method
    oc_none, oc_none, oc_none,     oc_none,oc_none,
  //dk_enum,dk_enumitem,dk_set, dk_character,dk_data
    oc_none,oc_none,    oc_none,oc_none,     oc_none
 );
}
procedure managestring(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty{; const ssaindex: integer});
begin
 case op of 
  mo_ini: begin
   inipointer(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_inizeroed: begin
   //nothing to do
  end;
  mo_fini: begin
   finirefsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_incref: begin
   increfsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_decref: begin
   decrefsize(aro_none,{atype,}aref{,ssaindex});
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarray(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty{; const ssaindex: integer});
begin
 case op of 
  mo_ini: begin
   inipointer(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_inizeroed: begin
   //nothing to do
  end;
  mo_fini: begin
   finirefsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_incref: begin
   increfsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_decref: begin
   decrefsize(aro_none,{atype,}aref{,ssaindex});
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarraydynar(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty{; const ssaindex: integer});
begin
 case op of 
  mo_ini: begin
   inipointer(aro_dynamic,{atype,}aref{,ssaindex});
   inipointer(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_inizeroed: begin
   //nothing to do
  end;
  mo_fini: begin
   finirefsize(aro_dynamic,{atype,}aref{,ssaindex});
   finirefsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_incref: begin
   increfsize(aro_dynamic,{atype,}aref{,ssaindex});
   increfsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_decref: begin
   decrefsize(aro_dynamic,{atype,}aref{,ssaindex});
   decrefsize(aro_none,{atype,}aref{,ssaindex});
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managedynarraystring(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty{; const ssaindex: integer});
begin
 case op of 
  mo_ini: begin
//   inipointer(aro_dynamic,{atype,}aref{,ssaindex});
   inipointer(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_fini: begin
   finirefsize(aro_dynamic,{atype,}aref{,ssaindex});
//   finirefsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_incref: begin
   increfsize(aro_dynamic,{atype,}aref{,ssaindex});
   increfsize(aro_none,{atype,}aref{,ssaindex});
  end;
  mo_decref: begin
   decrefsize(aro_dynamic,{atype,}aref{,ssaindex});
   decrefsize(aro_none,{atype,}aref{,ssaindex});
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managearraydynar(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty{; const ssaindex: integer});
begin
 case op of 
  mo_ini: begin
   inipointer(aro_static,{atype,}aref{,ssaindex});
  end;
  mo_inizeroed: begin
   //nothing to do
  end;
  mo_fini: begin
   finirefsize(aro_static,{atype,}aref{,ssaindex});
  end;
  mo_incref: begin
   increfsize(aro_static,{atype,}aref{,ssaindex});
  end;
  mo_decref: begin
   decrefsize(aro_static,{atype,}aref{,ssaindex});
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managearraystring(const op: managedopty;{ const atype: ptypedataty;}
                       const aref: addressrefty{; const ssaindex: integer});
begin
 case op of 
  mo_ini: begin
   inipointer(aro_static,{atype,}aref{,ssaindex});
  end;
  mo_inizeroed: begin
   //nothing to do
  end;
  mo_fini: begin
   finirefsize(aro_static,{atype,}aref{,ssaindex});
  end;
  mo_incref: begin
   increfsize(aro_static,{atype,}aref{,ssaindex});
  end;
  mo_decref: begin
   decrefsize(aro_static,{atype,}aref{,ssaindex});
  end;
 {$ifdef mse_checkinternalerror}                             
  else begin
   internalerror(ie_managed,'20140416A');
  end;
 {$endif}
 end;
end;

procedure managerecord(const op: managedopty; const aref: addressrefty);
var
 sub1: pinternalsubdataty;
 op1: popinfoty;
 typ1: ptypedataty;
 ele1: elementoffsetty;
 sf1: dosubflagsty;
 i1,i2,i3: int32;
// i1: int32;
begin
 with info do begin
  typ1:= getaddreftype(aref);
  if aref.isclass then begin
   ele1:= 0;
   i2:= aref.contextindex-s.stackindex;
   case op of
    mo_ini: begin
     i1:= pushmanageaddr(aref);
     with insertitem(oc_storestackindipopnil,i2,-1)^ do begin
      par.ssas1:= i1;
     end;
    end;
    mo_incref: begin
     ele1:= typ1^.infoclass.subattach.incref;
     sf1:= [dsf_objini];
    end;
    mo_decref,mo_fini: begin
     ele1:= typ1^.infoclass.subattach.decref;
     sf1:= [dsf_objfini];
    end;
   end;
   if ele1 <> 0 then begin
    i1:= pushmanageaddr(aref);
    i3:= opcount;
    with addcontrolitem(oc_gotonilindirect)^ do begin //insert?
     par.ssas1:= i1;
    end; //skip call in case of nil instance
    with insertitem(oc_indirectpo,i2,-1)^ do begin
     par.ssas1:= i1;
     i1:= par.ssad;
    end;
    callsub(aref.contextindex,ele.eledataabs(ele1),aref.contextindex,0,sf1,i1);
    with getoppo(i3)^ do begin
     par.opaddress.opaddress:= opcount-1;
    end;
    addlabel(); //insert?
   end;
  end
  else begin   
   sub1:= ele.eledataabs(typ1^.recordmanagehandlers[op]);
   i1:= pushmanageaddr(aref);
   op1:= callinternalsubpo(sub1^.address,i1,aref.contextindex);
   if (sub1^.address = 0) and 
                 (not modularllvm or 
                  (s.unitinfo = datatoele(sub1)^.header.defunit)) then begin 
                                           //unresolved
    linkmark(sub1^.calllinks,getsegaddress(seg_op,@op1^.par.callinfo.ad));
   end;
  end;
 end;
end;
 
procedure handlesetlength(const paramco: integer);
var
 len: integer;
// typ1: ptypedataty;
 po1,po2: pcontextitemty;
 op1: opcodety;
begin
 with info do begin
  if checkparamco(2,paramco) then begin
   po2:= @contextstack[s.stacktop];
   po1:= getpreviousnospace(po2-1);
   if getvalue(po2,das_32) then begin
    if not tryconvert(po2,st_int32,[]) then begin
     incompatibletypeserror(sysdatatypes[st_int32],s.stacktop-s.stackindex);
     exit;
    end;
    with po2^ do begin
{
     typ1:= ele.eledataabs(d.dat.datatyp.typedata);
     if (d.dat.datatyp.indirectlevel <> 0) or 
                                     (typ1^.h.kind <> dk_integer) then begin
      incompatibletypeserror(2,'dk_integer',d);
     end
     else begin
     }
     if getaddress(po1,true) then begin
     {$ifdef mse_checkinternalerror}
      if not (po2^.d.kind in factcontexts) or 
                    not (po1^.d.kind in 
                                              [ck_fact,ck_subres]) then begin
       internalerror(ie_handler,'20160228A');
      end;
     {$endif}
      with po1^ do begin
       with ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^ do begin
        op1:= oc_none;
        case h.kind of
         dk_dynarray: begin
          op1:= oc_setlengthdynarray;
         end;
         dk_string: begin
          case itemsize of
           2: begin
            op1:= oc_setlengthstr16;
           end;
           4: begin
            op1:= oc_setlengthstr32;
           end;
           else begin
            op1:= oc_setlengthstr8;
           end;
          end;
         end;
        end;
        with additem(op1)^ do begin
         if op.op = oc_none then begin
          errormessage(err_typemismatch,[]);
         end
         else begin
          if co_llvm in o.compileoptions then begin
           par.ssas1:= d.dat.fact.ssaindex; //result
           par.ssas2:= po2^.d.dat.fact.ssaindex;
           par.setlength.itemsize:= 
                  info.s.unitinfo^.llvmlists.constlist.addi32(itemsize).listid;
          end
          else begin
           par.setlength.itemsize:= itemsize;
          end;
         end;
        end;
       end;
//       end;
      end;
     end;
    end;  
   end;
  end;
 end;
end;

function checkaddressparamsysfunc(const paramco: int32;
                                        out atype: ptypedataty): boolean;
var
 ptop: pcontextitemty;
begin
 with info do begin
  ptop:= @contextstack[s.stacktop];
  result:= checkparamco(1,paramco) and getaddress(ptop,true);
  if result then begin
   with ptop^ do begin
    atype:=  ele.eledataabs(d.dat.datatyp.typedata);
   end;
  end;
 end;
end;

function checkvalueparamsysfunc(const paramco: int32;
                                        out atype: ptypedataty): boolean;
var
 ptop: pcontextitemty;
begin
 with info do begin
  ptop:= @contextstack[s.stacktop];
  result:= checkparamco(1,paramco) and getvalue(ptop,das_none);
  if result then begin
   with ptop^ do begin
    atype:=  ele.eledataabs(d.dat.datatyp.typedata);
   end;
  end;
 end;
end;

procedure handleunique(const paramco: integer);
var
// ptop: pcontextitemty;
 op1: opcodety;
 typ1: ptypedataty;
begin
 with info do begin
//  ptop:= @contextstack[s.stacktop];
//  if checkparamco(1,paramco) and 
//                       getaddress(ptop,true) then begin
//   with ptop^ do begin
  if checkaddressparamsysfunc(paramco,typ1) then begin
 //    with ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^ do begin
   with typ1^ do begin
    op1:= oc_none;
    case h.kind of
     dk_string: begin
      case itemsize of
       1: begin
        op1:= oc_uniquestr8;
       end;
       2: begin
        op1:= oc_uniquestr16;
       end;
       4: begin
        op1:= oc_uniquestr32;
       end;
      {$ifdef mse_checkinternalerror}                             
       else begin
        internalerror(ie_managed,'20170325C');
       end;
      {$endif}
      end;
     end;
     dk_dynarray: begin
      op1:= oc_uniquedynarray;
     end;
    end;
    if op1 = oc_none then begin
     errormessage(err_typemismatch,[]);
    end
    else begin
     with additem(op1)^ do begin
      if co_llvm in o.compileoptions then begin
       par.ssas1:= contextstack[s.stacktop].d.dat.fact.ssaindex; //result
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

procedure callmanagesyssub(const asub: elementoffsetty);
var
 sub1: pinternalsubdataty;
 op1: popinfoty;
begin
 if asub > 0 then begin
  with info,contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_fact then begin
    internalerror(ie_handler,'20170926B');
   end;
  {$endif}
   sub1:= ele.eledataabs(asub);
   op1:= callinternalsubpo(sub1^.address,d.dat.fact.ssaindex,s.stacktop);
   if (sub1^.address = 0) and 
                 (not modularllvm or 
                  (s.unitinfo = datatoele(sub1)^.header.defunit)) then begin 
                                           //unresolved
    linkmark(sub1^.calllinks,getsegaddress(seg_op,@op1^.par.callinfo.ad));
   end;
  end;
 end;
end;

procedure callmanagesyssubifnotnil(const asub: elementoffsetty);
var
 sub1: psubdataty;
 op1: popinfoty;
 i3: int32;
begin
 if asub > 0 then begin
  with info,contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_fact then begin
    internalerror(ie_handler,'20170926B');
   end;
  {$endif}
   sub1:= ele.eledataabs(asub);
   i3:= opcount;
   with addcontrolitem(oc_gotonil)^ do begin
    par.ssas1:= d.dat.fact.ssaindex;
   end; //skip call in case of nil instance
   op1:= callinternalsubpo(sub1^.address,d.dat.fact.ssaindex,s.stacktop);
   if (sub1^.address = 0) and 
                 (not modularllvm or 
                  (s.unitinfo = datatoele(sub1)^.header.defunit)) then begin 
                                           //unresolved
    linkmark(sub1^.calllinks,getsegaddress(seg_op,@op1^.par.callinfo.ad));
   end;
   with getoppo(i3)^ do begin
    par.opaddress.opaddress:= opcount-1;
   end;
   addlabel();
  end;
 end;
end;


procedure handleinitialize(const paramco: integer);
var
 typ1: ptypedataty;
begin
 if checkaddressparamsysfunc(paramco,typ1) then begin
  with info,contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_fact then begin
    internalerror(ie_handler,'20170926A');
   end;
  {$endif}
   if d.dat.datatyp.indirectlevel = 1 then begin
    case typ1^.h.kind of
     dk_string,dk_dynarray,dk_class: begin
      with additem(oc_storestackindipopnil)^ do begin
       par.ssas1:= d.dat.fact.ssaindex;
      end;
     end;
     dk_record,dk_object: begin
      callmanagesyssub(typ1^.recordmanagehandlers[mo_ini]);
     end;
    end;
   end;
  end;
 end;
end;

procedure handlefinalize(const paramco: integer);
var
 typ1: ptypedataty;
begin
 if checkaddressparamsysfunc(paramco,typ1) then begin
  with info,contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_fact then begin
    internalerror(ie_handler,'20170926A');
   end;
  {$endif}
   if d.dat.datatyp.indirectlevel = 1 then begin
    case typ1^.h.kind of
     dk_string,dk_dynarray: begin
      with additem(oc_finirefsizestackindi)^ do begin
       par.memop.podataaddress.offset:= 0;
       par.memop.podataaddress.address:= -pointersize;
       par.ssas1:= d.dat.fact.ssaindex;
      end;
      with additem(oc_pop)^ do begin
       par.imm.vsize:= pointersize;
      end;
     end;
     dk_record,dk_object,dk_class: begin
      callmanagesyssub(typ1^.recordmanagehandlers[mo_fini]);
     end;
    end;
   end;
  end;
 end;
end;

procedure handleincref(const paramco: integer);
var
 typ1: ptypedataty;
begin
 with info,contextstack[s.stacktop] do begin
 {$ifdef mse_checkinternalerror}
  if not (d.kind in datacontexts) then begin
   internalerror(ie_handler,'2017092/A');
  end;
 {$endif}
  typ1:= ele.eledataabs(d.dat.datatyp.typedata);
  case typ1^.h.kind of
   dk_string,dk_dynarray: begin
    if checkvalueparamsysfunc(paramco,typ1) and
                  (d.dat.datatyp.indirectlevel = 0) then begin
     with additem(oc_increfsizestack)^ do begin
      par.memop.podataaddress.offset:= 0;
      par.memop.podataaddress.address:= -pointersize;
      par.ssas1:= d.dat.fact.ssaindex;
     end;
     with additem(oc_pop)^ do begin
      par.imm.vsize:= pointersize;
     end;
    end;
   end;
   dk_record,dk_object: begin
    if checkaddressparamsysfunc(paramco,typ1) and
              (d.dat.datatyp.indirectlevel = 1) then begin
     callmanagesyssub(typ1^.recordmanagehandlers[mo_incref]);
    end;
   end;
   dk_class: begin
    if checkvalueparamsysfunc(paramco,typ1) and
                       (d.dat.datatyp.indirectlevel = 1) then begin
     callmanagesyssubifnotnil(typ1^.infoclass.subattach.incref);
    end;
   end;
  end;
 end;
end;

procedure handledecref(const paramco: integer);
var
 typ1: ptypedataty;
begin
 with info,contextstack[s.stacktop] do begin
 {$ifdef mse_checkinternalerror}
  if not (d.kind in datacontexts) then begin
   internalerror(ie_handler,'2017092/A');
  end;
 {$endif}
  typ1:= ele.eledataabs(d.dat.datatyp.typedata);
  case typ1^.h.kind of
   dk_string,dk_dynarray: begin
    if checkvalueparamsysfunc(paramco,typ1) and
                  (d.dat.datatyp.indirectlevel = 0) then begin
     with additem(oc_decrefsizestack)^ do begin
      par.memop.podataaddress.offset:= 0;
      par.memop.podataaddress.address:= -pointersize;
      par.ssas1:= d.dat.fact.ssaindex;
     end;
     with additem(oc_pop)^ do begin
      par.imm.vsize:= pointersize;
     end;
    end;
   end;
   dk_record,dk_object: begin
    if checkaddressparamsysfunc(paramco,typ1) and
              (d.dat.datatyp.indirectlevel = 1) then begin
     callmanagesyssub(typ1^.recordmanagehandlers[mo_decref]);
    end;
   end;
   dk_class: begin
    if checkvalueparamsysfunc(paramco,typ1) and
                       (d.dat.datatyp.indirectlevel = 1) then begin
     callmanagesyssubifnotnil(typ1^.infoclass.subattach.decref);
    end;
   end;
  end;
 end;
end;

procedure writemanagedtypeop(const op: managedopty;
                const atype: ptypedataty; var aref: addressrefty);
                //todo: cleanup addressref setup
begin
 if aref.kind in [ark_stack,ark_stackref,ark_local,ark_tempvar] then begin
  aref.typ:= atype;
 end
 else begin
  if aref.kind = ark_contextdata then begin
   with pcontextdataty(aref.contextdata)^ do begin
    if kind in factcontexts then begin
     aref.ssaindex:= dat.fact.ssaindex;
    end;
   end;
  end;
 end;
 atype^.h.manageproc(op,aref);
end;

procedure writemanagedvarop(const op: managedopty; const avar: pvardataty;
                                                 const acontextindex: int32);
var
 ad1: addressrefty;
begin
 ad1.contextindex:= acontextindex;
 ad1.isclass:= false;
 ad1.kind:= ark_vardatanoaggregate;
 ad1.offset:= 0;
 ad1.vardata:= avar;
 writemanagedtypeop(op,ele.eledataabs(avar^.vf.typ),ad1);
end;

procedure writemanagedvarop(const op: managedopty;
                 const chain: elementoffsetty; const acontextindex: int32);
var
 ad1: addressrefty;
 ele1: elementoffsetty;
 po1: pvardataty;
begin
 if chain <> 0 then begin
  ad1.contextindex:= acontextindex;
  ad1.kind:= ark_vardatanoaggregate;
  ad1.offset:= 0;
  ele1:= chain;
  repeat
   po1:= ele.eledataabs(ele1);
   if (tf_needsmanage in po1^.vf.flags) or 
                 (op = mo_ini) and (tf_needsini in po1^.vf.flags) or 
                 (op = mo_fini) and (tf_needsfini in po1^.vf.flags) then begin
    ad1.vardata:= po1;
    ad1.isclass:= ptypedataty(ele.eledataabs(po1^.vf.typ))^.
                                                 h.kind in [dk_class]; 
                                                        //todo: dk_interface
    writemanagedtypeop(op,ele.eledataabs(po1^.vf.typ),ad1);
   end;
   ele1:= po1^.vf.next;
  until ele1 = 0;
 end;
end;

function writemanagedtempvarop(const op: managedopty;
                 const aitem: listadty; const acontextindex: int32): boolean;
                              //uses tempvarlist, false if none
var
 ad1: addressrefty;
 item1: listadty;
 p1: ptempvaritemty;
 p2: ptypedataty;
begin
 result:= false;
 if aitem <> 0 then begin
  ad1.contextindex:= acontextindex;
  ad1.kind:= ark_tempvar;
  ad1.isclass:= false;
  item1:= aitem;
  p1:= getlistitem(tempvarlist,item1);
  repeat
   if (af_tempvar in p1^.address.flags) and (p1^.typeele > 0) then begin
    p2:= ele.eledataabs(p1^.typeele);
    ad1.isclass:= p2^.h.kind in [dk_class];  //todo: dk_interface
    if (not ad1.isclass and (p1^.address.indirectlevel = 0) or 
       ad1.isclass and (p1^.address.indirectlevel = 1)) and
           ((tf_needsmanage in p2^.h.flags) or 
                  (op = mo_ini) and (tf_needsini in p2^.h.flags) or 
                  (op = mo_fini) and (tf_needsfini in p2^.h.flags)) then begin
     ad1.typ:= p2;
     ad1.tempaddress:= p1^.address.tempaddress;
     writemanagedtypeop(op,p2,ad1);
     result:= true;
    end;
   end;
   p1:= steplistitem(tempvarlist,item1);
  until p1 = nil;
 end;
end;

procedure writemanagedtempop(const op: managedopty;
                            const achain: listadty; //managettempitem
                                                    const acontextindex: int32);
var
 ad1: listadty;
 po2: pointer;
 po1: pmanagedtempitemty;
 ref1: addressrefty;
begin
 if achain <> 0 then begin
  ref1.contextindex:= acontextindex;
  ref1.isclass:= false;
  ref1.offset:= 0;
  ref1.kind:= ark_managedtemp;
  if co_llvm in info.o.compileoptions then begin
   ref1.address:= info.managedtemparrayid;
  end;

  ad1:= achain;
  po2:= managedtemplist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   if co_llvm in info.o.compileoptions then begin
    setimmint32(po1^.index*pointersize,ref1.offset);
   end
   else begin
    ref1.address:= {info.managedtempref+}po1^.index*pointersize;
   end;
   ref1.typ:= ele.eledataabs(po1^.typ);
   writemanagedtypeop(op,ref1.typ,ref1);
   ad1:= po1^.header.next;
  end;
 end;
end;

procedure writemanagedtypeop(const op: managedopty; const atype: ptypedataty;
                   const aaddress: addressvaluety; const acontextindex: int32);
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
