unit fieldmemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Graphics, epicustombase, epidatafiles,
  LCLType, epistringutils, epiglobals, entryprocs, LMessages, control_types;

type

  { TFieldMemo }

  TFieldMemo = class(TMemo, IEntryDataControl)
  // IEntryDataControl
  private
    FOnValidateError: TFieldValidateErrorProc;
    FRecNo: Integer;
    function  GetField: TEpiField;
    procedure SetField(const AValue: TEpiField);

    function  GetRecNo: integer;
    procedure SetRecNo(const AValue: integer);

    function  GetJumpToNext: boolean;
    procedure SetJumpToNext(AValue: boolean);

    function  GetOnValidateError: TFieldValidateErrorProc;
    procedure SetOnValidateError(AValue: TFieldValidateErrorProc);

    function GetCustomEdit: TCustomEdit;
    procedure UpdateText;
  protected
    procedure SetParent(NewParent: TWinControl); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    procedure   UpdateSettings;
    function    ValidateEntry: boolean;
    procedure   Commit;
    function    CompareTo(Const AText: string; ct: TEpiComparisonType): boolean;
    property    Field: TEpiField read GetField write SetField;
    property    RecNo: integer read GetRecNo write SetRecNo;
    property    JumpToNext: boolean read GetJumpToNext write SetJumpToNext;
    property    OnValidateError: TFieldValidateErrorProc read GetOnValidateError write SetOnValidateError;
    property    CustomEdit: TCustomEdit read GetCustomEdit;

  // Local class
  private
    FCommitingData: Boolean;
    FNameLabel: TLabel;
    FQuestionLabel: TLabel;
    FField: TEpiMemoField;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  LazUTF8, epidocument, settings, epidatafilestypes, dataform_frame;

{ TFieldMemo }

function TFieldMemo.GetCustomEdit: TCustomEdit;
begin
  result := Self;
end;

procedure TFieldMemo.UpdateText;
begin
  if (RecNo = NewRecord) or (Field.IsMissing[RecNo]) then
    Text := ''
  else
    Text := Field.AsString[RecNo];
  UpdateSettings;
end;

procedure TFieldMemo.SetParent(NewParent: TWinControl);
begin
  inherited SetParent(NewParent);

  FNameLabel.Parent := NewParent;
  FQuestionLabel.Parent := NewParent;
end;

procedure TFieldMemo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      if (CaretPos.y = 0) then
        inherited KeyDown(Key, Shift);

    VK_DOWN:
      if (CaretPos.y = (Lines.Count - 1)) then
        inherited KeyDown(Key, Shift);

    VK_RETURN:
      if not (Shift = [ssCtrl]) then
        inherited KeyDown(Key, Shift);
  else
    inherited KeyDown(Key, Shift);
  end;
end;

procedure TFieldMemo.UpdateSettings;
begin
  Font.Assign(EntrySettings.FieldFont);

  if Focused then
    Color := EntrySettings.ActiveFieldColour
  else if Field.EntryMode = emMustEnter then
    Color := EntrySettings.MustEnterFieldColour
  else
    Color := EntrySettings.InactiveFieldColour;

  FQuestionLabel.Font.Assign(EntrySettings.FieldFont);
  FNameLabel.Font.Assign(EntrySettings.FieldFont);
end;

function TFieldMemo.GetField: TEpiField;
begin
  result := FField;
end;

function TFieldMemo.GetJumpToNext: boolean;
begin
  result := false;
end;

function TFieldMemo.GetOnValidateError: TFieldValidateErrorProc;
begin
  result := FOnValidateError;
end;

function TFieldMemo.GetRecNo: integer;
begin
  result := FRecNo;
end;

procedure TFieldMemo.SetField(const AValue: TEpiField);
begin
  FField := TEpiMemoField(AValue);

  Name := FField.Name;

  Text      := '';
  Left      := FField.Left;
  Top       := FField.Top;
  Width     := FField.Width;
  Height    := FField.Height;

  with FQuestionLabel do
    Caption := Field.Question.Text;

  with FNameLabel do
  begin
    Caption := Field.Name;
    if (not TEpiDocument(Field.RootOwner).ProjectSettings.ShowFieldNames) then
      Visible := false;
  end;
end;

procedure TFieldMemo.SetJumpToNext(AValue: boolean);
begin
  //
end;

procedure TFieldMemo.SetOnValidateError(AValue: TFieldValidateErrorProc);
begin
  FOnValidateError := AValue;
end;

procedure TFieldMemo.SetRecNo(const AValue: integer);
begin
  FRecNo := AValue;
  UpdateText;
end;

function TFieldMemo.ValidateEntry: boolean;
begin
  // Memo's have no logical bindings and is always validated.
  result := true;
end;

procedure TFieldMemo.Commit;
var
  LRecNo: Integer;
begin
  FCommitingData := true;

  LRecNo := RecNo;
  // Assume that if this is a new record and we are about to commit
  // the Datafile has been expanded to hold the new record.
  if RecNo = NewRecord then
    LRecNo := Field.DataFile.Size - 1;
  if Text = '' then
    Field.IsMissing[LRecNo] := true
  else
    Field.AsString[LRecNo] := Text;

  FCommitingData := false;
end;

function TFieldMemo.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
var
  OwnVal: String;
  CmpVal: String;
  StrCmp: Integer;
begin
  OwnVal := Text;
  CmpVal := AText;

  StrCmp := UTF8CompareStr(OwnVal, CmpVal);
  case ct of
    fcEq:  result := StrCmp = 0;
    fcNEq: result := StrCmp <> 0;
    fcLT:  result := StrCmp < 0;
    fcLEq: result := StrCmp <= 0;
    fcGEq: result := StrCmp >= 0;
    fcGT:  result := StrCmp > 0;
  end;
end;

constructor TFieldMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FNameLabel := TLabel.Create(Self);
  FNameLabel.Anchors := [];
  FNameLabel.AnchorParallel(akLeft, 0, Self);
  FNameLabel.AnchorToNeighbour(akBottom, 5, Self);

  FQuestionLabel := TLabel.Create(Self);
  FQuestionLabel.Anchors := [];
  FQuestionLabel.AnchorToNeighbour(akLeft, 5, FNameLabel);
  FQuestionLabel.AnchorParallel(akBottom, 0, FNameLabel);

  FCommitingData := false;
  FRecNo := -1;

  WordWrap := true;
  WantReturns := true;
  ScrollBars := ssAutoBoth;
end;

end.

