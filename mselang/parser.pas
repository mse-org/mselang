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
interface
uses
 msetypes,msestream,stackops,parserglob;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

const
 keywordchars = ['a'..'z','A'..'Z'];
 nokeywordendchars = keywordchars+['0'..'9','_'];
 
function parse(const input: string; const acommand: ttextstream;
               out aopcode: opinfoarty; out aconstseg: bytearty): boolean;
                              //true if ok
function parseunit({const info: pparseinfoty;} const input: string;
                                       const aunit: punitinfoty): boolean;

procedure init;
procedure deinit;

{$ifdef mse_debugparser}
procedure outinfo(const text: string);
{$endif}
implementation
uses
 typinfo,grammar,handler,elements,msestrings,sysutils,handlerglob,
 msebits,unithandler,msefileutils,errorhandler,mseformatstr,opcode,
 handlerutils;
  
//
//todo: move context-end flag handling to handler procedures.
//

procedure init;
begin
 elements.init;
 handlerutils.init;
 unithandler.init;
// handler.init;
end;

procedure deinit;
begin
// handler.deinit;
 unithandler.deinit;
 handlerutils.deinit;
 elements.clear;
end;

{$ifdef mse_debugparser}
procedure outinfo(const text: string);
 procedure writetype(const ainfo: typeinfoty);
 var
  po1: ptypedataty;
 begin
  with ainfo do begin
   po1:= ele.eledataabs(typedata);
   write('T:',inttostr(typedata),' ',
          getenumname(typeinfo(datakindty),ord(po1^.kind)),' ',
          'I:',inttostr(indirectlevel),' ');
  end;
 end;
 
var
 int1: integer;
