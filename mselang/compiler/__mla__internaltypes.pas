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
 dataoffsty = int32; //todo: use target size
 ppointer = ^pointer;

type            
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
  interfacestart: int32; //offset in classdefheaderty
 end;
 classdefheaderty = record
  parentclass: dataoffsty;
  interfaceparent: dataoffsty; //last parent class with interfaces
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
 pclassdefinfoty = ^classdefinfoty;
 
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
