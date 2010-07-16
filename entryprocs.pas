unit entryprocs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, epidatafilestypes;

const
  IntegerChars:    Set of char=['0'..'9','-','+'];
  FloatChars:      Set of char=['0'..'9', '.', ',', '-', '+'];
  DateChars:       Set of char=['0'..'9','/', '-', '.'];
  BooleanChars:    Set of char=['y','Y','n','N','1','0'];

  SystemChars:     Set of char=[
                   // VK_BACK, VK_TAB, VK_RETURN, VK_UP, VK_DOWN
                      #8,      #9,     #13,       #38,   #40
                   ];

  function IsEpiInteger(Const S: string; var I: EpiInteger): boolean;
  function IsEpiDate(Var S: string; Var D: EpiDate; Ft: TEpiFieldType): boolean;


implementation

uses
  lclproc, strutils, epidatafiles;

function IsEpiInteger(const S: string; var I: EpiInteger): boolean;
var
  Code: Integer;
begin
  Val(S, I, Code);
  result := Code = 0;
end;

function IsEpiDate(Var S: string; var D: EpiDate; Ft: TEpiFieldType): boolean;
var
  Sep: String;
  DateStr: String;
  LocalFmt: String;
begin
  Sep := String(DateSeparator);
  LocalFmt := ShortDateFormat;

  DateStr := StringsReplace(S, ['/', '-', '\', '.'], [Sep, Sep, Sep, Sep], [rfReplaceAll]);
  Case Ft of
    ftDMYDate:
      ShortDateFormat := 'DD/MM/YYYY';
    ftMDYDate:
      ShortDateFormat := 'MM/DD/YYYY';
    ftYMDDate:
      ShortDateFormat := 'YYYY/MM/DD';
  end;
  D := EpiDate(Trunc(StrToDateDef(DateStr, TEpiDateField.DefaultMissing)));

  ShortDateFormat := LocalFmt;
  if D = TEpiDateField.DefaultMissing then exit(false);

  Result := true;
end;

end.

