unit ImportUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,Math, EpiTypes;

type
  TImportForm = class(TForm)
    Label1: TLabel;
    ImportFileEdit: TEdit;
    DatafileEdit: TEdit;
    Label2: TLabel;
    QESFileLabel: TLabel;
    QesFileEdit: TEdit;
    TextFileGroup: TGroupBox;
    DelFormatCheck: TRadioButton;
    FixFormatCheck: TRadioButton;
    Label4: TLabel;
    DateFormatCombo: TComboBox;
    DelimiterCombo: TComboBox;
    DelimiterLabel: TLabel;
    PrefixedZeroCheck: TCheckBox;
    YearWith4digitsCheck: TCheckBox;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    FindImportFileBtn: TBitBtn;
    FindRecFileBtn: TBitBtn;
    FindQesFileBtn: TBitBtn;
    Bevel1: TBevel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    TextQuotesCheck: TRadioButton;
    AllQuotesCheck: TRadioButton;
    NoQuotesCheck: TRadioButton;
    DateSepLabel: TLabel;
    DateSepEdit: TEdit;
    Bevel2: TBevel;
    IgnoreFirstLineCheck: TCheckBox;
    DBaseGroup: TGroupBox;
    EuDateFormatCheck: TRadioButton;
    USDateFormatcheck: TRadioButton;
    Label5: TLabel;
    YMDDateFormatcheck: TRadioButton;
    procedure DelFormatCheckClick(Sender: TObject);
    procedure FixFormatCheckClick(Sender: TObject);
    procedure ImportFileEditExit(Sender: TObject);
    procedure DelimiterComboChange(Sender: TObject);
    procedure DelimiterKeyPress(Sender: TObject; var Key: Char);
    procedure FindImportFileBtnClick(Sender: TObject);
    procedure FindRecFileBtnClick(Sender: TObject);
    procedure FindQesFileBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImportForm: TImportForm;
  ImportType: TExporttypes;


Procedure ImportDatafile;

implementation

uses MainUnit, InputFormUnit, FileUnit, EdUnit, SelectFilesUnit, PeekCheckUnit, ProgressUnit;

{$R *.DFM}



procedure TImportForm.DelFormatCheckClick(Sender: TObject);
begin
  FixFormatCheck.Checked:=NOT DelFormatCheck.Checked;
  DelimiterCombo.Enabled:=DelFormatCheck.Checked;
  TextQuotesCheck.Enabled:=DelFormatCheck.Checked;
  AllQuotesCheck.Enabled:=DelFormatCheck.Checked;
  NoQuotesCheck.Enabled:=DelFormatCheck.Checked;
  DelimiterLabel.Enabled:=DelFormatCheck.Checked;
end;

procedure TImportForm.FixFormatCheckClick(Sender: TObject);
begin
  DelFormatCheck.Checked:=NOT FixFormatCheck.Checked;
  DelimiterCombo.Enabled:=DelFormatCheck.Checked;
  TextQuotesCheck.Enabled:=DelFormatCheck.Checked;
  AllQuotesCheck.Enabled:=DelFormatCheck.Checked;
  NoQuotesCheck.Enabled:=DelFormatCheck.Checked;  
  DelimiterLabel.Enabled:=DelFormatCheck.Checked;  
end;

procedure TImportForm.ImportFileEditExit(Sender: TObject);
begin
  IF trim(ImportfileEdit.Text)<>'' THEN
    BEGIN
      DataFileEdit.Text:=ChangeFileExt(ImportfileEdit.Text,'.rec');
      IF QesFileEdit.Enabled THEN QESFileEdit.Text:=ChangeFileExt(ImportFileEdit.Text,'.qes');
    END;
end;

procedure TImportForm.DelimiterComboChange(Sender: TObject);
begin
  IF DelimiterCombo.Items[DelimiterCombo.ItemIndex]='Other' THEN     //***
    BEGIN
      WITH CreateMessageDialog(Lang(22382),mtCustom, []) do  //'Press a key to enter the field separator character'
        try
          onKeyPress:=DelimiterKeyPress;
          IF ShowModal=mrOK THEN
            BEGIN
              DelimiterCombo.Items.Add(' '+CHR(Tag)+' ');
              DelimiterCombo.ItemIndex:=DelimiterCombo.Items.Count-1;
            END
          ELSE DelimiterCombo.ItemIndex:=0;
        finally
          Free;
        end;
    END;
end;

procedure TImportForm.DelimiterKeyPress(Sender: TObject; var Key: Char);
BEGIN
  IF Key=#27 THEN TForm(Sender).ModalResult:=mrCancel
  ELSE
    BEGIN
      TForm(Sender).Tag:=ORD(Key);
      TForm(Sender).ModalResult:=mrOK;
    END;
END;


procedure TImportForm.FindImportFileBtnClick(Sender: TObject);
VAR
  ExpExtension: String;
begin
  CASE ImportType OF
    etTxt: BEGIN
             OpenDialog1.Filter:=Lang(2114)+'|*.txt|'+Lang(2112)+'|*.*';   //'Textfile  (*.txt)|*.txt|All files  (*.*)|*.*'
             OpenDialog1.DefaultExt:='txt';
             ExpExtension:='.TXT';
           END;
    etDBase: BEGIN
               OpenDialog1.Filter:=Lang(2116)+'|*.dbf|'+Lang(2112)+'|*.*';  //'dBase III file  (*.dbf)|*.dbf|All files  (*.*)|*.*';
               OpenDialog1.DefaultExt:='dbf';
               ExpExtension:='.DBF';
             END;
    etXLS:   BEGIN
               OpenDialog1.Filter:=Lang(2118)+'|*.xls|'+Lang(2112)+'|*.*';  //'Excel file  (*.xls)|*.xls|All files  (*.*)|*.*';
               OpenDialog1.DefaultExt:='xls';
               ExpExtension:='.XLS';
             END;
    etStata: BEGIN
               OpenDialog1.Filter:=Lang(2120)+'|*.dta|'+Lang(2112)+'|*.*';  //'Stata datafile  (*.dta)|*.dta|All files  (*.*)|*.*';
               OpenDialog1.DefaultExt:='dta';
               ExpExtension:='.DTA';
             END;
  END;   //Case
  OpenDialog1.FilterIndex:=1;    //set filter to exportfiletype-extension
  OpenDialog1.Options:=OpenDialog1.Options-[ofFileMustExist];
  IF AnsiUpperCase(ExtractFileExt(ImportFileEdit.Text))=ExpExtension THEN
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(ImportFileEdit.Text);
      OpenDialog1.FileName:=ExtractFileName(ImportFileEdit.Text);
    END
  ELSE OpenDialog1.Filename:='';
  IF OpenDialog1.Execute THEN
    BEGIN
      ImportFileEdit.Text:=OpenDialog1.Filename;
      ImportFileEditExit(Sender);
      DatafileEdit.SetFocus;
    END;
end;

procedure TImportForm.FindRecFileBtnClick(Sender: TObject);
begin
  OpenDialog1.Filter:=Lang(2104)+'|*.rec|'+Lang(2112)+'*.*';  //set filter to REC and All files
  OpenDialog1.FilterIndex:=1;    //set filter to *.rec
  OpenDialog1.Options:=OpenDialog1.Options-[ofFileMustExist];
  IF AnsiUpperCase(ExtractFileExt(DataFileEdit.Text))='.REC' THEN
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(DataFileEdit.Text);
      OpenDialog1.FileName:=ExtractFileName(DataFileEdit.Text);
    END
  ELSE OpenDialog1.Filename:='';
  IF OpenDialog1.Execute THEN
    DataFileEdit.Text:=OpenDialog1.Filename;
end;

procedure TImportForm.FindQesFileBtnClick(Sender: TObject);
begin
  OpenDialog1.Filter:=Lang(2102)+'|*.qes|'+Lang(2112)+'*.*';  //set filter to QES and All files
  OpenDialog1.FilterIndex:=1;    //set filter to QES filetype
  OpenDialog1.Options:=OpenDialog1.Options-[ofFileMustExist];
  IF AnsiUpperCase(ExtractFileExt(QesFileEdit.Text))='.QES' THEN
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(QesFileEdit.Text);
      OpenDialog1.FileName:=ExtractFileName(QesFileEdit.Text);
    END
  ELSE OpenDialog1.Filename:='';
  IF OpenDialog1.Execute THEN
    QesFileEdit.Text:=OpenDialog1.Filename;
end;


procedure TImportForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  CASE ImportType OF
    etTxt:    Self.Caption:=Lang(23900);   //'Import from text-file'
    etDBase:  Self.Caption:=Lang(23902);   //'Import from dBase'
    etStata:  Self.Caption:=Lang(23904);   //'Import from Stata'
  END;  //case
  DelimiterCombo.ItemIndex:=0;
  DateFormatCombo.ItemIndex:=0;
end;


