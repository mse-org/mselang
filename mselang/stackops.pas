{ MSElang Copyright (c) 2013-2017 by Martin Schreiber

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
// vfloat64ty = flo64;
// pvfloat64ty = ^vfloat64ty;
// vfloat32ty = flo32;
// pvfloat32ty = ^vfloat32ty;
 vpointerty = pointer;
 pvpointerty = ^vpointerty;
 vsizety = ptrint;
 voffsty = ptrint;
const
 vpointersize = sizeof(vpointerty);
type
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
  frame: vpointerty; //lsb -> constructor flag
  link: vpointerty;     //todo: remove link field
  managedtemp: vpointerty;
  stacktemp: vpointerty;
 end;
 pframeinfoty = ^frameinfoty;
 infoopty = procedure(const opinfo: popinfoty);

 segmentbufferty = record
  base: pointer;
  size: integer;
 end;
 segmentbuffersty = array[segmentty] of segmentbufferty;
 
function alignsize(const size: ptruint): ptruint; 
                         {$ifdef mse_inline}inline;{$endif}
            //todo: align startaddress
procedure addreloc(const asource: segmentty; const adest: segaddressty);
procedure finalize;
function run(const stackdepht: integer): integer; //returns exitcode
function run(const asegments: segmentbuffersty): integer; //returns exitcode

function getoptable: poptablety;
//function getssatable: pssatablety;

implementation
uses
 msestrings,sysutils,handlerglob,mseformatstr,msetypes,internaltypes,
 mserttiutils,errorhandler,
 segmentutils,classhandler,interfacehandler,__mla__internaltypes,
 mseapplication;

const
 temprefcount = 1;
   
type
 cputy = record
  pc: popinfoty;
  stack: pointer;
  frame: pointer;
  managedtemp: pointer;
  stacktemp: pointer;
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
 alloccount: int32;
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

function getmem1(const size: ptruint): pointer;
begin
 getmem(result,size);
 inc(alloccount);
end;

procedure freemem1(const mem: pointer);
begin
 freemem(mem);
 dec(alloccount);
end;

procedure notimplemented();
begin
 notimplementederror(' Stackops OP not implemented');
 cpu.stop:= true;
end;
 
procedure internalerror(const atext: string);
begin
 raise exception.create('Internal error '+atext);
end;
{
function getstackaddress(const aaddress: stackaddressty): pointer;
begin
 result:= cpu.stack + aaddress.address;
end;
}
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
 if af_stacktemp in aaddress.t.flags then begin
  result:= cpu.stacktemp + aaddress.tempdataaddress.a.address; //offset?
 end
 else begin
  if af_managedtemp in aaddress.t.flags then begin
   result:= cpu.managedtemp + aaddress.tempdataaddress.a.address; //offset?
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
end;

function gettempaddress(const aaddress: tempaddressty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 result:= cpu.stacktemp + aaddress.address; //offset?
end;

function getlocaddressindi(const aaddress: memopty): pointer; 
                                          {$ifdef mse_inline}inline;{$endif}
var
 i1: integer;
 po1: pointer;
begin
 if af_stacktemp in aaddress.t.flags then begin
  result:= ppointer(cpu.stacktemp + aaddress.tempdataaddress.a.address)^; //offset?
 end
 else begin
  if af_managedtemp in aaddress.t.flags then begin
   result:= ppointer(cpu.managedtemp + aaddress.tempdataaddress.a.address)^; //offset?
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
end;

function getstackaddress(const aaddress: tempdataaddressty): pointer;
begin
 result:= cpu.stack + aaddress.a.address + aaddress.offset;
end;

function alignsize(const size: ptruint): ptruint; 
                             {$ifdef mse_inline}inline;{$endif}
begin
 result:= (size+(alignstep-1)) and alignmask;
end;

type
 relocinfoty = record
  source: segmentty;
  dest: segaddressty;
 end;
 prelocinfoty = ^relocinfoty;
 
procedure addreloc(const asource: segmentty; const adest: segaddressty);
var
 p1: prelocinfoty;
begin
 p1:= allocsegmentpo(seg_reloc,sizeof(relocinfoty));
 p1^.source:= asource;
 p1^.dest:= adest;
end;

function intgetmem(const size: integer): pointer;
begin
 result:= getmem1(size);
end;

function intgetzeromem(const size: integer): pointer;
begin
 result:= getmem1(size);
 fillchar(result^,size,0);
end;

function intgetzeroedmem(const allocsize: integer;
                           const nullsize: integer): pointer;
begin
 result:= getmem1(allocsize);
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
 freemem1(mem);
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

function popimmop(): pointer;
begin
 with cpu.pc^.par do begin
  result:= stackpop(bytesizes[imm.datasize]);
 end;
end;

function pushimmop(): pointer;
begin
 with cpu.pc^.par do begin
  result:= stackpush(bytesizes[imm.datasize]);
 end;
end;

function popbinop(): pointer;
begin
 with cpu.pc^.par do begin
  result:= stackpop(bytesizes[stackop.t.kind]);
 end;
end;

function pushbinop(): pointer;
begin
 with cpu.pc^.par do begin
  result:= stackpush(bytesizes[stackop.t.kind]);
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

procedure phiop();
begin
 //dummy
end;

procedure gotoop();
begin
 cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
end;

procedure gotofalseop();
var
 po1: pointer;
begin
 if not pvbooleanty(cpu.stack-alignsize(sizeof(vbooleanty)))^ then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
 end;
end;

procedure gototrueop();
var
 po1: pointer;
begin
 if pvbooleanty(cpu.stack-alignsize(sizeof(vbooleanty)))^ then begin
  cpu.pc:= startpo + cpu.pc^.par.opaddress.opaddress;
 end;
end;

procedure beginparseop();
begin
 with cpu.pc^ do begin
  finihandler:= par.beginparse.finisub;
  halting:= false;
  cpu.pc:= startpo + par.beginparse.mainad - 1;
  alloccount:= 0;
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
var
 p1,pe: ppointer;
begin
 cpu.stacklink:= cpu.frame;
 cpu.frame:= cpu.stack;
 with cpu.pc^.par do begin
  stackpush(main.stackop.managedtempsize);
  pe:= cpu.stack;
  cpu.stacktemp:= pe;
  p1:= pointer(pe)-main.stackop.managedtempsize;
  cpu.managedtemp:= p1;
  while p1 < pe do begin
   p1^:= nil;
   inc(p1);
  end;
  stackpush(main.stackop.tempsize);
  exitcodeaddress:= pint32(segments[main.exitcodeaddress.segment].basepo+
                                                 main.exitcodeaddress.address);
 end; 
end;

procedure progendop();
begin
 cpu.frame:= cpu.stacklink;
 cpu.stack:= cpu.frame;
// cpu.temp:= cpu.tempbefore;

{
 with cpu.pc^.par.progend do begin
  exitcode:= pint32(segments[exitcodeaddress.segment].basepo+
                                                 exitcodeaddress.address)^;
 end;
}
 cpu.stop:= true;
 if alloccount <> 0 then begin
  writeln('********** Memory alloc error ',alloccount,' blocks');
 end;
end;

procedure cmpjmpneimmop();
begin
 with cpu.pc^.par do begin
  case cmpjmpimm.imm.datasize of
   das_8: begin
    if pint8(cpu.stack-alignsize(sizeof(int8)))^ <> 
                                   cmpjmpimm.imm.vint8 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_16: begin
    if pint16(cpu.stack-alignsize(sizeof(int16)))^ <> 
                                    cmpjmpimm.imm.vint16 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_32: begin
    if pint32(cpu.stack-alignsize(sizeof(int32)))^ <> 
                                    cmpjmpimm.imm.vint32 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_64: begin
    if pint64(cpu.stack-alignsize(sizeof(int64)))^ <> 
                                   cmpjmpimm.imm.vint64 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
  end;
 end;
end;

procedure cmpjmpeqimmop();
begin
 with cpu.pc^.par do begin
  case cmpjmpimm.imm.datasize of
   das_8: begin
    if pint32(cpu.stack-alignsize(sizeof(int8)))^ = 
                                      cmpjmpimm.imm.vint8 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_16: begin
    if pint16(cpu.stack-alignsize(sizeof(int16)))^ = 
                                     cmpjmpimm.imm.vint16 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_32: begin
    if pint32(cpu.stack-alignsize(sizeof(int32)))^ = 
                                     cmpjmpimm.imm.vint32 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_64: begin
    if pint64(cpu.stack-alignsize(sizeof(int64)))^ = 
                                     cmpjmpimm.imm.vint64 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
  end;
 end;
end;

procedure cmpjmploimmop();
begin
 with cpu.pc^.par do begin
  case cmpjmpimm.imm.datasize of
   das_8: begin
    if pint32(cpu.stack-alignsize(sizeof(int8)))^ < 
                                       cmpjmpimm.imm.vint8 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_16: begin
    if pint16(cpu.stack-alignsize(sizeof(int16)))^ < 
                                      cmpjmpimm.imm.vint16 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_32: begin
    if pint32(cpu.stack-alignsize(sizeof(int32)))^ < 
                                      cmpjmpimm.imm.vint32 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_64: begin
    if pint64(cpu.stack-alignsize(sizeof(int64)))^ < 
                                     cmpjmpimm.imm.vint64 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
  end;
 end;
end;

procedure cmpjmploeqimmop();
begin
 with cpu.pc^.par do begin
  case cmpjmpimm.imm.datasize of
   das_8: begin
    if pint8(cpu.stack-alignsize(sizeof(int8)))^ <= 
                                    cmpjmpimm.imm.vint8 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_16: begin
    if pint16(cpu.stack-alignsize(sizeof(int16)))^ <= 
                                    cmpjmpimm.imm.vint16 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_32: begin
    if pint32(cpu.stack-alignsize(sizeof(int32)))^ <= 
                                    cmpjmpimm.imm.vint32 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_64: begin
    if pint64(cpu.stack-alignsize(sizeof(int64)))^ <= 
                                    cmpjmpimm.imm.vint64 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
  end;
 end;
end;

procedure cmpjmpgtimmop();
begin
 with cpu.pc^.par do begin
  case cmpjmpimm.imm.datasize of
   das_8: begin
    if pint8(cpu.stack-alignsize(sizeof(int8)))^ > 
                                    cmpjmpimm.imm.vint8 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_16: begin
    if pint16(cpu.stack-alignsize(sizeof(int16)))^ > 
                                   cmpjmpimm.imm.vint16 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_32: begin
    if pint32(cpu.stack-alignsize(sizeof(int32)))^ > 
                                   cmpjmpimm.imm.vint32 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
   das_64: begin
    if pint64(cpu.stack-alignsize(sizeof(int64)))^ > 
                                   cmpjmpimm.imm.vint64 then begin
     cpu.pc:= startpo + cmpjmpimm.destad.opaddress;
    end;
   end;
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

procedure writecardinal8op();
begin
 write(card8((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writecardinal16op();
begin
 write(card16((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writecardinal32op();
begin
 write(card32((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writecardinal64op();
begin
 write(card64((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writeinteger8op();
begin
 write(int8((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writeinteger16op();
begin
 write(int16((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writeinteger32op();
begin
 write(int32((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writeinteger64op();
begin
 write(int64((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writefloat32op();
begin
 write(flo32((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writefloat64op();
begin
 write(flo64((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writechar8op();
begin
 write(char8((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writechar16op();
begin
 write(char16((cpu.stack+cpu.pc^.par.voffset)^));
end;

procedure writechar32op();
begin
 write(ucs4tostring(card32((cpu.stack+cpu.pc^.par.voffset)^)));
end;

procedure checkstring(const astring: pstringheaderty);
begin
 if (astring^.len < 0) or (astring^.len > 1000) then begin
  internalerror('Invalid string');
 end;
end;

procedure writestring8op();
var
 po1: pointer;
 po2: pstringheaderty;
 str1: string;
begin
 po1:= pointer((cpu.stack+cpu.pc^.par.voffset)^);
 if po1 <> nil then begin
  po2:= po1-sizeof(stringheaderty);
  checkstring(po2);
  setlength(str1,po2^.len);
  move(po1^,pointer(str1)^,po2^.len);
  write(str1);
 end;
end;

procedure writestring16op();
var
 po1: pointer;
 po2: pstringheaderty;
 str1: unicodestring;
begin
 po1:= pointer((cpu.stack+cpu.pc^.par.voffset)^);
 if po1 <> nil then begin
  po2:= po1-sizeof(stringheaderty);
  checkstring(po2);
  setlength(str1,po2^.len);
  move(po1^,pointer(str1)^,po2^.len*2);
  write(str1);
 end;
end;

procedure writestring32op();
var
 po1: pointer;
 po2: pstringheaderty;
 str1: unicodestring;
 ps,pe: pcard32;
 pd: pcard16;
 c1: card32;
begin
 po1:= pointer((cpu.stack+cpu.pc^.par.voffset)^);
 if po1 <> nil then begin
  po2:= po1-sizeof(stringheaderty);
  checkstring(po2);
  setlength(str1,po2^.len*2); //max
  ps:= po1;
  pe:= ps+po2^.len;
  pd:= pointer(str1);
  while ps < pe do begin
   c1:= ps^;
   if c1 < $10000 then begin
    pd^:= c1;
   end
   else begin
    pd^:= (c1 shr 10) and $3ff or $d800;
    inc(pd);
    pd^:= c1 and $3ff or $dc00;
   end;
   inc(pd);   
   inc(ps);
  end;
  setlength(str1,pd-pcard16(pointer(str1)));
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

procedure swapstackop; //todo: use local buffer for small sizes
var
 po1: pointer;
 ps,pd: pointer;
begin
 with cpu.pc^.par.swapstack do begin
  po1:= getmem1(size);
  ps:= cpu.stack-size;
  pd:= cpu.stack+offset;
  move(ps^,po1^,size);
  move(pd^,(pd+size)^,-offset-size);
  move(po1^,pd^,size);
  freemem1(po1);
 end;
end;

procedure movestackop;
var
 ps,pd: pointer;
begin
 with cpu.pc^.par.swapstack do begin
  ps:= cpu.stack-size;
  pd:= ps+offset;
  move(ps^,pd^,size);
 end;
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
 pint64(stackpush(8))^:= cpu.pc^.par.imm.vint64; 
end;

procedure pushimmf32op();
begin
 pflo32(stackpush(4))^:= cpu.pc^.par.imm.vflo32; 
end;

procedure pushimmf64op();
begin
 pflo64(stackpush(8))^:= cpu.pc^.par.imm.vflo64; 
end;

procedure pushimmdatakindop();
begin
 vdatakindty(stackpushnoalign(sizeof(vdatakindty))^):= 
                                       cpu.pc^.par.imm.vdatakind; 
end;

procedure card8toflo32op();       //todo: 32bit!
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card8));
 flo32(stackpush(sizeof(flo32))^):= card8(po1^);
end;

procedure card16toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card16));
 flo32(stackpush(sizeof(flo32))^):= card16(po1^);
end;

procedure card32toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card32));
 flo32(stackpush(sizeof(flo32))^):= card32(po1^);
end;

procedure card64toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card64));
 flo32(stackpush(sizeof(flo32))^):= card64(po1^);
end;

procedure int8toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int8));
 flo32(stackpush(sizeof(flo32))^):= int8(po1^);
end;

procedure int16toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int16));
 flo32(stackpush(sizeof(flo32))^):= int16(po1^);
end;

procedure int32toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int32));
 flo32(stackpush(sizeof(flo32))^):= int32(po1^);
end;

procedure int64toflo32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int64));
 flo32(stackpush(sizeof(flo32))^):= int64(po1^);
end;

procedure card8toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card8));
 flo64(stackpush(sizeof(flo64))^):= card8(po1^);
end;

procedure card16toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card16));
 flo64(stackpush(sizeof(flo64))^):= card16(po1^);
end;

procedure card32toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card32));
 flo64(stackpush(sizeof(flo64))^):= card32(po1^);
end;

procedure card64toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(card64));
 flo64(stackpush(sizeof(flo64))^):= card64(po1^);
end;

procedure int8toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int8));
 flo64(stackpush(sizeof(flo64))^):= int8(po1^);
end;

procedure int16toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int16));
 flo64(stackpush(sizeof(flo64))^):= int16(po1^);
end;

procedure int32toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int32));
 flo64(stackpush(sizeof(flo64))^):= int32(po1^);
end;

procedure int64toflo64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(int64));
 flo64(stackpush(sizeof(flo64))^):= int64(po1^);
end;

procedure potoint32op();
var
 po1: ppointer;
begin
 po1:= stackpop(sizeof(vpointerty));
 vintegerty(stackpush(sizeof(vintegerty))^):= vintegerty(po1^);
end;

procedure inttopoop();
begin
 //dummy
end;

procedure potopoop();
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

procedure andop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) and card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) and card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) and card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) and card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure or1op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 vbooleanty(po2^):= vbooleanty(po2^) or vbooleanty(po1^);
end;

procedure orop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) or card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) or card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) or card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) or card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure xor1op();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= po1-alignsize(sizeof(vbooleanty));
 vbooleanty(po2^):= vbooleanty(po2^) xor vbooleanty(po1^);
