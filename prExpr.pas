unit prExpr;
interface
{Date functionality added by Michael Bruus, june 2000 - marked mib in code}
{TMissingLiteral and ttMissing:TExprType added by Michael Bruus, august 2001}

{main documentation block just before implementation
Copyright:   1997-1999 Production Robots Engineering Ltd, all rights reserved.
Version:     1.04 3/7/99
Status:      Free for private or commercial use subject to following restrictions:
             * Use entirely at your own risk
             * Do not resdistribute without this note
             * Any redistribution to be free of charges
any questions to Martin Lafferty   robots@enterprise.net}

uses
  TypInfo,
  Classes,
  SysUtils,
  EpiTypes,
  epiUDFTypes,
  math,
  Windows;

type
  TExprType = (ttObject, ttString, ttFloat, ttInteger, ttEnumerated, ttBoolean,ttMissing);

  IValue =
  interface(IUnknown)
    function TestParameters: Boolean;   {after parsing
                                        may either return false or
                                        raise EExpression. This call
                                        is used internally}
    function CanReadAs(aType: TExprType): Boolean;
    function TypeInfo: PTypeInfo;
    function AsString: String;
    function AsFloat: Double;
    function AsInteger: Integer;
    function AsBoolean: Boolean;
    function AsObject: TObject;
    function ExprType: TExprType;
    function TypeName: String;
  end;

  TExpression =
  class(TInterfacedObject, IValue)
  private
  protected
    function TestParameters: Boolean; virtual;
  public
    function TypeInfo: PTypeInfo; virtual;
    function AsString: String; virtual;
    function AsFloat: Double; virtual;
    function AsInteger: Integer; virtual;
    function AsBoolean: Boolean; virtual;
    function AsObject: TObject; virtual;
    function ExprType: TExprType; virtual; abstract;
    function TypeName: String; virtual;
    constructor Create;
    destructor Destroy; override;
    function CanReadAs(aType: TExprType): Boolean;
  end;

  TStringLiteral =
  class(TExpression)
  private
    FAsString: String;
  protected
  public
    function AsString: String; override;
    function AsFloat:  Double; override;
    function ExprType: TExprType; override;
    constructor Create( aAsString: String);
  end;

  TFloatLiteral =
  class(TExpression)
  private
    FAsFloat: Double;
  protected
  public
    function AsFloat: Double; override;
    function ExprType: TExprType; override;
    constructor Create( aAsFloat: Double);
  end;

  TIntegerLiteral =
  class(TExpression)
  private
    FAsInteger: Integer;
  protected
  public
    function AsInteger: Integer; override;
    function AsString:  String;  override;
    function ExprType: TExprType; override;
    constructor Create( aAsInteger: Integer);
  end;

  TEnumeratedLiteral =
  class(TIntegerLiteral)
  private
    Rtti: Pointer;
  protected
  public
    function TypeInfo: PTypeInfo; override;
    constructor Create(aRtti: Pointer; aAsInteger: Integer);
    constructor StrCreate(aRtti: Pointer; const aVal: String);
  end;

  TBooleanLiteral =
  class(TExpression)
  private
    FAsBoolean: Boolean;
  protected
  public
    function AsBoolean: Boolean; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
    constructor Create( aAsBoolean: Boolean);
  end;

  {mib}
  TDateLiteral =
  class(TExpression)
  private
    FAsFloat: Double;
  public
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
    constructor Create(aAsFloat: Double);
  end;

  TMissingLiteral = Class(TExpression)
  public
    function AsFloat: Double;  override;
    function AsInteger: Integer;  override;
    function AsString:  String;  override;
    function AsBoolean: Boolean;  override;
    function ExprType: TExprType;  override;
    constructor Create;
  end;

  {mib}


  TObjectRef =
  class(TExpression)
  private
    FObject: TObject;
  protected
  public
    function TypeInfo: PTypeInfo; override;
    function AsObject: TObject; override;
    function ExprType: TExprType; override;
    constructor Create( aObject: TObject);
  end;

  TParameterList =
  class(TList)
  private
    function GetAsObject(i: Integer): TObject;
    function GetAsString(i: Integer): String;
    function GetAsFloat(i: Integer): Double;
    function GetAsInteger(i: Integer): Integer;
    function GetAsBoolean(i: Integer): Boolean;
    function GetExprType(i: Integer): TExprType;
    function GetParam(i: Integer): IValue;
  public
    function AddExpression( e: IValue): Integer;
    destructor Destroy; override;
    property Param[i: Integer]: IValue read GetParam;
    property ExprType[i: Integer]: TExprType read GetExprType;
    property AsObject[i: Integer]: TObject read GetAsObject;
    property AsString[i: Integer]: String read GetAsString;
    property AsFloat[i: Integer]: Double read GetAsFloat;
    property AsInteger[i: Integer]: Integer read GetAsInteger;
    property AsBoolean[i: Integer]: Boolean read GetAsBoolean;
  end;

  TFunction =
  class(TExpression)
  private
    FParameterList: TParameterList;
    function GetParam(n: Integer): IValue;
  protected
  public
    constructor Create( aParameterList: TParameterList);
    destructor Destroy; override;
    function ParameterCount: Integer;
    property Param[n: Integer]: IValue read GetParam;
  end;

  {salah}
TUDFExpression = class(TFunction)
  private
    fUdf:TEpiUDF;
    fPropType: TExprType;
    Intvalue :variant;
    function Execute: variant;
  public
    constructor Create(aParameterList: TParameterList;aUdf:TEpiUDF);
    function ConvertParamToArrayValues:variant;
    function AsString: String; override;
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    property Udf:TEpiUDF read fUdf write fUdf;
  end;
  {/salah}



  {mib}
  TDateExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TYearExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TMonthExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TDayExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TWeekNumExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TDayOfWeekExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsInteger: Integer; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TSoundexExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; Override;
  public
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TTimeValueExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; Override;
  public
    function AsString: String; override;
    function AsFloat: Double;  override;
    function ExprType: TExprType; Override;
  end;

  TTimeExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsString: string;  override;
    function AsFloat:  Double;  override;
    function Exprtype: TExprType;  override;
  end;

  TIsBlankExpr =
  class(TFunction)
  protected
    function TestParameters: Boolean; override;
  public
    function AsBoolean: Boolean; override;
    function AsString: String; override;
    function ExprType: TExprType; override;
  end;

  TCountMissingExpr = Class(TFunction)
  Protected
    FAsInteger: Integer;
    function TestParameters: Boolean; override;
  public
    function AsInteger: Integer; override;
    function AsString: String;  override;
    function ExprType: TExprType;  override;
    constructor Create( aParameterList: TParameterList);
  end;

  TSumExpr = Class(TFunction)
  Protected
    FAsDouble: Double;
    function TestParameters: Boolean; override;
  public
    function AsFloat: Double; override;
    function AsString: String;  override;
    function ExprType: TExprType;  override;
    constructor Create(aParameterList: TParameterList);
  end;

  TRangeExpr = Class(TFunction)
  Protected
    function TestParameters: Boolean; override;
  public
    function AsBoolean: Boolean;  override;
    function ExprType: TExprType;  override;
  end;

  {mib}

  EExpression = class(Exception);

  TIdentifierFunction = function( const Identifier: String;
                                  ParameterList: TParameterList): IValue of Object;

function CheckEnumeratedVal(Rtti: Pointer; const aVal: String): IValue;

function CreateExpression( const S: String;
                IdentifierFunction: TIdentifierFunction): IValue;

function FoldConstant( Value: IValue): IValue;
  {replace complex constant expression with literal, hence reducing
   evaluation time. This function does not release Value - caller
   should do that if it is appropriate. This is usually, but not
   necessarily always, the case.}
var
  InstanceCount: Integer = 0;
  GlobalPrExprDf: PDatafileInfo;

