unit PasswordUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, EpiTypes;

type
  TPasswordForm = class(TForm)
    edPW1: TEdit;
    Label1: TLabel;
    edPW2: TEdit;
    Label2: TLabel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    Label3: TLabel;
    Label4: TLabel;
    lbDatafile: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    DoubleEntry: Boolean;
  end;

var
  PasswordForm: TPasswordForm;

implementation

{$R *.DFM}

procedure TPasswordForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  DoubleEntry:=True;
end;

procedure TPasswordForm.FormPaint(Sender: TObject);
begin
  IF DoubleEntry=False THEN
    BEGIN
      edPW2.Visible:=False;
      edPW2.Enabled:=False;
      Label2.Visible:=False;
    END;
end;

procedure TPasswordForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  IF ModalResult=mrCancel THEN CanClose:=True
  ELSE
    BEGIN
      IF DoubleEntry THEN
        BEGIN
          CanClose:=(edPW1.Text=edPW2.Text);
          IF (NOT CanClose) THEN
          MessageDlg('The password are not identical',mtError,[mbOK],0);
          IF (Length(edPW1.Text)<6) OR (trim(edPW1.Text)='') THEN
            BEGIN
              MessageDlg('Password must be 6 or more characters',mtError,[mbOK],0);
              CanClose:=False;
            END;
        END
      ELSE CanClose:=True;
    END;
end;

end.
