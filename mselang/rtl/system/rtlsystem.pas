{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtlsystem;
//system functions, preliminary ad-hoc implementation
interface
uses
 rtlbase,rtllibc;

const
 invalidfilehandle = -1;
 
type
 fileopenmodety = (fm_none,fm_read,fm_write,fm_readwrite,fm_create,fm_append);
 fileaccessmodety = (fa_denywrite,fa_denyread);
 fileaccessmodesty = set of fileaccessmodety;
 filerightty = (s_irusr,s_iwusr,s_ixusr,
                s_irgrp,s_iwgrp,s_ixgrp,
                s_iroth,s_iwoth,s_ixoth,
                s_isuid,s_isgid,s_isvtx);
 filerightsty = set of filerightty;
 filetypety = (ft_unknown,ft_dir,ft_blk,ft_chr,ft_reg,ft_lnk,ft_sock,ft_fifo);
 fileattributety = (fa_rusr,fa_wusr,fa_xusr,
                    fa_rgrp,fa_wgrp,fa_xgrp,
                    fa_roth,fa_woth,fa_xoth,
                    fa_suid,fa_sgid,fa_svtx,
                    fa_dir,
                    fa_archive,fa_compressed,fa_encrypted,fa_hidden,
                    fa_offline,fa_reparsepoint,fa_sparsefile,fa_system,
                    fa_temporary,
                    fa_all);
 fileattributesty = set of fileattributety;
 accessmodety = (am_read,am_write,am_execute,am_exist);
 accessmodesty = set of accessmodety;

 syserrorty = (sye_ok,sye_lasterror,sye_extendederror,sye_busy,sye_dirstream,
                sye_network,sye_write,sye_read,
                sye_thread,sye_mutex,sye_semaphore,sye_cond,sye_timeout,
                sye_copyfile,sye_createdir,sye_noconsole,sye_notimplemented,
                sye_sockaddr,sye_socket,sye_isdir
               );

function nowutc(): datetimety;

function fileopen(const path: string8{filenamety}; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out fd: int32): syserrorty;
function fileclose(const fd: int32): syserrorty;
function filewrite(const fd: int32; const buf: pointer; nbytes: card32): int32;
implementation
//{$internaldebug on}
//uses                           //todo: error with llvm debuginfo:
// rtllibc;                      //"Unable to find compile unit!"
                               //must be in interface
  
const
 unidatetimeoffset = -25569;

function syelasterror: syserrorty; //returns sye_lasterror, sets mselasterror
begin
 result:= sye_lasterror; //todo
end;

function nowutc(): datetimety;
var
 ti: timeval;
 f1,f2: flo64;
begin
 gettimeofday(@ti,nil);
 result:= ti.tv_sec / (flo64(24.0)*60.0*60.0) + 
          ti.tv_usec / (flo64(24.0)*60.0*60.0*1e6) - unidatetimeoffset;
end;
(*
const
 openmodes: array[fileopenmodety] of longword =
//    fm_none,fm_read, fm_write,fm_readwrite,fm_create,
     (0,      o_rdonly,o_wronly,o_rdwr,      o_rdwr or o_creat or o_trunc,
//    fm_append
      o_rdwr or o_creat {or o_trunc});
*)
sub getopenmodes(amode: fileopenmodety): card32; //todo: use array
begin
 result:= 0;
 case amode of 
  fm_read: begin
   result:= o_rdonly;
  end;
  fm_write: begin
   result:= o_wronly;
  end;
  fm_readwrite: begin
   result:= o_rdwr;
  end;
  fm_create: begin
   result:= o_rdwr or o_creat or o_trunc;
  end;
  fm_append: begin
   result:= o_rdwr or o_creat;
  end;
 end;
end;

function fileopen(const path: string8{filenamety}; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out fd: int32): syserrorty;
var
// str1: string;
// str2: string16;
// stat1: _stat;
const
 defaultopenflags = o_cloexec; 
begin
{
 str2:= path;
 sys_tosysfilepath(str2);
 str1:= tosys(str2);
}
// str1:= path;
 fd:= open(pcchar(path), getopenmodes(openmode) or defaultopenflags);
// handle:= open(pcchar(str1), openmodes[openmode] or 
//                            defaultopenflags,[getfilerights(rights)]);
 if fd >= 0 then begin
 {
  if fstat(handle,@stat1) = 0 then begin  
   if s_isdir(stat1.st_mode) then begin
    mselibc.__close(handle);
    handle:= -1;
    result:= sye_isdir;
   end
   else begin
    setcloexec(handle);
    result:= sye_ok;
   end;    
  end
  else begin
   mselibc.__close(handle);
   handle:= -1;
   result:= syelasterror;
  end;
 }
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function fileclose(const fd: int32): syserrorty;
var
 i1: cint;
begin
 result:= sye_ok;
 if (fd <> invalidfilehandle) then begin
  if close(fd) <> 0 then begin
   result:= sye_lasterror;
  end;
 end;
{
  repeat
   int1:= mselibc.__close(handle);
  until (int1 = 0) or (sys_getlasterror <> EINTR);
  if int1 <> 0 then begin
   result:= syelasterror;
  end;
 end;
}
end;

function filewrite(const fd: int32; const buf: pointer; nbytes: card32): int32;
var
 i1: int32;
begin
 result:= write(fd,buf,nbytes);
{
 result:= nbytes;
 repeat
  i1:= mselibc.__write(fd,buf^,nbytes);
  if int1 = -1 then begin
   if sys_getlasterror <> eintr then begin
    result:= int1;
    break;
   end;
   continue;
  end;
  inc(pchar(buf),int1);
  dec(nbytes,int1);
 until integer(nbytes) <= 0;
}
end;

end.