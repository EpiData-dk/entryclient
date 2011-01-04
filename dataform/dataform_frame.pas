unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, types, FileUtil, Forms, Controls, epidatafiles,
  epicustombase, StdCtrls, ExtCtrls, Buttons, ActnList, LCLType, fieldedit;

type

  { TDataFormFrame }

  TDataFormFrame = class(TFrame)
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
    PgDnFieldAction: TAction;
    PgUpFieldAction: TAction;
    PrevFieldAction: TAction;
    NextFieldAction: TAction;
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
    procedure NextFieldActionExecute(Sender: TObject);
    procedure NextRecActionExecute(Sender: TObject);
    procedure PageDownActionExecute(Sender: TObject);
    procedure PageUpActionExecute(Sender: TObject);
    procedure PrevFieldActionExecute(Sender: TObject);
    procedure PrevRecActionExecute(Sender: TObject);
    procedure RecordEditEditingDone(Sender: TObject);
    procedure RecordEditEnter(Sender: TObject);
  private
    FDataFile: TEpiDataFile;
    FFieldEditList: TFpList;
    FRecNo: integer;
    FHintWindow: THintWindow;
    procedure SetDataFile(const AValue: TEpiDataFile);
    procedure LoadRecord(RecordNo: Integer);
    procedure UpdateRecordEdit;
    procedure SetRecNo(AValue: integer);
    procedure SetModified(const AValue: boolean);
    function  GetHintWindow: THintWindow;
  private
    { Field Entry Handling }
    function  NextNonAutoFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    function  PrevNonAutoFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldEnter(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure FieldValidateError(Sender: TObject; const Msg: string);
    procedure UpdateFieldPanel(Field: TEpiField);
  private
    { Flow control/Validation/Script handling}
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
  public
    constructor Create(TheOwner: TComponent); override;
    procedure CommitFields;
    property  DataFile: TEpiDataFile read FDataFile write SetDataFile;
    property  RecNo: integer read FRecNo write SetRecNo;
    property  Modified: boolean read FModified write SetModified;
    property  FieldEditList: TFpList read FFieldEditList;
  end;

const
  NewRecord = MaxInt;

implementation

{$R *.lfm}

uses
  epidatafilestypes, LCLProc, settings,
  main, Menus, Dialogs, math, Graphics, epimiscutils,
  picklist;

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
begin
  I := NextNonAutoFieldIndex(-1, false);
  if i = -1 then exit;

  TFieldEdit(FieldEditList[i]).SetFocus;
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
  i: Integer;
  Res: LongInt;
begin
  // Sanity check - current focused field may not have been validated.
  if (MainForm.ActiveControl is TFieldEdit) and
     (not TFieldEdit(MainForm.ActiveControl).ValidateEntry) then exit;

  // *******************
  // * Commit old data *
  // *******************
  if (RecNo <> NewRecord) and Modified then
  begin
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
    if MessageDlg('Confirmation', 'Save Record?',
      mtConfirmation, mbYesNo, 0, mbYes) = mrNo then exit;
    // Commit text to data.
    CommitFields;
  end;

  // **********************************
  // * Prepare system for new record  *
  // **********************************
  RecNo := NewRecord;
  for i := 0 to FieldEditList.Count - 1 do
  with TFieldEdit(FieldEditList[i]) do
  begin
    // Check for AutoInc/Today fields.
    if Field.FieldType in AutoFieldTypes then
      DoEnter;
  end;

  // Set focus to first field.
  FirstFieldAction.Execute;
end;

procedure TDataFormFrame.NextFieldActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if not (MainForm.ActiveControl is TFieldEdit) then exit;

  i := FieldEditList.IndexOf(MainForm.ActiveControl);
  i := NextNonAutoFieldIndex(i, true);

  if i = -1  then exit;
  TFieldEdit(FFieldEditList[i]).SetFocus;  // Jump to next control.
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

procedure TDataFormFrame.PrevFieldActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if not (MainForm.ActiveControl is TFieldEdit) then exit;

  i := FieldEditList.IndexOf(MainForm.ActiveControl);
  i := PrevNonAutoFieldIndex(i, true);

  if i = -1  then exit;
  TFieldEdit(FFieldEditList[i]).SetFocus;  // Jump to prev control.
end;

procedure TDataFormFrame.PrevRecActionExecute(Sender: TObject);
begin
  RecNo := Min(RecNo - 1, DataFile.Size - 1);
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

function FieldSort(Item1, Item2: Pointer): Integer;
var
  F1: TFieldEdit absolute Item1;
  F2: TFieldEdit absolute Item2;
begin
  result := FieldEditTop(F1) - FieldEditTop(F2);
  if result = 0 then
    result := FieldEditLeft(F1) - FieldEditLeft(F2);
end;

procedure TDataFormFrame.SetDataFile(const AValue: TEpiDataFile);
var
  i: Integer;
  TheParent: TWinControl;
  j: Integer;
begin
  if FDataFile = AValue then exit;
  FDataFile := AValue;

  // Create components.
  Name := DataFile.Id;

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
  FirstFieldAction.Execute;
end;

procedure TDataFormFrame.LoadRecord(RecordNo: Integer);
var
  i: Integer;
begin
  for i := 0 to FFieldEditList.Count - 1 do
    TFieldEdit(FFieldEditList[i]).RecNo := RecordNo
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

  if DataFile.Size = 0 then
    RecordEdit.Text := 'Empty';
end;

function TDataFormFrame.NewSectionControl(EpiControl: TEpiCustomControlItem
  ): TControl;
begin
  result := TGroupBox.Create(DataFormScroolBox);

  with EpiControl do
  begin
    Result.Top := Top;
    Result.Left := Left;
    Result.Width := TEpiSection(EpiControl).Width;
    Result.Height := TEpiSection(EpiControl).Height;
    Result.Caption := TEpiSection(EpiControl).Name.Text;
  end;
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
    ftDMYToday,
    ftMDYDate,
    ftMDYToday,
    ftYMDDate,
    ftYMDToday: Result := TDateEdit.Create(AParent);

    ftTimeNow,
    ftTime:     Result := TTimeEdit.Create(AParent);
  end;
  Result.Parent := AParent;

  with TFieldEdit(Result) do
  begin
    Field     := TEpiField(EpiControl);
    OnEnter   := @FieldEnter;
    OnExit    := @FieldExit;
    OnKeyDown := @FieldKeyDown;
    OnKeyUp   := @FieldKeyUp;
    OnValidateError := @FieldValidateError;
  end;

  FFieldEditList.Add(Result);
end;

function TDataFormFrame.NewHeadingControl(EpiControl: TEpiCustomControlItem;
  AParent: TWinControl): TControl;
begin
  Result := TLabel.Create(AParent);

  With TEpiHeading(EpiControl) do
  begin
    Result.Top := Top;
    Result.Left := Left;
    Result.Caption := Caption.Text;
    Result.Font.Style := [fsBold];
  end;
  Result.Parent := AParent;
end;

procedure TDataFormFrame.SetCursor(Value: TCursor);
begin
  DataFormScroolBox.Cursor := Value;
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

  // Before setting new record no. do a "ValidateEntry" on the Edit with focus.
  // - this is because when using shortcuts to change record, the active Edit is
  //   not exited, hence not triggering of OnExit event.
  if (MainForm.ActiveControl is TFieldEdit) and
     (not TFieldEdit(MainForm.ActiveControl).ValidateEntry) then exit;

  if (not (AValue = NewRecord)) and Modified then
  begin
    Res := MessageDlg('Warning',
      'Record is modified.' + LineEnding +
      'Save?',
      mtWarning, mbYesNoCancel, 0, mbCancel);
    case Res of
      mrCancel: Exit;
      mrYes:    begin
                  // if a new record is being edited the datafile has NOT been
                  // expanded at this point.
                  CommitFields;
                end;
      mrNo:     Modified := false; // do nothing.
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
  end;
  FHintWindow.HideInterval := EntrySettings.HintTimeOut * 1000; //TTimer.interval is in millisecs.
  result := FHintWindow;
end;

procedure TDataFormFrame.CommitFields;
var
  i: Integer;
begin
  // Expand datafile so that current text can be commited...
  if RecNo = NewRecord then
    DataFile.NewRecords();
  for i := 0 to FFieldEditList.Count - 1 do
    TFieldEdit(FFieldEditList[i]).Commit;
  Modified := false;
end;

function TDataFormFrame.NextNonAutoFieldIndex(const Index: integer;
  const Wrap: boolean): integer;
begin
  // Assume Index is always valid (or -1 to get the first field).
  Result := Index + 1;

  if (Result >= FieldEditList.Count) and Wrap then
    Result := 0;

  while (Result <= (FieldEditList.Count - 1)) and
        (TFieldEdit(FieldEditList[Result]).Field.FieldType in AutoFieldTypes) do
  begin
    inc(Result);
    if (Result >= FieldEditList.Count) and Wrap then
      Result := 0;
  end;
  if Result = FieldEditList.Count then
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
        (TFieldEdit(FieldEditList[Result]).Field.FieldType in AutoFieldTypes) do
  begin
    dec(Result);
    if (Result < 0) and Wrap then
      Result := FieldEditList.Count - 1;
  end;
end;

procedure TDataFormFrame.FieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FieldEdit: TFieldEdit absolute Sender;

  procedure NextFieldOnKeyDown;
  begin
    if NextNonAutoFieldIndex(FieldEditList.IndexOf(FieldEdit), false) = -1 then
      if (RecNo = NewRecord) or (RecNo = (DataFile.Size - 1))  then
        NewRecordAction.Execute
      else begin
        NextRecAction.Execute;
        FirstFieldAction.Execute;
      end
    else
      NextFieldAction.Execute;
  end;

begin
  GetHintWindow.Hide;

  if ((Key = VK_RETURN) and (Shift = [])) then
  begin
    NextFieldOnKeyDown;
    Key := VK_UNKNOWN;
  end;

  if ((Key = VK_DOWN) and (Shift = []))then
  begin
    NextFieldAction.Execute;
    Key := VK_UNKNOWN;
  end;

  if (Key = VK_UP) and (Shift = []) then
  Begin
    PrevFieldAction.Execute;
    Key := VK_UNKNOWN;
  end;
                             // 187 = Plus sign that is NOT part of numpad!
  if (Key in [VK_ADD, VK_F9, 187]) and (Shift = []) then
  begin
    if Assigned(FieldEdit.Field.ValueLabelSet) and
       ShowValueLabelPickList(FieldEdit) then
      NextFieldOnKeyDown;
    Key := VK_UNKNOWN;
  end;
end;

procedure TDataFormFrame.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FieldEdit: TFieldEdit absolute Sender;
begin
  if FieldEdit.Modified then Modified := true;

  if FieldEdit.JumpToNext then
  begin
    Key := VK_RETURN;
    FieldEdit.OnKeyDown(FieldEdit, Key, []);
    FieldEdit.JumpToNext := false;
    Exit;
  end;
end;

procedure TDataFormFrame.FieldEnter(Sender: TObject);
var
  FieldEdit: TFieldEdit absolute Sender;
  FieldTop: LongInt;
begin
  // Occurs whenever a field recieves focus
  // - eg. through mouseclik, tab or move.

  FieldTop := FieldEditTop(FieldEdit);
  if FieldTop < DataFormScroolBox.VertScrollBar.Position then
    DataFormScroolBox.VertScrollBar.Position := FieldTop - 5;

  if FieldTop > (DataFormScroolBox.VertScrollBar.Position + DataFormScroolBox.VertScrollBar.Page) then
    DataFormScroolBox.VertScrollBar.Position := FieldTop - DataFormScroolBox.VertScrollBar.Page + FieldEdit.Height + 5;

  UpdateFieldPanel(FieldEdit.Field);

  // ********************************
  // **    EpiData Flow Control    **
  // ********************************
  // Should all these things happen each time, or only first time
  //   field is entered.

  // Before field script:
  // TODO : Before field script

  // AutoInc/Today:
  if FieldEdit.Field.FieldType in AutoFieldTypes then
  with FieldEdit.Field do
  begin
    case FieldType of
      ftAutoInc:  FieldEdit.Text := IntToStr(DataFile.Size + 1);    // TODO : Auto increment functionality.
      ftDMYToday: FieldEdit.Text := FormatDateTime('DD/MM/YYYY', Date);
      ftMDYToday: FieldEdit.Text := FormatDateTime('MM/DD/YYYY', Date);
      ftYMDToday: FieldEdit.Text := FormatDateTime('YYYY/MM/DD', Date);
      ftTimeNow:  FieldEdit.Text := FormatDateTime('HH:NN:SS',   Now);
    end;
    Exit;
  end;

  // NoEnter property?


  // Repeat?


  // Top-of-screen?
end;

procedure TDataFormFrame.FieldExit(Sender: TObject);
var
  FE: TFieldEdit absolute sender;
begin
  if not FE.ValidateEntry then
  begin
    FE.SetFocus;
    Beep;
  end else
    GetHintWindow.Hide;
  FE.JumpToNext := false;
  FE.SelLength := 0;
end;

procedure TDataFormFrame.FieldValidateError(Sender: TObject; const Msg: string
  );
var
  FE: TFieldEdit absolute Sender;
  H: THintWindow;
  R: TRect;
  P: TPoint;
begin
  H := GetHintWindow;
  R := H.CalcHintRect(0, Msg, nil);
  P := FE.ClientToScreen(Point(0,0));
  OffsetRect(R, P.X, P.Y + FE.Height);
  H.ActivateHint(R, Msg);
end;

procedure TDataFormFrame.UpdateFieldPanel(Field: TEpiField);
begin
  with Field do
  begin
    FieldNameLabel.Caption := Name;
    FieldTypeLabel.Caption := EpiTypeNames[FieldType];
    if Assigned(ValueLabelSet) then
      FieldInfoLabel.Caption := 'Label: +/F9'
    else
      FieldInfoLabel.Caption := '';
  end;
end;

function TDataFormFrame.ShowValueLabelPickList(AFieldEdit: TFieldEdit): boolean;
var
  VLForm: TValueLabelsPickListForm;
  P: TPoint;
begin
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
end;


end.

