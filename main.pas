unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, ActnList, StdActns, ComCtrls, LCLType, ExtCtrls, project_frame,
  LMessages, StdCtrls;


const
  LM_CLOSE_PROJECT = LM_USER + 1;
  LM_OPEN_PROJECT  = LM_USER + 2;
  LM_OPEN_RECENT   = LM_USER + 3;

type
  { TMainForm }

  TMainForm = class(TForm)
    AboutAction: TAction;
    Button1: TButton;
    DefaultPosAction: TAction;
    EpiDataWebTutorialsMenuItem: TMenuItem;
    DefaultPosMenuItem: TMenuItem;
    MenuItem1: TMenuItem;
    FindMenuItem: TMenuItem;
    FindNextMenuItem: TMenuItem;
    FindPrevMenuItem: TMenuItem;
    FieldNotesDivider: TMenuItem;
    FieldNotesMenuItem: TMenuItem;
    FindListMenuItem: TMenuItem;
    ProcessToolPanel: TPanel;
    SearchMenu: TMenuItem;
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
    procedure DefaultPosActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure EpiDataWebTutorialsMenuItemClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
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
    procedure OpenTutorialMenuItemClick(Sender: TObject);
    procedure LoadTutorials;
    procedure DoNewProject;
    function  DoCloseProject: boolean;
    procedure DoOpenProject(Const AFileName: string);
    procedure UpdateMainMenu;
    procedure UpdateShortCuts;
    procedure UpdateSettings;
    procedure UpdateProcessToolPanel;
    procedure SetCaption;
    procedure OpenRecentMenuItemClick(Sender: TObject);
    procedure LMCLoseProject(var Msg: TLMessage); message LM_CLOSE_PROJECT;
    procedure LMOpenProject(var Msg: TLMessage); message LM_OPEN_PROJECT;
    procedure LMOpenRecent(var Msg: TLMessage); message LM_OPEN_RECENT;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    procedure UpdateRecentFiles;
    procedure ResoreDefaultPos;
    procedure BeginUpdateForm;
    procedure EndUpdateForm;
    property  ActiveFrame: TProjectFrame read FActiveFrame;
  end; 

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  settings, about, Clipbrd, epimiscutils, epicustombase,
  epiversionutils, LCLIntf, settings2, searchform,
  shortcuts;

{ TMainForm }

procedure TMainForm.NewProjectActionExecute(Sender: TObject);
begin
  DoNewProject;
end;

procedure TMainForm.OpenProjectActionExecute(Sender: TObject);
begin
  PostMessage(Self.Handle, LM_OPEN_PROJECT, 0, 0);
end;

procedure TMainForm.SettingsActionExecute(Sender: TObject);
var
  SettingsForm: TSettings2Form;
begin
  SettingsForm := TSettings2Form.Create(Self);
  SettingsForm.ShowModal;
  SettingsForm.Free;

  UpdateSettings;
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
  OpenURL(EntrySettings.TutorialURLUTF8);
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
       (TutorialSubMenu[i] = WebTutorialsMenuItem) or
       (TutorialSubMenu[i] = EpiDataWebTutorialsMenuItem)
       then continue;

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
  UpdateProcessToolPanel;

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
  UpdateProcessToolPanel;
  SetCaption;
end;

procedure TMainForm.DoOpenProject(const AFileName: string);
begin
  DoNewProject;
  try
    FActiveFrame.OpenProject(AFileName);
  except
    on E: TEpiCoreException do
      begin
        ShowMessage('Unable to open the file: ' + AFileName + LineEnding +
                    E.Message);
        DoCloseProject;
      end;
    on E: EFOpenError do
      begin
        ShowMessage('Unable to open the file: ' + AFileName + LineEnding +
                    'File is corrupt or does not exist.');
        DoCloseProject;
      end;
  else
    begin
      ShowMessage('Unable to open the file: ' + AFileName + LineEnding +
                  'An unknown error occured.');
      DoCloseProject;
    end;
  end;
end;

procedure TMainForm.UpdateMainMenu;
begin
  SaveProjectMenuItem.Visible := Assigned(FActiveFrame);
  CloseProjectAction.Enabled := Assigned(FActiveFrame);

  FieldNotesMenuItem.Visible := Assigned(FActiveFrame);
  FieldNotesDivider.Visible := Assigned(FActiveFrame);

  SearchMenu.Visible := Assigned(FActiveFrame);
  {$IFDEF EPI_RELEASE}
  MenuItem1.Visible := false;
  {$ENDIF}
end;

procedure TMainForm.UpdateShortCuts;
begin
  // Mainform
  FileExitAction.ShortCut := M_Exit;
  NewProjectAction.ShortCut := M_NewProject;
  SettingsAction.ShortCut := M_Settings;
  AboutAction.ShortCut := M_ShowAbout;
  CopyProjectInfoAction.ShortCut := M_CopyProjectInfo;
  CheckVersionAction.ShortCut := M_CheckVersion;
  DefaultPosAction.ShortCut := M_DefaultPos;
  CloseProjectAction.ShortCut := M_CloseProject;
  OpenProjectAction.ShortCut := M_OpenProject;
