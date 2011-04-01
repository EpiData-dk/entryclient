unit dataform_field_calculations;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fieldedit, epidatafiles;

function CalcTimeDiff(Const FieldEditList: TFpList; Calculation: TEpiTimeCalc): string;
function CalcCombineDate(Const FieldEditList: TFpList; Calculation: TEpiCombineDateCalc; Out ErrMsg: string; Out ErrFieldEdit: TFieldEdit): string;
function CalcCombineString(Const FieldEditList: TFpList; Calculation: TEpiCombineStringCalc): string;

implementation

uses
  dateutils, epidatafilestypes, epiconvertutils;

function GetFieldEditFromField(Const List: TFpList; Const Field: TEpiField): TFieldEdit;
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
    if TFieldEdit(List[i]).Field = Field then
      Exit(TFieldEdit(List[i]));
  Result := nil;
end;

function CalcTimeDiff(const FieldEditList: TFpList; Calculation: TEpiTimeCalc
  ): string;
var
  S, E: EpiDateTime;

  function ExtractDate(Const Field: TEpiDateField): EpiDateTime;
  var
    Backup: String;
  begin
    Backup := DefaultFormatSettings.ShortDateFormat;
    DefaultFormatSettings.ShortDateFormat := Field.FormatString;
    Result := StrToDate(GetFieldEditFromField(FieldEditList, Field).Text);
    DefaultFormatSettings.ShortDateFormat := Backup;
  end;

  function ExtractTime(Const Field: TEpiDateTimeField): EpiDateTime;
  var
    Backup: String;
  begin
    Backup := DefaultFormatSettings.ShortTimeFormat;
    DefaultFormatSettings.ShortTimeFormat := Field.FormatString;
    Result := StrToTime(GetFieldEditFromField(FieldEditList, Field).Text);
    DefaultFormatSettings.ShortTimeFormat := Backup;
  end;

begin
  S := 0;
  E := 0;

  with Calculation do
  begin;
    if Assigned(StartDate) then
      S += ExtractDate(StartDate);
    if Assigned(StartTime) then
      S += ExtractTime(StartTime);
    if Assigned(EndDate) then
      E += ExtractDate(EndDate);
    if Assigned(EndTime) then
      E += ExtractTime(EndTime);

    case TimeCalcType of
      ctAsYear:        Result := IntToStr(dateutils.YearsBetween(S, E));
      ctAsMonths:      Result := IntToStr(dateutils.MonthsBetween(S, E));
      ctAsWeeks:       Result := IntToStr(dateutils.WeeksBetween(S, E));
      ctAsDays:        Result := IntToStr(dateutils.DaysBetween(S, E));
      ctAsDayFraction: Result := FloatToStr(frac(S-E));
    end;
  end;
end;

function CalcCombineDate(const FieldEditList: TFpList;
  Calculation: TEpiCombineDateCalc; out ErrMsg: string; Out ErrFieldEdit: TFieldEdit): string;
var
  D: String;
  M: String;
  Y: String;
  TheDate: EpiDate;
begin
  ErrFieldEdit := nil;
  with Calculation do
  begin
    D := GetFieldEditFromField(FieldEditList, Day).Text;
    M := GetFieldEditFromField(FieldEditList, Month).Text;
    Y := GetFieldEditFromField(FieldEditList, Year).Text;

    if EpiStrToDate(D+'-'+M+'-'+Y, '-', ftDMYDate, TheDate, ErrMsg) then
      Result := FormatDateTime(TEpiDateField(ResultField).FormatString, TheDate)
    else begin
      Result := '';
      if pos('day', ErrMsg) > 0 then
        ErrFieldEdit := GetFieldEditFromField(FieldEditList, Day);
      if pos('month', ErrMsg) > 0 then
        ErrFieldEdit := GetFieldEditFromField(FieldEditList, Month);
      if pos('year', ErrMsg) > 0 then
        ErrFieldEdit := GetFieldEditFromField(FieldEditList, Year);
    end;
  end;
end;

function CalcCombineString(const FieldEditList: TFpList;
  Calculation: TEpiCombineStringCalc): string;
begin
  with Calculation do
  begin
    result := '';
    if Assigned(Field1) then
      Result += GetFieldEditFromField(FieldEditList, Field1).Text;
    Result += Delim1;
    if Assigned(Field2) then
      Result += GetFieldEditFromField(FieldEditList, Field2).Text;
    Result += Delim2;
    if Assigned(Field3) then
      Result += GetFieldEditFromField(FieldEditList, Field3).Text;
  end;
end;

end.
