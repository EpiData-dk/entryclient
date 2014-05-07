unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, types, FileUtil, PrintersDlgs, Forms, Controls,
  epidatafiles, epicustombase, StdCtrls, ExtCtrls, Buttons, ActnList, LCLType,
  ComCtrls, fieldedit, notes_form, epitools_search, LMessages, entry_messages;

type

  { TDataFormFrame }
  TFieldExitFlowType = (fxtOk, fxtError, fxtJump);

  TDataFormFrame = class(TFrame)
    BrowseAllAction: TAction;
    CopyToClipBoardAction: TAction;
    FieldLengthLabel: TLabel;
    FieldRangeLabel: TLabel;
    FieldLengthPanel: TPanel;
    FieldRangePanel: TPanel;
    PrintDataFormWithDataAction: TAction;
    PrintDataFormAction: TAction;
    DeleteLabel: TLabel;
    DeletePanel: TPanel;
    Label1: TLabel;
    Panel1: TPanel;
    PrintDialog1: TPrintDialog;
    ShowFieldNotesAction: TAction;
    FindFastListAction: TAction;
    FindRecordExAction: TAction;
    FindPrevAction: TAction;
    FindNextAction: TAction;
    FindRecordAction: TAction;
    FieldInfoLabel: TLabel;
    FieldInfoPanel: TPanel;
    FieldTypeLabel: TLabel;
    FieldTypePanel: TPanel;
    JumpNextRecAction: TAction;
    JumpPrevRecAction: TAction;
    FieldNamePanel: TPanel;
    FieldNameLabel: TLabel;
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
    NewRecSpeedButton: TSpeedButton;
    DeleteRecSpeedButton: TSpeedButton;
    RecActionPanel: TPanel;
    RecordEdit: TEdit;
    PrevRecSpeedButton: TSpeedButton;
    InformationPanel: TPanel;
    NavigationPanel: TPanel;
    FirstRecSpeedButton: TSpeedButton;
    NextRecSpeedButton: TSpeedButton;
    LastRecSpeedButton: TSpeedButton;
    procedure BrowseAllActionExecute(Sender: TObject);
    procedure CopyToClipBoardActionExecute(Sender: TObject);
    procedure DataFormScroolBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure DeleteRecSpeedButtonClick(Sender: TObject);
    procedure FindRecordExActionExecute(Sender: TObject);
    procedure FindFastListActionExecute(Sender: TObject);
    procedure FindNextActionExecute(Sender: TObject);
    procedure FindRecordActionExecute(Sender: TObject);
    procedure FindPrevActionExecute(Sender: TObject);
    procedure FirstFieldActionExecute(Sender: TObject);
    procedure FirstRecActionExecute(Sender: TObject);
    procedure FirstRecActionUpdate(Sender: TObject);
    procedure GotoRecordActionExecute(Sender: TObject);
    procedure JumpNextRecActionExecute(Sender: TObject);
    procedure JumpPrevRecActionExecute(Sender: TObject);
    procedure LastFieldActionExecute(Sender: TObject);
    procedure LastRecActionExecute(Sender: TObject);
    procedure LastRecActionUpdate(Sender: TObject);
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
    procedure RecordEditEditingDone(Sender: TObject);
    procedure RecordEditEnter(Sender: TObject);
    procedure ShowFieldNotesActionExecute(Sender: TObject);
    procedure ShowFieldNotesActionUpdate(Sender: TObject);
  private
    FDataFile: TEpiDataFile;
    FFieldEditList: TFpList;
    FRecNo: integer;
    FLoadingDatafile: boolean;
    procedure SetDataFile(const AValue: TEpiDataFile);
    procedure LoadRecord(RecordNo: Integer);
    procedure UpdateRecordEdit;
    procedure UpdateRecActionPanel;
    procedure SetRecNo(AValue: integer);
    procedure SetModified(const AValue: boolean);
    function  DoNewRecord: boolean;
    function  ControlFromEpiControl(EpiControl: TEpiCustomItem): TControl;
    function  FieldEditFromField(Field: TEpiField): TFieldEdit;
    procedure DoPrintDataForm(WithData: boolean);
    procedure DoCopyToClipBoard;
  private
    { Hint }
    FHintWindow: THintWindow;
    function  GetHintWindow: THintWindow;
    procedure ShowHintMsg(Const Msg: string; Const Ctrl: TControl);
  private
    { Search }
    FRecentSearch: TEpiSearch;
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
    procedure ShowNotes(FE: TFieldEdit; ForceShow: boolean = false);
  private
    { Field Enter/Exit Handling }
    // - Delayed key down handling.
    function  KeyDownData(Sender: TObject; Const Key: Word; Const Shift: TShiftState): PtrInt;
    procedure ASyncKeyDown(Data: PtrInt);
    procedure DoKeyFieldDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function  NextUsableFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    function  PrevNonAutoFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldEnter(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure UpdateFieldPanel(Field: TEpiField);
  private
    { Flow control/Validation/Script handling}
    procedure FieldEnterFlow(FE: TFieldEdit);
    function  FieldExitFlow(FE: TFieldEdit; Out NewFieldEdit: TFieldEdit): TFieldExitFlowType;
    function  AllFieldsValidate(IgnoreMustEnter: boolean): boolean;
    function  FieldValidate(FE: TFieldEdit; IgnoreMustEnter: boolean = true): boolean;
    procedure FieldValidateError(Sender: TObject; const Msg: string);
    function  ShowValueLabelPickList(AFieldEdit: TFieldEdit): boolean;
  private
    FModified: boolean;
    { DataForm Control }
    function  NewSectionControl(EpiControl: TEpiCustomControlItem): TControl;
    function  NewFieldControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
    function  NewHeadingControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
  protected
    procedure SetCursor(Value: TCursor); override;
  private
    procedure UpdateShortCuts;
    procedure UpdateNotesHints;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure CommitFields;
    procedure UpdateSettings;
    procedure CloseQuery(var CanClose: boolean);
    property  DataFile: TEpiDataFile read FDataFile write SetDataFile;
    property  RecNo: integer read FRecNo write SetRecNo;
    property  Modified: boolean read FModified write SetModified;
    property  FieldEditList: TFpList read FFieldEditList;
  public
    class procedure RestoreDefaultPos(F: TDataFormFrame);
  end;

const
  NewRecord = MaxInt;

implementation

{$R *.lfm}

uses
  epidatafilestypes, LCLProc, settings,
  main, Menus, Dialogs, math, Graphics, epimiscutils,
  picklist, epidocument, epivaluelabels, LCLIntf, dataform_field_calculations,
  searchform, resultlist_form, shortcuts, control_types,
  Printers, OSPrinters, Clipbrd,
  entrylabel, entrysection, entry_globals,
  notes_report, epireport_generator_txt,
  strutils;

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
  FE: TFieldEdit;
begin
   I := NextUsableFieldIndex(-1, false);
  if i = -1 then exit;

  FE := TFieldEdit(FieldEditList[i]);
  FieldEnterFlow(FE);
  FE.SetFocus;
end;

procedure TDataFormFrame.DataFormScroolBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  with DataFormScroolBox.VertScrollBar do
    Position := Position - WheelDelta;
  Handled := true;
end;

procedure TDataFormFrame.CopyToClipBoardActionExecute(Sender: TObject);
begin
  DoCopyToClipBoard;
end;

procedure TDataFormFrame.BrowseAllActionExecute(Sender: TObject);
begin
  ShowResultListForm(
    Self,
    'All Data',
    DataFile,
    DataFile.Fields
  );
end;

procedure TDataFormFrame.DeleteRecSpeedButtonClick(Sender: TObject);
begin
  if RecNo = NewRecord then exit;

  FDataFile.Deleted[RecNo] := not FDataFile.Deleted[RecNo];
  Modified := true;
  UpdateRecordEdit;
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
    ShowHintMsg('No records found', RecordEdit);
    exit;
  end;

  FieldList := TEpiFields.Create(nil);
  for i := 0 to FieldEditList.Count - 1 do
    FieldList.AddItem(TFieldEdit(FieldEditList[i]).Field);

  ShowResultListForm(
    Self,
    'Result List:',
    DataFile,
    FieldList,
    Lst);
end;

procedure TDataFormFrame.FindPrevActionExecute(Sender: TObject);
var
  idx: LongInt;
begin
  if not Assigned(FRecentSearch) then exit;
  FRecentSearch.Direction := sdBackward;
  Idx := Min(RecNo, FDataFile.Size) - 1;
  DoPerformSearch(FRecentSearch, Idx, true);
end;

procedure TDataFormFrame.FirstRecActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (RecNo > 0) and (DataFile.Size > 0);
end;

procedure TDataFormFrame.GotoRecordActionExecute(Sender: TObject);
begin
  RecordEdit.SetFocus;
end;

procedure TDataFormFrame.JumpNextRecActionExecute(Sender: TObject);
begin
  RecNo :=  RecNo + EntrySettings.RecordsToSkip;
end;

procedure TDataFormFrame.JumpPrevRecActionExecute(Sender: TObject);
begin
  RecNo :=  Min(RecNo - EntrySettings.RecordsToSkip, DataFile.Size - EntrySettings.RecordsToSkip);
end;

procedure TDataFormFrame.LastFieldActionExecute(Sender: TObject);
var
  i: LongInt;
begin
  i := PrevNonAutoFieldIndex(FieldEditList.Count, false);
  if i = -1 then exit;

  TFieldEdit(FieldEditList[i]).SetFocus;
end;

procedure TDataFormFrame.LastRecActionExecute(Sender: TObject);
begin
  RecNo := DataFile.Size - 1;
end;

procedure TDataFormFrame.LastRecActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := RecNo < (DataFile.Size - 1);
end;

procedure TDataFormFrame.NewRecordActionExecute(Sender: TObject);
var
  FE: TFieldEdit;
  Idx: LongInt;
begin
  if not DoNewRecord then exit;

  Idx := NextUsableFieldIndex(-1, false);
  if Idx = -1 then exit;

  FE := TFieldEdit(FieldEditList[Idx]);
  FieldEnterFlow(FE);
  FE.SetFocus;
end;

procedure TDataFormFrame.NewRecordActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    (RecNo <> NewRecord) or
    ((RecNo = NewRecord) and (Modified));
  NewRecSpeedButton.ShowHint := TAction(Sender).Enabled;
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
  RecNo := Min(RecNo - 1, DataFile.Size - 1);
end;

procedure TDataFormFrame.PrintDataFormActionExecute(Sender: TObject);
begin
  DoPrintDataForm(false);
end;

procedure TDataFormFrame.PrintDataFormWithDataActionExecute(Sender: TObject);
begin
  DoPrintDataForm(true);
end;

procedure TDataFormFrame.RecordEditEditingDone(Sender: TObject);
var
  AValue, Code: integer;
begin
  Val(RecordEdit.Text, AValue, Code);
  if Code <> 0 then exit;

  Code := Min(AValue - 1, DataFile.Size - 1);
  if Code < 0 then exit;

  RecNo := Code;
  FirstFieldAction.Execute;
end;

procedure TDataFormFrame.RecordEditEnter(Sender: TObject);
begin
  RecordEdit.SelectAll;
end;

procedure TDataFormFrame.ShowFieldNotesActionExecute(Sender: TObject);
begin
  if MainForm.ActiveControl is TFieldEdit then
    ShowNotes(TFieldEdit(MainForm.ActiveControl), true);
end;

procedure TDataFormFrame.ShowFieldNotesActionUpdate(Sender: TObject);
var
  LAction: TAction absolute Sender;
begin
  LAction.Enabled :=
    (MainForm.ActiveControl is TFieldEdit) and
    (TFieldEdit(MainForm.ActiveControl).Field.Notes.Text <> '');
end;

procedure TDataFormFrame.FindNextActionExecute(Sender: TObject);
var
  idx: LongInt;
begin
  if not Assigned(FRecentSearch) then exit;
  FRecentSearch.Direction := sdForward;
  Idx := Min(RecNo, FDataFile.Size) + 1;
  DoPerformSearch(FRecentSearch, Idx, true);
end;

procedure TDataFormFrame.FindRecordActionExecute(Sender: TObject);
begin
  DoSearchForm(nil);
end;

function FieldSort(Item1, Item2: Pointer): Integer;
var
  F1: TFieldEdit absolute Item1;
  F2: TFieldEdit absolute Item2;
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

  MainSection := F1.Field.DataFile.MainSection;

  // Cross section comparison.
  if (F1.Field.Section <> MainSection) and (F2.Field.Section <> MainSection) then
  begin
    result := F1.Parent.Top - F2.Parent.Top;
    if result = 0 then
      Result := F1.Parent.Left - F2.Parent.Left;
    Exit;
  end;

  // Main <-> Section comparison
  if (F1.Field.Section = MainSection) then
  begin
    result := F1.Top - F2.Parent.Top;
    if Result = 0 then
      result := F1.Left - F2.Parent.Left;
    exit;
  end;

  // Section <-> Main comparison
  if (F2.Field.Section = MainSection) then
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

  // Correct tab order of fields.
  FFieldEditList.Sort(@FieldSort);
  for i := 0 to FFieldEditList.Count - 1 do
    TFieldEdit(FFieldEditList[i]).TabOrder := i;

  // Todo : React to how users have define "new record" behaviour.
  if DataFile.Size = 0 then
    NewRecordActionExecute(nil)
  else
    RecNo := (DataFile.Size - 1);

  FLoadingDatafile := false;
  RecordEdit.SetFocus;
end;

procedure TDataFormFrame.LoadRecord(RecordNo: Integer);
var
  i: Integer;
begin
  MainForm.BeginUpdateForm;
  for i := 0 to FFieldEditList.Count - 1 do
    TFieldEdit(FFieldEditList[i]).RecNo := RecordNo;
  MainForm.EndUpdateForm;
end;

procedure TDataFormFrame.UpdateRecordEdit;
begin
  if RecNo = NewRecord then
  begin
    if Modified then
      RecordEdit.Text :=
          Format('New / %d *', [DataFile.Size])
    else
      RecordEdit.Text :=
        Format('New / %d', [DataFile.Size]);
  end else begin
    if Modified then
      RecordEdit.Text :=
          Format('%d / %d *', [RecNo + 1, DataFile.Size])
    else
      RecordEdit.Text :=
        Format('%d / %d', [RecNo + 1, DataFile.Size]);
  end;
  UpdateRecActionPanel;

  if DataFile.Size = 0 then
    RecordEdit.Text := 'Empty';
end;

procedure TDataFormFrame.UpdateRecActionPanel;
var
  B: Boolean;
begin
  B := RecNo <> NewRecord;
  DeleteRecSpeedButton.Enabled  := B;
  DeleteRecSpeedButton.ShowHint := B;

  B := B and FDataFile.Deleted[RecNo];
  DeleteRecSpeedButton.Hint := BoolToStr(B, 'UnDelete', 'Delete');
  DeleteLabel.Caption       := BoolToStr(B, 'DEL',      '');
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
  AParent: TWinControl): TControl;
