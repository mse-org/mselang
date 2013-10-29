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
 msestrings,msetypes,msehash,mseparserglob;

{$define mse_debug_parser}

const
 maxidentvector = 200;
type
 identarty = integerarty;
 identvectorty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;
 elementoffsetaty = array[0..0] of elementoffsetty;
 pelementoffsetaty = ^elementoffsetaty;
 
 elementkindty = (ek_none,{ek_context,}ek_type,ek_const,ek_var,
                  ek_sysfunc,ek_func,ek_classes,ek_class,
                  ek_unit,ek_implementation);
 
 elementheaderty = record
  size: integer; //for debugging
  name: identty;
  path: identty;
  parent: elementoffsetty; //offset in data array
  parentlevel: integer;
  kind: elementkindty;
  vislevel: vislevelty;
 end;
 
 elementinfoty = record
  header: elementheaderty;
  data: record
  end;
 end;
 pelementinfoty = ^elementinfoty;
 
const
 elesize = sizeof(elementinfoty);

type
 telementhashdatalist = class(thashdatalist)
  protected
   felementdata: string;
   fnextelement: elementoffsetty;
   felementlen: elementoffsetty;
   felementpath: identty; //sum of names in hierarchy 
   felementparent: elementoffsetty;
   fparentlevel: integer;
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
   procedure addelement(const aident: identty; const avislevel: vislevelty;
                                              const aelement: elementoffsetty);
   procedure setelementparent(const element: elementoffsetty);
  public
   constructor create;
   procedure clear; override;
   function findcurrent(const aident: identty;
                              const avislevel: vislevelty): elementoffsetty;
                  //searches in current scope, -1 if not found
   function findupward(const aident: identty;
                  const avislevel: vislevelty): elementoffsetty; overload;
                  //searches in current scope and above, -1 if not found
   function findupward(const aidents: identvectorty;
                  const avislevel: vislevelty): elementoffsetty; overload;
                  //searches in current scope and above, -1 if not found

   function eledatarel(const adata: pointer): elementoffsetty; inline;
   function eledataabs(const adata: elementoffsetty): pointer; inline;

   function dumpelements: msestringarty;
   function dumppath(const aelement: pelementinfoty): msestring;

   function pushelement(const aname: identty; const avislevel: vislevelty;
                  const akind: elementkindty;
                  const asize: integer): pelementinfoty; //nil if duplicate
   function pushelement(const aname: identty; const avislevel: vislevelty;
                  const akind: elementkindty;                  
                  const asize: integer; out aelementdata: pointer): boolean;
                                                       //false if duplicate
   function popelement: pelementinfoty;
   function addelement(const aname: identty; const avislevel: vislevelty;
              const akind: elementkindty;              
              const asize: integer): pelementinfoty;   //nil if duplicate
   function addelement(const aname: identty; const avislevel: vislevelty;
              const akind: elementkindty;
              const asize: integer; out aelementdata: pointer): boolean;
                                                       //false if duplicate
   
   function findelement(const aname: identty;
                          const avislevel: vislevelty): pelementinfoty;
                                               //nil if not found
   function findelementupward(const aname: identty;
                          const avislevel: vislevelty): pelementinfoty; overload;
                                                       //nil if not found
   function findelementupward(const aname: identty;
                          const avislevel: vislevelty;
                        out element: elementoffsetty): pelementinfoty; overload;
                                                       //nil if not found
   function findelementsupward(const anames: identvectorty;
                          const avislevel: vislevelty;
                        out element: elementoffsetty): pelementinfoty;
                                                       //nil if not found
   function findelementsupward(const anames: identarty;
                          const avislevel: vislevelty;
                        out element: elementoffsetty): pelementinfoty;
                                                       //nil if not found
   function decelementparent: elementoffsetty; //returns old offset
   procedure markelement(out ref: markinfoty);
   procedure releaseelement(const ref: markinfoty);
   //function elementcount: integer;
   property elementparent: elementoffsetty read felementparent 
                                                 write setelementparent;
 end;
 
procedure clear;
procedure init;

