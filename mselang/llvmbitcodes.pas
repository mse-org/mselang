//===- LLVMBitCodes.h - Enum values for the LLVM bitcode format -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This header defines Bitcode enum values for LLVM IR bitcode files.
//
// The enum values defined in this file should be considered permanent.  If
// new features are added, they should have values added at the end of the
// respective lists.
//
//===----------------------------------------------------------------------===//

{ MSElang Copyright (c) 2014 by Martin Schreiber
   
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

unit llvmbitcodes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

type
  StandardWidths = (
    CodeLenWidth   = 4,  // Codelen are VBR-4.
    BlockIDWidth   = 8,  // We use VBR-8 for block IDs.
    BlockSizeWidth = 32  // BlockSize up to 2^32 32-bit words = 16GB per block.
  );

  // The standard abbrev namespace always has a way to exit a block, enter a
  // nested block, define abbrevs, and define an unabbreviated record.
  FixedAbbrevIDs = (
    END_BLOCK = 0,  // Must be zero to guarantee termination for broken bitcode.
    ENTER_SUBBLOCK = 1,

    /// DEFINE_ABBREV - Defines an abbrev for the current block.  It consists
    /// of a vbr5 for # operand infos.  Each operand info is emitted with a
    /// single bit to indicate if it is a literal encoding.  If so, the value is
    /// emitted with a vbr8.  If not, the encoding is emitted as 3 bits followed
    /// by the info value as a vbr5 if needed.
    DEFINE_ABBREV = 2,

    // UNABBREV_RECORDs are emitted with a vbr6 for the record code, followed by
    // a vbr6 for the # operands, followed by vbr6's for each operand.
    UNABBREV_RECORD = 3,

    // This is not a code, this is a marker for the first abbrev assignment.
    FIRST_APPLICATION_ABBREV = 4
  );
{
  /// StandardBlockIDs - All bitcode files can optionally include a BLOCKINFO
  /// block, which contains metadata about other blocks in the file.
  StandardBlockIDs = (
    /// BLOCKINFO_BLOCK is used to define metadata about blocks, for example,
    /// standard abbrevs that should be available to all blocks of a specified
    /// ID.
    BLOCKINFO_BLOCK_ID = 0,

    // Block IDs 1-7 are reserved for future expansion.
    FIRST_APPLICATION_BLOCKID = 8
  );
}
  /// BlockInfoCodes - The blockinfo block contains metadata about user-defined
  /// blocks.
  BlockInfoCodes = (
    // DEFINE_ABBREV has magic semantics here, applying to the current SETBID'd
    // block, instead of the BlockInfo block.

    BLOCKINFO_CODE_SETBID        = 1, // SETBID: [blockid#]
    BLOCKINFO_CODE_BLOCKNAME     = 2, // BLOCKNAME: [name]
    BLOCKINFO_CODE_SETRECORDNAME = 3  // BLOCKINFO_CODE_SETRECORDNAME:
                                      //                             [id, name]
  );

  // The only top-level block type defined is for a module.
  BlockIDs = (
    /// BLOCKINFO_BLOCK is used to define metadata about blocks, for example,
    /// standard abbrevs that should be available to all blocks of a specified
    /// ID.
    BLOCKINFO_BLOCK_ID,// = 0,
    BLOCK_1,
    BLOCK_2,
    BLOCK_3,
    BLOCK_4,
    BLOCK_5,
    BLOCK_6,
    BLOCK_7,

    // Block IDs 1-7 are reserved for future expansion.
//    FIRST_APPLICATION_BLOCKID = 8,

    // Blocks
    MODULE_BLOCK_ID,//          = 8, //FIRST_APPLICATION_BLOCKID,

    // Module sub-block id's.
    PARAMATTR_BLOCK_ID,          //9
    PARAMATTR_GROUP_BLOCK_ID,    //10

    CONSTANTS_BLOCK_ID,          //11
    FUNCTION_BLOCK_ID,           //12

    UNUSED_ID1,                  //13

    VALUE_SYMTAB_BLOCK_ID,       //14
    METADATA_BLOCK_ID,           //15
    METADATA_ATTACHMENT_ID,      //16

    TYPE_BLOCK_ID_NEW,           //17

    USELIST_BLOCK_ID             //18
  );


  /// MODULE blocks have a number of optional fields and subblocks.
  ModuleCodes = (
    MODULE_CODE_0,
    MODULE_CODE_VERSION,//     = 1,    // VERSION:     [version#]
    MODULE_CODE_TRIPLE,//      = 2,    // TRIPLE:      [strchr x N]
    MODULE_CODE_DATALAYOUT,//  = 3,    // DATALAYOUT:  [strchr x N]
    MODULE_CODE_ASM,//         = 4,    // ASM:         [strchr x N]
    MODULE_CODE_SECTIONNAME,// = 5,    // SECTIONNAME: [strchr x N]

    // FIXME: Remove DEPLIB in 4.0.
    MODULE_CODE_DEPLIB,//      = 6,    // DEPLIB:      [strchr x N]

    // GLOBALVAR: [pointer type, isconst, initid,
    //             linkage, alignment, section, visibility, threadlocal]
    MODULE_CODE_GLOBALVAR,//   = 7,

    // FUNCTION:  [type, callingconv, isproto, linkage, paramattrs, alignment,
    //             section, visibility, gc, unnamed_addr]
    MODULE_CODE_FUNCTION,//    = 8,

    // ALIAS: [alias type, aliasee val#, linkage, visibility]
    MODULE_CODE_ALIAS,//       = 9,

    // MODULE_CODE_PURGEVALS: [numvals]
    MODULE_CODE_PURGEVALS,//   = 10,

    MODULE_CODE_GCNAME,//      = 11,  // GCNAME: [strchr x N]
    MODULE_CODE_COMDAT//      = 12   // COMDAT: [selection_kind, name]
  );

  /// PARAMATTR blocks have code for defining a parameter attribute set.
  AttributeCodes = (
    // FIXME: Remove `PARAMATTR_CODE_ENTRY_OLD' in 4.0
    PARAMATTR_CODE_ENTRY_OLD  = 1, // ENTRY: [paramidx0, attr0,
                                   //         paramidx1, attr1...]
    PARAMATTR_CODE_ENTRY      = 2, // ENTRY: [paramidx0, attrgrp0,
                                   //         paramidx1, attrgrp1, ...]
    PARAMATTR_GRP_CODE_ENTRY  = 3  // ENTRY: [id, attr0, att1, ...]
  );

  /// TYPE blocks have codes for each type primitive they use.
  TypeCodes = (
    TYPE_CODE_0,
    TYPE_CODE_NUMENTRY,// =  1,    // NUMENTRY: [numentries]

    // Type Codes
    TYPE_CODE_VOID,//     =  2,    // VOID
    TYPE_CODE_FLOAT,//    =  3,    // FLOAT
    TYPE_CODE_DOUBLE,//   =  4,    // DOUBLE
    TYPE_CODE_LABEL,//    =  5,    // LABEL
    TYPE_CODE_OPAQUE,//   =  6,    // OPAQUE
    TYPE_CODE_INTEGER,//  =  7,    // INTEGER: [width]
    TYPE_CODE_POINTER,//  =  8,    // POINTER: [pointee type]

    TYPE_CODE_FUNCTION_OLD,// = 9, // FUNCTION: [vararg, attrid, retty,
                                //            paramty x N]

    TYPE_CODE_HALF,//     =  10,   // HALF

    TYPE_CODE_ARRAY,//    = 11,    // ARRAY: [numelts, eltty]
    TYPE_CODE_VECTOR,//   = 12,    // VECTOR: [numelts, eltty]

    // These are not with the other floating point types because they're
    // a late addition, and putting them in the right place breaks
    // binary compatibility.
    TYPE_CODE_X86_FP80,// = 13,    // X86 LONG DOUBLE
    TYPE_CODE_FP128,//    = 14,    // LONG DOUBLE (112 bit mantissa)
    TYPE_CODE_PPC_FP128,//= 15,    // PPC LONG DOUBLE (2 doubles)

    TYPE_CODE_METADATA,// = 16,    // METADATA

    TYPE_CODE_X86_MMX,// = 17,     // X86 MMX

    TYPE_CODE_STRUCT_ANON,// = 18, // STRUCT_ANON: [ispacked, eltty x N]
    TYPE_CODE_STRUCT_NAME,// = 19, // STRUCT_NAME: [strchr x N]
    TYPE_CODE_STRUCT_NAMED,// = 20,// STRUCT_NAMED: [ispacked, eltty x N]

    TYPE_CODE_FUNCTION// = 21     // FUNCTION: [vararg, retty, paramty x N]
  );

  // The type symbol table only has one code (TST_ENTRY_CODE).
  TypeSymtabCodes = (
    TST_CODE_ENTRY = 1     // TST_ENTRY: [typeid, namechar x N]
  );

  // The value symbol table only has one code (VST_ENTRY_CODE).
  ValueSymtabCodes = (
    VST_CODE_0,
    VST_CODE_ENTRY,//   = 1,  // VST_ENTRY: [valid, namechar x N]
    VST_CODE_BBENTRY// = 2   // VST_BBENTRY: [bbid, namechar x N]
  );

  MetadataCodes = (
    METADATA_0,
    METADATA_STRING,//        = 1,   // MDSTRING:      [values]
    METADATA_2,    // 2 is unused.
    METADATA_3,    // 3 is unused.
    METADATA_NAME,//          = 4,   // STRING:        [values]
    METADATA_5,   // 5 is unused.
    METADATA_KIND,//          = 6,   // [n x [id, name]]
    METADATA_7,    // 7 is unused.
    METADATA_NODE,//        = 8,   // NODE:          [n x (type num, value num)]
    METADATA_FN_NODE,//     = 9,   // FN_NODE:       [n x (type num, value num)]
    METADATA_NAMED_NODE,//    = 10,  // NAMED_NODE:    [n x mdnodes]
    METADATA_ATTACHMENT //    = 11   // [m x [value, [n x [id, mdnode]]]
  );

  // The constants block (CONSTANTS_BLOCK_ID) describes emission for each
  // constant and maintains an implicit current type value.
  ConstantsCodes = (
    CST_CODE_0,
    CST_CODE_SETTYPE,//       =  1,  // SETTYPE:       [typeid]
    CST_CODE_NULL,//          =  2,  // NULL
    CST_CODE_UNDEF,//         =  3,  // UNDEF
    CST_CODE_INTEGER,//       =  4,  // INTEGER:       [intval]
    CST_CODE_WIDE_INTEGER,//  =  5,  // WIDE_INTEGER:  [n x intval]
    CST_CODE_FLOAT,//         =  6,  // FLOAT:         [fpval]
    CST_CODE_AGGREGATE,//     =  7,  // AGGREGATE:     [n x value number]
    CST_CODE_STRING,//        =  8,  // STRING:        [values]
    CST_CODE_CSTRING,//       =  9,  // CSTRING:       [values]
    CST_CODE_CE_BINOP,//      = 10,  // CE_BINOP:      [opcode, opval, opval]
    CST_CODE_CE_CAST,//       = 11,  // CE_CAST:       [opcode, opty, opval]
    CST_CODE_CE_GEP,//        = 12,  // CE_GEP:        [n x operands]
    CST_CODE_CE_SELECT,//     = 13,  // CE_SELECT:     [opval, opval, opval]
    CST_CODE_CE_EXTRACTELT,// = 14,  // CE_EXTRACTELT: [opty, opval, opval]
    CST_CODE_CE_INSERTELT,//  = 15,  // CE_INSERTELT:  [opval, opval, opval]
    CST_CODE_CE_SHUFFLEVEC,// = 16,  // CE_SHUFFLEVEC: [opval, opval, opval]
    CST_CODE_CE_CMP,//        = 17,  // CE_CMP:        [opty, opval, opval, pred]
    CST_CODE_INLINEASM_OLD,// = 18,  // INLINEASM:     [sideeffect|alignstack,
                                  //                 asmstr,conststr]
    CST_CODE_CE_SHUFVEC_EX,// = 19,  // SHUFVEC_EX:    [opty, opval, opval, opval]
    CST_CODE_CE_INBOUNDS_GEP,// = 20,// INBOUNDS_GEP:  [n x operands]
    CST_CODE_BLOCKADDRESS,//  = 21,  // CST_CODE_BLOCKADDRESS [fnty, fnval, bb#]
    CST_CODE_DATA,//          = 22,  // DATA:          [n x elements]
    CST_CODE_INLINEASM//      = 23   // INLINEASM:     [sideeffect|alignstack|
                                  //                 asmdialect,asmstr,conststr]
  );

  /// CastOpcodes - These are values used in the bitcode files to encode which
  /// cast a CST_CODE_CE_CAST or a XXX refers to.  The values of these enums
  /// have no fixed relation to the LLVM IR enum values.  Changing these will
  /// break compatibility with old files.
  CastOpcodes = (
    CAST_TRUNC,//    =  0,
    CAST_ZEXT,//     =  1,
    CAST_SEXT,//     =  2,
    CAST_FPTOUI,//   =  3,
    CAST_FPTOSI,//   =  4,
    CAST_UITOFP,//   =  5,
    CAST_SITOFP,//   =  6,
    CAST_FPTRUNC,//  =  7,
    CAST_FPEXT,//    =  8,
    CAST_PTRTOINT,// =  9,
    CAST_INTTOPTR,// = 10,
    CAST_BITCAST//  = 11
  );

  /// BinaryOpcodes - These are values used in the bitcode files to encode which
  /// binop a CST_CODE_CE_BINOP or a XXX refers to.  The values of these enums
  /// have no fixed relation to the LLVM IR enum values.  Changing these will
  /// break compatibility with old files.
  BinaryOpcodes  = (
    BINOP_ADD,//  =  0,
    BINOP_SUB,//  =  1,
    BINOP_MUL,//  =  2,
    BINOP_UDIV,// =  3,
    BINOP_SDIV,// =  4,    // overloaded for FP
    BINOP_UREM,// =  5,
    BINOP_SREM,// =  6,    // overloaded for FP
    BINOP_SHL,//  =  7,
    BINOP_LSHR,// =  8,
    BINOP_ASHR,// =  9,
    BINOP_AND,//  = 10,
    BINOP_OR,//   = 11,
    BINOP_XOR//  = 12
  );

  /// These are values used in the bitcode files to encode AtomicRMW operations.
  /// The values of these enums have no fixed relation to the LLVM IR enum
  /// values.  Changing these will break compatibility with old files.
  RMWOperations = (
    RMW_XCHG = 0,
    RMW_ADD = 1,
    RMW_SUB = 2,
    RMW_AND = 3,
    RMW_NAND = 4,
    RMW_OR = 5,
    RMW_XOR = 6,
    RMW_MAX = 7,
    RMW_MIN = 8,
    RMW_UMAX = 9,
    RMW_UMIN = 10
  );

  /// OverflowingBinaryOperatorOptionalFlags - Flags for serializing
  /// OverflowingBinaryOperator's SubclassOptionalData contents.
  OverflowingBinaryOperatorOptionalFlags = (
    OBO_NO_UNSIGNED_WRAP = 0,
    OBO_NO_SIGNED_WRAP = 1
  );

  /// PossiblyExactOperatorOptionalFlags - Flags for serializing
  /// PossiblyExactOperator's SubclassOptionalData contents.
  PossiblyExactOperatorOptionalFlags = (
    PEO_EXACT = 0
  );

  /// Encoded AtomicOrdering values.
  AtomicOrderingCodes = (
    ORDERING_NOTATOMIC = 0,
    ORDERING_UNORDERED = 1,
    ORDERING_MONOTONIC = 2,
    ORDERING_ACQUIRE = 3,
    ORDERING_RELEASE = 4,
    ORDERING_ACQREL = 5,
    ORDERING_SEQCST = 6
  );

  /// Encoded SynchronizationScope values.
  AtomicSynchScopeCodes = (
    SYNCHSCOPE_SINGLETHREAD = 0,
    SYNCHSCOPE_CROSSTHREAD = 1
  );

  // The function body block (FUNCTION_BLOCK_ID) describes function bodies.  It
  // can contain a constant block (CONSTANTS_BLOCK_ID).
  FunctionCodes = (
    FUNC_CODE_0,
    FUNC_CODE_DECLAREBLOCKS,//    =  1, // DECLAREBLOCKS: [n]

    FUNC_CODE_INST_BINOP,//       =  2, // BINOP:      [opcode, ty, opval, opval]
                                 //mse: BINOP:      [opval, opval, opcode]
    FUNC_CODE_INST_CAST,//        =  3, // CAST:       [opcode, ty, opty, opval]
                                 //mse: CAST:       [opval, destty, castopcode]
    FUNC_CODE_INST_GEP,//         =  4, // GEP:        [n x operands]
    FUNC_CODE_INST_SELECT,//      =  5, // SELECT:     [ty, opval, opval, opval]
    FUNC_CODE_INST_EXTRACTELT,//  =  6, // EXTRACTELT: [opty, opval, opval]
    FUNC_CODE_INST_INSERTELT,//   =  7, // INSERTELT:  [ty, opval, opval, opval]
    FUNC_CODE_INST_SHUFFLEVEC,//  =  8, // SHUFFLEVEC: [ty, opval, opval, opval]
    FUNC_CODE_INST_CMP,//         =  9, // CMP:        [opty, opval, opval, pred]
                                 //mse: CMP:       [opval, opval, pred]

    FUNC_CODE_INST_RET,//         = 10, // RET:        [opty,opval<both optional>]
                        //mse:       // RET:        [opval<optional>]
    FUNC_CODE_INST_BR,//          = 11, // BR:         [bb#, bb#, cond] or [bb#]
    FUNC_CODE_INST_SWITCH,//      = 12, // SWITCH:     [opty, op0, op1, ...]
    FUNC_CODE_INST_INVOKE,//      = 13,
          // INVOKE:     [attr, fnty, op0,op1, ...]
          //mse INVOKE: [paramattrs, cc, normBB, unwindBB, fnid, arg0,arg1, ...]

    FUNC_CODE_14,
    // 14 is unused.
    FUNC_CODE_INST_UNREACHABLE,// = 15, // UNREACHABLE

    FUNC_CODE_INST_PHI,//         = 16, // PHI:        [ty, val0,bb0, ...]
    FUNC_CODE_17,
    // 17 is unused.
    FUNC_CODE_18,
    // 18 is unused.
    FUNC_CODE_INST_ALLOCA,//      = 19, // ALLOCA:     [instty, op, align]
                          //mse: ALLOCA ^type,memtype,memcount,align/inalloca
    FUNC_CODE_INST_LOAD,//        = 20, // LOAD:       [opty, op, align, vol]
                                 //mse: LOAD:       [op, align, vol]
    FUNC_CODE_21,
    // 21 is unused.
    FUNC_CODE_22,
    // 22 is unused.
    FUNC_CODE_INST_VAARG,//       = 23, // VAARG:      [valistty, valist, instty]
    // This store code encodes the pointer type, rather than the value type
    // this is so information only available in the pointer type (e.g. address
    // spaces) is retained.
    FUNC_CODE_INST_STORE,//       = 24, // STORE:      [ptrty,ptr,val, align, vol]
                                 //mse: STORE:      [ptr,val, align, vol]
    FUNC_CODE_25,
    // 25 is unused.
    FUNC_CODE_INST_EXTRACTVAL,//  = 26, // EXTRACTVAL: [n x operands]
    FUNC_CODE_INST_INSERTVAL,//   = 27, // INSERTVAL:  [n x operands]
    // fcmp/icmp returning Int1TY or vector of Int1Ty. Same as CMP, exists to
    // support legacy vicmp/vfcmp instructions.
    FUNC_CODE_INST_CMP2,//        = 28, // CMP2:       [opty, opval, opval, pred]
                                 //mse: CMP2:       [opval, opval, pred]
    // new select on i1 or [N x i1]
    FUNC_CODE_INST_VSELECT,//     = 29, // VSELECT:    [ty,opval,opval,predty,pred]
    FUNC_CODE_INST_INBOUNDS_GEP,//= 30, // INBOUNDS_GEP: [n x operands]
    FUNC_CODE_INST_INDIRECTBR,//  = 31, // INDIRECTBR: [opty, op0, op1, ...]
    FUNC_CODE_32,
    // 32 is unused.
    FUNC_CODE_DEBUG_LOC_AGAIN,//  = 33, // DEBUG_LOC_AGAIN

    FUNC_CODE_INST_CALL,//        = 34, // CALL:       [attr, fnty, fnid, args...]
                             //mse: CALL: [paramattrs, cc, fnid, arg0, arg1...]
    FUNC_CODE_DEBUG_LOC,//        = 35, // DEBUG_LOC:  [Line,Col,ScopeVal, IAVal]
    FUNC_CODE_INST_FENCE,//       = 36, // FENCE: [ordering, synchscope]
    FUNC_CODE_INST_CMPXCHG,//     = 37, 
                           // CMPXCHG: [ptrty,ptr,cmp,new, align, vol,
                                     //           ordering, synchscope]
    FUNC_CODE_INST_ATOMICRMW,//   = 38, // ATOMICRMW: [ptrty,ptr,val, operation,
                                     //             align, vol,
                                     //             ordering, synchscope]
    FUNC_CODE_INST_RESUME,//      = 39, // RESUME:     [opval]
    FUNC_CODE_INST_LANDINGPAD,//  = 40, 
     // LANDINGPAD: [ty,val,val,num,id0,val0...]
     //mse: LANDINGPAD: 
     //         [resultty,PersFn,IsCleanup,NumClauses,
     //                   {lpc_catch,GlobVal|lpc_filter,GlobArray}]
    FUNC_CODE_INST_LOADATOMIC,//  = 41, // LOAD: [opty, op, align, vol,
                                     //        ordering, synchscope]
    FUNC_CODE_INST_STOREATOMIC// = 42  // STORE: [ptrty,ptr,val, align, vol
                                     //         ordering, synchscope]
  );

  UseListCodes = (
    USELIST_CODE_ENTRY = 1   // USELIST_CODE_ENTRY: TBD.
  );


//mse

 landingpadclausety = (
  lpc_catch,
  lpc_filter
 );
 
 callingconvty = (
  cv_ccc = 0,
  cv_fastcc = 8,
  cv_coldcc = 9,
  cv_webkit_jscc = 12,
  cv_anyregcc = 13,
  cv_preserve_mostcc = 14,
  cv_preserve_allcc = 15,
  cv_x86_stdcallcc = 64,
  cv_x86_fastcallcc = 65,
  cv_arm_apcscc = 66,
  cv_arm_aapcscc = 67,
  cv_arm_aapcs_vfpcc = 68
 );
 
 linkagety = (
  li_external = 0,
  li_weak = 1,
  li_appending = 2,
  li_internal = 3,
  li_linkonce = 4,
  li_dllimport = 5,
  li_dllexport = 6,
  li_extern_weak = 7,
  li_common = 8,
  li_private = 9,
  li_weak_odr = 10,
  li_linkonce_odr = 11,
  li_available_externally = 12
 );
 
 visibilityty = (
  vi_default = 0,
  vi_hidden = 1,
  vi_protected = 2
 );

 dllstorageclassty = (
  ds_default = 0,
  ds_dllimport = 1,
  ds_dllexport = 2
 );

 Predicate = (
  // Opcode              U L G E    Intuitive operation
  FCMP_FALSE,// =  0,  ///< 0 0 0 0    Always false (always folded)
  FCMP_OEQ,//   =  1,  ///< 0 0 0 1    True if ordered and equal
  FCMP_OGT,//   =  2,  ///< 0 0 1 0    True if ordered and greater than
  FCMP_OGE,//   =  3,  ///< 0 0 1 1    True if ordered and greater than or equal
  FCMP_OLT,//   =  4,  ///< 0 1 0 0    True if ordered and less than
  FCMP_OLE,//   =  5,  ///< 0 1 0 1    True if ordered and less than or equal
  FCMP_ONE,//   =  6,  ///< 0 1 1 0    True if ordered and operands are unequal
  FCMP_ORD,//   =  7,  ///< 0 1 1 1    True if ordered (no nans)
  FCMP_UNO,//   =  8,  ///< 1 0 0 0    True if unordered: isnan(X) | isnan(Y)
  FCMP_UEQ,//   =  9,  ///< 1 0 0 1    True if unordered or equal
  FCMP_UGT,//   = 10,  ///< 1 0 1 0    True if unordered or greater than
  FCMP_UGE,//   = 11,  ///< 1 0 1 1    True if unordered, greater than, or equal
  FCMP_ULT,//   = 12,  ///< 1 1 0 0    True if unordered or less than
  FCMP_ULE,//   = 13,  ///< 1 1 0 1    True if unordered, less than, or equal
  FCMP_UNE,//   = 14,  ///< 1 1 1 0    True if unordered or not equal
  FCMP_TRUE,//  = 15,  ///< 1 1 1 1    Always true (always folded)
  FCMP_16,
  FCMP_17,
  FCMP_18,
  FCMP_19,
  FCMP_20,
  FCMP_21,
  FCMP_22,
  FCMP_23,
  FCMP_24,
  FCMP_25,
  FCMP_26,
  FCMP_27,
  FCMP_28,
  FCMP_29,
  FCMP_30,
  FCMP_31,
{
  FIRST_FCMP_PREDICATE = FCMP_FALSE,
  LAST_FCMP_PREDICATE = FCMP_TRUE,
  BAD_FCMP_PREDICATE = ord(FCMP_TRUE) + 1,
}
  ICMP_EQ,//    = 32,  ///< equal
  ICMP_NE,//    = 33,  ///< not equal
  ICMP_UGT,//   = 34,  ///< unsigned greater than
  ICMP_UGE,//   = 35,  ///< unsigned greater or equal
  ICMP_ULT,//   = 36,  ///< unsigned less than
  ICMP_ULE,//   = 37,  ///< unsigned less or equal
  ICMP_SGT,//   = 38,  ///< signed greater than
  ICMP_SGE,//   = 39,  ///< signed greater or equal
  ICMP_SLT,//   = 40,  ///< signed less than
  ICMP_SLE//   = 41,  ///< signed less or equal
{
  FIRST_ICMP_PREDICATE = ICMP_EQ,
  LAST_ICMP_PREDICATE = ICMP_SLE,
  BAD_ICMP_PREDICATE = ord(ICMP_SLE) + 1
}
 );

const
  FIRST_FCMP_PREDICATE = FCMP_FALSE;
  LAST_FCMP_PREDICATE = FCMP_TRUE;
  BAD_FCMP_PREDICATE = predicate(ord(FCMP_TRUE) + 1);
  FIRST_ICMP_PREDICATE = ICMP_EQ;
  LAST_ICMP_PREDICATE = ICMP_SLE;
  BAD_ICMP_PREDICATE = predicate(ord(ICMP_SLE) + 1);

//
// llvm version 3.5.1
//
//from llvm/include/llvm/IR/Module.h
type
  ModFlagBehavior = (
    /// Emits an error if two values disagree, otherwise the resulting value is
    /// that of the operands.
    mfb_Error = 1,

    /// Emits a warning if two values disagree. The result value will be the
    /// operand for the flag from the first module being linked.
    mfb_Warning = 2,

    /// Adds a requirement that another module flag be present and have a
    /// specified value after linking is performed. The value must be a metadata
    /// pair, where the first element of the pair is the ID of the module flag
    /// to be restricted, and the second element of the pair is the value the
    /// module flag should be restricted to. This behavior can be used to
    /// restrict the allowable results (via triggering of an error) of linking
    /// IDs with the **Override** behavior.
    mfb_Require = 3,

    /// Uses the specified value, regardless of the behavior or value of the
    /// other module. If both modules specify **Override**, but the values
    /// differ, an error will be emitted.
    mfb_Override = 4,

    /// Appends the two values, which are required to be metadata nodes.
    mfb_Append = 5,

    /// Appends the two values, which are required to be metadata
    /// nodes. However, duplicate entries in the second list are dropped
    /// during the append operation.
    mfb_AppendUnique = 6
  );

const

//from llvm/include/llvm/IR/Metadata.h
 DEBUG_METADATA_VERSION = 1;  // Current debug info version number.

//from llvm/Support/Dwarf.h

 //LLVMConstants
  // llvm mock tags
  DW_TAG_invalid = -1; // Tag for invalid results.

  DW_TAG_auto_variable = $100; // Tag for local (auto) variables.
  DW_TAG_arg_variable = $101;  // Tag for argument variables.

  DW_TAG_user_base = $1000; // Recommended base for user tags.

  DWARF_VERSION = 4;       // Default dwarf version we output.
  DW_PUBTYPES_VERSION = 2; // Section version number for .debug_pubtypes.
  DW_PUBNAMES_VERSION = 2; // Section version number for .debug_pubnames.
  DW_ARANGES_VERSION = 2;   // Section version number for .debug_aranges.

  //llvm debug version
  LLVMDebugVersion = (12 shl 16);    // Current version of debug information.
  LLVMDebugVersion11 = (11 shl 16);  // Constant for version 11.
  LLVMDebugVersion10 = (10 shl 16);  // Constant for version 10.
  LLVMDebugVersion9 = (9 shl 16);    // Constant for version 9.
  LLVMDebugVersion8 = (8 shl 16);    // Constant for version 8.
  LLVMDebugVersion7 = (7 shl 16);    // Constant for version 7.
  LLVMDebugVersion6 = (6 shl 16);    // Constant for version 6.
  LLVMDebugVersion5 = (5 shl 16);    // Constant for version 5.
  LLVMDebugVersion4 = (4 shl 16);    // Constant for version 4.
  LLVMDebugVersionMask = $ffff0000;  // Mask for version number.

  //tags
  DW_TAG_array_type = $01;
  DW_TAG_class_type = $02;
  DW_TAG_entry_point = $03;
  DW_TAG_enumeration_type = $04;
  DW_TAG_formal_parameter = $05;
  DW_TAG_imported_declaration = $08;
  DW_TAG_label = $0a;
  DW_TAG_lexical_block = $0b;
  DW_TAG_member = $0d;
  DW_TAG_pointer_type = $0f;
  DW_TAG_reference_type = $10;
  DW_TAG_compile_unit = $11;
  DW_TAG_string_type = $12;
  DW_TAG_structure_type = $13;
  DW_TAG_subroutine_type = $15;
  DW_TAG_typedef = $16;
  DW_TAG_union_type = $17;
  DW_TAG_unspecified_parameters = $18;
  DW_TAG_variant = $19;
  DW_TAG_common_block = $1a;
  DW_TAG_common_inclusion = $1b;
  DW_TAG_inheritance = $1c;
  DW_TAG_inlined_subroutine = $1d;
  DW_TAG_module = $1e;
  DW_TAG_ptr_to_member_type = $1f;
  DW_TAG_set_type = $20;
  DW_TAG_subrange_type = $21;
  DW_TAG_with_stmt = $22;
  DW_TAG_access_declaration = $23;
  DW_TAG_base_type = $24;
  DW_TAG_catch_block = $25;
  DW_TAG_const_type = $26;
  DW_TAG_constant = $27;
  DW_TAG_enumerator = $28;
  DW_TAG_file_type = $29;
  DW_TAG_friend = $2a;
  DW_TAG_namelist = $2b;
  DW_TAG_namelist_item = $2c;
  DW_TAG_packed_type = $2d;
  DW_TAG_subprogram = $2e;
  DW_TAG_template_type_parameter = $2f;
  DW_TAG_template_value_parameter = $30;
  DW_TAG_thrown_type = $31;
  DW_TAG_try_block = $32;
  DW_TAG_variant_part = $33;
  DW_TAG_variable = $34;
  DW_TAG_volatile_type = $35;
  DW_TAG_dwarf_procedure = $36;
  DW_TAG_restrict_type = $37;
  DW_TAG_interface_type = $38;
  DW_TAG_namespace = $39;
  DW_TAG_imported_module = $3a;
  DW_TAG_unspecified_type = $3b;
  DW_TAG_partial_unit = $3c;
  DW_TAG_imported_unit = $3d;
  DW_TAG_condition = $3f;
  DW_TAG_shared_type = $40;
  DW_TAG_type_unit = $41;
  DW_TAG_rvalue_reference_type = $42;
  DW_TAG_template_alias = $43;

  // New in DWARF 5:
  DW_TAG_coarray_type = $44;
  DW_TAG_generic_subrange = $45;
  DW_TAG_dynamic_type = $46;

  DW_TAG_MIPS_loop = $4081;
  DW_TAG_format_label = $4101;
  DW_TAG_function_template = $4102;
  DW_TAG_class_template = $4103;
  DW_TAG_GNU_template_template_param = $4106;
  DW_TAG_GNU_template_parameter_pack = $4107;
  DW_TAG_GNU_formal_parameter_pack = $4108;
  DW_TAG_lo_user = $4080;
  DW_TAG_APPLE_property = $4200;
  DW_TAG_hi_user = $ffff;

  // Language names
  DW_LANG_C89 = $0001;
  DW_LANG_C = $0002;
  DW_LANG_Ada83 = $0003;
  DW_LANG_C_plus_plus = $0004;
  DW_LANG_Cobol74 = $0005;
  DW_LANG_Cobol85 = $0006;
  DW_LANG_Fortran77 = $0007;
  DW_LANG_Fortran90 = $0008;
  DW_LANG_Pascal83 = $0009;
  DW_LANG_Modula2 = $000a;
  DW_LANG_Java = $000b;
  DW_LANG_C99 = $000c;
  DW_LANG_Ada95 = $000d;
  DW_LANG_Fortran95 = $000e;
  DW_LANG_PLI = $000f;
  DW_LANG_ObjC = $0010;
  DW_LANG_ObjC_plus_plus = $0011;
  DW_LANG_UPC = $0012;
  DW_LANG_D = $0013;
  // New in DWARF 5:
  DW_LANG_Python = $0014;
  DW_LANG_OpenCL = $0015;
  DW_LANG_Go = $0016;
  DW_LANG_Modula3 = $0017;
  DW_LANG_Haskell = $0018;
  DW_LANG_C_plus_plus_03 = $0019;
  DW_LANG_C_plus_plus_11 = $001a;
  DW_LANG_OCaml = $001b;

  DW_LANG_lo_user = $8000;
  DW_LANG_Mips_Assembler = $8001;
  DW_LANG_hi_user = $ffff;

{DI* metadata nodes from llvm/IR/DebugInfo.h, llvm/lib/IR/DebugInfo.cpp}

//first field is (LLVMDebugVersion or DW_TAG_*)                         //0
//DIScope
(*
  StringRef getName() const;
  StringRef getFilename() const;                -+combined to subnode   //1
  StringRef getDirectory() const;               -+                       
*)

// DICompileUnit(DIScope)
(*
  dwarf::SourceLanguage getLanguage() const {
    return static_cast<dwarf::SourceLanguage>(getUnsignedField(2));     //2
  }
  StringRef getProducer() const { return getStringField(3); }           //3

  bool isOptimized() const { return getUnsignedField(4) != 0; }         //4
  StringRef getFlags() const { return getStringField(5); }              //5
  unsigned getRunTimeVersion() const { return getUnsignedField(6); }    //6

  DIArray getEnumTypes() const;                                         //7
  DIArray getRetainedTypes() const;                                     //8
  DIArray getSubprograms() const;                                       //9
  DIArray getGlobalVariables() const;                                   //10
  DIArray getImportedEntities() const;                                  //11

  StringRef getSplitDebugFilename() const { return getStringField(12); }//12
  unsigned getEmissionKind() const { return getUnsignedField(13); }     //13
*)

//DIType(DIScope)

(*
protected:
  friend class DIDescriptor;
  void printInternal(raw_ostream &OS) const;

public:
  explicit DIType(const MDNode *N = nullptr) : DIScope(N) {}
  operator DITypeRef () const {
    assert(isType() &&
           "constructing DITypeRef from an MDNode that is not a type");
    return DITypeRef(&*getRef());
  }

  /// Verify - Verify that a type descriptor is well formed.
  bool Verify() const;

  DIScopeRef getContext() const { return getFieldAs<DIScopeRef>(2); }     //2
  StringRef getName() const { return getStringField(3); }                 //3
  unsigned getLineNumber() const { return getUnsignedField(4); }          //4
  uint64_t getSizeInBits() const { return getUInt64Field(5); }            //5
  uint64_t getAlignInBits() const { return getUInt64Field(6); }           //6
  // FIXME: Offset is only used for DW_TAG_member nodes.  Making every type
  // carry this is just plain insane.
  uint64_t getOffsetInBits() const { return getUInt64Field(7); }          //7
  unsigned getFlags() const { return getUnsignedField(8); }               //8
  bool isPrivate() const { return (getFlags() & FlagPrivate) != 0; }
  bool isProtected() const { return (getFlags() & FlagProtected) != 0; }
  bool isForwardDecl() const { return (getFlags() & FlagFwdDecl) != 0; }
  // isAppleBlock - Return true if this is the Apple Blocks extension.
  bool isAppleBlockExtension() const {
    return (getFlags() & FlagAppleBlock) != 0;
  }
  bool isBlockByrefStruct() const {
    return (getFlags() & FlagBlockByrefStruct) != 0;
  }
  bool isVirtual() const { return (getFlags() & FlagVirtual) != 0; }
  bool isArtificial() const { return (getFlags() & FlagArtificial) != 0; }
  bool isObjectPointer() const { return (getFlags() & FlagObjectPointer) != 0; }
  bool isObjcClassComplete() const {
    return (getFlags() & FlagObjcClassComplete) != 0;
  }
  bool isVector() const { return (getFlags() & FlagVector) != 0; }
  bool isStaticMember() const { return (getFlags() & FlagStaticMember) != 0; }
  bool isLValueReference() const {
    return (getFlags() & FlagLValueReference) != 0;
  }
  bool isRValueReference() const {
    return (getFlags() & FlagRValueReference) != 0;
  }
  bool isValid() const { return DbgNode && isType(); }

  /// replaceAllUsesWith - Replace all uses of debug info referenced by
  /// this descriptor.
  void replaceAllUsesWith(LLVMContext &VMContext, DIDescriptor D);
  void replaceAllUsesWith(MDNode *D);
};
*)

