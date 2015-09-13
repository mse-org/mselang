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
unit handlerutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 globtypes,handlerglob,parserglob,opglob,elements,msestrings,msetypes;

type
 datasizetyxx = type integer;
 
 systypeinfoty = record
  name: string;
  data: typedataty;
 end;
 sysconstinfoty = record
  name: string;
  ctyp: systypety;
  cval: dataty;
 end;
  
 opsinfoty = record
  ops: array[stackdatakindty] of opcodety;
  opname: string;
 end;

var
 unitsele: elementoffsetty;
 sysdatatypes: array[systypety] of typeinfoty;

const
 basedatatypes: array[databitsizety] of systypety = (
 //das_none,das_1,   das_2_7,das_8,  das_9_15,das_16,  das_17_31,das_32,
  st_none,  st_bool1,st_none,st_int8,st_int16,st_int16,st_int32, st_int32,
//das_33_63,das_64,  das_pointer,das_f16,das_f32,das_f64,   das_sub,das_meta
  st_int64, st_int64,st_pointer, st_none,st_none,st_float64,st_none,st_none
 );

 stackdatakinds: array[datakindty] of stackdatakindty = (
   //dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
    sdk_none,sdk_pointer,sdk_bool1,sdk_card32, sdk_int32, sdk_flo64,sdk_none,
  //dk_address,dk_record,dk_string,dk_dynarray,dk_array,dk_class,dk_interface
    sdk_pointer,  sdk_none, sdk_none, sdk_none,   sdk_none,sdk_none,sdk_none,
  //dk_sub
    sdk_pointer,
  //dk_enum,dk_enumitem, dk_set
    sdk_none,   sdk_none, sdk_none);
                
 resultdatakinds: array[stackdatakindty] of datakindty =
          //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64
           (dk_none,dk_pointer,dk_boolean,dk_cardinal,dk_integer,dk_float);
 resultdatatypes: array[stackdatakindty] of systypety =
          //sdk_none,sdk_pointer,sdk_bool1,sdk_card32,sdk_int32,sdk_flo64
           (st_none,st_pointer,st_bool1,st_card32,st_int32,st_float64);

function getidents(const astackoffset: integer;
                     out idents: identvecty): boolean; overload;
function getidents(const astackoffset: integer): identvecty; overload;
 
function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty; const visibility: visikindsty;
                                    out ainfo: pointer): boolean;
function findkindelements(
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: visikindsty; out aelement: pelementinfoty;
           out firstnotfound: integer; out idents: identvecty;
            const rest: int32 = 0): boolean;
function findkindelements(
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: visikindsty; out aelement: pelementinfoty;
           const noerror: boolean = false): boolean;
function findkindelementsdata(
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: visikindsty; out ainfo: pointer;
              out firstnotfound: integer; out idents: identvecty;
              const rest: int32 = 0): boolean;
function findkindelementsdata(
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: visikindsty; out ainfo: pointer): boolean;

function findvar(const astackoffset: integer; 
        const visibility: visikindsty; out varinfo: vardestinfoty): boolean;
function addvar(const aname: identty; const avislevel: visikindsty;
          var chain: elementoffsetty; out aelementdata: pvardataty): boolean;

procedure updateop(const opsinfo: opsinfoty);
function convertconsts(): stackdatakindty;
function compaddress(const a,b: addressvaluety): integer;

function getvalue(const stackoffset: integer; const adatasize: databitsizety;
                               const retainconst: boolean = false): boolean;
function getaddress(const stackoffset: integer;
                                  const endaddress: boolean): boolean;
function getassignaddress(const stackoffset: integer;
                                  const endaddress: boolean): boolean;

procedure push(const avalue: boolean); overload;
procedure push(const avalue: integer); overload;
procedure push(const avalue: real); overload;
procedure push( const atype: typeinfoty; const avalue: addressvaluety;
                const offset: dataoffsty{; const indirect: boolean}); overload;
procedure push(const avalue: datakindty); overload;
//procedure pushconst(var avalue: contextdataty);
procedure pushdata(const address: addressvaluety;
                   const varele: elementoffsetty;
                   const offset: dataoffsty;
                   const opdatatype: typeallocinfoty);

procedure pushinsert(const stackoffset: integer; const before: boolean;
                  const avalue: datakindty); overload;
procedure pushinsert(const stackoffset: integer; const before: boolean;
            const atype: typeinfoty;
            const avalue: addressvaluety; const offset: dataoffsty{;
                                            const indirect: boolean}); overload;
            //class field address
function pushinsertvar(const stackoffset: int32; const before: boolean;
              const indirectlevel: int32; const atype: ptypedataty): integer;
procedure pushinsertsegaddresspo(const stackoffset: integer;
                            const before: boolean; const address: segaddressty);
procedure pushinsertdata(const stackoffset: integer; const before: boolean;
                  const address: addressvaluety;
                  const varele: elementoffsetty;
                  const offset: dataoffsty;
                  const opdatatype: typeallocinfoty);
procedure pushinsertaddress(const stackoffset: integer; const before: boolean);
procedure pushinsertconst(const stackoffset: integer; const before: boolean;
                                              const adatasize: databitsizety);
procedure offsetad(const stackoffset: integer; const aoffset: dataoffsty);

//procedure setcurrentloc(const indexoffset: integer);
procedure setcurrentlocbefore(const indexoffset: integer);
procedure setlocbefore(const destindexoffset,sourceindexoffset: integer);
//procedure setloc(const destindexoffset,sourceindexoffset: integer);

procedure getordrange(const typedata: ptypedataty; out range: ordrangety);
function getordcount(const typedata: ptypedataty): int64;
function getordconst(const avalue: dataty): int64;
function getdatabitsize(const avalue: int64): databitsizety;

function getcontextssa(const stackoffset: integer): int32;
procedure initfactcontext(const stackoffset: integer);
//procedure trackalloc(const asize: integer; var address: addressvaluety);
procedure trackalloc(const adatasize: databitsizety; const asize: integer; 
                                 var address: segaddressty);
//procedure trackalloc(const asize: integer; var address: addressvaluety);
//procedure allocsubvars(const asub: psubdataty; out allocs: suballocinfoty);
procedure tracklocalaccess(var aaddress: locaddressty; 
                                 const avarele: elementoffsetty;
                                 const aopdatatype: typeallocinfoty);
function trackaccess(const avar: pvardataty): addressvaluety;
function trackaccess(const asub: psubdataty): int32;

procedure resetssa();
function getssa(const aopcode: opcodety): integer;
function getssa(const aopcode: opcodety; const count: integer): integer;
function getopdatatype(const atypeinfo: typeinfoty): typeallocinfoty;
function getopdatatype(const atypedata: elementoffsetty;
                           const aindirectlevel: integer): typeallocinfoty;
function getopdatatype(const atypedata: ptypedataty;
                           const aindirectlevel: integer): typeallocinfoty;
function getopdatatype(const adest: vardestinfoty): typeallocinfoty;
function getbytesize(const aopdatatype: typeallocinfoty): integer;
function getbasetypedata(const abitsize: databitsizety): ptypedataty;
function getsystypeele(const atype: systypety): elementoffsetty;
procedure init();
procedure deinit();

{$ifdef mse_debugparser}
procedure outhandle(const text: string);
procedure outinfo(const text: string; const indent: boolean = true);
procedure dumpelements();
{$endif}

implementation
uses
 errorhandler,typinfo,opcode,stackops,parser,sysutils,mseformatstr,
 syssubhandler,managedtypes,grammar,segmentutils,valuehandler,unithandler,
 identutils,llvmbitcodes,llvmlists;
   
