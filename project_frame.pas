unit project_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, StdCtrls, epidocument, epidatafiles;

type

  { TProjectFrame }

  TProjectFrame = class(TFrame)
    CloseProjectAction: TAction;
    ProjectOpenDialog: TOpenDialog;
    ProjectImageList: TImageList;
    SaveProjectAction: TAction;
    OpenProjectAction: TAction;
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
    procedure CloseProjectActionExecute(Sender: TObject);
    procedure OpenProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TFrame;
    FEpiDocument: TEpiDocument;
    FDocumentFilename: string;
    FBackupTimer: TTimer;
    procedure DoSaveProject(Const aFilename: string);
    procedure DoNewDataForm(DataFile: TEpiDataFile);
    function  DoCreateNewDocument: TEpiDocument;
    procedure DoCloseProject;
    procedure EpiDocModified(Sendet: TObject);
    procedure UpdateMainCaption;
    procedure TimedBackup(Sender: TObject);
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    // TODO : Move DoOpenProject back to private when test-phase over.
    procedure DoOpenProject(Const aFilename: string);
    property  EpiDocument: TEpiDocument read FEpiDocument;
    property  ActiveFrame: TFrame read FActiveFrame;
    property  DocumentFileName: string read FDocumentFilename;
  end; 

implementation

{$R *.lfm}

uses
  main, dataform_frame, epimiscutils, settings, fieldedit, LCLIntf;

{ TProjectFrame }

procedure TProjectFrame.OpenProjectActionExecute(Sender: TObject);
var
  Res: LongInt;
  List: TFPList;
  i: Integer;
begin
  ProjectOpenDialog.InitialDir := EntrySettings.WorkingDirUTF8;
  ProjectOpenDialog.Filter := GetEpiDialogFilter(true, true, false, false, false,
    false, false, false, false, false, true);
  if not ProjectOpenDialog.Execute then exit;

  if (Assigned(EpiDocument)) and
     ((EpiDocument.Modified) or
      (TDataFormFrame(ActiveFrame).Modified))
  then begin
    Res := MessageDlg('Warning',
      'Project data content modified.' + LineEnding +
      'Save?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrCancel then exit;

    if Res = mrYes then
    begin
      // Commit field (in case they are not already).
      TDataFormFrame(ActiveFrame).CommitFields;
      SaveProjectAction.Execute;
    end;
  end;

  DoOpenProject(ProjectOpenDialog.FileName);
end;

procedure TProjectFrame.CloseProjectActionExecute(Sender: TObject);
var
  Res: LongInt;
begin
  if (EpiDocument.Modified) or
     (TDataFormFrame(ActiveFrame).Modified)
  then
  begin
    Res := MessageDlg('Warning',
      'Project data content modified.' + LineEnding +
      'Save before exit?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrCancel then exit;

    if Res = mrYes then
    begin
      // Commit field (in case they are not already.
      TDataFormFrame(ActiveFrame).CommitFields;
      SaveProjectAction.Execute;
    end;
  end;

  DoCloseProject;
end;

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

  UpdateMainCaption;
  SaveProjectAction.Update;
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
  Result.OnModified := @EpiDocModified;
end;

procedure TProjectFrame.DoCloseProject;
var
  S: String;
begin
  if not Assigned(FEpiDocument) then exit;

  if FEpiDocument.ProjectSettings.BackupOnShutdown then
  begin
    S := ExtractFileNameWithoutExt(DocumentFileName);
    DoSaveProject(S + '.' + FormatDateTime('YYYY/MM/DD', Now) + '.epx');
  end;

  // TODO : Delete ALL dataforms!
  FreeAndNil(FEpiDocument);
  FreeAndNil(FActiveFrame);
  FreeAndNil(FBackupTimer);
  if FileExistsUTF8(FDocumentFilename + '.bak') then
    DeleteFileUTF8(FDocumentFilename + '.bak');
  DataFilesTreeView.Items.Clear;
end;

procedure TProjectFrame.EpiDocModified(Sendet: TObject);
begin
  UpdateMainCaption;

  // Activates/Deactivates timed backup.
  if Assigned(FBackupTimer) and Assigned(EpiDocument) then
    FBackupTimer.Enabled := EpiDocument.Modified;
end;

procedure TProjectFrame.UpdateMainCaption;
var
  S: String;
begin
  S := 'EpiData Entry Client';

  if Assigned(EpiDocument) then
  begin
    if Assigned(ActiveFrame) then
      S := S + ' "' + TDataFormFrame(ActiveFrame).DataFile.Name.Text + '"';
  end;
  MainForm.Caption := S + ' (v' + GetEntryVersion + ')  WARNING: TEST VERSION';

  if Assigned(EpiDocument) and Assigned(ActiveFrame) then
  begin
    S := FDocumentFilename;
    if EpiDocument.Modified then
      S := S + '*';
    TDataFormFrame(ActiveFrame).FileNameEdit.Text := S;
  end;
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

  {$IFDEF EPI_RELEASE}
    ProjectPanel.Enabled := false;
    ProjectPanel.Visible := false;
    Splitter1.Enabled    := false;
    Splitter1.Visible    := false;


    Panel1.Enabled       := false;
    Panel1.Visible       := false;
  {$ENDIF}
end;

end.

