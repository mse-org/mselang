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
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets,
 msegrids,msedispwidgets,mserichstring,msepostscriptprinter,mseprinter,sysutils,
 mclasses,elements,msegraphedits,msesplitter,msewidgetgrid,mseeditglob,
 msesyntaxedit,msetextedit,msepipestream,mseprocess,parserglob;

type
 tmainfo = class(tmainform)
   statf: tstatfile;
   tbutton1: tbutton;
   grid: tstringgrid;
   di: trealdisp;
   getidented: tstringedit;
   intdi: tintegerdisp;
   pushed: tstringedit;
   added: tstringedit;
   addi: tbooleandisp;
   tbutton2: tbutton;
   tbutton3: tbutton;
   finded: tstringedit;
   finddi: tstringdisp;
   tbutton4: tbutton;
   tbooleanedit1: tbooleanedit;
   tfacelist1: tfacelist;
   tpostscriptprinter1: tpostscriptprinter;
   tsplitter1: tsplitter;
   edgrid: twidgetgrid;
   ed: tsyntaxedit;
   coldi: tintegerdisp;
   tbutton5: tbutton;
   tbutton6: tbutton;
   tbutton7: tbutton;
   markdi: tintegerdisp;
   countdi: tintegerdisp;
   markddi: tintegerdisp;
   procedure parseexe(const sender: TObject);
   procedure findsetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure clearexe(const sender: TObject);
   procedure popexe(const sender: TObject);
   procedure setpaexe(const sender: TObject);
   procedure editnotiexe(const sender: TObject;
                   var info: editnotificationinfoty);
   procedure saveex(const sender: TObject);
   procedure markexe(const sender: TObject);
   procedure releaseexe(const sender: TObject);
  protected
   felement: elementoffsetty;
   procedure dump;
 end;
var
 mainfo: tmainfo;
  
implementation
uses
 main_mfm,msestream,stackops,parser;

procedure tmainfo.parseexe(const sender: TObject);
var
 ar1: opinfoarty;
 stream1: ttextstream;
begin
 writeln('*****************************************');
 stream1:= ttextstream.create;
 parser.init;
 parser.parse(ed.gettext,stream1,nil,ar1);
 parser.deinit;

 stream1.position:= 0;
 grid[0].datalist.loadfromstream(stream1);
 stream1.free;
 if ar1 <> nil then begin
  di.value:= run(ar1,1024);
 end;
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

procedure tmainfo.dump;
begin
 grid[0].datalist.asarray:= ele.dumpelements;
 grid.row:= bigint;
 countdi.value:= ele.count;
end;

procedure tmainfo.clearexe(const sender: TObject);
begin
 clear;
 dump;
end;

procedure tmainfo.popexe(const sender: TObject);
begin
 addi.value:= ele.popelement <> nil;
 dump;
end;

procedure tmainfo.setpaexe(const sender: TObject);
begin
 if grid.row > 0 then begin
  ele.elementparent:= (grid.row-1)*sizeof(elementinfoty);
  dump;
 end;
end;

procedure tmainfo.editnotiexe(const sender: TObject;
               var info: editnotificationinfoty);
begin
 coldi.value:= ed.col+1;
end;

procedure tmainfo.saveex(const sender: TObject);
begin
 statf.writestat;
end;

var
 ref: markinfoty;
 
procedure tmainfo.markexe(const sender: TObject);
var
 puint1: ptruint;
begin
 ele.markelement(ref);
 markdi.value:= ref.hashref;
 markddi.value:= ref.dataref;
 countdi.value:= ele.count;
end;

procedure tmainfo.releaseexe(const sender: TObject);
begin
 ele.releaseelement(ref);
 dump;
end;

end.