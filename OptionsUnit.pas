unit OptionsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls,Registry,ShlObj;

type
  TOptionsForm = class(TForm)
    OptionsPageControl: TPageControl;
    EdOptions: TTabSheet;
    DataformOptions: TTabSheet;
    ColorDialog1: TColorDialog;
    GroupBox1: TGroupBox;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    FontDialog1: TFontDialog;
    EdFontBtn: TButton;
    FontExPanel: TPanel;
    EdColorBtn: TButton;
    FormColorGroup: TGroupBox;
    DataFontExPanel: TPanel;
    DataFormFontBtn: TButton;
    DataFormColorBtn: TButton;
    TabSheet1: TTabSheet;
    GroupBox5: TGroupBox;
    DocuFontExPanel: TPanel;
    DocuFontBtn: TButton;
    DocuColorBtn: TButton;
    GroupBox6: TGroupBox;
    Label5: TLabel;
    NumTabCharsEdit: TEdit;
    Label6: TLabel;
    CreateDatafileOptions: TTabSheet;
    FieldNameCaseRadio: TRadioGroup;
    FieldNameTypeRadio: TRadioGroup;
    UpdateQuestionCheck: TCheckBox;
    Bevel1: TBevel;
    TabSheet2: TTabSheet;
    IDNumberGroup: TGroupBox;
    Label1: TLabel;
    IDNUMEdit: TEdit;
    ErrorGroup: TGroupBox;
    ShowExprErrorsCheck: TCheckBox;
    Label7: TLabel;
    FieldColorGroup: TGroupBox;
    HighlightActiveCheck: TCheckBox;
    HighlightColorPanel: TPanel;
    HighlightColorBtn: TButton;
    FieldColorBtn: TButton;
    FieldColorPanel: TPanel;
    FieldStyleRadio: TRadioGroup;
    TabGroup: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    EvenTabEdit: TEdit;
    LineHeightRadio: TRadioGroup;
    RestoreGroup: TGroupBox;
    BitBtn1: TBitBtn;
    GroupBox2: TGroupBox;
    LanguageCombo: TComboBox;
    TabSheet3: TTabSheet;
    GroupBox3: TGroupBox;
    QESCheck: TCheckBox;
    RecCheck: TCheckBox;
    ChkCheck: TCheckBox;
    AssocBtn: TButton;
    RemoveAssBtn: TButton;
    NOTCheck: TCheckBox;
    LOGCheck: TCheckBox;
    GroupBox4: TGroupBox;
    WarningSoundsCheck: TCheckBox;
    procedure EdColorBtnClick(Sender: TObject);
    procedure EdFontBtnClick(Sender: TObject);
    procedure DataFormFontBtnClick(Sender: TObject);
    procedure DataFormColorBtnClick(Sender: TObject);
    procedure IDNUMEditKeyPress(Sender: TObject; var Key: Char);
    procedure DocuFontBtnClick(Sender: TObject);
    procedure DocuColorBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FieldNameTypeRadioClick(Sender: TObject);
    procedure HighlightActiveCheckClick(Sender: TObject);
    procedure FieldColorBtnClick(Sender: TObject);
    procedure HighlightColorBtnClick(Sender: TObject);
    procedure AssocBtnClick(Sender: TObject);
    procedure RemoveAssBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;
  FontChanged, ColorChanged:Boolean;

implementation

uses MainUnit, EpiTypes;

{$R *.DFM}


procedure TOptionsForm.EdColorBtnClick(Sender: TObject);
begin
  ColorDialog1.Color:=FontExPanel.Color;
  IF ColorDialog1.Execute
  THEN FontExPanel.Color:=ColorDialog1.Color;
end;


procedure TOptionsForm.EdFontBtnClick(Sender: TObject);
begin
  FontDialog1.Font.Assign(FontExPanel.Font);
  IF FontDialog1.Execute THEN
    BEGIN
      FontExPanel.Font.Assign(FontDialog1.Font);
      FontExPanel.Caption:=FontDialog1.Font.Name+
      ', '+IntToStr(FontDialog1.Font.Size)+' p.';
    END;
end;



procedure TOptionsForm.DataFormFontBtnClick(Sender: TObject);
begin
  FontDialog1.Font.Assign(DataFontExPanel.Font);
  IF FontDialog1.Execute THEN
    BEGIN
      DataFontExPanel.Font.Assign(FontDialog1.Font);
      DataFontExPanel.Caption:=FontDialog1.Font.Name+
      ', '+IntToStr(FontDialog1.Font.Size)+' p.';
    END;
end;

