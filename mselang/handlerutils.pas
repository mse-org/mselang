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
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 handlerglob,parserglob,elements,msestrings,msetypes;

type
 systypety = (st_none,st_bool8,st_int32,st_float64,st_string8);
 systypeinfoty = record
  name: string;
  data: typedataty;
 end;
 sysconstinfoty = record
  name: string;
  ctyp: systypety;
  cval: dataty;
 end;
  
 opinfoty = record
  ops: array[stackdatakindty] of opty;
  opname: string;
 end;

var
 unitsele: elementoffsetty;
 sysdatatypes: array[systypety] of typeinfoty;

const
 stackdatakinds: array[datakindty] of stackdatakindty = 
   //dk_none,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
   (sdk_none,sdk_bool8,sdk_int32,   sdk_int32, sdk_flo64,sdk_none,
  //dk_address,dk_record,dk_string,dk_array,dk_class,dk_interface
    sdk_none,  sdk_none, sdk_none, sdk_none,sdk_none,sdk_none,
  //dk_enum,dk_enumitem, dk_set
    sdk_none,   sdk_none, sdk_none);
                
 resultdatakinds: array[stackdatakindty] of datakindty =
            //sdk_bool8,sdk_int32,sdk_flo64
           (dk_none,dk_boolean,dk_integer,dk_float);
 resultdatatypes: array[stackdatakindty] of systypety =
            //sdk_bool8,sdk_int32,sdk_flo64
           (st_none,st_bool8,st_int32,st_float64);

type
 comperrorty = (ce_invalidfloat,ce_expressionexpected,ce_startbracketexpected,
               ce_endbracketexpected);
const
 errormessages: array[comperrorty] of msestring = (
  'Invalid Float',
  'Expression expected',
  '''('' expected',
  ''')'' expected'
 );

//procedure error(const error: comperrorty;
//                   const pos: pchar=nil);
//procedure parsererror(const info: pparseinfoty; const text: string);
//procedure identnotfounderror(const info: contextitemty; const text: string);
//procedure wrongidentkinderror(const info: contextitemty; 
//       wantedtype: elementkindty; const text: string);
//procedure outcommand(const items: array of integer;
//                     const text: string);

function getidents(const astackoffset: integer;
                     out idents: identvecty): boolean; overload;
function getidents(const astackoffset: integer): identvecty; overload;
 
function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty; const visibility: visikindsty;
                                    out ainfo: pointer): boolean;
function findkindelements(
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: visikindsty; out aelement: pelementinfoty;
           out firstnotfound: integer; out idents: identvecty): boolean;
function findkindelements(
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: visikindsty; out aelement: pelementinfoty): boolean;
function findkindelementsdata(
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: visikindsty; out ainfo: pointer;
              out firstnotfound: integer; out idents: identvecty): boolean;
function findkindelementsdata(
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: visikindsty; out ainfo: pointer): boolean;

function findvar(const astackoffset: integer; 
        const visibility: visikindsty; out varinfo: vardestinfoty): boolean;
function addvar(const aname: identty; const avislevel: visikindsty;
          var chain: elementoffsetty; out aelementdata: pvardataty): boolean;

procedure updateop(const opinfo: opinfoty);
function convertconsts(): stackdatakindty;
function getvalue(const stackoffset: integer;
                               const retainconst: boolean = false): boolean;
function getaddress(const stackoffset: integer;
                                  const endaddress: boolean): boolean;

procedure push(const avalue: boolean); overload;
procedure push(const avalue: integer); overload;
procedure push(const avalue: real); overload;
procedure push(const avalue: addressvaluety; const offset: dataoffsty;
                                          const indirect: boolean); overload;
procedure push(const avalue: datakindty); overload;
procedure pushconst(const avalue: contextdataty);
procedure pushdata(const address: addressvaluety; const offset: dataoffsty;
                                                   const size: datasizety);
procedure pushinsert(const stackoffset: integer; const before: boolean;
                                     const avalue: datakindty); overload;
procedure pushinsert(const stackoffset: integer; const before: boolean;
            const avalue: addressvaluety; const offset: dataoffsty;
                                            const indirect: boolean); overload;
            //class field address
