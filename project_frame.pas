unit project_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, epidocument, epidatafiles, dataform_frame, entry_messages, LMessages,
  documentfile_ext, epicustombase;

type

  EInvalidTimeStampException = class(Exception);

  { TProjectFrame }

  TProjectFrame = class(TFrame)
    ProgressBar1: TProgressBar;
    ProjectImageList: TImageList;
    SaveProjectAction: TAction;
    ProjectActionList: TActionList;
    ProjectPanel: TPanel;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    OpenProjectToolButton: TToolButton;
    ProjectToolButtomDivider1: TToolButton;
    SaveProjectToolButton: TToolButton;
    ProjectToolButtomDivider2: TToolButton;
    DataFilesTreeView: TTreeView;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure EpiDocumentPassWord(Sender: TObject; var Login: string;
      var Password: string);
    procedure EpiDocumentProgress(const Sender: TEpiCustomBase;
      ProgressType: TEpiProgressType; CurrentPos, MaxPos: Cardinal;
      var Canceled: Boolean);
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TDataFormFrame;
    FDocumentFile: TEntryDocumentFile;
    FBackupTimer: TTimer;
    FAllowForEndBackup: boolean;  // Indicates if the BackupOnShutdown is activated. Is set to true first time content of EpiDocument is modified.
    procedure DoSaveProject(Const aFilename: string);
    procedure DoNewDataForm(DataFile: TEpiDataFile);
    procedure DoCloseProject;
    procedure EpiDocModified(Sender: TObject);
    procedure UpdateMainCaption;
    procedure TimedBackup(Sender: TObject);
    function  DoOpenProject(Const aFilename: string): boolean;
    procedure AddToRecent(Const aFilename: string);
    procedure UpdateShortCuts;
  private
    function GetEpiDocument: TEpiDocument;
    { messages }
    // Relaying
    procedure LMDataFormGotoRec(var Msg: TLMessage); message LM_DATAFORM_GOTOREC;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   CloseQuery(var CanClose: boolean);
    function    OpenProject(Const aFilename: string): boolean;
    procedure   UpdateSettings;
    property    DocumentFile: TEntryDocumentFile read FDocumentFile;
    property    EpiDocument: TEpiDocument read GetEpiDocument;
    property    ActiveFrame: TDataFormFrame read FActiveFrame;
  public
    { Default position }
    class procedure RestoreDefaultPos(F: TProjectFrame);
  end;

implementation

{$R *.lfm}

uses
  main, epimiscutils, settings, fieldedit, LCLIntf,
  epistringutils, Menus, LCLType, shortcuts,
  RegExpr;

{ TProjectFrame }

procedure TProjectFrame.SaveProjectActionExecute(Sender: TObject);
begin
  try
    DoSaveProject(DocumentFile.FileName);
  except
    on E: Exception do
      begin
        MessageDlg('Error',
          'Unable to save project to:' + LineEnding +
          DocumentFile.FileName + LineEnding +
          'Error message: ' + E.Message,
          mtError, [mbOK], 0);
        Exit;
      end;
  end;
  EpiDocument.Modified := false;
end;

procedure TProjectFrame.EpiDocumentPassWord(Sender: TObject; var Login: string;
  var Password: string);
begin
  PassWord :=
    PasswordBox('Project Password',
                'Project data is password protected.' + LineEnding +
                'Please enter password:');
end;

procedure TProjectFrame.EpiDocumentProgress(const Sender: TEpiCustomBase;
  ProgressType: TEpiProgressType; CurrentPos, MaxPos: Cardinal;
  var Canceled: Boolean);
Const
  LastUpdate: Cardinal = 0;
  ProgressUpdate: Cardinal = 0;
begin
  case ProgressType of
    eptInit:
      begin
        ProgressUpdate := MaxPos div 50;
        ProgressBar1.Position := CurrentPos;
        ProgressBar1.Visible := true;
        ProgressBar1.Max := MaxPos;
        Application.ProcessMessages;
      end;
    eptFinish:
      begin
        ProgressBar1.Visible := false;
        Application.ProcessMessages;
        LastUpdate := 0;
      end;
    eptRecords:
      begin
        if CurrentPos > (LastUpdate + ProgressUpdate) then
        begin
          ProgressBar1.Position := CurrentPos;
          {$IFNDEF MSWINDOWS}
          Application.ProcessMessages;
          {$ENDIF}
          LastUpdate := CurrentPos;
        end;
      end;
  end;
end;

procedure TProjectFrame.SaveProjectActionUpdate(Sender: TObject);
begin
  SaveProjectAction.Enabled :=
    Assigned(DocumentFile) and
    (not DocumentFile.ReadOnly);
end;

