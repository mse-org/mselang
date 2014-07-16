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
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets,
 msegrids,msedispwidgets,mserichstring,msepostscriptprinter,mseprinter,sysutils,
 mclasses,elements,msegraphedits,msesplitter,msewidgetgrid,mseeditglob,
 msesyntaxedit,msetextedit,msepipestream,mseprocess,parserglob,msebitmap,
 msedatanodes,msefiledialog,mseificomp,mseificompglob,mselistbrowser,msesys,
 msescrollbar;

type
 it = interface(ievent)
 end;

 tmainfo = class(tmainform)
   statf: tstatfile;
   tbutton1: tbutton;
   grid: tstringgrid;
   tpostscriptprinter1: tpostscriptprinter;
   tsplitter1: tsplitter;
   edgrid: twidgetgrid;
   ed: tsyntaxedit;
   coldi: tintegerdisp;
   tbutton5: tbutton;
   tbutton2: tbutton;
   filena: tfilenameedit;
   llvm: tbooleanedit;
   procedure parseexe(const sender: TObject);
   procedure editnotiexe(const sender: TObject;
                   var info: editnotificationinfoty);
   procedure saveexe(const sender: TObject);
   procedure loadexe(const sender: TObject);
   procedure aftreadexe(const sender: TObject);
   procedure befwriteexe(const sender: TObject);
//   procedure tbutton2();
  protected
//   function test: integer; override;
 end;
var
 mainfo: tmainfo;

//procedure test(); virtual;
  
implementation
uses
 main_mfm,msestream,stackops,parser,llvmops,msedatalist;
 
procedure tmainfo.parseexe(const sender: TObject);
var
 stream1: ttextstream;
 bo1: boolean;
 backend: backendty;
 str1: string;
 int1: integer;
begin
 writeln('*****************************************');
 stream1:= ttextstream.create;
 backend:= bke_direct;
 if llvm.value then begin
  backend:= bke_llvm;
 end;
 bo1:= parser.parse(ed.gettext,backend,stream1);

 stream1.position:= 0;
 grid[0].datalist.loadfromstream(stream1);
 stream1.free;
 if bo1 then begin
  if llvm.value then begin
   llvmops.run();
   int1:= getprocessoutput('llvm-as test.ll','',str1);
   if (int1 = 0) and (str1 = '') then begin
    grid.appendrow(['**llvm OK**']);
   end
   else begin
    grid[0].readpipe(str1,[aco_stripescsequence]);
   end;
  end
  else begin
   stackops.run(1024);
  end;
 end;
end;

procedure tmainfo.editnotiexe(const sender: TObject;
               var info: editnotificationinfoty);
begin
 coldi.value:= ed.col+1;
end;

procedure tmainfo.saveexe(const sender: TObject);
begin
 ed.savetofile(filena.value);
end;

procedure tmainfo.loadexe(const sender: TObject);
begin
 ed.loadfromfile(filena.value);
end;

procedure tmainfo.aftreadexe(const sender: TObject);
begin
 loadexe(nil);
end;

procedure tmainfo.befwriteexe(const sender: TObject);
begin
 saveexe(nil);
end;

end.