function getident(const astart,astop: pchar): identty; overload;
function getident(const aname: lstringty): identty; overload;
function getident(const aname: pchar; const alen: integer): identty; overload;
function getident(const aname: string): identty; overload;

//function scramble1(const avalue: hashvaluety): hashvaluety; inline;

var
 elements: telementhashdatalist;

implementation
uses
 msearrayutils,sysutils,typinfo,mselfsr,grammar;
 
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

 
const
 mindatasize = 1024; 
var
 stringdata: string;
 stringindex,stringlen: identoffsetty;
 stringident: identty;
 identlist: tindexidenthashdatalist;

{$ifdef mse_debug_parser}
 identnames: stringarty;
{$endif}

function telementhashdatalist.eledatarel(const adata: pointer): elementoffsetty;
begin
 result:= adata-pointer(felementdata);
end;

function telementhashdatalist.eledataabs(const adata: elementoffsetty): pointer;
begin
 result:= pointer(adata+pointer(felementdata));
end;

procedure clear;
begin
 identlist.clear;
 stringdata:= '';
 stringindex:= 0;
 stringlen:= 0;

 elements.clear;
{$ifdef mse_debug_parser}
 identnames:= nil;
{$endif}
 stringident:= 0;
end;

procedure init;
var
 int1: integer;
 tk1: integer;
begin
 clear;
 elements.pushelement(getident(''),vis_max,ek_none,elesize); //root
 stringident:= idstart; //invalid
 lfsr321(stringident);
 for tk1:= 1 to high(tokens) do begin
  getident(tokens[tk1]);
 end;
end;

type
 dumpinfoty = record
  text: msestring;
  offset: elementoffsetty;
  parent: elementoffsetty;
  parents: array[0..255] of elementoffsetty;
  parentlevel: integer;
 end;
 dumpinfoarty = array of dumpinfoty;

function compdump(const l,r): integer;
var
 int1: integer;
 int2: integer;
 levell,levelr: integer;
begin
 result:= 0;
// if dumpinfoty(l).parent = dumpinfoty(r).offset then begin
//  inc(result);
// end;
// if dumpinfoty(r).parent = dumpinfoty(l).offset then begin
//  dec(result);
// end;
 levell:= dumpinfoty(l).parentlevel;
 levelr:= dumpinfoty(r).parentlevel;
 int1:= levell;
 if int1 > levelr then begin
  int1:= levelr;
 end;
 int2:= int1;
 for int1:= 0 to int2 do begin
  result:= dumpinfoty(l).parents[int1]-dumpinfoty(r).parents[int1];
  if result <> 0 then begin
   break;
  end;
 end;
 if result = 0 then begin
  if levell > levelr then begin
   result:= dumpinfoty(l).parents[int2+1]-dumpinfoty(r).offset;
  end
  else begin
   if levelr > levell then begin
    result:= dumpinfoty(l).parents[int2+1]-dumpinfoty(r).offset;
   end;
  end;
 end;
end;

function telementhashdatalist.dumpelements: msestringarty;
var
 int1,int2,int3,int4,int5,int6: integer;
 po1: pelementinfoty;
 mstr1: msestring;
 ar1: dumpinfoarty;
 off1: elementoffsetty;
begin
 int1:= 0;
 int2:= 0;
 int5:= pelementinfoty(pointer(felementdata))^.header.name; //root
 while int1 < fnextelement do begin
  additem(ar1,typeinfo(dumpinfoty),int2);
  po1:= pelementinfoty(pointer(felementdata)+int1);
  off1:= int1;
  if pointer(po1)-pointer(felementdata) = felementparent then begin
   mstr1:= '*';
  end
  else begin
   mstr1:= ' ';
  end;
  mstr1:= mstr1+'P:'+inttostr(po1^.header.parent)+' O:'+inttostr(int1)+' N:'+
            inttostr(po1^.header.name)+' '+
            ' '+identnames[po1^.header.name] + 
            ' V:'+inttostr(ord(po1^.header.vislevel))+' '+
            getenumname(typeinfo(po1^.header.kind),ord(po1^.header.kind));
  int4:= 0;
  int1:= int1 + po1^.header.size;
  with ar1[int2-1] do begin
   parent:= po1^.header.parent;
   int3:= po1^.header.parentlevel;
   parentlevel:= int3;
   parents[int3]:= off1;
   for int6:= int3-1 downto 0 do begin
    parents[int6]:= po1^.header.parent;
    int4:= int4 + po1^.header.name;
    po1:= pelementinfoty(pointer(felementdata)+po1^.header.parent);
   end;
   mstr1:= charstring(msechar('.'),int3-1)+' '+
                          inttostr(int5+int4+po1^.header.name)+' '+mstr1;
   text:= mstr1;
   offset:= off1;
  end;
 end;
 setlength(ar1,int2);
 sortarray(ar1,sizeof(ar1[0]),@compdump);
 setlength(result,int2+1);
 result[0]:= 'elementpath: '+inttostr(felementpath);
 for int1:= 0 to int2-1 do begin
  result[int1+1]:= ar1[int1].text;
 end;
