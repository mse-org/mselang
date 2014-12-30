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
 typ1,typ2: typeallocinfoty;
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

  str1:= 'abcde';
  typ1.kind:= das_none;
  typ1.size:= length(str1);
  typelist.addvalue(typ1);
  str2:= '123567';
  typ2.kind:= das_none;
  typ2.size:= length(str2);
  typelist.addvalue(typ2);

  i1:= typelist.addsubvalue(nil);
  i1:= typelist.addsubvalue(nil);

  i1:= constlist.addcard8value(1);
  i1:= constlist.addcard8value(2);
  i1:= constlist.addcard8value(1);
  i1:= constlist.addcard8value(2);
 
  
  i1:= constlist.addvalue(str1[1],length(str1),typ1.listindex);
  i1:= constlist.addvalue(str2[1],length(str2),typ2.listindex);

  i1:= constlist.addvalue(str1[1],length(str1),typ1.listindex);
  i1:= constlist.addvalue(str2[1],length(str2),typ2.listindex);

  i1:= constlist.addint32value(3);

  i1:= typelist.addsubvalue(nil);
    
  stream:= tllvmbcwriter.create('test.bc',fm_create);
  stream.start(constlist);
  stream.emitsub(i1,cv_ccc,li_code,0);
  stream.beginblock(FUNCTION_BLOCK_ID,3);
  stream.endblock();
  stream.beginblock(VALUE_SYMTAB_BLOCK_ID,3);
  stream.endblock();
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