end;

procedure TMainForm.UpdateSettings;
begin
  LoadTutorials;
  UpdateProcessToolPanel;
  UpdateShortCuts;

  if Assigned(FActiveFrame) then
    TProjectFrame(FActiveFrame).UpdateSettings;
end;

procedure TMainForm.UpdateProcessToolPanel;
begin
  ProcessToolPanel.Visible :=
    (EntrySettings.ShowWorkToolbar) and
    (not Assigned(FActiveFrame));
end;

procedure TMainForm.SetCaption;
begin
  Caption := 'EpiData Entry Client (v' + GetEntryVersion + ')';
end;

procedure TMainForm.OpenRecentMenuItemClick(Sender: TObject);
begin
  PostMessage(Self.Handle, LM_OPEN_RECENT, WParam(Sender), 0);
end;

procedure TMainForm.LMCLoseProject(var Msg: TLMessage);
begin
  DoCloseProject;
end;

procedure TMainForm.LMOpenProject(var Msg: TLMessage);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(self);
  Dlg.InitialDir := EntrySettings.WorkingDirUTF8;
  Dlg.Filter := GetEpiDialogFilter([dfEPX, dfEPZ, dfCollection]);
  Dlg.FilterIndex := 0;

  if not Dlg.Execute then exit;
  if not DoCloseProject then exit;

  DoOpenProject(Dlg.FileName);
  Dlg.Free;
end;

procedure TMainForm.LMOpenRecent(var Msg: TLMessage);
var
  MI: TMenuItem;
begin
  MI := TMenuItem(Msg.WParam);
  DoOpenProject(ExpandFileNameUTF8(MI.Caption));
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
  K: Word;
  Shift: TShiftState;
begin
  ShortCutToKey(M_OpenRecent, K, Shift);

  RecentFilesSubMenu.Visible := RecentFiles.Count > 0;
  RecentFilesSubMenu.Clear;
  for i := 0 to RecentFiles.Count - 1 do
  begin
    Mi := TMenuItem.Create(RecentFilesSubMenu);
    Mi.Name := 'recent' + inttostr(i);
    Mi.Caption := RecentFiles[i];
    Mi.OnClick := @OpenRecentMenuItemClick;
    if i < 9 then
      Mi.ShortCut := ShortCut(VK_1 + i, Shift);
    RecentFilesSubMenu.Add(Mi);
  end;
end;

procedure TMainForm.ResoreDefaultPos;
begin
  BeginFormUpdate;
  Width := 700;
  Height := 600;
  Top := (Monitor.Height div 2) - (Height div 2);
  Left := (Monitor.Width div 2) - (Width div 2);
  EndFormUpdate;
  SaveFormPosition(Self, 'MainForm');

  TSettings2Form.RestoreDefaultPos;
  TSearchForm1.RestoreDefaultPos;

  if Assigned(FActiveFrame) then
    FActiveFrame.RestoreDefaultPos;
end;

procedure TMainForm.BeginUpdateForm;
begin
  BeginFormUpdate;
end;

procedure TMainForm.EndUpdateForm;
begin
  EndFormUpdate;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SetCaption;
  {$IFDEF EPI_DEBUG}
  AboutAction.Enabled := true;
  {$ENDIF}

//  if ManagerSettings.SaveWindowPositions then
    LoadFormPosition(Self, 'MainForm');

  UpdateSettings;
  UpdateRecentFiles;

  {$IFDEF EPI_RELEASE}
  if EntrySettings.ShowWelcome then
    ShowMessagePos('EpiData EntryClient:' + LineEnding +
                   'See help menu above for an introduction.' + LineEnding +
                   'Get latest version from http://www.epidata.dk', 15, 15);
  {$ENDIF}
end;

procedure TMainForm.EpiDataWebTutorialsMenuItemClick(Sender: TObject);
begin
  OpenURL('http://www.epidata.org/dokuwiki/doku.php/documentation:tutorials');
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
var
  SettingsForm: TSettingsForm;
begin
  SettingsForm := TSettingsForm.Create(Self);
  SettingsForm.ShowModal;
  SettingsForm.Free;

  LoadTutorials;

  if Assigned(FActiveFrame) then
    TProjectFrame(FActiveFrame).UpdateSettings;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := true;

  {$IFDEF EPI_RELEASE}
  if Assigned(FActiveFrame) then
    FActiveFrame.CloseQuery(CanClose);
  {$ENDIF}

  if CanClose {and ManagerSettings.SaveWindowPositions} then
    SaveFormPosition(Self, 'MainForm');

  SaveSettingToIni(EntrySettings.IniFileName);
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
  PostMessage(Self.Handle, LM_CLOSE_PROJECT, 0, 0);
end;

procedure TMainForm.CopyProjectInfoActionExecute(Sender: TObject);
var
  S: String;
begin
  S := GetProgramInfo;
  if Assigned(ActiveFrame) then
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

procedure TMainForm.DefaultPosActionExecute(Sender: TObject);
begin
  ResoreDefaultPos;
end;

end.

