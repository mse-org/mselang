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

{$define mse_implicittryfinally}

unit subhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 globtypes,stackops,parserglob,handlerglob,listutils,opglob,msetypes;

type
 paramupdateinfoty = record
  varele: elementoffsetty;
//  size: int32;
 end;
 pparamupdateinfoty = ^paramupdateinfoty;
 paramupdatechainty = record
  next: dataoffsty; //in seg_temp
  sub: elementoffsetty;
  count: int32;
  data: record //array[0..count-1] of paramupdateinfoty
  end;
 end;
 pparamupdatechainty = ^paramupdatechainty;
 
const
 stacklinksize = sizeof(frameinfoty);
{
type
 externallinkinfoty = record
  header: linkheaderty;
  sub: elementoffsetty;
 end;
 pexternallinkinfoty = ^externallinkinfoty;
}
type
 dosubflagty = (dsf_indirect,dsf_isinherited,dsf_ownedmethod,dsf_indexedsetter,
                dsf_instanceonstack,dsf_classdefonstack,dsf_nooverloadcheck,
                dsf_useobjssa,dsf_useinstancetype,
                dsf_usedestinstance, //use d.dat.fact.instancessa
                dsf_noinstancecopy,dsf_noparams,{dsf_noparamscheck,}
                dsf_nofreemem, //for object destructor
                dsf_readsub,dsf_writesub,
                dsf_attach, //afterconstruct or beforedestruct
                dsf_destroy,
                dsf_noconstructor, //constructor called from constructor
                dsf_objassign,
                dsf_objconvert,
                dsf_objini,dsf_objfini);  //from objectmanagehandler
 dosubflagsty = set of dosubflagty;

 simplesuboptionty = (sso_pointerparam,sso_global,sso_globheader);
 simplesuboptionsty = set of simplesuboptionty;


 tempvaritemty = record
  header: linkheaderty;
  address: addressvaluety;
  case integer of
   0: (
    typeele: elementoffsetty; //typedataty if address.flags af_tempvar set
   );
   1: (
    typeid: int32; //llvm typeid if address.flags af_tempvar not set
   );
 end;
 ptempvaritemty = ^tempvaritemty;
var
 tempvarlist: linklistty;

procedure callsub(const adestindex: int32; asub: psubdataty;
                 const paramstart,paramco: int32; aflags: dosubflagsty;
                          const aobjssa: int32 = 0; const aobjsize: int32 = 0;
                                              ainstancetype: ptypedataty = nil);
procedure handleparamsdefentry();
procedure handleparamsdef();
procedure handleparamdef0entry();

procedure handleparams0entry();
procedure setconstparam();
procedure setconstrefparam();
procedure setvarparam();
procedure setoutparam();
procedure handleuntypedparam();
procedure handleparamdef3();
procedure handleparamdefault();
procedure handleparamsend();
procedure handlenoparamsend();
//procedure handlesubheader();

procedure handleclassprocedureentry();
procedure handleclassfunctionentry();
procedure handleclassmethodentry();
procedure handleprocedureentry();
procedure handlefunctionentry();
procedure handlemethodentry();
procedure handlesubentry();
procedure handleproceduretypedefentry();
procedure handlefunctiontypedefentry();
procedure handlesubtypedefentry();
procedure handlemethodtypedefentry();
procedure handlesubtypedef0entry();

//procedure handleclasubheaderentry();
procedure callsubheaderentry();
procedure callclasubheaderentry();

procedure checkfunctiontype();
procedure handlesub1entry();
procedure handlevirtual();
procedure handleoverride();
procedure handleclasubheaderattach();
procedure handlesubheaderattach();
procedure handleoverload();
procedure handleexternal();
procedure handleexternal0entry();
procedure handleexternal0();
procedure handleexternal1();
procedure handleexternal2();
procedure handleforward();
procedure handleofobjectexpected();
procedure subofentry();
procedure handlesubheader();
//procedure subbody4entry();
procedure handlesubbody5a();
procedure handlesubbody6();

procedure handlebeginexpected();
procedure handleendexpected();
procedure handleimplementationexpected();

function checkparams(const po1,ref: psubdataty): boolean; 
                  //paramcount an subkind must be equal
function checkparamsbase(const po1,ref: psubdataty): boolean;
               //compare base types
function getinternalsub(const asub: internalsubty;
                         out aaddress: opaddressty): boolean; //true if new
function callinternalsub(const asub: opaddressty;
                                   const stackindex: int32 = bigint): popinfoty;
                                                        //ignores op address 0
{
function callinternalsub(const aunit: punitinfoty; const asubid: int32;
                                   const stackindex: int32 = bigint): popinfoty;
}
function callinternalsub(const aunit: punitinfoty; const asub: internalsubty;
                                   const stackindex: int32 = bigint): popinfoty;
function callinternalsubpo(const asub: pinternalsubdataty{opaddressty};
                            const pointerparamssa: int32; 
                                   const stackindex: int32 = bigint): popinfoty;
                                                        //ignores op address 0
function callinternalsubpo(const asub: psubdataty{opaddressty};
                            const pointerparamssa: int32; 
                                   const stackindex: int32 = bigint): popinfoty;
procedure initsubstartinfo();
procedure begintempvars();
procedure endtempvars();
procedure settempvars(var allocs: suballocllvmty);
function startsimplesub(const aname: identty; const options: simplesuboptionsty;
                                   const aglobname: identty = 0): opaddressty;
function startsimplesub(const asub: pinternalsubdataty; 
                               const options: simplesuboptionsty;
                                     const aglobname: identty = 0): opaddressty;
procedure endsimplesub(const pointerparam: boolean);
procedure setoperparamid(var dest: identvecty; const aindirectlevel: int32;
                                                 const atyp: ptypedataty);
                                                        //0 -> void
procedure updateparams(const info: paramupdatechainty);

implementation
uses
 errorhandler,handlerutils,elements,opcode,unithandler,handler,interfacehandler,
 managedtypes,segmentutils,classhandler,llvmlists,__mla__internaltypes,
 msestrings,typehandler,exceptionhandler,identutils,llvmbitcodes,parser,
 valuehandler,elementcache,grammarglob,compilerunit;

type
 tmetadatalist1 = class(tmetadatalist);
 equalparaminfoty = record
  ref: psubdataty;
  match: psubdataty;
 end;

const
 internalsubidents: array[internalsubty] of identty  =
                        //isub_ini,isub_fini
                         (tks_ini, tks_fini);
 
function getinternalsub(const asub: internalsubty;
                                   out aaddress: opaddressty): boolean;
var
 scope1: metadataty;
begin
 with info,s.unitinfo^ do begin
  aaddress:=  internalsubs[asub];
  result:= aaddress = 0;
  if result then begin
   aaddress:= startsimplesub(internalsubidents[asub],[sso_global]);
   internalsubs[asub]:= aaddress;
   internalsubnames[asub]:= nameid{-1};
  end;
 end;
end;

function callinternalsub(const asub: opaddressty;
                                   const stackindex: int32 = bigint): popinfoty;
begin
 result:= insertitem(oc_call,stackindex-info.s.stackindex,-1);
 with result^.par.callinfo do begin
  if asub <> 0 then begin
   ad.globid:= getoppo(asub)^.par.subbegin.globid;
   ad.ad:= asub-1; //compensate inc(pc)
  end;
  flags:= [];
  linkcount:= 0;
  paramcount:= 0;
 end;
end;
{
function callinternalsub(const aunit: punitinfoty; const asubid: int32;
                                   const stackindex: int32 = bigint): popinfoty;
begin
 result:= insertitem(oc_call,stackindex-info.s.stackindex,-1);
 with result^.par.callinfo do begin
  ad.globid:= tracksimplesubaccess(aunit,asubid);
  flags:= [];
  linkcount:= 0;
  paramcount:= 0;
 end;
end;
}
function callinternalsub(const aunit: punitinfoty; const asub: internalsubty;
                                   const stackindex: int32 = bigint): popinfoty;
begin
 result:= insertitem(oc_call,stackindex-info.s.stackindex,-1);
 with result^.par.callinfo do begin
  if info.modularllvm then begin
   ad.globid:= tracksimplesubaccessx(aunit,aunit^.internalsubnames[asub]);
   if ad.globid < 0 then begin
    ad.globid:= getoppo(aunit^.internalsubs[asub])^.par.subbegin.globid; //local
   end;
  end;
  flags:= [];
  linkcount:= 0;
  paramcount:= 0;
 end;
end;

function callinternalsubpo(const asub: pinternalsubdataty{opaddressty};
    const pointerparamssa: int32; const stackindex: int32 = bigint): popinfoty;
begin
 result:= insertitem(oc_call,stackindex-info.s.stackindex,-1);
 with result^.par.callinfo do begin
  if info.modularllvm then begin
   ad.globid:= trackaccess(asub);
  end
  else begin
   if asub^.address <> 0 then begin
    ad.globid:= getoppo(asub^.address)^.par.subbegin.globid;
    ad.ad:= asub^.address-1; //compensate inc(pc)
   end;
  end;
  flags:= [];
  linkcount:= 0;
  paramcount:= 1;
  params:= getsegmenttopoffs(seg_localloc);
  with pparallocinfoty(allocsegmentpo(seg_localloc,
                                       sizeof(parallocinfoty)))^ do begin
   ssaindex:= pointerparamssa;
   size:= bitoptypes[das_pointer] //not used? 
  end;
 end;
end;

function callinternalsubpo(const asub: psubdataty;
    const pointerparamssa: int32; const stackindex: int32 = bigint): popinfoty;
begin
 result:= insertitem(oc_call,stackindex-info.s.stackindex,-1);
 with result^.par.callinfo do begin
  if info.modularllvm then begin
   ad.globid:= trackaccess(asub);
  end
  else begin
   if asub^.address <> 0 then begin
    ad.globid:= getoppo(asub^.address)^.par.subbegin.globid;
    ad.ad:= asub^.address-1; //compensate inc(pc)
   end;
  end;
  flags:= [];
  linkcount:= 0;
  paramcount:= 1;
  params:= getsegmenttopoffs(seg_localloc);
  with pparallocinfoty(allocsegmentpo(seg_localloc,
                                       sizeof(parallocinfoty)))^ do begin
   ssaindex:= pointerparamssa;
   size:= bitoptypes[das_pointer] //not used? 
  end;
 end;
end;

function checkparamsbase(const po1,ref: psubdataty): boolean; 
//                                  {$ifndef mse_debugparser} inline;{$endif}
var
 par1,parref: pelementoffsetaty;
 pva,pvb: pvardataty;
 offs1: ptrint;
 var1,varref: pvardataty;
 int1: integer;
// start,stop: integer;
begin
 result:= (((po1^.flags >< ref^.flags) *  //todo: sf_ofobject?
  [sf_functionx,sf_method,sf_constructor,sf_destructor]) = []) and 
                                        (po1^.paramcount = ref^.paramcount);
 if result then begin
  offs1:= ele.eledataoffset;
  pointer(par1):= @po1^.paramsrel;
  pointer(parref):= @ref^.paramsrel;
  int1:= 0;
  if sf_constructor in ref^.flags then begin
   int1:= 2; //skip result and self
  end
  else begin
   if sf_method in ref^.flags then begin
    if sf_functionx in ref^.flags then begin
     if basetype(pvardataty(par1^[0]+offs1)^.vf.typ) <> 
                   basetype(pvardataty(parref^[0]+offs1)^.vf.typ) then begin
      result:= false;
      exit;
     end;
     int1:= 2; //skip result and self
    end
    else begin
     int1:= 1; //skip self;
    end;
   end;
  end;
  for int1:= int1 to ref^.paramcount-1 do begin
   pva:= pvardataty(par1^[int1]+offs1);
   pvb:= pvardataty(parref^[int1]+offs1);
   if ((pva^.address.flags >< pvb^.address.flags) * 
        [af_param,af_paramindirect,af_const,af_paramconst,af_paramconstref,
                                   af_paramvar,af_paramout] <> []) or
         (pva^.address.indirectlevel <> pvb^.address.indirectlevel) or
                 (basetype(pva^.vf.typ) <> basetype(pvb^.vf.typ)) then begin
    result:= false;
    exit;
   end;
  end;
 end;
end;

function checkparams(const po1,ref: psubdataty): boolean; 
//                                  {$ifndef mse_debugparser} inline;{$endif}
var
 par1,parref: pelementoffsetaty;
 offs1: ptrint;
 var1,varref: pvardataty;
 int1: integer;
 pa,pb: pvardataty;
 ta,tb: ptypedataty;
 b1: boolean;

begin
 result:= true;
 offs1:= ele.eledataoffset;
 pointer(par1):= @po1^.paramsrel;
 pointer(parref):= @ref^.paramsrel;
 int1:= 0;
 if sf_constructor in ref^.flags then begin
  int1:= 2; //skip result and self
 end
 else begin
  if sf_method in ref^.flags then begin
   if sf_functionx in ref^.flags then begin
    if pvardataty(par1^[0]+offs1)^.vf.typ <> 
                  pvardataty(parref^[0]+offs1)^.vf.typ then begin
     result:= false;
     exit;
    end;
    int1:= 2; //skip result and self
   end
   else begin
    int1:= 1; //skip self;
   end;
  end;
 end;
 for int1:= int1 to ref^.paramcount-1 do begin
  pa:= pvardataty(par1^[int1]+offs1);
  pb:= pvardataty(parref^[int1]+offs1);
  b1:= ((pa^.address.flags >< pb^.address.flags) *
                                     compatibleparamflags <> []) or
                  (pa^.address.indirectlevel <> pb^.address.indirectlevel);
  if not b1 then begin
   b1:= pa^.vf.typ <> pb^.vf.typ;
   if b1 then begin
    ta:= ele.eledataabs(pa^.vf.typ);
    tb:= ele.eledataabs(pb^.vf.typ);
    if ta^.h.kind = tb^.h.kind then begin
     if (ta^.h.kind = dk_openarray) and 
      (ta^.infodynarray.i.itemindirectlevel = 
               tb^.infodynarray.i.itemindirectlevel) and
      (ta^.infodynarray.i.itemtypedata = 
               tb^.infodynarray.i.itemtypedata) then begin
      b1:= false;
     end;
    end;
   end;
  end;
  if b1 then begin
   result:= false;
   exit;
  end;
 end;
end;

