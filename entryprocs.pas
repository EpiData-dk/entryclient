unit entryprocs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, epidatafilestypes;

const
  IntegerChars:    Set of char=['0'..'9','-','+'];
  FloatChars:      Set of char=['0'..'9', '.', ',', '-', '+'];
  DateChars:       Set of char=['0'..'9','/', '-', '.'];
  TimeChars:       Set of char=['0'..'9',':','.'];
  BooleanChars:    Set of char=['y','Y','n','N','1','0'];

  SystemChars:     Set of char=[
                   // VK_BACK, VK_TAB, VK_RETURN, VK_UP, VK_DOWN
                      #8,      #9,     #13,       #38,   #40
                   ];

implementation

uses
  lclproc, strutils, epidatafiles;

end.