begin
  case TEpiField(EpiControl).FieldType of
    ftBoolean:  Result := TBoolEdit.Create(AParent);
    ftInteger,
    ftAutoInc:  Result := TIntegerEdit.Create(AParent);

    ftFloat:    Result := TFloatEdit.Create(AParent);

    ftUpperString,
    ftString:   Result := TStringEdit.Create(AParent);

    ftDMYDate,
    ftDMYAuto,
    ftMDYDate,
    ftMDYAuto,
    ftYMDDate,
    ftYMDAuto: Result := TDateEdit.Create(AParent);

    ftTimeAuto,
    ftTime:     Result := TTimeEdit.Create(AParent);
  end;
  if TEpiField(EpiControl).EntryMode = emNoEnter then
    Result.Enabled := false;

  EpiControl.AddCustomData(DataFormCustomDataKey, result);
  Result.Parent := AParent;

  with TFieldEdit(Result) do
  begin
    Field     := TEpiField(EpiControl);
    OnKeyDown := @FieldKeyDown;
    OnKeyUp   := @FieldKeyUp;
    OnEnter   := @FieldEnter;
    OnExit    := @FieldExit;
    OnValidateError := @FieldValidateError;
  end;

  FFieldEditList.Add(Result);
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
  GotoRecordAction.ShortCut := D_GotoRec;
  PageUpAction.ShortCut := D_SideUp;
  PageDownAction.ShortCut := D_SideDown;
  FindRecordAction.ShortCut := D_SearchRecordEmpty;
  FindRecordExAction.ShortCut := D_SearchRecordFilled;
  FindNextAction.ShortCut := D_SearchRepeatForward;
  FindPrevAction.ShortCut := D_SearchRepeatBackward;
  FindFastListAction.ShortCut := D_SearchRecordList;
  CopyToClipBoardAction.ShortCut := D_CopyRecordToClipBoard;
  PrintDataFormAction.ShortCut   := D_PrintForm;
  PrintDataFormWithDataAction.ShortCut := D_PrintFormWithData;
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

