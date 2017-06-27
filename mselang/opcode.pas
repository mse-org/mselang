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
unit opcode;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,parserglob,globtypes,opglob,handlerglob;
 
type
 loopinfoty = record
  start: opaddressty;
  size: databitsizety;
 end;
 aropty = (aro_none,aro_static,aro_dynamic); //for refcount helpers
 
var
 optable: poptablety;
// ssatable: pssatablety;
 pushsegaddrssaar: array[segmentty] of int32;
  
function getglobvaraddress(const adatasize: databitsizety; const asize: integer;
                                    var aflags: addressflagsty): segaddressty;
procedure inclocvaraddress(const asize: integer);
function getlocvaraddress(const adatasize: databitsizety; const asize: integer;
            var aflags: addressflagsty; const shift: integer = 0): locaddressty;

function getpointertempaddress(): addressvaluety;
procedure releasepointertempaddress();
function gettempaddress(const asize: databitsizety): addressvaluety;
function gettempaddress(const abytesize: int32{;
                                       var atotsize: int32}): addressvaluety;
procedure releasetempaddress(const asize: databitsizety);
procedure releasetempaddress(const asize: array of databitsizety);
procedure releasetempaddress(const abytesize: int32);
{
function getglobconstaddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): segaddressty;
}
function getglobconstaddress(const asize: integer;
                                             out adata: pointer): segaddressty;
function getclassinfoaddress(const asize: int32;
                                 const ainterfacecount: int32): segaddressty;
//function getinterfacecount(const classindex: int32): int32;

procedure setimmboolean(const value: boolean; var aimm: immty);
procedure setimmcard8(const value: card8; var aimm: immty);
procedure setimmcard16(const value: card16; var aimm: immty);
procedure setimmcard32(const value: card32; var aimm: immty);
procedure setimmcard64(const value: card64; var aimm: immty);
procedure setimmint1(const value: int8; var aimm: immty);
procedure setimmint8(const value: int8; var aimm: immty);
procedure setimmint16(const value: int16; var aimm: immty);
procedure setimmint32(const value: int32; var aimm: immty);
procedure setimmint64(const value: int64; var aimm: immty);
procedure setimmfloat32(const value: flo32; var aimm: immty);
procedure setimmfloat64(const value: flo64; var aimm: immty);
procedure setimmsize(const value: datasizety; var aimm: immty);
procedure setimmpointer(const value: dataaddressty; var aimm: immty);
procedure setimmoffset(const value: dataoffsty; var aimm: immty);
procedure setimmdatakind(const value: datakindty; var aimm: immty);

procedure setimmint32(const value: int32; out aimm: int32);

procedure setmemimm(const value: int32; var par: opparamty);

procedure checkopcapacity(const areserve: int32);
                  //garanties room for areserve ops
function additem(const aopcode: opcodety;
                               const ssaextension: integer = 0): popinfoty;
function insertitem(const aopcode: opcodety; const stackoffset: integer;
                          const aopoffset: int32; //-1 -> at end
                          const ssaextension: integer = 0): popinfoty;
function insertitem(const aopcode: opcodety; const acontext: pcontextitemty;
                          const aopoffset: int32; //-1 -> at end
                          const ssaextension: integer = 0): popinfoty;
function insertitem1(const aopcode: opcodety; const stackoffset: integer;
                          var aopoffset: int32; //-1 -> at end
                          const ssaextension: integer = 0): popinfoty;
                              //increments aopoffset if not at end
procedure cutopend(const aindex: int32);
{
function insertcallitem(const aopcode: opcodety; const stackoffset: integer;
                          const before: boolean;
                          const ssaextension: integer = 0): popinfoty;
}
function getoppo(const opindex: integer): popinfoty;
function getoppo(const ref: int32; offset: int32): popinfoty;
                           //skips op_lineinfo
//function getitem(const index: integer): popinfoty;
function opoffset(const ref: int32; offset: int32): int32; //skips lineinfo
function addcontrolitem(const aopcode: opcodety;
                               const ssaextension: integer = 0): popinfoty;
{
function insertcontrolitem(const aopcode: opcodety; const stackoffset: integer;
                          const before: boolean;
                          const ssaextension: integer = 0): popinfoty;
}
//function addcallitem(const aopcode: opcodety;
//                               const ssaextension: integer = 0): popinfoty;

procedure addlabel();

          //refcount helpers
