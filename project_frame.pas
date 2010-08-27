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
    ProjectSaveDialog: TSaveDialog;
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
  private
    { private declarations }
    FActiveFrame: TFrame;
    FEpiDocument: TEpiDocument;
    FDocumentFilename: string;
    procedure DoOpenProject(Const aFilename: string);
    procedure DoSaveProject(Const aFilename: string);
    procedure DoNewDataForm(DataFile: TEpiDataFile);
    function  DoCreateNewDocument: TEpiDocument;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    property  EpiDocument: TEpiDocument read FEpiDocument;
    property  ActiveFrame: TFrame read FActiveFrame;
  end; 

implementation

{$R *.lfm}

uses
  dataform_frame, epimiscutils;

{ TProjectFrame }

procedure TProjectFrame.OpenProjectActionExecute(Sender: TObject);
begin
  ProjectOpenDialog.InitialDir := GetCurrentDirUTF8; //ManagerSettings.WorkingDirUTF8;
  ProjectOpenDialog.Filter := GetEpiDialogFilter(true, false, false, false,
    false, false, false, false, false, true);

{  {$IFNDEF EPI_DEBUG}
  if MessageDlg('Warning', 'Opening project will clear all.' + LineEnding +
       'Continue?',
       mtWarning, mbYesNo, 0, mbNo) = mrNo then exit;
  {$ENDIF}     }

  if not ProjectOpenDialog.Execute then exit;

  DoOpenProject(ProjectOpenDialog.FileName);
end;

procedure TProjectFrame.SaveProjectActionExecute(Sender: TObject);
begin
  DoSaveProject(FDocumentFilename);
end;

procedure TProjectFrame.DoOpenProject(const aFilename: string);
begin
  FEpiDocument.Free;

  // TODO : Delete ALL dataforms!
  FActiveFrame.Free;
  DataFilesTreeView.Items.Clear;

  FEpiDocument := DoCreateNewDocument;
  FEpiDocument.LoadFromFile(aFilename);
  FDocumentFilename := aFilename;
  DoNewDataForm(FEpiDocument.DataFiles[0]);
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
end;

function TProjectFrame.DoCreateNewDocument: TEpiDocument;
begin
  Result := TEpiDocument.Create('en');
//  Result.DataFiles.OnNewItemClass := @NewDataFileItem;
//  Result.OnModified := @EpiDocumentModified;
end;

constructor TProjectFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  {$IFDEF EPI_RELEASE}
    ProjectPanel.Enabled := false;
    ProjectPanel.Visible := false;
    Splitter1.Enabled    := false;
    Splitter1.Visible    := false;
  {$ENDIF}
end;

end.