procedure TOptionsForm.DataFormColorBtnClick(Sender: TObject);
begin
  ColorDialog1.Color:=DataFontExPanel.Color;
  IF ColorDialog1.Execute
  THEN DataFontExPanel.Color:=ColorDialog1.Color;
end;



procedure TOptionsForm.DocuFontBtnClick(Sender: TObject);
begin
  FontDialog1.Font.Assign(DocuFontExPanel.Font);
  FontDialog1.Options:=FontDialog1.Options+[fdFixedPitchOnly];
  IF FontDialog1.Execute THEN
    BEGIN
      DocuFontExPanel.Font.Assign(FontDialog1.Font);
      DocuFontExPanel.Caption:=FontDialog1.Font.Name+
      ', '+IntToStr(FontDialog1.Font.Size)+' p.';
    END;
  FontDialog1.Options:=FontDialog1.Options-[fdFixedPitchOnly];
end;

procedure TOptionsForm.DocuColorBtnClick(Sender: TObject);
begin
  ColorDialog1.Color:=DocuFontExPanel.Color;
  IF ColorDialog1.Execute
  THEN DocuFontExPanel.Color:=ColorDialog1.Color;
end;

procedure TOptionsForm.IDNUMEditKeyPress(Sender: TObject; var Key: Char);
VAR
  KeyOK:Boolean;
begin
  KeyOK:=True;
  IF NOT(Key in IntegerChars) THEN KeyOK:=FALSE;
  IF ORD(Key)=8 THEN KeyOK:=TRUE;   //BackSpace is OK
  IF NOT KeyOK THEN
    BEGIN
      beep;
      Key:=#0;
    END;
end;

procedure TOptionsForm.FormCreate(Sender: TObject);
VAR
  SearchRec: TSearchRec;
  n,Found: Integer;
  Languages: TStringList;
  s: String;
begin
  TranslateForm(self);
  OptionsPageControl.ActivePage:=OptionsPageControl.Pages[LastActiveOptionsPage];
  FontExPanel.Font.Assign(epiEdFont);
  FontExPanel.Caption:=epiEdFont.Name+', '+IntToStr(epiEdFont.Size)+' p.';
  FontExPanel.Color:=EdColor;
  DataFontExPanel.Font.Assign(epiDataFormFont);
  DataFontExPanel.Caption:=epiDataFormFont.Name+', '+IntToStr(epiDataformFont.Size)+' p.';
  DataFontExPanel.Color:=DataFormColor;
  DocuFontExPanel.Font.Assign(epiDocuFont);
  DocuFontExPanel.Caption:=epiDocuFont.Name+', '+IntToStr(epiDocuFont.Size)+' p.';
  DocuFontExPanel.Color:=DocuColor;

  CASE FieldNameCase OF
    fcUpper: FieldNameCaseRadio.ItemIndex:=0;
    fcLower: FieldNameCaseRadio.ItemIndex:=1;
    fcDontChange: FieldNameCaseRadio.ItemIndex:=2;
  END;  //case
  IDNUMEdit.Text:=IntToStr(FirstIDNumber);
  EvenTabEdit.Text:=IntToStr(EvenTabValue);
  NumTabCharsEdit.Text:=IntToStr(NumberOfTabChars);
  FieldNameTypeRadio.ItemIndex:=ORD(EpiInfoFieldNaming);
  UpdateQuestionCheck.Checked:=UpdateFieldnameInQuestion;
  UpdateQuestionCheck.Enabled:=(FieldnameTypeRadio.ItemIndex=0);
  ShowExprErrorsCheck.Checked:=ShowExprErrors;
  WarningSoundsCheck.Checked:=WarningSounds;
  FieldColorPanel.Color:=FieldColor;
  FieldStyleRadio.ItemIndex:=FieldStyle;
  HighlightActiveCheck.Checked:=FieldHighlightActive;
  HighlightColorBtn.Enabled:=FieldHighlightActive;
  HighlightColorPanel.Color:=FieldHighlightColor;
  LineHeightRadio.ItemIndex:=LineHeight;

  {Find languagefiles}
  Languages:=TStringList.Create;
  Languages.Append('English');
  Found:=FindFirst(ExtractFiledir(ParamStr(0))+'\*.lang.txt',faAnyFile,SearchRec);
  WHILE Found=0 DO
    BEGIN
      s:=ExtractFilename(SearchRec.Name);
      n:=Pos('.lang.txt',s);
      s:=Copy(s,1,n-1);
      Languages.Append(s);
      Found:=FindNext(SearchRec);
    END;  //while
  FindClose(SearchRec);
  Languages.Sort;
  Found:=Languages.IndexOf(CurLanguage);
  LanguageCombo.Items.Assign(Languages);
  LanguageCombo.ItemIndex:=Found;
  Languages.Free;
