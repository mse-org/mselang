{ MSElang Copyright (c) 2014-2015 by Martin Schreiber
   
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
unit llvmlists;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msehash,parserglob,handlerglob,mselist,msestrings,llvmbitcodes,
 opglob,__mla__internaltypes,interfacehandler;

const
 maxparamcount = 512;

type
 bufferdataty = record
  listindex: int32;
  buffersize: int32;
  buffer: ptruint{card32}; 
             //direct data or buffer offset if buffersize > sizeof(ptruint)
 end;
 
 bufferhashdataty = record
  header: hashheaderty;
  data: bufferdataty;
 end;
 pbufferhashdataty = ^bufferhashdataty;
 
 bufferallocdataty = record
  data: pointer; //first!
  size: int32;
 end;

 buffermarkinfoty = record
  hashref: ptruint;
  bufferref: ptruint;
 end;
 
 tbufferhashdatalist = class(thashdatalist)
  private
   fbuffer: pointer;
   fbuffersize: integer;
   fbuffercapacity: integer;
  protected
   procedure checkbuffercapacity(const asize: integer);
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitemdata): boolean override;
   function addunique(const adata: bufferallocdataty;
                       out res: pbufferhashdataty): boolean; //true if new
   function addunique(const adata: card32;
                       out res: pbufferhashdataty): boolean; //true if new
   function addunique(const adata; const size: integer;
                       out res: pbufferhashdataty): boolean; //true if new
  public
   constructor create(const datasize: integer);
   procedure clear(); override;
   procedure mark(out ref: buffermarkinfoty);
   procedure release(const ref: buffermarkinfoty);
   function absdata(const aoffset: ptruint): pointer; inline;
 end;

 typelistdataty = record
  header: bufferdataty; //header.buffer -> alloc size if size = -1
  kind: databitsizety;
//  typealloc: typeallocinfoty;
 end;
 ptypelistdataty = ^typelistdataty;
 
 typelisthashdataty = record
  header: hashheaderty;
  data: typelistdataty;
 end;
 ptypelisthashdataty = ^typelisthashdataty;

 aggregatekindty = (ak_none,ak_pointerarray,ak_struct,ak_aggregatearray);
 typeallocdataty = record
  header: bufferallocdataty; //header.data -> alloc size if size = -1
  kind: databitsizety; //aggregatekindty if negative
 end;

 subtypeheaderty = record
  flags: subflagsty;
  paramcount: integer;
 end;
 psubtypeheaderty = ^subtypeheaderty;

 paramitemflagty = (pif_dumy);
 paramitemflagsty = set of paramitemflagty;
 paramitemty = record
  typelistindex: int32;
  flags: paramitemflagsty;
 end;
 pparamitemty = ^paramitemty;

 subtypedataty = record
  header: subtypeheaderty;
  params: record           //array of paramitemty
  end;
 end;
 psubtypedataty = ^subtypedataty;

 paramsty = record
  count: int32;
  items: pparamitemty;
 end;
 pparamsty = ^paramsty;

 aggregatearraytypedataty = record
  size: int32;
  typ: int32;
 end;
 paggregatearraytypedataty = ^aggregatearraytypedataty;
 
const
 noparams: paramsty = (
  count: 0;
  items: nil;
 );
 voidtype = ord(das_none);
 pointertype = ord(das_pointer);
 bytetype = ord(das_8);
 inttype = ord(das_32);
{$if pointersize = 64}
 sizetype = ord(das_64);
{$else}
 sizetype = ord(das_32);
{$endif}
 bittypemax = ord(lastdatakind);
 
type
 ttypehashdatalist = class(tbufferhashdatalist)
  protected
   fclassdef: int32;
   fintfitem: int32;
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitemdata): boolean override;
   function addvalue(var avalue: typeallocdataty): ptypelisthashdataty; inline;
  public
   constructor create();
   procedure clear(); override; //automatic entries for bitsize optypes...
   function addbitvalue(const asize: databitsizety): integer; //returns listid
   function addbytevalue(const asize: integer): integer; //returns listid
   function addpointerarrayvalue(const asize: int32): integer;
   function addaggregatearrayvalue(const asize: int32;
                                            const atype: int32): integer;
   function addstructvalue(const atypes: array of int32): integer;
   function addstructvalue(const asize: int32; const atypes: pint32): integer;
   function addvarvalue(const avalue: pvardataty): integer; //returns listid
   function addsubvalue(const avalue: psubdataty): integer; //returns listid
                         //nil -> main sub
   function addsubvalue(const aflags: subflagsty; 
                                          const aparams: paramsty): int32;
            //first item can be result type, returns listid
   function first: ptypelistdataty;
   function next: ptypelistdataty;
   property classdef: int32 read fclassdef;
   property intfitem: int32 read fintfitem;
 end;

 consttypety = (ct_none,ct_null,ct_pointercast,
                ct_pointerarray,ct_aggregatearray,ct_aggregate{,ct_intfitem});
                                            //stored as negative typeid

 constlistdataty = record
  header: bufferdataty;
  typeid: integer; // < 0 -> consttypety
 end;
 pconstlistdataty = ^constlistdataty;
 
 constlisthashdataty = record
  header: hashheaderty;
  data: constlistdataty;
 end;
 pconstlisthashdataty = ^constlisthashdataty;

 constallocdataty = record
  header: bufferallocdataty;  //header.data = ord value if size = -1
  typeid: integer;
 end;

