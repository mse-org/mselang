program mli;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef mswindows}{$apptype console}{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cthreads,cwstring,{$endif}{$endif}
 sysutils,msenogui,mainmodule;

begin
 application.createdatamodule(tmainmo,mainmo);
 application.run();
end.
