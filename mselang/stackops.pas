{ MSElang Copyright (c) 2013 by Martin Schreiber

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
 //todo: use variable alignment
 alignstep = 4;
 alignmask = ptrint(-alignstep);
  
type
 vaddressty = pointer;
 frameinfoty = record
  pc: vaddressty;
  frame: vaddressty;
 end;
 infoopty = procedure(const opinfo: popinfoty);

function alignsize(const size: ptruint): ptruint; inline;

procedure finalize;
function run(const code: opinfoarty; const stackdepht: integer): real;

procedure dummyop;
procedure gotoop;
procedure ifop;
procedure writelnop;

procedure push8;
procedure push16;
procedure push32;
procedure push64;
procedure pushdatakind;
procedure int32toflo64;
procedure mulint32;
procedure mulflo64;
procedure addint32;
procedure addflo64;
procedure negcard32;
procedure negint32;
procedure negflo64;

procedure popglob8;
procedure popglob16;
procedure popglob32;
procedure popglob;

procedure poploc8;
procedure poploc16;
procedure poploc32;
procedure poploc;

procedure pushglob8;
procedure pushglob16;
procedure pushglob32;
procedure pushglob;

procedure pushloc8;
procedure pushloc16;
procedure pushloc32;
procedure pushloc;

procedure pushlocaddr;
procedure pushglobaddr;

procedure indirect8;
procedure indirect16;
procedure indirect32;
procedure indirect;

procedure popindirect8;
procedure popindirect16;
procedure popindirect32;
procedure popindirect;

procedure callop;
procedure calloutop;
procedure locvarpushop;
procedure locvarpopop;
procedure returnop;

implementation
uses
 sysutils;
type
 vdatakindty = datakindty;
 vbooleanty = boolean;
 vcardinalty = card32;
 vintegerty = int32;
 vfloatty = float64;
// vaddressty = pointer;
 vsizety = ptrint;
 voffsty = ptrint;
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
var
 mainstack: pointer;
 mainstackend: pointer;
 mainstackpo: pointer;
 framepo: pointer;
 startpo: popinfoty;
 oppo: popinfoty;
 globdata: pointer;

procedure internalerror(const atext: string);
begin
 raise exception.create('Internal error '+atext);
end;
 
function alignsize(const size: ptruint): ptruint; inline;
begin
 result:= (size+(alignstep-1)) and alignmask;
end;

function stackoffs(const offs: ptruint; const size: ptruint): pointer; inline;
begin
 result:= mainstackpo + offs;
 if (result < mainstack) or (result >= mainstackend) or 
           (result+size < mainstack) or (result+size > mainstackend) then begin
  raise exception.create('Interpreter AV');
 end;
end;

function stacktop(const size: ptruint): pointer; inline;
begin
 result:= mainstackpo-alignsize(size);
end;

procedure avexception;
begin
 raise exception.create('Interpreter AV');
end;

function stackpush(const size: ptruint): pointer; inline;
begin
 result:= mainstackpo;
 mainstackpo:= mainstackpo + alignsize(size);
 if (mainstackpo < mainstack) or (mainstackpo > mainstackend) then begin
  avexception;
 end; 
end;

function stackpushnoalign(const size: ptruint): pointer; inline;
begin
 result:= mainstackpo;
 mainstackpo:= mainstackpo + size;
 if (mainstackpo < mainstack) or (mainstackpo > mainstackend) then begin
  avexception;
 end; 
end;

function stackpop(const size: ptruint): pointer; inline;
begin
 mainstackpo:= mainstackpo - alignsize(size);
 result:= mainstackpo;
 if (mainstackpo < mainstack) or (mainstackpo > mainstackend) then begin
  avexception;
 end; 
end;

procedure dummyop;
begin
end;

procedure gotoop;
begin
 oppo:= startpo + oppo^.d.opaddress;
end;

procedure ifop;
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  oppo:= startpo + oppo^.d.opaddress;
 end;
end;

procedure writelnop;
var
 int1,int2,int3: integer;
 po1,po2: pointer;
 po3: pdatakindty;
begin
 dec(mainstackpo,oppo^.d.paramcount*sizeof(datakindty));
 po3:= mainstackpo; //start of data kinds
 po2:= po3;
 dec(mainstackpo,oppo^.d.paramsize);
 po1:= mainstackpo; //start of params
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
   else begin
    internalerror('I20131210A');
   end;
  end;
  inc(po3);
 end;
 writeln;
{ 
 int1:= mainstack[mainstackpo].vinteger;
 int3:= mainstackpo-int1;
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
 mainstackpo:= mainstackpo-2*int1-1;
}
end;

procedure push8;
begin
 pv8ty(stackpush(1))^:= oppo^.d.v8; 
end;

procedure push16;
begin
 pv16ty(stackpush(2))^:= oppo^.d.v16; 
end;

procedure push32;
begin
 pv32ty(stackpush(4))^:= oppo^.d.v32; 
end;

procedure push64;
begin
 pv64ty(stackpush(8))^:= oppo^.d.v64; 
end;

procedure pushdatakind;
begin
 vdatakindty(stackpushnoalign(sizeof(vdatakindty))^):= oppo^.d.vdatakind; 
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

procedure popglob8;
begin
 puint8(globdata+oppo^.d.dataaddress)^:= puint8(stackpop(1))^;
end;

procedure popglob16;
begin
 puint16(globdata+oppo^.d.dataaddress)^:= puint16(stackpop(2))^;
end;

procedure popglob32;
begin
 puint32(globdata+oppo^.d.dataaddress)^:= puint32(stackpop(4))^;
end;

procedure popglob;
begin
 move(stackpop(oppo^.d.datasize)^,(globdata+oppo^.d.dataaddress)^,
                                                        oppo^.d.datasize);
end;

procedure pushglob8;
begin
 pv8ty(stackpush(1))^:= pv8ty(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob16;
begin
 pv16ty(stackpush(2))^:= pv16ty(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob32;
begin
 pv32ty(stackpush(4))^:= pv32ty(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob;
begin
 move((globdata+oppo^.d.dataaddress)^,stackpush(oppo^.d.datasize)^,
                                                          oppo^.d.datasize);
end;

//todo: make special locvar access funcs for inframe variables
//and loop unroll

function locaddress(const aaddress: locdataadressty): pointer;// inline;
var
 i1: integer;
 po1: pointer;
begin
 if aaddress.framecount < 0 then begin
  result:= framepo+aaddress.offset;
 end
 else begin
  po1:= framepo;
  for i1:= aaddress.framecount downto 0 do begin
   po1:= frameinfoty((po1-sizeof(frameinfoty))^).frame;
  end;
  result:= po1+aaddress.offset;
 end;
end;

procedure poploc8;
begin             
 pv8ty(locaddress(oppo^.d.locdataaddress))^:= pv8ty(stackpop(1))^;
end;

procedure poploc16;
begin
 pv16ty(locaddress(oppo^.d.locdataaddress))^:= pv16ty(stackpop(2))^;
end;

procedure poploc32;
begin
 pv32ty(locaddress(oppo^.d.locdataaddress))^:= pv32ty(stackpop(4))^;
end;

procedure poploc;
begin
 move(stackpop(oppo^.d.datasize)^,(locaddress(oppo^.d.locdataaddress))^,
                                                         oppo^.d.datasize);
end;

procedure pushloc8;
begin
 pv8ty(stackpush(1))^:= pv8ty(locaddress(oppo^.d.locdataaddress))^;
end;

procedure pushloc16;
begin
 pv16ty(stackpush(2))^:= pv16ty(locaddress(oppo^.d.locdataaddress))^;
end;

procedure pushloc32;
begin
 pv32ty(stackpush(4))^:= pv32ty(locaddress(oppo^.d.locdataaddress))^;
end;

procedure pushloc;
begin
 move((locaddress(oppo^.d.locdataaddress))^,stackpush(oppo^.d.datasize)^,
                                                   oppo^.d.datasize);
end;

procedure pushlocaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= locaddress(oppo^.d.locdataaddress);
end;

procedure pushglobaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= globdata+oppo^.d.vaddress;
end;

procedure indirect8;
var
 po1: pointer;
begin
 po1:= mainstackpo-alignstep;
 pv8ty(po1)^:=  pv8ty(ppointer(po1)^)^;
end;

procedure indirect16;
var
 po1: pointer;
begin
 po1:= mainstackpo-alignstep;
 pv16ty(po1)^:=  pv16ty(ppointer(po1)^)^;
end;

procedure indirect32;
var
 po1: pointer;
begin
 po1:= mainstackpo-alignstep;
 pv32ty(po1)^:=  pv32ty(ppointer(po1)^)^;
end;

procedure indirect;
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,stackpush(oppo^.d.datasize)^,oppo^.d.datasize);
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
 po1:= stackpop(oppo^.d.datasize);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,po2^,oppo^.d.datasize);
end;

procedure callop;
var
 i1: integer;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= oppo;
  frame:= framepo;
 end;
 framepo:= mainstackpo;
 oppo:= startpo+oppo^.d.callinfo.ad;
end;

procedure calloutop;
var
 i1: integer;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= oppo;
  frame:= framepo;
 end;
 for i1:= oppo^.d.callinfo.framecount downto 0 do begin
  framepo:= frameinfoty((framepo-sizeof(frameinfoty))^).frame;
 end;
 oppo:= startpo+oppo^.d.callinfo.ad;
end;

procedure locvarpushop;
begin
 stackpush(oppo^.d.stacksize);
end;

procedure locvarpopop;
begin
 stackpop(oppo^.d.stacksize);
end;

procedure returnop;
var
 int1: integer;
begin
 int1:= oppo^.d.stacksize;
 with frameinfoty((mainstackpo-sizeof(frameinfoty))^) do begin
  oppo:= pc;
  framepo:= frame;
 end;
 mainstackpo:= mainstackpo-int1;
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

function run(const code: opinfoarty; const stackdepht: integer): real;
var
 endpo: popinfoty;
begin
 reallocmem(mainstack,stackdepht);
 mainstackpo:= mainstack;
 mainstackend:= mainstackpo + stackdepht;
 startpo:= pointer(code);
 oppo:= startpo;
 endpo:= oppo+length(code);
 framepo:= nil;
 with pstartupdataty(oppo)^ do begin
  reallocmem(globdata,globdatasize);
 end;
 inc(oppo,startupoffset);
 while oppo^.op <> nil do begin
  oppo^.op;
  inc(oppo);
 end;
 result:= 0;
end;

end.
