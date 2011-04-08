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
    FField: TEpiField;
    FMatchCriteria: TMatchCriteria;
    FText: string;
    procedure SetBinOp(const AValue: TSearchBinOp);
    procedure SetField(const AValue: TEpiField);
    procedure SetMatchCriteria(const AValue: TMatchCriteria);
    procedure SetText(const AValue: string);
  public
    property BinOp: TSearchBinOp read FBinOp write SetBinOp;
    property Field: TEpiField read FField write SetField;
    property MatchCriteria: TMatchCriteria read FMatchCriteria write SetMatchCriteria;
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
  Math, LCLProc, epidatafilestypes;

function SearchFindNext(const Search: TSearch; const Index: integer): integer;
var
  Match: Boolean;
  SC: TSearchCondition;
  TmpRes: Boolean;
  i: Integer;

  function Eq(Const Field: TEpiField; Const Text: string; Const Idx: integer): boolean;
  begin
    case Field.FieldType of
      ftBoolean,
      ftInteger,
      ftAutoInc: Result := Field.AsInteger[Idx] = StrToInt(Text);
      ftFloat:   Result := SameValue(Field.AsFloat[Idx], StrToFloat(Text));
      ftDMYDate,
      ftMDYDate,
      ftYMDDate,
      ftDMYToday,
      ftMDYToday,
      ftYMDToday: Result := Field.AsDate[Idx] = StrToDate(Text, TEpiDateField(Field).FormatString, DateSeparator);
      ftTime,
      ftTimeNow:  Result := Field.AsTime[Idx] = StrToTime(Text);
      ftString,
      ftUpperString: Result := Field.AsString[Idx] = Text;
    end;
  end;

  function LT(Const Field: TEpiField; Const Text: string; Const Idx: integer): boolean;
  begin
    case Field.FieldType of
      ftBoolean,
      ftInteger,
      ftAutoInc: Result := Field.AsInteger[Idx] < StrToInt(Text);
      ftFloat:   Result := (Field.AsFloat[Idx] < StrToFloat(Text)) and
                           (Not SameValue(Field.AsFloat[Idx], StrToFloat(Text)));
      ftDMYDate,
      ftMDYDate,
      ftYMDDate,
      ftDMYToday,
      ftMDYToday,
      ftYMDToday: Result := Field.AsDate[Idx] < StrToDate(Text, TEpiDateField(Field).FormatString, DateSeparator);
      ftTime,
      ftTimeNow:  Result := Field.AsTime[Idx] < StrToTime(Text);
      ftString,
      ftUpperString: Result := AnsiCompareStr(Field.AsString[Idx], Text) < 0;
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
    with Search.SearchCondiction[i] do
    begin
      case MatchCriteria of
        mcEq:  TmpRes := Eq(Field, Text, Result);
        mcNEq: TmpRes := not (Eq(Field, Text, Result));
        mcLEq: TmpRes := LT(Field, Text, Result) or EQ(Field, Text, Result);
        mcLT:  TmpRes := LT(Field, Text, Result);
        mcGT:  TmpRes := not (LT(Field, Text, Result) or Eq(Field, Text, Result));
        mcGEq: TmpRes := not (LT(Field, Text, Result));
        mcBegin:
          begin
            case Field.FieldType of
              ftString,
              ftUpperString: TmpRes := UTF8Pos(Text, Field.AsString[Result]) = 1;
            end;
          end;
        mcEnd:
          begin
            case Field.FieldType of
              ftString,
              ftUpperString: TmpRes := UTF8Pos(Text, Field.AsString[Result]) = UTF8Length(Field.AsString[Result]) - UTF8Length(Text);
            end;
          end;
        mcContains:
          begin
            case Field.FieldType of
              ftString,
              ftUpperString: TmpRes := UTF8Pos(Text, Field.AsString[Result]) >= 1;
            end;
          end;
      end; // Case MatchCriteria of;

      case BinOp of
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

