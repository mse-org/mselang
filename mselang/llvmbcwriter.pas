{ MSElang Copyright (c) 2014-2017 by Martin Schreiber
   
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
unit llvmbcwriter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,msestream,msetypes,llvmbitcodes,parserglob,elements,msestrings,
 llvmlists,opglob,bcunitglob,unithandler;
 
type
 idarty = record
  count: int32;
  ids: pint32;
 end;

const
 emptyidar: idarty = (count: 0; ids: nil);
 
const
 bcwriterbuffersize = 16; //test flushbuffer, todo: make it bigger
 blockstacksize  = 256;

type
 blockstackinfoty = record
  idsize: integer;
  startpos: integer;
 end;
 pblockstackinfoty = ^blockstackinfoty;

 bcdataty = record
  bitsize: integer;
  data: pcard8;
 end;
 pbcdataty = ^bcdataty;
  
 tllvmbcwriter = class(tmsefilestream)
  private
   fbuffer: array[0..bcwriterbuffersize-1] of byte;
   fbufend: pointer;
   fbufpos: pointer;
   fblockstack: array[0..blockstacksize-1] of blockstackinfoty;
   fblockstackpo: pblockstackinfoty;
   fblockstackendpo: pblockstackinfoty;
   fpos: integer;
   fbitpos: integer;
   fbitbuf: card16;
   fdebugloc: debuglocty;
   fnodebugloc: boolean;
   ftrampolineop: popinfoty;
   fstartpos: int32;
  protected
   fdatalayout: string;
   ftriple: string;
//   fmetadata: tmetadatalist;
   fmetadatatype: int32;
   flandingpadtype: int32;
   fpointertype: int32;
   fpointersizeconst: int32;
   fconstseg: int32;
   fclassdefs: pointer;
   flastdebugloc: debuglocty;
   fconststart: int32;      //start of global constants
   fsubstart: int32;        //start of sub values (params)
   fsubparamstart: int32;   //reference for param access
   fsuballocstart: int32;   //reference for allocs
   fsubtempstart: int32;    //reference for temp allocs
   fsubopstart: int32;      //start of op ssa id's
   fsubopindex: int32;      //current op ssa is
   fcurrentbb: int32;
   flandingpadblock: int32;
//   fgetexceptionpointer: int32;
  {$ifdef mse_checkinternalerror}
   procedure checkalignment(const bytes: integer);
  {$endif}
   procedure write8(const avalue: int8);
   procedure write16(const avalue: int16);
   procedure write32(const avalue: int32);
   procedure write64(const avalue: int64);
   procedure writeback32(const apos: int32; const avalue: int32);
//   procedure writeabbrev();
   procedure emit(const asize: integer; const avalue: card8);
   procedure emit1(const avalue: card8);
   procedure emit4(const avalue: card8);
   procedure emit5(const avalue: card8);
   procedure emit6(const avalue: card8);
   procedure emit8(const avalue: card8);
   procedure emitvbr4(avalue: int32);
   procedure emitvbr5(avalue: int32);
   procedure emitvbr6(avalue: int32);
   procedure emitvbr6(avalue: int64);
   procedure emitvbr8(avalue: int32);
   procedure emitcode(const avalue: int32);
   procedure emitdata(const avalue: bcdataty);
   procedure emitdata(const avalues: array of pbcdataty);
//   procedure emitchar6(const avalue: shortstring);
   procedure emitchar6(const avalue: pchar; const alength: integer);
   procedure emitchar6(const avalue: array of lstringty);
//   procedure emitint32rec(const id: int32; const value: int32);
   procedure pad32();
   procedure emittypeid(const avalue: int32);
   procedure emitintconst(const avalue: int32);
   procedure emitintconst(const avalue: int64);
   procedure emitfloatconst(const avalue: flo64);
   procedure emitdataconst(const avalue; const asize: int32);
   procedure emitpointercastconst(const avalue: int32; const atype: int32);
   procedure checkdebugloc();
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure start(const consts: tconsthashdatalist;
                    const globals: tgloballocdatalist;
                    const metadata: tmetadatalist;
                    const unitheader: bcunitinfoty;
                    const adatalayout: string;
                    const atriple: string; const apersonality: int32);
   procedure stop();
   procedure flushbuffer(); override;
   function bitpos(): int32;

   function typeval(const typeid: databitsizety): int32; inline;
   function ptypeval(const typeid: databitsizety): int32; inline;
   function pptypeval(const typeid: databitsizety): int32; inline;
   function typeval(const typeid: int32): int32; inline;
   function ptypeval(const typeid: int32): int32; inline;
   function pptypeval(const typeid: int32): int32; inline;
   function typeval(const alloc: typeallocinfoty): int32; inline;
   function ptypeval(const alloc: typeallocinfoty): int32; inline;
   function constval(const constid: int32): int32; inline;
   function globval(const globid: int32): int32; inline;
   function paramval(const paramid: int32): int32; inline;
   function allocval(const allocid: int32): int32; inline;
   function tempval(const tempid: int32): int32; inline;
   function subval(const offset: int32): int32; inline; 
                          //0 -> first param
   function ssaval(const ssaid: int32): int32; inline;
   function relval(const offset: int32): int32; inline; 
                    //0 -> result of last op
//   function subval(const subid: int32): int32; inline;

   procedure beginblock(const id: blockids; const nestedidsize: int32);
   procedure endblock();
   procedure emitrec(const id: int32; const data: array of int32;
                                         const extensioncount: int32 = 0);
   procedure emitrec(const id: int32; const data: array of int32;
                                                 const adddata: idarty);
   procedure emitrec(const id: int32; const data: array of int32;
                                   const addlen: int32; const adddata: pint32);
   procedure emitrec(const id: int32; const data: array of int32;
                                                const adddata: array of int32);
   procedure emitrec(const id: int32; const len: int32; const data: pcard8);
   procedure emitrec(const id: int32; const len: int32; const data: pint32);

   procedure emitnopssa(); //1 ssa
   
   procedure emitsub(const atype: int32; const acallingconv: callingconvty;
               const aflags: subflagsty;
               const alinkage: linkagety; const aparamattr: int32;
               const apersonality: int32);
   procedure emitsubdbg(const avalue: int32);
   procedure emitvar(const atype: int32; const alinkage: linkagety);
   procedure emitvar(const atype: int32; const ainitconst: int32;
                                                   const alinkage: linkagety);
   procedure emitconst(const atype: int32; const ainitconst: int32);
   procedure emitalloca(const atype: int32); //1 ssa //todo: use explicittype
   procedure resetssa(); //sets ssastart to current ssa
   
   procedure beginsub(const aflags: subflagsty; const allocs: suballocinfoty;
                                                          const bbcount: int32);
   procedure endsub();
                                        //todo: add explicit typeid to call ops
   procedure emitcallop(const afunc: boolean;
             const valueid: int32; const aparams: idarty);
                                          //changes aparams
   procedure emitcallop(const afunc: boolean;
             const valueid: int32; aparams: array of int32);
   
   procedure emitvstentry(const aid: integer; const aname: lstringty);
   procedure emitvstentry(const aid: integer; const anames: array of lstringty);
   procedure emitvstbbentry(const aid: integer; const aname: lstringty);

   procedure emitphiop(const atyp: int32; const alist: pphilistty);
   
   procedure emitbrop(const acond: int32; const bb1: int32; 
                                                    const bb0: int32);
   procedure emitbrop(const bb: int32);
   procedure emitretop();                    //procedure
   procedure emitretop(const avalue: int32); //function

   procedure emitresumeop(const avalue: int32);
   
   procedure emitsegdataaddress(const aaddress: memopty); //i8*
   procedure emitsegdataaddresspo(const aaddress: memopty); //for load/store

   procedure emitlocdataaddress(const aaddress: memopty); //i8*, 2 ssa
   procedure emitlocdataaddresspo(const aaddress: memopty);
                               //for load/store, 3 ssa

   procedure emitptroffset(const avalue: int32; const aoffset: int32);
   procedure emitgetelementad(const avalue: int32; const atype: int32;
                                                    const aindex: int32);//1 ssa
   procedure emitgetelementptr(const avalue: int32;
                                              const aoffset: int32);
                                         //aoffset = byteoffset, 2 ssa
   procedure emitbitcast(const asource: int32; const adesttype: int32); //1 ssa
   procedure emitcastop(const asource: int32; const adesttype: int32;
                                               const aop: castopcodes); //1 ssa
                                 
   procedure emitloadop(const asource: int32);
   procedure emitstoreop(const asource: int32; const adest: int32);

   procedure emitpushconst(const aconst: llvmvaluety);
   procedure emitpushconstsegad(const aoffset: int32); //2ssa
   
   procedure emitbinop(const aop: BinaryOpcodes; 
                         const valueida: int32; const valueidb: int32);
   procedure emitcmpop(const apred: Predicate; const valueida: int32;
                                                      const valueidb: int32);
   procedure emitlandingpad(const aresulttype: int32; 
                                        const apersonality: int32); //1ssa
   procedure emitdebugloc(const avalue: debuglocty);
   procedure emitdebuglocagain();

   procedure marktrampoline(const apc: popinfoty);
   procedure releasetrampoline(out apc: popinfoty); //nil if none

   procedure emitmetadatakind(const aid: int32; const len: int32;
                                                       const name: pchar);
   
   procedure emitmetavalue(const atyp,avalue: int32);  
   procedure emitmetafile(const afile,adirectory: int32);
   procedure emitmetacompileunit(const avalue: dicompileunitty);
   procedure emitmetabasictype(const avalue: dibasictypety);
   procedure emitmetasubrange(const avalue: disubrangety);
   procedure emitmetadataenumerator(const avalue: dienumeratorty);
   procedure emitmetaderivedtype(const avalue: diderivedtypety);
   procedure emitmetacompositetype(const avalue: dicompositetypety);
   procedure emitmetarefstringtype(const avalue: direfstringtypety);
   procedure emitmetasubroutinetype(const avalue: disubroutinetypety);
   procedure emitmetasubprogram(const avalue: disubprogramty);
   procedure emitmetaglobalvar(const avalue: diglobvariablety);
   procedure emitmetalocalvar(const avalue: dilocvariablety);
   procedure emitmetaexpression(const avalue: diexpressionty);
   procedure emitgenericdebug(const tag: int32; const len: int32;
                                                const values: pmetavaluety);
   procedure emitmetanode(const len: int32; const values: pmetavaluety);
   procedure emitmetanode(const values: array of metavaluety);
   procedure emitnamedmetanode(const namelen: int32; const name: pcard8;
                                 const len: int32; const values: pint32);
//   procedure emitmetadatafnnonde(const avalue,atype: int32);
   function valindex(const aadress: segaddressty): integer;
   property pointertype: int32 read fpointertype;
   property landingpadtype: int32 read flandingpadtype;
   property pointersizeconst: int32 read fpointersizeconst;
   property landingpadblock: int32 read flandingpadblock write flandingpadblock;
//   property getexceptionpointer: int32 read fgetexceptionpointer 
//                                                   write fgetexceptionpointer;
       //"token" and llvm.eh.padparam.pNi8 seem not to work with llvm 3.8
   property constseg: int32 read fconstseg write fconstseg;
   property classdefs: pointer read fclassdefs write fclassdefs;
   property ssaindex: int32 read fsubopindex;
   property debugloc: debuglocty read fdebugloc write fdebugloc;
   property nodebugloc: boolean read fnodebugloc write fnodebugloc;
 end;

function signedvbr(const avalue: integer): integer; inline;
function signedvbr(const avalue: int64): int64; inline;
 
implementation
uses
 errorhandler,msesys,sysutils,msebits,mseformatstr,identutils;

 //abreviations, made by createabbrev tool todo: use more abbrevs
 
type
 mabmodty = (
  mabmod_sub = 4 //MODULE_CODE_FUNCTION (literal 8), type (vbr 6), callingconv (vbr 6), isproto (fixed 1), linkagetype (vbr 6), paramattr (vbr 6), alignment (literal 0), section (literal 0), visibility (literal 0), gc (literal 0), unnamed_addr (literal 0), prologdata (literal 0), dllstorageclass (literal 0), comdat (literal 0), prefixdata (literal 0), personality (vbr 6)
 );
const
 mabmodsdat: array[0..19] of card8 = (130,33,2,25,50,18,200,144,9,16,32,64,128,0,1,2,4,8,64,6);
 mabmods: bcdataty = (bitsize: 157; data: @mabmodsdat);

type
 mabconstty = (
  mabconst_int = 4, //id (vbr 6), value (vbr 6)
  mabconst_data //id (vbr 6), array (array), data (vbr 8)
 );
const
 mabconstsdat: array[0..6] of card8 = (18,100,200,104,144,49,66);
 mabconsts: bcdataty = (bitsize: 56; data: @mabconstsdat);

type
 mabtypety = (
  mabtype_subtype = 4 //TYPE_CODE_FUNCTION (literal 21), vararg (fixed 1), retty (vbr 6), paramty (array),  (vbr 6)
 );
const
 mabtypesdat: array[0..5] of card8 = (42,43,36,144,49,50);
 mabtypes: bcdataty = (bitsize: 48; data: @mabtypesdat);

type
 mabsymty = (
  mabsym_entry = 4, //VST_CODE_ENTRY (literal 1), valid (vbr 6), namechar (array),  (char6)
  mabsym_bbentry //VST_CODE_BBENTRY (literal 2), valid (vbr 6), namechar (array),  (char6)
 );
const
 mabsymsdat: array[0..8] of card8 = (34,3,200,24,138,20,32,99,8);
 mabsyms: bcdataty = (bitsize: 68; data: @mabsymsdat);

type
 mabfuncty = (
  mabfunc_inst0 = 4, //instruction code (fixed 6)
  mabfunc_inst1, //instruction code (fixed 6), par1 (vbr 6)
  mabfunc_inst2 //instruction code (fixed 6), par1 (vbr 6), par2 (vbr 6)
 );
const
 mabfuncsdat: array[0..9] of card8 = (10,98,36,196,144,209,16,67,134,12);
 mabfuncs: bcdataty = (bitsize: 78; data: @mabfuncsdat);



const

 char6tab: array[char] of card8 = (
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
//                                                        '.'
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$3e,$ff,
//'0','1','2','3','4','5','6','7','8','9'
  $34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$ff,$ff,$ff,$ff,$ff,$ff,
//    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O' ,
  $ff,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$24,$25,$26,$27,$28,
//'P','Q','R','S','T','U','V','W','X','Y','Z'                 '_'
  $29,$2a,$2b,$2c,$2d,$2e,$2f,$30,$31,$32,$33,$ff,$ff,$ff,$ff,$3f,
//    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
  $ff,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,
//'p','q','r','s','t','u','v','w','x','y','z'
  $0f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 );
 
function signedvbr(const avalue: integer): integer; inline;
begin
 if avalue < 0 then begin
  result:= (-avalue shl 1) or 1;
 end
 else begin
  result:= avalue shl 1;
 end;
end;

function signedvbr(const avalue: int64): int64; inline;
begin
 if avalue < 0 then begin
  result:= (-avalue shl 1) or 1;
 end
 else begin
  result:= avalue shl 1;
 end;
end;

function typeindex(const avalue: databitsizety): integer; inline;
begin
 result:= ord(avalue) * typeindexstep;
end;

function typeindex(const avalue: integer): integer; inline;
begin
 result:= avalue * typeindexstep;
end;

function ptypeindex(const avalue: integer): integer; inline;
begin
 result:= avalue * typeindexstep + 1;
end;

function pptypeindex(const avalue: integer): integer; inline;
begin
 result:= avalue * typeindexstep + 2;
end;

function metaornull(const ameta: metavaluety): int32;
begin
 result:= ameta.id + 1;
{
 if idmvf_dummy in ameta.flags then begin
  result:= 0;
 end
 else begin
  result:= ameta.value.listid+1;
 end;
}
end; 

{ tllvmbcwriter }

constructor tllvmbcwriter.create(ahandle: integer);
begin
 fbufpos:= @fbuffer;
 fbufend:= fbufpos + bcwriterbuffersize;
 fblockstackpo:= @fblockstack;
 fblockstackendpo:= fblockstackpo + blockstacksize;
 fblockstackpo^.idsize:= 2; //start default
 inherited;
end;

destructor tllvmbcwriter.destroy();
begin
 inherited;
end;

procedure tllvmbcwriter.start(const consts: tconsthashdatalist;
                              const globals: tgloballocdatalist;
                              const metadata: tmetadatalist;
                              const unitheader: bcunitinfoty;
                              const adatalayout: string;
                              const atriple: string;
                              const apersonality: int32);
var
 id1: int32;
 
 procedure checkconsttypeid(const aid: int32);
 begin
  if id1 <> aid then begin
   id1:= aid;
   emittypeid(id1*typeindexstep);
  end;
 end; //checkconsttypeid

var
 pt1: ptypelistdataty;
 pc2: pconstlistdataty;
 pp3,pp4: pparamitemty;
 pga5,pgae: pgloballocdataty;
 pgn7,pgne: pglobnamedataty;
 pa,pe: pint32;
 i1,i2,i3: int32;
 po9: paggregateconstty;
 pm1: pmetadataty;
 m1,m2: metavaluety;
 namebuffer1,separatorbuffer1: lstringty;
 namebufferdata1: array[0..2*sizeof(int32)-1] of char;
 separator1: char;
 wrap: bcunitheaderty;
begin
 fdatalayout:= adatalayout;
 ftriple:= atriple;
 fstartpos:= position;
 wrap.wrap.magic:= bcheadermagic;
 wrap.wrap.version:= bcheaderversion;
 wrap.wrap.bitcodeoffset:= sizeof(bcunitheaderty); //from filestart
 wrap.wrap.bitcodesize:= 0;
 wrap.wrap.cputype:= 0;
 wrap.header:= unitheader;
 writebuffer(wrap,sizeof(wrap));
 fpos:= fstartpos+sizeof(wrap);

 ftrampolineop:= nil;
 fdebugloc.line:= -1;
 fdebugloc.col:= 0;
 flastdebugloc.line:= -1;
 flastdebugloc.col:= 0;
 fmetadatatype:= consts.typelist.metadata;
 flandingpadtype:= consts.typelist.landingpad;
// fgetexceptionpointer:= globals.getexceptionpointer;
 fpointersizeconst:= consts.pointersize;
 fpointertype:= ptypeval(das_8);
 write32(int32((uint32($dec0) shl 16) or (uint32(byte('C')) shl 8) or
                                                             uint32('B')));
                                //llvm ir signature

 beginblock(MODULE_BLOCK_ID,3);

 beginblock(BLOCKINFO_BLOCK_ID,3); //abbreviations, must be in module block for
                                   //llvm 3.7
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(CONSTANTS_BLOCK_ID)]);
 emitdata(mabconsts);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(TYPE_BLOCK_ID_NEW)]);
 emitdata(mabtypes);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(VALUE_SYMTAB_BLOCK_ID)]);
 emitdata(mabsyms);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(FUNCTION_BLOCK_ID)]);
 emitdata(mabfuncs);
 endblock();
 emitdata(mabmods);

 emitrec(ord(MODULE_CODE_VERSION),[1]);
 emitrec(ord(MODULE_CODE_DATALAYOUT),length(fdatalayout),
                                       pcard8(pointer(fdatalayout)));
 emitrec(ord(MODULE_CODE_TRIPLE),length(ftriple),pcard8(pointer(ftriple)));
 
 fconststart:= globals.count;
 fsubstart:= globals.count+consts.count;
                                                      //types
 if consts.typelist.count > 0 then begin
  beginblock(TYPE_BLOCK_ID_NEW,3);
  emitrec(ord(TYPE_CODE_NUMENTRY),[consts.typelist.count*typeindexstep]);
  pt1:= consts.typelist.first();
  for i1:= consts.typelist.count - 1 downto 0 do begin
   if ord(pt1^.kind) < 0 then begin
    case aggregatekindty(-ord(pt1^.kind)) of
     ak_pointerarray: begin
      emitrec(ord(TYPE_CODE_ARRAY),[pt1^.header.buffer,typeval(pointertype)]);
     end;
     ak_aggregatearray: begin
      with paggregatearraytypedataty(info.s.unitinfo^.llvmlists.typelist.
                                        absdata(pt1^.header.buffer))^ do begin
       emitrec(ord(TYPE_CODE_ARRAY),[size,typeval(typ)]);
      end;
     end;
     ak_struct: begin
      i2:= pt1^.header.buffersize div sizeof(int32);
      emitrec(ord(TYPE_CODE_STRUCT_ANON),[0],i2);
      pa:= info.s.unitinfo^.llvmlists.typelist.absdata(pt1^.header.buffer);
      pe:= pa+i2;
      while pa < pe do begin
       emitvbr6(typeval(pa^));
       inc(pa);
      end;
     end;
     else begin
      internalerror1(ie_bcwriter,'20150329A');
     end;
    end;
   end
   else begin
    if pt1^.kind in ordinalopdatakinds then begin
     if pt1^.kind = das_pointer then begin
      emitrec(ord(TYPE_CODE_POINTER),[typeindex(das_8)]);
     end
     else begin
      emitrec(ord(TYPE_CODE_INTEGER),[pt1^.header.buffer]);
     end;
    end
    else begin
     if pt1^.kind in byteopdatakinds then begin
