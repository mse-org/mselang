{ MSElang Copyright (c) 2014-2015 by Martin Schreiber
   
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
unit llvmops;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 opglob,parserglob,msestream,llvmbcwriter,llvmbitcodes;

//todo: generate bitcode, use static string buffers, no ansistrings
 
function getoptable: poptablety;
function getssatable: pssatablety;
//procedure allocproc(const asize: integer; var address: segaddressty);

procedure run(const atarget: tllvmbcwriter);
 
implementation
uses
 sysutils,msesys,segmentutils,handlerglob,elements,msestrings,compilerunit,
 handlerutils,llvmlists,errorhandler,__mla__internaltypes,opcode,msearrayutils,
 interfacehandler;

type
 icomparekindty = (ick_eq,ick_ne,
                  ick_ugt,ick_uge,ick_ult,ick_ule,
                  ick_sgt,ick_sge,ick_slt,ick_sle);
 idsarty = array[0..maxparamcount-1] of int32;
var
 pc: popinfoty;
 i32consts: array[0..32] of int32;
 trampolinealloc: suballocinfoty;
 
 
type
 internalfuncinfoty = record
  name: string;
  flags: subflagsty;
  params: pparamsty;
 end;
 internalfuncty = (if_printf,if_malloc,if_free,if_calloc,if_memset,
                   if__exit{,
                   if__Unwind_RaiseException});
const
 printfpar: array[0..0] of paramitemty = (
              (typelistindex: pointertype; flags: [])
 );
 printfparams: paramsty = (count: 1; items: @printfpar);
 mallocpar: array[0..1] of paramitemty = (
              (typelistindex: sizetype; flags: []),    //size
              (typelistindex: pointertype; flags: [])  //result
 );
 mallocparams: paramsty = (count: 2; items: @mallocpar);
 freepar: array[0..0] of paramitemty = (
              (typelistindex: pointertype; flags: [])  //ptr
 );
 freeparams: paramsty = (count: 1; items: @freepar);
 callocpar: array[0..2] of paramitemty = (
              (typelistindex: sizetype; flags: []),    //nelm
              (typelistindex: sizetype; flags: []),    //elsize
              (typelistindex: pointertype; flags: [])  //result
 );
 callocparams: paramsty = (count: 3; items: @callocpar);
 memsetpar: array[0..3] of paramitemty = (
              (typelistindex: pointertype; flags: []), //s data
              (typelistindex: inttype; flags: []),     //c fill value
              (typelistindex: sizetype; flags: []),    //n count
              (typelistindex: pointertype; flags: [])  //result
 );
 memsetparams: paramsty = (count: 4; items: @memsetpar);

 _exitpar: array[0..0] of paramitemty = (
              (typelistindex: inttype; flags: [])      //status
 );
 _exitparams: paramsty = (count: 1; items: @_exitpar);

 _Unwind_RaiseExceptionpar: array[0..0] of paramitemty = (
              (typelistindex: pointertype; flags: [])  //ptr
 );
 _Unwind_RaiseExceptionparams: paramsty = 
                      (count: 1; items: @_Unwind_RaiseExceptionpar);
 
 internalfuncconsts: array[internalfuncty] of internalfuncinfoty = (
  (name: 'printf'; flags: [sf_proto,sf_vararg]; params: @printfparams),
  (name: 'malloc'; flags: [sf_proto,sf_function]; params: @mallocparams),
  (name: 'free'; flags: [sf_proto]; params: @freeparams),
  (name: 'calloc'; flags: [sf_proto,sf_function]; params: @callocparams),
  (name: 'memset'; flags: [sf_proto,sf_function]; params: @memsetparams),
  (name: '_exit'; flags: [sf_proto]; params: @_exitparams){,
  (name: '_Unwind_RaiseException'; flags: [sf_proto];
                     params: @_Unwind_RaiseExceptionparams)}  
 );

type
 internalstringinfoty = record
  text: string;
 end;
 internalstringty = (is_ret,is_int32,is_string8,is_pointer);
const
 internalstringconsts: array[internalstringty] of internalstringinfoty = (
  (text: #$a#0),        //is_ret,
  (text: '%d'#0),       //is_int32,
  (text: '%s'#0),       //is_string8,
  (text: '%p'#0)        //is_pointer
 );  

var
 bcstream: tllvmbcwriter;
 globconst: string;
 internalfuncs: array[internalfuncty] of int32;
 internalstrings: array[internalstringty] of int32;
 
procedure outbinop(const aop: BinaryOpcodes);
begin
 with pc^.par do begin
  bcstream.emitbinop(aop,bcstream.ssaval(ssas1),bcstream.ssaval(ssas2));
 end;
end;

procedure notimplemented();
begin
 raise exception.create('LLVM OP not implemented');
end;

procedure storeseg(const source: int32);
begin
 with pc^.par do begin
  if af_aggregate in memop.t.flags then begin
   bcstream.emitsegdataaddresspo(memop);
//   bcstream.emitgetelementptr(bcstream.globval(a.address),
//                                         bcstream.constval(offset));
//   bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(t.listindex));
   bcstream.emitstoreop(source,bcstream.relval(0));
  end
  else begin
   bcstream.emitstoreop(source,
                  bcstream.globval(memop.segdataaddress.a.address));
  end;
 end;
end;

procedure storeseg();
begin
 storeseg(bcstream.ssaval(pc^.par.ssas1));
end;

procedure storelastseg(); //store last ssa value
begin
 storeseg(bcstream.relval(0));
end;

procedure loadseg();
begin
 with pc^.par do begin
  if af_aggregate in memop.t.flags then begin
   bcstream.emitsegdataaddresspo(memop);
   bcstream.emitloadop(bcstream.relval(0));
  end
  else begin
   bcstream.emitloadop(bcstream.globval(memop.segdataaddress.a.address));
  end;
 end;
end;

procedure storeloc(const source: int32);
begin
 with pc^.par do begin
  with memop,locdataaddress do begin
   if a.framelevel >= 0 then begin  //nested variable
    bcstream.emitgetelementptr(bcstream.subval(0),
            //pointer to array of pointer to local alloc
                                           bcstream.constval(a.address));
            //byte offset in array
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitloadop(bcstream.relval(0));
            //pointer to variable
    if af_aggregate in t.flags then begin
     bcstream.emitnopssaop();          //agregatessa = 3
     bcstream.emitgetelementptr(bcstream.relval(1),bcstream.constval(offset));
    end;
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(t.listindex));
    bcstream.emitstoreop(source,bcstream.relval(0));
   end
   else begin
    if af_aggregate in t.flags then begin
     bcstream.emitlocdataaddresspo(memop);
     bcstream.emitstoreop(source,bcstream.relval(0));
    end
    else begin
     bcstream.emitstoreop(source,bcstream.allocval(a.address));
    end;
   end;
  end;
 end;
end;

procedure storelocindi(const source: int32);
var
 str1,str2,dest1,dest2: shortstring;
begin
 with pc^.par do begin           
  with memop,locdataaddress do begin
  {$ifdef mse_checkinternalerror}
   if a.framelevel >= 0 then begin  //nested variable not possible, called from
                                    //popparindi*() only.
    internalerror(ie_llvm,'20150313A');
   end;
  {$endif}
   bcstream.emitloadop(bcstream.allocval(a.address)); //^variable
   if af_aggregate in t.flags then begin
    bcstream.emitnopssaop(); //aggregatessa = 3
    bcstream.emitgetelementptr(bcstream.relval(1),
                          bcstream.constval(offset));
   end;
   bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(t.listindex));
   bcstream.emitstoreop(source,bcstream.relval(0));
  end;
 end;
end;

procedure storeloc();
begin
 storeloc(bcstream.ssaval(pc^.par.ssas1));
end;

procedure storelastloc(); //store last ssa value
begin
 storeloc(bcstream.relval(0));
end;

procedure loadindirect();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),
                    bcstream.ptypeval(memop.t.listindex));
  bcstream.emitloadop(bcstream.relval(0));
 end;
end;

procedure loadloc();
begin
 with pc^.par do begin
  with memop,locdataaddress do begin
   if a.framelevel >= 0 then begin
    bcstream.emitgetelementptr(bcstream.subval(0),
            //pointer to array of pointer to local alloc
                                           bcstream.constval(a.address));
            //byte offset in array
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitloadop(bcstream.relval(0));
            //pointer to variable
    if af_aggregate in t.flags then begin
     bcstream.emitnopssaop();          //agregatessa = 3
     bcstream.emitgetelementptr(bcstream.relval(1),bcstream.constval(offset));
    end;
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(t.listindex));
    bcstream.emitloadop(bcstream.relval(0));
   end
   else begin
    if af_temp in t.flags then begin
     bcstream.emitbitcast(bcstream.ssaval(a.ssaindex),t.listindex);
    end
    else begin
     if af_aggregate in t.flags then begin
      bcstream.emitlocdataaddresspo(memop);
      bcstream.emitloadop(bcstream.relval(0));
     end
     else begin
      bcstream.emitloadop(bcstream.allocval(a.address));
     end;
    end;
   end;
  end;
 end;
