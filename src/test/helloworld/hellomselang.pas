program hellomselang;
uses
rtl_stringconv;
var
x, y : integer;
tex : string16;
begin
x := 1;
y := 3;
tex := 'Hello MSElang world!' ;
writeln(tex);
writeln( 'x = ' + inttostring16(x));
writeln( 'y = ' + inttostring16(y));
writeln( 'x + y = ' + inttostring16(x+y));

end.
