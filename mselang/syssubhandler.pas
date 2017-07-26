{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
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
unit syssubhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 globtypes,handlerglob,opglob,managedtypes,msetypes,exceptionhandler;
type
 syssubty = procedure (const paramco: int32);
 
procedure handleexit(const paramco: int32);
procedure handlewriteln(const paramco: int32);
procedure handlewrite(const paramco: int32);
procedure handlesizeof(const paramco: int32);
procedure handleord(const paramco: int32);
procedure handleinc(const paramco: int32);
procedure handledec(const paramco: int32);
procedure handleabs(const paramco: int32);
procedure handlegetmem(const paramco: int32);
procedure handlegetzeromem(const paramco: int32);
procedure handlefreemem(const paramco: int32);
procedure handlereallocmem(const paramco: int32);
procedure handlesetmem(const paramco: int32);
procedure handlememcpy(const paramco: int32);
procedure handlememmove(const paramco: int32);
procedure handlehalt(const paramco: int32);
procedure handlelow(const paramco: int32);
procedure handlehigh(const paramco: int32);
procedure handlelength(const paramco: int32);
procedure handlesin(const paramco: int32);
procedure handlecos(const paramco: int32);
procedure handlesqrt(const paramco: int32);
procedure handlefloor(const paramco: int32);
procedure handleround(const paramco: int32);
procedure handlenearbyint(const paramco: int32);
procedure handletruncint32(const paramco: int32);
procedure handletruncint64(const paramco: int32);
procedure handletrunccard32(const paramco: int32);
procedure handletrunccard64(const paramco: int32);

const
 sysfuncs: array[sysfuncty] of syssubty = (
  //syf_exit,
  @handleexit,
  //syf_write,   syf_writeln,
  @handlewrite,@handlewriteln,
  //syf_setlength,  syf_unique
  @handlesetlength,@handleunique,
  //syf_sizeof,  syf_ord
  @handlesizeof, @handleord,
  //syf_inc,  syf_dec    syf_abs,   
  @handleinc,@handledec,@handleabs,
  //syf_getmem,  syf_getzeromem,   syf_freemem
  @handlegetmem,@handlegetzeromem,@handlefreemem,
  //syf_reallocmem
  @handlereallocmem,
  //syf_setmem,  syf_memcpy,  syf_memmove,
  @handlesetmem,@handlememcpy,@handlememmove,
  //syf_halt, //syf_low, //syf_high, //syf_length, //syf_sin, //syf_cos
  @handlehalt,@handlelow,@handlehigh,@handlelength,@handlesin,@handlecos,
  //syf_sqrt, syf_floor,   syf_round,   syf_nearbyint,
  @handlesqrt,@handlefloor,@handleround,@handlenearbyint,
  //syf_truncint32,syf_truncint64
  @handletruncint32,@handletruncint64,
  //syf_trunccard32,syf_trunccard64,
  @handletrunccard32,@handletrunccard64,
  //syf_getexceptobj
  @handlegetexceptobj
 );

function checkparamco(const wanted, actual: integer): boolean;
  
procedure init();
procedure deinit();

implementation
uses
 elements,parserglob,handlerutils,opcode,stackops,errorhandler,rttihandler,
 segmentutils,llvmlists,valuehandler,identutils,unithandler,msestrings;

function checkparamco(const wanted, actual: integer): boolean;
begin
 result:= wanted = actual;
 if not result then begin
  with info do begin
   if actual > wanted then begin
    errormessage(err_tokenexpected,[')'],s.stacktop-s.stackindex-actual+wanted);
   end
   else begin
    identerror(1,err_wrongnumberofparameters);
   end;
  end;
 end;
end;

procedure handlesizeof(const paramco: integer);
var
 int1: integer;
 po1: pcontextitemty;
begin
 if checkparamco(1,paramco) then begin
  with info do begin
   po1:= @contextstack[s.stackindex];
   with po1^ do begin
    initdatacontext(po1^.d,ck_const);
    d.dat.datatyp:= sysdatatypes[st_int32];
    d.dat.constval.kind:= dk_integer;
    with contextstack[s.stacktop] do begin
     case d.kind of
      ck_const,ck_fact,ck_subres,ck_ref,ck_reffact: begin
       if d.kind in factcontexts then begin
        cutopend(po1^.opmark.address);
       end;
       if d.dat.datatyp.indirectlevel > 0 then begin
        int1:= pointersize;
       end
       else begin
        int1:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata))^.h.bytesize;
       end;
      end;
      ck_typetype,ck_fieldtype,ck_typearg: begin
       if d.typ.indirectlevel > 0 then begin
        int1:= pointersize;
       end
       else begin
        int1:= ptypedataty(ele.eledataabs(d.typ.typedata))^.h.bytesize;
       end;
      end;
      else begin
       int1:= 0;
       errormessage(err_cannotgetsize,[]);
      end;
     end;
    end;      
    d.dat.constval.vinteger:= int1;
   end;
  end;
 end;
end;

type
 memopty = (meo_segment,meo_local,meo_param,meo_paramindi,meo_indi);
 memoparty = array[memopty] of opcodety;
  
function addmemop(var context: contextdataty; const ops: memoparty;
                     const readwrite: boolean; 
                          const operanddatasize: databitsizety): popinfoty;
var
 ssaextension1: integer;
 framelevel1: integer;
 opdatatype1: typeallocinfoty;