implementation
{This unit comprises a mixed type expression evaluator which follows pascal
syntax (reasonably accurately) and approximates standard pascal types.

Feedback
--------
I shall be pleased to hear from anyone
- with any questions or comments
- who finds or suspects any bugs
- who wants me to quote for implementing extensions or applications

in any event, my address is:   robots@enterprise.net
I am sometimes very busy and cannot always enter into protracted or complex correspondence
but I do really like to hear from users of this code

I have found this code very useful and surprisingly robust. I sincerely hope you do too.

For detailed explanation as to how to effectively use this unit please refer to prExpr.txt.

Compatibility
-------------
Version 1.04 of this unit is not compatible with previous versions and will break existing
applications.

This code developed with Delphi 4 and 3. It won't work with Delphi 2 because it uses
interfaces. If you want a Delphi 2 version then try v1.03 which also supports Delphi 1
(16 bit)

Additional Resources
--------------------
This archive includes a help file prExpr.hlp, which you can incorporate into your
help system to provide your users with a definition of expression syntax. If you want
the rtf file from which this is compiled then download

http://homepages.enterprise.net/robots/downloads/exprhelp.zip

That package includes
  prExpr.rtf - The source file (inline graphics)
  prExpr.hpj - The help project file.

Next Steps (ideas not implemented)
----------
TypeRegistry for enumerated types could
(a) allow enumerates to be efficiently and automatically parsed
    (Build a binary list of all the names)
(b) allow typecasts to enumerated types


Version History
---------------
latest version should be available from:
  http://homepages.enterprise.net/robots/downloads/prexpr.zip

version 1.04 is not backwardly compatible with previous versions so
for historical reasons version 1.03 should be available from:
  http://homepages.enterprise.net/robots/downloads/expreval.zip


prExpr version 1.04
  For Version 1.04 the help file is out of date: it is not actually wrong - it just misses out
  a load of stuff, like class references and enumerated types.

  v104 is not backwardly compatible with v1.03 but it might be worth converting your applications
  because there is some quite neat stuff in here. You really need to understand interfaces though.

  1. No longer supports 16 bit
  2. Value is now an interface. This was an idea I nicked from Clayton Collie.
     This makes handling object disposals really easy when there are lots of random references
     to a bunch of expressions stored in a haphazard way. The compiler handles it for you.
  3. New rule: it must be possible to determine the type of an expression at parse-time. Therefore the
     two parameters to IF must be the same type. This prevents lots of awkward situations.
  4. Typecasts should now work both to a more general type (e.g Integer to string) and to a more
     specific type (String to integer). Implausible casts e.g Integer('four') will raise an exception
     when evaluated, but still return a valid type at parse time (see rule 3 above).
  5. Objects now supported. If an ID Function returns an instance of an object, then all its
     published properties are available in the expression without further ado. Don't forget a class
     has to be compiled under $M+ to have rtti.
  6. Enumerated types now supported, using rtti.
  7. Rtti means 'Run-Time-Type-Information'. I thought you would know that.
  8. While I am about breaking backward compatibility, I have decided to get rid
     of most read-only properties. Surely it is silly to use a complicated syntax
     when there is an equivalent, much simpler option
     (Maybe I thought write specifiers would have some meaning in some other
     context of IValue)

31/1/98 v1.03
(a) Unit Name changed from 'Expressions' to 'prExpr'.
    reasons:
     1. Merging 16/32 versions into one unit means name must be
        8.3 compliant
     2. Name should be 8.3 compliant anyway. Long filenames are
        still a pain in the neck.
     3. 'Expressions' is a term with too many meanings. Better to
        use an arbitary, mostly meaningless name.

(b) Incorporation of 16 & 32 bit versions in one unit.

(c) Modification by Markus Stephany
    (http://home.t-online.de/home/mirbir.st)
    Support for Hex literals added. Marked (mst) in source.

(d) Reverse 'Decimal Separator' mod made in v1.02.

(e) Significant structural changes to rationalise by
    eliminating repeated code. Introduced concept of 'Expression
    chain' which means that functions Factor, Term, Simple,
    and Expression now have a common implementation (Chain)
    The source is now a lot shorter, and, I hope, clearer. These
    changes should have eliminated Ken Friesen's bug in a more
    structured way.

(f) I have added another 'tier' to the syntax hierachy. The basic
    syntax element is now the 'SimpleFactor' - (was Factor). A
    factor now consists of a string of SimpleFactors linked by
    ^ the exponention operator. This change allows the ^ operator
    to be supported. prExpr.hlp updated.

(g) Archive structure changes:
      1. Expr.hlp has been renamed prExpr.hlp and is included with the
         issue archive.

      2. Tutorial documentation removed from this file to a separate file
         prExpr.txt. (hint - right click on filename then choose 'Open file
         at cursor')

      3. Form unit name changed to Main.pas

      4. Now includes 16 bit example files (tester16.dpr, Main16.pas, Main16.dfm)


20/1/98 v1.02
companion help material issued.

Structure of comment blocks rationalised. Or derationalised,
depending on your point of view.

9/1/98 v1.01
Bugs reported by Ken Friesen

1) (1+2))-1=3
(this is a bug, but known. See comment right at end
of source. Function EoE (EndOfExpression) returns true for all of
 ')' ',' or #0. This is necessary for handing functions and
 parameters but irritating if your expression has an extra ).
 Fixed.

2) 1+( )= Access Violation
Oversight. Parser did not check for null subexpresssion (fixed)

3) 0-2+2=-4
4) 1-0+1=0
5) -2-2+2 = -6
I cannot believe that this has not been picked up before now!
There is an awful lot of recursion about and this was caused
by the fact that the function SIMPLE called itself to in order
to generate a string of TERMS. The result of this is that any
simple expressions containing more than two terms were constructed
as if they were bracketed from the end of the expression.

i.e a+b+c+d was evaluated as a + (b + (c + d))

This was an elegant construct and I fell for it regardless of the fact
that it was completely wrong. This problem also affected the function
Term, but because a*b*c*d = a*(b*(c*d)) I got away with it.

I have made a (rough) fix. Which works but may have introduced other
problems. The structure of simple is now (approximately)

function Simple: TExpression;
Result:= Term
while NextOperator in [+, -, or, xor] do
  Result:= Binary(NextOperator, Result, Term)

As opposed to the previous (incorrect) way of doing things which was:

function Simple: TExpression;
Result:= Term
if NextOperator in [+, -, or, xor] then
  Result:= Binary(NextOperator, Result, Simple)


I have also made this modification to  TERM, in order to be consistent,
and because it was a  fluke that it worked before.

The unit now passes Ken's tests. I cannot be sure I have not introduced
other problems. I should devise a proper test routine, when I have some
time.

30/12/97 v1.00
Released to http://homepages.enterprise.net/robots/downloads/expreval.zip
Some slight restructing. Added more comprehensive documentation. Removed
a few calls to StrPas which are redundant under D2/D3

11/11/97
Bug caused mishandling of function lists. Fixed.

5/11/97
Slight modifications for first issue of Troxler.exe

16/9/97
Realised that it should be possible to pass the parameter stack
to the identifier function. The only problem with this approach is
how to handle disposal of the stack.

We could require that the identifier function disposes of the stack...
I don't really like this (I can't think why at the moment). Another
approach would be to define a 'placeholder' expression which does nothing
but hold the parameter list and the <clients> expression.

Compromise solution:
  The parser constructs an instance of TParameter list and passes it to
  the 'user' via a call to IdentifierFunction. There are four possible
  mechanisms for disposal of the parameter list.
     a) If the Identifier function returns NIL the parser disposes
        of the parameter list then raises 'Unknown identifier'.
     b) If the Identifier function raises an exception then the parser
        catches this exception (in a 'finally' clause) and disposes
        of the parameter list.
     c) If the Identifier function returns an expression then it must
        dispose of the parameter list if it does not wish to keep it.
     d) If the Identifier function returns an expression which is
        derived from TFunction, then it may pass the parameter list to
        its result. The result frees the parameter list when it is freed.
        (i.e. ParameterList passed to TFunction.Create is freed by
        TFunction.Destroy)

Simple rule - if IdentFunction returns Non-nil then parameters are
responsiblity of the object returned. Otherwise caller will handle. OK?

7/9/97
function handling completely changed.

added support for Integers including support for the following operators
  bitwise not
  bitwise and
  bitwise or
  bitwise xor
  shl
  shr
  div

now support std functions:

arithmetic...
  TRUNC, ROUND, ABS, ARCTAN, COS, EXP, FRAC, INT,
     LN, LOG10, PI, SIN, SQR, SQRT, POWER

string...
  UPPER, LOWER, COPY, POS, LENGTH

Fixed a couple of minor bugs. Forgotten what they are.


18/6/97
Written for Mark Page's troxler thing - as part of the report definition language,
but might be needed for Robot application framework. Not tested much.
Loosely based on syntax diagrams in BP7 Language Guide pages 66 to 79.
This is where the nomenclature Term, Factor, SimpleExpression, Expression is
derived.
}


type
  TOperator = ( opNot,
                opExp,
                opMult, opDivide, opDiv, opMod, opAnd, opShl, opShr,
                opPlus, opMinus, opOr, opXor,
                opEq, opNEq, opLT, opGT, opLTE, opGTE);

  TOperators = set of TOperator;

  TUnaryOp =
  class(TExpression)
  private
    Operand: IValue;
    OperandType: TExprType;
    Operator: TOperator;
  protected
  public
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    constructor Create( aOperator: TOperator; aOperand: IValue);
  end;

  TBinaryOp =
  class(TExpression)
  private
    Operand1, Operand2: IValue;
    Operator: TOperator;
    OperandType: TExprType;
  protected
  public
    function AsString: String; override;
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    constructor Create( aOperator: TOperator; aOperand1, aOperand2: IValue);
  end;

  TRelationalOp =
  class(TExpression)
  private
    Operand1, Operand2: IValue;
    OperandType: TExprType;
    Operator: TOperator;
  protected
  public
    function AsString: String; override;
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    constructor Create( aOperator: TOperator; aOperand1, aOperand2: IValue);
  end;

  TObjectProperty =
  class(TExpression)
  private
    Obj: TObject;
    PropInfo: PPropInfo;
    PropType: TExprType;
  protected
  public
    function TypeInfo: PTypeInfo; override;
    function AsObject: TObject; override;
    function AsString: String; override;
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    constructor Create(aObj: IValue; const PropName: String);
  end;


const
  MaxStringLength = 255; {why?}
  Digits = ['0'..'9'];
  PrimaryIdentChars = ['a'..'z', 'A'..'Z', '_'];
  IdentChars = PrimaryIdentChars + Digits;


  NExprType: array[TExprType] of String =
      ('Object', 'String', 'Float', 'Integer', 'Enumerated', 'Boolean','Missing');

  NOperator: array[TOperator] of String =
              ( 'opNot',
                'opExp',
                'opMult', 'opDivide', 'opDiv', 'opMod', 'opAnd', 'opShl', 'opShr',
                'opPlus', 'opMinus', 'opOr', 'opXor',
                'opEq', 'opNEq', 'opLT', 'opGT', 'opLTE', 'opGTE');

  UnaryOperators = [opNot];
  ExpOperator = [opExp];
  MultiplyingOperators = [opMult, opDivide, opDiv, opMod, opAnd, opShl, opShr];
  AddingOperators = [opPlus, opMinus, opOr, opXor];
  RelationalOperators = [opEq, opNEq, opLT, opGT, opLTE, opGTE];

  NBoolean: array[Boolean] of String[5] = ('FALSE', 'TRUE');


function ResultType( Operator: TOperator; OperandType: TExprType): TExprType;
procedure NotAppropriate;
begin
  Result:= ttString;
  raise EExpression.CreateFmt( Lang(23000),     //'Operator %s incompatible with %s'
                               [NOperator[Operator], NExprType[OperandType]])
end;

