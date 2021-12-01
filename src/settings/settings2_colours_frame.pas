unit settings2_colours_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Dialogs, ExtCtrls,
  EditBtn, settings2_interface, settings, Graphics;

type

  { TSettingsColourFrame }

  TSettingsColourFrame = class(TFrame, ISettingsFrame)
    FontDialog1: TFontDialog;
    NotesFontColourBtn: TColorButton;
    NotesBgColourBtn: TColorButton;
    NotesFontEdit: TEditButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    MustEnterFieldClrBtn: TColorButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel1: TPanel;
    NotesUseSystemRadioBtn: TRadioButton;
    RadioButton2: TRadioButton;
    ValidateErrorColourBtn: TColorButton;
    ValueLabelColourBtn: TColorButton;
    ActiveFieldClrBtn: TColorButton;
    InActiveFieldClrBtn: TColorButton;
    procedure NotesFontColourBtnColorChanged(Sender: TObject);
    procedure NotesFontEditButtonClick(Sender: TObject);
    procedure NotesUseSystemRadioBtnClick(Sender: TObject);
  private
    { private declarations }
    FData: PEntrySettings;
    procedure SetFont(AFont: TFont; Btn: TEditButton);
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

procedure TSettingsColourFrame.NotesUseSystemRadioBtnClick(Sender: TObject);
begin
  Panel1.Enabled := not (NotesUseSystemRadioBtn.Checked);
end;

procedure TSettingsColourFrame.NotesFontEditButtonClick(Sender: TObject);
var
  Btn: TEditButton absolute Sender;
begin
  FontDialog1.Font.Assign(Btn.Font);
  if not FontDialog1.Execute then exit;
  SetFont(FontDialog1.Font, Btn);
end;

procedure TSettingsColourFrame.NotesFontColourBtnColorChanged(Sender: TObject);
begin
  NotesFontEdit.Font.Color := NotesFontColourBtn.ButtonColor;
end;

procedure TSettingsColourFrame.SetFont(AFont: TFont; Btn: TEditButton);
begin
  Btn.Text := AFont.Name + ' (' + IntToStr(AFont.Size) + ')';
  Btn.Font.Assign(AFont);
end;

procedure TSettingsColourFrame.SetSettings(Data: PEntrySettings);
begin
  FData := Data;
  with FData^ do
  begin
    ValidateErrorColourBtn.ButtonColor := ValidateErrorColour;
    ValueLabelColourBtn.ButtonColor    := ValueLabelColour;
    ActiveFieldClrBtn.ButtonColor      := ActiveFieldColour;
    InActiveFieldClrBtn.ButtonColor    := InactiveFieldColour;
    MustEnterFieldClrBtn.ButtonColor   := MustEnterFieldColour;
    NotesUseSystemRadioBtn.Checked     := NotesUseSystem;
    RadioButton2.Checked               := not NotesUseSystem;
    SetFont(NotesHintFont, NotesFontEdit);
    NotesFontColourBtn.ButtonColor     := NotesHintFont.Color;
    NotesBgColourBtn.ButtonColor       := NotesHintBgColor;
  end;
  NotesUseSystemRadioBtnClick(nil);
end;

function TSettingsColourFrame.ApplySettings: boolean;
begin
  with FData^ do
  begin
    ValidateErrorColour   := ValidateErrorColourBtn.ButtonColor;
    ValueLabelColour      := ValueLabelColourBtn.ButtonColor;
    ActiveFieldColour     := ActiveFieldClrBtn.ButtonColor;
    InactiveFieldColour   := InActiveFieldClrBtn.ButtonColor;
    MustEnterFieldColour  := MustEnterFieldClrBtn.ButtonColor;
    NotesUseSystem        := NotesUseSystemRadioBtn.Checked;
    NotesHintFont.Assign(NotesFontEdit.Font);
    NotesHintFont.Color   := NotesFontColourBtn.ButtonColor;
    NotesHintBgColor      := NotesBgColourBtn.ButtonColor;
  end;
  result := true;
end;

{ TSettingsColourFrame }

initialization

begin
  RegisterSettingFrame(2, TSettingsColourFrame, 'Colours');
end;

end.

