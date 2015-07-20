{ MSElang Copyright (c) 2013-2015 by Martin Schreiber
   
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
unit identutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,msehash,msestrings;
 
type
 identheaderty = record
  ident: identty;
 end;
 pidentheaderty = ^identheaderty;

 tidenthashdatalist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create(const asize: int32); 
                    //total datasize including identheaderty
   function adduniquedata(const akey: identty; out adata: pointer): boolean;
                              //false if duplicate
 end;
  
function getident(): identty; overload;
function getident(const astart,astop: pchar): identty; overload;
function getident(const aname: lstringty): identty; overload;
function getident(const aname: pchar; const alen: integer): identty; overload;
function getident(const aname: string): identty; overload;

function getidentname(const aident: identty; out name: lstringty): boolean;
                             //true if found
function getidentname(const aident: identty): string;

procedure clear();
procedure init();
      
implementation
uses
 mselfsr,parserglob;
type
 identoffsetty = int32;
 
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

 identdataty = record
  header:identheaderty;
  keyname: identoffsetty;
  keylen: integer;
 end;
 identhashdataty = record
  header: hashheaderty;
  data: identdataty;
 end;
 pidenthashdataty = ^identhashdataty;

 tindexidenthashdatalist = class(thashdatalist)
// {$ifdef mse_debugparser}
  private
   fidents: tidenthashdatalist;
// {$endif}
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create;
   destructor destroy; override;
   procedure clear; override;
   function identname(const aident: identty; out aname: lstringty): boolean;
   function getident(const aname: lstringty): identty;
 end;

var
 stringident: identty;
 identlist: tindexidenthashdatalist;
 stringindex,stringlen: identoffsetty;
 stringdata: string;

const
 mindatasize = 1024; 

procedure nextident;
begin
 repeat
  lfsr321(stringident);
 until stringident >= firstident;
end;

function getident(): identty;
begin
 result:= stringident;
 nextident; 
end;
 
function getident(const aname: lstringty): identty;
begin
 result:= identlist.getident(aname);
end;

function getident(const aname: pchar; const alen: integer): identty;
var
 lstr1: lstringty;
begin
 lstr1.po:= aname;
 lstr1.len:= alen;
 result:= identlist.getident(lstr1);
end;

function getident(const astart,astop: pchar): identty;
var
 lstr1: lstringty;
begin
 lstr1.po:= astart;
 lstr1.len:= astop-astart;
 result:= identlist.getident(lstr1);
end;

function getident(const aname: string): identty;
var
 lstr1: lstringty;
begin
 lstr1.po:= pointer(aname);
 lstr1.len:= length(aname);
 result:= identlist.getident(lstr1);
end;

function getidentname(const aident: identty; out name: lstringty): boolean;
                             //true if found
begin
 result:= identlist.identname(aident,name);
end;

function getidentname(const aident: identty): string;
var
 lstr1: lstringty;
begin
 if getidentname(aident,lstr1) then begin
  result:= lstringtostring(lstr1);
 end
 else begin
  result:= '°';
 end;
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

function storestring(const astr: lstringty): integer; //offset from stringdata
var
 int1,int2: integer;
begin
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
 nextident;
end;

procedure clear();
begin
 identlist.clear;
 stringdata:= '';
 stringindex:= 0;
 stringlen:= 0;
 stringident:= 0;
end;

procedure init();
begin
 stringident:= idstart; //invalid
 nextident();
end;

{ tidenthashdatalist }

constructor tidenthashdatalist.create(const asize: int32);
begin
 inherited create(asize);
end;

function tidenthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= identty(akey);
end;

function tidenthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= identty(akey) = identheaderty(aitemdata).ident;
end;

function tidenthashdatalist.adduniquedata(const akey: identty;
                                         out adata: pointer): boolean;
begin
 adata:= internalfind(akey);
 result:= adata = nil;
 if result then begin
  adata:= addr(internaladd(akey)^.data);
  pidentheaderty(adata)^.ident:= akey;
 end
 else begin
  inc(adata,sizeof(hashheaderty));
 end;
end;

{ tindexidenthashdatalist }

constructor tindexidenthashdatalist.create;
begin
 inherited create(sizeof(indexidentdataty));
 fidents:= tidenthashdatalist.create(sizeof(identdataty));
end;

destructor tindexidenthashdatalist.destroy;
begin
 inherited;
 fidents.free;
end;

procedure tindexidenthashdatalist.clear;
begin
 inherited;
 fidents.clear;
end;

function tindexidenthashdatalist.identname(const aident: identty;
                   out aname: lstringty): boolean;
var
 po1: pidenthashdataty;
begin
 po1:= pidenthashdataty(fidents.internalfind(aident,aident));
 if po1 <> nil then begin
  result:= true;
  aname.po:= pchar(stringdata)+po1^.data.keyname;
  aname.len:= po1^.data.keylen;
 end
 else begin
  result:= false;
  aname.po:= nil;
  aname.len:= 0;
 end;
end;

function tindexidenthashdatalist.getident(const aname: lstringty): identty;
var
 po1: pindexidenthashdataty;
 ha1: hashvaluety;
begin
 ha1:= hashkey1(aname);
 po1:= pointer(internalfind(aname,ha1));
 if po1 = nil then begin
  po1:= pointer(internaladdhash(ha1));
  with po1^.data do begin
   data:= stringident;
   key:= storestring(aname);
   with pidenthashdataty(fidents.internaladdhash(data))^.data do begin
    header.ident:= data;
    keyname:= key;
    keylen:= aname.len;
   end;
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

initialization
 identlist:= tindexidenthashdatalist.create;
finalization
 identlist.free();
end.