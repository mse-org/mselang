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
 msegrids,msedispwidgets,mserichstring;

type
 tmainfo = class(tmainform)
   ed: tmemoedit;
   tstatfile1: tstatfile;
   tbutton1: tbutton;
   grid: tstringgrid;
   di: trealdisp;
   procedure parseexe(const sender: TObject);
 end;
var
 mainfo: tmainfo;
  
implementation
uses
 main_mfm,mseexpint,msestream,msestackops,mseparserglob;
 
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

end.