//      if pt1^.header.buffer = 0 then begin
      if pt1^.header.buffer = ptruint(ptrint(-1)) then begin
       emitrec(ord(TYPE_CODE_VOID),[]);     
       emitrec(ord(TYPE_CODE_VOID),[]); //dummy *type
       emitrec(ord(TYPE_CODE_VOID),[]); //dummy **type
       pt1:= consts.typelist.next();
       continue;
      end
      else begin
       emitrec(ord(TYPE_CODE_ARRAY),[pt1^.header.buffer,typeindex(das_8)]);     
      end;
     end
     else begin
      case pt1^.kind of
       das_f16: begin
        emitrec(ord(TYPE_CODE_HALF),[]);     
       end;
       das_f32: begin
        emitrec(ord(TYPE_CODE_FLOAT),[]);     
       end;
       das_f64: begin
        emitrec(ord(TYPE_CODE_DOUBLE),[]);     
       end;
       das_sub: begin
        with psubtypedataty(
                consts.typelist.absdata(pt1^.header.buffer))^ do begin
                      //todo: vararg
         emitcode(ord(mabtype_subtype));
         i2:= header.paramcount;
         pp3:= @params;
         if sf_vararg in header.flags then begin
          emit1(1);      //vararg
         end
         else begin
          emit1(0);      //no vararg
         end;
         if sf_function in header.flags then begin
          dec(i2);
          emitvbr6(typeindex(pp3[0].typelistindex)); //retval
          inc(pp3);
