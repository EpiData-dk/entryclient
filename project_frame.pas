unit project_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, epidocument, epidatafiles, dataform_frame, entry_messages, LMessages,
  VirtualTrees, documentfile_ext, epicustombase, epirelations, Graphics;

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
    DataFileTree: TVirtualStringTree;
    procedure EpiDocumentPassWord(Sender: TObject; var Login: string;
      var Password: string);
    procedure EpiDocumentProgress(const Sender: TEpiCustomBase;
      ProgressType: TEpiProgressType; CurrentPos, MaxPos: Cardinal;
      var Canceled: Boolean);
    procedure LoadError(const Sender: TEpiCustomBase; ErrorType: Word;
      Data: Pointer; out Continue: boolean);
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
    FDocumentFile: TEntryDocumentFile;
    FBackupTimer: TTimer;
    FAllowForEndBackup: boolean;  // Indicates if the BackupOnShutdown is activated. Is set to true first time content of EpiDocument is modified.
    procedure DoSaveProject(Const aFilename: string);
    function  DoNewDataForm(DataFile: TEpiDataFile): TDataFormFrame;
    procedure DoCloseProject;
    procedure EpiDocModified(Sender: TObject);
    procedure UpdateMainCaption;
    procedure TimedBackup(Sender: TObject);
    function  DoOpenProject(Const aFilename: string): boolean;
    procedure AddToRecent(Const aFilename: string);
    procedure UpdateShortCuts;
  private
    { Relational handling (checking/updating/etc...) }
    procedure RequireFocus(Sender: TObject);
    procedure FrameModified(Sender: TObject);
    function GetFilteredDataFileSize(Const DataFile: TEpiDataFile): Integer;
    function DataformRecordChange(Sender: TObject): boolean;
    procedure LM_ProjectRelate(var Msg: TLMessage); message LM_PROJECT_RELATE;
  private
    { Tree Handling }
    FProjectNode: PVirtualNode;
    FSelectedNode: PVirtualNode;
    procedure DataFileTreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure DataFileTreeFocusChanging(Sender: TBaseVirtualTree; OldNode,
      NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
      var Allowed: Boolean);
    procedure DataFileTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure DataFileTreeInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure DataFileTreeInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure DataFileTreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
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
  public
    { Default position }
    class procedure RestoreDefaultPos(F: TProjectFrame);
  end;

implementation

{$R *.lfm}

uses
  main, epimiscutils, settings, fieldedit, LCLIntf,
  epistringutils, Menus, LCLType, shortcuts, entry_globals,
  RegExpr;

type

  TNodeData = record
    Frame: TDataFormFrame;
    Relation: TEpiMasterRelation;
    RelationList: TEpiRelationList;
  end;
  PNodeData = ^TNodeData;


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

procedure TProjectFrame.LoadError(const Sender: TEpiCustomBase;
  ErrorType: Word; Data: Pointer; out Continue: boolean);
var
  Fn: String;
begin
  Continue := false;

  Fn := string(data^);
  ShowMessage(
    'External file "' + Fn + '" not found.' + LineEnding +
    'Please restore "' + Fn + '" to folder: ' + ExtractFilePath(FDocumentFile.FileName) + LineEnding +
    'Cannot Enter Data into: ' + ExtractFileName(FDocumentFile.FileName) + LineEnding +
    'Contact Project Manager.'
  );
end;

procedure TProjectFrame.RequireFocus(Sender: TObject);
var
  Frame: TDataFormFrame;
begin
  Frame := TDataFormFrame(Sender);

  DataFileTree.FocusedNode := Frame.TreeNode;
  DataFileTree.Selected[Frame.TreeNode] := true;
  DataFileTree.InvalidateNode(Frame.TreeNode);
  Frame.BringToFront;
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
var
  Node: PVirtualNode;
