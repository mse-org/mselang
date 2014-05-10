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

 stringheaderty = record
  len: integer;
  data: record
  end;
 end;
 pstringheaderty = ^stringheaderty;

 frameinfoty = record
  pc: vpointerty;
  frame: vpointerty;
  link: vpointerty;     //todo: remove link field
 end;
 infoopty = procedure(const opinfo: popinfoty);

function alignsize(const size: ptruint): ptruint; inline;

procedure finalize;
procedure run(const code: opinfoarty; const constseg: pointer;
                                    const stackdepht: integer);

//procedure dummyop;
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

procedure storelocnil();
procedure storeglobnil();
procedure storereg0nil();
procedure storelocnilar();
procedure storeglobnilar();
procedure storereg0nilar();

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

implementation
uses
 sysutils,handlerglob,mseformatstr,msetypes;
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
 reg0: pointer;
 framepo: pointer;
 stacklink: pointer;
 startpo: popinfoty;
 oppo: popinfoty;
 globdata: pointer;
 constdata: pointer;

procedure internalerror(const atext: string);
begin
 raise exception.create('Internal error '+atext);
end;
 
function alignsize(const size: ptruint): ptruint; inline;
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

procedure nop;
begin
end;

procedure gotoop;
begin
 oppo:= startpo + oppo^.par.opaddress;
end;

procedure ifop;
begin
 if not vbooleanty(stackpop(sizeof(vbooleanty))^) then begin
  oppo:= startpo + oppo^.par.opaddress;
 end;
end;

procedure writelnop;
var
 int1,int2,int3: integer;
 po1,po2: pointer;
 po3: pdatakindty;
 str1: string;
 po4: pstringheaderty;
begin
 dec(mainstackpo,oppo^.par.paramcount*sizeof(datakindty));
 po3:= mainstackpo; //start of data kinds
 po2:= po3;
 dec(mainstackpo,oppo^.par.paramsize);
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
   dk_string8: begin
    po4:= pointer(po1^);
    if po4 <> nil then begin
     po4:= pointer(po4)-sizeof(stringheaderty);
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

procedure pushop;
begin
 stackpush(oppo^.par.imm.vsize);
end;

procedure popop;
begin
 stackpop(oppo^.par.imm.vsize);
end;

procedure push8;
begin
 pv8ty(stackpush(1))^:= oppo^.par.v8; 
end;

procedure push16;
begin
 pv16ty(stackpush(2))^:= oppo^.par.v16; 
end;

procedure push32;
begin
 pv32ty(stackpush(4))^:= oppo^.par.v32; 
end;

procedure push64;
begin
 pv64ty(stackpush(8))^:= oppo^.par.v64; 
end;

procedure pushdatakind;
begin
 vdatakindty(stackpushnoalign(sizeof(vdatakindty))^):= oppo^.par.vdatakind; 
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
 po1:= mainstackpo - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)*oppo^.par.imm.vint32;
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
 po1:= mainstackpo - alignsize(sizeof(vintegerty));
 vintegerty(po1^):= vintegerty(po1^)+oppo^.par.imm.vint32;
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
 ppointer(stackpush(sizeof(dataaddressty)))^:= constdata+oppo^.par.vaddress; 
end;

procedure storeglobnil();
begin
 ppointer(globdata+oppo^.par.dataaddress)^:= nil;
end;

procedure storelocnil();
begin
 ppointer(framepo+oppo^.par.dataaddress)^:= nil;
end;

procedure storereg0nil();
begin
 ppointer(reg0+oppo^.par.dataaddress)^:= nil;
end;