begin
  case OperandType of
    ttMissing:
    case Operator of
      opEq, opNEq: Result:= ttBoolean;
      opMult,opDivide,opPlus,opMinus: Result:=ttFloat;
    else
      NotAppropriate;
    end;
    ttString:
    case Operator of
      opPlus: Result:= ttString;
      opEq..opGTE: Result:= ttBoolean;
    else
      NotAppropriate;
    end;
    ttFloat:
    case Operator of
      opExp, opMult, opDivide, opPlus, opMinus: Result:= ttFloat;
      opEq..opGTE: Result:= ttBoolean;
    else
      NotAppropriate;
    end;
    ttInteger:
    case Operator of
      opNot, opMult, opDiv, opMod, opAnd, opShl, opShr, opPlus, opMinus,
      opOr, opXor: Result:= ttInteger;
      opExp, opDivide: Result:= ttFloat;
      opEq..opGTE: Result:= ttBoolean;
    else
      NotAppropriate;
    end;
    ttBoolean:
    case Operator of
      opNot, opAnd, opOr, opXor, opEq, opNEq: Result:= ttBoolean;
    else
      NotAppropriate;
    end;
    ttObject:
    case Operator of
      opEq, opNEq: Result:= ttBoolean;
    else
      NotAppropriate;
    end;
  else
    NotAppropriate
  end
end;

function IncompatibleTypes(T1, T2: TExprType): TExprType;
{result is not defined... Do this to avoid warning}
begin
  raise EExpression.CreateFmt(Lang(23002),   //'Type %s is incompatible with type %s'
                                  [NExprType[T1], NExprType[T2]])
end;

function CommonType( Op1Type, Op2Type: TExprType): TExprType;
begin
  if (Op1Type = ttObject) or (Op2Type = ttObject) then
  begin
    if Op1Type <> Op2Type then
      Result:= IncompatibleTypes(Op1Type, Op2Type)
    else
      Result:= ttObject
  end else
  begin
    if Op1Type < Op2Type then
      Result:= Op1Type else
      Result:= Op2Type
  end;
end;

procedure Internal( Code: Integer);
begin
  raise EExpression.CreateFmt(Lang(23004), [Code])    //'Internal parser error. Code %d'
end;

constructor TExpression.Create;
begin
  inherited Create;
  Inc(InstanceCount)
end;

destructor TExpression.Destroy;
begin
  Dec(InstanceCount);
  inherited Destroy
end;

function TExpression.AsString: String;
{too scary to deal with Enumerated types here?}
begin
  case ExprType of
    ttObject: Result:= AsObject.ClassName;
    ttFloat: Result:= FloatToStr(AsFloat);
    ttInteger: Result:= IntToStr(AsInteger);
    ttEnumerated: Result:= GetEnumName(TypeInfo, AsInteger);
    ttBoolean: Result:= NBoolean[AsBoolean];
  else
    EExpression.CreateFmt(Lang(23006),    //'Cannot read %s as String'
                              [NExprType[ExprType]]);
  end
end;

function TExpression.AsFloat: Double;
begin
  case ExprType of
    ttInteger, ttEnumerated, ttBoolean: Result:= AsInteger;
  else
    raise EExpression.CreateFmt(Lang(23008),   //'Cannot read %s as Float'
                                   [NExprType[ExprType]]);
  end
end;

function TExpression.AsInteger: Integer;
begin
  case ExprType of
    ttBoolean: Result:= Integer(AsBoolean);
  else
    raise EExpression.CreateFmt(Lang(23010),     //'Cannot read %s as Integer'
                               [NExprType[ExprType]]);
  end;
end;

function TExpression.AsBoolean: Boolean;
begin
  raise EExpression.CreateFmt(Lang(23012),    //'Cannot read %s as boolean'
                               [NExprType[ExprType]])
end;

function TExpression.AsObject: TObject;
begin
  raise EExpression.CreateFmt(Lang(23014),    //'Cannot read %s as object'
                               [NExprType[ExprType]])
end;

function TExpression.TestParameters: Boolean;
begin
  Result:= true
end;

function TExpression.CanReadAs(aType: TExprType): Boolean;
var
  et: TExprType;
begin
  et:= ExprType;
  if (et = ttObject) or
     (aType = ttObject) then
    Result:= aType = et
  else
    Result:= aType <= et
end;

function TExpression.TypeName: String;
begin
  Result:= TypeInfo^.Name
end;

function TStringLiteral.AsString: String;
begin
  Result:= FAsString
end;

function TStringLiteral.AsFloat: Double;
begin
  IF FAsString='' THEN Result:=0
  ELSE IF IsFloat(FAsString) THEN Result:=eStrToFloat(FAsString)
  ELSE raise EExpression.CreateFmt( '%s is not a numeric value',[FAsString] );
END;

function TStringLiteral.ExprType: TExprType;
begin
  Result:= ttString
end;

constructor TStringLiteral.Create( aAsString: String);
begin
  inherited Create;
  FAsString:= aAsString
end;


function TFloatLiteral.AsFloat: Double;
begin
  Result:= FAsFloat
end;

function TFloatLiteral.ExprType: TExprType;
begin
  Result:= ttFloat
end;

constructor TFloatLiteral.Create( aAsFloat: Double);
begin
  inherited Create;
  FAsFloat:= aAsFloat
end;

function TDateLiteral.AsFloat: Double;
BEGIN
  Result:= FAsFloat;
END;

function TDateLiteral.AsInteger: Integer;
BEGIN
  Result:=Round(FAsFloat);
END;

function TDateLiteral.AsString: String;
BEGIN
  Result:=mibDateToStr(FAsFloat,ftEuroDate);
END;

Function TDateLiteral.ExprType: TExprType;
BEGIN
  Result:=ttFloat;
END;

constructor TDateLiteral.Create(aAsFloat: Double);
BEGIN
  inherited Create;
  FAsFloat:=aAsFloat;
END;

function TMissingLiteral.AsFloat: Double;
begin
  result:=0;
end;

function TMissingLiteral.AsInteger: Integer;
begin
  result:=0;
end;

function TMissingLiteral.AsString: String;
begin
  result:='';
end;

function TMissingLiteral.AsBoolean: Boolean;
begin
  result:=False;
end;

function TMissingLiteral.ExprType: TExprType;
begin
  result:=ttMissing;
end;

Constructor TMissingLiteral.Create;
begin
  inherited Create;
  IF MissingAction=maRejectMissing THEN ResultEqualsMissing:=True;
end;


function TUDFExpression.ConvertParamToArrayValues:variant;
var
  i,count : integer;
  ws :PWideChar;
begin
  Result:= varNull;
  count:=Parametercount;
  if count=0 then exit;
  Result:=VarArrayCreate([0,1],varVariant);
  VarArrayRedim(Result,count);
  for i:= 0 to count-1 do
  begin
     case FParameterList.ExprType[i] of
      ttString:
      begin
         Result[i]:=Param[i].AsString;
      end;
      ttFloat:Result[i]:=Param[i].AsFloat;
      ttInteger:Result[i]:=Param[i].AsInteger;
      ttBoolean:Result[i]:=Param[i].AsBoolean;
      end;//case
  end;
end;


function TUDFExpression.AsBoolean: Boolean;
begin
      Result:=execute;
end;

function TUDFExpression.AsFloat: Double;
begin
       Result:=execute;
end;

function TUDFExpression.AsInteger: Integer;
begin
     Result:=execute;
end;

function TUDFExpression.AsString: String;
begin
     Result:=execute;
end;


constructor TUDFExpression.Create(aParameterList: TParameterList;aUDF: TEpiUDF);
begin
  inherited Create(aParameterList);
  fUdf:= aUdf;
  case fUDF.ReturnType of
   UDFReturnString :  fPropType:= ttString;
   UDFReturnInteger:  fPropType:= ttInteger;
   UDFReturnBoolean: fPropType:= ttBoolean;
   UDFReturnFloat  :  fPropType:= ttFloat;
// ftDate, ftTime, ftDateTime:=Result:= ttInteger
 else
//   raise EExpression.CreateFmt('Field %s has unsupported type', [aUDF.FieldName]);
 end;
  fUDF.ExecuteUDF:=GetProcAddress(fUDF.ModuleID,fUDF.szUDFName);
  if not assigned(fUDF.ExecuteUDF) then
    raise Exception.create(format(Lang(22882),[fUDF.szUDFName]));    //'Error loading external function %s'
end;

function TUDFExpression.ExprType: TExprType;
begin
  result:=fPropType;
end;

function TUDFExpression.Execute: variant;
var
 v :variant;
begin
  v :=ConvertParamToArrayValues;
  fUDF.ExecuteUDF(v,result);
  intValue:=result;
end;



function TIntegerLiteral.AsInteger: Integer;
begin
  IF FAsInteger=$FFFFFFFE THEN Result:=0 ELSE Result:= FAsInteger
end;

function TIntegerLiteral.AsString: String;
begin
  IF FAsInteger=$FFFFFFFE THEN Result:=''
  ELSE Result:=IntToStr(FAsInteger);
END;

function TIntegerLiteral.ExprType: TExprType;
begin
  Result:= ttInteger
end;

constructor TIntegerLiteral.Create( aAsInteger: Integer);
begin
  inherited Create;
  FAsInteger:= aAsInteger
end;

function TBooleanLiteral.AsBoolean: Boolean;
begin
  Result:= FAsBoolean
end;

function TBooleanLiteral.AsString: String;
Begin
  If FAsBoolean THEN Result:='Y' ELSE Result:='N';
END;

function TBooleanLiteral.ExprType: TExprType;
begin
  Result:= ttBoolean
end;

constructor TBooleanLiteral.Create( aAsBoolean: Boolean);
begin
  inherited Create;
  FAsBoolean:= aAsBoolean
end;

constructor TEnumeratedLiteral.Create(aRtti: Pointer; aAsInteger: Integer);
begin
  inherited Create(aAsInteger);
  Rtti:= aRtti
end;

constructor TEnumeratedLiteral.StrCreate(aRtti: Pointer; const aVal: String);
var
  i: Integer;
begin
  i:= GetEnumValue(PTypeInfo(aRtti), aVal);
  if i = -1 then
    raise EExpression.CreateFmt(Lang(23016),    //'%s is not a valid value for %s'
                [aVal, PTypeInfo(aRtti)^.Name]);
  Create(aRtti, i)
end;

function CheckEnumeratedVal(Rtti: Pointer; const aVal: String): IValue;
begin
  try
    Result:= TEnumeratedLiteral.StrCreate(Rtti, aVal)
  except
    on EExpression do
      Result:= nil
  end
end;