end;

function telementhashdatalist.dumppath(const aelement: pelementinfoty): msestring;
var
 po1: pelementinfoty;
begin
 result:= '';
 po1:= aelement;
 result:= identnames[po1^.header.name-1];
 while po1^.header.parent <> 0 do begin
  po1:= pointer(felementdata)+po1^.header.parent;
  result:= identnames[po1^.header.name-1]+'.'+result;
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
             const avislevel: vislevelty; const akind: elementkindty;
                                        const asize: integer): pelementinfoty;
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= findcurrent(aname,avislevel);
 if ele1 < 0 then begin
  ele1:= fnextelement;
  fnextelement:= fnextelement+asize;
  if fnextelement >= felementlen then begin
   felementlen:= fnextelement*2+mindatasize;
   setlength(felementdata,felementlen);
  end;
  result:= pointer(felementdata)+ele1;
  with result^.header do begin
   size:= asize; //for debugging
   parent:= felementparent;
   parentlevel:= fparentlevel;
   path:= felementpath;
   name:= aname;
   vislevel:= avislevel;
   kind:= akind;
  end;
  felementparent:= ele1;
  inc(fparentlevel);
  felementpath:= felementpath+aname;
  addelement(felementpath,avislevel,ele1);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
           const avislevel: vislevelty; const akind: elementkindty;
           const asize: integer; out aelementdata: pointer): boolean;
                                                    //false if duplicate
begin
 aelementdata:= pushelement(aname,avislevel,akind,asize);
 result:= aelementdata <> nil;
 if result then begin
  aelementdata:= @(pelementinfoty(aelementdata)^.data);
 end;
end;

function telementhashdatalist.addelement(const aname: identty;
              const avislevel: vislevelty; const akind: elementkindty;
              const asize: integer): pelementinfoty;   
                                                   //nil if duplicate
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= findcurrent(aname,avislevel);
 if ele1 < 0 then begin
  ele1:= fnextelement;
  fnextelement:= fnextelement+asize;
  if fnextelement >= felementlen then begin
   felementlen:= fnextelement*2+mindatasize;
   setlength(felementdata,felementlen);
  end;
  result:= pointer(felementdata)+ele1;
  with result^.header do begin
   size:= asize; //for debugging
   parent:= felementparent;
   parentlevel:= fparentlevel;
   path:= felementpath;
   name:= aname;
   vislevel:= avislevel;
   kind:= akind;
  end; 
  addelement(felementpath+aname,avislevel,ele1);
 end;
end;

function telementhashdatalist.addelement(const aname: identty;
           const avislevel: vislevelty; const akind: elementkindty;
           const asize: integer; out aelementdata: pointer): boolean;
                                                    //false if duplicate
begin
 aelementdata:= addelement(aname,avislevel,akind,elesize+asize);
 result:= aelementdata <> nil;
 if result then begin
  aelementdata:= @(pelementinfoty(aelementdata)^.data);
 end;
end;

function telementhashdatalist.popelement: pelementinfoty;
begin
 result:= pelementinfoty(pointer(felementdata)+felementparent);
 felementparent:= result^.header.parent;
 fparentlevel:= result^.header.parentlevel;
 felementpath:= result^.header.path;
end;

function telementhashdatalist.decelementparent: elementoffsetty; 
                    //returns old offset
