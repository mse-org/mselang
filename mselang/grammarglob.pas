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
 tks_void = $4FC6E54B;
 tks_classes = $9F8DCA96;
 tks_private = $3F1B952D;
 tks_protected = $7E372A5B;
 tks_public = $FC6E54B6;
 tks_published = $F8DCA96C;
 tks_classintfname = $F1B952D8;
 tks_classintftype = $E372A5B1;
 tks_classimp = $C6E54B62;
 tks_self = $8DCA96C4;
 tks_units = $1B952D88;
 tks_ancestors = $372A5B10;
 tks_nestedvarref = $6E54B621;
 tks_defines = $DCA96C42;
 tks_ini = $B952D885;
 tks_fini = $72A5B10B;
 tks_incref = $E54B6216;
 tks_decref = $CA96C42D;
 tks_decrefindi = $952D885A;
 tks_method = $2A5B10B4;
 tks_operators = $54B62168;
 tks_operatorsright = $A96C42D0;
 tks_system = $52D885A1;
 tk_mselang = $A5B10B43;
 tk_pascal = $4B621687;
 tk_nil = $96C42D0E;
 tk_result = $2D885A1C;
 tk_exitcode = $5B10B438;
 tk_sizeof = $B6216870;
 tk_defined = $6C42D0E1;
 tk_break = $D885A1C3;
 tk_continue = $B10B4387;
 tk_self = $6216870F;
 tk_b = $C42D0E1E;
 tk_booleval = $885A1C3D;
 tk_internaldebug = $10B4387B;
 tk_nozeroinit = $216870F6;
 tk_zeroinit = $42D0E1EC;
 tk_virtual = $85A1C3D9;
 tk_end = $0B4387B2;
 tk_afterconstruct = $16870F64;
 tk_beforedestruct = $2D0E1EC9;
 tk_ini = $5A1C3D92;
 tk_fini = $B4387B25;
 tk_operator = $6870F64A;
 tk_operatorright = $D0E1EC95;
 tk_unit = $A1C3D92B;
 tk_program = $4387B257;
 tk_interface = $870F64AE;
 tk_implementation = $0E1EC95D;
 tk_uses = $1C3D92BB;
 tk_type = $387B2576;
 tk_const = $70F64AED;
 tk_var = $E1EC95DB;
 tk_label = $C3D92BB7;
 tk_class = $87B2576F;
 tk_procedure = $0F64AEDF;
 tk_function = $1EC95DBE;
 tk_method = $3D92BB7D;
 tk_initialization = $7B2576FA;
 tk_finalization = $F64AEDF5;
 tk_constructor = $EC95DBEB;
 tk_destructor = $D92BB7D6;
 tk_begin = $B2576FAC;
 tk_mode = $64AEDF59;
 tk_dumpelements = $C95DBEB3;
 tk_dumpopcode = $92BB7D66;
 tk_abort = $2576FACC;
 tk_stoponerror = $4AEDF598;
 tk_nop = $95DBEB31;
 tk_include = $2BB7D662;
 tk_define = $576FACC5;
 tk_undef = $AEDF598A;
 tk_ifdef = $5DBEB315;
 tk_ifndef = $BB7D662B;
 tk_if = $76FACC56;
 tk_else = $EDF598AC;
 tk_endif = $DBEB3159;
 tk_ifend = $B7D662B3;
 tk_h = $6FACC566;
 tk_inline = $DF598ACD;
 tk_on = $BEB3159B;
 tk_off = $7D662B37;
 tk_default = $FACC566E;
 tk_constref = $F598ACDD;
 tk_out = $EB3159BB;
 tk_override = $D662B376;
 tk_overload = $ACC566EC;
 tk_of = $598ACDD8;
 tk_object = $B3159BB1;
 tk_external = $662B3762;
 tk_forward = $CC566EC4;
 tk_sub = $98ACDD89;
 tk_finally = $3159BB13;
 tk_except = $62B37626;
 tk_do = $C566EC4C;
 tk_with = $8ACDD898;
 tk_case = $159BB130;
 tk_while = $2B376261;
 tk_repeat = $566EC4C3;
 tk_for = $ACDD8987;
 tk_try = $59BB130E;
 tk_raise = $B376261D;
 tk_goto = $66EC4C3A;
 tk_then = $CDD89874;
 tk_until = $9BB130E8;
 tk_to = $376261D1;
 tk_downto = $6EC4C3A3;
 tk_set = $DD898746;
 tk_record = $BB130E8C;
 tk_array = $76261D18;
 tk_private = $EC4C3A30;
 tk_protected = $D8987460;
 tk_public = $B130E8C1;
 tk_published = $6261D183;
 tk_property = $C4C3A306;
 tk_read = $8987460D;
 tk_write = $130E8C1A;
 tk_div = $261D1834;
 tk_mod = $4C3A3068;
 tk_and = $987460D0;
 tk_shl = $30E8C1A1;
 tk_shr = $61D18343;
 tk_or = $C3A30686;
 tk_xor = $87460D0D;
 tk_in = $0E8C1A1B;
 tk_not = $1D183437;
 tk_is = $3A30686F;
 tk_as = $7460D0DE;
 tk_inherited = $E8C1A1BD;

 tokens: array[0..130] of string = ('',
  '.void','.classes','.private','.protected','.public','.published',
  '.classintfname','.classintftype','.classimp','.self','.units','.ancestors',
  '.nestedvarref','.defines','.ini','.fini','.incref','.decref','.decrefindi',
  '.method','.operators','.operatorsright','.system',
  'mselang','pascal','nil','result','exitcode','sizeof','defined','break',
  'continue','self','b','booleval','internaldebug','nozeroinit','zeroinit',
  'virtual','end','afterconstruct','beforedestruct','ini','fini','operator',
  'operatorright','unit','program','interface','implementation','uses','type',
  'const','var','label','class','procedure','function','method',
  'initialization','finalization','constructor','destructor','begin','mode',
  'dumpelements','dumpopcode','abort','stoponerror','nop','include','define',
  'undef','ifdef','ifndef','if','else','endif','ifend','h','inline','on','off',
  'default','constref','out','override','overload','of','object','external',
  'forward','sub','finally','except','do','with','case','while','repeat','for',
  'try','raise','goto','then','until','to','downto','set','record','array',
  'private','protected','public','published','property','read','write','div',
  'mod','and','shl','shr','or','xor','in','not','is','as','inherited');

 tokenids: array[0..130] of identty = (
  $00000000,$4FC6E54B,$9F8DCA96,$3F1B952D,$7E372A5B,$FC6E54B6,$F8DCA96C,
  $F1B952D8,$E372A5B1,$C6E54B62,$8DCA96C4,$1B952D88,$372A5B10,$6E54B621,
  $DCA96C42,$B952D885,$72A5B10B,$E54B6216,$CA96C42D,$952D885A,$2A5B10B4,
  $54B62168,$A96C42D0,$52D885A1,$A5B10B43,$4B621687,$96C42D0E,$2D885A1C,
  $5B10B438,$B6216870,$6C42D0E1,$D885A1C3,$B10B4387,$6216870F,$C42D0E1E,
  $885A1C3D,$10B4387B,$216870F6,$42D0E1EC,$85A1C3D9,$0B4387B2,$16870F64,
  $2D0E1EC9,$5A1C3D92,$B4387B25,$6870F64A,$D0E1EC95,$A1C3D92B,$4387B257,
  $870F64AE,$0E1EC95D,$1C3D92BB,$387B2576,$70F64AED,$E1EC95DB,$C3D92BB7,
  $87B2576F,$0F64AEDF,$1EC95DBE,$3D92BB7D,$7B2576FA,$F64AEDF5,$EC95DBEB,
  $D92BB7D6,$B2576FAC,$64AEDF59,$C95DBEB3,$92BB7D66,$2576FACC,$4AEDF598,
  $95DBEB31,$2BB7D662,$576FACC5,$AEDF598A,$5DBEB315,$BB7D662B,$76FACC56,
  $EDF598AC,$DBEB3159,$B7D662B3,$6FACC566,$DF598ACD,$BEB3159B,$7D662B37,
  $FACC566E,$F598ACDD,$EB3159BB,$D662B376,$ACC566EC,$598ACDD8,$B3159BB1,
  $662B3762,$CC566EC4,$98ACDD89,$3159BB13,$62B37626,$C566EC4C,$8ACDD898,
  $159BB130,$2B376261,$566EC4C3,$ACDD8987,$59BB130E,$B376261D,$66EC4C3A,
  $CDD89874,$9BB130E8,$376261D1,$6EC4C3A3,$DD898746,$BB130E8C,$76261D18,
  $EC4C3A30,$D8987460,$B130E8C1,$6261D183,$C4C3A306,$8987460D,$130E8C1A,
  $261D1834,$4C3A3068,$987460D0,$30E8C1A1,$61D18343,$C3A30686,$87460D0D,
  $0E8C1A1B,$1D183437,$3A30686F,$7460D0DE,$E8C1A1BD);

implementation
end.