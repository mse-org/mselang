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
procedure handlevaluepathstart();
procedure handlevaluepath1a();
procedure handlevaluepath2a();
procedure handlevaluepath2();
procedure handlevalueinherited();

type
 dosubflagty = (dsf_indirect,dsf_isinherited,dsf_ownedmethod,dsf_indexedsetter,
                dsf_instanceonstack,
                dsf_usedestinstance, //use d.dat.fact.instancessa
                dsf_noinstancecopy,dsf_noparams,
                dsf_nofreemem, //for object destructor
                dsf_readsub,dsf_writesub,
                dsf_attach, //afterconstruct or beforedestruct
                dsf_objini,dsf_objfini);  //from objectmanagehandler
 dosubflagsty = set of dosubflagty;

procedure dosub(const adestindex: int32; asub: psubdataty;
                 const paramstart,paramco: int32; aflags: dosubflagsty;
                                                    const aobjssa: int32 = 0);
function getselfvar(out aele: elementoffsetty): boolean;
function listtoset(const acontext: pcontextitemty): boolean;

implementation
uses
 errorhandler,elements,handlerutils,opcode,stackops,segmentutils,opglob,
 subhandler,unithandler,syssubhandler,classhandler,interfacehandler,
 controlhandler,identutils,msestrings,handler,managedtypes,elementcache,
 __mla__internaltypes,exceptionhandler,listutils,llvmlists,grammarglob;

function listtoset(const acontext: pcontextitemty): boolean;
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
 poe:= acontext + acontext^.d.list.contextcount;
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
 result:= true;
end;

function listtoopenarray(const acontext: pcontextitemty;
                                         const aitemtype: ptypedataty): boolean;
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
 ele.checkcapacity(ek_type);
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
 ele.checkcapacity(ek_type);
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
  with info do begin
   i1:= contextstack[s.stackindex+stackoffset].d.dat.fact.ssaindex;
  end;
  result:= insertitem(aop,stackoffset,-1);
  with result^ do begin
   par.ssas1:= i1;
  end;
 end; //convert
  
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
     listtoset(acontext);
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
   if (dest^.h.kind = dk_object) and (destindirectlevel = 0) then begin
                     //check ":=" operator, convert to object
    operatorsig.d[0]:= tks_operators;
    operatorsig.d[1]:= objectoperatoridents[oa_assign];
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
        i4:= pointersize;
       end
       else begin
        i4:= alignsize(source1^.h.bytesize);
       end;
       var1:= ele.eledataabs(pelementoffsetty(@sub1^.paramsrel)[1]);
                            //value param
       
       if af_paramindirect in var1^.address.flags then begin
        with insertitem(oc_pushstackaddr,acontext,-1)^.par.memop do begin
         tempdataaddress.a.address:= 
                     -(i4 + alignsize(dest^.h.bytesize)+pointersize);
         tempdataaddress.offset:= 0;
        end;
       end
       else begin
        with insertitem(oc_pushstack,acontext,-1)^.par.memop do begin
         t.size:= source1^.h.bytesize;
         tempdataaddress.a.address:= 
                     -(i4 + i1 + pointersize);
         tempdataaddress.offset:= 0;
        end;
       end;
       dosub(getstackindex(acontext),sub1,getstackindex(acontext),1,
                       [dsf_instanceonstack,dsf_noinstancecopy,dsf_noparams]);
       with additem(oc_push)^ do begin
        par.imm.vsize:= pointersize; //compensate missing instance copy
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
       dosub(i1,sub1,i1,1,[dsf_instanceonstack,dsf_usedestinstance]);
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
   if (source1^.h.kind = dk_object) and 
                     (d.dat.datatyp.indirectlevel = 0) then begin
                    // check ":=" operator, convert from object
    operatorsig.d[0]:= tks_operators;
    operatorsig.d[1]:= objectoperatoridents[oa_assign];
    setoperparamid(@operatorsig.d[2],destindirectlevel,dest); //return value
    operatorsig.high:= 3;
    if ele.findchilddata(basetype(source1),
                          operatorsig,[ek_operator],allvisi,oper1) then begin
     result:= getvalue(acontext,das_none);
     if result then begin
      sub1:= ele.eledataabs(oper1^.methodele);
     {$ifdef mse_checkinternalerror}
      if sub1^.paramcount <> 2 then begin
       internalerror(ie_handler,'20170601A');
      end;
     {$endif}
     end;
     i1:= alignsize(source1^.h.bytesize);  //object size
     i2:= acontext^.d.dat.fact.ssaindex;
     with insertitem(oc_pushstackaddr,acontext,-1)^.par do begin
      ssas1:= i2;
      memop.t:= getopdatatype(source1,d.dat.datatyp.indirectlevel);
      memop.tempdataaddress.a.address:= -i1;
      memop.tempdataaddress.offset:= 0;
     end;
     i2:= getstackindex(acontext);
     dosub(i2,sub1,i2,0,[dsf_instanceonstack]);
     //todo: fini object
     if co_mlaruntime in info.o.compileoptions then begin
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
      end;
      if not result then begin
       exit; //no conversion possible
      end;
     end;
    end;
    if not result then begin
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
            convert(oc_chartostring8); //todo: !!!!!!!!!!!!!!!!!!!
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
   end
   else begin //different indirectlevel
    if (dest^.h.kind = dk_integer) and (destindirectlevel = 0) and 
             (d.dat.datatyp.indirectlevel > 0) and 
                                          (coo_type in aoptions) then begin
     if getvalue(acontext,das_pointer) then begin //pointer to int
      i1:= d.dat.fact.ssaindex;        //todo: operand size
      with insertitem(oc_potoint32,stackoffset,-1)^ do begin
       par.ssas1:= i1;
      end;
      d.dat.datatyp.typedata:= ele.eledatarel(dest);
      d.dat.datatyp.indirectlevel:= 0;
      result:= true;
     end;
    end
    else begin
{    
     if (d.kind in [ck_fact,ck_ref]) and 
        (destindirectlevel = 0) and (dest^.h.kind = dk_interface) and
        ((d.dat.datatyp.indirectlevel = 1) and (source1^.h.kind = dk_class) or
         (d.dat.datatyp.indirectlevel = 0) and 
                                      (source1^.h.kind = dk_object)) then begin
      i1:= ele.elementparent;
      po1:= source1;
      repeat
       if getclassinterfaceoffset(po1,dest,i3) then begin
        if getvalue(acontext,das_pointer) then begin
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
}     
      if (coo_type in aoptions) and 
              ((destindirectlevel > 0) and (source1^.h.indirectlevel = 0) and 
               (source1^.h.bitsize = pointerbitsize) or 
                      (source1^.h.kind in [dk_integer,dk_cardinal])) then begin
       if source1^.h.kind in [dk_string,dk_dynarray] then begin
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
//     end;
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
     result:=                           //todo: optimise
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
     pointerconv:= result;
    end;
   end;
   if not result and (coo_type in aoptions) then begin
    result:= (destindirectlevel = 0) and (source1^.h.indirectlevel = 0) and
                              (dest^.h.bytesize = source1^.h.bytesize);
   end;
   if result then begin
    if (d.kind = ck_const) and not pointerconv then begin
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
 sourceitem{,destitem}: ptypedataty;
 sourceindilev{,destindilev}: int32;
 pocont1,poe: pcontextitemty;
 i1,i2: int32;
 addr1: addressvaluety;
