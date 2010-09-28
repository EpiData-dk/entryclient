unit fieldedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Graphics, epicustombase, epidatafiles,
  LCLType, LMessages, epistringutils, entryprocs;

type

  { TFieldEdit }

  TFieldEdit = class(TEdit)
  private
    FField: TEpiField;
    FJumpToNext: boolean;
    FNameLabel: TLabel;
    FOnEditDoneError: TNotifyEvent;
    FQuestionLabel: TLabel;
    FRecNo: integer;
    procedure   SetField(const AValue: TEpiField);
    procedure   SetRecNo(const AValue: integer);
    procedure   UpdateText;
    procedure   FieldChange(Sender: TObject; EventGroup: TEpiEventGroup; EventType: Word; Data: Pointer);
  protected
    WC:         WideChar;
    Caret:      Integer;
    IsSeparator: boolean;
    procedure   SetParent(NewParent: TWinControl); override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    PreUTF8KeyPress(var UTF8Key: TUTF8Char; var SepCount: integer;
      var InheritHandled: boolean): boolean;
    function    Characters: TCharSet; virtual;
    function    Separators: TCharArray; virtual;
    function    SeparatorCount: integer; virtual;
    function    UseSigns: boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    ValidateEntry: boolean; virtual;
    procedure   Commit;
    property    Field: TEpiField read FField write SetField;
    property    RecNo: integer read FRecNo write SetRecNo;
    property    JumpToNext: boolean read FJumpToNext write FJumpToNext;
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
  epidocument, episettings, dataform_frame;

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

  Name := FField.Id;
  MaxLength := Field.Length;

  Caption   := '';
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
    bsNone:   SideBuf := 0;
    bsSingle: SideBuf := {$IFDEF MSWINDOWS} 7 {$ELSE} 6 {$ENDIF};
  end;

  //         Side buffer (pixel from controls left side to first character.
  Width   := (SideBuf * 2) + Cv.GetTextWidth(S) * FField.Length;

  with FQuestionLabel do
  begin
    Left    := Field.Question.Left;
    Top     := Field.Question.Top;
    Caption := Field.Question.Caption.Text;
  end;

  with FNameLabel do
  begin
    Caption := Field.Name;
    Left    := FQuestionLabel.Left - (FNameLabel.Width + 5);
    Top     := FQuestionLabel.Top;
    if not Settings.ShowFieldNames then
      Visible := false;
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

  FNameLabel.Parent := NewParent;
  FQuestionLabel.Parent := NewParent;
end;

function TFieldEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
begin
  UTF8Key := UTF16ToUTF8(WC);
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

function TFieldEdit.PreUTF8KeyPress(var UTF8Key: TUTF8Char;
  var SepCount: integer; var InheritHandled: boolean): boolean;
var
  i, n: integer;
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
  if (SelLength = 0) and (UTF8Length(Text) = (MaxLength-1)) then
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

constructor TFieldEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNameLabel := TLabel.Create(Self);
  FQuestionLabel := TLabel.Create(Self);
  FRecNo := -1;
end;

destructor TFieldEdit.Destroy;
begin
  FNameLabel.Free;
  FQuestionLabel.Free;
  inherited Destroy;
end;

function TFieldEdit.ValidateEntry: boolean;
var
  S: WideString;
begin
  S := Trim(UTF8ToUTF16(Text));
  if (S = '.') or (S = '') then
  begin
    Text := '';
    exit(true);
  end else
    exit(false);
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

{ TIntegerEdit }

function TIntegerEdit.ValidateEntry: boolean;
var
  I: EpiInteger;
  Code: integer;
begin
  result := true;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;

  Val(Text, I, Code);
  if (Code <> 0) then exit(false);
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
  Code: Integer;
begin
  result := true;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;

  if not TryStrToFloat(Text, F) then exit(false);
end;

function TFloatEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: Integer;
begin
  if PreUTF8KeyPress(UTF8Key, N, Result) then exit;

  // Validate position of separator... (cannot be placed beyond #integers)
  if IsSeparator and (Caret > (Field.Length - Field.Decimals)) then
    exit;

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

{ TStringEdit }

