unit project_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, epidocument, epidatafiles, dataform_frame;

type

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
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TDataFormFrame;
    FEpiDocument: TEpiDocument;
    FDocumentFilename: string;
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
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    procedure   CloseQuery(var CanClose: boolean);
    procedure   OpenProject(Const aFilename: string);
    procedure   UpdateSettings;
    property    EpiDocument: TEpiDocument read FEpiDocument;
    property    ActiveFrame: TDataFormFrame read FActiveFrame;
    property    DocumentFileName: string read FDocumentFilename;
  end; 

implementation

{$R *.lfm}

uses
  main, epimiscutils, settings, fieldedit, LCLIntf,
  epistringutils;

{ TProjectFrame }

procedure TProjectFrame.SaveProjectActionExecute(Sender: TObject);
begin
  DoSaveProject(FDocumentFilename);
  EpiDocument.Modified := false;
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

  Cursor := crHourGlass;
  Application.ProcessMessages;

  St := TMemoryStream.Create;
  if ExtractFileExt(UTF8ToSys(Fn)) = '.epz' then
    ZipFileToStream(St, Fn)
  else
    St.LoadFromFile(Fn);
  St.Position := 0;
  FEpiDocument := DoCreateNewDocument;
  FEpiDocument.LoadFromStream(St);
  FEpiDocument.OnModified := @EpiDocModified;
  FDocumentFilename := Fn;

  // Create backup process.
  if EpiDocument.ProjectSettings.BackupInterval > 0 then
  begin
    FBackupTimer := TTimer.Create(Self);
    FBackupTimer.Enabled := false;
    FBackupTimer.OnTimer := @TimedBackup;                               { Milliseconds * 60 sec/min. }
    FBackupTimer.Interval := EpiDocument.ProjectSettings.BackupInterval * 60000;
  end;

  DoNewDataForm(FEpiDocument.DataFiles[0]);

  Cursor := crDefault;
  Application.ProcessMessages;
  if Res = mrYes then
    EpiDocument.Modified := true;

  AddToRecent(DocumentFileName);
  UpdateMainCaption;
  SaveProjectAction.Update;
end;

procedure TProjectFrame.AddToRecent(const aFilename: string);
begin
  Settings.AddToRecent(AFileName);
  MainForm.UpdateRecentFiles;
end;

procedure TProjectFrame.DoSaveProject(const aFilename: string);
var
  Fs: TFileStream;
  Ms: TMemoryStream;
begin
  ActiveFrame.Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    Ms := TMemoryStream.Create;
    EpiDocument.SaveToStream(Ms);
    Ms.Position := 0;

    if ExtractFileExt(UTF8ToSys(aFilename)) = '.epz' then
      StreamToZipFile(Ms, aFilename)
    else begin
      Fs := TFileStream.Create(aFilename, fmCreate);
      Fs.CopyFrom(Ms, Ms.Size);
      Fs.Free;
    end;
  finally
    ActiveFrame.Cursor := crDefault;
    Application.ProcessMessages;
    Ms.Free;
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

  DataFilesTreeView.Selected := DataFilesTreeView.Items.AddObject(nil, DataFile.Name.Text, Frame);

  // TODO : Adapt to multiple datafiles.
  With MainForm do
  begin
    GotoRecordMenuItem.Action  := Frame.GotoRecordAction;
    // -
    FirstRecordMenuItem.Action := Frame.FirstRecAction;
    PrevRecordMenuItem.Action  := Frame.PrevRecAction;
    NextRecordMenuItem.Action  := Frame.NextRecAction;
    LastRecordMenuItem.Action  := Frame.LastRecAction;
    // -
    NewRecordMenuItem.Action   := Frame.NewRecordAction;
    BrowseMenu.Visible := true;
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
    DoSaveProject(S + '.' + Format('%d-%.2d-%.2d', [Y,M,D]) + '.epz');
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
  S := 'EpiData Entry Client (v' + GetEntryVersion + ') test version';

  if Assigned(EpiDocument) then
  begin
    S := S + ' - ' + ExtractFileName(FDocumentFilename);
    if EpiDocument.Modified then
      S := S + '*';

    if Assigned(ActiveFrame) then
    begin
      T := TDataFormFrame(ActiveFrame).DataFile.Name.Text;
      if (T <> '') then
        S := S + ' [' + EpiCutString(T, 20) + ']';
    end;
  end;
  MainForm.Caption := S;
end;

procedure TProjectFrame.TimedBackup(Sender: TObject);
begin
  try
    FBackupTimer.Enabled := false;
    DoSaveProject(DocumentFileName + '.bak');
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

  {$IFDEF EPI_RELEASE}
    ProjectPanel.Enabled := false;
    ProjectPanel.Visible := false;
    Splitter1.Enabled    := false;
    Splitter1.Visible    := false;
  {$ENDIF}
end;

procedure TProjectFrame.CloseQuery(var CanClose: boolean);
var
  Res: LongInt;
begin
  if (EpiDocument.Modified) or (ActiveFrame.Modified) then
  begin
    Res := MessageDlg('Warning',
      'Project data content modified.' + LineEnding +
      'Save before exit?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrCancel then exit;

    if Res = mrYes then
    begin
      // Commit field (in case they are not already.
      if (MainForm.ActiveControl is TFieldEdit) and
         (not TFieldEdit(MainForm.ActiveControl).ValidateEntry) then exit;
      ActiveFrame.CommitFields;
      SaveProjectAction.Execute;
      CanClose := true;
    end;
  end;
end;

procedure TProjectFrame.OpenProject(const aFilename: string);
begin
  DoOpenProject(aFilename);
end;

procedure TProjectFrame.UpdateSettings;
begin
  // TODO : Implement recursive call of updated settings.
end;

end.

