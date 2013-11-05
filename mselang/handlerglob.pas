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

type
 typedataty = record
  size: integer;
  case kind: datakindty of 
   dk_record: ();
 end;

 ptypedataty = ^typedataty;
 varflagty = (vf_global,vf_param);
 varflagsty = set of varflagty;

 constdataty = record
  d: contextdataty;
 end;
 pconstdataty = ^constdataty;

 vardataty = record
  address: ptruint;
  typ: elementoffsetty; //elementdata relative
  flags: varflagsty;
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
