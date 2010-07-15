unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, epidatafiles,
  epicustombase, StdCtrls, ExtCtrls, Buttons, Arrow, ActnList, LCLType;

type

  { TDataFormFrame }

  TDataFormFrame = class(TFrame)
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
    procedure FirstRecActionExecute(Sender: TObject);
    procedure FirstRecActionUpdate(Sender: TObject);
    procedure LastRecActionExecute(Sender: TObject);
    procedure LastRecActionUpdate(Sender: TObject);
    procedure NextRecActionExecute(Sender: TObject);
    procedure PrevRecActionExecute(Sender: TObject);
    procedure RecordEditClick(Sender: TObject);
    procedure RecordEditEditingDone(Sender: TObject);
  private
    FDataFile: TEpiDataFile;
    FFieldEditList: TFpList;
    FRecNo: integer;
    procedure SetDataFile(const AValue: TEpiDataFile);
    procedure LoadRecord(RecordNo: Integer);
    procedure UpdateRecordEdit;
    procedure SetRecNo(AValue: integer);
  private
    { Field Entry Handling }
    procedure FieldEditingDone(Sender: TObject);
    procedure FieldKeyPressUTF8(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { DataForm Control }
    function  NewSectionControl(EpiControl: TEpiCustomControlItem): TControl;
    function  NewFieldControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
    function  NewHeadingControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
  public
    constructor Create(TheOwner: TComponent); override;
    property  DataFile: TEpiDataFile read FDataFile write SetDataFile;
    property  RecNo: integer read FRecNo write SetRecNo;
  end; 

implementation

{$R *.lfm}

uses
  fieldedit, epidatafilestypes, LCLProc, entryprocs,
  main, Menus, LMessages;

{ TDataFormFrame }

procedure TDataFormFrame.FirstRecActionExecute(Sender: TObject);
begin
  RecNo := 0;
end;

procedure TDataFormFrame.FirstRecActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := RecNo > 0;
end;

procedure TDataFormFrame.LastRecActionExecute(Sender: TObject);
begin
  RecNo := DataFile.Size - 1;
end;

procedure TDataFormFrame.LastRecActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := RecNo < (DataFile.Size - 1);
end;

procedure TDataFormFrame.NextRecActionExecute(Sender: TObject);
begin
  RecNo := RecNo + 1;
end;

procedure TDataFormFrame.PrevRecActionExecute(Sender: TObject);
begin
  RecNo := RecNo - 1;
end;

procedure TDataFormFrame.RecordEditClick(Sender: TObject);
begin
  RecordEdit.SelectAll;
end;

procedure TDataFormFrame.RecordEditEditingDone(Sender: TObject);
var
  AValue, Code: integer;
begin
  Val(RecordEdit.Text, AValue, Code);

  if Code <> 0 then exit;

  RecNo := AValue - 1;
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

  RecNo := 0;
end;

procedure TDataFormFrame.LoadRecord(RecordNo: Integer);
var
  i: Integer;
begin
  for i := 0 to FFieldEditList.Count - 1 do
  with TFieldEdit(FFieldEditList[i]) do
  begin
    Text := Field.AsString[RecordNo];
  end;
end;

procedure TDataFormFrame.UpdateRecordEdit;
begin
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
var
  Lbl: TLabel;
begin
  Result := TFieldEdit.Create(AParent);
  Result.Parent := AParent;

  with TFieldEdit(Result) do
  begin
    Field          := TEpiField(EpiControl);
    OnEditingDone  := @FieldEditingDone;
    OnUTF8KeyPress := @FieldKeyPressUTF8;
//    OnKeyPress     := @FieldKeyPress;
    OnKeyDown      := @FieldKeyDown;
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
begin
  if AValue = FRecNo then exit;
  if AValue >= DataFile.Size then AValue := DataFile.Size - 1;
  if AValue < 0 then AValue := 0;

  // Before setting new record no. do a "EditingDone" on the Edit with focus.
  // - this is because when using shortcuts to change record, the active Edit is
  //   not exited, hence editing is not done.
  if MainForm.ActiveControl is TFieldEdit then
    TFieldEdit(MainForm.ActiveControl).EditingDone;


  FRecNo := AValue;
  if DataFile.Size > 0 then
    LoadRecord(AValue);
  UpdateRecordEdit;
  TFieldEdit(FFieldEditList[0]).SetFocus;
end;

procedure TDataFormFrame.FieldEditingDone(Sender: TObject);
var
  FieldEdit: TFieldEdit absolute Sender;
  Field: TEpiField;
begin
  // We don't care if Edit has not been modified.
  if not FieldEdit.Modified then exit;

  // This should verify text for the last time and then
  // write data directly to the TEpiField.
  Field := FieldEdit.Field;

  case Field.FieldType of
    ftInteger: ;
  end;

  Field.AsString[RecNo] := FieldEdit.Text;
end;

procedure TDataFormFrame.FieldKeyPressUTF8(Sender: TObject; var UTF8Key: TUTF8Char
  );
var
  l: LongInt;
  FieldEdit: TFieldEdit absolute Sender;
  Key: Char;
  S: String;
begin
  // Sole purpose of this:
  // - catch UTF8 characters with > 1 byte length, since these are NOT caught in
  //   the non-UTF8 version and cannot therefor be handled.
  //   Luckily enough >1 byte characters will ALWAYS be local string character and
  //   should NEVER be part of fields with types other than string.

  l := Length(UTF8Key);
  if (l > 1) then
  begin
    if not (FieldEdit.Field.FieldType in StringFieldTypes) then
      UTF8Key := '';

    if (FieldEdit.Field.FieldType = ftUpperString) then
      UTF8Key := UTF8UpperCase(UTF8Key);

    exit;
  end;

  Key := UTF8Key[1];
  if Key in SystemChars then
  begin
    exit;
  end;

  with FieldEdit.Field do
  begin
    case FieldType of
      ftInteger: if not(Key in IntegerChars) then Key:=#0;
      ftBoolean: if not(Key in BooleanChars) then Key:=#0;
      ftDMYDate,
      ftMDYDate,
      ftYMDDate: if not(Key in DateChars)    then Key:=#0;
      ftFloat:   begin
                   if not(Key in FloatChars) then Key:=#0;
                   if Key <> #0 then
                   begin
                     S := FieldEdit.Text;
                     if Decimals > 0 then
                     begin
                       if (System.Length(S) = Length - 1 - Decimals) and
                          (Pos('.',S)=0) and (Pos(',',S)=0) and
                          (ORD(Key)<>8) and (Key<>',') and (Key<>'.') then
                       begin
                         FieldEdit.Text:=S + DecimalSeparator;
                         FieldEdit.SelStart := System.Length(FieldEdit.Text);
                       end;
                     end;
                   end;
                 end;
    end;
  end;
  UTF8Key[1] := Key;
end;

procedure TDataFormFrame.FieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  KeyMsg: TLMKey;
begin
  if Key = VK_MENU then exit;
  // Ugly dirty way of capturing shortcuts involving keys.
  // -- send to mainform, it automatically propagetes down through action lists..
  if Key <> VK_UNKNOWN then
  begin
    KeyMsg.Msg := LM_KEYDOWN;
    KeyMsg.KeyData := ShortCut(0, Shift);
    if (ssAlt in Shift) then
      KeyMsg.KeyData := KeyMsg.KeyData or $20000000;
    KeyMsg.CharCode := Key;
    KeyMsg.Result := 0;
    if MainForm.IsShortcut(KeyMsg) then
      Key := VK_UNKNOWN;
  end;
end;

constructor TDataFormFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FFieldEditList := TFPList.Create;
  FRecNo := -1;
end;


end.

