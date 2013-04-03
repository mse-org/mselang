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

procedure creategrammar(const grammar,outfile: filenamety);
type
 contextinfoty = record
  cont: stringarty;
  bran: stringararty;
 end;
 contextinfoarty = array of contextinfoty;
 
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

 procedure error(const text: string);
 begin
  exitcode:= 1;
//  application.terminated:= true;
  writestderr('***ERROR*** '+text+ ' line '+inttostr(line)+lineend+str1,true);
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

var
 ar1: stringarty;
 mstr1: msestring;
 str2,str3: string;
 int1,int2: integer;
 po1,po2,po3: pchar;
begin
 application.terminated:= true;
 try
  grammarstream:= ttextstream.create(grammar,fm_read);
  line:= 0;
  branchcount:= 0;
  context:= '';
  repeat
   grammarstream.readln(str1);
   inc(line);
   if (str1 <> '') and (str1[1] <> '#') then begin
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
       error('Format of contextline is "context,next,handler"');
       exit;
      end;
      branchcount:= 0;
      branches:= nil;
     end
     else begin
      int1:= findlastchar(str1,',');
      if int1 = 0 then begin
       error('Format of branch is "''string'',{''string'',}context"');
       exit;
      end;
      str2:= trim(copy(str1,int1+1,bigint));
      po1:= pchar(str1)+1;
      po2:= po1+int1-2;
      while true do begin
       po3:= po1;
       getpascalstring(po1);
       if po1 = po3 then begin
        error('Invalid string');
        exit;
       end;
       setstring(str3,po3,po1-po3);
       setlength(ar1,2);
       ar1[0]:= trim(str3);
       ar1[1]:= str2;
       additem(branches,ar1,branchcount);
       if po1 = po2 then begin
        break;
       end;
       if po1^ <> ',' then begin
        error('Format of branch is "''string'',{''string'',}context"');
        exit;
       end;
       inc(po1);
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
''+lineend+
'implementation'+lineend+
''+lineend+
'uses'+lineend+
' '+usesdef+';'+lineend+
' '+lineend+
'var'+lineend;
  for int1:= 0 to high(contexts) do begin
   with contexts[int1] do begin
    str1:= str1+
' '+cont[0]+'co: contextty = (branch: nil; handle: nil; next: nil;'+lineend+
'               caption: '''+cont[0]+''');'+lineend;
   end;
  end;
  str1:= str1+
lineend+
'const'+lineend;
  for int1:= 0 to high(contexts) do begin
   with contexts[int1] do begin
    if bran <> nil then begin
     str1:= str1+
' b'+cont[0]+': array[0..'+inttostr(high(bran)+1)+'] of branchty = ('+lineend;
     for int2:= 0 to high(bran) do begin
      str1:= str1+
'  (t:'+bran[int2][0]+';c:';
      if bran[int2][1] <> '' then begin
       str1:= str1+'@'+bran[int2][1]+'co),';
      end
      else begin
       str1:= str1+'nil),';
      end;
      str1:= str1+lineend;
     end;
     str1:= str1+
'  (t:'''';c:nil)'+lineend+
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