procedure storeglobnilar();
begin
 with oppo^ do begin
{$ifdef cpu64}
  fillqword(ppointer(globdata+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(globdata+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storelocnilar();
begin
 with oppo^ do begin
{$ifdef cpu64}
  fillqword(ppointer(framepo+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(framepo+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure storereg0nilar();
begin
 with oppo^ do begin
{$ifdef cpu64}
  fillqword(ppointer(reg0+par.dataaddress)^,par.datasize,0);
{$else}
  filldword(ppointer(reg0+par.dataaddress)^,par.datasize,0);
{$endif}
 end;
end;

procedure popglob8;
begin
 puint8(globdata+oppo^.par.dataaddress)^:= puint8(stackpop(1))^;
end;

procedure popglob16;
begin
 puint16(globdata+oppo^.par.dataaddress)^:= puint16(stackpop(2))^;
end;

procedure popglob32;
begin
 puint32(globdata+oppo^.par.dataaddress)^:= puint32(stackpop(4))^;
end;

procedure popglob;
begin
 move(stackpop(oppo^.par.datasize)^,(globdata+oppo^.par.dataaddress)^,
                                                        oppo^.par.datasize);
end;

procedure pushglob8;
begin
 pv8ty(stackpush(1))^:= pv8ty(globdata+oppo^.par.dataaddress)^;
end;

procedure pushglob16;
begin
 pv16ty(stackpush(2))^:= pv16ty(globdata+oppo^.par.dataaddress)^;
end;

procedure pushglob32;
begin
 pv32ty(stackpush(4))^:= pv32ty(globdata+oppo^.par.dataaddress)^;
end;

procedure pushglob;
begin
 move((globdata+oppo^.par.dataaddress)^,stackpush(oppo^.par.datasize)^,
                                                          oppo^.par.datasize);
end;

//todo: make special locvar access funcs for inframe variables
//and loop unroll

function locaddress(const aaddress: locdataaddressty): pointer; inline;
var
 i1: integer;
 po1: pointer;
begin
 if aaddress.linkcount < 0 then begin
  result:= framepo+aaddress.offset;
 end
 else begin
  po1:= stacklink;
  for i1:= aaddress.linkcount downto 0 do begin
   po1:= frameinfoty((po1-sizeof(frameinfoty))^).link;
  end;
  result:= po1+aaddress.offset;
 end;
end;

procedure poploc8;
begin             
 pv8ty(locaddress(oppo^.par.locdataaddress))^:= pv8ty(stackpop(1))^;
end;

procedure poploc16;
begin
 pv16ty(locaddress(oppo^.par.locdataaddress))^:= pv16ty(stackpop(2))^;
end;

procedure poploc32;
begin
 pv32ty(locaddress(oppo^.par.locdataaddress))^:= pv32ty(stackpop(4))^;
end;

procedure poploc;
begin
 move(stackpop(oppo^.par.datasize)^,(locaddress(oppo^.par.locdataaddress))^,
                                                         oppo^.par.datasize);
end;

procedure poplocindi8;
begin             
 pv8ty(locaddress(oppo^.par.locdataaddress)^)^:= pv8ty(stackpop(1))^;
end;

procedure poplocindi16;
begin
 pv16ty(ppointer(locaddress(oppo^.par.locdataaddress))^)^:= pv16ty(stackpop(2))^;
end;

procedure poplocindi32;
begin
 pv32ty(ppointer(locaddress(oppo^.par.locdataaddress))^)^:= pv32ty(stackpop(4))^;
end;

procedure poplocindi;
begin
 move(stackpop(oppo^.par.datasize)^,
      (ppointer(locaddress(oppo^.par.locdataaddress))^)^,oppo^.par.datasize);
end;

procedure pushloc8;
begin
 pv8ty(stackpush(1))^:= pv8ty(locaddress(oppo^.par.locdataaddress))^;
end;

procedure pushloc16;
begin
 pv16ty(stackpush(2))^:= pv16ty(locaddress(oppo^.par.locdataaddress))^;
end;

procedure pushloc32;
begin
 pv32ty(stackpush(4))^:= pv32ty(locaddress(oppo^.par.locdataaddress))^;
end;

procedure pushlocpo;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                              ppointer(locaddress(oppo^.par.locdataaddress))^;
end;

procedure pushloc;
begin
 move((locaddress(oppo^.par.locdataaddress))^,stackpush(oppo^.par.datasize)^,
                                                   oppo^.par.datasize);
end;

procedure pushlocindi8;
begin
 pv8ty(stackpush(1))^:= ppv8ty(locaddress(oppo^.par.locdataaddress))^^;
end;

procedure pushlocindi16;
begin
 pv16ty(stackpush(2))^:= ppv16ty(locaddress(oppo^.par.locdataaddress))^^;
end;

procedure pushlocindi32;
begin
 pv32ty(stackpush(4))^:= ppv32ty(locaddress(oppo^.par.locdataaddress))^^;
end;

procedure pushlocindi;
begin
 move(ppointer(locaddress(oppo^.par.locdataaddress))^^,
               stackpush(oppo^.par.datasize)^,oppo^.par.datasize);
end;

procedure pushaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= pointer(oppo^.par.imm.vpointer);
end;

procedure pushlocaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                     locaddress(oppo^.par.vlocaddress)+oppo^.par.vlocadoffs;;
end;

procedure pushlocaddrindi;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
           ppointer(locaddress(oppo^.par.vlocaddress))^+oppo^.par.vlocadoffs;
end;

procedure pushglobaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
                     globdata+oppo^.par.vaddress+oppo^.par.vglobadoffs;
end;

procedure pushglobaddrindi;
begin
 ppointer(stackpush(sizeof(pointer)))^:= 
           ppointer(globdata+oppo^.par.vaddress)^+oppo^.par.vglobadoffs;
end;

procedure pushstackaddr;
begin
 ppointer(stackpush(sizeof(pointer)))^:= mainstackpo+oppo^.par.voffset;
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

procedure indirectpo;
var
 po1: pointer;
begin
 po1:= mainstackpo-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^;
end;

procedure indirectpooffs;
var
 po1: pointer;
begin
 po1:= mainstackpo-sizeof(pointer);
 ppointer(po1)^:=  ppointer(ppointer(po1)^)^+oppo^.par.voffset;
end;

procedure indirect;
var
 po1: pointer;
begin
 po1:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,stackpush(oppo^.par.datasize)^,oppo^.par.datasize);
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
 po1:= stackpop(oppo^.par.datasize);
 po2:= ppointer(stackpop(sizeof(pointer)))^;
 move(po1^,po2^,oppo^.par.datasize);
end;

//first op:
//                  |framepo    |mainstackpo
// params frameinfo locvars      
//
procedure callop;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= oppo;
  frame:= framepo;
  link:= stacklink;
 end;
 framepo:= mainstackpo;
 stacklink:= framepo;
 oppo:= startpo+oppo^.par.callinfo.ad;
end;

procedure calloutop;
var
 i1: integer;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= oppo;
  frame:= framepo;
  link:= stacklink;
 end;
 
 for i1:= oppo^.par.callinfo.linkcount downto 0 do begin
  stacklink:= frameinfoty((stacklink-sizeof(frameinfoty))^).link;
 end;
 framepo:= mainstackpo;
 oppo:= startpo+oppo^.par.callinfo.ad;
end;

procedure callvirtop;
begin
 with frameinfoty(stackpush(sizeof(frameinfoty))^) do begin
  pc:= oppo;
  frame:= framepo;
  link:= stacklink;
 end;
 framepo:= mainstackpo;
 stacklink:= framepo;
 with oppo^.par.virtcallinfo do begin
  oppo:= startpo+pptruint(pppointer(mainstackpo+selfinstance)^^+virtoffset)^;
//  oppo:= startpo+ptruint(ppppointer(mainstackpo+selfinstance)^^[virtindex]); 
 end;
end;

procedure locvarpushop;
begin
 stackpush(oppo^.par.stacksize);
end;

procedure locvarpopop;
begin
 stackpop(oppo^.par.stacksize);
end;

procedure returnop;
var
 int1: integer;
begin
 int1:= oppo^.par.stacksize;
 with frameinfoty((framepo-sizeof(frameinfoty))^) do begin
  oppo:= pc;
  framepo:= frame;
  stacklink:= link;
 end;
 mainstackpo:= mainstackpo-int1;
end;

procedure initclassop;
var
 po1: pointer;
 po2: pclassdefinfoty;
 self1: ppointer;
begin
 with oppo^.par do begin
//  po2:= pclassdefinfoty(initclass.classdef+constdata);
  self1:= framepo+initclass.selfinstance;
  po2:= self1^;  //class type
  po1:= intgetnulledmem(po2^.header.fieldsize);
  ppointer(po1)^:= po2;
  self1^:= po1;  //class instance
  pppointer(framepo+initclass.result)^^:= po1; //result
 end;
end;

procedure destroyclassop;
begin
 with oppo^.par do begin
  intfreemem(ppointer(framepo+destroyclass.selfinstance)^);
 end;
end;

procedure decloop32();
var
 po1: pinteger;
begin
 po1:= pinteger(mainstackpo-4);
 dec(po1^);
 if po1^ = 0 then begin
  oppo:= startpo+oppo^.par.opaddress;
 end;
end;

procedure decloop64();
var
 po1: pint64;
begin
 po1:= pint64(mainstackpo-8);
 dec(po1^);
 if po1^ = 0 then begin
  oppo:= startpo+oppo^.par.opaddress;
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
 reallocmem(mainstack,stackdepht);
 mainstackpo:= mainstack;
 mainstackend:= mainstackpo + stackdepht;
 startpo:= pointer(code);
 oppo:= startpo;
 endpo:= oppo+length(code);
 framepo:= nil;
 stacklink:= nil;
 reg0:= nil;
 with pstartupdataty(oppo)^ do begin
  reallocmem(globdata,globdatasize);
  fillchar(globdata^,globdatasize,0);
 end;
 constdata:= constseg;
 inc(oppo,startupoffset);
 while oppo^.op <> nil do begin
  oppo^.op;
  inc(oppo);
 end;
end;

finalization
 finalize;
end.
