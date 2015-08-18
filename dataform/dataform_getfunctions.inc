type
  TGetFunctionType = (gftIndexedString, gftFieldEdit);
  TGetFunction = record
    FuncType: TGetFunctionType;
    FuncPtr: PtrUInt;
    FuncData: PtrUInt;
  end;
  TGetFunctions = array of TGetFunction;

  TGetFEFunction = function (Const FE: TFieldEdit): string;

  TGetIdxStrFunction = function (Const FmtStr: string; SIdx, EIdx: integer): string;
  TGetIdxStrRec = record
    SIdx: Integer;
    EIdx: Integer;
  end;
  PGetIdxStrRec = ^TGetIdxStrRec;

function GetF(Const FE: TFieldEdit): string;
begin
  result := FE.Field.Name;
end;

function GetQ(Const FE: TFieldEdit): string;
begin
  Result := FE.Field.Question.Text;
end;

function GetD(Const FE: TFieldEdit): string;
begin
  Result := FE.Text;
end;

function GetV(Const FE: TFieldEdit): string;
begin
  Result := '';
  if Assigned(FE.Field.ValueLabelSet) and
     (FE.Text <> '') and
     (FE.Field.ValueLabelSet.ValueLabelExists[FE.Text])
  then
    result := FE.Field.ValueLabelSet.ValueLabel[FE.Text].TheLabel.Text;
end;

function GetL(Const FE: TFieldEdit): string;
begin
  Result := GetV(FE);
  if Result = '' then
    Result := GetD(FE);
end;

function GetN(Const FE: TFieldEdit): string;
begin
  result := LineEnding;
end;

function GetT(Const FE: TFieldEdit): string;
begin
  result := #9;
end;

function GetStr(Const FmtStr: string; SIdx, EIdx: integer): string;
begin
  result := Copy(FmtStr, SIdx, EIdx-SIdx);
end;

function DecodeFormat(FormatStr: string): TGetFunctions;
var
  i: integer;
  ChPos: integer;
  ChLen: integer;
  l: Integer;
  OldPos: Integer;
  Escaped: Boolean;
  IdxRec: PGetIdxStrRec;

  procedure AddFunction(var Res: TGetFunctions;
                            FType: TGetFunctionType;
                            Func: PtrUInt;
                            Data: PtrUInt);
  begin
    l := Length(Res);
    SetLength(Res, l + 1);
    with Res[L] do
    begin
      FuncType := FType;
      FuncPtr := Func;
      FuncData := Data;
    end;
  end;

begin
  Result := nil;

  ChPos := 1;
  ChLen := Length(FormatStr);
  OldPos := 1;

  while ChPos <= ChLen do
  begin
    while (ChPos <= ChLen) and
          (not (FormatStr[ChPos] = '%')) and
          (not (FormatStr[ChPos] = '\'))
    do
      inc(ChPos);

    if ChPos > OldPos then
    begin
      IdxRec := New(PGetIdxStrRec);
      IdxRec^.SIdx := OldPos;
      IdxRec^.EIdx := ChPos;
      AddFunction(Result, gftIndexedString, PtrUInt(@GetStr), PtrUInt(IdxRec)); // TODO: Kopier "rå" tekst
      OldPos := ChPos;
      Continue;
    end;

    Escaped := FormatStr[ChPos] = '\';
    Inc(ChPos);
{
    %f Returns the Field Name (even if it not shown on the form)
    %q Returns the Field Question
    %v Returns the label part of a valuelabel if availble (even if the label is not shown on the form)
    %l Returns the label part of a valuelabel if exists otherwise returns data for the record
    %p : include project file name

    %d Returns the current data for the record (or blank if no data)
    %dt : include date of current "copy to clipboard"
    %df : Include dataform name

    %ti : include time of current "copy to clipboard"

    \n Inserts a “newline” into the text (usefull for have eg. each field on a seperate line)
    \t Inserts a “tab” into the text
    \% Insert the character “%” into the text (otherwise the program interprets the % as a specifier.

    Applied to "copy field to clipboard" - ignored on "copy record to clipboard":
    %k : include any key defined for current dataform (only applies to
    will be with field name, e.g. key id: 100 datevisit: 18-9-2015 childno: 3   }

    case UpCase(FormatStr[ChPos]) of
      'F': AddFunction(Result, gftFieldEdit, PtrUInt(@GetF), 0);
      'Q': AddFunction(Result, gftFieldEdit, PtrUInt(@GetQ), 0);
      'D': begin
             case UpCase(FormatStr[ChPos+1]) of
               ''
               ''
             else
               AddFunction(Result, gftFieldEdit, PtrUInt(@GetD), 0);
             end;
           end;
      'V': AddFunction(Result, gftFieldEdit, PtrUInt(@GetV), 0);
      'L': AddFunction(Result, gftFieldEdit, PtrUInt(@GetL), 0);
      'N': AddFunction(Result, gftFieldEdit, PtrUInt(@GetN), 0);
      'T': AddFunction(Result, gftFieldEdit, PtrUInt(@GetT), 0);
    else
      // ERROR!
    end;

    Inc(ChPos);
    OldPos := ChPos;
  end;
end;