begin
 opdatatype1:= getopdatatype(context.dat.datatyp);
 if context.kind = ck_fact then begin
  result:= additem(ops[meo_indi]);
 end
 else begin
  opdatatype1.flags:= context.dat.ref.c.address.flags;
  if af_aggregate in opdatatype1.flags then begin
   ssaextension1:= getssa(ocssa_aggregate);
   if readwrite then begin
    ssaextension1:= ssaextension1 + ssaextension1;
   end;
  end
  else begin
   ssaextension1:= 0;
  end;
  if af_segment in opdatatype1.flags then begin
   result:= additem(ops[meo_segment],ssaextension1);
   with result^.par do begin
    memop.segdataaddress.a:= context.dat.ref.c.address.segaddress;
    memop.segdataaddress.offset:= context.dat.ref.offset;
   end;
  end
  else begin
   framelevel1:= info.sublevel-
                         context.dat.ref.c.address.locaddress.framelevel-1;
   if framelevel1 >= 0 then begin
    ssaextension1:= ssaextension1 + getssa(ocssa_nestedvar);
   end;
   if af_param in context.dat.ref.c.address.flags then begin
    if af_paramindirect in context.dat.ref.c.address.flags then begin
     result:= additem(ops[meo_paramindi],ssaextension1);
    end
    else begin
     result:= additem(ops[meo_param],ssaextension1);
    end;
   end
   else begin   
    result:= additem(ops[meo_local],ssaextension1);
   end;
   with result^ do begin
    par.memop.locdataaddress.a:= context.dat.ref.c.address.locaddress;
    par.memop.locdataaddress.a.framelevel:= framelevel1;
    par.memop.locdataaddress.offset:= context.dat.ref.offset;
   end;
   tracklocalaccess(context.dat.ref.c.address.locaddress,
                                          context.dat.ref.c.varele,opdatatype1);
  end;
 end;
 result^.par.memop.t:= opdatatype1;
 result^.par.memop.operanddatasize:= operanddatasize;
end;

const
 incdecimmint32ops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incdecsegimmint,oc_incdeclocimmint,oc_incdecparimmint,
//meo_paramindi          //meo_indi
  oc_incdecparindiimmint,oc_incdecindiimmint);
 
 incdecimmpoops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incdecsegimmpo,oc_incdeclocimmpo,oc_incdecparimmpo,
//meo_paramindi         //meo_indi
  oc_incdecparindiimmpo,oc_incdecindiimmpo);

 incint32ops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incsegint,oc_inclocint,oc_incparint,
//meo_paramindi          //meo_indi
  oc_incparindiint,oc_incindiint);

 decint32ops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_decsegint,oc_declocint,oc_decparint,
//meo_paramindi          //meo_indi
  oc_decparindiint,oc_decindiint);
 
 incpoops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incsegpo,oc_inclocpo,oc_incparpo,
//meo_paramindi         //meo_indi
  oc_incparindipo,oc_incindipo);

 decpoops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_decsegpo,oc_declocpo,oc_decparpo,
//meo_paramindi         //meo_indi
  oc_decparindipo,oc_decindipo);
 
procedure handleincdec(const paramco: integer; const adec: boolean);
                             //todo: operand sizes
var
 par2isconst: boolean;

 procedure handleimm(const dest: pcontextitemty);
 var
  po1: ptypedataty;
  po3: popinfoty;
  i1,i2: int32;
 begin
  with info,dest^ do begin
   dec(d.dat.datatyp.indirectlevel); //dest type
   po1:= ele.eledataabs(d.dat.datatyp.typedata);
   if (paramco = 1) or par2isconst then begin
    if (d.dat.datatyp.indirectlevel > 0) then begin
     po3:= addmemop(d,incdecimmpoops,true,das_32);
     if d.dat.datatyp.indirectlevel = 1 then begin
      if po1^.h.kind = dk_pointer then begin
       po3^.par.memimm.vint32:= 1;
      end
      else begin
       po3^.par.memimm.vint32:= po1^.h.bytesize;
      end;
     end
     else begin
      po3^.par.memimm.vint32:= pointersize;
     end;
    end
    else begin
     po3:= addmemop(d,incdecimmint32ops,true,das_32);
     po3^.par.memimm.vint32:= 1;
    end;
    if par2isconst and (paramco > 1) then begin
     po3^.par.memimm.vint32:= po3^.par.memimm.vint32 *
                info.contextstack[info.s.stacktop].d.dat.constval.vinteger;
    end;
   end
   else begin
    if (d.dat.datatyp.indirectlevel > 0) then begin
     if d.dat.datatyp.indirectlevel = 1 then begin
      if po1^.h.kind = dk_pointer then begin
       i1:= 1;
      end
      else begin
       i1:= po1^.h.bytesize;
      end;
     end
     else begin
      i1:= pointersize;
     end;
     with contextstack[s.stacktop] do begin
      if i1 <> 1 then begin
       i2:= d.dat.fact.ssaindex;
       with insertitem(oc_mulimmint,s.stacktop-s.stackindex,-1)^ do begin
        par.ssas1:= i2;
        setimmint32(i1,par.imm);
       end;
      end;
      i2:= d.dat.fact.ssaindex;
     end;
     if adec then begin
      po3:= addmemop(d,decpoops,true,das_32);
     end
     else begin
      po3:= addmemop(d,incpoops,true,das_32);
     end;
     po3^.par.ssas2:= i2;
    end
    else begin
     if not tryconvert(@contextstack[s.stacktop],po1,0,[]) then begin
      typeconversionerror(contextstack[s.stacktop].d,
                                              po1,0,err_incompatibletypes);
      exit;
     end;
     i1:= contextstack[s.stacktop].d.dat.fact.ssaindex;
     if adec then begin
      po3:= addmemop(d,decint32ops,true,das_32);
     end
     else begin
      po3:= addmemop(d,incint32ops,true,das_32);
     end;
     po3^.par.ssas2:= i1;
    end;
    if par2isconst and (paramco > 1) then begin
     po3^.par.memimm.vint32:= po3^.par.memimm.vint32 *
                contextstack[s.stacktop].d.dat.constval.vinteger;
    end;
   end;
   po3^.par.ssas1:= info.s.ssa.index - 1;
   if adec then begin
    po3^.par.memimm.vint32:= -po3^.par.memimm.vint32;
   end;
   if co_llvm in o.compileoptions then begin
    with po3^.par.memimm do begin
     case po1^.h.datasize of
      das_8: begin
       llvm:= info.s.unitinfo^.llvmlists.constlist.addi8(vint32);
      end;
      das_16: begin
       llvm:= info.s.unitinfo^.llvmlists.constlist.addi16(vint32);
      end;
      das_32: begin
       llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(vint32);
      end;
      das_64: begin
       llvm:= info.s.unitinfo^.llvmlists.constlist.addi64(vint32);
      end;
      else begin
       llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(vint32);
      end;
     end;
    end;
   end;
  end;
 end;

