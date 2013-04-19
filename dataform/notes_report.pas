unit notes_report;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epireport_base,
  epidatafiles;

type

  { TNotesReport }

  TNotesReport = class(TEpiReportBase)
  private
    FField: TEpiField;
  protected
    procedure DoSanityCheck; override;
  public
    procedure RunReport; override;
    property Field: TEpiField read FField write FField;
  end;

implementation

uses
  epimiscutils, epireport_types;

{ TNotesReport }

procedure TNotesReport.DoSanityCheck;
begin
  inherited DoSanityCheck;
end;

procedure TNotesReport.RunReport;
var
  i, j: Integer;
  S: String;
begin
  inherited RunReport;

  I := 0;

  if Assigned(Field.ValueLabelSet) then
    Inc(I, Field.ValueLabelSet.Count);

  if (I = 0) and
     (not Assigned(Field.Ranges))
  then
    Exit;

  if I > 0 then
    DoTableHeader('', 3, I, []);
  j := 0;

  if Assigned(Field.ValueLabelSet) then
    for i := 0 to Field.ValueLabelSet.Count - 1 do
    with Field.ValueLabelSet[i] do
    begin
      DoTableCell(0, j, ValueAsString, tcaLeftAdjust);
      DoTableCell(1, j, TheLabel.Text);
      DoTableCell(2, j, BoolToStr(IsMissingValue, 'M', ''), tcaLeftAdjust);
      Inc(j);
    end;

  S := '';
  if Assigned(Field.Ranges) then
    S := 'Range: ' + Field.Ranges.RangesToText;

  if Assigned(Field.ValueLabelSet) then
    DoTableFooter(S)
  else
    DoLineText(S);
end;

end.