//const
// nullconst = 256;
const
 maxpointeroffset = 32; //preallocated pointeroffset values
 nullpointeroffset = high(card8)+1; //constlist index
 
type 
 nullconstty = (nc_i1 = 256+maxpointeroffset+1, nc_i8, nc_i16, nc_i32, nc_i64,
                nc_pointer);
const
 nullpointer = ord(nc_pointer);
 nullconst: llvmconstty = (
             listid: nullpointer;
             typeid: pointertype;
            ); 
type
 aggregateconstheaderty = record
  typeid: int32;
  itemcount: int32;
 end;
 aggregateconstty = record
  header: aggregateconstheaderty;
  items: record //array[count] of int32
  end;
 end;
 paggregateconstty = ^aggregateconstty;
{ 
 intfitemconstty = record
  instanceshiftid: int32;
  subid: int32;
 end;
 pintfitemconstty = ^intfitemconstty;
}
 
 tconsthashdatalist = class(tbufferhashdatalist)
  private
   ftypelist: ttypehashdatalist;
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitemdata): boolean override;
//   function addintfitem(const aitem: intfitemconstty): int32;
  public
   constructor create(const atypelist: ttypehashdatalist);
   procedure clear(); override; //init first entries with 0..255
   function addi1(const avalue: boolean): llvmconstty;
   function addi8(const avalue: int8): llvmconstty;
   function addi16(const avalue: int16): llvmconstty;
   function addi32(const avalue: int32): llvmconstty;
   function addi64(const avalue: int64): llvmconstty;
   function adddataoffs(const avalue: dataoffsty): llvmconstty;
   function addvalue(const avalue; const asize: int32): llvmconstty;
   function addpointerarray(const asize: int32;
                                     const ids: pint32): llvmconstty;
               //ids[asize] used for type id, restored
   function addaggregatearray(const asize: int32; const atype: int32; 
                                              const ids: pint32): llvmconstty;
               //ids[asize] used for type id not restored
   function addpointercast(const aid: int32): llvmconstty;
   function addaggregate(const avalue: paggregateconstty): llvmconstty;
   function addclassdef(const aclassdef: classdefinfopoty; 
                                const aintfcount: int32
                        {const virtualcount: int32; const virtualsubs: pint32;
                                  const virtualsubconsts: pint32}): llvmconstty;
                        //virtualsubconsts[virtualcount] used fot typeid
   function addintfdef(const aintf: pintfdefinfoty;
                                       const acount: int32): llvmconstty;
                                                   //overwrites aintf data
   function addnullvalue(const atypeid: int32): llvmconstty;
   property typelist: ttypehashdatalist read ftypelist;
   function first(): pconstlistdataty;
   function next(): pconstlistdataty;
   function pointeroffset(const aindex: int32): int32; //offset in pointer array
   function i8(const avalue: int8): int32; //returns id
   function gettype(const aindex: int32): int32;
 end;

 globnamedataty = record
  name: lstringty;
  listindex: integer;
 end;
 pglobnamedataty = ^globnamedataty;
 tglobnamelist = class(trecordlist)
  public
   constructor create;
   procedure addname(const aname: lstringty; const alistindex: integer);
 end;
 
 globallockindty = (gak_var,gak_const,gak_sub); 
 globallocdataty = record
  typeindex: int32;
  initconstindex: int32;
  case kind: globallockindty of
   gak_sub: (flags: subflagsty; linkage: linkagety;)
 end;
 pgloballocdataty = ^globallocdataty;
 
 tgloballocdatalist = class(trecordlist)
  private
   ftypelist: ttypehashdatalist;
   fnamelist: tglobnamelist;
   fconstlist: tconsthashdatalist;
  protected
   function addnoinit(const atyp: int32): int32;
  public
   constructor create(const atypelist: ttypehashdatalist;
                          const aconstlist: tconsthashdatalist);
   destructor destroy(); override;
   procedure clear(); override;
