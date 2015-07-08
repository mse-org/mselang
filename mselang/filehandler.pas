{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
unit filehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,parserglob;
 
//todo: use search tree and cache

const
 rtunitextension = 'mru';
 mlaextension = 'mla';
 pasextension = 'pas';

function getsourceunitfile(const aname: filenamety): filenamety;
function getsourceunitfile(const aname: lstringty): filenamety;
function getincludefile(const aname: lstringty): filenamety;

function getrtunitfile(const aunit: punitinfoty): filenamety;
function getrtunitfilename(const aname: filenamety): filenamety;

function getsysfile(const aname: filenamety): filenamety;

implementation
uses
 msefileutils;

procedure getsourcefile(var aname: filenamety); //todo: use directory options
begin
 if findfile(aname) then begin
  aname:= filepath(aname);
 end
 else begin
  aname:= getsysfile(aname);
 end;
end;

procedure getrtfile(var aname: filenamety); //todo: use directory options
begin
 if findfile(aname) then begin
  aname:= filepath(aname);
 end
 else begin
  aname:= getsysfile(aname);
 end;
end;

function getsourceunitfile(const aname: filenamety): filenamety;
begin
 result:= aname+'.'+mlaextension;
 getsourcefile(result);
end;

function getsourceunitfile(const aname: lstringty): filenamety;
begin
 result:= utf8tostring(aname)+'.'+mlaextension;
 getsourcefile(result);
 if result = '' then begin
  result:= utf8tostring(aname)+'.'+pasextension;
  getsourcefile(result);
 end;
end;

function getincludefile(const aname: lstringty): filenamety;
begin
 result:= utf8tostring(aname);
 getsourcefile(result);
end;

function getrtunitfilename(const aname: filenamety): filenamety;
begin
 result:= replacefileext(aname,rtunitextension);
end;

function getrtunitfile(const aunit: punitinfoty): filenamety;
begin
 result:= replacefileext(aunit^.filepath,rtunitextension);
 if not findfile(result) then begin
  result:= utf8tostring(aunit^.name)+'.'+rtunitextension;
  getrtfile(result);
 end;
end;

//todo: make it portable

function getsysfile(const aname: filenamety): filenamety;
begin
 result:= 'compiler/'+aname;
 if not findfile(result) then begin
  result:= '/home/mse/packs/standard/git/mselang/mselang/compiler/'+aname;
  if not findfile(result) then begin
   result:= '';
  end;
 end
 else begin
  result:= filepath(result);
 end;
end;

end.
