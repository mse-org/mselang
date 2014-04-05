{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
  
 sysfuncinfoty = record
  name: string;
  data: sysfuncdataty;
 end;

 opinfoty = record
  ops: array[stackdatakindty] of opty;
  opname: string;
 end;

var
 sysdatatypes: array[systypety] of typeinfoty;
 resultident: identty;

const
 stackdatakinds: array[datakindty] of stackdatakindty = 
   //dk_none,dk_boolean,dk_cardinal,dk_integer,dk_float,dk_kind,
   (sdk_none,sdk_bool8,sdk_int32,   sdk_int32, sdk_flo64,sdk_none,
  //dk_address,dk_record,dk_string,dk_array
    sdk_none,  sdk_none, sdk_none, sdk_none);
                
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

procedure error({const info: pparseinfoty;} const error: comperrorty;
                   const pos: pchar=nil);
//procedure parsererror(const info: pparseinfoty; const text: string);
//procedure identnotfounderror(const info: contextitemty; const text: string);
//procedure wrongidentkinderror(const info: contextitemty; 
//       wantedtype: elementkindty; const text: string);
procedure outcommand({const info: pparseinfoty;} const items: array of integer;
                     const text: string);
 
function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty; const visibility: vislevelty;
                                    out ainfo: pointer): boolean;
function findkindelements({const info: pparseinfoty;}
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty;
           out lastident: integer; out idents: identvecty): boolean;
function findkindelements({const info: pparseinfoty;}
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty): boolean;
function findkindelementsdata({const info: pparseinfoty;}
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer;
              out lastident: integer; out idents: identvecty): boolean;
function findkindelementsdata({const info: pparseinfoty;}
              const astackoffset: integer; const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer): boolean;

function findvar({const info: pparseinfoty;} const astackoffset: integer; 
        const visibility: vislevelty; out varinfo: vardestinfoty): boolean;

procedure updateop(const opinfo: opinfoty);
function convertconsts(): stackdatakindty;
function getvalue(const stackoffset: integer{; const insert: boolean}): boolean;
function getaddress(const stackoffset: integer): boolean;

procedure push(const avalue: boolean); overload;
procedure push(const avalue: integer); overload;
procedure push(const avalue: real); overload;
procedure push(const avalue: addressinfoty); overload;
procedure push(const avalue: datakindty); overload;
procedure pushconst(const avalue: contextdataty);
procedure pushdata(const address: addressinfoty; const offset: dataoffsty;
                                                   const size: databytesizety);
procedure pushinsert(const stackoffset: integer; const before: boolean;
                                     const avalue: datakindty); overload;
function pushinsertvar(const stackoffset: integer; const before: boolean;
                                     const atype: ptypedataty): integer;
procedure pushinsertdata(const stackoffset: integer; const before: boolean;
                  const address: addressinfoty; const offset: dataoffsty;
                                                  const size: databytesizety);
procedure pushinsertaddress(const stackoffset: integer; const before: boolean);
procedure pushinsertconst(const stackoffset: integer; const before: boolean);

procedure setcurrentloc(const indexoffset: integer);
procedure setcurrentlocbefore(const indexoffset: integer);
procedure setlocbefore(const destindexoffset,sourceindexoffset: integer);
procedure setloc(const destindexoffset,sourceindexoffset: integer);

procedure init();
procedure deinit();
                           
implementation
uses
 errorhandler,typinfo,opcode,stackops,parser;
   