procedure checkequalheader(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
var
 po1: psubdataty;
begin
 po1:= @aelement^.data;
 with equalparaminfoty(adata) do begin
  if (po1 <> ref) and 
    ((po1^.flags >< ref^.flags)*[sf_header,sf_method] = []) and
                    (po1^.paramcount = ref^.paramcount) and
                    (po1^.paramsize = ref^.paramsize) and 
                    ((po1^.flags*[sf_virtual,sf_override]<>[]) or
                                not(sf_override in ref^.flags)) and
                                            checkparams(po1,ref) then begin
   terminate:= true;
   match:= po1;
  end;
 end;
end;

procedure checkequalparam(const aelement: pelementinfoty; var adata;
                                                     var terminate: boolean);
var
 po1: psubdataty;
 int1: integer;
 par1,parref: pelementoffsetaty;
 offs1: elementoffsetty;
 var1,varref: pvardataty;
begin
 po1:= @aelement^.data;
 with equalparaminfoty(adata) do begin
  if (po1 <> ref) and (po1^.paramcount = ref^.paramcount) and 
                                    checkparams(po1,ref) then begin
   terminate:= true;
   match:= po1;
  end;
 end;
end;

procedure handleparamsdefentry();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSDEFENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  b.flags:= s.currentstatementflags;
  include(s.currentstatementflags,stf_paramsdef);
 end;
end;

procedure handleparamsdef();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSDEF');
{$endif}
 with info do begin
  with contextstack[s.stackindex] do begin
   s.currentstatementflags:= b.flags;
  end;
 end;
end;

procedure handleparamdef0entry();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMDEF0ENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_paramdef;
  paramdef.kind:= pk_value;
  paramdef.defaultconst:= 0;
 end;
end;

procedure handleparams0entry();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMS0ENTRY');
{$endif}
 with info do begin
  with contextstack[s.stackindex] do begin
   d.kind:= ck_params;
//   d.params.tempsize:= 0;
   b.flags:= s.currentstatementflags;
   include(s.currentstatementflags,stf_params);
   exclude(s.currentstatementflags,stf_cutvalueident);
  end;
 end;
end;

procedure setconstparam();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTPARAM');
{$endif}
// with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
 with info,contextstack[s.stackindex].d.paramdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_const;
 end;
end;

procedure setconstrefparam();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTREFPARAM');
{$endif}
// with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
 with info,contextstack[s.stackindex].d.paramdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_constref;
 end;
end;

procedure setvarparam();
begin
{$ifdef mse_debugparser}
 outhandle('VARPARAM');
{$endif}
// with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
 with info,contextstack[s.stackindex].d.paramdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_var;
 end;
end;

procedure setoutparam();
begin
{$ifdef mse_debugparser}
 outhandle('OUTPARAM');
{$endif}
// with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
 with info,contextstack[s.stackindex].d.paramdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_out;
 end;
end;

procedure handleuntypedparam();
begin
{$ifdef mse_debugparser}
 outhandle('UTYPEDPARAM');
{$endif}
 with info do begin
  with contextstack[s.stacktop] do begin
   d.kind:= ck_fieldtype;
   d.typ:= sysdatatypes[st_none];
  end;
 (*
  if contextstack[s.stacktop-1].d.kind = ck_ident then begin
   with contextstack[contextstack[contextstack[
                                s.stackindex].parent].parent-1] do begin
   {$ifdef mse_checkinternalerror}
    if d.kind <> ck_subdef then begin
     internalerror(ie_handler,'20170720A');
    end;
   {$endif}
    include(d.subdef.flags1,sf1_params);
   end;
  end;
 *)
 end;
end;

procedure handleparamdef3();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMDEF3');
{$endif}
 with info do begin
  if contextstack[s.stacktop].d.kind <> ck_fieldtype then begin
//  if s.stacktop-s.stackindex <> 2 then begin
   errormessage(err_typeidentexpected,[]);
(*
  end
  else begin
   if contextstack[s.stacktop-1].d.kind = ck_ident then begin
    with contextstack[contextstack[contextstack[
                                 s.stackindex].parent].parent-1] do begin
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_subdef then begin
      internalerror(ie_handler,'20170720B');
     end;
    {$endif}
     include(d.subdef.flags1,sf1_params);
    end;
   end;
*)
  end;
 end;
end;

procedure handleparamdefault();
var
 paramtype: ptypeinfoty;
 i1: int32;
 ad1: addressvaluety;
 poa,potop: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('PARAMDEFAULT');
{$endif}
 with info do begin
  potop:= @contextstack[s.stacktop];
  poa:= getpreviousnospace(potop-1); //ck_fieldtype
 {$ifdef mse_checkinternalerror}
  if contextstack[s.stackindex].d.kind <> ck_paramdef then begin
   internalerror(ie_parser,'20160520A');
  end;
  if poa^.d.kind <> ck_fieldtype then begin
   internalerror(ie_parser,'20160520B');
  end;
 {$endif}
  paramtype:= @poa^.d.typ;
  if not tryconvert(potop,ele.eledataabs(paramtype^.typedata),
                                  paramtype^.indirectlevel,[]) then begin
                                           //constref?
   incompatibletypeserror(poa^.d,potop^.d);
  end
  else begin
   if potop^.d.kind <> ck_const then begin
    errormessage(err_constexpressionexpected,[]);
   end
   else begin
    with contextstack[s.stackindex] do begin
     if d.paramdef.kind in [pk_var,pk_out] then begin
      errormessage(err_defaultvaluescanonly,[]);
     end
     else begin
      ad1.flags:= paramkinds[d.paramdef.kind];
      ad1.indirectlevel:= paramtype^.indirectlevel;
      if not tryconvert(potop,ele.eledataabs(paramtype^.typedata),
                                      paramtype^.indirectlevel,[]) then begin
                                               //constref?
       incompatibletypeserror(poa^.d,potop^.d);
      end
      else begin
      {$ifdef mse_checkinternalerror}
       if potop^.d.kind <> ck_const then begin
        internalerror(ie_parser,'20160521A');
       end;
      {$endif}
       if not ele.addelement(getident(),ek_const,
                                   allvisi,d.paramdef.defaultconst) then begin
        internalerror1(ie_parser,'20160520C'); //there is a duplicate
       end;
       with pconstdataty(ele.eledataabs(d.paramdef.defaultconst))^ do begin
        with potop^.d do begin
         val.typ:= dat.datatyp;
         val.d:= dat.constval;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  s.stacktop:= getstackindex(poa); //remove const  
 end;
end;

procedure handleparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
{
 with info do begin
  with contextstack[s.stackindex] do begin
   s.currentstatementflags:= b.flags;
  end;
 end;
}
end;

procedure handlenoparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
 tokenexpectederror(')');
end;

procedure handleclassprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSPROCEDUREENTRY');
{$endif}
 initsubdef([sf_classmethod]);
end;

procedure handleclassfunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSFUNCTIONENTRY');
{$endif}
 initsubdef([sf_classmethod,sf_functionx,sf_functioncall]);
end;

procedure handleclassmethodentry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASSMETHODENTRY');
{$endif}
 initsubdef([sf_classmethod,sf_methodtoken,sf_method]);
end;

procedure handleprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDUREENTRY');
{$endif}
 initsubdef([]);
end;

procedure handlefunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONENTRY');
{$endif}
 initsubdef([sf_functionx,sf_functioncall]);
end;

procedure handlemethodentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHODENTRY');
{$endif}
 initsubdef([sf_methodtoken,sf_method]);
end;

procedure handlesubentry();
begin
{$ifdef mse_debugparser}
 outhandle('SUBENTRY');
{$endif}
 initsubdef([sf_subtoken]);
end;

procedure handleproceduretypedefentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDURETYPEDEFENTRY');
{$endif}
 initsubdef([sf_typedef,sf_header]);
end;

procedure handlefunctiontypedefentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONTYPEDEFENTRY');
{$endif}
 initsubdef([sf_typedef,sf_header,sf_functionx,sf_functioncall]);
end;

procedure handlesubtypedefentry();
begin
{$ifdef mse_debugparser}
 outhandle('SUBTYPEDFENTRY');
{$endif}
 initsubdef([sf_typedef,sf_header,sf_subtoken]);
end;

procedure handlemethodtypedefentry();
begin
{$ifdef mse_debugparser}
 outhandle('METHODTYPEDFENTRY');
{$endif}
 initsubdef([sf_typedef,sf_header,sf_methodtoken,sf_method,sf_ofobject]);
end;

procedure handlesubtypedef0entry();
begin
{$ifdef mse_debugparser}
 outhandle('SUBTYPEDEF0ENTRY');
{$endif}
 pushdummycontext(ck_ident); //add dummy ident
 with info,contextstack[s.stacktop].d do begin 
  currenttypedef:= 0;
  ident.ident:= getident;
  ident.len:= 0;
  ident.flags:= [];
 end;
end;

procedure dosubheaderentry(const akind: contextkindty);
var
 po1: pcontextdataty;
begin
 with info,contextstack[s.stackindex].d do begin
  po1:= @contextstack[s.stackindex-1].d;
  kind:= ck_subdef;
  subdef.flags:= po1^.subdef.flags;
  subdef.flags1:= po1^.subdef.flags1;
  po1^.kind:= akind;//ck_none;
 end;
end;

procedure callclasubheaderentry();
begin
{$ifdef mse_debugparser}
 outhandle('CALLCLASUBHEADERENTRY');
{$endif}
 dosubheaderentry(ck_objsubheader);
end;
 
procedure callsubheaderentry();
var
 po1: pcontextdataty;
begin
{$ifdef mse_debugparser}
 outhandle('CALLSUBHEADERENTRY');
{$endif}
 dosubheaderentry(ck_subheader);
end;

procedure checkfunctiontype();

begin
{$ifdef mse_debugparser}
 outhandle('CHECKFUNCTIONTYPE');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  d.kind:= ck_paramdef;
  if co_hasfunction in o.compileoptions then begin
   d.paramdef.kind:= pk_value; 
           //can be changed by var-result setting in handlesubheader
  end
  else begin
   d.paramdef.kind:= pk_var;
  end;
  d.paramdef.defaultconst:= 0;
 end;
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_ident;
//  d.ident.paramkind:= pk_var;
  d.ident.ident:= tk_result;
  with contextstack[parent-1] do begin
   if s.dialect = dia_mse then begin
    if sf_functiontype in d.subdef.flags then begin
     errormessage(err_syntax,[';']);
     dec(s.stackindex,2); //remove result type
     s.stacktop:= s.stackindex;
    end;
    include(d.subdef.flags,sf_functiontype);
   end
   else begin //dia_pas
    if (d.subdef.flags * [sf_functionx,sf_methodtoken,sf_subtoken] = []) or 
                            (sf_functiontype in d.subdef.flags) then begin
     errormessage(err_syntax,[';']);
    end;
    d.subdef.flags:= d.subdef.flags+
                   [sf_functiontype,sf_functionx,sf_functioncall];
   end;
  end;
 end;
end;

procedure handlesub1entry(); //header
var
 int1: integer;
 ele1: elementoffsetty;
 po1: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('SUB1ENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  b.flags:= s.currentstatementflags;
  b.eleparent:= ele.elementparent;
  s.currentstatementflags:= s.currentstatementflags -
                                  [stf_needsmanage,stf_needsini,stf_needsfini];
  int1:= s.stacktop-s.stackindex; 
  if int1 > 1 then begin //todo: check procedure level and the like
   if ele.findupward(contextstack[s.stackindex+1].d.ident.ident,[],
             implementationvisi,ele1) = [] then begin
    identerror(1,err_identifiernotfound,erl_fatal);
   end
   else begin
    po1:= ele.eleinfoabs(ele1);
    if (po1^.header.kind <> ek_type) or 
      not (ptypedataty(@po1^.data)^.h.kind in [dk_object,dk_class]) then begin
     errormessage(err_classidentexpected,[],1);
    end
    else begin
     if int1 > 2 then begin
      errormessage(err_syntax,[';'],2);
     end
     else begin     //class sub
      include(s.currentstatementflags,stf_objimp);
      if sf_classmethod in d.subdef.flags then begin
       include(s.currentstatementflags,stf_classmethod);
      end;
      if sf_constructor in d.subdef.flags then begin
       include(s.currentstatementflags,stf_constructor);
      end;
      currentcontainer:= ele1;
      contextstack[s.stackindex+1].d.ident:= 
                                       contextstack[s.stackindex+2].d.ident;
      s.stacktop:= s.stackindex+1;
      ele.pushelementparent(
                     ptypedataty(ele.eledataabs(ele1))^.infoclass.implnode);
     end;
    end;
   end;
  end
  else begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_subdef then begin
    internalerror(ie_handler,'20170509A');
   end;
  {$endif}
   if d.subdef.flags * [sf_method,sf_ofobject] = [sf_method] then begin
    if not (contextstack[parent].d.kind in 
                        [ck_typetype,ck_objsubheader]) then begin
     errormessage(err_objectorclasstypeexpected,[]);
    end;
   end;
   s.currentstatementflags:= s.currentstatementflags -
                                                [stf_objimp,stf_classmethod];
  end;
 end;
end;

function checkclassdef(const astackindex: int32; 
                                        const avirtual: boolean): boolean;
begin
 result:= true;
 with info,contextstack[astackindex] do begin
  if not (stf_objdef in s.currentstatementflags) then begin
   result:= false;
   if stf_implementation in s.currentstatementflags then begin
    handlebeginexpected();
   end
   else begin
    handleimplementationexpected();
   end
  end
  else begin
   if avirtual then begin
    with ptypedataty(ele.eledataabs(info.currentcontainer))^ do begin
     if not (icf_virtual in infoclass.flags) then begin
      errormessage(err_missingobjectattachment,['virtual']);
      result:= false;
     end;
    end;
   end;
  end
 end;
end;

procedure handlevirtual();
begin
{$ifdef mse_debugparser}
 outhandle('VIRTUAL');
{$endif}
 if checkclassdef(info.s.stackindex-1,true) then begin
  with info,contextstack[s.stackindex-1] do begin
   if d.subdef.flags * [sf_virtual,sf_override] <> [] then begin
    errormessage(err_procdirectiveconflict,['virtual']);
   end
   else begin
    include(d.subdef.flags,sf_virtual);
   end;
  end;
 end;
end;

procedure handleoverride();
begin
{$ifdef mse_debugparser}
 outhandle('OVERRIDE');
{$endif}
 if checkclassdef(info.s.stackindex-1,true) then begin
  with info,contextstack[s.stackindex-1] do begin
   if d.subdef.flags * [sf_virtual,sf_override] <> [] then begin
    errormessage(err_procdirectiveconflict,['override']);
   end
   else begin
    include(d.subdef.flags,sf_override);
   end;
  end;
 end;
end;
 
procedure handleclasubheaderattach();
var
// i1: int32;
 o1: objectoperatorty;
 subdefindex: int32;
 p1,pe: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('CLASUBHEADERATTACH');
{$endif}
 with info do begin
  subdefindex:= contextstack[s.stackindex].parent+1;
  with contextstack[subdefindex] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_subdef then begin
    internalerror(ie_handler,'20170504A');
   end;
  {$endif}
   p1:= @contextstack[s.stackindex+3];
   pe:= @contextstack[s.stacktop];
   while p1 <= pe do begin
    case p1^.d.kind of
     ck_ident: begin
      case p1^.d.ident.ident of
       tk_noexception: begin
        include(d.subdef.flags,sf_noimplicitexception);
       end;
       tk_operator: begin
        inc(p1);
        if (p1 <= pe) and (p1^.d.kind = ck_stringident) then begin
         if not (sf_operator in d.subdef.flags) then begin
          include(d.subdef.flags,sf_operator);
          currentoperator:= p1^.d.ident.ident;
         end
         else begin
          errormessage(err_multipleoperators,[],p1);
         end;
        end
        else begin
         if p1 > pe then begin
          dec(p1);
         end;
         errormessage(err_stringexpected,[],p1);
        end;
       end;
       tk_operatorright: begin
        inc(p1);
        if (p1 <= pe) and (p1^.d.kind = ck_stringident) then begin
         if not (sf_operatorright in d.subdef.flags) then begin
          include(d.subdef.flags,sf_operatorright);
          currentoperatorright:= p1^.d.ident.ident;
         end
         else begin
          errormessage(err_multipleoperators,[],p1);
         end;
        end
        else begin
         if p1 > pe then begin
          dec(p1);
         end;
         errormessage(err_stringexpected,[],p1);
        end;
       end;
       tk_virtual: begin
        if checkclassdef(subdefindex,true) then begin
         if d.subdef.flags * [sf_virtual,sf_override] <> [] then begin
          errormessage(err_procdirectiveconflict,['virtual']);
         end
         else begin
          include(d.subdef.flags,sf_virtual);
         end;
        end;
       end;
       tk_override: begin
        if checkclassdef(subdefindex,true) then begin
         if d.subdef.flags * [sf_virtual,sf_override] <> [] then begin
          errormessage(err_procdirectiveconflict,['override']);
         end
         else begin
          include(d.subdef.flags,sf_override);
         end;
        end;
       end;
       tk_new: begin
        include(d.subdef.flags1,sf1_new);
       end;
       tk_dispose: begin
        include(d.subdef.flags1,sf1_dispose);
       end;
       tk_afterconstruct: begin
        include(d.subdef.flags1,sf1_afterconstruct);
       end;
       tk_beforedestruct: begin
        include(d.subdef.flags1,sf1_beforedestruct);
       end;
       tk_ini: begin
        include(d.subdef.flags1,sf1_ini);
       end;
       tk_fini: begin
        include(d.subdef.flags1,sf1_fini);
       end;
       tk_incref: begin
        include(d.subdef.flags1,sf1_incref);
       end;
       tk_decref: begin
        include(d.subdef.flags1,sf1_decref);
       end;
       tk_default: begin
        include(d.subdef.flags1,sf1_default);
       end;
       else begin
        identerror(p1,p1^.d.ident.ident,err_invalidattachment);
       end;
      end;
     end;
     else begin
      internalerror1(ie_handler,'20170501A');
     end;
    end;
    inc(p1);
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

const
 allsubattachflags = [sf_forward,sf_external];

procedure handlesubheaderattach();
var
// i1: int32;
 o1: objectoperatorty;
 subdefindex: int32;
 p1,pe: pcontextitemty;
begin
{$ifdef mse_debugparser}
 outhandle('SUBHEADERATTACH');
{$endif}
 with info do begin
  subdefindex:= contextstack[s.stackindex].parent-1;
  with contextstack[subdefindex] do begin
  {$ifdef mse_checkinternalerror}
   if d.kind <> ck_subdef then begin
    internalerror(ie_handler,'20170504A');
   end;
  {$endif}
   if sf_method in d.subdef.flags then begin
    errormessage(err_attachnotallowed,[]);
   end
   else begin
    p1:= @contextstack[s.stackindex+3];
    pe:= @contextstack[s.stacktop];
    while p1 <= pe do begin
     case p1^.d.kind of
      ck_ident: begin
       case p1^.d.ident.ident of
        tk_forward: begin
         if d.subdef.flags * allsubattachflags <> [] then begin
          errormessage(err_invaliddirective,['forward']);
         end
         else begin
          d.subdef.flags:= d.subdef.flags + [sf_forward,sf_header];
         end;
        end;
        tk_external: begin
         if sublevel > 0 then begin
          errormessage(err_cannotdeclarelocalexternal,[]);
         end;
         if d.subdef.flags * allsubattachflags <> [] then begin
          errormessage(err_invaliddirective,['external']);
         end
         else begin
          d.subdef.flags:= d.subdef.flags + [sf_external,sf_header];
          if (p1+1)^.d.kind = ck_stringident then begin
           inc(p1);
           d.subdef.libname:= p1^.d.ident.ident;
          end;
         end;
        end;
        tk_name: begin
         d.subdef.flags:= d.subdef.flags + [{sf_external,}sf_header];
         if (p1+1)^.d.kind = ck_stringident then begin
          inc(p1);
          d.subdef.funcname:= p1^.d.ident.ident;
         end
         else begin
          errormessage(err_invalidattachmentvalue,[],p1);
         end;
        end;
        tk_noexception: begin
         include(d.subdef.flags,sf_noimplicitexception);
        end;
        else begin
         identerror(p1,p1^.d.ident.ident,err_invalidattachment);
        end;
       end;
      end;
      ck_stringident: begin
       errormessage(err_invalidattachmentvalue,[],p1);
      end;
      else begin
       internalerror1(ie_handler,'20180723A');
      end;
     end;
     inc(p1);
    end;
   end;
  end;
  dec(s.stackindex);
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleoverload();
begin
{$ifdef mse_debugparser}
 outhandle('OVERLOAD');
{$endif}
 //ignored
end;

procedure handleexternal();
begin
{$ifdef mse_debugparser}
 outhandle('EXTERNAL');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if sublevel > 0 then begin
   errormessage(err_cannotdeclarelocalexternal,[]);
  end;
  if (stf_objimp in s.currentstatementflags) then begin
   errormessage(err_invaliddirective,['external']);
  end
  else begin
   d.subdef.flags:= d.subdef.flags + [sf_external,sf_header];
  end;
 end;
end;

procedure handleexternal0entry();
begin
{$ifdef mse_debugparser}
 outhandle('EXTERNAL0ENTRY');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_subdef then begin
   internalerror(ie_handler,'20171011A');
  end;
 {$endif}
  if sublevel > 0 then begin
   errormessage(err_cannotdeclarelocalexternal,[]);
  end;
  if (stf_objimp in s.currentstatementflags) then begin
   errormessage(err_invaliddirective,['external']);
  end
  else begin
   d.subdef.flags:= d.subdef.flags + [sf_external,sf_header];
   d.subdef.libname:= 0;
   d.subdef.funcname:= 0;
  end;
 end;
end;

procedure handleexternal0();
begin
{$ifdef mse_debugparser}
 outhandle('EXTERNAL0');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (d.kind <> ck_const) or (d.dat.constval.kind <> dk_string) or 
                      (strf_empty in d.dat.constval.vstring.flags) then begin
   errormessage(err_libnameexpected,[]);
  end
  else begin
  {$ifdef mse_checkinternalerror}
   if contextstack[s.stackindex-1].d.kind <> ck_subdef then begin
    internalerror(ie_handler,'20171011B');
   end;
  {$endif}
   contextstack[s.stackindex-1].d.subdef.libname:= 
                                           getident(d.dat.constval.vstring);
  end;
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleexternal1();
begin
{$ifdef mse_debugparser}
 outhandle('EXTERNAL1');
{$endif}
end;

procedure handleexternal2();
begin
{$ifdef mse_debugparser}
 outhandle('EXTERNAL2');
{$endif}
 with info,contextstack[s.stacktop] do begin
  if (d.kind <> ck_const) or (d.dat.constval.kind <> dk_string) or 
                      (strf_empty in d.dat.constval.vstring.flags) then begin
   errormessage(err_functionnameexpected,[]);
  end
  else begin
  {$ifdef mse_checkinternalerror}
   if contextstack[s.stackindex-1].d.kind <> ck_subdef then begin
    internalerror(ie_handler,'20171011B');
   end;
  {$endif}
   contextstack[s.stackindex-1].d.subdef.funcname:= 
                               getident(d.dat.constval.vstring);
  end;
  s.stacktop:= s.stackindex;
 end;
end;

procedure handleforward();
begin
{$ifdef mse_debugparser}
 outhandle('FORWARD');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  if (stf_objdef in s.currentstatementflags) then begin
   errormessage(err_invaliddirective,['forward']);
  end
  else begin
   d.subdef.flags:= d.subdef.flags + [sf_forward,sf_header];
  end;
 end;
end;

procedure handleofobjectexpected();
begin
{$ifdef mse_debugparser}
 outhandle('OFOBJECTEXPECTED');
{$endif}
 with info do begin
  errormessage(err_syntax,['object']);
 end;
end;

procedure subofentry();
begin
{$ifdef mse_debugparser}
 outhandle('SUBOFENTRY');
{$endif}
 with info do begin
  with contextstack[s.stackindex-1] do begin
   d.subdef.flags:= d.subdef.flags + [sf_ofobject,sf_method];
  end;
 end;
end;

procedure addsubbegin(const aop: opcodety; const asub: psubdataty);
begin
{$ifdef mse_checkinternalerror}
 if not ((aop = oc_subbegin) or (aop = oc_externalsub)) then begin
  internalerror(ie_handler,'20150424A');
 end;
{$endif}
 with info do begin
  asub^.address:= opcount;
  with additem(aop,0)^ do begin
   par.subbegin.subname:= asub^.address;
   par.subbegin.globid:= asub^.globid;
//   par.subbegin.submeta:= asub^.submeta;
   par.subbegin.sub.flags:= asub^.flags;
   par.subbegin.sub.allocs:= asub^.allocs; 
                  //will be updated for llvm nested vars
   if not (co_llvm in o.compileoptions) then begin
    par.subbegin.sub.allocs.stackop.varsize:= 0; //will be updated at subend
   end;
  end;
 {$ifdef mse_checkinternalerror}
  if s.trystack <> 0 then begin
   internalerror(ie_handler,'20150507A');
  end;
 {$endif}
  s.trystacklevel:= 0;
 end;
end;

procedure addsubend(const asub: psubdataty);
begin
 with additem(oc_subend)^ do begin
  par.subend.flags:= asub^.flags;
  par.subend.submeta:= asub^.submeta;
  par.subend.allocs:= asub^.allocs;
 end;
 with info do begin
  deletelistchain(trystacklist,s.trystack); //normally already empty
  s.trystacklevel:= 0;
 end;
end;

procedure initsubstartinfo();
begin
 with info do begin
//  frameoffset:= 0;
//  stacktempoffset:= 0;
  llvmtempcount:= 0;
  firstllvmtemp:= -1;
//  lastllvmtemp:= -1;
  tempvarcount:= 0;
  tempvarchain:= 0;
  managedtempcount:= 0;
  managedtempchain:= 0;
  managedtempref:= 0;
  managedtemparrayid:= 0;
 end;
end;

function startsimplesub1(const aname: identty;
               const options: simplesuboptionsty; const aglobname: identty;
                                          out aglobid,anameid: int32): opaddressty;
var
 m1: metavaluety;
 var1: vardataty;
 i1: int32;
begin
 aglobid:= -1;
 anameid:= -1;
 with info do begin
  if do_proginfo in s.debugoptions then begin
   if sso_pointerparam in options then begin
    m1:= s.unitinfo^.llvmlists.metadatalist.params1posubtyp;
   end
   else begin
    m1:= s.unitinfo^.llvmlists.metadatalist.noparamssubtyp;
   end;
   pushcurrentscope(s.unitinfo^.llvmlists.metadatalist.adddisubprogram(
           s.currentscopemeta,getidentname2(aname),
              s.currentfilemeta,s.source.line,-1,m1,[],true));
  end;
  initsubstartinfo();
//  managedtemparrayid:= locallocid;  
  managedtemparrayid:= locallocid;  
  resetssa();
  result:= opcount;
  simplesubstart:= opcount;
  with additem(oc_subbegin)^.par do begin
   subbegin.subname:= result;
   
   if co_llvm in o.compileoptions then begin
    with s.unitinfo^ do begin
     if sso_global in options then begin
      if sso_pointerparam in options then begin
       subbegin.globid:= llvmlists.globlist.addsubvalue([],li_external,
                                                                params1po);
      end
      else begin
       subbegin.globid:= llvmlists.globlist.addsubvalue([],li_external,
                                                                noparams);
      end;
      if not (sso_globheader in options) then begin
       if aglobname > 0 then begin
        llvmlists.globlist.namelist.addname(getidentname2(aglobname),
                                                             subbegin.globid);
       end
       else begin
//        inc(info.s.unitinfo^.nameid);
        anameid:= getunitnameid();
        llvmlists.globlist.namelist.addname(info.s.unitinfo,
                                                   anameid,subbegin.globid);
       end;
      end
      else begin
       anameid:= aglobname;
       llvmlists.globlist.namelist.addname(info.s.unitinfo,
                                                   anameid,subbegin.globid);
      end;
     end
     else begin
      if sso_pointerparam in options then begin
       subbegin.globid:= llvmlists.globlist.addinternalsubvalue([],params1po);
      end
      else begin
       subbegin.globid:= llvmlists.globlist.addinternalsubvalue([],noparams);
      end;
     end;
     aglobid:= subbegin.globid;
     if do_proginfo in s.debugoptions then begin
      with pdisubprogramty(llvmlists.metadatalist.getdata(
                                      s.currentscopemeta))^ do begin
       _function:= llvmlists.metadatalist.addglobvalue(subbegin.globid);
      end;
     end;
    end;
//    subbegin.sub.allocs.llvm.tempcount:= 0;
//    subbegin.sub.allocs.llvm.managedtemptypeid:= 0;
//    subbegin.sub.llvm.managedtempcount:= 0; //constid
//    subbegin.sub.llvm.blockcount:= 1; //will be updated in endsimplesub()
   end
   else begin
//    subbegin.sub.stackop.varsize:= 0;
//    subbegin.sub.stackop.managedtempsize:= 0;
   end;
   subbegin.sub.flags:= [];
 //  sub.flags:= [sf_nolineinfo];
   if sso_pointerparam in options then begin
    subbegin.sub.allocs:= param1poallocs;
    with subbegin.sub.allocs do begin 
     allocs:= getsegmenttopoffs(seg_localloc);
     with plocallocinfoty(allocsegmentpo(seg_localloc,
                                        sizeof(locallocinfoty)))^ do begin
      address:= 0;
      flags:= [];
      size:= bitoptypes[das_pointer];
      if do_proginfo in info.o.debugoptions then begin
       var1.address.flags:= [af_param];
       var1.address.indirectlevel:= 1;
       var1.vf.typ:= sysdatatypes[st_pointer].typedata;
       debuginfo:= s.unitinfo^.llvmlists.metadatalist.adddivariable(
                  par0name,s.source.line,0,var1);
      end
      else begin
       debuginfo:= dummymeta;
      end;
     end;
    end;
   end
   else begin
    subbegin.sub.allocs:= nullallocs;
   end;
  end;
  stacktempoffset:= locdatapo;
 end;
 begintempvars();
 (*
  with info do begin
  {$ifdef mse_checkinternalerror}
   if s.trystack <> 0 then begin
    internalerror(ie_handler,'20150507A');
   end;
  {$endif}
   s.trystacklevel:= 0;
  end;
 *)
end;

function startsimplesub(const aname: identty; const options: simplesuboptionsty;
                                   const aglobname: identty = 0): opaddressty;
var
 i1,i2: int32;
begin
 result:= startsimplesub1(aname,options,aglobname,i1,i2);
end;

function startsimplesub(const asub: pinternalsubdataty; 
                                const options: simplesuboptionsty;
                                   const aglobname: identty = 0): opaddressty;
begin
 if isf_globalheader in asub^.flags then begin
  result:= startsimplesub1(datatoele(asub)^.header.name,options +
                                               [sso_global,sso_globheader],
                                        asub^.nameid,asub^.globid,asub^.nameid);
 end
 else begin
  result:= startsimplesub1(datatoele(asub)^.header.name,options,
                                          aglobname,asub^.globid,asub^.nameid);
 end;
end;

procedure settempvars(var allocs: suballocllvmty);
var
 p1,pe: pint32;
 p2: ptempvaritemty;
 item1: listadty;
begin
 with info do begin
  allocs.tempvars:= 0; //init
  if tempvarcount > 0 then begin
   allocs.tempvars:=
           allocsegmentoffset(seg_localloc,tempvarcount*sizeof(int32),p1);
   pe:= p1 + tempvarcount;
   item1:= tempvarchain;
   p2:= getlistitem(tempvarlist,item1);
   while p1 < pe do begin
   {$ifdef mse_checkinternalerror}
    if p2 = nil then begin
     internalerror(ie_handler,'20170831A');
    end;
   {$endif}
    if (af_tempvar in p2^.address.flags) and (p2^.typeid > 0) then begin
     if p2^.address.indirectlevel > 0 then begin
      p1^:= ord(das_pointer);
     end
     else begin
      p1^:= s.unitinfo^.llvmlists.typelist.addtypevalue(
                                              ele.eledataabs(p2^.typeele));
     end;
    end
    else begin
     p1^:= p2^.typeid;
    end;
    inc(p1);
    p2:= steplistitem(tempvarlist,item1);
   end;
  {$ifdef mse_checkinternalerror}
   if p2 <> nil then begin
    internalerror(ie_handler,'20170831B');
   end;
  {$endif}
  end;
  allocs.tempcount:= tempvarcount;
 end;
end;

procedure endsimplesub(const pointerparam: boolean);
var
 tempsize1,varsize1,managedtempsize1: int32;
 p1: pint32;
begin
 with info do begin
  writemanagedtempop(mo_decref,managedtempchain,s.stacktop);
  deletelistchain(managedtemplist,managedtempchain);
  managedtempsize1:= managedtempcount*targetpointersize; 
{
  with addcontrolitem(oc_return)^ do begin
   if pointerparam then begin
    par.stacksize:= pointersize + sizeof(frameinfoty);
   end
   else begin
    par.stacksize:= 0 + sizeof(frameinfoty);
   end;
  end;
}
  invertlist(tempvarlist,tempvarchain);
  writemanagedtempvarop(mo_decref,tempvarchain,s.stacktop);

  tempsize1:= locdatapo-stacktempoffset;
  varsize1:= managedtempsize1+tempsize1;
  if varsize1 <> 0 then begin
   with additem(oc_locvarpop)^ do begin
    par.stacksize:= varsize1;
   end;
  end;
  with additem(oc_return)^ do begin
   if pointerparam then begin
    par.stacksize:= targetpointersize + sizeof(frameinfoty);
   end
   else begin
    par.stacksize:= 0 + sizeof(frameinfoty);
   end;
  end;
  endtempvars();
  with getoppo(simplesubstart)^ do begin
   if co_llvm in o.compileoptions then begin
    if managedtempsize1 > 0 then begin
     par.subbegin.sub.allocs.llvm.managedtemptypeid:= 
         info.s.unitinfo^.llvmlists.typelist.addaggregatearrayvalue(
                                            managedtempsize1,ord(das_8));
     setimmint32(managedtempcount,par.subbegin.sub.allocs.llvm.managedtempcount);
    end
    else begin
     par.subbegin.sub.allocs.llvm.managedtemptypeid:= 0;
    end;
    settempvars(par.subbegin.sub.allocs.llvm);
    par.subbegin.sub.allocs.llvm.blockcount:= s.ssa.bbindex; 
   end
   else begin
    par.subbegin.sub.allocs.stackop.managedtempsize:= managedtempsize1;
    par.subbegin.sub.allocs.stackop.tempsize:= tempsize1;
    par.subbegin.sub.allocs.stackop.varsize:= varsize1;
   end;
  end;
  with additem(oc_subend)^ do begin
   par.subend.submeta:= info.s.currentscopemeta;
   par.subend.allocs.alloccount:= 0;
   par.subend.allocs.nestedalloccount:= 0;
  end;
  deletelistchain(trystacklist,s.trystack); //normally already empty
  deletelistchain(tempvarlist,tempvarchain);
  s.trystacklevel:= 0;
  if do_proginfo in s.debugoptions then begin
   popcurrentscope();
  end;
 end;
(*
 with info do begin
  deletelistchain(trystacklist,s.trystack); //normally already empty
  s.trystacklevel:= 0;
 end;
*)
end;

function checkoperatorreturntype(const var1: pvardataty): boolean;
begin    
 result:= (var1^.address.indirectlevel = 1) and
                              (var1^.vf.typ = info.currentcontainer);
end;

function checkoperatorparam(const var1: pvardataty): boolean;
begin    
 result:= (var1^.address.flags*[af_paramvar,af_paramout] = []) and
          ((var1^.address.indirectlevel = 0) and 
              not (af_paramindirect in var1^.address.flags) or
           (var1^.address.indirectlevel = 1) and 
              (af_paramindirect in var1^.address.flags)) and
          (var1^.vf.typ = info.currentcontainer);
end;

procedure setoperparamid(var dest: identvecty; const aindirectlevel: int32;
                                                  const atyp: ptypedataty);
var
 p1: ptypedataty;
 p2: punitinfoty;
 p3: pidentty;
begin
 p3:= @dest.d[dest.high];
 (p3+1)^:= getident(aindirectlevel);
 if atyp = nil then begin
  (p3+2)^:= tks_void;
  (p3+3)^:= tks_system;
 end
 else begin
  p1:= basetype1(atyp);
  (p3+2)^:= p1^.h.signature;
  p2:= datatoele(p1)^.header.defunit;
  if p2 = nil then begin
   (p3+3)^:= tks_system;
  end
  else begin
   (p3+3)^:= p2^.key;
  end;
 end;
 dest.high:= dest.high + 3;
end;

procedure setoperparamid(var dest: identvecty; const avar: pvardataty);
                                                 //nil -> void
var
 i1: int32;
begin
 if avar = nil then begin
  setoperparamid(dest,0,nil);
 end
 else begin
  i1:= avar^.address.indirectlevel;
  if af_paramindirect in avar^.address.flags then begin
   dec(i1);
  end;
  setoperparamid(dest,i1,ele.eledataabs(avar^.vf.typ));
 end;
end;

procedure updateparams(const info: paramupdatechainty);
var
 i1,i2: int32;
 shift: int32;
 p1,pe: pparamupdateinfoty;
 p2: pvardataty;
 p3: ptypedataty;
begin
 p1:= @info.data;          //todo: alignment
 pe:= p1 + info.count;
// shift:= 0;
 while p1 < pe do begin
  p2:= ele.eledataabs(p1^.varele);
//  inc(p2^.address.locaddress.address,shift); not necessary,
                     //address used in implementation only
  if (p2^.address.indirectlevel = 0) then begin
   p3:= ele.eledataabs(p2^.vf.typ);
   i2:= p3^.h.bytesize;
   if (p2^.address.flags * [af_paramconst,af_paramindirect] = 
                                               [af_paramconst]) then begin
    if i2 > targetpointersize then begin
     inc(p2^.address.indirectlevel);
     include(p2^.address.flags,af_paramindirect);
     i2:= targetpointersize;
    end;
   end;
//   shift:= shift+i2-p1^.size;
  end;
  inc(p1);
 end;
end;

const
 attachmentnames: array[subflag1ty] of string = (
 //sf1_ini,sf1_fini,sf1_afterconstruct,sf1_new,sf1_dispose,sf1_beforedestruct,
      'ini',  'fini',  'afterconstruct',  'new',  'dispose',  'beforedestruct',
 //sf1_incref,sf1_decref,
      'incref',  'decref',
 //sf1_default
      'default'
 );

procedure handlesubheader();
var
 sub1: psubdataty;
 curparam,curparamend: pelementoffsetty;
 curstackindex: int32;
 isobject,isclass: boolean;
 err1: boolean;
 impl1: boolean;
 defaultparamcount1: int32;
 subflags: subflagsty;
 subflags1: subflags1ty;
 paramsize1: integer;
 paramco{,paramhigh}: int32;
 
 function doparams(const resultvar: boolean): boolean;
 var
  i1,i2,i3: int32;
  si1: int32;
  paramkind1: paramkindty;
  defaultconst1: elementoffsetty;
  needssizeupdate: boolean;
  paramsbuffer: array[0..maxparamcount-1] of paramupdateinfoty;
  p1: pparamupdatechainty;
  var1: pvardataty;
  typ1,typ2: ptypedataty;
  ele1: elementoffsetty;
 begin
  result:= true;
  needssizeupdate:= false;
  i3:= 0;
  with info do begin
   while curparam < curparamend do begin
    i1:= curstackindex+2; //first ck_ident
    if resultvar then begin
     dec(i1); //curstackindex+1
    end;
    i2:= i1;
    while contextstack[i1].d.kind = ck_ident do begin
     inc(i1);
    {$ifdef mse_checkinternalerror}
     if i1 > s.stacktop then begin
      internalerror(ie_handler,'20160216A');
     end;
    {$endif}
    end;
    with contextstack[curstackindex] do begin
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_paramdef then begin
      internalerror(ie_handler,'20160606C');
     end;
    {$endif}
     paramkind1:= d.paramdef.kind;
     defaultconst1:= d.paramdef.defaultconst;
    end;
    for i2:= i2 to i1 - 1 do begin
     with contextstack[i2] do begin //ck_ident
     {$ifdef mse_checkinternalerror}
      if d.kind <> ck_ident then begin
       internalerror(ie_handler,'20160216B');
      end;
     {$endif}
      if (isobject and (s.dialect <> dia_mse) and
          ele.findchild(currentcontainer,d.ident.ident,[],allvisi,ele1)) or not
              addvar(d.ident.ident,allvisi,sub1^.varchain,var1) then begin
       identerror(curstackindex-s.stackindex,err_duplicateidentifier);
       err1:= true;
      end;
      if ps_stop in s.state then begin
       exit; //recursive ancestor
      end;
      paramsbuffer[i3].varele:= ele.eledatarel(var1);
      curparam^:= elementoffsetty(var1); 
                    //absoluteaddress, will be qualified later ??? 64bit?
      with contextstack[i1] do begin //ck_fieldtype
       if d.kind = ck_fieldtype then begin
        if sf_vararg in sub1^.flags then begin
         errormessage(err_varargmustbelast,[]);
        end;
        typ1:= ele.eledataabs(d.typ.typedata);
        var1^.address.flags:= [af_param];
        if (typ1^.h.kind = dk_openarray) and 
           (tf_untyped in ptypedataty(ele.eledataabs(
                       typ1^.infodynarray.i.itemtypedata))^.h.flags) then begin
         if not (sf_external in sub1^.flags) then begin //todo: check "cdecl"
          typ1^.infodynarray.i.itemtypedata:= internaltypes[it_varrec];
          include(var1^.address.flags,af_untyped);
         end
         else begin
          include(sub1^.flags,sf_vararg);
         end;
        end;
        with var1^ do begin
         vf.defaultconst:= defaultconst1;
         if defaultconst1 > 0 then begin
          inc(defaultparamcount1);
         end;
         address.indirectlevel:= d.typ.indirectlevel;
         if (address.indirectlevel > 0) then begin
          si1:= targetpointersize;
         end
         else begin
          si1:= typ1^.h.bytesize;
         end;
         if resultvar then begin
          include(var1^.address.flags,af_resultvar);
         end;
         if typ1^.h.kind = dk_openarray then begin
          include(address.flags,af_openarray);
          if sf_vararg in sub1^.flags then begin
           include(address.flags,af_vararg);
          end;
         end;
         if typ1^.h.datasize = das_none then begin
          include(address.flags,af_aggregate);
         end;
         address.flags:= address.flags + paramkinds[paramkind1];
         if paramkind1 = pk_const then begin
          if tf_sizeinvalid in typ1^.h.flags then begin //size not known yet
           needssizeupdate:= true;
          end;
          if (si1 > targetpointersize){ and 
                            (typ1^.h.kind <> dk_openarray)} then begin
                                  //dk_openarray has special handling
           inc(address.indirectlevel);
           include(address.flags,af_paramindirect);
           si1:= targetpointersize;
          end;
          include(address.flags,af_const);
         end
         else begin
          if paramkind1 in [pk_constref,pk_var,pk_out] then begin
           inc(address.indirectlevel);
           include(address.flags,af_paramindirect);
           si1:= targetpointersize;
           if paramkind1 = pk_constref then begin
            include(address.flags,af_const);
           end;
           if impl1 and resultvar and (sf_functioncall in subflags) and 
               (d.typ.indirectlevel = 0) and 
                  (typ1^.h.flags*[tf_needsini,tf_needsmanage] <> []) then begin
            include(vf.flags,tf_needsini);
            include(s.currentstatementflags,stf_needsini);
           end;
          end
          else begin
           if impl1 and (d.typ.indirectlevel = 0) then begin
            if resultvar then begin
             if typ1^.h.flags*[tf_needsini,tf_needsmanage] <> [] then begin
              include(vf.flags,tf_needsini);
              include(s.currentstatementflags,stf_needsini);
             end;
            end
            else begin 
             vf.flags:= typ1^.h.flags * 
                            [tf_needsmanage,tf_needsini,tf_needsfini];
//             if tf_needsmanage in typ1^.h.flags then begin
//              include(vf.flags,tf_needsmanage);
//             end;
            end;
           end;
          end;
         end;
         if (typ1^.h.kind = dk_none) and 
                      not (tf_forward in typ1^.h.flags) then begin //untyped
          if address.flags * [af_paramconst,af_paramconstref,af_paramvar,
                                                    af_paramout] = [] then begin
           tokenexpectederror(':'); //todo: sourcepos
           result:= false;
           exit;
          end
          else begin
           if not (af_paramindirect in address.flags) then begin
            inc(address.indirectlevel);
            include(address.flags,af_paramindirect);
            si1:= targetpointersize;
           end;
          end;
         end;
         if impl1 then begin
          address.locaddress:= 
                            getlocvaraddress(typ1^.h.datasize,si1,address.flags);
         end;
         address.locaddress.framelevel:= sublevel+1;
         vf.typ:= d.typ.typedata;
        end;
       end
       else begin
        err1:= true;
        internalerror1(ie_parser,'20150212A');
       end;
       if (co_mlaruntime in o.compileoptions) and 
                            (tf_sizeinvalid in typ1^.h.flags) and 
                                 (var1^.address.indirectlevel = 0) then begin
        with pclasspendingitemty(
                       addlistitem(pendingclassitems,
                                   selfobjparamchain))^.selfobjparam do begin
         methodelement:= ele.eledatarel(sub1);
         paramindex:= curparam-pelementoffsetty(@sub1^.paramsrel);
         paramsize:= alignsize(si1);
        end;
       end;
//       paramsbuffer[i3].size:= si1; //todo: alignment
       inc(i3);
       inc(paramsize1,alignsize(si1));
       inc(curparam);
      end;
     end;
    end;
    curstackindex:= i1+1; //next ck_paramsdef
   end;
   if needssizeupdate then begin
    i2:= i3*sizeof(paramupdateinfoty);
    i1:= allocsegment(seg_temp,sizeof(paramupdatechainty)+i2,p1).address;
    p1^.next:= currentparamupdatechain;
    p1^.sub:= ele.eledatarel(sub1);
    p1^.count:= i3;
    currentparamupdatechain:= i1;
    move(paramsbuffer,p1^.data,i2);
   end;
  end; //lastparamindex
 end;//doparams()

 function checksysobjectmethod(akind: subflag1ty): boolean;
 begin
  result:= akind in subflags1;
  if result and (not isobject or (subflags*[sf_functionx,sf_classmethod] <> []) or
                                                  (paramco <> 1)) then begin
   errormessage(err_invalidmethodforattach,[attachmentnames[akind]]);
   result:= false;
  end;
 end;//checksysobjectmethod()

 function checksysclassmethod(const akind: subflag1ty): boolean;
 begin
  if isclass then begin
   result:= checksysobjectmethod(akind);
  end
  else begin
   result:= false;
   if akind in subflags1 then begin
    errormessage(err_invalidattachment,[attachmentnames[akind]]);
   end;
  end;
 end;//checksysclassmethod()

var                       //todo: move after doparams()
 var1: pvardataty;
 typ1: ptypedataty;
// po4: pelementoffsetaty;
 paramend: pelementoffsetty;
// {int1,}int2{,int3}: integer;
// lastparamindex: int32;
// curparamindex: int32;
 parent1: elementoffsetty;
 paramdata: equalparaminfoty;
 par1,parref: pelementoffsetaty;
 eledatabase: ptruint;
// parambase: ptruint;
 si1: integer;
 bo1,isinterface,ismethod: boolean;
 ele1: elementoffsetty;
 ident1: identty;
 resulttype1: resulttypety;

var
 lstr1: lstringty;  
 i1: int32;
 element1: pelementinfoty;
 poind: pcontextitemty;
 poper1: poperatordataty;
 poperid: pidentty;
 operatorsig: identvecty;
begin
{$ifdef mse_debugparser}
 outhandle('SUBHEADER');
{$endif}
//|gettype
//|-3        |-2   
//|classdef0,|*headercall*|
//            -1  0     1     2
//            sub,sub2,ident,paramsdef3
//            3            4            5        6
//          {,ck_paramsdef,commaidents2,ck_ident,{ck_ident,}ck_type}
// interfacedef0
//  6           7             8       9                   result
//[ck_paramsdef,commaidents2,ck_ident,{ck_ident,}ck_type] 
              //todo: multi level type

//runtime call stack:
//                                   |cpu.frame                    |cpu.stack
//[^result] [self] {param} frameinfo {locvar}{managedtemp pointers}
//|-------- subdataty.paramsize -----|------subdataty.varsize------|
//
//llvm call stack:
//[self] {params}

//todo: do not use absolute pointers in paramsarray because of 64bit host,
//elementoffsetty is 32 bit

 with info do begin
  poind:= @contextstack[s.stackindex];
  with (poind-1)^ do begin
   d.subdef.match:= 0;              //todo: nested forward subs
   subflags:= d.subdef.flags;
   subflags1:= d.subdef.flags1;
   d.subdef.parambase:= locdatapo;
   d.subdef.locallocidbefore:= locallocid;
   locallocid:= 0;
  end;
  if (sf_functionx in subflags) and 
                      not (sf_functiontype in subflags) then begin
   tokenexpectederror(':');
   exit; //fatal
  end;

  if sf_functiontype in subflags then begin
   subflags:= subflags+[sf_functionx,sf_functioncall];
  end;
  paramsize1:= 0;
  resulttype1.typeele:= 0;
  resulttype1.indirectlevel:= 0;
  defaultparamcount1:= 0;
  isobject:= s.currentstatementflags * [stf_objdef,stf_objimp] <> [];
  isclass:= isobject and (stf_class in s.currentstatementflags);
  isinterface:=  stf_interfacedef in s.currentstatementflags;
  ismethod:= isobject or isinterface or (sf_ofobject in subflags);
  if ismethod and (subflags * [sf_constructor,sf_destructor] = []) and 
                                     not (sf_methodtoken in subflags) and 
                                              (s.dialect = dia_mse) then begin
   errormessage(err_tokenexpected,['method'],poind-1);
   exit;
  end;
  if sf_functionx in subflags then begin
   with contextstack[s.stacktop].d.typ do begin
    resulttype1.typeele:= typedata;
    resulttype1.indirectlevel:= indirectlevel;
   end;
//   if co_hasfunction in o.compileoptions then begin
    with contextstack[s.stacktop-2] do begin
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_paramdef then begin
      internalerror(ie_handler,'20170818A');
     end;
    {$endif}
     if resulttype1.indirectlevel = 0 then begin
      with ptypedataty(ele.eledataabs(resulttype1.typeele))^ do begin
       if (h.flags*[tf_managed,tf_needsmanage] <> []) or
           (h.bytesize > targetpointersize) and (h.kind <> dk_float) then begin
        d.paramdef.kind:= pk_var; //pk_out?
        exclude(subflags,sf_functioncall);
       end;
      end;
     end;
//    end;
   end;
  end;
  if isinterface then begin
   i1:= s.stackindex + 3;
  end
  else begin
   i1:= s.stackindex + 5;
  end;
  paramco:= 0;
  for i1:= i1 to s.stacktop-1 do begin
   if contextstack[i1].d.kind = ck_ident then begin
    inc(paramco);
   end;
  end;
  if (paramco = 0) and (sf_functionx in subflags) then begin
   paramco:= 1;  //no getidents context
  end;
//  paramco:= (s.stacktop-s.stackindex-2) div 3;
//  paramhigh:= paramco-1;
  if ismethod then begin
   inc(paramco); //self pointer
  end;
  if paramco > maxparamcount then begin
   errormessage(err_toomanyparams,[],minint,0,erl_fatal);
   exit;
  end;
  {
  i1:= paramco* (sizeof(pvardataty)+elesizes[ek_var]) + elesizes[ek_alias] +
                 elesizes[ek_sub] + elesizes[ek_none] + elesizes[ek_type]+
                 2*elesizes[ek_operator]+elesizes[ek_none];
  }
  i1:= paramco* (sizeof(pvardataty)+elesize+sizeof(vardataty)) + 
       elesize+sizeof(aliasdataty) +
       elesize+sizeof(subdataty) + 
       elesize +
       elesize+sizeof(typedataty) +
       2*(elesize+sizeof(operatordataty)) +
       elesize;
  
  ele.checkcapacity(i1); //ensure that absolute addresses can be used
  eledatabase:= ele.eledataoffset();
  ident1:= contextstack[s.stackindex+1].d.ident.ident;
  if ele.findcurrent(ident1,[],allvisi,ele1) and 
                   (ele.eleinfoabs(ele1)^.header.kind <> ek_sub) then begin
   identerror(1,err_overloadnotfunc);
//   ele1:= 0;
  end;
  if ele1 < 0 then begin
   ele1:= 0;
  end;
// {
  if (ele1 > 0) then begin
   if (sf_method in subflags) then begin
    element1:= ele.eleinfoabs(ele1);
    if element1^.header.parent <> ele.elementparent then begin
     ele1:= 0;    //todo: use correct class overload handling
    end;
   end
   else begin
    if sf_forward in psubdataty(ele.eledataabs(ele1))^.flags then begin
     ele1:= 0;
    end;
   end;
  end;
// }
  sub1:= addr(ele.pushelementduplicate(ident1,ek_sub,allvisi,
                                     paramco*sizeof(pvardataty))^.data);
  sub1^.next:= currentsubchain;
  currentsubchain:= ele.eledatarel(sub1);
  sub1^.globid:= -1;
  sub1^.impl:= 0;
{
  if (ele1 >= 0) and (sf_method in subflags) then begin
   element1:= ele.eleinfoabs(ele1);
   if element1^.header.parent <> ele.elementparent then begin
    ele1:= -1;    //todo: use correct class overload handling
   end;
  end;
}
  sub1^.nextoverload:= ele1;
  if ele1 > 0 then begin
   include(subflags,sf_overload);
   include(psubdataty(ele.eledataabs(ele1))^.flags,sf_overload);
  end;

  typ1:= ele.addelementdata(getident(),ek_type,allvisi);
  info.currenttypedef:= ele.eledatarel(typ1);
  sub1^.typ:= ele.eledatarel(typ1);
  inittypedatasize(typ1^,dk_sub,0,das_pointer);
  with typ1^ do begin
   infoaddress.sub:= currentsubchain;
  end;
  if not (us_implementation in s.unitinfo^.state) then begin 
               //interface needs name for linker ???
   include(subflags,sf_named); //todo: check visibility
  end;
  if isinterface then begin
   include(subflags,sf_interface); 
   sub1^.tableindex:= currentsubcount;
  end
  else begin
   sub1^.tableindex:= -1; //none
  end;
  inc(currentsubcount);
  if isobject and (sf_constructor in subflags) then begin
   resulttype1.typeele:= currentcontainer;
   resulttype1.indirectlevel:= 1;
  end;
  sub1^.paramcount:= paramco;
  sub1^.calllinks:= 0;
  sub1^.adlinks:= 0;
  sub1^.exitlinks:= 0;
  sub1^.trampolinelinks:= 0;   //for virtual interface items
  sub1^.trampolineaddress:= 0;
  sub1^.trampolineid:= -1;
  sub1^.nestinglevel:= sublevel;
  sub1^.flags:= subflags;
  if sf_classmethod in subflags then begin
   include(datatoele(sub1)^.header.visibility,vik_classele);
  end;
  sub1^.flags1:= subflags1;
  sub1^.linkage:= s.globlinkage;
//  inc(s.unitinfo^.nameid);
  sub1^.nameid:= getunitnameid();
  sub1^.resulttype:= resulttype1;
  sub1^.varchain:= 0;
//  sub1^.paramfinichain:= 0;
  sub1^.allocs.nestedalloccount:= 0;
  if sf_external in subflags then begin
   with (poind-1)^ do begin
    sub1^.libname:= d.subdef.libname;
    sub1^.funcname:= d.subdef.funcname;
   end;
  end
  else begin
   sub1^.libname:= 0;
   sub1^.funcname:= 0;
  end;
  if (stf_objdef in s.currentstatementflags) and 
                        (subflags*[sf_virtual,sf_override]<>[]) then begin
   with contextstack[s.stackindex-3] do begin
   {$ifdef mse_checkinternalerror}
    if d.kind <> ck_classdef then begin
     internalerror(ie_handler,'20151128A');
    end;
   {$endif}
    sub1^.tableindex:= d.cla.virtualindex;
    inc(d.cla.virtualindex);
   end;
  end;
  err1:= false;
  impl1:= (us_implementation in s.unitinfo^.state) and 
                                                 not (sf_header in subflags);
  curparam:= @sub1^.paramsrel;
  if sf_functionx in subflags then begin  //allocate result var first
   curstackindex:= s.stacktop-2;  //-> paramsdef     
   curparamend:= curparam + 1;
   if not doparams(true) or (ps_stop in s.state) then begin 
                            //increments curparam
                            //recursive class or object parent
    exit;
   end;
  end;
  curparamend:= pelementoffsetty(@sub1^.paramsrel) + paramco;
  
  if ismethod then begin
  {$ifdef mse_checkinternalerror}
   if not addvar(tks_self,allvisi,sub1^.varchain,var1) then begin
    internalerror(ie_sub,'20140415A');
   end;
  {$else}
   addvar(tks_self,allvisi,sub1^.varchain,var1);
  {$endif}
   ele.addalias(tk_self,ele.eledatarel(var1),allvisi);
   curparam^:= elementoffsetty(var1); //absoluteaddress //??? 64 bit ???
   inc(curparam);          //todo: class proc
   with var1^ do begin //self variable
    inc(paramsize1,targetpointersize);
    address.indirectlevel:= 1;
    if impl1 then begin
     address.locaddress:= getlocvaraddress(das_pointer,targetpointersize,
                                                              address.flags);
    end;
    address.locaddress.framelevel:= sublevel+1;
    address.flags:= [af_param,af_const];
    if sf_classmethod in subflags then begin
     include(datatoele(var1)^.header.visibility,vik_classele);
//     include(address.flags,af_classele);
    end;
    with ptypedataty(
             ele.eledataabs(currentcontainer))^ do begin
     if isobject then begin
      include(address.flags,af_self);
      if h.kind = dk_object then begin
       vf.typ:= infoclass.objpotyp;
      end
      else begin
       vf.typ:= currentcontainer;
      end;
     end
     else begin
      vf.typ:= -1;
     end;
    end;
   end;
  end;
//  curstackindex:= s.stackindex + 3; //->paramsdef
  curstackindex:= s.stackindex;
  while (curstackindex < s.stacktop) and 
         (contextstack[curstackindex].d.kind <> ck_paramdef) do begin
   inc(curstackindex);
  end;
  if not doparams(false) then begin
   exit;
  end;
  curparam:= @sub1^.paramsrel;
  inc(paramsize1,stacklinksize);
  sub1^.paramsize:= paramsize1;
  sub1^.defaultparamcount:= defaultparamcount1;
  sub1^.address:= 0; //init
  if impl1 then begin //implementation
   if sublevel = 0 then begin
    currentzerolevelsub:= ele.eledatarel(sub1);
   end;
   inc(sublevel);
   inclocvaraddress(stacklinksize);
   with (poind-1)^ do begin
    ele.markelement(b.elemark); 
    sub1^.nestedvarele:= ele.addelementduplicate1(tks_nestedvarref,
                                                            ek_none,allvisi);
    sub1^.nestedvarchain:= 0;
    sub1^.nestedvarcount:= 1; //for callout frame ref
    d.subdef.ssabefore:= s.ssa;
    resetssa();
    d.subdef.frameoffsetbefore:= frameoffset;
    frameoffset:= locdatapo; //todo: nested procedures
    d.subdef.paramsize:= paramsize1;
    d.subdef.error:= err1;
    d.subdef.ref:= ele.eledatarel(sub1);
    while curparam < curparamend do begin
     var1:= pointer(curparam^);
     dec(var1^.address.locaddress.address,frameoffset);
     curparam^:= ptruint(var1)-eledatabase;
     if tf_needsmanage in var1^.vf.flags then begin
      include(sub1^.flags,sf_hasmanagedparam);
//      var1^.vf.next:= sub1^.paramfinichain;
//      sub1^.paramfinichain:= ele.eledatarel(var1);
     end;
     inc(curparam);
    end;
   end;
  end
  else begin //interface
   while curparam < curparamend do begin
    dec(curparam^,eledatabase); //relative address
    inc(curparam);
   end;
   if not isinterface then begin
    if sf_external in subflags then begin
     include(sub1^.flags,sf_proto);
     sub1^.linkage:= li_external;
{
     with pexternallinkinfoty(addlistitem(
             s.unitinfo^.externallinklist,s.unitinfo^.externalchain))^ do begin
      sub:= ele.eledatarel(sub1);
     end;
}
     if co_llvm in o.compileoptions then begin
      if sub1^.funcname <> 0 then begin      //todo: handle libname
       ident1:= sub1^.funcname;
      end
      else begin
       ident1:= pelementinfoty(pointer(sub1)-eledatashift)^.header.name;
      end;
      {
      if sf_named in sub1^.flags then begin
       i1:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(
                                                sub1,getidentname2(ident1));
       sub1^.globid:= info.s.unitinfo^.llvmlists.globlist.addalias(i1,
                                                                sub1^.nameid);
      end
      else begin
      }
       sub1^.globid:= 
             info.s.unitinfo^.llvmlists.globlist.addsubvalue(
                                                sub1,getidentname2(ident1));
//      end;
     end;
//     addsubbegin(oc_externalsub,sub1);
    end
    else begin
     if sf_typedef in subflags then begin
      ele.decelementparent();
      setsubtype(-2,ele.eledatarel(sub1));
      dec(info.s.stackindex);
      exit;
     end
     else begin
      forwardmark(sub1^.mark,poind^.start,datatoele(sub1)^.header.name);
     end;
    end;
   end
   else begin
    sub1^.mark:= -1;
   end;   
  end;

  parent1:= ele.decelementparent;
  with paramdata do begin  //check params duplicate
   ref:= sub1;
   match:= nil;
  end;                                    
  if sf_override in subflags then begin
   if not ele.forallancestor((poind+1)^.d.ident.ident,[ek_sub],
                             allvisi,@checkequalheader,paramdata) then begin
    err1:= true;
    errormessage(err_noancestormethod,[]);
   end
   else begin
    sub1^.tableindex:= paramdata.match^.tableindex;
    with (poind-3)^ do begin
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_classdef then begin
      internalerror(ie_handler,'20151128A');
     end;
    {$endif}
     dec(d.cla.virtualindex);
    end;
   end;
  end
  else begin
   if ele.forallcurrent((poind+1)^.d.ident.ident,[ek_sub],
                             allvisi,@checkequalheader,paramdata) then begin
    err1:= true;
    errormessage(err_sameparamlist,[]);
   end;
  end;

  if impl1 then begin
   if err1 = false then begin
    if sublevel = 1 then begin
     paramdata.match:= nil;
     if isobject then begin
      currentobject:= currentcontainer;
      ele.pushelementparent(currentcontainer);
      bo1:= ele.forallcurrent((poind+1)^.d.ident.ident,[ek_sub],
                                  allvisi,@checkequalparam,paramdata);
      ele.popelementparent();
      if not bo1 then begin
       errormessage(err_methodidentexpected,[],1);
      end
      else begin
       if sf_classmethod in (paramdata.match^.flags >< sub1^.flags) then begin
        bo1:= false;
        if sf_classmethod in sub1^.flags then begin
         errormessage(err_methodidentexpected,[],1);
        end
        else begin
         errormessage(err_classmethodexpected,[],1);
        end;
       end;
      end;
     end
     else begin
      bo1:= ele.forallcurrent((poind+1)^.d.ident.ident,[ek_sub],
                                            allvisi,@checkequalparam,paramdata);
      if not bo1 then begin
       ele.decelementparent; //interface
       bo1:= ele.forallcurrent((poind+1)^.d.ident.ident,[ek_sub],
                                            allvisi,@checkequalparam,paramdata);
      end;
     end;
     if bo1 then begin
      with paramdata.match^ do begin
       if (sf_external in flags) or (impl <> 0) then begin
        errormessage(err_sameparamlist,[]);
       end
       else begin
        forwardresolve(mark);
        impl:= ele.eledatarel(sub1);
        pointer(parref):= @paramsrel;
        pointer(par1):= @sub1^.paramsrel;
        for i1:= 0 to paramco-1 do begin
         if ele.eleinfoabs(parref^[i1])^.header.name <> 
                   ele.eleinfoabs(par1^[i1])^.header.name then begin
          errormessage(
               err_functionheadernotmatch,
                  [getidentname(ele.eleinfoabs(parref^[i1])^.header.name),
                       getidentname(ele.eleinfoabs(par1^[i1])^.header.name)],
                             s.stacktop-s.stackindex-3*(paramco-i1-1)-1);
         end;
        end;
       end;
      end;
     end;
     with (poind-1)^ do begin
      if paramdata.match <> nil then begin
       d.subdef.match:= ele.eledatarel(paramdata.match);
 //     end
 //     else begin
 //      d.subdef.match:= 0;
      end;
     end;
    end;
    {
    if backend = bke_llvm then begin
     sub1^.globid:= globlist.addsubvalue(sub1);
    end;
    }
    if s.debugoptions * [do_proginfo,do_names] <> [] then begin
     with (poind-1)^ do begin
     {$ifdef mse_checkinternalerror}
      if (s.stackindex < 1) or (d.kind <> ck_subdef) then begin
       internalerror(ie_parser,'20151023A');
      end;
     {$endif}
      element1:= ele.eleinfoabs(d.subdef.ref);
      with s.unitinfo^ do begin
       if do_proginfo in s.debugoptions then begin
        pushcurrentscope(llvmlists.metadatalist.adddisubprogram(
            s.currentscopemeta,getidentname2(element1^.header.name),
            s.currentfilemeta,
            info.contextstack[info.s.stackindex].start.line,-1,
            dummymeta,[flagprototyped],us_implementation in s.unitinfo^.state));
        sub1^.submeta:= s.currentscopemeta;
       end;
      end;
     end;
    end;
    ele.elementparent:= parent1; //restore in sub
   end;
   dec(s.stackindex);
   s.stacktop:= s.stackindex;
  end
  else begin
   if (sf1_new in subflags1) then begin
    if isobject and (subflags*[sf_functionx,sf_classmethod] = 
             [sf_functionx,sf_classmethod]) and (paramco = 2) and 
             (resulttype1.indirectlevel = 1) and 
            (ptypedataty(ele.eledataabs(resulttype1.typeele))^.h.kind =
                                                        dk_pointer) then begin
     with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
      infoclass.subattach[osa_new]:= ele.eledatarel(sub1);
     end;
    end
    else begin
     errormessage(err_invalidmethodforattach,[attachmentnames[sf1_new]]);
    end;
   end;
   if checksysobjectmethod(sf1_dispose) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_dispose]:= ele.eledatarel(sub1);
    end;
   end;
   if checksysobjectmethod(sf1_afterconstruct) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_afterconstruct]:= ele.eledatarel(sub1);
    end;
   end;
   if checksysobjectmethod(sf1_beforedestruct) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_beforedestruct]:= ele.eledatarel(sub1);
    end;
   end;
   if checksysobjectmethod(sf1_ini) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_ini]:= ele.eledatarel(sub1);
     include(h.flags,tf_needsini);
    end;
   end;
   if checksysobjectmethod(sf1_fini) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_fini]:= ele.eledatarel(sub1);
     include(h.flags,tf_needsfini);
    end;
   end;
   if checksysobjectmethod(sf1_incref) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_incref]:= ele.eledatarel(sub1);
     h.flags:= h.flags+[tf_managed,tf_needsmanage];
    end;
   end;
   if checksysobjectmethod(sf1_decref) then begin
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     infoclass.subattach[osa_decref]:= ele.eledatarel(sub1);
     h.flags:= h.flags+[tf_managed,tf_needsmanage];
    end;
   end;
   if sf1_default in subflags1 then begin
    if not (sf_destructor in subflags) or (sub1^.paramcount > 1) then begin
     errormessage(err_wrongdefaultdestructor,[]);
    end
    else begin
     with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
      infoclass.subattach[osa_destroy]:= ele.eledatarel(sub1);
     end;
    end;
   end;
   if subflags * [sf_operator,sf_operatorright] <> [] then begin
    if sub1^.paramcount*2 >= high(operatorsig.d)-1 then begin
     errormessage(err_toomanyoperparams,[]);
    end
    else begin
     operatorsig.high:= 0;
     if sf_functionx in subflags then begin
      setoperparamid(operatorsig,ele.eledataabs(
                                 pelementoffsetty(@sub1^.paramsrel)[0]));
      i1:= 2;
     end
     else begin
      setoperparamid(operatorsig,nil);
{
      p1^:= getident(0);
      inc(p1);
      p1^:= tks_void;
      inc(p1);
}
      i1:= 1;
     end;
     for i1:= i1 to sub1^.paramcount-1 do begin
      setoperparamid(operatorsig,ele.eledataabs(
                                 pelementoffsetty(@sub1^.paramsrel)[i1]));
     end;
     if sf_operator in subflags then begin
      if currentoperator = objectoperatoridents[oa_assign] then begin
       var1:= ele.eledataabs(sub1^.varchain); //last param
       if not isobject or (sub1^.paramcount <> 2) or 
                               (sf_functionx in subflags) or
               not (af_paramvar in var1^.address.flags) or
               (var1^.address.indirectlevel <> 1) or
               (var1^.vf.typ <> ele.elementparent) then begin
        errormessage(err_invalidassignop,[]);
       end
       else begin
        ptypedataty(ele.parentdata)^.infoclass.subattach[osa_assign]:= 
                                                         ele.eledatarel(sub1);
       end;
      end;
      operatorsig.d[0]:= currentoperator;
      if not ele.findcurrent(tks_operators,[],allvisi,ele1) then begin
       ele1:= ele.addelementduplicate1(tks_operators,ek_none,allvisi);
      end;
      if ele.adduniquechilddata(ele1,operatorsig,
                                          ek_operator,allvisi,poper1) then begin
       poper1^.methodele:= ele.eledatarel(sub1);
      end
      else begin
       errormessage(err_operatoralreadydefined,[getidentname(currentoperator)]);
      end;
     end;
     if sf_operatorright in subflags then begin
      operatorsig.d[0]:= currentoperatorright;
      if not ele.findcurrent(tks_operatorsright,[],allvisi,ele1) then begin
       ele1:= ele.addelementduplicate1(tks_operatorsright,ek_none,allvisi);
      end;
      if ele.adduniquechilddata(ele1,operatorsig,
                                          ek_operator,allvisi,poper1) then begin
       poper1^.methodele:= ele.eledatarel(sub1);
      end
      else begin
       errormessage(err_operatoralreadydefined,[getidentname(currentoperator)]);
      end;
     end;
    end;
   end;
   dec(s.stackindex,2);
   s.stacktop:= s.stackindex;
  end;
 end;
