{ MSEide Copyright (c) 2013 by Martin Schreiber
   
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
//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//
unit mseelements;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,msetypes;
{$define mse_debug_parser}

type
 identty = integer;
 elementoffsetty = integer;
 
 elementheaderty = record
  name: identty;
  parent: elementoffsetty; //offset in data array
 end;
 
 elementinfoty = record
  header: elementheaderty;
  data: record
  end;
 end;
 pelementinfoty = ^elementinfoty;
 
procedure clear;

function getident(const aname: lstringty): identty;
function pushelement(const aname: identty; 
                            const asize: integer): pelementinfoty;
function popelement: pelementinfoty;
function addelement(const aname: identty; 
           const asize: integer): pelementinfoty; //nil if duplicate
           
function dumpelements: msestringarty;

implementation
uses
 msehash,msearrayutils,sysutils;
 
type

 identoffsetty = integer;
 
 indexidentdataty = record
  key: identoffsetty; //index of null terminated string
  data: identty;
 end;
 pindexidentdataty = ^indexidentdataty;
 indexidenthashdataty = record
  header: hashheaderty;
  data: indexidentdataty;
 end;
 pindexidenthashdataty = ^indexidenthashdataty;
 
 tindexidenthashdatalist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create;
   function getident(aname: lstringty): identty;
 end;

 elementdataty = record
  key: identty;
  data: elementoffsetty;
 end;
 pelementdataty = ^elementdataty;
 elementhashdataty = record
  header: hashheaderty;
  data: elementdataty;
 end;
 pelementhashdataty = ^elementhashdataty;

 
 telementhashdatalist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create;
   procedure addelement(const aident: identty; const aelement: elementoffsetty);
   function findcurrent(const aident: identty): elementoffsetty;
                  //searches in current scope, -1 if not found
 end;

const
 mindatasize = 1024; 
var
 stringdata: string;
 stringindex,stringlen: identoffsetty;
 stringident: integer;
 identlist: tindexidenthashdatalist;
 elementlist: telementhashdatalist;

 elementdata: string;
 elementindex,elementlen: elementoffsetty;
 elementpath: integer; //sum of names in hierarchy 
 elementparent: integer;
{$ifdef mse_debug_parser}
 identnames: stringarty;
{$endif}

procedure clear;
begin
 identlist.clear;
 stringdata:= '';
 stringindex:= 0;
 stringlen:= 0;
 stringident:= 0;

 elementlist.clear;
 elementindex:= 0;
 elementlen:= 0;
 elementparent:= 0;
 elementpath:= 0;
{$ifdef mse_debug_parser}
 identnames:= nil;
{$endif}
end;

function dumpelements: msestringarty;
var
 int1,int2,int3: integer;
 po1: pelementinfoty;
 mstr1: msestring;
begin
 int1:= 0;
 int2:= 0;
 additem(result,'elementpath: '+inttostr(elementpath),int2);
 while int1 < elementindex do begin
  po1:= pelementinfoty(pointer(elementdata)+int1);
  mstr1:= inttostr(po1^.header.name)+' '+identnames[po1^.header.name-1];
  int3:= 0;
  while po1^.header.parent <> 0 do begin
   inc(int3);
   po1:= pelementinfoty(pointer(elementdata)+po1^.header.parent);
  end;
  mstr1:= charstring(msechar('.'),int3)+mstr1;
  additem(result,mstr1,int2);
  int1:= int1 + sizeof(elementinfoty);
 end;
 setlength(result,int2);
end;

function pushelement(const aname: identty; const asize: integer): pelementinfoty;
var
 ele1: elementoffsetty;
begin
 ele1:= elementindex;
 elementindex:= elementindex+asize;
 if elementindex >= elementlen then begin
  elementlen:= elementindex*2+mindatasize;
  setlength(elementdata,elementlen);
 end;
 result:= pointer(elementdata)+ele1;
 with result^.header do begin
  parent:= elementparent;
  name:= aname;
 end;
 elementparent:= ele1;
 elementpath:= elementpath+aname;
 elementlist.addelement(elementpath,ele1);
end;

function addelement(const aname: identty; 
           const asize: integer): pelementinfoty; //nil if duplicate
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= elementlist.findcurrent(aname);
 if ele1 < 0 then begin
  ele1:= elementindex;
  elementindex:= elementindex+asize;
  if elementindex >= elementlen then begin
   elementlen:= elementindex*2+mindatasize;
   setlength(elementdata,elementlen);
  end;
  result:= pointer(elementdata)+ele1;
  with result^.header do begin
   parent:= elementparent;
   name:= aname;
  end; 
  elementlist.addelement(elementpath+aname,ele1);
 end;
end;

function popelement: pelementinfoty;
begin
 result:= pelementinfoty(pointer(elementdata)+elementparent);
 elementparent:= result^.header.parent;
 elementpath:= elementpath - result^.header.name;
end;

function storestring(const astr: lstringty): integer; //offset from stringdata
var
 int1,int2: integer;
begin
{$ifdef mse_debug_parser}
 additem(identnames,lstringtostring(astr));
{$endif}
 int1:= stringindex;
 int2:= astr.len;
 stringindex:= stringindex+int2+1;
 if stringindex >= stringlen then begin
  stringlen:= stringindex*2+mindatasize;
  setlength(stringdata,stringlen);
  fillchar((pchar(pointer(stringdata))+int1)^,stringlen-int1,0);
 end;
 move(astr.po^,(pchar(pointer(stringdata))+int1)^,int2);
 result:= int1;
 inc(stringident); 
end;
 
function getident(const aname: lstringty): identty;
begin
 result:= identlist.getident(aname);
end;

const
 hashmask: array[0..7] of longword =
  (%10101010101010100101010101010101,
   %01010101010101011010101010101010,
   %11001100110011000011001100110011,
   %00110011001100111100110011001100,
   %01100110011001111001100110011000,
   %10011001100110000110011001100111,
   %11100110011001100001100110011001,
   %00011001100110011110011001100110
   );
   
function hashkey1(const akey: lstringty): hashvaluety;
var
 int1: integer;
 wo1: word;
 by1: byte;
 po1: pchar;
begin
 wo1:= hashmask[0];
 po1:= akey.po;
 for int1:= 0 to akey.len-1 do begin
  by1:= byte(po1[int1]);
  wo1:= ((wo1 + by1) xor by1);
 end;
 wo1:= (wo1 xor wo1 shl 7);
 result:= (wo1 or (longword(wo1) shl 16)) xor hashmask[akey.len and $7];
end;

function scramble1(const avalue: hashvaluety): hashvaluety; inline;
begin
 result:= ((avalue xor (avalue shl 8)) xor (avalue shl 16)) xor (avalue shl 24);
end;

{ tindexidenthashdatalist }

constructor tindexidenthashdatalist.create;
begin
 inherited create(sizeof(indexidentdataty));
end;

//todo: use scrambled ident for no hash in elementlist?

function tindexidenthashdatalist.getident(aname: lstringty): integer;
var
 po1: pindexidenthashdataty;
 ha1: hashvaluety;
begin
 ha1:= hashkey1(aname);
 po1:= pointer(internalfind(aname,ha1));
 if po1 = nil then begin
  po1:= pointer(internaladdhash(ha1));
  with po1^.data do begin
   key:= storestring(aname);
   data:= stringident;
  end;
 end;  
 result:= po1^.data.data;
end;

function tindexidenthashdatalist.hashkey(const akey): hashvaluety;
var
 po1,po2: pchar;
 wo1: word;
 by1: byte;
begin
 with indexidentdataty(akey) do begin
  po1:= pchar(pointer(stringdata))+key;
  po2:= po1;
  wo1:= hashmask[0];
  while true do begin
   by1:= byte(po1^);
   if by1 = 0 then begin
    break;
   end;
   wo1:= ((wo1 + by1) xor by1);
  end;
  wo1:= (wo1 xor wo1 shl 7);
  result:= (wo1 or (longword(wo1) shl 16)) xor hashmask[(po1-po2) and $7];
 end;
end;

function tindexidenthashdatalist.checkkey(const akey; const aitemdata): boolean;
var
 po1,po2: pchar;
 int1: integer;
begin
 result:= false;
 with lstringty(akey) do begin
  po1:= po;
  po2:= pchar(pointer(stringdata)) + indexidentdataty(aitemdata).key;
  for int1:= 0 to len-1 do begin
   if po1[int1] <> po2[int1] then begin
    exit;
   end;
  end;
  result:= po2[len] = #0;
 end;
end;

{ telementhashdatalist }

constructor telementhashdatalist.create;
begin
 inherited create(sizeof(elementdataty));
end;

function telementhashdatalist.hashkey(const akey): hashvaluety;
begin
 with elementdataty(akey) do begin
  result:= scramble1(key);
 end;
end;

function telementhashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= identty(akey) = elementdataty(aitemdata).key;
end;

procedure telementhashdatalist.addelement(const aident: identty;
                                       const aelement: elementoffsetty);
begin
 with pelementhashdataty(internaladdhash(scramble1(aident)))^.data do begin
  key:= aident;
  data:= aelement;
 end;
end;

function telementhashdatalist.findcurrent(
                                     const aident: identty): elementoffsetty;
var
 uint1: ptruint;
 po1: pelementhashdataty;
 hash1: hashvaluety;
 id1: identty;
begin
 result:= -1;
 if count > 0 then begin
  id1:= elementpath+aident;
  hash1:= scramble1(id1);
  uint1:= fhashtable[hash1 and fmask];
  if uint1 <> 0 then begin
   po1:= pelementhashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.data.key = id1) and 
         (pelementinfoty(pointer(elementdata)+
                   po1^.data.data)^.header.parent = elementparent) then begin
     break;
    end;
    if po1^.header.nexthash = 0 then begin
     exit;
    end;
    po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
   result:= po1^.data.data;
  end;
 end;
end;

initialization
 identlist:= tindexidenthashdatalist.create;
 elementlist:= telementhashdatalist.create;
 clear;
finalization
 identlist.free;
 elementlist.free;
end.
