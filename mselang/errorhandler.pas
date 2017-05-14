{ MSElang Copyright (c) 2013-2017 by Martin Schreiber
   
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
 globtypes,parserglob,grammar,elements,handlerglob,msetypes,msestrings,
                                                               msesystypes;

type
 errorty = (err_ok,err_duplicateidentifier,err_identifiernotfound,
            err_identifiertoolong,
            {err_thenexpected,}err_syntax,
            err_booleanexpressionexpected,
            err_wrongnumberofparameters,err_incompatibletypeforarg,
            err_toomanyidentifierlevels,err_wrongtype,
            err_cantfindunit,{err_implementationexpected,err_unitexpected,}
            err_illegalunitname,err_internalerror,err_abort,err_tokenexpected,
            err_typeidentexpected,err_identexpected,err_incompatibletypes,
            err_illegalqualifier,err_illegalexpression,err_varidentexpected,
            err_argnotassign,err_illegalcharacter,err_numberexpected,
            err_negnotpossible,{err_closeparentexpected,}err_illegalconversion,
            err_operationnotsupported,err_invalidtoken,err_sameparamlist,
            err_functionheadernotmatch,err_forwardnotsolved,err_filetrunc,
            err_circularreference,err_variableexpected,err_stringexeedsline,
            err_invalidintegerexpression,err_illegalcharconst,
            err_constexpressionexpected,err_errintypedef,err_ordtypeexpected,
            err_dataeletoolarge,err_highlowerlow,err_valuerange,
            err_cannotaddressconst,err_cannotderefnonpointer,
            err_cannotassigntoaddr,err_cannotaddressexp,err_invalidderef,
            err_expmustbeclassorrec,err_cannotfindinclude,err_toomanyincludes,
            err_fileread,err_filewrite,err_anonclassdef,err_classidentexpected,
            err_classfieldexpected,err_noclass,err_classref,err_invalidfloat,
            err_expressionexpected,err_overloadnotfunc,
            err_procdirectiveconflict,err_noancestormethod,err_methodexpected,
            err_typemismatch,err_classinstanceexpected,err_ordinalexpexpected,
            err_ordinalconstexpected,err_cantreadwritevar,
            err_identtoolong,err_illegalsetele,err_setelemustbecontiguous,
            err_anoninterfacedef,err_interfacetypeexpected,
            err_classtypeexpected,err_nomatchingimplementation,
            err_duplicateancestortype,err_localclassdef,err_noinputfile,
            err_cannotwritetargetfile,err_cannotcreatetargetfile,
            err_wrongversion,err_invalidprogram,err_compilerunitnotfound,
            err_cannotaddresstype,err_valueexpected,err_cannotgetsize,
            err_pointertypeexpected,err_write,err_toomanyparams,
            err_noancestor,err_forwardtypenotfound,err_invaliddirective,
            err_notnotpossible,err_invalidcontroltoken,
            err_wrongsignature,err_wrongkind,err_toomanynestinglevels,
            err_invalidunitfile,err_labelalreadydef,err_labelnotfound,
            err_invalidgototarget,err_enumnotcontiguous,
            err_duplicatesetelement,err_illegaldirective,
            err_cannotdeclarelocalexternal,err_unknownfieldormethod,
            err_nomemberaccessproperty,err_unknownrecordfield,
            err_illegalpropsymbol,err_div0,
            err_cantdetermine,err_callbyvarexact,err_defaultvaluescanonly,
            err_subnovalue,
            err_ignoreddirective,err_definehasnovalue,
            err_typecastdifferentsize,err_classnotresolved,
            err_invalidutf8,err_objecttypeexpected,
            err_recursiveancestor,err_objectpointerexpected,
            err_interfaceexpected,err_objectexpected,err_invalidattachment,
            err_missingobjectattachment,err_fieldtypeexpected,
            err_invalidmethodforattach,err_objectorclasstypeexpected,
            err_classmethodexpected,err_classmethod,err_classreference,
            err_typeidentnotallowed,err_attachitemexpected);
            
 errorinfoty = record
  level: errorlevelty;
  message: string;
 end;
 
 internalerrorkindty = (ie_none,ie_notimplemented,//todo
                        ie_parser,   //error in parser
                        ie_handler,  //error in handler function
                        ie_error,    //invalid error message
                        ie_unit,     //error in unithandler
                        ie_type,     //error in type handler
                        ie_managed,  //error in managed types handler
                        ie_sub,      //error in subhadler
                        ie_value,    //error in value handler
                        ie_elements, //error in element list
                        ie_rtti,     //error in rtti handler
                        ie_segment,  //error in segment handler
                        ie_bcwriter, //error in llvm bc writer
                        ie_llvm,     //error in llvm code generator
                        ie_llvmlist, //error in llvm lists
                        ie_llvmmeta, //error in llvm metadata
                        ie_module    //error in modular compilation
                       ); 
const
 internalerrorlabels: array[internalerrorkindty] of string = (
 //ie_none,ie_notimplemented,ie_parser,ie_handler,ie_error,ie_unit,
     '',     'N',              'P',      'H',       'R',     'U',    
 //ie_type,ie_managed
     'T',    'M',
 //ie_sub,ie_value,ie_elements,ie_rtti,ie_segment,ie_bcwriter,ie_llvm
     'SUB',   'V',   'E',        'I',    'SEG',     'BC',     'LLVM',
 //ie_llvmlist,ie_llvmmeta,ie_module
     'LLVML',  'LLVMME',   'MO'
 );
 
 stoperrorlevel = erl_fatal;
 errorerrorlevel = erl_error;
 
 errorleveltext: array[errorlevelty] of string = (
  '','Fatal','Error','Warning','Note','Hint'
 );
 errortext: array[errorty] of errorinfoty = (
  (level: erl_none; message: ''),
  (level: erl_error; message: 'Duplicate identifier "%s"'),
  (level: erl_error; message: 'Identifier not found "%s"'),
  (level: erl_fatal; message: 'Identifier too long "%s"'),
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
//  (level: erl_fatal; message: 'Syntax error, ")" expected'),
  (level: erl_error; message: 'Illegal type conversion: "%s" to "%s"'),
  (level: erl_error; message: 'Operation "%s" not supported for "%s" and "%s"'),
  (level: erl_fatal; message: 'Invalid token "%s"'),
  (level: erl_error; message: 
                       'Overloaded functions have the same parameter list'),
  (level: erl_error; message: 
               'Function header doesn''t match: param name changes "%s"=>"%s"'),
  (level: erl_error; message: 'Forward declaration not solved "%s"'),
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
                    'Can''t take the address of constant expressions'),
  (level: erl_error; message: 'Can''t dereference non pointer'),
  (level: erl_error; message: 'Can''t assign values to an address'),
  (level: erl_error; message: 'Can''t take the address of expression'),
  (level: erl_error; message: 'Invalid dereference'),
  (level: erl_error; message: 'Expresssion type must be object, class or record type'),
  (level: erl_fatal; message: 'Can not find include file'),
  (level: erl_error; message: 'Too many nested include files'),
  (level: erl_fatal; message: 'Can not read file "%s", error:'+lineend+
                              '%s'),
  (level: erl_fatal; message: 'Can not write file "%s", error:'+lineend+
                              '%s'),
  (level: erl_fatal; message: 'Anonymous class definitions are not allowed'),
  (level: erl_fatal; message: 'Object or class identifier expected'),
  (level: erl_error; message: 'Class field expected'),
  (level: erl_error; message: 'Class expected'),
  (level: erl_error; message: 
             'Only class methods can be referenced with class references'),
  (level: erl_error; message: 'Invalid floating point number'),
  (level: erl_error; message: 'Expression expected'),
  (level: erl_error; message: 'Overloaded identifier "%s" isn''t a function'),
  (level: erl_error; message: 
              'Procedure directive "%s" has conflicts with other directives'),
  (level: erl_error; message: 
              'There is no method in ancestor class to be overridden'),
  (level: erl_error; message: 'Method identifier expected'),
  (level: erl_error; message: 'Type mismatch'),
  (level: erl_error; message: 'Class instance expected'),
  (level: erl_error; message: 'Ordinal expression expected'),
  (level: erl_error; message: 'Ordinal constant expected'),
  (level: erl_error; message: 'Can''t read or write variables of this type'),
  (level: erl_error; message: 'Identifier too long "%s"'),
  (level: erl_error; message: 'Illegal type declaration of set elements'),
  (level: erl_error; message: 'Set elements must be contiguous'),
  (level: erl_fatal; message: 
              'Anonymous interface definitions are not allowed'),
  (level: erl_error; message: 'Interface type expected'),
  (level: erl_error; message: 'Class type expected'),
  (level: erl_error; message: 
          'No matching implementation for interface method "%s" found'),
  (level: erl_error; message: 'Duplicate ancestor type'),
  (level: erl_error; message: 'Local class definitions are not allowed'),
  (level: erl_fatal; message: 'No input file defined'),
  (level: erl_fatal; message: 'Can not write target file, error:'+lineend+
                              '%s'),
  (level: erl_fatal; message: 'Can not create target file, error:'+lineend+
                              '%s'),
  (level: erl_fatal; message: 'Wrong version "%s", expected "%s"'),
  (level: erl_fatal; message: 'Invalid program'),
  (level: erl_fatal; message: 'Compiler unit "%s" not found'),
  (level: erl_error; message: 'Can''t take the address of type'),
  (level: erl_error; message: 'Value expected'),
  (level: erl_error; message: 'Can not get size of this expression'),
  (level: erl_error; message: 'Pointer type expected'),
  (level: erl_error; message: 'Write error'),
  (level: erl_error; message: 'Too many parameters'),
  (level: erl_error; message: 'There is no ancestor'),
  (level: erl_error; message: 'Forward type "%s" not found'),
  (level: erl_error; message: 'Invalid directive "%s"'),
  (level: erl_error; message: '"not" operation not possible'),
  (level: erl_error; message: 'Invalid control token'),
  (level: erl_error; message: 'Wrong signature'),
  (level: erl_error; message: 'Wrong file kind'),
  (level: erl_fatal; message: 'Too many nesting levels'),
  (level: erl_fatal; message: 'Invalid unit file "%s"'),
  (level: erl_error; message: 'Label already defined'),
  (level: erl_error; message: 'Label not found "%s"'),
  (level: erl_error; message: 'Invalid goto target'),
  (level: erl_error; message: 'Enum type must be contiguous'),
  (level: erl_error; message: 'Duplicate set element'),
  (level: erl_warning; message: 'Illegal compiler directive "%s"'),
  (level: erl_error; message: 'Cannot declare local subroutine as EXTERNAL'),
  (level: erl_error; message: 'Unknown class field or method identifier "%s"'),
  (level: erl_error; message: 'No member is provided to access property'),
  (level: erl_error; message: 'Unknown record field identifier "%s"'),
  (level: erl_error; message: 'Illegal symbol for property access'),
  (level: erl_error; message: 'Division by zero'),
  (level: erl_error; message: 
                     'Can''t determine which overloaded subroutine to call'),
  (level: erl_error; message: 
    'Call by var for arg no. %d has to match exactly: Got "%s", expected "%s"'),
  (level: erl_error; message: 'Default values can only be specified for value,'+
                                              ' const and constref parameters'),
  (level: erl_error; message: 'Subroutine returns no value'),
  (level: erl_note; message: 'Ignored directive "%s"'),
  (level: erl_error; message: 'Define has no value'),
  (level: erl_error; message: 
                    'Typecast has different size (%d -> %d) in assignment'),
  (level: erl_error; message: 
                    'Parent class forward declaration not yet resolved'),
  (level: erl_error; message: 
                    'Invalid utf-8 sequence'),
  (level: erl_error; message: 'Object type expected'),
  (level: erl_error; message: 'Recursive ancestor "%s"'),
  (level: erl_error; message: 'Object pointer expected'),
  (level: erl_error; message: 'Interface expected'),
  (level: erl_error; message: 'Object expected'),
  (level: erl_error; message: 'Invalid attachment "%s"'),
  (level: erl_error; message: 'Missing object attachment "%s"'),
  (level: erl_error; message: 'Fieldtype expected'),
  (level: erl_error; message: 'Invalid method type for attachment "%s"'),
  (level: erl_error; message: 'Object or class type name expexted'),
  (level: erl_error; message: 'Class method expected'),
  (level: erl_error; message: 
                    'Only class methods can be accessed in class methods'),
  (level: erl_error; message: 
                    'Only class methods can be referred with object/class type references'),
  (level: erl_error; message: 
                    'Type identifier not allowed here'),
  (level: erl_error; message: 
                    'Attachment item expected')
 );

