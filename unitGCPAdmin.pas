unit unitGCPAdmin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ComCtrls, Grids;

type
  TformGCPAdmin = class(TForm)
    PageControl1: TPageControl;
    tabProject: TTabSheet;
    tabUsers: TTabSheet;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    ComboBox1: TComboBox;
    Edit5: TEdit;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    tabFiles: TTabSheet;
    ListBox1: TListBox;
    gridCombo: TComboBox;
    sg: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FFilename: TFilename;
  public
    { Public declarations }
    property filename:TFilename read FFilename write FFilename;
  end;

var
  formGCPAdmin: TformGCPAdmin;

implementation

{$R *.DFM}

procedure TformGCPAdmin.FormCreate(Sender: TObject);
var
  n,t: integer;
begin
  sg.Cells[1,0]:='Username';
  sg.Cells[2,0]:='Password';
  sg.Cells[3,0]:='Notes';
  for n:=1 to sg.RowCount-1 do
    sg.Cells[0,n]:='User '+IntToStr(n);
  PageControl1.ActivePage:=tabProject;
end;

end.
