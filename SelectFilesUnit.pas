unit SelectFilesUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TSelectFilesForm = class(TForm)
    Panel1: TPanel;
    File1Label: TStaticText;
    File1Edit: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    File2Label: TStaticText;
    File2Edit: TEdit;
    FindFile1: TBitBtn;
    FindFile2: TBitBtn;
    procedure SpeedButton1Click(Sender: TObject);
    procedure File1EditChange(Sender: TObject);
    procedure FindFile2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Ext1,Ext2:String;
    File1MustExist,File2MustExist:Boolean;   //default True
    WarnOverwrite1,WarnOverwrite2:Boolean;   //default false
    UpDateFile2Text:Boolean;                 //default false
    IgnoreExt1,IgnoreExt2: Boolean;          //default false
    OldfileLabel: String;
  end;

var
  SelectFilesForm: TSelectFilesForm;

implementation

USES
  EPITypes;

{$R *.DFM}

VAR
  DontChange:Boolean;

procedure TSelectFilesForm.SpeedButton1Click(Sender: TObject);
begin
  IF Ext1='.qes' THEN OpenDialog1.FilterIndex:=1
  ELSE IF Ext1='.rec' THEN OpenDialog1.FilterIndex:=2
  ELSE IF Ext1='.dta' THEN
    BEGIN
      OpenDialog1.Filter:=Lang(2120)+'|*.dta|'+Lang(2112)+'|*.*';  //'Stata datafile  (*.dta)|*.dta|All files  (*.*)|*.*';
      OpenDialog1.DefaultExt:='dta';
      OpenDialog1.FilterIndex:=1;
    END
  ELSE OpenDialog1.FilterIndex:=3;

  IF File1MustExist THEN OpenDialog1.Options:=OpenDialog1.Options+[ofFileMustExist]
  ELSE OpenDialog1.Options:=OpenDialog1.Options-[ofFileMustExist];
  OpenDialog1.InitialDir:=ExtractFileDir(File1Edit.Text);
  OpenDialog1.FileName:=ExtractFileName(File1Edit.Text);
  IF OpenDialog1.Execute THEN File1Edit.Text:=OpenDialog1.FileName;
  IF Ext1='.dta' THEN
    OpenDialog1.Filter:=Lang(2102)+'|*.qes|'+Lang(2104)+'|*.rec|'+Lang(2112)+'|*.*';
end;

procedure TSelectFilesForm.File1EditChange(Sender: TObject);
begin
  IF (UpDateFile2Text) AND (NOT DontChange) THEN
    BEGIN
      IF (ExtractFileExt(File1Edit.Text)=Ext1) or (ExtractFileExt(File1Edit.text)='')
      THEN file2Edit.Text:=ChangeFileExt(File1Edit.Text,Ext2);
    END;
end;


procedure TSelectFilesForm.FindFile2Click(Sender: TObject);
begin
  IF Ext2='.qes' THEN OpenDialog1.FilterIndex:=1
  ELSE IF Ext2='.rec' THEN OpenDialog1.FilterIndex:=2
  ELSE OpenDialog1.FilterIndex:=3;
  IF File2MustExist THEN OpenDialog1.Options:=OpenDialog1.Options+[ofFileMustExist]
  ELSE OpenDialog1.Options:=OpenDialog1.Options-[ofFileMustExist];
  OpenDialog1.InitialDir:=ExtractFileDir(File2Edit.Text);
  OpenDialog1.FileName:=ExtractFileName(File2Edit.Text);
  IF OpenDialog1.Execute THEN File2Edit.Text:=OpenDialog1.FileName;
end;

procedure TSelectFilesForm.FormCloseQuery(Sender: TObject;  var CanClose: Boolean);
VAR
  f:TextFile;
  s: String;
  n:Integer;