begin
 with info,sourcecontext^ do begin
 {$ifdef mse_checkinternalerror}
  if not (d.kind in (datacontexts + [ck_list])) then begin
   internalerror(ie_parser,'141211A');
  end;
 {$endif}
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
   result:= false;
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
     addr1.indirectlevel:= ptypedataty(ele.eledataabs(
                        dest^.infodynarray.i.itemtypedata))^.h.indirectlevel;
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
     inc(conversioncost); //at least 1
     result:= true;
     exit;
    end;
    else begin
     exit;
    end;
   end;
  end;
  
//  if (d.kind = ck_ref) and (d.dat.ref.castchain <> 0) then begin
//   source:= ele.basetype(linkgetcasttype(d.dat.ref.castchain));
//   sourceindilev:= source^.h.indirectlevel;
//  end
//  else begin
  source:= ele.basetype(d.dat.datatyp.typedata);
  sourceindilev:= d.dat.datatyp.indirectlevel;
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

procedure handlevaluepath1a();
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
   errormessage(err_identexpected,[]);
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
  if idf_inherited in ident.flags then begin
   errormessage(err_identexpected,[]);
  end;
  include(ident.flags,idf_inherited);
 end;
end;

procedure dosub(const adestindex: int32; asub: psubdataty;
              const paramstart,paramco: int32; aflags: dosubflagsty;
                                                    const aobjssa: int32 = 0);
var
 paramsize1: int32;
 paramschecked: boolean;
// tempsize: int32;
 
 function doparam(var context1: pcontextitemty;
                               const subparams1: pelementoffsetty; 
                               const parallocpo: pparallocinfoty): boolean;
                                              //false if skipped
 var
  vardata1: pvardataty;
  
  procedure doconvert();
  begin
   if not tryconvert(context1,ele.eledataabs(vardata1^.vf.typ),
                              vardata1^.address.indirectlevel,[]) then begin
    internalerror1(ie_handler,'20160519A');
   end;
  end; //doconvert

  procedure storetempgetaddress(); 
           //store stack value in local var and get address on stack
  var
   i1,i2,i3: int32;
   si1: databitsizety;
   sourcetype: ptypedataty;
   ad1: addressvaluety;
   ty1: typeallocinfoty;
  begin
   sourcetype:= ele.eledataabs(context1^.d.dat.datatyp.typedata);
              //dest can be untyped
   i3:= context1^.d.dat.fact.ssaindex; //data ssa
   if context1^.d.dat.datatyp.indirectlevel > 1 then begin
    i2:= pointersize;
    si1:= das_pointer;
   end
   else begin
    i2:= sourcetype^.h.bytesize;
    si1:= sourcetype^.h.datasize;
   end;
   ad1:= gettempaddress(i2);
   ty1:= getopdatatype(sourcetype,vardata1^.address.indirectlevel-1);
   if co_llvm in info.o.compileoptions then begin
    with insertitem(oc_tempalloc,context1,-1)^ do begin
     par.tempalloc.typid:= ty1.listindex;
     i1:= par.ssad;
    end;
   end;
   with insertitem(getpoptempop(si1),context1,-1)^ do begin
    par.memop.t:= getopdatatype(sourcetype,
                 vardata1^.address.indirectlevel-1);
    par.memop.t.flags:= par.memop.t.flags + [af_stacktemp,af_ssas2];
    if co_llvm in info.o.compileoptions then begin
     par.ssas1:= i3;
     par.ssas2:= i1; //alloc ssa
    end
    else begin
     par.memop.tempdataaddress.a:= ad1.tempaddress;
    end;
    par.memop.tempdataaddress.offset:= 0;
   end;
   if not (co_llvm in info.o.compileoptions) then begin
    pushinserttempaddress(ad1.tempaddress,getstackoffset(context1),-1);
   end
   else begin
    with insertitem(oc_potopo,context1,-1)^ do begin
     par.ssas1:= i1;
     context1^.d.dat.fact.ssaindex:= par.ssad;
    end;
   end;
  end; //storetempgetaddress
  
 var
  desttype: ptypedataty;
  si1: databitsizety;
  stackoffset,i1,i2,i3: int32;
  conversioncost1: int32;
  err1: errorty;
  opref1: int32;
  p1,pe: pcontextitemty;
  ele1: elementoffsetty;
  sourcetype: ptypedataty;
  destindilev1: int32;
 begin
  result:= true; //not skipped
  with info do begin
   vardata1:= ele.eledataabs(subparams1^);
   if vardata1^.vf.typ = 0 then begin
    exit; //invalid param type
   end;
   desttype:= ptypedataty(ele.eledataabs(vardata1^.vf.typ));
   si1:= desttype^.h.datasize;
   stackoffset:= getstackoffset(context1);
   conversioncost1:= 1;
   if not paramschecked and 
          not checkcompatibledatatype(context1,vardata1^.vf.typ,
                               vardata1^.address,[cco_novarconversion],
                                       conversioncost1,destindilev1) then begin
    err1:= err_incompatibletypeforarg;
    with context1^ do begin
     sourcetype:= ele.eledataabs(d.dat.datatyp.typedata);
     i1:= context1^.d.dat.datatyp.indirectlevel-sourcetype^.h.indirectlevel;
    end;
    if vardata1^.address.flags * [af_paramvar,af_paramout] <> [] then begin
     err1:= err_callbyvarexact;
    end;
    i2:= 1;
    p1:= @contextstack[context1^.parent];
    while getnextnospace(p1+1,p1) and (p1 <> context1) do begin
     inc(i2);
    end;
    if context1^.d.kind = ck_list then begin
     errormessage(err1,[i2,'list',
                  typename(ptypedataty(ele.eledataabs(vardata1^.vf.typ))^,
                                                   destindilev1)],stackoffset);
    end
    else begin
     errormessage(err1,[i2,
               typename(sourcetype^,i1),
                  typename(ptypedataty(ele.eledataabs(vardata1^.vf.typ))^,
                                                   destindilev1)],stackoffset);
    end;
    exit;
   end;
   if af_paramindirect in vardata1^.address.flags then begin
    case context1^.d.kind of
     ck_const,ck_list: begin
      if not (af_const in vardata1^.address.flags) then begin
       errormessage(err_variableexpected,[],stackoffset);
      end
      else begin
       if context1^.d.kind = ck_const then begin
        if not tryconvert(context1,ele.eledataabs(vardata1^.vf.typ),
                  vardata1^.address.indirectlevel-1,[]) then begin
         internalerror1(ie_handler,'20170423A');
        end;
        if not getvalue(context1,das_none) then begin
         internalerror1(ie_handler,'20170424A');
        end;
        storetempgetaddress(); //get data pointer
       end
       else begin
        errormessage(err_variableexpected,[],stackoffset);
 //       notimplementederror('20140405B'); //todo
       end;
      end;
     end;
     ck_ref: begin
      pushinsertaddress(stackoffset,-1);
     end;
     ck_fact,ck_subres: begin
      with context1^ do begin
       if d.dat.indirection = 0 then begin
        storetempgetaddress();
       end
       else begin
        if d.dat.indirection < -1 then begin
         inc(d.dat.indirection);
         inc(d.dat.datatyp.indirectlevel);
         getvalue(context1,si1);
        end;
       end;
      end;
     end;
    end;
   end
   else begin
    with desttype^ do begin
     if h.indirectlevel > 0 then begin
      si1:= das_pointer;
     end
     else begin
      si1:= h.datasize;
     end;
    end;
    
    if context1^.d.kind = ck_list then begin
     case desttype^.h.kind of
      dk_set: begin
       if not listtoset(context1) then begin
        exit;
       end;
       conversioncost1:= 0;
      end;
      dk_openarray: begin
       if sf_vararg in asub^.flags then begin
        pe:= context1+context1^.d.list.contextcount;
        p1:= context1+1;
        while p1 < pe do begin
         if p1^.d.kind = ck_list then begin
          p1:= p1+p1^.d.list.contextcount;
         end
         else begin
          exclude(p1^.d.handlerflags,hf_listitem);
          inc(p1);
         end;
        end;
        result:= false; //skip
        exit;
       end;
       if not listtoopenarray(context1,desttype) then begin
        exit;
       end;
       conversioncost1:= 0;
      end;
      else begin
       internalerror1(ie_handler,'20160612A');
      end;
     end;
    end;
    case context1^.d.kind of
     ck_const: begin
      if conversioncost1 > 0 then begin
       doconvert();
      end;
      pushinsertconst(stackoffset,-1,si1);
     end;
     ck_ref: begin
      if desttype^.h.kind <> dk_openarray then begin //address needed?
       getvalue(context1,si1);                       //no
      end;
      if conversioncost1 > 0 then begin
       doconvert();
      end;
     end;
     ck_fact,ck_subres: begin
      if context1^.d.dat.indirection < 0 then begin //pending dereference
       getvalue(context1,si1);                       
      end;
      if conversioncost1 > 0 then begin
       doconvert();
      end;
     end;
    end;
   end;
   if (af_paramvar in vardata1^.address.flags) and 
                                  (context1^.d.kind in factcontexts) then begin
    checkneedsunique(stackoffset);
   end;
   with parallocpo^ do begin
    ssaindex:= context1^.d.dat.fact.ssaindex;
    size:= getopdatatype(vardata1^.vf.typ,vardata1^.address.indirectlevel);
    inc(paramsize1,alignsize(getbytesize(size)));
   end;
  end;
 end; //doparam