var
 poa,pob: pcontextitemty;
 {po1,}po2: ptypedataty;
 int1: integer;
// po3: popinfoty;
//label
// factlab;
begin
 with info do begin
  if (paramco < 1) or (paramco > 2) then begin
   identerror(1,err_wrongnumberofparameters);
  end
  else begin
   int1:= 1;
   par2isconst:= true;
   if paramco > 1 then begin
    pob:= @contextstack[s.stacktop];
    poa:= getpreviousnospace(pob-1);
    with pob^ do begin
     po2:= ele.eledataabs(d.dat.datatyp.typedata);
     if (d.dat.datatyp.indirectlevel <> 0) or 
                  not (po2^.h.kind in ordinaldatakinds) then begin
      errormessage(err_ordinalexpexpected,[],s.stacktop-s.stackindex);      
     end
     else begin
      if d.kind = ck_const then begin
       int1:= d.dat.constval.vinteger;
      end
      else begin
       par2isconst:= false;
       if d.kind <> ck_none then begin //parameter error otherwise
        getvalue(pob,das_none);
        int1:= -1; //no imm
       end;
      end;
     end;
    end;
   end
   else begin
    poa:= @contextstack[s.stacktop];
   end;
   if int1 <> 0 then begin //ignore otherwise
    with poa^ do begin //dest
     case d.kind of
      ck_ref: begin
       if d.dat.indirection <> 0 then begin
        getaddress(poa,true);
       end
       else begin
        inc(d.dat.indirection);         //address
        inc(d.dat.datatyp.indirectlevel);
       end;
       handleimm(poa);
      end;
      ck_fact: begin
       getaddress(poa,true);
       handleimm(poa);
      end;
      ck_const: begin
       errormessage(err_variableexpected,[],s.stacktop-s.stackindex-paramco+1);
      end;
      ck_none: begin
       //error in parameter, ignore
      end;
      else begin
      {$ifdef mse_checkinternalerror}   
       internalerror(ie_handler,'20141109A');
      {$endif}
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure handleinc(const paramco: integer);
begin
 handleincdec(paramco,false);
end;

procedure handledec(const paramco: integer);
begin
 handleincdec(paramco,true);
end;

procedure handleord(const paramco: integer);

 procedure ordinalerror();
 begin
  errormessage(err_ordinalexpexpected,[],info.s.stacktop-info.s.stackindex);
 end; //ordinalerror

var
 typ1: ptypedataty;
 lstr1: lstringty;
 p1,p2: pcard8;
 c1: card32;
 i1: int32;
begin
 if checkparamco(1,paramco) then begin
  with info,contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if not (d.kind in datacontexts) then begin
    internalerror(ie_handler,'20170519A');
   end;
  {$endif}
   if (d.dat.datatyp.indirectlevel <> 0) or 
                          (hf_listitem in d.handlerflags) then begin
    ordinalerror();
   end
   else begin
    typ1:= ele.eledataabs(d.dat.datatyp.typedata);
    case d.kind of
     ck_const: begin
      case typ1^.h.kind of
       dk_integer: begin //nothing to do
       end;
       dk_cardinal: begin
        d.dat.constval.vinteger:= d.dat.constval.vcardinal;
       end;
       dk_boolean: begin
        if d.dat.constval.vboolean then begin
         d.dat.constval.vinteger:= 1;
        end
        else begin
         d.dat.constval.vinteger:= 0;
        end;
       end;
       dk_enum: begin
        d.dat.constval.vinteger:= d.dat.constval.venum.value;
       end;
       dk_character: begin
        d.dat.constval.vinteger:= d.dat.constval.vcharacter;
       end;
       dk_string: begin 
        lstr1:= getstringconst(d.dat.constval.vstring);
        if lstr1.len > 0 then begin
         p1:= pointer(lstr1.po);
         p2:= p1 + lstr1.len;
         if not getcodepoint(p1,p2,c1) or (p1 <> p2) then begin
          ordinalerror();
         end;
         d.dat.constval.vinteger:= c1;
        end;
       end;
       else begin
        ordinalerror();
       end;
      end;
      d.dat.constval.kind:= dk_integer;
      d.dat.datatyp:= sysdatatypes[st_int32];
     end;
     else begin
      if getvalue(@contextstack[s.stacktop],das_none) then begin
       if typ1^.h.kind = dk_boolean then begin
        i1:= d.dat.fact.ssaindex;
        with additem(oc_card1toint32)^ do begin
         par.ssas1:= i1;
         par.stackop.t:= getopdatatype(typ1,d.dat.datatyp.indirectlevel);
         d.kind:= ck_subres;
         d.dat.fact.ssaindex:= par.ssad;
         d.dat.datatyp:= sysdatatypes[st_int32];
        end;
       end
       else begin
        if not tryconvert(@contextstack[s.stacktop],st_int32,
                            [coo_enum,{coo_boolean,}coo_character]) then begin
         ordinalerror();
        end;
       end;
      end;
     end;
    end;
    contextstack[s.stackindex].d:= d; //todo: optimize
   end;
  end;
 end;
