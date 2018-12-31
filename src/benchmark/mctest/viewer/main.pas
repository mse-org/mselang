unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,mseimage,
 msesimplewidgets,mseact,msebitmap,msedataedits,msedatanodes,mseedit,
 msefiledialog,msegrids,mseificomp,mseificompglob,mseifiglob,mselistbrowser,
 msestatfile,msestream,msestrings,msesys,sysutils;

type
 tmainfo = class(tmainform)
   ima: timage;
   tbutton1: tbutton;
   fname: tfilenameedit;
   tstatfile1: tstatfile;
   procedure loadexe(const sender: TObject);
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
 
procedure tmainfo.loadexe(const sender: TObject);
var
 s1: string;
 si1: sizety;
 ima1: imagety;
begin
 si1:= ms(640,400);
 s1:= readfiledatastring(fname.value);
 if length(s1) = si1.cx*si1.cy*4 then begin
  ima1.kind:= bmk_rgb;
  ima1.bgr:= false;
  ima1.size:= si1;
  ima1.length:= si1.cx*si1.cy;
  ima1.linelength:= si1.cx;
  ima1.linebytes:= ima1.linelength*4;
  ima1.pixels:= pointer(s1);
  ima.bitmap.loadfromimage(ima1);
 end;
end;

end.