end;

procedure begintempvars();
begin
 with info do begin
  with additem(oc_goto)^ do begin //for possible tempvar init
   par.opaddress.opaddress:= opcount-1;
  end;
  tempinitlabel:= opcount;
  addlabel();
 end;
end;

procedure endtempvars();
var
 i1: int32;
 po2: popinfoty;
begin
 with info do begin
  i1:= opcount-1;
  addlabel();
  if writemanagedtempvarop(mo_ini,tempvarchain,s.stacktop) then begin
   po2:= getoppo(tempinitlabel,-1);
  {$ifdef mse_checkinternalerror}
   if po2^.op.op <> oc_goto then begin
    internalerror(ie_handler,'20170901A');
   end;
  {$endif}
   po2^.par.opaddress.opaddress:= i1;
  end;
  with additem(oc_goto)^ do begin       //terminator
   par.opaddress.opaddress:= tempinitlabel-1;
  end;
 end;
end;

procedure handlesubbody5a();
var
 po1,po2: psubdataty;
 po3: ptypedataty;
 po4: pvardataty;
 po5: pnestedvardataty;
 ele1,ele2: elementoffsetty;
 int1{,int2}: integer;
 alloc1: dataoffsty;
 ad1: opaddressty;
 lnr1: int32;
 id1: identty;
