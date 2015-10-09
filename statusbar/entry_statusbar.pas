unit entry_statusbar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, dataform_frame, contnrs;

type

  TEntryClientStatusbarUpdateCondition = (
    esucDataform              // Assigned the dataform
  );

  { TEntryClientStatusBar }

  TEntryClientStatusBar = class(TEpiVCustomStatusBar)
  private
    FEntryClientStatubarItems: TObjectList;
    FDataForm: TDataFormFrame;
    procedure SetDataForm(AValue: TDataFormFrame);
    procedure DoUpdateItems(Condition: TEntryClientStatusbarUpdateCondition);
  protected
    procedure AddItem(StatusBarItem: TEpiVCustomStatusBarItem); override;
    procedure Clear; override;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure LoadSettings;
    procedure Update(Condition: TEntryClientStatusbarUpdateCondition); overload;
    property  DataForm: TDataFormFrame read FDataForm write SetDataForm;
  end;

  { TEntryClientStatusBarItem }

  TEntryClientStatusBarItem = class(TEpiVCustomStatusBarItem)
  private
    function  GetStatusbar: TEntryClientStatusBar;
  protected
    procedure  Update(Condition: TEntryClientStatusbarUpdateCondition); virtual; overload;
    property  Statusbar: TEntryClientStatusBar read GetStatusbar;
  end;


implementation

uses
  entry_statusbaritem_navigator,
  epiv_statusbar_item_recordcount, epiv_statusbar_item_cycleno,
  epiv_statusbar_item_currentuser, epiv_statusbar_item_savetime,
  epiv_statusbar_item_selectionnames;

{ TEntryClientStatusBar }

procedure TEntryClientStatusBar.SetDataForm(AValue: TDataFormFrame);
begin
  if FDataForm = AValue then Exit;
  FDataForm := AValue;
  Update(esucDataform);

  Datafile := FDataForm.DataFile;
end;

procedure TEntryClientStatusBar.DoUpdateItems(
  Condition: TEntryClientStatusbarUpdateCondition);
var
  I: Integer;
begin
  for I := 0 to FEntryClientStatubarItems.Count -1 do
    TEntryClientStatusBarItem(FEntryClientStatubarItems[i]).Update(Condition);
end;

procedure TEntryClientStatusBar.AddItem(StatusBarItem: TEpiVCustomStatusBarItem
  );
begin
  inherited AddItem(StatusBarItem);

  if StatusBarItem.InheritsFrom(TEntryClientStatusBarItem) then
    FEntryClientStatubarItems.Add(StatusBarItem);
end;

procedure TEntryClientStatusBar.Clear;
begin
  inherited Clear;
  FEntryClientStatubarItems.Clear;
end;

constructor TEntryClientStatusBar.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FEntryClientStatubarItems := TObjectList.create(false);
end;

procedure TEntryClientStatusBar.LoadSettings;
var
  L: TList;
  i: Integer;
begin
  L := EpiV_GetCustomStatusBarItems;
  if Assigned(L) then
    for i := 0 to L.Count - 1 do
      AddItem(TEpiVCustomStatusBarItemClass(L[i]).Create(Self));
end;

procedure TEntryClientStatusBar.Update(
  Condition: TEntryClientStatusbarUpdateCondition);
begin
  DoUpdateItems(Condition);
  Resize;
end;

{ TEntryClientStatusBarItem }

function TEntryClientStatusBarItem.GetStatusbar: TEntryClientStatusBar;
begin
  result := TEntryClientStatusBar(Inherited Statusbar);
end;

procedure TEntryClientStatusBarItem.Update(
  Condition: TEntryClientStatusbarUpdateCondition);
begin
  //
end;

end.

