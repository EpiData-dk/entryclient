unit project_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, epidocument, epidatafiles, dataform_frame, entry_messages, LMessages;

type

  EInvalidTimeStampException = class(Exception);

  { TProjectFrame }

  TProjectFrame = class(TFrame)
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
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TDataFormFrame;
    FEpiDocument: TEpiDocument;
    FDocumentFilename: string;
    FDocumentFileTimeStamp: longint;
    FBackupTimer: TTimer;
    FAllowForEndBackup: boolean;  // Indicates if the BackupOnShutdown is activated. Is set to true first time content of EpiDocument is modified.
    procedure DoSaveProject(Const aFilename: string);
    procedure DoNewDataForm(DataFile: TEpiDataFile);
    function  DoCreateNewDocument: TEpiDocument;
    procedure DoCloseProject;
    procedure EpiDocModified(Sender: TObject);
    procedure UpdateMainCaption;
    procedure TimedBackup(Sender: TObject);
    procedure DoOpenProject(Const aFilename: string);
    procedure AddToRecent(Const aFilename: string);
    procedure UpdateShortCuts;
  private
    { messages }
    // Relaying
    procedure LMDataFormGotoRec(var Msg: TLMessage); message LM_DATAFORM_GOTOREC;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   CloseQuery(var CanClose: boolean);
    procedure   OpenProject(Const aFilename: string);
    procedure   UpdateSettings;
    procedure   RestoreDefaultPos;
    property    EpiDocument: TEpiDocument read FEpiDocument;
    property    ActiveFrame: TDataFormFrame read FActiveFrame;
    property    DocumentFileName: string read FDocumentFilename;
  end; 

implementation

{$R *.lfm}

uses
  main, epimiscutils, settings, fieldedit, LCLIntf,
  epistringutils, Menus, LCLType, shortcuts;

{ TProjectFrame }

