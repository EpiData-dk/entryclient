unit search;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epidatafiles;

type

  TSearchBinOp = (boAnd, boOr);
  TMatchCriteria = (mcEq, mcNEq, mcLEq, mcLT, mcGT, mcGEq, mcBegin, mcEnd, mcContains);

  { TSearchCondition }

  TSearchCondition = class
  private
    FBinOp: TSearchBinOp;
    FCaseSensitive: Boolean;
    FField: TEpiField;
    FMatchCriteria: TMatchCriteria;
    FText: string;
    procedure SetBinOp(const AValue: TSearchBinOp);
    procedure SetCaseSensitive(AValue: Boolean);
    procedure SetField(const AValue: TEpiField);
    procedure SetMatchCriteria(const AValue: TMatchCriteria);
    procedure SetText(const AValue: string);
  public
    constructor Create;
    property BinOp: TSearchBinOp read FBinOp write SetBinOp;
    property Field: TEpiField read FField write SetField;
    property MatchCriteria: TMatchCriteria read FMatchCriteria write SetMatchCriteria;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property Text: string read FText write SetText;
  end;


  TSearchDirection = (sdForward, sdBackward);
  TSearch = class
  private
    FConditionCount: integer;
    FDataFile: TEpiDataFile;
    FDirection: TSearchDirection;
    FList: TList;
    FOrigin: TSeekOrigin;
    function GetConditionCount: integer;
    function GetSearchCondiction(const index: integer): TSearchCondition;
  public
    constructor Create;
    property List: TList read FList;
    property ConditionCount: integer read GetConditionCount;
    property SearchCondiction[Const index: integer]: TSearchCondition read GetSearchCondiction;
    property Origin: TSeekOrigin read FOrigin write FOrigin;
    property Direction: TSearchDirection read FDirection write FDirection;
    property DataFile: TEpiDataFile read FDataFile write FDataFile;
  end;



function SearchFindNext(Const Search: TSearch; Const Index: integer): integer;
function SearchFindList(Const Search: TSearch; CurIndex: integer): TBoundArray;


implementation

uses
  Math, LazUTF8, epidatafilestypes, entryprocs;

function SearchFindNext(const Search: TSearch; const Index: integer): integer;
var
  Match: Boolean;
  SC: TSearchCondition;
  TmpRes: Boolean;
  i: Integer;
  S1: String;
  S2: String;

//  function Eq(Const Field: TEpiField; Const Text: string; Const Idx: integer): boolean;
  function Eq(Const SC: TSearchCondition; Const Idx: integer): boolean;
  begin
    case SC.Field.FieldType of
      ftBoolean: Result := ((SC.Field.AsBoolean[Idx] = 0) and (SC.Text[1] in BooleanNoChars)) or
                           ((SC.Field.AsBoolean[Idx] = 1) and (SC.Text[1] in BooleanYesChars));
      ftInteger,
      ftAutoInc: Result := SC.Field.AsInteger[Idx] = StrToInt(SC.Text);
      ftFloat:   Result := SameValue(SC.Field.AsFloat[Idx], StrToFloat(SC.Text), 0.0);
      ftDMYDate,
      ftMDYDate,
      ftYMDDate,
      ftDMYAuto,
      ftMDYAuto,
      ftYMDAuto: Result := SC.Field.AsDate[Idx] = StrToDate(SC.Text, TEpiDateField(SC.Field).FormatString, DateSeparator);
      ftTime,
      ftTimeAuto:  Result := SC.Field.AsTime[Idx] = StrToTime(SC.Text);
      ftString,
      ftUpperString:
        if SC.CaseSensitive then
          Result := UTF8CompareStr(SC.Field.AsString[Idx], SC.Text) = 0
        else
          Result := UTF8CompareText(SC.Field.AsString[Idx], SC.Text) = 0
    end;
  end;

//  function LT(Const Field: TEpiField; Const Text: string; Const Idx: integer): boolean;
  function LT(Const SC: TSearchCondition; Const Idx: integer): boolean;
  begin
    case SC.Field.FieldType of
      ftBoolean,
      ftInteger,
      ftAutoInc: Result := SC.Field.AsInteger[Idx] < StrToInt(SC.Text);
      ftFloat:   Result := (SC.Field.AsFloat[Idx] < StrToFloat(SC.Text)) and
                           (Not SameValue(SC.Field.AsFloat[Idx], StrToFloat(SC.Text), 0.0));
      ftDMYDate,
      ftMDYDate,
      ftYMDDate,
      ftDMYAuto,
      ftMDYAuto,
      ftYMDAuto: Result := SC.Field.AsDate[Idx] < StrToDate(SC.Text, TEpiDateField(SC.Field).FormatString, DateSeparator);
      ftTime,
      ftTimeAuto:  Result := SC.Field.AsTime[Idx] < StrToTime(SC.Text);
      ftString,
      ftUpperString:
        if SC.CaseSensitive then
          Result := UTF8CompareStr(SC.Field.AsString[Idx], SC.Text) < 0
        else
          Result := UTF8CompareText(SC.Field.AsString[Idx], SC.Text) = 0
    end;
  end;

