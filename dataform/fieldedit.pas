unit fieldedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Graphics, epicustombase, epidatafiles,
  LCLType, epistringutils, epiglobals, entryprocs, LMessages, control_types;

type

  TFieldValidateErrorProc = procedure (Sender: TObject; Const Msg: String) of object;
  TFieldValidateResult = (fvrAccept, fvrReject, fvrNone);

  { TFieldEdit }

  TFieldEdit = class(TEdit, IEntryControl)
  private
    FField: TEpiField;
    FJumpToNext: boolean;
    FNameLabel: TLabel;
    FOnValidateError: TFieldValidateErrorProc;
    FQuestionLabel: TLabel;
    FValueLabelLabel: TLabel;
    FRecNo: integer;
    // FCommitingData = true, during .Commit call. This is to prevent updating text during a normal commit.
    FCommitingData: boolean;
    procedure   SetRecNo(const AValue: integer);
    procedure   FieldChange(Const Sender, Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup; EventType: Word; Data: Pointer);
  protected
    WC:         WideChar;
    Caret:      Integer;
    IsSeparator: boolean;
    procedure   SetField(const AValue: TEpiField); virtual;
    procedure   UpdateText; virtual;
    procedure   SetParent(NewParent: TWinControl); override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    PreUTF8KeyPress(var UTF8Key: TUTF8Char; out SepCount: integer;
      out InheritHandled: boolean): boolean;
    function    Characters: TCharSet; virtual;
    function    Separators: TCharArray; virtual;
    function    SeparatorCount: integer; virtual;
    function    UseSigns: boolean; virtual;
    function    ValidateError(const ErrorMsg: string): boolean;
    function    DoValidateSyntax: boolean; virtual;
    function    DoValidateRange: boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    ValidateEntry: boolean; virtual;
    procedure   Commit;
    procedure   UpdateSettings;
    function    CompareTo(Const AText: string; ct: TEpiComparisonType): boolean; virtual;
    property    Field: TEpiField read FField write SetField;
    property    RecNo: integer read FRecNo write SetRecNo;
    property    JumpToNext: boolean read FJumpToNext write FJumpToNext;
    property    OnValidateError: TFieldValidateErrorProc read FOnValidateError write FOnValidateError;
  end;

  { TIntegerEdit }

  TIntegerEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
    function    UseSigns: boolean; override;
    function    DoValidateSyntax: boolean; override;
    function    DoValidateRange: boolean; override;
  public
    function CompareTo(const AText: string; ct: TEpiComparisonType): boolean;
       override;
  end;

  { TFloatEdit }

  TFloatEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
    function    Separators: TCharArray; override;
    function    SeparatorCount: integer; override;
    function    UseSigns: boolean; override;
    procedure   UpdateText; override;
    function    DoValidateSyntax: boolean; override;
    function    DoValidateRange: boolean; override;
  public
    function CompareTo(const AText: string; ct: TEpiComparisonType): boolean;
       override;
  end;

  { TStringEdit }
  TStringEdit = class(TFieldEdit)
  protected
    procedure   SetField(const AValue: TEpiField); override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  public
    function CompareTo(const AText: string; ct: TEpiComparisonType): boolean;
       override;
  end;

  { TDateEdit }

  TDateEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
    function    Separators: TCharArray; override;
    function    SeparatorCount: integer; override;
    function    DoValidateSyntax: boolean; override;
    function    DoValidateRange: boolean; override;
    procedure KeyDownBeforeInterface(var Key: Word; Shift: TShiftState);
      override;
  public
    function CompareTo(const AText: string; ct: TEpiComparisonType): boolean;
      override;
  end;

  { TTimeEdit }

  TTimeEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
    function    Separators: TCharArray; override;
    function    SeparatorCount: integer; override;
    function    DoValidateSyntax: boolean; override;
    function    DoValidateRange: boolean; override;
    procedure KeyDownBeforeInterface(var Key: Word; Shift: TShiftState);
      override;
  public
    function CompareTo(const AText: string; ct: TEpiComparisonType): boolean;
       override;
  end;

  { TBoolEdit }

  TBoolEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
  end;

