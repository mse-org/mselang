unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets;

type
 tmainfo = class(tmainform)
   tmemoedit1: tmemoedit;
   tstatfile1: tstatfile;
   tbutton1: tbutton;
 end;
var
 mainfo: tmainfo;
 
implementation
uses
 main_mfm,mseexpint;
end.
