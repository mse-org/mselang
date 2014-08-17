{ MSElang Copyright (c) 2014 by Martin Schreiber
   
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
 opglob,parserglob;

//todo: generate bitcode, use static string buffers
 
function getoptable: poptablety;
function getssatable: pssatablety;
//procedure allocproc(const asize: integer; var address: segaddressty);

procedure run();
 
implementation
uses
 sysutils,msestream,msesys,segmentutils,handlerglob,elements;

type
 icomparekindty = (ick_eq,ick_ne,
                  ick_ugt,ick_uge,ick_ult,ick_ule,
                  ick_sgt,ick_sge,ick_slt,ick_sle);

const
 icomparetokens: array[icomparekindty] of string[3] = (
                  'eq','ne',
                  'ugt','uge','ult','ule',
                  'sgt','sge','slt','sle');
 ptrintname = 'i32';
                   
var
// sp: integer; //unnamed variables
 pc: popinfoty;

var
 assstream: ttextstream;

procedure outass(const atext: string);
begin
 assstream.writeln(atext);
end;

procedure outbinop(const atext: string);
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = '+atext+
   ' %'+inttostr(ssas1)+', %'+inttostr(ssas2));
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
               
function segdataaddress(const address: segdataaddressty): string;
begin
 result:= segprefix[address.a.segment]+inttostr(address.a.address);
end;

function segaddress(const address: segaddressty): string;
begin
 result:= segprefix[address.segment]+inttostr(address.address);
end;

function locaddress(const address: dataoffsty): string;
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

function paraddress(const address: dataoffsty): string;
begin
{$ifdef mse_locvarssatracking}
 result:= '%l'+inttostr(address.address);
{$else}
 result:= '%p'+inttostr(address);
{$endif}
end;

function locdataaddress(const address: locdataaddressty): string;
begin
 result:= locaddress(address.a.address);
end;

procedure curoplabel(var avalue: shortstring);
begin
 avalue:= 'o'+
    inttostr((pointer(pc)-getsegmentbase(seg_op)) div sizeof(opinfoty) -
                                                             startupoffset);
end;

procedure nextoplabel(var avalue: shortstring);
begin
 avalue:= 'o'+
    inttostr((pointer(pc)-getsegmentbase(seg_op)) div sizeof(opinfoty)- 
                                                            startupoffset+1);
end;

procedure oplabel(var avalue: shortstring);
begin
 avalue:= 'o'+ inttostr(pc^.par.opaddress);
end;

procedure stackimmassign1();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i1 '+ inttostr(imm.vint8)+' ,0');
 end;
end;

procedure stackimmassign8();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
                                                inttostr(imm.vint8)+' ,0');
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
  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
                                                inttostr(imm.vint32)+' ,0');
 end;
end;

procedure stackimmassign64();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i'+inttostr(imm.datasize*8)+' '+
                                                inttostr(imm.vint64)+' ,0');
 end;
end;

{
procedure segassign32(const ssaindex: integer; const dest: segdataaddressty);
begin
 outass('store i32 %'+inttostr(ssaindex)+', i32* '+segdataaddress(dest));
end;
}
procedure segassign();
begin
 with pc^.par do begin
  outass('store i'+inttostr(memop.datacount)+
  ' %'+inttostr(ssas1)+', i'+inttostr(memop.datacount)+'* '+
                                         segdataaddress(memop.segdataaddress));
 end;
end;

procedure assignseg();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = load i'+inttostr(memop.datacount)+
                               '* '+segdataaddress(memop.segdataaddress));
 end;
end;
{
procedure assignseg32(const ssaindex: integer; const dest: segdataaddressty);
begin
 outass('%'+inttostr(ssaindex)+' = load i32* '+segdataaddress(dest));
end;
}
procedure locassign();
var
 str1,str2,str3,str4,str5: shortstring;
begin
 with pc^.par do begin
  str1:= 'i'+inttostr(memop.datacount);
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
var
 dest1,dest2: shortstring;
begin
 with pc^.par do begin
  dest1:= '%'+inttostr(ssad);
  dest2:= '%'+inttostr(ssad+1);
  outass(dest1+' = inttoptr '+ptrintname+' %'+inttostr(ssas1)+
                         ' to i'+inttostr(memop.datacount)+'*');
  outass(dest2+' = load i'+inttostr(memop.datacount)+'* '+dest1);
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
 dest1,dest2: shortstring;
