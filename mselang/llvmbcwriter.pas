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
unit llvmbcwriter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream,msetypes,llvmbitcodes,parserglob,elements,msestrings,llvmlists,
 opglob;
 
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
   ftrampolineop: popinfoty;
  protected
   fconstseg: int32;
   flastdebugloc: debuglocty;
   fconststart: int32;      //start of global constants
   fsubstart: int32;        //start of sub values (params)
   fsubparamstart: int32;   //reference for param access
   fsuballocstart: int32;   //reference for allocs
   fsubopstart: int32;      //start of op ssa id's
   fsubopindex: int32;      //current op ssa is
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
   procedure emitvbr8(avalue: int32);
   procedure emitcode(const avalue: int32);
   procedure emitdata(const avalue: bcdataty);
   procedure emitdata(const avalues: array of pbcdataty);
//   procedure emitchar6(const avalue: shortstring);
   procedure emitchar6(const avalue: pchar; const alength: integer);
//   procedure emitint32rec(const id: int32; const value: int32);
   procedure pad32();
   procedure emittypeid(const avalue: int32);
   procedure emitintconst(const avalue: int32);
   procedure emitdataconst(const avalue; const asize: int32);
   procedure emitpointercastconst(const avalue: int32; const atype: int32);
   procedure checkdebugloc();
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure start(const consts: tconsthashdatalist; 
                                     const globals: tgloballocdatalist);
   procedure stop();
   procedure flushbuffer(); override;
   function bitpos(): int32;

   function typeval(const typeid: databitsizety): integer; inline;
   function ptypeval(const typeid: databitsizety): integer; inline;
   function pptypeval(const typeid: databitsizety): integer; inline;
   function typeval(const typeid: int32): int32; inline;
   function ptypeval(const typeid: int32): int32; inline;
   function pptypeval(const typeid: int32): int32; inline;
   function typeval(const alloc: typeallocinfoty): int32; 
   function ptypeval(const alloc: typeallocinfoty): int32;
   function constval(const constid: int32): int32; inline;
   function globval(const globid: int32): int32; inline;
   function paramval(const paramid: int32): int32; inline;
   function allocval(const allocid: int32): int32; inline;
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
                                                const adddata: array of int32);
   procedure emitnopssaop(); //1 ssa
   
   procedure emitsub(const atype: int32; const acallingconv: callingconvty;
               const aflags: subflagsty;
               const alinkage: linkagety; const aparamattr: int32{;
               const aalignment: int32; const asection: int32;
               const avisibility: visibility; const agc: int32;
               const unnamed_addr: int32;
               const aprologdata: int32;
               const adllstorageclass: dllstorageclassty; const acomdat: int32;
               const aprefixdata: int32});
   procedure emitvar(const atype: int32);
   procedure emitvar(const atype: int32; const ainitconst: int32);
   procedure emitconst(const atype: int32; const ainitconst: int32);
   procedure emitalloca(const atype: int32); //1 ssa
   procedure resetssa(); //sets ssastart to current ssa
   
   procedure beginsub(const aflags: subflagsty; const allocs: suballocinfoty;
                                                         const bbcount: int32);
   procedure endsub();
   
   procedure emitcallop(const afunc: boolean; const valueid: int32;
                                                      const aparams: idarty);
                                          //changes aparams
   procedure emitcallop(const afunc: boolean; const valueid: int32;
                                              aparams: array of int32);
   
   procedure emitvstentry(const aid: integer; const aname: lstringty);
   procedure emitvstbbentry(const aid: integer; const aname: lstringty);

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
   procedure emitgetelementptr(const avalue: int32; const aoffset: int32);
                                         //aoffset = byteoffset, 2 ssa
   procedure emitbitcast(const asource: int32; const adesttype: int32); //1 ssa
   procedure emitcastop(const asource: int32; const adesttype: int32;
                                               const aop: castopcodes); //1 ssa
                                 
   procedure emitloadop(const asource: int32);
   procedure emitstoreop(const asource: int32; const adest: int32);

   procedure emitpushconst(const aconst: llvmconstty);
   procedure emitpushconstsegad(const aoffset: int32); //2ssa
   
   procedure emitbinop(const aop: BinaryOpcodes; 
                         const valueida: int32; const valueidb: int32);
   procedure emitcmpop(const apred: Predicate; const valueida: int32;
                                                      const valueidb: int32);
   procedure emitdebugloc(const avalue: debuglocty);
   procedure emitdebuglocagain();

   procedure marktrampoline(const apc: popinfoty);
   procedure releasetrampoline(out apc: popinfoty); //nil if none
      
   function valindex(const aadress: segaddressty): integer;
   property constseg: int32 read fconstseg write fconstseg;
   property ssaindex: int32 read fsubopindex;
   property debugloc: debuglocty read fdebugloc write fdebugloc;
 end;
 
