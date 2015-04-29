unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  EditBtn, StdCtrls, ExtCtrls, ComCtrls, Buttons, MaskEdit,
  epiversionutils, setting_types;

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
    // General:
    RecordsToSkip:  Integer;
    HintTimeOut:    Integer;
    MultipleInstances: boolean;
    ShowWorkToolbar: boolean;
    NotesDisplay:   byte;   // 0 = Show as hint, 1 = Show in window.
    CopyToClipBoardFormat: string;
    ValueLabelsAsNotes: boolean;
    CheckForUpdates: boolean;
    DaysBetweenChecks: byte;
    LastUpdateCheck: TDateTime;


    // Paths:
    WorkingDirUTF8: string;
    TutorialDirUTF8: string;
    TutorialURLUTF8: string;
    BackupDirUTF8: string;

    // Colours
    ValidateErrorColour: TColor;
    ValueLabelColour: TColor;
    ActiveFieldColour: TColor;
    InactiveFieldColour: TColor;
    MustEnterFieldColour: TColor;

    // Hint window (notes/valuelabels/ranges)
    NotesUseSystem:        Boolean;
    NotesHintBgColor:      TColor;
    NotesHintFont:         TFont;

    // Fonts
    FieldFont:             TFont;
    SectionFont:           TFont;
    HeadingFont1:          TFont;
    HeadingFont2:          TFont;
    HeadingFont3:          TFont;
    HeadingFont4:          TFont;
    HeadingFont5:          TFont;

    // Relate
//    RelateMaxRecsReached:  TSettingRelateMaxRecordReached;
//    RelateChangeRecord:    TSettingRelateRecordChanged;
  end;
  PEntrySettings = ^TEntrySettings;

const
  EntryVersion: TEpiVersionInfo = (
  {$I epidataentryclient.version.inc}
  );

var
  EntrySettings: TEntrySettings;

  {$I epidataentryclient.revision.inc}

  function GetEntryVersion: String;

  function SaveSettingToIni(Const FileName: string): boolean;
  function LoadSettingsFromIni(Const FileName: string): boolean;
  function SaveRecentFilesToIni(Const FileName: string): boolean;
  function LoadRecentFilesIni(Const FileName: string): boolean;

  procedure SaveFormPosition(Const AForm: TForm; Const SectionName: string);
  procedure LoadFormPosition(AForm: TForm; Const SectionName: string);

  procedure SaveSplitterPosition(Const ASplitter: TSplitter; Const SectionName: string);
  procedure LoadSplitterPosition(ASplitter: TSplitter; Const SectionName: string);

  procedure AddToRecent(const AFilename: string);

  procedure InitFont(Font: TFont);
  procedure RestoreSettingsDefaults;

var
  RecentFiles: TStringList;
  // Startup files are a list of files that the program should
  // open. This list is gathered during parsing commandline options.
  // Maintained from "entryprocs.pas"
  StartupFiles: TStringList = nil;

implementation

{$R *.lfm}

uses
  LCLProc, IniFiles, entryprocs, FileUtil, LazFileUtils;

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
      WriteBool(Sec, 'MultipleInstances', MultipleInstances);
      WriteInteger(Sec, 'NotesDisplay', NotesDisplay);
      WriteString(Sec, 'CopyToClipBoardFormat', CopyToClipBoardFormat);
      WriteBool(Sec, 'ValueLabelsAsNotes', ValueLabelsAsNotes);
      WriteBool(Sec, 'CheckForUpdates', CheckForUpdates);
      WriteInteger(Sec, 'DaysBetweenChecks', DaysBetweenChecks);
      WriteDateTime(Sec, 'LastUpdateCheck', LastUpdateCheck);

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

      Sec := 'noteshint';
      WriteBool(Sec, 'NotesUseSystem', NotesUseSystem);
      WriteInteger(Sec, 'NotesHintBgColor', NotesHintBgColor);
      WriteString(Sec, 'NotesHintFont', NotesHintFont.Name);
      WriteInteger(sec, 'NotesHintFontSize', NotesHintFont.Size);
      WriteInteger(sec, 'NotesHintFontStyle', Integer(NotesHintFont.Style));
      WriteInteger(sec, 'NotesHintFontColour', NotesHintFont.Color);

      Sec := 'relate';
