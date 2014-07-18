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
procedure allocproc(const asize: integer; var address: segaddressty);

procedure run();
 
implementation
uses
 sysutils,msestream,msesys,segmentutils;

var
 sp: integer; //unnamed variables
 pc: popinfoty;

var
 assstream: ttextstream;

procedure outass(const atext: string);
begin
 assstream.writeln(atext);
end;
  
procedure notimplemented();
begin
 raise exception.create('LLVM OP not implemented');
end;

const
 segprefix: array[segmentty] of string = (
 //seg_nil,seg_stack,seg_globvar,seg_globconst,
   '',     '@s',       '@gv',      '@gc',
 //seg_op,seg_rtti,seg_intf,seg_alloc
   '@o',  '@rt',   '@if',   '');
               
function segdataaddress(const address: segdataaddressty): string;
begin
 result:= segprefix[address.a.segment]+inttostr(address.a.address);
end;

function segaddress(const address: segaddressty): string;
begin
 result:= segprefix[address.segment]+inttostr(address.address);
end;

procedure stackassign(const offset: integer; const value: v32ty);
begin
 outass('%'+inttostr(sp+offset)+' = add i32 '+inttostr(int32(value))+' ,0');
end;

procedure segassign32(const offset: integer; const dest: segdataaddressty);
begin
 outass('store i32 %'+inttostr(sp+offset)+', i32*  '+segdataaddress(dest));
end;

procedure nop();
begin
 //dummy;
end;

type
 allocinfoty = record
  a: segaddressty;
  size: integer;
 end;
 pallocinfoty = ^allocinfoty;

var
 exitcodeaddress: segaddressty;
  
procedure beginparseop();
var
 endpo: pointer;
 allocpo: pallocinfoty;
begin
 freeandnil(assstream);
 assstream:= ttextstream.create('test.ll',fm_create);
 allocpo:= getsegmentbase(seg_alloc);
 endpo:= pointer(allocpo)+getsegmentsize(seg_alloc);
 exitcodeaddress:= pc^.par.beginparse.exitcodeaddress;
 while allocpo < endpo do begin
  with allocpo^ do begin
   case a.segment of 
    seg_globvar: begin
     outass(segprefix[seg_globvar]+inttostr(a.address)+' = global i'+
                                             inttostr(8*size)+ ' 0');
    end;
   end;
  end;
  inc(allocpo);
 end;
 outass('define i32 @main() {');
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
 stackassign(0,pc^.par.v32);
 inc(sp);
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
 notimplemented();
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
 dec(sp);
 segassign32(0,pc^.par.segdataaddress);
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
 notimplemented();
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
 notimplemented();
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
 notimplemented();
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
 notimplemented();
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
 notimplemented();
end;
procedure locvarpopop();
begin
 notimplemented();
end;
procedure returnop();
begin
 notimplemented();
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
 sp:= 1;

 pc:= getsegmentbase(seg_op);
 endpo:= pointer(pc)+getsegmentsize(seg_op);
 inc(pc,startupoffset);
 while pc < endpo do begin
  pc^.op.proc();
  inc(pc);
 end;
end;

const
 llvmoptable: optablety = (
  nil,
  @nop,

  @beginparseop,
  @progendop, //oc_progend
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
 result:= @llvmoptable;
end;

procedure allocproc(const asize: integer; var address: segaddressty);
begin
 if address.segment = seg_globvar then begin
  address.address:= info.allocid;
  with pallocinfoty(allocsegmentpo(seg_alloc,sizeof(allocinfoty)))^ do begin
   a:= address;
   size:= asize;
  end;
 end;
end;

finalization
 freeandnil(assstream);
end.
