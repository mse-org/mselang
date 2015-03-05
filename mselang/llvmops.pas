{ MSElang Copyright (c) 2014-2015 by Martin Schreiber
   
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
unit llvmops;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 opglob,parserglob,msestream
  {$ifdef mse_llvmbc},llvmbcwriter,llvmbitcodes{$endif};

//todo: generate bitcode, use static string buffers, no ansistrings
 
function getoptable: poptablety;
function getssatable: pssatablety;
//procedure allocproc(const asize: integer; var address: segaddressty);

procedure run(const atarget: 
                   {$ifdef mse_llvmbc}tllvmbcwriter{$else}ttextstream{$endif});
 
implementation
uses
 sysutils,msesys,segmentutils,handlerglob,elements,msestrings,compilerunit,
 handlerutils,llvmlists,errorhandler;

type
 icomparekindty = (ick_eq,ick_ne,
                  ick_ugt,ick_uge,ick_ult,ick_ule,
                  ick_sgt,ick_sge,ick_slt,ick_sle);
 idsarty = array[0..maxparamcount-1] of int32;
 
const
 breakline = c_linefeed;
// nilconst = 'i8* inttoptr(i32 0 to i8*)';
 nilconst = 'i8* zeroinitializer';
 icomparetokens: array[icomparekindty] of string[3] = (
                  'eq','ne',
                  'ugt','uge','ult','ule',
                  'sgt','sge','slt','sle');
 ptrintname = 'i32';
 bytestrings: array[byte] of array[0..2] of char = (
  '  0','  1','  2','  3','  4','  5','  6','  7',
  '  8','  9',' 10',' 11',' 12',' 13',' 14',' 15',
  ' 16',' 17',' 18',' 19',' 20',' 21',' 22',' 23',
  ' 24',' 25',' 26',' 27',' 28',' 29',' 30',' 31',
  ' 32',' 33',' 34',' 35',' 36',' 37',' 38',' 39',
  ' 40',' 41',' 42',' 43',' 44',' 45',' 46',' 47',
  ' 48',' 49',' 50',' 51',' 52',' 53',' 54',' 55',
  ' 56',' 57',' 58',' 59',' 60',' 61',' 62',' 63',
  ' 64',' 65',' 66',' 67',' 68',' 69',' 70',' 71',
  ' 72',' 73',' 74',' 75',' 76',' 77',' 78',' 79',
  ' 80',' 81',' 82',' 83',' 84',' 85',' 86',' 87',
  ' 88',' 89',' 90',' 91',' 92',' 93',' 94',' 95',
  ' 96',' 97',' 98',' 99','100','101','102','103',
  '104','105','106','107','108','109','110','111',
  '112','113','114','115','116','117','118','119',
  '120','121','122','123','124','125','126','127',
  '128','129','130','131','132','133','134','135',
  '136','137','138','139','140','141','142','143',
  '144','145','146','147','148','149','150','151',
  '152','153','154','155','156','157','158','159',
  '160','161','162','163','164','165','166','167',
  '168','169','170','171','172','173','174','175',
  '176','177','178','179','180','181','182','183',
  '184','185','186','187','188','189','190','191',
  '192','193','194','195','196','197','198','199',
  '200','201','202','203','204','205','206','207',
  '208','209','210','211','212','213','214','215',
  '216','217','218','219','220','221','222','223',
  '224','225','226','227','228','229','230','231',
  '232','233','234','235','236','237','238','239',
  '240','241','242','243','244','245','246','247',
  '248','249','250','251','252','253','254','255');
var
// sp: integer; //unnamed variables
 pc: popinfoty;
type
 internalfuncinfoty = record
  name: string;
  flags: subflagsty;
  params: pparamsty;
 end;
 internalfuncty = (if_printf,if_malloc,if_free);
const
 printfpar: array[0..0] of paramitemty = (
              (typelistindex: pointertype; flags: [])
 );
 printfparams: paramsty = (count: 1; items: @printfpar);
 mallocpar: array[0..1] of paramitemty = (
              (typelistindex: pointertype; flags: []),
              (typelistindex: sizetype; flags: [])
 );
 mallocparams: paramsty = (count: 2; items: @mallocpar);
 freepar: array[0..0] of paramitemty = (
              (typelistindex: pointertype; flags: [])
 );
 freeparams: paramsty = (count: 1; items: @freepar);
 
 internalfuncconsts: array[internalfuncty] of internalfuncinfoty = (
  (name: 'printf'; flags: [sf_proto,sf_vararg]; params: @printfparams),
  (name: 'malloc'; flags: [sf_proto,sf_function]; params: @mallocparams),
  (name: 'free'; flags: [sf_proto]; params: @freeparams)
 );

type
 internalstringinfoty = record
  text: string;
 end;
 internalstringty = (is_ret,is_int32,is_string8,is_pointer);
const
 internalstringconsts: array[internalstringty] of internalstringinfoty = (
  (text: #$a#0),        //is_ret,
  (text: '%d'#0),       //is_int32,
  (text: '%s'#0),       //is_string8,
  (text: '%p'#0)        //is_pointer
 );  

var
 compilersubids: array[compilersubty] of int32;
{$ifdef mse_llvmbc}
 bcstream: tllvmbcwriter;
{$else}
 assstream: ttextstream;
{$endif}
 globconst: string;
 globconstid: int32;
 internalfuncs: array[internalfuncty] of int32;
 internalstrings: array[internalstringty] of int32;
 
// globconsttype: int32;


//todo: use c"..." form
function encodebytes(const source: pointer; const count: integer): string;
const
 itemsize = 7; //'i8 123,'
var
 int1,int2: integer;
 ps,pe: pbyte;
 po1: pchar;
 pd,pr: pchar;
begin
 result:= '';
 int1:= count * itemsize;
 int2:= 80 div itemsize; //items per row
 int1:= int1 + (count div int2); //for c_linefeed
 setlength(result,int1); //max
 ps:= source;
 pe:= ps + count;
 pd:= pointer(result);
 int2:= int2 * itemsize;
 pr:= pd + int2;
 while ps < pe do begin
  pd^:= 'i';
  inc(pd);
  pd^:= '8';
  inc(pd);
  pd^:= ' ';
  inc(pd);
  po1:= @bytestrings[ps^];
  pd^:= po1^;
  inc(pd);
  inc(po1);
  pd^:= po1^;
  inc(pd);
  inc(po1);
  pd^:= po1^;
  inc(pd);
  inc(po1);
  pd^:= ',';
  inc(pd);
  if pd >= pr then begin
   pd^:= c_linefeed;
   inc(pd);
   pr:= pd + int2;
  end;
  inc(ps);
 end;
 if count > 0 then begin
  dec(pd);                            //remove last comma
  if pd^ = c_linefeed then begin
   dec(pd);
  end;
  setlength(result,pointer(pd)-pointer(result));
 end;
end;

procedure outass(const atext: string);
begin
{$ifdef mse_llvmbc}
 raise exception.create('LLVM bitcode only!');
{$else}
 assstream.writeln(atext);
{$endif}
end;

procedure outbinop(const atext: string);
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = '+atext+
   ' %'+inttostr(ssas1)+', %'+inttostr(ssas2));
 end;
end;

procedure outbinop(const aop: BinaryOpcodes);
begin
 with pc^.par do begin
  bcstream.emitbinop(aop,bcstream.ssaval(ssas1),bcstream.ssaval(ssas2));
 end;
end;

procedure notimplemented();
begin
 raise exception.create('LLVM OP not implemented');
end;

const
 segprefix: array[segmentty] of string = (
 //seg_nil,seg_stack,seg_globvar,seg_globconst,
   '',     '@s',       '@gv',      '@gc',
 //seg_op,seg_rtti,seg_intf,seg_paralloc
   '@o',  '@rt',   '@if',   '');
 
 typestrings: array[databitsizety] of string = (
  //das_none,das_1,das_2_7,das_8,das_9_15,das_16,das_17_31,das_32,
    '',      'i1', '',     'i8', '',      'i16', '',       'i32',  
  //das_33_63,das_64,das_pointer,das_f16,das_f32,das_f64,  das_sub
    '',       'i64', 'i8*',      'half', 'float','double','sub');

procedure llvmtype(const asize: typeallocinfoty; out result: shortstring);
begin
 case asize.kind of
  das_none: begin
   result:= '['+inttostr(asize.size)+'x i8]';
  end;
  else begin
   result:= typestrings[asize.kind];
   if result = '' then begin
    result:= 'i'+inttostr(asize.size);
   end;
  end;
 end;
end;

procedure llvmglobvar(const avar: pvardataty; out result: shortstring);
var
 po1: ptypedataty;
begin
 if (avar^.address.indirectlevel > 0) then begin
  result:= nilconst;
 end
 else begin
  po1:= ptypedataty(ele.eledataabs(avar^.vf.typ));
  if po1^.kind in pointerdatakinds then begin
   result:= nilconst;
  end
  else begin
   llvmtype(getopdatatype(po1,avar^.address.indirectlevel),result);
   result:= result+' zeroinitializer';
  end;
 end;
end;

procedure segdataaddress(const address: segdataaddressty;
                                             out result: shortstring);
begin
 notimplemented();
{
 case address.a.segment of
  seg_globconst: begin
   if address.a.size = 0 then begin
    result:= 'bitcast (i8* getelementptr ('+globconst+',i32 0, i32 '+
                                 inttostr(address.a.address)+') to i8**)';
   end
   else begin
    if address.a.size < 0 then begin //int
     result:= 'bitcast i8* (getelementptr '+globconst+',i32 0, i32 '+
                                           inttostr(address.a.address) + 
                          ') to i'+inttostr(-address.a.size)+'* ';
    end
    else begin                       //record
     result:= 'getelementptr '+globconst+',i32 0, i32 '+
                          inttostr(address.a.address + address.offset);
    end;
   end;
  end;
  else begin
   result:= segprefix[address.a.segment]+inttostr(address.a.address);
  end;
 end;
}
end;

procedure segdataaddresspo(const address: segdataaddressty;
                     const brackets: boolean; out result: shortstring);
var
 str1,str2: shortstring;
begin
 notimplemented();
{
 segdataaddress(address,str2);
 if address.a.size = 0 then begin //pointer
  if brackets then begin
   result:='bitcast (i8** '+str2+' to i8*)';
  end
  else begin
   result:='bitcast i8** '+str2+' to i8*';
  end;
 end
 else begin
  if address.a.size < 0 then begin //int
   str1:= 'i'+inttostr(-address.a.size)+'* ';
   if brackets then begin
    result:= 'bitcast ('+str1+'getelementptr('+str1+str2+') to i8*)';
   end
   else begin
    result:= 'bitcast '+str1+'getelementptr('+str1+str2+') to i8*';
   end;
  end
  else begin                           //record
   if brackets then begin
    result:= 'getelementptr (['+
              inttostr(address.a.size)+' x i8]* '+str2+
              ', i32 0, i32 '+
              inttostr(address.offset)+')';
   end
   else begin
    result:= 'getelementptr ['+
              inttostr(address.a.size)+' x i8]* '+str2+
              ', i32 0, i32 '+
              inttostr(address.offset);
   end;
  end;
 end;
}
end;

procedure segaddress(const address: segaddressty; out result: shortstring);
begin
 result:= segprefix[address.segment]+inttostr(address.address);
end;

procedure locaddress(const address: dataoffsty; out result: shortstring);
begin
{$ifdef mse_locvarssatracking}
 if address.ssaindex > 0 then begin
  result:= '%'+inttostr(address.ssaindex);
 end
 else begin
{$endif}
  result:= '%l'+inttostr(address);
{$ifdef mse_locvarssatracking}
 end;
{$endif}
end;

procedure paraddress(const address: dataoffsty; out result: shortstring);
begin
{$ifdef mse_locvarssatracking}
 result:= '%l'+inttostr(address.address);
{$else}
 result:= '%p'+inttostr(address);
{$endif}
end;

procedure locdataaddress(const address: locdataaddressty;
                                            out result: shortstring);
begin
 locaddress(address.a.address,result);
end;

procedure curoplabel(out result: shortstring);
begin
 result:= 'o'+
    inttostr((pointer(pc)-getsegmentbase(seg_op)) div sizeof(opinfoty) -
                                                             startupoffset);
end;

procedure nextoplabel(out result: shortstring);
begin
 result:= 'o'+
    inttostr((pointer(pc)-getsegmentbase(seg_op)) div sizeof(opinfoty)- 
                                                            startupoffset+1);
end;

procedure oplabel(out result: shortstring);
begin
 result:= 'o'+ inttostr(pc^.par.opaddress.opaddress);
end;
(*
procedure stackimmassign1();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.listindex,imm.typeindex);
//  outass('%'+inttostr(ssad)+' = add i1 '+ inttostr(imm.vint8)+' ,0');
 end;
end;

procedure stackimmassign8();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.listindex,imm.typeindex);
//  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
//                                                inttostr(imm.vint8)+' ,0');
 end;
end;

procedure stackimmassign16();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
                                                inttostr(imm.vint16)+' ,0');
 end;
end;

procedure stackimmassign32();
begin
 with pc^.par do begin
  bcstream.emiti32const(imm.listindex);
{
  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
                                                inttostr(imm.vint32)+' ,0');
}
 end;
end;

procedure stackimmassign64();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
                                                inttostr(imm.vint64)+' ,0');
 end;
