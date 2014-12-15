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
unit llvmbcwriter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream,msetypes;

const
 bcwriterbuffersize = 16; //test flushbuffer, todo: make it bigger
 blockstacksize  = 256;

  // The standard abbrev namespace always has a way to exit a block, enter a
  // nested block, define abbrevs, and define an unabbreviated record.
 END_BLOCK = 0;  // Must be zero to guarantee termination for broken bitcode.
 ENTER_SUBBLOCK = 1;

 /// DEFINE_ABBREV - Defines an abbrev for the current block.  It consists
 /// of a vbr5 for # operand infos.  Each operand info is emitted with a
 /// single bit to indicate if it is a literal encoding.  If so, the value is
 /// emitted with a vbr8.  If not, the encoding is emitted as 3 bits followed
 /// by the info value as a vbr5 if needed.
 DEFINE_ABBREV = 2;

 // UNABBREV_RECORDs are emitted with a vbr6 for the record code, followed by
 // a vbr6 for the # operands, followed by vbr6's for each operand.
 UNABBREV_RECORD = 3;

 // This is not a code, this is a marker for the first abbrev assignment.
 FIRST_APPLICATION_ABBREV = 4;

type
  /// MODULE blocks have a number of optional fields and subblocks.
 modulecodety = (
    MODULE_CODE_VERSION     = 1,    // VERSION:     [version#]
    MODULE_CODE_TRIPLE      = 2,    // TRIPLE:      [strchr x N]
    MODULE_CODE_DATALAYOUT  = 3,    // DATALAYOUT:  [strchr x N]
    MODULE_CODE_ASM         = 4,    // ASM:         [strchr x N]
    MODULE_CODE_SECTIONNAME = 5,    // SECTIONNAME: [strchr x N]

    // FIXME: Remove DEPLIB in 4.0.
    MODULE_CODE_DEPLIB      = 6,    // DEPLIB:      [strchr x N]

    // GLOBALVAR: [pointer type, isconst, initid,
    //             linkage, alignment, section, visibility, threadlocal]
    MODULE_CODE_GLOBALVAR   = 7,

    // FUNCTION:  [type, callingconv, isproto, linkage, paramattrs, alignment,
    //             section, visibility, gc, unnamed_addr]
    MODULE_CODE_FUNCTION    = 8,

    // ALIAS: [alias type, aliasee val#, linkage, visibility]
    MODULE_CODE_ALIAS       = 9,

    // MODULE_CODE_PURGEVALS: [numvals]
    MODULE_CODE_PURGEVALS   = 10,

    MODULE_CODE_GCNAME      = 11   // GCNAME: [strchr x N]
  );


 cstcodety = (
  CST_CODE_SETTYPE       =  1,  // SETTYPE:       [typeid]
  CST_CODE_NULL          =  2,  // NULL
  CST_CODE_UNDEF         =  3,  // UNDEF
  CST_CODE_INTEGER       =  4,  // INTEGER:       [intval]
  CST_CODE_WIDE_INTEGER  =  5,  // WIDE_INTEGER:  [n x intval]
  CST_CODE_FLOAT         =  6,  // FLOAT:         [fpval]
  CST_CODE_AGGREGATE     =  7,  // AGGREGATE:     [n x value number]
  CST_CODE_STRING        =  8,  // STRING:        [values]
  CST_CODE_CSTRING       =  9,  // CSTRING:       [values]
  CST_CODE_CE_BINOP      = 10,  // CE_BINOP:      [opcode, opval, opval]
  CST_CODE_CE_CAST       = 11,  // CE_CAST:       [opcode, opty, opval]
  CST_CODE_CE_GEP        = 12,  // CE_GEP:        [n x operands]
  CST_CODE_CE_SELECT     = 13,  // CE_SELECT:     [opval, opval, opval]
  CST_CODE_CE_EXTRACTELT = 14,  // CE_EXTRACTELT: [opty, opval, opval]
  CST_CODE_CE_INSERTELT  = 15,  // CE_INSERTELT:  [opval, opval, opval]
  CST_CODE_CE_SHUFFLEVEC = 16,  // CE_SHUFFLEVEC: [opval, opval, opval]
  CST_CODE_CE_CMP        = 17,  // CE_CMP:        [opty, opval, opval, pred]
  CST_CODE_INLINEASM_OLD = 18,  // INLINEASM:     [sideeffect|alignstack,
                                //                 asmstr,conststr]
  CST_CODE_CE_SHUFVEC_EX = 19,  // SHUFVEC_EX:    [opty, opval, opval, opval]
  CST_CODE_CE_INBOUNDS_GEP = 20,// INBOUNDS_GEP:  [n x operands]
  CST_CODE_BLOCKADDRESS  = 21,  // CST_CODE_BLOCKADDRESS [fnty, fnval, bb#]
  CST_CODE_DATA          = 22,  // DATA:          [n x elements]
  CST_CODE_INLINEASM     = 23   // INLINEASM:     [sideeffect|alignstack|
                                //                 asmdialect,asmstr,conststr]
 );

 blockidty = (
    /// BLOCKINFO_BLOCK is used to define metadata about blocks, for example,
    /// standard abbrevs that should be available to all blocks of a specified
    /// ID.
    BLOCKINFO_BLOCK_ID = 0,

    // Block IDs 1-7 are reserved for future expansion.
//    FIRST_APPLICATION_BLOCKID = 8,

  // The only top-level block type defined is for a module.
    // Blocks
    MODULE_BLOCK_ID          = 8{= FIRST_APPLICATION_BLOCKID},

    // Module sub-block id's.
    PARAMATTR_BLOCK_ID,
    PARAMATTR_GROUP_BLOCK_ID,

    CONSTANTS_BLOCK_ID,
    FUNCTION_BLOCK_ID,

    UNUSED_ID1,

    VALUE_SYMTAB_BLOCK_ID,
    METADATA_BLOCK_ID,
    METADATA_ATTACHMENT_ID,

    TYPE_BLOCK_ID_NEW,

    USELIST_BLOCK_ID
 );
 
   /// BlockInfoCodes - The blockinfo block contains metadata about user-defined
  /// blocks.
  blockinfocodety = (
    // DEFINE_ABBREV has magic semantics here, applying to the current SETBID'd
    // block, instead of the BlockInfo block.

    BLOCKINFO_CODE_SETBID        = 1, // SETBID: [blockid#]
    BLOCKINFO_CODE_BLOCKNAME     = 2, // BLOCKNAME: [name]
    BLOCKINFO_CODE_SETRECORDNAME = 3  // BLOCKINFO_CODE_SETRECORDNAME:
                                      //                             [id, name]
  );

