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
 typinfo,grammar,{msegrammar,}msehandler,mseelements,msestrings,sysutils;
  
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
  writeln('  ',text,' T:',stacktop,' I:',stackindex,' O:',opcount,' ''',
                                             singleline(source),'''');
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
     ck_opmark: begin
      write(opmark.address,' ');
     end;
    end;
    writeln(' ''',singleline(start),'''');
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
  pc:= pb^.c;
  while pc^.branch = nil do begin
   if pc^.next = nil then begin
    result:= false;
    break;
   end;
   pc^.handle(info); //transition handler
   pc:= pc^.next;
  end;
  int1:= contextstack[stackindex].parent;
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
   if pb^.s then begin
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
   (t:''; x:false; k:false; c:nil; e:false; p:true;
    s:false; sb:false; sa:false);

procedure pushcontext(const info: pparseinfoty; const cont: pcontextty);
begin
 with info^ do begin
  pb:= @pushcontextbranch;
  pushcontextbranch.c:= cont;
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
 
label
 handlelab,stophandlelab,parseend;
begin
 result:= nil;
 mseelements.clear;
 
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
  initparser(@info);
  pc:= contextstack[stackindex].context;
  while (source^ <> #0) and (stackindex >= 0) do begin
   while (source^ <> #0) and (stackindex >= 0) do begin
    pb:= pc^.branch;
    if pb = nil then begin
     break;
    end;
//    if pb^.x then begin 
    if pointer(pb^.t) = nil then begin
     pushcont(@info);
    end
    else begin
     keywordindex:= 0;
     while not pb^.x do begin
//     while pointer(pb^.t) <> nil do begin
      if pb^.k then begin
       if keywordindex = 0 then begin
        po1:= source;
        while po1^ in ['a'..'z','A'..'Z'] do begin
         inc(po1);
        end; 
        keywordindex:= getident(source,po1);
        keywordend:= po1;
       end;
       po1:= keywordend;
       bo1:= keywordindex = byte(pb^.t[1]);
      end
      else begin
       po1:= source;
       po2:= pointer(pb^.t);
       if po2 = nil then begin
        inc(po1);
        bo1:= true;
       end
       else begin
        while po1^ = po2^ do begin
         inc(po1);
         inc(po2);
         if po1^ = #0 then begin
          break;
         end;
        end;
        bo1:= po2^ = #0;
       end;
      end;
      if bo1 then begin //match
       if pb^.e then begin
        source:= po1;
       end;
       if (pb^.c <> nil) and (pb^.c <> pc) then begin
        repeat
         if not pushcont(@info) then begin
          goto handlelab;
         end;
//        until not pb^.x;
        until pointer(pb^.t) <> nil;
       end;
       source:= po1;
       keywordindex:= 0;
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
    if pc^.next = nil then begin
     outinfo(@info,'! after0b');
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
stophandlelab:
   outinfo(@info,'! after1');
  end;
parseend:
  outinfo(@info,'! after2');
  setlength(ops,opcount);
  with pstartupdataty(pointer(ops))^ do begin
   globdatasize:= globdatapo;
  end;
  result:= ops;
 end;
end;

end.