function pushinsertvar(const stackoffset: integer; const before: boolean;
                                     const atype: ptypedataty): integer;
procedure pushinsertconstaddress(const stackoffset: integer;
                            const before: boolean; const address: dataoffsty);
procedure pushinsertdata(const stackoffset: integer; const before: boolean;
                  const address: addressvaluety; const offset: dataoffsty;
                                                  const size: datasizety);
procedure pushinsertaddress(const stackoffset: integer; const before: boolean);
procedure pushinsertconst(const stackoffset: integer; const before: boolean);
procedure offsetad(const stackoffset: integer; const aoffset: dataoffsty);

procedure setcurrentloc(const indexoffset: integer);
procedure setcurrentlocbefore(const indexoffset: integer);
procedure setlocbefore(const destindexoffset,sourceindexoffset: integer);
procedure setloc(const destindexoffset,sourceindexoffset: integer);

procedure getordrange(const typedata: ptypedataty; out range: ordrangety);
function getordcount(const typedata: ptypedataty): int64;
function getordconst(const avalue: dataty): int64;
function getdatabitsize(const avalue: int64): databitsizety;

procedure init();
procedure deinit();

{$ifdef mse_debugparser}
procedure outhandle(const text: string);
procedure outinfo(const text: string; const indent: boolean);
{$endif}
                           
implementation
uses
 errorhandler,typinfo,opcode,stackops,parser,sysutils,mseformatstr,
 syssubhandler,managedtypes,grammar;
   
const
 mindouble = -1.7e308;
 maxdouble = 1.7e308; //todo: use exact values
 
  //will be replaced by systypes.mla
 systypeinfos: array[systypety] of systypeinfoty = (
   (name: 'none'; data: (rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 0; bytesize: 0; datasize: das_none; ancestor: 0; kind: dk_none;
       dummy: 0)),
   (name: 'bool8'; data: (rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 8; bytesize: 1; datasize: das_8; ancestor: 0; kind: dk_boolean;
       dummy: 0)),
   (name: 'int32'; data: (rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 32; bytesize: 4; datasize: das_32; ancestor: 0;
                 kind: dk_integer; infoint32:(min: minint; max: maxint))),
   (name: 'flo64'; data: (rtti: 0; flags: []; indirectlevel: 0;
       bitsize: 64; bytesize: 8; datasize: das_64; ancestor: 0;
                 kind: dk_float; infofloat64:(min: mindouble; max: maxdouble))),
   (name: 'string8'; data: (rtti: 0; flags: [tf_hasmanaged,tf_managed];
       indirectlevel: 0;
       bitsize: pointerbitsize; bytesize: pointersize; datasize: das_pointer;
        ancestor: 0;
                 kind: dk_string8; manageproc: @managestring8;
                 ))
  );
 sysconstinfos: array[0..1] of sysconstinfoty = (
   (name: 'false'; ctyp: st_bool8; cval:(kind: dk_boolean; vboolean: false)),
   (name: 'true'; ctyp: st_bool8; cval:(kind: dk_boolean; vboolean: true))
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
  result:= findkindelementdata(contextstack[stackindex+astackoffset].d,
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
  po1:= @contextstack[stackindex+astackoffset];
  identcount:= -1;
  for int1:= 0 to high(idents.d) do begin
   idents.d[int1]:= po1^.d.ident.ident;
   if not po1^.d.ident.continued then begin
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
            out firstnotfound: integer; out idents: identvecty): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents(astackoffset,idents) then begin
  with info do begin
   if ele.findparentscope(idents.d[0],akinds,visibility,eleres) then begin
    result:= true;
    firstnotfound:= 0;
   end
   else begin
    result:= ele.findupward(idents,akinds,visibility,eleres,firstnotfound);
    if not result then begin //todo: use cache
     ele2:= ele.elementparent;
     for int1:= 0 to high(info.unitinfo^.implementationuses) do begin
      ele.elementparent:=
        info.unitinfo^.implementationuses[int1]^.interfaceelement;
      result:= ele.findupward(idents,akinds,visibility,eleres,firstnotfound);
      if result then begin
       break;
      end;
     end;
     if not result then begin
      for int1:= 0 to high(info.unitinfo^.interfaceuses) do begin
       ele.elementparent:=
         info.unitinfo^.interfaceuses[int1]^.interfaceelement;
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
           const visibility: visikindsty; out aelement: pelementinfoty): boolean;
