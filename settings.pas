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

    // Paths:
    WorkingDirUTF8: string;
    TutorialDirUTF8: string;
    TutorialURLUTF8: string;

    // Colours
    ValidateErrorColour: TColor;
    ValueLabelColour: TColor;
    ActiveFieldColour: TColor;
    InactiveFieldColour: TColor;

    // Fonts
    FieldFont:             TFont;
    HeadingFont:           TFont;
    SectionFont:           TFont;
  end;
  PEntrySettings = ^TEntrySettings;

const
  {$IFDEF EPI_SHOWREVISION}
    EntryVersion: TEpiVersionInfo = (
    {$I epidataentryclient.version.inc}
    );
  {$ELSE}
    EntryVersion: TEpiVersionInfo = (
      VersionNo: 0;
      MajorRev:  4;
      MinorRev:  0;
      BuildNo:   0;
    );
  {$ENDIF}

var
  EntrySettings: TEntrySettings = (
    IniFileName:    '';

    RecordsToSkip:  25;
    HintTimeOut:    15;
    ShowWelcome:    true;
    MultipleInstances: false;

    WorkingDirUTF8: '';
    TutorialDirUTF8: '';
    TutorialURLUTF8: 'http://epidata.dk/documentation.php';

    ValidateErrorColour: clYellow;
    ValueLabelColour: clBlue;
    ActiveFieldColour: clHighlight;
    InactiveFieldColour: clWhite;

    FieldFont:             nil;
    HeadingFont:           nil;
    SectionFont:           nil;
  );

  {$IFDEF EPI_SHOWREVISION}
    {$I revision.inc}
  {$ELSE}
    const RevisionStr = '(DEBUG)';
  {$ENDIF}

  function GetEntryVersion: String;
  function SaveSettingToIni(Const FileName: string): boolean;
  function LoadSettingsFromIni(Const FileName: string): boolean;

  procedure SaveFormPosition(Const AForm: TForm; Const SectionName: string);
  procedure LoadFormPosition(Var AForm: TForm; Const SectionName: string);

  procedure AddToRecent(const AFilename: string);


var
  RecentFiles: TStringList;

implementation

{$R *.lfm}

uses
  LCLProc, IniFiles;

function GetEntryVersion: String;
begin
  result := GetEpiVersionInfo(EntryVersion);
end;

function SaveSettingToIni(Const FileName: string): boolean;
var
  Ini: TIniFile;
  Sec: string;
  i: Integer;