//          emitvbr6(typeindex(pp3[i2].typelistindex)); //retval
         end
         else begin
          emitvbr6(typeindex(das_none)); //void retval
         end;
         emitvbr6(i2); //param count
         pp4:= pp3+i2;
         while pp3 < pp4 do begin
          emitvbr6(typeindex(pp3^.typelistindex));
          inc(pp3);
         end;
        end;
       end;
       das_meta: begin
        emitrec(ord(TYPE_CODE_METADATA),[]);     
       end;
       else begin
       {$ifdef mse_checkinternalerror}
        internalerror(ie_bcwriter,'20141216A');
       {$endif}
       end;
      end;
     end;
    end;
   end;
   if pt1^.kind = das_meta then begin
    emitrec(ord(TYPE_CODE_METADATA),[]);
    emitrec(ord(TYPE_CODE_METADATA),[]);
   end
   else begin
    emitrec(ord(TYPE_CODE_POINTER),[pt1^.header.listindex*typeindexstep]);
    emitrec(ord(TYPE_CODE_POINTER),[pt1^.header.listindex*typeindexstep+1]);
   end;
   pt1:= consts.typelist.next();
  end;
  endblock(); 
                                                           //globals
  pga5:= globals.datapo;
  pgae:= pga5 + globals.count;
  while pga5 < pgae do begin
   case pga5^.kind of
    gak_sub: begin
     emitsub(pga5^.typeindex,cv_ccc,pga5^.flags,pga5^.linkage,0,
     apersonality+1);
    end;
    gak_const: begin
     emitconst(pga5^.typeindex,pga5^.initconstindex);
    end;
    gak_var: begin
     if pga5^.initconstindex >= 0 then begin
      emitvar(pga5^.typeindex,pga5^.initconstindex,pga5^.linkage);
     end
     else begin
      emitvar(pga5^.typeindex,pga5^.linkage);
     end;
    end;
   end;
   inc(pga5);
  end;
  namebuffer1.len:= length(namebufferdata1);
  namebuffer1.po:= @namebufferdata1;
  separator1:= '.';
  separatorbuffer1.po:= @separator1;
  separatorbuffer1.len:= 1;
  if globals.namelist.count > 0 then begin
   beginblock(VALUE_SYMTAB_BLOCK_ID,3);
   pgn7:= globals.namelist.datapo;
   pgne:= pgn7 + globals.namelist.count;
   while pgn7 < pgne do begin
    if pgn7^.name.offset <= 0 then begin 
              //concat unitname and destindex
     i1:= -pgn7^.nameunit.destindex - 
                       punitinfoty(pgn7^.nameunit.po)^.globallocstart;
     for i2:= 0 to high(namebufferdata1) do begin
      i3:= i1 and $f;
      namebufferdata1[i2]:= charhexlower[i3];
      i1:= card32(i1) shr 4;
      if i1 = 0 then begin
       namebuffer1.len:= i2+1;
       break;
      end;
     end;
     emitvstentry(pgn7^.listindex,
         [punitinfoty(pgn7^.nameunit.po)^.name,separatorbuffer1,namebuffer1]);
    end
    else begin
     emitvstentry(pgn7^.listindex,nametolstring(pgn7^.name));
    end;
    inc(pgn7);
   end;
   endblock();
  end;
                                                             //consts
  if consts.count > 0 then begin
   beginblock(CONSTANTS_BLOCK_ID,3);
   id1:= -1;
   pc2:= consts.first;
   for i1:= 0 to consts.count-1 do begin
    if pc2^.typeid < 0 then begin //consttypety
     case consttypety(-pc2^.typeid) of
      ct_null: begin       
       checkconsttypeid(int32(pc2^.header.buffer));
       emitrec(ord(CST_CODE_NULL),[]);
      end;
      ct_pointercast: begin
       checkconsttypeid(pointertype);
       emitpointercastconst(globval(pc2^.header.buffer),
                 ptypeval(info.s.unitinfo^.llvmlists.globlist.
                                                gettype(pc2^.header.buffer)));
      end;
      ct_pointerarray,ct_aggregatearray: begin
       pa:= info.s.unitinfo^.llvmlists.constlist.absdata(pc2^.header.buffer);
       i2:= pc2^.header.buffersize div sizeof(int32) - 1;
       checkconsttypeid(pa[i2]); //last item is type
       emitrec(ord(CST_CODE_AGGREGATE),[],i2); //ids
       pe:= pa+i2;
       while pa < pe do begin
        emitvbr6(constval(pa^));
        inc(pa);
       end;
      end;
      ct_aggregate: begin
       po9:= info.s.unitinfo^.llvmlists.constlist.absdata(pc2^.header.buffer);
       checkconsttypeid(po9^.header.typeid);
       pa:= @po9^.items;
       i2:= po9^.header.itemcount;
       emitrec(ord(CST_CODE_AGGREGATE),[],i2); //ids
       pe:= pa+i2;
       while pa < pe do begin
        emitvbr6(constval(pa^));
        inc(pa);
       end;
      end;
      else begin
       internalerror1(ie_bcwriter,'20150328A');
      end;
     end;
    end
    else begin //typeid
     checkconsttypeid(pc2^.typeid);
     case databitsizety(pc2^.typeid) of
      das_1..das_32: begin
       emitintconst(int32(pc2^.header.buffer));
      end;
      das_64: begin
     {$ifdef cpu64}
       emitintconst(int64(pc2^.header.buffer));
     {$else}
       emitintconst(pint64(consts.absdata(pc2^.header.buffer))^);
     {$endif}
      end;
      das_f32: begin
       emitfloatconst(flo32(pc2^.header.buffer));
      end;
      das_f64: begin
     {$ifdef cpu64}
       emitfloatconst(flo64(pc2^.header.buffer));
     {$else}
       emitfloatconst(pflo64(consts.absdata(pc2^.header.buffer))^);
     {$endif}
      end;
      else begin
      {$ifdef mse_checkinternalerror}
       if databitsizety(pc2^.typeid) <= lastdatakind then begin
        internalerror(ie_bcwriter,'141220A');
       end;
      {$endif}
       emitdataconst(consts.absdata(pc2^.header.buffer)^,
                                                pc2^.header.buffersize);
      end;
     end;
    end;
    pc2:= consts.next();
   end;
   endblock(); 
  end;
 end;
 if metadata.count > 0 then begin                          //metadata
  beginblock(METADATA_BLOCK_ID,3);
  pm1:= metadata.first();
  while pm1 <> nil do begin
   case pm1^.header.kind of
    mdk_string: begin
     with pstringmetaty(@pm1^.data)^ do begin
      emitrec(ord(METADATA_STRING),len,pcard8(@data));
     end;
    end;
    mdk_ident: begin
     with nametolstring(pidentmetaty(@pm1^.data)^.name) do begin
      emitrec(ord(METADATA_STRING),len,pcard8(po));
     end;
    end;
    mdk_digenericdebug: begin
     with pdigenericdebugty(@pm1^.data)^ do begin
      emitgenericdebug(tag,len,@data);
     end;
    end;
    mdk_node: begin
     with pnodemetaty(@pm1^.data)^ do begin
      emitmetanode(len,@data);
     end;
    end;
    mdk_namednode: begin
     with pnamednodemetaty(@pm1^.data)^ do begin
      emitnamedmetanode(namelen,@data+len*sizeof(int32),len,@data);
     end;
    end;
    mdk_difile: begin
     with pdifilety(@pm1^.data)^ do begin
      emitmetafile(filename.id,dirname.id);
     end;
    end;
    mdk_dibasictype: begin
     emitmetabasictype(pdibasictypety(@pm1^.data)^);
    end;
    mdk_disubrange: begin
     emitmetasubrange(pdisubrangety(@pm1^.data)^);
    end;
    mdk_dienumerator: begin
     emitmetadataenumerator(pdienumeratorty(@pm1^.data)^);
    end;
    mdk_diderivedtype: begin
     emitmetaderivedtype(pdiderivedtypety(@pm1^.data)^);
    end;
    mdk_dicompositetype: begin
     emitmetacompositetype(pdicompositetypety(@pm1^.data)^);
    end;
    mdk_direfstringtype: begin
     emitmetarefstringtype(pdirefstringtypety(@pm1^.data)^);
    end;
    mdk_dicompileunit: begin
     emitmetacompileunit(pdicompileunitty(@pm1^.data)^);
    end;
    mdk_disubprogram: begin
     emitmetasubprogram(pdisubprogramty(@pm1^.data)^);
    end;
    mdk_disubroutinetype: begin
     emitmetasubroutinetype(pdisubroutinetypety(@pm1^.data)^);
    end;
    mdk_diglobvariable: begin
     emitmetaglobalvar(pdiglobvariablety(@pm1^.data)^);
    end;
    mdk_dilocvariable: begin
     emitmetalocalvar(pdilocvariablety(@pm1^.data)^)
    end;
    mdk_diexpression: begin
     emitmetaexpression(pdiexpressionty(@pm1^.data)^)
    end;
    mdk_constvalue: begin
     with pvaluemetaty(@pm1^.data)^ do begin
      emitmetavalue(typeval(value.typeid),constval(value.listid));
     end;
    end;
    mdk_globvalue: begin
     with pvaluemetaty(@pm1^.data)^ do begin
      emitmetavalue(ptypeval(value.typeid),globval(value.listid));
     end;
    end;
    else begin
     internalerror1(ie_llvm,'20150516A');
    end;
   end;
   pm1:= metadata.next();
  end;
  endblock();  
 end;