var
 po1: popinfoty;
 resulttype1: ptypedataty;
 subparams1,subparamse: pelementoffsetty;
 po7: pelementinfoty;
 totparamco: integer; //including internal params
 i1,i2,i3: integer;
 bo1: boolean;
 parallocstart: dataoffsty;
                    //todo: paralloc info for hidden params
 selfpo,parallocpo: pparallocinfoty;
 hasresult: boolean;
 idents1: identvecty;
 firstnotfound1: integer;
 callssa: int32;
 vardata1: pvardataty;
 lastparamsize1: int32;
 instancessa: int32;
 subdata1: psubdataty;
 cost1,matchcount1: int32;
 needsvarcheck: boolean;
 destoffset: int32;

 procedure dodefaultparams();
 var
  i1: int32;  
  desttype: ptypedataty;
  vardata1: pvardataty;
  si1: databitsizety;
 begin
  with info do begin
   i1:= asub^.paramcount - totparamco; //defaultparamcount
   if i1 > 0 then begin
    if paramco = 0 then begin //no data context at top
     inc(s.stacktop);
    end;
    for i1:= i1-1 downto 0 do begin
     vardata1:= ele.eledataabs(subparams1^);
     desttype:= ptypedataty(ele.eledataabs(vardata1^.vf.typ));
    {$ifdef mse_checkinternalerror}
     if vardata1^.vf.defaultconst <= 0 then begin
      internalerror(ie_handler,'20160521D');
     end;
    {$endif}
     with desttype^ do begin
      if h.indirectlevel > 0 then begin
       si1:= das_pointer;
      end
      else begin
       si1:= h.datasize;
      end;
     end;
     pushinsertconst(s.stacktop-s.stackindex,
          pconstdataty(ele.eledataabs(vardata1^.vf.defaultconst))^.val.d,
                                                                 -1,si1);
     with parallocpo^ do begin
     {$ifdef mse_checkinternalerror}
      if contextstack[s.stacktop].d.kind <> ck_fact then begin
       internalerror(ie_handler,'20160521E');
      end;
     {$endif}
      ssaindex:= contextstack[s.stacktop].d.dat.fact.ssaindex;
      size:= getopdatatype(vardata1^.vf.typ,vardata1^.address.indirectlevel);
      inc(paramsize1,alignsize(getbytesize(size)));
     end;
     inc(subparams1);
     inc(parallocpo);
    end;
    if paramco = 0 then begin //no data context at top
     dec(s.stacktop);
    end;
   end;
  end;
 end;

 procedure callclasssubattach(const asub: elementoffsetty);
 begin
  if asub <> 0 then begin
   dosub(adestindex,ele.eledataabs(asub),paramstart,0,
                            [dsf_instanceonstack,dsf_attach],instancessa);
   if co_mlaruntime in info.o.compileoptions then begin
    with additem(oc_push)^ do begin
     par.imm.vsize:= pointersize; //compensate stackpop
    end;
   end;
  end;
 end;

var
 instancetype1: ptypedataty;

 procedure doinstanceonstack();
 begin
  with info.contextstack[adestindex] do begin
   instancetype1:= ele.eledataabs(d.dat.datatyp.typedata);
   if dsf_usedestinstance in aflags then begin
    instancessa:= d.dat.fact.instancessa; //for sf_method
   end
   else begin
    instancessa:= d.dat.fact.ssaindex; //for sf_method
   end;
   if (sf_destructor in asub^.flags) then begin
    callclasssubattach(instancetype1^.infoclass.subattach.beforedestruct);
   end;
  end;
 end;
 
var
 realparamco: int32; //including defaults
 {poparams,indpo,}poitem1{,pe}: pcontextitemty;
 stacksize,resultsize: int32;
 isfactcontext: boolean;
 ismethod: boolean;
 opoffset1: int32;
 methodtype1: ptypedataty;
 i4: int32;
 adref1: addressrefty;
 b1: boolean;
 mo1: managedopty;
 typ1: ptypedataty;
 varargcount: int32;
 varargs: array[0..maxparamcount] of int32;
 isvararg: boolean;
label
 paramloopend;
begin
{$ifdef mse_debugparser}
 outhandle('dosub');
{$endif}
 varargcount:= 0;
 isvararg:= sf_vararg in asub^.flags;
 with info do begin
