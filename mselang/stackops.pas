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
 parserglob;

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

function alignsize(const size: ptruint): ptruint; 
                         {$ifdef mse_inline}inline;{$endif}

procedure finalize;
procedure run(const code: opinfoarty; const constseg: pointer;
                                    const stackdepht: integer);

//procedure dummyop;
procedure moveglobalreg0();
procedure moveframereg0();
procedure popreg0();
procedure increg0();

procedure nop();
procedure gotoop();
procedure ifop();
procedure writelnop();

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

procedure cmpequbool();
procedure cmpequint32();
procedure cmpequflo64();

procedure storeglobnil();
procedure storereg0nil();
procedure storeframenil();
procedure storestacknil();
procedure storestackrefnil();
procedure storeglobnilar();
procedure storeframenilar();
procedure storereg0nilar();
procedure storestacknilar();
procedure storestackrefnilar();

procedure finirefsizeglob();
procedure finirefsizeframe();
procedure finirefsizereg0();
procedure finirefsizestack();
procedure finirefsizestackref();
procedure finirefsizeframear();
procedure finirefsizeglobar();
procedure finirefsizereg0ar();
procedure finirefsizestackar();
procedure finirefsizestackrefar();

procedure increfsizeglob();
procedure increfsizeframe();
procedure increfsizereg0();
procedure increfsizestack();
procedure increfsizestackref();
procedure increfsizeframear();
procedure increfsizeglobar();
procedure increfsizereg0ar();
procedure increfsizestackar();
procedure increfsizestackrefar();

procedure decrefsizeglob();
procedure decrefsizeframe();
procedure decrefsizereg0();
procedure decrefsizestack();
procedure decrefsizestackref();
procedure decrefsizeframear();
procedure decrefsizeglobar();
procedure decrefsizereg0ar();
procedure decrefsizestackar();
procedure decrefsizestackrefar();

procedure popglob8();
procedure popglob16();
procedure popglob32();
procedure popglob();

procedure poploc8();
procedure poploc16();
procedure poploc32();
procedure poploc();

procedure poplocindi8();
procedure poplocindi16();
procedure poplocindi32();
procedure poplocindi();

procedure pushconstaddress();

procedure pushglob8();
procedure pushglob16();
procedure pushglob32();
procedure pushglob();

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
procedure pushglobaddr();
procedure pushglobaddrindi();
procedure pushstackaddr();

procedure indirect8();
procedure indirect16();
procedure indirect32();
procedure indirectpo();
procedure indirectpooffs();
procedure indirect();

procedure popindirect8();
procedure popindirect16();
procedure popindirect32();
procedure popindirect();

procedure callop();
procedure calloutop();
procedure callvirtop();
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
procedure pophandlecpucontext();

implementation
uses
 sysutils,handlerglob,mseformatstr,msetypes,internaltypes;
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
  exceptobj: pointer;
//  flags: jumpflagsty;
 end;
 
var                       //todo: threadvar
 mainstack: pointer;
 mainstackend: pointer;
 reg0: pointer;
 trystack: pjumpinfoty;
 cpu: cputy;
 {
 mainstackpo: pointer;
 framepo: pointer;
 stacklink: pointer;
 oppo: popinfoty;
}
 startpo: popinfoty;
 globdata: pointer;
 constdata: pointer;

procedure internalerror(const atext: string);
begin
 raise exception.create('Internal error '+atext);
end;
 
function alignsize(const size: ptruint): ptruint; 
                             {$ifdef mse_inline}inline;{$endif}
begin
 result:= (size+(alignstep-1)) and alignmask;
end;

function intgetnulledmem(const size: integer): pointer;
begin
 result:= getmem(size);
 fillchar(result^,size,0);
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

procedure moveglobalreg0();
begin
 ppointer(stackpush(sizeof(pointer)))^:= reg0;
 reg0:= globdata;
end;

procedure moveframereg0();
begin
 ppointer(stackpush(sizeof(pointer)))^:= reg0;
 reg0:= cpu.frame;
end;

procedure popreg0();
begin
 reg0:= ppointer(stackpop(sizeof(pointer)))^;
