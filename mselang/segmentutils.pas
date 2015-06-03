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
unit segmentutils;
{$ifdef FPC}{$mode objfpc}{$goto on}{$h+}{$endif}
interface
uses
 globtypes,opglob,msetypes,classes,mclasses;
type
 segmentinfoty = record
  data: pointer;
  toppo: pointer;
  endpo: pointer;
 end;
 segmentstatety = record
  segment: segmentty;
  state: segmentinfoty;
 end;
 subsegmentty = record
  segment: segmentty;
  start: int32;
  size: int32;
 end;
  
  //todo: use inline
const
 mlasignature = ord('M') or (ord('L') shl 8) or (ord('A') shl 16) or
                                                          (ord('0') shl 24);
 mlafileversion = 0;
 
 minsegmentreserve = 32; //at least free bytes at buffer end  

function allocsegment(const asegment: segmentty;
                                    asize: integer): segaddressty;
function allocsegmentoffset(const asegment: segmentty;
                                    asize: integer): dataoffsty;
function allocsegmentpo(const asegment: segmentty;
                                    asize: integer): pointer;
function allocsegmentpounaligned(const asegment: segmentty;
                                                const asize: integer): pointer;
function allocsegmentpo(const asegment: segmentty;
                                 asize: integer; var buffer: pointer): pointer;
procedure checksegmentcapacity(const asegment: segmentty;
                               asize: integer; var buffer: pointer);
function checksegmentcapacity(const asegment: segmentty;
                                asize: integer): pointer;
                                 //returns alloc top

procedure setsegmenttop(const asegment: segmentty; const atop: pointer);
procedure resetsegment(const asegment: segmentty);
function getsubsegment(const asegment: segmentty): subsegmentty;
function setsubsegment(const asubseg: subsegmentty): segmentstatety;
                                //returns old state, do not change size
procedure setsubsegmentsize(var asubseg: subsegmentty);

procedure setsegment(const aseg: segmentstatety);

function getsegmentoffset(const asegment: segmentty;
                                    const apo: pointer): dataoffsty;

function getsegmentpo(const asegment: segmentty;
                                    const aoffset: dataoffsty): pointer;
function getsegmentpo(const aaddress: segaddressty): pointer;
function getsegaddress(const asegment: segmentty;
                             const aaddress: dataoffsty): segaddressty;
function getsegaddress(const asegment: segmentty;
                             const aref: pointer): segaddressty;

function getsegmenttoppo(const asegment: segmentty): pointer;
function getsegmenttopoffs(const asegment: segmentty): dataoffsty;
function getsegmentbase(const asegment: segmentty): pointer;
function getsegmentsize(const asegment: segmentty): integer;

function getoppo(const opindex: integer): popinfoty;
                               
procedure init();
procedure deinit();

procedure writesegmentdata(const adest: tstream; 
                const astoredsegments: segmentsty; const atimestamp: tdatetime);
function readsegmentdata(const asource: tstream;
                                  const astoredsegments: segmentsty): boolean;
                     //true if ok
function checksegmentdata(const asource: tstream;
                                  const atimestamp: tdatetime): boolean;

implementation
uses
 errorhandler,stackops,mseformatstr,msesystypes,msestream,msestrings,parserglob;
 
const
 minsize: array[segmentty] of integer = (
//seg_nil,seg_stack,seg_globvar,seg_globconst,seg_op,seg_classinfo,seg_rtti,
  0,      0,        0,          1024,         1024,  1024,         1024,
//seg_intf,seg_paralloc,seg_classintfcount,seg_intfitemcount,
  1024,    1024,        1024,              1024,             
//seg_unitintf,seg_unitidents
  1024,        1024);          
  
var
 segments: array[segmentty] of segmentinfoty;

type
 segmentflagty = (shf_load);
 segmentflagsty = set of segmentflagty;
 
 segmentitemty = record
  kind: segmentty;
  flags: segmentflagsty;
  size: int32;
 end;
 
 segmentfileheaderty = record
  signature: card32;
  version: int32;
  segmentcount: int32;
  reftimestamp: tdatetime;
 end;
 
 segmentfileinfoty = record
  header: segmentfileheaderty;
  data: record
   //array [segmencount] of segmentitemty;
   //segmentdata
  end;
