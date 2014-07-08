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

implementation
uses
 errorhandler,msetypes,handlerutils,elements,grammar,opcode,unithandler,
 managedtypes;
 
type
 equalparaminfoty = record
  ref: psubdataty;
  match: psubdataty;
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
 with info,contextstack[stackindex].d do begin
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
  with contextstack[stackindex] do begin
   d.kind:= ck_params;
   b.flags:= currentstatementflags;
   include(currentstatementflags,stf_params);
  end;
 end;
end;

procedure setconstparam();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTPARAM');
{$endif}
// with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
 with info,contextstack[stackindex].d.paramsdef do begin
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
 with info,contextstack[stackindex].d.paramsdef do begin
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
 with info,contextstack[stackindex].d.paramsdef do begin
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
  if stacktop-stackindex <> 2 then begin
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
  with contextstack[stackindex] do begin
   currentstatementflags:= b.flags;
  end;
 end;
end;

procedure handleprocedureentry();
begin
{$ifdef mse_debugparser}
 outhandle('PROCEDUREENTRY');
{$endif}
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [];
 end;
end;

procedure handlefunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONENTRY');
{$endif}
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_function];
 end;
end;

procedure checkfunctiontype();
begin
{$ifdef mse_debugparser}
 outhandle('CHECKFUNCTIONTYPE');
{$endif}
 with info,contextstack[stackindex-1] do begin
  d.kind:= ck_paramsdef;
  d.paramsdef.kind:= pk_var;
 end;
 with info,contextstack[stackindex] do begin
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
 with info,contextstack[stackindex-1] do begin
  b.flags:= currentstatementflags;
  b.eleparent:= ele.elementparent;
  exclude(currentstatementflags,stf_hasmanaged);
  int1:= stacktop-stackindex; 
  if int1 > 1 then begin //todo: check procedure level and the like
   if not ele.findupward(contextstack[stackindex+1].d.ident.ident,[],
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
     else begin
///      ele.pushscopelevel();
      include(currentstatementflags,stf_classimp);
      currentcontainer:= ele1;
      contextstack[stackindex+1].d.ident:= contextstack[stackindex+2].d.ident;
      stacktop:= stackindex+1;
      ele.pushelementparent(ptypedataty(ele.eledataabs(ele1))^.infoclass.impl);
     end;
    end;
   end;
  end
  else begin
   exclude(currentstatementflags,stf_classimp);
//   currentclass:= 0;
  end;
 end;
end;

function checkclassdef(): boolean;
begin
 result:= true;
 with info,contextstack[stackindex-1] do begin
  if not (stf_classdef in currentstatementflags) then begin
   result:= false;
   if stf_implementation in currentstatementflags then begin
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
  with info,contextstack[stackindex-1] do begin
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
  with info,contextstack[stackindex-1] do begin
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
 int1,int2: integer;
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

begin
{$ifdef mse_debugparser}
 outhandle('SUB3');
{$endif}
//|-2        |-1  0     1     2           3           4        5    
//|classdef0,|sub,sub2,ident,paramsdef3{,ck_paramsdef,ck_ident,ck_type}
// interfacedef0
//  6           7             8    result
//[ck_paramsdef,ck_ident,ck_type] 
              //todo: multi level type
 with info do begin
//  subflags:= contextstack[stackindex-1].d.subdef.flags;
  with contextstack[stackindex-1] do begin
   subflags:= d.subdef.flags;
   d.subdef.parambase:= locdatapo;
  end;
  if (sf_function in subflags) and 
                      not (sf_functiontype in subflags) then begin
   tokenexpectederror(':');
  end;
  paramsize1:= 0;
  isclass:= currentstatementflags * [stf_classdef,stf_classimp] <> [];
  isinterface:=  stf_interfacedef in currentstatementflags;
  ismethod:= isclass or isinterface;
  if isclass and (sf_constructor in subflags) then begin //add return type
   inc(stacktop);
   with contextstack[stacktop] do begin
    d.kind:= ck_paramsdef;
    d.paramsdef.kind:= pk_var;
   end;
   inc(stacktop);
   with contextstack[stacktop] do begin
    d.kind:= ck_ident;
    d.ident.ident:= tk_result;
   end;
   inc(stacktop);
   with contextstack[stacktop] do begin
    d.kind:= ck_fieldtype;
    d.typ.typedata:= currentcontainer;
    d.typ.indirectlevel:= 1;
   end;
  end;
  paramco:= (stacktop-stackindex-2) div 3;
  paramhigh:= paramco-1;
  if ismethod then begin
   inc(paramco); //self pointer
  end;
  int2:= paramco*(sizeof(pvardataty)+elesizes[ek_var])+elesizes[ek_sub];
  ele.checkcapacity(int2); //absolute addresses can be used
  eledatabase:= ele.eledataoffset();
  ident1:= contextstack[stackindex+1].d.ident.ident;
  if ele.findcurrent(ident1,[],allvisi,ele1) and 
       (ele.eleinfoabs(ele1)^.header.kind <> ek_sub) then begin
   identerror(1,err_overloadnotfunc);
  end;
  po1:= addr(ele.pushelementduplicate(ident1,
                      allvisi,ek_sub,paramco*sizeof(pvardataty))^.data);
  po1^.next:= currentsubchain;
  currentsubchain:= ele.eledatarel(po1);
  inc(currentsubcount);
  po1^.paramcount:= paramco;
  po1^.links:= 0;
  po1^.nestinglevel:= funclevel;
  po1^.flags:= subflags;
  po1^.virtualindex:= -1; //none
  po1^.varchain:= 0;
  po1^.paramfinichain:= 0;
  if (stf_classdef in currentstatementflags) and 
                        (subflags*[sf_virtual,sf_override]<>[]) then begin
   with contextstack[stackindex-2] do begin
    po1^.virtualindex:= d.cla.virtualindex;
    inc(d.cla.virtualindex);
   end;
  end;
  po4:= @po1^.paramsrel;
  int1:= 4;
  err1:= false;
  impl1:= (us_implementation in unitinfo^.state) and 
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
     address.address:= getlocvaraddress(pointersize);
    end;
    address.framelevel:= funclevel+1;
    address.flags:= [af_param];
    include(address.flags,af_const);
    vf.typ:= currentcontainer;
   end;
  end;
  for int2:= 0 to paramhigh do begin
   paramkind1:= contextstack[int1+stackindex-1].d.paramsdef.kind;
   with contextstack[int1+stackindex] do begin
    if (isclass and
        ele.findchild(currentcontainer,d.ident.ident,[],allvisi,ele1)) or not
            addvar(d.ident.ident,allvisi,po1^.varchain,po2) then begin
     identerror(int1,err_duplicateidentifier);
     err1:= true;
    end;
    po4^[int2]:= elementoffsetty(po2); //absoluteaddress
    with contextstack[int1+stackindex+1] do begin
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
        address.address:= getlocvaraddress(si1);
       end;
       address.framelevel:= funclevel+1;
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
//       identerror(int1+1-stackindex,err_identifiernotfound);
      err1:= true;
     end;
     inc(paramsize1,si1);
    end;
   end;
   int1:= int1+3;
  end;
  if ismethod then begin
   dec(po4);
  end;
  inc(paramsize1,stacklinksize);
  po1^.paramsize:= paramsize1;
  po1^.address:= 0; //init
  if impl1 then begin //implementation
   po1^.address:= opcount;
   inc(funclevel);
   getlocvaraddress(stacklinksize);
   with contextstack[stackindex-1] do begin
    d.subdef.frameoffsetbefore:= frameoffset;
    frameoffset:= locdatapo; //todo: nested procedures
    d.subdef.paramsize:= paramsize1;
    d.subdef.error:= err1;
    d.subdef.ref:= ele.eledatarel(po1);
    for int2:= 0 to paramco-1 do begin
     po2:= pointer(po4^[int2]);
     dec(po2^.address.address,frameoffset);
     po4^[int2]:= ptruint(po2)-eledatabase;
     if tf_hasmanaged in po2^.vf.flags then begin
      writemanagedtypeop(mo_incref,ptypedataty(ele.eledataabs(po2^.vf.typ)),
                                                                 po2^.address);
      po2^.vf.next:= po1^.paramfinichain;
      po1^.paramfinichain:= ele.eledatarel(po2);
     end;
    end;
    ele.markelement(b.elemark); 
//    markmanagedblock(b.managedblock);
   end;
  end
  else begin
   for int2:= 0 to paramco-1 do begin
    dec(po4^[int2],eledatabase); //relative address
   end;
   if not isinterface then begin
    forwardmark(po1^.mark,source);
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
   if not ele.forallancestor(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                             allvisi,@checkequalheader,paramdata) then begin
    err1:= true;
    errormessage(err_noancestormethod,[]);
   end
   else begin
    po1^.virtualindex:= paramdata.match^.virtualindex;
    with contextstack[stackindex-2] do begin
     dec(d.cla.virtualindex);
    end;
   end;
  end
  else begin
   if ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                             allvisi,@checkequalheader,paramdata) then begin
    err1:= true;
    errormessage(err_sameparamlist,[]);
   end;
  end;
  
  if impl1 then begin
   if funclevel = 1 then begin
    paramdata.match:= nil;
    if isclass then begin
     ele.pushelementparent(currentcontainer);
     bo1:= ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                                 allvisi,@checkequalparam,paramdata);
     ele.popelementparent();       
     if not bo1 then begin
      errormessage(err_methodexpected,[],1);
     end;
    end
    else begin
     bo1:= ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                                 allvisi,@checkequalparam,paramdata);
     if not bo1 then begin
      ele.decelementparent; //interface
      bo1:= ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
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
                                      stacktop-stackindex-3*(paramco-int1-1)-1);
       end;
      end;
     end;
    end;
    ele.elementparent:= parent1; //restore in sub
    with contextstack[stackindex-1] do begin
     if paramdata.match <> nil then begin
      d.subdef.match:= ele.eledatarel(paramdata.match);
     end
     else begin
      d.subdef.match:= 0;
     end;
    end;
   end;
   stacktop:= stackindex;
  end;
 end;