var
 idents: identvecty;
 firstnotfound: integer;
begin
 result:= findkindelements(astackoffset,akinds,visibility,
                              aelement,firstnotfound,idents) and 
                              (firstnotfound > idents.high);
 if not result then begin
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
             out idents: identvecty): boolean;
begin
 result:= findkindelements(astackoffset,akinds,visibility,ainfo,
                                firstnotfound,idents);
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
 po1:= ele.addelement(aname,avislevel,ek_var);
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
  contextstack[stackindex].d.kind:= ck_error;
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
   with contextstack[stacktop+items[int1]].d do begin
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
function pushinsertvar(const stackoffset: integer; const before: boolean;
                                       const atype: ptypedataty): integer;
begin
 with insertitem(stackoffset,before)^ do begin
  op:= @pushop;
  result:= atype^.bytesize; //todo: alignment
  par.imm.vsize:= result;
 end;
end;

procedure pushinsertconstaddress(const stackoffset: integer; const before: boolean;
                             const address: dataoffsty);
begin
 with insertitem(stackoffset,before)^ do begin
  op:= @pushconstaddress;
  par.vaddress:= address;
 end;
end;

procedure pushinsertaddress(const stackoffset: integer; const before: boolean);
begin
 with insertitem(stackoffset,before)^,info,
                     contextstack[stackindex+stackoffset].d.ref do begin
  if af_segment in address.flags then begin
   op:= @pushsegaddr;
   par.vsegaddress.a:= address.segaddress;
   par.vsegaddress.offset:= offset;
  end
  else begin
   op:= @pushlocaddr;
   par.vlocaddress.a:= address.locaddress;
   par.vlocaddress.a.framelevel:= info.sublevel-address.locaddress.framelevel-1;
   par.vlocaddress.offset:= offset;
  end;
 end;
end;

procedure pushinsertconst(const stackoffset: integer; const before: boolean);
var
 po1: pcontextitemty;
begin
 with insertitem(stackoffset,before)^,info do begin
  po1:= @contextstack[stackindex+stackoffset];
  case po1^.d.constval.kind of
   dk_boolean: begin
    op:= @push8;
    par.imm.vboolean:= po1^.d.constval.vboolean;
   end;
   dk_integer,dk_enum: begin
    op:= @push32;
    par.imm.vint32:= po1^.d.constval.vinteger;
   end;
   dk_float: begin
    op:= @push64;
    par.imm.vfloat64:= po1^.d.constval.vfloat;
   end;
   dk_string8: begin
    op:= @pushconstaddress;
    par.vaddress:= stringconst(po1^.d.constval.vstring);
   end;
  {$ifdef mse_checkinternalerror}                             
   else begin
    internalerror(ie_handler,'20131121A');
   end;
  {$endif}
  end;
 end;
end;

procedure offsetad(const stackoffset: integer; const aoffset: dataoffsty);
begin
 if aoffset <> 0 then begin
  with insertitem(stackoffset,false)^ do begin
   op:= @addimmint32;
   par.imm.vint32:= aoffset;
  end;
 end;
end;

procedure push(const avalue: boolean); overload;
begin
 with additem({info})^ do begin
  op:= @push8;
  par.imm.vboolean:= avalue;
 end;
end;

procedure push(const avalue: integer); overload;
begin
 with additem({info})^ do begin
  op:= @push32;
  par.imm.vint32:= avalue;
 end;
end;

procedure push(const avalue: real); overload;
begin
 with additem({info})^ do begin
  op:= @push64;
  par.imm.vfloat64:= avalue;
 end;
end;

procedure pushins(const aitem: popinfoty;
          const avalue: addressvaluety; const offset: dataoffsty;
                                           const indirect: boolean);