//  case integer of
//   0: (items: array [segmentty] of segmentitemty);
 end;
  
procedure writesegmentdata(const adest: tstream; 
                           const astoredsegments: segmentsty;
                           const atimestamp: tdatetime);

 function writedata(const adata; const alen: int32): boolean;
 var
  i1: int32;
 begin
  result:= checksysok(adest.write(adata,alen,i1),err_cannotwritetargetfile,[]);
 end; //writedata
 
var
 info1: segmentfileinfoty;
 segitems: array[segmentty] of segmentitemty;
 seg1: segmentty;
 i1: integer;
begin
 fillchar(info1,sizeof(info1),0);
 with info1.header do begin
  signature:= mlasignature;
  version:= mlafileversion;
  reftimestamp:= atimestamp;
  i1:= 0;
  for seg1:= low(segmentsty) to high(segmentsty) do begin
   if seg1 in astoredsegments then begin
    with segitems[segmentty(i1)] do begin
     kind:= seg1;
     flags:= [shf_load];
     with segments[seg1] do begin
      size:= toppo - data;
     end;
    end;
    inc(i1);
   end;
  end;
  segmentcount:= i1;
 end;
 if writedata(info1,sizeof(info1)) and 
      writedata(segitems,
                  info1.header.segmentcount*sizeof(segmentitemty)) then begin
  for seg1:= low(segmentsty) to high(segmentsty) do begin
   if seg1 in astoredsegments then begin
    with segments[seg1] do begin
     if not writedata(data^,toppo-data) then begin
      break;
     end;
    end;
   end;
{
   with info1.items[seg1] do begin
    if shf_load in flags then begin
     if not checksysok(dest.write(segments[seg1].data^,size,int1),
                                    err_cannotwritetargetfile,[]) then begin
      break;
     end;
    end;
   end;
}
  end;  
 end;
end;

function checksegmentdata(const asource: tstream;
                                  const atimestamp: tdatetime): boolean;
var
 header1: segmentfileheaderty;
 posbefore: int64;
begin
 result:= false;
 posbefore:= asource.position;
 if asource.tryreadbuffer(header1,sizeof(header1)) = sye_ok then begin
  with header1 do begin
   result:= (signature = mlasignature) and (version = mlafileversion) and 
                                                  (reftimestamp = atimestamp);
  end;
 end;
 asource.position:= posbefore;
end;

function readsegmentdata(const asource: tstream; 
                        const astoredsegments: segmentsty): boolean;
var
 fna1: filenamety;
 
 function readdata(out adata; const alen: int32): boolean;
 var
  i1: int32;
 begin
  result:= checksysok(asource.read(adata,alen,i1),err_fileread,[fna1],erl_note)
 end; //readdata

 function skipdata(const alen: int32): boolean;
 var
  i1: int64;
 begin
  result:= checksysok(asource.seek(int64(alen),socurrent,i1),
                                              err_fileread,[fna1],erl_note);
 end; //skipdata
 
var
 info1: segmentfileinfoty;
 segitems: array[segmentty] of segmentitemty;
 seg1: segmentty;
 i1: integer;
 segs1: segmentsty;
