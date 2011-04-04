unit settings_general_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn, MaskEdit,
  settings2_interface, settings;

type

  { TSettingsGeneralFrame }

  TSettingsGeneralFrame = class(TFrame, ISettingsFrame)
    HintTimeOutEdit: TMaskEdit;
    Label1: TLabel;
    Label2: TLabel;
    MultipleInstanceChkBox: TCheckBox;
    RecordsToSkipEdit: TMaskEdit;
    ShowWelcomeChkBox: TCheckBox;
  private
    { private declarations }
    FData: PEntrySettings;
  public
    { public declarations }
    procedure SetSettings(Data: PEntrySettings);
    function  ApplySettings: boolean;
  end;

implementation

{$R *.lfm}

uses
  settings2;

{ TSettingsGeneralFrame }

procedure TSettingsGeneralFrame.SetSettings(Data: PEntrySettings);
begin
  FData := Data;
  with FData^ do
  begin
    ShowWelcomeChkBox.Checked := ShowWelcome;
    MultipleInstanceChkBox.Checked := MultipleInstances;
    RecordsToSkipEdit.Text := IntToStr(RecordsToSkip);
    HintTimeOutEdit.Text := IntToStr(HintTimeOut);
  end;
end;

function TSettingsGeneralFrame.ApplySettings: boolean;
begin
  result := false;
  if StrToInt(RecordsToSkipEdit.Text) < 1 then exit;

  with FData^ do
  begin
    ShowWelcome := ShowWelcomeChkBox.Checked;
    MultipleInstances := MultipleInstanceChkBox.Checked;
    RecordsToSkip := StrToInt(RecordsToSkipEdit.Text);
    HintTimeOut := StrToInt(HintTimeOutEdit.Text);
  end;

  result := true;
end;

initialization

begin
  RegisterSettingFrame(0, TSettingsGeneralFrame, 'General');
end;

end.

