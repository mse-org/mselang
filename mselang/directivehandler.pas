{ MSElang Copyright (c) 2013-2015 by Martin Schreiber
   
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
unit directivehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes;
 
procedure handledumpelements();
procedure handledumpopcode();
procedure handleabort();
procedure handlestoponerror();
procedure handlenop();

procedure handledefine();
procedure handledefinevalue();
procedure handleundef();

procedure handledirectiveentry();
procedure handledirective();
procedure handlestorenextcontext();
procedure handleifdef();
procedure handleifndef();
procedure ifcondentry();
procedure handleifcond();
procedure handleelseif();
procedure handleendif();
procedure handleskipifelseentry();

procedure handleignoreddirective();

//procedure adddefine(const id: identty);

implementation
uses
 msestrings,elements,parserglob,opcode,opglob,handlerutils,errorhandler,
 parser,handlerglob,grammarglob;
 
procedure handledumpelements();
begin
{$ifdef mse_debugparser}
 dumpelements();
{$endif}
 with info do begin
  dec(s.stackindex);
 end;
end;

procedure handledumpopcode();
begin
{$ifdef mse_debugparser}
 dumpops();
{$endif}
 with info do begin
  dec(s.stackindex);
 end;
end;

procedure handleabort();
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  s.stopparser:= true;
  errormessage(err_abort,[]);
  dec(s.stackindex);
 end;
end;

procedure handlestoponerror();
var
 int1: integer;
begin
{$ifdef mse_debugparser}
 outhandle('ABORT');
{$endif}
 with info do begin
  s.unitinfo^.stoponerror:= true;
  dec(s.stackindex);
 end;
end;

procedure handlenop();
begin
{$ifdef mse_debugparser}
 outhandle('NOP');
{$endif}
 additem(oc_nop);
end;
{
procedure adddefine(const id: identty);
var
 po1: pconditiondataty;
begin
 ele.adduniquechilddata(info.s.unitinfo^.interfaceelement,
                  [tks_defines,id],ek_condition,allvisi,po1);
 po1^.deleted:= false;
end;
}
procedure handledefine();
var
 po1: pconditiondataty;
 ident1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('DEFINE');
{$endif}
 with info,contextstack[s.stackindex+1] do begin
 {$ifdef mse_internaldebug}
  if d.kind <> ck_ident then begin
   internalerror(ie_handler,'20160703A');
  end;
 {$endif}
  ele.adduniquechilddata(s.unitinfo^.interfaceelement,
                  [tks_defines,d.ident.ident],ek_condition,allvisi,po1);
  po1^.deleted:= false;
  po1^.value.kind:= dk_none;
 end;
end;

procedure handledefinevalue();
var
 po1: pconditiondataty;
 ident1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('DEFINEVALUE');
{$endif}
 with info,contextstack[s.stacktop] do begin
 {$ifdef mse_internaldebug}
  if contextstack[s.stackindex+1].d.kind <> ck_ident then begin
   internalerror(ie_handler,'20160703A');
  end;
 {$endif}
  if d.kind <> ck_space then begin
   if not (d.kind in datacontexts) then begin
    internalerror(ie_handler,'20160703B');
   end;
   ele.adduniquechilddata(s.unitinfo^.interfaceelement,
                  [tks_defines,contextstack[s.stackindex+1].d.ident.ident],
                                                     ek_condition,allvisi,po1);
   po1^.deleted:= false;
   po1^.value:= d.dat.constval;
  end;
 end;
end;

procedure handleundef();
var
 po1: pconditiondataty;
begin
{$ifdef mse_debugparser}
 outhandle('UNDEF');
{$endif}
 with info,contextstack[s.stacktop] do begin
//  if ele.findchilddata(s.unitinfo^.interfaceelement,
//                 [tks_defines,d.ident.ident],[],allvisi,po1) then begin
  ele.adduniquechilddata(s.unitinfo^.interfaceelement,
                  [tks_defines,d.ident.ident],ek_condition,allvisi,po1);
                                  //hide possible global define
  po1^.deleted:= true;
//  end;
 end;
end;

procedure checkdef(const ifndef: boolean);
var
 po1: pconditiondataty;
begin
 po1:= nil;
 with info,contextstack[s.stacktop] do begin
  if not ele.findchilddata(s.unitinfo^.interfaceelement,
               [tks_defines,d.ident.ident],[],allvisi,po1) and
     not ele.findchilddata(rootelement,
               [tks_defines,d.ident.ident],[],allvisi,po1) then begin
   po1:= nil;
  end;
  if ((po1 = nil) or po1^.deleted) xor ifndef then begin
   switchcontext(s.contextref1);
  end;
 end;
end;

procedure handledirectiveentry();
begin
{$ifdef mse_debugparser}
 outhandle('DIRECTIVEENTRY');
{$endif}
 info.s.stackref1:= info.s.stacktop-1;
end;

procedure handledirective();
begin
{$ifdef mse_debugparser}
 outhandle('DIRECTIVE');
{$endif}
 info.s.stacktop:= info.s.stackref1;
end;

procedure handlestorenextcontext();
begin
{$ifdef mse_debugparser}
 outhandle('STORENEXTCONTEXT');
{$endif}
 with info do begin
  s.contextref1:= s.pc^.next;
 end;
end;

procedure handleifdef();
begin
{$ifdef mse_debugparser}
 outhandle('IFDEF');
{$endif}
 checkdef(false);
end;

procedure handleifndef();
begin
{$ifdef mse_debugparser}
 outhandle('IFNDEF');
{$endif}
 checkdef(true);
end;

procedure ifcondentry();
begin
{$ifdef mse_debugparser}
 outhandle('IFCONDENTRY');
{$endif}
 handlestorenextcontext();
 with info do begin
  include(s.currentstatementflags,stf_condition);
  exclude(s.currentstatementflags,stf_invalidcondition);
 end;
end;

procedure handleifcond();
begin
{$ifdef mse_debugparser}
 outhandle('IFCOND');
{$endif}
 with info do begin
  exclude(s.currentstatementflags,stf_condition);
  if stf_invalidcondition in s.currentstatementflags then begin
   switchcontext(s.contextref1);
  end
  else begin
   with info.contextstack[s.stacktop] do begin
    if d.kind <> ck_const then begin
     errormessage(err_constexpressionexpected,[],s.stacktop-s.stackindex);
    end
    else begin
     if (d.dat.datatyp.indirectlevel <> 0) or 
                       (d.dat.constval.kind <> dk_boolean) then begin
      errormessage(err_booleanexpressionexpected,[],s.stacktop-s.stackindex);
     end
     else begin
      if not d.dat.constval.vboolean then begin
       switchcontext(s.contextref1);
      end;
     end;
    end;
   end;
  end;
 end;
end;

//todo: check missing ifdef or double elseif
procedure handleelseif();
begin
{$ifdef mse_debugparser}
 outhandle('ELSEIF');
{$endif}
end;

procedure handleendif();
begin
{$ifdef mse_debugparser}
 outhandle('ENDIF');
{$endif}
end;

procedure handleskipifelseentry();
begin
{$ifdef mse_debugparser}
 outhandle('SKIPIFELSENTRY');
{$endif}
end;

procedure handleignoreddirective();
begin
{$ifdef mse_debugparser}
 outhandle('IGNOREDDIRECTIVE');
{$endif}
 identerror(1,err_ignoreddirective);
end;

end.