//      WriteInteger(Sec, 'RelateMaxRecsReached', Integer(RelateMaxRecsReached));
//      WriteInteger(Sec, 'RelateChangeRecord', Integer(RelateChangeRecord));
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

  if FileName = '' then exit;

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
    MultipleInstances := ReadBool(Sec, 'MultipleInstances', MultipleInstances);
    NotesDisplay      := ReadInteger(Sec, 'NotesDisplay', NotesDisplay);
    CopyToClipBoardFormat := ReadString(Sec, 'CopyToClipBoardFormat', CopyToClipBoardFormat);
    ValueLabelsAsNotes := ReadBool(Sec, 'ValueLabelsAsNotes', ValueLabelsAsNotes);
    CheckForUpdates    := ReadBool(Sec, 'CheckForUpdates', CheckForUpdates);
    DaysBetweenChecks  := ReadInteger(Sec, 'DaysBetweenChecks', DaysBetweenChecks);
    LastUpdateCheck    := ReadDateTime(Sec, 'LastUpdateCheck', LastUpdateCheck);

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

    Sec := 'noteshint';
    NotesUseSystem      := ReadBool(Sec, 'NotesUseSystem', NotesUseSystem);
    NotesHintBgColor    := ReadInteger(Sec, 'NotesHintBgColor', NotesHintBgColor);
    NotesHintFont.Name  := ReadString(Sec, 'NotesHintFont', NotesHintFont.Name);
    NotesHintFont.Size  := ReadInteger(sec, 'NotesHintFontSize', NotesHintFont.Size);
    NotesHintFont.Style := TFontStyles(ReadInteger(sec, 'NotesHintFontStyle', Integer(NotesHintFont.Style)));
    NotesHintFont.Color := ReadInteger(sec, 'NotesHintFontColour', NotesHintFont.Color);

    // Relate
    Sec := 'relate';
//    RelateMaxRecsReached := TSettingRelateMaxRecordReached(ReadInteger(Sec, 'RelateMaxRecsReached', Integer(RelateMaxRecsReached)));
//    RelateChangeRecord := TSettingRelateRecordChanged(ReadInteger(Sec, 'RelateChangeRecord', Integer(RelateChangeRecord)));
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

  try
    Ini := GetIniFile(FileName);

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

  try
    Ini := GetIniFile(FileName);
    RecentFiles.Clear;

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
  try
    Ini := GetIniFile(GetIniFileName);
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
  try
    Ini := GetIniFile(GetIniFileName);
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

procedure SaveSplitterPosition(const ASplitter: TSplitter;
  const SectionName: string);
var
  Ini: TIniFile;
begin
  try
    Ini := GetIniFile(GetIniFileName);
    Ini.WriteInteger(SectionName, 'SplitterPosition', ASplitter.GetSplitterPosition);
  finally
    Ini.Free;
  end;
end;

procedure LoadSplitterPosition(ASplitter: TSplitter; const SectionName: string);
var
  Ini: TIniFile;
begin
  try
    Ini := GetIniFile(GetIniFileName);
    ASplitter.SetSplitterPosition(
      Ini.ReadInteger(SectionName, 'SplitterPosition', ASplitter.GetSplitterPosition)
    );
  finally
    Ini.Free;
  end;
end;

procedure AddToRecent(const AFilename: string);
var
  Idx: Integer;
  Fn: String;
begin
  Fn := ExpandFileNameUTF8(AFilename);

  Idx := RecentFiles.IndexOf(Fn);
  if (Idx >= 0) then
    RecentFiles.Move(Idx, 0)
  else
    RecentFiles.Insert(0, Fn);
  if RecentFiles.Count > 10 then
    RecentFiles.Delete(10);

  SaveRecentFilesToIni(GetRecentIniFileName);
end;

{$I initfont.inc}