end;

procedure handleabs(const paramco: integer);
var
 typ1: ptypedataty;
 op1: opcodety;
 i1: int32;
begin
 if checkparamco(1,paramco) then begin
  with info,contextstack[s.stacktop] do begin
  {$ifdef mse_checkinternalerror}
   if not (d.kind in datacontexts) then begin
    internalerror(ie_handler,'20170519A');
   end;
  {$endif}
   typ1:= ele.eledataabs(d.dat.datatyp.typedata);
   if (d.dat.datatyp.indirectlevel <> 0) or 
              not (typ1^.h.kind in numericdatakinds)  then begin
    incompatibletypeserror('numerical type',s.stacktop-s.stackindex);
   end
   else begin
    if typ1^.h.kind <> dk_cardinal then begin //else nothing to do
     case d.kind of
      ck_const: begin
       case typ1^.h.kind of
        dk_integer: begin
         d.dat.constval.vinteger:= abs(d.dat.constval.vinteger);
        end;
        dk_float: begin
         d.dat.constval.vfloat:= abs(d.dat.constval.vfloat);
        end;
        else begin
         internalerror1(ie_handler,'20170519D');
        end;
       end;
      end;
      else begin
       if getvalue(@contextstack[s.stacktop],das_none) then begin
        case typ1^.h.kind of
         dk_integer: begin
          op1:= oc_absint;
         end;
         dk_float: begin
          op1:= oc_absflo;
         end;
         else begin
          internalerror1(ie_handler,'20170519E');
         end;
        end;
        i1:= d.dat.fact.ssaindex;
        with additem(op1)^ do begin
         par.ssas1:= i1;
         par.stackop.t:= getopdatatype(typ1,d.dat.datatyp.indirectlevel);
         d.kind:= ck_subres;
         d.dat.fact.ssaindex:= par.ssad;
        end;
       end;
      end;
     end;
    end;
    contextstack[s.stackindex].d:= d; //todo: optimize
   end;
  end;
 end;
end;

procedure handleexit(const paramco: integer);
begin
 with info do begin         //todo: try/finally
  if checkparamco(0,paramco) then begin
   with addcontrolitem(oc_goto)^ do begin
    linkmark(psubdataty(ele.parentdata)^.exitlinks,
                                getsegaddress(seg_op,@par.opaddress));
   end;
  end;
 end;
end;

procedure handlewrite(const paramco: integer);
var
 int1,int3: integer;
 po1: popinfoty; 
 po2: ptypedataty;
 poitem,poe: pcontextitemty;
label
 errlab;
begin                      
 with info do begin
  int3:= 0;
  poe:= @contextstack[s.stacktop];
  poitem:= @contextstack[s.stackindex+2];
  while getnextnospace(poitem+1,poitem) do begin
   if (poitem^.d.kind in datacontexts) and 
         (poitem^.d.dat.datatyp.indirectlevel = 0) then begin
    getvalue(poitem,
            ptypedataty(ele.eledataabs(
                          poitem^.d.dat.datatyp.typedata))^.h.datasize);
   end
   else begin
    getvalue(poitem,das_none);
   end;
  end;
  poitem:= @contextstack[s.stackindex+2];
  while getnextnospace(poitem+1,poitem) do begin
   with poitem^ do begin //todo: use table
    if d.dat.datatyp.indirectlevel > 0 then begin
     po1:= additem(oc_writepointer);
     po1^.par.voffset:= alignsize(pointersize);
    end
    else begin
     po2:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata));
     case po2^.h.kind of
      dk_boolean: begin
       po1:= additem(oc_writeboolean);
      end;
      dk_integer: begin
       case po2^.h.datasize of
        das_2_7,das_8: begin
         po1:= additem(oc_writeinteger8);
        end;
        das_9_15,das_16: begin
         po1:= additem(oc_writeinteger16);
        end;
        das_17_31,das_32: begin
         po1:= additem(oc_writeinteger32);
        end;
        das_33_63,das_64: begin
         po1:= additem(oc_writeinteger64);
        end;
        else begin
         goto errlab;
        end;
       end;
      end;
      dk_cardinal: begin
       case po2^.h.datasize of
        das_2_7,das_8: begin
         po1:= additem(oc_writecardinal8);
        end;
        das_9_15,das_16: begin
         po1:= additem(oc_writecardinal16);
        end;
        das_17_31,das_32: begin
         po1:= additem(oc_writecardinal32);
        end;
        das_33_63,das_64: begin
         po1:= additem(oc_writecardinal64);
        end;
        else begin
         goto errlab;
        end;
       end;
      end;
      dk_float: begin
       case po2^.h.datasize of
        das_f32: begin
         po1:=  additem(oc_writefloat32);
         po1^.par.voffset:= alignsize(sizeof(float32));
        end;
        das_f64: begin
         po1:=  additem(oc_writefloat64);
         po1^.par.voffset:= alignsize(sizeof(float64));
        end;
        else begin
         goto errlab;
        end;
       end;
      end;
      dk_string: begin
       case po2^.itemsize of
        1: begin
         po1:= additem(oc_writestring8);
        end;
        2: begin
         po1:= additem(oc_writestring16);
        end;
        4: begin
         po1:= additem(oc_writestring32);
        end;
        else begin
        {$ifdef mse_checkinternalerror}   
         internalerror(ie_parser,'20170325A');
        {$endif}
        end;
       end;
       po1^.par.voffset:= alignsize(pointersize);
      end;
      dk_character: begin
       case po2^.h.datasize of
        das_8: begin
         po1:= additem(oc_writechar8);
         po1^.par.voffset:= alignsize(1);
        end;
        das_16: begin
         po1:= additem(oc_writechar16);
         po1^.par.voffset:= alignsize(2);
        end;
        das_32: begin
         po1:= additem(oc_writechar32);
         po1^.par.voffset:= alignsize(4);
        end;
        else begin
        {$ifdef mse_checkinternalerror}   
         internalerror(ie_parser,'20170327A');
        {$endif}
        end;
       end;
      end;
      dk_class: begin
       po1:= additem(oc_writeclass);
       po1^.par.voffset:= alignsize(pointersize);
      end;
      dk_pointer: begin
       po1:= additem(oc_writepointer);
       po1^.par.voffset:= alignsize(pointersize);
      end;
      dk_enum: begin
       po1:= additem(oc_writeenum);
       po1^.par.voffset:= alignsize(pointersize);
       po1^.par.voffsaddress:= getrtti(po2);
      end;
      else begin
