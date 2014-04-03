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
unit errorhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 parserglob,grammar,elements,handlerglob,msetypes;

type
 errorty = (err_ok,err_duplicateidentifier,err_identifiernotfound,
            {err_thenexpected,}err_syntax,
            err_booleanexpressionexpected,
            err_wrongnumberofparameters,err_incompatibletypeforarg,
            err_toomanyidentifierlevels,err_wrongtype,
            err_cantfindunit,{err_implementationexpected,err_unitexpected,}
            err_illegalunitname,err_internalerror,err_abort,err_tokenexpected,
            err_typeidentexpected,err_identexpected,err_incompatibletypes,
            err_illegalqualifier,err_illegalexpression,err_varidentexpected,
            err_argnotassign,err_illegalcharacter,err_numberexpected,
            err_negnotpossible,err_closeparentexpected,err_illegalconversion,
            err_operationnotsupported,err_invalidtoken,err_sameparamlist,
            err_functionheadernotmatch,err_forwardnotsolved,err_filetrunc,
            err_circularreference,err_variableexpected,err_stringexeedsline,
            err_invalidintegerexpression,err_illegalcharconst,
            err_constexpressionexpected,err_errintypedef,err_ordtypeexpected,
            err_dataeletoolarge,err_highlowerlow,err_valuerange,
            err_cannotaddressconst,err_cannotderefnonpointer,
            err_cannotassigntoaddr,err_cannotaddressexp);
            
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
  (level: erl_fatal; message: 'Syntax error, "%s" expected'),
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
  (level: erl_error; message: 'Illegal type conversion: "%s" to "%s"'),
  (level: erl_error; message: 'Operation "%s" not supported for "%s" and "%s"'),
  (level: erl_fatal; message: 'Invalid token "%s"'),
  (level: erl_error; message: 
                       'Overloaded functions have the same parameter list'),
  (level: erl_error; message: 
               'Function header doesn''t match: param name changes "%s"=>"%s"'),
  (level: erl_error; message: 
               'Forward declaration not solved "%s"'),
  (level: erl_fatal; message: 'File "%s" truncated'),
  (level: erl_fatal; message: 'Circular unit reference %s'),
  (level: erl_error; message: 'Variable identifier expected'),
  (level: erl_fatal; message: 'String exeeds line'),
  (level: erl_error; message: 'Invalid integer expression'),
  (level: erl_error; message: 'Illegal char constant'),
  (level: erl_error; message: 'Constant expression expected'),
  (level: erl_error; message: 'Error in type definition'),
  (level: erl_error; message: 'Ordinal type expected'),
  (level: erl_error; message: 'Data element too large'),
  (level: erl_error; message: 'High range limit < low range limit'),
  (level: erl_error; message: 'Value exceeds range %s..%s'),
  (level: erl_error; message: 
                    'Can''t take the addreess of constant expressions'),
  (level: erl_error; message: 'Can''t dereference non pointer'),
  (level: erl_error; message: 'Can''t assign values to an address'),
  (level: erl_error; message: 'Can''t take the addreess of expression')
 );
 
procedure errormessage({const info: pparseinfoty;} const asourcepos: sourceinfoty;
                   const aerror: errorty; const values: array of const;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);
procedure errormessage({const info: pparseinfoty;}
                   const aerror: errorty; const values: array of const;
                   const astackoffset: integer = minint;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);

procedure identerror({const info: pparseinfoty;} const astackoffset: integer;
                               const aerror: errorty;
                                   const aerrorlevel: errorlevelty = erl_none);
procedure tokenexpectederror({const info: pparseinfoty;} const atoken: identty;
                             const aerrorlevel: errorlevelty = erl_none);
procedure tokenexpectederror({const info: pparseinfoty;} const atoken: string;
                             const aerrorlevel: errorlevelty = erl_none);
procedure assignmenterror({const info: pparseinfoty;}
                 const source: contextdataty; const dest: vardestinfoty);
procedure illegalconversionerror({const info: pparseinfoty;}
                 const source: contextdataty; const dest: ptypedataty;
                                       const destindirectlevel: integer);
procedure incompatibletypeserror({const info: pparseinfoty;}
                                    const a,b: contextdataty);
procedure operationnotsupportederror({const info: pparseinfoty;}
                           const a,b: contextdataty; const operation: string);

procedure illegalcharactererror({const info: pparseinfoty;} const eaten: boolean);
                             
procedure internalerror({const info: pparseinfoty;} const id: string);
procedure circularerror({const info: pparseinfoty;} const astackoffset: integer;
                                                     const adest: punitinfoty);
procedure rangeerror(const range: ordrangety;
                                          const stackoffset: integer = minint);
implementation
uses
 msestrings,sysutils,mseformatstr,typinfo,msefileutils;

procedure errormessage({const info: pparseinfoty;} const asourcepos: sourceinfoty;
                   const aerror: errorty; const values: array of const;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);
var
 po1: pchar;
 str1: string;
 level1: errorlevelty;
begin
 with asourcepos do begin
  if line > 0 then begin
   po1:= po;
   if po1^ = c_linefeed then begin
    dec(po1);
   end;
   while po1^ <> c_linefeed do begin
    dec(po1);
   end;
  end
  else begin
   po1:= info.sourcestart-1;
  end;
  with errortext[aerror],info do begin
   level1:= level;
   if aerrorlevel <> erl_none then begin
    level1:= aerrorlevel;
   end;
   inc(errors[level1]);
   str1:= msefileutils.filename(unitinfo^.filepath)+
      '('+inttostr(line+1)+','+inttostr(po-po1+coloffset)+') '+
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

