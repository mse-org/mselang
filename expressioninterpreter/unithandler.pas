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
unit unithandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,mseparserglob,mseelements;

function newunit(const aname: string): punitinfoty; 
function loadunitinterface(const info: pparseinfoty;
                                         const aindex: integer): boolean;
                    //true if ok

procedure setunitname(const info: pparseinfoty); //unitname on top of stack
procedure implementationstart(const info: pparseinfoty);

procedure init;
procedure deinit;

implementation
uses
 msehash,filehandler,errorhandler,parser,msefileutils,msestream,grammar;
 
type
 unithashdataty = record
  header: hashheaderty;
  data: unitinfoty;
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

type
 unitdataty = record
 end;
 punitdataty = ^unitdataty;
 
 implementationdataty = record
 end;
 pimplementationdataty = ^implementationdataty;
 
procedure setunitname(const info: pparseinfoty); //unitname on top of stack
var
 id1: identty;
 po1: punitdataty;
begin
{$ifdef mse_debugparser}
 outhandle(info,'SETUNITNAME');
{$endif}
 with info^ do begin
  id1:= contextstack[stacktop].d.ident.ident;
  if unitinfo^.key <> id1 then begin
   identerror(info,1,err_illegalunitname);
  end
  else begin
   if not elements.pushelement(id1,ek_unit,
                                 elesize+sizeof(unitdataty),po1) then begin
    internalerror(info,'U131018A');
   end;
  end;
  stacktop:= stackindex;
 end;
end;

procedure implementationstart(const info: pparseinfoty);
var
 po1: punitdataty;
begin
 with info^ do begin
  if us_interface in unitinfo^.state then begin
   stopparser:= true; //stop parsing;
  end
  else begin
   if not elements.pushelement(ord(kw_implementation),ek_implementation,
                        elesize+sizeof(implementationdataty),po1) then begin
    
   end;
  end;
 end;
{$ifdef mse_debugparser}
 outhandle(info,'IMPLEMENTATIONSTART');
{$endif}
end;

function parseinterface(const aunit: punitinfoty): boolean;
var
 ar1: opinfoarty;
 stream1: ttextstream;
begin
 with aunit^ do begin
  writeln('***************************************** interface');
  writeln(filepath);
  try
   stream1:= ttextstream.create;
   result:= parse(readfiledatastring(filepath),stream1,aunit,ar1);
   include(state,us_interfaceparsed);
  finally
   stream1.free;
  end;
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
 end;
end;
 
function loadunitinterface(const info: pparseinfoty;
                                         const aindex: integer): boolean;
                    //true if ok
var
 po1: punitinfoty;
 lstr1: lstringty;
begin
 result:= true; 
 with info^.contextstack[aindex] do begin
  po1:= unitlist.findunit(d.ident.ident);
  if po1 = nil then begin
   result:= false;
   po1:= unitlist.newunit(d.ident.ident);
   with po1^ do begin
    lstr1.po:= start.po;
    lstr1.len:= d.ident.len;
    filepath:= filehandler.getunitfile(lstr1);
    if filepath = '' then begin
     identerror(info,aindex-info^.stackindex,err_cantfindunit);
    end
    else begin
     state:= [us_interface];
     result:= parseinterface(po1);
    end;
   end;
  end;
 end;
end;

procedure init;
begin
 unitlist:= tunitlist.create;
end;

procedure deinit;
begin
 unitlist.free;
end;

{ tunitlist }

constructor tunitlist.create;
begin
 inherited create(sizeof(unitinfoty));
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

function tunitlist.hashkey(const akey): hashvaluety;
begin
 with unitinfoty(akey) do begin
  result:= scramble1(key);
 end;
end;

function tunitlist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= identty(akey) = unitinfoty(aitemdata).key;
end;

function tunitlist.findunit(const aname: identty): punitinfoty;
begin
 result:= punitinfoty(internalfind(aname));
end;

procedure tunitlist.finalizeitem(var aitemdata);
begin
 finalize(unitinfoty(aitemdata));
end;

function tunitlist.newunit(const aname: identty): punitinfoty;
var
 po1: punithashdataty;
begin
 po1:= punithashdataty(internaladd(aname));
 po1^.data.key:= aname;
 result:= @po1^.data;
end;

end.