begin
 with pc^.par do begin                  //todo: add offset, nested frame
  dest1:= '%'+inttostr(ssad);
  dest2:= '%'+inttostr(ssad+1);
  outass(dest1+' = load '+ptrintname+
                               '* '+locdataaddress(memop.locdataaddress));
  outass(dest2+' = inttoptr '+ptrintname+' '+dest1+' to i32*');
  outass('store i'+inttostr(memop.datacount)+' %'+inttostr(ssas1)+
                             ', i'+inttostr(memop.datacount)+'* '+dest2);
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
var
 str1,str2,str3,str4,str5: shortstring;
begin
 with pc^.par do begin
  str1:= 'i'+inttostr(memop.datacount);
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
   outass(str2+' = load '+str1+'* '+locdataaddress(memop.locdataaddress));
  end;
 end;
end;

procedure assignlocindi();
var
 dest1,dest2,dest3: shortstring;
begin
 with pc^.par do begin
  dest1:= '%'+inttostr(ssad);
  dest2:= '%'+inttostr(ssad+1);
  dest3:= '%'+inttostr(ssad+2);
  outass(dest1+' = load '+ptrintname+
                               '* '+locdataaddress(memop.locdataaddress));
  outass(dest2+' = inttoptr '+ptrintname+' '+dest1+' to i32*');
  outass(dest3+' = load i'+inttostr(memop.datacount)+'* '+dest2);
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

procedure icompare(const akind: icomparekindty);
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = icmp '+icomparetokens[akind]+
                   ' i'+inttostr(stackop.databitsize)+
                               ' %'+inttostr(ssas1)+', %'+inttostr(ssas2));  
 end;
end;

procedure nopop();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = add i1 0, 0');
 end;
end;

var
 exitcodeaddress: segaddressty;
  
procedure beginparseop();
var
// endpo: pointer;
// allocpo: pgloballocinfoty;
 ele1,ele2: elementoffsetty;
 po1: punitdataty;
 po2: pvardataty;
 int1: integer;
begin
 freeandnil(assstream);
 assstream:= ttextstream.create('test.ll',fm_create);
 with pc^.par.beginparse do begin
  ele1:= unitinfochain;
  while ele1 <> 0 do begin
   po1:= ele.eledataabs(ele1);
   ele2:= po1^.varchain;
   while ele2 <> 0 do begin
    po2:= ele.eledataabs(ele2);
    if po2^.address.indirectlevel > 0 then begin
     int1:= pointerbitsize;
    end
    else begin
     int1:= ptypedataty(ele.eledataabs(po2^.vf.typ))^.bitsize;
    end;
    outass(segaddress(po2^.address.segaddress)+' = global i'+
                                              inttostr(int1)+ ' 0');
    ele2:= po2^.vf.next;
   end;
   ele1:= po1^.next;
  end;
  llvmops.exitcodeaddress:= exitcodeaddress;
 {
  allocpo:= getsegmentpo(globallocstart);
  endpo:= pointer(allocpo)+globalloccount*sizeof(globallocinfoty);
  llvmops.exitcodeaddress:= exitcodeaddress;
  while allocpo < endpo do begin
   with allocpo^ do begin
    outass(segaddress(a)+' = global i'+
                                              inttostr(8*size)+ ' 0');
   end;
   inc(allocpo);
  end;
 }
 end;
end;

procedure mainop();
begin
 outass('define i32 @main() {');
// info.ssaindex:= 1;
end;

procedure progendop();
begin
 outass('%.exitcode = load i32* '+segaddress(exitcodeaddress));
 outass('ret i32 %.exitcode');
 outass('}');
end;

procedure endparseop();
begin
 freeandnil(assstream);
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
var
 lab: shortstring;
begin
 oplabel(lab);
 outass('br label %'+lab);
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
var
 tmp,lab1,lab2: shortstring;
begin
 with pc^.par do begin
  tmp:= '%'+inttostr(ssad);
  nextoplabel(lab1);
  oplabel(lab2);
  outass(tmp+' = icmp ne i1 %'+inttostr(ssas1)+', 0');
  outass('br i1 '+tmp+', label %'+lab1+', label %'+lab2);
  outass(lab1+':');
 end;
end;

procedure writelnop();
begin
 notimplemented();
end;
procedure writebooleanop();
begin
 notimplemented();
end;
procedure writeintegerop();
begin
 notimplemented();
end;
procedure writefloatop();
begin
 notimplemented();
end;
procedure writestring8op();
begin
 notimplemented();
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
 stackimmassign1();
end;

procedure pushimm8op();
begin
 stackimmassign8();
end;

procedure pushimm16op();
begin
 stackimmassign16();
end;

procedure pushimm32op();
begin
 stackimmassign32();
