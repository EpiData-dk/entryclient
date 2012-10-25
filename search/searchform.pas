unit searchform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, types, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Search, epidatafiles, epidatafilestypes, LCLType,
  ActnList;

type

  { TSearchForm1 }

  TSearchForm1 = class(TForm)
    AddSearchAction: TAction;
    ActionList1: TActionList;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    CurSearchGrpBox: TGroupBox;
    SearchLabel: TLabel;
    ListBtn: TBitBtn;
    FindBtn: TBitBtn;
    BitBtn3: TBitBtn;
    ComboBox6: TComboBox;
    GroupBox1: TGroupBox;
    BinOpBevel: TBevel;
    FieldBevel: TBevel;
    Label5: TLabel;
    MatchBevel: TBevel;
    Panel1: TPanel;
    AddBtn: TSpeedButton;
    DelBtn: TSpeedButton;
    Panel2: TPanel;
    ValueBevel: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OriginGrpBox: TRadioGroup;
    DirectionGrpBox: TRadioGroup;
    ScrollBox1: TScrollBox;
    TopBevel: TBevel;
    procedure AddBtnClick(Sender: TObject);
    procedure AddSearchActionExecute(Sender: TObject);
    procedure FindBtnClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBtnClick(Sender: TObject);
  private
    FActiveField: TEpiField;
    FActiveText: String;
    { private declarations }
    FDataFile: TEpiDataFile;
    FSearch: TSearch;
    FSearchConditionList: TList;
    FHintWindow: THintWindow;
    FActiveFields: TStringList;
    procedure SetActiveField(const AValue: TEpiField);
    procedure SetActiveFields(const AValue: TStringList);
    procedure SetActiveText(const AValue: String);
    procedure SetDataFile(const AValue: TEpiDataFile);
    function  DoAddNewSearchCondition: Pointer;
    procedure AddBinOpToCombo(Combo: TComboBox);
    procedure AddFieldsToCombo(Combo: TComboBox);
    procedure AddMatchCriteriaToCombo(Combo: TComboBox; Ft: TEpiFieldType);
    procedure FieldChange(Sender: TObject);
    procedure MatchChange(Sender: TObject);
    procedure DoCreateSearch;
    procedure ValueEditUTF8KeyPress(Sender: TObject;
      var UTF8Key: TUTF8Char);
    procedure ValueEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function ValidateCriterias: boolean;
    procedure DoError(Const Msg: string; Const Ctrl: TControl);
    procedure UpdateSearchLabel;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent; Const DataFile: TEpiDataFile);
    class procedure RestoreDefaultPos;
    property ActiveField: TEpiField read FActiveField write SetActiveField;
    property ActiveText: String read FActiveText write SetActiveText;
    property ActiveFields: TStringList read FActiveFields write SetActiveFields;
    property Search: TSearch read FSearch;
  end; 

const
  mrFind = mrLast + 1;
  mrList = mrLast + 2;

implementation

{$R *.lfm}

uses
  LCLIntf, math, LCLProc, epiconvertutils, strutils, settings, epistringutils,
  entry_rsconsts;

type
  TSearchConditions = record
    BinOpCmb: TComboBox;
    FieldListCmb: TComboBox;
    MatchCriteriaCmb: TComboBox;
    ValueEdit: TEdit;
  end;
  PSearchConditions = ^TSearchConditions;

{ TSearchForm1 }

procedure TSearchForm1.DelBtnClick(Sender: TObject);
var
  MRec: PSearchConditions;
  Idx: Integer;
begin
  BeginFormUpdate;

  Idx := FSearchConditionList.Count - 1;
  MRec := PSearchConditions(FSearchConditionList[Idx]);

  DelBtn.AnchorVerticalCenterTo(PSearchConditions(FSearchConditionList[Idx-1])^.BinOpCmb);

  with MRec^ do
  begin
    BinOpCmb.Free;
    FieldListCmb.Free;
    MatchCriteriaCmb.Free;
    ValueEdit.Free;
  end;
  FSearchConditionList.Remove(MRec);

  DelBtn.Enabled := FSearchConditionList.Count > 1;
  EndFormUpdate;

  UpdateSearchLabel;
