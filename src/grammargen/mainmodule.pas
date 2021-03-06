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
unit mainmodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msetypes,msesysenv,
 globtypes;

(*
[STATEMENT]'!'COMMENT

'{'MACRONAME'}' '"'MACROTEXT'"' 
 macrotext can be multiline, "" -> "

'{$'DIALECT{','DIALECT'}'
 Conditional for dialects. DIALECT is filename base of output file
'{$}'
 End of conditional
 
'${'MACRONAME'}'
'@'TOKENDEF
 PASCALSTRING {','PASCALSTRING}
'@.handlerunits'
 PASCALSTRING{','PASCALSTRING}
'@.internaltokens'
 PASCALSTRING{','PASCALSTRING}
     first character of strings removed for const def ex:
      '.classes' -> tks_classes
'@.tokens'
 PASCALSTRING{','PASCALSTRING}
     ex:
      '.result' -> tk_result
CONTEXT,[NEXT]['-']','[ENTRYHANDLER]','[EXITHANDLER]
        (['*']['^'|'!']) | (['^'|'!']['*']) ['+']['>']
    ENTRYHANDLER called at contextstart
    EXITHANDLER called by context termination
 '-' -> eat text
 '*' -> stackindex -> stacktop
 '^' -> pop parent, NEXT must be empty
 '!' -> pop parent and execute parent handler, NEXT must be empty
 '+' -> restore source pointer
 '>' -> continue with calling context
 STRINGDEF|'@'TOKENDEF{','STRINGDEF|'@'TOKENDEF}','
        ([CONTEXT] ['+']['-']['+'] [['^']['*'] | ['*']['^']] [ '>']) |
                                                      (['!'[HANDLER]][-][*][^])
        [',' (PUSHEDCONTEXT | (PARENTCONTEXT'^'))]
 '+' -> do not set start source pointer
 '-' -> eat token
 CONTEXT'^' -> set parent
 CONTEXT'*' -> push context
 ['!'[HANDLER]]'*' -> terminate context
 '>' -> continue context after return
STRINGDEF -> PASCALSTRING['.']
 '.' -> keyword
*)

const
 unitheader =
'{ MSElang Copyright (c) 2013-2017 by Martin Schreiber'+lineend+
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
'}'+lineend;

 contextlinesyntax = 
'CONTEXT,[NEXT][''-'']'',''[ENTRYHANDLER]'',''[EXITHANDLER][''^''|''!''][''+''][''*''][''>'']';
 branchlinesyntax = 
'STRINGDEF|''@''TOKENDEF{'',''STRINGDEF|''@''TOKENDEF}'','''+lineend+
'        ([CONTEXT] [''+''][''-''] [[''^''][''*''] | [''*''][''^'']] [ ''>'']) |'+lineend+
'                                                      ([''!''HANDLER][-][*][^])'+lineend+
'        ['','' (PUSHEDCONTEXT | (PARENTCONTEXT''^''))]';

 commentchar = '/';
 quotechar = '''';
 
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
 mainmodule_mfm,msefileutils,msestream,msesys,msesysutils,sysutils,
 mseformatstr,msearrayutils,msemacros,{parserglob,}typinfo,mselfsr,
 msestrings;

const
 numidcount = 256; 
type
 paramty = (pa_grammarfile,pa_pasglobfile,pa_pasfile);

const
 b: array[0..0] of branchty = (
   (flags: []; dest: (context: nil); stack: nil; keys: (
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: []),
    (kind: bkk_none; chars: [])
    )
   )
  );

type
 branchrecty = record
  tokens: stringarty;
  keyword: keywordty;
  dest: string;
  stack: string;
  emptytoken: boolean;
  bline: integer;
 end;
  
 brancharty = array of branchrecty;

function checkident(const avalue: string): boolean;
var
 int1: integer;
begin
 result:= true;
 for int1:= 1 to length(avalue) do begin
  if not (avalue[int1] in ['a'..'z','A'..'Z','0'..'9','_']) then begin
   result:= false;
   break;
  end;
 end;
end;

function checklastchar(var astr: string; const achar: char): boolean;
begin
 result:= (astr <> '') and (astr[length(astr)] = achar);
 if result then begin
  setlength(astr,length(astr)-1);
 end;
end;
 
function comparebranch(const l,r): integer;
begin
 result:= 0;
 with branchrecty(l) do begin
  if emptytoken then begin
   inc(result);
  end;
  if branchrecty(r).emptytoken then begin
   dec(result);
  end;
  if (result = 0) and not emptytoken then begin
   if (keyword = 0) then begin
    inc(result);
   end;
   if (branchrecty(r).keyword = 0) then begin
    dec(result);
   end;
   if (result = 0) and (keyword = 0) then begin
    if length(tokens) = 0 then begin
     inc(result);
    end;
    if length(branchrecty(r).tokens) = 0 then begin
     dec(result);
    end;
    if (result = 0) and (length(tokens) <> 0) then begin
     result:= length(branchrecty(r).tokens[0]) - length(tokens[0]);
    end;
   end;
  end;
 end;
end;

function charsettostring(const aset: charsetty): string;
 function getcharstr(const achar: char): string;
 begin
  if (achar > #$1f) and (achar < #$7f) then begin
   if achar = '''' then begin
    result:= '''''''''';
   end
   else begin
    result:= ''''+achar+'''';
   end;
  end
  else begin
   result:= '#'+inttostr(ord(achar));
  end;
 end; //getcharstr
 
var
 ch1: char;
 last: integer;
begin
 result:= '[';
 last:= -1;
 for ch1:= #0 to #255 do begin
  if ch1 in aset then begin
   if last < 0 then begin
    result:= result+getcharstr(ch1);
    last:= ord(ch1);
   end
   else begin
    if ch1 = #255 then begin
     result:= result+'..#255';
    end;
   end;
  end
  else begin
   if last >= 0 then begin
    if (last <> ord(ch1)-1) then begin
     result:= result+'..'+getcharstr(char(byte(ch1)-1));
    end;
    result:= result+',';
    last:= -1;
   end;
  end;
 end;
 if result[length(result)] = ',' then begin
  setlength(result,length(result)-1);
 end;
 result:= result + ']';
end;

var
 id: uint32;

procedure nextid;
begin
// repeat
 inc(id);
//  lfsr321(id);
// until id >= firstident;
end;

function idstring(const aid: string): string;
begin
 result:= 
' '+aid+' = $'+hextostr(id,8)+';'+lineend;
 nextid;
end;

procedure creategrammar(const grammar,globfile: filenamety;
                                     outfiles: array of filenamety);
type
 contextinfoty = record
  cont: stringarty;
  bran: brancharty;
  li: integer;
 end;
 contextinfoarty = array of contextinfoty;
 tokendefty = record
  name: string;
  tokens: stringarty;
 end;
 tokendefarty = array of tokendefty;
 
var
 grammarstream: ttextstream;
 passtream: ttextstream;
 str1: string;
 usesdef: string;
 internaltokens: stringarty;
 context: string;
 contextline: stringarty;
 contextlinenr: integer;
 branches: brancharty;
 line: integer;
 contexts: contextinfoarty;
 tokendefs: tokendefarty;
 intokendef: boolean;
 keywords: array of string;
 keywordids: array of keywordty;
 dialect: string;

 procedure error(const text: string; aline: integer = -1);
 begin
  if aline < 0 then begin
   aline:= line;
  end;
  exitcode:= 1;
//  application.terminated:= true;
  writestderr('***ERROR '+dialect+' *** line '+inttostr(aline)+lineend+str1+lineend+text,true);
 end;

 procedure readline(var astr: string);
 var
  pe,po1: pchar;
  inquote: boolean;
 begin
  grammarstream.readln(astr);
  astr:= trimright(astr);
  po1:= pointer(astr);
  pe:= po1 + length(astr);
  inquote:= false;
  while po1 < pe do begin
   if (po1^ = quotechar) then begin
    inquote:= not inquote;
   end;
   if (po1^ = commentchar) and ((po1+1)^ = commentchar) and 
                                                   not inquote then begin
    break;
   end;
   inc(po1);
  end;
  setlength(astr,po1-pchar(pointer(astr)));
  inc(line);
 end;
 
 function getkeyword(const atext: string; out keyword: keywordty): boolean;
 var
  int1: integer;
  mstr1: msestring;
  str1: string;
 begin
  result:= true;
  if not trypascalstringtostring(atext,mstr1) then begin
   error('Invalid keyword "'+atext+'".');
   result:= false;
   exit;
  end;
  str1:= ansistring(mstr1);
{
  for int1:= 1 to length(str1) do begin
   if not (str1[int1] in ['a'..'z','A'..'Z']) then begin
    error('Invalid keyword "'+str1+'".');
    result:= false;
    exit;
   end;
  end;
}
  for int1:= 0 to high(keywords) do begin
   if keywords[int1] = str1 then begin
    keyword:= keywordids[int1];
    exit;
   end;
  end;
  setlength(keywords,high(keywords)+2);
  setlength(keywordids,length(keywords));
  keywords[high(keywords)]:= str1;
  keywordids[high(keywordids)]:= id;
  if high(keywords) + high(internaltokens) > 254 then begin
   error('Too many keywords.');
   result:= false;
   exit;
  end;
  keyword:= id;
  nextid;
//  atext:= stringtopascalstring(msechar(high(keywords)+keywordoffset))+
//   '{'+atext+'}';
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
     additem(branches[high(branches)].tokens,tokens[int1]);
//     setlength(ar1,2);
//     ar1[1]:= acontext;
//     ar1[0]:= tokens[int1];
//     additem(branches,ar1,branchcount);
    end;
   end;
  end;
 end;

const
 flagchars = ['^','!','+','*','>'];

 procedure handlecontext;
 begin
  setlength(contexts,high(contexts)+2);
  with contexts[high(contexts)] do begin
   cont:= contextline;
   bran:= copy(branches);
   li:= contextlinenr;
   {
   if (bran = nil) and (cont <> nil) and (cont[high(cont)] <> '') and
       (cont[high(cont)][length(cont[high(cont)])] in flagchars)  then begin
    error('Transition context can not have flags.',li);
   end;
   }
  end;
 end;

const
 contextformat =
 'Format of contextline is'+lineend+'"'+contextlinesyntax+'"';
 branchformat = 
 'Format of branch is'+lineend+'"'+branchlinesyntax+'"';
 defaultflags = ' e:false; p:false; s: false; sb:false; sa: false';
var
 str2,str3,str4,str5: string;
 int1,int2,int3: integer;
 po1,po2,po3: pchar;
 setbefore,setafter: boolean;
// keywordsstart: integer;
 macroname,macrotext: string;
 bo1: boolean;
 macrolist1: tmacrolist = nil;
 expandedtext: stringarty;
 lnr: integer;
 mstr1: msestring;
 branflags1: branchflagsty;
 chars1: charsetty;
 kw1: keywordty;
 outstr: string;
 i1,of1: int32;
 s1: string;
 ar1: stringarty;
 conditionlevel: int32;
 disablelevel: int32;
 disabled: boolean;
const
 contlast = 3; 
begin
 internaltokens:= nil; //compiler warning
 application.terminated:= true;
 grammarstream:= nil;
 try
  id:= idstart; //invalid
  nextid;
  for i1:= 0 to numidcount -1 do begin //numidents
   nextid();
  end;

  grammarstream:= ttextstream.create(grammar,fm_read);
  macrolist1:= tmacrolist.create([mao_curlybraceonly]);
  for of1:= 0 to high(outfiles) do begin
   passtream:= nil;
   dialect:= ansistring(filenamebase(outfiles[of1]));
   conditionlevel:= 0;
   disablelevel:= 0;
   disabled:= false;
   tokendefs:= nil;
   contexts:= nil;
   grammarstream.position:= 0;
   macrolist1.clear;
   line:= 0;
   context:= '';
   intokendef:= false;
   usesdef:= '';
 
   repeat
    readline(str1);
    if (str1 <> '') then begin
     if (str1[1] = '{') and (str1[2] <> '$') then begin //macrodef
      int1:= findchar(str1,'}');
      if int1 = 0 then begin
       error('Invalid macrodef');
       exit;
      end;
(*
      if str1[2] = '$' then begin
       if str1[3] = '}' then begin
        dec(conditionlevel);
        if conditionlevel < 0 then begin
         error('Invalid condition level');
         exit;
        end;
        if conditionlevel < disablelevel then begin
         disabled:= false;
        end;
       end
       else begin
        inc(conditionlevel);
        ar1:= splitstring(copy(str1,3,length(str1)-3),',',true);
        bo1:= false;
        for i1:= 0 to high(ar1) do begin
         if ar1[i1] = dialect then begin
          bo1:= true;
          break;
         end;
        end;
        if not bo1 and not disabled then begin
         disablelevel:= conditionlevel;
         disabled:= true;
        end;
       end;
      end
      else begin
*)
       if disabled then begin
        continue;
       end;
       macroname:= copy(str1,2,int1-2);
       int2:= findchar(str1,'"');
       if (int2 > 0) and (int2 < int1) then begin
        error('Ivalid macro name.');
        exit;
       end;
       if int2 = 0 then begin
        if grammarstream.eof then begin
         str2:= '';
        end
        else begin
         readline(str2);
         int2:= findchar(str2,'"');
         if int2 = 0 then begin
          error('Invalid macrodef');
          exit;
         end;
        end;
       end
       else begin
        str2:= str1;
       end;
       str2:= copy(str2,int2+1,bigint);
       macrotext:= '';
       bo1:= false;
       while true do begin
        int1:= 0;
        while true do begin
         int1:= findchar(str2,int1+1,'"');
         if int1 > 0 then begin
          if str2[int1+1] = '"' then begin
           move(str2[int1+1],str2[int1],length(str2)-int1);
           setlength(str2,length(str2)-1);
          end
          else begin
           setlength(str2,int1-1);
           bo1:= true;
           break;
          end;
         end
         else begin
          break;
         end;
        end;
        macrotext:= macrotext+str2;
        if bo1 or grammarstream.eof then begin
         break;
        end;
        macrotext:= macrotext+lineend;
        readline(str2);
       end;
       macrolist1.add([utf8tostringansi(macroname)],
                                          [utf8tostringansi(macrotext)],[]);
//      end; //macrodef
     end
     else begin //no macrodef
{
      if disabled then begin
       continue;
      end;
}
      mstr1:= utf8tostringansi(str1);
      macrolist1.expandmacros1(mstr1);
      if (mstr1 <> '') then begin //no comment
       expandedtext:= breaklines(stringtoutf8(mstr1));
       for lnr:= 0 to high(expandedtext) do begin
        str1:= expandedtext[lnr];
        if str1 <> '' then begin


         if (str1[1] = '{') and (str1[2] = '$') then begin
          if str1[3] = '}' then begin
           dec(conditionlevel);
           if conditionlevel < 0 then begin
            error('Invalid condition level');
            exit;
           end;
           if conditionlevel <= disablelevel then begin
            disabled:= false;
           end;
          end
          else begin
           inc(conditionlevel);
           ar1:= splitstring(copy(str1,3,length(str1)-3),',',true);
           bo1:= false;
           for i1:= 0 to high(ar1) do begin
            if ar1[i1] = dialect then begin
             bo1:= true;
             break;
            end;
           end;
           if not bo1 and not disabled then begin
            disablelevel:= conditionlevel;
            disabled:= true;
           end;
          end;
          continue;
         end;

         if disabled then begin
          continue;
         end;

         if str1[1] = '@' then begin
          setlength(tokendefs,high(tokendefs)+2);
          with tokendefs[high(tokendefs)] do begin
           name:= trim(copy(str1,2,bigint));
          end;
          intokendef:= true;
         end
         else begin
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
              setstring(s1,po3,po1-po3);
              bo1:= true;
              if name = '.internaltokens' then begin
               for i1:= 0 to high(internaltokens) do begin
                if internaltokens[i1] = s1 then begin
                 bo1:= false;
                 break;
                end;
               end;
              end;
              if bo1 then begin
               setlength(tokens,high(tokens)+2);
               setstring(tokens[high(tokens)],po3,po1-po3);
               if name = '.internaltokens' then begin
                nextid;
               end
               else begin
                if name = '.tokens' then begin
                 if not getkeyword(tokens[high(tokens)],kw1) then begin
                  exit;
                 end;
                end;
               end;
              end;
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
           if str1[1] <> ' ' then begin
            if context <> '' then begin
             handlecontext; //new context
            end;
            context:= str1;
            contextline:= splitstring(context,',',true);
            contextlinenr:= line;
            if length(contextline) <> contlast+1 then begin
             error(contextformat);
             exit;
            end;
            branches:= nil;
           end
           else begin
            int1:= findlastchar(str1,',');
            if int1 = 0 then begin
             error(branchformat);
             exit;
            end;
            setlength(branches,high(branches)+2);
            str2:= trim(copy(str1,int1+1,bigint));
            with branches[high(branches)] do begin
             dest:= str2;
            end;
            po1:= pchar(str1)+1;
            po2:= po1+int1-3;
            while po2 > po1 do begin
             if po2^ = ',' then begin
              with branches[high(branches)] do begin
               stack:= dest;
               setstring(dest,po2+1,int1-(po2-po1)-3);
               dest:= trim(dest);
               int1:= (po2-po1)+2;
              end;
              break;
             end;
             if po2^ in ['''','@'] then begin
              break;
             end;
             dec(po2);
            end;
            
            po2:= po1+int1-2;
            while true do begin
             po3:= po1;
             if po1^ = '@' then begin
              inc(po3);
              while po1^ <> ',' do begin
               inc(po1);
              end;
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
              additem(branches[high(branches)].tokens,str3);
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
            with branches[high(branches)] do begin
             bline:= line;
             for int1:= 0 to high(tokens) do begin
              if (tokens[int1] = '''''') then begin
               if (length(tokens) > 1) then begin
                error(branchformat);
                exit;
               end;
               emptytoken:= true;
               tokens[int1]:= '';
              end
              else begin
               if tokens[int1][length(tokens[int1])] = '.' then begin
                if keyword > 0 then begin
                 error(branchformat);
                 exit;
                end;
                setlength(tokens[int1],length(tokens[int1])-1);
                if not getkeyword(tokens[int1],keyword) then begin
                 exit;
                end;
               end
               else begin
                po1:= pchar(tokens[int1]);
                tokens[int1]:= ansistring(getpascalstring(po1));
                if length(tokens[int1]) > 1 then begin
                 if high(tokens) > 0 then begin
                  error(branchformat);
                  exit;
                 end;
                end;
                if length(tokens[int1]) > branchkeymaxcount then begin
                 error(branchformat);
                 exit;
                end;
               end;
              end;
             end;
            end;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   until grammarstream.eof;
   if conditionlevel <> 0 then begin
    error('Missing "{$}"');
    exit;
   end;
   if context = '' then begin
    error('Context definition expected');
    exit;
   end;
   handlecontext;
   for int1:= 0 to high(tokendefs) do begin
    with tokendefs[int1] do begin
     if name = '.handlerunits' then begin
      for int2:= 0 to high(tokens) do begin
       usesdef:= usesdef+ansistring(pascalstringtostring(tokens[int2]))+',';
      end;
      if tokens <> nil then begin
       setlength(usesdef,length(usesdef)-1);
      end;
     end;
     if name = '.internaltokens' then begin
      for int2:= 0 to high(tokens) do begin
       additem(internaltokens,tokens[int2]);
      end;
     end;
    end;
   end;
 
   passtream:= ttextstream.create(outfiles[of1],fm_create);
   str1:= ''; //for error message
  outstr:= unitheader+
 'unit '+ansistring(filenamebase(outfiles[of1]))+';'+lineend+
 '{$ifdef FPC}{$mode objfpc}{$h+}{$endif}'+lineend+
 'interface'+lineend+
 'uses'+lineend+
 ' globtypes,parserglob,elements;'+lineend+
 ' '+lineend+
 'function startcontext: pcontextty;'+lineend+
 ''+lineend+
 {
 'implementation'+lineend+
 'uses'+lineend+
 ' '+usesdef+';'+lineend;
 
 //  outstr:= outstr+
 //'const'+lineend;
//   keywordsstart:= length(outstr);
  outstr:= outstr+
  }
 'var'+lineend;
   for int1:= 0 to high(contexts) do begin
    str2:= '';
    with contexts[int1] do begin
     if (cont[contlast] <> '') and 
                       (cont[contlast][length(cont[contlast])] = '>') then begin
      setlength(cont[contlast],length(cont[contlast])-1);
      str2:= str2+'continue: true; ';
     end
     else begin
      str2:= str2+'continue: false; ';
     end;
     if (cont[contlast] <> '') and 
                       (cont[contlast][length(cont[contlast])] = '+') then begin
      setlength(cont[contlast],length(cont[contlast])-1);
      str2:= str2+'restoresource: true; ';
     end
     else begin
      str2:= str2+'restoresource: false; ';
     end;
     if (cont[contlast] <> '') and 
                       (cont[contlast][length(cont[contlast])] = '*') then begin
      setlength(cont[contlast],length(cont[contlast])-1);
      str2:= str2+'cutafter: true; ';
     end
     else begin
      str2:= str2+'cutafter: false; ';
     end;
     if (cont[contlast] <> '') and 
                       (cont[contlast][length(cont[contlast])] = '^') then begin
      setlength(cont[contlast],length(cont[contlast])-1);
      str2:= str2+lineend+
 '               pop: true; popexe: false; ';
 {
      if cont[1] <> '' then begin
       error('pop parent not allowed with NEXT',li);
      end;
 }
     end
     else begin
      if (cont[contlast] <> '') and 
                       (cont[contlast][length(cont[contlast])] = '!') then begin
       setlength(cont[contlast],length(cont[contlast])-1);
       str2:= str2+lineend+
 '               pop: true; popexe: true; ';
  {
       if cont[1] <> '' then begin
        error('pop parent-exe not allowed with NEXT',li);
       end;
  }
      end
      else begin
       str2:= str2+lineend+
 '               pop: false; popexe: false; ';
      end;
     end;
     if (cont[contlast] <> '') and 
                       (cont[contlast][length(cont[contlast])] = '*') then begin
      setlength(cont[contlast],length(cont[contlast])-1);
      str2:= str2+'cutbefore: true; ';
     end
     else begin
      str2:= str2+'cutbefore: false; ';
     end;
     if (cont[1] <> '') and (cont[1][length(cont[1])] = '-') then begin
      setlength(cont[1],length(cont[1])-1);
      str2:= str2+'nexteat: true; ';
     end
     else begin
      str2:= str2+'nexteat: false; ';
     end;
     outstr:= outstr+
 ' '+cont[0]+'co: contextty = (branch: nil; '+lineend+
 '               handleentry: nil; handleexit: nil; '+lineend+
 '               '+str2+'next: nil;'+lineend+
 '               caption: '''+cont[0]+''');'+lineend;
    end;
   end;
 
   outstr:= outstr+
 'implementation'+lineend+
 'uses'+lineend+
 ' '+usesdef+';'+lineend+
 'const'+lineend;
   for int1:= 0 to high(contexts) do begin
    with contexts[int1] do begin
     if bran <> nil then begin
      sortarray(bran,sizeof(bran[0]),@comparebranch);
      outstr:= outstr+
 ' b'+cont[0]+': array[0..'+inttostr(high(bran)+1)+'] of branchty = ('+lineend;
      for int2:= 0 to high(bran) do begin
       with bran[int2] do begin
        branflags1:= [bf_nt];
        if emptytoken then begin
         include(branflags1,bf_emptytoken);
        end;
        if keyword <> 0 then begin
         include(branflags1,bf_keyword);
        end;
        if (dest <> '') and (dest[1] = '!') then begin
         include(branflags1,bf_handler);
         dest:= copy(dest,2,bigint);
        end;
        if checklastchar(dest,'>') then begin
         include(branflags1,bf_continue);
        end;
 //       if checklastchar(dest,'!') then begin
 //        include(branflags1,bf_setpc);
 //       end;
        if checklastchar(dest,'*') then begin
         include(branflags1,bf_push);
        end;
        if checklastchar(dest,'^') then begin
         if bf_push in branflags1 then begin
          include(branflags1,bf_setparentbeforepush);
         end
         else begin
          include(branflags1,bf_setparentafterpush);
         end;
        end;
        if checklastchar(dest,'*') then begin
         include(branflags1,bf_push);
        end;
        if checklastchar(dest,'+') then begin
         include(branflags1,bf_nostartafter);
        end;
        if checklastchar(dest,'-') then begin
         include(branflags1,bf_eat);
        end;
        if checklastchar(dest,'+') then begin
         include(branflags1,bf_nostartbefore);
        end;
        if checklastchar(stack,'^') then begin
         include(branflags1,bf_changeparentcontext);
        end;
        if not checkident(dest) then begin
         error(branchformat,bline);
        end;
        outstr:= outstr+
 '   (flags: '+settostring(ptypeinfo(typeinfo(branflags1)),
                                  integer(branflags1),true)+';'+lineend+
 '     dest: (';
        if bf_handler in branflags1 then begin
         outstr:= outstr + 'handler: ';
        end
        else begin
         outstr:= outstr + 'context: ';
        end;
        if dest = '' then begin
         outstr:= outstr+'nil';
        end
        else begin
         outstr:= outstr+'@'+dest;
         if not (bf_handler in branflags1) then begin
          outstr:= outstr+'co';
         end;
        end;
        outstr:= outstr+'); stack: ';
        if stack = '' then begin
         outstr:= outstr+'nil';
        end
        else begin
         outstr:= outstr+'@'+stack+'co';
        end;
        outstr:= outstr+'; ';
        if keyword <> 0 then begin
         include(branflags1,bf_keyword);
         outstr:= outstr+lineend+
 '     keyword: $'+hextostr(keyword,8)+'{'+tokens[0]+'}),'+lineend;
        end
        else begin
         if (tokens <> nil) and (length(tokens[0]) > 1) then begin
          outstr:= outstr+'keys: ('+lineend;
          for int3:= 1 to length(tokens[0])-1 do begin
           outstr:= outstr+
 '    (kind: bkk_charcontinued; chars: '+
             charsettostring([tokens[0][int3]])+')';
           if int3 <> branchkeymaxcount then begin
            outstr:= outstr + ',';
           end;
           outstr:= outstr+lineend;
          end;
          outstr:= outstr+
 '    (kind: bkk_char; chars: '+
             charsettostring([tokens[0][length(tokens[0])]])+'),'+lineend;
          for int3:= length(tokens[0])+1 to branchkeymaxcount do begin
           outstr:= outstr +
 '    (kind: bkk_none; chars: [])';
           if int3 <> branchkeymaxcount then begin
            outstr:= outstr+ ',';
           end;
           outstr:= outstr+lineend;
          end;
          outstr:= outstr+
 '    )),'+lineend;
         end
         else begin
          chars1:= [];
          for int3:= 0 to high(tokens) do begin
           if tokens[int3] <> '' then begin
            include(chars1,tokens[int3][1]);
           end
           else begin
 //           chars1:= [#1..#255];
            chars1:= [#0..#255];
            break;
           end;
          end;
          outstr:= outstr+'keys: ('+lineend+
 '    (kind: bkk_char; chars: '+charsettostring(chars1)+'),'+lineend+
 '    (kind: bkk_none; chars: []),'+lineend+
 '    (kind: bkk_none; chars: []),'+lineend+
 '    (kind: bkk_none; chars: [])'+lineend+
 '    )),'+lineend;
         end;
        end;
       end;
      end;
      outstr:= outstr+
 '   (flags: []; dest: (context: nil); stack: nil; keyword: 0)'+lineend+
 '   );'+lineend;
     end;
    end;
   end;
   id:= idstart;
   nextid;
   for i1:= 0 to numidcount-1 do begin
    nextid();
   end;
 {
   str5:= 
 'const'+lineend+
 ' tks_none = 0;'+lineend;
   for int2:= 0 to high(internaltokens) do begin
    str2:= ansistring(pascalstringtostring(internaltokens[int2]));
    if (str2 <> '') and (str2[1] = '.') then begin
     str2:= copy(str2,2,bigint);
    end;
    str5:= str5+idstring('tks_'+str2);
   end;
   for int2:= 0 to high(keywords) do begin
    str5:= str5+ idstring('tk_'+keywords[int2]);
   end;
   int3:= 2+high(internaltokens)+high(keywords);
   str5:= str5+lineend+
 ' tokens: array[0..'+inttostr(int3)+
                       '] of string = ('''','+lineend;
   str2:= 
 '  ';
   for int2:= 0 to high(internaltokens) do begin
    str3:= internaltokens[int2]+',';
    if length(str2)+length(str3) > 80 then begin
     str5:= str5+str2+lineend;
     str2:= 
 '  ';
    end;
    str2:= str2+str3;
   end;
   str5:= str5 + str2 + lineend;
 
   str2:= 
 '  ';
   for int2:= 0 to high(keywords) do begin
    str3:= ansistring(stringtopascalstring(msestring(keywords[int2])))+',';
    if length(str2)+length(str3) > 80 then begin
     str5:= str5+str2+lineend;
     str2:= 
 '  ';
    end;
    str2:= str2+str3;
   end;
   setlength(str2,length(str2)-1);
   str5:= str5 + str2+');'+lineend+lineend;
 
   id:= idstart;
   nextid;
   for i1:= 0 to numidcount -1 do begin //numidents
    nextid();
   end;
   str5:= str5+
 ' tokenids: array[0..'+inttostr(int3)+'] of identty = ('+lineend;
   str2:=
 '  $00000000,';
   for int2:= 1 to int3 do begin
    str3:= '$'+hextostr(id,8)+',';
    nextid;
    if length(str2)+length(str3) > 80 then begin
     str5:= str5+str2+lineend;
     str2:= 
 '  ';
    end;
    str2:= str2+str3;
   end;
   setlength(str2,length(str2)-1);
   str5:= str5 + str2+');'+lineend+lineend;
 
   outstr:= copy(outstr,1,keywordsstart)+str5+copy(outstr,keywordsstart+1,bigint);
 }
   outstr:= outstr+
 'procedure init;'+lineend+
 'begin'+lineend;
   for int1:= 0 to high(contexts) do begin
    with contexts[int1] do begin
     outstr:= outstr+
 ' '+cont[0]+'co.branch:= ';
     if bran = nil then begin
      outstr:= outstr+'nil;'+lineend;
     end
     else begin
      outstr:= outstr+'@b'+cont[0]+';'+lineend;
     end;
     if cont[1] <> '' then begin
      outstr:= outstr+
 ' '+cont[0]+'co.next:= @'+cont[1]+'co;'+lineend;
     end;
     if cont[contlast-1] <> '' then begin
      outstr:= outstr+
 ' '+cont[0]+'co.handleentry:= @'+cont[contlast-1]+';'+lineend;
     end;
     if cont[contlast] <> '' then begin
 //     if cont[1] <> '' then begin
 //      error('EXITHANDLER not allowed with NEXT',li);
 //     end;
      outstr:= outstr+
 ' '+cont[0]+'co.handleexit:= @'+cont[contlast]+';'+lineend;
     end;
    end;
   end;
   outstr:= outstr +
 'end;'+lineend;
   outstr:= outstr+lineend+
 'function startcontext: pcontextty;'+lineend+
 'begin'+lineend+
 ' result:= @'+contexts[0].cont[0]+'co;'+lineend+
 'end;'+lineend+
 ''+lineend+
 'initialization'+lineend+
 ' init;'+lineend+
 'end.'+lineend+
 lineend;
 
   passtream.write(outstr);
   passtream.destroy();
  end; 
   //globals
  passtream:= ttextstream.create(globfile,fm_create);
  outstr:= unitheader+
