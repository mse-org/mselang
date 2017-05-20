{ MSEpas Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit rtlfpccompatibility;
interface
//FPC compatibility

type
 sizeint = intptr;
 
procedure move(const source; var dest; count: sizeint);

implementation

procedure move(const source; var dest; count: sizeint);
begin
 memmove(@dest,@source,count);
end;

end.