end;

procedure handlesubbody5a();
var
 po1,po2: psubdataty;
 po3: ptypedataty;
begin
{$ifdef mse_debugparser}
 outhandle('SUB5A');
{$endif}
 with info,contextstack[stackindex-2].d do begin
  subdef.varsize:= locdatapo - subdef.parambase - subdef.paramsize;
  po1:= ele.eledataabs(subdef.ref);
//  with po1^ do begin
//   address:= opcount;
//  end;
  if subdef.match <> 0 then begin
   po2:= ele.eledataabs(subdef.match);    
   po2^.address:= po1^.address;
   po1^.flags:= po2^.flags;
   po1^.virtualindex:= po2^.virtualindex;
   if po2^.flags * [sf_virtual,sf_override] <> [] then begin
   {$ifdef mse_checkinternalerror}
    if currentcontainer = 0 then begin
     internalerror(ie_sub,'20140502A');
    end;
   {$endif}
    with ptypedataty(ele.eledataabs(currentcontainer))^ do begin
     popaddressty(@pclassdefinfoty(pointer(constseg)+infoclass.defs)^.
                      virtualmethods)[po2^.virtualindex]:= po1^.address-1;
              //resolve virtual table entry, compensate oppo inc
    end;
   end;
   linkresolve(po2^.links,po1^.address);
  end;
  if sf_constructor in subdef.flags then begin
   po3:= ele.eledataabs(currentcontainer);
   with additem^,par.initclass do begin
    op:= @initclassop;
    selfinstance:= subdef.parambase-locdatapo+subdef.varsize;
    result:= selfinstance+subdef.paramsize-stacklinksize-pointersize;
   end;
  end;
  if subdef.varsize <> 0 then begin //alloc local variables
   with additem()^ do begin
    op:= @locvarpushop;
    par.stacksize:= subdef.varsize;
   end;
  end;
  if stf_hasmanaged in currentstatementflags then begin
   writemanagedvarop(mo_ini,po1^.varchain,false);
  end;
 end;
