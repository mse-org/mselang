
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
 msetypes,msehash,parserglob,handlerglob,mselist,msestrings,llvmbitcodes;

const
 maxparamcount = 512;

type
 bufferdataty = record
  listindex: int32;
  buffersize: int32;
  buffer: card32; //direct data or buffer offset if size > sizeof(ptruint)
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

 typeallocdataty = record
  header: bufferallocdataty; //header.data -> alloc size if size = -1
  kind: databitsizety;
 end;

 subtypeheaderty = record
  flags: subflagsty;
  paramcount: integer;
 end;

 paramitemty = record
  typelistindex: int32;
 end;
 pparamitemty = ^paramitemty;

 subtypedataty = record
  header: subtypeheaderty;
  params: record           //array of paramitemty
  end;
 end;
 psubtypedataty = ^subtypedataty;

const
 voidtype = ord(das_none);
 bittypemax = ord(lastdatakind);
 
type
 ttypehashdatalist = class(tbufferhashdatalist)
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitemdata): boolean override;
   function addvalue(var avalue: typeallocdataty): ptypelisthashdataty; inline;
  public
   constructor create();
   procedure clear(); override; //automatic entries for bitsize optypes
   function addbitvalue(const asize: databitsizety): integer; //returns listid
   function addbytevalue(const asize: integer): integer; //returns listid
   function addvarvalue(const avalue: pvardataty): integer; //returns listid
   function addsubvalue(const avalue: psubdataty): integer; //returns listid
                         //nil -> main sub
   function first: ptypelistdataty;
   function next: ptypelistdataty;
 end;

 constlistdataty = record
  header: bufferdataty;
  typeid: integer; // < 0 -> NULL value
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
type 
 nullconstty = (nc_i1 = 256, nc_i8, nc_i16, nc_i32, nc_i64);
 
 tconsthashdatalist = class(tbufferhashdatalist)
  private
   ftypelist: ttypehashdatalist;
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitemdata): boolean override;
  public
   constructor create(const atypelist: ttypehashdatalist);
   procedure clear(); override; //init first entries with 0..255
   function addi1(const avalue: boolean): int32; //returns id
   function addi8(const avalue: int8): int32; //returns id
   function addi16(const avalue: int16): int32; //returns id
   function addi32(const avalue: int32): int32; //returns id
   function addi64(const avalue: int64): int32; //returns id
   function addvalue(const avalue; const asize: int32): int32; //returns id
   function addnullvalue(const atypeid: int32): int32; //returns id
   property typelist: ttypehashdatalist read ftypelist;
   function first(): pconstlistdataty;
   function next(): pconstlistdataty;
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
 
 globallockindty = (gak_var,gak_sub); 
 globallocdataty = record
  typeindex: int32;
  initconstindex: int32;
  case kind: globallockindty of
   gak_sub: (linkage: linkagety)
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
   function addinitvalue(const aconstlistindex: integer): int32;
                                                            //returns listid
   property namelist: tglobnamelist read fnamelist;
 end;

implementation
uses
 errorhandler,elements;
 
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
var testvar: bufferdataty; testvar2: bufferallocdataty;
function tbufferhashdatalist.checkkey(const akey; const aitemdata): boolean;
var
 po1,po2,pe: pcard8;
begin
testvar:= bufferdataty(aitemdata); testvar2:= bufferallocdataty(akey);
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
// if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
//  po1^.data.kind:= avalue.kind;
// end;
 result:= po1^.data.header.listindex;
end;

function ttypehashdatalist.addsubvalue(const avalue: psubdataty): integer;

type
 subtypebufferty = record
  header: subtypeheaderty;
  params: array[0..maxparamcount-1] of paramitemty;
 end;

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
   params[0].typelistindex:= ord(das_32);
  end;
 end
 else begin
  with parbuf do begin
   header.flags:= avalue^.flags;
   header.paramcount:= avalue^.paramcount;
   if header.paramcount > maxparamcount then begin
    header.paramcount:= 0;
    errormessage(err_toomanyparams,[]);
   end;
   po2:= @avalue^.paramsrel;
   for i1:= 0 to header.paramcount - 1 do begin //todo: const var out...
    params[i1].typelistindex:= addvarvalue(ele.eledataabs(po2[i1]));
   end;
  end;
 end;
 alloc1.kind:= das_sub;
 alloc1.header.size:= sizeof(subtypeheaderty) + 
             parbuf.header.paramcount * sizeof(paramitemty);
 alloc1.header.data:= @parbuf;
 result:= addvalue(alloc1)^.data.header.listindex;