//  indpo:= @contextstack[s.stackindex];
//  pe:= @contextstack[s.stacktop];
  ele.checkcapacity(ek_type,1,asub); //for anonymus method def
  destoffset:= adestindex-s.stackindex;
  with contextstack[adestindex] do begin //classinstance, result,
                                         //classdefreturn for ini/fini
   if dsf_instanceonstack in aflags then begin
    doinstanceonstack();
   end;
   paramschecked:= false;
   if asub^.nextoverload >= 0 then begin //check overloads
    needsvarcheck:= true;
    subdata1:= asub;
    matchcount1:= 0;
    cost1:= bigint;
    while true do begin
    {$ifdef mse_checkinternalerror}
     if datatoele(subdata1)^.header.kind <> ek_sub then begin
      internalerror(ie_handler,'20160517A');
     end;
    {$endif}
     subparams1:= @subdata1^.paramsrel;
     subparamse:= subparams1 + subdata1^.paramcount;
     totparamco:= paramco;
     if [sf_function] * subdata1^.flags <> [] then begin
      inc(totparamco); //result parameter
      inc(subparams1);
     end;
     if sf_method in subdata1^.flags then begin
      inc(totparamco); //self parameter
      inc(subparams1);
     end;
     i3:= 0;
     bo1:= false;
     if (totparamco >= subdata1^.paramcount - subdata1^.defaultparamcount) and
                (totparamco <= subdata1^.paramcount) then begin 
      poitem1:= @contextstack[adestindex+2]; //????
      while subparams1 < subparamse do begin //find best parameter match
       if not getnextnospace(poitem1+1,poitem1) then begin
        poitem1:= nil; //needs default param
        break;
       end;
       vardata1:= ele.eledataabs(subparams1^);
       bo1:= bo1 or (vardata1^.address.flags * [af_paramvar,af_paramout] <> []);
       if (vardata1^.vf.typ = 0) or 
             not checkcompatibledatatype(poitem1,
                        vardata1^.vf.typ,vardata1^.address,[],i2,i4) then begin
                                                           //report byvalue,
                                                           //byaddress dup
        goto paramloopend;
       end;
       i2:= i2*32; //room for default params cost
       if i3 < i2 then begin
        i3:= i2;             //maximal cost
       end;
       inc(subparams1);
//       inc(i1);
      end;
      if poitem1 = nil then begin
       inc(i3);      //needs default params
      end;
      if i3 < cost1 then begin
       cost1:= i3;
       asub:= subdata1;
       matchcount1:= 1;
       needsvarcheck:= bo1;
      end
      else begin
       if i3 = cost1 then begin
        inc(matchcount1);
       end;
      end;
     end;
 paramloopend:
     if subdata1^.nextoverload < 0 then begin
      break;
     end;
     subdata1:= ele.eledataabs(subdata1^.nextoverload);
    end;
    if matchcount1 > 1 then begin
     errormessage(err_cantdetermine,[]);
     exit;
    end;
    paramschecked:= not needsvarcheck;
   end;

   if stf_getaddress in s.currentstatementflags then begin
    if dsf_instanceonstack in aflags then begin
                                     //get method
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_fact then begin
      internalerror(ie_handler,'20160916A');
     end;
    {$endif}
//     i1:= d.dat.fact.ssaindex;
//     instancetype1:= ele.eledataabs(d.dat.datatyp.typedata);
    end;
    initdatacontext(d,ck_ref);
    d.dat.datatyp.typedata:= asub^.typ;
    d.dat.datatyp.indirectlevel:= 0;
    d.dat.datatyp.flags:= [tf_subad];
    d.dat.ref.c.address:= nilopad;
    d.dat.ref.c.address.segaddress.element:= ele.eledatarel(asub); 
    d.dat.ref.offset:= 0;
    d.dat.ref.c.varele:= 0;
    if dsf_instanceonstack in aflags then begin //get method
     case instancetype1^.h.kind of
      dk_interface: begin
       with insertitem(oc_getintfmethod,destoffset,-1)^ do begin
        par.getvirtsubad.virtoffset:= asub^.tableindex*sizeof(intfitemty) +
                                                        sizeof(intfdefheaderty);
        if co_llvm in info.o.compileoptions then begin
         par.ssas1:= instancessa; //class
         par.getvirtsubad.virtoffset:= 
               info.s.unitinfo^.llvmlists.constlist.
                          adddataoffs(par.getvirtsubad.virtoffset).listid;
        end;
       end;
       initfactcontext(destoffset);
      end;
      dk_class,dk_object: begin
       d.dat.ref.c.address.segaddress.address:= asub^.globid;
       if asub^.flags * [sf_virtual,sf_override] <> [] then begin
        with insertitem(oc_getvirtsubad,destoffset,-1)^ do begin
         par.getvirtsubad.virtoffset:= asub^.tableindex*sizeof(opaddressty)+
                                                           virtualtableoffset;
         if co_llvm in info.o.compileoptions then begin
          par.ssas1:= instancessa; //class
          par.getvirtsubad.virtoffset:= 
                info.s.unitinfo^.llvmlists.constlist.
                           adddataoffs(par.getvirtsubad.virtoffset).listid;
         end;
        end;
        initfactcontext(destoffset);
       end
       else begin
        getaddress(@contextstack[adestindex],true);
       end;
      {$ifdef mse_checkinternalerror}
       if d.kind <> ck_fact then begin
        internalerror(ie_handler,'20160916A');
       end;
      {$endif}
       i2:= d.dat.fact.ssaindex;
       with insertitem(oc_combinemethod,destoffset,-1)^ do begin
        par.ssas1:= instancessa;
        par.ssas2:= i2;
       end;
      end;
      else begin
       internalerror1(ie_handler,'20160821C');
      end;
     end;
     methodtype1:= ele.addelementdata(getident(),ek_type,nonevisi); //anonymous
     inittypedatabyte(methodtype1^,dk_method,0,2*pointersize);
     methodtype1^.infosub.sub:= ele.eledatarel(asub);
     d.dat.datatyp:= methoddatatype; //sub type undefined
     d.dat.datatyp.typedata:= ele.eledatarel(methodtype1);
     dec(d.dat.indirection); //restore getaddress
     dec(d.dat.datatyp.indirectlevel); //restore getaddress
    end;
   end
   else begin
    isfactcontext:= d.kind in factcontexts;
    ismethod:= asub^.flags * [sf_method,sf_ofobject] = [sf_method];

    if ismethod then begin
     if (dsf_ownedmethod in aflags) then begin
               //owned method
     {$ifdef mse_checkinternalerror}
      if ele.findcurrent(tks_self,[],allvisi,vardata1) <> ek_var then begin
       internalerror(ie_value,'20140505A');
      end;
     {$else}
      ele.findcurrent(tk_self,[],allvisi,vardata1);
     {$endif}
 //     with insertitem(oc_pushlocpo,parent-s.stackindex,-1)^ do begin
      with insertitem(oc_pushlocpo,destoffset,-1)^ do begin
       par.memop.t:= bitoptypes[das_pointer];
       par.memop.locdataaddress.a.framelevel:= -1;
       par.memop.locdataaddress.a.address:= vardata1^.address.poaddress;
       par.memop.locdataaddress.offset:= 0;
       instancessa:= par.ssad;
      end;
      instancetype1:= ele.eledataabs(vardata1^.vf.typ);
     end
     else begin
      if aflags*[dsf_objini,dsf_objfini,dsf_attach] <> [] then begin
      {
       if co_mlaruntime in o.compileoptions then begin
        with additem(oc_pushduppo)^ do begin
         par.voffset:= -vpointersize;
        end;
       end;
      }
       instancessa:= aobjssa;
 //      instancetype1:= aobjtypeele.eledataabs(vardata1^.vf.typ);
      end
      else begin
       if aflags*[dsf_instanceonstack,dsf_indirect,
                              dsf_readsub,dsf_writesub] = [] then begin
        if ismethod and isfactcontext then begin
         if (sf_class in asub^.flags) then begin
          if d.dat.datatyp.indirectlevel <> 0 then begin
           errormessage(err_classinstanceexpected,[]);
          end;
         end
         else begin
          if d.dat.datatyp.indirectlevel <> 0 then begin
           errormessage(err_objectpointerexpected,[]);
          end;
         end;
        end;
        if ismethod and isfactcontext and (d.dat.indirection = 0) then begin
         i1:= d.dat.fact.ssaindex;
         typ1:= ele.eledataabs(d.dat.datatyp.typedata);
         with insertitem(oc_pushstackaddr,destoffset,-1)^.par do begin
          memop.tempdataaddress.a.address:= -alignsize(typ1^.h.bytesize);
          memop.tempdataaddress.offset:= 0;
