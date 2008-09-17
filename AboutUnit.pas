unit AboutUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, FmxUtils;

type
  TAboutForm = class(TForm)
    VersionLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    AboutHyperLink: TLabel;
    CloseBtn: TBitBtn;
    LogoAnim: TAnimate;
    FundingHyperLink: TLabel;
    LanguageLabel: TLabel;
    TranslatorLabel: TLabel;
    LocalHomepageLabel: TLabel;
    procedure AboutHyperLinkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label7DblClick(Sender: TObject);
    procedure FundingHyperLinkClick(Sender: TObject);
    procedure LocalHomepageLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.DFM}


USES
  EpiTypes;

CONST
  EPILOGO=123;


procedure TAboutForm.AboutHyperLinkClick(Sender: TObject);
begin
  Application.HelpContext(10);
end;

procedure TAboutForm.FormCreate(Sender: TObject);
VAR
  LanguageStr,HomePageStr: String;
begin
  TranslateForm(self);
  VersionLabel.Caption:=VersionLabel.Caption+' '+EpiDataVersion+'    ('+BuildNo+')';
  TRY
    LogoAnim.ResNAME:='EPILOGO';
    LogoAnim.Active:=True;
  EXCEPT
    ErrorMsg(Format(Lang(22104),[ExtractFileDir(ParamStr(0))+'\EpiLogo.avi']));  //'The file %s cannot be opened.'
  END;  //try..except
  LanguageStr:=Lang(100);
  IF (NOT UsesEnglish) AND (LanguageStr[1]<>'*') AND (LanguageStr[1]<>'[') THEN
    BEGIN
      LanguageLabel.Caption:=Format(Lang(3008),[LanguageStr]);
      TranslatorLabel.Caption:=Lang(110);
      HomePageStr:=Lang(120);
      IF (HomePageStr[1]<>'*') AND (HomePageStr[1]<>'[') THEN
        BEGIN
          LocalHomepageLabel.Caption:=HomePageStr;
        END;
    END
  ELSE
    BEGIN
      LanguageLabel.Visible:=False;
      TranslatorLabel.Visible:=False;
      LocalHomepageLabel.Visible:=False;
      AboutHyperLink.Top:=216;
      FundingHyperLink.Top:=240;
      CloseBtn.Top:=270;
      Self.Height:=330;
    END;

end;

procedure TAboutForm.Label7DblClick(Sender: TObject);
begin
  LogoAnim.Active:=True;
end;


procedure TAboutForm.FundingHyperLinkClick(Sender: TObject);
begin
  Application.HelpContext(110);
end;


procedure TAboutForm.LocalHomepageLabelClick(Sender: TObject);
begin
  ExecuteFile(Lang(120),'', ExtractFileDir(ParamStr(0)), SW_SHOW);
end;

end.
