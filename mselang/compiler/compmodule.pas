unit compmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv,
 parserglob,msestream,parser;

const
 mliextension = 'mli';
 llvmbcextension = 'bc'; 
type
 paramty = (pa_source,                  //0
            pa_llvm,                    //1
            pa_nocompilerunit,          //2
            pa_nortlunits,              //3
            pa_debug,                   //4
            pa_debugline,               //5
            pa_unitdirs,                //6
            pa_define,                  //7
            pa_undefine,                //8
            pa_build,                   //9
            pa_makeobject,              //10
            pa_makebc,                  //11 produce no exe
            pa_showcompilefile);        //12
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
   procedure initparams(var parserparams: parserparamsty);
   procedure initparams(const aparams: msestringarty;
                                     var parserparams: parserparamsty);
 end;

var
 compmo: tcompmo;

implementation

uses
 globtypes,compmodule_mfm,msesysutils,errorhandler,msesys,msesystypes,
 msefileutils,segmentutils,llvmops,sysutils,llvmbcwriter,unithandler,
 msearrayutils,identutils,opglob;
 
const
 startupmessage =
'MSElang Compiler version 0.0'+lineend+
'Copyright (c) 2013-2018 by Martin Schreiber';

 llvmbindir = 
 '/home/mse/packs/standard/git/llvm/build_debug/Debug+Asserts/bin/';

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
 parserparams: parserparamsty;
 seg1: subsegmentty;
begin
 initparams(parserparams);
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
   initparams(parserparams);
   
(*
   parserparams.buildoptions.llvmlinkcommand:= 
                                      tosysfilepath(llvmbindir+'llvm-link');
   parserparams.buildoptions.llccommand:= tosysfilepath(llvmbindir+'llc');
//   parserparams.buildoptions.llvmoptcommand:= llvmbindir+'opt '+opted.value;
   parserparams.buildoptions.gcccommand:= tosysfilepath('gcc');
   parserparams.buildoptions.ascommand:= tosysfilepath('as');
   parserparams.buildoptions.exefile:= tosysfilepath(
                                          replacefileext(filename1,'bin'));

   parserparams.compileoptions:= mlaruntimecompileoptions;
   if sysenv.defined[ord(pa_llvm)] then begin
    parserparams.compileoptions:= llvmcompileoptions+[co_modular,co_buildexe];
    if sysenv.defined[ord(pa_debug)] then begin
     parserparams.compileoptions:= 
                       parserparams.compileoptions + [co_lineinfo,co_proginfo];
    end;
    if sysenv.defined[ord(pa_debugline)] then begin
     parserparams.compileoptions:= parserparams.compileoptions + [co_lineinfo];
    end;
   end;
   if sysenv.defined[ord(pa_build)] then begin
    include(parserparams.compileoptions,co_build);
   end;
   if sysenv.defined[ord(pa_makeobject)] then begin
    parserparams.compileoptions:= parserparams.compileoptions +
                                        [co_buildexe,co_modular,co_objmodules];
   end;
   if sysenv.defined[ord(pa_makebc)] then begin
    parserparams.compileoptions:= parserparams.compileoptions - 
                                              [co_buildexe,co_modular];
   end;
   if sysenv.defined[ord(pa_showcompilefile)] then begin
    parserparams.compileoptions:= parserparams.compileoptions +
                                                          [co_compilefileinfo];
   end;
   if sysenv.defined[ord(pa_nocompilerunit)] then begin
    include(parserparams.compileoptions,co_nocompilerunit);
   end;
   if sysenv.defined[ord(pa_nortlunits)] then begin
    include(parserparams.compileoptions,co_nortlunits);
   end;
   info.o.unitdirs:= reversearray(sysenv.values[ord(pa_unitdirs)]);
*)
   if parse(str1,filename1,parserparams) then begin
    if parserparams.compileoptions * [co_llvm,co_modular] = [co_llvm] then begin
     filename1:= replacefileext(filename1,llvmbcextension);
     if checksysok(tllvmbcwriter.trycreate(tmsefilestream(llvmstream),
                          filename1,fm_create),
                             err_cannotcreatetargetfile,[filename1]) then begin
      seg1:= getfullsegment(seg_op,startupoffset);
      try
       llvmops.run(llvmstream,true,info.s.unitinfo^.mainfini,seg1);
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
   end
   else begin
    exitcode:= 1;
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

procedure tcompmo.initparams(var parserparams: parserparamsty);
var
 ar1: msestringarty;
 i1: int32;
begin

 parserparams.buildoptions.llvmlinkcommand:= 
                                    tosysfilepath(llvmbindir+'llvm-link');
 parserparams.buildoptions.llccommand:= tosysfilepath(llvmbindir+'llc');
//   parserparams.buildoptions.llvmoptcommand:= llvmbindir+'opt '+opted.value;
 parserparams.buildoptions.gcccommand:= tosysfilepath('gcc');
 parserparams.buildoptions.ascommand:= tosysfilepath('as');
 parserparams.buildoptions.exefile:= tosysfilepath(
                       replacefileext(sysenv.value[ord(pa_source)],'bin'));

 parserparams.compileoptions:= mlaruntimecompileoptions;
 if sysenv.defined[ord(pa_llvm)] then begin
  parserparams.compileoptions:= llvmcompileoptions+[co_modular,co_buildexe];
  if sysenv.defined[ord(pa_debug)] then begin
   parserparams.compileoptions:= 
                     parserparams.compileoptions + [co_lineinfo,co_proginfo];
  end;
  if sysenv.defined[ord(pa_debugline)] then begin
   parserparams.compileoptions:= parserparams.compileoptions + [co_lineinfo];
  end;
 end;
 if sysenv.defined[ord(pa_build)] then begin
  include(parserparams.compileoptions,co_build);
 end;
 if sysenv.defined[ord(pa_makeobject)] then begin
  parserparams.compileoptions:= parserparams.compileoptions +
                                      [co_buildexe,co_modular,co_objmodules];
 end;
 if sysenv.defined[ord(pa_makebc)] then begin
  parserparams.compileoptions:= parserparams.compileoptions - 
                                            [co_buildexe,co_modular];
 end;
 if sysenv.defined[ord(pa_showcompilefile)] then begin
  parserparams.compileoptions:= parserparams.compileoptions +
                                                        [co_compilefileinfo];
 end;
 if sysenv.defined[ord(pa_nocompilerunit)] then begin
  include(parserparams.compileoptions,co_nocompilerunit);
 end;
 if sysenv.defined[ord(pa_nortlunits)] then begin
  include(parserparams.compileoptions,co_nortlunits);
 end;
 parserparams.unitdirs:= reversearray(sysenv.values[ord(pa_unitdirs)]);
end;

procedure tcompmo.initparams(const aparams: msestringarty;
                                         var parserparams: parserparamsty);
begin
 info.o.defines:= nil;
 sysenv.init(aparams);
 initparams(parserparams);
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