procedure errormessage({const info: pparseinfoty;}
                   const aerror: errorty; const values: array of const;
                   const astackoffset: integer = minint;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);
var
 po1: pchar;
 sourcepos: sourceinfoty;
 str1: string;
 level1: errorlevelty;
 int1: integer;
begin
 with info do begin
  if astackoffset = minint then begin
   sourcepos:= source;
  end
  else begin
   int1:= stackindex+astackoffset;
   if (int1 > stacktop) or (int1 < 0) then begin
    internalerror({info,}'E20140326A');
    exit;
   end;
   sourcepos:= contextstack[int1].start;
  end;
  errormessage({info,}sourcepos,aerror,values,coloffset,aerrorlevel);
 end;
end;

procedure illegalcharactererror({const info: pparseinfoty;} const eaten: boolean);
var
 po1: pchar;
begin
 with info do begin
  po1:= source.po;   //todo: utf-8 decoding
  if eaten then begin
   dec(po1);
  end;
  errormessage({info,}err_illegalcharacter,
           ['"'+po1^+'" (#$'+hextostr(ord(po1^),2)+')'],stacktop-stackindex);
 end;
end;

procedure identerror({const info: pparseinfoty;} const astackoffset: integer;
            const aerror: errorty; const aerrorlevel: errorlevelty = erl_none);
begin
 with info,contextstack[stackindex+astackoffset] do begin
  errormessage({info,}aerror,[lstringtostring(start.po,d.ident.len)],
                                    astackoffset,d.ident.len,aerrorlevel);
 end;
end;

procedure tokenexpectederror({const info: pparseinfoty;} const atoken: string;
                                               const aerrorlevel: errorlevelty);
begin
 errormessage({info,}err_tokenexpected,[atoken],minint,0,aerrorlevel);
end;

procedure tokenexpectederror({const info: pparseinfoty;} const atoken: identty;
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
 tokenexpectederror({info,}str1,aerrorlevel);
end;

procedure typeconversionerror({const info: pparseinfoty;}
          const source: contextdataty; const dest: vardestinfoty;
                   const error: errorty);
var
 sourceinfo,destinfo: string;
 po1,po2: pelementinfoty;
 int1: integer;
begin
 case source.kind of
  ck_const,ck_fact,ck_ref: begin
   po1:= ele.eleinfoabs(source.datatyp.typedata);
   sourceinfo:= getidentname(po1^.header.name);
   for int1:= 0 to source.datatyp.indirectlevel-1 do begin
    sourceinfo:= '^'+sourceinfo;
   end;
   destinfo:= getenumname(typeinfo(dest.typ^.kind),ord(dest.typ^.kind));
//   if vf_reference in dest.address.flags then begin
   for int1:= 0 to dest.address.indirectlevel-1 do begin
    destinfo:= '^'+destinfo;
   end;
  end;
 end;  
 errormessage({info,}error,[sourceinfo,destinfo]);
end;

procedure assignmenterror({const info: pparseinfoty;}
                      const source: contextdataty; const dest: vardestinfoty);
begin
 typeconversionerror({info,}source,dest,err_incompatibletypes);
end;

procedure illegalconversionerror({const info: pparseinfoty;}
                 const source: contextdataty; const dest: ptypedataty;
                                             const destindirectlevel: integer);
var
 d1: vardestinfoty;
begin
 d1.address.flags:= [];
 d1.typ:= dest;
 d1.address.indirectlevel:= destindirectlevel;
 typeconversionerror({info,}source,d1,err_illegalconversion);
end;

procedure typeinfonames(const a,b: contextdataty; out ainfo,binfo: string);
var
 po1,po2: pelementinfoty;
begin
 case a.kind of
  ck_const,ck_fact: begin
   po1:= ele.eleinfoabs(a.datatyp.typedata);
   ainfo:= getidentname(po1^.header.name);
  end;
 end;
 case b.kind of
  ck_const,ck_fact: begin
   po2:= ele.eleinfoabs(b.datatyp.typedata);
   binfo:= getidentname(po2^.header.name);
  end;
 end;
end;

procedure incompatibletypeserror({const info: pparseinfoty;}
                                    const a,b: contextdataty);
var
 ainfo,binfo: string;
begin
 typeinfonames(a,b,ainfo,binfo);
 errormessage({info,}err_incompatibletypes,[binfo,ainfo]);
end;

procedure operationnotsupportederror({const info: pparseinfoty;}
                           const a,b: contextdataty; const operation: string);
var
 ainfo,binfo: string;
begin
 typeinfonames(a,b,ainfo,binfo);
 errormessage({info,}err_operationnotsupported,[operation,ainfo,binfo]);
end;

procedure internalerror({const info: pparseinfoty;} const id: string);
begin
 errormessage({info,}err_internalerror,[id]);
end;

procedure circularerror({const info: pparseinfoty;} const astackoffset: integer;
                                                     const adest: punitinfoty);
var
 str1: string;
 po1: punitinfoty;
begin
 po1:= info.unitinfo;
 str1:= '';
 while po1 <> nil do begin
  str1:= po1^.name+'->'+str1;
  if po1 = adest then begin
   break;
  end;
  po1:= po1^.prev;
 end;
 str1:= info.unitinfo^.name+'->'+str1;
 setlength(str1,length(str1)-2);
 errormessage({info,}err_circularreference,[str1],astackoffset);
end;

procedure rangeerror(const range: ordrangety;
                                    const stackoffset: integer = minint);
begin
 errormessage(err_valuerange,[inttostr(range.min),
                                         inttostr(range.max)],stackoffset);
end;

end.
