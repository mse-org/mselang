{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
unit valuehandler;
{$ifdef FPC}{$mode objfpc}{$goto on}{$h+}{$endif}
interface
uses
 globtypes,parserglob,handlerglob,msetypes;

type
 convertoptionty = (coo_type,coo_enum,{coo_boolean,}coo_character,coo_set,
                    coo_notrunk);
 convertoptionsty = set of convertoptionty;
 compatibilitycheckoptionty = (cco_novarconversion);
 compatibilitycheckoptionsty = set of compatibilitycheckoptionty;
 
function tryconvert(const acontext: pcontextitemty;
          const dest: ptypedataty; destindirectlevel: integer;
          const aoptions: convertoptionsty): boolean;
{
function tryconvert(const stackoffset: integer;
          const dest: ptypedataty; destindirectlevel: integer;
          const aoptions: convertoptionsty): boolean;
}
function tryconvert(const acontext: pcontextitemty;
                                               const dest: systypety;
                           const aoptions: convertoptionsty = []): boolean;
{
function tryconvert(const stackoffset: integer; const dest: systypety;
                           const aoptions: convertoptionsty = []): boolean;
}
function checkcompatibledatatype(const sourcecontext: pcontextitemty;
    const desttypedata: elementoffsetty; const destaddress: addressvaluety;
                                   const options: compatibilitycheckoptionsty;
            out conversioncost: int32; out destindirectlevel: int32): boolean;
function getbasevalue(const acontext: pcontextitemty;
                             const dest: databitsizety): boolean;
procedure handlevalueidentifier();
procedure handlefactcallentry();
//procedure handlefactcallentry1(); //nohandlevalueident call
procedure handlefactcall();
procedure handlevaluepathstart();
procedure handlevaluepath1a();
procedure handlevaluepath2a();
procedure handlevaluepath2();
procedure handlevalueinherited();

function getselfvar(out aele: elementoffsetty): boolean;
function listtoset(const acontext: pcontextitemty;
                               out lastitem: pcontextitemty): boolean;
function listtoopenarray(const acontext: pcontextitemty;
                          const aitemtype: ptypedataty; 
                                  out lastitem: pcontextitemty): boolean;
function listtoarrayofconst(const acontext: pcontextitemty;
                                  out lastitem: pcontextitemty): boolean;

implementation
uses
 errorhandler,elements,handlerutils,opcode,stackops,segmentutils,opglob,
 subhandler,unithandler,syssubhandler,classhandler,interfacehandler,
 controlhandler,identutils,msestrings,handler,managedtypes,elementcache,
 __mla__internaltypes,exceptionhandler,listutils,llvmlists,grammarglob,
 parser,compilerunit;

function listtoset(const acontext: pcontextitemty;
                               out lastitem: pcontextitemty): boolean;
var
 i1,i2: int32;
 po1,po2: ptypedataty;
 ca1,ca2: card32;
 op1: popinfoty;
 poe,poitem: pcontextitemty;
begin
{$ifdef mse_checkinternalerrror}
 if acontext^.d.kind <> ck_list then begin
  internalerror(ie_handler,'20160610A');
 end;
{$endif}
 result:= false;
 poe:= acontext + acontext^.d.list.contextcount; //??? ck_space?
 ele.checkcapacity(ek_type);
 if acontext^.d.list.itemcount = 0 then begin //empty set
  initdatacontext(acontext^.d,ck_const);
  with acontext^ do begin
   d.dat.datatyp:= emptyset;
   d.dat.constval.kind:= dk_set;
  end;
 end
 else begin
  po2:= nil;
  ca1:= 0;          //todo: arbitrary size, ranges
  poitem:= acontext+1;
  while poitem < poe do begin
   with poitem^ do begin
    if d.kind <> ck_space then begin
    {$ifdef mse_checkinternalerror}
     if not (d.kind in datacontexts) then begin
      internalerror(ie_handler,'20151007A');
     end;
    {$endif}
     po1:= ele.eledataabs(basetype(d.dat.datatyp.typedata));
     if po2 = nil then begin
      po2:= po1;
     end;
     if not (po1^.h.kind in ordinaldatakinds) or 
                                  (po1^.h.indirectlevel <> 0) then begin
      errormessage(err_ordinalexpexpected,[],getstackoffset(poitem));
      exit;
     end
     else begin
      if (po1 <> po2) then begin //todo: try to convert ordinals
       incompatibletypeserror(po2,po1,getstackoffset(poitem));
       exit;
      end;
     end;
     case d.kind of 
      ck_const: begin
       ca2:= 1 shl d.dat.constval.vcardinal;
       if ca1 and ca2 <> 0 then begin
        errormessage(err_duplicatesetelement,[],getstackoffset(poitem));
        exit;
       end;
       ca1:= ca1 or ca2;
      end
      else begin
       if not getvalue(poitem,das_32) then begin
        exit;
       end;
      end;
     end; 
    end;
   end;
   inc(poitem);
  end;
  po1:= ele.addelementdata(getident(),ek_type,[]); //anonymous set type
  inittypedatasize(po1^,dk_set,0,das_32);
  with po1^ do begin
   infoset.itemtype:= ele.eledatarel(po2);
  end;
  if lf_allconst in acontext^.d.list.flags then begin
   initdatacontext(acontext^.d,ck_const);
   with acontext^ do begin
    d.dat.constval.kind:= dk_set;
    d.dat.constval.vset.value:= ca1;
   end;
  end
  else begin
   initdatacontext(acontext^.d,ck_fact); //wrong opmark?
   with insertitem(oc_pushimm32,getstackoffset(acontext)+1,0)^ do begin 
                                                               //first op
    setimmint32(ca1,par.imm);
    i2:= par.ssad;
   end;
   poitem:= acontext+1;
   while poitem < poe do begin
    if not (poitem^.d.kind in [ck_space,ck_const]) then begin
     op1:= insertitem(oc_setbit,getstackoffset(poitem),-1);
     with op1^ do begin //last op
      par.ssas1:= i2;
      par.ssas2:= (op1-1)^.par.ssad;
      i2:= par.ssad;
     end;
    end;
    inc(poitem);
   end;
   acontext^.d.dat.fact.ssaindex:= i2;
  end;
  with acontext^ do begin
   d.dat.datatyp.flags:= [];
   d.dat.datatyp.typedata:= ele.eledatarel(po1);
   d.dat.datatyp.indirectlevel:= 0;
  end;
 end;
 poitem:= acontext+1;
 while poitem < poe do begin
  poitem^.d.kind:= ck_space;
  inc(poitem);
 end;
 lastitem:= poitem-1;
 result:= true;
end;

function listtoopenarray(const acontext: pcontextitemty;
                          const aitemtype: ptypedataty; 
                                  out lastitem: pcontextitemty): boolean;
var
 poe: pointer;
 poitem1,poparams: pcontextitemty;
 po1,itemtype1: ptypedataty;
 indilev1,itemcount1: int32;
 podata1: pointer;
 isallconst: boolean;
 poalloc: plistitemallocinfoty;
 alloc1: dataoffsty;
 i1: int32;
begin
{$ifdef mse_checkinternalerror}
 if acontext^.d.kind <> ck_list then begin
  internalerror(ie_handler,'20160612B');
 end;
{$endif}
 result:= false;
 ele.checkcapacity(ek_type); //for anonymous type
 indilev1:= aitemtype^.h.indirectlevel;
 itemtype1:= ele.eledataabs(aitemtype^.infodynarray.i.itemtypedata);
 itemcount1:= acontext^.d.list.itemcount;
 isallconst:= lf_allconst in acontext^.d.list.flags;
 if not isallconst then begin
  if co_llvm in info.o.compileoptions then begin
   alloc1:= allocsegmentoffset(seg_localloc,
                         itemcount1*sizeof(listitemallocinfoty),poalloc);
  end;
 end;

 poe:= acontext + acontext^.d.list.contextcount;
// ele.checkcapacity(ek_type);
 poitem1:= acontext+1;
 while poitem1 < poe do begin
  with poitem1^ do begin
   if d.kind <> ck_space then begin
   {$ifdef mse_checkinternalerror}
    if not (d.kind in datacontexts) then begin
     internalerror(ie_handler,'20151007A');
    end;
   {$endif}
    if not tryconvert(poitem1,itemtype1,indilev1,[]) then begin
     internalerror1(ie_handler,'20160612C');
    end;
    if not isallconst then begin
     getvalue(poitem1,das_none,false);
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_fact then begin
      internalerror(ie_handler,'20160615A');
     end;
    {$endif}
     if co_llvm in info.o.compileoptions then begin
      poalloc^.ssaoffs:= d.dat.fact.ssaindex;
      inc(poalloc);
     end;
    end;
   end;
  end;
  inc(poitem1);
 end;
 lastitem:= poitem1-1;
 po1:= ele.addelementdata(getident(),ek_type,[]); //anonymus type
 inittypedatasize(po1^,dk_openarray,0,das_none);
 with po1^ do begin
  infodynarray.i.itemtypedata:= ele.eledatarel(aitemtype);
 end;
 with acontext^ do begin
  if isallconst and not (tf_untyped in itemtype1^.h.flags) then begin
   initdatacontext(d,ck_const);
   podata1:= initopenarrayconst(d.dat.constval,itemcount1,
                                                itemtype1^.h.bytesize);
   poitem1:= acontext+1;
   case itemtype1^.h.datasize of //todo: endianess
    das_32: begin
     while poitem1 < poe do begin
      if poitem1^.d.kind <> ck_space then begin
       pv32ty(podata1)^:= pv32ty(@poitem1^.d.dat.constval.vdummy)^;
       inc(pv32ty(podata1));
       poitem1^.d.kind:= ck_space;
      end;
      inc(poitem1);
     end;
    end;
    das_pointer: begin
     while poitem1 < poe do begin
      if poitem1^.d.kind <> ck_space then begin
       pvpoty(podata1)^:= pvpoty(@poitem1^.d.dat.constval.vdummy)^;
       inc(pvpoty(podata1));
       poitem1^.d.kind:= ck_space;
      end;
      inc(poitem1);
     end;
    end;
    else begin
     notimplementederror('20160613A'); //todo
    end;
   end;
  end
  else begin
   if co_llvm in info.o.compileoptions then begin
    poe:= poalloc;
    poalloc:= poalloc-acontext^.d.list.itemcount;
    i1:= (plistitemallocinfoty(poe)-1)^.ssaoffs; //last item is base
    while poalloc < poe do begin
     poalloc^.ssaoffs:= poalloc^.ssaoffs-i1; //relative ssa
     inc(poalloc);
    end;
   end;
   initfactcontext(acontext);
   with insertitem(oc_listtoopenar,poitem1,0,
               itemcount1*getssa(ocssa_listtoopenaritem))^ do begin
                                       //at start of next context
    with info do begin
     if co_mlaruntime in o.compileoptions then begin
      poparams:= @contextstack[acontext^.parent];
     {$ifdef mse_checkinternalerror}
      if poparams^.d.kind <> ck_params then begin
       internalerror(ie_handler,'20160623B');
      end;
     {$endif}
     end;
    end;
    par.listinfo.alloccount:= itemcount1;
    setimmint32(itemtype1^.h.bytesize,par.listinfo.itemsize);
    if co_llvm in info.o.compileoptions then begin
     par.listinfo.allocs:= alloc1;
     setimmint32(itemcount1-1,par.listtoopenar.allochigh);
     par.listtoopenar.arraytype:= info.s.unitinfo^.
             llvmlists.typelist.addbytevalue(itemcount1*itemtype1^.h.bytesize);
     par.listtoopenar.itemtype:= getopdatatype(itemtype1,
                                              itemtype1^.h.indirectlevel);
    end
    else begin // co_mlaruntime
     par.listinfo.tempad:= gettempaddress(itemcount1*itemtype1^.h.bytesize{,
                         poparams^.d.params.tempsize}).tempaddress;
    end;
    d.dat.fact.ssaindex:= par.ssad;
   end;
  end;
  d.dat.datatyp.flags:= [];
  d.dat.datatyp.typedata:= ele.eledatarel(po1);
  d.dat.datatyp.indirectlevel:= 0;
 end;
 result:= true;
end;

function listtoarrayofconst(const acontext: pcontextitemty;
                                  out lastitem: pcontextitemty): boolean;
var
 poe: pointer;
 poitem1,poparams: pcontextitemty;
 typ1: ptypedataty;
 alloc1: dataoffsty;
 poalloc: parrayofconstitemallocinfoty;
 itemcount1: int32;
 i1: int32;
 
begin
{$ifdef mse_checkinternalerror}
 if acontext^.d.kind <> ck_list then begin
  internalerror(ie_handler,'20180516A');
 end;
{$endif}
 result:= false;
 if not (co_llvm in info.o.compileoptions) then begin
  notimplementederror('20180516C');
 end;
 itemcount1:= acontext^.d.list.itemcount;
 alloc1:= allocsegmentoffset(seg_localloc,
                     itemcount1*sizeof(arrayofconstitemallocinfoty),poalloc);
 poe:= acontext + acontext^.d.list.contextcount;
 poitem1:= acontext+1;
 while poitem1 < poe do begin
  with poitem1^ do begin
   if d.kind <> ck_space then begin
   {$ifdef mse_checkinternalerror}
    if not (d.kind in datacontexts) then begin
     internalerror(ie_handler,'20180516B');
    end;
   {$endif}
    if not getvalue(poitem1,das_none,false) then begin
     exit;
    end;
   {$ifdef mse_checkinternalerror}
    if d.kind <> ck_fact then begin
     internalerror(ie_handler,'20160615A');
    end;
   {$endif}
    if d.dat.datatyp.indirectlevel > 0 then begin
    end
    else begin
     typ1:= ele.eledataabs(d.dat.datatyp.typedata);
     case typ1^.h.kind of
      dk_integer: begin
       poalloc^.valuefunc:= cs_int32tovarrecty;
      end;
      else begin
       errormessage(err_wrongarrayitemtype,[typename(typ1^)],poitem1);
       exit;
      end;
     end;
     poalloc^.ssaoffs:= d.dat.fact.ssaindex;
    end;
    inc(poalloc);
   end;
  end;
  inc(poitem1);
 end;
 lastitem:= poitem1-1;
 poe:= poalloc;
 poalloc:= poalloc-acontext^.d.list.itemcount;
 i1:= (parrayofconstitemallocinfoty(poe)-1)^.ssaoffs; //last item is base
 while poalloc < poe do begin
  poalloc^.ssaoffs:= poalloc^.ssaoffs-i1; //relative ssa
  inc(poalloc);
 end;

 initfactcontext(acontext);
 with acontext^,insertitem(oc_listtoarrayofconst,poitem1,0,
             itemcount1*getssa(ocssa_listtoarrayofconstitem))^ do begin
                                     //at start of next context
  if target64 then begin
   i1:= sizeof(varrecty64);
  end
  else begin
   i1:= sizeof(varrecty32);
  end;
  par.listtoarrayofconst.arraytype:= info.s.unitinfo^.
             llvmlists.typelist.addbytevalue(itemcount1*i1);
  par.listinfo.alloccount:= itemcount1;
  par.listinfo.allocs:= alloc1;
  par.listinfo.itemsize:= info.s.unitinfo^.llvmlists.constlist.varrectysize;
  setimmint32(itemcount1-1,par.listtoarrayofconst.allochigh);
  d.dat.fact.ssaindex:= par.ssad;
  d.dat.datatyp.flags:= [];
  d.dat.datatyp.typedata:= internaltypes[it_varrecty];
  d.dat.datatyp.indirectlevel:= 0;
 end;
 result:= true;
end;

type
 convertsizetablety = array[intbitsizety,databitsizety] of opcodety;
 convertnumtablety = array[boolean,databitsizety] of opcodety;
                           //true -> signed

const 
 cardtocard: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_card8tocard16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_card8tocard32,oc_none,  oc_card8tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_card16tocard8,oc_none, oc_none,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card16tocard32,oc_none,  oc_card16tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card32tocard8,oc_none, oc_card32tocard16,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_card32tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card64tocard8,oc_none, oc_card64tocard16,oc_none,
  //das_32,          das_33_63, das_64,             
    oc_card64tocard32,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  )
 );

 inttoint: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16,        das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_int8toint16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int8toint32,oc_none,  oc_int8toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_int16toint8,oc_none, oc_none,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int16toint32,oc_none,  oc_int16toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int32toint8,oc_none, oc_int32toint16,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_int32toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_mta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int64toint8,oc_none, oc_int64toint16,oc_none,
  //das_32,          das_33_63, das_64,             
    oc_int64toint32,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  )
 );

 cardtoint: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_card8toint8,oc_none, oc_card8toint16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_card8toint32,oc_none,  oc_card8toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card16toint8,oc_none, oc_card16toint16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card16toint32,oc_none,  oc_card16toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card32toint8,oc_none, oc_card32toint16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card32toint32,oc_none,  oc_card32toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card64toint8,oc_none, oc_card64toint16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card64toint32,oc_none,  oc_card64toint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  )
 );

 inttocard: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int8tocard8,oc_none, oc_int8tocard16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int8tocard32,oc_none,  oc_int8tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_int16tocard8,oc_none, oc_int16tocard16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int16tocard32,oc_none,  oc_int16tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_int32tocard8,oc_none, oc_int32tocard16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int32tocard32,oc_none,  oc_int32tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_int64tocard8,oc_none, oc_int64tocard16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int64tocard32,oc_none,  oc_int64tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  )
 );

 convtoflo32: convertnumtablety = (
  (//unsigned
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card8toflo32,oc_none, oc_card16toflo32,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card32toflo32,oc_none,  oc_card64toflo32,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//signed
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int8toflo32,oc_none, oc_int16toflo32,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int32toflo32,oc_none,  oc_int64toflo32,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  )
 );

 convtoflo64: convertnumtablety = (
  (//unsigned
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card8toflo64,oc_none, oc_card16toflo64,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card32toflo64,oc_none,  oc_card64toflo64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  ),
  (//signed
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int8toflo64,oc_none, oc_int16toflo64,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int32toflo64,oc_none,  oc_int64toflo64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
  )
 );

 potointops: array[databitsizety] of opcodety = (
  //das_none,das_1,  das_2_7,das_8,      das_9_15,das_16,      das_17_31,
    oc_none, oc_none,oc_none,oc_potoint8,oc_none, oc_potoint16,oc_none,
  //das_32,      das_33_63,das_64,             
    oc_potoint32,oc_none,  oc_potoint64,
  //das_pointer,das_f16,das_f32,das_f64, das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,oc_none
 );
  