end;
*)
{
procedure segassign32(const ssaindex: integer; const dest: segdataaddressty);
begin
 outass('store i32 %'+inttostr(ssaindex)+', i32* '+segdataaddress(dest));
end;
}
procedure storeseg();
//var
// str1,str2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitstoreop(bcstream.ssaval(ssas1),
                     bcstream.globval(memop.segdataaddress.a.address));
{  
  llvmtype(memop.t,str1);
  segdataaddresspo(memop.segdataaddress,true,str2);
  outass('store '+str1+' %'+inttostr(ssas1)+', '+str1+'* '+
            'bitcast (i8* '+str2+ ' to '+str1+'*)');
}
 end;
end;

procedure loadseg();
//var
// str1, str2: shortstring;
begin
 with pc^.par do begin
  if memop.t.listindex > bittypemax then begin
   bcstream.emitsegdataaddresspo(memop);
   bcstream.emitloadop(bcstream.relval(0));
  end
  else begin
   bcstream.emitloadop(bcstream.globval(memop.segdataaddress.a.address));
  end;
{
  llvmtype(memop.t,str1);
  segdataaddresspo(memop.segdataaddress,true,str2);
  outass('%'+inttostr(ssad)+' = load '+str1+'* bitcast (i8* '+str2+
                                                          ' to '+str1+'* )');
}
 end;
end;
{
procedure loadseg32(const ssaindex: integer; const dest: segdataaddressty);
begin
 outass('%'+inttostr(ssaindex)+' = load i32* '+segdataaddress(dest));
end;
}
procedure locassign();
//var
// str1,str2,str3,str4,str5: shortstring;
begin
 with pc^.par do begin
  with memop,locdataaddress do begin
   if a.framelevel >= 0 then begin  //nested variable
    bcstream.emitgetelementptr(bcstream.subval(0),
            //pointer to array of pointer to local alloc
                                           bcstream.constval(a.address));
            //byte offset in array
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitloadop(bcstream.relval(0));
            //pointer to variable
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(t.listindex));
    bcstream.emitstoreop(bcstream.ssaval(ssas1),bcstream.relval(0));
   end
   else begin
    bcstream.emitstoreop(bcstream.ssaval(ssas1),
                                       bcstream.allocval(a.address));
   end;
  end;
{
 with pc^.par do begin
  llvmtype(memop.t,str1);
  str2:= '%'+inttostr(ssas1);
  if memop.locdataaddress.a.framelevel >= 0 then begin
   str3:= '%'+inttostr(ssad-2);
   str4:= '%'+inttostr(ssad-1);
   str5:= '%'+inttostr(ssad);
   outass(str3+' = getelementptr i8** %fp, i32 '+
                                   inttostr(memop.locdataaddress.a.address));
   outass(str4+' = bitcast i8** '+str3+' to '+str1+'**');
   outass(str5+' = load '+str1+'** '+str4);
   outass('store '+str1+' '+str2+
               ', '+str1+'* '+str5);
  end
  else begin
   locdataaddress(memop.locdataaddress,str3);
   outass('store '+str1+' '+str2+', '+
                         str1+'* '+str3);
  end;
}
{
  case memop.t.kind of
   odk_bit: begin
    str1:= 'i'+inttostr(memop.t.size);
    str2:= '%'+inttostr(ssas1);
    if memop.locdataaddress.a.framelevel >= 0 then begin
     str3:= '%'+inttostr(ssad-2);
     str4:= '%'+inttostr(ssad-1);
     str5:= '%'+inttostr(ssad);
     outass(str3+' = getelementptr i8** %fp, i32 '+
                                     inttostr(memop.locdataaddress.a.address));
     outass(str4+' = bitcast i8** '+str3+' to '+str1+'**');
     outass(str5+' = load '+str1+'** '+str4);
     outass('store '+str1+' '+str2+
                 ', '+str1+'* '+str5);
    end
    else begin
     outass('store '+str1+' '+str2+', '+
                           str1+'* '+ locdataaddress(memop.locdataaddress));
    end;
   end;
   else begin
    notimplemented();
   end;
  end;
}
 end;
end;

procedure parassign;
begin
{$ifdef mse_locvarssatracking}
 with pc^.par do begin
  outass('%'+inttostr(ssad)+
               ' = add i'+inttostr(memop.datacount)+
               ' %'+inttostr(ssas1)+', 0');
 end;
{$else}
 locassign();
{$endif}
end;

procedure assignindirect();
//var
// str1,dest1,dest2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),
                    bcstream.ptypeval(memop.t.listindex));
  bcstream.emitloadop(bcstream.relval(0));
{
  llvmtype(memop.t,str1);
  dest1:= '%'+inttostr(ssad-1);
  dest2:= '%'+inttostr(ssad);
  outass(dest1+' = bitcast i8* %'+inttostr(ssas1)+
                          ' to '+str1+'*');
  outass(dest2+' = load '+str1+'* '+dest1);
}
 end;
end;

{
procedure locassign32(const ssaindex: integer; const dest: locdataaddressty);
begin
 outass('store i32 %'+inttostr(ssaindex)+', i32* '+locdataaddress(dest));
end;
}