function TObjectRef.AsObject: TObject;
begin
  Result:= FObject
end;

function TObjectRef.ExprType: TExprType;
begin
  Result:= ttObject
end;

constructor TObjectRef.Create( aObject: TObject);
begin
  inherited Create;
  FObject:= aObject
end;

function TUnaryOp.AsFloat: Double;
begin
  case Operator of
    opMinus: Result:= -Operand.AsFloat;
    opPlus: Result:= Operand.AsFloat;
  else
    Result:= inherited AsFloat;
  end
end;

function TUnaryOp.AsInteger: Integer;
begin
  Result:= 0;
  case Operator of
    opMinus: Result:= -Operand.AsInteger;
    opPlus: Result:= Operand.AsInteger;
    opNot:
    case OperandType of
      ttInteger: Result:= not Operand.AsInteger;
      ttBoolean: Result:= Integer(AsBoolean);
    else
      Internal(6);
    end;
  else
    Result:= inherited AsInteger;
  end
end;

function TUnaryOp.AsBoolean: Boolean;
begin
  case Operator of
    opNot: Result:= not(Operand.AsBoolean)
  else
    Result:= inherited AsBoolean;
  end
end;

function TUnaryOp.ExprType: TExprType;
begin
  Result:= ResultType(Operator, OperandType)
end;

constructor TUnaryOp.Create( aOperator: TOperator; aOperand: IValue);
begin
  inherited Create;
  Operand:= aOperand;
  Operator:= aOperator;
  OperandType:= Operand.ExprType;
  if not (Operator in [opNot, opPlus, opMinus]) then
    raise EExpression.CreateFmt('%s is not simple unary operator',
                                [NOperator[Operator]])
end;

function TBinaryOp.AsString: String;
begin
  Result:= '';
  case ExprType of
    ttString:
      case Operator of
        opPlus: Result:= Operand1.AsString + Operand2.AsString;
      else
        Internal(10);
      end;
    ttFloat:
      Result:= FloatToStr(AsFloat);
    ttInteger:
      Result:= IntToStr(AsInteger);
    ttBoolean:
      Result:= NBoolean[AsBoolean];
  end
end;

function TBinaryOp.AsFloat: Double;
begin
  Result:= 0;
  case ExprType of
    ttFloat:
      case Operator of
        opExp: Result:= Exp(Operand2.AsFloat * Ln(Operand1.AsFloat));
        opPlus: Result:= Operand1.AsFloat + Operand2.AsFloat;
        opMinus: Result:= Operand1.AsFloat - Operand2.AsFloat;
        opMult: Result:= Operand1.AsFloat * Operand2.AsFloat;
        opDivide: Result:= Operand1.AsFloat / Operand2.AsFloat;
      else
        Internal(11);
      end;
    ttInteger:
        Result:= AsInteger;
    ttBoolean:
       Result:= Integer(AsBoolean);
  end
end;


function TBinaryOp.AsInteger: Integer;
begin
  Result:= 0;
  case ExprType of
    ttInteger:
    case Operator of
      opPlus: Result:= Operand1.AsInteger + Operand2.AsInteger;
      opMinus: Result:= Operand1.AsInteger - Operand2.AsInteger;
      opMult: Result:= Operand1.AsInteger * Operand2.AsInteger;
      opDiv: Result:= Operand1.AsInteger div Operand2.AsInteger;
      opMod: Result:= Operand1.AsInteger mod Operand2.AsInteger;
      opShl: Result:= Operand1.AsInteger shl Operand2.AsInteger;
      opShr: Result:= Operand1.AsInteger shr Operand2.AsInteger;
      opAnd: Result:= Operand1.AsInteger and Operand2.AsInteger;
      opOr: Result:= Operand1.AsInteger or Operand2.AsInteger;
      opXor: Result:= Operand1.AsInteger xor Operand2.AsInteger;
    else
      Internal(12);
    end;
    ttBoolean:
      Result:= Integer(AsBoolean);
  end
end;

function TBinaryOp.AsBoolean: Boolean;
begin
  Result:= false;
  case Operator of
    opAnd: Result:= Operand1.AsBoolean and Operand2.AsBoolean;
    opOr: Result:= Operand1.AsBoolean or Operand2.AsBoolean;
    opXor: Result:= Operand1.AsBoolean xor Operand2.AsBoolean;
  else
    Internal(13);
  end
end;

function TBinaryOp.ExprType: TExprType;
begin
  Result:= ResultType(Operator, OperandType)
end;

constructor TBinaryOp.Create( aOperator: TOperator; aOperand1, aOperand2: IValue);
begin
  inherited Create;
  {what if type changes? Operands might be IF expressions!}
  Operator:= aOperator;
  Operand1:= aOperand1;
  Operand2:= aOperand2;
  OperandType:= CommonType(Operand1.ExprType, Operand2.ExprType);
  if not (Operator in [opExp, opMult..opXor]) then
    raise EExpression.CreateFmt('%s is not a simple binary operator',
              [NOperator[Operator]])
end;

function TRelationalOp.AsString: String;
begin
  Result:= NBoolean[AsBoolean]
end;

function TRelationalOp.AsFloat: Double;
begin
  Result:= Integer(AsBoolean)
end;

function TRelationalOp.AsInteger: Integer;
begin
  Result:= Integer(AsBoolean)
end;

function TRelationalOp.AsBoolean: Boolean;
begin
  Result:= false;
  case OperandType of
    ttMissing:
    Case Operator of
      opEq: Result:= Operand1.AsString = Operand2.AsString;
      opNEq: Result:=Operand1.AsString<>Operand2.AsString;
    else
      raise EExpression.CreateFmt('cannot apply %s to missing operands',
             [NOperator[Operator]]);
    end;

    ttBoolean:
    IF ((Operand1.ExprType=ttMissing) AND (Operand2.ExprType=ttBoolean))
    OR ((Operand1.ExprType=ttBoolean) AND (Operand2.ExprType=ttMissing))
    THEN
      Case Operator of
        opEq: Result:=False;
        opNEq: Result:=True;
      end
    ELSE
      begin
        case Operator of
          opEq: Result:= Operand1.AsBoolean = Operand2.AsBoolean;
          opNEq: Result:= Operand1.AsBoolean <> Operand2.AsBoolean;
        else
          raise EExpression.CreateFmt(Lang(23018),    //'cannot apply %s to boolean operands'
                                      [NOperator[Operator]]);
        end;
      end;

    ttInteger:
    BEGIN
      IF (Operand1.ExprType=ttMissing) OR (Operand2.ExprType=ttMissing) THEN
        BEGIN
          CASE Operator of
            opEq: Result:=False;
            opNEq: Result:=True;
          ELSE
            raise EExpression.CreateFmt(Lang(23018),    //'cannot apply %s to boolean operands'
                                        [NOperator[Operator]]);
          end;
        END
      ELSE
        BEGIN
          case Operator of
            opLT: Result:= Operand1.AsInteger < Operand2.AsInteger;
            opLTE: Result:= Operand1.AsInteger <= Operand2.AsInteger;
            opGT: Result:= Operand1.AsInteger > Operand2.AsInteger;
            opGTE: Result:= Operand1.AsInteger >= Operand2.AsInteger;
            opEq: Result:= Operand1.AsInteger = Operand2.AsInteger;
            opNEq: Result:= Operand1.AsInteger <> Operand2.AsInteger;
          end;
        END;
    end;

    ttFloat:
    BEGIN
      {mib}
      IF (Operand1.ExprType=ttMissing) OR (Operand2.ExprType=ttMissing) THEN
        BEGIN
          CASE Operator of
            opEq: Result:=False;
            opNEq: Result:=True;
          ELSE
            raise EExpression.CreateFmt(Lang(23018),    //'cannot apply %s to boolean operands'
                                        [NOperator[Operator]]);
          end;
        END
      ELSE
        BEGIN
        {end mib}
          case Operator of
            opLT: Result:= Operand1.AsFloat < Operand2.AsFloat;
            opLTE: Result:= Operand1.AsFloat <= Operand2.AsFloat;
            opGT: Result:= Operand1.AsFloat > Operand2.AsFloat;
            opGTE: Result:= Operand1.AsFloat >= Operand2.AsFloat;
            opEq: Result:= Operand1.AsFloat = Operand2.AsFloat;
            opNEq: Result:= Operand1.AsFloat <> Operand2.AsFloat;
          end;
        END;
    END;

    ttString:
    case Operator of
      opLT: Result:= Operand1.AsString < Operand2.AsString;
      opLTE: Result:= Operand1.AsString <= Operand2.AsString;
      opGT: Result:= Operand1.AsString > Operand2.AsString;
      opGTE: Result:= Operand1.AsString >= Operand2.AsString;
      opEq: Result:= Operand1.AsString = Operand2.AsString;
      opNEq: Result:= Operand1.AsString <> Operand2.AsString;
    end;
  end
end;

function TRelationalOp.ExprType: TExprType;
begin
  Result:= ttBoolean
end;

constructor TRelationalOp.Create( aOperator: TOperator; aOperand1, aOperand2: IValue);
begin
  inherited Create;
  Operator:= aOperator;
  Operand1:= aOperand1;
  Operand2:= aOperand2;
  OperandType:= CommonType(Operand1.ExprType, Operand2.ExprType);
  if not (Operator in RelationalOperators) then
    raise EExpression.CreateFmt(Lang(23020),   //'%s is not relational operator'
                                 [NOperator[Operator]])
end;

function TObjectProperty.AsObject: TObject;
begin
  if PropType = ttObject then
    Result:= TObject(GetOrdProp(Obj, PropInfo))
  else
    Result:= inherited AsObject
end;

function TObjectProperty.AsString: String;
begin
  case PropType of
    ttString: Result:= GetStrProp(Obj, PropInfo);
    ttEnumerated: Result:= GetEnumName(PropInfo.PropType^, AsInteger);
  else
    Result:= inherited AsString
  end
end;

function TObjectProperty.AsFloat: Double;
begin
  if PropType = ttFloat then
    Result:= GetFloatProp(Obj, PropInfo)
  else
    Result:= inherited AsFloat
end;

