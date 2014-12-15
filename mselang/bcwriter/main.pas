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
 main_mfm,msesys,parser,msestream;
 
procedure tmainfo.exe(const sender: TObject);
var
 stream: tllvmbcwriter;
 foutputstream,ferrorstream: ttextstream;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 try
  stream:= tllvmbcwriter.create('test.bc',fm_create);
  stream.free();
 finally
  foutputstream.destroy();
  ferrorstream.destroy();
 end;
end;

end.
