unit unitGCPInit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TformGCPAdminInit = class(TForm)
    btnOpen: TButton;
    btnNew: TButton;
    editSecFilename: TEdit;
    FindFile1: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FindFile1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formGCPAdminInit: TformGCPAdminInit;

implementation

{$R *.DFM}

uses
  EpiTypes;

procedure TformGCPAdminInit.FormCreate(Sender: TObject);
begin
  OpenDialog1.InitialDir:=GetRecentFileDir;
  OpenDialog1.Filename:=GetRecentFilename('.sec');
  editSecFilename.Text:=OpenDialog1.FileName;
end;

procedure TformGCPAdminInit.FindFile1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then editSecFilename.Text:=OpenDialog1.FileName;
end;

procedure TformGCPAdminInit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=True;
  if modalresult=mrCancel then exit;
  if (modalresult=mrYes) and (trim(editSecFilename.text)='') then
    begin
      ErrorMsg('Please enter file name for existing project');
      Canclose:=false;
      exit;
    end;
  if (modalresult=mrYes) and (NOT(fileexists(editSecFilename.text))) then
    begin
      Errormsg('The file '+editSecFilename.text+' doesn''t exist');
      CanClose:=false;
    end;
end;

end.