begin
  Result := Index;

  while true do
  begin
    Match := true;

    if Result < 0 then exit(-1);
    if Result >= Search.DataFile.Size then exit(-1);

    For i := 0 to Search.ConditionCount - 1 do
    begin
      SC := Search.SearchCondiction[i];
      case SC.MatchCriteria of
        mcEq:  TmpRes := Eq(SC, Result);
        mcNEq: TmpRes := not (Eq(SC, Result));
        mcLEq: TmpRes := LT(SC, Result) or EQ(SC, Result);
        mcLT:  TmpRes := LT(SC, Result);
        mcGT:  TmpRes := not (LT(SC, Result) or Eq(SC, Result));
        mcGEq: TmpRes := not (LT(SC, Result));

        mcBegin,
        mcEnd,
        mcContains:
          begin
            If not (SC.Field.FieldType in StringFieldTypes) then
            begin
              TmpRes := False;
              Continue;
            end;

            S1 := SC.Text;
            S2 := SC.Field.AsString[Result];
            if not SC.CaseSensitive then
            begin
              S1 := UTF8LowerCase(S1);
              S2 := UTF8LowerCase(S2);
            end;

            Case SC.MatchCriteria of
              mcBegin:
                TmpRes := UTF8Pos(S1, S2) = 1;
              mcEnd:
                TmpRes := UTF8Pos(S1, S2) = UTF8Length(S2) - UTF8Length(S1);
              mcContains:
                TmpRes := UTF8Pos(S1, S2) >= 1;
            end;
          end;
      end; // Case MatchCriteria of;

      case SC.BinOp of
        boAnd: Match := Match and TmpRes;
        boOr:  Match := Match or TmpRes;
      end;
    end; // For i := 0 to Search.ConditionCount - 1 do

    if Match then exit;

    case Search.Direction of
      sdForward:  Inc(Result);
      sdBackward: Dec(Result);
    end;
  end;
end;

function SearchFindList(const Search: TSearch; CurIndex: integer): TBoundArray;
var
  L: Integer;
begin
  L := 0;

  case Search.Origin of
    soBeginning: CurIndex := 0;
    soEnd:       CurIndex := Search.DataFile.Size - 1;
  end;

  while true do
  begin
    CurIndex := SearchFindNext(Search, CurIndex);
    if CurIndex = -1 then exit;

    SetLength(Result, L + 1);
    Result[L] := CurIndex;
    Inc(L);

    case Search.Direction of
      sdForward:  Inc(CurIndex);
      sdBackward: Dec(CurIndex);
    end;
  end;
end;

{ TSearchCondition }

procedure TSearchCondition.SetField(const AValue: TEpiField);
begin
  if FField = AValue then exit;
  FField := AValue;
end;

procedure TSearchCondition.SetBinOp(const AValue: TSearchBinOp);
begin
  if FBinOp = AValue then exit;
  FBinOp := AValue;
end;

procedure TSearchCondition.SetCaseSensitive(AValue: Boolean);
begin
  if FCaseSensitive = AValue then Exit;
  FCaseSensitive := AValue;
end;

procedure TSearchCondition.SetMatchCriteria(const AValue: TMatchCriteria);
begin
  if FMatchCriteria = AValue then exit;
  FMatchCriteria := AValue;
end;

procedure TSearchCondition.SetText(const AValue: string);
begin
  if FText = AValue then exit;
  FText := AValue;
end;

constructor TSearchCondition.Create;
begin
  FBinOp          := boAnd;
  FCaseSensitive  := true;
  FField          := nil;
  FMatchCriteria  := mcEq;
  FText           := '';
end;

{ TSearch }

function TSearch.GetSearchCondiction(const index: integer): TSearchCondition;
begin
  result := TSearchCondition(List[Index]);
end;

function TSearch.GetConditionCount: integer;
begin
  result := FList.Count;
end;

constructor TSearch.Create;
begin
  FList := TList.Create;
end;

end.

