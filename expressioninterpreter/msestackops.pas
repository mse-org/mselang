{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestackops;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//
interface
type
 datakindty = (dk_none,dk_int32,dk_flo64);
 datainfoty = record
  case kind: datakindty of
   dk_int32: (
    vint32: integer;
   );
   dk_flo64: (
    vflo64: double;
   );
 end;

 popinfoty = ^opinfoty;
 infoopty = procedure(const opinfo: popinfoty);
 opty = procedure;

 op1infoty = record
  index0: integer;
 end;

 opkindty = (ok_none,ok_pushint32,ok_pushflo64,ok_pop,ok_op,ok_op1);
 opinfoty = record
//todo: variable item size, immediate data
  op: opty;
  case opkindty of 
   ok_pushint32: (
    vint32: integer;
   );
   ok_pushflo64: (
    vflo64: real;
   );
   ok_pop: (
    count: integer;
   );
   ok_op1: (
    op1: op1infoty;
   )
 end;
 
 opinfoarty = array of opinfoty;
 
procedure finalize;
function run(const code: opinfoarty; const stackdepht: integer): real;

procedure dummyop;
procedure pushint32;
procedure pushflo64;
procedure int32toflo64;
procedure mulint32;
procedure mulflo64;
procedure addint32;
procedure addflo64;
procedure negint32;
procedure negflo64;

implementation
type
 stackinfoty = record
  case datakindty of
   dk_int32: (vint32: integer);
   dk_flo64: (vflo64: real);
 end;
 stackinfoarty = array of stackinfoty;
var
 mainstack: stackinfoarty; 
 mainstackpo: integer;
 oppo: popinfoty;

procedure dummyop;
begin
end;

procedure pushint32;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vint32:= oppo^.vint32; 
end;

procedure pushflo64;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vflo64:= oppo^.vflo64; 
end;

procedure int32toflo64;
begin
 with mainstack[mainstackpo+oppo^.op1.index0] do begin
  vflo64:= vint32;
 end;
end;

procedure mulint32;
begin
 mainstack[mainstackpo-1].vint32:= 
                mainstack[mainstackpo-1].vint32 * mainstack[mainstackpo].vint32;
 dec(mainstackpo);
end;

procedure mulflo64;
begin
 mainstack[mainstackpo-1].vflo64:= 
                mainstack[mainstackpo-1].vflo64 * mainstack[mainstackpo].vflo64;
 dec(mainstackpo);
end;

procedure addint32;
begin
 mainstack[mainstackpo-1].vint32:= 
                mainstack[mainstackpo-1].vint32 + mainstack[mainstackpo].vint32;
 dec(mainstackpo);
end;

procedure addflo64;
begin
 mainstack[mainstackpo-1].vflo64:= 
                mainstack[mainstackpo-1].vflo64 + mainstack[mainstackpo].vflo64;
 dec(mainstackpo);
end;

procedure negint32;
begin
 mainstack[mainstackpo].vint32:= -mainstack[mainstackpo].vint32;
end;

procedure negflo64;
begin
 mainstack[mainstackpo].vflo64:= -mainstack[mainstackpo].vflo64;
end;

procedure finalize;
begin
 mainstack:= nil;
end;

function run(const code: opinfoarty; const stackdepht: integer): real;
var
 int1: integer;
 endpo: popinfoty;
begin
 setlength(mainstack,stackdepht);
 mainstackpo:= -1;
 int1:= 0;
 oppo:= pointer(code);
 endpo:= oppo+length(code);
 while oppo < endpo do begin
  oppo^.op;
  inc(oppo);
 end;
 result:= mainstack[0].vflo64;
end;

end.
