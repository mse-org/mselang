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
unit rttihandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,parserglob,handlerglob;
 
function getrtti(const atype: ptypedataty): dataaddressty;
{
procedure init();
procedure deinit();
}
implementation
uses
 errorhandler,elements,msestrings,{msertti,}opcode,segmentutils,identutils,
 __mla__internaltypes,handlerutils,unithandler,llvmbitcodes;

//var
// rttibuffer: pointer;
// rttibufferindex: integer;
// rttibuffersize: integer;

procedure checkbuffer(step: integer); inline;
begin
 checksegmentcapacity(seg_rtti,step);
{
 inc(rttibufferindex,step);
 if rttibufferindex > rttibuffersize then begin
  rttibuffersize:= 2*rttibufferindex;
  reallocmem(rttibuffer,rttibuffersize);
 end;
}
end;

procedure checkbuffer(step: integer; var abuffer: pointer); 
                                 {$ifndef mse_debugparser}inline;{$endif}
//var
// po1: pointer;
begin
 checksegmentcapacity(seg_rtti,step,abuffer);
{
 inc(rttibufferindex,step);
 if rttibufferindex > rttibuffersize then begin
  rttibuffersize:= 2*rttibufferindex;
  po1:= rttibuffer;
  reallocmem(rttibuffer,rttibuffersize);
  abuffer:= abuffer+(rttibuffer-po1); //realloc
 end;
}
end;

function allocrttibuffer(const akind: rttikindty; 
                                         const asize: integer): pointer;
var
 po1: ^rttity;
begin
 po1:= allocsegmentpo(seg_rtti,asize);
 po1^.size:= asize;
 po1^.kind:= akind;
 result:= po1;
end;

procedure addname(const aname: identty; var abuffer: pointer);
var
 s1: lstringty;
// int1: integer;
 po1: pbyte;
begin
 if getidentname(aname,s1) then begin
  if s1.len > 255 then begin
   identerror(aname,err_identtoolong);
  end;
  po1:= allocsegmentpo(seg_rtti,s1.len+1,abuffer);
//  int1:= rttibufferindex;
//  checkbuffer(s1.len+1,abuffer);
//  po1:= rttibuffer+int1;
  po1^:= s1.len;
  move(s1.po^,(po1+1)^,s1.len);
 end
 else begin
  internalerror1(ie_rtti,'20140605C');
 end;
end;

function rttiname(const aident: identty): string8;
begin
 result:= allocstringconst(getidentname3(aident)).address;
 if co_llvm in info.o.compileoptions then begin
  internalerror1(ie_rtti,'20171107C');
 end;
end;

function getrttistackops(const atype: ptypedataty): dataaddressty;
var
 po1: ^enumrttity;
 po2: ptypedataty;
 po3: ^enumitemrttity;
 ele1: elementoffsetty;
 int1,int2: integer;
begin
 result:= atype^.h.rtti;
 if result = 0 then begin
  case atype^.h.kind of 
   dk_enum: begin
    int2:= sizeof(enumrttity)+atype^.infoenum.itemcount*sizeof(enumitemrttity);
    po1:= allocrttibuffer(rtk_enum,int2);
    result:= getsegmentoffset(seg_rtti,po1);
    po1^.itemcount:= atype^.infoenum.itemcount;
    po1^.min:= atype^.infoenum.min;
    po1^.max:= atype^.infoenum.max;
    po1^.flags:= [];
    if enf_contiguous in atype^.infoenum.flags then begin
     include(po1^.flags,erf_contiguous);
    end;
    if enf_ascending in atype^.infoenum.flags then begin
     include(po1^.flags,erf_ascending);
    end;
    po3:= @po1^.items;
    ele1:= atype^.infoenum.first;
    for int1:= 0 to atype^.infoenum.itemcount-1 do begin
     po2:= ele.eledataabs(ele1);
     po3^.value:= po2^.infoenumitem.value;
     po3^.name:= rttiname(datatoele(po2)^.header.name);
//     po3^.name:= getsegmenttop(seg_rtti)-pointer(po3);
//     addname(pelementinfoty(pointer(po2)-eledatashift)^.header.name,po2);
     inc(po3);
     ele1:= po2^.infoenumitem.next;
    end;
//    alignsegment(seg_rtti);
   end;
   else begin
  {$ifdef mse_checkinternalerror}
    internalerror(ie_notimplemented,'20140605A');
  {$endif}
   end;
  end;
//  result:= getglobconstaddress(rttibufferindex);
//  move(rttibuffer^,info.constseg[result],rttibufferindex);
 end;
end;

function getrtti(const atype: ptypedataty): dataaddressty;
var
 i1: int32;
 p1: pelementinfoty;
begin
 result:= atype^.h.rtti;
 if result = 0 then begin
  if co_llvm in info.o.compileoptions then begin
   result:= info.s.unitinfo^.llvmlists.globlist.addrtticonst(atype).listid;
//   atype^.h.rttinameid:= getunitnameid();
  end
  else begin
   result:= getrttistackops(atype);
   atype^.h.rtti:= result;
  end;
 end
 else begin
  p1:= datatoele(atype);
  if llvmlink(p1^.header.defunit,atype^.h.llvmrttivar,i1) then begin
   with info.s.unitinfo^.llvmlists do begin
    if i1 < 0 then begin
     i1:= globlist.addexternalvalue(
                  p1,atype^.h.rttinameid,ord(das_pointer),li_external);
    end;
    result:= constlist.addpointercast(i1).listid;
   end;
  end;
 end;
end;

{
procedure init();
begin
// rttibufferindex:= 0;
// rttibuffersize:= defaultrttibuffersize;
// rttibuffer:= getmem(rttibuffersize);
end;

procedure deinit();
begin
// freemem(rttibuffer);
end;
}
end.
