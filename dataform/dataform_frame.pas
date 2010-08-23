unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, epidatafiles,
  epicustombase, StdCtrls, ExtCtrls, Buttons, ActnList, LCLType;

type

  { TDataFormFrame }

  TDataFormFrame = class(TFrame)
    LastRecAction: TAction;
    ListBox1: TListBox;
    NextRecAction: TAction;
    Panel1: TPanel;
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
    Splitter1: TSplitter;
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
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldExit(Sender: TObject);
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
  fieldedit, epidatafilestypes, LCLProc,
  main, Menus, Dialogs;

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
    TFieldEdit(FFieldEditList[i]).RecNo := RecordNo
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
    Field    := TEpiField(EpiControl);
    OnExit   := @FieldExit;
    OnKeyUp  := @FieldKeyUp;
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

  // Before setting new record no. do a "ValidateEntry" on the Edit with focus.
  // - this is because when using shortcuts to change record, the active Edit is
  //   not exited, hence not triggering of OnExit event.
  if (MainForm.ActiveControl is TFieldEdit) and
     (not TFieldEdit(MainForm.ActiveControl).ValidateEntry) then exit;

  FRecNo := AValue;
  if DataFile.Size > 0 then
    LoadRecord(AValue);
  UpdateRecordEdit;
  TFieldEdit(FFieldEditList[0]).SetFocus;
end;

procedure TDataFormFrame.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FieldEdit: TFieldEdit absolute Sender;
  l: Integer;
begin
{  // This sort of works, but a lot of special characters exists
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

procedure TDataFormFrame.FieldExit(Sender: TObject);
begin
  with TFieldEdit(Sender) do
  if not ValidateEntry then
  begin
    SetFocus;
    Beep;
  end;
end;

constructor TDataFormFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FFieldEditList := TFPList.Create;
  FRecNo := -1;
end;


end.