begin
 with aitem^ do begin
  if af_nil in avalue.flags then begin
   op:= @pushaddr;
   par.imm.vpointer:= 0;
  end
  else begin
   if af_segment in avalue.flags then begin
    if indirect then begin
     op:= @pushsegaddrindi;
    end
    else begin
     op:= @pushsegaddr;
    end;
    par.vsegaddress.a:= avalue.segaddress;
    par.vsegaddress.offset:= offset;
   end
   else begin
    if indirect then begin
     op:= @pushlocaddrindi;
    end
    else begin
     op:= @pushlocaddr;
    end;
    par.vlocaddress.a:= avalue.locaddress;
    par.vlocaddress.a.framelevel:= info.sublevel-avalue.locaddress.framelevel-1;
    par.vlocaddress.offset:= offset;
   end;
  end;
 end;
end;

procedure push(const avalue: addressvaluety; const offset: dataoffsty;
            const indirect: boolean); overload;
begin
 pushins(additem,avalue,offset,indirect);
end;

procedure pushinsert(const stackoffset: integer; const before: boolean;
            const avalue: addressvaluety; const offset: dataoffsty;
            const indirect: boolean); overload;
begin
 pushins(insertitem(stackoffset,before),avalue,offset,indirect);
end;

procedure push(const avalue: datakindty); overload;
      //no alignsize
begin
 with additem({info})^ do begin
  op:= @pushdatakind;
  par.vdatakind:= avalue;
 end;
end;

procedure pushinsert(const stackoffset: integer; const before: boolean;
                                    const avalue: datakindty); overload;
      //no alignsize
begin
 with insertitem(stackoffset,before)^ do begin
  op:= @pushdatakind;
  par.vdatakind:= avalue;
 end;
end;

procedure pushconst(const avalue: contextdataty);
//todo: optimize
begin
 with avalue do begin
  case constval.kind of
   dk_boolean: begin
    push(constval.vboolean);
   end;
   dk_integer: begin
    push(constval.vinteger);
   end;
   dk_float: begin
    push(constval.vfloat);
   end;
   dk_address: begin
    push(constval.vaddress,0,false);
   end;
  end;
 end;
end;

procedure int32toflo64({; const index: integer});
begin
 with additem({info})^ do begin
  op:= @stackops.int32toflo64;
  {
  with d.op1 do begin
   index0:= index;
  end;
  }
 end;
end;

procedure setcurrentloc(const indexoffset: integer);
begin 
 with info do begin
  ops[contextstack[stackindex+indexoffset].opmark.address].par.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setcurrentlocbefore(const indexoffset: integer);
begin 
 with info do begin
  ops[contextstack[stackindex+indexoffset].opmark.address-1].par.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setlocbefore(const destindexoffset,sourceindexoffset: integer);
begin
 with info do begin
  ops[contextstack[stackindex+destindexoffset].opmark.address-1].
                                                               par.opaddress:=
         contextstack[stackindex+sourceindexoffset].opmark.address-1;
 end; 
end;

procedure setloc(const destindexoffset,sourceindexoffset: integer);
begin
 with info do begin
  ops[contextstack[stackindex+destindexoffset].opmark.address].
                                                               par.opaddress:=
         contextstack[stackindex+sourceindexoffset].opmark.address-1;
 end; 
end;

function convertconsts(): stackdatakindty;
                //convert stacktop, stacktop-2
begin
 with info,contextstack[stacktop-2] do begin
  result:= stackdatakinds[d.constval.kind];  
  if contextstack[stacktop].d.constval.kind <> d.constval.kind then begin
   case contextstack[stacktop].d.constval.kind of
    dk_float: begin
     result:= sdk_flo64;
     with d,constval do begin
      case kind of
       dk_float: begin
        vfloat:= vfloat + contextstack[stacktop].d.constval.vfloat;
       end;
       dk_integer: begin
        vfloat:= vinteger + contextstack[stacktop].d.constval.vfloat;
        kind:= dk_float;
        datatyp:= contextstack[stacktop].d.datatyp;
       end;
       else begin
        result:= sdk_none;
       end;
      end;
     end;
    end;
    dk_integer: begin
     with d,constval do begin
      case kind of
       dk_integer: begin
        vinteger:= vinteger + contextstack[stacktop].d.constval.vinteger;
       end;
       dk_float: begin
        result:= sdk_flo64;
        vfloat:= vfloat + contextstack[stacktop].d.constval.vfloat;
        kind:= dk_float;
        datatyp:= contextstack[stacktop].d.datatyp;
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
   incompatibletypeserror(contextstack[stacktop-2].d,
                                           contextstack[stacktop].d);
  end;
 end;