implementation

uses
  Forms, epidatafilestypes, LCLProc, strutils,
  epidocument, episettings, dataform_frame,
  epiconvertutils, settings, math;

{ TFieldEdit }

procedure TFieldEdit.SetField(const AValue: TEpiField);
var
  S: string;
  Cv: TCanvas;
  SideBuf: integer;
  Settings: TEpiProjectSettings;
  TmpFont: TFont;
begin
  if FField = AValue then exit;
  FField := AValue;
  Settings :=  TEpiDocument(Field.RootOwner).ProjectSettings;

  // Trick to avoid updaing "SetRealText" with the field.id;
  Name := GetRandomComponentName;
  MaxLength := Field.Length;

  Text      := '';
  Left      := Field.Left;
  Top       := Field.Top;
  if Self.Parent is TScrollBox then
    Cv := TScrollBox(Self.Parent).Canvas
  else
    Cv := TScrollBox(Self.Parent.Parent).Canvas;

  if Field.FieldType in StringFieldTypes then
    S := 'W'
  else
    S := '8';

  if not Settings.ShowFieldBorders then
    BorderStyle := bsNone;
  case BorderStyle of
    bsNone:   SideBuf := {$IFDEF DARWIN}    6 {$ELSE} 0 {$ENDIF};
    bsSingle: SideBuf := {$IFDEF MSWINDOWS} 7 {$ELSE} 6 {$ENDIF};
  end;

  // Man - this is a dirty way to handle font and the odd way they are
  // used in LCL... :(
  TmpFont := TFont.Create;
  TmpFont.Assign(Cv.Font);
  Cv.Font.Assign(Self.Font);
  //         Side buffer (pixel from controls left side to first character.
  Width   := (SideBuf * 2) + Cv.GetTextWidth(S) * FField.Length;
  Cv.Font.Assign(TmpFont);
  TmpFont.Free;

  with FQuestionLabel do
    Caption := Field.Question.Text;

  with FNameLabel do
  begin
    Caption := Field.Name;
    if not Settings.ShowFieldNames then
      Visible := false;
  end;

  with FValueLabelLabel do
  begin
    Visible := Field.ShowValueLabel;
    Caption := '';
  end;

  if Field.FieldType in AutoFieldTypes then
  begin
    ReadOnly := True;
    Enabled  := false;
    TabStop  := false;
  end;
  Field.RegisterOnChangeHook(@FieldChange);

  {$IFDEF EPI_DEBUG}
  WriteStr(S,  Field.FieldType);
  ShowHint := true;
  Hint := WideFormat(
    'FieldName: %s' + LineEnding +
    'Length:    %d' + LineEnding +
    'Type:      %s' + LineEnding +
    'Top,Left:  (%d, %d)',
    [Field.Name, Field.Length, S,
     Top, Left]);
  {$ENDIF}
end;

procedure TFieldEdit.SetRecNo(const AValue: integer);
begin
  // Commented out because otherwise performing "New Record" on a "New Record"
  // would not clear Edits.
//  if FRecNo = AValue then exit;
  FRecNo := AValue;
  UpdateText;
end;

procedure TFieldEdit.UpdateText;
begin
  if (RecNo = NewRecord) or (Field.IsMissing[RecNo]) then
    Text := ''
  else
    Text := Field.AsString[RecNo];
  UpdateSettings;
end;

procedure TFieldEdit.FieldChange(const Sender, Initiator: TEpiCustomBase;
  EventGroup: TEpiEventGroup; EventType: Word; Data: Pointer);
begin
  if FCommitingData then exit;

  if (Initiator = Field) and
     (EventGroup = eegFields) and
     (EventType = Word(efceData))
  then
  begin
    UpdateText;
  end;
end;

