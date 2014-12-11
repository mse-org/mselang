unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv,
 parserglob,msestream;

type
 paramty = (pa_source,pa_llvm,pa_debug); //item number in sysenv
 
 tmainmo = class(tmsedatamodule)
   sysenv: tsysenvmanager;
   procedure eventloopexe(const sender: TObject);
   procedure terminatedexe(const sender: TObject);
   procedure createexe(const sender: TObject);
   procedure sysenvexe(sender: tsysenvmanager);
  private
   foutputstream: ttextstream;
   ferrorstream: ttextstream;
 end;

var
 mainmo: tmainmo;

implementation

uses
 mainmodule_mfm,parser,msesysutils,errorhandler,msesys,msesystypes,
 msefileutils,segmentutils,llvmops,sysutils;
 
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
 filename1: filenamety;
 str1: string;
 mstr1: msestring;
 err: syserrorty;
 targetstream: tmsefilestream;
 llvmstream: ttextstream;
 backend: backendty;
begin
 foutputstream:= ttextstream.create(stdoutputhandle);
 ferrorstream:= ttextstream.create(stderrorhandle);
 initio(foutputstream,ferrorstream);
 filename1:= sysenv.value[ord(pa_source)];
 if filename1 = '' then begin
  errormessage1(err_noinputfile,[]);
 end
 else begin
  if checksysok(tryreadfiledatastring(filename1,str1),
                                    err_fileread,[filename1]) then begin
   backend:= bke_direct;
   if sysenv.defined[ord(pa_llvm)] then begin
    backend:= bke_llvm;
   end;
   if parse(str1,backend) then begin
    if backend = bke_llvm then begin
     filename1:= replacefileext(filename1,'ll');
     if checksysok(ttextstream.trycreate(llvmstream,filename1,fm_create),
                             err_cannotcreatetargetfile,[filename1]) then begin
      try
       llvmops.run(llvmstream);
      except
       on e: exception do begin
        errormessage1(msestring(e.message),[]);
        exitcode:= 1;
       end;
      end;
      llvmstream.destroy();
     end;
    end
    else begin
     filename1:= replacefileext(filename1,'mlr');
     if checksysok(tmsefilestream.trycreate(targetstream,filename1,fm_create),
                             err_cannotcreatetargetfile,[filename1]) then begin
      try
       writesegmentdata(targetstream,storedsegments);
      finally
       targetstream.destroy();
      end;      
     end;
    end;
   end;
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

procedure tmainmo.sysenvexe(sender: tsysenvmanager);
begin
 if sender.defined[ord(pa_debug)] then begin
  include(info.debugoptions,deo_lineinfo);
 end;
end;

end.
