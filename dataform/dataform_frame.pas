unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, epidatafiles,
  epicustombase, StdCtrls, ExtCtrls, Buttons, ActnList, LCLType;

type

  { TDataFormFrame }

  TDataFormFrame = class(TFrame)
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
    procedure LastFieldActionExecute(Sender: TObject);
    procedure LastRecActionExecute(Sender: TObject);
    procedure LastRecActionUpdate(Sender: TObject);
    procedure NewRecordActionExecute(Sender: TObject);
    procedure NextFieldActionExecute(Sender: TObject);
    procedure NextRecActionExecute(Sender: TObject);
    procedure PrevFieldActionExecute(Sender: TObject);
    procedure PrevRecActionExecute(Sender: TObject);
    procedure RecordEditEditingDone(Sender: TObject);
    procedure RecordEditEnter(Sender: TObject);
  private
    FDataFile: TEpiDataFile;
    FFieldEditList: TFpList;
    FRecNo: integer;
    procedure SetDataFile(const AValue: TEpiDataFile);
    procedure LoadRecord(RecordNo: Integer);
    procedure UpdateRecordEdit;
    procedure SetRecNo(AValue: integer);
    procedure SetModified(const AValue: boolean);
    function  CheckRecordModified(Const IsNewRecord: boolean): Word;
  private
    { Field Entry Handling }
    function  NextNonAutoFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    function  PrevNonAutoFieldIndex(Const Index: integer; Const Wrap: boolean): integer;
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldEnter(Sender: TObject);
    procedure FieldExit(Sender: TObject);
  private
    FModified: boolean;
    { DataForm Control }
    function  FieldEditTop(LocalCtrl: TControl): integer;
    function  NewSectionControl(EpiControl: TEpiCustomControlItem): TControl;
    function  NewFieldControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
    function  NewHeadingControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
  public
    constructor Create(TheOwner: TComponent); override;
    property  DataFile: TEpiDataFile read FDataFile write SetDataFile;
    property  RecNo: integer read FRecNo write SetRecNo;
    property  Modified: boolean read FModified write SetModified;
    property  FieldEditList: TFpList read FFieldEditList;
  end;

implementation

{$R *.lfm}

uses
  fieldedit, epidatafilestypes, LCLProc,
  main, Menus, Dialogs;

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
  (Sender as TAction).Enabled := RecNo > 0;
end;

procedure TDataFormFrame.GotoRecordActionExecute(Sender: TObject);
begin
  RecordEdit.SetFocus;
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
begin
  if CheckRecordModified(true) = mrCancel then exit;

  // This expands the datafile to prepare for a new record input.
  DataFile.NewRecords;
  LastRecAction.Execute;

  // Check for AutoInc/Today fields.
  for i := 0 to FieldEditList.Count - 1 do
  begin
    if TFieldEdit(FieldEditList[i]).Field.FieldType in AutoFieldTypes then
    begin
      FieldEnter(TFieldEdit(FieldEditList[i]));
    end;
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
  RecNo := RecNo - 1;
end;

procedure TDataFormFrame.RecordEditEditingDone(Sender: TObject);
var
  AValue, Code: integer;
begin
  Val(RecordEdit.Text, AValue, Code);
  if Code <> 0 then exit;

  RecNo := AValue - 1;
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
  result := F1.Top - F2.Top;
  if result = 0 then
    result := F1.Left - F2.Left;
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
    DataFile.NewRecords(1);
  RecNo := (DataFile.Size - 1);
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
  if Modified then
    RecordEdit.Text :=
        Format('%d / %d *', [RecNo + 1, DataFile.Size])
  else
    RecordEdit.Text :=
      Format('%d / %d', [RecNo + 1, DataFile.Size]);

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
  end;
  Result.Parent := DataFormScroolBox;
end;

function TDataFormFrame.NewFieldControl(EpiControl: TEpiCustomControlItem;
  AParent: TWinControl): TControl;
begin
  case TEpiField(EpiControl).FieldType of
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
  end;
  Result.Parent := AParent;
end;

procedure TDataFormFrame.SetRecNo(AValue: integer);
var
  i: Integer;
  Res: LongInt;