end;

procedure TSearchForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  SaveFormPosition(Self, 'SearchForm');
  if ModalResult = mrCancel then
  begin
    CanClose := true;
    Exit;
  end;

  CanClose := ValidateCriterias;
end;

procedure TSearchForm1.FormShow(Sender: TObject);
begin
  LoadFormPosition(Self, 'SearchForm');
end;

procedure TSearchForm1.AddBtnClick(Sender: TObject);
begin
  DoAddNewSearchCondition;
end;

procedure TSearchForm1.AddSearchActionExecute(Sender: TObject);
begin
  PSearchConditions(DoAddNewSearchCondition)^.FieldListCmb.SetFocus;
end;

procedure TSearchForm1.FindBtnClick(Sender: TObject);
begin
  DoCreateSearch;
  ModalResult := mrFind;
end;

procedure TSearchForm1.FormCreate(Sender: TObject);
begin
  FSearchConditionList := TList.Create;
  FSearch := nil;
  DoAddNewSearchCondition;
end;

procedure TSearchForm1.ListBtnClick(Sender: TObject);
begin
  DoCreateSearch;
  ModalResult := mrList;
end;

procedure TSearchForm1.SetDataFile(const AValue: TEpiDataFile);
begin
  if FDataFile = AValue then exit;
  FDataFile := AValue;
end;

procedure TSearchForm1.SetActiveField(const AValue: TEpiField);
begin
  if FActiveField = AValue then exit;
  FActiveField := AValue;
  if FSearchConditionList.Count = 0 then exit;

  with PSearchConditions(FSearchConditionList[0])^.FieldListCmb do
    ItemIndex := Items.IndexOfObject(AValue);
end;

procedure TSearchForm1.SetActiveFields(const AValue: TStringList);
var
  i: Integer;
begin
  if FActiveFields = AValue then exit;
  FActiveFields := AValue;

  if FActiveFields.Count <= 0 then exit;

  SetActiveField(TEpiField(FActiveFields.Objects[0]));
  SetActiveText(FActiveFields[0]);

  for i := 1 to FActiveFields.Count - 1 do
  begin
    with PSearchConditions(DoAddNewSearchCondition)^ do
    begin
      with FieldListCmb do
        ItemIndex := Items.IndexOfObject(FActiveFields.Objects[i]);
      with ValueEdit do
        Text := FActiveFields[i];
    end;
  end;
  UpdateSearchLabel;
end;

procedure TSearchForm1.SetActiveText(const AValue: String);
begin
  if FActiveText = AValue then exit;
  FActiveText := AValue;
  with PSearchConditions(FSearchConditionList[0])^.ValueEdit do
    Text := AValue;
end;

function TSearchForm1.DoAddNewSearchCondition: Pointer;
var
  BinOpCmb: TComboBox;
  FieldListCmb: TComboBox;
  MatchCriteriaCmb: TComboBox;
  ValueEdit: TEdit;
  MRec: PSearchConditions;