end;

procedure loadlocindi();
begin
 loadloc();
 bcstream.emitloadop(bcstream.relval(0));
end;

procedure comparessa(const apredicate: predicate);
begin
 with pc^.par do begin
  bcstream.emitcmpop(apredicate,bcstream.ssaval(ssas1),bcstream.ssaval(ssas2));
 end;
end;

procedure callcompilersub(const asub: compilersubty;
          const afunc: boolean; const aparams: array of int32);
begin
 bcstream.emitcallop(afunc,bcstream.globval(compilersubids[asub]),aparams);
end;

procedure nopop();
begin
 with pc^.par do begin
  bcstream.emitnopssaop();
 end;
end;

procedure labelop();
begin
 with pc^.par do begin
  bcstream.emitbrop(opaddress.bbindex);
 end;
end;

var
 exitcodeaddress: segaddressty;
 finihandler: int32; //globid

procedure beginparseop();
var
 ele1,ele2: elementoffsetty;
 po1: punitdataty;
 po2: pvardataty;
 po3: ptypedataty;
 po4: popinfoty;
 int1: integer;
 str1,str2: shortstring;
 funcs1: internalfuncty;
 strings1: internalstringty;
 compilersub1: compilersubty;
 poclassdef,peclassdef: ^classdefinfoty;
 povirtual,pevirtual: popaddressty;
 i1,i2,i3: int32;
 virtualcapacity: int32;
 virtualsubs,virtualsubconsts: pint32;
 countpo,counte: pint32;
 intfpo: pintfdefinfoty;
begin
 for int1:= low(i32consts) to high(i32consts) do begin
  i32consts[int1]:= constlist.addi32(int1).listid;
 end;
 fillchar(trampolinealloc,sizeof(trampolinealloc),0); //used in subbeginop

 int1:= getsegmentsize(seg_globconst);
 if int1 > 0 then begin                               //global consts
  bcstream.constseg:= globlist.addinitvalue(gak_var,
             constlist.addvalue(getsegmentpo(seg_globconst,0)^,int1).listid);
 end;

// globlist.addsubvalue(nil,stringtolstring('main'));
 for funcs1:= low(internalfuncs) to high(internalfuncs) do begin
  with internalfuncconsts[funcs1] do begin
   internalfuncs[funcs1]:= globlist.addexternalsubvalue(flags,params^,
                                                    stringtolstring(name));
  end;
 end;
 for strings1:= low(internalstringconsts) to high(internalstringconsts) do begin
                                       //string consts
  with internalstringconsts[strings1] do begin
   internalstrings[strings1]:= globlist.addinitvalue(gak_const,
                     constlist.addvalue(pointer(text)^,length(text)).listid);
  end;
 end;

 countpo:= getsegmentbase(seg_intfitemcount); //interfaces
 counte:= getsegmenttoppo(seg_intfitemcount);
 intfpo:= getsegmentbase(seg_intf);
 while countpo < counte do begin
  if countpo^ > 0 then begin
   pint32(intfpo)^:= globlist.addinitvalue(gak_const,
                          constlist.addintfdef(intfpo,countpo^).listid);
  end;
  inc(pointer(intfpo),sizeof(intfpo^)+countpo^*opaddresssize);
  inc(countpo);
 end;

 poclassdef:= getsegmentbase(seg_classdef);
 peclassdef:= getsegmenttoppo(seg_classdef);
 virtualcapacity:= 0;
 virtualsubs:= nil; 
 virtualsubconsts:= nil;
 countpo:= getsegmentbase(seg_classintfcount);
 try
  while poclassdef < peclassdef do begin   //classes
   pint32(poclassdef)^:= globlist.addinitvalue(gak_const,
             constlist.addclassdef(poclassdef,countpo^).listid);
   poclassdef:= pointer(poclassdef) +
                        poclassdef^.header.allocs.classdefinterfacestart +
                                                         countpo^*pointersize;
   inc(countpo);
  end;
 finally
  if virtualsubs <> nil then begin
   freemem(virtualsubs);
   freemem(virtualsubconsts);
  end;
 end;
 with pc^.par.beginparse do begin
  bcstream.start(constlist,globlist);
  llvmops.exitcodeaddress:= exitcodeaddress;
  if finisub = 0 then begin
   llvmops.finihandler:= 0;
  end
  else begin
   llvmops.finihandler:= getoppo(finisub)^.par.subbegin.globid;
  end;
 end;
end;

procedure mainop();
begin
 with pc^.par do begin
  bcstream.beginsub([]{false},nullallocs,main.blockcount);
 end;
end;

procedure progendop();
var
 i1: int32;
begin
 bcstream.emitloadop(bcstream.valindex(exitcodeaddress));
 bcstream.emitretop(bcstream.ssaindex-1);
 bcstream.endsub();
end;

procedure endparseop();
begin
 bcstream.stop();
end;

procedure haltop();
begin
 if finihandler <> 0 then begin
  bcstream.emitcallop(false,bcstream.globval(finihandler),[]);
 end;  
 bcstream.emitloadop(bcstream.valindex(exitcodeaddress));
 bcstream.emitcallop(false,bcstream.globval(internalfuncs[if__exit]),
                                                      [bcstream.relval(0)]);
end;

procedure movesegreg0op();
begin
 notimplemented();
end;
procedure moveframereg0op();
begin
 notimplemented();
end;
procedure popreg0op();
begin
 notimplemented();
end;
procedure increg0op();
begin
 notimplemented();
end;

procedure gotoop();
begin
 with pc^.par do begin
  bcstream.emitbrop(getoppo(opaddress.opaddress+1)^.par.opaddress.bbindex);
 end;
end;

