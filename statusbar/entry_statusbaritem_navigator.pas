unit entry_statusbaritem_navigator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, Buttons, StdCtrls, entry_statusbar;

type

  { TEntryClientStatusBarNavigator }

  TEntryClientStatusBarNavigator = class(TEpiVCustomStatusBarItem)
  private
    FFirstBtn: TSpeedButton;
    FPrevBtn: TSpeedButton;
    FRecordStatus: TEdit;
    FNextBtn: TSpeedButton;
    FLastBtn: TSpeedButton;
    function  GetStatusbar: TEntryClientStatusBar;
    procedure UpdateSpeedBtns;
    procedure RecordStatusEditDone(Sender: TObject);
    procedure UpdateRecordEdit;
  protected
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
    property  Statusbar: TEntryClientStatusBar read GetStatusbar;
  public
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    function GetPreferedWidth: Integer; override;
  end;


implementation

uses
  Graphics, Controls;

{ TEntryClientStatusBarNavigator }

procedure TEntryClientStatusBarNavigator.UpdateSpeedBtns;
begin
  Statusbar.DataForm.ImageList1.GetBitmap(0, FFirstBtn.Glyph);
  Statusbar.DataForm.ImageList1.GetBitmap(1, FLastBtn.Glyph);
  Statusbar.DataForm.ImageList1.GetBitmap(2, FNextBtn.Glyph);
  Statusbar.DataForm.ImageList1.GetBitmap(3, FPrevBtn.Glyph);

  FFirstBtn.Action := Statusbar.DataForm.FirstRecAction;
  FPrevBtn.Action  := Statusbar.DataForm.PrevRecAction;
  FNextBtn.Action  := Statusbar.DataForm.NextRecAction;
  FLastBtn.Action  := Statusbar.DataForm.LastRecAction;
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

  Statusbar.DataForm.RecNo := (AValue - 1);
  Statusbar.DataForm.FirstFieldAction.Execute;
end;

procedure TEntryClientStatusBarNavigator.UpdateRecordEdit;
begin

end;

function TEntryClientStatusBarNavigator.GetStatusbar: TEntryClientStatusBar;
begin
  result := TEntryClientStatusBar(Inherited Statusbar);
end;

procedure TEntryClientStatusBarNavigator.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    sucDefault: ;
    sucCustom: UpdateSpeedBtns;
    sucDocFile: ;
    sucDataFile: ;
    sucSelection: ;
    sucSave: ;
  end;
end;

constructor TEntryClientStatusBarNavigator.Create(AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);

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
    Height := 22;
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

