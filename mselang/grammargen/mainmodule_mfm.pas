unit mainmodule_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 mseclasses,mainmodule;

const
 objdata: record size: integer; data: array[0..457] of byte end =
      (size: 458; data: (
  84,80,70,48,7,116,109,97,105,110,109,111,6,109,97,105,110,109,111,9,
  98,111,117,110,100,115,95,99,120,3,42,1,9,98,111,117,110,100,115,95,
  99,121,2,105,16,111,110,101,118,101,110,116,108,111,111,112,115,116,97,114,
  116,7,12,101,118,101,110,116,108,111,111,112,101,120,101,4,108,101,102,116,
  2,47,3,116,111,112,3,216,0,15,109,111,100,117,108,101,99,108,97,115,
  115,110,97,109,101,6,14,116,109,115,101,100,97,116,97,109,111,100,117,108,
  101,0,14,116,115,121,115,101,110,118,109,97,110,97,103,101,114,6,115,121,
  115,101,110,118,7,111,112,116,105,111,110,115,11,27,115,101,111,95,97,112,
  112,116,101,114,109,105,110,97,116,101,111,110,101,120,99,101,112,116,105,111,
  110,20,115,101,111,95,116,101,114,109,105,110,97,116,101,111,110,101,114,114,
  111,114,12,115,101,111,95,116,111,111,117,116,112,117,116,11,115,101,111,95,
  116,111,101,114,114,111,114,0,11,111,110,97,102,116,101,114,105,110,105,116,
  7,12,97,102,116,101,114,105,110,105,116,101,120,101,4,108,101,102,116,2,
  16,3,116,111,112,2,8,4,100,101,102,115,1,1,7,9,97,107,95,112,
  97,114,97,114,103,6,1,103,1,0,11,13,97,114,102,95,109,97,110,100,
  97,116,111,114,121,0,6,0,6,11,71,82,65,77,77,65,82,70,73,76,
  69,6,0,6,0,6,0,0,1,7,9,97,107,95,112,97,114,97,114,103,
  6,1,104,1,0,11,13,97,114,102,95,109,97,110,100,97,116,111,114,121,
  0,6,0,6,14,80,65,83,67,65,76,71,76,79,66,70,73,76,69,6,
  0,6,0,6,0,0,1,7,9,97,107,95,112,97,114,97,114,103,6,1,
  112,1,0,11,13,97,114,102,95,109,97,110,100,97,116,111,114,121,13,97,
  114,102,95,102,105,108,101,110,97,109,101,115,0,6,0,6,10,80,65,83,
  67,65,76,70,73,76,69,6,0,6,0,6,0,0,0,0,0,0)
 );

initialization
 registerobjectdata(@objdata,tmainmo,'');
end.