//DIDerivedType(DIType)
(*
  DITypeRef getTypeDerivedFrom() const { return getFieldAs<DITypeRef>(9); } //9

  /// getObjCProperty - Return property node, if this ivar is
  /// associated with one.
  MDNode *getObjCProperty() const;

  DITypeRef getClassType() const {
    assert(getTag() == dwarf::DW_TAG_ptr_to_member_type);
    return getFieldAs<DITypeRef>(10);
  }

  Constant *getConstant() const {
    assert((getTag() == dwarf::DW_TAG_member) && isStaticMember());
    return getConstantField(10);
  }

  /// Verify - Verify that a derived type descriptor is well formed.
  bool Verify() const;
};
*)

//DICompositeType(DIDerivedType)
(*
  DIArray getTypeArray() const { return getFieldAs<DIArray>(10); }       //10
  unsigned getRunTimeLang() const { return getUnsignedField(11); }       //11
  DITypeRef getContainingType() const { return getFieldAs<DITypeRef>(12); }//12
  void setContainingType(DICompositeType ContainingType);
  DIArray getTemplateParams() const { return getFieldAs<DIArray>(13); }  //13
  MDString *getIdentifier() const;                                       //14
};

DICompositeType DIBuilder::createSubroutineType(DIFile File,
                                                DIArray ParameterTypes,
                                                unsigned Flags) {
  // TAG_subroutine_type is encoded in DICompositeType format.
  Value *Elts[] = {
    GetTagConstant(VMContext, dwarf::DW_TAG_subroutine_type),
    Constant::getNullValue(Type::getInt32Ty(VMContext)),
    nullptr,
    MDString::get(VMContext, ""),
    ConstantInt::get(Type::getInt32Ty(VMContext), 0), // Line
    ConstantInt::get(Type::getInt64Ty(VMContext), 0), // Size
    ConstantInt::get(Type::getInt64Ty(VMContext), 0), // Align
    ConstantInt::get(Type::getInt64Ty(VMContext), 0), // Offset
    ConstantInt::get(Type::getInt32Ty(VMContext), Flags), // Flags
    nullptr,
    ParameterTypes,
    ConstantInt::get(Type::getInt32Ty(VMContext), 0),
    nullptr,
    nullptr,
    nullptr  // Type Identifer
  };
  return DICompositeType(MDNode::get(VMContext, Elts));
}
*)