begin
 result:= false;
 if asource is tmsefilestream then begin
  fna1:= tmsefilestream(asource).filename;
 end
 else begin
  fna1:= '<none>';
 end;
 if readdata(info1,sizeof(info1)) then begin
  with info1.header do begin
   if signature <> mlasignature then begin
    errormessage1(err_wrongsignature,[]);
   end
   else begin
    if version <> mlafileversion then begin
     errormessage1(err_wrongversion,[inttostrmse(version),
                                        inttostrmse(mlafileversion)]);
    end
    else begin
     if (segmentcount <= ord(high(segmentty))+1) and 
           readdata(segitems,segmentcount*sizeof(segmentitemty))then begin
      segs1:= [];
      result:= true;
      for i1:= 0 to segmentcount-1 do begin
       with segitems[segmentty(i1)] do begin
        if (kind in segs1) {or not (kind in storedsegments)} then begin
         result:= false;
         break;
        end;         
        if kind in astoredsegments then begin
         if not readdata(allocsegmentpo(kind,size)^,size) then begin
          result:= false;
          exit;
         end;
         include(segs1,kind);
        end
        else begin
         if not skipdata(size) then begin
          result:= false;
          exit;
         end;
        end;
       end;
      end;
      result:= result and (segs1 = astoredsegments);
      if not result then begin
       errormessage1(err_invalidprogram,[]);
      end;
     end;
    end;
   end;
  end;
 end;
{    
  if info1.header.version <> 0 then begin
   errormessage1(err_wrongversion,[inttostrmse(info1.header.version),'0']);
  end
  else begin
   segs1:= [];
   for seg1:= low(segmentty) to high(segmentty) do begin
    with info1.items[seg1] do begin
     if shf_load in flags then begin
      if seg1 in segs1 then begin
       errormessage1(err_invalidprogram,[]);
       goto endlab;
      end;
      include(segs1,seg1);
      if not checksysok(source.read(allocsegmentpo(seg1,size)^,size,int1),
                                                 err_fileread,[]) then begin
       goto endlab;
      end;
     end;
    end;
   end;
   if (segs1 * storedsegments <> storedsegments) or 
                       (segs1 - storedsegments <> []) then begin
    errormessage1(err_invalidprogram,[]);
    goto endlab;
   end;
   result:= true;
  end;
}
end;

procedure grow(const asegment: segmentty; var ref: pointer);
var
 po1: pointer;
 int1: integer;
begin
 with segments[asegment] do begin
  int1:= (toppo-data)*2 + minsize[asegment];
  po1:= data;
  reallocmem(data,int1+minsegmentreserve);
  endpo:= data + int1;
  toppo:= toppo + (data - po1);
  ref:= ref + (data - po1);
 end;
end;

procedure grow(const asegment: segmentty);
var
 po1: pointer;
begin
 grow(asegment,po1);
end;

procedure sizealign(var asize: integer); {$ifdef mse_inline}inline;{$endif}
begin
 asize:= (asize+alignstep-1) and alignmask;
end;

function allocsegment(const asegment: segmentty;
                                    asize: integer): segaddressty;
begin
 with segments[asegment] do begin
  result.segment:= asegment;
  result.address:= toppo-pointer(data);
  sizealign(asize);
  inc(toppo,asize);
  if toppo > endpo then begin
   grow(asegment);
  end;
 end;
end;

function allocsegmentoffset(const asegment: segmentty;
                                    asize: integer): dataoffsty;
begin
 with segments[asegment] do begin
  result:= toppo-pointer(data);
  sizealign(asize);
  inc(toppo,asize);
  if toppo > endpo then begin
   grow(asegment);
  end;
 end;
end;

function allocsegmentpo(const asegment: segmentty;
                                    asize: integer): pointer;
begin
 with segments[asegment] do begin
  result:= toppo;
  sizealign(asize);
  inc(toppo,asize);
  if toppo > endpo then begin
   grow(asegment,result);
  end;
 end;
end;

function allocsegmentpounaligned(const asegment: segmentty;
                                                const asize: integer): pointer;
begin
 with segments[asegment] do begin
  result:= toppo;
  inc(toppo,asize);
  if toppo > endpo then begin
   grow(asegment,result);
  end;
 end;
end;

function allocsegmentpo(const asegment: segmentty;
                          asize: integer; var buffer: pointer): pointer;
var
 po1: pointer;
begin
 with segments[asegment] do begin
  result:= toppo;
  sizealign(asize);
  inc(toppo,asize);
  if toppo > endpo then begin
   po1:= result;
   grow(asegment,result);
   buffer:= buffer + (result-po1);
  end;
 end;
end;

procedure checksegmentcapacity(const asegment: segmentty;
                               asize: integer; var buffer: pointer);
begin
 with segments[asegment] do begin
  sizealign(asize);
  inc(toppo,asize);
  if toppo > endpo then begin
   grow(asegment,buffer);
  end;
  dec(toppo,asize);
 end;
