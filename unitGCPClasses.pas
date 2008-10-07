unit unitGCPClasses;

interface

uses
  sysutils,classes;

const
  MAXGCPUSERS=20;

type
  TGCPUsers=record
    name:string;
    pw:string;
    note:string;
  end;

TGCPsecfile=class(TObject)
  private
    FMasterPw:string;
    FMasterUsername: string;
    FNumUsers:integer;
    FUsers:array[1..MAXGCPUSERS] of TGCPUsers;
    FProjDesc:string;
    FProjfilename:string;
    FEncryptCheckFile: boolean;
    FEncryptDataFile: boolean;
    FLogWhere: string;
    FLogFilename: string;
    FLognew: boolean;
    FLogEdit: boolean;
    FLogDel: boolean;
    FLogRead: boolean;
    FLogFind: boolean;
    FDataFiles: TStringList;
    Lin: TStringList;
    MaxLen: integer;
    function RandomPad(len:integer):string;
    procedure AddLine(s:string);
    procedure SetLogWhere(value: string);
    function Boolean2string(value: boolean):string;
    function String2Boolean(value: string):boolean;
  public
    property MasterPassword:string read FMasterPw write FMasterPw;
    property MasterUsername:string read FMasterUsername write FMasterUsername;
    property ProjectDescription:string read FProjDesc write FProjDesc;
    property ProjectFilename:string read FProjfilename write FProjfilename;
    property EncryptDataFile:boolean read FEncryptDatafile write FEncryptDatafile;
    property EncryptCheckFile:boolean read FEncryptDataFile write FEncryptDataFile;
    property LogWhere:string read FLogWhere write SetLogWhere;
    property Logfilename:string read FLogfilename write FLogfilename;
    property LogNew:boolean read FLogNew write FLogNew;
    property LogEdit:boolean read FLogEdit write FLogEdit;
    property LogDel:boolean read FLogDel write FLogDel;
    property LogRead:boolean read FLogRead write FLogRead;
    property LogFind:boolean read FLogFind write FLogFind;
    property Datafiles:TStringList read FDatafiles write FDatafiles;
    procedure AddUser(username,userpw,usernote:string);
    procedure Save;
    procedure Load;
    constructor create;
    destructor  destroy;
end;



implementation

uses
  EpiTypes;

//************************ Class TGCPsecfile *************************

    {  sec-file format:
       1. linie er numusers=X, dvs antal brugere incl. admin

       1-MAXUSERS linier der er krypteret med den enkelte users pw.
       For ubrugte users er username=nothing.

       userX=username¤userpw¤masterpw¤usernote¤padding

       Herefter kommer alle users igen, men nu kodet med masterpw

       Resten af filen er krypteret med masterpw, alle linier slutter med ¤ og padding:
       projectfilename=
       projectdescription=
       encryptcheckfile=true|false
       encryptdatafile=true|false
       logwhere=localfile|ws|ftp
       logfilename=
       lognew=true|false
       logchanges=true|false
       logdeletions=true|false
       logread=true|false
       logfind=true|false
       datafileX=
       datafileY=....
    }

constructor TGCPsecfile.create;
begin
  inherited create;
  Randomize;
  FDataFiles:=TStringList.create;
  FNumUsers:=0;
end;

destructor TGCPsecfile.destroy;
begin
  FDataFiles.Free;
  inherited destroy;
end;

function TGCPsecfile.RandomPad(len:integer):string;
CONST
  chars='23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!?/*+-';
begin
  result:='';
  if len=0 then exit;
  while (length(result)<len) do result:=result+chars[Random(length(chars))+1];
end;

procedure TGCPsecfile.AddLine(s:string);
begin
  s:=s+'¤'+RandomPad(maxlen-length(s));
  lin.append(s);
end;

function TGCPsecfile.boolean2string(value: boolean):string;
begin
  if value=true then result:='true' else result:='false';
end;

function TGCPsecfile.string2boolean(value: string):boolean;
begin
  if AnsiLowerCase(value)='true' then result:=true else result:=false;
end;

procedure TGCPsecfile.AddUser(username,userpw,usernote:string);
begin
  if FNumUsers=MAXGCPUSERS then exit;
  inc(FNumUsers);
  FUsers[FNumUsers].name:=username;
  FUsers[FNumUsers].pw:=userpw;
  FUsers[FNumUsers].note:=usernote;
end;

procedure TGCPsecfile.SetLogWhere(value:string);
begin
  value:=AnsiLowercase(value);
  if (value<>'localfile') then Exception.Create('LogWhere type '+value+' not implemented')
  else FLogWhere:=value;
end;

procedure TGCPsecfile.Save;
var
  s: string;
  n,t: integer;
begin
  lin:=TStringList.create;
  try
    lin.append('numusers='+IntToStr(MAXGCPUSERS));
    s:=FMasterUsername+'¤'+FMasterPw+'¤'+FMasterPw+'¤'+RandomPad(10);
    lin.append(s);
    maxlen:=length(s);
    for n:=1 to MAXGCPUSERS do
      begin
        if FUsers[n].name=''
        then s:='noone¤'+RandomPad(10)+'¤'+RandomPad(12)
        else s:=FUsers[n].name+'¤'+FUsers[n].pw+'¤'+FUsers[n].note;
        lin.append(s);
        if length(s)>maxlen then maxlen:=length(s);
      end;

    for n:=1 TO MAXGCPUSERS do
      begin
        lin.append(lin[n+1]);
      end;

    if length('projectdescription='+FProjDesc)>maxlen then maxlen:=length('projectdescription='+FProjDesc);
    maxlen:=maxlen+10;
    for n:=0 to lin.count-1 do
      begin
        lin[n]:=lin[n]+'¤'+RandomPad(maxlen-length(lin[n]));
      end;
    AddLine('projectfilename='+FProjfilename);
    AddLine('projectdescription='+FProjDesc);
    AddLine('encryptcheckfile='+boolean2string(FEncryptCheckfile));
    AddLine('encryptdatafile='+boolean2string(FEncryptDatafile));
    AddLine('logwhere='+FLogWhere);
    AddLine('logfilename='+ExtractFilename(FLogFilename));
    AddLine('lognew='+boolean2string(FLogNew));
    AddLine('logchanges='+boolean2string(FLogEdit));
    AddLine('logdeletions='+boolean2string(FLogDel));
    AddLine('logread='+boolean2string(FLogRead));
    AddLine('logfind='+boolean2string(FLogFind));
    AddLine('Datafiles');
    for n:=0 to FDatafiles.Count-1 do
      AddLine('datafile'+IntToStr(n)+'='+ExtractFilename(FDatafiles[n]));

    //encrypt lines
    lin[0]:=EncryptString(lin[0],Fmasterpw);  //numusers=
    lin[1]:=EncryptString(lin[1],Fmasterpw);  //administrator
    for n:=1 to MAXGCPUSERS do
      begin
        if FUsers[n].pw='' then s:=RandomPad(10) else s:=FUsers[n].pw;
        lin[n]:=EncryptString(lin[n],s);
      end;

    //encrypt users with masterpw
    for n:=1 to MAXGCPUSERS do
      begin
        lin[n+MAXGCPUSERS+2]:=EncryptString(lin[n+MAXGCPUSERS+2],FmasterPw);
      end;

    for n:=(MAXGCPUSERS*2)+3 to lin.count-1 do
      lin[n]:=EncryptString(lin[n],Fmasterpw);

    lin.SaveToFile(FProjFilename);

  finally
    lin.free;
  end;
end;

procedure TGCPsecfile.Load;
begin
end;


end.


