{ MSElang Copyright (c) 2013-2016 by Martin Schreiber
   
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
unit parser;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
{$ifdef mse_debugparser}
 {$define mse_debugparser1}
{$endif}
interface
uses
 globtypes,msetypes,msestream,parserglob,opglob,msestrings;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

const
 keywordchars = ['a'..'z','A'..'Z'];
 nokeywordendchars = keywordchars+['0'..'9','_'];
 contextstackreserve = 16; //guaranteed available above stacktop in handlers


procedure resetinfo();
procedure initio(const aoutput: ttextstream; const aerror: ttextstream);
  
function parse(const input: string; const afilename: filenamety;
                                     const aoptions: compileoptionsty): boolean;
                              //true if ok
function parseunit(const input: string; const aunit: punitinfoty;
                   const ainterfaceonly: boolean): boolean;
                                       
procedure pushincludefile(const afilename: filenamety);
procedure pushdummycontext(const akind: contextkindty);
procedure switchcontext(const acontext: pcontextty);
procedure saveparsercontext(var acontext: pparsercontextty; 
                                               const astackcount: int32);
procedure restoreparsercontext(const acontext: pparsercontextty);
procedure freeparsercontext(var acontext: pparsercontextty);
procedure postlineinfo();

//procedure init;
//procedure deinit;

implementation
uses
 typinfo,grammar,handler,elements,sysutils,handlerglob,
 msebits,unithandler,msefileutils,errorhandler,mseformatstr,opcode,
 handlerutils,managedtypes,rttihandler,segmentutils,stackops,llvmops,
 subhandler,listutils,llvmbitcodes,llvmlists,unitwriter,unitreader,
 identutils,compilerunit,msearrayutils;
  
//
//todo: move context-end flag handling to handler procedures.
//

procedure init();
begin
 segmentutils.init();
 elements.init();
 handlerutils.init();
 unithandler.init();
// opcode.init();
// rttihandler.init();
// inifini.init;
// handler.init;
end;

procedure deinit(const freeunitlist: boolean);
begin
// handler.deinit;
// inifini.deinit;
// rttihandler.deinit();
// opcode.deinit();
 unithandler.deinit(freeunitlist);
 handlerutils.deinit();
 if co_mlaruntime in info.o.compileoptions then begin
  elements.clear();
 end;
 segmentutils.deinit();
 
end;


//
// todo: optimize, this is a proof of concept only
//

procedure pushincludefile(const afilename: filenamety);
begin
 with info do begin
  if includeindex > high(includestack) then begin
   errormessage(err_toomanyincludes,[]);
  end
  else begin
   with includestack[includeindex] do begin
    try
     input:= readfiledatastring(afilename);
    except
     filereaderror(afilename);
     exit;
    end;
    sourcebefore:= s.source;
    sourcestartbefore:= s.sourcestart;
    filenamebefore:= s.filename;
    s.source.line:= 0;
    s.source.po:= pchar(input);
    s.sourcestart:= s.source.po;
    s.filename:= msefileutils.filename(afilename);
   {$ifdef mse_debugparser}
    s.debugsource:= s.source.po;
   {$endif}
   end;
   inc(includeindex);
  end;
 end;
end;

function popincludefile: boolean;
begin
 with info do begin
  result:= includeindex > 0;
  if result then begin
   dec(includeindex);
   with includestack[includeindex] do begin
    input:= '';
    s.source:= sourcebefore;
    s.sourcestart:= sourcestartbefore;
    s.filename:= filenamebefore;
   {$ifdef mse_debugparser}
    s.debugsource:= s.source.po;
   {$endif}
    if s.source.po^ = #0 then begin
     result:= popincludefile();
    end;
   end;
  end;
 end;
end;

procedure switchcontext(const acontext: pcontextty);
begin
 with info do begin
  s.pc:= acontext;
  with contextstack[s.stackindex] do begin
   context:= acontext;
   include(transitionflags,bf_continue);
  end;
 end;
end;

procedure incstack(const acount: int32 = 1);
begin
 with info do begin
  inc(s.stacktop,acount);
  s.stackindex:= s.stacktop;
  if s.stacktop >= stackdepth then begin
   stackdepth:= 2*stackdepth;
   setlength(contextstack,stackdepth+contextstackreserve);
  end;
  with contextstack[s.stacktop] do begin
   d.handlerflags:= [];
  end;
 end;
end;

procedure pushdummycontext(const akind: contextkindty);
var
 poind: pcontextitemty;
begin
 with info do begin
  inc(s.stacktop);
  if s.stacktop >= stackdepth then begin
   stackdepth:= 2*stackdepth;
   setlength(contextstack,stackdepth+contextstackreserve);
  end;
  poind:= @contextstack[s.stackindex];
  with contextstack[s.stacktop] do begin
   d.kind:= akind;
   parent:= poind^.parent;
   start:= poind^.start;
  {$ifdef mse_debugparser}
   debugstart:= start.po;
  {$endif}
   context:= nil;
   returncontext:= nil;
   transitionflags:= [];
   opmark.address:= opcount;
  end;
 end;
end;

procedure saveparsercontext(var acontext: pparsercontextty;
                                          const astackcount: int32);
var
 stacksize1: int32;
begin
 stacksize1:= astackcount*sizeof(contextitemty);
 acontext:= getmem(sizeof(parsercontextty)+stacksize1);
 fillchar(acontext^,sizeof(acontext^),0);
 with acontext^ do begin
  compilerswitches:= info.s.compilerswitches;
  currentscopemeta:= info.s.currentscopemeta;
  source:= info.s.input;
  sourceoffset:= info.s.source.po-info.s.sourcestart;
  sourceline:= info.s.source.line;
  eleparent:= ele.elementparent;
  stackcount:= astackcount;
  stackindex:= info.s.stackindex;
  stacktop:= info.s.stacktop;

  move(info.contextstack[info.s.stacktop-astackcount+1],
                                             contextstack,stacksize1);
 end;
end;

procedure restoreparsercontext(const acontext: pparsercontextty);
var
 stacksize1: int32;
 i1: int32;
 delta1: int32;
begin
 with acontext^ do begin
  stacksize1:= stackcount*sizeof(contextitemty);
  incstack(stackcount);
  move(contextstack,info.contextstack[info.s.stacktop-stackcount+1],stacksize1);
  delta1:= info.s.stacktop - stacktop;
  for i1:= info.s.stacktop - stackcount + 1 to info.s.stacktop do begin
   with info.contextstack[i1] do begin
    parent:= parent + delta1;
   end;
  end;
  info.s.compilerswitches:= compilerswitches;
  info.s.currentscopemeta:= currentscopemeta;
  info.s.input:= source;
  info.s.sourcestart:= pchar(source);
  info.s.source.po:= info.s.sourcestart + sourceoffset;
  info.s.source.line:= sourceline;
  ele.elementparent:= eleparent;
  info.s.stackindex:= stackindex+delta1;
 end;
end;

procedure freeparsercontext(var acontext: pparsercontextty);
begin
 if acontext <> nil then begin
  system.finalize(acontext^);
  freemem(acontext);
  acontext:= nil;
 end;
end;

{$ifdef mse_debugparser}
procedure writetransitioninfo(const text: string);
begin
 with info do begin
  if not (cos_internaldebug in s.compilerswitches) then begin
   exit;
  end;
  write(text+' I:'+inttostr(s.stackindex)+' T:'+inttostr(s.stacktop));
  if s.stackindex >= 0 then begin
   write(' P:'+
             inttostr(contextstack[s.stackindex].parent));
  end;
  if s.pc <> nil then begin
   write(' '+s.pc^.caption);
  end;
  writeln();
 end;
end;

procedure writeinfoline(const text: string);
begin
 writetransitioninfo('! '+text);
end;
{$endif}


function pushcont({const info: pparseinfoty}): boolean;
        //handle branch transition flags, transitionhandler, set pc
        //returns false for stopparser or open transistion chain
var
 int1: integer;
 bo1: boolean;
{$ifdef mse_debugparser}
 ch1: char;
{$endif}
begin
 result:= true;
 bo1:= false;
 with info do begin
  s.pc:= pb^.dest.context;
  contextstack[s.stackindex].transitionflags:= pb^.flags;
  if not (bf_changeparentcontext in pb^.flags) then begin
   contextstack[s.stackindex].returncontext:= pb^.stack;
         //replace return context
  end;

  int1:= contextstack[s.stackindex].parent;
  if bf_setparentbeforepush in pb^.flags then begin
   int1:= s.stackindex;
  end;
  if bf_push in pb^.flags then begin
   bo1:= true;
   incstack();
   if bf_setparentafterpush in pb^.flags then begin
    int1:= s.stacktop;
   end;
  end;
  if bf_changeparentcontext in pb^.flags then begin
   contextstack[int1].context:= pb^.stack;
         //replace return context
  end;
  with contextstack[s.stackindex],d do begin
   if bf_push in pb^.flags then begin
    kind:= ck_none;
//    start:= source;
    start:= contextstack[s.stackindex-1].start; //default
   end;
   if not (bf_nostartafter in pb^.flags) then begin
    start:= s.source;
   end
   else begin
    if not (bf_nostartbefore in pb^.flags) then begin
     start:= s.source;
     start.po:= beforeeat;
    end;
   end;
   context:= s.pc;
//   sourcebef:= source;
  {$ifdef mse_debugparser}
   debugstart:= s.debugsource;
  {$endif}
   parent:= int1;
   opmark.address:= opcount;
  end;

  while s.pc^.branch = nil do begin //handle transition chain
   if s.pc^.next = nil then begin
    result:= false;  //open transition chain
    break;
   end;
   if s.pc^.handleentry <> nil then begin
    s.pc^.handleentry(); //transition handler
    if s.stopparser then begin
     result:= false;
     exit;
    end;
   end;
   if s.pc^.handleexit <> nil then begin
    s.pc^.handleexit(); //transition handler
    if s.stopparser then begin
     result:= false;
     exit;
    end;
   end;
   if s.pc^.nexteat then begin
    contextstack[s.stackindex].start:= s.source;
   end;
   if s.pc^.cutafter or s.pc^.cutbefore then begin
    s.stacktop:= s.stackindex;
   end;
   s.pc:= s.pc^.next;
   contextstack[s.stackindex].context:= s.pc;
  end;
{$ifdef mse_debugparser1}
  ch1:= ' ';
  if bf_setparentbeforepush in pb^.flags then begin
   ch1:= '-';
  end;
  if bf_setparentafterpush in pb^.flags then begin
   ch1:= '+';
  end;
  if bo1 then begin
   writetransitioninfo('^'+ch1+s.pc^.caption); //push context
  end
  else begin
   writetransitioninfo('>'+ch1+s.pc^.caption); //switch context
  end;
{$endif}
  pb:= s.pc^.branch;
  if (s.pc^.handleentry <> nil) then begin
   s.pc^.handleentry();
   if s.stopparser then begin
    result:= false;
   end;
  end;
 end;
end;

function linelen(const astr: pchar): integer;
var
 po1: pchar;
begin
 po1:= astr;
 while not (po1^ in [#0,c_return,c_linefeed]) do begin
  inc(po1);
 end;
 result:= po1-astr;
end;

procedure postlineinfo();
begin
 if (do_lineinfo in info.s.debugoptions) and 
             (co_llvm in info.o.compileoptions) then begin   //todo: columns
  include(info.s.currentstatementflags,stf_newlineposted);
  with additem(oc_lineinfo)^.par.lineinfo do begin
   loc.line:= info.s.source.line;
   loc.col:= 0;
   loc.scope:= info.s.currentscopemeta.id;
  end;
 end;
end;

procedure checklinebreak(var achar: pchar; var linebreaks: integer) 
                          {$ifndef mse_debugparser} inline{$endif};
begin
 if do_lineinfo in info.s.debugoptions then begin        //todo: columns
  if not (stf_newlineposted in info.s.currentstatementflags) then begin
   include(info.s.currentstatementflags,stf_newlineposted);
   if (co_llvm in info.o.compileoptions) then begin
    with additem(oc_lineinfo)^.par.lineinfo do begin
     loc.line:= linebreaks+info.s.source.line;
     loc.col:= 0;
     loc.scope:= info.s.currentscopemeta.id;
    end;
   end;
  end;
 end;
 if achar^ = c_linefeed then begin
  inc(linebreaks);
  exclude(info.s.currentstatementflags,stf_newlineposted);
 end;
 inc(achar);
end;

function parseunit(const input: string; const aunit: punitinfoty;
                                      const ainterfaceonly: boolean): boolean;

var
 popped: boolean;
 
 procedure popparent;
 var
  int1: integer;
 begin
  with info do begin
{$ifdef mse_debugparser1}
   writeinfoline('pop ->'+
             contextstack[contextstack[s.stackindex].parent].context^.caption);
{$endif}
   popped:= true;
   int1:= s.stackindex;
   s.stackindex:= contextstack[s.stackindex].parent;
  {$ifdef mse_checkinternalerror}                             
   if int1 = s.stackindex then begin
    internalerror(ie_parser,'20140324A');
   end;
  {$endif}
  end;
 end;//popparent

 procedure parseimplementations();
 begin
  with info do begin
   if (unitlevel = 1) then begin 
                       //todo: parse implementations as soon as possible
    while (intfparsedchain <> 0) and result do begin
    {$ifdef mse_debugparser}
      writeln();
      writeln('***************************************** implementation');
      writeln(punitlinkinfoty(
             getlistitem(intfparsedlinklist,intfparsedchain))^.ref^.filepath);
    {$endif}
     result:= parseunit('',punitlinkinfoty(
                getlistitem(intfparsedlinklist,intfparsedchain))^.ref,false);
     deletelistitem(intfparsedlinklist,intfparsedchain);
    end;
   end;
  end;
 end; //parseimplementations

var
 po1,po2: pchar;
 pc1{,pc2}: pcontextty;
 inifinisub: opaddressty;
 int1: integer;
 bo1: boolean;
 keywordindex: identty;
 keywordend: pchar;
 linebreaks: integer;
 ad1: listadty;
 statebefore: savedparseinfoty;  
 eleparentbefore: elementoffsetty;
 i1: int32;
 m1,m2,m3: metavaluety;
 
label
 handlelab{,stophandlelab},parseend;
begin
 result:= false;
 with info do begin
  inc(unitlevel);
  statebefore:= s;
  s.unitinfo:= aunit;
  aunit^.dwarflangid:= DW_LANG_Pascal83;
  if o.compileoptions * [co_readunits,co_build] = [co_readunits] then begin
   if not (us_invalidunitfile in aunit^.state) and 
                                      readunitfile(aunit) then begin
    result:= true;
    parseimplementations();
    s:= statebefore;
    dec(unitlevel);
    if unitlevel = 0 then begin
     with pstartupdataty(getoppo(0))^ do begin
      globdatasize:= globdatapo;
     end;
     with getoppo(startupoffset)^ do begin
      par.beginparse.mainad:= info.s.unitinfo^.mainad;
     end;
    end;
    exit;
   end;
  end;
  if (aunit^.llvmlists = nil) and (co_llvm in info.o.compileoptions) then begin
   if co_writeunits in info.o.compileoptions then begin
    aunit^.llvmlists:= tllvmlists.create();
   end
   else begin 
    aunit^.llvmlists:= globllvmlists;
   end;
  end;
  linebreaks:= 0;
  eleparentbefore:= ele.elementparent;
  ele.elementparent:= unitsele;

  resetssa();
  currentsubchain:= 0;
  currentsubcount:= 0;
  s.currentstatementflags:= [];
  s.currentopcodemarkchain:= 0;
  s.globlinkage:= li_internal;
//  inc(unitlevel);
  
//  s.unitinfo:= aunit;
  s.filename:= msefileutils.filename(s.unitinfo^.filepath);
  s.interfaceonly:= ainterfaceonly;

  if not (us_interfaceparsed in s.unitinfo^.state) then begin
                            //parse from start
   s.input:= input;
   s.sourcestart:= pchar(input); //todo: use filecache and include stack
   s.source.po:= s.sourcestart;
   s.source.line:= 0;
 
   incstack();
   with contextstack[s.stackindex],d do begin
    kind:= ck_none;
    context:= startcontext;
    start.po:= pchar(input);
    debugstart:= start.po;
    start.line:= 0;
    parent:= s.stackindex;
   end;
   aunit^.stackstart:= s.stacktop;
   beginunit(aunit);
   
   if (s.debugoptions <> []) then begin
    with s.unitinfo^ do begin
     if llvmlists <> nil then begin
      with llvmlists.metadatalist do begin
       filepathmeta:= adddifile(filepath);
       debugfilemeta:= filepathmeta;
       {llvmlists.metadatalist.adddifile(filepathmeta);}
       compileunitmeta:= adddicompileunit(
          filepathmeta,dwarflangid,'MSElang 0.0',dummymeta,dummymeta,
                                                                  FullDebug);
//       s.currentscopemeta:= compileunitmeta;
       addnamednode(stringtolstring('llvm.dbg.cu'),
                                            [compileunitmeta.id]);
       if not hasmoduleflags then begin
        hasmoduleflags:= true;
        m1:= i32const(ord(mfb_warning));
        m2:= addnode([m1,addstring(stringtolstring('Dwarf Version')),
                                      i8const(mse_DWARF_VERSION)]);
                                      
        m3:= addnode([m1,addstring(stringtolstring('Debug Info Version')),
                             i8const(DEBUG_METADATA_VERSION)]);

        addnamednode(stringtolstring('llvm.module.flags'),[m2.id,
                                                    m3.id]);
       end;
      end;
     end;
    end;
   end;
   markinterfacestart();
     //possibly overridden by unithandler.setunitname() or 
     //handleafterintfuses().
  end
  else begin //continue with implementation parsing
  {$ifdef mse_checkinternalerror}
   if s.unitinfo^.implstart = nil then begin
    internalerror(ie_parser,'20120529A');
   end;
   if us_implementationparsed in s.unitinfo^.state then begin
    internalerror(ie_parser,'20130603A');
   end;
  {$endif}
   restoreparsercontext(s.unitinfo^.implstart);
   freeparsercontext(s.unitinfo^.implstart);
  (*
   if s.unitinfo^.impl.sourceoffset >= length(input) then begin
    errormessage(err_filetrunc,[s.filename]);
   {$ifdef mse_debugparser}
    s.debugsource:= s.source.po;
   {$endif}
    goto parseend;
   end;
   inc(s.source.po,s.unitinfo^.impl.sourceoffset);
   s.source.line:= s.unitinfo^.impl.sourceline;
   with contextstack[s.stackindex],d do begin
    start:= s.source;
    debugstart:= start.po;
    context:= s.unitinfo^.impl.context;
   end;
   ele.elementparent:= s.unitinfo^.impl.eleparent;
  *)
  end;

  with s.unitinfo^ do begin
   s.currentfilemeta:= filepathmeta;
   s.currentcompileunitmeta:= compileunitmeta;
   if do_proginfo in info.o.debugoptions then begin
    pushcurrentscope(compileunitmeta);
//    pushcurrentscope(filepathmeta);
//    setcurrentscope(filepathmeta);
   end
   else begin
    pushcurrentscope(dummymeta);
//    setcurrentscope(dummymeta);
   end;
  end;

  s.pc:= contextstack[s.stackindex].context;
  keywordindex:= 0;
 {$ifdef mse_debugparser}
  s.debugsource:= s.source.po;
  outinfo('START',false);
 {$endif}
  while true do begin
   if s.stackindex <= statebefore.stacktop then begin
    break;
   end;
   if (s.source.po^ = #0) and not popincludefile() then begin
    break;
   end;
   while true do begin
    if s.stackindex <= statebefore.stacktop then begin
     break;
    end;
    if (s.source.po^ = #0) and not popincludefile() then begin
     break;
    end;
    pb:= s.pc^.branch;
    if pb = nil then begin
     break; //no branch
    end;
    if bf_emptytoken in pb^.flags then begin
     pushcont(); //default branch
               //???? why no break or standard match handling
    end
    else begin
     while pb^.flags <> [] do begin
           //check match
      po1:= s.source.po;
      linebreaks:= 0;
      if bf_keyword in pb^.flags then begin
       if keywordindex = 0 then begin
        while po1^ in keywordchars do begin
         inc(po1);
        end; 
        if (po1 <> s.source.po) and not (po1^ in nokeywordendchars) then begin
         keywordindex:= getident(s.source.po,po1);
         keywordend:= po1;
        end
        else begin
         keywordindex:= idstart; //invalid
        end;
        po1:= s.source.po;
        checklinebreak(po1,linebreaks);
       end;
       bo1:= keywordindex = pb^.keyword;
       if bo1 then begin
        po1:= keywordend;
       end;
      end
      else begin
       bo1:= po1^ in pb^.keys[0].chars;
       if bo1 then begin
        checklinebreak(po1,linebreaks);
        if pb^.keys[0].kind = bkk_charcontinued then begin
         bo1:= charset32ty(pb^.keys[1].chars)[byte(po1^) shr 5] and 
                                            bits[byte(po1^) and $1f] <> 0;
         if bo1 then begin
          checklinebreak(po1,linebreaks);
          if pb^.keys[1].kind = bkk_charcontinued then begin
           bo1:= charset32ty(pb^.keys[2].chars)[byte(po1^) shr 5] and 
                                              bits[byte(po1^) and $1f] <> 0;
           if bo1 then begin
            checklinebreak(po1,linebreaks);
            if pb^.keys[2].kind = bkk_charcontinued then begin
             bo1:= charset32ty(pb^.keys[3].chars)[byte(po1^) shr 5] and 
                                                bits[byte(po1^) and $1f] <> 0;
             if bo1 then begin
              checklinebreak(po1,linebreaks);
             end;
            end;
           end;
          end;
         end;
        end;
       end;
      end;
      if bo1 then begin //match
      {$ifdef mse_debugparser}
       s.debugsource:= s.source.po;
      {$endif}
       beforeeat:= s.source.po;
       if bf_eat in pb^.flags then begin
        s.source.line:= s.source.line + linebreaks;
        linebreaks:= 0;
        keywordindex:= 0;
        s.source.po:= po1;
       end;
       if (pb^.dest.context = nil) and (bf_push in pb^.flags) then begin
        break;                                  //terminate current context
       end;
       if (pb^.dest.context <> nil) then begin
        if bf_handler in pb^.flags then begin
         pb^.dest.handler();
         if s.stopparser then begin
          goto parseend;
         end;
         s.pc:= contextstack[s.stackindex].context;
                                   //stackindex could be changed
         if bf_push in pb^.flags then begin
//          s.pc:= contextstack[s.stackindex].context;
//                                   //stackindex could be changed
          break;                                //terminate current context
         end
        end
        else begin                              //switch branch context
         repeat
          if not pushcont() then begin          //can not continue
           if s.stopparser then begin
            goto parseend;
           end;
           goto handlelab;
          end;
         until not (bf_emptytoken in pb^.flags); //no start default branch
        end;
       end;
       pb:= s.pc^.branch;                        //restart branch evaluation
       continue;
      end;
      inc(pb);                                   //next branch
     end;  
     break;                                      //no match, next context
    end;
   end;
handlelab:
{$ifdef mse_debugparser}
   if (cos_internaldebug in s.compilerswitches) then begin
   {$ifdef mse_debugparser1}
    writetransitioninfo('*** terminate context');
   {$endif}
//    writeln('*** terminate context');
          //context terminated, pop stack
   end;
{$endif}
   repeat
    popped:= false;
    pc1:= s.pc;
    if pc1^.restoresource then begin
     s.source:= contextstack[s.stackindex].start;
   {$ifdef mse_debugparser}
     s.debugsource:= s.source.po;
    {$endif}
     keywordindex:= 0;
    end;
    if s.pc^.handleexit <> nil then begin
         //call context termination handler
     i1:= s.stackindex;
     s.pc^.handleexit();
     s.pc:= contextstack[s.stackindex].context; //stackindex could be changed
     if s.stackindex < i1 then begin
      popped:= true;
     end;
     if s.stopparser then begin
      goto parseend;
     end;
         //take context terminate actions
     if s.pc^.cutbefore then begin
      s.stacktop:= s.stackindex;
     end;
     if (s.pc^.next = nil) and s.pc^.pop then begin
      popparent();
     end;
    end
    else begin
         //no handler, automatic stack decrement
     if s.pc^.cutbefore then begin
      s.stacktop:= s.stackindex;
     end;
     if s.pc^.next = nil then begin
      if s.pc^.pop then begin
       popparent;
      end
      else begin
       dec(s.stackindex);
      end;
     end;
    end;
    if s.pc^.cutafter then begin
     s.stacktop:= s.stackindex;
    end;
    if (s.stackindex <= statebefore.stacktop) or s.stopparser then begin
     goto parseend;
    end;
    while true do begin                        //skip deleted contexts
     s.pc:= contextstack[s.stackindex].context;
     if s.pc <> nil then begin
      break;
     end;
     dec(s.stackindex);
     if s.stackindex < 1 then begin
      internalerror1(ie_parser,'20160821B');
     end;
    end;
    if popped then begin
     if (s.pc^.handleexit <> nil) and (s.pc^.next <> nil) and 
       not (pc1^.continue or (bf_continue in 
                        contextstack[s.stackindex].transitionflags)) then begin
         //call context termination handler
      s.pc^.handleexit();
      if s.stopparser then begin
       goto parseend;
      end;
     end;
    end;
    if pc1^.popexe then begin
{$ifdef mse_debugparser1}
     writeinfoline('popexe');
{$endif}
     goto handlelab;    
    end;
{$ifdef mse_debugparser1}
    if not pc1^.continue and (s.pc^.next = nil) and 
               not (bf_continue in 
                      contextstack[s.stackindex].transitionflags) then begin
     writeinfoline('no next, no continue');
    end;
{$endif}
   until pc1^.continue or (s.pc^.next <> nil) or 
                 (bf_continue in contextstack[s.stackindex].transitionflags);
      //continue with branch checking
   with contextstack[s.stackindex] do begin
    if pc1^.continue or (returncontext <> nil) or 
                              (bf_continue in transitionflags) then begin
     exclude(transitionflags,bf_continue);
     if returncontext <> nil then begin
      context:= returncontext;
      s.pc:= returncontext;
      returncontext:= nil;
     end;
{$ifdef mse_debugparser}
     writeinfoline(pc1^.caption+'.>'+s.pc^.caption);
{$endif}
    end
    else begin
     if s.pc^.restoresource then begin
      s.source:= start;
     end
     else begin
      if s.pc^.nexteat then begin
       start:= s.source;
      end;
     end;
     if s.pc^.cutafter then begin
      s.stacktop:= s.stackindex;
     end;
{$ifdef mse_debugparser}
     writeinfoline(s.pc^.caption+'->'+s.pc^.next^.caption);
{$endif}
//     pc2:= s.pc;
     s.pc:= s.pc^.next;
     context:= s.pc;
{
     if pc2^.handleexit <> nil then begin
      pc2^.handleexit();
      if s.stopparser then begin
       goto parseend;
      end;
     end;
}
     if s.pc^.handleentry <> nil then begin
      s.pc^.handleentry();
      if s.stopparser then begin
       goto parseend;
      end;
     end;
    end;
   end;
{$ifdef mse_debugparser1}
   writeinfoline('after1');
{$endif}
  end;
parseend:
{$ifdef mse_debugparser1}
  if not s.stopparser then begin
   writeinfoline('after2');
  end;
{$endif}
  linkresolve(s.currentopcodemarkchain); //delete chain
{
  with s.unitinfo^,externallinklist do begin
   ad1:= externalchain;
   while ad1 <> 0 do begin         //emit externals
    with pexternallinkinfoty(list+ad1)^ do begin
     ad1:= header.next;
    end;
   end;
   freelist(externallinklist);
  end;
}
  with s.unitinfo^ do begin
   if [stf_needsmanage,stf_needsini] * s.currentstatementflags <> [] then begin
    if getinternalsub(isub_ini,inifinisub) then begin //no initialization section                                               
     writemanagedvarop(mo_ini,varchain,s.stacktop);
     endsimplesub(false);
    end;
   end;
   if [stf_needsmanage,stf_needsfini] * s.currentstatementflags <> [] then begin
    if getinternalsub(isub_fini,inifinisub) then begin //no finalization section
     writemanagedvarop(mo_fini,varchain,s.stacktop);
     endsimplesub(false);
    end;
   end;
  end;
  result:= (errors[erl_fatal] = 0) and (errors[erl_error] = 0);
  with punitdataty(ele.eledataabs(s.unitinfo^.interfaceelement))^ do begin
   varchain:= s.unitinfo^.varchain;
  end;
  if result then begin
   if s.interfaceonly and 
            not (us_implementationparsed in s.unitinfo^.state) then begin
    with punitlinkinfoty(addlistitem(
                               intfparsedlinklist,intfparsedchain))^ do begin
     ref:= s.unitinfo;
    end;       
   end;
   parseimplementations();
   if (unitlevel = 1) then begin 
    if result then begin
     with pstartupdataty(getoppo(0))^ do begin
      globdatasize:= globdatapo;
     end;
    end;
   end;
   if us_implementationparsed in aunit^.state then begin
    result:= endunit(aunit) and result;
   end;
  end;
  popcurrentscope();
  if (result = false) or (us_implementationparsed in aunit^.state) then begin
   finalizeunit(aunit);
  end;
  s:= statebefore;  
  dec(unitlevel);
  ele.elementparent:= eleparentbefore;
 end;
{
 if result and (co_writertunits in info.compileoptions) then begin
  result:= writeunitfile(aunit);
 end;
} 
{$ifdef mse_debugparser}
 if (cos_internaldebug in info.s.compilerswitches) then begin
  write('**** end **** ');
 end;
 if aunit <> nil then begin
  writeinfoline(ansistring(aunit^.filepath));
 end
 else begin
  writeinfoline('NIL');
 end;
{$endif}
end;

procedure resetinfo();
var
 optbefore: parseoptionsty;
begin
 optbefore:= info.o;
 system.finalize(info);
 fillchar(info,sizeof(info),0);
 info.o:= optbefore; 
 exitcode:= 0;
end;

procedure initio(const aoutput: ttextstream; const aerror: ttextstream);
{
var
 debugoptionsbefore: debugoptionsty;
 compilerswitchesbefore: compilerswitchesty;
}
begin
{
 debugoptionsbefore:= info.debugoptions;
 compilerswitchesbefore:= info.compilerswitches;
 finalize(info);
 fillchar(info,sizeof(info),0);
 info.debugoptions:= debugoptionsbefore;
 info.compilerswitches:= compilerswitchesbefore;
 exitcode:= 0;
}
 with info do begin
  outputstream:= aoutput;
  errorstream:= aerror;
 end;
end;

function parse(const input: string; const afilename: filenamety; 
                                     const aoptions: compileoptionsty): boolean;
                              //true if ok
var                           
 po1: punitinfoty;
 po2: pchar;
 unit1,unit2: punitinfoty;
 i1: integer;
 pcond: pconditiondataty;
 lstr1: lstringty;
 rtlunit1: rtlunitty;
begin
 result:= false;
// init();
 with info do begin
  try
   try
    o.compileoptions:= aoptions;
    o.debugoptions:= [];
    if co_llvm in aoptions then begin
     if co_lineinfo in aoptions then begin
      include(info.o.debugoptions,do_lineinfo);
     end;
     if co_proginfo in aoptions then begin
      include(info.o.debugoptions,do_proginfo);
     end;    
     if co_names in aoptions then begin
      include(info.o.debugoptions,do_names);
     end;    
    end;
    s.debugoptions:= o.debugoptions;
    s.compilerswitches:= o.compilerswitches;
    modularllvm:= aoptions * [co_llvm,co_writeunits] = [co_llvm,co_writeunits];
    init();
//    globelement:= ele.addelementduplicate1(idstart,ek_global,[]); //globals
    for i1:= 0 to high(o.defines) do begin
     with o.defines[i1] do begin
      po2:= msestrings.strscan(pointer(name),'=');
      if po2 <> nil then begin
       ele.adduniquechilddata(rootelement,
                     [tks_defines,getident(pchar(pointer(name)),po2)],
                                               ek_condition,allvisi,pcond);
       pcond^.value.kind:= dk_none;
       lstr1.po:= po2+1;
       lstr1.len:= length(name)-(lstr1.po-pchar(pointer(name)));
       if trystrtoint64(lstr1,pcond^.value.vinteger) then begin
        pcond^.value.kind:= dk_integer;
       end
       else begin
        pcond^.value.vstring:= newstringconst(lstr1);
        pcond^.value.kind:= dk_string;
       end;
      end
      else begin
       ele.adduniquechilddata(rootelement,
                  [tks_defines,getident(name)],ek_condition,allvisi,pcond);
       pcond^.value.kind:= dk_none;
      end;
      pcond^.deleted:= deleted;
     end;
    end;
    unit1:= newunit('program');
    unit1^.filepath:= afilename; //todo: file reading
    if not initunitfileinfo(unit1) then begin
     //todo: error message
    end;
//    getunitfile(unit1,afilename);
    s.unitinfo:= unit1;
    scopemetaindex:= 0;
    stringbuffer:= '';
    stackdepth:= defaultstackdepth;
    setlength(contextstack,stackdepth);
    s.stacktop:= -1;
    s.stackindex:= s.stacktop;
    opcount:= startupoffset;
    allocsegmentpo(seg_op,opcount*sizeof(opinfoty));
    if co_llvm in o.compileoptions then begin
     beginparser(llvmops.getoptable());
    end
    else begin
     beginparser(stackops.getoptable());
    end;
    result:= parsecompilerunit(rtlunitnames[rtl_system],
                                          info.rtlunits[rtl_system]);
    if result then begin
//     po1:= info.systemunit;
     setlength(unit1^.interfaceuses,1);
     unit1^.interfaceuses[0]:= info.rtlunits[rtl_system];
     if result and not (co_nocompilerunit in aoptions) then begin
      result:= parsecompilerunit(memhandlerunitname,unit2);
      if result  then begin
       result:= parsecompilerunit(compilerunitname,unit2);
      end;
     end;
     if result and not (co_nortlunits in aoptions)then begin
      rtlunit1:= rtl_system;
      inc(rtlunit1);
      for rtlunit1:= rtlunit1 to high(rtlunits) do begin
       result:= parsecompilerunit(rtlunitnames[rtlunit1],unit2);
       if not result then begin
        break;
       end;
       msearrayutils.additem(pointerarty(unit1^.interfaceuses),pointer(unit2));
      end;
     end;
     if result then begin
      result:= parseunit(input,unit1,false);
     end;
    end;
    endparser();
//    mainmetadatalist:= unit1^.metadatalist;
//    unit1^.metadatalist:= nil;
   finally
//    system.finalize(info);
    deinit(not result or not (co_llvm in aoptions));
   end;
  except
   result:= false;
  end;
 end;
end;

end.