end;

procedure pushd(const oppo: popinfoty; const address: addressvaluety;
                     const offset: dataoffsty; const size: datasizety);
begin
 with oppo^,address do begin //todo: use table
  if af_segment in flags then begin
   case size of
    1: begin 
     op:= @pushseg8;
    end;
    2: begin
     op:= @pushseg16;
    end;
    4: begin
     op:= @pushseg32;
    end;
    else begin
     op:= @pushseg;
    end;
   end;
   par.vsegaddress.a:= segaddress;
   par.vsegaddress.offset:= offset;
  end
  else begin
   if af_paramindirect in flags then begin
    case size of
     1: begin 
      op:= @pushlocindi8;
     end;
     2: begin
      op:= @pushlocindi16;
     end;
     4: begin
      op:= @pushlocindi32;
     end;
     else begin
      op:= @pushlocindi;
     end;
    end;
   end
   else begin
    case size of
     1: begin 
      op:= @pushloc8;
     end;
     2: begin
      op:= @pushloc16;
     end;
     4: begin
      op:= @pushloc32;
     end;
     else begin
      op:= @pushloc;
     end;
    end;
   end;
   par.locdataaddress.a:= locaddress;
   par.locdataaddress.a.framelevel:= info.sublevel-locaddress.framelevel-1;
   par.locdataaddress.offset:= offset;
  end;
  par.datasize:= size;
 end;
end;

//todo: optimize call
procedure pushdata(const address: addressvaluety; const offset: dataoffsty;
                                          const size: datasizety);
begin
 pushd(additem({info}),address,offset,size);
end;

procedure pushinsertdata(const stackoffset: integer; const before: boolean;
                  const address: addressvaluety; const offset: dataoffsty;
                                                  const size: datasizety);
begin
 pushd(insertitem(stackoffset,before),address,offset,size);
end;

function pushindirection(const stackoffset: integer): boolean;
var
 int1: integer;
begin
 result:= true;
 with info,contextstack[stackindex+stackoffset] do begin;
  if d.indirection <= 0 then begin
   if d.indirection = 0 then begin
    pushinsert(stackoffset,false,d.ref.address,d.ref.offset,true);
   end
   else begin
    pushinsert(stackoffset,false,d.ref.address,0,true);
    for int1:= d.indirection to -2 do begin
     with insertitem(stackoffset,false)^ do begin
      op:= @indirectpo;
     end;
    end;
    with insertitem(stackoffset,false)^ do begin
     op:= @indirectpooffs;
     par.voffset:= d.ref.offset;
    end;
   end;
   d.kind:= ck_fact;
   d.indirection:= 0;
  end
  else begin
   errormessage(err_cannotassigntoaddr,[],stackoffset);
   result:= false;
  end;
 end;
end;

function getvalue(const stackoffset: integer;
                            const retainconst: boolean = false): boolean;

 procedure doindirect();
 var
  po1: ptypedataty;
  si1: datasizety;
  op1: popinfoty;
 begin
  with info,contextstack[stackindex+stackoffset],d do begin
   if datatyp.indirectlevel > 0 then begin
    si1:= pointersize;
   end
   else begin
    si1:= ptypedataty(ele.eledataabs(datatyp.typedata))^.bytesize;
   end;
   op1:= insertitem(stackoffset,false);
   with op1^ do begin //todo: use table
    case si1 of
     1: begin
      op:= @indirect8;
     end;
     2: begin
      op:= @indirect16;
     end;
     4: begin
      op:= @indirect32;
     end;
     else begin
      op:= @indirect;
      par.datasize:= si1;      
     end;
    end;
   end;
  end;
 end;

