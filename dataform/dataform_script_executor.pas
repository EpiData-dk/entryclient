unit dataform_script_executor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epi_script_executor, epi_script_AST,
  dataform_frame, epidatafiles, epidatafilestypes;

type

  TDataFormScriptError = procedure (Const OwnerField: TEpiField;
    Const Msg: string; Const ColNo, LineNo: integer; Const LineTxt: string) of object;

  { TDataFormScriptExecutor }

  TDataFormScriptExecutor = class(TEpiScriptExecutor)
  { Executor Overrides }
  private
    FGotoJump: TEpiJump;
  protected
    procedure ProcessGoto(AGoto: TGoto); override;
  public
    procedure SetFieldValue(Const Sender: TObject; Const F: TEpiField; Const Value: EpiBool); override; overload;
    procedure SetFieldValue(Const Sender: TObject; Const F: TEpiField; Const Value: EpiInteger); override; overload;
    procedure SetFieldValue(Const Sender: TObject; Const F: TEpiField; Const Value: EpiFloat); override; overload;
    procedure SetFieldValue(Const Sender: TObject; Const F: TEpiField; Const Value: EpiString); override; overload;
    function GetFieldValueBool(Const Sender: TObject; Const F: TEpiField): EpiBool; override;
    function GetFieldValueInt(Const Sender: TObject; Const F: TEpiField): EpiInteger; override;
    function GetFieldValueFloat(Const Sender: TObject; Const F: TEpiField): EpiFloat; override;
    function GetFieldValueString(Const Sender: TObject; Const F: TEpiField): EpiString; override;

    function ExecuteScript(StatementList: TStatementList = nil): boolean;
       override;
    procedure ParseError(const Msg: string; const LineNo, ColNo: integer;
       const TextFound: string); override;
    property GotoJump: TEpiJump read FGotoJump;

  { Class related items }
  private
    FOnError: TDataFormScriptError;
    FOwnerField: TEpiField;
    FDataForm: TDataFormFrame;
    procedure SetOnError(AValue: TDataFormScriptError);
  public
    constructor Create(Dataform: TDataFormFrame; OwnerField: TEpiField);
    property OnError: TDataFormScriptError read FOnError write SetOnError;
  end;

implementation

uses
  math;

{ TDataFormScriptExecutor }

procedure TDataFormScriptExecutor.ProcessGoto(AGoto: TGoto);
begin
  inherited ProcessGoto(AGoto);
  FDataForm.ProcessGoto(FOwnerField, AGoto, FGotoJump);
end;

procedure TDataFormScriptExecutor.SetFieldValue(const Sender: TObject;
  const F: TEpiField; const Value: EpiBool);
begin
  FDataForm.SetFieldValue(Sender, F, Value);
end;

procedure TDataFormScriptExecutor.SetFieldValue(const Sender: TObject;
  const F: TEpiField; const Value: EpiInteger);
begin
  FDataForm.SetFieldValue(Sender, F, Value);
end;

procedure TDataFormScriptExecutor.SetFieldValue(const Sender: TObject;
  const F: TEpiField; const Value: EpiFloat);
begin
  FDataForm.SetFieldValue(Sender, F, Value);
end;

procedure TDataFormScriptExecutor.SetFieldValue(const Sender: TObject;
  const F: TEpiField; const Value: EpiString);
begin
  FDataForm.SetFieldValue(Sender, F, Value);
end;

function TDataFormScriptExecutor.GetFieldValueBool(const Sender: TObject;
  const F: TEpiField): EpiBool;
begin
  result := EpiBool(FDataForm.GetFieldValue(Sender, F));
end;

function TDataFormScriptExecutor.GetFieldValueInt(const Sender: TObject;
  const F: TEpiField): EpiInteger;
begin
  result := EpiInteger(FDataForm.GetFieldValue(Sender, F));
end;

function TDataFormScriptExecutor.GetFieldValueFloat(const Sender: TObject;
  const F: TEpiField): EpiFloat;
begin
  result := EpiFloat(FDataForm.GetFieldValue(Sender, F));
end;

function TDataFormScriptExecutor.GetFieldValueString(const Sender: TObject;
  const F: TEpiField): EpiString;
begin
  result := EpiString(FDataForm.GetFieldValue(Sender, F));
end;

function TDataFormScriptExecutor.ExecuteScript(StatementList: TStatementList
  ): boolean;
var
  M: TFPUExceptionMask;
begin
  {
    SetExceptionmask:
    Needed because GTK widgetset sets ZeroDevide exceptionmask, but we need
    it during screipt calculations
  }
  M := GetExceptionMask;
  SetExceptionMask(M - [exZeroDivide, exInvalidOp]);

  FGotoJump := nil;
  Result := inherited ExecuteScript(StatementList);
  SetExceptionMask(M);
end;

procedure TDataFormScriptExecutor.ParseError(const Msg: string; const LineNo,
  ColNo: integer; const TextFound: string);
begin
  if Assigned(OnError) then
    OnError(FOwnerField, Msg, ColNo, LineNo, TextFound)
  else
    inherited ParseError(Msg, LineNo, ColNo, TextFound);
end;

procedure TDataFormScriptExecutor.SetOnError(AValue: TDataFormScriptError);
begin
  if FOnError = AValue then Exit;
  FOnError := AValue;
end;

constructor TDataFormScriptExecutor.Create(Dataform: TDataFormFrame;
  OwnerField: TEpiField);
begin
  inherited Create;
  FDataForm := Dataform;
  FOwnerField := OwnerField;
end;

end.

