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
//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//
unit elements;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 msestrings,msetypes,msehash,parserglob,handlerglob,segmentutils,globtypes,
 classhandler,mselist,llvmlists;

const
 maxidentvector = 200;
 pointertypeid = -1;
 
type
 identarty = integerarty;
 identvecty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;
 elementoffsetaty = array[0..0] of elementoffsetty;
 pelementoffsetaty = ^elementoffsetaty;
 
 elementkindty = (ek_none,ek_ref,ek_type,ek_const,ek_var,
                  ek_field,ek_classintfname,ek_classintftype,
                  ek_ancestorchain,
                  ek_sysfunc,ek_sub,
                  ek_nestedvar,
                  ek_unit,ek_implementation,
                  ek_classimpnode,ek_classintfnamenode,ek_classintftypenode,
                  ek_uses,ek_condition);
 elementkindsty = set of elementkindty;
 
 elementheaderty = record
 {$ifdef mse_debugparser}
 // size: integer; //for debugging
  next: elementoffsetty; //for debugging
 {$endif}
  name: identty;
  path: identty;
  parent: elementoffsetty; //offset in data array
  parentlevel: integer;    //max = maxidentvector-1
  kind: elementkindty;
  visibility: visikindsty;
  defunit: identty;
 end;
 
 elementinfoty = record
  header: elementheaderty;
  data: record
  end;
 end;
 pelementinfoty = ^elementinfoty;

 elementdataty = record
  key: identty;
  data: elementoffsetty; //offset in elementdata
 end;
 pelementdataty = ^elementdataty;
 
const
 elesize = sizeof(elementinfoty);
 eledatashift = sizeof(elementheaderty);
 maxparents = 255;

 elesizes: array[elementkindty] of integer = (
//ek_none,ek_ref,                   
  elesize,sizeof(refdataty)+elesize,
//ek_type,                   ek_const,         
  sizeof(typedataty)+elesize,sizeof(constdataty)+elesize,
//ek_var,                   ek_field,                
  sizeof(vardataty)+elesize,sizeof(fielddataty)+elesize,
//ek_classintfname,                   ek_classintftype,
  sizeof(classintfnamedataty)+elesize,sizeof(classintftypedataty)+elesize,
//ek_ancestorchain,
  sizeof(ancestorchaindataty)+elesize,
//ek_sysfunc,                   ek_sub,
  sizeof(sysfuncdataty)+elesize,sizeof(subdataty)+elesize,
//ek_nestedvar,
  sizeof(nestedvardataty)+elesize,
//ek_classes,                   ek_class,
 {sizeof(classesdataty)+elesize,}{sizeof(classdataty)+elesize,}
//ek_unit,                   ek_implementation  
  sizeof(unitdataty)+elesize,sizeof(implementationdataty)+elesize,
//ek_classimpnode,                   ek_classintfnamenode,
  sizeof(classimpnodedataty)+elesize,sizeof(classintfnamenodedataty)+elesize,
//ek_classintftypenode,
  sizeof(classintftypenodedataty)+elesize,
//ek_uses                    ek_condition
  sizeof(usesdataty)+elesize,sizeof(conditiondataty)+elesize
 );