begin
  BinOpCmb := TComboBox.Create(ScrollBox1);
  FieldListCmb := TComboBox.Create(ScrollBox1);
  MatchCriteriaCmb := TComboBox.Create(ScrollBox1);
  ValueEdit := TEdit.Create(ScrollBox1);

  with BinOpCmb do
  begin
    Style := csDropDownList;
    AnchorParallel(akLeft, 0, TopBevel);
    AnchorToNeighbour(akRight, 5, BinOpBevel);
    if FSearchConditionList.Count = 0 then
      AnchorToNeighbour(akTop, 3, TopBevel)
    else
      AnchorToNeighbour(akTop, 3, PSearchConditions(FSearchConditionList[FSearchConditionList.Count-1])^.BinOpCmb);
    Enabled := FSearchConditionList.Count > 0;
    AddBinOpToCombo(BinOpCmb);
    ItemIndex := 0;
    Tag := FSearchConditionList.Count;
    TabOrder := (Tag * 4);
    Parent := ScrollBox1;
  end;

  with FieldListCmb do
  begin
    Style := csDropDownList;
    OnChange := @FieldChange;
    AnchorToNeighbour(akLeft, 5, BinOpBevel);
    AnchorToNeighbour(akRight, 5, FieldBevel);
    AnchorVerticalCenterTo(BinOpCmb);
    AddFieldsToCombo(FieldListCmb);
    ItemIndex := 0;
    Tag := FSearchConditionList.Count;
    TabOrder := (Tag * 4) + 1;
    Parent := ScrollBox1;
  end;

  with MatchCriteriaCmb do
  begin
    Style := csDropDownList;
    AnchorToNeighbour(akLeft, 5, FieldBevel);
    AnchorToNeighbour(akRight, 5, MatchBevel);
    AnchorVerticalCenterTo(BinOpCmb);
    AddMatchCriteriaToCombo(MatchCriteriaCmb, TEpiField(FieldListCmb.Items.Objects[0]).FieldType);
    OnChange := @MatchChange;
    ItemIndex := 0;
    Tag := FSearchConditionList.Count;
    TabOrder := (Tag * 4) + 2;
    Parent := ScrollBox1;
  end;

  with ValueEdit do
  begin
    AnchorToNeighbour(akLeft, 5, MatchBevel);
    AnchorToNeighbour(akRight, 5, ValueBevel);
    AnchorVerticalCenterTo(BinOpCmb);
    OnUTF8KeyPress := @ValueEditUTF8KeyPress;
    OnKeyUp := @ValueEditKeyUp;
    Tag := FSearchConditionList.Count;
    TabOrder := (Tag * 4) + 3;
    Parent := ScrollBox1;
  end;

  DelBtn.AnchorVerticalCenterTo(BinOpCmb);
  DelBtn.Enabled := FSearchConditionList.Count > 0;

  MRec := New(PSearchConditions);
  MRec^.BinOpCmb         := BinOpCmb;
  MRec^.FieldListCmb     := FieldListCmb;
  MRec^.MatchCriteriaCmb := MatchCriteriaCmb;
  MRec^.ValueEdit        := ValueEdit;
  FSearchConditionList.Add(MRec);
  Result := MRec;

  UpdateSearchLabel;
end;

procedure TSearchForm1.AddBinOpToCombo(Combo: TComboBox);
begin
  with Combo do
  begin
    Items.BeginUpdate;
    Clear;
    AddItem(rsAnd, TObject(PtrUInt(boAnd)));
    AddItem(rsOr, TObject(PtrUInt(boOr)));
    Items.EndUpdate;
  end;
end;

procedure TSearchForm1.AddFieldsToCombo(Combo: TComboBox);
var
  i: Integer;
begin
  with Combo do
  begin
    Items.BeginUpdate;
    Clear;
    for i := 0 to FDataFile.Fields.Count - 1 do
      AddItem(FDataFile.Field[i].Name +
              BoolToStr(FDataFile.Field[i].Question.Text <> '',
                ': ' + EpiCutString(FDataFile.Field[i].Question.Text, 10),
                ''),
              FDataFile.Field[i]);
    Items.EndUpdate;
  end;
end;

procedure TSearchForm1.AddMatchCriteriaToCombo(Combo: TComboBox;
  Ft: TEpiFieldType);
