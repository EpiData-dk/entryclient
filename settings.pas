unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  EditBtn, StdCtrls, ExtCtrls, ComCtrls, Buttons, MaskEdit, epiversionutils;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label18: TLabel;
    ShowWelcomeChkBox: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    RecordsToSkipEdit: TMaskEdit;
    HintTimeOutEdit: TMaskEdit;
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
    RecordsToSkip:  Integer;
    HintTimeOut:    Integer;
    IniFileName:    string;
    ShowWelcome:    boolean;
  end;

const
  EntryVersion: TEpiVersionInfo = (
    VersionNo: 0;
    MajorRev:  2;
    MinorRev:  0;
    BuildNo:   0;
  );

var
  EntrySettings: TEntrySettings = (
    WorkingDirUTF8: '';
    TutorialDirUTF8: '';
    RecordsToSkip:  25;
    HintTimeOut:    15;
    IniFileName:    '';
    ShowWelcome:    true;
  );

  {$IFDEF EPI_SHOWREVISION}
    {$I revision.inc}
  {$ELSE}
    const RevisionStr = '(DEBUG)';
  {$ENDIF}

  function GetEntryVersion: String;
  function SaveSettingToIni(Const FileName: string): boolean;
  function LoadSettingsFromIni(Const FileName: string): boolean;

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
      WriteInteger(Sec, 'RecordsToSkip', RecordsToSkip);
      WriteInteger(Sec, 'HintTimeOut', HintTimeOut);
      WriteBool(Sec, 'ShowWelcome' ,ShowWelcome);
      Result := true;
    end;
  finally
    Ini.Free;
  end;
end;

function LoadSettingsFromIni(Const FileName: string): boolean;
var
  Ini: TIniFile;
  Sec: String;
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
    RecordsToSkip    := ReadInteger(Sec, 'RecordsToSkip', RecordsToSkip);
    HintTimeOut      := ReadInteger(Sec, 'HintTimeout', HintTimeOut);
    ShowWelcome      := ReadBool(Sec, 'ShowWelcome', ShowWelcome);
  end;
end;


{ TSettingsForm }

procedure TSettingsForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := true;
  if ModalResult = mrCancel then exit;

  CanClose := false;
  if not DirectoryExistsUTF8(WorkingDirEdit.Text) then exit;
  if not DirectoryExistsUTF8(TutorialDirEdit.Text) then exit;
  if StrToInt(RecordsToSkipEdit.Text) < 1 then exit;

  EntrySettings.WorkingDirUTF8 := WorkingDirEdit.Text;
  EntrySettings.TutorialDirUTF8 := TutorialDirEdit.Text;
  EntrySettings.RecordsToSkip := StrToInt(RecordsToSkipEdit.Text);
  EntrySettings.HintTimeOut := StrToInt(HintTimeOutEdit.Text);
  EntrySettings.ShowWelcome := ShowWelcomeChkBox.Checked;

  SaveSettingToIni(EntrySettings.IniFileName);
  CanClose := true;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  with EntrySettings do
  begin
    WorkingDirEdit.Text := WorkingDirUTF8;
    TutorialDirEdit.Text := TutorialDirUTF8;
    RecordsToSkipEdit.Text := IntToStr(RecordsToSkip);
    HintTimeOutEdit.Text := IntToStr(HintTimeOut);
    ShowWelcomeChkBox.Checked := ShowWelcome;
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
end;

end.
