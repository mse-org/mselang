{ MSElang Copyright (c) 2013-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit stackops;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//
interface
uses
 parserglob,opglob;

const
 pointersize = sizeof(pointer);
 //todo: use variable alignment, remove stacklink
 alignstep = 4;
 alignmask = ptrint(-alignstep);
  
type
 vdatakindty = datakindty;
 pvdatakindty = ^vdatakindty;
 vbooleanty = boolean;
 pvbooleanty = ^vbooleanty;
 vcardinalty = card32;
 pvcardinalty = ^vcardinalty;
 vintegerty = int32;
 pvintegerty = ^vintegerty;
 vfloatty = float64;
 pvfloatty = ^vfloatty;
 vpointerty = pointer;
 pvpointerty = ^vpointerty;
 vsizety = ptrint;
 voffsty = ptrint;
{
 stringheaderty = record
  len: integer;
  data: record
  end;
 end;
 pstringheaderty = ^stringheaderty;
}
 frameinfoty = record
  pc: vpointerty;
  frame: vpointerty;
  link: vpointerty;     //todo: remove link field
 end;
 infoopty = procedure(const opinfo: popinfoty);

 segmentbufferty = record
  base: pointer;
  size: integer;
 end;
 segmentbuffersty = array[segmentty] of segmentbufferty;
 
function alignsize(const size: ptruint): ptruint; 
                         {$ifdef mse_inline}inline;{$endif}

procedure finalize;
procedure run(const stackdepht: integer);
procedure run(const asegments: segmentbuffersty);

function getoptable: poptablety;
procedure allocproc(const asize: integer; var address: segaddressty);

//procedure dummyop;
{
procedure movesegreg0();
procedure moveframereg0();
procedure popreg0();
procedure increg0();

procedure nop();
procedure gotoop();
procedure cmpjmpneimm4();
procedure cmpjmpeqimm4();
procedure cmpjmploimm4();
procedure cmpjmpgtimm4();
procedure cmpjmploeqimm4();

procedure ifop();
procedure writelnop();
procedure writebooleanop();
procedure writeintegerop();
procedure writefloatop();
procedure writestring8op();
procedure writeclassop();
procedure writeenumop();

procedure pushop();
procedure popop();

procedure push8();
procedure push16();
procedure push32();
procedure push64();

procedure pushdatakind();
procedure int32toflo64();
procedure mulint32();
procedure mulimmint32();
procedure mulflo64();
procedure addint32();
procedure addimmint32();
procedure addflo64();
procedure negcard32();
procedure negint32();
procedure negflo64();

procedure offsetpoimm32();

procedure cmpequbool();
procedure cmpequint32();
procedure cmpequflo64();

procedure storesegnil();
procedure storereg0nil();
procedure storeframenil();
procedure storestacknil();
procedure storestackrefnil();
procedure storesegnilar();
procedure storeframenilar();
procedure storereg0nilar();
procedure storestacknilar();
procedure storestackrefnilar();

procedure finirefsizeseg();
procedure finirefsizeframe();
procedure finirefsizereg0();
procedure finirefsizestack();
procedure finirefsizestackref();
procedure finirefsizeframear();
procedure finirefsizesegar();
procedure finirefsizereg0ar();
procedure finirefsizestackar();
procedure finirefsizestackrefar();

procedure increfsizeseg();
procedure increfsizeframe();
procedure increfsizereg0();
procedure increfsizestack();
procedure increfsizestackref();
procedure increfsizeframear();
procedure increfsizesegar();
procedure increfsizereg0ar();
procedure increfsizestackar();
procedure increfsizestackrefar();

procedure decrefsizeseg();
procedure decrefsizeframe();
procedure decrefsizereg0();
procedure decrefsizestack();
procedure decrefsizestackref();
procedure decrefsizeframear();
procedure decrefsizesegar();
procedure decrefsizereg0ar();
procedure decrefsizestackar();
procedure decrefsizestackrefar();

procedure popseg8();
procedure popseg16();
procedure popseg32();
procedure popseg();

procedure poploc8();
procedure poploc16();
procedure poploc32();
procedure poploc();

procedure poplocindi8();
procedure poplocindi16();
procedure poplocindi32();
procedure poplocindi();

procedure pushnil();
procedure pushsegaddress();

procedure pushseg8();
procedure pushseg16();
procedure pushseg32();
procedure pushseg();

procedure pushloc8();
procedure pushloc16();
procedure pushloc32();
procedure pushlocpo();
procedure pushloc();

procedure pushlocindi8();
procedure pushlocindi16();
procedure pushlocindi32();
procedure pushlocindi();

procedure pushaddr();
procedure pushlocaddr();
procedure pushlocaddrindi();
procedure pushsegaddr();
procedure pushsegaddrindi();
procedure pushstackaddr();
procedure pushstackaddrindi();

procedure indirect8();
procedure indirect16();
procedure indirect32();
procedure indirectpo();
procedure indirectpooffs(); //offset after indirect
procedure indirectoffspo(); //offset before indirect
procedure indirect();

procedure popindirect8();
procedure popindirect16();
procedure popindirect32();
procedure popindirect();

procedure callop();
procedure calloutop();
procedure callvirtop();
procedure callintfop();
procedure virttrampolineop();

procedure locvarpushop();
procedure locvarpopop();
procedure returnop();

procedure initclassop();
procedure destroyclassop();

procedure decloop32();
procedure decloop64();

procedure setlengthstr8();

procedure raiseop();
procedure pushcpucontext();
procedure popcpucontext();
procedure finiexception();
procedure continueexception();
}
implementation
uses
 sysutils,handlerglob,mseformatstr,msetypes,internaltypes,mserttiutils,
 segmentutils,classhandler,interfacehandler;
{
 stackinfoty = record
  case datakindty of
   dk_kind: (vdatakind: datakindty);
   dk_boolean: (vboolean: boolean);
   dk_cardinal: (vcardinal: card32);
   dk_integer: (vinteger: int32);
   dk_float: (vfloat: float64);
   dk_address: (vaddress: pointer);
 end;
 stackinfoarty = array of stackinfoty;
 
var
 mainstack: stackinfoarty; 
 mainstackpo: integer;
 framepointer: integer;
}

  
type
 cputy = record
  pc: popinfoty;
  stack: pointer;
  frame: pointer;
  stacklink: pointer;
 end;
 pcputy = ^cputy;
 
 jumpflagty = (jf_exception);
 jumpflagsty = set of jumpflagty;
 
 pjumpinfoty = ^jumpinfoty;
 jumpinfoty = record
  cpu: cputy;
  next: pjumpinfoty;
//  exceptobj: pointer;
//  flags: jumpflagsty;
 end;

 exceptioninfoty = record
  trystack: pjumpinfoty;
  exceptobj: pointer;
 end;

 segmentrangety = record
  basepo: pointer;
  endpo: pointer;
 end; 
  
var                       //todo: use threadvars where necessary
 mainstack: pointer;
 mainstackend: pointer;
 reg0: pointer;
 exceptioninfo: exceptioninfoty;
 cpu: cputy;
 {
 mainstackpo: pointer;
 framepo: pointer;
 stacklink: pointer;
 oppo: popinfoty;
}
 startpo: popinfoty;
// globdata: pointer;
// constdata: pointer;

 segments: array[segmentty] of segmentrangety;
 
procedure internalerror(const atext: string);
begin
 raise exception.create('Internal error '+atext);
end;
 
function getsegaddress(const aaddress: segdataaddressty): pointer; 
                                  {$ifdef mse_inline}inline;{$endif}
begin
 result:= segments[aaddress.a.segment].basepo + 
                              aaddress.a.address + aaddress.offset;
end;

function getsegaddressindi(const aaddress: segdataaddressty): pointer;
                                  {$ifdef mse_inline}inline;{$endif}
begin
 result:= ppointer(segments[aaddress.a.segment].basepo + 
                              aaddress.a.address)^ + aaddress.offset;
end;

function alignsize(const size: ptruint): ptruint; 
                             {$ifdef mse_inline}inline;{$endif}
begin
 result:= (size+(alignstep-1)) and alignmask;
end;

function intgetmem(const size: integer): pointer;
begin
 result:= getmem(size);
end;

function intgetnulledmem(const size: integer): pointer;
begin
 result:= getmem(size);
 fillchar(result^,size,0);
end;

function intgetnulledmem(const allocsize: integer;
                           const nullsize: integer): pointer;
begin
 result:= getmem(allocsize);
 fillchar(result^,nullsize,0);
end;

procedure intfreemem(const mem: pointer);
begin
 freemem(mem);
end;

function stackoffs(const offs: ptruint; const size: ptruint): pointer;
                                          {$ifdef mse_inline}inline;{$endif}
begin
 result:= cpu.stack + offs;
 if (result < mainstack) or (result >= mainstackend) or 
           (result+size < mainstack) or (result+size > mainstackend) then begin
  raise exception.create('Interpreter AV');
 end;
end;

function stacktop(const size: ptruint): pointer; 
                                      {$ifdef mse_inline}inline;{$endif}
begin
 result:= cpu.stack-alignsize(size);
end;

procedure avexception;
begin
 raise exception.create('Interpreter AV');
end;

function stackpush(const size: ptruint): pointer; 
                                       {$ifdef mse_inline}inline;{$endif}
begin
 result:= cpu.stack;
 cpu.stack:= cpu.stack + alignsize(size);
 if (cpu.stack < mainstack) or (cpu.stack > mainstackend) then begin
  avexception;
 end; 
end;

function stackpushnoalign(const size: ptruint): pointer; 
                                        {$ifdef mse_inline}inline;{$endif}
begin
 result:= cpu.stack;
 cpu.stack:= cpu.stack + size;
 if (cpu.stack < mainstack) or (cpu.stack > mainstackend) then begin
  avexception;
 end; 
end;

function stackpop(const size: ptruint): pointer; 
                                        {$ifdef mse_inline}inline;{$endif}
begin
 cpu.stack:= cpu.stack - alignsize(size);
 result:= cpu.stack;
 if (cpu.stack < mainstack) or (cpu.stack > mainstackend) then begin
  avexception;
 end; 
end;

procedure movesegreg0op();
begin
 ppointer(stackpush(sizeof(pointer)))^:= reg0;
 reg0:= segments[cpu.pc^.par.vsegment].basepo;
end;

procedure moveframereg0op();
begin
 ppointer(stackpush(sizeof(pointer)))^:= reg0;
 reg0:= cpu.frame;
end;

procedure popreg0op();
begin
 reg0:= ppointer(stackpop(sizeof(pointer)))^;
end;

procedure increg0op();
begin
 inc(reg0,cpu.pc^.par.imm.voffset);
end;

procedure nop();
begin
 //dummy
end;

procedure gotoop();
begin
 cpu.pc:= startpo + cpu.pc^.par.opaddress;
end;

procedure beginparseop();
begin
 gotoop();
end;

procedure endparseop();
begin
 //dummy
end;

procedure cmpjmpneimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ <> ordimm.vint32 then begin
   cpu.pc:= startpo + immgoto;
  end;
 end;
end;

procedure cmpjmpeqimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ = ordimm.vint32 then begin
   cpu.pc:= startpo + immgoto;
  end;
 end;
end;

procedure cmpjmploimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ < ordimm.vint32 then begin
   cpu.pc:= startpo + immgoto;
  end;
 end;
end;

procedure cmpjmploeqimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ <= ordimm.vint32 then begin
   cpu.pc:= startpo + immgoto;
  end;
 end;
end;

procedure cmpjmpgtimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ > ordimm.vint32 then begin
   cpu.pc:= startpo + immgoto;
  end;
 end;
end;

procedure ifop();
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress;
 end;
end;

procedure writebooleanop();
begin
 write(vbooleanty((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writeintegerop();
begin
 write(vintegerty((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writefloatop();
begin
 write(vfloatty((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writestring8op();
var
 po1: pointer;
 po2: pstring8headerty;
 str1: string;
begin
 po1:= pointer((cpu.stack+cpu.pc^.par.voffset)^);
 if po1 <> nil then begin
  po2:= po1-sizeof(string8headerty);
  setlength(str1,po2^.len);
  move(po1^,pointer(str1)^,po2^.len);
  write(str1);
 end;
end;

procedure writeclassop();
begin
 write(hextostr(vpointerty((cpu.stack+cpu.pc^.par.voffset)^)));
end;

procedure writeenumop();
begin
 write(getenumname(vintegerty((cpu.stack+cpu.pc^.par.voffset)^),
                           segments[seg_rtti].basepo+cpu.pc^.par.voffsaddress));
end;

procedure writelnop();
begin
 writeln();
end;

(*
procedure writelnop;
var
 int1,int2,int3: integer;
 po1,po2: pointer;
 po3: pdatakindty;
 str1: string;
 po4: pstring8headerty;
begin
 dec(cpu.stack,cpu.pc^.par.paramcount*sizeof(datakindty));
 po3:= cpu.stack; //start of data kinds
 po2:= po3;
 dec(cpu.stack,cpu.pc^.par.paramsize);
 po1:= cpu.stack; //start of params
 while po1 < po2 do begin
  case po3^ of
   dk_boolean: begin
    write(vbooleanty(po1^));
    inc(po1,alignsize(sizeof(vbooleanty)));
   end;
   dk_integer: begin
    write(vintegerty(po1^));
    inc(po1,alignsize(sizeof(vintegerty)));
   end;
   dk_float: begin
    write(vfloatty(po1^));
    inc(po1,alignsize(sizeof(vfloatty)));
   end;
   dk_string8: begin
    po4:= pointer(po1^);
    if po4 <> nil then begin
     po4:= pointer(po4)-sizeof(string8headerty);
     setlength(str1,po4^.len);
     move(vpointerty(po1^)^,pointer(str1)^,po4^.len);
     write(str1);
    end;
    inc(po1,alignsize(sizeof(vpointerty)));
   end;
   dk_class: begin
    write(hextostr(vpointerty(po1^),8));
    inc(po1,alignsize(sizeof(vpointerty)));
   end;
   else begin
    internalerror('I20131210A');
   end;
  end;
  inc(po3);
 end;
 writeln;
{ 
 int1:= mainstack[cpu.stack].vinteger;
 int3:= cpu.stack-int1;
 int2:= int3-int1;
 while int2 < int3 do begin
  case mainstack[int2+int1].vdatakind of
   dk_boolean: begin
    write(mainstack[int2].vboolean);
   end;
   dk_integer: begin
    write(mainstack[int2].vinteger);
   end;
   dk_float: begin
    write(mainstack[int2].vfloat);
   end;
  end;
  int2:= int2 + 1;
 end;
 writeln;
 cpu.stack:= cpu.stack-2*int1-1;
}
end;
*)

procedure pushop();
begin
 stackpush(cpu.pc^.par.imm.vsize);
end;

procedure popop();
begin
 stackpop(cpu.pc^.par.imm.vsize);
end;

procedure push8op();
begin
 pv8ty(stackpush(1))^:= cpu.pc^.par.vpush.v8; 
end;

procedure push16op();
begin
 pv16ty(stackpush(2))^:= cpu.pc^.par.vpush.v16; 
end;

procedure push32op();
begin
 pv32ty(stackpush(4))^:= cpu.pc^.par.vpush.v32; 
end;

procedure push64op();
begin
 pv64ty(stackpush(8))^:= cpu.pc^.par.vpush.v64; 
end;

procedure pushdatakindop();
begin
 vdatakindty(stackpushnoalign(sizeof(vdatakindty))^):= 
                                       cpu.pc^.par.vpush.vdatakind; 
end;

procedure int32toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 vfloatty(stackpush(sizeof(vfloatty))^):= vintegerty(po1^);
end;

procedure mulint32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^)*vintegerty(po1^);
end;

procedure mulimmint32op();
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)*cpu.pc^.par.imm.vint32;
end;

procedure mulflo64op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= po1-alignsize(sizeof(vfloatty));
 vfloatty(po2^):= vfloatty(po2^)*vfloatty(po1^);
end;

procedure addint32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^)+vintegerty(po1^);
end;

procedure addimmint32op();
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)+cpu.pc^.par.imm.vint32;
end;

procedure offsetpoimm32op();
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vpointerty));
 vpointerty(po1^):= vpointerty(po1^)+cpu.pc^.par.imm.vint32;
end;

procedure cmpequboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ = po1^;
end;

procedure cmpequint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure cmpequflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure addflo64op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= po1-alignsize(sizeof(vfloatty));
 vfloatty(po2^):= vfloatty(po2^)+vfloatty(po1^);
end;

procedure negcard32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vcardinalty));
 vcardinalty(po1^):= -vcardinalty(po1^);
end;

procedure negint32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vintegerty));
 vintegerty(po1^):= -vintegerty(po1^);
