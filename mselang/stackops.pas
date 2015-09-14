{ MSElang Copyright (c) 2013-2015 by Martin Schreiber

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
 globtypes,parserglob,opglob;

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
            //todo: align startaddress
            
procedure finalize;
function run(const stackdepht: integer): integer; //returns exitcode
function run(const asegments: segmentbuffersty): integer; //returns exitcode

function getoptable: poptablety;
//function getssatable: pssatablety;

implementation
uses
 sysutils,handlerglob,mseformatstr,msetypes,internaltypes,mserttiutils,
 segmentutils,classhandler,interfacehandler,__mla__internaltypes;
  
type
 cputy = record
  pc: popinfoty;
  stack: pointer;
  frame: pointer;
  stacklink: pointer;
  stop: boolean;
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
 exitcodeaddress: pint32;
 cpu: cputy;
 {
 mainstackpo: pointer;
 framepo: pointer;
 stacklink: pointer;
 oppo: popinfoty;
}
 startpo: popinfoty;
 finihandler: opaddressty;
 halting: boolean;
// globdata: pointer;
// constdata: pointer;

 segments: array[segmentty] of segmentrangety;

procedure notimplemented();
begin
 raise exception.create('stackops OP not implemented');
end;
 
procedure internalerror(const atext: string);
begin
 raise exception.create('Internal error '+atext);
end;

function getstackaddress(const aaddress: stackaddressty): pointer;
begin
 result:= cpu.stack + aaddress.address;
end;

function getsegaddress(const aaddress: segdataaddressty): pointer; 
                                  {$ifdef mse_inline}inline;{$endif}
begin
 if aaddress.a.segment = seg_op then begin
  result:= segments[seg_op].basepo + 
        aaddress.a.address*sizeof(opinfoty) + aaddress.offset;
 end
 else begin
  result:= segments[aaddress.a.segment].basepo + 
                              aaddress.a.address + aaddress.offset;
 end;
end;

function getsegaddressindi(const aaddress: segdataaddressty): pointer;
                                  {$ifdef mse_inline}inline;{$endif}
begin
 result:= ppointer(segments[aaddress.a.segment].basepo + 
                              aaddress.a.address)^ + aaddress.offset;
end;

//todo: make special locvar access funcs for inframe variables
//and loop unroll

function getlocaddress(const aaddress: memopty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 if af_temp in aaddress.t.flags then begin
  result:= cpu.frame + aaddress.tempaddress.address;
 end
 else begin
  with aaddress.locdataaddress do begin
   if a.framelevel < 0 then begin
    result:= cpu.frame + a.address + offset;
   end
   else begin
    po1:= cpu.stacklink;
    for i1:= a.framelevel downto 0 do begin
     po1:= frameinfoty((po1-sizeof(frameinfoty))^).link;
    end;
    result:= po1 + a.address + offset;
   end;
  end;
 end;
end;

function getlocaddressindi(const aaddress: memopty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 if af_temp in aaddress.t.flags then begin
  result:= ppointer(cpu.frame + aaddress.tempaddress.address)^;
 end
 else begin
  with aaddress.locdataaddress do begin
   if a.framelevel < 0 then begin
    result:= ppointer(cpu.frame + a.address)^ + offset;
   end
   else begin
    po1:= cpu.stacklink;
    for i1:= a.framelevel downto 0 do begin
     po1:= frameinfoty((po1-sizeof(frameinfoty))^).link;
    end;
    result:= ppointer(po1 + a.address)^ + offset;
   end;
  end;
 end;
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

function intgetzeromem(const size: integer): pointer;
begin
 result:= getmem(size);
 fillchar(result^,size,0);
end;

function intgetzeroedmem(const allocsize: integer;
                           const nullsize: integer): pointer;
begin
 result:= getmem(allocsize);
 fillchar(result^,nullsize,0);
end;

procedure intreallocnulledmem(var po: pointer;
                        const oldsize,newsize: integer);
begin
 reallocmem(po,newsize);
 if newsize > oldsize then begin
  fillchar((po+oldsize)^,newsize-oldsize,0);
 end;
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

procedure nopop();
begin
 //dummy
end;

procedure labelop();
begin
 //dummy
end;

procedure gotoop();
begin
 cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
end;

procedure beginparseop();
begin
 with cpu.pc^ do begin
  finihandler:= par.beginparse.finisub;
  halting:= false;
  cpu.pc:= startpo + par.beginparse.mainad - 1;
 end;
end;

procedure endparseop();
begin
 //dummy
end;

procedure beginunitcodeop();
begin
 //dummy
end;

procedure endunitop();
begin
 //dummy
end;

procedure mainop();
begin
 cpu.frame:= cpu.stack;
 with cpu.pc^.par do begin
  exitcodeaddress:= pint32(segments[main.exitcodeaddress.segment].basepo+
                                                 main.exitcodeaddress.address);
 end; 
end;

procedure progendop();
begin
{
 with cpu.pc^.par.progend do begin
  exitcode:= pint32(segments[exitcodeaddress.segment].basepo+
                                                 exitcodeaddress.address)^;
 end;
}
 cpu.stop:= true;
end;

procedure cmpjmpneimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ <> cmpjmpimm.imm.vint32 then begin
   cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
  end;
 end;
end;

procedure cmpjmpeqimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ = cmpjmpimm.imm.vint32 then begin
   cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
  end;
 end;
end;

procedure cmpjmploimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ < cmpjmpimm.imm.vint32 then begin
   cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
  end;
 end;
end;

procedure cmpjmploeqimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ <= cmpjmpimm.imm.vint32 then begin
   cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
  end;
 end;
end;

procedure cmpjmpgtimm4op();
begin
 with cpu.pc^.par do begin
  if pint32(cpu.stack-sizeof(int32))^ > cmpjmpimm.imm.vint32 then begin
   cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
  end;
 end;
end;

procedure ifop();
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
 end;
end;

procedure whileop();
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
 end;
end;

procedure untilop();
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
 end;
end;

procedure writebooleanop();
begin
 write(vbooleanty((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writecardinalop();
begin
 write(vcardinalty((cpu.stack+cpu.pc^.par.voffset)^));
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

procedure writepointerop();
begin
 write(hextostr(vpointerty((cpu.stack+cpu.pc^.par.voffset)^)));
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

procedure pushimm1op();
begin
 pint8(stackpush(1))^:= cpu.pc^.par.imm.vint8; 
end;

procedure pushimm8op();
begin
 pint8(stackpush(1))^:= cpu.pc^.par.imm.vint8; 
end;

procedure pushimm16op();
begin
 pint16(stackpush(2))^:= cpu.pc^.par.imm.vint16; 
end;

procedure pushimm32op();
begin
 pint32(stackpush(4))^:= cpu.pc^.par.imm.vint32; 
end;

procedure pushimm64op();
begin
 pint32(stackpush(8))^:= cpu.pc^.par.imm.vint64; 
end;

procedure pushimmdatakindop();
begin
 vdatakindty(stackpushnoalign(sizeof(vdatakindty))^):= 
                                       cpu.pc^.par.imm.vdatakind; 
end;

procedure int32toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 vfloatty(stackpush(sizeof(vfloatty))^):= vintegerty(po1^);
end;

procedure potoint32op();
var
 po1: ppointer;
begin
 po1:= stackpop(sizeof(vpointerty));
 vintegerty(stackpush(sizeof(vintegerty))^):= vintegerty(po1^);
end;

procedure inttopoop();
var
 po1: ppointer;
begin
 //dummy
end;

procedure and1op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 vbooleanty(po2^):= vbooleanty(po2^) and vbooleanty(po1^);
end;

procedure and32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) and vintegerty(po1^);
end;

procedure or1op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 vbooleanty(po2^):= vbooleanty(po2^) or vbooleanty(po1^);
end;

procedure or32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) or vintegerty(po1^);
end;

procedure shl32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) shl vintegerty(po1^);
end;
{
procedure shrcard32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vcardinalty));
 po2:= po1-alignsize(sizeof(vcardinalty));
 vintegerty(po2^):= vcardinalty(po2^) shr vcardinalty(po1^);
end;
}
procedure shr32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) shr vintegerty(po1^);
end;

