{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
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
unit elements;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,msetypes,msehash,parserglob,handlerglob;

{$define mse_debug_parser}

const
 maxidentvector = 200;
 firstident = 256;
type
 identarty = integerarty;
 identvecty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;
 elementoffsetaty = array[0..0] of elementoffsetty;
 pelementoffsetaty = ^elementoffsetaty;
 
 elementkindty = (ek_none,ek_type,ek_const,ek_var,ek_field,
                  ek_sysfunc,ek_sub,ek_classes,ek_class,
                  ek_unit,ek_implementation,ek_arraydim);
 elementkindsty = set of elementkindty;
 
 elementheaderty = record
 // size: integer; //for debugging
  next: elementoffsetty; //for debugging
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
 eledatashift = sizeof(elementheaderty);

type
 elehandlerprocty = procedure(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
 telementhashdatalist = class(thashdatalist)
  private
   ffindvislevel: vislevelty;
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
   procedure checkbuffersize; inline;
  public
//todo: use faster calling, less parameters

   constructor create;
   procedure clear; override;
   procedure checkcapacity(const areserve: integer);

   function forallcurrent(const aident: identty; const akinds: elementkindsty;
                 const avislevel: vislevelty; const ahandler: elehandlerprocty;
                 var adata): boolean; //returns terminated flag
   function findcurrent(const aident: identty; const akinds: elementkindsty;
            const avislevel: vislevelty; out element: elementoffsetty): boolean;
                  //searches in current scope
   function findupward(const aident: identty; const akinds: elementkindsty;
                  const avislevel: vislevelty;
                  out element: elementoffsetty): boolean; overload;
                  //searches in current scope and above
   function findupward(const aidents: identvecty;
                      const akinds: elementkindsty;
                      const avislevel: vislevelty;
                      out element: elementoffsetty;
                      out lastident: integer): boolean; overload;
                  //searches in current scope and above, -1 if not found
                  //lastident = index of last matching in aident if
                  //akinds <> []
   function findchild(const aparent: elementoffsetty; 
                 const achild: elementoffsetty; const akinds: elementkindsty;
                 const avislevel: vislevelty; 
                               out element: elementoffsetty): boolean;

   function eleoffset: ptruint; inline;
   function eledataoffset: ptruint; inline;
   function eleinfoabs(const aelement: elementoffsetty): pelementinfoty; inline;
   function eleinforel(const aelement: pelementinfoty): elementoffsetty; inline;
   function eledataabs(const aelement: elementoffsetty): pointer; inline;
   function eledatarel(const aelement: pointer): elementoffsetty; inline;
   
  {$ifdef mse_debugparser}
   function dumpelements: msestringarty;
   function dumppath(const aelement: pelementinfoty): msestring;
  {$endif}
   function pushelementduplicate(const aname: identty;
                  const avislevel: vislevelty; const akind: elementkindty;
                                  const sizeextend: integer): pelementinfoty;
   function pushelement(const aname: identty; const avislevel: vislevelty;
                  const akind: elementkindty{;
                  const asize: integer}): pelementinfoty; //nil if duplicate
   function pushelement(const aname: identty; const avislevel: vislevelty;
                  const akind: elementkindty;                  
                  {const asize: integer;} out aelementdata: pointer): boolean;
                                                       //false if duplicate
   function pushelement(const aname: identty; const avislevel: vislevelty;
                const akind: elementkindty;                  
                const sizeextend: integer; out aelementdata: pointer): boolean;
                                                       //false if duplicate
   function pushelement(const aname: identty; const avislevel: vislevelty;
                  const akind: elementkindty;                  
           {const asize: integer;} out aelementdata: elementoffsetty): boolean;
                                                       //false if duplicate
   function popelement: pelementinfoty;
   function addelement(const aname: identty; const avislevel: vislevelty;
              const akind: elementkindty{;
              const asize: integer}): pelementinfoty;   //nil if duplicate
   function addelement(const aname: identty; const avislevel: vislevelty;
              const akind: elementkindty;
              {const asize: integer;} out aelementdata: pointer): boolean;
                                                       //false if duplicate
   function decelementparent: elementoffsetty; //returns old offset
   procedure markelement(out ref: markinfoty);
   procedure releaseelement(const ref: markinfoty);
   //function elementcount: integer;
   property elementparent: elementoffsetty read felementparent 
                                                 write setelementparent;
   property findvislevel: vislevelty read ffindvislevel write ffindvislevel;
 end;
 
procedure clear;
procedure init;

function getident(): identty; overload;
function getident(const astart,astop: pchar): identty; overload;
function getident(const aname: lstringty): identty; overload;
function getident(const aname: pchar; const alen: integer): identty; overload;
function getident(const aname: string): identty; overload;

procedure linkmark(const info: pparseinfoty; var alinks: linkindexty;
                                                      const aaddress: integer);
procedure linkresolve(const info: pparseinfoty; const alinks: linkindexty;
                                                  const aaddress: opaddressty);

procedure forwardmark(const info: pparseinfoty;
            out aforward: forwardindexty; const asource: sourceinfoty);
procedure forwardresolve(const info: pparseinfoty;
                                        const aforward: forwardindexty);
procedure checkforwarderrors(const info: pparseinfoty;
                                    const aforward: forwardindexty);
function newstring(const info: pparseinfoty): stringinfoty;
function stringconst(const info: pparseinfoty;
                                   const astring: stringinfoty): dataaddressty;

{$ifdef mse_debugparser}
function getidentname(const aident: identty): string;
{$endif}
//function scramble1(const avalue: hashvaluety): hashvaluety; inline;

const
 elesizes: array[elementkindty] of integer = (
//ek_none,ek_type,                   ek_const,         
  0,      sizeof(typedataty)+elesize,sizeof(constdataty)+elesize,
//ek_var,                   ek_field,
  sizeof(vardataty)+elesize,sizeof(fielddataty)+elesize, 
//ek_sysfunc,                   ek_func,
  sizeof(sysfuncdataty)+elesize,sizeof(funcdataty)+elesize,
//ek_classes,                   ek_class,
  sizeof(classesdataty)+elesize,sizeof(classdataty)+elesize,
//ek_unit,                   ek_implementation  
  sizeof(unitdataty)+elesize,sizeof(classdataty)+elesize,
//ek_arraydim
  sizeof(arraydimdataty)+elesize
 );

var
 ele: telementhashdatalist;

implementation
uses
 msearrayutils,sysutils,typinfo,mselfsr,grammar,mseformatstr,
 errorhandler,mselinklist,stackops;

 
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

{$ifdef mse_debugparser}
 identdataty = record
  ident: identty;
  keyname: identoffsetty;
 end;
 identhashdataty = record
  header: hashheaderty;
  data: identdataty;
 end;
 pidenthashdataty = ^identhashdataty;

 tidenthashdatalist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create;
 end;
{$endif}
  
 tindexidenthashdatalist = class(thashdatalist)
 {$ifdef mse_debugparser}
  private
   fidents: tidenthashdatalist;
 {$endif}
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create;
  {$ifdef mse_debugparser}
   destructor destroy; override;
   procedure clear; override;
   function identname(const aident: identty): string;
  {$endif}
   function getident(const aname: lstringty): identty;
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
{
 varlendataty = record
  len: integer;
  data: record //array of byte
  end;
 end;
 pvarlendataty = ^varlendataty;
}
 stringbufdataty = record
  len: integer;
  offset: ptruint; //offset in fbuffer
  constoffset: dataoffsty; //offset in constdata, 0 -> not assigned
 end;
 pstringbufdataty = ^stringbufdataty;
 stringbufhashdataty = record
  header: hashheaderty;
  data: stringbufdataty;
 end;
 pstringbufhashdataty = ^stringbufhashdataty;
 
 tstringbuffer = class(thashdatalist)
  private
   fbuffer: pointer;
   fbufsize: ptruint;
   fbufcapacity: ptruint;
  protected
   procedure initbuffer;
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create;
   destructor destroy; override;
   procedure clear; override;
   function add(const avalue: string): stringinfoty;
   function allocconst(const info: pparseinfoty;
                         const astring: stringinfoty): dataaddressty;
 end;
 
const
 mindatasize = 1024; 
var
 stringdata: string;
 stringindex,stringlen: identoffsetty;
 stringident: identty;
 identlist: tindexidenthashdatalist;
 stringbuf: tstringbuffer;

procedure nextident;
begin
 repeat
  lfsr321(stringident);
 until stringident >= firstident;
end;

function telementhashdatalist.eleoffset: ptruint; inline;
begin
 result:= ptruint(felementdata);
end;

function telementhashdatalist.eledataoffset: ptruint; inline;
begin
 result:= ptruint(felementdata) + eledatashift;
end;

function telementhashdatalist.eleinforel(
                          const aelement: pelementinfoty): elementoffsetty;
begin
 result:= aelement-pointer(felementdata);
end;

function telementhashdatalist.eleinfoabs(
                         const aelement: elementoffsetty): pelementinfoty;
begin
 result:= aelement+pointer(felementdata);
end;

function telementhashdatalist.eledatarel(
                          const aelement: pointer): elementoffsetty;
begin
 result:= aelement-pointer(felementdata)-eledatashift;
end;

function telementhashdatalist.eledataabs(
                           const aelement: elementoffsetty): pointer; inline;
begin
 result:= @pelementinfoty(aelement+pointer(felementdata))^.data;
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

type
 linkinfoty = record
  next: linkindexty;
  dest: opaddressty;
 end;
 plinkinfoty = ^linkinfoty;
 linkarty = array of linkinfoty;
 
var
 links: linkarty; //[0] -> dummy entry
 linkindex: linkindexty;
 deletedlinks: linkindexty;
 
procedure linkmark(const info: pparseinfoty; 
                           var alinks: linkindexty; const aaddress: integer);
var
 li1: linkindexty;
 po1: plinkinfoty;
begin
 li1:= deletedlinks;
 if li1 = 0 then begin
  inc(linkindex);
  if linkindex > high(links) then begin
   reallocuninitedarray(high(links)*2+1024,sizeof(links[0]),links);
  end;
  li1:= linkindex;
  po1:= @links[li1];
 end
 else begin
  po1:= @links[li1];
  deletedlinks:= po1^.next;
 end;
 po1^.next:= alinks;
 po1^.dest:= aaddress;
 alinks:= li1;
end;

procedure linkresolve(const info: pparseinfoty;
                    const alinks: linkindexty; const aaddress: opaddressty);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    info^.ops[dest].d.opaddress:= aaddress-1;
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
 end;
end;

type
 forwardinfoty = record
  prev: forwardindexty;
  next: forwardindexty;
  source: sourceinfoty;
 end;
 pforwardinfoty = ^forwardinfoty;
 forwardarty = array of forwardinfoty;
 
var
 forwards: forwardarty; //[0] -> dummy entry
 forwardindex: forwardindexty;
 deletedforwards: forwardindexty;

procedure forwardmark(const info: pparseinfoty;
            out aforward: forwardindexty; const asource: sourceinfoty);
var
 fo1: forwardindexty;
 po1: pforwardinfoty;
begin
 fo1:= deletedforwards;
 if fo1 = 0 then begin
  inc(forwardindex);
  if forwardindex > high(forwards) then begin
   reallocuninitedarray(high(forwards)*2+1024,sizeof(forwards[0]),forwards);
  end;
  fo1:= forwardindex;
  po1:= @forwards[fo1];
 end
 else begin
  po1:= @forwards[fo1];
  deletedlinks:= po1^.next;
 end;
 with info^.unitinfo^ do begin
  po1^.prev:= 0;
  po1^.next:= forwardlist;
  po1^.source:= asource;
  forwards[forwardlist].prev:= fo1;
  forwardlist:= fo1;
 end;
 aforward:= fo1;
end;

procedure forwardresolve(const info: pparseinfoty;
                                        const aforward: forwardindexty);
begin
 if aforward <> 0 then begin
  with forwards[aforward] do begin
   if info^.unitinfo^.forwardlist = aforward then begin
    info^.unitinfo^.forwardlist:= next;
   end;
   forwards[next].prev:= prev;
   forwards[prev].next:= next;
   next:= deletedforwards;
  end;
  deletedforwards:= aforward;
 end;
end;

procedure checkforwarderrors(const info: pparseinfoty;
                                    const aforward: forwardindexty);
var
 fo1: forwardindexty;
begin
 fo1:= aforward;
 while fo1 <> 0 do begin
  with forwards[fo1] do begin
   errormessage(info,source,err_forwardnotsolved,['']);
                      //todo show header
   fo1:= next;
  end;
 end;
end;

function newstring(const info: pparseinfoty): stringinfoty;
begin
 result:= stringbuf.add(info^.stringbuffer);
end;

function stringconst(const info: pparseinfoty;
                           const astring: stringinfoty): dataaddressty;
begin
 result:= stringbuf.allocconst(info,astring);
end;

procedure clear;
begin
 identlist.clear;
 stringdata:= '';
 stringindex:= 0;
 stringlen:= 0;

 ele.clear;
 stringident:= 0;
 links:= nil;
 linkindex:= 0;
 deletedlinks:= 0;
 forwards:= nil;
 forwardindex:= 0;
 deletedforwards:= 0;
 
 stringbuf.clear;
end;

procedure init;
var
 int1: integer;
 tk1: integer;
begin
 clear;
// ele.pushelement(getident(''),vis_max,ek_none); //root
 ele.pushelement(0,vis_max,ek_none); //root
 stringident:= idstart; //invalid
 nextident;
 for tk1:= 1 to high(tokens) do begin
  getident(tokens[tk1]);
 end;
end;

{$ifdef mse_debugparser}
function getidentname(const aident: identty): string;
begin
 result:= identlist.identname(aident);
end;

{ tidenthashdataty }

constructor tidenthashdatalist.create;
begin
 inherited create(sizeof(identdataty));
end;

function tidenthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= identty(akey);
end;

function tidenthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= identty(akey) = identdataty(aitemdata).ident;
end;
{$endif}

{ tindexidenthashdatalist }

constructor tindexidenthashdatalist.create;
begin
 inherited create(sizeof(indexidentdataty));
{$ifdef mse_debugparser}
 fidents:= tidenthashdatalist.create;
{$endif}
end;

{$ifdef mse_debugparser}
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

function tindexidenthashdatalist.identname(const aident: identty): string;
var
 po1: pidenthashdataty;
begin
 result:= '';
 po1:= pidenthashdataty(fidents.internalfind(aident,aident));
 if po1 <> nil then begin
  result:= strpas(pchar(stringdata)+po1^.data.keyname);
 end;
end;
{$endif}

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
  {$ifdef mse_debugparser}
   with pidenthashdataty(fidents.internaladdhash(data))^.data do begin
    ident:= data;
    keyname:= key;
   end;
  {$endif}
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
 ffindvislevel:= vis_min;
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

function telementhashdatalist.forallcurrent(const aident: identty;
                 const akinds: elementkindsty;
                 const avislevel: vislevelty; const ahandler: elehandlerprocty;
                 var adata): boolean; //returns terminated flag
var
 uint1: ptruint;
 po1: pelementhashdataty;
 po2: pelementinfoty;
 id1: identty;
begin
 result:= false;
 if count > 0 then begin
  id1:= felementpath+aident;
  uint1:= fhashtable[id1 and fmask];
  if uint1 <> 0 then begin
   po1:= pelementhashdataty(pchar(fdata) + uint1);
   while not result do begin
    if (po1^.data.key = id1) then begin
     po2:= pelementinfoty(pointer(felementdata)+po1^.data.data);
     with po2^.header do begin
      if (name = aident) and (parent = felementparent) and 
                               (vislevel <= avislevel) and 
                           ((akinds = []) or (kind in akinds)) then begin
       ahandler(po2,adata,result);
      end;
     end;
    end;
    if po1^.header.nexthash = 0 then begin
     exit;
    end;
    po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
end;

function telementhashdatalist.findcurrent(const aident: identty;
              const akinds: elementkindsty; const avislevel: vislevelty;
                                        out element: elementoffsetty): boolean;
var
 uint1: ptruint;
 po1: pelementhashdataty;
 id1: identty;
begin
 element:= -1;
 result:= false;
 if count > 0 then begin
  id1:= felementpath+aident;
  uint1:= fhashtable[id1 and fmask];
  if uint1 <> 0 then begin
   po1:= pelementhashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.data.key = id1) then begin
     with pelementinfoty(pointer(felementdata)+po1^.data.data)^.header do begin
      if (name = aident) and (parent = felementparent) and 
                               (vislevel <= avislevel) and 
                           ((akinds = []) or (kind in akinds)) then begin
       break;
      end;
     end;
    end;
    if po1^.header.nexthash = 0 then begin
     exit;
    end;
    po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
   element:= po1^.data.data;
  end;
 end;
 result:= element >= 0;
end;

function telementhashdatalist.findupward(const aident: identty;
          const akinds: elementkindsty;
          const avislevel: vislevelty; out element: elementoffsetty): boolean;
var
 parentbefore: elementoffsetty;
 pathbefore: identty;
begin
 result:= findcurrent(aident,akinds,avislevel,element);
 if not result and (felementpath <> 0) then begin
  parentbefore:= felementparent;
  pathbefore:= felementpath;
  while true do begin
   with pelementinfoty(pointer(felementdata)+felementparent)^.header do begin
    felementpath:= felementpath-name;
    felementparent:= parent;
    result:= findcurrent(aident,akinds,avislevel,element);
    if result or (path = 0) then begin
     break;
    end;
   end;
  end;
  felementparent:= parentbefore;
  felementpath:= pathbefore;
 end;
end;

function telementhashdatalist.findupward(const aidents: identvecty;
              const akinds: elementkindsty; const avislevel: vislevelty;
              out element: elementoffsetty;
              out lastident: integer): boolean;
//todo: optimize
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
 result:= false;
 element:= -1;
 lastident:= aidents.high;
 if aidents.high >= 0 then begin
  if aidents.high = 0 then begin
   result:= findupward(aidents.d[0],akinds,avislevel,element);
  end
  else begin
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
    if not findupward(aidents.d[0],[],avislevel,first) then begin //find root
     break; //not found
    end;
    with pelementinfoty(pointer(felementdata)+first)^.header do begin
     felementparent:= parent;
     felementpath:= path;
    end;
    repeat
     id1:= felementpath+path1; //complete path
     uint1:= fhashtable[id1 and fmask];
     if uint1 <> 0 then begin //there are candidates
      po1:= pelementhashdataty(pchar(fdata) + uint1);
      while true do begin
       if (po1^.data.key = id1) then begin
        element:= po1^.data.data;
        po2:= pelementinfoty(pointer(felementdata)+element);
        if (akinds = []) or (po2^.header.kind in akinds) then begin
         for int1:= lastident downto 1 do begin //check ancestor chain
          if po2^.header.name <> aidents.d[int1] then begin
           element:= -1; //ancestoor chain broken
           break;
          end;
          po2:= pointer(felementdata)+po2^.header.parent;
         end;
         if (element >= 0) and (po2^.header.parent = felementparent) then begin
          result:= true;
          break; //ancestor chain ok
         end;
        end
        else begin
         element:= -1;
        end;
       end;
       if po1^.header.nexthash = 0 then begin
        break; //not found
       end;
       po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
      end;
     end
     else begin
      element:= -1;
     end;
     if result then begin
      break; //found
     end;
     path1:= path1 - aidents.d[lastident];
     dec(lastident);
    until (akinds = []) or (lastident < 0);
    if result or (felementparent = 0) then begin
     break;
    end;
    with pelementinfoty(pointer(felementdata)+felementparent)^.header do begin
     felementparent:= parent; //parentlevel
     felementpath:= path;
    end;
   end;
   felementparent:= parentbefore;
   felementpath:= pathbefore;
  end;
 end;
end;

function telementhashdatalist.findchild(const aparent: elementoffsetty; 
           const achild: elementoffsetty; const akinds: elementkindsty;
           const avislevel: vislevelty; out element: elementoffsetty): boolean;
//todo: optimize
var 
 ele1: elementoffsetty;
begin
 ele1:= elementparent;
 elementparent:= aparent;
 result:= findcurrent(achild,akinds,avislevel,element);
 elementparent:= ele1;
end;

{$ifdef mse_debugparser}
function telementhashdatalist.dumpelements: msestringarty;
var
 int1,int2,int3,int4,int5,int6: integer;
 po1,po2,po3: pelementinfoty;
 mstr1,mstr2: msestring;
 ar1: dumpinfoarty;
 off1: elementoffsetty;
 ar2: msestringarty;
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
  mstr1:= mstr1+'O:'+inttostr(int1) +
            ' P:'+inttostr(po1^.header.parent)+' N:$'+
            hextostr(po1^.header.name,8)+' '+
            ' '+identlist.identname(po1^.header.name) + 
            ' V:'+inttostr(ord(po1^.header.vislevel))+' '+
            getenumname(typeinfo(po1^.header.kind),ord(po1^.header.kind));
  case po1^.header.kind of
   ek_var: begin
    with pvardataty(@po1^.data)^ do begin
     mstr1:= mstr1+lineend+' A:'+inttostr(address.address)+' '+
           settostring(ptypeinfo(typeinfo(address.flags)),
                                         integer(address.flags),false);
     po2:= eleinfoabs(typ);
     mstr1:= mstr1+' T:'+inttostr(typ)+':'+getidentname(po2^.header.name);
     with ptypedataty(@po2^.data)^ do begin
      mstr1:= mstr1+' K:'+getenumname(typeinfo(kind),ord(kind))+
       ' S:'+inttostr(bytesize);
     end;
    end;
   end;
   ek_type: begin
    with ptypedataty(@po1^.data)^ do begin
     mstr1:= mstr1+lineend+' K:'+getenumname(typeinfo(kind),ord(kind))+
       ' S:'+inttostr(bytesize)+' I:'+inttostr(indirectlevel);
     po3:= po1;
     {
     while ptypedataty(@po3^.data)^.kind = dk_reference do begin
      mstr1:= mstr1+' R:'+inttostr(ptypedataty(@po3^.data)^.indirectlevel);
      mstr2:= '  ';
      po3:= eleinfoabs(ptypedataty(@po3^.data)^.target);
      mstr1:= mstr1+lineend+mstr2+'N:$'+
            hextostr(po3^.header.name,8)+' '+
            ' '+identlist.identname(po3^.header.name);
      with ptypedataty(@po3^.data)^ do begin
       mstr1:= mstr1+' K:'+getenumname(typeinfo(kind),ord(kind))+
         ' S:'+inttostr(bytesize);
      end;
      mstr2:= mstr2+' ';
     end;
     }
    end;
   end;
  end;
  int4:= 0;
  int1:= po1^.header.next;
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
   ar2:= breaklines(mstr1);
   ar2[0]:= charstring(msechar('.'),int3-1)+'$'+
                 hextostr(longword(int5+int4+po1^.header.name),8)+' '+ar2[0];
   mstr2:= charstring(msechar(' '),int3-1);
   for int6:= 1 to high(ar2) do begin
    ar2[int6]:= mstr2+ar2[int6];
   end;
   text:= concatstrings(ar2,lineend);
   offset:= off1;
  end;
 end;
 setlength(ar1,int2);
 sortarray(ar1,sizeof(ar1[0]),@compdump);
 setlength(result,int2+1);
 result[0]:= 'elementpath: $'+hextostr(felementpath,8);
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
 result:= identlist.identname(po1^.header.name);
 while po1^.header.parent <> 0 do begin
  po1:= pointer(felementdata)+po1^.header.parent;
  result:= identlist.identname(po1^.header.name)+'.'+result;
 end;
end;
{$endif}

procedure telementhashdatalist.checkbuffersize; inline;
begin
 if fnextelement >= felementlen then begin
  felementlen:= fnextelement*2+mindatasize;
  setlength(felementdata,felementlen);
 end;
end;

procedure telementhashdatalist.checkcapacity(const areserve: integer);
begin
 if fnextelement+areserve >= felementlen then begin
  felementlen:= fnextelement*2+mindatasize+areserve;
  setlength(felementdata,felementlen);
 end;
end;

function telementhashdatalist.pushelementduplicate(const aname: identty;
                  const avislevel: vislevelty;
                  const akind: elementkindty;
                  const sizeextend: integer): pelementinfoty;
var
 ele1: elementoffsetty;
begin
 ele1:= fnextelement;
 fnextelement:= fnextelement+(elesizes[akind])+sizeextend;
 checkbuffersize;
 result:= pointer(felementdata)+ele1;
 with result^.header do begin
  next:= fnextelement; //for debugging
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

function telementhashdatalist.pushelement(const aname: identty;
             const avislevel: vislevelty;
             const akind: elementkindty): pelementinfoty;
var
 ele1: elementoffsetty;
begin
 result:= nil;
 if not findcurrent(aname,[],ffindvislevel,ele1) then begin
  result:= pushelementduplicate(aname,avislevel,akind,0);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
           const avislevel: vislevelty; const akind: elementkindty;
                   out aelementdata: pointer): boolean; //false if duplicate