procedure TImportForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  IF ModalResult=mrOK THEN
    BEGIN
      IF ExtractFileExt(DataFileEdit.Text)='' THEN DataFileEdit.Text:=ChangeFileExt(DataFileEdit.Text,'.rec');

      IF ExtractFileExt(DatafileEdit.Text)<>'.rec' THEN
        BEGIN
          eDlg(Lang(23906),mtWarning,[mbOK],0);  //'The datafile to import to must have the extension .REC'
          CanClose:=False;
        END;

      IF FileExists(DataFileEdit.Text)
      THEN IF WarningDlg(Format(Lang(20444),[DataFileEdit.Text])+' '+Lang(20446)   //'Datafile %s'  'already exists.'
      +#13#13+Lang(20448))=mrCancel THEN CanClose:=False;    //'Overwrite existing file?'

      IF (CanClose) AND (NOT FileExists(ImportFileEdit.Text)) THEN
        BEGIN
          eDlg(Format(Lang(22126),[ImportFileEdit.Text]),mtWarning,[mbOK],0);  //22126=The file %s does not exist.
          CanClose:=False;
        END;

      IF (CanClose) AND (QesFileEdit.Enabled) AND (QesFileEdit.Visible)
      AND (NOT FileExists(QESFileEdit.Text)) THEN
        BEGIN
          eDlg(Format(Lang(22126),[QESFileEdit.Text]),mtWarning,[mbOK],0);  //22126=The file %s does not exist.
          CanClose:=False;
        END;
    END  //if mrOK
  ELSE
    BEGIN
      IF ModalResult<>mrCancel THEN ModalResult:=mrCancel;
      CanClose:=True;
    END;
end;



Procedure ImportDatafile;
VAR
  QESLines: TStringList;
  Mess,s,s2: String;
  df: PDataFileInfo;
  tmpBool,ok,IsInclosed,PreZero,Y4dig: Boolean;
  F,dfFile: Textfile;
  CurLine,CurField,n: Integer;
  AField: PeField;
  DelChar: String;
  tmpDate: TDateTime;
  WindowList: Pointer;


  Function HandleDates(VAR ds: String; Ftype: TFelttyper):Boolean;
 {Handles dates in relation with text-file import}
  VAR
    n:Integer;
    d,m,y,t: Word;
    DateF,tds,sepChar: String;
  BEGIN
    Result:=False;
    tds:=ds;
    Y4dig:=ImportForm.YearWith4digitsCheck.Checked;
    TRY
      SepChar:=Importform.DateSepEdit.Text;
      DateF:=ImportForm.DateFormatCombo.Items[ImportForm.DateFormatCombo.ItemIndex];
      IF SepChar<>'' THEN
        BEGIN
          //Get first number
          n:=Pos(SepChar,tds);
          IF n=0 THEN Exit;
          d:=StrToInt(Copy(tds,1,n-1));
          Delete(tds,1,n);
          //Get second number
          n:=Pos(SepChar,tds);
          IF n=0 THEN Exit;
          m:=StrToInt(Copy(tds,1,n-1));
          Delete(tds,1,n);
          //Get third number
          y:=StrToInt(tds);

          IF DateF='mdy' THEN
            BEGIN
              t:=d;
              d:=m;
              m:=t;
            END
          ELSE IF DateF='ymd' THEN
            BEGIN
              t:=d;
              d:=y;
              y:=t;
            END;
        END
      ELSE
        BEGIN  //No separator
          PreZero:=ImportForm.PrefixedZeroCheck.Checked;
          IF PreZero THEN
            BEGIN
              IF (Y4dig) AND (Length(tds)<>8) THEN Exit
              ELSE IF (NOT Y4dig) AND (Length(tds)<>6) THEN Exit;
              d:=StrToInt(Copy(tds,1,2));
              m:=StrToInt(Copy(tds,3,2));
              y:=StrToInt(Copy(tds,5,4));
            END
          ELSE
            BEGIN
              IF (DateF<>'ymd') AND ((Y4dig) AND (Length(tds)=7))
              OR ((NOT Y4dig) AND (Length(tds)=5)) THEN tds:='0'+tds;
              IF (Y4dig) ANd (Length(tds)<>8) THEN Exit;
              IF (NOT Y4dig) AND (Length(tds)<>6) THEN Exit;

              IF (DateF='dmy') OR (DateF='mdy') THEN
                BEGIN
                  d:=StrToInt(Copy(tds,1,2));
                  m:=StrToInt(Copy(tds,3,2));
                  y:=StrToInt(Copy(tds,5,4));
                  IF DateF='mdy' THEN
                    BEGIN
                      t:=d;
                      d:=m;
                      m:=t;
                    END;
                END
              ELSE
                BEGIN
                  //format is ymd
                  IF Y4dig THEN
                    BEGIN
                      y:=StrToInt(Copy(tds,1,4));
                      m:=StrToInt(Copy(tds,5,2));
                      d:=StrToInt(Copy(tds,7,2));
                    END
                  ELSE
                    BEGIN
                      y:=StrToInt(Copy(tds,1,2));
                      m:=StrToInt(Copy(tds,3,2));
                      d:=StrToInt(Copy(tds,5,2));
                    END;
                END;  //if format is ymd
            END;  //if not preZero
        END;  //if not separator

      IF Y4dig THEN
        BEGIN
          IF y<1000 THEN Exit
        END
      ELSE
        BEGIN
          //only 2 digit years
          IF (y>=0) AND (y<50) THEN y:=y+2000
          ELSE IF (y>=50) AND (y<100) THEN y:=y+1900
          ELSE Exit;
        END;

      IF (m>12) OR (m<1) THEN Exit;
      IF (d>DaysInMonth[m]) THEN Exit;
      IF (d=29) AND (m=2) THEN IF NOT IsLeapYear(y) THEN Exit;

      tmpDate:=EncodeDate(y,m,d);
      ds:=mibDateToStr(tmpDate,FType);
      Result:=True;

    EXCEPT
      ds:='';
      Result:=False;
    END;
  END;

  Procedure ImportdBase;
  VAR
    dBaseFilename,RecFilename: TFilename;
    dBaseFile: TFileStream;
    buff: Array[0..255] OF Byte;
    NRec,CurRec,CurField,n2: Integer;
    HSize,Rsize: Word;
    AField: PeField;
    c: Char;
    ok:Boolean;
    TempName: String;
  BEGIN
    TRY
      dBaseFile:=NIL;
      df:=NIL;
      ProgressForm:=NIL;
      ImportForm:=TImportForm.Create(MainForm);
      WITH ImportForm DO
        BEGIN
          TextFileGroup.visible:=False;
          dBaseGroup.Left:=(ClientWidth DIV 2) - (dBaseGroup.Width DIV 2);
          dBaseGroup.Top:=115;
          OKBtn.Top:=265;
          CancelBtn.Top:=265;
          Height:=325;
          QESFileLabel.Visible:=False;
          QESFileEdit.Visible:=False;
          FindQESFileBtn.Visible:=False;
          IF ShowModal<>mrOK THEN Exit;
          dBaseFilename:=ImportFileEdit.Text;
          RecFilename:=DatafileEdit.Text;
        END;  //with
      Screen.Cursor:=crHourGlass;
      dBaseFile:=TFileStream.Create(dBaseFilename,fmOpenRead);
      dBaseFile.Position:=0;
      dBaseFile.Read(buff,1);
      IF (buff[0]<>3) AND (buff[0]<>4) THEN
        BEGIN
          ErrorMsg(Format(Lang(23908)+#13+    //23908=%s is not a plain dBase III or IV file.
          Lang(23910),[dBaseFilename]));     //23910=Import terminates
          Exit;
        END;
      dBaseFile.Position:=4;
      dBaseFile.Read(NRec,4);
      dBaseFile.Read(HSize,2);
      dBaseFile.Read(RSize,2);
{      IF (dBaseFile.Size<>(NRec*RSize)+HSize) AND (dBaseFile.Size<>(NRec*RSize)+HSize+1) THEN
        BEGIN
          ErrorMsg(Format(Lang(23912)+#13+   //'Incorrect format of %s'
          Lang(23910),[dBaseFilename]));   //'Import terminates'
          Exit;
        END;}

      IF NOT GetDataFilePointer(df) THEN Exit;
      df^.RECFilename:=RECFilename;
      {Read field descriptors}
      dBaseFile.Position:=32;
      REPEAT
        dBaseFile.Read(buff,32);
        IF buff[0]<>$0D THEN
          BEGIN
            New(eField);
            n:=0;
            TempName:='          ';
            WHILE (buff[n]<>0) AND (n<12) DO
              BEGIN
                TempName[n+1]:=Chr(buff[n]);
                INC(n);
              END;
            TempName:=trim(TempName);
            IF Length(TempName)>FieldnameLen THEN TempName:=Copy(TempName,1,FieldnameLen);
            IF NOT NameIsUnique(TempName,df,FieldnameLen) THEN REPEAT UNTIL NameIsUnique(TempName,df,FieldnameLen);
            CASE FieldNameCase OF
              fcUpper: TempName:=AnsiUpperCase(TempName);
              fcLower: Tempname:=AnsiLowerCase(TempName);
            END;  //case
            eField^.FName:=trim(TempName);
            c:=Chr(buff[11]);
            IF c='C' THEN
              BEGIN
                eField^.Felttype:=ftAlfa;
                eField^.FLength:=buff[16];
                eField^.FieldN:=buff[16];
                IF eField^.FLength>80 THEN
                  BEGIN
                    ErrorMsg(Format(Lang(23914)+#13+  //'The variable %s is a text variable with more than 80 characters.'
                    Lang(23916),[eField^.FName]));   //'This variable cannot be imported to EpiData.'
                    Dispose(eField);
                    Exit;
                  END;
              END
            ELSE IF c='D' THEN
              BEGIN
                IF ImportForm.EuDateFormatCheck.Checked THEN eField^.Felttype:=ftEuroDate
                ELSE IF ImportForm.YMDDateFormatcheck.Checked THEN eField^.Felttype:=ftYMDDate 
                ELSE eField^.Felttype:=ftDate;
                eField^.FLength:=10;
                eField^.FieldN:=8;
              END
            ELSE IF (c='F') OR (c='N') THEN
              BEGIN
                IF (buff[17]=0) AND (buff[16]<5) THEN eField^.Felttype:=ftInteger
                ELSE eField^.Felttype:=ftFloat;
                eField^.FieldN:=buff[16];
                IF buff[16]>16 THEN eField^.FLength:=16 ELSE eField^.FLength:=buff[16];
                eField^.FNumDecimals:=buff[17];
              END
            ELSE IF c='L' THEN
              BEGIN
                eField^.FeltType:=ftBoolean;
                eField^.FLength:=1;
                eField^.FieldN:=1;
              END
            ELSE
              BEGIN
                ErrorMsg(Format(Lang(23918),[eField^.FName,c]));   //'The variable %s is of the type %s.~This variabletype is not supported by EpiData.'
                Dispose(eField);
                Exit;
              END;
            ResetCheckProperties(eField);
            WITH eField^ DO
              BEGIN
                FQuestion:=FName;
                FQuestX:=1;
                FQuestY:=df^.FieldList.Count+1;
                FFieldX:=12;
                FFieldY:=FQuestY;
                FOriginalQuest:=FQuestion;
              END;  //with
            df^.FieldList.Add(eField);
          END;
      UNTIL buff[0]=$0D;
      df^.NumFields:=df^.FieldList.Count;
      df^.EpiInfoFieldNaming:=True;
      IF NOT PeekCreateDatafile(df) THEN
        BEGIN
          ErrorMsg(Format(Lang(20416)+#13+  //20416=The datafile with the name %s cannot be created.
          Lang(23910),[df^.RECFilename]));   //'Import terminates'
          Exit;
        END;

      {Read data}
      //AssignFile(df^.DatFile,df^.RECFilename);
      //Reset(df^.DatFile);
      TRY
        UserAborts:=False;
        ProgressForm:=TProgressForm.Create(MainForm);
        ProgressForm.Caption:=Lang(23902);  //'Import from dBase'
        ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
        ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
        ProgressForm.pBar.Max:=NRec;
        ProgressForm.pBar.Position:=0;
        WindowList:=DisableTaskWindows(ProgressForm.Handle);
        ProgressForm.Show;

        AssignFile(F,df^.RECFilename);
        Append(F);
        FOR CurRec:=1 TO NRec DO
          BEGIN
            IF ProgressStep(NRec,CurRec) THEN
              BEGIN
                ProgressForm.pBar.Position:=CurRec;
                ProgressForm.pLabel.Caption:=Format(' '+Lang(23920),[CurRec,NRec]);  //'Importing record no. %d of %d'
                Application.ProcessMessages;
              END;
            dBaseFile.Position:=HSize+((RSize)*(CurRec-1));
            dBaseFile.Read(buff,1);
            IF Chr(Buff[1])='*' THEN df^.CurRecDeleted:=True ELSE df^.CurRecDeleted:=False;
            FOR CurField:=0 TO df^.FieldList.Count-1 DO
              BEGIN
                AField:=PeField(df^.FieldList.Items[Curfield]);
                n:=dBaseFile.Read(buff,AField^.FieldN);
                s:=cFill(' ',AField^.FieldN);
                FOR n2:=1 TO n DO s[n2]:=CHR(Buff[n2-1]);
                ok:=True;
                IF (AField^.FeltType in [ftInteger,ftFloat,ftIDNUM,ftBoolean]) AND (s[1]='*')
                THEN s:=cFill(' ',AField^.FieldN);
                IF trim(s)<>'' THEN
                  BEGIN
                    CASE AField^.Felttype OF
                      //dates are yyyymmdd in dBase
                      ftDate:
                        BEGIN
                          s:=Copy(s,5,2)+'/'+Copy(s,7,2)+'/'+Copy(s,1,4);
                          ok:=mibIsDate(s,AField^.Felttype);
                        END;
                      ftEuroDate:
                        BEGIN
                          s:=Copy(s,7,2)+'/'+Copy(s,5,2)+'/'+Copy(s,1,4);
                          ok:=mibIsDate(s,AField^.Felttype);
                        END;
                      ftYMDDate:          
                        BEGIN
                          s:=Copy(s,1,4)+'/'+Copy(s,5,2)+'/'+Copy(s,7,2);
                          ok:=mibIsDate(s,Afield^.Felttype);
                        END;
                      ftInteger: ok:=IsInteger(s);
                      ftFloat:   ok:=IsFloat(s);
                      ftBoolean:
                        BEGIN
                          C:=UpCase(s[1]);
                          ok:=(C in ['Y','N','T','F','?']);
                          IF ok THEN
                            BEGIN
                              IF C='T' THEN s:='Y'
                              ELSE IF C='F' THEN s:='N'
                              ELSE IF C='Y' THEN s:='Y'
                              ELSE IF C='N' THEN s:='N'
                              ELSE IF C='?' THEN s:=' '
                            END;
                        END;  //case ftBoolean
                    END;  //case
                  END;  //if s<>''
                IF Length(trim(s))>AField^.FLength THEN
                  BEGIN
                    ErrorMsg(Format(Lang(23966)+   //'Error in record %d, variable %s.~The data ('%s') is too wide to fit in the field.'
                    #13#13+Lang(23910),[CurRec,AField^.FName,trim(s)]));   //'Import terminates.'
                    Exit;
                  END;
                IF ok THEN AField^.FFieldText:=trim(s)
                ELSE
                  BEGIN
                    ErrorMsg(Format(Lang(23968)+   //'Error in record %d, variable %s.~The data ('%s') is not compatible with the variabletype'
                      #13#13+Lang(23910),     //'Import terminates.'
                      [CurRec,AField^.FName,s])); 
                    Exit;
                  END;  //if not ok
              END;  //for CurField
            //peWriteRecord(df,NewRecord);
            WriteNextRecord(df,F);

            IF UserAborts THEN
              BEGIN
                IF eDlg(Lang(23932),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort import?'
                THEN
                  BEGIN
                    CloseFile(F);
                    tmpBool:=DeleteFile(df^.RECFilename);
                    Exit;
                  END
                ELSE UserAborts:=False;
              END;  //if UserAborts

          END;  //for CurRec

      FINALLY
        EnableTaskWindows(WindowList);
        ProgressForm.Free;
      END;  //try..Finally

      Screen.Cursor:=crDefault;
      s:=Format(Lang(23970),[dBaseFilename]);   //'Datafile created by importing dBase file %s'
      AddToNotesFile(df,s);
      eDlg(Format(Lang(23972),[dBaseFilename,RecFilename,df^.NumRecords]),  //'The dBase file %s har been imported~to %s~~%d records were imported'
      mtInformation,[mbOK],0); 
      AddToRecentFiles(RecFilename);
    FINALLY
      Screen.Cursor:=crDefault;
      DisposeDatafilePointer(df);
      {$I-}
      CloseFile(F);
      n:=IOResult;
      {$I+}
      IF dBaseFile<>NIL THEN dBaseFile.Free;
      ImportForm.Free;
    END;  //try..finally

  END;  //procedure ImportdBase;


  Procedure ImportStata;
  VAR
    StataFile: TFileStream;
    StataFilename,RECFilename: TFilename;
    buff: Array[0..50000] OF Char;
    NumBuff: Array[0..7] OF Byte;
    typList: Array[0..800] OF Char;
    StataVersion: Byte;
    tmpSmallInt: SmallInt;
    SmallIntBuff: Array[0..1] OF Byte absolute tmpSmallInt;
    pByte: ^BYTE;
    pSmallInt: ^SmallInt;
    pShortInt: ^ShortInt;
    pWord: ^Word;
    pLongInt: ^LongInt;
    pDouble: ^Double;
    n,n2,n3,t, NameLength:Integer;
    LOHI,HasValueLabels:Boolean;
    HeaderSize,nVar,nObs,MaxVarLabel,MaxFNameWidth,CurRec,CurField: Integer;
    tmpByte:   Byte;
    tmpWord:   Word;
    tmpInt:    SmallInt;
    tmpShortInt: ShortInt;
    tmpLong:   LongInt;
    tmpSingle: Single;
    tmpDouble: Double;
    tmpS,tmpS2:      String;
    FirstLabelRec,NextLabelRec,tmpLabelRec: PLabelRec;
    FirstLabel:Boolean;
    ChkLin: TStringList;
    CutsDecimals,OkToCutDecimals: Boolean;
    ByteChar,intChar,LongChar,FloatChar,DoubleChar: Char;
    StrBaseNumber: Byte;
    MisVal: String;
    MisWidth: Integer;

    Function ReadByte(p: LongInt):shortInt;
    BEGIN
      New(pShortInt);
      pShortInt^:=0;
      Statafile.Position:=p;
      StataFile.Read(pShortInt^,1);
      Result:=pShortInt^;
      Dispose(pShortInt);
    END;

    Function ReadWord(p: LongInt):Word;
    VAR
      tmpValue: Word;
      tBuff: Array[0..1] OF Byte absolute tmpValue;
      tmpByte: Byte;
    BEGIN
      Statafile.Position:=p;
      StataFile.read(tBuff,2);
      IF NOT LOHI THEN
        BEGIN
          tmpByte:=tBuff[0];
          tBuff[0]:=tBuff[1];
          tBuff[1]:=tmpByte;
        END;
      Result:=tmpValue;
    END;

    Function ReadDbWord(p: LongInt):LongInt;
    VAR
      tmpValue: LongInt;
      tBuff: Array[0..3] OF byte absolute tmpValue;
      tmpByte: Byte;
    BEGIN
      StataFile.Position:=p;
      StataFile.Read(tBuff,4);
      IF NOT LOHI THEN
        BEGIN
          tmpByte:=tBuff[0];
          tBuff[0]:=tBuff[3];
          tBuff[3]:=tmpByte;
          tmpByte:=tBuff[1];
          tBuff[1]:=tBuff[2];
          tBuff[2]:=tmpByte;
        END;
      Result:=tmpValue;
    END;

    Function vltInteger(p: Integer):LongInt;
    VAR
      tmpValue: LongInt;
      tBuff: Array[0..3] OF Byte absolute tmpValue;
      vn: Integer;
      tmpByte: Byte;
    BEGIN
      MisVal:='';
      FOR vn:=0 TO 3 DO
        tBuff[vn]:=ORD(buff[p+vn]);
      IF NOT LOHI THEN
        BEGIN
          tmpByte:=tBuff[0];
          tBuff[0]:=tBuff[3];
          tBuff[3]:=tmpByte;
          tmpByte:=tBuff[1];
          tBuff[1]:=tBuff[2];
          tBuff[2]:=tmpByte;
        END;
      IF tmpValue>=$7fffffe5 THEN MisVal:='.';
      Result:=tmpValue;
    END;

    Function vltString(p: Integer):String;
    VAR
      vs: String;
      vn: Integer;
    BEGIN
      vn:=p;
      vs:='';
      WHILE (vn<SizeOf(buff)-1) AND (buff[vn]<>#0) DO
        BEGIN
          vs:=vs+buff[vn];
          INC(vn);
        END;
      Result:=vs;
    END;



    Function ReadSingle(p: LongInt):Single;
    VAR
      tmpValue: Single;
      b: Array[0..3] of byte absolute tmpValue;
      tmpByte: Byte;
    BEGIN
      MisVal:='';
      StataFile.Position:=p;
      StataFile.Read(b,4);
      IF NOT LOHI THEN
        BEGIN
          tmpByte:=b[0];
          b[0]:=b[3];
          b[3]:=tmpByte;
          tmpByte:=b[1];
          b[1]:=b[2];
          b[2]:=tmpByte;
        END;
      IF (b[0]=0) AND (b[1]=0) AND (b[2]=0) AND (b[3]=$7F) THEN MisVal:='.';
      IF (b[0]=0) AND (b[1]=8) AND (b[2]=0) AND (b[3]=$7F) THEN MisVal:='.a';
      IF (b[0]=0) AND (b[1]=$10) AND (b[2]=0) AND (b[3]=$7F) THEN MisVal:='.b';
      IF (b[0]=0) AND (b[1]=$18) AND (b[2]=0) AND (b[3]=$7F) THEN MisVal:='.c';
      Result:=tmpValue;
    END;

    Function ReadDouble(p: LongInt):Double;
    VAR
      tmpValue: Double;
      b: Array[0..7] of byte absolute tmpValue;
      tmpByte: Byte;
    BEGIN
      MisVal:='';
      StataFile.Position:=p;
      StataFile.Read(b,8);
      IF NOT LOHI THEN
        BEGIN
          tmpByte:=b[0];
          b[0]:=b[7];
          b[7]:=tmpByte;
          tmpByte:=b[1];
          b[1]:=b[6];
          b[6]:=tmpByte;
          tmpByte:=b[2];
          b[2]:=b[5];
          b[5]:=tmpByte;
          tmpByte:=b[3];
          b[3]:=b[4];
          b[4]:=tmpByte;
        END;
      IF (b[0]=0) AND (b[1]=0) AND (b[2]=0) AND (b[3]=0) AND (b[4]=0) AND (b[5]=0) AND (b[6]=$E0) AND (b[7]=$7F) THEN MisVal:='.';
      IF (b[0]=0) AND (b[1]=0) AND (b[2]=0) AND (b[3]=0) AND (b[4]=0) AND (b[5]=01) AND (b[6]=$E0) AND (b[7]=$7F) THEN MisVal:='.a';
      IF (b[0]=0) AND (b[1]=0) AND (b[2]=0) AND (b[3]=0) AND (b[4]=0) AND (b[5]=02) AND (b[6]=$E0) AND (b[7]=$7F) THEN MisVal:='.b';
      IF (b[0]=0) AND (b[1]=0) AND (b[2]=0) AND (b[3]=0) AND (b[4]=0) AND (b[5]=03) AND (b[6]=$E0) AND (b[7]=$7F) THEN MisVal:='.c';
      Result:=tmpValue;
    END;


  BEGIN   //importStata
    TRY
      SelectFilesform:=TSelectFilesForm.Create(MainForm);
      WITH SelectFilesForm DO
        BEGIN
          Caption:=Lang(23904);    //'Import from Stata'
          File1Label.Caption:=Lang(23974);  //'Name of Stata-file:'
          File2Label.Caption:=Lang(23976);  //'Import to:'
          Ext1:='.dta';
          Ext2:='.rec';
          File2MustExist:=False;
          WarnOverWrite2:=True;
          UpdateFile2Text:=True;
          IF LastSelectFilestype=sfImportStata THEN
            BEGIN
              File1Edit.Text:=LastSelectFile1;
              File2Edit.Text:=LastSelectFile2;
            END;
          IF ShowModal<>mrOK THEN Exit;
          LastSelectFilestype:=sfImportStata;
          LastSelectFile1:=File1Edit.Text;
          LastSelectFile2:=File2Edit.Text;
          StataFilename:=File1Edit.Text;
          RECFilename:=File2Edit.Text;
        END;  //with
    FINALLY
      SelectFilesForm.Free;
    END;  //try..finally

    TRY
      Screen.Cursor:=crHourGlass;
      df:=NIL;
      StataFile:=NIL;
      Statafile:=TFileStream.Create(StataFilename,fmOpenRead);
      IF NOT GetDatafilePointer(df) THEN Exit;

      df^.EpiInfoFieldNaming:=False;
      df^.RECFilename:=RECFilename;

      StataFile.Position:=0;
      StataFile.Read(NumBuff,3);
      IF NumBuff[0]=$69 THEN
        BEGIN
          HeaderSize:=60;
          StataVersion:=4;
        END
      ELSE IF NumBuff[0]=$6C THEN
        BEGIN
          HeaderSize:=109;
          StataVersion:=6;
        END
      ELSE IF NumBuff[0]=$6E THEN
        BEGIN
          HeaderSize:=109;
          StataVersion:=7;
        END
      ELSE IF NumBuff[0]=$71 THEN   //&&
        BEGIN
          HeaderSize:=109;
          StataVersion:=8;
        END
      ELSE
        BEGIN
          ErrorMsg(Lang(23978));  //'Unknown version of Stata-file'
          Exit;
        END;

      IF NumBuff[1]=1 THEN LOHI:=False
      ELSE IF NumBuff[1]=2 THEN LOHI:=True
      ELSE
        BEGIN
          ErrorMsg(Lang(23980));  //'Incorrect format of stata-file'
          Exit;
        END;

      IF NumBuff[2]<>1 THEN
        BEGIN
          ErrorMsg(Lang(23980));  //'Incorrect format of stata-file'
          Exit;
        END;

      nVar:=ReadWord(4);
      IF nVar>800 THEN
        BEGIN
          ErrorMsg(Format(Lang(23982),[nVar]));  //'The stata-file contains %d variables.~A maximum of 800 variables can be imported.'
          Exit;
        END;

      df^.NumFields:=nVar;
      FOR n:=1 TO nVar DO
        BEGIN
          New(eField);
          ResetCheckProperties(eField);
          WITH eField^ DO
            BEGIN
              FQuestion:='';
              FOriginalQuest:='';
              FLength:=0;
              FNumDecimals:=0;
              FVariableLabel:='';
              FFieldX:=0;
              FFieldY:=n;
              FQuestX:=1;
              FQuestY:=n;
              FName:='          ';
            END;
          df^.FieldList.Add(eField);
        END;  //for N


      nObs:=ReadDbWord(6);
      FillChar(buff,SizeOf(buff),0);
      StataFile.Position:=10;
      IF StataVersion=4 THEN StataFile.Read(buff,32) ELSE StataFile.Read(buff,81);
      df^.FileLabel:=StrPas(buff);

      {Read typlist - the variable's types}
      IF StataVersion=8 THEN  //&&
        BEGIN
          ByteChar:=#251;
          IntChar:=#252;
          LongChar:=#253;
          FloatChar:=#254;
          DoubleChar:=#255;
        END
      ELSE
        BEGIN
          ByteChar:='b';
          IntChar:='i';
          LongChar:='l';
          FloatChar:='f';
          DoubleChar:='d';
        END;
      IF StataVersion=8 THEN StrBaseNumber:=0 ELSE StrBaseNumber:=$7F;  //&&
      FillChar(typList,sizeOf(typList),0);
      StataFile.Position:=HeaderSize;
      StataFile.Read(typList,nVar);
      FOR n:=0 TO nVar-1 DO
        BEGIN
          Afield:=PeField(df^.FieldList.Items[n]);
          IF (typList[n]=DoubleChar) OR (typList[n]=FloatChar)
          OR (typList[n]=LongChar) OR (typList[n]=IntChar) THEN AField^.Felttype:=ftFloat
          ELSE IF typList[n]=ByteChar THEN AField^.Felttype:=ftInteger
//          ELSE IF ORD(typList[n])>$7F THEN    &&
//            BEGIN
//              AField^.Felttype:=ftAlfa;
//              AField^.FLength:=ORD(typList[n])-$7F;
//            END
          ELSE
            BEGIN
              IF StataVersion=8 THEN              //&&
                BEGIN
                  AField^.Felttype:=ftAlfa;
                  AField^.FLength:=ORD(typList[n]);
                END
              ELSE
                BEGIN
                  IF ORD(typList[n])>$7F THEN
                    BEGIN
                      AField^.Felttype:=ftAlfa;
                      AField^.FLength:=ORD(typList[n])-$7F;
                    END
                  ELSE
                    BEGIN
                      ErrorMsg(Lang(23984));  //'Unknown variable type found in Stata-file'
                      Exit;
                    END;
                END;
            END;
        END;  //for

      {Read varlist - list of variable names}
      Fillchar(buff,sizeOf(buff),0);
      MaxFNameWidth:=0;
      StataFile.Position:=HeaderSize+nVar;
      IF StataVersion>=7 THEN NameLength:=33 ELSE NameLength:=9;   //&&
      StataFile.Read(buff,NameLength*nVar);
      FOR n:=0 TO nVar-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.Items[n]);
          tmpS:=cFill(' ',NameLength);
          t:=0;
          WHILE buff[(n*NameLength)+t]<>#0 DO
            BEGIN
              tmpS[t+1]:=buff[(n*NameLength)+t];
              INC(t);
            END;  //while
          tmpS2:=tmpS;
          tmpS:='';
          FOR t:=1 TO Length(tmpS2) DO
            IF (tmpS2[t] in AlfaNumChars) THEN tmpS:=tmpS+tmpS2[t];
          IF Length(tmpS)>FieldNameLen THEN tmpS:=Copy(tmpS,1,FieldnameLen);
          IF NOT NameIsUnique(tmpS,df,FieldnameLen) THEN REPEAT UNTIL NameIsUnique(tmpS,df,FieldnameLen);
          CASE FieldNameCase OF
            fcUpper: tmpS:=AnsiUpperCase(tmpS);
            fcLower: tmpS:=AnsiLowerCase(tmpS);
          END;  //case
          AField^.FName:=trim(tmpS);
          IF Length(trim(AField^.FName))>MaxFNameWidth THEN MaxFNameWidth:=Length(trim(AField^.FName));
          IF AField^.FLength>80 THEN
            BEGIN
              ErrorMsg(Format(Lang(23914)+#13+  //'The variable %s is a text variable with more than 80 characters.'
              Lang(23916),[AField^.FName]));   //'This variable cannot be imported to EpiData.'
              Exit;
            END;

        END;  //for n

      {Read fmtlist - list of formats of the variables}
      Fillchar(buff,sizeOf(buff),0);
      StataFile.Position:=HeaderSize+nVar+(NameLength*nVar)+(2*(nVar+1));
      StataFile.Read(buff,12*nVar);
      FOR n:=0 TO nVar-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.items[n]);
          tmpS:='            ';
          t:=0;
          WHILE buff[(n*12)+t]<>#0 DO
            BEGIN
              tmpS[t+1]:=buff[(n*12)+t];
              INC(t);
            END;  //while
          {Handle formats...}
          tmpS:=trim(AnsiUpperCase(tmpS));
          IF tmpS[Length(tmpS)]='S' THEN AField^.Felttype:=ftAlfa
          ELSE IF Copy(tmpS,1,2)='%D' THEN
            BEGIN
              {format is a date}
              AField^.Felttype:=ftEuroDate;
              AField^.FLength:=10;
              IF length(tmpS)>2 THEN
                BEGIN
                  {date has a detailed format - check if month is before date}
                  s:=Copy(tmpS,3,Length(tmpS));
                  FOR t:=1 TO Length(s) DO
                    IF Pos(s[n],'MLN')>0 THEN s[n]:='M';
                  IF (pos('D',s)>0) AND (pos('D',s)>Pos('M',s)) THEN AField^.Felttype:=ftDate;
                END;
            END  //if date
          ELSE
            BEGIN
              {format is numeric}
              t:=Pos('.',tmpS);
              IF t=0 THEN
                BEGIN
                  ErrorMsg(Format(Lang(23986),[AField^.FName]));   //'Unknown format specified for variable %s'
                  Exit;
                END;
              s:='';
              DEC(t);
              WHILE (t>1) AND (tmpS[t] in NumChars) DO
                BEGIN
                  s:=tmpS[t]+s;
                  DEC(t);
                END;
              t:=Pos('.',tmpS)+1;
              s2:='';
              WHILE (t<Length(tmpS)) AND (tmpS[t] in NumChars) DO
                BEGIN
                  s2:=tmpS[t]+s2;
                  INC(t);
                END;
              TRY
                AField^.FLength:=StrToInt(s);
                AField^.FNumDecimals:=StrToInt(s2);
              EXCEPT
                ErrorMsg(Format(Lang(23986),[AField^.FName]));   //'Unknown format specified for variable %s'
                Exit;
              END;  //try..except
              IF typList[n]=ByteChar THEN   //&&
                     BEGIN    //&&
                       AField^.FLength:=3;
                       AField^.FNumDecimals:=0;
                     END
              ELSE IF typList[n]=IntChar THEN   //&&
                     BEGIN   //&&
                       AField^.FLength:=5;
                       AField^.FNumDecimals:=0;
                     END
              ELSE IF typList[n]=LongChar THEN   //&&
                     BEGIN    //&&
                       AField^.FLength:=11;
                       AField^.FNumDecimals:=0;
                     END
              ELSE IF (typList[n]=FloatChar) OR (typList[n]=DoubleChar) THEN
                    BEGIN
                      IF (tmpS[Length(tmpS)]<>'F') AND (NOT (AField^.Felttype in [ftDate,ftEuroDate,ftYMDDate])) THEN   //&&
                        BEGIN
                          AField^.FLength:=18;
                          AField^.FNumDecimals:=4;
                        END;
                    END;
            END;  //if numeric
        END;  //for n

      {Read lbllist - names af value label}
      Fillchar(buff,12*nVar,0);
      HasValueLabels:=False;
      StataFile.Read(buff,NameLength*nVar);
      FOR n:=0 TO nVar-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.items[n]);
          AField^.FValueLabel:='';
          tmpS:=cFill(' ',NameLength);
          t:=0;
          WHILE buff[(n*NameLength)+t]<>#0 DO
            BEGIN
              tmpS[t+1]:=buff[(n*NameLength)+t];
              INC(t);
            END;  //while
          tmpS:=trim(tmpS);
          IF tmpS<>'' THEN
            BEGIN
              AField^.FValueLabel:=tmpS;
              HasValueLabels:=True;
            END;
        END;  //for n

      {Read variable labels}
      MaxVarLabel:=0;
      FillChar(buff,sizeOf(Buff),0);
      IF StataVersion=4 THEN t:=32 ELSE t:=81;
      FOR n:=0 TO nVar-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.items[n]);
          FillChar(buff,t,0);
          StataFile.Read(buff,t);
          s:=StrPas(buff);
          IF Length(s)>50 THEN s:=Copy(s,1,48)+'..';
          IF Length(s)>MaxVarLabel THEN MaxVarLabel:=Length(s);
          FOR n2:=1 TO Length(s) DO
            IF (s[n2] in ['#','<','>','_']) THEN s[n2]:=' ';
          IF trim(AnsiUpperCase(AField^.FVariableLabel))=trim(AnsiUpperCase(AField^.FName))
            THEN AField^.FVariableLabel:=''
            ELSE AField^.FVariableLabel:=s;
        END;  //for n

      {Make Field's question and position entryfield}
      t:=10+1+MaxVarLabel+2;
      s:='%-10s %'+IntToStr(MaxVarLabel)+'s';
      FOR n:=0 TO nVar-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.items[n]);
          AField^.FOriginalQuest:=Format(s,[AField^.FName,AField^.FVariableLabel]);
          AField^.FFieldX:=t;
        END;  //for n

      {Read - and skip - expansion fields}
      New(pByte);
      REPEAT
        StataFile.Read(pByte^,1);   //data type code
        IF StataVersion>=7 THEN tmpWord:=ReadDbWord(StataFile.Position)   //&&
        ELSE tmpWord:=ReadWord(StataFile.Position);
        IF (pByte^<>0) OR (tmpWord<>0) THEN StataFile.Read(buff,tmpWord);
      UNTIL (StataFile.Position>=StataFile.Size-1) OR ( (pByte^=0) AND (tmpWord=0) );
      Dispose(pByte);

      {Datafile description is read - now make the datafile}
      IF NOT PeekCreateDatafile(df) THEN
        BEGIN
          ErrorMsg(Format(Lang(20416)+#13+  //20416=The datafile with the name %s cannot be created.
          Lang(23910),[df^.RECFilename]));   //'Import terminates'
          Exit;
        END;

      {Read data}
      TRY
        TRY
        UserAborts:=False;
        ProgressForm:=TProgressForm.Create(MainForm);
        ProgressForm.Caption:=Lang(23904);   //'Import from Stata'
        ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
        ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
        ProgressForm.pBar.Max:=nObs;
        ProgressForm.pBar.Position:=0;
        WindowList:=DisableTaskWindows(ProgressForm.Handle);
        ProgressForm.Show;

        CutsDecimals:=False;
        OKToCutDecimals:=False;
        AssignFile(F,df^.RECFilename);
        Append(F);
        FOR CurRec:=1 TO nObs DO
          BEGIN
            IF ProgressStep(nObs,CurRec) THEN
              BEGIN
                ProgressForm.pBar.Position:=CurRec;
                ProgressForm.pLabel.Caption:=Format(' '+Lang(23920),[CurRec,nObs]);  //'Importing record no. %d of %d'
                Application.ProcessMessages;
              END;
            FOR CurField:=0 TO df^.FieldList.Count-1 DO
              BEGIN
                AField:=PeField(df^.FieldList.Items[Curfield]);
                IF typList[CurField]=ByteChar THEN   //&&
                  BEGIN    //&&
                    tmpshortInt:=ReadByte(StataFile.Position);
                    IF StataVersion<8 THEN
                      BEGIN
                        IF tmpShortInt=$7F THEN s:='' ELSE s:=IntToStr(tmpShortInt);
                      END
                    ELSE
                      BEGIN
                        IF tmpShortInt<=100 THEN s:=IntToStr(tmpShortInt)
                        ELSE IF tmpShortInt=102 THEN s:=cFill('9',AField^.FLength)   // missing value .a
                        ELSE IF tmpShortInt=103 THEN s:=cFill('8',AField^.FLength)   // missing value .b
                        ELSE IF tmpShortInt=104 THEN s:=cFill('7',AField^.FLength)   // missing value .c
                        ELSE s:='';   // missing value . and missing values .d - .z
                        IF (tmpShortInt>=102) AND (tmpShortInt<=104) THEN
                          BEGIN
                            AField^.FMissingValues[0]:=cFill('9',Afield^.FLength);
                            AField^.FMissingValues[1]:=cFill('8',Afield^.FLength);
                            AField^.FMissingValues[2]:=cFill('7',Afield^.FLength);
                          END;
                      END
                  END
                ELSE IF typList[CurField]=IntChar THEN
                  BEGIN   //&&
                    tmpInt:=ReadWord(Statafile.Position);
                    IF StataVersion<8 THEN
                      BEGIN
                        IF tmpInt=$7FFF THEN s:='' ELSE s:=IntToStr(tmpInt);
                      END
                    ELSE
                      BEGIN
                        IF tmpInt<=$7FE4 THEN s:=IntToStr(tmpInt)
                        ELSE IF tmpInt=$7FE6 THEN s:=cFill('9',AField^.FLength)   // missing value .a
                        ELSE IF tmpInt=$7FE7 THEN s:=cFill('8',AField^.FLength)   // missing value .b
                        ELSE IF tmpInt=$7FE8 THEN s:=cFill('7',AField^.FLength)   // missing value .c
                        ELSE s:='';   // missing value . and missing values .d - .z
                        IF (tmpInt>=$7FE6) AND (tmpInt<=$7FE8) THEN
                          BEGIN
                            AField^.FMissingValues[0]:=cFill('9',Afield^.FLength);
                            AField^.FMissingValues[1]:=cFill('8',Afield^.FLength);
                            AField^.FMissingValues[2]:=cFill('7',Afield^.FLength);
                          END;
                      END
                  END
                ELSE IF typList[CurField]=LongChar THEN
                  BEGIN     //&&
                    tmpLong:=ReadDbWord(Statafile.Position);
                    IF StataVersion<8 THEN
                      BEGIN
                        IF tmpLong=$7FFFFFFF THEN s:='' ELSE s:=IntToStr(tmpLong);
                      END
                    ELSE
                      BEGIN
                        IF tmpLong<=$7fffffe4 THEN s:=IntToStr(tmpLong)
                        ELSE IF tmpLong=$7fffffe6 THEN s:=cFill('9',AField^.FLength)   // missing value .a
                        ELSE IF tmpLong=$7fffffe7 THEN s:=cFill('8',AField^.FLength)   // missing value .b
                        ELSE IF tmpLong=$7fffffe8 THEN s:=cFill('7',AField^.FLength)   // missing value .c
                        ELSE s:='';   // missing value . and missing values .d - .z
                        IF (tmpShortInt>=$7fffffe6) AND (tmpShortInt<=$7fffffe8) THEN
                          BEGIN
                            AField^.FMissingValues[0]:=cFill('9',Afield^.FLength);
                            AField^.FMissingValues[1]:=cFill('8',Afield^.FLength);
                            AField^.FMissingValues[2]:=cFill('7',Afield^.FLength);
                          END;
                      END
                  END
                ELSE IF typList[CurField]=FloatChar THEN
                  BEGIN    //&&
                    tmpSingle:=ReadSingle(StataFile.Position);
                    IF StataVersion<8 THEN
                      BEGIN
                        IF tmpSingle=Power(2,127) THEN s:=''
                        ELSE Str(tmpSingle:AField^.FLength:AField^.FNumDecimals,s);
                        IF (AField^.FNumDecimals>4) AND (INT(tmpSingle*10000)/10000 <> tmpSingle) THEN CutsDecimals:=True;
                      END
                    ELSE
                      BEGIN
                        IF tmpSingle<Power(2,127) THEN
                          BEGIN
                            Str(tmpSingle:Afield^.FLength:AField^.FNumDecimals,s);
                            IF (AField^.FNumDecimals>4) AND (INT(tmpSingle*10000)/10000 <> tmpSingle) THEN CutsDecimals:=True;
                          END
                        ELSE IF MisVal='.' THEN s:=''
                        ELSE IF MisVal='.a' THEN s:=cFill('9',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('9',AField^.FNumDecimals)
                        ELSE IF MisVal='.b' THEN s:=cFill('8',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('8',AField^.FNumDecimals)
                        ELSE IF MisVal='.c' THEN s:=cFill('7',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('7',AField^.FNumDecimals)
                        ELSE s:='';
                        IF (MisVal='.a') OR (MisVal='.b') OR (MisVal='.c') THEN
                          BEGIN
                            IF AField^.FNumDecimals>0 THEN
                              BEGIN
                                AField^.FMissingValues[0]:=cFill('9',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('9',AField^.FNumDecimals);
                                AField^.FMissingValues[1]:=cFill('8',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('8',AField^.FNumDecimals);
                                AField^.FMissingValues[2]:=cFill('7',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('7',AField^.FNumDecimals);
                              END
                            ELSE
                              BEGIN
                                AField^.FMissingValues[0]:=cFill('9',AField^.FLength-1-AField^.FNumDecimals);
                                AField^.FMissingValues[1]:=cFill('8',AField^.FLength-1-AField^.FNumDecimals);
                                AField^.FMissingValues[2]:=cFill('7',AField^.FLength-1-AField^.FNumDecimals);
                              END;
                          END;
                      END;  //if stata8
                  END   //if FloatChar
                ELSE IF typList[CurField]=DoubleChar THEN
                  BEGIN   //&&
                    tmpDouble:=ReadDouble(StataFile.Position);
                    IF StataVersion<8 THEN
                      BEGIN
                        IF tmpDouble=Power(2,1023) THEN s:=''
                        ELSE
                          BEGIN
                            Str(tmpDouble:AField^.FLength:AField^.FNumDecimals,s);
                            IF (AField^.FNumDecimals>4) AND ((INT(tmpDouble*10000))/10000 <> tmpDouble) THEN CutsDecimals:=True;
                          END
                      END  //if ver<8
                    ELSE
                      BEGIN
                        IF tmpDouble<Power(2,1023) THEN
                          BEGIN
                            Str(tmpDouble:Afield^.FLength:AField^.FNumDecimals,s);
                            IF (AField^.FNumDecimals>4) AND ((INT(tmpDouble*10000))/10000 <> tmpDouble) THEN CutsDecimals:=True;
                          END
                        ELSE IF MisVal='.a' THEN s:=cFill('9',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('9',AField^.FNumDecimals)
                        ELSE IF MisVal='.b' THEN s:=cFill('8',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('8',AField^.FNumDecimals)
                        ELSE IF MisVal='.c' THEN s:=cFill('7',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('7',AField^.FNumDecimals)
                        ELSE s:='';
                        IF (MisVal='.a') OR (MisVal='.b') OR (MisVal='.c') THEN
                          BEGIN
                            IF Afield^.FNumDecimals>0 THEN
                              BEGIN
                                AField^.FMissingValues[0]:=cFill('9',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('9',AField^.FNumDecimals);
                                AField^.FMissingValues[1]:=cFill('8',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('8',AField^.FNumDecimals);
                                AField^.FMissingValues[2]:=cFill('7',AField^.FLength-1-AField^.FNumDecimals)+'.'+cFill('7',AField^.FNumDecimals);
                              END
                            ELSE
                              BEGIN
                                AField^.FMissingValues[0]:=cFill('9',AField^.FLength-1-AField^.FNumDecimals);
                                AField^.FMissingValues[1]:=cFill('8',AField^.FLength-1-AField^.FNumDecimals);
                                AField^.FMissingValues[2]:=cFill('7',AField^.FLength-1-AField^.FNumDecimals);
                              END;
                          END;
                      END;  //if stata8
                  END  //if DoubleChar
                ELSE
                  BEGIN
                    IF (StataVersion<8) AND (ORD(typList[CurField])<=$7F) THEN    //&&
                      BEGIN
                        ErrorMsg(format(Lang(23922),[typList[Curfield]]));   //'Unknown dataformat %s found'
                        Exit;
                      END;
                  END;
                IF ( (StataVersion=8) AND (ORD(typList[CurField])<$F5) )
                OR ( (StataVersion<8) AND (ORD(typList[CurField])>$7F) ) THEN  //&&
                  BEGIN
                    FillChar(buff,sizeOf(buff),0);
                    StataFile.Read(buff,AField^.FLength);
                    s:=StrPas(buff);
                  END;  //if string variable
                IF (s<>'') AND ( AField^.Felttype in [ftDate,ftEuroDate,ftYMDDate]) THEN
                  BEGIN
                    tmpDate:=StrToFloat(s)+21916;  {Date is converted from Stata's 1/1-1960 base to Delphi's 30/12-1899 base}
                    s:=mibDateToStr(tmpDate,AField^.Felttype);
                  END;  //if date variable

                IF Length(s)>AField^.FLength THEN
                  BEGIN
                    tmpS:=Format(Lang(23924),[CurRec,AField^.FName]);   //'Error in record %d, field %s: data is too long to fit the field in EpiData'
                    IF (TypList[CurField]=FloatChar) OR (TypList[CurField]=DoubleChar)
                    THEN tmpS:=tmpS+#13#13+Lang(23926);   //'Try to use a fixed format (e.g. %9.2f) in Stata to optimize the fieldsize'
                    ErrorMsg(tmpS);
                    Exit;
                  END
                ELSE IF (NOT OKToCutDecimals) AND (CutsDecimals) THEN
                  BEGIN
                    tmpS:=Format(Lang(23928),    //'Data in record %d, field %s will be rounded to 4 decimals after the decimalpoint'
                    [CurRec,AField^.FName])+#13#13+Lang(23930);   //'Continue import?'
                    IF WarningDlg(tmpS)=mrCancel THEN Exit ELSE OKToCutDecimals:=True;
                  END;

                AField^.FFieldText:=s;

              END;  //for CurField
            WriteNextRecord(df,F);

            IF UserAborts THEN
              BEGIN
                IF eDlg(Lang(23932),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort import?'
                THEN
                  BEGIN
                    CloseFile(F);
                    tmpBool:=DeleteFile(df^.RECFilename);
                    Exit;
                  END
                ELSE UserAborts:=False;
              END;  //if UserAborts

          END;  //for CurRec
        EXCEPT
          ErrorMsg(Lang(23934));   //'Error reading data from Stata-file'
          Exit;
        END;  //try..except
      FINALLY
        {$I-}
        CloseFile(F);
        {$I+}
        EnableTaskWindows(WindowList);
        ProgressForm.Free;
      END;  //try.Except

      IF (HasValueLabels) AND (StataFile.Position<StataFile.Size-4) THEN
        BEGIN
          IF StataVersion=4 THEN
            BEGIN
              {Read value labels definitions - if present}
              WHILE StataFile.Position<StataFile.Size-2 DO
                BEGIN
                  FillChar(buff,sizeOf(buff),0);
                  t:=ReadWord(StataFile.Position);  //get number of entries in label
                  StataFile.Read(buff,10);   //11+(10*t));   //Load label definition
                  s:=StrPas(buff);
                  FirstLabel:=true;
                  tmpLabelRec:=NIL;
                  FirstLabelRec:=NIL;
                  Fillchar(buff,10,0);
                  StataFile.Read(buff,10*t);
                  FOR n:=1 TO t DO
                    BEGIN
                      IF LOHI THEN
                        BEGIN
                          SmallIntBuff[0]:=ORD(buff[(n-1)*2]);
                          SmallIntBuff[1]:=ORD(buff[((n-1)*2)+1]);
                        END
                      ELSE
                        BEGIN
                          SmallIntBuff[1]:=ORD(buff[(n-1)*2]);
                          SmallIntBuff[0]:=ORD(buff[((n-1)*2)+1]);
                        END;
                      NextLabelRec:=tmpLabelRec;
                      New(tmpLabelRec);
                      tmpLabelRec^.Next:=NIL;
                      IF FirstLabel THEN
                        BEGIN
                          FirstLabelRec:=tmpLabelRec;
                          FirstLabel:=False;
                        END
                      ELSE NextLabelRec^.Next:=tmpLabelRec;
                      tmpLabelRec^.Value:=IntToStr(tmpSmallInt);
                      tmpLabelRec^.Text:='        ';
                      n2:=0;
                      WHILE (n2<8) AND (buff[(t*2)+((n-1)*8)+n2]<>#0) DO
                        BEGIN
                          tmpLabelRec^.text[n2+1]:=buff[(t*2)+((n-1)*8)+n2];
                          INC(n2);
                        END;
                      tmpLabelRec^.Text:=trim(tmpLabelRec^.Text);
                    END;  //for n
                  n:=df^.ValueLabels.IndexOf(s);
                  IF n<>-1 THEN
                    BEGIN
                      ErrorMsg(Lang(23936));  //'Duplicate value label name found'
                      Exit;
                    END;
                  df^.ValueLabels.AddObject(s,TObject(FirstLabelRec));
                END;  //if not end of StataFile
            END  //if stataversion 4
          ELSE
            BEGIN
              {Value labels for stata version 6, 7 and 8}
              WHILE StataFile.Position<StataFile.Size-4 DO
                BEGIN
                  FillChar(buff,sizeOf(buff),0);
                  n:=ReadDbWord(StataFile.Position);     //Length of value_label_table (vlt)
                  StataFile.Read(buff,NameLength+3);     //Read label-name+3 byte padding
                  s:=StrPas(buff);                       //s now contains labelname
                  t:=df^.ValueLabels.IndexOf(s);
                  IF t<>-1 THEN
                    BEGIN
                      ErrorMsg(Lang(23936));  //'Duplicate value label name found'
                      Exit;
                    END;
                  FillChar(buff,NameLength+3,0);
                  StataFile.Read(buff,n);           //Load value_label_table into buffer
                  FirstLabel:=true;
                  tmpLabelRec:=NIL;
                  FirstLabelRec:=NIL;
                  n:=vltInteger(0);                 //Number of entries in label
                  MisWidth:=0;
                  FOR t:=0 TO n-1 DO
                    BEGIN
                      tmpLong:=vltInteger(4+4+(4*n)+(4*t));   //read the value
                      IF NOT ( (tmpLong=$7FFFFFE5) OR (tmpLong>$7FFFFFE8) ) THEN  //ignore valuelabels where value = . or value > .c
                        BEGIN
                          NextLabelRec:=tmpLabelRec;
                          New(tmpLabelRec);
                          tmpLabelRec^.Next:=NIL;
                          IF FirstLabel THEN
                            BEGIN
                              FirstLabelRec:=tmpLabelRec;
                              FirstLabel:=False;
                            END
                          ELSE NextLabelRec^.Next:=tmpLabelRec;
                          //tmpLabelRec^.Value:=IntToStr(vltInteger(4+4+(4*n)+(4*t)));
                          //tmpLabelRec^.Text:=vltString(4+4+(4*n)+(4*n)+vltInteger(4+4+(4*t)));
                          tmpLabelRec^.Value:=IntToStr(vltInteger(4+4+(4*n)+(4*t)));  //read the value
                          IF (tmpLong>=$7FFFFFE6) AND (tmpLong<=$7FFFFFE8) THEN
                            BEGIN
                              IF MisWidth=0 THEN
                                BEGIN
                                  //Find first field that uses this label to obtain the field's width
                                  n3:=0;
                                  WHILE (n3<df^.FieldList.Count-1) AND
                                  (PeField(df^.FieldList.Items[n3])^.FValueLabel<>s) DO INC(n3);
                                  AField:=PeField(df^.FieldList.Items[n3]);
                                  IF AField^.FNumDecimals=0
                                  THEN MisWidth:=AField^.FLength
                                  ELSE MisWidth:=AField^.FLength-1-AField^.FNumDecimals;
                                END;  //if MisWidth=0
                              CASE tmpLong OF
                                $7fffffe6: tmpLabelRec^.Value:=cFill('9',MisWidth);   // .a
                                $7fffffe7: tmpLabelRec^.Value:=cFill('8',MisWidth);   // .b
                                $7fffffe8: tmpLabelRec^.Value:=cFill('7',MisWidth);   // .c
                              ELSE
                                tmpLabelRec^.Value:='.';
                              END;  //case
                            END; //if value=.a, .b or .c
                          tmpLabelRec^.Text:=vltString(4+4+(4*n)+(4*n)+vltInteger(4+4+(4*t)));  //read the labeltext
                        END;  //if not . or >.c
                    END;  //for t
                  df^.ValueLabels.AddObject(s,TObject(FirstLabelRec));
                END;  //while
            END;  //if stataversion 6, 7 or 8

          {Assign the FCommentLegalRec property for the fields based on FValueLabel}
          FOR n:=0 TO df^.FieldList.Count-1 DO
            BEGIN
              AField:=PeField(df^.FieldList.Items[n]);
              IF AField^.FValueLabel<>'' THEN
                BEGIN
                  t:=df^.ValueLabels.IndexOf(AField^.FValueLabel);
                  IF t<>-1 THEN AField^.FCommentLegalRec:=pLabelRec(df^.ValueLabels.Objects[t])
                  ELSE
                    BEGIN
                      eDlg(Format(Lang(23988),     //'The field %s uses value label ''%s'' which is undefined.'
                      [trim(AField^.FName),AField^.FValueLabel]),mtWarning,[mbOK],0);
                    END;
                END;  //if
            END;  //for n

          IF df^.ChkTopComments=NIL THEN df^.ChkTopComments:=TSTringList.Create;
          df^.ChkTopComments.Append(Format('* '+Lang(23938),[StataFilename]));   //'Checkfile created from import of the stata-file %s'
          ChkLin:=TStringList.Create;
          ChecksToStrings(df,ChkLin);
          df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
          IF FileExists(df^.CHKFilename) THEN
            BEGIN
              n:=eDlg(Format(Lang(23940)+#13+   //'The stata-file contains valuelabels which will be imported to a checkfile'
              Lang(23942),[df^.CHKFilename]),   //'Do you want to overwrite the existing checkfile %s?'
              mtWarning,[mbYes,mbNo,mbCancel],0);  
              CASE n OF
                mrYes: ChkLin.SaveTofile(df^.CHKFilename);
                mrNo:  HasValueLabels:=False;
                mrCancel: Exit;
              END;  //case
            END  //if Chkfile fileExists
          ELSE ChkLin.SaveToFile(df^.CHKFilename);
          ChkLin.Free;

        END  //if hasValueLabels
      ELSE HasValueLabels:=False;

      Screen.Cursor:=crDefault;
      s:=Format(Lang(23944),[StataFilename]);   //'Datafile created by importing stata file %s'
      AddToNotesFile(df,s);
      IF NOT HasValueLabels
      THEN eDlg(Format(Lang(23946),  //'Stata-file %s is imported ~to %s~~%d records were imported'
      [StataFilename,df^.RECFilename,df^.NumRecords]),mtInformation,[mbOK],0)
      ELSE eDlg(Format(Lang(23948),  //'Stata-file %s has been imported~to %s~~Valuelabels are imported to the checkfile %s~~%d records were imported'
        [StataFilename,df^.RECFilename,df^.CHKFilename,df^.NumRecords]),mtInformation,[mbOK],0); 

      AddToRecentFiles(df^.RECFilename);

    FINALLY
      Screen.Cursor:=crDefault;
      DisposeDatafilePointer(df);
      IF Assigned(StataFile) THEN StataFile.Free;
      {$I-}
      CloseFile(F);
      n:=IOResult;
      {$I+}
    END;  //try..Finally
  END;  //procedure Importstata


BEGIN   //Procedure ImportDatafile
  IF ImportType=etdBase THEN
    BEGIN
      ImportdBase;
      Exit;
    END;
  IF ImportType=etStata THEN
    BEGIN
      ImportStata;
      Exit;
    END;

  {Import textfile}
  TRY
    df:=NIL;
    ImportForm:=TImportForm.Create(MainForm);
    WITH ImportForm DO
      BEGIN
        EUDateFormatCheck.Enabled:=False;
        USDateFormatCheck.Enabled:=False;
        DBaseGroup.Visible:=False;
        TextFileGroup.Left:=(ClientWidth DIV 2) - (TextFileGroup.Width DIV 2);
        IF ShowModal<>mrOK THEN Exit;
      END;
    IF NOT GetDataFilePointer(df) THEN Exit;
    Screen.Cursor:=crHourGlass;
    df^.RECFilename:=ImportForm.DatafileEdit.Text;
    df^.QESFilename:=ImportForm.QESFileEdit.Text;
    TRY
      QESLines:=TStringList.Create;
      QESLines.LoadFromFile(df^.QESFilename);
    EXCEPT
      ErrorMsg(Format(Lang(20406),[df^.QESFilename]));   //'QES-file %s cannot be found or opened.');
      QESLines.Free;
      Exit;
    END;  //try..except
    Mess:=QESLines.Text;
    QESLines.Free;

    df^.EpiInfoFieldNaming:=EpiInfoFieldNaming;
    df^.UpdateFieldnameInQuestion:=UpdateFieldnameInQuestion;
    CreatingFromQesFile:=True;
    tmpBool:=TranslateQes(df,mess);
    CreatingFromQesFile:=False;
    IF tmpBool=False THEN
      BEGIN
        LockWindowUpdate(MainForm.Handle);
        TRY
          RapForm:=TEdform.Create(MainForm);
          RapFormCreated:=TRUE;
          RapForm.Caption:=Lang(20412);   //'Error log'
          RapForm.Ed.Text:=Mess;
          RapForm.Ed.Modified:=FALSE;
        EXCEPT
          RapForm.Free;
          RapFormCreated:=FALSE;
        END;  //try..except
        LockWindowUpdate(0);
        Exit;
      END;  //if createIndtastningsFormError

    IF df^.NumFields=0 THEN
      BEGIN
        ErrorMsg(Format(Lang(20414),[df^.QESFilename])); //'The QES-file %s does not contain any entryfields.~~Datafile is not created.'
        Exit;
      END;

    IF NOT PeekCreateDataFile(df) THEN
      BEGIN
        ErrorMsg(Format(Lang(20416),[df^.RECFilename])+#13+Lang(20206));
        //20416='The datafile with the name %s cannot be created.'
        //20206='Please check if the filename is legal or if the disk is writeprotected or full.
        Exit;
      END;

    AddToRecentFiles(df^.RECFilename);

    {New REC-file is now created from the QES-file - now begin to read the data in the text-file}
    TRY
      Screen.Cursor:=crHourGlass;
      AssignFile(F,ImportForm.ImportFileEdit.Text);
      Reset(F);
      //AssignFile(df^.DatFile,df^.RECFilename);
      //Reset(df^.DatFile);
      AssignFile(dfFile,df^.RECFilename);
      Append(dfFile);

      IF ImportForm.IgnoreFirstLineCheck.Checked THEN
        BEGIN
          ReadLn(F,s);
          CurLine:=1;
        END
      ELSE CurLine:=0;
      DelChar:=trim(ImportForm.DelimiterCombo.Items[ImportForm.DelimiterCombo.ItemIndex]);
      IF DelChar='TAB' THEN DelChar:=#9
      ELSE IF DelChar='Space' THEN DelChar:=' ';
      WHILE NOT EOF(F) DO
        BEGIN
          ReadLN(F,s);
          INC(CurLine);
          FOR CurField:=0 TO df^.FieldList.Count-1 DO
            BEGIN
              AField:=PeField(df^.FieldList.Items[Curfield]);
              IF AField^.Felttype=ftQuestion THEN Continue;
{              IF s='' THEN
                BEGIN
                  ErrorMsg(Format('Line %d in the file %s is too short.'+#13+
                    'No data was found for the field %s',[CurLine,ImportForm.ImportFileEdit.Text,trim(AField^.FName)]));
                  Exit;
                END;}

              IF ImportForm.FixFormatCheck.Checked THEN
                BEGIN
                  s2:=Copy(s,1,AField^.FLength);
                  IF Length(s2)<AField^.FLength THEN
                    BEGIN
                      ErrorMsg(Format(Lang(23950)+#13+    //'Error in line %d in the file %s:'
                        Lang(23952),[CurLine,ImportForm.ImportFileEdit.Text,s2,trim(AField^.FName)]));   //'The data ('%s') for the field %s are too short.'
                      Exit;
                    END;
                  Delete(s,1,Length(s2));
                END
              ELSE
                BEGIN
                  //Read in delimited text-file format
                  IF (s='') OR (s[1]<>DelChar) THEN
                    BEGIN
                      IsInclosed:=(ImportForm.AllQuotesCheck.Checked)
                        OR (   (ImportForm.TextQuotesCheck.Checked)
                           AND (  (AField^.Felttype=ftAlfa)
                               OR (AField^.Felttype=ftUpperAlfa)
                               OR (AField^.Felttype=ftSoundex)
                               OR (AField^.Felttype=ftCrypt)       
                                )
                           AND (s<>'')
                           );
                      IF s='' THEN s:=' ';
                      IF (IsInclosed) AND (s[1]<>'"') THEN
                        BEGIN
                          ErrorMsg(Format(Lang(23950)+#13+    //'Error in line %d in the file %s:'
                            Lang(23954),[CurLine,ImportForm.ImportFileEdit.Text,trim(AField^.FName)]));   //'Missing start-quote for the field %s.'
                          Exit;
                        END;
                      n:=1;
                      REPEAT
                        IF (IsInclosed) AND (s[n]='"') THEN
                          BEGIN
                            REPEAT
                              INC(n);
                            UNTIL (s[n]='"') OR (n>Length(s));
                            IF (n>Length(s)) AND (s[n]<>'"') THEN
                              BEGIN
                                ErrorMsg(Format(Lang(23950)+#13+   //'Error in line %d in the file %s:'
                                Lang(23956),[CurLine,ImportForm.ImportFileEdit.Text,trim(AField^.FName)]));   //'Missing end-quote for the field %s.'
                                Exit;
                              END;
                          END;  //if IsInclosed
                        INC(n);
                      UNTIL (n>Length(s)) OR (s[n]=DelChar);
                      s2:=Copy(s,1,n);
                      Delete(s,1,Length(s2));
                      IF s2[Length(s2)]=DelChar THEN s2:=Copy(s2,1,Length(s2)-1);
                      IF IsInclosed THEN s2:=Copy(s2,2,Length(s2)-2);  //Remove quotes
                    END
                  ELSE
                    BEGIN
                      s2:='';
                      Delete(s,1,1);
                    END;
                END;
              ok:=True;
              s2:=Trim(s2);
              IF s2='' THEN ok:=True
              ELSE
                BEGIN
                  CASE AField^.Felttype OF
                    ftInteger,ftIDNUM: ok:=IsInteger(s2);
                    ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt: ok:=True;    
                    ftBoolean:
                      BEGIN
                        s2:=AnsiUpperCase(s2);
                        IF (s2='Y') OR (s2='1') OR (s2='T') THEN
                          BEGIN
                            ok:=True;
                            s2:='Y';
                          END;
                        IF (s2='N') OR (s2='0') OR (s2='F') THEN
                          BEGIN
                            ok:=True;
                            s2:='N';
                          END;
                      END;
                    ftFloat: ok:=isFloat(s2);
                    ftDate,ftEuroDate,ftToday,
                    ftYMDDate,ftYMDToday,ftEuroToday: ok:=HandleDates(s2,AField^.Felttype);
                  ELSE
                    ok:=False;
                  END;  //case
                END;  //if s2<>''
              IF NOT ok THEN
                BEGIN
                  ErrorMsg(Format(Lang(23950)+#13+   //'Error in line %d in the file %s:'
                  Lang(23958),   //'Data ('%s') is not compliant with the fieldtype of field %s (%s).'
                  [CurLine,ImportForm.ImportFileEdit.Text,s2,trim(AField^.FName),
                  FieldTypeNames[ORD(AField^.Felttype)]]));
                  Exit;
                END
              ELSE IF Length(s2)>AField^.FLength THEN
                BEGIN
                  ErrorMsg(Format(Lang(23950)+#13+   //'Error in line %d in the file %s:'
                  Lang(23960),[CurLine,ImportForm.ImportFileEdit.Text,s2,trim(AField^.FName)]));   //'Data ('%s') too wide to fit in the field %s'
                  Exit;
                END
              ELSE AField^.FFieldText:=s2;
            END;  //For Curfield
          //PeWriteRecord(df,NewRecord);
          WriteNextRecord(df,dfFile);
        END;  //while not EOF

      TRY
        InputForm:=TInputForm.Create(Application);
      EXCEPT
        InputForm.Free;
        ErrorMsg(Format(Lang(20204),[751]));   //'Out of memory (reference code 751)');
        Exit;
      END;
      InputForm.Maxlength:=50;
      InputForm.LabelText:=Lang(20408);   //'Enter description of datafile (datafile label)'
      InputForm.Caption:=Lang(20410)+' '+ExtractFilename(df^.RECFilename);  //'Datafile label for'
      IF InputForm.ShowModal=mrOK THEN df^.Filelabel:=InputForm.UserInput;
      InputForm.Free;

      Screen.Cursor:=crDefault;
      s:=Format(Lang(23962),[ImportForm.ImportFileEdit.Text]);   //'Datafile created by importing text file %s'
      AddToNotesFile(df,s);
      eDlg(Format(Lang(23964),   //'Text-file %s is imported~to %s~~%d records were imported'
      [ImportForm.ImportFileEdit.Text,df^.RECFilename,df^.NumRecords]),mtInformation,[mbOK],0);
    FINALLY
      CloseFile(F);
      CloseFile(dfFile);
    END;

  FINALLY
    Screen.Cursor:=crDefault;
    DisposeDataFilePointer(df);
    ImportForm.Free;
  END;
END;

end.
