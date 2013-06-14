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
uses
 mseparserglob;
 
type

 infoopty = procedure(const opinfo: popinfoty);

procedure finalize;
function run(const code: opinfoarty; const stackdepht: integer): real;

procedure dummyop;
procedure gotoop;
procedure ifop;
procedure writelnop;

procedure pushbool8;
procedure pushint32;
procedure pushflo64;
procedure pushdatakind;
procedure int32toflo64;
procedure mulint32;
procedure mulflo64;
procedure addint32;
procedure addflo64;
procedure negint32;
procedure negflo64;

procedure popglob1;
procedure popglob2;
procedure popglob4;
procedure popglob;

procedure pushglob1;
procedure pushglob2;
procedure pushglob4;
procedure pushglob;

procedure callop;
procedure returnop;

implementation
type
 stackinfoty = record
  case datakindty of
   dk_kind: (vdatakind: datakindty);
   dk_bool8: (vbool8: boolean);
   dk_int32: (vint32: integer);
   dk_flo64: (vflo64: real);
   dk_address: (vaddress: pointer);
 end;
 stackinfoarty = array of stackinfoty;
var
 mainstack: stackinfoarty; 
 mainstackpo: integer;
 startpo: popinfoty;
 oppo: popinfoty;
 globdata: pointer;

procedure dummyop;
begin
end;

procedure gotoop;
begin
 oppo:= startpo + oppo^.d.opaddress;
end;

procedure ifop;
begin
 if not mainstack[mainstackpo].vbool8 then begin
  oppo:= startpo + oppo^.d.opaddress;
 end;
 dec(mainstackpo);
end;

procedure writelnop;
var
 int1,int2,int3: integer;
begin
 int1:= mainstack[mainstackpo].vint32;
 int3:= mainstackpo-int1;
 int2:= int3-int1;
 while int2 < int3 do begin
  case mainstack[int2+int1].vdatakind of
   dk_bool8: begin
    write(mainstack[int2].vbool8);
   end;
   dk_int32: begin
    write(mainstack[int2].vint32);
   end;
   dk_flo64: begin
    write(mainstack[int2].vflo64);
   end;
  end;
  int2:= int2 + 1;
 end;
 writeln;
 mainstackpo:= mainstackpo-2*int1-1;
end;

procedure pushbool8;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vbool8:= oppo^.d.vbool8; 
end;

procedure pushint32;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vint32:= oppo^.d.vint32; 
end;

procedure pushflo64;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vflo64:= oppo^.d.vflo64; 
end;

procedure pushdatakind;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vdatakind:= oppo^.d.vdatakind; 
end;

procedure int32toflo64;
begin
 with mainstack[mainstackpo+oppo^.d.op1.index0] do begin
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

procedure popglob1;
begin
 puint8(globdata+oppo^.d.dataaddress)^:= puint8(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure popglob2;
begin
 puint16(globdata+oppo^.d.dataaddress)^:= puint16(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure popglob4;
begin
 puint32(globdata+oppo^.d.dataaddress)^:= puint32(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure popglob;
begin
 move((@mainstack[mainstackpo])^,(globdata+oppo^.d.dataaddress)^,
                                                         oppo^.d.datasize);
 dec(mainstackpo);
end;

procedure pushglob1;
begin
 inc(mainstackpo);
 puint8(@mainstack[mainstackpo])^:= puint8(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob2;
begin
 inc(mainstackpo);
 puint16(@mainstack[mainstackpo])^:= puint16(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob4;
begin
 inc(mainstackpo);
 puint32(@mainstack[mainstackpo])^:= puint32(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob;
begin
 inc(mainstackpo);
 move((globdata+oppo^.d.dataaddress)^,(@mainstack[mainstackpo])^,
                                                    oppo^.d.datasize);
end;

procedure callop;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vaddress:= oppo;
 oppo:= startpo+oppo^.d.opaddress;
end;

procedure returnop;
var
 int1: integer;
begin
 int1:= oppo^.d.count;
 oppo:= mainstack[mainstackpo].vaddress;
 mainstackpo:= mainstackpo-int1;
end;

procedure finalize;
begin
 mainstack:= nil;
end;

function run(const code: opinfoarty; const stackdepht: integer): real;
var
 endpo: popinfoty;
begin
 setlength(mainstack,stackdepht);
 mainstackpo:= -1;
 startpo:= pointer(code);
 oppo:= startpo;
 endpo:= oppo+length(code);
 with pstartupdataty(oppo)^ do begin
  getmem(globdata,globdatasize);
 end;
 inc(oppo,startupoffset);
 try
  while oppo < endpo do begin
   oppo^.op;
   inc(oppo);
  end;
  result:= 0;
 finally
  freemem(globdata);
 end;
end;

end.