type
 elehandlerprocty = procedure(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
 scopeinfoty = record
  element: elementoffsetty;
  childparent: elementoffsetty;
 end;
 pscopeinfoty = ^scopeinfoty;
 
 telementhashdatalist = class(thashdatalist)
  private
//   ffindvislevel: visikindsty;
   fscopes: pointer;
   fscopespo: pscopeinfoty;
   fscopesend: pointer;
   fscopestack: integerarty;
   fscopestackpo: integer;
   fscopestacksize: integer;
//   fdestroying: boolean;
   fparents: array[0..maxparents] of elementoffsetty;
   fparentindex: integer;
   flastdescendent: elementoffsetty;
  protected
   felementdata: string;
   fnextelement: elementoffsetty;
   felementlen: elementoffsetty;
   felementpath: identty; //sum of names in hierarchy 
   felementparent: elementoffsetty;
   fparentlevel: integer;
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
   procedure addelement(const aident: identty; const avislevel: visikindsty;
                                              const aelement: elementoffsetty);
   procedure setelementparent(const element: elementoffsetty);
   procedure checkbuffersize; inline;
  public
//todo: use faster calling, less parameters
   constructor create();
   procedure clear(); override;
   procedure checkcapacity(const areserve: integer);
   procedure checkcapacity(const akind: elementkindty;
                                        const acount: integer = 1);
   function addbuffer(const asize: int32): pointer;

   function forallcurrent(const aident: identty; const akinds: elementkindsty;
                 const avislevel: visikindsty; const ahandler: elehandlerprocty;
                 var adata): boolean; //returns terminated flag
   function forallancestor(const aident: identty; const akinds: elementkindsty;
                 const avislevel: visikindsty; const ahandler: elehandlerprocty;
                 var adata): boolean; //returns terminated flag

   function checkancestor(var aele: elementoffsetty;
                                        var avislevel: visikindsty): boolean;
   
   function findcurrent(const aident: identty; const akinds: elementkindsty;
             avislevel: visikindsty; out element: elementoffsetty): boolean;
   function findcurrent(const aident: identty; const akinds: elementkindsty;
             avislevel: visikindsty; out adata: pointer): elementkindty;
                  //searches in current scope and ancestors
   function findupward(const aident: identty; const akinds: elementkindsty;
                  const avislevel: visikindsty;
                  out element: elementoffsetty): boolean; overload;
                  //searches in current scope and above
   function findupward(const aidents: identvecty;
                      const akinds: elementkindsty;
                      const avislevel: visikindsty;
                      out element: elementoffsetty;
                      out firstnotfound: integer): boolean; overload;
                  //searches in current scope and above, -1 if not found
                  //firstnotfound = index of first not matching in aident

   function findchild(aparent: elementoffsetty; 
                 const achild: identty; const akinds: elementkindsty;
                 avislevel: visikindsty; 
                               out element: elementoffsetty): boolean;
   function findchilddata(const aparent: elementoffsetty; 
                 const achild: identty; const akinds: elementkindsty;
                 const avislevel: visikindsty; out adata: pointer): boolean;
   function findchild(const aparent: elementoffsetty;
                 const achild: identty; const akinds: elementkindsty; 
                 const avislevel: visikindsty; 
               out element: elementoffsetty; out adata: pointer): elementkindty;
   function findchild(aparent: elementoffsetty; 
                 const achildtree: array of identty;
                 const akinds: elementkindsty;
                 avislevel: visikindsty; 
                               out element: elementoffsetty): boolean;
   function findchilddata(const aparent: elementoffsetty; 
                 const achildtree: array of identty;
                 const akinds: elementkindsty;
                 const avislevel: visikindsty; 
                               out adata: pointer): boolean;
   function findparentscope(const aident: identty; const akinds: elementkindsty;
           const avislevel: visikindsty; out aparent: elementoffsetty): boolean;
                  //searches in scopestack, returns parent
   property lastdescendent: elementoffsetty read flastdescendent;
   function elebase: pointer; inline;
   function eleoffset: ptruint; inline;
   function eledataoffset: ptruint; inline;
   function eleinfoabs(const aelement: elementoffsetty): pelementinfoty; inline;
   function eleinforel(const aelement: pelementinfoty): elementoffsetty; inline;
   function eledataabs(const aelement: elementoffsetty): pointer; inline;
   function eledatarel(const aelement: pointer): elementoffsetty; inline;
   property eletopoffset: elementoffsetty read fnextelement;
   
  {$ifdef mse_debugparser}
   function dumpelements: msestringarty;
   function dumppath(const aelement: pelementinfoty): msestring;
  {$endif}
   function pushelementduplicate(const aname: identty;
                   const akind: elementkindty; const avislevel: visikindsty;
                                  const sizeextend: integer): pelementinfoty;
   function pushelementduplicatedata(const aname: identty;
                   const akind: elementkindty; const avislevel: visikindsty;
                                                  out adata: pointer): boolean;
                  //false if duplicate
   function pushelement(const aname: identty; const akind: elementkindty;
                   const avislevel: visikindsty{;
                  const asize: integer}): pelementinfoty; //nil if duplicate
   function pushelement(const aname: identty; const akind: elementkindty;
                  const avislevel: visikindsty;                  
                  out aelementdata: pointer): boolean;
                                                       //false if duplicate
   function pushelement(const aname: identty; const akind: elementkindty;  
                const avislevel: visikindsty;                
                const sizeextend: integer; out aelementdata: pointer): boolean;
                                                       //false if duplicate
   function pushelement(const aname: identty; const akind: elementkindty;
           const avislevel: visikindsty;                         
           out aelementdata: elementoffsetty): boolean;
                                                       //false if duplicate
   function popelement: pelementinfoty;
   function addelementduplicate(const aname: identty;
                                const akind: elementkindty;
                                const avislevel: visikindsty): pelementinfoty;
   function addelementduplicatedata(const aname: identty;
               const akind: elementkindty;
               const avislevel: visikindsty;
               out aelementdata: pointer;
               const asearchlevel: visikindsty = allvisi): boolean;
                                                       //false if duplicate
   function addelementduplicate1(const aname: identty;
                                 const akind: elementkindty;
                                 const avislevel: visikindsty): elementoffsetty;
   function addelementduplicatedata1(const aname: identty;
                                const akind: elementkindty;
                                const avislevel: visikindsty): pointer;
   function addelement(const aname: identty; const akind: elementkindty;
                       const avislevel: visikindsty): pelementinfoty; 
                                              //nil if duplicate
   function addelementdata(const aname: identty; const akind: elementkindty;
                       const avislevel: visikindsty): pointer; 
                                              //nil if duplicate
   function addelementdata(const aname: identty; const akind: elementkindty;
              const avislevel: visikindsty;
              out aelementdata: pointer): boolean;
         //false if duplicate, aelementdata = new or duplicate
   function addelement(const aname: identty; const akind: elementkindty;
              const avislevel: visikindsty;
              out aelementoffset: elementoffsetty): boolean;
         //false if duplicate, aelementoffset = 0 if duplicate
   function adduniquechilddata(const aparent: elementoffsetty;
                           const achild: array of identty; 
                           const akind: elementkindty;
                           const avislevel: visikindsty;
                           out aelementdata: pointer): boolean;
                                          //true if new
   function addchildduplicatedata(const aparent: elementoffsetty;
                           const achild: array of identty;
                           const akind: elementkindty;
                           const avislevel: visikindsty): pointer;
                     
                           
   procedure pushscopelevel();
   procedure popscopelevel();
   function addscope(const akind: elementkindty;
                        const achildparent: elementoffsetty): pointer;
   
   function decelementparent: elementoffsetty; //returns old offset
   procedure markelement(out ref: markinfoty);
   procedure releaseelement(const ref: markinfoty);
   procedure hideelementdata(const adata: pointer); //for error handling only
   property elementparent: elementoffsetty read felementparent 
                                                 write setelementparent;
   function parentdata: pointer;
   function parentelement: pelementinfoty;
   procedure pushelementparent(); //save current on stack
   procedure pushelementparent(const aparent: elementoffsetty);
   procedure popelementparent;
//   property findvislevel: visikindsty read ffindvislevel write ffindvislevel;
 end;

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
  
    
procedure clear;
procedure init;

function getident(): identty; overload;
function getident(const astart,astop: pchar): identty; overload;
function getident(const aname: lstringty): identty; overload;
function getident(const aname: pchar; const alen: integer): identty; overload;
function getident(const aname: string): identty; overload;

function newstring(): stringvaluety; //save info.stringbuffer
function stringconst(const astring: stringvaluety): segaddressty;

function getidentname(const aident: identty; out name: lstringty): boolean;
                             //true if found
function getidentname(const aident: identty): string;

var
 ele: telementhashdatalist;
 typelist: ttypehashdatalist;
 constlist: tconsthashdatalist;
 globlist: tgloballocdatalist;
 mainmetadatalist: tmetadatalist;

implementation
uses
 msearrayutils,sysutils,typinfo,mselfsr,grammar,mseformatstr,
 mselinklist,{stackops,}msesysutils,opcode,{syssubhandler,}
 internaltypes,__mla__internaltypes,errorhandler;
 
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
   function add(const avalue: string): stringvaluety;
   function allocconst(const astring: stringvaluety): segaddressty;
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

function telementhashdatalist.elebase: pointer; inline;
begin
 result:= pointer(felementdata);
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
                    const aelement: elementoffsetty): pelementinfoty; inline;
begin
 result:= aelement+pointer(felementdata);
end;

function telementhashdatalist.eledatarel(
                    const aelement: pointer): elementoffsetty; inline;
begin
 result:= aelement-pointer(felementdata)-eledatashift;
end;

function telementhashdatalist.eledataabs(
                           const aelement: elementoffsetty): pointer; inline;
begin
 result:= aelement+pointer(felementdata)+eledatashift;
