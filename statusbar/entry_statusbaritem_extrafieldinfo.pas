unit entry_statusbaritem_extrafieldinfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, epidatafiles, StdCtrls,
  entry_statusbar, dataform_frame;

type

  { TEntryClientStatusBarExtraFieldInfo }

  TEntryClientStatusBarExtraFieldInfo = class(TEntryClientStatusBarItem)
  private
    FLabel: TLabel;
    procedure DoUpdate;
    procedure DoExample;
  public
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
    class function Caption: string; override;
    class function Name: string; override;
  public
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    function GetPreferedWidth: Integer; override;
  end;

implementation

uses
  epidatafilestypes, Controls;

{ TEntryClientStatusBarExtraFieldInfo }

procedure TEntryClientStatusBarExtraFieldInfo.DoUpdate;
var
  F: TEpiField;
  S: String;
begin
  if (Statusbar.Selection.Count = 0) then exit;

  S := '';

  F := TEpiField(Statusbar.Selection[0]);
  if Assigned(F.ValueLabelSet) then
    S := 'Label: +/F9';

  if (F.FieldType in DateFieldTypes) then
    S := 'Current date: +';

  if (F.FieldType in TimeFieldTypes) then
    S := 'Current time: +';

  if (S = '') then
    Visible := false
  else
    begin
      FLabel.Caption := S;
      Visible := true;
    end;
end;

procedure TEntryClientStatusBarExtraFieldInfo.DoExample;
begin
  FLabel.Caption := 'Label: +/F9';
end;

procedure TEntryClientStatusBarExtraFieldInfo.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    sucDefault: ;
    sucDocFile: ;
    sucDataFile: ;
    sucSelection:
      DoUpdate;
    sucSave: ;
    sucExample:
      DoExample;
  end;
end;

class function TEntryClientStatusBarExtraFieldInfo.Caption: string;
begin
  Result := 'Additional Variable Information';
end;

class function TEntryClientStatusBarExtraFieldInfo.Name: string;
begin
  result := 'extrafieldinfo';
end;

constructor TEntryClientStatusBarExtraFieldInfo.Create(
  AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);

  FLabel := TLabel.Create(Panel);
  FLabel.AnchorParallel(akLeft, 2, Panel);
  FLabel.AnchorVerticalCenterTo(Panel);
  FLabel.Caption := '';
  FLabel.Parent := Panel;
end;

function TEntryClientStatusBarExtraFieldInfo.GetPreferedWidth: Integer;
begin
  if not Panel.HandleAllocated then
    begin
      Result := inherited GetPreferedWidth;
      Exit;
    end;

  Result := FLabel.Left + FLabel.Width + 2;
end;

initialization
  EpiV_RegisterCustomStatusBarItem(TEntryClientStatusBarExtraFieldInfo);


end.

