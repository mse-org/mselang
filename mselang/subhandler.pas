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
unit subhandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,stackops,parserglob,handlerglob,listutils,opglob;
 
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

procedure checkfunctiontype();
procedure handlesub1entry();
procedure handlevirtual();
procedure handleoverride();
procedure handleclasubheaderattach();
procedure handleoverload();
procedure handleexternal();
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
                              const pointerparam: boolean): popinfoty;
                                                        //ignores op address 0
procedure initsubstartinfo();
function startsimplesub(const aname: identty;
                        const pointerparam: boolean): opaddressty;
procedure endsimplesub(const pointerparam: boolean);
procedure setoperparamid(const dest: pidentty; const aindirectlevel: int32;
                                                     const atyp: ptypedataty);
                                                        //nil -> void

implementation
uses
 errorhandler,msetypes,handlerutils,elements,opcode,unithandler,
 managedtypes,segmentutils,classhandler,llvmlists,__mla__internaltypes,
 msestrings,typehandler,exceptionhandler,identutils,llvmbitcodes,parser,
 valuehandler,elementcache,grammarglob;

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
   aaddress:= startsimplesub(internalsubidents[asub],false);
   internalsubs[asub]:= aaddress;
  end;
 end;
end;

function callinternalsub(const asub: opaddressty;
                                  const pointerparam: boolean): popinfoty;
begin
 result:= additem(oc_call);
 with result^.par.callinfo do begin
  if asub <> 0 then begin
   ad.globid:= getoppo(asub)^.par.subbegin.globid;
   ad.ad:= asub-1; //compensate inc(pc)
  end;
  flags:= [];
  linkcount:= 0;
  if pointerparam then begin
   paramcount:= 1;
   params:= getsegmenttopoffs(seg_localloc);
   with pparallocinfoty(allocsegmentpo(seg_localloc,
                                        sizeof(parallocinfoty)))^ do begin
    ssaindex:= info.s.ssa.nextindex-1;
    size:= bitoptypes[das_pointer] //not used? 
   end;
  end
  else begin
   paramcount:= 0;
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
  [sf_function,sf_method,sf_constructor,sf_destructor]) = []) and 
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
    if sf_function in ref^.flags then begin
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
// start,stop: integer;
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
   if sf_function in ref^.flags then begin
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
  if (pa^.vf.typ <> pb^.vf.typ) or 
         ((pa^.address.flags >< pb^.address.flags) *
                                     compatibleparamflags <> []) then begin
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
 with info,contextstack[s.stackindex] do begin
  s.currentstatementflags:= b.flags;
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
  paramdef.defaultconst:= -1;
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
 outhandle('PARAMDEF3');
{$endif}
 with info,contextstack[s.stacktop] do begin
  d.kind:= ck_fieldtype;
  d.typ:= sysdatatypes[st_none];
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
//     if not checkcompatibledatatype(s.stacktop-s.stackindex,
//                                  paramtype^.typedata,ad1,[],i1) then begin
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
  s.stacktop:= getstackindex(poa); //remove const  
//  dec(s.stacktop); //remove const
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
 initsubdef([sf_classmethod,sf_function]);
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
 initsubdef([sf_function]);
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
 initsubdef([sf_typedef,sf_header,sf_function]);
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

(*
procedure handleclasubheaderentry();
begin
{$ifdef mse_debugparser}
 outhandle('CLASUBHEADERENTRY');
{$endif}
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_objsubheader;
 end;
end;
*)
procedure callsubheaderentry();
var
 po1: pcontextdataty;
