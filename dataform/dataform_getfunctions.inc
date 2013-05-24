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
    case UpCase(FormatStr[ChPos]) of
      'F': AddFunction(Result, gftFieldEdit, PtrUInt(@GetF), 0);
      'Q': AddFunction(Result, gftFieldEdit, PtrUInt(@GetQ), 0);
      'D': AddFunction(Result, gftFieldEdit, PtrUInt(@GetD), 0);
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

