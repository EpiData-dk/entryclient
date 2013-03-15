unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  EditBtn, StdCtrls, ExtCtrls, ComCtrls, Buttons, MaskEdit,
  epiversionutils;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label5: TLabel;
    ValidateErrorColourBtn: TColorButton;
    Label4: TLabel;
    MultipleInstanceChkBox: TCheckBox;
    TutorialURLEdit: TEdit;
    Label18: TLabel;
    Label3: TLabel;
    ShowWelcomeChkBox: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    RecordsToSkipEdit: TMaskEdit;
    HintTimeOutEdit: TMaskEdit;
    ValueLabelColourBtn: TColorButton;
    WorkingDirEdit: TDirectoryEdit;
    Label17: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TutorialDirEdit: TDirectoryEdit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;


  TEntrySettings = record
    // Non-user changeable
    IniFileName:    string;

    // General:
    RecordsToSkip:  Integer;
    HintTimeOut:    Integer;
    ShowWelcome:    boolean;
    MultipleInstances: boolean;
    ShowWorkToolbar: boolean;
    NotesDisplay:   byte;   // 0 = Show as hint, 1 = Show in window.
    CopyToClipBoardFormat: string;

    // Paths:
    WorkingDirUTF8: string;
    TutorialDirUTF8: string;
    TutorialURLUTF8: string;

    // Colours
    ValidateErrorColour: TColor;
    ValueLabelColour: TColor;
    ActiveFieldColour: TColor;
    InactiveFieldColour: TColor;
    MustEnterFieldColour: TColor;

    // Fonts
    FieldFont:             TFont;
    SectionFont:           TFont;
    HeadingFont1:          TFont;
    HeadingFont2:          TFont;
    HeadingFont3:          TFont;
    HeadingFont4:          TFont;
    HeadingFont5:          TFont;
  end;
  PEntrySettings = ^TEntrySettings;

const
  EntryVersion: TEpiVersionInfo = (
  {$I epidataentryclient.version.inc}
  );

var
  EntrySettings: TEntrySettings = (
    IniFileName:    '';

    RecordsToSkip:  25;
    HintTimeOut:    15;
    ShowWelcome:    true;
    MultipleInstances: false;
    ShowWorkToolbar: true;
    NotesDisplay:   0;
    CopyToClipBoardFormat: '%f\t%q\t%d\t%v\n';

    WorkingDirUTF8: '';
    TutorialDirUTF8: '';
    TutorialURLUTF8: 'http://epidata.dk/documentation.php';

    ValidateErrorColour: clYellow;
    ValueLabelColour: clBlue;
    ActiveFieldColour: TCOlor($FFC26B);
    InactiveFieldColour: clWhite;
    MustEnterFieldColour: clRed;

    FieldFont:             nil;
    SectionFont:           nil;
    HeadingFont1:          nil;
    HeadingFont2:          nil;
    HeadingFont3:          nil;
    HeadingFont4:          nil;
    HeadingFont5:          nil;
  );

  {$I epidataentryclient.revision.inc}

  function GetEntryVersion: String;

  function SaveSettingToIni(Const FileName: string): boolean;
  function LoadSettingsFromIni(Const FileName: string): boolean;
  function SaveRecentFilesToIni(Const FileName: string): boolean;
  function LoadRecentFilesIni(Const FileName: string): boolean;

  procedure SaveFormPosition(Const AForm: TForm; Const SectionName: string);
  procedure LoadFormPosition(AForm: TForm; Const SectionName: string);

  procedure AddToRecent(const AFilename: string);

  procedure InitFont(Font: TFont);

var
  RecentFiles: TStringList;

implementation

{$R *.lfm}

uses
  LCLProc, IniFiles;

const
  RecentIniFileName: string = '';

function GetEntryVersion: String;
begin
  result := GetEpiVersionInfo(HINSTANCE);
end;

function GetIniFile(Const FileName: String): TIniFile;
begin
  result := TIniFile.Create(UTF8ToSys(FileName));
end;

function SaveSettingToIni(Const FileName: string): boolean;
var
  Ini: TIniFile;
  Sec: string;
  i: Integer;
