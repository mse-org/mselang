unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv;

type
 tmainmo = class(tmsedatamodule)
   sysenv: tsysenvmanager;
   procedure initsysenvexe(sender: tsysenvmanager);
 end;
var
 mainmo: tmainmo;
implementation
uses
 mainmodule_mfm;
type
 paramty = (pa_grammarfile,pa_pasfile,pa_incfile);
const
 params: array[paramty] of argumentdefty = (
  (kind: ak_pararg; name: 'g';  anames: nil;  flags: [];
           initvalue: '';),
  (kind: ak_pararg; name: 'p';  anames: nil;  flags: [];
           initvalue: '';),
  (kind: ak_pararg; name: 'i';  anames: nil;  flags: [];
           initvalue: '';)
 );
 
procedure tmainmo.initsysenvexe(sender: tsysenvmanager);
begin
 sender.init(params);
end;

end.