procedure TDataFormFrame.SetRecNo(AValue: integer);
var
  Res: LongInt;
begin
  if not (AValue = NewRecord) then
  begin
    if AValue = FRecNo then exit;
    if AValue >= DataFile.Size then AValue := DataFile.Size - 1;
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
  LoadRecord(AValue);
  UpdateRecordEdit;
end;

procedure TDataFormFrame.SetModified(const AValue: boolean);
begin
  if FModified = AValue then exit;
  FModified := AValue;
  UpdateRecordEdit;
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

function TDataFormFrame.DoNewRecord: boolean;
var
  i: Integer;
  Res: LongInt;
  AVal: Int64;
begin
  Result := false;

  // *******************
  // * Commit old data *
  // *******************
  if (RecNo <> NewRecord) and Modified then
  begin
    // Sanity check
    // - go through all fields for a validity check.
    if not AllFieldsValidate(false) then exit;

    Res := MessageDlg('Warning',
             'Current record modified.' + LineEnding +
             'Save before new record?', mtConfirmation, mbYesNoCancel, 0, mbCancel);
    case Res of
      mrCancel: Exit;
      mrYes:    CommitFields;
      mrNo:     ; // Do nothing
    end;
  end;

  if (RecNo = NewRecord) then
  begin
    // Sanity check
    // - go through all fields for a validity check.
    if not AllFieldsValidate(false) then exit;

    Res := MessageDlg('Confirmation',
             'Save Record?',
             mtConfirmation, mbYesNoCancel, 0, mbYes);
    case Res of
      mrCancel: Exit;
      mrYes:    CommitFields;
      mrNo:     ; // Do nothing
    end;
  end;

  // **********************************
  // * Prepare system for new record  *
  // **********************************
  RecNo := NewRecord;
  for i := 0 to FieldEditList.Count - 1 do
  with TFieldEdit(FieldEditList[i]) do
  begin
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
        ftDMYAuto: if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('DD/MM/YYYY', Date);
        ftMDYAuto: if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('MM/DD/YYYY', Date);
        ftYMDAuto: if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('YYYY/MM/DD', Date);
        ftTimeAuto:  if (TEpiCustomAutoField(Field).AutoMode = umCreated) then Text := FormatDateTime('HH:NN:SS',   Now);
      end;
    end;

    // Default Value
    if (Field.HasDefaultValue) then
      Text := Field.DefaultValueAsString;

    // Repeat
    if (Field.RepeatValue) and (Field.Size > 0) and (not Field.IsMissing[Field.Size - 1]) then
      Text := Field.AsString[Field.Size - 1];
  end;
  Result := true;