begin
  Result := false;

  try
    Ini := GetIniFile(FileName);
    With Ini, EntrySettings do
    begin
      Sec := 'advanced';
      WriteString(Sec, 'WorkingDirectory', WorkingDirUTF8);
      WriteString(Sec, 'TutorialDirectory', TutorialDirUTF8);
      WriteString(Sec, 'TutorialURL', TutorialURLUTF8);
      WriteInteger(Sec, 'RecordsToSkip', RecordsToSkip);
      WriteInteger(Sec, 'HintTimeOut', HintTimeOut);
      WriteBool(Sec, 'ShowWelcome', ShowWelcome);
      WriteBool(Sec, 'MultipleInstances', MultipleInstances);
      WriteInteger(Sec, 'NotesDisplay', NotesDisplay);
      WriteString(Sec, 'CopyToClipBoardFormat', CopyToClipBoardFormat);

      Sec := 'fonts';
      WriteString(sec, 'FieldFontName', FieldFont.Name);
      WriteInteger(sec, 'FieldFontSize', FieldFont.Size);
      WriteInteger(sec, 'FieldFontStyle', Integer(FieldFont.Style));
      WriteInteger(sec, 'FieldFontColour', FieldFont.Color);
      WriteString(sec, 'SectionFontName', SectionFont.Name);
      WriteInteger(sec, 'SectionFontSize', SectionFont.Size);
      WriteInteger(sec, 'SectionFontStyle', Integer(SectionFont.Style));
      WriteInteger(sec, 'SectionFontColour', SectionFont.Color);

      WriteString(sec, 'HeadingFontName1', HeadingFont1.Name);
      WriteInteger(sec, 'HeadingFontSize1', HeadingFont1.Size);
      WriteInteger(sec, 'HeadingFontStyle1', Integer(HeadingFont1.Style));
      WriteInteger(sec, 'HeadingFontColour1', HeadingFont1.Color);
      WriteString(sec, 'HeadingFontName2', HeadingFont2.Name);
      WriteInteger(sec, 'HeadingFontSize2', HeadingFont2.Size);
      WriteInteger(sec, 'HeadingFontStyle2', Integer(HeadingFont2.Style));
      WriteInteger(sec, 'HeadingFontColour2', HeadingFont2.Color);
      WriteString(sec, 'HeadingFontName3', HeadingFont3.Name);
      WriteInteger(sec, 'HeadingFontSize3', HeadingFont3.Size);
      WriteInteger(sec, 'HeadingFontStyle3', Integer(HeadingFont3.Style));
      WriteInteger(sec, 'HeadingFontColour3', HeadingFont3.Color);
      WriteString(sec, 'HeadingFontName4', HeadingFont4.Name);
      WriteInteger(sec, 'HeadingFontSize4', HeadingFont4.Size);
      WriteInteger(sec, 'HeadingFontStyle4', Integer(HeadingFont4.Style));
      WriteInteger(sec, 'HeadingFontColour4', HeadingFont4.Color);
      WriteString(sec, 'HeadingFontName5', HeadingFont5.Name);
      WriteInteger(sec, 'HeadingFontSize5', HeadingFont5.Size);
      WriteInteger(sec, 'HeadingFontStyle5', Integer(HeadingFont5.Style));
      WriteInteger(sec, 'HeadingFontColour5', HeadingFont5.Color);

      Sec := 'colour';
      WriteInteger(Sec, 'ValidateErrorColour', ValidateErrorColour);
      WriteInteger(Sec, 'ValueLabelColour', ValueLabelColour);
      WriteInteger(Sec, 'ActiveFieldColour', ActiveFieldColour);
      WriteInteger(Sec, 'InactiveFieldColour', InactiveFieldColour);
      WriteInteger(Sec, 'MustEnterFieldColour', MustEnterFieldColour);
    end;

    Result := true;
  finally
    Ini.Free;
  end;
end;

function LoadSettingsFromIni(Const FileName: string): boolean;
var
  Ini: TIniFile;
  Sec: String;
  i: Integer;
  S: String;

  procedure CorrectFont(F: TFont);
  begin
    if (F.Name = '') or
       (LowerCase(F.Name) = 'default') or
       (F.Size = 0)
    then
      InitFont(F);
  end;

