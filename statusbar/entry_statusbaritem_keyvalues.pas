unit entry_statusbaritem_keyvalues;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, epidatafiles, Buttons, StdCtrls,
  entry_statusbar, dataform_frame;

type

  { TEntryClientStatusBarKeyInformation }

  TEntryClientStatusBarKeyInformation = class(TEntryClientStatusBarItem)
  private
    FKeyLabel: TLabel;
    procedure DoUpdate;
  protected
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
  public
    class function Caption: string; override;
    class function Name: string; override;
  public
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    function GetPreferedWidth: Integer; override;
  end;

implementation

uses
  Controls;

{ TEntryClientStatusBarKeyInformation }

procedure TEntryClientStatusBarKeyInformation.DoUpdate;
var
  MasterDataForm: TDataFormFrame;
  KFs: TEpiFields;
  RecNo: Integer;
  F: TEpiField;
  S: String;
begin
  if not Assigned(DataForm) then exit;

  MasterDataForm := DataForm.MasterDataform;

  if (not (Assigned(MasterDataForm))) then
    MasterDataForm := DataForm;

  KFs := MasterDataForm.DataFile.KeyFields;
  RecNo := MasterDataForm.RecNo;

  S := '';
  if RecNo <> NewRecord then
  begin
    for F in KFs do
      S += '(' + F.Name + ': ' + F.AsString[RecNo] + '), ';

    Delete(S, Length(S) - 1, 2);
  end else
    S := 'No Key';

  FKeyLabel.Caption := S;
end;

procedure TEntryClientStatusBarKeyInformation.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    sucDefault:
      DoUpdate;
    sucDocFile: ;
    sucDataFile:
      DoUpdate;
    sucSelection: ;
    sucSave: ;
  end;
end;

class function TEntryClientStatusBarKeyInformation.Caption: string;
begin
  Result := 'Key Values';
end;

class function TEntryClientStatusBarKeyInformation.Name: string;
begin
  result := 'KeyInfo';
end;

constructor TEntryClientStatusBarKeyInformation.Create(
  AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);

  FKeyLabel := TLabel.Create(Panel);
  FKeyLabel.AnchorParallel(akLeft, 2, Panel);
  FKeyLabel.AnchorVerticalCenterTo(Panel);
  FKeyLabel.Caption := '';
  FKeyLabel.Parent := Panel;
end;

function TEntryClientStatusBarKeyInformation.GetPreferedWidth: Integer;
begin
  if not Panel.HandleAllocated then
    begin
      Result := inherited GetPreferedWidth;
      Exit;
    end;

  Result := FKeyLabel.Left + FKeyLabel.Width + 2;
end;

initialization
  EpiV_RegisterCustomStatusBarItem(TEntryClientStatusBarKeyInformation);

end.