procedure message1(const atext: string; const values: array of const); 
procedure errormessage1(const atext: string; const values: array of const); 

procedure message1(const aerror: errorty; const values: array of const;
                       const aerrorlevel: errorlevelty = erl_none); 
procedure errormessage1(const aerror: errorty; const values: array of const;
                       const aerrorlevel: errorlevelty = erl_none); 

procedure errormessage(const asourcepos: sourceinfoty;
                   const aerror: errorty; const values: array of const;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);
procedure errormessage(const aerror: errorty; const values: array of const;
                   const astackoffset: integer = minint;
                   const coloffset: integer = 0;
                   const aerrorlevel: errorlevelty = erl_none);

function checksysok(const asyserror: syserrorty; const aerror: errorty; 
                                   const values: array of const;
                     const aerrorlevel: errorlevelty = erl_none): boolean;
                //true for sye_ok, appends syserror text to values

procedure identerror(const astackoffset: integer;const aerror: errorty;
                                   const aerrorlevel: errorlevelty = erl_none);
procedure identerror(const aident: identty; const aerror: errorty;
                             const aerrorlevel: errorlevelty = erl_none);
procedure identerror(const astackoffset: integer; const aident: identty; 
                                   const aerror: errorty;
                                   const aerrorlevel: errorlevelty = erl_none);