procedure cmpjmpneimm4op();
begin
 notimplemented();
end;
procedure cmpjmpeqimm4op();
begin
 notimplemented();
end;
procedure cmpjmploimm4op();
begin
 notimplemented();
end;
procedure cmpjmpgtimm4op();
begin
 notimplemented();
end;
procedure cmpjmploeqimm4op();
begin
 notimplemented();
end;

procedure ifop();
begin
 with pc^.par do begin
  bcstream.emitbrop(bcstream.ssaval(ssas1),opaddress.bbindex,
                         getoppo(opaddress.opaddress)^.par.opaddress.bbindex);
 end;
end;

procedure whileop();
begin
 with pc^.par do begin
  bcstream.emitbrop(bcstream.ssaval(ssas1),opaddress.bbindex,
                         getoppo(opaddress.opaddress)^.par.opaddress.bbindex);
 end;
end;

procedure untilop();
begin
 with pc^.par do begin
  bcstream.emitbrop(bcstream.ssaval(ssas1),opaddress.bbindex,
                         getoppo(opaddress.opaddress+1)^.par.opaddress.bbindex);
 end;
end;

procedure writelnop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_ret]),
                                             bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                                                      [bcstream.relval(0)]);
 end;
end;

procedure writebooleanop();
begin
 notimplemented();
end;
 
procedure writeintegerop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_int32]),
                                           bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                               [bcstream.relval(0),bcstream.ssaval(ssas1)]);
 end;
end;

procedure writefloatop();
begin
 notimplemented();
end;

procedure writestring8op();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_string8]),
                                           bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                               [bcstream.relval(0),bcstream.ssaval(ssas1)]);
 end;
end;

procedure writepointerop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_pointer]),
                                           bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                               [bcstream.relval(0),bcstream.ssaval(ssas1)]);
 end;
end;

procedure writeclassop();
begin
 writepointerop();
end;

procedure writeenumop();
begin
 notimplemented();
end;

procedure pushop();
begin
 //dummy
// notimplemented();
end;

procedure popop();
begin
 //dummy
// notimplemented();
end;

procedure pushimm1op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm8op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm16op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm32op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm64op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimmdatakindop();
begin
 notimplemented();
end;

procedure int32toflo64op();
begin
 notimplemented();
end;

procedure potoint32op();
begin
 with pc^.par do begin
  bcstream.emitcastop(bcstream.ssaval(ssas1),bcstream.typeval(das_32),
                                                               CAST_PTRTOINT);
 end;
end;

procedure inttopoop();
begin
 with pc^.par do begin
  bcstream.emitcastop(bcstream.ssaval(ssas1),bcstream.typeval(pointertype),
                                                               CAST_INTTOPTR);
 end;
end;

procedure and1op();
begin
 outbinop(BINOP_AND);
end;

procedure and32op();
begin
 outbinop(BINOP_AND);
end;

procedure or1op();
begin
 outbinop(BINOP_OR);
end;

procedure or32op();
begin
 outbinop(BINOP_OR);
end;

procedure mulint32op();
begin
 notimplemented();
end;

procedure mulimmint32op();
begin
 with pc^.par do begin
  bcstream.emitbinop(BINOP_MUL,bcstream.ssaval(ssas1),
                                    bcstream.constval(imm.llvm.listid));
 end;
end;

procedure mulflo64op();
begin
 notimplemented();
end;

procedure addint32op();
begin
 outbinop(BINOP_ADD);
end;

procedure subint32op();
begin
 outbinop(BINOP_SUB);
end;

procedure addpoint32op();
begin
 with pc^.par do begin
  bcstream.emitgetelementptr(bcstream.ssaval(ssas1),bcstream.ssaval(ssas2));
 end;
end;

procedure subpoop();
begin
 with pc^.par do begin
  bcstream.emitcastop(bcstream.ssaval(ssas1),
                               bcstream.typeval(sizetype),CAST_PTRTOINT);
  bcstream.emitcastop(bcstream.ssaval(ssas2),
                               bcstream.typeval(sizetype),CAST_PTRTOINT);
  bcstream.emitbinop(BINOP_SUB,bcstream.relval(1),bcstream.relval(0));
 end;
end;

procedure addimmint32op();
begin
 notimplemented();
end;

procedure addflo64op();
begin
 notimplemented();
end;

procedure subflo64op();
begin
 notimplemented();
end;

procedure negcard32op();
begin
 notimplemented();
end;
procedure negint32op();
begin
 notimplemented();
end;
procedure negflo64op();
begin
 notimplemented();
end;

procedure offsetpoimm32op();
begin
 with pc^.par do begin
  bcstream.emitgetelementptr(bcstream.ssaval(ssas1),
                                    bcstream.constval(imm.llvm.listid));
 end;
end;

procedure incdecsegimmint32op();
begin
 with pc^.par,memimm do begin
  loadseg();
  bcstream.emitbinop(BINOP_ADD,bcstream.relval(0),
                                bcstream.constval(llvm.listid));
  storelastseg();
 end;
end;

procedure incdecsegimmpo32op();
begin
 with pc^.par,memimm do begin
  loadseg();
  bcstream.emitgetelementptr(bcstream.relval(0),bcstream.constval(llvm.listid));
  storelastseg();
 end;
end;

procedure incdeclocimmint32op();
begin
 with pc^.par,memimm do begin
  loadloc();
  bcstream.emitbinop(BINOP_ADD,bcstream.relval(0),
                                bcstream.constval(llvm.listid));
  storelastloc();
 end;
end;

procedure incdeclocimmpo32op();
var
 str1,str2: shortstring;
begin
 with pc^.par,memimm do begin
  loadloc();
  bcstream.emitgetelementptr(bcstream.relval(0),bcstream.constval(llvm.listid));
  storelastloc();
 end;
end;

procedure incdecparimmint32op();
begin
 notimplemented();
end;

procedure incdecparimmpo32op();
begin
 incdeclocimmpo32op();
end;

procedure incdecparindiimmint32op();
begin
 notimplemented();
end;

procedure incdecparindiimmpo32op();
begin
 notimplemented();
end;

procedure incdecindiimmint32op();
begin
 with pc^.par,memimm do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(das_32));
  bcstream.emitloadop(bcstream.relval(0));
  bcstream.emitbinop(BINOP_ADD,bcstream.relval(0),
                                  bcstream.constval(llvm.listid));
  bcstream.emitstoreop(bcstream.relval(0),bcstream.relval(2));
 end;
end;

procedure incdecindiimmpo32op();
begin
 with pc^.par,memimm do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitloadop(bcstream.relval(0));
  bcstream.emitptroffset(bcstream.relval(0),bcstream.constval(llvm.listid));
  bcstream.emitstoreop(bcstream.relval(0),bcstream.relval(2));
 end;
end;

procedure comparepo(const apredicate: predicate);
begin
 with pc^.par do begin
  bcstream.emitcastop(bcstream.ssaval(ssas1),
                              bcstream.typeval(sizetype),CAST_PTRTOINT);
  bcstream.emitcastop(bcstream.ssaval(ssas2),
                              bcstream.typeval(sizetype),CAST_PTRTOINT);
  bcstream.emitcmpop(apredicate,bcstream.relval(1),bcstream.relval(0));
 end;
end;

procedure cmpeqpoop();
begin
 comparessa(icmp_eq);
// comparepo(icmp_eq);
end;

procedure cmpeqboolop();
begin
 notimplemented();