procedure mulcard32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vcardinalty(po2^)*vcardinalty(po1^);
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

procedure subint32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^)-vintegerty(po1^);
end;

procedure addpoint32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 inc(pvpointerty(po2)^,vintegerty(po1^));
end;

procedure subpoop();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vpointerty(po2^)-vpointerty(po1^);
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

procedure incdecsegimmint32op();
var
 po1: pinteger;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getsegaddress(mem.segdataaddress);
  inc(po1^,vint32);
 end; 
end;

procedure incdecsegimmpo32op();
var
 po1: ppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getsegaddress(mem.segdataaddress);
  inc(po1^,vint32);
 end; 
end;

procedure incdeclocimmint32op();
var
 po1: pinteger;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  inc(po1^,vint32);
 end; 
end;

procedure incdeclocimmpo32op();
var
 po1: ppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  inc(po1^,vint32);
 end; 
end;

procedure incdecparimmint32op();
begin
 incdeclocimmint32op();
end;

procedure incdecparimmpo32op();
begin
 incdeclocimmpo32op();
end;

procedure incdecparindiimmint32op();
var
 po1: ^pinteger;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  inc(po1^^,vint32);
 end; 
end;

procedure incdecparindiimmpo32op();
var
 po1: pppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  inc(po1^^,vint32);
 end; 
end;

procedure incdecindiimmint32op();
var
 po1: ^pinteger;
begin
 with cpu.pc^.par.memimm do begin
  po1:= stackpop(sizeof(vpointerty));
  inc(po1^^,vint32);
 end; 
end;

procedure incdecindiimmpo32op();
var
 po1: pppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= stackpop(sizeof(vpointerty));
  inc(po1^^,vint32);
 end; 
end;





















procedure incsegint32op();
var
 po1: pinteger;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  inc(po1^,pint32(stackpop(sizeof(int32)))^);
 end; 
end;

procedure incsegpo32op();
var
 po1: ppointer;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  i1:= pint32(stackpop(sizeof(int32)))^;
  inc(po1^,i1);
 end; 
end;

procedure inclocint32op();
var
 po1: pinteger;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  inc(po1^,i1);
 end; 
end;

procedure inclocpo32op();
var
 po1: ppointer;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  inc(po1^,i1);
 end; 
end;

procedure incparint32op();
begin
 inclocint32op();
end;

procedure incparpo32op();
begin
 inclocpo32op();
end;

procedure incparindiint32op();
var
 po1: ^pinteger;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  inc(po1^^,i1);
 end; 
end;

procedure incparindipo32op();
var
 po1: pppointer;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  inc(po1^^,i1);
 end; 
end;

procedure incindiint32op();
var
 po1: ^pinteger;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= stackpop(sizeof(vpointerty));
  i1:= pint32(stackpop(sizeof(int32)))^;
  inc(po1^^,i1);
 end; 
end;

procedure incindipo32op();
var
 po1: pppointer;
begin
 with cpu.pc^.par.memop do begin
  po1:= stackpop(sizeof(vpointerty));
  inc(po1^^,pint32(stackpop(sizeof(int32)))^);
 end; 
end;





























procedure decsegint32op();
var
 po1: pinteger;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^,i1);
 end; 
end;

procedure decsegpo32op();
var
 po1: ppointer;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^,i1);
 end; 
end;

procedure declocint32op();
var
 po1: pinteger;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^,i1);
 end; 
end;

procedure declocpo32op();
var
 po1: ppointer;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^,i1);
 end; 
end;

procedure decparint32op();
begin
 declocint32op();
end;

procedure decparpo32op();
begin
 declocpo32op();
end;

procedure decparindiint32op();
var
 po1: ^pinteger;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^^,i1);
 end; 
end;

procedure decparindipo32op();
var
 po1: pppointer;
 i1: int32;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^^,i1);
 end; 
end;

procedure decindiint32op();
var
 po1: ^pinteger;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= stackpop(sizeof(vpointerty));
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^^,i1);
 end; 
end;

procedure decindipo32op();
var
 po1: pppointer;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= stackpop(sizeof(vpointerty));
  i1:= pint32(stackpop(sizeof(int32)))^;
  dec(po1^^,i1);
 end; 
end;


procedure cmpeqpoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure cmpeqboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ = po1^;
end;

procedure cmpeqint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure cmpeqflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
end;

procedure cmpnepoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <> po1^;
end;

procedure cmpneboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ <> po1^;
end;

procedure cmpneint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <> po1^;
end;

procedure cmpneflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <> po1^;
end;

procedure cmpgtpoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ > po1^;
end;

procedure cmpgtboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ > po1^;
end;

procedure cmpgtcard32op();
var
 po1,po2: pvcardinalty;
begin
 po1:= stackpop(sizeof(vcardinalty));
 po2:= stackpop(sizeof(vcardinalty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ > po1^;
end;

procedure cmpgtint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ > po1^;
end;

procedure cmpgtflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ > po1^;
end;

procedure cmpltpoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ < po1^;
end;

procedure cmpltboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ < po1^;
end;

procedure cmpltcard32op();
var
 po1,po2: pvcardinalty;
begin
 po1:= stackpop(sizeof(vcardinalty));
 po2:= stackpop(sizeof(vcardinalty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ < po1^;
end;

procedure cmpltint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ < po1^;
end;

procedure cmpltflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ < po1^;
end;

procedure cmpgepoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ >= po1^;
end;

procedure cmpgeboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ >= po1^;
end;

procedure cmpgecard32op();
var
 po1,po2: pvcardinalty;
begin
 po1:= stackpop(sizeof(vcardinalty));
 po2:= stackpop(sizeof(vcardinalty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ >= po1^;
end;

procedure cmpgeint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ >= po1^;
end;

procedure cmpgeflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ >= po1^;
end;

procedure cmplepoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <= po1^;
end;

procedure cmpleboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 po2^:= po2^ <= po1^;
end;

procedure cmplecard32op();
var
 po1,po2: pvcardinalty;
begin
 po1:= stackpop(sizeof(vcardinalty));
 po2:= stackpop(sizeof(vcardinalty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <= po1^;
end;

procedure cmpleint32op();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <= po1^;
end;

procedure cmpleflo64op();
var
 po1,po2: pvfloatty;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= stackpop(sizeof(vfloatty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <= po1^;
end;

procedure addflo64op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= po1-alignsize(sizeof(vfloatty));
 vfloatty(po2^):= vfloatty(po2^)+vfloatty(po1^);
end;

procedure subflo64op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vfloatty));
 po2:= po1-alignsize(sizeof(vfloatty));
 vfloatty(po2^):= vfloatty(po2^)-vfloatty(po1^);
end;

procedure card8tocard16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card8));
 pcard16(po1)^:= pcard8(po1)^;
end;

procedure card8tocard32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card8));
 pcard32(po1)^:= pcard8(po1)^;
end;

procedure card8tocard64op();
var
 da1: card8;
begin
 da1:= pcard8(stackpop(sizeof(card8)))^;
 pcard64(stackpush(sizeof(card64)))^:= da1;
end;

procedure card16tocard8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card16));
 pcard16(po1)^:= pcard16(po1)^;
end;

procedure card16tocard32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card16));
 pcard32(po1)^:= pcard16(po1)^;
