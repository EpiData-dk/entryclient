unit resultlist_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epidatafiles;

procedure ShowResultListForm(Const Caption: String;
  Const DataFile: TEpiDataFile;
  Const FieldList: TEpiFields;
  Const RecordList: TBoundArray = nil);

implementation

uses
  Forms, Controls, LCLType, main, LCLIntf, entry_messages,
  epiv_dataset_viewer_frame, settings;

type
  { TResultListForm }

  TResultListForm = class(TForm)
  private
    { private declarations }
    FViewerFrame: TCustomFrame;
    procedure CloseQueryResultListForm(Sender: TObject; var CanClose: boolean);
    procedure ShowResultListForm(Sender: TObject);
    procedure SelectRecord(Sender: TObject; RecordNo: Integer;
      const Field: TEpiField);
  public
    { public declarations }
    constructor Create(TheOwner: TComponent; Const DataFile: TEpiDataFile);
  end;

var
  FResultListForm: TResultListForm = nil;
  FDisplayFields: TEpiFields = nil;

{ TResultListForm }

procedure TResultListForm.CloseQueryResultListForm(Sender: TObject;
  var CanClose: boolean);
begin
  if CanClose then
    SaveFormPosition(Self, 'ResultListForm');
end;

procedure TResultListForm.ShowResultListForm(Sender: TObject);
begin
  LoadFormPosition(Self, 'ResultListForm');
end;

procedure TResultListForm.SelectRecord(Sender: TObject; RecordNo: Integer;
  const Field: TEpiField);
begin
  SendMessage(MainForm.Handle, LM_DATAFORM_GOTOREC, WPARAM(RecordNo), LPARAM(Field));
end;

constructor TResultListForm.Create(TheOwner: TComponent;
  const DataFile: TEpiDataFile);
begin
  inherited CreateNew(TheOwner);
  OnShow := @ShowResultListForm;
  OnCloseQuery := @CloseQueryResultListForm;

  FViewerFrame := TDatasetViewerFrame.Create(self, DataFile);
  with TDatasetViewerFrame(FViewerFrame) do
  begin
    Align := alClient;
    OnSelectRecord := @SelectRecord;
    Parent := Self;
  end;
end;

procedure ShowResultListForm(const Caption: String;
  const DataFile: TEpiDataFile; const FieldList: TEpiFields;
  const RecordList: TBoundArray);
begin
  if not Assigned(FResultListForm) then
    FResultListForm := TResultListForm.Create(nil, DataFile);
  with TDatasetViewerFrame(FResultListForm.FViewerFrame) do
  begin
    DisplayFields := FieldList;
    ShowRecords(RecordList);
    ListGridHeaderClick(Nil, True, 0);
  end;
  FResultListForm.Caption := Caption + ' (' + IntToStr(Length(RecordList)) + ')';
  FResultListForm.Show;
end;

end.