end;

function TDataFormFrame.ControlFromEpiControl(EpiControl: TEpiCustomItem
  ): TControl;
begin
  result := TControl(EpiControl.FindCustomData(DataFormCustomDataKey));
end;

function TDataFormFrame.FieldEditFromField(Field: TEpiField): TFieldEdit;
begin
  result := TFieldEdit(ControlFromEpiControl(Field));
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

  function RecursiveFindControl(Const EpiCtrl: TEpiCustomControlItem;
    Const WinControl: TWinControl): TControl;
  var
    i: Integer;
  begin
    if EpiCtrl is TEpiField then
      Exit(FieldEditFromField(TEpiField(EpiCtrl)));

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
        ABot := ATop + Round(FieldEditFromField(TEpiField(CI)).Height * yscale);  // Canvas.TextHeight(TEpiField(CI).Name);
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
        // Draw box
        ARight := ALeft + Round(FieldEditFromField(TEpiField(CI)).Width * xscale);
        ATop := ABot - ((ABot - ATop) div 2);

        Canvas.MoveTo(ALeft, ATop);
        Canvas.LineTo(ALeft, ABot);
        Canvas.LineTo(ARight, ABot);
        Canvas.LineTo(ARight, ATop);

        // DATA!
        if WithData and (RecNo <> NewRecord) then
        begin
          Canvas.TextOut(
            ALeft + Round(2 * xscale),
            ABot - Canvas.TextHeight(FieldEditFromField(TEpiField(CI)).Text) - Round(2 * yscale),
            FieldEditFromField(TEpiField(CI)).Text
            );
        end;

        IF trim(Question.Text)<>'' THEN
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
           (RecNo <> NewRecord) and
           (Assigned(ValueLabelSet))
        then
        begin
          Canvas.Font.Color := EntrySettings.ValueLabelColour;
          S := ValueLabelSet.ValueLabelString[FieldEditFromField(TEpiField(CI)).Text];
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

procedure TDataFormFrame.DoCopyToClipBoard;
var
  i: integer;
  Functions: TGetFunctions;
  S: String;
  l: Integer;
  j: Integer;
begin
  Functions := DecodeFormat(EntrySettings.CopyToClipBoardFormat);
  l := Length(Functions);

  S := '';
  for i := 0 to DataFile.Fields.Count -1 do
  begin
    for j := 0 to l - 1 do
    with Functions[j] do
    case FuncType of
      gftIndexedString:
        S += TGetIdxStrFunction(FuncPtr)(EntrySettings.CopyToClipBoardFormat, PGetIdxStrRec(FuncData)^.SIdx, PGetIdxStrRec(FuncData)^.EIdx);
      gftFieldEdit:
        S += TGetFEFunction(FuncPtr)(FieldEditFromField(DataFile.Field[i]));
    end;
  end;
  Clipboard.AsText := S;
end;

procedure TDataFormFrame.DoPerformSearch(Search: TEpiSearch; Idx: Integer;
  Wrap: boolean);
var
  H: THintWindow;
  R: TRect;
  P: TPoint;
begin
  if not Assigned(Search) then exit;

  case Search.Origin of
    soBeginning: Idx := 0;
    soEnd:       Idx := Search.DataFile.Size - 1;
  end;

  idx := SearchFindNext(Search, Idx);
  if idx <> -1 then
    RecNo := idx
  else if wrap then begin
    case Search.Direction of
      sdForward:  Idx := 0;
      sdBackward: Idx := FDataFile.Size - 1;
    end;
    Idx := SearchFindNext(Search, Idx);
    if idx <> -1 then
    begin
      RecNo := idx;
      ShowHintMsg('Wrapped search. Reached end of datafile', RecordEdit);
    end;
  end else begin
    ShowHintMsg('No records found', RecordEdit);
  end;
end;

function TDataFormFrame.CreateSearchFromFieldEdits: TEpiSearch;
var
  SC: TEpiSearchCondition;
  i: Integer;
begin
  // Search is saved in FRecentSearch!
  Result := TEpiSearch.Create;
  Result.DataFile := DataFile;
  Result.Direction := sdForward;
  Result.Origin := soBeginning;

  for i := 0 to FieldEditList.Count - 1 do
  with TFieldEdit(FieldEditList[i]) do
  begin
    if (Field.FieldType in AutoFieldTypes) or
       (Field.RepeatValue) or
       (Field.HasDefaultValue) or
       (Text = '')
       then continue;

    SC := TEpiSearchCondition.Create;
    SC.BinOp := boAnd;
    SC.Field := Field;
    SC.Text := Text;
    SC.CaseSensitive := false;
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
  L: TStringList;
  i: Integer;
  FieldList: TEpiFields;
