unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epidocument, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, ActnList, StdActns, ComCtrls, LCLType, StdCtrls, ExtCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    SettingsAction: TAction;
    FirstRecordMenuItem: TMenuItem;
    LastRecordMenuItem: TMenuItem;
    EditMenu: TMenuItem;
    SettingsMenuItem: TMenuItem;
    RecordMenuDivider2: TMenuItem;
    RecordMenuDivider1: TMenuItem;
    PrevRecordMenuItem: TMenuItem;
    NextRecordMenuItem: TMenuItem;
    BrowseMenu: TMenuItem;
    GotoRecordMenuItem: TMenuItem;
    NewRecordMenuItem: TMenuItem;
    NewProjectAction: TAction;
    FileExitAction: TFileExit;
    MainActionList: TActionList;
    MainFormMenu: TMainMenu;
    FileMenu: TMenuItem;
    FileMenuDivider1: TMenuItem;
    ExitMenuItem: TMenuItem;
    MainFormPageControl: TPageControl;
    SaveProjectMenuItem: TMenuItem;
    OpenProjectMenuItem: TMenuItem;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure NewProjectActionExecute(Sender: TObject);
    procedure SettingsActionExecute(Sender: TObject);
  private
    { private declarations }
    FActiveFrame: TFrame;
    TabNameCount: integer;
    procedure LoadIniFile;
  public
    { public declarations }
    property  ActiveFrame: TFrame read FActiveFrame;
  end; 

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  project_frame, dataform_frame, fieldedit, settings;

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
  OpenProjectMenuItem.Action := Frame.OpenProjectAction;

  Inc(TabNameCount);
end;

procedure TMainForm.SettingsActionExecute(Sender: TObject);
var
  SettingsForm: TSettingsForm;
begin
  SettingsForm := TSettingsForm.Create(Self);
  SettingsForm.ShowModal;
end;

procedure TMainForm.LoadIniFile;
const
  IniName = 'epidataentry.ini';
begin
  // TODO : Settings can be loaded from commandline?

  if LoadSettingsFromIni(GetAppConfigDirUTF8(false) + IniName) then exit;

  // Todo - this is not optimal on Non-windows OS's. Do some checks for writeability first.
  if LoadSettingsFromIni(ExtractFilePath(Application.ExeName) + IniName) then exit;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
//  SetCaption;
  {$IFDEF EPI_RELEASE}
  Width := 800;
  Height := 600;
  {$ENDIF}

  LoadIniFile;

  NewProjectAction.Execute;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  List: TFPList;
  Res: LongInt;
  i: Integer;
begin
  CanClose := false;

  // TODO : Optimize NOT to used casting, and units specific to the dataform_frame
  // TODO : Works only on a single datafile in a single document - expand to be more generic.
  if (Assigned(TProjectFrame(ActiveFrame).EpiDocument)) and
     ((TProjectFrame(ActiveFrame).EpiDocument.Modified) or
      (TDataFormFrame(TProjectFrame(ActiveFrame).ActiveFrame).Modified))
  then begin
    Res := MessageDlg('Warning',
      'Project data content modified.' + LineEnding +
      'Save before exit?',
      mtWarning, mbYesNoCancel, 0, mbCancel);

    if Res = mrCancel then exit;

    if Res = mrYes then
    begin
      // Commit field (in case they are not already.
      List := TDataFormFrame(TProjectFrame(ActiveFrame).ActiveFrame).FieldEditList;
      for i := 0 to List.Count - 1 do
        TFieldEdit(List[i]).Commit;

      SaveProjectMenuItem.Click;
    end;
  end;
  CanClose := true;
end;

end.