const
 mindouble = -1.7e308;
 maxdouble = 1.7e308; //todo: use exact values
 
  //will be replaced by systypes.mla
 systypeinfos: array[systypety] of systypeinfoty = (
   (name: 'none'; data: (h: (ancestor: 0; kind: dk_none;
       base: 0; rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 0; bytesize: 0; datasize: das_none);
       dummy1: 0)),
   (name: 'pointer'; data: (h: (ancestor: 0; kind: dk_pointer;
       base: 0;  rtti: 0; flags: []; indirectlevel: 1;
       bitsize: pointerbitsize; bytesize: pointersize; datasize: das_pointer);
       dummy1: 0)),
   (name: 'bool1'; data: (h: (ancestor: 0; kind: dk_boolean;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 1; bytesize: 1; datasize: das_1);
       dummy1: 0)),
   (name: 'int8'; data: (h: (ancestor: 0; kind: dk_integer;
       base: 0;  rtti: 0; flags: [];indirectlevel: 0;
       bitsize: 8; bytesize: 1; datasize: das_8);
       infoint8:(min: int8($80); max: $7f))),
   (name: 'int16'; data: (h: (ancestor: 0; kind: dk_integer;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 16; bytesize: 2; datasize: das_16);
       infoint16:(min: int16($8000); max: $7fff))),
   (name: 'int32'; data: (h: (ancestor: 0; kind: dk_integer;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 32; bytesize: 4; datasize: das_32);
      infoint32:(min: int32($80000000); max: $7fffffff))),
   (name: 'int64'; data: (h: (ancestor: 0; kind: dk_integer;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 64; bytesize: 8; datasize: das_64);
       infoint64:(min: int64($8000000000000000); max: $7fffffffffffffff))),
   (name: 'card8'; data: (h: (ancestor: 0; kind: dk_cardinal;
       base: 0;  rtti: 0; flags: [];indirectlevel: 0;
       bitsize: 8; bytesize: 1; datasize: das_8);
       infocard8:(min: int8($00); max: $ff))),
   (name: 'card16'; data: (h: (ancestor: 0; kind: dk_cardinal;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 16; bytesize: 2; datasize: das_16);
       infocard16:(min: int16($0000); max: $ffff))),
   (name: 'card32'; data: (h: (ancestor: 0; kind: dk_cardinal;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 32; bytesize: 4; datasize: das_32);
      infocard32:(min: int32($00000000); max: $ffffffff))),
   (name: 'card64'; data: (h: (ancestor: 0; kind: dk_cardinal;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 64; bytesize: 8; datasize: das_64);
       infocard64:(min: $0000000000000000; max: card64($ffffffffffffffff)))),
   (name: 'flo64'; data: (h: (ancestor: 0; kind: dk_float;
       base: 0;  rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 64; bytesize: 8; datasize: das_64);
       infofloat64:(min: mindouble; max: maxdouble))),
   (name: 'string8'; data: (h: (ancestor: 0; kind: dk_string8;
       base: 0;  rtti: 0; flags: [tf_hasmanaged,tf_managed]; indirectlevel: 0;
       bitsize: pointerbitsize; bytesize: pointersize; datasize: das_pointer);
       manageproc: @managestring8; itemsize: 1;
                 dummy2: 0))
  );
 sysconstinfos: array[0..2] of sysconstinfoty = (
   (name: 'false'; ctyp: st_bool1; cval:(kind: dk_boolean; vboolean: false)),
   (name: 'true'; ctyp: st_bool1; cval:(kind: dk_boolean; vboolean: true)),
   (name: 'nil'; ctyp: st_pointer; cval:(kind: dk_pointer; 
             vaddress: (flags: [af_nil]; indirectlevel: 0; poaddress: 0)))
  );
    
{ 
procedure error(const error: comperrorty;
                   const pos: pchar=nil);
begin
 outcommand([],'*ERROR* '+errormessages[error]);
end;
}
function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty;
              const visibility: visikindsty; out ainfo: pointer): boolean;
var
 po1: pelementinfoty;
 ele1: elementoffsetty;
begin
 result:= false;
 if aident.kind = ck_ident then begin
  if ele.findcurrent(aident.ident.ident,akinds,visibility,ele1) then begin
   po1:= ele.eleinfoabs(ele1);
   ainfo:= @po1^.data;
   result:= true;
  end;
 end;
end;

function findkindelementdata(
              const astackoffset: integer;
              const akinds: elementkindsty;
              const visibility: visikindsty; out ainfo: pointer): boolean;
begin
 with info do begin
  result:= findkindelementdata(contextstack[s.stackindex+astackoffset].d,
                                                      akinds,visibility,ainfo);
 end;
end;

function getidents(const astackoffset: integer;
                     out idents: identvecty): boolean;
var
 po1: pcontextitemty;
 int1: integer;
 identcount: integer;
begin
 with info do begin
  po1:= @contextstack[s.stackindex+astackoffset];
  identcount:= -1;
  for int1:= 0 to high(idents.d) do begin
   idents.d[int1]:= po1^.d.ident.ident;
   if not (idf_continued in po1^.d.ident.flags) then begin
    identcount:= int1;
    break;
   end;
   inc(po1);
  end;
  idents.high:= identcount;
  inc(identcount);
  result:= true;
  if identcount = 0 then begin
   result:= false;
  end;
  if identcount > high(idents.d) then begin
   errormessage(err_toomanyidentifierlevels,[],astackoffset+identcount);
  end;
 end;
end;

function getidents(const astackoffset: integer): identvecty;
begin
 getidents(astackoffset,result); 
end;

function findkindelements(const astackoffset: integer;
            const akinds: elementkindsty; 
            const visibility: visikindsty;
            out aelement: pelementinfoty;
            out firstnotfound: integer; out idents: identvecty;
            const rest: int32 = 0): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents(astackoffset,idents) then begin
  idents.high:= idents.high - rest;
  if idents.high < 0 then begin
   idents.high:= -1;
   exit;
  end;
  with info do begin
   if ele.findparentscope(idents.d[0],akinds,visibility,eleres) then begin
    result:= true;
    firstnotfound:= 0;
   end
   else begin
    result:= ele.findupward(idents,akinds,visibility,eleres,firstnotfound);
    if not result then begin //todo: use cache
     ele2:= ele.elementparent;
     for int1:= 0 to high(info.s.unitinfo^.implementationuses) do begin
      ele.elementparent:=
        info.s.unitinfo^.implementationuses[int1]^.interfaceelement;
      result:= ele.findupward(idents,akinds,visibility,eleres,firstnotfound);
      if result then begin
       break;
      end;
     end;
     if not result then begin
      for int1:= 0 to high(info.s.unitinfo^.interfaceuses) do begin
       ele.elementparent:=
         info.s.unitinfo^.interfaceuses[int1]^.interfaceelement;
       result:= ele.findupward(idents,akinds,visibility,eleres,firstnotfound);
       if result then begin
        break;
       end;
      end;
     end;
     ele.elementparent:= ele2;
    end;
   end;
  end;
 end;
 if result then begin
  aelement:= ele.eleinfoabs(eleres);
 end;
end;

function findkindelements(const astackoffset: integer;
           const akinds: elementkindsty; 
           const visibility: visikindsty;
           out aelement: pelementinfoty;
           const noerror: boolean = false): boolean;
var
 idents: identvecty;
 firstnotfound: integer;
begin
 result:= findkindelements(astackoffset,akinds,visibility,
                              aelement,firstnotfound,idents) and 
                              (firstnotfound > idents.high);
 if not result and not noerror then begin
  identerror(astackoffset+firstnotfound,err_identifiernotfound);
 end;
end;

