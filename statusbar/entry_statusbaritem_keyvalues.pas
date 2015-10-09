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

    procedure DoUpdate;
  protected
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
  public
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    function GetPreferedWidth: Integer; override;
  end;

implementation

{ TEntryClientStatusBarKeyInformation }

procedure TEntryClientStatusBarKeyInformation.DoUpdate;
var
  MasterDataForm: TDataFormFrame;
  KFs: TEpiFields;
  RecNo: Integer;
  F: TEpiField;
begin
  MasterDataForm := Statusbar.DataForm.MasterDataform

  if (not (Assigned(MasterDataForm)) then
    MasterDataForm := Statusbar.DataForm;

  KFs := MasterDataForm.DataFile.KeyFields;
  RecNo := MasterDataForm.RecNo;

  for F in KFs do
  begin

  end;
end;

procedure TEntryClientStatusBarKeyInformation.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);
end;

constructor TEntryClientStatusBarKeyInformation.Create(
  AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);
end;

function TEntryClientStatusBarKeyInformation.GetPreferedWidth: Integer;
begin
  if not Panel.HandleAllocated then
    begin
      Result := inherited GetPreferedWidth;
      Exit;
    end;

  Result := FRecordsLabel.Left + FRecordsLabel.Width + 2;
end;

end.

