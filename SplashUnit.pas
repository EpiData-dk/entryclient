unit SplashUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TSplashForm = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    Label1: TLabel;
    VersionLabel: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Label3: TLabel;
    Label4: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SplashForm: TSplashForm;

implementation

USES EpiTypes;

{$R *.DFM}


procedure TSplashForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=False;
end;

procedure TSplashForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=NOT Timer1.Enabled;
end;




procedure TSplashForm.FormCreate(Sender: TObject);
begin
  VersionLabel.Caption:=VersionLabel.Caption+EpiDataVersion;
end;

end.
