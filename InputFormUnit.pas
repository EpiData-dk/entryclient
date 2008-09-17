unit InputFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  InputTypes = (itInteger,itFloat,itAlfa);
  TInputForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    MaxLength: Integer;
    InputType: InputTypes;
    DefaultValue: String;
    UserInput: String;
    LabelText: String;
    { Public declarations }
  end;

var
  InputForm: TInputForm;

implementation

{$R *.DFM}

USES
  EpiTypes;


procedure TInputForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UserInput:=Edit1.Text;
end;

procedure TInputForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  MaxLength:=0;
  InputType:=itAlfa;
  DefaultValue:='';
  UserInput:='';
  LabelText:='';
end;

procedure TInputForm.FormShow(Sender: TObject);
begin
  Label1.Caption:=LabelText;
  IF DefaultValue<>'' THEN Edit1.Text:=DefaultValue;
  IF MaxLength<>0 THEN Edit1.MaxLength:=MaxLength;
end;

end.
