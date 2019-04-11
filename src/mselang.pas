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
program mselang;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif}
 
 {$ifdef mse_i18n}
  gettext,msei18nutils,msestrings,mseconsts,
  //{
  mseconsts_af,mseconsts_am,mseconsts_an,mseconsts_ar,mseconsts_as,
  mseconsts_ast,mseconsts_az,mseconsts_be,mseconsts_bg,mseconsts_bn,
  mseconsts_br,mseconsts_bs,mseconsts_ca,mseconsts_crh,mseconsts_cs,
  mseconsts_cy,mseconsts_da,mseconsts_de,mseconsts_dz,mseconsts_el,
  mseconsts_eo,mseconsts_es,mseconsts_et,mseconsts_eu,mseconsts_fa,
  mseconsts_fi,mseconsts_fr,mseconsts_ga,mseconsts_gd,mseconsts_gl,
  mseconsts_gu,mseconsts_he,mseconsts_hi,mseconsts_hr,mseconsts_hu,
  mseconsts_hy,mseconsts_id,mseconsts_is,mseconsts_it,mseconsts_ja,
  mseconsts_ka,mseconsts_kk,mseconsts_km,mseconsts_kn,mseconsts_ko,
  mseconsts_ku,mseconsts_lb,mseconsts_ln,mseconsts_lo,mseconsts_lt,
  mseconsts_lv,mseconsts_mg,mseconsts_mi,mseconsts_mk,mseconsts_ml,
  mseconsts_mn,mseconsts_mr,mseconsts_ms,mseconsts_my,mseconsts_nb,
  mseconsts_nds,mseconsts_ne,mseconsts_nl,mseconsts_nn,mseconsts_oc,
  mseconsts_or,mseconsts_pa,mseconsts_pl,mseconsts_ps,mseconsts_pt,
  mseconsts_pt_BR,mseconsts_ro,mseconsts_ru,mseconsts_rw,mseconsts_si,
  mseconsts_sk,mseconsts_sl,mseconsts_sq,mseconsts_sr,mseconsts_sr_latin,
  mseconsts_sv,mseconsts_ta,mseconsts_te,mseconsts_tg,mseconsts_th,
  mseconsts_tk,mseconsts_tr,mseconsts_ug,mseconsts_uk,mseconsts_uz,
  mseconsts_uz_Latn,mseconsts_vi,mseconsts_wa,mseconsts_xh,mseconsts_zh,
  mseconsts_zh_HK,mseconsts_zh_TW,
  //}
  {$endif}
 
  msegui,mseforms,main,compmoduledebug,patheditform;

{$ifdef mse_i18n}
var
  MSELanguage,MSEFallbacklang:string;
{$endif}

begin
{$ifdef mse_i18n}
  Gettext.GetLanguageIDs(MSELang,MSEFallbackLang);
  if not loadlangunit('i18n_'+splitstring((MSELang),'.')[0],true) then
     if loadlangunit('i18n_'+MSEFallbackLang,true) then
         if not setlangconsts(splitstring((MSELang),'.')[0]) then
               setlangconsts(MSEFallbackLang);
{$endif}

 application.createdatamodule(tcompdebugmo,compdebugmo);
 application.createform(tmainfo,mainfo);
 application.createform(tpatheditfo,patheditfo);
 application.run;
end.
