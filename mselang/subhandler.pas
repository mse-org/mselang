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
 stackops;
 
const
 stacklinksize = sizeof(frameinfoty);

procedure handleparamsdef0entry();
procedure handleparams0entry();
procedure setconstparam();
procedure setvarparam();
procedure setoutparam();
procedure handleparamdef2();
procedure handleparamsend();
procedure handlesubheader();

procedure handlefunctionentry();
procedure handleprocedureentry();

procedure checkfunctiontype();
procedure handlesub1entry();
procedure handlesub3();
procedure handlesub5a();
procedure handlesub6();

implementation
uses
 parserglob,errorhandler,msetypes,handlerutils,elements,handlerglob,
 grammar,opcode;
 
type
 equalparaminfoty = record
  ref: psubdataty;
  match: psubdataty;
 end;

function checkparams(const po1,ref: psubdataty): boolean; inline;
var
 par1,parref: pelementoffsetaty;
 offs1: elementoffsetty;
 var1,varref: pvardataty;
 int1: integer;
begin
 result:= true;
 offs1:= ele.eledataoffset;
 pointer(par1):= @po1^.paramsrel;
 pointer(parref):= @ref^.paramsrel;
 for int1:= 0 to po1^.paramcount-1 do begin
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
// int1: integer;
// par1,parref: pelementoffsetaty;
// offs1: elementoffsetty;
// var1,varref: pvardataty;
begin
 po1:= @aelement^.data;
 with equalparaminfoty(adata) do begin
  if (po1 <> ref) and ((po1^.flags >< ref^.flags)*[sf_header] = []) and
     (po1^.paramcount = ref^.paramcount) and checkparams(po1,ref) then begin
   {
   offs1:= ele.eledataoffset;
   pointer(par1):= @po1^.paramsrel;
   pointer(parref):= @ref^.paramsrel;
   for int1:= 0 to po1^.paramcount-1 do begin
    var1:= pointer(par1^[int1]+offs1);
    varref:= pointer(parref^[int1]+offs1);
    if var1^.typ <> varref^.typ then begin
     exit;
    end;
   end;
   }
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
  {
   offs1:= ele.eledataoffset;
   pointer(par1):= @po1^.paramsrel;
   pointer(parref):= @ref^.paramsrel;
   for int1:= 0 to po1^.paramcount-1 do begin
    var1:= pointer(par1^[int1]+offs1);
    varref:= pointer(parref^[int1]+offs1);
    if var1^.typ <> varref^.typ then begin
     exit;
    end;
   end;
  }
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
outinfo('***');
 with info do begin
  with contextstack[stackindex].d do begin
   kind:= ck_params;
   params.flagsbefore:= currentstatementflags;
   include(currentstatementflags,stf_params);
  end;
 end;
end;

procedure setconstparam();
begin
{$ifdef mse_debugparser}
 outhandle('CONSTPARAM');
{$endif}
 with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
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
outinfo('***');
 with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
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
 with info,contextstack[contextstack[stackindex].parent].d.paramsdef do begin
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
outinfo('***');
 with info do begin
  if stacktop-stackindex <> 2 then begin
   errormessage(err_typeidentexpected,[]);
  end
  else begin
 {
   with contextstack[stacktop-1] do begin
    d.ident.paramkind:= 
             contextstack[contextstack[stackindex].parent].d.paramsdef.kind;
   end;
  }
  end;
 end;
end;

procedure handleparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
 with info do begin
  with contextstack[stackindex].d do begin
   currentstatementflags:= params.flagsbefore;
  end;
 end;
end;

procedure handlesubheader();
begin
{$ifdef mse_debugparser}
 outhandle('SUBHEADER');
{$endif}
 with info do begin
  dec(stackindex);
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
outinfo('****');
 with info,contextstack[stackindex].d do begin
  kind:= ck_subdef;
  subdef.flags:= [sf_function];
 end;
end;

