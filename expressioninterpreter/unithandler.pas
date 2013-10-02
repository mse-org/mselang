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
 msestrings,mseparserglob;

function loadunitinterface(const info: pparseinfoty;
                                         const aindex: integer): boolean;
                    //true if ok
procedure init;
procedure deinit;

implementation
uses
 msehash,mseelements,filehandler,errorhandler;
 
type
 unitinfoty = record
  key: identty;
  filepath: filenamety;
 end;
 punitinfoty = ^unitinfoty;
 
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
     result:= true;
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
begin
 result:= punitinfoty(internaladd(aname));
end;

end.
