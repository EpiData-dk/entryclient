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
    procedure   SetField(const AValue: TEpiField);
  protected
    procedure   SetParent(NewParent: TWinControl); override;
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
    function    PreUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    Field: TEpiField read FField write SetField;
  end;

  { TFloatEdit }

  TFloatEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  end;

  { TDateEdit }

  TDateEdit = class(TFieldEdit)
  protected
    function    DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean; override;
  end;

  { TIntegerEdit }

  TIntegerEdit = class(TFieldEdit)
  protected
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

procedure TFieldEdit.SetParent(NewParent: TWinControl);
begin
  inherited SetParent(NewParent);
  if csDestroying in ComponentState then exit;

  FNameLabel.Parent := NewParent;
  FQuestionLabel.Parent := NewParent;
end;

function TFieldEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  WC: WideChar;
  N: LongInt;
begin
 { // Compare the pressed key to the field type. Sets to '' (empty) key if
  // the type is not allowed.
  // Also catch to many separator in float, date and time field.

  // We catch keypresses "below" space here, since eg. backspace generates #8, we
  // must accept it!
  WC := UTF8ToUTF16(UTF8Key)[1];
  if WC < #32 then
    exit(inherited DoUTF8KeyPress(UTF8Key));

  if UTF8Length(Text) = MaxLength then exit(false);

  // Strict type checking. (Eg. number in int-field, etc.)
  case Field.FieldType of
    ftString, ftUpperString: ;
    ftInteger: if not(WC in IntegerChars) then UTF8Key := '';
    ftBoolean: if not(WC in BooleanChars) then UTF8Key := '';
    ftDMYDate,
    ftMDYDate,
    ftYMDDate: if not(WC in DateChars)  then UTF8Key := '';
    ftTime:    if not(WC in TimeChars)  then UTF8Key := '';
    ftFloat:   if not(WC in FloatChars) then UTF8Key := '';
  end;
  if UTF8Key = '' then exit(true);

  // Check for separators.
  N := CountChar(Text, '.'); // Float, date
  N += CountChar(Text, ','); // Float
  N += CountChar(Text, '-'); // Date, time
  N += CountChar(Text, '/'); // Date
  N += CountChar(Text, ':'); // Time
  case Field.FieldType of
    ftDMYDate,
    ftMDYDate,
    ftYMDDate: if (N >= 2) and (WC in ['.','-','/']) then UTF8Key := '';
    ftTime:    if (N >= 2) and (WC in ['-',':']) then UTF8Key := '';
    ftFloat:   if (N >= 1) and (WC in ['.',',']) then UTF8Key := '';
  end;
  if UTF8Key = '' then exit(true);

  Result := inherited DoUTF8KeyPress(UTF8Key);     }
end;

function TFieldEdit.PreUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  WC: WideChar;
begin
  WC := UTF8ToUTF16(UTF8Key)[1];
  if WC < #32 then
  begin
    inherited DoUTF8KeyPress(UTF8Key);
    exit(true);
  end;

  if UTF8Length(Text) = MaxLength then exit(true);
end;

constructor TFieldEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNameLabel := TLabel.Create(Self);
  FQuestionLabel := TLabel.Create(Self);
end;

destructor TFieldEdit.Destroy;
begin
  FNameLabel.Free;
  FQuestionLabel.Free;
  inherited Destroy;
end;

{ TFloatEdit }

function TFloatEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  WC: WideChar;
  IsSeparator: Boolean;
  Caret: LongInt;
begin
  WC := UTF8ToUTF16(UTF8Key)[1];
  if WC < #32 then
    exit(inherited DoUTF8KeyPress(UTF8Key));

  UTF8Key := '';
  N := CountChar(Text, '.');
  N += CountChar(Text, ',');

  IsSeparator := false;
  if (WC in ['.',',']) then IsSeparator := true;

  if not(WC in FloatChars) then exit;
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

  if IsSeparator then
    UTF8Key := DecimalSeparator
  else
    UTF8Key := WC;

  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TDateEdit }

function TDateEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  WC: WideChar;
  IsSeparator: Boolean;
begin
  WC := UTF8ToUTF16(UTF8Key)[1];
  if WC < #32 then
    exit(inherited DoUTF8KeyPress(UTF8Key));

  UTF8Key := '';
  N := CountChar(Text, '-');
  N += CountChar(Text, '/');
  N += CountChar(Text, '.');

  IsSeparator := false;
  if (WC in ['.',',']) then IsSeparator := true;

  if not(WC in DateChars) then exit;
  if IsSeparator and (N >= 2) then exit;

  if IsSeparator then UTF8Key := DateSeparator;
  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

{ TIntegerEdit }

function TIntegerEdit.DoUTF8KeyPress(var UTF8Key: TUTF8Char): boolean;
var
  N: LongInt;
  WC: WideChar;
begin
  WC := UTF8ToUTF16(UTF8Key)[1];
  if WC < #32 then
    exit(inherited DoUTF8KeyPress(UTF8Key));

  UTF8Key := '';

  if not(WC in IntegerChars) then exit;

  Result := inherited DoUTF8KeyPress(UTF8Key);
end;

end.

