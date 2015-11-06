unit project_frame;

{$codepage UTF8}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, epidocument, epidatafiles, dataform_frame, entry_messages, LMessages,
  VirtualTrees, documentfile_ext, epicustombase, epirelations, Graphics,
  StdCtrls, Menus, epidatafilestypes;

type

  EInvalidTimeStampException = class(Exception);

  { TProjectFrame }

  TProjectFrame = class(TFrame)
    CloseProjectAction: TAction;
    OpenProjectAction: TAction;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    ProjectRecentFilesDropDownMenu: TPopupMenu;
    ProgressBar1: TProgressBar;
    SaveProjectAction: TAction;
    ProjectActionList: TActionList;
    ProjectPanel: TPanel;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    OpenProjectToolButton: TToolButton;
    ProjectToolButtomDivider1: TToolButton;
    SaveProjectToolButton: TToolButton;
    ProjectToolButtomDivider2: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure CloseProjectActionExecute(Sender: TObject);
    procedure EpiDocumentPassWord(Sender: TObject; var Login: string;
      var Password: string);
    procedure EpiDocumentProgress(const Sender: TEpiCustomBase;
      ProgressType: TEpiProgressType; CurrentPos, MaxPos: Cardinal;
      var Canceled: Boolean);
    procedure LoadError(const Sender: TEpiCustomBase; ErrorType: Word;
      Data: Pointer; out Continue: boolean);
    procedure OpenProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
    DataFileTree: TVirtualStringTree;
    FDocumentFile: TEntryDocumentFile;
    FBackupTimer: TTimer;
    FAllowForEndBackup: boolean;  // Indicates if the BackupOnShutdown is activated. Is set to true first time content of EpiDocument is modified.
    procedure DoSaveProject(Const aFilename: string);
    function  DoNewDataForm(ARelation: TEpiMasterRelation): TDataFormFrame;
    procedure DoCloseProject;
    procedure EpiDocModified(Sender: TObject);
    procedure UpdateMainCaption;
    procedure TimedBackup(Sender: TObject);
    function  DoOpenProject(Const aFilename: string): boolean;
    procedure AddToRecent(Const aFilename: string);
    procedure UpdateShortCuts;
    procedure UpdateActionLinks;
  private
    { Relational handling (checking/updating/etc...) }
    FRelateToParent: boolean;
    FRelateToNextDataform: boolean;
    procedure FrameModified(Sender: TObject);
    procedure FrameRecordchanged(Sender: TObject);
    procedure LM_ProjectRelate(var Msg: TLMessage); message LM_PROJECT_RELATE;
  private
    { Tree Handling }
    FChangingRecNo: integer;
    FProjectNode: PVirtualNode;
    FSelectedNode: PVirtualNode;
    function GetRecordState(Node: PVirtualNode): TEpiRecordState;
    function FrameFromNode(Node: PVirtualNode): TDataFormFrame;
    function NodeIsSelectable(Node: PVirtualNode): boolean;
    function NodeIsValidated(Node: PVirtualNode): boolean;
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
    procedure DataFileTreeGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: String);
  private
    function GetEpiDocument: TEpiDocument;
    { messages }
    // Relaying
    procedure LMDataFormGotoRec(var Msg: TLMessage); message LM_DATAFORM_GOTOREC;
    procedure OpenRecentMenuItemClick(Sender: TObject);
    procedure UpdateRecentFilesDropDown;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   CloseQuery(var CanClose: boolean);
    function    OpenProject(Const aFilename: string): boolean;
    procedure   UpdateSettings;
    function    FrameFromRelation(Relation: TEpiMasterRelation): TDataFormFrame;
    property    DocumentFile: TEntryDocumentFile read FDocumentFile;
    property    EpiDocument: TEpiDocument read GetEpiDocument;
  public
    { Default position }
    class procedure RestoreDefaultPos(F: TProjectFrame);
  end;