implementation
uses
 errorhandler,msesys,sysutils,msebits;

 //abreviations, made by createabbrev tool
 
type
 mabmodty = (
  mabmod_sub = 4 //MODULE_CODE_FUNCTION (literal 8), type (vbr 6), callingconv (vbr 6), isproto (fixed 1), linkagetype (vbr 6), paramattr (vbr 6), alignment (literal 0), section (literal 0), visibility (literal 0), gc (literal 0), unnamed_addr (literal 0), prologdata (literal 0), dllstorageclass (literal 0), comdat (literal 0), prefixdata (literal 0)
 );
const
 mabmodsdat: array[0..17] of card8 = (122,17,200,144,145,64,134,76,128,0,1,2,4,8,16,32,64,0);
 mabmods: bcdataty = (bitsize: 143; data: @mabmodsdat);

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
 typeindexstep = 3;   //type list stack =   basetype [0]
                      //                   *basetype [1]
                      //                  **basetype [2]

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
                                 const globals: tgloballocdatalist);
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
 po1: ptypelistdataty;
 po2: pconstlistdataty;
 po3,po4: pparamitemty;
 po5,po6: pgloballocdataty;
 po7,po8: pglobnamedataty;
 pa,pe: pint32;
 i1,i2: int32;
 po9: paggregateconstty;