//   function addvalue(var avalue: typeallocinfoty): int32;
   function addvalue(const avalue: pvardataty): int32; 
                                                            //returns listid
   function addbitvalue(const asize: databitsizety): int32;
                                                            //returns listid
   function addbytevalue(const asize: integer): int32;
                                                           //returns listid
   function addsubvalue(const avalue: psubdataty): int32; //returns listid
                               //nil -> main sub
   function addsubvalue(const avalue: psubdataty;
                           const aname: lstringty): int32;  //returns listid
                               //nil -> main sub
   function addsubvalue(const aflags: subflagsty; const alinkage: linkagety; 
                             const aparams: paramsty): int32; 
                                                             //returns listid
   function addinternalsubvalue(const aflags: subflagsty; 
                 const aparams: paramsty): int32; //returns listid
   function addexternalsubvalue(const aflags: subflagsty; 
                       const aparams: paramsty;
                           const aname: lstringty): int32;  //returns listid

   procedure updatesubtype(const avalue: psubdataty); 
                 //new type for changed flags sf_hasnestedaccess
   function addinitvalue(const akind: globallockindty;
                                     const aconstlistindex: integer): int32;
                                                            //returns listid
   function addtypecopy(const alistid: int32): int32;
   function gettype(const alistid: int32): int32; //returns type listid
   property namelist: tglobnamelist read fnamelist;
 end;

implementation
uses
 errorhandler,elements,segmentutils;
  
{ tbufferhashdatalist }

constructor tbufferhashdatalist.create(const datasize: integer);
begin
 inherited create(sizeof(bufferhashdataty)-sizeof(hashheaderty)+datasize);
end;

procedure tbufferhashdatalist.checkbuffercapacity(const asize: integer);
begin
 fbuffersize:= fbuffersize + asize;
 if fbuffersize > fbuffercapacity then begin
  fbuffercapacity:= fbuffersize*2 + 1024;
  reallocmem(fbuffer,fbuffercapacity);
 end;
end;

procedure tbufferhashdatalist.clear;
begin
 inherited;
 if fbuffer <> nil then begin
  freemem(fbuffer);
  fbuffer:= nil;
  fbuffercapacity:= 0;
 end;
 fbuffersize:= 0;
end;

procedure tbufferhashdatalist.mark(out ref: buffermarkinfoty);
begin
 inherited mark(ref.hashref);
 ref.bufferref:= fbuffersize;
end;

procedure tbufferhashdatalist.release(const ref: buffermarkinfoty);
begin
 inherited release(ref.hashref);
 fbuffersize:= ref.bufferref;
end;

function tbufferhashdatalist.hashkey(const akey): hashvaluety;
begin
 with bufferallocdataty(akey) do begin
  if size < 0 then begin
   result:= scramble(hashvaluety(ptruint(pointer(data))));
  end
  else begin
   result:= datahash2(data^,size);
  end;
 end;
end;

function tbufferhashdatalist.checkkey(const akey; const aitemdata): boolean;
var
 po1,po2,pe: pcard8;
begin
 result:= true;
 with bufferdataty(aitemdata) do begin
  if buffersize <> bufferallocdataty(akey).size then begin
   result:= false;
  end
  else begin
   if buffersize < 0 then begin
    result:= ptruint(akey) = buffer;
   end
   else begin
    po1:= bufferallocdataty(akey).data;
    pe:= po1 + buffersize;
    po2:= fbuffer + buffer;
    while po1 < pe do begin
     if po1^ > po2^ then begin
      result:= false;
      exit;
     end;
     inc(po1);
     inc(po2);
    end;
   end;
  end
 end;
end;

function tbufferhashdatalist.addunique(const adata: bufferallocdataty;
                              out res: pbufferhashdataty): boolean;
var
 po1: pbufferhashdataty;
begin
 po1:= pointer(internalfind(adata));
 result:= po1 = nil;
 if result then begin
  po1:= pointer(internaladd(adata));
  if adata.size < 0 then begin
   po1^.data.buffersize:= -1;
   po1^.data.buffer:= ptruint(adata.data);
  end
  else begin
   checkbuffercapacity(adata.size);
   po1^.data.buffersize:= adata.size;
   po1^.data.buffer:= fbuffersize;
   move(adata.data^,(fbuffer+fbuffersize)^,adata.size);
   fbuffersize:= fbuffersize + adata.size;
  end;
  po1^.data.listindex:= count-1;
 end;
 res:= po1;
end;

function tbufferhashdatalist.addunique(const adata: card32;
                                     out res: pbufferhashdataty): boolean;
var
 a1: bufferallocdataty;
 po1: pbufferhashdataty;
begin
 a1.size:= -1;
 a1.data:= pointer(ptruint(adata));
 result:= addunique(a1,res);
end;

