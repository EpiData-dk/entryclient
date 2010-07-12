unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, StdActns, ComCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    NewProjectAction: TAction;
    FileExitAction: TFileExit;
    MainActionList: TActionList;
    MainFormMenu: TMainMenu;
    FileMenu: TMenuItem;
    FileMenuDivider1: TMenuItem;
    ExitMenuItem: TMenuItem;
    MainFormPageControl: TPageControl;
    SaveProjectAsMenuItem: TMenuItem;
    SaveProjectMenuItem: TMenuItem;
    OpenProjectMenuItem: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure NewProjectActionExecute(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TFrame;
    TabNameCount: integer;
  public
    { public declarations }
    property  ActiveFrame: TFrame read FActiveFrame;
  end; 

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  project_frame;

{ TMainForm }

procedure TMainForm.NewProjectActionExecute(Sender: TObject);
var
  TabSheet: TTabSheet;
  Frame: TProjectFrame;
begin
  TabSheet := TTabSheet.Create(MainFormPageControl);
  TabSheet.PageControl := MainFormPageControl;
  TabSheet.Name := 'TabSheet' + IntToStr(TabNameCount);
  TabSheet.Caption := 'Untitled';

//  if PageControl1.PageCount >= 1 then
//    PageControl1.ShowTabs := true;

  Frame := TProjectFrame.Create(TabSheet);
  Frame.Name := 'ProjectFrame' + IntToStr(TabNameCount);
  Frame.Align := alClient;
  Frame.Parent := TabSheet;
//  Frame.OnModified := @ProjectModified;
//  Frame.NewDataFormAction.Execute;
  FActiveFrame := Frame;
  MainFormPageControl.ActivePage := TabSheet;

  // Only as long as one project is created!
  SaveProjectMenuItem.Action := Frame.SaveProjectAction;
  SaveProjectAsMenuItem.Action := Frame.SaveProjectAsAction;
  OpenProjectMenuItem.Action := Frame.OpenProjectAction;

  Inc(TabNameCount);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
//  SetCaption;
//  ShowWorkFlowAction.Execute;
  {$IFDEF EPI_RELEASE}
  Width := 800;
  Height := 600;
  {$ENDIF}

//  LoadIniFile;

  NewProjectAction.Execute;
end;

end.