(*
procedure handlefunctionentry();
begin
{$ifdef mse_debugparser}
 outhandle('FUNCTIONENTRY');
{$endif}
end;
*)
(*
procedure handleparamsend();
begin
{$ifdef mse_debugparser}
 outhandle('PARAMSEND');
{$endif}
 with info^ do begin
  if source.po^ <> ')' then begin
   error(info,ce_endbracketexpected);
//   outcommand(info,[],'*ERROR* '')'' expected');
  end
  else begin
   inc(source.po);
  end;
  dec(stackindex);
 end;
end;
*)
procedure checkfunctiontype();
begin
{$ifdef mse_debugparser}
 outhandle('CHECKFUNCTIONTYPE');
{$endif}
outinfo('****');
 with info,contextstack[stackindex-1] do begin
  d.kind:= ck_paramsdef;
  d.paramsdef.kind:= pk_var;
 end;
 with info,contextstack[stackindex] do begin
  d.kind:= ck_ident;
//  d.ident.paramkind:= pk_var;
  d.ident.ident:= resultident;
  with contextstack[parent-1] do begin
   if sf_functiontype in d.subdef.flags then begin
    errormessage(err_syntax,[';']);
   end;
   include(d.subdef.flags,sf_functiontype);
  end;
 end;
outinfo('****');
end;

procedure handlesub1entry();
var
 int1: integer;
 ele1: elementoffsetty;
 po1: pelementinfoty;
begin
{$ifdef mse_debugparser}
 outhandle('SUB1ENTRY');
{$endif}
outinfo('****');
 with info,contextstack[stackindex] do begin
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
      currentclass:= ele1;
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

procedure handlesub3();
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
 paramkind1: paramkindty;
 bo1,isclass: boolean;

begin
{$ifdef mse_debugparser}
 outhandle('SUB3');
{$endif}
//0          1     2          3          4    5      6           7
//procedure2,ident,paramsdef3{,paramdef2,name,type}[functiontype,ident]
              //todo: multi level type
outinfo('****');
 with info do begin
  subflags:= contextstack[stackindex-1].d.subdef.flags;
  with contextstack[stackindex] do begin
   d.subdef.flags:= subflags;
   d.subdef.parambase:= locdatapo;
  end;
  if (sf_function in subflags) and 
                      not (sf_functiontype in subflags) then begin
   tokenexpectederror(':');
  end;
outinfo('****');
  isclass:= currentstatementflags * [stf_classdef,stf_classimp] <> [];
  paramco:= (stacktop-stackindex-2) div 3;
  paramhigh:= paramco-1;
  if isclass then begin
   inc(paramco); //self pointer
  end;
  int2:= paramco*(sizeof(pvardataty)+elesizes[ek_var])+elesizes[ek_sub];
  ele.checkcapacity(int2); //absolute addresses can be used
  eledatabase:= ele.eledataoffset();
  po1:= addr(ele.pushelementduplicate(
                      contextstack[stackindex+1].d.ident.ident,
                      allvisi,ek_sub,paramco*sizeof(pvardataty))^.data);
  po1^.paramcount:= paramco;
  po1^.links:= 0;
  po1^.nestinglevel:= funclevel;
  po1^.flags:= subflags;
  po4:= @po1^.paramsrel;
  int1:= 4;
  err1:= false;
  impl1:= (us_implementation in unitinfo^.state) and 
                                                 not (sf_header in subflags);
  if isclass then begin
   if not ele.addelement(tks_self,allvisi,ek_var,po2) then begin
    internalerror('H20140415A');
    exit;
   end;
   po4^[0]:= elementoffsetty(po2); //absoluteaddress
   inc(po4);
   with po2^ do begin
    address.indirectlevel:= 1;
    if impl1 then begin
     address.address:= getlocvaraddress(pointersize);
    end;
    address.framelevel:= funclevel+1;
    address.flags:= [vf_param];
    include(address.flags,vf_const);
    vf.typ:= currentclass;
   end;
  end;
  for int2:= 0 to paramhigh do begin
   paramkind1:= contextstack[int1+stackindex-1].d.paramsdef.kind;
   with contextstack[int1+stackindex] do begin
    if ele.addelement(d.ident.ident,allvisi,ek_var,po2) then begin
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
        address.flags:= [vf_param];
        if paramkind1 = pk_const then begin
         if si1 > pointersize then begin
          inc(address.indirectlevel);
          include(address.flags,vf_paramindirect);
         end;
         include(address.flags,vf_const);
        end
        else begin
         if paramkind1 in [pk_var,pk_out] then begin
          inc(address.indirectlevel);
          include(address.flags,vf_paramindirect);
         end;
        end;
        vf.typ:= d.typ.typedata;
       end;
      end
      else begin
