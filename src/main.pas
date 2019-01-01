{ MSElang Copyright (c) 2013-2018 by Martin Schreiber
   
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
 msememodialog,msedropdownlist,parser,msedragglob,msegridsglob;

const
 llvmbindir2 = 
 '/usr/bin/';
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
   edgrid: twidgetgrid;
   ed: tsyntaxedit;
   coldi: tintegerdisp;
   tbutton5: tbutton;
   tbutton2: tbutton;
   filena: tfilenameedit;
   tsyntaxpainter1: tsyntaxpainter;
   opted: tmemodialoghistoryedit;
   llced: tmemodialoghistoryedit;
   gcced: tmemodialoghistoryedit;
   llvmbindir: tfilenameedit;
   tgroupbox1: tgroupbox;
   nameed: tbooleanedit;
   builded: tbooleanedit;
   llvm: tbooleanedit;
   nortlunitsed: tbooleanedit;
   nocompilerunited: tbooleanedit;
   objed: tbooleanedit;
   modulared: tbooleanedit;
   lineinfoed: tbooleanedit;
   proginfoed: tbooleanedit;
   tbutton3: tbutton;
   keeptmped: tbooleanedit;
   beopt: tbooleanedit;
   bellc: tbooleanedit;
   begcc: tbooleanedit;
   tsplitter1: tsplitter;
   tmemodialoghistoryedit2: tmemodialoghistoryedit;
   belink: tbooleanedit;
   edexeex: tedit;
   runend: tbooleanedit;
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
   procedure changopt(const sender: TObject);
   procedure changgcc(const sender: TObject);
   procedure changllc(const sender: TObject);
  private
   fcompparams: msestringarty;
   procedure setcompparams(const avalue: msestringarty);
  protected
   procedure initparams(var parserparams: parserparamsty);
  public
   property compparams: msestringarty read fcompparams write setcompparams;
 end;
var
 mainfo: tmainfo;

//procedure test(); virtual;
  
implementation
uses
 errorhandler,main_mfm,stackops,llvmops,msedatalist,msearrayutils,
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
 i1,i2,x, er: int32;
 dt1: tdatetime;
 ho, mi, se, ms: word;
begin
{$ifdef mse_debugparser}
 writeln('*****************************************');
{$endif}
 er := 0;

 dt1:= now;
 errstream:= ttextstream.create;
 outstream:= ttextstream.create;
 resetinfo();
 initio(outstream,errstream);
 system.finalize(parserparams);
 fillchar(parserparams,sizeof(parserparams),0);

 initparams(parserparams);
 parserparams.buildoptions.llvmlinkcommand:= 
                                    tosysfilepath(llvmbindir.value+'llvm-link');
 parserparams.buildoptions.llccommand:= tosysfilepath(llvmbindir.value+'llc')+
   ' '+llced.value;
   
 if beopt.value then                                                         
 if opted.value <> '' then begin
  parserparams.buildoptions.llvmoptcommand:= llvmbindir.value+'opt '+opted.value;
 end;
 
 if begcc.value then  
 if gcced.value <> '' then begin
  parserparams.buildoptions.gcccommand:= 
                parserparams.buildoptions.gcccommand+' '+gcced.value;
 end;
 
// parserparams.buildoptions.ascommand:= tosysfilepath('as');
 parserparams.buildoptions.exefile:= tosysfilepath(
                                        replacefileext(filena.value,'bin'));
 if llvm.value then begin
  parserparams.compileoptions:= (parserparams.compileoptions -
                                     mlaruntimecompileoptions) + 
                                llvmcompileoptions + [co_buildexe];
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
 if keeptmped.value then begin
  include(parserparams.compileoptions,co_keeptmpfiles);
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
 
  include(parserparams.compileoptions,co_nodeinit);
  bo1:= parser.parse(ansistring(ed.gettext),filena.value,parserparams);
  try
   errstream.position:= 0;
   grid[0].datalist.loadfromstream(errstream);
   if bo1 then begin
    if llvm.value then begin
     try
      filename1:= replacefileext(filena.value,'bc');
      if not (co_modular in parserparams.compileoptions) then begin
       if tllvmbcwriter.trycreate(tmsefilestream(targetstream),
                                  filename1,fm_create) <> sye_ok then begin
        grid.appendrow(['******TARGET FILE WRITE ERROR*******']);
       end 
       else begin
       grid.appendrow(['*** ' + filename(filename1) + ' created by mselang from ' +
         filename(filena.value) +' ***']);
          llvmops.run(targetstream,true,info.s.unitinfo^.mainfini,
                           getfullsegment(seg_op,0{startupoffset}));
       {$ifdef mse_debugparser}
        writeln('***************** LLVM BC gen ended ***********');
       {$endif}
        targetstream.destroy();
        optname:= filenamebase(filename1);
        if beopt.value then  
        begin
          grid.appendrow([]);
         optname:= optname+'_opt';
         i2:= getprocessoutput(llvmbindir.value+'opt '+opted.value+
                                   ' -o '+optname+'.bc '+filename1,'',str1);
         grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
       {$ifdef mse_debugparser}
         writeln('***************** LLVM OPT ended ***********');
       {$endif}
          x := 0;
           
           while (x < grid.rowcount) and (er = 0) do begin
            if system.pos('error',grid[0][x]) > 0 then er := 1;  
            inc(x);
            end;
                   
          if er = 0 then         
         grid.appendrow(['*** '+optname+'.bc created by llvm-opt from '+filename(filename1)+' ***'])
         else 
          grid.appendrow(['*** '+optname+'.bc not created... ***']);
         end
        else begin
         i2:= 0;
        end;
               
        if i2 = 0 then begin
        
        if bellc.value then begin  
          i2:= getprocessoutput(llvmbindir.value+'llc '+llced.value+' -o '+
                                      filenamebase(filename1)+'.s '+
                                                   optname+'.bc','',str1);
         grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
       {$ifdef mse_debugparser}
         writeln('***************** LLC ended ***********');
       {$endif}
         grid.appendrow(['*** '+filename(filename1)+'.s created by llvm-llc from '+optname+'.bc ***']);
       
        end;
        
          optname:= filenamebase(filename1);
        
     // llvm-link
     if belink.value then begin 
         if i2 = 0 then begin
       
         if beopt.value then  
         optname:= removefileext(filena.value)+'_opt.bc' else
         optname:= removefileext(filena.value)+'.bc';
        
        filename2:= removefileext(filena.value)+ edexeex.text ;
      
        i2:= getprocessoutput(llvmbindir.value+'llvm-link -o='+filename2+' '+
                 optname,'',str1);
        grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
        grid.appendrow(['*** '+filename(filename2)+ ' created by llvm-link from '+ 
        filename(optname)+' ***']);
        end;
        
        {$ifdef unix}
         if i2 = 0 then begin       
         if beopt.value then  
         optname:= removefileext(filena.value)+'_opt.bc' else
         optname:= removefileext(filena.value)+'.bc';
        
        filename2:= removefileext(filena.value)+ edexeex.text ;
      
        i2:= getprocessoutput('chmod 0755 '+filename2,'',str1);
        grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
        grid.appendrow(['*** chmod 0755 assigned to '+filename(filename2)+' ***']);
        end;
       {$endif}
       
      end;        
      // ended link   
        
         if begcc.value then begin 
         if i2 = 0 then begin
          grid.appendrow([]);
          filename2:= removefileext(filena.value)+ edexeex.text ;
      
          i2:= getprocessoutput('gcc -lm -o '+ filename2+' '+
                            filenamebase(filename1)+'.s','',str1);
          grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
           
           x := 0;
           
           while (x < grid.rowcount) and (er = 0) do begin
            if system.pos('Error',grid[0][x]) > 0 then er := 1;  
            inc(x);
            end;
                   
          if er = 0
          then  grid.appendrow(['*** '+filename(filename2)+' created by gcc from '+filename(filename1)+'.s ***'])
          else  grid.appendrow(['*** '+filename(filename2)+' failed to create ***']);
    
        {$ifdef mse_debugparser}
          writeln('***************** gcc ended ***********');
        {$endif}
           grid.appendrow;
        end;
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
        
         dt1 := now-dt1;
         DecodeTime(dt1, ho, mi, se, ms);
         
         grid.appendrow;
         grid.appendrow(['*** Process duration: ' + format('%.2d:%.2d:%.2d.%.3d',
          [ho, mi, se, ms])+ ' ***']) ;
         
         if er = 0 then
          grid.appendrow(['*** All is OK. :) ***']) else
          grid.appendrow(['*** Some process failed ***']);
          
        end;
       end;
       
      end
      else begin
        if (co_modular in parserparams.compileoptions) then
       grid.appendrow(['*** Modular compilation done ***']);
      {
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
      }
       i2:= 0;
      end;
      if i2 = 0 then begin
       if runend.value then begin
         grid.appendrow;
         grid.appendrow(['*** Running '+filenamebase(filename1)+ edexeex.text + ' ***']);
         grid.appendrow;
         grid.appendrow;
        i2:= getprocessoutput('./'+filenamebase(filename1)+ edexeex.text ,'',str1);
        grid[0].readpipe(str1,[aco_stripescsequence,aco_multilinepara],120);
        
        if i2 = 0 then grid.appendrow(['*** Executable ended without errors ***']) else
        grid.appendrow(['*** Executable EXITCODE: '+inttostrmse(i2)+ ' ***']);
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
      grid.appendrow(['*** '+filename(filename1)+ ' created by MSElang from '+ 
      filename(filena.value)+' ***']);
  
     end;
            
      if (stackops.run(1024) = 0) and (er = 0) then grid.appendrow(['*** Compilation is OK. :) ***'])
       else grid.appendrow(['*** Compilation EXITCODE: '+inttostrmse(i2)+ ' ***']);   
    
    end;
   end;
  finally
    if (co_modular in parserparams.compileoptions) then
       grid.appendrow(['*** Modular compilation done ***']);
   errstream.destroy();
   outstream.destroy();
   if not (co_mlaruntime in parserparams.compileoptions) then begin
    elements.clear();
   end;
   {unithandler.}parser.deinit(true); //free unitlist
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
if fileexists(filena.value) then
begin
 try
  ed.loadfromfile(filena.value);
 except
  application.handleexception;
  application.terminated:= false;
 end;
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

procedure tmainfo.initparams(var parserparams: parserparamsty);
begin
 compdebugmo.initparams(fcompparams,parserparams);
// info.o.unitdirs:= reversearray(maindebugmo.sysenv.values[ord(pa_unitdirs)]);
end;

procedure tmainfo.createev(const sender: TObject);
begin
 application.options:= application.options - [apo_terminateonexception];
end;

procedure tmainfo.changopt(const sender: TObject);
begin
opted.enabled := beopt.value;
end;

procedure tmainfo.changgcc(const sender: TObject);
begin
gcced.enabled := begcc.value;
end;

procedure tmainfo.changllc(const sender: TObject);
begin
llced.enabled := bellc.value;
end;

end.