//          tempdataaddress.a.ssaindex:= i1;
          ssas1:= i1;
          memop.t:= getopdatatype(typ1,0);
         end;
         include(aflags,dsf_instanceonstack);
         doinstanceonstack();
        end
        else begin
         inc(d.dat.indirection);              //instance pointer
         inc(d.dat.datatyp.indirectlevel);
         getvalue(@contextstack[adestindex],das_none);
        end;
       end;
       if dsf_usedestinstance in aflags then begin
        instancessa:= d.dat.fact.instancessa;
       end
       else begin
        instancessa:= d.dat.fact.ssaindex; //for sf_method
       end;
      end;
     end; //ismethod
    end;

    if dsf_indirect in aflags then begin
     if co_llvm in o.compileoptions then begin
      if sf_ofobject in asub^.flags then begin //method pointer call
       with insertitem(oc_getmethodcode,destoffset,-1)^ do begin
        par.ssas1:= instancessa; //[code,data]
       end;
       callssa:= d.dat.fact.ssaindex;
       with insertitem(oc_getmethoddata,destoffset,-1)^ do begin
        par.ssas1:= instancessa; //[code,data]
       end;
       instancessa:= d.dat.fact.ssaindex;
      end
      else begin
       callssa:= d.dat.fact.ssaindex;
      end;
     end;
    end;

    subparams1:= @asub^.paramsrel;
    totparamco:= paramco;
    if [sf_function] * asub^.flags <> [] then begin
     inc(totparamco); //result parameter
    end;
    if sf_method in asub^.flags then begin
     inc(totparamco); //self parameter
    end;
    if ((totparamco < asub^.paramcount - asub^.defaultparamcount) or 
                (totparamco > asub^.paramcount)) and 
         not (isvararg and (asub^.paramcount-totparamco = 1)) then begin 
                                         //todo: use correct source pos
     identerror(datatoele(asub)^.header.name,err_wrongnumberofparameters);
     exit;
    end;
    hasresult:= (sf_function in asub^.flags) or 
          not isfactcontext and 
          (sf_constructor in asub^.flags) and not (dsf_isinherited in aflags);
    if hasresult then begin
     initfactcontext(adestindex-s.stackindex); //set ssaindex
     if sf_constructor in asub^.flags then begin //needs memory
      bo1:= findkindelementsdata(1,[],allvisi,resulttype1,
                                                   firstnotfound1,idents1,1);
                                          //get class type
     {$ifdef mse_checkinternalerror}
      if not bo1 then begin 
       internalerror(ie_handler,'20150325A'); 
      end;
     {$endif}
      instancetype1:= resulttype1;
     {
      if icf_class in resulttype1^.infoclass.flags then begin
       with insertitem(oc_initclass,destoffset,-1)^,par.initclass do begin
        classdef:= resulttype1^.infoclass.defs.address;
        setimmint32(resulttype1^.infoclass.virttaboffset,virttaboffset);
       end;
       instancessa:= d.dat.fact.ssaindex; //for sf_constructor
      end
      else begin
      }
      with resulttype1^.infoclass do begin
       if (icf_zeroinit in flags) or not (icf_nozeroinit in flags) then begin
        with insertitem(oc_getobjectzeromem,destoffset,-1)^ do begin
         setimmint32(allocsize,par.imm);
        end;
        instancessa:= d.dat.fact.ssaindex; //for sf_constructor
        b1:= false;
       end
       else begin
        with insertitem(oc_getobjectmem,destoffset,-1)^ do begin
         setimmint32(allocsize,par.imm);
        end;
        instancessa:= d.dat.fact.ssaindex; //for sf_constructor
        b1:= true;
       end;
       if b1 and (tf_needsmanage in resulttype1^.h.flags) or
                          (tf_needsini in resulttype1^.h.flags) then begin
        adref1.offset:= 0;
        adref1.ssaindex:= instancessa;
        adref1.contextindex:= adestindex;
        adref1.kind:= ark_stack;
        adref1.address:= 0;
        adref1.typ:= resulttype1;
        writemanagedtypeop(mo_ini,resulttype1,adref1);
       end;
//       end;
      end;
     end
     else begin
      resulttype1:= ele.eledataabs(asub^.resulttype.typeele);
      inc(subparams1);
     end;
     d.kind:= ck_subres;
     d.dat.datatyp.indirectlevel:= asub^.resulttype.indirectlevel;
     d.dat.datatyp.typedata:= ele.eledatarel(resulttype1);        
     d.dat.fact.opdatatype:= getopdatatype(resulttype1,d.dat.datatyp.indirectlevel);
    end;

    if isvararg then begin
     checksegmentcapacity(seg_localloc,sizeof(parallocinfoty)*maxparamcount);
                                                             //max
    end
    else begin
     checksegmentcapacity(seg_localloc,sizeof(parallocinfoty)*asub^.paramcount);
                                                             //max
    end;
    parallocstart:= getsegmenttopoffs(seg_localloc);    

    if sf_function in asub^.flags then begin
     with pparallocinfoty(
              allocsegmentpo(seg_localloc,sizeof(parallocinfoty)))^ do begin
      ssaindex:= 0; //not used
      size:= d.dat.fact.opdatatype;//getopdatatype(po3,po3^.indirectlevel);
     end;
    end;
    if sf_method in asub^.flags then begin
     selfpo:= allocsegmentpo(seg_localloc,sizeof(parallocinfoty));
     with selfpo^ do begin
      ssaindex:= instancessa;
      size:= bitoptypes[das_pointer];
     end;
     inc(subparams1); //first param
    end;
    opoffset1:= getcontextopcount(adestindex-s.stackindex);
    if co_mlaruntime in o.compileoptions then begin
     stacksize:= 0;
     resultsize:= 0;
     i2:= opoffset1; //insert result space at end of statement
     if hasresult then begin
      if sf_method in asub^.flags then begin
       i2:= 0; //insert result space before instance
       stacksize:= vpointersize;
      end;
      resultsize:= pushinsertvar(adestindex-s.stackindex,
                              i2,asub^.resulttype.indirectlevel,resulttype1);
      inc(opoffset1);
      stacksize:= stacksize + resultsize; //alloc space for return value
      locdatapo:= locdatapo + resultsize;
     end;
    end;
    paramsize1:= 0;
    realparamco:= asub^.paramcount-(totparamco-paramco);
    parallocpo:= allocsegmentpo(seg_localloc,sizeof(parallocinfoty)*
                                 realparamco);
                                 //including default params
    poitem1:= @contextstack[paramstart-1]; //before first param
//    tempsize:= 0;
    i1:= paramco;