begin
 aelementdata:= pushelement(aname,avislevel,akind);
 result:= aelementdata <> nil;
 if result then begin
  aelementdata:= @(pelementinfoty(aelementdata)^.data);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
           const avislevel: vislevelty; const akind: elementkindty;
           out aelementdata: elementoffsetty): boolean;
                                                    //false if duplicate
var
 po1: pelementinfoty;
begin
 po1:= pushelement(aname,avislevel,akind);
 result:= po1 <> nil;
 if result then begin
  aelementdata:= pointer(po1)-pointer(felementdata);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
                  const avislevel: vislevelty;
       const akind: elementkindty;                  
       const sizeextend: integer; out aelementdata: pointer): boolean;
                                                       //false if duplicate
var
 po1: pelementinfoty;
 ele1: elementoffsetty;
begin
 result:= false;
 if not findcurrent(aname,[],ffindvislevel,ele1) then begin
  po1:= pushelementduplicate(aname,avislevel,akind,sizeextend);
  aelementdata:= @(po1^.data);
 end;
end;

function telementhashdatalist.addelement(const aname: identty;
              const avislevel: vislevelty;
              const akind: elementkindty): pelementinfoty;   
                                                   //nil if duplicate
var
 ele1: elementoffsetty;
begin
 result:= nil;
 if not findcurrent(aname,[],ffindvislevel,ele1) then begin
  ele1:= fnextelement;
  fnextelement:= fnextelement+elesizes[akind];
  checkbuffersize;
  result:= pointer(felementdata)+ele1;
  with result^.header do begin
