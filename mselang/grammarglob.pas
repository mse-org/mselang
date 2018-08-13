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
 tk_mselang = $0000021E;
 tk_pascal = $0000021F;
 tk_system = $00000220;
 tk_nil = $00000221;
 tk_result = $00000222;
 tk_exitcode = $00000223;
 tk_sizeof = $00000224;
 tk_defined = $00000225;
 tk_break = $00000226;
 tk_continue = $00000227;
 tk_self = $00000228;
 tk_b = $00000229;
 tk_booleval = $0000022A;
 tk_internaldebug = $0000022B;
 tk_nozeroinit = $0000022C;
 tk_zeroinit = $0000022D;
 tk_rtti = $0000022E;
 tk_nortti = $0000022F;
 tk_virtual = $00000230;
 tk_except = $00000231;
 tk_end = $00000232;
 tk_new = $00000233;
 tk_dispose = $00000234;
 tk_afterconstruct = $00000235;
 tk_beforedestruct = $00000236;
 tk_ini = $00000237;
 tk_fini = $00000238;
 tk_incref = $00000239;
 tk_decref = $0000023A;
 tk_operator = $0000023B;
 tk_operatorright = $0000023C;
 tk_default = $0000023D;
 tk_streaming = $0000023E;
 tk_unit = $0000023F;
 tk_program = $00000240;
 tk_interface = $00000241;
 tk_implementation = $00000242;
 tk_uses = $00000243;
 tk_type = $00000244;
 tk_const = $00000245;
 tk_var = $00000246;
 tk_threadvar = $00000247;
 tk_resourcestring = $00000248;
 tk_label = $00000249;
 tk_class = $0000024A;
 tk_procedure = $0000024B;
 tk_function = $0000024C;
 tk_method = $0000024D;
 tk_initialization = $0000024E;
 tk_finalization = $0000024F;
 tk_constructor = $00000250;
 tk_destructor = $00000251;
 tk_begin = $00000252;
 tk_mode = $00000253;
 tk_dumpelements = $00000254;
 tk_dumpopcode = $00000255;
 tk_abort = $00000256;
 tk_stoponerror = $00000257;
 tk_nop = $00000258;
 tk_include = $00000259;
 tk_define = $0000025A;
 tk_undef = $0000025B;
 tk_ifdef = $0000025C;
 tk_ifndef = $0000025D;
 tk_if = $0000025E;
 tk_else = $0000025F;
 tk_endif = $00000260;
 tk_ifend = $00000261;
 tk_h = $00000262;
 tk_inline = $00000263;
 tk_on = $00000264;
 tk_off = $00000265;
 tk_constref = $00000266;
 tk_out = $00000267;
 tk_override = $00000268;
 tk_overload = $00000269;
 tk_of = $0000026A;
 tk_object = $0000026B;
 tk_external = $0000026C;
 tk_forward = $0000026D;
 tk_name = $0000026E;
 tk_sub = $0000026F;
 tk_finally = $00000270;
 tk_do = $00000271;
 tk_with = $00000272;
 tk_case = $00000273;
 tk_while = $00000274;
 tk_repeat = $00000275;
 tk_for = $00000276;
 tk_try = $00000277;
 tk_raise = $00000278;
 tk_goto = $00000279;
 tk_then = $0000027A;
 tk_until = $0000027B;
 tk_to = $0000027C;
 tk_downto = $0000027D;
 tk_set = $0000027E;
 tk_packed = $0000027F;
 tk_record = $00000280;
 tk_array = $00000281;
 tk_private = $00000282;
 tk_protected = $00000283;
 tk_public = $00000284;
 tk_published = $00000285;
 tk_property = $00000286;
 tk_read = $00000287;
 tk_write = $00000288;
 tk_div = $00000289;
 tk_mod = $0000028A;
 tk_and = $0000028B;
 tk_shl = $0000028C;
 tk_shr = $0000028D;
 tk_or = $0000028E;
 tk_xor = $0000028F;
 tk_in = $00000290;
 tk_is = $00000291;
 tk_not = $00000292;
 tk_as = $00000293;
 tk_inherited = $00000294;

 tokens: array[0..148] of string = ('',
  '.rootele','.void','.classes','.private','.protected','.public','.published',
  '.classintfname','.classintftype','.classimp','.objpotyp','.classoftyp',
  '.self','.units','.ancestors','.nestedvarref','.defines','.ini','.inizeroed',
  '.fini','.incref','.decref','.decrefindi','.destroy','.method','.operators',
  '.operatorsright','.system','.__mla__mainfini',
  'mselang','pascal','system','nil','result','exitcode','sizeof','defined',
  'break','continue','self','b','booleval','internaldebug','nozeroinit',
  'zeroinit','rtti','nortti','virtual','except','end','new','dispose',
  'afterconstruct','beforedestruct','ini','fini','incref','decref','operator',
  'operatorright','default','streaming','unit','program','interface',
  'implementation','uses','type','const','var','threadvar','resourcestring',
  'label','class','procedure','function','method','initialization',
  'finalization','constructor','destructor','begin','mode','dumpelements',
  'dumpopcode','abort','stoponerror','nop','include','define','undef','ifdef',
  'ifndef','if','else','endif','ifend','h','inline','on','off','constref','out',
  'override','overload','of','object','external','forward','name','sub',
  'finally','do','with','case','while','repeat','for','try','raise','goto',
  'then','until','to','downto','set','packed','record','array','private',
  'protected','public','published','property','read','write','div','mod','and',
  'shl','shr','or','xor','in','is','not','as','inherited');

 tokenids: array[0..148] of identty = (
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
  $00000293,$00000294);

implementation
end.