errlab:
       errormessage(err_cantreadwritevar,[],getstackoffset(poitem));
       po1:= additem(oc_none);
       po1^.par.voffset:= 0;         //dummy
 //      po1^.par.voffsaddress:= getrtti(po2);
      end;
     end;
     po1^.par.voffset:= alignsize(po2^.h.bytesize);
    end;
    po1^.par.ssas1:= d.dat.fact.ssaindex;
   end;
  end;
  po1:= getoppo(opcount);
  int3:= 0;
  for int1:= paramco-1 downto 0 do begin
   dec(po1);
   int3:= int3-po1^.par.voffset;
   po1^.par.voffset:= int3;
  end;
  with additem(oc_pop)^ do begin
   par.imm.vsize:= -int3;
  end;
 end;
end;

procedure handlewriteln(const paramco: integer);
begin
 handlewrite(paramco);
 with additem(oc_writeln)^ do begin
 end;
end;

(*
procedure handlewriteln(const paramco: integer);
var
 int1: integer;
 stacksize1: datasizety;
begin
 stacksize1:= 0;
 with info do begin
  for int1:= s.stacktop-paramco+1 to s.stacktop do begin
   getvalue(int1-s.stackindex{,true});
  end;
  for int1:= s.stacktop-paramco+1 to s.stacktop do begin
   with contextstack[int1] do begin
    with ptypedataty(ele.eledataabs(d.datatyp.typedata))^ do begin
     push(kind);
     stacksize1:= stacksize1 + alignsize(bytesize);
    end;
   end;
  end;
  with additem()^ do begin
   op:= @writelnop;
   par.paramcount:= paramco;
   par.paramsize:= stacksize1;
  end;
 end;
end;
*)

procedure handlesetlength(const paramco: integer);
begin
end;

procedure call2param(const paramco: integer; const op: opcodety);
     //(var [stacktop-1]: pointer; [stacktop]: i32)
var
 po1,po2: pcontextitemty;
begin
 if checkparamco(2,paramco) then begin
  with info do begin
   po2:= @contextstack[s.stacktop];
   po1:= getpreviousnospace(po2-1);
   with po1^ do begin
    if getaddress(po1,true) and
                    getbasevalue(po2,das_32) then begin
     if d.dat.datatyp.indirectlevel <= 0 then begin
      errormessage(err_pointertypeexpected,[]);
      exit;
     end;
     if not (po2^.d.dat.fact.opdatatype.kind in
                                             ordinalopdatakinds) then begin
      errormessage(err_ordinalexpexpected,[],s.stacktop-s.stackindex);
      exit;
     end;    
     with additem(op)^ do begin
      par.ssas1:= d.dat.fact.ssaindex;
      par.ssas2:= po2^.d.dat.fact.ssaindex;
      par.memop.t:= po2^.d.dat.fact.opdatatype;
     end;
    end;
   end;
  end;
 end;
end;

procedure handlegetmem(const paramco: integer);
begin
 call2param(paramco,oc_getmem);
end;

procedure handlegetzeromem(const paramco: integer);
begin
 call2param(paramco,oc_getzeromem);
end;

procedure handlefreemem(const paramco: integer);
begin
 with info do begin
  if checkparamco(1,paramco) and 
          getbasevalue(@contextstack[s.stacktop],das_pointer) then begin
//   with contextstack[s.stacktop] do begin
    with additem(oc_freemem)^ do begin
     par.ssas1:= info.s.ssa.index-1;
    end;
//   end;
  end;
 end;
end;

procedure handlereallocmem(const paramco: integer);
begin
 call2param(paramco,oc_reallocmem);
end;
 
procedure handlesetmem(const paramco: integer);
var
 po1,po2,po3: pcontextitemty;
begin
 with info do begin
  po3:= @contextstack[s.stacktop];
  po2:= getpreviousnospace(po3-1);
  po1:= getpreviousnospace(po2-1);
  if checkparamco(3,paramco) and getbasevalue(po1,das_pointer) and 
           getbasevalue(po2,das_32) and getbasevalue(po3,das_32) then begin
   with additem(oc_setmem)^ do begin
    par.ssas1:= po1^.d.dat.fact.ssaindex; //pointer
    par.ssas2:= po2^.d.dat.fact.ssaindex; //count
    par.ssas3:= po3^.d.dat.fact.ssaindex; //fill value
   end;
  end;
 end;
end;

procedure domemtransfer(const paramco: int32; const aop: opcodety);
var
 po1,po2,po3: pcontextitemty;
 i1: int32;
