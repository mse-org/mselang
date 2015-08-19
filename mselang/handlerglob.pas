{ MSElang Copyright (c) 2013-2015 by Martin Schreiber
   
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
unit handlerglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,{opcode,}opglob,listutils,llvmbitcodes;

type
 ordrangety = record
  min: int64;
  max: int64;
 end;
 card8infoty = record
  min: card8;
  max: card8;
 end;
 card16infoty = record
  min: card16;
  max: card16;
 end;
 card32infoty = record
  min: card32;
  max: card32;
 end;
 card64infoty = record
  min: card64;
  max: card64;
 end;

 int8infoty = record
  min: int8;
  max: int8;
 end;
 int16infoty = record
  min: int16;
  max: int16;
 end;
 int32infoty = record
  min: int32;
  max: int32;
 end;
 int64infoty = record
  min: int64;
  max: int64;
 end;
 float32infoty = record
  min: single;
  max: single;
 end;
 float64infoty = record
  min: double;
  max: double;
 end;

 arrayiteminfoty = record
  itemtypedata: elementoffsetty;
  itemindirectlevel: integer;
 end;
 infoarrayty = record
  i: arrayiteminfoty;
  indextypedata: elementoffsetty;
 end;

 infodynarrayty = record
  i: arrayiteminfoty;
 end;

 infoclassflagty = (icf_virtualtablevalid);
 infoclassflagsty = set of infoclassflagty;  
 infoclassty = record
  intfnamenode: elementoffsetty;
  intftypenode: elementoffsetty;
  implnode: elementoffsetty;
  defs: segaddressty; //classdefinfoty in target const
  pendingdescends: listadty;
//  fieldsize: dataoffsty;
  allocsize: dataoffsty;
  virtualcount: integer;
  flags: infoclassflagsty;
  interfaceparent: elementoffsetty; //last parent with interface items
  interfacecount: integer;
  interfacechain: elementoffsetty;
  interfacesubcount: integer;
 end;
 pinfoclassty = ^infoclassty;

 ancestorchaindataty = record
  next: elementoffsetty;  //chain, root = typedataty.ancestor
  intftype: elementoffsetty;
 end;
 pancestorchaindataty = ^ancestorchaindataty;

 infointerfacety = record
//  ancestorchain: elementoffsetty; //-> infoancestordataty
  subchain: elementoffsetty;      //->
  subcount: integer;  
 end;
 pinfointerfacety = ^infointerfacety;

 infosubty = record
  sub: elementoffsetty;
 end;
 pinfosubty = ^infosubty;
 
 infoenumitemty = record
  value: integer;
  enum: elementoffsetty;
  next: elementoffsetty;
 end;
 pinfoenumitemty = ^infoenumitemty;

 infoenumty = record
  itemcount: integer;
  first: elementoffsetty;
  flags: enumflagsty;
 end;
 
 infosetty = record
  itemtype: elementoffsetty;
 end;

 infoaddressty = record
  case integer of
   0: (sub: elementoffsetty);
 end;

// writeiniprocty = procedure (const address: dataoffsty);
// writefiniprocty = procedure (const address: dataoffsty);
 addresskindty = boolean;{(adk_local,adk_global)}

 managedopty = (mo_ini,mo_fini,mo_incref,mo_decref);
 
 managedtypeprocty = procedure(const op: managedopty;
                       const aadress: addressrefty; const count: datasizety;
                                                     const ssaindex: integer);

 manageddataty = record
  managedele: elementoffsetty;
 end;
 pmanageddataty = ^manageddataty;

 refdataty = record
  ref: elementoffsetty;
 end;
 prefdataty = ^refdataty;

 typedataheaderty = record
  ancestor: elementoffsetty; //first, 
            //valid for ancestordatakinds and ancestorchaindatakinds
  kind: datakindty;
  base: elementoffsetty; //base type, ex: precordty = ^recordty -> recordty type
                         //used for addressing record fields.
  rtti: dataaddressty; //0 -> none
  flags: typeflagsty;
  indirectlevel: indirectlevelty; //total indirection count
  bitsize: integer;
  bytesize: integer;
  datasize: databitsizety;
 end;
  
 typedataty = record
  h: typedataheaderty;
  case datakindty of 
   dk_boolean:(
    dummy1: byte //for systypeinfos list
   );
   dk_cardinal:(
    case databitsizety of
     das_1,das_2_7,das_8: (infocard8: card8infoty);
     das_9_15,das_16: (infocard16: card16infoty);
     das_17_31,das_32: (infocard32: card32infoty);
     das_33_63,das_64: (infocard64: card64infoty);
   );
   dk_integer:(
    case databitsizety of  
     das_1,das_2_7,das_8: (infoint8: int8infoty);
     das_9_15,das_16: (infoint16: int16infoty);
     das_17_31,das_32: (infoint32: int32infoty);
     das_33_63,das_64: (infoint64: int64infoty);
   );
   dk_float:(
    case databitsizety of
     das_32:(infofloat32: float32infoty);
     das_64:(infofloat64: float64infoty);
   );
   dk_string8,dk_dynarray:(
    manageproc: managedtypeprocty;
    itemsize: integer; //bytes
    case datakindty of
     dk_string8:(
      dummy2: byte; //for systypeinfos list
     );
     dk_dynarray:(
      infodynarray: infodynarrayty;
     );
   );
   dk_array:(
    infoarray: infoarrayty;
   );
   dk_address:(
    infoaddress: infoaddressty;
   );
   dk_record,dk_class:(
    fieldchain: elementoffsetty;
    case datakindty of
     dk_class:(
//      classancestor: elementoffsetty;
      case datakindty of
       dk_class:(
        infoclass: infoclassty;
       );
     );
   );
   dk_interface:(
    infointerface: infointerfacety;
   );
   dk_sub:(
    infosub: infosubty;
   );
   dk_enum:(
    infoenum: infoenumty;
   );
   dk_enumitem:(
    infoenumitem: infoenumitemty;
   );
   dk_set:(
    infoset: infosetty;
   );
 end;
 ptypedataty = ^typedataty;
 
 vardestinfoty = record
  address: addressvaluety;
  offset: dataoffsty;
  typ: ptypedataty;
 end;
 
 constdataty = record
//  typ: elementoffsetty; //typedataty
  val: datainfoty;
//  d: contextdataty;
 end;
 pconstdataty = ^constdataty;

 vfinfoty = record
  typ: elementoffsetty;   //elementdata relative typedataty
  flags: typeflagsty;
  next: elementoffsetty;  //chain in same scope, used for ini, fini
                          //root = typedataty.fieldchain
 end;
 vardataty = record
  vf: vfinfoty;           //same layout as fielddataty
  address: addressvaluety; //indirectlevel = total
 end;
 pvardataty = ^vardataty;
 ppvardataty = ^pvardataty;

// vardatapoaty = array[0..0] of pvardataty;
// pvardatapoaty = ^vardatapoaty;

 fielddataty = record
  vf: vfinfoty;           //same layout as vardataty
  offset: dataoffsty;
  flags: addressflagsty;
  indirectlevel: integer;
 end;
 pfielddataty = ^fielddataty;

 nestedvardataty = record
  next: elementoffsetty; //chain, root = subdataty nestedvarchain
//  nestedindex: integer;
  address: nestedaddressty;
 end;
 pnestedvardataty = ^nestedvardataty;
 
 subdataty = record
  next: elementoffsetty;
  impl: elementoffsetty; //pfuncdataty
  typ: elementoffsetty;  //typedataty dk_address
  links: linkindexty;    //calls which need to be resolved
  mark: forwardindexty;
  flags: subflagsty;
  tableindex: integer; //-1 = none
  address: opaddressty;
  trampolinelinks: linkindexty;   //for virtual interface items
  trampolineaddress: opaddressty;
  nestinglevel: integer;
  nestedvarele: elementoffsetty;
  nestedvarchain: elementoffsetty;
  nestedvarcount: integer;
  varchain: elementoffsetty;
//  varallocs: dataoffsty;
//  varalloccount: integer;
  paramfinichain: elementoffsetty;
  resulttype: elementoffsetty;
  allocs: suballocinfoty;
  paramsize: integer;
  paramcount: integer;
  globid: int32; //for llvm
  linkage: linkagety;
  paramsrel: record //array of relative pvardataty (elementoffsetty)
  end;
 end;
 psubdataty = ^subdataty;

 sysfuncty = (sf_write,sf_writeln,sf_setlength,sf_sizeof,sf_inc,sf_dec,
              sf_getmem,sf_getzeromem,sf_freemem,sf_setmem,sf_halt);

 sysfuncdataty = record
  func: sysfuncty;
//  sysop: opty;
 end;
 psysfuncdataty = ^sysfuncdataty;

 unitdataty = record
  varchain: elementoffsetty;
  next: elementoffsetty;
 end;
 punitdataty = ^unitdataty;
 implementationdataty = record
 end;
 pimplementationdataty = ^implementationdataty;

 usesdataty = record
  ref: elementoffsetty;
 end;
 pusesdataty = ^usesdataty;
 
 conditiondataty = record
  deleted: boolean;
 end;
 pconditiondataty = ^conditiondataty;
 
 classimpnodedataty = record
 end;
 pclassimpnodedataty = ^classimpnodedataty;
 
 classintfnamenodedataty = record
 end;
 pclassintfnamenodedataty = ^classintfnamenodedataty;
 
 classintftypenodedataty = record
 end;
 pclassintftypenodedataty = ^classintftypenodedataty;
 
{
 classdataty = record
 end;
 pclassdataty = ^classdataty;
}
{
 classesdataty = record
  scopebefore: elementoffsetty;
 end;
 pclassesdataty = ^classesdataty;
}
 visibledataty = record
 end;
 pvisibledataty = ^visibledataty;


const 
 datasizes: array[0..64] of databitsizety = (
 //   0        1     2       3       4       5       6       7
  das_none,das_1,das_2_7,das_2_7,das_2_7,das_2_7,das_2_7,das_2_7,
 //   8     9        10       11       12       13       14       15   
  das_8,das_9_15,das_9_15,das_9_15,das_9_15,das_9_15,das_9_15,das_9_15,
 //   16     17        18        19        20        21        22        23 
  das_16,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,
 //   24        25        26        27        28           29        30        31
  das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,das_17_31,
 //   32     33        34        35        36        37        38        39 
  das_32,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   40        41        42        43        44        45        46        47
  das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   48        49        50        51        52        53        54        55
  das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   56        57        58        59        60        61        62        64
  das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,das_33_63,
 //   64 
  das_64);
  
 bitsizes: array[databitsizety] of integer =
//das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
 (    0,       1,      7,    8,      15,    16,       31,    32,
//das_33_63,das_64,das_pointer,das_f16,das_f23,das_f64,das_sub,       das_meta
         63,    64,pointerbitsize,16,  32,     64,     pointerbitsize,0);
         
 bytesizes: array[databitsizety] of integer =
//das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
 (    0,       1,      1,    1,       2,     2,        4,     4,
//das_33_63,das_64,das_pointer,das_f16,das_f23,das_f64,das_sub,    das_meta
          8,     8,pointersize,2,      4,      8,      pointersize,0);
 
 
function gettypesize(const typedata: typedataty): datasizety; inline;
function basetype(const atype: ptypedataty): elementoffsetty;
function basetype(const atype: elementoffsetty): elementoffsetty;

procedure inittypedata(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; aflags: typeflagsty;
            artti: dataaddressty; aancestor: elementoffsetty); inline;
procedure inittypedatabit(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abitsize: integer;
            aflags: typeflagsty = [];
            artti: dataaddressty = 0; aancestor: elementoffsetty = 0); inline;
procedure inittypedatabyte(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abytesize: integer;
            aflags: typeflagsty = [];
            artti: dataaddressty = 0; aancestor: elementoffsetty = 0); inline;
procedure inittypedatasize(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; adatasize: databitsizety;
            aflags: typeflagsty = [];
            artti: dataaddressty = 0; aancestor: elementoffsetty = 0); inline;

implementation
uses
 elements;
 
function gettypesize(const typedata: typedataty): datasizety; inline;
begin
 result:= typedata.h.bytesize;
 if typedata.h.indirectlevel <> 0 then begin
  result:= pointersize;
 end;
end;

function basetype(const atype: ptypedataty): elementoffsetty;
begin
 result:= atype^.h.base;
 if result = 0 then begin
  result:= ele.eledatarel(atype);
 end;
end;

function basetype(const atype: elementoffsetty): elementoffsetty;
begin
 result:= ptypedataty(ele.eledataabs(atype))^.h.base;
 if result = 0 then begin
  result:= atype;
 end;
end;

procedure inittypedata(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; aflags: typeflagsty;
            artti: dataaddressty; aancestor: elementoffsetty); inline;
begin
 atype.h.base:= 0;
 atype.h.rtti:= artti;
 atype.h.flags:= aflags;
 atype.h.indirectlevel:= aindirectlevel;
 atype.h.ancestor:= aancestor;
 atype.h.kind:= akind;
end;

procedure inittypedatabit(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abitsize: integer;
            aflags: typeflagsty = [];
            artti: dataaddressty = 0; aancestor: elementoffsetty = 0); inline;
begin
 inittypedata(atype,akind,aindirectlevel,aflags,artti,aancestor);
 atype.h.bitsize:= abitsize;
 atype.h.bytesize:= (abitsize+7) div 8;
 if atype.h.bitsize >= 64 then begin
  atype.h.datasize:= das_none;
 end
 else begin
  atype.h.datasize:= datasizes[atype.h.bitsize];
 end;
end;

procedure inittypedatabyte(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; abytesize: integer;
            aflags: typeflagsty = [];
            artti: dataaddressty = 0; aancestor: elementoffsetty = 0); inline;
begin
 inittypedata(atype,akind,aindirectlevel,aflags,artti,aancestor);
 atype.h.bytesize:= abytesize;
 if abytesize >= pointersize then begin
  atype.h.datasize:= das_none;
  atype.h.bitsize:= 0;
 end
 else begin
  atype.h.bitsize:= abytesize*8;
  atype.h.datasize:= datasizes[atype.h.bitsize];
 end;  
end;

procedure inittypedatasize(var atype: typedataty; akind: datakindty;
            aindirectlevel: integer; adatasize: databitsizety;
            aflags: typeflagsty = [];
            artti: dataaddressty = 0; aancestor: elementoffsetty = 0); inline;
begin
 inittypedata(atype,akind,aindirectlevel,aflags,artti,aancestor);
 atype.h.datasize:= adatasize;
 atype.h.bytesize:= bytesizes[adatasize];
 atype.h.bitsize:= bitsizes[adatasize];
end;

end.