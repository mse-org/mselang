{ MSElang Copyright (c) 2013-2014 by Martin Schreiber
   
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
 stackops,parserglob,handlerglob;
 
const
 stacklinksize = sizeof(frameinfoty);

procedure handleparamsdef0entry();
procedure handleparams0entry();
procedure setconstparam();
procedure setvarparam();
procedure setoutparam();
procedure handleparamdef2();
procedure handleparamsend();
//procedure handlesubheader();

procedure handlefunctionentry();
procedure handleprocedureentry();

procedure checkfunctiontype();
procedure handlesub1entry();
procedure handlevirtual();
procedure handleoverride();
procedure handleoverload();
procedure handlesubheader();
//procedure handlesub4entry();
procedure handlesubbody5a();
procedure handlesubbody6();

procedure handlebeginexpected();
procedure handleendexpected();
procedure handleimplementationexpected();

function checkparams(const po1,ref: psubdataty): boolean; 
function getinternalsub(const asub: internalsubty;
                         out aaddress: opaddressty): boolean; //true if new
procedure endinternalsub();
procedure callinternalsub(const asub: opaddressty); //ignores op address 0

implementation
uses
 errorhandler,msetypes,handlerutils,elements,grammar,opcode,unithandler,
 managedtypes,segmentutils,classhandler,opglob;

type
 equalparaminfoty = record
  ref: psubdataty;
  match: psubdataty;
 end;

function getinternalsub(const asub: internalsubty;
                                   out aaddress: opaddressty): boolean;
begin
 with info.s.unitinfo^ do begin
  aaddress:=  internalsubs[asub];
  result:= aaddress = 0;
  if result then begin
   aaddress:= info.opcount;
   internalsubs[asub]:= aaddress;
   resetssa();
   with additem(oc_subbegin)^.par.subbegin do begin
    subname:= aaddress;
    flags:= [];
    allocs.alloccount:= 0;
    allocs.nestedalloccount:= 0;
   end;
  end;
 end;
end;

procedure endinternalsub();
begin
 with additem(oc_return)^ do begin
  par.stacksize:= 0;
 end;
 with additem(oc_subend)^ do begin
  par.subend.allocs.alloccount:= 0;
  par.subend.allocs.nestedalloccount:= 0;
 end;
end;

procedure callinternalsub(const asub: opaddressty);
begin
 with additem(oc_call)^.par.callinfo do begin
  ad:= asub-1;
  flags:= [];
  linkcount:= 0;
  paramcount:= 0;
 end;
end;

function checkparams(const po1,ref: psubdataty): boolean; 
//                                  {$ifndef mse_debugparser} inline;{$endif}
var
 par1,parref: pelementoffsetaty;
 offs1: elementoffsetty;
 var1,varref: pvardataty;
 int1: integer;
 start,stop: integer;
begin
 result:= true;
 offs1:= ele.eledataoffset;
 pointer(par1):= @po1^.paramsrel;
 pointer(parref):= @ref^.paramsrel;
 start:= 0;
 stop:= ref^.paramcount-1;
 if sf_method in ref^.flags then begin
  start:= 1; //skip self param
  if sf_constructor in ref^.flags then begin
   dec(stop); //skip result param
  end;
 end;
 for int1:= start to stop do begin
  var1:= pointer(par1^[int1]+offs1);
  varref:= pointer(parref^[int1]+offs1);
  if var1^.vf.typ <> varref^.vf.typ then begin
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
  if (po1 <> ref) and ((po1^.flags >< ref^.flags)*[sf_header] = []) and
                    (po1^.paramcount = ref^.paramcount) and
                    (po1^.paramsize = ref^.paramsize) and 
                    ((sf_method in po1^.flags) = (sf_method in ref^.flags)) and
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

procedure handleparamsdef0entry();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSDEF0ENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_paramsdef;
  paramsdef.kind:= pk_value;
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
 with info,contextstack[s.stackindex].d.paramsdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_const;
 end;
end;

procedure setvarparam();
begin
{$ifdef mse_debugparser}
 outhandle('VARPARAM');
{$endif}
// with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
 with info,contextstack[s.stackindex].d.paramsdef do begin
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
 with info,contextstack[s.stackindex].d.paramsdef do begin
  if kind <> pk_value then begin
   errormessage(err_identexpected,[],minint,0,erl_fatal);
  end;
  kind:= pk_out;
 end;
end;

procedure handleparamdef2();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMDEF2');
{$endif}
 with info do begin
  if s.stacktop-s.stackindex <> 2 then begin
   errormessage(err_typeidentexpected,[]);
  end;
 end;
end;

procedure handleparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
 with info do begin
  with contextstack[s.stackindex] do begin
   s.currentstatementflags:= b.flags;
  end;
 end;
end;

procedure handleprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDUREENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [];
 end;
end;

procedure handlefunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONENTRY');
{$endif}
 with info,contextstack[s.stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_function];
 end;
end;

procedure checkfunctiontype();
begin
{$ifdef mse_debugparser}
 outhandle('CHECKFUNCTIONTYPE');
{$endif}
 with info,contextstack[s.stackindex-1] do begin
  d.kind:= ck_paramsdef;
  if backendhasfunction then begin
   d.paramsdef.kind:= pk_value;
  end
  else begin
   d.paramsdef.kind:= pk_var;
  end;
 end;
 with info,contextstack[s.stackindex] do begin
  d.kind:= ck_ident;
//  d.ident.paramkind:= pk_var;
  d.ident.ident:= tk_result;
  with contextstack[parent-1] do begin
   if sf_functiontype in d.subdef.flags then begin
    errormessage(err_syntax,[';']);
   end;
   include(d.subdef.flags,sf_functiontype);
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
  exclude(s.currentstatementflags,stf_hasmanaged);
  int1:= s.stacktop-s.stackindex; 
  if int1 > 1 then begin //todo: check procedure level and the like
   if not ele.findupward(contextstack[s.stackindex+1].d.ident.ident,[],
             implementationvisi,ele1) then begin
    identerror(1,err_identifiernotfound,erl_fatal);
   end
   else begin
    po1:= ele.eleinfoabs(ele1);
    if (po1^.header.kind <> ek_type) or 
               (ptypedataty(@po1^.data)^.kind <> dk_class) then begin
     errormessage(err_classidentexpected,[],1);
    end
    else begin
     if int1 > 2 then begin
      errormessage(err_syntax,[';'],2);
     end
     else begin     //class sub
      include(s.currentstatementflags,stf_classimp);
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
   exclude(s.currentstatementflags,stf_classimp);
  end;
 end;
end;

function checkclassdef(): boolean;
begin
 result:= true;
 with info,contextstack[s.stackindex-1] do begin
  if not (stf_classdef in s.currentstatementflags) then begin
   result:= false;
   if stf_implementation in s.currentstatementflags then begin
    handlebeginexpected();
   end
   else begin
    handleimplementationexpected();
   end
  end
 end;
end;

procedure handlevirtual();
begin
{$ifdef mse_debugparser}
 outhandle('VIRTUAL');
{$endif}
 if checkclassdef() then begin
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
 if checkclassdef() then begin
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

procedure handleoverload();
begin
{$ifdef mse_debugparser}
 outhandle('OVERLOAD');
{$endif}
end;

procedure handlesubheader();
var
 po1: psubdataty;
 po2: pvardataty;
 po3: ptypedataty;
 po4: pelementoffsetaty;
 int1,int2,int3: integer;
 paramco,paramhigh: integer;
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
 paramkind1: paramkindty;
 bo1,isclass,isinterface,ismethod: boolean;
 ele1: elementoffsetty;
 ident1: identty;
 resultele1: elementoffsetty;

 procedure doparam();
 begin
  with info do begin
   paramkind1:= contextstack[int1+s.stackindex-1].d.paramsdef.kind;
   with contextstack[int1+s.stackindex] do begin
    if (isclass and
        ele.findchild(currentcontainer,d.ident.ident,[],allvisi,ele1)) or not
            addvar(d.ident.ident,allvisi,po1^.varchain,po2) then begin
     identerror(int1,err_duplicateidentifier);
     err1:= true;
    end;
    po4^[int2]:= elementoffsetty(po2); //absoluteaddress
    with contextstack[int1+s.stackindex+1] do begin
     if d.kind = ck_fieldtype then begin
      po3:= ele.eledataabs(d.typ.typedata);
      with po2^ do begin
       address.indirectlevel:= d.typ.indirectlevel;
       if address.indirectlevel > 0 then begin
        si1:= pointersize;
       end
       else begin
        si1:= po3^.bytesize;
       end;
       if impl1 then begin
        address.locaddress:= getlocvaraddress(si1,address.flags);
       end;
       address.locaddress.framelevel:= sublevel+1;
       address.flags:= [af_param];
       if paramkind1 = pk_const then begin
        if si1 > pointersize then begin
         inc(address.indirectlevel);
         include(address.flags,af_paramindirect);
         si1:= pointersize;
        end;
        include(address.flags,af_const);
       end
       else begin
        if paramkind1 in [pk_var,pk_out] then begin
         inc(address.indirectlevel);
         include(address.flags,af_paramindirect);
         si1:= pointersize;
        end
        else begin
         if impl1 and (d.typ.indirectlevel = 0) and 
                   (tf_hasmanaged in po3^.flags) then begin
          include(vf.flags,tf_hasmanaged);
         end;                     
        end;
       end;
       vf.typ:= d.typ.typedata;
      end;
     end
     else begin
      err1:= true;
     end;
     inc(paramsize1,si1);
    end;
   end;
   int1:= int1+3;
  end;
 end; //doparam
 
begin
{$ifdef mse_debugparser}
 outhandle('SUBHEADER');
{$endif}
//|-2        |-1  0     1     2           3           4        5    
//|classdef0,|sub,sub2,ident,paramsdef3{,ck_paramsdef,ck_ident,ck_type}
// interfacedef0
//  6           7             8    result
//[ck_paramsdef,ck_ident,ck_type] 
              //todo: multi level type
 with info do begin
//  subflags:= contextstack[stackindex-1].d.subdef.flags;
  with contextstack[s.stackindex-1] do begin
   subflags:= d.subdef.flags;
   d.subdef.parambase:= locdatapo;
   d.subdef.locallocidbefore:= locallocid;
   locallocid:= 0;
  end;
  if (sf_function in subflags) and 
                      not (sf_functiontype in subflags) then begin
   tokenexpectederror(':');
  end;
  paramsize1:= 0;
  resultele1:= 0;
  isclass:= s.currentstatementflags * [stf_classdef,stf_classimp] <> [];
  isinterface:=  stf_interfacedef in s.currentstatementflags;
  ismethod:= isclass or isinterface;
  if sf_function in subflags then begin
   resultele1:= contextstack[s.stacktop].d.typ.typedata;
  end;

  if isclass and (sf_constructor in subflags) then begin //add return type
   inc(s.stacktop);
   with contextstack[s.stacktop] do begin
    d.kind:= ck_paramsdef;
    d.paramsdef.kind:= pk_var;
   end;
   inc(s.stacktop);
   with contextstack[s.stacktop] do begin
    d.kind:= ck_ident;
    d.ident.ident:= tk_result;
   end;
   inc(s.stacktop);
   with contextstack[s.stacktop] do begin
    d.kind:= ck_fieldtype;
    d.typ.typedata:= currentcontainer;
    resultele1:= currentcontainer;
    d.typ.indirectlevel:= 1;
   end;
  end;
  paramco:= (s.stacktop-s.stackindex-2) div 3;
  paramhigh:= paramco-1;
  if ismethod then begin
   inc(paramco); //self pointer
  end;
  int2:= paramco*(sizeof(pvardataty)+elesizes[ek_var]) + elesizes[ek_sub];
  ele.checkcapacity(int2); //absolute addresses can be used
  eledatabase:= ele.eledataoffset();
  ident1:= contextstack[s.stackindex+1].d.ident.ident;
  if ele.findcurrent(ident1,[],allvisi,ele1) and 
       (ele.eleinfoabs(ele1)^.header.kind <> ek_sub) then begin
   identerror(1,err_overloadnotfunc);
  end;
  po1:= addr(ele.pushelementduplicate(ident1,ek_sub,allvisi,
                                      paramco*sizeof(pvardataty))^.data);
  po1^.next:= currentsubchain;
  currentsubchain:= ele.eledatarel(po1);
  if isinterface then begin
   include(subflags,sf_interface);
   po1^.tableindex:= currentsubcount;
  end
  else begin
   po1^.tableindex:= -1; //none
  end;
  inc(currentsubcount);
  po1^.paramcount:= paramco;
  po1^.links:= 0;
  po1^.trampolinelinks:= 0;   //for virtual interface items
  po1^.trampolineaddress:= 0;
  po1^.nestinglevel:= sublevel;
  po1^.flags:= subflags;
  po1^.resulttype:= resultele1;
  po1^.varchain:= 0;
  po1^.paramfinichain:= 0;
  if (stf_classdef in s.currentstatementflags) and 
                        (subflags*[sf_virtual,sf_override]<>[]) then begin
   with contextstack[s.stackindex-2] do begin
    po1^.tableindex:= d.cla.virtualindex;
    inc(d.cla.virtualindex);
   end;
  end;
  po4:= @po1^.paramsrel;
  err1:= false;
  impl1:= (us_implementation in s.unitinfo^.state) and 
                                                 not (sf_header in subflags);
  if ismethod then begin
  {$ifdef mse_checkinternalerror}
   if not addvar(tks_self,allvisi,po1^.varchain,po2) then begin
    internalerror(ie_sub,'20140415A');
   end;
  {$else}
    addvar(tks_self,allvisi,po1^.varchain,po2);
  {$endif}
   po4^[0]:= elementoffsetty(po2); //absoluteaddress
   inc(po4);          //todo: class proc
   with po2^ do begin //self variable
    inc(paramsize1,pointersize);
    address.indirectlevel:= 1;
    if impl1 then begin
     address.locaddress:= getlocvaraddress(pointersize,address.flags);
    end;
    address.locaddress.framelevel:= sublevel+1;
    address.flags:= [af_param];
    include(address.flags,af_const);
    vf.typ:= currentcontainer;
   end;
  end;
  int3:= paramhigh;
  if (sf_function in subflags) and backendhasfunction then begin
   int1:= 4 + paramhigh * 3;          //result
   int2:= paramhigh;
   doparam();
   int3:= paramhigh - 1;
  end;
  int1:= 4;
  for int2:= 0 to int3 do begin
   doparam();
  end;
  if ismethod then begin
   dec(po4);
  end;
  inc(paramsize1,stacklinksize);
  po1^.paramsize:= paramsize1;
  po1^.address:= 0; //init
  if impl1 then begin //implementation
//   po1^.address:= opcount;
   inc(sublevel);   
   inclocvaraddress(stacklinksize);
   with contextstack[s.stackindex-1] do begin
    ele.markelement(b.elemark); 
    po1^.nestedvarele:= ele.addelementduplicate1(tks_nestedvarref,
                                                            ek_none,allvisi);
    po1^.nestedvarchain:= 0;
    po1^.nestedvarcount:= 1; //for callout frame ref
    d.subdef.ssabefore:= s.ssa;
    resetssa();
    d.subdef.frameoffsetbefore:= frameoffset;
    frameoffset:= locdatapo; //todo: nested procedures
    d.subdef.paramsize:= paramsize1;
    d.subdef.error:= err1;
    d.subdef.ref:= ele.eledatarel(po1);
    for int2:= 0 to paramco-1 do begin
     po2:= pointer(po4^[int2]);
     dec(po2^.address.locaddress.address,frameoffset);
     po4^[int2]:= ptruint(po2)-eledatabase;
     if tf_hasmanaged in po2^.vf.flags then begin
      writemanagedtypeop(mo_incref,ptypedataty(ele.eledataabs(po2^.vf.typ)),
                                                        po2^.address,0);
      po2^.vf.next:= po1^.paramfinichain;
      po1^.paramfinichain:= ele.eledatarel(po2);
     end;
    end;
   end;
  end
  else begin
   for int2:= 0 to paramco-1 do begin
    dec(po4^[int2],eledatabase); //relative address
   end;
   if not isinterface then begin
    forwardmark(po1^.mark,s.source);
   end
   else begin
    po1^.mark:= -1;
   end;
  end;

  parent1:= ele.decelementparent;
  with paramdata do begin  //check params duplicate
   ref:= po1;
   match:= nil;
  end;                                    
  if sf_override in subflags then begin
   if not ele.forallancestor(contextstack[s.stackindex+1].d.ident.ident,[ek_sub],
                             allvisi,@checkequalheader,paramdata) then begin
    err1:= true;
    errormessage(err_noancestormethod,[]);
   end
   else begin
    po1^.tableindex:= paramdata.match^.tableindex;
    with contextstack[s.stackindex-2] do begin
     dec(d.cla.virtualindex);
    end;
   end;
  end
  else begin
   if ele.forallcurrent(contextstack[s.stackindex+1].d.ident.ident,[ek_sub],
                             allvisi,@checkequalheader,paramdata) then begin
    err1:= true;
    errormessage(err_sameparamlist,[]);
   end;
  end;
  
  if impl1 then begin
   if sublevel = 1 then begin
    paramdata.match:= nil;
    if isclass then begin
     ele.pushelementparent(currentcontainer);
     bo1:= ele.forallcurrent(contextstack[s.stackindex+1].d.ident.ident,[ek_sub],
                                 allvisi,@checkequalparam,paramdata);
     ele.popelementparent();       
     if not bo1 then begin
      errormessage(err_methodexpected,[],1);
     end;
    end
    else begin
     bo1:= ele.forallcurrent(contextstack[s.stackindex+1].d.ident.ident,[ek_sub],
                                 allvisi,@checkequalparam,paramdata);
     if not bo1 then begin
      ele.decelementparent; //interface
      bo1:= ele.forallcurrent(contextstack[s.stackindex+1].d.ident.ident,[ek_sub],
                                allvisi,@checkequalparam,paramdata);
     end;
    end;
    if bo1 then begin
     with paramdata.match^ do begin
      forwardresolve(mark);
      impl:= ele.eledatarel(po1);
      pointer(parref):= @paramsrel;
      pointer(par1):= @po1^.paramsrel;
      for int1:= 0 to paramco-1 do begin
       if ele.eleinfoabs(parref^[int1])^.header.name <> 
                 ele.eleinfoabs(par1^[int1])^.header.name then begin
        errormessage(
             err_functionheadernotmatch,
                [getidentname(ele.eleinfoabs(parref^[int1])^.header.name),
                     getidentname(ele.eleinfoabs(par1^[int1])^.header.name)],
                                      s.stacktop-s.stackindex-3*(paramco-int1-1)-1);
       end;
      end;
     end;
    end;
    with contextstack[s.stackindex-1] do begin
     if paramdata.match <> nil then begin
      d.subdef.match:= ele.eledatarel(paramdata.match);
     end
     else begin
      d.subdef.match:= 0;
     end;
    end;
   end;
   ele.elementparent:= parent1; //restore in sub
   s.stacktop:= s.stackindex;
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
begin
{$ifdef mse_debugparser}
 outhandle('SUB5A');
{$endif}
 with info,contextstack[s.stackindex-2].d do begin
//  subdef.locallocidbefore:= locallocid;
  subdef.varsize:= locdatapo - subdef.parambase - subdef.paramsize;
  po1:= ele.eledataabs(subdef.ref);
  po1^.address:= opcount;
  if subdef.match <> 0 then begin
   po2:= ele.eledataabs(subdef.match);    
   po2^.address:= po1^.address;
   po1^.flags:= po2^.flags;
   po1^.tableindex:= po2^.tableindex;
   if po2^.flags * [sf_virtual,sf_override] <> [] then begin
   {$ifdef mse_checkinternalerror}
    if currentcontainer = 0 then begin
     internalerror(ie_sub,'20140502A');
    end;
   {$endif}
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     popaddressty(@pclassdefinfoty(getsegmentpo(infoclass.defs))^.
                      virtualmethods)[po2^.tableindex]:= po1^.address-1;
              //resolve virtual table entry, compensate oppo inc
    end;
   end;
   linkresolve(po2^.links,po1^.address);
  end;
  linkresolve(po1^.links,po1^.address); //nested calls
  if sf_constructor in subdef.flags then begin
   po3:= ele.eledataabs(currentcontainer);
   with additem(oc_initclass)^,par.initclass do begin
    selfinstance:= subdef.parambase-locdatapo+subdef.varsize;
    result:= selfinstance+subdef.paramsize-stacklinksize-pointersize;
   end;
  end;

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

  if info.backend = bke_llvm then begin
   ele1:= po1^.varchain;
   alloc1:= getsegmenttopoffs(seg_localloc);
   int1:= 0;
   while ele1 <> 0 do begin      //number params and vars
    po4:= ele.eledataabs(ele1);
    {
    if po4^.address.indirectlevel > 0 then begin
     int2:= 0;
    end
    else begin
     with ptypedataty(ele.eledataabs(po4^.vf.typ))^ do begin
      int2:= bitsize;
     end;
    end;
    }
    with plocallocinfoty(
                allocsegmentpo(seg_localloc,sizeof(locallocinfoty)))^ do begin
     address:= po4^.address.locaddress.address;
     flags:= po4^.address.flags;
     size:= getopdatatype(po4^.vf.typ,po4^.address.indirectlevel);
    end;
    ele1:= po4^.vf.next;
    inc(int1);
   end;
   po1^.allocs.allocs:= alloc1;
   po1^.allocs.alloccount:= int1;

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
   po1^.allocs.allocs:= 0;
   po1^.allocs.alloccount:= 0;
   po1^.allocs.nestedallocs:= 0;
   po1^.allocs.nestedalloccount:= 0;
  end;
  resetssa();
  int1:= getssa(ocssa_nestedvar,po1^.allocs.nestedalloccount);
  if sf_hascallout in po1^.flags then begin
   int1:= int1 + getssa(ocssa_hascallout);
  end;
  with additem(oc_subbegin,int1)^ do begin
   par.subbegin.subname:= po1^.address;
//   par.subbegin.flags:= po1^.flags;
   par.subbegin.allocs:= po1^.allocs;
   
//   par.subbegin.allocs.allocs:= alloc1;
//   par.subbegin.allocs.alloccount:= int1;
  end;
  if subdef.varsize <> 0 then begin //alloc local variables
   with additem(oc_locvarpush)^ do begin
    par.stacksize:= subdef.varsize;
   end;
  end;
  if stf_hasmanaged in s.currentstatementflags then begin
   writemanagedvarop(mo_ini,po1^.varchain,false,0);
  end;           //todo: implicit try-finally
 end;
end;

procedure handlesubbody6();
var
 po1{,po2}: psubdataty;
begin
{$ifdef mse_debugparser}
 outhandle('SUB6');
{$endif}
 with info,contextstack[s.stackindex-2] do begin
   //todo: check local forward
//  ele.decelementparent;
  po1:= ele.eledataabs(d.subdef.ref); //todo: implicit try-finally
  if stf_hasmanaged in s.currentstatementflags then begin
   writemanagedvarop(mo_fini,po1^.varchain,false,0);
  end;
  if po1^.paramfinichain <> 0 then begin
   writemanagedvarop(mo_fini,po1^.paramfinichain,false,0);
  end;          
  if d.subdef.varsize <> 0 then begin
   with additem(oc_locvarpop)^ do begin
    par.stacksize:= d.subdef.varsize;
   end;
  end;
  if sf_destructor in d.subdef.flags then begin
   with additem(oc_destroyclass)^,par.destroyclass do begin
    selfinstance:= -d.subdef.paramsize;
   end;
  end;
  if sf_function in po1^.flags then begin
   with additem(oc_returnfunc)^ do begin
    par.stacksize:= d.subdef.paramsize;
    par.returnfuncinfo.flags:= po1^.flags;
    par.returnfuncinfo.allocs:= po1^.allocs;
   end;
  end
  else begin
   with additem(oc_return)^ do begin
    par.stacksize:= d.subdef.paramsize;
   end;
  end;
  locdatapo:= d.subdef.parambase;
  s.ssa:= d.subdef.ssabefore;
  frameoffset:= d.subdef.frameoffsetbefore;
  dec(sublevel);
  if sublevel = 0 then begin
   ele.releaseelement(b.elemark); //remove local definitions
  end;
  ele.elementparent:= b.eleparent;
  s.currentstatementflags:= b.flags;
  if d.subdef.match <> 0 then begin
   po1:= ele.eledataabs(d.subdef.match);
   if (po1^.flags * [sf_virtual,sf_override] <> []) and 
                    (sf_intfcall in po1^.flags) then begin
    po1^.trampolineaddress:= opcount;
    linkresolve(po1^.trampolinelinks,po1^.trampolineaddress);
    with additem(oc_virttrampoline)^ do begin 
      //todo: possibly better in front of sub because of cache line
     par.virttrampolineinfo.selfinstance:= -d.subdef.paramsize;
     par.virttrampolineinfo.virtoffset:= po1^.tableindex*sizeof(opaddressty)+
                                                            virtualtableoffset;
    end;
   end;
  end;
  with additem(oc_subend)^ do begin
   par.subend.flags:= po1^.flags;
   par.subend.allocs:= po1^.allocs;
  end;
  locallocid:= d.subdef.locallocidbefore;
  with getitem(po1^.address)^ do begin
   par.subbegin.flags:= po1^.flags;
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
