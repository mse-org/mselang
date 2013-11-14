{ MSElang Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit stackops;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
//
//todo: use efficient data structures and procedures, 
//this is a proof of concept only
//
interface
uses
 parserglob;
 
type

 infoopty = procedure(const opinfo: popinfoty);

procedure finalize;
function run(const code: opinfoarty; const stackdepht: integer): real;

procedure dummyop;
procedure gotoop;
procedure ifop;
procedure writelnop;

procedure push8;
procedure push16;
procedure push32;
procedure push64;
procedure pushdatakind;
procedure int32toflo64;
procedure mulint32;
procedure mulflo64;
procedure addint32;
procedure addflo64;
procedure negcard32;
procedure negint32;
procedure negflo64;

procedure popglob8;
procedure popglob16;
procedure popglob32;
procedure popglob;

procedure poploc8;
procedure poploc16;
procedure poploc32;
procedure poploc;

procedure pushglob8;
procedure pushglob16;
procedure pushglob32;
procedure pushglob;

procedure pushloc8;
procedure pushloc16;
procedure pushloc32;
procedure pushloc;

procedure pushlocaddr;
procedure pushglobaddr;

procedure indirect8;
procedure indirect16;
procedure indirect32;
procedure indirect;

procedure callop;
procedure returnop;

implementation
type
 stackinfoty = record
  case datakindty of
   dk_kind: (vdatakind: datakindty);
   dk_boolean: (vboolean: boolean);
   dk_cardinal: (vcardinal: card32);
   dk_integer: (vinteger: int32);
   dk_float: (vfloat: float64);
   dk_address: (vaddress: pointer);
 end;
 stackinfoarty = array of stackinfoty;
var
 mainstack: stackinfoarty; 
 mainstackpo: integer;
 framepointer: integer;
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
 if not mainstack[mainstackpo].vboolean then begin
  oppo:= startpo + oppo^.d.opaddress;
 end;
 dec(mainstackpo);
end;

procedure writelnop;
var
 int1,int2,int3: integer;
begin
 int1:= mainstack[mainstackpo].vinteger;
 int3:= mainstackpo-int1;
 int2:= int3-int1;
 while int2 < int3 do begin
  case mainstack[int2+int1].vdatakind of
   dk_boolean: begin
    write(mainstack[int2].vboolean);
   end;
   dk_integer: begin
    write(mainstack[int2].vinteger);
   end;
   dk_float: begin
    write(mainstack[int2].vfloat);
   end;
  end;
  int2:= int2 + 1;
 end;
 writeln;
 mainstackpo:= mainstackpo-2*int1-1;
end;

procedure push8;
begin
 inc(mainstackpo);
 pv8ty(@mainstack[mainstackpo])^:= oppo^.d.v8; 
end;

procedure push16;
begin
 inc(mainstackpo);
 pv16ty(@mainstack[mainstackpo])^:= oppo^.d.v16; 
end;

procedure push32;
begin
 inc(mainstackpo);
 pv32ty(@mainstack[mainstackpo])^:= oppo^.d.v32; 
end;

procedure push64;
begin
 inc(mainstackpo);
 pv64ty(@mainstack[mainstackpo])^:= oppo^.d.v64; 
end;

procedure pushdatakind;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vdatakind:= oppo^.d.vdatakind; 
end;

procedure int32toflo64;
begin
 with mainstack[mainstackpo+oppo^.d.op1.index0] do begin
  vfloat:= vinteger;
 end;
end;

procedure mulint32;
begin
 mainstack[mainstackpo-1].vinteger:= 
                mainstack[mainstackpo-1].vinteger * 
                                  mainstack[mainstackpo].vinteger;
 dec(mainstackpo);
end;

procedure mulflo64;
begin
 mainstack[mainstackpo-1].vfloat:= mainstack[mainstackpo-1].vfloat * 
                                              mainstack[mainstackpo].vfloat;
 dec(mainstackpo);
end;

procedure addint32;
begin
 mainstack[mainstackpo-1].vinteger:= mainstack[mainstackpo-1].vinteger + 
                                              mainstack[mainstackpo].vinteger;
 dec(mainstackpo);
end;

procedure addflo64;
begin
 mainstack[mainstackpo-1].vfloat:= mainstack[mainstackpo-1].vfloat + 
                                              mainstack[mainstackpo].vfloat;
 dec(mainstackpo);
end;

procedure negcard32;
begin
 mainstack[mainstackpo].vcardinal:= -mainstack[mainstackpo].vcardinal;
end;

procedure negint32;
begin
 mainstack[mainstackpo].vinteger:= -mainstack[mainstackpo].vinteger;
end;

procedure negflo64;
begin
 mainstack[mainstackpo].vfloat:= -mainstack[mainstackpo].vfloat;
end;

procedure popglob8;
begin
 puint8(globdata+oppo^.d.dataaddress)^:= puint8(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure popglob16;
begin
 puint16(globdata+oppo^.d.dataaddress)^:= puint16(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure popglob32;
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

procedure pushglob8;
begin
 inc(mainstackpo);
 pv8ty(@mainstack[mainstackpo])^:= pv8ty(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob16;
begin
 inc(mainstackpo);
 pv16ty(@mainstack[mainstackpo])^:= pv16ty(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob32;
begin
 inc(mainstackpo);
 pv32ty(@mainstack[mainstackpo])^:= pv32ty(globdata+oppo^.d.dataaddress)^;
end;

procedure pushglob;
begin
 inc(mainstackpo);
 move((globdata+oppo^.d.dataaddress)^,(@mainstack[mainstackpo])^,
                                                    oppo^.d.datasize);
end;

procedure poploc8;
begin             
 pv8ty(@mainstack[framepointer+oppo^.d.count])^:= 
                                     pv8ty(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure poploc16;
begin
 pv16ty(@mainstack[framepointer+oppo^.d.count])^:= 
                                       pv16ty(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure poploc32;
begin
 pv32ty(@mainstack[framepointer+oppo^.d.count])^:= 
                                          pv32ty(@mainstack[mainstackpo])^;
 dec(mainstackpo);
end;

procedure poploc;
begin
 move((@mainstack[mainstackpo])^,(@mainstack[framepointer+oppo^.d.count])^,
                                                         oppo^.d.datasize);
 dec(mainstackpo);
end;

procedure pushloc8;
begin
 inc(mainstackpo);
 pv8ty(@mainstack[mainstackpo])^:= 
                       pv8ty(@mainstack[framepointer+oppo^.d.count])^;
end;

procedure pushloc16;
begin
 inc(mainstackpo);
 pv16ty(@mainstack[mainstackpo])^:= 
                       pv16ty(@mainstack[framepointer+oppo^.d.count])^;
end;

procedure pushloc32;
begin
 inc(mainstackpo);
 pv32ty(@mainstack[mainstackpo])^:= 
                       pv32ty(@mainstack[framepointer+oppo^.d.count])^;
end;

procedure pushloc;
begin
 inc(mainstackpo);
 move((@mainstack[framepointer+oppo^.d.count])^,
                                (@mainstack[mainstackpo])^,oppo^.d.datasize);
end;

procedure pushlocaddr;
begin
 inc(mainstackpo);
 ppointer(@mainstack[mainstackpo])^:= @mainstack[framepointer+oppo^.d.vaddress];
end;

procedure pushglobaddr;
begin
 inc(mainstackpo);
 pppointer(@mainstack[mainstackpo])^:= globdata + oppo^.d.vaddress;
end;

procedure indirect8;
begin
 pv8ty(@mainstack[mainstackpo])^:= 
          pv8ty(ppointer(@mainstack[mainstackpo])^)^;
end;

procedure indirect16;
begin
 pv16ty(@mainstack[mainstackpo])^:= 
          pv16ty(ppointer(@mainstack[mainstackpo])^)^;
end;

procedure indirect32;
begin
 pv32ty(@mainstack[mainstackpo])^:= 
         pv32ty(ppointer(@mainstack[mainstackpo])^)^;
end;

procedure indirect;
begin
 move(ppointer(@mainstack[mainstackpo])^^,(mainstack[mainstackpo]),
                                                          oppo^.d.datasize);
end;

procedure callop;
begin
 inc(mainstackpo);
 mainstack[mainstackpo].vaddress:= oppo;
 //todo: save framepointer
 framepointer:= mainstackpo{+1};
 oppo:= startpo+oppo^.d.opaddress;
end;

procedure returnop;
var
 int1: integer;
begin
 int1:= oppo^.d.count;
 oppo:= mainstack[mainstackpo].vaddress;
 mainstackpo:= mainstackpo-int1;
 //todo: restore framepointer
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