//   size:= asize; //for debugging
   next:= fnextelement;
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
           out aelementdata: pointer): boolean;
                                                    //false if duplicate
begin
 aelementdata:= addelement(aname,avislevel,akind);
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
{
function telementhashdatalist.findelement(const aname: identty;
              const akinds: elementkindsty;
              const avislevel: vislevelty): pelementinfoty; //nil if not found
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= findcurrent(aname,akinds,avislevel);
 if ele1 >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+ele1);
 end;
end;

function telementhashdatalist.findelementupward(const aname: identty;
              const akinds: elementkindsty;
              const avislevel: vislevelty): pelementinfoty; //nil if not found
var
 ele1: elementoffsetty;
begin
 result:= nil;
 ele1:= findupward(aname,akinds,avislevel);
 if ele1 >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+ele1);
 end;
end;

function telementhashdatalist.findelementupward(const aname: identty;
                     const akinds: elementkindsty;
                     const avislevel: vislevelty;
                     out element: elementoffsetty): pelementinfoty; overload;
                                                    //nil if not found
begin
 result:= nil;
 element:= findupward(aname,akinds,avislevel);
 if element >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+element);
 end;
end;

function telementhashdatalist.findelementsupward(const anames: identvectorty;
                     const akinds: elementkindsty;
                     const avislevel: vislevelty;
                     out element: elementoffsetty): pelementinfoty;
                                                    //nil if not found