end;

procedure tllvmbcwriter.stop;
var
 i1: int32;
begin
 endblock();
{$ifdef mse_checkinternalerror}
 if fblockstackpo <> @fblockstack then begin
  internalerror(ie_bcwriter,'141213C');
 end;
{$endif}
 flushbuffer();
 i1:= position - fstartpos - sizeof(bcunitheaderty);
 position:= fstartpos + bitcodesizeoffset;
 write(i1,sizeof(bc_header.bitcodesize));
end;


{$ifdef mse_checkinternalerror}
procedure tllvmbcwriter.checkalignment(const bytes: integer);
begin
 if fbitpos <> 0 then begin
  internalerror(ie_bcwriter,'141214A');
 end;
 if (fbufpos - pointer(@fbuffer)+fpos) mod bytes <> 0 then begin
  internalerror(ie_bcwriter,'141214B');
 end;
end;
{$endif}

procedure tllvmbcwriter.flushbuffer;
var
 int1: integer;
begin
 int1:= fbufpos-pointer(@fbuffer);
 if write(fbuffer,int1) <> int1 then begin
  checksysok(syelasterror(),err_write,[]);
  abort();
 end;
 fpos:= fpos + int1;
 fbufpos:= @fbuffer;
end;

//todo: endianess, currently littleendian only

procedure tllvmbcwriter.emit(const asize: integer; const avalue: card8);
begin
{$ifdef mse_checkinternalerror}
 if (asize < 0) or (asize > 8) then begin
  internalerror(ie_bcwriter,'141213D');
 end;
 if avalue and not bitmask[asize] <> 0 then begin
  internalerror(ie_bcwriter,'141213E');
 end;
{$endif}
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + asize;
 if fbitpos >= 8 then begin
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf;
  fbufpos:= fbufpos + 1;
  fbitbuf:= fbitbuf shr 8;
  fbitpos:= fbitpos - 8;
 end;
end;

procedure tllvmbcwriter.emit1(const avalue: card8);
begin
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + 1;
 if fbitpos >= 8 then begin
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf;
  fbufpos:= fbufpos + 1;
  fbitbuf:= fbitbuf shr 8;
  fbitpos:= fbitpos - 8;
 end;
end;

procedure tllvmbcwriter.emit4(const avalue: card8);
begin
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + 4;
 if fbitpos >= 8 then begin
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf;
  fbufpos:= fbufpos + 1;
  fbitbuf:= fbitbuf shr 8;
  fbitpos:= fbitpos - 8;
 end;
end;

procedure tllvmbcwriter.emit5(const avalue: card8);
begin
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + 5;
 if fbitpos >= 8 then begin
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf;
  fbufpos:= fbufpos + 1;
  fbitbuf:= fbitbuf shr 8;
  fbitpos:= fbitpos - 8;
 end;
end;

procedure tllvmbcwriter.emit6(const avalue: card8);
begin
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + 6;
 if fbitpos >= 8 then begin
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf;
  fbufpos:= fbufpos + 1;
  fbitbuf:= fbitbuf shr 8;
  fbitpos:= fbitpos - 8;
 end;
end;

procedure tllvmbcwriter.emit8(const avalue: card8);
begin
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + 8;
 if fbufpos + 1 >= fbufend then begin
  flushbuffer();
 end;
 pint8(fbufpos)^:= fbitbuf;
 fbufpos:= fbufpos + 1;
 fbitbuf:= fbitbuf shr 8;
 fbitpos:= fbitpos - 8;
end;

procedure tllvmbcwriter.emitvbr4(avalue: int32);
var
 i1: int32;
begin
 repeat
  i1:= avalue and $7;
  if card32(avalue) - i1 <> 0 then begin
   i1:= i1 or $80;
  end;
  emit4(i1);
  avalue:= card32(avalue) shr 3;
 until avalue = 0;
end;

procedure tllvmbcwriter.emitvbr5(avalue: int32);
var
 i1: int32;
begin
 repeat
  i1:= avalue and $f;
  if card32(avalue) - i1 <> 0 then begin
   i1:= i1 or $10;
  end;
  emit5(i1);
  avalue:= card32(avalue) shr 4;
 until avalue = 0;
end;

procedure tllvmbcwriter.emitvbr6(avalue: int32);
var
 i1: int32;
begin
 repeat
  i1:= avalue and $1f;
  if card32(avalue) - i1 <> 0 then begin
   i1:= i1 or $20;
  end;
  emit6(i1);
  avalue:= card32(avalue) shr 5;
 until avalue = 0;