begin
{$ifdef mse_debugparser}
 outhandle('SUBBODY5A');
{$endif}
 checkforwardtypeerrors();
 with info,contextstack[s.stackindex-1] do begin
 {$ifdef mse_checkinternalerror}
  if d.kind <> ck_subdef then begin
   internalerror(ie_handler,'20151126A');
  end;
 {$endif}
  d.subdef.varsize:= locdatapo - d.subdef.parambase - d.subdef.paramsize;
  initsubstartinfo();
  managedtempref:= d.subdef.varsize;
  managedtemparrayid:= locallocid;  
  po1:= ele.eledataabs(d.subdef.ref);
  po1^.address:= opcount;
  if d.subdef.match <> 0 then begin
   po2:= ele.eledataabs(d.subdef.match);    
   if co_llvm in o.compileoptions then begin
    po1^.globid:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(po2,false); 
          //body order must be in header order-> nested subs first -> 
                                       //do not add to list in sub header
   end;
   if (po2^.flags * [sf_virtual,sf_override] <> []) and 
                    (sf_intfcall in po2^.flags) then begin
    po2^.trampolineaddress:= opcount;
    linkresolveopad(po2^.trampolinelinks,po2^.trampolineaddress);
    with additem(oc_virttrampoline)^ do begin
     if sf_functionx in po2^.flags then begin
      par.subbegin.trampoline.selfinstance:= -d.subdef.paramsize + vpointersize;
     end
     else begin
      par.subbegin.trampoline.selfinstance:= -d.subdef.paramsize;
     end;
     par.subbegin.trampoline.virttaboffset:= 
          ptypedataty(ele.eledataabs(
                datatoele(po2)^.header.parent))^.infoclass.virttaboffset;
     par.subbegin.trampoline.virtoffset:= po2^.tableindex*sizeof(opaddressty)+
                                                            virtualtableoffset;
     if co_llvm in o.compileoptions then begin
      par.subbegin.trampoline.virtoffset:= 
           info.s.unitinfo^.llvmlists.constlist.adddataoffs(
                                par.subbegin.trampoline.virtoffset).listid;
      par.subbegin.trampoline.virttaboffset:= 
           info.s.unitinfo^.llvmlists.constlist.adddataoffs(
                                par.subbegin.trampoline.virttaboffset).listid;
      par.subbegin.globid:= po1^.globid;               //trampoline
      po1^.trampolineid:= po1^.globid;
      po1^.globid:= info.s.unitinfo^.llvmlists.globlist.
                                     addtypecopy(po1^.globid); //real sub
     end;
    end;
    po1^.address:= opcount;
   end;
   po2^.address:= po1^.address;
   po2^.globid:= po1^.globid;
   po1^.flags:= po1^.flags*[sf_noimplicitexception] + po2^.flags;
   po1^.tableindex:= po2^.tableindex;
   if po2^.flags * [sf_virtual,sf_override] <> [] then begin
   {$ifdef mse_checkinternalerror}
    if currentcontainer = 0 then begin
     internalerror(ie_sub,'20140502A');
    end;
   {$endif}
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     if co_llvm in o.compileoptions then begin
      ad1:= po1^.globid;
     end
     else begin
      ad1:= po1^.address-1; //compensate oppo inc
     end;
     popaddressty(@(classdefpoty(getsegmentpo(infoclass.defs))^.
                                     virtualmethods))[po2^.tableindex]:= ad1;
              //resolve virtual table entry
    end;
   end;
   linkresolvecall(po2^.calllinks,po1^.address,po1^.globid);
   linkresolveopad(po2^.adlinks,po1^.address);
  end
  else begin //no header
   if co_llvm in o.compileoptions then begin
    po1^.globid:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(po1,false);
          //body order must be in header order-> nested subs first -> 
                                       //do not add to list in sub header
   end;
  end;
  linkresolvecall(po1^.calllinks,po1^.address,po1^.globid); //nested calls
  ele1:= po1^.varchain;
  po1^.varchain:= 0;
  while ele1 <> 0 do begin      //reverse order
   ele2:= po1^.varchain;
   po1^.varchain:= ele1;
   po4:= ele.eledataabs(ele1);
   ele1:= po4^.vf.next;
   po4^.vf.next:= ele2;
  end;

  ele1:= po1^.nestedvarchain;
  po1^.nestedvarchain:= 0;
  while ele1 <> 0 do begin      //reverse order
   ele2:= po1^.nestedvarchain;
   po1^.nestedvarchain:= ele1;
   po5:= ele.eledataabs(ele1);
   ele1:= po5^.next;
   po5^.next:= ele2;
  end;

  if co_llvm in o.compileoptions then begin
   if do_names in s.debugoptions then begin
    s.unitinfo^.llvmlists.globlist.namelist.addname(
                                        getidentname2(po1),po1^.globid);
   end;
   ele1:= po1^.varchain;
   alloc1:= getsegmenttopoffs(seg_localloc);
   int1:= 0;
   lnr1:= start.line;
   while ele1 <> 0 do begin      //number params and vars
    po4:= ele.eledataabs(ele1);
    with plocallocinfoty(
                allocsegmentpo(seg_localloc,sizeof(locallocinfoty)))^ do begin
     address:= po4^.address.locaddress.address;
     flags:= po4^.address.flags;
     size:= getopdatatype(po4^.vf.typ,po4^.address.indirectlevel);
     if do_proginfo in info.o.debugoptions then begin
      id1:= datatoele(po4)^.header.name;
      with s.unitinfo^.llvmlists.metadatalist do begin
       if id1 = tks_self then begin
        id1:= tk_self;
        debuginfo:= adddivariable(getidentname1(id1),lnr1,int1,po4^,
                                                             addtype(po4^));
       end
       else begin
        debuginfo:= adddivariable(getidentname1(id1),lnr1,int1,po4^);
       end;
      end;
     end;
    end;
    ele1:= po4^.vf.next;
    inc(int1);
   end;
   po1^.allocs.allocs:= alloc1;
   po1^.allocs.alloccount:= int1;
   po1^.allocs.paramcount:= po1^.paramcount;

   ele1:= po1^.nestedvarchain;
   po1^.allocs.nestedallocs:= getsegmenttopoffs(seg_localloc);
   int1:= 0;
   while ele1 <> 0 do begin      //number nested vars
    po5:= ele.eledataabs(ele1);
    with pnestedallocinfoty(
       allocsegmentpo(seg_localloc,sizeof(nestedallocinfoty)))^ do begin
     address:= po5^.address;
    end;
    ele1:= po5^.next;
    inc(int1);
   end;
   po1^.allocs.nestedalloccount:= int1;
  end
  else begin
   po1^.allocs:= nullallocs;
  end;
  resetssa();
  addsubbegin(oc_subbegin,po1);
  stacktempoffset:= locdatapo;
  if s.currentstatementflags * [stf_needsmanage,stf_needsini] <> [] then begin
   writemanagedvarop(mo_ini,po1^.varchain,[],s.stacktop);
  end;           //todo: implicit try-finally
