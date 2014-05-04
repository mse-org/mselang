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
unit unithandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,parserglob,elements,handlerglob;

function newunit(const aname: string): punitinfoty; 
function loadunit(const aindex: integer): punitinfoty;

procedure setunitname(); //unitname on top of stack
procedure interfacestop();
procedure implementationstart();
procedure handleinclude();

procedure linkmark(var alinks: linkindexty; const aaddress: integer);
procedure linkresolve(const alinks: linkindexty; const aaddress: opaddressty);

procedure forwardmark(out aforward: forwardindexty; const asource: sourceinfoty);
procedure forwardresolve(const aforward: forwardindexty);
procedure checkforwarderrors(const aforward: forwardindexty);

procedure regclass(const aclass: elementoffsetty);
procedure regclassdescendant(const aclass: elementoffsetty;
                                const aancestor: elementoffsetty);
procedure handleunitend();
procedure copyvirtualtable(const source,dest: dataoffsty;
                                                 const itemcount: integer);

procedure init;
procedure deinit;

implementation
uses
 msehash,filehandler,errorhandler,parser,msefileutils,msestream,grammar,
 mselinklist,handlerutils,msearrayutils;
 
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
{
 implpenddataty = record
  unitname: identty;
 end;
 pimplpenddataty = ^implpenddataty;
 implpendinfoty = record
  header: doublelinkheaderty;
  data: implpenddataty;
 end;
 pimplpendinfoty = ^implpendinfoty;
 
 timplementationpendinglist = class(tdoublelinklist)
  protected
   froot: ptruint;
  public
   constructor create;
   procedure add(const aunit: punitinfoty);
   function next: punitinfoty;
 end;
} 
var
 unitlist: tunitlist;
// implementationpending: timplementationpendinglist;
 
procedure setunitname(); //unitname on top of stack
var
 id1: identty;
 po1: punitdataty;
// po2: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('SETUNITNAME');
{$endif}
 with info do begin
  id1:= contextstack[stacktop].d.ident.ident;
  if unitinfo^.key <> id1 then begin
   identerror(1,err_illegalunitname);
  end
  else begin
   if not ele.pushelement(id1,globalvisi,ek_unit,po1) then begin
    internalerror('U131018A');
   end;
   with unitinfo^ do begin
    interfaceelement:= ele.elementparent;
//    po2:= ele.addelement(tks_classes,globalvisi,ek_classes);
//    classeselement:= ele.eleinforel(po2);
   end;
  end;
  stacktop:= stackindex;
 end;
end;

procedure interfacestop();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACESTOP');
{$endif}
 with info do begin
  include(unitinfo^.state,us_interfaceparsed);
{
  if us_interface in unitinfo^.state then begin
   unitinfo^.impl.sourceoffset:= source.po-sourcestart;
   unitinfo^.impl.sourceline:= source.line;
   unitinfo^.impl.context:= @implementationstartco;
   unitinfo^.impl.eleparent:= ele.elementparent;
   stopparser:= true; //stop parsing;
  end
}
 end;
end;

procedure implementationstart();
var
 po1: pimplementationdataty;
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATIONSTART');
{$endif}
 with info do begin
  if us_implementation in unitinfo^.state then begin
   errormessage(err_invalidtoken,['implementation']);
  end
  else begin
   include(unitinfo^.state,us_implementation);
   include(currentstatementflags,stf_implementation);
   if not ele.pushelement(tk_implementation,implementationvisi,
                                    ek_implementation,po1) then begin
    internalerror('U20131130A');
   end;
  end;
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
    errormessage(err_cannotfindinclude,[],stacktop-stackindex);
   end
   else begin
    pushincludefile(filepath);
   end;
  end;
  dec(stackindex,2);
 end;
end;

