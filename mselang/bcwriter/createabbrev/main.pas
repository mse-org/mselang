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
 main_mfm,llvmbcwriter,mseformatstr,parser,msearrayutils;

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
 i1,i2,i3,i4: int32;
 str1: string;
 mstr1,nam1,comment: msestring;
 foutputstream,ferrorstream: ttextstream;
 id: integer;
 names: msestringarty;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 try
  initio(foutputstream,ferrorstream);
  i4:= 0;
  mstr1:= '';
  id:= abbrevidstart.value;
  repeat
   nam1:= nameed[i4];
   additem(names,'@mab'+nam1);
   comment:= '';
   writer1:= tllvmbcwriter1(tllvmbcwriter.create());
   i1:= writer1.bitpos;
   writer1.emit(idsize.value,define_abbrev);
   for i3:= i4+1 to grid.rowcount do begin
    if (i3 = grid.rowcount) or (nameed[i3] <> '') then begin
     writer1.emitvbr5(i3-i4);
    end;
   end;
   i3:= i4;
   repeat
    case encodingty(encoding[i3]) of
     en_literal: begin
      writer1.emit(1,1);
      writer1.emitvbr8(valueed[i3]);
      comment:= comment+'literal '+inttostr(valueed[i3])+',';
     end;
     en_fixed: begin
      writer1.emit(1,0);
      writer1.emit(3,1);
      writer1.emitvbr5(valueed[i3]);
      comment:= comment+'fixed '+inttostr(valueed[i3])+',';
     end;
     en_vbr: begin
      writer1.emit(1,0);
      writer1.emit(3,2);
      writer1.emitvbr5(valueed[i3]);
      comment:= comment+'vbr '+inttostr(valueed[i3])+',';
     end;
     en_array: begin
      writer1.emit(1,0);
      writer1.emit(3,3);
      comment:= comment+'array,';
        //next operand is type
     end;
     en_char6: begin
      writer1.emit(1,0);
      writer1.emit(3,4);
      comment:= comment+'char6,';
     end;
     en_blob: begin
      writer1.emit(1,0);
      writer1.emit(3,4);
      comment:= comment+'blob,';
     end;
    end;
    inc(i3);
   until (nameed[i3] <> '') or (i3 >= grid.rowcount);
   i2:= writer1.bitpos;
   writer1.pad32;
   writer1.flush();
   writer1.position:= 0;
   str1:= copy(writer1.readdatastring(),i1 div 8 + 1,(i2-i1+7) div 8);
   writer1.free;
   setlength(comment,length(comment)-1);
   mstr1:= mstr1 + 'mab_'+nam1+' = '+inttostr(id)+'; //'+comment+lineend+
           'mab'+nam1+'dat : array[0..'+
           inttostr(length(str1)-1)+'] of card8 = ('+lineend+
           bytestrtostr(str1,nb_dec,',')+');'+lineend+
     'mab'+nam1+': bcdataty = (bitsize: '+inttostr(i2-i1)+'; data: @'+
     'mab'+nam1+'dat);'+lineend;
   inc(id);
   i4:= i3;
  until i4 >= grid.rowcount;
  mstr1:= mstr1+'mabs: array[0..'+inttostr(high(names))+'] of pbcdataty = ('+
  concatstrings(names,',')+');'+lineend;
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
