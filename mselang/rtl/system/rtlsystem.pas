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
 rtlbase;
 
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

function fileopen(const path: filenamety; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out handle: integer): syserrorty;
function fileclose(const handle: integer): syserrorty;

implementation
uses
 rtllibc;
  
const
 unidatetimeoffset = -25569;

function nowutc(): datetimety;
var
 ti: timeval;
 f1,f2: flo64;
begin
 gettimeofday(@ti,nil);
 result:= ti.tv_sec / (flo64(24.0)*60.0*60.0) + 
          ti.tv_usec / (flo64(24.0)*60.0*60.0*1e6) - unidatetimeoffset;
end;

function fileopen(const path: filenamety; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out handle: integer): syserrorty;
var
 str1: string;
 str2: msestring;
 stat1: _stat;
const
 defaultopenflags = o_cloexec; 
begin
{
 str2:= path;
 sys_tosysfilepath(str2);
 str1:= tosys(str2);
}
 str1:= path;
 handle:= Integer(mselibc.open(PChar(str1), openmodes[openmode] or 
                            defaultopenflags,[getfilerights(rights)]));
 if handle >= 0 then begin
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
 end
 else begin
  result:= syelasterror;
 end;
end;

end.