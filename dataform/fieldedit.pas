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
  Seps: Array of WideChar;
begin
  // Compare the pressed key to the field type. Sets to '' (empty) key if
  // the type is not allowed.
  // Also catch to many separator in float, date and time field.

  WC := UTF8ToUTF16(UTF8Key)[1];

  case Field.FieldType of
    ftString, ftUpperString: ;
    ftInteger: if not(WC in IntegerChars) then UTF8Key := '';
    ftBoolean: if not(WC in BooleanChars) then UTF8Key := '';
    ftDMYDate,
    ftMDYDate,
    ftYMDDate: begin
                 if not(WC in DateChars)    then UTF8Key := '';
                 Seps := ('/', '-', '.');
               end;
    ftFloat:   begin
                 if not(WC in FloatChars) then UTF8Key := '';
{                 if WC <> #0 then
                 begin
                   S := FieldEdit.Text;
                   if Decimals > 0 then
                   begin
                     if (System.Length(S) = Length - 1 - Decimals) and
                        (Pos('.',S)=0) and (Pos(',',S)=0) and
                        (ORD(WC)<>8) and (WC<>',') and (WC<>'.') then
                     begin
                       FieldEdit.Text:=S + DecimalSeparator;
                       FieldEdit.SelStart := System.Length(FieldEdit.Text);
                     end;
                   end;
                 end;        }
               end;
  end;

{
  if (FieldEdit.Field.FieldType = ftUpperString) then
    UTF8Key := UTF8UpperCase(UTF8Key);

  l := Length(UTF8Key);
  if (l > 1) then
  begin
    if not (FieldEdit.Field.FieldType in StringFieldTypes) then
      UTF8Key := '';
    exit;
  end;

  Key := UTF8Key[1];
  if Key in SystemChars then
  begin
    if Word(Key) = VK_RETURN then
    begin
      l := FFieldEditList.IndexOf(FieldEdit)+1;
      if l = FFieldEditList.Count then
      begin
        NextRecAction.Execute;
        Exit;
      end;

      TFieldEdit(FFieldEditList[l]).SetFocus;  // Jump to next control.
    end;
    exit;
  end;

  with FieldEdit.Field do
  begin
    case FieldType of
      ftInteger: if not(Key in IntegerChars) then Key:=#0;
      ftBoolean: if not(Key in BooleanChars) then Key:=#0;
      ftDMYDate,
      ftMDYDate,
      ftYMDDate: if not(Key in DateChars)    then Key:=#0;
      ftFloat:   begin
                   if not(Key in FloatChars) then Key:=#0;
                   if Key <> #0 then
                   begin
                     S := FieldEdit.Text;
                     if Decimals > 0 then
                     begin
                       if (System.Length(S) = Length - 1 - Decimals) and
                          (Pos('.',S)=0) and (Pos(',',S)=0) and
                          (ORD(Key)<>8) and (Key<>',') and (Key<>'.') then
                       begin
                         FieldEdit.Text:=S + DecimalSeparator;
                         FieldEdit.SelStart := System.Length(FieldEdit.Text);
                       end;
                     end;
                   end;
                 end;
    end;
  end;
  UTF8Key[1] := Key;

                                  }

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

