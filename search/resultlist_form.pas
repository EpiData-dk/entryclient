unit resultlist_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, types, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  epidatafiles, search;

type

  { TResultListForm }

  TResultListForm = class(TForm)
    ListGrid: TStringGrid;
procedure ListGridDblClick(Sender: TObject);
procedure ListGridHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
  private
    { private declarations }
    FDataFile: TEpiDataFile;
    FFieldList: TFpList;
    FSelectedRecordNo: integer;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent; Const DataFile: TEpiDataFile; Const FieldList: TFPList);
    procedure   ApplyList(Const Search: TSearch; Const List: TBoundArray);
    property    SelectedRecordNo: integer read FSelectedRecordNo;
  end; 

implementation

{$R *.lfm}

uses
  fieldedit;

{ TResultListForm }

procedure TResultListForm.ListGridHeaderClick(Sender: TObject;
  IsColumn: Boolean; Index: Integer);
begin
  // So far - no search
  if IsColumn then exit;
  if Index <= 0 then exit;

  FSelectedRecordNo := StrToInt(ListGrid.Cells[0, Index]) - 1;
  ModalResult := mrOk;
end;

procedure TResultListForm.ListGridDblClick(Sender: TObject);
var
  P: TPoint;
begin
  P := ListGrid.MouseToCell(ListGrid.ScreenToClient(Mouse.CursorPos));
  if P.Y <= 0 then exit;

  FSelectedRecordNo := StrToInt(ListGrid.Cells[0, P.Y]) - 1;
  ModalResult := mrOk;
end;

constructor TResultListForm.Create(TheOwner: TComponent;
  const DataFile: TEpiDataFile; const FieldList: TFPList);
begin
  inherited Create(TheOwner);
  FDataFile := DataFile;
  FFieldList := FieldList;
  FSelectedRecordNo := -1;
end;

procedure TResultListForm.ApplyList(const Search: TSearch;
  const List: TBoundArray);
var
  L: Integer;
  i: Integer;
  j: Integer;
begin
  L := Length(List);
  ListGrid.ColCount := FFieldList.Count + 1;
  ListGrid.RowCount := L + 1;

  ListGrid.Cells[0,0] := 'Record No:';
  for i := 0 to FFieldList.Count - 1 do
  with TFieldEdit(FFieldList[i]).Field do
    ListGrid.Cells[i+1, 0] := Name;

  for i := 0 to L - 1 do
  begin
    ListGrid.Cells[0, i + 1] := IntToStr(List[i] + 1);

    for j := 0 to FFieldList.Count - 1 do
    with TFieldEdit(FFieldList[j]).Field do
      ListGrid.Cells[j + 1, i + 1] := AsString[List[i]];
  end;
  ListGrid.AutoSizeColumns;
end;

end.

