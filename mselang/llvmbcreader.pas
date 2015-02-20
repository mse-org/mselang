{ MSElang Copyright (c) 2015 by Martin Schreiber
   
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
unit llvmbcreader;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream,classes,mclasses,msetypes,msestrings,mselist,llvmbitcodes;
//
//not optimized, for debug purpose only
//
const
 bcreaderbuffersize = 16; //test fillbuffer, todo: make it bigger
type
 valuety = int64;
 valuearty = array of valuety;

 abbrevkindty = (ak_literal,ak_fix,ak_var,ak_array,ak_char6,ak_blob);
 abbrevitemty = record
  case kind: abbrevkindty of
   ak_literal: (
    literal: valuety;
   );
   ak_fix,ak_var: (
    size: int32;
   );
   ak_array: (
    arraytype: int32; //index in farraytypes
   );
 end;
 abbrevty = array of abbrevitemty;
 abbrevarty = array of abbrevty;
  
 blockinfoty = record
  id: int32;
  oldidsize: int32;
  blockabbrev: abbrevarty;
  abbrevs: abbrevarty;
 end;
 blockinfoarty = array of blockinfoty;
 
 outputkindty = (ok_begin,ok_end,ok_beginend);

 typeinfoty = record
  case kind: typecodes of
   TYPE_CODE_INTEGER:(
    size: int32;
   );
   TYPE_CODE_POINTER:(
    base: int32; //index
   );
   TYPE_CODE_ARRAY:(
    arraysize: int32;
    arraytype: int32; //index
   );
   TYPE_CODE_FUNCTION:(
    subvararg: boolean;
    subparamcount: int32;
    subparamindex: int32;
   );
 end;
 ptypeinfoty = ^typeinfoty;
 
 ttypelist = class(trecordlist)
  protected
   fsubparamcount: int32;
   fsubparams: integerarty; //typeindex
  public
   constructor create();
   procedure checkvalidindex(const aindex: int32);
   function typename(const aindex: int32): string;
   function iskind(const aindex: int32; const akind: typecodes): boolean;
   function parentiskind(const aindex: int32; const akind: typecodes): boolean;
   function parenttype(const aindex: int32): ptypeinfoty;
   function parenttypeindex(const aindex: int32): int32;
   function itemtypeindex(const aindex: integer): int32;
 end;

 globkindty = (gk_const,gk_var,gk_sub);
 constkindty = (ck_integer);
 
 globinfoty = record
  valuetype: int32;
  case kind: globkindty of
   gk_const: (
    case constkind: constantscodes of
     CST_CODE_INTEGER: (
      intconst: valuety;
     );
   );
   gk_var: (
   );
   gk_sub: (
    subindex: int32;    
   );
 end;
 pglobinfoty = ^globinfoty;
 
 tgloblist = class(trecordlist)
  protected
   ftypelist: ttypelist;
   fsettype: int32;
  public
   constructor create(const typelist: ttypelist);
   procedure checkvalidindex(const aindex: int32);
   function constname(const aid: int32): string;
   function typeid(const aindex: int32): int32;
 end;

 tllvmbcreader = class(tmsefilestream)
  private
   fbuffer: array[0..bcreaderbuffersize-1] of byte;
   fbufend: pcard8;
   fbufpos: pcard8;
   fbitpos: int32;
   fbitbuf: card16;
   fidsize: int32;
   findent: int32;
   fblocklevel: int32;
   fblockstack: blockinfoarty;
   farraytypes: array of abbrevitemty;
   fblockinfoid: int32;
   fblockabbrevs: array of abbrevarty; //blockid is array index
//   fglobindex: int32;
   ftypelist: ttypelist;
   fgloblist: tgloblist;
   fsubheadercount: int32;
   fsubheaders: integerarty; //index in fgloblist
   fsubimplementationcount: int32;
  protected
   procedure checkdatalen(const arec: valuearty; const alen: integer);
   procedure checkmindatalen(const arec: valuearty; const alen: integer);

   function finished: boolean;
   function tryfillbuffer(): boolean;
   procedure fillbuffer();
   function get8(): card8;
   function getbits(const bitcount: int32): card8;
   procedure readbits(const bitcount: int32; out buffer);
   function read32(const bitcount: int32 = 32): int32;
   function readvbr(const bitsize: int32): valuety;
   procedure align32();
   procedure readabbrev(aid: int32; var values: valuearty);
   function readitem(): valuearty;
          //nil if internal read, first array item = abbrev, second = code
   procedure readblockheader(out blockid: int32; 
                               out newabbrevlen: int32; out blocklen: int32);

   procedure output(const kind: outputkindty; const text: string);
   procedure outrecord(const aname: string; const values: array of const);
   procedure unknownrec(const arec: valuearty);
	
   procedure beginblock(const aid: int32; const newidsize: int32);
   procedure endblock();
   procedure readblock();
   procedure readblockinfoblock();
   procedure readmoduleblock();
   procedure readtypeblock();
   procedure readconstantsblock();
   procedure readvaluesymtabblock();
   procedure readfunctionblock();
   procedure skip(const words: int32);
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure dump(const aoutput: tstream);
 end;
 
implementation
uses
 msebits,sysutils,mseformatstr,msearrayutils;
 
const
 blockidnames: array[blockids] of string = (
  'BLOCKINFO_BLOCK',
  '','','','','','','',
  'MODULE_BLOCK',
  'PARAMATTR_BLOCK',
  'PARAMATTR_GROUP_BLOCK',
  'CONSTANTS_BLOCK',
  'FUNCTION_BLOCK',
  'UNUSED_BLOCK',
  'VALUE_SYMTAB_BLOCK',
  'METADATA_BLOCK',
  'METADATA_ATTACHMENT',
  'TYPE_BLOCK_NEW',
  'USELIST_BLOCK'
 );

 modulecodenames: array[modulecodes] of string = (
  '',             //0
  'VERSION',      //1
  'TRIPLE',       //2
  'DATALAYOUT',   //3
  'ASM',          //4
  'SECTIONNAME',  //5
  'DEPLIB',       //6
  'GLOBALVAR',    //7
  'FUNCTION',     //8
  'ALIAS',        //9
  'PURGEVALS',    //10
  'GCNAME',       //11
  'COMDAT'        //12
 );
 
 typecodenames: array[typecodes] of string = (
  '',
  'NUMENTRY',
  'VOID',
  'FLOAT',
  'DOUBLE',
  'LABEL',
  'OPAQUE',
  'INTEGER',
  'POINTER',
  'FUNCTION_OLD',
  'HALF',
  'ARRAY',
  'VECTOR',
  'X86_FP80',
  'FP128',
  'PPC_FP128',
  'METADATA',
  'X86_MMX',
  'STRUCT_ANON',
  'STRUCT_NAME',
  'TRUCT_NAMED',
  'FUNCTION'
 );
  
 constantscodesnames: array[constantscodes] of string = (
  '',
  'SETTYPE',
  'NULL',
  'UNDEF',
  'INTEGER',
  'WIDE_INTEGER',
  'FLOAT',
  'AGGREGATE',
  'STRING',
  'CSTRING',
  'CE_BINOP',
  'CE_CAST',
  'CE_GEP',
  'CE_SELECT',
  'CE_EXTRACTELT',
  'CE_INSERTELT',
  'CE_SHUFFLEVEC',
  'CE_CMP',
  'INLINEASM_OLD',
  'CE_SHUFVEC_EX',
  'CE_INBOUNDS_GEP',
  'BLOCKADDRESS',
  'DATA',
  'INLINEASM'
 );

 valuesymtabcodesnames: array[valuesymtabcodes] of string = (
  '', 
  'ENTRY',
  'BBENTRY'
 );
  
 functioncodesnames: array[functioncodes] of string = (
  '',
  'DECLAREBLOCKS',
  'BINOP',
  'CAST',
  'GEP',
  'SELECT',
  'EXTRACTELT',
  'INSERTELT',
  'SHUFFLEVEC',
  'CMP',
  'RET',
  'BR',
  'SWITCH',
  'INVOKE',
  '',
  'UNREACHABLE',
  'PHI',
  '',
  '',
  'ALLOCA',
  'LOAD',
  '',
  '',
  'VAARG',
  'STORE',
  '',
  'EXTRACTVAL',
  'INSERTVAL',
  'CMP2',
  'VSELECT',
  'INBOUNDS_GEP',
  'INDIRECTBR',
  '',
  'DEBUG_LOC_AGAIN',
  'CALL',
  'DEBUG_LOC',
  'FENCE',
  'CMPXCHG',
  'ATOMICRMW',
  'RESUME',
  'LANDINGPAD',
  'LOADATOMIC',
  'STOREATOMIC'
 );

 binaryopcodesnames: array[binaryopcodes] of string = (
  'ADD',
  'SUB',
  'MUL',
  'UDIV',
  'SDIV',
  'UREM',
  'SREM',
  'SHL',
  'LSHR',
  'ASHR',
  'AND',
  'OR',
  'XOR'
 );

 castopcodesnames: array[castopcodes] of string = (
  'TRUNC',
  'ZEXT',
  'SEXT',
  'FPTOUI',
  'FPTOSI',
  'UITOFP',
  'SITOFP',
  'FPTRUNC',
  'FPEXT',
  'PTRTOINT',
  'INTTOPTR',
  'BITCAST'
 );

 char6tab: array[card8] of char = (
// 0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
  'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s',
//19  20  21  22  23  24  25
  't','u','v','w','x','y','z',
//26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44
  'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S',
//45  46  47  48  49  50  51
  'T','U','V','W','X','Y','Z',
//52  53  54  55  56  57  58  59  60  61
  '0','1','2','3','4','5','6','7','8','9',
//62  63
  '.','_',
// $40
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $50
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $60
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $70
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $80
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $90
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $a0
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $b0
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $c0
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $d0
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $e0
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
// $f0
  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0);

procedure error(const message: string);
begin
 raise exception.create(message+'.');
end;

function valueartostring(const avalue: valuearty): string;
var
 i1: int32;
 po1: pchar;
begin
 setlength(result,length(avalue));
 po1:= pointer(result);
 for i1:= 0 to high(avalue) do begin
  po1^:= char(avalue[i1]);
  inc(po1);
 end;
end;
  
{ ttypelist }

constructor ttypelist.create;
begin
 inherited create(sizeof(typeinfoty));
end;

function ttypelist.typename(const aindex: int32): string;
var
 i1: int32;
begin
 if aindex < 0 then begin
  result:= '^'+typename(-aindex);
 end
 else begin
  if invalidindex(aindex) then begin
   raise exception.create('Invalid type '+inttostr(aindex));
  end;
  with ptypeinfoty(pointer(fdata)+aindex*sizeof(typeinfoty))^ do begin
   if (ord(kind) < 0) or (kind > high(typecodenames)) then begin
    raise exception.create('Invalid type '+inttostr(ord(kind)));
   end;
   case kind of
    TYPE_CODE_POINTER: begin
     result:= '^'+typename(base);
    end;
    TYPE_CODE_ARRAY: begin
     result:= 'array['+inttostr(arraysize)+'] of '+typename(arraytype);
    end;
    TYPE_CODE_INTEGER: begin
     result:= typecodenames[kind]+':'+inttostr(size);
    end;
    TYPE_CODE_FUNCTION: begin
     result:= typecodenames[kind]+'(';
     for i1:= subparamindex to subparamindex+subparamcount-1 do begin
      result:= result+typename(fsubparams[i1])+',';
     end;
     setlength(result,length(result)-1);
     result:= result+')';
    end;
    else begin
     result:= typecodenames[kind];
    end;
   end;
  end;
  result:= inttostr(aindex)+'.'+result;
 end;
end;

function ttypelist.iskind(const aindex: int32; const akind: typecodes): boolean;
begin
 result:= validindex(aindex) and (ptypeinfoty(fdata)[aindex].kind = akind);
end;

function ttypelist.parentiskind(const aindex: int32;
               const akind: typecodes): boolean;
begin
 result:= validindex(aindex);
 if result then begin
  with ptypeinfoty(fdata)[aindex] do begin
   result:= (kind = TYPE_CODE_POINTER) and validindex(base) and
                   (ptypeinfoty(fdata)[base].kind = akind);
  end;
 end;
end;

function ttypelist.parenttype(const aindex: int32): ptypeinfoty;
begin
 checkvalidindex(aindex);
 with ptypeinfoty(fdata)[aindex] do begin
  if (kind <> TYPE_CODE_POINTER) or invalidindex(base) then begin
   error('Invalid pointer type');
  end;
  result:= @ptypeinfoty(fdata)[base];
 end;
end;

function ttypelist.parenttypeindex(const aindex: int32): int32;
begin
 if aindex < 0 then begin
  result:= -aindex;
  checkvalidindex(result);
 end
 else begin
  checkvalidindex(aindex);
  with ptypeinfoty(fdata)[aindex] do begin
   if (kind <> TYPE_CODE_POINTER) or invalidindex(base) then begin
    error('Invalid pointer type');
   end;
   result:= base;
  end;
 end;
end;

procedure ttypelist.checkvalidindex(const aindex: int32);
begin
 if invalidindex(aindex) then begin
  error('Invalid type index');
 end;
end;

function ttypelist.itemtypeindex(const aindex: integer): int32;
begin
 if aindex < 0 then begin
  result:= -aindex;
  checkvalidindex(result);
 end
 else begin
  checkvalidindex(aindex);
  with ptypeinfoty(fdata)[aindex] do begin
   case kind of
    TYPE_CODE_POINTER: begin
     result:= base;
    end;
    TYPE_CODE_ARRAY: begin
     result:= arraytype;
    end;
    else begin
     error('Invalid item type');
    end;
   end;
  end;
 end;
end;

{ tgloblist }

constructor tgloblist.create(const typelist: ttypelist);
begin
 ftypelist:= typelist;
 inherited create(sizeof(globinfoty));
end;

function tgloblist.constname(const aid: int32): string;
 
 procedure consterror();
 begin
  error('Invalid const '+inttostr(aid));
 end; //consterror
 
begin
 result:= '';
 if aid >= 0 then begin
  if (aid < count) then begin
   with pglobinfoty(fdata)[aid] do begin
    if kind <> gk_const then begin
     consterror();
    end;
    result:= inttostr(aid)+':'+ftypelist.typename(valuetype)+':';
    case constkind of
     CST_CODE_INTEGER: begin
      result:= result+inttostr(intconst);
     end;
     else begin
      result:= result + constantscodesnames[constkind];
     end;
    end;
   end;
  end
  else begin
   consterror();
  end;
 end;
end;

function tgloblist.typeid(const aindex: int32): int32;
begin
 checkvalidindex(aindex);
 with pglobinfoty(fdata)[aindex] do begin
  result:= valuetype;
 end;
end;

procedure tgloblist.checkvalidindex(const aindex: int32);
begin
 if invalidindex(aindex) then begin
  error('Invalid global index');
 end;
end;

{ tllvmbcreader }

constructor tllvmbcreader.create(ahandle: integer);
begin
 ftypelist:= ttypelist.create();
 fgloblist:= tgloblist.create(ftypelist);
 inherited;
 fbufpos:= @fbuffer;
 fbufend:= fbufpos;
 fillbuffer();
 fbitbuf:= fbufpos^;
 inc(fbufpos);
 fidsize:= 2;
end;

destructor tllvmbcreader.destroy;
begin
 ftypelist.free();
 fgloblist.free();
 inherited;
end;

function tllvmbcreader.tryfillbuffer: boolean;
begin
 fbufpos:= @fbuffer;
 fbufend:= fbufpos + read(fbuffer,sizeof(fbuffer));
 result:= fbufend > fbufpos;
end;

procedure tllvmbcreader.fillbuffer;
begin
 if not tryfillbuffer then begin
  error('Unexpected end of file');
 end;
end;

function tllvmbcreader.finished: boolean;
begin
 result:= fbufpos >= fbufend;
 if result then begin
  result:= not tryfillbuffer();
 end;
end;

function tllvmbcreader.getbits(const bitcount: int32): card8;
begin
 if bitcount > 0 then begin
  if fbitpos = 8 then begin //after skip
   if fbufpos >= fbufend then begin
    fillbuffer();
   end;
   fbitbuf:= fbufpos^;
   inc(fbufpos);
   fbitpos:= 0;
  end;
  fbitpos:= fbitpos + bitcount;
  if fbitpos >= 8 then begin
   if fbufpos >= fbufend then begin
    fillbuffer();
   end;
   fbitpos:= fbitpos - 8;
   fbitbuf:= fbitbuf or (fbufpos^ shl (bitcount-fbitpos));
   inc(fbufpos);
  end;
  result:= fbitbuf and bitmask[bitcount];
  fbitbuf:= fbitbuf shr bitcount;
 end;
end;

function tllvmbcreader.get8: card8;
begin
 if fbitpos = 0 then begin
  result:= fbitbuf;
  if fbufpos >= fbufend then begin
   fillbuffer();
  end;
  fbitbuf:= fbufpos^;
  inc(fbufpos);
 end
 else begin
  result:= getbits(8);
 end;
end;

procedure tllvmbcreader.readbits(const bitcount: int32; out buffer);
var
 po1,pe: pcard8;
 i1: integer;
begin
 if bitcount > 0 then begin
  po1:= @buffer;
  pe:= po1 + bitcount div 8; //whole bytes
  while po1 < pe do begin
   po1^:= get8();
   inc(po1);
  end;
  i1:= bitcount mod 8;
  if i1 > 0 then begin
   po1^:= getbits(i1);
  end;
 end;
end;

function tllvmbcreader.read32(const bitcount: int32 = 32): int32;
begin
 result:= 0;
 readbits(bitcount,result);
end;

procedure tllvmbcreader.beginblock(const aid: int32; const newidsize: int32);
begin
 if high(fblockstack) < fblocklevel then begin
  setlength(fblockstack,fblocklevel+1);
 end;
 with fblockstack[fblocklevel] do begin
  id:= aid;
  oldidsize:= fidsize;
  fidsize:= newidsize;
  if high(fblockabbrevs) >= id then begin
   blockabbrev:= fblockabbrevs[id];
  end
  else begin
   blockabbrev:= nil;
  end;
  abbrevs:= nil;
 end;
 inc(fblocklevel);
end;

procedure tllvmbcreader.endblock();
begin
 dec(fblocklevel);
 if fblocklevel < 0 then begin
  error('Invalid END_BLOCK');
 end;
 with fblockstack[fblocklevel] do begin
  fidsize:= oldidsize;
 end;
 align32();
end;

procedure tllvmbcreader.readblockheader(out blockid: int32; 
                               out newabbrevlen: int32; out blocklen: int32);
begin
 blockid:= readvbr(8);
 newabbrevlen:= readvbr(4);
 align32();
 blocklen:= read32();
end;

procedure tllvmbcreader.readmoduleblock;
var
 rec1: valuearty;

 procedure outglobalvalue(const message: string; const params: array of const);
 begin
//  output(ok_beginend,modulecodenames[modulecodes(rec1[1])]+
//             '.'+inttostr(fgloblist.count)+':'+message);
  outrecord(modulecodenames[modulecodes(rec1[1])]+
             '.'+inttostr(fgloblist.count-1)+':'+message,params);
//  inc(fglobindex);
 end;

var
 str1: string; 
 blocklevelbefore: int32;

begin
 output(ok_begin,blockidnames[MODULE_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(modulecodenames))) or 
             (modulecodenames[modulecodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin
    case modulecodes(rec1[1]) of
     MODULE_CODE_GLOBALVAR: begin
      checkmindatalen(rec1,5);
      with pglobinfoty(fgloblist.add())^ do begin
       kind:= gk_var;
       valuetype:= rec1[2];
       outglobalvalue(ftypelist.typename(valuetype)+','+inttostr(rec1[3])+','+
                    fgloblist.constname(rec1[4]-1),
                                      dynarraytovararray(copy(rec1,5,bigint)));
      end;
     end;
     MODULE_CODE_FUNCTION: begin
      checkmindatalen(rec1,2);
      additem(fsubheaders,fgloblist.count,fsubheadercount);
      with pglobinfoty(fgloblist.add())^ do begin
       kind:= gk_sub;
       valuetype:= rec1[2];
       if not ftypelist.parentiskind(valuetype,TYPE_CODE_FUNCTION) then begin
        error('Invalid function type');
       end;
       subindex:= fsubheadercount-1;
       str1:= inttostr(subindex)+':'+ftypelist.typename(valuetype);
       if high(rec1) > 2 then begin
        outglobalvalue(str1,dynarraytovararray(copy(rec1,3,bigint)));
       end
       else begin
        outglobalvalue(str1,[]);
       end;
      end;
     end;
     else begin
      outrecord(modulecodenames[modulecodes(rec1[1])],
                       dynarraytovararray(copy(rec1,2,bigint)));
     end;
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readtypeblock();
var
 blocklevelbefore,i2,i3: int32;
 rec1: valuearty;
 po1: ptypeinfoty;
begin
 output(ok_begin,blockidnames[TYPE_BLOCK_ID_NEW]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(typecodenames))) or 
             (typecodenames[typecodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin
    if typecodes(rec1[1]) <> TYPE_CODE_NUMENTRY then begin
     po1:= ftypelist.add();
     po1^.kind:= typecodes(rec1[1]);
    end;
    if high(rec1) = 1 then begin
     output(ok_beginend,typecodenames[typecodes(rec1[1])]);
    end
    else begin //length > 2
     case typecodes(rec1[1]) of
      TYPE_CODE_POINTER: begin
       po1^.base:= rec1[2];
       output(ok_beginend,ftypelist.typename(ftypelist.count-1));
      end;
      TYPE_CODE_ARRAY: begin
       checkmindatalen(rec1,3);
       po1^.arraysize:= rec1[2];
       po1^.arraytype:= rec1[3];
       output(ok_beginend,ftypelist.typename(ftypelist.count-1));
      end;
      TYPE_CODE_INTEGER: begin
       po1^.size:= rec1[2];
       output(ok_beginend,ftypelist.typename(ftypelist.count-1));
      end;
      TYPE_CODE_FUNCTION: begin
       checkmindatalen(rec1,3);
       po1^.subvararg:= rec1[2] <> 0;
       po1^.subparamcount:= high(rec1)-4+1+1; //+result type
       with ftypelist do begin
        po1^.subparamindex:= fsubparamcount;
        fsubparamcount:= fsubparamcount+po1^.subparamcount;
        if fsubparamcount > high(fsubparams) then begin
         reallocuninitedarray(2*fsubparamcount+256,sizeof(fsubparams[0]),
                                                               fsubparams);
        end;
        i2:= po1^.subparamindex;
        fsubparams[i2]:= rec1[3]; //result type
        inc(i2);
        for i3:= 4 to high(rec1) do begin
         fsubparams[i2]:= rec1[i3];
         inc(i2);
        end;
       end;
       output(ok_beginend,ftypelist.typename(ftypelist.count-1));
      end;
      else begin
       outrecord(inttostr(ftypelist.count-1)+'.'+
                   typecodenames[typecodes(rec1[1])],
                        dynarraytovararray(copy(rec1,2,bigint)));
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readconstantsblock();
var
 rec1: valuearty;
 
 procedure outconst(const avalues: array of const);
 begin
  outrecord(inttostr(fgloblist.count-1)+'.'+
                    constantscodesnames[constantscodes(rec1[1])],avalues);
 end; //outconst

var
 blocklevelbefore: int32;
 po1: ptypeinfoty;
 
begin
 output(ok_begin,blockidnames[CONSTANTS_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(constantscodesnames))) or 
             (constantscodesnames[constantscodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin
    if constantscodes(rec1[1]) = CST_CODE_SETTYPE then begin
     checkdatalen(rec1,2);
     fgloblist.fsettype:= rec1[2];
     output(ok_beginend,constantscodesnames[constantscodes(rec1[1])]+':'+
                                       ftypelist.typename(fgloblist.fsettype));
    end
    else begin
     with pglobinfoty(fgloblist.add())^ do begin
      kind:= gk_const;
      valuetype:= fgloblist.fsettype;
      constkind:= constantscodes(rec1[1]);
      if high(rec1) = 1 then begin
       outconst([]);
      end
      else begin //length > 2
       case constkind of
        CST_CODE_INTEGER: begin
         intconst:= rec1[2] shr 1;
         if odd(rec1[2]) then begin
          intconst:= -intconst;
         end;
         outconst([inttostr(intconst)]);
        end
        else begin
         outconst(dynarraytovararray(copy(rec1,2,bigint)));
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readvaluesymtabblock();
var
 blocklevelbefore: int32;
 rec1: valuearty;
begin
 output(ok_begin,blockidnames[VALUE_SYMTAB_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(valuesymtabcodesnames))) or 
             (valuesymtabcodesnames[valuesymtabcodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin 
    case valuesymtabcodes(rec1[1]) of
     VST_CODE_ENTRY,VST_CODE_BBENTRY: begin
      checkmindatalen(rec1,3);
      outrecord(valuesymtabcodesnames[valuesymtabcodes(rec1[1])],
                              [rec1[2],valueartostring(copy(rec1,3,bigint))]);
     end;
     else begin
      unknownrec(rec1);
     end;
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readfunctionblock();
var
 rec1: valuearty;
 paramcount,ssastart,ssaindex: int32;
 ssatypes: integerarty;
 
 procedure outssarecord(const atype: int32; const avalue: string);
 begin
  output(ok_beginend,functioncodesnames[functioncodes(rec1[1])]+': S'+
              inttostr(ssaindex)+':= '+avalue+': '+ftypelist.typename(atype));
  additem(ssatypes,atype,ssaindex);
 end; //outfuncrecord

 function absvalue(const avalue: int32): int32;
 begin
  result:= ssaindex+ssastart-avalue;
 end; //absvalue
 
 function typeid(avalue: int32): int32;
 begin
  avalue:= ssaindex-avalue;
  if avalue < 0 then begin
   result:= fgloblist.typeid(avalue+ssastart);
  end
  else begin
   if avalue >= ssaindex then begin
    error('Invalid ssa index');
   end;
   result:= ssatypes[avalue];
  end;
 end; //typeid

 function opname(avalue: int32): string;
 begin
  avalue:= ssaindex-avalue;
  if avalue < 0 then begin
   avalue:= avalue+ssastart;
   with pglobinfoty(fgloblist.fdata)[avalue] do begin
    if kind = gk_const then begin
     result:= 'C'+inttostr(avalue)+'=';
     case constkind of
      CST_CODE_INTEGER: begin
       result:= result+inttostr(intconst);
      end;
      CST_CODE_NULL: begin
       result:= result+'NULL';
      end;
     end;
    end
    else begin
     result:= 'G'+inttostr(avalue);
    end;
   end;
  end
  else begin
   if avalue >= ssaindex then begin
    error('Invalid ssa index');
   end;
   if avalue < paramcount then begin
    result:= 'P'+inttostr(avalue);
   end
   else begin
    result:= 'S'+inttostr(avalue-paramcount);
   end;
  end;
 end;
  
var
 subtyp1: int32;
 blocklevelbefore: int32;
 i1,i2: int32;
 str1: string;
 
begin
 if fsubimplementationcount >= fsubheadercount then begin
  error('Function without header');
 end;
 i1:= fsubheaders[fsubimplementationcount];
 subtyp1:= pglobinfoty(fgloblist.fdata)[i1].valuetype;
 output(ok_begin,blockidnames[FUNCTION_BLOCK_ID]+'.'+
            inttostr(i1)+':'+inttostr(fsubimplementationcount)+':'+
            ftypelist.typename(subtyp1));
 inc(fsubimplementationcount);
 ssastart:= fgloblist.count;
 with ftypelist.parenttype(subtyp1)^ do begin
// ssaindex:= ptypeinfoty(ftypelist.fdata)[
//                 ptypeinfoty(ftypelist.fdata)[subtyp1].base].subparamcount-1;
  ssaindex:= subparamcount-1;
  paramcount:= ssaindex;
  setlength(ssatypes,ssaindex);
  i2:= subparamindex;
  for i1:= 0 to high(ssatypes) do begin
   ssatypes[i1]:= ftypelist.fsubparams[i2];
   inc(i2);
  end;
 end;
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(functioncodesnames))) or 
   (functioncodesnames[functioncodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin
    if high(rec1) > 1 then begin
     case functioncodes(rec1[1]) of
      FUNC_CODE_INST_BINOP: begin
       checkdatalen(rec1,4);
       if rec1[4] > ord(high(binaryopcodesnames)) then begin
        error('Invalid binary opcode');
       end;
       str1:= binaryopcodesnames[binaryopcodes(rec1[4])]+
        '('+opname(rec1[2])+','+opname(rec1[3])+')';
       i1:= typeid(rec1[2]);
       i2:= typeid(rec1[3]);
       outssarecord(i1,str1);
       if i1 <> i2 then begin
        error('Incompatible type');
       end;
      end;
      FUNC_CODE_INST_CAST: begin
       checkdatalen(rec1,4);
       str1:= castopcodesnames[castopcodes(rec1[4])]+
       '('+opname(rec1[2])+':'+ftypelist.typename(typeid(rec1[2]))+')';
       i1:= rec1[3];
       outssarecord(i1,str1);
      end;
      FUNC_CODE_INST_GEP: begin
       checkmindatalen(rec1,2);
       str1:= opname(rec1[2])+'[';
       i2:= typeid(rec1[2]);
       for i1:= 3 to high(rec1) do begin
        str1:= str1+opname(rec1[i1])+',';
        i2:= ftypelist.itemtypeindex(i2);
       end;
       if high(rec1) >= 3 then begin
        setlength(str1,length(str1)-1);
        i2:= -i2; //pointer
       end;
       str1:= str1+']';
       outssarecord(i2,str1);
      end;
      FUNC_CODE_INST_STORE: begin
       checkmindatalen(rec1,3);
       i1:= typeid(rec1[2]); //dest
       i2:= typeid(rec1[3]); //source
       str1:= functioncodesnames[functioncodes(rec1[1])]+
               ': '+opname(rec1[2])+'^:= '+opname(rec1[3])+': '+
                                                 ftypelist.typename(i2);
       if high(rec1) > 3 then begin
        outrecord(str1+' A',dynarraytovararray(copy(rec1,4,bigint)));
       end
       else begin
        outrecord(str1,[]);
       end;
       if ftypelist.parenttypeindex(i1) <> i2 then begin
        error('Invalid pointer type');
       end;
      end;
      FUNC_CODE_INST_LOAD: begin
       checkmindatalen(rec1,2);
       outssarecord(ftypelist.parenttypeindex(typeid(rec1[2])),
                            opname(rec1[2])+'^');
      end;
      FUNC_CODE_INST_ALLOCA: begin
       outssarecord(rec1[2],'@');
      end;
      FUNC_CODE_INST_RET: begin
       if high(rec1) = 2 then begin
        outrecord(functioncodesnames[functioncodes(rec1[1])],[opname(rec1[2])]);
       end
       else begin
        outrecord(functioncodesnames[functioncodes(rec1[1])],
               dynarraytovararray(copy(rec1,2,bigint)));
       end;
      end;
      else begin
       outrecord(functioncodesnames[functioncodes(rec1[1])],
               dynarraytovararray(copy(rec1,2,bigint)));
      end;
     end;
    end
    else begin
     outrecord(functioncodesnames[functioncodes(rec1[1])],[]);
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readblockinfoblock;
var
 blocklevelbefore: int32;
 rec1: valuearty;
 str1: string;
begin
 output(ok_begin,blockidnames[BLOCKINFO_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   case blockinfocodes(rec1[1]) of
    BLOCKINFO_CODE_SETBID: begin
     checkdatalen(rec1,2);
     fblockinfoid:= rec1[2];
     str1:= inttostr(fblockinfoid);
     if fblockinfoid <= ord(high(blockidnames)) then begin
      str1:= str1+'.'+blockidnames[blockids(fblockinfoid)];
     end;
     outrecord('SETBID',[str1]);
     if fblockinfoid > high(fblockabbrevs) then begin
      setlength(fblockabbrevs,fblockinfoid+1);
     end;
    end;
    else begin
     unknownrec(rec1);
    end;
   end;
  end;
 end;
 fblockinfoid:= 0;
end;

procedure tllvmbcreader.readblock();
var
 blockid,newabbrevlen,blocklen: int32;

 procedure unknownblock();
 begin
  output(ok_beginend,'UNKNOWN_BLOCK_'+inttostr(blockid));
  skip(blocklen);
  endblock();
 end; //unknownblock

begin
 readblockheader(blockid,newabbrevlen,blocklen);
 beginblock(blockid,newabbrevlen);
 if (blockid > ord(high(blockidnames))) or 
                       (blockidnames[blockids(blockid)] = '') then begin
  unknownblock();
 end
 else begin
  case blockids(blockid) of
   BLOCKINFO_BLOCK_ID: begin
    readblockinfoblock();
   end;
   MODULE_BLOCK_ID: begin
    readmoduleblock();
   end;
   TYPE_BLOCK_ID_NEW: begin
    readtypeblock();
   end;
   CONSTANTS_BLOCK_ID: begin
    readconstantsblock();
   end;
   VALUE_SYMTAB_BLOCK_ID: begin
    readvaluesymtabblock();
   end;
   FUNCTION_BLOCK_ID: begin
    readfunctionblock();
   end;
   else begin
    unknownblock();
   end;
  end;
 end;
end;

procedure tllvmbcreader.readabbrev(aid: int32; var values: valuearty);

var
 outindex: int32;

 procedure doread(const abbrev: abbrevty);

  procedure readarray(const item: abbrevitemty); forward;
  
  procedure readvalue(const item: abbrevitemty);
  var
   by1: card8;
  begin
   if outindex > high(values) then begin
    reallocuninitedarray(outindex*2+4,sizeof(values[0]),values);
   end;
   with item do begin
    case kind of
     ak_literal: begin
      values[outindex]:= literal;
     end;
     ak_fix: begin
      values[outindex]:= 0;
      readbits(size,values[outindex]);
     end;
     ak_var: begin
      values[outindex]:= readvbr(size);
     end;
     ak_array: begin
      readarray(item);
     end;
     ak_char6: begin
      by1:= 0;
      readbits(6,by1);
      values[outindex]:= ord(char6tab[by1]);
     end;
     ak_blob: begin
     end;
     else begin
      error('Invalid abbrev kind '+inttostr(ord(kind)));
     end;
    end;
   end;
   inc(outindex);
  end; //readvalue
  
  procedure readarray(const item: abbrevitemty);
  var
   i1: int32;
  begin
   for i1:= readvbr(6) - 1 downto 0 do begin
    readvalue(farraytypes[item.arraytype]);
   end;
   dec(outindex); //compensate inc() at end of readvalue 
  end; //readarray
  
 var
  i1: int32;
 begin
  for i1:= 0 to high(abbrev) do begin
   readvalue(abbrev[i1]);
  end;
  setlength(values,outindex);
 end;

begin
 setlength(values,8);
 values[0]:= aid;
 outindex:= 1;
 with fblockstack[fblocklevel-1] do begin
  aid:= aid - 4;
  if aid <= high(blockabbrev) then begin
   doread(blockabbrev[aid]);
  end
  else begin
   aid:= aid - length(blockabbrev);
   if aid <= high(abbrevs) then begin
    doread(abbrevs[aid]);
   end
   else begin
    error('Unknown abbrev '+inttostr(id+4+length(blockabbrev)));
   end;
  end;   
 end;
end;

function tllvmbcreader.readitem(): valuearty;
          //nil if internal read, first array item = code
var
 str1: string;
 numops: int32;
 
 procedure readabbrevitem(var abbrev1: abbrevitemty);
 var
  by1: card8;
 begin
  with abbrev1 do begin
   if getbits(1) = 1 then begin
    kind:= ak_literal;
    literal:= readvbr(8);
    str1:= str1+'LITERAL:'+inttostr(literal);
   end
   else begin
    by1:= getbits(3);     
    case by1 of
     1: begin
      kind:= ak_fix;
      size:= readvbr(5);
      str1:= str1+'FIX'+inttostr(size);
     end;
     2: begin
      kind:= ak_var;
      size:= readvbr(5);     
      str1:= str1+'VAR'+inttostr(size);
     end;
     3: begin
      kind:= ak_array;
      setlength(farraytypes,high(farraytypes)+2);
      arraytype:= high(farraytypes);
      str1:= str1+'ARRAY(';
      dec(numops);
      readabbrevitem(farraytypes[arraytype]);
      setlength(str1,length(str1)-1);
      str1:= str1+')';
     end;
     4: begin
      kind:= ak_char6;
      str1:= 'CHAR6';
     end;
     5: begin
      kind:= ak_blob;
      str1:= 'BLOB';
     end;
     else begin
      error('Invalid abbrev encoding '+inttostr(by1));
     end;
    end;
   end;
   str1:= str1+',';
  end;
 end; //readabbrevitem
 
var
 ca1: card32;
 i1,code: int32;
 abbrev1: abbrevty;
begin
 result:= nil;
 ca1:= read32(fidsize);
 case fixedabbrevids(ca1) of
  enter_subblock: begin
   readblock();
  end;
  end_block: begin
   endblock();
   with fblockstack[fblocklevel] do begin
    if (id > ord(high(blockidnames))) or 
                       (blockidnames[blockids(id)] = '') then begin
     output(ok_end,'UNKNOWN_BLOCK_'+inttostr(id));
    end
    else begin
     output(ok_end,blockidnames[blockids(id)]);
    end;
   end;
  end;
  unabbrev_record: begin
   code:= readvbr(6);
   numops:= readvbr(6);
   allocuninitedarray(numops+2,sizeof(result[0]),result);   
   result[0]:= ca1;
   result[1]:= code;
   for i1:= 2 to numops+1 do begin
    result[i1]:= readvbr(6);
   end;
  end;
  define_abbrev: begin
   abbrev1:= nil;
   numops:= readvbr(5);
   allocuninitedarray(numops,sizeof(abbrev1[0]),abbrev1);
   str1:= '';
   i1:= 0;
   while i1 < numops do begin
    readabbrevitem(abbrev1[i1]);
    inc(i1);
   end;
   setlength(abbrev1,numops); //possibly changed by array operand
   if str1 <> '' then begin
    setlength(str1,length(str1)-1); //remove last comma
   end;
   if fblockinfoid > 0 then begin
    i1:= high(fblockabbrevs[fblockinfoid])+1;
    setlength(fblockabbrevs[fblockinfoid],i1+1);
    fblockabbrevs[fblockinfoid][i1]:= abbrev1;
   end
   else begin
    with fblockstack[fblocklevel] do begin
     i1:= high(abbrevs)+1;
     setlength(abbrevs,i1+1);
     abbrevs[i1]:= abbrev1;
     i1:= i1+length(fblockabbrevs);
    end;
   end;
   output(ok_beginend,'DEFINE_ABBREV:'+inttostr(i1+4)+':('+str1+')');
   
  end;
  else begin
   readabbrev(ca1,result);
   if high(result) < 1 then begin
    error('Empty record');
   end;
  end;
 end;
end;

procedure tllvmbcreader.dump(const aoutput: tstream);
var
 ca1: card32;
begin
 exitcode:= 1;
 ca1:= read32();
 if ca1 <> $dec04342 then begin
  error('Invalid magic number '+hextostr(ntobe(ca1),8));
 end;
 while not finished do begin
  readitem();
 end;
 exitcode:= 0;
end;

procedure tllvmbcreader.align32();
var
 i1: int32;
begin
 fbufpos:= fbufpos+2;
 if fbitpos > 0 then begin
  inc(fbufpos);
 end;
 fbufpos:= pointer(ptruint(fbufpos) and not ptruint(3));
 if fbufpos >= fbufend then begin
  i1:= fbufpos-fbufend;
  if i1 = 0 then begin
   fbitpos:= 8;
   exit; //possibly at end of file
  end;
  fillbuffer();
  fbufpos:= fbufpos + i1;
  if fbufpos >= fbufend then begin
   fillbuffer(); //error message
  end;
 end;
 fbitbuf:= fbufpos^;
 inc(fbufpos);
 fbitpos:= 0;
end;

function tllvmbcreader.readvbr(const bitsize: int32): valuety;
var
 ca1,mask: card32;
 i1,masksize: int32;
begin
 result:= 0;
 masksize:= bitsize-1;
 i1:= 0;
 ca1:= 0;
 mask:= bitmask[masksize];
 repeat
  readbits(bitsize,ca1);
  result:= result or ((ca1 and mask) shl valuety(i1));
  i1:= i1 + masksize;
 until ca1 and bits[masksize] = 0;
end;

procedure tllvmbcreader.skip(const words: int32);
begin
 if fbitpos <> 0 then begin
  error('Invalid skip');
 end;
 fbufpos:= fbufpos + words * 4 - 1; //current byte is in bitbuffer
 if fbufpos > fbufend then begin
  seek(fbufpos-fbufend,socurrent);
  fbufpos:= fbufend;
 end;
 fbitpos:= 8; //empty bitbuffer
end;

procedure tllvmbcreader.output(const kind: outputkindty; const text: string);
begin
 if kind = ok_end then begin
  dec(findent);
  if findent < 0 then begin
   error('Invalid block end');
  end;
 end;
 system.write(charstring(' ',findent)+'<'+text);
 if kind in [ok_end,ok_beginend] then begin
  system.write('/');
 end;
 writeln('>');
 if kind = ok_begin then begin
  inc(findent);
 end;
end;

procedure tllvmbcreader.outrecord(const aname: string;
               const values: array of const);
var
 str1: string;
 i1: int32;
begin
 str1:= '';
 for i1:= 0 to high(values) do begin
  str1:= str1+tvarrectoansistring(values[i1])+',';
 end;
 if str1 <> '' then begin
  setlength(str1,length(str1)-1);
 end;
 output(ok_beginend,aname+':'+str1);
end;

procedure tllvmbcreader.checkdatalen(const arec: valuearty;
               const alen: integer);
begin
 if high(arec) <> alen then begin
  error('Invalid record length '+inttostr(high(arec))+
                                   ', should be '+inttostr(alen));
 end;
end;

procedure tllvmbcreader.checkmindatalen(const arec: valuearty;
               const alen: integer);
begin
 if high(arec) < alen then begin
  error('Invalid record length '+inttostr(high(arec))+
                                ', should be at least '+inttostr(alen));
 end;
end;

procedure tllvmbcreader.unknownrec(const arec: valuearty);
var
 str1: string;
 i1: int32;
begin
 str1:= '';
 for i1:= 2 to high(arec) do begin
  str1:= str1+inttostr(arec[i1])+',';
 end;
 if str1 <> '' then begin
  setlength(str1,length(str1)-1);
 end;
 output(ok_beginend,'UNKNOWN_REC_'+inttostr(arec[0])+'.'+inttostr(arec[1])+
                                                                     ':'+str1);
end;

end.