function tbufferhashdatalist.addunique(const adata;  const size: integer;
                              out res: pbufferhashdataty): boolean;
var
 a1: bufferallocdataty;
 po1: pbufferhashdataty;
begin
 a1.size:= size;
 a1.data:= @adata;
 result:= addunique(a1,res);
end;

function tbufferhashdatalist.absdata(const aoffset: ptruint): pointer; inline;
begin
 result:= fbuffer+aoffset;
end;

{ ttypehashdatalist }

constructor ttypehashdatalist.create();
begin
// inherited create(sizeof(typeallocinfoty));
 inherited create(sizeof(typelisthashdataty)-sizeof(bufferhashdataty));
 clear();
end;

procedure ttypehashdatalist.clear;
var
 k1: databitsizety;
// t1: typeallocdataty;
begin
 inherited;
 if not (hls_destroying in fstate) then begin
  for k1:= low(databitsizety) to lastdatakind do begin
   addbitvalue(k1);
  end;
  fclassdef:= addbytevalue(sizeof(classdefheaderty));
  fintfitem:= addstructvalue([inttype,pointertype]);
 end;
 {
 t1.header.size:= -1;
 t1.header.data:= nil;
 t1.kind:= das_none;
 addvalue(t1);        //void
 }
end;

function ttypehashdatalist.addvalue(
                 var avalue: typeallocdataty): ptypelisthashdataty; inline;
begin
 if addunique(bufferallocdataty((@avalue)^),pointer(result)) then begin
  result^.data.kind:= avalue.kind;
 end;
end;

function ttypehashdatalist.addbitvalue(const asize: databitsizety): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= -1;
 t1.header.data:= pointer(ptruint(bitopsizes[asize]));
 t1.kind:= asize;
 po1:= addvalue(t1);
