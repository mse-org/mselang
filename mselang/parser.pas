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
 msetypes,msestream,parserglob,opglob,msestrings;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

const
 keywordchars = ['a'..'z','A'..'Z'];
 nokeywordendchars = keywordchars+['0'..'9','_'];
 contextstackreserve = 16; //guaranteed available above stacktop in handlers

  
function parse(const input: string; const abackend: backendty;
                                  const aerror: ttextstream): boolean;
                              //true if ok
function parseunit(const input: string;
                                       const aunit: punitinfoty): boolean;
procedure pushincludefile(const afilename: filenamety);

procedure init;
procedure deinit;

implementation
uses
 typinfo,grammar,handler,elements,sysutils,handlerglob,
 msebits,unithandler,msefileutils,errorhandler,mseformatstr,opcode,
 handlerutils,managedtypes,rttihandler,segmentutils,stackops,llvmops;
  
//
//todo: move context-end flag handling to handler procedures.
//

procedure init();
begin
 segmentutils.init();
 elements.init();
 handlerutils.init();
 unithandler.init();
// rttihandler.init();
// inifini.init;
// handler.init;
end;

procedure deinit();
begin
// handler.deinit;
// inifini.deinit;
// rttihandler.deinit();
 unithandler.deinit();
 handlerutils.deinit();
 elements.clear();
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
    sourcebefore:= source;
    sourcestartbefore:= sourcestart;
    filenamebefore:= filename;
    source.line:= 0;
    source.po:= pchar(input);
    sourcestart:= source.po;
    filename:= msefileutils.filename(afilename);
    debugsource:= source.po;
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
    source:= sourcebefore;
    sourcestart:= sourcestartbefore;
    filename:= filenamebefore;
    debugsource:= source.po;
    if source.po^ = #0 then begin
     result:= popincludefile();
    end;
   end;
  end;
 end;
end;

procedure incstack({const info: pparseinfoty});
begin
 with info do begin
  inc(stacktop);
  stackindex:= stacktop;
  if stacktop >= stackdepth then begin
   stackdepth:= 2*stackdepth;
   setlength(contextstack,stackdepth+contextstackreserve);
  end;
 end;
end;

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
  pc:= pb^.dest.context;
  contextstack[stackindex].transitionflags:= pb^.flags;
  if not (bf_changeparentcontext in pb^.flags) then begin
   contextstack[stackindex].returncontext:= pb^.stack;
         //replace return context
  end;

  int1:= contextstack[stackindex].parent;
  if bf_setparentbeforepush in pb^.flags then begin
   int1:= stackindex;
  end;
  if bf_push in pb^.flags then begin
   bo1:= true;
   incstack();
   if bf_setparentafterpush in pb^.flags then begin
    int1:= stacktop;
   end;
  end;
  if bf_changeparentcontext in pb^.flags then begin
   contextstack[int1].context:= pb^.stack;
         //replace return context
  end;
  with contextstack[stackindex],d do begin
   if bf_push in pb^.flags then begin
    kind:= ck_none;
//    start:= source;
    start:= contextstack[stackindex-1].start; //default
   end;
   if not (bf_nostartafter in pb^.flags) then begin
    start:= source;
   end
   else begin
    if not (bf_nostartbefore in pb^.flags) then begin
     start:= source;
     start.po:= beforeeat;
    end;
   end;
   context:= pc;
//   sourcebef:= source;
   debugstart:= debugsource;
   parent:= int1;
   opmark.address:= opcount;
  end;

  while pc^.branch = nil do begin //handle transition chain
   if pc^.next = nil then begin
    result:= false;  //open transition chain
    break;
   end;
   if pc^.handleentry <> nil then begin
    pc^.handleentry(); //transition handler
    if stopparser then begin
     result:= false;
     exit;
    end;
   end;
   if pc^.handleexit <> nil then begin
    pc^.handleexit(); //transition handler
    if stopparser then begin
     result:= false;
     exit;
    end;
   end;
   if pc^.nexteat then begin
    contextstack[stackindex].start:= source;
   end;
   if pc^.cutafter or pc^.cutbefore then begin
    stacktop:= stackindex;
   end;
   pc:= pc^.next;
   contextstack[stackindex].context:= pc;
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
   writeln('^'+ch1+pc^.caption); //push context
  end
  else begin
   writeln('>'+ch1+pc^.caption); //switch context
  end;
{$endif}
  pb:= pc^.branch;
  if (pc^.handleentry <> nil) then begin
   pc^.handleentry();
   if stopparser then begin
    result:= false;
   end;
  end;
 end;