procedure locassignindi();
var
 str1,str2,dest1,dest2: shortstring;
begin
 with pc^.par do begin                  //todo: add offset, nested frame
  llvmtype(memop.t,str1); 
  dest1:= '%'+inttostr(ssad);
  dest2:= '%'+inttostr(ssad+1);
  locdataaddress(memop.locdataaddress,str2);
  outass(dest1+' = load '+ptrintname+'* '+str2);
  outass(dest2+' = inttoptr '+ptrintname+' '+dest1+' to i32*');
  outass('store '+str1+' %'+inttostr(ssas1)+', '+str1+'* '+dest2);
 
{
  case memop.t.kind of
   odk_bit: begin
    dest1:= '%'+inttostr(ssad);
    dest2:= '%'+inttostr(ssad+1);
    outass(dest1+' = load '+ptrintname+
                                 '* '+locdataaddress(memop.locdataaddress));
    outass(dest2+' = inttoptr '+ptrintname+' '+dest1+' to i32*');
    outass('store i'+inttostr(memop.t.size)+' %'+inttostr(ssas1)+
                               ', i'+inttostr(memop.t.size)+'* '+dest2);
   end;
   else begin
    notimplemented();
   end;
  end;
}
 end;
end;

procedure parassignindi();
begin
{$ifdef mse_locvarssatracking}
 notimplemented();
{$else}
 locassignindi();
{$endif}
end;

procedure assignloc();
//var
// str1,str2,str3,str4,str5: shortstring;
begin
 with pc^.par do begin
  with memop,locdataaddress do begin
   if a.framelevel >= 0 then begin
    bcstream.emitgetelementptr(bcstream.subval(0),
            //pointer to array of pointer to local alloc
                                           bcstream.constval(a.address));
            //byte offset in array
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitloadop(bcstream.relval(0));
            //pointer to variable
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(t.listindex));
    bcstream.emitloadop(bcstream.relval(0));
   end
   else begin
    bcstream.emitloadop(bcstream.allocval(a.address));
   end;
  end;
{
  llvmtype(memop.t,str1);
  if memop.locdataaddress.a.framelevel >= 0 then begin
   str2:= '%'+inttostr(ssad-3);
   str3:= '%'+inttostr(ssad-2);
   str4:= '%'+inttostr(ssad-1);
   str5:= '%'+inttostr(ssad);
   outass(str2+' = getelementptr i8** %fp, i32 '+
                                   inttostr(memop.locdataaddress.a.address));
   outass(str3+' = bitcast i8** '+str2+' to '+str1+'**');
   outass(str4+' = load '+str1+'** '+str3);
   outass(str5+' = load '+str1+'* '+str4);
  end
  else begin
   str2:= '%'+inttostr(ssad);
   locdataaddress(memop.locdataaddress,str3);
   outass(str2+' = load '+str1+'* '+str3);
  end;
}
 end;
end;

procedure assignlocindi();
var
 dest1,dest2,dest3: shortstring;
 str1,str2: shortstring;
begin
 with pc^.par do begin
  ;
  dest1:= '%'+inttostr(ssad);
  dest2:= '%'+inttostr(ssad+1);
  dest3:= '%'+inttostr(ssad+2);
  locdataaddress(memop.locdataaddress,str2);
  outass(dest1+' = load '+ptrintname+'* '+str2);
  outass(dest2+' = inttoptr '+ptrintname+' '+dest1+' to i32*');
  llvmtype(memop.t,str1);
  outass(dest3+' = load '+str1+'* '+dest2);

{
  case memop.t.kind of
   odk_bit: begin
    dest1:= '%'+inttostr(ssad);
    dest2:= '%'+inttostr(ssad+1);
    dest3:= '%'+inttostr(ssad+2);
    outass(dest1+' = load '+ptrintname+
                                 '* '+locdataaddress(memop.locdataaddress));
    outass(dest2+' = inttoptr '+ptrintname+' '+dest1+' to i32*');
    outass(dest3+' = load i'+inttostr(memop.t.size)+'* '+dest2);
   end;
   else begin
    notimplemented();
   end;
  end;
}
 end;
end;

procedure assignpar();
begin
{$ifdef mse_locvarssatracking}
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i'+inttostr(memop.databitsize)+
                       ' '+locdataaddress(memop.locdataaddress)+', 0');
 end;
{$else}
 assignloc();
{$endif}
end;

{
procedure assignloc32(const ssaindex: integer; const dest: locdataaddressty);
begin
 outass('%'+inttostr(ssaindex)+' = load i32* '+locdataaddress(dest));
end;
}
{
procedure icompare(const akind: icomparekindty);
begin
 with pc^.par do begin
  
  outass('%'+inttostr(ssad)+' = icmp '+icomparetokens[akind]+
                   ' i'+inttostr(stackop.t.size)+
                               ' %'+inttostr(ssas1)+', %'+inttostr(ssas2));  
 end;
end;

procedure pocompare(const akind: icomparekindty);
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = icmp '+icomparetokens[akind]+
                   ' i8* %'+inttostr(ssas1)+', %'+inttostr(ssas2));  
 end;
end;
}

procedure compare(const apredicate: predicate);
begin
 with pc^.par do begin
  bcstream.emitcmpop(apredicate,bcstream.ssaval(ssas1),
                                               bcstream.ssaval(ssas2));
 end;
end;

procedure callcompilersub(const asub: compilersubty;
                                     const aparams: shortstring);
var
 po1: psubdataty;
begin
 po1:= ele.eledataabs(compilersubs[asub]);
 outass('call void @s'+inttostr(po1^.address)+'('+aparams+')');
end;

procedure callcompilersub(const asub: compilersubty; const afunc: boolean;
                                     const aparams: array of int32);
begin
 bcstream.emitcallop(afunc,compilersubids[asub],aparams);
end;

procedure decrefsize(const aaddress: shortstring);
begin
 callcompilersub(cs_decrefsize,aaddress);
end;

procedure finirefsize(const aaddress: shortstring);
begin
 callcompilersub(cs_finifrefsize,'i8* '+aaddress);
end;

procedure nopop();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i1 0, 0');
 end;
end;

procedure labelop();
//var
// lab: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbrop(opaddress.bbindex);
 end;
{
 curoplabel(lab);
 outass('br label %'+lab);
 outass(lab+':');
}
end;

var
 exitcodeaddress: segaddressty;

const
 wret = '\0a\00';
 wretformat = '[2 x i8]* @.wret';
 wretc = '[2 x i8] c"'+wret+'"';

 wint32 = '%d\00';
 wint32c = '[3 x i8] c"'+wint32+'"';
 wint32format = '[3 x i8]* @.wint32';
 
 wstring8 = '%s\00';
 wstring8c = '[3 x i8] c"'+wstring8+'"';
 wstring8format = '[3 x i8]* @.wstring8';

 wpointer = '%p\00';
 wpointerc = '[3 x i8] c"'+wpointer+'"';
 wpointerformat = '[3 x i8]* @.wpointer';
  
procedure beginparseop();
var
// endpo: pointer;
// allocpo: pgloballocinfoty;
 ele1,ele2: elementoffsetty;
 po1: punitdataty;
 po2: pvardataty;
 po3: ptypedataty;
 int1: integer;
 str1,str2: shortstring;
 funcs1: internalfuncty;
 strings1: internalstringty;
 compilersub1: compilersubty;
{
const
// voidparam: paramitemty = (typelistindex: voidtype; flags: []);
 pointerparam: paramitemty = (typelistindex: pointertype; flags: []);
// varargparam: paramitemty = (typelistindex: 0; flags: [pif_vararg]);
} 
begin
// freeandnil(assstream);
// assstream:= ttextstream.create('test.ll',fm_create);
{
 outass('declare i32 @printf(i8*, ...)');
 outass('declare i8* @malloc(i32)');
 outass('declare void @free(i8*)');
 outass('@.wret = internal constant '+wretc);
 outass('@.wint32 = internal constant '+wint32c);
 outass('@.wstring8 = internal constant '+wstring8c);
 outass('@.wpointer = internal constant '+wpointerc);
}
 int1:= getsegmentsize(seg_globconst);
 if int1 > 0 then begin
  globconstid:= globlist.addinitvalue(gak_var,
             constlist.addvalue(getsegmentpo(seg_globconst,0)^,int1).listid{,
                                                           globconsttype});
 end;
 globlist.addsubvalue(nil,stringtolstring('main'));
 for funcs1:= low(internalfuncs) to high(internalfuncs) do begin
  with internalfuncconsts[funcs1] do begin
   internalfuncs[funcs1]:= globlist.addexternalsubvalue(flags,params^,
                                                    stringtolstring(name));
  end;
 end;
 for strings1:= low(internalstringconsts) to high(internalstringconsts) do begin
  with internalstringconsts[strings1] do begin
   internalstrings[strings1]:= globlist.addinitvalue(gak_const,
                     constlist.addvalue(pointer(text)^,length(text)).listid);
  end;
 end;

 for compilersub1:= low(compilersubids) to high(compilersubids) do begin
  compilersubids[compilersub1]:= psubdataty(
                  ele.eledataabs(compilersubs[compilersub1]))^.globid;  
 end;
 
 with pc^.par.beginparse do begin
  bcstream.start(constlist,globlist);
 {
  ele1:= unitinfochain;
  while ele1 <> 0 do begin
   po1:= ele.eledataabs(ele1);
   ele2:= po1^.varchain;
   while ele2 <> 0 do begin
    po2:= ele.eledataabs(ele2);
    globlist.addvalue(po2);
    ele2:= po2^.vf.next;
   end;
   ele1:= po1^.next;
  end;
  }
  llvmops.exitcodeaddress:= exitcodeaddress;
 end;