{ 
 blockidty = (
    BLOCKINFO_BLOCK_ID,
    res1_block_id,
    res2_block_id,
    res3_block_id,
    res4_block_id,
    res5_block_id,
    res6_block_id,
    res7_block_id,
    MODULE_BLOCK_ID,

    // Module sub-block id's.
    PARAMATTR_BLOCK_ID,
    PARAMATTR_GROUP_BLOCK_ID,

    CONSTANTS_BLOCK_ID,
    FUNCTION_BLOCK_ID,

    UNUSED_ID1,

    VALUE_SYMTAB_BLOCK_ID,
    METADATA_BLOCK_ID,
    METADATA_ATTACHMENT_ID,

    TYPE_BLOCK_ID_NEW,

    USELIST_BLOCK_ID
 );
}  
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
  protected
  {$ifdef mse_checkinternalerror}
   procedure checkalignment(const bytes: integer);
  {$endif}
   procedure write8(const avalue: int8);
   procedure write16(const avalue: int16);
   procedure write32(const avalue: int32);
   procedure write64(const avalue: int64);
   procedure writeback32(const avalue: int32; const apos: int32);
   procedure writeint32rec(const id: int32; const value: int32);
//   procedure writeabbrev();
   procedure checkbitflush();
   procedure emit(const asize: integer; const avalue: int32);
   procedure emit5(const avalue: card8);
   procedure emit6(const avalue: card8);
   procedure emit8(const avalue: card8);
   procedure emitvbr5(avalue: int32);
   procedure emitvbr6(avalue: int32);
   procedure emitvbr8(avalue: int32);
   procedure emitdata(const avalue: bcdataty);
   procedure pad32();
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure flushbuffer(); override;
   procedure beginblock(const id: blockidty; const nestedidsize: int32);
   procedure endblock();
   function bitpos(): int32;
 end;
 
