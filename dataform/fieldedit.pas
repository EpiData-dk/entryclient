unit fieldedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Graphics, epicustombase, epidatafiles,
  LCLType;


type

  { TFieldEdit }

  TFieldEdit = class(TEdit)
  private
    FField: TEpiField;
    FNameLabel: TLabel;
    FQuestionLabel: TLabel;
    FRecNo: integer;
    procedure   SetField(const AValue: TEpiField);
    procedure   SetRecNo(const AValue: integer);
    procedure   UpdateText;
  protected
    WC: WideChar;
    procedure   SetParent(NewParent: TWinControl); override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    PreUTF8KeyPress(var UTF8Key: TUTF8Char; var InheritHandled: boolean): boolean;
    procedure   EditingDone; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    Field: TEpiField read FField write SetField;
    property    RecNo: integer read FRecNo write SetRecNo;
  end;

  { TIntegerEdit }

  TIntegerEdit = class(TFieldEdit)
  protected
    procedure   EditingDone; override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  end;

  { TFloatEdit }

  TFloatEdit = class(TFieldEdit)
  protected
    procedure   EditingDone; override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  end;

  { TStringEdit }
  TStringEdit = class(TFieldEdit)
  protected
    procedure   EditingDone; override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  end;

  { TDateEdit }

  TDateEdit = class(TFieldEdit)
  protected
    procedure   EditingDone; override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  end;

  { TTimeEdit }

  TTimeEdit = class(TFieldEdit)
  protected
    procedure   EditingDone; override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
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
  case Field.FieldType of
    ftString, ftUpperString:
      S := 'W';
  else
    S := '4';
  end;

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

  {$IFDEF EPI_DEBUG}
  WriteStr(S,  Field.FieldType);
  ShowHint := true;
  Hint := WideFormat(
    'FieldName: %s' + LineEnding +
    'Length:    %d' + LineEnding +
    'Type:      %s',
    [Field.Name, Field.Length, S]);
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
  Text := Field.AsString[RecNo];
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
  UTF8Key := WC;
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

  UTF8Key := '';
  InheritHandled := false;
  if (SelLength = 0) and (UTF8Length(Text) = MaxLength) then exit(true);
  result := false;
end;

procedure TFieldEdit.EditingDone;
begin
  UpdateText;
  inherited EditingDone;
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

{ TIntegerEdit }

procedure TIntegerEdit.EditingDone;
var
  I: integer;
begin
  if not Modified then exit;

  if not IsEpiInteger(Text, I) then exit;
  Field.AsInteger[RecNo] := I;

  inherited EditingDone;
end;

function TIntegerEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  Caret: LongInt;

begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit(Result);

  Caret := CaretPos.X;
  if not(WC in IntegerChars) then exit;
  // Sign operators are only allowed at pos 0.
  if (WC in ['+','-']) and (Caret > 0) and (SelLength = 0) then exit;

  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TFloatEdit }

procedure TFloatEdit.EditingDone;
begin
  if not Modified then exit;

  //  if not IsEpiInteger(Text, I) then exit;
  Field.AsString[RecNo] := Text;

  inherited EditingDone;
end;

function TFloatEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  IsSeparator: Boolean;
  Caret: LongInt;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

  N := CountChar(Text, '.');
  N += CountChar(Text, ',');

  IsSeparator := false;
  if (WC in ['.',',']) then IsSeparator := true;

  // Check for allowed keys.
  if not(WC in FloatChars) then exit;
  // Sign operators are only allowed at pos 0.
  if (WC in ['+','-']) and (Caret > 0) and (SelLength = 0) then exit;
  // No more than 1 separator is allowed at any time.
  if IsSeparator and (N >= 1) then exit;

  Caret := CaretPos.X;

  // Validate position of separator... (cannot be placed beyond #integers)
  if IsSeparator and (Caret > (Field.Length - Field.Decimals - 1)) then
    exit;

  // Auto place the separator...
  if (not IsSeparator) and (N=0) and
     (Caret = (Field.Length - Field.Decimals - 1)) then
  begin
    Text := Text + DecimalSeparator;
    CaretPos := Point(Caret + 1, 0);
  end;

  if IsSeparator then WC := DecimalSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TStringEdit }

