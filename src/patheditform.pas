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
   tbutton3: tbutton;
   tbutton4: tbutton;
   procedure loadedev(const sender: TObject);
   procedure closequerydef(const sender: tcustommseform;
                   var amodalresult: modalresultty);
   procedure addrow(const sender: TObject);
   procedure delrow(const sender: TObject);
 end;
var
 patheditfo: tpatheditfo;
implementation
uses
 patheditform_mfm,parserglob,main;
 
procedure tpatheditfo.loadedev(const sender: TObject);
begin
 fuvalues.gridvalues:= mainfo.compparams;
end;

procedure tpatheditfo.closequerydef(const sender: tcustommseform;
               var amodalresult: modalresultty);
var
x : integer;               
begin
 if amodalresult = mr_ok then begin
  mainfo.compparams:= fuvalues.gridvalues;
 //for x:=0 to length(fuvalues.gridvalues) do
   //  mainfo.fuedit.text := mainfo.fuedit.text + ' ' + fuvalues.gridvalues[0];
 end;
end;

procedure tpatheditfo.addrow(const sender: TObject);
begin
twidgetgrid1.rowcount := twidgetgrid1.rowcount + 1;
end;

procedure tpatheditfo.delrow(const sender: TObject);
begin
twidgetgrid1.rowcount := twidgetgrid1.rowcount - 1;
end;

end.