implementation
uses
 errorhandler,msesys,sysutils,msebits;

type
 mlaabbrevty = (mab_card);
 
const
 mabcardbitsize = 6;
 mabcard: array[0..mabcardbitsize-1] of card8 = (
  0,1,2,3,4,5
 );
 
 mlaabbrevs: array[mlaabbrevty] of bcdataty = (
  (bitsize: mabcardbitsize; data: @mabcard)
 ); 
//type
// mlablockty = (mlb_internalconst);
{ tllvmbcwriter }

constructor tllvmbcwriter.create(ahandle: integer);
begin
 fbufpos:= @fbuffer;
 fbufend:= fbufpos + bcwriterbuffersize;
 fblockstackpo:= @fblockstack;
 fblockstackendpo:= fblockstackpo + blockstacksize;
 fblockstackpo^.idsize:= 2; //start default
 inherited;
 write32(int32((uint32($dec0) shl 16) or (uint32(byte('C')) shl 8) or
                                                             uint32('B')));
                                //llvm ir signature
 beginblock(MODULE_BLOCK_ID,3);
 beginblock(BLOCKINFO_BLOCK_ID,3);
 emitdata(mlaabbrevs[mab_card]);
// writeint32rec(ord(BLOCKINFO_CODE_SETBID),ord(CONSTANTS_BLOCK_ID));
 endblock();
 
end;

destructor tllvmbcwriter.destroy();
begin
 endblock();
{$ifdef mse_checkinternalerror}
 if fblockstackpo <> @fblockstack then begin
  internalerror(ie_bcwriter,'141213C');
 end;
{$endif}
 inherited;
end;

{$ifdef mse_checkinternalerror}
procedure tllvmbcwriter.checkalignment(const bytes: integer);
begin
 if fbitpos <> 0 then begin
  internalerror(ie_bcwriter,'141214A');
 end;
 if (fbufpos - pointer(@fbuffer)) mod bytes <> 0 then begin
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

procedure tllvmbcwriter.emit(const asize: integer; const avalue: int32);
begin
{$ifdef mse_checkinternalerror}
 if (asize < 0) or (asize > 8) then begin
  internalerror(ie_bcwriter,'141213D');
 end;
 if avalue and not bitmask[asize] <> 0 then begin
  internalerror(ie_bcwriter,'141213E');
 end;
{$endif}
 fbitbuf:= fbitbuf shl asize or avalue;
 fbitpos:= fbitpos + asize;
 if fbitpos >= 8 then begin
  fbitpos:= fbitpos - 8;
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf shr fbitpos;
  fbufpos:= fbufpos + 1;
 end; 
end;

procedure tllvmbcwriter.checkbitflush();
begin
 if fbitpos >= 8 then begin
  fbitpos:= fbitpos - 8;
  if fbufpos + 1 >= fbufend then begin
   flushbuffer();
  end;
  pint8(fbufpos)^:= fbitbuf shr fbitpos;
  fbufpos:= fbufpos + 1;
 end;
end;