end;

{$ifdef mse_debugparser}
procedure writeinfoline(const text: string);
begin
 with info do begin
  write('! '+text+' '+inttostr(stackindex)+':'+inttostr(stacktop));
  if pc <> nil then begin
   write(' '+pc^.caption);
  end;
  writeln();
 end;
end;
{$endif}

function parseunit(const input: string; const aunit: punitinfoty): boolean;

 procedure popparent;
 var
  int1: integer;
 begin
  with info do begin
   int1:= stackindex;
   stackindex:= contextstack[stackindex].parent;
  {$ifdef mse_checkinternalerror}                             
   if int1 = stackindex then begin
    internalerror(ie_parser,'20140324A');
   end;
  {$endif}
  end;
 end;//popparent

var
 po1,po2: pchar;
 pc1: pcontextty;
 int1: integer;
 bo1: boolean;
 keywordindex: identty;
 keywordend: pchar;
 linebreaks: integer;
 
 sourcebefore: sourceinfoty;
 filenamebefore: filenamety;
 sourcestartbefore: pchar;
 stackindexbefore: integer;
 stacktopbefore: integer;
 unitinfobefore: punitinfoty;
 pcbefore: pcontextty;
 stopparserbefore: boolean;
 eleparentbefore: elementoffsetty;
 currentstatementflagsbefore: statementflagsty;
{$ifdef mse_debugparser}
 debugsourcebefore: pchar;
{$endif}
label
 handlelab{,stophandlelab},parseend;
begin
 linebreaks:= 0;
 eleparentbefore:= ele.elementparent;
 ele.elementparent:= unitsele;
 with info do begin
  filenamebefore:= filename;
  sourcebefore:= source;