end;

function telementhashdatalist.parentdata: pointer;
begin
 result:= pointer(felementdata)+felementparent+eledatashift;
end;

function telementhashdatalist.parentelement: pelementinfoty;
begin
 result:= pointer(felementdata)+felementparent;
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

function newstring({const info: pparseinfoty}): stringvaluety;
begin
 result:= stringbuf.add(info.stringbuffer);
end;

function stringconst(const astring: stringvaluety): segaddressty;
begin
 result:= stringbuf.allocconst({info,}astring);
end;

procedure clear;
begin
 identlist.clear;
 stringdata:= '';
 stringindex:= 0;
 stringlen:= 0;

 ele.clear;
 stringident:= 0;
 
 stringbuf.clear;
 typelist.clear();
 constlist.clear();
 globlist.clear();
end;

procedure init;
var
 int1: integer;
 tk1: integer;
begin
 clear;
 ele.pushelement(idstart,ek_none,[]); //root
 stringident:= idstart; //invalid
 nextident;
 for tk1:= 1 to high(tokens) do begin
  getident(tokens[tk1]);
 end;
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

function alignsize(const asize: int32): int32; inline;
begin
 result:= (asize+3) and not 3;
end;

{ tidenthashdataty }

constructor tidenthashdatalist.create(const asize: int32);
begin
 inherited create(asize);
end;

function tidenthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= identty(akey);
end;
var testvar: identty; testvar1: pidentheaderty;
function tidenthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
testvar:= identty(akey);
testvar1:= @aitemdata;
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

{ telementhashdatalist }

constructor telementhashdatalist.create();
begin
// ffindvislevel:= nonevisi;
 inherited create(sizeof(elementdataty));
 clear();
end;

procedure telementhashdatalist.clear();
var
 int1: integer;
begin
 inherited;
 fnextelement:= 0;
 felementlen:= 0;
 felementparent:= 0;
 felementpath:= 0;
 fparentlevel:= 0;
 if hls_destroying in fstate then begin
  if fscopes <> nil then begin
   freemem(fscopes);
   fscopes:= nil;
  end;
 end
 else begin
  reallocmem(fscopes,16*sizeof(fscopes));
 end;
 fscopespo:= nil;
 fscopestack:= nil;
 fscopestackpo:= -1;
 fscopestacksize:= 0;
 fparentindex:= 0;
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
               const avislevel: visikindsty; const aelement: elementoffsetty);
begin
// with pelementhashdataty(internaladdhash(scramble1(aident)))^.data do begin
 with pelementhashdataty(internaladdhash(aident))^.data do begin
  key:= aident;
  data:= aelement;
 end;
end;