begin
 with info do begin
  po3:= @contextstack[s.stacktop];
  po2:= getpreviousnospace(po3-1);
  po1:= getpreviousnospace(po2-1);
  if checkparamco(3,paramco) and getbasevalue(po1,das_pointer) and 
           getbasevalue(po2,das_pointer) and getbasevalue(po3,das_32) then begin
   with additem(aop)^ do begin        //todo: alignment
    par.ssas1:= po1^.d.dat.fact.ssaindex; //dest
    par.ssas2:= po2^.d.dat.fact.ssaindex; //source
    par.ssas3:= po3^.d.dat.fact.ssaindex; //count
   end;
  end;
 end;
end;

procedure handlememcpy(const paramco: int32);
begin
 domemtransfer(paramco,oc_memcpy);
end;

procedure handlememmove(const paramco: int32);
begin
 domemtransfer(paramco,oc_memmove);
end;

procedure handlehalt(const paramco: integer);
begin
 with info do begin
  if checkparamco(0,paramco) then begin
   updateprogend(additem(oc_halt))
  end;
 end;
end;

procedure typeerror();
begin
 with info do begin
  contextstack[s.stacktop].d.kind:= ck_error;
  errormessage(err_typemismatch,[],s.stacktop-s.stackindex);
 end;
end;

procedure handlelowhigh(const paramco: integer; const ahigh: boolean);

 procedure checktype(const atype: elementoffsetty);
 var
  po1: ptypedataty;
  range: ordrangety;
 begin
  with info,contextstack[s.stackindex] do begin
   po1:= ele.eledataabs(atype);
   case po1^.h.kind of
    dk_integer: begin
     getordrange(po1,range);
     d.dat.constval.kind:= dk_integer;
     case po1^.h.datasize of  
      das_1,das_2_7,das_8: begin
       d.dat.datatyp:= sysdatatypes[st_int8];
      end;
      das_9_15,das_16: begin
       d.dat.datatyp:= sysdatatypes[st_int16];
      end;
      das_17_31,das_32: begin
//       d.dat.datatyp:= sysdatatypes[st_int32]; //default
      end;
      das_33_63,das_64: begin
       d.dat.datatyp:= sysdatatypes[st_int64];
      end;
      else begin
       internalerror1(ie_handler,'20150919');
      end;
     end;
     if ahigh then begin
      d.dat.constval.vinteger:= range.max;
     end
     else begin
      d.dat.constval.vinteger:= range.min;
     end;
    end;
    dk_cardinal: begin
     getordrange(po1,range);
     d.dat.constval.kind:= dk_cardinal;
     case po1^.h.datasize of  
      das_1,das_2_7,das_8: begin
       d.dat.datatyp:= sysdatatypes[st_card8];
      end;
      das_9_15,das_16: begin
       d.dat.datatyp:= sysdatatypes[st_card16];
      end;
      das_17_31,das_32: begin
       d.dat.datatyp:= sysdatatypes[st_card32];
      end;
      das_33_63,das_64: begin
       d.dat.datatyp:= sysdatatypes[st_card64];
      end;
      else begin
       internalerror1(ie_handler,'20150919');
      end;
     end;
     if ahigh then begin
      d.dat.constval.vcardinal:= card64(range.max);
     end
     else begin
      d.dat.constval.vcardinal:= card64(range.min);
     end;
    end;
    dk_enum: begin
     if ahigh then begin
      po1:= ele.eledataabs(po1^.infoenum.last);
     end
     else begin
      po1:= ele.eledataabs(po1^.infoenum.first);
     end;     
     setenumconst(po1^.infoenumitem,contextstack[s.stackindex]);
    end;
    dk_set: begin
     checktype(po1^.infoset.itemtype);
    end;
    else begin
     typeerror();
    end;
   end;
  end;
 end; //checktype
 
var
 po1: ptypedataty;
 dest1: pcontextitemty;
 
 procedure checkfact();
 var
  op1: opcodety;
 begin
  case po1^.h.kind of
   dk_string: begin
    op1:= oc_highstring;
   end;
   dk_dynarray: begin
    op1:= oc_highdynar;
   end;
   dk_openarray: begin
    op1:= oc_highopenar;
   end;
   else begin
    checktype(po1^.infoarray.indextypedata);
    cutopend(dest1^.opmark.address);
//    typeerror();
    exit;
   end;
  end;
  with additem(op1)^ do begin
   par.ssas1:= info.s.ssa.index-1;
  end;
  dest1^.d.kind:= ck_subres;
  dest1^.d.dat.fact.ssaindex:= info.s.ssa.index;
 end; //checkfact

var
 ptop: pcontextitemty;
  
begin
 with info do begin
  if checkparamco(1,paramco) then begin
   dest1:= @contextstack[s.stackindex];
   initdatacontext(dest1^.d,ck_const); //default
   dest1^.d.dat.datatyp:= sysdatatypes[st_int32]; //default
   ptop:= @contextstack[s.stacktop];
   with ptop^ do begin
    po1:= ele.eledataabs(d.dat.datatyp.typedata);
    case d.kind of
     ck_ref: begin
      if d.dat.datatyp.indirectlevel <> 0 then begin
       typeerror();
      end
      else begin
       case po1^.h.kind of
        dk_array: begin
         checktype(po1^.infoarray.indextypedata);
        end;
        dk_string,dk_dynarray,dk_openarray: begin
         if ahigh then begin
          if po1^.h.kind = dk_openarray then begin
           if getaddress(ptop,true) then begin
            checkfact();
           end;
          end
          else begin
           if getvalue(ptop,das_none) then begin
            checkfact();
           end;
          end;
         end
         else begin
          dest1^.d.dat.constval.kind:= dk_integer;
          if po1^.h.kind in [dk_dynarray,dk_openarray] then begin
           dest1^.d.dat.constval.vinteger:= 0;
          end
          else begin
           dest1^.d.dat.constval.vinteger:= 1;
          end;
         end;
        end;
        else begin
         checktype(d.dat.datatyp.typedata);
        end;
       end;
      end;
     end;
     ck_fact,ck_subres: begin
      checkfact();
     end;
     ck_typearg: begin
      checktype(d.typ.typedata);
     end;
     ck_const: begin
      case d.dat.constval.kind of
       dk_string: begin
