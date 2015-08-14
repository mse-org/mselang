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
unit unithandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,mselinklist,listutils,msestrings,parserglob,opglob,elements,
 handlerglob,msetypes;

type
 unitlinkinfoty = record  //used for ini, fini
  header: linkheaderty;
  ref: punitinfoty
 end;
 punitlinkinfoty = ^unitlinkinfoty;
var 
 unitlinklist: linklistty;
 unitchain: listadty;
 intfparsedlinklist: linklistty;
 intfparsedchain: listadty;

function newunit(const aname: string): punitinfoty; 
function getunitfile(const aunit: punitinfoty; const aname: lstringty): boolean;
function getunitfile(const aunit: punitinfoty;
                                        const aname: filenamety): boolean;
function initunitfileinfo(const aunit: punitinfoty): boolean;

function loadunitbyid(const aid: identty; 
                    const astackoffset: int32 = minint): punitinfoty;
function loadunit(const aindex: integer): punitinfoty;
function parsecompilerunit(const aname: filenamety): boolean;

procedure handleprogramentry();
procedure beginunit(const aname: identty; const nopush: boolean);
procedure setunitname(); //unitname on top of stack
function getunitname(const id: identty): string;
function getunittimestamp(const id: identty): tdatetime;
//procedure setunitsubname(aindex: int32); //sets namebuffer

//procedure interfacestop();

procedure markinterfacestart();
{
procedure markinterfaceend();
procedure markimplementationstart();
procedure markunitend();
}
procedure handleuseserror();
procedure handleuses();

procedure handleafterintfuses();
procedure handleimplementationentry();
procedure handleimplusesentry();
procedure handleafterimpluses();
procedure handleimplementation();
procedure handleinclude();

procedure linkmark(var alinks: linkindexty; const aaddress: segaddressty;
                                                  const offset: integer  = 0);
procedure linkresolveopad(const alinks: linkindexty; 
                                                 const aaddress: opaddressty);
procedure linkresolveint(const alinks: linkindexty; const avalue: int32);

procedure forwardmark(out aforward: forwardindexty; const asource: sourceinfoty);
procedure forwardresolve(const aforward: forwardindexty);
procedure checkforwarderrors(const aforward: forwardindexty);
//function addtypedef(const aname: identty; const avislevel: visikindsty;
//                                        out aelementdata: pointer): boolean;
procedure markforwardtype(const atype: ptypedataty; const aforwardname: identty);
procedure resolveforwardtype(const atype: ptypedataty);
procedure checkforwardtypeerrors();

procedure regclass(const aclass: elementoffsetty);
procedure regclassdescendent(const aclass: elementoffsetty;
                                const aancestor: elementoffsetty);
procedure handleunitend();
//procedure handleinifini();
procedure handleinitializationstart();
procedure handleinitialization();
procedure handlefinalizationstart();
procedure handlefinalization();

procedure beginunit(const aunit: punitinfoty);
function endunit(const aunit: punitinfoty): boolean;
procedure finalizeunit(const aunit: punitinfoty);

procedure init;
procedure deinit(const freeunitlist: boolean);

implementation
uses
 msehash,filehandler,errorhandler,parser,msefileutils,msestream,grammar,
 handlerutils,msearrayutils,opcode,subhandler,exceptionhandler,llvmlists,
 {stackops,}segmentutils,classhandler,compilerunit,managedtypes,
 unitwriter,identutils,mseformatstr,sysutils;
 
type
 unithashdataty = record
  header: hashheaderty;
  data: punitinfoty;
 end;
 punithashdataty = ^unithashdataty;

 tunitlist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
   procedure finalizeitem(var aitemdata); override;
  public
   constructor create;
   function findunit(const aname: identty): punitinfoty;
   function newunit(const aname: identty): punitinfoty;
 end;

var
 unitlist: tunitlist;

procedure handleprogramentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROGRAMENTRY');
{$endif}
 with info,s.unitinfo^ do begin
  if prev <> nil then begin
   tokenexpectederror(tk_unit);
  end;  
 end;
end;

procedure beginunit(const aname: identty; const nopush: boolean);
var
 po1: punitdataty;
 lstr1: lstringty;