//    tempsbefore:= locdatapo;
    if dsf_indexedsetter in aflags then begin
     inc(parallocpo); //second, first index
     inc(subparams1);
     while i1 > 1 do begin
      getnextnospace(poitem1+1,poitem1);
      doparam(poitem1,subparams1,parallocpo);
      inc(subparams1);
      inc(parallocpo);
      dec(i1);
     end;
     dodefaultparams();
     lastparamsize1:= paramsize1;
     dec(parallocpo,paramco); //first, value
     dec(subparams1,paramco);
     getnextnospace(poitem1+1,poitem1);
     doparam(poitem1,subparams1,parallocpo); //last
     lastparamsize1:= paramsize1-lastparamsize1;
    end
    else begin
     if not (dsf_noparams in aflags) then begin
      while i1 > 0 do begin
       getnextnospace(poitem1+1,poitem1);
       if doparam(poitem1,subparams1,parallocpo) then begin 
                                      //vararg list skipped?
        inc(subparams1);              //no
        inc(parallocpo);
        dec(i1);
       end
       else begin
        i1:= maxparamcount-asub^.paramcount;
        while getnextnospace(poitem1+1,poitem1) do begin
         getvalue(poitem1,das_none);
         parallocpo^.ssaindex:= poitem1^.d.dat.fact.ssaindex;
         inc(varargcount);
         inc(parallocpo);
         if varargcount >= i1 then begin
          errormessage(err_toomanyparams,[]);
          break;
         end;
        end;
        allocsegmentpo(seg_localloc,varargcount*sizeof(parallocinfoty));
        break;
       end;
      end;
      if not isvararg then begin
       dodefaultparams(); //varargs can not have defaultparams
      end;
      if dsf_instanceonstack in aflags then begin
       if not (dsf_usedestinstance in aflags) then begin
        selfpo^.ssaindex:= d.dat.fact.ssaindex; 
               //could be shifted by right side operator param
       end;
      end;
     end;
    end;
//    locdatapo:= tempsbefore;
    
    if co_mlaruntime in o.compileoptions then begin
     poitem1:= @contextstack[paramstart];
     if poitem1^.d.kind <> ck_params then begin //no params
      dec(poitem1);
     end;
     {
     if poitem1^.d.kind = ck_params then begin
      tempsize:= poitem1^.d.params.tempsize;
     end;
     if tempsize > 0 then begin
      with insertitem(oc_push,0,opoffset1)^ do begin
       par.imm.vsize:= tempsize;
      end;
      inc(opoffset1);
     end;
     }
     if hasresult then begin
      with insertitem(oc_pushstackaddr,destoffset,opoffset1)^.
                                     par.memop.tempdataaddress do begin
                                              //result var param
       a.address:= -stacksize{-tempsize};
       offset:= 0;
      end;
      inc(opoffset1);
      stacksize:= stacksize + vpointersize;
     end;
     if (sf_method in asub^.flags) and 
                not (dsf_noinstancecopy in aflags) then begin
          //param order is [returnvaluepointer],instancepo,{params}
      with insertitem(oc_pushduppo,destoffset,opoffset1)^ do begin
       if hasresult then begin
        par.voffset:= -2*vpointersize;
       end
       else begin
        par.voffset:= -vpointersize;
       end;
      end;
      inc(opoffset1);
     end;
    end;

    if not hasresult and 
            (aflags*[dsf_attach,dsf_objini,dsf_objfini] = []) then begin
     d.kind:= ck_subcall;
     if (dsf_indexedsetter in aflags) and 
                             (co_mlaruntime in o.compileoptions) then begin
      with additem(oc_swapstack)^.par.swapstack do begin
       offset:= -paramsize1;
       size:= lastparamsize1;
      end;
     end;
    end;
    if not (dsf_isinherited in aflags) and 
         (asub^.flags * [sf_virtual,sf_override,sf_interface] <> []) then begin
     if sf_interface in asub^.flags then begin
      if sf_function in asub^.flags then begin
       po1:= additem(oc_callintffunc);
      end
      else begin
       po1:= additem(oc_callintf);
      end;
      po1^.par.callinfo.virt.virtoffset:= asub^.tableindex*sizeof(intfitemty) +
                                                        sizeof(intfdefheaderty);
     end
     else begin
      if sf_function in asub^.flags then begin
       po1:= additem(oc_callvirtfunc);
      end
      else begin
       po1:= additem(oc_callvirt);
      end;
      po1^.par.callinfo.virt.virtoffset:= asub^.tableindex*sizeof(opaddressty)+
                                                             virtualtableoffset;
     end;
     if co_llvm in o.compileoptions then begin
      po1^.par.callinfo.virt.virtoffset:=  
              info.s.unitinfo^.llvmlists.constlist.
                         adddataoffs(po1^.par.callinfo.virt.virtoffset).listid;
      po1^.par.callinfo.virt.typeid:= info.s.unitinfo^.llvmlists.typelist.
                                                            addsubvalue(asub);
     end;
     if sf_function in asub^.flags then begin
      po1^.par.callinfo.virt.selfinstance:= -asub^.paramsize + vpointersize;
     end
     else begin
      po1^.par.callinfo.virt.selfinstance:= -asub^.paramsize;
     end;
     setimmint32(instancetype1^.infoclass.virttaboffset,
                                 po1^.par.callinfo.virt.virttaboffset);
                                    ;
     po1^.par.callinfo.linkcount:= -1;
    end
    else begin
     if (asub^.nestinglevel = 0) or 
                      (asub^.nestinglevel = sublevel) then begin
      if dsf_indirect in aflags then begin
       if sf_function in asub^.flags then begin
        po1:= additem(oc_callfuncindi);
       end
       else begin
        po1:= additem(oc_callindi);
       end;
       if co_llvm in o.compileoptions then begin
        po1^.par.ssas1:= callssa;
        po1^.par.callinfo.indi.typeid:= 
                     info.s.unitinfo^.llvmlists.typelist.addsubvalue(asub);
       end
       else begin
        po1^.par.callinfo.indi.calladdr:= -asub^.paramsize -
                                                   resultsize - pointersize;
        if sf_ofobject in asub^.flags then begin
         dec(po1^.par.callinfo.indi.calladdr,pointersize); 
                     //method pointer is [code,data]
        end;
       end;
      end
      else begin
       if sf_function in asub^.flags then begin
        po1:= additem(oc_callfunc);
       end
       else begin
        po1:= additem(oc_call);
       end;
      end;
      po1^.par.callinfo.linkcount:= -1;
     end
     else begin
      i1:= sublevel-asub^.nestinglevel;
      if sf_function in asub^.flags then begin
       po1:= additem(oc_callfuncout,getssa(ocssa_nestedcallout,i1));
      end
      else begin
       po1:= additem(oc_callout,getssa(ocssa_nestedcallout,i1));
      end;
      po1^.par.callinfo.linkcount:= i1-2;      //for downto 0
      po7:= ele.parentelement;
      include(psubdataty(@po7^.data)^.flags,sf_hasnestedaccess);
      for i1:= i1-1 downto 0 do begin
       po7:= ele.eleinfoabs(po7^.header.parent);
       include(psubdataty(@po7^.data)^.flags,sf_hasnestedref);
       if i1 <> 0 then begin
        include(psubdataty(@po7^.data)^.flags,sf_hasnestedaccess);
        include(psubdataty(@po7^.data)^.flags,sf_hascallout);
       end;
      end;
     end;
     if (asub^.address = 0) and 
                   (not modularllvm or 
                    (s.unitinfo = datatoele(asub)^.header.defunit)) then begin 
                                             //unresolved header
      linkmark(asub^.calllinks,getsegaddress(seg_op,@po1^.par.callinfo.ad));
     end;
    end;
    with po1^ do begin
     par.callinfo.flags:= asub^.flags;
     if not hasresult then begin
      exclude(par.callinfo.flags,sf_constructor); //no class pointer on stack
     end;      
     if dsf_isinherited in aflags then begin
      exclude(par.callinfo.flags,sf_virtual);
     end;
     par.callinfo.params:= parallocstart;
    {$ifdef mse_checkinternalerror}
     if realparamco+totparamco-paramco <> asub^.paramcount then begin
      internalerror(ie_handler,'20160522A');
     end;
    {$endif}
     if isvararg then begin
      par.callinfo.paramcount:= asub^.paramcount - 1 + varargcount;
     end
     else begin
      par.callinfo.paramcount:= asub^.paramcount;
     end;
     par.callinfo.ad.ad:= asub^.address-1; //possibly invalid
     par.callinfo.ad.globid:= trackaccess(asub);
    end;
    if sf_function in asub^.flags then begin
     d.dat.fact.ssaindex:= s.ssa.nextindex-1;
    end;
    if (sf_destructor in asub^.flags) and 
                     (aflags * [dsf_isinherited,dsf_nofreemem] = []) then begin
     if instancetype1^.h.flags*[tf_needsmanage,tf_needsfini] <> [] then begin
      adref1.offset:= 0;
      adref1.ssaindex:= instancessa;
      adref1.contextindex:= adestindex;
      adref1.kind:= ark_stack;
      adref1.address:= 0; //instance removed by destroy()
      adref1.typ:= instancetype1;
      if tf_needsfini in instancetype1^.h.flags then begin
       mo1:= mo_fini;
      end
      else begin
       mo1:= mo_decref;
      end;
      writemanagedtypeop(mo1,instancetype1,adref1);
     end;
     with additem(oc_destroyclass)^ do begin //insertitem???
      par.ssas1:= d.dat.fact.ssaindex;
      par.destroyclass.flags:= [];
     { 
      if dsf_nofreemem in aflags then begin
       include(par.destroyclass.flags,dcf_nofreemem);
      end;
     }
     end;
    end;
    if dsf_indirect in aflags then begin
     if hasresult then begin
      with additem(oc_movestack)^ do begin //move result to calladdress
       par.swapstack.offset:= -pointersize;
       par.swapstack.size:= resultsize;
      end;
     end;
     with additem(oc_pop)^ do begin          //insertitem???
      setimmsize(pointersize,par.imm); //remove call address
     end;
    end;
    if co_mlaruntime in o.compileoptions then begin
