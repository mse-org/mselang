unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv,
 parserglob,msestream;

type
 paramty = (pa_source); //item number in sysenv
 
 tmainmo = class(tmsedatamodule)
   sysenv: tsysenvmanager;
   procedure eventloopexe(const sender: TObject);
   procedure terminatedexe(const sender: TObject);
   procedure createexe(const sender: TObject);
  private
   foutputstream: ttextstream;
   ferrorstream: ttextstream;
 end;

var
 mainmo: tmainmo;

implementation

uses
 mainmodule_mfm,parser,msesysutils,errorhandler,msesys,msesystypes;
 
const
 startupmessage =
'MSElang Compiler version 0.0'+lineend+
'Copyright (c) 2013-2014 by Martin Schreiber';

procedure tmainmo.createexe(const sender: TObject);
begin
 sysenv.printmessage(startupmessage);
end;

procedure tmainmo.eventloopexe(const sender: TObject);
var
 inputstream: ttextstream;
 inpfname: filenamety;
 str1: string;
 mstr1: msestring;
 err: syserrorty;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 inpfname:= sysenv.value[ord(pa_source)];
 if inpfname = '' then begin
  message(err_noinputfile,[]);
 end
 else begin
  err:= tryreadfiledatastring(inpfname,str1);
  if err <> sye_ok then begin
   if err = sye_lasterror then begin
    mstr1:= getlasterrortext();
   end
   else begin
    mstr1:= 'unknown';
   end;
   message(err_fileread,[inpfname,mstr1]);
  end
  else begin
  end;
 end;
 if (errorcount(erl_error) > 0) and (exitcode = 0) then begin
  exitcode:= 1;
 end;
 application.terminated:= true;
end;

procedure tmainmo.terminatedexe(const sender: TObject);
begin
 foutputstream.free();
 ferrorstream.free();
end;

end.