begin
 with info do begin
{$ifdef mse_debugparser}
  writeln('  ',text,' T:',stacktop,' I:',stackindex,' O:',opcount,'L:'+
    inttostr(source.line+1)+':''',psubstr(debugsource,source.po)+''','''+
                         singleline(source.po),'''');
{$endif}
  for int1:= stacktop downto 0 do begin
   write(fitstring(inttostr(int1),3,sp_right));
   if int1 = stackindex then begin
    write('*');
   end
   else begin
    write(' ');
   end;
   if (int1 < stacktop) and (int1 = contextstack[int1+1].parent) then begin
    write('-');
   end
   else begin
    write(' ');
   end;
   with contextstack[int1],d do begin
    write(fitstring(inttostr(parent),3,sp_right),' ');
    if bf_continue in transitionflags then begin
     write('>');
    end
    else begin
     write(' ');
    end;
    if context <> nil then begin
     with context^ do begin
      if cutbefore then begin
       write('-');
      end
      else begin
       write(' ');
      end;
      if pop then begin
       write('^');
      end
      else begin
       write(' ');
      end;
      if popexe then begin
       write('!');
      end
      else begin
       write(' ');
      end;
      if cutafter then begin
       write('-');
      end
      else begin
       write(' ');
      end;
     end;
     write(fitstring(inttostr(opmark.address),3,sp_right));
     write('<',context^.caption,'> ');
    end
    else begin
     write(fitstring(inttostr(opmark.address),3,sp_right));
     write('<NIL> ');
    end;
    write(getenumname(typeinfo(kind),ord(kind)),' ');
    case kind of
     ck_ident: begin
      write('$',hextostr(ident.ident,8),':',ident.len);
      if ident.continued then begin
       write('c ');
      end
      else begin
       write('  ');
      end;
      write(getidentname(ident.ident));
     end;
     ck_fact: begin
      writetype(datatyp);
     end;
     ck_ref: begin
      writetype(datatyp);
     end;
     ck_const: begin
      writetype(datatyp);
      case constval.kind of
       dk_boolean: begin
        write(constval.vboolean,' ');
       end;
       dk_integer: begin
        write(constval.vinteger,' ');
       end;
       dk_float: begin
        write(constval.vfloat,' ');
       end;
       dk_address: begin
        with constval.vaddress do begin
         write(settostring(ptypeinfo(typeinfo(varflagsty)),
                               integer(constval.vaddress.flags),true));
         write('I:',inttostr(indirectlevel),' A:',inttostr(address),' ');
        end;
       end;
      end;
     end;
     ck_proc: begin
      write('flags:',settostring(ptypeinfo(typeinfo(procflagsty)),
                           integer(proc.flags),true),' pasize:',proc.paramsize);
     end;
     ck_paramsdef: begin
      with paramsdef do begin
       write('kind:',getenumname(typeinfo(kind),ord(kind)))
      end;
     end;
    end;
{$ifdef mse_debugparser}
    writeln(' '+inttostr(start.line+1)+':''',psubstr(debugstart,start.po),''',''',
                     singleline(start.po),'''');
{$endif}
   end;
  end;
 end;
end;
{$endif}

//
// todo: optimize, this is a proof of concept only
//

procedure incstack({const info: pparseinfoty});
begin
 with info do begin
  inc(stacktop);
  stackindex:= stacktop;
  if stacktop = stackdepht then begin
   stackdepht:= 2*stackdepht;
   setlength(contextstack,stackdepht);
  end;
 end;
end;

function pushcont({const info: pparseinfoty}): boolean;
        //handle branch transition flags, transitionhandler, set pc
        //returns false for stopparser or open transistion chain
var
 int1: integer;
 bo1: boolean;
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
   incstack({info});
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
    pc^.handleentry({info}); //transition handler
    if stopparser then begin
     result:= false;
     exit;
    end;
   end;
   if pc^.handleexit <> nil then begin
    pc^.handleexit({info}); //transition handler
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
  pb:= pc^.branch;
{$ifdef mse_debugparser}
  if bo1 then begin
   outinfo({info,}'^ '+pc^.caption); //push context
  end
  else begin
   outinfo({info,}'> '+pc^.caption); //switch context
  end;
{$endif}
  if (pc^.handleentry <> nil) then begin
   pc^.handleentry({info});
   if stopparser then begin
    result:= false;
   end;
  end;
 end;
end;

function parseunit({const info: pparseinfoty;} const input: string;
                                       const aunit: punitinfoty): boolean;
 procedure popparent;
 var
  int1: integer;
 begin
  with info do begin
   int1:= stackindex;
   stackindex:= contextstack[stackindex].parent;
   if int1 = stackindex then begin
    internalerror({info,}'P20140324A');
   end;
  end;
 end; //popparent

var
 po1,po2: pchar;
 pc1: pcontextty;
 int1: integer;
 bo1: boolean;
 keywordindex: identty;
 keywordend: pchar;
 linebreaks: integer;
 
 sourcebefore: sourceinfoty;
// sourcebefbefore: sourceinfoty;
 sourcestartbefore: pchar;
 stackindexbefore: integer;
 stacktopbefore: integer;
 unitinfobefore: punitinfoty;
 pcbefore: pcontextty;
 stopparserbefore: boolean;
{$ifdef mse_debugparser}
 debugsourcebefore: pchar;
{$endif}
label
 handlelab{,stophandlelab},parseend;
begin
 linebreaks:= 0;
 with info do begin
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
  inc(unitlevel);
  
  sourcestart:= pchar(input); //todo: use filecache and include stack
  source.po:= sourcestart;
  source.line:= 0;

  incstack({info});
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
    errormessage({info,}err_filetrunc,[filename]);
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
{$ifdef mse_debugparser}
  outinfo({info,}'****');
{$endif}
  while (source.po^ <> #0) and (stackindex > stacktopbefore) do begin
   while (source.po^ <> #0) and (stackindex > stacktopbefore) do begin
            //check context branches
//    sourcebef:= source;
    pb:= pc^.branch;
    if pb = nil then begin
     break; //no branch
    end;
    if bf_emptytoken in pb^.flags then begin
     pushcont({info}); //default branch
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
         pb^.dest.handler({info});
         if stopparser then begin
          goto parseend;
         end;
         if bf_push in pb^.flags then begin
          break; //terminate current context
         end
        end
        else begin //switch branch context
         repeat
          if not pushcont({info}) then begin 
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
   writeln('***');
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
     pc^.handleexit({info});
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
{$ifdef mse_debugparser}
     outinfo({info,}'! after0a');
{$endif}
     goto handlelab;    
    end;
{$ifdef mse_debugparser}
    if not pc1^.continue and (pc^.next = nil) then begin
     outinfo({info,}'! after0b');
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
     writeln(pc1^.caption,'.>',pc^.caption);
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
     writeln(pc^.caption,'->',pc^.next^.caption);
{$endif}
     pc:= pc^.next;
     context:= pc;
     if pc^.handleentry <> nil then begin
      pc^.handleentry({info});
      if stopparser then begin
       goto parseend;
      end;
     end;
    end;
//    kind:= ck_none;
   end;
{$ifdef mse_debugparser}
   outinfo({info,}'! after1');
{$endif}
  end;
parseend:
{$ifdef mse_debugparser}
  if not stopparser then begin
   outinfo({info,}'! after2');
  end;
{$endif}
  setlength(ops,opcount);
  with pstartupdataty(pointer(ops))^ do begin
   globdatasize:= globdatapo;
  end;
  result:= (errors[erl_fatal] = 0) and (errors[erl_error] = 0);
  source:= sourcebefore;
//  sourcebef:= sourcebefbefore;
 {$ifdef mse_debugparser}
  debugsource:= debugsourcebefore;
 {$endif}
  sourcestart:= sourcestartbefore;
  stackindex:= stackindexbefore;
  stacktop:= stacktopbefore;
  unitinfo:= unitinfobefore;
  pc:= pcbefore;
  stopparser:= stopparserbefore;
  dec(unitlevel);
 end;

{$ifdef mse_debugparser}
 write('**** end **** ');
 if aunit <> nil then begin
  writeln(aunit^.filepath);
 end
 else begin
  writeln('NIL');
 end;
{$endif}
end;
        
function parse(const input: string; const acommand: ttextstream;
               {const aunit: punitinfoty;} out aopcode: opinfoarty;
                                     out aconstseg: bytearty): boolean;
                              //true if ok
var
 startopcount: integer;
 po1: punitinfoty;
 unit1: punitinfoty;
begin
 fillchar(info,sizeof(info),0);
 unit1:= newunit('program');
 unit1^.filepath:= 'main.mla'; //dummy
 
 with info do begin
  ops:= nil;
  constseg:= nil;
  constcapacity:= defaultconstsegsize;
  setlength(constseg,constcapacity);
  constsize:= 4; //0 -> not allocated
  stringbuffer:= '';
  command:= acommand;
  stackdepht:= defaultstackdepht;
  setlength(contextstack,stackdepht);
  stacktop:= -1;
  stackindex:= stacktop;
  opcount:= startupoffset;
  setlength(ops,opcount);
  initparser({info});
  startopcount:= opcount;
  result:= parseunit({info,}input,unit1);
  {
  inc(unitlevel);
  while result do begin
   po1:= nextunitimplementation;
   if (po1 = nil) then begin
    break;
   end;
   result:= parseimplementation(@info,po1);
  end;
  }
  if not result or (opcount = startopcount) then begin
   ops:= nil;
  end;
  aopcode:= ops; 
  aconstseg:= constseg;
 end;
end;

end.
