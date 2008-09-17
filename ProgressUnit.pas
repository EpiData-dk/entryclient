unit ProgressUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls;

type
  TProgressForm = class(TForm)
    pBar: TProgressBar;
    CancelBtn: TBitBtn;
    pLabel: TLabel;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProgressForm: TProgressForm;

implementation

{$R *.DFM}

USES
  EpiTypes, MainUnit;

procedure TProgressForm.CancelBtnClick(Sender: TObject);
begin
  Beep;
  UserAborts:=True;
end;

procedure TProgressForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=UserAborts;
  Beep;
  UserAborts:=True;
end;

procedure TProgressForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
end;

end.