begin
  Result := false;
  try
    Screen.Cursor := crHourGlass;
    Application.ProcessMessages;

    try
      FDocumentFile := TEntryDocumentFile.Create;
      FDocumentFile.OnProgress := @EpiDocumentProgress;
      FDocumentFile.OnLoadError := @LoadError;
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
//      if Assigned(FActiveFrame) then FreeAndNil(FActiveFrame);
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

    DataFileTree.RootNodeCount := 1;
    Node := FProjectNode^.FirstChild;
    DataFileTree.Selected[Node] := true;
    DataFileTree.FocusedNode := Node;

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
{    if Assigned(FActiveFrame) then
      FActiveFrame.FirstFieldAction.Execute;   }
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

procedure TProjectFrame.FrameModified(Sender: TObject);
begin
  DataFileTree.InvalidateNode(TDataFormFrame(Sender).TreeNode);
end;

function TProjectFrame.GetFilteredDataFileSize(const DataFile: TEpiDataFile
  ): Integer;
begin
  // TODO!
  result := DataFile.Size;
end;

function TProjectFrame.DataformRecordChange(Sender: TObject): boolean;

  function RecursiveRecordChange(Node: PVirtualNode): boolean;
  var
    ND: PNodeData;
  begin
    ND := DataFileTree.GetNodeData(Node);
    result := ND^.Frame.CanChange;

    Node := Node^.FirstChild;
    while Result and Assigned(Node) do
    begin
      Result := RecursiveRecordChange(Node);
      Node := Node^.NextSibling;
    end;
  end;

var
  Node: PVirtualNode;
begin
  Result := true;
  Node := TDataFormFrame(Sender).TreeNode^.FirstChild;

  while Result and Assigned(Node) do
  begin
    Result := RecursiveRecordChange(Node);
    Node := Node^.NextSibling;
  end;
end;

procedure TProjectFrame.LM_ProjectRelate(var Msg: TLMessage);
var
  DetailRelation: TEpiDetailRelation;
  Node: PVirtualNode;
  ND: PNodeData;
begin
  ND := DataFileTree.GetNodeData(FSelectedNode);
  if (not ND^.Frame.AllKeyFieldsAreFilled) then
    Exit;

  DetailRelation := TEpiDetailRelation(Msg.WParam);
  Node := PVirtualNode(DetailRelation.FindCustomData(PROJECT_RELATION_NODE_KEY));
  ND := DataFileTree.GetNodeData(Node);

  DataFileTree.Selected[Node] := true;
  DataFileTree.FocusedNode := node;

  ND^.Frame.RelateInit();
end;

procedure TProjectFrame.DataFileTreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData: PNodeData;
begin
  NodeData := PNodeData(Sender.GetNodeData(Node));
  NodeData^.Frame.BringToFront;
  FSelectedNode := Node;

  Sender.InvalidateChildren(FProjectNode, true);
end;

procedure TProjectFrame.DataFileTreeFocusChanging(Sender: TBaseVirtualTree;
  OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
  var Allowed: Boolean);
var
  NodeData: PNodeData;
begin
  if NewNode = FProjectNode then
  begin
    Allowed := False;
    Exit;
  end;


  NodeData := Sender.GetNodeData(NewNode);


  // TODO : KeyField checks etc...
end;

procedure TProjectFrame.DataFileTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  DF: TEpiDataFile;
  ND: PNodeData;
begin
  if (Node = FProjectNode) then
  begin
    if (TextType = ttNormal) then
      CellText := EpiDocument.Study.Title.Text
  end else
  begin
    ND := Sender.GetNodeData(Node);
    DF := ND^.Relation.Datafile;
    case TextType of
      ttNormal:
        CellText := BoolToStr(ND^.Frame.Modified, '*', '') + DF.Caption.Text;
      ttStatic:
        begin
          if (Node = FSelectedNode) or
             (Sender.HasAsParent(Node, FSelectedNode))
          then
            CellText := Format('(%d)', [GetFilteredDataFileSize(DF)]);
        end;
    end;
  end;
