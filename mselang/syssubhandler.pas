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
 globtypes,handlerglob,opglob,managedtypes,msetypes;
type
 syssubty = procedure (const paramco: integer);
 
procedure handlewriteln(const paramco: integer);
procedure handlewrite(const paramco: integer);
procedure handlesizeof(const paramco: integer);
procedure handleinc(const paramco: integer);
procedure handledec(const paramco: integer);
procedure handlegetmem(const paramco: integer);
procedure handlegetzeromem(const paramco: integer);
procedure handlefreemem(const paramco: integer);
procedure handlesetmem(const paramco: integer);
procedure handlehalt(const paramco: integer);
procedure handlelow(const paramco: integer);
procedure handlehigh(const paramco: integer);

const
 sysfuncs: array[sysfuncty] of syssubty = (
  //sf_write,   sf_writeln,    sf_setlength,   sf_sizeof,
  @handlewrite,@handlewriteln,@handlesetlength,@handlesizeof,
  //sf_inc,  sf_dec     sf_getmem,    sf_getzeromem,    sf_freemem
  @handleinc,@handledec,@handlegetmem,@handlegetzeromem,@handlefreemem,
  //sf_setmem,  sf_halt
  @handlesetmem,@handlehalt,@handlelow,@handlehigh);
  
procedure init();
procedure deinit();

implementation
uses
 elements,parserglob,handlerutils,opcode,stackops,errorhandler,rttihandler,
 segmentutils,llvmlists,valuehandler,identutils,unithandler;

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
begin
 if checkparamco(1,paramco) then begin
  with info,contextstack[s.stackindex] do begin
   d.kind:= ck_const;
   d.dat.indirection:= 0;
   d.dat.datatyp:= sysdatatypes[st_int32];
   d.dat.constval.kind:= dk_integer;
   with contextstack[s.stacktop] do begin
    case d.kind of
     ck_const,ck_fact,ck_subres,ck_ref,ck_reffact: begin
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

type
 memopty = (meo_segment,meo_local,meo_param,meo_paramindi,meo_indi);
 memoparty = array[memopty] of opcodety;
  
function addmemop(var context: contextdataty; const ops: memoparty;
                        const readwrite: boolean): popinfoty;
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
end;

const
 incdecimmint32ops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incdecsegimmint32,oc_incdeclocimmint32,oc_incdecparimmint32,
//meo_paramindi          //meo_indi
  oc_incdecparindiimmint32,oc_incdecindiimmint32);
 
 incdecimmpoops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incdecsegimmpo32,oc_incdeclocimmpo32,oc_incdecparimmpo32,
//meo_paramindi         //meo_indi
  oc_incdecparindiimmpo32,oc_incdecindiimmpo32);

 incint32ops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incsegint32,oc_inclocint32,oc_incparint32,
//meo_paramindi          //meo_indi
  oc_incparindiint32,oc_incindiint32);

 decint32ops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_decsegint32,oc_declocint32,oc_decparint32,
//meo_paramindi          //meo_indi
  oc_decparindiint32,oc_decindiint32);
 
 incpoops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_incsegpo32,oc_inclocpo32,oc_incparpo32,
//meo_paramindi         //meo_indi
  oc_incparindipo32,oc_incindipo32);

 decpoops: memoparty = (
//meo_segment,        meo_local,          meo_param,
  oc_decsegpo32,oc_declocpo32,oc_decparpo32,
//meo_paramindi         //meo_indi
  oc_decparindipo32,oc_decindipo32);
 
procedure handleincdec(const paramco: integer; const adec: boolean);

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
     po3:= addmemop(d,incdecimmpoops,true);
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
     po3:= addmemop(d,incdecimmint32ops,true);
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
       with insertitem(oc_mulimmint32,s.stacktop-s.stackindex,false)^ do begin
        par.ssas1:= i2;
        setimmint32(i1,par);
       end;
      end;
      i2:= d.dat.fact.ssaindex;
     end;
     if adec then begin
      po3:= addmemop(d,decpoops,true);
     end
     else begin
      po3:= addmemop(d,incpoops,true);
     end;
     po3^.par.ssas2:= i2;
    end
    else begin
     i1:= contextstack[s.stacktop].d.dat.fact.ssaindex;
     if adec then begin
      po3:= addmemop(d,decint32ops,true);
     end
     else begin
      po3:= addmemop(d,incint32ops,true);
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
   if co_llvm in compileoptions then begin
    with po3^.par.memimm do begin
     llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(vint32);
    end;
   end;
  end;
 end;

var
 po1: pcontextitemty;
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
    with contextstack[s.stacktop] do begin
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
        getvalue(s.stacktop-s.stackindex,das_none);
        int1:= -1; //no imm
       end;
      end;
     end;
    end;
   end;
   if int1 <> 0 then begin //ignore otherwise
    po1:= @contextstack[s.stacktop-paramco+1];
    with po1^ do begin //dest
     case d.kind of
      ck_ref: begin
       if d.dat.indirection <> 0 then begin
        getaddress(s.stacktop-paramco+1-s.stackindex,true);
       end
       else begin
        inc(d.dat.indirection);         //address
        inc(d.dat.datatyp.indirectlevel);
       end;
       handleimm(po1);
      end;
      ck_fact: begin
       getaddress(s.stacktop-paramco+1-s.stackindex,true);
       handleimm(po1);
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

procedure handlewrite(const paramco: integer);
var
 int1,int3: integer;
 po1: popinfoty; 
 po2: ptypedataty;