implementation

{$R *.lfm}

uses
  epiv_datamodule,
  main, epimiscutils, settings, fieldedit, LCLIntf,
  epistringutils, LCLType, shortcuts, entry_globals,
  RegExpr, LazUTF8, entryprocs;

type

  TNodeData = record
    Frame: TDataFormFrame;
    Relation: TEpiMasterRelation;
    RelationList: TEpiRelationList;
  end;
  PNodeData = ^TNodeData;

var
  TextCount: QWord;
  PaintCount: QWord;

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

procedure TProjectFrame.CloseProjectActionExecute(Sender: TObject);
begin
  PostMessage(MainForm.Handle, LM_CLOSE_PROJECT, WParam(Sender), 0);
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
        if not (csDestroying in ComponentState) then
          Application.ProcessMessages;
      end;
    eptFinish:
      begin
        ProgressBar1.Visible := false;
        if not (csDestroying in ComponentState) then
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

procedure TProjectFrame.OpenProjectActionExecute(Sender: TObject);
begin
  PostMessage(MainForm.Handle, LM_OPEN_PROJECT, 0, 0);
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
  Dummy: string;
  Res: TModalResult;
begin
  Result := false;
  try
    Screen.Cursor := crHourGlass;
    Application.ProcessMessages;

    try
      FDocumentFile := TEntryDocumentFile.Create;
      FDocumentFile.OnProgress := @EpiDocumentProgress;
      FDocumentFile.OnLoadError := @LoadError;
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

    // Test the End-Backup location. If not then warn and ask user what
    // to do.
    if (not FDocumentFile.IsEndBackupFileWriteable(Dummy)) then
    begin
      Res := MessageDlg(
        'Warning',
        'The file: ' + LineEnding +
          FDocumentFile.FileName + LineEnding +
          LineEnding +
          'cannot write backups when project is closed in folder:' + LineEnding +
          ExtractFilePath(Dummy) + LineEnding +
          LineEnding +
          'Continue opening this project?' + LineEnding +
          LineEnding +
          '(Use program parameter -b to change default backup location)',
        mtWarning,
        mbYesNo,
        0,
        mbOK
      );

      case Res of
        mrOk:
          ;  // Do nothing
        mrNo:
          begin
            FreeAndNil(FDocumentFile);
            Exit;
          end;
      end;
    end;


    MainForm.BeginUpdateForm;
    try
      EpiDocument.OnModified := @EpiDocModified;
    except
      if Assigned(FDocumentFile) then FreeAndNil(FDocumentFile);
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

    // We must initialize the project node by ourselves, because even though
    // the project panel MIGHT be visible, is has not yet initialized the tree nodes.
    // In that case FProjectNode is not available later on!
    DataFileTree.RootNodeCount := 1;
    DataFileTree.ReinitNode(DataFileTree.RootNode, true);

    Node := FProjectNode^.FirstChild;
    DataFileTree.Selected[Node] := true;
    DataFileTree.FocusedNode := Node;

    ProjectPanel.Visible := (EpiDocument.DataFiles.Count > 1);
    Splitter1.Visible    := ProjectPanel.Visible;

    EpiDocument.Modified := false;

    AddToRecent(DocumentFile.FileName);
    UpdateMainCaption;
    SaveProjectAction.Update;
    Result := true;
  finally
    MainForm.EndUpdateForm;
    Screen.Cursor := crDefault;
    Application.ProcessMessages;
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

procedure TProjectFrame.UpdateActionLinks;
var
  Frame: TDataFormFrame;
begin
  Frame := FrameFromNode(FSelectedNode);

  With MainForm do
  begin
    // File menu
    PrintMenuItem.Action         := Frame.PrintDataFormAction;
    PrintWithDataMenuItem.Action := Frame.PrintDataFormWithDataAction;

    // Edit menu
    CopyRecToClpMenuItem.Action := Frame.CopyToClipBoardAction;
    CopyFieldToClpMenuItem.Action := FRame.CopyFieldToClipboardAction;

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

