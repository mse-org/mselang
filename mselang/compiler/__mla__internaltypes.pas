//__mla__internaltypes
{ MSEgui Copyright (c) 2014-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit __mla__internaltypes;
interface
// {$internaldebug on}
//{$ifndef mse_compiler}
// procedure test(a: int32);
//{$endif}
 
type
 ppointer = ^pointer;

type
{$ifdef mse_compiler}
 targetptrintty = int32;
 ptargetptrintty = ^targetptrintty;
 card32 = longword;
 card64 = qword;
 targetpointerty = card32;
 ptargetpointerty = ^targetpointerty;
{$endif}
 cint = int32;
 
 ptrint = int32;
 pptrint = ^ptrint;
 ptrcard = card32;
 
 pint64 = ^int64;
 pcard64 = ^card64;
 
 refcountty = int32;
 managedsizety = ptrint;
 stringsizety = managedsizety;
 pstringsizety = ^stringsizety;
 dynarraysizety = managedsizety;
 pdynarraysizety = ^dynarraysizety;
 
 refinfoty = record
  count: refcountty;
 end;
 prefinfoty = ^refinfoty;
 refsizeinfoty = record
  ref: refinfoty;
  sizedummy: managedsizety;
 end;
 prefsizeinfoty = ^refsizeinfoty;
 pprefsizeinfoty = ^prefsizeinfoty;

 stringheaderty = record
  ref: refinfoty;
  len: stringsizety;
  data: record
  end; //stringdata + terminating #0
 end; 
 pstringheaderty = ^stringheaderty;
 ppstringheaderty = ^pstringheaderty;

 dynarrayheaderty = record
  ref: refinfoty;
  high: dynarraysizety;
  data: record //data array
  end;
 end;
 pdynarrayheaderty = ^dynarrayheaderty;
 ppdynarrayheaderty = ^pdynarrayheaderty;
 
 openarrayty = record //layout fix
  high: int32;
 {$ifdef mse_compiler}
  data: targetpointerty;
 {$else}
  data: pointer;
 {$endif}
 end;
 popenarrayty = ^openarrayty;

 methodty = record
 {$ifdef mse_compiler}
  code: targetpointerty;
  data: targetpointerty;
 {$else}
  code: pointer;
  data: pointer;
 {$endif}
 end;
 
const
// string8headersize = sizeof(stringheaderty);
 stringheadersize = sizeof(stringheaderty);
 string8allocsize = stringheadersize+1; //terminating #0
 string16allocsize = stringheadersize+2; //terminating #0
 string32allocsize = stringheadersize+4; //terminating #0
 dynarrayheadersize = sizeof(dynarrayheaderty);
 dynarrayallocsize = dynarrayheadersize;

type
{$ifdef mse_compiler}
 string8 = targetptrintty;
{$endif}

 rttikindty = (rtk_none,rtk_enum,rtk_enumitem,rtk_object,
               rtk_property);

 rttity = object
  size: int32;            //0
  kind: rttikindty;       //1
 {$ifdef mse_compiler}
  typename: string8;      //2
 {$else}
  typename: pointer;      //2  
 {$endif}
 end;
{$ifdef mse_compiler}
 prttity = targetptrintty;
 pcrttity = ^rttity; 
{$else}
 prttity = ^rttity;
{$endif}

const
 rttifieldcount = 3;
 classrttidefindex = rttifieldcount + 0;

type
 enumrttiflagty = (erf_contiguous);
 enumrttiflagsty = set of enumrttiflagty;

 enumitemrttity = record
  value: int32;
 {$ifdef mse_compiler}
  name: string8;
 {$else}
  name: pointer;
 {$endif}
 end;
{$ifdef mse_compiler}
 penumitemrttity = targetptrintty;
 pcenumitemrttity = ^enumitemrttity; 
{$else}
 penumitemrttity = ^enumitemrttity;
{$endif}

 enumrttity = object(rttity)
  itemcount: integer;                 //0
  flags: enumrttiflagsty;             //1
  items: record end; //array of enumitemrttity
 end;

type
{$ifdef mse_compiler}
 penumrttity = targetptrintty;
 pcenumrttity = ^enumrttity; 
{$else}
 penumrttity = ^enumrttity;
{$endif}

{$ifdef mse_compiler}
 pclassdefinfoty = targetptrintty;
 classdefinfopoty = ^classdefinfoty;
 classprocty = targetptrintty;
{$else}
 pclassdefinfoty = ^classdefinfoty;
 ppclassdefinfoty = ^pclassdefinfoty;
 procpoty = pointer;
 classprocty = procedure(instance: pointer);
{$endif}

 propertyrttity = object(rttity)
  
 end;

 rttilistty = record
  count: int32;
  items: record //array of rttity
  end;
 end;
   
 objectrttity = object(rttity)
  classdef: pclassdefinfoty; //0 -> classrttidefindex
  properties: rttilistty;
 end;
 pobjectrttity = ^objectrttity;
 allocsinfoty = record
  size: int32;
  instanceinterfacestart: int32; //offset in instance record
  classdefinterfacestart: int32; //offset in classdefheaderty
 end;

 classdefprocty = (cdp_ini,cdp_fini,cdp_destruct);

 classdefheaderty = record 
   //layout fix, used in compiler llvmlists.tconsthashdatalist.addclassdef()
  parentclass: pclassdefinfoty;                                          //0
  interfaceparent: pclassdefinfoty; //last parent class with interfaces  //1
  virttaboffset: int32;             //field offset in instance           //2
  rtti: prttity;                                                         //3
  procs: array[classdefprocty] of classprocty;  //4             
  allocs: allocsinfoty;                         //4+high(procs)+1
 end;
 pclassdefheaderty = ^classdefheaderty;
 
 classdefinfoty = record
  header: classdefheaderty;                                //0
  virtualmethods: record //array of targetpointer to sub   //4+high(procs)+2
  end;
  interfaces: record     //array of targetpointer to intfdefinfoty,
                         //copied to instance
  end;  
 end;
const
 classvirttabindex = 4+ord(high(classdefprocty))+2;
type 
 intfdefheaderty = record
  instanceoffset: int32; //offset from interface pointer to class instance
 end;
 pintfdefheaderty = ^intfdefheaderty;
 
 intfdefinfoty = record
  header: intfdefheaderty;
  items: record          //array of targetpointer to sub
  end;
 end;
 pintfdefinfoty = ^intfdefinfoty;

 valuetypety = (vt_boolean,vt_int32,vt_card32,vt_int64,vt_card64,
                vt_char8,vt_char16,vt_char32,
                vt_string8,vt_string16,vt_string32,
                vt_flo64
               );
{$ifdef mse_compiler}
 varrecty32 = record
  vtype: valuetypety;
  vpointer: card32;
 end;
 varrecty64 = record
  vtype: valuetypety;
  vpointer: card64;
 end;
{$else}
 varrecty = record
  vtype: valuetypety;
  (vboolean: boolean);
  (vint32: int32);
  (vcard32: card32);
  (vint64: pint64);
  (vcard64: pcard64);
  (vchar8: char8);
  (vchar16: char16);
  (vchar32: char32);
  (vstring8: pointer);
  (vstring16: pointer);
  (vstring32: pointer);
 end;
 pvarrecty = ^varrecty;
{$endif}
implementation

end.
