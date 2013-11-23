{ MSElang Copyright (c) 2013 by Martin Schreiber
   
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
unit errorhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob,grammar,elements,handlerglob;

type
 errorty = (err_ok,err_duplicateidentifier,err_identifiernotfound,
            {err_thenexpected,}err_semicolonexpected,err_identifierexpected,
            err_booleanexpressionexpected,
            err_wrongnumberofparameters,err_incompatibletypeforarg,
            err_toomanyidentifierlevels,err_wrongtype,
            err_cantfindunit,{err_implementationexpected,err_unitexpected,}
            err_illegalunitname,err_internalerror,err_abort,err_tokenexpected,
            err_typeidentexpected,err_identexpected,err_incompatibletypes,
            err_illegalqualifier,err_illegalexpression,err_varidentexpected,
            err_argnotassign,err_illegalcharacter,err_numberexpected,
            err_negnotpossible,err_closeparentexpected,err_illegalconversion);
 errorinfoty = record
  level: errorlevelty;
  message: string;
 end;
const
 stoperrorlevel = erl_fatal;
 errorerrorlevel = erl_error;
 
 errorleveltext: array[errorlevelty] of string = (
  '','Fatal','Error'
 );
 errortext: array[errorty] of errorinfoty = (
  (level: erl_none; message: ''),
  (level: erl_error; message: 'Duplicate identifier "%s"'),
  (level: erl_error; message: 'Identifier not found "%s"'),
//  (level: erl_fatal; message: 'Syntax error, "then" expected'),
  (level: erl_fatal; message: 'Syntax error, ";" expected'),
  (level: erl_fatal; message: 'Syntax error, "identifier" expected'),
  (level: erl_error; message: 'Boolean expression expected'),
  (level: erl_error; message: 
                    'Wrong number of parameters specified for call to "%s"'),
  (level: erl_error; message: 
                    'Incompatible type for arg no. %d: Got "%s", expected "%s"'),
  (level: erl_fatal; message:
                    'Too many identifier levels'),
  (level: erl_error; message: 
                    'Wrong type'),
  (level: erl_fatal; message: 'Can''t find unit "%s"'),
//  (level: erl_fatal; message: 'Syntax error, "implementation" expected'),
//  (level: erl_fatal; message: 'Syntax error, "unit" expected'),
  (level: erl_fatal; message: 'Illegal unit name: "%s"'),
  (level: erl_fatal; message: 'Internal error %s'),
  (level: erl_fatal; message: 'Abort'),
  (level: erl_fatal; message: 'Syntax error,"%s" expected'),
  (level: erl_error; message: 'Type identifier expected'),
  (level: erl_error; message: 'Identifier expected'),
  (level: erl_error; message: 'Incompatible types: got "%s" expected "%s"'),
  (level: erl_error; message: 'Illegal qualifier'),
  (level: erl_error; message: 'Illegal expression'),
  (level: erl_error; message: 'Variable identifier expexted'),
  (level: erl_error; message: 'Argument can''t be assigned to'),
  (level: erl_fatal; message: 'Illegal character %s'),
  (level: erl_error; message: 'Number expected'),
  (level: erl_error; message: 'Negation not possible'),
  (level: erl_fatal; message: 'Syntax error, ")" expected'),
  (level: erl_error; message: 'Illegal type conversion: "%s" to "%s"')
 );
 
procedure errormessage(const info: pparseinfoty; const astackoffset: integer;
                   const aerror: errorty; const values: array of const;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);
procedure identerror(const info: pparseinfoty; const astackoffset: integer;
                               const aerror: errorty;
                                   const aerrorlevel: errorlevelty = erl_none);
procedure tokenexpectederror(const info: pparseinfoty; const atoken: identty;
                             const aerrorlevel: errorlevelty = erl_none);
procedure assignmenterror(const info: pparseinfoty;
                 const source: contextdataty; const dest: vardestinfoty);
procedure illegalconversionerror(const info: pparseinfoty;
                 const source: contextdataty; const dest: ptypedataty);
procedure illegalcharactererror(const info: pparseinfoty; const eaten: boolean);
                             
procedure internalerror(const info: pparseinfoty; const id: string);

implementation
uses
 msestrings,sysutils,mseformatstr,typinfo;

procedure errormessage(const info: pparseinfoty; const astackoffset: integer;
                   const aerror: errorty; const values: array of const;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);
var
 po1: pchar;
 sourcepos: sourceinfoty;
 str1: string;
 level1: errorlevelty;
begin
 with info^ do begin
  if astackoffset < 0 then begin
   sourcepos:= source;
  end
  else begin
   sourcepos:= contextstack[stackindex+astackoffset].start;
  end;
  with sourcepos do begin
   if line > 0 then begin
    po1:= po;
    while po1^ <> c_linefeed do begin
     dec(po1);
    end;
   end
   else begin
    po1:= sourcestart-1;
   end;
   with errortext[aerror] do begin
    level1:= level;
    if aerrorlevel <> erl_none then begin
     level1:= aerrorlevel;
    end;
    inc(errors[level1]);
    str1:=filename+'('+inttostr(line+1)+','+inttostr(po-po1+coloffset)+') '+
        errorleveltext[level1]+': '+format(message,values);
    command.writeln(str1);
    writeln('<<<<<<< '+str1);
    if level1 <= stoperrorlevel then begin
     stopparser:= true;
    end;
    if level1 <= errorerrorlevel then begin
     errorfla:= true;
    end;
   end;
  end;
 end;
end;

procedure illegalcharactererror(const info: pparseinfoty; const eaten: boolean);
var
 po1: pchar;
begin
 with info^ do begin
  po1:= source.po;   //todo: utf-8 decoding
  if eaten then begin
   dec(po1);
  end;
  errormessage(info,stacktop-stackindex,err_illegalcharacter,
           ['"'+po1^+'" (#$'+hextostr(ord(po1^),2)+')']);
 end;
end;

procedure identerror(const info: pparseinfoty; const astackoffset: integer;
            const aerror: errorty; const aerrorlevel: errorlevelty = erl_none);
begin
 with info^,contextstack[stackindex+astackoffset] do begin
  errormessage(info,astackoffset,aerror,
          [lstringtostring(start.po,d.ident.len)],d.ident.len,aerrorlevel);
 end;
end;

procedure tokenexpectederror(const info: pparseinfoty; const atoken: identty;
                                               const aerrorlevel: errorlevelty);
var
 int1: integer;
 str1: string;
begin
 str1:= '$'+hextostr(atoken,8);
 for int1:= 0 to high(tokenids) do begin
  if tokenids[int1] = atoken then begin
   str1:= tokens[int1];
   break;
  end;
 end;
 errormessage(info,-1,err_tokenexpected,[str1],0,aerrorlevel);
end;

procedure typeconversionerror(const info: pparseinfoty;
          const source: contextdataty; const dest: vardestinfoty;
                   const error: errorty);
var
 sourceinfo,destinfo: string;
 po1,po2: pelementinfoty;
begin
 case source.kind of
  ck_const,ck_fact: begin
   po1:= ele.eleinfoabs(source.datatyp.typedata);
   sourceinfo:= getidentname(po1^.header.name);
   destinfo:= getenumname(typeinfo(dest.typ^.kind),ord(dest.typ^.kind));
   if vf_reference in dest.address.flags then begin
    destinfo:= '^'+destinfo;
   end;
  end;
 end;  
 errormessage(info,-1,error,[sourceinfo,destinfo]);
end;

procedure assignmenterror(const info: pparseinfoty;
                      const source: contextdataty; const dest: vardestinfoty);
begin
 typeconversionerror(info,source,dest,err_incompatibletypes);
end;

procedure illegalconversionerror(const info: pparseinfoty;
                 const source: contextdataty; const dest: ptypedataty);
var
 d1: vardestinfoty;
begin
 d1.address.flags:= [];
 d1.typ:= dest;
 typeconversionerror(info,source,d1,err_illegalconversion);
end;

procedure internalerror(const info: pparseinfoty; const id: string);
begin
 errormessage(info,-1,err_internalerror,[id]);
end;

end.

sub test(para: boolean): int32;
var
 c1: card32;

 sub locabc();
 var
  bo1: bool8;
 begin
  bo1:= false;
  if bo1 then
   c1:= 88;
  else
   para:= false;
  end;
 end;

const
 maxval = 123;
 
begin
 if para then
  return maxval;
 end;
 locabc();
 return 12;
end;

procedure test(para: boolean): int32;
var
 c1: card32;

 procedure locabc();
 var
  bo1: bool8;
 begin
  bo1:= false;
  if bo1 then
   c1:= 88;
  else
   para:= false;
  end;
 end;

const
 maxval = 123;
 
begin
 if para then
  return maxval;
 end;
 locabc();
 return 12;
end;

testfunc(para: boolean): int32;
var
 c1: card32;

 locabc();
 var
  bo1: bool8;
 begin
  bo1:= false;
  if bo1 then
   c1:= 88;
  else
   para:= false;
  end;
 end;

const
 maxval = 123;
 
begin
 if para then
  return maxval;
 end;
 locabc();
end:= 12;

handler(const par1: msestring);
begin
 testfunc(false);
end;