function TObjectProperty.AsInteger: Integer;
begin
  case PropType of
    ttInteger, ttEnumerated:
      Result:= GetOrdProp(Obj, PropInfo)
  else
    Result:= inherited AsInteger;
  end
end;

function TObjectProperty.AsBoolean: Boolean;
begin
  if PropType = ttBoolean then
    Result:= LongBool(GetOrdProp(Obj, PropInfo))
  else
    Result:= inherited AsBoolean
end;

function TObjectProperty.ExprType: TExprType;
begin
  Result:= PropType
end;

constructor TObjectProperty.Create(aObj: IValue; const PropName: String);
begin
  inherited Create;
  Obj:= aObj.AsObject;
  PropInfo:= GetPropInfo(PTypeInfo(Obj.ClassInfo), PropName);
  if not Assigned(PropInfo) then
    raise EExpression.CreateFmt('%s is not published property of %s',
                   [PropName, aObj.AsObject.ClassName]);
  case PropInfo.PropType^^.Kind of
    tkClass: PropType:= ttObject;
    tkEnumeration:
    if PropInfo.PropType^^.Name = 'Boolean' then {special case}
      PropType:= ttBoolean
    else
      PropType:= ttEnumerated; {not boolean}
    tkInteger, tkChar: PropType:= ttInteger;
    tkFloat: PropType:= ttFloat;
    tkString, tkLString, tkWString: PropType:= ttString;
  else
    raise EExpression.CreateFmt('Property %s unsupported type', [PropName]);
  end
end;

function TParameterList.GetAsObject(i: Integer): TObject;
begin
  Result:= Param[i].AsObject
end;


function TParameterList.GetAsString(i: Integer): String;
begin
  Result:= Param[i].AsString
end;

function TParameterList.GetAsFloat(i: Integer): Double;
begin
  Result:= Param[i].AsFloat
end;

function TParameterList.GetAsInteger(i: Integer): Integer;
begin
  Result:= Param[i].AsInteger
end;

function TParameterList.GetAsBoolean(i: Integer): Boolean;
begin
  Result:= Param[i].AsBoolean
end;

function TParameterList.GetExprType(i: Integer): TExprType;
begin
  Result:= Param[i].ExprType
end;

function TParameterList.GetParam(i: Integer): IValue;
begin
  Result:= IValue(Items[i])
end;

function TParameterList.AddExpression( e: IValue): Integer;
begin
  Result:= Add(Pointer(e));
  e._AddRef
end;

destructor TParameterList.Destroy;
var
  i: Integer;
begin
  for i:= 0 to (Count - 1) do
    IValue(Items[i])._Release;
  inherited Destroy
end;

function TFunction.GetParam(n: Integer): IValue;
begin
  Result:= FParameterList.Param[n]
end;

function TFunction.ParameterCount: Integer;
begin
  if Assigned(FParameterList) then
    ParameterCount:= FParameterList.Count
  else
    ParameterCount:= 0
end;

constructor TFunction.Create( aParameterList: TParameterList);
begin
  inherited Create;
  FParameterList:= aParameterList
end;

destructor TFunction.Destroy;
begin
  FParameterList.Free;
  inherited Destroy
end;

type
  TTypeCast =
  class(TFunction)
  private
    OperandType,
    Operator: TExprType;
  protected
    function TestParameters: Boolean; override;
  public
    function AsObject: TObject; override;
    function AsString: String; override;
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    constructor Create( aParameterList: TParameterList;
                        aOperator: TExprType);
  end;

  TMF =
    (mfTrunc, mfRound, mfAbs, mfArcTan, mfCos, mfExp, mfFrac, mfInt,
     mfLn, mfLog10, mfPi, mfSin, mfSqr, mfSqrt, mfPower);

  TMathExpression =
  class(TFunction)
  private
    Operator: TMF;
  protected
    function TestParameters: Boolean; override;
  public
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function ExprType: TExprType; override;
    constructor Create( aParameterList: TParameterList;
                        aOperator: TMF);
  end;

  TSF =
    (sfUpper, sfLower, sfCopy, sfPos, sfLength);

  TStringExpression =
  class(TFunction)
  private
    Operator: TSF;
  protected
    function TestParameters: Boolean; override;
  public
    function AsString: String; override;
    function AsInteger: Integer; override;
    function ExprType: TExprType; override;
    constructor Create( aParameterList: TParameterList;
                        aOperator: TSF);
  end;

  TConditional =
  class(TFunction)
  private
    CommonType: TExprType;
    function Rex: IValue;
  protected
    function TestParameters: Boolean; override;
  public
    function AsString: String; override;
    function AsFloat: Double; override;
    function AsInteger: Integer; override;
    function AsBoolean: Boolean; override;
    function ExprType: TExprType; override;
    constructor Create( aParameterList: TParameterList);
  end;

const
  NTypeCast: array[TExprType] of PChar =
    ('OBJECT', 'STRING', 'FLOAT', 'INTEGER', 'ENUMERATED', 'BOOLEAN','MISSING');
  NMF: array[TMF] of PChar =
    ('TRUNC', 'ROUND', 'ABS', 'ARCTAN', 'COS', 'EXP', 'FRAC', 'INT',
     'LN', 'LOG10', 'PI', 'SIN', 'SQR', 'SQRT', 'POWER');
  NSF: array[TSF] of PChar = ('UPPER', 'LOWER', 'COPY', 'POS', 'LENGTH');

function TStringExpression.AsString: String;
begin
  case Operator of
    sfUpper: Result:= AnsiUpperCase(Param[0].AsString);
    sfLower: Result:= AnsiLowerCase(Param[0].AsString);
    sfCopy: Result:=  Copy(Param[0].AsString, Param[1].AsInteger, Param[2].AsInteger);
  else
    Result:= inherited AsString;
  end
end;

function TStringExpression.AsInteger: Integer;
begin
  case Operator of
    sfPos: Result:= Pos(Param[0].AsString, Param[1].AsString);
    sfLength: Result:= Length(Param[0].AsString);
  else
    Result:= inherited AsInteger
  end
end;

function TStringExpression.ExprType: TExprType;
begin
  case Operator of
    sfUpper, sfLower, sfCopy: Result:= ttString;
  else
    Result:= ttInteger;
  end
end;

function TStringExpression.TestParameters: Boolean;
begin
  case Operator of
    sfUpper, sfLower, sfLength:
      Result:= (ParameterCount = 1) and
               Param[0].CanReadAs(ttString);
    sfCopy:
      Result:= (ParameterCount = 3) and
            Param[0].CanReadAs(ttString) and
            (Param[1].ExprType = ttInteger) and
            (Param[2].ExprType = ttInteger);
    sfPos:
      Result:= (ParameterCount = 2) and
            Param[0].CanReadAs(ttString) and
            Param[1].CanReadAs(ttString);
  else
    Result:= false;
  end;
end;

constructor TStringExpression.Create( aParameterList: TParameterList;
                                      aOperator: TSF);
begin
  inherited Create(aParameterList);
  Operator:= aOperator
end;

function TMathExpression.AsFloat: Double;
begin
  case Operator of
    mfAbs: Result:= Abs(Param[0].AsFloat);
    mfArcTan: Result:= ArcTan(Param[0].AsFloat);
    mfCos: Result:= Cos(Param[0].AsFloat);
    mfExp: Result:= Exp(Param[0].AsFloat);
    mfFrac: Result:= Frac(Param[0].AsFloat);
    mfInt: Result:= Int(Param[0].AsFloat);
    mfLn: Result:= Ln(Param[0].AsFloat);
    mfLog10: Result:=Log10(Param[0].AsFloat);
    mfPi: Result:= Pi;
    mfSin: Result:= Sin(Param[0].AsFloat);
    mfSqr: Result:= Sqr(Param[0].AsFloat);
    mfSqrt: Result:= Sqrt(Param[0].AsFloat);
    mfPower: Result:=  Exp(Param[1].AsFloat * Ln(Param[0].AsFloat))
  else
    Result:= inherited AsFloat;
  end
end;

function TMathExpression.AsInteger: Integer;
begin
  case Operator of
    mfTrunc: Result:= Trunc(Param[0].AsFloat);
    mfRound: Result:= Round(Param[0].AsFloat);
    mfAbs: Result:= Abs(Param[0].AsInteger);
  else
    Result:= inherited AsInteger;
  end
end;

function TMathExpression.TestParameters: Boolean;
begin
  Result:= True;
  case Operator of
    mfTrunc, mfRound, mfArcTan, mfCos, mfExp, mfFrac, mfInt,
    mfLn, mfLog10, mfSin, mfSqr, mfSqrt, mfAbs:
    begin
      Result:= (ParameterCount = 1) and
           Param[0].CanReadAs(ttFloat);
    end;
    mfPower:
    begin
      Result:= (ParameterCount = 2) and
           Param[0].CanReadAs(ttFloat) and
           Param[1].CanReadAs(ttFloat);
    end;
  end
end;

function TMathExpression.ExprType: TExprType;
begin
  case Operator of
    mfTrunc, mfRound: Result:= ttInteger;
  else
    Result:= ttFloat;
  end
end;

constructor TMathExpression.Create( aParameterList: TParameterList;
                                    aOperator: TMF);
begin
  inherited Create(aParameterList);
  Operator:= aOperator
end;

function TTypeCast.AsObject: TObject;
begin
  if Operator = ttObject then
    Result:= Param[0].AsObject
  else
    Result:= inherited AsObject {almost certainly bomb}
end;

function TTypeCast.AsString: String;
begin
  if Operator = ttString then
  begin
    Result:= Param[0].AsString
  end else
  begin
    Result:= inherited AsString
  end
end;

function TTypeCast.AsFloat: Double;
var
  Code: Integer;
  s: String;
begin
  if Operator = ttFloat then
  begin
    case OperandType of
      ttString:
      begin
         s:= Param[0].AsString;
         Val(s, Result, Code);
         if Code <> 0 then
           raise EExpression.CreateFmt(Lang(23022), [s])   //'Cannot convert %s to float'
      end;
    else
      Result:= Param[0].AsFloat
    end
  end else
  begin
    Result:= inherited AsFloat
  end