//  if po1^.paramfinichain <> 0 then begin
  if sf_hasmanagedparam in po1^.flags then begin
   writemanagedvarop(mo_incref,po1^.varchain,[af_param],s.stacktop);
  end;
  begintempvars();
 {$ifdef mse_implicittryfinally}
  if (co_llvm in o.compileoptions) and 
                         not (sf_noimplicitexception in po1^.flags) then begin
   tryblockbegin();
  end;
 {$endif}
 end;
end;

procedure handlesubbody6();
var
 po1: psubdataty;
 po2: popinfoty;
 m1,m2: metavaluety;
 i1,i2,i3: int32;
 managedtempsize1,tempsize1,varsize1: int32;
 op1: popinfoty;
 landingpad1: landingpadty;
 b1: boolean;
{$ifdef mse_implicittryfinally}
 implicitexcept: boolean;
{$endif} 
begin
{$ifdef mse_debugparser}
 outhandle('SUBBODY6');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
   //todo: check local forward
  po1:= ele.eledataabs(d.subdef.ref);
 {$ifdef mse_implicittryfinally}
  implicitexcept:= false;
 {$endif}
  if co_llvm in o.compileoptions then begin
//   if sf_hasnestedaccess in po1^.flags then begin
//   if po1^.flags * [sf_hasnestedref,hasnestedaccess] <> [] then begin
   info.s.unitinfo^.llvmlists.globlist.updatesubtype(po1);
