unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, ActnList, StdActns, ComCtrls, LCLType, ExtCtrls, project_frame,
  LMessages, StdCtrls, Buttons, entry_messages;

type
  { TMainForm }

  TMainForm = class(TForm)
    AboutAction: TAction;
    BetaPanel: TPanel;
    DefaultPosAction: TAction;
    EpiDataWebTutorialsMenuItem: TMenuItem;
    DefaultPosMenuItem: TMenuItem;
    FindMenuItem: TMenuItem;
    FindNextMenuItem: TMenuItem;
    FindPrevMenuItem: TMenuItem;
    FieldNotesDivider: TMenuItem;
    FieldNotesMenuItem: TMenuItem;
    FindListMenuItem: TMenuItem;
    CopyRecToClpMenuItem: TMenuItem;
    AppleMenuItem: TMenuItem;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    FindMenuExItem: TMenuItem;
    OpenProjectBtn: TBitBtn;
    RecentFilesPopupSubMenu: TMenuItem;
    OpenProjectPopupMenuItem: TMenuItem;
    MenuItem2: TMenuItem;
    BrowseAllMenuItem: TMenuItem;
    OpenProjectPopupMenu: TPopupMenu;
    PrintWithDataMenuItem: TMenuItem;
    PrintMenuItem: TMenuItem;
    FileMenuDivider2: TMenuItem;
    ProcessToolPanel: TPanel;
    BrowseMenu: TMenuItem;
    OpenProjectAction: TAction;
    CloseProjectAction: TAction;
    CloseProjectMenuItem: TMenuItem;
    RecentFilesSubMenu: TMenuItem;
    StaticText1: TStaticText;
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
    GotoMenu: TMenuItem;
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
    CopyFieldToClpMenuItem: TMenuItem;
    SaveProjectAsMenuItem: TMenuItem;
    MenuItem5: TMenuItem;
    ShowChangeLogAction: TAction;
    procedure AboutActionExecute(Sender: TObject);
    procedure CheckVersionActionExecute(Sender: TObject);
    procedure CloseProjectActionExecute(Sender: TObject);
    procedure CopyProjectInfoActionExecute(Sender: TObject);
    procedure DefaultPosActionExecute(Sender: TObject);
    procedure FileMenuClick(Sender: TObject);
    procedure FormChanged(Sender: TObject; Form: TCustomForm);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormShow(Sender: TObject);
    procedure EpiDataWebTutorialsMenuItemClick(Sender: TObject);
    procedure MainActionListUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure NewProjectActionExecute(Sender: TObject);
    procedure OpenProjectActionExecute(Sender: TObject);
    procedure OpenProjectBtnClick(Sender: TObject);
    procedure SettingsActionExecute(Sender: TObject);
    procedure ShowIntroActionExecute(Sender: TObject);
    procedure ShowShortCutsActionExecute(Sender: TObject);
    procedure WebTutorialsMenuItemClick(Sender: TObject);
    procedure FormShortCut(var Msg: TLMKey; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ShowChangeLogActionExecute(Sender: TObject);
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
    procedure LoadGlyphs;
    procedure OpenRecentMenuItemClick(Sender: TObject);
  { messages }
    procedure LMCLoseProject(var Msg: TLMessage); message LM_CLOSE_PROJECT;
    procedure LMOpenProject(var Msg: TLMessage); message LM_OPEN_PROJECT;
    procedure LMOpenRecent(var Msg: TLMessage); message LM_OPEN_RECENT;
    // Relaying...
    procedure LMDataFormGotoRec(var Msg: TLMessage); message LM_DATAFORM_GOTOREC;
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
  epiv_datamodule,
  settings, about, Clipbrd, epimiscutils, epicustombase,
  epiversionutils, LCLIntf, settings2, searchform,
  shortcuts, epistringutils, epiadmin, entryprocs,
  epiv_checkversionform, LazUTF8, LazFileUtils;

{ TMainForm }

procedure TMainForm.NewProjectActionExecute(Sender: TObject);
begin
  DoNewProject;
end;

procedure TMainForm.OpenProjectActionExecute(Sender: TObject);
begin
  PostMessage(Self.Handle, LM_OPEN_PROJECT, 0, 0);
end;

procedure TMainForm.OpenProjectBtnClick(Sender: TObject);
begin
  UpdateRecentFiles;
  OpenProjectPopupMenu.PopUp;
end;

procedure TMainForm.SettingsActionExecute(Sender: TObject);
var
  SettingsForm: TSettings2Form;
  mr: Integer;
begin
  SettingsForm := TSettings2Form.Create(Self);
  mr := SettingsForm.ShowModal;
  SettingsForm.Free;

  if (mr = mrOK) then
    UpdateSettings;
end;

procedure TMainForm.ShowIntroActionExecute(Sender: TObject);
var
  Fn: String;
begin
  Fn := EntrySettings.TutorialDirUTF8 + '/epidataentryclientintro.pdf';
  if FileExistsUTF8(Fn) then
    OpenURL(Fn)
  else
  begin
    ShowMessage(
      'Introduction document was not found in tutorial folder:' + LineEnding +
      EntrySettings.TutorialDirUTF8
    );
    OpenURL('http://epidata.dk/php/downloadc.php?file=epidataentryclientintro.pdf');
  end;
end;

procedure TMainForm.ShowShortCutsActionExecute(Sender: TObject);
var
  Fn: String;
begin
  Fn := EntrySettings.TutorialDirUTF8 + '/epidataentryclientshortcuts.pdf';
  if FileExistsUTF8(Fn) then
    OpenURL(Fn)
  else
  begin
    ShowMessage(
      'Introduction document was not found in tutorial folder:' + LineEnding +
      EntrySettings.TutorialDirUTF8
    );
    OpenURL('http://epidata.info/dokuwiki/doku.php?id=documentation:keyboard_shortcuts');
  end;
end;

procedure TMainForm.WebTutorialsMenuItemClick(Sender: TObject);
begin
  OpenURL(EntrySettings.TutorialURLUTF8);
end;

procedure TMainForm.FormShortCut(var Msg: TLMKey; var Handled: Boolean);
begin
  if Assigned(FActiveFrame) then
    FActiveFrame.IsShortCut(Msg, Handled);
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DoCloseProject;
end;

procedure TMainForm.ShowChangeLogActionExecute(Sender: TObject);
begin
  OpenURL('http://epidata.dk/epidataentryclient.changelog.txt');
end;

procedure TMainForm.OpenTutorialMenuItemClick(Sender: TObject);
begin
  OpenDocument(EntrySettings.TutorialDirUTF8 + DirectorySeparator + TMenuItem(Sender).Caption + '.pdf');
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
    MenuItem := TutorialSubMenu[i];
    TutorialSubMenu.Delete(i);
    MenuItem.Free;
  end;

  // Find all .pdf files in the directory set by TutorialsDirUTF8
  FileList := FindAllFiles(EntrySettings.TutorialDirUTF8, '*.pdf', false);

  TutorialSubMenu.Enabled := (FileList.Count > 0);

  for i := 0 to FileList.Count - 1 do
  begin
    MenuItem := TMenuItem.Create(TutorialSubMenu);
    MenuItem.Name := 'TutorialMenuItem' + IntToStr(i);
    MenuItem.Caption := ExtractFileNameOnly(FileList[i]);
    MenuItem.OnClick := @OpenTutorialMenuItemClick;

    TutorialSubMenu.Add(MenuItem);
  end;
end;

procedure TMainForm.DoNewProject;
var
  TabSheet: TTabSheet;
begin
  // Close Old project
  if not DoCloseProject then exit;

  {$IFDEF EPI_BETA}
  BetaPanel.Visible :=  false;
  {$ENDIF}

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
  SaveProjectAsMenuItem.Action := FActiveFrame.SaveProjectAsAction;

  Inc(TabNameCount);
end;

function TMainForm.DoCloseProject: boolean;
begin
  result := true;
  if Assigned(FActiveFrame) then
  begin
    FActiveFrame.CloseQuery(result);
    if not Result then exit;

    Screen.Cursor := crHourGlass;
    Application.ProcessMessages;

    FActiveFrame.CloseProject;

    Screen.Cursor := crDefault;
    Application.ProcessMessages;

    MainFormPageControl.ActivePage.Free;
    FActiveFrame := nil;
  end;
  UpdateMainMenu;
  UpdateProcessToolPanel;
  SetCaption;

  {$IFDEF EPI_BETA}
  BetaPanel.Visible := true;
  BetaPanel.BringToFront;
  {$ENDIF}
end;

procedure TMainForm.DoOpenProject(const AFileName: string);
begin
  DoNewProject;
  try
    if not FActiveFrame.OpenProject(AFileName) then
      DoCloseProject;
  except
    on E: Exception do
      begin
        ShowMessage('Unable to open the file: ' + AFileName + LineEnding +
                    'An unknown error occured:' + LineEnding +
                    E.Message);
        DoCloseProject;
      end;
  end;
end;

procedure TMainForm.UpdateMainMenu;
begin
  // FILE:
  SaveProjectMenuItem.Visible   := Assigned(FActiveFrame);
  SaveProjectAsMenuItem.Visible := Assigned(FActiveFrame);
  CloseProjectAction.Enabled    := Assigned(FActiveFrame);
  PrintMenuItem.Visible         := Assigned(FActiveFrame);
  PrintWithDataMenuItem.Visible := Assigned(FActiveFrame);
  FileMenuDivider2.Visible      := Assigned(FActiveFrame);

  // EDIT:
  CopyRecToClpMenuItem.Visible   := Assigned(FActiveFrame);
  CopyFieldToClpMenuItem.Visible := Assigned(FActiveFrame);

  // BROWSE:
  BrowseMenu.Visible            := Assigned(FActiveFrame);

  // GOTO:
  GotoMenu.Visible              := Assigned(FActiveFrame);

  // HELP
  FieldNotesMenuItem.Visible    := Assigned(FActiveFrame);
  FieldNotesDivider.Visible     := Assigned(FActiveFrame);
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

procedure TMainForm.LoadGlyphs;
begin
  DM.Icons16.GetBitmap(19, OpenProjectBtn.Glyph);
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
  Fn: String;
begin
  if Msg.WParam = 0 then
  begin
    Dlg := TOpenDialog.Create(self);
    Dlg.InitialDir := EntrySettings.WorkingDirUTF8;
    Dlg.Filter := GetEpiDialogFilter([dfEPX, dfEPZ, dfCollection]);
    Dlg.FilterIndex := 0;

    if not Dlg.Execute then exit;
    Fn := Dlg.FileName;
    Dlg.Free;
  end else begin
    Fn := TString(Msg.WParam).Str;
    TString(Msg.WParam).Free;
  end;

  if not DoCloseProject then exit;
  DoOpenProject(Fn);
end;

procedure TMainForm.LMOpenRecent(var Msg: TLMessage);
var
  MI: TMenuItem;
begin
  MI := TMenuItem(Msg.WParam);
  DoOpenProject(ExpandFileNameUTF8(MI.Caption));
end;

procedure TMainForm.LMDataFormGotoRec(var Msg: TLMessage);
begin
  if Assigned(FActiveFrame) then
    SendMessage(FActiveFrame.Handle, LM_DATAFORM_GOTOREC, Msg.WParam, Msg.LParam);
end;

constructor TMainForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FActiveFrame := nil;

  LoadGlyphs;
  UpdateMainMenu;
end;

procedure TMainForm.UpdateRecentFiles;
var
  Mi: TMenuItem;
  i, RecentFilesRunner: Integer;
  K: Word;
  Shift: TShiftState;
begin
  ShortCutToKey(M_OpenRecent, K, Shift);

  LoadRecentFilesIni(GetRecentIniFileName);
  RecentFilesSubMenu.Clear;
  RecentFilesPopupSubMenu.Clear;

  RecentFilesRunner := 0;
  for i := 0 to 8 do
  begin
    while (RecentFilesRunner < RecentFiles.Count) and
          (ExtractFileExt(RecentFiles[RecentFilesRunner]) <> '.epx')
    do
      Inc(RecentFilesRunner);

    // Disable actions if the list of recentfiles is not long enough.
    if (RecentFilesRunner >= RecentFiles.Count) then
      break;

    Mi := TMenuItem.Create(RecentFilesSubMenu);
    Mi.Name := 'recent' + inttostr(i);
    Mi.Caption := RecentFiles[RecentFilesRunner];
    Mi.OnClick := @OpenRecentMenuItemClick;
    Mi.ShortCut := ShortCut(VK_1 + i, Shift);
    RecentFilesSubMenu.Add(Mi);

    // Popup menu
    Mi := TMenuItem.Create(RecentFilesPopupSubMenu);
    Mi.Name := 'recent' + inttostr(i);
    Mi.Caption := RecentFiles[RecentFilesRunner];
    Mi.OnClick := @OpenRecentMenuItemClick;
    Mi.ShortCut := KeyToShortCut(VK_1 + i, Shift);
    RecentFilesPopupSubMenu.Add(Mi);

    Inc(RecentFilesRunner);
  end;

  RecentFilesSubMenu.Visible := RecentFilesSubMenu.Count > 0;
  RecentFilesPopupSubMenu.Visible := RecentFilesSubMenu.Visible;
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
  TAboutForm.RestoreDefaultPos;
  TProjectFrame.RestoreDefaultPos(FActiveFrame);
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
  LoadFormPosition(Self, 'MainForm');

  UpdateSettings;
  UpdateRecentFiles;

  {$IFDEF EPI_BETA}
  BetaPanel.Visible := true;
  BetaPanel.BringToFront;
  {$ENDIF}
end;

procedure TMainForm.EpiDataWebTutorialsMenuItemClick(Sender: TObject);
begin
  OpenURL('http://www.epidata.info/dokuwiki/doku.php?id=documentation:start');
end;

procedure TMainForm.MainActionListUpdate(AAction: TBasicAction;
  var Handled: Boolean);
begin
{  if Screen.ActiveCustomForm <> MainForm then
    MainActionList.State := asSuspended
  else
    MainActionList.State := asNormal;     }
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

  {$IFNDEF EPI_DEBUG}
  if Assigned(FActiveFrame) then
    FActiveFrame.CloseQuery(CanClose);
  {$ENDIF}

  if CanClose {and ManagerSettings.SaveWindowPositions} then
    SaveFormPosition(Self, 'MainForm');

  SaveSettingToIni(GetIniFileName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Fn: String;
  i: Integer;
begin
  {$IFDEF darwin}
  AppleMenuItem.Visible := true;
  AppleMenuItem.Caption := #$EF#$A3#$BF;
  {$ELSE}
  AppleMenuItem.Visible := false;
  {$ENDIF}
  AboutMenuItem.Visible    := not (AppleMenuItem.Visible);
  HelpMenuDivider2.Visible := not (AppleMenuItem.Visible);
  SettingsMenuItem.Visible := not (AppleMenuItem.Visible);

  Screen.AddHandlerActiveFormChanged(@FormChanged);

  if Assigned(StartupFiles) then
  begin
    for i := 0 to StartupFiles.Count - 1 do
    begin
      Fn := StartupFiles[i];
      if FileExistsUTF8(Fn) then
        PostMessage(Self.Handle, LM_OPEN_PROJECT, WPARAM(TString.Create(Fn)), 0);
    end;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Screen.RemoveAllHandlersOfObject(Self);
end;

procedure TMainForm.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var
  S: TString;
begin
  if Length(FileNames) = 0 then Exit;

  S := TString.Create(FileNames[0]);
  PostMessage(Self.Handle, LM_OPEN_PROJECT, WPARAM(S), 0);
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
  F: TCheckVersionForm;
begin
  F := TCheckVersionForm.Create(Self);
  F.Caption := 'EpiData EntryClient';
  F.ShowModal;
  F.Free;
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
      'Filename: ' + TProjectFrame(ActiveFrame).DocumentFile.FileName + LineEnding +
      'XML Version: ' + IntToStr(Version) + LineEnding +
      'Dataforms: ' + IntToStr(DataFiles.Count);
//      'Field count: ' + IntToStr(DataFiles[0].Fields.Count) + LineEnding +
//      'Record count: ' + IntToStr(DataFiles[0].Size);
  end;
  Clipboard.AsText := S;
  ShowMessage('Version info copied to clipboard!');
end;

procedure TMainForm.DefaultPosActionExecute(Sender: TObject);
begin
  ResoreDefaultPos;
end;

procedure TMainForm.FileMenuClick(Sender: TObject);
begin
//  UpdateRecentFiles;
end;

procedure TMainForm.FormChanged(Sender: TObject; Form: TCustomForm);
begin
  if (Form <> MainForm) then
    MainActionList.State := asSuspended
  else
    MainActionList.State := asNormal;
end;

end.

