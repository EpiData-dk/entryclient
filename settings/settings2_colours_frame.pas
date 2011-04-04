unit settings2_colours_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Dialogs,
  settings2_interface, settings;

type

  { TSettingsColourFrame }

  TSettingsColourFrame = class(TFrame, ISettingsFrame)
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ValidateErrorColourBtn: TColorButton;
    ValueLabelColourBtn: TColorButton;
    ActiveFieldClrBtn: TColorButton;
    InActiveFieldClrBtn: TColorButton;
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

{ TSettingsColourFrame }

procedure TSettingsColourFrame.SetSettings(Data: PEntrySettings);
begin
  FData := Data;
  with FData^ do
  begin
    ValidateErrorColourBtn.ButtonColor := ValidateErrorColour;
    ValueLabelColourBtn.ButtonColor := ValueLabelColour;
    ActiveFieldClrBtn.ButtonColor := ActiveFieldColour;
    InActiveFieldClrBtn.ButtonColor := InactiveFieldColour;
  end;
end;

function TSettingsColourFrame.ApplySettings: boolean;
begin
  with FData^ do
  begin
    ValidateErrorColour := ValidateErrorColourBtn.ButtonColor;
    ValueLabelColour := ValueLabelColourBtn.ButtonColor;
    ActiveFieldColour := ActiveFieldClrBtn.ButtonColor;
    InactiveFieldColour := InActiveFieldClrBtn.ButtonColor;
  end;
  result := true;
end;

{ TSettingsColourFrame }

initialization

begin
  RegisterSettingFrame(2, TSettingsColourFrame, 'Colours');
end;

end.