end;

procedure tllvmbcwriter.emitvbr6(avalue: int64);
var
 i1: int64;
begin
 repeat
  i1:= avalue and $1f;
  if card64(avalue) - i1 <> 0 then begin
   i1:= i1 or $20;
  end;
  emit6(i1);
  avalue:= card64(avalue) shr 5;
 until avalue = 0;
end;

procedure tllvmbcwriter.emitvbr8(avalue: int32);
var
 i1: int32;
begin
 repeat
  i1:= avalue and $7f;
  if card32(avalue) - i1 <> 0 then begin
   i1:= i1 or $80;
  end;
  emit(8,i1);
  avalue:= card32(avalue) shr 7;
 until avalue = 0;
end;

procedure tllvmbcwriter.pad32;
var
 i1: int32;
begin
 if fbufpos + 5 >= fbufend then begin
  flushbuffer();
 end;
 if fbitpos <> 0 then begin
  emit(8-fbitpos,0);  
 end;
 i1:= fpos + (fbufpos-pointer(@fbuffer));  //byte pos
 i1:= ((i1+3) and not $3) - i1;            //pad count
 for i1:= i1-1 downto 0 do begin
  pcard8(fbufpos)^:= 0;
  inc(fbufpos);
 end;
end;

procedure tllvmbcwriter.emitcode(const avalue: int32);
begin
 emit(fblockstackpo^.idsize,avalue);
end;

procedure tllvmbcwriter.emitdata(const avalue: bcdataty);
var
 po1,pe: pcard8;
begin
 po1:= avalue.data;
 pe:= po1 + avalue.bitsize div 8;
 while po1 < pe do begin
  emit(8,po1^);
  inc(po1);
 end;
 emit(avalue.bitsize and $7,po1^); //trailing bits
end;

procedure tllvmbcwriter.emitdata(const avalues: array of pbcdataty);
var
 i1: int32;
begin
 for i1:= 0 to high(avalues) do begin
  emitdata(avalues[i1]^);
 end;
end;

procedure tllvmbcwriter.emitrec(const id: int32; const data: array of int32;
                                               const extensioncount: int32 = 0);
var
 i1: int32;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(length(data)+extensioncount);
 for i1:= 0 to high(data) do begin
  emitvbr6(data[i1]);
 end;
end;

procedure tllvmbcwriter.emitrec(const id: int32; const data: array of int32;
                                                         const adddata: idarty);
var
 i1: int32;
 po1,pe: pint32;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(length(data) + adddata.count);
 for i1:= 0 to high(data) do begin
  emitvbr6(data[i1]);
 end;
 po1:= adddata.ids;
 pe:= po1 + adddata.count;
 while po1 < pe do begin
  emitvbr6(po1^);
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitrec(const id: int32; const data: array of int32;
               const addlen: int32; const adddata: pint32);
var
 i1: int32;
 po1,pe: pint32;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(length(data) + addlen);
 for i1:= 0 to high(data) do begin
  emitvbr6(data[i1]);
 end;
 po1:= adddata;
 pe:= po1 + addlen;
 while po1 < pe do begin
  emitvbr6(po1^);
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitrec(const id: int32; const data: array of int32;
                                                const adddata: array of int32);
var
 i1: int32;
 po1,pe: pint32;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(length(data) + length(adddata));
 for i1:= 0 to high(data) do begin
  emitvbr6(data[i1]);
 end;
 for i1:= 0 to high(adddata) do begin
  emitvbr6(adddata[i1]);
 end;
end;

procedure tllvmbcwriter.emitrec(const id: int32; 
                      const len: int32; const data: pcard8);
                                //todo: use abbrev
var
 po1,pe: pcard8;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(len);
 po1:= data;
 pe:= data+len;
 while po1 < pe do begin
  emitvbr6(po1^);
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitrec(const id: int32; const len: int32;
                                                      const data: pint32);
var
 po1,pe: pint32;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(len);
 po1:= data;
 pe:= data+len;
 while po1 < pe do begin
  emitvbr6(po1^);
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitnopssa();
begin
 emitbinop(binop_add,constval(0),constval(0));
end;

procedure tllvmbcwriter.write8(const avalue: int8);
begin
{$ifdef mse_checkinternalerror}
 checkalignment(1);
{$endif}
 if fbufpos + 1 >= fbufend then begin
  flushbuffer();
 end;
 pint8(fbufpos)^:= avalue;
 fbufpos:= fbufpos + 1;
end;

procedure tllvmbcwriter.write16(const avalue: int16);
begin
{$ifdef mse_checkinternalerror}
 checkalignment(2);
{$endif}
 if fbufpos + 2 >= fbufend then begin
  flushbuffer();
 end;
 pint16(fbufpos)^:= avalue;
 fbufpos:= fbufpos + 2;
end;

procedure tllvmbcwriter.write32(const avalue: int32);
begin
{$ifdef mse_checkinternalerror}
 checkalignment(4);
{$endif}
 if fbufpos + 4 >= fbufend then begin
  flushbuffer();
 end;
 pint32(fbufpos)^:= avalue;
 fbufpos:= fbufpos + 4;
end;

procedure tllvmbcwriter.write64(const avalue: int64);
begin
{$ifdef mse_checkinternalerror}
 checkalignment(4);
{$endif}
 if fbufpos + 8 >= fbufend then begin
  flushbuffer();
 end;
 pint64(fbufpos)^:= avalue;
 fbufpos:= fbufpos + 8;
end;

procedure tllvmbcwriter.writeback32(const apos: int32; const avalue: int32);
begin
 if (apos < fpos) or (fbufpos + 4 >= fbufend) then begin
  flushbuffer();              //not in buffer
  position:= apos;
  writebuffer(avalue,4);
  position:= fpos;
 end
 else begin
  pint32(pointer(@fbuffer) + apos - fpos)^:= avalue;                                                            
 end;
end;
{
procedure tllvmbcwriter.writeint32rec(const id: int32; const value: int32);
begin
end;
}
{
type
 beginblockrecord = record //         4      8   fblockidsize
  header: uint32;          //    nextidsize id ENTER_SUBBLOCK
  blocklen: uint32;
 end;
 pbeginblockrecord = ^beginblockrecord;
} 
procedure tllvmbcwriter.beginblock(const id: blockids;
                                       const nestedidsize: int32);
begin
{
 if fbufpos + sizeof(beginblockrecord) >= fbufend then begin
  flushbuffer();
 end;
 pbeginblockrecord(fbufpos)^.header:= 
    ord(ENTER_SUBBLOCK) or (int32(id) shl fblockstackpo^.idsize) or 
                                 (nestedidsize shl (fblockstackpo^.idsize + 8));
 fbufpos:= fbufpos + sizeof(beginblockrecord);
}
 emitcode(ord(ENTER_SUBBLOCK));
 emitvbr8(ord(id));
 emitvbr4(nestedidsize);
 pad32();
 inc(fblockstackpo);
 if fblockstackpo >= fblockstackendpo then begin
  internalerror1(ie_bcwriter,'141213A'); //stack overflow
 end;
 write32(0); //blocklen
 fblockstackpo^.idsize:= nestedidsize;
 fblockstackpo^.startpos:= fpos + (fbufpos - pointer(@fbuffer));
end;

procedure tllvmbcwriter.endblock;
var
 int1,int2: integer;
begin
// int1:= fblockstackpo^.startpos - 4; //address blocklen
// writeback32(int1,((fpos + (fbufpos - pointer(@fbuffer)) - int1)+3) div 4 - 1); 
//                                     //word length without blocklen
 emitcode(ord(END_BLOCK));
 pad32();
 int1:= fblockstackpo^.startpos - 4; //address blocklen
 writeback32(int1,((fpos + (fbufpos - pointer(@fbuffer)) - int1) div 4 - 1)); 
                                     //word length without blocklen
 dec(fblockstackpo);
{$ifdef mse_checkinternalerror}
 if fblockstackpo < @fblockstack then begin
  internalerror(ie_bcwriter,'141213B');
 end;
{$endif}
end;
{
procedure tllvmbcwriter.writeabbrev;
begin
// beginblock(DEFINE_ABBREV,4);
// endblock();
end;
}
function tllvmbcwriter.bitpos: int32;
begin
 result:= (fpos + fbufpos - pointer(@fbuffer)) * 8 + fbitpos;
end;

procedure tllvmbcwriter.emitintconst(const avalue: int32);
begin
 emitcode(ord(mabconst_int));
 emitvbr6(ord(CST_CODE_INTEGER));
 emitvbr6(signedvbr(avalue));
end;

procedure tllvmbcwriter.emitintconst(const avalue: int64);
begin
 emitcode(ord(mabconst_int));
 emitvbr6(ord(CST_CODE_INTEGER));
 emitvbr6(signedvbr(avalue));
end;

procedure tllvmbcwriter.emitfloatconst(const avalue: flo64);
begin
 emitcode(ord(mabconst_int));
 emitvbr6(ord(CST_CODE_FLOAT));
 emitvbr6(pint64(@avalue)^);
end;

procedure tllvmbcwriter.emittypeid(const avalue: int32);
begin
 emitcode(ord(mabconst_int));
 emitvbr6(ord(CST_CODE_SETTYPE));
 emitvbr6(avalue);
