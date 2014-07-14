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
unit opglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob;
 
type
 opty = procedure;

 op1infoty = record
  index0: integer;
 end;

 opninfoty = record
  paramcount: integer;
 end;

 opkindty = (ok_none,ok_startup,ok_imm,ok_immgoto,
             ok_push8,ok_push16,ok_push32,ok_push64,
             ok_pushdatakind,
             ok_pushglobaddress,ok_pushlocaddress,
             ok_pushglobaddressindi,ok_pushlocaddressindi,
             ok_pushstackaddress,ok_indirectpooffs,
             ok_pushconstaddress,
             ok_offset,ok_offsetaddress,ok_segment,
             ok_locop,ok_segop,ok_poop,
             ok_op,ok_op1,ok_opn,ok_opaddress,ok_params,
             ok_call,ok_virtcall,ok_intfcall,ok_virttrampoline,
             ok_stack,ok_initclass,ok_destroyclass,
             ok_managed);

 v8ty = array[0..0] of byte;
 pv8ty = ^v8ty;
 ppv8ty = ^pv8ty;
 v16ty = array[0..1] of byte;
 pv16ty = ^v16ty;
 ppv16ty = ^pv16ty;
 v32ty = array[0..3] of byte;
 pv32ty = ^v32ty;
 ppv32ty = ^pv32ty;
 v64ty = array[0..7] of byte;
 pv64ty = ^v64ty;
 ppv64ty = ^pv64ty;

   //todo: simplify nested procedure link handling

 callinfoty = record
  ad: opaddressty;    //first!
  linkcount: integer; //used in "for downto 0"
 end; 

 virtcallinfoty = record
  selfinstance: dataoffsty; //stackoffset
  virtoffset: dataoffsty;   //offset in classdefinfoty
 end;

 virttrampolineinfoty = record
  selfinstance: dataoffsty; //frameoffset
  virtoffset: dataoffsty;   //offset in classdefinfoty
 end;

 intfcallinfoty = record
  selfinstance: dataoffsty; 
    //stackoffset, points to interface item in obj instance.
  subindex: integer;   //sub item in interface list
 end;
  
 initclassinfoty = record
  selfinstance: dataoffsty; //stackoffset
//  classdef: dataoffsty;
  result: dataoffsty;   //stackoffset to result pointer
 end;

 destroyclassinfoty = record
  selfinstance: dataoffsty; //stackoffset
 end;

 destroyclassinfo = record
 end;
 
 immty = record
  case integer of               //todo: use target size
   1: (vboolean: boolean);
   2: (vcard32: card32);
   3: (vint32: int32);
   4: (vint64: int64);
   5: (vfloat64: float64);
   6: (vsize: ptrint);
   7: (vpointer: ptruint);
   8: (voffset: ptrint);
 end;  

 ordimmty = record
  case integer of
   1: (vboolean: boolean);
   2: (vcard32: card32);
   3: (vint32: int32);
 end;

 segdataaddressty = record
  a: segaddressty;
  offset: dataoffsty;
 end;
   
 locdataaddressty = record
  a: locaddressty;
  offset: dataoffsty;
 end;
  
 opparamty = record
  case opkindty of 
   ok_none: (
    dummy: record
    end;
   );
   ok_imm: (
    imm: immty;
   );
   ok_immgoto: (
    ordimm: ordimmty;
    immgoto: opaddressty
   );
   ok_segment:(
    vsegment: segmentty;
   );
   ok_push8:(
    v8: v8ty;
   );
   ok_push16:(
    v16: v16ty;
   );
   ok_push32:(
    v32: v32ty;
   );
   ok_push64:(
    v64: v64ty;
   );
   ok_pushdatakind:(
    vdatakind: datakindty;
   );
   ok_pushconstaddress,ok_managed:(
    vaddress: dataaddressty;
   );
   ok_pushglobaddress,ok_pushglobaddressindi:(
    vsegaddress: segdataaddressty;
//    vglobaddress: dataaddressty;
 //   vglobadoffs: dataoffsty;
   );
   ok_pushlocaddress,ok_pushlocaddressindi:(
    vlocaddress: locdataaddressty;
//    vlocadoffs: dataoffsty;
   );
   ok_pushstackaddress,ok_indirectpooffs,ok_offset,ok_offsetaddress:(
    voffset: dataoffsty;
    case opkindty of
     ok_offsetaddress:(
      voffsaddress: dataaddressty;
     );
   );
   ok_locop,ok_segop,ok_poop:(
    datasize: datasizety;
    case opkindty of
     ok_locop:(
      locdataaddress: locdataaddressty;
     );
     ok_segop:(
      segdataaddress: segdataaddressty;
     );
     ok_poop:(
      podataaddress: dataaddressty;
     );
   );
   ok_op1:(
    op1: op1infoty;
   );
   ok_opn:(
    opn: opninfoty;
   );
   ok_opaddress:(
    opaddress: opaddressty; //first!
   );
   ok_params:(
    paramsize: datasizety;
    paramcount: integer;
   );
   ok_call:(
    callinfo: callinfoty;
   );
   ok_virtcall:(
    virtcallinfo: virtcallinfoty;
   );
   ok_virttrampoline:(
    virttrampolineinfo: virttrampolineinfoty;
   );
   ok_intfcall:(
    intfcallinfo: intfcallinfoty;
   );
   ok_stack:(
    stacksize: datasizety;
   );
   ok_initclass:(
    initclass: initclassinfoty;
   );
   ok_destroyclass:(
    destroyclass: destroyclassinfoty;
   );
  end;

 opinfoty = record
//todo: variable item size, immediate data
  op: opty;
  par: opparamty;
 end;
 popinfoty = ^opinfoty;

 startupdataty = record
  globdatasize: ptruint;
//  startaddress: opaddressty;
 end;
 pstartupdataty = ^startupdataty;

const
 startupoffset = (sizeof(startupdataty)+sizeof(opinfoty)-1) div 
                                                         sizeof(opinfoty);

implementation
end.