end;

procedure pushimm64op();
begin
 stackimmassign64();
end;

procedure pushimmdatakindop();
begin
 notimplemented();
end;

procedure int32toflo64op();
begin
 notimplemented();
end;
procedure mulint32op();
begin
 notimplemented();
end;
procedure mulimmint32op();
begin
 notimplemented();
end;
procedure mulflo64op();
begin
 notimplemented();
end;

procedure addint32op();
begin
 outbinop('add i32');
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

procedure cmpequboolop();
begin
 notimplemented();
end;

procedure cmpequint32op();
begin
 icompare(ick_eq);
end;

procedure cmpequflo64op();
begin
 notimplemented();
end;

procedure storesegnilop();
begin
 notimplemented();
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
begin
 notimplemented();
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
begin
 notimplemented();
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
 segassign();
end;

procedure popseg16op();
begin
 segassign();
end;

procedure popseg32op();
begin
 segassign();
end;

procedure popsegop();
begin
 segassign();
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

procedure poplocop();
begin
 locassign();
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

procedure poplocindiop();
begin
 locassign();
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

procedure popparop();
begin
 parassign();
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

procedure popparindiop();
begin
 parassignindi()
end;

procedure pushnilop();
begin
 notimplemented();
end;
procedure pushsegaddressop();
begin
 notimplemented();
end;

procedure pushseg8op();
begin
 assignseg();
end;

procedure pushseg16op();
begin
 assignseg();
end;

procedure pushseg32op();
begin
 assignseg();
end;

procedure pushsegop();
begin
 assignseg();
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

procedure pushlocpoop();
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

procedure pushparpoop();
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
 notimplemented();
end;

procedure pushlocaddrindiop();          //todo: offset, nested frames
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = load '+ptrintname+'* '+
                                 locdataaddress(vlocaddress));
 end;
end;

procedure pushsegaddrop();
begin
 with pc^.par do begin
  outass('%'+inttostr(ssad)+' = ptrtoint i32* '+
                      segdataaddress(vsegaddress)+' to '+ptrintname);
 end;
end;

procedure pushsegaddrindiop();
begin
 notimplemented();
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

procedure indirectpoop();
begin
 assignindirect();
end;

procedure indirectpooffsop();
begin
 notimplemented();
end; //offset after indirect
procedure indirectoffspoop();
begin
 notimplemented();
end; //offset before indirect
procedure indirectop();
begin
 notimplemented();
end;

procedure popindirect8op();
begin
 notimplemented();
end;
procedure popindirect16op();
begin
 notimplemented();
end;
procedure popindirect32op();
begin
 notimplemented();
end;
procedure popindirectop();
begin
 notimplemented();
end;

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

procedure docallparam(parpo: pparallocinfoty; const endpo: pointer;
                      const outlinkcount: integer);
var
 first: boolean;
 int1: integer;
 str1: shortstring;
begin
 with pc^.par do begin
  first:= true;
  if sf_hasnestedaccess in callinfo.flags then begin
   if outlinkcount > 0 then begin
    int1:= ssad-1;
    if sf_function in callinfo.flags then begin
     dec(int1);
    end;
    outass(' i8** %'+inttostr(int1));
   end
   else begin
    outass(' i8** %f');
   end;
   first:= false;
  end;
  while parpo < endpo do begin
   str1:= ',i'+inttostr(parpo^.bitsize)+' %'+inttostr(parpo^.ssaindex);
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

procedure docall(const outlinkcount: integer);
var
 parpo: pparallocinfoty;
 endpo: pointer;
begin
 with pc^.par do begin
  parpo:= getsegmentpo(seg_localloc,callinfo.params);
  endpo:= parpo + callinfo.paramcount;
  outass('call void @s'+inttostr(callinfo.ad+1)+'(');
  docallparam(parpo,endpo,outlinkcount);
 end;
end;

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
  outass('%'+inttostr(ssad)+' = call i'+inttostr(parpo^.bitsize)+
                                     ' @s'+inttostr(callinfo.ad+1)+'(');
  inc(parpo); //skip result param
  docallparam(parpo,endpo,outlinkcount);
 end;
end;

procedure callop();
begin
 with pc^.par do begin
  docall(0);
 end;
end;

procedure callfuncop();
begin
 with pc^.par do begin
  docallfunc(0);
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
  docallfunc(int1);
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
// ele1: elementoffsetty;
// po1: pvardataty;
 po1: plocallocinfoty;
 po2: pnestedallocinfoty;
 poend: pointer;
 first: boolean;
 str1,str2,str3,str4: shortstring;
 int1: integer;
 ssa1: integer;