begin
 ftrampolineop:= nil;
 fdebugloc.line:= -1;
 fdebugloc.col:= 0;
 flastdebugloc.line:= -1;
 flastdebugloc.col:= 0;
 write32(int32((uint32($dec0) shl 16) or (uint32(byte('C')) shl 8) or
                                                             uint32('B')));
                                //llvm ir signature

 beginblock(BLOCKINFO_BLOCK_ID,3); //abbreviations
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(CONSTANTS_BLOCK_ID)]);
 emitdata(mabconsts);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(TYPE_BLOCK_ID_NEW)]);
 emitdata(mabtypes);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(MODULE_BLOCK_ID)]);
 emitdata(mabmods);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(VALUE_SYMTAB_BLOCK_ID)]);
 emitdata(mabsyms);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(FUNCTION_BLOCK_ID)]);
 emitdata(mabfuncs);
 endblock();

 beginblock(MODULE_BLOCK_ID,3);
 emitrec(ord(MODULE_CODE_VERSION),[1]);

 fconststart:= globals.count;
 fsubstart:= globals.count+consts.count;
 
 if consts.typelist.count > 0 then begin
  beginblock(TYPE_BLOCK_ID_NEW,3);
  emitrec(ord(TYPE_CODE_NUMENTRY),[consts.typelist.count*typeindexstep]);
  po1:= consts.typelist.first();
  for i1:= consts.typelist.count - 1 downto 0 do begin
   if ord(po1^.kind) < 0 then begin
    case aggregatekindty(-ord(po1^.kind)) of
     ak_pointerarray: begin
      emitrec(ord(TYPE_CODE_ARRAY),[po1^.header.buffer,typeval(pointertype)]);
     end;
     ak_aggregatearray: begin
      with paggregatearraytypedataty(
                       typelist.absdata(po1^.header.buffer))^ do begin
       emitrec(ord(TYPE_CODE_ARRAY),[size,typeval(typ)]);
      end;
     end;
     ak_struct: begin
      i2:= po1^.header.buffersize div sizeof(int32);
      emitrec(ord(TYPE_CODE_STRUCT_ANON),[0],i2);
      pa:= typelist.absdata(po1^.header.buffer);
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
    if po1^.kind in ordinalopdatakinds then begin
     if po1^.kind = das_pointer then begin
      emitrec(ord(TYPE_CODE_POINTER),[typeindex(das_8)]);
     end
     else begin
      emitrec(ord(TYPE_CODE_INTEGER),[po1^.header.buffer]);
     end;
    end
    else begin
     if po1^.kind in byteopdatakinds then begin
      if po1^.header.buffer = 0 then begin
       emitrec(ord(TYPE_CODE_VOID),[]);     
       emitrec(ord(TYPE_CODE_VOID),[]); //dummy *type
       emitrec(ord(TYPE_CODE_VOID),[]); //dummy **type
       po1:= consts.typelist.next();
       continue;
      end
      else begin
       emitrec(ord(TYPE_CODE_ARRAY),[po1^.header.buffer,typeindex(das_8)]);     
      end;
     end
     else begin
      case po1^.kind of
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
                consts.typelist.absdata(po1^.header.buffer))^ do begin
                      //todo: vararg
 //        emitrec(ord(TYPE_CODE_FUNCTION),[0,0,ord(das_none)]);
 
         emitcode(ord(mabtype_subtype));
         i2:= header.paramcount;
         po3:= @params;
         if sf_vararg in header.flags then begin
          emit1(1);      //vararg
         end
         else begin
          emit1(0);      //no vararg
         end;
         if sf_function in header.flags then begin
          emitvbr6(typeindex(po3^.typelistindex)); //retval
          dec(i2);
          inc(po3);
         end
         else begin
          emitvbr6(typeindex(das_none)); //void retval
         end;
         emitvbr6(i2); //param count
         po4:= po3+i2;
         while po3 < po4 do begin
          emitvbr6(typeindex(po3^.typelistindex));
          inc(po3);
         end;
 //        emitrec(ord(TYPE_CODE_FUNCTION),[0,0,
                         //vararg,ignored,
 
        end;
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
   emitrec(ord(TYPE_CODE_POINTER),[po1^.header.listindex*typeindexstep]);
   emitrec(ord(TYPE_CODE_POINTER),[po1^.header.listindex*typeindexstep+1]);
   po1:= consts.typelist.next();
  end;
  endblock(); 

  po5:= globals.datapo;
  po6:= po5 + globals.count;
  while po5 < po6 do begin
   case po5^.kind of
    gak_sub: begin
     emitsub(po5^.typeindex,cv_ccc,po5^.flags,po5^.linkage,0);
    end;
    gak_const: begin
     emitconst(po5^.typeindex,po5^.initconstindex);
    end;
    gak_var: begin
     if po5^.initconstindex >= 0 then begin
      emitvar(po5^.typeindex,po5^.initconstindex);
     end
     else begin
      emitvar(po5^.typeindex);
     end;
    end;
   end;
   inc(po5);
  end;
  if globals.namelist.count > 0 then begin
   beginblock(VALUE_SYMTAB_BLOCK_ID,3);
   po7:= globals.namelist.datapo;
   po8:= po7 + globals.namelist.count;
   while po7 < po8 do begin
    emitvstentry({fglobstart+}po7^.listindex,po7^.name);
    inc(po7);
   end;
   endblock();
  end;

  if consts.count > 0 then begin
   beginblock(CONSTANTS_BLOCK_ID,3);
   id1:= -1;
   po2:= consts.first;
   for i1:= 0 to consts.count-1 do begin
    if po2^.typeid < 0 then begin
     case consttypety(-po2^.typeid) of
      ct_null: begin       
       checkconsttypeid(int32(po2^.header.buffer));
       emitrec(ord(CST_CODE_NULL),[]);
      end;
      ct_pointercast: begin
       checkconsttypeid(pointertype);
       emitpointercastconst(globval(po2^.header.buffer),
                               ptypeval(globlist.gettype(po2^.header.buffer)));
      end;
      ct_pointerarray,ct_aggregatearray: begin
       pa:= constlist.absdata(po2^.header.buffer);
       i2:= po2^.header.buffersize div sizeof(int32) - 1;
       checkconsttypeid(pa[i2]); //last item is type
       emitrec(ord(CST_CODE_AGGREGATE),[],i2); //ids
       pe:= pa+i2;
       while pa < pe do begin
        emitvbr6(constval(pa^));
        inc(pa);
       end;
      end;
      ct_aggregate: begin
       po9:= constlist.absdata(po2^.header.buffer);
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
      {
      ct_intfitem: begin
       checkconsttypeid(consts.typelist.intfitem);
       with pintfitemconstty(constlist.absdata(po2^.header.buffer))^ do begin
        emitrec(ord(CST_CODE_AGGREGATE),[instanceshiftid+fconststart,
                                                        subid+fconststart]);
       end;
      end;
      }
      else begin
       internalerror1(ie_bcwriter,'20150328A');
      end;
     end;
    end
    else begin
     checkconsttypeid(po2^.typeid);
     case databitsizety(po2^.typeid) of
      das_1..das_32: begin //todo: das_64
       emitintconst(int32(po2^.header.buffer));
      end;
      else begin
      {$ifdef mse_checkinternalerror}
       if databitsizety(po2^.typeid) <= lastdatakind then begin
        internalerror(ie_bcwriter,'141220A');
       end;
      {$endif}
       emitdataconst(consts.absdata(po2^.header.buffer)^,
                                                po2^.header.buffersize);
      end;
     end;
    end;
    po2:= consts.next();
   end;
   endblock(); 
  end;
 end;
end;