function parseusesunit(const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
  writeln('***************************************** uses');
  writeln(filepath);
//todo: use mmap(), problem: no terminating 0.
  result:= parseunit(readfiledatastring(filepath),aunit);
  include(state,us_implementationparsed);
 end;
end;

(*
function parseinterface(const info: pparseinfoty; 
                                       const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
  writeln('***************************************** interface');
  writeln(filepath);
  state:= [us_interface];
  result:= parseunit(info,readfiledatastring(filepath),aunit);
  include(state,us_interfaceparsed);
 end;
end;

function parseimplementation(const info: pparseinfoty; 
                                       const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
  writeln('***************************************** implementation');
  writeln(filepath);
  exclude(state,us_interface);
  result:= parseunit(info,readfiledatastring(filepath),aunit);
  include(state,us_implementationparsed);
 end;
end;
*)
function newunit(const aname: string): punitinfoty; 
var
 id: identty;
begin
 id:= getident(aname);
 result:= unitlist.findunit(id);
 if result = nil then begin
  result:= unitlist.newunit(id);
 end;
end;
 
function loadunit(const aindex: integer): punitinfoty;
var
 lstr1: lstringty;
begin
 with info.contextstack[aindex] do begin
  result:= unitlist.findunit(d.ident.ident);
  if result = nil then begin
   result:= unitlist.newunit(d.ident.ident);
   with result^ do begin
    prev:= info.unitinfo;
    lstr1.po:= start.po;
    lstr1.len:= d.ident.len;
    name:= lstringtostring(lstr1);
    filepath:= filehandler.getunitfile(lstr1);
    if filepath = '' then begin
     identerror(aindex-info.stackindex,err_cantfindunit);
    end
    else begin
     if not parseusesunit(result) then begin
      result:= nil;
     end
{    
     if not parseinterface(info,result) then begin
      result:= nil;
     end
     else begin
      implementationpending.add(result);
     end;
}
    end;
   end;
  end
  else begin
   if not (us_interfaceparsed in result^.state) then begin
    circularerror(aindex-info.stackindex,result);
    result:= nil;
   end;
  end;
 end;
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
 finalize(punitinfoty(aitemdata)^);
 freemem(punitinfoty(aitemdata));
end;

function tunitlist.newunit(const aname: identty): punitinfoty;
var
 po1: punithashdataty;
begin
 po1:= punithashdataty(internaladdhash(aname));
 getmem(result,sizeof(unitinfoty));
 fillchar(result^,sizeof(result^),0);
 result^.key:= aname;
 po1^.data:= result;
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
 with info.unitinfo^ do begin
  if us_end in state then begin
   internalerror('U201400402B');
  end;
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
// listadty = longword;

 linkheaderty = record
  next: listadty; //offset from list
 end;
 plinkheaderty = ^linkheaderty;
 linkdataty = record
  header: linkheaderty;
  data: record
  end;
 end;
 plinkdataty = ^linkdataty;

 linklistty = record
  itemsize: integer;
  list: pointer;
  current: listadty;  //offset from list
  capacity: listadty; //offset from list
  deleted: listadty;
 end;

procedure clearlist(var alist: linklistty; const aitemsize: integer);
begin
 with alist do begin
  itemsize:= aitemsize;
  if list <> nil then begin
   freemem(list);
  end;
  list:= nil;
  current:= 0;
  capacity:= 0;
  deleted:= 0;  
 end;
end;

function addlistitem(var alist: linklistty; var aitem: listadty): pointer;
var
 li1: listadty;
begin
 with alist do begin
  li1:= deleted;
  if li1 = 0 then begin
   current:= current + itemsize;
   if current >= capacity then begin
    capacity:= 2*capacity + 256*itemsize;
    reallocmem(list,capacity);
   end;
   li1:= current;
   result:= list+li1;
  end
  else begin
   result:= list+li1;
   deleted:= plinkheaderty(result)^.next;
  end;
  plinkheaderty(result)^.next:= aitem;
  aitem:= li1;  
 end; 
end; 

procedure deletelistchain(var alist: linklistty; const achain: listadty);
begin
 with alist do begin
  plinkheaderty(list+achain)^.next:= deleted;
  deleted:= achain;
 end; 
end;

type
 resolvehandlerty = procedure(const listitem: pointer);

procedure invert(const alist: linklistty; var achain: listadty);
var
 s,s1,d: listadty;
begin
 if achain <> 0 then begin
  d:= 0;
  s:= achain;
  repeat
   with plinkheaderty(alist.list+s)^ do begin
    s1:= next;
    next:= d;
   end;
   d:= s;
   s:= s1;
  until s = 0;
  achain:= d;
 end;
end;
 
procedure resolve(var alist: linklistty; const handler: resolvehandlerty;
                                                         var achain: listadty);
var
 ad1: listadty;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  with alist do begin
   while ad1 <> 0 do begin
    po1:= alist.list+ad1;
    handler(po1);
    ad1:= po1^.next;
   end;
   plinkheaderty(list+achain)^.next:= deleted;
   deleted:= achain;
   achain:= 0;
  end;
 end;
end;

type
 classdescendinfoty = record
  header: linkheaderty;
  itemcount: integer;
  source: dataoffsty;
  dest: dataoffsty;
 end;
 pclassdescendinfoty = ^classdescendinfoty;
 classdescendarty = array of classdescendinfoty;
var
 classdescendindex: linkindexty;
 deletedclassdescends: linkindexty;
 classdescends: classdescendarty;


var
 classdescendlist: linklistty;
 
procedure regclassdescendant(const aclass: elementoffsetty;
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
  dest: opaddressty;
 end;
 plinkinfoty = ^linkinfoty;
 linkarty = array of linkinfoty;
 
var
 links: linkarty; //[0] -> dummy entry
 linkindex: linkindexty;
 deletedlinks: linkindexty;
 
procedure linkmark(var alinks: linkindexty; const aaddress: integer);
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

procedure linkresolve(const alinks: linkindexty; const aaddress: opaddressty);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    info.ops[dest].par.opaddress:= aaddress-1;
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
  deletedlinks:= po1^.next;
 end;
 with info.unitinfo^ do begin
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
   if info.unitinfo^.forwardlist = aforward then begin
    info.unitinfo^.forwardlist:= next;
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

procedure copyvirtualtable(const source,dest: dataoffsty;
                                                 const itemcount: integer);
var
 ps,pd,pe: popaddressty;
begin
 ps:= pointer(info.constseg)+source+sizeof(classdefheaderty);
 pd:= pointer(info.constseg)+dest+sizeof(classdefheaderty);
 pe:= pd+itemcount;
 repeat
  if pd^ = 0 then begin
   pd^:= ps^;
  end;
  inc(ps);
  inc(pd);
 until pd >= pe;
end;

procedure resolveclassdescend(const listitem: pointer);
begin
 with pclassdescendinfoty(listitem)^ do begin
  copyvirtualtable(source,dest,itemcount);
 end;
end;

procedure handleunitend();
var
 int1: integer;
 ad1: listadty;
begin
 with info.unitinfo^ do begin
  checkforwarderrors(forwardlist);
  for int1:= 0 to pendingcount-1 do begin
   with ptypedataty(ele.eledataabs(pendings[int1].ref))^ do begin
    include(infoclass.flags,icf_virtualtablevalid);
//    invert(classdescendlist,infoclass.pendingdescends);
    resolve(classdescendlist,@resolveclassdescend,infoclass.pendingdescends);
   end;
  end;
  pendings:= nil;
  include(state,us_end);
 end;
end;

procedure clear;
begin
 clearlist(classdescendlist,sizeof(classdescendinfoty));
 
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

procedure deinit;
begin
 clear;
 unitlist.free;
end;

end.