begin
  try
    SF := TSearchForm1.Create(Self, DataFile);

    L := nil;
    if Assigned(Search) then
    begin
      L := TStringList.Create;
      for i := 0 to Search.List.Count - 1 do
      with Search.SearchCondiction[i] do
        L.AddObject(Text, Field);
    end;

    SF.ActiveFields := L;
    Res := SF.ShowModal;
    if Res = mrCancel then exit;

    if Res = mrFind then
    begin
      // Find single record.
      FRecentSearch := SF.Search;
      DoPerformSearch(SF.Search, Min(RecNo, FDataFile.Size), false);
    end;
    if res = mrList then
    begin
      FieldList := TEpiFields.Create(nil);
      for i := 0 to FieldEditList.Count - 1 do
        FieldList.AddItem(TFieldEdit(FieldEditList[i]).Field);

      FRecentSearch := nil;
      List := SearchFindList(SF.Search, Min(RecNo, FDataFile.Size));
      if Length(List) = 0 then exit;

      ShowResultListForm(
          Self,
          'Showing results for: ' + SF.SearchLabel.Caption,
          DataFile,
          FieldList,
          List);
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
begin
  Result := -1;

  S := TEpiSearch.Create;
  S.DataFile := DataFile;
  S.Direction := sdForward;
  S.Origin := soBeginning;
  for i := 0 to DataFile.KeyFields.Count - 1 do
  begin
    Txt := FieldEditFromField(DataFile.KeyFields[i]).Text;
    if Txt <> '' then
    begin
      C := TEpiSearchCondition.Create;
      C.BinOp := boAnd;
      C.MatchCriteria := mcEq;
      C.Text := Txt;
      C.Field := DataFile.KeyFields[i];
      S.List.Add(C);
    end;
  end;
  if (S.ConditionCount = DataFile.KeyFields.Count) then
    Result := SearchFindNext(S, 0);

  S.Free;
end;

procedure TDataFormFrame.LMGotoRec(var Msg: TLMessage);
var
  F: TEpiField;
  FE: TFieldEdit;
begin
  // WParam = RecordNo
  // LParam = Field (or nil)
  RecNo := Msg.WParam;
  FirstFieldAction.Execute;

  F := TEpiField(Msg.LParam);
  if Assigned(F) then
  begin
    FE := FieldEditFromField(F);
    if FE.CanFocus then
      FE.SetFocus;
  end;
end;

procedure TDataFormFrame.ShowNotes(FE: TFieldEdit; ForceShow: boolean);
var
  R: TRect;
  P: TPoint;
  NoteText: String;
  Rep: TNotesReport;
  Lines: TStringList;
  I: Integer;
begin
  NoteText := FE.Field.Notes.Text;
  if (NoteText = '') and
//     Assigned(FE.Field.ValueLabelSet) and
     (not FE.Field.ForcePickList) and
     (EntrySettings.ValueLabelsAsNotes)
  then
  begin
    Lines := TStringList.Create;
    Lines.StrictDelimiter := true;
    Lines.Delimiter := #1;

    Rep := TNotesReport.Create(TEpiReportTXTGenerator);
    Rep.Field := FE.Field;
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
    P := FE.ClientToScreen(Point(0,0));
    OffsetRect(R, P.X + FE.Width + 2, P.Y);
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
begin
  // Add text to auto field with Update mode set.
  for i := 0 to FieldEditList.Count - 1 do
  with TFieldEdit(FieldEditList[i]) do
  begin
    // Check for AutoInc/Today fields.
    if (Field is TEpiCustomAutoField) and
       ((TEpiCustomAutoField(Field).AutoMode = umUpdated) or
        ((TEpiCustomAutoField(Field).AutoMode = umFirstSave) and (RecNo = NewRecord))
       )
    then with Field do
    begin
      case FieldType of
        ftDMYAuto: Text := FormatDateTime('DD/MM/YYYY', Date);
        ftMDYAuto: Text := FormatDateTime('MM/DD/YYYY', Date);
        ftYMDAuto: Text := FormatDateTime('YYYY/MM/DD', Date);
        ftTimeAuto:  Text := FormatDateTime('HH:NN:SS',   Now);
      end;
    end;
  end;

  // Expand datafile so that current text can be commited...
  if RecNo = NewRecord then
    DataFile.NewRecords();
  for i := 0 to FFieldEditList.Count - 1 do
    TFieldEdit(FFieldEditList[i]).Commit;
  Modified := false;
end;

procedure TDataFormFrame.UpdateSettings;
var
  i: Integer;
begin
  UpdateShortCuts;
  UpdateNotesHints;

  if Assigned(DataFile) then
    for i := 0 to DataFile.ControlItems.Count - 1 do
      if Supports(ControlFromEpiControl(DataFile.ControlItems[i]), IEntryControl) then
        (ControlFromEpiControl(DataFile.ControlItems[i]) as IEntryControl).UpdateSettings;
end;

class procedure TDataFormFrame.RestoreDefaultPos(F: TDataFormFrame);
begin
  if Assigned(F) then
    TNotesForm.RestoreDefaultPos(F.FNotesForm)
  else
    TNotesForm.RestoreDefaultPos();

  TSearchForm1.RestoreDefaultPos;
  TValueLabelsPickListForm.RestoreDefaultPos;

  ResultListFormDefaultPosition();
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
    mrNo:     ; // Do nothing
  end;
end;

function TDataFormFrame.NextUsableFieldIndex(const Index: integer;
  const Wrap: boolean): integer;
begin
  // Assume Index is always valid (or -1 to get the first field).
  Result := Index + 1;

  if (Result >= FieldEditList.Count) and Wrap then
    Result := 0;

  while (Result <= (FieldEditList.Count - 1)) and
        ((TFieldEdit(FieldEditList[Result]).Field.FieldType in AutoFieldTypes) or
         (not TFieldEdit(FieldEditList[Result]).Enabled)) do
  begin
    inc(Result);
    if (Result >= FieldEditList.Count) and Wrap then
      Result := 0;
  end;
  if Result >= FieldEditList.Count then
    Result := -1;