procedure TFieldEdit.SetParent(NewParent: TWinControl);
begin
  inherited SetParent(NewParent);
  if csDestroying in ComponentState then exit;

  FQuestionLabel.Parent := NewParent;
  FQuestionLabel.Anchors := [];
  FQuestionLabel.AnchorToNeighbour(akRight, 5, Self);
  FQuestionLabel.AnchorParallel(akBottom, 0, Self);

  FNameLabel.Parent := NewParent;
  FNameLabel.Anchors := [];
  FNameLabel.AnchorToNeighbour(akRight, 5, FQuestionLabel);
  FNameLabel.AnchorParallel(akBottom, 0, FQuestionLabel);

  FValueLabelLabel.Parent := NewParent;
  FValueLabelLabel.Anchors := [];
  FValueLabelLabel.AnchorToNeighbour(akLeft, 10, Self);
  FValueLabelLabel.AnchorParallel(akBottom, 0, Self);
end;

function TFieldEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
begin
  UTF8Key := UTF16ToUTF8(WC);
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TFieldEdit.PreUTF8KeyPress(var UTF8Key: TUTF8Char;
  out SepCount: integer; out InheritHandled: boolean): boolean;
var
  i: integer;
  LSeparators: TCharArray;
  LCharacters: TCharSet;
begin
  WC := UTF8ToUTF16(UTF8Key)[1];

  // Use ESC key to cancel current entry in field.
  // - on new record, field is set to empty (using updatetext).
  if WC = WideChar(VK_ESCAPE) then
  begin
    UpdateText;
    exit(true);
  end;

  if WC < WideChar(VK_SPACE) then
  begin
    InheritHandled := inherited DoUTF8KeyPress(UTF8Key);
    exit(true);
  end;

  if SelLength > 0 then
    Caret := SelStart
  else
    Caret := CaretPos.X;
  // Increment to have 1 indexed caret as with strings.
  Inc(Caret);

  // Missing handling.
  if (Caret = 1) and (WC = '.') then
  begin
    InheritHandled := inherited DoUTF8KeyPress(UTF8Key);
    exit(true);
  end;

  // Separator counting
  IsSeparator := false;
  SepCount := 0;
  LSeparators := Separators;
  for i := Low(LSeparators) to High(LSeparators) do
  begin
    SepCount += CountChar(Text, LSeparators[i]);
    if WC = LSeparators[i] then IsSeparator := true;
  end;

  // Check for allowed keys.
  UTF8Key := '';
  InheritHandled := false;
  LCharacters := Characters;
  if (not (LCharacters = [])) and
     (not (WC in LCharacters)) then
  begin
    InheritHandled := inherited DoUTF8KeyPress(UTF8Key);
    exit(true);
  end;

  // Sign operators are only allowed at pos 0.
  if UseSigns and
     (WC in ['+','-']) and (Caret > 1) then exit(true);
  // No more than "SeparatorCount)" separator is allowed at any time.
  if IsSeparator and (SepCount >= SeparatorCount) then exit(true);

  if (SelLength = 0) and (UTF8Length(Text) = MaxLength) then
    exit(true);
  FJumpToNext := false;
  if (SelLength = 0) and
     (
      (UTF8Length(Text) = (MaxLength-1)) or
      // This is because autoplacing a seperator right before the last keystroke
      // didn't previously got caugth correctly. (Can only happen with floats)
      ((UTF8Length(Text) = (MaxLength-2)) and (Field.Decimals = 1))
     ) then
    FJumpToNext := true;
  result := false;
end;

function TFieldEdit.Characters: TCharSet;
begin
  result := [];
end;

function TFieldEdit.Separators: TCharArray;
begin
  result := nil;
end;

function TFieldEdit.SeparatorCount: integer;
begin
  result := 0;
end;

function TFieldEdit.UseSigns: boolean;
begin
  result := false;
end;

function TFieldEdit.ValidateError(const ErrorMsg: string): boolean;
begin
  result := false;
  if Assigned(OnValidateError) then
    OnValidateError(Self, ErrorMsg);
end;

function TFieldEdit.DoValidateSyntax: boolean;
begin
  result := true;
