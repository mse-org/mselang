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
 msestream,msetypes,llvmbitcodes,parserglob,elements;

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
  protected
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
   procedure emitvbr4(avalue: int32);
   procedure emitvbr5(avalue: int32);
   procedure emitvbr6(avalue: int32);
   procedure emitvbr8(avalue: int32);
   procedure emit8(const avalue: card8);
   procedure emitcode(const avalue: int32);
   procedure emitdata(const avalue: bcdataty);
   procedure emitdata(const avalues: array of pbcdataty);
   procedure emitrec(const id: int32; const data: array of int32);
//   procedure emitint32rec(const id: int32; const value: int32);
   procedure pad32();
   procedure emittypeid(const avalue: int32);
   procedure emitintconst(const avalue: int32);
   procedure emitdataconst(const avalue; const asize: int32);
  public
   constructor create(ahandle: integer); override;
   destructor destroy(); override;
   procedure start(const consts: tconsthashdatalist);
   procedure stop();
   procedure flushbuffer(); override;
   procedure beginblock(const id: blockids; const nestedidsize: int32);
   procedure endblock();
   function bitpos(): int32;
 end;
 
implementation
uses
 errorhandler,msesys,sysutils,msebits;

 //abreviations, made by createabbrev tool
 
type
 mabty = (
  mab_data = 4, //id (vbr 6), count (vbr 6), array (array), data (fixed 8)
  mab_int //id (vbr 6), value (vbr 6)
 );
const
 mabsdat: array[0..8] of card8 = (34,100,200,152,32,9,50,100,0);
 mabs: bcdataty = (bitsize: 65; data: @mabsdat);


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

procedure tllvmbcwriter.start(const consts: tconsthashdatalist);
var
 po1: ptypeallocinfoty;
 po2: pconstlistdataty;
 i1: int32;
 id1: int32;
begin
 write32(int32((uint32($dec0) shl 16) or (uint32(byte('C')) shl 8) or
                                                             uint32('B')));
                                //llvm ir signature
 beginblock(MODULE_BLOCK_ID,3);
 emitrec(ord(MODULE_CODE_VERSION),[1]);

 beginblock(BLOCKINFO_BLOCK_ID,3);
 emitrec(ord(BLOCKINFO_CODE_SETBID),[ord(CONSTANTS_BLOCK_ID)]);
 emitdata(mabs);
 endblock();
 if consts.typelist.count > 0 then begin
  beginblock(TYPE_BLOCK_ID_NEW,3);
  emitrec(ord(TYPE_CODE_NUMENTRY),[consts.typelist.count]);
  po1:= consts.typelist.first();
  for i1:= consts.typelist.count - 1 downto 0 do begin
   if po1^.kind in ordinalopdatakinds then begin
    if po1^.kind = das_pointer then begin
     emitrec(ord(TYPE_CODE_POINTER),[ord(das_8)]);
    end
    else begin
     emitrec(ord(TYPE_CODE_INTEGER),[po1^.size]);
    end;
   end
   else begin
    if po1^.kind in byteopdatakinds then begin
     emitrec(ord(TYPE_CODE_ARRAY),[po1^.size,ord(das_8)]);     
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
      else begin
      {$ifdef mse_checkinternalerror}
       internalerror(ie_bcwriter,'141216A');
      {$endif}
      end;
     end;
    end;
   end;
   po1:= consts.typelist.next();
  end;
  endblock(); 
  if consts.count > 0 then begin
   beginblock(CONSTANTS_BLOCK_ID,3);
   id1:= -1;
   po2:= consts.first;
   for i1:= 0 to consts.count-1 do begin
    if id1 <> po2^.typeid then begin
     id1:= po2^.typeid;
     emittypeid(id1);
    end;
    case databitsizety(po2^.typeid) of
     das_32: begin
      emitintconst(ptruint(po2^.header.buffer));
     end;
     else begin
     {$ifdef mse_checkinternalerror}
      if databitsizety(po2^.typeid) <= high(databitsizety) then begin
       internalerror(ie_bcwriter,'141220A');
      end;
     {$endif}
      emitdataconst(consts.absdata(po2^.header.buffer)^,po2^.header.buffersize);
     end;
    end;
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

procedure tllvmbcwriter.emit8(const avalue: card8);
begin
 fbitbuf:= fbitbuf or (avalue shl fbitpos);
 fbitpos:= fbitpos + 8;
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

procedure tllvmbcwriter.emitvbr4(avalue: int32);
var
 i1: int32;
begin
 repeat
  i1:= avalue and $7;
  if card32(avalue) - i1 <> 0 then begin
   i1:= i1 or $80;
  end;
  emit(4,i1);
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
  emit(5,i1);
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
  emit(6,i1);
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
  avalue:= card32(avalue) shr 8;
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

procedure tllvmbcwriter.emitrec(const id: int32; const data: array of int32);
var
 i1: int32;
begin
 emitcode(ord(UNABBREV_RECORD));
 emitvbr6(id);
 emitvbr6(length(data));
 for i1:= 0 to high(data) do begin
  emitvbr6(data[i1]);
 end;
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
 int1:= fblockstackpo^.startpos - 4; //address blocklen
 writeback32(int1,((fpos + (fbufpos - pointer(@fbuffer)) - int1)+3) div 4 - 1); 
                                     //word length without blocklen
 dec(fblockstackpo);
{$ifdef mse_checkinternalerror}
 if fblockstackpo < @fblockstack then begin
  internalerror(ie_bcwriter,'141213B');
 end;
{$endif}
 emitcode(ord(END_BLOCK));
 pad32();
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
 emitcode(ord(mab_int));
 emitvbr6(ord(CST_CODE_INTEGER));
 emitvbr6(avalue);
end;

procedure tllvmbcwriter.emittypeid(const avalue: int32);
begin
 emitcode(ord(mab_int));
 emitvbr6(ord(CST_CODE_SETTYPE));
 emitvbr6(avalue);
end;

procedure tllvmbcwriter.emitdataconst(const avalue; const asize: int32);
var
 po1,pe: pcard8;
 i1: int32;
begin
 emitcode(ord(mab_data));
 emitvbr6(ord(CST_CODE_AGGREGATE));
 emitvbr6(asize);
 po1:= @avalue;
 pe:= po1+asize;
 while po1 < pe do begin
  emit8(po1^);
  inc(po1);
 end;
end;

end.