end;

function TDataFormFrame.PrevNonAutoFieldIndex(const Index: integer;
  const Wrap: boolean): integer;
begin
  // Assume Index is always valid (or FieldEditList.Count to get last field).
  Result := Index - 1;

  if (Result < 0) and Wrap then
    Result := FieldEditList.Count - 1;

  while (Result >= 0) and
        ((TFieldEdit(FieldEditList[Result]).Field.FieldType in AutoFieldTypes) or
         (not TFieldEdit(FieldEditList[Result]).Enabled)) do
  begin
    dec(Result);
    if (Result < 0) and Wrap then
      Result := FieldEditList.Count - 1;
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
  FieldEdit: TFieldEdit absolute Sender;
  NextFieldEdit: TFieldEdit;
  Res: TFieldExitFlowType;
  CRecNo: Integer;


  function NextFieldOnKeyDown: TFieldEdit;
  var
    Idx: LongInt;
  begin
    Result := nil;
    Idx := NextUsableFieldIndex(FieldEditList.IndexOf(FieldEdit), false);
    if Idx = -1 then
    begin
      if (RecNo = NewRecord) or (RecNo = (DataFile.Size - 1))  then
        exit
      else begin
        NextRecAction.Execute;
        Idx := NextUsableFieldIndex(-1, false);
      end
    end;
    if Idx = -1 then ; // TODO : This should never happend?
    result := TFieldEdit(FieldEditList[Idx]);
  end;

  function PrevFieldOnKeyDown: TFieldEdit;
  var
    Idx: LongInt;
  begin
    Result := nil;
    Idx := PrevNonAutoFieldIndex(FieldEditList.IndexOf(FieldEdit), false);
    if Idx = -1 then exit;
    Result := TFieldEdit(FieldEditList[Idx]);
  end;

begin
  // Jumps backward though fields.
  if ((Key = VK_UP) and (Shift = [])) or
     ((Key = VK_TAB) and (Shift = [ssShift]))
  then
  Begin
    if not FieldValidate(FieldEdit) then exit;

    NextFieldEdit := PrevFieldOnKeyDown;
    if Assigned(NextFieldEdit) then
      NextFieldEdit.SetFocus;
    Key := VK_UNKNOWN;
  end;

  // Leave field or see pick-list.
  if (Key in [VK_RETURN, VK_TAB, VK_DOWN,
              VK_ADD, VK_F9, VK_OEM_PLUS])
  then begin
    if (Key in [VK_ADD, VK_F9, VK_OEM_PLUS]) and
       (not Assigned(FieldEdit.Field.ValueLabelSet)) then exit;

    if (Key in [VK_ADD, VK_F9, VK_OEM_PLUS]) and
       (Assigned(FieldEdit.Field.ValueLabelSet)) and
       (not ShowValueLabelPickList(FieldEdit)) then
    begin
      Key := VK_UNKNOWN;
      exit;
    end;

    if not FieldValidate(FieldEdit, false) then
    begin
      Key := VK_UNKNOWN;
      exit;
    end;

    // Field is validated - check for Valuelabels and update FieldEdit.
    FieldEdit.UpdateSettings;

    Res := FieldExitFlow(FieldEdit, NextFieldEdit);
    case Res of
      fxtOk:    NextFieldEdit := NextFieldOnKeyDown;
      fxtError: begin
                  Key := VK_UNKNOWN;
                  Exit;
                end;
      fxtJump:  ; // Do nothing - NextFieldEdit is set.
    end;

    if not Assigned(NextFieldEdit) then
    begin
      // NextFieldEdit = nil => either do a new record (if this is a new record or last record)
      //                        or increment record no...
      if (RecNo = NewRecord) or
         (RecNo = (FDataFile.Size - 1))
      then
      begin
        if not DoNewRecord then exit;
      end else
      begin
        CRecNo := RecNo;
        RecNo := RecNo + 1;
        // if the recno was not changed a validation failed, hence do not
        // shift focus field, etc...
        if CRecNo = RecNo then exit;
      end;
      NextFieldEdit := TFieldEdit(FieldEditList[NextUsableFieldIndex(-1, false)]);
    end;
    FieldEnterFlow(NextFieldEdit);
    NextFieldEdit.SetFocus;
    Key := VK_UNKNOWN;
  end;
end;

procedure TDataFormFrame.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FieldEdit: TFieldEdit absolute Sender;
begin
  if FieldEdit.Modified then Modified := true;

  if (FieldEdit.JumpToNext) and (not FieldEdit.Field.ConfirmEntry) then
  begin
    Key := VK_RETURN;
    FieldEdit.OnKeyDown(FieldEdit, Key, []);
    FieldEdit.JumpToNext := false;
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
  FieldEdit: TFieldEdit absolute sender;
  FieldTop: LongInt;
  Delta: Integer;
begin
  // Occurs whenever a field recieves focus
  // - eg. through mouseclik, tab or move.
  FieldTop := FieldEditTop(FieldEdit);
  Delta := DataFormScroolBox.Height div 4;

  With DataFormScroolBox.VertScrollBar do
  begin
    if FieldTop < (Position + Delta) then
      Position := FieldTop - Delta;

    if FieldTop > (Position + Page - Delta) then
      Position := FieldTop - Page + FieldEdit.Height + Delta;
  end;

  FieldEdit.Color := EntrySettings.ActiveFieldColour;
  UpdateFieldPanel(FieldEdit.Field);
  ShowNotes(FieldEdit);
end;

procedure TDataFormFrame.FieldExit(Sender: TObject);
var
  FieldEdit: TFieldEdit absolute Sender;
begin
  if FieldEdit.Field.EntryMode = emMustEnter then
    FieldEdit.Color := EntrySettings.MustEnterFieldColour
  else
    FieldEdit.Color := EntrySettings.InactiveFieldColour;
  FieldValidate(FieldEdit);
end;