//       identerror(int1+1-stackindex,err_identifiernotfound);
       err1:= true;
      end;
     end;
    end
    else begin
     identerror(int1,err_duplicateidentifier);
     err1:= true;
    end;
   end;
   int1:= int1+3;
  end;

  if isclass then begin
   dec(po4);
  end;
  po1^.address:= 0; //init
  if impl1 then begin //implementation
   inc(funclevel);
   getlocvaraddress(stacklinksize);
   with contextstack[stackindex] do begin
    d.kind:= ck_subdef;
    d.subdef.frameoffsetbefore:= frameoffset;
    frameoffset:= locdatapo; //todo: nested procedures
    stacktop:= stackindex;
    d.subdef.paramsize:= locdatapo - d.subdef.parambase;
    po1^.paramsize:= d.subdef.paramsize;
    d.subdef.error:= err1;
    d.subdef.ref:= ele.eledatarel(po1);
    for int2:= 0 to paramco-1 do begin
     po2:= pointer(po4^[int2]);
     dec(po2^.address.address,frameoffset);
     po4^[int2]:= ptruint(po2)-eledatabase;
    end;
    ele.markelement(d.subdef.elementmark); 
   end;
  end
  else begin
   for int2:= 0 to paramco-1 do begin
    dec(po4^[int2],eledatabase); //relative address
   end;
   forwardmark(po1^.mark,source);
  end;

  parent1:= ele.decelementparent;
  with paramdata do begin  //check params duplicate
   ref:= po1;
   match:= nil;
  end;                                    
  if ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                            allvisi,@checkequalheader,paramdata) then begin
   err1:= true;
   errormessage(err_sameparamlist,[]);
  end;
  
  if impl1 then begin
   if funclevel = 1 then begin
    paramdata.match:= nil;
    if isclass then begin
     ele.pushelementparent(currentclass);
     bo1:= ele.forallcurrent(contextstack[stackindex+1].d.ident.ident,[ek_sub],
                                 allvisi,@checkequalparam,paramdata);
     ele.popelementparent();       
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
    with contextstack[stackindex] do begin
     if paramdata.match <> nil then begin
      d.subdef.match:= ele.eledatarel(paramdata.match);
     end
     else begin
      d.subdef.match:= 0;
     end;
    end;
   end;
  end;
 end;
end;

procedure handlesub5a();
var
 po1,po2: psubdataty;
begin
{$ifdef mse_debugparser}
 outhandle('SUB5A');
{$endif}
outinfo('*****');
 with info,contextstack[stackindex-1].d do begin
  subdef.varsize:= locdatapo - subdef.parambase - subdef.paramsize;
  po1:= ele.eledataabs(subdef.ref);
  with po1^ do begin
   address:= opcount;
  end;
  if subdef.varsize <> 0 then begin
   with additem()^ do begin
    op:= @locvarpushop;
    d.stacksize:= subdef.varsize;
   end;
  end;
  if subdef.match <> 0 then begin
   po2:= ele.eledataabs(subdef.match);    
   po2^.address:= opcount;
   linkresolve(po2^.links,opcount);
  end;
 end;
end;

procedure handlesub6();
begin
{$ifdef mse_debugparser}
 outhandle('SUB6');
{$endif}
outinfo('*****');
 with info do begin
  with contextstack[stackindex-1],d do begin
   //todo: check local forward
   ele.decelementparent;
   ele.releaseelement(subdef.elementmark); //remove local definitions
   if subdef.varsize <> 0 then begin
    with additem()^ do begin
     op:= @locvarpopop;
     d.stacksize:= subdef.varsize;
    end;
   end;
   with additem()^ do begin
    op:= @returnop;
    d.stacksize:= subdef.paramsize;
   end;
   locdatapo:= subdef.parambase;
   frameoffset:= subdef.frameoffsetbefore;
  end;
  dec(funclevel);
  if (funclevel = 0) and (stf_classimp in currentstatementflags) then begin
   exclude(currentstatementflags,stf_classimp);
   ele.popelementparent();
//   ele.popscopelevel();
  end;
 end;
end;

end.