begin
 result:= felementparent;
 with pelementinfoty(pointer(felementdata)+felementparent)^ do begin
  felementparent:= header.parent;
  fparentlevel:= header.parentlevel;
  felementpath:= header.path;
 end;
end;

procedure telementhashdatalist.setelementparent(const element: elementoffsetty);
var
 po1: pelementinfoty;
begin
 felementparent:= element;
 with pelementinfoty(pointer(felementdata)+felementparent)^ do begin
  felementpath:= header.path + header.name;
  fparentlevel:= header.parentlevel+1;
 end;
end;

function telementhashdatalist.findelement(const aname: identty;
              const avislevel: vislevelty): pelementinfoty; //nil if not found
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= findcurrent(aname,avislevel);
 if ele1 >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+ele1);
 end;
end;

function telementhashdatalist.findelementupward(const aname: identty;
              const avislevel: vislevelty): pelementinfoty; //nil if not found
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= findupward(aname,avislevel);
 if ele1 >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+ele1);
 end;
end;

function telementhashdatalist.findelementupward(const aname: identty;
                     const avislevel: vislevelty;
                     out element: elementoffsetty): pelementinfoty; overload;
                                                    //nil if not found
begin
 result:= nil;
 element:= findupward(aname,avislevel);
 if element >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+element);
 end;
end;

function telementhashdatalist.findelementsupward(const anames: identvectorty;
                     const avislevel: vislevelty;
                     out element: elementoffsetty): pelementinfoty;
                                                    //nil if not found
begin
 result:= nil;
 element:= findupward(anames,avislevel);
 if element >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+element);
 end;
end;

function telementhashdatalist.findelementsupward(const anames: identarty;
                        const avislevel: vislevelty;
                        out element: elementoffsetty): pelementinfoty;
                                                       //nil if not found
var
 vec1: identvectorty;
begin
 vec1.high:= high(anames);
 if vec1.high > maxidentvector then begin
  raise exception.create('Ident vector too long.');
 end;
 move(anames[0],vec1.d,(vec1.high+1)*sizeof(vec1.d[0]));
 result:= findelementsupward(vec1,avislevel,element);
end;

{
function telementhashdatalist.findelementsupward(const anames: identvectorty;
                     out element: elementoffsetty): pelementinfoty;
                                                    //nil if not found
//todo: use identvectorty directly
var
 ar1: identarty;
 int1,int2: integer;
begin
 setlength(ar1,high(anames)+1);
 int2:= 0;
 for int1:= 0 to high(anames) do begin
  ar1[int1]:= anames[int1];
  if ar1[int1] = 0 then begin
   int2:= int1;
   break;
  end;
 end;
 setlength(ar1,int2);
 result:= findelementsupward(ar1,element);
end;
}
procedure telementhashdatalist.markelement(out ref: markinfoty);
begin
 mark(ref.hashref);
 ref.dataref:= fnextelement;
end;

procedure telementhashdatalist.releaseelement(const ref: markinfoty);
begin
 release(ref.hashref);
 fnextelement:= ref.dataref;
end;
{
function elementcount: integer;
begin
 result:= elementlist.count;
end;
}
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
 lfsr321(stringident); 
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
{
function scramble1(const avalue: hashvaluety): hashvaluety; inline;
begin
 result:= ((avalue xor (avalue shl 8)) xor (avalue shl 16)) xor (avalue shl 24);
end;
}
{ tindexidenthashdatalist }

constructor tindexidenthashdatalist.create;
begin
 inherited create(sizeof(indexidentdataty));
end;

function tindexidenthashdatalist.getident(aname: lstringty): identty;
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

procedure telementhashdatalist.clear;
begin
 inherited;
 fnextelement:= 0;
 felementlen:= 0;
 felementparent:= 0;
 felementpath:= 0;
 fparentlevel:= 0;
end;

function telementhashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= elementdataty(akey).key;
end;

function telementhashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= identty(akey) = elementdataty(aitemdata).key;
end;

procedure telementhashdatalist.addelement(const aident: identty;
               const avislevel: vislevelty; const aelement: elementoffsetty);