var
 po1: ptypedataty;
 si1: datasizety;
 op1: popinfoty;
 int1: integer;
 
begin                    //todo: optimize
 result:= false;
 with info,contextstack[stackindex+stackoffset] do begin
  case d.kind of
   ck_ref: begin
    if d.datatyp.indirectlevel < 0 then begin
     errormessage(err_invalidderef,[],stackoffset);
     exit;
    end;
    if d.indirection > 0 then begin //@ operator
     if d.indirection = 1 then begin
      pushinsertaddress(stackoffset,false);
     end
     else begin
      errormessage(err_cannotassigntoaddr,[],stackoffset);
      exit;
     end;
    end
    else begin
     if d.indirection < 0 then begin //dereference
      inc(d.indirection); //correct addr handling
      if not pushindirection(stackoffset) then begin
       exit;
      end;
      doindirect;
     end
     else begin
      if d.datatyp.indirectlevel <= 0 then begin //??? <0 = error?
       po1:= ele.eledataabs(d.datatyp.typedata);
       si1:= po1^.bytesize;
      end
      else begin
       si1:= pointersize;
      end;
      pushinsertdata(stackoffset,false,d.ref.address,d.ref.offset,si1);
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
    pushinsertconst(stackoffset,false);
   end;
   ck_subres,ck_fact: begin
    if d.indirection < 0 then begin
     for int1:= d.indirection+2 to 0 do begin
      with insertitem(stackoffset,false)^ do begin
       op:= @indirectpo;
      end;
     end;
     doindirect();
    end
    else begin
     if d.indirection > 0 then begin
      errormessage(err_cannotaddressexp,[],stackoffset);
      exit;
     end;
    end;
   end;
  {$ifdef mse_checkinternalerror}                             
   else begin
    internalerror(ie_notimplemented,'20140401B');
   end;
  {$endif}
  end;
  d.kind:= ck_fact;
  d.indirection:= 0;
 end;
 result:= true;
end;

function getaddress(const stackoffset: integer;
                                const endaddress: boolean): boolean;
var
 ref1: refvaluety;
 int1: integer;
begin
 result:= false;
 with info,contextstack[stackindex+stackoffset] do begin
 {$ifdef mse_checkinternalerror}                             
  if not (d.kind in datacontexts) then begin
   internalerror(ie_handler,'20140405A');
  end;
 {$endif}
  inc(d.indirection);
  inc(d.datatyp.indirectlevel);
  if d.datatyp.indirectlevel <= 0 then begin
   errormessage(err_cannotassigntoaddr,[]);
   exit;
  end;
  case d.kind of
   ck_ref: begin
    if d.indirection = 1 then begin
     d.indirection:= 0;
     if endaddress then begin
      pushinsert(stackoffset,false,d.ref.address,d.ref.offset,false);
                  //address pointer on stack
      d.kind:= ck_fact;
     end
     else begin
      ref1:= d.ref; //todo: optimize
      d.kind:= ck_const;
      d.constval.kind:= dk_address;
      d.constval.vaddress:= ref1.address;
      d.constval.vaddress.poaddress:= 
                       d.constval.vaddress.poaddress + ref1.offset;
     end;
    end
    else begin
     if not pushindirection(stackoffset) then begin
      exit;
     end;
    end;
   end;
   ck_reffact: begin //
    internalerror1(ie_notimplemented,'20140404B'); //todo
    exit;
//    inc(d.datatyp.indirectlevel);
//    kind:= ck_fact;
   end;
   ck_fact,ck_subres: begin
    if d.indirection <> 0 then begin
     result:= getvalue(stackoffset);
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

procedure init;
var
 ty1: systypety;
 po1: pelementinfoty;
 po2: ptypedataty;
 int1: integer;
begin
 ele.addelement(tks_units,globalvisi,ek_none,unitsele);
 for ty1:= low(systypety) to high(systypety) do begin
  with systypeinfos[ty1] do begin
   po1:= ele.addelement(getident(name),globalvisi,ek_type);
   po2:= @po1^.data;
   po2^:= data;
  end;
  sysdatatypes[ty1].typedata:= ele.eleinforel(po1);
