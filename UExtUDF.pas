unit UExtUDF;

interface

uses sysutils,classes,windows,epiUDFTypes;

Type
TEpiExternalUDFList=class
  private
    FList: TList;
    function GetCount: word;
    function GetEpiUDF(index: integer): PTEpiUDF;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Item: Pointer);
    procedure Clear;
    procedure Remove(Item: Pointer);
    function FillFromDLLHandle(var ModuleInfo: TEpiDataModuleInfo): boolean;
    function GetUDFByName(const UDFname: string;var aUDF: TEpiUDF): boolean;
    function GetUDFByCommandString(const UDFstring:string;var aUDF:TEpiUDF): boolean;    
    property Count: word read GetCount;
    property Items[index: integer]: PTEpiUDF read GetEpiUDF;
  end;

function EpiLoadModule(const DLLName:string;var ModuleInfo: TEpiDataModuleInfo): integer;
function EpiUnLoadModule(var ModuleInfo: TEpiDataModuleInfo): integer;

implementation

function EpiLoadModule(const DLLName:string;var ModuleInfo: TEpiDataModuleInfo): integer;
begin
   strlCopy(ModuleInfo.szModuleName, pchar(DLLName),length(ModuleInfo.szModuleName));
   ModuleInfo.ModuleHandle:= loadLibrary(pchar(DLLName));
   ModuleInfo.ModuleID :=1;
end;

function EpiUnLoadModule(var ModuleInfo: TEpiDataModuleInfo): integer;
begin
  FreeLibrary(ModuleInfo.ModuleHandle);
end;


procedure TEpiExternalUDFList.Add(Item: Pointer);
begin
    if FList.IndexOf(Item) = -1 then
    FList.Add(Item);
end;

procedure TEpiExternalUDFList.Clear;
begin
   FList.Clear;
end;

constructor TEpiExternalUDFList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TEpiExternalUDFList.Destroy;
begin
    FList.Free;
    inherited Destroy;
end;

function TEpiExternalUDFList.GetUDFByCommandString(const UDFstring:string;var aUDF:TEpiUDF): boolean;
var
 i, co :integer;
begin
  co := count;
  result:=false;
  IF co=0 THEN Exit;
  for i:= 0 to co-1 do
  begin
      if AnsiCompareText(items[i].szUDFCommandString,UDFstring)=0 then
      begin
         aUDF:=items[i]^;
         result:=true;
      end;
  end;
end;

function TEpiExternalUDFList.FillFromDLLHandle(var ModuleInfo: TEpiDataModuleInfo): boolean;
var
  getUDFcount: TEpiGetIntFunction;
  GetUDFInfo:TEpiGetUDFInfo;
  i : integer;
  functionString:variant;
  ReturnType:variant;
  FunctionName:variant;
  ParamCount:integer;
  aUDF :PTEpiUDF;
  s :string;
begin
  result:=false;
  getUDFcount:=GetProcAddress(ModuleInfo.ModuleHandle,'GetUDFCount');
  if not assigned(getUDFcount) then
    raise Exception.create('Invalid DLL');
  ModuleInfo.UDFCount:=getUDFcount;
  if ModuleInfo.UDFCount<1 then
    raise Exception.create('No UDFs');
  GetUDFInfo:=GetProcAddress(ModuleInfo.ModuleHandle,'GetUDFInfo');
  if not assigned(GetUDFInfo) then
    raise Exception.create('Invlaid DLL');
  for i := 1 to ModuleInfo.UDFCount do
  begin
     GetUDFInfo(i, functionString,ReturnType,FunctionName,ParamCount);
     new(aUDF);
     aUDF.ModuleId := ModuleInfo.ModuleHandle; //Must be change to ModuleID at a later stage.
     s :=functionString;
     StrLcopy(aUDF.szUDFCommandString ,pchar(s),length(s));
     s :=FunctionName;
     StrLcopy(aUDF.szUDFName,pchar(s),length(s));
     aUDF.ReturnType:=ReturnType;
     aUDF.ParamCount:= ParamCount;
     add(aUDF);
  end;
end;

procedure TEpiExternalUDFList.Remove(Item: Pointer);
begin
   FList.Remove(Item);
end;

function TEpiExternalUDFList.GetCount: word;
begin
  IF Assigned(FList) THEN result:=Flist.count ELSE result:=0;
end;

function TEpiExternalUDFList.GetEpiUDF(index: integer): PTEpiUDF;
begin
  if (index>-1) and (index<count) then begin
    result:=Flist[index];
  end;
end;

function TEpiExternalUDFList.GetUDFByName(const UDFname: string;
  var aUDF: TEpiUDF): boolean;
begin

end;

end.
