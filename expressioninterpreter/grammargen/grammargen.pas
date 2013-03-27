program grammargen;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef mswindows}{$apptype console}{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cthreads,cwstring,{$endif}{$endif}
 sysutils,mainmodule,msenogui;
begin
 application.createdatamodule(tmainmo,mainmo);
 application.run;
end.
