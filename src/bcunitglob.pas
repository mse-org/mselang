{ MSElang Copyright (c) 2015 by Martin Schreiber
   
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
unit bcunitglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msectypes;
const
 bcheadermagic = $0B17C0DE;
 bcheaderversion = 0;
 
type
 bc_header = record
  Magic: cuint32;         // 0x0B17C0DE
  Version: cuint32;       // Version, currently always 0.
  BitcodeOffset: cuint32; // Offset to traditional bitcode file.
  BitcodeSize: cuint32;   // Size of traditional bitcode file.
  CPUType: cuint32;
 end;
 
const
 bitcodesizeoffset = 3*sizeof(cuint32);
 
type
 bcunitinfoty = record
  guid: tguid;
 end;
 
 bcunitheaderty = record
  wrap: bc_header;
  header: bcunitinfoty;
  data: record end;
 end;
implementation
end.