procedure TProjectFrame.ToolButton1Click(Sender: TObject);
var
  A: TTimeEdit;
begin
  A.Commit;
end;

function TProjectFrame.DoOpenProject(const aFilename: string): boolean;
begin
  Result := false;
  try
    Screen.Cursor := crHourGlass;
    Application.ProcessMessages;

    try
      FDocumentFile := TEntryDocumentFile.Create;
      FDocumentFile.OnProgress := @EpiDocumentProgress;
      FDocumentFile.BackupDirectory := EntrySettings.BackupDirUTF8;
      FDocumentFile.DataDirectory   := EntrySettings.WorkingDirUTF8;
      if not FDocumentFile.OpenFile(AFileName) then
      begin
        FreeAndNil(FDocumentFile);
        Exit;
      end;
    except
      FreeAndNil(FDocumentFile);
      // If ever this happens then it is because something not right happened
      // during OpenFile(...) and we need to notify the user.
      raise;
    end;

    MainForm.BeginUpdateForm;
    try
      EpiDocument.OnModified := @EpiDocModified;
    except
      if Assigned(FDocumentFile) then FreeAndNil(FDocumentFile);
      if Assigned(FActiveFrame) then FreeAndNil(FActiveFrame);
      raise;
    end;

    // Create backup process.
    if EpiDocument.ProjectSettings.BackupInterval > 0 then
    begin
      FBackupTimer := TTimer.Create(Self);
      FBackupTimer.Enabled := false;
      FBackupTimer.OnTimer := @TimedBackup;                               { Milliseconds * 60 sec/min. }
      FBackupTimer.Interval := EpiDocument.ProjectSettings.BackupInterval * 60000;
    end;

    DoNewDataForm(EpiDocument.DataFiles[0]);

    EpiDocument.Modified := false;

    AddToRecent(DocumentFile.FileName);
    UpdateMainCaption;
    SaveProjectAction.Update;
    Result := true;
  finally
    MainForm.EndUpdateForm;
    Screen.Cursor := crDefault;
    Application.ProcessMessages;

    // Put the "Activate first field" here, because prior to EndUpdateForm controls
    // have no handle, and hence cannot be focused correctly.
    if Assigned(FActiveFrame) then
      FActiveFrame.FirstFieldAction.Execute;
  end;
end;

procedure TProjectFrame.AddToRecent(const aFilename: string);
begin
  Settings.AddToRecent(AFileName);
  MainForm.UpdateRecentFiles;
end;

procedure TProjectFrame.UpdateShortCuts;
begin
  SaveProjectAction.ShortCut := P_SaveProject;
end;

function TProjectFrame.GetEpiDocument: TEpiDocument;
begin
  result := nil;
  if Assigned(DocumentFile) then
    result := DocumentFile.Document;
end;