//     releasetempaddress(tempsize);
     locdatapo:= locdatapo - resultsize;
    end;
    if (sf_constructor in asub^.flags) then begin
     callclasssubattach(instancetype1^.infoclass.subattach.afterconstruct);
    end;
   end;
  end;
  if aflags*[dsf_objini,dsf_objfini] <> [] then begin
   if co_mlaruntime in o.compileoptions then begin
    with additem(oc_push)^ do begin
     par.imm.vsize:= pointersize;    //compensate stack pop
    end;
   end;
  end;
 end;
end;

function getselfvar(out aele: elementoffsetty): boolean;
begin
 result:= ele.findcurrent(tks_self,[],allvisi,aele);
                       //todo: what about variables with name "self"?
end;

//todo: simplify, use unified indirection handling
procedure handlevalueidentifier();
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
// getfactflags: factflagsty;
 isinherited: boolean;
 isgetfact: boolean;
 subflags: dosubflagsty;
 poind,pob,potop: pcontextitemty;
  
// procedure donotfound(const typeele: elementoffsetty);
 procedure donotfound(const adatacontext: pcontextitemty;
                                               const atype: elementoffsetty);

  procedure pushclassdef(const atyp: ptypedataty);
  begin
  {$ifdef mse_checkinternalerror}
   if not (atyp^.h.kind in [dk_object,dk_class]) then begin
    internalerror(ie_handler,'20170510A');
   end;
  {$endif} 
   with insertitem(oc_pushsegaddr,adatacontext,-1,
                           pushsegaddrssaar[seg_classdef])^ do begin
    par.memop.segdataaddress.a:= atyp^.infoclass.defs;
    par.memop.segdataaddress.offset:= 0;
    par.memop.t:= bitoptypes[das_pointer];
   end;
   initfactcontext(adatacontext);
   adatacontext^.d.dat.fact.opdatatype:= bitoptypes[das_pointer];
   include(subflags,dsf_instanceonstack);
  end;//pushclassdef
  
 var
  offs1: dataoffsty;
  ele1,ele2: elementoffsetty;
  pvar1: pvardataty;
  int1: integer;
  po4: pointer;
  subflags1: subflagsty;
  typ1: ptypedataty;
  i2: int32;
//  pind: pcontextitemty;
 begin //donotfond
  if firstnotfound <= idents.high then begin
   ele1:= basetype(atype);
   offs1:= 0;
   with info do begin
//    pind:= @contextstack[s.stackindex];
    for int1:= firstnotfound to idents.high do begin //fields
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
          if typ1^.h.kind = dk_class then begin
//          if af_classfield in flags then begin
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
        {$ifdef mse_checkinternalerror}
         else begin
          internalerror(ie_value,'20151207B');
         end;
        {$endif}
        end;
       end;       
      end;
      ek_sub: begin
       if int1 <> idents.high then begin
        errormessage(err_illegalqualifier,[],int1+1,0,erl_fatal);
        exit;
       end;
       case po1^.header.kind of
        ek_var: begin //todo: check class procedures
         pvar1:= eletodata(po1);
         subflags1:= psubdataty(po4)^.flags;
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
          if not getvalue(adatacontext,das_none) then begin 
                                             //get class instance
           exit;
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
              include(subflags,dsf_instanceonstack);
             end
             else begin
              pushclassdef(typ1);
             end;
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
        ek_type: begin
        {???
         if not (sf_constructor in psubdataty(po4)^.flags) then begin
          errormessage(err_classref,[],int1+1);
          exit;
         end;
        }
//         pushinsert(0,-1,sysdatatypes[st_pointer],nilad,0);
         if not (stf_getaddress in info.s.currentstatementflags) and 
               not (sf_constructor in psubdataty(po4)^.flags) then begin
          pushclassdef(eletodata(po1));
         end;
        end;
        else begin
         internalerror1(ie_notimplemented,'20140417A');
        end;
       end;
       dosub(s.stackindex,psubdataty(po4),paramstart,paramco,subflags);
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
 end;//donotfound
 
 function checknoclassmethod(const aitem: pelementinfoty): boolean;
 var
  p1,p2: pelementinfoty;
 begin
  result:= not (stf_classmethod in info.s.currentstatementflags) or
    (aitem^.header.kind = ek_sub) and 
        (sf_classmethod in psubdataty(eletodata(aitem))^.flags);
     
  if not result then begin
   p2:= ele.eleinfoabs(aitem^.header.parent);
   p1:= ele.eleinfoabs(info.currentclass);
   while true do begin
    if p1 = p2 then begin
     errormessage(err_classmethod,[]);
     exit;
    end;
    if (p1^.header.parent = 0) then begin
     break; //not element of current class
    end;
    p1:= ele.eledataabs(po1^.header.parent);
    if p1^.header.kind <> ek_type then begin
     break; //not element of current class
    end;
   end;
   result:= true;
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
// offs1: dataoffsty;
// indilev1: indirectlevelty;
 stacksize1: datasizety;
 paramco1: integer;
 origparent: elementoffsetty;
 ssabefore: int32;
 pocontext1: pcontextitemty;
 i1,i2: int32;
 bo1: boolean;
 