procedure RestoreSettingsDefaults;
const
  OriginalSettings: TEntrySettings = (
    RecordsToSkip:          25;
    HintTimeOut:            15;
    MultipleInstances:      false;
    ShowWorkToolbar:        true;
    NotesDisplay:           0;
    CopyToClipBoardFormat: '%f\t%q\t%d\t%v\n';
    ValueLabelsAsNotes:    true;
    CheckForUpdates:       true;
    DaysBetweenChecks:     7;
    LastUpdateCheck:       0;

    WorkingDirUTF8:        '';
    TutorialDirUTF8:       '';
    TutorialURLUTF8:       'http://epidata.dk/documentation.php';
    BackupDirUTF8:         '';

    ValidateErrorColour:   clYellow;
    ValueLabelColour:      clBlue;
    ActiveFieldColour:     TColor($FFC26B);
    InactiveFieldColour:   clWhite;
    MustEnterFieldColour:  clRed;

    // Color:
    NotesUseSystem:        true;
    NotesHintBgColor:      clInfoBk;
    NotesHintFont:         nil;

    FieldFont:             nil;
    SectionFont:           nil;
    HeadingFont1:          nil;
    HeadingFont2:          nil;
    HeadingFont3:          nil;
    HeadingFont4:          nil;
    HeadingFont5:          nil;
  );
begin
  with EntrySettings do
  begin
    if Assigned(FieldFont) then FieldFont.Free;
    if Assigned(SectionFont) then SectionFont.Free;
    if Assigned(HeadingFont1) then HeadingFont1.Free;
    if Assigned(HeadingFont2) then HeadingFont2.Free;
    if Assigned(HeadingFont3) then HeadingFont3.Free;
    if Assigned(HeadingFont4) then HeadingFont4.Free;
    if Assigned(HeadingFont5) then HeadingFont5.Free;
  end;

  EntrySettings := OriginalSettings;

  with EntrySettings do
  begin
    NotesHintFont := TFont.Create;
    FieldFont := TFont.Create;
    SectionFont := TFont.Create;
    HeadingFont1 := TFont.Create;
    HeadingFont2 := TFont.Create;
    HeadingFont3 := TFont.Create;
    HeadingFont4 := TFont.Create;
    HeadingFont5 := TFont.Create;

    InitFont(NotesHintFont);
    InitFont(FieldFont);
    InitFont(SectionFont);
    InitFont(HeadingFont1);
    InitFont(HeadingFont2);
    InitFont(HeadingFont3);
    InitFont(HeadingFont4);
    InitFont(HeadingFont5);

    HeadingFont1.Size := Trunc(HeadingFont1.Size * 2.0);
    HeadingFont2.Size := Trunc(HeadingFont2.Size * 1.5);
    HeadingFont3.Size := Trunc(HeadingFont3.Size * 1.2);
    HeadingFont4.Size := Trunc(HeadingFont4.Size * 1.0);
    HeadingFont5.Size := Trunc(HeadingFont5.Size * 0.8);
  end;

  EntrySettings.WorkingDirUTF8 := GetCurrentDirUTF8 + DirectorySeparator + 'data';
  if not DirectoryExistsUTF8(EntrySettings.WorkingDirUTF8) then
    EntrySettings.WorkingDirUTF8 := GetCurrentDirUTF8;

  EntrySettings.TutorialDirUTF8 := GetCurrentDirUTF8 + DirectorySeparator + 'tutorials';
  if not DirectoryExistsUTF8(EntrySettings.TutorialDirUTF8) then
    EntrySettings.TutorialDirUTF8 := GetCurrentDirUTF8;

  EntrySettings.BackupDirUTF8 := '';
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
  EntrySettings.MultipleInstances := MultipleInstanceChkBox.Checked;
  EntrySettings.ValidateErrorColour := ValidateErrorColourBtn.ButtonColor;
  EntrySettings.ValueLabelColour := ValueLabelColourBtn.ButtonColor;

  SaveSettingToIni(GetIniFileName);
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
    MultipleInstanceChkBox.Checked := MultipleInstances;
    ValidateErrorColourBtn.ButtonColor := ValidateErrorColour;
    ValueLabelColourBtn.ButtonColor := ValueLabelColour;
  end;
end;

initialization

begin
  RecentFiles := TStringList.Create;
  RecentFiles.CaseSensitive := true;

  RestoreSettingsDefaults;
end;

finalization

begin
  RecentFiles.Free;
end;

end.