//  sourcebefbefore:= sourcebef;
 {$ifdef mse_debugparser}
  debugsourcebefore:= debugsource;
 {$endif}
  sourcestartbefore:= sourcestart;
  stackindexbefore:= stackindex;
  stacktopbefore:= stacktop;
  unitinfobefore:= unitinfo;
  pcbefore:= pc;
  stopparserbefore:= stopparser;
  currentsubchain:= 0;
  currentsubcount:= 0;
  currentstatementflagsbefore:= currentstatementflags;
  currentstatementflags:= [];
  inc(unitlevel);
  
  sourcestart:= pchar(input); //todo: use filecache and include stack
  source.po:= sourcestart;
  source.line:= 0;

  incstack();
  with contextstack[stackindex],d do begin
   kind:= ck_none;
   context:= startcontext;
   start.po:= pchar(input);
   debugstart:= start.po;
   start.line:= 0;
   parent:= stackindex;
  end;

  unitinfo:= aunit;
  filename:= msefileutils.filename(unitinfo^.filepath);
  if us_interfaceparsed in unitinfo^.state then begin
   if unitinfo^.impl.sourceoffset >= length(input) then begin
    errormessage(err_filetrunc,[filename]);
    debugsource:= source.po;
    goto parseend;
   end;
   inc(source.po,unitinfo^.impl.sourceoffset);
   source.line:= unitinfo^.impl.sourceline;
   with contextstack[stackindex],d do begin
    start:= source;
    debugstart:= start.po;
    context:= unitinfo^.impl.context;
   end;
   ele.elementparent:= unitinfo^.impl.eleparent;
  end;

  pc:= contextstack[stackindex].context;
  keywordindex:= 0;
  debugsource:= source.po;
  while true do begin
   if stackindex <= stacktopbefore then begin
    break;
   end;
   if (source.po^ = #0) and not popincludefile() then begin
    break;
   end;
   while true do begin
    if stackindex <= stacktopbefore then begin
     break;
    end;
    if (source.po^ = #0) and not popincludefile() then begin
     break;
    end;
    pb:= pc^.branch;
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
      po1:= source.po;
      linebreaks:= 0;
      if bf_keyword in pb^.flags then begin
       if keywordindex = 0 then begin
        while po1^ in keywordchars do begin
         inc(po1);
        end; 
        if (po1 <> source.po) and not (po1^ in nokeywordendchars) then begin
         keywordindex:= getident(source.po,po1);
         keywordend:= po1;
        end
        else begin
         keywordindex:= idstart; //invalid
        end;
        po1:= source.po;
       end;
       bo1:= keywordindex = pb^.keyword;
       if bo1 then begin
        po1:= keywordend;
       end;
      end
      else begin
       bo1:= po1^ in pb^.keys[0].chars;
       if bo1 then begin
        if po1^ = c_linefeed then begin
         inc(linebreaks);
        end;
        inc(po1);
        if pb^.keys[0].kind = bkk_charcontinued then begin
         bo1:= charset32ty(pb^.keys[1].chars)[byte(po1^) shr 5] and 
                                            bits[byte(po1^) and $1f] <> 0;
         if bo1 then begin
          if po1^ = c_linefeed then begin
           inc(linebreaks);
          end;       
          inc(po1);
          if pb^.keys[1].kind = bkk_charcontinued then begin
           bo1:= charset32ty(pb^.keys[2].chars)[byte(po1^) shr 5] and 
                                              bits[byte(po1^) and $1f] <> 0;
           if bo1 then begin
            if po1^ = c_linefeed then begin
             inc(linebreaks);
            end;       
            inc(po1);
            if pb^.keys[2].kind = bkk_charcontinued then begin
             bo1:= charset32ty(pb^.keys[3].chars)[byte(po1^) shr 5] and 
                                                bits[byte(po1^) and $1f] <> 0;
             if bo1 then begin
              if po1^ = c_linefeed then begin
               inc(linebreaks);
              end;       
              inc(po1);
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
       debugsource:= source.po;
      {$endif}
       beforeeat:= source.po;
       if bf_eat in pb^.flags then begin
        source.line:= source.line + linebreaks;
        linebreaks:= 0;
        keywordindex:= 0;
        source.po:= po1;
       end;
       if (pb^.dest.context = nil) and (bf_push in pb^.flags) then begin
        break; //terminate current context
       end;
       if (pb^.dest.context <> nil) then begin
        if bf_handler in pb^.flags then begin
         pb^.dest.handler();
         if stopparser then begin
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
           if stopparser then begin
            goto parseend;
           end;
           goto handlelab;
          end;
         until not (bf_emptytoken in pb^.flags); //no start default branch
        end;
       end;
       pb:= pc^.branch; //restart branch evaluation
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
    pc1:= pc;
    if pc1^.restoresource then begin
     source:= contextstack[stackindex].start;
     debugsource:= source.po;
     keywordindex:= 0;
    end;
    if pc^.handleexit <> nil then begin
         //call context termination handler
     pc^.handleexit();
     if stopparser then begin
      goto parseend;
     end;
         //take context terminate actions
     if pc^.cutbefore then begin
      stacktop:= stackindex;
     end;
     if (pc^.next = nil) and pc^.pop then begin
      popparent;
     end;
    end
    else begin
         //no handler, automatic stack decrement
     if pc^.cutbefore then begin
      stacktop:= stackindex;
     end;
     if pc^.next = nil then begin
      if pc^.pop then begin
       popparent;
      end
      else begin
       dec(stackindex);
      end;
     end;
    end;
    if pc^.cutafter then begin
     stacktop:= stackindex;
    end;
    if (stackindex <= stacktopbefore) or stopparser then begin
     goto parseend;
    end;
    pc:= contextstack[stackindex].context;
    if pc1^.popexe then begin
{$ifdef mse_debugparser1}
     writeinfoline('popexe');
{$endif}
     goto handlelab;    
    end;
{$ifdef mse_debugparser1}
    if not pc1^.continue and (pc^.next = nil) then begin
     writeinfoline('no next, no continue');
    end;
{$endif}
   until pc1^.continue or (pc^.next <> nil) or 
                 (bf_continue in contextstack[stackindex].transitionflags);
      //continue with branch checking
   with contextstack[stackindex] do begin
    if pc1^.continue or (returncontext <> nil) or 
                              (bf_continue in transitionflags) then begin
     exclude(transitionflags,bf_continue);
     if returncontext <> nil then begin
      context:= returncontext;
      pc:= returncontext;
      returncontext:= nil;
     end;
{$ifdef mse_debugparser}
     writeinfoline(pc1^.caption+'.>'+pc^.caption);
{$endif}
    end
    else begin
     if pc^.restoresource then begin
      source:= start;
     end
     else begin
      if pc^.nexteat then begin
       start:= source;
      end;
     end;
     if pc^.cutafter then begin
      stacktop:= stackindex;
     end;
{$ifdef mse_debugparser}
     writeinfoline(pc^.caption+'->'+pc^.next^.caption);
{$endif}
     pc:= pc^.next;
     context:= pc;
     if pc^.handleentry <> nil then begin
      pc^.handleentry();
      if stopparser then begin
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
  if not stopparser then begin
   writeinfoline('after2');
  end;
{$endif}
  if stf_hasmanaged in currentstatementflags then begin
   with unitinfo^ do begin
    inistart:= opcount;
    writemanagedvarop(mo_ini,varchain,true);
    if inistart = opcount then begin
     inistart:= 0;
    end
    else begin
     inistop:= opcount;
     with additem^ do begin
      setop(op,oc_goto);
     end;
    end;
    finistart:= opcount;
    writemanagedvarop(mo_fini,varchain,true);
    if finistart = opcount then begin
     finistart:= 0;
    end
    else begin
     finistop:= opcount;
     with additem^ do begin
      setop(op,oc_goto);
     end;
    end;
   end;
  end;
  result:= (errors[erl_fatal] = 0) and (errors[erl_error] = 0);
  if result and (unitlevel = 1) then begin
   unithandler.handleinifini();
//   setlength(ops,opcount);
   with pstartupdataty(getoppo(0))^ do begin
    globdatasize:= globdatapo;
   end;
  end;
  source:= sourcebefore;
 {$ifdef mse_debugparser}
  debugsource:= debugsourcebefore;
 {$endif}
  sourcestart:= sourcestartbefore;
  stackindex:= stackindexbefore;
  stacktop:= stacktopbefore;
  unitinfo:= unitinfobefore;
  filename:= filenamebefore;
  pc:= pcbefore;
  stopparser:= stopparserbefore;
  currentstatementflags:= currentstatementflagsbefore;
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
        
function parse(const input: string; const abackend: backendty;
               const aerror: ttextstream
                {out aopcode: opinfoarty; out aconstseg: bytearty}): boolean;
                              //true if ok
var
 po1: punitinfoty;
 unit1: punitinfoty;
 int1: integer;
begin
 exitcode:= 0;
 fillchar(info,sizeof(info),0);
 result:= false;
 init();
 with info do begin
  try
   try
    backend:= abackend;
    unit1:= newunit('program');
    unit1^.filepath:= 'main.mla'; //dummy
    
    stringbuffer:= '';
    errorstream:= aerror;
    stackdepth:= defaultstackdepth;
    setlength(contextstack,stackdepth);
    stacktop:= -1;
    stackindex:= stacktop;
    opcount:= startupoffset;
    allocid:= 0;
    allocsegmentpo(seg_op,opcount*sizeof(opinfoty));
    case backend of
     bke_direct: begin
      beginparser(stackops.getoptable(),@stackops.allocproc);
     end;
     bke_llvm: begin
      beginparser(llvmops.getoptable(),@llvmops.allocproc);
     end;
    end;
    result:= parseunit(input,unit1);
    endparser();
   finally
    system.finalize(info);
    deinit();
   end;
  except
  end;
 end;
end;

end.
