{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
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


procedure initio(const aoutput: ttextstream; const aerror: ttextstream);
  
function parse(const input: string; const afilename: filenamety;
                                     const abackend: backendty): boolean;
                              //true if ok
function parseunit(const input: string;
                                       const aunit: punitinfoty): boolean;
                                       
procedure pushincludefile(const afilename: filenamety);
procedure switchcontext(const acontext: pcontextty);

//procedure init;
//procedure deinit;

implementation
uses
 typinfo,grammar,handler,elements,sysutils,handlerglob,
 msebits,unithandler,msefileutils,errorhandler,mseformatstr,opcode,
 handlerutils,managedtypes,rttihandler,segmentutils,stackops,llvmops,
 subhandler,listutils;
  
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

procedure deinit(const abackend: backendty);
begin
// handler.deinit;
// inifini.deinit;
// rttihandler.deinit();
// opcode.deinit();
 unithandler.deinit();
 handlerutils.deinit();
 if abackend <> bke_llvm then begin
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

procedure incstack({const info: pparseinfoty});
begin
 with info do begin
  inc(s.stacktop);
  s.stackindex:= s.stacktop;
  if s.stacktop >= stackdepth then begin
   stackdepth:= 2*stackdepth;
   setlength(contextstack,stackdepth+contextstackreserve);
  end;
 end;
end;

{$ifdef mse_debugparser}
procedure writetransitioninfo(const text: string);
begin
 with info do begin
  write(text+' I:'+inttostr(s.stackindex)+' T:'+inttostr(s.stacktop)+' P:'+
             inttostr(contextstack[s.stackindex].parent));
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

procedure checklinebreak(var achar: pchar; var linebreaks: integer) 
                          {$ifndef mse_debugparser} inline{$endif};
begin
 if do_lineinfo in info.debugoptions then begin
  if not (stf_newlineposted in info.s.currentstatementflags) then begin
   include(info.s.currentstatementflags,stf_newlineposted);
   if info.backend = bke_llvm then begin
    with additem(oc_lineinfo)^ do begin
     par.lineinfo.line.po:= achar;
     par.lineinfo.line.len:= linelen(achar);
     par.lineinfo.loc.line:= linebreaks+info.s.source.line;
     par.lineinfo.loc.col:= 0;
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

function parseunit(const input: string; const aunit: punitinfoty): boolean;

var
 popped: boolean;
 
 procedure popparent;
 var
  int1: integer;
 begin
  with info do begin
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
 
label
 handlelab{,stophandlelab},parseend;
begin
 linebreaks:= 0;
 eleparentbefore:= ele.elementparent;
 ele.elementparent:= unitsele;
 with info do begin
  statebefore:= s;

  resetssa();
  currentsubchain:= 0;
  currentsubcount:= 0;
  s.currentstatementflags:= [];
  inc(unitlevel);
  
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

  s.unitinfo:= aunit;
  s.filename:= msefileutils.filename(s.unitinfo^.filepath);
  if not (us_interfaceparsed in s.unitinfo^.state) then begin
   if s.debugoptions <> [] then begin
    s.unitinfo^.filepathmeta:= 
                      s.unitinfo^.metadatalist.adddifile(s.unitinfo^.filepath);
   end;
  end
  else begin
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
  end;

  s.pc:= contextstack[s.stackindex].context;
  keywordindex:= 0;
 {$ifdef mse_debugparser}
  s.debugsource:= s.source.po;
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
        break; //terminate current context
       end;
       if (pb^.dest.context <> nil) then begin
        if bf_handler in pb^.flags then begin
         pb^.dest.handler();
         if s.stopparser then begin
          goto parseend;
         end;
         if bf_push in pb^.flags then begin
          break; //terminate current context
         end
        end
        else begin //switch branch context
         repeat
          if not pushcont() then begin 
                //can not continue
           if s.stopparser then begin
            goto parseend;
           end;
           goto handlelab;
          end;
         until not (bf_emptytoken in pb^.flags); //no start default branch
        end;
       end;
       pb:= s.pc^.branch; //restart branch evaluation
       continue;
      end;
      inc(pb); //next branch
     end;  
     break; //no match, next context
    end;
   end;
handlelab:
{$ifdef mse_debugparser}
   writeln('*** terminate context');
          //context terminated, pop stack
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
     s.pc^.handleexit();
     if s.stopparser then begin
      goto parseend;
     end;
         //take context terminate actions
     if s.pc^.cutbefore then begin
      s.stacktop:= s.stackindex;
     end;
     if (s.pc^.next = nil) and s.pc^.pop then begin
      popparent;
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
    if (s.stackindex <= statebefore.stacktop) or s.stopparser then begin
     goto parseend;
    end;
    if s.pc^.cutafter then begin
     s.stacktop:= s.stackindex;
    end;
    s.pc:= contextstack[s.stackindex].context;
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
    if not pc1^.continue and (s.pc^.next = nil) then begin
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
  if stf_hasmanaged in s.currentstatementflags then begin
   with s.unitinfo^ do begin
    if getinternalsub(isub_ini,inifinisub) then begin //no initialization section                                               
     writemanagedvarop(mo_ini,varchain,true,0);
     endsimplesub();
    end;
    if getinternalsub(isub_fini,inifinisub) then begin //no finalization section
     writemanagedvarop(mo_fini,varchain,true,0);
     endsimplesub();
    end;
   end;
  end;
  result:= (errors[erl_fatal] = 0) and (errors[erl_error] = 0);
  with punitdataty(ele.eledataabs(s.unitinfo^.interfaceelement))^ do begin
   varchain:= s.unitinfo^.varchain;
  end;
  if result and (unitlevel = 1) then begin
//   unithandler.handleinifini();
//   setlength(ops,opcount);
   with pstartupdataty(getoppo(0))^ do begin
    globdatasize:= globdatapo;
   end;
  end;

  s:= statebefore;  
  dec(unitlevel);
  ele.elementparent:= eleparentbefore;
 end;
 
{$ifdef mse_debugparser}
 write('**** end **** ');
 if aunit <> nil then begin
  writeinfoline(aunit^.filepath);
 end
 else begin
  writeinfoline('NIL');
 end;
{$endif}
end;

procedure initio(const aoutput: ttextstream; const aerror: ttextstream);
var
 debugoptionsbefore: debugoptionsty;
begin
 debugoptionsbefore:= info.debugoptions;
 fillchar(info,sizeof(info),0);
 info.debugoptions:= debugoptionsbefore;
 exitcode:= 0;
 with info do begin
  outputstream:= aoutput;
  errorstream:= aerror;
 end;
end;

function parse(const input: string; const afilename: filenamety; 
                                        const abackend: backendty): boolean;
                              //true if ok
var
 po1: punitinfoty;
 unit1: punitinfoty;
 int1: integer;
begin
 result:= false;
 init();
 with info do begin
  try
   try
    backend:= abackend;
    s.debugoptions:= debugoptions;
    unit1:= newunit('program');
    unit1^.filepath:= afilename;
    s.unitinfo:= unit1;
    stringbuffer:= '';
    stackdepth:= defaultstackdepth;
    setlength(contextstack,stackdepth);
    s.stacktop:= -1;
    s.stackindex:= s.stacktop;
    opcount:= startupoffset;
    allocsegmentpo(seg_op,opcount*sizeof(opinfoty));
    case backend of
     bke_direct: begin
      beginparser(stackops.getoptable(),stackops.getssatable());
     end;
     bke_llvm: begin
      backendhasfunction:= true;
      beginparser(llvmops.getoptable(),llvmops.getssatable());
     end;
    end;
   {$ifndef mse_nocompilerunit}
    result:= parsecompilerunit('__mla__compilerunit');
    if result then begin
   {$endif}
     result:= parseunit(input,unit1);
   {$ifndef mse_nocompilerunit}
    end;
   {$endif}
    endparser();
    mainmetadatalist:= unit1^.metadatalist;
    unit1^.metadatalist:= nil;
   finally
    system.finalize(info);
    deinit(abackend);
   end;
  except
   result:= false;
  end;
 end;
end;

end.