end;

function TTypeCast.AsInteger: Integer;
var
  Code: Integer;
  s: String;
begin
  if Operator = ttInteger then
  begin
    case OperandType of
      ttString:
      begin
         s:= Param[0].AsString;
         Val(s, Result, Code);
         if Code <> 0 then
           raise EExpression.CreateFmt(Lang(23024), [s])   //'Cannot convert %s to integer'
      end;
      ttFloat:
      begin
        Result:= Trunc(Param[0].AsFloat);
      end
    else
      Result:= Param[0].AsInteger
    end
  end else
  begin
    Result:= inherited AsInteger
  end
end;

function TTypeCast.AsBoolean: Boolean;
var
  s: String;
const
  Eps30 = 1e-30;
begin
  if Operator = ttBoolean then
  begin
    case OperandType of
      ttString:
      begin
         s:= Uppercase(Param[0].AsString);
         if s =  NBoolean[false] then
           Result:= False
         else
         if s = NBoolean[true] then
           Result:= True
         else
           raise EExpression.CreateFmt(Lang(23026), [s])    //'Cannot convert %s to Boolean'
      end;
      ttFloat:
        Result:= Abs(Param[0].AsFloat) > Eps30;
      ttInteger:
        Result:= Param[0].AsInteger <> 0
    else
      Result:= Param[0].AsBoolean;
    end
  end else
  begin
    Result:= inherited AsBoolean
  end
end;

function TTypeCast.ExprType: TExprType;
begin
  Result:= Operator
end;

constructor TTypeCast.Create( aParameterList: TParameterList;
                              aOperator: TExprType);
begin
  if aOperator = ttEnumerated then
    raise EExpression.Create('Cannot cast to enumerated');
  if aParameterList.Count = 1 then
    OperandType:= aParameterList.Param[0].ExprType
  else
    raise EExpression.Create(Lang(23028));   //'Invalid parameters to typecast'
  {allow futile cast Object(ObjVar) }
  if (aOperator = ttObject) and
     (OperandType <> ttObject) then
    IncompatibleTypes(aOperator, OperandType);

  {objects may be cast to string or object only
   casting to string helplessly returns class name}
  if (OperandType = ttObject) and
     not ((aOperator = ttObject) or
          (aOperator = ttString)) then
      IncompatibleTypes(aOperator, OperandType);
  inherited Create(aParameterList);
  Operator:= aOperator
end;

function TTypeCast.TestParameters: Boolean;
begin
  Result:= ParameterCount = 1
end;

function TConditional.Rex: IValue;
begin
  if Param[0].AsBoolean then
    Result:= Param[1] else
    Result:= Param[2]
end;

constructor TConditional.Create( aParameterList: TParameterList);
begin
  inherited Create(aParameterList);
  CommonType:= Param[1].ExprType
end;

function TConditional.TestParameters: Boolean;
begin
  if not (ParameterCount = 3) then
    raise EExpression.Create(Lang(23030));   //'IF must have 3 parameters'
  if not (Param[0].ExprType = ttBoolean) then
    raise EExpression.Create(Lang(23032));   //'First parameter to If must be Boolean'
  if not (Param[1].ExprType = Param[2].ExprType) then
    raise EExpression.Create(Lang(23034));   //'IF options must be the same type'
  Result:= true
end;

function TConditional.AsString: String;
begin
  Result:= Rex.AsString
end;

function TConditional.AsFloat: Double;
begin
  Result:= Rex.AsFloat
end;

function TConditional.AsInteger: Integer;
begin
  Result:= Rex.AsInteger
end;

function TConditional.AsBoolean: Boolean;
begin
  Result:= Rex.AsBoolean
end;

function TConditional.ExprType: TExprType;
begin
  Result:= CommonType
end;

function StandardFunctions (const Ident: String; PL: TParameterList): IValue;
var
  i: TExprType;
  j: TMF;
  k: TSF;
  Found: Boolean;
begin
  Found:= false;
  if Ident = 'IF' then
  begin
    Result:= TConditional.Create(PL)
  end else
  begin
    for i:= Low(TExprType) to High(TExprType) do
    begin
      if Ident = NTypeCast[i] then
      begin
        Found:= true;
        Break
      end;
    end;
    if Found then
    begin
      Result:= TTypeCast.Create(PL, i)
    end else
    begin
      for j:= Low(TMF) to High(TMF) do
      begin
        if Ident = NMF[j] then
        begin
          Found:= true;
          break
        end
      end;
      if Found then
      begin
        Result:= TMathExpression.Create(PL, j)
      end else
      begin
        for k:= Low(TSF) to High(TSF) do
        begin
          if Ident = NSF[k] then
          begin
            Found:= true;
            break
          end
        end;
        if Found then
        begin
          Result:= TStringExpression.Create(PL, k)
        end else
        begin
          Result:= nil
        end
      end
    end
  end
end;

