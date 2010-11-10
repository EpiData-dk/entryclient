unit picklist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, epidatafiles, epivaluelabels;

type

  { TValueLabelsPickListForm }

  TValueLabelsPickListForm = class(TForm)
    Edit1: TEdit;
    LabelsListBox: TListBox;
    ValueListBox: TListBox;
    Panel1: TPanel;
    procedure Edit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LabelsListBoxDblClick(Sender: TObject);
    procedure LabelsListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LabelsListBoxSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FField: TEpiField;
    FInitialValue: string;
    FSelectedValueLabel: TEpiCustomValueLabel;
    constructor Create(TheOwner: TComponent); override;
    function    LocateListBoxIndex(AListBox: TListBox; Const S: string; Out Idx: integer): boolean;
  protected
    property    Field: TEpiField read FField;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent; Const AField: TEpiField);
    procedure   SetInitialValue(Const S: string);
    property    SelectedValueLabel: TEpiCustomValueLabel read FSelectedValueLabel;
  end; 

implementation

{$R *.lfm}

uses
  math, LCLProc, LCLType;

{ TValueLabelsPickListForm }

procedure TValueLabelsPickListForm.FormShow(Sender: TObject);
var
  W: LongInt;
  i: Integer;
begin
  if not Assigned(Field.ValueLabelSet) then exit;

  W := 25;
  for i := 0 to Field.ValueLabelSet.Count - 1 do
  with Field do
  begin
    ValueListBox.Items.AddObject(ValueLabelSet[i].ValueAsString, ValueLabelSet[i]);
    W := Max(W, 6 + ValueListBox.Canvas.TextWidth(ValueLabelSet[i].ValueAsString) + 6);
    LabelsListBox.Items.AddObject(ValueLabelSet[i].TheLabel.Text, ValueLabelSet[i]);
  end;
  ValueListBox.Width := W;

  Edit1.Text := FInitialValue;
end;

procedure TValueLabelsPickListForm.Edit1Change(Sender: TObject);
var
  S: String;
  I: LongInt;
  Idx: Integer;
begin
  S := UTF8UpperCase(TEdit(Sender).Text);

  if LocateListBoxIndex(ValueListBox, S, Idx) then
  begin
    ValueListBox.ItemIndex := Idx;
    exit;
  end;

  if LocateListBoxIndex(LabelsListBox, S, Idx) then
  begin
    LabelsListBox.ItemIndex := Idx;
    exit;
  end;

  LabelsListBox.ItemIndex := -1;
end;

procedure TValueLabelsPickListForm.LabelsListBoxDblClick(Sender: TObject);
var
  SenderList: TListBox absolute Sender;
begin
  ModalResult := mrOK;
  Close;
end;

procedure TValueLabelsPickListForm.LabelsListBoxKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  S: String;
  Idx: integer;
begin
  if (Key in [VK_CANCEL, VK_ESCAPE]) and (Shift = []) then ModalResult := mrCancel;

  if (Sender = Edit1) and
     (Key = VK_RETURN) and
     (Shift = []) then
  begin
    S := UTF8UpperCase(TEdit(Sender).Text);
    if (LocateListBoxIndex(ValueListBox, S, Idx)) or
       (LocateListBoxIndex(LabelsListBox, S, Idx)) then
      ModalResult := mrOK;
  end;

  if (Sender <> Edit1) and
     (Key = VK_RETURN) and
     (Shift = []) then ModalResult := mrOK;
end;

procedure TValueLabelsPickListForm.LabelsListBoxSelectionChange(
  Sender: TObject; User: boolean);
var
  SenderList: TListBox absolute Sender;
begin
  ValueListBox.ItemIndex := SenderList.ItemIndex;
  LabelsListBox.ItemIndex := SenderList.ItemIndex;
  if SenderList.ItemIndex >= 0 then
    FSelectedValueLabel := TEpiCustomValueLabel(SenderList.Items.Objects[SenderList.ItemIndex]);
end;

constructor TValueLabelsPickListForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
end;

function TValueLabelsPickListForm.LocateListBoxIndex(AListBox: TListBox;
  const S: string; Out Idx: integer): boolean;
var
  I: Integer;
begin
  for I := 0 to AListBox.Items.Count - 1 do
    if Pos(S, UTF8UpperCase(AListBox.Items[I])) = 1 then
    begin
      Idx := I;
      Exit(true);
    end;
  Idx := -1;
  result := False;
end;

constructor TValueLabelsPickListForm.Create(TheOwner: TComponent; const AField: TEpiField);
begin
  Create(TheOwner);
  FField := AField;
end;

procedure TValueLabelsPickListForm.SetInitialValue(const S: string);
begin
  FInitialValue := S;
end;

end.