procedure tokenexpectederror(const atoken: identty;
                             const aerrorlevel: errorlevelty = erl_none);
procedure tokenexpectederror(const atoken: string;
                             const aerrorlevel: errorlevelty = erl_none);
procedure assignmenterror(const source: contextdataty; 
                                      const dest: vardestinfoty);
procedure illegalconversionerror(const source: contextdataty;
                 const dest: ptypedataty; const destindirectlevel: integer);
procedure incompatibletypeserror(const expected,got: contextdataty);
procedure incompatibletypeserror(const expected: typeinfoty;
                                                   const astackoffset: int32);
procedure incompatibletypeserror(const expected,got: ptypedataty; 
                                          const astackoffset: int32 = minint);
procedure incompatibletypeserror(const expected,got: elementoffsetty;
                                          const astackoffset: int32 = minint);
procedure incompatibletypeserror(const expected: string;
                                                const got: contextdataty);
procedure incompatibletypeserror(const param: integer; const expected: string;
                                                const got: contextdataty);
procedure operationnotsupportederror(const a,b: contextdataty;
                                             const operation: string);

procedure illegalcharactererror(const eaten: boolean);
procedure notimplementederror(const id: string);

{$ifdef mse_checkinternalerror}                             
procedure internalerror(const kind: internalerrorkindty; const id: string);
{$endif}
procedure internalerror1(const kind: internalerrorkindty; const id: string);

