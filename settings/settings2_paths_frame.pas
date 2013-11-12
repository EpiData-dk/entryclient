unit settings2_paths_frame; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn,
  settings2_interface, settings;

type

  { TSettingsPathsFrame }

  TSettingsPathsFrame = class(TFrame, ISettingsFrame)
    PerProjectChkBox: TCheckBox;
    Label1: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label3: TLabel;
    TutorialDirEdit: TDirectoryEdit;
    TutorialURLEdit: TEdit;
    WorkingDirEdit: TDirectoryEdit;
    BackupFolderEdit: TDirectoryEdit;
  private
    { private declarations }
    FData: PEntrySettings;
  public
    { public declarations }
    procedure SetSettings(Data: PEntrySettings);
    function  ApplySettings: boolean;
  end;

implementation

{$R *.lfm}

uses
  settings2, LCLProc;

{ TSettingsPathsFrame }

procedure TSettingsPathsFrame.SetSettings(Data: PEntrySettings);
begin
  FData := Data;
  With FData^ do
  begin
    WorkingDirEdit.Text := WorkingDirUTF8;
    TutorialDirEdit.Text := TutorialDirUTF8;
    TutorialURLEdit.Text := TutorialURLUTF8;
    BackupFolderEdit.Text := BackupDirUTF8;
    PerProjectChkBox.Checked := PerProjectBackup;
  end;
end;

function TSettingsPathsFrame.ApplySettings: boolean;
begin
  result := false;

  if not DirectoryExistsUTF8(WorkingDirEdit.Text) then exit;
  if not DirectoryExistsUTF8(TutorialDirEdit.Text) then exit;
  if not (
      (LeftStr(UTF8LowerCase(TutorialURLEdit.Text), 7) = 'http://') or
      (LeftStr(UTF8LowerCase(TutorialURLEdit.Text), 8) = 'https://')) then exit;

  if not DirectoryExistsUTF8(BackupFolderEdit.Text) then exit;

  With FData^ do
  begin
    WorkingDirUTF8 := WorkingDirEdit.Text;
    TutorialDirUTF8 := TutorialDirEdit.Text;
    TutorialURLUTF8 := TutorialURLEdit.Text;
    BackupDirUTF8    := BackupFolderEdit.Text;
    PerProjectBackup := PerProjectChkBox.Checked;
  end;
  result := true;
end;

initialization

begin
  RegisterSettingFrame(1, TSettingsPathsFrame, 'Paths');
end;


end.