begin
  CanClose:=True;
  OldfileLabel:='';
  IF ModalResult=mrOK THEN
    BEGIN
      DontChange:=True;
      IF (trim(File1Edit.Text)<>'') AND (ExtractFileExt(File1Edit.Text)='')
      THEN File1Edit.Text:=ChangefileExt(File1Edit.Text,Ext1);

      IF (trim(File2Edit.Text)<>'') AND (ExtractFileExt(File2Edit.text)='')
      THEN File2Edit.Text:=ChangeFileExt(File2Edit.Text,Ext2);
      DontChange:=False;

      IF (File1MustExist) AND (NOT FileExists(File1Edit.Text)) THEN
        BEGIN
          ErrorMsg(Format(Lang(22126),[File1Edit.Text]));  //The file %s does not exist.
          CanClose:=FALSE;
          Exit;
        END;
      IF (File2MustExist) AND (NOT FileExists(File2Edit.Text)) THEN
        BEGIN
          ErrorMsg(Format(Lang(22126),[File2Edit.Text]));  //The file %s does not exist.
          CanClose:=FALSE;
          Exit;
        END;
      IF File1Edit.Text='' THEN
        BEGIN
          IF Ext1='.qes' THEN ErrorMsg(Lang(22338))    //'Please enter a name for the QES-file'
          ELSE IF Ext1='.rec' THEN ErrorMsg(Lang(20132))   //'Please enter a filename for the first datafile.'
          ELSE ErrorMsg(Lang(20136));   //'Please enter a name for the first file'
          CanClose:=False;
          Exit;
        END;
      IF File2Edit.Text='' THEN
        BEGIN
          IF (Ext1='.rec') AND (Ext2='.rec') THEN ErrorMsg(Lang(20134))    //'Please enter a filename for the second datafile.'
          ELSE IF (Ext1='.qes') AND (Ext2='.rec') THEN ErrorMsg(Lang(22336))   //'Please enter a filename for the datafile.'
          ELSE ErrorMsg(Lang(20138));   //'Please enter a name for the second file'
          CanClose:=False;
          Exit;
        END;
      IF (NOT IgnoreExt1) AND (AnsiUpperCase(ExtractFileExt(File1Edit.Text))<>AnsiUpperCase(Ext1)) THEN
        BEGIN
          ErrorMsg(Format(Lang(20140),[AnsiUpperCase(Ext1)]));   //'The first file must have the extension %s'
          CanClose:=False;
          Exit;
        END;
      IF (NOT IgnoreExt2) AND (AnsiUpperCase(ExtractFileExt(File2Edit.Text))<>AnsiUpperCase(Ext2)) THEN
        BEGIN
          ErrorMsg(Format(Lang(20142),[AnsiUpperCase(Ext2)]));   //'The second file must have the extension %s'
          CanClose:=False;
          Exit;
        END;
      IF (FileExists(File1Edit.Text)) AND (WarnOverwrite1) THEN
        BEGIN
          IF WarningDlg(Format(Lang(21500),[File1Edit.Text]))=mrCancel THEN CanClose:=False   //21500=A file with name %s already exists.~~Overwrite existing file?
          ELSE  //Users wants to overwrite existing datafile
            BEGIN
              IF WarningDlg(Format(Lang(20444),[File1Edit.Text])   //'Datafile %s
              +' '+Lang(20450)+#13#13+Lang(20452))=mrCancel   //'will be deleted!'    //'Are you sure?'
              THEN CanClose:=False
              ELSE DeleteFile(File1Edit.Text);
            END;
        END;
      IF (FileExists(File2Edit.Text)) AND (WarnOverwrite2) THEN
        BEGIN
          IF WarningDlg(Format(Lang(20444),[File2Edit.Text])+' '+Lang(20446)   //'Datafile %s'  'already exists.'
          +#13#13+Lang(20448))=mrCancel THEN CanClose:=False    //'Overwrite existing file?'
          ELSE  //Users wants to overwrite existing datafile
            BEGIN
              IF WarningDlg(Format(Lang(20444),[File2Edit.Text])   //'Datafile %s
              +' '+Lang(20450)+#13#13+Lang(20452))=mrCancel   //'will be deleted!'    //'Are you sure?'
              THEN CanClose:=False
              ELSE
                BEGIN
                  //retrieve the filelabel of the old datafile
                  TRY
                    AssignFile(F,File2Edit.Text);
                    Reset(F);
                    ReadLn(F,s);  //read first line
                    n:=Pos('FILELABEL: ',AnsiUpperCase(s));
                    IF n<>0 THEN OldfileLabel:=Copy(s,n+Length('FILELABEL: '),Length(s));
                  FINALLY
                    CloseFile(F);
                  END;
                  DeleteFile(File2Edit.Text);
                END;
            END;
        END;
    END;   //If modalresult=mrOK
end;

procedure TSelectFilesForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  dontChange:=False;

  Ext1:='';
  Ext2:='';
  File1MustExist:=True;
  File2MustExist:=True;
  WarnOverwrite1:=False;
  WarnOverwrite2:=False;
  UpDateFile2Text:=False;
  IgnoreExt1:=False;
  IgnoreExt2:=False;
  OpenDialog1.Filter:=Lang(2102)+'|*.qes|'+
                      Lang(2104)+'|*.rec|'+
                      Lang(2106)+'|*.chk|'+
                      Lang(2112)+'|*.*';

    {2102=EpiData Questionnaire (*.qes)
    2104=EpiData Datafile (*.rec)
    2106=EpiData Checkfile  (*.chk)
    2112=All (*.*)}
end;

end.