procedure TStringEdit.EditingDone;
begin
  if not Modified then exit;

  Field.AsString[RecNo] := Text;
  inherited EditingDone;
end;

function TStringEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TDateEdit }

procedure TDateEdit.EditingDone;
var
  DateStr: String;
  Sep: String;
  Y, M, D: word;
  A, B, C: String;
  Al, Bl, Cl: Integer;
  ThisYear: Word;

begin
  if not Modified then exit;

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
        if (Al > 2) or (Bl > 2) or (Cl > 4) then exit;

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
        if (Al > 4) or (Bl > 2) or (Cl > 2) then exit;
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

  // TODO : Errorhandling when date not valid.
  Field.AsDate[RecNo] := TruncToInt(EncodeDate(Y,M,D));
  inherited EditingDone;
end;

function TDateEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  IsSeparator: Boolean;
  Caret: LongInt;
  SepPos: TIntegerSet;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

  N := CountChar(Text, '-');
  N += CountChar(Text, '/');
  N += CountChar(Text, '.');

  IsSeparator := false;
  if (WC in ['-','/','.']) then IsSeparator := true;

  if not(WC in DateChars) then exit;
  if IsSeparator and (N >= 2) and (SelLength = 0) then exit(false);

  Caret := CaretPos.X;

  SepPos := [2,5];
  if Field.FieldType = ftYMDDate then
    SepPos := [4,7];

  // Auto place the separator...
  if (not IsSeparator) and (N<2) and
     (Caret in SepPos) then
  begin
    Text := Text + DateSeparator;
    CaretPos := Point(Caret + 1, 0);
  end;

  if IsSeparator then WC := DateSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TTimeEdit }

procedure TTimeEdit.EditingDone;
var
  Sep: String;
  TimeStr: String;
  A,B,C: String;
  Al,Bl,Cl: Integer;
begin
  if not Modified then exit;

  Sep := String(TimeSeparator);
  TimeStr := StringsReplace(Text, ['/', '-', '\', '.'], [Sep, Sep, Sep, Sep], [rfReplaceAll]);

  A := Copy2SymbDel(TimeStr, TimeSeparator);
  Al := Length(A);
  B := Copy2SymbDel(TimeStr, TimeSeparator);
  Bl := Length(B);
  C := Copy2SymbDel(TimeStr, TimeSeparator);
  Cl := Length(C);

  if (Al > 0) and (StrToInt(A) > 23) then raise Exception.Create('fielderror');
  if (Bl > 0) and (StrToInt(B) > 59) then abort;
  if (Cl > 0) and (StrToInt(C) > 59) then abort;

  Field.AsTime[RecNo] := EncodeTime(StrToInt(A), StrToInt(B), StrToInt(C), 0);
  inherited EditingDone;
end;

function TTimeEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  IsSeparator: Boolean;
  Caret: LongInt;
begin
  if PreUTF8KeyPress(UTF8Key, Result) then exit;

  N := CountChar(Text, '-');
  N += CountChar(Text, ':');

  IsSeparator := false;
  if (WC in ['-',':']) then IsSeparator := true;

  if not(WC in TimeChars) then exit;
  if IsSeparator and (N >= 2) and (SelLength = 0) then exit(false);

  Caret := CaretPos.X;

  // Auto place the separator...
  if (not IsSeparator) and (N<2) and
     (Caret in [2,5]) then
  begin
    Text := Text + TimeSeparator;
    CaretPos := Point(Caret + 1, 0);
  end;

  if IsSeparator then WC := TimeSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

end.

