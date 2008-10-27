unit unitGCPClasses;

interface

uses
  sysutils,classes;

const
  MAXGCPUSERS=20;

type
  TGCPUsers=record
    name:string;
    utype: string;
    pw:string;
    note:string;
  end;

  TUserTypes=(utUnknown,utSuperAdmin,utAdmin,utUser);
  TUsers=array[1..MAXGCPUSERS] of TGCPUsers;

TGCPsecfile=class(TObject)
  private
    FMasterPw:string;
    FMasterUsername: string;
    FLoginusername: string;
    FLoginPassword: string;
    FCuruserType: TUserTypes;
    FNumUsers:integer;
    FUsers:TUsers;
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
    Fencrypt: boolean;
    function  RandomPad(len:integer):string;
    procedure AddLine(s:string);
    procedure SetLogWhere(value: string);
    function  Boolean2string(value: boolean):string;
    function  String2Boolean(value: string):boolean;
    function  GetUser(index: Integer): TGCPUsers;
    procedure Clear;
  public
    property MasterPassword:string read FMasterPw write FMasterPw;
    property MasterUsername:string read FMasterUsername write FMasterUsername;
    property LoginUsername:string read FLoginUsername write FLoginUsername;
    property LoginPassword:string read FLoginPassword write FLoginPassword;
    property CurUserType: TUsertypes read FCurUserType write FCurUserType;
    property numUsers:integer read FnumUsers write FnumUsers;
    property Users[Index: integer]: TGCPUsers read GetUser;
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
    procedure AddUser(username,usertype,userpw,usernote:string);
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
  Fencrypt:=true;
end;

destructor TGCPsecfile.destroy;
begin
  FDataFiles.Free;
  inherited destroy;
end;

procedure TGCPsecfile.clear;
var
  n:integer;
begin
  for n:=1 to MAXGCPUSERS do
    begin
      FUsers[n].name:='';
      FUsers[n].utype:='';
      FUsers[n].pw:='';
      FUsers[n].note:='';
    end;
  FNumUsers:=0;
  FMasterPw:='';
  FMasterUsername:='';
  FCurUserType:=utUnknown;
  FDataFiles.Clear;
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

procedure TGCPsecfile.AddUser(username,usertype,userpw,usernote:string);
begin
  if FNumUsers=MAXGCPUSERS then exit;
  inc(FNumUsers);
  if (usertype<>'User') and (usertype<>'Administrator') then usertype:='User';
  FUsers[FNumUsers].name:=username;
  FUsers[FNumUsers].utype:=usertype;
  FUsers[FNumUsers].pw:=userpw;
  FUsers[FNumUsers].note:=usernote;
end;

procedure TGCPsecfile.SetLogWhere(value:string);
begin
  value:=AnsiLowercase(value);
  if (value<>'localfile') then Exception.Create('LogWhere type '+value+' not implemented')
  else FLogWhere:=value;
end;

function TGCPsecfile.GetUser(index: Integer): TGCPUsers;
begin
  result:=FUsers[index];
end;

procedure TGCPsecfile.Save;
var
  s: string;
  n,t,numUsers: integer;
begin
  lin:=TStringList.create;
  numUsers:=0;
  FEncrypt:=true;
  try
    lin.append('numusers='+IntToStr(MAXGCPUSERS));
    s:=FMasterUsername+'¤superadmin¤'+FMasterPw+'¤'+FMasterPw+'¤'+RandomPad(10);
    lin.append(s);
    maxlen:=length(s);
    for n:=1 to MAXGCPUSERS do
      begin
        if FUsers[n].name='' then
          begin
            s:=RandomPad(7)+'¤'+RandomPad(10)+'¤'+RandomPad(8)+'¤'+RandomPad(12)
          end
        else
          begin
            inc(numUsers);
            s:=FUsers[n].name+'¤'+FUsers[n].utype+'¤'+FUsers[n].pw+'¤'+FMasterPw+'¤'+FUsers[n].note;
          end;
        lin.append(s);
        if length(s)>maxlen then maxlen:=length(s);
      end;

    lin[0]:='numusers='+intToStr(numUsers);

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
      AddLine(FDatafiles[n]);

    if Fencrypt then
      begin
        //encrypt lines
        lin[0]:=EncryptString(lin[0],Fmasterpw);  //numusers=
        lin[1]:=EncryptString(lin[1],Fmasterpw);  //administrator
        for n:=2 to MAXGCPUSERS+1 do
          begin
            if FUsers[n-1].pw='' then s:=RandomPad(10) else s:=FUsers[n].pw;
            lin[n]:=EncryptString(lin[n],s);
          end;

        //encrypt users with masterpw + rest of the lines with masterpw
        for n:=MAXGCPUSERS+2 to lin.count-1 do
          begin
            lin[n]:=EncryptString(lin[n],FmasterPw);
          end;
      end;

    lin.SaveToFile(FProjFilename);

  finally
    lin.free;
  end;
end;