label
 endlab;
begin
{$ifdef mse_debugparser}
 outhandle('VALUEIDENTIFIER');
{$endif}
 with info do begin
  ele.pushelementparent();
  isgetfact:= false;
  poind:= @contextstack[s.stackindex];
  pob:= poind-1;
  potop:= @contextstack[s.stacktop];
  with pob^ do begin
//   if d.kind = ck_ref then begin
//    if not checkdatatypeconversion(pob) then begin
//     goto endlab;
//    end;
//    if not checkreftypeconversion(pob) then begin
//     goto endlab;
//    end;
//   end
//   else begin
//    if d.kind in [ck_fact,ck_subres] then begin
//     if not checkdatatypeconversion(pob) then begin
//      goto endlab;
//     end;
//    end
//   end;
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
  bo1:= findkindelements(1,[],allvisi+[vik_stoponstarttype],po1,
                                                     firstnotfound,idents);
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
    identerror(1,err_identifiernotfound);
   end;
   goto endlab;
  end;
  subflags:= [];
  if isinherited then begin
   include(subflags,dsf_isinherited);
  end;
  if (idents.high = 0) and 
            not (pob^.d.kind in factcontexts) then begin
//      ((pob^.d.kind = ck_fact) and (pob^.d.dat.indirection < 0)) then begin
                                             //correct?
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
//        initfactcontext(0);
        initdatacontext(poind^.d,ck_ref);
        d.dat.datatyp.typedata:= vf.typ;
        d.dat.datatyp.indirectlevel:= indirectlevel;
        d.dat.datatyp.flags:= vf.flags;
        d.dat.indirection:= -1;
        d.dat.ref.c.address:= pvardataty(ele.eledataabs(ele2))^.address;
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
          ck_fact: begin
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
//        d:= contextstack[s.stackindex-1].d;
                  //todo: no double copy by handlefact
       end;
       donotfound(pocontext1,pocontext1^.d.dat.datatyp.typedata);
      end;
     end
     else begin //ek_var
      if isgetfact then begin
       initdatacontext(poind^.d,ck_ref);
       d.dat.ref.c.address:= trackaccess(pvardataty(po2));
       d.dat.ref.offset:= 0;
       d.dat.ref.c.varele:= ele.eledatarel(po2); //used to store ssaindex
       d.dat.datatyp.typedata:= pvardataty(po2)^.vf.typ;
       d.dat.datatyp.indirectlevel:= pvardataty(po2)^.address.indirectlevel;
       d.dat.datatyp.flags:= [];
       if d.dat.ref.c.address.flags *
                          [af_paramindirect,af_withindirect] <> [] then begin
        d.dat.ref.c.address.flags:= d.dat.ref.c.address.flags-
                                       [af_paramindirect,af_withindirect];
        dec(d.dat.indirection);
        dec(d.dat.datatyp.indirectlevel);
       end;
       pocontext1:= poind;
      end
      else begin
       with contextstack[s.stackindex-1] do begin
        if d.dat.indirection <> 0 then begin
         getaddress(pob,false);
         dec(d.dat.indirection); //pending dereference
        end;
        pocontext1:= poind - 1;
//        poind^.d:= d; 
                  //todo: no double copy by handlefact
       end;
      end;
      if pvardataty(po2)^.vf.typ <= 0 then begin
       goto endlab; //todo: stop error earlier
      end;
      donotfound(pocontext1,pvardataty(po2)^.vf.typ); 
                                  //todo: call of sub function results
      if (stf_params in s.currentstatementflags) and
                           (d.kind in datacontexts) then begin
       if getvalue(poind,das_none) then begin
        po3:= ele.eledataabs(d.dat.datatyp.typedata);
        if (d.dat.datatyp.indirectlevel = 0) and 
                              (po3^.h.kind in [dk_sub,dk_method]) then begin
         include(subflags,dsf_indirect);
         if po3^.h.kind = dk_method then begin
          include(subflags,dsf_instanceonstack);
         end;
         dosub(s.stackindex,ele.eledataabs(po3^.infosub.sub),
                                         paramstart,paramco,subflags);
        end;
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
     if isgetfact then begin
      i1:= s.stackindex;
     end
     else begin
      i1:= s.stackindex-1;
     end;
     dosub(i1,psubdataty(po2),paramstart,paramco,subflags);
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
         
       {
         errormessage(err_illegalexpression,[],s.stacktop-s.stackindex);
       }
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
         if (potop^.d.kind = ck_ref) then begin
          linkaddcast(ele.eledatarel(po2),potop);
          po3:= ele.eledataabs(potop^.d.dat.datatyp.typedata);
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
//          potop^.d.dat.datatyp.indirectlevel:= 
//                  potop^.d.dat.datatyp.indirectlevel + 
//                                      (h.indirectlevel - po3^.h.indirectlevel);
          bo1:= false;
{
          po3:= ele.eledataabs(potop^.d.dat.datatyp.typedata);
          i1:= h.bytesize;
          i2:= po3^.h.bytesize;
          if h.indirectlevel > 0 then begin
           i1:= pointersize;
          end;
          if potop^.d.dat.datatyp.indirectlevel > 0 then begin
           i2:= pointersize;
          end;
          if i1 = i2 then begin
           if getaddress(potop,true) then begin
            potop^.d.dat.datatyp.indirectlevel:= 
                      po3^.h.indirectlevel - h.indirectlevel - 1;
            dec(potop^.d.dat.indirection);
            potop^.d.dat.datatyp.typedata:= ele.eledatarel(po2);
            potop^.d.dat.datatyp.flags:= h.flags;
            bo1:= false;
           end;
          end
          else begin
           errormessage(err_typecastdifferentsize,[i2,i1]);
          end;
         end;
         if bo1 then begin
         }
         end
         else begin
 //        if getvalue(potop,das_none,true) then begin
          bo1:= not tryconvert(potop,po2,
                      ptypedataty(po2)^.h.indirectlevel,[coo_type]);
          if bo1 then begin
           illegalconversionerror(potop^.d,po2,
                                       ptypedataty(po2)^.h.indirectlevel);
          end;
         end;
         if not bo1 then begin
          poind^.d:= potop^.d; //big copy!
//          contextstack[s.stackindex].d.kind:= ck_space;
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
{
      if value.kind = dk_none then begin
       errormessage(err_definehasnovalue,[]);
       goto endlab;
      end;
}
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
                     //todo: use something more elegant
   s.stacktop:= s.stackindex;
   pob^.context:= nil;
/////////////////////////////////////////////   pob^.context:= @dummyco;
  end;
 end;
end;

end.
