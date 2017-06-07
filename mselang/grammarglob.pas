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
 tk_nil = $A5B10B43;
 tk_result = $4B621687;
 tk_exitcode = $96C42D0E;
 tk_sizeof = $2D885A1C;
 tk_defined = $5B10B438;
 tk_break = $B6216870;
 tk_continue = $6C42D0E1;
 tk_self = $D885A1C3;
 tk_b = $B10B4387;
 tk_booleval = $6216870F;
 tk_internaldebug = $C42D0E1E;
 tk_nozeroinit = $885A1C3D;
 tk_zeroinit = $10B4387B;
 tk_virtual = $216870F6;
 tk_end = $42D0E1EC;
 tk_afterconstruct = $85A1C3D9;
 tk_beforedestruct = $0B4387B2;
 tk_ini = $16870F64;
 tk_fini = $2D0E1EC9;
 tk_operator = $5A1C3D92;
 tk_operatorright = $B4387B25;
 tk_unit = $6870F64A;
 tk_program = $D0E1EC95;
 tk_interface = $A1C3D92B;
 tk_implementation = $4387B257;
 tk_uses = $870F64AE;
 tk_type = $0E1EC95D;
 tk_const = $1C3D92BB;
 tk_var = $387B2576;
 tk_label = $70F64AED;
 tk_class = $E1EC95DB;
 tk_procedure = $C3D92BB7;
 tk_function = $87B2576F;
 tk_method = $0F64AEDF;
 tk_sub = $1EC95DBE;
 tk_initialization = $3D92BB7D;
 tk_finalization = $7B2576FA;
 tk_constructor = $F64AEDF5;
 tk_destructor = $EC95DBEB;
 tk_begin = $D92BB7D6;
 tk_dumpelements = $B2576FAC;
 tk_dumpopcode = $64AEDF59;
 tk_abort = $C95DBEB3;
 tk_stoponerror = $92BB7D66;
 tk_nop = $2576FACC;
 tk_include = $4AEDF598;
 tk_define = $95DBEB31;
 tk_undef = $2BB7D662;
 tk_ifdef = $576FACC5;
 tk_ifndef = $AEDF598A;
 tk_if = $5DBEB315;
 tk_else = $BB7D662B;
 tk_endif = $76FACC56;
 tk_ifend = $EDF598AC;
 tk_h = $DBEB3159;
 tk_mode = $B7D662B3;
 tk_inline = $6FACC566;
 tk_on = $DF598ACD;
 tk_off = $BEB3159B;
 tk_default = $7D662B37;
 tk_constref = $FACC566E;
 tk_out = $F598ACDD;
 tk_override = $EB3159BB;
 tk_overload = $D662B376;
 tk_of = $ACC566EC;
 tk_object = $598ACDD8;
 tk_external = $B3159BB1;
 tk_forward = $662B3762;
 tk_finally = $CC566EC4;
 tk_except = $98ACDD89;
 tk_do = $3159BB13;
 tk_with = $62B37626;
 tk_case = $C566EC4C;
 tk_while = $8ACDD898;
 tk_repeat = $159BB130;
 tk_for = $2B376261;
 tk_try = $566EC4C3;
 tk_raise = $ACDD8987;
 tk_goto = $59BB130E;
 tk_then = $B376261D;
 tk_until = $66EC4C3A;
 tk_to = $CDD89874;
 tk_downto = $9BB130E8;
 tk_set = $376261D1;
 tk_record = $6EC4C3A3;
 tk_array = $DD898746;
 tk_private = $BB130E8C;
 tk_protected = $76261D18;
 tk_public = $EC4C3A30;
 tk_published = $D8987460;
 tk_property = $B130E8C1;
 tk_read = $6261D183;
 tk_write = $C4C3A306;
 tk_div = $8987460D;
 tk_mod = $130E8C1A;
 tk_and = $261D1834;
 tk_shl = $4C3A3068;
 tk_shr = $987460D0;
 tk_or = $30E8C1A1;
 tk_xor = $61D18343;
 tk_in = $C3A30686;
 tk_not = $87460D0D;
 tk_is = $0E8C1A1B;
 tk_as = $1D183437;
 tk_inherited = $3A30686F;

 tokens: array[0..128] of string = ('',
  '.void','.classes','.private','.protected','.public','.published',
  '.classintfname','.classintftype','.classimp','.self','.units','.ancestors',
  '.nestedvarref','.defines','.ini','.fini','.incref','.decref','.decrefindi',
  '.method','.operators','.operatorsright','.system',
  'nil','result','exitcode','sizeof','defined','break','continue','self','b',
  'booleval','internaldebug','nozeroinit','zeroinit','virtual','end',
  'afterconstruct','beforedestruct','ini','fini','operator','operatorright',
  'unit','program','interface','implementation','uses','type','const','var',
  'label','class','procedure','function','method','sub','initialization',
  'finalization','constructor','destructor','begin','dumpelements','dumpopcode',
  'abort','stoponerror','nop','include','define','undef','ifdef','ifndef','if',
  'else','endif','ifend','h','mode','inline','on','off','default','constref',
  'out','override','overload','of','object','external','forward','finally',
  'except','do','with','case','while','repeat','for','try','raise','goto',
  'then','until','to','downto','set','record','array','private','protected',
  'public','published','property','read','write','div','mod','and','shl','shr',
  'or','xor','in','not','is','as','inherited');

 tokenids: array[0..128] of identty = (
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
  $0E8C1A1B,$1D183437,$3A30686F);

implementation
end.