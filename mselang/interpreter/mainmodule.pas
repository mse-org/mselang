unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv,
 parserglob,msestream;
{$goto on}

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
 mainmodule_mfm,parser,msesysutils,errorhandler,msesys,msesystypes,
 msefileutils,segmentutils,sysutils,stackops,globtypes;
 
const
 startupmessage =
'MSElang Runtime version 0.0'+lineend+
'Copyright (c) 2013-2014 by Martin Schreiber';

procedure tmainmo.createexe(const sender: TObject);
begin
// sysenv.printmessage(startupmessage);
end;

procedure tmainmo.eventloopexe(const sender: TObject);
var
 inputstream: tmsefilestream;
 filename1: filenamety;
 str1: string;
 mstr1: msestring;
 err: syserrorty;
label
 endlab;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 filename1:= sysenv.value[ord(pa_source)];
 if filename1 = '' then begin
  errormessage1(err_noinputfile,[],erl_none);
 end
 else begin
  if checksysok(tmsefilestream.trycreate(inputstream,filename1,fm_read),
                                        err_fileread,[filename1]) then begin
   try
    if readsegmentdata(inputstream,storedsegments) then begin
     freeandnil(inputstream);
     exitcode:= run(1024);
    end;
   except
    on e: exception do begin
     errormessage1(e.message,[]);
     exitcode:= 1;
    end;
   end;
   inputstream.free();
  end;
 end;
endlab:
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