function checkcompatiblesub(const a,b: ptypedataty): boolean;
var
 sa,sb: psubdataty;
 poa,poe,pob: pelementoffsetty;
 va,vb: pvardataty;
 po1: pointer;
begin
{$ifdef mse_checkinternalerror}
 if (a^.h.kind <> dk_sub) or (b^.h.kind <> dk_sub) then begin
  internalerror(ie_handler,'20160729B');
 end;
{$endif}
 result:= a = b;
 if not result then begin
  po1:= ele.eledatabase;
  sa:= po1 + a^.infosub.sub;
  sb:= po1 + b^.infosub.sub;
  result:= sa = sb;
  if not result then begin
   result:= (sa^.paramcount = sb^.paramcount) and 
                        ((sa^.flags >< sb^.flags) * compatiblesubflags = []);
   if result then begin
    poa:= @sa^.paramsrel;
    poe:= poa + sa^.paramcount;
    pob:= @sb^.paramsrel;
    while poa < poe do begin
     va:= po1 + poa^;
     vb:= po1 + pob^;
     if ((va^.address.flags >< vb^.address.flags) * 
                                       compatibleparamflags <> []) or 
               (va^.address.indirectlevel <> vb^.address.indirectlevel) or
                                        (va^.vf.typ <> vb^.vf.typ) then begin
      result:= false;
      break;
     end;
     inc(poa);
     inc(pob);
    end;
   end;
  end;
 end;
end;

const                                  // 0  1  2  3  4
 stringsizeindex: array[0..4] of card8 = (0, 0, 1, 0, 2);
 stringconvops: array[card8(0)..card8(2),card8(0)..card8(2)] of opcodety = (
 //8              16              32      dest          source
  (oc_none,       oc_string8to16, oc_string8to32),      //8
  (oc_string16to8,oc_none,        oc_string16to32),     //16
  (oc_string32to8,oc_string32to16,oc_none)              //32
 );

function getconvstringop(const sourcesize,destsize: int32): opcodety;
begin
 result:= stringconvops[stringsizeindex[sourcesize],stringsizeindex[destsize]];
end;

function tryconvert(const acontext: pcontextitemty;
          const dest: ptypedataty; destindirectlevel: integer;
          const aoptions: convertoptionsty): boolean;
var                     //todo: optimize, use tables, complete
 source1,po1,po2: ptypedataty;
 stackoffset: int32;
 
 procedure convertsize(const atable: convertsizetablety);
 var
  op1: opcodety;
  i1: int32;
 begin
  if (coo_notrunk in aoptions) and (intbits[source1^.h.datasize] >
                                           intbits[dest^.h.datasize]) then begin
   result:= false;
  end
  else begin
   result:= true;
   if source1^.h.datasize <> dest^.h.datasize then begin
    op1:= atable[intbits[source1^.h.datasize]][dest^.h.datasize];
    if op1 = oc_none then begin
     result:= false;
    end
    else begin
     with info do begin
      i1:= acontext^.d.dat.fact.ssaindex;
     end;
     with insertitem(op1,stackoffset,-1)^ do begin
      par.ssas1:= i1;
     end;
    end;
   end;
  end;
 end; //convertsize

 function convert(const aop: opcodety): popinfoty;
 var
  i1: int32;
 begin
//  tryconvert.result:= true;
  with acontext^ do begin
   if (d.kind = ck_subres) and (faf_varsubres in d.dat.fact.flags) then begin
    getvalue(acontext,das_none);
   end;
   i1:= d.dat.fact.ssaindex;
  end;
  result:= insertitem(aop,stackoffset,-1);
  with result^ do begin
   par.ssas1:= i1;
  end;
 end; //convert

 function checkancestorclass(base,ancestor: ptypedataty): boolean;
 var
  p1,p2: ptypedataty;
 begin
  if base^.h.kind = dk_classof then begin
   base:= ele.eledataabs(base^.infoclassof.classtyp);
  end;
  ancestor:= ancestor;
  if ancestor^.h.kind = dk_classof then begin
   ancestor:= ele.eledataabs(ancestor^.infoclassof.classtyp);
  end;
  p1:= basetype1(ancestor);
  p2:= basetype1(base);
  result:= true;
  while true do begin
   if p2 = p1 then begin
    break;
   end;
   if p1^.h.ancestor = 0 then begin
    result:= false;
    break;
   end;
   p1:= ele.eledataabs(p1^.h.ancestor);
  end;
  if not result then begin
   p1:= base;
   if p1^.h.kind = dk_classof then begin
    p1:= ele.eledataabs(p1^.infoclassof.classtyp);
   end;
   p2:= ancestor;
   if p2^.h.kind = dk_classof then begin
    p2:= ele.eledataabs(p2^.infoclassof.classtyp);
   end;
   errormessage(err_doesnotinheritfromclass,[
              getidentname(datatoele(ancestor)^.header.name),
              getidentname(datatoele(base)^.header.name)],acontext);
  end;
 end;
  
