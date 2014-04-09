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
 msestrings,parserglob,elements;

function newunit(const aname: string): punitinfoty; 
function loadunit({const info: pparseinfoty;}
                                const aindex: integer): punitinfoty;
//function nextunitimplementation: punitinfoty;
//function parseimplementation(const info: pparseinfoty; 
//                                       const aunit: punitinfoty): boolean;

procedure setunitname(); //unitname on top of stack
procedure interfacestop();
procedure implementationstart();
procedure handleinclude();

procedure init;
procedure deinit;

implementation
uses
 msehash,filehandler,errorhandler,parser,msefileutils,msestream,grammar,
 handlerglob,mselinklist;
 
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
 po2: pelementinfoty;
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
   if not ele.pushelement(id1,vis_max,ek_unit,po1) then begin
    internalerror('U131018A');
   end;
   with unitinfo^ do begin
    interfaceelement:= ele.elementparent;
    po2:= ele.addelement(tks_classes,vis_max,ek_classes);
    classeselement:= ele.eleinforel(po2);
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
 po1: punitdataty;
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
   if not ele.pushelement(ord(tk_implementation),vis_max,
                                    ek_implementation,po1) then begin
    internalerror('U20131130A');
   end;
  end;
 end;
end;

procedure handleinclude();
begin
{$ifdef mse_debugparser}
 outhandle('INCLUDE');
{$endif} 
outinfo('***');
 with info do begin
  dec(stackindex,2);
 end;
end;

function parseusesunit({const info: pparseinfoty;}
                              const aunit: punitinfoty): boolean;
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
 
function loadunit({const info: pparseinfoty;} const aindex: integer): punitinfoty;
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
procedure init;
begin
 unitlist:= tunitlist.create;
// implementationpending:= timplementationpendinglist.create;
end;

procedure deinit;
begin
 unitlist.free;
// implementationpending.free;
end;

{ tunitlist }

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
end.
