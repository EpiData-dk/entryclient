unit PickListUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons, ComCtrls, ExtCtrls;

type
  TPickListForm = class(TForm)
    PageControl: TPageControl;
    NumPage: TTabSheet;
    TextPage: TTabSheet;
    DatePage: TTabSheet;
    OtherPage: TTabSheet;
    BeforeUpDown: TUpDown;
    AfterUpDown: TUpDown;
    BeforeDigitEdit: TEdit;
    AfterDigitEdit: TEdit;
    BeforeDigitLabel: TLabel;
    AfterDigitLabel: TLabel;
    NumSampleLabel: TLabel;
    NumLengthLabel: TLabel;
    NumInsertBtn: TBitBtn;
    TextTypeRadio: TRadioGroup;
    TextInsertBtn: TBitBtn;
    DateInsertBtn: TBitBtn;
    OtherInsertBtn: TBitBtn;
    TextLengthEdit: TEdit;
    TextUpDown: TUpDown;
    Label1: TLabel;
    DateRadio: TRadioGroup;
    AutoDateRadio: TRadioGroup;
    OtherLengthLabel: TLabel;
    OtherLengthEdit: TEdit;
    OtherUpDown: TUpDown;
    OtherRadio: TRadioGroup;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BeforeDigitEditKeyPress(Sender: TObject; var Key: Char);
    procedure BeforeDigitEditChange(Sender: TObject);
    Procedure UpdateNumLabels;
    procedure NumInsertBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AfterDigitEditChange(Sender: TObject);
    procedure TextLengthEditChange(Sender: TObject);
    procedure TextInsertBtnClick(Sender: TObject);
    procedure DateRadioClick(Sender: TObject);
    procedure AutoDateRadioClick(Sender: TObject);
    procedure DateInsertBtnClick(Sender: TObject);
    procedure OtherRadioClick(Sender: TObject);
    procedure OtherLengthEditChange(Sender: TObject);
    procedure OtherInsertBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PickListForm: TPickListForm;

implementation

USES EpiTypes, EdUnit, MainUnit;

{$R *.DFM}

VAR
  NumInsertStr:String;


procedure TPickListForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.PickListBtn.Down:=False;
  PickListCreated:=False;
end;


{procedure TPickListForm.PickTag(i:Integer);
VAR
  s:String;
BEGIN
  s:='';
  CASE i OF
    0:PickListForm.Close;
    1:BEGIN    //Integer
        IF (FieldLenEdit.Value>0) AND (FieldLenEdit.Value<15)
        THEN WHILE Length(s)<FieldLenEdit.Value DO s:=s+'#';
      END;
    2:BEGIN    //IDNUM
        s:='<IDNUM';
        IF (FieldLenEdit.Value>5) AND (FieldLenEdit.Value<15)
        THEN WHILE Length(s)<FieldLenEdit.Value+1 DO s:=s+' ';
        s:=s+'>';
      END;
    3:BEGIN   //Text
        IF (FieldLenEdit.Value>0) AND (FieldLenEdit.Value<81)
        THEN WHILE Length(s)<FieldLenEdit.Value DO s:=s+'_';
      END;
    4:BEGIN   //Upper-case alpha
        IF(FieldLenEdit.Value>0) AND (FieldLenEdit.Value<81) THEN
        BEGIN
          s:='<A';
          WHILE Length(s)<FieldLenEdit.Value+1 DO s:=s+' ';
          s:=s+'>';
        END;
      END;
    5:BEGIN   //Soundex
        IF (FieldLenEdit.Value>0) AND (FieldLenEdit.Value<81) THEN
        BEGIN
          s:='<S';
          WHILE Length(s)<FieldLenEdit.Value+1 DO s:=s+' ';
          s:=s+'>';
        END;
      END;
    6: s:='<Y>';                    //Boolean
    7: s:='<dd/mm/yyyy>';                //EU date
    8: s:='<mm/dd/yyyy>';             //US date
    9: s:='<today-dmy>';           //EU today
    10: s:='<today-mdy>';               //US today
  END;   //Case
  IF s<>'' THEN
    BEGIN
      LastActiveEd.SelText:=s;
      MainForm.SetFocus;
    END;
END;}


procedure TPickListForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF Key=VK_ESCAPE THEN PickListForm.Close;
  IF (Key=ORD('Q')) AND (Shift=[ssCtrl]) THEN PickListForm.Close;
end;