var
 pointerconv: boolean;
 needsmanagedtemp: boolean;
 i1,i2,i3,i4: integer;
 lstr1: lstringty;
 p1,p2: pcard8;
 b1: boolean;
 op1: opcodety;
 operatorsig: identvecty;
 oper1: poperatordataty;
 sub1: psubdataty;
 ad1: addressrefty;
 var1: pvardataty;
 lastitem: pcontextitemty;
begin
 result:= false;
 with info do begin
//  if not checkreftypeconversion(acontext) then begin
//   exit;
//  end;
  stackoffset:= getstackoffset(acontext);
  needsmanagedtemp:= false;
  if acontext^.d.kind = ck_list then begin
   case dest^.h.kind of
    dk_set: begin
     listtoset(acontext,lastitem);
    end;
    else begin
     exit;
    end;
   end;
  end;
 {$ifdef mse_checkinternalerror}
  if not (acontext^.d.kind in datacontexts) then begin
   internalerror(ie_handler,'20170530A');
  end;
 {$endif}
  with acontext^ do begin
   if (acontext^.d.kind = ck_const) and 
       ((destindirectlevel > 0) or (dest^.h.kind in nilpointerdatakinds)) and 
          (acontext^.d.dat.constval.kind = dk_none) then begin 
                  //nil -> nilpointer
    d.dat.constval.kind:= dk_pointer;
    d.dat.constval.vaddress:= niladdress;
    d.dat.datatyp:= sysdatatypes[st_pointer];
    inc(d.dat.datatyp.indirectlevel,d.dat.indirection);
   end;
   pointerconv:= false;
   source1:= ele.eledataabs(d.dat.datatyp.typedata);
   if (tf_untyped in source1^.h.flags) or 
                                (tf_untyped in dest^.h.flags) then begin
    result:= true; //untyped param
    exit;
   end;

   if (source1^.h.kind = dk_objectpo) and 
          (source1^.h.indirectlevel = 0) and (destindirectlevel = 0) then begin
    dec(d.dat.indirection);
    d.dat.datatyp.indirectlevel:= 0;
    d.dat.datatyp.typedata:= source1^.h.base;
    source1:= ele.eledataabs(d.dat.datatyp.typedata);
   end;

   if (dest^.h.kind = dk_object) and (destindirectlevel = 0) then begin
                     //check "()" operator, convert to object
    operatorsig.d[0]:= tks_operators;
    operatorsig.d[1]:= objectoperatoridents[oa_convert];
    setoperparamid(@operatorsig.d[2],0,nil); //no return value
    setoperparamid(@operatorsig.d[4],d.dat.datatyp.indirectlevel,source1);
    operatorsig.high:= 5;
    if ele.findchilddata(basetype(dest),
                          operatorsig,[ek_operator],allvisi,oper1) then begin
     result:= getvalue(acontext,das_none);
     if result then begin
      sub1:= ele.eledataabs(oper1^.methodele);
     {$ifdef mse_checkinternalerror}
      if sub1^.paramcount <> 2 then begin
       internalerror(ie_handler,'20170530B');
      end;
     {$endif}
      if co_mlaruntime in info.o.compileoptions then begin
       i1:= alignsize(dest^.h.bytesize);
       with insertitem(oc_push,acontext,-1)^ do begin //todo: managed temp
        par.imm.vsize:= i1;
       end;
       if tf_needsini in dest^.h.flags then begin
        ad1.contextindex:= getstackindex(acontext);
        ad1.isclass:= false;
        ad1.offset:= 0;
        ad1.kind:= ark_stackref;
        ad1.address:= -i1;
        ad1.typ:= dest;
        writemanagedtypeop(mo_ini,dest,ad1);
       end; 
       with insertitem(oc_pushstackaddr,acontext,-1)^.par do begin
        memop.tempdataaddress.a.address:= -i1;
        memop.tempdataaddress.offset:= 0;
       end;

       if acontext^.d.dat.datatyp.indirectlevel > 0 then begin
        i4:= targetpointersize;
       end
       else begin
        i4:= alignsize(source1^.h.bytesize);
       end;
       var1:= ele.eledataabs(pelementoffsetty(@sub1^.paramsrel)[1]);
                            //value param
       
       if af_paramindirect in var1^.address.flags then begin
        with insertitem(oc_pushstackaddr,acontext,-1)^.par.memop do begin
         tempdataaddress.a.address:= 
                     -(i4 + alignsize(dest^.h.bytesize)+targetpointersize);
         tempdataaddress.offset:= 0;
        end;
       end
       else begin
        with insertitem(oc_pushstack,acontext,-1)^.par.memop do begin
         t.size:= source1^.h.bytesize;
         tempdataaddress.a.address:= 
                     -(i4 + i1 + targetpointersize);
         tempdataaddress.offset:= 0;
        end;
       end;
       callsub(getstackindex(acontext),sub1,getstackindex(acontext),1,
                   [dsf_instanceonstack,dsf_noinstancecopy,dsf_noparams,
                                                       dsf_nooverloadcheck]);
       with additem(oc_push)^ do begin
        par.imm.vsize:= targetpointersize; //compensate missing instance copy
       end;
       with additem(oc_movestack)^.par.swapstack do begin
        size:= i1;
        offset:= -i4;
       end;
       with additem(oc_pop)^ do begin
        par.imm.vsize:= i4;
       end;
      end
      else begin //llvm
       i1:= acontext^.d.dat.fact.ssaindex; //source
       with insertitem(oc_tempalloc,acontext,-1)^ do begin //todo: managed temp
        par.tempalloc.typid:= 
               s.unitinfo^.llvmlists.typelist.addbytevalue(dest^.h.bytesize);
        i2:= par.ssad;
       end;
       with insertitem(oc_pushallocaddr,acontext,-1)^ do begin
        par.ssas1:= i2;
        i3:= par.ssad;
        acontext^.d.dat.fact.instancessa:= i3;
       end;
       if tf_needsini in dest^.h.flags then begin
        ad1.contextindex:= getstackindex(acontext);
        ad1.isclass:= false;
        ad1.kind:= ark_stack;
        ad1.ssaindex:= i3;
        ad1.typ:= dest;
        writemanagedtypeop(mo_ini,dest,ad1);
       end; 
       {
       inc(s.stacktop); //for instancepointer
       initfactcontext(s.stacktop-s.stackindex);
       contextstack[s.stacktop].d.dat.datatyp:= sysdatatypes[st_pointer];
       }
       acontext^.d.dat.fact.ssaindex:= i1; //source
       i1:= getstackindex(acontext);
       callsub(i1,sub1,i1,1,
              [dsf_instanceonstack,dsf_usedestinstance,dsf_nooverloadcheck]);