end;

procedure cmpeqint32op();
begin
 comparessa(icmp_eq);
end;

procedure cmpeqflo64op();
begin
 notimplemented();
end;

procedure cmpnepoop();
begin
 comparessa(icmp_ne);
// comparepo(icmp_ne);
end;

procedure cmpneboolop();
begin
 notimplemented();
end;

procedure cmpneint32op();
begin
 comparessa(icmp_ne);
end;

procedure cmpneflo64op();
begin
 notimplemented();
end;

procedure cmpgtpoop();
begin
 comparessa(icmp_ugt);
// comparepo(icmp_ugt);
end;

procedure cmpgtboolop();
begin
 notimplemented();
end;

procedure cmpgtint32op();
begin
 comparessa(icmp_sgt);
end;

procedure cmpgtflo64op();
begin
 notimplemented();
end;

procedure cmpltpoop();
begin
 comparessa(icmp_ult);
// comparepo(icmp_ult);
end;

procedure cmpltboolop();
begin
 notimplemented();
end;

procedure cmpltint32op();
begin
 comparessa(icmp_slt);
end;

procedure cmpltflo64op();
begin
 notimplemented();
end;

procedure cmpgepoop();
begin
 notimplemented();
end;

procedure cmpgeboolop();
begin
 notimplemented();
end;

procedure cmpgeint32op();
begin
 comparessa(icmp_sge);
end;

procedure cmpgeflo64op();
begin
 notimplemented();
end;

procedure cmplepoop();
begin
 notimplemented();
end;

procedure cmpleboolop();
begin
 notimplemented();
end;

procedure cmpleint32op();
begin
 comparessa(icmp_sle);
end;

procedure cmpleflo64op();
begin
 notimplemented();
end;

procedure storesegnilop();
var
 str1: shortstring;
begin
 with pc^.par do begin
  bcstream.emitstoreop(bcstream.constval(nullpointer),
                     bcstream.globval(memop.segdataaddress.a.address));
 end;
end;

procedure storereg0nilop();
begin
 notimplemented();
end;

procedure storeframenilop();
begin
 with pc^.par do begin
  bcstream.emitstoreop(bcstream.constval(nullpointer),
                                         bcstream.allocval(vaddress));
 end;
end;

procedure storestacknilop();
begin
 notimplemented();
end;
procedure storestackrefnilop();
begin
 notimplemented();
end;
procedure storesegnilarop();
begin
 notimplemented();
end;
procedure storeframenilarop();
begin
 notimplemented();
end;
procedure storereg0nilarop();
begin
 notimplemented();
end;
procedure storestacknilarop();
begin
 notimplemented();
end;
procedure storestackrefnilarop();
begin
 notimplemented();
end;

procedure finirefsizesegop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(memop.segdataaddress.a.address),
                                                bcstream.typeval(pointertype));
  callcompilersub(cs_finifrefsize,false,[bcstream.relval(0)]);
 end;
end;

procedure finirefsizeframeop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.allocval(vaddress),
                                                bcstream.typeval(pointertype));
  callcompilersub(cs_finifrefsize,false,[bcstream.relval(0)]);
 end;
end;

procedure finirefsizereg0op();
begin
 notimplemented();
end;
procedure finirefsizestackop();
begin
 notimplemented();
end;
procedure finirefsizestackrefop();
begin
 notimplemented();
end;
procedure finirefsizeframearop();
begin
 notimplemented();
end;
procedure finirefsizesegarop();
begin
 notimplemented();
end;
procedure finirefsizereg0arop();
begin
 notimplemented();
end;
procedure finirefsizestackarop();
begin
 notimplemented();
end;
procedure finirefsizestackrefarop();
begin
 notimplemented();
end;

procedure increfsizesegop();
begin
 notimplemented();
end;
procedure increfsizeframeop();
begin
 notimplemented();
end;
procedure increfsizereg0op();
begin
 notimplemented();
end;
procedure increfsizestackop();
begin
 notimplemented();
end;
procedure increfsizestackrefop();
begin
 notimplemented();
end;
procedure increfsizeframearop();
begin
 notimplemented();
end;
procedure increfsizesegarop();
begin
 notimplemented();
end;
procedure increfsizereg0arop();
begin
 notimplemented();
end;
procedure increfsizestackarop();
begin
 notimplemented();
end;
procedure increfsizestackrefarop();
begin
 notimplemented();
end;

procedure decrefsizesegop();
begin
 with pc^.par do begin
  bcstream.emitloadop(bcstream.globval(memop.segdataaddress.a.address));
  callcompilersub(cs_decrefsize,false,[bcstream.relval(0)]);
 end;
end;

procedure decrefsizeframeop();
begin
 with pc^.par do begin
  bcstream.emitloadop(bcstream.allocval(vaddress));
  callcompilersub(cs_decrefsize,false,[bcstream.relval(0)]);
 end;
end;

procedure decrefsizereg0op();
begin
 notimplemented();
end;
procedure decrefsizestackop();
begin
 notimplemented();
end;
procedure decrefsizestackrefop();
begin
 notimplemented();
end;
procedure decrefsizeframearop();
begin
 notimplemented();
end;
procedure decrefsizesegarop();
begin
 notimplemented();
end;
procedure decrefsizereg0arop();
begin
 notimplemented();
end;
procedure decrefsizestackarop();
begin
 notimplemented();
end;
procedure decrefsizestackrefarop();
begin
 notimplemented();
end;

procedure popseg8op();
begin
 storeseg();
end;

procedure popseg16op();
begin
 storeseg();
end;

procedure popseg32op();
begin
 storeseg();
end;

procedure popseg64op();
begin
 storeseg();
end;

procedure popsegpoop();
var
 str1: shortstring;
begin
 storeseg();
{
 with pc^.par do begin
  bcstream.emitstoreop(bcstream.ssaval(ssas1),
                     bcstream.globval(memop.segdataaddress.a.address));
 end;
}
end;

procedure popsegf16op();
begin
 storeseg();
end;

procedure popsegf32op();
begin
 storeseg();
end;

procedure popsegf64op();
begin
 storeseg();
end;

procedure popsegop();
begin
 notimplemented();
end;

procedure poploc8op();
begin
 storeloc();
end;

procedure poploc16op();
begin
 storeloc();
end;

procedure poploc32op();
begin
 storeloc();
end;

procedure poploc64op();
begin
 storeloc();
end;

procedure poplocpoop();
begin
 storeloc();
end;

procedure poplocf16op();
begin
 storeloc();
end;

procedure poplocf32op();
begin
 storeloc();
end;

procedure poplocf64op();
begin
 storeloc();
end;

procedure poplocop();
begin
 notimplemented();
end;

procedure poplocindi8op();
begin
 storeloc();
end;

procedure poplocindi16op();
begin
 storeloc();
end;

procedure poplocindi32op();
begin
 storeloc();
end;

procedure poplocindi64op();
begin
 storeloc();
end;

procedure poplocindipoop();
begin
 notimplemented();
end;

procedure poplocindif16op();
begin
 storeloc();
end;

procedure poplocindif32op();
begin
 storeloc();
end;

procedure poplocindif64op();
begin
 storeloc();
end;

procedure poplocindiop();
begin
 notimplemented();
end;

procedure poppar8op();
begin
 storeloc();
end;

procedure poppar16op();
begin
 storeloc();
end;

procedure poppar32op();
begin
 storeloc();