begin
// with pelementhashdataty(internaladdhash(scramble1(aident)))^.data do begin
 with pelementhashdataty(internaladdhash(aident))^.data do begin
  key:= aident;
  data:= aelement;
 end;
end;

function telementhashdatalist.findcurrent(const aident: identty;
                              const avislevel: vislevelty): elementoffsetty;
var
 uint1: ptruint;
 po1: pelementhashdataty;
 id1: identty;
begin
 result:= -1;
 if count > 0 then begin
  id1:= felementpath+aident;
  uint1:= fhashtable[id1 and fmask];
  if uint1 <> 0 then begin
   po1:= pelementhashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.data.key = id1) then begin
     with pelementinfoty(pointer(felementdata)+po1^.data.data)^.header do begin
      if (name = aident) and (parent = felementparent) and 
                                      (vislevel <= avislevel) then begin
       break;
      end;
     end;
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

function telementhashdatalist.findupward(const aident: identty;
                      const avislevel: vislevelty): elementoffsetty;
var
 parentbefore: elementoffsetty;
 pathbefore: identty;
begin
 result:= findcurrent(aident,avislevel);
 if (result < 0) and (felementpath <> 0) then begin
  parentbefore:= felementparent;
  pathbefore:= felementpath;
  while true do begin
   with pelementinfoty(pointer(felementdata)+felementparent)^.header do begin
    felementpath:= felementpath-name;
    felementparent:= parent;
    result:= findcurrent(aident,avislevel);
    if result >= 0 then begin
     break;
    end;
    if path = 0 then begin
     break;
    end;
   end;
  end;
  felementparent:= parentbefore;
  felementpath:= pathbefore;
 end;
end;

function telementhashdatalist.findupward(const aidents: identvectorty;
                               const avislevel: vislevelty): elementoffsetty;
//todo: use identvectorty

var
 parentbefore: elementoffsetty;
 pathbefore: identty;
 path1: identty;
 id1: identty;
 uint1: ptruint;
 po1: pelementhashdataty;
 po2: pelementinfoty;
 hash1: hashvaluety;
 int1: integer;
 first: elementoffsetty;
begin
 if aidents.high = 0 then begin
  result:= findupward(aidents.d[0],avislevel);
 end
 else begin
  result:= -1;
  path1:= aidents.d[0];
  for int1:= 1 to aidents.high do begin
   if aidents.d[int1] = 0 then begin
    break;
   end;
   path1:= path1 + aidents.d[int1];
  end;
  parentbefore:= felementparent;
  pathbefore:= felementpath;
  while true do begin
   first:= findupward(aidents.d[0],avislevel);
   if first < 0 then begin
    break;
   end;
   with pelementinfoty(pointer(felementdata)+first)^.header do begin
    felementparent:= parent;
    felementpath:= path;
   end;
   id1:= felementpath+path1;
//   hash1:= scramble1(id1);
   uint1:= fhashtable[id1 and fmask];
   if uint1 <> 0 then begin
    po1:= pelementhashdataty(pchar(fdata) + uint1);
    while true do begin
     if (po1^.data.key = id1) then begin
      result:= po1^.data.data;
      po2:= pelementinfoty(pointer(felementdata)+result);
      for int1:= aidents.high downto 1 do begin
       if po2^.header.name <> aidents.d[int1] then begin
        result:= -1;
        break;
       end;
       po2:= pointer(felementdata)+po2^.header.parent;
      end;
      if (result >= 0) and (po2^.header.parent = felementparent) then begin
       break;
      end;
     end;
     if po1^.header.nexthash = 0 then begin
      break;
     end;
     po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
    end;
   end
   else begin
    result:= -1;
   end;
   if (result >= 0) or (felementparent = 0) then begin
    break;
   end;
   with pelementinfoty(pointer(felementdata)+felementparent)^.header do begin
    felementparent:= parent;
    felementpath:= path;
   end;
  end;
  felementparent:= parentbefore;
  felementpath:= pathbefore;
 end;
end;

initialization
 identlist:= tindexidenthashdatalist.create;
 elements:= telementhashdatalist.create;
 clear;
finalization
 identlist.free;
 elements.free;
end.