begin
 result:= nil;
 element:= findupward(anames,akinds,avislevel);
 if element >= 0 then begin
  result:= pelementinfoty(pointer(felementdata)+element);
 end;
end;

function telementhashdatalist.findelementsupward(const anames: identarty;
                     const akinds: elementkindsty;
                        const avislevel: vislevelty;
                        out element: elementoffsetty): pelementinfoty;
                                                       //nil if not found
var
 vec1: identvectorty;
begin
 vec1.high:= high(anames);
 if vec1.high > maxidentvector then begin
  raise exception.create('Internal error E20131103A');
 end;
 move(anames[0],vec1.d,(vec1.high+1)*sizeof(vec1.d[0]));
 result:= findelementsupward(vec1,akinds,avislevel,element);
end;

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
{ tstringbuffer }

constructor tstringbuffer.create;
begin
 inherited create(sizeof(stringbufdataty));
 initbuffer;
end;

destructor tstringbuffer.destroy;
begin
 inherited;
 freemem(fbuffer);
end;

function tstringbuffer.hashkey(const akey): hashvaluety;
begin
 result:= stringhash(lstringty(akey));
end;

function tstringbuffer.checkkey(const akey; const aitemdata): boolean;
begin
 result:= (lstringty(akey).len = stringbufdataty(aitemdata).len) and
       comparemem(lstringty(akey).po,
                       fbuffer+stringbufdataty(aitemdata).offset,
                                      stringbufdataty(aitemdata).len);