const
 mindouble = -1.7e308;
 maxdouble = 1.7e308; //todo: use exact values
 
  //will be replaced by systypes.mla
 systypeinfos: array[systypety] of systypeinfoty = (
   (name: 'none'; data: (indirectlevel: 0;
       bitsize: 0; bytesize: 0; datasize: das_none; kind: dk_none; dummy: 0)),
   (name: 'bool8'; data: (indirectlevel: 0;
       bitsize: 8; bytesize: 1; datasize: das_8; kind: dk_boolean; dummy: 0)),
   (name: 'int32'; data: (indirectlevel: 0;
       bitsize: 32; bytesize: 4; datasize: das_32;
                 kind: dk_integer; infoint32:(min: minint; max: maxint))),
   (name: 'flo64'; data: (indirectlevel: 0;
       bitsize: 64; bytesize: 8; datasize: das_64;
                 kind: dk_float; infofloat64:(min: mindouble; max: maxdouble))),
   (name: 'string8'; data: (indirectlevel: 0;
       bitsize: pointerbitsize; bytesize: pointersize; datasize: das_pointer;
                 kind: dk_string8; dummy: 0))
  );
 sysconstinfos: array[0..1] of sysconstinfoty = (
   (name: 'false'; ctyp: st_bool8; cval:(kind: dk_boolean; vboolean: false)),
   (name: 'true'; ctyp: st_bool8; cval:(kind: dk_boolean; vboolean: true))
  );
 sysfuncinfos: array[sysfuncty] of sysfuncinfoty = (
   (name: 'writeln'; data: (func: sf_writeln; sysop: @writelnop))
  );
 
procedure error({const info: pparseinfoty;} const error: comperrorty;
                   const pos: pchar=nil);
begin
 outcommand({info,}[],'*ERROR* '+errormessages[error]);
end;

function findkindelementdata(const aident: contextdataty;
              const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer): boolean;
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

function findkindelementdata({const info: pparseinfoty;}
              const astackoffset: integer;
              const akinds: elementkindsty;
              const visibility: vislevelty; out ainfo: pointer): boolean;
begin
 with info do begin
  result:= findkindelementdata(contextstack[stackindex+astackoffset].d,
                                                      akinds,visibility,ainfo);
 end;
end;

