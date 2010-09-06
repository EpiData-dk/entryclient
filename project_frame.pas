unit project_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  Dialogs, epidocument, epidatafiles;

type

  { TProjectFrame }

  TProjectFrame = class(TFrame)
    ProjectOpenDialog: TOpenDialog;
    ProjectImageList: TImageList;
    SaveProjectAction: TAction;
    OpenProjectAction: TAction;
    ProjectActionList: TActionList;
    ProjectPanel: TPanel;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    OpenProjectToolButton: TToolButton;
    ProjectToolButtomDivider1: TToolButton;
    SaveProjectToolButton: TToolButton;
    ProjectToolButtomDivider2: TToolButton;
    DataFilesTreeView: TTreeView;
    procedure OpenProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionExecute(Sender: TObject);
    procedure SaveProjectActionUpdate(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TFrame;
    FEpiDocument: TEpiDocument;
    FDocumentFilename: string;
    procedure DoOpenProject(Const aFilename: string);
    procedure DoSaveProject(Const aFilename: string);
    procedure DoNewDataForm(DataFile: TEpiDataFile);
    function  DoCreateNewDocument: TEpiDocument;
    procedure EpiDocModified(Sendet: TObject);
    procedure UpdateMainCaption;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    property  EpiDocument: TEpiDocument read FEpiDocument;
    property  ActiveFrame: TFrame read FActiveFrame;
  end; 

implementation

{$R *.lfm}

uses
  main, dataform_frame, epimiscutils, settings, fieldedit;

{ TProjectFrame }

procedure TProjectFrame.OpenProjectActionExecute(Sender: TObject);
var
  Res: LongInt;
  List: TFPList;
  i: Integer;
begin
  ProjectOpenDialog.InitialDir := EntrySettings.WorkingDirUTF8;
  ProjectOpenDialog.Filter := GetEpiDialogFilter(true, false, false, false,
    false, false, false, false, false, true);
  if not ProjectOpenDialog.Execute then exit;

  if (Assigned(EpiDocument)) and
     ((EpiDocument.Modified) or
      (TDataFormFrame(ActiveFrame).Modified))
  then begin
    Res := MessageDlg('Warning',
      'Project data content modified.' + LineEnding +
      'Save?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrCancel then exit;

    if Res = mrYes then
    begin
      // Commit field (in case they are not already).
      List := TDataFormFrame(ActiveFrame).FieldEditList;
      for i := 0 to List.Count - 1 do
        TFieldEdit(List[i]).Commit;

      SaveProjectAction.Execute;
    end;
  end;

  DoOpenProject(ProjectOpenDialog.FileName);
end;

procedure TProjectFrame.SaveProjectActionExecute(Sender: TObject);
begin
  DoSaveProject(FDocumentFilename);
end;

procedure TProjectFrame.SaveProjectActionUpdate(Sender: TObject);
begin
  SaveProjectAction.Enabled := Assigned(FEpiDocument);
end;

procedure TProjectFrame.DoOpenProject(const aFilename: string);
begin
  FreeAndNil(FEpiDocument);

  // TODO : Delete ALL dataforms!
  FreeAndNil(FActiveFrame);
  DataFilesTreeView.Items.Clear;

  FEpiDocument := DoCreateNewDocument;
  FEpiDocument.LoadFromFile(aFilename);
  FDocumentFilename := aFilename;

  DoNewDataForm(FEpiDocument.DataFiles[0]);
  UpdateMainCaption;
end;

procedure TProjectFrame.DoSaveProject(const aFilename: string);
var
  Ss: TStringStream;
  Fs: TFileStream;
begin
  Ss := TStringStream.Create(EpiDocument.SaveToXml());
  Fs := TFileStream.Create(aFilename, fmCreate);
  Fs.CopyFrom(Ss, Ss.Size);
  Ss.Free;
  Fs.Free;

  UpdateMainCaption;
end;

procedure TProjectFrame.DoNewDataForm(DataFile: TEpiDataFile);
var
  Frame: TDataFormFrame;
begin
  Frame := TDataFormFrame.Create(Self);
  Frame.Align := alClient;
  Frame.Parent := Self;
  Frame.DataFile := DataFile;
  FActiveFrame := Frame;

  DataFilesTreeView.Selected := DataFilesTreeView.Items.AddObject(nil, DataFile.Name.Text, Frame);
//  TEpiDataFileEx(Df).TreeNode := DataFilesTreeView.Selected;
//  Df.Name.RegisterOnChangeHook(@OnDataFileChange);

  // TODO : Adapt to multiple datafiles.
  With MainForm do
  begin
    GotoRecordMenuItem.Action  := Frame.GotoRecordAction;
    // -
    FirstRecordMenuItem.Action := Frame.FirstRecAction;
    PrevRecordMenuItem.Action  := Frame.PrevRecAction;
    NextRecordMenuItem.Action  := Frame.NextRecAction;
    LastRecordMenuItem.Action  := Frame.LastRecAction;
    // -
    NewRecordMenuItem.Action   := Frame.NewRecordAction;
    BrowseMenu.Visible := true;
  end;
end;

function TProjectFrame.DoCreateNewDocument: TEpiDocument;
begin
  Result := TEpiDocument.Create('en');
  Result.OnModified := @EpiDocModified;
end;

procedure TProjectFrame.EpiDocModified(Sendet: TObject);
var
  EpiDoc: TEpiDocument;
begin
  UpdateMainCaption;
end;

procedure TProjectFrame.UpdateMainCaption;
var
  S: String;
begin
  S := 'EpiData Entry';

  if Assigned(EpiDocument) then
  begin
    S := S + ': ' + SysToUTF8(ExtractFileName(UTF8ToSys(FDocumentFilename)));
    if EpiDocument.Modified then
     S := S + '*';
    if Assigned(ActiveFrame) then
      S := S + ' (' + TDataFormFrame(ActiveFrame).DataFile.Name.Text + ')';
  end;
  MainForm.Caption := S;
end;

constructor TProjectFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FEpiDocument := nil;
  FActiveFrame := nil;

  {$IFDEF EPI_RELEASE}
    ProjectPanel.Enabled := false;
    ProjectPanel.Visible := false;
    Splitter1.Enabled    := false;
    Splitter1.Visible    := false;
  {$ENDIF}
end;

end.

