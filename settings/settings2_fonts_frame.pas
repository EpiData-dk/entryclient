unit settings2_fonts_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, EditBtn, StdCtrls, Dialogs,
  Graphics, settings, settings2_interface;

type

  { TSettingsFontsFrame }

  TSettingsFontsFrame = class(TFrame, ISettingsFrame)
    FieldColourBtn: TColorButton;
    HeadingColourBtn: TColorButton;
    SectionColourBtn: TColorButton;
    ColorDialog1: TColorDialog;
    FieldFontEditBtn: TEditButton;
    FontDialog1: TFontDialog;
    HeadingFontEditBtn: TEditButton;
    Label10: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    SectionFontEditBtn: TEditButton;
    procedure FieldColourBtnColorChanged(Sender: TObject);
    procedure FieldFontEditBtnButtonClick(Sender: TObject);
  private
    { private declarations }
    FEntrySettings: PEntrySettings;
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

{ TSettingsFontsFrame }

procedure TSettingsFontsFrame.FieldFontEditBtnButtonClick(Sender: TObject);
var
  Btn: TEditButton absolute Sender;
begin
  FontDialog1.Font.Assign(Btn.Font);
  if not FontDialog1.Execute then exit;
  SetFont(FontDialog1.Font, Btn);
end;

procedure TSettingsFontsFrame.FieldColourBtnColorChanged(Sender: TObject);
var
  Btn: TEditButton;
begin
  if Sender = FieldColourBtn then
    Btn := FieldFontEditBtn;
  if Sender = HeadingColourBtn then
    Btn := HeadingFontEditBtn;
  if SEnder = SectionColourBtn then
    Btn := SectionFontEditBtn;
  Btn.Font.Color := TColorButton(Sender).ButtonColor;
end;

procedure TSettingsFontsFrame.SetFont(AFont: TFont; Btn: TEditButton);
begin
  Btn.Text := AFont.Name + ' (' + IntToStr(AFont.Size) + ')';
  Btn.Font.Assign(AFont);
end;

procedure TSettingsFontsFrame.SetSettings(Data: PEntrySettings);
begin
  FEntrySettings := Data;

  with FEntrySettings^ do
  begin
    SetFont(FieldFont, FieldFontEditBtn);
    FieldColourBtn.ButtonColor := FieldFont.Color;
    SetFont(HeadingFont, HeadingFontEditBtn);
    HeadingColourBtn.ButtonColor := HeadingFont.Color;
    SetFont(SectionFont, SectionFontEditBtn);
    SectionColourBtn.ButtonColor := SectionFont.Color;
  end;
end;

function TSettingsFontsFrame.ApplySettings: boolean;
begin
  result := true;
  with FEntrySettings^ do
  begin
    FieldFont.Assign(FieldFontEditBtn.Font);
    HeadingFont.Assign(HeadingFontEditBtn.Font);
    SectionFont.Assign(SectionFontEditBtn.Font);
  end;
end;

initialization

begin
  RegisterSettingFrame(3, TSettingsFontsFrame, 'Fonts');
end;


end.