end;

procedure mainop();
begin
 with pc^.par do begin
  bcstream.beginsub([]{false},nullallocs,main.blockcount);
 end;
// outass('define i32 @main() {');
end;

procedure progendop();
var
 i1: int32;
begin
 bcstream.emitloadop(bcstream.valindex(exitcodeaddress));
 bcstream.emitretop(bcstream.ssaindex-1);
 bcstream.endsub();
(*
 segaddress(exitcodeaddress,str1);
 outass('%.exitcode = load i32* '+str1);
 outass('ret i32 %.exitcode');
 outass('}');
*)
end;

procedure endparseop();
begin
 bcstream.stop();
// freeandnil(assstream);
end;

procedure movesegreg0op();
begin
 notimplemented();
end;
procedure moveframereg0op();
begin
 notimplemented();
end;
procedure popreg0op();
begin
 notimplemented();
end;
procedure increg0op();
begin
 notimplemented();
end;

procedure gotoop();
//var
// lab: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbrop(getoppo(opaddress.opaddress)^.par.opaddress.bbindex);
 end;
{
 oplabel(lab);
 outass('br label %'+lab);
}
end;

procedure cmpjmpneimm4op();
begin
 notimplemented();
end;
procedure cmpjmpeqimm4op();
begin
 notimplemented();
end;
procedure cmpjmploimm4op();
begin
 notimplemented();
end;
procedure cmpjmpgtimm4op();
begin
 notimplemented();
end;
procedure cmpjmploeqimm4op();
begin
 notimplemented();
end;

procedure ifop();
//var
// tmp,lab1,lab2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbrop(bcstream.ssaval(ssas1),opaddress.bbindex,
                         getoppo(opaddress.opaddress)^.par.opaddress.bbindex);
{
  tmp:= '%'+inttostr(ssad);
  nextoplabel(lab1);
  oplabel(lab2);
  outass(tmp+' = icmp ne i1 %'+inttostr(ssas1)+', 0');
  outass('br i1 '+tmp+', label %'+lab1+', label %'+lab2);
  outass(lab1+':');
}
 end;
end;

procedure writelnop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_ret]),
                                             bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                                                      [bcstream.relval(0)]);
{
  outass('call i32 (i8*, ...)* @printf( i8* getelementptr ('+wretformat+
         ', i32 0, i32 0))');
}
 end;
end;

procedure writebooleanop();
begin
 notimplemented();
end;
 
procedure writeintegerop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_int32]),
                                           bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                               [bcstream.relval(0),bcstream.ssaval(ssas1)]);
{
  outass('call i32 (i8*, ...)* @printf( i8* getelementptr ('+wint32format+
         ', i32 0, i32 0), i32 %'+inttostr(ssas1)+')');
}
 end;
end;

procedure writefloatop();
begin
 notimplemented();
end;

procedure writestring8op();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_string8]),
                                           bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                               [bcstream.relval(0),bcstream.ssaval(ssas1)]);
{
  outass('call i32 (i8*, ...)* @printf( i8* getelementptr ('+wstring8format+
         ', i32 0, i32 0), i8* %'+inttostr(ssas1)+')');
}
 end;
end;

procedure writepointerop();
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.globval(internalstrings[is_pointer]),
                                           bcstream.typeval(pointertype));
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_printf]),
                               [bcstream.relval(0),bcstream.ssaval(ssas1)]);
{
  outass('call i32 (i8*, ...)* @printf( i8* getelementptr ('+wpointerformat+
         ', i32 0, i32 0), i8* %'+inttostr(ssas1)+')');
}
 end;
end;

procedure writeclassop();
begin
 notimplemented();
end;
procedure writeenumop();
begin
 notimplemented();
end;

procedure pushop();
begin
// notimplemented();
end;

procedure popop();
begin
// notimplemented();
end;

procedure pushimm1op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm8op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm16op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm32op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimm64op();
begin
 with pc^.par do begin
  bcstream.emitpushconst(imm.llvm);
 end;
end;

procedure pushimmdatakindop();
begin
 notimplemented();
end;

procedure int32toflo64op();
begin
 notimplemented();
end;

procedure potoint32op();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = ptrtoint i8* %'+inttostr(ssas1)+' to i32');
 end;
end;

procedure mulint32op();
begin
 notimplemented();
end;

procedure mulimmint32op();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = mul i32 %'+inttostr(ssas1)+
         ', '+inttostr(imm.vint32));
 end;
end;

procedure mulflo64op();
begin
 notimplemented();
end;

procedure addint32op();
begin
 outbinop(BINOP_ADD);
end;

procedure addpoint32op();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = getelementptr i8* %'+inttostr(ssas1)+
         ', i32 %'+inttostr(ssas2));
 end;
end;


procedure addimmint32op();
begin
 notimplemented();
end;
procedure addflo64op();
begin
 notimplemented();
end;
procedure negcard32op();
begin
 notimplemented();
end;
procedure negint32op();
begin
 notimplemented();
end;
procedure negflo64op();
begin
 notimplemented();
end;

procedure offsetpoimm32op();
begin
 notimplemented();
end;

procedure incdecimmint32(const adest: shortstring);
var
 str2,str3: shortstring;
begin
 with pc^.par,memimm do begin
  str2:= '%'+inttostr(ssad-1);
  str3:= '%'+inttostr(ssad);
  outass(str2+' = load i32* bitcast (i8* '+adest+' to i32*)');
  outass(str3+' = add i32 '+str2+', '+inttostr(vint32));
  outass('store i32 '+str3+', i32* bitcast (i8* '+adest+' to i32*)');
 end;
end;

procedure incdecimmpo(const adest: shortstring);
var
 str2,str3: shortstring;
begin
 with pc^.par,memimm do begin
  str2:= '%'+inttostr(ssad-1);
  str3:= '%'+inttostr(ssad);
  outass(str2+' = load i8** bitcast (i8* '+adest+' to i8**)');
  outass(str3+' = getelementptr i8* '+str2+', i32 '+inttostr(vint32));
  outass('store i8* '+str3+', i8** bitcast (i8* '+adest+' to i8**)');
 end;
end;

procedure incdecsegimmint32op();
var
 str1: shortstring;
begin
 with pc^.par,memimm do begin
  segdataaddresspo(mem.segdataaddress,true,str1);
  incdecimmint32(str1);
 end;
end;

procedure incdecsegimmpo32op();
var
 str1: shortstring;
begin
 with pc^.par,memimm do begin
  segdataaddresspo(mem.segdataaddress,true,str1);
  incdecimmpo(str1);
 end;
end;

procedure incdeclocimmint32op();
begin
 notimplemented();
end;

procedure incdeclocimmpo32op();
var
 str1,str2: shortstring;
begin
 with pc^.par,memimm do begin
  assignloc();
  bcstream.emitgetelementptr(bcstream.relval(0),bcstream.constval(llvm.listid));
{
  locdataaddress(mem.locdataaddress,str1);
  str2:= '%'+inttostr(ssad-1);
  outass(str2+' = load i8** '+str1);
  outass('%'+inttostr(ssad)+' = getelementptr i8* '+str2+
                                          ', i32 '+inttostr(vint32));
}
 end;
end;

procedure incdecparimmint32op();
begin
 notimplemented();
end;

procedure incdecparimmpo32op();
begin
 notimplemented();
end;

procedure incdecparindiimmint32op();
begin
 notimplemented();
end;

procedure incdecparindiimmpo32op();
begin
 notimplemented();
end;

procedure incdecindiimmint32op();
//var
// str1,str2,str3,str4: shortstring;
begin
 with pc^.par,memimm do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(das_32));
  bcstream.emitloadop(bcstream.relval(0));
  bcstream.emitbinop(BINOP_ADD,bcstream.relval(0),
                                  bcstream.constval(llvm.listid));
  bcstream.emitstoreop(bcstream.relval(0),bcstream.relval(2));
{
  str1:= '%'+inttostr(ssas1);
  str2:= '%'+inttostr(ssad-2);
  str3:= '%'+inttostr(ssad-1);
  str4:= '%'+inttostr(ssad);
  outass(str2+' = bitcast i8* '+str1+' to i32*');
  outass(str3+' = load i32* '+str2);
  outass(str4+' = add i32 '+str3+', '+inttostr(vint32));
  outass('store i32 '+str4+', i32* '+str2);
}
 end;
end;

procedure incdecindiimmpo32op();
var
 str1,str2,str3,str4: shortstring;
begin
 with pc^.par,memimm do begin
  str1:= '%'+inttostr(ssas1);
  str2:= '%'+inttostr(ssad-2);
  str3:= '%'+inttostr(ssad-1);
  str4:= '%'+inttostr(ssad);
  outass(str2+' = bitcast i8* '+str1+' to i8**');
  outass(str3+' = load i8** '+str2);
  outass(str4+' = getelementptr i8* '+str3+', i32 '+inttostr(vint32));
  outass('store i8* '+str4+', i8** '+str2);
 end;
