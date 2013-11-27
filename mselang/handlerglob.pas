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
unit handlerglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;

const
 pointersize = sizeof(pointer);
type  
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
 
 typedataty = record
  indirectlevel: indirectlevelty; //total indirection count
  bitsize: integer;
  bytesize: integer;
  datasize: datasizety;
//  flags: typeflagsty;
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
   dk_record: ();
  {
   dk_reference:(
    target: elementoffsetty;        //not indirected root type
     indirectlevel: indirectlevelty; //total indirection count
   );
  }
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

 vardataty = record
  address: addressinfoty;
  typ: elementoffsetty; //elementdata relative
 end;
 pvardataty = ^vardataty;
 ppvardataty = ^pvardataty;

 fielddataty = record
  offset: ptruint;
  typ: elementoffsetty; //elementdata relative
  flags: varflagsty;
 end;
 pfielddataty = ^fielddataty;

 sysfuncty = (sf_writeln);

 sysfuncdataty = record
  func: sysfuncty;
  op: opty;
 end;
 psysfuncdataty = ^sysfuncdataty;

 funcdataty = record
  address: opaddressty;
  paramcount: integer;
  paramsrel: record //array of relative pvardataty
  end;
 end;
 pfuncdataty = ^funcdataty;

 unitdataty = record
 end;
 punitdataty = ^unitdataty;

 classdataty = record
 end;
 pclassdataty = ^classdataty;

 classesdataty = record
  scopebefore: elementoffsetty;
 end;
 pclassesdataty = ^classesdataty;
 
 implementationdataty = record
 end;
 pimplementationdataty = ^implementationdataty;

 visibledataty = record
 end;
 pvisibledataty = ^visibledataty;
 

implementation
end.