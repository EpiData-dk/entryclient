unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epidocument, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, ActnList, StdActns, ComCtrls, LCLType, StdCtrls, ExtCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    AboutAction: TAction;
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
    procedure CopyProjectInfoActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewProjectActionExecute(Sender: TObject);
    procedure SettingsActionExecute(Sender: TObject);
    procedure ShowIntroActionExecute(Sender: TObject);
    procedure ShowShortCutsActionExecute(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TFrame;
    TabNameCount: integer;
    procedure LoadIniFile;
    procedure SetCaption;
  public
    { public declarations }
    property  ActiveFrame: TFrame read FActiveFrame;
  end; 

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  project_frame, dataform_frame, fieldedit, settings, about, Clipbrd,
  epiversionutils, LCLIntf;

{ TMainForm }

procedure TMainForm.NewProjectActionExecute(Sender: TObject);
var
  TabSheet: TTabSheet;
  Frame: TProjectFrame;
  S: String;
const
  SampleFileName = 'sample.epx';
begin
  TabSheet := TTabSheet.Create(MainFormPageControl);
  TabSheet.PageControl := MainFormPageControl;
  TabSheet.Name := 'TabSheet' + IntToStr(TabNameCount);
  TabSheet.Caption := 'Untitled';

  Frame := TProjectFrame.Create(TabSheet);
  Frame.Name := 'ProjectFrame' + IntToStr(TabNameCount);
  Frame.Align := alClient;
  Frame.Parent := TabSheet;
  FActiveFrame := Frame;
  MainFormPageControl.ActivePage := TabSheet;

  // Only as long as one project is created!
  SaveProjectMenuItem.Action := Frame.SaveProjectAction;
  OpenProjectMenuItem.Action := Frame.OpenProjectAction;

  S := ExtractFilePath(Application.ExeName) + SampleFileName;
  if FileExistsUTF8(S) then
    Frame.DoOpenProject(S);

  Inc(TabNameCount);
end;

procedure TMainForm.SettingsActionExecute(Sender: TObject);
var
  SettingsForm: TSettingsForm;
begin
  SettingsForm := TSettingsForm.Create(Self);
  SettingsForm.ShowModal;
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

procedure TMainForm.LoadIniFile;
const
  IniName = 'epidataentry.ini';
var
  S: String;
begin
  // TODO : Settings can be loaded from commandline?

  if LoadSettingsFromIni(GetAppConfigFileUTF8(false)) then exit;

  // Todo - this is not optimal on Non-windows OS's. Do some checks for writeability first.
  if LoadSettingsFromIni(ExtractFilePath(Application.ExeName) + IniName) then exit;

  if not DirectoryExistsUTF8(GetAppConfigDirUTF8(false)) then
    CreateDirUTF8(GetAppConfigDirUTF8(false));
  EntrySettings.IniFileName := GetAppConfigFileUTF8(false);
end;

procedure TMainForm.SetCaption;
begin
  Caption := 'EpiData Entry Client (v' + GetEntryVersion + ')';
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SetCaption;
  {$IFDEF EPI_DEBUG}
  AboutAction.Enabled := true;
  {$ENDIF}

  LoadIniFile;

  NewProjectAction.Execute;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  List: TFPList;
  Res: LongInt;
  i: Integer;
begin
  with TProjectFrame(ActiveFrame) do
  begin
    CloseProjectAction.Execute;
    CanClose := not Assigned(EpiDocument);
  end;
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