begin
 if nopush then begin
 {$ifdef mse_checkinternalerror}
  if not ele.adduniquechilddata(unitsele,[aname],ek_unit,
                                           [vik_units],po1) then begin
   internalerror(ie_unit,'150710A');
  end;
 {$else}
  ele.adduniquechilddata(unitsele,[aname],ek_unit,[vik_units],po1);
 {$endif}
 end
 else begin
 {$ifdef mse_checkinternalerror}                             
  if not ele.pushelement(aname,ek_unit,[vik_units],po1) then begin
   internalerror(ie_unit,'131018A');
  end;
 {$else}
  ele.pushelement(aname,ek_unit,[vik_units],po1);
 {$endif}
 end;
 with info do begin
  po1^.next:= unitinfochain;
  unitinfochain:= ele.eledatarel(po1);
  with s.unitinfo^ do begin
   if nopush then begin
    interfaceelement:= ele.eledatarel(po1);
   end
   else begin
    interfaceelement:= ele.elementparent;
   end;
   getidentname(aname,lstr1);
   namestring:= lstringtostring(lstr1);
   name:= stringtolstring(namestring);
   {
   getidentname(aname,lstr1);
   move(lstr1.po^,namebufferdata,lstr1.len);
   namebufferdata[lstr1.len]:= '_';
   namebufferstart:= lstr1.len + 1;
   namebuffer.po:= @namebufferdata;
   namebuffer.len:= lstr1.len+1+2*sizeof(int32);
   }
  end;
 end;
end;

procedure markinterfacestart();
begin
 with info.s.unitinfo^ do begin
  ele.markelement(interfacestart); 
  reloc.interfaceelestart:= interfacestart.bufferref;
  reloc.interfaceglobstart:= info.globdatapo;
 end;
end;

procedure markinterfaceend();
begin
 with info.s.unitinfo^ do begin
  ele.markelement(interfaceend);
  reloc.interfaceelesize:= interfaceend.bufferref- interfacestart.bufferref;
  reloc.interfaceglobsize:= info.globdatapo - reloc.interfaceglobstart;
 end;
end;

procedure markimplementationstart();
begin
 with info.s.unitinfo^ do begin
  ele.markelement(implementationstart);
  implementationglobstart:= info.globdatapo;
  reloc.opstart:= info.opcount;
  opseg:= getsubsegment(seg_op);
  with additem(oc_beginunitcode)^ do begin
  end;
 end;
end;

procedure markunitend();
begin
 with info.s.unitinfo^ do begin
  setsubsegmentsize(opseg);
  reloc.opsize:= info.opcount-reloc.opstart;
  implementationglobsize:= info.globdatapo - implementationglobstart;
 end;
end;

procedure setunitname(); //unitname on top of stack
var
 id1: identty;
// po2: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('SETUNITNAME');
{$endif}
 with info do begin
  id1:= contextstack[s.stacktop].d.ident.ident;
  if (s.unitinfo^.key <> id1) and (s.unitinfo^.prev <> nil) then begin
   identerror(1,err_illegalunitname);
  end
  else begin
   s.unitinfo^.key:= id1; //overwrite "program"
   beginunit(id1,false);
   markinterfacestart();
//   ele.markelement(s.unitinfo^.interfacestart);
  end;
  s.stacktop:= s.stackindex;
 end;
end;

(*
procedure interfacestop();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACESTOP');
{$endif}
 with info do begin
  include(unitinfo^.state,us_interfaceparsed);
 end;
end;
*)

procedure handleuseserror();
begin
{$ifdef mse_debugparser}
 outhandle('USESERROR');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleuses();
var
 int1,int2: integer;
// offs1: elementoffsetty;
 po1: ppunitinfoty;
 ar1: elementoffsetarty;
begin
{$ifdef mse_debugparser}
 outhandle('USES');
{$endif}
 with info do begin
  int2:= s.stacktop-s.stackindex-1;
  setlength(ar1,int2);
  for int1:= 0 to int2-1 do begin
   if not ele.addelement(contextstack[s.stackindex+int1+2].d.ident.ident,
                                    ek_uses,[vik_global],ar1[int1]) then begin
    identerror(int1+2,err_duplicateidentifier);
   end;
  end;