procedure TProjectFrame.FrameModified(Sender: TObject);
begin
  DataFileTree.Invalidate; //ToBottom(FProjectNode);
end;

procedure TProjectFrame.FrameRecordchanged(Sender: TObject);
var
  Relation: TEpiMasterRelation;
  i: Integer;
begin
  // Invalidate updates the tree with new values/selectables
  DataFileTree.Invalidate;

  Relation := TDataFormFrame(Sender).Relation;

  for i := 0 to Relation.DetailRelations.Count - 1 do
    FrameFromRelation(Relation[i]).RelateInit(rrRecordChange, GetRecordState(TDataFormFrame(Sender).TreeNode));
end;

procedure TProjectFrame.LM_ProjectRelate(var Msg: TLMessage);
var
  Relation: TEpiMasterRelation;
  Node: PVirtualNode;
  ND: PNodeData;
  Frame: TDataFormFrame;
begin
  Relation := TEpiMasterRelation(Msg.WParam);
  Node := PVirtualNode(Relation.FindCustomData(PROJECT_RELATION_NODE_KEY));

  FRelateToParent := (Msg.LParam = 1);
  FRelateToNextDataform := (Msg.LParam = 2);

  DataFileTree.FocusedNode := Node;

  if DataFileTree.FocusedNode = Node then
    DataFileTree.Selected[Node] := true;
end;

function TProjectFrame.GetRecordState(Node: PVirtualNode): TEpiRecordState;
var
  Idx: Integer;
begin
  Result := rsNormal;

  if not Assigned(Node) then exit;
  if Node = FProjectNode then exit;

  with FrameFromNode(Node) do
  begin
    Idx := IndexedRecNo;

    if Idx = NewRecord then exit;

    if DataFile.Deleted[Idx] then
      Result := rsDeleted;

    if DataFile.Verified[Idx] then
      Result := rsVerified;
  end;
end;

function TProjectFrame.FrameFromNode(Node: PVirtualNode): TDataFormFrame;
begin
  result := PNodeData(DataFileTree.GetNodeData(Node))^.Frame;
end;

function TProjectFrame.NodeIsSelectable(Node: PVirtualNode): boolean;
begin
  Result := true;

  if Node^.Parent = FProjectNode then exit;

  Result := (FrameFromNode(Node^.Parent).AllKeyFieldsAreFilled);
end;

function TProjectFrame.NodeIsValidated(Node: PVirtualNode): boolean;
var
  Res: TModalResult;
  DefaultBtn: TMsgDlgBtn;
begin
  result := true;

  if Node = FProjectNode then exit;

  with FrameFromNode(Node) do
  begin
    if RecNo = NewRecord then
      DefaultBtn := mbOk
    else
      DefaultBtn := mbCancel;

    if Modified then
    begin
      Res := MessageDlg('Warning',
               'Save record before change?',
               mtConfirmation, mbYesNoCancel, 0, DefaultBtn);
      case Res of
        mrCancel: Result := false;
        mrYes:    Result := AllFieldsValidate(false);
        mrNo:     begin
                    Modified := false; // Do nothing
                    NewRecordAction.Execute;
                    Result := false;
                  end;
      end;
    end;
  end;
end;

procedure TProjectFrame.DataFileTreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  RelateReason: TRelateReason;
  P: PVirtualNode;
  DestRelation: TEpiMasterRelation;
  PFrame: TDataFormFrame;
  C: PVirtualNode;
  CFrame: TDataFormFrame;