begin
  Result := false;
  EntrySettings.IniFileName := FileName;

  if not FileExistsUTF8(FileName) then exit;

  Ini := GetIniFile(FileName);
  With Ini, EntrySettings do
  begin
{    // Advanced:
    WorkingDirUTF8:        string;}
    Sec := 'advanced';
    WorkingDirUTF8   := ReadString(Sec, 'WorkingDirectory', WorkingDirUTF8);
    TutorialDirUTF8  := ReadString(Sec, 'TutorialDirectory', TutorialDirUTF8);
    TutorialURLUTF8  := ReadString(Sec, 'TutorialURL', TutorialURLUTF8);
    RecordsToSkip    := ReadInteger(Sec, 'RecordsToSkip', RecordsToSkip);
    HintTimeOut      := ReadInteger(Sec, 'HintTimeout', HintTimeOut);
    ShowWelcome      := ReadBool(Sec, 'ShowWelcome', ShowWelcome);
    MultipleInstances := ReadBool(Sec, 'MultipleInstances', MultipleInstances);
    NotesDisplay      := ReadInteger(Sec, 'NotesDisplay', NotesDisplay);
    CopyToClipBoardFormat := ReadString(Sec, 'CopyToClipBoardFormat', CopyToClipBoardFormat);

    // Fonts
    Sec := 'fonts';
    FieldFont.Name   := ReadString(sec, 'FieldFontName', FieldFont.Name);
    FieldFont.Size   := ReadInteger(sec, 'FieldFontSize', FieldFont.Size);
    FieldFont.Style  := TFontStyles(ReadInteger(sec, 'FieldFontStyle', Integer(FieldFont.Style)));
    FieldFont.Color  := ReadInteger(sec, 'FieldFontColour', FieldFont.Color);
    CorrectFont(FieldFont);
    SectionFont.Name   := ReadString(sec, 'SectionFontName', SectionFont.Name);
    SectionFont.Size   := ReadInteger(sec, 'SectionFontSize', SectionFont.Size);
    SectionFont.Style  := TFontStyles(ReadInteger(sec, 'SectionFontStyle', Integer(SectionFont.Style)));
    SectionFont.Color  := ReadInteger(sec, 'SectionFontColour', SectionFont.Color);
    CorrectFont(SectionFont);
    HeadingFont1.Name   := ReadString(sec, 'HeadingFontName1', HeadingFont1.Name);
    HeadingFont1.Size   := ReadInteger(sec, 'HeadingFontSize1', HeadingFont1.Size);
    HeadingFont1.Style  := TFontStyles(ReadInteger(sec, 'HeadingFontStyle1', Integer(HeadingFont1.Style)));
    HeadingFont1.Color  := ReadInteger(sec, 'HeadingFontColour1', HeadingFont1.Color);
    CorrectFont(HeadingFont1);
    HeadingFont2.Name   := ReadString(sec, 'HeadingFontName2', HeadingFont2.Name);
    HeadingFont2.Size   := ReadInteger(sec, 'HeadingFontSize2', HeadingFont2.Size);
    HeadingFont2.Style  := TFontStyles(ReadInteger(sec, 'HeadingFontStyle2', Integer(HeadingFont2.Style)));
    HeadingFont2.Color  := ReadInteger(sec, 'HeadingFontColour2', HeadingFont2.Color);
    CorrectFont(HeadingFont2);
    HeadingFont3.Name   := ReadString(sec, 'HeadingFontName3', HeadingFont3.Name);
    HeadingFont3.Size   := ReadInteger(sec, 'HeadingFontSize3', HeadingFont3.Size);
    HeadingFont3.Style  := TFontStyles(ReadInteger(sec, 'HeadingFontStyle3', Integer(HeadingFont3.Style)));
    HeadingFont3.Color  := ReadInteger(sec, 'HeadingFontColour3', HeadingFont3.Color);
    CorrectFont(HeadingFont3);
    HeadingFont4.Name   := ReadString(sec, 'HeadingFontName4', HeadingFont4.Name);
    HeadingFont4.Size   := ReadInteger(sec, 'HeadingFontSize4', HeadingFont4.Size);
    HeadingFont4.Style  := TFontStyles(ReadInteger(sec, 'HeadingFontStyle4', Integer(HeadingFont4.Style)));
    HeadingFont4.Color  := ReadInteger(sec, 'HeadingFontColour4', HeadingFont4.Color);
    CorrectFont(HeadingFont4);
    HeadingFont5.Name   := ReadString(sec, 'HeadingFontName5', HeadingFont5.Name);
    HeadingFont5.Size   := ReadInteger(sec, 'HeadingFontSize5', HeadingFont5.Size);
    HeadingFont5.Style  := TFontStyles(ReadInteger(sec, 'HeadingFontStyle5', Integer(HeadingFont5.Style)));
    HeadingFont5.Color  := ReadInteger(sec, 'HeadingFontColour5', HeadingFont5.Color);
    CorrectFont(HeadingFont5);

    // Color
    Sec := 'colour';
    ValidateErrorColour := ReadInteger(Sec, 'ValidateErrorColour', ValidateErrorColour);
    ValueLabelColour    := ReadInteger(Sec, 'ValueLabelColour', ValueLabelColour);
    ActiveFieldColour   := ReadInteger(Sec, 'ActiveFieldColour', ActiveFieldColour);
    InactiveFieldColour := ReadInteger(Sec, 'InactiveFieldColour', InactiveFieldColour);
    MustEnterFieldColour := ReadInteger(Sec, 'MustEnterFieldColour', MustEnterFieldColour);
  end;
  Result := true;