end;

function ttypehashdatalist.addvarvalue(const avalue: pvardataty): integer;
var
 po1: ptypedataty;
begin 
 po1:= ele.eledataabs(avalue^.vf.typ);
 if po1^.datasize = das_none then begin
  result:= addbytevalue(po1^.bytesize);
 end
 else begin
  result:= addbitvalue(po1^.datasize);
 end;
end;

function ttypehashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= inherited hashkey(akey) xor 
               scramble(ord(typeallocdataty(akey).kind));
end;
//var testvar1: typeallocdataty; testvar2: 
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
begin
 inherited;
 if not (hls_destroying in fstate) then begin
  for c1:= low(c1) to high(c1) do begin
   addi8(int8(c1));
  end;
 end;
 addnullvalue(ord(das_1));
 addnullvalue(ord(das_8));
 addnullvalue(ord(das_16));
 addnullvalue(ord(das_32));
 addnullvalue(ord(das_64));
end;

function tconsthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= inherited hashkey(akey) xor scramble(constallocdataty(akey).typeid);
end;
var testvar3: constlistdataty; testvar4: constallocdataty;
function tconsthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
testvar3:= constlistdataty(aitemdata);
testvar4:= constallocdataty(akey);
 result:= (constlistdataty(aitemdata).typeid = 
                           constallocdataty(akey).typeid) and 
                                    inherited checkkey(akey,aitemdata);
end;

function tconsthashdatalist.addi1(const avalue: boolean): int32;
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
 result:= po1^.data.header.listindex
end;

function tconsthashdatalist.addi8(const avalue: int8): int32;
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
 result:= po1^.data.header.listindex
end;

function tconsthashdatalist.addi16(const avalue: int16): int32;
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
 result:= po1^.data.header.listindex
end;

function tconsthashdatalist.addi32(const avalue: int32): int32;
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
 result:= po1^.data.header.listindex
end;

function tconsthashdatalist.addi64(const avalue: int64): int32;
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

function tconsthashdatalist.addvalue(const avalue; const asize: int32): int32;
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
 result:= po1^.data.header.listindex
end;

function tconsthashdatalist.addnullvalue(const atypeid: int32): int32;
var
 alloc1: constallocdataty;
 po1: pconstlisthashdataty;
begin
 alloc1.header.size:= -1;
 alloc1.header.data:= pointer(ptruint(0));
 alloc1.typeid:= -atypeid;
 if addunique(bufferallocdataty((@alloc1)^),pointer(po1)) then begin
  po1^.data.typeid:= alloc1.typeid;
 end;
 result:= po1^.data.header.listindex
end;

function tconsthashdatalist.first: pconstlistdataty;
begin
 result:= pointer(internalfirst());
end;

function tconsthashdatalist.next: pconstlistdataty;
begin
 result:= pointer(internalnext());
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
 dat1.initconstindex:= fconstlist.addnullvalue(atyp);
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

function tgloballocdatalist.addinitvalue(const aconstlistindex: integer): int32;
var
 dat1: globallocdataty;
begin
 fillchar(dat1,sizeof(dat1),0);
 dat1.typeindex:= (pconstlisthashdataty(fconstlist.fdata)+
                                             aconstlistindex+1)^.data.typeid;
 dat1.kind:= gak_var;
 dat1.initconstindex:= aconstlistindex; 
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= dat1;
end;

function tgloballocdatalist.addsubvalue(const avalue: psubdataty): int32;
var
 dat1: globallocdataty;
begin
 dat1.typeindex:= ftypelist.addsubvalue(avalue);
 dat1.kind:= gak_sub;
 if avalue = nil then begin
  dat1.linkage:= li_external;
 end
 else begin
  dat1.linkage:= li_internal;
 end;
 dat1.initconstindex:= -1;
 result:= fcount;
 inccount();
 (pgloballocdataty(fdata) + result)^:= dat1;
end;

function tgloballocdatalist.addsubvalue(const avalue: psubdataty;
                                             const aname: lstringty): int32;
begin
 result:= addsubvalue(avalue);
 fnamelist.addname(aname,result);
end;

end.
