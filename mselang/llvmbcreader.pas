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
 msestream,classes,mclasses,msetypes,msestrings;
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
  protected
   procedure error(const message: string);
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
   function readitem(): valuearty;
          //nil if internal read, first array item = code
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
   procedure skip(const words: int32);
  public
   constructor create(ahandle: integer); override;
   procedure dump(const aoutput: tstream);
 end;
 
implementation
uses
 msebits,sysutils,mseformatstr,llvmbitcodes,msearrayutils;

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
 
{ tllvmbcreader }

constructor tllvmbcreader.create(ahandle: integer);
begin
 inherited;
 fbufpos:= @fbuffer;
 fbufend:= fbufpos;
 fillbuffer();
 fbitbuf:= fbufpos^;
 inc(fbufpos);
 fidsize:= 2;
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
 i1: int32;
begin
 output(ok_begin,blockidnames[MODULE_BLOCK_ID]);
 i1:= fblocklevel;
 while not finished and (fblocklevel >= i1) do begin
  readitem();
 end;
end;

procedure tllvmbcreader.readblockinfoblock;
var
 i1: int32;
 val1: valuearty;
 str1: string;
begin
 output(ok_begin,blockidnames[BLOCKINFO_BLOCK_ID]);
 i1:= fblocklevel;
 while not finished and (fblocklevel >= i1) do begin
  val1:= readitem();
  if val1 <> nil then begin
   case blockinfocodes(val1[0]) of
    BLOCKINFO_CODE_SETBID: begin
     checkdatalen(val1,1);
     fblockinfoid:= val1[1];
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
     unknownrec(val1);
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
   else begin
    unknownblock();
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
   allocuninitedarray(numops+1,sizeof(result[0]),result);   
   result[0]:= code;
   for i1:= 1 to numops do begin
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
   error('Unknown abbrev');
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

procedure tllvmbcreader.error(const message: string);
begin
 raise exception.create(message+'.');
end;

procedure tllvmbcreader.outrecord(const aname: string;
               const values: array of const);
var
 str1: string;
 i1: int32;
begin
 str1:= '';
 for i1:= 0 to high(values) do begin
  str1:= tvarrectoansistring(values[i1])+',';
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
 for i1:= 1 to high(arec) do begin
  str1:= inttostr(arec[i1])+',';
 end;
 if str1 <> '' then begin
  setlength(str1,length(str1)-1);
 end;
 output(ok_beginend,'UNKNOWN_REC'+inttostr(arec[0])+':'+str1);
end;

end.
