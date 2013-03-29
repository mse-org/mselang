unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv;

type
 tmainmo = class(tmsedatamodule)
   sysenv: tsysenvmanager;
   procedure eventloopexe(const sender: TObject);
   procedure afterinitexe(sender: tsysenvmanager);
 end;
var
 mainmo: tmainmo;
implementation
uses
 mainmodule_mfm,msefileutils,msestream,msesys;
type
 paramty = (pa_grammarfile,pa_pasfile,pa_incfile);

procedure creategrammar(const grammar,pas,inc: filenamety);
var
 grammarstream: ttextstream = nil;
 passtream: ttextstream = nil;
 incstream: ttextstream = nil;
begin
 try
  grammarstream:= ttextstream.create(grammar,fm_read);
  passtream:= ttextstream.create(pas,fm_create);
  incstream:= ttextstream.create(pas,fm_create);
 finally
  grammarstream.free;
  passtream.free;
  incstream.free;
 end;
end;

procedure tmainmo.eventloopexe(const sender: TObject);
begin
 with sysenv do begin
  creategrammar(value[ord(pa_grammarfile)],value[ord(pa_pasfile)],
                                                 value[ord(pa_incfile)]);
 end;
end;

procedure tmainmo.afterinitexe(sender: tsysenvmanager);
begin
 with sender do begin
  if not defined[ord(pa_pasfile)] then begin
   value[ord(pa_pasfile)]:= replacefileext(value[ord(pa_grammarfile)],'pas');
  end;
  if not defined[ord(pa_incfile)] then begin
   value[ord(pa_incfile)]:= replacefileext(value[ord(pa_grammarfile)],'inc');
  end;
 end;
end;

end.