procedure circularerror(const astackoffset: integer; const adest: punitinfoty);
procedure rangeerror(const range: ordrangety;
                               const stackoffset: integer = minint);
procedure filereaderror(const afile: filenamety);
procedure filewriteerror(const afile: filenamety);

function typename(const ainfo: contextdataty;
                               const aindirection: int32=0): string;
function typename(const atype: typedataty;
                               const aindirection: int32=0): string;

function errorcount(const alevel: errorlevelty): integer;

implementation
uses
 sysutils,mseformatstr,typinfo,msefileutils,msesysutils,msesysintf1,msesys,
 identutils;
 
function typename(const ainfo: contextdataty;
                                    const aindirection: int32=0): string;
var
 po1: ptypedataty;
begin
{$ifdef mse_checkinternalerror}
 if not (ainfo.kind in datacontexts) then begin
  internalerror(ie_handler,'20160611B');
 end;
{$endif}
 po1:= ele.eledataabs(ainfo.dat.datatyp.typedata);
 result:= charstring('^',po1^.h.indirectlevel+ainfo.dat.datatyp.indirectlevel+
                                                           aindirection)+
                           getenumname(typeinfo(datakindty),ord(po1^.h.kind));
end;

function typename(const atype: typedataty;
                                  const aindirection: int32=0): string;