begin
  RelateReason := rrFocusShift;

  // We are allowed to change node (this was confirmed in DataFileTreeFocusChanging)
  // now we must commit unsaved data and position at the saved record no.
  // There is no FSelectedNode first time after a project is loaded...
  if Assigned(FSelectedNode) then
    with FrameFromNode(FSelectedNode) do
    begin
      if Modified then
      begin
        CommitFields;
        if FChangingRecNo = NewRecord then
        begin
          RelateReason := rrNewRecord;
          RecNo := DataFile.Size - 1
        end;
      end;

      ActionList1.State := asSuspended;
    end;

  // Relate to Parent here, because the reason is set to rrNewRecord
  // based on RecNo - but relate to parent is define by eg. pressing a key;
  if FRelateToParent then
  begin
    RelateReason := rrReturnToParent;
    FRelateToParent := false;
  end;

  if FRelateToNextDataform then
  begin
    RelateReason := rrRelateToNextDF;
    FRelateToNextDataform := false;
  end;


  if (RelateReason = rrFocusShift) and
     (Assigned(FSelectedNode)) and
     (Assigned(Node))
  then
  begin
    // Notify dataforms, that an explicit focus-shift occured. Information about dataform-relate
    // information may need to be updated.
    DestRelation := FrameFromNode(Node).Relation;

    P := FSelectedNode;
    PFrame := FrameFromNode(P);
    while (P <> FProjectNode) and
          (not PFrame.Relation.IsChild(DestRelation, true)) do
    begin
      PFrame.UpdateChildFocusShift(nil);
      P := P^.Parent;
      PFrame := FrameFromNode(P);
    end;

    repeat
      C := DataFileTree.GetFirstChild(P);
      CFrame := FrameFromNode(C);
      while (not CFrame.Relation.IsChild(DestRelation, true)) and
            (C <> Node)
      do
        begin
          C := DataFileTree.GetNextSibling(C);
          CFrame := FrameFromNode(C);
        end;

      // PFrame could be nil, if NODE is a main dataform.
      if Assigned(PFrame) then
        PFrame.UpdateChildFocusShift(CFrame.Relation);

      P := C;
      PFrame := CFrame;
    until (P = Node);
  end;

  FSelectedNode := Node;
  UpdateActionLinks;

  with FrameFromNode(Node) do
  begin
    ActionList1.State := asNormal;
    BringToFront;
    UpdateSettings;
    RelateInit(RelateReason, GetRecordState(Node^.Parent));
  end;

  Sender.Invalidate;
end;

procedure TProjectFrame.DataFileTreeFocusChanging(Sender: TBaseVirtualTree;
  OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
  var Allowed: Boolean);
begin
  Allowed := true;

  // We can always change to the same node!
  if NewNode = OldNode then exit;

  // We can NEVER change to the project node!
  if NewNode = FProjectNode then
  begin
    Allowed := False;
    Exit;
  end;

  // We cannot select "nothing"
  Allowed := Assigned(NewNode);

  // Check for selectability.
  Allowed := Allowed and
    NodeIsSelectable(NewNode);

  // This case is only when the project is just loaded.
  if (not Assigned(OldNode)) then Exit;

  // Check for validated fields
  Allowed := Allowed and
    NodeIsValidated(OldNode);

  if Allowed then
    FChangingRecNo := FrameFromNode(OldNode).RecNo;
end;

procedure TProjectFrame.DataFileTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  DF: TEpiDataFile;
  ND: PNodeData;
  S: String;
  Frame: TDataFormFrame;
begin
  if (Node = FProjectNode) then
  begin
    if (TextType = ttNormal) then
      S := EpiDocument.Study.Title.Text
  end else
  begin
    ND := Sender.GetNodeData(Node);
    DF := ND^.Relation.Datafile;
    Frame := ND^.Frame;
    case TextType of
      ttNormal:
        S := BoolToStr(Frame.Modified, '*', '') + DF.Caption.Text;
      ttStatic:
        if (Node = FSelectedNode) or
           (Sender.HasAsParent(Node, FSelectedNode))
        then
          begin
            if (Node^.Parent = FProjectNode) then
              S := Format('[%d]', [Frame.IndexedSize])
            else
              S := Format('[%d] (%d)', [DF.Size, Frame.IndexedSize]);
          end;
    end;
  end;

  CellText := S;