procedure inipointer(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
procedure finirefsize(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
procedure increfsize(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
procedure decrefsize(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
                     
procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
procedure endforloop(const ainfo: loopinfoty);


procedure setoptable(const aoptable: poptablety);
{
procedure init();
procedure deinit();
}
{$ifdef mse_debugparser}
procedure dumpops();
{$endif}
implementation
uses
 stackops,handlerutils,errorhandler,segmentutils,typinfo,elements,msearrayutils,
 unithandler;
 
type
 opadsty = array[addressbasety] of opcodety;
 aropadsty = array[aropty] of opadsty;
//var
// classdefinterfacecount: integerarty;
// classdefcount: int32;

{$ifdef mse_debugparser}
procedure dumpops();
var
 int1: integer;
 po1: popinfoty;
begin
 writeln('n ssad ssa1 ssa2 ----OPS---- ',info.s.ssa.index,' ',info.s.ssa.nextindex);
 po1:= getsegmentpo(seg_op,0);
 for int1:= 0 to info.opcount-1 do begin
  with po1^.par do begin
   writeln(int1,' ',ssad,' ',ssas1,' ',ssas2,' ',
            getenumname(typeinfo(opcodety),ord(po1^.op.op)));
  end;
  inc(po1);
 end;
end;
{$endif}
{
procedure init();
begin
 //dummy
end;

procedure deinit();
begin
 classdefinterfacecount:= nil;
 classdefcount:= 0;
end;
}
procedure setoptable(const aoptable: poptablety);
begin
 optable:= aoptable;
// ssatable:= assatable;
 fillchar(pushsegaddrssaar,sizeof(pushsegaddrssaar),0);
 pushsegaddrssaar[seg_nil]:= optable^[ocssa_pushsegaddrnil].ssa;
 pushsegaddrssaar[seg_globvar]:= optable^[ocssa_pushsegaddrglobvar].ssa;
 pushsegaddrssaar[seg_op]:= optable^[ocssa_pushsegaddrglobvar].ssa;
 pushsegaddrssaar[seg_globconst]:= optable^[ocssa_pushsegaddrglobconst].ssa;
 pushsegaddrssaar[seg_classdef]:= optable^[ocssa_pushsegaddrclassdef].ssa;
 
end;
 
const
 storenilops: aropadsty = (
  (    //aro_none
  //ab_segment,   ab_local,      ab_locindi,
   oc_storesegnil,oc_storelocnil,oc_storelocindinil,
  //ab_stack,      ab_stackref
   oc_storestacknil,oc_storestackrefnil),
  (    //aro_static
  //ab_segment,     ab_local,        ab_locindi,
   oc_storesegnilar,oc_storelocnilar,oc_storelocindinilar,
  //ab_stack,       ab_stackref
   oc_storestacknilar,oc_storestackrefnilar),
  (    //aro_dynamic
  //ab_segment,     ab_local,        ab_locindi,
   oc_storesegnildynar,oc_storelocnildynar,oc_storelocindinildynar,
  //ab_stack,       ab_stackref
   oc_storestacknildynar,oc_storestackrefnildynar)
 );

 finirefsizeops: aropadsty = (
  (     //aro_none
  //ab_segment,         ab_local,            ab_locindi,
   oc_finirefsizeseg,oc_finirefsizeloc,oc_finirefsizelocindi,
  //ab_stack,           ab_stackref
   oc_finirefsizestack,oc_finirefsizestackref),
  (     //aro_static
  //ab_segment,           ab_local,              ab_locindi,
   oc_finirefsizesegar,oc_finirefsizelocar,oc_finirefsizelocindiar,
  //ab_stack,             ab_stackref
   oc_finirefsizestackar,oc_finirefsizestackrefar),
  (     //aro_dynamic
  //ab_segment,           ab_local,              ab_locindi,
   oc_finirefsizesegdynar,oc_finirefsizelocdynar,oc_finirefsizelocindidynar,
  //ab_stack,             ab_stackref
   oc_finirefsizestackdynar,oc_finirefsizestackrefdynar)
 );

 increfsizeops: aropadsty = (
  (     //aro_none
  //ab_segment,         ab_local,            ab_locindi,
   oc_increfsizeseg,oc_increfsizeloc,oc_increfsizelocindi,
  //ab_stack,           ab_stackref
   oc_increfsizestack,oc_increfsizestackref),
  (     //aro_static
  //ab_segment,           ab_local,              ab_locindi,
   oc_increfsizesegar,oc_increfsizelocar,oc_increfsizelocindiar,
  //ab_stack,             ab_stackref
   oc_increfsizestackar,oc_increfsizestackrefar),
  (     //aro_dynamic
  //ab_segment,           ab_local,              ab_locindi,
   oc_increfsizesegdynar,oc_increfsizelocdynar,oc_increfsizelocindidynar,
  //ab_stack,             ab_stackref
   oc_increfsizestackdynar,oc_increfsizestackrefdynar)
 );

 decrefsizeops: aropadsty = (
  (     //aro_none
  //ab_segment,         ab_local,            ab_locindi,
   oc_decrefsizeseg,oc_decrefsizeloc,oc_decrefsizelocindi,
  //ab_stack,           ab_stackref
   oc_decrefsizestack,oc_decrefsizestackref),
  (     //aro_static
  //ab_global,           ab_local,              ab_locindi,
   oc_decrefsizesegar,oc_decrefsizelocar,oc_decrefsizelocindiar,
  //ab_stack,             ab_stackref
   oc_decrefsizestackar,oc_decrefsizestackrefar),
  (     //aro_dynamic
  //ab_global,           ab_local,              ab_locindi,
   oc_decrefsizesegdynar,oc_decrefsizelocdynar,oc_decrefsizelocindidynar,
  //ab_stack,             ab_stackref
   oc_decrefsizestackdynar,oc_decrefsizestackrefdynar)
 );

procedure addmanagedop(const opsar: aropadsty; const arop: aropty;
                                                    {const atype: ptypedataty;}
                        const aref: addressrefty{; const ssaindex: integer});
var
 i1,ssaext1,ssabefore: int32;
 ab1: addressbasety;
 seg1: segmentty;
 ad1: dataoffsty;
 offs1: dataoffsty;
 af1: addressflagsty;
 typ1: ptypedataty;
 lev1: int32;
 context1: pcontextitemty;
begin
 ssaext1:= 0;
 context1:= @info.contextstack[aref.contextindex];
 case aref.kind of
  ark_vardata,ark_vardatanoaggregate: begin
   with pvardataty(aref.vardata)^ do begin 
    af1:= address.flags;
    offs1:= aref.offset;
    if (aref.kind = ark_vardatanoaggregate) then begin
     exclude(af1,af_aggregate);
    end;
    if af_segment in af1 then begin
     ab1:= ab_segment;
     ad1:= address.segaddress.address;
     seg1:= address.segaddress.segment;
     typ1:= ele.eledataabs(vf.typ);
    end
    else begin
     if af_local in af1 then begin
      tracklocalaccess(address.locaddress,ele.eledatarel(aref.vardata),
                                                      bitoptypes[das_pointer]);
      lev1:= info.sublevel - address.locaddress.framelevel - 1;
      if (co_mlaruntime in info.o.compileoptions) and 
          (af_resultvar in pvardataty(aref.vardata)^.address.flags) then begin
       ab1:= ab_localindi;
      end
      else begin
       ab1:= ab_local;
      end;
      ad1:= address.locaddress.address;
     end
     else begin
      notimplementederror('');
     end;
    end;
   end;
  end;
  ark_local: begin
   af1:= [];
   lev1:= -1;
   ab1:= ab_local;
   ad1:= aref.address;
   offs1:= aref.offset;
   typ1:= aref.typ;
  end;
  ark_managedtemp: begin
   af1:= [af_aggregate,af_managedtemp];
   lev1:= -1;
   ab1:= ab_local;
   ad1:= aref.address;
   offs1:= aref.offset;
   typ1:= aref.typ;
  end;
  ark_stack: begin
   af1:= [];
   ab1:= ab_stack;
   ad1:= aref.address;
   offs1:= aref.offset;
   typ1:= aref.typ;
  end;
  ark_stackref: begin
   af1:= [];
   ab1:= ab_stackref;
   ad1:= aref.address;
   offs1:= aref.offset;
   typ1:= aref.typ;
  end;
  ark_contextdata: begin
   with pcontextdataty(aref.contextdata)^ do begin
    case kind of
     ck_ref: begin
      typ1:= ele.eledataabs(dat.datatyp.typedata);
      offs1:= dat.ref.offset;
      af1:= dat.ref.c.address.flags;
      if af_segment in af1 then begin
       ab1:= ab_segment;
       ad1:= dat.ref.c.address.segaddress.address;
       seg1:= dat.ref.c.address.segaddress.segment;
      end
      else begin
       if af_local in af1 then begin
        tracklocalaccess(dat.ref.c.address.locaddress,dat.ref.c.varele,
                                                      bitoptypes[das_pointer]);
        lev1:= info.sublevel - dat.ref.c.address.locaddress.framelevel - 1;
        ab1:= ab_local;
        ad1:= dat.ref.c.address.locaddress.address;
       end
       else begin
        notimplementederror('');
       end;
      end;
     end;
     ck_fact: begin
      af1:= [];
      if dat.indirection = -1 then begin
       ab1:= ab_stackref;
      end
      else begin
       ab1:= ab_stack;
      end;
      ad1:= aref.offset;
      offs1:= 0;
//       typ1:= aaddress.typ;
      typ1:= ele.eledataabs(dat.datatyp.typedata);
     end;
     else begin
      notimplementederror('');
     end;
    end;
   end;
  end;
  else begin
   notimplementederror('20160328A');
  end;
 end;
 if af_aggregate in af1 then begin
  ssaext1:= ssaext1 + getssa(ocssa_aggregate);
 end;
 if (ab1 = ab_local) and (lev1 >= 0) then begin
  ssaext1:= ssaext1 + getssa(ocssa_nestedvar);
 end;
 if context1^.d.kind = ck_fact then begin
  ssabefore:= context1^.d.dat.fact.ssaindex;
 end;
 with insertitem(opsar[arop][ab1],
                    aref.contextindex-info.s.stackindex,-1,ssaext1)^ do begin
  par.ssas1:= aref.ssaindex;
  par.memop.t:= bitoptypes[das_pointer];
  par.memop.t.flags:= af1;
  case ab1 of
   ab_segment: begin
    with par.memop.segdataaddress do begin
     a.address:= ad1;
     a.segment:= seg1;
     offset:= offs1;
    end;
   end;
   ab_local,ab_localindi: begin
    with par.memop.locdataaddress do begin
     a.address:= ad1;
     a.framelevel:= lev1;
     offset:= offs1;
    end;
   end;
   else begin
    with par.memop.podataaddress do begin
     address:= ad1;
     offset:= offs1;
    end;
   end;
  end;
  if arop = aro_static then begin
   i1:= typ1^.infoarray.i.totitemcount;
   if (co_llvm in info.o.compileoptions) then begin
    par.memop.t.size:= 
              info.s.unitinfo^.llvmlists.constlist.adddataoffs(i1).listid;
   end
   else begin
    par.memop.t.size:= i1;
   end;
   par.memop.t.kind:= das_none;
   par.memop.t.flags:= [af_arrayop]; //size = count
  end;
 end;
 if context1^.d.kind = ck_fact then begin
  context1^.d.dat.fact.ssaindex:= ssabefore;
 end;

(*
 i1:= 0;
 if af_aggregate in aaddress.flags then begin
  i1:= getssa(ocssa_aggregate);
 end;
 with additem(opsar[arop][aaddress.base],i1)^ do begin
  par.ssas1:= ssaindex;
  par.memop.t:= bitoptypes[das_pointer];
  par.memop.t.flags:= aaddress.flags;
  if aaddress.base = ab_segment then begin
   par.memop.segdataaddress.a.address:= aaddress.address;
   par.memop.segdataaddress.a.segment:= aaddress.segment;
   par.memop.segdataaddress.offset:= aaddress.offset;
  end
  else begin
   par.memop.podataaddress.address:= aaddress.address;
   par.memop.podataaddress.offset:= aaddress.offset;
//   par.voffset:= aaddress.address;
  end;
  if arop = aro_static then begin
   i1:= atype^.infoarray.i.totitemcount;
   if (co_llvm in info.compileoptions) then begin
    par.memop.t.size:= 
              info.s.unitinfo^.llvmlists.constlist.adddataoffs(i1).listid;
   end
   else begin
    par.memop.t.size:= i1;
   end;
   par.memop.t.kind:= das_none;
   par.memop.t.flags:= [af_arrayop]; //size = count
  end;
 end;
 *)
end;

procedure inipointer(const arop: aropty; {const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
begin
 addmanagedop(storenilops,arop,{atype,}aref{,ssaindex});
end;

procedure finirefsize(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
begin
 addmanagedop(finirefsizeops,arop,{atype,}aref{,ssaindex});
end;

procedure increfsize(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
begin
 addmanagedop(increfsizeops,arop,{atype,}aref{,ssaindex});
end;

procedure decrefsize(const arop: aropty;{ const atype: ptypedataty;}
                     const aref: addressrefty{; const ssaindex: integer});
begin
 addmanagedop(decrefsizeops,arop,{atype,}aref{,ssaindex});
end;

function getglobvaraddress(const adatasize: databitsizety; const asize: integer;
                                    var aflags: addressflagsty): segaddressty;
begin
 with info do begin
  result.address:= globdatapo;
  globdatapo:= globdatapo + alignsize(asize);
  result.segment:= seg_globvar;
  aflags:= aflags - addresskindflags + [af_segment];
  if adatasize = das_none then begin
   include(aflags,af_aggregate);
  end;
  trackalloc(adatasize,asize,result);
 end;
end;

procedure inclocvaraddress(const asize: integer);
begin
 with info do begin
  if not (co_llvm in o.compileoptions) then begin
   locdatapo:= locdatapo + alignsize(asize);
  end;
 end;
end;

function getlocvaraddress(const adatasize: databitsizety; const asize: integer;
           var aflags: addressflagsty; const shift: integer = 0): locaddressty;
begin
 with info do begin
  if co_llvm in o.compileoptions then begin
   result.address:= info.locallocid;
   inc(info.locallocid);
  end
  else begin
   result.address:= locdatapo+shift;
  {$ifdef mse_locvarssatracking}
   result.ssaindex:= 0;
  {$endif}
   locdatapo:= locdatapo + alignsize(asize);
  end;
  result.framelevel:= info.sublevel;
  aflags:= aflags - addresskindflags + [af_local];
  if adatasize = das_none then begin
   include(aflags,af_aggregate);
  end;
 end;
end;

function getpointertempaddress(): addressvaluety;
begin
 with info do begin
  result.flags:= [af_stacktemp];
  result.indirectlevel:= 1;
//  result.locaddress.framelevel:= info.sublevel;
  if not (co_llvm in o.compileoptions) then begin
   result.tempaddress.address:= locdatapo - stacktempoffset;
   locdatapo:= locdatapo + pointersize;
  end
  else begin
   result.tempaddress.ssaindex:= info.s.ssa.nextindex-1;
                //last result
  end;
 end;
end;

procedure releasepointertempaddress();
begin
 with info do begin
  if not (co_llvm in o.compileoptions) then begin
   locdatapo:= locdatapo - pointersize;
   with additem(oc_pop)^ do begin
    par.imm.vsize:= pointersize;
   end;
  end;
 end;
end;

function gettempaddress(const asize: databitsizety): addressvaluety;
begin
 with info do begin
  result.flags:= [af_stacktemp];
  result.indirectlevel:= 0;
//  result.locaddress.framelevel:= info.sublevel;
  if not (co_llvm in o.compileoptions) then begin
   result.tempaddress.address:= locdatapo - info.stacktempoffset;
   locdatapo:= locdatapo + alignsize(bytesizes[asize]);
  end
  else begin
   result.tempaddress.ssaindex:= info.s.ssa.nextindex-1;
                 //last result
  end;
 end;
end;

function gettempaddress(const abytesize: int32{;
                                       var atotsize: int32}): addressvaluety;
var
 i1: int32;
begin
 with info do begin
  result.flags:= [af_stacktemp];
  result.indirectlevel:= 0;
  if not (co_llvm in o.compileoptions) then begin
   result.tempaddress.address:= locdatapo - info.stacktempoffset;
   i1:= alignsize(abytesize);
   locdatapo:= locdatapo + i1;
//   atotsize:= atotsize + i1;
  end
  else begin
   result.tempaddress.ssaindex:= info.s.ssa.nextindex-1;
                 //last result
  end;
 end;
end;

procedure releasetempaddress(const abytesize: int32);
begin
 with info do begin
  if not (co_llvm in o.compileoptions) then begin
   if abytesize > 0 then begin
    locdatapo:= locdatapo - abytesize;
    with additem(oc_pop)^ do begin
     par.imm.vsize:= alignsize(abytesize);
    end;
   end;
  end;
 end;
end;

procedure releasetempaddress(const asize: databitsizety);
begin
 releasetempaddress(alignsize(bytesizes[asize]));
end;

procedure releasetempaddress(const asize: array of databitsizety);
var
 i1,i2: int32;
begin
 i2:= 0;
 for i1:= 0 to high(asize) do begin
  i2:= i2 + alignsize(bytesizes[asize[i1]]);
 end;
 releasetempaddress(i2);
end;
{
function getglobconstaddress(const asize: integer; var aflags: addressflagsty;
                                       const shift: integer = 0): segaddressty;
begin
 result:= allocsegment(seg_globconst,asize);
 result.address:= result.address + shift;
 aflags:= aflags - addresskindflags + [af_segment];
end;
}
function getglobconstaddress(const asize: integer;
                                             out adata: pointer): segaddressty;
begin
 result:= allocsegment(seg_globconst,asize,adata);
end;

function getclassinfoaddress(const asize: int32;
                                   const ainterfacecount: int32): segaddressty;
begin
 result:= allocsegment(seg_classdef,asize);
 pint32(allocsegmentpo(seg_classintfcount,sizeof(int32)))^:= ainterfacecount;
end;

procedure setimmboolean(const value: boolean; var aimm: immty);
begin
 aimm.datasize:= das_1;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi1(value);
 end
 else begin
  aimm.vboolean:= value;
 end;
end;

procedure setimmcard8(const value: card8; var aimm: immty);
begin
 aimm.datasize:= das_8;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi8(value);
 end
 else begin
  aimm.vcard8:= value;
 end;
end;

procedure setimmcard16(const value: card16; var aimm: immty);
begin
 aimm.datasize:= das_16;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi16(value);
 end
 else begin
  aimm.vcard16:= value;
 end;
end;

procedure setimmcard32(const value: card32; var aimm: immty);
begin
 aimm.datasize:= das_32;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(value);
 end
 else begin
  aimm.vcard32:= value;
 end;
end;

procedure setimmcard64(const value: card64; var aimm: immty);
begin
 aimm.datasize:= das_64;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi64(value);
 end
 else begin
  aimm.vcard64:= value;
 end;
end;

procedure setimmint1(const value: int8; var aimm: immty);
begin
 aimm.datasize:= das_1;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi1(odd(value));
 end
 else begin
  aimm.vint8:= value;
 end;
end;

procedure setimmint8(const value: int8; var aimm: immty);
begin
 aimm.datasize:= das_8;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi8(value);
 end
 else begin
  aimm.vint8:= value;
 end;
end;

procedure setimmint16(const value: int16; var aimm: immty);
begin
 aimm.datasize:= das_16;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi16(value);
 end
 else begin
  aimm.vint16:= value;
 end;
end;

procedure setimmint32(const value: int32; var aimm: immty);
begin
 aimm.datasize:= das_32;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(value);
 end
 else begin
  aimm.vint32:= value;
 end;
end;

procedure setimmint32(const value: int32; out aimm: int32);
begin
 if co_llvm in info.o.compileoptions then begin
  aimm:= info.s.unitinfo^.llvmlists.constlist.addi32(value).listid;
 end
 else begin
  aimm:= value;
 end;
end;

procedure setmemimm(const value: int32; var par: opparamty);
begin
 if co_llvm in info.o.compileoptions then begin
  case par.memimm.mem.t.kind of
   das_8: begin
    par.memimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi8(value);
   end;
   das_16: begin
    par.memimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi16(value);
   end;
   das_64: begin
    par.memimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi64(value);
   end;
   else begin
    par.memimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi32(value);
   end;
  end;
 end
 else begin
  par.memimm.vint32:= value;
 end;
end;

procedure setimmint64(const value: int64; var aimm: immty);
begin
 aimm.datasize:= das_64;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addi64(value);
 end
 else begin
  aimm.vint64:= value;
 end;
end;

procedure setimmfloat32(const value: flo32; var aimm: immty);
begin
 aimm.datasize:= das_f32;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addf32(value);
 end
 else begin
  aimm.vflo32:= value;
 end;
end;

procedure setimmfloat64(const value: flo64; var aimm: immty);
begin
 aimm.datasize:= das_f64;
 if co_llvm in info.o.compileoptions then begin
  aimm.llvm:= info.s.unitinfo^.llvmlists.constlist.addf64(value);
 end
 else begin
  aimm.vflo64:= value;
 end;
end;

procedure setimmsize(const value: datasizety; var aimm: immty);
begin
 aimm.datasize:= pointerintsize;
 if co_llvm in info.o.compileoptions then begin
  aimm.vsize:= info.s.unitinfo^.llvmlists.constlist.
                                        adddataoffs(value).listid;
 end
 else begin
  aimm.vsize:= value;
 end;
end;

procedure setimmpointer(const value: dataaddressty; var aimm: immty);
var
 i1: int32;
begin
 aimm.datasize:= das_pointer;
 if co_llvm in info.o.compileoptions then begin
  if sizeof(dataaddressty) = 8 then begin
   aimm.vpointer:= info.s.unitinfo^.llvmlists.constlist.addi64(value).listid;
  end
  else begin
   aimm.vpointer:= info.s.unitinfo^.llvmlists.constlist.addi32(value).listid;
  end;
 end
 else begin
  aimm.vpointer:= value;
 end;
end;

procedure setimmoffset(const value: dataoffsty; var aimm: immty);
begin
 aimm.datasize:= dataoffssize;
 if co_llvm in info.o.compileoptions then begin
  notimplementederror('20150109D');
 end
 else begin
  aimm.voffset:= value;
 end;
end;

procedure setimmdatakind(const value: datakindty; var aimm: immty);
begin
 aimm.datasize:= das_32;
 if co_llvm in info.o.compileoptions then begin
  notimplementederror('20150109E');
 end
 else begin
  aimm.vdatakind:= value;
 end;
end;

procedure beginforloop(out ainfo: loopinfoty; const count: loopcountty);
begin  //todo: ssaindex
 ainfo.size:= getdatabitsize(count);
 if ainfo.size > das_32 then begin
  with additem(oc_pushimm64)^ do begin
   par.imm.vint64:= count;
   ainfo.start:= info.opcount;
   with additem(oc_decloop64)^ do begin
   end;
  end;
 end
 else begin
  with additem(oc_pushimm32)^ do begin
   par.imm.vint32:= count;
   ainfo.start:= info.opcount;
   with additem(oc_decloop32)^ do begin
   end;
  end;
 end;
end;

procedure endforloop(const ainfo: loopinfoty);
begin
 with additem(oc_goto)^ do begin
  par.opaddress.opaddress:= ainfo.start-1;
 end;
 with getoppo(ainfo.start)^ do begin
  par.opaddress.opaddress:= info.opcount-1;
 end;
 with additem(oc_locvarpop)^ do begin
  if ainfo.size > das_32 then begin
   par.stacksize:= 8;
  end
  else begin
   par.stacksize:= 4;
  end;
 end;
end;

procedure checkopcapacity(const areserve: int32);
                  //garanties room for areserve ops
begin
 checksegmentcapacity(seg_op,areserve*sizeof(opinfoty));
end;

function additem(const aopcode: opcodety;
                            const ssaextension: integer = 0): popinfoty;
begin
 with info do begin
  s.ssa.index:= s.ssa.nextindex;
  inc(s.ssa.nextindex,optable^[aopcode].ssa+ssaextension);
  result:= allocsegmentpo(seg_op,sizeof(opinfoty));
  with result^ do begin
   op.op:= aopcode;
//   op.flags:= [];
   par.ssad:= s.ssa.nextindex - 1;
  end;
  inc(opcount);
  if aopcode in callops then begin
   if info.s.trystacklevel > 0 then begin
    inc(info.s.ssa.bbindex);
   end;
  end;
 end;
end;

function addcontrolitem(const aopcode: opcodety;
                               const ssaextension: integer = 0): popinfoty;
begin
{$ifdef mse_checkinternalerror}
 if not (aopcode in controlops) then begin
  internalerror(ie_parser,'20150113A');
 end;
{$endif}
 result:= additem(aopcode,ssaextension);
 inc(info.s.ssa.bbindex);
 result^.par.opaddress.bbindex:= info.s.ssa.bbindex;
end;

function insertitem(const aopcode: opcodety; const stackoffset: integer;
                    const aopoffset: int32; //-1 -> at end
                    const ssaextension: integer = 0): popinfoty;
var
 int1,int2: integer;
 ad1: opaddressty;
 po1: popinfoty;
 poend: pointer;
 ssadelta: integer;
 parpo: pparallocinfoty;
 listpo: plistitemallocinfoty;
 endpo: pointer;
begin
 with info do begin
  int1:= stackoffset+s.stackindex;
  if (int1 > s.stacktop) or (aopoffset < 0) and (int1 = s.stacktop) then begin
   result:= additem(aopcode,ssaextension);
   if int1 = s.stacktop then begin
    with contextstack[s.stacktop] do begin
     if d.kind in factcontexts then begin
      d.dat.fact.ssaindex:= result^.par.ssad;
     end;
    end;
   end;
  end
  else begin
   ssadelta:= optable^[aopcode].ssa+ssaextension;
   allocsegmentpo(seg_op,sizeof(opinfoty));
   if aopoffset >= 0 then begin
    ad1:= contextstack[int1].opmark.address+aopoffset;
   end
   else begin
    ad1:= contextstack[int1+1].opmark.address
   end;
   linkinsertop(s.currentopcodemarkchain,ad1); //shift pending relocations
   result:= getoppo(ad1);
   move(result^,(result+1)^,(opcount-ad1)*sizeof(opinfoty));
   result^.op.op:= aopcode;
   result^.par.ssad:= (result-1)^.par.ssad + ssadelta; 
                //there is at least a subbegin op
   s.ssa.index:= s.ssa.nextindex;
   inc(s.ssa.nextindex,ssadelta);
   po1:= result+1;
   poend:= po1+opcount-ad1;
   inc(opcount);
   int2:= (result-1)^.par.ssad; //original start ssa
   while po1 < poend do begin           
                        //todo: boolean expression shortcut addresses?
    inc(po1^.par.ssad,ssadelta);
    if po1^.par.ssas1 >= int2 then begin
     inc(po1^.par.ssas1,ssadelta);
    end;
    if po1^.par.ssas2 >= int2 then begin
     inc(po1^.par.ssas2,ssadelta);
    end;
    if po1^.op.op in subops then begin //adjust param ssa's
     parpo:= getsegmentpo(seg_localloc,po1^.par.callinfo.params);
     endpo:= parpo + po1^.par.callinfo.paramcount;
     while parpo < endpo do begin
      if parpo^.ssaindex >= int2 then begin
       inc(parpo^.ssaindex,ssadelta);
      end;
      inc(parpo);
     end;
    end
    else begin
    {
     if po1^.op.op in listops then begin
      listpo:= getsegmentpo(seg_localloc,po1^.par.listinfo.allocs);
      endpo:= listpo + po1^.par.listinfo.alloccount;
      while listpo < endpo do begin
       if listpo^.ssaindex >= int2 then begin
        inc(listpo^.ssaindex,ssadelta);
       end;
       inc(listpo);
      end;
     end;
    }
    end;
    inc(po1);
   end;
   with contextstack[int1] do begin
    if d.kind in factcontexts then begin
     inc(d.dat.fact.ssaindex,ssadelta);
    end;
   end;
   for int1:= int1+1 to s.stacktop do begin
    with contextstack[int1] do begin
     inc(opmark.address);
     if d.kind in factcontexts then begin
      inc(d.dat.fact.ssaindex,ssadelta);
     end;
    end;
   end;
   if aopcode in callops then begin
    if info.s.trystacklevel > 0 then begin
     inc(info.s.ssa.bbindex);
    end;
   end;   
  end;
 end;
end;

function insertitem(const aopcode: opcodety; const acontext: pcontextitemty;
                          const aopoffset: int32; //-1 -> at end
                          const ssaextension: integer = 0): popinfoty;
begin
 result:= insertitem(aopcode,(acontext-pcontextitemty(info.contextstack)) -
                                    info.s.stackindex,aopoffset,ssaextension);
end;

function insertitem1(const aopcode: opcodety; const stackoffset: integer;
                          var aopoffset: int32; //-1 -> at end
                          const ssaextension: integer = 0): popinfoty;
                              //increments aopoffset if not at end
begin
 result:= insertitem(aopcode,stackoffset,aopoffset,ssaextension);
 if aopoffset >= 0 then begin
  inc(aopoffset);
 end;
end;

procedure cutopend(const aindex: int32);
begin
 with info do begin
 {$ifdef mse_checkinternalerror}
  if (opcount < aindex) or (aindex < 2) then begin
   internalerror(ie_handler,'20170609A');
  end;
 {$endif}
  if aindex < opcount then begin 
   //there are at least 2 ops by oc_beginparse and oc_subbegin
   s.ssa.nextindex:= getoppo(aindex-1)^.par.ssad+1;
   s.ssa.index:= getoppo(aindex-2)^.par.ssad+1;
   setsegmenttop(seg_op,getsegmentbase(seg_op)+aindex*sizeof(opinfoty));
   opcount:= aindex;
  end;
 end;
end;

function getoppo(const opindex: integer): popinfoty;
begin
 result:= getsegmentpo(seg_op,opindex*sizeof(opinfoty));
end;

function getoppo(const ref: int32; offset: int32): popinfoty; //skips lineinfo
var
 p1: popinfoty;
begin
 p1:= getsegmentbase(seg_op);
 inc(p1,ref);
 if offset > 0 then begin
  inc(p1);
  dec(offset);
  while true do begin
   while p1^.op.op = oc_lineinfo do begin
    inc(p1);
   end;
   if offset = 0 then begin
    break;
   end;
   dec(offset);
  end;
 end
 else begin
  if offset < 0 then begin
   dec(p1);
   inc(offset);
   while true do begin
    while p1^.op.op = oc_lineinfo do begin
     dec(p1);
    end;
    if offset = 0 then begin
     break;
    end;
    inc(offset);
   end;
  end
  else begin
   while p1^.op.op = oc_lineinfo do begin
    dec(p1);
   end;
  end;   
 end;
 result:= p1;
end;

function opoffset(const ref: int32; offset: int32): int32; //skips lineinfo
begin
 result:= getoppo(ref,offset) - popinfoty(getsegmentbase(seg_op));
end;

procedure addlabel();
begin
 with addcontrolitem(oc_label)^ do begin
  par.opaddress.opaddress:= info.opcount-1;
  par.opaddress.bbindex:= info.s.ssa.bbindex;
 end;
end;

{
function insertcallitem(const aopcode: opcodety; const stackoffset: integer;
                          const before: boolean;
                          const ssaextension: integer = 0): popinfoty;
begin
 result:= insertitem(aopcode,stackoffset,before,ssaextension);
 if info.s.trystacklevel > 0 then begin
  inc(info.s.ssa.blockindex);
 end;
end;
}
{
function insertitemafter(const stackoffset: integer;
                                         const shift: integer=0): popinfoty;
begin
 with info do begin
  if stackoffset+s.stackindex > s.stacktop then begin
   result:= additem;
  end
  else begin
   result:= insertitem(
                 contextstack[s.stackindex+stackoffset+1].opmark.address+shift);
  end;
 end;
end;
}
{
procedure writeop(const operation: opty); inline;
begin
 with additem()^ do begin
  op:= operation
 end;
end;
}
end.