end;

function tstringbuffer.add(const avalue: string): stringinfoty;
var
 hash: longword;
 po1: pstringbufhashdataty;
 offs1: ptruint;
 len1: integer;
begin
 hash:= stringhash(avalue);
 po1:= pointer(internalfind(stringtolstring(avalue),hash));
 if po1 = nil then begin
  len1:= length(avalue);
  po1:= pointer(internaladdhash(hash));
  po1^.data.offset:= fbufsize;
  po1^.data.constoffset:= 0;
  po1^.data.len:= len1;
  fbufsize:= fbufsize + len1;
  if fbufsize > fbufcapacity then begin
   fbufcapacity:= fbufsize*2;
   reallocmem(fbuffer,fbufcapacity);
  end;
  move(pointer(avalue)^,(fbuffer+po1^.data.offset)^,len1);
 end;
 result.offset:= @po1^.data-fdata;
end;

procedure tstringbuffer.clear;
begin
 initbuffer;
 inherited; 
end;

procedure tstringbuffer.initbuffer;
const
 minbuffersize = $16;// $10000;
begin
 fbufsize:= 0;
 fbufcapacity:= minbuffersize;
 reallocmem(fbuffer,fbufcapacity);
end;
 
function tstringbuffer.allocconst(const info: pparseinfoty;
                                   const astring: stringinfoty): dataaddressty;
var
 po1: pstringheaderty;
 po2: pbyte;
begin
 with pstringbufdataty(fdata+astring.offset)^ do begin
  if constoffset = 0 then begin
   with info^ do begin
    constoffset:= constsize;
    constsize:= constsize+sizeof(stringheaderty)+len+1;
    alignsize(constsize);
    if constsize > constcapacity then begin
     constcapacity:= 2*constsize;
     setlength(constseg,constcapacity);
    end;
    po1:= pointer(constseg)+constoffset;
    po1^.len:= len;
    po2:= @po1^.data;
    move((fbuffer+offset)^,po2^,len);
    (po2+len)^:= 0;
   end;
  end;
  if len = 0 then begin
   result:= 0;
  end
  else begin
   result:= constoffset+sizeof(stringheaderty);
  end;
 end;
end;

initialization
 identlist:= tindexidenthashdatalist.create;
 stringbuf:= tstringbuffer.create;
 ele:= telementhashdatalist.create;
 clear;
finalization
 identlist.free;
 stringbuf.free;
 ele.free;
end.