//       dec(s.stacktop);
       with insertitem(oc_loadalloca,acontext,-1)^ do begin //todo: managed temp
        par.ssas1:= i2;
        acontext^.d.dat.fact.ssaindex:= par.ssad; //result object
       end;
      end;
      acontext^.d.kind:= ck_fact;
      acontext^.d.dat.datatyp.typedata:= ele.eledatarel(dest);
      acontext^.d.dat.datatyp.indirectlevel:= 0;
      acontext^.d.dat.datatyp.flags:= dest^.h.flags;
     end;
     exit;
    end;
   end;
   if (source1^.h.kind = dk_object) and (d.dat.datatyp.indirectlevel = 0) or
      (source1^.h.kind = dk_objectpo) and 
                                   (d.dat.datatyp.indirectlevel = 1) then begin
                    // check "()" operator, convert from object
    operatorsig.d[0]:= tks_operators;
    operatorsig.d[1]:= objectoperatoridents[oa_convert];
    setoperparamid(@operatorsig.d[2],destindirectlevel,dest); //return value
    operatorsig.high:= 3;
    if ele.findchilddata(basetype(source1),
                          operatorsig,[ek_operator],allvisi,oper1) then begin
     if result then begin
      sub1:= ele.eledataabs(oper1^.methodele);
     {$ifdef mse_checkinternalerror}
      if sub1^.paramcount <> 2 then begin
       internalerror(ie_handler,'20170601A');
      end;
     {$endif}
     end;
     i1:= 0;
     if d.dat.datatyp.indirectlevel = 0 then begin
      if d.kind in factcontexts then begin
       if d.dat.indirection < 0 then begin
        result:= getaddress(acontext,true);
       end
       else begin
        result:= getvalue(acontext,das_none); //pending idirection
        i1:= alignsize(source1^.h.bytesize);  //object size
        i2:= acontext^.d.dat.fact.ssaindex;
        with insertitem(oc_pushstackaddr,acontext,-1)^.par do begin
         ssas1:= i2;
         memop.t:= getopdatatype(source1,d.dat.datatyp.indirectlevel);
         memop.tempdataaddress.a.address:= -i1;
         memop.tempdataaddress.offset:= 0;
        end;
       end;
      end
      else begin
       result:= getaddress(acontext,true);
      end;
     end
     else begin
      result:= getvalue(acontext,das_none);
     end;
     sub1:= ele.eledataabs(oper1^.methodele);
    {$ifdef mse_checkinternalerror}
     if sub1^.paramcount <> 2 then begin
      internalerror(ie_handler,'20170601A');
     end;
    {$endif}
     i2:= getstackindex(acontext);
     callsub(i2,sub1,i2,0,[dsf_instanceonstack,dsf_nooverloadcheck],0,i1);
     //todo: fini object
     if co_mlaruntime in info.o.compileoptions then begin
      if i1 > 0 then begin
       with insertitem(oc_pop,acontext,-1)^ do begin
        par.imm.vsize:= i1;
       end;
      end;
     {
      with insertitem(oc_movestack,acontext,-1)^.par.swapstack do begin
       if destindirectlevel > 0 then begin
        size:= pointersize;
       end
       else begin
        size:= dest^.h.bytesize;
       end;
       offset:= -(i1+pointersize);
      end;
      }
     end
     else begin //llvm
     end;
     exit;
    end;
   end;
   result:= destindirectlevel = d.dat.datatyp.indirectlevel;
   if result then begin
    result:= (dest^.h.kind = source1^.h.kind) and 
                           (dest^.h.datasize = source1^.h.datasize);
    if result then begin
     if dest^.h.kind = dk_string then begin
      result:= dest^.itemsize = source1^.itemsize;
     end
     else begin
      case dest^.h.kind of
       dk_enum: begin
        result:= issametype(dest,source1);
       end;
       dk_set: begin
        result:= dest^.infoset.itemtype = source1^.infoset.itemtype;
       end;
       dk_sub: begin
        result:= checkcompatiblesub(source1,dest);
       end;
       dk_record: begin
        result:= issamebasetype(dest,source1);
       end;
       dk_object,dk_class,dk_interface: begin
        result:= false;
        po1:= basetype1(source1);
        po2:= basetype1(dest);
        while true do begin
         if po1 = po2 then begin
          if (destindirectlevel > 0) or 
                 not (icf_virtual in source1^.infoclass.flags) or
                            (source1^.infoclass.allocsize =
                                        po1^.infoclass.allocsize) then begin
           result:= true;
          end;
          break;
         end;
         if po1^.h.ancestor = 0 then begin
          break;
         end;
         po1:= ele.eledataabs(po1^.h.ancestor);
        end;
       end;
       dk_classof: begin
        if not checkancestorclass(dest,source1) then begin
         result:= false;
         exit;
        end;
       end;
      end;
      if not result then begin
       exit; //no conversion possible
      end;
     end;
    end;
    if not result then begin
     if (dest^.h.kind = dk_classof) and 
           (source1^.h.kind = dk_class) and (destindirectlevel = 1) and 
                  (tf_classdef in acontext^.d.dat.datatyp.flags) then begin
      if not checkancestorclass(dest,source1) then begin
       exit;
      end;
      result:= true;
     end
     else begin
      if destindirectlevel = 0 then begin
       case d.kind of
        ck_const: begin
         with d.dat.constval do begin
          if kind = dk_none then begin //nil
           case dest^.h.kind of
            dk_method: begin
             kind:= dest^.h.kind;
             vaddress:= niladdress;
             result:= true;
            end;
           end;
          end
          else begin
           case dest^.h.kind of //todo: use table
            dk_float: begin
             case source1^.h.kind of
              dk_float: begin
               result:= true;
              end;
              dk_integer: begin
               case intbits[source1^.h.datasize] of
                ibs_8: begin
                 vfloat:= int8(vinteger);
                end;
                ibs_16: begin
                 vfloat:= int16(vinteger);
                end;
                ibs_32: begin
                 vfloat:= int32(vinteger);
                end;
                ibs_64: begin
                 vfloat:= int64(vinteger);
                end;
                else begin
                 internalerror1(ie_handler,'20160519B');
                end;
               end;
               result:= true;
              end;
              dk_cardinal: begin
               case intbits[source1^.h.datasize] of
                ibs_8: begin
                 vfloat:= card8(vcardinal);
                end;
                ibs_16: begin
                 vfloat:= card16(vcardinal);
                end;
                ibs_32: begin
                 vfloat:= card32(vcardinal);
                end;
                ibs_64: begin
                 vfloat:= card64(vcardinal);
                end;
                else begin
                 internalerror1(ie_handler,'20160519C');
                end;
               end;
               result:= true;
              end;
             end;
            end;
            dk_cardinal: begin
             case source1^.h.kind of
              dk_cardinal: begin
               result:= true;
              end;
              dk_integer: begin
               result:= true;
              end;
              dk_enum: begin
               if coo_enum in aoptions then begin
                result:= true;
               end;
               vcardinal:= venum.value;
              end;
              {
              dk_boolean: begin
               if coo_boolean in aoptions then begin
                result:= true;
               end;
               vboolean:= venum.value <> 0;
              end;
              }
              dk_character: begin
               if coo_character in aoptions then begin
                result:= true;
               end;
               vcardinal:= vcharacter;
              end;
              dk_set: begin //todo: arbitrary size
               if coo_set in aoptions then begin
                result:= true;
               end;
               vcardinal:= vset.value;
              end;
             end;
            end;
            dk_integer: begin
             case source1^.h.kind of
              dk_integer: begin
               result:= true;
              end;
              dk_cardinal: begin
               result:= true;
              end;
              dk_enum: begin
               if coo_enum in aoptions then begin
                result:= true;
               end;
               vinteger:= venum.value;
              end;
              {
              dk_boolean: begin
               if coo_boolean in aoptions then begin
                result:= true;
               end;
               if vboolean then begin
                vinteger:= 1;
               end
               else begin
                vinteger:= 0;
               end;
              end;
              }
              dk_character: begin
               if coo_character in aoptions then begin
                result:= true;
               end;
               vinteger:= vcharacter;
              end;
              dk_set: begin //todo: arbitrary size
               if coo_set in aoptions then begin
                result:= true;
               end;
               vinteger:= vset.value;
              end;
             end;
            end;
            dk_set: begin
             case source1^.h.kind of
              dk_set: begin
               if vset.value = 0 then begin //empty set
                result:= true; 
               end;
              end;
             end;
            end;
            dk_character: begin
             case source1^.h.kind of
              dk_string: begin 
               lstr1:= getstringconst(vstring);
               if lstr1.len > 0 then begin
                p1:= pointer(lstr1.po);
                p2:= p1 + lstr1.len;
                if getcodepoint(p1,p2,vcharacter) and (p1 = p2) then begin
                 result:= true;
                end;
               end;
              end;
             end;
            end;
            dk_string: begin
             case dest^.itemsize of
              1: begin
               result:= true;
              end;
              2: begin
               include(vstring.flags,strf_16);
               result:= true;
              end;
              4: begin
               include(vstring.flags,strf_32);
               result:= true;
              end;
              else begin
              {$ifdef mse_checkinternalerrror}
               internalerror(ie_handler,'20170326A');
              {$endif}
              end;
             end;
            end;
           end;
          end;
          if result then begin
           d.dat.datatyp.typedata:= ele.eledatarel(dest);
          end;
         end;
        end;
        ck_ref: begin
         case dest^.h.kind of
          dk_openarray: begin
           case source1^.h.kind of
            dk_dynarray: begin
             if issametype(source1^.infodynarray.i.itemtypedata,
                                dest^.infodynarray.i.itemtypedata) then begin
              if getvalue(acontext,das_pointer,false) then begin
               with convert(oc_dynarraytoopenar)^ do begin
               end;
               result:= true;
              end;
             end;
            end;
            dk_array: begin
             if issametype(source1^.infoarray.i.itemtypedata,
                                dest^.infodynarray.i.itemtypedata) then begin
              if getaddress(acontext,true) then begin
               with convert(oc_arraytoopenar)^ do begin
                setimmint32(source1^.infoarray.i.totitemcount-1,par.imm);
               end;
               result:= true;
              end;
             end;
            end;
           end;
          end;
          else begin
           if (destindirectlevel = 0) and
                 not (dest^.h.kind in structdatakinds) and
                 not (source1^.h.kind in structdatakinds) then begin
                            //otherwise probably address calculation
            if getvalue(acontext,das_none,false) then begin
             result:= tryconvert(acontext,dest,destindirectlevel,aoptions);
            end;
           end;
          end;
         end;
        end;
        ck_fact,ck_subres: begin
         case dest^.h.kind of //todo: use table
          dk_float: begin
           case source1^.h.kind of
            dk_integer,dk_cardinal: begin //todo: data size
             i1:= d.dat.fact.ssaindex;
             if dest^.h.datasize = das_f32 then begin
              op1:= convtoflo32[source1^.h.kind = dk_integer,
                                source1^.h.datasize];
             end
             else begin
              op1:= convtoflo64[source1^.h.kind = dk_integer,
                                source1^.h.datasize];
             end;
             with insertitem(op1,stackoffset,-1)^ do begin
              par.ssas1:= i1;
             end;
             result:= true;
            end;
            dk_float: begin
             if source1^.h.datasize = das_f32 then begin
              op1:= oc_flo32toflo64;
             end
             else begin
              op1:= oc_flo64toflo32;
             end;
             i1:= d.dat.fact.ssaindex;
             with insertitem(op1,stackoffset,-1)^ do begin
              par.ssas1:= i1;
             end;
             result:= true;
            end;
           end;
          end;
          dk_cardinal: begin
           case source1^.h.kind of
            dk_integer: begin
             convertsize(inttocard);
            end;
            dk_cardinal: begin
             convertsize(cardtocard);
            end;
            dk_enum: begin
             if coo_enum in aoptions then begin
              convertsize(inttocard);
             end;
            end;
            {
            dk_boolean: begin
             if coo_boolean in aoptions then begin
              convertsize(inttocard);
             end;
            end;
            }
            dk_character: begin
             if coo_character in aoptions then begin
              convertsize(cardtocard);
             end;
            end;
           end;
          end;
          dk_integer: begin
           case source1^.h.kind of
            dk_cardinal: begin
             convertsize(cardtoint);
            end;
            dk_integer: begin
             convertsize(inttoint);
            end;
            dk_enum: begin
             if coo_enum in aoptions then begin
              convertsize(inttoint);
             end;
            end;
            {
            dk_boolean: begin
             if coo_boolean in aoptions then begin
              convertsize(inttoint);
             end;
            end;
            }
            dk_character: begin
             if coo_character in aoptions then begin
              convertsize(cardtoint);
             end;
            end;
           end;
          end;
          dk_set: begin
           if (source1^.h.kind = dk_set) and 
                (d.dat.datatyp.typedata = emptyset.typedata) then begin
            result:= true;
           end;
          end;
          dk_string: begin
           case source1^.h.kind of
            dk_character: begin
             convert(oc_chartostring8); //todo: sizes !!!!!!!!!!!!!!!!!!!
             result:= true;
            end;
            dk_string: begin
             convert(getconvstringop(source1^.itemsize,dest^.itemsize));
             result:= true;
            end;
           end;
           needsmanagedtemp:= true;
          end;
         end;
        end;
       {$ifdef mse_checkinternalerror}
        else begin
         internalerror(ie_handler,'20131121B');
        end;
       {$endif}
       end;
      end
      else begin
       if (destindirectlevel > 0) and 
           ((((dest^.h.kind = dk_pointer) or 
                            (source1^.h.kind = dk_pointer))) or //untyped pointer
            (coo_type in aoptions) and (source1^.h.indirectlevel > 0)) then begin
        result:= true; 
        pointerconv:= true;
       end;
      end;
     end;
    end;
   end;
   if not result then begin
    if (coo_type in aoptions) and
      (dest^.h.kind = dk_integer) and (destindirectlevel = 0) and 
             ((d.dat.datatyp.indirectlevel > 0) or 
                               (source1^.h.kind in pointerdatakinds)) then begin
     if getvalue(acontext,das_pointer) then begin //pointer to int
      i1:= d.dat.fact.ssaindex;        //todo: operand size
      with insertitem(potointops[dest^.h.datasize],stackoffset,-1)^ do begin
       par.ssas1:= i1;
      end;
      d.dat.datatyp.typedata:= ele.eledatarel(dest);
      d.dat.datatyp.indirectlevel:= 0;
      result:= true;
     end;
    end
    else begin
     if (coo_type in aoptions) and 
           (destindirectlevel <> d.dat.datatyp.indirectlevel) and
             ((destindirectlevel > 0) and (source1^.h.indirectlevel = 0) and 
              (source1^.h.bitsize = targetpointerbitsize) or 
                     (source1^.h.kind in [dk_integer,dk_cardinal])) then begin
      if source1^.h.kind in [dk_string,dk_dynarray,dk_classof] then begin
       result:= getvalue(acontext,das_pointer);
       result:= true; //todo: pchar handling
      end
      else begin
       if getvalue(acontext,pointerintsize) then begin //any to pointer
        i1:= d.dat.fact.ssaindex; //todo: no int source
        with insertitem(oc_inttopo,stackoffset,-1)^ do begin
         par.ssas1:= i1;
        end;
        d.dat.datatyp.typedata:= ele.eledatarel(dest);
        d.dat.datatyp.indirectlevel:= destindirectlevel;
        result:= true;
       end;
      end;
     end;
    end;
   end;
   if not result then begin
    b1:= (source1^.h.kind = dk_class);
    if (d.kind in [ck_fact,ck_subres,ck_ref]) and 
       (destindirectlevel = 0) and (dest^.h.kind = dk_interface) and
       (b1 and (d.dat.datatyp.indirectlevel = 1) or
                     not b1 and (d.dat.datatyp.indirectlevel = 0)) then begin
     i1:= ele.elementparent;
     po1:= source1;
     repeat
      if getclassinterfaceoffset(po1,dest,i3) then begin
       if b1 and getvalue(acontext,das_pointer) or
             not b1 and getaddress(acontext,true) then begin
        i2:= d.dat.fact.ssaindex;
        with insertitem(oc_offsetpoimm,stackoffset,-1)^ do begin
         setimmint32(i3,par.imm);
         par.ssas1:= i2;
        end;
        result:= true;
        destindirectlevel:= 1;
       end;
       break;
      end;
      if po1^.infoclass.interfaceparent <> 0 then begin
       ele.elementparent:= po1^.infoclass.interfaceparent;
       po1:= ele.eledataabs(po1^.infoclass.interfaceparent);
      end
      else begin
       po1:= nil;
      end;
     until po1 = nil;
     ele.elementparent:= i1;
     if po1 = nil then begin
      exit;      //interface not found
     end;
    end
    else begin
     result:=          //todo: optimise
        ((dest^.h.kind in nilpointerdatakinds) and 
                                       (destindirectlevel = 0) or
                (dest^.h.kind = dk_pointer) and (destindirectlevel = 1)) and 
                                              (source1^.h.kind = dk_pointer) or
        ((dest^.h.kind = dk_pointer) and (destindirectlevel = 1) and 
          (source1^.h.kind = dk_sub) and (d.dat.datatyp.indirectlevel = 0)) or
        (source1^.h.kind = dk_pointer) and 
            (d.dat.datatyp.indirectlevel = 1) and (destindirectlevel > 0) or
                      //untyped pointer to any pointer
        (coo_type in aoptions) and (destindirectlevel > 0) and 
                                          (d.dat.datatyp.indirectlevel > 0);
                   //pointer type conversion
     result:= result and 
             ((dest^.h.kind <> dk_string) or (destindirectlevel <> 0) or
                             (d.kind <> ck_const) and (coo_type in aoptions));
     pointerconv:= result;
    end;
   end;
   if not result and (coo_type in aoptions) then begin
    result:= (destindirectlevel = 0) and (source1^.h.indirectlevel = 0) and
                              (dest^.h.bytesize = source1^.h.bytesize);
   end;
   if result then begin
    if not pointerconv and (d.kind = ck_const) then begin
     d.dat.constval.kind:= dest^.h.kind;
    end;    
    d.dat.datatyp.indirectlevel:= destindirectlevel;
    d.dat.datatyp.typedata:= ele.eledatarel(dest);
    if needsmanagedtemp then begin
     addmanagedtemp(acontext);
