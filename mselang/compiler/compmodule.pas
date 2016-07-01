unit compmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv,
 parserglob,msestream;

const
 mliextension = 'mli';
 llvmbcextension = 'bc'; 
type
 paramty = (pa_source,pa_llvm,pa_nocompilerunit,
            pa_debug,pa_debugline,pa_unitdirs,pa_define,pa_undefine); 
            //item number in sysenv
 
 tcompmo = class(tmsedatamodule)
   sysenv: tsysenvmanager;
   procedure eventloopexe(const sender: TObject);
   procedure terminatedexe(const sender: TObject);
   procedure createexe(const sender: TObject);
//   procedure sysenvexe(sender: tsysenvmanager);
   procedure valuereadev(sender: tsysenvmanager; const index: Integer;
                   var defined: Boolean; var argument: msestringarty;
                   var error: sysenverrornrty);
  private
   foutputstream: ttextstream;
   ferrorstream: ttextstream;
  public
   procedure initparams();
   procedure initparams(const aparams: msestringarty);
 end;

var
 compmo: tcompmo;

implementation

uses
 globtypes,compmodule_mfm,parser,msesysutils,errorhandler,msesys,msesystypes,
 msefileutils,segmentutils,llvmops,sysutils,llvmbcwriter,unithandler,
 msearrayutils,identutils;
 
const
 startupmessage =
'MSElang Compiler version 0.0'+lineend+
'Copyright (c) 2013-2016 by Martin Schreiber';

procedure tcompmo.createexe(const sender: TObject);
begin
 sysenv.printmessage(startupmessage);
end;

procedure tcompmo.eventloopexe(const sender: TObject);
var
// inputstream: ttextstream;
 filename1: filenamety;
 str1: string;
 mstr1: msestring;
 err: syserrorty;
 targetstream: tmsefilestream;
 llvmstream: tllvmbcwriter;
 compoptions: compileoptionsty;
begin
 initparams();
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
   compoptions:= mlaruntimecompileoptions;
   if sysenv.defined[ord(pa_llvm)] then begin
    compoptions:= llvmcompileoptions;
    if sysenv.defined[ord(pa_debug)] then begin
     compoptions:= compoptions + [co_lineinfo,co_proginfo];
    end;
    if sysenv.defined[ord(pa_debugline)] then begin
     compoptions:= compoptions + [co_lineinfo];
    end;
   end;
   if sysenv.defined[ord(pa_nocompilerunit)] then begin
    include(compoptions,co_nocompilerunit);
   end;
   if parse(str1,filename1,compoptions) then begin
    if co_llvm in compoptions then begin
     filename1:= replacefileext(filename1,llvmbcextension);
     if checksysok(tllvmbcwriter.trycreate(tmsefilestream(llvmstream),
                          filename1,fm_create),
                             err_cannotcreatetargetfile,[filename1]) then begin
      try
       llvmops.run(llvmstream,true);
      except
       on e: exception do begin
        errormessage1(e.message,[]);
        exitcode:= 1;
       end;
      end;
      unithandler.deinit(true); //destroy unitlist
      llvmstream.destroy();
     end;
    end
    else begin
     filename1:= replacefileext(filename1,mliextension);
     if checksysok(tmsefilestream.trycreate(targetstream,filename1,fm_create),
                             err_cannotcreatetargetfile,[filename1]) then begin
      try
       writesegmentdata(targetstream,getfilekind(mlafk_rtprogram),
                                                           storedsegments,now);
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

procedure tcompmo.terminatedexe(const sender: TObject);
begin
 foutputstream.free();
 ferrorstream.free();
end;

procedure tcompmo.initparams();
var
 ar1: msestringarty;
 i1: int32;
begin
 if sysenv.defined[ord(pa_debug)] then begin
  info.o.debugoptions:= info.o.debugoptions + 
                 [do_lineinfo,do_proginfo];
 end;
 if sysenv.defined[ord(pa_debugline)] then begin
  info.o.debugoptions:= info.o.debugoptions + 
                 [do_lineinfo];
 end;
 info.o.unitdirs:= reversearray(sysenv.values[ord(pa_unitdirs)]);
{
 ar1:= sysenv.values[ord(pa_define)];
 setlength(info.o.defines,length(ar1));
 for i1:= 0 to high(ar1) do begin
  info.o.defines[i1].name:= ansistring(ar1[i1]);
 end;
}
end;

procedure tcompmo.initparams(const aparams: msestringarty);
begin
 info.o.defines:= nil;
 sysenv.init(aparams);
 initparams();
end;
{
procedure tcompmo.sysenvexe(sender: tsysenvmanager);
begin
 initparams();
end;
}
procedure tcompmo.valuereadev(sender: tsysenvmanager; const index: Integer;
               var defined: Boolean; var argument: msestringarty;
               var error: sysenverrornrty);
var
 i1: int32;
begin
 if error = ern_io then begin
  case paramty(index) of
   pa_define,pa_undefine: begin
    i1:= high(info.o.defines)+1;
    setlength(info.o.defines,i1+1);
    with info.o.defines[i1] do begin
     if argument <> nil then begin
      name:= stringtoutf8ansi(argument[0]);
      deleted:= paramty(index) = pa_undefine;
     end;
    end;
   end;
  end;
 end;
end;

end.