// if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
//  po1^.data.kind:= avalue.kind;
// end;
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addbytevalue(const asize: integer): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= -1;
 t1.header.data:= pointer(ptruint(asize));
 t1.kind:= das_none;
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addpointerarrayvalue(const asize: int32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= -1;
 t1.header.data:= pointer(ptruint(asize));
 t1.kind:= databitsizety(-(ord(ak_pointerarray)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addaggregatearrayvalue(const asize: int32;
                                                  const atype: int32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
 info1: aggregatearraytypedataty;
begin
 info1.size:= asize;
 info1.typ:= atype;
 t1.header.size:= sizeof(info1);
 t1.header.data:= @info1;
 t1.kind:= databitsizety(-(ord(ak_aggregatearray)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addstructvalue(
              const atypes: array of int32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= length(atypes)*sizeof(int32);
 t1.header.data:= @atypes[0];
 t1.kind:= databitsizety(-(ord(ak_struct)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addstructvalue(const asize: int32;
                                               const atypes: pint32): integer;
var
 t1: typeallocdataty;
 po1: ptypelisthashdataty;
begin
 t1.header.size:= asize*sizeof(int32);
 t1.header.data:= atypes;
 t1.kind:= databitsizety(-(ord(ak_struct)));
 po1:= addvalue(t1);
 result:= po1^.data.header.listindex;
end;


type
 subtypebufferty = record
  header: subtypeheaderty;
  params: array[0..maxparamcount-1] of paramitemty;
 end;

function ttypehashdatalist.addsubvalue(const avalue: psubdataty): integer;

var
 alloc1: typeallocdataty;
 po1: ptypelisthashdataty;
 parbuf: subtypebufferty;
 po2: pelementoffsetty;
 i1: int32;
begin
 if avalue = nil then begin //main()
  with parbuf do begin
   header.flags:= [sf_function];
   header.paramcount:= 1;
   with params[0] do begin
    flags:= [];
    typelistindex:= ord(das_32);
   end;
  end;
 end
 else begin
  with parbuf do begin
   header.flags:= avalue^.flags;
   header.paramcount:= avalue^.paramcount;
   i1:= avalue^.allocs.nestedalloccount+1; 
            //first item is possible pointer to outer frame
   if i1 > 1 then begin
    avalue^.allocs.nestedallocstypeindex:= addbytevalue(i1*pointersize);
   end
   else begin
    avalue^.allocs.nestedallocstypeindex:= -1;
   end;
   if sf_hasnestedaccess in header.flags then begin
                   //array of pointer for pointer to nested vars
    with parbuf.params[0] do begin
     flags:= [];
     typelistindex:= ord(das_pointer);
    end;
    inc(header.paramcount);
    i1:= 1;
   end
   else begin
    i1:= 0;
   end;
   if header.paramcount > maxparamcount then begin
    header.paramcount:= 0;
    errormessage(err_toomanyparams,[]);
   end;
   po2:= @avalue^.paramsrel;
   for i1:= i1 to header.paramcount - 1 do begin
    with params[i1] do begin
     flags:= [];
     typelistindex:= addvarvalue(ele.eledataabs(po2^));
    end;
    inc(po2);
   end;
  end;
 end;
 alloc1.kind:= das_sub;
 alloc1.header.size:= sizeof(subtypeheaderty) + 
             parbuf.header.paramcount * sizeof(paramitemty);
 alloc1.header.data:= @parbuf;
 result:= addvalue(alloc1)^.data.header.listindex;
end;

function ttypehashdatalist.addsubvalue(const aflags: subflagsty; 
                                             const aparams: paramsty): int32;
var
 alloc1: typeallocdataty;
 po1: ptypelisthashdataty;
 parbuf: subtypebufferty;
 i1,i2: int32;
begin
 with parbuf do begin
  header.flags:= aflags;
  header.paramcount:= aparams.count;
  for i1:= 0 to aparams.count - 1 do begin
   params[i1]:= aparams.items[i1];
  end;
 end;
 alloc1.kind:= das_sub;
 alloc1.header.size:= sizeof(subtypeheaderty) + 
             aparams.count * sizeof(paramitemty);
 alloc1.header.data:= @parbuf;
 result:= addvalue(alloc1)^.data.header.listindex;
end;

function ttypehashdatalist.addvarvalue(const avalue: pvardataty): integer;
var
 po1: ptypedataty;
begin 
 po1:= ele.eledataabs(avalue^.vf.typ);
 if (af_paramindirect in avalue^.address.flags) or 
      (po1^.indirectlevel+avalue^.address.indirectlevel > 0) then begin
  result:= pointertype;
 end
 else begin
  if po1^.datasize = das_none then begin
   result:= addbytevalue(po1^.bytesize);
  end
  else begin
   result:= addbitvalue(po1^.datasize);
  end;
 end;
end;

function ttypehashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= inherited hashkey(akey) xor 
               scramble(ord(typeallocdataty(akey).kind));
end;

function ttypehashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= (typeallocdataty(akey).kind = typelistdataty(aitemdata).kind) and
              inherited checkkey(akey,aitemdata);
end;

function ttypehashdatalist.first: ptypelistdataty;
begin
 result:= pointer(internalfirst());
end;

function ttypehashdatalist.next: ptypelistdataty;
begin
 result:= pointer(internalnext());
end;

{ tconsthashdatalist }

constructor tconsthashdatalist.create(const atypelist: ttypehashdatalist);

begin
 ftypelist:= atypelist;
 inherited create(sizeof(constlisthashdataty)-sizeof(bufferhashdataty));
// inherited create(sizeof(constallocdataty));
 clear(); //create default entries
end;

procedure tconsthashdatalist.clear;
var
 c1: card8;
 po1: pconstlisthashdataty;
 alloc1: constallocdataty;
 i1: int32;
begin
 inherited;
 if not (hls_destroying in fstate) then begin
  for c1:= low(c1) to high(c1) do begin
   addi8(int8(c1));
  end;
  for i1:= 0 to maxpointeroffset do begin
   addi32(i1*pointersize);
  end;
  addnullvalue(ord(das_1));
  addnullvalue(ord(das_8));
  addnullvalue(ord(das_16));
  addnullvalue(ord(das_32));
  addnullvalue(ord(das_64));
  addnullvalue(ord(das_pointer));
 end;
end;

function tconsthashdatalist.pointeroffset(const aindex: int32): int32;
begin
 if aindex <= maxpointeroffset then begin
  result:= high(card8)+1+aindex
 end
 else begin
  result:= addi32(aindex*pointersize).listid;
  if result = count-1 then begin
   internalerror1(ie_llvmlist,'20150225');
  end;
 end;
end;

function tconsthashdatalist.i8(const avalue: int8): int32;
begin
 result:= card8(avalue);
end;

function tconsthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= inherited hashkey(akey) xor scramble(constallocdataty(akey).typeid);
end;

function tconsthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= (constlistdataty(aitemdata).typeid = 
                           constallocdataty(akey).typeid) and 
                                    inherited checkkey(akey,aitemdata);
end;

function tconsthashdatalist.addi1(const avalue: boolean): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 if avalue then begin
  alloc1.header.data:= pointer(ptruint(1));
 end
 else begin
  alloc1.header.data:= pointer(ptruint(0));
 end;
 alloc1.typeid:= ord(das_1);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi8(const avalue: int8): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_8);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi16(const avalue: int16): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_16);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi32(const avalue: int32): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_32);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addi64(const avalue: int64): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
{$ifdef cpu64}
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(avalue));
 alloc1.typeid:= ord(das_64);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result:= po1^.data.header.listindex
{$else}
 result:= addvalue(avalue,8);
{$endif}
end;

function tconsthashdatalist.adddataoffs(const avalue: dataoffsty): llvmconstty;
begin
{$if sizeof(dataoffsty) = 4}
 result:= addi32(avalue);
{$else}
 result:= addi64(avalue);
{$ifend}
end;

function tconsthashdatalist.addvalue(const avalue;
                                            const asize: int32): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= asize;
 alloc1.header.data:= @avalue;
 alloc1.typeid:= ftypelist.addbytevalue(asize);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.typeid;
end;

function tconsthashdatalist.addnullvalue(const atypeid: int32): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptrint(atypeid));
 alloc1.typeid:= -ord(ct_null);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= po1^.data.header.buffer;
end;

function tconsthashdatalist.addpointercast(const aid: int32): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptrint(aid));
 alloc1.typeid:= -ord(ct_pointercast);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= pointertype;
end;

function tconsthashdatalist.addpointerarray(const asize: int32;
                                              const ids: pint32): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
 i1: int32;
begin
 alloc1.header.size:= (asize+1)*sizeof(int32);
 alloc1.header.data:= ids;
 i1:= ids[asize];
 ids[asize]:= ftypelist.addpointerarrayvalue(asize);
 alloc1.typeid:= -ord(ct_pointerarray);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= ids[asize];
 ids[asize]:= i1;
end;

function tconsthashdatalist.addaggregatearray(const asize: int32;
                           const atype: int32; const ids: pint32): llvmconstty;
                                     //ids[asize] used for type id
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= (asize+1)*sizeof(int32);
 alloc1.header.data:= ids;
 ids[asize]:= ftypelist.addaggregatearrayvalue(asize,atype);
 alloc1.typeid:= -ord(ct_aggregatearray);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= ids[asize];
end;

function tconsthashdatalist.addaggregate(
                               const avalue: paggregateconstty): llvmconstty;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= sizeof(avalue^)+avalue^.header.itemcount*sizeof(int32);
 alloc1.header.data:= avalue;
 alloc1.typeid:= -ord(ct_aggregate);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result.listid:= po1^.data.header.listindex;
 result.typeid:= avalue^.header.typeid;
end;
var testvar: classdefinfopoty;
function tconsthashdatalist.addclassdef(const aclassdef: classdefinfopoty;
                                          const aintfcount: int32): llvmconstty;
 function getclassid(const asegoffset: int32): int32;
 begin
  result:= pint32(getsegmentpo(seg_classdef,asegoffset))^;
 end; //getclassid

type
 classdefty = record
  header: aggregateconstty;
  //parentclass,interfaceparent,allocs,virtualmethods,interfaces
  //0           1               2      3              4
  items: array[0..4] of int32; //constlist ids
 end;
var
 pd: pint32;
 co1: llvmconstty;
 
 classdef1: classdefty;
 types1: array[0..2] of int32;
 i1: int32;
 ps1,ps,pe: popaddressty;
 po1: pointer;
begin
 if aclassdef^.header.parentclass < 0 then begin
  classdef1.items[0]:= nullpointer;
  classdef1.items[1]:= nullpointer;
 end
 else begin                 
testvar:= getsegmentpo(seg_classdef,aclassdef^.header.parentclass);
  classdef1.items[0]:= addpointercast(
                          getclassid(aclassdef^.header.parentclass)).listid;
  if aclassdef^.header.interfaceparent < 0 then begin
   classdef1.items[1]:= nullpointer;
  end
  else begin
   classdef1.items[1]:= addpointercast(
                    getclassid(aclassdef^.header.interfaceparent)).listid;
  end;
 end;
 types1[0]:= pointertype;
 types1[1]:= pointertype;
 co1:= addvalue(aclassdef^.header.allocs,sizeof(aclassdef^.header.allocs));
 classdef1.items[2]:= co1.listid;
 types1[2]:= co1.typeid;             

 classdef1.header.header.itemcount:= 3;
 
 ps:= @aclassdef^.virtualmethods;
 pd:= pointer(ps);
 pe:= pointer(aclassdef)+aclassdef^.header.allocs.classdefinterfacestart;
 i1:= pe - ps;
 if i1 > 0 then begin
  while ps < pe do begin
   pd^:= addpointercast(ps^).listid;
   inc(pd);
   inc(ps);
  end;
  co1:= addpointerarray(i1,@aclassdef^.virtualmethods);
  classdef1.items[1]:= co1.listid;
  types1[1]:= co1.typeid;
  classdef1.header.header.itemcount:= 2;
 end;
 if aintfcount > 0 then begin
  po1:= getsegmentbase(seg_intf);
  ps1:= ps;
  pe:= ps+aintfcount;
  while ps < pe do begin
   pd^:= addpointercast(pint32(po1+ps^)^).listid;
   inc(pd);
   inc(ps);
  end;
  co1:= addpointerarray(aintfcount,pointer(ps1));
  classdef1.items[classdef1.header.header.itemcount]:= co1.listid;
  types1[classdef1.header.header.itemcount]:= co1.typeid;
  inc(classdef1.header.header.itemcount);
 end;
 classdef1.header.header.typeid:= ftypelist.addstructvalue(
                                  classdef1.header.header.itemcount,@types1);
 result:= addaggregate(@classdef1); 
{
 poa:= virtualsubs;
 pob:= virtualsubconsts;
 if virtualcount > 0 then begin
  pe:= poa+virtualcount;
  while poa < pe do begin
   pob^:= addpointercast(poa^).listid;
   inc(poa);
   inc(pob);
  end;
  co1:= addpointerarray(virtualcount,virtualsubconsts);
  classdef1.header.header.typeid:= 
               ftypelist.addstructvalue([ftypelist.fclassdef,co1.typeid]);
  classdef1.virtualtable:= co1.listid;
  classdef1.header.header.itemcount:= 2;
 end
 else begin
  classdef1.header.header.typeid:= 
               ftypelist.addstructvalue([ftypelist.fclassdef]);
  classdef1.header.header.itemcount:= 1;
 end;
 classdef1.info:= addvalue(aclassdef^.header,sizeof(aclassdef^.header)).listid;
 result:= addaggregate(@classdef1); 
}
end;
{
function tconsthashdatalist.addintfitem(const aitem: intfitemconstty): int32;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= sizeof(aitem);
 alloc1.header.data:= @aitem;
 alloc1.typeid:= -ord(ct_intfitem);
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result:= po1^.data.header.listindex;
end;
}
function tconsthashdatalist.addintfdef(const aintf: pintfdefinfoty;
               const acount: int32): llvmconstty;
                //overwrites aintf data
var
 intfpo,intfe: popaddressty;
 oppo: popinfoty;
 pi1: pint32;
 agg1: record
  header: aggregateconstheaderty;
  offs: int32;
  items: int32;
 end;
 co1,offs1: llvmconstty;
begin
 offs1:= addi32(aintf^.header.instanceoffset);
 intfpo:= @aintf^.items;
 intfe:= intfpo+acount;
 pi1:= pointer(aintf);
 while intfpo < intfe do begin
  oppo:= getoppo(intfpo^+1);
 {$ifdef mse_checkinternalerror}
  if oppo^.op.op <> oc_subbegin then begin
   internalerror(ie_llvm,'20150404A');
  end;
 {$endif}
  pi1^:= addpointercast(oppo^.par.subbegin.globid).listid;
  inc(pi1);
  inc(intfpo);  
 end;
 co1:= addpointerarray(acount,pint32(aintf));
 agg1.header.itemcount:= 2;
 agg1.header.typeid:= ftypelist.addstructvalue([offs1.typeid,co1.typeid]);
 agg1.offs:= offs1.listid;
 agg1.items:= co1.listid;
 result:= addaggregate(@agg1);
end;

function tconsthashdatalist.first: pconstlistdataty;
begin
 result:= pointer(internalfirst());
end;

function tconsthashdatalist.next: pconstlistdataty;
begin
 result:= pointer(internalnext());
end;

function tconsthashdatalist.gettype(const aindex: int32): int32;
begin
 result:= pconstlisthashdataty(fdata)[aindex].data.typeid;
end;

{ tglobnamelist }

constructor tglobnamelist.create;
begin
 inherited create(sizeof(globnamedataty));
end;

procedure tglobnamelist.addname(const aname: lstringty;
               const alistindex: integer);
begin
 inccount();
 with (pglobnamedataty(fdata)+fcount-1)^ do begin
  name:= aname;
  listindex:= alistindex;
 end;
end;

{ tgloballocdatalist }

constructor tgloballocdatalist.create(const atypelist: ttypehashdatalist;
                                       const aconstlist: tconsthashdatalist);
begin
 ftypelist:= atypelist;
 fconstlist:= aconstlist;
 fnamelist:= tglobnamelist.create;
 inherited create(sizeof(globallocdataty));
end;

destructor tgloballocdatalist.destroy();
begin
 inherited;
 fnamelist.free();
end;

procedure tgloballocdatalist.clear;
begin
 inherited;
 fnamelist.clear();
end;

{
function tgloballocdatalist.addvalue(var avalue: typeallocinfoty): int32;
var
 dat1: globallocdataty;
begin
 ftypelist.addvalue(avalue);
 dat1.typeindex:= avalue.listindex;
 dat1.kind:= gak_var;
 dat1.initconstindex:= -1;
 avalue.listindex:= fcount;
 inccount();
 (pgloballocdataty(fdata) + avalue.listindex)^:= dat1;
end;
}
function tgloballocdatalist.addnoinit(const atyp: int32): int32;
var
 dat1: globallocdataty;
begin
 fillchar(dat1,sizeof(dat1),0);
 dat1.typeindex:= atyp;
 dat1.kind:= gak_var;
 dat1.initconstindex:= fconstlist.addnullvalue(atyp).listid;
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= dat1;
end;

function tgloballocdatalist.addvalue(const avalue: pvardataty): int32;
begin
 result:= addnoinit(ftypelist.addvarvalue(avalue));
end;

function tgloballocdatalist.addbytevalue(const asize: integer): int32;
begin 
 result:= addnoinit(ftypelist.addbytevalue(asize));
end;

function tgloballocdatalist.addbitvalue(const asize: databitsizety): int32;
begin 
 result:= addnoinit(ftypelist.addbitvalue(asize));
end;

function tgloballocdatalist.addinitvalue(const akind: globallockindty;
                                       const aconstlistindex: integer): int32;
var
 dat1: globallocdataty;
 po1: pconstlisthashdataty;
 po2: pint32;
begin
 fillchar(dat1,sizeof(dat1),0);
 po1:= pconstlisthashdataty(fconstlist.fdata)+aconstlistindex+1;
 if po1^.data.typeid < 0 then begin
  case consttypety(-po1^.data.typeid) of
   ct_null: begin       
    dat1.typeindex:= int32(po1^.data.header.buffer);
   end;
   ct_pointercast: begin
    dat1.typeindex:= pointertype;
   end;
   ct_pointerarray,ct_aggregatearray: begin
    dat1.typeindex:= pint32(constlist.absdata(po1^.data.header.buffer))
                           [po1^.data.header.buffersize div sizeof(int32) - 1];
                                       //last item is type
   end;
   ct_aggregate: begin
    dat1.typeindex:= paggregateconstty(
                 constlist.absdata(po1^.data.header.buffer))^.header.typeid;
   end;
   else begin
    internalerror1(ie_bcwriter,'20150328C');
   end;
  end;
 end
 else begin
  dat1.typeindex:= po1^.data.typeid;
 end;
 dat1.kind:= akind;
 dat1.initconstindex:= aconstlistindex; 
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= dat1;
end;

function tgloballocdatalist.addsubvalue(const avalue: psubdataty): int32;
var
 dat1: globallocdataty;
begin
 dat1.flags:= [];
 if avalue = nil then begin
  dat1.linkage:= li_external;
 end
 else begin
  dat1.linkage:= li_internal;
 end;
 dat1.kind:= gak_sub;
 dat1.typeindex:= ftypelist.addsubvalue(avalue);
 dat1.initconstindex:= -1;
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= dat1;
end;

procedure tgloballocdatalist.updatesubtype(const avalue: psubdataty);
var
 po1: psubtypeheaderty;
begin
 with pgloballocdataty(fdata)[avalue^.globid] do begin
  typeindex:= ftypelist.addsubvalue(avalue);
 end;
end;

function tgloballocdatalist.addsubvalue(const avalue: psubdataty;
                                             const aname: lstringty): int32;
begin
 result:= addsubvalue(avalue);
 fnamelist.addname(aname,result);
end;

function tgloballocdatalist.addsubvalue(const aflags: subflagsty; 
                             const alinkage: linkagety; 
                             const aparams: paramsty): int32; 
                                                             //returns listid
var
 dat1: globallocdataty;
begin
 dat1.linkage:= alinkage;
 dat1.flags:= aflags;
 dat1.kind:= gak_sub;
 dat1.typeindex:= ftypelist.addsubvalue(aflags,aparams);
 dat1.initconstindex:= -1;
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= dat1;
end;

function tgloballocdatalist.addinternalsubvalue(const aflags: subflagsty; 
                                              const aparams: paramsty): int32;
begin
 result:= addsubvalue(aflags,li_internal,aparams);
end;

function tgloballocdatalist.addexternalsubvalue(const aflags: subflagsty; 
                      const aparams: paramsty; const aname: lstringty): int32;
begin
 result:= addsubvalue(aflags,li_external,aparams);
 fnamelist.addname(aname,result);
end;

function tgloballocdatalist.gettype(const alistid: int32): int32;
begin
 result:= (pgloballocdataty(fdata) + alistid)^.typeindex;
end;

function tgloballocdatalist.addtypecopy(const alistid: int32): int32;
begin
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= (pgloballocdataty(fdata) + alistid)^; 
end;

end.
