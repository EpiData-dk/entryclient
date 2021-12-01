unit admin_authenticator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epicustombase, epidocument, epiopenfile, epirights,
  epiadmin, epidatafiles;

type

  { TAuthenticator }

  TAuthenticator = class
  private
    FDocument: TEpiDocument;
    FDocumentFile: TEpiDocumentFile;

    procedure DocumentHook(const Sender: TEpiCustomBase;
      const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup;
      EventType: Word; Data: Pointer);
    function GetAdmin: TEpiAdmin;
    function GetAuthedUser: TEpiUser;
  public
    constructor Create(Const ADocumentFile: TEpiDocumentFile);
    destructor Destroy; override;
    function AuthedUserEntryRights(Const DataFile: TEpiDataFile): TEpiEntryRights;
    function IsAuthorizedEntry(Const DataFile: TEpiDataFile; Const EntryRight: TEpiEntryRights): boolean;
    function IsAuthorizedManager(Const ManageRights: TEpiManagerRights): boolean;
  public
    property DocumentFile: TEpiDocumentFile read FDocumentFile;
    property Admin: TEpiAdmin read GetAdmin;
    property AuthedUser: TEpiUser read GetAuthedUser;
  end;

var
  Authenticator: TAuthenticator;

implementation


{ TAuthenticator }

procedure TAuthenticator.DocumentHook(const Sender: TEpiCustomBase;
  const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup; EventType: Word;
  Data: Pointer);
begin
  if (Initiator <> FDocument) then exit;
  if (EventGroup <> eegCustomBase) then exit;
  if (TEpiCustomChangeEventType(EventType) <> ecceDestroy) then exit;

  Self.Free;
end;

function TAuthenticator.GetAdmin: TEpiAdmin;
begin
  result := FDocument.Admin;
end;

function TAuthenticator.GetAuthedUser: TEpiUser;
begin
  result := nil;
  if (Self = nil) then exit;

  if Assigned(DocumentFile) then
    result := DocumentFile.AuthedUser;
end;

constructor TAuthenticator.Create(const ADocumentFile: TEpiDocumentFile);
begin
  FDocumentFile := ADocumentFile;
  FDocument     := FDocumentFile.Document;

  FDocument.RegisterOnChangeHook(@DocumentHook, true);
end;

destructor TAuthenticator.Destroy;
begin
  Authenticator := nil;
  FDocument.UnRegisterOnChangeHook(@DocumentHook);
  inherited Destroy;
end;

function TAuthenticator.AuthedUserEntryRights(const DataFile: TEpiDataFile
  ): TEpiEntryRights;
var
  G: TEpiGroup;
  GR: TEpiGroupRight;
begin
  if (not Assigned(AuthedUser)) then
  begin
    Result := EpiEntryRightsAll;
    Exit;
  end;

  if (not Assigned(DataFile)) then
  begin
    Result := [];
    Exit;
  end;

  Result := [];
  for G in AuthedUser.Groups do
    begin
      GR := DataFile.GroupRights.GroupRightFromGroup(G);
      if Assigned(GR) then
        Result := Result + GR.EntryRights
    end;
end;

function TAuthenticator.IsAuthorizedEntry(const DataFile: TEpiDataFile;
  const EntryRight: TEpiEntryRights): boolean;
begin
  result := AuthedUserEntryRights(DataFile) * EntryRight = EntryRight;
end;

function TAuthenticator.IsAuthorizedManager(
  const ManageRights: TEpiManagerRights): boolean;
begin
  Result := true;
  if not Assigned(AuthedUser) then exit;

  result := AuthedUser.Groups.HasRights(ManageRights);
end;

end.

