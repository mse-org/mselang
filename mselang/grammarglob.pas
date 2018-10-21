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
unit grammarglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 globtypes,parserglob,elements;
 
const
 tks_none = 0;
 tks_rootele = $00000201;
 tks_void = $00000202;
 tks_classes = $00000203;
 tks_private = $00000204;
 tks_protected = $00000205;
 tks_public = $00000206;
 tks_published = $00000207;
 tks_classintfname = $00000208;
 tks_classintftype = $00000209;
 tks_classimp = $0000020A;
 tks_objpotyp = $0000020B;
 tks_classoftyp = $0000020C;
 tks_self = $0000020D;
 tks_units = $0000020E;
 tks_ancestors = $0000020F;
 tks_nestedvarref = $00000210;
 tks_defines = $00000211;
 tks_ini = $00000212;
 tks_inizeroed = $00000213;
 tks_fini = $00000214;
 tks_incref = $00000215;
 tks_decref = $00000216;
 tks_decrefindi = $00000217;
 tks_destroy = $00000218;
 tks_method = $00000219;
 tks_operators = $0000021A;
 tks_operatorsright = $0000021B;
 tks_system = $0000021C;
 tks___mla__mainfini = $0000021D;
 tks__none = $0000021E;
 tks__nil = $0000021F;
 tks__forward = $00000220;
 tk_mselang = $00000221;
 tk_pascal = $00000222;
 tk_system = $00000223;
 tk_result = $00000224;
 tk_exitcode = $00000225;
 tk_sizeof = $00000226;
 tk_defined = $00000227;
 tk_break = $00000228;
 tk_continue = $00000229;
 tk_self = $0000022A;
 tk_b = $0000022B;
 tk_booleval = $0000022C;
 tk_internaldebug = $0000022D;
 tk_nozeroinit = $0000022E;
 tk_zeroinit = $0000022F;
 tk_rtti = $00000230;
 tk_nortti = $00000231;
 tk_virtual = $00000232;
 tk_except = $00000233;
 tk_end = $00000234;
 tk_new = $00000235;
 tk_dispose = $00000236;
 tk_afterconstruct = $00000237;
 tk_beforedestruct = $00000238;
 tk_ini = $00000239;
 tk_fini = $0000023A;
 tk_incref = $0000023B;
 tk_decref = $0000023C;
 tk_operator = $0000023D;
 tk_operatorright = $0000023E;
 tk_default = $0000023F;
 tk_streaming = $00000240;
 tk_noexception = $00000241;
 tk_pointer = $00000242;
 tk_bool1 = $00000243;
 tk_int8 = $00000244;
 tk_int16 = $00000245;
 tk_int32 = $00000246;
 tk_int64 = $00000247;
 tk_intpo = $00000248;
 tk_card8 = $00000249;
 tk_card16 = $0000024A;
 tk_card32 = $0000024B;
 tk_card64 = $0000024C;
 tk_cardpo = $0000024D;
 tk_flo32 = $0000024E;
 tk_flo64 = $0000024F;
 tk_char8 = $00000250;
 tk_char16 = $00000251;
 tk_char32 = $00000252;
 tk_bytestring = $00000253;
 tk_string8 = $00000254;
 tk_string16 = $00000255;
 tk_string32 = $00000256;
 tk_false = $00000257;
 tk_true = $00000258;
 tk_nil = $00000259;
 tk_unit = $0000025A;
 tk_program = $0000025B;
 tk_interface = $0000025C;
 tk_implementation = $0000025D;
 tk_uses = $0000025E;
 tk_type = $0000025F;
 tk_const = $00000260;
 tk_var = $00000261;
 tk_threadvar = $00000262;
 tk_resourcestring = $00000263;
 tk_procedure = $00000264;
 tk_method = $00000265;
 tk_label = $00000266;
 tk_class = $00000267;
 tk_initialization = $00000268;
 tk_finalization = $00000269;
 tk_sub = $0000026A;
 tk_constructor = $0000026B;
 tk_destructor = $0000026C;
 tk_begin = $0000026D;
 tk_mode = $0000026E;
 tk_dumpelements = $0000026F;
 tk_dumpopcode = $00000270;
 tk_abort = $00000271;
 tk_stoponerror = $00000272;
 tk_nop = $00000273;
 tk_include = $00000274;
 tk_define = $00000275;
 tk_undef = $00000276;
 tk_ifdef = $00000277;
 tk_ifndef = $00000278;
 tk_if = $00000279;
 tk_else = $0000027A;
 tk_endif = $0000027B;
 tk_ifend = $0000027C;
 tk_h = $0000027D;
 tk_inline = $0000027E;
 tk_on = $0000027F;
 tk_off = $00000280;
 tk_constref = $00000281;
 tk_out = $00000282;
 tk_name = $00000283;
 tk_finally = $00000284;
 tk_do = $00000285;
 tk_with = $00000286;
 tk_case = $00000287;
 tk_while = $00000288;
 tk_repeat = $00000289;
 tk_for = $0000028A;
 tk_try = $0000028B;
 tk_raise = $0000028C;
 tk_goto = $0000028D;
 tk_then = $0000028E;
 tk_until = $0000028F;
 tk_to = $00000290;
 tk_downto = $00000291;
 tk_of = $00000292;
 tk_set = $00000293;
 tk_packed = $00000294;
 tk_record = $00000295;
 tk_array = $00000296;
 tk_object = $00000297;
 tk_external = $00000298;
 tk_private = $00000299;
 tk_protected = $0000029A;
 tk_public = $0000029B;
 tk_published = $0000029C;
 tk_property = $0000029D;
 tk_read = $0000029E;
 tk_write = $0000029F;
 tk_div = $000002A0;
 tk_mod = $000002A1;
 tk_and = $000002A2;
 tk_shl = $000002A3;
 tk_shr = $000002A4;
 tk_or = $000002A5;
 tk_xor = $000002A6;
 tk_in = $000002A7;
 tk_is = $000002A8;
 tk_not = $000002A9;
 tk_as = $000002AA;
 tk_inherited = $000002AB;
 tk_function = $000002AC;
 tk_override = $000002AD;
 tk_overload = $000002AE;
 tk_forward = $000002AF;

 tokens: array[0..175] of string = ('',
  '.rootele','.void','.classes','.private','.protected','.public','.published',
  '.classintfname','.classintftype','.classimp','.objpotyp','.classoftyp',
  '.self','.units','.ancestors','.nestedvarref','.defines','.ini','.inizeroed',
  '.fini','.incref','.decref','.decrefindi','.destroy','.method','.operators',
  '.operatorsright','.system','.__mla__mainfini','._none','._nil','._forward',
  'mselang','pascal','system','result','exitcode','sizeof','defined','break',
  'continue','self','b','booleval','internaldebug','nozeroinit','zeroinit',
  'rtti','nortti','virtual','except','end','new','dispose','afterconstruct',
  'beforedestruct','ini','fini','incref','decref','operator','operatorright',
  'default','streaming','noexception','pointer','bool1','int8','int16','int32',
  'int64','intpo','card8','card16','card32','card64','cardpo','flo32','flo64',
  'char8','char16','char32','bytestring','string8','string16','string32',
  'false','true','nil','unit','program','interface','implementation','uses',
  'type','const','var','threadvar','resourcestring','procedure','method',
  'label','class','initialization','finalization','sub','constructor',
  'destructor','begin','mode','dumpelements','dumpopcode','abort','stoponerror',
  'nop','include','define','undef','ifdef','ifndef','if','else','endif','ifend',
  'h','inline','on','off','constref','out','name','finally','do','with','case',
  'while','repeat','for','try','raise','goto','then','until','to','downto','of',
  'set','packed','record','array','object','external','private','protected',
  'public','published','property','read','write','div','mod','and','shl','shr',
  'or','xor','in','is','not','as','inherited','function','override','overload',
  'forward');

 tokenids: array[0..175] of identty = (
  $00000000,$00000201,$00000202,$00000203,$00000204,$00000205,$00000206,
  $00000207,$00000208,$00000209,$0000020A,$0000020B,$0000020C,$0000020D,
  $0000020E,$0000020F,$00000210,$00000211,$00000212,$00000213,$00000214,
  $00000215,$00000216,$00000217,$00000218,$00000219,$0000021A,$0000021B,
  $0000021C,$0000021D,$0000021E,$0000021F,$00000220,$00000221,$00000222,
  $00000223,$00000224,$00000225,$00000226,$00000227,$00000228,$00000229,
  $0000022A,$0000022B,$0000022C,$0000022D,$0000022E,$0000022F,$00000230,
  $00000231,$00000232,$00000233,$00000234,$00000235,$00000236,$00000237,
  $00000238,$00000239,$0000023A,$0000023B,$0000023C,$0000023D,$0000023E,
  $0000023F,$00000240,$00000241,$00000242,$00000243,$00000244,$00000245,
  $00000246,$00000247,$00000248,$00000249,$0000024A,$0000024B,$0000024C,
  $0000024D,$0000024E,$0000024F,$00000250,$00000251,$00000252,$00000253,
  $00000254,$00000255,$00000256,$00000257,$00000258,$00000259,$0000025A,
  $0000025B,$0000025C,$0000025D,$0000025E,$0000025F,$00000260,$00000261,
  $00000262,$00000263,$00000264,$00000265,$00000266,$00000267,$00000268,
  $00000269,$0000026A,$0000026B,$0000026C,$0000026D,$0000026E,$0000026F,
  $00000270,$00000271,$00000272,$00000273,$00000274,$00000275,$00000276,
  $00000277,$00000278,$00000279,$0000027A,$0000027B,$0000027C,$0000027D,
  $0000027E,$0000027F,$00000280,$00000281,$00000282,$00000283,$00000284,
  $00000285,$00000286,$00000287,$00000288,$00000289,$0000028A,$0000028B,
  $0000028C,$0000028D,$0000028E,$0000028F,$00000290,$00000291,$00000292,
  $00000293,$00000294,$00000295,$00000296,$00000297,$00000298,$00000299,
  $0000029A,$0000029B,$0000029C,$0000029D,$0000029E,$0000029F,$000002A0,
  $000002A1,$000002A2,$000002A3,$000002A4,$000002A5,$000002A6,$000002A7,
  $000002A8,$000002A9,$000002AA,$000002AB,$000002AC,$000002AD,$000002AE,
  $000002AF);

implementation
end.