unit dataform_script_executor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epi_script_executor, epi_script_AST,
  dataform_frame, epidatafiles;

type

  { TDataFormScriptExecutor }

  TDataFormScriptExecutor = class(TEpiScriptExecutor)
  { Executor Overrides }
  private
    FGotoJump: TEpiJump;
  protected
    procedure ProcessGoto(AGoto: TGoto); override;
  public
    procedure SetFieldValue(const Sender: TObject; const F: TEpiField;
       const Value: Variant); override;
    function GetFieldValue(const Sender: TObject; const F: TEpiField
       ): Variant; override;
    function ExecuteScript(StatementList: TStatementList = nil): boolean;
       override;
    property GotoJump: TEpiJump read FGotoJump;

  { Class related items }
  private
    FOwnerField: TEpiField;
    FDataForm: TDataFormFrame;
  public
    constructor Create(Dataform: TDataFormFrame; OwnerField: TEpiField);
  end;

implementation

{ TDataFormScriptExecutor }

procedure TDataFormScriptExecutor.ProcessGoto(AGoto: TGoto);
begin
  inherited ProcessGoto(AGoto);
  FDataForm.ProcessGoto(FOwnerField, AGoto, FGotoJump);
end;

procedure TDataFormScriptExecutor.SetFieldValue(const Sender: TObject;
  const F: TEpiField; const Value: Variant);
begin
  FDataForm.SetFieldValue(Sender, F, Value);
end;

function TDataFormScriptExecutor.GetFieldValue(const Sender: TObject;
  const F: TEpiField): Variant;
begin
  Result := FDataForm.GetFieldValue(Sender, F);
end;

function TDataFormScriptExecutor.ExecuteScript(StatementList: TStatementList
  ): boolean;
begin
  FGotoJump := nil;
  Result := inherited ExecuteScript(StatementList);
end;

constructor TDataFormScriptExecutor.Create(Dataform: TDataFormFrame;
  OwnerField: TEpiField);
begin
  inherited Create;
  FDataForm := Dataform;
  FOwnerField := OwnerField;
end;

end.

