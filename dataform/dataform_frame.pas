unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, types, FileUtil, PrintersDlgs, Forms, Controls,
  epidatafiles, epicustombase, StdCtrls, ExtCtrls, Buttons, ActnList, LCLType,
  ComCtrls, fieldedit, notes_form, LMessages, entry_messages,
  VirtualTrees, epitools_search, entry_globals, epidatafilerelations, epidatafilestypes,
  epirelates, control_types, contnrs;

type

  { TDataFormFrame }
  TFieldExitFlowType = (fxtOk, fxtError, fxtJump, fxtRelate);

  TDataFormFrame = class(TFrame)
    DeleteRecordAction: TAction;
    BrowseAllAction: TAction;
    CopyToClipBoardAction: TAction;
    PrintDataFormWithDataAction: TAction;
    PrintDataFormAction: TAction;
    Label1: TLabel;
    Panel1: TPanel;
    PrintDialog1: TPrintDialog;
    ShowFieldNotesAction: TAction;
    FindFastListAction: TAction;
    FindRecordExAction: TAction;
    FindPrevAction: TAction;
    FindNextAction: TAction;
    FindRecordAction: TAction;
    JumpNextRecAction: TAction;
    JumpPrevRecAction: TAction;
    PageDownAction: TAction;
    PageUpAction: TAction;
    GotoRecordAction: TAction;
    LastFieldAction: TAction;
    FirstFieldAction: TAction;
    NewRecordAction: TAction;
    LastRecAction: TAction;
    NextRecAction: TAction;
    PrevRecAction: TAction;
    FirstRecAction: TAction;
    ActionList1: TActionList;
    DataFormScroolBox: TScrollBox;
    CopyFieldToClipboardAction: TAction;
    procedure BrowseAllActionExecute(Sender: TObject);
    procedure CopyToClipBoardActionExecute(Sender: TObject);
    procedure DataFormScroolBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure DeleteRecordActionExecute(Sender: TObject);
    procedure DeleteRecordActionUpdate(Sender: TObject);
    procedure FindRecordExActionExecute(Sender: TObject);
    procedure FindFastListActionExecute(Sender: TObject);
    procedure FindNextActionExecute(Sender: TObject);
    procedure FindRecordActionExecute(Sender: TObject);
    procedure FindPrevActionExecute(Sender: TObject);
    procedure FirstFieldActionExecute(Sender: TObject);
    procedure FirstRecActionExecute(Sender: TObject);
    procedure GotoRecordActionExecute(Sender: TObject);
    procedure JumpNextRecActionExecute(Sender: TObject);
    procedure JumpPrevRecActionExecute(Sender: TObject);
    procedure LastFieldActionExecute(Sender: TObject);
    procedure LastRecActionExecute(Sender: TObject);
    procedure NewRecordActionExecute(Sender: TObject);
    procedure NewRecordActionUpdate(Sender: TObject);
    procedure NextRecActionExecute(Sender: TObject);
    procedure PageDownActionExecute(Sender: TObject);
    procedure PageUpActionExecute(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure PrevRecActionExecute(Sender: TObject);
    procedure PrintDataFormActionExecute(Sender: TObject);
    procedure PrintDataFormWithDataActionExecute(Sender: TObject);
    procedure ShowFieldNotesActionExecute(Sender: TObject);
    procedure CopyFieldToClipboardActionExecute(Sender: TObject);
    procedure NoViewDataActionUpdate(Sender: TObject);
  private
    FLocalToDFIndex: TEpiField;
    FDFToLocalIndex: TEpiField;
    FDataFile: TEpiDataFile;
    FCustomEditList: TObjectList;
    FRecNo: integer;
    FLoadingDatafile: boolean;
    procedure UpdateIndexFields;
    procedure SetDataFile(const AValue: TEpiDataFile);
    procedure LoadRecord(RecordNo: Integer);
    procedure SetRecNo(AValue: integer);
    procedure UpdateModified;
    procedure SetModified(const AValue: boolean);
    function  DoNewRecord: boolean;
    function  ControlFromEpiControl(EpiControl: TEpiCustomItem): TControl;
    procedure DoPrintDataForm(WithData: boolean);
    procedure DoCopyToClipBoard(Const SingleField: Boolean);
  public
    function  CustomEditFromField(Field: TEpiField): TCustomEdit;
  private
    { Hint }
    FHintWindow: THintWindow;
    function  GetHintWindow: THintWindow;
    procedure ShowHintMsg(Const Msg: string; Const Ctrl: TControl);
  private
    { Search }
    // ALL Searches are performed on the entire datafile!
    // - hence, result index MUST be translated to current filter, using FDFToLocalIndex.
    FRecentSearch: TEpiSearch;
    function  DoIndexedSearchFindList(Const Search: TEpiSearch; CurIndex: integer): TBoundArray;
    function  DoIndexedSearchFindNext(Const Search: TEpiSearch; Index: integer): Integer;
    procedure DoPerformSearch(Search: TEpiSearch; Idx: Integer; Wrap: boolean);
    function  CreateSearchFromFieldEdits: TEpiSearch;
    function  DoSearchForm(Search: TEpiSearch): Word;
    function  PerformKeyFieldsCheck: boolean;
    function  DoSearchKeyFields: integer;
    // Search Messages:
    procedure LMGotoRec(var Msg: TLMessage); message LM_DATAFORM_GOTOREC;
  private
    { Notes }
    FNotesForm: TNotesForm;
    FNotesHint: THintWindow;
    procedure ShowNotes(CE: TCustomEdit; ForceShow: boolean = false);
    procedure UnShowNotes;
    procedure UnShowNotesAndHint;
  private
    { Field Enter/Exit Handling }
    // - Delayed key down handling.
    FCurrentEdit: TCustomEdit;
    FCurrentDataCtrl: IEntryDataControl;
    function  NewOrNextRecord: TCustomEdit;
    function  KeyDownData(Sender: TObject; Const Key: Word; Const Shift: TShiftState): PtrInt;
    procedure ASyncKeyDown(Data: PtrInt);
    procedure DoKeyFieldDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function  NextFieldOnKeyDown(Const CurrentEdit: TCustomEdit): TCustomEdit;
    function  NextUsableFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    function  PrevNonAutoFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldEnter(Sender: TObject);
    procedure FieldExit(Sender: TObject);
  private
    { Flow control/Validation/Script handling}
    FLastDataFileRelate: TEpiRelate;
    procedure FieldEnterFlow(DC: IEntryDataControl);
    function  FieldExitFlow(CE: TCustomEdit; Out NewEdit: TCustomEdit): TFieldExitFlowType;
    function  DoValidateKeyFields: Boolean;
    function  FieldValidate(CE: TCustomEdit; IgnoreMustEnter: boolean = true): boolean;
    procedure FieldValidateError(Sender: TObject; const Msg: string);
    function  ShowValueLabelPickList(ACustomEdit: TCustomEdit): boolean;
    procedure DoAfterRecord(out NewEdit: TCustomEdit);
  private
    FModified: boolean;
    { DataForm Control }
    function  NewSectionControl(EpiControl: TEpiCustomControlItem): TControl;
    function  NewFieldControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TWinControl;
    function  NewHeadingControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
  protected
    procedure SetCursor(Value: TCursor); override;
  private
    FRelation: TEpiMasterRelation;
    function  GetDetailRelation: TEpiDetailRelation;
    function  GetIndexedRecNo: Integer;
    function  GetIndexedSize: Integer;
    procedure SetRelation(AValue: TEpiMasterRelation);
    procedure UpdateShortCuts;
    procedure UpdateNotesHints;
    function  IsDetailRelation: boolean;
  { Statusbar }
  private
    procedure UpdateStatusbarSelection;
    procedure UpdateStatusbarDataform;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure CommitFields;
    procedure UpdateSettings;
    procedure CloseQuery(var CanClose: boolean);
    procedure IsShortCut(var Msg: TLMKey; var Handled: Boolean);
    property  DataFile: TEpiDataFile read FDataFile write SetDataFile;
    property  Relation: TEpiMasterRelation read FRelation write SetRelation;
    property  DetailRelation: TEpiDetailRelation read GetDetailRelation;
    property  RecNo: integer read FRecNo write SetRecNo;
    property  IndexedRecNo: Integer read GetIndexedRecNo;
    property  Modified: boolean read FModified write SetModified;
    property  CustomEditList: TObjectList read FCustomEditList;
    property  IndexedSize: Integer read GetIndexedSize;
  public
    class procedure RestoreDefaultPos(F: TDataFormFrame);

  { Project/Relation stuff }
  private
    FOnModified: TNotifyEvent;
    FOnRecordChanged: TNotifyEvent;
    FTreeNode: PVirtualNode;
    FParentRecordState: TEpiRecordState;
    procedure FillKeyFields;
    procedure DoRecordChanged;
    function  GetMasterDataForm: TDataFormFrame;
    procedure RecordStatusChange(const Sender: TEpiCustomBase;
      const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup;
      EventType: Word; Data: Pointer);
    procedure KeyFieldDataChange(const Sender: TEpiCustomBase;
      const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup;
      EventType: Word; Data: Pointer);
    procedure UpdateActions;
    procedure ChangeParentRecordState(NewState: TEpiRecordState);
  public
    function  CanChange: Boolean;
    function  AllFieldsValidate(IgnoreMustEnter: boolean): boolean;
    function  AllKeyFieldsAreFilled: boolean;
    function  GetCurrentKeyFieldValues: string;
    procedure RelateInit(Reason: TRelateReason; ParentRecordState: TEpiRecordState);
    procedure UpdateChildFocusShift(Const NewChildRelation: TEpiMasterRelation);
    property  TreeNode: PVirtualNode read FTreeNode write FTreeNode;
    property  OnModified: TNotifyEvent read FOnModified write FOnModified;
    property  OnRecordChanged: TNotifyEvent read FOnRecordChanged write FOnRecordChanged;
    property  MasterDataform: TDataFormFrame read GetMasterDataForm;
  end;

const
  NewRecord = MaxInt;

implementation

{$R *.lfm}

uses
  epiv_datamodule, epiv_custom_statusbar,
  LCLProc, settings, fieldmemo,
  main, Menus, Dialogs, math, Graphics, epimiscutils,
  picklist2, epidocument, epivaluelabels, LCLIntf, dataform_field_calculations,
  searchform, resultlist_form, shortcuts,
  Printers, OSPrinters, Clipbrd, setting_types,
  entrylabel, entrysection, project_frame,
  notes_report, epireport_generator_txt, admin_authenticator, epirights,
  strutils, epifields_helper;

const
  Key_PrevFieldFlowKeys = [VK_UP];
  Key_RelateToParentKeys = [VK_F10];
  Key_ShowPickListKeys  = [VK_ADD, VK_F9, VK_OEM_PLUS];
  Key_NextFieldFlowKeys = [VK_RETURN, VK_TAB, VK_DOWN];
  Key_FieldActKeys =
    Key_ShowPickListKeys +
    Key_NextFieldFlowKeys;

type
  TKeyDownData = record
    Sender: TObject;
    Key: Word;
    Shift: TShiftState;
  end;
  PKeyDownData = ^TKeyDownData;

function FieldEditTop(LocalCtrl: TControl): integer;
begin
  if LocalCtrl.Parent is TScrollBox then
    exit(LocalCtrl.Top);

  With LocalCtrl do
    result := Parent.Top + (ControlOrigin.y - Parent.ControlOrigin.y);
end;

function FieldEditLeft(LocalCtrl: TControl): integer;
begin
  if LocalCtrl.Parent is TScrollBox then
    exit(LocalCtrl.Left);

  With LocalCtrl do
    result := Parent.Top + (ControlOrigin.x - Parent.ControlOrigin.x);
end;

{ TDataFormFrame }

procedure TDataFormFrame.FirstRecActionExecute(Sender: TObject);
begin
  RecNo := 0;
end;

procedure TDataFormFrame.FirstFieldActionExecute(Sender: TObject);
var
  I: LongInt;
  DC: IEntryDataControl;
  CE: TCustomEdit;
begin
  I := NextUsableFieldIndex(-1, false);
  if i = -1 then
  begin
    // In the odd case that this is a related dataform with only no-enter fields (eg. keyfields, etc.)
    // then FOCUS is still on the last used field in the previous dataform.
    // And pressing buttons will act on previous dataform - hence we need focus on this
    // dataform.
    DataFormScroolBox.SetFocus;
    Exit;
  end;

//  FE := TFieldEdit(CustomEditList[i]);
  CE := TCustomEdit(CustomEditList[i]);
  DC := (CE as IEntryDataControl);

  FieldEnterFlow(DC);

  // Line below:
  // Fixes bug where opening a single form, doesn't have a handle prior to
  // focusing the first field.
  CE.HandleNeeded;
  CE.SetFocus;
end;

procedure TDataFormFrame.DataFormScroolBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  with DataFormScroolBox.VertScrollBar do
    Position := Position - WheelDelta;
  Handled := true;
end;

procedure TDataFormFrame.DeleteRecordActionExecute(Sender: TObject);
begin
  FDataFile.Deleted[IndexedRecNo] := not FDataFile.Deleted[IndexedRecNo];
  Modified := true;
end;

procedure TDataFormFrame.DeleteRecordActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    (IndexedRecNo <> NewRecord) and
    (FParentRecordState <> rsDeleted) and
    (Authenticator.IsAuthorizedEntry(DataFile, [eerDelete]));
end;

procedure TDataFormFrame.CopyToClipBoardActionExecute(Sender: TObject);
begin
  DoCopyToClipBoard(false);
end;

procedure TDataFormFrame.BrowseAllActionExecute(Sender: TObject);
begin
  ShowResultListForm(
    Self,
    DataFile.Caption.Text,
    DataFile,
    DataFile.Fields,
    nil,
    FDFToLocalIndex,
    FLocalToDFIndex
  );
end;

procedure TDataFormFrame.FindRecordExActionExecute(Sender: TObject);
var
  S: TEpiSearch;
begin
  // Search data using current text in field for lookup. Will always be
  // from first record and forward.
  S := CreateSearchFromFieldEdits;
  DoSearchForm(S);
end;

procedure TDataFormFrame.FindFastListActionExecute(Sender: TObject);
var
  S: TEpiSearch;
  Lst: TBoundArray;
  FieldList: TEpiFields;
  i: Integer;
begin
  S := CreateSearchFromFieldEdits;

  Lst := SearchFindList(S, 0);
  if Length(Lst) = 0 then
  begin
    SetLength(Lst, 1);
    Lst[0] := -1;
  end;

  FieldList := TEpiFields.Create(nil);
  for i := 0 to CustomEditList.Count - 1 do
    FieldList.AddItem((CustomEditList[i] as IEntryDataControl).Field);

  ShowResultListForm(
    Self,
    'Result List:',
    DataFile,
    FieldList,
    Lst);
  if RecNo = NewRecord then
    Modified := false;
end;

procedure TDataFormFrame.FindPrevActionExecute(Sender: TObject);
begin
  if not Assigned(FRecentSearch) then exit;
  FRecentSearch.Direction := sdBackward;
  FRecentSearch.Origin    := soCurrent;
  DoPerformSearch(FRecentSearch, RecNo - 1, true);
end;

procedure TDataFormFrame.GotoRecordActionExecute(Sender: TObject);
begin
  //RecordEdit.SetFocus;
end;

procedure TDataFormFrame.JumpNextRecActionExecute(Sender: TObject);
begin
  RecNo := RecNo + EntrySettings.RecordsToSkip;
end;

procedure TDataFormFrame.JumpPrevRecActionExecute(Sender: TObject);
begin
  RecNo := Min(RecNo - EntrySettings.RecordsToSkip, FLocalToDFIndex.Size - EntrySettings.RecordsToSkip);
end;

procedure TDataFormFrame.LastFieldActionExecute(Sender: TObject);
var
  i: LongInt;
begin
  i := PrevNonAutoFieldIndex(CustomEditList.Count, false);
  if i = -1 then exit;

  TCustomEdit(CustomEditList[i]).SetFocus;
end;

procedure TDataFormFrame.LastRecActionExecute(Sender: TObject);
begin
  RecNo := FLocalToDFIndex.Size - 1;
end;

procedure TDataFormFrame.NewRecordActionExecute(Sender: TObject);
var
  CE: TCustomEdit;
  Idx: LongInt;
begin
  if not DoNewRecord then exit;

  Idx := NextUsableFieldIndex(-1, false);
  if Idx = -1 then exit;

  CE := TCustomEdit(CustomEditList[Idx]);
  FieldEnterFlow((CE as IEntryDataControl));
  CE.SetFocus;
end;

procedure TDataFormFrame.NewRecordActionUpdate(Sender: TObject);
var
  B: Boolean;
begin
  B := (FParentRecordState <> rsDeleted) and
       (Authenticator.IsAuthorizedEntry(DataFile, [eerCreate]));

  if (IsDetailRelation) and
     (DetailRelation.MaxRecordCount > 0)
  then
    B := B and
      (FLocalToDFIndex.Size < DetailRelation.MaxRecordCount);

  TAction(Sender).Enabled := B;
  //NewRecSpeedButton.ShowHint := TAction(Sender).Enabled;
end;

procedure TDataFormFrame.NextRecActionExecute(Sender: TObject);
begin
  RecNo := RecNo + 1;
end;

procedure TDataFormFrame.PageDownActionExecute(Sender: TObject);
begin
  With DataFormScroolBox.VertScrollBar do
    Position := Position + Page;
end;

procedure TDataFormFrame.PageUpActionExecute(Sender: TObject);
begin
  With DataFormScroolBox.VertScrollBar do
    Position := Position - Page;
end;

procedure TDataFormFrame.Panel1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(MainForm.ActiveControl) then
    Label1.Caption := 'Focused control: ' + MainForm.ActiveControl.Name;
end;

procedure TDataFormFrame.PrevRecActionExecute(Sender: TObject);
begin
  RecNo := Min(RecNo - 1, FLocalToDFIndex.Size - 1);
end;

procedure TDataFormFrame.PrintDataFormActionExecute(Sender: TObject);
begin
  DoPrintDataForm(false);
end;

procedure TDataFormFrame.PrintDataFormWithDataActionExecute(Sender: TObject);
begin
  DoPrintDataForm(true);
end;

procedure TDataFormFrame.ShowFieldNotesActionExecute(Sender: TObject);
begin
  if MainForm.ActiveControl is TFieldEdit then
    ShowNotes(TCustomEdit(MainForm.ActiveControl), true);
end;

procedure TDataFormFrame.CopyFieldToClipboardActionExecute(Sender: TObject);
begin
  DoCopyToClipBoard(true);
end;

procedure TDataFormFrame.NoViewDataActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Authenticator.IsAuthorizedEntry(DataFile, [eerRead]);
end;

procedure TDataFormFrame.UpdateIndexFields;
var
  MasterKFs: TEpiFields;
  MasterF: TEpiField;
  KF: TEpiField;
  AddToIndex: Boolean;
  MasterFrame: TDataFormFrame;
  i: Integer;
begin
  FDFToLocalIndex.Size := DataFile.Size;
  FDFToLocalIndex.ResetData;

  if IsDetailRelation then
  begin
    MasterKFs := DetailRelation.MasterRelation.Datafile.KeyFields;
    MasterFrame := GetMasterDataForm;

    FLocalToDFIndex.Size := 0;

    if MasterFrame.IndexedRecNo = NewRecord then exit;

    for i := 0 to DataFile.Size - 1 do
    begin
      AddToIndex := true;

      for MasterF in MasterKFs do
      begin
        KF := DataFile.KeyFields.FieldByName[MasterF.Name];

        AddToIndex := AddToIndex and
          (MasterF.AsValue[MasterFrame.IndexedRecNo] = KF.AsValue[i]);
        if (not AddToIndex) then
          break;
      end;

      if AddToIndex then
      begin
        FLocalToDFIndex.Size := FLocalToDFIndex.Size + 1;
        FLocalToDFIndex.AsInteger[FLocalToDFIndex.Size - 1] := i;

        FDFToLocalIndex.AsInteger[i] := (FLocalToDFIndex.Size - 1);
      end;
    end;
  end else begin
    FLocalToDFIndex.Size := DataFile.Size;

    for i := 0 to FLocalToDFIndex.Size - 1 do
    begin
      FLocalToDFIndex.AsInteger[i] := i;
      FDFToLocalIndex.AsInteger[i] := i;
    end;
  end;
end;

procedure TDataFormFrame.FindNextActionExecute(Sender: TObject);
var
  idx: LongInt;
begin
  if not Assigned(FRecentSearch) then exit;
  FRecentSearch.Direction := sdForward;
  FRecentSearch.Origin    := soCurrent;
  DoPerformSearch(FRecentSearch, RecNo + 1, true);
end;

procedure TDataFormFrame.FindRecordActionExecute(Sender: TObject);
var
  Search: TEpiSearch;
  SC: TEpiSearchCondition;
begin
  Search := TEpiSearch.Create;
  Search.DataFile := DataFile;
  Search.Direction := sdForward;
  Search.Origin := soBeginning;

  SC := TEpiSearchCondition.Create;
  SC.BinOp := boAnd;
  SC.Field := FCurrentDataCtrl.Field;
  SC.Text  := FCurrentEdit.Text;
  SC.CaseSensitive := false;
  if SC.Text = TEpiStringField.DefaultMissing then
    SC.MatchCriteria := mcIsSysMissing
  else
    if FCurrentDataCtrl.Field.FieldType in StringFieldTypes then
      SC.MatchCriteria := mcContains
    else
      SC.MatchCriteria := mcEq;
  Search.List.Add(SC);

  DoSearchForm(Search);
end;

function FieldSort(Item1, Item2: Pointer): Integer;
var
  F1: TCustomEdit absolute Item1;
  F2: TCustomEdit absolute Item2;
  D1, D2: IEntryDataControl;
  MainSection: TEpiSection;
begin
  // Simple comparison
  if F1.Parent = F2.Parent then
  begin
    result := F1.Top - F2.Top;
    if result = 0 then
      result := F1.Left - F2.Left;
    exit;
  end;

  D1 := (F1 as IEntryDataControl);
  D2 := (F2 as IEntryDataControl);

  MainSection := D1.Field.DataFile.MainSection;

  // Cross section comparison.
  if (D1.Field.Section <> MainSection) and (D2.Field.Section <> MainSection) then
  begin
    result := F1.Parent.Top - F2.Parent.Top;
    if result = 0 then
      Result := F1.Parent.Left - F2.Parent.Left;
    Exit;
  end;

  // Main <-> Section comparison
  if (D1.Field.Section = MainSection) then
  begin
    result := F1.Top - F2.Parent.Top;
    if Result = 0 then
      result := F1.Left - F2.Parent.Left;
    exit;
  end;

  // Section <-> Main comparison
  if (D2.Field.Section = MainSection) then
  begin
    result := F1.Parent.Top - F2.Top;
    if Result = 0 then
      result := F1.Parent.Left - F2.Left;
  end;
end;

procedure TDataFormFrame.SetDataFile(const AValue: TEpiDataFile);
var
  i: Integer;
  TheParent: TWinControl;
  j: Integer;
begin
  if FDataFile = AValue then exit;
  FDataFile := AValue;
  FLoadingDatafile := true;

  // Create components.
  Name := DataFile.Name;

  // Register the visual feedback hook.
  DataFile.BeginUpdate;
  with DataFile do
  begin
    if not ((Fields.Count = 0) and (Headings.Count = 0)) then
    begin
      for i := 0 to Sections.Count - 1 do
      begin
        if Section[i] <> MainSection then
          TheParent := TWinControl(NewSectionControl(Section[i]))
        else
          TheParent := DataFormScroolBox;

        with Section[i] do
        begin
          for j := 0 to Fields.Count - 1 do
            NewFieldControl(Field[j], TheParent);
          for j := 0 to Headings.Count - 1 do
            NewHeadingControl(Heading[j], TheParent);
        end;
      end;
    end;
  end;
  DataFile.EndUpdate;

  UpdateIndexFields;

  // Correct tab order of fields.
  FCustomEditList.Sort(@FieldSort);
  for i := 0 to FCustomEditList.Count - 1 do
    TCustomEdit(FCustomEditList[i]).TabOrder := i;

  FLoadingDatafile := false;
end;

procedure TDataFormFrame.LoadRecord(RecordNo: Integer);
var
  i: Integer;
begin
  if RecordNo >= FLocalToDFIndex.Size then
    RecordNo := NewRecord;

  if RecordNo <> NewRecord then
  begin
    RecordNo :=  FLocalToDFIndex.AsInteger[RecordNo];
    // In order to log correctly
    DataFile.LoadRecord(RecordNo);

    if Assigned(Authenticator.AuthedUser) then
      TProjectFrame(Parent).SaveProjectAction.Execute;
  end;

  MainForm.BeginUpdateForm;
  for i := 0 to FCustomEditList.Count - 1 do
    (FCustomEditList[i] as IEntryDataControl).RecNo := RecordNo;
  MainForm.EndUpdateForm;
end;

function TDataFormFrame.NewSectionControl(EpiControl: TEpiCustomControlItem
  ): TControl;
begin
  result := TEntrySection.Create(DataFormScroolBox);
  EpiControl.AddCustomData(DataFormCustomDataKey, Result);
  TEntrySection(Result).Section := TEpiSection(EpiControl);
  Result.Parent := DataFormScroolBox;
end;

function TDataFormFrame.NewFieldControl(EpiControl: TEpiCustomControlItem;
  AParent: TWinControl): TWinControl;
var
  Field: TEpiField absolute EpiControl;
  DC: IEntryDataControl;
begin
  case Field.FieldType of
    ftBoolean:  Result := TBoolEdit.Create(AParent);
    ftInteger,
    ftAutoInc:  Result := TIntegerEdit.Create(AParent);

    ftFloat:    Result := TFloatEdit.Create(AParent);

    ftUpperString,
    ftString:   Result := TStringEdit.Create(AParent);

    ftMemo:     Result := TFieldMemo.Create(Parent);

    ftDMYDate,
    ftDMYAuto,
    ftMDYDate,
    ftMDYAuto,
    ftYMDDate,
    ftYMDAuto: Result := TDateEdit.Create(AParent);

    ftTimeAuto,
    ftTime:     Result := TTimeEdit.Create(AParent);
  end;
  DC := (Result as IEntryDataControl);

  //  This check is normal No-Entry mode
  if (Field.EntryMode = emNoEnter) or
     // This check is for Parent-Child related key fields.
     (IsDetailRelation and
      (DataFile.KeyFields.IndexOf(Field) >= 0) and
      (Assigned(GetMasterDataForm.DataFile.KeyFields.FieldByName[Field.Name]))
     ) or
     (not Authenticator.IsAuthorizedEntry(DataFile, [eerUpdate]))
  then
    Result.Enabled := false;

  EpiControl.AddCustomData(DataFormCustomDataKey, result);
  Result.Parent := AParent;

//  with TFieldEdit(Result) do
  with Result do
  begin
    OnKeyDown := @FieldKeyDown;
    OnKeyUp   := @FieldKeyUp;
    OnEnter   := @FieldEnter;
    OnExit    := @FieldExit;
  end;

  DC.Field := TEpiField(EpiControl);
  DC.OnValidateError := @FieldValidateError;

  FCustomEditList.Add(Result);
end;

function TDataFormFrame.NewHeadingControl(EpiControl: TEpiCustomControlItem;
  AParent: TWinControl): TControl;
begin
  Result := TEntryLabel.Create(AParent);
  EpiControl.AddCustomData(DataFormCustomDataKey, Result);
  TEntryLabel(Result).Heading := TEpiHeading(EpiControl);
  Result.Parent := AParent;
end;

procedure TDataFormFrame.SetCursor(Value: TCursor);
begin
  DataFormScroolBox.Cursor := Value;
end;

procedure TDataFormFrame.UpdateShortCuts;
begin
  // Dataform
  BrowseAllAction.ShortCut := D_BrowseData;
  ShowFieldNotesAction.ShortCut := D_FieldNotes;
  FirstRecAction.ShortCut := D_MoveFirstRec;
  JumpPrevRecAction.ShortCut := D_MoveSkipPrevRec;
  PrevRecAction.ShortCut := D_MovePrevRec;
  NextRecAction.ShortCut := D_MoveNextRev;
  JumpNextRecAction.ShortCut := D_MoveSkipNextRec;
  LastRecAction.ShortCut := D_MoveLastRec;
  NewRecordAction.ShortCut := D_NewRec;
  PageUpAction.ShortCut := D_SideUp;
  PageDownAction.ShortCut := D_SideDown;
  FindRecordAction.ShortCut := D_SearchRecordEmpty;
  FindRecordExAction.ShortCut := D_SearchRecordFilled;
  FindNextAction.ShortCut := D_SearchRepeatForward;
  FindPrevAction.ShortCut := D_SearchRepeatBackward;
  FindFastListAction.ShortCut := D_SearchRecordList;
  CopyToClipBoardAction.ShortCut := D_CopyRecordToClipBoard;
  CopyFieldToClipboardAction.ShortCut := D_CopyFieldToClipBoard;
  PrintDataFormAction.ShortCut   := D_PrintForm;
  PrintDataFormWithDataAction.ShortCut := D_PrintFormWithData;
end;

function TDataFormFrame.GetDetailRelation: TEpiDetailRelation;
begin
  result := nil;
  if IsDetailRelation then
    result := TEpiDetailRelation(Relation);
end;

function TDataFormFrame.GetIndexedRecNo: Integer;
begin
  if (RecNo >= 0) and
     (RecNo < FLocalToDFIndex.Size) and
     (FLocalToDFIndex.Size >= 0)
  then
    Result := FLocalToDFIndex.AsInteger[RecNo]
  else
    Result := NewRecord;
end;

function TDataFormFrame.GetIndexedSize: Integer;
begin
  result := FLocalToDFIndex.Size;
end;

procedure TDataFormFrame.SetRelation(AValue: TEpiMasterRelation);
var
  MasterDF: TEpiDataFile;
  MasterKFs: TEpiFields;
  MF: TEpiField;
begin
  if FRelation = AValue then Exit;
  FRelation := AValue;

  if not IsDetailRelation then exit;

  // Create a hook for ALL keyfields in Master Datafile, such than when data
  // is changed, all subsequent data is also changed.
  MasterDF := DetailRelation.MasterRelation.Datafile;
  MasterDF.RegisterOnChangeHook(@RecordStatusChange, true);

  MasterKFs := MasterDF.KeyFields;

  for MF in MasterKFs do
    MF.RegisterOnChangeHook(@KeyFieldDataChange, true);
end;

procedure TDataFormFrame.UpdateNotesHints;
begin
  if not Assigned(FNotesHint) then exit;

  if EntrySettings.NotesUseSystem then
  begin
    FNotesHint.Font.SetDefault;
    FNotesHint.Color := clInfoBk;
  end else begin
    FNotesHint.Font.Assign(EntrySettings.HeadingFont5);
    FNotesHint.Color := EntrySettings.NotesHintBgColor;
  end;
end;

function TDataFormFrame.IsDetailRelation: boolean;
begin
  result := Relation.InheritsFrom(TEpiDetailRelation);
end;

procedure TDataFormFrame.UpdateStatusbarSelection;
var
  FList: TEpiFields;
begin
  if (not Assigned(Parent)) then Exit;
  if (not Assigned(FCurrentEdit)) then Exit;

  FList := TEpiFields.Create(nil);
  FList.AddItem(FCurrentDataCtrl.Field);
  TProjectFrame(Parent).StatusBar.Selection := FList;
  FList.Free;
end;

procedure TDataFormFrame.UpdateStatusbarDataform;
begin
  if Assigned(Parent) then
    TProjectFrame(Parent).StatusBar.DataForm := Self;
end;

procedure TDataFormFrame.SetRecNo(AValue: integer);
var
  Res: LongInt;
begin
  if not (AValue = NewRecord) then
  begin
    if AValue = FRecNo then exit;
    if AValue >= FLocalToDFIndex.Size then AValue := FLocalToDFIndex.Size - 1;
    if AValue < 0 then AValue := 0;
  end;

  if (not (AValue = NewRecord)) and Modified then
  begin
    Res := MessageDlg('Warning',
      'Current record is modified.' + LineEnding +
      'Save record?',
      mtWarning, mbYesNoCancel, 0, mbCancel);
    case Res of
      mrCancel:
        Exit;

      mrYes:
        begin
          // if a new record is being edited the datafile has NOT been
          // expanded at this point.
          if not AllFieldsValidate(false) then exit;
          CommitFields;
        end;

      mrNo:
        Modified := false; // do nothing.
    end;
  end;

  FRecNo := AValue;
  LoadRecord(RecNo);
  DoRecordChanged;
end;

procedure TDataFormFrame.UpdateModified;
begin
  if Assigned(OnModified) then
    OnModified(Self);
end;

procedure TDataFormFrame.SetModified(const AValue: boolean);
begin
  if FModified = AValue then exit;
  FModified := AValue;
  UpdateModified;
end;

function TDataFormFrame.GetHintWindow: THintWindow;
begin
  if not Assigned(FHintWindow) then
  begin
    FHintWindow := THintWindow.Create(self);
    FHintWindow.AutoHide := true;
    FHintWindow.HideInterval := EntrySettings.HintTimeOut * 1000; //TTimer.interval is in millisecs.
  end;
  result := FHintWindow;
end;

procedure TDataFormFrame.ShowHintMsg(const Msg: string; const Ctrl: TControl);
var
  H: THintWindow;
  R: TRect;
  P: TPoint;
begin
  H := GetHintWindow;
  if (Msg = '') or (Ctrl = nil) then
  begin
    H.Hide;
    Exit;
  end;

  R := H.CalcHintRect(0, Msg, nil);
  P := Ctrl.ClientToScreen(Point(0,0));
  OffsetRect(R, P.X, P.Y + Ctrl.Height);
  H.ActivateHint(R, Msg);
end;

function TDataFormFrame.DoIndexedSearchFindList(const Search: TEpiSearch;
  CurIndex: integer): TBoundArray;
var
  i: Integer;
begin
  // Results from SearchFindList is indexed using the entire Datafile!
  // And incomming CurIndex is in filtered record number, but outgoing
  // CurIndex to SearchFindList MUST be in Datafile record number
  CurIndex := FLocalToDFIndex.AsInteger[CurIndex];
  Result := SearchFindList(Search, CurIndex);

  for i := Low(Result) to High(Result) do
    if Result[i] >= 0 then
      Result[i] := FDFToLocalIndex.AsInteger[Result[i]];
end;

function TDataFormFrame.DoIndexedSearchFindNext(const Search: TEpiSearch;
  Index: integer): Integer;
begin
  // Result from SearchFindNext is indexed using the entire Datafile!
  // And incomming index is in filtered record number, but outgoing
  // index to SearchFindNext MUST be in Datafile record number

  // This should only be the case when FLocalToDFIndex.Size = 0
  if Index >= FLocalToDFIndex.Size then
    Exit(-1);

  if Index < 0 then
    Exit(-1);

//  if Index < FLocalToDFIndex.Size then
    Index := FLocalToDFIndex.AsInteger[Index];

  Result := SearchFindNext(Search, Index);

  // Result = -1 is no result is found
  if Result >= 0 then
    Result := FDFToLocalIndex.AsInteger[Result];
end;

function TDataFormFrame.DoNewRecord: boolean;
var
  i: Integer;
  Res: LongInt;
  AVal: Int64;
  CE: TCustomEdit;
  DC: IEntryDataControl;
  Field: TEpiField;
begin
  if (Modified) and
     (not AllFieldsValidate(false))
  then
    Exit(false);

  // *******************
  // * Commit old data *
  // *******************
  if Modified then
  begin
    // Sanity check
    // - go through all fields for a validity check.
    if (not AllFieldsValidate(false))
    then
      Exit;

    if (RecNo <> NewRecord) then
    begin
      Res := MessageDlg('Warning',
               'Current record modified.' + LineEnding +
               'Save record?', mtConfirmation, mbYesNoCancel, 0, mbCancel);
      case Res of
        mrCancel: Exit;
        mrYes:    CommitFields;
        mrNo:     ; // Do nothing
      end;
    end;

    if (RecNo = NewRecord) then
    begin
      Res := MessageDlg('Confirmation',
               'Save Record?',
               mtConfirmation, mbYesNoCancel, 0, mbYes);
      case Res of
        mrCancel: Exit;
        mrYes:    CommitFields;
        mrNo:     ; // Do nothing
      end;
    end;
  end;

  // **********************************
  // * Prepare system for new record  *
  // **********************************
  RecNo := NewRecord;
  for i := 0 to CustomEditList.Count - 1 do
  begin
    CE := TCustomEdit(CustomEditList[i]);
    Field := (CE as IEntryDataControl).Field;

    // Check for AutoInc/Today fields.
    if (Field.FieldType in AutoFieldTypes) then
    with Field do
    begin
      case FieldType of
        ftAutoInc:  begin
                      AVal := TEpiDocument(DataFile.RootOwner).ProjectSettings.AutoIncStartValue;
                      if DataFile.Size = 0 then
                        Text := IntToStr(AVal)
                      else
                        Text := IntToStr(Max(AsInteger[DataFile.Size - 1] + 1, AVal));
                    end;
        ftDMYAuto:  if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('DD/MM/YYYY', Date);
        ftMDYAuto:  if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('MM/DD/YYYY', Date);
        ftYMDAuto:  if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('YYYY/MM/DD', Date);
        ftTimeAuto: if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('HH:NN:SS',   Now);
      end;
    end;

    // Default Value
    if (Field.HasDefaultValue) then
      CE.Text := Field.DefaultValueAsString;

    // Repeat
    if (Field.RepeatValue) and
       (FLocalToDFIndex.Size > 0) and
       (not Field.IsMissing[FLocalToDFIndex.AsInteger[FLocalToDFIndex.Size - 1]])
    then
      CE.Text := Field.AsString[FLocalToDFIndex.AsInteger[FLocalToDFIndex.Size - 1]];
  end;

  // Finally fill all key fields with inherited data
  FillKeyFields;

  // Reset last related datafil, otherwise subsequest relates may end up in the wrong place
  FLastDataFileRelate := nil;

  TProjectFrame(Parent).StatusBar.Update();
  Result := true;
end;

function TDataFormFrame.ControlFromEpiControl(EpiControl: TEpiCustomItem
  ): TControl;
begin
  result := TControl(EpiControl.FindCustomData(DataFormCustomDataKey));
end;

function TDataFormFrame.CustomEditFromField(Field: TEpiField): TCustomEdit;
begin
  result := TCustomEdit(ControlFromEpiControl(Field));
end;

procedure TDataFormFrame.DoPrintDataForm(WithData: boolean);
var
  ppix: Integer;
  ppiy: Integer;
  ppmmx: Int64;
  ppmmy: Int64;
  LeftMarg: Integer;
  TopMarg: Integer;
  BotMarg: Integer;
  pClientHeight: Integer;
  xscale: Extended;
  yscale: Extended;
  CI: TEpiCustomControlItem;
  ALeft: Integer;
  ARight: Integer;
  ATop: Integer;
  ABot: Integer;
  i: Integer;
  S: String;
  Sz: TSize;
  CE: TCustomEdit;

  function RecursiveFindControl(Const EpiCtrl: TEpiCustomControlItem;
    Const WinControl: TWinControl): TControl;
  var
    i: Integer;
  begin
    if EpiCtrl is TEpiField then
      Exit(CustomEditFromField(TEpiField(EpiCtrl)));

    for i := 0 to WinControl.ControlCount - 1 do
    with WinControl do
      begin
        if (EpiCtrl is TEpiHeading) and
           (Controls[i] is TEntryLabel) and
           (TEntryLabel(Controls[i]).Caption = TEpiHeading(EpiCtrl).Caption.Text)
        then
          Exit(Controls[i]);

        if (Controls[i].InheritsFrom(TWinControl)) then
          Result := RecursiveFindControl(EpiCtrl, TWinControl(Controls[i]));

        if Assigned(Result) then
          Exit;
      end;

    Result := nil;
  end;


  procedure SetFont(Const AFont: TFont);
  begin
    printer.canvas.Font.PixelsPerInch  := ppix;
    Printer.Canvas.Font.Name           := AFont.Name;
    Printer.Canvas.Font.Size           := AFont.Size;
    Printer.Canvas.Font.Style          := AFont.Style;
    Printer.Canvas.Font.Color          := AFont.Color;
    printer.canvas.Font.PixelsPerInch  := ppix;
  end;

  function ControlItemTop(Const Item: TEpiCustomControlItem): Integer;
  begin
    if Item is TEpiSection then
      Result := Item.Top
    else
      Result := DataFormScroolBox.ScreenToClient(RecursiveFindControl(CI, DataFormScroolBox).ClientToScreen(Point(0,0))).Y;
  end;

  function ControlItemLeft(Const Item: TEpiCustomControlItem): Integer;
  begin
    if Item is TEpiSection then
      Result := Item.Left
    else
      Result := Item.Left + TEpiSection(Item.Owner.Owner).Left;
  end;

begin
  IF NOT PrintDialog1.Execute THEN Exit;

  WITH Printer DO
  BEGIN
//    FileName := '/tmp/tmp.ps';
    Title    := 'EpiData Manager - ' + TEpiDocument(DataFile.RootOwner).Study.Title.Text;
    ppix     := XDPI;                    //pixels pr inch X
    ppiy     := YDPI;                    //pixels pr inch Y
    ppmmx    := Round(ppix/25.4);        //pixels pr mm X
    ppmmy    := Round(ppiy/25.4);        //pixels pr mm Y
    LeftMarg := 0;                       //Sets left margin to 0 cm
    TopMarg  := 0;                       //Sets top margin to 0 cm
    BotMarg  := PageHeight;              //Sets bottom margin to 0 cm
    pClientHeight := BotMarg - TopMarg;

    xscale := ppix / GetParentForm(Self).PixelsPerInch;
    yscale := ppiy / GetParentForm(Self).PixelsPerInch;

    BeginDoc;

    i := 0;
    while i < DataFile.ControlItems.Count - 1 do
    begin
      CI := DataFile.ControlItem[i];
      if CI = DataFile.MainSection then
      begin
        inc(i);
        continue;
      end;

      ATop := (Round(ControlItemTop(CI) * yscale) - (PageNumber - 1) * pClientHeight) + TopMarg;
      ALeft := Round(ControlItemLeft(CI) * xscale) + LeftMarg;

      if (CI is TEpiSection) then
      begin
        SetFont(EntrySettings.SectionFont);
        ABot := ATop + Round(TEpiSection(CI).Height * yscale);
      end;
      if (CI is TEpiHeading) then
      begin
        SetFont(ControlFromEpiControl(CI).Font);
        ABot := ATop + Canvas.TextHeight(TEpiHeading(CI).Caption.Text);
      end;
      if (CI is TEpiField) then
      begin
        SetFont(EntrySettings.FieldFont);
        ABot := ATop + Round(CustomEditFromField(TEpiField(CI)).Height * yscale);  // Canvas.TextHeight(TEpiField(CI).Name);
      end;

      // Check if we need to create a new page
      if ATop > BotMarg then
      begin
        NewPage;
        Continue;
      end;

      if CI is TEpiSection then
      with TEpiSection(CI) do
      begin
        SetFont(EntrySettings.SectionFont);
        ARight := ALeft + Round(Width * xscale);

        Sz := Size(0,0);
        if Caption.Text <> '' then
        begin
          Sz := Canvas.TextExtent(Caption.Text);
          Canvas.TextOut(ALeft + Round(10 * xscale), ATop, Caption.Text);
        end;

        ATop := ATop + Round(Sz.cy * (2 / 3));

        // Draw box
        Canvas.MoveTo(ALeft + Round(5 * xscale), ATop);
        Canvas.LineTo(ALeft, ATop);
        Canvas.LineTo(ALeft, ABot);
        Canvas.LineTo(ARight, ABot);
        Canvas.LineTo(ARight, ATop);
        // .. line to caption text
        Canvas.LineTo(ALeft + Sz.cx + Round(15 * xscale), Atop);
      end;

      if CI is TEpiHeading then
      begin
        Canvas.TextOut(aLeft, ATop, TEpiHeading(CI).Caption.Text);
      end;

      if CI is TEpiField then
      with TEpiField(CI) do
      begin
        CE := CustomEditFromField(TEpiField(CI));

        // Draw box
        ARight := ALeft + Round(CE.Width * xscale);
        ATop := ABot - ((ABot - ATop) div 2);

        Canvas.MoveTo(ALeft, ATop);
        Canvas.LineTo(ALeft, ABot);
        Canvas.LineTo(ARight, ABot);
        Canvas.LineTo(ARight, ATop);

        // DATA!
        if WithData and
           (Trim(CE.Text) <> '')
        then
        begin
          Canvas.TextOut(
            ALeft + Round(2 * xscale),
            ABot - Canvas.TextHeight(CE.Text) - Round(2 * yscale),
            CE.Text
            );
        end;

        IF Trim(Question.Text)<>'' THEN
        BEGIN
          aLeft := ALeft - Round(5 * xscale) - Canvas.TextWidth(Question.Text);
          ATop := ABot - Canvas.TextHeight(Question.Text);
          Canvas.TextOut(aLeft, ATop, Question.Text);
        END;

        IF TEpiDocument(DataFile.RootOwner).ProjectSettings.ShowFieldNames then
        begin
          ALeft := ALeft - Round(5 * xscale) - Canvas.TextWidth(Name);
          ATop := ABot - Canvas.TextHeight(Question.Text);
          Canvas.TextOut(aLeft, ATop, Name);
        end;

        // VALUELABEL
        if WithData and
           (Assigned(ValueLabelSet)) and
           (CE.Text <> '')
        then
        begin
          Canvas.Font.Color := EntrySettings.ValueLabelColour;
          S := ValueLabelSet.ValueLabelString[CE.Text];
          ALeft := ARight + Round(5 * xscale);
          ATop := ABot - Canvas.TextHeight(S);
          Canvas.TextOut(ALeft, ATop, S);
        end;
      end;

      Inc(i);
    end;

    EndDoc;
  END;  //with printer
end;


{$I dataform_getfunctions.inc}

procedure TDataFormFrame.DoCopyToClipBoard(const SingleField: Boolean);
var
  i: integer;
  Functions: TGetFunctions;
  S: String;
  l: Integer;
  Globals: TGetGlobalFuncSet;
  F: TEpiField;
  S1: String;

  function FunctionsCall(Const CE: TCustomEdit): String;
  var
    j: Integer;
  begin
    Result := '';

    for j := 0 to l - 1 do
      with Functions[j] do
        case FuncType of
          gftIndexedString:
            Result += TGetIdxStrFunction(FuncPtr)(EntrySettings.CopyToClipBoardFormat, PGetIdxStrRec(FuncData)^.SIdx, PGetIdxStrRec(FuncData)^.EIdx);
          gftCustomEdit:
            Result += TGetFEFunction(FuncPtr)(CE);
        end;
  end;

begin
  Functions := DecodeFormat(EntrySettings.CopyToClipBoardFormat, Globals);
  l := Length(Functions);

  S := '';
  if ggfCurrentDate in Globals
  then
    S += DateTimeToStr(Now) + LineEnding;

  if ggfFileName in Globals
  then
    S += 'File: ' + MainForm.ActiveFrame.DocumentFile.FileName;

  if ggfCycleNo in Globals
  then
    S += Format(' (cycle %d)', [MainForm.ActiveFrame.EpiDocument.CycleNo]) + LineEnding
  else
    if (ggfFileName in Globals) then S += LineEnding;

  if ggfProjectName  in Globals
  then
    S += 'Title: ' + MainForm.ActiveFrame.EpiDocument.Study.Title.Text + LineEnding;

  if (ggfDataFormName in Globals) and
     (FDataFile.Caption.Text <> '')
  then
    S += 'Dataform: ' + FDataFile.Caption.Text + LineEnding;

  if (SingleField) and
     (ggfKeyFields in Globals) and
     (DataFile.KeyFields.Count > 0)
  then
    begin
      S += 'KEY: ';
      for F in DataFile.KeyFields do
        S += F.Name + '=' + CustomEditFromField(F).Text + ' ';

      TrimRight(S);
      S += LineEnding;
    end;

  if SingleField then
    S += FunctionsCall(FCurrentEdit)
  else
    for i := 0 to DataFile.Fields.Count -1 do
      begin
        S += FunctionsCall(CustomEditFromField(DataFile.Field[i]));
      end;

  S := TrimRight(S);
  Clipboard.AsText := S;
end;

procedure TDataFormFrame.DoPerformSearch(Search: TEpiSearch; Idx: Integer;
  Wrap: boolean);
begin
  if not Assigned(Search) then exit;

  case Search.Origin of
    soBeginning: Idx := 0;
    soEnd:       Idx := FLocalToDFIndex.Size - 1;
  end;

  Idx := DoIndexedSearchFindNext(Search, Idx);
  if idx <> -1 then
    RecNo := idx
  else if wrap then begin
    case Search.Direction of
      sdForward:  Idx := 0;
      sdBackward: Idx := FLocalToDFIndex.Size - 1;
    end;
    Idx := DoIndexedSearchFindNext(Search, Idx);
    if idx <> -1 then
    begin
      RecNo := idx;
      ShowHintMsg('Wrapped search. Reached end of datafile', FCurrentEdit);
    end;
  end else begin
    ShowHintMsg('No records found', FCurrentEdit);
  end;
end;

function TDataFormFrame.CreateSearchFromFieldEdits: TEpiSearch;
var
  SC: TEpiSearchCondition;
  i: Integer;
  CE: TCustomEdit;
  Field: TEpiField;
begin
  // Search is saved in FRecentSearch!
  Result := TEpiSearch.Create;
  Result.DataFile := DataFile;
  Result.Direction := sdForward;
  Result.Origin := soBeginning;

  for i := 0 to CustomEditList.Count - 1 do
  begin
    CE := TCustomEdit(CustomEditList[i]);
    Field := (CE as IEntryDataControl).Field;

    if (Field.FieldType in AutoFieldTypes) or
       (Field.RepeatValue) or
       (Field.HasDefaultValue) or
       (CE.Text = '')
       then continue;

    SC := TEpiSearchCondition.Create;
    SC.BinOp := boAnd;
    SC.Field := Field;
    SC.Text  := CE.Text;
    SC.CaseSensitive := false;
    if (SC.Text = TEpiStringField.DefaultMissing) then
      SC.MatchCriteria := mcIsSysMissing
    else
      if Field.FieldType in StringFieldTypes then
        SC.MatchCriteria := mcContains
      else
        SC.MatchCriteria := mcEq;
    Result.List.Add(SC);
  end;
  FRecentSearch := Result;
end;

function TDataFormFrame.DoSearchForm(Search: TEpiSearch): Word;
var
  SF: TSearchForm1;
  Res: LongInt;
  idx: LongInt;
  List: TBoundArray;
  i: Integer;
  FieldList: TEpiFields;
begin
  try
    SF := TSearchForm1.Create(Self, DataFile);
    SF.Search := Search;
    Res := SF.ShowModal;
    if Res = mrCancel then exit;

    TProjectFrame(Parent).EpiDocument.Logger.LogSearch(SF.Search);

    if Res = mrFind then
    begin
      // Find single record.
      FRecentSearch := SF.Search;
      DoPerformSearch(SF.Search, Min(RecNo, DataFile.Size), false);
    end;

    if res = mrList then
    begin
      FieldList := TEpiFields.Create(nil);
      for i := 0 to CustomEditList.Count - 1 do
        FieldList.AddItem((CustomEditList[i] as IEntryDataControl).Field);

      FRecentSearch := nil;
      List := SearchFindList(SF.Search, Min(RecNo, FDataFile.Size));
//      List := DoIndexedSearchFindList(SF.Search, Min(RecNo, FDataFile.Size));
      if Length(List) = 0 then exit;

      ShowResultListForm(
          Self,
          'Showing results for: ' + SF.SearchLabel.Caption,
          DataFile,
          FieldList,
          List,
          FDFToLocalIndex,
          FLocalToDFIndex
          );
    end;
  finally
    SF.Free;
  end;
end;

function TDataFormFrame.PerformKeyFieldsCheck: boolean;
var
  Idx: Integer;
begin
  Idx := DoSearchKeyFields;
  if Idx = RecNo then
    Idx := -1;


  if (Idx <> -1) then
  begin
    if MessageDlg(
        'Index Conflict',
        'Index key already found' + LineEnding +
          'Goto record: ' + IntToStr(Idx + 1),
        mtWarning,
        mbYesNo,
        0,
        mbYes
       ) = mrYes then
    begin
      // Trick to make system believe nothing has happened.
      Modified := false;
      RecNo := Idx;
      Idx := -1;
    end;
  end;

  result := Idx = -1;
end;

function TDataFormFrame.DoSearchKeyFields: integer;
var
  S: TEpiSearch;
  i: Integer;
  C: TEpiSearchCondition;
  Txt: TCaption;
  F: TEpiField;
begin
  Result := -1;

  S := TEpiSearch.Create;
  S.DataFile := DataFile;
  S.Direction := sdForward;
  S.Origin := soBeginning;
  for F in DataFile.KeyFields do
  begin
    Txt := CustomEditFromField(F).Text;
    if Txt <> '' then
    begin
      C := TEpiSearchCondition.Create;
      C.BinOp := boAnd;
      C.MatchCriteria := mcEq;
      C.Text := Txt;
      C.Field := F;
      S.List.Add(C);
    end;
  end;
  if (S.ConditionCount = DataFile.KeyFields.Count) then
    Result := DoIndexedSearchFindNext(S, 0);

  S.Free;
end;

procedure TDataFormFrame.LMGotoRec(var Msg: TLMessage);
var
  F: TEpiField;
  CE: TCustomEdit;
begin
  // WParam = RecordNo
  // LParam = Field (or nil)
  RecNo := Msg.WParam;
  FirstFieldAction.Execute;

  F := TEpiField(Msg.LParam);
  if Assigned(F) then
  begin
    CE := CustomEditFromField(F);
    if CE.CanFocus then
      CE.SetFocus;
  end;
  ResultListFormClose;
end;

procedure TDataFormFrame.ShowNotes(CE: TCustomEdit; ForceShow: boolean);
var
  R: TRect;
  P: TPoint;
  NoteText: String;
  Rep: TNotesReport;
  Lines: TStringList;
  I: Integer;
  DC: IEntryDataControl;
begin
  if (not Supports(CE, IEntryDataControl, DC)) then
    Exit;

  NoteText := DC.Field.Notes.Text;
  if (NoteText = '') and
     Assigned(DC.Field.ValueLabelSet) and
     (not DC.Field.ForcePickList) and
     (EntrySettings.ValueLabelsAsNotes)
  then
  begin
    Lines := TStringList.Create;
    Lines.StrictDelimiter := true;
    Lines.Delimiter := #1;

    Rep := TNotesReport.Create(TEpiReportTXTGenerator);
    Rep.Field := DC.Field;
    Rep.RunReport;
    Lines.DelimitedText := StringReplace(Trim(Rep.ReportText), LineEnding, #1, [rfReplaceAll]);
    Rep.Free;

    if Lines.Count > 0 then
    begin
      if Lines[0][1] = '-' then
        Lines.Delete(0);
      if Lines[Lines.Count - 1][1] = '-' then
        Lines.Delete(Lines.Count - 1);
      NoteText := Trim(StringReplace(Lines.DelimitedText, #1, LineEnding, [rfReplaceAll]));
    end;
    Lines.Free;
  end;

  if EntrySettings.NotesDisplay = 0 then
  // Display as hint:
  begin
    if NoteText = '' then
    begin
      if Assigned(FNotesHint) then FNotesHint.Hide;
      exit;
    end;

    I := NPos(LineEnding, NoteText, 7);
    if I > 0 then
    begin
      Delete(NoteText, I + 1, Length(NoteText));
      NoteText += '...';
    end;


    if not Assigned(FNotesHint) then
    begin
      FNotesHint := THintWindow.Create(Self);
      if (not EntrySettings.NotesUseSystem) then
      begin
        FNotesHint.Font.Assign(EntrySettings.HeadingFont5);
        FNotesHint.Color := EntrySettings.NotesHintBgColor;
      end;
      FNotesHint.AutoHide := true;
      FNotesHint.HideInterval := 5000;
    end;
    R := FNotesHint.CalcHintRect(0, NoteText, nil);
    P := CE.ClientToScreen(Point(0,0));
    OffsetRect(R, P.X + CE.Width + 2, P.Y);
    FNotesHint.ActivateHint(R, NoteText);
  end else
  // Display in window
  begin
    if not Assigned(FNotesForm) then
      FNotesForm := TNotesForm.Create(Self);
    FNotesForm.NotesMemo.Text := NoteText;

    if not FNotesForm.Showing and ForceShow then
      FNotesForm.Show;
  end;
end;

procedure TDataFormFrame.UnShowNotes;
begin
  if Assigned(FNotesHint) then
    FNotesHint.Hide;
end;

procedure TDataFormFrame.UnShowNotesAndHint;
begin
  UnShowNotes;
  ShowHintMsg('', nil);
end;

function TDataFormFrame.NewOrNextRecord: TCustomEdit;
var
  B: Boolean;
  CRecNo: Integer;
begin
  Result := nil;

  if (RecNo = NewRecord) or
     (RecNo = (FLocalToDFIndex.Size - 1))
  then
    begin
      // If we have reached the maximum number of possible records then???
      if IsDetailRelation then
      begin
        // If we are entering a new record, then size of datafile/localindex is
        // 1 records to short (it is not yet commited).
        B :=
          (RecNo = NewRecord) and
          ((FLocalToDFIndex.Size + 1) = DetailRelation.MaxRecordCount);

        // If we are editing the last record localindex/datafile size is correct
        // size.
        B := B or
           (
            (RecNo = FLocalToDFIndex.Size - 1) and
            (FLocalToDFIndex.Size = DetailRelation.MaxRecordCount)
           );

        // DataFile settings has presedence over ReachedLastRecord setting.
        B := B or (DataFile.AfterRecordState = arsReturnToParent);

        if B then
        begin
          if (DataFile.AfterRecordState in [arsReturnToParent, arsReturnToParentOnMax])
          then
            PostMessage(Parent.Handle, LM_PROJECT_RELATE, WPARAM(DetailRelation.MasterRelation), 2)
          else begin
            DoNewRecord;
            RecNo := FLocalToDFIndex.Size -1;
          end;
          Exit;
        end;
      end;

      // This was not the last possible record to enter,
      // try to do a new record!
      if not DoNewRecord then exit;
    end
  else
    begin
      CRecNo := RecNo;
      RecNo := RecNo + 1;
      // if the recno was not changed a validation failed, hence do not
      // shift focus field, etc...
      if CRecNo = RecNo then exit;
    end;
  Result := TCustomEdit(CustomEditList[NextUsableFieldIndex(-1, false)]);
end;

function TDataFormFrame.KeyDownData(Sender: TObject; const Key: Word;
  const Shift: TShiftState): PtrInt;
var
  Kdd: PKeyDownData;
begin
  Kdd := New(PKeyDownData);
  Kdd^.Sender := Sender;
  Kdd^.Key := Key;
  Kdd^.Shift := Shift;
  Result := PtrInt(Kdd);
end;

procedure TDataFormFrame.CommitFields;
var
  i: Integer;
  CE: TFieldEdit;
  Field: TEpiField;
begin
  // Add text to auto field with Update mode set.
  for i := 0 to CustomEditList.Count - 1 do
  begin
    CE := TFieldEdit(CustomEditList[i]);
    Field := (CE as IEntryDataControl).Field;

    // Check for AutoInc/Today fields.
    if (Field is TEpiCustomAutoField) and
       ((TEpiCustomAutoField(Field).AutoMode = umUpdated) or
        ((TEpiCustomAutoField(Field).AutoMode = umFirstSave) and (RecNo = NewRecord))
       )
    then with Field do
    begin
      case FieldType of
        ftDMYAuto:  CE.Text := FormatDateTime('DD/MM/YYYY', Date);
        ftMDYAuto:  CE.Text := FormatDateTime('MM/DD/YYYY', Date);
        ftYMDAuto:  CE.Text := FormatDateTime('YYYY/MM/DD', Date);
        ftTimeAuto: CE.Text := FormatDateTime('HH:NN:SS',   Now);
      end;
    end;
  end;

  // Expand datafile so that current text can be commited...
  if RecNo = NewRecord then
  begin
    DataFile.BeginCommitRecord(true);
    DataFile.NewRecords();

    // Add to IndexField!
    FLocalToDFIndex.Size := FLocalToDFIndex.Size + 1;
    FLocalToDFIndex.AsInteger[FLocalToDFIndex.Size - 1] := DataFile.Size - 1;

    FDFToLocalIndex.Size := DataFile.Size;
    FDFToLocalIndex.AsInteger[FDFToLocalIndex.Size - 1] := FLocalToDFIndex.Size - 1;
  end else
    DataFile.BeginCommitRecord(false);

  for i := 0 to FCustomEditList.Count - 1 do
    (FCustomEditList[i] as IEntryDataControl).Commit;

  DataFile.EndCommitRecord(RecNo);
  Modified := false;
end;

procedure TDataFormFrame.UpdateSettings;
var
  i: Integer;
  Intf: IEntryControl;
begin
  UpdateShortCuts;
  UpdateNotesHints;
  UpdateStatusbarDataform;
  UpdateStatusbarSelection;

  if Assigned(DataFile) then
    for i := 0 to DataFile.ControlItems.Count - 1 do
      if Supports(ControlFromEpiControl(DataFile.ControlItems[i]), IEntryControl, Intf) then
        Intf.UpdateSettings;
end;

class procedure TDataFormFrame.RestoreDefaultPos(F: TDataFormFrame);
begin
  if Assigned(F) then
    TNotesForm.RestoreDefaultPos(F.FNotesForm)
  else
    TNotesForm.RestoreDefaultPos();

  TSearchForm1.RestoreDefaultPos;
  TValueLabelsPickListForm2.RestoreDefaultPos;

  ResultListFormDefaultPosition();
end;

procedure TDataFormFrame.FillKeyFields;
var
  ParentKeyFields: TEpiFields;
  ParentKeyField: TEpiField;
  ParentCE: TCustomEdit;
  F: TEpiField;
  CE: TCustomEdit;
begin
  if not IsDetailRelation then exit;

  ParentKeyFields := TEpiDetailRelation(Relation).MasterRelation.Datafile.KeyFields;

  for ParentKeyField in ParentKeyFields do
  begin
    ParentCE := CustomEditFromField(ParentKeyField);

    F := DataFile.KeyFields.FieldByName[ParentKeyField.Name];
    CE := CustomEditFromField(F);

    CE.Text := ParentCE.Text;
  end;
end;

procedure TDataFormFrame.DoRecordChanged;
begin
  if Assigned(OnRecordChanged) then
    OnRecordChanged(Self);
end;

function TDataFormFrame.GetMasterDataForm: TDataFormFrame;
begin
  Result := nil;

  if IsDetailRelation then
    Result := TProjectFrame(Parent).FrameFromRelation(DetailRelation.MasterRelation);
end;

procedure TDataFormFrame.RecordStatusChange(const Sender: TEpiCustomBase;
  const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup; EventType: Word;
  Data: Pointer);
var
  MasterDF: TEpiDataFile absolute Sender;
  NewStatus: TEpiRecordState;
  i: Integer;
begin
  if (EventGroup <> eegDataFiles) then exit;
  if (EventType <> Word(edceRecordStatus)) then exit;

  NewStatus := PEpiDataFileStatusRecord(Data)^.NewValue;

  for i := 0 to FLocalToDFIndex.Size - 1 do
  begin
    case NewStatus of
      rsNormal:
        DataFile.Deleted[FLocalToDFIndex.AsInteger[i]] := False;
      rsVerified:
        DataFile.Verified[FLocalToDFIndex.AsInteger[i]] := True;
      rsDeleted:
        DataFile.Deleted[FLocalToDFIndex.AsInteger[i]] := True;
    end;
  end;
end;

procedure TDataFormFrame.KeyFieldDataChange(const Sender: TEpiCustomBase;
  const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup; EventType: Word;
  Data: Pointer);
var
  MasterField: TEpiField absolute Sender;
  KeyField: TEpiField;
  KeyDataRec: PEpiFieldDataEventRecord absolute Data;
  i, IdxSz: Integer;
  BVal: EpiBool;
  IVal: EpiInteger;
  FVal: EpiFloat;
  DVal: EpiDate;
  TVal: EpiTime;
  SVal: EpiString;

begin
  if (EventGroup <> eegFields) then exit;
  if (TEpiFieldsChangeEventType(EventType) <> efceData) then exit;

  KeyField := DataFile.KeyFields.FieldByName[MasterField.Name];
  IdxSz := GetIndexedSize;
  with KeyDataRec^ do
  begin
    case FieldType of
      ftBoolean:
        begin
          BVal := MasterField.AsBoolean[Index];
          for i := 0 to IdxSz - 1 do
            KeyField.AsBoolean[FLocalToDFIndex.AsInteger[i]] := BVal;
        end;
      ftInteger,
      ftAutoInc:
        begin
          IVal := MasterField.AsInteger[Index];
          for i := 0 to IdxSz - 1 do
            KeyField.AsInteger[FLocalToDFIndex.AsInteger[i]] := IVal;
        end;
      ftFloat:
        begin
          FVal := MasterField.AsFloat[Index];
          for i := 0 to IdxSz - 1 do
            KeyField.AsFloat[FLocalToDFIndex.AsInteger[i]] := FVal;
        end;
      ftDMYDate,
      ftMDYDate,
      ftYMDDate,
      ftDMYAuto,
      ftMDYAuto,
      ftYMDAuto:
        begin
          DVal := MasterField.AsDate[Index];
          for i := 0 to IdxSz - 1 do
            KeyField.AsDate[FLocalToDFIndex.AsInteger[i]] := DVal;
        end;
      ftTime,
      ftTimeAuto:
        begin
          TVal := MasterField.AsTime[Index];
          for i := 0 to IdxSz - 1 do
            KeyField.AsTime[FLocalToDFIndex.AsInteger[i]] := TVal;
        end;
      ftString,
      ftUpperString:
        begin
          SVal := MasterField.AsString[Index];
          for i := 0 to IdxSz - 1 do
            KeyField.AsString[FLocalToDFIndex.AsInteger[i]] := SVal;
        end;
    end;
  end;
end;

procedure TDataFormFrame.UpdateActions;
var
  A: TContainedAction;
begin
  for A in ActionList1 do
    A.Update;
end;

procedure TDataFormFrame.ChangeParentRecordState(NewState: TEpiRecordState);
begin
  FParentRecordState := NewState;
end;

function TDataFormFrame.CanChange: Boolean;
begin
  Result := true;
  CloseQuery(Result);
end;

procedure TDataFormFrame.RelateInit(Reason: TRelateReason;
  ParentRecordState: TEpiRecordState);
var
  CE: TCustomEdit;
begin
  UpdateIndexFields;

  case Reason of
    rrRecordChange:
      begin
        // Trick to force a load of data using current filter.
        FRecNo := -1;

        DoNewRecord;
      end;

    rrNewRecord:
      DoNewRecord;

    rrFocusShift:
      begin
        if ((FParentRecordState = rsDeleted) and
            (FLocalToDFIndex.Size > 0))
           or
           (
            (IsDetailRelation) and
            (DetailRelation.MaxRecordCount > 0) and
            (FLocalToDFIndex.Size = DetailRelation.MaxRecordCount)
           )
        then begin
          RecNo := (FLocalToDFIndex.Size - 1);
        end else
          DoNewRecord;

        if ResultListFormIsShowing then
          BrowseAllAction.Execute;
      end;

    rrReturnToParent:
      if ResultListFormIsShowing then
        BrowseAllAction.Execute;

    rrRelateToNextDF:
      begin
        CE := nil;
        DoAfterRecord(CE);
        if ResultListFormIsShowing then
          BrowseAllAction.Execute;
        Exit;
      end;
  end;

  // The one special case where an empty subform is entered
  // from a parentform, where selected record is "Marked for deletion"
  DataFormScroolBox.Enabled :=
    not (
      (Reason = rrFocusShift) and
      (ParentRecordState = rsDeleted) and
      (FLocalToDFIndex.Size = 0)
    );

  ChangeParentRecordState(ParentRecordState);
  UpdateActions;

  DoRecordChanged;
  if (Reason = rrReturnToParent)
  then
    begin
      CE := NextFieldOnKeyDown(FCurrentEdit);

      if (not Assigned(CE)) then
        DoAfterRecord(CE);
    end
  else if (DataFormScroolBox.Enabled)
  then
    FirstFieldAction.Execute;
end;

procedure TDataFormFrame.UpdateChildFocusShift(
  const NewChildRelation: TEpiMasterRelation);
var
  R: TEpiRelate;
begin
  if not (Assigned(NewChildRelation)) then
  begin
    FLastDataFileRelate := nil;
    Exit;
  end;

  for R in DataFile.Relates do
  begin
    if R.DetailRelation = NewChildRelation then
    begin
      FLastDataFileRelate := R;
      Break;
    end;
  end;
end;

procedure TDataFormFrame.CloseQuery(var CanClose: boolean);
var
  Res: Integer;
begin
  CanClose := true;
  if not Modified then exit;

  Res := MessageDlg('Warning',
           'Save record before close?',
           mtConfirmation, mbYesNoCancel, 0, mbCancel);
  case Res of
    mrCancel: CanClose := false;
    mrYes:    begin
                // Sanity check
                // - go through all fields for a validity check.
                if not AllFieldsValidate(false) then
                begin
                  CanClose := false;
                  exit;
                end;
                CommitFields;
              end;
    mrNo:     Modified := false; // Do nothing
  end;
end;

procedure TDataFormFrame.IsShortCut(var Msg: TLMKey; var Handled: Boolean);
begin
  //
end;

function TDataFormFrame.NextUsableFieldIndex(const Index: integer;
  const Wrap: boolean): integer;
begin
  // Assume Index is always valid (or -1 to get the first field).
  Result := Index + 1;

  if (Result >= CustomEditList.Count) and Wrap then
    Result := 0;

  while (Result <= (CustomEditList.Count - 1)) and
        (((CustomEditList[Result] as IEntryDataControl).Field.FieldType in AutoFieldTypes) or
         (not TCustomEdit(CustomEditList[Result]).Enabled)) do
  begin
    inc(Result);
    if (Result >= CustomEditList.Count) and Wrap then
      Result := 0;
  end;
  if Result >= CustomEditList.Count then
    Result := -1;
end;

function TDataFormFrame.PrevNonAutoFieldIndex(const Index: integer;
  const Wrap: boolean): integer;
begin
  // Assume Index is always valid (or CustomEditList.Count to get last field).
  Result := Index - 1;

  if (Result < 0) and Wrap then
    Result := CustomEditList.Count - 1;

  while (Result >= 0) and
        (((CustomEditList[Result] as IEntryDataControl).Field.FieldType in AutoFieldTypes) or
         (not TCustomEdit(CustomEditList[Result]).Enabled)) do
  begin
    dec(Result);
    if (Result < 0) and Wrap then
      Result := CustomEditList.Count - 1;
  end;
end;

procedure TDataFormFrame.ASyncKeyDown(Data: PtrInt);
begin
  with PKeyDownData(Data)^ do
    DoKeyFieldDown(Sender, Key, Shift);
  Dispose(PKeyDownData(Data));
end;

procedure TDataFormFrame.DoKeyFieldDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CE: TCustomEdit absolute Sender;
  NextCE: TCustomEdit;
  Res: TFieldExitFlowType;
  CRecNo: Integer;
  B: Boolean;
  DC: IEntryDataControl;

  function PrevFieldOnKeyDown: TCustomEdit;
  var
    Idx: LongInt;
  begin
    Result := nil;
    Idx := PrevNonAutoFieldIndex(CustomEditList.IndexOf(CE), false);
    if Idx = -1 then exit;
    Result := TCustomEdit(CustomEditList[Idx]);
  end;

begin
  // Jumps backward though fields.
  if ((Key in Key_PrevFieldFlowKeys) and (Shift = [])) or
     ((Key = VK_TAB) and (Shift = [ssShift]))
  then
  Begin
    if not FieldValidate(CE) then exit;

    NextCE := PrevFieldOnKeyDown;
    if Assigned(NextCE) then
      NextCE.SetFocus;
    Key := VK_UNKNOWN;
  end;

  if (Key in Key_RelateToParentKeys) and
     (Shift = []) and
     (IsDetailRelation)
  then
  begin
    PostMessage(Parent.Handle, LM_PROJECT_RELATE, WPARAM(DetailRelation.MasterRelation), 1);
    Key := VK_UNKNOWN;
    Exit;
  end;

  DC := (CE as IEntryDataControl);

  // Leave field or see pick-list.
  if (Key in Key_FieldActKeys) and
     (Shift = [])
  then
    begin
      if (Key in Key_ShowPickListKeys) and
         (not Assigned(DC.Field.ValueLabelSet)) then exit;

      if (Key in Key_ShowPickListKeys) and
         (Assigned(DC.Field.ValueLabelSet)) and
         (not ShowValueLabelPickList(CE)) then
      begin
        Key := VK_UNKNOWN;
        exit;
      end;

      if not FieldValidate(CE, false) then
      begin
        Key := VK_UNKNOWN;
        exit;
      end;

      // Field is validated - check for Valuelabels and update CE.
      DC.UpdateSettings;

      Res := FieldExitFlow(CE, NextCE);
      case Res of
        fxtOk:
          NextCE := NextFieldOnKeyDown(CE);

        fxtError:
          begin
            Key := VK_UNKNOWN;
            Exit;
          end;

        fxtRelate:
          begin
            // A PostMessage() has been sent to Project Frame, so just exit!
            Key := VK_UNKNOWN;
            Exit;
          end;

        fxtJump:
          ; // Do nothing - NextCE is set.
      end;

      if not Assigned(NextCE)
      then
        begin
          DoAfterRecord(NextCE);
          if not Assigned(NextCE) then exit;
        end
      else
        begin
          FieldEnterFlow((NextCE as IEntryDataControl));
          NextCE.SetFocus;
        end;

      Key := VK_UNKNOWN;
    end;

  // Needed to keep project updated on changes to key fields.
  if (DataFile.KeyFields.IndexOf(DC.Field) > -1) then
    UpdateModified;
end;

function TDataFormFrame.NextFieldOnKeyDown(const CurrentEdit: TCustomEdit
  ): TCustomEdit;
var
  Idx: LongInt;
begin
  Result := nil;
  Idx := NextUsableFieldIndex(CustomEditList.IndexOf(CurrentEdit), false);
  if Idx = -1 then
  begin
    if (RecNo = NewRecord) or (RecNo = (FLocalToDFIndex.Size - 1))  then
      exit
    else begin
      NextRecAction.Execute;
      Idx := NextUsableFieldIndex(-1, false);
    end
  end;
  if Idx = -1 then ; // TODO : This should never happend?
  result := TCustomEdit(CustomEditList[Idx]);
end;

procedure TDataFormFrame.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CE: TCustomEdit absolute Sender;
  DC: IEntryDataControl;
begin
  if CE.Modified then Modified := true;
  DC := (CE as IEntryDataControl);

  if (DC.JumpToNext) and (not DC.Field.ConfirmEntry) then
  begin
    Key := VK_RETURN;
    CE.OnKeyDown(CE, Key, []);
    DC.JumpToNext := false;
    Exit;
  end;
end;

procedure TDataFormFrame.FieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ShowHintMsg('', nil);

  // Moved all vode to DoKeyFieldDown - then only real key presses activates
  // the ShowHint method.
  DoKeyFieldDown(Sender, Key, Shift);
end;

procedure TDataFormFrame.FieldEnter(Sender: TObject);
var
  CE: TFieldEdit absolute sender;
  FieldTop: LongInt;
  Delta: Integer;
begin
  // Occurs whenever a field recieves focus
  // - eg. through mouseclik, tab or move.
  FieldTop := FieldEditTop(CE);
  Delta := DataFormScroolBox.Height div 4;

  With DataFormScroolBox.VertScrollBar do
  begin
    if FieldTop < (Position + Delta) then
      Position := FieldTop - Delta;

    if FieldTop > (Position + Page - Delta) then
      Position := FieldTop - Page + CE.Height + Delta;
  end;

  CE.Color := EntrySettings.ActiveFieldColour;
  ShowNotes(CE);
  FCurrentEdit := CE;
  FCurrentDataCtrl := (FCurrentEdit as IEntryDataControl);

  UpdateStatusbarSelection;
end;

procedure TDataFormFrame.FieldExit(Sender: TObject);
var
  CE: TCustomEdit absolute Sender;
  DC: IEntryDataControl;
begin
  DC := (CE as IEntryDataControl);

  if (DC.Field.EntryMode = emMustEnter) or
     (DataFile.KeyFields.IndexOf(DC.Field) >= 0)
  then
    CE.Color := EntrySettings.MustEnterFieldColour
  else
    CE.Color := EntrySettings.InactiveFieldColour;
  FieldValidate(CE);
end;

procedure TDataFormFrame.FieldEnterFlow(DC: IEntryDataControl);
var
  Field: TEpiField;
begin
  // *************************************
  // **    EpiData Flow Control (Pre)   **
  // *************************************
  // Should all these things happen each time, or only first time
  //   field is entered.


  Field := DC.Field;
  // Before field script:
  // TODO : Before field script

  // Top-of-screen?

  // TORSTEN Okt. 2012:
  // Due to the flow of event, it is nessesary to check if a Project
  // is being opened - else a bug occurs where the Picklist form is
  // shown before the Dataform is loaded.
  // Force Show Picklist.
  if (DC.CustomEdit.Text = '') and
     (Assigned(Field.ValueLabelSet)) and
     (Field.ForcePickList)
  then
    if not FLoadingDatafile then
      PostMessage(DC.CustomEdit.Handle, CN_KEYDOWN, VK_F9, 0);
end;

function TDataFormFrame.FieldExitFlow(CE: TCustomEdit; out NewEdit: TCustomEdit
  ): TFieldExitFlowType;
var
  Field: TEpiField;
  Jump: TEpiJump;
  Idx: LongInt;
  Section: TEpiSection;
  EIdx: LongInt;
  NewField: TEpiField;
  Err: string;
  ErrEdit: TCustomEdit;
  Txt: String;
  OldText: TCaption;
  CheckUnique: Boolean;
  R: TEpiValueRelate;
  DC: IEntryDataControl;

  procedure PerformJump(Const StartIdx, EndIdx: LongInt; ResetType: TEpiJumpResetType);
  var
    i: LongInt;
    Cnt: Integer;
    j: Integer;
    CachedVLS: TEpiValueLabelSet;
    CachedVL: TEpiCustomValueLabel;
    lCE: TCustomEdit;
    lField: TEpiField;
  begin
    if ResetType = jrLeaveAsIs then exit;

    CachedVLS := nil;
    for i := StartIdx to EndIdx do
    begin
      lCE := TCustomEdit(CustomEditList[i]);
      lField := (lCE as IEntryDataControl).Field;

      if lField.FieldType in AutoFieldTypes then continue;

      case ResetType of
        jrSystemMissing: lCE.Text := '.';
        jrMaxMissing:    with lField do
                         begin
                           if not Assigned(ValueLabelSet) then continue;

                           // A little cacheing make it faster, works well if
                           // lots of fields use the same VLSet.
                           if CachedVLS = ValueLabelSet then
                             lCE.Text := CachedVL.ValueAsString
                           else begin
                             for j := ValueLabelSet.Count - 1 downto 0 do
                             with ValueLabelSet[j] do
                             begin
                               if IsMissingValue then
                               begin
                                 CachedVLS := ValueLabelSet;
                                 CachedVL := ValueLabelSet[j];
                                 lCE.Text := ValueAsString;
                                 Break;
                               end;
                             end;
                           end;
                         end;
        jr2ndMissing:    with lField do
                         begin
                           if not Assigned(ValueLabelSet) then continue;

                           // A little cacheing make it faster, works well if
                           // lots of fields use the same VLSet.
                           if CachedVLS = ValueLabelSet then
                             lCE.Text := CachedVL.ValueAsString
                           else begin
                             Cnt := 0;
                             for j := ValueLabelSet.Count - 1 downto 0 do
                             with ValueLabelSet[j] do
                             begin
                               if IsMissingValue then inc(Cnt);
                               if (Cnt = 2) then
                               begin
                                 CachedVLS := ValueLabelSet;
                                 CachedVL := ValueLabelSet[j];
                                 lCE.Text := ValueAsString;
                                 Break;
                               end;
                             end;
                           end;
                         end;
      end;

      // This forces and update of the FieldEdits labels -> hence updates ValueLabel too.
      UpdateSettings;
    end;
  end;

begin
  // **************************************
  // **    EpiData Flow Control (Post)   **
  // **************************************
  result := fxtOk;
  DC := (CE as IEntryDataControl);
  Field := DC.Field;


  // Key Unique
  if (DataFile.KeyFields.Count > 0) and
     (DataFile.KeyFields.FieldExists(Field)) then
  begin
    if not PerformKeyFieldsCheck then
    begin
      CE.SelectAll;
      Exit(fxtError);
    end;
  end;

  // Comparison
  if Assigned(Field.Comparison) then
  begin
    NewEdit := CustomEditFromField(Field.Comparison.CompareField);
    if not DC.CompareTo(NewEdit.Text, Field.Comparison.CompareType) then
    begin
      Err := Format(
        'Comparison failed:' + LineEnding +
        '%s: %s  %s  %s: %s',
        [Field.Name, CE.Text, ComparisonTypeToString(Field.Comparison.CompareType),
         Field.Name, NewEdit.Text]);
      FieldValidateError(CE, Err);
      Exit(fxtError);
    end;
  end;

  // Type Comment
  if Assigned(Field.ValueLabelWriteField) then
  begin
    NewEdit := CustomEditFromField(Field.ValueLabelWriteField);
    OldText := NewEdit.Text;
    NewEdit.Text := Field.ValueLabelSet.ValueLabelString[CE.Text];
    if OldText <> NewEdit.Text then
      Modified := true;
  end;

  // After Entry Script (Calculation)
  if Assigned(Field.Calculation) then
  begin
    NewEdit := CustomEditFromField(Field.Calculation.ResultField);
    Err := '';
    OldText := NewEdit.Text;
    case Field.Calculation.CalcType of
      ctTimeDiff:      Txt := CalcTimeDiff(TEpiTimeCalc(Field.Calculation));
      ctCombineDate:   Txt := CalcCombineDate(TEpiCombineDateCalc(Field.Calculation), Err, ErrEdit);
      ctCombineString: Txt := CalcCombineString(TEpiCombineStringCalc(Field.Calculation));
    end;
    if (Txt <> TEpiStringField.DefaultMissing)
    then
      NewEdit.Text := Txt;

    if Err <> '' then
    begin
      ErrEdit.SetFocus;
      FieldValidateError(ErrEdit, Err);
      Exit(fxtError);
    end;
    if OldText <> NewEdit.Text then
      Modified := true;
  end;


  // Jumps
  NewEdit := nil;
  if Assigned(Field.Jumps) then
  begin
    Idx := CustomEditList.IndexOf(CE);
    Txt := CE.Text;
    if Txt = '' then Txt := '.';
    Jump := Field.Jumps.JumpFromValue[Txt];
    if Assigned(Jump) then
    begin
      case Jump.JumpType of
        jtSaveRecord:    begin
                           PerformJump(Idx + 1, CustomEditList.Count - 1, Jump.ResetType);
                         end;
        jtExitSection:   begin
                           Section := Field.Section;
                           if Section = DataFile.MainSection then
                           begin
                             EIdx := CustomEditList.Count;
                             PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                           end else begin
                             EIdx := Idx + 1;
                             while (EIdx < CustomEditList.Count) and (EIdx <> -1) and
                                   ((CustomEditList[EIdx] as IEntryDataControl).Field.Section = Section) do
                               EIdx := NextUsableFieldIndex(EIdx, false);
                             if EIdx = -1 then EIdx := CustomEditList.Count;
                             PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                             // Making this check also forces a "new record" event since NewEdit = nil;
                             if EIdx < CustomEditList.Count then
                               NewEdit := TCustomEdit(CustomEditList[EIdx]);
                           end;
                         end;
        jtSkipNextField: begin
                           EIdx := NextUsableFieldIndex(Idx + 1, false);
                           if EIdx = -1 then EIdx := CustomEditList.Count;
                           PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                           if EIdx < CustomEditList.Count then
                             NewEdit := TCustomEdit(CustomEditList[EIdx]);
                           // A "DoNewRecord" is performed if no NewEdit is assigned
                           // as is the case if SkipNextField is perform on second-last field.
                           {
                           else
                             NewRecordAction.Execute;}
                         end;
        jtToField:       begin
                           NewField := Jump.JumpToField;
                           EIdx := Idx + 1;
                           while (EIdx < CustomEditList.Count) and (EIdx <> -1) and
                                 ((CustomEditList[EIdx] as IEntryDataControl).Field <> NewField) do
                             EIdx := NextUsableFieldIndex(EIdx, false);

                           if EIdx = -1 then EIdx := CustomEditList.Count;
                           if Eidx >= CustomEditList.Count then exit;

                           PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                           NewEdit := TCustomEdit(CustomEditList[EIdx]);
                         end;
      end;
      Exit(fxtJump);
    end;
  end;

  if Assigned(Field.Relates)
  then
  begin
    R := Field.Relates.RelateFromValue[CE.Text];

    if Assigned(R) then
    begin
      PostMessage(Parent.Handle, LM_PROJECT_RELATE, WPARAM(R.DetailRelation), 0);
      Result := fxtRelate;
    end;
  end;
end;

function TDataFormFrame.DoValidateKeyFields: Boolean;
var
  i: Integer;
begin
  Result := true;

  if (
      // This is only possible on main dataforms.
      (DataFile.KeyFields.Count > 0) and
      (not IsDetailRelation)
     ) or
     (
     // Is this is a detail, only check keyfields if there are actually more
     // keyfields than the parent, otherwise it will naturally always fail.
      (IsDetailRelation) and
      (DetailRelation.MasterRelation.Datafile.KeyFields.Count < DataFile.KeyFields.Count)
     )
  then
    begin
      i := DoSearchKeyFields;
      // if i = -1 then keys do not exists,
      // if i = RecNo then current records is found in the search, which is ok
      result := (i = RecNo) or (i = -1);
    end;
end;

function TDataFormFrame.AllFieldsValidate(IgnoreMustEnter: boolean): boolean;
var
  i: Integer;
begin
  result := true;

  // Regular check on Syntax Etc.
  for i := 0 to CustomEditList.Count - 1 do
    if not FieldValidate(TCustomEdit(CustomEditList[i]), IgnoreMustEnter) then exit(false);

  // Additional check for KeyFields consistency.
  Result := Result and
    DoValidateKeyFields;
end;

function TDataFormFrame.AllKeyFieldsAreFilled: boolean;
var
  F: TEpiField;
begin
  Result := true;

  for F in DataFile.KeyFields do
    Result := Result and
              (CustomEditFromField(F).Text <> '');
end;

function TDataFormFrame.GetCurrentKeyFieldValues: string;
var
  F: TEpiField;
  CE: TCustomEdit;
begin
  Result := '';

  for F in DataFile.KeyFields do
  begin
    CE := CustomEditFromField(F);
    Result += F.Name + ' = ' + CE.Text + LineEnding;
  end;
end;

function TDataFormFrame.FieldValidate(CE: TCustomEdit; IgnoreMustEnter: boolean
  ): boolean;

  procedure DoError(LocalCE: TCustomEdit);
  begin
    LocalCE.Color := EntrySettings.ValidateErrorColour;
    LocalCE.SelectAll;
    if LocalCE.Enabled then
      LocalCE.SetFocus;
    Beep;
  end;

  procedure NotifyFieldEditKeyDown;
  begin
    Application.QueueAsyncCall(@ASyncKeyDown, KeyDownData(CE, VK_F9, []));
  end;

var
  F: TEpiField;
  DC: IEntryDataControl;
begin
  DC := (CE as IEntryDataControl);
  DC.JumpToNext := false;
  F := DC.Field;
  CE.SelLength := 0;

  Result := DC.ValidateEntry;
  if not Result then
  begin
    DoError(CE);
    if Assigned(F.ValueLabelSet) and
       (not Assigned(F.Ranges))
    then
      NotifyFieldEditKeyDown;
    Exit;
  end else begin
    ShowHintMsg('', nil);
  end;

  if (not IgnoreMustEnter) and
     ((F.EntryMode = emMustEnter) or
      (DataFile.KeyFields.FieldExists(F))
     ) and
     (CE.Text = '') then
  begin
    DoError(CE);
    FieldValidateError(CE, 'Field cannot be empty!');
    if Assigned(F.ValueLabelSet) and
       (not Assigned(F.Ranges))
    then
      NotifyFieldEditKeyDown;
    Result := false;
  end;
end;

procedure TDataFormFrame.FieldValidateError(Sender: TObject; const Msg: string
  );
begin
  ShowHintMsg(Msg, TControl(Sender));
end;

function TDataFormFrame.ShowValueLabelPickList(ACustomEdit: TCustomEdit
  ): boolean;
var
  VLForm: TValueLabelsPickListForm2;
  P: TPoint;
  F: TEpiField;
begin
  UnShowNotesAndHint;

  F := (ACustomEdit as IEntryDataControl).Field;

  VLForm := TValueLabelsPickListForm2.Create(Self, F);
  VLForm.SetInitialValue(ACustomEdit.Text);
  P := ACustomEdit.Parent.ClientToScreen(Point(ACustomEdit.Left + ACustomEdit.Width + 2, ACustomEdit.Top));
  VLForm.Top := P.Y;
  VLForm.Left := P.X;
  result := VLForm.ShowModal = mrOK;

  if Result then
  begin
    ACustomEdit.Text := VLForm.SelectedValueLabel.ValueAsString;
    Modified := true;
  end;

  VLForm.Free;
end;

procedure TDataFormFrame.DoAfterRecord(out NewEdit: TCustomEdit);
var
  Relate: TEpiRelate;
  Idx: Integer;
begin
  // First relate dataforms
  Relate := nil;
  if DataFile.Relates.Count > 0 then
  begin
    if not Assigned(FLastDataFileRelate) then
      Relate := DataFile.Relates[0]
    else
      begin
        Idx := DataFile.Relates.IndexOf(FLastDataFileRelate) + 1;
        if (Idx < DataFile.Relates.Count) then
          Relate := DataFile.Relates[Idx];
      end;

    FLastDataFileRelate := Relate;

    if Assigned(Relate) then
    begin
      PostMessage(Parent.Handle, LM_PROJECT_RELATE, WPARAM(Relate.DetailRelation), 0);
      Exit;
    end;
  end;

  NewEdit := NewOrNextRecord;

  if not Assigned(NewEdit) then
    Exit;

  FieldEnterFlow((NewEdit as IEntryDataControl));
  NewEdit.SetFocus;
end;

constructor TDataFormFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FParentRecordState := rsNormal;
  FLastDataFileRelate := nil;

  FLocalToDFIndex := TEpiField.CreateField(nil, ftInteger);
  FLocalToDFIndex.Size := 0;

  FDFToLocalIndex := TEpiField.CreateField(nil, ftInteger);
  FDFToLocalIndex.Size := 0;

  FCustomEditList := TObjectList.Create;
  FCustomEditList.OwnsObjects := false;

  FHintWindow := nil;
  FRecNo := -1;

  {$IFNDEF EPI_DEBUG}
  Panel1.Hide;
  {$ENDIF}

  UpdateSettings;
end;


end.