//        dest1^.d.dat.datatyp:= sysdatatypes[st_int32];
        dest1^.d.dat.constval.kind:= dk_integer;
        if ahigh then begin
         dest1^.d.dat.constval.vinteger:= 
                             stringconstlen(d.dat.constval.vstring);
        end
        else begin
         dest1^.d.dat.constval.vinteger:= 1;
        end;
       end;
       else begin
        checktype(d.dat.datatyp.typedata);
       end;
      end;
     end;
     else begin
      typeerror();
     end;
    end;
   end;
  end;
 end;
end;

procedure handlelow(const paramco: integer);
begin
 handlelowhigh(paramco,false);
end;

procedure handlehigh(const paramco: integer);
begin
 handlelowhigh(paramco,true);
end;

procedure handlelength(const paramco: int32);
var
 typ1: ptypedataty;
 
 function arraylength(): int32;
 begin
  with getordrange(
         ptypedataty(ele.eledataabs(typ1^.infoarray.indextypedata))) do begin
   result:= max - min + 1;
  end;
 end; //arraylength
 
var
 dest1,ptop: pcontextitemty;
begin
 with info do begin
  if checkparamco(1,paramco) then begin
   ptop:= @contextstack[s.stacktop];
   with ptop^ do begin
    dest1:= @contextstack[s.stackindex];
    dest1^.d.dat.datatyp:= sysdatatypes[st_int32];
    initdatacontext(dest1^.d,ck_const); //default
    case d.kind of
     ck_const,ck_ref,ck_fact,ck_subres: begin
      if d.dat.datatyp.indirectlevel <> 0 then begin
       typeerror();
       exit;
      end;
      typ1:= ele.eledataabs(d.dat.datatyp.typedata);
      if d.kind = ck_const then begin
       dest1^.d.dat.constval.kind:= dk_integer;
       case d.dat.constval.kind of
        dk_array: begin
         dest1^.d.dat.constval.vinteger:= arraylength();
        end;
        dk_string: begin
         dest1^.d.dat.constval.vinteger:= 
                                      stringconstlen(d.dat.constval.vstring);
        end;
        dk_dynarray: begin
         notimplementederror('20160104B');
        end;
        else begin
         typeerror;
         exit;
        end;
       end;
      end
      else begin
       if typ1^.h.kind = dk_openarray then begin
        if getaddress(ptop,true) then begin
         with additem(oc_lengthopenar)^ do begin
          par.ssas1:= info.s.ssa.index-1;
         end;
        end;
       end
       else begin
        if getvalue(ptop,das_none) then begin
         case typ1^.h.kind of
          dk_string: begin
           with additem(oc_lengthstring)^ do begin
            par.ssas1:= info.s.ssa.index-1;
           end;
          end;
          dk_dynarray: begin
           with additem(oc_lengthdynar)^ do begin
            par.ssas1:= info.s.ssa.index-1;
           end;
          end;
          dk_array: begin //todo: do not load data
          {
           if co_mlaruntime in o.compileoptions then begin
            if d.kind in factcontexts then begin
             with additem(oc_pop)^ do begin
              setimmint32(typ1^.h.bytesize,par.imm); //indirectlevel?
             end;
            end;
           end;
          }
           if d.kind in factcontexts then begin
            cutopend(dest1^.opmark.address);
           end;
           initdatacontext(dest1^.d,ck_const);
           dest1^.d.dat.constval.kind:= dk_integer;
           dest1^.d.dat.constval.vinteger:= arraylength();
           exit();
          end;
          else begin
           typeerror();
           exit;
          end;
         end;
        end;
       end;
       dest1^.d.kind:= ck_subres;
       dest1^.d.dat.fact.ssaindex:= info.s.ssa.index;
      end;
     end;
     ck_typearg: begin
      typ1:= ele.eledataabs(d.typ.typedata);
      if typ1^.h.indirectlevel <> 0 then begin
       typeerror();
       exit;
      end;
      initdatacontext(dest1^.d,ck_const);
      dest1^.d.dat.constval.kind:= dk_integer;
      case typ1^.h.kind of
       dk_array: begin
        dest1^.d.dat.constval.vinteger:= arraylength();
       end;
       else begin
        typeerror();
       end;
      end;
     end;
     else begin
      notimplementederror('');
     end;
    end;
   end;
  end;
 end;
end;

procedure floatsysfunc(const paramco: integer; const aop: opcodety);
var
 po1: pcontextitemty;
begin
 with info do begin
  if checkparamco(1,paramco) and 
          getbasevalue(@contextstack[s.stacktop],das_f64) then begin
   with additem(aop)^ do begin
    par.ssas1:= info.s.ssa.index-1;
   end;
   po1:= @contextstack[s.stackindex];
   initdatacontext(po1^.d,ck_subres);
   with po1^ do begin
    d.dat.fact.ssaindex:= info.s.ssa.index;
    d.dat.datatyp:= sysdatatypes[st_flo64];
   end;
  end;
 end;
end;