end;

procedure poppar64op();
begin
 storeloc();
end;

procedure popparpoop();
begin
 notimplemented();
end;

procedure popparf16op();
begin
 storeloc();
end;

procedure popparf32op();
begin
 storeloc();
end;

procedure popparf64op();
begin
 storeloc();
end;

procedure popparop();
begin
 notimplemented();
end;

procedure popparindi8op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindi16op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindi32op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindi64op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindipoop();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindif16op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindif32op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindif64op();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure popparindiop();
begin
 storelocindi(bcstream.ssaval(pc^.par.ssas1));
end;

procedure pushnilop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.constval(nullpointer),
                               bcstream.typeval(pointertype));
 end;
end;

procedure pushsegaddressop();
begin
 notimplemented();
end;

procedure pushseg8op();
begin
 loadseg();
end;

procedure pushseg16op();
begin
 loadseg();
end;

procedure pushseg32op();
begin
 loadseg();
end;

procedure pushseg64op();
begin
 loadseg();
end;

procedure pushsegpoop();
begin
 loadseg();
end;

procedure pushsegf16op();
begin
 loadseg();
end;

procedure pushsegf32op();
begin
 loadseg();
end;

procedure pushsegf64op();
begin
 loadseg();
end;

procedure pushsegop();
begin
 loadseg();
end;

procedure pushloc8op();
begin
 loadloc();
end;

procedure pushloc16op();
begin
 loadloc();
end;

procedure pushloc32op();
begin
 loadloc();
end;

procedure pushloc64op();
begin
 loadloc();
end;

procedure pushlocpoop();
begin
 loadloc();
end;

procedure pushlocf16op();
begin
 loadloc();
end;

procedure pushlocf32op();
begin
 loadloc();
end;

procedure pushlocf64op();
begin
 loadloc();
end;

procedure pushlocop();
begin
 loadloc();
end;

procedure pushpar8op();
begin
 loadloc();
end;

procedure pushpar16op();
begin
 loadloc();
end;

procedure pushpar32op();
begin
 loadloc();
end;

procedure pushpar64op();
begin
 loadloc();
end;

procedure pushparpoop();
begin
 loadloc();
end;

procedure pushparf16op();
begin
 loadloc();
end;

procedure pushparf32op();
begin
 loadloc();
end;

procedure pushparf64op();
begin
 loadloc();
end;

procedure pushparop();
begin
 loadloc();
end;

procedure pushlocindi8op();
begin
 loadlocindi();
end;

procedure pushlocindi16op();
begin
 loadlocindi();
end;

procedure pushlocindi32op();
begin
 loadlocindi();
end;

procedure pushlocindi64op();
begin
 loadlocindi();
end;

procedure pushlocindipoop();
begin
 loadlocindi();
end;

procedure pushlocindif16op();
begin
 loadlocindi();
end;

procedure pushlocindif32op();
begin
 loadlocindi();
end;

procedure pushlocindif64op();
begin
 loadlocindi();
end;

procedure pushlocindiop();
begin
 loadlocindi();
end;

procedure pushaddrop();
begin
 notimplemented();
end;

procedure pushlocaddrop();
begin
 with pc^.par do begin
  bcstream.emitlocdataaddress(memop);
 end;
end;
{
procedure pushlocaddrindiop();          //todo: nested frames
begin
 with pc^.par do begin
  if memop.locdataaddress.a.framelevel >= 0 then begin
   notimplemented();
  end;
  bcstream.emitloadop(bcstream.allocval(memop.locdataaddress.a.address));
  bcstream.emitgetelementptr(bcstream.relval(0),
                bcstream.constval(memop.locdataaddress.offset));
 end;
end;
}
procedure pushsegaddrop();
var
 str1: shortstring;
begin
 with pc^.par do begin
  bcstream.emitsegdataaddress(memop);
 end;
end;
{
procedure pushsegaddrindiop(); //offset after load
begin
 with pc^.par do begin
  bcstream.emitloadop(bcstream.globval(memop.segdataaddress.a.address));
  bcstream.emitgetelementptr(bcstream.relval(0),
                bcstream.constval(memop.segdataaddress.offset));
 end;
end;
}
procedure pushstackaddrop();
begin
 notimplemented();
end;
{
procedure pushstackaddrindiop();
begin
 notimplemented();
end;
}
procedure pushduppoop();
begin
 notimplemented();
end;

procedure indirect8op();
begin
 loadindirect();
end;

procedure indirect16op();
begin
 loadindirect();
end;

procedure indirect32op();
begin
 loadindirect();
end;

procedure indirect64op();
begin
 loadindirect();
end;

procedure indirectpoop();
var
 dest1,dest2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitloadop(bcstream.relval(0));
 end;
end;

procedure indirectf16op();
begin
 loadindirect();
end;

procedure indirectf32op();
begin
 loadindirect();
end;

procedure indirectf64op();
begin
 loadindirect();
end;

procedure indirectpooffsop();
begin //offset after indirect
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitptroffset(bcstream.relval(0),bcstream.constval(voffset));
 end;
end; 

procedure indirectoffspoop();
begin
 notimplemented();
end; //offset before indirect
procedure indirectop();
begin
 notimplemented();
end;

procedure popindirect();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas2),
                              bcstream.ptypeval(memop.t.listindex));
  bcstream.emitstoreop(bcstream.ssaval(ssas1),bcstream.relval(0));
 end;
end;

procedure popindirect8op();
begin
 popindirect();
end;

procedure popindirect16op();
begin
 popindirect();
end;

procedure popindirect32op();
begin
 popindirect();
end;

procedure popindirect64op();
begin
 popindirect();
end;

procedure popindirectpoop();
begin
 popindirect();
end;

procedure popindirectf16op();
begin
 popindirect();
end;

procedure popindirectf32op();
begin
 popindirect();
end;

procedure popindirectf64op();
begin
 popindirect();
end;

procedure popindirectop();
begin
 popindirect();
end;

procedure dooutlink(const outlinkcount: integer);
var
 i1: int32;
begin
 with pc^.par do begin
  if (outlinkcount > 0) and (sf_hasnestedaccess in callinfo.flags) then begin
   bcstream.emitgetelementptr(bcstream.subval(0),
                     bcstream.constval(nullpointeroffset)); //nested vars
   for i1:= outlinkcount-2 downto 0 do begin;
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitloadop(bcstream.relval(0));
   end;
  end;
 end;
end;

procedure docallparam(const outlinkcount: int32; var ids: idarty);
var
 parpo,endpo: pparallocinfoty;
 po1: pint32;
begin
 with pc^.par do begin
  ids.count:= callinfo.paramcount;
  po1:= ids.ids;
  if sf_hasnestedaccess in callinfo.flags then begin
   if outlinkcount > 0 then begin
    po1^:= bcstream.relval(0);
   end
   else begin
    po1^:= bcstream.ssaval(-1); //last alloc is nested var ref table
   end;
   inc(po1);
   inc(ids.count);
  end;
 {$ifdef mse_checkinternalerror}
  if ids.count >= high(idsarty) then begin
   internalerror(ie_llvm,'20150122');
  end;
 {$endif}
  parpo:= getsegmentpo(seg_localloc,callinfo.params);
  endpo:= parpo + callinfo.paramcount;  
  if sf_function in callinfo.flags then begin
   inc(parpo);            //skip result param
   dec(ids.count);
  end;
  while parpo < endpo do begin
   po1^:= bcstream.ssaval(parpo^.ssaindex);
   inc(po1);
   inc(parpo);
  end;
 end;
