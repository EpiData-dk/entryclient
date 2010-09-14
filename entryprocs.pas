unit entryprocs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, epidatafilestypes, epistringutils;

const
  IntegerChars:    TCharSet=['0'..'9','-','+'];
  FloatChars:      TCharSet=['0'..'9', '.', ',', '-', '+'];
  DateChars:       TCharSet=['0'..'9','/', '-', '.'];
  TimeChars:       TCharSet=['0'..'9',':','.'];
  BooleanChars:    TCharSet=['y','Y','n','N','1','0'];

type
  TCharArray = array of char;

implementation

uses
  lclproc, strutils, epidatafiles;

end.