procedure i32floatsysfunc(const paramco: integer; const aop64: opcodety;
                                              const aop32: opcodety = oc_none);
var
 po1: pcontextitemty;
 si1: databitsizety;
 op1: opcodety;
begin
 with info do begin
  if checkparamco(1,paramco) then begin
   po1:= @contextstack[s.stacktop];
   if (aop32 = oc_none) or (po1^.d.kind in datacontexts) and
    (ptypedataty(ele.eledataabs(po1^.d.dat.datatyp.typedata))^.h.datasize <>
                                                           das_f32) then begin
    si1:= das_f64;
    op1:= aop64;
   end
   else begin
    si1:= das_f32;
    op1:= aop32;
   end;
   if getbasevalue(@contextstack[s.stacktop],si1) then begin
    with additem(op1)^ do begin
     par.ssas1:= info.s.ssa.index-1;
    end;
    po1:= @contextstack[s.stackindex];
    initdatacontext(po1^.d,ck_subres);
    with po1^ do begin
     d.dat.fact.ssaindex:= info.s.ssa.index;
     d.dat.datatyp:= sysdatatypes[st_int32];
    end;
   end;
  end;
 end;
end;

procedure i64floatsysfunc(const paramco: integer; const aop: opcodety);
var
 po1: pcontextitemty;
begin
 with info do begin
  if checkparamco(1,paramco) and 
          getbasevalue(@contextstack[s.stacktop],das_f64) then begin
   with additem(aop)^ do begin
    par.ssas1:= info.s.ssa.index-1;
   end;
   po1:= @contextstack[s.stackindex];
   initdatacontext(po1^.d,ck_subres);
   with po1^ do begin
    d.dat.fact.ssaindex:= info.s.ssa.index;
    d.dat.datatyp:= sysdatatypes[st_int64];
   end;
  end;
 end;
end;

procedure handlesin(const paramco: integer);
begin
 floatsysfunc(paramco,oc_sin64);
end;

procedure handlecos(const paramco: integer);
begin
 floatsysfunc(paramco,oc_cos64);
end;

procedure handlesqrt(const paramco: integer);
begin
 floatsysfunc(paramco,oc_sqrt64);
end;

procedure handlefloor(const paramco: integer);
begin
 floatsysfunc(paramco,oc_floor64);
end;

procedure handleround(const paramco: integer);
begin
 floatsysfunc(paramco,oc_round64);
end;

procedure handlenearbyint(const paramco: integer);
begin
 floatsysfunc(paramco,oc_nearbyint64);
end;

procedure handletruncint32(const paramco: integer);
begin
 i32floatsysfunc(paramco,oc_truncint32flo64,oc_truncint32flo32);
end;

procedure handletruncint64(const paramco: integer);
begin
 i64floatsysfunc(paramco,oc_truncint64flo64);
end;

procedure handletrunccard32(const paramco: integer);
begin
 i32floatsysfunc(paramco,oc_trunccard32flo64,oc_trunccard32flo32);
end;

procedure handletrunccard64(const paramco: integer);
begin
 i64floatsysfunc(paramco,oc_trunccard64flo64);
end;


type
 sysfuncinfoty = record
  name: string;
  data: sysfuncdataty;
 end;
const
 sysfuncinfos: array[sysfuncty] of sysfuncinfoty = (
   (name: 'exit'; data: (func: syf_exit)),
   (name: 'write'; data: (func: syf_write)),
   (name: 'writeln'; data: (func: syf_writeln)),
   (name: 'setlength'; data: (func: syf_setlength)),
   (name: 'unique'; data: (func: syf_unique)),
   (name: 'sizeof'; data: (func: syf_sizeof)),
   (name: 'ord'; data: (func: syf_ord)),
   (name: 'inc'; data: (func: syf_inc)),
   (name: 'dec'; data: (func: syf_dec)),
   (name: 'abs'; data: (func: syf_abs)),
   (name: 'getmem'; data: (func: syf_getmem)),
   (name: 'getzeromem'; data: (func: syf_getzeromem)),
   (name: 'freemem'; data: (func: syf_freemem)),
   (name: 'reallocmem'; data: (func: syf_reallocmem)),
   (name: 'setmem'; data: (func: syf_setmem)),
   (name: 'memcpy'; data: (func: syf_memcpy)),
   (name: 'memmove'; data: (func: syf_memmove)),
   (name: 'halt'; data: (func: syf_halt)),
   (name: 'low'; data: (func: syf_low)),
   (name: 'high'; data: (func: syf_high)),
   (name: 'length'; data: (func: syf_length)),
   (name: 'sin'; data: (func: syf_sin)),
   (name: 'cos'; data: (func: syf_cos)),
   (name: 'sqrt'; data: (func: syf_sqrt)),
   (name: 'floor'; data: (func: syf_floor)),
   (name: 'round'; data: (func: syf_round)),
   (name: 'nearbyint'; data: (func: syf_nearbyint)),
   (name: 'truncint32'; data: (func: syf_truncint32)),
   (name: 'truncint64'; data: (func: syf_truncint64)),
   (name: 'trunccard32'; data: (func: syf_trunccard32)),
   (name: 'trunccard64'; data: (func: syf_trunccard64)),
   (name: 'getexceptobj'; data: (func: syf_getexceptobj))
  );

procedure init();
var
 sf1: sysfuncty;
 po1: pelementinfoty;
begin
 for sf1:= low(sysfuncty) to high(sysfuncty) do begin
  with sysfuncinfos[sf1] do begin
   po1:= ele.addelement(getident(name),ek_sysfunc,globalvisi);
   psysfuncdataty(@po1^.data)^:= data;
  end;
 end;
end;

procedure deinit();
begin
end;

end.