end;

procedure card16tocard64op();
var
 da1: card16;
begin
 da1:= pcard16(stackpop(sizeof(card16)))^;
 pcard64(stackpush(sizeof(card64)))^:= da1;
end;

procedure card32tocard8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card32));
 pcard8(po1)^:= pcard32(po1)^;
end;

procedure card32tocard16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card32));
 pcard16(po1)^:= pcard16(po1)^;
end;

procedure card32tocard64op();
var
 da1: card32;
begin
 da1:= pcard32(stackpop(sizeof(card32)))^;
 pcard64(stackpush(sizeof(card64)))^:= da1;
end;

procedure card64tocard8op();
var
 da1: card64;
begin
 da1:= pcard64(stackpop(sizeof(card64)))^;
 pcard8(stackpush(sizeof(card8)))^:= da1;
end;

procedure card64tocard16op();
var
 da1: card64;
begin
 da1:= pcard64(stackpop(sizeof(card64)))^;
 pcard16(stackpush(sizeof(card16)))^:= da1;
end;

procedure card64tocard32op();
var
 da1: card64;
begin
 da1:= pcard64(stackpop(sizeof(card64)))^;
 pcard32(stackpush(sizeof(card32)))^:= da1;
end;

procedure int8toint16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int8));
 pint16(po1)^:= pint8(po1)^;
end;

procedure int8toint32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int8));
 pint32(po1)^:= pint8(po1)^;
end;

procedure int8toint64op();
var
 da1: int8;
begin
 da1:= pint8(stackpop(sizeof(int8)))^;
 pint64(stackpush(sizeof(int64)))^:= da1;
end;

procedure int16toint8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int16));
 pint8(po1)^:= pint16(po1)^;
end;

procedure int16toint32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int16));
 pint32(po1)^:= pint16(po1)^;
end;

procedure int16toint64op();
var
 da1: int16;
begin
 da1:= pint16(stackpop(sizeof(int16)))^;
 pint64(stackpush(sizeof(int64)))^:= da1;
end;

procedure int32toint8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int32));
 pint8(po1)^:= pint32(po1)^;
end;

procedure int32toint16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int32));
 pint16(po1)^:= pint32(po1)^;
end;

procedure int32toint64op();
var
 da1: int32;
begin
 da1:= pint32(stackpop(sizeof(int32)))^;
 pint64(stackpush(sizeof(int64)))^:= da1;
end;

procedure int64toint8op();
var
 da1: int64;
begin
 da1:= pint64(stackpop(sizeof(int64)))^;
 pint8(stackpush(sizeof(int8)))^:= da1;
end;

procedure int64toint16op();
var
 da1: int64;
begin
 da1:= pint64(stackpop(sizeof(int64)))^;
 pint16(stackpush(sizeof(int16)))^:= da1;
end;

procedure int64toint32op();
var
 da1: int64;
begin
 da1:= pint64(stackpop(sizeof(int64)))^;
 pint32(stackpush(sizeof(int32)))^:= da1;
end;

procedure card8toint8op();
begin
 //dummy
end;

procedure card8toint16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card8));
 pint16(po1)^:= pcard8(po1)^;
end;

procedure card8toint32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card8));
 pint32(po1)^:= pcard8(po1)^;
end;

procedure card8toint64op();
var
 da1: card8;
begin
 da1:= pcard8(stackpop(sizeof(card8)))^;
 pint64(stackpush(sizeof(int64)))^:= da1;
end;

procedure card16toint8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card16));
 pint8(po1)^:= pcard16(po1)^;
end;

procedure card16toint16op();
begin
 //dummy
end;

procedure card16toint32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card16));
 pint32(po1)^:= pcard16(po1)^;
end;

procedure card16toint64op();
var
 da1: card16;
begin
 da1:= pcard16(stackpop(sizeof(card16)))^;
 pint64(stackpush(sizeof(int64)))^:= da1;
end;

procedure card32toint8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card32));
 pint8(po1)^:= pcard32(po1)^;
end;

procedure card32toint16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(card32));
 pint16(po1)^:= pcard32(po1)^;
end;

procedure card32toint32op();
begin
 //dummy
end;

procedure card32toint64op();
var
 da1: card32;
begin
 da1:= pcard32(stackpop(sizeof(card32)))^;
 pint64(stackpush(sizeof(int64)))^:= da1;
end;

procedure card64toint8op();
var
 da1: card64;
begin
 da1:= pcard64(stackpop(sizeof(card64)))^;
 pint8(stackpush(sizeof(int8)))^:= da1;
end;

procedure card64toint16op();
var
 da1: card64;
begin
 da1:= pcard64(stackpop(sizeof(card64)))^;
 pint16(stackpush(sizeof(int16)))^:= da1;
end;

procedure card64toint32op();
var
 da1: card64;
begin
 da1:= pcard64(stackpop(sizeof(card64)))^;
 pint32(stackpush(sizeof(int32)))^:= da1;
end;

procedure card64toint64op();
begin
 //dummy
end;

procedure int8tocard8op();
begin
 //dummy
end;

procedure int8tocard16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int8));
 pcard16(po1)^:= pcard8(po1)^;
end;

procedure int8tocard32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int8));
 pcard32(po1)^:= pcard8(po1)^;
end;

procedure int8tocard64op();
var
 da1: int8;
begin
 da1:= pint8(stackpop(sizeof(int8)))^;
 pint64(stackpush(sizeof(card64)))^:= da1;
end;

procedure int16tocard8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int16));
 pcard8(po1)^:= pint16(po1)^;
end;

procedure int16tocard16op();
begin
 //dummy
end;

procedure int16tocard32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int16));
 pcard32(po1)^:= pint16(po1)^;
end;

procedure int16tocard64op();
var
 da1: int16;
begin
 da1:= pint16(stackpop(sizeof(int16)))^;
 pint64(stackpush(sizeof(card64)))^:= da1;
end;

procedure int32tocard8op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int32));
 pcard8(po1)^:= pint32(po1)^;
end;

procedure int32tocard16op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int32));
 pcard16(po1)^:= pint32(po1)^;
end;

procedure int32tocard32op();
begin
 //dummy
end;

procedure int32tocard64op();
var
 da1: int32;
begin
 da1:= pint32(stackpop(sizeof(int16)))^;
 pint64(stackpush(sizeof(card64)))^:= da1;
end;

procedure int64tocard8op();
var
 da1: int64;
begin
 da1:= pint64(stackpop(sizeof(int64)))^;
 pint8(stackpush(sizeof(int8)))^:= da1;
end;

procedure int64tocard16op();
var
 da1: int64;
begin
 da1:= pint64(stackpop(sizeof(int64)))^;
 pint16(stackpush(sizeof(int16)))^:= da1;
end;

procedure int64tocard32op();
var
 da1: int64;
begin
 da1:= pint64(stackpop(sizeof(int64)))^;
 pint32(stackpush(sizeof(int32)))^:= da1;
end;

procedure int64tocard64op();
begin
 //dummy
end;