function TStringEdit.ValidateEntry: boolean;
begin
  Result := true;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;
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
  A, B, C: String;
  Al, Bl, Cl: Integer;
  ThisYear: Word;
  S: String;
begin
  Result := true;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;

  Sep := String(DateSeparator);
  DateStr := StringsReplace(Text, ['/', '-', '\', '.'], [Sep, Sep, Sep, Sep], [rfReplaceAll]);

  DecodeDate(Date, Y, M, D);
  ThisYear := Y;

  A := Copy2SymbDel(DateStr, DateSeparator);
  Al := Length(A);
  B := Copy2SymbDel(DateStr, DateSeparator);
  Bl := Length(B);
  C := Copy2SymbDel(DateStr, DateSeparator);
  Cl := Length(C);

  case Field.FieldType of
    ftDMYDate,
    ftMDYDate:
      begin
        if (Al > 2) or (Bl > 2) or (Cl > 4) then exit(false);

        if Field.FieldType = ftDMYDate then
        begin
          if (Al > 0) then D := StrToInt(A);
          if (Bl > 0) then M := StrToInt(B);
        end else begin
          // Only 2 digits enteres -> any case, it's considered to be the day.
          if (Al > 0) and (Bl = 0) then D := StrToInt(A);
          if (Al > 0) and (Bl > 0) then M := StrToInt(A);
          if (Bl > 0) then D := StrToInt(B);
        end;
        if (Cl > 0) then Y := StrToInt(C);
      end;
    ftYMDDate:
      begin
        if (Al > 4) or (Bl > 2) or (Cl > 2) then exit(false);
        if (Al > 0) and (Al <= 2) and (Bl+Cl = 0) then
          D := StrToInt(A)
        else begin
          if (Al > 0) then Y := StrToInt(A);
          if (Bl > 0) then M := StrToInt(B);
          if (Cl > 0) then D := StrToInt(C);
        end;
      end;
  end;

  // 2 year digit conversion.
  if Y < 100 then
    if Y <= (ThisYear-2000) then  // TODO: Make 2-year limit variable.
      Y += 2000
    else
      Y += 1900;

  // I don't what to use try-except... :)
  if (Y <= 0) or (Y >= 2100) then exit(false);
  if (M <= 0) or (M > 12) then exit(false);
  case M of
    1,3,5,7,8,10,12:
      if (D <= 0) or (D > 31) then exit(false);
    4,6,9,11:
      if (D <= 0) or (D > 30) then exit(false);
    2:
      if ((Y mod 4  = 0) and (Y mod 100 <> 0)) or (Y mod 400 = 0) then      // leap year
        begin if (D <= 0) or (D > 29) then exit(false); end
      else
        begin if (D <= 0) or (D > 28) then exit(false); end;
  end;

  case Field.FieldType of
    ftDMYDate, ftDMYToday: S := 'DD/MM/YYYY';
    ftMDYDate, ftMDYToday: S := 'MM/DD/YYYY';
    ftYMDDate, ftYMDToday: S := 'YYYY/MM/DD';
  end;
  Text := FormatDateTime(S, EncodeDate(Y,M,D));
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
  SetLength(Result, 3);
  Result[0] := '-';
  Result[1] := '.';
  Result[2] := '/';
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
  A,B,C: String;
  Al,Bl,Cl: Integer;
  H, M, S: Word;
begin
  Result := true;;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;

  Sep := String(TimeSeparator);
  TimeStr := StringsReplace(Text, ['/', '-', '\', '.'], [Sep, Sep, Sep, Sep], [rfReplaceAll]);

  A := Copy2SymbDel(TimeStr, TimeSeparator);
  Al := Length(A);
  B := Copy2SymbDel(TimeStr, TimeSeparator);
  Bl := Length(B);
  C := Copy2SymbDel(TimeStr, TimeSeparator);
  Cl := Length(C);

  H := 0; M := 0; S := 0;
  if Al > 0 then H := StrToInt(A);
  if Bl > 0 then M := StrToInt(B);
  if Cl > 0 then S := StrToInt(C);

  if H > 23 then exit(false);
  if M > 59 then exit(false);
  if S > 59 then exit(false);

  Text := FormatDateTime('HH:NN:SS', EncodeTime(H, M, S, 0));
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
  Result := true;
end;

end.

