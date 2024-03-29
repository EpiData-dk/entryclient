type
  TGetFunctionType = (
    gftIndexedString,   // Extracts text from format string that is NOT escaped:
                        //   Data = PGetIdxStrRec

    gftCustomEdit        // Calls neded function based on format specifiers
  );

  TGetFunction = record
    FuncType: TGetFunctionType;
    FuncPtr: PtrUInt;
    FuncData: PtrUInt;
  end;
  TGetFunctions = array of TGetFunction;

  TGetFEFunction = function (Const CE: TCustomEdit): string;

  TGetIdxStrFunction = function (Const FmtStr: string; SIdx, EIdx: integer): string;
  TGetIdxStrRec = record
    SIdx: Integer;
    EIdx: Integer;
  end;
  PGetIdxStrRec = ^TGetIdxStrRec;

  TGetGlobalFuncEnum = (
    ggfDataFormName,
    ggfProjectName,
    ggfCurrentDate,
    ggfCycleNo,
    ggfFileName,
    ggfKeyFields
  );
  TGetGlobalFuncSet = set of TGetGlobalFuncEnum;

function GetF(Const CE: TCustomEdit): string;
begin
  result := (CE as IEntryDataControl).Field.Name;
end;

function GetQ(Const CE: TCustomEdit): string;
begin
  Result := (CE as IEntryDataControl).Field.Question.Text;
end;

function GetD(Const CE: TCustomEdit): string;
begin
  Result := CE.Text;
end;

function GetV(Const CE: TCustomEdit): string;
var
  DC: IEntryDataControl;
begin
  Result := '';
  DC := (CE as IEntryDataControl);
  if Assigned(DC.Field.ValueLabelSet) and
     (CE.Text <> '') and
     (DC.Field.ValueLabelSet.ValueLabelExists[CE.Text])
  then
    result := DC.Field.ValueLabelSet.ValueLabel[CE.Text].TheLabel.Text;
end;

function GetL(Const CE: TCustomEdit): string;
begin
  Result := GetV(CE);
  if Result = '' then
    Result := GetD(CE);
end;

function GetN(Const CE: TCustomEdit): string;
begin
  result := LineEnding;
end;

function GetT(Const CE: TCustomEdit): string;
begin
  result := #9;
end;

function GetStr(Const FmtStr: string; SIdx, EIdx: integer): string;
begin
  result := Copy(FmtStr, SIdx, EIdx-SIdx);
end;

function DecodeFormat(FormatStr: string; out Globals: TGetGlobalFuncSet): TGetFunctions;
var
  ChPos: integer;
  ChLen: integer;
  OldPos: Integer;

  procedure AddFunction(var Res: TGetFunctions;
                            FType: TGetFunctionType;
                            Func: PtrUInt;
                            Data: PtrUInt);
  var
    l: Integer;
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

  procedure CreateIndexedString(Const StartIdx, EndIdx: Integer);
  var
    IdxRec: PGetIdxStrRec;
  begin
    IdxRec := New(PGetIdxStrRec);
    IdxRec^.SIdx := StartIdx;
    IdxRec^.EIdx := EndIdx;
    AddFunction(Result, gftIndexedString, PtrUInt(@GetStr), PtrUInt(IdxRec));
  end;

begin
  Result := nil;
  Globals := [];

  ChPos := 1;
  ChLen := Length(FormatStr);
  OldPos := 1;

  while ChPos <= ChLen do
  begin
    while (ChPos <= ChLen) and
          (not (FormatStr[ChPos] = '%'))
    do
      inc(ChPos);

    if ChPos > OldPos then
    begin
      CreateIndexedString(OldPos, ChPos);
      OldPos := ChPos;
      Continue;
    end;

    {
    %f Returns the Field Name (even if it not shown on the form)
    %q Returns the Field Question
    %v Returns the label part of a valuelabel if availble (even if the label is not shown on the form)
    %l Returns the label part of a valuelabel if exists otherwise returns data for the record
    %d Returns the current data for the record (or blank if no data)

    %t Inserts a “tab” into the text
    %n Inserts a “newline” into the text (usefull for have eg. each field on a seperate line)
    %% Insert the character “%” into the text (otherwise the program interprets the % as a specifier.

    %gd Include current date and time
    %gn Include project file including full path
    %gc Include project cycle no.
    %gp Include project title
    %gf Include dataform name

    Applied to "copy field to clipboard" - ignored on "copy record to clipboard":
    %gk : include any key defined for current dataform (only applies to
    will be with field name, e.g. key id: 100 datevisit: 18-9-2015 childno: 3
    }

    Inc(ChPos);
    case UpCase(FormatStr[ChPos]) of
      'F': AddFunction(Result, gftCustomEdit, PtrUInt(@GetF), 0);
      'Q': AddFunction(Result, gftCustomEdit, PtrUInt(@GetQ), 0);
      'V': AddFunction(Result, gftCustomEdit, PtrUInt(@GetV), 0);
      'L': AddFunction(Result, gftCustomEdit, PtrUInt(@GetL), 0);
      'D': AddFunction(Result, gftCustomEdit, PtrUInt(@GetD), 0);
      'T': AddFunction(Result, gftCustomEdit, PtrUInt(@GetT), 0);
      'N': AddFunction(Result, gftCustomEdit, PtrUInt(@GetN), 0);
      '%': CreateIndexedString(OldPos, ChPos);
      'G': begin
             Inc(ChPos);
             case UpCase(FormatStr[ChPos]) of
               'D': Include(Globals, ggfCurrentDate);
               'F': Include(Globals, ggfDataFormName);
               'C': Include(Globals, ggfCycleNo);
               'P': Include(Globals, ggfProjectName);
               'N': Include(Globals, ggfFileName);
               'K': Include(Globals, ggfKeyFields);
             else
               // ERROR
             end;
           end;
    else
      // ERROR!
    end;

    Inc(ChPos);
    OldPos := ChPos;
  end;
end;

