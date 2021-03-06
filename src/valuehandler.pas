{ MSElang Copyright (c) 2013-2018 by Martin Schreiber
   
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
 convertoptionty = (coo_type,coo_enum,{coo_boolean,}coo_character,
                    coo_set,coo_nomincheck,
                    coo_notrunc,coo_errormessage,coo_paramindirect);
 convertoptionsty = set of convertoptionty;
 compatibilitycheckoptionty = (cco_novarconversion);
 compatibilitycheckoptionsty = set of compatibilitycheckoptionty;
 
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

function listtoset(const acontext: pcontextitemty; adest: ptypedataty;
          out lastitem: pcontextitemty): boolean;
function listtoopenarray(const acontext: pcontextitemty;
                          const aitemtype: ptypedataty; 
                                  out lastitem: pcontextitemty;
                                  paramindirect: boolean): boolean;
function listtoarrayofconst(const acontext: pcontextitemty;
                                  out lastitem: pcontextitemty;
                                  const paramindirect: boolean): boolean;
function checkcompatibleset(const asourcecontext: pcontextitemty;
                            const source,dest: ptypedataty;
                                   const nomincheck: boolean = false): boolean;

implementation
uses
 errorhandler,elements,handlerutils,opcode,stackops,segmentutils,opglob,
 subhandler,unithandler,syssubhandler,classhandler,interfacehandler,
 controlhandler,identutils,msestrings,handler,managedtypes,elementcache,
 __mla__internaltypes,exceptionhandler,listutils,llvmlists,grammarglob,
 parser,compilerunit,mseformatstr;

function listtoset(const acontext: pcontextitemty; adest: ptypedataty;
          out lastitem: pcontextitemty): boolean;
var
 i1,i2: int32;
 type1,type2,type3: ptypedataty;
 ca1,ca2: card32;
 op1: popinfoty;
 poe,poitem: pcontextitemty;
 min1,max1: int32;
 datasize1: databitsizety;
 bigset1: bigsetbufferty;
 maxitemindex1: int32;
 minitemindex1: int32;
 ra1: ordrangety;
 b1: boolean;
 p1: pcard8;
 m1: card8;
 lastvalue: int32;
 rangestart: pcontextitemty;
 sv1: stringvaluety;
 mark1: opmarkty;
 si1: databitsizety;
begin
 ele.checkcapacity(ek_type,2,adest);
 if (adest = nil) or (adest^.h.datasize = das_none) then begin
  datasize1:= das_32; //todo: $packset
  minitemindex1:= 0;
  maxitemindex1:= maxsetelementcount-1;
 end
 else begin
 {$ifdef mse_checkinternalerror}
  if adest^.h.kind <> dk_set then begin
   internalerror(ie_handler,'20181116A');
  end;
 {$endif}
  datasize1:= adest^.h.datasize;
  minitemindex1:= adest^.infoset.itemstart;
  maxitemindex1:= minitemindex1+adest^.infoset.itemcount-1;
 end;
{$ifdef mse_checkinternalerror}
 if acontext^.d.kind <> ck_list then begin
  internalerror(ie_handler,'20160610A');
 end;
 if not (datasize1 in [das_8,das_16,das_32,das_bigint]) then begin
  internalerror(ie_handler,'20181114E');
 end;
{$endif}
 result:= false;
 poe:= acontext + acontext^.d.list.contextcount;
 if acontext^.d.list.itemcount = 0 then begin //empty set
  initdatacontext(acontext^.d,ck_const);
  with acontext^ do begin
   d.dat.datatyp:= emptyset;
   with d.dat.constval do begin
    kind:= dk_set;
    vset.min:= 0;
    vset.max:= -1;
    vset.kind:= das_32;
    vset.setvalue:= 0;
   end;
  end;
 end
 else begin
  type2:= nil;
  ca1:= 0;
  min1:= maxint;
  max1:= -1;
  rangestart:= nil;
  fillchar(bigset1[4],sizeof(bigset1)-4,0);
  poitem:= acontext+1;
  while poitem < poe do begin
   with poitem^ do begin
    if d.kind <> ck_space then begin
    {$ifdef mse_checkinternalerror}
     if not (d.kind in datacontexts) then begin
      internalerror(ie_handler,'20151007A');
     end;
    {$endif}
     type1:= ele.eledataabs(basetype(d.dat.datatyp.typedata));
     if (d.kind = ck_const) and (type1^.h.kind = dk_string) then begin
      if tryconvert(poitem,st_char32) then begin
       type1:= ele.eledataabs(basetype(d.dat.datatyp.typedata));
      end;
     end;
     if type2 = nil then begin
      type2:= type1;
     end;
     if not (type1^.h.kind in (ordinaldatakinds+[dk_character])) or 
                                  (type1^.h.indirectlevel <> 0) then begin
      errormessage(err_ordinalexpexpected,[],poitem);
      exit;
     end;
     if type1^.h.datasize = das_64 then begin
      errormessage(err_invalidsetele,[],poitem);
      exit;
     end;
     if (type1 <> type2) and not 
      ((type1^.h.kind in [dk_cardinal,dk_integer]) and 
                    (type2^.h.kind in [dk_cardinal,dk_integer]) or
        (type1^.h.kind = dk_character) and 
                    (type1^.h.kind = dk_character)) then begin
      incompatibletypeserror(type2,type1,poitem);
      exit;
     end;
     case d.kind of 
      ck_const: begin
       case d.dat.constval.kind of
        dk_character: begin
         i1:= d.dat.constval.vcharacter;
         if i1 < 0 then begin
          i1:= bigint;
         end;
        end;
        dk_cardinal: begin
         i1:= d.dat.constval.vcardinal;
         if i1 < 0 then begin
          i1:= bigint;
         end;
        end;
        dk_integer: begin
         i1:= d.dat.constval.vinteger;
        end;
        dk_enum: begin
         i1:= d.dat.constval.venum.value;
        end;
        else begin
         internalerror1(ie_handler,'20181120A');
        end;
       end;
       if i1 < min1 then begin
        min1:= i1;
       end;
       if i1 > max1 then begin
        max1:= i1;
       end;
       if hf_range in d.handlerflags then begin
        rangestart:= poitem;
        lastvalue:= i1;
       end
       else begin
        i2:= i1;
        if rangestart <> nil then begin
         if rangestart^.d.kind = ck_const then begin
          i2:= lastvalue;
          if i2 > i1 then begin
           errormessage(err_highlowerlow,[],poitem);
           exit;
          end;
         end
         else begin
          if not getvalue(poitem,das_none) then begin
           exit;
          end;
          i2:= bigint; //handle in variable loop
         end;
        end;
        for i1:= i2 to i1 do begin
         if i1 < sizeof(ca2)*8 then begin
          ca2:= 1 shl i1;
          if ca1 and ca2 <> 0 then begin
           errormessage(err_duplicatesetelement,[],poitem);
           exit;
          end;
          ca1:= ca1 or ca2;
         end
         else begin
          if i1 < sizeof(bigset1)*8 then begin
           p1:= @bigset1[i1 div 8];
           m1:= bytebits[i1 and $7];
           if p1^ and m1 <> 0 then begin
            errormessage(err_duplicatesetelement,[],poitem);
            exit;
           end;
           p1^:= p1^ or m1;
          end;
         end;
        end;
        rangestart:= nil;
       end;
      end
      else begin
       if not getvalue(poitem,das_32) then begin
        exit;
       end;
       if rangestart <> nil then begin
        if not getvalue(rangestart,das_none) then begin
         exit;
        end;
       end;
       getordrange(type1,ra1);
       if int32(ra1.min) < min1 then begin
        min1:= int32(ra1.min);
       end;
       if int32(ra1.max) > max1 then begin
        max1:= int32(ra1.max);
       end;
       if hf_range in d.handlerflags then begin
        rangestart:= poitem;
       end;
      end;
      if min1 < minitemindex1 then begin
       errormessage(err_minseteleallowed,[minitemindex1],poitem);
       exit;
      end;
      if max1 > maxitemindex1 then begin
       errormessage(err_maxseteleallowed,[maxitemindex1+1],poitem);
       exit;
      end;
     end; 
    end;
   end;
   inc(poitem);
  end;
  if type2^.h.kind in [dk_cardinal,dk_integer,dk_character] then begin
   getordrange(type2,ra1);
   if (ra1.min <> min1) or (ra1.max <> max1) then begin
    type3:= ele.addelementdata(getident(),ek_type,[]);
    si1:= das_32;
    if max1 <= $100 then begin
     si1:= das_8;
    end
    else begin
     if max1 < $10000 then begin
      si1:= das_16;
     end;
    end;
    if type2^.h.kind = dk_character then begin
     inittypedatasize(type3^,dk_character,0,si1);
     case si1 of
      das_8: begin
       with type3^.infochar8 do begin
        min:= min1;
        max:= max1;
       end;
      end;
      das_16: begin
       with type3^.infochar16 do begin
        min:= min1;
        max:= max1;
       end;
      end;
      das_32: begin
       with type3^.infochar32 do begin
        min:= min1;
        max:= max1;
       end;
      end;
     end;
    end
    else begin
     inittypedatasize(type3^,dk_cardinal,0,si1);
     case si1 of
      das_8: begin
       with type3^.infocard8 do begin
        min:= min1;
        max:= max1;
       end;
      end;
      das_16: begin
       with type3^.infocard16 do begin
        min:= min1;
        max:= max1;
       end;
      end;
      das_32: begin
       with type3^.infocard32 do begin
        min:= min1;
        max:= max1;
       end;
      end;
     end;
    end;
    type2:= type3;  //anonymous item type
   end;
  end;
  type1:= ele.addelementdata(getident(),ek_type,[]); //anonymous set type
  b1:= max1 >= 32;
  if b1 then begin
   inittypedatasize(type1^,dk_set,0,das_bigint);
   type1^.h.bytesize:= (max1+8) div 8;
   type1^.h.bitsize:= type1^.h.bytesize * 8;
  end
  else begin
   inittypedatasize(type1^,dk_set,0,das_32);
  end;
  with type1^.infoset do begin
   itemtype:= ele.eledatarel(type2);
   itemstart:= min1;
   itemcount:= max1+1;
  end;
  if b1 then begin
   pcard32(@bigset1)^:= ca1;
   sv1:= newbigintconst(@bigset1,max1+1);
  end;
  if lf_allconst in acontext^.d.list.flags then begin
   initdatacontext(acontext^.d,ck_const);
   with acontext^.d.dat.constval do begin
    kind:= dk_set;
    vset.min:= min1;
    vset.max:= max1;
    if b1 then begin
     vset.bigsetvalue:= sv1;
     vset.kind:= das_bigint;
    end
    else begin
     vset.kind:= das_32;
     vset.setvalue:= ca1;
    end;
   end;
  end
  else begin
   if b1 then begin
    with insertitem(oc_pushimmbigintindi,poe,-1)^ do begin
     setimmbigintindi(sv1,par.imm);
     i2:= par.ssad;
    end;
   end
   else begin
    with insertitem(oc_pushimm32,poe,-1)^ do begin 
     setimmint32(ca1,par.imm);
     i2:= par.ssad;
    end;
   end;
   lastvalue:= -1;
   poitem:= acontext+1;
   while poitem < poe do begin
    with poitem^ do begin
     if not (poitem^.d.kind in [ck_space,ck_const]) then begin
     {$ifdef mse_cehckinternalerror}
      if not (poitem^.d.kind in factcontexts) then begin
       internalerror(ie_handler,'20181120C');
      end;
     {$endif}
      i1:= d.dat.fact.ssaindex;
      if hf_range in d.handlerflags then begin
       lastvalue:= i1;
      end
      else begin
       if lastvalue >= 0 then begin
        op1:= insertitem(oc_setbitrange,poe,-1);
        op1^.par.ssas3:= lastvalue;
        lastvalue:= -1;
       end
       else begin
        op1:= insertitem(oc_setbit,poe,-1);
       end;
       with op1^ do begin //last op
        par.stackop.t:= getopdatatype(type1,0);
        updatesetstackop(par,type1,ele.eledataabs(d.dat.datatyp.typedata));
        par.ssas1:= i2;
        par.ssas2:= i1;
        i2:= par.ssad;
       end;
      end;
     end;
    end;
    inc(poitem);
   end;
   initdatacontext(acontext^.d,ck_fact);
   acontext^.d.dat.fact.ssaindex:= i2;
  end;
  with acontext^ do begin
   d.dat.datatyp.flags:= [];
   d.dat.datatyp.typedata:= ele.eledatarel(type1);
   d.dat.datatyp.indirectlevel:= 0;
  end;
 end;
 mark1:= getcontextopmark(poe);
 poitem:= acontext+1;
 while poitem < poe do begin
  poitem^.opmark:= mark1;    //move ops to result context
  poitem^.d.kind:= ck_space;
  inc(poitem);
 end;
 lastitem:= poitem-1;
 result:= true;
{$ifdef mse_debugparser}
 outhandle('after LISTTOSET');
{$endif}
end;

function listtoopenarray(const acontext: pcontextitemty;
                          const aitemtype: ptypedataty; 
                                  out lastitem: pcontextitemty;
                                  paramindirect: boolean): boolean;
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
 op1: opcodety;
 
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
   paramindirect:= false;     //todo: indirectlevel
   initdatacontext(d,ck_const);
   i1:= itemtype1^.h.bytesize;
   if itemtype1^.h.kind = dk_string then begin
    i1:= sizeof(stringvaluety);
   end;
   podata1:= initopenarrayconst(d.dat.constval,itemcount1,i1,itemtype1^.h.kind);
   poitem1:= acontext+1;
   case itemtype1^.h.datasize of //todo: endianess
    das_32: begin
     while poitem1 < poe do begin
      if poitem1^.d.kind <> ck_space then begin
       pv32ty(podata1)^:= pv32ty(@poitem1^.d.dat.constval.vdummy)^;
                                        //??? endianess
       inc(pv32ty(podata1));
       poitem1^.d.kind:= ck_space;
      end;
      inc(poitem1);
     end;
    end;
    das_pointer: begin
     if itemtype1^.h.kind = dk_string then begin
      while poitem1 < poe do begin
       if poitem1^.d.kind <> ck_space then begin
        pstringvaluety(podata1)^:= pstringvaluety(
                                      @poitem1^.d.dat.constval.vdummy)^;
        inc(pstringvaluety(podata1));
        poitem1^.d.kind:= ck_space;
       end;
       inc(poitem1);
      end;
     end
     else begin
      while poitem1 < poe do begin
       if poitem1^.d.kind <> ck_space then begin
        pvpoty(podata1)^:= pvpoty(@poitem1^.d.dat.constval.vdummy)^;
        inc(pvpoty(podata1));
        poitem1^.d.kind:= ck_space;
       end;
       inc(poitem1);
      end;
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
   op1:= oc_listtoopenar;
   if paramindirect then begin
    op1:= oc_listtoopenarad;
   end;
   with insertitem(op1,poitem1,0,
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
  if paramindirect then begin
   d.dat.datatyp.indirectlevel:= 1;
 //  d.dat.indirection:= -1;
  end;
 end;
 result:= true;
end;

function listtoarrayofconst(const acontext: pcontextitemty;
                                  out lastitem: pcontextitemty;
                                  const paramindirect: boolean): boolean;
var
 poe: pointer;
 poitem1,poparams: pcontextitemty;
 typ1: ptypedataty;
 alloc1: dataoffsty;
 poalloc: parrayofconstitemallocinfoty;
 itemcount1: int32;
 i1: int32;
 datasize1: databitsizety;
 op1: opcodety;
 
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
     poalloc^.valuefunc:= cs_pointertovarrecty;
    end;
   {$endif}
    datasize1:= das_none;
    typ1:= ele.eledataabs(d.dat.datatyp.typedata);
    poalloc^.typid:= ord(das_none); //direct value, use pointer otherwise
    if d.dat.datatyp.indirectlevel > 0 then begin
     poalloc^.valuefunc:= cs_pointertovarrecty;
     datasize1:= das_pointer;
    end
    else begin
     case typ1^.h.kind of
      dk_none: begin //nil constant
       poalloc^.valuefunc:= cs_pointertovarrecty;
       datasize1:= das_pointer;
      end;
      dk_integer: begin
       if typ1^.h.datasize = das_64 then begin
        datasize1:= das_64;
        poalloc^.valuefunc:= cs_int64tovarrecty;
        poalloc^.typid:= ord(das_64); //use pointer
       end
       else begin
        if not tryconvert(poitem1,st_int32,[coo_errormessage]) then begin
         exit;
        end;
        datasize1:= das_32;
        poalloc^.valuefunc:= cs_int32tovarrecty;
       end;
      end;
      dk_cardinal: begin
       if typ1^.h.datasize = das_64 then begin
        datasize1:= das_64;
        poalloc^.valuefunc:= cs_card64tovarrecty;
        poalloc^.typid:= ord(das_64); //use pointer
       end
       else begin
        if not tryconvert(poitem1,st_card32,[coo_errormessage]) then begin
         exit;
        end;
        datasize1:= das_32;
        poalloc^.valuefunc:= cs_card32tovarrecty;
       end;
      end;
      dk_float: begin
       if not tryconvert(poitem1,st_flo64,[coo_errormessage]) then begin
        exit;
       end;
       datasize1:= das_f64;
       poalloc^.valuefunc:= cs_flo64tovarrecty;
       poalloc^.typid:= ord(das_f64); //use pointer
      end;
      dk_character: begin
       if not tryconvert(poitem1,st_char32,[coo_errormessage]) then begin
        exit;
       end;
       datasize1:= das_32;
       poalloc^.valuefunc:= cs_char32tovarrecty;
      end;
      dk_string: begin
       case typ1^.itemsize of
        1: begin
         poalloc^.valuefunc:= cs_string8tovarrecty;
        end;
        2: begin
         poalloc^.valuefunc:= cs_string16tovarrecty;
        end;
        4: begin
         poalloc^.valuefunc:= cs_string32tovarrecty;
        end;
        else begin
         internalerror1(ie_handler,'20180517A');
        end;
       end;
      end;
      else begin
       errormessage(err_wrongarrayitemtype,[typename(typ1^)],poitem1);
       exit;
      end;
     end;
    end;
    if not getvalue(poitem1,datasize1,false) then begin
     exit;
    end;
   {$ifdef mse_checkinternalerror}
    if not (d.kind in factcontexts) then begin
     internalerror(ie_handler,'20160615A');
    end;
   {$endif}
    poalloc^.ssaoffs:= d.dat.fact.ssaindex;
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
 op1:= oc_listtoarrayofconst;
 if paramindirect then begin
  op1:= oc_listtoarrayofconstad;
 end;
 with acontext^,insertitem(op1,poitem1,0,
             itemcount1*getssa(ocssa_listtoarrayofconstitem))^ do begin
                                     //at start of next context
  if info.s.trystacklevel > 0 then begin
   inc(info.s.ssa.bbindex,itemcount1); //per item compilersub call
  end;
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
  d.dat.datatyp.typedata:= internaltypes[it_varrec];
  d.dat.datatyp.indirectlevel:= 0;
  if paramindirect then begin
   d.dat.datatyp.indirectlevel:= 1;
//   d.dat.indirection:= -1;
  end;
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
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_card8tocard16,oc_none,
  //das_32,         das_33_63,das_64,           
    oc_card8tocard32,oc_none,  oc_card8tocard64,
  //das_pointer,das_f16,das_f32,das_f64, das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none, oc_none,   oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_card16tocard8,oc_none, oc_none,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card16tocard32,oc_none,  oc_card16tocard64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card32tocard8,oc_none, oc_card32tocard16,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_card32tocard64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card64tocard8,oc_none, oc_card64tocard16,oc_none,
  //das_32,          das_33_63, das_64,             
    oc_card64tocard32,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  )
 );

 inttoint: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16,        das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_int8toint16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int8toint32,oc_none,  oc_int8toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_int16toint8,oc_none, oc_none,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int16toint32,oc_none,  oc_int16toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int32toint8,oc_none, oc_int32toint16,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_int32toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_mta
    oc_none,    oc_none,oc_none,oc_none,oc_none,oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int64toint8,oc_none, oc_int64toint16,oc_none,
  //das_32,          das_33_63, das_64,             
    oc_int64toint32,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,oc_none,oc_none
  )
 );

 cardtoint: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_card8toint8,oc_none, oc_card8toint16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_card8toint32,oc_none,  oc_card8toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigin,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,  oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card16toint8,oc_none, oc_card16toint16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card16toint32,oc_none,  oc_card16toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card32toint8,oc_none, oc_card32toint16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card32toint32,oc_none,  oc_card32toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card64toint8,oc_none, oc_card64toint16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card64toint32,oc_none,  oc_card64toint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  )
 );

 inttocard: convertsizetablety = (
  (//ibs_none
  //das_none,das_1,  das_2_7,das_8,  das_9_15,das_16, das_17_31,
    oc_none, oc_none,oc_none,oc_none,oc_none, oc_none,oc_none,
  //das_32, das_33_63,das_64,             
    oc_none,oc_none,  oc_none,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_8
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int8tocard8,oc_none, oc_int8tocard16,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int8tocard32,oc_none,  oc_int8tocard64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_16
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_int16tocard8,oc_none, oc_int16tocard16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int16tocard32,oc_none,  oc_int16tocard64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_32
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_int32tocard8,oc_none, oc_int32tocard16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int32tocard32,oc_none,  oc_int32tocard64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//ibs_64
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_int64tocard8,oc_none, oc_int64tocard16,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_int64tocard32,oc_none,  oc_int64tocard64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  )
 );

 convtoflo32: convertnumtablety = (
  (//unsigned
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card8toflo32,oc_none, oc_card16toflo32,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card32toflo32,oc_none,  oc_card64toflo32,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//signed
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int8toflo32,oc_none, oc_int16toflo32,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int32toflo32,oc_none,  oc_int64toflo32,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  )
 );

 convtoflo64: convertnumtablety = (
  (//unsigned
  //das_none,das_1,  das_2_7,das_8,          das_9_15,das_16,          das_17_31,
    oc_none, oc_none,oc_none,oc_card8toflo64,oc_none, oc_card16toflo64,oc_none,
  //das_32,          das_33_63,das_64,             
    oc_card32toflo64,oc_none,  oc_card64toflo64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  ),
  (//signed
  //das_none,das_1,  das_2_7,das_8,         das_9_15,das_16,         das_17_31,
    oc_none, oc_none,oc_none,oc_int8toflo64,oc_none, oc_int16toflo64,oc_none,
  //das_32,         das_33_63,das_64,             
    oc_int32toflo64,oc_none,  oc_int64toflo64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,   oc_none,oc_none
  )
 );

 potointops: array[databitsizety] of opcodety = (
  //das_none,das_1,  das_2_7,das_8,      das_9_15,das_16,      das_17_31,
    oc_none, oc_none,oc_none,oc_potoint8,oc_none, oc_potoint16,oc_none,
  //das_32,      das_33_63,das_64,             
    oc_potoint32,oc_none,  oc_potoint64,
  //das_pointer,das_f16,das_f32,das_f64,das_bigint,das_sub,das_meta
    oc_none,    oc_none,oc_none,oc_none,oc_none,oc_none,oc_none
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

function checkcompatibleset(const asourcecontext: pcontextitemty;
                                    const source,dest: ptypedataty; 
                                   const nomincheck: boolean = false): boolean;
var
 source1,dest1: ptypedataty;
 ra1,ra2: ordrangety;
 buf1: bigsetbufferty;
 s1: lstringty;
 i1: int32;
label
 nocopylab;
begin
{$ifdef mse_checkinternalerror}
 if (source^.h.kind <> dk_set) or (dest^.h.kind <> dk_set) then begin
  internalerror(ie_handler,'20181119B');
 end;
{$endif}
 if dest^.infoset.itemtype = 0 then begin
  result:= source^.infoset.itemtype = 0;
  exit; //empty set
 end;
 dest1:= ele.eledataabs(dest^.infoset.itemtype);
 if source^.infoset.itemtype = 0 then begin
  source1:= nil; //empty set
 end
 else begin
  source1:= ele.eledataabs(source^.infoset.itemtype);
 end;
{$ifdef mse_checkinternalerror}
 if dest1^.h.bytesize > sizeof(buf1) then begin
  internalerror(ie_handler,'20181119C');
 end;
{$endif}
 result:= (source1 <> nil) and issametype(source1,dest1);
 if not result then begin
  case dest1^.h.kind of
   dk_cardinal,dk_integer,dk_character: begin
    if (source1 = nil) or
          (source1^.h.kind in [dk_cardinal,dk_integer,dk_character]) then begin
     getordrange(dest1,ra1);
     if asourcecontext^.d.kind = ck_const then begin
      with asourcecontext^.d.dat.constval.vset do begin
       result:= (nomincheck or (min >= ra1.min)) and (max <= ra1.max);
       if result then begin
        if dest^.h.datasize = das_bigint then begin
         if source^.h.datasize = das_bigint then begin
          if (dest^.h.bytesize > source^.h.bytesize) then begin
           s1:= getstringconst(bigsetvalue);
           move(s1.po^,buf1,s1.len);
           fillchar(buf1[s1.len],dest^.h.bytesize-s1.len,0);
          end
          else begin
           goto nocopylab;
          end;
         end
         else begin //source is not das_bigint
          kind:= das_bigint;
          pint32(@buf1)^:= setvalue;
          fillchar(buf1[sizeof(int32)],dest^.h.bytesize-sizeof(int32),0);
         end;
         bigsetvalue:= newbigintconst(@buf1,dest^.h.bitsize);
        end;
nocopylab:
        max:= ra1.max;
        if min > ra1.min then begin
         min:= ra1.min;
        end;
        asourcecontext^.d.dat.datatyp.typedata:= ele.eledatarel(dest);
       end;
      end;
     end
     else begin
      getordrange(source1,ra2);
      result:= (ra2.min >= ra1.min) and (ra2.max <= ra1.max);
      if result and (ra2.max < ra1.max) and 
                          getvalue(asourcecontext,das_none) then begin
       i1:= asourcecontext^.d.dat.fact.ssaindex;
       with insertitem(oc_setexpand,asourcecontext,-1)^ do begin
        par.ssas1:= i1;
        par.stackop.t:= getopdatatype(dest,0);
       end;
      end;
     end;
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
  result:= false;
  if acontext^.d.dat.indirection <> 0 then begin
   if not getvalue(acontext,das_none) then begin
    exit;
   end;
  end;
  if (coo_notrunc in aoptions) and (intbits[source1^.h.datasize] >
                                           intbits[dest^.h.datasize]) then begin
   exit;
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
 end; //checkancestorclass

 function checkcharacterrange(): boolean;
 var
  ra1: ordrangety;
 begin
  result:= true;
  getordrange(dest,ra1);
  with acontext^ do begin
   if (ra1.min > d.dat.constval.vcharacter) or 
           (ra1.max < d.dat.constval.vcharacter) then begin
    result:= false;
    if coo_errormessage in aoptions then begin
     errormessage(err_valuerange,
               [hextostr(card64(ra1.min),0),hextostr(card64(ra1.max),0)],
                                                                   acontext);
    end;
   end;
  end;
 end; //checkcharacterrange 
 
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
 fl1: stringflagsty;
 ra1: ordrangety;
 bigset1: bigsetbufferty;
 
label
 sizeconvlab,endlab; 
begin //tryconvert
 result:= false;
 with info do begin
//  if not checkreftypeconversion(acontext) then begin
//   exit;
//  end;
  stackoffset:= getstackoffset(acontext);
  needsmanagedtemp:= false;
  if acontext^.d.kind = ck_list then begin
   case dest^.h.kind of
    dk_set{,dk_bigset}: begin
     if not listtoset(acontext,dest,lastitem) then begin
      exit;
     end;
    end;
    else begin
     goto endlab;
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
    operatorsig.high:= 1;
    setoperparamid(operatorsig,0,nil); //no return value
    setoperparamid(operatorsig,d.dat.datatyp.indirectlevel,source1);

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
    operatorsig.high:= 1;
    setoperparamid(operatorsig,destindirectlevel,dest); //return value

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
     callsub(i2,sub1,i2,0,[dsf_instanceonstack,dsf_nooverloadcheck,
                                                      dsf_objconvert],0,i1);
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
     if (d.kind = ck_const) and 
        ((coo_notrunc in aoptions) or (tf_subrange in dest^.h.flags)) then begin
      case source1^.h.kind of
       dk_integer: begin
        getordrange(dest,ra1);
        if (ra1.min > d.dat.constval.vinteger) or 
                (ra1.max < d.dat.constval.vinteger) then begin
         if coo_errormessage in aoptions then begin
          errormessage(err_valuerange,[inttostr(ra1.min),inttostr(ra1.max)],
                                                                     acontext);
         end;
         result:= false;
         exit;
        end;
       end;
       dk_cardinal: begin
        getordrange(dest,ra1);
        if (card64(ra1.min) > d.dat.constval.vcardinal) or 
                (card64(ra1.max) < d.dat.constval.vcardinal) then begin
         if coo_errormessage in aoptions then begin
          errormessage(err_valuerange,[inttostr(card64(ra1.min)),
                                                  inttostr(card64(ra1.max))],
                                                                     acontext);
         end;
         result:= false;
         exit;
        end;
       end;
       dk_character: begin
        if not checkcharacterrange() then begin
         result:= false;
         exit;
        end;
       end;
      end;
     end;
     if dest^.h.kind = dk_string then begin
      result:= dest^.itemsize = source1^.itemsize;
     end
     else begin
      case dest^.h.kind of
       dk_enum: begin
        result:= issametype(dest,source1);
       end;
       dk_set{,dk_bigset}: begin
        result:= checkcompatibleset(acontext,source1,dest);
//        result:= issametype(dest^.infoset.itemtype,source1^.infoset.itemtype);
       end;
       dk_sub: begin
        result:= checkcompatiblesub(source1,dest);
       end;
       dk_record,dk_array: begin
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
        if not result and (destindirectlevel > 0) and 
                                  (coo_type in aoptions) then begin
         result:= true; //todo: "not related" warning
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
       goto sizeconvlab;
      end;
     end;
    end;
    if not result then begin
     if (dest^.h.kind = dk_classof) and 
           (source1^.h.kind = dk_class) and (destindirectlevel = 1) and 
                  (tf_classdef in acontext^.d.dat.datatyp.flags) then begin
      if not checkancestorclass(dest,source1) then begin
       goto endlab;
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
                vcardinal:= venum.value;
               end;
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
                vcardinal:= vcharacter;
               end;
              end;
              dk_set: begin //todo: arbitrary size
               if (coo_set in aoptions) and (vset.kind = dest^.h.datasize) and 
                                         (vset.kind <> das_bigint) then begin
                result:= true;
                vcardinal:= card32(vset.setvalue);
               end;
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
                vinteger:= venum.value;
               end;
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
                vinteger:= vcharacter;
               end;
              end;
              dk_set: begin //todo: arbitrary size
               if (coo_set in aoptions) and (vset.kind = dest^.h.datasize) and 
                                         (vset.kind <> das_bigint) then begin
                result:= true;
                vinteger:= int32(vset.setvalue);
               end;
              end;
             end;
            end;
            dk_set{,dk_bigset}: begin
             if vset.kind = das_bigint then begin
              if strf_empty in vset.bigsetvalue.flags then begin //empty set
               result:= true; 
              end;
             end
             else begin
              if vset.setvalue = 0 then begin //empty set
               result:= true; 
              end;
             end;
             if not result then begin
              if checkcompatibleset(acontext,source1,dest,
                                     coo_nomincheck in aoptions) then begin
               result:= true;
              {
               if dest^.h.datasize = das_bigint then begin
                fillchar(bigset1[4],sizeof(bigset1)-4,0);
                pcard32(@bigset1)^:= vset.setvalue;
                vset.bigsetvalue:= newbigintconst(@bigset1,dest^.h.bitsize);
                vset.kind:= das_bigint;
                                    //min,max?
                result:= true;
               end;
}
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
                                //single character
                 if not checkcharacterrange() then begin
                  exit;
                 end;
                 result:= true;
                end;
               end;
              end;
              dk_character: begin
               case dest^.h.datasize of
                das_8: begin
                 if vcharacter <= $ff then begin
                  result:= true;
                 end;
                end;
                das_16: begin
                 if vcharacter <= $ffff then begin
                  result:= true;
                 end;
                end;
                das_32: begin
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
         {
          if result then begin
           d.dat.datatyp.typedata:= ele.eledatarel(dest);
          end;
         }
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
               op1:= oc_dynarraytoopenar;
               if coo_paramindirect in aoptions then begin
                inc(destindirectlevel);
                op1:= oc_dynarraytoopenarad;
               end;
               with convert(op1)^ do begin
               end;
               result:= true;
              end;
             end;
            end;
            dk_array: begin
             if issametype(source1^.infoarray.i.itemtypedata,
                                dest^.infodynarray.i.itemtypedata) then begin
              if getaddress(acontext,true) then begin
               op1:= oc_arraytoopenar;
               if coo_paramindirect in aoptions then begin
                inc(destindirectlevel);
                op1:= oc_arraytoopenarad;
               end;
               with convert(op1)^ do begin
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
          dk_character: begin
           case source1^.h.kind of
            dk_character: begin
             convertsize(cardtocard);
            end;
           end;
          end;
          dk_set{,dk_bigset}: begin
           result:= checkcompatibleset(acontext,source1,dest);
          end;
          dk_string: begin
           case source1^.h.kind of
            dk_character: begin
             if tryconvert(acontext,st_card32,[coo_character]) then begin
              case dest^.itemsize of
               1: begin
                convert(oc_chartostring8);
               end;
               2: begin
                convert(oc_chartostring16);
               end;
               4: begin
                convert(oc_chartostring32);
               end;
               else begin
                internalerror1(ie_handler,'20181125C');
               end;
              end;
              result:= true;
             end;
            end;
            dk_string: begin
             fl1:= source1^.infostring.flags >< dest^.infostring.flags;
             if strf_bytes in fl1 then begin
              if strf_bytes in source1^.infostring.flags then begin
              {$ifdef mse_checkinternalerror}
               if source1^.itemsize <> 1 then begin
                internalerror(ie_handler,'20180803A');
               end;
              {$endif}
               convert(oc_bytestostring);
               convert(getconvstringop(source1^.itemsize,dest^.itemsize));
              end
              else begin
              {$ifdef mse_checkinternalerror}
               if dest^.itemsize <> 1 then begin
                internalerror(ie_handler,'20180803A');
               end;
              {$endif}
               convert(getconvstringop(source1^.itemsize,dest^.itemsize));
               convert(oc_stringtobytes);
              end;
             end
             else begin
              convert(getconvstringop(source1^.itemsize,dest^.itemsize));
             end;
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
       if (destindirectlevel = 1) and 
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
        if source1^.h.kind = dk_sub then begin
         op1:= oc_potopo;
        end
        else begin
         op1:= oc_inttopo;
        end;
        with insertitem(op1,stackoffset,-1)^ do begin
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
sizeconvlab:
   if not result and (coo_type in aoptions) then begin
    result:= (destindirectlevel = 0) and (source1^.h.indirectlevel = 0) and
                              (dest^.h.bytesize = source1^.h.bytesize);
    if result then begin
     include(d.dat.flags,df_typeconversion);
     if d.kind = ck_ref then begin
      if dest^.h.datasize = das_none then begin
       include(d.dat.ref.c.address.flags,af_aggregate);
      end
      else begin
       exclude(d.dat.ref.c.address.flags,af_aggregate);
      end;
     end;
    end;
   end;
   if result then begin
    if not pointerconv and (d.kind = ck_const) then begin
     d.dat.constval.kind:= dest^.h.kind;
    end;
    if coo_type in aoptions then begin
     include(d.dat.flags,df_typeconversion);
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
endlab:
 if not result and (coo_errormessage in aoptions) then begin
  incompatibletypeserror(dest,source1,getstackoffset(acontext));
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
function tryconvert(const acontext: pcontextitemty; const dest: systypety;
                           const aoptions: convertoptionsty = []): boolean;
begin
 with sysdatatypes[dest] do begin
  result:= tryconvert(acontext,
                              ele.eledataabs(typedata),indirectlevel,aoptions);
{
  if not result and (coo_errormessage in aoptions) then begin
   incompatibletypeserror(typedata,acontext^.d.dat.datatyp.typedata,
                                                getstackoffset(acontext));
  end;
}
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
    dk_set{,dk_bigset}: begin
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
//  if source^.h.kind = dk_class then begin
//   dec(sourceindilev);
//  end;
//  end;
  result:= destindirectlevel = sourceindilev;
  if result then begin
   result:= issametype(source,dest);
   if not result then begin
    if source^.h.kind = dest^.h.kind then begin
     if (source^.h.kind in [dk_sub,dk_method]) then begin
      result:= checkparamsbase(ele.eledataabs(source^.infosub.sub),
                               ele.eledataabs(dest^.infosub.sub));
      if result then begin
       exit;
      end;
     end;
     if (source^.h.kind in [dk_object,dk_class]) then begin
      result:= checkclassis(dest,source);
      if result then begin
       exit;
      end;
     end;
     if (source^.h.kind = dk_openarray) then begin
      result:= (source^.infodynarray.i.itemindirectlevel = 
                           dest^.infodynarray.i.itemindirectlevel) and
         issametype(source^.infodynarray.i.itemtypedata,
                               source^.infodynarray.i.itemtypedata);
      if result then begin
       exit;
      end;
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
    if (source^.h.kind = dk_string) and (dest^.h.kind = dk_character) and
       (d.kind = ck_const) and not (df_typeconversion in d.dat.flags) and
       ischarstringconst(d.dat.constval.vstring,dest^.h.bytesize) then begin
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
   include(d.dat.ref.c.address.flags,af_nostartoffset);
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
  ident.po:= start.po;
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
 po2: pointer;
 isinherited: boolean;
 isgetfact: boolean;
 firstcall: boolean;
 subflags: dosubflagsty;
 poind,pob,potop: pcontextitemty;
  
 procedure donotfound(const adatacontext: pcontextitemty;
                           const atype: elementoffsetty;
                           const startelement: pelementinfoty);

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
//  pvar1: pvardataty;
  int1: integer;
  po4: pointer;
  subflags1: subflagsty;
  typ1: ptypedataty;
  i2: int32;
  isclassof: boolean;
  po1: pelementinfoty;
  p1: pointer;
  indilev1: int32;
  flags1: addressflagsty;
  k1: elementkindty;
  isaddress: boolean;
 label
  fieldendlab;

 begin //donotfond()
  if firstnotfound <= idents.high then begin
   po1:= startelement;
   ele1:= basetype(atype);
   offs1:= 0;
   with info do begin
    for int1:= firstnotfound to idents.high do begin //fields
     typ1:= ele.eledataabs(ele1);
     isclassof:= (typ1^.h.kind = dk_classof) and (typ1^.h.indirectlevel = 1);
     isaddress:= false;
     if isclassof then begin
      ele1:= basetype(typ1^.infoclassof.classtyp);
     end;
     ele2:= ele1; //parent backup
     k1:= ele.findchild(ele1,idents.d[int1],[],allvisi,ele1,po4);
     with adatacontext^ do begin
      if not firstcall and (po1^.header.kind <> ek_type) and
       ((typ1^.h.kind = dk_class) and (d.dat.datatyp.indirectlevel = 1) or 
        (typ1^.h.kind = dk_object) and (d.dat.datatyp.indirectlevel = 0))
                                                                    then begin
       if (d.kind in factcontexts) and (d.dat.indirection = -1) then begin
        offsetad(adatacontext,offs1);
       end;
       offs1:= 0;
       if typ1^.h.kind = dk_class then begin 
        if not getvalue(adatacontext,das_none) then begin
         exit;
        end;
       end
       else begin //dk_object
        if not getaddress(adatacontext,true) then begin
         exit;
        end;
        isaddress:= true;
       end;
       if k1 in [ek_field,ek_property] then begin
        dec(d.dat.indirection);
        dec(d.dat.datatyp.indirectlevel);
       end;
      end;
     end;
     case k1 of
      ek_none: begin
       identerror(1+int1,err_identifiernotfound);
       exit;
      end;
      ek_field: begin
       with adatacontext^,pfielddataty(po4)^ do begin
        ele1:= vf.typ;
        typ1:= ele.eledataabs(ele2);
        case d.kind of
         ck_ref,ck_refprop: begin
         {
          if (typ1^.h.kind = dk_class) then begin
           if d.dat.ref.offset <> 0 then begin
            if not getvalue(adatacontext,das_none) then begin
             exit;
            end;
            offs1:= offset;
            dec(d.dat.indirection);
            dec(d.dat.datatyp.indirectlevel);
            goto fieldendlab;
           end;
           dec(d.dat.indirection);
           dec(d.dat.datatyp.indirectlevel);
          end;
         }
          d.dat.ref.offset:= d.dat.ref.offset + offset;
         end;
         ck_fact,ck_factprop: begin     //todo: check indirection
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
fieldendlab:
        if d.dat.datatyp.indirectlevel <> 0 then begin
         errormessage(err_illegalqualifier,[],
                            s.stacktop-s.stackindex + int1-idents.high);
         exit;
        end;
        d.dat.datatyp.typedata:= ele1; //todo: adress operator
        d.dat.datatyp.indirectlevel:= d.dat.datatyp.indirectlevel +
                       ptypedataty(ele.eledataabs(ele1))^.h.indirectlevel;
       end;
      end;
      ek_property: begin
       with adatacontext^,ppropertydataty(po4)^ do begin
        case d.kind of
         ck_ref,ck_fact,ck_subres: begin
          if d.kind = ck_ref then begin
           d.kind:= ck_refprop;
           d.dat.refprop.propele:= ele.eledatarel(po4);
          end
          else begin
           d.kind:= ck_factprop;
           d.dat.factprop.propele:= ele.eledatarel(po4);
          end;
         {
          if (pof_class in flags) and not firstcall then begin
           dec(d.dat.indirection);
           dec(d.dat.datatyp.indirectlevel);
          end;
         }
          d.dat.datatyp.typedata:= typ;
          d.dat.datatyp.indirectlevel:= d.dat.datatyp.indirectlevel +
                        ptypedataty(ele.eledataabs(typ))^.h.indirectlevel;
          ele1:= typ;
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
        ek_var,ek_field: begin
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
//          pvar1:= eletodata(po1);
          p1:= eletodata(po1);
          if po1^.header.kind = ek_var then begin
           with pvardataty(p1)^ do begin
            indilev1:= address.indirectlevel;
            flags1:= address.flags;
           end;
          end
          else begin
           with pfielddataty(p1)^ do begin
            indilev1:= indirectlevel;
            flags1:= flags;
           end;
          end;
          typ1:= ele.eledataabs(pvardataty(p1)^.vf.typ); //ek_var and ek_field
          if typ1^.h.kind = dk_class then begin
           include(subflags1,sf_class);
          end;
          if [sf_class,sf_interface] * subflags1 <> [] then begin
           if indilev1 <> 1 then begin
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
            if af_classele in flags1 then begin
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
            if indilev1 <> 1 then begin
             errormessage(err_classinstanceexpected,[]);
            end;
            if not getvalue(adatacontext,das_none) then begin 
                                               //get object pointer
             exit;
            end;
           end
           else begin
            if (sf_destructor in subflags1) and 
                 (indilev1 = 1) then begin //object pointer
             if not getvalue(adatacontext,das_none) then begin 
                                               //get object pointer
              exit;
             end;
            end
            else begin
             if indilev1 <> 0 then begin
              errormessage(err_objectexpected,[]);
             end;
             if sf_classmethod in subflags1 then begin
              if icf_virtual in typ1^.infoclass.flags then begin
               if not isaddress and not getaddress(adatacontext,true) then begin
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
              if not isaddress and not getaddress(adatacontext,true) then begin
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
     po1:= datatoele(po4); //new parentelement
    end;
    offsetad(adatacontext,offs1);
    firstcall:= false;
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
 end; //checcknoclassmethod
  
var
 po1: pelementinfoty;
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
 pe1: pelementinfoty;
 id1: identty;
 
label
 endlab;
begin //handlevalueident 
 with info do begin
  ele.pushelementparent();
  isgetfact:= false;
  firstcall:= false;
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
   pe1:= ele.eleinfoabs(po1^.header.parent);
   if (pe1^.header.kind = ek_classimpnode) or 
    (pe1^.header.kind = ek_type) and 
      (ptypedataty(eletodata(pe1))^.h.kind in [dk_class,dk_object]) then begin
    include(subflags,dsf_ownedmethod);
   end;
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
      initdatacontext(poind^.d,ck_refprop);
      d.dat.refprop.propele:= ele.eleinforel(po1);
      with ptypedataty(ele.eledataabs(ppropertydataty(po2)^.typ))^ do begin
       d.dat.datatyp.typedata:= ppropertydataty(po2)^.typ;
       d.dat.datatyp.flags:= h.flags;
       d.dat.datatyp.indirectlevel:= h.indirectlevel;
       d.dat.indirection:= -1;
       d.dat.ref.c.address:= pvardataty(ele.eledataabs(ele2))^.address;
       include(d.dat.ref.c.address.flags,af_dereferenced);
       d.dat.ref.offset:= 0;
       d.dat.ref.c.varele:= 0;
      end;
     end
     else begin
      case pob^.d.kind of
       ck_ref,ck_fact,ck_subres: begin
        dec(firstnotfound);
        firstcall:= true;
       (*
        with pob^,ptypedataty(ele.eledataabs(
                             ppropertydataty(po2)^.typ))^ do begin
         d.kind:= ck_prop;
         {
         if pof_class in flags then begin
          dec(d.dat.indirection);
          dec(d.dat.datatyp.indirectlevel);
         end;
         }
         d.dat.datatyp.typedata:= ppropertydataty(po2)^.typ;
         d.dat.datatyp.indirectlevel:= d.dat.datatyp.indirectlevel +
                       ptypedataty(ele.eledataabs(ppropertydataty(po2)^.typ))^.
                                                             h.indirectlevel;
         d.dat.prop.propele:= ele.eledatarel(po2);
        end;
       *)
       end;
       else begin
      {$ifdef mse_checkinternalerror}
        internalerror(ie_handler,'20151214B');
      {$endif}
       end;
      end;
     end;
     donotfound(pob,pob^.d.dat.datatyp.typedata,po1);
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
        if af_classfield in flags then begin
         include(d.dat.ref.c.address.flags,af_dereferenced);
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
           include(d.dat.fact.flags,faf_field);
           if co_llvm in o.compileoptions then begin
            if (faf_varsubres in d.dat.fact.flags) then begin
             with insertitem(oc_pushtempaddr,-1,-1)^ do begin
              par.tempaddr.a.ssaindex:= d.dat.fact.varsubres.ssaindex;
             end;
             exclude(d.dat.fact.flags,faf_varsubres);
            end
            else begin
//             internalerror1(ie_handler,'20181031A');
            {
             if not getaddress(pob,true) then begin
              goto endlab;
             end;
            }
            end;
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
       donotfound(pocontext1,pocontext1^.d.dat.datatyp.typedata,po1);
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
      donotfound(pocontext1,pvardataty(po2)^.vf.typ,po1);
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
      with pconstdataty(po2)^ do begin
       d.dat.datatyp:= val.typ;
       if tf_typeconversion in d.dat.datatyp.flags then begin
        include(d.dat.flags,df_typeconversion);
       end;
       d.dat.constval:= val.d;
       if (nameid >= 0) and (datatoele(po2)^.header.defunit <> s.unitinfo) and
                                                          modularllvm then begin
                                     //other unit
        case val.d.kind of
         dk_string: begin
          with d.dat.constval.vstring do begin
           offset:= ele.eledatarel(po2);
           include(flags,strf_ele);
          end;
         end;
         dk_set: begin
          with d.dat.constval.vset do begin
           if kind = das_bigint then begin
            bigsetvalue.offset:= ele.eledatarel(po2);
            include(bigsetvalue.flags,strf_ele);
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    ek_sub: begin
     if idents.high >= firstnotfound then begin
      errormessage(err_illegalqualifier,[],2);
      goto endlab;
     end;
     if not checknoclassmethod(po1) then begin
      goto endlab;
     end;
     if not isgetfact then begin
      dec(s.stackindex);
     end;
     if (dsf_ownedmethod in subflags) and 
              (stf_constructor in s.currentstatementflags) then begin
      subflags:= subflags + [dsf_noconstructor,dsf_isinherited];
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
      donotfound(poind,ele.eleinforel(po1),po1);
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
    ek_unit: begin
     if (firstnotfound = 1) and (idents.high = 0) then begin
      errormessage(err_illegalexpression,[],1); 
      goto endlab;
     end;
     id1:= po1^.header.name;
     with info.s.unitinfo^ do begin
      if stf_implementation in s.currentstatementflags then begin
       for i1:= 0 to high(implementationuses) do begin
        if implementationuses[i1]^.key = id1 then begin
         identerror(firstnotfound+1,err_identifiernotfound);
         goto endlab;
        end;
       end;
      end;
      for i1:= 0 to high(interfaceuses) do begin
       if interfaceuses[i1]^.key = id1 then begin
        identerror(firstnotfound+1,err_identifiernotfound);
        goto endlab;
       end;
      end;
      identerror(1,err_identifiernotfound); //unit not in scope
      goto endlab;
     end;
    end;
    ek_uses: begin
     identerror(1,err_identifiernotfound);
    end;
    else begin
     errormessage(err_illegalexpression,[],potop); 
//     internalerror1(ie_parser,'20150917C');
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