//  offs1:= ele.decelementparent;
  with s.unitinfo^ do begin
   if us_interfaceparsed in state then begin
//    ele.decelementparent;
    setlength(implementationuses,int2);
    po1:= pointer(implementationuses);
   end
   else begin
    setlength(interfaceuses,int2);
    po1:= pointer(interfaceuses);
   end;
  end;
  inc(po1,int2);
  int2:= 0;
  for int1:= s.stackindex+2 to s.stacktop do begin
   dec(po1);
   po1^:= loadunit(int1);
   if po1^ = nil then begin
    s.stopparser:= true;
    break;
   end;
   if ar1[int2] <> 0 then begin
    with pusesdataty(ele.eledataabs(ar1[int2]))^ do begin
     ref:= po1^^.interfaceelement;
    end;
   end;
   inc(int2);
  end;
//  ele.elementparent:= offs1;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleafterintfuses();
begin
{$ifdef mse_debugparser}
 outhandle('AFTERINTFUSES');
{$endif}
 with info do begin
  markinterfacestart();
//  ele.markelement(s.unitinfo^.interfacestart);
  with contextstack[s.stackindex] do begin
   d.kind:= ck_interface;
//   ele.markelement(d.impl.elemark);
  end;
 end;
end;

procedure handleimplementationentry();
var
 po1: pimplementationdataty;
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATIONENTRY');
{$endif}
 checkforwardtypeerrors();
 markinterfaceend();
 with info do begin
  include(s.unitinfo^.state,us_interfaceparsed);
  if us_implementation in s.unitinfo^.state then begin
   errormessage(err_invalidtoken,['implementation']);
  end
  else begin
   include(s.unitinfo^.state,us_implementation);
   include(s.currentstatementflags,stf_implementation);
  {$ifdef mse_checkinternalerror}                             
   if not ele.pushelement(tk_implementation,ek_implementation,
                                    implementationvisi,po1) then begin
    internalerror(ie_unit,'20131130A');
   end;
  {$else}
   ele.pushelement(tk_implementation,ek_implementation,implementationvisi,po1);
  {$endif}
   s.unitinfo^.implementationelement:= ele.eledatarel(po1);
{
   s.unitinfo^.impl.sourceoffset:= s.source.po - s.sourcestart;
   if s.interfaceonly then begin
    s.stopparser:= true;
   end;
}
  end;
  with contextstack[s.stackindex] do begin
   d.kind:= ck_implementation;
//   ele.markelement(d.impl.elemark);
  end;
 end;
end;

procedure handleimplusesentry();
begin
{$ifdef mse_debugparser}
 outhandle('IMPLUSESENTRY');
{$endif}
 with info do begin
  if s.interfaceonly then begin
   saveparsercontext(s.unitinfo^.implstart,2);
   s.stopparser:= true;
  end;
 end;
end;

procedure handleafterimpluses();
begin
{$ifdef mse_debugparser}
 outhandle('AFTERIMPLUSES');
{$endif}
 markimplementationstart();
end;

procedure handleimplementation();
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATION');
{$endif}
 checkforwardtypeerrors();
 markunitend();
 with info do begin
  with s.unitinfo^ do begin
//   setsubsegmentsize(opseg);
   if unitlevel > 1 then begin
    ele.releaseelement(implementationstart);
        //possible pending implementation units
        //todo: compile implementation units as soon as possible in order to
        //save resources
   end;
   freeparsercontext(implstart);
   include(state,us_implementationparsed);
  end;
  dec(s.stackindex);
 end;
end;

procedure handleinclude();
var
 lstr1: lstringty;
 filepath: filenamety;
begin
{$ifdef mse_debugparser}
 outhandle('INCLUDE');
{$endif} 
 with info do begin
  if stringbuffer <> '' then begin
   lstr1.po:= pointer(stringbuffer);
   lstr1.len:= length(stringbuffer);
   filepath:= filehandler.getincludefile(lstr1);
   if filepath = '' then begin
    errormessage(err_cannotfindinclude,[],s.stacktop-s.stackindex);
   end
   else begin
    pushincludefile(filepath);
   end;
  end;
  dec(s.stackindex,2);
 end;