end;

procedure docall(const outlinkcount: integer; const aindirect: boolean);
var
 ids: idsarty;
 idar: idarty;
 i1: int32;
begin
 with pc^.par do begin               //todo: calling convention
  idar.ids:= @ids;
  if aindirect then begin
   bcstream.emitbitcast(bcstream.ssaval(ssas1),                     //1ssa
                         bcstream.ptypeval(callinfo.indi.typeid));
   i1:= bcstream.relval(0);
  end
  else begin
   i1:= bcstream.globval(getoppo(callinfo.ad+1)^.par.subbegin.globid);
  end;
  docallparam(outlinkcount,idar);
  bcstream.emitcallop(sf_function in callinfo.flags,i1,idar);
 end;
end;

procedure callop();
begin
 docall(0,false);
end;

procedure callfuncop();
begin
 docall(0,false);
end;

procedure callindiop();
begin
 docall(0,true);
end;

procedure callfuncindiop();
begin
 docall(0,true);
end;

procedure calloutop();
var
 int1: integer;
begin
 with pc^.par do begin
  int1:= callinfo.linkcount+2;
  dooutlink(int1);
  docall(int1,false);
 end;
end;

procedure callfuncoutop();
var
 int1: integer;
begin
 with pc^.par do begin
  int1:= callinfo.linkcount+2;
  dooutlink(int1);
  docall(int1,false);
 end;
end;

procedure callvirtop();
var
 ids: idsarty;
 idar: idarty;
 i1: int32;
begin
 with pc^.par do begin               //todo: calling convention
  idar.ids:= @ids;
  docallparam(0,idar);
  bcstream.emitbitcast(ids[0],bcstream.ptypeval(pointertype)); //1ssa **i8
  bcstream.emitloadop(bcstream.relval(0));                     //1ssa *i8
               //class def
  bcstream.emitgetelementptr(bcstream.relval(0),               
                     bcstream.constval(callinfo.virt.virtoffset));//2ssa *i8
               //virtual table item address
  bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(pointertype));
                                                                  //1ssa **i8
  bcstream.emitloadop(bcstream.relval(0));                        //1ssa *i8
               //sub address
  bcstream.emitbitcast(bcstream.relval(0),                     //1ssa
                         bcstream.ptypeval(callinfo.virt.typeid));
  bcstream.emitcallop(sf_function in callinfo.flags,bcstream.relval(0),idar);
 end;
end;

procedure callintfop();
var
 ids: idsarty;
 idar: idarty;
 i1: int32;
begin
 with pc^.par do begin               //todo: calling convention
  idar.ids:= @ids;
  docallparam(0,idar);
  bcstream.emitbitcast(ids[0],bcstream.ptypeval(pointertype)); //1ssa **i8
  bcstream.emitloadop(bcstream.relval(0));                     //1ssa *i8
              //interface base
  bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(inttype));
                                                               //1ssa *i32
  bcstream.emitloadop(bcstream.relval(0));                     //1ssa i32
              //instanceoffset
  bcstream.emitgetelementptr(ids[0],bcstream.relval(0));       //2ssa *i8
              //shift instance po
  ids[0]:= bcstream.relval(0); //class instance
  bcstream.emitgetelementptr(bcstream.relval(3),                   //2ssa *i8
       bcstream.constval(callinfo.virt.virtoffset));
              //interface table item address
  bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(pointertype));
                                                               //1ssa **i8
  bcstream.emitloadop(bcstream.relval(0));                     //1ssa *i8
               //sub address
  bcstream.emitbitcast(bcstream.relval(0),                     //1ssa
                         bcstream.ptypeval(callinfo.virt.typeid));
  bcstream.emitcallop(sf_function in callinfo.flags,bcstream.relval(0),idar);
 end;
end;

procedure virttrampolineop();
begin
 bcstream.marktrampoline(pc);
end;

procedure locvarpushop();
begin
 //dummy
end;

procedure locvarpopop();
begin
 //dummy
end;

procedure subbeginop();
var
 po1: plocallocinfoty;
 po2: pnestedallocinfoty;
 i1,i2: int32;
 poend: pointer;
 trampop: popinfoty;
 idar: idarty;
 ids: idsarty;
 isfunction: boolean;
begin
 isfunction:= sf_function in pc^.par.subbegin.sub.flags;
 bcstream.releasetrampoline(trampop);
 if trampop <> nil then begin //todo: force tailcall
  with trampop^.par.subbegin do begin
   idar.count:= pc^.par.subbegin.sub.allocs.paramcount;
   trampolinealloc.paramcount:= idar.count;
   bcstream.beginsub([],trampolinealloc,1);
   bcstream.emitbitcast(bcstream.subval(0), //first param, class instance
                                 bcstream.ptypeval(pointertype)); //1ssa **i8
   bcstream.emitloadop(bcstream.relval(0));                     //1ssa *i8
                //class def
   bcstream.emitgetelementptr(bcstream.relval(0),               
                     bcstream.constval(trampoline.virtoffset));//2ssa *i8
               //virtual table item address
   bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(pointertype));
                                                                  //1ssa **i8
   bcstream.emitloadop(bcstream.relval(0));                        //1ssa *i8
               //sub address
   bcstream.emitbitcast(bcstream.relval(0),                     //1ssa
                         bcstream.ptypeval(trampoline.typeid));
   if isfunction then begin
    dec(idar.count);
   end;
   for i1:= 0 to idar.count-1 do begin
    ids[i1]:= bcstream.subval(i1);
   end;
   idar.ids:= @ids;
   bcstream.emitcallop(isfunction,bcstream.relval(0),idar);
   if isfunction then begin
    bcstream.emitretop(bcstream.relval(0));
   end
   else begin
    bcstream.emitretop();
   end;
   bcstream.endsub();
  end;
 end;
 with pc^.par.subbegin do begin
  bcstream.beginsub(sub.flags,sub.allocs,sub.blockcount);
  po1:= getsegmentpo(seg_localloc,sub.allocs.allocs);
  poend:= po1 + sub.allocs.alloccount;
  while po1 < poend do begin
   bcstream.emitalloca(bcstream.ptypeval(po1^.size));
   inc(po1);
  end;
  i2:= 0;
  if isfunction then begin
   i2:= 1; //skip result param
  end;
  for i1:= i2 to sub.allocs.paramcount-1 do begin
   bcstream.emitstoreop(bcstream.paramval(i1),bcstream.allocval(i1));
  end;
  if sub.allocs.nestedalloccount > 0 then begin
   bcstream.emitalloca(bcstream.ptypeval(sub.allocs.nestedallocstypeindex));
   if sf_hascallout in sub.flags then begin
    bcstream.emitgetelementptr(bcstream.subval(0),constlist.i8(0)); 
                                        //param parent nested var,source
    bcstream.emitgetelementptr(bcstream.ssaval(0),nullpointeroffset);
                                                  //nested var array,dest
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitstoreop(bcstream.relval(3),bcstream.relval(0));
   end;
   po2:= getsegmentpo(seg_localloc,sub.allocs.nestedallocs);
   poend:= po2+sub.allocs.nestedalloccount;
   i1:= 1;
   while po2 < poend do begin
    if po2^.address.nested then begin
     bcstream.emitgetelementptr(bcstream.subval(0),po2^.address.arrayoffset);
                              //pointer to parent nestedvars, 2 ssa
     bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
     bcstream.emitloadop(bcstream.relval(0));                       //source
    end
    else begin
     bcstream.emitbitcast(bcstream.allocval(po2^.address.origin),
                                    bcstream.typeval(das_pointer)); //source
    end;
    bcstream.emitgetelementptr(bcstream.ssaval(0),
                                 constlist.pointeroffset(i1)); //dest
                        //pointer to nestedallocs
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitstoreop(bcstream.relval(3),bcstream.relval(0));
    inc(po2);
    inc(i1);
   end;
   bcstream.emitbitcast(bcstream.allocval(sub.allocs.alloccount),
                                               bcstream.typeval(das_pointer));
                                 //pointer to nestedallocs
   bcstream.resetssa();
  end;
 end;