end;

function SaveRecentFilesToIni(const FileName: string): boolean;
var
  Ini: TIniFile;
  Fn: String;
  i: Integer;
begin
  Result := false;

  Fn := FileName;
  if (RecentIniFileName <> '') and
     (FileName = '')
  then
    Fn := RecentIniFileName;

  try
    Ini := GetIniFile(Fn);

    for i := 0 to RecentFiles.Count - 1 do
      Ini.WriteString('Files', 'file'+inttostr(i), RecentFiles[i]);
  finally
    Ini.Free;
  end;
end;

function LoadRecentFilesIni(const FileName: string): boolean;
var
  Ini: TIniFile;
  Sec: String;
  i: Integer;
  S: String;
begin
  Result := false;

  // trick - store filename in const :)
  // and use in save recent.
  if RecentIniFileName = '' then RecentIniFileName := FileName;

  try
    Ini := GetIniFile(FileName);

    // Read recent files.
    Sec := 'Files';
    for i := 0 to 9 do
    begin
      S := Ini.ReadString(sec, 'file'+inttostr(i), '');
      if S <> '' then
        RecentFiles.Add(S);
    end;
  finally
    Ini.Free;
  end;
end;
procedure SaveFormPosition(const AForm: TForm; const SectionName: string);
var
  Ini: TIniFile;
begin
  if EntrySettings.IniFileName = '' then exit;

  try
    Ini := GetIniFile(EntrySettings.IniFileName);
    With Ini, AForm do
    begin
      WriteInteger(SectionName, 'Top', Top);
      WriteInteger(SectionName, 'Left', Left);
      WriteInteger(SectionName, 'Width', Width);
      WriteInteger(SectionName, 'Height', Height);
    end;
  finally
    Ini.Free;
  end;
end;

procedure LoadFormPosition(AForm: TForm; const SectionName: string);
var
  Ini: TIniFile;
begin
  if EntrySettings.IniFileName = '' then exit;

  try
    Ini := GetIniFile(EntrySettings.IniFileName);
    With Ini, AForm do
    begin
      Top     := ReadInteger(SectionName, 'Top', Top);
      Left    := ReadInteger(SectionName, 'Left', Left);
      Width   := ReadInteger(SectionName, 'Width', Width);
      Height  := ReadInteger(SectionName, 'Height', Height);
    end;
  finally
    Ini.Free;
  end;
end;

procedure AddToRecent(const AFilename: string);
var
  Idx: Integer;
begin
  Idx := RecentFiles.IndexOf(AFilename);
  if (Idx >= 0) then
    RecentFiles.Exchange(Idx, 0)
  else
    RecentFiles.Insert(0, AFilename);
  if RecentFiles.Count > 10 then
    RecentFiles.Delete(10);

  SaveRecentFilesToIni('');
end;

{$I initfont.inc}

{ TSettingsForm }