end;

procedure TProjectFrame.DataFileTreeInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  RelationList: TEpiRelationList;
  MR: TEpiMasterRelation;
begin
  RelationList := PNodeData(Sender.GetNodeData(Node))^.RelationList;

  // EPX Version <= 2 file:
  if (Node = FProjectNode) and
     (RelationList.Count = 0)
  then
    begin
      MR := RelationList.NewMasterRelation;
      MR.Datafile := EpiDocument.DataFiles[0];
    end;

  ChildCount := RelationList.Count;
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
    // Project Node: In manager this is where the project details are set.
    FProjectNode := Node;
    NodeData^.RelationList := EpiDocument.Relations;
    Include(InitialStates, ivsHasChildren);
  end else begin
    ARelation := ParentData^.RelationList[Node^.Index];

    // In case of a double-initialization...
    if (not Assigned(NodeData^.Frame)) then
    begin
      ARelation.AddCustomData(PROJECT_RELATION_NODE_KEY, TObject(Node));
      with NodeData^ do
      begin
        Relation := ARelation;
        RelationList := ARelation.DetailRelations;
        Frame := DoNewDataForm(ARelation);
        Frame.TreeNode := Node;
        Frame.ActionList1.State := asSuspended;
      end;
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

  case TextType of
    ttNormal:
      begin
        if NodeIsSelectable(Node)
        then
          TargetCanvas.Font.Color := clDefault
        else
          TargetCanvas.Font.Color := clInactiveCaption;
      end;
    ttStatic:
      TargetCanvas.Font.Color := clBlue;
  end;
end;

procedure TProjectFrame.DataFileTreeGetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: String);
var
  ND: PNodeData;
  Rel: TEpiDetailRelation;
  S: String;
begin
  if Node = FProjectNode then exit;
  S := '';

  ND := Sender.GetNodeData(Node);
  if ND^.Relation is TEpiDetailRelation then
  begin
    S += '1:';

    Rel := TEpiDetailRelation(ND^.Relation);
    if Rel.MaxRecordCount = 0 then
      S += char($E2) + char($88) + char($9E)             // unicode infinity symbol (UTF-8 encoded)
    else
      S += IntToStr(Rel.MaxRecordCount);

    S += LineEnding;
  end;

  S += TrimRight(FrameFromNode(Node).GetCurrentKeyFieldValues);

  HintText := S;
end;

function TProjectFrame.GetEpiDocument: TEpiDocument;
begin
  result := nil;
  if Assigned(DocumentFile) then
    result := DocumentFile.Document;
end;

procedure TProjectFrame.LMDataFormGotoRec(var Msg: TLMessage);
var
  ND: PNodeData;
