{ MSEide Copyright (c) 2013 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets,
 msegrids,msedispwidgets,mserichstring,msepostscriptprinter,mseprinter,sysutils,
 mclasses,mseelements,msegraphedits,msesplitter,msewidgetgrid,mseeditglob,
 msesyntaxedit,msetextedit,msepipestream;

type
 tmainfo = class(tmainform)
   statf: tstatfile;
   tbutton1: tbutton;
   grid: tstringgrid;
   di: trealdisp;
   getidented: tstringedit;
   intdi: tintegerdisp;
   pushed: tstringedit;
   added: tstringedit;
   addi: tbooleandisp;
   tbutton2: tbutton;
   tbutton3: tbutton;
   finded: tstringedit;
   finddi: tstringdisp;
   tbutton4: tbutton;
   tbooleanedit1: tbooleanedit;
   tfacelist1: tfacelist;
   tpostscriptprinter1: tpostscriptprinter;
   tsplitter1: tsplitter;
   edgrid: twidgetgrid;
   ed: tsyntaxedit;
   coldi: tintegerdisp;
   tbutton5: tbutton;
   procedure parseexe(const sender: TObject);
   procedure findsetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure pushelementexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure addelementexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure clearexe(const sender: TObject);
   procedure popexe(const sender: TObject);
   procedure findelementexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure setpaexe(const sender: TObject);
   procedure editnotiexe(const sender: TObject;
                   var info: editnotificationinfoty);
   procedure saveex(const sender: TObject);
  protected
   felement: elementoffsetty;
   procedure dump;
 end;
var
 mainfo: tmainfo;
  
implementation
uses
 main_mfm,mseexpint,msestream,msestackops,mseparserglob;
 
procedure tmainfo.parseexe(const sender: TObject);
var
 ar1: opinfoarty;
 stream1: ttextstream;
begin
 writeln('*****************************************');
 stream1:= ttextstream.create;
 ar1:= parse(ed.gettext,stream1);
 stream1.position:= 0;
 grid[0].datalist.loadfromstream(stream1);
 stream1.free;
 if ar1 <> nil then begin
  di.value:= run(ar1,1024);
 end;
end;

procedure tmainfo.findsetexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 lstr1: lstringty;
 str1: string;
begin
 str1:= avalue;
 lstr1:= stringtolstring(str1);
 intdi.value:= getident(lstr1);
end;

procedure tmainfo.pushelementexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 lstr1: lstringty;
 str1: string;
begin
 str1:= avalue;
 lstr1:= stringtolstring(str1);
 intdi.value:= getident(lstr1);
 addi.value:= pushelement(intdi.value,ek_none,0) <> nil;
 dump;
end;

procedure tmainfo.addelementexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 lstr1: lstringty;
 str1: string;
 po1: pelementinfoty;
begin
 str1:= avalue;
 lstr1:= stringtolstring(str1);
 intdi.value:= getident(lstr1);
 po1:= addelement(intdi.value,ek_none,0); 
 addi.value:= po1 <> nil;
 dump;
end;

procedure tmainfo.dump;
begin
 grid[0].datalist.asarray:= dumpelements;
 grid.row:= bigint;
end;

procedure tmainfo.clearexe(const sender: TObject);
begin
 clear;
 dump;
end;

procedure tmainfo.popexe(const sender: TObject);
begin
 addi.value:= popelement <> nil;
 dump;
end;

procedure tmainfo.findelementexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 po1: pelementinfoty;
 ar1: stringarty;
 ar2: integerarty;
 mstr1: msestring;
 int1: integer;
begin
 ar1:= splitstring(string(avalue),'.');
 if high(ar1) > 0 then begin
  setlength(ar2,length(ar1));
  for int1:= 0 to high(ar1) do begin
   mstr1:= ar1[int1];
   findsetexe(sender,mstr1,accept);
   ar2[int1]:= intdi.value;
  end;
  po1:= findelementsupward(ar2,felement);
 end
 else begin
  findsetexe(sender,avalue,accept);
  po1:= findelementupward(intdi.value,felement);
 end;
 if po1 = nil then begin
  finddi.value:= '';
 end
 else begin
  finddi.value:= dumppath(po1); 
 end;
end;

procedure tmainfo.setpaexe(const sender: TObject);
begin
 if grid.row > 0 then begin
  setelementparent((grid.row-1)*sizeof(elementinfoty));
  dump;
 end;
end;

procedure tmainfo.editnotiexe(const sender: TObject;
               var info: editnotificationinfoty);
begin
 coldi.value:= ed.col+1;
end;

procedure tmainfo.saveex(const sender: TObject);
begin
 statf.writestat;
end;

end.