procedure TPickListForm.BeforeDigitEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  IF NOT ((Key in NumChars) or (Key=#8)) THEN
    BEGIN
      Beep;
      Key:=#0;
    END;
end;

procedure TPickListForm.BeforeDigitEditChange(Sender: TObject);
begin
  IF BeforeDigitEdit.Text='' THEN BeforeUpDown.Position:=1
  ELSE BeforeUpDown.Position:=StrToInt(BeforeDigitEdit.Text);
  BeforeDigitEdit.SelStart:=Length(BeforeDigitEdit.Text);
  UpdateNumLabels;
end;

procedure TPickListForm.AfterDigitEditChange(Sender: TObject);
begin
  IF AfterDigitEdit.Text='' THEN AfterUpDown.Position:=0
  ELSE AfterUpDown.Position:=StrToInt(AfterDigitEdit.Text);
  AfterDigitEdit.SelStart:=Length(AfterDigitEdit.Text);
  UpdateNumLabels;
end;

Procedure TPickListForm.UpdateNumLabels;
VAR
  fLength:Integer;
BEGIN
  fLength:=BeforeUpDown.Position+AfterUpDown.Position+
  ORD(AfterUpDown.Position>0);
  IF (fLength>14) OR (BeforeUpDown.Position=0) THEN
    BEGIN
      NumInsertStr:=Lang(22900);  //'Illegal'
      NumInsertBtn.Enabled:=False;
      If BeforeUpDown.Position=0 THEN
        BEGIN
          NumSampleLabel.Caption:=Lang(22902);  //'Error: 1 or more digits before';
          NumLengthLabel.Caption:=Lang(22904);  //'decimalpoint required.';
          NumSampleLabel.Font.Color:=clRed;
          NumLengthLabel.Font.Color:=clRed;
        END
      ELSE
        BEGIN
          NumSampleLabel.Caption:=Lang(22906);  //'Error: Maximum length is 14 characters.'
          NumLengthLabel.Caption:=Format(Lang(22908),[fLength]);  //'Field length: %d'
          NumSampleLabel.Font.Color:=clRed;
          NumLengthLabel.Font.Color:=clWindowText;
        END;
    END
  ELSE
    BEGIN
      NumInsertBtn.Enabled:=True;
      NumInsertStr:=cFill('#',BeforeUpDown.Position);
      IF AfterUpDown.Position>0
      THEN NumInsertStr:=NumInsertStr+'.'+cFill('#',AfterUpDown.Position);
      NumSampleLabel.Caption:=Lang(4616)+' '+NumInsertStr;  //'Field to insert: '
      NumLengthLabel.Caption:=Format(Lang(22908),[Length(NumInsertStr)]);  //'Field length: '+
      NumSampleLabel.Font.Color:=clWindowText;
      NumLengthLabel.Font.Color:=clWindowText;
    END;
END;


procedure TPickListForm.NumInsertBtnClick(Sender: TObject);
begin
  UpDateNumLabels;
  IF NumInsertBtn.Enabled THEN
    BEGIN
      LastActiveEd.SelText:=NumInsertStr;
      MainForm.SetFocus;
    END;
end;

procedure TPickListForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  PageControl.ActivePage:=NumPage;
  BeforeUpDown.Position:=1;
  AfterUpDown.Position:=0;
end;


procedure TPickListForm.TextLengthEditChange(Sender: TObject);
begin
  IF TextLengthEdit.Text='' THEN TextUpDown.Position:=0
  ELSE TextUpDown.Position:=StrToInt(TextLengthEdit.Text);
  TextLengthEdit.SelStart:=Length(TextLengthEdit.Text);
end;

procedure TPickListForm.TextInsertBtnClick(Sender: TObject);
VAR
  s:String;
begin
  IF TextUpDown.Position>0 THEN
    BEGIN
      IF TextTypeRadio.ItemIndex=0 THEN s:=cFill('_',TextUpDown.Position)
      ELSE IF TextTypeRadio.ItemIndex=2 THEN
        BEGIN
          IF TextUpDown.Position=1 THEN s:='<E>'
          ELSE s:='<E'+cFill(' ',TextUpDown.Position-1)+'>';
        END
      ELSE
        BEGIN
          IF TextUpDown.Position=1 THEN s:='<A>'
          ELSE s:='<A'+cFill(' ',TextUpDown.Position-1)+'>';
        END;
      LastActiveEd.SelText:=s;
      MainForm.SetFocus;
    END;  //if length>0
end;

procedure TPickListForm.DateRadioClick(Sender: TObject);
begin
  AutoDateRadio.ItemIndex:=-1;
end;

procedure TPickListForm.AutoDateRadioClick(Sender: TObject);
begin
  DateRadio.ItemIndex:=-1;
end;

procedure TPickListForm.DateInsertBtnClick(Sender: TObject);
VAR
  s:String;
begin
  s:='';
  CASE DateRadio.ItemIndex OF
    0: s:='<dd/mm/yyyy>';
    1: s:='<mm/dd/yyyy>';
    2: s:='<yyyy/mm/dd>';
  END;  //case
  CASE AutoDateRadio.ItemIndex OF
    0: s:='<Today-dmy>';
    1: s:='<Today-mdy>';
    2: s:='<Today-ymd>';
  END;  //case
  IF s<>'' THEN
    BEGIN
      LastActiveEd.SelText:=s;
      MainForm.SetFocus;
    END;
end;



procedure TPickListForm.OtherRadioClick(Sender: TObject);
begin
  OtherLengthEdit.Enabled:=NOT (OtherRadio.ItemIndex=2);
  OtherUpDown.Enabled:=NOT (OtherRadio.ItemIndex=2);
  OtherLengthLabel.Enabled:=NOT (OtherRadio.ItemIndex=2);
  CASE OtherRadio.ItemIndex OF
    0: OtherUpDown.Max:=14;
    1: OtherUpDown.Max:=80;
    2: OtherUpDown.Max:=1;
  END;
end;

procedure TPickListForm.OtherLengthEditChange(Sender: TObject);
begin
  IF OtherLengthEdit.Text='' THEN OtherUpDown.Position:=0
  ELSE OtherUpDown.Position:=StrToInt(OtherLengthEdit.Text);
  OtherLengthEdit.SelStart:=Length(OtherLengthEdit.Text);
end;

procedure TPickListForm.OtherInsertBtnClick(Sender: TObject);
VAR
  s:String;
begin
  IF OtherUpDown.Position>0 THEN
    BEGIN
      CASE OtherRadio.ItemIndex OF
        0: BEGIN
             IF OtherUpDown.Position<5 THEN OtherUpDown.Position:=5;
             s:='<IDNUM'+cFill(' ',OtherUpDown.Position-5)+'>';
           END;
        1: s:='<S'+cFill(' ',OtherUpDown.Position-1)+'>';
        2: s:='<Y>';
      END;
        LastActiveEd.SelText:=s;
        MainForm.SetFocus;
    END;  //if Length>0
end;

procedure TPickListForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  IF Key=#27 THEN
    BEGIN
      Key:=#0;
      PickListForm.Close;
    END;
end;

end.