end;

procedure xorop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) xor card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) xor card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) xor card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) xor card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure shlop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) shl card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) shl card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) shl card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) shl card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
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
procedure shrop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) shr card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) shr card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) shr card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) shr card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure mulcardop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) * card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) * card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) * card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) * card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure mulintop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= int8(po2^) * int8(po1^);
   end;
   das_16: begin
    int16(po3^):= int16(po2^) * int16(po1^);
   end;
   das_32: begin
    int32(po3^):= int32(po2^) * int32(po1^);
   end;
   das_64: begin
    int64(po3^):= int64(po2^) * int64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure divcardop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) div card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) div card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) div card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) div card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure divintop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= int8(po2^) div int8(po1^);
   end;
   das_16: begin
    int16(po3^):= int16(po2^) div int16(po1^);
   end;
   das_32: begin
    int32(po3^):= int32(po2^) div int32(po1^);
   end;
   das_64: begin
    int64(po3^):= int64(po2^) div int64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure modcardop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= card8(po2^) mod card8(po1^);
   end;
   das_16: begin
    card16(po3^):= card16(po2^) mod card16(po1^);
   end;
   das_32: begin
    card32(po3^):= card32(po2^) mod card32(po1^);
   end;
   das_64: begin
    card64(po3^):= card64(po2^) mod card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure modintop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= int8(po2^) mod int8(po1^);
   end;
   das_16: begin
    int16(po3^):= int16(po2^) mod int16(po1^);
   end;
   das_32: begin
    int32(po3^):= int32(po2^) mod int32(po1^);
   end;
   das_64: begin
    int64(po3^):= int64(po2^) mod int64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure mulimmintop();
var
 po2,po3: pointer;
begin
 po2:= popimmop();
 po3:= pushimmop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= int8(po2^) * cpu.pc^.par.imm.vint32;
   end;
   das_16: begin
    int16(po3^):= int16(po2^) * cpu.pc^.par.imm.vint32;
   end;
   das_32: begin
    int32(po3^):= int32(po2^) * cpu.pc^.par.imm.vint32;
   end;
   das_64: begin
    int64(po3^):= int64(po2^) * cpu.pc^.par.imm.vint32;
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure mulfloop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_f64: begin
    flo64(po3^):= flo64(po2^) * flo64(po1^);
   end;
   das_f32: begin
    flo32(po3^):= flo32(po2^) * flo32(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure divfloop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_f64: begin
    flo64(po3^):= flo64(po2^) / flo64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure addintop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= int8(po2^) + int8(po1^);
   end;
   das_16: begin
    int16(po3^):= int16(po2^) + int16(po1^);
   end;
   das_32: begin
    int32(po3^):= int32(po2^) + int32(po1^);
   end;
   das_64: begin
    int64(po3^):= int64(po2^) + int64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure subintop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= int8(po2^) - int8(po1^);
   end;
   das_16: begin
    int16(po3^):= int16(po2^) - int16(po1^);
   end;
   das_32: begin
    int32(po3^):= int32(po2^) - int32(po1^);
   end;
   das_64: begin
    int64(po3^):= int64(po2^) - int64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure addpointop();
var
 po1,po2: pointer;
begin
 po1:= popbinop();
 po2:= po1-alignsize(sizeof(vpointerty));
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    inc(pvpointerty(po2)^,int8(po1^));
   end;
   das_16: begin
    inc(pvpointerty(po2)^,int16(po1^));
   end;
   das_32: begin
    inc(pvpointerty(po2)^,int32(po1^));
   end;
   das_64: begin
    inc(pvpointerty(po2)^,int64(po1^));
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure subpointop();
var
 po1,po2: pointer;
begin
 po1:= popbinop();
 po2:= po1-alignsize(sizeof(vpointerty));
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    dec(pvpointerty(po2)^,int8(po1^));
   end;
   das_16: begin
    dec(pvpointerty(po2)^,int16(po1^));
   end;
   das_32: begin
    dec(pvpointerty(po2)^,int32(po1^));
   end;
   das_64: begin
    dec(pvpointerty(po2)^,int64(po1^));
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure subpoop();
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= po1-alignsize(sizeof(vpointerty));
 vintegerty(po2^):= vpointerty(po2^)-vpointerty(po1^);
end;

procedure addimmintop();
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)+cpu.pc^.par.imm.vint32;
end;

procedure offsetpoimmop();
var
 po1: pointer;
begin
 po1:= cpu.stack - alignsize(sizeof(vpointerty));
 vpointerty(po1^):= vpointerty(po1^)+cpu.pc^.par.imm.vint32;
end;

procedure incdecsegimmintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getsegaddress(mem.segdataaddress);
  case mem.t.kind of
   das_8: begin
    inc(pint8(po1)^,vint32);
   end;
   das_16: begin
    inc(pint16(po1)^,vint32);
   end;
   das_32: begin
    inc(pint32(po1)^,vint32);
   end;
   das_64: begin
    inc(pint64(po1)^,vint32);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure incdecsegimmpoop();
var
 po1: ppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getsegaddress(mem.segdataaddress);
  inc(po1^,vint32);
 end; 
end;

procedure incdeclocimmintop();
var
 po1: pointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  case mem.t.kind of
   das_8: begin
    inc(pint8(po1)^,vint32);
   end;
   das_16: begin
    inc(pint16(po1)^,vint32);
   end;
   das_32: begin
    inc(pint32(po1)^,vint32);
   end;
   das_64: begin
    inc(pint64(po1)^,vint32);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incdeclocimmpoop();
var
 po1: ppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  case mem.operanddatasize of
   das_8: begin
    inc(pint8(po1)^,vint32);
   end;
   das_16: begin
    inc(pint16(po1)^,vint32);
   end;
   das_32: begin
    inc(pint32(po1)^,vint32);
   end;
   das_64: begin
    inc(pint64(po1)^,vint32);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incdecparimmintop();
begin
 incdeclocimmintop();
end;

procedure incdecparimmpoop();
begin
 incdeclocimmpoop();
end;

procedure incdecparindiimmintop();
var
 po1: pointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  case mem.t.kind of
   das_8: begin
    inc(ppint8(po1)^^,vint32);
   end;
   das_16: begin
    inc(ppint16(po1)^^,vint32);
   end;
   das_32: begin
    inc(ppint32(po1)^^,vint32);
   end;
   das_64: begin
    inc(ppint64(po1)^^,vint32);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incdecparindiimmpoop();
var
 po1: pppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= getlocaddress(mem);
  inc(po1^^,vint32);
 end; 
end;

procedure incdecindiimmintop();
var
 po1: pointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= stackpop(sizeof(vpointerty));
  case mem.t.kind of
   das_8: begin
    inc(ppint8(po1)^^,vint32);
   end;
   das_16: begin
    inc(ppint16(po1)^^,vint32);
   end;
   das_32: begin
    inc(ppint32(po1)^^,vint32);
   end;
   das_64: begin
    inc(ppint64(po1)^^,vint32);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incdecindiimmpoop();
var
 po1: pppointer;
begin
 with cpu.pc^.par.memimm do begin
  po1:= stackpop(sizeof(vpointerty));
  inc(po1^^,vint32);
 end; 
end;

function popmemop(): pointer;
begin
 with cpu.pc^.par do begin
//  result:= stackpop(bytesizes[memop.t.kind]);
  result:= stackpop(bytesizes[memop.operanddatasize]);
 end;
end;

