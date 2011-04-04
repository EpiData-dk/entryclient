unit fieldedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Graphics, epicustombase, epidatafiles,
  LCLType, epistringutils, entryprocs;

type

  TFieldValidateErrorProc = procedure (Sender: TObject; Const Msg: String) of object;
  TFieldValidateResult = (fvrAccept, fvrReject, fvrNone);

  { TFieldEdit }

  TFieldEdit = class(TEdit)
  private
    FField: TEpiField;
    FJumpToNext: boolean;
    FNameLabel: TLabel;
    FOnValidateError: TFieldValidateErrorProc;
    FQuestionLabel: TLabel;
    FValueLabelLabel: TLabel;
    FRecNo: integer;
    procedure   SetField(const AValue: TEpiField);
    procedure   SetRecNo(const AValue: integer);
    procedure   FieldChange(Sender: TObject; EventGroup: TEpiEventGroup; EventType: Word; Data: Pointer);
  protected
    WC:         WideChar;
    Caret:      Integer;
    IsSeparator: boolean;
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    ValidateEntry: boolean; virtual;
    procedure   Commit;
    procedure   UpdateSettings;
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
  public
    function    ValidateEntry: boolean; override;
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
  public
    function    ValidateEntry: boolean; override;
  end;

  { TStringEdit }
  TStringEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  public
    function    ValidateEntry: boolean; override;
  end;

  { TDateEdit }

  TDateEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
    function    Separators: TCharArray; override;
    function    SeparatorCount: integer; override;
  public
    function    ValidateEntry: boolean; override;
  end;

  { TTimeEdit }

  TTimeEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
    function    Separators: TCharArray; override;
    function    SeparatorCount: integer; override;
  public
    function    ValidateEntry: boolean; override;
  end;

  { TBoolEdit }

  TBoolEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    Characters: TCharSet; override;
  public
    function    ValidateEntry: boolean; override;
  end;

implementation

uses
  Forms, epidatafilestypes, LCLProc, strutils,
  epidocument, episettings, dataform_frame,
  epiconvertutils, settings;

{ TFieldEdit }

procedure TFieldEdit.SetField(const AValue: TEpiField);
var
  S: string;
  Cv: TCanvas;
  SideBuf: integer;
  Settings: TEpiProjectSettings;
begin
  if FField = AValue then exit;
  FField := AValue;
  Settings :=  TEpiDocument(Field.RootOwner).ProjectSettings;

  // Trick to avoid updaing "SetRealText" with the field.id;
  Name := FField.Id;
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
    S := '4';

  if not Settings.ShowFieldBorders then
    BorderStyle := bsNone;
  case BorderStyle of
    bsNone:   SideBuf := {$IFDEF DARWIN}    6 {$ELSE} 0 {$ENDIF};
    bsSingle: SideBuf := {$IFDEF MSWINDOWS} 7 {$ELSE} 6 {$ENDIF};
  end;

  //         Side buffer (pixel from controls left side to first character.
  Width   := (SideBuf * 2) + Cv.GetTextWidth(S) * FField.Length;

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
  if FRecNo = AValue then exit;
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

procedure TFieldEdit.FieldChange(Sender: TObject; EventGroup: TEpiEventGroup;
  EventType: Word; Data: Pointer);
begin
  if (EventGroup = eegFields) and (EventType = Word(efceData)) then
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
  if WC < #32 then
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
     (not (WC in LCharacters)) then exit(true);

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

constructor TFieldEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  FQuestionLabel := TLabel.Create(Self);
  FNameLabel := TLabel.Create(Self);
  FValueLabelLabel := TLabel.Create(Self);
  FValueLabelLabel.Font.Color := EntrySettings.ValueLabelColour;

  FRecNo := -1;
end;

destructor TFieldEdit.Destroy;
begin
  inherited Destroy;
end;

function TFieldEdit.ValidateEntry: boolean;
var
  S: string;
begin
  result := true;

  S := Trim(Text);
  if (S = '.') or (S = '') then
    Text := '';
end;

procedure TFieldEdit.Commit;
var
  LRecNo: LongInt;
begin
  LRecNo := RecNo;
  // Assume that if this is a new record and we are about to commit
  // the Datafile has been expanded to hold the new record.
  if RecNo = NewRecord then
    LRecNo := Field.DataFile.Size - 1;
  if Text = '' then
    Field.IsMissing[LRecNo] := true
  else
    Field.AsString[LRecNo] := Text;
end;

procedure TFieldEdit.UpdateSettings;
begin
  FValueLabelLabel.Font.Color := EntrySettings.ValueLabelColour;
  if (Field.ShowValueLabel) and
     (Assigned(Field.ValueLabelSet)) and
     (Text <> '') then
    FValueLabelLabel.Caption := Field.ValueLabelSet.ValueLabelString[Text]
  else
    FValueLabelLabel.Caption := '';
  if Focused then
    Color := EntrySettings.ActiveFieldColour
  else
    Color := EntrySettings.InactiveFieldColour;
end;

{ TIntegerEdit }

function TIntegerEdit.ValidateEntry: boolean;
var
  I: EpiInteger;
  Code: integer;