//     addmanagedtemp(s.stackindex+stackoffset);
    end;
   end;
  end;
 end;
end;
(*
function tryconvert(const stackoffset: integer;{var context: contextitemty;}
          const dest: ptypedataty; destindirectlevel: integer;
                       const aoptions: convertoptionsty): boolean;
begin
 with info do begin
  result:= tryconvert(@contextstack[s.stackindex+stackoffset],dest,
                                              destindirectlevel,aoptions); 
 end;
end;
*)
function tryconvert(const acontext: pcontextitemty;
                                               const dest: systypety;
                           const aoptions: convertoptionsty = []): boolean;
begin
 with sysdatatypes[dest] do begin
  result:= tryconvert(acontext,
                              ele.eledataabs(typedata),indirectlevel,aoptions);
 end;
end;
{
function tryconvert(const stackoffset: integer; const dest: systypety;
                           const aoptions: convertoptionsty = []): boolean;
begin
 with info do begin
  result:= tryconvert(@contextstack[s.stackindex+stackoffset],dest,aoptions);
 end;
end;
}
function getbasevalue(const acontext: pcontextitemty;
                         const dest: databitsizety): boolean;
var
 po1: ptypedataty;
 pocontext1: pcontextitemty;
begin
 po1:= getbasetypedata(dest);
 pocontext1:= acontext;
 if acontext^.d.kind = ck_const then begin
  result:= tryconvert(pocontext1,po1,po1^.h.indirectlevel,[]);
  if not result then begin
   illegalconversionerror(pocontext1^.d,po1,po1^.h.indirectlevel);
  end
  else begin
   result:= getvalue(pocontext1,dest);
  end;
 end
 else begin
  result:= getvalue(pocontext1,dest);
  if result then begin
   result:= tryconvert(pocontext1,po1,po1^.h.indirectlevel,[]);
   if not result then begin
    illegalconversionerror(pocontext1^.d,po1,po1^.h.indirectlevel);
   end;
  end; 
 end;
end;

function checkcompatibledatatype(const sourcecontext: pcontextitemty;
         const desttypedata: elementoffsetty; const destaddress: addressvaluety;
           const options: compatibilitycheckoptionsty;
             out conversioncost: int32; out destindirectlevel: int32): boolean;
const
 maxsizeconversioncost = ord(das_64)-ord(das_1);
var
 source,dest: ptypedataty;
 sourceitem,destitem: ptypedataty;
 sourceindilev{,destindilev}: int32;
 pocont1,poe: pcontextitemty;
 i1,i2: int32;
 addr1: addressvaluety;
 p1,p2: ptypedataty;
begin
 with info,sourcecontext^ do begin
 {$ifdef mse_checkinternalerror}
  if not (d.kind in (datacontexts + [ck_list,ck_typearg])) then begin
   internalerror(ie_parser,'141211A');
  end;
 {$endif}
  result:= false;
  conversioncost:= 0;
  dest:= ele.basetype(desttypedata);
  if (dest^.h.kind = dk_none) and 
              (not (hf_listitem in d.handlerflags) or 
                             (af_listitem in destaddress.flags)) then begin
  {$ifdef mse_checkinternalerror}
   if destaddress.flags*[af_param,af_listitem] = [] then begin
    internalerror(ie_parser,'20170420A');
   end;
  {$endif}
   result:= true; //untyped pointer
   exit;
  end;
  destindirectlevel:= destaddress.indirectlevel;
  if af_paramindirect in destaddress.flags then begin
   dec(destindirectlevel);
  end;
  if dest^.h.kind in [dk_sub,dk_method] then begin
   inc(destindirectlevel);
  end;
  if d.kind = ck_list then begin
   if destindirectlevel <> 0 then begin
    exit;
   end;
   pocont1:= sourcecontext+1;
   poe:= sourcecontext + sourcecontext^.d.list.contextcount;
   addr1.flags:= [af_listitem];
   i1:= conversioncost;
   case dest^.h.kind of
    dk_set: begin
     if sourcecontext^.d.list.itemcount = 0 then begin
      result:= true; //empty set
      exit;
     end;
     addr1.indirectlevel:= 0;
     while pocont1 < poe do begin
      if pocont1^.d.kind <> ck_space then begin
       if not checkcompatibledatatype(
                    pocont1,dest^.infoset.itemtype,addr1,[],i1,i2) then begin
        exit;
       end;
       if i1 > conversioncost then begin
        conversioncost:= i1;
       end;
      end;
      inc(pocont1);
     end;
     result:= true;
     exit;
    end;
    dk_openarray: begin
     destitem:= ele.eledataabs(dest^.infodynarray.i.itemtypedata);
     addr1.indirectlevel:= destitem^.h.indirectlevel;
     if not (af_untyped in destaddress.flags) or  //no array of const
                                    (addr1.indirectlevel <> 0) then begin
      while pocont1 < poe do begin
       if pocont1^.d.kind <> ck_space then begin
        if not checkcompatibledatatype(
          pocont1,dest^.infodynarray.i.itemtypedata,addr1,[],i1,i2) then begin
         exit;
        end;
        if i1 > conversioncost then begin
         conversioncost:= i1;
        end;
       end;
       inc(pocont1);
      end;
     end;
     inc(conversioncost); //at least 1
     result:= true;
     exit;
    end;
    else begin
     exit;
    end;
   end;
  end;
  if d.kind = ck_typearg then begin
   p1:= basetype1(ele.eledataabs(d.typ.typedata));
   if (dest^.h.kind <> dk_classof) or (p1^.h.kind <> dk_class) or 
            (destindirectlevel <> 1) or (d.typ.indirectlevel <> 1) then begin
    exit;
   end;
   p2:= basetype1(ele.eledataabs(dest^.infoclassof.classtyp));
   while true do begin
    if p1 = p2 then begin
     result:= true;
     break;
    end;
    if p1^.h.ancestor = 0 then begin
     break;
    end;
    p1:= ele.eledataabs(p1^.h.ancestor);
   end;
   exit;
  end;
  
//  if (d.kind = ck_ref) and (d.dat.ref.castchain <> 0) then begin
//   source:= ele.basetype(linkgetcasttype(d.dat.ref.castchain));
//   sourceindilev:= source^.h.indirectlevel;
//  end
//  else begin
  source:= ele.basetype(d.dat.datatyp.typedata);
  sourceindilev:= d.dat.datatyp.indirectlevel;
  if source^.h.kind = dk_class then begin
   dec(sourceindilev);
  end;
//  end;
  result:= destindirectlevel = sourceindilev;
  if result then begin
   result:= (source = dest);
   if not result then begin
    if (source^.h.kind in [dk_sub,dk_method]) and 
                        (dest^.h.kind in [dk_sub,dk_method]) then begin
     result:= checkparamsbase(ele.eledataabs(source^.infosub.sub),
                              ele.eledataabs(dest^.infosub.sub));
     if result then begin
      exit;
     end;
    end;
    if (cco_novarconversion in options) and 
             (destaddress.flags * [af_paramvar,af_paramout] <> []) then begin
     exit;
    end;
    inc(conversioncost);            //1
    if (d.kind = ck_const) and (d.dat.constval.kind = dk_none) then begin 
                        //nil const
     if dest^.h.kind in [dk_method]+nilpointerdatakinds then begin
      result:= true;
      exit;
     end;
    end;
    if (destindirectlevel = 0) and (dest^.h.kind = dk_openarray) and
               ((source^.h.kind = dk_dynarray) and 
                         issametype(source^.infodynarray.i.itemtypedata,
                          dest^.infodynarray.i.itemtypedata) or
                         (source^.h.kind = dk_array) and 
                         issametype(source^.infoarray.i.itemtypedata,
                          dest^.infodynarray.i.itemtypedata)) then begin
     result:= true;
     exit;
    end;
    result:= (source^.h.kind = dest^.h.kind) and 
             (source^.h.kind in [dk_cardinal,dk_integer,dk_float,
                                 dk_string,dk_character]);
                        //todo: stringsizes !!!!!!!!!!!!
    if result and (source^.h.datasize <> dest^.h.datasize) then begin
     inc(conversioncost);          //2
     if source^.h.datasize < dest^.h.datasize then begin
      inc(conversioncost,ord(dest^.h.datasize)-ord(source^.h.datasize));         //3
     end
     else begin
      inc(conversioncost,-(ord(dest^.h.datasize)-ord(source^.h.datasize))
                                                      + maxsizeconversioncost); 
     end;                                                         //3
    end;
    if not result then begin
     inc(conversioncost,2+maxsizeconversioncost+maxsizeconversioncost); //4
     result:= (source^.h.kind = dk_cardinal) and 
                                (dest^.h.kind = dk_integer) or
              (source^.h.kind = dk_integer) and 
                                (dest^.h.kind = dk_cardinal);
     if not result then begin
      inc(conversioncost);        //5
      result:= (source^.h.kind in [dk_cardinal,dk_integer]) and
            (dest^.h.kind = dk_float);
     end; //todo: finish
    end;
   end;
  end;
  if not result then begin  //untyped pointer conversion
   result:= (dest^.h.kind = dk_pointer) and (destindirectlevel = 1) and 
                                     (sourceindilev > 0) or 
    ((sourceindilev = 1 ) and (source^.h.kind = dk_pointer) or
        (sourcecontext^.d.kind = ck_const) and 
                 (sourcecontext^.d.dat.constval.kind = dk_none)) //nil
                                                   and (destindirectlevel > 0);
   if result then begin
    conversioncost:= 1;
   end;
  end;
 end;
