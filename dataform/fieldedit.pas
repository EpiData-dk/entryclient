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
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    Field: TEpiField read FField write SetField;
  end;


implementation

uses
  Forms, epidatafilestypes, entryprocs, LCLProc, strutils;

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
//  Seps: Array of WideChar;
begin
  // Compare the pressed key to the field type. Sets to '' (empty) key if
  // the type is not allowed.
  // Also catch to many separator in float, date and time field.

  WC := UTF8ToUTF16(UTF8Key)[1];
  if WC < #32 then
    exit(inherited DoUTF8KeyPress(UTF8Key));

  // Strict type checking. (Eg. number in int-field, etc.)
  case Field.FieldType of
    ftString, ftUpperString: ;
    ftInteger: if not(WC in IntegerChars) then UTF8Key := '';
    ftBoolean: if not(WC in BooleanChars) then UTF8Key := '';
    ftDMYDate,
    ftMDYDate,
    ftYMDDate: begin
                 if not(WC in DateChars)    then UTF8Key := '';
               end;
    ftFloat:   begin
                 if not(WC in FloatChars) then UTF8Key := '';
               end;
  end;

  // Check for separators.

  Result := inherited DoUTF8KeyPress(UTF8Key);
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

end.