procedure tllvmbcwriter.emit5(const avalue: card8);
begin
{$ifdef mse_checkinternalerror}
 if avalue and not $1f <> 0 then begin
  internalerror(ie_bcwriter,'141213C');
 end;
{$endif}
 fbitbuf:= fbitbuf shl 5 or avalue;
 fbitpos:= fbitpos + 5;
 checkbitflush();
end;

procedure tllvmbcwriter.emit6(const avalue: card8);
begin
{$ifdef mse_checkinternalerror}
 if avalue and not $3f <> 0 then begin
  internalerror(ie_bcwriter,'141213C');
 end;
{$endif}
 fbitbuf:= fbitbuf shl 6 or avalue;
 fbitpos:= fbitpos + 6;
 checkbitflush();
end;

procedure tllvmbcwriter.emit8(const avalue: card8);
begin
 fbitbuf:= (fbitbuf shl 8) or avalue;
 if fbufpos + 1 >= fbufend then begin
  flushbuffer();
 end;
 pint8(fbufpos)^:= fbitbuf shr fbitpos;
 fbufpos:= fbufpos + 1;
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
  emit8(i1);
  avalue:= card32(avalue) shr 8;
 until avalue = 0;
end;

procedure tllvmbcwriter.pad32;
begin
 if fbufpos + 4 >= fbufend then begin
  flushbuffer();
 end;
 if fbitpos <> 0 then begin
  emit(8-fbitpos,0);  
 end;
 while ptruint(fbufpos) and $3 <> 0 do begin
  pcard8(fbufpos)^:= 0;
  inc(fbufpos);
 end;
end;

procedure tllvmbcwriter.emitdata(const avalue: bcdataty);
var
 po1,pe: pcard8;
begin
 po1:= avalue.data;
 pe:= po1 + avalue.bitsize div 8;
 while po1 < pe do begin
  emit8(po1^);
  inc(po1);
 end;
 emit(avalue.bitsize and $7,po1^);
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

procedure tllvmbcwriter.writeback32(const avalue: int32; const apos: int32);
begin
 if (apos < fpos) then begin
  flushbuffer();              //not in buffer
  position:= apos;
  writebuffer(avalue,4);
  position:= fpos;
 end
 else begin
  if (fbufpos + 4 >= fbufend) then begin
   flushbuffer();
  end;
  pint32(pointer(@fbuffer) + apos - fpos)^:= avalue;                                                            
 end;
end;

procedure tllvmbcwriter.writeint32rec(const id: int32; const value: int32);
begin
end;

type
 beginblockrecord = record //         4      8   fblockidsize
  header: uint32;          //    nextidsize id ENTER_SUBBLOCK
  blocklen: uint32;
 end;
 pbeginblockrecord = ^beginblockrecord;
 
procedure tllvmbcwriter.beginblock(const id: blockidty;
                                       const nestedidsize: int32);
begin
 if fbufpos + sizeof(beginblockrecord) >= fbufend then begin
  flushbuffer();
 end;
 pbeginblockrecord(fbufpos)^.header:= 
    ENTER_SUBBLOCK or (int32(id) shl fblockstackpo^.idsize) or 
                                 (nestedidsize shl (fblockstackpo^.idsize + 8));
 fbufpos:= fbufpos + sizeof(beginblockrecord);

 inc(fblockstackpo);
 if fblockstackpo >= fblockstackendpo then begin
  internalerror1(ie_bcwriter,'141213A'); //stack overflow
 end;
 fblockstackpo^.idsize:= nestedidsize;
 fblockstackpo^.startpos:= fpos + (fbufpos - pointer(@fbuffer));
end;

procedure tllvmbcwriter.endblock;
var
 int1,int2: integer;
begin
 int1:= fblockstackpo^.startpos - 4; //address blocklen
 writeback32((fpos + (fbufpos - pointer(@fbuffer)) - int1) div 4 - 1,int1); 
                                     //word length without blocklen
 emit(fblockstackpo^.idsize,0);
 pad32();
// write32(0);
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

end.