end;
{
procedure tllvmbcwriter.emitdataconst(const avalue; const asize: int32);
var
 po1: pcard8;
 i1: int32;
 ar1: integerarty;
begin
 setlength(ar1,asize);
 po1:= @avalue;
 for i1:= 0 to high(ar1) do begin
  ar1[i1]:= po1^;
  inc(po1);
 end;
 emitrec(ord(CST_CODE_AGGREGATE),ar1);
end;
}

procedure tllvmbcwriter.emitdataconst(const avalue; const asize: int32);
var
 po1,pe: pcard8;
 i1: int32;
begin
 emitcode(ord(mabconst_data)); 
 emitvbr6(ord(CST_CODE_AGGREGATE));
 emitvbr6(asize);
 po1:= @avalue;
 pe:= po1+asize;
 while po1 < pe do begin
  emitvbr8(po1^+fconststart);  //todo: better encoding
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitpointercastconst(const avalue: int32;
                                                       const atype: int32);
begin
 emitrec(ord(CST_CODE_CE_CAST),[ord(CAST_BITCAST),atype,avalue]);
end;

procedure tllvmbcwriter.emitsub(const atype: int32;
               const acallingconv: callingconvty;
               const aflags: subflagsty; const alinkage: linkagety;
               const aparamattr: int32; const apersonality: int32);
begin
{
 emitrec(ord(MODULE_CODE_FUNCTION),[atype*typeindexstep+1,
                                        ord(acallingconv),0,ord(alinkage),
 aparamattr,0,0,0]);
}
 emitcode(ord(mabmod_sub));
 emitvbr6(ptypeindex(atype));
 emitvbr6(ord(acallingconv));
 if sf_proto in aflags then begin
  emit1(1);
 end
 else begin
  emit1(0);
 end;
 emitvbr6(ord(alinkage));
 emitvbr6(aparamattr);
 if sf_proto in aflags then begin
  emitvbr6(0); //personality
 end
 else begin
  emitvbr6(apersonality); //personality
 end;
// result:= fsubopstart;
// inc(fsubopstart);
end;

procedure tllvmbcwriter.emitsubdbg(const avalue: int32);
begin
 emitrec(ord(metadata_attachment),[ord(md_dbg),avalue]);
end;

//{$define explicitvartype}

const
{$ifdef explicitvartype}
 explicitvartype = 2;
{$else}
 explicitvartype = 0;
{$endif}

procedure tllvmbcwriter.emitvar(const atype: int32; const alinkage: linkagety);
begin           //no init -> external
 emitrec(ord(MODULE_CODE_GLOBALVAR),[
 {$ifdef explicitvartype}typeindex{$else}ptypeindex{$endif}(atype),
                                    explicitvartype,0,ord(alinkage),0,0]);
end;

procedure tllvmbcwriter.emitvar(const atype: int32; const ainitconst: int32;
                                                    const alinkage: linkagety);
begin
 emitrec(ord(MODULE_CODE_GLOBALVAR),[
 {$ifdef explicitvartype}typeindex{$else}ptypeindex{$endif}(atype),
             explicitvartype,ainitconst+1+fconststart,ord(alinkage),0,0]);
end;

procedure tllvmbcwriter.emitconst(const atype: int32; const ainitconst: int32);
begin
 emitrec(ord(MODULE_CODE_GLOBALVAR),[
 {$ifdef explicitvartype}typeindex{$else}ptypeindex{$endif}(atype),
          1 or explicitvartype,ainitconst+1+fconststart,ord(li_internal),0,0]);
end;