end;

procedure handlesubbody6();
var
 po1: psubdataty;
begin
{$ifdef mse_debugparser}
 outhandle('SUB6');
{$endif}
 with info,contextstack[stackindex-2] do begin
   //todo: check local forward
//  ele.decelementparent;
  po1:= ele.eledataabs(d.subdef.ref);
  if stf_hasmanaged in currentstatementflags then begin
   writemanagedvarop(mo_fini,po1^.varchain,false);
  end;
  if po1^.paramfinichain <> 0 then begin
   writemanagedvarop(mo_fini,po1^.paramfinichain,false);
  end;
  if d.subdef.varsize <> 0 then begin
   with additem()^ do begin
    op:= @locvarpopop;
    par.stacksize:= d.subdef.varsize;
   end;
  end;
  if sf_destructor in d.subdef.flags then begin
   with additem^,par.destroyclass do begin
    op:= @destroyclassop;
    selfinstance:= -d.subdef.paramsize;
   end;
  end;
  with additem()^ do begin
   op:= @returnop;
   par.stacksize:= d.subdef.paramsize;
  end;
  locdatapo:= d.subdef.parambase;
  frameoffset:= d.subdef.frameoffsetbefore;
  dec(funclevel);
  ele.releaseelement(b.elemark); //remove local definitions
  ele.elementparent:= b.eleparent;
  currentstatementflags:= b.flags;
 end;
end;

procedure handlebeginexpected();
begin
{$ifdef mse_debugparser}
 outhandle('BEGINEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('begin');
  dec(stackindex);
 end;
end;

procedure handleendexpected();
begin
{$ifdef mse_debugparser}
 outhandle('ENDEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('end');
  dec(stackindex);
 end;
end;

procedure handleimplementationexpected();
begin
{$ifdef mse_debugparser}
 outhandle('IMPLEMENTATIONEXPECTED');
{$endif}
 with info do begin
  tokenexpectederror('implementation');
  dec(stackindex);
 end;
end;

end.
