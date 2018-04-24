{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,
 mseifiglob,msestrings,msetypes,msestatfile,msesimplewidgets,msewidgets,
 msegrids,msedispwidgets,mserichstring,msepostscriptprinter,mseprinter,sysutils,
 mclasses,elements,msegraphedits,msesplitter,msewidgetgrid,mseeditglob,
 msesyntaxedit,msetextedit,msepipestream,mseprocess,parserglob,msebitmap,
 msedatanodes,msefiledialog,mseificomp,mseificompglob,mselistbrowser,msesys,
 msescrollbar,msesyntaxpainter,msesercomm,msestream,msebarcode,mseact,
 msememodialog;

const
 llvmbindir = 
 '/home/mse/packs/standard/git/llvm/build_debug/Debug+Asserts/bin/';
// llvmbindir = 
//      '/home/mse/packs/standard/git/llvm/build_debug_3_7/Debug+Asserts/bin/';
type
 it = interface(ievent)
 end;

 tmainfo = class(tmainform)
   statf: tstatfile;
   tbutton1: tbutton;
   grid: tstringgrid;
   tpostscriptprinter1: tpostscriptprinter;
   tsplitter1: tsplitter;
   edgrid: twidgetgrid;
   ed: tsyntaxedit;
   coldi: tintegerdisp;
   tbutton5: tbutton;
   tbutton2: tbutton;
   filena: tfilenameedit;
   llvm: tbooleanedit;
   tsyntaxpainter1: tsyntaxpainter;
   lineinfoed: tbooleanedit;
   norun: tbooleanedit;
   modulared: tbooleanedit;
   objed: tbooleanedit;
   builded: tbooleanedit;
   proginfoed: tbooleanedit;
   nameed: tbooleanedit;
   nocompilerunited: tbooleanedit;
   tbutton3: tbutton;
   nortlunitsed: tbooleanedit;
   opted: tmemodialoghistoryedit;
   llced: tmemodialoghistoryedit;
   procedure parseev(const sender: TObject);
   procedure editnotiexe(const sender: TObject;
                   var info: editnotificationinfoty);
   procedure saveexe(const sender: TObject);
   procedure loadexe(const sender: TObject);
   procedure aftreadexe(const sender: TObject);
   procedure befwriteexe(const sender: TObject);
//   procedure tbutton2();
   procedure lineinfoset(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure nameset(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure proginfoset(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure statupdateev(const sender: TObject; const filer: tstatfiler);
   procedure patheditev(const sender: TObject);
   procedure createev(const sender: TObject);
  private
   fcompparams: msestringarty;
   procedure setcompparams(const avalue: msestringarty);
  protected
   procedure initparams();
  public
   property compparams: msestringarty read fcompparams write setcompparams;
 end;
var
 mainfo: tmainfo;

//procedure test(); virtual;
  
implementation
uses
 errorhandler,main_mfm,stackops,parser,llvmops,msedatalist,msearrayutils,
 msefileutils,patheditform,compmoduledebug,opglob,
 msesystypes,llvmbcwriter,unithandler,mseformatstr,segmentutils,globtypes;
 
procedure tmainfo.parseev(const sender: TObject);
//const
// llcopt = '-debugger-tune=gdb ';
var
 errstream,outstream: ttextstream;
 mlistream: tmsefilestream;
 targetstream: tllvmbcwriter;
 bo1: boolean;
 parserparams: parserparamsty;
 str1: string;
 int1: integer;
 filename1,filename2,filename3,optname: filenamety;
 dirbefore: msestring;
 ar1: filenamearty;
 i1,i2: int32;
  dt1,dt2: tdatetime;
begin
{$ifdef mse_debugparser}
 writeln('*****************************************');
{$endif}
 errstream:= ttextstream.create;
 outstream:= ttextstream.create;
 resetinfo();
 initio(outstream,errstream);
 initparams();
 parserparams.buildoptions.llccommand:= tosysfilepath(llvmbindir+'llc')+
                                                            ' '+llced.value;
 parserparams.buildoptions.ascommand:= tosysfilepath('as');
 parserparams.compileoptions:= [];
 if llvm.value then begin
	  parserparams.compileoptions:= llvmcompileoptions;
  if lineinfoed.value then begin
   include(parserparams.compileoptions,co_lineinfo);
  end;
  if proginfoed.value then begin
   include(parserparams.compileoptions,co_proginfo);
  end;
  if nameed.value then begin
   include(parserparams.compileoptions,co_names);
  end;
 end
 else begin
  parserparams.compileoptions:= mlaruntimecompileoptions;
 end;
 if modulared.value then begin
  include(parserparams.compileoptions,co_modular);
 end;
 if objed.value then begin
  include(parserparams.compileoptions,co_objmodules);
 end;
 {
 if wrtued.value then begin
  include(compoptions,co_writeunits);
 end;
 }
 if builded.value then begin
  include(parserparams.compileoptions,co_build);
 end;
 {
 if rrtued.value then begin
  include(compoptions,co_readunits);
 end;
 }
 if nocompilerunited.value then begin
  include(parserparams.compileoptions,co_nocompilerunit);
 end;
 if nortlunitsed.value then begin
  include(parserparams.compileoptions,co_nortlunits);
 end;
 dirbefore:= setcurrentdirmse(filedir(filena.value));
 try
  bo1:= parser.parse(ansistring(ed.gettext),filena.value,parserparams);
  try
   errstream.position:= 0;
   grid[0].datalist.loadfromstream(errstream);
   if bo1 then begin
    if llvm.value then begin
     try
//      if not rrtued.value then begin
      filename1:= replacefileext(filena.value,'bc');
      if not (co_modular in parserparams.compileoptions) then begin
       if tllvmbcwriter.trycreate(tmsefilestream(targetstream),
                                  filename1,fm_create) <> sye_ok then begin
        grid.appendrow(['******TARGET FILE WRITE ERROR*******']);
       end
       else begin
        llvmops.run(targetstream,true,getfullsegment(seg_op,startupoffset));
       {$ifdef mse_debugparser}
        writeln('***************** LLVM BC gen end ***********');
       {$endif}
        targetstream.destroy();
        optname:= filenamebase(filename1);
        if opted.value <> '' then begin
         optname:= optname+'_opt';
         i2:= getprocessoutput(llvmbindir+'opt '+opted.value+
                                   ' -o '+optname+'.bc '+filename1,'',str1);
         grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
       {$ifdef mse_debugparser}
         writeln('***************** LLVM OPT end ***********');
       {$endif}
        end
        else begin
         i2:= 0;
        end;
        if i2 = 0 then begin
         i2:= getprocessoutput(llvmbindir+'llc '+llced.value+' -o '+
                                      filenamebase(filename1)+'.s '+
                                                   optname+'.bc','',str1);
         grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
       {$ifdef mse_debugparser}
         writeln('***************** LLC end ***********');
       {$endif}
         if i2 = 0 then begin
          i2:= getprocessoutput('gcc -lm -o '+filenamebase(filename1)+'.bin '+
                            filenamebase(filename1)+'.s','',str1);
          grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
        {$ifdef mse_debugparser}
          writeln('***************** gcc end ***********');
        {$endif}
        {
          if int1 = 0 then begin
           if not norun.value then begin
            int1:= getprocessoutput('./'+filenamebase(filename1)+'.bin','',str1);
            grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
            grid.appendrow(['EXITCODE: '+inttostrmse(int1)]);
           end;
          end;
        }
         end;
        end;
       end;
      end
      else begin
       if co_objmodules in parserparams.compileoptions then begin
        ar1:= objfiles();
        filename2:= filenamebase(filename1)+'.bin';
        grid.appendrow('link -> '+filename2);
        for int1:= 0 to high(ar1) do begin
         grid.appendrow(' '+ar1[int1]);
        end;
        grid.appendrow();
        i2:= getprocessoutput('gcc -lm -o'+filename2+' '+
                                                 quotefilename(ar1),'',str1);
       end
       else begin
        ar1:= bcfiles();
        filename2:= removefileext(filena.value)+'_all.bc';
        grid.appendrow('link -> '+filename2);
        for int1:= 0 to high(ar1) do begin
         grid.appendrow(' '+ar1[int1]);
        end;
        grid.appendrow();
        i2:= getprocessoutput(llvmbindir+'llvm-link -o='+filename2+' '+
                 quotefilename(ar1),'',str1);
        grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
        if i2 = 0 then begin
         i2:= getprocessoutput(llvmbindir+'llc '+llced.value+' '+
                                                         filename2,'',str1);
         grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
         if i2 = 0 then begin
          i2:= getprocessoutput('gcc -lm -o'+filenamebase(filename1)+'.bin '+
                            filenamebase(filename2)+'.s','',str1);
          grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
         end;
        end;
       end;
      end;
      if i2 = 0 then begin
       if not norun.value then begin
        grid.appendrow;
        i2:= getprocessoutput('./'+filenamebase(filename1)+'.bin','',str1);
        grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
        grid.appendrow(['EXITCODE: '+inttostrmse(i2)]);
       end;
      end;
     finally
      unithandler.deinit(true); //destroy unitlist
     end;
    end
    else begin
     filename1:= replacefileext(filena.value,'mli');
     if checksysok(tmsefilestream.trycreate(mlistream,filename1,fm_create),
                             err_cannotcreatetargetfile,[filename1]) then begin
      try
       writesegmentdata(mlistream,getfilekind(mlafk_rtprogram),
                                                           storedsegments,now);
      finally
       mlistream.destroy();
      end;      
     end;
     if not norun.value then begin
      grid.appendrow(['EXITCODE: '+inttostrmse(stackops.run(1024))]);
     end;
    end;
   end;
  finally
   errstream.destroy();
   outstream.destroy();
   if not (co_mlaruntime in parserparams.compileoptions) then begin
    elements.clear();
   end;
//   freeandnil(mainmetadatalist);
  end;
 finally
  setcurrentdirmse(dirbefore);
 end;
end;

procedure tmainfo.editnotiexe(const sender: TObject;
               var info: editnotificationinfoty);
begin
 coldi.value:= ed.col+1;
end;

procedure tmainfo.saveexe(const sender: TObject);
begin
 ed.savetofile(filena.value);
end;

procedure tmainfo.loadexe(const sender: TObject);
begin
 try
  ed.loadfromfile(filena.value);
 except
  application.handleexception;
  application.terminated:= false;
 end;
end;

procedure tmainfo.aftreadexe(const sender: TObject);
begin
 loadexe(nil);
// initparams();
end;

procedure tmainfo.befwriteexe(const sender: TObject);
begin
 saveexe(nil);
end;

procedure tmainfo.lineinfoset(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
{
 if avalue then begin
  include(info.debugoptions,do_lineinfo);
 end
 else begin
  exclude(info.debugoptions,do_lineinfo);
 end;
}
end;

procedure tmainfo.nameset(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 if avalue then begin
  include(info.o.debugoptions,do_names);
 end
 else begin
  exclude(info.o.debugoptions,do_names);
 end;
end;

procedure tmainfo.proginfoset(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
{
 if avalue then begin
  include(info.debugoptions,do_proginfo);
 end
 else begin
  exclude(info.debugoptions,do_proginfo);
 end;
 }
end;

procedure tmainfo.statupdateev(const sender: TObject; const filer: tstatfiler);
begin
 filer.updatevalue('unitdirs',fcompparams);
end;

procedure tmainfo.patheditev(const sender: TObject);
begin
 tpatheditfo.create(nil);
end;

procedure tmainfo.setcompparams(const avalue: msestringarty);
begin
 fcompparams:= avalue;
// initparams();
end;

procedure tmainfo.initparams();
begin
 compdebugmo.initparams(fcompparams);
// info.o.unitdirs:= reversearray(maindebugmo.sysenv.values[ord(pa_unitdirs)]);
end;

procedure tmainfo.createev(const sender: TObject);
begin
 application.options:= application.options - [apo_terminateonexception];
end;

end.
