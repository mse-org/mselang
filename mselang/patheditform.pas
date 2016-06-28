unit patheditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msedataedits,
 mseedit,msegrids,mseificomp,mseificompglob,mseifiglob,msestatfile,msestream,
 msestrings,msewidgetgrid,sysutils,msesimplewidgets;
type
 tpatheditfo = class(tmseform)
   twidgetgrid1: twidgetgrid;
   tbutton1: tbutton;
   tbutton2: tbutton;
   fuvalues: tstringedit;
   procedure loadedev(const sender: TObject);
   procedure closequerydef(const sender: tcustommseform;
                   var amodalresult: modalresultty);
 end;
var
 patheditfo: tpatheditfo;
implementation
uses
 patheditform_mfm,parserglob;
 
procedure tpatheditfo.loadedev(const sender: TObject);
begin
 fuvalues.gridvalues:= info.o.unitdirs;
end;

procedure tpatheditfo.closequerydef(const sender: tcustommseform;
               var amodalresult: modalresultty);
begin
 if amodalresult = mr_ok then begin
  info.o.unitdirs:= fuvalues.gridvalues;
 end;
end;

end.
