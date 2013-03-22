unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets;

type
 tmainfo = class(tmainform)
   ed: tmemoedit;
   tstatfile1: tstatfile;
   tbutton1: tbutton;
   procedure parseexe(const sender: TObject);
 end;
var
 mainfo: tmainfo;
  
implementation
uses
 main_mfm,mseexpint;
 
procedure tmainfo.parseexe(const sender: TObject);
var
 ar1: stringarty;
begin
 writeln('**********');
 parse(ed.value,ar1);
end;

end.
