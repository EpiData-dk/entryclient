unit entry_statusbaritem_navigator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, Buttons, StdCtrls, entry_statusbar,
  LMessages;

type

  { TEntryClientStatusBarNavigator }

  TEntryClientStatusBarNavigator = class(TEntryClientStatusBarItem)
  private
    FFirstBtn: TSpeedButton;
    FPrevBtn: TSpeedButton;
    FRecordStatus: TEdit;
    FNextBtn: TSpeedButton;
    FLastBtn: TSpeedButton;
    FSpeedBtnBitmapInit: boolean;
    procedure UpdateSpeedBtns;
    procedure RecordStatusEditDone(Sender: TObject);
    procedure UpdateRecordEdit;
  protected
    procedure Update(Condition: TEntryClientStatusbarUpdateCondition); override;
    procedure IsShortCut(var Msg: TLMKey; var Handled: Boolean); override;
  public
    class function Caption: string; override;
    class function Name: string; override;
  public
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    function GetPreferedWidth: Integer; override;
  end;


implementation

{$ *.rc}

uses
  Graphics, Controls, dataform_frame, LCLType, LCLIntf, epiv_datamodule;

{ TEntryClientStatusBarNavigator }

procedure TEntryClientStatusBarNavigator.UpdateSpeedBtns;
begin
  if Assigned(DataForm) then
    begin
      FFirstBtn.Action := DataForm.FirstRecAction;
      FPrevBtn.Action  := DataForm.PrevRecAction;
      FNextBtn.Action  := DataForm.NextRecAction;
      FLastBtn.Action  := DataForm.LastRecAction;
    end;

  if FSpeedBtnBitmapInit then exit;
  DM.Icons16.GetBitmap(46, FNextBtn.Glyph);
  DM.Icons16.GetBitmap(47, FPrevBtn.Glyph);
  DM.Icons16.GetBitmap(48, FLastBtn.Glyph);
  DM.Icons16.GetBitmap(49, FFirstBtn.Glyph);
  FSpeedBtnBitmapInit := true;
end;

procedure TEntryClientStatusBarNavigator.RecordStatusEditDone(Sender: TObject);
var
  AValue, Code: integer;
begin
  Val(FRecordStatus.Text, AValue, Code);
  if Code <> 0 then
    begin
      UpdateRecordEdit;
      Exit;
    end;

  DataForm.RecNo := (AValue - 1);
  DataForm.FirstFieldAction.Execute;
end;

procedure TEntryClientStatusBarNavigator.UpdateRecordEdit;
var
  IndexSize, RecNo: Integer;
  S: String;
begin
  if (not Assigned(DataForm)) then
    Exit;

  IndexSize := DataForm.IndexedSize;
  if IndexSize = 0 then
  begin
    FRecordStatus.Text := 'Empty';
    Exit;
  end;

  if DataForm.Modified then
    S := '*'
  else
    S := '';

  RecNo := DataForm.RecNo;

  if RecNo = NewRecord then
    S := Format('New / %d %s', [IndexSize, S])
  else
    S := Format('%d / %d %s', [RecNo + 1, IndexSize, S]);

  FRecordStatus.Text := Trim(S);
end;

procedure TEntryClientStatusBarNavigator.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    sucDefault:
      UpdateRecordEdit;
    sucDocFile: ;
    sucDataFile:
      UpdateRecordEdit;
    sucSelection: ;
    sucSave: ;
    sucExample:
      begin
        UpdateSpeedBtns;
        FRecordStatus.OnEditingDone := nil;
      end;
  end;
end;

procedure TEntryClientStatusBarNavigator.Update(
  Condition: TEntryClientStatusbarUpdateCondition);
begin
  case Condition of
    esucDataform:
      begin
        UpdateSpeedBtns;
        UpdateRecordEdit;
      end;
  end;
end;

procedure TEntryClientStatusBarNavigator.IsShortCut(var Msg: TLMKey;
  var Handled: Boolean);
begin
  with Msg do
  begin
    if (CharCode = VK_G) and
       (MsgKeyDataToShiftState(KeyData) = [ssCtrl]) and
       FRecordStatus.CanFocus
    then
    begin
      FRecordStatus.SetFocus;
      Handled := true;
    end;
  end;
end;

class function TEntryClientStatusBarNavigator.Caption: string;
begin
  Result := 'Observations Navigation';
end;

class function TEntryClientStatusBarNavigator.Name: string;
begin
  result := 'Navigator';
end;

constructor TEntryClientStatusBarNavigator.Create(AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);

  FSpeedBtnBitmapInit := false;
  Panel.Color := clDefault;

  FFirstBtn := TSpeedButton.Create(Panel);
  with FFirstBtn do
  begin
    Parent := Panel;
    AnchorParallel(akLeft, 1, Panel);
    AnchorVerticalCenterTo(Panel);
    Width := 22;
    Height := 22;
    ShowCaption := false;
  end;

  FPrevBtn := TSpeedButton.Create(Panel);
  with FPrevBtn do
  begin
    Parent := Panel;
    AnchorToNeighbour(akLeft, 1, FFirstBtn);
    AnchorVerticalCenterTo(Panel);
    Width := 22;
    Height := 22;
    ShowCaption := false;
  end;

  FRecordStatus := TEdit.Create(Panel);
  with FRecordStatus do
  begin
    Parent := Panel;
    AnchorToNeighbour(akLeft, 1, FPrevBtn);
    AnchorVerticalCenterTo(Panel);
    Width := 120;
    Height := 20;
    Alignment := taCenter;
    Font.Size := 10;
    OnEditingDone := @RecordStatusEditDone;
  end;

  FNextBtn := TSpeedButton.Create(Panel);
  with FNextBtn do
  begin
    Parent := Panel;
    AnchorToNeighbour(akLeft, 1, FRecordStatus);
    AnchorVerticalCenterTo(Panel);
    Width := 22;
    Height := 22;
    ShowCaption := false;
  end;

  FLastBtn := TSpeedButton.Create(Panel);
  with FLastBtn do
  begin
    Parent := Panel;
    AnchorToNeighbour(akLeft, 1, FNextBtn);
    AnchorVerticalCenterTo(Panel);
    Width := 22;
    Height := 22;
    ShowCaption := false;
  end;
end;

function TEntryClientStatusBarNavigator.GetPreferedWidth: Integer;
begin
  if not Panel.HandleAllocated then
    begin
      Result := inherited GetPreferedWidth;
      Exit;
    end;

  Result := FLastBtn.Left + FLastBtn.Width + 1;
end;

initialization
  EpiV_RegisterCustomStatusBarItem(TEntryClientStatusBarNavigator);

end.