begin
  if Assigned(FSelectedNode) then
  begin
    ND := DataFileTree.GetNodeData(FSelectedNode);
    Msg.Result := SendMessage(ND^.Frame.Handle, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

procedure TProjectFrame.OpenRecentMenuItemClick(Sender: TObject);
begin
  OpenProjectToolButton.Style := tbsButton;
  PostMessage(MainForm.Handle, LM_OPEN_RECENT, WParam(Sender), 0);
end;

procedure TProjectFrame.UpdateRecentFilesDropDown;
var
  K: Word;
  Shift: TShiftState;
  i: Integer;
  Mi: TMenuItem;
begin
  ShortCutToKey(M_OpenRecent, K, Shift);

  LoadRecentFilesIni(GetRecentIniFileName);
  ProjectRecentFilesDropDownMenu.Items.Clear;

  for i := 0 to RecentFiles.Count - 1 do
  begin
    Mi := TMenuItem.Create(ProjectRecentFilesDropDownMenu);
    Mi.Name := 'project_frame_recent' + inttostr(i);
    Mi.Caption := RecentFiles[i];
    Mi.OnClick := @OpenRecentMenuItemClick;
    if i < 9 then
      Mi.ShortCut := ShortCut(VK_1 + i, Shift);
    ProjectRecentFilesDropDownMenu.Items.Add(Mi);
  end;
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

function TProjectFrame.DoNewDataForm(ARelation: TEpiMasterRelation
  ): TDataFormFrame;
var
  Frame: TDataFormFrame;
begin
  Result := TDataFormFrame.Create(Self);
  Result.Align := alClient;
  Result.Parent := Self;
  Result.Relation := ARelation;
  Result.DataFile := ARelation.DataFile;
  Result.OnModified := @FrameModified;
  Result.OnRecordChanged := @FrameRecordChanged;
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
  FAllowForEndBackup := false;
  FRelateToParent := false;

  FChangingRecNo := NewRecord;

  DataFileTree := TVirtualStringTree.Create(Self);
  with DataFileTree do
  begin
    Align := alClient;
    Parent := ProjectPanel;
    Header.AutoSizeIndex := 0;
    HintMode := hmHint;
    ScrollBarOptions.ScrollBars := ssAutoBoth;
    TabOrder := 1;
    TreeOptions.PaintOptions := [toHotTrack, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages];
    TreeOptions.StringOptions := [toSaveCaptions, toShowStaticText, toAutoAcceptEditChange];

    ShowHint       := true;
    OnGetText      := @DataFileTreeGetText;
    OnInitNode     := @DataFileTreeInitNode;
    OnInitChildren := @DataFileTreeInitChildren;
    OnPaintText    := @DataFileTreePaintText;
    NodeDataSize   := SizeOf(TNodeData);
    OnFocusChanging := @DataFileTreeFocusChanging;
    OnFocusChanged := @DataFileTreeFocusChanged;
    OnGetHint      := @DataFileTreeGetHint;
  end;

  ToolBar1.Images := DM.Icons16;

  Label2.Caption := '0';
  TextCount := 0;
  Label4.Caption := '0';
  PaintCount := 0;

  UpdateShortCuts;
  UpdateRecentFilesDropDown;
end;

destructor TProjectFrame.Destroy;
begin
  if Splitter1.Visible then
    SaveSplitterPosition(Splitter1, 'ProjectSplitter');

  DoCloseProject;
  inherited Destroy;
end;

procedure TProjectFrame.CloseQuery(var CanClose: boolean);
var
  Res: LongInt;
  Frame: TDataFormFrame;
begin
  CanClose := true;

  if not Assigned(EpiDocument) then exit;

  // Passes control to DataformFrame, which
  // ensures a potential modified record is commited.
  Frame := FrameFromNode(FSelectedNode);
  Frame.CloseQuery(CanClose);
  if not CanClose then exit;

  if (EpiDocument.Modified) {or (Frame.Modified)} then
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
  LoadSplitterPosition(Splitter1, 'ProjectSplitter');
end;

procedure TProjectFrame.UpdateSettings;
begin
  UpdateShortCuts;
  FrameFromNode(FSelectedNode).UpdateSettings;
end;

function TProjectFrame.FrameFromRelation(Relation: TEpiMasterRelation
  ): TDataFormFrame;
var
  Node: PVirtualNode;
begin
  Node := PVirtualNode(Relation.FindCustomData(PROJECT_RELATION_NODE_KEY));
  result := FrameFromNode(Node);
end;

class procedure TProjectFrame.RestoreDefaultPos(F: TProjectFrame);
begin
  if Assigned(F) and
     Assigned(F.FrameFromNode(F.FSelectedNode))
   then
    TDataFormFrame.RestoreDefaultPos(F.FrameFromNode(F.FSelectedNode))
  else
    TDataFormFrame.RestoreDefaultPos(nil);
end;

end.


