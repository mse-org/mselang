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
 llvmlists,opglob;
 
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
// t0: int32;
 v1: int32;
 c1,c2: int32;
 segad1: memopty;
 
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
  c2:= constlist.addi32(124);
    
  i3:= globlist.addsubvalue(nil,stringtolstring('main'));
  v1:= globlist.addbytevalue(4);
  i3:= globlist.addinitvalue(c2);

  i1:= constlist.addi32(3);
  c1:= constlist.addi32(1);

  stream:= tllvmbcwriter.create('test.bc',fm_create);
  stream.start(constlist,globlist);

//  i3:= stream.emitsub(i1,cv_ccc,li_code,0);

  stream.beginsub();
//  stream.emitretop(stream.constop(i2));
//  stream.emitloadop(stream.globval(i3));
  with segad1 do begin
   t.listindex:= ord(das_32);
   segdataaddress.a.address:= v1;
   segdataaddress.offset:= c1;
  end;
  stream.emitsegdataaddresspo(segad1);
  stream.emitstoreop(stream.constval(c2),stream.relval(0));
  

//  stream.emitbinop(BINOP_ADD,stream.constval(i1),stream.ssaindex-1);
//  stream.emitstoreop(stream.ssaindex-1,stream.globval(i3));
//  stream.emitloadop(stream.globval(i3));
//  stream.emitloadop(stream.globop(i3));
//  stream.emitretop(stream.ssaindex-1);
  stream.emitsegdataaddresspo(segad1);
  stream.emitloadop(stream.relval(0));
  stream.emitretop(stream.relval(0));
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