'unit '+ansistring(filenamebase(globfile))+';'+lineend+
'{$ifdef FPC}{$mode objfpc}{$h+}{$endif}'+lineend+
'interface'+lineend+
'uses'+lineend+
' globtypes,parserglob,elements;'+lineend+
' '+lineend;

  str5:= 
'const'+lineend+
' tks_none = 0;'+lineend;
  for int2:= 0 to high(internaltokens) do begin
   str2:= ansistring(pascalstringtostring(internaltokens[int2]));
   if (str2 <> '') and (str2[1] = '.') then begin
    str2:= copy(str2,2,bigint);
   end;
   str5:= str5+idstring('tks_'+str2);
  end;
  for int2:= 0 to high(keywords) do begin
   str5:= str5+ idstring('tk_'+keywords[int2]);
  end;
  int3:= 2+high(internaltokens)+high(keywords);
  str5:= str5+lineend+
' tokens: array[0..'+inttostr(int3)+
                      '] of string = ('''','+lineend;
  str2:= 
'  ';
  for int2:= 0 to high(internaltokens) do begin
   str3:= internaltokens[int2]+',';
   if length(str2)+length(str3) > 80 then begin
    str5:= str5+str2+lineend;
    str2:= 
'  ';
   end;
   str2:= str2+str3;
  end;
  str5:= str5 + str2 + lineend;

  str2:= 
'  ';
  for int2:= 0 to high(keywords) do begin
   str3:= ansistring(stringtopascalstring(msestring(keywords[int2])))+',';
   if length(str2)+length(str3) > 80 then begin
    str5:= str5+str2+lineend;
    str2:= 
'  ';
   end;
   str2:= str2+str3;
  end;
  setlength(str2,length(str2)-1);
  str5:= str5 + str2+');'+lineend+lineend;

  id:= idstart;
  nextid;
  for i1:= 0 to numidcount -1 do begin //numidents
   nextid();
  end;
  str5:= str5+
' tokenids: array[0..'+inttostr(int3)+'] of identty = ('+lineend;
  str2:=
'  $00000000,';
  for int2:= 1 to int3 do begin
   str3:= '$'+hextostr(id,8)+',';
   nextid;
   if length(str2)+length(str3) > 80 then begin
    str5:= str5+str2+lineend;
    str2:= 
'  ';
   end;
   str2:= str2+str3;
  end;
  setlength(str2,length(str2)-1);
  str5:= str5 + str2+');'+lineend+lineend;

  outstr:= outstr+str5+
'implementation'+lineend+
'end.';
  passtream.write(outstr);

 finally
  grammarstream.free;
  passtream.free;
  macrolist1.free;
 end;

// internaltokens:= nil;
 branches:= nil;
 contexts:= nil;
// tokendefs:= nil;
// keywords:= nil;
// keywordids:= nil;
end;

procedure tmainmo.eventloopexe(const sender: TObject);
begin
 with sysenv do begin
  creategrammar(value[ord(pa_grammarfile)],value[ord(pa_pasglobfile)],
                                      values[ord(pa_pasfile)]);
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