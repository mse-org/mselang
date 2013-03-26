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
 main_mfm,mseexpint,msestream,msestackops;
 
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