end;

procedure cmpeqpoop();
begin
 notimplemented();
end;

procedure cmpeqboolop();
begin
 notimplemented();
end;

procedure cmpeqint32op();
begin
 compare(icmp_eq);
end;

procedure cmpeqflo64op();
begin
 notimplemented();
end;

procedure cmpnepoop();
begin
 compare(icmp_ne);
end;

procedure cmpneboolop();
begin
 notimplemented();
end;

procedure cmpneint32op();
begin
 compare(icmp_ne);
end;

procedure cmpneflo64op();
begin
 notimplemented();
end;

procedure cmpgtpoop();
begin
 notimplemented();
end;

procedure cmpgtboolop();
begin
 notimplemented();
end;

procedure cmpgtint32op();
begin
 compare(icmp_sgt);
end;

procedure cmpgtflo64op();
begin
 notimplemented();
end;

procedure cmpltpoop();
begin
 notimplemented();
end;

procedure cmpltboolop();
begin
 notimplemented();
end;

procedure cmpltint32op();
begin
 compare(icmp_slt);
end;

procedure cmpltflo64op();
begin
 notimplemented();
end;

procedure cmpgepoop();
begin
 notimplemented();
end;

procedure cmpgeboolop();
begin
 notimplemented();
end;

procedure cmpgeint32op();
begin
 compare(icmp_sge);
end;

procedure cmpgeflo64op();
begin
 notimplemented();
end;

procedure cmplepoop();
begin
 notimplemented();
end;

procedure cmpleboolop();
begin
 notimplemented();
end;

procedure cmpleint32op();
begin
 compare(icmp_sle);
end;

procedure cmpleflo64op();
begin
 notimplemented();
end;

procedure storesegnilop();
var
 str1: shortstring;
begin
 with pc^.par do begin
  bcstream.emitstoreop(bcstream.constval(nullpointer),
                     bcstream.globval(memop.segdataaddress.a.address));
//  segdataaddress(memop.segdataaddress,str1);
//  outass('store '+nilconst+', i8** '+str1);
 end;
end;

procedure storereg0nilop();
begin
 notimplemented();
end;
procedure storeframenilop();
begin
 notimplemented();
end;
procedure storestacknilop();
begin
 notimplemented();
end;
procedure storestackrefnilop();
begin
 notimplemented();
end;
procedure storesegnilarop();
begin
 notimplemented();
end;
procedure storeframenilarop();
begin
 notimplemented();
end;
procedure storereg0nilarop();
begin
 notimplemented();
end;
procedure storestacknilarop();
begin
 notimplemented();
end;
procedure storestackrefnilarop();
begin
 notimplemented();
end;

procedure finirefsizesegop();
//var
// str1,str2: shortstring;
begin
 with pc^.par do begin
  callcompilersub(cs_finifrefsize,false,
         [bcstream.globval(memop.segdataaddress.a.address)]);
{
  str1:= '%'+inttostr(ssad);
  segdataaddress(memop.segdataaddress,str2);
  outass(str1+' = bitcast i8** '+str2+' to i8*');
  finirefsize(str1);
}
 end;
end;

procedure finirefsizeframeop();
begin
 notimplemented();
end;
procedure finirefsizereg0op();
begin
 notimplemented();
end;
procedure finirefsizestackop();
begin
 notimplemented();
end;
procedure finirefsizestackrefop();
begin
 notimplemented();
end;
procedure finirefsizeframearop();
begin
 notimplemented();
end;
procedure finirefsizesegarop();
begin
 notimplemented();
end;
procedure finirefsizereg0arop();
begin
 notimplemented();
end;
procedure finirefsizestackarop();
begin
 notimplemented();
end;
procedure finirefsizestackrefarop();
begin
 notimplemented();
end;

procedure increfsizesegop();
begin
 notimplemented();
end;
procedure increfsizeframeop();
begin
 notimplemented();
end;
procedure increfsizereg0op();
begin
 notimplemented();
end;
procedure increfsizestackop();
begin
 notimplemented();
end;
procedure increfsizestackrefop();
begin
 notimplemented();
end;
procedure increfsizeframearop();
begin
 notimplemented();
end;
procedure increfsizesegarop();
begin
 notimplemented();
end;
procedure increfsizereg0arop();
begin
 notimplemented();
end;
procedure increfsizestackarop();
begin
 notimplemented();
end;
procedure increfsizestackrefarop();
begin
 notimplemented();
end;

procedure decrefsizesegop();
var
 str1: shortstring;
begin
 segdataaddress(pc^.par.memop.segdataaddress,str1);
 decrefsize(str1);
end;

procedure decrefsizeframeop();
begin
 notimplemented();
end;
procedure decrefsizereg0op();
begin
 notimplemented();
end;
procedure decrefsizestackop();
begin
 notimplemented();
end;
procedure decrefsizestackrefop();
begin
 notimplemented();
end;
procedure decrefsizeframearop();
begin
 notimplemented();
end;
procedure decrefsizesegarop();
begin
 notimplemented();
end;
procedure decrefsizereg0arop();
begin
 notimplemented();
end;
procedure decrefsizestackarop();
begin
 notimplemented();
end;
procedure decrefsizestackrefarop();
begin
 notimplemented();
end;

procedure popseg8op();
begin
 storeseg();
end;

procedure popseg16op();
begin
 storeseg();
end;

procedure popseg32op();
begin
 storeseg();
end;

procedure popseg64op();
begin
 storeseg();
end;

procedure popsegpoop();
var
 str1: shortstring;
begin
 with pc^.par do begin
  bcstream.emitstoreop(bcstream.ssaval(ssas1),
                     bcstream.globval(memop.segdataaddress.a.address));
{
  segdataaddress(memop.segdataaddress,str1);
  outass('store i8* %'+inttostr(ssas1)+', i8** '+str1);
}
 end;
end;

procedure popsegf16op();
begin
 storeseg();
end;

procedure popsegf32op();
begin
 storeseg();
end;

procedure popsegf64op();
begin
 storeseg();
end;

procedure popsegop();
begin
 notimplemented();
end;

procedure poploc8op();
begin
 locassign();
end;

procedure poploc16op();
begin
 locassign();
end;

procedure poploc32op();
begin
 locassign();
end;

procedure poploc64op();
begin
 locassign();
end;

procedure poplocpoop();
begin
 locassign();
end;

procedure poplocf16op();
begin
 locassign();
end;

procedure poplocf32op();
begin
 locassign();
end;

procedure poplocf64op();
begin
 locassign();
end;

procedure poplocop();
begin
 notimplemented();
end;

procedure poplocindi8op();
begin
 locassign();
end;

procedure poplocindi16op();
begin
 locassign();
end;

procedure poplocindi32op();
begin
 locassign();
end;

procedure poplocindi64op();
begin
 locassign();
end;

procedure poplocindipoop();
begin
 notimplemented();
end;

procedure poplocindif16op();
begin
 locassign();
end;

procedure poplocindif32op();
begin
 locassign();
end;

procedure poplocindif64op();
begin
 locassign();
end;

procedure poplocindiop();
begin
 notimplemented();
end;

procedure poppar8op();
begin
 parassign();
end;

procedure poppar16op();
begin
 parassign();
end;

procedure poppar32op();
begin
 parassign();
end;

procedure poppar64op();
begin
 parassign();
end;

procedure popparpoop();
begin
 notimplemented();
end;

procedure popparf16op();
begin
 parassign();
end;

procedure popparf32op();
begin
 parassign();
end;

procedure popparf64op();
begin
 parassign();
end;

procedure popparop();
begin
 notimplemented();
end;

procedure popparindi8op();
begin
 parassignindi()
end;

procedure popparindi16op();
begin
 parassignindi()
end;

procedure popparindi32op();
begin
 parassignindi()
end;

procedure popparindi64op();
begin
 parassignindi()
end;

procedure popparindipoop();
begin
 notimplemented()
end;

procedure popparindif16op();
begin
 parassignindi()
end;

procedure popparindif32op();
begin
 parassignindi()
end;

procedure popparindif64op();
begin
 parassignindi()
end;

procedure popparindiop();
begin
 notimplemented()
end;

procedure pushnilop();
begin
 with pc^.par do begin
//  bcstream.emitgetelementptr(bcstream.constval(ord(nc_i8)),
//                                                bcstream.constval(0));
  bcstream.emitbitcast(bcstream.constval(nullpointer),
                               bcstream.typeval(pointertype));
{
  outass('%'+inttostr(ssad)+' = getelementptr i8* null, i32 0')
}
 end;
end;

procedure pushsegaddressop();
begin
 notimplemented();
end;

procedure pushseg8op();
begin
 loadseg();
end;

procedure pushseg16op();
begin
 loadseg();
end;

procedure pushseg32op();
begin
 loadseg();
end;

procedure pushseg64op();
begin
 loadseg();
end;

procedure pushsegpoop();
begin
 loadseg();
end;

procedure pushsegf16op();
begin
 loadseg();
end;

procedure pushsegf32op();
begin
 loadseg();
