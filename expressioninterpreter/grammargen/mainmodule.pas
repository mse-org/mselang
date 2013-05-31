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
unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msestrings,msesysenv;

(*
#<comment>
@<tokendef>
 <pascalstring>{,<pascalstring>}
<handler_usesdef>
<context>,[<next>][-],[<handler>][^|!][+][*]
 - -> eat text
 ^ -> pop parent
 ! -> pop parent and execute parent handler
 + -> restore source pointer
 * -> stackindex -> stacktop

 <pascalstring>|@<tokendef>{,pascalstring|@<tokendef>},
                                        [[<context>][-] [[^][*] | [*][^]] [!] ]
 - -> eat token
 <context>^ -> set parent
 <context>* -> push context
 <context>! -> set ck_codemarker
 * -> terminate context
*)

type
 tmainmo = class(tmsedatamodule)
   sysenv: tsysenvmanager;
   procedure eventloopexe(const sender: TObject);
   procedure afterinitexe(sender: tsysenvmanager);
 end;
var
 mainmo: tmainmo;
implementation
uses
 mainmodule_mfm,msefileutils,msestream,msesys,msetypes,msesysutils,sysutils,
 mseformatstr,msearrayutils;
 
type
 paramty = (pa_grammarfile,pa_pasfile);

//lines starting with '#' are comments
//first non comment line is uses clause
//
//contextdef=
//context,next,handler
// 'branch',destcontext
// ...
var testvar: char;
procedure creategrammar(const grammar,outfile: filenamety);
type
 contextinfoty = record
  cont: stringarty;
  bran: stringararty;
 end;
 contextinfoarty = array of contextinfoty;
 tokendefty = record
  name: string;
  tokens: stringarty;
 end;
 tokendefarty = array of tokendefty;
 
var
 grammarstream: ttextstream = nil;
 passtream: ttextstream = nil;
 str1: string;
 firstrow: boolean = true;
 usesdef: string;
 context: string;
 contextline: stringarty;
 branches: stringararty;
 line: integer;
 branchcount: integer;
 contexts: contextinfoarty;
 tokendefs: tokendefarty;
 intokendef: boolean;

 procedure error(const text: string);
 begin
  exitcode:= 1;
//  application.terminated:= true;
  writestderr('***ERROR*** '+text+ ' line '+inttostr(line)+lineend+str1,true);
 end;
 
 function gettokendef(const aname: string; const acontext: string): boolean;
 var
  int1,int2,int3: integer;
  ar1: stringarty;
 begin
  result:= true;
  int2:= -1;
  for int1:= 0 to high(tokendefs) do begin
   if tokendefs[int1].name = aname then begin
    int2:= int1;
    break;
   end;
  end;
  if int2 < 0 then begin
   error('Tokendef not found.');
   result:= false;
   exit;
  end;
  if intokendef then begin
   with tokendefs[int2] do begin
    int3:= high(tokendefs[high(tokendefs)].tokens);
    setlength(tokendefs[high(tokendefs)].tokens,int3+length(tokens)+1);
    for int1:= 0 to high(tokens) do begin
     inc(int3);
     tokendefs[high(tokendefs)].tokens[int3]:= tokens[int1];
    end;
   end;
  end
  else begin
   with tokendefs[int2] do begin
    for int1:= 0 to high(tokens) do begin
     setlength(ar1,2);
     ar1[1]:= acontext;
     ar1[0]:= tokens[int1];
     additem(branches,ar1,branchcount);
    end;
   end;
  end;
 end;

 procedure handlecontext;
 begin
  setlength(branches,branchcount);
  setlength(contexts,high(contexts)+2);
  with contexts[high(contexts)] do begin
   cont:= contextline;
   bran:= branches;
  end;
 end;
const
 branchformat = 
  'Format of branch is "''string''[.],{''string''[.],}context[-][[^][*] | [*][^]]"';
 defaultflags = ' e:false; p:false; s: false; sb:false; sa: false';