procedure not1op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vbooleanty));
 vbooleanty(po1^):= not vbooleanty(po1^);
end;

procedure not32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vcardinalty));
 vcardinalty(po1^):= not vcardinalty(po1^);
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

procedure pushstack8op();
var
 po1: pv8ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv8ty(stackpush(1))^:= po1^;
end;

procedure pushstack16op();
var
 po1: pv16ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv16ty(stackpush(2))^:= po1^;
end;

procedure pushstack32op();
var
 po1: pv32ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv32ty(stackpush(4))^:= po1^;
end;

procedure pushstack64op();
var
 po1: pv64ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv64ty(stackpush(8))^:= po1^;
end;

procedure pushstackpoop();
var
 po1: ppointer;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 ppointer(stackpush(sizeof(pointer)))^:= po1^;
end;

procedure pushstackindi8op();
var
 po1: ppv8ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv8ty(stackpush(1))^:= po1^^;
end;

procedure pushstackindi16op();
var
 po1: ppv16ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv16ty(stackpush(2))^:= po1^^;
end;

procedure pushstackindi32op();
var
 po1: ppv32ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv32ty(stackpush(4))^:= po1^^;
end;

procedure pushstackindi64op();
var
 po1: ppv64ty;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 pv64ty(stackpush(8))^:= po1^^;
end;

procedure pushstackindipoop();
var
 po1: pppointer;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.stackaddress);
 ppointer(stackpush(sizeof(pointer)))^:= po1^^;
end;

procedure pushsegaddressop();
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= 
                             getsegaddress(cpu.pc^.par.memop.segdataaddress); 
end;

procedure storesegnilop();
begin
 ppointer(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= nil;
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
  fillqword(getsegaddress(par.memop.segdataaddress)^,par.memop.t.size,0);
{$else}
  filldword(getsegaddress(par.memop.segdataaddress)^,par.memop.t.size,0);
{$endif}
 end;
end;

procedure storeframenilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(cpu.frame+par.memop.podataaddress)^,
                                            par.memop.t.size,0);
{$else}
  filldword(ppointer(cpu.frame+par.memop.podataaddress)^,
                                            par.memop.t.size,0);
{$endif}
 end;
end;

procedure storereg0nilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(reg0+par.memop.podataaddress)^,par.memop.t.size,0);
{$else}
  filldword(ppointer(reg0+par.memop.podataaddress)^,par.memop.t.size,0);
{$endif}
 end;
end;

procedure storestacknilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(ppointer(cpu.stack+par.memop.podataaddress)^,
                                                  par.memop.t.size,0);
{$else}
  filldword(ppointer(cpu.stack+par.memop.podataaddress)^,
                                                  par.memop.t.size,0);
{$endif}
 end;
end;

procedure storestackrefnilarop();
begin
 with cpu.pc^ do begin
{$ifdef cpu64}
  fillqword(pppointer(cpu.stack+par.memop.podataaddress)^^,
                                                    par.memop.t.size,0);
{$else}
  filldword(pppointer(cpu.stack+par.memop.podataaddress)^^,
                                                    par.memop.t.size,0);
{$endif}
 end;
end;

