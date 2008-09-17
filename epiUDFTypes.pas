unit epiUDFTypes;

interface

uses classes;
Type

TEpiFileName=array[0..31] of char;
TEpiFilePath=array[0..255] of char;
TEpiCommandString=array[0..255] of char;

TEpiHandle=LongWord;
TEpiErrorCode = word;
TPEpiDataModuleInfo=^TEpiDataModuleInfo;
TPEpiMenuCommand=^TEpiMenuCommand;
TPEpiDataModuleRec=^TEpiDataModuleRec;

TEpiInitLibProc=procedure(ModuleInfo: TPEpiDataModuleInfo);
TEpiRegCmdProc=procedure(CommandInfo: TPEpiMenuCommand);

TUDFFunction=procedure(const ParamList:variant;var ReturnValue:variant);
//TUDFFunction=function(const ParamList:variant):variant;
TUDFValidateFunction=function(ParamList:variant):integer;
TEpiGetIntFunction=function :integer;
TEpiGetUDFInfo=procedure (Const UDFid:integer; var functionString:variant;var ReturnType:variant;
       var FunctionName:variant;var ParamCount:integer);

TUDFReturnType=word;

TEpiDataVersionInfo=record
  Major,
  Minor,
  BuildNo :word;
end;

TEpiContext=record
  RegisterCommand:TEpiRegCmdProc;
  UnRegisterCommand:TEpiRegCmdProc;
end;

TEpiDataModuleInfo=record
  ModuleID     :TEpiHandle;
  ModuleHandle     : TEpiHandle;
  ModuleType   :Word;
  ModulePriority :word;
  szModuleName: TEpiFileName;
  szHelpfileName: TEpiFilePath;
  MinimumEpiDataVersion : TEpiDataVersionInfo;
  EpiDataVersion : TEpiDataVersionInfo;
  OSRequired: word;
  MinimumOSVersion : TEpiDataVersionInfo;
  EpiDataHandle    : TEpiHandle;
  ErrorCode        : TEpiErrorCode;
  UDFCount      :Word;
//  Context          : TEpiContext;
end;


TEpiDataModuleRec=record
 ModuleInfo: TEpiDataModuleInfo;
 szModulefileName: TEpiFilePath;
 ModuleHandle     : TEpiHandle;
 InitializeModule,
 finalizeModule : TEpiInitLibProc;
 ExecuteCommand:TEpiRegCmdProc;
end;


TEpiMenuCommand=record
 ModuleId : word;
 CommandType  :word;
 szCommandName:TEpiCommandString;
 szCommandHint:TEpiCommandString;
 commandID    :word;
end;

PTEpiUDF=^TEpiUDF;
TEpiUDF=record
 ModuleId : integer;
 szUDFName:TEpiCommandString;
 szUDFCommandString:TEpiCommandString;
 szUDFDescription:TEpiCommandString;
 UDFID    :word;
 ExecuteUDF  :  TUDFFunction;
 ValidateParam: TUDFValidateFunction;
 ReturnType:TUDFReturnType;
 ParamCount  : Word;
end;




const
  Epi_OK=0;
  Epi_Cancel=1;

  UDFReturnString=0;
  UDFReturnInteger=1;
  UDFReturnFloat=2;
  UDFReturnBoolean=3;

implementation





end.