//DISubprogram(DIScope)
(*
  DIScopeRef getContext() const { return getFieldAs<DIScopeRef>(2); }   //2
  StringRef getName() const { return getStringField(3); }               //3
  StringRef getDisplayName() const { return getStringField(4); }        //4
  StringRef getLinkageName() const { return getStringField(5); }        //5
  unsigned getLineNumber() const { return getUnsignedField(6); }        //6
  DICompositeType getType() const { return getFieldAs<DICompositeType>(7); }
                                    //DW_TAG_subroutine_type
  /// isLocalToUnit - Return true if this subprogram is local to the current
  /// compile unit, like 'static' in C.
  unsigned isLocalToUnit() const { return getUnsignedField(8); }        //8
  unsigned isDefinition() const { return getUnsignedField(9); }         //9

  unsigned getVirtuality() const { return getUnsignedField(10); }       //10
  unsigned getVirtualIndex() const { return getUnsignedField(11); }     //11

  DITypeRef getContainingType() const { return getFieldAs<DITypeRef>(12); }

  unsigned getFlags() const { return getUnsignedField(13); }            //13

  unsigned isArtificial() const {
    return (getUnsignedField(13) & FlagArtificial) != 0;
  }
  /// isPrivate - Return true if this subprogram has "private"
  /// access specifier.
  bool isPrivate() const { return (getUnsignedField(13) & FlagPrivate) != 0; }
  /// isProtected - Return true if this subprogram has "protected"
  /// access specifier.
  bool isProtected() const {
    return (getUnsignedField(13) & FlagProtected) != 0;
  }
  /// isExplicit - Return true if this subprogram is marked as explicit.
  bool isExplicit() const { return (getUnsignedField(13) & FlagExplicit) != 0; }
  /// isPrototyped - Return true if this subprogram is prototyped.
  bool isPrototyped() const {
    return (getUnsignedField(13) & FlagPrototyped) != 0;
  }

  /// Return true if this subprogram is a C++11 reference-qualified
  /// non-static member function (void foo() &).
  unsigned isLValueReference() const {
    return (getUnsignedField(13) & FlagLValueReference) != 0;
  }

  /// Return true if this subprogram is a C++11
  /// rvalue-reference-qualified non-static member function
  /// (void foo() &&).
  unsigned isRValueReference() const {
    return (getUnsignedField(13) & FlagRValueReference) != 0;
  }

  unsigned isOptimized() const;                                        //14

  Function *getFunction() const { return getFunctionField(15); }       //15
  void replaceFunction(Function *F) { replaceFunctionField(15, F); }
  DIArray getTemplateParams() const { return getFieldAs<DIArray>(16); }//16
  DISubprogram getFunctionDeclaration() const {
    return getFieldAs<DISubprogram>(17);                               //17
  }
  MDNode *getVariablesNodes() const;                                   //18
  DIArray getVariables() const;

  /// getScopeLineNumber - Get the beginning of the scope of the
  /// function, not necessarily where the name of the program
  /// starts.
  unsigned getScopeLineNumber() const { return getUnsignedField(19); } //19
*)


type
 DebugEmissionKind = (FullDebug=1, LineTablesOnly);
                           //from llvm/include/llvm/IR/DIBuilder.h

implementation
end.
