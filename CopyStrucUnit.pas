unit CopyStrucUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, checklst, Buttons;

type
  TCopyDatafileForm = class(TForm)
    OldDatafileGroup: TGroupBox;
    NewDatafileGroup: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    OldRecDatafileLabel: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    NewRecFilenameEdit: TEdit;
    NewRecDatafileLabel: TEdit;
    HelpBtn: TBitBtn;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    SearchNewRecBtn: TBitBtn;
    OldRecFilenameLabel: TLabel;
    SaveDialog1: TSaveDialog;
    OptionsBox: TGroupBox;
    DontCopyTextFields: TCheckBox;
    DoCopyCheckFile: TCheckBox;
    checkMatchbyKeyfield: TCheckBox;
    procedure SearchNewRecBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NewRecFilenameEditExit(Sender: TObject);
    procedure checkMatchbyKeyfieldClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    MatchField:string;
    MatchFieldNo:Integer;
    FieldList:TStringList;
    MatchOldAndNewPath:boolean;
  end;

var
  CopyDatafileForm: TCopyDatafileForm;

implementation

{$R *.DFM}

USES
  EpiTypes, LegalPickListUnit;

procedure TCopyDatafileForm.SearchNewRecBtnClick(Sender: TObject);
begin
  IF ExtractFilename(NewRecFilenameEdit.Text)<>''
  THEN SaveDialog1.FileName:=NewRecFilenameEdit.Text
  ELSE
    BEGIN
      SaveDialog1.InitialDir:=ExtractFileDir(OldRecFilenameLabel.Caption);
      SaveDialog1.Filename:='';
    END;
  IF SaveDialog1.Execute THEN NewRecFilenameEdit.Text:=SaveDialog1.Filename;

end;

procedure TCopyDatafileForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  IF ModalResult=mrOK THEN
    BEGIN
      IF trim(NewRecFilenameEdit.Text)='' THEN
        BEGIN
          eDlg(Lang(21008),mtWarning,[mbOK],0);  //'Please specify a filename for the new datafile.',
          CanClose:=False;
        END
      ELSE IF ExtractFileExt(NewRecFilenameEdit.Text)<>'.REC'
      THEN NewRecFilenameEdit.Text:=ChangeFileExt(NewRecFilenameEdit.Text,'.rec');
      IF (MatchOldAndNewPath) THEN
        begin
          if AnsiUpperCase(extractfilepath(OldRecFilenameLabel.Caption))<>AnsiUpperCase(extractfilepath(NewRecFilenameEdit.Text)) then
            begin
              eDlg('Double entry data file must use same directory as original data file',mtWarning,[mbOK],0);
              CanClose:=False;
              exit;
            end;
        end;
      IF FileExists(NewRecFilenameEdit.Text) THEN
        IF NoYesDlg(Format(Lang(21500),[NewRecFilenameEdit.Text]))=mrNo THEN CanClose:=False;  //A file with name %s allready exists.~~Overwrite existing file?
    END
  ELSE CanClose:=True;
end;

procedure TCopyDatafileForm.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(150);
end;

procedure TCopyDatafileForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  FieldList:=TStringList.Create;
  MatchFieldNo:=-1;
  MatchField:='';
  SaveDialog1.Filter:=Lang(2104)+'|*.rec|'+Lang(2112)+'|*.*';  //  EpiData datafile  (*.rec)|*.rec|All files  (*.*)|*.*
  MatchOldAndNewPath:=false;
end;

procedure TCopyDatafileForm.NewRecFilenameEditExit(Sender: TObject);
begin
  IF ExtractFileExt(NewRecFilenameEdit.Text)<>'.REC'
  THEN NewRecFilenameEdit.Text:=ChangeFileExt(NewRecFilenameEdit.Text,'.rec');
end;

procedure TCopyDatafileForm.checkMatchbyKeyfieldClick(Sender: TObject);
VAR
  n,w,ModResult:Integer;
  s,FormStr: String;
  HasVarlabels:Boolean;
begin
  IF checkMatchbyKeyfield.Checked=True THEN
    BEGIN
      TRY
        LegalPickForm:=TLegalPickForm.Create(NIL);
        LegalPickForm.Caption:=Lang(3340);    //'Select key-field';
        LegalPickForm.ListBox1.Items.Assign(FieldList);
        LegalPickForm.ListBox1.ItemIndex:=0;
        //LegalPickForm.Width:=FieldNamesListWidth;

        w:=LegalPickForm.ShowModal;
        IF w=mrOK THEN
          BEGIN
            n:=LegalPickForm.ListBox1.ItemIndex;
            IF n>-1 THEN
              BEGIN
                MatchFieldNo:=Integer(LegalPickForm.ListBox1.Items.Objects[n]);
                MatchField:=LegalPickForm.ListBox1.Items[n];
                checkMatchbyKeyfield.caption:=Lang(3342) + ' ''' + trim(LegalPickForm.ListBox1.Items[n]) + '''';  //&Match records by field
              END
            ELSE
              BEGIN
                MatchFieldNo:=-1;
                MatchField:='';
                checkMatchbyKeyfield.caption:=Lang(3344);   //&Match record by keyfield
                checkMatchbyKeyField.Checked:=False;
              END;
          END  //if mrOK
        ELSE
          BEGIN
            MatchFieldNo:=-1;
            MatchField:='';
            checkMatchbyKeyfield.caption:=Lang(3344);    //&Match record by keyfield
            checkMatchbyKeyField.Checked:=False;
          END;
      FINALLY
        LegalPickForm.Free;
        LegalPickForm:=NIL;
      END;
    END
  ELSE
    BEGIN
      MatchFieldNo:=-1;
      MatchField:='';
      checkMatchbyKeyfield.caption:=Lang(3344);   //'&Match record by keyfield
    END;
end;

procedure TCopyDatafileForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FieldList.Free;
end;

end.
