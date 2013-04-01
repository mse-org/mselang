unit mseexpint;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msestream,msestackops,mseparserglob;

//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//

//type
 
function parse(const input: string; const acommand: ttextstream): opinfoarty;

implementation
uses
 typinfo,grammar,{msegrammar,}msehandler;
  
//procedure handledecnum(const info: pparseinfoty); forward;
//procedure handlefrac(const info: pparseinfoty); forward;


procedure outinfo(const info: pparseinfoty; const text: string);
var
 int1: integer;
begin
 with info^ do begin
  writeln('**',text,' T:',stacktop,' I:',stackindex,' ''',source,'''');
  for int1:= stacktop downto 0 do begin
   write(int1);
   if int1 = stackindex then begin
    write('*');
   end
   else begin
    write(' ');
   end;
   with contextstack[int1] do begin
    write(getenumname(typeinfo(kind),ord(kind)),' ');
    case kind of
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
    writeln(' ''',start,'''');
   end;
  end;
 end;
end;


//
// todo: optimize, this is a proof of concept only
//

function parse(const input: string; const acommand: ttextstream): opinfoarty;
var
 pb: pbranchty;
 pc: pcontextty;
 info: parseinfoty;

 function pushcontext: boolean;
 begin
  result:= true;
  with info do begin
   pc:= pb^.c;
   if pc^.branch = nil then begin
    pc^.handle(@info);
    pc:= pc^.next;
   end
   else begin
    inc(stacktop);
    stackindex:= stacktop;
    if stacktop = stackdepht then begin
     result:= false;
     exit;
    end;
    with contextstack[stacktop] do begin
     kind:= ck_none;
     context:= pb^.c;
     start:= source;
    end;
   end;
   pb:= pc^.branch;
  end;
  outinfo(@info,'push');
 end;

var
 po1,po2: pchar; 
begin
 result:= nil;
 with info do begin
  command:= acommand;
  source:= pchar(input);
  with contextstack[0] do begin
   kind:= ck_none;
   context:= startcontext;
   start:= source;
  end;
  stackindex:= 0;
  stacktop:= 0;
  opcount:= 0;
  pc:= contextstack[stackindex].context;
  while source^ <> #0 do begin
   while source^ <> #0 do begin
    pb:= pc^.branch;
    if pointer(pb^.t) = nil then begin
     if not pushcontext then begin
      exit;
     end;
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
      if po2^ = #0 then begin
       if (pb^.c <> nil) and (pb^.c <> pc) then begin
        repeat
         if not pushcontext then begin
          exit
         end;
        until pointer(pb^.t) <> nil;
       end;
       source:= po1;
//       pb:= pc^.branch;
       continue;
      end;
      inc(pb);
     end;  
     break;
    end;
 //   inc(source);
   end;
   writeln('***');
   repeat
    pc^.handle(@info);
    pc:= contextstack[stackindex].context;
    if pc^.next = nil then begin
     outinfo(@info,'after0');
    end;
   until pc^.next <> nil;
   pc:= pc^.next;
   with contextstack[stackindex] do begin
    context:= pc;
//    kind:= ck_none;
   end;
   outinfo(@info,'after1');
  end;
  while stackindex > 0 do begin
   contextstack[stackindex].context^.handle(@info);
   outinfo(@info,'after2');
  end;
  contextstack[0].context^.handle(@info);
  with contextstack[0] do begin
   case kind of
    ck_int32const: begin
     push(@info,real(int32const.value));
    end;   
    ck_flo64const: begin
     push(@info,flo64const.value);
    end;
    ck_int32fact: begin
     int32toflo64(@info,0);
    end;
   end;
  end;   
  outinfo(@info,'after3');
  setlength(ops,opcount);
  result:= ops;
 end;
end;

end.
