unit CheckErrorUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TCheckErrorForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CheckErrorForm: TCheckErrorForm;

implementation

{$R *.DFM}

USES EpiTypes;

procedure TCheckErrorForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
end;

end.