procedure tllvmbcwriter.emitalloca(const atype: int32);
begin                       
 emitrec(ord(FUNC_CODE_INST_ALLOCA),[atype,typeval(das_8),constval(1),0]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitchar6(const avalue: pchar; const alength: integer);
var
 po1,pe: pchar;
begin
 emitvbr6(alength);
 po1:= avalue;
 pe:= po1 + alength;
 while po1 < pe do begin
 {$ifdef mse_checkinternalerror}
  if char6tab[po1^] = $ff then begin
   internalerror(ie_bcwriter,'20141230A');
  end;
 {$endif}
  emit6(char6tab[po1^]);
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitchar6(const avalue: array of lstringty);
var
 po1,pe: pchar;
 i1: int32;
 po2,pe2: plstringty;
begin
 i1:= 0;
 po2:= @avalue[0];
 pe2:= po2 + length(avalue);
 while po2 < pe2 do begin
  i1:= i1 + po2^.len;
  inc(po2);
 end;
 emitvbr6(i1);
 po2:= @avalue[0];
 while po2 < pe2 do begin
  po1:= po2^.po;
  pe:= po1 + po2^.len;
  while po1 < pe do begin
  {$ifdef mse_checkinternalerror}
   if char6tab[po1^] = $ff then begin
    internalerror(ie_bcwriter,'20141230A');
   end;
  {$endif}
   emit6(char6tab[po1^]);
   inc(po1);
  end;
  inc(po2);
 end;
end;

procedure tllvmbcwriter.emitvstentry(const aid: integer; 
                                               const aname: lstringty);
begin
 emitcode(ord(mabsym_entry));
 emitvbr6(aid);
 emitchar6(aname.po,aname.len);
end;

procedure tllvmbcwriter.emitvstentry(const aid: integer; 
                                             const anames: array of lstringty);
begin
 emitcode(ord(mabsym_entry));
 emitvbr6(aid);
 emitchar6(anames);
end;

procedure tllvmbcwriter.emitvstbbentry(const aid: integer; 
                                               const aname: lstringty);
begin
 emitcode(ord(mabsym_bbentry));
 emitvbr6(aid);
 emitchar6(aname.po,aname.len);
end;

procedure tllvmbcwriter.emitphiop(const atyp: int32; const alist: pphilistty);
var
 po1,pe: pphilistitemty;
begin
 emitrec(ord(FUNC_CODE_INST_PHI),[atyp],alist^.count*2);
 po1:= @alist^.items;
 pe:= po1 + alist^.count;
 while po1 < pe do begin
  emitvbr6(signedvbr(fsubopindex-ssaval(po1^.ssa)));
  emitvbr6(po1^.bbindex);
  inc(po1);
 end;
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitbrop(const acond: int32; const bb1: int32; 
                                                         const bb0: int32);
begin
 emitrec(ord(FUNC_CODE_INST_BR),[bb1,bb0,fsubopindex-acond]);
 checkdebugloc();
end;
                              
procedure tllvmbcwriter.emitbrop(const bb: int32);
begin
 emitrec(ord(FUNC_CODE_INST_BR),[bb]);
 checkdebugloc();
 inc(fcurrentbb);
end;
                              
procedure tllvmbcwriter.emitretop();
begin
 emitcode(ord(mabfunc_inst0));
 emit6(ord(FUNC_CODE_INST_RET));
 checkdebugloc();
 inc(fsubopindex);
 inc(fcurrentbb);
end;

procedure tllvmbcwriter.emitretop(const avalue: int32);
begin
 emitrec(ord(FUNC_CODE_INST_RET),[fsubopindex-avalue]);
 checkdebugloc();
 inc(fsubopindex);
 inc(fcurrentbb);
end;

procedure tllvmbcwriter.emitresumeop(const avalue: int32);
begin
 emitrec(ord(FUNC_CODE_INST_RESUME),[fsubopindex-avalue]);
 checkdebugloc();
end;

procedure tllvmbcwriter.emitptroffset(const avalue: int32;
                                                   const aoffset: int32);
begin
 emitrec(ord(FUNC_CODE_INST_GEP),[0,typeval(das_8),
                                  fsubopindex-avalue,fsubopindex-aoffset]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitgetelementad(const avalue: int32;
                              const atype: int32; const aindex: int32);
begin
 emitrec(ord(FUNC_CODE_INST_GEP),[0,atype,
                                  fsubopindex-avalue,fsubopindex-aindex]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitgetelementptr(const avalue: int32;
                                                   const aoffset: int32);
begin
 emitrec(ord(FUNC_CODE_INST_CAST),[fsubopindex-avalue,typeval(das_pointer),
                                                   ord(CAST_BITCAST)]);
 checkdebugloc();
 inc(fsubopindex);                //no inbounds
 emitrec(ord(FUNC_CODE_INST_GEP),[0,typeval(das_8),
                                                1,fsubopindex-aoffset]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitbitcast(const asource: int32;
                                            const adesttype: int32);
begin
 emitrec(ord(FUNC_CODE_INST_CAST),[fsubopindex-asource,adesttype,
                                                   ord(CAST_BITCAST)]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitcastop(const asource: int32; const adesttype: int32;
                                               const aop: castopcodes); //1 ssa
begin
 emitrec(ord(FUNC_CODE_INST_CAST),[fsubopindex-asource,adesttype,ord(aop)]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitsegdataaddress(const aaddress: memopty);
begin
 case aaddress.segdataaddress.a.segment of
  seg_globvar,seg_op: begin
   emitgetelementptr(globval(aaddress.segdataaddress.a.address),
                                   constval(aaddress.segdataaddress.offset));
  end;
  seg_globconst: begin
   emitgetelementptr(globval(fconstseg),
                                   constval(aaddress.segdataaddress.a.address));
   emitgetelementptr(relval(0),constval(aaddress.segdataaddress.offset));
  end;
  seg_classdef: begin
   emitgetelementptr(globval(
       pint32(fclassdefs+aaddress.segdataaddress.a.address)^),
                                      constval(aaddress.segdataaddress.offset)); 
                                                           //2ssa
//   notimplementederror('20150327A');
  end;
  seg_nil: begin
   emitpushconst(nullconst);
  end;
  else begin
   internalerror1(ie_llvm,'20150310A');
  end;
 end;
end;

procedure tllvmbcwriter.emitsegdataaddresspo(const aaddress: memopty);
begin
 emitgetelementptr(globval(aaddress.segdataaddress.a.address),
                                   constval(aaddress.segdataaddress.offset));
 emitbitcast(relval(0),ptypeval(aaddress.t.listindex));
// emitrec(ord(FUNC_CODE_INST_CAST),[1,ptypeval(aaddress.t.listindex),
//                                                   ord(CAST_BITCAST)]);
// checkdebugloc();
// inc(fsubopindex);
end;

procedure tllvmbcwriter.emitlocdataaddress(const aaddress: memopty);
begin
 emitgetelementptr(allocval(aaddress.locdataaddress.a.address),
                                   constval(aaddress.locdataaddress.offset));
end;

procedure tllvmbcwriter.emitlocdataaddresspo(const aaddress: memopty);
begin
 emitgetelementptr(allocval(aaddress.locdataaddress.a.address),
                                   constval(aaddress.locdataaddress.offset));
 emitbitcast(relval(0),ptypeval(aaddress.t.listindex));
 
// emitrec(ord(FUNC_CODE_INST_CAST),[1,ptypeval(aaddress.t.listindex),
//                                                   ord(CAST_BITCAST)]);
// checkdebugloc();
// inc(fsubopindex);
end;

procedure tllvmbcwriter.emitloadop(const asource: int32);
begin
 emitrec(ord(FUNC_CODE_INST_LOAD),[fsubopindex-asource,0,0]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitstoreop(const asource: int32; const adest: int32);
begin
 emitrec(ord(FUNC_CODE_INST_STORE),[fsubopindex-adest,fsubopindex-asource,0,0]);
 checkdebugloc();
end;

procedure tllvmbcwriter.emitbinop(const aop: BinaryOpcodes;
               const valueida: int32; const valueidb: int32);
begin
 emitrec(ord(FUNC_CODE_INST_BINOP),[fsubopindex-valueida,fsubopindex-valueidb,
                                                                     ord(aop)]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitcmpop(const apred: Predicate;
                               const valueida: int32; const valueidb: int32);
begin
 emitrec(ord(FUNC_CODE_INST_CMP),[fsubopindex-valueida,fsubopindex-valueidb,
                                                                   ord(apred)]);
 checkdebugloc();
 inc(fsubopindex);
end;

function tllvmbcwriter.typeval(const typeid: databitsizety): int32;
begin
 result:= typeval(ord(typeid));
end;

function tllvmbcwriter.ptypeval(const typeid: databitsizety): int32;
begin
 result:= ptypeval(ord(typeid));
end;

function tllvmbcwriter.pptypeval(const typeid: databitsizety): int32;
begin
 result:= pptypeval(ord(typeid));
end;

function tllvmbcwriter.typeval(const typeid: int32): int32;
begin
 result:= typeindex(typeid);
end;

function tllvmbcwriter.ptypeval(const typeid: int32): int32;
begin
 result:= ptypeindex(typeid);
end;

function tllvmbcwriter.pptypeval(const typeid: int32): int32;
begin
 result:= pptypeindex(typeid);
end;

function tllvmbcwriter.typeval(const alloc: typeallocinfoty): int32;
begin
 with alloc do begin
//  if listindex < 0 then begin
//   result:= typeval(kind);
//  end
//  else begin
  result:= typeval(listindex);
//  end;
 end;
end;

function tllvmbcwriter.ptypeval(const alloc: typeallocinfoty): int32;
begin
 result:= typeval(alloc) + 1;
end;

function tllvmbcwriter.constval(const constid: int32): int32;
begin
 result:= constid + fconststart;
// result:= fsubopindex - ({fconstopstart +} constid);
end;

function tllvmbcwriter.globval(const globid: int32): int32;
begin
 result:= globid{ + fglobstart};
end;

function tllvmbcwriter.relval(const offset: int32): int32;
begin
 result:= fsubopindex - offset - 1;
end;

function tllvmbcwriter.paramval(const paramid: int32): int32;
begin
 result:= paramid + fsubparamstart;
end;

function tllvmbcwriter.allocval(const allocid: int32): int32;
begin
 result:= allocid + fsuballocstart;
end;

function tllvmbcwriter.tempval(const tempid: int32): int32;
begin
 result:= tempid + fsubtempstart;
end;

function tllvmbcwriter.subval(const offset: int32): int32;
begin
 result:= offset + fsubstart;
end;

function tllvmbcwriter.ssaval(const ssaid: int32): int32;
begin
 result:= ssaid + fsubopstart;
end;

{
function tllvmbcwriter.subval(const subid: int32): int32;
begin
 result:= subid + fsubopstart;
end;
}
procedure tllvmbcwriter.beginsub(const aflags: subflagsty;
                   const allocs: suballocinfoty; const bbcount: int32);
begin
 fcurrentbb:= 0;
 flandingpadblock:= 0;
 flastdebugloc.line:= -1;
 flastdebugloc.col:= 0;
 with allocs do begin
  fsubparamstart:= fsubstart;
  if sf_function in aflags then begin
   dec(fsubparamstart); //skip result param
  end;
  if sf_hasnestedaccess in aflags then begin
   inc(fsubparamstart); //skip nested var array pointer
  end;
  fsuballocstart:= fsubparamstart+paramcount;
  fsubtempstart:= fsuballocstart+alloccount+2; //managedtemp
  fsubopstart:= fsubtempstart+llvm.tempcount-2;//managedtemp
 {
  if nestedalloccount > 0 then begin
   inc(fsubopstart,2); //nested var array alloc + byte pointer
  end;
 }
  fsubopindex:= fsuballocstart; //pending allocs done in llvmops.subbeginop()
 end;
 beginblock(FUNCTION_BLOCK_ID,3);
 emitrec(ord(FUNC_CODE_DECLAREBLOCKS),[bbcount]);
end;

procedure tllvmbcwriter.resetssa();
begin
 fsubopstart:= fsubopindex;
end;

procedure tllvmbcwriter.endsub();
begin
 endblock();
end;

procedure tllvmbcwriter.emitcallop(const afunc: boolean;
                           const valueid: int32; const aparams: idarty);
var
 i1: int32;
begin
 for i1:= aparams.count-1 downto 0 do begin
  aparams.ids[i1]:= fsubopindex-aparams.ids[i1];
 end;
 if flandingpadblock = 0 then begin
  emitrec(ord(FUNC_CODE_INST_CALL),[0,0,fsubopindex-valueid],aparams);
 end
 else begin
  inc(fcurrentbb);
  emitrec(ord(FUNC_CODE_INST_INVOKE),
          [0,0,fcurrentbb,flandingpadblock,fsubopindex-valueid],aparams);
 end;
 checkdebugloc();
 if afunc then begin
  inc(fsubopindex);
 end;
end;

procedure tllvmbcwriter.emitcallop(const afunc: boolean; 
                          const valueid: int32; aparams: array of int32);
var
 i1: int32;
begin
 for i1:= high(aparams) downto 0 do begin
  aparams[i1]:= fsubopindex-aparams[i1];
 end;
 if flandingpadblock = 0 then begin
  emitrec(ord(FUNC_CODE_INST_CALL),[0,0,fsubopindex-valueid],aparams);
 end
 else begin
  inc(fcurrentbb);
  emitrec(ord(FUNC_CODE_INST_INVOKE),
            [0,0,fcurrentbb,flandingpadblock,fsubopindex-valueid],aparams);
 end;
 checkdebugloc();
 if afunc then begin
  inc(fsubopindex);
 end;
end;

function tllvmbcwriter.valindex(const aadress: segaddressty): integer;
begin
 result:= aadress.address;
 if aadress.segment in [seg_globconst,seg_classdef] then begin
  result:= result + fconststart;
 end;
 {
 if aadress.segment = seg_globvar then begin
  result:= result + fglobstart;
 end;
 }
end;

procedure tllvmbcwriter.emitpushconst(const aconst: llvmvaluety);
begin
 emitrec(ord(FUNC_CODE_INST_CAST),
       [fsubopindex-constval(aconst.listid),typeval(aconst.typeid),
                                                          ord(CAST_BITCAST)]);
 checkdebugloc();
 inc(fsubopindex);
// emitbinop(BINOP_ADD,constval(aconstid),constval(ord(nc_i1)));
end;

procedure tllvmbcwriter.emitpushconstsegad(const aoffset: int32); //2ssa
begin
 emitgetelementptr(globval(constseg),aoffset);
end;

procedure tllvmbcwriter.emitdebugloc(const avalue: debuglocty);
begin
 emitrec(ord(FUNC_CODE_DEBUG_LOC),
      [avalue.line+1,avalue.col+1,avalue.scope+1,0]);
end;

procedure tllvmbcwriter.emitdebuglocagain;
begin
 emitrec(ord(FUNC_CODE_DEBUG_LOC_AGAIN),[]);
end;

procedure tllvmbcwriter.checkdebugloc();
begin
 if not fnodebugloc then begin
  if (fdebugloc.line <> flastdebugloc.line) or 
               (fdebugloc.col <> flastdebugloc.col) or 
                           (fdebugloc.scope <> flastdebugloc.scope)then begin
   emitdebugloc(fdebugloc);
   flastdebugloc:= debugloc;
  end
  else begin
   if fdebugloc.line >= 0 then begin
    emitdebuglocagain();
   end;
  end;
 end;
end;

procedure tllvmbcwriter.marktrampoline(const apc: popinfoty);
begin
 ftrampolineop:= apc;
end;

procedure tllvmbcwriter.releasetrampoline(out apc: popinfoty);
begin
 apc:= ftrampolineop;
 ftrampolineop:= nil;
end;

procedure tllvmbcwriter.emitmetadatakind(const aid: int32; 
                                      const len: int32; const name: pchar);
var
 p1,pe: pcard8;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(ord(METADATA_KIND));
 emitvbr6(len+1);
 emitvbr6(aid);
 p1:= pointer(name);
 pe:= p1+len;
 while p1 < pe do begin
  emitvbr6(p1^);
  inc(p1);
 end;
end;

procedure tllvmbcwriter.emitmetavalue(const atyp: int32;
               const avalue: int32);
begin
 emitrec(ord(METADATA_VALUE),[atyp,avalue]);
end;

procedure tllvmbcwriter.emitmetafile(const afile,adirectory: int32);
begin
 emitrec(ord(METADATA_FILE),[0,afile+1,adirectory+1]);
                             //no distinct
end;

procedure tllvmbcwriter.emitmetacompileunit(const avalue: dicompileunitty);
begin
 with avalue do begin
  emitrec(ord(METADATA_COMPILE_UNIT),[0, //distinct
   sourcelanguage,                       //sourcelanguage,
   difile.id+1,                          //file,
   producer.id+1,                        //producer,
   0,                                    //isoptimized,
   0,                                    //flags
   0,                                    //runtimeversion
   0,                                    //splitdebugfilename
   ord(emissionkind),                    //emissionkind,
   0,                                    //enumtypes,
   0,                                    //retainedtypes,
   metaornull(subprograms),              //subprograms,
   metaornull(globalvariables),          //globalvariables
   0                                     //importedentities
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetabasictype(const avalue: dibasictypety);
begin
 with avalue do begin
  emitrec(ord(METADATA_BASIC_TYPE),[0, //distinct
   DW_TAG_base_type,                   //tag
   name.id+1,                          //name
   sizeinbits,                         //sizenbits
   aligninbits,                        //aligninbits
   encoding                            //encoding
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetasubrange(const avalue: disubrangety);
begin
 with avalue do begin
  emitrec(ord(METADATA_SUBRANGE),[0,   //distinct
   range.max-range.min+1,              //count
   signedvbr(range.min)                //lowerbound
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetadataenumerator(const avalue: dienumeratorty);
begin
 with avalue do begin
  emitrec(ord(METADATA_ENUMERATOR),[0, //distinct
   signedvbr(value),                   //value
   name.id+1                           //name
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetaderivedtype(const avalue: diderivedtypety);
const
 derivedtags: array[diderivedtypekindty] of int32 = (
   DW_TAG_pointer_type,DW_TAG_reference_type,DW_TAG_member);
begin
 with avalue do begin
  emitrec(ord(METADATA_DERIVED_TYPE),[0, //distinct
   derivedtags[kind],                    //tag
   name.id+1,                            //name
   _file.id+1,                           //file
   line,                                 //line
   scope.id+1,                           //scope
   basetype.id+1,                        //basetype
   sizeinbits,                           //sizeinbits
   aligninbits,                          //aligninbits
   offsetinbits,                         //offsetinbits
   flags,                                //flags
   0                                     //extradata
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetacompositetype(const avalue: dicompositetypety);
const
 compositetags: array[dicompositetypekindty] of int32 = (
             DW_TAG_structure_type,DW_TAG_array_type,DW_TAG_enumeration_type);
begin
 with avalue do begin
  emitrec(ord(METADATA_COMPOSITE_TYPE),[0, //distinct
   compositetags[kind],                  //tag
   name.id+1,                            //name
   _file.id+1,                           //file
   line,                                 //line
   scope.id+1,                           //scope
   basetype.id+1,                        //basetype
   sizeinbits,                           //sizeinbits
   aligninbits,                          //aligninbits
   offsetinbits,                         //offsetinbits
   flags,                                //flags
   elements.id+1,                        //elements
   info.s.unitinfo^.dwarflangid,         //runtimelang
   0,                                    //vtableholder
   0,                                    //templateparams
   0                                     //identifier
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetarefstringtype(const avalue: direfstringtypety);
begin
 with avalue do begin
  notimplementederror('20160109A');
 end;
end;

procedure tllvmbcwriter.emitmetasubroutinetype(
              const avalue: disubroutinetypety);
begin
 with avalue do begin
  emitrec(ord(METADATA_SUBROUTINE_TYPE),[0, //distinct
   0,                                       //flags
   params.id+1                              //typearray  
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetasubprogram(const avalue: disubprogramty);
begin
 with avalue do begin
  emitrec(ord(METADATA_SUBPROGRAM),[1, //distinct
   scope.id+1,               //scope
   name.id+1,                //name
   0,                        //linkagename
   _file.id+1,               //file
   line,                     //line
   _type.id+1,               //type
   ord(localtounit),         //islocaltounit
   1,                        //isdefinition
   line,                     //scopeline
   0,                        //containingtype
   0,                        //virtuality
   1,                        //virtualindex
   int32(flags),             //flags
   0,                        //isoptimized
   _function.id+1,           //function
   0,                        //templateparams
   0,                        //declaration
   variables.id+1            //variables
  ]);
 end;
end;

procedure tllvmbcwriter.emitmetalocalvar(const avalue: dilocvariablety);
const
 vartags: array[dilocvariablekindty] of int32 = 
                                    (DW_TAG_auto_variable,DW_TAG_arg_variable);
begin
 with avalue do begin
  emitrec(ord(METADATA_LOCAL_VAR),[0, //distinct
   vartags[kind],         //tag
   scope.id+1,            //scope
   name.id+1,             //name
   _file.id+1,           //file
   linenumber,            //line
   _type.id+1,            //type
   arg,                   //arg
   flags]);               //flags
 end;
end;

procedure tllvmbcwriter.emitmetaexpression(const avalue: diexpressionty);
var
 idar1: array[0..high(expitemarty)] of int32;
 i1: int32;
begin
 with avalue do begin
  for i1:= 0 to count-1 do begin
   idar1[i1]:= items[i1];
  end;
  emitrec(ord(METADATA_EXPRESSION),[0],count,@idar1[0]); //distinct
 end;
end;

procedure tllvmbcwriter.emitmetaglobalvar(const avalue: diglobvariablety);
begin
 with avalue do begin
  emitrec(ord(METADATA_GLOBAL_VAR),[0, //distinct
   scope.id+1,                         //scope
   name.id+1,                          //name
   0,                                  //linkagename
   _file.id+1,                         //file
   line,                               //line
   _type.id+1,                         //type
   ord(islocaltounit),                 //islocaltounit
   1,                                  //isdefinition
   variable.id+1,                      //variable
   0                                   //staticdatamemberdeclaration
  ]);
 end;
end;

procedure tllvmbcwriter.emitlandingpad(const aresulttype: int32;
                                                   const apersonality: int32);
begin                        //todo: use FUNC_CODE_INST_LANDINGPAD,
                             //set personality in function definitions
// emitrec(ord(FUNC_CODE_INST_LANDINGPAD_OLD),
//                                   [aresulttype,fsubopindex-apersonality,1,0]);
 emitrec(ord(FUNC_CODE_INST_LANDINGPAD),
                                   [aresulttype,1,0]);
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitgenericdebug(const tag: int32; const len: int32;
               const values: pmetavaluety);
var
 po1,pe: pmetavaluety;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(ord(METADATA_GENERIC_DEBUG));
 emitvbr6(len+4);
 emitvbr6(0); //distinct
 emitvbr6(tag);
 emitvbr6(0); //version
 emitvbr6(0); //string?
 po1:= values;
 pe:= po1+len;
 while po1 < pe do begin
  with po1^ do begin
   emitvbr6(id+1);
  end;
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitmetanode(const len: int32; 
                                              const values: pmetavaluety);
var
 po1,pe: pmetavaluety;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(ord(METADATA_NODE));
 emitvbr6(len);
 po1:= values;
 pe:= po1+len;
 while po1 < pe do begin
  with po1^ do begin
   emitvbr6(id+1);
  end;
  inc(po1);
 end;
end;

procedure tllvmbcwriter.emitmetanode(const values: array of metavaluety);
begin
 emitmetanode(length(values),@values[0]);
end;

procedure tllvmbcwriter.emitnamedmetanode(
          const namelen: int32; const name: pcard8;
                                 const len: int32; const values: pint32);
begin
 emitrec(ord(METADATA_NAME),namelen,name);
 emitrec(ord(METADATA_NAMED_NODE),len,pint32(values));
end;

end.