end;

procedure handlevaluepathstart();
begin
 with info,contextstack[s.stacktop],d do begin
  ident.flags:= [];
 end;
end;

procedure setupvarrefcontext(const acontext: pcontextitemty;
                          const avar: pvardataty; const continued: boolean);
begin
 initdatacontext(acontext^.d,ck_ref);
 with info,acontext^ do begin
  d.dat.ref.c.address:= trackaccess(avar);
  d.dat.ref.offset:= 0;
  d.dat.ref.c.varele:= ele.eledatarel(avar); //used to store ssaindex
  d.dat.datatyp.typedata:= avar^.vf.typ;
  d.dat.datatyp.indirectlevel:= avar^.address.indirectlevel;
  d.dat.datatyp.flags:= [];
  if (af_self in d.dat.ref.c.address.flags) and 
                   (stf_classmethod in s.currentstatementflags) then begin
   include(d.dat.datatyp.flags,tf_classdef);
  end;
  if (d.dat.ref.c.address.flags *
                     [af_paramindirect,af_withindirect] <> []) or 
         (af_self in d.dat.ref.c.address.flags) and 
            (ptypedataty(ele.eledataabs(
                  d.dat.datatyp.typedata))^.h.kind = dk_objectpo) and
                                                          continued then begin
   d.dat.ref.c.address.flags:= d.dat.ref.c.address.flags-
                                  [af_paramindirect,af_withindirect];
   dec(d.dat.indirection);
   dec(d.dat.datatyp.indirectlevel);
  end;
 end;
end;

procedure handlevaluepath1a();
var
 sub1: psubdataty;
 var1: pvardataty;
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('VALUEPATH1A');
{$endif}
 with info,contextstack[s.stacktop],d do begin
  kind:= ck_ident;
  ident.len:= s.source.po-start.po;
  ident.ident:= getident(start.po,ident.len);
  exclude(ident.flags,idf_continued);
  if ident.len = 0 then begin
   if idf_inherited in ident.flags then begin
   {$ifdef mse_checkinternalerror}
    if currentzerolevelsub = 0 then begin
     internalerror(ie_handler,'20171102A');
    end;
   {$endif}
    ident.ident:= ele.eleinfoabs(currentzerolevelsub)^.header.name;
    pushdummycontext(ck_params);
    sub1:= ele.eledataabs(currentzerolevelsub);
    i1:= sub1^.paramcount-1; //skip self
    var1:= ele.eledataabs(sub1^.varchain);
    if sf_functionx in sub1^.flags then begin
     var1:= ele.eledataabs(var1^.vf.next); //result
     dec(i1);
    end;
//    var1:= ele.eledataabs(var1^.vf.next); //self
    while i1 > 0 do begin
    {$ifdef mse_checkinternalerror}
     if var1^.vf.next = 0 then begin
      internalerror(ie_handler,'20171104A');
     end;
    {$endif}
     var1:= ele.eledataabs(var1^.vf.next);
     pushdummycontext(ck_ref);
     setupvarrefcontext(@contextstack[s.stacktop],var1,false);
     dec(i1);
    end;
   end
   else begin
    errormessage(err_identexpected,[]);
   end;
  end;
 end;
end;

procedure handlevaluepath2a();
begin
{$ifdef mse_debugparser}
 outhandle('VALUEPATH2A');
{$endif}
 with info,contextstack[s.stacktop],d do begin
  include(ident.flags,idf_continued);
 end;
end;

procedure handlevaluepath2();
begin
{$ifdef mse_debugparser}
 outhandle('VALUEPATH2');
{$endif}
 errormessage(err_syntax,['identifier'],0);
end;

procedure handlevalueinherited();  //todo: anonymous inherited
begin                   
{$ifdef mse_debugparser}
 outhandle('VALUEINHRITED');
{$endif}
 with info,contextstack[s.stacktop],d do begin
  if (currentobject <> 0) and (sublevel > 0) then begin
   if idf_inherited in ident.flags then begin
    errormessage(err_identexpected,[]);
   end;
   include(ident.flags,idf_inherited);
  end;
 end;
end;

function getselfvar(out aele: elementoffsetty): boolean;
begin
 result:= ele.findcurrent(tks_self,[],allvisi,aele);
                       //todo: what about variables with name "self"?
end;

//todo: simplify
procedure handlevalueident();
var
 paramco,paramstart: integer;

 function checknoparam: boolean;
 begin
  result:= paramco = 0;
  if not result then begin
   with info,contextstack[s.stackindex].d do begin
    errormessage(err_syntax,[';'],1,ident.len);
   end;
  end;
 end;

var
 idents: identvecty;
 firstnotfound: integer;
 po1: pelementinfoty;
 po2: pointer;
 isinherited: boolean;
 isgetfact: boolean;
 subflags: dosubflagsty;
 poind,pob,potop: pcontextitemty;
  
 procedure donotfound(const adatacontext: pcontextitemty;
                           const atype: elementoffsetty);

  procedure pushclassdef(const atyp: ptypedataty);
  begin
  {$ifdef mse_checkinternalerror}
   if not (atyp^.h.kind in [dk_object,dk_class]) then begin
    internalerror(ie_handler,'20170510A');
   end;
  {$endif} 
   with insertitem(oc_pushclassdef,adatacontext,-1)^.par do begin
    if co_llvm in info.o.compileoptions then begin
     classdefid:= getclassdefid(atyp);
    end
    else begin
     classdefstackops:= atyp^.infoclass.defs.address;
    end;
   end;
   initfactcontext(adatacontext);
   adatacontext^.d.dat.fact.opdatatype:= bitoptypes[das_pointer];
   adatacontext^.d.dat.datatyp.typedata:= ele.eledatarel(atyp);
   adatacontext^.d.dat.datatyp.indirectlevel:= 1;
   include(subflags,dsf_instanceonstack);
  end;//pushclassdef()
  
 var
  offs1: dataoffsty;
  ele1,ele2: elementoffsetty;
  pvar1: pvardataty;
  int1: integer;
  po4: pointer;
  subflags1: subflagsty;
  typ1: ptypedataty;
  i2: int32;
  isclassof: boolean;

 begin //donotfond()
  if firstnotfound <= idents.high then begin
   ele1:= basetype(atype);
   offs1:= 0;
   with info do begin
    for int1:= firstnotfound to idents.high do begin //fields
     typ1:= ele.eledataabs(ele1);
     isclassof:= (typ1^.h.kind = dk_classof) and (typ1^.h.indirectlevel = 1);
     if isclassof then begin
      ele1:= basetype(typ1^.infoclassof.classtyp);
     end;
     ele2:= ele1; //parent backup
     case ele.findchild(ele1,idents.d[int1],[],allvisi,ele1,po4) of
      ek_none: begin
       identerror(1+int1,err_identifiernotfound);
       exit;
      end;
      ek_field: begin
       with adatacontext^,pfielddataty(po4)^ do begin
        ele1:= vf.typ;
        typ1:= ele.eledataabs(ele2);
        case d.kind of
         ck_ref: begin
          if (typ1^.h.kind = dk_class) then begin
           dec(d.dat.indirection);
           dec(d.dat.datatyp.indirectlevel);
          end; //todo: handle indirection with existing offset
          d.dat.ref.offset:= d.dat.ref.offset + offset;
         end;
         ck_fact: begin     //todo: check indirection
          offs1:= offs1 + offset;
         end;
        {$ifdef mse_checkinternalerror}
         else begin
          if typ1^.h.kind in [dk_object,dk_class] then begin
           errormessage(err_classreference,[]);
          end
          else begin
           errormessage(err_typeidentnotallowed,[]);
          end;
          exit;
         end;
        {$endif}
        end;
        d.dat.datatyp.typedata:= ele1; //todo: adress operator
        d.dat.datatyp.indirectlevel:= d.dat.datatyp.indirectlevel +
                       ptypedataty(ele.eledataabs(ele1))^.h.indirectlevel;
       end;
      end;
      ek_property: begin
       with adatacontext^,ppropertydataty(po4)^ do begin
        case d.kind of
         ck_ref: begin
          d.kind:= ck_prop;
          if pof_class in flags then begin
           dec(d.dat.indirection);
           dec(d.dat.datatyp.indirectlevel);
          end;
          d.dat.datatyp.typedata:= typ;
          d.dat.datatyp.indirectlevel:= d.dat.datatyp.indirectlevel +
                        ptypedataty(ele.eledataabs(typ))^.h.indirectlevel;
          d.dat.prop.propele:= ele.eledatarel(po4);
         end;
         else begin
          errormessage(err_illegalexpression,[],adatacontext); 
           //??? triggered by "objtyp.property:= value;"
         end;
         (*
        {$ifdef mse_checkinternalerror}
         else begin
          internalerror(ie_value,'20151207B');
         end;
        {$endif}
         *)
        end;
       end;       
      end;
      ek_sub: begin
       if int1 <> idents.high then begin
        errormessage(err_illegalqualifier,[],int1+1,0,erl_fatal);
        exit;
       end;
       subflags1:= psubdataty(po4)^.flags;
       case po1^.header.kind of
        ek_var: begin
         if isclassof then begin
          if subflags1 * [sf_classmethod,sf_constructor] = [] then begin
           errormessage(err_classmethodexpected,[]);
           exit;
          end;
          if not getvalue(adatacontext,das_none) then begin
           exit;
          end;
          include(subflags1,sf_class);
         end
         else begin
          pvar1:= eletodata(po1);
          typ1:= ele.eledataabs(pvar1^.vf.typ);
          if typ1^.h.kind = dk_class then begin
           include(subflags1,sf_class);
          end;
          if [sf_class,sf_interface] * subflags1 <> [] then begin
           if pvar1^.address.indirectlevel <> 1 then begin
            if sf_class in subflags1 then begin
             errormessage(err_classinstanceexpected,[]);
            end
            else begin
             errormessage(err_interfaceexpected,[]);
            end;
            exit;
           end;
           if sf_classmethod in subflags1 then begin
            if icf_virtual in typ1^.infoclass.flags then begin
             if not getvalue(adatacontext,das_none) then begin 
                                                //get class instance
              exit;
             end;
             offsetad(adatacontext,typ1^.infoclass.virttaboffset);
             i2:= adatacontext^.d.dat.fact.ssaindex;
             with insertitem(oc_indirectpo,adatacontext,-1)^ do begin
              par.ssas1:= i2;
             end;
            end
            else begin
             pushclassdef(typ1);
            end;
            subflags:= subflags + [dsf_instanceonstack,dsf_classdefonstack];
           end
           else begin
            if af_classele in pvar1^.address.flags then begin
             errormessage(err_onlyclassmethod,[],adatacontext);
             exit;
            end;
            if not getvalue(adatacontext,das_none) then begin 
                                               //get class instance
             exit;
            end;
           end;
          end
          else begin
           if subflags1 * [sf_destructor,sf_class] = 
                                            [sf_destructor,sf_class] then begin
            if pvar1^.address.indirectlevel <> 1 then begin
             errormessage(err_classinstanceexpected,[]);
            end;
            if not getvalue(adatacontext,das_none) then begin 
                                               //get object pointer
             exit;
            end;
           end
           else begin
            if (sf_destructor in subflags1) and 
                 (pvar1^.address.indirectlevel = 1) then begin //object pointer
             if not getvalue(adatacontext,das_none) then begin 
                                               //get object pointer
              exit;
             end;
            end
            else begin
             if pvar1^.address.indirectlevel <> 0 then begin
              errormessage(err_objectexpected,[]);
             end;
             if sf_classmethod in subflags1 then begin
              if icf_virtual in typ1^.infoclass.flags then begin
               if not getaddress(adatacontext,true) then begin
                exit;
               end;
               offsetad(adatacontext,typ1^.infoclass.virttaboffset);
               i2:= adatacontext^.d.dat.fact.ssaindex;
               with insertitem(oc_indirectpo,adatacontext,-1)^ do begin
                par.ssas1:= i2;
               end;
              end
              else begin
               pushclassdef(typ1);
              end;
              subflags:= subflags + [dsf_instanceonstack,dsf_classdefonstack];
             end
             else begin
              if not getaddress(adatacontext,true) then begin
                                                 //get object address
               exit;
              end;
             end;
             include(subflags,dsf_nofreemem);
            end;
           end;
          end;
          include(subflags,dsf_instanceonstack);
         end;
        end;
        ek_type: begin
         if info.s.currentstatementflags * 
                                 [stf_getaddress,stf_addressop] = [] then begin
          if (subflags1 * [sf_classmethod,sf_constructor] = []) then begin
           errormessage(err_classref,[],int1+1);
           exit;
          end;
         end
         else begin
          if not (sf_classmethod in subflags1) then begin
           errormessage(err_classmethodexpected,[]);
           exit;
          end;
         end;
         if {(info.s.currentstatementflags * 
                    [stf_getaddress,stf_addressop] = []) and }
               not (sf_constructor in psubdataty(po4)^.flags) then begin
          pushclassdef(eletodata(po1));
          include(subflags,dsf_classdefonstack);
         end;
        end;
        else begin
         internalerror1(ie_notimplemented,'20140417A');
        end;
       end;
       if isclassof then begin
        callsub(s.stackindex,psubdataty(po4),paramstart,paramco,
                    subflags+[dsf_instanceonstack,dsf_classdefonstack,
                 dsf_useinstancetype],0,0,ptypedataty(ele.eledataabs(ele2)));
       end
       else begin
        callsub(s.stackindex,psubdataty(po4),paramstart,paramco,subflags);
       end;
       exit;
      end;
      else begin
       identerror(1+int1,err_wrongtype,erl_fatal);
       exit;
      end;
     end;
    end;
    if offs1 <> 0 then begin
     offsetad(-1,offs1);
    end;
   end;
  end; 
 end;//donotfound()
 
 function checknoclassmethod(const aitem: pelementinfoty): boolean;
 var
  p1,p2: pelementinfoty;
 begin
  result:= true;
  if (aitem^.header.kind = ek_sub) and 
                (stf_classmethod in info.s.currentstatementflags) and 
                not (sf_classmethod in 
                     psubdataty(eletodata(aitem))^.flags) then begin
   p2:= ele.eleinfoabs(aitem^.header.parent);
   if p2^.header.kind = ek_classimpnode then begin //implementation found
    p2:= ele.eleinfoabs(p2^.header.parent);
   end;
   p1:= ele.eleinfoabs(info.currentobject);
   while true do begin
    if p1 = p2 then begin
     errormessage(err_onlyclassmethod,[]);
     result:= false;
     exit;
    end;
    if (p1^.header.parent = 0) then begin
     break; //not element of current class
    end;
    p1:= ele.eledataabs(p1^.header.parent);
    if p1^.header.kind <> ek_type then begin
     break; //not element of current class
    end;
   end;
  end;
 end;
  