begin
{$ifdef mse_debugparser}
 outhandle('CALLSUBHEADERENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  po1:= @contextstack[s.stackindex-1].d;
  kind:= ck_subdef;
  subdef.flags:= po1^.subdef.flags;
  po1^.kind:= ck_objsubheader;//ck_none;
 end;
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
  end
  else begin
   d.paramdef.kind:= pk_var;
  end;
  d.paramdef.defaultconst:= -1;
 end;
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_ident;
//  d.ident.paramkind:= pk_var;
  d.ident.ident:= tk_result;
  with contextstack[parent-1] do begin
  {$ifdef mselang}
   if sf_functiontype in d.subdef.flags then begin
    errormessage(err_syntax,[';']);
    dec(s.stackindex,2); //remove result type
    s.stacktop:= s.stackindex;
   end;
   include(d.subdef.flags,sf_functiontype);
  {$else} //msepas
   if (d.subdef.flags * [sf_function,sf_methodtoken,sf_subtoken] = []) or 
                           (sf_functiontype in d.subdef.flags) then begin
    errormessage(err_syntax,[';']);
   end;
   d.subdef.flags:= d.subdef.flags+[sf_functiontype,sf_function];
  {$endif}
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
   if not ele.findupward(contextstack[s.stackindex+1].d.ident.ident,[],
             implementationvisi,ele1) then begin
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
       tk_afterconstruct: begin
        include(d.subdef.flags,sf_afterconstruct);
       end;
       tk_beforedestruct: begin
        include(d.subdef.flags,sf_beforedestruct);
       end;
       tk_ini: begin
        include(d.subdef.flags,sf_ini);
       end;
       tk_fini: begin
        include(d.subdef.flags,sf_fini);
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
  lastllvmtemp:= -1;
  managedtempcount:= 0;
  managedtempchain:= 0;
  managedtempref:= 0;
  managedtemparrayid:= 0;
 end;
end;

function startsimplesub(const aname: identty;
                             const pointerparam: boolean): opaddressty;
var
 m1: metavaluety;
 var1: vardataty;
begin
 with info do begin
  if do_proginfo in s.debugoptions then begin
   if pointerparam then begin
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
  managedtemparrayid:= locallocid;  
 {
  managedtempref:= 0;
  managedtemparrayid:= locallocid;  
  managedtempchain:= 0;
  managedtempcount:= 0;
 }
  managedtemparrayid:= locallocid;  
  resetssa();
  result:= opcount;
  simplesubstart:= opcount;
  with additem(oc_subbegin)^.par do begin
   subbegin.subname:= result;
   
   if co_llvm in o.compileoptions then begin
    with s.unitinfo^ do begin
     if pointerparam then begin
      subbegin.globid:= llvmlists.globlist.addinternalsubvalue([],params1po);
     end
     else begin
      subbegin.globid:= llvmlists.globlist.addinternalsubvalue([],noparams);
     end;
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
   if pointerparam then begin
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
 end;
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

procedure endsimplesub(const pointerparam: boolean);
var
 managedtempsize1: int32;
begin
 with info do begin
  writemanagedtempop(mo_decref,managedtempchain,s.stacktop);
  deletelistchain(managedtemplist,managedtempchain);
  managedtempsize1:= managedtempcount*pointersize; 
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
    par.subbegin.sub.allocs.llvm.blockcount:= s.ssa.bbindex + 1;
   end
   else begin
    par.subbegin.sub.allocs.stackop.managedtempsize:= managedtempsize1;
    par.subbegin.sub.allocs.stackop.varsize:= managedtempsize1;
   end;
  end;
  if managedtempsize1 <> 0 then begin
   with additem(oc_locvarpop)^ do begin
    par.stacksize:= managedtempsize1;
   end;
  end;
 end;
 with additem(oc_return)^ do begin
  if pointerparam then begin
   par.stacksize:= pointersize + sizeof(frameinfoty);
  end
  else begin
   par.stacksize:= 0 + sizeof(frameinfoty);
  end;
 end;
 with additem(oc_subend)^ do begin
  par.subend.submeta:= info.s.currentscopemeta;
  par.subend.allocs.alloccount:= 0;
  par.subend.allocs.nestedalloccount:= 0;
 end;
 with info do begin
  deletelistchain(trystacklist,s.trystack); //normally already empty
  s.trystacklevel:= 0;
 end;
 if do_proginfo in info.s.debugoptions then begin
  popcurrentscope();
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

procedure setoperparamid(const dest: pidentty; const aindirectlevel: int32;
                                                     const atyp: ptypedataty);
begin
 dest^:= getident(aindirectlevel);
 if atyp = nil then begin
  (dest+1)^:= tks_void;
 end
 else begin
  (dest+1)^:= basetype1(atyp)^.h.signature;
 end;
end;

procedure setoperparamid(var dest: pidentty; const avar: pvardataty);
begin
 if af_paramindirect in avar^.address.flags then begin
  dest^:= getident(avar^.address.indirectlevel-1);
 end
 else begin
  dest^:= getident(avar^.address.indirectlevel);
 end;
 inc(dest);
 dest^:= ptypedataty(ele.eledataabs(basetype(avar^.vf.typ)))^.h.signature;
 inc(dest);
end;

procedure handlesubheader();
var                       //todo: move after doparam
 sub1: psubdataty;
 var1: pvardataty;
 typ1: ptypedataty;
// po4: pelementoffsetaty;
 curparam,curparamend,paramend: pelementoffsetty;
// {int1,}int2{,int3}: integer;
// lastparamindex: int32;
 curstackindex: int32;
// curparamindex: int32;
 paramco{,paramhigh}: integer;
 err1: boolean;
 impl1: boolean;
 parent1: elementoffsetty;
 paramdata: equalparaminfoty;
 par1,parref: pelementoffsetaty;
 eledatabase: ptruint;
 subflags: subflagsty;
// parambase: ptruint;
 si1: integer;
 paramsize1: integer;
 defaultparamcount1: int32;
 bo1,isclass,isinterface,ismethod: boolean;
 ele1: elementoffsetty;
 ident1: identty;
 resulttype1: resulttypety;

 function doparams(const resultvar: boolean): boolean;
 var
  i1,i2: int32;
  paramkind1: paramkindty;
  defaultconst1: elementoffsetty;
 begin
  result:= true;
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
      if (isclass and
          ele.findchild(currentcontainer,d.ident.ident,[],allvisi,ele1)) or not
              addvar(d.ident.ident,allvisi,sub1^.varchain,var1) then begin
       identerror(curstackindex-s.stackindex,err_duplicateidentifier);
       err1:= true;
      end;
      if s.stopparser then begin
       exit; //recursive ancestor
      end;
      curparam^:= elementoffsetty(var1); 
                    //absoluteaddress, will be qualified later
      with contextstack[i1] do begin //ck_fieldtype
       if d.kind = ck_fieldtype then begin
        if sf_vararg in sub1^.flags then begin
         errormessage(err_varargmustbelast,[]);
        end;
        typ1:= ele.eledataabs(d.typ.typedata);
        if (typ1^.h.kind = dk_openarray) and 
           (tf_untyped in ptypedataty(ele.eledataabs(
                       typ1^.infodynarray.i.itemtypedata))^.h.flags) then begin
         if not (sf_external in sub1^.flags) then begin //todo: check "cdecl"
          notimplementederror('20170521B');
         end
         else begin
          include(sub1^.flags,sf_vararg);
         end;
        end;
        with var1^ do begin
         vf.defaultconst:= defaultconst1;
         if defaultconst1 >= 0 then begin
          inc(defaultparamcount1);
         end;
         address.indirectlevel:= d.typ.indirectlevel;
         if (address.indirectlevel > 0) then begin
          si1:= pointersize;
         end
         else begin
          si1:= typ1^.h.bytesize;
         end;
         address.flags:= [af_param];
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
          if (si1 > pointersize) or (tf_sizeinvalid in typ1^.h.flags) then begin
                                      //size not known yet
           inc(address.indirectlevel);
           include(address.flags,af_paramindirect);
           si1:= pointersize;
          end;
          include(address.flags,af_const);
         end
         else begin
          if paramkind1 in [pk_constref,pk_var,pk_out] then begin
           inc(address.indirectlevel);
           include(address.flags,af_paramindirect);
           si1:= pointersize;
           if paramkind1 = pk_constref then begin
            include(address.flags,af_const);
           end;
           if resultvar and impl1 and (d.typ.indirectlevel = 0) and 
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
             if tf_needsmanage in typ1^.h.flags then begin
              include(vf.flags,tf_needsmanage);
             end;
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
            si1:= pointersize;
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
                            (tf_sizeinvalid in typ1^.h.flags)  then begin
        with pselfobjparamitemty(
             addlistitem(selfobjparams,selfobjparamchain))^ do begin
         methodelement:= ele.eledatarel(sub1);
         paramindex:= curparam-pelementoffsetty(@sub1^.paramsrel);
         paramsize:= alignsize(si1);
        end;
       end;
       inc(paramsize1,alignsize(si1));
       inc(curparam);
      end;
     end;
    end;
    curstackindex:= i1+1; //next ck_paramsdef
   end;
  end; //lastparamindex
 end; //doparams

var
 lstr1: lstringty;  
 i1: int32;
 element1: pelementinfoty;
 poind: pcontextitemty;
 poper1: poperatordataty;
 poperid: pidentty;
 operparamids: identvecty;
 p1: pidentty;
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
   d.subdef.parambase:= locdatapo;
   d.subdef.locallocidbefore:= locallocid;
   locallocid:= 0;
  end;
  if (sf_function in subflags) and 
                      not (sf_functiontype in subflags) then begin
   tokenexpectederror(':');
   exit; //fatal
  end;
  paramsize1:= 0;
  resulttype1.typeele:= 0;
  resulttype1.indirectlevel:= 0;
  defaultparamcount1:= 0;
  isclass:= s.currentstatementflags * [stf_objdef,stf_objimp] <> [];
  isinterface:=  stf_interfacedef in s.currentstatementflags;
  ismethod:= isclass or isinterface or (sf_ofobject in subflags);
  if sf_function in subflags then begin
   with contextstack[s.stacktop].d.typ do begin
    resulttype1.typeele:= typedata;
    resulttype1.indirectlevel:= indirectlevel;
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
  if (paramco = 0) and (sf_function in subflags) then begin
   paramco:= 1;  //no getidents context
  end;
//  paramco:= (s.stacktop-s.stackindex-2) div 3;
//  paramhigh:= paramco-1;
  if ismethod then begin
   inc(paramco); //self pointer
  end;
  i1:= paramco* (sizeof(pvardataty)+elesizes[ek_var]) + elesizes[ek_alias] +
                 elesizes[ek_sub] + elesizes[ek_none] + elesizes[ek_type];
  ele.checkcapacity(i1); //ensure that absolute addresses can be used
  eledatabase:= ele.eledataoffset();
  ident1:= contextstack[s.stackindex+1].d.ident.ident;
  if ele.findcurrent(ident1,[],allvisi,ele1) and 
                   (ele.eleinfoabs(ele1)^.header.kind <> ek_sub) then begin
   identerror(1,err_overloadnotfunc);
   ele1:= -1;
  end;
  sub1:= addr(ele.pushelementduplicate(ident1,ek_sub,allvisi,
                                     paramco*sizeof(pvardataty))^.data);
  sub1^.next:= currentsubchain;
  currentsubchain:= ele.eledatarel(sub1);
  if (ele1 >= 0) and (sf_method in subflags) then begin
   element1:= ele.eleinfoabs(ele1);
   if element1^.header.parent <> ele.elementparent then begin
    ele1:= -1;    //todo: use correct class overload handling
   end;
  end;
  sub1^.nextoverload:= ele1;

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
  if isclass and (sf_constructor in subflags) then begin
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
  sub1^.linkage:= s.globlinkage;
  inc(s.unitinfo^.nameid);
  sub1^.nameid:= s.unitinfo^.nameid;
  sub1^.resulttype:= resulttype1;
  sub1^.varchain:= 0;
  sub1^.paramfinichain:= 0;
  sub1^.allocs.nestedalloccount:= 0;
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
  if sf_function in subflags then begin  //allocate result var first
   curstackindex:= s.stacktop-2;  //-> paramsdef     
   curparamend:= curparam + 1;
   if not doparams(true) or s.stopparser then begin //increments curparam
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
    inc(paramsize1,pointersize);
    address.indirectlevel:= 1;
    if impl1 then begin
     address.locaddress:= getlocvaraddress(das_pointer,pointersize,
                                                              address.flags);
    end;
    address.locaddress.framelevel:= sublevel+1;
    address.flags:= [af_param];
    include(address.flags,af_const);
    vf.typ:= currentcontainer;
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
      var1^.vf.next:= sub1^.paramfinichain;
      sub1^.paramfinichain:= ele.eledatarel(var1);
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
      sub1^.globid:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(sub1,
       getidentname2(pelementinfoty(pointer(sub1)-eledatashift)^.header.name));
     end;
     addsubbegin(oc_externalsub,sub1);
    end
    else begin
     if sf_typedef in subflags then begin
      ele.decelementparent();
      setsubtype(-2,ele.eledatarel(sub1));
      dec(info.s.stackindex);
      exit;
     end
     else begin
      forwardmark(sub1^.mark,s.source);
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
     if isclass then begin
      currentclass:= currentcontainer;
      ele.pushelementparent(currentcontainer);
      bo1:= ele.forallcurrent((poind+1)^.d.ident.ident,[ek_sub],
                                  allvisi,@checkequalparam,paramdata);
      ele.popelementparent();
      if not bo1 then begin
       errormessage(err_methodexpected,[],1);
      end
      else begin
       if sf_classmethod in (paramdata.match^.flags >< sub1^.flags) then begin
        bo1:= false;
        if sf_classmethod in sub1^.flags then begin
         errormessage(err_methodexpected,[],1);
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
       if sf_external in flags then begin
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
   if sf_afterconstruct in subflags then begin
    if not isclass or (subflags*[sf_function,sf_classmethod] <> []) or
                                                    (paramco <> 1) then begin
     errormessage(err_invalidmethodforattach,['afterconstruct']);
    end
    else begin
     with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
      infoclass.subattach.afterconstruct:= ele.eledatarel(sub1);
     end;
    end;
   end;
   if sf_beforedestruct in subflags then begin
    if not isclass or (subflags*[sf_function,sf_classmethod] <> []) or 
                                                    (paramco <> 1) then begin
     errormessage(err_invalidmethodforattach,['beforedestruct']);
    end
    else begin
     with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
      infoclass.subattach.beforedestruct:= ele.eledatarel(sub1);
     end;
    end;
   end;
   if sf_ini in subflags then begin
    if not isclass or (subflags*[sf_function,sf_classmethod] <> []) or 
                                                    (paramco <> 1) then begin
     errormessage(err_invalidmethodforattach,['ini']);
    end
    else begin
     with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
      infoclass.subattach.ini:= ele.eledatarel(sub1);
      include(h.flags,tf_needsini);
     end;
    end;
   end;
   if sf_fini in subflags then begin
    if not isclass or (subflags*[sf_function,sf_classmethod] <> []) or 
                                                    (paramco <> 1) then begin
     errormessage(err_invalidmethodforattach,['fini']);
    end
    else begin
     with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
      infoclass.subattach.fini:= ele.eledatarel(sub1);
      include(h.flags,tf_needsfini);
     end;
    end;
   end;
   if subflags * [sf_operator,sf_operatorright] <> [] then begin
    if sub1^.paramcount*2 >= high(operparamids.d)-1 then begin
     errormessage(err_toomanyoperparams,[]);
    end
    else begin
     p1:= @operparamids.d[1];
     if sf_function in subflags then begin
      setoperparamid(p1,ele.eledataabs(pelementoffsetty(@sub1^.paramsrel)[0]));
      i1:= 2;
     end
     else begin
      p1^:= getident(0);
      inc(p1);
      p1^:= tks_void;
      inc(p1);
      i1:= 1;
     end;
     for i1:= i1 to sub1^.paramcount-1 do begin
      setoperparamid(p1,ele.eledataabs(pelementoffsetty(@sub1^.paramsrel)[i1]));
     end;
     operparamids.high:= (p1-pidentty(@operparamids.d[0]))-1;
     if sf_operator in subflags then begin
      operparamids.d[0]:= currentoperator;
      if not ele.findcurrent(tks_operators,[],allvisi,ele1) then begin
       ele1:= ele.addelementduplicate1(tks_operators,ek_none,allvisi);
      end;
      if ele.adduniquechilddata(ele1,operparamids,
                                          ek_operator,allvisi,poper1) then begin
       poper1^.methodele:= ele.eledatarel(sub1);
      end
      else begin
       errormessage(err_operatoralreadydefined,[getidentname(currentoperator)]);
      end;
     end;
     if sf_operatorright in subflags then begin
      operparamids.d[0]:= currentoperatorright;
      if not ele.findcurrent(tks_operatorsright,[],allvisi,ele1) then begin
       ele1:= ele.addelementduplicate1(tks_operatorsright,ek_none,allvisi);
      end;
      if ele.adduniquechilddata(ele1,operparamids,
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
(*
procedure subbody4entry();
var
 po1: pelementinfoty;
{$ifdef mse_checkinternalerror}
 bo1: boolean;
{$endif}
begin
{$ifdef mse_debugparser}
 outhandle('SUBBODY4ENTRY');
{$endif}
*)
(*
 with info do begin
  if s.debugoptions * [do_proginfo,do_name] <> [] then begin
   with contextstack[s.stackindex-2] do begin
   {$ifdef mse_checkinternalerror}
    if (s.stackindex < 2) or (d.kind <> ck_subdef) then begin
     internalerror(ie_parser,'20151023A');
    end;
   {$endif}
    po1:= ele.eleinfoabs(d.subdef.ref);
    with s.unitinfo^ do begin
     if do_proginfo in s.debugoptions then begin
      pushcurrentscope(llvmlists.metadatalist.adddisubprogram(
           {s.}currentscopemeta,getidentname2(po1^.header.name),
           s.currentfilemeta,
           info.contextstack[info.s.stackindex].start.line,-1,
           dummymeta,[flagprototyped],us_implementation in s.unitinfo^.state));
     end;
    end;
   end;
  end;
 end;
*)
//end;

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
 outhandle('SUB5A');
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
    po1^.globid:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(po2); 
          //body order must be in header order-> nested subs first -> 
                                       //do not add to list in sub header
   end;
   if (po2^.flags * [sf_virtual,sf_override] <> []) and 
                    (sf_intfcall in po2^.flags) then begin
    po2^.trampolineaddress:= opcount;
    linkresolveopad(po2^.trampolinelinks,po2^.trampolineaddress);
    with additem(oc_virttrampoline)^ do begin
     if sf_function in po2^.flags then begin
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
   po1^.flags:= po2^.flags;
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
     popaddressty(@classdefinfoty(getsegmentpo(infoclass.defs)^).
                      virtualmethods)[po2^.tableindex]:= ad1;
              //resolve virtual table entry
    end;
   end;
   linkresolvecall(po2^.calllinks,po1^.address,po1^.globid);
   linkresolveopad(po2^.adlinks,po1^.address);
  end
  else begin //no header
   if co_llvm in o.compileoptions then begin
    po1^.globid:= info.s.unitinfo^.llvmlists.globlist.addsubvalue(po1);
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
        debuginfo:= adddivariable(getidentnamel(id1),lnr1,int1,po4^,
                                                             addtype(po4^));
       end
       else begin
        debuginfo:= adddivariable(getidentnamel(id1),lnr1,int1,po4^);
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
   writemanagedvarop(mo_ini,po1^.varchain,s.stacktop);
  end;           //todo: implicit try-finally
  if po1^.paramfinichain <> 0 then begin
   writemanagedvarop(mo_incref,po1^.paramfinichain,s.stacktop);
  end;          
 end;
end;

procedure handlesubbody6();
var
 po1: psubdataty;
 po2: popinfoty;
 m1,m2: metavaluety;
 i1: int32;
 managedtempsize1,varsize1: int32;
begin
{$ifdef mse_debugparser}
 outhandle('SUB6');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
   //todo: check local forward
  po1:= ele.eledataabs(d.subdef.ref); //todo: implicit try-finally
  if co_llvm in o.compileoptions then begin
//   if sf_hasnestedaccess in po1^.flags then begin
//   if po1^.flags * [sf_hasnestedref,hasnestedaccess] <> [] then begin
    info.s.unitinfo^.llvmlists.globlist.updatesubtype(po1);
//   end;
  end;
  addlabel();
  linkresolveopad(po1^.exitlinks,opcount-1);
  if s.currentstatementflags * [stf_needsmanage,stf_needsfini] <> [] then begin
   writemanagedvarop(mo_fini,po1^.varchain,s.stacktop);
  end;
  if po1^.paramfinichain <> 0 then begin
   writemanagedvarop(mo_fini,po1^.paramfinichain,s.stacktop);
  end;
  writemanagedtempop(mo_decref,managedtempchain,s.stacktop);
  deletelistchain(managedtemplist,managedtempchain);
  managedtempsize1:= managedtempcount*pointersize; 
  varsize1:= managedtempsize1+d.subdef.varsize;
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
  if sf_function in po1^.flags then begin
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
  locdatapo:= d.subdef.parambase;
  frameoffset:= d.subdef.frameoffsetbefore;
  dec(sublevel);
  if sublevel = 0 then begin
   checkpendingmanagehandlers(); //needs local definitions
   ele.releaseelement(b.elemark); //remove local definitions
  end;
  ele.elementparent:= b.eleparent;
  s.currentstatementflags:= b.flags;
  addsubend(po1);
  locallocid:= d.subdef.locallocidbefore;
  po2:= getoppo(po1^.address);
 {
  if po2^.op.op = oc_initclass then begin
   inc(po2);
  end;
 }
  with po2^ do begin
   if co_llvm in o.compileoptions then begin
    par.subbegin.sub.allocs.llvm.tempcount:= llvmtempcount;
    par.subbegin.sub.allocs.llvm.firsttemp:= firstllvmtemp;
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
    par.subbegin.sub.allocs.llvm.blockcount:= s.ssa.bbindex + 1;
   end
   else begin
    par.subbegin.sub.allocs.stackop.managedtempsize:= managedtempsize1;
    par.subbegin.sub.allocs.stackop.varsize:= varsize1;
   end;
   par.subbegin.sub.flags:= po1^.flags;
  end;
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
   currentcontainer := 0;
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
