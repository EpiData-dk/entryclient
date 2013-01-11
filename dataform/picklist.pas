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
    Splitter1: TSplitter;
    ValueListBox: TListBox;
    Panel1: TPanel;
    procedure Edit1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure LabelsListBoxDblClick(Sender: TObject);
    procedure LabelsListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LabelsListBoxSelectionChange(Sender: TObject; User: boolean);
  private
    { private declarations }
    FUpdatingListBox: boolean;
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
    class procedure RestoreDefaultPos;
    procedure   SetInitialValue(Const S: string);
    property    SelectedValueLabel: TEpiCustomValueLabel read FSelectedValueLabel;
  end; 

implementation

{$R *.lfm}

uses
  math, LCLProc, LCLType, settings;

{ TValueLabelsPickListForm }

procedure TValueLabelsPickListForm.FormShow(Sender: TObject);
var
  W: LongInt;
  i: Integer;
begin
  if not Assigned(Field.ValueLabelSet) then exit;
  LoadFormPosition(Self, 'PickListForm');

  W := 25;
  for i := 0 to Field.ValueLabelSet.Count - 1 do
  with Field do
  begin
    ValueListBox.Items.AddObject(ValueLabelSet[i].ValueAsString, ValueLabelSet[i]);
    W := Max(W, 6 + ValueListBox.Canvas.TextWidth(ValueLabelSet[i].ValueAsString) + 6);
    LabelsListBox.Items.AddObject(ValueLabelSet[i].TheLabel.Text, ValueLabelSet[i]);
  end;
  ValueListBox.ScrollWidth := W;

  Panel1.Height := {$IFNDEF MSWINDOWS}26{$ELSE}24{$ENDIF};

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

procedure TValueLabelsPickListForm.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  CanClose := true;
  SaveFormPosition(Self, 'PickListForm');
end;

procedure TValueLabelsPickListForm.LabelsListBoxDblClick(Sender: TObject);
var
  SenderList: TListBox absolute Sender;
begin
  ModalResult := mrOK;
end;

procedure TValueLabelsPickListForm.LabelsListBoxKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  S: String;
  Idx: integer;
begin
  if (Key in [VK_CANCEL, VK_ESCAPE]) and (Shift = []) then ModalResult := mrCancel;

  if (Sender = Edit1) then
  begin
    if (Key = VK_RETURN) and (Shift = []) then
    begin
      S := UTF8UpperCase(TEdit(Sender).Text);
      if (LocateListBoxIndex(ValueListBox, S, Idx)) or
         (LocateListBoxIndex(LabelsListBox, S, Idx)) then
        ModalResult := mrOK;
    end;

    if (Key = VK_DOWN) and (Shift = []) then
    begin
      ValueListBox.SetFocus;
      if ValueListBox.ItemIndex = -1 then
        ValueListBox.ItemIndex := 0;
      Key := VK_UNKNOWN;
    end;
  end;

  if (Sender <> Edit1) then
  begin
     if (Key = VK_RETURN) and (Shift = []) then ModalResult := mrOK;
  end;
end;

procedure TValueLabelsPickListForm.LabelsListBoxSelectionChange(
  Sender: TObject; User: boolean);
var
  SenderList: TListBox absolute Sender;
begin
  if FUpdatingListBox then exit;

  FUpdatingListBox := true;
  ValueListBox.ItemIndex := SenderList.ItemIndex;
  LabelsListBox.ItemIndex := SenderList.ItemIndex;
  if SenderList.ItemIndex >= 0 then
    FSelectedValueLabel := TEpiCustomValueLabel(SenderList.Items.Objects[SenderList.ItemIndex]);
  FUpdatingListBox := false;
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

class procedure TValueLabelsPickListForm.RestoreDefaultPos;
var
  Aform: TForm;
begin
  Aform := TForm.Create(nil);
  Aform.Width := 250;
  Aform.Height := 230;
  Aform.top := (Screen.Monitors[0].Height - Aform.Height) div 2;
  Aform.Left := (Screen.Monitors[0].Width - Aform.Width) div 2;
  SaveFormPosition(Aform, 'PickListForm');
  AForm.free;
end;

procedure TValueLabelsPickListForm.SetInitialValue(const S: string);
begin
  FInitialValue := S;
end;

end.