function telementhashdatalist.forallcurrent(const aident: identty;
                 const akinds: elementkindsty;
                 const avislevel: visikindsty; const ahandler: elehandlerprocty;
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
             ((visibility * avislevel <> []) or 
          (vik_sameunit in visibility) and (defunit = info.s.unitinfo^.key)) and 
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

function telementhashdatalist.forallancestor(const aident: identty;
                 const akinds: elementkindsty;
                 const avislevel: visikindsty; const ahandler: elehandlerprocty;
                 var adata): boolean; //returns terminated flag
var
 po1: pelementinfoty;
 po2: ptypedataty;
 parentbefore: elementoffsetty;
begin
 result:= false;
 po1:= eleinfoabs(felementparent);
 if (po1^.header.kind = ek_type) then begin
  po2:= @po1^.data;
  if po2^.h.kind in ancestordatakinds then begin
   parentbefore:= elementparent;
   while not result and (po2^.h.ancestor <> 0) do begin
    elementparent:= po2^.h.ancestor;
    po2:= eledataabs(po2^.h.ancestor);
    result:= forallcurrent(aident,akinds,avislevel,ahandler,adata);
   end;
   elementparent:= parentbefore;
  end;
 end;
end;

function telementhashdatalist.checkancestor(var aele: elementoffsetty;
                                        var avislevel: visikindsty): boolean;
begin
 result:= false;
 if vik_ancestor in avislevel then begin
  with pelementinfoty(pointer(felementdata)+aele)^ do begin
   if header.kind = ek_type then begin
    with ptypedataty(@data)^ do begin
     if h.kind in ancestordatakinds then begin
      aele:= h.ancestor;
      result:= aele <> 0;
      include(avislevel,vik_descendent);
     end
     else begin
      if h.kind in ancestorchaindatakinds then begin
       internalerror1(ie_elements,'20150425A');
         //todo
      end;
     end;
    end;
   end;
  end;
 end;
end;

function telementhashdatalist.findcurrent(const aident: identty;
              const akinds: elementkindsty; avislevel: visikindsty;
                                        out element: elementoffsetty): boolean;
var
 uint1: ptruint;
 po1: pelementhashdataty;
 id1: identty;
 int1,int2: integer;
 parentele: elementoffsetty;
 classdescend: elementoffsetty;
 elepath: identty;
label
 endlab;
begin
 element:= -1;
 result:= false;
 if count > 0 then begin
  classdescend:= 0;
  parentele:= felementparent;
  elepath:= felementpath;
  while true do begin
   id1:= elepath+aident;
   uint1:= fhashtable[id1 and fmask];
   if uint1 <> 0 then begin
    po1:= pelementhashdataty(pchar(fdata) + uint1);
    while true do begin
     if (po1^.data.key = id1) then begin
      with pelementinfoty(pointer(felementdata)+po1^.data.data)^.header do begin
       if (name = aident) and (parent = parentele) and 
                                    ((visibility * avislevel <> []) or 
           (vik_sameunit in visibility) and (defunit = info.s.unitinfo^.key)) and 
                            ((akinds = []) or (kind in akinds)) then begin
        element:= po1^.data.data;
        goto endlab;
       end;
      end;
     end;
     if po1^.header.nexthash = 0 then begin
      break;
     end;
     po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
    end;
   end;
   if vik_ancestor in avislevel then begin
    with eleinfoabs(parentele)^ do begin
     if (header.kind = ek_type) and 
                             (ptypedataty(@data)^.h.kind = dk_class) then begin
      if classdescend = 0 then begin
       classdescend:= parentele;
      end;
      parentele:= ptypedataty(@data)^.h.ancestor;
      if parentele <> 0 then begin
       with eleinfoabs(parentele)^ do begin
        elepath:= header.path+header.name;
       end;
       include(avislevel,vik_descendent);
       continue;
      end;
     end;
    end;
   end;
   break;
  end;
 end;
endlab:
 result:= element >= 0;
 if result then begin
  flastdescendent:= classdescend;
 end;
end;

function telementhashdatalist.findcurrent(const aident: identty;
             const akinds: elementkindsty;
             avislevel: visikindsty; out adata: pointer): elementkindty;
var
 ele1: elementoffsetty;
 po1: pelementinfoty;
begin
 result:= ek_none;
 if findcurrent(aident,akinds,avislevel,ele1) then begin
  po1:= eleinfoabs(ele1);
  result:= po1^.header.kind;
  adata:= @po1^.data;
 end;
end;

function telementhashdatalist.findupward(const aident: identty;
          const akinds: elementkindsty;
          const avislevel: visikindsty; out element: elementoffsetty): boolean;
var
 parentbefore: elementoffsetty;
 pathbefore: identty;
 po1: pelementinfoty;
label
 endlab;
begin
 parentbefore:= felementparent;
 pathbefore:= felementpath;
 while true do begin
  result:= findcurrent(aident,akinds,avislevel,element);
  if result then begin
   break;
  end;
  with pelementinfoty(pointer(felementdata)+felementparent)^.header do begin    
   if path = 0 then begin
    break;
   end;
  {$ifdef mse_checkinternalerror}
   if felementparent = 0 then begin
    internalerror(ie_elements,'20150503A');
   end;
  {$endif}
   felementpath:= felementpath-name;
   felementparent:= parent;
  end;
 end;
endlab:
 felementparent:= parentbefore;
 felementpath:= pathbefore;
end;

function telementhashdatalist.findupward(const aidents: identvecty;
              const akinds: elementkindsty; const avislevel: visikindsty;
              out element: elementoffsetty;
              out firstnotfound: integer): boolean;
var
 parentbefore: elementoffsetty;
 pathbefore: identty;
 ele1: elementoffsetty;
 po1: pointer;
begin //todo: optimize
 result:= false;
 element:= -1;
 firstnotfound:= 0;
 if aidents.high >= 0 then begin
  result:= findupward(aidents.d[0],akinds,avislevel,element);
  if result then begin
   firstnotfound:= 1;
   if aidents.high > 0 then begin
    parentbefore:= felementparent;
    pathbefore:= felementpath;
    po1:= pointer(felementdata)+element;
    with pelementinfoty(po1)^.header do begin
     if kind = ek_uses then begin
      element:= pusesdataty(po1+eledatashift)^.ref;
     end;
    end;
    felementparent:= element; //parentlevel
    with pelementinfoty(pointer(felementdata)+element)^.header do begin
     felementpath:= path + name;
    end;
    while true do begin
     if not findcurrent(aidents.d[firstnotfound],[],allvisi,ele1) then begin
      break;
     end;
     element:= ele1;
     felementparent:= ele1;
     felementpath:= felementpath+aidents.d[firstnotfound];
     inc(firstnotfound);
     if firstnotfound > aidents.high then begin
      break;
     end;
    end;
    felementparent:= parentbefore;
    felementpath:= pathbefore;
   end;
  end;
 end;
end;

(*
function telementhashdatalist.findupward(const aidents: identvecty;
              const akinds: elementkindsty; const avislevel: visikindsty;
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
*)
{
function telementhashdatalist.findchild(const aparent: elementoffsetty; 
           const achild: identty; const akinds: elementkindsty;
           const avislevel: visikindsty; out element: elementoffsetty): boolean;
//todo: optimize
var 
 ele1: elementoffsetty;
begin
 ele1:= elementparent;
 elementparent:= aparent;
 result:= findcurrent(achild,akinds,avislevel,element);
 elementparent:= ele1;
end;
}
function telementhashdatalist.findchild(aparent: elementoffsetty; 
                 const achildtree: array of identty;
                 const akinds: elementkindsty;
                 avislevel: visikindsty;
                               out element: elementoffsetty): boolean;
var
 int1: integer;
 id1: identty;
 uint1: ptruint;
 po1: pelementhashdataty;
 po2,po3: pelementinfoty;
label
 next;
begin
 result:= false;
 if length(achildtree) > 0 then begin
  repeat
   with pelementinfoty(pointer(felementdata)+aparent)^ do begin
    id1:= header.path + header.name;
   end;
   for int1:= 0 to high(achildtree) do begin
    id1:= id1 + achildtree[int1];
   end;
   uint1:= fhashtable[id1 and fmask];
   if uint1 <> 0 then begin
    po1:= pelementhashdataty(pchar(fdata) + uint1);
    while true do begin
     if po1^.data.key = id1 then begin
      po2:= pelementinfoty(pointer(felementdata)+po1^.data.data);
      po3:= po2; //searched child
      for int1:= high(achildtree) downto 0 do begin
       if (po2^.header.name <> achildtree[int1]) or 
              (po2^.header.visibility*avislevel = []) then begin
        goto next;
       end;
       po2:= pointer(felementdata)+po2^.header.parent;
      end;
      if (pointer(po2)-pointer(felementdata) = aparent) then begin
       element:= po1^.data.data;
       result:= (akinds = []) or (po3^.header.kind in akinds);
       exit;
      end;
     end;
 next:
     if po1^.header.nexthash = 0 then begin
      break;
     end;
     po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
    end;
   end;
  until not checkancestor(aparent,avislevel);
 end;
end;

function telementhashdatalist.findchilddata(const aparent: elementoffsetty; 
                 const achildtree: array of identty;
                 const akinds: elementkindsty;
                 const avislevel: visikindsty;
                               out adata: pointer): boolean;
var
 ele1: elementoffsetty;
begin
 adata:= nil;
 result:= findchild(aparent,achildtree,akinds,avislevel,ele1);
 if result then begin
  adata:= ele1+pointer(felementdata)+eledatashift;
 end;
end;

function telementhashdatalist.findchild(aparent: elementoffsetty; 
                 const achild: identty;
                 const akinds: elementkindsty;
                 avislevel: visikindsty;
                               out element: elementoffsetty): boolean;
var
 int1: integer;
 id1: identty;
 uint1: ptruint;
 po1: pelementhashdataty;
 po2,po3: pelementinfoty;
label
 next;
begin
 result:= false;
 repeat
  with pelementinfoty(pointer(felementdata)+aparent)^ do begin
   id1:= header.path + header.name + achild;
  end;
  uint1:= fhashtable[id1 and fmask];
  if uint1 <> 0 then begin
   po1:= pelementhashdataty(pchar(fdata) + uint1);
   while true do begin
    if po1^.data.key = id1 then begin
     po2:= pelementinfoty(pointer(felementdata)+po1^.data.data);
     if (po2^.header.name <> achild) or 
                           (po2^.header.parent <> aparent) then begin
      goto next;
     end;
     element:= po1^.data.data;
     result:= (po2^.header.visibility*avislevel <> []) and
                 ((akinds = []) or (po2^.header.kind in akinds));
     exit;
    end;
next:
    if po1^.header.nexthash = 0 then begin
     break;
    end;
    po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 until not checkancestor(aparent,avislevel);
end;

function telementhashdatalist.findchilddata(const aparent: elementoffsetty; 
                 const achild: identty; const akinds: elementkindsty;
                 const avislevel: visikindsty;
                               out adata: pointer): boolean;
var
 ele1: elementoffsetty;
begin
 adata:= nil;
 result:= findchild(aparent,achild,akinds,avislevel,ele1);
 if result then begin
  adata:= ele1+pointer(felementdata)+eledatashift;
 end;
end;

function telementhashdatalist.findchild(const aparent: elementoffsetty;
                 const achild: identty; const akinds: elementkindsty;
                 const avislevel: visikindsty; 
               out element: elementoffsetty; out adata: pointer): elementkindty;
begin
 result:= ek_none;
 adata:= nil;
 if findchild(aparent,achild,akinds,avislevel,element) then begin
  adata:= element+pointer(felementdata)+eledatashift;
  result:= pelementinfoty(adata-eledatashift)^.header.kind;
 end;
end;

{
function telementhashdatalist.findchild(const aparent: elementoffsetty; 
                 const achild: identty; const avislevel: visikindsty; 
               out element: elementoffsetty; out adata: pointer): elementkindty;
var 
 ele1: elementoffsetty;
begin
 ele1:= elementparent;
 elementparent:= aparent;
 if findcurrent(achild,[],avislevel,element) then begin
  adata:= eleinfoabs(element);
  result:= pelementinfoty(adata)^.header.kind;
  inc(adata,eledatashift);
 end
 else begin
  result:= ek_none;
  adata:= nil;
 end;
 elementparent:= ele1;
end;
}

function telementhashdatalist.findparentscope(const aident: identty;
               const akinds: elementkindsty; const avislevel: visikindsty;
               out aparent: elementoffsetty): boolean;
var
 uint1: ptruint;
 po1: pelementhashdataty;
 po2: pscopeinfoty;
 id1: identty;
label
 endloop;
begin
 result:= false;
 if (fscopespo <> nil) and (count > 0) then begin // check "with" and the like 
  po2:= fscopespo;
  while true do begin
   with pelementinfoty(pointer(felementdata)+po2^.childparent)^ do begin
    id1:= header.path+header.name+aident;
    uint1:= fhashtable[id1 and fmask];
    if uint1 <> 0 then begin
     po1:= pelementhashdataty(pchar(fdata) + uint1);
     while true do begin
      if (po1^.data.key = id1) then begin
       with pelementinfoty(
              pointer(felementdata)+po1^.data.data)^.header do begin //child
        if (name = aident) and (parent = po2^.childparent) then begin
          with pelementinfoty(pointer(felementdata) +
                                po2^.childparent)^.header do begin //parent
          if ((visibility * avislevel <> [])  or 
          (vik_sameunit in visibility) and (defunit = info.s.unitinfo^.key)) and 
                             ((akinds = []) or (kind in akinds)) then begin
           aparent:= po2^.element;
           result:= true;
           exit;
          end;
         end;
        end;
       end;
      end;
      if po1^.header.nexthash = 0 then begin
       goto endloop; //not found
      end;
      po1:= pelementhashdataty(pchar(fdata) + po1^.header.nexthash);
     end;
    end;
   end;
endloop:
   if po2 = fscopes then begin
    break;
   end;
   dec(po2);
  end; 
 end;
end;

{$ifdef mse_debugparser}
function telementhashdatalist.dumpelements: msestringarty;

 function dumptyp(const atyp: elementoffsetty): msestring;
 var
  po2: pelementinfoty;
 begin
  if atyp < 0 then begin
   result:= ' T:invalid';
  end
  else begin
   po2:= eleinfoabs(atyp);
   result:= ' T:'+inttostr(atyp)+':'+getidentname(po2^.header.name);
   with ptypedataty(@po2^.data)^ do begin
    result:= result+' B:'+inttostr(h.base);
    result:= result+' K:'+getenumname(typeinfo(h.kind),ord(h.kind));
    if h.kind <> dk_none then begin
     result:= result+
     ' F:'+settostring(ptypeinfo(typeinfo(h.flags)),integer(h.flags),false)+
     ' S:'+inttostr(h.bytesize)+' I:'+inttostr(h.indirectlevel);
     case h.kind of
      dk_enumitem: begin
       result:= result+' value:'+inttostr(infoenumitem.value);
      end;
      dk_set: begin
       result:= result+' itemtyp:'+inttostr(infoset.itemtype);
      end;
      dk_interface: begin
       result:= result+' subco:'+inttostr(infointerface.subcount);
      end;
      dk_sub: begin
       result:= result+' sub:'+inttostr(infosub.sub);
      end;
     end;
    end;
   end;
  end;
 end; //dumptyp
 
var
 int1,int2,int3,int4,int5,int6: integer;
 po1,po2,po3: pelementinfoty;
 mstr1,mstr2: msestring;
 ar1: dumpinfoarty;
 off1: elementoffsetty;
 ar2: msestringarty;
 po4: pscopeinfoty;
 po5: popaddressty;
begin
 int1:= 0;
 int2:= 0;
 int5:= pelementinfoty(pointer(felementdata))^.header.name; //root
 while int1 < fnextelement do begin
  msearrayutils.additem(ar1,typeinfo(dumpinfoty),int2);
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
            ' '+getidentname(po1^.header.name) + 
            ' '+getenumname(typeinfo(po1^.header.kind),ord(po1^.header.kind))+
             ' V:'+settostring(ptypeinfo(typeinfo(po1^.header.visibility)),
                                 integer(po1^.header.visibility),false);
  case po1^.header.kind of
   ek_var: begin
    with pvardataty(@po1^.data)^ do begin
     mstr1:= mstr1+lineend+' A:'+inttostr(address.poaddress)+' I:'+
               inttostr(address.indirectlevel)+ ' ' +
           settostring(ptypeinfo(typeinfo(address.flags)),
                                         integer(address.flags),false);
     if af_segment in address.flags then begin
      mstr1:= mstr1+' S:'+getenumname(typeinfo(segmentty),
                                    ord(address.segaddress.segment));
     end
     else begin
      mstr1:= mstr1+' L:'+inttostr(address.locaddress.framelevel);
     end;               

     mstr1:= mstr1 + dumptyp(vf.typ);
     {
     po2:= eleinfoabs(vf.typ);
     mstr1:= mstr1+' T:'+inttostr(vf.typ)+':'+getidentname(po2^.header.name);
     with ptypedataty(@po2^.data)^ do begin
      mstr1:= mstr1+' K:'+getenumname(typeinfo(kind),ord(kind))+
       ' S:'+inttostr(bytesize)+' I:'+inttostr(indirectlevel);
     end;
     }
    end;
   end;
   ek_field: begin
    with pfielddataty(@po1^.data)^ do begin
     mstr1:= mstr1+lineend+' O:'+inttostr(offset)+
          ' I:'+inttostr(indirectlevel)+' '+
           settostring(ptypeinfo(typeinfo(flags)),
                                         integer(flags),false);
     mstr1:= mstr1+dumptyp(vf.typ);
    {
     po2:= eleinfoabs(vf.typ);
     mstr1:= mstr1+' T:'+inttostr(vf.typ)+':'+getidentname(po2^.header.name);
     with ptypedataty(@po2^.data)^ do begin
      mstr1:= mstr1+' K:'+getenumname(typeinfo(kind),ord(kind))+
       ' S:'+inttostr(bytesize);
     end;
    }
    end;
   end;
   ek_type: begin
    with ptypedataty(@po1^.data)^ do begin
     mstr1:= mstr1+lineend+dumptyp(off1);
     {
     ' K:'+getenumname(typeinfo(kind),ord(kind))+
                      ' S:'+inttostr(bytesize)+' I:'+inttostr(indirectlevel);
     }
     if h.kind in ancestordatakinds then begin
      mstr1:= mstr1+' A:'+inttostr(h.ancestor);
      case h.kind of
       dk_class: begin
        mstr1:= mstr1+' alloc:'+inttostr(infoclass.allocsize)+
                      ' virt:'+inttostr(infoclass.virtualcount)+
                      ' intf:'+inttostr(infoclass.interfacecount)+
                      ' isub:'+inttostr(infoclass.interfacesubcount)+
                      ' defs:'+inttostr(infoclass.defs.address);
        po5:= @classdefinfoty(getsegmentpo(infoclass.defs)^).virtualmethods;
        for int6:= 0 to infoclass.virtualcount-1 do begin
         if int6 mod 5 = 0 then begin
          mstr1:= mstr1+lineend+'  ';
         end;
         mstr1:= mstr1+inttostrlen(po5^,4)+' ';
         inc(po5);
        end;
       end;
      end;
     end;
     po3:= po1;
    end;
   end;
   {
   ek_managed: begin
    with pmanageddataty(@po1^.data)^ do begin
     mstr1:= mstr1+' E:'+inttostr(managedele);
    end;
   end;
   }
   ek_sub: begin
    with psubdataty(@po1^.data)^ do begin
     mstr1:= mstr1+lineend+
     ' F:'+settostring(ptypeinfo(typeinfo(flags)),integer(flags),false)+
     ' idx:'+inttostr(tableindex)+' impl:'+inttostr(impl)+
     ' op:'+inttostr(address);
     if flags * [sf_functiontype,sf_constructor] <> [] then begin
      mstr1:= mstr1+lineend+' result:'+dumptyp(resulttype);
     end;
    end;
   end;
   ek_uses: begin
    with pusesdataty(@po1^.data)^ do begin
     mstr1:= mstr1 + ' U:'+inttostr(ref);
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
   if mstr1[1] = '*' then begin
    ar2[0][1]:= ' ';
    mstr2:= '*';
   end
   else begin
    mstr2:= ' ';
   end;
   ar2[0]:= mstr2+charstring(msechar('.'),int3)+'$'+
                 hextostr(longword(int5+int4+po1^.header.name),8)+ar2[0];
//                 hextostr(longword(po1^.header.path),8)+ar2[0];
   mstr2:= charstring(msechar(' '),int3+1);
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
 msearrayutils.additem(result,'---SCOPES');
 if fscopespo <> nil then begin
  int1:= length(result);
  setlength(result,length(result)+(fscopespo-pscopeinfoty(fscopes))+1);
  po4:= fscopes;
  for int1:= int1 to high(result) do begin
   po1:= ele.eleinfoabs(po4^.element);
   mstr1:= getenumname(typeinfo(po1^.header.kind),ord(po1^.header.kind));
   po1:= ele.eleinfoabs(po4^.childparent);
   mstr1:= mstr1+' CP:'+
    getenumname(typeinfo(po1^.header.kind),ord(po1^.header.kind))+
    ' '+getidentname(po1^.header.name);
   result[int1]:= mstr1;
   inc(po4);
  end;
 end;
end;

function telementhashdatalist.dumppath(const aelement: pelementinfoty): msestring;
var
 po1: pelementinfoty;
begin
 result:= '';
 po1:= aelement;
 result:= getidentname(po1^.header.name);
 while po1^.header.parent <> 0 do begin
  po1:= pointer(felementdata)+po1^.header.parent;
  result:= getidentname(po1^.header.name)+'.'+result;
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

procedure telementhashdatalist.checkcapacity(const akind: elementkindty;
                                                  const acount: integer = 1);
var
 ele1: elementoffsetty;
begin
 ele1:= elesizes[akind]*acount;
 if fnextelement+ele1 >= felementlen then begin
  felementlen:= fnextelement*2+mindatasize+ele1;
  setlength(felementdata,felementlen);
 end;
end;

function telementhashdatalist.addbuffer(const asize: int32): pointer;
var
 ele1: elementoffsetty;
begin
 ele1:= fnextelement;
 fnextelement:= fnextelement+alignsize(asize);
 checkbuffersize();
 result:= pointer(felementdata)+ele1;
end;

function telementhashdatalist.pushelementduplicate(const aname: identty;
                  const akind: elementkindty;
                  const avislevel: visikindsty;
                  const sizeextend: integer): pelementinfoty;
var
 ele1: elementoffsetty;
begin
 ele1:= fnextelement;
 fnextelement:= fnextelement+(elesizes[akind])+alignsize(sizeextend);
 checkbuffersize;
 result:= pointer(felementdata)+ele1;
 with result^.header do begin
 {$ifdef mse_debugparser}
  next:= fnextelement; //for debugging
 {$endif}
  parent:= felementparent;
  parentlevel:= fparentlevel;
  path:= felementpath;
  name:= aname;
  visibility:= avislevel;
  if info.s.unitinfo <> nil then begin
   defunit:= info.s.unitinfo^.key;
  end
  else begin
   defunit:= 0;
  end;
  kind:= akind;
 end;
 felementparent:= ele1;
 inc(fparentlevel);
 if fparentlevel >= maxidentvector then begin
  errormessage(err_toomanynestinglevels,[]);
 end;
 felementpath:= felementpath+aname;
 addelement(felementpath,avislevel,ele1);
end;

function telementhashdatalist.pushelementduplicatedata(const aname: identty;
               const akind: elementkindty; const avislevel: visikindsty;
               out adata: pointer): boolean;
var
 ele1: elementoffsetty;
begin
 result:= not findcurrent(aname,[],allvisi,ele1);
 adata:= pointer(pushelementduplicate(aname,akind,avislevel,0)) + eledatashift;
end;

function telementhashdatalist.pushelement(const aname: identty;
             const akind: elementkindty; 
             const avislevel: visikindsty): pelementinfoty;
var
 ele1: elementoffsetty;
begin
 result:= nil;
 if not findcurrent(aname,[],allvisi{ffindvislevel},ele1) then begin
  result:= pushelementduplicate(aname,akind,avislevel,0);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
            const akind: elementkindty; const avislevel: visikindsty;
                   out aelementdata: pointer): boolean; //false if duplicate
begin
 aelementdata:= pushelement(aname,akind,avislevel);
 result:= aelementdata <> nil;
 if result then begin
  aelementdata:= @(pelementinfoty(aelementdata)^.data);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
           const akind: elementkindty; const avislevel: visikindsty;
           out aelementdata: elementoffsetty): boolean;
                                                    //false if duplicate
