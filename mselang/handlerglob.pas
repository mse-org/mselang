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
unit handlerglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob{,elements};

const
 pointersize = sizeof(pointer);
 pointerbitsize = pointersize*8;
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

 infoarrayty = record
  itemtypedata: elementoffsetty;
  itemindirectlevel: integer;
  indextypedata: elementoffsetty;
 end;

 classdefheaderty = record
  fieldsize: integer;
  parentclass: elementoffsetty;
 end;
 classdefinfoty = record
  header: classdefheaderty;
  virtualmethods: record //array of opaddressty
  end;
 end;
 pclassdefinfoty = ^classdefinfoty;

 infoclassflagty = (icf_virtualtablevalid);
 infoclassflagsty = set of infoclassflagty;  
 infoclassty = record
  impl: elementoffsetty;
  defs: dataoffsty; //classdefinfoty in target const
  pendingdescends: listadty;
  allocsize: dataoffsty;
  virtualcount: integer;
  flags: infoclassflagsty;
 end;
 pinfoclassty = ^infoclassty;

 writeiniprocty = procedure (const address: dataoffsty);
 writefiniprocty = procedure (const address: dataoffsty);
 addresskindty = boolean;{(adk_local,adk_global)}

 managedtypeprocty = procedure(const aadress: dataoffsty;
                               const global: boolean; const count: boolean);

 manageddataty = record
  managedele: elementoffsetty;
 end;
 pmanageddataty = ^manageddataty;
  
 typedataty = record
  flags: typeflagsty;
  indirectlevel: indirectlevelty; //total indirection count
  bitsize: integer;
  bytesize: integer;
  datasize: datasizety;
  case kind: datakindty of 
   dk_boolean:(
    dummy: byte
   );
   dk_cardinal:(
    case datasizety of
     das_1,das_2_7,das_8: (infocard8: card8infoty);
     das_9_15,das_16: (infocard16: card16infoty);
     das_17_31,das_32: (infocard32: card32infoty);
     das_33_63,das_64: (infocard64: card64infoty);
   );
   dk_integer:(
    case datasizety of  
     das_1,das_2_7,das_8: (infoint8: int8infoty);
     das_9_15,das_16: (infoint16: int16infoty);
     das_17_31,das_32: (infoint32: int32infoty);
     das_33_63,das_64: (infoint64: int64infoty);
   );
   dk_float:(
    case datasizety of
     das_32:(infofloat32: float32infoty);
     das_64:(infofloat64: float64infoty);
   );
   dk_string8:(
    iniproc: managedtypeprocty;
    finiproc: managedtypeprocty;
    case datakindty of
     dk_string8:(
     );
   );
   dk_record:(
   );
   dk_class:(
    ancestor: elementoffsetty;
    case datakindty of
     dk_class:(
      infoclass: infoclassty;
     );
   );
   dk_array:(
    infoarray: infoarrayty;
   );
 end;
 ptypedataty = ^typedataty;
 
 vardestinfoty = record
  address: addressinfoty;
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
 end;
 vardataty = record
  vf: vfinfoty;           //same layout as fielddataty
  address: addressinfoty; //indirectlevel = total
 end;
 pvardataty = ^vardataty;
 ppvardataty = ^pvardataty;

// vardatapoaty = array[0..0] of pvardataty;
// pvardatapoaty = ^vardatapoaty;

 fielddataty = record
  vf: vfinfoty;           //same layout as vardataty
  offset: dataoffsty;
  flags: varflagsty;
  indirectlevel: integer;
 end;
 pfielddataty = ^fielddataty;

 sysfuncty = (sf_writeln);

 sysfuncdataty = record
  func: sysfuncty;
  sysop: opty;
 end;
 psysfuncdataty = ^sysfuncdataty;

 subdataty = record
  impl: elementoffsetty; //pfuncdataty
  links: linkindexty;
  mark: forwardindexty;
  flags: subflagsty;
  virtualindex: integer; //-1 = none
  address: opaddressty;
  nestinglevel: integer;
  paramsize: integer;
  paramcount: integer;
  paramsrel: record //array of relative pvardataty
  end;
 end;
 psubdataty = ^subdataty;

 unitdataty = record
 end;
 punitdataty = ^unitdataty;
 implementationdataty = record
 end;
 pimplementationdataty = ^implementationdataty;
 
 classimpdataty = record
 end;
 pclassimpdataty = ^classimpdataty;
 
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
 
function gettypesize(const typedata: typedataty): databytesizety; inline;

implementation

function gettypesize(const typedata: typedataty): databytesizety; inline;
begin
 result:= typedata.bytesize;
 if typedata.indirectlevel <> 0 then begin
  result:= pointersize;
 end;
end;

end.