end;

procedure increg0();
begin
 inc(reg0,cpu.pc^.par.imm.voffset);
end;

procedure nop();
begin
end;

procedure gotoop();
begin
 cpu.pc:= startpo + cpu.pc^.par.opaddress;
end;

procedure ifop();
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress;
 end;
end;

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

procedure pushop;
begin
 stackpush(cpu.pc^.par.imm.vsize);
end;

procedure popop;
begin
 stackpop(cpu.pc^.par.imm.vsize);
end;

procedure push8;
begin
 pv8ty(stackpush(1))^:= cpu.pc^.par.v8; 
end;

procedure push16;
begin
 pv16ty(stackpush(2))^:= cpu.pc^.par.v16; 
end;

procedure push32;
begin
 pv32ty(stackpush(4))^:= cpu.pc^.par.v32; 
end;

procedure push64;
begin
 pv64ty(stackpush(8))^:= cpu.pc^.par.v64; 
end;

procedure pushdatakind;
begin
 vdatakindty(stackpushnoalign(sizeof(vdatakindty))^):= cpu.pc^.par.vdatakind; 
end;

procedure int32toflo64;
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 vfloatty(stackpush(sizeof(vfloatty))^):= vintegerty(po1^);
end;

procedure mulint32;
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^)*vintegerty(po1^);
end;

procedure mulimmint32;
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)*cpu.pc^.par.imm.vint32;
end;

procedure mulflo64;
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= po1-alignsize(sizeof(vfloatty));
 vfloatty(po2^):= vfloatty(po2^)*vfloatty(po1^);
end;

procedure addint32;
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^)+vintegerty(po1^);
end;

procedure addimmint32;
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)+cpu.pc^.par.imm.vint32;
end;

procedure cmpequbool;
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ = po1^;
end;

procedure cmpequint32;
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure cmpequflo64;
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure addflo64;
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= po1-alignsize(sizeof(vfloatty));
 vfloatty(po2^):= vfloatty(po2^)+vfloatty(po1^);
end;

procedure negcard32;
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vcardinalty));
 vcardinalty(po1^):= -vcardinalty(po1^);
end;

procedure negint32;
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vintegerty));
 vintegerty(po1^):= -vintegerty(po1^);
end;

procedure negflo64;
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vfloatty));
 vfloatty(po1^):= -vfloatty(po1^);
end;

procedure pushconstaddress;
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= constdata+cpu.pc^.par.vaddress; 
end;