end;

procedure TProjectFrame.DataFileTreeInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
begin
  ChildCount := PNodeData(Sender.GetNodeData(Node))^.RelationList.Count;
end;

procedure TProjectFrame.DataFileTreeInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  NodeData,
  ParentData: PNodeData;
  ARelation: TEpiMasterRelation;
begin
  NodeData := Sender.GetNodeData(Node);
  ParentData := Sender.GetNodeData(ParentNode);
  InitialStates := [ivsExpanded];

  if (ParentNode = nil) then
  begin
    FProjectNode := Node;
    NodeData^.RelationList := EpiDocument.Relations;
    Include(InitialStates, ivsHasChildren);
  end else begin
    ARelation := ParentData^.RelationList[Node^.Index];
    ARelation.AddCustomData(PROJECT_RELATION_NODE_KEY, TObject(Node));
    with NodeData^ do
    begin
      Relation := ARelation;
      RelationList := ARelation.DetailRelations;
      Frame := DoNewDataForm(ARelation.Datafile);
      Frame.TreeNode := Node;
    end;
    if ARelation.DetailRelations.Count > 0 then
      Include(InitialStates, ivsHasChildren);
  end;
end;

procedure TProjectFrame.DataFileTreePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if Node = FProjectNode then exit;

  if (TextType = ttStatic) then
    TargetCanvas.Font.Color := clBlue;
end;

function TProjectFrame.GetEpiDocument: TEpiDocument;
begin
  result := nil;
  if Assigned(DocumentFile) then
    result := DocumentFile.Document;
end;

procedure TProjectFrame.LMDataFormGotoRec(var Msg: TLMessage);
begin
  // TODO
{  if Assigned(FActiveFrame) then
    Msg.Result := SendMessage(FActiveFrame.Handle, Msg.Msg, Msg.WParam, Msg.LParam);}
end;

procedure TProjectFrame.DoSaveProject(const aFilename: string);
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    DocumentFile.SaveFile(aFilename);
    AddToRecent(aFilename);
  finally
    Screen.Cursor := crDefault;
    Application.ProcessMessages;
  end;
end;

function TProjectFrame.DoNewDataForm(DataFile: TEpiDataFile): TDataFormFrame;
var
  Frame: TDataFormFrame;
begin
  Result := TDataFormFrame.Create(Self);
  Result.Align := alClient;
  Result.Parent := Self;
  Result.DataFile := DataFile;
  Result.OnModified := @FrameModified;
  Result.OnRecordChange := @DataformRecordChange;
  Result.OnRequireFocus := @RequireFocus;

//  DataFilesTreeView.Selected := DataFilesTreeView.Items.AddObject(nil, DataFile.Caption.Text, Frame);
{
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
  end;  }
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
  FAllowForEndBackup := false;;

  DataFileTree.OnGetText      := @DataFileTreeGetText;
  DataFileTree.OnInitNode     := @DataFileTreeInitNode;
  DataFileTree.OnInitChildren := @DataFileTreeInitChildren;
  DataFileTree.OnPaintText    := @DataFileTreePaintText;
  DataFileTree.NodeDataSize   := SizeOf(TNodeData);
  DataFileTree.OnFocusChanging := @DataFileTreeFocusChanging;
  DataFileTree.OnFocusChanged := @DataFileTreeFocusChanged;


  UpdateSettings;
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

  // Passes control to DataformFrame, which
  // ensures a potential modified record is commited.
//  ActiveFrame.CloseQuery(CanClose);
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

  // TODO
{  if Assigned(ActiveFrame) then
    ActiveFrame.UpdateSettings;}
end;

class procedure TProjectFrame.RestoreDefaultPos(F: TProjectFrame);
begin
{  if Assigned(F) then
    TDataFormFrame.RestoreDefaultPos(F.FActiveFrame)
  else
    TDataFormFrame.RestoreDefaultPos(nil);    }
end;

end.


