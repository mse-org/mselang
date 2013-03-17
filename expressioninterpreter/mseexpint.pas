{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseexpint;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes;
 
type
 opinfoty = record
 end;
 oparty = array of opinfoty;
 
function parse(const input: string; out errors: stringarty): oparty;

implementation

type
 contextty = record
  
 end;
 pcontextty = record
 end;

const
 startcontext: contextty =
  ();

function parse(const input: string; out errors: stringarty): oparty;
var
 source: pchar;
 context: pcontextty;
begin
 source:= pchar(input);
 repeat
  inc(source);
 until source^ = #0;
end;

end.