begin
  with Combo do
  begin
    Items.BeginUpdate;
    Clear;
    AddItem('=',  TObject(PtrUInt(mcEq)));
    AddItem('<>', TObject(PtrUInt(mcNEq)));
    if not (Ft in StringFieldTypes) then AddItem('<=', TObject(PtrUInt(mcLEq)));
    if not (Ft in StringFieldTypes) then AddItem('<',  TObject(PtrUInt(mcLT)));
    if not (Ft in StringFieldTypes) then AddItem('>',  TObject(PtrUInt(mcGT)));
    if not (Ft in StringFieldTypes) then AddItem('=>', TObject(PtrUInt(mcGEq)));
    if (Ft in StringFieldTypes) then AddItem(rsBegins,   TObject(PtrUInt(mcBegin)));
    if (Ft in StringFieldTypes) then AddItem(rsContains, TObject(PtrUInt(mcContains)));
    if (Ft in StringFieldTypes) then AddItem(rsEnds,     TObject(PtrUInt(mcEnd)));
    Items.EndUpdate;
  end;
end;

procedure TSearchForm1.FieldChange(Sender: TObject);
var
  Cmb: TComboBox;
  Obj: TObject;
  Idx: LongInt;
  Field: TEpiField;
begin
  with TComboBox(Sender) do
  begin
    Idx := Tag;
    Field := TEpiField(Items.Objects[ItemIndex]);
  end;
  Cmb := PSearchConditions(FSearchConditionList[Idx])^.MatchCriteriaCmb;
  Obj := Cmb.Items.Objects[Cmb.ItemIndex];
  AddMatchCriteriaToCombo(Cmb, Field.FieldType);
  Idx := Max(Cmb.Items.IndexOfObject(Obj), 0);
  Cmb.ItemIndex := Idx;

  UpdateSearchLabel;
end;

procedure TSearchForm1.MatchChange(Sender: TObject);
begin
  UpdateSearchLabel;
end;

procedure TSearchForm1.DoCreateSearch;
var
  SC: TSearchCondition;
  i: Integer;
begin
  FSearch := TSearch.Create;
  FSearch.DataFile := FDataFile;
  case OriginGrpBox.ItemIndex of
    0: FSearch.Origin := soBeginning;
    1: FSearch.Origin := soCurrent;
    2: FSearch.Origin := soEnd;
  end;
  Case DirectionGrpBox.ItemIndex of
    0: FSearch.Direction := sdForward;
    1: FSearch.Direction := sdBackward;
  end;

  for i := 0 to FSearchConditionList.Count - 1 do
  with PSearchConditions(FSearchConditionList[i])^ do
  begin
    SC := TSearchCondition.Create;
    SC.BinOp         := TSearchBinOp(PtrUInt(BinOpCmb.Items.Objects[BinOpCmb.ItemIndex]));
    SC.MatchCriteria := TMatchCriteria(PtrUInt(MatchCriteriaCmb.Items.Objects[MatchCriteriaCmb.ItemIndex]));
    SC.Text          := ValueEdit.Text;
    SC.Field         := TEpiField(FieldListCmb.Items.Objects[FieldListCmb.ItemIndex]);
    FSearch.List.Add(SC);
  end;
end;

procedure TSearchForm1.ValueEditUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
var
  I: integer;
  Ch: LongWord;
  Idx: LongInt;
  Field: TEpiField;
