//rtl_fpccompatibility
{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
{$mode pascal}
unit rtl_fpccompatibility;
interface
//FPC compatibility
uses
 rtl_system,rtl_string,rtl_libc,__mla__internaltypes,rtl_base;
 
type
//{$internaldebug on}
 tobject = class;
// iunknown = interface;

 tclass  = class of tobject;
 pclass  = ^tclass;

 tobject = class(tbase)[virtual]
  private
   class function newinst(): pointer [new];
  protected
  public
   constructor create();
   destructor destroy() [override,default];
   procedure free();
   class function newinstance(): tobject [virtual];
   procedure freeinstance [dispose,virtual];
   class function initinstance(instance : pointer): tobject;
   procedure cleanupinstance();
   class function classtype(): tclass;
   class function classinfo(): pointer; //returns pobjectrttity
   class function classname(): string8;
   class function classnameis(const name: string8): boolean;
   class function classparent(): tclass;
   class function instancesize(): int32;
   class function inheritsfrom(aclass: tclass): boolean;
   //class function stringmessagetable : pstringmessagetable;
                         //not implemented

        //todo
   //class function MethodAddress(const name : shortstring) : codepointer;         
   //class function MethodName(address : codepointer) : shortstring;
   //function FieldAddress(const name : shortstring) : pointer;

   procedure afterconstruction() [afterconstruct,virtual];
   procedure beforedestruction() [beforedestruct,virtual];
   
 end; 
 
 pchar = ^char8;
 sizeint = intptr;
 tdatetime = datetimety;
 tsize = size_t;
 tssize = ssize_t;
 
procedure move(const source; var dest; count: sizeint);
function now(): tdatetime;
function trunc(d: flo64): int64;
function round(d: flo64): int64;
function fpopen(path: pchar; flags: cint):cint;
function fpwrite(fd: cint; buf: pchar; nbytes: tsize): tssize;
function fpclose(fd: cint): cint;

implementation

procedure move(const source; var dest; count: sizeint);
begin
 memmove(@dest,@source,count);
end;

function now(): tdatetime;
begin
 result:= nowutc();
end;

function trunc(d: flo64): int64;
begin
 result:= truncint64(d);
end;

function round(d: flo64): int64;
begin
 result:= truncint64(nearbyint(d));
end;

function fpopen (path : pchar; flags : cint):cint;
begin
 result:= open(path,flags,[]);
end;

function fpwrite(fd: cint; buf: pchar; nbytes: tsize): tssize;
begin
 result:= write(fd,buf,nbytes);
end;

function fpclose(fd: cint): cint;
begin
 result:= close(fd);
end;

{ tobject }

constructor tobject.create();
begin
 //dummy
end;

destructor tobject.destroy();
begin
 //dummy
end;

procedure tobject.free();
begin
 if self <> nil then begin
  destroy();
 end;
end;

class function tobject.newinst(): pointer;
begin
 result:= newinstance();
end;

class function tobject.newinstance(): tobject;
begin
 result:= getmem(sizeof(self^));
 initialize(result,classof(self));
end;

procedure tobject.freeinstance();
begin
 finalize(self^);
 freemem(self);
end;

class function tobject.initinstance(instance: pointer): tobject;
begin
 result:= instance;
 initialize(result,classof(self));
end;

procedure tobject.cleanupinstance();
begin
 finalize(self^);
end;

class function tobject.classtype(): tclass;
begin
 result:= tclass(self);
end;

class function tobject.classparent(): tclass;
begin
 result:= tclass(pclassdefty(classof(self))^.header.parentclass);
end;
   
class function tobject.classinfo(): pointer; //returns pobjectrttity
begin
 result:= pclassdefty(self)^.header.rtti;
end;

class function tobject.classname(): string8;
begin
 decref(result);
 pointer(result):= pointer(prttity(classinfo)^.typename); 
                                          //const, no incref needed
end;

class function tobject.classnameis(const name: string8): boolean;
begin
 result:= stringicomp(name,
            string8(prttity(pclassdefty(self)^.header.rtti)^.typename)) = 0;
end;

class function tobject.instancesize(): int32;
begin
 result:= sizeof(self^);
end;

class function tobject.inheritsfrom(aclass: tclass): boolean;
begin
 result:= self is aclass;
end;

procedure tobject.afterconstruction();
begin
 //dummy
end;

procedure tobject.beforedestruction();
begin
 //dummy
end;

end.