begin
 result:= charstring('^',atype.h.indirectlevel+aindirection)+
                    getenumname(typeinfo(datakindty),ord(atype.h.kind));
end;

function errorcount(const alevel: errorlevelty): integer;
var
 erl1: errorlevelty;
begin
 result:= 0;
 for erl1:= alevel downto low(errorlevelty) do begin
  result:= result + info.errors[erl1];
 end;
end;

procedure writeerror(const atext: string);
begin
 with info do begin
  if outputwritten then begin
   outputwritten:= false;
   outputstream.flush();
  end;
  errorstream.writeln(atext);
  errorwritten:= true;
 end;
end;

procedure writeoutput(const atext: string);
begin
 with info do begin
  if errorwritten then begin
   errorwritten:= false;
   errorstream.flush();
  end;
  outputstream.writeln(atext);
  outputwritten:= true;
 end;
end;

procedure printmessage(const atext: string; const toerror: boolean);
begin
 if toerror then begin
  writeoutput(atext);
 end
 else begin
  writeerror(atext);
 end;
end;

procedure printmessage(const aerror: errorty; const values: array of const;
                       const aerrorlevel: errorlevelty;
                       const toerror: boolean);
var
 str1: string;
 level1: errorlevelty;
begin
 with errortext[aerror],info do begin
  level1:= level;
  if aerrorlevel <> erl_none then begin
   level1:= aerrorlevel;
  end;
  inc(errors[level1]);
  str1:= errorleveltext[level1]+': '+format(message,values);
  printmessage(str1,toerror);
   
{$ifdef mse_debugparser}
  if toerror then begin
   writeln('<<<message<<< '+str1);
  end;
{$endif}
{
  if level1 <= stoperrorlevel then begin
   s.stopparser:= true;
  end;
  if level1 <= errorerrorlevel then begin
   errorfla:= true;
   if s.unitinfo^.stoponerror then begin
    s.stopparser:= true;
   end;
  end;
}
 end;
end;
                       
procedure errormessage1(const atext: string; const values: array of const); 
begin
 printmessage(format(atext,values),true);
end;

procedure message1(const atext: string; const values: array of const); 
begin
 printmessage(format(atext,values),false);
end;
  
procedure errormessage1(const aerror: errorty; const values: array of const;
                       const aerrorlevel: errorlevelty = erl_none); 
begin
 printmessage(aerror,values,aerrorlevel,true);
end;

procedure message1(const aerror: errorty; const values: array of const;
                       const aerrorlevel: errorlevelty = erl_none); 
begin
 printmessage(aerror,values,aerrorlevel,false);
end;
  
