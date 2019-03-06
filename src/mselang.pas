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
  gettext,msei18nutils,mseconsts,mseconsts_ru,mseconsts_uzcyr,
  mseconsts_de,mseconsts_es,mseconsts_zh,mseconsts_id,mseconsts_fr,
 {$endif}
 
  msegui,mseforms,main,compmoduledebug, patheditform;

{$ifdef mse_i18n}
var
  MSELanguage,MSEFallbacklang:string;
  {$endif}

begin
 {$ifdef mse_i18n}
 Gettext.GetLanguageIDs(MSELanguage,MSEFallbackLang);
 if loadlangunit('.' + directoryseparator + 'languages' + directoryseparator +
  'mselang_i18n_'+ MSEFallbackLang,true) then
                                                   setlangconsts(MSEFallbackLang);
 {$endif}

 application.createdatamodule(tcompdebugmo,compdebugmo);
 application.createform(tmainfo,mainfo);
 application.createform(tpatheditfo,patheditfo);
 application.run;
end.
