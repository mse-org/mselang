{ MSEide Copyright (c) 2013 by Martin Schreiber
   
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
               const aunit: punitinfoty; out opcode: opinfoarty): boolean;
                              //true if ok
//procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);

procedure init;
procedure deinit;

implementation
uses
 typinfo,grammar,handler,elements,msestrings,sysutils,
 msebits,unithandler,msefileutils,errorhandler,mseformatstr;
  
//procedure handledecnum(const info: pparseinfoty); forward;
//procedure handlefrac(const info: pparseinfoty); forward;

//
//todo: move context-end flag handling to handler procedures.
//

procedure init;
begin
 elements.init;
 unithandler.init;
 handler.init;
end;

procedure deinit;
begin
 handler.deinit;
 unithandler.deinit;
 elements.clear;
end;

{$ifdef mse_debugparser}
procedure outinfo(const info: pparseinfoty; const text: string);
var
 int1: integer;
begin
 with info^ do begin
{$ifdef mse_debugparser}
  writeln('  ',text,' T:',stacktop,' I:',stackindex,' O:',opcount,' '+
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
    with context^ do begin
     if cut then begin
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
    end;
    if context <> nil then begin
     write('<',context^.caption,'> ');
    end
    else begin
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
     ck_const: begin
      case factkind of
       dk_bool8: begin
        write(constval.vbool8,' ');
       end;
       dk_int32: begin
        write(constval.vint32,' ');
       end;
       dk_flo64: begin
        write(constval.vflo64,' ');
       end;
      end;
     end;
     ck_opmark: begin
      write(opmark.address,' ');
     end;
     ck_proc: begin
      write('paco:',proc.paramcount);
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
{
procedure internalerror(const info: pparseinfoty; const atext: string);
begin
 writeln('*INTERNAL ERROR* ',atext);
 outinfo(info,'');
 abort;
end;
}
function pushcont(const info: pparseinfoty): boolean;
        //handle branch transition flags, transitionhandler, set pc
        //returns false for stopparser or open transistion chain
var
 int1: integer;
 bo1: boolean;
begin
 result:= true;
 bo1:= false;
 with info^ do begin
  pc:= pb^.dest.context;
  if not (bf_changeparentcontext in pb^.flags) then begin
   contextstack[stackindex].returncontext:= pb^.stack;
         //replace return context
  end;
  while pc^.branch = nil do begin //handle transition chain
   if pc^.next = nil then begin
    result:= false;  //open transition chain
    break;
   end;
   pc^.handle(info); //transition handler
   if stopparser then begin
    result:= false;
    exit;
   end; 
   if pc^.nexteat then begin
    contextstack[stackindex].start:= source;
   end;
   if pc^.cut then begin
    stacktop:= stackindex;
   end;
   pc:= pc^.next;
  end;
  int1:= contextstack[stackindex].parent;
  if bf_setparentbeforepush in pb^.flags then begin
   int1:= stackindex;
  end;
  if bf_push in pb^.flags then begin
   bo1:= true;
   inc(stacktop);
   stackindex:= stacktop;
   if stacktop = stackdepht then begin
    stackdepht:= 2*stackdepht;
    setlength(contextstack,stackdepht);
   end;
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
   end;
   context:= pc;
   if not (bf_nostart in pb^.flags) then begin
    start:= source;
   end;
   debugstart:= debugsource;
   parent:= int1;
   if bf_setpc in pb^.flags then begin
    kind:= ck_opmark;
    opmark.address:= opcount;
   end;
  end;
  pb:= pc^.branch;
{$ifdef mse_debugparser}
  if bo1 then begin
   outinfo(info,'^ '+pc^.caption); //push context
  end
  else begin
   outinfo(info,'> '+pc^.caption); //switch context
  end;
{$endif}
 end;
end;
{
var
 pushcontextbranch: branchty =
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: nil; stack: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    ));
}
//   (t:''; x:false; k:false; c:nil; e:false; p:true;
//    s:false; sb:false; sa:false);
{
procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);
begin
 with info^ do begin
  pb:= @pushcontextbranch;
  pushcontextbranch.dest:= cont;
  stophandle:= true;
  pushcont(info);
 end;
end;
}
function parse(const input: string; const acommand: ttextstream;
               const aunit: punitinfoty; out opcode: opinfoarty): boolean;
                              //true if ok
var
 info: parseinfoty;

 procedure popparent;
 var
  int1: integer;
 begin
  with info do begin
   int1:= stackindex;
   stackindex:= contextstack[stackindex].parent;
   if int1 = stackindex then begin
    internalerror(@info,'invalid pop parent');
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
 startopcount: integer;
 
label
 handlelab{,stophandlelab},parseend;