procedure popseg8op();
begin
 puint8(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                     puint8(stackpop(1))^;
end;

procedure popseg16op();
begin
 puint16(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                      puint16(stackpop(2))^;
end;

procedure popseg32op();
begin
 puint32(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                      puint32(stackpop(4))^;
end;

procedure popseg64op();
begin
 puint64(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                      puint64(stackpop(8))^;
end;

procedure popsegpoop();
begin
 ppointer(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                       ppointer(stackpop(sizeof(pointer)))^;
end;

procedure popsegf16op();
begin
 puint16(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                      puint16(stackpop(2))^;
end;

procedure popsegf32op();
begin
 puint32(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                      puint32(stackpop(4))^;
end;

procedure popsegf64op();
begin
 puint64(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= 
                                                      puint64(stackpop(8))^;
end;

procedure popsegop();
var
 int1: integer;
begin
 int1:= -cpu.pc^.par.memop.t.size;
 move(stackpop(int1)^,getsegaddress(cpu.pc^.par.memop.segdataaddress)^,int1);
end;

procedure pushseg8op();
begin
 pv8ty(stackpush(1))^:= pv8ty(getsegaddress(
                                cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushseg16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getsegaddress(
                                cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushseg32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getsegaddress(
                                    cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushseg64op();
begin
 pv64ty(stackpush(8))^:= pv64ty(getsegaddress(
                                    cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushsegpoop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= ppointer(getsegaddress(
                                   cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushsegf16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getsegaddress(
                                cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushsegf32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getsegaddress(
                                    cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushsegf64op();
begin
 pv64ty(stackpush(8))^:= pv64ty(getsegaddress(
                                    cpu.pc^.par.memop.segdataaddress))^;
end;

procedure pushsegop();
var
 int1: integer;       
begin
 int1:= cpu.pc^.par.memop.t.size;
 move(getsegaddress(cpu.pc^.par.memop.segdataaddress)^,
                  stackpush(int1)^,int1);
end;

procedure poploc8op();
begin             
 pv8ty(getlocaddress(cpu.pc^.par.memop))^:= pv8ty(stackpop(1))^;
end;

procedure poploc16op();
begin
 pv16ty(getlocaddress(cpu.pc^.par.memop))^:= pv16ty(stackpop(2))^;
end;

procedure poploc32op();
begin
 pv32ty(getlocaddress(cpu.pc^.par.memop))^:= pv32ty(stackpop(4))^;
end;

procedure poploc64op();
begin
 pv64ty(getlocaddress(cpu.pc^.par.memop))^:= pv64ty(stackpop(8))^;
end;

procedure poplocpoop();
begin
 ppointer(getlocaddress(cpu.pc^.par.memop))^:= 
                                   ppointer(stackpop(sizeof(pointer)))^;
end;

procedure poplocf16op();
begin
 pv16ty(getlocaddress(cpu.pc^.par.memop))^:= pv16ty(stackpop(2))^;
end;

procedure poplocf32op();
begin
 pv32ty(getlocaddress(cpu.pc^.par.memop))^:= pv32ty(stackpop(4))^;
end;

procedure poplocf64op();
begin
 pv64ty(getlocaddress(cpu.pc^.par.memop))^:= pv64ty(stackpop(8))^;
end;

procedure poplocop();
var
 int1: integer;
begin
 int1:= -cpu.pc^.par.memop.t.size;
 move(stackpop(int1)^,getlocaddress(cpu.pc^.par.memop)^,int1);
end;

procedure poplocindi8op();
begin             
 pv8ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv8ty(stackpop(1))^;
end;

procedure poplocindi16op();
begin
 pv16ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv16ty(stackpop(2))^;
end;

procedure poplocindi32op();
begin
 pv32ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv32ty(stackpop(4))^;
end;

procedure poplocindi64op();
begin
 pv64ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv64ty(stackpop(8))^;
end;

procedure poplocindipoop();
begin
 ppointer(getlocaddressindi(cpu.pc^.par.memop))^:= 
                                           ppointer(stackpop(sizeof(pointer)))^;
end;

procedure poplocindif16op();
begin
 pv16ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv16ty(stackpop(2))^;
end;

procedure poplocindif32op();
begin
 pv32ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv32ty(stackpop(4))^;
end;

procedure poplocindif64op();
begin
 pv64ty(getlocaddressindi(cpu.pc^.par.memop))^:= pv64ty(stackpop(8))^;
end;

procedure poplocindiop();
var
 int1: integer;
begin
 int1:= -cpu.pc^.par.memop.t.size;
 move(stackpop(int1)^,getlocaddressindi(cpu.pc^.par.memop)^,int1);
end;

procedure poppar8op();
begin             
 poploc8op();
end;

procedure poppar16op();
begin
 poploc16op();
end;

procedure poppar32op();
begin
 poploc32op();
end;

procedure poppar64op();
begin
 poploc64op();
end;

procedure popparpoop();
begin
 poplocpoop();
end;

procedure popparf16op();
begin
 poploc16op();
end;

procedure popparf32op();
begin
 poploc32op();
end;

procedure popparf64op();
begin
 poploc64op();
end;

procedure popparop();
begin
 poplocop();
end;

procedure popparindi8op();
begin             
 poplocindi8op();
end;

procedure popparindi16op();
begin
 poplocindi16op();
end;

procedure popparindi32op();
begin
 poplocindi32op();
end;

procedure popparindi64op();
begin
 poplocindi64op();
end;

procedure popparindipoop();
begin
 poplocindipoop();
end;

procedure popparindif16op();
begin
 poplocindi16op();
end;

procedure popparindif32op();
begin
 poplocindi32op();
end;

procedure popparindif64op();
begin
 poplocindi64op();
end;

procedure popparindiop();
begin
 poplocindiop();
end;

procedure pushloc8op();
begin
 pv8ty(stackpush(1))^:= pv8ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushloc16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushloc32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushloc64op();
begin
 pv64ty(stackpush(8))^:= pv64ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushlocpoop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
               ppointer(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushlocf16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushlocf32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushlocf64op();
begin
 pv64ty(stackpush(8))^:= pv64ty(getlocaddress(cpu.pc^.par.memop))^;
end;

procedure pushlocop();
var
 int1: integer;
begin
 int1:= cpu.pc^.par.memop.t.size;
 move(getlocaddress(cpu.pc^.par.memop)^,stackpush(int1)^,int1);
end;

procedure pushpar8op();
begin
 pushloc8op();
end;

procedure pushpar16op();
begin
 pushloc16op();
end;

procedure pushpar32op();
begin
 pushloc32op();
end;

procedure pushpar64op();
begin
 pushloc64op();
end;

procedure pushparpoop();
begin
 pushlocpoop();
end;

procedure pushparf16op();
begin
 pushlocf16op();
end;

procedure pushparf32op();
begin
 pushlocf32op();
end;

procedure pushparf64op();
begin
 pushlocf64op();
end;

procedure pushparop();
begin
 pushlocop();
end;

procedure pushlocindi8op();
begin
 pv8ty(stackpush(1))^:= pv8ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindi16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindi32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindi64op();
begin
 pv64ty(stackpush(8))^:= pv64ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindipoop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= ppointer(getlocaddressindi(
                                                        cpu.pc^.par.memop))^;
end;

procedure pushlocindif16op();
begin
 pv16ty(stackpush(2))^:= pv16ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindif32op();
begin
 pv32ty(stackpush(4))^:= pv32ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindif64op();
begin
 pv64ty(stackpush(8))^:= pv64ty(getlocaddressindi(cpu.pc^.par.memop))^;
end;

procedure pushlocindiop();
var
 int1: integer;
begin
 int1:= cpu.pc^.par.memop.t.size;
 move(getlocaddressindi(cpu.pc^.par.memop)^,stackpush(int1)^,int1);
end;

procedure pushaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= pointer(cpu.pc^.par.imm.vpointer);
end;

procedure pushlocaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= getlocaddress(cpu.pc^.par.memop);
end;
{
procedure pushlocaddrindiop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                         getlocaddressindi(cpu.pc^.par.memop.locdataaddress);
end;
}
procedure pushsegaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
               getsegaddress(cpu.pc^.par.memop.segdataaddress);
end;
{
procedure pushsegaddrindiop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
               getsegaddressindi(cpu.pc^.par.memop.segdataaddress);
end;
}
procedure pushstackaddrop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= cpu.stack+cpu.pc^.par.voffset;
end;
{
procedure pushstackaddrindiop();
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
        ppointer(cpu.stack+cpu.pc^.par.voffset)^+cpu.pc^.par.voffsaddress;
end;
}
procedure pushduppoop();
var
 po1: ppointer;
begin
 po1:= ppointer(stackpush(sizeof(pointer)));
 po1^:= (po1-1)^
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

procedure indirect64op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv64ty(po1)^:=  pv64ty(ppointer(po1)^)^;
end;

procedure indirectpoop();
var
 po1: pointer;
begin
 po1:= cpu.stack-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^;
end;

procedure indirectf16op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv16ty(po1)^:=  pv16ty(ppointer(po1)^)^;
end;

procedure indirectf32op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv32ty(po1)^:=  pv32ty(ppointer(po1)^)^;
end;

procedure indirectf64op();
var
 po1: pointer;
begin
 po1:= cpu.stack-alignstep;
 pv64ty(po1)^:=  pv64ty(ppointer(po1)^)^;
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
 int1: integer;
begin
 int1:= cpu.pc^.par.memop.t.size;
 po1:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,stackpush(int1)^,int1);
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

procedure popindirect64op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(4);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv64ty(po2)^:= pv64ty(po1)^;
end;

procedure popindirectpoop();
var
 po1,po2: pointer;
begin
 po1:= stackpop(4);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 ppointer(po2)^:= ppointer(po1)^;
end;

procedure popindirectf16op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(2);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv16ty(po2)^:= pv16ty(po1)^;
end;

procedure popindirectf32op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(4);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv32ty(po2)^:= pv32ty(po1)^;
end;

procedure popindirectf64op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(4);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 pv64ty(po2)^:= pv64ty(po1)^;
end;

procedure popindirectop();
var
 po1,po2: pointer;
 int1: integer;
begin
 int1:= cpu.pc^.par.memop.t.size;
 po1:= stackpop(int1);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,po2^,int1);
end;

//first op:
//                  |cpu.frame    |cpu.stack
// params frameinfo locvars      
//
procedure docall();
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
end;

procedure haltop();
begin
 if not halting and (finihandler <> 0) then begin
  halting:= true;
  dec(cpu.pc); //return to haltop()
  docall();
  cpu.pc:= startpo+finihandler-1;
 end
 else begin
  progendop();
//  cpu.stop:= true;
 end;
end;

procedure callop();
begin
 docall();
 cpu.pc:= startpo+cpu.pc^.par.callinfo.ad.ad;
end;

procedure callfuncop();
begin
 callop();
end;

procedure callindiop();
begin
 docall();
 with cpu.pc^.par do begin
  cpu.pc:= ppointer(cpu.frame+callinfo.indi.calladdr)^;
  dec(cpu.pc);
 end;
end;

procedure callfuncindiop();
begin
 callindiop();
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
 cpu.pc:= startpo+cpu.pc^.par.callinfo.ad.ad;
end;

procedure callfuncoutop();
begin
 calloutop();
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
 with cpu.pc^.par.callinfo.virt do begin
  cpu.pc:= startpo+pptruint(pppointer(cpu.stack+selfinstance)^^+virtoffset)^;
//  cpu.pc:= startpo+ptruint(ppppointer(cpu.stack+selfinstance)^^[virtindex]); 
 end;
end;

procedure callintfop();
var
 po1: ppointer;
// po2: pintfitemty;
 po3: pintfdefinfoty;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
 with cpu.pc^.par.callinfo.virt do begin
  po1:= cpu.stack + selfinstance;
  po3:= ppointer(po1^)^;
  inc(po1^,po3^.header.instanceoffset);
  cpu.pc:= startpo + pintfitemty(pointer(po3)+virtoffset)^.subad;
{
  po2:= segments[seg_intf].basepo + pptrint(po1^)^;
  inc(po1^,po2^.instanceshift);
  cpu.pc:= startpo + po2^.subad;
}
 end;
end;

procedure virttrampolineop();
begin
 with cpu.pc^.par.subbegin.trampoline do begin
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

procedure subbeginop();
begin
 //dummy
end;

procedure subendop();
begin
 //dummy
end;

procedure externalsubop();
begin
 notimplemented();
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

procedure returnfuncop();
begin
 returnop();
end;

procedure initclassop();
var
 po1: pointer;
 po2: classdefinfopoty;
 self1: ppointer;
 ps: popaddressty;
 pd: ppointer;
 pe: pointer;
begin
 with cpu.pc^.par do begin
  po2:= classdefinfopoty(segments[seg_classdef].basepo+initclass.classdef);
  self1:= stackpush(pointersize);
//  po2:= self1^;  //class type
//  po1:= intgetzeroedmem(po2^.header.allocsize,po2^.header.fieldsize);
  po1:= intgetzeromem(po2^.header.allocs.size);
  ppointer(po1)^:= po2;    //class type info
  self1^:= po1;            //class instance
  ppointer(cpu.stack-2*pointersize)^:= po1; //result

  repeat
   pd:= po1 + po2^.header.allocs.instanceinterfacestart; //copy interface table
   pe:= po1 + po2^.header.allocs.size;
   ps:= (pointer(po2)+po2^.header.allocs.classdefinterfacestart);
   while pd < pe do begin
    pd^:= segments[seg_intf].basepo+ps^;
    inc(pd);
    inc(ps);
   end;
   if po2^.header.interfaceparent >= 0 then begin
    po2:= segments[seg_classdef].basepo+po2^.header.interfaceparent;
   end
   else begin
    po2:= nil;
   end;
  until po2 = nil;
 end;
end;

procedure destroyclassop();
begin
 with cpu.pc^.par do begin
  intfreemem(ppointer(stackpop(sizeof(pointer)))^);
 end;
end;

procedure decloop32op();
var
 po1: pinteger;
begin
 po1:= pinteger(cpu.stack-4);
 dec(po1^);
 if po1^ < 0 then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
 end;
end;

procedure decloop64op();
var
 po1: pint64;
begin
 po1:= pint64(cpu.stack-8);
 dec(po1^);
 if po1^ < 0 then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
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
 finirefsize(getsegaddress(cpu.pc^.par.memop.segdataaddress));
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
 finirefsizear(getsegaddress(cpu.pc^.par.memop.segdataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure finirefsizeframearop();
begin
 finirefsizear(ppointer(cpu.frame+cpu.pc^.par.memop.podataaddress),
                                                 cpu.pc^.par.memop.t.size);
end;

procedure finirefsizereg0arop();
begin
 finirefsizear(ppointer(reg0+cpu.pc^.par.memop.podataaddress),
                                                 cpu.pc^.par.memop.t.size);
end;

procedure finirefsizestackarop();
begin
 finirefsizear(ppointer(cpu.stack+cpu.pc^.par.memop.podataaddress),
                                                 cpu.pc^.par.memop.t.size);
end;

procedure finirefsizestackrefarop();
begin
 finirefsizear(pppointer(cpu.stack+cpu.pc^.par.memop.podataaddress)^,
                                                 cpu.pc^.par.memop.t.size);
end;

procedure increfsizesegop();
begin
 increfsize(getsegaddress(cpu.pc^.par.memop.segdataaddress));
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
 increfsizear(getsegaddress(cpu.pc^.par.memop.segdataaddress),
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizeframearop();
begin
 increfsizear(ppointer(cpu.frame+cpu.pc^.par.memop.podataaddress),
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizereg0arop();
begin
 increfsizear(ppointer(reg0+cpu.pc^.par.memop.podataaddress),
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizestackarop();
begin
 increfsizear(ppointer(cpu.stack+cpu.pc^.par.memop.podataaddress),
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizestackrefarop();
begin
 increfsizear(pppointer(cpu.stack+cpu.pc^.par.memop.podataaddress)^,
                                             cpu.pc^.par.memop.t.size);
end;

procedure decrefsizesegop();
begin
 decrefsize(getsegaddress(cpu.pc^.par.memop.segdataaddress));
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
 decrefsizear(getsegaddress(cpu.pc^.par.memop.segdataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizeframearop();
begin
 decrefsizear(ppointer(cpu.frame+cpu.pc^.par.memop.podataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizereg0arop();
begin
 decrefsizear(ppointer(reg0+cpu.pc^.par.memop.podataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizestackarop();
begin
 decrefsizear(ppointer(cpu.stack+cpu.pc^.par.memop.podataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizestackrefarop();
begin
 decrefsizear(pppointer(cpu.stack+cpu.pc^.par.memop.podataaddress)^,
                                                cpu.pc^.par.memop.t.size);
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

procedure setlengthdynarrayop();
var
 si1: dynarraysizety;
 sil1,sil2: dynarraysizety;
 ds,ss: pdynarrayheaderty;
 ad: ppointer;
 itemsize1: integer;
begin
 si1:= pdynarraysizety(cpu.stack-sizeof(dynarraysizety))^;
 ad:= ppointer(cpu.stack-(sizeof(dynarraysizety)+sizeof(pointer)))^;
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
  itemsize1:= cpu.pc^.par.setlength.itemsize;
  sil1:= si1*itemsize1;
  if ds = nil then begin
   getmem(ds,sil1+dynarrayallocsize);
  end
  else begin
   if ds^.ref.count = 1 then begin
    intreallocnulledmem(ds,ds^.len*itemsize1+dynarrayallocsize,
                                                    sil1+dynarrayallocsize);
   end
   else begin //needs copy
    ss:= ds;
    getmem(ds,sil1+dynarrayallocsize);
    sil2:= ss^.len*itemsize1;
    if sil1 < sil2 then begin
     sil2:= sil1;
    end
    else begin
     fillchar((pointer(ds+1)+sil2)^,sil1-sil2,0);
    end;    
    move((ss+1)^,(ds+1)^,sil2); //get data copy
   end;
  end;
  ds^.len:= si1;
  ds^.ref.count:= 1;
  inc(ds);    //data
  ad^:= ds;
 end;
 stackpop(pointersize+sizeof(dynarraysizety));
end;
{
const
 stopop: opinfoty = (op: (op: oc_none); 
                   par:(ssad: 0; ssas1: 0; ssas2: 0; dummy:()));
}
procedure unhandledexception(const exceptobj: pointer);
begin
 writeln('An unhandled exception occured at $'+hextostr(cpu.pc));
 finiclass(@exceptobj);
 cpu.stop:= true;
// cpu.pc:= @stopop;
// dec(cpu.pc);
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
 po1^.cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
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

procedure getmemop();
var
 int1: int32;
 po1: ppointer;
begin
 int1:= pinteger(stackpop(sizeof(int32)))^;
 po1:= ppointer(stackpop(pointersize))^;
 getmem(po1^,int1); //todo: out of memory
end;

procedure getzeromemop();
var
 int1: int32;
 po1: ppointer;
begin
 int1:= pinteger(stackpop(sizeof(int32)))^;
 po1:= ppointer(stackpop(pointersize))^;
 po1^:= intgetzeromem(int1);
// getmem(po1^,int1); //todo: out of memory
end;

procedure freememop();
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(pointersize))^;
 freemem(po1);
end;

procedure setmemop();
var
 po1: pointer;
 i1: int32;
 b1: byte;
begin
 b1:= pinteger(stackpop(sizeof(int32)))^;
 i1:= pinteger(stackpop(sizeof(int32)))^;
 po1:= ppointer(stackpop(pointersize))^;
 fillchar(po1^,i1,b1);
end;

procedure lineinfoop();
begin
 //dummy
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

var
 globdata: pointer;

const
  nonessa = 0;
  nopssa = 0;
  labelssa = 0;
  ifssa = 0;
  whilessa = 0;
  untilssa = 0;
  decloop32ssa = 0;
  decloop64ssa = 0;

 
  beginparsessa = 0;
  endparsessa = 0;
  beginunitcodessa = 0;
  endunitssa = 0;
  mainssa = 0;
  progendssa = 0;  
  haltssa = 0;

  movesegreg0ssa = 0;
  moveframereg0ssa = 0;
  popreg0ssa = 0;
  increg0ssa = 0;

  gotossa = 0;
  cmpjmpneimm4ssa = 0;
  cmpjmpeqimm4ssa = 0;
  cmpjmploimm4ssa = 0;
  cmpjmpgtimm4ssa = 0;
  cmpjmploeqimm4ssa = 0;

  writelnssa = 0;
  writebooleanssa = 0;
  writecardinalssa = 0;
  writeintegerssa = 0;
  writefloatssa = 0;
  writestring8ssa = 0;
  writepointerssa = 0;
  writeclassssa = 0;
  writeenumssa = 0;

  pushssa = 0;
  popssa = 0;

  pushimm1ssa = 0;
  pushimm8ssa = 0;
  pushimm16ssa = 0;
  pushimm32ssa = 0;
  pushimm64ssa = 0;
  pushimmdatakindssa = 0;
  
  int32toflo64ssa = 0;
  potoint32ssa = 0;
  inttopossa = 0;
  
  and1ssa = 0;
  and32ssa = 0;
  or1ssa = 0;
  or32ssa = 0;
  
  shl32ssa = 0;
  shr32ssa = 0;
//  shrint32ssa = 0;
  
  card8tocard16ssa = 0;
  card8tocard32ssa = 0;
  card8tocard64ssa = 0;
  card16tocard8ssa = 0;
  card16tocard32ssa = 0;
  card16tocard64ssa = 0;
  card32tocard8ssa = 0;
  card32tocard16ssa = 0;
  card32tocard64ssa = 0;
  card64tocard8ssa = 0;
  card64tocard16ssa = 0;
  card64tocard32ssa = 0;

  int8toint16ssa = 0;
  int8toint32ssa = 0;
  int8toint64ssa = 0;
  int16toint8ssa = 0;
  int16toint32ssa = 0;
  int16toint64ssa = 0;
  int32toint8ssa = 0;
  int32toint16ssa = 0;
  int32toint64ssa = 0;
  int64toint8ssa = 0;
  int64toint16ssa = 0;
  int64toint32ssa = 0;

  card8toint8ssa = 0;
  card8toint16ssa = 0;
  card8toint32ssa = 0;
  card8toint64ssa = 0;
  card16toint8ssa = 0;
  card16toint16ssa = 0;
  card16toint32ssa = 0;
  card16toint64ssa = 0;
  card32toint8ssa = 0;
  card32toint16ssa = 0;
  card32toint32ssa = 0;
  card32toint64ssa = 0;
  card64toint8ssa = 0;
  card64toint16ssa = 0;
  card64toint32ssa = 0;
  card64toint64ssa = 0;

  int8tocard8ssa = 0;
  int8tocard16ssa = 0;
  int8tocard32ssa = 0;
  int8tocard64ssa = 0;
  int16tocard8ssa = 0;
  int16tocard16ssa = 0;
  int16tocard32ssa = 0;
  int16tocard64ssa = 0;
  int32tocard8ssa = 0;
  int32tocard16ssa = 0;
  int32tocard32ssa = 0;
  int32tocard64ssa = 0;
  int64tocard8ssa = 0;
  int64tocard16ssa = 0;
  int64tocard32ssa = 0;
  int64tocard64ssa = 0;

  not1ssa = 0;
  not32ssa = 0;
  
  negcard32ssa = 0;
  negint32ssa = 0;
  negflo64ssa = 0;

  mulcard32ssa = 0;
  mulint32ssa = 0;
  mulflo64ssa = 0;
  addint32ssa = 0;
  subint32ssa = 0;
  addpoint32ssa = 0;
  subpossa = 0;
  addflo64ssa = 0;
  subflo64ssa = 0;

  addimmint32ssa = 0;
  mulimmint32ssa = 0;
  offsetpoimm32ssa = 0;

  incdecsegimmint32ssa = 0;
  incdecsegimmpo32ssa = 0;

  incdeclocimmint32ssa = 0;
  incdeclocimmpo32ssa = 0;

  incdecparimmint32ssa = 0;
  incdecparimmpo32ssa = 0;

  incdecparindiimmint32ssa = 0;
  incdecparindiimmpo32ssa = 0;

  incdecindiimmint32ssa = 0;
  incdecindiimmpo32ssa = 0;

  incsegint32ssa = 0;
  incsegpo32ssa = 0;

  inclocint32ssa = 0;
  inclocpo32ssa = 0;

  incparint32ssa = 0;
  incparpo32ssa = 0;

  incparindiint32ssa = 0;
  incparindipo32ssa = 0;

  incindiint32ssa = 0;
  incindipo32ssa = 0;

  decsegint32ssa = 0;
  decsegpo32ssa = 0;

  declocint32ssa = 0;
  declocpo32ssa = 0;

  decparint32ssa = 0;
  decparpo32ssa = 0;

  decparindiint32ssa = 0;
  decparindipo32ssa = 0;

  decindiint32ssa = 0;
  decindipo32ssa = 0;

  cmpeqpossa = 0;
  cmpeqboolssa = 0;
  cmpeqint32ssa = 0;
  cmpeqflo64ssa = 0;

  cmpnepossa = 0;
  cmpneboolssa = 0;
  cmpneint32ssa = 0;
  cmpneflo64ssa = 0;

  cmpgtpossa = 0;
  cmpgtboolssa = 0;
  cmpgtcard32ssa = 0;
  cmpgtint32ssa = 0;
  cmpgtflo64ssa = 0;

  cmpltpossa = 0;
  cmpltboolssa = 0;
  cmpltcard32ssa = 0;
  cmpltint32ssa = 0;
  cmpltflo64ssa = 0;

  cmpgepossa = 0;
  cmpgeboolssa = 0;
  cmpgecard32ssa = 0;
  cmpgeint32ssa = 0;
  cmpgeflo64ssa = 0;

  cmplepossa = 0;
  cmpleboolssa = 0;
  cmplecard32ssa = 0;
  cmpleint32ssa = 0;
  cmpleflo64ssa = 0;

  storesegnilssa = 0;
  storereg0nilssa = 0;
  storeframenilssa = 0;
  storestacknilssa = 0;
  storestackrefnilssa = 0;
  storesegnilarssa = 0;
  storeframenilarssa = 0;
  storereg0nilarssa = 0;
  storestacknilarssa = 0;
  storestackrefnilarssa = 0;

  finirefsizesegssa = 0;
  finirefsizeframessa = 0;
  finirefsizereg0ssa = 0;
  finirefsizestackssa = 0;
  finirefsizestackrefssa = 0;
  finirefsizeframearssa = 0;
  finirefsizesegarssa = 0;
  finirefsizereg0arssa = 0;
  finirefsizestackarssa = 0;
  finirefsizestackrefarssa = 0;

  increfsizesegssa = 0;
  increfsizeframessa = 0;
  increfsizereg0ssa = 0;
  increfsizestackssa = 0;
  increfsizestackrefssa = 0;
  increfsizeframearssa = 0;
  increfsizesegarssa = 0;
  increfsizereg0arssa = 0;
  increfsizestackarssa = 0;
  increfsizestackrefarssa = 0;

  decrefsizesegssa = 0;
  decrefsizeframessa = 0;
  decrefsizereg0ssa = 0;
  decrefsizestackssa = 0;
  decrefsizestackrefssa = 0;
  decrefsizeframearssa = 0;
  decrefsizesegarssa = 0;
  decrefsizereg0arssa = 0;
  decrefsizestackarssa = 0;
  decrefsizestackrefarssa = 0;

  popseg8ssa = 0;
  popseg16ssa = 0;
  popseg32ssa = 0;
  popseg64ssa = 0;
  popsegpossa = 0;
  popsegf16ssa = 0;
  popsegf32ssa = 0;
  popsegf64ssa = 0;
  popsegssa = 0;

  poploc8ssa = 0;
  poploc16ssa = 0;
  poploc32ssa = 0;
  poploc64ssa = 0;
  poplocpossa = 0;
  poplocf16ssa = 0;
  poplocf32ssa = 0;
  poplocf64ssa = 0;
  poplocssa = 0;

  poplocindi8ssa = 0;
  poplocindi16ssa = 0;
  poplocindi32ssa = 0;
  poplocindi64ssa = 0;
  poplocindipossa = 0;
  poplocindif16ssa = 0;
  poplocindif32ssa = 0;
  poplocindif64ssa = 0;
  poplocindissa = 0;

  poppar8ssa = 0;
  poppar16ssa = 0;
  poppar32ssa = 0;
  poppar64ssa = 0;
  popparpossa = 0;
  popparf16ssa = 0;
  popparf32ssa = 0;
  popparf64ssa = 0;
  popparssa = 0;

  popparindi8ssa = 0;
  popparindi16ssa = 0;
  popparindi32ssa = 0;
  popparindi64ssa = 0;
  popparindipossa = 0;
  popparindif16ssa = 0;
  popparindif32ssa = 0;
  popparindif64ssa = 0;
  popparindissa = 0;

  pushnilssa = 0;
  pushstack8ssa = 0;
  pushstack16ssa = 0;
  pushstack32ssa = 0;
  pushstack64ssa = 0;
  pushstackpossa = 0;
  pushstackindi8ssa = 0;
  pushstackindi16ssa = 0;
  pushstackindi32ssa = 0;
  pushstackindi64ssa = 0;
  pushstackindipossa = 0;
  pushsegaddressssa = 0;

  pushseg8ssa = 0;
  pushseg16ssa = 0;
  pushseg32ssa = 0;
  pushseg64ssa = 0;
  pushsegpossa = 0;
  pushsegf16ssa = 0;
  pushsegf32ssa = 0;
  pushsegf64ssa = 0;
  pushsegssa = 0;

  pushloc8ssa = 0;
  pushloc16ssa = 0;
  pushloc32ssa = 0;
  pushloc64ssa = 0;
  pushlocpossa = 0;
  pushlocf16ssa = 0;
  pushlocf32ssa = 0;
  pushlocf64ssa = 0;
  pushlocssa = 0;

  pushlocindi8ssa = 0;
  pushlocindi16ssa = 0;
  pushlocindi32ssa = 0;
  pushlocindi64ssa = 0;
  pushlocindipossa = 0;
  pushlocindif16ssa = 0;
  pushlocindif32ssa = 0;
  pushlocindif64ssa = 0;
  pushlocindissa = 0;

  pushpar8ssa = 0;
  pushpar16ssa = 0;
  pushpar32ssa = 0;
  pushpar64ssa = 0;
  pushparpossa = 0;
  pushparf16ssa = 0;
  pushparf32ssa = 0;
  pushparf64ssa = 0;
  pushparssa = 0;

  pushaddrssa = 0;
  pushlocaddrssa = 0;
//  pushlocaddrindissa = 0;
  pushsegaddrssa = 0;
//  pushsegaddrindissa = 0;
  pushstackaddrssa = 0;
//  pushstackaddrindissa = 0;

  pushduppossa = 0;
  
  indirect8ssa = 0;
  indirect16ssa = 0;
  indirect32ssa = 0;
  indirect64ssa = 0;
  indirectpossa = 0;
  indirectf16ssa = 0;
  indirectf32ssa = 0;
  indirectf64ssa = 0;
  indirectpooffsssa = 0;
  indirectoffspossa = 0;
  indirectssa = 0;

  popindirect8ssa = 0;
  popindirect16ssa = 0;
  popindirect32ssa = 0;
  popindirect64ssa = 0;
  popindirectpossa = 0;
  popindirectf16ssa = 0;
  popindirectf32ssa = 0;
  popindirectf64ssa = 0;
  popindirectssa = 0;

  callssa = 0;
  callfuncssa = 0;
  calloutssa = 0;
  callfuncoutssa = 0;
  callvirtssa = 0;
  callintfssa = 0;
  virttrampolinessa = 0;

  callindissa = 0;
  callfuncindissa = 0;

  locvarpushssa = 0;
  locvarpopssa = 0;

  subbeginssa = 0;
  subendssa = 0;
  externalsubssa = 0;
  returnssa = 0;
  returnfuncssa = 0;

  initclassssa = 0;
  destroyclassssa = 0;

  setlengthstr8ssa = 0;
  setlengthdynarrayssa = 0;

  raisessa = 0;
  pushcpucontextssa = 0;
  popcpucontextssa = 0;
  finiexceptionssa = 0;
  continueexceptionssa = 0;
  getmemssa = 0;
  getzeromemssa = 0;
  freememssa = 0;
  setmemssa = 0;
  
  lineinfossa = 0;

//ssa only
  nestedvarssa = 0;
  popnestedvarssa = 0;
//  popsegaggregatessa = 0;
  pushnestedvarssa = 0;
  aggregatessa = 0;
  allocssa = 0;
  nestedcalloutssa = 0;
  hascalloutssa = 0;

  pushsegaddrnilssa = 0;
  pushsegaddrglobvarssa = 0;
  pushsegaddrglobconstssa = 0;
  pushsegaddrclassdefssa = 0;
    
{$include optable.inc}

function run(const asegments: segmentbuffersty): integer;
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
 while not cpu.stop do begin
  optable[cpu.pc^.op.op].proc();
  inc(cpu.pc);
 end;
 result:= exitcodeaddress^;
// result:= pinteger(segments[seg_globvar].basepo)^;
end;

function run(const stackdepht: integer): integer;
var
 segs: segmentbuffersty;
 seg1: segmentty;
begin
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
 result:= run(segs);
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

 
function getoptable: poptablety;
begin
 result:= @optable;
end;
{
function getssatable: pssatablety;
begin
 result:= @ssatable;
end;
}
{
procedure allocproc(const asize: integer; var address: segaddressty);
begin
 //dummy
end;
}
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
