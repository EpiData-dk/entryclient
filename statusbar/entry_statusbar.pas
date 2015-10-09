unit entry_statusbar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, dataform_frame;

type

  { TEntryClientStatusBar }

  TEntryClientStatusBar = class(TEpiVCustomStatusBar)
  private
    FDataForm: TDataFormFrame;
    procedure SetDataForm(AValue: TDataFormFrame);
  public
    constructor Create(TheOwner: TComponent); override;
    procedure LoadSettings;
    property  DataForm: TDataFormFrame read FDataForm write SetDataForm;
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
  Update(sucCustom);

  Datafile := FDataForm.DataFile;
end;

constructor TEntryClientStatusBar.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
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

end.

