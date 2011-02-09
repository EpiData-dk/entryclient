unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  EditBtn, StdCtrls, ExtCtrls, ComCtrls, Buttons, MaskEdit, ColorBox,
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
    WorkingDirUTF8: string;
    TutorialDirUTF8: string;
    TutorialURLUTF8: string;
    RecordsToSkip:  Integer;
    HintTimeOut:    Integer;
    IniFileName:    string;
    ShowWelcome:    boolean;
    MultipleInstances: boolean;
    ValidateErrorColour: TColor;
    ValueLabelColour: TColor;
  end;

const
  EntryVersion: TEpiVersionInfo = (
    VersionNo: 0;
    MajorRev:  3;
    MinorRev:  0;
    BuildNo:   0;
  );

var
  EntrySettings: TEntrySettings = (
    WorkingDirUTF8: '';
    TutorialDirUTF8: '';
    TutorialURLUTF8: 'http://epidata.dk/documentation.php';
    RecordsToSkip:  25;
    HintTimeOut:    15;
    IniFileName:    '';
    ShowWelcome:    true;
    MultipleInstances: false;
    ValidateErrorColour: clYellow;
    ValueLabelColour: clBlue;
  );

  {$IFDEF EPI_SHOWREVISION}
    {$I revision.inc}
  {$ELSE}
    const RevisionStr = '(DEBUG)';
  {$ENDIF}

  function GetEntryVersion: String;
  function SaveSettingToIni(Const FileName: string): boolean;
  function LoadSettingsFromIni(Const FileName: string): boolean;

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
  {    // Advanced:
      WorkingDirUTF8:        string;}
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
