unit WarningUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TWarningForm = class(TForm)
    Image1: TImage;
    YesBtn: TButton;
    NoBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WarningForm: TWarningForm;

  Function WarningDlg(CONST s1,s2,s3,s4:String):Word;

implementation

{$R *.DFM}

USES
  EpiTypes;

Function WarningDlgOld(CONST s1,s2,s3,s4:String):Word;
BEGIN
  TRY
    WarningForm:=TWarningForm.Create(Application);
    IF trim(s1)<>'' THEN WarningForm.Label1.Caption:=s1;
    IF trim(s2)<>'' THEN WarningForm.Label2.Caption:=s2;
    IF trim(s3)<>'' THEN WarningForm.Label3.Caption:=s3;
    IF trim(s4)<>'' THEN WarningForm.Label4.Caption:=s4;
    Result:=WarningForm.ShowModal;
  FINALLY
    WarningForm.Free;
  END;
END;



procedure TWarningForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
end;

end.