(*
function findkindelements(const astackoffset: integer;
           const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
 idents: identvecty;
 lastident: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents(astackoffset,idents) then begin
  with info do begin
   result:= ele.findupward(idents,[],visibility,eleres,lastident); //exact
   if not result then begin //todo: use cache
    ele2:= ele.elementparent;
    for int1:= 0 to high(info.unitinfo^.implementationuses) do begin
     ele.elementparent:=
       info.unitinfo^.implementationuses[int1]^.interfaceelement;
     result:= ele.findupward(idents,[],visibility,eleres,lastident); //exact
     if result then begin
      break;
     end;
    end;
    if not result then begin
     for int1:= 0 to high(info.unitinfo^.interfaceuses) do begin
      ele.elementparent:=
        info.unitinfo^.interfaceuses[int1]^.interfaceelement;
      result:= ele.findupward(idents,[],visibility,eleres,lastident); //exact
      if result then begin
       break;
      end;
     end;
    end;
    ele.elementparent:= ele2;
   end;
  end;
 end;
 if result then begin
  aelement:= ele.eleinfoabs(eleres);
  result:= (akinds = []) or (aelement^.header.kind in akinds);
 end;
end;
*)

function findkindelementsdata(
             const astackoffset: integer;
             const akinds: elementkindsty; const visibility: visikindsty; 
             out ainfo: pointer; out firstnotfound: integer;
             out idents: identvecty;
             const rest: int32 = 0): boolean;
begin
 result:= findkindelements(astackoffset,akinds,visibility,ainfo,
                                firstnotfound,idents,rest);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

function findkindelementsdata(
             const astackoffset: integer;
             const akinds: elementkindsty; const visibility: visikindsty; 
             out ainfo: pointer): boolean;
begin
 result:= findkindelements(astackoffset,akinds,visibility,ainfo);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

function findvar(const astackoffset: integer; 
                   const visibility: visikindsty;
                           out varinfo: vardestinfoty): boolean;
var
 idents,types: identvecty;	
 po1: pvardataty;
 po2: ptypedataty;
 po3: pfielddataty;
 ele1,ele2: elementoffsetty;
 int1: integer;
begin
 result:= false;
 if getidents(astackoffset,idents) then begin
  result:= ele.findupward(idents,[ek_var],visibility,ele1,int1);
  if result then begin
   po1:= ele.eledataabs(ele1);
   varinfo.address:= po1^.address;
   ele2:= po1^.vf.typ;
   if int1 < idents.high then begin
    for int1:= int1+1 to idents.high do begin //fields
     result:= ele.findchild(ele2,idents.d[int1],[ek_field],visibility,ele2);
     if not result then begin
      identerror(astackoffset+int1,err_identifiernotfound);
      exit;
     end;
     po3:= ele.eledataabs(ele2);
     varinfo.address.poaddress:= varinfo.address.poaddress + po3^.offset;
    end;
    varinfo.typ:= ele.eledataabs(po3^.vf.typ);
   end
   else begin
    po2:= ele.eledataabs(ele2);
    varinfo.typ:= po2;
   end;
  end
  else begin
   identerror(astackoffset,err_identifiernotfound);
  end;
 end;
end;                           

function addvar(const aname: identty; const avislevel: visikindsty;
          var chain: elementoffsetty; out aelementdata: pvardataty): boolean;
var
 po1: pelementinfoty;
begin
 result:= false;
 po1:= ele.addelement(aname,ek_var,avislevel);
 if po1 <> nil then begin
  aelementdata:= @po1^.data;
  aelementdata^.vf.next:= chain;
  aelementdata^.vf.flags:= [];
  chain:= ele.eleinforel(po1);
  result:= true;
 end;
end;

(*
procedure parsererror(const info: pparseinfoty; const text: string);
begin
 with info^ do begin
  contextstack[s.stackindex].d.kind:= ck_error;
  writeln(' ***ERROR*** '+text);
 end; 
end;

procedure identnotfounderror(const info: contextitemty; const text: string);
begin
 writeln(' ***ERROR*** ident '+lstringtostring(info.start.po,info.d.ident.len)+
                   ' not found. '+text);
end;

procedure wrongidentkinderror(const info: contextitemty; 
       wantedtype: elementkindty; const text: string);
begin
 writeln(' ***ERROR*** wrong ident kind '+
               lstringtostring(info.start.po,info.d.ident.len)+
                   ', expected '+
         getenumname(typeinfo(elementkindty),ord(wantedtype))+'. '+text);
end;
*)
(*
procedure outcommand(const items: array of integer;
                     const text: string);
var
 int1: integer;
begin
 with info do begin
  for int1:= 0 to high(items) do begin
   with contextstack[s.stacktop+items[int1]].d do begin
    command.write([getenumname(typeinfo(kind),ord(kind)),': ']);
    case kind of
     ck_const: begin
      with constval do begin
       case kind of
        dk_boolean: begin
         command.write(vboolean);
        end;
        dk_integer: begin
         command.write(vinteger);
        end;
        dk_float: begin
         command.write(vfloat);
        end;
       end;
      end;
     end;
    end;
    command.write(',');
   end;
  end;
  command.writeln([' ',text]);
 end;
end;
*)
function pushinsertvar(const stackoffset: int32; const before: boolean;
              const indirectlevel: int32; const atype: ptypedataty): integer;
begin
 with insertitem(oc_push,stackoffset,before)^ do begin
  if indirectlevel > 0 then begin
   result:= pointersize;
  end
  else begin
   result:= atype^.h.bytesize; //todo: alignment
  end;
  setimmsize(result,par);
 end;
end;

procedure pushinsertsegaddresspo(const stackoffset: integer;
                             const before: boolean;
                             const address: segaddressty);
begin
 if address.segment = seg_nil then begin
  insertitem(oc_pushnil,stackoffset,before);
 end
 else begin
  with insertitem(oc_pushsegaddr,stackoffset,before,
                                 pushsegaddrssaar[address.segment])^ do begin
   par.memop.segdataaddress.a:= address;
   par.memop.segdataaddress.offset:= 0;
   par.memop.t:= bitoptypes[das_pointer];
//   par.memop.segdataaddress.datasize:= 0; //todo!
  end;
 end;
end;

procedure pushinsertaddress(const stackoffset: integer; const before: boolean);
var
 int1: integer;
 po1: psubdataty;
begin
 with info,contextstack[s.stackindex+stackoffset].d.dat do begin
  if af_segment in ref.c.address.flags then begin
   with insertitem(oc_pushsegaddr,stackoffset,before,
                 pushsegaddrssaar[ref.c.address.segaddress.segment])^ do begin
    par.memop.segdataaddress.a:= ref.c.address.segaddress; //todo:typelistindex
    par.memop.segdataaddress.offset:= ref.offset;
    par.memop.t:= getopdatatype(datatyp);
    if tf_subad in datatyp.flags then begin
     po1:= ele.eledataabs(ref.c.address.segaddress.element);
     if co_llvm in compileoptions then begin
      par.memop.segdataaddress.a.address:= po1^.globid;
     end
     else begin
      if po1^.address = 0 then begin
       linkmark(po1^.adlinks,getsegaddress(seg_op,
                                         @par.memop.segdataaddress.a.address));
      end
      else begin
       par.memop.segdataaddress.a.address:= po1^.address;
      end;
     end;
    end;
   end;
  end
  else begin
   with insertitem(oc_pushlocaddr,stackoffset,before)^ do begin
    par.memop.locdataaddress.a:= ref.c.address.locaddress;
    par.memop.locdataaddress.a.framelevel:= info.sublevel-
                          ref.c.address.locaddress.framelevel-1;
    par.memop.locdataaddress.offset:= ref.offset;
    par.memop.t:= getopdatatype(datatyp);
   end;
  end;
 end;
 initfactcontext(stackoffset);
end;

function getopdatatype(const atypedata: ptypedataty;
                           const aindirectlevel: integer): typeallocinfoty;
begin
 if aindirectlevel > 0 then begin
  result:= bitoptypes[das_pointer];
 end
 else begin
  if (atypedata^.h.datasize = das_none) and 
                             (co_llvm in info.compileoptions) then begin
   result.listindex:= info.s.unitinfo^.llvmlists.typelist.
                                    addbytevalue(atypedata^.h.bytesize);
  end
  else begin
   result.listindex:= ord(atypedata^.h.datasize);
  end;
  result.kind:= atypedata^.h.datasize;
  if result.kind in byteopdatakinds then begin
   result.size:= atypedata^.h.bytesize;
  end
  else begin
   result.size:= atypedata^.h.bitsize;
  end;
  result.flags:= [];
 end;
end;

function getopdatatype(const atypedata: elementoffsetty;
                           const aindirectlevel: integer): typeallocinfoty;
begin
 if aindirectlevel > 0 then begin
  result:= bitoptypes[das_pointer];
 end
 else begin
  result:= getopdatatype(ele.eledataabs(atypedata),aindirectlevel);
 end;
end;

function getopdatatype(const atypeinfo: typeinfoty): typeallocinfoty;
begin
 result:= getopdatatype(atypeinfo.typedata,atypeinfo.indirectlevel);
end;

function getopdatatype(const adest: vardestinfoty): typeallocinfoty;
var
 i1: int32;
begin
 i1:= adest.address.indirectlevel;
 if af_paramindirect in adest.address.flags then begin
  dec(i1);
 end;
 result:= getopdatatype(adest.typ,i1);
 result.flags:= adest.address.flags;
{
 if af_aggregate in adest.address.flags then begin
  result:= getopdatatype(adest.typ,adest.address.indirectlevel);
 end
 else begin
  result.listindex:= -1; //none
 end;
}
end;

function getbytesize(const aopdatatype: typeallocinfoty): integer;
begin
 if aopdatatype.kind = das_none then begin
  result:= aopdatatype.size;
 end
 else begin
  result:= bytesizes[aopdatatype.kind];
 end;
end;

function getbasetypedata(const abitsize: databitsizety): ptypedataty;
var
 typ1: systypety;
begin
 typ1:= basedatatypes[abitsize];
{$ifdef mse_checkinternalerror}
 if typ1 = st_none then begin
  internalerror(ie_handler,'20150319A');
 end;
{$endif}
 result:= ele.eledataabs(sysdatatypes[typ1].typedata);
end;

function getsystypeele(const atype: systypety): elementoffsetty;
begin
 result:= sysdatatypes[atype].typedata;
end;

procedure pushinsertconst(const stackoffset: integer; const before: boolean;
                                               const adatasize: databitsizety);
var
 po1: pcontextitemty;
 isimm: boolean;
 segad1: segaddressty;
 si1: databitsizety;
begin
 with info do begin
  po1:= @contextstack[s.stackindex+stackoffset];
  isimm:= true;
  case po1^.d.dat.constval.kind of
   dk_boolean: begin
    si1:= das_1;
    with insertitem(oc_pushimm1,stackoffset,before)^ do begin
     setimmboolean(po1^.d.dat.constval.vboolean,par);
    end;
   end;
   dk_integer,dk_cardinal,dk_enum: begin //todo: datasize warning
    if adatasize = das_none then begin //todo das_1..das_16
     si1:= das_32;
     if po1^.d.dat.constval.kind = dk_cardinal then begin
      if po1^.d.dat.constval.vcardinal > $ffffffff then begin
       si1:= das_64;
      end;
     end
     else begin
      if (po1^.d.dat.constval.vinteger > $7ffffff) or 
               (po1^.d.dat.constval.vinteger < -$80000000) then begin
       si1:= das_64;
      end;
     end;
    end
    else begin
     si1:= adatasize;
    end;
    case si1 of
     das_1: begin
      with insertitem(oc_pushimm1,stackoffset,before)^ do begin
       setimmint1(po1^.d.dat.constval.vinteger,par);
      end;
     end;
     das_8: begin
      with insertitem(oc_pushimm8,stackoffset,before)^ do begin
       setimmint8(po1^.d.dat.constval.vinteger,par);
      end;
     end;
     das_16: begin
      with insertitem(oc_pushimm16,stackoffset,before)^ do begin
       setimmint16(po1^.d.dat.constval.vinteger,par);
      end;
     end;
     das_32: begin
      with insertitem(oc_pushimm32,stackoffset,before)^ do begin
       setimmint32(po1^.d.dat.constval.vinteger,par);
      end;
     end;
     das_64: begin
      with insertitem(oc_pushimm64,stackoffset,before)^ do begin
       setimmint64(po1^.d.dat.constval.vinteger,par);
      end;
     end;
     else begin
      internalerror1(ie_handler,'20150501A');
     end;
    end;
   end;
   dk_float: begin
    si1:= das_f64;
    with insertitem(oc_pushimm64,stackoffset,before)^ do begin
     setimmfloat64(po1^.d.dat.constval.vfloat,par);
    end;
   end;
   dk_string8: begin
    si1:= das_pointer;
    isimm:= false;
    segad1:= stringconst(po1^.d.dat.constval.vstring);
    if segad1.segment = seg_nil then begin
     insertitem(oc_pushnil,stackoffset,before);
    end
    else begin
     with insertitem(oc_pushsegaddr,stackoffset,before,
                               pushsegaddrssaar[segad1.segment])^ do begin
      par.memop.segdataaddress.a:= segad1;
      par.memop.segdataaddress.offset:= 0;
      par.memop.t:= bitoptypes[das_pointer];
     end;
    end;
   end;
   dk_pointer: begin
    si1:= das_pointer;
    with po1^.d.dat.constval do begin
     if af_nil in vaddress.flags then begin
      insertitem(oc_pushnil,stackoffset,before);
     end
     else begin
      if af_segment in vaddress.flags then begin
       with insertitem(oc_pushsegaddr,stackoffset,before,
                  pushsegaddrssaar[vaddress.segaddress.segment])^ do begin
        par.memop.segdataaddress.a:= vaddress.segaddress;//todo:typelistindex
        par.memop.segdataaddress.offset:= 0;
        par.memop.t:= bitoptypes[das_pointer];
       end;
      end
      else begin
       with insertitem(oc_pushlocaddr{ess},stackoffset,before)^ do begin
        par.memop.locdataaddress.a:= vaddress.locaddress;
        par.memop.locdataaddress.offset:= 0;
        par.memop.t:= bitoptypes[das_pointer];
       end;
      end;
     end;
    end;
   end;
  {$ifdef mse_checkinternalerror}                             
   else begin
    internalerror(ie_handler,'20131121A');
   end;
  {$endif}
  end;
 {
  if isimm then begin
   par.ssad:= ssaindex;
  end;
 }
  initfactcontext(stackoffset);
  with po1^.d.dat.fact.opdatatype do begin
   kind:= si1;
   size:= bitsizes[si1];
  end;
//  po1^.d.dat.fact.opdatatype:= opdatatype[si1]; //todo: odk_float
 end;
end;

procedure offsetad(const stackoffset: integer; const aoffset: dataoffsty);
var
 ssabefore: int32;
begin
 if aoffset <> 0 then begin
  with info do begin
   ssabefore:= contextstack[s.stackindex+stackoffset].d.dat.fact.ssaindex;
   with insertitem(oc_offsetpoimm32,stackoffset,false)^ do begin
    setimmint32(aoffset,par);
    par.ssas1:= ssabefore;
   end;
  end;
 end;
end;

function addpushimm(const aop: opcodety): popinfoty; 
                                 {$ifndef mse_debugparser} inline; {$endif}
begin
 result:= additem(aop);
// result^.par.ssad:= info.ssaindex;
end;

procedure push(const avalue: boolean);
begin
 with addpushimm(oc_pushimm8)^ do begin
  setimmboolean(avalue,par);
 end;
end;

procedure push(const avalue: integer);
begin
 with addpushimm(oc_pushimm32)^ do begin
  setimmint32(avalue,par);
 end;
end;

procedure push(const avalue: real);
begin
 with addpushimm(oc_pushimm64)^ do begin
  setimmfloat64(avalue,par);
 end;
end;

procedure pushins(const ains: boolean; const stackoffset: integer;
          const before: boolean; const atype: typeinfoty;
          const avalue: addressvaluety; const offset: dataoffsty{;
                                           const indirect: boolean});
                 //push address on stack
//todo: optimize

 function getop(const aop: opcodety; const ssaextension: int32 = 0): popinfoty;
 begin
  if ains then begin
   result:= insertitem(aop,stackoffset,before,ssaextension);
  end
  else begin
   result:= additem(aop,ssaextension);
  end;
 end;

var
 po1: popinfoty;
  
begin
 if af_nil in avalue.flags then begin
  with getop(oc_pushaddr)^ do begin
   setimmpointer(0,par);
  end;
 end
 else begin
  if af_segment in avalue.flags then begin
   po1:= getop(oc_pushsegaddr,
                 pushsegaddrssaar[avalue.segaddress.segment]);
   with po1^ do begin
    par.memop.segdataaddress.a:= avalue.segaddress;
    par.memop.segdataaddress.offset:= offset;
    par.memop.t:= getopdatatype(atype);
   end;
  end
  else begin
   po1:= getop(oc_pushlocaddr);
   with po1^ do begin
    par.memop.locdataaddress.a:= avalue.locaddress;
    par.memop.locdataaddress.a.framelevel:= 
                               info.sublevel-avalue.locaddress.framelevel-1;
    par.memop.locdataaddress.offset:= offset;
    par.memop.t:= getopdatatype(atype);
   end;
  end;
 end;
end;

procedure push(const atype: typeinfoty; const avalue: addressvaluety;
            const offset: dataoffsty{;
            const indirect: boolean}); overload;
begin
 pushins(false,0,false,atype,avalue,offset{,indirect});
end;

procedure pushinsert(const stackoffset: integer; const before: boolean;
            const atype: typeinfoty;
            const avalue: addressvaluety; const offset: dataoffsty{;
            const indirect: boolean}); overload;
begin
 pushins(true,stackoffset,before,atype,avalue,offset{,indirect});
end;

procedure push(const avalue: datakindty); overload;
      //no alignsize
begin
 with addpushimm(oc_pushimmdatakind)^ do begin
  setimmdatakind(avalue,par);
 end;
end;

function insertpushimm(const aop: opcodety; const stackoffset: integer;
                       const before: boolean): popinfoty; 
                                 {$ifndef mse_debugparser} inline; {$endif}
begin
 result:= insertitem(aop,stackoffset,before);
// result^.par.ssad:= info.ssaindex;
end;

procedure pushinsert(const stackoffset: integer; const before: boolean;
                                    const avalue: datakindty); overload;
      //no alignsize
begin
 with insertpushimm(oc_pushimmdatakind,stackoffset,before)^ do begin
  setimmdatakind(avalue,par);
 end;
end;
(*
procedure pushconst(var avalue: contextdataty);
//todo: optimize
begin
 with avalue do begin
  case dat.constval.kind of
   dk_boolean: begin
    push(dat.constval.vboolean);
   end;
   dk_integer: begin
    push(dat.constval.vinteger);
   end;
   dk_float: begin
    push(dat.constval.vfloat);
   end;
   dk_address,dk_pointer: begin
    push(dat.constval.vaddress,0,false);
   end;
   else begin
   {$ifdef mse_checkinternalerror}   
    internalerror(ie_handler,'2014118A');
   {$endif}
   end;
  end;
  kind:= ck_ref;
  dat.fact.ssaindex:= info.s.ssa.index;
  dat.indirection:= 0;
  with dat.fact.opdatatype do begin
   kind:= dat.constval.kind;
   size:= bitsizes[kind];
  end;
 end;
end;
*)
procedure int32toflo64({; const index: integer});
begin
 additem(oc_int32toflo64);
end;
{
procedure setcurrentloc(const indexoffset: integer);
begin 
 with info do begin
  getoppo(
   contextstack[s.stackindex+indexoffset].opmark.address)^.par.opaddress:=
                                                                     opcount-1;
 end; 
end;
}
procedure setcurrentlocbefore(const indexoffset: integer);
begin 
 with info do begin
  with getoppo(contextstack[s.stackindex+indexoffset].
                                             opmark.address-1)^ do begin
   par.opaddress.opaddress:= opcount-1;
//   par.opaddress.bbindex:= info.s.ssa.blockindex;
  end;
//  addlabel();
 end;
end;

procedure setlocbefore(const destindexoffset,sourceindexoffset: integer);
var
 dest: integer;
begin
 with info do begin
  dest:= contextstack[s.stackindex+sourceindexoffset].opmark.address;
  getoppo(contextstack[s.stackindex+destindexoffset].opmark.address-1)^.
                                            par.opaddress.opaddress:= dest-1;
 end; 
end;
{
procedure setloc(const destindexoffset,sourceindexoffset: integer);
var
 dest: integer;
begin
 with info do begin
  dest:= contextstack[s.stackindex+sourceindexoffset].opmark.address;
  getoppo(
    contextstack[s.stackindex+destindexoffset].opmark.address)^.par.opaddress:=
                                                                        dest-1;
  include(getoppo(dest)^.op.flags,opf_label);
 end; 
end;
}
function compaddress(const a,b: addressvaluety): integer;
        //todo: handle runtime address calculation
begin
 result:= maxint;
 if a.flags * addresscompflags = b.flags * addresscompflags then begin
  if af_nil in a.flags then begin
   result:= 0;
  end
  else begin
   result:= a.poaddress - b.poaddress;
  end;
 end;
end;

function convertconsts(): stackdatakindty;
                //convert s.stacktop, s.stacktop-2
begin
 with info,contextstack[s.stacktop-2] do begin
  result:= stackdatakinds[d.dat.constval.kind];  
  if contextstack[s.stacktop].d.dat.constval.kind <> 
                                              d.dat.constval.kind then begin
   case contextstack[s.stacktop].d.dat.constval.kind of
    dk_float: begin
     result:= sdk_flo64;
     with d,dat.constval do begin
      case kind of
       dk_float: begin
        vfloat:= vfloat + contextstack[s.stacktop].d.dat.constval.vfloat;
       end;
       dk_integer: begin
        vfloat:= vinteger + contextstack[s.stacktop].d.dat.constval.vfloat;
        kind:= dk_float;
        dat.datatyp:= contextstack[s.stacktop].d.dat.datatyp;
       end;
       else begin
        result:= sdk_none;
       end;
      end;
     end;
    end;
    dk_integer: begin
     with d,dat.constval do begin
      case kind of
       dk_integer: begin
        vinteger:= vinteger + contextstack[s.stacktop].d.dat.constval.vinteger;
       end;
       dk_float: begin
        result:= sdk_flo64;
        vfloat:= vfloat + contextstack[s.stacktop].d.dat.constval.vfloat;
        kind:= dk_float;
        dat.datatyp:= contextstack[s.stacktop].d.dat.datatyp;
       end;
       else begin
        result:= sdk_none;
       end;
      end;
     end;
    end;
    else begin
     result:= sdk_none;
    end;
   end;
  end;
  if result = sdk_none then begin
   incompatibletypeserror(contextstack[s.stacktop-2].d,
                                           contextstack[s.stacktop].d);
  end;
 end;
end;

procedure tracklocalaccess(var aaddress: locaddressty; 
                                 const avarele: elementoffsetty;
                                 const aopdatatype: typeallocinfoty);

var
 int1: integer;
 parentbefore,ele1: elementoffsetty;
 po1: pnestedvardataty;
 first: boolean;
 bo1: boolean;
 addressbefore: dataoffsty;
begin
 if co_llvm in info.compileoptions then begin
  int1:= info.sublevel-aaddress.framelevel;
  if int1 > 0 then begin   //var in outer sub
   addressbefore:= aaddress.address;
   parentbefore:= ele.elementparent;
   first:= true;
   for int1:= int1-1 downto 0 do begin
    with psubdataty(ele.parentdata())^ do begin //current sub
     include(flags,sf_hasnestedaccess);
    end;
    ele.decelementparent();
   {$ifdef mse_checkinternalerror}
    if ele.parentelement()^.header.kind <> ek_sub then begin
     internalerror(ie_elements,'20140811A');
    end;
   {$endif}
    with psubdataty(ele.parentdata())^ do begin //parent sub
     bo1:= ele.adduniquechilddata(nestedvarele,[avarele],ek_nestedvar,
                                                       allvisi,po1);
     if bo1 then begin
      include(flags,sf_hasnestedref);
      po1^.next:= nestedvarchain;
      po1^.address.datatype:= aopdatatype;
      po1^.address.arrayoffset:= info.s.unitinfo^.llvmlists.constlist.
                              addi32((nestedvarcount{-1})*pointersize).listid;
      po1^.address.origin:= addressbefore;
      po1^.address.nested:= true;
      if int1 = 0 then begin //last
       po1^.address.nested:= false;
      end;
      nestedvarchain:= ele.eledatarel(po1);
      inc(nestedvarcount);
     end;
     if first then begin
      aaddress.address:= po1^.address.arrayoffset; //nested var offset
      first:= false;
     end;
     {
     if int1 = 0 then begin //last
      po1^.address.address:= addressbefore; //restore
      po1^.address.nested:= false;
     end;
     }
    end;
    if not bo1 then begin //already tracked
     break;
    end;
   end;
   ele.elementparent:= parentbefore; //restore
  end;
 end;
end;

function llvmlink(const adata: pointer; out destunitid: identty;
                                              out globid: int32): boolean;
                                              // -1 -> new
var
 po1: pelementinfoty;
 po2: plinkdataty;
begin
 with info do begin
  result:= modularllvm;
  if result then begin
   po1:= datatoele(adata);
   destunitid:= po1^.header.defunit^.key;
   result:= destunitid <> s.unitinfo^.key;
   if result then begin
    po2:= info.s.unitinfo^.llvmlists.globlist.linklist.find(
                                              ele.eledatarel(adata));
    if po2 <> nil then begin
     globid:= po2^.globid;
    end
    else begin
     globid:= -1; //new
    end;
   end;
  end;
 end;
end;

function trackaccess(const avar: pvardataty): addressvaluety;
var
 unitid: identty;
 globid: int32;
begin
 result:= avar^.address;
 if af_segment in avar^.address.flags then begin
  if llvmlink(avar,unitid,globid) then begin
   if globid < 0 then begin
    result.segaddress.address:= info.s.unitinfo^.llvmlists.globlist.addvalue(
                                                         avar,li_external,true);
   end
   else begin
    result.segaddress.address:= globid;
   end;
  end;
 end;
{
 if info.compileoptions * [co_llvm,co_writeunits] = 
                                            [co_llvm,co_writeunits] then begin
  if af_segment in avar^.address.flags then begin
   po1:= datatoele(avar);
   if po1^.header.defunit <> info.s.unitinfo then begin
   end;
  end;
 end;
}
end;

function trackaccess(const asub: psubdataty): int32;
var
 unitid: identty;
 globid: int32;
begin
 if llvmlink(asub,unitid,globid) then begin
  if globid < 0 then begin
   result:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(asub,true);
  end
  else begin
   result:= globid;
  end;
 end
 else begin
  result:= asub^.globid;
 end;
end;

type
 opsizety = (ops_none,ops_8,ops_16,ops_32,ops_64,ops_po);

const
 pushseg: array[opsizety] of opcodety =
           (oc_pushseg,oc_pushseg8,oc_pushseg16,
            oc_pushseg32,oc_pushseg64,oc_pushsegpo);
 pushloc: array[opsizety] of opcodety =
           (oc_pushloc,oc_pushloc8,oc_pushloc16,
            oc_pushloc32,oc_pushloc64,oc_pushlocpo);
 pushlocindi: array[opsizety] of opcodety =
           (oc_pushlocindi,oc_pushlocindi8,oc_pushlocindi16,
            oc_pushlocindi32,oc_pushlocindi64,oc_pushlocindipo);
 pushpar: array[opsizety] of opcodety =
           (oc_pushpar,oc_pushpar8,oc_pushpar16,
            oc_pushpar32,oc_pushpar64,oc_pushparpo);
 
procedure pushd(const ains: boolean; const stackoffset: integer;
          const before: boolean;
          const aaddress: addressvaluety; const avarele: elementoffsetty;
          const offset: dataoffsty; const aopdatatype: typeallocinfoty);
//todo: optimize

var
 ssaextension1: integer;

 function getop(const aop: opcodety): popinfoty;
 begin
  if ains then begin
   result:= insertitem(aop,stackoffset,before,ssaextension1);
  end
  else begin
   result:= additem(aop,ssaextension1);
  end;
 end;

var
 po1: popinfoty;
 framelevel1: integer;
 opsize1: opsizety;
 opflags1: addressflagsty;
begin
 opsize1:= ops_none;
 case aopdatatype.kind of
  das_pointer: begin
   opsize1:= ops_po;
  end;
  else begin
   if aopdatatype.kind in bitopdatakinds then begin
    case aopdatatype.size of
     1..8: begin 
      opsize1:= ops_8;
     end;
     9..16: begin
      opsize1:= ops_16;
     end;
     17..32: begin
      opsize1:= ops_32;
     end;
     33..64: begin
      opsize1:= ops_64;
     end;
    end;
   end; 
  end;
 end;
  
 with aaddress do begin //todo: use table
  opflags1:= flags;
  if aaddress.indirectlevel > 0 then begin
   exclude(opflags1,af_aggregate);
  end;
  if af_aggregate in opflags1 then begin
   ssaextension1:= getssa(ocssa_aggregate);
  end
  else begin
   ssaextension1:= 0;
  end;
  if af_segment in flags then begin
   po1:= getop(pushseg[opsize1]);
   with po1^ do begin
    par.memop.segdataaddress.a:= segaddress;
    par.memop.segdataaddress.offset:= offset;
   end;
  end
  else begin
   framelevel1:= info.sublevel-locaddress.framelevel-1;
   if framelevel1 >= 0 then begin
    ssaextension1:= ssaextension1 + getssa(ocssa_pushnestedvar);
   end;
   if af_param in flags then begin
    if af_paramindirect in flags then begin
     po1:= getop(pushlocindi[opsize1]);
    end
    else begin
     po1:= getop(pushpar[opsize1]);
    end;
   end
   else begin   
    po1:= getop(pushloc[opsize1]);
   end;
   with po1^ do begin
    par.memop.locdataaddress.a:= locaddress;
    tracklocalaccess(par.memop.locdataaddress.a,avarele,aopdatatype);
    par.memop.locdataaddress.a.framelevel:= framelevel1;
    par.memop.locdataaddress.offset:= offset;
   end;
  end;
  po1^.par.memop.t:= aopdatatype;
  po1^.par.memop.t.flags:= opflags1;
//  po1^.par.memop.t.flags:= aaddress.flags;
//  par.ssad:= ssaindex;
 end;
end;

//todo: optimize call
procedure pushdata(const address: addressvaluety;
                   const varele: elementoffsetty;
                   const offset: dataoffsty;
                         const opdatatype: typeallocinfoty);
begin
 pushd(false,0,false,address,varele,offset,opdatatype);
end;

procedure pushinsertdata(const stackoffset: integer; const before: boolean;
                  const address: addressvaluety;
                  const varele: elementoffsetty;
                  const offset: dataoffsty;
                  const opdatatype: typeallocinfoty);
begin
 pushd(true,stackoffset,before,address,varele,offset,opdatatype);
end;

function getcontextssa(const stackoffset: integer): int32;
var
 i1: int32;
 op1: opaddressty;
begin
 with info do begin
  i1:= s.stackindex+stackoffset;
  with info.contextstack[i1] do begin
   if i1 >= s.stacktop then begin
    result:= s.ssa.nextindex-1;
   end
   else begin
    op1:= contextstack[i1+1].opmark.address;
    if op1 >= opmark.address then begin
     result:= getoppo(op1-1)^.par.ssad; //use last op of context
    end
    else begin
     if op1 >= opcount-1 then begin
      result:= s.ssa.index;
     end
     else begin
      result:= getoppo(op1)^.par.ssad; //use current op
     end;
    end;
   end;
  end;
 end;
end;

procedure initfactcontext(const stackoffset: integer);
begin
 with info,contextstack[s.stackindex+stackoffset] do begin
  d.kind:= ck_fact;
  d.dat.fact.ssaindex:= getcontextssa(stackoffset);
  d.dat.indirection:= 0;
 end;
end;

//todo: use better and universal algorithm
function pushindirection(const stackoffset: integer;
                                       const address: boolean): boolean;
var
 i1,i2,i3: integer;
 po1: popinfoty;
 bo1,isstartoffset: boolean;
 ssabefore: int32;
begin
 result:= true;
 with info,contextstack[s.stackindex+stackoffset] do begin;
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_ref then begin
   internalerror(ie_handler,'20150413A');
  end;
 {$endif}
  if d.dat.indirection <= 0 then begin
   bo1:= (d.dat.datatyp.indirectlevel =
                                 d.dat.ref.c.address.indirectlevel);
   isstartoffset:= af_startoffset in d.dat.ref.c.address.flags;
   i3:= 0;
   if isstartoffset then begin
    i3:= d.dat.ref.offset;
   end;
   if address and not bo1 then begin
    i2:= 0;
    if d.dat.indirection = 0 then begin
     pushd(true,stackoffset,false,d.dat.ref.c.address,d.dat.ref.c.varele,
                i3,bitoptypes[das_pointer]);
     if not isstartoffset and (d.dat.ref.offset <> 0) then begin
      ssabefore:= getcontextssa(stackoffset);
      with insertitem(oc_offsetpoimm32,stackoffset,false)^ do begin
       par.ssas1:= ssabefore;
       setimmint32(d.dat.ref.offset,par);
      end;
      inc(d.dat.indirection);
     end;
     i2:= -1;
    end
    else begin
     pushinsert(stackoffset,false,d.dat.datatyp,d.dat.ref.c.address,
                                                        d.dat.ref.offset);
    end;
   end
   else begin
    pushd(true,stackoffset,false,d.dat.ref.c.address,d.dat.ref.c.varele,
                i3,bitoptypes[das_pointer]);
    i2:= -1;
   end;
   for i1:= d.dat.indirection to i2 do begin
    with insertitem(oc_indirectpo,stackoffset,false)^ do begin
     par.memop.t:= bitoptypes[das_pointer];
     par.ssas1:= par.ssad - getssa(oc_indirectpo);
    end;
   end;
   initfactcontext(stackoffset);
   if (not address or bo1) and not isstartoffset then begin
    offsetad(stackoffset,d.dat.ref.offset);
   end;
    {
    po1:= insertitem(oc_indirectpooffs,stackoffset,false);
    with po1^ do begin
     par.voffset:= d.dat.ref.offset;
     if info.backend = bke_llvm then begin
      par.voffset:= constlist.addi32(par.voffset).listid;
     end;
     par.ssas1:= par.ssad - getssa(oc_indirectpooffs);
    end;
    }
//   end;
//   inc(d.dat.datatyp.indirectlevel,d.dat.indirection);
  end
  else begin
   errormessage(err_cannotassigntoaddr,[],stackoffset);
   result:= false;
  end;
 end;
end;

const
 indirect: array[databitsizety] of opcodety = (
 //das_none,   das_1,       das_2_7,     das_8,
   oc_indirect,oc_indirect8,oc_indirect8,oc_indirect8,
 //das_9_15,     das_16,       das_17_31,    das_32,
   oc_indirect16,oc_indirect16,oc_indirect32,oc_indirect32,
 //das_33_63,    das_64,       das_pointer,
   oc_indirect64,oc_indirect64,oc_indirectpo,
 //das_f16,       das_f32,       das_f64        das_sub,      das_meta
   oc_indirectf16,oc_indirectf32,oc_indirectf64,oc_indirectpo,oc_none);

function getvalue(const stackoffset: integer; const adatasize: databitsizety;
                                  const retainconst: boolean = false): boolean;

var
 opdata1: typeallocinfoty;

 procedure doindirect();
 var
  op1: opcodety;
  si1: databitsizety;
  ssabefore: integer;
 begin
  with info,contextstack[s.stackindex+stackoffset],d do begin
   opdata1:= getopdatatype(dat.datatyp.typedata,dat.datatyp.indirectlevel);
   ssabefore:= d.dat.fact.ssaindex;
   with insertitem(indirect[opdata1.kind],stackoffset,false)^ do begin
    par.ssas1:= ssabefore;
    par.memop.t:= opdata1;
    d.dat.fact.ssaindex:= par.ssad;
    d.dat.fact.opdatatype:= opdata1;
   end;
  end;
 end;

var
 po1: ptypedataty;
 op1: popinfoty;
 int1: integer;
label errlab; 
begin                    //todo: optimize
 result:= false;
 with info,contextstack[s.stackindex+stackoffset] do begin
  po1:= ptypedataty(ele.eledataabs(d.dat.datatyp.typedata));
  case d.kind of
   ck_ref: begin
    if d.dat.datatyp.indirectlevel < 0 then begin
     errormessage(err_invalidderef,[],stackoffset);
     exit;
    end;
    if af_paramindirect in d.dat.ref.c.address.flags then begin
     dec(d.dat.indirection);
     dec(d.dat.datatyp.indirectlevel);
     if d.dat.datatyp.indirectlevel > 0 then begin
      d.dat.ref.c.address.flags:= d.dat.ref.c.address.flags - 
                                            [af_aggregate,af_paramindirect];
                //??? correct?
     end;
    end;
    if d.dat.indirection > 0 then begin //@ operator
     if d.dat.indirection = 1 then begin
      pushinsertaddress(stackoffset,false);
      d.dat.datatyp:= sysdatatypes[st_pointer]; //untyped pointer
     end
     else begin
      errormessage(err_cannotassigntoaddr,[],stackoffset);
      exit;
     end;
    end
    else begin
     if d.dat.indirection < 0 then begin //dereference
      inc(d.dat.indirection); //correct addr handling
      if not pushindirection(stackoffset,false) then begin
       exit;
      end;
//      dec(d.dat.datatyp.indirectlevel); //correct addr handling
      doindirect;
     end
     else begin
      opdata1:= getopdatatype(d.dat.datatyp.typedata,
                                             d.dat.datatyp.indirectlevel);
      pushinsertdata(stackoffset,false,d.dat.ref.c.address,
                               d.dat.ref.c.varele,d.dat.ref.offset,opdata1);
     end;
    end;
   end;
   ck_reffact: begin
    doindirect();
   end;
   ck_const: begin
    if retainconst then begin
     result:= true;
     exit;
    end;
    pushinsertconst(stackoffset,false,adatasize);
   end;
   ck_subres,ck_fact: begin
    if d.dat.indirection < 0 then begin
     for int1:= d.dat.indirection+2 to 0 do begin
      insertitem(oc_indirectpo,stackoffset,false);
     end;
     d.dat.indirection:= 0;
     doindirect();
    end
    else begin
     if d.dat.indirection > 0 then begin
      errormessage(err_cannotaddressexp,[],stackoffset);
      exit;
     end;
    end;
   end;
   ck_typearg,ck_controltoken: begin
    errormessage(err_valueexpected,[],stackoffset);
    goto errlab;
   end;
  {$ifdef mse_checkinternalerror}                             
   else begin
    internalerror(ie_notimplemented,'20140401B');
   end;
  {$endif}
  end;
errlab:
  if not (d.kind in [ck_fact,ck_subres]) then begin
   initfactcontext(stackoffset);
   d.dat.fact.opdatatype:= opdata1;
  end;
 end;
 result:= true;
end;

function getaddress(const stackoffset: integer;
                                const endaddress: boolean): boolean;
var
 si1: databitsizety;
begin
 result:= false;
 with info,contextstack[s.stackindex+stackoffset] do begin
 {$ifdef mse_checkinternalerror}                             
  if not (d.kind in datacontexts) then begin
   internalerror(ie_handler,'20140405A');
  end;
 {$endif}
  inc(d.dat.indirection);
  inc(d.dat.datatyp.indirectlevel);
  if d.dat.datatyp.indirectlevel <= 0 then begin
   errormessage(err_cannotassigntoaddr,[]);
   exit;
  end;
  case d.kind of
   ck_ref: begin
    if d.dat.indirection = 1 then begin
     if endaddress then begin
      pushinsert(stackoffset,false,d.dat.datatyp,d.dat.ref.c.address,
                                                       d.dat.ref.offset);
                  //address pointer on stack
      initfactcontext(stackoffset);
     end
     else begin
      inc(d.dat.ref.c.address.indirectlevel,d.dat.indirection);
      d.dat.indirection:= 0;
      if not (af_segment in d.dat.ref.c.address.flags) then begin
       tracklocalaccess(d.dat.ref.c.address.locaddress,d.dat.ref.c.varele,
                                 getopdatatype(d.dat.datatyp.typedata,
                                      d.dat.ref.c.address.indirectlevel));
      end;
      {
      d.kind:= ck_refconst;
      d.dat.ref.c.address.poaddress:=
                       d.dat.ref.c.address.poaddress + d.dat.ref.offset;
      d.dat.ref.offset:= 0;
      }
     end;
    end
    else begin
     if not pushindirection(stackoffset,true) then begin
      exit;
     end;
    end;
   end;
   ck_reffact: begin //
    d.kind:= ck_fact;
    result:= true;
//    internalerror1(ie_notimplemented,'20140404B'); //todo
//    exit;
   end;
   ck_fact,ck_subres: begin
    if d.dat.indirection <> 0 then begin
     result:= getvalue(stackoffset,das_none);
     exit;
    end;
   end;
  {$ifdef mse_checkinternalerror}
   else begin
    internalerror(ie_handler,'20140401A');
   end;
  {$endif}
  end;
 end;
 result:= true;
end;

function getassignaddress(const stackoffset: integer;
                                  const endaddress: boolean): boolean;
begin
 with info,contextstack[s.stackindex+stackoffset] do begin
  if (d.kind in datacontexts) then begin
   result:= getaddress(stackoffset,endaddress);
  end
  else begin
   result:= false;
   errormessage(err_argnotassign,[],stackoffset);
  end;
 end;
end;

procedure init;
var
 ty1: systypety;
 po1: pelementinfoty;
 po2: ptypedataty;
 int1: integer;
begin
 ele.addelement(tks_units,ek_none,globalvisi,unitsele);
 for ty1:= low(systypety) to high(systypety) do begin
  with systypeinfos[ty1] do begin
   po1:= ele.addelement(getident(name),ek_type,globalvisi);
   po2:= @po1^.data;
   po2^:= data;
   with sysdatatypes[ty1] do begin
    flags:= data.h.flags;
    indirectlevel:= data.h.indirectlevel;
    typedata:= ele.eleinforel(po1);
   end;
  end;
//  sysdatatypes[ty1].flags:= [];
 end;
 for int1:= low(sysconstinfos) to high(sysconstinfos) do begin
  with sysconstinfos[int1] do begin
   po1:= ele.addelement(getident(name),ek_const,globalvisi);
   with pconstdataty(@po1^.data)^ do begin
    val.d:= cval;
    val.typ:= sysdatatypes[ctyp];
   end;
  end;
 end;
 syssubhandler.init();
end;

procedure deinit;
begin
 syssubhandler.deinit();
end;

procedure resetssa();
begin
 with info do begin
  s.ssa.index:= 0;
  s.ssa.nextindex:= 0;
  s.ssa.blockindex:= 0;
 end;
end;

function getssa(const aopcode: opcodety; const count: integer): integer;
begin
 with info do begin
  result:= optable^[aopcode].ssa*count;
 end;
end;

function getssa(const aopcode: opcodety): integer;
begin
 with info do begin
  result:= optable^[aopcode].ssa;
 end;
end;

procedure updateop(const opsinfo: opsinfoty);
var
 kinda,kindb: datakindty;
// po1: pelementinfoty;
 int1: integer;
 sd1: stackdatakindty;
 op1: opcodety;
 po1: ptypedataty;
 bo1,bo2: boolean;
 si1: databitsizety;
label
 endlab;
begin
 with info do begin
  bo1:= false;
  with contextstack[s.stacktop-2] do begin
   if d.kind <> ck_const then begin
    getvalue(s.stacktop-s.stackindex-2,das_none);
   end;
   if contextstack[s.stacktop].d.kind <> ck_const then begin
    getvalue(s.stacktop-s.stackindex,das_none);
   end;
   po1:= ele.eledataabs(d.dat.datatyp.typedata);
   int1:= d.dat.datatyp.indirectlevel;
   if not tryconvert(s.stacktop-s.stackindex,po1,int1) then begin
    with contextstack[s.stacktop] do begin
     po1:= ele.eledataabs(d.dat.datatyp.typedata);
     int1:= d.dat.datatyp.indirectlevel;
    end;
    if tryconvert(s.stacktop-s.stackindex-2,po1,int1) then begin
     bo1:= true;
    end;
   end
   else begin
    bo1:= true;
   end;
   if not bo1 then begin
    incompatibletypeserror(contextstack[s.stacktop-2].d,
                                               contextstack[s.stacktop].d);
    goto endlab;
   end
   else begin
    if int1 > 0 then begin //indirectlevel
     sd1:= sdk_pointer;
    end
    else begin
     sd1:= stackdatakinds[po1^.h.kind];
    end;
    op1:= opsinfo.ops[sd1];
    if op1 = oc_none then begin
     operationnotsupportederror(d,contextstack[s.stacktop].d,opsinfo.opname);
     dec(s.stacktop,2);
    end
    else begin
     bo2:= false;
     if (d.kind = ck_const) and 
                      (contextstack[s.stacktop].d.kind = ck_const) then begin
      bo2:= true;
      case op1 of
       oc_and32: begin
        d.dat.constval.vinteger:= int32(d.dat.constval.vinteger) and
                 int32(contextstack[s.stacktop].d.dat.constval.vinteger);
       end;
       oc_or32: begin
        d.dat.constval.vinteger:= int32(d.dat.constval.vinteger) or
                 int32(contextstack[s.stacktop].d.dat.constval.vinteger);
       end;
       oc_shl32: begin
        d.dat.constval.vinteger:= int32(d.dat.constval.vinteger) shl
                 int32(contextstack[s.stacktop].d.dat.constval.vinteger);
       end;
       oc_shr32: begin
        d.dat.constval.vinteger:= int32(d.dat.constval.vinteger) shr
                 int32(contextstack[s.stacktop].d.dat.constval.vinteger);
       end;
       else begin
        bo2:= false;
       end;
      end;
     end;
     if bo2 then begin
      goto endlab;
     end;

     if int1 > 0 then begin
      si1:= das_pointer;
     end
     else begin
      si1:= po1^.h.datasize;
     end;
     if d.kind = ck_const then begin
      pushinsertconst(s.stacktop-s.stackindex-2,false,si1);
     end;
     with contextstack[s.stacktop] do begin
      if d.kind = ck_const then begin
       pushinsertconst(s.stacktop-s.stackindex,false,si1);
      end;
     end;
     with additem(op1)^ do begin      
      par.ssas1:= d.dat.fact.ssaindex;
      par.ssas2:= contextstack[s.stacktop].d.dat.fact.ssaindex;
      par.stackop.t:= getopdatatype(d.dat.datatyp.typedata,
                                      d.dat.datatyp.indirectlevel);
     end;
     d.kind:= ck_fact;
     d.dat.fact.ssaindex:= s.ssa.nextindex-1;
     d.dat.indirection:= 0;   
//     initfactcontext(-1);
    end;
endlab:
    dec(s.stacktop,2);
//    d.dat.datatyp:= sysdatatypes[resultdatatypes[sd1]];
    context:= nil;
   end;
  end;
  s.stackindex:= s.stacktop-1; 
 end;
end;

procedure getordrange(const typedata: ptypedataty; out range: ordrangety);
begin
 with typedata^ do begin
  case h.kind of
   dk_cardinal: begin
    if h.datasize <= das_8 then begin
     range.min:= infocard8.min;
     range.max:= infocard8.max;
    end
    else begin
     if h.datasize <= das_16 then begin
      range.min:= infocard16.min;
      range.max:= infocard16.max;
     end
     else begin
      range.min:= infocard32.min;
      range.max:= infocard32.max;
     end;
    end;
   end;
   dk_integer: begin
    if h.datasize <= das_8 then begin
     range.min:= infoint8.min;
     range.max:= infoint8.max;
    end
    else begin
     if h.datasize <= das_16 then begin
      range.min:= infoint16.min;
      range.max:= infoint16.max;
     end
     else begin
      range.min:= infoint32.min;
      range.max:= infoint32.max;
     end;
    end;
   end;
   dk_boolean: begin
    range.min:= 0;
    range.max:= 1;
   end;
  {$ifdef mse_checkinternalerror}
   else begin
    internalerror(ie_handler,'20120327B');
   end;
  {$endif}
  end;
 end;
end;

function getordcount(const typedata: ptypedataty): int64;
var
 ra1: ordrangety;
begin
 getordrange(typedata,ra1);
 result:= ra1.max - ra1.min + 1;
end;

function getordconst(const avalue: dataty): int64;
begin
 with avalue do begin
  case kind of
   dk_integer: begin
    result:= vinteger;
   end;
   dk_boolean: begin
    if vboolean then begin
     result:= 1;
    end
    else begin
     result:= 0;
    end;
   end;
  {$ifdef mse_checkinternalerror}
   else begin
    internalerror(ie_handler,'20140329A');
   end;
  {$endif}
  end;
 end;
end;

function getdatabitsize(const avalue: int64): databitsizety;
begin
 result:= das_8;
 if avalue < 0 then begin
  if avalue < -$80 then begin
   if avalue < -$8000 then begin
    if avalue < -$80000000 then begin
     result:= das_64;
    end
    else begin
     result:= das_32;
    end;
   end
   else begin
    result:= das_16;
   end;
  end;   
 end
 else begin
  if avalue > $7f then begin
   if avalue > $7fff then begin
    if avalue > $7fffffff then begin
     result:= das_64;
    end
    else begin
     result:= das_32;
    end;
   end
   else begin
    result:= das_16;
   end;
  end;   
 end;
end;

procedure trackalloc(const adatasize: databitsizety; const asize: integer; 
                                 var address: segaddressty);
begin
 if co_llvm in info.compileoptions then begin
  if address.segment = seg_globvar then begin
   if adatasize = das_none then begin
    address.address:= info.s.unitinfo^.llvmlists.globlist.
                                      addbytevalue(asize,info.s.globlinkage);
   end
   else begin
    address.address:= info.s.unitinfo^.llvmlists.globlist.
                                      addbitvalue(adatasize,info.s.globlinkage);
   end;
  end;
 end;
end;

{$ifdef mse_debugparser}
procedure outhandle(const text: string);
begin
 outinfo('*'+text+'*',false);
end;

procedure outinfo(const text: string; const indent: boolean = true);

 procedure writetype(const ainfo: contextdataty);
 var
  po1: ptypedataty;
 begin
  with ainfo.dat.datatyp do begin
   po1:= ele.eledataabs(typedata);
   write('T:',typedata,' ',
          getenumname(typeinfo(datakindty),ord(po1^.h.kind)));
   if po1^.h.kind <> dk_none then begin
    write(' F:',settostring(ptypeinfo(typeinfo(typeflagsty)),
                  integer(po1^.h.flags),false),
          ' I:',indirectlevel,':',ainfo.dat.indirection,
          ' F:',settostring(ptypeinfo(typeinfo(typeflagsty)),
                                            integer(flags),false),' ');
   end;
  end;
 end;//writetype

 procedure writetyp(const atyp: typeinfoty);
 var
  po1: ptypedataty;
 begin
  with atyp do begin
   if typedata = 0 then begin
    write('NIL');
   end
   else begin
    po1:= ele.eledataabs(typedata);
    write('T:',typedata,' ',
           getenumname(typeinfo(datakindty),ord(po1^.h.kind)));
    if po1^.h.kind <> dk_none then begin
     write(' F:',settostring(ptypeinfo(typeinfo(typeflagsty)),
                  integer(po1^.h.flags),false),
           ' I:',indirectlevel);
    end;
   end;
  end;
 end;//writetyp

 procedure writetypedata(const adata: ptypedataty);
 begin
   write(getidentname(pelementinfoty(pointer(adata)-eledatashift)^.header.name),
          ':',getenumname(typeinfo(datakindty),ord(adata^.h.kind)))
  end;
 
 procedure writeaddress(const aaddress: addressvaluety);
 begin
  with aaddress do begin
   write('I:',inttostr(indirectlevel),' A:',inttostr(integer(poaddress)),' ');
   write(settostring(ptypeinfo(typeinfo(addressflagsty)),
                                                     integer(flags),true),' ');
   if af_stack in flags then begin
    write(' F:',inttostr(locaddress.framelevel),' ');
   end;
   if af_segment in flags then begin
    write(' S:',getenumname(typeinfo(segmentty),ord(segaddress.segment)),' ');
   end;
  end;
 end;//writeaddress
 
 procedure writeref(const ainfo: contextdataty);
 begin
  with ainfo.dat.ref do begin
   writeaddress(c.address);
   write('O:',offset,' ');
  end;
 end;//writeref
 
var
 int1: integer;
begin
 with info do begin
  if indent then begin
   write('  ');
  end;
  write(text,' T:',s.stacktop,' I:',s.stackindex,' O:',opcount,
  ' S:',s.ssa.index,' N:',s.ssa.nextindex,
  ' cont:',currentcontainer);
  if currentcontainer <> 0 then begin
   write(' ',getidentname(ele.eleinfoabs(currentcontainer)^.header.name));
  end;
  write(' ',settostring(ptypeinfo(typeinfo(statementflagsty)),
                         integer(s.currentstatementflags),true));
  write(' L:'+inttostr(s.source.line+1)+':''',psubstr(s.debugsource,s.source.po)+''','''+
                         singleline(s.source.po),'''');
  writeln;
  for int1:= 0 to s.stacktop do begin
   write(fitstring(inttostrmse(int1),3,sp_right));
   if int1 = s.stackindex then begin
    write('*');
   end
   else begin
    write(' ');
   end;
   if (int1 < s.stacktop) and (int1 = contextstack[int1+1].parent) then begin
    write('-');
   end
   else begin
    write(' ');
   end;
   with contextstack[int1],d do begin
    write(fitstring(inttostrmse(parent),3,sp_right),' ');
    if bf_continue in transitionflags then begin
     write('>');
    end
    else begin
     write(' ');
    end;
    if context <> nil then begin
     with context^ do begin
      if cutbefore then begin
       write('-');
      end
      else begin
       write(' ');
      end;
      if pop then begin
       write('^');
      end
      else begin
       write(' ');
      end;
      if popexe then begin
       write('!');
      end
      else begin
       write(' ');
      end;
      if cutafter then begin
       write('-');
      end
      else begin
       write(' ');
      end;
     end;
     write(fitstring(inttostrmse(opmark.address),3,sp_right));
     write('<',context^.caption,'> ');
    end
    else begin
     write(fitstring(inttostrmse(opmark.address),3,sp_right));
     write('<NIL> ');
    end;
    write(getenumname(typeinfo(kind),ord(kind)),' ');
    case kind of
     ck_ident: begin
      write('$',hextostr(ident.ident,8),':',ident.len);
      write(' ',getidentname(ident.ident));
      write(' flags:',settostring(ptypeinfo(typeinfo(identflagsty)),
                                           integer(ident.flags),true));
      {
      if ident.continued then begin
       write('c ');
      end
      else begin
       write('  ');
      end;
      }
     end;
     {
     ck_getfact: begin
      with getfact do begin
       write('flags:',settostring(ptypeinfo(typeinfo(factflagsty)),
                                           integer(getfact.flags),true));
      end;
     end;
     }
     ck_fact,ck_subres: begin
      write('ssa:',d.dat.fact.ssaindex,' ');
      writetype(d);
     end;
     ck_ref: begin
      writeref(d);
      writetype(d);
     end;
     ck_reffact: begin
      writetype(d);
     end;
     ck_const: begin
      writetype(d);
      write('V:');
      case dat.constval.kind of
       dk_boolean: begin
        write(dat.constval.vboolean,' ');
       end;
       dk_integer: begin
        write(dat.constval.vinteger,' ');
       end;
       dk_float: begin
        write(dat.constval.vfloat,' ');
       end;
       dk_address: begin
        writeaddress(dat.constval.vaddress);
       end;
      end;
     end;
     ck_subdef: begin
      write('fl:',settostring(ptypeinfo(typeinfo(subflagsty)),
                                           integer(subdef.flags),true),
            ' ma:',subdef.match,
                            ' ps:',subdef.paramsize,' vs:',subdef.varsize);
     end;
     ck_paramsdef: begin
      with paramsdef do begin
       write('kind:',getenumname(typeinfo(kind),ord(kind)))
      end;
     end;
     ck_recorddef: begin
      write('foffs:',d.rec.fieldoffset);
     end;
     ck_classdef: begin
      write('foffs:',d.cla.fieldoffset,' virt:',d.cla.virtualindex);
     end;
     ck_index: begin
      write('opshiftmark:'+inttostr(opshiftmark));
     end;
     ck_typedata: begin
      writetypedata(d.typedata);
     end;
     ck_typeref: begin
      writetypedata(ele.eledataabs(d.typeref));
     end;
     ck_typetype,ck_fieldtype: begin
      writetyp(typ);
     end;
     ck_control: begin
      with control do begin
       write('kind:',getenumname(typeinfo(kind),ord(kind)),' OP1:',
                                                       opmark1.address);
      end;
     end;
    end;
    writeln(' '+inttostr(start.line+1)+':''',
             psubstr(debugstart,start.po),''',''',singleline(start.po),'''');
   end;
  end;
 end;
end;

{$endif}

{$ifdef mse_debugparser}
procedure dumpelements();
var
 ar1: msestringarty;
 int1: integer;
begin
 writeln('--ELEMENTS---------------------------------------------------------');
 ar1:= ele.dumpelements;
 for int1:= 0 to high(ar1) do begin
  writeln(ar1[int1]);
 end;
 writeln('-------------------------------------------------------------------');
end;
{$endif}

end.