procedure TGCPsecfile.Load;
{
Input: brugernavn og kodeord og projekctfilename


For hver linie:
  dekrypt linien med kodeord
  Hvis linien starter med brugernavn+¤ så er brugeren fundet: indlæs brugeroplysninger, hent MasterPW

Afkod linie 1: antal brugere
Indlæs alle brugere: start i linie 3+maxusers og læs antalbrugere linier - dekrypt med MasterPW

Læs derefter projektoptions: start i linie 3+(2*maxusers) - dekrypt med MasterPW
Når kommer til linie med 'Datafiles', så er hver efterfølgende linie en datafil
}
var
  n,foundline,searchlen,numUsers:integer;
  s: string;
  aUser: TGCPUsers;
  aArray: TdynArrayString;
begin
  if(not FileExists(FProjFilename)) then exit;
  if (FLoginUsername='') OR (FLoginPassword='') then exit;
  lin:=TStringList.create;
  try
    lin.LoadFromFile(FProjfilename);
    clear;
    n:=0;
    foundline:=0;
    searchlen:=length(FLoginUsername)+1;
    while (n<lin.count) and (foundline=0) do
      begin
        s:=lin[n];
        if FEncrypt then s:=DecryptString(s,FLoginPassword);
        if copy(s,1,searchlen)=FLoginUsername+'¤' then foundline:=n;
        inc(n);
      end;
    if foundline=0 then exit;
    s:=lin[foundline];
    if FEncrypt then s:=DecryptString(s,FLoginPassword);
    //FUsers[n].name+'¤'+FUsers[n].utype+'¤'+FUsers[n].pw+'¤'+FMasterPw+'¤'+FUsers[n].note;
    aArray:=explode(s,'¤');
    if length(aArray)>=5 then
      begin
        if (aArray[0]=FLoginUsername) and (aArray[2]=FLoginPassword) then
          begin
            s:=AnsiLowerCase(aArray[1]);
            if s='user' then FCurUserType:=utUser
            else if s='administrator' then FCurUserType:=utAdmin
            else if s='superadmin' then FCurUserType:=utSuperAdmin
            else FCurUserType:=utUnknown;

            if FCurUserType<>utUnknown then
              begin
                //Brugeren er fundet - hent Masterpw og alle øvrige oplysninger
                FMasterPw:=aArray[3];
                s:=lin[0];
                if FEncrypt then s:=DecryptString(s,FMasterPw);
                s:=copy(s,1,pos('¤',s)-1);
                try
                  numUsers:=StrToInt(copy(s,pos('=',s)+1,length(s)));
                except
                  FCurUserType:=utUnknown;
                  exit;
                end;
                s:=lin[1];  //Hent superadmin record
                if FEncrypt then s:=DecryptString(s,FMasterPw);
                aArray:=explode(s,'¤');
                FMasterUsername:=aArray[0];

                //Indlæs alle brugere: start i linie 3+maxusers og læs antalbrugere linier - dekrypt med MasterPW
                for n:=2+MAXGCPUSERS to 1+MAXGCPUSERS+numUsers do
                  begin
                    s:=lin[n];
                    if Fencrypt then s:=DecryptString(s,FMasterPw);
                    aArray:=explode(s,'¤');
                    AddUser(aArray[0],aArray[1],aArray[2],aArray[4]);
                  end;

                //Læs derefter projektoptions: start i linie 3+(2*maxusers) - dekrypt med MasterPW
                //Når kommer til linie med 'Datafiles', så er hver efterfølgende linie en datafil
    {
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
    }
                n:=2+(2*MAXGCPUSERS);
                while n<lin.count do
                  begin
                    s:=lin[n];
                    if FEncrypt then s:=DecryptString(s,FMasterPw);
                    s:=copy(s,1,pos('¤',s)-1);
                    //if copy(s,1,pos('=',s)-1)='projectfilename' then FProjfilename:=copy(s,pos('=',s)+1,length(s))
                    if      copy(s,1,pos('=',s)-1)='projectdescription' then FProjDesc:=copy(s,pos('=',s)+1,length(s))
                    else if copy(s,1,pos('=',s)-1)='encryptcheckfile' then FEncryptCheckfile:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if copy(s,1,pos('=',s)-1)='encryptdatafile' then FEncryptDatafile:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if copy(s,1,pos('=',s)-1)='logwhere' then FLogWhere:=copy(s,pos('=',s)+1,length(s))
                    else if copy(s,1,pos('=',s)-1)='logfilename' then FLogFilename:=copy(s,pos('=',s)+1,length(s))
                    else if copy(s,1,pos('=',s)-1)='lognew' then FLogNew:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if copy(s,1,pos('=',s)-1)='logchanges' then FLogEdit:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if copy(s,1,pos('=',s)-1)='logdeletions' then FLogDel:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if copy(s,1,pos('=',s)-1)='logread' then FLogRead:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if copy(s,1,pos('=',s)-1)='logfind' then FLogFind:=string2boolean(copy(s,pos('=',s)+1,length(s)))
                    else if s='Datafiles' then
                      begin
                        inc(n);
                        while n<lin.count do
                          begin
                            s:=lin[n];
                            if FEncrypt then s:=DecryptString(s,FMasterPw);
                            s:=copy(s,1,pos('¤',s)-1);
                            FDataFiles.Append(s);
                            inc(n);
                          end;
                      end;
                    inc(n);
                  end;
              end;
          end;
      end;
  finally
    lin.free;
  end;
end;


end.


