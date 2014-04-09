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
  public
    { public declarations }
    procedure SetSettings(Data: PEntrySettings);
    function  ApplySettings: boolean;
  end;

implementation

{$R *.lfm}

uses
  settings2;

{ TRelateFrame }

procedure TRelateFrame.SetSettings(Data: PEntrySettings);
begin

end;

function TRelateFrame.ApplySettings: boolean;
begin
  result := true;
end;

initialization

begin
 RegisterSettingFrame(4, TRelateFrame, 'Relate');
end;

end.