var
 po1: pelementinfoty;
begin
 po1:= pushelement(aname,akind,avislevel);
 result:= po1 <> nil;
 if result then begin
  aelementdata:= pointer(po1)-pointer(felementdata);
 end;
end;

function telementhashdatalist.pushelement(const aname: identty;
       const akind: elementkindty;                  
       const avislevel: visikindsty;
       const sizeextend: integer; out aelementdata: pointer): boolean;
                                                       //false if duplicate
var
 po1: pelementinfoty;
 ele1: elementoffsetty;
begin
 result:= false;
 if not findcurrent(aname,[],allvisi{ffindvislevel},ele1) then begin
  po1:= pushelementduplicate(aname,akind,avislevel,sizeextend);
  aelementdata:= @(po1^.data);
 end;
end;

function telementhashdatalist.addelementduplicate1(const aname: identty;
                                const akind: elementkindty;
                                const avislevel: visikindsty): elementoffsetty;
//var
// ele1: elementoffsetty;
begin
 result:= fnextelement;
 fnextelement:= fnextelement+elesizes[akind];
 checkbuffersize;
// result:= pointer(felementdata)+ele1;
 with eleinfoabs(result)^.header do begin
 {$ifdef mse_debugparser}
  next:= fnextelement;
 {$endif}
  parent:= felementparent;
  parentlevel:= fparentlevel;
  path:= felementpath;
  name:= aname;
  visibility:= avislevel;
  if info.s.unitinfo <> nil then begin
   defunit:= info.s.unitinfo^.key;
  end
  else begin
   defunit:= 0;
  end;
  kind:= akind;
 end; 
 addelement(felementpath+aname,avislevel,result);