procedure TDataFormFrame.FieldEnterFlow(FE: TFieldEdit);
var
  Field: TEpiField;
begin
  // *************************************
  // **    EpiData Flow Control (Pre)   **
  // *************************************
  // Should all these things happen each time, or only first time
  //   field is entered.


  Field := FE.Field;
  // Before field script:
  // TODO : Before field script

  // Top-of-screen?


  // TORSTEN Okt. 2012:
  // Due to the flow of event, it is nessesary to check if a Project
  // is being opened - else a bug occurs where the Picklist form is
  // shown before the Dataform is loaded.
  // Force Show Picklist.
  if (FE.Text = '') and
     (Assigned(Field.ValueLabelSet)) and
     (Field.ForcePickList)
  then
    if not FLoadingDatafile then
      PostMessage(FE.Handle, CN_KEYDOWN, VK_F9, 0);
end;

function TDataFormFrame.FieldExitFlow(FE: TFieldEdit; out
  NewFieldEdit: TFieldEdit): TFieldExitFlowType;
var
  Field: TEpiField;
  Jump: TEpiJump;
  Idx: LongInt;
  Section: TEpiSection;
  EIdx: LongInt;
  NewField: TEpiField;
  Err: string;
  ErrFieldEdit: TFieldEdit;
  Txt: String;
  OldText: TCaption;
  CheckUnique: Boolean;

  procedure PerformJump(Const StartIdx, EndIdx: LongInt; ResetType: TEpiJumpResetType);
  var
    i: LongInt;
    Cnt: Integer;
    j: Integer;
    CachedVLS: TEpiValueLabelSet;
    CachedVL: TEpiCustomValueLabel;
  begin
    if ResetType = jrLeaveAsIs then exit;

    CachedVLS := nil;
    for i := StartIdx to EndIdx do
    with TFieldEdit(FieldEditList[i]) do
    begin
      if Field.FieldType in AutoFieldTypes then continue;

      case ResetType of
        jrSystemMissing: Text := '.';
        jrMaxMissing:    with Field do
                         begin
                           if not Assigned(ValueLabelSet) then continue;

                           // A little cacheing make it faster, works well if
                           // lots of fields use the same VLSet.
                           if CachedVLS = ValueLabelSet then
                             Text := CachedVL.ValueAsString
                           else begin
                             for j := ValueLabelSet.Count - 1 downto 0 do
                             with ValueLabelSet[j] do
                             begin
                               if IsMissingValue then
                               begin
                                 CachedVLS := ValueLabelSet;
                                 CachedVL := ValueLabelSet[j];
                                 Text := ValueAsString;
                                 Break;
                               end;
                             end;
                           end;
                         end;
        jr2ndMissing:    with Field do
                         begin
                           if not Assigned(ValueLabelSet) then continue;

                           // A little cacheing make it faster, works well if
                           // lots of fields use the same VLSet.
                           if CachedVLS = ValueLabelSet then
                             Text := CachedVL.ValueAsString
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
                                 Text := ValueAsString;
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
  Field := FE.Field;


  // Key Unique
  if (DataFile.KeyFields.Count > 0) and
     (DataFile.KeyFields.FieldExists(Field)) then
  begin
    if not PerformKeyFieldsCheck then
      Exit(fxtError);
  end;

  // Comparison
  if Assigned(Field.Comparison) then
  begin
    NewFieldEdit := FieldEditFromField(Field.Comparison.CompareField);
    if not FE.CompareTo(NewFieldEdit.Text, Field.Comparison.CompareType) then
    begin
      Err := Format(
        'Comparison failed:' + LineEnding +
        '%s: %s  %s  %s: %s',
        [Field.Name, FE.Text, ComparisonTypeToString(Field.Comparison.CompareType),
         NewFieldEdit.Field.Name, NewFieldEdit.Text]);
      FieldValidateError(FE, Err);
      Exit(fxtError);
    end;
  end;

  // Type Comment
  if Assigned(Field.ValueLabelWriteField) then
  begin
    NewFieldEdit := FieldEditFromField(Field.ValueLabelWriteField);
    OldText := NewFieldEdit.Text;
    NewFieldEdit.Text := Field.ValueLabelSet.ValueLabelString[FE.Text];
    if OldText <> NewFieldEdit.Text then
      Modified := true;
  end;

  // After Entry Script (Calculation)
  if Assigned(Field.Calculation) then
  begin
    NewFieldEdit := FieldEditFromField(Field.Calculation.ResultField);
    Err := '';
    OldText := NewFieldEdit.Text;
    case Field.Calculation.CalcType of
      ctTimeDiff:      Txt := CalcTimeDiff(TEpiTimeCalc(Field.Calculation));
      ctCombineDate:   Txt := CalcCombineDate(TEpiCombineDateCalc(Field.Calculation), Err, ErrFieldEdit);
      ctCombineString: Txt := CalcCombineString(TEpiCombineStringCalc(Field.Calculation));
    end;
    if (Txt <> TEpiStringField.DefaultMissing)
    then
      NewFieldEdit.Text := Txt;

    if Err <> '' then
    begin
      ErrFieldEdit.SetFocus;
      FieldValidateError(ErrFieldEdit, Err);
      Exit(fxtError);
    end;
    if OldText <> NewFieldEdit.Text then
      Modified := true;
  end;


  // Jumps
  NewFieldEdit := nil;
  if Assigned(Field.Jumps) then
  begin
    Idx := FieldEditList.IndexOf(FE);
    Txt := FE.Text;
    if Txt = '' then Txt := '.';
    Jump := Field.Jumps.JumpFromValue[Txt];
    if Assigned(Jump) then
    begin
      case Jump.JumpType of
        jtSaveRecord:    begin
                           PerformJump(Idx + 1, FieldEditList.Count - 1, Jump.ResetType);
                         end;
        jtExitSection:   begin
                           Section := Field.Section;
                           if Section = DataFile.MainSection then
                           begin
                             EIdx := FieldEditList.Count;
                             PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                           end else begin
                             EIdx := Idx + 1;
                             while (EIdx < FieldEditList.Count) and (EIdx <> -1) and
                                   (TFieldEdit(FieldEditList[EIdx]).Field.Section = Section) do
                               EIdx := NextUsableFieldIndex(EIdx, false);
                             if EIdx = -1 then EIdx := FieldEditList.Count;
                             PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                             // Making this check also forces a "new record" event since NewFieldEdit = nil;
                             if EIdx < FieldEditList.Count then
                               NewFieldEdit := TFieldEdit(FieldEditList[EIdx]);
                           end;
                         end;
        jtSkipNextField: begin
                           EIdx := NextUsableFieldIndex(Idx + 1, false);
                           if EIdx = -1 then EIdx := FieldEditList.Count;
                           PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                           if EIdx < FieldEditList.Count then
                             NewFieldEdit := TFieldEdit(FieldEditList[EIdx]);
                           // A "DoNewRecord" is performed if no NewFieldEdit is assigned
                           // as is the case if SkipNextField is perform on second-last field.
                           {
                           else
                             NewRecordAction.Execute;}
                         end;
        jtToField:       begin
                           NewField := Jump.JumpToField;
                           EIdx := Idx + 1;
                           while (EIdx < FieldEditList.Count) and (EIdx <> -1) and
                                 (TFieldEdit(FieldEditList[EIdx]).Field <> NewField) do
                             EIdx := NextUsableFieldIndex(EIdx, false);

                           if EIdx = -1 then EIdx := FieldEditList.Count;
                           if Eidx >= FieldEditList.Count then exit;

                           PerformJump(Idx + 1, EIdx - 1, Jump.ResetType);
                           NewFieldEdit := TFieldEdit(FieldEditList[EIdx]);
                         end;
      end;
      Exit(fxtJump);
    end;
  end;
