{ MSElang Copyright (c) 2015-2017 by Martin Schreiber
   
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
 msestream,classes,mclasses,msetypes,msestrings,
 llvmbitcodes,mselist,globtypes;
//
//not optimized, for debug purpose only
//

const
 bcreaderbuffersize = 16; //test fillbuffer, todo: make it bigger
type
 valuety = int64;
 pvaluety = ^valuety;
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
   fsubparams: integerarty; //array of typeindex
  public
   constructor create();
   procedure checkvalidindex(const aindex: int32);
   function item(const aindex: int32): ptypeinfoty;
   function typename(const aindex: int32): string;
   function typename(const aindex: int32; out asize: int32): string;
   function iskind(const aindex: int32; const akind: typecodes): boolean;
   function ispointer(const aindex: int32): boolean;
   function sametype(const a,b: int32): boolean;
   function parentiskind(const aindex: int32; const akind: typecodes): boolean;
   function parenttype(const aindex: int32): ptypeinfoty;
   function parenttype(const atype: ptypeinfoty): ptypeinfoty;
   function parenttypeindex(const aindex: int32): int32;
   function itemtypeindex(const aindex: integer): int32;
//   function item(const aindex: int32): ptypeinfoty;
 end;

 globkindty = (gk_const,gk_var,gk_sub,gk_meta);
 constkindty = (ck_integer);
 
 globinfoty = record
  valuetype: int32;
  case kind: globkindty of
   gk_const: (
    case constkind: constantscodes of
     CST_CODE_INTEGER: (
      intconst: valuety;
     );
     CST_CODE_WIDE_INTEGER: (
      bigintconst: int32; //index in fstringbuffer
     );
     CST_CODE_FLOAT: (
      case floatsize: databitsizety of
       das_f32: (
        flo32const: flo32;
       );
       das_f64: (
        flo64const: flo64;
       );
     );
   );
   gk_var: (
    explicittype: boolean;
   );
   gk_sub: (
    subheaderindex: int32;    
   );
   gk_meta: (
   );
 end;
 pglobinfoty = ^globinfoty;

type 
 tgloblist = class(trecordlist)
  protected
   ftypelist: ttypelist;
   fsettype: int32;
   fstringbuffer: stringarty;
  public
   constructor create(const typelist: ttypelist);
   procedure checkvalidindex(const aindex: int32);
   function constname(const aid: int32): string;
   function typeid(const aindex: int32): int32;
   function typeid(const aindex: int32; out aexplicittype: boolean): int32;
   function item(const aindex: int32): pglobinfoty;
 end;
{
 tmetakindlist = class(tbufferdatalist)
  public
 end;
}  
 metainfoty = record
 end;
 
 tmetalist = class(trecordlist)
  protected
//   fkindlist: tmetakindlist;
  public
   constructor create();
   destructor destroy(); override;
   procedure add();
 end;

 blockinfoty = record
  id: int32;
  oldidsize: int32;
  blockabbrev: abbrevarty;
  abbrevs: abbrevarty;
  list: tgloblist;
  ssapo: pint32;
 end;
 blockinfoarty = array of blockinfoty;
 
 outputkindty = (ok_begin,ok_end,ok_beginend);

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
   ffunctionlevel: int32;
   fblockstack: blockinfoarty;
   farraytypes: array of abbrevitemty;
   fblockinfoid: int32;
   fblockabbrevs: array of abbrevarty; //blockid is array index
//   fglobindex: int32;
   ftypelist: ttypelist;
   fgloblist: tgloblist;
   fmetalist: tmetalist;
   fsubheadercount: int32;
   fsubheaders: integerarty; //index in fgloblist
   fsubimplementationcount: int32;
   fbb,fbbbefore: int32;
   fwrapsize: card32;
   fwrapcpu: card32;
   fssastart,fssaindex,fparamcount: int32;
   fssatypes: integerarty; //negative values -> pointer
   fconststart: int32;
   fcurrentconstlist: tgloblist;
   fopnum: int32;
  protected
   procedure checkdatalen(const arec: valuearty; const alen: integer);
   procedure checkmindatalen(const arec: valuearty; const alen: integer);
   procedure checkmaxdatalen(const arec: valuearty; const alen: integer);

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
   function getopname(avalue: int32): string; //absvalue

   procedure output(const kind: outputkindty; const text: string);
   procedure outrecord(const aname: string; const values: array of const);
   procedure unknownrec(const arec: valuearty);
   function subopname(const aop: int32): string;

   procedure beginblock(const aid: int32; const newidsize: int32);
   procedure endblock();
   procedure readblock();
   procedure readblockinfoblock();
   procedure readmoduleblock();
   procedure readtypeblock();
   procedure readconstantsblock(const alist: tgloblist);
   procedure readmetadatablock();
   procedure readmetadatakindblock();
   procedure readmetadataattachmentblock();
   procedure readvaluesymtabblock();
   procedure readfunctionblock();
   procedure readparamattr(const akind: blockids);
   procedure readparamattrblock();
   procedure readparamattrgroupblock();
   procedure readuselistblock();
   procedure skip(const words: int32);
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure dump(const aoutput: tstream);
 end;
 
implementation
uses
 mseformatstr,msearrayutils,msebits,sysutils,llvmlists,typinfo,bcunitglob,
 msesystypes;
const
 pointermask = 1 shl 31;
 blockidnames: array[blockids] of string = (
  'BLOCKINFO_BLOCK',
  '','','','','','','',
  'MODULE_BLOCK',
  'PARAMATTR_BLOCK',
  'PARAMATTR_GROUP_BLOCK',
  'CONSTANTS_BLOCK',
  'FUNCTION_BLOCK',
  'IDENTIFICATION_BLOCK',
  'VALUE_SYMTAB_BLOCK',
  'METADATA_BLOCK',
  'METADATA_ATTACHMENT',
  'TYPE_BLOCK_NEW',
  'USELIST_BLOCK',
  'MODULE_STRTAB_BLOCK',
  'FUNCTION_SUMMARY_BLOCK',
  'OPERAND_BUNDLE_TAGS_BLOCK',
  'METADATA_KIND_BLOCK'
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
  'STRUCT_NAMED',
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

 attributecodesnames: array[attributecodes] of string = (
  '', 
  'PARAMATTR_CODE_ENTRY_OLD',
  'PARAMATTR_CODE_ENTRY',
  'PARAMATTR_GRP_CODE_ENTRY'
 );

 uselistcodesnames: array[uselistcodes] of string = (
  '', 
  'USELIST_CODE_DEFAULT',
  'USELIST_CODE_BB'
 );

 metadatacodesnames: array[metadatacodes] of string = (
  '',
    'METADATA_STRING',
    'METADATA_VALUE',
    'METADATA_NODE',
    'METADATA_NAME',
    'METADATA_DISTINCT_NODE',
    'METADATA_KIND',
    'METADATA_LOCATION',
    'METADATA_OLD_NODE',
    'METADATA_OLD_FN_NODE',
    'METADATA_NAMED_NODE',
    'METADATA_ATTACHMENT',
    'METADATA_GENERIC_DEBUG',
    'METADATA_SUBRANGE',
    'METADATA_ENUMERATOR',
    'METADATA_BASIC_TYPE',
    'METADATA_FILE',
    'METADATA_DERIVED_TYPE',
    'METADATA_COMPOSITE_TYPE',
    'METADATA_SUBROUTINE_TYPE',
    'METADATA_COMPILE_UNIT',
    'METADATA_SUBPROGRAM',
    'METADATA_LEXICAL_BLOCK',
    'METADATA_LEXICAL_BLOCK_FILE',
    'METADATA_NAMESPACE',
    'METADATA_TEMPLATE_TYPE',
    'METADATA_TEMPLATE_VALUE',
    'METADATA_GLOBAL_VAR',
    'METADATA_LOCAL_VAR',
    'METADATA_EXPRESSION',
    'METADATA_OBJC_PROPERTY',
    'METADATA_IMPORTED_ENTITY',
    'METADATA_MODULE'
   );

 functioncodesnames: array[functioncodes] of string = (
  '',                            //0
  'DECLAREBLOCKS',               //1
  'BINOP',                       //2
  'CAST',                        //3
  'GEP_OLD',                         //4
  'SELECT',                      //5
  'EXTRACTELT',                  //6
  'INSERTELT',                   //7
  'SHUFFLEVEC',                  //8
  'CMP',                         //9
  'RET',                         //10
  'BR',                          //11
  'SWITCH',                      //12
  'INVOKE',                      //13
  '',                            //14
  'UNREACHABLE',                 //15
  'PHI',                         //16
  '',                            //17
  '',                            //18
  'ALLOCA',                      //19
  'LOAD',                        //20
  '',                            //21
  '',                            //22
  'VAARG',                       //23
  'STORE_OLD',                       //24
  '',                            //25
  'EXTRACTVAL',                  //26
  'INSERTVAL',                   //27
  'CMP2',                        //28
  'VSELECT',                     //29
  'INBOUNDS_GEP_OLD',                //30
  'INDIRECTBR',                  //31
  '',                            //32
  'DEBUG_LOC_AGAIN',             //33
  'CALL',                        //34
  'DEBUG_LOC',                   //35
  'FENCE',                       //36
  'CMPXCHG_OLD',                     //37
  'ATOMICRMW',                   //38
  'RESUME',                      //39
  'LANDINGPAD_OLD',                  //40
  'LOADATOMIC',                  //41
  'STOREATOMIC_OLD',                 //42
  'GEP',                         //43
  'STORE',                       //44
  'STOREATOMIC',                 //45,
  'INST_CMPXCHG,',               //46
  'LANDINGPAD'                   //47
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

 predicatenames: array[predicate] of string = (
  'FCMP_FALSE',
  'FCMP_OEQ',
  'FCMP_OGT',
  'FCMP_OGE',
  'FCMP_OLT',
  'FCMP_OLE',
  'FCMP_ONE',
  'FCMP_ORD',
  'FCMP_UNO',
  'FCMP_UEQ',
  'FCMP_UGT',
  'FCMP_UGE',
  'FCMP_ULT',
  'FCMP_ULE',
  'FCMP_UNE',
  'FCMP_TRUE',
  'FCMP_16',
  'FCMP_17',
  'FCMP_18',
  'FCMP_19',
  'FCMP_20',
  'FCMP_21',
  'FCMP_22',
  'FCMP_23',
  'FCMP_24',
  'FCMP_25',
  'FCMP_26',
  'FCMP_27',
  'FCMP_28',
  'FCMP_29',
  'FCMP_30',
  'FCMP_31',
  'ICMP_EQ',
  'ICMP_NE',
  'ICMP_UGT',
  'ICMP_UGE',
  'ICMP_ULT',
  'ICMP_ULE',
  'ICMP_SGT',
  'ICMP_SGE',
  'ICMP_SLT',
  'ICMP_SLE'
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

function vbrsigned(const avalue: integer): integer; inline;
begin
 result:= card32(avalue) shr 1;
 if odd(avalue) then begin
  result:= -1;
 end;
 if avalue < 0 then begin
  result:= (-avalue shl 1) or 1;
 end;
end;

var
 reader: tllvmbcreader;
 
procedure error(const message: string);
begin
 writeln('********** error '+message);
 writeln('Opnum ',reader.fopnum);
 flush(output);
 raise exception.create(message+'. Opnum: '+inttostr(reader.fopnum));
end;

function valueartostring(const avalue: valuearty; const start: int32): string;
var
 i1: int32;
 po1: pchar;
begin
 result:= '';
 if start <= high(avalue) then begin
  setlength(result,length(avalue)-start);
  po1:= pointer(result);
  for i1:= start to high(avalue) do begin
   po1^:= char(avalue[i1]);
   inc(po1);
  end;
 end;
end;

function intvalueartostring(const avalue: valuearty; const start: int32): string;
var
 i1: int32;
begin
 result:= '';
 if start <= high(avalue) then begin
  for i1:= start to high(avalue) do begin
   result:= result + inttostr(avalue[i1])+',';
  end;
  setlength(result,length(result)-1);
 end;
end;

function tagvalueartostring(const avalue: valuearty; const start: int32): string;
var
 i1: int32;
begin
 result:= '';
 if start <= high(avalue) then begin
  for i1:= start to high(avalue) do begin
   result:= result + '$'+hextostr(card32(avalue[i1]),0)+',';
  end;
  setlength(result,length(result)-1);
 end;
end;

function metaornullartostring(const avalues: valuearty;
                                                const start: int32): string;
var
 i1: int32;
begin
 result:= '';
 if start <= high(avalues) then begin
  for i1:= start to high(avalues) do begin
   result:= result+'M'+inttostr(avalues[i1]-1)+',';
  end;
  setlength(result,length(result)-1);
 end;
end;
  

procedure decodesigned1(var value: valuety);
begin
 if odd(value) then begin
  value:= -(value shr 1);
 end
 else begin
  value:= (value shr 1);
 end;
end;

{ ttypelist }

constructor ttypelist.create;
begin
 inherited create(sizeof(typeinfoty));
end;

function ttypelist.typename(const aindex: int32; out asize: int32): string;
var
 i1: int32;
begin
 asize:= 0;
 if aindex and pointermask <> 0 then begin
  result:= '^'+typename(aindex and not pointermask,i1);
 end
 else begin
  if invalidindex(aindex) then begin
   error('Invalid type '+inttostr(aindex));
  end;
  with ptypeinfoty(pointer(fdata)+aindex*sizeof(typeinfoty))^ do begin
   if (ord(kind) < 0) or (kind > high(typecodenames)) then begin
    error('Invalid type '+inttostr(ord(kind)));
   end;
   case kind of
    TYPE_CODE_POINTER: begin
     result:= '^'+typename(base);
    end;
    TYPE_CODE_ARRAY: begin
     result:= 'array['+inttostr(arraysize)+'] of '+typename(arraytype);
    end;
    TYPE_CODE_INTEGER: begin
     asize:= size;
     result:= typecodenames[kind]+':'+inttostr(size);
    end;
    TYPE_CODE_FUNCTION: begin
     result:= typecodenames[kind]+'(';
     for i1:= subparamindex to subparamindex+subparamcount-1 do begin
      result:= result+typename(fsubparams[i1])+',';
     end;
     if subvararg then begin
      result:= result + '...,';
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

function ttypelist.typename(const aindex: int32): string;
var
 i1: int32;
begin
 result:= typename(aindex,i1);
end;

function ttypelist.sametype(const a,b: int32): boolean;
var
 sa,sb: string;
begin
 result:= a = b;
 if not result then begin
  sa:= typename(a);
  sb:= typename(b);
  result:= (countchars(sa,'^') = countchars(sb,'^'));
  if result then begin
   sa:= copy(sa,findlastchar(sa,'.')+1,bigint);
   sb:= copy(sb,findlastchar(sb,'.')+1,bigint);
   result:= sa = sb;
  end;
 end;
end;

function ttypelist.iskind(const aindex: int32; const akind: typecodes): boolean;
begin
 result:= validindex(aindex) and (ptypeinfoty(fdata)[aindex].kind = akind);
end;

function ttypelist.ispointer(const aindex: int32): boolean;
begin
 result:= validindex(aindex);
 if result then begin
  with ptypeinfoty(fdata)[aindex] do begin
   result:= (kind = TYPE_CODE_POINTER);
  end;
 end;
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

function ttypelist.parenttype(const atype: ptypeinfoty): ptypeinfoty;
begin
 with atype^ do begin
  if kind = TYPE_CODE_FUNCTION then begin
   result:= atype;
  end
  else begin
   if (kind <> TYPE_CODE_POINTER) or invalidindex(base) then begin
    error('Invalid pointer type');
   end;
   result:= @ptypeinfoty(fdata)[base];
  end;
 end;
end;

function ttypelist.parenttype(const aindex: int32): ptypeinfoty;
begin
 checkvalidindex(aindex);
 result:= parenttype(@ptypeinfoty(fdata)[aindex]);
end;

function ttypelist.parenttypeindex(const aindex: int32): int32;
begin
 if aindex and pointermask <> 0 then begin
  result:= aindex and not pointermask;
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

function ttypelist.item(const aindex: int32): ptypeinfoty;
begin
 checkvalidindex(aindex);
 result:= @ptypeinfoty(fdata)[aindex];
end;

{ tmetalist }

constructor tmetalist.create();
begin
 inherited create(sizeof(metainfoty));
// fkindlist:= tmetakindlist.create();
end;

destructor tmetalist.destroy();
begin
// fkindlist.free();
 inherited;
end;

procedure tmetalist.add;
var
 dummy: int32 = 0;
begin
 inherited add(dummy);
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
   result:= inttostr(aid)+':forward';
//   consterror();
  end;
 end;
end;

function tgloblist.typeid(const aindex: int32;
               out aexplicittype: boolean): int32;
begin
 checkvalidindex(aindex);
 aexplicittype:= false;
 with pglobinfoty(fdata)[aindex] do begin
  result:= valuetype;
  if kind = gk_var then begin
   aexplicittype:= explicittype;
  end;
 end;
end;

function tgloblist.typeid(const aindex: int32): int32;
var
 bo1: boolean;
begin
 result:= typeid(aindex,bo1);
end;

procedure tgloblist.checkvalidindex(const aindex: int32);
begin
 if invalidindex(aindex) then begin
  error('Invalid global index');
 end;
end;

function tgloblist.item(const aindex: int32): pglobinfoty;
begin
 checkvalidindex(aindex);
 result:= @pglobinfoty(fdata)[aindex];
end;

{ tllvmbcreader }

constructor tllvmbcreader.create(ahandle: integer);
begin
 reader:= self;
 ftypelist:= ttypelist.create();
 fgloblist:= tgloblist.create(ftypelist);
 fmetalist:= tmetalist.create;
 inherited;
 fbufpos:= @fbuffer;
 fbufend:= fbufpos;
 fillbuffer();
 fbitbuf:= fbufpos^;
 inc(fbufpos);
 fidsize:= 2;
end;

destructor tllvmbcreader.destroy();
begin
 ftypelist.free();
 fgloblist.free();
 fmetalist.free();
 inherited;
end;

function tllvmbcreader.tryfillbuffer(): boolean;
begin
 fbufpos:= @fbuffer;
 fbufend:= fbufpos + read(fbuffer,sizeof(fbuffer));
 result:= fbufend > fbufpos;
end;

procedure tllvmbcreader.fillbuffer();
begin
 if not tryfillbuffer then begin
  error('Unexpected end of file');
 end;
end;

function tllvmbcreader.finished(): boolean;
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

procedure tllvmbcreader.checkmaxdatalen(const arec: valuearty;
               const alen: integer);
begin
 if high(arec) > alen then begin
  error('Invalid record length '+inttostr(high(arec))+
                                ', should be at most '+inttostr(alen));
 end;
end;

procedure tllvmbcreader.output(const kind: outputkindty; const text: string);
var
 str1: string;
 i1: int32;
begin
 str1:= '';
 if ffunctionlevel > 0 then begin
  str1:= inttostr(fopnum);
  i1:= 4;
  if fopnum >= 1000 then begin
   inc(i1);
  end;
  if fopnum >= 10000 then begin
   inc(i1);
  end;
  if fopnum >= 10000 then begin
   inc(i1);
  end;
  extendstring(str1,i1);
  if fbb <> fbbbefore then begin
   str1:= str1+inttostr(fbb)+':';
   fbbbefore:= fbb;
  end;
  extendstring(str1,5+i1);
  system.write(str1);
 end;
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
  list:= nil;
  ssapo:= nil;
  if fblocklevel > 0 then begin
   ssapo:= fblockstack[fblocklevel-1].ssapo;
  end;
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
  list.free();
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

procedure tllvmbcreader.readmoduleblock();
var
 rec1: valuearty;

 procedure outglobalvalue(const message: string; const params: array of const;
                          const linkageindex: int32 = -1);
 var
  str1: string;
 begin
  if (linkageindex >= 0) and (linkageindex <= high(params)) then begin
   str1:= '.'+getenumname(typeinfo(linkagety),params[linkageindex].vint64^)+
          ':';
  end
  else begin
   str1:= ':';
  end;
  outrecord(modulecodenames[modulecodes(rec1[1])]+'.'+
             inttostr(fgloblist.count-1)+str1+message,params);
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
     MODULE_CODE_TRIPLE,MODULE_CODE_DATALAYOUT: begin
      outrecord(modulecodenames[modulecodes(rec1[1])],
                                         [valueartostring(rec1,2)]);
     end;
     MODULE_CODE_GLOBALVAR: begin
     //    2            3         4
     //[pointer type, isconst, initid,
     //   5         6         7         8              9
     //linkage, alignment, section, visibility, threadlocal]
      checkmindatalen(rec1,5);
      with pglobinfoty(fgloblist.add())^ do begin
       kind:= gk_var;
       valuetype:= rec1[2];
       explicittype:= rec1[3] and $2 <> 0;
       if rec1[4] = 0 then begin
        str1:= 'ext';
       end
       else begin
        str1:= fgloblist.constname(rec1[4]-1);
       end;
       outglobalvalue(ftypelist.typename(valuetype)+','+
         inttostr(rec1[3])+','+str1,dynarraytovararray(copy(rec1,5,bigint)),0);
      end;
     end;
     MODULE_CODE_FUNCTION: begin
      checkmindatalen(rec1,4);
      with pglobinfoty(fgloblist.add())^ do begin
       if rec1[4] = 0 then begin //no proto
        subheaderindex:= fsubheadercount;
        additem(fsubheaders,fgloblist.count-1,fsubheadercount);
        str1:= 'D'; //definition
       end
       else begin
        subheaderindex:= -1;
        str1:= 'P'; //proto
       end;
       kind:= gk_sub;
       valuetype:= rec1[2];
       if not (ftypelist.iskind(valuetype,TYPE_CODE_FUNCTION) or
               ftypelist.parentiskind(valuetype,TYPE_CODE_FUNCTION)) then begin
        error('Invalid function type');
       end;
       if subheaderindex >= 0 then begin
        str1:= str1+inttostr(subheaderindex)
       end;
       str1:= str1+':'+ftypelist.typename(valuetype);
       if high(rec1) > 2 then begin
        outglobalvalue(str1,dynarraytovararray(copy(rec1,3,bigint)),2);
       end
       else begin
        outglobalvalue(str1,[]);
       end;
      end;
     end;
     MODULE_CODE_ALIAS: begin
      // 2            3             4       5   
      //alias type, aliasee val#, linkage, visibility
      checkmindatalen(rec1,5);
      str1:= inttostr(rec1[3])+':'+ftypelist.typename(rec1[2]);
      outglobalvalue(str1,[]);
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
    if not (typecodes(rec1[1]) in [TYPE_CODE_NUMENTRY,TYPE_CODE_STRUCT_NAME]) then begin
     po1:= ftypelist.add();
     po1^.kind:= typecodes(rec1[1]);
    end;
    if high(rec1) = 1 then begin
     output(ok_beginend,inttostr(ftypelist.count-1)+'.'+
                                typecodenames[typecodes(rec1[1])]);
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
      TYPE_CODE_STRUCT_NAME: begin
       output(ok_beginend,valueartostring(rec1,2));
//       outrecord(typecodesnames[typecodes(rec1[1])],
//                               [valueartostring(rec1,2)]);
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

procedure tllvmbcreader.readconstantsblock(const alist: tgloblist);
var
 rec1: valuearty;
 
 procedure outconst(const avalues: array of const);
 begin
  outrecord(inttostr(alist.count-1)+'.'+
                    constantscodesnames[constantscodes(rec1[1])],avalues);
  with fblockstack[fblocklevel-1] do begin
   if ssapo <> nil then begin
    additem(fssatypes,alist.fsettype,ssapo^);
   end;
  end;
 end; //outconst
 
 procedure defoutconst();
 begin
  outconst(dynarraytovararray(copy(rec1,2,bigint)));
 end; //defoutconst

var
 blocklevelbefore: int32;
 po1: ptypeinfoty;
 countbefore: int32; 
 s1: string;
 isflo32: boolean;
 p2: pvaluety;
 v1: valuety;
 i1,si1: int32;
begin
 output(ok_begin,blockidnames[CONSTANTS_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 countbefore:= alist.count;
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
     alist.fsettype:= rec1[2];
     s1:= ftypelist.typename(alist.fsettype,si1);
     if pos('FLOAT',s1) > 0 then begin
      isflo32:= true;
     end;
     if pos('DOUBLE',s1) > 0 then begin
      isflo32:= false;
     end;
     output(ok_beginend,constantscodesnames[constantscodes(rec1[1])]+':'+s1);
    end
    else begin
     with pglobinfoty(alist.add())^ do begin
      kind:= gk_const;
      valuetype:= alist.fsettype;
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
          if intconst = 0 then begin
           intconst:= -$8000000000000000;
          end;
         end;
         outconst([inttostr(intconst)]);
        end;
        CST_CODE_WIDE_INTEGER: begin
         s1:= '';
         i1:= length(rec1)-2;
         if i1 > 0 then begin
          setlength(s1,i1*sizeof(valuety));
          p2:= pointer(s1);
          fillchar(p2^,length(s1),0);
          for i1:= 2 to 2 + (i1 - 1) do begin
           v1:= rec1[i1] shr 1;
           if odd(rec1[i1]) then begin
            v1:= -v1;
            if v1 = 0 then begin
             v1:= -$8000000000000000;
            end;
           end;
           p2^:= v1;
           inc(p2);
          end;
         end;
         setlength(s1,(si1+7)div 8);
         outconst([bytestrtostr(s1,nb_hex,' ')]);
         bigintconst:= length(alist.fstringbuffer);
         additem(alist.fstringbuffer,s1);
        end;
        CST_CODE_FLOAT: begin
         if isflo32 then begin
          floatsize:= das_f32;
          flo32const:= pflo32(@rec1[2])^;
          outconst([realtostrmse(flo32const)]);
         end
         else begin
          floatsize:= das_f64;
          flo64const:= pflo64(@rec1[2])^;
          outconst([realtostrmse(flo64const)]);
         end;
        end;
        CST_CODE_CE_CAST: begin
         if high(rec1) = 4 then begin
          if (rec1[2] >= 0) and 
                           (rec1[2] <= ord(high(castopcodesnames))) then begin
           s1:= castopcodesnames[castopcodes(rec1[2])];
          end
          else begin
           s1:= inttostr(rec1[2]);
          end;
//          s1:= s1 + ':'+ftypelist.typename(rec1[3])+','+inttostr(rec1[4]);
          s1:= s1 + ':'+ftypelist.typename(rec1[3])+','+getopname(rec1[4]);
          outconst([s1]);
         end
         else begin
          defoutconst();
         end;
        end;
        CST_CODE_CE_GEP: begin
         defoutconst();
        end;
        else begin
         defoutconst();
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
{
 with fblockstack[fblocklevel-1] do begin
  if ssapo <> nil then begin
   ssapo^:= ssapo^ + alist.count - countbefore;
  end;
 end;
}
end;

function tllvmbcreader.subopname(const aop: int32): string;
var
 i1: int32;
begin
 i1:= aop-fssastart-fparamcount;
 if i1 < 0 then begin
  result:= 'P';
  i1:= i1 + fparamcount;
 end
 else begin
  if i1 >= fssaindex-fparamcount then begin
   result:= 'S+';
  end
  else begin
   result:= 'S';
  end;
 end;
 result:= result + inttostr(i1);
end;

procedure tllvmbcreader.readmetadatablock();

var
 rec1: valuearty;

function metastring(const avalues: valuearty): string;
 var
  i1: int32;
 begin
  result:= '';
  if avalues <> nil then begin
   for i1:= 0 to high(avalues) do begin
    result:= result+'M'+inttostr(avalues[i1])+',';
   end;
   setlength(result,length(result)-1);
  end;
 end;

 procedure outmetarecord(atext: string; const last: int32);
 begin
  if last < high(rec1) then begin
   atext:= atext+','+intvalueartostring(copy(rec1,last+1,bigint),0);
  end;
  output(ok_beginend,metadatacodesnames[metadatacodes(rec1[1])]+': M'+
                                     inttostr(fmetalist.count-1)+':= '+ atext);
 end; //outmetarecord

 function typevaluepair(const start: int32): string;
 var
  po1,pe: pvaluety;
  i1,i2: int32;
 begin
  result:= '';
  po1:= @rec1[start];
  pe:= @rec1[high(rec1)];
  while po1 < pe do begin
   with ftypelist.item(po1^)^ do begin
    case kind of 
     TYPE_CODE_METADATA: begin
       result:= result+'M'+inttostr((po1+1)^);
     end;
     TYPE_CODE_VOID: begin
      result:= result+'NULL';
     end;
     else begin
      result:= result + getopname((po1+1)^);
     end;
    end;
   end;
   result:= result + ',';
   inc(po1,2);
  end;
  if result <> '' then begin
   setlength(result,length(result)-1);
  end;
 end; //typevaluepair

 function distinct(): string;
 begin
  if rec1[2] <> 0 then begin
   result:= 'distinct ';
  end
  else begin
   result:= '';
  end;
 end; //distinct
 
 function meta(const aname: string; const aindex: int32): string;
 begin
  result:= aname+':M'+inttostr(rec1[aindex]);
 end;

 function metaornull(const aname: string; const aindex: int32): string;
 begin
  result:= aname+':M'+inttostr(int32(rec1[aindex])-1);
 end;

 function card(const aname: string; const aindex: int32): string;
 begin
  result:= aname+':'+inttostr(int32(rec1[aindex]));
 end;

 function int(const aname: string; const aindex: int32): string;
 begin
  result:= aname+':'+inttostr(vbrsigned(rec1[aindex]));
 end;

 function tag(const aname: string; const aindex: int32): string;
 begin
  result:= aname+':$'+hextostr(card32(rec1[aindex]),0);
 end;
   
var
 blocklevelbefore: int32;
 name1: string;
 str1: string;
 fncount: int32;
 i1: int32;
begin
 if ffunctionlevel > 0 then begin
  inc(fopnum);
 end;
 output(ok_begin,blockidnames[METADATA_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 fncount:= 0;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(metadatacodesnames))) or 
             (metadatacodesnames[metadatacodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin 
    case metadatacodes(rec1[1]) of
     METADATA_STRING: begin
      fmetalist.add();
      outmetarecord(quotestring(valueartostring(rec1,2),'"'),bigint);
     end;
     METADATA_NAME: begin
      name1:= valueartostring(rec1,2);
     end;
     METADATA_NAMED_NODE: begin
      output(ok_beginend,metadatacodesnames[metadatacodes(rec1[1])]+': '+
                name1+':= '+intvalueartostring(rec1,2));
      name1:= '';
     end;
     METADATA_KIND: begin
      checkmindatalen(rec1,3);
      output(ok_beginend,metadatacodesnames[metadatacodes(rec1[1])]+':'+
                             inttostr(rec1[2])+':'+valueartostring(rec1,3));
     end;
     METADATA_VALUE: begin
      fmetalist.add();
      outmetarecord(typevaluepair(2),3);
     end;
     METADATA_FILE: begin
      fmetalist.add();
      checkdatalen(rec1,4);
      outmetarecord(distinct()+
       metaornull('filename',3)+','+
       metaornull('directory',4),4);
     end;
     METADATA_BASIC_TYPE: begin
      fmetalist.add();
      checkdatalen(rec1,7);
      outmetarecord(distinct()+
       tag('tag',3)+','+
       metaornull('name',4)+','+
       card('size',5)+','+
       card('align',6)+','+
       tag('encoding',7),7);
     end;
     METADATA_ENUMERATOR: begin
      fmetalist.add();
      checkdatalen(rec1,4);
      outmetarecord(distinct()+
       int('value',3)+','+
       metaornull('name',4),4);
     end;
     METADATA_DERIVED_TYPE: begin
      fmetalist.add();
      checkdatalen(rec1,13);
      outmetarecord(distinct()+
       tag('tag',3)+','+
       metaornull('name',4)+','+
       metaornull('file',5)+','+
       card('line',6)+','+
       metaornull('scope',7)+','+
       metaornull('basetype',8)+','+
       card('sizeinbits',9)+','+
       card('aligninbits',10)+','+
       card('offsetinbits',11)+','+
       tag('flags',12)+','+
       metaornull('extradata',13),13);
     end;
     METADATA_COMPOSITE_TYPE: begin
      fmetalist.add();
      checkdatalen(rec1,17);
      outmetarecord(distinct()+
       tag('tag',3)+','+
       metaornull('name',4)+','+
       metaornull('file',5)+','+
       card('line',6)+','+
       metaornull('scope',7)+','+
       metaornull('basetype',8)+','+
       card('sizeinbits',9)+','+
       card('aligninbits',10)+','+
       card('offsetinbits',11)+','+
       tag('flags',12)+','+
       metaornull('elements',13)+','+
       tag('runtimelang',14)+','+
       metaornull('vtableholder',15)+','+
       metaornull('templateparams',16)+','+
       metaornull('identifier',17),17);
     end;
     METADATA_SUBROUTINE_TYPE: begin
      fmetalist.add();
      checkdatalen(rec1,4);
      outmetarecord(distinct()+
        tag('flags',3)+','+
        metaornull('typearray',4),4);
     end;
     METADATA_SUBPROGRAM: begin
      fmetalist.add();
      checkmindatalen(rec1,19);
      str1:= distinct()+metaornull('scope',3)+','+
        metaornull('name',4)+','+
        metaornull('linkagename',5)+','+
        metaornull('file',6)+','+
        card('line',7)+','+
        metaornull('type',8)+','+
        card('islocaltounit',9)+','+
        card('isdefinition',10)+','+
        card('scopeline',11)+','+
        metaornull('containingtype',12)+','+
        tag('virtuality',13)+','+
        card('virtualindex',14)+','+
        tag('flags',15)+','+
        card('isoptimized',16)+','+
        metaornull('function',17)+','+
        metaornull('templateparams',18)+','+
        metaornull('declaration',19);
      if high(rec1) >= 20 then begin
       str1:= str1 + ',' + metaornull('variables',20);
      end;
      outmetarecord(str1,high(rec1));
     end;
     METADATA_COMPILE_UNIT: begin
      fmetalist.add();
      checkmindatalen(rec1,14);
//      checkmaxdatalen(rec1,16);
      str1:= distinct()+
        tag('sourcelanguage',3)+','+
        metaornull('file',4)+','+
        metaornull('producer',5)+','+
        card('isoptimized',6)+','+
        metaornull('flags',7)+','+
        card('runtimeversion',8)+','+
        metaornull('splitdebugfilename',9)+','+
        card('emissionkind',10)+','+
        metaornull('enumtypes',11)+','+
        metaornull('retainedtypes',12)+','+
        metaornull('subprograms',13)+','+
        metaornull('globalvariables',14)+','+
        metaornull('importedidentities',15);
      if high(rec1) >= 16 then begin
       str1:= str1+','+card('dwoid',16);
       outmetarecord(str1,high(rec1));
      end
      else begin
       outmetarecord(str1,15);
      end;
     end;
     METADATA_GLOBAL_VAR: begin
      fmetalist.add();
      checkmindatalen(rec1,12);
      str1:= distinct()+
        metaornull('scope',3)+','+
        metaornull('name',4)+','+
        metaornull('linkagename',5)+','+
        metaornull('file',6)+','+
        card('line',7)+','+
        metaornull('type',8)+','+
        card('islocaltounit',9)+','+
        card('isdefinition',10)+','+
        metaornull('variable',11)+','+
        metaornull('staticmemberdeclaration',12);
      outmetarecord(str1,12);
     end;
     METADATA_LOCAL_VAR: begin
      fmetalist.add();
      checkmindatalen(rec1,10);
      str1:= distinct()+
        tag('tag',3)+','+
        metaornull('scope',4)+','+
        metaornull('name',5)+','+
        metaornull('file',6)+','+
        card('line',7)+','+
        metaornull('type',8)+','+
        card('arg',9)+','+
        tag('flags',10);
      outmetarecord(str1,10);
     end;
     METADATA_NODE: begin
      fmetalist.add();
      outmetarecord(metaornullartostring(rec1,2),bigint);
     end;
     METADATA_EXPRESSION: begin
      fmetalist.add();
      outmetarecord(distinct()+tagvalueartostring(rec1,3),bigint);
     end;
     else begin
      fmetalist.add();
      outmetarecord(intvalueartostring(rec1,2),bigint);
     end;
    end;
   end;
   if ffunctionlevel > 0 then begin
    inc(fopnum);
   end;
  end;
 end;
 if ffunctionlevel > 0 then begin
  inc(fopnum);
 end;
end;

procedure tllvmbcreader.readmetadatakindblock();
var
 blocklevelbefore: int32;
 name1: string;
 str1: string;
 fncount: int32;
 i1: int32;
 rec1: valuearty;
begin
 output(ok_begin,blockidnames[METADATA_KIND_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 fncount:= 0;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   checkmindatalen(rec1,2);
   if (rec1[1] <> ord(metadata_kind)) then begin
    unknownrec(rec1);
   end
   else begin
    outrecord('KIND.'+inttostr(rec1[2]),
                         [quotestring(valueartostring(rec1,3),'"')]);
   end;
  end;
 end;
end;

procedure tllvmbcreader.readmetadataattachmentblock();
var
 blocklevelbefore: int32;
 name1: string;
 str1: string;
 fncount: int32;
 i1: int32;
 rec1: valuearty;
begin
 if ffunctionlevel > 0 then begin
  inc(fopnum);
 end;
 output(ok_begin,blockidnames[METADATA_ATTACHMENT_ID]);
 blocklevelbefore:= fblocklevel;
 fncount:= 0;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   checkmindatalen(rec1,2);
   if (rec1[1] <> ord(metadata_attachment)) or 
                (rec1[2] > ord(high(metadataattachmentcodenames))) then begin
    unknownrec(rec1);
   end
   else begin
    outrecord('ATTACHMENT.'+
         metadataattachmentcodenames[metadataattachmentcodes(rec1[2])],
          [intvalueartostring(rec1,3)]);
   end;
   if ffunctionlevel > 0 then begin
    inc(fopnum);
   end;
  end;
 end;
 if ffunctionlevel > 0 then begin
  inc(fopnum);
 end;
end;

procedure tllvmbcreader.readvaluesymtabblock();
var
 blocklevelbefore: int32;
 rec1: valuearty;
 str1: string;
begin
 if ffunctionlevel > 0 then begin
  inc(fopnum);
 end;
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
      if ffunctionlevel > 0 then begin
       str1:= subopname(rec1[2]);
      end
      else begin
       str1:= inttostr(rec1[2]);
      end;
      outrecord(valuesymtabcodesnames[valuesymtabcodes(rec1[1])],
                              [str1,valueartostring(rec1,3)]);
     end;
     else begin
      unknownrec(rec1);
     end;
    end;
   end;
   if ffunctionlevel > 0 then begin
    inc(fopnum);
   end;
  end;
 end;
end;

function tllvmbcreader.getopname(avalue: int32): string; //absvalue

 procedure returnglob(const alist: tgloblist; const aindex: int32;
                                               const constname: string);
 begin
  alist.checkvalidindex(aindex);
  with pglobinfoty(alist.fdata)[aindex] do begin
   if kind = gk_const then begin
    result:= constname+inttostr(aindex)+'=';
    case constkind of
     CST_CODE_INTEGER: begin
      result:= result+inttostr(intconst);
     end;
     CST_CODE_WIDE_INTEGER: begin
      result:= result+bytestrtostr(alist.fstringbuffer[bigintconst],nb_hex,' ');
     end;
     CST_CODE_FLOAT: begin              //todo: size
      case floatsize of
       das_f32: begin
        result:= result+ansistring(realtostrmse(flo32const));
       end;
       das_f64: begin
        result:= result+ansistring(realtostrmse(flo64const));
       end;
      end;
     end;
     CST_CODE_NULL: begin
      result:= result+'NULL';
     end;
     else begin
      result:= result+constantscodesnames[constkind];
     end;
    end;
   end
   else begin
    if (kind = gk_var) and explicittype then begin
     result:= '^';
    end
    else begin
     result:= '';
    end;
    result:= result+'G'+inttostr(avalue);
   end;
  end;
 end; //returnglob

 //valueids:
 //              0
 //globals       fconststart
 //local consts  fssastart
 //params        fssastart + fparamcount
 //ssa's         fssastart + fssaindex

begin
 if (ffunctionlevel = 0) or (ffunctionlevel > 0) and 
                                       (avalue < fconststart) then begin
  returnglob(fgloblist,avalue,'C');
 end
 else begin
  if (avalue >= fconststart) and 
           (avalue < fconststart+fcurrentconstlist.count) then begin
   returnglob(fcurrentconstlist,avalue-fconststart,'CL');
  end
  else begin
   avalue:= avalue - fssastart;
   if avalue < fparamcount then begin
    result:= 'P'+inttostr(avalue);
   end
   else begin
    if avalue >= fssaindex then begin
     result:= 'S+';
    end
    else begin
     result:= 'S';
    end;
    result:= result + inttostr(avalue-fparamcount);
   end;
  end;
 end;
end;

procedure tllvmbcreader.readfunctionblock();
var
 rec1: valuearty;
// conststart: int32;
// currentconstlist: tgloblist;
 bbcount: int32;

 procedure incompatibletypeerror(const atext: string; typea,typeb: int32);
 begin
  error(atext+' is:'+ftypelist.typename(typea)+
               ' wanted:'+ftypelist.typename(typeb));
 end; //incompatibletypeerror()

 procedure outoprecord(const aname: string; const values: array of const);
 begin
  if fbb = -1 then begin
   fbb:= 0;
  end;
  outrecord(aname,values);
 end;

 procedure outssarecord(const atype: int32; const avalue: string);
 begin
  if fbb = -1 then begin
   fbb:= 0;
  end;
  output(ok_beginend,functioncodesnames[functioncodes(rec1[1])]+': S'+
                          inttostr(fssaindex-fparamcount)+':= '+
                                       avalue+': '+ftypelist.typename(atype));
  additem(fssatypes,atype,fssaindex);
 end; //outfuncrecord

 function absvalue(const avalue: int32): int32;
 begin
  result:= fssaindex+fssastart-avalue;
 end; //absvalue
 
 function typeid1(avalue: int32; out explicittype: boolean): int32;
 begin
  explicittype:= false;
  avalue:= fssaindex-avalue;
  if avalue < 0 then begin
   avalue:= avalue+fssastart;
   if avalue >= fconststart then begin
    result:= fcurrentconstlist.typeid(avalue-fconststart);
   end
   else begin
    result:= fgloblist.typeid(avalue,explicittype);
   end;
  end
  else begin
   if avalue >= fssaindex then begin
    result:= maxint;
   end
   else begin
    result:= fssatypes[avalue];
    if result and pointermask <> 0 then begin
     explicittype:= true;
    end;
   end;
  end;
 end; //typeid

 function typeid(avalue: int32; out explicittype: boolean): int32;
 begin
  result:= typeid1(avalue,explicittype) and not pointermask;
 end;

 function pointertypeid(avalue: int32): int32;
 var
  bo1: boolean;
 begin
  result:= typeid1(avalue,bo1);
 end;

 function typeid(avalue: int32): int32;
 var
  bo1: boolean;
 begin
  result:= typeid1(avalue,bo1) and not pointermask;
 end;

 function pointerbasetypeid(const avalue: int32): int32;
 var
  bo1: boolean;
 begin
  result:= typeid(avalue,bo1);
  if not bo1 then begin
   result:= ftypelist.parenttypeindex(result);
  end;
 end;
 
 function opname(avalue: int32; const typeindex: int32 = -1): string;
 begin
  if (typeindex >= 0) and 
             (ftypelist.item(typeindex)^.kind = TYPE_CODE_METADATA) then begin
   result:= 'M'+inttostr(fssaindex-avalue+fssastart);
  end
  else begin
   result:= getopname(absvalue(avalue));
  end;
 end; //opname
 
 function destname(const avalue: int32): string;
 begin
  if (avalue < 0) or (avalue >= bbcount) then begin
   error('Invalid BB id '+inttostr(avalue));
  end;
  result:= '->'+inttostr(avalue);
 end; //destname

 function checktypeids(const a: int32; const b: int32): boolean;
                //negative values -> pointer
 begin
  result:= (a = b) or 
                     (a = maxint) or (b = maxint); //unknown because of forward
  if not result then begin
   if a and pointermask <> 0 then begin
    if b and pointermask = 0 then begin
     result:= a and not pointermask = ftypelist.parenttypeindex(b);
    end;
   end
   else begin
    if b and pointermask <> 0 then begin
     if a and pointermask = 0 then begin
      result:= b and not pointermask = ftypelist.parenttypeindex(a);
     end;
    end;
   end;
   if not result then begin
    result:= ftypelist.sametype(a,b);
   end;
   result:= result or (b and pointermask = 0) and (b < ftypelist.count) and 
                         (ftypelist.item(b)^.kind = TYPE_CODE_METADATA);
  end;
 end; //checktypeids

 procedure incbb();
 begin
  if fbb < 0 then begin
   fbb:= 0;
  end;
  inc(fbb);
  if fbb > bbcount then begin
   error('BB bigger than BB-count');
  end;
 end;

 procedure outrec();
 begin
  outrecord(functioncodesnames[functioncodes(rec1[1])],
                                 dynarraytovararray(copy(rec1,2,bigint)));
 end;
 
var
 subtyp1: int32;
 blocklevelbefore: int32;
 i1,i2,i3,i4: int32;
 str1: string;
 bo1: boolean;
 vararg1: boolean;
 po1: ptypeinfoty;
 fuco: functioncodes;
 metacountbefore: int32;

 //valueids:
 //              0
 //globals       fconststart
 //local consts  fssastart
 //params        fssastart + fparamcount
 //ssa's         fssastart + fssaindex
 
begin
 with fblockstack[fblocklevel-1] do begin
  list:= tgloblist.create(ftypelist);
  ssapo:= @fssaindex;
  fcurrentconstlist:= list;
 end;
 if fsubimplementationcount >= fsubheadercount then begin
  error('Function without header');
 end;
 i1:= fsubheaders[fsubimplementationcount];
 subtyp1:= pglobinfoty(fgloblist.fdata)[i1].valuetype;
 output(ok_begin,blockidnames[FUNCTION_BLOCK_ID]+'.'+
                   inttostr(i1)+'.'+inttostr(fopnum)+
                       ':'+inttostr(fsubimplementationcount)+':'+
                                            ftypelist.typename(subtyp1));
 inc(fsubimplementationcount);
 fconststart:= fgloblist.count;
 fssastart:= fconststart;
 fbbbefore:= -1;
 fbb:= -1;
 if ftypelist.ispointer(subtyp1) then begin
  po1:= ftypelist.parenttype(subtyp1);
 end
 else begin
  po1:= ftypelist.item(subtyp1);
 end;
 with po1^ do begin
// ssaindex:= ptypeinfoty(ftypelist.fdata)[
//                 ptypeinfoty(ftypelist.fdata)[subtyp1].base].subparamcount-1;
  fssaindex:= subparamcount-1;
  fparamcount:= fssaindex;
  setlength(fssatypes,fssaindex);
  i2:= subparamindex+1; //skip result type
  for i1:= 0 to high(fssatypes) do begin
   fssatypes[i1]:= ftypelist.fsubparams[i2];
   inc(i2);
  end;
 end;
 blocklevelbefore:= fblocklevel;
 bbcount:= 0;
 if ffunctionlevel <> 0 then begin
  error('Nested function');
 end;
 inc(ffunctionlevel);
 metacountbefore:= fmetalist.count;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(functioncodesnames))) or 
   (functioncodesnames[functioncodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin
    if high(rec1) > 0 then begin
     fuco:= functioncodes(rec1[1]);
     case fuco of
      FUNC_CODE_DECLAREBLOCKS: begin
       checkdatalen(rec1,2);
       bbcount:= rec1[2];
       outrec();
      end;
      FUNC_CODE_INST_BINOP,FUNC_CODE_INST_CMP: begin
       checkdatalen(rec1,4);
       if fuco = FUNC_CODE_INST_BINOP then begin
        if rec1[4] > ord(high(binaryopcodesnames)) then begin
         error('Invalid binary opcode');
        end;
        str1:= binaryopcodesnames[binaryopcodes(rec1[4])];
       end
       else begin
        if rec1[4] > ord(high(predicatenames)) then begin
         error('Invalid predicate');
        end;
        str1:= predicatenames[predicate(rec1[4])];
       end;
       str1:= str1+ '('+opname(rec1[2])+','+opname(rec1[3])+')';
       i1:= typeid(rec1[2]);
       i2:= typeid(rec1[3]);
       if fuco = FUNC_CODE_INST_CMP then begin
        outssarecord(ord(das_1)*typeindexstep,str1);
       end
       else begin
        outssarecord(i1,str1);
       end;
       if not checktypeids(i1,i2) then begin
        incompatibletypeerror('Incompatible type',i1,i2);
       end;
      end;
      FUNC_CODE_INST_PHI: begin
       checkmindatalen(rec1,2);
       if odd(high(rec1)) then begin
        error('Invalid phi record');
       end;
       i1:= rec1[2];
       str1:= '[';
       i2:= 3;
       while i2 <= high(rec1) do begin
        decodesigned1(rec1[i2]);
        str1:= str1+inttostr(fssaindex-fparamcount-rec1[i2])+':'+
                                                  inttostr(rec1[i2+1])+',';
        if not checktypeids(typeid(rec1[i2]),i1) then begin
         outssarecord(i1,str1);
         error('Incompatible phi types');
         
        end;
        inc(i2,2);
       end;
       str1[length(str1)]:= ']';
       outssarecord(i1,str1);
      end;
      FUNC_CODE_INST_CAST: begin
       checkdatalen(rec1,4);
       str1:= castopcodesnames[castopcodes(rec1[4])]+
       '('+opname(rec1[2])+':'+ftypelist.typename(pointertypeid(rec1[2]))+')';
       i1:= rec1[3];
       outssarecord(i1,str1);
      end;
      FUNC_CODE_INST_GEP: begin
       checkmindatalen(rec1,4);
       if rec1[2] <> 0 then begin
        str1:= 'inbounds ';
       end
       else begin
        str1:= '';
       end;
       str1:= str1+opname(rec1[4])+'[';
       i2:= typeid(rec1[4]);
       for i1:= 5 to high(rec1) do begin
        str1:= str1+opname(rec1[i1])+',';
        i2:= ftypelist.itemtypeindex(i2);
       end;
       i3:= i2;
       if high(rec1) >= 5 then begin
        setlength(str1,length(str1)-1);
        i2:= i2 or pointermask; //pointer
       end;
       str1:= str1+']';
       outssarecord(i2,str1);
       if i3 <> rec1[3] then begin
        error('Invalid explicit type');
       end;
      end;
      FUNC_CODE_INST_STORE_OLD: begin
       checkmindatalen(rec1,3);
       i1:= typeid(rec1[2]); //dest
       i2:= typeid(rec1[3]); //source
       str1:= functioncodesnames[functioncodes(rec1[1])]+
               ': '+opname(rec1[2])+'^:= '+opname(rec1[3])+': '+
                                                 ftypelist.typename(i2);
       if high(rec1) > 3 then begin
        outoprecord(str1+' A',dynarraytovararray(copy(rec1,4,bigint)));
       end
       else begin
        outoprecord(str1,[]);
       end;
       if i2 < 0 then begin
        bo1:= ftypelist.parenttypeindex(ftypelist.parenttypeindex(i1)) <> -i2;
       end
       else begin
        bo1:= ftypelist.parenttypeindex(i1) <> i2;
       end;
       if bo1 then begin
        error('Invalid pointer type');
       end;
      end;
      FUNC_CODE_INST_STORE: begin  //  2  3     4      5
       checkdatalen(rec1,5);       //[ptr,val, align, vol]
       str1:= functioncodesnames[functioncodes(rec1[1])]+
               ': '+opname(rec1[2])+'^:= '+opname(rec1[3])+': ';
       i1:= pointerbasetypeid(rec1[2]); //dest
       i2:= pointertypeid(rec1[3]); //source
       str1:= str1+ftypelist.typename(i2);
       outoprecord(str1+' A',dynarraytovararray(copy(rec1,4,bigint)));
       if not ftypelist.sametype(i1,i2) then begin
        error('Not same type is:'+ftypelist.typename(i2)+
                           ' wanted:'+ftypelist.typename(i1));
       end;
      end;
      FUNC_CODE_INST_LOAD: begin
       checkmindatalen(rec1,2);
       outssarecord(pointerbasetypeid(rec1[2]),opname(rec1[2])+'^');
      end;
      FUNC_CODE_INST_ALLOCA: begin
       checkdatalen(rec1,5);
       if rec1[5] and (1 shl 6) = 0 then begin //no explicittype
        ftypelist.parenttypeindex(rec1[2]); //check pointer type
       end
       else begin
        rec1[2]:= rec1[2] or pointermask; //explicit type
       end;
       outssarecord(rec1[2],'@');
      end;
      FUNC_CODE_INST_RET: begin
       if high(rec1) = 2 then begin
        outoprecord(functioncodesnames[functioncodes(rec1[1])],
                                                           [opname(rec1[2])]);
       end
       else begin
        outoprecord(functioncodesnames[functioncodes(rec1[1])],
               dynarraytovararray(copy(rec1,2,bigint)));
       end;
       incbb();
      end;
      FUNC_CODE_INST_CALL,FUNC_CODE_INST_INVOKE: begin
       if fuco = FUNC_CODE_INST_INVOKE then begin
        checkmindatalen(rec1,6);
        i4:= 6;
        str1:= '->'+inttostr(rec1[4])+'->'+inttostr(rec1[5])+' ';
       end
       else begin
        checkmindatalen(rec1,4);
        i4:= 4;
        if (rec1[3] and (1 shl 15)) <> 0 then begin
         checkmindatalen(rec1,5);
         i4:= 5;
        end;
        str1:= '';
       end;
       po1:= ftypelist.parenttype(typeid(rec1[i4]));
       if po1^.kind <> TYPE_CODE_FUNCTION then begin
        error('Invalid sub');
       end;
       str1:= str1 + opname(rec1[i4])+':';
       i1:= absvalue(rec1[i4]);
       if (i1 >= 0) and (i1 < fgloblist.count) then begin
        with fgloblist.item(i1)^ do begin
         str1:= str1+inttostr(subheaderindex);
        end;
       end;
       with po1^ do begin
        i2:= subparamindex;    //result type
        i3:= subparamcount;
        vararg1:= subvararg;
       end;
       str1:= str1+'(';
       for i1:= i4+1 to high(rec1) do begin
        str1:= str1+opname(rec1[i1],ftypelist.fsubparams[i1-i4+i2])+',';
       end;
       if high(rec1) >= i4+1 then begin
        setlength(str1,length(str1)-1);
       end;
       str1:= str1+')';
       i1:= ftypelist.fsubparams[i2];
       bo1:= ftypelist.item(i1)^.kind <> TYPE_CODE_VOID;
       if bo1 then begin
        outssarecord(i1,str1);
        dec(fssaindex); //for parameter check
       end
       else begin
        outoprecord(functioncodesnames[functioncodes(rec1[1])],[' '+str1]);
       end;
       if (high(rec1)-i4+1 < i3) or (high(rec1)-i4+1 > i3) and 
                                                 not vararg1 then begin
        error('Invalid param count: '+
                  inttostr(high(rec1)-i4+1)+' should be: '+inttostr(i3));
       end;
       inc(i2); //first param
       for i1:= i4+1 to i3+3 do begin
        if not checktypeids(pointertypeid(rec1[i1]),
                                    ftypelist.fsubparams[i2]) then begin
         error('Invalid param '+inttostr(i1-i4-1)+
               ' is:'+ftypelist.typename(pointertypeid(rec1[i1]))+
               ' wanted:'+ftypelist.typename(ftypelist.fsubparams[i2]));
        end;
        inc(i2);
       end;
       if bo1 then begin
        inc(fssaindex); //restore
       end;
       if functioncodes(rec1[1]) = FUNC_CODE_INST_INVOKE then begin
        incbb();
       end;
      end;
      FUNC_CODE_INST_LANDINGPAD: begin
       checkmindatalen(rec1,4); //???
       outssarecord(rec1[2],{opname(rec1[3])+','+}inttostr(rec1[4]));
      end;
      FUNC_CODE_INST_LANDINGPAD_OLD: begin
       checkmindatalen(rec1,5);
       outssarecord(rec1[2],opname(rec1[3])+','+inttostr(rec1[4])+
                                                      ','+inttostr(rec1[5]));
      end;
      FUNC_CODE_INST_BR: begin
       checkmindatalen(rec1,2);
       if high(rec1) > 2 then begin
        checkdatalen(rec1,4);
        str1:=opname(rec1[4])+','+
                             destname(rec1[2])+','+destname(rec1[3]);
       end
       else begin
        str1:= destname(rec1[2]);
       end;
       outoprecord(functioncodesnames[functioncodes(rec1[1])],[' '+str1]);
       incbb();
      end;
      FUNC_CODE_DEBUG_LOC: begin
       checkdatalen(rec1,5);
       dec(rec1[4]);
       dec(rec1[5]);
       outrecord(' *',[rec1[2],rec1[3],'M'+inttostr(rec1[4]),rec1[5]]);
//       outrecord(' *',dynarraytovararray(copy(rec1,2,bigint)));
      end;
      FUNC_CODE_DEBUG_LOC_AGAIN: begin
       checkdatalen(rec1,1); //error
      end;
      else begin
       outrec();
//       outrecord(functioncodesnames[functioncodes(rec1[1])],
//                                 dynarraytovararray(copy(rec1,2,bigint)));
      end;
     end;
    end
    else begin
     case functioncodes(rec1[1]) of 
      FUNC_CODE_DEBUG_LOC_AGAIN: begin
       //no output
      end;
      else begin      
       outoprecord(functioncodesnames[functioncodes(rec1[1])],[]);
      end;
     end;
    end;
   end;
   inc(fopnum);
  end;
 end;
 inc(fopnum);
 fmetalist.count:= metacountbefore;
 fbb:= 0;
 fbbbefore:= 0;
 dec(ffunctionlevel);
end;

procedure tllvmbcreader.readparamattr(const akind: blockids);
var
 blocklevelbefore: int32;
 rec1: valuearty;
begin
 output(ok_begin,blockidnames[akind]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(attributecodesnames))) or 
             (attributecodesnames[attributecodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin 
    case attributecodes(rec1[1]) of
     PARAMATTR_CODE_ENTRY_OLD,
     PARAMATTR_CODE_ENTRY,
     PARAMATTR_GRP_CODE_ENTRY: begin
      checkmindatalen(rec1,1);
      outrecord(attributecodesnames[attributecodes(rec1[1])],
                                          [intvalueartostring(rec1,2)]);
     end;
     else begin
      unknownrec(rec1);
     end;
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readparamattrblock();
begin
 readparamattr(PARAMATTR_BLOCK_ID);
end;

procedure tllvmbcreader.readparamattrgroupblock();
begin
 readparamattr(PARAMATTR_GROUP_BLOCK_ID);
end;

procedure tllvmbcreader.readuselistblock();
var
 blocklevelbefore: int32;
 rec1: valuearty;
begin
 output(ok_begin,blockidnames[USELIST_BLOCK_ID]);
 blocklevelbefore:= fblocklevel;
 while not finished and (fblocklevel >= blocklevelbefore) do begin
  rec1:= readitem();
  if rec1 <> nil then begin
   if (rec1[1] > ord(high(uselistcodesnames))) or 
    (uselistcodesnames[uselistcodes(rec1[1])] = '') then begin
    unknownrec(rec1);
   end
   else begin
    case uselistcodes(rec1[1]) of
     USELIST_CODE_DEFAULT,USELIST_CODE_BB: begin
      outrecord(uselistcodesnames[uselistcodes(rec1[1])],
                            dynarraytovararray(copy(rec1,2,bigint)));
     end
     else begin
      unknownrec(rec1);
     end;
    end;
   end;
  end;
 end;
end;

procedure tllvmbcreader.readblockinfoblock();
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

 procedure skipblock();
 begin
  output(ok_beginend,blockidnames[blockids(blockid)]);
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
    with fblockstack[fblocklevel-2] do begin
     if (fblocklevel < 2) or (list = nil) then begin
      readconstantsblock(fgloblist);
     end
     else begin
      readconstantsblock(list);
     end;
    end;
   end;
   VALUE_SYMTAB_BLOCK_ID: begin
    readvaluesymtabblock();
   end;
   FUNCTION_BLOCK_ID: begin
    readfunctionblock();
   end;
   METADATA_BLOCK_ID: begin
    readmetadatablock();
   end;
   METADATA_KIND_BLOCK_ID: begin
    readmetadatakindblock();
   end;
   METADATA_ATTACHMENT_ID: begin
    readmetadataattachmentblock();
   end;
   PARAMATTR_BLOCK_ID: begin
    readparamattrblock();
   end;   
   PARAMATTR_GROUP_BLOCK_ID: begin
    readparamattrgroupblock();
   end;
   USELIST_BLOCK_ID: begin
    readuselistblock();
   end;
   IDENTIFICATION_BLOCK_ID: begin
    skipblock();
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
    with fblockstack[fblocklevel-1] do begin
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

 procedure wrappererror();
 begin
  error('Invalid bitcode wrapper header');
 end; //wrapererror
{ 
 procedure checkread(var buffer; const count: int32);
 begin
  if not (tryreadbuffer(buffer,count) = sye_ok) then begin
   wrappererror();
  end;
 end;
}
var
 ca1: card32;
 startoffset: int32;
 iswrapped: boolean;
begin
 reader:= self;
 fopnum:= 0;
 exitcode:= 1;
 iswrapped:= false;
 ca1:= read32();
 if ca1 = $0B17C0DE then begin
  iswrapped:= true;
  ca1:= read32();
  if ca1 <> 0 then begin
   wrappererror();
  end;
  startoffset:= read32(); //from file start
  fwrapsize:= read32();
  fwrapcpu:= read32();
  startoffset:= startoffset - sizeof(bc_header);
  if (startoffset < 0) or (startoffset mod 4 <> 0) then begin
   wrappererror();
  end;
  skip(startoffset div 4);
  ca1:= read32();
 end;
 if ca1 <> $dec04342 then begin
  error('Invalid magic number '+hextostr(ntobe(ca1),8));
 end;
 while not finished do begin
  readitem();
 end;
 writeln('Opcount: '+inttostr(fopnum));
 if iswrapped and (position <> 
                       fwrapsize + startoffset + sizeof(bc_header)) then begin
  wrappererror();
 end;
 exitcode:= 0;
 system.flush(system.output);
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
  result:= result or (valuety(ca1 and mask) shl valuety(i1));
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


end.
