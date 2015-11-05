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
    function  GetDataform: TDataFormFrame;
  protected
    procedure  Update(Condition: TEntryClientStatusbarUpdateCondition); virtual; overload;
    property  Statusbar: TEntryClientStatusBar read GetStatusbar;
    property  Dataform: TDataFormFrame read GetDataform;
  end;


implementation

uses
  settings,
  entry_statusbaritem_navigator,
  entry_statusbaritem_keyvalues, entry_statusbaritem_datafilecontent,
  epiv_statusbar_item_recordcount, epiv_statusbar_item_cycleno,
  epiv_statusbar_item_currentuser, {epiv_statusbar_item_savetime,}
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
  L: TStrings;
  S: String;
  Idx: Integer;
begin
  Clear;

  L := TStringList.Create;
  L.StrictDelimiter := true;
  L.CommaText := EntrySettings.StatusBarItemNames;

  for S in L do
  begin
    Idx := EpiV_GetCustomStatusBarItems.IndexOf(S);
    if (Idx < 0) then continue;

    AddItem(TEpiVCustomStatusBarItemClass(EpiV_GetCustomStatusBarItems.Objects[Idx]).Create(Self));
  end;
  Resize;
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

function TEntryClientStatusBarItem.GetDataform: TDataFormFrame;
begin
  result := Statusbar.DataForm;
end;

procedure TEntryClientStatusBarItem.Update(
  Condition: TEntryClientStatusbarUpdateCondition);
begin
  //
end;

end.