procedure TSettingsForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := true;
  if ModalResult = mrCancel then exit;

  CanClose := false;
  if not DirectoryExistsUTF8(WorkingDirEdit.Text) then exit;
  if not DirectoryExistsUTF8(TutorialDirEdit.Text) then exit;
  if not (
      (LeftStr(UTF8LowerCase(TutorialURLEdit.Text), 7) = 'http://') or
      (LeftStr(UTF8LowerCase(TutorialURLEdit.Text), 8) = 'https://')) then exit;
  if StrToInt(RecordsToSkipEdit.Text) < 1 then exit;

  EntrySettings.WorkingDirUTF8 := WorkingDirEdit.Text;
  EntrySettings.TutorialDirUTF8 := TutorialDirEdit.Text;
  EntrySettings.TutorialURLUTF8 := TutorialURLEdit.Text;
  EntrySettings.RecordsToSkip := StrToInt(RecordsToSkipEdit.Text);
  EntrySettings.HintTimeOut := StrToInt(HintTimeOutEdit.Text);
  EntrySettings.ShowWelcome := ShowWelcomeChkBox.Checked;
  EntrySettings.MultipleInstances := MultipleInstanceChkBox.Checked;
  EntrySettings.ValidateErrorColour := ValidateErrorColourBtn.ButtonColor;
  EntrySettings.ValueLabelColour := ValueLabelColourBtn.ButtonColor;

  SaveSettingToIni(EntrySettings.IniFileName);
  CanClose := true;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  with EntrySettings do
  begin
    WorkingDirEdit.Text := WorkingDirUTF8;
    TutorialDirEdit.Text := TutorialDirUTF8;
    TutorialURLEdit.Text := TutorialURLUTF8;
    RecordsToSkipEdit.Text := IntToStr(RecordsToSkip);
    HintTimeOutEdit.Text := IntToStr(HintTimeOut);
    ShowWelcomeChkBox.Checked := ShowWelcome;
    MultipleInstanceChkBox.Checked := MultipleInstances;
    ValidateErrorColourBtn.ButtonColor := ValidateErrorColour;
    ValueLabelColourBtn.ButtonColor := ValueLabelColour;
  end;
end;

initialization

begin
  EntrySettings.FieldFont := TFont.Create;
  EntrySettings.SectionFont := TFont.Create;
  EntrySettings.HeadingFont1 := TFont.Create;
  EntrySettings.HeadingFont2 := TFont.Create;
  EntrySettings.HeadingFont3 := TFont.Create;
  EntrySettings.HeadingFont4 := TFont.Create;
  EntrySettings.HeadingFont5 := TFont.Create;
  InitFont(EntrySettings.FieldFont);
  InitFont(EntrySettings.SectionFont);
  InitFont(EntrySettings.HeadingFont1);
  EntrySettings.HeadingFont1.Size := Trunc(EntrySettings.HeadingFont1.Size * 2.0);
  InitFont(EntrySettings.HeadingFont2);
  EntrySettings.HeadingFont2.Size := Trunc(EntrySettings.HeadingFont2.Size * 1.5);
  InitFont(EntrySettings.HeadingFont3);
  EntrySettings.HeadingFont3.Size := Trunc(EntrySettings.HeadingFont3.Size * 1.2);
  InitFont(EntrySettings.HeadingFont4);
  EntrySettings.HeadingFont4.Size := Trunc(EntrySettings.HeadingFont4.Size * 1.0);
  InitFont(EntrySettings.HeadingFont5);
  EntrySettings.HeadingFont5.Size := Trunc(EntrySettings.HeadingFont5.Size * 0.8);

  EntrySettings.WorkingDirUTF8 := GetCurrentDirUTF8 + DirectorySeparator + 'data';
  if not DirectoryExistsUTF8(EntrySettings.WorkingDirUTF8) then
    EntrySettings.WorkingDirUTF8 := GetCurrentDirUTF8;

  EntrySettings.TutorialDirUTF8 := GetCurrentDirUTF8 + DirectorySeparator + 'tutorials';
  if not DirectoryExistsUTF8(EntrySettings.TutorialDirUTF8) then
    EntrySettings.TutorialDirUTF8 := GetCurrentDirUTF8;

  RecentFiles := TStringList.Create;
  RecentFiles.CaseSensitive := true;
end;

finalization

begin
  RecentFiles.Free;
end;

end.
