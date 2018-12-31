program mlc;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef mswindows}{$apptype console}{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cthreads,cwstring,{$endif}{$endif}
 sysutils,msenogui,compmodule;

begin
 application.createdatamodule(tcompmo,compmo);
 application.run();
end.
