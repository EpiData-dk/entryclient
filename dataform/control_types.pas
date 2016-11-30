unit control_types;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, epidatafiles, fgl;

type

  TFieldValidateErrorProc = procedure (Sender: TObject; Const Msg: String) of object;
  TFieldValidateResult = (fvrAccept, fvrReject, fvrNone);

  IEntryControl = interface ['IEntryControl']
    procedure UpdateSettings;
  end;


  { IEntryDataControl }

  IEntryDataControl = interface(IEntryControl) ['IEntryControl']
    function  GetField: TEpiField;
    procedure SetField(const AValue: TEpiField);

    function  GetRecNo: integer;
    procedure SetRecNo(const AValue: integer);

    function  GetJumpToNext: boolean;
    procedure SetJumpToNext(AValue: boolean);

    function  GetOnValidateError: TFieldValidateErrorProc;
    procedure SetOnValidateError(AValue: TFieldValidateErrorProc);

    function GetText: TCaption;
    procedure SetText(const AValue: TCaption);

    function GetCustomEdit: TCustomEdit;

    function    ValidateEntry: boolean;
    procedure   Commit;
    function    CompareTo(Const AText: string; ct: TEpiComparisonType): boolean;
    property    Field: TEpiField read GetField write SetField;
    property    RecNo: integer read GetRecNo write SetRecNo;
    property    JumpToNext: boolean read GetJumpToNext write SetJumpToNext;
    property    OnValidateError: TFieldValidateErrorProc read GetOnValidateError write SetOnValidateError;
    property    CustomEdit: TCustomEdit read GetCustomEdit;
  end;

implementation

end.