end;

procedure TOptionsForm.FieldNameTypeRadioClick(Sender: TObject);
begin
  UpdateQuestionCheck.Enabled:=(FieldnameTypeRadio.ItemIndex=0);
end;






procedure TOptionsForm.HighlightActiveCheckClick(Sender: TObject);
begin
  HighlightColorBtn.Enabled:=HighlightActiveCheck.Checked;
end;





procedure TOptionsForm.FieldColorBtnClick(Sender: TObject);
begin
  IF ColorDialog1.Execute THEN FieldColorPanel.Color:=ColorDialog1.Color;
end;

procedure TOptionsForm.HighlightColorBtnClick(Sender: TObject);
begin
  IF ColorDialog1.Execute THEN HighlightColorPanel.Color:=ColorDialog1.Color;
end;


Procedure AssociateFiletype(CONST AExt,AFiletype,ATypeDescrip:String; AIconNo:Integer);
VAR
  Reg: TRegistry;
BEGIN
  Reg:=TRegistry.Create;
  TRY
    Reg.RootKey:=HKEY_CLASSES_ROOT;
    Reg.OpenKey(AExt,True);
    Reg.WriteString('',AFileType);
    Reg.CloseKey;
    Reg.OpenKey(AFileType,True);
    Reg.WriteString('',ATypeDescrip);
    Reg.CloseKey;
    Reg.OpenKey(AFiletype+'\DefaultIcon',True);
    Reg.WriteString('',Application.ExeName+','+IntToStr(AIconNo));
    reg.CloseKey;
    Reg.OpenKey(AFiletype+'\Shell\Open\Command',True);
    Reg.Writestring('','"'+Application.ExeName+'" "%1"');
    Reg.CloseKey;
  FINALLY
    Reg.Free;
  END;
END;

Procedure RemoveAssociation(CONST AExt,AFiletype: String);
VAR
  Reg: TRegistry;
BEGIN
  Reg:=TRegistry.Create;
  TRY
    Reg.RootKey:=HKEY_CLASSES_ROOT;
    Reg.DeleteKey(AExt);
    Reg.DeleteKey(AFiletype+'\Shell\Open\Command');
    Reg.DeleteKey(AFiletype+'\DefaultIcon');
    reg.DeleteKey(AFiletype);
  FINALLY
    Reg.Free;
  END;
ENd;

procedure TOptionsForm.AssocBtnClick(Sender: TObject);
begin
  IF (QesCheck.Checked) OR (ChkCheck.Checked) OR (recCheck.Checked)
  OR (notCheck.Checked) OR (logCheck.Checked) THEN
    BEGIN
      IF QesCheck.Checked THEN AssociateFiletype('.qes','EpiData.Qes',Lang(50200),1);   //'EpiData Questionnaire'
      IF ChkCheck.Checked THEN AssociateFiletype('.chk','EpiData.Chk',Lang(50202),2);   //'EpiData Check file'
      IF RecCheck.Checked THEN AssociateFiletype('.rec','EpiData.Rec',Lang(50204),0);   //'EpiData Datafile'
      IF NOTCheck.Checked THEN AssociateFiletype('.not','EpiData.not',Lang(50206),3);   //'EpiData dataentry notes'
      IF LOGCheck.Checked THEN AssociateFiletype('.log','EpiData.log',Lang(50208),4);   //'EpiData documentation file'
      SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,nil,nil);
      eDlg(Lang(50210),mtInformation,[mbOK],0);   //'Marked file extensions associated with EpiData'
    END
  ELSE ErrorMsg(Lang(50212));   //'Please select which filetypes should be associated with EpiData'
end;

procedure TOptionsForm.RemoveAssBtnClick(Sender: TObject);
begin
  IF (QesCheck.Checked) OR (ChkCheck.Checked) OR (recCheck.Checked)
  OR (notCheck.Checked) OR (logCheck.Checked) THEN
    BEGIN
      IF QesCheck.Checked THEN RemoveAssociation('.qes','EpiData.Qes');
      IF ChkCheck.Checked THEN RemoveAssociation('.chk','EpiData.Chk');
      IF RecCheck.Checked THEN RemoveAssociation('.rec','EpiData.Rec');
      IF NotCheck.Checked THEN RemoveAssociation('.not','EpiData.not');
      IF LogCheck.Checked THEN RemoveAssociation('.log','EpiData.log');
      SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,nil,nil);
      eDlg(Lang(50214),mtInformation,[mbOK],0);   //'Marked file extensions no longer associated with EpiData'
    END
  ELSE ErrorMsg(Lang(20216));   //'Please select the filetypes whose association with EpiData are to be removed'
end;

end.