begin                             //todo: datasize
 with info do begin
  int3:= 0;
  for int1:= s.stacktop-paramco+1 to s.stacktop do begin
   getvalue(int1-s.stackindex,das_none);
  end;
  for int1:= s.stacktop-paramco+1 to s.stacktop do begin
   with contextstack[int1] do begin //todo: use table
    if d.dat.datatyp.indirectlevel > 0 then begin
     po1:= additem(oc_writepointer);
     po1^.par.voffset:= alignsize(pointersize);
    end
    else begin
     po2:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata));
     case po2^.h.kind of
      dk_boolean: begin
       po1:= additem(oc_writeboolean);
       po1^.par.voffset:= alignsize(sizeof(boolean));
      end;
      dk_integer: begin
       po1:= additem(oc_writeinteger);
       po1^.par.voffset:= alignsize(sizeof(int32));
      end;
      dk_cardinal: begin
       po1:= additem(oc_writecardinal);
       po1^.par.voffset:= alignsize(sizeof(int32));
      end;
      dk_float: begin
       po1:=  additem(oc_writefloat);
       po1^.par.voffset:= alignsize(sizeof(float64));
      end;
      dk_string8: begin
       po1:= additem(oc_writestring8);
       po1^.par.voffset:= alignsize(pointersize);
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
       errormessage(err_cantreadwritevar,[],int1-s.stackindex);
       po1:= additem(oc_none);
       po1^.par.voffset:= 0;         //dummy
 //      po1^.par.voffsaddress:= getrtti(po2);
      end;
     end;
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
var
 po1,po2: pcontextitemty;
begin
 if checkparamco(2,paramco) then begin
  with info do begin
   po2:= @contextstack[s.stacktop];
   po1:= po2-1;
   with po1^ do begin
    if getaddress(s.stacktop-s.stackindex-1,true) and
                    getbasevalue(s.stacktop-s.stackindex,das_32) then begin
     if d.dat.datatyp.indirectlevel <= 0 then begin
      errormessage(err_pointertypeexpected,[]);
      exit;
     end;
     if not (contextstack[s.stacktop].d.dat.fact.opdatatype.kind in
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
          getbasevalue(s.stacktop-s.stackindex,das_pointer) then begin
   with contextstack[s.stacktop] do begin
    with additem(oc_freemem)^ do begin
     par.ssas1:= info.s.ssa.index-1;
    end;
   end;
  end;
 end;
end;
 
procedure handlesetmem(const paramco: integer);
var
 po1: pcontextitemty;
 i1: int32;
begin
 with info do begin
  i1:= s.stacktop-s.stackindex;
  if checkparamco(3,paramco) and getbasevalue(i1-2,das_pointer) and 
           getbasevalue(i1-1,das_32) and getbasevalue(i1,das_32) then begin
   with additem(oc_setmem)^ do begin
    po1:= @contextstack[s.stackindex+3];
    par.ssas1:= po1^.d.dat.fact.ssaindex; //pointer
    inc(po1);
    par.ssas2:= po1^.d.dat.fact.ssaindex; //count
    inc(po1);
    par.ssas3:= po1^.d.dat.fact.ssaindex; //fill value
   end;
  end;
 end;
end;

procedure handlehalt(const paramco: integer);
begin
 with info do begin
  if checkparamco(0,paramco) then begin
   updateprogend(additem(oc_halt))
  end;
 end;
end;

procedure handlelowhigh(const paramco: integer; const ahigh: boolean);

 procedure typeerror();
 begin
  with info do begin
   contextstack[s.stacktop].d.kind:= ck_error;
   errormessage(err_typemismatch,[],s.stacktop-s.stackindex);
  end;
 end;

 procedure checktype(const atype: elementoffsetty);
 var
  po1: ptypedataty;
  range: ordrangety;
 begin
  with info,contextstack[s.stackindex] do begin
   po1:= ele.eledataabs(atype);
   d.kind:= ck_const;
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
       d.dat.datatyp:= sysdatatypes[st_int32];
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
    end;
    dk_set: begin
    end;
    else begin
     typeerror();
    end;
   end;
  end;
 end;
 
var
 po1: ptypedataty;
  
begin
 with info do begin
  if checkparamco(1,paramco) then begin
   with contextstack[s.stacktop] do begin
    case d.kind of
     ck_ref: begin
      if d.dat.datatyp.indirectlevel <> 0 then begin
       typeerror();
      end
      else begin
       po1:= ele.eledataabs(d.dat.datatyp.typedata);
       case po1^.h.kind of
        dk_array: begin
         checktype(po1^.infoarray.indextypedata);
        end;
        else begin
         checktype(d.dat.datatyp.typedata);
        end;
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

type
 sysfuncinfoty = record
  name: string;
  data: sysfuncdataty;
 end;
const
 sysfuncinfos: array[sysfuncty] of sysfuncinfoty = (
   (name: 'write'; data: (func: sf_write)),
   (name: 'writeln'; data: (func: sf_writeln)),
   (name: 'setlength'; data: (func: sf_setlength)),
   (name: 'sizeof'; data: (func: sf_sizeof)),
   (name: 'inc'; data: (func: sf_inc)),
   (name: 'dec'; data: (func: sf_dec)),
   (name: 'getmem'; data: (func: sf_getmem)),
   (name: 'getzeromem'; data: (func: sf_getzeromem)),
   (name: 'freemem'; data: (func: sf_freemem)),
   (name: 'setmem'; data: (func: sf_setmem)),
   (name: 'halt'; data: (func: sf_halt)),
   (name: 'low'; data: (func: sf_low)),
   (name: 'high'; data: (func: sf_high))
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