{parser...}
const
{note: These two cannot be the same}
  DecSeparator = '.';
  ParamDelimiter = ',';

  OpTokens: array[TOperator] of PChar =
              ( 'NOT',
                '^',
                '*', '/', 'DIV', 'MOD', 'AND', 'SHL', 'SHR',
                '+', '-', 'OR', 'XOR',
                '=', '<>', '<', '>', '<=', '>=');

  Whitespace = [#$1..#$20];
  SignChars = ['+', '-'];
  RelationalChars = ['<', '>', '='];
  OpChars = SignChars + ['^', '/', '*'] + RelationalChars;

  OpenSub = '(';
  CloseSub = ')';
  SQuote = '''';

  ExprDelimiters = [#0, CloseSub, ParamDelimiter];

  {mst}
  SHex = '$';
  HexDigs = Digits+['a'..'f','A'..'F'];
  {mst}

procedure SwallowWhitespace( var P: PChar);
begin
  while P^ in Whitespace do inc(P)
end;

function EoE( var P: PChar): Boolean;
begin
  Result:= (P^ in ExprDelimiters)
end;


function GetOperator( var P: PChar; var Operator: TOperator): Boolean;
{this leaves p pointing to next char after operator}
var
  Buf: array[0..3] of Char;
  lp: PChar;
  i: Integer;

function tt( op: TOperator): Boolean;
begin
  if StrLComp(Buf, OpTokens[Op], i) = 0 then
  begin
    Operator:= op;
    Result:= true
  end else
  begin
    Result:= false
  end
end;

begin
  Result:= false;
  if P^ in OpChars then
  begin
    Result:= true;
    Buf[0]:= P^;
    Inc(P);
    case Buf[0] of
      '*': Operator:= opMult;
      '+': Operator:= opPlus;
      '-': Operator:= opMinus;
      '/': Operator:= opDivide;
      '<': if P^ = '=' then
           begin
             Operator:= opLTE;
             Inc(P)
           end else
           if P^ = '>' then
           begin
             Operator:= opNEq;
             Inc(P)
           end else
           begin
             Operator:= opLT
           end;
       '=': Operator:= opEq;
       '>': if P^ = '=' then
            begin
              Operator:= opGTE;
              Inc(P)
            end else
            begin
              Operator:= opGT
            end;
      '^': Operator:= opExp;
    end
  end else
  if UpCase(P^) in ['A', 'D', 'M', 'N', 'O', 'S', 'X'] then
  begin  {check for 'identifer' style operators. We can ignore NOT}
    lp:= P;
    i:= 0;
    while (i <= 3) and (lp^ in IdentChars) do
    begin
      Buf[i]:= UpCase(lp^);
      inc(lp);
      inc(i)
    end;
    if i in [2,3] then
    begin
      if tt(opNot) then
        Result:= true
      else
      if tt(opDiv) then
        Result:= true
      else
      if tt(opMod) then
        Result:= true
      else
      if tt(opAnd) then
        Result:= true
      else
      if tt(opShl) then
        Result:= true
      else
      if tt(opShr) then
        Result:= true
      else
      if tt(opOr) then
        Result:= true
      else
      if tt(opXor) then
        Result:= true
    end;
    if Result then
      inc(P, i)
  end
end;

type
  TExprFunc = function( var P: PChar; IDF: TIdentifierFunction): IValue;

function Chain(var P: PChar; IDF: TIdentifierFunction;
                   NextFunc: TExprFunc; Ops: TOperators): IValue;
{this function is used to construct a chain of expressions}
var
  NextOpr: TOperator;
  StopF: Boolean;
  lp: PChar;
begin
  StopF:= false;
  Result:= NextFunc(P, IDF);
  try
    repeat
      SwallowWhitespace(P);
      lp:= P;
      if not EoE(P) and GetOperator(lp, NextOpr) and (NextOpr in Ops) then
      begin
        P:= lp;
        if NextOpr in RelationalOperators then
          Result:= TRelationalOp.Create(NextOpr, Result, NextFunc(P, IDF))
        else
          Result:= TBinaryOp.Create(NextOpr, Result, NextFunc(P, IDF))
      end else
      begin
        StopF:= true
      end
    until StopF
  except
    Result:= nil;
    raise
  end
end;

function Expression( var P: PChar; IDF: TIdentifierFunction): IValue;
  forward;

function SimpleFactor( var P: PChar; IDF: TIdentifierFunction): IValue;

function UnsignedNumber: IValue;
type
  TNScan = (nsMantissa, nsDPFound, nsExpFound, nsFound);
var
  S: String[30];
  State: TNScan;
  Int: Boolean;
  SaveSep: Char;

procedure Bomb;
begin
  raise EExpression.Create(Lang(23036))   //'Bad numeric format'
end;

begin
  S:= '';
  Int:= false;
  State:= nsMantissa;
  repeat
    if P^ in Digits then
    begin
      S:= S + P^;
      inc(P)
    end else
    if P^ = DecSeparator then
    begin
      if State = nsMantissa then
      begin
        S:= S + P^;
        inc(P);
        State:= nsDPFound
      end else
      begin
        Bomb
      end;
    end else
    if (P^ = 'e') or (P^ = 'E') then
    begin
      if (State = nsMantissa) or
         (State = nsDPFound) then
      begin
        S:= S + 'E';
        inc(P);
        if P^ = '-' then
        begin
          S:= S + P^;
          inc(P)
        end;
        State:= nsExpFound;
        if not (P^ in Digits) then
          Bomb
      end else
      begin
        Bomb
      end
    end else
    begin
      Int:= (State = nsMantissa);
      State:= nsFound
    end;
    if Length(S) > 28 then
      Bomb
  until State = nsFound;
  if Int then
  begin
    Result:= TIntegerLiteral.Create(StrToInt(S))
  end else
  begin
    {WATCH OUT if you are running another thread
     which might refer to DecimalSeparator &&&}
    SaveSep:= SysUtils.DecimalSeparator;
    SysUtils.DecimalSeparator:= DecSeparator;
    try
      Result:= TFloatLiteral.Create(StrToFloat(S))
    finally
      SysUtils.DecimalSeparator:= SaveSep
    end
  end
end;

function CharacterString: IValue;
var
  SR,s: String;

begin
  SR:= '';
  repeat
    inc(P);
    if P^ = SQuote then
    begin
     inc(P);
      if P^ <> SQuote then
        break;
     end;
     if P^ = #0 then
       raise EExpression.Create(Lang(23038));   //'Unterminated string'
     if Length(SR) > MaxStringLength then
       raise EExpression.Create(Lang(23040));   //'String too long'
     SR:= SR + P^;
  until false;
  {mib}
  s:=SR;
  IF (Length(s)=10) AND (mibIsDate(s,ftEuroDate))
  THEN Result:= TDateLiteral.Create(mibStrToDate(s,ftEuroDate))
  ELSE Result:= TStringLiteral.Create(SR)
  {mib}
end;

{mst}
function HexValue : IValue;
var
  SR: String;
begin
  SR:= '';
  repeat
    inc(P);
    if Length(SR) > MaxStringLength then
      raise EExpression.Create(Lang(23042));   //'Hex string too long'
    if not (P^ in HexDigs) then break;
      SR:= SR + P^
  until False;
  try
    Result:= TintegerLiteral.Create(StrToInt(SHex+SR))
  except
    raise EExpression.Create(Lang(23044))    //'Invalid char in hex number'
  end;
end;
{mst}

var
  Identifier: String;
  Operator: TOperator;
  PList: TParameterList;
  MoreParameters: Boolean;

begin {simple factor}
  Result:= nil;
  try
    SwallowWhitespace(P);
    if GetOperator(P, Operator) then
    begin
      case Operator of
        opPlus:
          Result:= TUnaryOp.Create(opPlus, SimpleFactor(P, IDF));
        opMinus:
          Result:= TUnaryOp.Create(opMinus, SimpleFactor(P, IDF));
        opNot:
          Result:= TUnaryOp.Create(opNot, SimpleFactor(P, IDF));
      else
        raise EExpression.CreateFmt(Lang(23046), [NOperator[Operator]]);  //'%s not allowed here'
      end;
    end else
    if P^ = SQuote then
    begin
      Result:= CharacterString;
    end else
    {mst}
    if P^ = SHex then
    begin
      Result:= HexValue;
    end else
    {mst}
    if P^ in Digits then
    begin
      Result:= UnsignedNumber;
    end else
    if P^ = OpenSub then
    begin
      Inc(P);
      Result:= Expression(P, IDF);
      {K Friesen's bug 2. Expression may be nil if
      factor = (). Note: this may also apply to
      parameters i.e. Func(x ,, y)}
      if Result = nil then
        raise EExpression.Create(Lang(23048));   //'invalid sub-expression'
      if P^ = CloseSub then
        inc(P)
      else
        raise EExpression.Create(' '+Lang(23050))   //') expected'
    end else
    if P^ in PrimaryIdentChars then
    begin
      Identifier:= '';
      while P^ in IdentChars do
      begin
        Identifier:= Identifier + UpCase(P^);
        inc(P)
      end;
      if Identifier = 'TRUE' then
      begin
        Result:= TBooleanLiteral.Create(true)
      end else
      if Identifier = 'FALSE' then
      begin
        Result:= TBooleanLiteral.Create(false)
      end else
      begin
        PList:= nil;
        try
          SwallowWhitespace(P);
          MoreParameters:= P^ = OpenSub;
          if MoreParameters then
          begin
            PList:= TParameterList.Create;
            while MoreParameters do
            begin
              inc(P);
              PList.AddExpression(Expression(P, IDF));
              MoreParameters:= P^ = ParamDelimiter
            end;
            {bug fix 11/11/97}
            if P^ = CloseSub then
              Inc(P)
            else
              raise EExpression.Create(Lang(23052))   //'Incorrectly formed parameters'
          end;
          Result:= StandardFunctions(Identifier, PList);
          if (Result = nil) and Assigned(IDF) then
            Result:= IDF(Identifier, PList);
          if Result = nil then
            raise EExpression.CreateFmt(Lang(23054), [Identifier])  //'Unknown Identifier %s'
          else
          if not Result.TestParameters then
            raise EExpression.CreateFmt(Lang(23056), [Identifier])   //'Invalid parameters to %s'
        finally
          if Result = nil then
            PList.Free
        end
      end
    end else
    {mib - introduces handling of dot as missing value}
    if P^='.' THEN
    begin
      //Result:=TStringLiteral.Create('');
      //Result:=TIntegerLiteral.Create($FFFFFFFE);
      Result:=TMissingLiteral.Create;
      INC(P)
    end else
    {mib}
    if EoE(P) then
    begin
      raise EExpression.Create('Unexpected end of factor')
    end else
    begin
      raise EExpression.Create(Lang(23058)) {leak here ?}   //'Syntax error'
    end
  except
    Result:= nil;
    raise
  end
end;  {Simplefactor}

function ObjectProperty( var P: PChar; IDF: TIdentifierFunction): IValue;
var
  PropName: String;
begin
  SwallowWhitespace(P);
  Result:= SimpleFactor(P, IDF);
  SwallowWhitespace(P);
  while (Result.ExprType = ttObject) and (P^ = '.') do
  begin
    Inc(P);
    SwallowWhitespace(P);
    if P^ in PrimaryIdentChars then
    begin
      PropName:= '';
      while P^ in IdentChars do
      begin
        PropName:= PropName + P^;
        inc(P)
      end;
      Result:= TObjectProperty.Create(Result, PropName)
    end else
    begin
      raise EExpression.CreateFmt('Invalid property of object %s', [Result.AsObject.ClassName])
    end
  end;
end;

function Factor( var P: PChar; IDF: TIdentifierFunction): IValue;
begin
  Result:= Chain(P, IDF, ObjectProperty, [opExp])
end;

function Term( var P: PChar; IDF: TIdentifierFunction): IValue;
begin
  Result:= Chain(P, IDF, Factor, [opMult, opDivide, opDiv, opMod, opAnd, opShl, opShr])
end;

function Simple( var P: PChar; IDF: TIdentifierFunction): IValue;
begin
  Result:= Chain(P, IDF, Term, [opPlus, opMinus, opOr, opXor])
end;

function Expression( var P: PChar; IDF: TIdentifierFunction): IValue;
begin
  Result:= Chain(P, IDF, Simple, RelationalOperators)
end;

function CreateExpression( const S: String;
                IdentifierFunction: TIdentifierFunction): IValue;
var
  P:PChar;
begin
  ResultEqualsMissing:=False;
  NumVariables:=0;
  NumMissingVariables:=0;
  P:= PChar(S);
  Result:= Expression(P, IdentifierFunction);
  if P^ <> #0 then
  begin
    Result:= nil;
    raise EExpression.CreateFmt(Lang(23060), [P^])   //'%s not appropriate'
  end
end;


function TExpression.TypeInfo: PTypeInfo;
begin
  case ExprType of
    ttString: Result:= System.TypeInfo(String);
    ttFloat: Result:= System.TypeInfo(Double);
    ttInteger: Result:= System.TypeInfo(Integer);
    ttBoolean: Result:= System.TypeInfo(Boolean);
  else
    raise EExpression.CreateFmt('Cannot provide TypeInfo for %s', [ClassName])
  end
end;

function TEnumeratedLiteral.TypeInfo: PTypeInfo;
begin
  Result:= Rtti
end;

function TObjectRef.TypeInfo: PTypeInfo;
begin
  if Assigned(FObject) then
    Result:= FObject.ClassInfo
  else
    Result:= TObject.ClassInfo
end;

function FoldConstant( Value: IValue): IValue;
begin
  if Assigned(Value) then
  case Value.ExprType of
    ttObject: Result:= TObjectRef.Create(Value.AsObject);
    ttString: Result:= TStringLiteral.Create(Value.AsString);
    ttFloat: Result:= TFloatLiteral.Create(Value.AsFloat);
    ttInteger: Result:= TIntegerLiteral.Create(Value.AsInteger);
    ttEnumerated: Result:= TEnumeratedLiteral.Create(Value.TypeInfo, Value.AsInteger);
    ttBoolean: Result:= TBooleanLiteral.Create(Value.AsBoolean);
  else
    Result:= nil
  end
end;

function TObjectProperty.TypeInfo: PTypeInfo;
begin
  Result:= PropInfo.PropType^
end;

{mib}
function TDateExpr.TestParameters: Boolean;
begin
  Result:= (ParameterCount = 3) and
           (Param[0].CanReadAs(ttInteger)) and
           (Param[1].CanReadAs(ttInteger)) and
           (Param[2].CanReadAs(ttInteger));
end;

function TDateExpr.AsFloat: Double;
begin
  Result:= Double(EncodeDate(Param[2].AsInteger,
  Param[1].AsInteger,Param[0].AsInteger));
end;

function TDateExpr.AsInteger: Integer;
BEGIN
  Result:= Round(EncodeDate(Param[2].AsInteger,
  Param[1].AsInteger,Param[0].AsInteger));
END;

function TDateExpr.AsString: String;
BEGIN
  Result:=FloatToStr(AsFloat);
END;

function TDateExpr.ExprType: TExprType;
begin
  Result:= ttFloat;
end;

function TYearExpr.TestParameters: Boolean;
begin
  Result:= (ParameterCount = 1) and
           (Param[0].CanReadAs(ttFloat));
end;

function TYearExpr.AsInteger: Integer;
VAR
  d,m,y:Word;
BEGIN
  DecodeDate(Param[0].AsFloat,y,m,d);
  Result:= y;
END;

function TYearExpr.AsString: String;
BEGIN
  Result:=IntToStr(AsInteger);
END;

function TYearExpr.ExprType: TExprType;
begin
  Result:= ttInteger;
end;

function TMonthExpr.TestParameters: Boolean;
begin
  Result:= (ParameterCount = 1) and
           (Param[0].CanReadAs(ttFloat));
end;

function TMonthExpr.AsInteger: Integer;
VAR
  d,m,y:Word;
BEGIN
  DecodeDate(Param[0].AsFloat,y,m,d);
  Result:= m;
END;

function TMonthExpr.AsString: String;
BEGIN
  Result:=IntToStr(AsInteger);
END;

function TMonthExpr.ExprType: TExprType;
begin
  Result:= ttInteger;
end;

function TDayExpr.TestParameters: Boolean;
begin
  Result:= (ParameterCount = 1) and
           (Param[0].CanReadAs(ttFloat));
end;

function TDayExpr.AsInteger: Integer;
VAR
  d,m,y:Word;
BEGIN
  DecodeDate(Param[0].AsFloat,y,m,d);
  Result:= d;
END;

function TDayExpr.AsString: String;
BEGIN
  Result:=IntToStr(AsInteger);
END;

function TDayExpr.ExprType: TExprType;
begin
  Result:= ttInteger;
end;

Function TWeekNumExpr.TestParameters: Boolean;
BEGIN
  Result:= (ParameterCount = 1) AND
           (Param[0].CanReadAs(ttFloat));
END;

Function TWeekNumExpr.AsInteger: Integer;
BEGIN
  Result:=WeekNum(Param[0].AsFloat);
END;

Function TWeekNumExpr.AsString: String;
BEGIN
  Result:=IntToStr(AsInteger);
END;

Function TWeekNumExpr.ExprType: TExprType;
BEGIN
  Result:=ttInteger;
END;

Function TDayOfWeekExpr.TestParameters: Boolean;
BEGIN
  Result:= (ParameterCount =1) AND
           (Param[0].CanReadAs(ttFloat));
END;

Function TDayOfWeekExpr.AsInteger: Integer;
BEGIN
  Result:=dkDayOfWeek(Param[0].AsFloat);
END;

Function TDayOfWeekExpr.AsString: String;
BEGIN
  Result:=IntToStr(AsInteger);
END;

Function TDayOfWeekExpr.ExprType: TExprType;
BEGIN
  Result:=ttInteger;
END;

Function TSoundexExpr.TestParameters: Boolean;
BEGIN
  Result:= (ParameterCount=1) AND
           (Param[0].CanReadAs(ttString));
END;

Function TSoundexExpr.AsString: String;
BEGIN
  Result:=soundex(Param[0].AsString);
END;

Function TSoundexExpr.ExprType: TExprType;
BEGIN
  Result:=ttString;
END;

Function TTimeValueExpr.TestParameters: Boolean;
BEGIN
  Result:=(Parametercount=1) AND (Param[0].CanReadAs(ttFloat));
END;

Function TTimeValueExpr.AsFloat: Double;
BEGIN
  {A double represents a time with hh.mm
   Result is the time expressed as a fraction of 24 hours}
  Result:=(  (Int(Param[0].AsFloat)*60) + (Frac(Param[0].AsFloat)*100) ) / 1440
END;

Function TTimeValueExpr.AsString: String;
BEGIN
  Result:=FloatToStr(AsFloat);
END;

Function TTimeValueExpr.ExprType: TExprType;
BEGIN
  Result:=ttFloat;
END;

Function TTimeExpr.TestParameters: Boolean;
BEGIN
  Result:=(ParameterCount=1) AND (Param[0].CanReadAs(ttFloat));
END;

Function TTimeExpr.AsFloat: Double;
BEGIN
  {A float represent a datetime - the fractional part is returned
   as a time (float) in the form hh.mm}
  Result:=Frac(Param[0].AsFloat)*1440;   //number of minutes
//=+HELTAL(F14/60)+(REST(F14;60)/100)
  Result:=Int(Result/60)+ ((Result-(Int(Result/60)*60))/100);
  Result:=Round(Result*100)/100;
  IF Frac(Result)>0.59
  THEN Result:=Int(Result+1);
END;

Function TTimeExpr.AsString: string;
BEGIN
  Result:=FloatToStr(AsFloat);
END;

Function TTimeExpr.ExprType: TExprType;
BEGIN
  Result:=ttFloat;
END;


Function TIsBlankExpr.TestParameters: Boolean;
begin
  Result:= (ParameterCount = 1) and
           (Param[0].CanReadAs(ttString));
end;


function TIsBlankExpr.AsBoolean: Boolean;
BEGIN
  Result:= (trim(Param[0].AsString)='');
END;

function TIsBlankExpr.AsString: String;
BEGIN
  IF AsBoolean THEN Result:='TRUE'
  ELSE Result:='FALSE';
END;

function TIsBlankExpr.ExprType: TExprType;
begin
  Result:= ttBoolean;
end;

function TCountMissingExpr.TestParameters: Boolean;
begin
  IF ParameterCount=0 THEN Result:=False ELSE Result:=True;
end;

function TCountMissingExpr.AsInteger: Integer;
begin
  Result:=FAsInteger;
end;

function TCountMissingExpr.AsString: String;
begin
  Result:=IntToStr(FAsInteger);
end;

function TCountMissingExpr.ExprType: TExprType;
begin
  Result:=ttInteger;
end;

constructor TCountMissingExpr.Create;
VAR
  n,t: Integer;
  FromField,ToField: Integer;
  s,s2: String;
  AField: PeField;
begin
  inherited Create(aParameterList);
  FAsInteger:=0;
  FOR n:=0 TO ParameterCount-1 DO
    BEGIN
      s:=Param[n].AsString;
      t:=Pos('-',s);
      IF (t>1) AND (t<Length(s)) THEN
        BEGIN
          //range defined ("V1-V5")
          s2:=Copy(s,1,t-1);
          FromField:=GetFieldNumber(s2,HandleVarsDf);
          s2:=Copy(s,t+1,Length(s)-t);
          ToField:=GetfieldNumber(s2,HandleVarsDf);
          IF (FromField<>-1) AND (ToField<>-1) AND (ToField>FromField) THEN
            BEGIN
              //Both parameters recognised as fields
              FOR t:=FromField TO ToField DO
                BEGIN
                  AField:=PeField(HandleVarsDf.FieldList.Items[t]);
                  IF AField^.Felttype<>ftQuestion THEN
                    BEGIN
                      INC(NumVariables);
                      IF trim(AField^.FFieldText)='' THEN
                        BEGIN
                          INC(FAsInteger);
                        END;  //if missing
                    END;  //if not ftQuestion
                END;  //for
            END;  //if
        END   //if
      ELSE IF trim(s)='' THEN
        BEGIN
          INC(FAsInteger);
          DEC(NumMissingVariables);
        END;
    END;
END;

function TSumExpr.TestParameters: Boolean;
begin
  IF ParameterCount=0 THEN Result:=False ELSE Result:=True;
end;

function TSumExpr.AsFloat: Double;
begin
  Result:=FAsDouble;
end;

function TSumExpr.AsString: String;
begin
  Result:=FloatToStr(FAsDouble);
end;

function TSumExpr.ExprType: TExprType;
begin
  Result:=ttFloat;
end;

constructor TSumExpr.Create;
VAR
  n,t: Integer;
  FromField,ToField: Integer;
  s,s2: String;
  AField: PeField;
begin
  inherited Create(aParameterList);
  FAsDouble:=0;
  FOR n:=0 TO ParameterCount-1 DO
    BEGIN
      s:=Param[n].AsString;
      t:=Pos('-',s);
      IF (t>1) AND (t<Length(s)) THEN
        BEGIN
          //range defined ("V1-V5")
          s2:=Copy(s,1,t-1);
          FromField:=GetFieldNumber(s2,HandleVarsDf);
          s2:=Copy(s,t+1,Length(s)-t);
          ToField:=GetfieldNumber(s2,HandleVarsDf);
          IF (FromField<>-1) AND (ToField<>-1) THEN
            BEGIN
              //Both parameters recognised as fields
              FOR t:=FromField TO ToField DO
                BEGIN
                  AField:=PeField(HandleVarsDf.FieldList.Items[t]);
                  IF (AField^.Felttype in [ftInteger,ftFloat,ftIDNUM,
                  ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday,ftBoolean]) THEN
                    BEGIN
                      INC(NumVariables);
                      IF trim(AField^.FFieldText)='' THEN INC(NumMissingVariables)
                      ELSE
                        BEGIN
                          Case AField^.Felttype of
                            ftInteger,ftFloat,ftIDNUM: FAsDouble:=FAsDouble+eStrToFloat(AField^.FFieldText);
                            ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday: FAsDouble:=FAsDouble+mibStrToDate(AField^.FFieldText,AField^.Felttype);
                            ftBoolean: FAsDouble:=FAsDouble+Integer(AField^.FFieldText='Y');
                          END;  //case
                        END;  //else
                    END;  //if legal fieldtype
                END;  //for t
            END;  //if
        END   //if
      ELSE IF Param[n].CanReadAs(ttFloat) THEN FAsDouble:=FAsDouble+Param[n].AsFloat;
    END;  //for n
end;


function TRangeExpr.TestParameters: Boolean;
begin
  Result:=(ParameterCount=3)
    AND   (Param[0].CanReadAs(ttFloat))
    AND   (Param[1].CanReadAs(ttFloat))
    AND   (Param[2].CanReadAs(ttFloat));
end;

function TRangeExpr.AsBoolean:Boolean;
begin
  Result:=(Param[1].AsFloat <= Param[0].AsFloat)
    AND   (Param[0].AsFloat <= Param[2].AsFloat);
end;

function TRangeExpr.Exprtype: TExprType;
begin
  Result:=ttBoolean;
end;

{mib}


end.
