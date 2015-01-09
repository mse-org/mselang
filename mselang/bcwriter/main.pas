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
 main_mfm,msesys,parser,msestream,parserglob,elements,llvmbitcodes,msestrings,
 llvmlists;
 
procedure tmainfo.exe(const sender: TObject);
var
 stream: tllvmbcwriter;
 foutputstream,ferrorstream: ttextstream;
 typelist: ttypehashdatalist;
 constlist: tconsthashdatalist;
 globlist: tgloballocdatalist;
 typ1,typ2: typeallocinfoty;
 b1,b2,i1,i2,i3: int32;
 str1,str2: string;

begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 typelist:= ttypehashdatalist.create();
 constlist:= tconsthashdatalist.create(typelist);
 globlist:= tgloballocdatalist.create(typelist,constlist);

 try
  typelist.addbitvalue(das_32);

  str1:= 'abcde';
  b1:= typelist.addbytevalue(length(str1));
  str2:= '123567';
  b2:= typelist.addbytevalue(length(str2));

  i1:= typelist.addsubvalue(nil);
  i1:= typelist.addsubvalue(nil);

  i1:= constlist.addi8(1);
  i1:= constlist.addi8(2);
  i1:= constlist.addi8(1);
  i1:= constlist.addi8(2);
 
  
  i1:= constlist.addvalue(str1[1],length(str1));
  i1:= constlist.addvalue(str2[1],length(str2));

  i1:= constlist.addvalue(str1[1],length(str1));
  i1:= constlist.addvalue(str2[1],length(str2));

  i1:= constlist.addi32(3);

  i1:= typelist.addsubvalue(nil);
  i2:= constlist.addi32(124);
    
  i3:= globlist.addsubvalue(nil,stringtolstring('main'));
  globlist.addbytevalue(4);
  i3:= globlist.addinitvalue(i2);

  stream:= tllvmbcwriter.create('test.bc',fm_create);
  stream.start(constlist,globlist);

//  i3:= stream.emitsub(i1,cv_ccc,li_code,0);

  stream.beginsub();
//  stream.emitretop(stream.constop(i2));
  stream.emitloadop(stream.globop(i3));
  stream.emitretop(stream.ssaindex-1);
  stream.endsub();

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