end;

procedure pushsegf64op();
begin
 loadseg();
end;

procedure pushsegop();
begin
 loadseg();
end;

procedure pushloc8op();
begin
 assignloc();
end;

procedure pushloc16op();
begin
 assignloc();
end;

procedure pushloc32op();
begin
 assignloc();
end;

procedure pushloc64op();
begin
 assignloc();
end;

procedure pushlocpoop();
begin
 assignloc();
end;

procedure pushlocf16op();
begin
 assignloc();
end;

procedure pushlocf32op();
begin
 assignloc();
end;

procedure pushlocf64op();
begin
 assignloc();
end;

procedure pushlocop();
begin
 assignloc();
end;

procedure pushpar8op();
begin
 assignpar();
end;

procedure pushpar16op();
begin
 assignpar();
end;

procedure pushpar32op();
begin
 assignpar();
end;

procedure pushpar64op();
begin
 assignpar();
end;

procedure pushparpoop();
begin
 assignpar();
end;

procedure pushparf16op();
begin
 assignpar();
end;

procedure pushparf32op();
begin
 assignpar();
end;

procedure pushparf64op();
begin
 assignpar();
end;

procedure pushparop();
begin
 assignpar();
end;

procedure pushlocindi8op();
begin
 assignlocindi();
end;

procedure pushlocindi16op();
begin
 assignlocindi();
end;

procedure pushlocindi32op();
begin
 assignlocindi();
end;

procedure pushlocindi64op();
begin
 assignlocindi();
end;

procedure pushlocindipoop();
begin
 assignlocindi();
end;

procedure pushlocindif16op();
begin
 assignlocindi();
end;

procedure pushlocindif32op();
begin
 assignlocindi();
end;

procedure pushlocindif64op();
begin
 assignlocindi();
end;

procedure pushlocindiop();
begin
 assignlocindi();
end;

procedure pushaddrop();
begin
 notimplemented();
end;

procedure pushlocaddrop();
begin
 with pc^.par do begin
  bcstream.emitlocdataaddress(memop);
 end;
end;

procedure pushlocaddrindiop();          //todo: nested frames
//var
// str1,str2: shortstring;
begin
 with pc^.par do begin
  if memop.locdataaddress.a.framelevel >= 0 then begin
   notimplemented();
  end;
  bcstream.emitloadop(bcstream.allocval(memop.locdataaddress.a.address));
  bcstream.emitgetelementptr(bcstream.relval(0),
                bcstream.constval(memop.locdataaddress.offset));
{
  locdataaddress(vlocaddress,str1);
  str2:= '%'+inttostr(ssad-1);
  outass(str2+' = load i8** '+str1);
  outass('%'+inttostr(ssad)+' = getelementptr i8* '+str2+
                                ', i32 '+inttostr(vlocaddress.offset));
}
 end;
end;

procedure pushsegaddrop();
var
 str1: shortstring;
begin
 with pc^.par do begin
  bcstream.emitsegdataaddress(memop);
 {
  segdataaddresspo(memop.segdataaddress,false,str1);
  outass('%'+inttostr(ssad)+' = '+str1);
 }
 end;
end;

procedure pushsegaddrindiop();
//var
// str1,str2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitloadop(bcstream.globval(memop.segdataaddress.a.address));
  bcstream.emitgetelementptr(bcstream.relval(0),
                bcstream.constval(memop.segdataaddress.offset));
{
  segdataaddress(memop.segdataaddress,str1);
  str2:= '%'+inttostr(ssad-1);
  outass(str2+' = load i8** '+str1);
  outass('%'+inttostr(ssad)+' = getelementptr i8* '+str2+', i32 '+
                                          inttostr(memop.segdataaddress.offset));
}
 end;
end;

procedure pushstackaddrop();
begin
 notimplemented();
end;
procedure pushstackaddrindiop();
begin
 notimplemented();
end;

procedure indirect8op();
begin
 assignindirect();
end;

procedure indirect16op();
begin
 assignindirect();
end;

procedure indirect32op();
begin
 assignindirect();
end;

procedure indirect64op();
begin
 assignindirect();
end;

procedure indirectpoop();
var
 dest1,dest2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitloadop(bcstream.relval(0));
{
  dest1:= '%'+inttostr(ssad-1);
  dest2:= '%'+inttostr(ssad);
  outass(dest1+' = bitcast i8* %'+inttostr(ssas1)+
                          ' to i8**');
  outass(dest2+' = load i8** '+dest1);
}
 end;
end;

procedure indirectf16op();
begin
 assignindirect();
end;

procedure indirectf32op();
begin
 assignindirect();
end;

procedure indirectf64op();
begin
 assignindirect();
end;

procedure indirectpooffsop();
var
 str1,str2: shortstring;
begin //offset after indirect
 with pc^.par do begin
  str1:= '%'+inttostr(ssad-2);
  str2:= '%'+inttostr(ssad-1);
  outass(str1+' = bitcast i8* %'+inttostr(ssas1)+' to i8**');
  outass(str2+' = load i8** '+str1);
  outass('%'+inttostr(ssad)+' = getelementptr i8* '+str2+', i32 '+
                                                        inttostr(voffset));
 end;
end; 

procedure indirectoffspoop();
begin
 notimplemented();
end; //offset before indirect
procedure indirectop();
begin
 notimplemented();
end;

procedure popindirect();
//var
// str1,str2: shortstring;
begin
 with pc^.par do begin
  bcstream.emitbitcast(bcstream.ssaval(ssas2),
                              bcstream.ptypeval(memop.t.listindex));
  bcstream.emitstoreop(bcstream.ssaval(ssas1),bcstream.relval(0));
{
  str1:= '%'+inttostr(ssad);
  llvmtype(memop.t,str2);
  outass(str1+' = bitcast i8* %'+inttostr(ssas2)+' to '+str2+'*');
  outass('store '+str2+' %'+inttostr(ssas1)+', '+str2+'* '+str1);
}
 end;
end;

procedure popindirect8op();
begin
 popindirect();
end;

procedure popindirect16op();
begin
 popindirect();
end;

procedure popindirect32op();
begin
 popindirect();
end;

procedure popindirect64op();
begin
 popindirect();
end;

procedure popindirectpoop();
begin
 popindirect();
end;

procedure popindirectf16op();
begin
 popindirect();
end;

procedure popindirectf32op();
begin
 popindirect();
end;

procedure popindirectf64op();
begin
 popindirect();
end;

procedure popindirectop();
begin
 popindirect();
end;

procedure dooutlink(const outlinkcount: integer);
var
 i1: int32;
begin
 with pc^.par do begin
  if (outlinkcount > 0) and (sf_hasnestedaccess in callinfo.flags) then begin
   bcstream.emitgetelementptr(bcstream.subval(0),
                     bcstream.constval(nullpointeroffset)); //nested vars
   for i1:= outlinkcount-2 downto 0 do begin;
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitloadop(bcstream.relval(0));
   end;
  end;
 end;
end;

{
procedure dooutlink(const outlinkcount: integer);
var
 ssa1: integer;
 int1: integer;
 str1,str2: shortstring;
 po1,po2,po3: pshortstring;
begin
 with pc^.par do begin
  if (outlinkcount > 0) and (sf_hasnestedaccess in callinfo.flags) then begin
   ssa1:= ssad-outlinkcount*2;
   str1:= '%'+inttostr(ssa1);
   inc(ssa1);
   str2:= '%'+inttostr(ssa1);
   inc(ssa1);
   outass(str1+' = add i32 0, 0'); //dummy
   outass(str2+' = bitcast i8** %fp to i8**');
   po2:= @str1;
   po1:= @str2;
   for int1:= outlinkcount-2 downto 0 do begin;
    po3:= po1;
    po1:= po2;
    po2:= po3;    //swap strings
    po1^:= '%'+inttostr(ssa1);
    inc(ssa1);
    outass(po1^+' = load i8** '+po2^);
    po2^:= '%'+inttostr(ssa1);
    inc(ssa1);
    outass(po2^+' = bitcast i8* '+po1^+' to i8**');
   end;
  end;
 end;
end;
}
{
procedure docallparam(parpo: pparallocinfoty; const endpo: pointer;
                      const outlinkcount: integer);
var
 first: boolean;
 int1: integer;
 str1,str2: shortstring;
begin
 with pc^.par do begin
  first:= true;
  if sf_hasnestedaccess in callinfo.flags then begin
   if outlinkcount > 0 then begin
    int1:= ssad-1;
//    if sf_function in callinfo.flags then begin
//     dec(int1);
//    end;
    outass(' i8** %'+inttostr(int1));
   end
   else begin
    outass(' i8** %f');
   end;
   first:= false;
  end;
  while parpo < endpo do begin
   llvmtype(parpo^.size,str2);
   str1:= ','+str2+' %'+inttostr(parpo^.ssaindex);
   if first then begin
    str1[1]:= ' ';
    first:= false;
   end;
   outass(str1);
   inc(parpo);
  end;
  outass(')');
 end;
end;
}
procedure docallparam(const outlinkcount: int32; var ids: idarty);
var
 parpo,endpo: pparallocinfoty;
 po1: pint32;