procedure TProjectFrame.LMDataFormGotoRec(var Msg: TLMessage);
begin
  if Assigned(FActiveFrame) then
    Msg.Result := SendMessage(FActiveFrame.Handle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TProjectFrame.DoSaveProject(const aFilename: string);
begin
  ActiveFrame.Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    DocumentFile.SaveFile(aFilename);
    AddToRecent(aFilename);
  finally
    ActiveFrame.Cursor := crDefault;
    Application.ProcessMessages;
  end;
end;

procedure TProjectFrame.DoNewDataForm(DataFile: TEpiDataFile);
var
  Frame: TDataFormFrame;
begin
  Frame := TDataFormFrame.Create(Self);
  Frame.Align := alClient;
  Frame.Parent := Self;
  Frame.DataFile := DataFile;
  FActiveFrame := Frame;

  DataFilesTreeView.Selected := DataFilesTreeView.Items.AddObject(nil, DataFile.Caption.Text, Frame);

  // TODO : Adapt to multiple datafiles.
  With MainForm do
  begin
    // File menu
    PrintMenuItem.Action       := Frame.PrintDataFormAction;
    PrintWithDataMenuItem.Action := Frame.PrintDataFormWithDataAction;

    // Edit menu
    CopyRecToClpMenuItem.Action := Frame.CopyToClipBoardAction;

    // Goto menu
    GotoRecordMenuItem.Action  := Frame.GotoRecordAction;
    // -
    FirstRecordMenuItem.Action := Frame.FirstRecAction;
    PrevRecordMenuItem.Action  := Frame.PrevRecAction;
    NextRecordMenuItem.Action  := Frame.NextRecAction;
    LastRecordMenuItem.Action  := Frame.LastRecAction;
    // -
    NewRecordMenuItem.Action   := Frame.NewRecordAction;
    BrowseMenu.Visible := true;

    // Browse Menu
    FindMenuItem.Action        := Frame.FindRecordAction;
    FindNextMenuItem.Action    := Frame.FindNextAction;
    FindPrevMenuItem.Action    := Frame.FindPrevAction;
    FindListMenuItem.Action    := Frame.FindFastListAction;
    BrowseAllMenuItem.Action   := Frame.BrowseAllAction;

    // Help menu.
    FieldNotesMenuItem.Action  := Frame.ShowFieldNotesAction;
    FieldNotesMenuItem.Action.Update;
  end;
end;

procedure TProjectFrame.DoCloseProject;
begin
  if not Assigned(DocumentFile) then exit;

  if FAllowForEndBackup and
     EpiDocument.ProjectSettings.BackupOnShutdown then
  begin
    try
      DocumentFile.SaveEndBackupFile;
    except
      // TODO : Warn about not saving backup file?
    end;
  end;

  // TODO : Delete ALL dataforms!
  FreeAndNil(FDocumentFile);
  FreeAndNil(FActiveFrame);
  FreeAndNil(FBackupTimer);
  DataFilesTreeView.Items.Clear;
end;

procedure TProjectFrame.EpiDocModified(Sender: TObject);
begin
  UpdateMainCaption;
  FAllowForEndBackup := true;

  // Activates/Deactivates timed backup.
  if Assigned(FBackupTimer) and Assigned(EpiDocument) then
    FBackupTimer.Enabled := EpiDocument.Modified;
end;

procedure TProjectFrame.UpdateMainCaption;
var
  S: String;
  T: String;
begin
  S := 'EpiData Entry Client (v' + GetEntryVersion + ')'
    {$IFDEF EPIDATA_TEST_RELEASE}
    + 'test version'
    {$ENDIF}
    ;

  if Assigned(EpiDocument) then
  begin
    S := S + ' - ' + ExtractFileName(DocumentFile.FileName);
    if EpiDocument.Modified then
      S := S + '*';

    T := EpiDocument.Study.Version;
    if (T <> '') then
      S := S + ' Version: ' + T;

    T := EpiDocument.Study.Title.Text;
    if (T <> '') then
      S := S + ' [' + EpiCutString(T, 20) + ']';
  end;
  MainForm.Caption := S;
end;

procedure TProjectFrame.TimedBackup(Sender: TObject);
begin
  try
    FBackupTimer.Enabled := false;
    try
      FDocumentFile.SaveBackupFile;
    except
      // TODO : Warn about not saving timed backup file.
      exit;
    end;
    FBackupTimer.Enabled := true;
  except
    //
  end;
end;

constructor TProjectFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FDocumentFile := nil;
  FActiveFrame := nil;
  FAllowForEndBackup := false;;

  UpdateSettings;

  {$IFNDEF EPI_DEBUG}
    ProjectPanel.Enabled := false;
    ProjectPanel.Visible := false;
    Splitter1.Enabled    := false;
    Splitter1.Visible    := false;
  {$ENDIF}
end;

destructor TProjectFrame.Destroy;
begin
  DoCloseProject;
  inherited Destroy;
end;

procedure TProjectFrame.CloseQuery(var CanClose: boolean);
var
  Res: LongInt;
begin
  CanClose := true;

  if not Assigned(EpiDocument) then exit;
  if not Assigned(ActiveFrame) then exit;

  // Passes control to DataformFrame, which
  // ensures a potential modified record is commited.
  ActiveFrame.CloseQuery(CanClose);
  if not CanClose then exit;

  if (EpiDocument.Modified) {or (ActiveFrame.Modified)} then
  begin
    Res := MessageDlg('Warning',
      'Project data content modified.' + LineEnding +
      'Store project permanently on disk before exit?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrNo then
    begin
      Res := MessageDlg('Warning',
        'Project content is NOT saved to disk.' + LineEnding +
        'Choose YES to permanently store data on disk!' + LineEnding +
        LineEnding +
        'Save project to disk before exit?',
        mtWarning, mbYesNoCancel, 0, mbCancel);
    end;

    case Res of
      mrCancel:
        CanClose := false;
      mrYes:
        SaveProjectAction.Execute;
    end;
  end;
end;

function TProjectFrame.OpenProject(const aFilename: string): boolean;
begin
  result := DoOpenProject(aFilename);
end;

procedure TProjectFrame.UpdateSettings;
begin
  UpdateShortCuts;

  if Assigned(ActiveFrame) then
    ActiveFrame.UpdateSettings;
end;

class procedure TProjectFrame.RestoreDefaultPos(F: TProjectFrame);
begin
  if Assigned(F) then
    TDataFormFrame.RestoreDefaultPos(F.FActiveFrame)
  else
    TDataFormFrame.RestoreDefaultPos(nil);
end;

end.