end;

function newunit(const aname: string): punitinfoty; 
var
 id: identty;
begin
 id:= getident(aname);
 result:= unitlist.findunit(id);
 if result = nil then begin
  result:= unitlist.newunit(id);
  result^.namestring:= aname;
  result^.name:= stringtolstring(result^.namestring);
 end;
end;

function getunitname(const id: identty): string;
var
 po1: punitinfoty;
begin
 po1:= unitlist.findunit(id);
 if po1 <> nil then begin
  result:= po1^.namestring;
 end
 else begin
  result:= '';
 end;
end;

function getunittimestamp(const id: identty): tdatetime;
var
 po1: punitinfoty;
 lstr1: lstringty;
 fna1: filenamety;
begin
 po1:= unitlist.findunit(id);
 if po1 <> nil then begin
  result:= po1^.filetimestamp;
 end
 else begin
  getidentname(id,lstr1);
  fna1:= getsourceunitfile(lstr1);
  if fna1 = '' then begin
   fna1:= getrtunitfile(lstr1);
  end;
  if fna1 = '' then begin
   result:= emptydatetime;
  end
  else begin
   result:= getfilemodtime(fna1);
  end;
 end;
end;
{
procedure setunitsubname(aindex: int32); //sets namebuffer
var
 po1,pe: pchar;
begin
 with info.s.unitinfo^ do begin
  po1:= @namebufferdata[namebufferstart];
  pe:= po1 + 8;
  while po1 < pe do begin
   po1^:= charhexlower[aindex and $F];
   aindex:= card32(aindex) shr 4;
   inc(po1);
  end;
 end;
end;
}
function parseusesunit(const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
{$ifdef mse_debugparser}
  writeln();
  writeln('***************************************** uses');
  writeln(filepath);
{$endif}
//todo: use mmap(), problem: no terminating 0.
  result:= parseunit(readfiledatastring(filepath),aunit,true);
 end;
end;

function initunitfileinfo(const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
  filetimestamp:= getfilemodtime(filepath);
  result:= filetimestamp <> emptydatetime;
 end;
end;

function getunitfile(const aunit: punitinfoty; const aname: lstringty): boolean;
begin
 with aunit^ do begin
  namestring:= lstringtostring(aname);
  name:= stringtolstring(namestring);
  filepath:= filehandler.getsourceunitfile(aname);
  result:= filepath <> '';
  if result then begin
   initunitfileinfo(aunit);
  end;
 end;
end;

function getunitfile(const aunit: punitinfoty; 
                                    const aname: filenamety): boolean;
begin
 result:= getunitfile(aunit,stringtolstring(string(aname)));
end;
         
function parsecompilerunit(const aname: filenamety): boolean;
var
 unit1: punitinfoty;
 str1: string;
begin
 result:= false;
 str1:= stringtoutf8(aname);
 unit1:= newunit(str1);
 with unit1^ do begin
//  name:= str1;
  prev:= info.s.unitinfo;
  if not getunitfile(unit1,aname) then begin
   errormessage(err_compilerunitnotfound,[aname]);
   exit;
  end;
  inc(info.unitlevel);
  result:= parseusesunit(unit1);
  if result then begin
   initcompilersubs(unit1);
  end;
  dec(info.unitlevel);
 end;
end;

function loadunitbyid(const aid: identty;
                      const astackoffset: int32 = minint): punitinfoty;
var
 lstr1: lstringty;
begin
 //todo: load unitfile without source
 
 result:= unitlist.findunit(aid);
 if result = nil then begin
  result:= unitlist.newunit(aid);
  with result^ do begin
   prev:= info.s.unitinfo;
   getidentname(aid,lstr1);
   if not getunitfile(result,lstr1) then begin
    identerror(astackoffset,err_cantfindunit);
   end
   else begin
    if not parseusesunit(result) then begin
     result:= nil;
    end
   end;
  end;
 end
 else begin
  if not (us_interfaceparsed in result^.state) then begin
   circularerror(astackoffset,result);
   result:= nil;
  end;
 end;
end;

function loadunit(const aindex: integer): punitinfoty;
begin
 result:= loadunitbyid(info.contextstack[aindex].d.ident.ident,
                                                aindex-info.s.stackindex);
end;

{
function nextunitimplementation: punitinfoty;
begin
 result:= implementationpending.next;
end;
}


constructor tunitlist.create;
begin
 inherited create(sizeof(punitinfoty));
 fstate:= fstate + [hls_needsfinalize];
end;

function tunitlist.hashkey(const akey): hashvaluety;
begin
 result:= unitinfoty(akey).key;
end;

function tunitlist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= identty(akey) = punitinfoty(aitemdata)^.key;
end;

function tunitlist.findunit(const aname: identty): punitinfoty;
var
 po1: punithashdataty;
begin
 result:= nil;
 po1:= punithashdataty(internalfind(aname,aname));
 if po1 <> nil then begin
  result:= po1^.data;
 end;
end;

procedure tunitlist.finalizeitem(var aitemdata);
begin
{
 with punitinfoty(aitemdata)^ do begin
  clearlist(externallinklist,sizeof(externallinkinfoty),0);
 end;
}
 system.finalize(punitinfoty(aitemdata)^);
 with punitinfoty(aitemdata)^ do begin
//  metadatalist.free();
  freeparsercontext(implstart);
 end;
 freemem(punitinfoty(aitemdata));
end;

function tunitlist.newunit(const aname: identty): punitinfoty;
var
 po1: punithashdataty;
begin
 po1:= punithashdataty(internaladdhash(aname));
 getmem(result,sizeof(unitinfoty));
 fillchar(result^,sizeof(result^),0);
// clearlist(result^.externallinklist,sizeof(externallinkinfoty),256);
 result^.key:= aname;
 po1^.data:= result;
// if 
 result^.llvmlists:= globllvmlists;
// result^.metadatalist:= tmetadatalist.create();
 with punitlinkinfoty(addlistitem(unitlinklist,unitchain))^ do begin
  ref:= result;
 end;
end;
(*
{ timplementationpendinglist }

constructor timplementationpendinglist.create;
begin
 inherited create(sizeof(implpenddataty));
end;

procedure timplementationpendinglist.add(const aunit: punitinfoty);
var
 ofs1: ptruint;
begin
 with pimplpendinfoty(inherited add(ofs1))^ do begin
  header.prev:= 0;
  header.lh.next:= froot;
  pimplpendinfoty(fdata+froot)^.header.prev:= ofs1;
  froot:= ofs1;
  data.unitname:= aunit^.key;
 end;
end;

function timplementationpendinglist.next: punitinfoty;
var
 ofs1: ptruint;
begin
 result:= nil;
 ofs1:= froot;
 if ofs1 <> 0 then begin
  with pimplpendinfoty(fdata+ofs1)^ do begin
   result:= unitlist.findunit(data.unitname);
   froot:= header.lh.next;
  end;
  delete(ofs1);
 end;  
end;
*)

procedure regclass(const aclass: elementoffsetty);
begin
 with info.s.unitinfo^ do begin
 {$ifdef mse_checkinternalerror}                             
  if us_end in state then begin
   internalerror(ie_unit,'201400402B');
  end;
 {$endif}
  if pendingcount >= pendingcapacity then begin
   pendingcapacity:= pendingcapacity*2+256;
   reallocuninitedarray(pendingcapacity,sizeof(pendings[0]),pendings);   
  end;
  with pendings[pendingcount] do begin
   ref:= aclass;
//   ancestor:= aancestor;
  end;
  inc(pendingcount);
 end;
end;

type
 classdescendinfoty = record  //used for copying ancestor virtual method table
  header: linkheaderty;
  itemcount: integer;
  source: segaddressty;
  dest: segaddressty;
 end;
 pclassdescendinfoty = ^classdescendinfoty;

var
 classdescendlist: linklistty;
 forwardtypes: linklistty;
 
procedure regclassdescendent(const aclass: elementoffsetty;
                                const aancestor: elementoffsetty);
var
 po1: pclassdescendinfoty;
begin
 with ptypedataty(ele.eledataabs(aancestor))^ do begin
  po1:= addlistitem(classdescendlist,infoclass.pendingdescends);
  po1^.source:= infoclass.defs;
  po1^.itemcount:= infoclass.virtualcount;
 end;
 with ptypedataty(ele.eledataabs(aclass))^ do begin
  po1^.dest:= infoclass.defs;
 end;
end;

type
 linkinfoty = record
  next: linkindexty;
  dest: segaddressty;
 end;
 plinkinfoty = ^linkinfoty;
 linkarty = array of linkinfoty;
 
var
 links: linkarty; //[0] -> dummy entry
 linkindex: linkindexty;
 deletedlinks: linkindexty;
 
procedure linkmark(var alinks: linkindexty; const aaddress: segaddressty;
                                                    const offset: integer = 0);
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
 inc(po1^.dest.address,offset); 
 alinks:= li1;
end;

procedure linkresolveopad(const alinks: linkindexty; const aaddress: opaddressty);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    popaddressty(getsegmentpo(dest))^:= aaddress-1;
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

procedure linkresolveint(const alinks: linkindexty; const avalue: int32);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    pint32(getsegmentpo(dest))^:= avalue;
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

{
function addtypedef(const aname: identty; const avislevel: visikindsty;
                                        out aelementdata: pointer): boolean;
begin
 result:= ele.addelementdata(aname,ek_type,avislevel,aelementdata);
 if result then begin
  resolveforwardtype(aelementdata);
 end;
end;
}
type
 forwardtypeitemty = record
  header: linkheaderty;
  ref: elementoffsetty;
  name: identty;
 end;
 pforwardtypeitemty = ^forwardtypeitemty;
   
procedure markforwardtype(const atype: ptypedataty;
                                           const aforwardname: identty);
begin
 with pforwardtypeitemty(addlistitem(
                         forwardtypes,info.s.unitinfo^.forwardtypes))^ do begin
  ref:= ele.eledatarel(atype);
  name:= aforwardname;
 end;
end; 

type
 typeresolveinfoty = record
  base: pointer;
  resolver: pelementinfoty;
 end;

procedure doresolveforwardtype(var item; var data; var resolved: boolean);
var
 ps,pd: ptypedataty;
 i1: int32;
begin
 with typeresolveinfoty(data) do begin
  with forwardtypeitemty(item) do begin
   pd:= base+ref;
   if (name = resolver^.header.name) and 
            (pelementinfoty(pointer(pd))^.header.parent = 
                                 resolver^.header.parent) then begin
    ps:= @resolver^.data;
    pd:= pointer(pd)+eledatashift;
    i1:= pd^.h.indirectlevel;
    pd^:= ps^;
    pd^.h.indirectlevel:= i1;
    if pd^.h.base = 0 then begin
     pd^.h.base:= ele.eledatarel(ps);
    end;
    resolved:= true;
   end;
  end;
 end;
end;

procedure resolveforwardtype(const atype: ptypedataty);
var
 data: typeresolveinfoty;
begin
 if info.s.unitinfo^.forwardtypes <> 0 then begin
  data.base:= ele.elebase();
  data.resolver:= pointer(atype)-eledatashift;
  checkresolve(forwardtypes,@doresolveforwardtype,
                                     info.s.unitinfo^.forwardtypes,@data);
 end;
end;

procedure forwardtypeerror(var item);
begin
 with forwardtypeitemty(item) do begin //todo: source location
  identerror(0,name,err_forwardtypenotfound);
 end;
end;

procedure checkforwardtypeerrors();
begin
 if info.s.unitinfo^.forwardtypes <> 0 then begin
  foralllistitems(forwardtypes,@forwardtypeerror,info.s.unitinfo^.forwardtypes);
  deletelistchain(forwardtypes,info.s.unitinfo^.forwardtypes);
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

procedure forwardmark(out aforward: forwardindexty; 
                                              const asource: sourceinfoty);
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
  deletedforwards:= po1^.next;
 end;
 with info.s.unitinfo^ do begin
  po1^.prev:= 0;
  po1^.next:= forwardlist;
  po1^.source:= asource;
  forwards[forwardlist].prev:= fo1;
  forwardlist:= fo1;
 end;
 aforward:= fo1;
end;

procedure forwardresolve(const aforward: forwardindexty);
begin
 if aforward <> 0 then begin
  with forwards[aforward] do begin
   if info.s.unitinfo^.forwardlist = aforward then begin
    info.s.unitinfo^.forwardlist:= next;
   end;
   forwards[next].prev:= prev;
   forwards[prev].next:= next;
   next:= deletedforwards;
  end;
  deletedforwards:= aforward;
 end;
end;

procedure checkforwarderrors(const aforward: forwardindexty);
var
 fo1: forwardindexty;
begin
 fo1:= aforward;
 while fo1 <> 0 do begin
  with forwards[fo1] do begin
   errormessage(source,err_forwardnotsolved,['']);
                      //todo show header
   fo1:= next;
  end;
 end;
end;

procedure resolveclassdescend(var itemdata);
begin
 with classdescendinfoty(itemdata) do begin
  copyvirtualtable(source,dest,itemcount);
 end;
end;

procedure handleunitend();
var
 int1: integer;
 ad1: listadty;
begin
 with info,s.unitinfo^ do begin
  codestop:= opcount;
  checkforwarderrors(forwardlist);
  for int1:= 0 to pendingcount-1 do begin
   with ptypedataty(ele.eledataabs(pendings[int1].ref))^ do begin
    include(infoclass.flags,icf_virtualtablevalid);
    resolvelist(classdescendlist,@resolveclassdescend,
                                              infoclass.pendingdescends);
   end;
  end;
  pendings:= nil;
  include(state,us_end);
 end;
end;

procedure handleinitializationstart();
var
 ad1: opaddressty;
begin
{$ifdef mse_debugparser}
 outhandle('INITIALIZATIONSTART');
{$endif}
 checkforwardtypeerrors();
 getinternalsub(isub_ini,ad1);
 writemanagedvarop(mo_ini,info.s.unitinfo^.varchain,true,0);
{
 with info,unitinfo^ do begin
  initializationstart:= opcount;
 end;
}
end;

procedure handleinitialization();
begin
{$ifdef mse_debugparser}
 outhandle('INITIALIZATION');
{$endif}
 endsimplesub();
{
 with info,unitinfo^ do begin
   initializationstop:= opcount;
  if opcount <> initializationstart then begin
   with additem(oc_goto)^ do begin
//    setop(op,oc_goto);
//    op:= @gotoop; //address set in handleinifini
   end;
  end;
 end;
}
end;

procedure handlefinalizationstart();
var
 ad1: opaddressty;
begin
{$ifdef mse_debugparser}
 outhandle('FINALIZATIONSTART');
{$endif}
 checkforwardtypeerrors();
 getinternalsub(isub_fini,ad1);
{
 with info,unitinfo^ do begin
  finalizationstart:= opcount;
 end;
}
end;

procedure handlefinalization();
begin
{$ifdef mse_debugparser}
 outhandle('FINALIZATION');
{$endif}
 writemanagedvarop(mo_fini,info.s.unitinfo^.varchain,true,0);
 endsimplesub();
{
 with info,unitinfo^ do begin
  if opcount <> finalizationstart then begin
   finalizationstop:= opcount;
   with additem(oc_goto)^ do begin
//    setop(op,oc_goto); //address set in handleinifini
   end;
  end;
 end;
}
end;
(*
procedure handleinifini();
var
 start1: opaddressty;
 unit1: punitinfoty;
 ad1: listadty;
 opad1: opaddressty;
 po1: popinfoty;
begin
 with info,unitlinklist do begin
  unit1:= nil; //compiler warning

  start1:= 0;
  ad1:= unitchain;
  po1:= getoppo(0);
  while ad1 <> 0 do begin         //insert ini calls
   with punitlinkinfoty(list+ad1)^ do begin
    with ref^ do begin
     if inistart <> 0 then begin
      if start1 = 0 then begin
       start1:= inistart;
      end
      else begin
       if unit1^.initializationstop <> 0 then begin
        po1[unit1^.initializationstop].par.opaddress:= inistart-1; //goto
       end
       else begin
        po1[unit1^.inistop].par.opaddress:= inistart-1;          //goto
       end;
      end;
      unit1:= ref;
     end;
     if initializationstop <> 0 then begin
      if start1 = 0 then begin
       start1:= initializationstart;
      end
      else begin
       if inistop <> 0 then begin
        po1[inistop].par.opaddress:= initializationstart-1;      //goto
       end
       else begin
        opad1:= unit1^.inistop;
        if opad1 = 0 then begin
         opad1:= unit1^.finalizationstop;
        end; 
        po1[opad1].par.opaddress:= initializationstart-1;        //goto
       end;
      end;
      unit1:= ref;
     end;
     ad1:= header.next;
    end;
   end;
  end;
  if start1 <> 0 then begin
   opad1:= unit1^.initializationstop;
   if opad1 = 0 then begin
    opad1:= unit1^.inistop;
   end;
   po1[opad1].par.opaddress:= po1[startupoffset].par.opaddress; //goto
   include(po1[po1[startupoffset].par.opaddress].op.flags,opf_label);
   po1[startupoffset].par.opaddress:= start1-1; //inject ini code
   include(po1[start1].op.flags,opf_label);
  end;

  invertlist(unitlinklist,unitchain);
  start1:= 0;
  ad1:= unitchain;
  while ad1 <> 0 do begin //append fini calls
   with punitlinkinfoty(list+ad1)^ do begin
    with ref^ do begin
     if finalizationstop <> 0 then begin
      if start1 = 0 then begin
       start1:= finalizationstart;
      end
      else begin
       if unit1^.finalizationstop <> 0 then begin
        po1[unit1^.finalizationstop].par.opaddress:= finalizationstart-1; 
                                                                   //goto
       end
       else begin
        po1[unit1^.finistop].par.opaddress:= finalizationstart-1;  //goto
       end;
      end;
      unit1:= ref;
     end;
     if finistart <> 0 then begin
      if start1 = 0 then begin
       start1:= finistart;
      end
      else begin
       if finalizationstop <> 0 then begin
        po1[finalizationstop].par.opaddress:= finistart-1;        //goto
       end
       else begin
        if unit1^.finalizationstop <> 0 then begin
         po1[unit1^.finalizationstop].par.opaddress:= finistart-1; 
                                                                 //goto
        end
        else begin
         po1[unit1^.finistop].par.opaddress:= finistart-1;       //goto
        end;
       end;
      end;
      unit1:= ref;
     end;
     ad1:= header.next;
    end;
   end;
  end;
  if start1 <> 0 then begin
   with po1[unitinfo^.codestop] do begin
    op.op:= oc_goto;
//    setop(op,oc_goto);
    par.opaddress:= start1-1;
    include(po1[start1].op.flags,opf_label);
   end;
   opad1:= unit1^.finistop;
   if opad1 = 0 then begin
    opad1:= unit1^.finalizationstop;
   end;
   po1[opad1].op.op:= oc_progend;         //stop
  end;

 end;
end;
*)

procedure beginunit(const aunit: punitinfoty);
begin
end;

function endunit(const aunit: punitinfoty): boolean;
begin
 with additem(oc_endunit)^ do begin
 end;
 result:= true;
 if co_writertunits in info.compileoptions then begin
  result:= writeunitfile(aunit);
 end;
end;

procedure finalizeunit(const aunit: punitinfoty);
begin
 with aunit^ do begin
  if llvmlists <> globllvmlists then begin
   freeandnil(llvmlists);
  end;
 end;
end;

procedure clear;
begin
 clearlist(classdescendlist,sizeof(classdescendinfoty),256);
 clearlist(unitlinklist,sizeof(unitlinkinfoty),256);
 clearlist(intfparsedlinklist,sizeof(unitlinkinfoty),256);
 clearlist(forwardtypes,sizeof(forwardtypeitemty),256);
 clearlist(trystacklist,sizeof(trystackitemty),256);
 unitchain:= 0;
 intfparsedchain:= 0;
  
 links:= nil;
 linkindex:= 0;
 deletedlinks:= 0;
 
 forwards:= nil;
 forwardindex:= 0;
 deletedforwards:= 0;
end;

procedure init;
begin
 clear;
 unitlist:= tunitlist.create;
end;

procedure deinit(const freeunitlist: boolean);
begin
 clear;
 if freeunitlist then begin
  unitlist.free;
 end;
end;

end.