end;

function TDataFormFrame.AllFieldsValidate(IgnoreMustEnter: boolean): boolean;
var
  i: Integer;
begin
  result := true;

  // Regular check on Syntax Etc.
  for i := 0 to FieldEditList.Count - 1 do
    if not FieldValidate(TFieldEdit(FieldEditList[i]), IgnoreMustEnter) then exit(false);

  // Additional check for KeyFields consistency.
  if DataFile.KeyFields.Count > 0 then
  begin
    i := DoSearchKeyFields;
    // if i = -1 then keys do not exists,
    // if i = RecNo then current records is found in the search, which is ok
    result := (i = -1) or (i = RecNo);
  end;
end;

function TDataFormFrame.FieldValidate(FE: TFieldEdit; IgnoreMustEnter: boolean
  ): boolean;

  procedure DoError(LocalFE: TFieldEdit);
  begin
    LocalFE.Color := EntrySettings.ValidateErrorColour;
    LocalFE.SelectAll;
    if LocalFE.Enabled then
      LocalFE.SetFocus;
    Beep;
  end;

  procedure NotifyFieldEditKeyDown;
  begin
    Application.QueueAsyncCall(@ASyncKeyDown, KeyDownData(FE, VK_F9, []));
  end;

var
  F: TEpiField;
begin
  FE.JumpToNext := false;
  FE.SelLength := 0;
  F := FE.Field;

  Result := FE.ValidateEntry;
  if not Result then
  begin
    DoError(FE);
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
     (FE.Text = '') then
  begin
    DoError(FE);
    FieldValidateError(FE, 'Field cannot be empty!');
    if Assigned(F.ValueLabelSet) and
       (not Assigned(F.Ranges))
    then
      NotifyFieldEditKeyDown;
    Result := false;
  end;
end;

procedure TDataFormFrame.FieldValidateError(Sender: TObject; const Msg: string
  );
var
  FE: TFieldEdit absolute Sender;
begin
  ShowHintMsg(Msg, FE);
end;

procedure TDataFormFrame.UpdateFieldPanel(Field: TEpiField);
var
  S: String;
begin
  with Field do
  begin
    FieldNameLabel.Caption := Name;
    FieldTypeLabel.Caption := EpiTypeNames[FieldType];
    FieldInfoLabel.Caption := '';

    // The three following if's should automatically be mutally exclusive... (date/time fields cannot have a valuelabel).
    if FieldType in DateFieldTypes then
      FieldInfoLabel.Caption := 'Current date: +';

    if FieldType in TimeFieldTypes then
      FieldInfoLabel.Caption := 'Current time: +';

    if Assigned(ValueLabelSet) then
      FieldInfoLabel.Caption := 'Label: +/F9';

    S := 'Length: ';
    if FieldType in FloatFieldTypes then
      S += IntToStr(Length - Decimals - 1) + '.' + IntToStr(Decimals)
    else
      S += IntToStr(Length);
    FieldLengthLabel.Caption := S;

    if Assigned(Ranges) then
      FieldRangeLabel.Caption := Ranges[0].AsString[true] + '-' + Ranges[0].AsString[false]
    else
      FieldRangeLabel.Caption := '';
  end;
end;

function TDataFormFrame.ShowValueLabelPickList(AFieldEdit: TFieldEdit): boolean;
var
  VLForm: TValueLabelsPickListForm;
  P: TPoint;
begin
  if Assigned(FHintWindow) then FHintWindow.Hide;
  if Assigned(FNotesForm) then FNotesForm.Hide;

  ShowHintMsg('', nil);
  FNotesHint.Hide;

  VLForm := TValueLabelsPickListForm.Create(Self, AFieldEdit.Field);
  VLForm.SetInitialValue(AFieldEdit.Text);
  P := AFieldEdit.Parent.ClientToScreen(Point(AFieldEdit.Left + AFieldEdit.Width + 2, AFieldEdit.Top));
  VLForm.Top := P.Y;
  VLForm.Left := P.X;
  result := VLForm.ShowModal = mrOK;
  if Result then
    AFieldEdit.Text := VLForm.SelectedValueLabel.ValueAsString;
  VLForm.Free;
end;

constructor TDataFormFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FFieldEditList := TFPList.Create;
  FHintWindow := nil;
  FRecNo := -1;

  {$IFNDEF EPI_DEBUG}
  Panel1.Hide;
  {$ENDIF}

  UpdateSettings;
end;


end.

