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
 main_mfm,msesys,parser,msestream,parserglob,elements,llvmbitcodes;
 
procedure tmainfo.exe(const sender: TObject);
var
 stream: tllvmbcwriter;
 foutputstream,ferrorstream: ttextstream;
 typelist: ttypehashdatalist;
 constlist: tconsthashdatalist;
 typ1: typeallocinfoty;
 i1,i2: int32;
 str1,str2: string;

begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 typelist:= ttypehashdatalist.create();
 constlist:= tconsthashdatalist.create(typelist);
 try

  typ1.kind:= das_32;
  typ1.size:= 32;
  typelist.addvalue(typ1);

  typ1.kind:= das_none;
  typ1.size:= 6;
  typelist.addvalue(typ1);
  typelist.addvalue(typ1);

  i1:= constlist.addvalue(1);
  i1:= constlist.addvalue(2);
  i1:= constlist.addvalue(1);
  i1:= constlist.addvalue(2);

  
  str1:= 'abcde';
  str2:= '123567';
  i1:= constlist.addvalue(str1[1],length(str1),typ1.listindex);
  i1:= constlist.addvalue(str2[1],length(str2),typ1.listindex);
  i1:= constlist.addvalue(str1[1],length(str1),typ1.listindex);
  i1:= constlist.addvalue(str2[1],length(str2),typ1.listindex);
  i1:= constlist.addvalue(3);
    
  stream:= tllvmbcwriter.create('test.bc',fm_create);
  stream.start(constlist);
//  stream.beginblock(FUNCTION_BLOCK_ID,3);
//  stream.endblock();
  stream.stop();
  stream.free();
 finally
  foutputstream.destroy();
  ferrorstream.destroy();
  typelist.destroy();
  constlist.destroy();
 end;
end;

end.
