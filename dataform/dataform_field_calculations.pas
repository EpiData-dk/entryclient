unit dataform_field_calculations;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, epidatafiles;

function CalcTimeDiff(Calculation: TEpiTimeCalc): string;
function CalcCombineDate(Calculation: TEpiCombineDateCalc; Out ErrMsg: string; Out ErrEdit: TCustomEdit): string;
function CalcCombineString(Calculation: TEpiCombineStringCalc): string;

implementation

uses
  dateutils, epidatafilestypes, epiconvertutils, math, entry_globals;

function GetFieldEditFromField(Const Field: TEpiField): TCustomEdit;
begin
  result := TCustomEdit(Field.FindCustomData(DataFormCustomDataKey));
end;

function CalcTimeDiff(Calculation: TEpiTimeCalc): string;
var
  S, E: EpiDateTime;

  function ExtractDate(Const Field: TEpiDateField): EpiDateTime;
  var
    Backup: String;
    Txt: String;
  begin
    Txt := GetFieldEditFromField(Field).Text;
    if Txt = '' then Exit(0);

    Backup := DefaultFormatSettings.ShortDateFormat;
    DefaultFormatSettings.ShortDateFormat := Field.FormatString;
    Result := StrToDate(Txt);
    DefaultFormatSettings.ShortDateFormat := Backup;
  end;

  function ExtractTime(Const Field: TEpiDateTimeField): EpiDateTime;
  var
    Backup: String;
    Txt: String;
  begin
    Txt := GetFieldEditFromField(Field).Text;
    if Txt = '' then Exit(0);

    Backup := DefaultFormatSettings.ShortTimeFormat;
    DefaultFormatSettings.ShortTimeFormat := Field.FormatString;
    Result := StrToTime(Txt);
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

    if (S = 0) or (E = 0) then exit('');

    case TimeCalcType of
      ctAsYear:        Result := IntToStr(Sign(S-E) * dateutils.YearsBetween(S, E));
      ctAsMonths:      Result := IntToStr(Sign(S-E) * dateutils.MonthsBetween(S, E));
      ctAsWeeks:       Result := IntToStr(Sign(S-E) * dateutils.WeeksBetween(S, E));
      ctAsDays:        Result := IntToStr(Sign(S-E) * dateutils.DaysBetween(S, E));
      ctAsDayFraction: Result := FloatToStr(S-E);
    end;
  end;
end;

function CalcCombineDate(Calculation: TEpiCombineDateCalc; out ErrMsg: string;
  out ErrEdit: TCustomEdit): string;
var
  D: String;
  M: String;
  Y: String;
  TheDate: EpiDate;
  Mis: EpiString;

  function GetValueFromField(F: TEpiField): String;
  var
    CE: TCustomEdit;
  begin
    CE := GetFieldEditFromField(F);

    if (CE.Text = '') or
       (CE.Text = TEpiStringField.DefaultMissing)
    then
      Exit(Mis);

    if Assigned(F.ValueLabelSet) and
       F.ValueLabelSet.IsMissingValue[CE.Text]
    then
      Exit(Mis);

    Result := CE.Text;
  end;

begin
  Mis := TEpiStringField.DefaultMissing;

  ErrEdit := nil;
  with Calculation do
  begin
    D := GetValueFromField(Day);
    M := GetValueFromField(Month);
    Y := GetValueFromField(Year);

    if EpiStrToDate(D+'-'+M+'-'+Y, '-', ftDMYDate, TheDate, ErrMsg) then
      Result := FormatDateTime(TEpiDateField(ResultField).FormatString, TheDate)
    else if ErrMsg = Mis then
    begin
      Result := Mis;
      ErrMsg := '';
    end else begin
      Result := '';
      if pos('day', ErrMsg) > 0 then
        ErrEdit := GetFieldEditFromField(Day);
      if pos('month', ErrMsg) > 0 then
        ErrEdit := GetFieldEditFromField(Month);
      if pos('year', ErrMsg) > 0 then
        ErrEdit := GetFieldEditFromField(Year);
    end;
  end;
end;

function CalcCombineString(Calculation: TEpiCombineStringCalc): string;
begin
  with Calculation do
  begin
    result := '';
    if Assigned(Field1) then
      Result += GetFieldEditFromField(Field1).Text;
    Result += Delim1;
    if Assigned(Field2) then
      Result += GetFieldEditFromField(Field2).Text;
    Result += Delim2;
    if Assigned(Field3) then
      Result += GetFieldEditFromField(Field3).Text;
  end;
end;

end.
