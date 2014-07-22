{ MSElang Copyright (c) 2014 by Martin Schreiber
   
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
unit llvmops;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 opglob,parserglob;

//todo: generate bitcode
 
function getoptable: poptablety;
//procedure allocproc(const asize: integer; var address: segaddressty);

procedure run();
 
implementation
uses
 sysutils,msestream,msesys,segmentutils;

var
// sp: integer; //unnamed variables
 pc: popinfoty;

var
 assstream: ttextstream;

procedure outass(const atext: string);
begin
 assstream.writeln(atext);
end;

procedure outbinop(const atext: string);
begin
 with pc^.par.stackop do begin
  outass('%'+inttostr(destssaindex)+' = '+atext+
   ' %'+inttostr(source1ssaindex)+', %'+inttostr(source2ssaindex));
 end;
end;
  
procedure notimplemented();
begin
 raise exception.create('LLVM OP not implemented');
end;

const
 segprefix: array[segmentty] of string = (
 //seg_nil,seg_stack,seg_globvar,seg_globconst,
   '',     '@s',       '@gv',      '@gc',
 //seg_op,seg_rtti,seg_intf,seg_globalloc,seg_localloc
   '@o',  '@rt',   '@if',   '',           '');
               
function segdataaddress(const address: segdataaddressty): string;
begin
 result:= segprefix[address.a.segment]+inttostr(address.a.address);
end;

function segaddress(const address: segaddressty): string;
begin
 result:= segprefix[address.segment]+inttostr(address.address);
end;

function locdataaddress(const address: locdataaddressty): string;
begin
 result:= '%l'+inttostr(address.a.address);
end;

function locaddress(const address: locaddressty): string;
begin
 result:= '%l'+inttostr(address.address);
end;

procedure stackassign(const ssaindex: integer; const value: int32);
begin
 outass('%'+inttostr(ssaindex)+' = add i32 '+inttostr(value)+' ,0');
end;

procedure segassign32(const ssaindex: integer; const dest: segdataaddressty);
begin
 outass('store i32 %'+inttostr(ssaindex)+', i32* '+segdataaddress(dest));
end;

procedure assignseg32(const ssaindex: integer; const dest: segdataaddressty);
begin
 outass('%'+inttostr(ssaindex)+' = load i32* '+segdataaddress(dest));
end;

procedure locassign32(const ssaindex: integer; const dest: locdataaddressty);
begin
 outass('store i32 %'+inttostr(ssaindex)+', i32* '+locdataaddress(dest));
end;

procedure assignloc32(const ssaindex: integer; const dest: locdataaddressty);
begin
 outass('%'+inttostr(ssaindex)+' = load i32* '+locdataaddress(dest));
end;

procedure nop();
begin
 //dummy;
end;

var
 exitcodeaddress: segaddressty;
  
procedure beginparseop();
var
 endpo: pointer;
 allocpo: pgloballocinfoty;
begin
 freeandnil(assstream);
 assstream:= ttextstream.create('test.ll',fm_create);
 with pc^.par.beginparse do begin
  allocpo:= getsegmentpo(globallocstart);
  endpo:= pointer(allocpo)+globalloccount*sizeof(globallocinfoty);
  llvmops.exitcodeaddress:= exitcodeaddress;
  while allocpo < endpo do begin
   with allocpo^ do begin
    outass(segaddress(a)+' = global i'+
                                              inttostr(8*size)+ ' 0');
   end;
   inc(allocpo);
  end;
 end;
end;

procedure mainop();
begin
 outass('define i32 @main() {');
// info.ssaindex:= 1;
end;

procedure progendop();
begin
 outass('%.exitcode = load i32* '+segaddress(exitcodeaddress));
 outass('ret i32 %.exitcode');
 outass('}');
end;

procedure endparseop();
begin
 freeandnil(assstream);
end;

procedure movesegreg0op();
begin
 notimplemented();
end;
procedure moveframereg0op();
begin
 notimplemented();
end;
procedure popreg0op();
begin
 notimplemented();
end;
procedure increg0op();
begin
 notimplemented();
end;

procedure gotoop();
begin
 notimplemented();
end;
procedure cmpjmpneimm4op();
begin
 notimplemented();
end;
procedure cmpjmpeqimm4op();
begin
 notimplemented();
end;
procedure cmpjmploimm4op();
begin
 notimplemented();
end;
procedure cmpjmpgtimm4op();
begin
 notimplemented();
end;
procedure cmpjmploeqimm4op();
begin
 notimplemented();
end;

procedure ifop();
begin
 notimplemented();
end;
procedure writelnop();
begin
 notimplemented();
end;
procedure writebooleanop();
begin
 notimplemented();
end;
procedure writeintegerop();
begin
 notimplemented();
end;
procedure writefloatop();
begin
 notimplemented();
end;
procedure writestring8op();
begin
 notimplemented();
end;
procedure writeclassop();
begin
 notimplemented();
end;
procedure writeenumop();
begin
 notimplemented();
end;

procedure pushop();
begin
 notimplemented();
end;
procedure popop();
begin
 notimplemented();
end;

procedure push8op();
begin
 notimplemented();
end;
procedure push16op();
begin
 notimplemented();
end;

procedure push32op();
begin
 with pc^.par do begin
  stackassign(imm.ssaindex,imm.vint32);
 end;
end;

procedure push64op();
begin
 notimplemented();
end;

procedure pushdatakindop();
begin
 notimplemented();
end;
procedure int32toflo64op();
begin
 notimplemented();
end;
procedure mulint32op();
begin
 notimplemented();
end;
procedure mulimmint32op();
begin
 notimplemented();
end;
procedure mulflo64op();
begin
 notimplemented();
end;

procedure addint32op();
begin
 outbinop('add i32');
end;

procedure addimmint32op();
begin
 notimplemented();
end;
procedure addflo64op();
begin
 notimplemented();
end;
procedure negcard32op();
begin
 notimplemented();
end;
procedure negint32op();
begin
 notimplemented();
end;
procedure negflo64op();
begin
 notimplemented();
end;

procedure offsetpoimm32op();
begin
 notimplemented();
end;

procedure cmpequboolop();
begin
 notimplemented();
end;
procedure cmpequint32op();
begin
 notimplemented();
end;
procedure cmpequflo64op();
begin
 notimplemented();
end;

procedure storesegnilop();
begin
 notimplemented();
end;
procedure storereg0nilop();
begin
 notimplemented();
end;
procedure storeframenilop();
begin
 notimplemented();
end;
procedure storestacknilop();
begin
 notimplemented();
end;
procedure storestackrefnilop();
begin
 notimplemented();
end;
procedure storesegnilarop();
begin
 notimplemented();
end;
procedure storeframenilarop();
begin
 notimplemented();
end;
procedure storereg0nilarop();
begin
 notimplemented();
end;
procedure storestacknilarop();
begin
 notimplemented();
end;
procedure storestackrefnilarop();
begin
 notimplemented();
end;

procedure finirefsizesegop();
begin
 notimplemented();
end;
procedure finirefsizeframeop();
begin
 notimplemented();
end;
procedure finirefsizereg0op();
begin
 notimplemented();
end;
procedure finirefsizestackop();
begin
 notimplemented();
end;
procedure finirefsizestackrefop();
begin
 notimplemented();
end;
procedure finirefsizeframearop();
begin
 notimplemented();
end;
procedure finirefsizesegarop();
begin
 notimplemented();
end;
procedure finirefsizereg0arop();
begin
 notimplemented();
end;
procedure finirefsizestackarop();
begin
 notimplemented();
end;
procedure finirefsizestackrefarop();
begin
 notimplemented();
end;

procedure increfsizesegop();
begin
 notimplemented();
end;
procedure increfsizeframeop();
begin
 notimplemented();
end;
procedure increfsizereg0op();
begin
 notimplemented();
end;
procedure increfsizestackop();
begin
 notimplemented();
end;
procedure increfsizestackrefop();
begin
 notimplemented();
end;
procedure increfsizeframearop();
begin
 notimplemented();
end;
procedure increfsizesegarop();
begin
 notimplemented();
end;
procedure increfsizereg0arop();
begin
 notimplemented();
end;
procedure increfsizestackarop();
begin
 notimplemented();
end;
procedure increfsizestackrefarop();
begin
 notimplemented();
end;

procedure decrefsizesegop();
begin
 notimplemented();
end;
procedure decrefsizeframeop();
begin
 notimplemented();
end;
procedure decrefsizereg0op();
begin
 notimplemented();
end;
procedure decrefsizestackop();
begin
 notimplemented();
end;
procedure decrefsizestackrefop();
begin
 notimplemented();
end;
procedure decrefsizeframearop();
begin
 notimplemented();
end;
procedure decrefsizesegarop();
begin
 notimplemented();
end;
procedure decrefsizereg0arop();
begin
 notimplemented();
end;
procedure decrefsizestackarop();
begin
 notimplemented();
end;
procedure decrefsizestackrefarop();
begin
 notimplemented();
end;

procedure popseg8op();
begin
 notimplemented();
end;
procedure popseg16op();
begin
 notimplemented();
end;

procedure popseg32op();
begin
 with pc^.par.memop do begin
  segassign32(ssaindex,segdataaddress);
 end;
end;

procedure popsegop();
begin
 notimplemented();
end;

procedure poploc8op();
begin
 notimplemented();
end;
procedure poploc16op();
begin
 notimplemented();
end;

procedure poploc32op();
begin
 with pc^.par.memop do begin
  locassign32(ssaindex,locdataaddress);  
 end;
end;

procedure poplocop();
begin
 notimplemented();
end;

procedure poplocindi8op();
begin
 notimplemented();
end;
procedure poplocindi16op();
begin
 notimplemented();
end;
procedure poplocindi32op();
begin
 notimplemented();
end;
procedure poplocindiop();
begin
 notimplemented();
end;

procedure pushnilop();
begin
 notimplemented();
end;
procedure pushsegaddressop();
begin
 notimplemented();
end;

procedure pushseg8op();
begin
 notimplemented();
end;
procedure pushseg16op();
begin
 notimplemented();
end;

procedure pushseg32op();
begin
 with pc^.par.memop do begin
  assignseg32(ssaindex,segdataaddress);
 end;
end;

procedure pushsegop();
begin
 notimplemented();
end;

procedure pushloc8op();
begin
 notimplemented();
end;
procedure pushloc16op();
begin
 notimplemented();
end;

procedure pushloc32op();
begin
 with pc^.par.memop do begin
  assignloc32(ssaindex,locdataaddress);
 end;
end;

procedure pushlocpoop();
begin
 notimplemented();
end;
procedure pushlocop();
begin
 notimplemented();
end;

procedure pushlocindi8op();
begin
 notimplemented();
end;
procedure pushlocindi16op();
begin
 notimplemented();
end;
procedure pushlocindi32op();
begin
 notimplemented();
end;
procedure pushlocindiop();
begin
 notimplemented();
end;

procedure pushaddrop();
begin
 notimplemented();
end;
procedure pushlocaddrop();
begin
 notimplemented();
end;
procedure pushlocaddrindiop();
begin
 notimplemented();
end;
procedure pushsegaddrop();
begin
 notimplemented();
end;
procedure pushsegaddrindiop();
begin
 notimplemented();
end;
procedure pushstackaddrop();
begin
 notimplemented();
end;
procedure pushstackaddrindiop();
begin
 notimplemented();
end;

procedure indirect8op();
begin
 notimplemented();
end;
procedure indirect16op();
begin
 notimplemented();
end;
procedure indirect32op();
begin
 notimplemented();
end;
procedure indirectpoop();
begin
 notimplemented();
end;
procedure indirectpooffsop();
begin
 notimplemented();
end; //offset after indirect
procedure indirectoffspoop();
begin
 notimplemented();
end; //offset before indirect
procedure indirectop();
begin
 notimplemented();
end;

procedure popindirect8op();
begin
 notimplemented();
end;
procedure popindirect16op();
begin
 notimplemented();
end;
procedure popindirect32op();
begin
 notimplemented();
end;
procedure popindirectop();
begin
 notimplemented();
end;

procedure callop();
begin
 with pc^.par.callinfo do begin
  outass('call void @s'+inttostr(ad+1)+'()');
 end;
end;

procedure calloutop();
begin
 notimplemented();
end;
procedure callvirtop();
begin
 notimplemented();
end;
procedure callintfop();
begin
 notimplemented();
end;
procedure virttrampolineop();
begin
 notimplemented();
end;

procedure locvarpushop();
begin
 //dummy
end;

procedure locvarpopop();
begin
 //dummy
end;

procedure subbeginop();
var
 endpo: pointer;
 allocpo: plocallocinfoty;
begin
 with pc^.par.subbegin do begin
  outass('define void @s'+inttostr(subname)+'(){');
  with pc^.par.subbegin do begin
   allocpo:= getsegmentpo(seg_localloc,varallocs);
   endpo:= pointer(allocpo)+varalloccount*sizeof(locallocinfoty);
   while allocpo < endpo do begin
    with allocpo^ do begin
     outass(locaddress(a)+' = alloca i'+inttostr(8*size));
    end;
    inc(allocpo);
   end;
  end;
 end;
end;

procedure subendop();
begin
 with pc^.par.subend do begin
  outass('}');
 end;
end;

procedure returnop();
begin
 outass('ret void');
end;

procedure initclassop();
begin
 notimplemented();
end;
procedure destroyclassop();
begin
 notimplemented();
end;

procedure decloop32op();
begin
 notimplemented();
end;
procedure decloop64op();
begin
 notimplemented();
end;

procedure setlengthstr8op();
begin
 notimplemented();
end;

procedure raiseop();
begin
 notimplemented();
end;
procedure pushcpucontextop();
begin
 notimplemented();
end;
procedure popcpucontextop();
begin
 notimplemented();
end;
procedure finiexceptionop();
begin
 notimplemented();
end;

procedure continueexceptionop();
begin
 notimplemented();
end;

procedure run();
var
 endpo: pointer;
begin
 pc:= getsegmentbase(seg_op);
 endpo:= pointer(pc)+getsegmentsize(seg_op);
 inc(pc,startupoffset);
 while pc < endpo do begin
  pc^.op.proc();
  inc(pc);
 end;
end;

const
{$include optable.inc}

function getoptable: poptablety;
begin
 result:= @optable;
end;

finalization
 freeandnil(assstream);
end.
