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
 msetypes,msestream,msestackops,mseparserglob;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

//type

const
 keywordchars = ['a'..'z','A'..'Z'];
 nokeywordendchars = keywordchars+['0'..'9','_'];
 
function parse(const input: string; const acommand: ttextstream): opinfoarty;
procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);

procedure init;
procedure deinit;

implementation
uses
 typinfo,grammar,{msegrammar,}msehandler,mseelements,msestrings,sysutils,
 msebits,unithandler;
  
//procedure handledecnum(const info: pparseinfoty); forward;
//procedure handlefrac(const info: pparseinfoty); forward;

//
//todo: move context-end flag handling to handler procedures.
//

procedure init;
begin
 unithandler.init;
end;

procedure deinit;
begin
 unithandler.deinit;
end;

procedure outinfo(const info: pparseinfoty; const text: string);
var
 int1: integer;
begin
 with info^ do begin
  writeln('  ',text,' T:',stacktop,' I:',stackindex,' O:',opcount,' '+
    inttostr(source.line+1)+':''',psubstr(debugsource,source.po)+''','''+
                         singleline(source.po),'''');
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
      write(ident.ident,':',ident.len);
      if ident.continued then begin
       write('c ');
      end
      else begin
       write('  ');
      end;
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
    writeln(' '+inttostr(start.line+1)+':''',psubstr(debugstart,start.po),''',''',
                     singleline(start.po),'''');
   end;
  end;
 end;
end;


//
// todo: optimize, this is a proof of concept only
//

procedure internalerror(const info: pparseinfoty; const atext: string);
begin
 writeln('*INTERNAL ERROR* ',atext);
 outinfo(info,'');
 abort;
end;

function pushcont(const info: pparseinfoty): boolean;
var
 int1: integer;
 bo1: boolean;
begin
 result:= true;
 bo1:= false;
 with info^ do begin
  pc:= pb^.dest;
  while pc^.branch = nil do begin
   if pc^.next = nil then begin
    result:= false;
    break;
   end;
   pc^.handle(info); //transition handler
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
  with contextstack[stackindex],d do begin
   if bf_push in pb^.flags then begin
    kind:= ck_none;
   end;
   context:= pc;
   start:= source;
   debugstart:= debugsource;
   parent:= int1;
   if bf_setpc in pb^.flags then begin
    kind:= ck_opmark;
    opmark.address:= opcount;
   end;
  end;
  pb:= pc^.branch;
  if bo1 then begin
   outinfo(info,'^ '+pc^.caption);
  end
  else begin
   outinfo(info,'> '+pc^.caption);
  end;
 end;
end;

var
 pushcontextbranch: branchty =
   (flags: [bf_nt,bf_emptytoken,bf_push]; dest: nil; keys: (
    (kind: bkk_char; chars: [#1..#255]),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    ));

//   (t:''; x:false; k:false; c:nil; e:false; p:true;
//    s:false; sb:false; sa:false);

procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);
begin
 with info^ do begin
  pb:= @pushcontextbranch;
  pushcontextbranch.dest:= cont;
  stophandle:= true;
  pushcont(info);
 end;
end;

function parse(const input: string; const acommand: ttextstream): opinfoarty;
var
// pb: pbranchty;
// pc: pcontextty;
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
 handlelab,stophandlelab,parseend;
begin

 fillchar(info,sizeof(info),0); 
 result:= nil;
 mseelements.clear;
 with info do begin
  command:= acommand;
  sourcestart:= pchar(input); //todo: use filecache and include stack
  source.po:= sourcestart;
//  source.line:= 0;
  filename:= 'main.pas'; //dummy
//  fillchar(errors,sizeof(errors),0);
  stackdepht:= defaultstackdepht;
  setlength(contextstack,stackdepht);
  with contextstack[0],d do begin
   kind:= ck_none;
   context:= startcontext;
   start:= source;
   parent:= 0;
  end;
//  stackindex:= 0;
//  stacktop:= 0;
  opcount:= startupoffset;
  setlength(ops,opcount);
//  globdatapo:= 0;
  initparser(@info);
  startopcount:= opcount;
  pc:= contextstack[stackindex].context;
  keywordindex:= 0;
  debugsource:= source.po;
  outinfo(@info,'****');
  while (source.po^ <> #0) and (stackindex >= 0) do begin
   while (source.po^ <> #0) and (stackindex >= 0) do begin
    pb:= pc^.branch;
    if pb = nil then begin
     break;
    end;
    if bf_emptytoken in pb^.flags then begin
     pushcont(@info);
    end
    else begin
//     keywordindex:= 0;
     while pb^.flags <> [] do begin
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
         keywordindex:= -1;
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
       if (pb^.dest = nil) and (bf_push in pb^.flags) then begin
        break; //terminate
       end;
       if (pb^.dest <> nil) and (pb^.dest <> pc) then begin
        repeat
         if not pushcont(@info) then begin
          goto handlelab;
         end;
        until not (bf_emptytoken in pb^.flags);
       end;
       source.po:= po1;
       source.line:= source.line + linebreaks;
       debugsource:= source.po;
       keywordindex:= 0;
//       if (pb^.c = nil) and pb^.p then begin
//        break; //terminate
//       end;
       pb:= pc^.branch; //restart
       continue;
      end;
      inc(pb);
     end;  
     break;
    end;
   end;
handlelab:
   writeln('***');
   repeat
    pc1:= pc;
    if pc1^.restoresource then begin
     source:= contextstack[stackindex].start;
     debugsource:= source.po;
     keywordindex:= 0;
    end;
    if pc^.handle <> nil then begin
     stophandle:= false;
     pc^.handle(@info);
     if stophandle then begin
      writeln('*** stophandle');
      goto stophandlelab
     end;
     if pc^.pop then begin
      popparent;
     end;
    end
    else begin
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
    if stackindex < 0 then begin
     goto parseend;
    end;
    pc:= contextstack[stackindex].context;
    if pc1^.popexe then begin
     outinfo(@info,'! after0a');
     goto handlelab;    
    end;
    if not pc1^.continue and (pc^.next = nil) then begin
     outinfo(@info,'! after0b');
    end;
   until pc1^.continue or (pc^.next <> nil);
   with contextstack[stackindex] do begin
    if pc1^.continue then begin
     writeln(pc1^.caption,'.>',pc^.caption);
    end
    else begin
     if pc^.nexteat then begin
      start:= source;
     end;
     if pc^.cut then begin
      stacktop:= stackindex;
     end;
     writeln(pc^.caption,'->',pc^.next^.caption);
     pc:= pc^.next;
     context:= pc;
    end;
//    kind:= ck_none;
   end;
stophandlelab:
   outinfo(@info,'! after1');
  end;
parseend:
  outinfo(@info,'! after2');
  setlength(ops,opcount);
  with pstartupdataty(pointer(ops))^ do begin
   globdatasize:= globdatapo;
  end;
  if (errors[erl_fatal] > 0) or (errors[erl_error] > 0) or 
                 (opcount = startopcount) then begin
   ops:= nil;
  end;
  result:= ops;
 end;
 
end;

end.
