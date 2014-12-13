unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,llvmbcwriter,
 msesimplewidgets;

type
 tmainfo = class(tmainform)
   tbutton1: tbutton;
   procedure exe(const sender: TObject);
 end;
var
 mainfo: tmainfo;
 
implementation
uses
 main_mfm,msesys;
 
procedure tmainfo.exe(const sender: TObject);
var
 stream: tllvmbcwriter;
begin
 stream:= tllvmbcwriter.create('test.bc',fm_create);
 stream.free();
end;

end.