procedure tllvmbcwriter.stop;
begin
 endblock();
{$ifdef mse_checkinternalerror}
 if fblockstackpo <> @fblockstack then begin
  internalerror(ie_bcwriter,'141213C');
 end;
{$endif}
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

procedure tllvmbcwriter.emitnopssaop();
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
               const aparamattr: int32);
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
// result:= fsubopstart;
// inc(fsubopstart);
end;

procedure tllvmbcwriter.emitvar(const atype: int32);
begin
 emitrec(ord(MODULE_CODE_GLOBALVAR),[ptypeindex(atype),0,
                          0+fconststart{nullconst+1},ord(li_internal),0,0]);
end;

procedure tllvmbcwriter.emitvar(const atype: int32; const ainitconst: int32);
begin
 emitrec(ord(MODULE_CODE_GLOBALVAR),[ptypeindex(atype),0,
                     ainitconst+1+fconststart,ord(li_internal),0,0]);
end;

procedure tllvmbcwriter.emitconst(const atype: int32; const ainitconst: int32);
begin
 emitrec(ord(MODULE_CODE_GLOBALVAR),[ptypeindex(atype),1,
                        ainitconst+1+fconststart,ord(li_internal),0,0]);
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

procedure tllvmbcwriter.emitvstentry(const aid: integer; 
                                               const aname: lstringty);
begin
 emitcode(ord(mabsym_entry));
 emitvbr6(aid);
 emitchar6(aname.po,aname.len);
end;

procedure tllvmbcwriter.emitvstbbentry(const aid: integer; 
                                               const aname: lstringty);
begin
 emitcode(ord(mabsym_bbentry));
 emitvbr6(aid);
 emitchar6(aname.po,aname.len);
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
end;
                              
procedure tllvmbcwriter.emitretop();
begin
 emitcode(ord(mabfunc_inst0));
 emit6(ord(FUNC_CODE_INST_RET));
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitretop(const avalue: int32);
begin
 emitrec(ord(FUNC_CODE_INST_RET),[fsubopindex-avalue]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitresumeop(const avalue: int32);
begin
 emitrec(ord(FUNC_CODE_INST_RESUME),[fsubopindex-avalue]);
 checkdebugloc();
end;

procedure tllvmbcwriter.emitptroffset(const avalue: int32;
                                                   const aoffset: int32);
begin
 emitrec(ord(FUNC_CODE_INST_GEP),[fsubopindex-avalue,fsubopindex-aoffset]);
 checkdebugloc();
 inc(fsubopindex);
end;

procedure tllvmbcwriter.emitgetelementptr(const avalue: int32;
                                                   const aoffset: int32);
begin
 emitrec(ord(FUNC_CODE_INST_CAST),[fsubopindex-avalue,typeval(das_pointer),
                                                   ord(CAST_BITCAST)]);
 checkdebugloc();
 inc(fsubopindex);
 emitrec(ord(FUNC_CODE_INST_GEP),[1,fsubopindex-aoffset]);
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
   notimplementederror('20150327A');
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
  fsubopstart:= fsuballocstart+alloccount;
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

procedure tllvmbcwriter.emitcallop(const afunc: boolean; const valueid: int32;
                                                   const aparams: idarty);
var
 i1: int32;
begin
 for i1:= aparams.count-1 downto 0 do begin
  aparams.ids[i1]:= fsubopindex-aparams.ids[i1];
 end;
 emitrec(ord(FUNC_CODE_INST_CALL),[0,0,fsubopindex-valueid],aparams);
 checkdebugloc();
 if afunc then begin
  inc(fsubopindex);
 end;
end;

procedure tllvmbcwriter.emitcallop(const afunc: boolean; const valueid: int32;
                                                 aparams: array of int32);
var
 i1: int32;
begin
 for i1:= high(aparams) downto 0 do begin
  aparams[i1]:= fsubopindex-aparams[i1];
 end;
 emitrec(ord(FUNC_CODE_INST_CALL),[0,0,fsubopindex-valueid],aparams);
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

procedure tllvmbcwriter.emitpushconst(const aconst: llvmconstty);
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
 emitrec(ord(FUNC_CODE_DEBUG_LOC),[avalue.line+1,avalue.col,0,0]);
end;

procedure tllvmbcwriter.emitdebuglocagain;
begin
 emitrec(ord(FUNC_CODE_DEBUG_LOC_AGAIN),[]);
end;

procedure tllvmbcwriter.checkdebugloc();
begin
 if fdebugloc.line <> flastdebugloc.line then begin
  emitdebugloc(fdebugloc);
  flastdebugloc:= debugloc;
 end
 else begin
  if fdebugloc.line >= 0 then begin
   emitdebuglocagain();
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

end.
