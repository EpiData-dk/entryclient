unit settings2_relate_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, settings2_interface,
  settings;

type

  { TRelateFrame }

  TRelateFrame = class(TFrame, ISettingsFrame)
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
  private
    { private declarations }
    FData: PEntrySettings;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    procedure SetSettings(Data: PEntrySettings);
    function  ApplySettings: boolean;
  end;

implementation

{$R *.lfm}

uses
  settings2, setting_types;

{ TRelateFrame }

constructor TRelateFrame.Create(TheOwner: TComponent);
var
  MRR: TSettingRelateMaxRecordReached;
  RRC: TSettingRelateRecordChanged;
begin
  inherited Create(TheOwner);

  RadioGroup1.Items.BeginUpdate;
  RadioGroup2.Items.BeginUpdate;

  RadioGroup1.Items.Clear;
  RadioGroup2.Items.Clear;

  for MRR in TSettingRelateMaxRecordReached do
    RadioGroup1.Items.AddObject(
      TSettingRelateMaxRecordReachedStrings[MRR],
      TObject(PtrInt(MRR))
    );

  for RRC in TSettingRelateRecordChanged do
    RadioGroup2.Items.AddObject(
      TSettingRelateRecordChangedStrings[RRC],
      TObject(PtrInt(RRC))
    );

  RadioGroup1.Items.EndUpdate;
  RadioGroup2.Items.EndUpdate;
end;

procedure TRelateFrame.SetSettings(Data: PEntrySettings);
begin
  FData := Data;

  with FData^ do
  begin
{    RadioGroup1.ItemIndex := RadioGroup1.Items.IndexOfObject(
      TObject(PtrInt(RelateMaxRecsReached))
    );

    RadioGroup2.ItemIndex := RadioGroup2.Items.IndexOfObject(
      TObject(PtrInt(RelateChangeRecord))
    );   }
  end;
end;

function TRelateFrame.ApplySettings: boolean;
begin
  with FData^ do
  begin
//    RelateMaxRecsReached := TSettingRelateMaxRecordReached(PtrInt(RadioGroup1.Items.Objects[RadioGroup1.ItemIndex]));
//    RelateChangeRecord   := TSettingRelateRecordChanged(PtrInt(RadioGroup2.Items.Objects[RadioGroup2.ItemIndex]));
  end;

  result := true;
end;

initialization

begin
// RegisterSettingFrame(4, TRelateFrame, 'Relate');
end;

end.

