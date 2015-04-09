{ MSEgui Copyright (c) 2014-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit __mla__internaltypes;
interface 

type
 ppointer = ^pointer;

type
{$ifdef mse_compiler}
 targetptrintty = int32;
{$endif}
 refcountty = int32;
 managedsizety = int32;
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
 
 string8headerty = record
  ref: refinfoty;
  len: stringsizety;
 end; //following stringdata + terminating #0
 pstring8headerty = ^string8headerty;

 dynarrayheaderty = record
  ref: refinfoty;
  len: dynarraysizety;
 end; //following array data
 pdynarrayheaderty = ^dynarrayheaderty;

const
 string8headersize = sizeof(string8headerty);
 string8allocsize = string8headersize+1; //terminating #0
 dynarrayheadersize = sizeof(dynarrayheaderty);
 dynarrayallocsize = dynarrayheadersize;

type
 allocsinfoty = record
  size: int32;
  instanceinterfacestart: int32; //offset in instance record
  classdefinterfacestart: int32; //offset in classdefheaderty
 end;
{$ifdef mse_compiler}
 pclassdefinfoty = targetptrintty;
 classdefinfopoty = ^classdefinfoty;
{$else}
 pclassdefinfoty = ^classdefinfoty;
{$endif}
 classdefheaderty = record
  parentclass: pclassdefinfoty;
  interfaceparent: pclassdefinfoty; //last parent class with interfaces
  allocs: allocsinfoty;
 end;
 pclassdefheaderty = ^classdefheaderty;
 
 classdefinfoty = record
  header: classdefheaderty;
  virtualmethods: record //array of targetpointer to sub
  end;
  interfaces: record     //array of targetpointer to intfdefinfoty,
                         //copied to instance
  end;  
 end;
 
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

implementation
end.
