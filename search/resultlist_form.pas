unit resultlist_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epidatafiles;

procedure ShowResultListForm(
  Const AOwner: TComponent;
  Const ACaption: String;
  Const ADataFile: TEpiDataFile;
  Const AFieldList: TEpiFields;
  Const ARecordList: TBoundArray = nil;
  Const AReverseIndex: TEpiField = nil;
  Const AForwardIndex: TEpiField = nil
  );

procedure ResultListFormDefaultPosition();
function  ResultListFormIsShowing: boolean;

implementation

uses
  Forms, Controls, LCLType, main, LCLIntf, entry_messages,
  {$IFDEF DARWIN}
  epiv_dataset_viewer_frame_mac,
  {$ELSE}
  epiv_dataset_viewer_frame,
  {$ENDIF}
  settings;

type
  { TResultListForm }

  TResultListForm = class(TForm)
  private
    { private declarations }
    FViewerFrame: TCustomFrame;
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CloseQueryResultListForm(Sender: TObject; var CanClose: boolean);
    procedure ShowResultListForm(Sender: TObject);
    procedure SelectRecord(Sender: TObject; RecordNo: Integer;
      const Field: TEpiField);
  public
    { public declarations }
    constructor Create(TheOwner: TComponent; Const DataFile: TEpiDataFile);
    destructor Destroy; override;
  end;

var
  FResultListForm: TResultListForm = nil;
  FDisplayFields: TEpiFields = nil;

{ TResultListForm }

procedure TResultListForm.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Key = VK_ESCAPE) and (Shift = [])) or
     {$IFDEF MSWINDOWS}
     ((Key = VK_F4)  and (Shift = [ssAlt]))
     {$ENDIF}
     {$IFDEF LINUX}
     ((Key = VK_W)  and (Shift = [ssCtrl]))
     {$ENDIF}
     {$IFDEF DARWIN}
     ((Key = VK_W)  and (Shift = [ssMeta]))
     {$ENDIF}
  then
  begin
    Key := VK_UNKNOWN;
    Self.Close;
  end;
end;

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
  OnKeyDown := @KeyDown;
  KeyPreview := true;
  Position := poDesktopCenter;

  FViewerFrame := TDatasetViewerFrame.Create(self, DataFile);
  with TDatasetViewerFrame(FViewerFrame) do
  begin
    Align := alClient;
    OnSelectRecord := @SelectRecord;
    Parent := Self;
  end;
end;

destructor TResultListForm.Destroy;
begin
  FResultListForm := nil;
  inherited Destroy;
end;

procedure ShowResultListForm(const AOwner: TComponent; const ACaption: String;
  const ADataFile: TEpiDataFile; const AFieldList: TEpiFields;
  const ARecordList: TBoundArray; const AReverseIndex: TEpiField;
  const AForwardIndex: TEpiField);
var
  S: String;
begin
  if not Assigned(FResultListForm) then
    FResultListForm := TResultListForm.Create(AOwner, ADataFile);

  with TDatasetViewerFrame(FResultListForm.FViewerFrame) do
  begin
    BeginUpdate;
    Datafile := ADataFile;
    DisplayFields := AFieldList;
    ShowRecords(ARecordList);
    ReverseIndex := AReverseIndex;
    ForwardIndex := AForwardIndex;
    {$IFDEF DARWIN}
    ListGridHeaderClick(Nil, True, 0);
    {$ENDIF}

    EndUpdate;
  end;

  S := IntToStr(ADataFile.Size);
  if Length(ARecordList) > 0 then
    S := IntToStr(Length(ARecordList));

  FResultListForm.Caption := ACaption + ' (' + S + ')';
  FResultListForm.Show;
end;

procedure ResultListFormDefaultPosition();
var
  F: TForm;
begin
  if Assigned(FResultListForm) then
    F := FResultListForm
  else
    F := TForm.Create(nil);

  with F do
  begin
    LockRealizeBounds;
    Width := 600;
    Height := 400;
    Top := (Monitor.Height div 2) - (Height div 2);
    Left := (Monitor.Width div 2) - (Width div 2);
    UnlockRealizeBounds;
    SaveFormPosition(F, 'ResultListForm');
  end;

  if F <> FResultListForm then
    F.Free;
end;

function ResultListFormIsShowing: boolean;
begin
  result := Assigned(FResultListForm) and (FResultListForm.Showing);
end;

end.

