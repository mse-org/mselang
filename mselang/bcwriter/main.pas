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
 main_mfm,msesys,parser,msestream,parserglob,elements;
 
procedure tmainfo.exe(const sender: TObject);
var
 stream: tllvmbcwriter;
 foutputstream,ferrorstream: ttextstream;
 typelist: ttypehashdatalist;
 typ1: typeallocinfoty;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 typelist:= ttypehashdatalist.create();
 try
  typ1.kind:= das_32;
  typ1.size:= 32;
  typelist.addunique(typ1);
  typelist.addunique(typ1);
  typ1.kind:= das_8;
  typ1.size:= 8;
  typelist.addunique(typ1);
  typelist.addunique(typ1);
  
  stream:= tllvmbcwriter.create('test.bc',fm_create);
  stream.start(typelist);
  stream.stop();
  stream.free();
 finally
  foutputstream.destroy();
  ferrorstream.destroy();
  typelist.destroy();
 end;
end;

end.