begin
 with pc^.par do begin
  ids.count:= callinfo.paramcount;
  po1:= ids.ids;
  if sf_hasnestedaccess in callinfo.flags then begin
   if outlinkcount > 0 then begin
    po1^:= bcstream.relval(0);
   end
   else begin
    po1^:= bcstream.ssaval(-1); //last alloc is nested var ref table
   end;
   inc(po1);
   inc(ids.count);
  end;
 {$ifdef mse_checkinternalerror}
  if ids.count >= high(idsarty) then begin
   internalerror(ie_llvm,'20150122');
  end;
 {$endif}
  parpo:= getsegmentpo(seg_localloc,callinfo.params);
  endpo:= parpo + callinfo.paramcount;  
  if sf_function in callinfo.flags then begin
   inc(parpo);            //skip result param
   dec(ids.count);
  end;
  while parpo < endpo do begin
   po1^:= bcstream.ssaval(parpo^.ssaindex);
   inc(po1);
   inc(parpo);
  end;
 end;
end;

procedure docall(const outlinkcount: integer);
var
 ids: idsarty;
 idar: idarty;
begin
 with pc^.par do begin               //todo: calling convention
  idar.ids:= @ids;
  docallparam(outlinkcount,idar);
  bcstream.emitcallop(sf_function in callinfo.flags,
      bcstream.globval(getoppo(callinfo.ad+1)^.par.subbegin.globid),idar);
 end;
end;
{
procedure docallfunc(const outlinkcount: integer);
var
 parpo: pparallocinfoty;
 endpo: pointer;
 first: boolean;
 str1: shortstring;
begin
 with pc^.par do begin
  parpo:= getsegmentpo(seg_localloc,callinfo.params);
  endpo:= parpo + callinfo.paramcount;
  llvmtype(parpo^.size,str1);
  outass('%'+inttostr(ssad)+' = call '+str1+
                                     ' @s'+inttostr(callinfo.ad+1)+'(');
  inc(parpo); //skip result param
  docallparam(parpo,endpo,outlinkcount);
 end;
end;
}
procedure callop();
begin
 with pc^.par do begin
  docall(0);
 end;
end;

procedure callfuncop();
begin
 with pc^.par do begin
  docall(0);
 end;
end;

procedure calloutop();
var
 int1: integer;
begin
 with pc^.par do begin
  int1:= callinfo.linkcount+2;
  dooutlink(int1);
  docall(int1);
 end;
end;

procedure callfuncoutop();
var
 int1: integer;
begin
 with pc^.par do begin
  int1:= callinfo.linkcount+2;
  dooutlink(int1);
  docall(int1);
 end;
end;

procedure callvirtop();
begin
 notimplemented();
end;
procedure callintfop();
begin
 notimplemented();
end;
procedure virttrampolineop();
begin
 notimplemented();
end;

procedure locvarpushop();
begin
 //dummy
end;

procedure locvarpopop();
begin
 //dummy
end;

procedure subbeginop();
var
 po1: plocallocinfoty;
 po2: pnestedallocinfoty;
 i1,i2: int32;
 poend: pointer;
begin
 with pc^.par.subbegin do begin
  bcstream.beginsub(flags,allocs,blockcount);
  po1:= getsegmentpo(seg_localloc,allocs.allocs);
  poend:= po1 + allocs.alloccount;
  while po1 < poend do begin
   bcstream.emitalloca(bcstream.ptypeval(po1^.size));
   inc(po1);
  end;
  i2:= 0;
  if sf_function in flags then begin
   i2:= 1; //skip result param
  end;
  for i1:= i2 to allocs.paramcount-1 do begin
   bcstream.emitstoreop(bcstream.paramval(i1),bcstream.allocval(i1));
  end;
  if allocs.nestedalloccount > 0 then begin
   bcstream.emitalloca(bcstream.ptypeval(allocs.nestedallocstypeindex));
   if sf_hascallout in flags then begin
    bcstream.emitgetelementptr(bcstream.subval(0),constlist.i8(0)); 
                                        //param parent nested var,source
    bcstream.emitgetelementptr(bcstream.ssaval(0),nullpointeroffset);
                                                  //nested var array,dest
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitstoreop(bcstream.relval(3),bcstream.relval(0));
   end;
   po2:= getsegmentpo(seg_localloc,allocs.nestedallocs);
   poend:= po2+allocs.nestedalloccount;
   i1:= 1;
   while po2 < poend do begin
    if po2^.address.nested then begin
     bcstream.emitgetelementptr(bcstream.subval(0),po2^.address.arrayoffset);
                              //pointer to parent nestedvars, 2 ssa
     bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
     bcstream.emitloadop(bcstream.relval(0));                       //source
    end
    else begin
     bcstream.emitbitcast(bcstream.allocval(po2^.address.origin),
                                    bcstream.typeval(das_pointer)); //source
    end;
    bcstream.emitgetelementptr(bcstream.ssaval(0),
                                 constlist.pointeroffset(i1)); //dest
                        //pointer to nestedallocs
    bcstream.emitbitcast(bcstream.relval(0),bcstream.ptypeval(das_pointer));
    bcstream.emitstoreop(bcstream.relval(3),bcstream.relval(0));
    inc(po2);
    inc(i1);
   end;
   bcstream.emitbitcast(bcstream.allocval(allocs.alloccount),
                                               bcstream.typeval(das_pointer));
                                 //pointer to nestedallocs
   bcstream.resetssa();
  end;
 end;
end;

procedure subendop();
begin
 with pc^.par.subend do begin
//  bcstream.emitretop(); //todo: function
  bcstream.endsub();
//  outass('}');
 end;
end;

procedure returnop();
begin
 bcstream.emitretop();
 //dummy
// bcstream.emitretop();
// outass('ret void');
end;

procedure returnfuncop();
var
 po1: plocallocinfoty;
 ty1: shortstring;
 dest1: shortstring;
begin
 with pc^.par do begin
  bcstream.emitloadop(bcstream.allocval(0));
  bcstream.emitretop(bcstream.relval(0));
  
{
  po1:= getsegmentpo(seg_localloc,returnfuncinfo.allocs.allocs);
  llvmtype(po1^.size,ty1);
  dest1:= '%'+inttostr(ssad);
  outass(dest1 + ' = load '+ty1+'* %l0');
  outass('ret '+ty1+' '+dest1);
}
 end;
end;

procedure initclassop();
begin
 notimplemented();
end;
procedure destroyclassop();
begin
 notimplemented();
end;

procedure decloop32op();
begin
 notimplemented();
end;
procedure decloop64op();
begin
 notimplemented();
end;

procedure setlengthstr8op();
begin
 notimplemented();
end;

procedure setlengthdynarrayop();
begin
 notimplemented();
end;

procedure raiseop();
begin
 notimplemented();
end;
procedure pushcpucontextop();
begin
 notimplemented();
end;
procedure popcpucontextop();
begin
 notimplemented();
end;
procedure finiexceptionop();
begin
 notimplemented();
end;

procedure continueexceptionop();
begin
 notimplemented();
end;

procedure getmemop();
//var
// str1,str2,str3: shortstring;
begin
 with pc^.par do begin
  bcstream.emitcallop(true,bcstream.globval(internalfuncs[if_malloc]),
                                                    [bcstream.ssaval(ssas2)]);
  bcstream.emitbitcast(bcstream.ssaval(ssas1),bcstream.ptypeval(pointertype));
  bcstream.emitstoreop(bcstream.relval(1),bcstream.relval(0));
{
  llvmtype(memop.t,str1);
  str2:= '%'+inttostr(ssad-1);
  str3:= '%'+inttostr(ssad);
  outass(str2+' = call i8* @malloc('+str1+' %'+inttostr(ssas2)+')');
  outass(str3+' = bitcast i8* '+'%'+inttostr(ssas1)+' to i8**');
  outass('store i8* '+str2+', i8** '+str3);
}
 end;
end;

procedure freememop();
begin
 with pc^.par do begin
  bcstream.emitcallop(false,bcstream.globval(internalfuncs[if_free]),
                                                    [bcstream.ssaval(ssas1)]);
{
  outass('call void @free(i8* %'+inttostr(ssas1)+')');
}
 end;
end;

procedure lineinfoop();
begin
 with pc^.par.lineinfo do begin
{$ifndef mse_llvmbc}
  outass(';'+inttostr(nr+1)+':'+lstringtostring(line)); //todo: optimize
{$endif}
 end;
end;

