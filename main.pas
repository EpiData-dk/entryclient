unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, ActnList, StdActns, ComCtrls, LCLType, ExtCtrls, project_frame;

type

  { TMainForm }

  TMainForm = class(TForm)
    AboutAction: TAction;
    OpenProjectAction: TAction;
    CloseProjectAction: TAction;
    CloseProjectMenuItem: TMenuItem;
    RecentFilesSubMenu: TMenuItem;
    TutorialsMenuDivider1: TMenuItem;
    WebTutorialsMenuItem: TMenuItem;
    TutorialSubMenu: TMenuItem;
    HelpMenuDivider3: TMenuItem;
    ShowShortCutsAction: TAction;
    ShowIntroAction: TAction;
    CheckVersionAction: TAction;
    CopyProjectInfoAction: TAction;
    HelpMenu: TMenuItem;
    AboutMenuItem: TMenuItem;
    HelpMenuDivider2: TMenuItem;
    CopyVersionInfoMenuItem: TMenuItem;
    CheckVersionMenuItem: TMenuItem;
    IntroMenuItem: TMenuItem;
    HelpMenuDivider1: TMenuItem;
    ShowShortcutsMenutItem: TMenuItem;
    SettingsAction: TAction;
    FirstRecordMenuItem: TMenuItem;
    LastRecordMenuItem: TMenuItem;
    EditMenu: TMenuItem;
    SettingsMenuItem: TMenuItem;
    RecordMenuDivider2: TMenuItem;
    RecordMenuDivider1: TMenuItem;
    PrevRecordMenuItem: TMenuItem;
    NextRecordMenuItem: TMenuItem;
    BrowseMenu: TMenuItem;
    GotoRecordMenuItem: TMenuItem;
    NewRecordMenuItem: TMenuItem;
    NewProjectAction: TAction;
    FileExitAction: TFileExit;
    MainActionList: TActionList;
    MainFormMenu: TMainMenu;
    FileMenu: TMenuItem;
    FileMenuDivider1: TMenuItem;
    ExitMenuItem: TMenuItem;
    MainFormPageControl: TPageControl;
    SaveProjectMenuItem: TMenuItem;
    OpenProjectMenuItem: TMenuItem;
    procedure AboutActionExecute(Sender: TObject);
    procedure CheckVersionActionExecute(Sender: TObject);
    procedure CloseProjectActionExecute(Sender: TObject);
    procedure CopyProjectInfoActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewProjectActionExecute(Sender: TObject);
    procedure OpenProjectActionExecute(Sender: TObject);
    procedure SettingsActionExecute(Sender: TObject);
    procedure ShowIntroActionExecute(Sender: TObject);
    procedure ShowShortCutsActionExecute(Sender: TObject);
    procedure WebTutorialsMenuItemClick(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TProjectFrame;
    TabNameCount: integer;
    procedure LoadIniFile;
    procedure OpenTutorialMenuItemClick(Sender: TObject);
    procedure LoadTutorials;
    procedure DoNewProject;
    function  DoCloseProject: boolean;
    procedure DoOpenProject(Const AFileName: string);
    procedure UpdateMainMenu;
    procedure UpdateSettings;
    procedure SetCaption;
    procedure OpenRecentMenuItemClick(Sender: TObject);
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    procedure UpdateRecentFiles;
    property  ActiveFrame: TProjectFrame read FActiveFrame;
  end; 

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  settings, about, Clipbrd, epimiscutils,
  epiversionutils, LCLIntf;

{ TMainForm }

procedure TMainForm.NewProjectActionExecute(Sender: TObject);
begin
  DoNewProject;
end;

procedure TMainForm.OpenProjectActionExecute(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(self);
  Dlg.InitialDir := EntrySettings.WorkingDirUTF8;
  Dlg.Filter := GetEpiDialogFilter(true, true, false, false, false,
    false, false, false, false, true, true);
  Dlg.FilterIndex := 0;

  if not Dlg.Execute then exit;
  if not DoCloseProject then exit;

  DoOpenProject(Dlg.FileName);
  Dlg.Free;
end;

procedure TMainForm.SettingsActionExecute(Sender: TObject);
var
  SettingsForm: TSettingsForm;
begin
  SettingsForm := TSettingsForm.Create(Self);
  SettingsForm.ShowModal;
  SettingsForm.Free;

  LoadTutorials;

  if Assigned(FActiveFrame) then
    TProjectFrame(FActiveFrame).Update;
end;

procedure TMainForm.ShowIntroActionExecute(Sender: TObject);
var
  Fn: String;
begin
  Fn := UTF8Encode(ExtractFilePath(Application.ExeName) + '/epidataentryclientintro.pdf');
  if FileExistsUTF8(Fn) then
    OpenURL(Fn)
  else
    OpenURL('http://epidata.dk/php/downloadc.php?file=epidataentryclientintro.pdf');
end;

procedure TMainForm.ShowShortCutsActionExecute(Sender: TObject);
begin
  OpenURL('http://www.epidata.org/dokuwiki/doku.php/documentation:program_keys');
end;

procedure TMainForm.WebTutorialsMenuItemClick(Sender: TObject);
begin
  OpenURL('http://www.epidata.dk');
end;

procedure TMainForm.LoadIniFile;
const
  IniName = 'epidataentry.ini';
begin
  // TODO : Settings can be loaded from commandline?
  if LoadSettingsFromIni(GetAppConfigFileUTF8(false)) then exit;

  // Todo - this is not optimal on Non-windows OS's. Do some checks for writeability first.
  if LoadSettingsFromIni(ExtractFilePath(Application.ExeName) + IniName) then exit;

  if not DirectoryExistsUTF8(ExtractFilePath(GetAppConfigFileUTF8(false))) then
    ForceDirectoriesUTF8(ExtractFilePath(GetAppConfigFileUTF8(false)));
  EntrySettings.IniFileName := GetAppConfigFileUTF8(false);
end;

procedure TMainForm.OpenTutorialMenuItemClick(Sender: TObject);
begin
  OpenURL(EntrySettings.TutorialDirUTF8 + DirectorySeparator + TMenuItem(Sender).Caption + '.pdf');
end;

procedure TMainForm.LoadTutorials;
var
  FileList: TStringList;
  MenuItem: TMenuItem;
  i: Integer;
begin
  // First delete all previous tutorials.. (could be a change in tutorial dir).
  for i := TutorialSubMenu.Count - 1 downto 0 do
  begin
    if (TutorialSubMenu[i] = TutorialsMenuDivider1) or
       (TutorialSubMenu[i] = WebTutorialsMenuItem) then continue;

    MenuItem := TutorialSubMenu[i];
    TutorialSubMenu.Delete(i);
    MenuItem.Free;
  end;

  // Find all .pdf files in the directory set by TutorialsDirUTF8
  FileList := FindAllFiles(EntrySettings.TutorialDirUTF8, '*.pdf', false);
  TutorialsMenuDivider1.Visible := FileList.Count > 0;

  if FileList.Count = 0 then Exit;

  for i := 0 to FileList.Count - 1 do
  begin
    MenuItem := TMenuItem.Create(TutorialSubMenu);
    MenuItem.Name := 'TutorialMenuItem' + IntToStr(i);
    MenuItem.Caption := ExtractFileNameOnly(FileList[i]);
    MenuItem.OnClick := @OpenTutorialMenuItemClick;

    With TutorialSubMenu do
      Insert(IndexOf(TutorialsMenuDivider1), MenuItem);
  end;
end;

procedure TMainForm.DoNewProject;
var
  TabSheet: TTabSheet;
begin
  // Close Old project
  if not DoCloseProject then exit;

  TabSheet := TTabSheet.Create(MainFormPageControl);
  TabSheet.PageControl := MainFormPageControl;
  TabSheet.Name := 'TabSheet' + IntToStr(TabNameCount);
  TabSheet.Caption := 'Untitled';

  FActiveFrame := TProjectFrame.Create(TabSheet);
  FActiveFrame.Name := 'ProjectFrame' + IntToStr(TabNameCount);
  FActiveFrame.Align := alClient;
  FActiveFrame.Parent := TabSheet;
  MainFormPageControl.ActivePage := TabSheet;

  // Only as long as one project is created!
  UpdateMainMenu;
  SaveProjectMenuItem.Action := FActiveFrame.SaveProjectAction;

  Inc(TabNameCount);
end;

function TMainForm.DoCloseProject: boolean;
begin
  result := true;
  if Assigned(FActiveFrame) then
  begin
    FActiveFrame.CloseQuery(result);
    if not Result then exit;

    MainFormPageControl.ActivePage.Free;
    FActiveFrame := nil;
  end;
  UpdateMainMenu;
  SetCaption;
end;

procedure TMainForm.DoOpenProject(const AFileName: string);
begin
  DoNewProject;
  FActiveFrame.OpenProject(AFileName);
end;

procedure TMainForm.UpdateMainMenu;
begin
  SaveProjectMenuItem.Visible := Assigned(FActiveFrame);
  CloseProjectAction.Enabled := Assigned(FActiveFrame);
end;

procedure TMainForm.UpdateSettings;
begin
  LoadTutorials;
end;

procedure TMainForm.SetCaption;
begin
  Caption := 'EpiData Entry Client (v' + GetEntryVersion + ')';
end;

procedure TMainForm.OpenRecentMenuItemClick(Sender: TObject);
begin
  DoOpenProject(ExpandFileNameUTF8(TMenuItem(Sender).Caption));
end;

constructor TMainForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FActiveFrame := nil;
  UpdateMainMenu;
end;

procedure TMainForm.UpdateRecentFiles;
var
  Mi: TMenuItem;
  i: Integer;
begin
  RecentFilesSubMenu.Visible := RecentFiles.Count > 0;

  RecentFilesSubMenu.Clear;
  for i := 0 to RecentFiles.Count - 1 do
  begin
    Mi := TMenuItem.Create(RecentFilesSubMenu);
    Mi.Name := 'recent' + inttostr(i);
    Mi.Caption := RecentFiles[i];
    Mi.OnClick := @OpenRecentMenuItemClick;
    RecentFilesSubMenu.Add(Mi);
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SetCaption;
  {$IFDEF EPI_DEBUG}
  AboutAction.Enabled := true;
  {$ENDIF}

  LoadIniFile;
  UpdateSettings;
  UpdateRecentFiles;

  {$IFDEF EPI_RELEASE}
  if EntrySettings.ShowWelcome then
    ShowMessagePos('EpiData EntryClient:' + LineEnding +
                   'See help menu above for an introduction.' + LineEnding +
                   'Get latest version from http://www.epidata.dk', 15, 15);
  {$ENDIF}
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := true;

  {$IFDEF EPI_RELEASE}
  if Assigned(FActiveFrame) then
    FActiveFrame.CloseQuery(CanClose);
  {$ENDIF}
  SaveSettingToIni(EntrySettings.IniFileName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  {$IFDEF EPI_RELEASE}
  Width := 800;
  Height := 600;
  AboutAction.Enabled := false;
  {$ENDIF}
end;

procedure TMainForm.AboutActionExecute(Sender: TObject);
var
  Frm: TAboutForm;
begin
  Frm := TAboutForm.Create(self);
  Frm.ShowModal;
  Frm.Free;
end;

procedure TMainForm.CheckVersionActionExecute(Sender: TObject);
var
  Stable: TEpiVersionInfo;
  Test: TEpiVersionInfo;
  Response: string;
  NewStable: Boolean;
  NewTest: Boolean;
  EntryScore: Integer;
  StableScore: Integer;
  TestScore: Integer;
  S: String;
begin
  if not CheckVersionOnline('epidataentryclient', Stable, Test, Response) then
  begin
    ShowMessage(
      'ERROR: Could not find version information.' + LineEnding +
      'Response: ' + Response + LineEnding +
      'Check internet connection!');
    exit;
  end;

  with EntryVersion do
    EntryScore  := (VersionNo * 10000) + (MajorRev * 100) + (MinorRev);
  With Stable do
    StableScore := (VersionNo * 10000) + (MajorRev * 100) + (MinorRev);
  With Test do
    TestScore   := (VersionNo * 10000) + (MajorRev * 100) + (MinorRev);

  NewStable     := (StableScore - EntryScore) > 0;
  NewTest       := (TestScore   - EntryScore) > 0;

  with EntryVersion do
    S := Format('Current Version: %d.%d.%d.%d', [VersionNo, MajorRev, MinorRev, BuildNo]) + LineEnding;
  with Stable do
    if NewStable then
      S := S + Format('New public release available: %d.%d.%d.%d', [VersionNo, MajorRev, MinorRev, BuildNo]) + LineEnding
    else
      S := S + Format('Latest public release: %d.%d.%d.%d', [VersionNo, MajorRev, MinorRev, BuildNo]) + LineEnding;
   with Test do
     if NewTest then
      S := S + Format('New test version available: %d.%d.%d.%d', [VersionNo, MajorRev, MinorRev, BuildNo])
    else
      S := S + Format('Latest test version: %d.%d.%d.%d', [VersionNo, MajorRev, MinorRev, BuildNo]);
  ShowMessage(S);
end;

procedure TMainForm.CloseProjectActionExecute(Sender: TObject);
begin
  DoCloseProject;
end;

procedure TMainForm.CopyProjectInfoActionExecute(Sender: TObject);
var
  S: String;
begin
  S := GetProgramInfo;
  if Assigned(TProjectFrame(ActiveFrame).EpiDocument) then
  with TProjectFrame(ActiveFrame).EpiDocument do
  begin
    S := S + LineEnding +
      'Filename: ' + TProjectFrame(ActiveFrame).DocumentFileName + LineEnding +
      'XML Version: ' + IntToStr(XMLSettings.Version) + LineEnding +
      'Field count: ' + IntToStr(DataFiles[0].Fields.Count) + LineEnding +
      'Record count: ' + IntToStr(DataFiles[0].Size);
  end;
  Clipboard.AsText := S;
end;

end.