end;

function checksegmentcapacity(const asegment: segmentty; 
                                           asize: integer): pointer;
                                 //returns alloc top
begin
 with segments[asegment] do begin
  sizealign(asize);
  inc(toppo,asize);
  if toppo > endpo then begin
   grow(asegment);
  end;
  dec(toppo,asize);
  result:= toppo;
 end;
end;
{
function alignsegment(const asegment: segmentty): pointer;
begin
 with segments[asegment] do begin
  toppo:= pointer((ptruint(toppo)+alignstep) and alignmask);
  if toppo > endpo then begin
   grow(asegment);
  end;
  result:= toppo;
 end;
end;

procedure alignsegment(var aaddress:segaddressty);
begin
 with segments[aaddress.segment] do begin
  toppo:= pointer((ptruint(toppo)+alignstep) and alignmask);
  if toppo > endpo then begin
   grow(aaddress.segment);
  end;
 end;
end;
}
procedure setsegmenttop(const asegment: segmentty; const atop: pointer);
begin
 with segments[asegment] do begin
  toppo:= atop;
 end; 
end;

procedure resetsegment(const asegment: segmentty);
begin
 with segments[asegment] do begin
  toppo:= data;
 end; 
end;

function setsubsegment(const asubseg: subsegmentty): segmentstatety; 
                                                 //returns old state
begin
 result.segment:= asubseg.segment;
 result.state:= segments[asubseg.segment];
 with segments[asubseg.segment] do begin
  data:= data + asubseg.start;
  toppo:= data + asubseg.size;
 end;
end;

function getsubsegment(const asegment: segmentty): subsegmentty;
begin
 result.segment:= asegment;
 with segments[asegment] do begin
  result.start:= toppo-data;
  result.size:= 0;
 end;
end;

procedure setsubsegmentsize(var asubseg: subsegmentty);
begin
 with segments[asubseg.segment] do begin
  asubseg.size:= toppo - data - asubseg.start;
 end;
end;

procedure setsegment(const aseg: segmentstatety);
begin
 segments[aseg.segment]:= aseg.state;
end;

function getsegmentoffset(const asegment: segmentty;
                                    const apo: pointer): dataoffsty;
begin
 result:= apo - segments[asegment].data;
end;

function getsegmentpo(const asegment: segmentty;
                                    const aoffset: dataoffsty): pointer;
begin
 result:= segments[asegment].data + aoffset;
end;

function getsegmentpo(const aaddress: segaddressty): pointer;
begin
 result:= segments[aaddress.segment].data + aaddress.address;
end;

function getsegaddress(const asegment: segmentty;
                             const aaddress: dataoffsty): segaddressty;
begin
 result.segment:= asegment;
 result.address:= aaddress;
end;

function getsegaddress(const asegment: segmentty;
                             const aref: pointer): segaddressty;
begin
 result.segment:= asegment;
 result.address:= aref-segments[asegment].data;
end;

function getoppo(const opindex: integer): popinfoty;
begin
 result:= getsegmentpo(seg_op,opindex*sizeof(opinfoty));
end;

function getsegmenttoppo(const asegment: segmentty): pointer;
begin
 result:= segments[asegment].toppo;
end;

function getsegmenttopoffs(const asegment: segmentty): dataoffsty;
begin
 with segments[asegment] do begin
  result:= toppo-pointer(data);
 end;
end;

function getsegmentbase(const asegment: segmentty): pointer;
begin
 result:= segments[asegment].data;
end;

function getsegmentsize(const asegment: segmentty): integer;
begin
 with segments[asegment] do begin
  result:= toppo-pointer(data);
 end;
end;

procedure dofinalize();
var
 seg1: segmentty;
begin
 for seg1:= low(segmentty) to high(segmentty) do begin
  with segments[seg1] do begin
   if data <> nil then begin
    freemem(data);
   end;
  end;
 end;
end;

procedure init();
begin
 dofinalize();
 fillchar(segments,sizeof(segments),0);
end;

procedure deinit();
begin
 //dummy
end;
 
finalization
 dofinalize();
end.