begin
 with pc^.par.subbegin do begin
  po1:= getsegmentpo(seg_localloc,allocs.allocs);
  poend:= po1+allocs.alloccount;

  if sf_function in flags then begin
   outass('define i'+inttostr(po1^.bitsize)+' @s'+inttostr(subname)+'(');
   inc(po1); //result
  end
  else begin
   outass('define void @s'+inttostr(subname)+'(');
  end;
  first:= true;
  if sf_hasnestedaccess in flags then begin
   outass(' i8** %fp'); //parent locals
   first:= false;
  end;
  while po1 < poend do begin
   if not (af_param in po1^.flags) then begin
    break;
   end;
   str1:= ',i'+inttostr(po1^.bitsize)+' '+paraddress(po1^.address);
   if first then begin
    str1[1]:= ' ';
    first:= false;
   end;
   outass(str1);
   inc(po1);
  end;
  outass('){');
{$ifndef mse_locvarssatracking}
  po1:= getsegmentpo(seg_localloc,allocs.allocs);
{$endif}
  if sf_function in flags then begin
   outass(locaddress(po1^.address)+' = alloca i'+inttostr(po1^.bitsize));
   inc(po1); //result
  end;
  while po1 < poend do begin
  if not (af_param in po1^.flags) then begin
   break;
  end;
   outass(locaddress(po1^.address)+' = alloca i'+inttostr(po1^.bitsize));
{$ifndef mse_locvarssatracking}
   outass('store i'+inttostr(po1^.bitsize)+' '+paraddress(po1^.address)+
               ',i'+inttostr(po1^.bitsize)+'* '+
                           locaddress(po1^.address));
{$endif}
   inc(po1);
  end;
  while po1 < poend do begin
   outass(locaddress(po1^.address)+' = alloca i'+inttostr(po1^.bitsize));
   inc(po1);
  end;
  if sf_hasnestedref in flags then begin
   outass('%f = alloca i8*, i32 '+inttostr(allocs.nestedalloccount+1));
                   //first is room for possible oc_callout frame pointer
   po2:= getsegmentpo(seg_localloc,allocs.nestedallocs);
   poend:= po2+allocs.nestedalloccount;
   ssa1:= 1;
   while po2 < poend do begin
    str1:= '%'+inttostr(ssa1); 
    outass(str1+' = getelementptr i8** %f, i32 '+ inttostr(ssa1 div 3 + 1));
    inc(ssa1);
    str2:= '%'+inttostr(ssa1);
    inc(ssa1);
    str3:= '%'+inttostr(ssa1);
    inc(ssa1);
    if po2^.address.nested then begin
     outass(str2+' = getelementptr i8** %fp, i32 '+
                                        inttostr(po2^.address.address));
     outass(str3+' = load i8** '+str2);
     outass('store i8* '+str3+', i8** '+str1);
    end
    else begin
     str4:= 'i'+ inttostr(8*po2^.address.size);
     outass(str2+' = bitcast i8** '+str1+' to '+str4+'**');
     outass('store '+str4+'* %l'+inttostr(po2^.address.address)+', '+
                                                             str4+'** '+str2);
     outass(str3+' = add i8 0, 0'); //dummy
    end;
    
    inc(po2);
   end;
   if sf_hascallout in flags then begin
    str1:= '%'+inttostr(ssa1);
    inc(ssa1);
    outass(str1+' = bitcast i8** %fp to i8*');
    outass('store i8* '+str1+', i8** %f');
   end;
  end;
 end;
end;

procedure subendop();
begin
 with pc^.par.subend do begin
  outass('}');
 end;
end;

procedure returnop();
begin
 outass('ret void');
end;

procedure returnfuncop();
var
 po1: plocallocinfoty;
 ty1: shortstring;
 dest1: shortstring;
begin
 with pc^.par do begin
  po1:= getsegmentpo(seg_localloc,returnfuncinfo.allocs.allocs);
  ty1:= 'i'+inttostr(po1^.bitsize);
  dest1:= '%'+inttostr(ssad);
  outass(dest1 + ' = load '+ty1+'* %l0');
  outass('ret '+ty1+' '+dest1);
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