procedure TProjectFrame.SaveProjectActionExecute(Sender: TObject);
begin
  try
    if (FileAgeUTF8(FDocumentFilename) <> FDocumentFileTimeStamp) then
    begin
      if MessageDlg('WARNING', 'Project file: ' + FDocumentFilename  + ' has been modified by another program since last save.' + LineEnding+
       'Overwrite modified file?', mtWarning, mbYesNo, 0, mbNo) = mrNo then exit;
    end;
    DoSaveProject(FDocumentFilename);
  except
    on E: EFCreateError do
      begin
        MessageDlg('Error',
          'Unable to save project to:' + LineEnding +
          FDocumentFilename + LineEnding +
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

procedure TProjectFrame.SaveProjectActionUpdate(Sender: TObject);
begin
  SaveProjectAction.Enabled := Assigned(FEpiDocument);
end;

procedure TProjectFrame.ToolButton1Click(Sender: TObject);
var
  A: TTimeEdit;
begin
  A.Commit;
end;

procedure TProjectFrame.DoOpenProject(const aFilename: string);
var
  Res: LongInt;
  Fn: String;
  St: TMemoryStream;
  T: TDateTime;
begin
  Fn := aFilename;
  Res := mrNone;
  if FileExistsUTF8(Fn + '.bak') then
  begin
    Res := MessageDlg('Information',
             'A timed backup file exists. (loading of this overwrites previous project file)' + LineEnding + LineEnding +
             'File: ' +  #9  + #9  + SysToUTF8(ExtractFileName(UTF8ToSys(Fn)))          +
               ' (' + FormatDateTime('YYYY/MM/DD HH:NN:SS', FileDateToDateTime(FileAgeUTF8(Fn))) + ')' + LineEnding +
             'Recovery: ' + #9 + SysToUTF8(ExtractFileName(UTF8ToSys(Fn + '.bak'))) +
               ' (' + FormatDateTime('YYYY/MM/DD HH:NN:SS', FileDateToDateTime(FileAgeUTF8(Fn + '.bak'))) + ')' + LineEnding +  LineEnding +
             'Load the backup instead?',
             mtInformation, mbYesNoCancel, 0, mbYes);
    case Res of
      mrYes:    Fn := aFilename + '.bak';
      mrNo:     begin
                  Res := MessageDlg('Warning',
                           'Loading ' + SysToUTF8(ExtractFileName(UTF8ToSys(Fn))) + ' will delete recovery file.' + LineEnding +
                           'Continue?',
                           mtWarning, mbYesNo, 0, mbNo);
                  case Res of
                    mrNo:  Exit;
                    mrYes: Res := mrNo;  // Res used later to check for modification state.
                  end;
                end;
      mrCancel: Exit;
    end;
  end;

  DoCloseProject;

  try
    Cursor := crHourGlass;
    Application.ProcessMessages;
    MainForm.BeginUpdateForm;

    St := nil;
    try
      St := TMemoryStream.Create;
      if ExtractFileExt(UTF8ToSys(Fn)) = '.epz' then
        ZipFileToStream(St, Fn)
      else
        St.LoadFromFile(UTF8ToSys(Fn));
      St.Position := 0;
      FEpiDocument := DoCreateNewDocument;
      FEpiDocument.OnPassword   := @EpiDocumentPassWord;
      FEpiDocument.LoadFromStream(St);
      FEpiDocument.OnModified := @EpiDocModified;
      FDocumentFilename := Fn;
    except
      if Assigned(St) then FreeAndNil(St);
      if Assigned(FEpiDocument) then FreeAndNil(FEpiDocument);
      if Assigned(FActiveFrame) then FreeAndNil(FActiveFrame);
      raise;
    end;
    FDocumentFileTimeStamp := FileAgeUTF8(Fn);

    // Create backup process.
    if EpiDocument.ProjectSettings.BackupInterval > 0 then
    begin
      FBackupTimer := TTimer.Create(Self);
      FBackupTimer.Enabled := false;
      FBackupTimer.OnTimer := @TimedBackup;                               { Milliseconds * 60 sec/min. }
      FBackupTimer.Interval := EpiDocument.ProjectSettings.BackupInterval * 60000;
    end;

    DoNewDataForm(FEpiDocument.DataFiles[0]);

    if Res = mrYes then
      EpiDocument.Modified := true;

    AddToRecent(DocumentFileName);
    UpdateMainCaption;
    SaveProjectAction.Update;
  finally
    Cursor := crDefault;
    Application.ProcessMessages;
    MainForm.EndUpdateForm;
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

procedure TProjectFrame.LMDataFormGotoRec(var Msg: TLMessage);
begin
  if Assigned(FActiveFrame) then
    Msg.Result := SendMessage(FActiveFrame.Handle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TProjectFrame.DoSaveProject(const aFilename: string);
var
  Fs: TFileStream;
  Ms: TMemoryStream;
begin
  ActiveFrame.Cursor := crHourGlass;
  Application.ProcessMessages;
  Fs := nil;
  Ms := nil;
  try
    Ms := TMemoryStream.Create;
    EpiDocument.Study.ModifiedDate := Now;
    EpiDocument.SaveToStream(Ms);
    Ms.Position := 0;

    if ExtractFileExt(UTF8ToSys(aFilename)) = '.epz' then
      StreamToZipFile(Ms, aFilename)
    else begin
      Fs := TFileStream.Create(UTF8ToSys(aFilename), fmCreate);
      Fs.CopyFrom(Ms, Ms.Size);
    end;
    FDocumentFileTimeStamp := FileAgeUTF8(aFilename);
  finally
    ActiveFrame.Cursor := crDefault;
    Application.ProcessMessages;
    if Assigned(Ms) then FreeAndNil(Ms);
    if Assigned(Fs) then FreeAndNil(Fs);
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
    // Browse menu
    GotoRecordMenuItem.Action  := Frame.GotoRecordAction;
    // -
    FirstRecordMenuItem.Action := Frame.FirstRecAction;
    PrevRecordMenuItem.Action  := Frame.PrevRecAction;
    NextRecordMenuItem.Action  := Frame.NextRecAction;
    LastRecordMenuItem.Action  := Frame.LastRecAction;
    // -
    NewRecordMenuItem.Action   := Frame.NewRecordAction;
    BrowseMenu.Visible := true;

    // Search Menu
    FindMenuItem.Action        := Frame.FindRecordAction;
    FindNextMenuItem.Action    := Frame.FindNextAction;
    FindPrevMenuItem.Action    := Frame.FindPrevAction;
    FindListMenuItem.Action    := Frame.FindFastListAction;

    // Help menu.
    FieldNotesMenuItem.Action  := Frame.ShowFieldNotesAction;
    FieldNotesMenuItem.Action.Update;
  end;
end;

function TProjectFrame.DoCreateNewDocument: TEpiDocument;
begin
  Result := TEpiDocument.Create('en');
end;

procedure TProjectFrame.DoCloseProject;
var
  S: String;
  Y, M, D: word;
begin
  if not Assigned(FEpiDocument) then exit;

  if FAllowForEndBackup and
     FEpiDocument.ProjectSettings.BackupOnShutdown then
  begin
    S := ExtractFileNameWithoutExt(DocumentFileName);
    DecodeDate(Now, Y, M, D);
    try
      DoSaveProject(S + '.' + Format('%d-%.2d-%.2d', [Y,M,D]) + '.epz');
    except
      // TODO : Warn about not saving backup file?
    end;
  end;

  // TODO : Delete ALL dataforms!
  FreeAndNil(FEpiDocument);
  FreeAndNil(FActiveFrame);
  FreeAndNil(FBackupTimer);
  if FileExistsUTF8(FDocumentFilename + '.bak') then
    DeleteFileUTF8(FDocumentFilename + '.bak');
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
    S := S + ' - ' + ExtractFileName(FDocumentFilename);
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
      DoSaveProject(DocumentFileName + '.bak');
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
  FEpiDocument := nil;
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
      'Save before exit?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrCancel then
      CanClose := false;

    if Res = mrYes then
      SaveProjectAction.Execute;
  end;
end;

procedure TProjectFrame.OpenProject(const aFilename: string);
begin
  DoOpenProject(aFilename);
end;

procedure TProjectFrame.UpdateSettings;
begin
  UpdateShortCuts;

  if Assigned(ActiveFrame) then
    ActiveFrame.UpdateSettings;
end;

procedure TProjectFrame.RestoreDefaultPos;
begin
  if Assigned(FActiveFrame) then
    FActiveFrame.RestoreDefaultPos;
end;

end.