var
 po3: ptypedataty;
 po4: pointer;
 po5: pelementoffsetty;
 po6: pvardataty;
 po7: pointer;
 ele1,ele2: elementoffsetty;
 int1,int2,int3: integer;
 si1: datasizety;
 stacksize1: datasizety;
 paramco1: integer;
 origparent: elementoffsetty;
 ssabefore: int32;
 pocontext1: pcontextitemty;
 i1,i2: int32;
 bo1: boolean;
 vis1,foundflags1: visikindsty;
 
label
 endlab;
begin
 with info do begin
  ele.pushelementparent();
  isgetfact:= false;
  foundflags1:= [];
  poind:= @contextstack[s.stackindex];
  pob:= poind-1;
  potop:= @contextstack[s.stacktop];
  with pob^ do begin
   case d.kind of
    ck_getfact: begin
     isgetfact:= true;
    end;
    ck_ref,ck_fact,ck_subres: begin
     po3:= ele.eledataabs(d.dat.datatyp.typedata);
     if po3^.h.kind = dk_class then begin
      dec(d.dat.datatyp.indirectlevel);
      dec(d.dat.indirection);
     end;
     if (d.dat.datatyp.indirectlevel <> 0) or 
                 not(po3^.h.kind in [dk_record,dk_object,dk_class]) then begin
      errormessage(err_illegalqualifier,[]);
      goto endlab;
     end
     else begin
      if po3^.h.base <> 0 then begin
       ele.elementparent:= po3^.h.base;
      end
      else begin
       ele.elementparent:= d.dat.datatyp.typedata;
      end;
     end;
    end;
    ck_error,ck_none: begin
     goto endlab;
    end;
    else begin
     internalerror1(ie_notimplemented,'20140406A');
    end;
   end;
  end;
 {$ifdef mse_checkinternalerror}
  if (s.stacktop <= s.stackindex) or 
           (contextstack[s.stackindex+1].d.kind <> ck_ident) then begin
   internalerror(ie_parser,'20150401A');
  end;
 {$endif}
  isinherited:= idf_inherited in contextstack[s.stackindex+1].d.ident.flags;
  if isinherited then begin
   if stf_objimp in s.currentstatementflags then begin
    origparent:= ele.elementparent;
    ele.decelementparent(); //ek_classimpnode
    ele.decelementparent(); //ek_class
    po1:= ele.parentelement;
   {$ifdef mse_checkinternalerror}
    if (po1^.header.kind <> ek_type) or 
       not (ptypedataty(@po1^.data)^.h.kind in [dk_class,dk_object]) then begin
     internalerror(ie_parser,'20150401B');
    end;
   {$endif}
    with ptypedataty(@po1^.data)^ do begin
     if h.ancestor = 0 then begin
      errormessage(err_noancestor,[]); //todo: source pos
      goto endlab;
     end
     else begin
      ele.elementparent:= h.ancestor;
     end;
    end;
   end
   else begin
    errormessage(err_identexpected,[]); //todo: source pos
    goto endlab;
   end;
  end;
  vis1:= allvisi+[vik_stoponstarttype];
  if stf_objimp in s.currentstatementflags then begin
   include(vis1,vik_implementation);
  end;
  bo1:= findkindelements(1,[],vis1,po1,firstnotfound,idents,foundflags1);
  paramstart:= s.stackindex+2+idents.high;
  paramco:= 0;
  pocontext1:= @contextstack[paramstart];
  if (pocontext1 < potop) and (pocontext1^.d.kind = ck_params) then begin
   inc(paramstart);
   while getnextnospace(pocontext1+1,pocontext1) do begin
    inc(paramco);
   end;
  end;
  if paramco < 0 then begin
   paramco:= 0; //no paramsend context
  end;
  
  if (stf_condition in s.currentstatementflags) then begin
   if (idents.high = 0) and (idents.d[0] = tk_defined) then begin
    if paramco = 1 then begin
     case potop^.d.kind of
      ck_const: begin
       setconstcontext(poind,valuetrue);
      end;
      ck_none: begin
       setconstcontext(poind,valuefalse);
      end;
      else begin
       errormessage(err_constexpressionexpected,[],s.stacktop-s.stackindex);
      end;
     end;
    end
    else begin
     errormessage(err_wrongnumberofparameters,['defined']);
    end;
    goto endlab;
   end;
   if not bo1 then begin
    poind^.d.kind:= ck_none;
    goto endlab;
   end;
  end;

  if bo1 then begin
   if isinherited then begin
    ele.elementparent:= origparent;
   end;
  end
  else begin //no condition
   if not isgetfact or not(stf_loop in s.currentstatementflags) or 
                                           not checkloopcommand() then begin
    identerror(idents.d[0],err_identifiernotfound);
   end;
   goto endlab;
  end;
  subflags:= [];
  if isinherited then begin
   include(subflags,dsf_isinherited);
  end;
  if (idents.high = 0) and 
            not ((pob^.d.kind in factcontexts) or (pob^.d.kind = ck_ref)) and 
                                  (po1^.header.kind <> ek_var) then begin
   include(subflags,dsf_ownedmethod);
  end;
  po2:= @po1^.data;
  if po1^.header.kind = ek_ref then begin
   po1:= ele.eleinfoabs(prefdataty(po2)^.ref);
   po2:= @po1^.data;
  end;
  with poind^ do begin
   d.dat.indirection:= 0;
   case po1^.header.kind of
    ek_property: begin                      //todo: indirection
     if isgetfact then begin
      if not getselfvar(ele2) then begin
       errormessage(err_noclass,[],0);
       goto endlab;
      end;
      if not checknoclassmethod(po1) then begin
       goto endlab;
      end;
      initdatacontext(poind^.d,ck_prop);
      d.dat.prop.propele:= ele.eleinforel(po1);
      with ptypedataty(ele.eledataabs(ppropertydataty(po2)^.typ))^ do begin
       d.dat.datatyp.typedata:= ppropertydataty(po2)^.typ;
       d.dat.datatyp.flags:= h.flags;
       d.dat.datatyp.indirectlevel:= h.indirectlevel;
       d.dat.indirection:= -1;
       d.dat.ref.c.address:= pvardataty(ele.eledataabs(ele2))^.address;
       d.dat.ref.offset:= 0;
       d.dat.ref.c.varele:= 0;
      end;
     end
     else begin
    {$ifdef mse_checkinternalerror}
      internalerror(ie_handler,'20151214B');
    {$endif}
     end;
    end;
    ek_var,ek_field: begin
     if po1^.header.kind in [ek_field] then begin
      if not checknoclassmethod(po1) then begin
       goto endlab;
      end;
      if not isgetfact and 
               (pob^.d.dat.indirection < 0) then begin
       if not getaddress(pob,true) then begin
        goto endlab;
       end;
      end;
      with pfielddataty(po2)^ do begin
       if isgetfact then begin
        if flags*[af_objectfield,af_classfield] <> [] then begin
         if not getselfvar(ele2) then begin
          errormessage(err_noclass,[],0);
          goto endlab;
         end;
       {$ifdef mse_checkinternalerror}
        end
        else begin
         internalerror(ie_value,'201400427B');
       {$endif}
        end;
        initdatacontext(poind^.d,ck_ref);
        d.dat.datatyp.typedata:= vf.typ;
        d.dat.datatyp.flags:= vf.flags;
        d.dat.indirection:= -1;
        d.dat.datatyp.indirectlevel:= indirectlevel;
        d.dat.ref.c.address:= pvardataty(ele.eledataabs(ele2))^.address;
        if vik_classele in foundflags1 then begin
         include(d.dat.ref.c.address.flags,af_classele);
        end;
        d.dat.ref.offset:= offset;
        d.dat.ref.c.varele:= 0;
        pocontext1:= poind;
       end
       else begin
        with pob^ do begin
         case d.kind of
          ck_ref: begin
           d.dat.datatyp.typedata:= vf.typ;
           d.dat.datatyp.indirectlevel:= indirectlevel;
           d.dat.ref.offset:= offset;
           d.dat.ref.c.varele:= 0;
          end;
          ck_fact,ck_subres: begin
           if (faf_varsubres in d.dat.fact.flags) and 
                                      (co_llvm in o.compileoptions) then begin
            with insertitem(oc_pushtempaddr,-1,-1)^ do begin
             par.tempaddr.a.ssaindex:= d.dat.fact.varsubres.ssaindex;
            end;
            exclude(d.dat.fact.flags,faf_varsubres);
           end;
           if offset <> 0 then begin
            ssabefore:= d.dat.fact.ssaindex;
            with insertitem(oc_offsetpoimm,-1,-1)^ do begin
             par.ssas1:= ssabefore;
             setimmint32(offset,par.imm);
            end;
           end;
           d.dat.datatyp.typedata:= vf.typ;
           d.dat.datatyp.indirectlevel:= indirectlevel;
           d.dat.indirection:= -1;
          end;
         {$ifdef mse_checkinternalerror}
          else begin
           internalerror(ie_value,'20140427D');
          end;
         {$endif}
         end;
         pocontext1:= pob;
        end;
                  //todo: no double copy by handlefact
       end;
       donotfound(pocontext1,pocontext1^.d.dat.datatyp.typedata);
      end;
     end
     else begin //ek_var
      if isgetfact then begin
       setupvarrefcontext(poind,pvardataty(po2),firstnotfound <= idents.high);
       pocontext1:= poind;
      end
      else begin
       with contextstack[s.stackindex-1] do begin
        if d.dat.indirection <> 0 then begin
         getaddress(pob,false);
         dec(d.dat.indirection); //pending dereference
        end;
        pocontext1:= poind - 1;
                  //todo: no double copy by handlefact
       end;
      end;
      if pvardataty(po2)^.vf.typ <= 0 then begin
       goto endlab; //todo: stop error earlier
      end;
      donotfound(pocontext1,pvardataty(po2)^.vf.typ);
     end;
     if (stf_params in s.currentstatementflags) and
                          (pocontext1^.d.kind in datacontexts) then begin
      po3:= ele.eledataabs(pocontext1^.d.dat.datatyp.typedata);
      if (pocontext1^.d.dat.datatyp.indirectlevel = 0) and 
                             (po3^.h.kind in [dk_sub,dk_method]) then begin
       if getvalue(pocontext1,das_none) then begin
        include(subflags,dsf_indirect);
        if po3^.h.kind = dk_method then begin
         include(subflags,dsf_instanceonstack);
        end;
        s.stackindex:= getstackindex(pocontext1);
        callsub(s.stackindex,ele.eledataabs(po3^.infosub.sub),
                                        paramstart,paramco,subflags);
       end;
      end;     
     end;
    end;
    ek_const: begin
     if checknoparam then begin
      initdatacontext(poind^.d,ck_const);
      d.dat.datatyp:= pconstdataty(po2)^.val.typ;
      d.dat.constval:= pconstdataty(po2)^.val.d;
     end;
    end;
    ek_sub: begin
     if not checknoclassmethod(po1) then begin
      goto endlab;
     end;
     if not isgetfact then begin
      dec(s.stackindex);
     end;
     callsub(s.stackindex,psubdataty(po2),paramstart,paramco,subflags);
    end;
    ek_sysfunc: begin //todo: handle ff_address
     with contextstack[s.stackindex] do begin
      d.kind:= ck_subcall;
     end;
     with psysfuncdataty(po2)^ do begin
      sysfuncs[func](paramco);
     end;
    end;
    ek_type: begin
     if firstnotfound > idents.high then begin
      if paramco = 0 then begin
       with ptypedataty(po2)^ do begin
        if h.kind = dk_enumitem then begin
         setenumconst(infoenumitem,contextstack[s.stackindex]);
        end
        else begin         
         with ptypedataty(po2)^ do begin
          d.kind:= ck_typearg;
          d.typ.flags:= h.flags;
          d.typ.typedata:= ele.eledatarel(po2);
          d.typ.indirectlevel:= h.indirectlevel;
          if not isgetfact then begin
           d.typ.indirectlevel:= d.typ.indirectlevel +
                    contextstack[s.stackindex-1].d.dat.indirection;
          end;
         end;
        end;
       end;
      end
      else begin          //type conversion //todo: identpath
       if paramco > 1 then begin
        errormessage(err_tokenexpected,[')'],4,-1);
       end
       else begin
        with ptypedataty(po2)^ do begin 
         bo1:= true;
         case potop^.d.kind of
          ck_ref: begin
           linkaddcast(ele.eledatarel(po2),potop);
           po3:= ele.eledataabs(potop^.d.dat.datatyp.typedata);
           if (potop^.d.dat.datatyp.indirectlevel = 1) and
                   (af_self in potop^.d.dat.ref.c.address.flags) then begin
            exclude(potop^.d.dat.ref.c.address.flags,af_classele); 
                                            //pointer(self) allowed
           end;
           potop^.d.dat.datatyp.typedata:= ele.eledatarel(po2);
           potop^.d.dat.datatyp.flags:= 
            (potop^.d.dat.datatyp.flags + h.flags) * (h.flags + [tf_subad]); 
                                     //do not remove tf_subad
           i1:= 0;
           if (h.kind = dk_interface) and (h.indirectlevel = 0) and
                 ((po3^.h.kind = dk_class) and 
                         (potop^.d.dat.datatyp.indirectlevel = 1) or
                  (po3^.h.kind = dk_object) and 
                         (potop^.d.dat.datatyp.indirectlevel = 0))
                          then begin
            i1:= 1;           //classinstance to interface
           end;
           potop^.d.dat.datatyp.indirectlevel:= 
                         potop^.d.dat.indirection + h.indirectlevel + i1;
           bo1:= false;
          end;
          ck_typearg: begin
           bo1:= false;
           errormessage(err_valueexpected,[]);
          end;
          else begin
           bo1:= not tryconvert(potop,po2,
                       ptypedataty(po2)^.h.indirectlevel,[coo_type]);
           if bo1 then begin
            illegalconversionerror(potop^.d,po2,
                                        ptypedataty(po2)^.h.indirectlevel);
           end;
          end;
         end;
         if not bo1 then begin
          poind^.d:= potop^.d; //big copy!
         end;
        end;
       end;
      end;
     end
     else begin
      donotfound(poind,ele.eleinforel(po1));
     end;
    end;
    ek_labeldef: begin
     d.kind:= ck_label;
     d.dat.lab:= ele.eleinforel(po1);
    end;
    ek_condition: begin
     with pconditiondataty(po2)^ do begin
      setconstcontext(poind,value)
     end;
    end;
    else begin
     internalerror1(ie_parser,'20150917C');
    end;
   end;
  end;