end;

procedure negflo64op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vfloatty));
 vfloatty(po1^):= -vfloatty(po1^);
end;

procedure pushnilop();
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= nil;
end;

procedure pushsegaddressop();
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= 
                                    getsegaddress(cpu.pc^.par.vsegaddress); 
end;

procedure storesegnilop();
begin
 ppointer(getsegaddress(cpu.pc^.par.vsegaddress))^:= nil;
end;

procedure storeframenilop();
begin
 ppointer(cpu.frame+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storereg0nilop();
begin
 ppointer(reg0+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storestacknilop();
begin
 ppointer(cpu.stack+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storestackrefnilop();
begin
 pppointer(cpu.stack+cpu.pc^.par.vaddress)^^:= nil;
end;

procedure storesegnilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(getsegaddress(par.segdataaddress)^,par.datasize,0);
{$else}
  filldword(getsegaddress(par.segdataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storeframenilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(cpu.frame+par.podataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(cpu.frame+par.podataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storereg0nilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(reg0+par.podataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(reg0+par.podataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storestacknilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(cpu.stack+par.podataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(cpu.stack+par.podataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storestackrefnilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(pppointer(cpu.stack+par.podataaddress)^^,par.datasize,0);
{$else}
  filldword(pppointer(cpu.stack+par.podataaddress)^^,par.datasize,0);
{$endif}
 end;
end;

procedure popseg8op();
begin
 puint8(getsegaddress(cpu.pc^.par.segdataaddress))^:= puint8(stackpop(1))^;
end;

procedure popseg16op();
begin
 puint16(getsegaddress(cpu.pc^.par.segdataaddress))^:= puint16(stackpop(2))^;
end;

procedure popseg32op();
begin
 puint32(getsegaddress(cpu.pc^.par.segdataaddress))^:= puint32(stackpop(4))^;
end;

procedure popsegop();
begin
 move(stackpop(cpu.pc^.par.datasize)^,
      getsegaddress(cpu.pc^.par.segdataaddress)^,cpu.pc^.par.datasize);
end;

procedure pushseg8op();
begin
 pv8ty(stackpush(1))^:= pv8ty(getsegaddress(cpu.pc^.par.segdataaddress))^;
end;

procedure pushseg16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getsegaddress(cpu.pc^.par.segdataaddress))^;
end;

procedure pushseg32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getsegaddress(cpu.pc^.par.segdataaddress))^;
end;

procedure pushsegop();
begin
 move(getsegaddress(cpu.pc^.par.segdataaddress)^,
                  stackpush(cpu.pc^.par.datasize)^,cpu.pc^.par.datasize);
end;

//todo: make special locvar access funcs for inframe variables
//and loop unroll

function getlocaddress(const aaddress: locdataaddressty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 if aaddress.a.framelevel < 0 then begin
  result:= cpu.frame + aaddress.a.address + aaddress.offset;
 end
 else begin
  po1:= cpu.stacklink;
  for i1:= aaddress.a.framelevel downto 0 do begin
   po1:= frameinfoty((po1-sizeof(frameinfoty))^).link;
  end;
  result:= po1 + aaddress.a.address + aaddress.offset;
 end;
end;

function getlocaddressindi(const aaddress: locdataaddressty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 if aaddress.a.framelevel < 0 then begin
  result:= ppointer(cpu.frame + aaddress.a.address)^ + aaddress.offset;
 end
 else begin
  po1:= cpu.stacklink;
  for i1:= aaddress.a.framelevel downto 0 do begin
   po1:= frameinfoty((po1-sizeof(frameinfoty))^).link;
  end;
  result:= ppointer(po1 + aaddress.a.address)^ + aaddress.offset;
 end;
end;

procedure poploc8op();
begin             
 pv8ty(getlocaddress(cpu.pc^.par.locdataaddress))^:= pv8ty(stackpop(1))^;
end;

procedure poploc16op();
begin
 pv16ty(getlocaddress(cpu.pc^.par.locdataaddress))^:= pv16ty(stackpop(2))^;
end;

procedure poploc32op();
begin
 pv32ty(getlocaddress(cpu.pc^.par.locdataaddress))^:= pv32ty(stackpop(4))^;
end;

procedure poplocop();
begin
 move(stackpop(cpu.pc^.par.datasize)^,
       getlocaddress(cpu.pc^.par.locdataaddress)^,cpu.pc^.par.datasize);
end;

procedure poplocindi8op();
begin             
 pv8ty(getlocaddressindi(cpu.pc^.par.locdataaddress))^:= pv8ty(stackpop(1))^;
end;

procedure poplocindi16op();
begin
 pv16ty(getlocaddressindi(cpu.pc^.par.locdataaddress))^:= pv16ty(stackpop(2))^;
end;

procedure poplocindi32op();
begin
 pv32ty(getlocaddressindi(cpu.pc^.par.locdataaddress))^:= pv32ty(stackpop(4))^;
end;

procedure poplocindiop();
begin
 move(stackpop(cpu.pc^.par.datasize)^,
      getlocaddressindi(cpu.pc^.par.locdataaddress)^,cpu.pc^.par.datasize);
end;

procedure pushloc8op();
begin
 pv8ty(stackpush(1))^:= pv8ty(getlocaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushloc16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getlocaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushloc32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getlocaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushlocpoop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                    ppointer(getlocaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushlocop();
begin
 move(getlocaddress(cpu.pc^.par.locdataaddress)^,stackpush(cpu.pc^.par.datasize)^,
                                                   cpu.pc^.par.datasize);
end;

procedure pushlocindi8op();
begin
 pv8ty(stackpush(1))^:= pv8ty(getlocaddressindi(cpu.pc^.par.locdataaddress))^;
end;

procedure pushlocindi16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getlocaddressindi(cpu.pc^.par.locdataaddress))^;
end;

procedure pushlocindi32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getlocaddressindi(cpu.pc^.par.locdataaddress))^;
end;

procedure pushlocindiop();
begin
 move(getlocaddressindi(cpu.pc^.par.locdataaddress)^,
               stackpush(cpu.pc^.par.datasize)^,cpu.pc^.par.datasize);
end;

procedure pushaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= pointer(cpu.pc^.par.imm.vpointer);
end;

procedure pushlocaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= getlocaddress(cpu.pc^.par.vlocaddress);
end;

procedure pushlocaddrindiop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                           getlocaddressindi(cpu.pc^.par.vlocaddress);
end;

procedure pushsegaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
               getsegaddress(cpu.pc^.par.segdataaddress);
end;

procedure pushsegaddrindiop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
               getsegaddressindi(cpu.pc^.par.segdataaddress);
end;

procedure pushstackaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= cpu.stack+cpu.pc^.par.voffset;
end;

procedure pushstackaddrindiop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
        ppointer(cpu.stack+cpu.pc^.par.voffset)^+cpu.pc^.par.voffsaddress;
end;

procedure indirect8op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv8ty(po1)^:=  pv8ty(ppointer(po1)^)^;
end;

procedure indirect16op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv16ty(po1)^:=  pv16ty(ppointer(po1)^)^;
end;

procedure indirect32op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv32ty(po1)^:=  pv32ty(ppointer(po1)^)^;
end;

procedure indirectpoop();
var
 po1: pointer;
begin
 po1:= cpu.stack-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^;
end;

procedure indirectpooffsop();
var
 po1: pointer;
begin
 po1:= cpu.stack-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^+cpu.pc^.par.voffset;
end;

procedure indirectoffspoop();
var
 po1: pointer;
begin
 po1:= cpu.stack-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^+cpu.pc^.par.voffset)^;
end;

procedure indirectop();
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,stackpush(cpu.pc^.par.datasize)^,cpu.pc^.par.datasize);
end;

procedure popindirect8op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(1);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv8ty(po2)^:= pv8ty(po1)^;
end;

procedure popindirect16op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(2);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv16ty(po2)^:= pv16ty(po1)^;
end;

procedure popindirect32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(4);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv32ty(po2)^:= pv32ty(po1)^;
end;

procedure popindirectop();
var
 po1,po2: pointer;
begin
 po1:= stackpop(cpu.pc^.par.datasize);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,po2^,cpu.pc^.par.datasize);
end;

//first op:
//                  |cpu.frame    |cpu.stack
// params frameinfo locvars      
//
procedure callop();
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
 cpu.pc:= startpo+cpu.pc^.par.callinfo.ad;
end;

procedure calloutop();
var
 i1: integer;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
 
 for i1:= cpu.pc^.par.callinfo.linkcount downto 0 do begin
  cpu.stacklink:= frameinfoty((cpu.stacklink-sizeof(frameinfoty))^).link;
 end;
 cpu.frame:= cpu.stack;
 cpu.pc:= startpo+cpu.pc^.par.callinfo.ad;
end;

procedure callvirtop();
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
 with cpu.pc^.par.virtcallinfo do begin
  cpu.pc:= startpo+pptruint(pppointer(cpu.stack+selfinstance)^^+virtoffset)^;
//  cpu.pc:= startpo+ptruint(ppppointer(cpu.stack+selfinstance)^^[virtindex]); 
 end;
end;

procedure callintfop();
var
 po1: ppointer;
 po2: pintfitemty;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
 with cpu.pc^.par.virtcallinfo do begin
  po1:= cpu.stack + selfinstance;
  po2:= segments[seg_intf].basepo + pptrint(po1^)^;
  inc(po1^,po2^.instanceshift);
  cpu.pc:= startpo + po2^.subad;
 end;
end;

procedure virttrampolineop();
begin
 with cpu.pc^.par.virttrampolineinfo do begin
  cpu.pc:= startpo+pptruint(pppointer(cpu.frame+selfinstance)^^+virtoffset)^;
 end;
end;

procedure locvarpushop();
begin
 stackpush(cpu.pc^.par.stacksize);
end;

procedure locvarpopop();
begin
 stackpop(cpu.pc^.par.stacksize);
end;

procedure returnop();
var
 int1: integer;
begin
 int1:= cpu.pc^.par.stacksize;
 with frameinfoty((cpu.frame-sizeof(frameinfoty))^) do begin
  cpu.pc:= pc;
  cpu.frame:= frame;
  cpu.stacklink:= link;
 end;
 cpu.stack:= cpu.stack-int1;
end;

procedure initclassop();
var
 po1: pointer;
 po2: pclassdefinfoty;
 self1: ppointer;
 ps,pd,pe: popaddressty;
begin
 with cpu.pc^.par do begin
//  po2:= pclassdefinfoty(initclass.classdef+constdata);
  self1:= cpu.frame+initclass.selfinstance;
  po2:= self1^;  //class type
  po1:= intgetnulledmem(po2^.header.allocsize,po2^.header.fieldsize);
  ppointer(po1)^:= po2;    //class type info
  self1^:= po1;            //class instance
  pppointer(cpu.frame+initclass.result)^^:= po1; //result

  pd:= po1 + po2^.header.fieldsize; //copy interface table
  pe:= po1 + po2^.header.allocsize;
  ps:= (pointer(po2)+po2^.header.interfacestart);
  while pd < pe do begin
   pd^:= ps^;
   inc(pd);
   inc(ps);
  end;
 end;
end;

procedure destroyclassop();
begin
 with cpu.pc^.par do begin
  intfreemem(ppointer(cpu.frame+destroyclass.selfinstance)^);
 end;
end;

procedure decloop32op();
var
 po1: pinteger;
begin
 po1:= pinteger(cpu.stack-4);
 dec(po1^);
 if po1^ < 0 then begin
  cpu.pc:= startpo+cpu.pc^.par.opaddress;
 end;
end;

procedure decloop64op();
var
 po1: pint64;
begin
 po1:= pint64(cpu.stack-8);
 dec(po1^);
 if po1^ < 0 then begin
  cpu.pc:= startpo+cpu.pc^.par.opaddress;
 end;
end;

procedure finirefsize(const ref: ppointer); 
                         {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
begin
 d:= ref^;
 if d <> nil then begin
  dec(d);
  if d^.ref.count > 0 then begin
   dec(d^.ref.count);
   if d^.ref.count = 0 then begin
    freemem(d);
   end;
   ref^:= nil;
  end;
 end;
end;

procedure finiclass(const ref: ppointer); 
                         {$ifdef mse_inline}inline;{$endif}
//todo: call destroy
begin
 intfreemem(ref^);
end;

procedure finirefsizear(ref: ppointer; const count: datasizety); 
                                    {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
 si1: datasizety;
begin
 for si1:= count-1 downto 0 do begin
  d:= ref^;
  if d <> nil then begin
   dec(d);
   if d^.ref.count > 0 then begin
    dec(d^.ref.count);
    if d^.ref.count = 0 then begin
     freemem(d);
    end;
    ref^:= nil;
   end;
  end;
  inc(ref);
 end;
end;

procedure increfsize(const ref: ppointer); {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
begin
 d:= ref^;
 if d <> nil then begin
  dec(d);
  if d^.ref.count > 0 then begin
   inc(d^.ref.count);
  end;
 end;
end;

procedure increfsizear(ref: ppointer; const count: datasizety); 
                                           {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
 si1: datasizety;
begin
 for si1:= count-1 downto 0 do begin
  d:= ref^;
  if d <> nil then begin
   dec(d);
   if d^.ref.count > 0 then begin
    inc(d^.ref.count);
   end;
  end;
  inc(ref);
 end;
end;

procedure decrefsize(const ref: ppointer); {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
begin
 d:= ref^;
 if d <> nil then begin
  dec(d);
  if d^.ref.count > 0 then begin
   dec(d^.ref.count);
   if d^.ref.count = 0 then begin
    freemem(d);
   end;
   ref^:= nil;
  end;
 end;
end;

procedure decrefsizear(ref: ppointer; const count: datasizety); 
                                           {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
 si1: datasizety;
begin
 for si1:= count-1 downto 0 do begin
  d:= ref^;
  if d <> nil then begin
   dec(d);
   if d^.ref.count > 0 then begin
    dec(d^.ref.count);
    if d^.ref.count = 0 then begin
     freemem(d);
    end;
    ref^:= nil;
   end;
  end;
  inc(ref);
 end;
end;

procedure finirefsizesegop();
begin
 finirefsize(getsegaddress(cpu.pc^.par.vsegaddress));
end;

procedure finirefsizeframeop();
begin
 finirefsize(ppointer(cpu.frame+cpu.pc^.par.vaddress));
end;

procedure finirefsizereg0op();
begin
 finirefsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure finirefsizestackop();
begin
 finirefsize(ppointer(cpu.stack+cpu.pc^.par.vaddress));
end;

procedure finirefsizestackrefop();
begin
 finirefsize(pppointer(cpu.stack+cpu.pc^.par.vaddress)^);
end;

procedure finirefsizesegarop();
begin
 finirefsizear(getsegaddress(cpu.pc^.par.segdataaddress),cpu.pc^.par.datasize);
end;

procedure finirefsizeframearop();
begin
 finirefsizear(ppointer(cpu.frame+cpu.pc^.par.podataaddress),
                                                       cpu.pc^.par.datasize);
end;

procedure finirefsizereg0arop();
begin
 finirefsizear(ppointer(reg0+cpu.pc^.par.podataaddress),cpu.pc^.par.datasize);
end;

procedure finirefsizestackarop();
begin
 finirefsizear(ppointer(cpu.stack+cpu.pc^.par.podataaddress),
                                                    cpu.pc^.par.datasize);
end;

procedure finirefsizestackrefarop();
begin
 finirefsizear(pppointer(cpu.stack+cpu.pc^.par.podataaddress)^,
                                                   cpu.pc^.par.datasize);
end;

procedure increfsizesegop();
begin
 increfsize(getsegaddress(cpu.pc^.par.vsegaddress));
end;

procedure increfsizeframeop();
begin
 increfsize(ppointer(cpu.frame+cpu.pc^.par.vaddress));
end;

procedure increfsizereg0op();
begin
 increfsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure increfsizestackop();
begin
 increfsize(ppointer(cpu.stack+cpu.pc^.par.vaddress));
end;

procedure increfsizestackrefop();
begin
 increfsize(pppointer(cpu.stack+cpu.pc^.par.vaddress)^);
end;

procedure increfsizesegarop();
begin
 increfsizear(getsegaddress(cpu.pc^.par.segdataaddress),
                                             cpu.pc^.par.datasize);
end;

procedure increfsizeframearop();
begin
 increfsizear(ppointer(cpu.frame+cpu.pc^.par.podataaddress),
                                             cpu.pc^.par.datasize);
end;

procedure increfsizereg0arop();
begin
 increfsizear(ppointer(reg0+cpu.pc^.par.podataaddress),cpu.pc^.par.datasize);
end;

procedure increfsizestackarop();
begin
 increfsizear(ppointer(cpu.stack+cpu.pc^.par.podataaddress),
                                                        cpu.pc^.par.datasize);
end;

procedure increfsizestackrefarop();
begin
 increfsizear(pppointer(cpu.stack+cpu.pc^.par.podataaddress)^,
                                                          cpu.pc^.par.datasize);
end;

procedure decrefsizesegop();
begin
 decrefsize(getsegaddress(cpu.pc^.par.vsegaddress));
end;

procedure decrefsizeframeop();
begin
 decrefsize(ppointer(cpu.frame+cpu.pc^.par.vaddress));
end;

procedure decrefsizereg0op();
begin
 decrefsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure decrefsizestackop();
begin
 decrefsize(ppointer(cpu.stack+cpu.pc^.par.vaddress));
end;

procedure decrefsizestackrefop();
begin
 decrefsize(pppointer(mainstack+cpu.pc^.par.vaddress)^);
end;

procedure decrefsizesegarop();
begin
 decrefsizear(getsegaddress(cpu.pc^.par.segdataaddress),
                                                  cpu.pc^.par.datasize);
end;

procedure decrefsizeframearop();
begin
 decrefsizear(ppointer(cpu.frame+cpu.pc^.par.podataaddress),
                                                cpu.pc^.par.datasize);
end;

procedure decrefsizereg0arop();
begin
 decrefsizear(ppointer(reg0+cpu.pc^.par.podataaddress),cpu.pc^.par.datasize);
end;

procedure decrefsizestackarop();
begin
 decrefsizear(ppointer(cpu.stack+cpu.pc^.par.podataaddress),cpu.pc^.par.datasize);
end;

procedure decrefsizestackrefarop();
begin
 decrefsizear(pppointer(cpu.stack+cpu.pc^.par.podataaddress)^,
                                                          cpu.pc^.par.datasize);
end;

procedure setlengthstr8op(); //address, length
var
 si1,si2: stringsizety;
 ds,ss: pstring8headerty;
 ad: ppointer;
begin
 si1:= pstringsizety(cpu.stack-sizeof(stringsizety))^;
 ad:= ppointer(cpu.stack-(sizeof(stringsizety)+sizeof(pointer)))^;
 ds:= ad^;   //data
 if ds <> nil then begin
  dec(ds);    //header
 end;
 if si1 <= 0 then begin
  if ds <> nil then begin
   dec(ds^.ref.count);
   if ds^.ref.count = 0 then begin
    freemem(ds);
   end;
   ad^:= nil;
  end;
 end
 else begin
  if ds = nil then begin
   getmem(ds,si1+string8allocsize);
  end
  else begin
   if ds^.ref.count = 1 then begin
    reallocmem(ds,si1+string8allocsize);
   end
   else begin //needs copy
    ss:= ds;
    getmem(ds,si1+string8allocsize);
    si2:= ss^.len;
    if si1 < si2 then begin
     si2:= si1;
    end;
    move((ss+1)^,(ds+1)^,si2); //get data copy
   end;
  end;
  ds^.len:= si1;
  ds^.ref.count:= 1;
  inc(ds);    //data
  (pchar8(ds)+si1)^:= #0; //endmarker
  ad^:= ds;
 end;
 stackpop(pointersize+sizeof(stringsizety));
end;

const
 stopop: opinfoty = (op: (proc:nil; flags:[]); par:(dummy:()));

procedure unhandledexception(const exceptobj: pointer);
begin
 writeln('An unhandled exception occured at $'+hextostr(cpu.pc));
 finiclass(@exceptobj);
 cpu.pc:= @stopop;
 dec(cpu.pc);
end;

procedure raiseop();
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(pointersize))^;
 with exceptioninfo do begin
  if exceptobj <> nil then begin
   finiclass(@exceptioninfo.exceptobj);
  end;
  exceptobj:= po1;
  if trystack <> nil then begin
   cpu:= trystack^.cpu;
  end
  else begin
   unhandledexception(po1);
  end;
 end;
end;
 
procedure pushcpucontextop(); //todo: don't use push/pop stack
var
 po1: pjumpinfoty;
begin
 po1:= stackpush(sizeof(jumpinfoty));
 po1^.cpu:= cpu;
 po1^.cpu.pc:= startpo + cpu.pc^.par.opaddress;
 po1^.next:= exceptioninfo.trystack;
 exceptioninfo.trystack:= po1;
end;

procedure popcpucontextop();
var
 po1: pjumpinfoty;
begin
 po1:= stackpop(sizeof(jumpinfoty));
 exceptioninfo.trystack:= po1^.next;
{
 trystack:= po1^.next;
 currentexception:= po1^.exceptobj
 if po1^.exceptobj <> nil then begin
  if trystack = nil then begin
   unhandledexception(po1^.exceptobj);
  end
  else begin
   trystack^.exceptobj:= po1^.exceptobj; //todo: check existing exception
   cpu:= trystack^.cpu;
  end;
 end;
}
end;

procedure finiexceptionop();
begin
 with exceptioninfo do begin
  if exceptobj <> nil then begin
   finiclass(@exceptioninfo.exceptobj);
   exceptobj:= nil;  
  end;
 end;
end;

procedure continueexceptionop();
begin
 with exceptioninfo do begin
  if exceptobj <> nil then begin
   if trystack = nil then begin
    unhandledexception(exceptobj);
   end
   else begin
    cpu:= trystack^.cpu;
   end;
  end;
 end;
end;

{
procedure pophandlecpucontext();
var
 po1: pjumpinfoty;
begin
 po1:= stackpop(sizeof(jumpinfoty));
 trystack:= po1^.next;
 if po1^.exceptobj <> nil then begin
  finiclass(@po1^.exceptobj);
 end;
end;
}

procedure run(const asegments: segmentbuffersty);
var
 seg1: segmentty;
begin
 for seg1:= low(segmentty) to high(segmentty) do begin
  segments[seg1].basepo:= asegments[seg1].base;
  segments[seg1].endpo:= segments[seg1].basepo+asegments[seg1].size;
 end;
 fillchar(cpu,sizeof(cpu),0);
 reg0:= nil;
 fillchar(exceptioninfo,sizeof(exceptioninfo),0);
 cpu.stack:= segments[seg_stack].basepo;
 mainstack:= cpu.stack;
 mainstackend:= segments[seg_stack].endpo;
 startpo:= segments[seg_op].basepo;
 cpu.pc:= startpo;
 with segments[seg_globvar] do begin
  fillchar(basepo^,endpo-basepo,0);
 end;
// constdata:= segments[seg_globconst].basepo;
 inc(cpu.pc,startupoffset);
 while cpu.pc^.op.proc <> nil do begin
  cpu.pc^.op.proc;
  inc(cpu.pc);
 end;
end;

var
 globdata: pointer;
 
procedure run({const code: opinfoarty; const constseg: pointer;}
                                        const stackdepht: integer);
var
 segs: segmentbuffersty;
 seg1: segmentty;
begin
// trystack:= nil;
// exceptobj:= nil;
 for seg1:= low(seg1) to high(seg1) do begin //defaults
  segs[seg1].base:= getsegmentbase(seg1); 
  segs[seg1].size:= getsegmentsize(seg1);
 end;

 reallocmem(mainstack,stackdepht);
 segs[seg_stack].base:= mainstack;
 segs[seg_stack].size:= stackdepht;
 with pstartupdataty(segs[seg_op].base)^ do begin
  reallocmem(globdata,globdatasize);
  segs[seg_globvar].base:= globdata;
  segs[seg_globvar].size:= globdatasize;
 end;
 run(segs);
end;

{
procedure run(const code: opinfoarty; const constseg: pointer;
                                        const stackdepht: integer);
var
 endpo: popinfoty;
begin
 fillchar(cpu,sizeof(cpu),0);
 reg0:= nil;
 fillchar(exceptioninfo,sizeof(exceptioninfo),0);
// trystack:= nil;
// exceptobj:= nil;
 reallocmem(mainstack,stackdepht);
 cpu.stack:= mainstack;
 mainstackend:= cpu.stack + stackdepht;
 startpo:= pointer(code);
 cpu.pc:= startpo;
 endpo:= cpu.pc+length(code);
 with pstartupdataty(cpu.pc)^ do begin
  reallocmem(globdata,globdatasize);
  fillchar(globdata^,globdatasize,0);
 end;
 constdata:= constseg;
 inc(cpu.pc,startupoffset);
 while cpu.pc^.op <> nil do begin
  cpu.pc^.op;
  inc(cpu.pc);
 end;
end;
}

const
 stackoptable: optablety = (
  nil,
  @nop,

  @beginparseop,
  nil, //oc_progend
  @endparseop,

  @movesegreg0op,
  @moveframereg0op,
  @popreg0op,
  @increg0op,

  @gotoop,
  @cmpjmpneimm4op,
  @cmpjmpeqimm4op,
  @cmpjmploimm4op,
  @cmpjmpgtimm4op,
  @cmpjmploeqimm4op,

  @ifop,
  @writelnop,
  @writebooleanop,
  @writeintegerop,
  @writefloatop,
  @writestring8op,
  @writeclassop,
  @writeenumop,

  @pushop,
  @popop,

  @push8op,
  @push16op,
  @push32op,
  @push64op,

  @pushdatakindop,
  @int32toflo64op,
  @mulint32op,
  @mulimmint32op,
  @mulflo64op,
  @addint32op,
  @addimmint32op,
  @addflo64op,
  @negcard32op,
  @negint32op,
  @negflo64op,

  @offsetpoimm32op,

  @cmpequboolop,
  @cmpequint32op,
  @cmpequflo64op,

  @storesegnilop,
  @storereg0nilop,
  @storeframenilop,
  @storestacknilop,
  @storestackrefnilop,
  @storesegnilarop,
  @storeframenilarop,
  @storereg0nilarop,
  @storestacknilarop,
  @storestackrefnilarop,

  @finirefsizesegop,
  @finirefsizeframeop,
  @finirefsizereg0op,
  @finirefsizestackop,
  @finirefsizestackrefop,
  @finirefsizeframearop,
  @finirefsizesegarop,
  @finirefsizereg0arop,
  @finirefsizestackarop,
  @finirefsizestackrefarop,

  @increfsizesegop,
  @increfsizeframeop,
  @increfsizereg0op,
  @increfsizestackop,
  @increfsizestackrefop,
  @increfsizeframearop,
  @increfsizesegarop,
  @increfsizereg0arop,
  @increfsizestackarop,
  @increfsizestackrefarop,

  @decrefsizesegop,
  @decrefsizeframeop,
  @decrefsizereg0op,
  @decrefsizestackop,
  @decrefsizestackrefop,
  @decrefsizeframearop,
  @decrefsizesegarop,
  @decrefsizereg0arop,
  @decrefsizestackarop,
  @decrefsizestackrefarop,

  @popseg8op,
  @popseg16op,
  @popseg32op,
  @popsegop,

  @poploc8op,
  @poploc16op,
  @poploc32op,
  @poplocop,

  @poplocindi8op,
  @poplocindi16op,
  @poplocindi32op,
  @poplocindiop,

  @pushnilop,
  @pushsegaddressop,

  @pushseg8op,
  @pushseg16op,
  @pushseg32op,
  @pushsegop,

  @pushloc8op,
  @pushloc16op,
  @pushloc32op,
  @pushlocpoop,
  @pushlocop,

  @pushlocindi8op,
  @pushlocindi16op,
  @pushlocindi32op,
  @pushlocindiop,

  @pushaddrop,
  @pushlocaddrop,
  @pushlocaddrindiop,
  @pushsegaddrop,
  @pushsegaddrindiop,
  @pushstackaddrop,
  @pushstackaddrindiop,

  @indirect8op,
  @indirect16op,
  @indirect32op,
  @indirectpoop,
  @indirectpooffsop, //offset after indirect
  @indirectoffspoop, //offset before indirect
  @indirectop,

  @popindirect8op,
  @popindirect16op,
  @popindirect32op,
  @popindirectop,

  @callop,
  @calloutop,
  @callvirtop,
  @callintfop,
  @virttrampolineop,

  @locvarpushop,
  @locvarpopop,
  @returnop,

  @initclassop,
  @destroyclassop,

  @decloop32op,
  @decloop64op,

  @setlengthstr8op,

  @raiseop,
  @pushcpucontextop,
  @popcpucontextop,
  @finiexceptionop,
  @continueexceptionop
 );


function getoptable: poptablety;
begin
 result:= @stackoptable;
end;

procedure allocproc(const asize: integer; var address: segaddressty);
begin
 //dummy
end;

procedure finalize;
begin
 if mainstack <> nil then begin
  freemem(mainstack);
  mainstack:= nil;
 end;
 if globdata <> nil then begin
  freemem(globdata);
  globdata:= nil;
 end;
end;

finalization
 finalize;
end.