end;

procedure subendop();
begin
 with pc^.par.subend do begin
  bcstream.endsub();
 end;
end;

procedure externalsubop();
begin
 //dummy
end;

procedure returnop();
begin
 bcstream.emitretop();
 //dummy
// bcstream.emitretop();
// outass('ret void');
end;

procedure returnfuncop();
begin
 with pc^.par do begin
  bcstream.emitloadop(bcstream.allocval(0));
  bcstream.emitretop(bcstream.relval(0));
 end;
end;

procedure initclassop();
begin
 with pc^.par.initclass do begin
//  bcstream.emitpushconstsegad(classdef); //2ssa
  bcstream.emitgetelementptr(bcstream.globval(
               pint32(getsegmentpo(seg_classdef,classdef))^),
                                   bcstream.constval(constlist.i8(0))); //2ssa
  callcompilersub(cs_initclass,true,[bcstream.relval(0)]); //1ssa
 end;
end;

procedure destroyclassop();
begin
 with pc^.par do begin
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_free]),
                                                    [bcstream.ssaval(ssas1)]);
 end;
end;

procedure decloop32op();
begin
 notimplemented();
end;
procedure decloop64op();
begin
 notimplemented();
end;

procedure setlengthstr8op();
begin
 notimplemented();
end;

procedure setlengthdynarrayop();
begin
 notimplemented();
end;

procedure raiseop();
begin
 with pc^.par do begin
  callcompilersub(cs_raise,false,[bcstream.ssaval(ssas1)]);
 end;
end;

procedure pushcpucontextop();
begin
 with pc^.par do begin
  bcstream.landingpad:= opaddress.bbindex;
 end;
end;

procedure popcpucontextop();
begin
 with pc^.par do begin
  bcstream.landingpad:= opaddress.bbindex;
  bcstream.emitlandingpad(bcstream.typeval(typelist.landingpad),
                       bcstream.globval(compilersubids[cs_personality]));
 end;
end;

procedure finiexceptionop();
begin
// notimplemented();
end;

procedure continueexceptionop();
begin
// notimplemented();
end;

procedure getmemop();
begin
 with pc^.par do begin
  bcstream.emitcallop(true,bcstream.globval(internalfuncs[if_malloc]),
                                                    [bcstream.ssaval(ssas2)]);
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitstoreop(bcstream.relval(1),bcstream.relval(0));
 end;
end;

procedure getzeromemop();
begin
 with pc^.par do begin
  bcstream.emitcallop(true,bcstream.globval(internalfuncs[if_calloc]),
                           [bcstream.ssaval(ssas2),i32consts[1]]);
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitstoreop(bcstream.relval(1),bcstream.relval(0));
 end;
end;

procedure freememop();
begin
 with pc^.par do begin
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_free]),
                                                    [bcstream.ssaval(ssas1)]);
 end;
end;

procedure setmemop();
begin
 with pc^.par do begin
  bcstream.emitcallop(true,bcstream.globval(internalfuncs[if_memset]),
            [bcstream.ssaval(ssas1),bcstream.ssaval(ssas3),
                                                    bcstream.ssaval(ssas2)]);
 end;
end;

procedure lineinfoop();
begin
 with pc^.par.lineinfo do begin
  bcstream.debugloc:= loc;
 end;
end;

