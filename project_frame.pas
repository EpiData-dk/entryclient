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
    SaveProjectAsAction: TAction;
    SaveProjectAction: TAction;
    OpenProjectAction: TAction;
    ProjectActionList: TActionList;
    ProjectPanel: TPanel;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    OpenProjectToolButton: TToolButton;
    ProjectToolButtomDivider1: TToolButton;
    SaveProjectToolButton: TToolButton;
    SaveProjectAsToolButton: TToolButton;
    ProjectToolButtomDivider2: TToolButton;
    DataFilesTreeView: TTreeView;
    procedure OpenProjectActionExecute(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TFrame;
    FEpiDocument: TEpiDocument;
    procedure DoOpenProject(Const aFilename: string);
    procedure DoNewDataForm(DataFile: TEpiDataFile);
    function  DoCreateNewDocument: TEpiDocument;
  public
    { public declarations }
    property  EpiDocument: TEpiDocument read FEpiDocument;
    property  ActiveFrame: TFrame read FActiveFrame;
  end; 

implementation

{$R *.lfm}

uses
  dataform_frame;

{ TProjectFrame }

procedure TProjectFrame.OpenProjectActionExecute(Sender: TObject);
begin
  ProjectOpenDialog.InitialDir := GetCurrentDirUTF8; //ManagerSettings.WorkingDirUTF8;

{  {$IFNDEF EPI_DEBUG}
  if MessageDlg('Warning', 'Opening project will clear all.' + LineEnding +
       'Continue?',
       mtWarning, mbYesNo, 0, mbNo) = mrNo then exit;
  {$ENDIF}     }

  if not ProjectOpenDialog.Execute then exit;

  DoOpenProject(ProjectOpenDialog.FileName);
end;

procedure TProjectFrame.DoOpenProject(const aFilename: string);
var
  Frame: TDataFormFrame;
begin
  FEpiDocument.Free;

  // TODO : Delete ALL dataforms!
  FActiveFrame.Free;
  DataFilesTreeView.Items.Clear;

  FEpiDocument := DoCreateNewDocument;
  FEpiDocument.LoadFromFile(aFilename);
  DoNewDataForm(FEpiDocument.DataFiles[0]);
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

end.

