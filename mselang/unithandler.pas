{ MSElang Copyright (c) 2013-2018 by Martin Schreiber
   
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
unit unithandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,mselinklist,listutils,msestrings,parserglob,opglob,elements,
 handlerglob,msetypes,compilerunit;

type
 philistitemty = record
  ssa: int32;
  bbindex: int32; //label
 end;
 pphilistitemty = ^philistitemty;

 philistty = record
  count: int32;
  items: record //array of philistitemty
  end;
 end;
 pphilistty = ^philistty;

 oprelocitemty = record
  opad: opaddressty;
  link: linkindexty;
 end;
 poprelocitemty = ^oprelocitemty;
 
 castitemty = record
  typedata: elementoffsetty;
  olddatatyp: typeinfoty;
  indirection: int32;
  offset: int32;
  oldflags: addressflagsty;
 end;
 pcastitemty = ^castitemty;
 docastflagty = (dcf_first,dcf_cancel);
 docastflagsty = set of docastflagty;
 castcallbackty = procedure (const acontext: pcontextitemty;
                            const item: castitemty; var aflags: docastflagsty);

 
 unitlinkinfoty = record  //used for ini, fini
  header: linkheaderty;
  ref: punitinfoty
 end;
 punitlinkinfoty = ^unitlinkinfoty;
var 
 unitlinklist: linklistty;
 unitchain: listadty;
 intfparsedlinklist: linklistty;
 intfparsedchain: listadty;

function newunit(const aname: string): punitinfoty; 
function defaultdialect(const afilename: filenamety): dialectty;

function getunitfile(const aunit: punitinfoty; const aname: lstringty): boolean;
function getunitfile(const aunit: punitinfoty;
                                        const aname: filenamety): boolean;
function initunitfileinfo(const aunit: punitinfoty): boolean;

function loadunitbyid(const aid: identty; 
                    const astackoffset: int32 = minint): punitinfoty;
function loadunit(const aindex: integer): punitinfoty;
function parsecompilerunit(const aname: string;
                                        out aunit: punitinfoty): boolean;

procedure handleprogramentry();
procedure beginunit(const aname: identty; const nopush: boolean);
procedure setunitname(); //unitname on top of stack
function getunitname(const id: identty): string;
function getunittimestamp(const id: identty): tdatetime;
//procedure setunitsubname(aindex: int32); //sets namebuffer

//procedure interfacestop();

procedure markinterfacestart();
{
procedure markinterfaceend();
procedure markimplementationstart();
procedure markunitend();
}
procedure handleuseserror();
procedure handleuses();

procedure handleafterintfuses();
procedure handleimplementationentry();
procedure handlemainentry();
procedure handleimplusesentry();
procedure handleafterimpluses();
procedure handleimplementation();
procedure handleinclude();

procedure handlemode();
procedure handlecompilerswitchentry();
procedure setcompilerswitch();
procedure handlelongcompilerswitchentry();
procedure setlongcompilerswitch();
procedure setdefaultcompilerswitch();
procedure unsetcompilerswitch();
procedure unsetlongcompilerswitch();
procedure handlecompilerswitch();

procedure linkmark(var alinks: linkindexty; const aaddress: segaddressty;
                                                  const offset: integer  = 0);
procedure linkmarkphi(var alinks: linkindexty; 
                            const aaddress: dataoffsty; //in seg_op
                                                const ssaindex: int32);
procedure linkresolve(var alinks: linkindexty); //delete chain

procedure linkresolveopad(const alinks: linkindexty; 
                                                 const aaddress: opaddressty);
procedure linkresolvegoto(const alinks: linkindexty; 
                 const aaddress: opaddressty; const ablockid: int32);
procedure linkresolvecall(const alinks: linkindexty; 
                            const aaddress: opaddressty; const aglobid: int32);
                                //aglobid < 0 -> fetch from subbegin op
procedure linkresolveint(const alinks: linkindexty; const avalue: int32);
procedure linkresolvephi(const alinks: linkindexty; 
                      const aaddress: opaddressty; const lastssa: int32;
                                 out philist: dataoffsty); //in seg_localloc
procedure linkaddcast(const atype: elementoffsetty; 
                                          const acontext: pcontextitemty);
function linkdocasts(var alinks: linkindexty; const acontext: pcontextitemty;
                                    const callback: castcallbackty): boolean;
                                                          //true if ok
function linkgetcasttype(const alinks: linkindexty): elementoffsetty;
procedure linkinsertop(const alinks: linkindexty; const aaddress: opaddressty);


procedure forwardmark(out aforward: forwardindexty;
                          const asource: sourceinfoty; const aident: identty);
procedure forwardresolve(const aforward: forwardindexty);
procedure checkforwarderrors(const aforward: forwardindexty);
//function addtypedef(const aname: identty; const avislevel: visikindsty;
//                                        out aelementdata: pointer): boolean;
procedure markforwardtype(const atype: ptypedataty; const aforwardname: identty);
procedure resolveforwardtype(const atype: ptypedataty;
                                        const first: boolean = true);
procedure checkforwardtypeerrors();

procedure regclass(const aclass: elementoffsetty);
procedure regclassdescendant(const aclass: elementoffsetty;
                                const aancestor: elementoffsetty);

procedure updateprogend(const aop: popinfoty);

procedure handleunitend();
//procedure handleinifini();
procedure handleinitializationstart();
procedure handleinitialization();
procedure handlefinalizationstart();
procedure handlefinalization();

procedure beginunit(const aunit: punitinfoty);
function endunit(const aunit: punitinfoty): boolean;
procedure finalizeunit(const aunit: punitinfoty);

function getexitcodeaddress: segaddressty;
function bcfiles(): filenamearty;
function objfiles(): filenamearty;

procedure deletetempfile(const afile: filenamety);

procedure init;
procedure deinit(const freeunitlist: boolean);

implementation
uses
 msehash,filehandler,errorhandler,parser,msefileutils,msestream,
 handlerutils,msearrayutils,opcode,subhandler,exceptionhandler,llvmlists,
 {stackops,}segmentutils,classhandler,managedtypes,llvmbitcodes,
 unitwriter,identutils,mseformatstr,sysutils,typehandler,directivehandler,
 elementcache,grammarglob,__mla__internaltypes;
 
type
 unithashdataty = record
  header: hashheaderty;
  data: punitinfoty;
 end;
 punithashdataty = ^unithashdataty;

 tunitlist = class(thashdatalist)
  private
   ffilenameiteratepo: pfilenamety;
   procedure bcfilenameiterator(const aitem: phashdataty);
   procedure objfilenameiterator(const aitem: phashdataty);
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   procedure finalizeitem(const aitem: phashdataty); override;
   function getrecordsize(): int32 override;
  public
   constructor create;
   function findunit(const aname: identty): punitinfoty;
   function newunit(const aname: identty): punitinfoty;
   function bcfiles(): filenamearty;
   function objfiles(): filenamearty;
 end;

var
 unitlist: tunitlist;

procedure handleprogramentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROGRAMENTRY');
{$endif}
 with info,s.unitinfo^ do begin
  include(state,us_program);
  if prev <> nil then begin
   tokenexpectederror(tk_unit);
  end;  
 end;
end;

procedure beginunit(const aname: identty; const nopush: boolean);
var
 po1: punitdataty;
 lstr1: lstringty;
 i1: int32;
begin
 if nopush then begin
 {$ifdef mse_checkinternalerror}
  if not ele.adduniquechilddata(unitsele,[aname],ek_unit,
                                           [vik_units],po1) then begin
   internalerror(ie_unit,'150710A');
  end;
 {$else}
  ele.adduniquechilddata(unitsele,[aname],ek_unit,[vik_units],po1);
 {$endif}
 end
 else begin
 {$ifdef mse_checkinternalerror}                             
  if not ele.pushelement(aname,ek_unit,[vik_units],po1) then begin
   internalerror(ie_unit,'131018A');
  end;
 {$else}
  ele.pushelement(aname,ek_unit,[vik_units],po1);
 {$endif}
 end;
 with info do begin
  po1^.next:= unitinfochain;
  unitinfochain:= ele.eledatarel(po1);
  with s.unitinfo^ do begin
   if nopush then begin
    interfaceelement:= ele.eledatarel(po1);
   end
   else begin
    interfaceelement:= ele.elementparent;
   end;
   getidentname(aname,lstr1);
   namestring:= lstringtostring(lstr1);
   name:= stringtolstring(namestring);
  {
   for i1:= 0 to high(o.defines) do begin
    adddefine(o.defines[i1].id);
   end;
  }
  end;
 end;
end;

procedure markinterfacestart();
begin
 with info.s,unitinfo^ do begin
  globlinkage:= li_external;
  ele.markelement(interfacestart); 
  reloc.interfaceelestart:= interfacestart.bufferref;
  reloc.interfaceglobstart:= info.globdatapo;
                //reloc.globidcount set in putunit()
 end;
end;

procedure markinterfaceend();
begin
 with info.s,unitinfo^ do begin
  globlinkage:= li_internal;
  ele.markelement(interfaceend);
  reloc.interfaceelesize:= interfaceend.bufferref- interfacestart.bufferref;
  reloc.interfaceglobsize:= info.globdatapo - reloc.interfaceglobstart;
 end;
end;

procedure markimplementationstart();
begin
 with info.s.unitinfo^ do begin
  ele.markelement(implementationstart);
  implementationglobstart:= info.globdatapo;
  reloc.opstart:= info.opcount;
  opseg:= getsubsegment(seg_op);
  opstart:= info.opcount;
  globidbasex:= info.globidcountx;
  with info do begin
   if modularllvm and (unitlevel = 1) then begin //main
    with additem(oc_beginparse)^ do begin
     with par.beginparse do begin
      finisub:= 0;
     end;
    end;
   end
   else begin
    with additem(oc_beginunitcode)^ do begin
    end;
   end;
  end;
 end;
end;

procedure markunitend();
begin
 with info.s.unitinfo^ do begin
  with additem(oc_endunit)^ do begin
  end;
  if info.modularllvm then begin
   with additem(oc_endparse)^ do begin
   end;
   info.globidcountx:= info.globidcountx+nameid;
  end;
  setsubsegmentsize(opseg);
  reloc.opsize:= info.opcount-reloc.opstart;
  implementationglobsize:= info.globdatapo - implementationglobstart;
 end;
end;

procedure setunitname(); //unitname on top of stack
var
 id1: identty;
// po2: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('SETUNITNAME');
{$endif}
 with info do begin
  id1:= contextstack[s.stacktop].d.ident.ident;
  if (s.unitinfo^.key <> id1) and (s.unitinfo^.prev <> nil) then begin
   identerror(1,err_illegalunitname);
  end
  else begin
   s.unitinfo^.key:= id1; //overwrite "program"
   beginunit(id1,false);
   markinterfacestart();
//   ele.markelement(s.unitinfo^.interfacestart);
  end;
  s.stacktop:= s.stackindex;
 end;
end;

(*
procedure interfacestop();
begin
{$ifdef mse_debugparser}
 outhandle('INTERFACESTOP');
{$endif}
 with info do begin
  include(unitinfo^.state,us_interfaceparsed);
 end;
end;
*)

procedure handleuseserror();
begin
{$ifdef mse_debugparser}
 outhandle('USESERROR');
{$endif}
 with info do begin
  errormessage(err_syntax,[';']);
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleuses();
var
 int1,int2: integer;
// offs1: elementoffsetty;
 po1: ppunitinfoty;
 ar1: elementoffsetarty;
begin
{$ifdef mse_debugparser}
 outhandle('USES');
{$endif}
 with info do begin
  int2:= s.stacktop-s.stackindex-1;
  setlength(ar1,int2);
  for int1:= 0 to int2-1 do begin
   if not ele.addelement(contextstack[s.stackindex+int1+2].d.ident.ident,
                                    ek_uses,[vik_global],ar1[int1]) then begin
    identerror(int1+2,err_duplicateidentifier);
   end;
  end;
//  offs1:= ele.decelementparent;
  with s.unitinfo^ do begin
   if us_interfaceparsed in state then begin
    setlength(implementationuses,int2);
    po1:= pointer(implementationuses);
   end
   else begin
   {$ifdef mse_checkinternalerror}
    if interfaceuses = nil then begin
     internalerror(ie_parser,'20150831A');
    end;
   {$endif}
    setlength(interfaceuses,int2+1);
    po1:= pointer(interfaceuses);
    inc(po1);
   end;
  end;
  inc(po1,int2);
  int2:= 0;
  for int1:= s.stackindex+2 to s.stacktop do begin
   dec(po1);
   po1^:= loadunit(int1);
   if po1^ = nil then begin
    s.stopparser:= true;
    break;
   end;
   if ar1[int2] <> 0 then begin
    with pusesdataty(ele.eledataabs(ar1[int2]))^ do begin
     ref:= po1^^.interfaceelement;
    end;
   end;
   inc(int2);
  end;
//  ele.elementparent:= offs1;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleafterintfuses();
begin
{$ifdef mse_debugparser}
 outhandle('AFTERINTFUSES');
{$endif}
 with info do begin
  markinterfacestart();
//  ele.markelement(s.unitinfo^.interfacestart);
  with contextstack[s.stackindex] do begin
   d.kind:= ck_interface;
//   ele.markelement(d.impl.elemark);
  end;
 end;
end;

procedure handleimplementationentry();
var
 po1: pimplementationdataty;
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATIONENTRY');
{$endif}
 checkforwardtypeerrors();
 markinterfaceend();
 with info do begin
 {
  if modularllvm and (unitlevel = 1) then begin //main
   with additem(oc_beginparse)^ do begin
    with par.beginparse do begin
     finisub:= 0;
    end;
   end;
  end;
 }
  include(s.unitinfo^.state,us_interfaceparsed);
{
  if (co_compilefileinfo in o.compileoptions) and s.interfaceonly then begin
   writeln('impl '+quotefilename(s.unitinfo^.filepath));
  end;
}
  if us_implementation in s.unitinfo^.state then begin
   errormessage(err_invalidtoken,['implementation']);
  end
  else begin
   include(s.unitinfo^.state,us_implementation);
   include(s.currentstatementflags,stf_implementation);
  {$ifdef mse_checkinternalerror}                             
   if not ele.pushelement(tk_implementation,ek_implementation,
                                    implementationvisi,po1) then begin
    internalerror(ie_unit,'20131130A');
   end;
  {$else}
   ele.pushelement(tk_implementation,ek_implementation,implementationvisi,po1);
  {$endif}
   s.unitinfo^.implementationelement:= ele.eledatarel(po1);
{
   s.unitinfo^.impl.sourceoffset:= s.source.po - s.sourcestart;
   if s.interfaceonly then begin
    s.stopparser:= true;
   end;
}
  end;
  po1^.exitlinks:= 0;
  with contextstack[s.stackindex] do begin
   d.kind:= ck_implementation;
//   ele.markelement(d.impl.elemark);
  end;
//  checkpendingmanagehandlers();
 end;
end;

procedure handlemainentry();
begin
{$ifdef mse_debugparser}
 outhandle('MAINENTRY');
{$endif}
{
 with info do begin
  if co_llvm in o.compileoptions then begin
   updatellvmclassdefs(false);
  end;
 end;
}
end;

procedure handleimplusesentry();
begin
{$ifdef mse_debugparser}
 outhandle('IMPLUSESENTRY');
{$endif}
 with info do begin
 {
  if co_llvm in o.compileoptions then begin
   updatellvmclassdefs();
  end;
 }
  s.unitinfo^.usescache.clear(); //override interface uses
  if s.interfaceonly then begin
   saveparsercontext(s.unitinfo^.implstart,s.stacktop-s.unitinfo^.stackstart+1);
   s.stopparser:= true;
  end;
 end;
end;

procedure handleafterimpluses();
begin
{$ifdef mse_debugparser}
 outhandle('AFTERIMPLUSES');
{$endif}
 markimplementationstart();
 checkpendingmanagehandlers();
 with info do begin
  if co_llvm in o.compileoptions then begin
   updatellvmclassdefs(false);
  end;
 end;
 include(info.s.unitinfo^.state,us_implementationblock);
end;

procedure handleimplementation();
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATION');
{$endif}
 checkforwardtypeerrors();
 markunitend();
 with info do begin
  with s.unitinfo^ do begin
   setsubsegmentsize(opseg);
   if unitlevel > 1 then begin
    ele.releaseelement(implementationstart);
        //possible pending implementation units
        //todo: compile implementation units as soon as possible in order to
        //save resources
   end;
   freeparsercontext(implstart);
   include(state,us_implementationparsed);
  end;
//  dec(s.stackindex);
 end;
end;

procedure handleinclude();
var
 lstr1: lstringty;
 filepath: filenamety;
begin
{$ifdef mse_debugparser}
 outhandle('INCLUDE');
{$endif} 
 with info do begin
  if stringbuffer <> '' then begin
   lstr1.po:= pointer(stringbuffer);
   lstr1.len:= length(stringbuffer);
   filepath:= filehandler.getincludefile(lstr1);
   if filepath = '' then begin
    errormessage(err_cannotfindinclude,[],s.stacktop-s.stackindex);
   end
   else begin
    pushincludefile(filepath);
   end;
  end;
  dec(s.stackindex,2);
 end;
end;

procedure handlemode();
var
 dialect: dialectty;
begin
{$ifdef mse_debugparser}
 outhandle('MODE');
{$endif}
 with info do begin
  if (s.stacktop < 2) or 
    (contextstack[s.stackindex-2].context <> 
                               getstartcontext(s.dialect)) then begin
   errormessage(err_dialectatbeginofunit,[],0);
  end
  else begin
   dialect:= dia_none;
   case contextstack[s.stacktop].d.ident.ident of
    tk_mselang: begin
     dialect:= dia_mse;
    end;
    tk_pascal: begin
     dialect:= dia_pas;
    end;
    else begin
     errormessage(err_unknowndialect,[]);
    end;
   end;
   if dialect <> dia_none then begin
    s.dialect:= dialect;
    contextstack[s.stackindex-2].context:= getstartcontext(dialect);
   end;
  end;
 end;
end;

procedure handlecompilerswitchentry();
begin
{$ifdef mse_debugparser}
 outhandle('COMPILERSWITCHENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.handlerflags:= d.handlerflags -
                    [hf_set,hf_clear,hf_long,hf_longset,hf_longclear];
 end;
end;

procedure setcompilerswitch();
begin
{$ifdef mse_debugparser}
 outhandle('SETCOMPILERSWITCH');
{$endif} 
 with info,contextstack[s.stackindex] do begin
  include(d.handlerflags,hf_set);
 end;
end;

procedure unsetcompilerswitch();
begin
{$ifdef mse_debugparser}
 outhandle('UNSETCOMPILERSWITCH');
{$endif} 
 with info,contextstack[s.stackindex] do begin
  include(d.handlerflags,hf_clear);
 end;
end;


procedure handlelongcompilerswitchentry();
begin
{$ifdef mse_debugparser}
 outhandle('LONGCOMPILERSWITCHENTRY');
{$endif} 
 with info,contextstack[s.stackindex] do begin
  include(d.handlerflags,hf_long);
 end;
end;

procedure setlongcompilerswitch();
begin
{$ifdef mse_debugparser}
 outhandle('UNSETCOMPILERSWITCH');
{$endif} 
 with info,contextstack[s.stackindex] do begin
  include(d.handlerflags,hf_longset);
 end;
end;

procedure setdefaultcompilerswitch();
begin
{$ifdef mse_debugparser}
 outhandle('SETDEFAULTCOMPILERSWITCH');
{$endif} 
 with info,contextstack[s.stackindex] do begin
  include(d.handlerflags,hf_default);
 end;
end;

procedure unsetlongcompilerswitch();
begin
{$ifdef mse_debugparser}
 outhandle('UNSETLONGCOMPILERSWITCH');
{$endif} 
 with info,contextstack[s.stackindex] do begin
  include(d.handlerflags,hf_longclear);
 end;
end;

type
 compilerswitchesidentsty = array[compilerswitchty] of identty;
const
 shortcompilerswitches: compilerswitchesidentsty =
//cos_none,cos_booleval,cos_internaldebug
 (0,       tk_b,        0);
 longcompilerswitches: compilerswitchesidentsty =
//cos_none,cos_booleval,cos_internaldebug
 (0,       tk_booleval, tk_internaldebug);
 
procedure handlecompilerswitch();
 function check(const aident: identty;
                const aswitches: compilerswitchesidentsty): compilerswitchty;
 var
  s1: compilerswitchty;  
 begin
  result:= cos_none;
  for s1:= low(s1) to high(s1) do begin
   if aswitches[s1] = aident then begin
    result:= s1;
    break;
   end;
  end;
 end; //check

var
 s1: compilerswitchty;
 ident1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('COMPILERSWITCH');
{$endif}
 with info,contextstack[s.stackindex] do begin
  if s.stacktop > s.stackindex then begin
  {$ifdef mse_checkinternalerror}
   if contextstack[s.stackindex+1].d.kind <> ck_ident then begin
    internalerror(ie_handler,'20151012A');
   end;
  {$endif}
   ident1:= contextstack[s.stackindex+1].d.ident.ident;
   if hf_long in d.handlerflags then begin
    s1:= check(ident1,longcompilerswitches);
    if d.handlerflags * [hf_longclear,hf_longset,hf_default] = [] then begin
     s1:= cos_none;
    end;
   end
   else begin
    s1:= check(ident1,shortcompilerswitches);
    if d.handlerflags * [hf_clear,hf_set] = [] then begin
     s1:= cos_none;
    end;
   end;
   if s1 = cos_none then begin
    identerror(1,err_illegaldirective);
   end
   else begin
    if (d.handlerflags * [hf_set,hf_longset] <> []) or 
           (hf_default in d.handlerflags) and 
                             (s1 in o.compilerswitches) then begin
     include(s.compilerswitches,s1);
    end
    else begin 
     exclude(s.compilerswitches,s1);
    end;
   end;
  end;
 end;
end;

function newunit(const aname: string): punitinfoty; 
var
 id: identty;
begin
 id:= getident(aname);
 result:= unitlist.findunit(id);
 if result = nil then begin
  result:= unitlist.newunit(id);
  result^.namestring:= aname;
  result^.name:= stringtolstring(result^.namestring);
  result^.dwarflangid:= DW_LANG_Pascal83;
 end;
end;

function getunitname(const id: identty): string;
var
 po1: punitinfoty;
begin
 po1:= unitlist.findunit(id);
 if po1 <> nil then begin
  result:= po1^.namestring;
 end
 else begin
  result:= '';
 end;
end;

function getunittimestamp(const id: identty): tdatetime;
var
 po1: punitinfoty;
 lstr1: lstringty;
 fna1: filenamety;
begin
 po1:= unitlist.findunit(id);
 if po1 <> nil then begin
  result:= po1^.filematch.timestamp;
 end
 else begin
  getidentname(id,lstr1);
  fna1:= getsourceunitfile(lstr1);
  if fna1 = '' then begin
   fna1:= getrtunitfile(lstr1);
  end;
  if fna1 = '' then begin
   result:= emptydatetime;
  end
  else begin
   result:= getfilemodtime(fna1);
  end;
 end;
end;
{
procedure setunitsubname(aindex: int32); //sets namebuffer
var
 po1,pe: pchar;
begin
 with info.s.unitinfo^ do begin
  po1:= @namebufferdata[namebufferstart];
  pe:= po1 + 8;
  while po1 < pe do begin
   po1^:= charhexlower[aindex and $F];
   aindex:= card32(aindex) shr 4;
   inc(po1);
  end;
 end;
end;
}
function defaultdialect(const afilename: filenamety): dialectty;
begin
 result:= dia_pas;
 if fileext(afilename) = 'mla' then begin
  result:= dia_mse;
 end;
end;

function parseusesunit(const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
{$ifdef mse_debugparser}
  writeln();
  writeln('***************************************** uses');
  writeln(filepath);
{$endif}
//todo: use mmap(), problem: no terminating 0.
  result:= parseunit(readfiledatastring(filepath),defaultdialect(filepath),
                                                    aunit,{false}true);
{$ifdef mse_debugparser}
  writeln('***************************************** usesend');
  writeln(filepath);
{$endif}
 end;
end;

function initunitfileinfo(const aunit: punitinfoty): boolean;
begin
 with aunit^ do begin
  createguid(filematch.guid);
  filematch.timestamp:= getfilemodtime(filepath);
  result:= filematch.timestamp <> emptydatetime;
 end;
end;

function getunitfile(const aunit: punitinfoty; const aname: lstringty): boolean;
begin
 with aunit^ do begin
  namestring:= lstringtostring(aname);
  name:= stringtolstring(namestring);
  filepath:= filehandler.getsourceunitfile(aname);
  result:= filepath <> '';
  if result then begin
   initunitfileinfo(aunit);
  end;
 end;
end;

function getunitfile(const aunit: punitinfoty; 
                                    const aname: filenamety): boolean;
begin
 result:= getunitfile(aunit,stringtolstring(string(aname)));
end;
         
function parsecompilerunit(const aname: string; 
                                             out aunit: punitinfoty): boolean;
var
 str1: string;
begin
 result:= false;
 str1:= aname;
 aunit:= newunit(str1);
 with aunit^ do begin
  prev:= info.s.unitinfo;
  if not getunitfile(aunit,msestring(aname)) then begin
   errormessage(err_compilerunitnotfound,[aname]);
   exit;
  end;
  inc(info.unitlevel);
  result:= parseusesunit(aunit);
  dec(info.unitlevel);
 end;
end;

function loadunitbyid(const aid: identty;
                      const astackoffset: int32 = minint): punitinfoty;
var
 lstr1: lstringty;
begin
 //todo: load unitfile without source
 
 result:= unitlist.findunit(aid);
 if result = nil then begin
  result:= unitlist.newunit(aid);
  with result^ do begin
   prev:= info.s.unitinfo;
   getidentname(aid,lstr1);
   if not getunitfile(result,lstr1) then begin
    identerror(astackoffset,err_cantfindunit);
   end
   else begin
    if not parseusesunit(result) then begin
     result:= nil;
    end
   end;
  end;
 end
 else begin
  if not (us_interfaceparsed in result^.state) then begin
   circularerror(astackoffset,result);
   result:= nil;
  end;
 end;
end;

function loadunit(const aindex: integer): punitinfoty;
begin
 result:= loadunitbyid(info.contextstack[aindex].d.ident.ident,
                                                aindex-info.s.stackindex);
end;

{
function nextunitimplementation: punitinfoty;
begin
 result:= implementationpending.next;
end;
}


constructor tunitlist.create;
begin
// inherited create(sizeof(punitinfoty));
 inherited;
 fstate:= fstate + [hls_needsfinalize];
end;

function tunitlist.hashkey(const akey): hashvaluety;
begin
 result:= unitinfoty(akey).key;
end;

function tunitlist.checkkey(const akey; const aitem: phashdataty): boolean;
begin
 result:= identty(akey) = punithashdataty(aitem)^.data^.key;
end;

function tunitlist.findunit(const aname: identty): punitinfoty;
var
 po1: punithashdataty;
begin
 result:= nil;
 po1:= punithashdataty(internalfind(aname,aname));
 if po1 <> nil then begin
  result:= po1^.data;
 end;
end;

procedure tunitlist.finalizeitem(const aitem: phashdataty);
begin
{
 with punitinfoty(aitemdata)^ do begin
  clearlist(externallinklist,sizeof(externallinkinfoty),0);
 end;
}
 with punithashdataty(aitem)^ do begin
  system.finalize(data^);
  freesegments(data^.segments);
//  metadatalist.free();
  freeparsercontext(data^.implstart);
  freemem(data);
 end;
end;

function tunitlist.getrecordsize(): int32;
begin
 result:= sizeof(unithashdataty);
end;

function tunitlist.newunit(const aname: identty): punitinfoty;
var
 po1: punithashdataty;
 rtlunit1: rtlunitty;
begin
 po1:= punithashdataty(internaladdhash(aname));
 getmem(result,sizeof(unitinfoty)); //todo: memory fragmentation?
 fillchar(result^,sizeof(result^),0);
// result^.nameid:= 1;
 result^.key:= aname;
 result^.usescache:= telementcache.create();
{
 if info.systemunit <> nil then begin
  setlength(result^.interfaceuses,1);
  result^.interfaceuses[0]:= info.systemunit;
 end;
}
 for rtlunit1:= low(info.rtlunits) to high(info.rtlunits) do begin
  if info.rtlunits[rtlunit1] <> nil then begin
   msearrayutils.additem(pointerarty(result^.interfaceuses),
                                           info.rtlunits[rtlunit1]);
  end;
 end;
 po1^.data:= result;
 with punitlinkinfoty(addlistitem(unitlinklist,unitchain))^ do begin
  ref:= result;
 end;
end;

procedure tunitlist.bcfilenameiterator(const aitem: phashdataty);
begin
 with punithashdataty(aitem)^.data^ do begin
  ffilenameiteratepo^:= bcfilepath;
 end;
 inc(ffilenameiteratepo);
end;

procedure tunitlist.objfilenameiterator(const aitem: phashdataty);
begin
 with punithashdataty(aitem)^.data^ do begin
  ffilenameiteratepo^:= objfilepath;
 end;
 inc(ffilenameiteratepo);
end;


function tunitlist.bcfiles: filenamearty;
begin
 setlength(result,count);
 ffilenameiteratepo:= pointer(result);
 iterate(@bcfilenameiterator);
end;

function tunitlist.objfiles: filenamearty;
begin
 setlength(result,count);
 ffilenameiteratepo:= pointer(result);
 iterate(@objfilenameiterator);
end;

(*
{ timplementationpendinglist }

constructor timplementationpendinglist.create;
begin
 inherited create(sizeof(implpenddataty));
end;

procedure timplementationpendinglist.add(const aunit: punitinfoty);
var
 ofs1: ptruint;
begin
 with pimplpendinfoty(inherited add(ofs1))^ do begin
  header.prev:= 0;
  header.lh.next:= froot;
  pimplpendinfoty(fdata+froot)^.header.prev:= ofs1;
  froot:= ofs1;
  data.unitname:= aunit^.key;
 end;
end;

function timplementationpendinglist.next: punitinfoty;
var
 ofs1: ptruint;
begin
 result:= nil;
 ofs1:= froot;
 if ofs1 <> 0 then begin
  with pimplpendinfoty(fdata+ofs1)^ do begin
   result:= unitlist.findunit(data.unitname);
   froot:= header.lh.next;
  end;
  delete(ofs1);
 end;  
end;
*)

procedure regclass(const aclass: elementoffsetty);
begin
 with info.s.unitinfo^ do begin
 {$ifdef mse_checkinternalerror}                             
  if us_end in state then begin
   internalerror(ie_unit,'201400402B');
  end;
 {$endif}
  if pendingcount >= pendingcapacity then begin
   pendingcapacity:= pendingcapacity*2+256;
   reallocuninitedarray(pendingcapacity,sizeof(pendings[0]),pendings);   
  end;
  with pendings[pendingcount] do begin
   ref:= aclass;
//   ancestor:= aancestor;
  end;
  inc(pendingcount);
 end;
end;

type
 classdescendinfoty = record  //used for copying ancestor virtual method table
  header: linkheaderty;
  itemcount: integer;
  source: segaddressty;
  dest: segaddressty;
 end;
 pclassdescendinfoty = ^classdescendinfoty;

var
 classdescendlist: linklistty;
 forwardtypes: linklistty;
 resolvedforwardtypes: linklistty;
 
procedure regclassdescendant(const aclass: elementoffsetty;
                                const aancestor: elementoffsetty);
var
 po1: pclassdescendinfoty;
begin
 with ptypedataty(ele.eledataabs(aancestor))^ do begin
  po1:= addlistitem(classdescendlist,infoclass.pendingdescends);
  po1^.source:= infoclass.defs;
  po1^.itemcount:= infoclass.virtualcount;
 end;
 with ptypedataty(ele.eledataabs(aclass))^ do begin
  po1^.dest:= infoclass.defs;
 end;
end;

type
 phiitemty = record
  opsegoffset: dataoffsty; //in seg_op
  ssa: int32;
  bbindex: int32;
 end;
 linkinfoty = record
  next: linkindexty;
  case integer of
   1:(dest: segaddressty);
   2:(phi: phiitemty);
   3:(cast: castitemty);
   4:(opreloc: oprelocitemty);
 end;
 plinkinfoty = ^linkinfoty;
 linkarty = array of linkinfoty;
 
var
 links: linkarty; //[0] -> dummy entry
 linkindex: linkindexty;
 deletedlinks: linkindexty;
 
function link(var alinks: linkindexty): plinkinfoty;
var
 li1: linkindexty;
begin
 li1:= deletedlinks;
 if li1 = 0 then begin
  inc(linkindex);
  if linkindex > high(links) then begin
   reallocuninitedarray(high(links)*2+1024,sizeof(links[0]),links);
  end;
  li1:= linkindex;
  result:= @links[li1];
 end
 else begin
  result:= @links[li1];
  deletedlinks:= result^.next;
 end;
 result^.next:= alinks;
 alinks:= li1;
end;

procedure linksreverse(var alinks: linkindexty);
var
 li1,li2,li3: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  li2:= 0;
  repeat
   with links[li1] do begin
    li3:= next;
    next:= li2;
   end;
   li2:= li1;
   li1:= li3;
  until li1 = 0;
  alinks:= li2;
 end;
end;

procedure linkmark(var alinks: linkindexty; const aaddress: segaddressty;
                                                    const offset: integer = 0);
var
 po1: plinkinfoty;
begin
 po1:= link(alinks);
 po1^.dest:= aaddress;
 inc(po1^.dest.address,offset);
 if aaddress.segment = seg_op then begin
  with link(info.s.currentopcodemarkchain)^ do begin
   opreloc.opad:= po1^.dest.address;
   opreloc.link:= alinks;
  end;
 end;
end;

procedure linkinsertop(const alinks: linkindexty; const aaddress: opaddressty);
var
 li1: linkindexty;
 o1: opaddressty;
 ad1: opaddressty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  ad1:= aaddress * sizeof(opinfoty);
  while true do begin
   with links[li1] do begin
    if opreloc.opad >= ad1 then begin
     inc(opreloc.opad,sizeof(opinfoty));
     inc(links[opreloc.link].dest.address,sizeof(opinfoty));
    end;
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
 end;
end;

procedure linkresolve(var alinks: linkindexty); //delete chain
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
  alinks:= 0;
 end;
end;

procedure linkresolveopad(const alinks: linkindexty;
                                   const aaddress: opaddressty);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    popaddressty(getsegmentpo(dest))^:= aaddress-1;
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
 end;
end;

procedure linkresolvegoto(const alinks: linkindexty; 
                 const aaddress: opaddressty; const ablockid: int32);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    popaddressty(getsegmentpo(dest))^:= aaddress-1;
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
 end;
end;

procedure linkresolvecall(const alinks: linkindexty; 
                            const aaddress: opaddressty; const aglobid: int32);
var
 li1: linkindexty;
 ad1: calladdressty;
begin
 if alinks <> 0 then begin
  ad1.ad:= aaddress-1;
  if aglobid < 0 then begin
   ad1.globid:= getoppo(aaddress)^.par.subbegin.globid;
  end
  else begin
   ad1.globid:= aglobid;
  end;
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    pcalladdressty(getsegmentpo(dest))^:= ad1;
//    popaddressty(getsegmentpo(dest))^:= aaddress-1;
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
 end;
end;

procedure linkresolveint(const alinks: linkindexty; const avalue: int32);
var
 li1: linkindexty;
begin
 if alinks <> 0 then begin
  li1:= alinks;
  while true do begin
   with links[li1] do begin
    pint32(getsegmentpo(dest))^:= avalue;
    if next = 0 then begin
     break;
    end;
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
 end;
end;

procedure linkmarkphi(var alinks: linkindexty; 
                            const aaddress: dataoffsty; //in seg_op
                                                const ssaindex: int32);
var
 po1: plinkinfoty;
begin
 po1:= link(alinks);
 po1^.phi.ssa:= ssaindex;
 po1^.phi.bbindex:= info.s.ssa.bbindex-1;
 po1^.phi.opsegoffset:= aaddress;
end;

procedure linkresolvephi(const alinks: linkindexty; 
                       const aaddress: opaddressty; const lastssa: int32;
                                 out philist: dataoffsty); //in seg_localloc
var
 li1: linkindexty;
 i1: int32;
 po1: pphilistty;
 po2: pphilistitemty;
begin
 philist:= 0;
 if alinks <> 0 then begin
  li1:= alinks;
  i1:= 1; //for lastssa
  while true do begin
   with links[li1] do begin
    popaddressty(getsegmentpo(seg_op,phi.opsegoffset))^:= aaddress-1;
   end;
   inc(i1);
   if links[li1].next = 0 then begin
    break;
   end;
   li1:= links[li1].next;
  end;
  if co_llvm in info.o.compileoptions then begin
   po1:= allocsegmentpo(seg_localloc,sizeof(philistty)+i1*sizeof(phiitemty));
   philist:= getsegmentoffset(seg_localloc,po1);
   with po1^ do begin
    count:= i1;
    po2:= @items;
   end;
   li1:= alinks;
   repeat
    with links[li1] do begin
     po2^.ssa:= phi.ssa;
     po2^.bbindex:= phi.bbindex;
     inc(po2);
     li1:= next;
    end;
   until li1 = 0;
   po2^.ssa:= lastssa;
   po2^.bbindex:= info.s.ssa.bbindex-1;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= alinks;
 end;
end;

procedure linkaddcast(const atype: elementoffsetty; 
                                          const acontext: pcontextitemty);
var
 po1: plinkinfoty;
begin
 with acontext^ do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_ref then begin
   internalerror(ie_handler,'20160716A');
  end;
 {$endif}
  po1:= link(d.dat.ref.castchain);
  with po1^ do begin
   cast.typedata:= atype;
   cast.olddatatyp:= d.dat.datatyp;
   cast.indirection:= d.dat.indirection;
   cast.offset:= d.dat.ref.offset;
   cast.oldflags:= d.dat.ref.c.address.flags;
  end;
  d.dat.indirection:= 0;
 end;
end;

function linkdocasts(var alinks: linkindexty; const acontext: pcontextitemty;
                                    const callback: castcallbackty): boolean;
var
 li1,li2: linkindexty;
 flags1: docastflagsty;
begin
 result:= true;
 if alinks <> 0 then begin
  li1:= alinks;
  alinks:= 0;
  linksreverse(li1);
  li2:= li1; //backup
  flags1:= [dcf_first];
  while true do begin
   with links[li1] do begin
    if not (dcf_cancel in flags1) then begin
     callback(acontext,cast,flags1);
    end;
    if next = 0 then begin
     break;
    end;
    flags1:= flags1 - [dcf_cancel,dcf_first];
    li1:= next;
   end;
  end;
  links[li1].next:= deletedlinks;
  deletedlinks:= li2;
  result:= not (dcf_cancel in flags1);
 end;
end;

function linkgetcasttype(const alinks: linkindexty): elementoffsetty;
begin
{$ifdef mse_checkinternalerror}
 if (alinks <= 0) or (alinks > high(links)) then begin
  internalerror(ie_handler,'20160711B');
 end;
{$endif}
 result:= links[alinks].cast.typedata;
end;

{
function addtypedef(const aname: identty; const avislevel: visikindsty;
                                        out aelementdata: pointer): boolean;
begin
 result:= ele.addelementdata(aname,ek_type,avislevel,aelementdata);
 if result then begin
  resolveforwardtype(aelementdata);
 end;
end;
}
type
 pendingconversionitemty = record
  typedata: elementoffsetty;
 end;
 ppendingconversionitemty = ^pendingconversionitemty;
 
type
 forwardtypeitemty = record
  header: linkheaderty;
  ref: elementoffsetty;
  name: identty;
 end;
 pforwardtypeitemty = ^forwardtypeitemty;
   
procedure markforwardtype(const atype: ptypedataty;
                                           const aforwardname: identty);
begin
 with pforwardtypeitemty(addlistitem(
                         forwardtypes,info.s.unitinfo^.forwardtypes))^ do begin
  ref:= ele.eledatarel(atype);
  name:= aforwardname;
 end;
end; 

type
 resolvedforwardtypeitemty = record
  header: linkheaderty;
  typ: ptypedataty;
 end;
 presolvedforwardtypeitemty = ^resolvedforwardtypeitemty;

 typeresolveinfoty = record
  base: pointer;
  resolver: pelementinfoty;
 end;

procedure doresolveforwardtype(var item; var data; var resolved: boolean);
var
 ps,pd: ptypedataty;
 i1: int32;
begin
 with typeresolveinfoty(data) do begin
  with forwardtypeitemty(item) do begin
   pd:= base+ref;
   if (name = resolver^.header.name) and 
            (pelementinfoty(pointer(pd))^.header.parent = 
                                 resolver^.header.parent) then begin
    pd:= pointer(pd)+eledatashift;
    if pd^.h.kind = dk_classof then begin
     pd^.infoclassof.classtyp:= ele.eleinforel(resolver);
    end
    else begin
     ps:= @resolver^.data;
     i1:= pd^.h.indirectlevel;
     pd^:= ps^;
//     pd^.h.indirectlevel:= ps^.h.indirectlevel+i1;
     pd^.h.indirectlevel:= i1;
     if pd^.h.base = 0 then begin
      pd^.h.base:= ele.eledatarel(ps);
     end;
    end;
    resolved:= true;
    with presolvedforwardtypeitemty(addlistitem(
          resolvedforwardtypes,info.s.unitinfo^.resolvedforwardtypes))^ do begin
     typ:= pd;
    end;
   end;
  end;
 end;
end;

procedure resolveforwardtype(const atype: ptypedataty;
                                        const first: boolean = true);
var
 data: typeresolveinfoty;
 p1: presolvedforwardtypeitemty;
begin
 if info.s.unitinfo^.forwardtypes <> 0 then begin
  data.base:= ele.elebase();
  data.resolver:= pointer(atype)-eledatashift;
  checkresolve(forwardtypes,@doresolveforwardtype,
                                     info.s.unitinfo^.forwardtypes,@data);
  if first then begin
   while poplistitem(resolvedforwardtypes,
                      info.s.unitinfo^.resolvedforwardtypes,p1) do begin
    resolveforwardtype(p1^.typ,false);
   end;
  end;
 end;
end;

procedure forwardtypeerror(var item);
begin
 with forwardtypeitemty(item) do begin //todo: source location
  identerror(0,name,err_forwardtypenotfound);
 end;
end;

procedure checkforwardtypeerrors();
begin
 if info.s.unitinfo^.forwardtypes <> 0 then begin
  foralllistitems(forwardtypes,@forwardtypeerror,info.s.unitinfo^.forwardtypes);
  deletelistchain(forwardtypes,info.s.unitinfo^.forwardtypes);
 end;
end;

type
 forwardinfoty = record
  prev: forwardindexty;
  next: forwardindexty;
  source: sourceinfoty;
  ident: identty;
 end;
 pforwardinfoty = ^forwardinfoty;
 forwardarty = array of forwardinfoty;

var
 forwards: forwardarty; //[0] -> dummy entry
 forwardindex: forwardindexty;
 deletedforwards: forwardindexty;

procedure forwardmark(out aforward: forwardindexty; 
                         const asource: sourceinfoty; const aident: identty);
var
 fo1: forwardindexty;
 po1: pforwardinfoty;
begin
 fo1:= deletedforwards;
 if fo1 = 0 then begin
  inc(forwardindex);
  if forwardindex > high(forwards) then begin
   reallocuninitedarray(high(forwards)*2+1024,sizeof(forwards[0]),forwards);
  end;
  fo1:= forwardindex;
  po1:= @forwards[fo1];
 end
 else begin
  po1:= @forwards[fo1];
  deletedforwards:= po1^.next;
 end;
 with info.s.unitinfo^ do begin
  po1^.prev:= 0;
  po1^.next:= forwardlist;
  po1^.source:= asource;
  po1^.ident:= aident;
  forwards[forwardlist].prev:= fo1;
  forwardlist:= fo1;
 end;
 aforward:= fo1;
end;

procedure forwardresolve(const aforward: forwardindexty);
begin
 if aforward <> 0 then begin
  with forwards[aforward] do begin
   if info.s.unitinfo^.forwardlist = aforward then begin
    info.s.unitinfo^.forwardlist:= next;
   end;
   forwards[next].prev:= prev;
   forwards[prev].next:= next;
   next:= deletedforwards;
  end;
  deletedforwards:= aforward;
 end;
end;

procedure checkforwarderrors(const aforward: forwardindexty);
var
 fo1: forwardindexty;
begin
 fo1:= aforward;
 while fo1 <> 0 do begin
  with forwards[fo1] do begin
   errormessage(source,err_forwardnotsolved,[getidentname(ident)]);
                      //todo show header
   fo1:= next;
  end;
 end;
end;

procedure resolveclassdescend(var itemdata);
begin
 with classdescendinfoty(itemdata) do begin
  copyvirtualtable(source,dest,itemcount);
 end;
end;

function getexitcodeaddress: segaddressty;
var
 ele1: elementoffsetty;
begin
 if not ele.findchild(info.rtlunits[rtl_system]^.interfaceelement,tk_exitcode,
                                           [ek_var],allvisi,ele1) then begin
  internalerror1(ie_parser,'20150831A');
 end;
 result:= trackaccess(pvardataty(ele.eledataabs(ele1))).segaddress;
end;

procedure updateprogend(const aop: popinfoty);
begin
 aop^.par.progend.exitcodeaddress:= getexitcodeaddress();
// aop^.par.progend.submeta:= info.s.currentscopemeta;
end;

procedure handleunitend();
var
 int1: integer;
 ad1: listadty;
begin
 with info,s.unitinfo^ do begin
  checkpendingmanagehandlers();
  codestop:= opcount;
  checkforwarderrors(forwardlist);
  for int1:= 0 to pendingcount-1 do begin
   with ptypedataty(ele.eledataabs(pendings[int1].ref))^ do begin
    include(infoclass.flags,icf_virtualtablevalid);
    resolvelist(classdescendlist,@resolveclassdescend,
                                              infoclass.pendingdescends);
   end;
  end;
  pendings:= nil;
  include(state,us_end);
 end;
end;

procedure handleinitializationstart();
var
 ad1: opaddressty;
begin
{$ifdef mse_debugparser}
 outhandle('INITIALIZATIONSTART');
{$endif}
 checkforwardtypeerrors();
 getinternalsub(isub_ini,ad1);
 writemanagedvarop(mo_ini,info.s.unitinfo^.varchain,info.s.stacktop);
{
 with info,unitinfo^ do begin
  initializationstart:= opcount;
 end;
}
end;

procedure handleinitialization();
begin
{$ifdef mse_debugparser}
 outhandle('INITIALIZATION');
{$endif}
{$ifdef mse_checkinternalerror}
 if ele.parentelement^.header.kind <> ek_implementation then begin
  internalerror(ie_handler,'20170821B');
 end;
{$endif}
 addlabel();
 with pimplementationdataty(ele.parentdata)^ do begin
  linkresolveopad(exitlinks,info.opcount-1);
  exitlinks:= 0;
 end;
 endsimplesub(false);
{
 with info,unitinfo^ do begin
   initializationstop:= opcount;
  if opcount <> initializationstart then begin
   with additem(oc_goto)^ do begin
//    setop(op,oc_goto);
//    op:= @gotoop; //address set in handleinifini
   end;
  end;
 end;
}
end;

procedure handlefinalizationstart();
var
 ad1: opaddressty;
begin
{$ifdef mse_debugparser}
 outhandle('FINALIZATIONSTART');
{$endif}
 checkforwardtypeerrors();
 getinternalsub(isub_fini,ad1);
{
 with info,unitinfo^ do begin
  finalizationstart:= opcount;
 end;
}
end;

procedure handlefinalization();
begin
{$ifdef mse_debugparser}
 outhandle('FINALIZATION');
{$endif}
{$ifdef mse_checkinternalerror}
 if ele.parentelement^.header.kind <> ek_implementation then begin
  internalerror(ie_handler,'20170821B');
 end;
{$endif}
 addlabel();
 linkresolveopad(pimplementationdataty(ele.parentdata)^.exitlinks,
                                                      info.opcount-1);
 writemanagedvarop(mo_fini,info.s.unitinfo^.varchain,info.s.stacktop);
 endsimplesub(false);
{
 with info,unitinfo^ do begin
  if opcount <> finalizationstart then begin
   finalizationstop:= opcount;
   with additem(oc_goto)^ do begin
//    setop(op,oc_goto); //address set in handleinifini
   end;
  end;
 end;
}
end;
(*
procedure handleinifini();
var
 start1: opaddressty;
 unit1: punitinfoty;
 ad1: listadty;
 opad1: opaddressty;
 po1: popinfoty;
begin
 with info,unitlinklist do begin
  unit1:= nil; //compiler warning

  start1:= 0;
  ad1:= unitchain;
  po1:= getoppo(0);
  while ad1 <> 0 do begin         //insert ini calls
   with punitlinkinfoty(list+ad1)^ do begin
    with ref^ do begin
     if inistart <> 0 then begin
      if start1 = 0 then begin
       start1:= inistart;
      end
      else begin
       if unit1^.initializationstop <> 0 then begin
        po1[unit1^.initializationstop].par.opaddress:= inistart-1; //goto
       end
       else begin
        po1[unit1^.inistop].par.opaddress:= inistart-1;          //goto
       end;
      end;
      unit1:= ref;
     end;
     if initializationstop <> 0 then begin
      if start1 = 0 then begin
       start1:= initializationstart;
      end
      else begin
       if inistop <> 0 then begin
        po1[inistop].par.opaddress:= initializationstart-1;      //goto
       end
       else begin
        opad1:= unit1^.inistop;
        if opad1 = 0 then begin
         opad1:= unit1^.finalizationstop;
        end; 
        po1[opad1].par.opaddress:= initializationstart-1;        //goto
       end;
      end;
      unit1:= ref;
     end;
     ad1:= header.next;
    end;
   end;
  end;
  if start1 <> 0 then begin
   opad1:= unit1^.initializationstop;
   if opad1 = 0 then begin
    opad1:= unit1^.inistop;
   end;
   po1[opad1].par.opaddress:= po1[startupoffsetnum].par.opaddress; //goto
   include(po1[po1[startupoffsetnum].par.opaddress].op.flags,opf_label);
   po1[startupoffsetnum].par.opaddress:= start1-1; //inject ini code
   include(po1[start1].op.flags,opf_label);
  end;

  invertlist(unitlinklist,unitchain);
  start1:= 0;
  ad1:= unitchain;
  while ad1 <> 0 do begin //append fini calls
   with punitlinkinfoty(list+ad1)^ do begin
    with ref^ do begin
     if finalizationstop <> 0 then begin
      if start1 = 0 then begin
       start1:= finalizationstart;
      end
      else begin
       if unit1^.finalizationstop <> 0 then begin
        po1[unit1^.finalizationstop].par.opaddress:= finalizationstart-1; 
                                                                   //goto
       end
       else begin
        po1[unit1^.finistop].par.opaddress:= finalizationstart-1;  //goto
       end;
      end;
      unit1:= ref;
     end;
     if finistart <> 0 then begin
      if start1 = 0 then begin
       start1:= finistart;
      end
      else begin
       if finalizationstop <> 0 then begin
        po1[finalizationstop].par.opaddress:= finistart-1;        //goto
       end
       else begin
        if unit1^.finalizationstop <> 0 then begin
         po1[unit1^.finalizationstop].par.opaddress:= finistart-1; 
                                                                 //goto
        end
        else begin
         po1[unit1^.finistop].par.opaddress:= finistart-1;       //goto
        end;
       end;
      end;
      unit1:= ref;
     end;
     ad1:= header.next;
    end;
   end;
  end;
  if start1 <> 0 then begin
   with po1[unitinfo^.codestop] do begin
    op.op:= oc_goto;
//    setop(op,oc_goto);
    par.opaddress:= start1-1;
    include(po1[start1].op.flags,opf_label);
   end;
   opad1:= unit1^.finistop;
   if opad1 = 0 then begin
    opad1:= unit1^.finalizationstop;
   end;
   po1[opad1].op.op:= oc_progend;         //stop
  end;

 end;
end;
*)

procedure beginunit(const aunit: punitinfoty);
begin
 if aunit^.llvmlists <> nil then begin
  aunit^.llvmlists.metadatalist.beginunit();
 end;
{
 aunit^.param1poallocs:= nullallocs;          //init
 with aunit^,param1poallocs do begin
  allocs:= getsegmenttopoffs(seg_localloc);
  with plocallocinfoty(allocsegmentpo(seg_localloc,
                                    sizeof(locallocinfoty)))^ do begin
   address:= 0;
   flags:= [];
   size:= bitoptypes[das_pointer];
   if (info.debugoptions <> []) and (co_llvm in info.compileoptions) then begin
    debuginfo:= llvmlists.metadatalist.pointertyp;
   end
   else begin
    debuginfo:= dummymeta;
   end;
  end;
  alloccount:= 1;
  paramcount:= 1;
  nestedallocs:= 0;
  nestedalloccount:= 0;
  nestedallocstypeindex:= -1;
 end;
}
end;

procedure endparser();
var
 ele1: elementoffsetty;
begin
 with getoppo(startupoffsetnum)^.par.beginparse do begin
  unitinfochain:= info.unitinfochain;
 end;
 if not info.modularllvm then begin
  with additem(oc_endparse)^ do begin
  end;
 end;
end;

function endunit(const aunit: punitinfoty): boolean;
var
 m1,m2: metavaluety;
 po1: pdicompileunitty;
begin
 result:= true;
 with info do begin
  if (do_proginfo in s.debugoptions) and (aunit^.llvmlists <> nil) then begin
   with aunit^.llvmlists.metadatalist do begin
    m1.id:= -1;
    m2.id:= -1;
    if aunit^.subprograms.count > 0 then begin
     m1:= addnode(aunit^.subprograms);
    end;
    if aunit^.globalvariables.count > 0 then begin
     m2:= addnode(aunit^.globalvariables);
    end;
    po1:= getdata(aunit^.compileunitmeta);
    if m1.id >= 0 then begin
     po1^.subprograms:= m1;
    end;
    if m2.id >= 0 then begin
     po1^.globalvariables:= m2;
    end;
   end;
  end;
  if unitlevel = 1 then begin
   endparser();
  end;
  initcompilersubs(aunit);
  if modularllvm then begin
   result:= writeunitfile(aunit);
   freeandnil(aunit^.llvmlists);
  end;
 end;
end;

procedure finalizeunit(const aunit: punitinfoty);
begin
 with aunit^ do begin
  if llvmlists <> globllvmlists then begin
   freeandnil(llvmlists);
  end;
  usescache.free();
 end;
end;

function bcfiles(): filenamearty;
begin
 result:= unitlist.bcfiles();
end;

function objfiles(): filenamearty;
begin
 result:= unitlist.objfiles();
end;

procedure deletetempfile(const afile: filenamety);
begin
 if not (co_keeptmpfiles in info.o.compileoptions) then begin
  trydeletefile(afile);
 end;
end;

procedure clear;
begin
 clearlist(classdescendlist,sizeof(classdescendinfoty),256);
 clearlist(unitlinklist,sizeof(unitlinkinfoty),256);
 clearlist(intfparsedlinklist,sizeof(unitlinkinfoty),256);
 clearlist(forwardtypes,sizeof(forwardtypeitemty),256);
 clearlist(resolvedforwardtypes,sizeof(resolvedforwardtypeitemty),256);
 clearlist(trystacklist,sizeof(trystackitemty),256);
 clearlist(tempvarlist,sizeof(tempvaritemty),256);
 clearlist(managedtemplist,sizeof(managedtempitemty),256);
 clearlist(pendingclassitems,sizeof(classpendingitemty),32);
 unitchain:= 0;
 intfparsedchain:= 0;
  
 links:= nil;
 linkindex:= 0;
 deletedlinks:= 0;
 
 forwards:= nil;
 forwardindex:= 0;
 deletedforwards:= 0;
end;

procedure init;
begin
 clear;
 unitlist:= tunitlist.create;
end;

procedure deinit(const freeunitlist: boolean);
begin
 clear;
 if freeunitlist then begin
  unitlist.free;
 end;
end;

end.