//   end;
  {$ifdef mse_implicittryfinally}
   implicitexcept:= not (sf_noimplicitexception in po1^.flags);
   if implicitexcept then begin
    checkopcapacity(10); //max
    op1:= additem(oc_goto);        //-> label 1                  //0
  
    landingpad1:= tryhandle(); //landingpad 1 ssa                //1
    tryblockend();
 
    i3:= opcount;
    with additem(oc_continueexception)^ do begin //2 ssa         //2
     par.landingpad:= landingpad1;
    end;
    
    with additem(oc_goto)^ do begin    //-> label 2              //3
     par.opaddress.opaddress:= opcount+1;        //jump to label 2
    end;
    op1^.par.opaddress.opaddress:= opcount-1;    //jump to label 1
   end;
  {$endif}
  end;

  addlabel();                                //label 1          //4
  linkresolveopad(po1^.exitlinks,opcount-1);
 {$ifdef mse_implicittryfinally}
  if implicitexcept then begin
   i2:= opcount;
   with additem(oc_iniexception)^ do begin //1 ssa              //5
    par.landingpad:= landingpad1;
   end;
   addlabel();                               //label 2          //6
  end;
 {$endif}                                                       //7...
  b1:= false;
  if s.currentstatementflags * [stf_needsmanage,stf_needsfini] <> [] then begin
   b1:= writemanagedvarop(mo_fini,po1^.varchain,[],s.stacktop) or b1;
  end;
  invertlist(tempvarlist,tempvarchain);
  b1:= writemanagedtempvarop(mo_decref,tempvarchain,s.stacktop) or b1;

//  if po1^.paramfinichain <> 0 then begin
  if sf_hasmanagedparam in po1^.flags then begin
   b1:= writemanagedvarop(mo_fini,po1^.varchain,[af_param],s.stacktop) or b1;
  end;
  b1:= writemanagedtempop(mo_decref,managedtempchain,s.stacktop) or b1;
  deletelistchain(managedtemplist,managedtempchain);
  managedtempsize1:= managedtempcount*targetpointersize; 
  tempsize1:= locdatapo-stacktempoffset;
  varsize1:= managedtempsize1+tempsize1+d.subdef.varsize;
  if varsize1 <> 0 then begin
   with additem(oc_locvarpop)^ do begin
    par.stacksize:= varsize1;
   end;
  end;
  i1:= d.subdef.paramsize;
  if sf_method in po1^.flags then begin
   if not (sf_destructor in po1^.flags) then begin 
                      //otherwise retain instancepointer for oc_destroyclass
    i1:= i1 + vpointersize; //instancepointer
   end;
//   if sf_constructor in po1^.flags then begin
//    i1:= i1 + vpointersize; //class pointer
//   end;
  end;
 {$ifdef mse_implicittryfinally}
  if implicitexcept then begin
   if b1 then begin
    with additem(oc_continueexception)^ do begin
     par.landingpad:= landingpad1;
    end;
    donop(i3);                 //remove continueexception 
   end
   else begin
    donop(i2);                 //niling landingpad not necessary 
   end;
  end;
 {$endif}
  if sf_functioncall in po1^.flags then begin
   with additem(oc_returnfunc)^ do begin
    par.stacksize:= i1;
//    par.returnfuncinfo.flags:= po1^.flags;
//    par.returnfuncinfo.allocs:= po1^.allocs;
   end;
  end
  else begin
   with additem(oc_return)^ do begin
    par.stacksize:= i1;
   end;
  end;
  endtempvars();
  locdatapo:= d.subdef.parambase;
  frameoffset:= d.subdef.frameoffsetbefore;
  dec(sublevel);
  if sublevel = 0 then begin
   currentzerolevelsub:= 0;
   checkpendingmanagehandlers(); //needs local definitions
   ele.releaseelement(b.elemark); //remove local definitions
  end;
  ele.elementparent:= b.eleparent;
  s.currentstatementflags:= b.flags;
  addsubend(po1);
  locallocid:= d.subdef.locallocidbefore;
  po2:= getoppo(po1^.address);
  with po2^ do begin
   if co_llvm in o.compileoptions then begin
    settempvars(par.subbegin.sub.allocs.llvm);
//    par.subbegin.sub.allocs.llvm.tempcount:= llvmtempcount;
//    par.subbegin.sub.allocs.llvm.firsttemp:= firstllvmtemp;
    if managedtempsize1 > 0 then begin
     par.subbegin.sub.allocs.llvm.managedtemptypeid:= 
         info.s.unitinfo^.llvmlists.typelist.addaggregatearrayvalue(
                                            managedtempsize1,ord(das_8));
     setimmint32(managedtempcount,
                         par.subbegin.sub.allocs.llvm.managedtempcount);
    end
    else begin
     par.subbegin.sub.allocs.llvm.managedtemptypeid:= 0;
    end;
    par.subbegin.sub.allocs.llvm.blockcount:= s.ssa.bbindex;
   end
   else begin
    par.subbegin.sub.allocs.stackop.tempsize:= tempsize1;
    par.subbegin.sub.allocs.stackop.managedtempsize:= managedtempsize1;
    par.subbegin.sub.allocs.stackop.varsize:= varsize1;
   end;
   par.subbegin.sub.flags:= po1^.flags;
  end;
  deletelistchain(tempvarlist,tempvarchain);

  s.ssa:= d.subdef.ssabefore;
  if do_proginfo in s.debugoptions then begin
//   m1.flags:= [mvf_globval,mvf_pointer];
//   m1.value.listid:= po1^.globid;
//   m1.value.typeid:= s.unitinfo^.llvmlists.globlist.
//                                           gettype(m1.value.listid);
   with info.s.unitinfo^ do begin
    m1:= llvmlists.metadatalist.addglobvalue(po1^.globid);
    m2:= llvmlists.metadatalist.adddisubroutinetype(
                                   po1{,filepathmeta,debugfilemeta});
    with pdisubprogramty(llvmlists.metadatalist.getdata(
                                                s.currentscopemeta))^ do begin
     _function:= m1;
     _type:= m2;
    end;
   end;
   popcurrentscope();
//   setcurrentscope(d.subdef.scopemetabefore);
  end;
  if sublevel = 0 then begin
   currentcontainer:= 0;
   currentobject:= 0;
  end;
 end;
end;

procedure callsub(const adestindex: int32; asub: psubdataty;
              const paramstart,paramco: int32; aflags: dosubflagsty;
                       const aobjssa: int32 = 0; const aobjsize: int32 = 0;
                                       ainstancetype: ptypedataty = nil);
var
 paramsize1: int32;
 paramschecked: boolean;
 lastitem: pcontextitemty;
// tempsize: int32;
 
 function doparam(var context1: pcontextitemty;
                               const subparams1: pelementoffsetty; 
                               var parallocpo: pparallocinfoty): boolean;
                 //parallocpo will be relocated in case of seg_localloc grow
                                              //false if skipped
 var
  vardata1: pvardataty;
  
  procedure doconvert();
  begin
   if not tryconvert(context1,ele.eledataabs(vardata1^.vf.typ),
                              vardata1^.address.indirectlevel,[]) then begin
    internalerror1(ie_handler,'20160519A');
   end;
  end; //doconvert

  procedure storetempgetaddress(); 
           //store stack value in local var and get address on stack
  var
   i1,i2,i3: int32;
   si1: databitsizety;
   sourcetype: ptypedataty;
   ad1: addressvaluety;
   ty1: typeallocinfoty;
  begin
   sourcetype:= ele.eledataabs(context1^.d.dat.datatyp.typedata);
              //dest can be untyped
   i3:= context1^.d.dat.fact.ssaindex; //data ssa
   if context1^.d.dat.datatyp.indirectlevel > 1 then begin
    i2:= targetpointersize;
    si1:= das_pointer;
   end
   else begin
    i2:= sourcetype^.h.bytesize;
    si1:= sourcetype^.h.datasize;
   end;
   ad1:= gettempaddress(i2);
   ty1:= getopdatatype(sourcetype,vardata1^.address.indirectlevel-1);
   if co_llvm in info.o.compileoptions then begin
    with insertitem(oc_tempalloc,context1,-1)^ do begin
     par.tempalloc.typid:= ty1.listindex;
     i1:= par.ssad;
    end;
   end;
   with insertitem(getpoptempop(si1),context1,-1)^ do begin
    par.memop.t:= getopdatatype(sourcetype,
                 vardata1^.address.indirectlevel-1);
    par.memop.t.flags:= par.memop.t.flags + [af_stacktemp,af_ssas2];
    if co_llvm in info.o.compileoptions then begin
     par.ssas1:= i3;
     par.ssas2:= i1; //alloc ssa
    end
    else begin
     par.memop.tempdataaddress.a:= ad1.tempaddress;
    end;
    par.memop.tempdataaddress.offset:= 0;
   end;
   if not (co_llvm in info.o.compileoptions) then begin
    pushinserttempaddress(ad1.tempaddress,getstackoffset(context1),-1);
   end
   else begin
    with insertitem(oc_potopo,context1,-1)^ do begin
     par.ssas1:= i1;
     context1^.d.dat.fact.ssaindex:= par.ssad;
    end;
   end;
  end; //storetempgetaddress()
  
 var
  desttype: ptypedataty;
  si1: databitsizety;
  stackoffset,i1,i2,i3: int32;
  conversioncost1: int32;
  err1: errorty;
  opref1: int32;
  p1,pe: pcontextitemty;
  p2: pointer;
  ele1: elementoffsetty;
  sourcetype: ptypedataty;
  destindilev1: int32;
  
 begin //doparam()
  result:= true; //not skipped
  with info do begin
   vardata1:= ele.eledataabs(subparams1^);
   if vardata1^.vf.typ = 0 then begin
    exit; //invalid param type
   end;
   desttype:= ptypedataty(ele.eledataabs(vardata1^.vf.typ));
   si1:= desttype^.h.datasize;
   stackoffset:= getstackoffset(context1);
   conversioncost1:= 1;
   if not paramschecked and
          not checkcompatibledatatype(context1,vardata1^.vf.typ,
                               vardata1^.address,[cco_novarconversion],
                                       conversioncost1,destindilev1) then begin
    err1:= err_incompatibletypeforarg;
    with context1^ do begin
     if d.kind = ck_typearg then begin
      sourcetype:= ele.eledataabs(d.typ.typedata);
      i1:= 0;
     end
     else begin
      sourcetype:= ele.eledataabs(d.dat.datatyp.typedata);
      i1:= context1^.d.dat.datatyp.indirectlevel-sourcetype^.h.indirectlevel;
     end;
    end;
    if vardata1^.address.flags * [af_paramvar,af_paramout] <> [] then begin
     err1:= err_callbyvarexact;
    end;
    i2:= 1;
    p1:= @contextstack[context1^.parent];
    while getnextnospace(p1+1,p1) and (p1 <> context1) do begin
     inc(i2);
    end;
    if context1^.d.kind = ck_list then begin
     errormessage(err1,[i2,'list',
                  typename(desttype^,destindilev1)],stackoffset);
    end
    else begin
     errormessage(err1,[i2,
               typename(sourcetype^,i1),
                  typename(desttype^,destindilev1)],stackoffset);
    end;
    exit;
   end;
   if context1^.d.kind = ck_typearg then begin
    if not getvalue(context1,das_none) then begin
     internalerror1(ie_handler,'20171122C');
    end;
   end;
   if (af_paramindirect in vardata1^.address.flags) then begin
    case context1^.d.kind of
     ck_const,ck_list: begin
      if not (af_const in vardata1^.address.flags) then begin
       errormessage(err_variableexpected,[],stackoffset);
      end
      else begin
       if context1^.d.kind = ck_const then begin
        if desttype^.h.kind = dk_none then begin
         errormessage(err_variableexpected,[],context1);
         exit;
        end;
        if not tryconvert(context1,desttype,
                  vardata1^.address.indirectlevel-1,[]) then begin
         internalerror1(ie_handler,'20170423A');
        end;
        if not getvalue(context1,das_none) then begin
         internalerror1(ie_handler,'20170424A');
        end;
        storetempgetaddress(); //get data pointer
       end
       else begin
        if desttype^.h.kind = dk_openarray then begin
         p2:= getsegmentbase(seg_localloc);
         if af_untyped in vardata1^.address.flags then begin
          if not listtoarrayofconst(context1,lastitem,true) then begin
           exit;
          end;
         end
         else begin
          if not listtoopenarray(context1,desttype,lastitem,true) then begin
           exit;
          end;
         end;
         inc(pointer(parallocpo),getsegmentbase(seg_localloc)-p2);
                    //relocate
         if context1^.d.kind = ck_const then begin
          pushinsertconst(stackoffset,-1,si1,true);
         end;
        end
        else begin
         errormessage(err_variableexpected,[],stackoffset);
 //       notimplementederror('20140405B'); //todo
        end;
       end;
      end;
     end;
     ck_ref: begin
      if desttype^.h.kind = dk_openarray then begin
       if not tryconvert(context1,ele.eledataabs(vardata1^.vf.typ),
                        vardata1^.address.indirectlevel-1,
                              [coo_paramindirect,coo_errormessage]) or
               (context1^.d.kind = ck_ref) and
                         not getaddress(context1,true) then begin //????
        exit;
       end;
      end
      else begin
       getaddress(context1,true);
//       pushinsertaddress(stackoffset,-1);
      end;
     end;
     ck_fact,ck_subres: begin
      with context1^ do begin
       if (faf_varsubres in d.dat.fact.flags) and 
                   (co_llvm in o.compileoptions) then begin
        with insertitem(oc_pushtempaddr,stackoffset,-1)^ do begin
         par.tempaddr.a.ssaindex:= d.dat.fact.varsubres.ssaindex;
        end;
        exclude(d.dat.fact.flags,faf_varsubres);
        dec(d.dat.indirection);
       end;
       if d.dat.indirection = 0 then begin
        if not (dsf_objassign in aflags) then begin
         storetempgetaddress();
        end;
       end
       else begin
        if d.dat.indirection < -1 then begin
         inc(d.dat.indirection);
         inc(d.dat.datatyp.indirectlevel);
         getvalue(context1,si1);
        end;
       end;
      end;
     end;
     else begin
      internalerror1(ie_parser,'20171122A');
     end;
    end;
   end
   else begin
    with desttype^ do begin
     if h.indirectlevel > 0 then begin
      si1:= das_pointer;
     end
     else begin
      si1:= h.datasize;
     end;
    end;
    
    if context1^.d.kind = ck_list then begin
     case desttype^.h.kind of
      dk_set: begin
       if not listtoset(context1,lastitem) then begin
        exit;
       end;
       conversioncost1:= 0;
      end;
      dk_openarray: begin
       if sf_vararg in asub^.flags then begin
        pe:= context1+context1^.d.list.contextcount;
        p1:= context1+1;
        while p1 < pe do begin
         if p1^.d.kind = ck_list then begin
          p1:= p1+p1^.d.list.contextcount;
         end
         else begin
          exclude(p1^.d.handlerflags,hf_listitem);
          inc(p1);
         end;
        end;
        result:= false; //skip
        exit;
       end;
       if af_untyped in vardata1^.address.flags then begin
        if not listtoarrayofconst(context1,lastitem,false) then begin
         exit;
        end;
       end
       else begin
        if not listtoopenarray(context1,desttype,lastitem,false) then begin
         exit;
        end;
       end;
       conversioncost1:= 0;
      end;
      else begin
       internalerror1(ie_handler,'20160612A');
      end;
     end;
    end;
    case context1^.d.kind of
     ck_const: begin
      if conversioncost1 > 0 then begin
       doconvert();
      end;
      pushinsertconst(stackoffset,-1,si1);
     end;
     ck_ref: begin
      if desttype^.h.kind <> dk_openarray then begin //address needed?
       getvalue(context1,si1);                       //no
      end;
      if conversioncost1 > 0 then begin
       doconvert();
      end;
     end;
     ck_fact,ck_subres: begin
      if (context1^.d.dat.indirection < 0) or //pending dereference
         (faf_varsubres in context1^.d.dat.fact.flags) and
                                    (co_llvm in o.compileoptions)  then begin 
       getvalue(context1,si1);                       
      end;
      if conversioncost1 > 0 then begin
       doconvert();
      end;
     end;
     else begin
      internalerror1(ie_handler,'20171122B');
     end;
    end;
   end;
   if (af_paramvar in vardata1^.address.flags) and 
                                  (context1^.d.kind in factcontexts) then begin
    checkneedsunique(stackoffset);
   end;
   with parallocpo^ do begin
    ssaindex:= context1^.d.dat.fact.ssaindex;
    size:= getopdatatype(vardata1^.vf.typ,vardata1^.address.indirectlevel);
    inc(paramsize1,alignsize(getbytesize(size)));
   end;
  end;
 end; //doparam()