begin
  DoError('', nil);

  with TEdit(Sender) do
    Idx := Tag;
  with PSearchConditions(FSearchConditionList[Idx])^.FieldListCmb do
    Field := TEpiField(Items.Objects[ItemIndex]);

  Ch := UTF8CharacterToUnicode(@UTF8Key[1], I);
  if (not (Field.FieldType in StringFieldTypes)) and
     (not (Char(Ch) in [VK_0..VK_9, VK_RETURN, Char(VK_BACK)] +
                       ['.',','] +
                       ['-', ':', '.'] +
                       ['/', '-', '\', '.']))
  then
    UTF8Key := '';
  case Field.FieldType of
    ftFloat:   if (Char(Ch) in ['.',',']) then UTF8Key := DecimalSeparator;
    ftTime:    if (Char(Ch) in ['-', ':', '.']) then UTF8Key := TimeSeparator;
    ftDMYDate,
    ftMDYDate,
    ftYMDDate: if (Char(Ch) in ['/', '-', '\', '.']) then UTF8Key := DateSeparator;
  end;
end;

procedure TSearchForm1.ValueEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateSearchLabel;
end;

function TSearchForm1.ValidateCriterias: boolean;
var
  Field: TEpiField;
  I64: int64;
  F: Extended;
  W1, W2, W3: Word;
  S: String;
  i: Integer;
begin
  result := false;

  for i := 0 to FSearchConditionList.Count - 1 do
  with PSearchConditions(FSearchConditionList[i])^ do
  begin
    with FieldListCmb do
      Field := TEpiField(Items.Objects[ItemIndex]);

    case Field.FieldType of
      ftBoolean,
      ftInteger, ftAutoInc:
        begin
          if not TryStrToInt64(ValueEdit.Text, I64) then
          begin
            DoError(Format(rsNotAValidIntegerS, [ValueEdit.Text]), ValueEdit);
            Exit;
          end;
        end;
      ftFloat:
        begin
          if not TryStrToFloat(ValueEdit.Text, F) then
          begin
            DoError(Format(rsNotAValidFloatS, [ValueEdit.Text]), ValueEdit);
            Exit;
          end;
        end;
      ftTime, ftTimeAuto:
        begin
          if not EpiStrToTime(ValueEdit.Text, TimeSeparator, W1, W2, W3, S) then
          begin
            DoError(S, ValueEdit);
            Exit;
          end;
        end;
      ftDMYDate, ftDMYAuto,
      ftMDYDate, ftMDYAuto,
      ftYMDDate, ftYMDAuto:
        begin
          if not EpiStrToDate(ValueEdit.Text, DateSeparator, Field.FieldType, W1, W2, W3, S) then
          begin
            DoError(S, ValueEdit);
            Exit;
          end;
        end;
    end;
  end;

  result := true;
end;

procedure TSearchForm1.DoError(const Msg: string; const Ctrl: TControl);
var
  R: TRect;
  P: TPoint;
begin
  if not Assigned(FHintWindow) then
  begin
    FHintWindow := THintWindow.Create(Self);
    FHintWindow.AutoHide := true;
    FHintWindow.HideInterval := 5 * 1000;
  end;

  if (Msg = '') or (Ctrl = nil) then
  begin
    FHintWindow.Hide;
    Exit;
  end;

  R := FHintWindow.CalcHintRect(0, Msg, nil);
  P := Ctrl.ClientToScreen(Point(0,0));
  OffsetRect(R, P.X, P.Y + Ctrl.Height);
  FHintWindow.ActivateHint(R, Msg);
end;

procedure TSearchForm1.UpdateSearchLabel;
var
  S: String;
  i: Integer;
begin
  S := DupeString('(', FSearchConditionList.Count - 2);

  for i := 0 to FSearchConditionList.Count - 1 do
  with PSearchConditions(FSearchConditionList[i])^ do
  begin
    if I > 0 then
      case BinOpCmb.ItemIndex of
        0: S += ' ' + rsAnd + ' ';
        1: S += ' ' + rsOr + ' ';
      end;
    S += '(' + FieldListCmb.Text + ' ' + MatchCriteriaCmb.Text + ' ' + ValueEdit.Text + ')';
    if (I > 0) and (I < FSearchConditionList.Count - 1) then
      S += ')';
  end;

  SearchLabel.Caption := S;
end;

constructor TSearchForm1.Create(TheOwner: TComponent;
  const DataFile: TEpiDataFile);
begin
  inherited Create(TheOwner);
  FDataFile := DataFile;
end;

class procedure TSearchForm1.RestoreDefaultPos;
var
  Aform: TForm;
begin
  Aform := TForm.Create(nil);
  Aform.Width := 600;
  Aform.Height := 480;
  Aform.top := (Screen.Monitors[0].Height - Aform.Height) div 2;
  Aform.Left := (Screen.Monitors[0].Width - Aform.Width) div 2;
  SaveFormPosition(Aform, 'SettingsForm');
  AForm.free;
end;

{ TSearchForm1 }

end.

