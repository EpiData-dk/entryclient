unit fieldedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Graphics, epicustombase, epidatafiles,
  LCLType, LMessages;


type

  { TFieldEdit }

  TFieldEdit = class(TEdit)
  private
    FField: TEpiField;
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
    procedure   SetParent(NewParent: TWinControl); override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    PreUTF8KeyPress(var UTF8Key: TUTF8Char; var InheritHandled: boolean): boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    ValidateEntry: boolean; virtual;
    procedure   Commit;
    property    Field: TEpiField read FField write SetField;
    property    RecNo: integer read FRecNo write SetRecNo;
  end;

  { TIntegerEdit }

  TIntegerEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  public
    function    ValidateEntry: boolean; override;
  end;

  { TFloatEdit }

  TFloatEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
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
  public
    function    ValidateEntry: boolean; override;
  end;

  { TTimeEdit }

  TTimeEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  public
    function    ValidateEntry: boolean; override;
  end;

implementation

uses
  Forms, epidatafilestypes, entryprocs, LCLProc, strutils,
  epistringutils;

{ TFieldEdit }

procedure TFieldEdit.SetField(const AValue: TEpiField);
var
  S: string;
  Cv: TCanvas;
  SideBuf: integer;
begin
  if FField = AValue then exit;
  FField := AValue;
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

  case BorderStyle of
    bsNone:   SideBuf := 0;
    bsSingle: SideBuf := 6;
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
  if Field.IsMissing[RecNo] then
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
  var InheritHandled: boolean): boolean;
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

  if (Caret = 1) and (WC = '.') then
  begin
    InheritHandled := inherited DoUTF8KeyPress(UTF8Key);
    exit(true);
  end;

  UTF8Key := '';
  InheritHandled := false;
  if (SelLength = 0) and (UTF8Length(Text) = MaxLength) then exit(true);
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
begin
  if Text = '' then
    Field.IsMissing[RecNo] := true
  else
    Field.AsString[RecNo] := Text;
end;

{ TIntegerEdit }

function TIntegerEdit.ValidateEntry: boolean;
var
  I, Code: integer;
begin
  result := true;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;

  Val(Text, I, Code);
  if (Code <> 0) then exit(false);

//  Field.AsInteger[RecNo] := I;
end;

function TIntegerEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit(Result);

  if not(WC in IntegerChars) then exit;
  // Sign operators are only allowed at pos 1.
  if (WC in ['+','-']) and (Caret > 1) then exit;

  Result := inherited DoUTF8KeyPress(UTF8Key);
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
{  try
    Field.AsString[RecNo] := Text;
  except
    result := false;
  end;}
end;

function TFloatEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  IsSeparator: Boolean;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

  N := CountChar(Text, '.');
  N += CountChar(Text, ',');

  IsSeparator := false;
  if (WC in ['.',',']) then IsSeparator := true;

  // Check for allowed keys.
  if not(WC in FloatChars) then exit;
  // Sign operators are only allowed at pos 0.
  if (WC in ['+','-']) and (Caret > 1) then exit;
  // No more than 1 separator is allowed at any time.
  if IsSeparator and (N >= 1) then exit;

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

{ TStringEdit }

function TStringEdit.ValidateEntry: boolean;
begin
  Result := true;
  if not Modified then exit;
  if Inherited ValidateEntry then exit;

//  Field.AsString[RecNo] := Text;
end;

function TStringEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

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
          if (Al > 0) then M := StrToInt(A);
          if (Bl > 0) then D := StrToInt(B);
        end;
        if (Cl > 0) then Y := StrToInt(C);
      end;
    ftYMDDate:
      begin
        if (Al > 4) or (Bl > 2) or (Cl > 2) then exit(false);
        if (Al > 0) then Y := StrToInt(A);
        if (Bl > 0) then M := StrToInt(B);
        if (Cl > 0) then D := StrToInt(C);
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

//  Field.AsDate[RecNo] := TruncToInt(EncodeDate(Y,M,D));
end;

function TDateEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  IsSeparator: Boolean;
  SepPos: TIntegerSet;
  AutoPlace: Boolean;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

  N := CountChar(Text, '-');
  N += CountChar(Text, '/');
  N += CountChar(Text, '.');

  IsSeparator := false;
  if (WC in ['-','/','.']) then IsSeparator := true;
  if IsSeparator then WC := DateSeparator;

  if not(WC in DateChars) then exit(false);
  // No more than two separators.
  if IsSeparator and (N >= 2) and (SelLength = 0) then exit(false);
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

  Result := inherited DoUTF8KeyPress(UTF8Key);
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
//  Field.AsTime[RecNo] := EncodeTime(H, M, S, 0);
end;

function TTimeEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  IsSeparator: Boolean;
  AutoPlace: Boolean;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

  N := CountChar(Text, '-');
  N += CountChar(Text, ':');
  N += CountChar(Text, '.');

  IsSeparator := false;
  if (WC in ['-',':','.']) then IsSeparator := true;
  if IsSeparator then WC := TimeSeparator;

  if not(WC in TimeChars) then exit;
  // No more than two separators.
  if IsSeparator and (N >= 2) and (SelLength = 0) then exit(false);
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

  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

end.

