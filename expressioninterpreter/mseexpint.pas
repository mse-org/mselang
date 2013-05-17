unit mseexpint;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 msetypes,msestream,msestackops,mseparserglob;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

//type
 
function parse(const input: string; const acommand: ttextstream): opinfoarty;
procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);

implementation
uses
 typinfo,grammar,{msegrammar,}msehandler,mseelements,msestrings;
  
//procedure handledecnum(const info: pparseinfoty); forward;
//procedure handlefrac(const info: pparseinfoty); forward;

//
//todo: move context-end flag handling to handler procedures.
//

procedure outinfo(const info: pparseinfoty; const text: string);
var
 int1: integer;
begin
 with info^ do begin
  writeln('**',text,' T:',stacktop,' I:',stackindex,' ''',
                                             singleline(source),'''');
  for int1:= stacktop downto 0 do begin
   write(int1);
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
    write(parent,' ');
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
    write(getenumname(typeinfo(kind),ord(kind)),' ');
    case kind of
     ck_ident: begin
      write(ident,' ');
     end;
     ck_bool8const: begin
      write(bool8const.value,' ');
     end;
     ck_int32const: begin
      write(int32const.value,' ');
     end;
     ck_flo64const: begin
      write(flo64const.value,' ');
     end;
    end;
    if context <> nil then begin
     write(context^.caption);
    end
    else begin
     write('NIL');
    end;
    writeln(' ''',singleline(start),'''');
   end;
  end;
 end;
end;


//
// todo: optimize, this is a proof of concept only
//

procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);
var
 int1: integer;
begin
 with info^ do begin
  int1:= contextstack[stacktop].parent;
  inc(stacktop);
  stackindex:= stacktop;
  if stacktop = stackdepht then begin
   stackdepht:= 2*stackdepht;
   setlength(contextstack,stackdepht);
  end;
  with contextstack[stackindex],d do begin
   kind:= ck_none;
   context:= cont;
   start:= source;
   parent:= int1;
  end;
 end;
 outinfo(info,'pusha');
end;

function parse(const input: string; const acommand: ttextstream): opinfoarty;
var
 pb: pbranchty;
 pc: pcontextty;
 info: parseinfoty;

 function pushcont: boolean;
 var
  int1: integer;
  bo1: boolean;
 begin
  result:= true;
  bo1:= false;
  with info do begin
   pc:= pb^.c;
   while pc^.branch = nil do begin
    if pc^.next = nil then begin
     result:= false;
     break;
    end;
    pc^.handle(@info); //transition handler
    pc:= pc^.next;
   end;
   int1:= contextstack[stacktop].parent;
   if pb^.sb then begin
    int1:= stackindex;
   end;
   if pb^.p then begin
    bo1:= true;
    inc(stacktop);
    stackindex:= stacktop;
    if stacktop = stackdepht then begin
     stackdepht:= 2*stackdepht;
     setlength(contextstack,stackdepht);
    end;
    if pb^.sa then begin
     int1:= stacktop;
    end;
   end;
   with contextstack[stackindex],d do begin
    kind:= ck_none;
    context:= pc;
    start:= source;
    parent:= int1;
   end;
   pb:= pc^.branch;
  end;
  if bo1 then begin
   outinfo(@info,'push');
  end
  else begin
   outinfo(@info,'branch');
  end;
 end;

var
 po1,po2: pchar;
 pc1: pcontextty;
 
label
 handlelab,parseend;
begin
 result:= nil;
 mseelements.clear;
 initparser;
 
 with info do begin
  command:= acommand;
  source:= pchar(input);
  stackdepht:= defaultstackdepht;
  setlength(contextstack,stackdepht);
  with contextstack[0],d do begin
   kind:= ck_none;
   context:= startcontext;
   start:= source;
   parent:= 0;
  end;
  stackindex:= 0;
  stacktop:= 0;
  opcount:= startupoffset;
  setlength(ops,opcount);
  globdatapo:= 0;
  pc:= contextstack[stackindex].context;
  while (source^ <> #0) and (stackindex >= 0) do begin
   while (source^ <> #0) and (stackindex >= 0) do begin
    pb:= pc^.branch;
    if pb = nil then begin
     break;
    end;
    if pointer(pb^.t) = nil then begin
     pushcont;
    end
    else begin
     while pointer(pb^.t) <> nil do begin
      po1:= source;
      po2:= pointer(pb^.t);
      while po1^ = po2^ do begin
       inc(po1);
       inc(po2);
       if po1^ = #0 then begin
        break;
       end;
      end;
      if (po2^ = #0) and (not pb^.k or not identchars[po1^]) then begin //match
       if pb^.e then begin
        source:= po1;
       end;
       if (pb^.c <> nil) and (pb^.c <> pc) then begin
        repeat
         if not pushcont then begin
          goto handlelab;
         end;
        until pointer(pb^.t) <> nil;
       end;
       source:= po1;
       if (pb^.c = nil) and pb^.p then begin
//        stacktop:= stackindex;
        break;
       end;
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
    end;
    if pc^.handle <> nil then begin
     pc^.handle(@info);
     if pc^.pop then begin
      stackindex:= contextstack[stackindex].parent;
     end;
    end
    else begin
     if pc^.next = nil then begin
      if pc^.pop then begin
       stackindex:= contextstack[stackindex].parent;
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
     outinfo(@info,'after0a');
     goto handlelab;    
    end;
    if pc^.next = nil then begin
     outinfo(@info,'after0b');
    end;
   until pc^.next <> nil;
   with contextstack[stackindex] do begin
    if pc^.nexteat then begin
     start:= source;
    end;
    writeln(pc^.caption,'->',pc^.next^.caption);
    pc:= pc^.next;
    context:= pc;
//    kind:= ck_none;
   end;
   outinfo(@info,'after1');
  end;
parseend:
  outinfo(@info,'after2');
  setlength(ops,opcount);
  with pstartupdataty(pointer(ops))^ do begin
   globdatasize:= globdatapo;
  end;
  result:= ops;
 end;
end;

end.