begin
  Result := false;

  try
    Ini := TIniFile.Create(FileName);
    With Ini do
    with EntrySettings do
    begin
      Sec := 'advanced';
      WriteString(Sec, 'WorkingDirectory', WorkingDirUTF8);
      WriteString(Sec, 'TutorialDirectory', TutorialDirUTF8);
      WriteString(Sec, 'TutorialURL', TutorialURLUTF8);
      WriteInteger(Sec, 'RecordsToSkip', RecordsToSkip);
      WriteInteger(Sec, 'HintTimeOut', HintTimeOut);
      WriteBool(Sec, 'ShowWelcome', ShowWelcome);
      WriteBool(Sec, 'MultipleInstances', MultipleInstances);
      WriteInteger(Sec, 'ValidateErrorColour', ValidateErrorColour);
      WriteInteger(Sec, 'ValueLabelColour', ValueLabelColour);

      Sec := 'fonts';
      WriteString(sec, 'FieldFontName', FieldFont.Name);
      WriteInteger(sec, 'FieldFontSize', FieldFont.Size);
      WriteInteger(sec, 'FieldFontStyle', Integer(FieldFont.Style));
      WriteInteger(sec, 'FieldFontColour', FieldFont.Color);
      WriteString(sec, 'HeadingFontName', HeadingFont.Name);
      WriteInteger(sec, 'HeadingFontSize', HeadingFont.Size);
      WriteInteger(sec, 'HeadingFontStyle', Integer(HeadingFont.Style));
      WriteInteger(sec, 'HeadingFontColour', HeadingFont.Color);
      WriteString(sec, 'SectionFontName', SectionFont.Name);
      WriteInteger(sec, 'SectionFontSize', SectionFont.Size);
      WriteInteger(sec, 'SectionFontStyle', Integer(SectionFont.Style));
      WriteInteger(sec, 'SectionFontColour', SectionFont.Color);
    end;

    // Read recent files.
    for i := 0 to RecentFiles.Count - 1 do
      Ini.WriteString('recent', 'file'+inttostr(i), RecentFiles[i]);

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
begin
  Result := false;
  EntrySettings.IniFileName := FileName;

  if not FileExistsUTF8(FileName) then exit;

  Ini := TIniFile.Create(FileName);
  With Ini do
  with EntrySettings do
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
    ValidateErrorColour := ReadInteger(Sec, 'ValidateErrorColour', ValidateErrorColour);
    ValueLabelColour := ReadInteger(Sec, 'ValueLabelColour', ValueLabelColour);

    // Fonts
    Sec := 'fonts';
    FieldFont.Name   := ReadString(sec, 'FieldFontName', FieldFont.Name);
    FieldFont.Size   := ReadInteger(sec, 'FieldFontSize', FieldFont.Size);
    FieldFont.Style  := TFontStyles(ReadInteger(sec, 'FieldFontStyle', Integer(FieldFont.Style)));
    FieldFont.Color  := ReadInteger(sec, 'FieldFontColour', FieldFont.Color);
    HeadingFont.Name   := ReadString(sec, 'HeadingFontName', HeadingFont.Name);
    HeadingFont.Size   := ReadInteger(sec, 'HeadingFontSize', HeadingFont.Size);
    HeadingFont.Style  := TFontStyles(ReadInteger(sec, 'HeadingFontStyle', Integer(HeadingFont.Style)));
    HeadingFont.Color  := ReadInteger(sec, 'HeadingFontColour', HeadingFont.Color);
    SectionFont.Name   := ReadString(sec, 'SectionFontName', SectionFont.Name);
    SectionFont.Size   := ReadInteger(sec, 'SectionFontSize', SectionFont.Size);
    SectionFont.Style  := TFontStyles(ReadInteger(sec, 'SectionFontStyle', Integer(SectionFont.Style)));
    SectionFont.Color  := ReadInteger(sec, 'SectionFontColour', SectionFont.Color);

    // Read recent files.
    Sec := 'recent';
    for i := 0 to 9 do
    begin
      S := Ini.ReadString(sec, 'file'+inttostr(i), '');
      if S > '' then
        RecentFiles.Add(S);
    end;
  end;
end;

procedure SaveFormPosition(const AForm: TForm; const SectionName: string);
var
  Ini: TIniFile;
begin
  if EntrySettings.IniFileName = '' then exit;

  try
    Ini := TIniFile.Create(EntrySettings.IniFileName);
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

procedure LoadFormPosition(var AForm: TForm; const SectionName: string);
var
  Ini: TIniFile;
begin
  if EntrySettings.IniFileName = '' then exit;

  try
    Ini := TIniFile.Create(EntrySettings.IniFileName);
    With Ini do
    with AForm do
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
end;


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
  EntrySettings.HeadingFont := TFont.Create;
  EntrySettings.SectionFont := TFont.Create;

  EntrySettings.WorkingDirUTF8 := GetCurrentDirUTF8 + DirectorySeparator + 'data';
  if not DirectoryExistsUTF8(EntrySettings.WorkingDirUTF8) then
    EntrySettings.WorkingDirUTF8 := GetCurrentDirUTF8;

  EntrySettings.TutorialDirUTF8 := GetCurrentDirUTF8 + DirectorySeparator + 'tutorials';
  if not DirectoryExistsUTF8(EntrySettings.TutorialDirUTF8) then
    EntrySettings.TutorialDirUTF8 := GetCurrentDirUTF8;

  RecentFiles := TStringList.Create;
end;

finalization

begin
  RecentFiles.Free;
end;

end.
