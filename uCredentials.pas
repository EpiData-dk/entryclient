unit uCredentials;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TformCredentials = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edUsername: TEdit;
    edPassword: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formCredentials: TformCredentials;

implementation

{$R *.DFM}

end.