endlab:
  ele.popelementparent();
{
  pocontext1:= poind;
  while pocontext1 < potop do begin
   pocontext1^.d.kind:= ck_space;
   inc(pocontext1);
  end;
}
{
  if poind^.d.kind = ck_none then begin
   s.stacktop:= s.stackindex-1;
  end
  else begin
   s.stacktop:= s.stackindex;
  end;
}
  s.stacktop:= s.stackindex;
  dec(s.stackindex);
  if stf_cutvalueident in s.currentstatementflags then begin
   s.stacktop:= s.stackindex;
   pob^.context:= nil;
  end;
 end;
end;

procedure handlevalueidentifier();
begin
{$ifdef mse_debugparser}
 outhandle('VALUEIDENTIFIER');
{$endif}
 handlevalueident();
end;

procedure handlefactcallentry();
var
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('FACTCALLENTRY');
{$endif}
 i1:= errorcount(erl_error);
 handlevalueident();
 if i1 = errorcount(erl_error) then begin
  inc(info.s.stackindex); //continue
 end;
end;
(*
procedure handlefactcallentry1();
var
 i1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('FACTCALLENTRY1');
{$endif}
// inc(info.s.stackindex); //fact context
end;
*)
procedure handlefactcall();
var
 typ1: ptypedataty;
 indpo1,potop,contextpo1: pcontextitemty;
 subflags: dosubflagsty;
 paramstart,paramco: int32;
 sub1: psubdataty;
 stackind1: int32;
label
 errlab,endlab;
begin
{$ifdef mse_debugparser}
 outhandle('FACTCALL');
{$endif}
 with info do begin
  indpo1:= @contextstack[s.stackindex];
 {$ifdef mse_checkinternalerror}
  if indpo1^.d.kind <> ck_getfact then begin
   internalerror(ie_handler,'20171102A');
  end;
 {$endif}
//  if indpo1^.d.kind = ck_getfact then begin
   indpo1:= getnextnospace(indpo1+1);
   stackind1:= getstackindex(indpo1);
//  end
//  else begin
//   stackind1:= s.stackindex;
//  end;
  if getvalue(indpo1,das_none) and (indpo1^.d.kind in factcontexts) then begin
   typ1:= ele.eledataabs(indpo1^.d.dat.datatyp.typedata);
   if indpo1^.d.dat.datatyp.indirectlevel <> 0 then begin
    goto errlab;
   end;
   case typ1^.h.kind of 
    dk_sub: begin
     subflags:= [dsf_indirect];
    end;
    dk_method: begin
     subflags:= [dsf_indirect,dsf_instanceonstack];
    end;
    else begin
     goto errlab;
    end;
   end;
   sub1:= ele.eledataabs(typ1^.infosub.sub);
   paramstart:= stackind1+1;
   paramco:= 0;
   contextpo1:= @contextstack[paramstart];
   potop:= @contextstack[s.stacktop];
   if (contextpo1 < potop) and (contextpo1^.d.kind = ck_params) then begin
    inc(paramstart);
    while getnextnospace(contextpo1+1,contextpo1) do begin
     inc(paramco);
    end;
   end;
   callsub(stackind1,sub1,paramstart,paramco,subflags);
   goto endlab;
  end;
errlab:  
  errormessage(err_tokenexpected,[';'],0);
endlab:
  s.stacktop:= stackind1;
  contextstack[s.stackindex].d.kind:= ck_space;
  dec(s.stackindex);
 end;
end;

end.