var
 ar1: stringarty;
// mstr1: msestring;
 str2,str3: string;
 int1,int2: integer;
 po1,po2,po3: pchar;
 setbefore,setafter: boolean;
 identchars: array[char] of boolean;
begin
 application.terminated:= true;
 try
  grammarstream:= ttextstream.create(grammar,fm_read);
  line:= 0;
  branchcount:= 0;
  context:= '';
  intokendef:= false;
  tokendefs:= nil;
  repeat
   grammarstream.readln(str1);
   inc(line);
   if (str1 <> '') then begin
    if str1[1] = '@' then begin
     setlength(tokendefs,high(tokendefs)+2);
     with tokendefs[high(tokendefs)] do begin
      name:= trim(copy(str1,2,bigint));
     end;
     intokendef:= true;
    end
    else begin
     if (str1[1] <> '#') then begin
      if str1[1] <> ' ' then begin
       intokendef:= false;
      end;
      if intokendef then begin
       po1:= @str1[2];
       with tokendefs[high(tokendefs)] do begin
        while true do begin
         po3:= po1;
         if po1^= '@' then begin
          inc(po3);
          while not (po1^ in [',',#0]) do begin
           inc(po1)
          end;
          if not gettokendef(psubstr(po3,po1),'') then begin
           exit;
          end;
         end
         else begin
          getpascalstring(po1);
          if po1 = po3 then begin
           error('Invalid string');
           exit;
          end;
          setlength(tokens,high(tokens)+2);
          setstring(tokens[high(tokens)],po3,po1-po3);
         end;
         if po1^ = #0 then begin
          break;
         end;
         if po1^ <> ',' then begin
          error('Format of tokendef is "''string''{,''string''}"');
          exit;
         end;
         inc(po1);
        end;
       end;
      end
      else begin
       if firstrow then begin
        usesdef:= str1;
        firstrow:= false;
       end
       else begin
        if str1[1] <> ' ' then begin
         if context <> '' then begin
          handlecontext;
         end;
         context:= str1;
         contextline:= splitstring(context,',',true);
         if length(contextline) <> 3 then begin
          error('Format of contextline is "context,next[-],handler[^|!]"');
          exit;
         end;
         branchcount:= 0;
         branches:= nil;
        end
        else begin
         int1:= findlastchar(str1,',');
         if int1 = 0 then begin
          error(branchformat);
          exit;
         end;
         str2:= trim(copy(str1,int1+1,bigint));
         po1:= pchar(str1)+1;
         po2:= po1+int1-2;
         while true do begin
          po3:= po1;
          if po1^ = '@' then begin
           inc(po3);
           while po1^ <> ',' do begin
            inc(po1);
           end;
//           setstring(str3,po3,po1-po3);
           if not gettokendef(psubstr(po3,po1),str2) then begin
            exit;
           end;
          end
          else begin
           getpascalstring(po1);
           if po1 = po3 then begin
            error('Invalid string');
            exit;
           end;
           if po1^ = '.' then begin
            inc(po1);
           end;
           setstring(str3,po3,po1-po3);
           setlength(ar1,2);
           ar1[0]:= trim(str3);
           ar1[1]:= str2;
           additem(branches,ar1,branchcount);
          end;
          if po1 = po2 then begin
           break;
          end;
          if po1^ <> ',' then begin
           error(branchformat);
           exit;
          end;
          inc(po1);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  until grammarstream.eof;
  if context = '' then begin
   error('Context definition expected');
   exit;
  end;
  handlecontext;
  passtream:= ttextstream.create(outfile,fm_create);
 str1:= 
'{ MSEide Copyright (c) 2013 by Martin Schreiber'+lineend+
'   '+lineend+
'    This program is free software; you can redistribute it and/or modify'+lineend+
'    it under the terms of the GNU General Public License as published by'+lineend+
'    the Free Software Foundation; either version 2 of the License, or'+lineend+
'    (at your option) any later version.'+lineend+
''+lineend+
'    This program is distributed in the hope that it will be useful,'+lineend+
'    but WITHOUT ANY WARRANTY; without even the implied warranty of'+lineend+
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the'+lineend+
'    GNU General Public License for more details.'+lineend+
''+lineend+
'    You should have received a copy of the GNU General Public License'+lineend+
'    along with this program; if not, write to the Free Software'+lineend+
'    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.'+lineend+
'}'+lineend+
'unit '+filenamebase(outfile)+';'+lineend+
'{$ifdef FPC}{$mode objfpc}{$h+}{$endif}'+lineend+
'interface'+lineend+
'uses'+lineend+
' mseparserglob;'+lineend+
' '+lineend+
'function startcontext: pcontextty;'+lineend+
''+lineend;
 for int1:= 0 to high(tokendefs) do begin
  with tokendefs[int1] do begin
   if name = '' then begin
    fillchar(identchars,sizeof(identchars),0);
    for int2:= 0 to high(tokens) do begin
     if tokens[int2] <> '' then begin
      str2:= pascalstringtostring(tokens[int2]);
      if str1 <> '' then begin      
       identchars[str2[1]]:= true;
      end;
     end;
    end;   
    str1:= str1+
'const'+lineend+
' identchars: array[char] of boolean = (';
    for int2:= 0 to 255 do begin
     if int2 mod 8 = 0 then begin
      str1:= str1 + lineend + '  ';
     end;
     if identchars[char(byte(int2))] then begin
      str1:= str1+'true,';
     end
     else begin
      str1:= str1+'false,';
     end;
    end;
    setlength(str1,length(str1)-1);
    str1:= str1+');'+lineend+lineend;
    break;
   end;
  end;
 end;
 str1:= str1+
'var'+lineend;
  for int1:= 0 to high(contexts) do begin
   with contexts[int1] do begin
    if (cont[2] <> '') and (cont[2][length(cont[2])] = '*') then begin
     setlength(cont[2],length(cont[2])-1);
     str2:= 'cut: true; ';
    end
    else begin
     str2:= 'cut: false; ';
    end;
    if (cont[2] <> '') and (cont[2][length(cont[2])] = '+') then begin
     setlength(cont[2],length(cont[2])-1);
     str2:= str2+'restoresource: true; ';
    end
    else begin
     str2:= str2+'restoresource: false; ';
    end;
    if (cont[2] <> '') and (cont[2][length(cont[2])] = '^') then begin
     setlength(cont[2],length(cont[2])-1);
     str2:= str2+'pop: true; popexe: false; ';
    end
    else begin
     if (cont[2] <> '') and (cont[2][length(cont[2])] = '!') then begin
      setlength(cont[2],length(cont[2])-1);
      str2:= str2+'pop: true; popexe: true; ';
     end
     else begin
      str2:= str2+'pop: false; popexe: false; ';
     end;
    end;
    if (cont[1] <> '') and (cont[1][length(cont[1])] = '-') then begin
     setlength(cont[1],length(cont[1])-1);
     str2:= str2+'nexteat: true; ';
    end
    else begin
     str2:= str2+'nexteat: false; ';
    end;
    str1:= str1+
' '+cont[0]+'co: contextty = (branch: nil; handle: nil; '+lineend+
'               '+str2+'next: nil;'+lineend+
'               caption: '''+cont[0]+''');'+lineend;
   end;
  end;
  str1:= str1+
lineend+
'implementation'+lineend+
''+lineend+
'uses'+lineend+
' '+usesdef+';'+lineend+
' '+lineend+
'const'+lineend;
  for int1:= 0 to high(contexts) do begin
   with contexts[int1] do begin
    if bran <> nil then begin
     str1:= str1+
' b'+cont[0]+': array[0..'+inttostr(high(bran)+1)+'] of branchty = ('+lineend;
     for int2:= 0 to high(bran) do begin
           if bran[int2][0][length(bran[int2][0])] = '.' then begin
       setlength(bran[int2][0],length(bran[int2][0])-1);
       str2:= '; k:true';
      end
      else begin
       str2:= '; k:false';
      end;
      str1:= str1+
'  (t:'+bran[int2][0]+str2+'; c:';
      if bran[int2][1] <> '' then begin
       str2:= bran[int2][1];
       setbefore:= false;
       setafter:= false;
       if (str2 <> '') and (str2[length(str2)] = '!') then begin
        setlength(str2,length(str2)-1);
        str3:= '; s: true';
       end
       else begin
        str3:= '; s: false';
       end;
       if (str2 <> '') and (str2[length(str2)] = '^') then begin
        setbefore:= true;
        setlength(str2,length(str2)-1);
       end;
       if (str2 <> '') and (str2[length(str2)] = '*') then begin
        setafter:= setbefore;
        setbefore:= false;
        str3:= '; p:true'+str3;
        setlength(str2,length(str2)-1);
        if (str2 <> '') and (str2[length(str2)] = '^') then begin
         setbefore:= true;
         setlength(str2,length(str2)-1);
        end;
       end
       else begin
        str3:= '; p:false'+str3;
       end;
       if setbefore then begin
        str3:= str3+'; sb:true; sa:false';
       end
       else begin
        if setafter then begin
         str3:= str3+'; sb:false; sa:true';
        end
        else begin
         str3:= str3+'; sb:false; sa:false';
        end;
       end;

       if (str2 <> '') and (str2[length(str2)] = '-') then begin
        str3:= '; e:true'+str3;
        setlength(str2,length(str2)-1);
       end
       else begin
        str3:= '; e:false'+str3;
       end;
       if str2 <> '' then begin
        str1:= str1+'@'+str2+'co'+str3+'),';
       end
       else begin
        str1:= str1+'nil'+str3+'),';
       end;
      end
      else begin
       str1:= str1+'nil;'+defaultflags+'),';
      end;
      str1:= str1+lineend;
     end;
     str1:= str1+
'  (t:''''; k:false; c:nil;'+defaultflags+')'+lineend+
' );'+lineend+
''+lineend;
    end;
   end;
  end;
  str1:= str1+
'procedure init;'+lineend+
'begin'+lineend;
  for int1:= 0 to high(contexts) do begin
   with contexts[int1] do begin
    str1:= str1+
' '+cont[0]+'co.branch:= ';
    if bran = nil then begin
     str1:= str1+'nil;'+lineend;
    end
    else begin
     str1:= str1+'@b'+cont[0]+';'+lineend;
    end;
    if cont[1] <> '' then begin
     str1:= str1+
' '+cont[0]+'co.next:= @'+cont[1]+'co;'+lineend;
    end;
    if cont[2] <> '' then begin
     str1:= str1+
' '+cont[0]+'co.handle:= @'+cont[2]+';'+lineend;
    end;
   end;
  end;
  str1:= str1 +
'end;'+lineend;
  str1:= str1+lineend+
'function startcontext: pcontextty;'+lineend+
'begin'+lineend+
' result:= @'+contexts[0].cont[0]+'co;'+lineend+
'end;'+lineend+
''+lineend+
'initialization'+lineend+
' init;'+lineend+
'end.'+lineend+
lineend;

  passtream.write(str1);
 finally
  grammarstream.free;
  passtream.free;
 end;
end;

procedure tmainmo.eventloopexe(const sender: TObject);
begin
 with sysenv do begin
  creategrammar(value[ord(pa_grammarfile)],value[ord(pa_pasfile)]);
 end;
end;

procedure tmainmo.afterinitexe(sender: tsysenvmanager);
begin
{
 with sender do begin
  if not defined[ord(pa_pasfile)] then begin
   value[ord(pa_pasfile)]:= replacefileext(value[ord(pa_grammarfile)],'pas');
  end;
 end;
}
end;

end.