end;

function telementhashdatalist.addelementduplicatedata1(const aname: identty;
                                const akind: elementkindty;
                                const avislevel: visikindsty): pointer;
begin
 result:= addelementduplicate1(aname,akind,avislevel) +
                        pointer(felementdata) + eledatashift;
end;

function telementhashdatalist.addelementduplicate(const aname: identty;
                                const akind: elementkindty;
                                const avislevel: visikindsty): pelementinfoty;
begin
 result:= eleinfoabs(addelementduplicate1(aname,akind,avislevel));
end;

function telementhashdatalist.addelementduplicatedata(const aname: identty;
               const akind: elementkindty;
               const avislevel: visikindsty; out aelementdata: pointer;
               const asearchlevel: visikindsty = allvisi): boolean;
var
 ele1: elementoffsetty;
begin
 result:= not findcurrent(aname,[],asearchlevel,ele1);
 aelementdata:= eledataabs(addelementduplicate1(aname,akind,avislevel));
end;             

function telementhashdatalist.addelement(const aname: identty;
              const akind: elementkindty; 
              const avislevel: visikindsty): pelementinfoty;   
                                                   //nil if duplicate
var
 scopebefore: pscopeinfoty;
 ele1: elementoffsetty;
begin
 result:= nil;
 scopebefore:= fscopespo;
 fscopespo:= nil;
 if not findcurrent(aname,[],allvisi{ffindvislevel},ele1) then begin
  result:= addelementduplicate(aname,akind,avislevel);
 end;
 fscopespo:= scopebefore;