var
 po1: popinfoty;
 resulttype1: ptypedataty;
 subparams1,subparamse: pelementoffsetty;
 po7: pelementinfoty;
 totparamco: integer; //including internal params
 i1,i2,i3: integer;
 bo1: boolean;
 parallocstart: dataoffsty;
                    //todo: paralloc info for hidden params
 selfpo,parallocpo: pparallocinfoty;
 hasresult,hasvarresult: boolean;
 idents1: identvecty;
 firstnotfound1: integer;
 callssa: int32;
 vardata1: pvardataty;
 lastparamsize1: int32;
 instancessa: int32;
 subdata1: psubdataty;
 cost1,matchcount1: int32;
 needsvarcheck: boolean;
 destoffset,topoffset: int32;

 procedure dodefaultparams();
 var
  i1: int32;  
  desttype: ptypedataty;
  vardata1: pvardataty;
  si1: databitsizety;
 begin
  with info do begin
   i1:= asub^.paramcount - totparamco; //defaultparamcount
   if i1 > 0 then begin
    if paramco = 0 then begin //no data context at top
     inc(s.stacktop);
    end;
    for i1:= i1-1 downto 0 do begin
     vardata1:= ele.eledataabs(subparams1^);
     desttype:= ptypedataty(ele.eledataabs(vardata1^.vf.typ));
    {$ifdef mse_checkinternalerror}
     if vardata1^.vf.defaultconst <= 0 then begin
      internalerror(ie_handler,'20160521D');
     end;
    {$endif}
     with desttype^ do begin
      if h.indirectlevel > 0 then begin
       si1:= das_pointer;
      end
      else begin
       si1:= h.datasize;
      end;
     end;
     pushinsertconst(s.stacktop-s.stackindex,
          pconstdataty(ele.eledataabs(vardata1^.vf.defaultconst))^.val.d,
                                                                 -1,si1);
     with parallocpo^ do begin
     {$ifdef mse_checkinternalerror}
      if contextstack[s.stacktop].d.kind <> ck_fact then begin
       internalerror(ie_handler,'20160521E');
      end;
     {$endif}
      ssaindex:= contextstack[s.stacktop].d.dat.fact.ssaindex;
      size:= getopdatatype(vardata1^.vf.typ,vardata1^.address.indirectlevel);
      inc(paramsize1,alignsize(getbytesize(size)));
     end;
     inc(subparams1);
     inc(parallocpo);
    end;
    if paramco = 0 then begin //no data context at top
     dec(s.stacktop);
    end;
   end;
  end;
 end; //dodefaultparams()

 function callclasssubattach(const instancetype1: ptypedataty;
                                       const attach: objsubattachty): boolean;
 var
  asub: elementoffsetty;
 begin
  result:= false;
  asub:= instancetype1^.infoclass.subattach[attach];
  if asub <> 0 then begin
   result:= true;
   callsub(adestindex,ele.eledataabs(asub),paramstart,0,
            [dsf_instanceonstack,dsf_attach,dsf_useobjssa] + 
            aflags*[dsf_destroy,dsf_noparams,dsf_noinstancecopy],
                                               instancessa,0,instancetype1);
   if co_mlaruntime in info.o.compileoptions then begin
    with insertitem(oc_push,topoffset,-1)^ do begin
     if dsf_destroy in aflags then begin
      par.imm.vsize:= 2*targetpointersize; //compensate stackpop
     end
     else begin
      par.imm.vsize:= targetpointersize; //compensate stackpop
     end;
    end;
   end;
  end;
 end; //callclasssubattach()

 procedure doinstanceonstack(var instancetype1: ptypedataty);
 begin
  with info.contextstack[adestindex] do begin
   if dsf_destroy in aflags then begin
    instancessa:= aobjssa;
    if dsf_useinstancetype in aflags then begin
     instancetype1:= ainstancetype;
    end
    else begin
     instancetype1:= ele.eledataabs(d.typ.typedata);
    end;
   end
   else begin
    if dsf_useinstancetype in aflags then begin //not used up to now
     instancetype1:= ainstancetype;
    end
    else begin
     instancetype1:= ele.eledataabs(d.dat.datatyp.typedata);
    end;
    if dsf_usedestinstance in aflags then begin
     instancessa:= d.dat.fact.instancessa; //for sf_method
    end
    else begin
     if dsf_useobjssa in aflags then begin
      instancessa:= aobjssa;
     end
     else begin
      instancessa:= d.dat.fact.ssaindex; //for sf_method
     end;
    end;
   end;
   if (sf_destructor in asub^.flags) then begin
    callclasssubattach(instancetype1,osa_beforedestruct);
   end;
  end;
 end; //doinstanceonstack()

 procedure dodispose(const instancetype1: ptypedataty);
 var
  adref1: addressrefty;
  mo1: managedopty;
 begin
  if instancetype1^.infoclass.subattach[osa_dispose] <> 0 then begin
   callclasssubattach(instancetype1,osa_dispose);
  end
  else begin
   if (icf_virtual in instancetype1^.infoclass.flags) and 
                       not (co_mlaruntime in info.o.compileoptions) then begin
                              //not implemented in runtime mode
    callclassdefproc(cdp_fini,instancetype1,instancessa,topoffset);
   end
   else begin
    if instancetype1^.h.flags*[tf_needsmanage,tf_needsfini] <> [] then begin
     adref1.offset:= 0;
     adref1.ssaindex:= instancessa;
     adref1.contextindex:= info.s.stacktop;
     adref1.isclass:= false;
     adref1.kind:= ark_stack;
     adref1.address:= 0; //instance removed by destroy()
     adref1.typ:= instancetype1;
     if tf_needsfini in instancetype1^.h.flags then begin
      mo1:= mo_fini;
     end
     else begin
      mo1:= mo_decref;
     end;
     writemanagedtypeop(mo1,instancetype1,adref1);
    end;
   end;
   with insertitem(oc_destroyclass,topoffset,-1)^ do begin
    par.ssas1:= instancessa;
    par.destroyclass.flags:= [];
   end;
  end;
 end; //dodispose()
 
var
 instancetype1: ptypedataty;

 realparamco: int32; //including defaults
 {poparams,indpo,}poitem1{,pe}: pcontextitemty;
 stacksize,resultsize: int32;
 isfactcontext,isconstructor: boolean;
 ismethod: boolean;
 opoffset1: int32;
 methodtype1: ptypedataty;
 i4: int32;
 b1: boolean;
 typ1: ptypedataty;
 varargcount: int32;
 varargs: array[0..maxparamcount] of int32;
 isvararg: boolean;
 isllvmgetmem: boolean;
 constbufferref: segmentstatety;
 varresulttemp: tempaddressty;
 varresulttempaddr: int32;
 op1: popinfoty;
 adref1: addressrefty;
 landingpad1: landingpadty;
 
label
 paramloopend;
begin
{$ifdef mse_debugparser}
 outhandle('callsub');
{$endif}
 varargcount:= 0;
 isvararg:= sf_vararg in asub^.flags;
 isconstructor:= false;
 with info do begin
//  indpo:= @contextstack[s.stackindex];
//  pe:= @contextstack[s.stacktop];
  ele.checkcapacity(ek_type,1,asub,ainstancetype); //for anonymus method def
  destoffset:= adestindex-s.stackindex;
  topoffset:= s.stacktop-s.stackindex;
  with contextstack[adestindex] do begin //classinstance, result,
                                         //classdefreturn for ini/fini
   if dsf_instanceonstack in aflags then begin
    doinstanceonstack(instancetype1);
   end;
   paramschecked:= false;
   if (sf_overload in asub^.flags) and 
              not (dsf_nooverloadcheck in aflags) then begin //check overloads
    needsvarcheck:= true;
    subdata1:= asub;
    matchcount1:= 0;
    cost1:= bigint;
    while true do begin
    {$ifdef mse_checkinternalerror}
     if datatoele(subdata1)^.header.kind <> ek_sub
                            {datatoele(asub)^.header.kind} then begin
      internalerror(ie_handler,'20160517A');
     end;
    {$endif}
     subparams1:= @subdata1^.paramsrel;
     subparamse:= subparams1 + subdata1^.paramcount;
     totparamco:= paramco;
     if [sf_functionx] * subdata1^.flags <> [] then begin
      inc(totparamco); //result parameter
      inc(subparams1);
     end;
     if sf_method in subdata1^.flags then begin
      inc(totparamco); //self parameter
      inc(subparams1);
     end;
     i3:= 0;
     bo1:= false;
     if (totparamco >= subdata1^.paramcount - subdata1^.defaultparamcount) and
                (totparamco <= subdata1^.paramcount) then begin 
      poitem1:= @contextstack[adestindex+2]; //????
      while subparams1 < subparamse do begin //find best parameter match
       if not getnextnospace(poitem1+1,poitem1) then begin
        poitem1:= nil; //needs default param
        break;
       end;
       vardata1:= ele.eledataabs(subparams1^);
       bo1:= bo1 or (vardata1^.address.flags * [af_paramvar,af_paramout] <> []);
       if (vardata1^.vf.typ = 0) or 
             not checkcompatibledatatype(poitem1,
                        vardata1^.vf.typ,vardata1^.address,[],i2,i4) then begin
                                                           //report byvalue,
                                                           //byaddress dup
        goto paramloopend;
       end;
       i2:= i2*32; //room for default params cost
       if i3 < i2 then begin
        i3:= i2;             //maximal cost
       end;
       inc(subparams1);
      end;
      if poitem1 = nil then begin
       inc(i3);      //needs default params
      end;
      if i3 < cost1 then begin
       cost1:= i3;
       asub:= subdata1;
       matchcount1:= 1;
       needsvarcheck:= bo1;
      end
      else begin
       if i3 = cost1 then begin
        inc(matchcount1);
       end;
      end;
     end;
 paramloopend:
     if subdata1^.nextoverload <= 0 then begin
      break;
     end;
     subdata1:= ele.eledataabs(subdata1^.nextoverload);
    end;
    if matchcount1 > 1 then begin
     errormessage(err_cantdetermine,[]);
     exit;
    end;
    paramschecked:= not needsvarcheck;
   end;

   if stf_getaddress in s.currentstatementflags then begin
    if stf_params in s.currentstatementflags then begin
     errormessage(err_cannotaddresscall,[],destoffset);
     exit;
    end;
    if dsf_instanceonstack in aflags then begin
                                     //get method
    {$ifdef mse_checkinternalerror}
     if d.kind <> ck_fact then begin
      internalerror(ie_handler,'20160916A');
     end;
    {$endif}
    end;
    initdatacontext(d,ck_ref);
    d.dat.datatyp.typedata:= asub^.typ;
    d.dat.datatyp.indirectlevel:= 0;
    d.dat.datatyp.flags:= [tf_subad];
    d.dat.ref.c.address:= nilopad;
    d.dat.ref.c.address.segaddress.element:= ele.eledatarel(asub); 
    d.dat.ref.offset:= 0;
    d.dat.ref.c.varele:= 0;
    if dsf_instanceonstack in aflags then begin //get method
     case instancetype1^.h.kind of
      dk_interface: begin
       with insertitem(oc_getintfmethod,destoffset,-1)^ do begin
        par.getvirtsubad.virtoffset:= asub^.tableindex*sizeof(intfitemty) +
                                                        sizeof(intfdefheaderty);
        if co_llvm in info.o.compileoptions then begin
         par.ssas1:= instancessa; //class
         par.getvirtsubad.virtoffset:= 
               info.s.unitinfo^.llvmlists.constlist.
                          adddataoffs(par.getvirtsubad.virtoffset).listid;
        end;
       end;
       initfactcontext(destoffset);
      end;
      dk_class,dk_object,dk_classof: begin
       d.dat.ref.c.address.segaddress.address:= asub^.globid;
       if asub^.flags * [sf_virtual,sf_override] <> [] then begin
        with insertitem(oc_getvirtsubad,destoffset,-1)^ do begin
         par.getvirtsubad.virtoffset:= asub^.tableindex*sizeof(opaddressty)+
                                                           virtualtableoffset;
         if co_llvm in info.o.compileoptions then begin
          par.ssas1:= instancessa; //class
          par.getvirtsubad.virtoffset:= 
                info.s.unitinfo^.llvmlists.constlist.
                           adddataoffs(par.getvirtsubad.virtoffset).listid;
         end;
        end;
        initfactcontext(destoffset);
       end
       else begin
        getaddress(@contextstack[adestindex],true);
       end;
      {$ifdef mse_checkinternalerror}
       if d.kind <> ck_fact then begin
        internalerror(ie_handler,'20160916A');
       end;
      {$endif}
       i2:= d.dat.fact.ssaindex;
       with insertitem(oc_combinemethod,destoffset,-1)^ do begin
        par.ssas1:= instancessa;
        par.ssas2:= i2;
       end;
      end;
      else begin
       internalerror1(ie_handler,'20160821C');
      end;
     end;
     methodtype1:= ele.addelementdata(getident(),ek_type,nonevisi); //anonymous
     inittypedatabyte(methodtype1^,dk_method,0,2*targetpointersize,[tf_method]);
     methodtype1^.infosub.sub:= ele.eledatarel(asub);
     d.dat.datatyp:= methoddatatype; //sub type undefined
     d.dat.datatyp.typedata:= ele.eledatarel(methodtype1);
     dec(d.dat.indirection); //restore getaddress
     dec(d.dat.datatyp.indirectlevel); //restore getaddress
    end;
   end
   else begin //not getaddress
    isfactcontext:= d.kind in factcontexts;
    ismethod:= asub^.flags * [sf_method,sf_ofobject] = [sf_method];
    isllvmgetmem:= false;

    if ismethod then begin
     if (dsf_ownedmethod in aflags) then begin
               //owned method
     {$ifdef mse_checkinternalerror}
      if ele.findcurrent(tks_self,[],allvisi,vardata1) <> ek_var then begin
       internalerror(ie_value,'20140505A');
      end;
     {$else}
      ele.findcurrent(tk_self,[],allvisi,vardata1);
     {$endif}
      with insertitem(oc_pushlocpo,destoffset,-1)^ do begin
       par.memop.t:= bitoptypes[das_pointer];
       par.memop.locdataaddress.a.framelevel:= -1;
       par.memop.locdataaddress.a.address:= vardata1^.address.poaddress;
       par.memop.locdataaddress.offset:= 0;
       instancessa:= par.ssad;
      end;
      instancetype1:= ele.eledataabs(vardata1^.vf.typ);
      if (sf_destructor in asub^.flags) and 
                         not (dsf_isinherited in aflags) then begin
       callclasssubattach(instancetype1,osa_beforedestruct);
      end;
     end
     else begin
      if aflags*[dsf_objini,dsf_objfini,dsf_attach] <> [] then begin
       instancessa:= aobjssa;
       instancetype1:= ainstancetype;
      end
      else begin
       if aflags*[dsf_instanceonstack,dsf_indirect,
                              dsf_readsub,dsf_writesub] = [] then begin
        if ismethod and isfactcontext then begin
         if (sf_class in asub^.flags) then begin
          if d.dat.datatyp.indirectlevel <> 0 then begin
           errormessage(err_classinstanceexpected,[]);
          end;
         end
         else begin
          if d.dat.datatyp.indirectlevel <> 0 then begin
           errormessage(err_objectpointerexpected,[]);
          end;
         end;
        end;
        if ismethod and isfactcontext and (d.dat.indirection = 0) then begin
         i1:= d.dat.fact.ssaindex;
         typ1:= ele.eledataabs(d.dat.datatyp.typedata);
         with insertitem(oc_pushstackaddr,destoffset,-1)^.par do begin
          memop.tempdataaddress.a.address:= -alignsize(typ1^.h.bytesize);
          memop.tempdataaddress.offset:= 0;
          ssas1:= i1;
          memop.t:= getopdatatype(typ1,0);
         end;
         include(aflags,dsf_instanceonstack);
         doinstanceonstack(instancetype1);
        end
        else begin
         if d.kind <> ck_none then begin //constructor otherwise
          inc(d.dat.indirection);              //instance pointer
          inc(d.dat.datatyp.indirectlevel);
          getvalue(@contextstack[adestindex],das_none);
         end;
        end;
       end;
       if not (dsf_instanceonstack in aflags) then begin
        if dsf_destroy in aflags then begin
         instancessa:= aobjssa;
        end
        else begin
         if dsf_usedestinstance in aflags then begin
          instancessa:= d.dat.fact.instancessa;
         end
         else begin
          instancessa:= d.dat.fact.ssaindex;
         end;
                             //for sf_method, invalid for constructor
        end;
       end;
      end;
     end; //ismethod
    end;

    if dsf_indirect in aflags then begin
     if co_llvm in o.compileoptions then begin
      if sf_ofobject in asub^.flags then begin //method pointer call
       with insertitem(oc_getmethodcode,{topoffset}destoffset,-1)^ do begin
        par.ssas1:= instancessa; //[code,data]
        callssa:= par.ssad;
       end;
//       callssa:= d.dat.fact.ssaindex;
       with insertitem(oc_getmethoddata,{topoffset}destoffset,-1)^ do begin
        par.ssas1:= instancessa; //[code,data]
        instancessa:= par.ssad;
       end;
       include(aflags,dsf_useobjssa); //do not update instancessa later
//       instancessa:= d.dat.fact.ssaindex;
      end
      else begin
       callssa:= d.dat.fact.ssaindex;
      end;
     end;
    end;
    
    if (aflags*[dsf_instanceonstack,dsf_classdefonstack] = 
             [dsf_instanceonstack]) and 
                   (sf_classmethod in asub^.flags) and isfactcontext then begin
     typ1:= ele.eledataabs(d.dat.datatyp.typedata);
     if (typ1^.h.kind in [dk_class,dk_object]) then begin
      if icf_virtual in typ1^.infoclass.flags then begin
       with insertitem(oc_getclassdef,destoffset,-1)^.par do begin
        ssas1:= instancessa;
        setimmint32(typ1^.infoclass.virttaboffset,imm);
       end;
      end
      else begin
       with insertitem(oc_pushclassdef,destoffset,-1)^.par do begin
        if co_llvm in o.compileoptions then begin
         classdefid:= getclassdefid(typ1);
        end
        else begin
         classdefstackops:= typ1^.infoclass.defs.address;
        end;
        instancessa:= ssad;
       end;
      end;
     end;
    end;

    subparams1:= @asub^.paramsrel;
    totparamco:= paramco;
    if [sf_functionx] * asub^.flags <> [] then begin
     inc(totparamco); //result parameter
    end;
    if sf_method in asub^.flags then begin
     inc(totparamco); //self parameter
    end;
    if ((totparamco < asub^.paramcount - asub^.defaultparamcount) or 
                (totparamco > asub^.paramcount)) and 
         not (isvararg and (asub^.paramcount-totparamco = 1)) then begin 
                                         //todo: use correct source pos
     identerror(datatoele(asub)^.header.name,err_wrongnumberofparameters);
     exit;
    end;
    varresulttempaddr:= -1;
    hasresult:= (sf_functionx in asub^.flags) or 
          (not isfactcontext or (dsf_classdefonstack in aflags)) and 
          (sf_constructor in asub^.flags) and not (dsf_isinherited in aflags);
    hasvarresult:= hasresult and 
          (asub^.flags*[sf_functioncall,sf_constructor] = []);
    
    if hasresult then begin
     initfactcontext(destoffset); //set ssaindex
     if hasvarresult then begin
      include(d.dat.fact.flags,faf_varsubres);
      d.dat.fact.varsubres.startopoffset:= getcontextopcount(destoffset);
      varresulttemp:= alloctempvar(asub^.resulttype.typeele,
                                     d.dat.fact.varsubres.tempvar).tempaddress;
      d.dat.fact.varsubres.ssaindex:= varresulttemp.ssaindex;
      if co_llvm in o.compileoptions then begin
       with insertitem(oc_pushtempaddr,destoffset,-1)^ do begin
        par.tempaddr.a:= varresulttemp;
//        if co_llvm in o.compileoptions then begin
         varresulttempaddr:= par.ssad;