end;

function TFieldEdit.DoValidateRange: boolean;
begin
  result := true;
end;

constructor TFieldEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentFont := false;
  ControlStyle := ControlStyle - [csSetCaption];

  Font.Assign(EntrySettings.FieldFont);

  FQuestionLabel := TLabel.Create(Self);
  FQuestionLabel.Font := EntrySettings.FieldFont;
  FNameLabel := TLabel.Create(Self);
  FNameLabel.Font := EntrySettings.FieldFont;

  FValueLabelLabel := TLabel.Create(Self);
  FValueLabelLabel.Font.Color := EntrySettings.ValueLabelColour;

  FCommitingData := false;

  FRecNo := -1;
end;

destructor TFieldEdit.Destroy;
begin
  inherited Destroy;
end;

function TFieldEdit.ValidateEntry: boolean;
var
  S: string;
  LowS: String;
  HighS: String;
begin
  result := true;
//  if not Modified then exit;

  // Always accept empty/system-missing in syntax validate.
  // handling must enter is done elsewhere.
  S := Trim(Text);
  if (S = '.') or (S = '') then
  begin
    Text := '';
    Exit;
  end;

  // Syntax validation.
  Result := DoValidateSyntax;
  if not Result then exit;

  // Valuelabel/Range validation
  if Assigned(FField.ValueLabelSet) and Assigned(FField.Ranges) then
  begin
    if not ((FField.ValueLabelSet.ValueLabelExists[Text]) or
            (DoValidateRange))
    then
    begin
      LowS := FField.Ranges[0].AsString[true];
      HighS := FField.Ranges[0].AsString[false];
      exit(ValidateError('Illegal value (valuelabel/range: ' + LowS + ' - ' + HighS + ' )'));
    end;
  end else begin
    if Assigned(FField.ValueLabelSet) and
       (not FField.ValueLabelSet.ValueLabelExists[Text]) then
       exit(ValidateError('Illegal value (valuelabel)'));

    if Assigned(FField.Ranges) and
       (not DoValidateRange)
    then
    begin
      LowS := FField.Ranges[0].AsString[true];
      HighS := FField.Ranges[0].AsString[false];
      exit(ValidateError('Illegal value (range: ' + LowS + ' - ' + HighS + ' )'));
    end;
  end;
end;

procedure TFieldEdit.Commit;
var
  LRecNo: LongInt;
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

procedure TFieldEdit.UpdateSettings;
begin
  Font.Assign(EntrySettings.FieldFont);

  FValueLabelLabel.Font.Color := EntrySettings.ValueLabelColour;
  if (Field.ShowValueLabel) and
     (Assigned(Field.ValueLabelSet)) and
     (Text <> '') and
     (Text <> TEpiStringField.DefaultMissing)
  then
    FValueLabelLabel.Caption := Field.ValueLabelSet.ValueLabelString[Text]
  else
    FValueLabelLabel.Caption := '';

  if Focused then
    Color := EntrySettings.ActiveFieldColour
  else if Field.EntryMode = emMustEnter then
    Color := EntrySettings.MustEnterFieldColour
  else
    Color := EntrySettings.InactiveFieldColour;

  FQuestionLabel.Font.Assign(EntrySettings.FieldFont);
  FNameLabel.Font.Assign(EntrySettings.FieldFont);
end;

function TFieldEdit.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
begin
  result := true;
end;

{ TIntegerEdit }

function TIntegerEdit.DoValidateSyntax: boolean;
var
  I: EpiInteger;
  Code: integer;
begin
  Result := true;
  Val(Text, I, Code);
  if Code <> 0 then
    Result := ValidateError(Format('Invalid charater "%s" at caret position %d', [Text[code], code]));
  Text := Format(Field.FormatString, [I]);
end;

function TIntegerEdit.DoValidateRange: boolean;
begin
  Result := Field.Ranges.InRange(StrToInt64(Text));
end;

function TIntegerEdit.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
var
  OwnVal, CmpVal: EpiInteger;