begin

 fillchar(info,sizeof(info),0);
 linebreaks:= 0;
 info.unitinfo:= aunit;
 if info.unitinfo = nil then begin
  info.unitinfo:= newunit('program');
 end;
 opcode:= nil;
 with info do begin
  command:= acommand;
  sourcestart:= pchar(input); //todo: use filecache and include stack
  source.po:= sourcestart;
  if aunit <> nil then begin
   filename:= msefileutils.filename(aunit^.filepath);
  end
  else begin
   filename:= 'main.pas'; //dummy
  end;
  stackdepht:= defaultstackdepht;
  setlength(contextstack,stackdepht);
  with contextstack[0],d do begin
   kind:= ck_none;
   context:= startcontext;
   start:= source;
   parent:= 0;
  end;
  opcount:= startupoffset;
  setlength(ops,opcount);
  initparser(@info);
  startopcount:= opcount;
  pc:= contextstack[stackindex].context;
  keywordindex:= 0;
  debugsource:= source.po;
{$ifdef mse_debugparser}
  outinfo(@info,'****');
{$endif}
  while (source.po^ <> #0) and (stackindex >= 0) do begin
   while (source.po^ <> #0) and (stackindex >= 0) do begin
            //check context branches
    pb:= pc^.branch;
    if pb = nil then begin
     break; //no branch
    end;
    if bf_emptytoken in pb^.flags then begin
     pushcont(@info); //default branch
               //???? why no break or stadard match handling
    end
    else begin
     while pb^.flags <> [] do begin
           //check match
      if bf_keyword in pb^.flags then begin
       if keywordindex = 0 then begin
        po1:= source.po;
        while po1^ in keywordchars do begin
         inc(po1);
        end; 
        if not (po1^ in nokeywordendchars) then begin
         keywordindex:= getident(source.po,po1);
        end
        else begin
         keywordindex:= idstart; //invalid
        end;
        keywordend:= po1;
       end;
       po1:= keywordend;
       bo1:= keywordindex = pb^.keyword;
      end
      else begin
       po1:= source.po;
       linebreaks:= 0;
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
       debugsource:= source.po;
       if bf_eat in pb^.flags then begin
        source.line:= source.line + linebreaks;
        linebreaks:= 0;
        keywordindex:= 0;
        source.po:= po1;
       end;
       if (pb^.dest.context = nil) and (bf_push in pb^.flags) then begin
        break; //terminate current context
       end;
       if (pb^.dest.context <> nil) {and (pb^.dest <> pc)????} then begin
        if bf_handler in pb^.flags then begin
         pb^.dest.handler(@info);
         if stopparser then begin
          goto parseend;
         end;
        end
        else begin
               //switch branch context
         repeat
          if not pushcont(@info) then begin 
                //can not continue
           if stopparser then begin
            goto parseend;
           end;
           goto handlelab;
          end;
         until not (bf_emptytoken in pb^.flags); //no start default branch
        end;
       end;
       source.po:= po1;
       source.line:= source.line + linebreaks;
       debugsource:= source.po;
       keywordindex:= 0;
//       if (pb^.c = nil) and pb^.p then begin
//        break; //terminate
//       end;
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
    if pc^.handle <> nil then begin
         //call context transition handler
//     stophandle:= false;
     pc^.handle(@info);
     if stopparser then begin
      goto parseend;
     end;
         //take context terminate actions
     if pc^.pop then begin
      popparent;
     end;
(*
     if stophandle then begin
{$ifdef mse_debugparser}
      writeln('*** stophandle');
{$endif}
      goto stophandlelab
     end;
*)
    end
    else begin
         //no handler, automatic stack decrement
     if pc^.next = nil then begin
      if pc^.pop then begin
       popparent;
      end
      else begin
       dec(stackindex);
      end;
     end;
    end;
    if pc^.cut then begin
     stacktop:= stackindex;
    end;
    if (stackindex < 0) or stopparser then begin
     goto parseend;
    end;
    pc:= contextstack[stackindex].context;
    if pc1^.popexe then begin
{$ifdef mse_debugparser}
     outinfo(@info,'! after0a');
{$endif}
     goto handlelab;    
    end;
{$ifdef mse_debugparser}
    if not pc1^.continue and (pc^.next = nil) then begin
     outinfo(@info,'! after0b');
    end;
{$endif}
   until pc1^.continue or (pc^.next <> nil);
      //continue with branch checking
   with contextstack[stackindex] do begin
    if pc1^.continue or (returncontext <> nil) then begin
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
     if pc^.nexteat then begin
      start:= source;
     end;
     if pc^.cut then begin
      stacktop:= stackindex;
     end;
{$ifdef mse_debugparser}
     writeln(pc^.caption,'->',pc^.next^.caption);
{$endif}
     pc:= pc^.next;
     context:= pc;
    end;
//    kind:= ck_none;
   end;
{$ifdef mse_debugparser}
   outinfo(@info,'! after1');
{$endif}
  end;
parseend:
{$ifdef mse_debugparser}
  outinfo(@info,'! after2');
{$endif}
  setlength(ops,opcount);
  with pstartupdataty(pointer(ops))^ do begin
   globdatasize:= globdatapo;
  end;
  result:= (errors[erl_fatal] = 0) and (errors[erl_error] = 0);
  if not result or (opcount = startopcount) then begin
   ops:= nil;
  end;
  opcode:= ops;
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

end.
