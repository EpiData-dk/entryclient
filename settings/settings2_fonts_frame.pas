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
    GroupBox1: TGroupBox;
    HeadingColourBtn1: TColorButton;
    HeadingColourBtn2: TColorButton;
    HeadingColourBtn3: TColorButton;
    HeadingColourBtn4: TColorButton;
    HeadingColourBtn5: TColorButton;
    HeadingFontEditBtn1: TEditButton;
    HeadingFontEditBtn2: TEditButton;
    HeadingFontEditBtn3: TEditButton;
    HeadingFontEditBtn4: TEditButton;
    HeadingFontEditBtn5: TEditButton;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label9: TLabel;
    SectionColourBtn: TColorButton;
    ColorDialog1: TColorDialog;
    FieldFontEditBtn: TEditButton;
    FontDialog1: TFontDialog;
    Label10: TLabel;
    Label2: TLabel;
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
  if SEnder = SectionColourBtn then
    Btn := SectionFontEditBtn;
  if Sender = HeadingColourBtn1 then
    Btn := HeadingFontEditBtn1;
  if Sender = HeadingColourBtn2 then
    Btn := HeadingFontEditBtn2;
  if Sender = HeadingColourBtn3 then
    Btn := HeadingFontEditBtn3;
  if Sender = HeadingColourBtn4 then
    Btn := HeadingFontEditBtn4;
  if Sender = HeadingColourBtn5 then
    Btn := HeadingFontEditBtn5;
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
    SetFont(SectionFont, SectionFontEditBtn);
    SectionColourBtn.ButtonColor := SectionFont.Color;

    SetFont(HeadingFont1, HeadingFontEditBtn1);
    HeadingColourBtn1.ButtonColor := HeadingFont1.Color;
    SetFont(HeadingFont2, HeadingFontEditBtn2);
    HeadingColourBtn2.ButtonColor := HeadingFont2.Color;
    SetFont(HeadingFont3, HeadingFontEditBtn3);
    HeadingColourBtn3.ButtonColor := HeadingFont3.Color;
    SetFont(HeadingFont4, HeadingFontEditBtn4);
    HeadingColourBtn4.ButtonColor := HeadingFont4.Color;
    SetFont(HeadingFont5, HeadingFontEditBtn5);
    HeadingColourBtn5.ButtonColor := HeadingFont5.Color;
  end;
end;

function TSettingsFontsFrame.ApplySettings: boolean;
begin
  result := true;
  with FEntrySettings^ do
  begin
    FieldFont.Assign(FieldFontEditBtn.Font);
    SectionFont.Assign(SectionFontEditBtn.Font);
    HeadingFont1.Assign(HeadingFontEditBtn1.Font);
    HeadingFont2.Assign(HeadingFontEditBtn2.Font);
    HeadingFont3.Assign(HeadingFontEditBtn3.Font);
    HeadingFont4.Assign(HeadingFontEditBtn4.Font);
    HeadingFont5.Assign(HeadingFontEditBtn5.Font);
  end;
end;

initialization

begin
  RegisterSettingFrame(3, TSettingsFontsFrame, 'Fonts');
end;


end.