procedure storeglobnil();
begin
 ppointer(globdata+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storeframenil();
begin
 ppointer(cpu.frame+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storereg0nil();
begin
 ppointer(reg0+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storestacknil();
begin
 ppointer(cpu.stack+cpu.pc^.par.vaddress)^:= nil;
end;

procedure storestackrefnil();
begin
 pppointer(cpu.stack+cpu.pc^.par.vaddress)^^:= nil;
end;

procedure storeglobnilar();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(globdata+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(globdata+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storeframenilar();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(cpu.frame+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(cpu.frame+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storereg0nilar();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(reg0+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(reg0+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storestacknilar();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(cpu.stack+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(cpu.stack+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storestackrefnilar();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(pppointer(cpu.stack+par.dataaddress)^^,par.datasize,0);
{$else}
  filldword(pppointer(cpu.stack+par.dataaddress)^^,par.datasize,0);
{$endif}
 end;
end;

procedure popglob8;
begin
 puint8(globdata+cpu.pc^.par.dataaddress)^:= puint8(stackpop(1))^;
end;

procedure popglob16;
begin
 puint16(globdata+cpu.pc^.par.dataaddress)^:= puint16(stackpop(2))^;
end;

procedure popglob32;
begin
 puint32(globdata+cpu.pc^.par.dataaddress)^:= puint32(stackpop(4))^;
end;

procedure popglob;
begin
 move(stackpop(cpu.pc^.par.datasize)^,(globdata+cpu.pc^.par.dataaddress)^,
                                                        cpu.pc^.par.datasize);
end;

procedure pushglob8;
begin
 pv8ty(stackpush(1))^:= pv8ty(globdata+cpu.pc^.par.dataaddress)^;
end;

procedure pushglob16;
begin
 pv16ty(stackpush(2))^:= pv16ty(globdata+cpu.pc^.par.dataaddress)^;
end;

procedure pushglob32;
begin
 pv32ty(stackpush(4))^:= pv32ty(globdata+cpu.pc^.par.dataaddress)^;
end;

procedure pushglob;
begin
 move((globdata+cpu.pc^.par.dataaddress)^,stackpush(cpu.pc^.par.datasize)^,
                                                          cpu.pc^.par.datasize);
end;

//todo: make special locvar access funcs for inframe variables
//and loop unroll

function locaddress(const aaddress: locdataaddressty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 if aaddress.linkcount < 0 then begin
  result:= cpu.frame+aaddress.offset;
 end
 else begin
  po1:= cpu.stacklink;
  for i1:= aaddress.linkcount downto 0 do begin
   po1:= frameinfoty((po1-sizeof(frameinfoty))^).link;
  end;
  result:= po1+aaddress.offset;
 end;
end;

procedure poploc8;
begin             
 pv8ty(locaddress(cpu.pc^.par.locdataaddress))^:= pv8ty(stackpop(1))^;
end;

procedure poploc16;
begin
 pv16ty(locaddress(cpu.pc^.par.locdataaddress))^:= pv16ty(stackpop(2))^;
end;

procedure poploc32;
begin
 pv32ty(locaddress(cpu.pc^.par.locdataaddress))^:= pv32ty(stackpop(4))^;
end;

procedure poploc;
begin
 move(stackpop(cpu.pc^.par.datasize)^,(locaddress(cpu.pc^.par.locdataaddress))^,
                                                         cpu.pc^.par.datasize);
end;

procedure poplocindi8;
begin             
 pv8ty(locaddress(cpu.pc^.par.locdataaddress)^)^:= pv8ty(stackpop(1))^;
end;

procedure poplocindi16;
begin
 pv16ty(ppointer(locaddress(cpu.pc^.par.locdataaddress))^)^:= pv16ty(stackpop(2))^;
end;

procedure poplocindi32;
begin
 pv32ty(ppointer(locaddress(cpu.pc^.par.locdataaddress))^)^:= pv32ty(stackpop(4))^;
end;

procedure poplocindi;
begin
 move(stackpop(cpu.pc^.par.datasize)^,
      (ppointer(locaddress(cpu.pc^.par.locdataaddress))^)^,cpu.pc^.par.datasize);
end;

procedure pushloc8;
begin
 pv8ty(stackpush(1))^:= pv8ty(locaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushloc16;
begin
 pv16ty(stackpush(2))^:= pv16ty(locaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushloc32;
begin
 pv32ty(stackpush(4))^:= pv32ty(locaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushlocpo;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                              ppointer(locaddress(cpu.pc^.par.locdataaddress))^;
end;

procedure pushloc;
begin
 move((locaddress(cpu.pc^.par.locdataaddress))^,stackpush(cpu.pc^.par.datasize)^,
                                                   cpu.pc^.par.datasize);
end;

procedure pushlocindi8;
begin
 pv8ty(stackpush(1))^:= ppv8ty(locaddress(cpu.pc^.par.locdataaddress))^^;
end;

procedure pushlocindi16;
begin
 pv16ty(stackpush(2))^:= ppv16ty(locaddress(cpu.pc^.par.locdataaddress))^^;
end;

procedure pushlocindi32;
begin
 pv32ty(stackpush(4))^:= ppv32ty(locaddress(cpu.pc^.par.locdataaddress))^^;
end;

procedure pushlocindi;
begin
 move(ppointer(locaddress(cpu.pc^.par.locdataaddress))^^,
               stackpush(cpu.pc^.par.datasize)^,cpu.pc^.par.datasize);
end;

procedure pushaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= pointer(cpu.pc^.par.imm.vpointer);
end;

procedure pushlocaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                     locaddress(cpu.pc^.par.vlocaddress)+cpu.pc^.par.vlocadoffs;;
end;

procedure pushlocaddrindi;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
           ppointer(locaddress(cpu.pc^.par.vlocaddress))^+cpu.pc^.par.vlocadoffs;
end;

procedure pushglobaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                     globdata+cpu.pc^.par.vaddress+cpu.pc^.par.vglobadoffs;
end;

procedure pushglobaddrindi;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
           ppointer(globdata+cpu.pc^.par.vaddress)^+cpu.pc^.par.vglobadoffs;
end;

procedure pushstackaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= cpu.stack+cpu.pc^.par.voffset;
end;

procedure indirect8;
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv8ty(po1)^:=  pv8ty(ppointer(po1)^)^;
end;

procedure indirect16;
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv16ty(po1)^:=  pv16ty(ppointer(po1)^)^;
end;

procedure indirect32;
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv32ty(po1)^:=  pv32ty(ppointer(po1)^)^;
end;

procedure indirectpo;
var
 po1: pointer;
begin
 po1:= cpu.stack-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^;
end;

procedure indirectpooffs;
var
 po1: pointer;
begin
 po1:= cpu.stack-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^+cpu.pc^.par.voffset;
end;

procedure indirect;
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,stackpush(cpu.pc^.par.datasize)^,cpu.pc^.par.datasize);
end;

procedure popindirect8;
var
 po1,po2: pointer;
begin
 po1:= stackpop(1);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv8ty(po2)^:= pv8ty(po1)^;
end;

procedure popindirect16;
var
 po1,po2: pointer;
begin
 po1:= stackpop(2);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv16ty(po2)^:= pv16ty(po1)^;
end;

procedure popindirect32;
var
 po1,po2: pointer;
begin
 po1:= stackpop(4);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv32ty(po2)^:= pv32ty(po1)^;
end;

procedure popindirect;
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
procedure callop;
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

procedure calloutop;
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

procedure callvirtop;
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

procedure locvarpushop;
begin
 stackpush(cpu.pc^.par.stacksize);
end;

procedure locvarpopop;
begin
 stackpop(cpu.pc^.par.stacksize);
end;

procedure returnop;
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

procedure initclassop;
var
 po1: pointer;
 po2: pclassdefinfoty;
 self1: ppointer;
begin
 with cpu.pc^.par do begin
//  po2:= pclassdefinfoty(initclass.classdef+constdata);
  self1:= cpu.frame+initclass.selfinstance;
  po2:= self1^;  //class type
  po1:= intgetnulledmem(po2^.header.fieldsize);
  ppointer(po1)^:= po2;
  self1^:= po1;  //class instance
  pppointer(cpu.frame+initclass.result)^^:= po1; //result
 end;
end;

procedure destroyclassop;
begin
 with cpu.pc^.par do begin
  intfreemem(ppointer(cpu.frame+destroyclass.selfinstance)^);
 end;
end;

procedure decloop32();
var
 po1: pinteger;
begin
 po1:= pinteger(cpu.stack-4);
 dec(po1^);
 if po1^ < 0 then begin
  cpu.pc:= startpo+cpu.pc^.par.opaddress;
 end;
end;

procedure decloop64();
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

procedure finirefsizeglob();
begin
 finirefsize(ppointer(globdata+cpu.pc^.par.vaddress));
end;

procedure finirefsizeframe();
begin
 finirefsize(ppointer(cpu.frame+cpu.pc^.par.vaddress));
end;

procedure finirefsizereg0();
begin
 finirefsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure finirefsizestack();
begin
 finirefsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure finirefsizestackref();
begin
 finirefsize(pppointer(reg0+cpu.pc^.par.vaddress)^);
end;

procedure finirefsizeglobar();
begin
 finirefsizear(ppointer(globdata+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure finirefsizeframear();
begin
 finirefsizear(ppointer(cpu.frame+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure finirefsizereg0ar();
begin
 finirefsizear(ppointer(reg0+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure finirefsizestackar();
begin
 finirefsizear(ppointer(cpu.stack+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure finirefsizestackrefar();
begin
 finirefsizear(pppointer(cpu.stack+cpu.pc^.par.dataaddress)^,
                                                          cpu.pc^.par.datasize);
end;

procedure increfsizeglob();
begin
 increfsize(ppointer(globdata+cpu.pc^.par.vaddress));
end;

procedure increfsizeframe();
begin
 increfsize(ppointer(cpu.frame+cpu.pc^.par.vaddress));
end;

procedure increfsizereg0();
begin
 increfsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure increfsizestack();
begin
 increfsize(ppointer(cpu.stack+cpu.pc^.par.vaddress));
end;

procedure increfsizestackref();
begin
 increfsize(pppointer(cpu.stack+cpu.pc^.par.vaddress)^);
end;

procedure increfsizeglobar();
begin
 increfsizear(ppointer(globdata+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure increfsizeframear();
begin
 increfsizear(ppointer(cpu.frame+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure increfsizereg0ar();
begin
 increfsizear(ppointer(reg0+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure increfsizestackar();
begin
 increfsizear(ppointer(cpu.stack+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure increfsizestackrefar();
begin
 increfsizear(pppointer(cpu.stack+cpu.pc^.par.dataaddress)^,
                                                          cpu.pc^.par.datasize);
end;

procedure decrefsizeglob();
begin
 decrefsize(ppointer(globdata+cpu.pc^.par.vaddress));
end;

procedure decrefsizeframe();
begin
 decrefsize(ppointer(cpu.frame+cpu.pc^.par.vaddress));
end;

procedure decrefsizereg0();
begin
 decrefsize(ppointer(reg0+cpu.pc^.par.vaddress));
end;

procedure decrefsizestack();
begin
 decrefsize(ppointer(cpu.stack+cpu.pc^.par.vaddress));
end;

procedure decrefsizestackref();
begin
 decrefsize(pppointer(mainstack+cpu.pc^.par.vaddress)^);
end;

procedure decrefsizeglobar();
begin
 decrefsizear(ppointer(globdata+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure decrefsizeframear();
begin
 decrefsizear(ppointer(cpu.frame+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure decrefsizereg0ar();
begin
 decrefsizear(ppointer(reg0+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure decrefsizestackar();
begin
 decrefsizear(ppointer(cpu.stack+cpu.pc^.par.dataaddress),cpu.pc^.par.datasize);
end;

procedure decrefsizestackrefar();
begin
 decrefsizear(pppointer(cpu.stack+cpu.pc^.par.dataaddress)^,
                                                          cpu.pc^.par.datasize);
end;

procedure setlengthstr8(); //address, length
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
 stopop: opinfoty = (op: nil; par:(dummy:()));

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
 if trystack <> nil then begin
  cpu:= trystack^.cpu;
  trystack^.exceptobj:= po1; //todo: check existing exception
//  include(trystack^.flags,jf_exception);
 end
 else begin
  unhandledexception(po1);
 end;
end;
 
procedure pushcpucontext(); //todo: don't use push/pop stack
var
 po1: pjumpinfoty;
begin
 po1:= stackpush(sizeof(jumpinfoty));
 po1^.cpu:= cpu;
 po1^.cpu.pc:= startpo + cpu.pc^.par.opaddress;
 po1^.next:= trystack;
 po1^.exceptobj:= nil;
// po1^.flags:= [];
 trystack:= po1;
end;

procedure popcpucontext();
var
 po1: pjumpinfoty;
begin
 po1:= stackpop(sizeof(jumpinfoty));
 trystack:= po1^.next;
 if po1^.exceptobj <> nil then begin
  if trystack = nil then begin
   unhandledexception(po1^.exceptobj);
  end
  else begin
   trystack^.exceptobj:= po1^.exceptobj; //todo: check existing exception
   cpu:= trystack^.cpu;
  end;
 end;
end;

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

procedure run(const code: opinfoarty; const constseg: pointer;
                                        const stackdepht: integer);
var
 endpo: popinfoty;
begin
 fillchar(cpu,sizeof(cpu),0);
 reg0:= nil;
 trystack:= nil;
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

finalization
 finalize;
end.
