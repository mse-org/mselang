//__mla__personality
{ MSEgui Copyright (c) 2014-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit __mla__personality;
interface
//uses
// __mla__internaltypes;

const            //M S E   m l a
 mlaexceptionid = $4d5345006d6c6100;
type
{$ifdef mse_compiler}
 targetptrintty = int32;
 ptargetptrintty = ^targetptrintty;
 card32 = longword;
 card64 = qword;
 targetpointerty = card32;
 ptargetpointerty = ^targetpointerty;
{$endif}

 cint = int32;
 ptrint = int32;
 pptrint = ^ptrint;
 ptrcard = card32;

 _Unwind_Reason_Code = (
  _URC_NO_REASON,// = 0,
  _URC_FOREIGN_EXCEPTION_CAUGHT,// = 1,
  _URC_FATAL_PHASE2_ERROR,// = 2,
  _URC_FATAL_PHASE1_ERROR,// = 3,
  _URC_NORMAL_STOP,// = 4,
  _URC_END_OF_STACK,// = 5,
  _URC_HANDLER_FOUND,// = 6,
  _URC_INSTALL_CONTEXT,// = 7,
  _URC_CONTINUE_UNWIND);// = 8

 p_Unwind_Exception = ^_Unwind_Exception;
 _Unwind_Exception_Cleanup_Fn = procedure(reason: _Unwind_Reason_Code;
                                                      exc: p_Unwind_Exception);
 _Unwind_Exception_Class = card64;
 _Unwind_Word = card32;
 _Unwind_Sword = int32;
 
 _Unwind_Exception = packed record
  exception_class: _Unwind_Exception_Class;
  exception_cleanup: _Unwind_Exception_Cleanup_Fn;
  private_1: _Unwind_Word;
  private_2: _Unwind_Word;
 end;
 exceptinfoty = packed record
  header: _Unwind_Exception;
  data: pointer;
 end;
 pexceptinfoty = ^exceptinfoty;
 _Unwind_Context = record
 end;
 p_Unwind_Context = ^_Unwind_Context;
 
 _Unwind_Action = cint;
const
 _UA_SEARCH_PHASE = 1;
 _UA_CLEANUP_PHASE = 2;
 _UA_HANDLER_FRAME = 4;
 _UA_FORCE_UNWIND = 8;
 exco_unhandledexception = 217;
{$ifndef mse_compiler} 
function __mla__personality(version: cint;
             actions: _Unwind_Action;
             exceptionclass: _Unwind_Exception_Class;
             exceptionobject: p_Unwind_Exception;
             context: p_Unwind_Context): _Unwind_Reason_Code;

function _Unwind_RaiseException(
           exception_object: p_Unwind_Exception): _Unwind_Reason_Code; external;
function _Unwind_GetLanguageSpecificData(context: p_Unwind_Context): pointer;
                                                                       external;
function _Unwind_GetIP(context: p_Unwind_Context): pointer; external;
procedure _Unwind_SetIP(context: p_Unwind_Context; new_value: pointer);
                                                                  external;
function _Unwind_GetGR(context: p_Unwind_Context; index: cint): ptrint;
                                                                   external;
procedure _Unwind_SetGR(context: p_Unwind_Context; index: cint;
                                                new_value: ptrint); external;

function _Unwind_GetRegionStart(context: p_Unwind_Context): pointer; external;
{$endif} 

implementation
{$ifndef mse_compiler} 
type
 pcard8 = ^card8;

function readusleb128(var adata: pointer): ptrint;
var
 po1: pcard8;
 shift,i1: int32;
begin
 po1:= adata;
 result:= po1^ and $7f;
 shift:= 7;
 while po1^ and $80 <> 0 do begin       //todo: overflow check
  inc(po1);
  result:= result or ptrint(po1^ and $7f) shl shift;
  shift:= shift + 7;
 end;
 adata:= po1+1;
end;

function readssleb128(var adata: pointer): ptrint;
var
 po1: pcard8;
 shift,i1: int32;
begin
 po1:= adata;
 result:= po1^ and $7f;
 shift:= 7;
 while po1^ and $80 <> 0 do begin       //todo: overflow check
  inc(po1);
  result:= result or ptrint(po1^ and $7f) shl shift;
  shift:= shift + 7;
 end;
 if po1^ and $40 <> 0 then begin   //sign
  result:= result or ptrint(-1) shl shift; //negative
 end;
 adata:= po1+1;
end;

procedure fatalerror();
begin
 writeln('Fatal error');
 halt();
end;

const
{$ifdef target_x86_64}
 exceptionregno = 0;
 selectorregno = 1;
{$else}
 exceptionregno = 0;
 selectorregno = 2;
{$endif}

function installfinallycontext(const actions: _Unwind_Action;
             const exceptiondata: p_Unwind_Exception;
             const context: p_Unwind_Context;
             const landingpad: pointer): _Unwind_Reason_Code;
begin
 if actions and _UA_SEARCH_PHASE <> 0 then begin
  result:= _URC_HANDLER_FOUND;
 end
 else begin
  if actions and _UA_HANDLER_FRAME <> 0 then begin
   _Unwind_SetGR(context,exceptionregno,ptrint(exceptiondata));
   _Unwind_SetGR(context,selectorregno,0);
   _Unwind_SetIP(context,landingpad);
   result:= _URC_INSTALL_CONTEXT;
  end
  else begin
   result:= _URC_CONTINUE_UNWIND;
  end;
 end;
end;

function __mla__personality(version: cint;
             actions: _Unwind_Action;
             exceptionclass: _Unwind_Exception_Class;
             exceptionobject: p_Unwind_Exception;
             context: p_Unwind_Context): _Unwind_Reason_Code;
var
 po1: pointer;
 c1: ptrcard;
 typebaseoffset: ptrcard;
 tablelength: ptrcard;
 actionoffset: ptrcard;
 bo1: bool1;
 typestable: pointer;
 callsitetable: pointer;
 actiontable: pointer;
 ip,regionstart: pointer;
begin
 result:= _URC_CONTINUE_UNWIND;
// if actions and _UA_SEARCH_PHASE <> 0 then begin
 po1:= _Unwind_GetLanguageSpecificData(context);
 if po1 <> nil then begin
  result:= _URC_CONTINUE_UNWIND;
  bo1:= false;
  if pcard8(po1)^ = $ff then begin
   inc(po1);
   if pcard8(po1)^ = 0 then begin
    inc(po1);
    c1:= readusleb128(po1);
    typestable:= po1 + c1;
//writeln(c1);
    if pcard8(po1)^ = 3 then begin
     inc(po1);
     c1:= readusleb128(po1);
//writeln(c1);
     callsitetable:= po1;
     actiontable:= po1 + c1;
     ip:= _Unwind_GetIP(context){-1};
     regionstart:= _Unwind_GetRegionStart(context);
//writeln('IP            ',ip);
//writeln('regionstart   ',regionstart);
//writeln('typestable    ',typestable);
//writeln('callsitetable ',callsitetable);
//writeln('actiontable   ',actiontable);
//writeln('----');
     while callsitetable < actiontable do begin
      po1:= regionstart + pptrint(callsitetable)^;    //blockstart
//writeln(' blockstart   ',po1);
      if po1 > ip then begin
       break;                //no region found
      end;
      po1:= po1 + (pptrint(callsitetable)+1)^;          //blockend
//writeln(' blockend   ',po1);
      if po1 >= ip then begin //region found
       po1:= regionstart + (pptrint(callsitetable)+2)^; //landing pad
//writeln(' landingpad   ',po1);
       inc(callsitetable,3*sizeof(ptrint));
       actionoffset:= readusleb128(callsitetable);
       if actionoffset = 0 then begin
        result:= installfinallycontext(actions,exceptionobject,context,po1);
       end;
       break;
      end
      else begin
       inc(callsitetable,3*sizeof(ptrint));
       readusleb128(callsitetable);
      end;
     end;
     bo1:= true;
    end;
   end;
  end;
  if not bo1 then begin
   fatalerror();
  end;
 end
 else begin
 end;
// end
// else begin
//  if actions and _UA_HANDLER_FRAME <> 0 then begin
//   result:= _URC_INSTALL_CONTEXT;
//  end;
// end;
end;
{$endif}
end.
