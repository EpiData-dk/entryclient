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
    FEditingOk: Boolean;
    procedure FieldEditingDone(Sender: TObject);
    procedure FieldKeyPressUTF8(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  if DataFile.Size = 0 then
    DataFile.Size := 10;
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
begin
  Result := TFieldEdit.Create(AParent);
  Result.Parent := AParent;

  with TFieldEdit(Result) do
  begin
    Field          := TEpiField(EpiControl);
    OnEditingDone  := @FieldEditingDone;
    OnUTF8KeyPress := @FieldKeyPressUTF8;
    OnKeyUp        := @FieldKeyUp;
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

  // TODO: Ask for saving current record if things have been modified.

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
  I: EpiInteger;
  D: EpiDate;
  S: String;
begin
  // We don't care if Edit has not been modified.
  if not FieldEdit.Modified then exit;

  // Temporary fix until "New Record" is implemented.
  if DataFile.Size = 0 then exit;

  FEditingOk := False;
  // This should verify text for the last time and then
  // write data directly to the TEpiField.
  Field := FieldEdit.Field;

  case Field.FieldType of
    ftInteger:
      begin
        if not IsEpiInteger(FieldEdit.Text, I) then exit;
        Field.AsInteger[RecNo] := I;
      end;
    ftDMYDate,
    ftMDYDate,
    ftYMDDate:
      begin
        S := FieldEdit.Text;
        if not IsEpiDate(S, D, Field.FieldType) then exit;
        Field.AsDate[RecNo] := D;
      end;
  else
    Field.AsString[RecNo] := FieldEdit.Text;
  end;

  FEditingOk := True;
  FieldEdit.Text := Field.AsString[RecNo];
end;

procedure TDataFormFrame.FieldKeyPressUTF8(Sender: TObject; var UTF8Key: TUTF8Char
  );
var
  l: LongInt;
  FieldEdit: TFieldEdit absolute Sender;
  Key: Char;
  S: String;
begin
  // Purpose of this:
  // - catch UTF8 characters with > 1 byte length, since these are NOT caught in
  //   the non-UTF8 version and cannot therefor be handled there.
  //   Luckily enough >1 byte characters will ALWAYS be string characters and
  //   should NEVER be part of fields with types other than string.
{
  if (FieldEdit.Field.FieldType = ftUpperString) then
    UTF8Key := UTF8UpperCase(UTF8Key);

  l := Length(UTF8Key);
  if (l > 1) then
  begin
    if not (FieldEdit.Field.FieldType in StringFieldTypes) then
      UTF8Key := '';
    exit;
  end;

  Key := UTF8Key[1];
  if Key in SystemChars then
  begin
    if Word(Key) = VK_RETURN then
    begin
      l := FFieldEditList.IndexOf(FieldEdit)+1;
      if l = FFieldEditList.Count then
      begin
        NextRecAction.Execute;
        Exit;
      end;

      TFieldEdit(FFieldEditList[l]).SetFocus;  // Jump to next control.
    end;
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
  UTF8Key[1] := Key;       }
end;

procedure TDataFormFrame.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FieldEdit: TFieldEdit absolute Sender;
  l: Integer;
begin
  // This sort of works, but a lot of special characters exists
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
  end;
end;

constructor TDataFormFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FFieldEditList := TFPList.Create;
  FRecNo := -1;
end;


end.