function getidents({const info: pparseinfoty;} const astackoffset: integer;
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
   errormessage({info,}err_toomanyidentifierlevels,[],astackoffset+identcount);
   result:= false;
  end;
 end;
end;

function findkindelements({const info: pparseinfoty;}
            const astackoffset: integer; const akinds: elementkindsty; 
            const visibility: vislevelty;
            out aelement: pelementinfoty;
            out lastident: integer; out idents: identvecty): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents({info,}astackoffset,idents) then begin
  with info do begin
   result:= ele.findupward(idents,akinds,visibility,eleres,lastident);
   if not result then begin //todo: use cache
    ele2:= ele.elementparent;
    for int1:= 0 to high(info.unitinfo^.implementationuses) do begin
     ele.elementparent:=
       info.unitinfo^.implementationuses[int1]^.interfaceelement;
     result:= ele.findupward(idents,akinds,visibility,eleres,lastident);
     if result then begin
      break;
     end;
    end;
    if not result then begin
     for int1:= 0 to high(info.unitinfo^.interfaceuses) do begin
      ele.elementparent:=
        info.unitinfo^.interfaceuses[int1]^.interfaceelement;
      result:= ele.findupward(idents,akinds,visibility,eleres,lastident);
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
 end;
end;

function findkindelements({const info: pparseinfoty;}
           const astackoffset: integer; const akinds: elementkindsty; 
           const visibility: vislevelty; out aelement: pelementinfoty): boolean;
var
 eleres,ele1,ele2: elementoffsetty;
 int1: integer;
 idents: identvecty;
 lastident: integer;
begin
 result:= false;
 aelement:= nil;
 if getidents({info,}astackoffset,idents) then begin
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

function findkindelementsdata({const info: pparseinfoty;}
             const astackoffset: integer;
             const akinds: elementkindsty; const visibility: vislevelty; 
             out ainfo: pointer; out lastident: integer;
             out idents: identvecty): boolean;
begin
 result:= findkindelements({info,}astackoffset,akinds,visibility,ainfo,
                                lastident,idents);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

function findkindelementsdata({const info: pparseinfoty;}
             const astackoffset: integer;
             const akinds: elementkindsty; const visibility: vislevelty; 
             out ainfo: pointer): boolean;
begin
 result:= findkindelements({info,}astackoffset,akinds,visibility,ainfo);
 if result then begin
  ainfo:= @pelementinfoty(ainfo)^.data;
 end;
end;

function findvar({const info: pparseinfoty;} const astackoffset: integer; 
                   const visibility: vislevelty;
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
 if getidents({info,}astackoffset,idents) then begin
  result:= ele.findupward(idents,[ek_var],visibility,ele1,int1);
  if result then begin
   po1:= ele.eledataabs(ele1);
   varinfo.address:= po1^.address;
   ele2:= po1^.typ;
   if int1 < idents.high then begin
    for int1:= int1+1 to idents.high do begin //fields
     result:= ele.findchild(ele2,idents.d[int1],[ek_field],visibility,ele2);
     if not result then begin
      identerror({info,}astackoffset+int1,err_identifiernotfound);
      exit;
     end;
     po3:= ele.eledataabs(ele2);
     varinfo.address.address:= varinfo.address.address + po3^.offset;
    end;
    varinfo.typ:= ele.eledataabs(po3^.typ);
   end
   else begin
    po2:= ele.eledataabs(ele2);
    varinfo.typ:= po2;
   end;
  end
  else begin
   identerror({info,}astackoffset,err_identifiernotfound);
  end;
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
procedure outcommand({const info: pparseinfoty;} const items: array of integer;
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

function pushinsertvar(const stackoffset: integer; const before: boolean;
                                       const atype: ptypedataty): integer;
begin
 with insertitem(stackoffset,before)^ do begin
  op:= @pushop;
  result:= atype^.bytesize; //todo: alignment
  d.d.vsize:= result;
 end;
end;

procedure pushinsertaddress(const stackoffset: integer; const before: boolean);
begin
 with insertitem(stackoffset,before)^,info,
                     contextstack[stackindex+stackoffset].d.ref do begin
  if vf_global in address.flags then begin
   op:= @pushglobaddr;
   d.vaddress:= address.address + offset;
  end
  else begin
   op:= @pushlocaddr;
   d.vlocaddress.offset:= address.address + offset;
   d.vlocaddress.linkcount:= info.funclevel-address.framelevel-1;
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
    d.d.vboolean:= po1^.d.constval.vboolean;
   end;
   dk_integer: begin
    op:= @push32;
    d.d.vinteger:= po1^.d.constval.vinteger;
   end;
   dk_float: begin
    op:= @push64;
    d.d.vfloat:= po1^.d.constval.vfloat;
   end;
   dk_string8: begin
    op:= @pushconstaddress;
    d.vaddress:= stringconst(po1^.d.constval.vstring);
   end;
   else begin
    internalerror('H20131121A');
   end;
  end;
 end;
end;

procedure push(const avalue: boolean); overload;
begin
 with additem({info})^ do begin
  op:= @push8;
  d.d.vboolean:= avalue;
 end;
end;

procedure push(const avalue: integer); overload;
begin
 with additem({info})^ do begin
  op:= @push32;
  d.d.vinteger:= avalue;
 end;
end;

procedure push(const avalue: real); overload;
begin
 with additem({info})^ do begin
  op:= @push64;
  d.d.vfloat:= avalue;
 end;
end;

procedure push(const avalue: addressinfoty); overload;
begin
 with additem({info})^ do begin
  if vf_global in avalue.flags then begin
   op:= @pushglobaddr;
   d.vaddress:= avalue.address;
  end
  else begin
   op:= @pushlocaddr;
   d.vlocaddress.offset:= avalue.address;
   d.vlocaddress.linkcount:= info.funclevel-avalue.framelevel-1;
  end;
 end;
end;

procedure push(const avalue: datakindty); overload;
      //no alignsize
begin
 with additem({info})^ do begin
  op:= @pushdatakind;
  d.vdatakind:= avalue;
 end;
end;

procedure pushinsert(const stackoffset: integer; const before: boolean;
                                    const avalue: datakindty); overload;
      //no alignsize
begin
 with insertitem(stackoffset,before)^ do begin
  op:= @pushdatakind;
  d.vdatakind:= avalue;
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
    push(constval.vaddress);
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
  ops[contextstack[stackindex+indexoffset].opmark.address].d.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setcurrentlocbefore(const indexoffset: integer);
begin 
 with info do begin
  ops[contextstack[stackindex+indexoffset].opmark.address-1].d.opaddress:=
                                                                     opcount-1;
 end; 
end;

procedure setlocbefore(const destindexoffset,sourceindexoffset: integer);
begin
 with info do begin
  ops[contextstack[stackindex+destindexoffset].opmark.address-1].
                                                               d.opaddress:=
         contextstack[stackindex+sourceindexoffset].opmark.address-1;
 end; 
end;

procedure setloc(const destindexoffset,sourceindexoffset: integer);
begin
 with info do begin
  ops[contextstack[stackindex+destindexoffset].opmark.address].
                                                               d.opaddress:=
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

procedure pushd({const info: pparseinfoty;}
                     const oppo: popinfoty; const address: addressinfoty;
                     const offset: dataoffsty; const size: databytesizety);
begin
 with oppo^,address do begin //todo: use table
  if vf_global in flags then begin
   case size of
    1: begin 
     op:= @pushglob8;
    end;
    2: begin
     op:= @pushglob16;
    end;
    4: begin
     op:= @pushglob32;
    end;
    else begin
     op:= @pushglob;
    end;
   end;
   d.dataaddress:= address+offset;
  end
  else begin
   if vf_paramindirect in flags then begin
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
   d.locdataaddress.offset:= address + offset;
   d.locdataaddress.linkcount:= info.funclevel-framelevel-1;
  end;
  d.datasize:= size;
 end;
end;

//todo: optimize call
procedure pushdata(const address: addressinfoty; const offset: dataoffsty;
                                          const size: databytesizety);
begin
 pushd(additem({info}),address,offset,size);
end;

procedure pushinsertdata(const stackoffset: integer; const before: boolean;
                  const address: addressinfoty; const offset: dataoffsty;
                                                  const size: databytesizety);
begin
 pushd(insertitem(stackoffset,before),address,offset,size);
end;

function getvalue(const stackoffset: integer{; const insert: boolean}): boolean;

 procedure doindirect();
 var
  po1: ptypedataty;
  si1: databytesizety;
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
      d.datasize:= si1;      
     end;
    end;
   end;
  end;
 end;

var
 po1: ptypedataty;
 si1: databytesizety;
 op1: popinfoty;
 int1: integer;
 
begin                    //todo: optimize
 result:= false;
 with info,contextstack[stackindex+stackoffset],d do begin
  case kind of
   ck_ref: begin
    if datatyp.indirectlevel < 0 then begin
     errormessage(err_invalidderef,[],stackoffset);
     exit;
    end;
    inc(ref.address.address,ref.offset);
    ref.offset:= 0;
    if indirection > 0 then begin //@ operator
     if indirection = 1 then begin
     pushinsertaddress(stackoffset,false);
     end
     else begin
      errormessage(err_cannotassigntoaddr,[],stackoffset);
      exit;
     end;
    end
    else begin
     if indirection < 0 then begin //dereference
      pushinsertdata(stackoffset,false,ref.address,ref.offset,pointersize);
      for int1:= indirection to -2 do begin
       op1:= insertitem(stackoffset,false);
       with op1^ do begin
        op:= @indirectpo;
       end;
      end;
      doindirect;
     end
     else begin
      if datatyp.indirectlevel <= 0 then begin //??? <0 = error?
       po1:= ele.eledataabs(datatyp.typedata);
       si1:= po1^.bytesize;
      end
      else begin
       si1:= pointersize;
      end;
      pushinsertdata(stackoffset,false,ref.address,ref.offset,si1);
     end;
    end;
   end;
   ck_reffact: begin
    doindirect();
   end;
   ck_const: begin
    pushinsertconst(stackoffset,false);
   end;
   ck_subres: begin
    kind:= ck_fact;
   end;
   ck_fact: begin
   end;
   else begin
    internalerror('B20140401B');
   end;
  end;
  kind:= ck_fact;
  indirection:= 0;
 end;
 result:= true;
end;

function getaddress(const stackoffset: integer): boolean;
var
 ref1: refinfoty;
begin
 result:= false;
 with info,contextstack[stackindex+stackoffset] do begin
  if not (d.kind in datacontexts) then begin
   internalerror('H20140405A');
   exit;
  end;
  inc(d.indirection);
  inc(d.datatyp.indirectlevel);
  if d.datatyp.indirectlevel <= 0 then begin
   errormessage(err_cannotassigntoaddr,[]);
   exit;
  end;
  case d.kind of
   ck_ref: begin
    if d.indirection = 1 then begin
     ref1:= d.ref; //todo: optimize
     d.kind:= ck_const;
     d.indirection:= 0;
     d.constval.kind:= dk_address;
     d.constval.vaddress:= ref1.address;
     d.constval.vaddress.address:= d.constval.vaddress.address + ref1.offset;
    end
    else begin
     if d.indirection <= 0 then begin
      result:= getvalue(stackoffset);
     end
     else begin
      errormessage(err_cannotassigntoaddr,[],stackoffset);
      exit;
     end;
    end;
   end;
   ck_reffact: begin //
    internalerror('N20140404B'); //todo
    exit;
//    inc(d.datatyp.indirectlevel);
//    kind:= ck_fact;
   end;
   ck_fact,ck_subres: begin
    if d.indirection <> 0 then begin
     result:= getvalue(stackoffset);
    end;
   end;
   else begin
    internalerror('H20140401A');
    exit;
   end;
  end;
 end;
 result:= true;
end;

procedure init;
var
 ty1: systypety;
 sf1: sysfuncty;
 po1: pelementinfoty;
 po2: ptypedataty;
 int1: integer;
begin
 for ty1:= low(systypety) to high(systypety) do begin
  with systypeinfos[ty1] do begin
   po1:= ele.addelement(getident(name),vis_max,ek_type);
   po2:= @po1^.data;
   po2^:= data;
  end;
  sysdatatypes[ty1].typedata:= ele.eleinforel(po1);
//  sysdatatypes[ty1].flags:= [];
 end;
 for int1:= low(sysconstinfos) to high(sysconstinfos) do begin
  with sysconstinfos[int1] do begin
   po1:= ele.addelement(getident(name),vis_max,ek_const);
   with pconstdataty(@po1^.data)^ do begin
    val.d:= cval;
    val.typ:= sysdatatypes[ctyp];
   end;
  end;
 end;
 for sf1:= low(sysfuncty) to high(sysfuncty) do begin
  with sysfuncinfos[sf1] do begin
   po1:= ele.addelement(getident(name),vis_max,ek_sysfunc);
   psysfuncdataty(@po1^.data)^:= data;
  end;
 end;
 resultident:= getident('result');
end;

procedure deinit;
begin
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
//  opshift:= 0;
outinfo('****');
  if contextstack[stacktop].d.kind <> ck_const then begin
   getvalue(stacktop-stackindex{,false});
  end;
outinfo('****');
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
        d.d.vfloat:= real(constval.vinteger);
       end;
       dk_float: begin
        d.d.vfloat:= constval.vfloat;
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
        with d.op1 do begin
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
        d.d.vboolean:= constval.vboolean;
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
        d.d.vinteger:= constval.vinteger;
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
    {$ifdef mse_debugparser}
     outcommand([-2,0],opinfo.opname);
    {$endif}
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

end.