//        end;
       end;
      end;
     end;
     if dsf_instanceonstack in aflags then begin
      d.dat.fact.ssaindex:= instancessa; 
                 //revert modification by varresulttemp
     end;
     if (sf_constructor in asub^.flags) and 
                 not (dsf_noconstructor in aflags) then begin //needs memory
               //todo: catch exception and call destroy
      include(d.dat.fact.flags,faf_create);
      isconstructor:= true;
      if dsf_useinstancetype in aflags then begin
       resulttype1:= ainstancetype;
      end
      else begin
       bo1:= findkindelementsdata(1,[],allvisi,resulttype1,
                                                    firstnotfound1,idents1,1);
                                           //get class type
      {$ifdef mse_checkinternalerror}
       if not bo1 then begin 
        internalerror(ie_handler,'20150325A'); 
       end;
      {$endif}
      end;
      instancetype1:= resulttype1;
      with resulttype1^.infoclass do begin
       if subattach[osa_new] <> 0 then begin
        if dsf_classdefonstack in aflags then begin
        end
        else begin
         with insertitem(oc_pushclassdef,destoffset,-1)^.par do begin
          if co_llvm in o.compileoptions then begin
           classdefid:= getclassdefid(resulttype1);
          end
          else begin
           classdefstackops:= resulttype1^.infoclass.defs.address;
          end;
          instancessa:= ssad;
         end;
        end;
        callsub(adestindex,ele.eledataabs(subattach[osa_new]),paramstart,0,
           [dsf_instanceonstack,dsf_classdefonstack,dsf_useobjssa,dsf_noparams,
                  dsf_useinstancetype],instancessa,0,resulttype1);
        instancessa:= d.dat.fact.ssaindex; //for sf_constructor
       end
       else begin
        with insertitem(oc_getobjectmem,destoffset,-1)^ do begin
         setimmint32(allocsize,par.imm);
        end;
        instancessa:= d.dat.fact.ssaindex; //for sf_constructor
        b1:= true;
        if b1 and (tf_needsmanage in resulttype1^.h.flags) or
                           (tf_needsini in resulttype1^.h.flags) then begin
         adref1.offset:= 0;
         adref1.ssaindex:= instancessa;
         adref1.contextindex:= adestindex;
         adref1.isclass:= false;
         adref1.kind:= ark_stack;
         adref1.address:= 0;
         adref1.typ:= resulttype1;
         writemanagedtypeop(mo_ini,resulttype1,adref1);
        end;
       end;
      end;
      isllvmgetmem:= co_llvm in o.compileoptions;
      if isllvmgetmem then begin
       tryblockbegin();
      end;      
     end
     else begin
      resulttype1:= ele.eledataabs(asub^.resulttype.typeele);
      inc(subparams1);
     end;
     d.kind:= ck_subres;
     d.dat.datatyp.indirectlevel:= asub^.resulttype.indirectlevel;
     d.dat.datatyp.typedata:= ele.eledatarel(resulttype1);        
     d.dat.fact.opdatatype:= getopdatatype(resulttype1,
                                                d.dat.datatyp.indirectlevel);
    end;

    if isvararg then begin
     checksegmentcapacity(seg_localloc,sizeof(parallocinfoty)*maxparamcount);
                                                             //max
    end
    else begin
     checksegmentcapacity(seg_localloc,sizeof(parallocinfoty)*asub^.paramcount);
                                                             //max
    end;
    parallocstart:= getsegmenttopoffs(seg_localloc);    

    if sf_functionx in asub^.flags then begin
     parallocpo:= pparallocinfoty(
                        allocsegmentpo(seg_localloc,sizeof(parallocinfoty)));
     d.dat.fact.varsubres.varparam:= getsegmentoffset(seg_localloc,parallocpo);
     with parallocpo^ do begin
      ssaindex:= varresulttempaddr;
      size:= d.dat.fact.opdatatype;//getopdatatype(po3,po3^.indirectlevel);
     end;
    end;
    if sf_method in asub^.flags then begin
     selfpo:= allocsegmentpo(seg_localloc,sizeof(parallocinfoty));
     with selfpo^ do begin
      ssaindex:= instancessa;
      size:= bitoptypes[das_pointer];
     end;
     inc(subparams1); //first param
    end;
    opoffset1:= getcontextopcount(adestindex-s.stackindex);
    if co_mlaruntime in o.compileoptions then begin
     stacksize:= 0;
     resultsize:= 0;
     if hasresult and not hasvarresult and not isconstructor then begin 
               //result already reserved by getmem for constructor
      i2:= opoffset1; //insert result space at end of statement
      if sf_method in asub^.flags then begin
       i2:= 0; //insert result space before instance
       stacksize:= vpointersize;
      end;
      resultsize:= pushinsertvar(destoffset,
                              i2,asub^.resulttype.indirectlevel,resulttype1);
      inc(opoffset1);
      stacksize:= stacksize + resultsize; //alloc space for return value
      locdatapo:= locdatapo + resultsize;
     end;
     stacksize:= stacksize + aobjsize;
    end;
    paramsize1:= 0;
    realparamco:= asub^.paramcount-(totparamco-paramco);
    parallocpo:= allocsegmentpo(seg_localloc,sizeof(parallocinfoty)*
                                 realparamco);
                                 //including default params
    if paramstart = 0 then begin
     poitem1:= @contextstack[0];
    end
    else begin
     poitem1:= @contextstack[paramstart-1]; //before first param
    end;
    lastitem:= nil;
//    tempsize:= 0;
    i1:= paramco;
//    tempsbefore:= locdatapo;
    if dsf_indexedsetter in aflags then begin
     inc(parallocpo); //second, first index
     inc(subparams1);
     while i1 > 1 do begin
      getnextnospace(poitem1+1,poitem1);
      doparam(poitem1,subparams1,parallocpo);
      inc(subparams1);
      inc(parallocpo);
      dec(i1);
     end;
     dodefaultparams();
     lastparamsize1:= paramsize1;
     dec(parallocpo,paramco); //first, value
     dec(subparams1,paramco);
     getnextnospace(poitem1+1,poitem1);
     doparam(poitem1,subparams1,parallocpo); //last
     lastparamsize1:= paramsize1 - lastparamsize1;
    end
    else begin
     if not (dsf_noparams in aflags) then begin
      paramschecked:= paramschecked or (dsf_objassign in aflags);
      constbufferref:= savesegment(seg_globconst); //for openarray const
      while i1 > 0 do begin
       getnextnospace(poitem1+1,poitem1);
       if doparam(poitem1,subparams1,parallocpo) then begin 
                                      //vararg list skipped?
        inc(subparams1);              //no
        inc(parallocpo);
        dec(i1);
       end
       else begin
        i1:= maxparamcount-asub^.paramcount;
        while getnextnospace(poitem1+1,poitem1) do begin
         getvalue(poitem1,das_none);
         parallocpo^.ssaindex:= poitem1^.d.dat.fact.ssaindex;
         inc(varargcount);
         inc(parallocpo);
         if varargcount >= i1 then begin
          errormessage(err_toomanyparams,[]);
          break;
         end;
        end;
        allocsegmentpo(seg_localloc,varargcount*sizeof(parallocinfoty));
        break;
       end;
      end;
      if not isvararg then begin
       dodefaultparams(); //varargs can not have defaultparams
      end;
      if dsf_instanceonstack in aflags then begin
       if aflags * 
             [dsf_usedestinstance,dsf_useobjssa] = [] then begin
        selfpo^.ssaindex:= d.dat.fact.ssaindex; 
               //could be shifted by right side operator param
       end;
      end;
      if co_llvm in o.compileoptions then begin
       restoresegment(constbufferref); //data stored in llvmconst
      end;
     end;
    end;
//    locdatapo:= tempsbefore;
    if lastitem > poitem1 then begin
     topoffset:= getstackindex(lastitem);
    end
    else begin
//     if true {lastitem <> nil} then begin
     if lastitem <> nil then begin
      topoffset:= getstackindex(poitem1);
     end
     else begin
     {
      topoffset:= adestindex+1;
      if topoffset > s.stacktop then begin
       topoffset:= s.stacktop;
      end
      else begin
       topoffset:= getnextnospace(topoffset);
      end;
      }
      if dsf_objconvert in aflags then begin
       topoffset:= destoffset; //no params
      end
      else begin
       topoffset:= s.stacktop; //no params
      end;
     end;
    end;
    if topoffset < paramstart then begin
     topoffset:= paramstart;
    end;
    topoffset:= topoffset - s.stackindex;
    if topoffset < destoffset then begin
     topoffset:= destoffset; //from calloperatorright()
    end;
    if co_mlaruntime in o.compileoptions then begin
     poitem1:= @contextstack[paramstart];
     if poitem1^.d.kind <> ck_params then begin //no params
      dec(poitem1);
     end;
     if hasresult then begin
      if hasvarresult then begin
       with insertitem(oc_pushtempaddr,destoffset,
                                 opoffset1)^.par.tempaddr do begin
                                               //result var param
        a:= varresulttemp;
       end;
      end
      else begin
       with insertitem(oc_pushstackaddr,destoffset,opoffset1)^.
                                      par.memop.tempdataaddress do begin
                                               //result var param
        a.address:= -stacksize{-tempsize};
        offset:= 0;
       end;
      end;
      inc(opoffset1);
      stacksize:= stacksize + vpointersize;
     end;
     if (sf_method in asub^.flags) and 
                not (dsf_noinstancecopy in aflags) then begin
          //param order is [returnvaluepointer],instancepo,{params}
      with insertitem(oc_pushduppo,destoffset,opoffset1)^ do begin
       if hasresult then begin
        par.voffset:= -2*vpointersize;
       end
       else begin
        par.voffset:= -vpointersize;
       end;
      end;
      inc(opoffset1);
     end;
    end;
    if not hasresult and 
            (aflags*[dsf_attach,dsf_objini,dsf_objfini] = []) then begin
     d.kind:= ck_subcall;
     if (dsf_indexedsetter in aflags) and 
                             (co_mlaruntime in o.compileoptions) then begin
      with insertitem(oc_swapstack,topoffset,-1)^.par.swapstack do begin
       offset:= -paramsize1;
       size:= lastparamsize1;
      end;
     end;
    end;
    if not (dsf_isinherited in aflags) and 
         (asub^.flags * [sf_virtual,sf_override,sf_interface] <> []) then begin
     if sf_interface in asub^.flags then begin
      if sf_functioncall in asub^.flags then begin
       po1:= insertitem(oc_callintffunc,topoffset,-1);
      end
      else begin
       po1:= insertitem(oc_callintf,topoffset,-1);
      end;
      po1^.par.callinfo.virt.virtoffset:= asub^.tableindex*sizeof(intfitemty) +
                                                        sizeof(intfdefheaderty);
     end
     else begin
      if sf_functioncall in asub^.flags then begin
       if sf_classmethod in asub^.flags then begin
        po1:= insertitem(oc_callvirtclassfunc,topoffset,-1);
       end
       else begin
        po1:= insertitem(oc_callvirtfunc,topoffset,-1);
       end;
      end
      else begin
       if sf_classmethod in asub^.flags then begin
        po1:= insertitem(oc_callvirtclass,topoffset,-1);
       end
       else begin
        po1:= insertitem(oc_callvirt,topoffset,-1);
       end;
      end;
      po1^.par.callinfo.virt.virtoffset:= asub^.tableindex*sizeof(opaddressty)+
                                                             virtualtableoffset;
     end;
     if co_llvm in o.compileoptions then begin
      po1^.par.callinfo.virt.virtoffset:=  
              info.s.unitinfo^.llvmlists.constlist.
                         adddataoffs(po1^.par.callinfo.virt.virtoffset).listid;
      po1^.par.callinfo.virt.typeid:= info.s.unitinfo^.llvmlists.typelist.
                                                            addsubvalue(asub);
     end;
     if sf_functioncall in asub^.flags then begin
      po1^.par.callinfo.virt.selfinstance:= -asub^.paramsize + vpointersize;
     end
     else begin
      po1^.par.callinfo.virt.selfinstance:= -asub^.paramsize;
     end;
     setimmint32(instancetype1^.infoclass.virttaboffset,
                                 po1^.par.callinfo.virt.virttaboffset);
                                    ;
     po1^.par.callinfo.linkcount:= -1;
    end
    else begin
     if (asub^.nestinglevel = 0) or 
                      (asub^.nestinglevel = sublevel) then begin
      if dsf_indirect in aflags then begin
       if sf_functioncall in asub^.flags then begin
        po1:= insertitem(oc_callfuncindi,topoffset,-1);
       end
       else begin
        po1:= insertitem(oc_callindi,topoffset,-1);
       end;
       if co_llvm in o.compileoptions then begin
        po1^.par.ssas1:= callssa;
        po1^.par.callinfo.indi.typeid:= 
                     info.s.unitinfo^.llvmlists.typelist.addsubvalue(asub);
       end
       else begin
        po1^.par.callinfo.indi.calladdr:= -asub^.paramsize -
                                               resultsize - targetpointersize;
        if sf_ofobject in asub^.flags then begin
         dec(po1^.par.callinfo.indi.calladdr,targetpointersize); 
                     //method pointer is [code,data]
        end;
       end;
      end
      else begin
       if sf_functioncall in asub^.flags then begin
        po1:= insertitem(oc_callfunc,topoffset,-1);
       end
       else begin
        po1:= insertitem(oc_call,topoffset,-1);
       end;
      end;
      po1^.par.callinfo.linkcount:= -1;
     end
     else begin
      i1:= sublevel-asub^.nestinglevel;
      i2:= i1;
      b1:= sf_hasnestedaccess in asub^.flags;
      if not b1 then begin
       i2:= 0;
      end;
      if sf_functioncall in asub^.flags then begin
       po1:= insertitem(oc_callfuncout,topoffset,-1,
                                       getssa(ocssa_nestedcallout,i2));
      end
      else begin
       po1:= insertitem(oc_callout,topoffset,-1,
                                       getssa(ocssa_nestedcallout,i2));
      end;
      po1^.par.callinfo.linkcount:= i1-2;      //for downto 0
      po7:= ele.parentelement;
      if b1 then begin
       include(psubdataty(@po7^.data)^.flags,sf_hasnestedaccess);
      end;
      for i1:= i1-1 downto 0 do begin
       po7:= ele.eleinfoabs(po7^.header.parent);
       include(psubdataty(@po7^.data)^.flags,sf_hasnestedref);
       if i1 <> 0 then begin
        if b1 then begin
         include(psubdataty(@po7^.data)^.flags,sf_hasnestedaccess);
        end;
        include(psubdataty(@po7^.data)^.flags,sf_hascallout);
       end;
      end;
     end;
     if (asub^.address = 0) and not(dsf_indirect in aflags) and
                   (not modularllvm or 
                    (s.unitinfo = datatoele(asub)^.header.defunit)) then begin 
                                             //unresolved header
      linkmark(asub^.calllinks,getsegaddress(seg_op,@po1^.par.callinfo.ad));
     end;
    end;
    with po1^ do begin
     par.callinfo.flags:= asub^.flags;
     if not hasresult then begin
      exclude(par.callinfo.flags,sf_constructor); //no class pointer on stack
     end;      
     if dsf_isinherited in aflags then begin
      exclude(par.callinfo.flags,sf_virtual);
     end;
     par.callinfo.params:= parallocstart;
    {$ifdef mse_checkinternalerror}
     if realparamco+totparamco-paramco <> asub^.paramcount then begin
      internalerror(ie_handler,'20160522A');
     end;
    {$endif}
     if isvararg then begin
      par.callinfo.paramcount:= asub^.paramcount - 1 + varargcount;
     end
     else begin
      par.callinfo.paramcount:= asub^.paramcount;
     end;
     par.callinfo.ad.ad:= asub^.address-1; //possibly invalid
     par.callinfo.ad.globid:= trackaccess(asub);
    end;
    if sf_functioncall in asub^.flags then begin
     d.dat.fact.ssaindex:= s.ssa.nextindex-1;
    end;
    if (sf_destructor in asub^.flags) and 
                     (aflags * [dsf_isinherited,dsf_nofreemem] = []) then begin
     if dsf_destroy in aflags then begin
      with insertitem(oc_push,topoffset,-1)^ do begin
       par.imm.vsize:= targetpointersize; //compensate missing instance copy
      end;
     end;
     dodispose(instancetype1);
    end;
    if dsf_indirect in aflags then begin
     if hasresult then begin
      with insertitem(oc_movestack,topoffset,-1)^ do begin
                                   //move result to calladdress
       par.swapstack.offset:= -targetpointersize;
       par.swapstack.size:= resultsize;
      end;
     end;
     with insertitem(oc_pop,topoffset,-1)^ do begin   
      setimmsize(targetpointersize,par.imm); //remove call address
     end;
    end;
    if co_mlaruntime in o.compileoptions then begin
//     releasetempaddress(tempsize);
     if hasvarresult then begin
      with insertitem(oc_pushtemp,topoffset,-1)^ do begin
       par.tempaddr.a.address:= varresulttemp.address;
       if asub^.resulttype.indirectlevel > 0 then begin
        par.tempaddr.bytesize:= targetpointersize;
       end
       else begin
        par.tempaddr.bytesize:= resulttype1^.h.bytesize;
       end;
      end;
     end
     else begin
      locdatapo:= locdatapo - resultsize;
     end;
    end
    else begin
    {
     if varresulttempaddr >= 0 then begin
      with insertitem(oc_pushtemp,topoffset,-1)^ do begin
       par.tempaddr.a.ssaindex:= varresulttemp.ssaindex;
       d.dat.fact.ssaindex:= par.ssad;
      end;
      d.dat.fact.varsubres.endopoffset:= 
                   contextstack[topoffset+s.stackindex].opmark.address +
                                  getcontextopcount(topoffset) - opmark.address;
     end;
    }
    end;
    if (sf_constructor in asub^.flags) and 
                            not (dsf_isinherited in aflags) then begin
     callclasssubattach(instancetype1,osa_afterconstruct);
     if isllvmgetmem then begin
      checkopcapacity(10); //max
      op1:= insertitem(oc_goto,topoffset,-1);
      landingpad1:= tryhandle(topoffset,-1); //landingpad
      tryblockend();
      if not callclasssubattach(instancetype1,osa_destroy) then begin
                                  //osa_destroy does dispose
       dodispose(instancetype1);
      end;
      with insertitem(oc_continueexception,topoffset,-1)^ do begin
       par.landingpad:= landingpad1;
      end;
      insertlabel(topoffset,-1);
      op1^.par.opaddress.opaddress:= getcontextopmark(topoffset+1).address-2;
                                                      //jump to label
     end;
    end;
   end;
  end;
  if (aflags*[dsf_objini,dsf_objfini] <> []) or isconstructor then begin
   if co_mlaruntime in o.compileoptions then begin
    with insertitem(oc_push,topoffset,-1)^ do begin
     par.imm.vsize:= targetpointersize;    //compensate stack pop
    end;
   end;
  end;
 end;
end;

procedure handlebeginexpected();
begin
{$ifdef mse_debugparser}
 outhandle('BEGINEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('begin');
  dec(s.stackindex);
 end;
end;

procedure handleendexpected();
begin
{$ifdef mse_debugparser}
 outhandle('ENDEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('end');
  dec(s.stackindex);
 end;
end;

procedure handleimplementationexpected();
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATIONEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('implementation');
  dec(s.stackindex);
 end;
end;

end.