const
  nonessa = 0;
  nopssa = 1;

  beginparsessa = 0;
  mainssa = 1;
  progendssa = 0;  
  endparsessa = 0;

  movesegreg0ssa = 1;
  moveframereg0ssa = 1;
  popreg0ssa = 1;
  increg0ssa = 1;

  gotossa = 1;
  cmpjmpneimm4ssa = 1;
  cmpjmpeqimm4ssa = 1;
  cmpjmploimm4ssa = 1;
  cmpjmpgtimm4ssa = 1;
  cmpjmploeqimm4ssa = 1;

  ifssa = 1;
  writelnssa = 1;
  writebooleanssa = 1;
  writeintegerssa = 1;
  writefloatssa = 1;
  writestring8ssa = 1;
  writeclassssa = 1;
  writeenumssa = 1;

  pushssa = 1;
  popssa = 1;

  pushimm1ssa = 1;
  pushimm8ssa = 1;
  pushimm16ssa = 1;
  pushimm32ssa = 1;
  pushimm64ssa = 1;
  pushimmdatakindssa = 1;
  
  int32toflo64ssa = 1;
  
  negcard32ssa = 1;
  negint32ssa = 1;
  negflo64ssa = 1;

  mulint32ssa = 1;
  mulflo64ssa = 1;
  addint32ssa = 1;
  addflo64ssa = 1;

  addimmint32ssa = 1;
  mulimmint32ssa = 1;
  offsetpoimm32ssa = 1;

  cmpequboolssa = 1;
  cmpequint32ssa = 1;
  cmpequflo64ssa = 1;

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
  popsegssa = 0;

  poploc8ssa = 0;
  poploc16ssa = 0;
  poploc32ssa = 0;
  poplocssa = 0;

  poplocindi8ssa = 2;
  poplocindi16ssa = 2;
  poplocindi32ssa = 2;
  poplocindissa = 2;

  poppar8ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar16ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  poppar32ssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};
  popparssa = {$ifdef mse_locvarssatracking}1{$else}0{$endif};

  popparindi8ssa = 2;
  popparindi16ssa = 2;
  popparindi32ssa = 2;
  popparindissa = 2;

  pushnilssa = 1;
  pushsegaddressssa = 1;

  pushseg8ssa = 1;
  pushseg16ssa = 1;
  pushseg32ssa = 1;
  pushsegssa = 1;

  pushloc8ssa = 1;
  pushloc16ssa = 1;
  pushloc32ssa = 1;
  pushlocpossa = 1;
  pushlocssa = 1;

  pushlocindi8ssa = 3;
  pushlocindi16ssa = 3;
  pushlocindi32ssa = 3;
  pushlocindissa = 3;

  pushpar8ssa = 1;
  pushpar16ssa = 1;
  pushpar32ssa = 1;
  pushparpossa = 1;
  pushparssa = 1;

  pushaddrssa = 1;
  pushlocaddrssa = 1;
  pushlocaddrindissa = 1;
  pushsegaddrssa = 1;
  pushsegaddrindissa = 1;
  pushstackaddrssa = 1;
  pushstackaddrindissa = 1;

  indirect8ssa = 2;
  indirect16ssa = 2;
  indirect32ssa = 2;
  indirectpossa = 2;
  indirectpooffsssa = 1;
  indirectoffspossa = 1;
  indirectssa = 1;

  popindirect8ssa = 1;
  popindirect16ssa = 1;
  popindirect32ssa = 1;
  popindirectssa = 1;

  callssa = 0;
  callfuncssa = 1;
  calloutssa = 1;
  callfuncoutssa = 1;
  callvirtssa = 1;
  callintfssa = 1;
  virttrampolinessa = 1;

  locvarpushssa = 0; //dummy
  locvarpopssa = 0;  //dummy

  subbeginssa = 1;
  subendssa = 0;
  returnssa = 1;
  returnfuncssa = 1;

  initclassssa = 1;
  destroyclassssa = 1;

  decloop32ssa = 1;
  decloop64ssa = 1;

  setlengthstr8ssa = 1;

  raisessa = 1;
  pushcpucontextssa = 1;
  popcpucontextssa = 1;
  finiexceptionssa = 1;
  continueexceptionssa = 1;

//ssa only
  nestedvarssa = 3;
  popnestedvarssa = 3;
  pushnestedvarssa = 3;
  nestedcalloutssa = 2;
  hascalloutssa = 1;

{$include optable.inc}

procedure run();
var
 endpo: pointer;
 lab: shortstring;
begin
 pc:= getsegmentbase(seg_op);
 endpo:= pointer(pc)+getsegmentsize(seg_op);
 inc(pc,startupoffset);
 while pc < endpo do begin
  if opf_label in pc^.op.flags then begin
   curoplabel(lab);
   outass('br label %'+lab);
   outass(lab+':');
  end;
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
 freeandnil(assstream);
end.