end;

function telementhashdatalist.addelementdata(const aname: identty; 
                       const akind: elementkindty;
                       const avislevel: visikindsty): pointer; 
                                              //nil if duplicate
begin
 result:= addelement(aname,akind,avislevel);
 if result <> nil then begin
  result:= @pelementinfoty(result)^.data;
 end;
end;

function telementhashdatalist.addelementdata(const aname: identty;
           const akind: elementkindty; const avislevel: visikindsty;
           out aelementdata: pointer): boolean;
         //false if duplicate, aelementdata = new or duplicate
var
 scopebefore: pscopeinfoty;
 ele1: elementoffsetty;
begin
 scopebefore:= fscopespo;
 fscopespo:= nil;
 result:= not findcurrent(aname,[],allvisi{ffindvislevel},ele1);
 if result then begin
  aelementdata:= eledataabs(addelementduplicate1(aname,akind,avislevel));
 end
 else begin
  aelementdata:= eledataabs(ele1);
 end;
 fscopespo:= scopebefore;
end;

function telementhashdatalist.addelement(const aname: identty;
              const akind: elementkindty;
              const avislevel: visikindsty;
              out aelementoffset: elementoffsetty): boolean;
         //false if duplicate, aelementoffset = 0 if duplicate
var
 po1: pelementinfoty;
begin
 po1:= addelement(aname,akind,avislevel);
 result:= po1 <> nil;
 if result then begin
  aelementoffset:= pointer(po1)-pointer(felementdata);
 end
 else begin
  aelementoffset:= 0;
 end;
end;