begin
  if (Text = '') or (AText = '') then exit(false);

  OwnVal := StrToInt(Text);
  CmpVal := StrToInt(AText);
  case ct of
    fcEq:  result := OwnVal = CmpVal;
    fcNEq: result := OwnVal <> CmpVal;
    fcLT:  result := OwnVal < CmpVal;
    fcLEq: result := OwnVal <= CmpVal;
    fcGEq: result := OwnVal >= CmpVal;
    fcGT:  result := OwnVal > CmpVal;
  end;
end;

function TIntegerEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: integer;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit(Result);
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TIntegerEdit.Characters: TCharSet;
begin
  Result :=  IntegerChars;
end;

function TIntegerEdit.UseSigns: boolean;
begin
  Result := true;
end;

{ TFloatEdit }

function TFloatEdit.DoValidateSyntax: boolean;
var
  F: EpiFloat;
  P, IntL: Integer;
begin
  Result := true;

  // Final check on decimal point placement.
  IntL := (Field.Length - Field.Decimals) - 1;
  P := Pos(DecimalSeparator, Text);
  if (P > (IntL + 1)) or  // Covers integral part with decimals.
     ((P = 0) and (Length(Text) > (IntL))) then
    exit(ValidateError(Format('Invalid number. (Format is %d.%d)', [IntL, Field.Decimals])));

  if not TryStrToFloat(Text, F) then
    exit(ValidateError('Invalid floating point number.'));

  Text := Format(Field.FormatString, [F]);
end;

function TFloatEdit.DoValidateRange: boolean;
begin
  Result := Field.Ranges.InRange(StrToFloat(Text));
end;

function TFloatEdit.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
var
  OwnVal, CmpVal: Extended;
begin
  if (Text = '') or (AText = '') then exit(false);

  OwnVal := StrToFloat(Text);
  CmpVal := StrToFloat(AText);
  case ct of
    fcEq:  result := SameValue(OwnVal, CmpVal, 0.0);
    fcNEq: result := not SameValue(OwnVal, CmpVal, 0.0);
    fcLT:  result := OwnVal < CmpVal;
    fcLEq: result := (OwnVal < CmpVal) or SameValue(OwnVal, CmpVal, 0.0);
    fcGEq: result := (OwnVal > CmpVal) or SameValue(OwnVal, CmpVal, 0.0);
    fcGT:  result := OwnVal > CmpVal;
  end;
end;

function TFloatEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: Integer;
  P: Int64;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;

  // Validate position of separator... (cannot be placed beyond #integers)
  if IsSeparator and (Caret > (Field.Length - Field.Decimals)) then
    exit;

  // Check number of decimals.
  if (N > 0) then
  begin
    P := Pos(DecimalSeparator, Text);
    if (Length(Text) - P) = (Field.Decimals - 1) then
      JumpToNext := true;
    if ((Length(Text) - P) = Field.Decimals) and
       (Caret > P)then
      Exit;
  end;

  // Auto place the separator...
  if (not IsSeparator) and (N=0) and
     (Caret = (Field.Length - Field.Decimals)) then
  begin
    Text := Text + DecimalSeparator;
    CaretPos := Point(Caret + 1, 0);
  end;

  if IsSeparator then WC := DecimalSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TFloatEdit.Characters: TCharSet;
begin
  Result := FloatChars;
end;

function TFloatEdit.Separators: TCharArray;
begin
  SetLength(Result, 2);
  Result[0] := ',';
  Result[1] := '.';
end;

function TFloatEdit.SeparatorCount: integer;
begin
  Result := 1;
end;

function TFloatEdit.UseSigns: boolean;
begin
  Result := true;
end;

procedure TFloatEdit.UpdateText;
begin
  if (RecNo = NewRecord) or (Field.IsMissing[RecNo]) then
    Text := ''
  else
    Text := Format(TEpiFloatField(Field).FormatString, [Field.AsFloat[RecNo]]);
  UpdateSettings;
end;

{ TStringEdit }