//  sysdatatypes[ty1].flags:= [];
 end;
 for int1:= low(sysconstinfos) to high(sysconstinfos) do begin
  with sysconstinfos[int1] do begin
   po1:= ele.addelement(getident(name),globalvisi,ek_const);
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

procedure updateop(const opinfo: opinfoty);
//todo: don't convert inplace, stack items will be of variable size
var
 kinda,kindb: datakindty;
 po1: pelementinfoty;
 sd1: stackdatakindty;
 op1: opty;
begin
 with info do begin
  if contextstack[stacktop].d.kind <> ck_const then begin
   getvalue(stacktop-stackindex{,false});
  end;
  sd1:= sdk_none;
  po1:= ele.eleinfoabs(contextstack[stacktop].d.datatyp.typedata);
  kinda:= ptypedataty(@po1^.data)^.kind;
  po1:= ele.eleinfoabs(contextstack[stacktop-2].d.datatyp.typedata);
  kindb:= ptypedataty(@po1^.data)^.kind;
  with contextstack[stacktop-2],d do begin
   if d.kind <> ck_const then begin
    getvalue(stacktop-2-stackindex{,true});
   end;
   if (kinda = dk_float) or (kindb = dk_float) then begin
    sd1:= sdk_flo64;
    if kind = ck_const then begin
     with insertitem(stacktop-2-stackindex,false)^ do begin
      op:= @push64;
      case constval.kind of
       dk_integer: begin
        par.imm.vfloat64:= real(constval.vinteger);
       end;
       dk_float: begin
        par.imm.vfloat64:= constval.vfloat;
       end;
       else begin
        sd1:= sdk_none;
       end;
      end;
     end;
    end
    else begin //ck_fact
     case kinda of
      dk_integer: begin
       with insertitem(stacktop-2-stackindex,false)^ do begin
        op:= @stackops.int32toflo64;
        with par.op1 do begin
         index0:= 0;
        end;
       end;
      end;
      dk_float: begin
      end;
      else begin
       sd1:= sdk_none;
      end;
     end;
    end;
    with contextstack[stacktop].d do begin
     if kind = ck_const then begin
      case kinda of
       dk_integer: begin
        push(real(constval.vinteger));
       end;
       dk_float: begin
        push(real(constval.vfloat));
       end;
       else begin
        sd1:= sdk_none;
       end;
      end;
     end
     else begin
      case kinda of
       dk_integer: begin
         int32toflo64({info});
       end;
       dk_float: begin
       end;
       else begin
        sd1:= sdk_none;
       end;
      end;
     end;
    end;
   end
   else begin
    if kinda = dk_boolean then begin
     if kindb = dk_boolean then begin
      sd1:= sdk_bool8;
      if kind = ck_const then begin
       with insertitem(stacktop-2-stackindex,false)^ do begin
        op:= @push8;
        par.imm.vboolean:= constval.vboolean;
       end;
      end;
      with contextstack[stacktop].d do begin
       if kind = ck_const then begin
        push(constval.vboolean);
       end;
      end;
     end;
    end
    else begin
     if (kinda = dk_integer) and (kindb = dk_integer) then begin
      sd1:= sdk_int32;
      if kind = ck_const then begin
       with insertitem(stacktop-2-stackindex,false)^ do begin
        op:= @push32;
        par.imm.vint32:= constval.vinteger;
       end;
      end;
      with contextstack[stacktop].d do begin
       if kind = ck_const then begin
        push(constval.vinteger);
       end;
      end;
     end;
    end;
   end;
   if sd1 = sdk_none then begin
    incompatibletypeserror(contextstack[stacktop-2].d,
                                            contextstack[stacktop].d);
   end
   else begin
    op1:= opinfo.ops[sd1];
    if op1 = nil then begin
     operationnotsupportederror(d,contextstack[stacktop].d,opinfo.opname);
    end
    else begin
