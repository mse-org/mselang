unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msestatfile,
 msedataedits,mseedit,mseificomp,mseificompglob,mseifiglob,msestream,msestrings,
 sysutils,msegrids,msewidgetgrid,msegraphedits,msescrollbar,msesplitter,
 msebitmap,msedatanodes,msefiledialog,mselistbrowser,msesys,msesimplewidgets;

type
 tmainfo = class(tmainform)
   projectstat: tstatfile;
   idsize: tintegeredit;
   grid: twidgetgrid;
   encoding: tenumtypeedit;
   valueed: tintegeredit;
   code: tmemoedit;
   nameed: tstringedit;
   tsplitter1: tsplitter;
   tfilenameedit1: tfilenameedit;
   mainstat: tstatfile;
   tbutton1: tbutton;
   abbrevidstart: tintegeredit;
   procedure initencoding(const sender: tenumtypeedit);
   procedure datentexe(const sender: TObject);
   procedure rowcontchaexe(const sender: tcustomgrid);
   procedure filenamesetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure saveexe(const sender: TObject);
   procedure closeexe(const sender: TObject);
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm,llvmbcwriter,mseformatstr,parser;

type
 encodingty = (en_literal,en_fixed,en_vbr,en_array,en_char6,en_blob);
 tllvmbcwriter1 = class(tllvmbcwriter);
   
procedure tmainfo.initencoding(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(encodingty);
end;

procedure tmainfo.datentexe(const sender: TObject);
var
 writer1: tllvmbcwriter1;
 int1,int2,int3,int4: int32;
 str1: string;
 mstr1,nam1: msestring;
 foutputstream,ferrorstream: ttextstream;
 id: integer;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 try
  initio(foutputstream,ferrorstream);
  int4:= 0;
  mstr1:= '';
  id:= abbrevidstart.value;
  repeat
   nam1:= nameed[int4];
   writer1:= tllvmbcwriter1(tllvmbcwriter.create());
   int1:= writer1.bitpos;
   writer1.emit(idsize.value,define_abbrev);
   writer1.emitvbr5(grid.rowcount);
   int3:= int4;
   repeat
    case encodingty(encoding[int3]) of
     en_literal: begin
      writer1.emit(1,1);
      writer1.emitvbr8(valueed[int3]);
     end;
     en_fixed: begin
      writer1.emit(1,0);
      writer1.emit(3,1);
      writer1.emitvbr5(valueed[int3]);
     end;
     en_vbr: begin
      writer1.emit(1,0);
      writer1.emit(3,2);
      writer1.emitvbr5(valueed[int3]);
     end;
     en_array: begin
      writer1.emit(1,0);
      writer1.emit(3,3);
        //next operand is type
     end;
     en_char6: begin
      writer1.emit(1,0);
      writer1.emit(3,4);
     end;
     en_blob: begin
      writer1.emit(1,0);
      writer1.emit(3,4);
     end;
    end;
    inc(int3);
   until (nameed[int3] <> '') or (int3 >= grid.rowcount);
   int2:= writer1.bitpos;
   writer1.pad32;
   writer1.flush();
   writer1.position:= 0;
   str1:= copy(writer1.readdatastring(),int1 div 8 + 1,(int2-int1+7) div 8);
   writer1.free;
   mstr1:= mstr1 + 'abbr_'+nam1+' = '+inttostr(id)+';'+lineend+
           nam1+'dat : array[0..'+
           inttostr(length(str1)-1)+'] of card8 = ('+lineend+
           bytestrtostr(str1,nb_dec,',')+');'+lineend+
     nam1+': bcdataty = (bitsize: '+inttostr(int2-int1)+'; data: @'+
     nam1+'dat);'+lineend;
   inc(id);
   int4:= int3;
  until int4 >= grid.rowcount;
  code.value:= mstr1
 except
  application.handleexception();
 end;
 foutputstream.destroy();
 ferrorstream.destroy();
end;

procedure tmainfo.rowcontchaexe(const sender: tcustomgrid);
begin
 datentexe(nil);
end;

procedure tmainfo.filenamesetexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
begin
 projectstat.filename:= avalue;
 projectstat.readstat();
 datentexe(nil);
end;

procedure tmainfo.saveexe(const sender: TObject);
begin
 projectstat.writestat();
end;

procedure tmainfo.closeexe(const sender: TObject);
begin
 saveexe(nil);
end;

end.
