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
 msestream;

const
 bcwriterbuffersize = 16; //test flushbuffer, todo: make it bigger
 blockstacksize  = 256;

const
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
  
type
 blockstackinfoty = record
  idsize: integer;
  startpos: integer;
 end;
 pblockstackinfoty = ^blockstackinfoty;
 
 tllvmbcwriter = class(tmsefilestream)
  private
   fbuffer: array[0..bcwriterbuffersize-1] of byte;
   fbufend: pointer;
   fbufpos: pointer;
   fblockstack: array[0..blockstacksize-1] of blockstackinfoty;
   fblockstackpo: pblockstackinfoty;
   fblockstackendpo: pblockstackinfoty;
   fpos: integer;
  protected
   procedure write8(const avalue: int8);
   procedure write16(const avalue: int16);
   procedure write32(const avalue: int32);
   procedure writeback32(const avalue: int32; const apos: int32);
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure flushbuffer(); override;
   procedure beginblock(const id: blockidty; const nestedidsize: int32);
   procedure endblock();
 end;
 
implementation
uses
 errorhandler,msesys,sysutils;
 
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

//todo: check pointer alignment, endianess, currently littleendian only

procedure tllvmbcwriter.write8(const avalue: int8);
begin
 if fbufpos + 1 >= fbufend then begin
  flushbuffer();
  pint8(fbufpos)^:= avalue;
 end
 else begin
  pint8(fbufpos)^:= avalue;
 end;
 fbufpos:= fbufpos + 1;
end;

procedure tllvmbcwriter.write16(const avalue: int16);
begin
 if fbufpos + 2 >= fbufend then begin
  flushbuffer();
  pint16(fbufpos)^:= avalue;
 end
 else begin
  pint16(fbufpos)^:= avalue;
 end;
 fbufpos:= fbufpos + 2;
end;

procedure tllvmbcwriter.write32(const avalue: int32);
begin
 if fbufpos + 4 >= fbufend then begin
  flushbuffer();
  pint32(fbufpos)^:= avalue;
 end
 else begin
  pint32(fbufpos)^:= avalue;
 end;
 fbufpos:= fbufpos + 4;
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
 write32(0);
 dec(fblockstackpo);
{$ifdef mse_checkinternalerror}
 if fblockstackpo < @fblockstack then begin
  internalerror(ie_bcwriter,'141213B');
 end;
{$endif}
end;

end.
