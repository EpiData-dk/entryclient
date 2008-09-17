unit WelcomeUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls;

type
  TWelcomeForm = class(TForm)
    RichEdit1: TRichEdit;
    Panel1: TPanel;
    HeadingLabel: TLabel;
    Panel2: TPanel;
    DontShowAgainCheck: TCheckBox;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WelcomeForm: TWelcomeForm;

implementation

Uses
  EpiTypes;

{$R *.DFM}



procedure TWelcomeForm.FormCreate(Sender: TObject);
VAR
  ReadFilename:TFilename;
begin
  TranslateForm(self);
  ReadFilename:=ExtractFileDir(ParamStr(0))+'\ReadMe.Rtf';
  IF NOT UsesEnglish AND (Lang(105)<>'**105**')
  THEN ReadFilename:=ExtractFileDir(ParamStr(0))+'\ReadMe_'+Lang(105)+'.rtf';
  IF NOT FileExists(ReadFilename) THEN ReadFilename:=ExtractFileDir(ParamStr(0))+'\ReadMe.Rtf';
  HeadingLabel.Caption:=HeadingLabel.Caption+' '+EpiDataVersion;
  DontShowAgainCheck.Checked:=False;
  IF FileExists(ReadFilename)
  THEN RichEdit1.Lines.LoadFromFile(ReadFilename)
  ELSE ErrorMsg(Lang(20214));   //'The ReadMe.rtf file was not found.~~Please get an updated version of EpiData at www.EpiData.dk'
end;

procedure TWelcomeForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ShowWelcomeWindow:=NOT DontShowAgainCheck.Checked;
end;




end.