begin
  if AValue = FRecNo then exit;
  if AValue >= DataFile.Size then AValue := DataFile.Size - 1;
  if AValue < 0 then AValue := 0;

  // Before setting new record no. do a "ValidateEntry" on the Edit with focus.
  // - this is because when using shortcuts to change record, the active Edit is
  //   not exited, hence not triggering of OnExit event.
  if (MainForm.ActiveControl is TFieldEdit) and
     (not TFieldEdit(MainForm.ActiveControl).ValidateEntry) then exit;

  if CheckRecordModified(false) = mrCancel then exit;

  FRecNo := AValue;
  if DataFile.Size > 0 then
    LoadRecord(AValue);
  UpdateRecordEdit;
//  TFieldEdit(FFieldEditList[0]).SetFocus;
end;

procedure TDataFormFrame.SetModified(const AValue: boolean);
begin
  if FModified = AValue then exit;
  FModified := AValue;
  UpdateRecordEdit;
end;

function TDataFormFrame.CheckRecordModified(const IsNewRecord: boolean): Word;
var
  i: Integer;
begin
  Result := mrYes;

  if Modified or IsNewRecord then
  begin
    if IsNewRecord then
    begin
      Result := MessageDlg('Confirmation',
        'Save Record?',
        mtConfirmation, mbYesNo, 0, mbYes);
      if Result = mrNo then
        Result := mrCancel;
    end
    else
      Result := MessageDlg('Warning',
        'Record is modified.' + LineEnding +
        'Save?',
        mtWarning, mbYesNoCancel, 0, mbCancel);

    if Result = mrCancel then exit;

    if Result = mrYes then
      for i := 0 to FFieldEditList.Count - 1 do
        TFieldEdit(FFieldEditList[i]).Commit;
    Modified := false;
  end;
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
begin
  if ((Key = VK_RETURN) and (Shift = [])) then
  begin
    if NextNonAutoFieldIndex(FieldEditList.IndexOf(FieldEdit), false) = -1 then
      if RecNo = (DataFile.Size - 1) then
        NewRecordAction.Execute
      else begin
        NextRecAction.Execute;
        FirstFieldAction.Execute;
      end
    else
      NextFieldAction.Execute;
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
end;

procedure TDataFormFrame.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FieldEdit: TFieldEdit absolute Sender;
  l: Integer;
begin

  if FieldEdit.Modified then Modified := true;

  { // This sort of works, but a lot of special characters exists
  //  and we cannot capture them all. Is there a better way perhaps
  //  that also ensure legal UTF-8 character can be entered into
  //  string fields.
  if (Key < VK_0) and (Key <> VK_SPACE) then exit;

  if UTF8Length(FieldEdit.Text) = FieldEdit.Field.Length then
  begin
    l := FFieldEditList.IndexOf(FieldEdit)+1;
    if l = FFieldEditList.Count then
    begin
      NextRecAction.Execute;
      Exit;
    end;

    TFieldEdit(FFieldEditList[l]).SetFocus;  // Jump to next control.
  end;   }
end;

procedure TDataFormFrame.FieldEnter(Sender: TObject);
var
  FieldEdit: TFieldEdit absolute Sender;
begin
  // Occurs whenever a field recieves focus
  // - eg. through mouseclik, tab or move.

  if FieldEdit.Top < DataFormScroolBox.VertScrollBar.Position then
    DataFormScroolBox.VertScrollBar.Position := FieldEdit.Top - 5;

  if FieldEdit.Top > (DataFormScroolBox.VertScrollBar.Position + DataFormScroolBox.VertScrollBar.Page) then
    DataFormScroolBox.VertScrollBar.Position := FieldEdit.Top - DataFormScroolBox.VertScrollBar.Page + FieldEdit.Height + 5;



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
      ftAutoInc: ;
      ftDMYToday: FieldEdit.Text := FormatDateTime('DD/MM/YYYY', Date);
      ftMDYToday: FieldEdit.Text := FormatDateTime('MM/DD/YYYY', Date);
      ftYMDToday: FieldEdit.Text := FormatDateTime('YYYY/MM/DD', Date);
      ftTimeNow:  FieldEdit.Text := FormatDateTime('HH:NN:SS',   Now);
    end;
    Self.Modified := true;
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
  end;
end;

function TDataFormFrame.FieldEditTop(LocalCtrl: TControl): integer;
begin
  if LocalCtrl.Parent = DataFormScroolBox then
    exit(LocalCtrl.Top);

  result := LocalCtrl.Top + LocalCtrl.Parent.Top;
end;

constructor TDataFormFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FFieldEditList := TFPList.Create;
  FRecNo := -1;
end;


end.

