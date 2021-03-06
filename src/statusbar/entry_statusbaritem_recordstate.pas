unit entry_statusbaritem_recordstate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, entry_statusbar, ugradbtn,
  epidatafilestypes, epicustombase, epidatafiles;

type

  { TEntryClientStatusBarRecordState }

  TEntryClientStatusBarRecordState = class(TEntryClientStatusBarItem)
  private
    FDeletedBtn:  TGradButton;
    FVerifiedBtn: TGradButton;
    FGCPBtn:      TGradButton;
    FLocalState:  TEpiRecordState;
    procedure DoLocalState;
    procedure DoUpdate;
    procedure DoDatafileUpdate;
  private
    FDataFile: TEpiDataFile;
    procedure RecordStataChangeHook(const Sender: TEpiCustomBase;
      const Initiator: TEpiCustomBase; EventGroup: TEpiEventGroup;
      EventType: Word; Data: Pointer);
  public
    class function Caption: string; override;
    class function Name: string; override;
  public
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
    procedure Update(Condition: TEntryClientStatusbarUpdateCondition); overload; override;
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    destructor Destroy; override;
    function GetPreferedWidth: Integer; override;
  end;

implementation

uses
  Controls, Graphics, dataform_frame, admin_authenticator, epirights;

{ TEntryClientStatusBarRecordState }

procedure TEntryClientStatusBarRecordState.DoLocalState;
begin
  FLocalState := rsNormal;

  if (not assigned(Dataform)) then Exit;
  if (Dataform.IndexedRecNo = NewRecord) then exit;

  if Dataform.DataFile.Verified[Dataform.IndexedRecNo] then
    FLocalState := rsVerified;

  if Dataform.DataFile.Deleted[Dataform.IndexedRecNo] then
    FLocalState := rsDeleted;
end;

procedure TEntryClientStatusBarRecordState.DoUpdate;
begin
  if (not Assigned(Dataform)) then exit;

  with FDeletedBtn do
    if (Dataform.IndexedRecNo <> NewRecord) and
       (Dataform.DataFile.Deleted[Dataform.IndexedRecNo])
    then
      begin
        Font.Color     := clBlack;
        BaseColor      := clRed;
        OverBlendColor := clSilver;
        ClickColor     := BaseColor;
        DisabledColor  := BaseColor;
      end
    else
      begin
        Font.Color     := clRed;
        BaseColor      := clBtnFace;
        OverBlendColor := clRed;
        ClickColor     := BaseColor;
        DisabledColor  := BaseColor;
      end;


  with FVerifiedBtn do
    if (Dataform.IndexedRecNo <> NewRecord) and
       (Dataform.DataFile.Verified[Dataform.IndexedRecNo])
    then
      begin
        Font.Color     := clBlack;
        BaseColor      := clGreen;
        OverBlendColor := clSilver;
        ClickColor     := BaseColor;
        DisabledColor  := BaseColor;
      end
    else
      begin
        Font.Color     := clGreen;
        BaseColor      := clBtnFace;
        OverBlendColor := clGreen;
        ClickColor     := BaseColor;
        DisabledColor  := BaseColor;
      end;
end;

procedure TEntryClientStatusBarRecordState.DoDatafileUpdate;
begin
  FDeletedBtn.Action := Dataform.DeleteRecordAction;
  FDeletedBtn.Caption := 'DEL';

  FVerifiedBtn.Action := Dataform.VerifiyRecordAction;
  FVerifiedBtn.Caption := 'VER';

  if Assigned(FDataFile) then
    FDataFile.UnRegisterOnChangeHook(@RecordStataChangeHook);

  FDataFile := Statusbar.Datafile;

  if Assigned(FDataFile) then
    FDataFile.RegisterOnChangeHook(@RecordStataChangeHook, true);
end;

procedure TEntryClientStatusBarRecordState.RecordStataChangeHook(
  const Sender: TEpiCustomBase; const Initiator: TEpiCustomBase;
  EventGroup: TEpiEventGroup; EventType: Word; Data: Pointer);
begin
  if (Initiator <> FDataFile) then Exit;

  if (EventGroup = eegCustomBase) and
     (TEpiCustomChangeEventType(EventType) = ecceDestroy)
  then
    begin
      FDataFile.UnRegisterOnChangeHook(@RecordStataChangeHook);
      FDataFile := nil;
      Exit;
    end;

  if (EventGroup <> eegDataFiles) then exit;
  if (TEpiDataFileChangeEventType(EventType) <> edceRecordStatus) then exit;

  DoUpdate;
end;

class function TEntryClientStatusBarRecordState.Caption: string;
begin
  Result := 'Record State';
end;

class function TEntryClientStatusBarRecordState.Name: string;
begin
  result := 'recordstate';
end;

procedure TEntryClientStatusBarRecordState.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    sucDefault:
      begin
        DoLocalState;
        DoUpdate;
      end;
    sucDocFile: ;
    sucDataFile:
      DoDatafileUpdate;
    sucSelection: ;
    sucSave: ;
    sucExample:
      FDeletedBtn.Action := nil;
  end;
end;

procedure TEntryClientStatusBarRecordState.Update(
  Condition: TEntryClientStatusbarUpdateCondition);
begin
  DoLocalState;
  DoUpdate;
end;

constructor TEntryClientStatusBarRecordState.Create(
  AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);

  FDeletedBtn := TGradButton.Create(AStatusBar);
  with FDeletedBtn do
  begin
    AnchorParallel(akLeft, 0, Panel);
    AnchorParallel(akTop, 0, Panel);
    AnchorParallel(akBottom, 0, Panel);
    AutoWidthBorderSpacing := 10;
    AutoWidth := true;
    Caption := 'DEL';
    Parent := Panel;
    OverBlend := 0.5;
    NormalBlend := 0.5;

    Font.Color     := clRed;
    BaseColor      := clBtnFace;
    OverBlendColor := clRed;
    ClickColor     := BaseColor;
  end;

  FVerifiedBtn := TGradButton.Create(AStatusBar);
  with FVerifiedBtn do
  begin
    AnchorToNeighbour(akLeft, 0, FDeletedBtn);
    AnchorParallel(akTop, 0, Panel);
    AnchorParallel(akBottom, 0, Panel);
    AutoWidth := true;
    AutoWidthBorderSpacing := 8;
    Caption := 'VER';
    Parent := Panel;
    OverBlend := 0.5;
    NormalBlend := 0.5;

    Font.Color     := clGreen;
    BaseColor      := clBtnFace;
    OverBlendColor := clGreen;
    ClickColor     := BaseColor;
  end;
end;

destructor TEntryClientStatusBarRecordState.Destroy;
begin
  if Assigned(FDataFile)
  then
    begin
      FDataFile.UnRegisterOnChangeHook(@RecordStataChangeHook);
      FDataFile := nil;
    end;

  inherited Destroy;
end;

function TEntryClientStatusBarRecordState.GetPreferedWidth: Integer;
begin
  if not Panel.HandleAllocated then
    begin
      Result := inherited GetPreferedWidth;
      Exit;
    end;

  Result := FVerifiedBtn.Left + FVerifiedBtn.Width + 1;
end;

initialization
  EpiV_RegisterCustomStatusBarItem(TEntryClientStatusBarRecordState);

end.

