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
 msetypes,msestrings,parserglob;
 
//todo: use search tree and cache

const
 compunitextension = 'mcu';
 rtunitextension = 'mru';
 bcunitextension = 'bc';
 objunitextension = 'o';
 mlaextension = 'mla';
 pasextension = 'pas';

function getsourceunitfile(const aname: filenamety): filenamety;
function getsourceunitfile(const aunitname: lstringty): filenamety;
function getincludefile(const aname: lstringty): filenamety;

function getrtunitfile(const aunit: punitinfoty): filenamety;
function getrtunitfile(const aunitname: lstringty): filenamety;
function getrtunitfilename(const aname: filenamety): filenamety;
function getbcunitfilename(const aname: filenamety): filenamety;
function getbcunitfile(const aunit: punitinfoty): filenamety;
function getobjunitfilename(const aname: filenamety): filenamety;
function getobjunitfile(const aunit: punitinfoty): filenamety;

//function getsysfile(const aname: filenamety): filenamety;

implementation
uses
 msefileutils;

procedure findunitfile(var aname: filenamety);
var
 mstr1: msestring;
begin
 if not findfile(aname) and //current dir
            not findfile(aname,info.o.unitdirs,aname) then begin
  aname:= '';
 end
 else begin
  aname:= filepath(aname);
 end;
end;

procedure getsourcefile(var aname: filenamety);
begin
 findunitfile(aname);
{
 if findfile(aname) then begin
  aname:= filepath(aname);
 end
 else begin
  aname:= getsysfile(aname);
 end;
}
end;

procedure getrtfile(var aname: filenamety); 
begin
 findunitfile(aname);
{
 if findfile(aname) then begin
  aname:= filepath(aname);
 end
 else begin
  aname:= getsysfile(aname);
 end;
}
end;

function getsourceunitfile(const aname: filenamety): filenamety;
begin
 result:= aname+'.'+mlaextension;
 getsourcefile(result);
end;

function getsourceunitfile(const aunitname: lstringty): filenamety;
begin
 result:= utf8tostring(aunitname)+'.'+mlaextension;
 getsourcefile(result);
 if result = '' then begin
  result:= utf8tostring(aunitname)+'.'+pasextension;
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

function getbcunitfilename(const aname: filenamety): filenamety;
begin
 result:= replacefileext(aname,bcunitextension);
end;

function getobjunitfilename(const aname: filenamety): filenamety;
begin
 result:= replacefileext(aname,objunitextension);
end;

function getbcunitfile(const aunit: punitinfoty): filenamety;
begin
 result:= '';
 if aunit^.rtfilepath <> '' then begin
  result:= getbcunitfilename(aunit^.rtfilepath);
  if not findfile(result) then begin
   result:= '';
  end;
 end;
end;

function getobjunitfile(const aunit: punitinfoty): filenamety;
begin
 result:= '';
 if aunit^.rtfilepath <> '' then begin
  result:= getobjunitfilename(aunit^.rtfilepath);
  if not findfile(result) then begin
   result:= '';
  end;
 end;
end;

function getrtunitfile(const aunit: punitinfoty): filenamety;
begin
 result:= replacefileext(aunit^.filepath,rtunitextension);
 if not findfile(result) then begin
  result:= utf8tostring(aunit^.name)+'.'+rtunitextension;
  getrtfile(result);
 end;
end;

function getrtunitfile(const aunitname: lstringty): filenamety;
begin
 result:= utf8tostring(aunitname)+'.'+rtunitextension;
 getrtfile(result);
end;

//todo: make it portable
{
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
}
end.