const
  nonessa = 0;
  nopssa = 1;
  labelssa = 0;
  ifssa = 0;
  whilessa = 0;
  untilssa = 0;
  decloop32ssa = 1;
  decloop64ssa = 1;

  beginparsessa = 0;
  mainssa = 0;//1;
  progendssa = 0;  
  endparsessa = 0;
  haltssa = 1;

  movesegreg0ssa = 1;
  moveframereg0ssa = 1;
  popreg0ssa = 1;
  increg0ssa = 1;

  gotossa = 0;
  cmpjmpneimm4ssa = 1;
  cmpjmpeqimm4ssa = 1;
  cmpjmploimm4ssa = 1;
  cmpjmpgtimm4ssa = 1;
  cmpjmploeqimm4ssa = 1;

  writelnssa = 1;
  writebooleanssa = 1;
  writeintegerssa = 1;
  writefloatssa = 1;
  writestring8ssa = 1;
  writepointerssa = 1;
  writeclassssa = 1;
  writeenumssa = 1;

  pushssa = 0; //dummy
  popssa = 0;  //dummy

  pushimm1ssa = 1;
  pushimm8ssa = 1;
  pushimm16ssa = 1;
  pushimm32ssa = 1;
  pushimm64ssa = 1;
  pushimmdatakindssa = 1;
  
  int32toflo64ssa = 1;
  potoint32ssa = 1;
  inttopossa =1;

  and1ssa = 1;
  and32ssa = 1;
  or1ssa = 1;
  or32ssa = 1;
  
  negcard32ssa = 1;
  negint32ssa = 1;
  negflo64ssa = 1;

  mulint32ssa = 1;
  mulflo64ssa = 1;
  addint32ssa = 1;
  subint32ssa = 1;
  addpoint32ssa = 2;
  subpossa = 3;
  addflo64ssa = 1;
  subflo64ssa = 1;

  addimmint32ssa = 1;
  mulimmint32ssa = 1;
  offsetpoimm32ssa = 2;

  incdecsegimmint32ssa = 2;
  incdecsegimmpo32ssa = 3;

  incdeclocimmint32ssa = 2;
  incdeclocimmpo32ssa = 3;

  incdecparimmint32ssa = 2;
  incdecparimmpo32ssa = 3;

  incdecparindiimmint32ssa = 3;
  incdecparindiimmpo32ssa = 4;

  incdecindiimmint32ssa = 3;
  incdecindiimmpo32ssa = 3;

  cmpeqpossa = 1;
  cmpeqboolssa = 1;
  cmpeqint32ssa = 1;
  cmpeqflo64ssa = 1;

  cmpnepossa = 1;
  cmpneboolssa = 1;
  cmpneint32ssa = 1;
  cmpneflo64ssa = 1;

  cmpgtpossa = 1;
  cmpgtboolssa = 1;
  cmpgtint32ssa = 1;
  cmpgtflo64ssa = 1;

  cmpltpossa = 1;
  cmpltboolssa = 1;
  cmpltint32ssa = 1;
  cmpltflo64ssa = 1;

  cmpgspossa = 1;
  cmpgsboolssa = 1;
  cmpgsint32ssa = 1;
  cmpgsflo64ssa = 1;

  cmplspossa = 1;
  cmplsboolssa = 1;
  cmplsint32ssa = 1;
  cmplsflo64ssa = 1;

  storesegnilssa = 0;
  storereg0nilssa = 1;
  storeframenilssa = 0;
  storestacknilssa = 1;
  storestackrefnilssa = 1;
  storesegnilarssa = 1;
  storeframenilarssa = 1;
  storereg0nilarssa = 1;
  storestacknilarssa = 1;
  storestackrefnilarssa = 1;

  finirefsizesegssa = 2;
  finirefsizeframessa = 1;
  finirefsizereg0ssa = 1;
  finirefsizestackssa = 1;
  finirefsizestackrefssa = 1;
  finirefsizeframearssa = 1;
  finirefsizesegarssa = 1;
  finirefsizereg0arssa = 1;
  finirefsizestackarssa = 1;
  finirefsizestackrefarssa = 1;

  increfsizesegssa = 1;
  increfsizeframessa = 1;
  increfsizereg0ssa = 1;
  increfsizestackssa = 1;
  increfsizestackrefssa = 1;
  increfsizeframearssa = 1;
  increfsizesegarssa = 1;
  increfsizereg0arssa = 1;
  increfsizestackarssa = 1;
  increfsizestackrefarssa = 1;

  decrefsizesegssa = 1;
  decrefsizeframessa = 1;
  decrefsizereg0ssa = 1;
  decrefsizestackssa = 1;
  decrefsizestackrefssa = 1;
  decrefsizeframearssa = 1;
  decrefsizesegarssa = 1;
  decrefsizereg0arssa = 1;
  decrefsizestackarssa = 1;
  decrefsizestackrefarssa = 1;

  popseg8ssa = 0;
  popseg16ssa = 0;
  popseg32ssa = 0;
  popseg64ssa = 0;
  popsegpossa = 0;
  popsegf16ssa = 0;
  popsegf32ssa = 0;
  popsegf64ssa = 0;
  popsegssa = 0;

  poploc8ssa = 0;
  poploc16ssa = 0;
  poploc32ssa = 0;
  poploc64ssa = 0;
  poplocpossa = 0;
  poplocf16ssa = 0;
  poplocf32ssa = 0;
  poplocf64ssa = 0;
  poplocssa = 0;

  poplocindi8ssa = 2;
  poplocindi16ssa = 2;
  poplocindi32ssa = 2;
  poplocindi64ssa = 2;
  poplocindipossa = 2;
  poplocindif16ssa = 2;
  poplocindif32ssa = 2;
  poplocindif64ssa = 2;
  poplocindissa = 2;

  poppar8ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar16ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar32ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar64ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparpossa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparf16ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparf32ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparf64ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};

  popparindi8ssa = 2;
  popparindi16ssa = 2;
  popparindi32ssa = 2;
  popparindi64ssa = 2;
  popparindipossa = 2;
  popparindif16ssa = 2;
  popparindif32ssa = 2;
  popparindif64ssa = 2;
  popparindissa = 2;

  pushnilssa = 1;
  pushsegaddressssa = 1;

  pushseg8ssa = 1;
  pushseg16ssa = 1;
  pushseg32ssa = 1;
  pushseg64ssa = 1;
  pushsegpossa = 1;
  pushsegf16ssa = 1;
  pushsegf32ssa = 1;
  pushsegf64ssa = 1;
  pushsegssa = 1;

  pushloc8ssa = 1;
  pushloc16ssa = 1;
  pushloc32ssa = 1;
  pushloc64ssa = 1;
  pushlocpossa = 1;
  pushlocf16ssa = 1;
  pushlocf32ssa = 1;
  pushlocf64ssa = 1;
  pushlocssa = 1;

  pushlocindi8ssa = 2;
  pushlocindi16ssa = 2;
  pushlocindi32ssa = 2;
  pushlocindi64ssa = 2;
  pushlocindipossa = 2;
  pushlocindif16ssa = 2;
  pushlocindif32ssa = 2;
  pushlocindif64ssa = 2;
  pushlocindissa = 2;

  pushpar8ssa = 1;
  pushpar16ssa = 1;
  pushpar32ssa = 1;
  pushpar64ssa = 1;
  pushparpossa = 1;
  pushparf16ssa = 1;
  pushparf32ssa = 1;
  pushparf64ssa = 1;
  pushparssa = 1;

  pushaddrssa = 1;
  pushlocaddrssa = 2;
//  pushlocaddrindissa = 3;
  pushsegaddrssa = 1;
//  pushsegaddrindissa = 3;
  pushstackaddrssa = 1;
//  pushstackaddrindissa = 1;
  
  pushduppossa = 1;

  indirect8ssa = 2;
  indirect16ssa = 2;
  indirect32ssa = 2;
  indirect64ssa = 2;
  indirectpossa = 2;
  indirectf16ssa = 2;
  indirectf32ssa = 2;
  indirectf64ssa = 2;
  indirectpooffsssa = 2;
  indirectoffspossa = 1;
  indirectssa = 1;

  popindirect8ssa = 1;
  popindirect16ssa = 1;
  popindirect32ssa = 1;
  popindirect64ssa = 1;
  popindirectpossa = 1;
  popindirectf16ssa = 1;
  popindirectf32ssa = 1;
  popindirectf64ssa = 1;
  popindirectssa = 1;

  callssa = 0;
  callfuncssa = 1;
  calloutssa = 0;
  callfuncoutssa = 1;
  callvirtssa = 7;
  callintfssa = 11;
  virttrampolinessa = 1;

  callindissa = 1;
  callfuncindissa = 2;

  locvarpushssa = 0; //dummy
  locvarpopssa = 0;  //dummy

  subbeginssa = 0; //1;
  subendssa = 0;
  externalsubssa = 0;
  returnssa = 0;
  returnfuncssa = 1;

  initclassssa = 3;
  destroyclassssa = 1;

  setlengthstr8ssa = 1;
  setlengthdynarrayssa = 1;

  raisessa = 0;
  pushcpucontextssa = 0;
  popcpucontextssa = 1;
  finiexceptionssa = 0;
  continueexceptionssa = 0;
  getmemssa = 2;
  getzeromemssa = 2;
  freememssa = 0;
  setmemssa = 1;
  
  lineinfossa = 0;

//ssa only
  nestedvarssa = 5;
  popnestedvarssa = 5;
//  popsegaggregatessa = 3;
  pushnestedvarssa = 5;
  aggregatessa = 3;
  allocssa = 1;
  nestedcalloutssa = 2;
  hascalloutssa = 1;

  pushsegaddrnilssa = 0;
  pushsegaddrglobvarssa = 1;
  pushsegaddrglobconstssa = 3;
  pushsegaddrclassdefssa = 3;
  
{$include optable.inc}

procedure run(const atarget: tllvmbcwriter);
var
 endpo: pointer;
 lab: shortstring;
begin
 bcstream:= atarget;
 pc:= getsegmentbase(seg_op);
 endpo:= pointer(pc)+getsegmentsize(seg_op);
 inc(pc,startupoffset);
 while pc < endpo do begin
 {
  if opf_label in pc^.op.flags then begin
   curoplabel(lab);
   outass('br label %'+lab);
   outass(lab+':');
  end;
  }
  optable[pc^.op.op]();
  inc(pc);
 end;
end;

function getoptable: poptablety;
begin
 result:= @optable;
end;

function getssatable: pssatablety;
begin
 result:= @ssatable;
end;

finalization
// freeandnil(assstream);
end.