begin
  result := inherited ValidateEntry;
  if (not result) or (Text = '') or (not Modified) then exit;

  Val(Text, I, Code);
  if Code <> 0 then
    Exit(ValidateError(Format('Invalid charater "%s" at caret position %d', [Text[code], code])));


  if Assigned(FField.ValueLabelSet) and Assigned(FField.Ranges) then
  begin
    if not ((FField.ValueLabelSet.ValueLabelExists[I]) or
            (FField.Ranges.InRange(I))) then
      exit(ValidateError('Illegal value (valuelabel/range)'));
  end else begin
    if Assigned(FField.ValueLabelSet) and
       (not FField.ValueLabelSet.ValueLabelExists[I]) then
       exit(ValidateError('Illegal value (valuelabel)'));

    if Assigned(FField.Ranges) and
       (not FField.Ranges.InRange(I)) then
       exit(ValidateError('Illegal value (range)'));
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

function TFloatEdit.ValidateEntry: boolean;
var
  F: EpiFloat;
  P, IntL: Integer;
begin
  result := inherited ValidateEntry;
  if (not result) or (Text = '') or (not Modified) then exit;

  // Final check on decimal point placement.
  IntL := (Field.Length - Field.Decimals) - 1;
  P := Pos(DecimalSeparator, Text);
  if (P > (IntL + 1)) or  // Covers integral part with decimals.
     ((P = 0) and (Length(Text) > (IntL))) then
    exit(ValidateError(Format('Invalid format. Accepted format is %d.%d', [IntL, Field.Decimals])));

  if not TryStrToFloat(Text, F) then
    exit(ValidateError('Invalid floating point number.'));

  if Assigned(FField.ValueLabelSet) and Assigned(FField.Ranges) then
  begin
    if not ((FField.ValueLabelSet.ValueLabelExists[F]) or
            (FField.Ranges.InRange(F))) then
      exit(ValidateError('Illegal value (valuelabel/range)'));
  end else begin
    if Assigned(FField.ValueLabelSet) and
       (not FField.ValueLabelSet.ValueLabelExists[F]) then
      exit(ValidateError('Illegal value (valuelabel)'));

    if Assigned(FField.Ranges) and
       (not FField.Ranges.InRange(F)) then
      exit(ValidateError('Illegal value (range)'));
  end;

  Text := Format(TEpiFloatField(Field).FormatString, [F]);
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

function TStringEdit.ValidateEntry: boolean;
begin
  result := inherited ValidateEntry;
  if (not result) or (Text = '') or (not Modified) then exit;

  if Assigned(FField.ValueLabelSet) and
     (not FField.ValueLabelSet.ValueLabelExists[Text]) then
      exit(ValidateError('Illegal value (valuelabel)'));
end;

function TStringEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: Integer;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;

  if Field.FieldType = ftUpperString then
    WC := WideUpperCase(WC)[1];
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TDateEdit }

function TDateEdit.ValidateEntry: boolean;
var
  DateStr: String;
  Sep: String;
  Y, M, D: word;
  S: String;
  TheDate: EpiDate;
begin
  result := inherited ValidateEntry;
  if (not result) or (Text = '') or (not Modified) then exit;

  Sep := String(DateSeparator);
  DateStr := StringsReplace(Text, ['/', '-', '\', '.'], [Sep, Sep, Sep, Sep], [rfReplaceAll]);

  if not EpiStrToDate(DateStr, DateSeparator, Field.FieldType, D, M, Y, S) then
    Exit(ValidateError(S));

  case Field.FieldType of
    ftDMYDate, ftDMYToday: S := 'DD/MM/YYYY';
    ftMDYDate, ftMDYToday: S := 'MM/DD/YYYY';
    ftYMDDate, ftYMDToday: S := 'YYYY/MM/DD';
  end;

  TheDate := Trunc(EncodeDate(Y,M,D));

  if Assigned(FField.Ranges) and
     (not FField.Ranges.InRange(TheDate)) then
      exit(ValidateError('Illegal value (range)'));

  Text := FormatDateTime(S, TheDate);
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
  Result[2] := '\';
end;

function TDateEdit.SeparatorCount: integer;
begin
  Result := 2;
end;

{ TTimeEdit }

function TTimeEdit.ValidateEntry: boolean;
var
  Sep: String;
  TimeStr: String;
  H, M, S: Word;
  TheTime: EpiTime;
  Msg: string;
begin
  result := inherited ValidateEntry;
  if (not result) or (Text = '') or (not Modified) then exit;

  Sep := String(TimeSeparator);
  TimeStr := StringsReplace(Text, ['-', ':', '.'], [Sep, Sep, Sep], [rfReplaceAll]);

  if not EpiStrToTime(TimeStr, TimeSeparator, H, M, S, Msg) then
    Exit(ValidateError(Msg));

  TheTime := EncodeTime(H, M, S, 0);

  if Assigned(FField.Ranges) and
     (not FField.Ranges.InRange(TheTime)) then
      exit(ValidateError('Illegal value (range)'));

  Text := FormatDateTime('HH:NN:SS', TheTime);
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

function TBoolEdit.ValidateEntry: boolean;
begin
  result := inherited ValidateEntry;
  if (not result) or (Text = '') or (not Modified) then exit;
end;

end.

