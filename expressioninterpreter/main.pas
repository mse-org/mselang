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
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets,
 msegrids,msedispwidgets,mserichstring,msepostscriptprinter,mseprinter,sysutils;

type
 tmainfo = class(tmainform)
   ed: tmemoedit;
   tstatfile1: tstatfile;
   tbutton1: tbutton;
   grid: tstringgrid;
   di: trealdisp;
   tpostscriptprinter1: tpostscriptprinter;
   getidented: tstringedit;
   intdi: tintegerdisp;
   pushed: tstringedit;
   added: tstringedit;
   addi: tbooleandisp;
   tbutton2: tbutton;
   tbutton3: tbutton;
   procedure parseexe(const sender: TObject);
   procedure findsetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure pushelementexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure addelementexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure clearexe(const sender: TObject);
   procedure popexe(const sender: TObject);
  protected
   procedure dump;
 end;
var
 mainfo: tmainfo;
  
implementation
uses
 main_mfm,mseexpint,msestream,msestackops,mseparserglob,mseelements;
 
procedure tmainfo.parseexe(const sender: TObject);
var
 ar1: opinfoarty;
 stream1: ttextstream;
begin
 writeln('*****************************************');
 stream1:= ttextstream.create;
 ar1:= parse(ed.value,stream1);
 stream1.position:= 0;
 grid[0].datalist.loadfromstream(stream1);
 stream1.free;
 di.value:= run(ar1,1024);
end;

procedure tmainfo.findsetexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 lstr1: lstringty;
 str1: string;
begin
 str1:= avalue;
 lstr1:= stringtolstring(str1);
 intdi.value:= getident(lstr1);
end;

procedure tmainfo.pushelementexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 lstr1: lstringty;
 str1: string;
begin
 str1:= avalue;
 lstr1:= stringtolstring(str1);
 intdi.value:= getident(lstr1);
 pushelement(intdi.value,sizeof(elementinfoty));
 dump;
end;

procedure tmainfo.addelementexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 lstr1: lstringty;
 str1: string;
 po1: pelementinfoty;
begin
 str1:= avalue;
 lstr1:= stringtolstring(str1);
 intdi.value:= getident(lstr1);
 po1:= addelement(intdi.value,sizeof(elementinfoty)); 
 addi.value:= po1 <> nil;
 dump;
end;

procedure tmainfo.dump;
begin
 grid[0].datalist.asarray:= dumpelements;
end;

procedure tmainfo.clearexe(const sender: TObject);
begin
 clear;
 dump;
end;

procedure tmainfo.popexe(const sender: TObject);
begin
 addi.value:= popelement <> nil;
end;

end.