//    {$ifdef mse_debugparser}
//     outcommand([-2,0],opinfo.opname);
//    {$endif}
     writeop(op1);
     d.kind:= ck_fact;
     d.indirection:= 0;
     d.datatyp:= sysdatatypes[resultdatatypes[sd1]];
     context:= nil;
    end;
   end;
  end;
  dec(stacktop,2);
  stackindex:= stacktop-1; 
 end;
end;

procedure getordrange(const typedata: ptypedataty; out range: ordrangety);
begin
 with typedata^ do begin
  case kind of
   dk_cardinal: begin
    if datasize <= das_8 then begin
     range.min:= infocard8.min;
     range.max:= infocard8.max;
    end
    else begin
     if datasize <= das_16 then begin
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
    if datasize <= das_8 then begin
     range.min:= infoint8.min;
     range.max:= infoint8.max;
    end
    else begin
     if datasize <= das_16 then begin
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
  with ainfo.datatyp do begin
   po1:= ele.eledataabs(typedata);
   write('T:',typedata,' ',
          getenumname(typeinfo(datakindty),ord(po1^.kind)));
   if po1^.kind <> dk_none then begin
    write(' F:',settostring(ptypeinfo(typeinfo(typeflagsty)),
                  integer(po1^.flags),false),
          ' I:',indirectlevel,':',ainfo.indirection,
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
           getenumname(typeinfo(datakindty),ord(po1^.kind)));
    if po1^.kind <> dk_none then begin
     write(' F:',settostring(ptypeinfo(typeinfo(typeflagsty)),
                  integer(po1^.flags),false),
           ' I:',indirectlevel);
    end;
   end;
  end;
 end;//writetyp

 procedure writetypedata(const adata: ptypedataty);
 begin
   write(getidentname(pelementinfoty(pointer(adata)-eledatashift)^.header.name),
          ':',getenumname(typeinfo(datakindty),ord(adata^.kind)))
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
  with ainfo.ref do begin
   writeaddress(address);
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
  write(text,' T:',stacktop,' I:',stackindex,' O:',opcount,
  ' cont:',currentcontainer);
  if currentcontainer <> 0 then begin
   write(' ',getidentname(ele.eleinfoabs(currentcontainer)^.header.name));
  end;
  write(' ',settostring(ptypeinfo(typeinfo(statementflagsty)),
                         integer(currentstatementflags),true));
  write(' L:'+inttostr(source.line+1)+':''',psubstr(debugsource,source.po)+''','''+
                         singleline(source.po),'''');
  writeln;
  for int1:= 0 to stacktop do begin
   write(fitstring(inttostr(int1),3,sp_right));
   if int1 = stackindex then begin
    write('*');
   end
   else begin
    write(' ');
   end;
   if (int1 < stacktop) and (int1 = contextstack[int1+1].parent) then begin
    write('-');
   end
   else begin
    write(' ');
   end;
   with contextstack[int1],d do begin
    write(fitstring(inttostr(parent),3,sp_right),' ');
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
     write(fitstring(inttostr(opmark.address),3,sp_right));
     write('<',context^.caption,'> ');
    end
    else begin
     write(fitstring(inttostr(opmark.address),3,sp_right));
     write('<NIL> ');
    end;
    write(getenumname(typeinfo(kind),ord(kind)),' ');
    case kind of
     ck_ident: begin
      write('$',hextostr(ident.ident,8),':',ident.len);
      if ident.continued then begin
       write('c ');
      end
      else begin
       write('  ');
      end;
      write(getidentname(ident.ident));
     end;
     ck_getfact: begin
      with getfact do begin
       write('flags:',settostring(ptypeinfo(typeinfo(factflagsty)),
                                           integer(getfact.flags),true));
      end;
     end;
     ck_fact,ck_subres: begin
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
      case constval.kind of
       dk_boolean: begin
        write(constval.vboolean,' ');
       end;
       dk_integer: begin
        write(constval.vinteger,' ');
       end;
       dk_float: begin
        write(constval.vfloat,' ');
       end;
       dk_address: begin
        writeaddress(constval.vaddress);
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
    end;
    writeln(' '+inttostr(start.line+1)+':''',
             psubstr(debugstart,start.po),''',''',singleline(start.po),'''');
   end;
  end;
 end;
end;

{$endif}

end.