const
  nonessa = 0;
  nopssa = 1;
  labelssa = 0;

  beginparsessa = 0;
  mainssa = 0;//1;
  progendssa = 0;  
  endparsessa = 0;

  movesegreg0ssa = 1;
  moveframereg0ssa = 1;
  popreg0ssa = 1;
  increg0ssa = 1;

  gotossa = 0;
  cmpjmpneimm4ssa = 1;
  cmpjmpeqimm4ssa = 1;
  cmpjmploimm4ssa = 1;
  cmpjmpgtimm4ssa = 1;
  cmpjmploeqimm4ssa = 1;

  ifssa = 0;
  writelnssa = 1;
  writebooleanssa = 1;
  writeintegerssa = 1;
  writefloatssa = 1;
  writestring8ssa = 1;
  writepointerssa = 1;
  writeclassssa = 1;
  writeenumssa = 1;

  pushssa = 0; //dummy
  popssa = 0;  //dummy

  pushimm1ssa = 1;
  pushimm8ssa = 1;
  pushimm16ssa = 1;
  pushimm32ssa = 1;
  pushimm64ssa = 1;
  pushimmdatakindssa = 1;
  
  int32toflo64ssa = 1;
  potoint32ssa = 1;
  
  negcard32ssa = 1;
  negint32ssa = 1;
  negflo64ssa = 1;

  mulint32ssa = 1;
  mulflo64ssa = 1;
  addint32ssa = 1;
  addpoint32ssa = 1;
  addflo64ssa = 1;

  addimmint32ssa = 1;
  mulimmint32ssa = 1;
  offsetpoimm32ssa = 1;

  incdecsegimmint32ssa = 2;
  incdecsegimmpo32ssa = 2;

  incdeclocimmint32ssa = 2;
  incdeclocimmpo32ssa = 2;

  incdecparimmint32ssa = 2;
  incdecparimmpo32ssa = 2;

  incdecparindiimmint32ssa = 2;
  incdecparindiimmpo32ssa = 2;

  incdecindiimmint32ssa = 3;
  incdecindiimmpo32ssa = 3;

  cmpeqpossa = 1;
  cmpeqboolssa = 1;
  cmpeqint32ssa = 1;
  cmpeqflo64ssa = 1;

  cmpnepossa = 1;
  cmpneboolssa = 1;
  cmpneint32ssa = 1;
  cmpneflo64ssa = 1;

  cmpgtpossa = 1;
  cmpgtboolssa = 1;
  cmpgtint32ssa = 1;
  cmpgtflo64ssa = 1;

  cmpltpossa = 1;
  cmpltboolssa = 1;
  cmpltint32ssa = 1;
  cmpltflo64ssa = 1;

  cmpgspossa = 1;
  cmpgsboolssa = 1;
  cmpgsint32ssa = 1;
  cmpgsflo64ssa = 1;

  cmplspossa = 1;
  cmplsboolssa = 1;
  cmplsint32ssa = 1;
  cmplsflo64ssa = 1;

  storesegnilssa = 1;
  storereg0nilssa = 1;
  storeframenilssa = 1;
  storestacknilssa = 1;
  storestackrefnilssa = 1;
  storesegnilarssa = 1;
  storeframenilarssa = 1;
  storereg0nilarssa = 1;
  storestacknilarssa = 1;
  storestackrefnilarssa = 1;

  finirefsizesegssa = 1;
  finirefsizeframessa = 1;
  finirefsizereg0ssa = 1;
  finirefsizestackssa = 1;
  finirefsizestackrefssa = 1;
  finirefsizeframearssa = 1;
  finirefsizesegarssa = 1;
  finirefsizereg0arssa = 1;
  finirefsizestackarssa = 1;
  finirefsizestackrefarssa = 1;

  increfsizesegssa = 1;
  increfsizeframessa = 1;
  increfsizereg0ssa = 1;
  increfsizestackssa = 1;
  increfsizestackrefssa = 1;
  increfsizeframearssa = 1;
  increfsizesegarssa = 1;
  increfsizereg0arssa = 1;
  increfsizestackarssa = 1;
  increfsizestackrefarssa = 1;

  decrefsizesegssa = 1;
  decrefsizeframessa = 1;
  decrefsizereg0ssa = 1;
  decrefsizestackssa = 1;
  decrefsizestackrefssa = 1;
  decrefsizeframearssa = 1;
  decrefsizesegarssa = 1;
  decrefsizereg0arssa = 1;
  decrefsizestackarssa = 1;
  decrefsizestackrefarssa = 1;

  popseg8ssa = 0;
  popseg16ssa = 0;
  popseg32ssa = 0;
  popseg64ssa = 0;
  popsegpossa = 0;
  popsegf16ssa = 0;
  popsegf32ssa = 0;
  popsegf64ssa = 0;
  popsegssa = 0;

  poploc8ssa = 0;
  poploc16ssa = 0;
  poploc32ssa = 0;
  poploc64ssa = 0;
  poplocpossa = 0;
  poplocf16ssa = 0;
  poplocf32ssa = 0;
  poplocf64ssa = 0;
  poplocssa = 0;

  poplocindi8ssa = 2;
  poplocindi16ssa = 2;
  poplocindi32ssa = 2;
  poplocindi64ssa = 2;
  poplocindipossa = 2;
  poplocindif16ssa = 2;
  poplocindif32ssa = 2;
  poplocindif64ssa = 2;
  poplocindissa = 2;

  poppar8ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar16ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar32ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar64ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparpossa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparf16ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparf32ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparf64ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};

  popparindi8ssa = 2;
  popparindi16ssa = 2;
  popparindi32ssa = 2;
  popparindi64ssa = 2;
  popparindipossa = 2;
  popparindif16ssa = 2;
  popparindif32ssa = 2;
  popparindif64ssa = 2;
  popparindissa = 2;

  pushnilssa = 1;
  pushsegaddressssa = 1;

  pushseg8ssa = 1;
  pushseg16ssa = 1;
  pushseg32ssa = 1;
  pushseg64ssa = 1;
  pushsegpossa = 1;
  pushsegf16ssa = 1;
  pushsegf32ssa = 1;
  pushsegf64ssa = 1;
  pushsegssa = 1;

  pushloc8ssa = 1;
  pushloc16ssa = 1;
  pushloc32ssa = 1;
  pushloc64ssa = 1;
  pushlocpossa = 1;
  pushlocf16ssa = 1;
  pushlocf32ssa = 1;
  pushlocf64ssa = 1;
  pushlocssa = 1;

  pushlocindi8ssa = 3;
  pushlocindi16ssa = 3;
  pushlocindi32ssa = 3;
  pushlocindi64ssa = 3;
  pushlocindipossa = 3;
  pushlocindif16ssa = 3;
  pushlocindif32ssa = 3;
  pushlocindif64ssa = 3;
  pushlocindissa = 3;

  pushpar8ssa = 1;
  pushpar16ssa = 1;
  pushpar32ssa = 1;
  pushpar64ssa = 1;
  pushparpossa = 1;
  pushparf16ssa = 1;
  pushparf32ssa = 1;
  pushparf64ssa = 1;
  pushparssa = 1;

  pushaddrssa = 1;
  pushlocaddrssa = 2;
  pushlocaddrindissa = 3;
  pushsegaddrssa = 2;
  pushsegaddrindissa = 3;
  pushstackaddrssa = 1;
  pushstackaddrindissa = 1;

  indirect8ssa = 2;
  indirect16ssa = 2;
  indirect32ssa = 2;
  indirect64ssa = 2;
  indirectpossa = 2;
  indirectf16ssa = 2;
  indirectf32ssa = 2;
  indirectf64ssa = 2;
  indirectpooffsssa = 3;
  indirectoffspossa = 1;
  indirectssa = 1;

  popindirect8ssa = 1;
  popindirect16ssa = 1;
  popindirect32ssa = 1;
  popindirect64ssa = 1;
  popindirectpossa = 1;
  popindirectf16ssa = 1;
  popindirectf32ssa = 1;
  popindirectf64ssa = 1;
  popindirectssa = 1;

  callssa = 0;
  callfuncssa = 1;
  calloutssa = 0;
  callfuncoutssa = 1;
  callvirtssa = 1;
  callintfssa = 1;
  virttrampolinessa = 1;

  locvarpushssa = 0; //dummy
  locvarpopssa = 0;  //dummy

  subbeginssa = 0; //1;
  subendssa = 0;
  returnssa = 0;
  returnfuncssa = 1;

  initclassssa = 1;
  destroyclassssa = 1;

  decloop32ssa = 1;
  decloop64ssa = 1;

  setlengthstr8ssa = 1;
  setlengthdynarrayssa = 1;

  raisessa = 1;
  pushcpucontextssa = 1;
  popcpucontextssa = 1;
  finiexceptionssa = 1;
  continueexceptionssa = 1;
  getmemssa = 2;
  freememssa = 0;
  
  lineinfossa = 0;

//ssa only
  nestedvarssa = 5;
  popnestedvarssa = 5;
  popsegaggregatessa = 3;
  pushnestedvarssa = 5;
  pushsegaggregatessa = 3;
  allocssa = 1;
  nestedcalloutssa = 2;
  hascalloutssa = 1;

{$include optable.inc}

procedure run(const atarget: 
           {$ifdef mse_llvmbc}tllvmbcwriter{$else}ttextstream{$endif});
var
 endpo: pointer;
 lab: shortstring;
begin
{$ifdef mse_llvmbc}
 bcstream:= atarget;
{$else}
 assstream:= atarget;
{$endif}
 pc:= getsegmentbase(seg_op);
 endpo:= pointer(pc)+getsegmentsize(seg_op);
 inc(pc,startupoffset);
 while pc < endpo do begin
 {
  if opf_label in pc^.op.flags then begin
   curoplabel(lab);
   outass('br label %'+lab);
   outass(lab+':');
  end;
  }
  optable[pc^.op.op]();
  inc(pc);
 end;
end;

function getoptable: poptablety;
begin
 result:= @optable;
end;

function getssatable: pssatablety;
begin
 result:= @ssatable;
end;

finalization
// freeandnil(assstream);
end.