procedure TStringEdit.SetField(const AValue: TEpiField);
begin
  inherited SetField(AValue);
  if AValue.FieldType = ftUpperString then
    CharCase := ecUppercase;
end;

function TStringEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: Integer;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TStringEdit.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
var
  OwnVal: String;
  CmpVal: String;
  StrCmp: Integer;
begin
  OwnVal := Text;
  CmpVal := AText;

  if Field.FieldType = ftUpperString then
    StrCmp := AnsiCompareText(OwnVal, CmpVal)
  else
    StrCmp := AnsiCompareStr(OwnVal, CmpVal);

  case ct of
    fcEq:  result := StrCmp = 0;
    fcNEq: result := StrCmp <> 0;
    fcLT:  result := StrCmp < 0;
    fcLEq: result := StrCmp <= 0;
    fcGEq: result := StrCmp >= 0;
    fcGT:  result := StrCmp > 0;
  end;
end;

{ TDateEdit }

function TDateEdit.DoValidateSyntax: boolean;
var
  DateStr: String;
  Sep: String;
  Y, M, D: word;
  S: String;
  TheDate: EpiDate;
begin
  Result := true;


  Sep := String(DateSeparator);
  DateStr := StringsReplace(Text, ['/', '-', '\', '.'], [Sep, Sep, Sep, Sep], [rfReplaceAll]);

  if not EpiStrToDate(DateStr, DateSeparator, Field.FieldType, D, M, Y, S) then
    Exit(ValidateError(S));

  TheDate := Trunc(EncodeDate(Y,M,D));
  Text := FormatDateTime(TEpiDateField(FField).FormatString, TheDate);
end;

function TDateEdit.DoValidateRange: boolean;
var
  S: string;
begin
  Result := Field.Ranges.InRange(EpiStrToDate(Text, DateSeparator, Field.FieldType, S));
end;

procedure TDateEdit.KeyDownBeforeInterface(var Key: Word; Shift: TShiftState);
begin
  if (Key in [VK_ADD, VK_OEM_PLUS]) and
     (Shift = [])
  then
  begin
    Text := FormatDateTime(Field.FormatString(), Now);
    Key := VK_RETURN;
  end;

  inherited KeyDownBeforeInterface(Key, Shift);
end;

function TDateEdit.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
var
  S: String;
  OwnVal, CmpVal: EpiDate;
begin
  if (Text = '') or (AText = '') then exit(false);

  with DefaultFormatSettings do
  begin
    OwnVal := EpiStrToDate(Text, DateSeparator, Field.FieldType, S);
    CmpVal := EpiStrToDate(AText, DateSeparator, Field.FieldType, S);
  end;
  case ct of
    fcEq:  result := OwnVal = CmpVal;
    fcNEq: result := OwnVal <> CmpVal;
    fcLT:  result := OwnVal < CmpVal;
    fcLEq: result := OwnVal <= CmpVal;
    fcGEq: result := OwnVal >= CmpVal;
    fcGT:  result := OwnVal > CmpVal;
  end;
end;

function TDateEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  AutoPlace: Boolean;
begin
  N := 2;
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;

  // No separator at start
  if IsSeparator and (Caret = 1) then exit(false);
  // No two consecutive separators.
  if IsSeparator and (Caret > 1) and (Text[Caret-1] = WC) then exit(false);

  if (not IsSeparator) then
  begin
    AutoPlace := false;
    case Field.FieldType of
      ftDMYDate,
      ftMDYDate:
        begin
          if (N=0) and (Caret = 3) then AutoPlace := true;
          if (N=1) and (Caret in [5,6]) and (Text[Caret-3] = DateSeparator) then AutoPlace := true;
        end;
      ftYMDDate:
        begin
          if (N=0) and (Caret = 5) then AutoPlace := true;
          if (N=1) and (Caret >= 5) and (Text[Caret-3] = DateSeparator) then AutoPlace := true;
        end;
    end;
    if AutoPlace then
    begin
      Text := Text + DateSeparator;
      CaretPos := Point(Caret + 1, 0);
    end;
  end;

  if IsSeparator then WC := DateSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TDateEdit.Characters: TCharSet;
begin
  Result := DateChars;
end;

function TDateEdit.Separators: TCharArray;
begin
  SetLength(Result, 4);
  Result[0] := '-';
  Result[1] := '.';
  Result[2] := '/';
  Result[3] := '\';
end;

function TDateEdit.SeparatorCount: integer;
begin
  Result := 2;
end;

{ TTimeEdit }

function TTimeEdit.DoValidateSyntax: boolean;
var
  Sep: String;
  TimeStr: String;
  H, M, S: Word;
  TheTime: EpiTime;
  Msg: string;
begin
  Result := true;


  Sep := String(TimeSeparator);
  TimeStr := StringsReplace(Text, ['-', ':', '.'], [Sep, Sep, Sep], [rfReplaceAll]);

  if not EpiStrToTime(TimeStr, TimeSeparator, H, M, S, Msg) then
    Exit(ValidateError(Msg));

  TheTime := EncodeTime(H, M, S, 0);
  Text := FormatDateTime('HH:NN:SS', TheTime);
end;

function TTimeEdit.DoValidateRange: boolean;
var
  S: string;
begin
  Result := Field.Ranges.InRange(EpiStrToTime(Text, TimeSeparator, S));
end;

procedure TTimeEdit.KeyDownBeforeInterface(var Key: Word; Shift: TShiftState);
begin
  if (Key in [VK_ADD, VK_OEM_PLUS]) and
     (Shift = [])
  then
  begin
    Text := FormatDateTime('HH:NN:SS', Now);
    Key := VK_RETURN;
  end;

  inherited KeyDownBeforeInterface(Key, Shift);
end;

function TTimeEdit.CompareTo(const AText: string; ct: TEpiComparisonType
  ): boolean;
var
  S: String;
  OwnVal, CmpVal: EpiTime;
begin
  if (Text = '') or (AText = '') then exit(false);

  with DefaultFormatSettings do
  begin
    OwnVal := EpiStrToTime(Text, TimeSeparator, S);
    CmpVal := EpiStrToTime(AText, TimeSeparator, S);
  end;

  case ct of
    fcEq:  result := OwnVal = CmpVal;
    fcNEq: result := OwnVal <> CmpVal;
    fcLT:  result := OwnVal < CmpVal;
    fcLEq: result := OwnVal <= CmpVal;
    fcGEq: result := OwnVal >= CmpVal;
    fcGT:  result := OwnVal > CmpVal;
  end;
end;

function TTimeEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  AutoPlace: Boolean;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;

  // No separator at start
  if IsSeparator and (Caret = 1) then exit(false);
  // No two consecutive separators.
  if IsSeparator and (Caret > 1) and (Text[Caret-1] = WC) then exit(false);

  // Auto place the separator...
  if (not IsSeparator) then
  begin
    AutoPlace := false;
    if (N=0) and (Caret = 3) then AutoPlace := true;
    if (N=1) and (Caret in [5,6]) and (Text[Caret-3] = TimeSeparator) then AutoPlace := true;
    if AutoPlace then
    begin
      Text := Text + TimeSeparator;
      CaretPos := Point(Caret + 1, 0);
    end;
  end;

  if IsSeparator then WC := TimeSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TTimeEdit.Characters: TCharSet;
begin
  Result := TimeChars;
end;

function TTimeEdit.Separators: TCharArray;
begin
  SetLength(Result, 3);
  Result[0] := '-';
  Result[1] := ':';
  Result[2] := '.';
end;

function TTimeEdit.SeparatorCount: integer;
begin
  Result := 2;
end;

{ TBoolEdit }

function TBoolEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: integer;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;
  // TODO : Use some sort of localized boolean chars.
  if WC in BooleanYesChars then
    WC := 'Y'
  else
    WC := 'N';
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TBoolEdit.Characters: TCharSet;
begin
  Result := BooleanChars;
end;

end.