procedure incsegintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  po2:= popmemop();
  case operanddatasize of
   das_8: begin
    inc(pint8(po1)^,pint8(po2)^);
   end;
   das_16: begin
    inc(pint16(po1)^,pint16(po2)^);
   end;
   das_32: begin
    inc(pint32(po1)^,pint32(po2)^);
   end;
   das_64: begin
    inc(pint64(po1)^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incsegpoop();
var
 po1,po2: ppointer;
 i1: int32;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  po2:= popmemop();
  case operanddatasize of
   das_8: begin
    inc(po1^,pint8(po2)^);
   end;
   das_16: begin
    inc(po1^,pint16(po2)^);
   end;
   das_32: begin
    inc(po1^,pint32(po2)^);
   end;
   das_64: begin
    inc(po1^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure inclocintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(pint8(po1)^,pint8(po2)^);
   end;
   das_16: begin
    inc(pint16(po1)^,pint16(po2)^);
   end;
   das_32: begin
    inc(pint32(po1)^,pint32(po2)^);
   end;
   das_64: begin
    inc(pint64(po1)^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure inclocpoop();
var
 po1,po2: ppointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(po1^,pint8(po2)^);
   end;
   das_16: begin
    inc(po1^,pint16(po2)^);
   end;
   das_32: begin
    inc(po1^,pint32(po2)^);
   end;
   das_64: begin
    inc(po1^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incparintop();
begin
 inclocintop();
end;

procedure incparpoop();
begin
 inclocpoop();
end;

procedure incparindiintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(ppint8(po1)^^,pint8(po2)^);
   end;
   das_16: begin
    inc(ppint16(po1)^^,pint16(po2)^);
   end;
   das_32: begin
    inc(ppint32(po1)^^,pint32(po2)^);
   end;
   das_64: begin
    inc(ppint64(po1)^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incparindipoop();
var
 po1,po2: pppointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(po1^^,pint8(po2)^);
   end;
   das_16: begin
    inc(po1^^,pint16(po2)^);
   end;
   das_32: begin
    inc(po1^^,pint32(po2)^);
   end;
   das_64: begin
    inc(po1^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incindiintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= stackpop(sizeof(vpointerty));
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(ppint8(po1)^^,pint8(po2)^);
   end;
   das_16: begin
    inc(ppint16(po1)^^,pint16(po2)^);
   end;
   das_32: begin
    inc(ppint32(po1)^^,pint32(po2)^);
   end;
   das_64: begin
    inc(ppint64(po1)^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure incindipoop();
var
 po1,po2: pppointer;
begin
 with cpu.pc^.par do begin
  po1:= stackpop(sizeof(vpointerty));
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(po1^^,pint8(po2)^);
   end;
   das_16: begin
    inc(po1^^,pint16(po2)^);
   end;
   das_32: begin
    inc(po1^^,pint32(po2)^);
   end;
   das_64: begin
    inc(po1^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure decsegintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  po2:= popmemop();
  case operanddatasize of
   das_8: begin
    dec(pint8(po1)^,pint8(po2)^);
   end;
   das_16: begin
    dec(pint16(po1)^,pint16(po2)^);
   end;
   das_32: begin
    dec(pint32(po1)^,pint32(po2)^);
   end;
   das_64: begin
    dec(pint64(po1)^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure decsegpoop();
var
 po1: ppointer;
 po2: pointer;
begin
 with cpu.pc^.par.memop do begin
  po1:= getsegaddress(segdataaddress);
  po2:= popmemop();
  case operanddatasize of
   das_8: begin
    dec(po1^,pint8(po2)^);
   end;
   das_16: begin
    dec(po1^,pint16(po2)^);
   end;
   das_32: begin
    dec(po1^,pint32(po2)^);
   end;
   das_64: begin
    dec(po1^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure declocintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    dec(pint8(po1)^,pint8(po2)^);
   end;
   das_16: begin
    dec(pint16(po1)^,pint16(po2)^);
   end;
   das_32: begin
    dec(pint32(po1)^,pint32(po2)^);
   end;
   das_64: begin
    dec(pint64(po1)^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure declocpoop();
var
 po1: ppointer;
 po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    dec(po1^,pint8(po2)^);
   end;
   das_16: begin
    dec(po1^,pint16(po2)^);
   end;
   das_32: begin
    dec(po1^,pint32(po2)^);
   end;
   das_64: begin
    dec(po1^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure decparintop();
begin
 declocintop();
end;

procedure decparpoop();
begin
 declocpoop();
end;

procedure decparindiintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    dec(ppint8(po1)^^,pint8(po2)^);
   end;
   das_16: begin
    dec(ppint16(po1)^^,pint16(po2)^);
   end;
   das_32: begin
    dec(ppint32(po1)^^,pint32(po2)^);
   end;
   das_64: begin
    dec(ppint64(po1)^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure decparindipoop();
var
 po1: pppointer;
 po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= getlocaddress(memop);
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    inc(po1^^,pint8(po2)^);
   end;
   das_16: begin
    inc(po1^^,pint16(po2)^);
   end;
   das_32: begin
    inc(po1^^,pint32(po2)^);
   end;
   das_64: begin
    inc(po1^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure decindiintop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= stackpop(sizeof(vpointerty));
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    dec(ppint8(po1)^^,pint8(po2)^);
   end;
   das_16: begin
    dec(ppint16(po1)^^,pint16(po2)^);
   end;
   das_32: begin
    dec(ppint32(po1)^^,pint32(po2)^);
   end;
   das_64: begin
    dec(ppint64(po1)^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure decindipoop();
var
 po1: pppointer;
 po2: pointer;
begin
 with cpu.pc^.par do begin
  po1:= stackpop(sizeof(vpointerty));
  po2:= popmemop();
  case memop.operanddatasize of
   das_8: begin
    dec(po1^^,pint8(po2)^);
   end;
   das_16: begin
    dec(po1^^,pint16(po2)^);
   end;
   das_32: begin
    dec(po1^^,pint32(po2)^);
   end;
   das_64: begin
    dec(po1^^,pint64(po2)^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end; 
end;

procedure cmppoop();
var
 po1,po2: pvpointerty;
begin
 po1:= stackpop(sizeof(vpointerty));
 po2:= stackpop(sizeof(vpointerty));
 with cpu.pc^.par do begin
  case stackop.compkind of
   cok_eq: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
   end;
   cok_ne: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <> po1^;
   end;
   cok_gt: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ > po1^;
   end;
   cok_lt: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ < po1^;
   end;
   cok_ge: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ >= po1^;
   end;
   cok_le: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <= po1^;
   end;
  end;
 end;
end;

procedure cmpboolop();
var
 po1,po2: pvbooleanty;
begin
 po1:= stackpop(sizeof(vbooleanty));
 po2:= stackpop(sizeof(vbooleanty));
 with cpu.pc^.par do begin
  case stackop.compkind of
   cok_eq: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ = po1^;
   end;
   cok_ne: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <> po1^;
   end;
   cok_gt: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ > po1^;
   end;
   cok_lt: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ < po1^;
   end;
   cok_ge: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ >= po1^;
   end;
   cok_le: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ <= po1^;
   end;
  end;
 end;
end;

procedure cmpintop();
var
 po1,po2: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 with cpu.pc^.par do begin
  case stackop.compkind of
   cok_eq: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint8(po2)^ = pint8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint16(po2)^ = pint16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint32(po2)^ = pint32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint64(po2)^ = pint64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_ne: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint8(po2)^ <> pint8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint16(po2)^ <> pint16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint32(po2)^ <> pint32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint64(po2)^ <> pint64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_gt: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint8(po2)^ > pint8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint16(po2)^ > pint16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint32(po2)^ > pint32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint64(po2)^ > pint64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_lt: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint8(po2)^ < pint8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint16(po2)^ < pint16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint32(po2)^ < pint32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint64(po2)^ < pint64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_ge: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint8(po2)^ >= pint8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint16(po2)^ >= pint16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint32(po2)^ >= pint32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint64(po2)^ >= pint64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_le: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint8(po2)^ <= pint8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint16(po2)^ <= pint16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint32(po2)^ <= pint32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pint64(po2)^ <= pint64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
  end;
 end;
end;

procedure cmpcardop();
var
 po1,po2: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 with cpu.pc^.par do begin
  case stackop.compkind of
   cok_eq: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard8(po2)^ = pcard8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard16(po2)^ = pcard16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard32(po2)^ = pcard32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard64(po2)^ = pcard64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_ne: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard8(po2)^ <> pcard8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard16(po2)^ <> pcard16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard32(po2)^ <> pcard32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard64(po2)^ <> pcard64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_gt: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard8(po2)^ > pcard8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard16(po2)^ > pcard16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard32(po2)^ > pcard32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard64(po2)^ > pcard64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_lt: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard8(po2)^ < pcard8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard16(po2)^ < pcard16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard32(po2)^ < pcard32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard64(po2)^ < pcard64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_ge: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard8(po2)^ >= pcard8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard16(po2)^ >= pcard16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard32(po2)^ >= pcard32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard64(po2)^ >= pcard64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_le: begin
    case stackop.t.kind of
     das_8: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard8(po2)^ <= pcard8(po1)^;
     end;
     das_16: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard16(po2)^ <= pcard16(po1)^;
     end;
     das_32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard32(po2)^ <= pcard32(po1)^;
     end;
     das_64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pcard64(po2)^ <= pcard64(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
  end;
 end;
end;

procedure cmpfloop();
var
 po1,po2: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 with cpu.pc^.par do begin
  case stackop.compkind of
   cok_eq: begin
    case stackop.t.kind of
     das_f64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo64(po2)^ = pflo64(po1)^;
     end;
     das_f32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo32(po2)^ = pflo32(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_ne: begin
    case stackop.t.kind of
     das_f64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo64(po2)^ <> pflo64(po1)^;
     end;
     das_f32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo32(po2)^ <> pflo32(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_gt: begin
    case stackop.t.kind of
     das_f64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo64(po2)^ > pflo64(po1)^;
     end;
     das_f32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo32(po2)^ > pflo32(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_lt: begin
    case stackop.t.kind of
     das_f64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo64(po2)^ < pflo64(po1)^;
     end;
     das_f32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo32(po2)^ < pflo32(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_ge: begin
    case stackop.t.kind of
     das_f64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo64(po2)^ >= pflo64(po1)^;
     end;
     das_f32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo32(po2)^ >= pflo32(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
   cok_le: begin
    case stackop.t.kind of
     das_f64: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo64(po2)^ <= pflo64(po1)^;
     end;
     das_f32: begin
      vbooleanty(stackpush(sizeof(vbooleanty))^):= pflo32(po2)^ <= pflo32(po1)^;
     end;
     else begin
      internalerror('20160716A');
     end;
    end;
   end;
  end;
 end;
end;

function compstring8(a,b: pointer): stringsizety;
var
 poa,poe,pob: pcard8;
 s1,s2: stringsizety;
 i1: int8;
 
begin
 result:= 0;
 if a <> b then begin
  if a = nil then begin
   if b <> nil then begin
    result:= -1;
   end;
  end
  else begin
   if b = nil then begin
    result:= 1;
   end
   else begin
    poa:= a;
    pob:= b;
    s1:= (pstringheaderty(a)-1)^.len;
    s2:= (pstringheaderty(b)-1)^.len;
    if s1 < s2 then begin
     poe:= poa + s1;
    end
    else begin
     poe:= poa + s2;
    end;
    while true do begin
     i1:= poa^-pob^;
     if i1 <> 0 then begin
      result:= i1;
      exit;
     end;
     inc(poa);
     if poa >= poe then begin
      break;
     end;
     inc(pob);
    end;
    if i1 = 0 then begin
     result:= s1 - s2;
    end;
   end;
  end;
 end;
end;

function compstring16(a,b: pointer): stringsizety;
var
 poa,poe,pob: pcard16;
 s1,s2: stringsizety;
 i1: int16;
 
begin
 result:= 0;
 if a <> b then begin
  if a = nil then begin
   if b <> nil then begin
    result:= -1;
   end;
  end
  else begin
   if b = nil then begin
    result:= 1;
   end
   else begin
    poa:= a;
    pob:= b;
    s1:= (pstringheaderty(a)-1)^.len;
    s2:= (pstringheaderty(b)-1)^.len;
    if s1 < s2 then begin
     poe:= poa + s1;
    end
    else begin
     poe:= poa + s2;
    end;
    while true do begin
     i1:= poa^-pob^;
     if i1 <> 0 then begin
      result:= i1;
      exit;
     end;
     inc(poa);
     if poa >= poe then begin
      break;
     end;
     inc(pob);
    end;
    if i1 = 0 then begin
     result:= s1 - s2;
    end;
   end;
  end;
 end;
end;

function compstring32(a,b: pointer): stringsizety;
var
 poa,poe,pob: pcard32;
 s1,s2: stringsizety;
 i1: int32;
 
begin
 result:= 0;
 if a <> b then begin
  if a = nil then begin
   if b <> nil then begin
    result:= -1;
   end;
  end
  else begin
   if b = nil then begin
    result:= 1;
   end
   else begin
    poa:= a;
    pob:= b;
    s1:= (pstringheaderty(a)-1)^.len;
    s2:= (pstringheaderty(b)-1)^.len;
    if s1 < s2 then begin
     poe:= poa + s1;
    end
    else begin
     poe:= poa + s2;
    end;
    while true do begin
     i1:= poa^-pob^;
     if i1 <> 0 then begin
      result:= i1;
      exit;
     end;
     inc(poa);
     if poa >= poe then begin
      break;
     end;
     inc(pob);
    end;
    if i1 = 0 then begin
     result:= s1 - s2;
    end;
   end;
  end;
 end;
end;


procedure cmpstringop();
var
 po1,po2: ppointer;
 i1: stringsizety;
begin
 po1:= stackpop(sizeof(pointer));
 po2:= stackpop(sizeof(pointer));
 with cpu.pc^.par do begin
  case stackop.t.size of
   1: begin
    i1:= compstring8(po2^,po1^);
   end;
   2: begin
    i1:= compstring16(po2^,po1^);
   end;
   4: begin
    i1:= compstring32(po2^,po1^);
   end;
   else begin
    internalerror('20170403A');
   end;
  end;

  case stackop.compkind of
   cok_eq: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= i1 = 0;
   end;
   cok_ne: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= i1 <> 0;
   end;
   cok_gt: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= i1 > 0;
   end;
   cok_lt: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= i1 < 0;
   end;
   cok_ge: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= i1 >= 0;
   end;
   cok_le: begin
    vbooleanty(stackpush(sizeof(vbooleanty))^):= i1 <= 0;
   end;
  end;
 end;
end;

procedure setcontainsop();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= tintegerset(po2^) <= 
                                                         tintegerset(po1^);
end;

procedure setinop();
var
 po1,po2: pvintegerty;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= stackpop(sizeof(vintegerty));
 vbooleanty(stackpush(sizeof(vbooleanty))^):= po2^ in tintegerset(po1^);
end;

procedure classisop();
var
 po1,po2: pointer;
 b1: boolean;
 i1: targetptrintty;
begin
 with cpu.pc^.par do begin
  po1:= ppointer(stackpop(sizeof(vpointerty)))^; //instance
  po2:= ppointer(stackpop(sizeof(vpointerty)))^; //instance
  b1:= false;
  if (po1 <> nil) and (po2 <> nil) then begin
   po1:= ppointer(po1+imm.vint32)^;
   po2:= ppointer(po2+imm.vint32)^;
   while true do begin
    if po1 = po2 then begin
     b1:= true;
     break;
    end;
    i1:= classdefinfopoty(po1)^.header.parentclass;
    if i1 < 0 then begin
     break;
    end;
    po1:= getsegmentpo(seg_classdef,i1);
   end;
  end;
 end;
 pboolean(stackpush(sizeof(vbooleanty)))^:= b1;
end;

procedure addfloop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_f64: begin
    flo64(po3^):= flo64(po2^) + flo64(po1^);
   end;
   das_f32: begin
    flo32(po3^):= flo32(po2^) + flo32(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure subfloop();
var
 po1,po2,po3: pointer;
begin
 po1:= popbinop();
 po2:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_f64: begin
    flo64(po3^):= flo64(po2^) - flo64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure diffsetop(); //todo: arbitrary size
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) and not vintegerty(po1^);
end;

procedure xorsetop(); //todo: arbitrary size
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) xor vintegerty(po1^);
end;

procedure setbitop(); //todo: arbitrary size
var
 po1,po2: pointer;
begin
 po1:= stackpop(sizeof(vintegerty));
 po2:= po1-alignsize(sizeof(vintegerty));
 vintegerty(po2^):= vintegerty(po2^) or (1 shl vintegerty(po1^));
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

procedure flo32toflo64op();
var
 da1: flo32;
begin
 da1:= pflo32(stackpop(sizeof(flo32)))^;
 pflo64(stackpush(sizeof(flo64)))^:= da1;
end;

procedure flo64toflo32op();
var
 da1: flo64;
begin
 da1:= pflo64(stackpop(sizeof(flo64)))^;
 pflo32(stackpush(sizeof(flo32)))^:= da1;
end;

procedure truncint32flo64op();
var
 da1: flo64;
begin
 da1:= pflo64(stackpop(sizeof(flo64)))^;
 pint32(stackpush(sizeof(int32)))^:= trunc(da1);
end;

procedure truncint32flo32op();
var
 da1: flo32;
begin
 da1:= pflo32(stackpop(sizeof(flo32)))^;
 pint32(stackpush(sizeof(int32)))^:= trunc(da1);
end;

procedure truncint64flo64op();
var
 da1: flo64;
begin
 da1:= pflo64(stackpop(sizeof(flo64)))^;
 pint64(stackpush(sizeof(int64)))^:= trunc(da1);
end;

procedure trunccard32flo64op();
var
 da1: flo64;
begin
 da1:= pflo64(stackpop(sizeof(flo64)))^;
 pcard32(stackpush(sizeof(int32)))^:= trunc(da1);
end;

procedure trunccard32flo32op();
var
 da1: flo32;
begin
 da1:= pflo32(stackpop(sizeof(flo32)))^;
 pcard32(stackpush(sizeof(int32)))^:= trunc(da1);
end;

procedure trunccard64flo64op();
var
 da1: flo64;
begin
 da1:= pflo64(stackpop(sizeof(flo64)))^;
 pcard64(stackpush(sizeof(int64)))^:= trunc(da1);
end;


procedure card1toint32op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(int8));
 if odd(pcard8(po1)^) then begin
  pint32(po1)^:= 1;
 end
 else begin
  pint32(po1)^:= 0;
 end;
end;

function getcodepoint(var ps: pcard8; const pe: pcard8; 
                                  out ares: card32): boolean;

 procedure error();
 begin
  ares:= ord('?');
  result:= false;
 end;
   
 function checkok(var acodepoint: card32): boolean; //inline;
 var
  c1: card8;
 begin
  result:= false;
  inc(ps);
  if ps >= pe then begin
   error();
  end
  else begin
   c1:= ps^ - %10000000;
   if c1 > %00111111 then begin
    error();
   end
   else begin
    acodepoint:= (acodepoint shl 6) or c1;
    result:= true;
   end;
  end;
 end;

begin
 result:= true;
 if ps^ < %10000000 then begin   //1 byte
  ares:= ps^;
 end
 else begin
  if ps^ <= %11100000 then begin //2 bytes
   ares:= ps^ and %00011111;
   if checkok(ares) then begin
    if ares < %1000000 then begin
     error(); //overlong
    end;
   end;
  end
  else begin
   if ps^ < %11110000 then begin //3 bytes
    ares:= ps^ and %00001111;
    if checkok(ares) and checkok(ares) then begin
     if ares < %100000000000 then begin
      error(); //overlong
     end;
    end;
   end
   else begin
    if ps^ < %11111000 then begin //4 bytes
     ares:= ps^ and %00000111;
     if checkok(ares) and checkok(ares) and checkok(ares) then begin
      if ares < %10000000000000000 then begin
       error(); //overlong
      end;
     end;
    end
    else begin
     error();
    end;
   end;
  end;
 end;
 inc(ps);
 if (ares >= $d800) and (ares <= $dfff) then begin
  error;
 end;
end;

function getcodepoint(var ps: pcard16; const pe: pcard16; 
                                  out ares: card32): boolean;

 procedure error();
 begin
  ares:= ord('?');
  result:= false;
 end;

begin
 result:= true;
 ares:= ps^;
 inc(ps);
 if ares and $fc00 = $d800 then begin
  ares:= (ares - $d800) shl 10;
  if ps < pe then begin 
   ares:= ares + ps^ - $dc00 + $10000;
   inc(ps);
   if ares < $10000 then begin
    error; //overlong;
   end;
  end
  else begin
   error(); //missing surrogate
  end;
 end;
 if (ares >= $d800) and (ares <= $dfff) then begin
  error; //surrogate pair
 end;
end;

procedure string8to16op();
var
 pss,pds: pstringheaderty;
 p1,pe: pcard8;
 p2,p3: pcard16;
 c1: card32;
begin
 pss:= ppointer(stackpop(sizeof(pointer)))^;
 if pss <> nil then begin
  p1:= pointer(pss);
  dec(pss); //header
  pe:= p1+pss^.len;
  pds:= getmem1(string16allocsize+pss^.len*2); //max 
                                            //todo: use less memory
  p2:= pointer(pds+1);
  p3:= p2;
  while p1 < pe do begin
   getcodepoint(p1,pe,c1);
   if c1 < $10000 then begin
    p2^:= c1;
   end
   else begin
    c1:= c1 - $10000;
    p2^:= (c1 shr 10) and $3ff or $d800;
    inc(p2);
    p2^:= c1 and $3ff or $dc00;
   end;
   inc(p2);
  end;
  p2^:= 0;
  pds^.ref.count:= temprefcount;; //will be incremented by assign
  pds^.len:= p2-p3;
  inc(pds); //data
 end
 else begin
  pds:= nil;
 end;
 ppointer(stackpush(sizeof(pointer)))^:= pds;
end;

procedure string8to32op();
var
 pss,pds: pstringheaderty;
 p1,pe: pcard8;
 p2,p3: pcard32;
 c1: card32;
begin
 pss:= ppointer(stackpop(sizeof(pointer)))^;
 if pss <> nil then begin
  p1:= pointer(pss);
  dec(pss); //header
  pe:= p1+pss^.len;
  pds:= getmem1(string32allocsize+pss^.len*4); //max 
                                            //todo: use less memory
  p2:= pointer(pds+1);
  p3:= p2;
  while p1 < pe do begin
   getcodepoint(p1,pe,p2^);
   inc(p2);
  end;
  p2^:= 0;
  pds^.ref.count:= temprefcount;; //will be incremented by assign
  pds^.len:= p2-p3;
  inc(pds); //data
 end
 else begin
  pds:= nil;
 end;
 ppointer(stackpush(sizeof(pointer)))^:= pds;
end;

procedure setutf8(const codepoint: card32; var dest: pcard8);
begin
 if codepoint < $80 then begin
  dest^:= codepoint;
 end
 else begin
  if codepoint < $800 then begin //2 byte
   dest^:= (codepoint shr 6) or %11000000;
   inc(dest);
   dest^:= codepoint and %00111111 or %10000000;
  end
  else begin
   if codepoint < $10000 then begin //3 byte
    dest^:= (codepoint shr 12) or %11100000;
    inc(dest);
    dest^:= (codepoint shr 6) and %00111111 or %10000000;
    inc(dest);
    dest^:= codepoint and %00111111 or %10000000;
   end
   else begin                       //4 byte
    dest^:= (codepoint shr 18) or %11110000;
    inc(dest);
    dest^:= (codepoint shr 12) and %00111111 or %10000000;
    inc(dest);
    dest^:= (codepoint shr 6) and %00111111 or %10000000;
    inc(dest);
    dest^:= codepoint and %00111111 or %10000000;
   end;
  end;
 end;
 inc(dest);
end;

procedure string16to8op();
var
 pss,pds: pstringheaderty;
 p1,pe: pcard16;
 p2,p3: pcard8;
 c1: card32;
begin
 pss:= ppointer(stackpop(sizeof(pointer)))^;
 if pss <> nil then begin
  p1:= pointer(pss);
  dec(pss); //header
  pe:= p1+pss^.len;
  pds:= getmem1(string8allocsize+pss^.len*3); //max 
                                            //todo: use less memory
  p2:= pointer(pds+1);
  p3:= p2;
  while p1 < pe do begin
   getcodepoint(p1,pe,c1);
   setutf8(c1,p2);
  end;
  p2^:= 0;
  pds^.ref.count:= temprefcount;; //will be incremented by assign
  pds^.len:= p2-p3;
  inc(pds); //data
 end
 else begin
  pds:= nil;
 end;
 ppointer(stackpush(sizeof(pointer)))^:= pds;
end;

procedure string16to32op();
var
 pss,pds: pstringheaderty;
 p1,pe: pcard16;
 p2,p3: pcard32;
 c1: card32;
begin
 pss:= ppointer(stackpop(sizeof(pointer)))^;
 if pss <> nil then begin
  p1:= pointer(pss);
  dec(pss); //header
  pe:= p1+pss^.len;
  pds:= getmem1(string8allocsize+pss^.len*4);
  p2:= pointer(pds+1);
  p3:= p2;
  while p1 < pe do begin
   getcodepoint(p1,pe,p2^); 
   inc(p2);
  end;
  p2^:= 0;
  pds^.ref.count:= temprefcount;; //will be incremented by assign
  pds^.len:= p2-p3;
  inc(pds); //data
 end
 else begin
  pds:= nil;
 end;
 ppointer(stackpush(sizeof(pointer)))^:= pds;
end;

procedure string32to8op();
var
 pss,pds: pstringheaderty;
 p1,pe: pcard32;
 p2,p3: pcard8;
 c1: card32;
begin
 pss:= ppointer(stackpop(sizeof(pointer)))^;
 if pss <> nil then begin
  p1:= pointer(pss);
  dec(pss); //header
  pe:= p1+pss^.len;
  pds:= getmem1(string8allocsize+pss^.len*4); //max 
                                            //todo: use less memory
  p2:= pointer(pds+1);
  p3:= p2;
  while p1 < pe do begin
   setutf8(p1^,p2);
   inc(p1);
  end;
  p2^:= 0;
  pds^.ref.count:= temprefcount;; //will be incremented by assign
  pds^.len:= p2-p3;
  inc(pds); //data
 end
 else begin
  pds:= nil;
 end;
 ppointer(stackpush(sizeof(pointer)))^:= pds;
end;

procedure string32to16op();
var
 pss,pds: pstringheaderty;
 p1,pe: pcard32;
 p2,p3: pcard16;
 c1: card32;
begin
 pss:= ppointer(stackpop(sizeof(pointer)))^;
 if pss <> nil then begin
  p1:= pointer(pss);
  dec(pss); //header
  pe:= p1+pss^.len;
  pds:= getmem1(string16allocsize+pss^.len*2*2); //max 
                                            //todo: use less memory
  p2:= pointer(pds+1);
  p3:= p2;
  while p1 < pe do begin
   c1:= p1^;
   inc(p1);
   if c1 < $10000 then begin
    p2^:= c1;
   end
   else begin
    c1:= c1 - $10000;
    p2^:= (c1 shr 10) and $3ff or $d800;
    inc(p2);
    p2^:= c1 and $3ff or $dc00;
   end;
   inc(p2);
  end;
  p2^:= 0;
  pds^.ref.count:= temprefcount;; //will be incremented by assign
  pds^.len:= p2-p3;
  inc(pds); //data
 end
 else begin
  pds:= nil;
 end;
 ppointer(stackpush(sizeof(pointer)))^:= pds;
end;

procedure concatstring8op();
var
 p1,ps,pe: ppstringheaderty;
 i1: int32;
 p0,p3: pstringheaderty;
 p4: pcard8;
begin
 with cpu.pc^.par do begin
  pe:= cpu.stack;
  ps:= pe - listinfo.alloccount;
  p1:= ps;
  i1:= 0;
  while p1 < pe do begin
   p0:= p1^;
   if p0 <> nil then begin
    i1:= i1+(p0-1)^.len;
   end;
   inc(p1);
  end;
  if i1 > 0 then begin
   p3:= getmem1(string8allocsize+i1*1);
   p3^.ref.count:= temprefcount;;
   p3^.len:= i1;
   inc(p3);
   p4:= pointer(p3);
   (p4+i1)^:= 0; //terminating 0
   p1:= ps;
   while p1 < pe do begin
    p0:= p1^;
    if p0 <> nil then begin
     i1:= (p0-1)^.len;
     move(p0^,p4^,i1);
     inc(p4,i1);
    end;
    inc(p1);
   end;
   ps^:= pointer(p3);
  end
  else begin
   ps^:= nil;
  end;
  stackpop(sizeof(pointer)*(listinfo.alloccount-1));
 end;
end;

procedure concatstring16op();
var
 p1,ps,pe: ppstringheaderty;
 i1: int32;
 p0,p3: pstringheaderty;
 p4: pcard16;
begin
 with cpu.pc^.par do begin
  pe:= cpu.stack;
  ps:= pe - listinfo.alloccount;
  p1:= ps;
  i1:= 0;
  while p1 < pe do begin
   p0:= p1^;
   if p0 <> nil then begin
    i1:= i1+(p0-1)^.len;
   end;
   inc(p1);
  end;
  if i1 > 0 then begin
   p3:= getmem1(string16allocsize+i1*2);
   p3^.ref.count:= temprefcount;;
   p3^.len:= i1;
   inc(p3);
   p4:= pointer(p3);
   (p4+i1)^:= 0; //terminating 0
   p1:= ps;
   while p1 < pe do begin
    p0:= p1^;
    if p0 <> nil then begin
     i1:= (p0-1)^.len;
     move(p0^,p4^,i1*2);
     inc(p4,i1);
    end;
    inc(p1);
   end;
   ps^:= pointer(p3);
  end
  else begin
   ps^:= nil;
  end;
  stackpop(sizeof(pointer)*(listinfo.alloccount-1));
 end;
end;

procedure concatstring32op();
var
 p1,ps,pe: ppstringheaderty;
 i1: int32;
 p0,p3: pstringheaderty;
 p4: pcard32;
begin
 with cpu.pc^.par do begin
  pe:= cpu.stack;
  ps:= pe - listinfo.alloccount;
  p1:= ps;
  i1:= 0;
  while p1 < pe do begin
   p0:= p1^;
   if p0 <> nil then begin
    i1:= i1+(p0-1)^.len;
   end;
   inc(p1);
  end;
  if i1 > 0 then begin
   p3:= getmem1(string32allocsize+i1*4);
   p3^.ref.count:= temprefcount;;
   p3^.len:= i1;
   inc(p3);
   p4:= pointer(p3);
   (p4+i1)^:= 0; //terminating 0
   p1:= ps;
   while p1 < pe do begin
    p0:= p1^;
    if p0 <> nil then begin
     i1:= (p0-1)^.len;
     move(p0^,p4^,i1*4);
     inc(p4,i1);
    end;
    inc(p1);
   end;
   ps^:= pointer(p3);
  end
  else begin
   ps^:= nil;
  end;
  stackpop(sizeof(pointer)*(listinfo.alloccount-1));
 end;
end;

procedure chartostring8op();
var
 char1: card8;
 po1: pstringheaderty;
begin
 char1:= pcard8(stackpop(sizeof(card8)))^;
 po1:= getmem1(1*1 + string8allocsize);
 po1^.len:= 1;
 po1^.ref.count:= 1;
 pcard8(@po1^.data)^:= char1;
 (pcard8(@po1^.data)+1)^:= 0;
 ppointer(stackpush(sizeof(pointer)))^:= po1+1; //-> data
end;

procedure arraytoopenarop();
var
 po1: targetpointerty;
begin
 po1:= ptargetpointerty(stackpop(sizeof(targetpointerty)))^;
 with popenarrayty(stackpush(sizeof(openarrayty)))^ do begin
  high:=  cpu.pc^.par.imm.vint32;
  data:= po1;
 end;
end;

procedure dynarraytoopenarop();
var
 po1: targetpointerty;
begin
 po1:= ptargetpointerty(stackpop(sizeof(targetpointerty)))^;
 with popenarrayty(stackpush(sizeof(openarrayty)))^ do begin
  high:=  system.high(bytearty(po1));
  data:= po1;
 end;
end;

procedure listtoopenarop();
var
 pd,pe,ps,po1,po2: pointer;
 i1,i2: int32;
begin
 with cpu.pc^.par do begin
  i1:= listinfo.itemsize;
  i2:= alignsize(i1);
  po1:= gettempaddress(listinfo.tempad);
  pd:= po1;
  pe:= pd + listinfo.alloccount * i1;
  po2:= cpu.stack - listinfo.alloccount * i2;
  ps:= po2;
  case listinfo.itemsize of
   1: begin
    while pd < pe do begin
     pcard8(pd)^:= pcard8(ps)^;
     inc(pd,i1);
     inc(ps,i2);
    end;
   end;
   2: begin
    while pd < pe do begin
     pcard16(pd)^:= pcard16(ps)^;
     inc(pd,i1);
     inc(ps,i2);
    end;
   end;
   4: begin
    while pd < pe do begin
     pcard32(pd)^:= pcard32(ps)^;
     inc(pd,i1);
     inc(ps,i2);
    end;
   end;
   8: begin
    while pd < pe do begin
     pcard64(pd)^:= pcard64(ps)^;
     inc(pd,i1);
     inc(ps,i2);
    end;
   end;
   else begin
    while pd < pe do begin
     move(ps^,pd^,i1);
     inc(pd,i1);
     inc(ps,i2);
    end;
   end;
  end;
  cpu.stack:= po2; //remove list
  with popenarrayty(stackpush(sizeof(openarrayty)))^ do begin
   high:=  listinfo.alloccount-1;
   data:= ptrint(po1);
  end;
 end;
end;

procedure combinemethodop();
var                            //classinstance,subaddress
 poa,pob: ppointer;
 po1: pointer;
begin
 poa:= stacktop(sizeof(pointer));
 pob:= poa-1;
 po1:= poa^;
 poa^:= pob^;      //swap values
 pob^:= po1;
end;

procedure getmethodcodeop();
begin
 notimplemented();
end;

procedure getmethoddataop();
begin
 notimplemented();
end;

procedure not1op();
var
 po1: pointer;
begin
 po1:= stacktop(sizeof(vbooleanty));
 vbooleanty(po1^):= not vbooleanty(po1^);
end;

procedure notop();
var
 po1,po3: pointer;
begin
 po1:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= not card8(po1^);
   end;
   das_16: begin
    card16(po3^):= not card16(po1^);
   end;
   das_32: begin
    card32(po3^):= not card32(po1^);
   end;
   das_64: begin
    card64(po3^):= not card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure negcardop();
var
 po1,po3: pointer;
begin
 po1:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    card8(po3^):= -card8(po1^);
   end;
   das_16: begin
    card16(po3^):= -card16(po1^);
   end;
   das_32: begin
    card32(po3^):= -card32(po1^);
   end;
   das_64: begin
    card64(po3^):= -card64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure negintop();
var
 po1,po3: pointer;
begin
 po1:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= -int8(po1^);
   end;
   das_16: begin
    int16(po3^):= -int16(po1^);
   end;
   das_32: begin
    int32(po3^):= -int32(po1^);
   end;
   das_64: begin
    int64(po3^):= -int64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure negfloop();
var
 po1,po3: pointer;
begin
 po1:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_f64: begin
    flo64(po3^):= -flo64(po1^);
   end;
   else begin
    internalerror('20160716A');
   end;
  end;
 end;
end;

procedure absintop();
var
 po1,po3: pointer;
begin
 po1:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_8: begin
    int8(po3^):= abs(int8(po1^));
   end;
   das_16: begin
    int16(po3^):= abs(int16(po1^));
   end;
   das_32: begin
    int32(po3^):= abs(int32(po1^));
   end;
   das_64: begin
    int64(po3^):= abs(int64(po1^));
   end;
   else begin
    internalerror('20170519C');
   end;
  end;
 end;
end;

procedure absfloop();
var
 po1,po3: pointer;
begin
 po1:= popbinop();
 po3:= pushbinop();
 with cpu.pc^.par do begin
  case stackop.t.kind of
   das_f64: begin
    flo64(po3^):= abs(flo64(po1^));
   end;
   else begin
    internalerror('20170519D');
   end;
  end;
 end;
end;

procedure pushnilop();
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= nil;
end;

procedure pushnilmethodop();
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= nil;
 ppointer(stackpush(sizeof(dataaddressty)))^:= nil;
end;

{
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
}
procedure pushsegaddressop();
begin
 ppointer(stackpush(sizeof(dataaddressty)))^:= 
                             getsegaddress(cpu.pc^.par.memop.segdataaddress); 
end;

procedure storesegnilop();
begin
 ppointer(getsegaddress(cpu.pc^.par.memop.segdataaddress))^:= nil;
end;

function getmanagedaddressoffset(): int32;
begin
 with cpu.pc^.par.memop.podataaddress do begin
  result:= address + offset;
 end;
end;

procedure storelocnilop();
begin
 ppointer(getlocaddress(cpu.pc^.par.memop))^:= nil;
end;

procedure storelocindinilop();
begin
 pppointer(getlocaddress(cpu.pc^.par.memop))^^:= nil;
end;

procedure storestacknilop();
begin
 ppointer(cpu.stack+getmanagedaddressoffset())^:= nil;
end;

procedure storestackrefnilop();
begin
 pppointer(cpu.stack+getmanagedaddressoffset())^^:= nil;
end;

procedure storesegnilarop();
begin
 with cpu.pc^.par.memop do begin
{$ifdef cpu64}
  fillqword(getsegaddress(segdataaddress)^,t.size,0);
{$else}
  filldword(getsegaddress(segdataaddress)^,t.size,0);
{$endif}
 end;
end;

procedure storelocnilarop();
begin
 with cpu.pc^.par do begin
 {$ifdef cpu64}
  fillqword(getlocaddress(memop)^,memop.t.size,0);
 {$else}
  fillqword(getlocaddress(memop)^,memop.t.size,0);
 {$endif}
 end;
end;

procedure storelocindinilarop();
begin
 with cpu.pc^.par do begin
 {$ifdef cpu64}
  fillqword(ppointer(getlocaddress(memop))^^,memop.t.size,0);
 {$else}
  fillqword(ppointer(getlocaddress(memop))^^,memop.t.size,0);
 {$endif}
 end;
end;

procedure storestacknilarop();
begin
{$ifdef cpu64}
 fillqword(ppointer(cpu.stack+getmanagedaddressoffset())^,
                                                  cpu.pc^.par.memop.t.size,0);
{$else}
 filldword(ppointer(cpu.stack+getmanagedaddressoffset())^,
                                                  cpu.pc^.par.memop.t.size,0);
{$endif}
end;

procedure storestackrefnilarop();
begin
{$ifdef cpu64}
 fillqword(pppointer(cpu.stack+getmanagedaddressoffset())^^,
                                                    cpu.pc^.par.memop.t.size,0);
{$else}
 filldword(pppointer(cpu.stack+getmanagedaddressoffset())^^,
                                                    cpu.pc^.par.memop.t.size,0);
{$endif}
end;

procedure storesegnildynarop();
var
 po1: pointer;
 i1: int32;
begin
 with cpu.pc^ do begin
  po1:= ppointer(getsegaddress(par.memop.segdataaddress))^;
  if po1 <> nil then begin
   i1:= (pdynarraysizety(po1)-1)^;
 {$ifdef cpu64}
   fillqword(po1^,i1,0);
 {$else}
   filldword(po1^,i1,0);
 {$endif}
  end;
 end;
end;

procedure storelocnildynarop();
var
 po1: pointer;
 i1: int32;
begin
 po1:= ppointer(getlocaddress(cpu.pc^.par.memop))^;
 if po1 <> nil then begin
  i1:= (pdynarraysizety(po1)-1)^;
{$ifdef cpu64}
  fillqword(po1^,i1,0);
{$else}
  filldword(po1^,i1,0);
{$endif}
 end;
end;

procedure storelocindinildynarop();
var
 po1: pointer;
 i1: int32;
begin
 po1:= pppointer(getlocaddress(cpu.pc^.par.memop))^^;
 if po1 <> nil then begin
  i1:= (pdynarraysizety(po1)-1)^;
{$ifdef cpu64}
  fillqword(po1^,i1,0);
{$else}
  filldword(po1^,i1,0);
{$endif}
 end;
end;

procedure storestacknildynarop();
var
 po1: pointer;
 i1: int32;
begin
 po1:= ppointer(cpu.stack+getmanagedaddressoffset())^;
 if po1 <> nil then begin
  i1:= (pdynarraysizety(po1)-1)^;
{$ifdef cpu64}
  fillqword(po1^,i1,0);
{$else}
  filldword(po1^,i1,0);
{$endif}
 end;
end;

procedure storestackrefnildynarop();
var
 po1: pointer;
 i1: int32;
begin
 po1:= pppointer(cpu.stack+getmanagedaddressoffset())^^;
 if po1 <> nil then begin
  i1:= (pdynarraysizety(po1)-1)^;
{$ifdef cpu64}
  fillqword(po1,i1,0);
{$else}
  filldword(po1,i1,0);
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
 i1: integer;
begin
 i1:= cpu.pc^.par.memop.t.size;
 move(stackpop(i1)^,getsegaddress(cpu.pc^.par.memop.segdataaddress)^,i1);
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
 i1: integer;
begin
 i1:= cpu.pc^.par.memop.t.size;
 move(getsegaddress(cpu.pc^.par.memop.segdataaddress)^,
                  stackpush(i1)^,i1);
end;
{
procedure pushsegopenarop();
begin
 with cpu.pc^.par.memimm do begin
  pint32(stackpush(sizeof(int32)))^:= vint32;
  ppointer(stackpush(sizeof(pointer)))^:= getsegaddress(mem.segdataaddress);
 end;
end;
}
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
 i1: int32;
begin
 i1:= cpu.pc^.par.memop.t.size;
 move(stackpop(i1)^,getlocaddress(cpu.pc^.par.memop)^,i1);
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
var
 po1: pointer;
begin
 po1:= getstackaddress(cpu.pc^.par.memop.tempdataaddress);
 ppointer(stackpush(sizeof(pointer)))^:= po1;
end;

procedure pushallocaddrop();
begin
 notimplemented();
end;

procedure pushstackop();
var
 po1,po2: pointer;
begin
 with cpu.pc^.par.memop do begin
  po1:= getstackaddress(tempdataaddress);
  po2:= stackpush(t.size);
  move(po1^,po2^,t.size);
 end;
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
 po1: pointer;
begin
 po1:= stackpush(sizeof(pointer));
 ppointer(po1)^:= ppointer((po1+cpu.pc^.par.voffset))^
end;

procedure storemanagedtempop();
begin
 ppointer((cpu.managedtemp+cpu.pc^.par.voffset))^:= (ppointer(cpu.stack)-1)^;
end;

procedure loadallocaop();
begin
 //dummy
end;

procedure indirect8op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv8ty(stackpush(sizeof(v8ty)))^:=  pv8ty(ppointer(po1)^)^;
end;

procedure indirect16op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv16ty(stackpush(sizeof(v16ty)))^:=  pv16ty(ppointer(po1)^)^;
end;

procedure indirect32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv32ty(stackpush(sizeof(v32ty)))^:=  pv32ty(ppointer(po1)^)^;
end;

procedure indirect64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv64ty(stackpush(sizeof(v64ty)))^:=  pv64ty(ppointer(po1)^)^;
end;

procedure indirectpoop();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-sizeof(pointer);
 ppointer(stackpush(sizeof(pointer)))^:=  ppointer(ppointer(po1)^)^;
end;

procedure indirectf16op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv16ty(stackpush(sizeof(v16ty)))^:=  pv16ty(ppointer(po1)^)^;
end;

procedure indirectf32op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv32ty(stackpush(sizeof(v32ty)))^:=  pv32ty(ppointer(po1)^)^;
end;

procedure indirectf64op();
var
 po1: pointer;
begin
 po1:= stackpop(sizeof(pointer));
// po1:= cpu.stack-alignstep;
 pv64ty(stackpush(sizeof(v64ty)))^:=  pv64ty(ppointer(po1)^)^;
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
 po1:= stackpop(8);
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
 po1:= stackpop(sizeof(float64));
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

procedure savecpu(const isconstructor: boolean);
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  if isconstructor then begin
   frame:= pointer(ptruint(frame) or 1);
  end;
  link:= cpu.stacklink;
  managedtemp:= cpu.managedtemp;
  stacktemp:= cpu.stacktemp;
 end;
end;

//first op:
//                  |cpu.frame    |cpu.stack
// params frameinfo locvars      
//
procedure docall(const isconstructor: boolean);
begin
 savecpu(isconstructor);
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
end;

procedure haltop();
begin
 if not halting and (finihandler <> 0) then begin
  halting:= true;
  dec(cpu.pc); //return to haltop()
  docall(false);
  cpu.pc:= startpo+finihandler-1;
 end
 else begin
  progendop();
//  cpu.stop:= true;
 end;
end;

procedure callop();
begin
 with cpu.pc^.par do begin
  docall(sf_constructor in callinfo.flags);
  cpu.pc:= startpo+callinfo.ad.ad;
 end;
end;

procedure callfuncop();
begin
 callop();
end;

procedure callindiop();
begin
 with cpu.pc^.par do begin
  docall(sf_constructor in callinfo.flags);
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
 savecpu(false);
{
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
  managedtemp:= cpu.managedtemp;
  stacktemp:= cpu.stacktemp;
 end;
} 
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
 savecpu(sf_constructor in cpu.pc^.par.callinfo.flags);
{
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
}
 cpu.frame:= cpu.stack;
 cpu.stacklink:= cpu.frame;
 with cpu.pc^.par.callinfo do begin
  cpu.pc:= startpo+pptruint(
  ppointer(ppointer(cpu.stack+virt.selfinstance)^+virt.virttaboffset)^+
                                                             virt.virtoffset)^;
//  cpu.pc:= startpo+pptruint(pppointer(cpu.stack+selfinstance)^^+virtoffset)^;
 end;
end;

procedure callvirtfuncop();
begin
 callvirtop();
end;

procedure callintfop();
var
 po1: ppointer;
// po2: pintfitemty;
 po3: pintfdefinfoty;
begin
 savecpu(false);
{
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= cpu.pc;
  frame:= cpu.frame;
  link:= cpu.stacklink;
 end;
}
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

procedure callintffuncop();
begin
 callintfop();
end;

procedure virttrampolineop();
begin
 with cpu.pc^.par.subbegin.trampoline do begin
  cpu.pc:= startpo +
     pptruint(
      ppointer(ppointer(cpu.frame+selfinstance)^ + virttaboffset)^ + 
                                                               virtoffset)^;
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

procedure tempallocop();
begin
 //dummy
end;

procedure subbeginop();
var
 p1,pe: ppointer;
begin
 with cpu.pc^.par.subbegin do begin
  stackpush(sub.allocs.stackop.varsize);
  pe:= cpu.stack;
  p1:= pointer(pe)-sub.allocs.stackop.managedtempsize;
  cpu.managedtemp:= p1;
  cpu.stacktemp:= p1-sub.allocs.stackop.tempsize;
  while p1 < pe do begin
   p1^:= nil;
   inc(p1);
  end;
 end;
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
 i1: integer;
 po1: pframeinfoty;
begin
 i1:= cpu.pc^.par.stacksize;
 po1:= (cpu.frame-sizeof(frameinfoty));
 with po1^ do begin
  if odd(ptruint(frame)) then begin
   dec(frame); //remove lsb
   i1:= i1 + constructorstacksize;
  end;
  cpu.pc:= pc;
  cpu.frame:= frame;
  cpu.stacklink:= link;
  cpu.managedtemp:= managedtemp;
  cpu.stacktemp:= stacktemp;
 end;
// cpu.stack:= po1 - i1;
 cpu.stack:= cpu.stack-i1;
end;

procedure returnfuncop();
begin
 returnop();
end;

procedure zeromemop();
begin
 with cpu.pc^.par do begin
  fillchar(pppointer(cpu.stack-pointersize)^^,imm.vint32,0);
 end;
end;

procedure getobjectmemop();
var
 self1: ppointer;
 po1: pointer;
begin
 with cpu.pc^.par do begin
  self1:= stackpush(pointersize);
  po1:= intgetmem(imm.vint32);
  self1^:= po1;            //class instance
//  ppointer(cpu.stack-2*pointersize)^:= po1; //result
 end;
end;

procedure getobjectzeromemop();
var
 self1: ppointer;
 po1: pointer;
begin
 with cpu.pc^.par do begin
  self1:= stackpush(pointersize);
  po1:= intgetzeromem(imm.vint32);
  self1^:= po1;            //class instance
//  ppointer(cpu.stack-2*pointersize)^:= po1; //result
 end;
end;

procedure initobjectop();
var
 po1: pointer;
 po2: classdefinfopoty;
 ps: popaddressty;
 pd: ppointer;
 pe: pointer;
begin
 with cpu.pc^.par do begin
  po2:= classdefinfopoty(segments[seg_classdef].basepo+initclass.classdef);
  po1:= ppointer(cpu.stack-pointersize)^; //object instance
  ppointer(po1+initclass.virttaboffset)^:= po2;
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
(*
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
*)
procedure destroyclassop();
begin
 with cpu.pc^.par do begin
  if dcf_nofreemem in destroyclass.flags then begin
   stackpop(sizeof(pointer));
  end
  else begin
   intfreemem(ppointer(stackpop(sizeof(pointer)))^);
  end;
 end;
end;

procedure getvirtsubadop();
var
 po1: pppointer;
begin
 with cpu.pc^.par do begin
  po1:= stacktop(sizeof(pointer));
  ppointer(stackpush(sizeof(pointer)))^:= 
                   startpo + pptruint((po1^^ + getvirtsubad.virtoffset))^;
 end;
end;

procedure getintfmethodop();
var
 po1: pppointer;
 po2: pintfdefinfoty;
 po3: pointer;
begin
 with cpu.pc^.par do begin
  po1:= stacktop(pointersize);         //interface
  po3:= po1^;                          //interface pointer in instance
  po2:= ppointer(po3)^;                //interface definition
  inc(po3,po2^.header.instanceoffset); //instance
  ppointer(stackpush(pointersize))^:= po3;                         //data
  ppointer(po1)^:= startpo + pintfitemty(pointer(po2) + 
                                  getvirtsubad.virtoffset)^.subad; //code
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
  end;
  if d^.ref.count = 0 then begin
   freemem1(d);
  end;
  ref^:= nil;
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
   end;
   if d^.ref.count = 0 then begin
    freemem1(d);
   end;
   ref^:= nil;
  end;
  inc(ref);
 end;
end;

procedure finirefsizedynar(const ref: ppointer); 
                                    {$ifdef mse_inline}inline;{$endif}
var
 r: pdynarrayheaderty;
 d: prefsizeinfoty;
 p1,pe: ppointer;
begin
 p1:= ref^;
 if p1 <> nil then begin
  r:= (pdynarrayheaderty(p1)-1);
  pe:= p1+r^.high;
  while p1 <= pe do begin
   d:= p1^;
   if d <> nil then begin
    dec(d);
    if d^.ref.count > 0 then begin
     dec(d^.ref.count);
    end;
    if d^.ref.count = 0 then begin
     freemem1(d);
     p1^:= nil;
    end;
   end;
   inc(p1);
  end;
  if r^.ref.count > 0 then begin
   dec(r^.ref.count);
  end;
  if r^.ref.count = 0 then begin
   freemem1(r);
  end;
  ref^:= nil;
 end;
end;

procedure increfsize(const ref: ppointer); {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
begin
 d:= ref^;
 if d <> nil then begin
  dec(d);
  if d^.ref.count >= 0 then begin
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
   if d^.ref.count >= 0 then begin
    inc(d^.ref.count);
   end;
  end;
  inc(ref);
 end;
end;

procedure increfsizedynar(ref: ppointer); 
                                           {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
 si1: datasizety;
begin
 if ref <> nil then begin
  for si1:= (pdynarraysizety(ref)-1)^ downto 0 do begin //high
   d:= ref^;
   if d <> nil then begin
    dec(d);
    if d^.ref.count >= 0 then begin
     inc(d^.ref.count);
    end;
   end;
   inc(ref);
  end;
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
  end;
  if d^.ref.count = 0 then begin
   freemem1(d);
  end;
//   ref^:= nil;
 end;
end;

procedure decrefsizeindi(const ref: pppointer); {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
begin
 d:= ref^^;
 if d <> nil then begin
  dec(d);
  if d^.ref.count > 0 then begin
   dec(d^.ref.count);
  end;
  if d^.ref.count = 0 then begin
   freemem1(d);
  end;
//   ref^:= nil;
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
   end;
   if d^.ref.count = 0 then begin
    freemem1(d);
   end;
   ref^:= nil; //??
  end;
  inc(ref);
 end;
end;

procedure decrefsizedynar(ref: ppointer); 
                                           {$ifdef mse_inline}inline;{$endif}
var
 d: prefsizeinfoty;
 si1: datasizety;
begin
 if ref <> nil then begin
  for si1:= (pdynarraysizety(ref)-1)^ downto 0 do begin //high
   d:= ref^;
   if d <> nil then begin
    dec(d);
    if d^.ref.count > 0 then begin
     dec(d^.ref.count);
    end;
    if d^.ref.count = 0 then begin
     freemem1(d);
    end;
    ref^:= nil; //??
   end;
   inc(ref);
  end;
 end;
end;

procedure finirefsizesegop();
begin
 finirefsize(getsegaddress(cpu.pc^.par.memop.segdataaddress));
end;

procedure finirefsizelocop();
begin
 finirefsize(ppointer(getlocaddress(cpu.pc^.par.memop)));
end;

procedure finirefsizelocindiop();
begin
 finirefsize(pppointer(getlocaddress(cpu.pc^.par.memop))^);
end;

procedure finirefsizestackop();
begin
 finirefsize(ppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure finirefsizestackrefop();
begin
 finirefsize(pppointer(cpu.stack+getmanagedaddressoffset())^);
end;

procedure finirefsizesegarop();
begin
 finirefsizear(getsegaddress(cpu.pc^.par.memop.segdataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure finirefsizelocarop();
begin
 with cpu.pc^.par do begin
  finirefsizear(ppointer(getlocaddress(memop)),memop.t.size);
 end;
end;

procedure finirefsizelocindiarop();
begin
 with cpu.pc^.par do begin
  finirefsizear(pppointer(getlocaddress(memop))^,memop.t.size);
 end;
end;

procedure finirefsizestackarop();
begin
 finirefsizear(ppointer(cpu.stack+getmanagedaddressoffset()),
                                                 cpu.pc^.par.memop.t.size);
end;

procedure finirefsizestackrefarop();
begin
 finirefsizear(pppointer(cpu.stack+getmanagedaddressoffset())^,
                                                 cpu.pc^.par.memop.t.size);
end;

procedure finirefsizesegdynarop();
begin
 finirefsizedynar(getsegaddress(cpu.pc^.par.memop.segdataaddress));
end;

procedure finirefsizelocdynarop();
begin
 finirefsizedynar(ppointer(getlocaddress(cpu.pc^.par.memop)));
end;

procedure finirefsizelocindidynarop();
begin
 finirefsizedynar(pppointer(getlocaddress(cpu.pc^.par.memop))^);
end;

procedure finirefsizestackdynarop();
begin
 finirefsizedynar(ppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure finirefsizestackrefdynarop();
begin
 finirefsizedynar(pppointer(cpu.stack+getmanagedaddressoffset())^);
end;

procedure increfsizesegop();
begin
 increfsize(getsegaddress(cpu.pc^.par.memop.segdataaddress));
end;

procedure increfsizelocop();
begin
 increfsize(ppointer(getlocaddress(cpu.pc^.par.memop)));
end;

procedure increfsizelocindiop();
begin
 increfsize(pppointer(getlocaddress(cpu.pc^.par.memop))^);
end;

procedure increfsizestackop();
begin
 increfsize(ppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure increfsizestackrefop();
begin
 increfsize(pppointer(cpu.stack+getmanagedaddressoffset())^);
end;

procedure increfsizesegarop();
begin
 increfsizear(getsegaddress(cpu.pc^.par.memop.segdataaddress),
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizelocarop();
begin
 with cpu.pc^.par do begin
  increfsizear(ppointer(getlocaddress(memop)),memop.t.size);
 end;
end;

procedure increfsizelocindiarop();
begin
 with cpu.pc^.par do begin
  increfsizear(pppointer(getlocaddress(memop))^,memop.t.size);
 end;
end;

procedure increfsizestackarop();
begin
 increfsizear(ppointer(cpu.stack+getmanagedaddressoffset()),
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizestackrefarop();
begin
 increfsizear(pppointer(cpu.stack+getmanagedaddressoffset())^,
                                             cpu.pc^.par.memop.t.size);
end;

procedure increfsizesegdynarop();
begin
 increfsizedynar(getsegaddress(cpu.pc^.par.memop.segdataaddress));
end;

procedure increfsizelocdynarop();
begin
 increfsizedynar(ppointer(getlocaddress(cpu.pc^.par.memop)));
end;

procedure increfsizelocindidynarop();
begin
 increfsizedynar(pppointer(getlocaddress(cpu.pc^.par.memop))^);
end;

procedure increfsizestackdynarop();
begin
 increfsizedynar(ppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure increfsizestackrefdynarop();
begin
 increfsizedynar(pppointer(cpu.stack+getmanagedaddressoffset())^);
end;

procedure decrefsizesegop();
begin
 decrefsize(getsegaddress(cpu.pc^.par.memop.segdataaddress));
end;

procedure decrefsizelocop();
begin
 decrefsize(ppointer(getlocaddress(cpu.pc^.par.memop)));
end;

procedure decrefsizelocindiop();
begin
 decrefsize(pppointer(getlocaddress(cpu.pc^.par.memop))^);
end;

procedure decrefsizestackop();
begin
 decrefsize(ppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure decrefsizestackrefop();
begin
 decrefsizeindi(pppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure decrefsizesegarop();
begin
 decrefsizear(getsegaddress(cpu.pc^.par.memop.segdataaddress),
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizelocarop();
begin
 with cpu.pc^.par do begin
  decrefsizear(ppointer(getlocaddress(memop)),memop.t.size);
 end;
end;

procedure decrefsizelocindiarop();
begin
 with cpu.pc^.par do begin
  decrefsizear(pppointer(getlocaddress(memop))^,memop.t.size);
 end;
end;

procedure decrefsizestackarop();
begin
 decrefsizear(ppointer(cpu.stack+getmanagedaddressoffset()),
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizestackrefarop();
begin
 decrefsizear(pppointer(cpu.stack+getmanagedaddressoffset())^,
                                                cpu.pc^.par.memop.t.size);
end;

procedure decrefsizesegdynarop();
begin
 decrefsizedynar(getsegaddress(cpu.pc^.par.memop.segdataaddress));
end;

procedure decrefsizelocdynarop();
begin
 decrefsizedynar(ppointer(getlocaddress(cpu.pc^.par.memop)));
end;

procedure decrefsizelocindidynarop();
begin
 decrefsizedynar(pppointer(getlocaddress(cpu.pc^.par.memop))^);
end;

procedure decrefsizestackdynarop();
begin
 decrefsizedynar(ppointer(cpu.stack+getmanagedaddressoffset()));
end;

procedure decrefsizestackrefdynarop();
begin
 decrefsizedynar(pppointer(cpu.stack+getmanagedaddressoffset())^);
end;

procedure highstringop();
var
 i1: int32;
begin
 i1:= high(pstring(stackpop(sizeof(pointer)))^);
 pint32(stackpush(sizeof(i1)))^:= i1;
end;

procedure highdynarop();
var
 i1: int32;
begin
 i1:= high(pbytearty(stackpop(sizeof(pointer)))^);
 pint32(stackpush(sizeof(i1)))^:= i1;
end;

procedure highopenarop();
var
 po1: popenarrayty;
begin
 po1:= popenarrayty(stackpop(sizeof(pointer))^);
 pint32(stackpush(sizeof(int32)))^:= po1^.high;
end;

procedure lengthstringop();
var
 i1: int32;
begin
 i1:= length(pstring(stackpop(sizeof(pointer)))^);
 pint32(stackpush(sizeof(i1)))^:= i1;
end;

procedure lengthdynarop();
var
 i1: int32;
begin
 i1:= length(pbytearty(stackpop(sizeof(pointer)))^);
 pint32(stackpush(sizeof(i1)))^:= i1;
end;

procedure lengthopenarop();
var
 po1: popenarrayty;
begin
 po1:= popenarrayty(stackpop(sizeof(pointer))^);
 pint32(stackpush(sizeof(int32)))^:= po1^.high+1;
end;

procedure setlengthstr8op(); //address, length
var
 si1,si2: stringsizety;
 ds,ss: pstringheaderty;
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
    freemem1(ds);
   end;
   ad^:= nil;
  end;
 end
 else begin
  if ds = nil then begin
   ds:= getmem1(si1+string8allocsize);
  end
  else begin
   if ds^.ref.count = 1 then begin
    reallocmem(ds,si1+string8allocsize);
   end
   else begin //needs copy
    ss:= ds;
    ds:= getmem1(si1+string8allocsize);
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

procedure setlengthstr16op(); //address, length
var
 si1,si2: stringsizety;
 ds,ss: pstringheaderty;
 ad: ppointer;
begin
 si1:= pstringsizety(cpu.stack-sizeof(stringsizety))^ * 2;
 ad:= ppointer(cpu.stack-(sizeof(stringsizety)+sizeof(pointer)))^;
 ds:= ad^;   //data
 if ds <> nil then begin
  dec(ds);    //header
 end;
 if si1 <= 0 then begin
  if ds <> nil then begin
   dec(ds^.ref.count);
   if ds^.ref.count = 0 then begin
    freemem1(ds);
   end;
   ad^:= nil;
  end;
 end
 else begin
  if ds = nil then begin
   ds:= getmem1(si1+string16allocsize);
  end
  else begin
   if ds^.ref.count = 1 then begin
    reallocmem(ds,si1+string16allocsize);
   end
   else begin //needs copy
    ss:= ds;
    ds:= getmem1(si1+string16allocsize);
    si2:= ss^.len*2;
    if si1 < si2 then begin
     si2:= si1;
    end;
    move((ss+1)^,(ds+1)^,si2); //get data copy
   end;
  end;
  ds^.len:= si1 div 2;
  ds^.ref.count:= 1;
  inc(ds);    //data
  pchar16(pointer(ds)+si1)^:= #0; //endmarker
  ad^:= ds;
 end;
 stackpop(pointersize+sizeof(stringsizety));
end;

procedure setlengthstr32op(); //address, length
var
 si1,si2: stringsizety;
 ds,ss: pstringheaderty;
 ad: ppointer;
begin
 si1:= pstringsizety(cpu.stack-sizeof(stringsizety))^ * 4;
 ad:= ppointer(cpu.stack-(sizeof(stringsizety)+sizeof(pointer)))^;
 ds:= ad^;   //data
 if ds <> nil then begin
  dec(ds);    //header
 end;
 if si1 <= 0 then begin
  if ds <> nil then begin
   dec(ds^.ref.count);
   if ds^.ref.count = 0 then begin
    freemem1(ds);
   end;
   ad^:= nil;
  end;
 end
 else begin
  if ds = nil then begin
   ds:= getmem1(si1+string32allocsize);
  end
  else begin
   if ds^.ref.count = 1 then begin
    reallocmem(ds,si1+string32allocsize);
   end
   else begin //needs copy
    ss:= ds;
    ds:= getmem1(si1+string32allocsize);
    si2:= ss^.len*4;
    if si1 < si2 then begin
     si2:= si1;
    end;
    move((ss+1)^,(ds+1)^,si2); //get data copy
   end;
  end;
  ds^.len:= si1 div 4;
  ds^.ref.count:= 1;
  inc(ds);    //data
  pchar32(pointer(ds)+si1)^:= 0; //endmarker
  ad^:= ds;
 end;
 stackpop(pointersize+sizeof(stringsizety));
end;

procedure setlengthdynarrayop(); //address, length
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
    freemem1(ds);
   end;
   ad^:= nil;
  end;
 end
 else begin
  itemsize1:= cpu.pc^.par.setlength.itemsize;
  sil1:= si1*itemsize1;
  if ds = nil then begin
   ds:= intgetzeromem(sil1+dynarrayallocsize);
  end
  else begin
   if ds^.ref.count = 1 then begin
    intreallocnulledmem(ds,(ds^.high+1)*itemsize1+dynarrayallocsize,
                                                    sil1+dynarrayallocsize);
   end
   else begin //needs copy
    ss:= ds;
    ds:= getmem1(sil1+dynarrayallocsize);
    sil2:= (ss^.high+1)*itemsize1;
    if sil1 < sil2 then begin
     sil2:= sil1;
    end
    else begin
     fillchar((pointer(ds+1)+sil2)^,sil1-sil2,0);
    end;    
    move((ss+1)^,(ds+1)^,sil2); //get data copy
    dec(ss^.ref.count);
   end;
  end;
  ds^.high:= si1-1;
  ds^.ref.count:= 1;
  ad^:= @ds^.data;
 end;
 stackpop(pointersize+sizeof(dynarraysizety));
end;

procedure uniquestr8op(); //address
var
 si1: stringsizety;
 ds,ss: pstringheaderty;
 ad: ppointer;
begin
 ad:= ppointer(cpu.stack-sizeof(pointer))^;
 ds:= ad^;   //data
 if ds <> nil then begin
  dec(ds);    //header
  if ds^.ref.count <> 1 then begin
   ss:= ds;
   si1:= ds^.len*1 + string8allocsize;
   ds:= getmem1(si1+string8allocsize);
   move(ss^,ds^,si1); //get copy including terminator
   if ss^.ref.count > 0 then begin //no const
    dec(ss^.ref.count);
   end;
   ds^.ref.count:= 1;
   ad^:= @ds^.data;
  end;
 end;
 stackpop(pointersize);
end;

procedure uniquestr16op();
begin
 notimplemented();
end;

procedure uniquestr32op();
begin
 notimplemented();
end;

procedure uniquedynarrayop();
var
 si1: dynarraysizety;
 ds,ss: pdynarrayheaderty;
 ad: ppointer;
begin
 ad:= ppointer(cpu.stack-sizeof(pointer))^;
 ds:= ad^;   //data
 if ds <> nil then begin
  dec(ds);    //header
  if ds^.ref.count <> 1 then begin
   si1:= (ds^.high+1)*cpu.pc^.par.setlength.itemsize + dynarrayallocsize;
   ss:= ds;
   ds:= getmem1(si1);
   move(ss^,ds^,si1);
   dec(ss^.ref.count);
   ds^.ref.count:= 1;
   ad^:= @ds^.data;
  end;
 end;
 stackpop(pointersize);
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
 po1^:= getmem1(int1); //todo: out of memory
end;
{
procedure getmem1op();
var
 po1: ppointer;
begin
 with cpu.pc^.par do begin
  po1:= stackpush(pointersize);
  po1^:= getmem1(imm.vint32); //todo: out of memory
 end;
end;
}
procedure getzeromemop();
var
 int1: int32;
 po1: ppointer;
begin
 int1:= pinteger(stackpop(sizeof(int32)))^;
 po1:= ppointer(stackpop(pointersize))^;
 po1^:= intgetzeromem(int1);
// getmem1(po1^,int1); //todo: out of memory
end;
{
procedure getzeromem1op();
var
 po1: ppointer;
begin
 with cpu.pc^.par do begin
  po1:= stackpush(pointersize);
  po1^:= intgetzeromem(imm.vint32); //todo: out of memory
 end;
end;
}
procedure freememop();
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(pointersize))^;
 freemem1(po1);
end;

procedure reallocmemop();
var
 po1: ppointer;
 i1: int32;
begin
 i1:= pinteger(stackpop(sizeof(int32)))^;
 po1:= ppointer(stackpop(pointersize))^;
 reallocmem(po1^,i1);
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

procedure memcpyop();
var
 ps,pd: pointer;
 count: int32;
begin
 count:= pinteger(stackpop(sizeof(int32)))^;
 ps:= ppointer(stackpop(pointersize))^;
 pd:= ppointer(stackpop(pointersize))^;
 move(ps^,pd^,count);
end;

procedure memmoveop();
begin
 memcpyop();
end;

procedure sin64op();
var
 po1: pflo64;
begin
 po1:= cpu.stack - 64 div 8;
 po1^:= sin(po1^);
end;

procedure cos64op();
var
 po1: pflo64;
begin
 po1:= cpu.stack - 64 div 8;
 po1^:= cos(po1^);
end;

procedure sqrt64op();
var
 po1: pflo64;
begin
 po1:= cpu.stack - 64 div 8;
 po1^:= sqrt(po1^);
end;

procedure floor64op();
var
 po1: pflo64;
 f1: flo64;
begin
 po1:= cpu.stack - 64 div 8;
 f1:= frac(po1^);
 po1^:= po1^-f1;
 if f1 < 0 then begin
  po1^:= po1^-1;
 end;
end;

procedure round64op();
var
 po1: pflo64;
 f1: flo64;
begin
 po1:= cpu.stack - 64 div 8;
 f1:= po1^;
 if f1 < 0 then begin
  f1:= f1-0.5;
 end
 else begin
  f1:= f1+0.5;
 end;  
 f1:= frac(po1^);
 po1^:= po1^-f1;
end;

procedure nearbyint64op();
var
 po1: pflo64;
 f1: flo64;
begin
 po1:= cpu.stack - 64 div 8;
 f1:= po1^;
 if f1 < 0 then begin
  f1:= f1-0.5;
 end
 else begin
  f1:= f1+0.5;
 end;  
 f1:= frac(po1^);   //todo: bankers rounding
 po1^:= po1^-f1;
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

  phissa = 0;
  
  gotossa = 0;
  gotofalsessa = 0;
  gototruessa = 0;
  cmpjmpneimmssa = 0;
  cmpjmpeqimmssa = 0;
  cmpjmploimmssa = 0;
  cmpjmpgtimmssa = 0;
  cmpjmploeqimmssa = 0;

  writelnssa = 0;
  writebooleanssa = 0;
  writecardinal8ssa = 0;
  writecardinal16ssa = 0;
  writecardinal32ssa = 0;
  writecardinal64ssa = 0;
  writeinteger8ssa = 0;
  writeinteger16ssa = 0;
  writeinteger32ssa = 0;
  writeinteger64ssa = 0;
  writefloat32ssa = 0;
  writefloat64ssa = 0;
  writechar8ssa = 0;
  writechar16ssa = 0;
  writechar32ssa = 0;
  writestring8ssa = 0;
  writestring16ssa = 0;
  writestring32ssa = 0;
  writepointerssa = 0;
  writeclassssa = 0;
  writeenumssa = 0;

  pushssa = 0;
  popssa = 0;
  swapstackssa = 0;
  movestackssa = 0;

  pushimm1ssa = 0;
  pushimm8ssa = 0;
  pushimm16ssa = 0;
  pushimm32ssa = 0;
  pushimm64ssa = 0;
  pushimmf32ssa = 0;
  pushimmf64ssa = 0;
  pushimmdatakindssa = 0;
  
  card8toflo32ssa = 0;
  card16toflo32ssa = 0;
  card32toflo32ssa = 0;
  card64toflo32ssa = 0;

  int8toflo32ssa = 0;
  int16toflo32ssa = 0;
  int32toflo32ssa = 0;
  int64toflo32ssa = 0;

  card8toflo64ssa = 0;
  card16toflo64ssa = 0;
  card32toflo64ssa = 0;
  card64toflo64ssa = 0;

  int8toflo64ssa = 0;
  int16toflo64ssa = 0;
  int32toflo64ssa = 0;
  int64toflo64ssa = 0;

  potoint32ssa = 0;
  inttopossa = 0;
  potopossa = 0;
  
  and1ssa = 0;
  andssa = 0;
  or1ssa = 0;
  orssa = 0;
  xor1ssa = 0;
  xorssa = 0;
  
  shlssa = 0;
  shrssa = 0;
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

  flo32toflo64ssa = 0;
  flo64toflo32ssa = 0;
  truncint32flo64ssa = 0;
  truncint32flo32ssa = 0;
  truncint64flo64ssa = 0;
  trunccard32flo64ssa = 0;
  trunccard32flo32ssa = 0;
  trunccard64flo64ssa = 0;
  
  card1toint32ssa = 0;

  string8to16ssa = 0;
  string8to32ssa = 0;
  string16to8ssa = 0;
  string16to32ssa = 0;
  string32to8ssa = 0;
  string32to16ssa = 0;

  concatstring8ssa = 0;
  concatstring16ssa = 0;
  concatstring32ssa = 0;
    
  chartostring8ssa = 0;
  arraytoopenarssa = 0;
  dynarraytoopenarssa = 0;
  listtoopenarssa = 0;
  
  combinemethodssa = 0;
  getmethodcodessa = 0;
  getmethoddatassa = 0;

  not1ssa = 0;
  notssa = 0;
  
  negcardssa = 0;
  negintssa = 0;
  negflossa = 0;

  absintssa = 0;
  absflossa = 0;
  
  mulcardssa = 0;
  mulintssa = 0;
  divcardssa = 0;
  divintssa = 0;
  modcardssa = 0;
  modintssa = 0;
  mulflossa = 0;
  divflossa = 0;
  addintssa = 0;
  subintssa = 0;
  addpointssa = 0;
  subpointssa = 0;
  subpossa = 0;
  addflossa = 0;
  subflossa = 0;
  diffsetssa = 0;
  xorsetssa = 0;
  
  setbitssa = 0;

  addimmintssa = 0;
  mulimmintssa = 0;
  offsetpoimmssa = 0;

  incdecsegimmintssa = 0;
  incdecsegimmpossa = 0;

  incdeclocimmintssa = 0;
  incdeclocimmpossa = 0;

  incdecparimmintssa = 0;
  incdecparimmpossa = 0;

  incdecparindiimmintssa = 0;
  incdecparindiimmpossa = 0;

  incdecindiimmintssa = 0;
  incdecindiimmpossa = 0;

  incsegintssa = 0;
  incsegpossa = 0;

  inclocintssa = 0;
  inclocpossa = 0;

  incparintssa = 0;
  incparpossa = 0;

  incparindiintssa = 0;
  incparindipossa = 0;

  incindiintssa = 0;
  incindipossa = 0;

  decsegintssa = 0;
  decsegpossa = 0;

  declocintssa = 0;
  declocpossa = 0;

  decparintssa = 0;
  decparpossa = 0;

  decparindiintssa = 0;
  decparindipossa = 0;

  decindiintssa = 0;
  decindipossa = 0;

  cmppossa = 0;
  cmpboolssa = 0;
  cmpcardssa = 0;
  cmpintssa = 0;
  cmpflossa = 0;
  cmpstringssa = 0;

  setcontainsssa = 0;
  setinssa = 0;
  classisssa = 0;

  storesegnilssa = 0;
  storelocindinilssa = 0;
  storelocnilssa = 0;
  storestacknilssa = 0;
  storestackrefnilssa = 0;

  storesegnilarssa = 0;
  storelocnilarssa = 0;
  storelocindinilarssa = 0;
  storestacknilarssa = 0;
  storestackrefnilarssa = 0;

  storesegnildynarssa = 0;
  storelocnildynarssa = 0;
  storelocindinildynarssa = 0;
  storestacknildynarssa = 0;
  storestackrefnildynarssa = 0;

  finirefsizesegssa = 0;
  finirefsizelocssa = 0;
  finirefsizelocindissa = 0;
  finirefsizestackssa = 0;
  finirefsizestackrefssa = 0;

  finirefsizesegarssa = 0;
  finirefsizelocarssa = 0;
  finirefsizelocindiarssa = 0;
  finirefsizestackarssa = 0;
  finirefsizestackrefarssa = 0;

  finirefsizesegdynarssa = 0;
  finirefsizelocdynarssa = 0;
  finirefsizelocindidynarssa = 0;
  finirefsizestackdynarssa = 0;
  finirefsizestackrefdynarssa = 0;

  increfsizesegssa = 0;
  increfsizelocssa = 0;
  increfsizelocindissa = 0;
  increfsizestackssa = 0;
  increfsizestackrefssa = 0;

  increfsizesegarssa = 0;
  increfsizelocarssa = 0;
  increfsizelocindiarssa = 0;
  increfsizestackarssa = 0;
  increfsizestackrefarssa = 0;

  increfsizesegdynarssa = 0;
  increfsizelocdynarssa = 0;
  increfsizelocindidynarssa = 0;
  increfsizestackdynarssa = 0;
  increfsizestackrefdynarssa = 0;

  decrefsizesegssa = 0;
  decrefsizelocssa = 0;
  decrefsizelocindissa = 0;
  decrefsizestackssa = 0;
  decrefsizestackrefssa = 0;

  decrefsizesegarssa = 0;
  decrefsizelocarssa = 0;
  decrefsizelocindiarssa = 0;
  decrefsizestackarssa = 0;
  decrefsizestackrefarssa = 0;

  decrefsizesegdynarssa = 0;
  decrefsizelocdynarssa = 0;
  decrefsizelocindidynarssa = 0;
  decrefsizestackdynarssa = 0;
  decrefsizestackrefdynarssa = 0;
  
  highstringssa = 0;
  highdynarssa = 0;
  highopenarssa = 0;
  lengthstringssa = 0;
  lengthdynarssa = 0;
  lengthopenarssa = 0;
  
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
  pushnilmethodssa = 0;
{
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
}
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
//  pushsegopenarssa = 0;

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
  pushallocaddrssa = 0;
//  pushstackaddrindissa = 0;

  pushstackssa = 0;

  pushduppossa = 0;
  storemanagedtempssa = 0;
  loadallocassa = 0;
  
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
  callvirtfuncssa = 0;
  callvirtssa = 0;
  callintfssa = 0;
  callintffuncssa = 0;
  virttrampolinessa = 0;

  callindissa = 0;
  callfuncindissa = 0;

  locvarpushssa = 0;
  locvarpopssa = 0;
  tempallocssa = 0;

  subbeginssa = 0;
  subendssa = 0;
  externalsubssa = 0;
  returnssa = 0;
  returnfuncssa = 0;

  zeromemssa = 0;
  getobjectmemssa = 0;
  getobjectzeromemssa = 0;
  initobjectssa = 0;
//  initclassssa = 0;
  destroyclassssa = 0;
  
  getvirtsubadssa = 0;
  getintfmethodssa = 0;

  setlengthstr8ssa = 0;
  setlengthstr16ssa = 0;
  setlengthstr32ssa = 0;
  setlengthdynarrayssa = 0;

  uniquestr8ssa = 0;
  uniquestr16ssa = 0;
  uniquestr32ssa = 0;
  uniquedynarrayssa = 0;

  raisessa = 0;
  pushcpucontextssa = 0;
  popcpucontextssa = 0;
  finiexceptionssa = 0;
  continueexceptionssa = 0;
  getmemssa = 0;
//  getmem1ssa = 0;
  getzeromemssa = 0;
//  getzeromem1ssa = 0;
  freememssa = 0;
  reallocmemssa = 0;
  setmemssa = 0;
  memcpyssa = 0;
  memmovessa = 0;
  
  sin64ssa = 0;
  cos64ssa = 0;
  sqrt64ssa = 0;
  floor64ssa = 0;
  round64ssa = 0;
  nearbyint64ssa = 0;
  
  lineinfossa = 0;

//ssa only
  nestedvarssa = 0;
  nestedvaradssa = 0;
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
  listtoopenaritemssa = 0;
  concattermsitemssa = 0;
    
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
 try
  while not cpu.stop do begin
   optable[cpu.pc^.op.op].proc();
   inc(cpu.pc);
  end;
 except
  application.handleexception();
 end;
 result:= exitcodeaddress^;
// result:= pinteger(segments[seg_globvar].basepo)^;
end;

function run(const stackdepht: integer): integer;
var
 segs: segmentbuffersty;
 seg1: segmentty;
 p1,pe: prelocinfoty;
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
 p1:= getsegmentbase(seg_reloc);
 pe:= getsegmenttop(seg_reloc);
 while p1 < pe do begin
  inc(ppointer(getsegmentpo(p1^.dest))^,ptruint(getsegmentbase(p1^.source)));
  inc(p1);
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