function telementhashdatalist.adduniquechilddata(const aparent: elementoffsetty;
                           const achild: array of identty;
                           const akind: elementkindty;
                           const avislevel: visikindsty;
                           out aelementdata: pointer): boolean;
var
 parentbefore: elementoffsetty;
 i1: int32;
 ele1: elementoffsetty;
begin
 result:= not findchilddata(aparent,achild,[akind],avislevel,aelementdata);
 if result then begin
  parentbefore:= felementparent;
  ele1:= aparent;
  for i1:= 0 to high(achild) - 1 do begin
   if not findchild(ele1,[achild[i1]],[],allvisi,ele1) then begin
    elementparent:= ele1;
    ele1:= addelementduplicate1(achild[i1],ek_none,allvisi);
   end;
  end;
  elementparent:= ele1;
  aelementdata:= addelementduplicatedata1(achild[high(achild)],akind,avislevel);
  elementparent:= parentbefore;
 end;
end;

function telementhashdatalist.addchildduplicatedata(
                           const aparent: elementoffsetty;
                           const achild: array of identty; 
                           const akind: elementkindty;
                           const avislevel: visikindsty): pointer;
var
 parentbefore: elementoffsetty;
 i1: int32;
 ele1: elementoffsetty;
begin
 parentbefore:= felementparent;
 ele1:= aparent;
 for i1:= 0 to high(achild) - 1 do begin
  if not findchild(ele1,[achild[i1]],[],allvisi,ele1) then begin
   elementparent:= ele1;
   ele1:= addelementduplicate1(achild[i1],ek_none,allvisi);
  end;
 end;
 elementparent:= ele1;
 result:= addelementduplicatedata1(achild[high(achild)],akind,avislevel);
 elementparent:= parentbefore;
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
 ref.bufferref:= fnextelement;
end;

procedure telementhashdatalist.releaseelement(const ref: markinfoty);
begin
 release(ref.hashref);
 fnextelement:= ref.bufferref;
end;

procedure telementhashdatalist.hideelementdata(const adata: pointer);
begin
 with pelementinfoty(adata-sizeof(elementheaderty))^.header do begin
  path:= path-name;
  name:= 0;
 end;
end;

procedure telementhashdatalist.pushscopelevel;
begin
 inc(fscopestackpo);
 if fscopestackpo >= fscopestacksize then begin
  fscopestacksize:= fscopestacksize*2+16;
  setlength(fscopestack,fscopestacksize);
 end;
 if fscopes = nil then begin
  fscopestack[fscopestackpo]:= -1;
 end
 else begin
  fscopestack[fscopestackpo]:= pointer(fscopespo)-fscopes;
 end;
end;

procedure telementhashdatalist.popscopelevel;
var
 int1,int2: integer;
begin
 if fscopestackpo < 0 then begin
 {$ifdef mse_checkinternalerror}
  internalerror(ie_elements,'E20140406C');
 {$endif}
 end
 else begin
  int2:= fscopestack[fscopestackpo];
  if int2 < 0 then begin
   fscopespo:= nil;
  end
  else begin
   fscopespo:= fscopes + int2;
  end;
  dec(fscopestackpo);
 end; 
end;

function telementhashdatalist.addscope(const akind: elementkindty;
                                 const achildparent: elementoffsetty): pointer;
var
 int1: integer;
begin
 if fscopespo = nil then begin
  fscopespo:= fscopes;
 end
 else begin
  inc(fscopespo);
  if fscopespo >= fscopesend then begin
   int1:= fscopespo-fscopes;
   reallocmem(fscopes,int1*2);
   fscopesend:= fscopes + int1*2;
   fscopespo:= fscopes + int1;
  end;
 end;
 result:= addelement(getident(),akind,globalvisi);
 if result = nil then begin
 {$ifdef mse_checkinternalerror}
  internalerror(ie_elements,'20140407B'); //duplicate id
 {$endif}
 end;
 with fscopespo^ do begin
  element:= result-pointer(felementdata);
  childparent:= achildparent;
 end;
 inc(result,eledatashift);
end;

procedure telementhashdatalist.pushelementparent(
                                           const aparent: elementoffsetty);
begin
{$ifdef mse_checkinternalerror}
 if fparentindex > maxparents then begin
  internalerror(ie_elements,'201400412A');
 end;
{$endif}
 fparents[fparentindex]:= elementparent;
 elementparent:= aparent;
 inc(fparentindex);
end;

procedure telementhashdatalist.pushelementparent(); //save current on stack
begin
{$ifdef mse_checkinternalerror}
 if fparentindex > maxparents then begin
  internalerror(ie_elements,'201400412A');
 end;
{$endif}
 fparents[fparentindex]:= elementparent;
 inc(fparentindex);
end;

procedure telementhashdatalist.popelementparent;
begin
{$ifdef mse_checkinternalerror}
 if fparentindex = 0 then begin
  internalerror(ie_elements,'201400412B');
 end;
{$endif}
 dec(fparentindex);
 elementparent:= fparents[fparentindex];
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

function tstringbuffer.add(const avalue: string): stringvaluety;
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
 
function tstringbuffer.allocconst(const astring: stringvaluety): segaddressty;
var
 po1: pstring8headerty;
 fla1: addressflagsty;
begin
 with pstringbufdataty(fdata+astring.offset)^ do begin
  if constoffset = 0 then begin
   result:= getglobconstaddress(sizeof(string8headerty)+len+1,fla1);
   constoffset:= result.address;
   with info do begin    
    po1:= getsegmentpo(result);
    po1^.ref.count:= -1;
    po1^.len:= len;
    inc(po1); //data
    move((fbuffer+offset)^,po1^,len);
    pbyte(pointer(po1))[len]:= 0;
   end;
  end;
  if len = 0 then begin
   result.address:= 0;
   result.segment:= seg_nil;
  end
  else begin
   result.segment:= seg_globconst;
   result.address:= constoffset+sizeof(string8headerty);
   if co_llvm in info.compileoptions then begin
    result.address:= constlist.adddataoffs(result.address).listid;
   end;
  end;
 end;
end;

initialization
 identlist:= tindexidenthashdatalist.create;
 stringbuf:= tstringbuffer.create;
 ele:= telementhashdatalist.create;
 typelist:= ttypehashdatalist.create();
 constlist:= tconsthashdatalist.create(typelist);
 globlist:= tgloballocdatalist.create(typelist,constlist);
 clear();
finalization
 identlist.free();
 stringbuf.free();
 ele.free();
 typelist.free();
 constlist.free();
 globlist.free();
end.