procedure errormessage(const asourcepos: sourceinfoty;
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
   po1:= info.s.sourcestart-1;
  end;
  with errortext[aerror],info do begin
   level1:= level;
   if aerrorlevel <> erl_none then begin
    level1:= aerrorlevel;
   end;
   inc(errors[level1]);
   str1:= ansistring(s.filename)+'('+inttostr(line+1)+','+
         inttostr(po-po1+coloffset)+') '+errorleveltext[level1]+': '+
                                format(ansistring(message),values);
   writeerror(str1);
{$ifdef mse_debugparser}
   writeln('<<<<<<< '+str1);
{$endif}
   if level1 <= stoperrorlevel then begin
    s.stopparser:= true;
   end;
   if level1 <= errorerrorlevel then begin
    errorfla:= true;
    if (s.unitinfo <> nil) and s.unitinfo^.stoponerror then begin
     s.stopparser:= true;
    end;
   end;
  end;
 end;
end;

procedure errormessage(const aerror: errorty; const values: array of const;
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
   sourcepos:= s.source;
  end
  else begin
   int1:= s.stackindex+astackoffset;
  {$ifdef mse_checkinternalerror}
   if (int1 > s.stacktop) or (int1 < 0) then begin
    internalerror(ie_error,'20140326A');
    exit;
   end;
  {$endif}
   sourcepos:= contextstack[int1].start;
  end;
  errormessage(sourcepos,aerror,values,coloffset,aerrorlevel);
 end;
end;

function checksysok(const asyserror: syserrorty; const aerror: errorty; 
                     const values: array of const;
                     const aerrorlevel: errorlevelty = erl_none): boolean;
                //true for sye_ok, appends syserror text to values
begin
 result:= asyserror = sye_ok;
 if not result then begin
  errormessage1(aerror,mergevarrec(values,[syserrortext(asyserror)]),
                                                                aerrorlevel);
 end;
end;

procedure illegalcharactererror(const eaten: boolean);
var
 po1: pchar;
begin
 with info do begin
  po1:= s.source.po;   //todo: utf-8 decoding
  if eaten then begin
   dec(po1);
  end;
  errormessage(err_illegalcharacter,
    ['"'+po1^+'" (#$'+hextostr(ord(po1^),2)+')'],s.stacktop-s.stackindex);
 end;
end;

procedure identerror(const astackoffset: integer;
            const aerror: errorty; const aerrorlevel: errorlevelty = erl_none);
begin
 with info,contextstack[s.stackindex+astackoffset] do begin
  errormessage(aerror,[lstringtostring(start.po,d.ident.len)],
                                    astackoffset,d.ident.len,aerrorlevel);
 end;
end;

procedure identerror(const aident: identty; const aerror: errorty;
                             const aerrorlevel: errorlevelty = erl_none);
begin
 errormessage(aerror,[getidentname(aident)],-1,0,aerrorlevel);
end;

procedure identerror(const astackoffset: integer; const aident: identty; 
                                   const aerror: errorty;
                                   const aerrorlevel: errorlevelty = erl_none);
begin
 errormessage(aerror,[getidentname(aident)],astackoffset,0,aerrorlevel);
end;

procedure tokenexpectederror(const atoken: string;
                                               const aerrorlevel: errorlevelty);
begin
 errormessage(err_tokenexpected,[atoken],minint,0,aerrorlevel);
end;

procedure tokenexpectederror(const atoken: identty;
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
 tokenexpectederror(str1,aerrorlevel);
end;

procedure typeconversionerror(const source: contextdataty;
                        const dest: vardestinfoty; const error: errorty);
var
 sourceinfo,destinfo: string;
 po1,po2: pelementinfoty;
 int1: integer;
begin
 case source.kind of
  ck_const,ck_fact,ck_ref: begin
   po1:= ele.eleinfoabs(source.dat.datatyp.typedata);
   sourceinfo:= getidentname(po1^.header.name);
   for int1:= 0 to source.dat.datatyp.indirectlevel-1 do begin
    sourceinfo:= '^'+sourceinfo;
   end;
   destinfo:= getenumname(typeinfo(dest.typ^.h.kind),ord(dest.typ^.h.kind));
   for int1:= 0 to dest.address.indirectlevel-1 do begin
    destinfo:= '^'+destinfo;
   end;
  end;
 end;  
 errormessage(error,[sourceinfo,destinfo]);
end;

procedure assignmenterror(const source: contextdataty; 
                                        const dest: vardestinfoty);
begin
 typeconversionerror(source,dest,err_incompatibletypes);
end;

procedure illegalconversionerror(const source: contextdataty;
                    const dest: ptypedataty; const destindirectlevel: integer);
var
 d1: vardestinfoty;
begin
 d1.address.flags:= [];
 d1.typ:= dest;
 d1.address.indirectlevel:= destindirectlevel;
 typeconversionerror(source,d1,err_illegalconversion);
end;

function typeinfoname(const typedata: elementoffsetty): string;
begin
 result:= getidentname(ele.eleinfoabs(typedata)^.header.name);
end;

function typeinfoname(const context: contextdataty): string;
begin
 with context do begin
  case kind of
   ck_const,ck_fact: begin
    result:= charstring('^',dat.datatyp.indirectlevel)+
                    charstring('@',-dat.datatyp.indirectlevel)+
                                   typeinfoname(dat.datatyp.typedata);
   end
   else begin
    result:= '';
   end;
  end;
 end;
end;

function typeinfoname(const typedata: ptypedataty): string;
begin
 result:= charstring('^',typedata^.h.indirectlevel)+
                    charstring('@',-typedata^.h.indirectlevel)+
                                   typeinfoname(ele.eledatarel(typedata));
end;

function typeinfoname(const atype: typeinfoty): string;
begin
 result:= charstring('^',atype.indirectlevel)+
                    charstring('@',-atype.indirectlevel)+
                                   typeinfoname(atype.typedata);
end;
{
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
}
procedure incompatibletypeserror(const expected,got: contextdataty);
begin
 errormessage(err_incompatibletypes,[typeinfoname(got),
                                                   typeinfoname(expected)]);
end;

procedure incompatibletypeserror(const expected: typeinfoty;
                                                   const astackoffset: int32); //stackoffset
begin
 with info do begin
  errormessage(err_incompatibletypes,
                  [typeinfoname(contextstack[s.stackindex+astackoffset].d),
                                         typeinfoname(expected)],astackoffset);
 end;
end;

procedure incompatibletypeserror(const expected,got: ptypedataty; 
                                          const astackoffset: int32 = minint);
begin
 errormessage(err_incompatibletypes,[typeinfoname(got),typeinfoname(expected)],
                                                                  astackoffset);
end;

procedure incompatibletypeserror(const expected,got: elementoffsetty;
                                          const astackoffset: int32 = minint);
var
 po1,po2: ptypedataty;
begin
 po1:= ele.eledataabs(expected);
 po2:= ele.eledataabs(got);
{$ifdef mse_checkinternalerror}
 if (datatoele(po1)^.header.kind <> ek_type) or 
             (datatoele(po2)^.header.kind <> ek_type) then begin
  internalerror(ie_handler,'20151202A');
 end;
{$endif}
 incompatibletypeserror(po1,po2,astackoffset);
end;

procedure incompatibletypeserror(const expected: string;
                                                const got: contextdataty);
begin
 errormessage(err_incompatibletypes,[typeinfoname(got),expected]);
end;

procedure incompatibletypeserror(const param: integer; const expected: string;
                                                const got: contextdataty);
begin
 errormessage(err_incompatibletypeforarg,[param,typeinfoname(got),expected]);
end;

procedure operationnotsupportederror(const a,b: contextdataty;
                                                   const operation: string);
begin
 errormessage(err_operationnotsupported,[operation,typeinfoname(a),
                                                           typeinfoname(b)]);
end;

procedure internalerror1(const kind: internalerrorkindty; const id: string);
begin
 errormessage(err_internalerror,[internalerrorlabels[kind]+id]);
 exitcode:= integer(kind);
 abort();
end;

procedure notimplementederror(const id: string);
begin
 internalerror1(ie_notimplemented,id);
end;

{$ifdef mse_checkinternalerror}
procedure internalerror(const kind: internalerrorkindty; const id: string);
begin
 internalerror1(kind,id);
end;
{$endif}

procedure circularerror(const astackoffset: integer; const adest: punitinfoty);
var
 str1: string;
 po1: punitinfoty;
begin
 po1:= info.s.unitinfo;
 str1:= '';
 while po1 <> nil do begin
  str1:= po1^.namestring+'->'+str1;
  if po1 = adest then begin
   break;
  end;
  po1:= po1^.prev;
 end;
 str1:= info.s.unitinfo^.namestring+'->'+str1;
 setlength(str1,length(str1)-2);
 errormessage(err_circularreference,[str1],astackoffset);
end;

procedure rangeerror(const range: ordrangety;
                                 const stackoffset: integer = minint);
begin
 errormessage(err_valuerange,[inttostr(range.min),
                                         inttostr(range.max)],stackoffset);
end;

procedure filereaderror(const afile: filenamety);
begin
 errormessage(err_fileread,[afile,sys_geterrortext(mselasterror)]);
end;

procedure filewriteerror(const afile: filenamety);
begin
 errormessage(err_filewrite,[afile,sys_geterrortext(mselasterror)]);
end;

end.
