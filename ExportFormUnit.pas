unit ExportFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Math, EpiTypes, ComCtrls, Spin, checklst;

type
  TExportForm = class(TForm)
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    PageControl1: TPageControl;
    SelectSheet: TTabSheet;
    ExportToLabel: TStaticText;
    ExportFilenameEdit: TEdit;
    SearchExpFileBtn: TBitBtn;
    OptionsSheet: TTabSheet;
    RecordsGroup: TGroupBox;
    AllRecordsCheck: TRadioButton;
    SelRecordsCheck: TRadioButton;
    FromRecEdit: TEdit;
    Label1: TLabel;
    ToRecEdit: TEdit;
    SkipDeletedCheck: TCheckBox;
    UseFilterCheck: TCheckBox;
    FilterLabel: TLabel;
    FilterEdit: TEdit;
    FieldsGroup: TGroupBox;
    FieldCheckList: TCheckListBox;
    AllBtn: TButton;
    NoneBtn: TButton;
    ListDataGroup: TGroupBox;
    MaxWidthLabel: TLabel;
    NumColsLabel: TLabel;
    NumCharsLabel: TLabel;
    WidthEdit: TEdit;
    ColEdit: TEdit;
    SpinButton1: TSpinButton;
    TextFileGroup: TGroupBox;
    UseTextIdentifierCheck: TCheckBox;
    FieldSepCombo: TComboBox;
    FieldSepText: TStaticText;
    WriteLabelsCheckBox: TCheckBox;
    StataGroup: TGroupBox;
    StataVerCombo: TComboBox;
    Bevel1: TBevel;
    VarLabel: TLabel;
    DotsLabel: TLabel;
    CodebookGroup: TGroupBox;
    OnlyBasicChecksRadio: TRadioButton;
    AllChecksRadio: TRadioButton;
    NamesInFirstLineCheck: TCheckBox;
    StataLetterCaseRadio: TRadioGroup;
    GroupBox1: TGroupBox;
    chkExpSortIndex: TCheckBox;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SearchExpFileBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FieldSepComboChange(Sender: TObject);
    procedure FieldSepKeyPress(Sender: TObject; var Key: Char);
    procedure AllBtnClick(Sender: TObject);
    procedure NoneBtnClick(Sender: TObject);
    procedure WidthEditChange(Sender: TObject);
    procedure WidthEditKeyPress(Sender: TObject; var Key: Char);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure FromRecEditChange(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure FieldCheckListMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FilterEditExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  PBuffer=^TBuffer;
  TBuffer=Array[0..120000] of Byte;


Procedure ExportDatafile;
Procedure ListData;
Procedure MakeQesFromRec;


var
  ExportForm: TExportForm;
  ExportType: TExportTypes;
  ListDataWidth, ListDataCols: Integer;
  ListDataLabels, ListDataSkipDel: Boolean;
  ShowAllChecksInCodebook:Boolean;



implementation

USES
  FileUnit, MainUnit, Xls, ProgressUnit,PeekCheckUnit,
  CheckErrorUnit, EdUnit, prExpr, SelectFilesUnit;

{$R *.DFM}

VAR
  NumFieldsExported,NumRecordsExported:Longint;


Function MakeName(CONST s:String):String;
VAR
  tmpS:String[20];
BEGIN
  tmpS:=Trim(s);
  CASE FieldNameCase OF
    fcUpper: tmpS:=ANSIUpperCase(tmpS);
    fcLower: tmpS:=ANSILowerCase(tmpS);
  END;  //Case
  Result:=tmpS;
END;  //Function MakeName

procedure ExportToTextFile(VAR df:PDatafileInfo; CONST ExpFilename:String);
VAR
  ExportLin:TStrings;
  ExpRecLin:String;
  exN, exN2:Integer;
  Seperator:String;
  StrID,DeD:Boolean;
  ReadOnlyRecFile:TextFile;
  InStr: String[MaxRecLineLength+3];
  FromRecNo,ToRecNo: Integer;
  UseFilter,FilterOK: Boolean;
  UseIndex: Boolean;
  E:IValue;
BEGIN
  Seperator:=trim(ExportForm.FieldSepCombo.Items[ExportForm.FieldSepCombo.ItemIndex]);
  IF Seperator='TAB' THEN Seperator:=#9;
  StrID:=ExportForm.UseTextIdentifierCheck.Checked;
  Ded:=ExportForm.SkipDeletedCheck.Checked;
  ExportLin:=TStringList.Create;
  WITH ExportForm DO
    BEGIN
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with

  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with

  {Initialize inputfile}
  //CloseFile(df^.DatFile);
  df^.Datfile.Free;   //§§§
  df^.Datfile:=NIL;  //§§§
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR exN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}

  {Write fieldnames}
  IF ExportForm.NamesInFirstLineCheck.Checked THEN
    BEGIN
      ExpRecLin:='';
      FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
      //FOR exN:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          IF ExportForm.FieldCheckList.Checked[exN] THEN
            BEGIN
              //WITH PeField(df^.FieldList.Items[exN])^ DO
              WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
                IF Felttype<>ftQuestion THEN
                  BEGIN
                    INC(NumFieldsExported);
                    IF StrID THEN ExpRecLin:=ExpRecLin+'"'+MakeName(FName)+'"'+Seperator
                    ELSE ExpRecLin:=ExpRecLin+MakeName(Fname)+Seperator;
                  END;  //if
            END;  //if write field
        END;  //for
      IF ExpRecLin[Length(ExpRecLin)]=Seperator
      THEN ExpRecLin:=Copy(ExpRecLin,1,Length(ExpRecLin)-1);
      ExportLin.Append(ExpRecLin);
    END;

  {Write Data}
  UserAborts:=False;
  FilterOK:=True;
  HandleVarsDf:=df;
  UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
  IF UseIndex THEN
    BEGIN
      ApplyIndex(df);
      InitSortIndex(df);
    END;
  TRY
    FOR exN:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,exN) THEN
          BEGIN
            ProgressForm.pBar.Position:=exN;
            ProgressForm.pLabel.Caption:=Format(Lang(22300),[exN]);   //' Exporting record no. %d'
            Application.ProcessMessages;
          END;
        //eReadOnlyNextRecord(df,ReadOnlyRecFile);
        IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,exN))
        ELSE eReadOnlyRecord(df,ReadOnlyRecFile,exN);

        IF UseFilter THEN
          BEGIN
            TRY
              E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
              IF Assigned(E) THEN
                BEGIN
                  IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                  ELSE
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      ExportLin.Free;
                      CloseFile(ReadOnlyRecFile);
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //if assigned(E)
            EXCEPT
              On Er:EExpression do
                BEGIN
                  ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                  DisposeDatafilePointer(df);
                  ExportLin.Free;
                  CloseFile(ReadOnlyRecFile);
                  UserAborts:=True;
                  Exit;
                END;
            END;  //try..except
          END;  //if UseFilter

        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
          BEGIN
            ExpRecLin:='';
            FOR exN2:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
//            FOR exN2:=0 TO df^.FieldList.Count-1 DO
              BEGIN
                IF ExportForm.FieldCheckList.Checked[exN2] THEN
                  BEGIN
                    WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN2])^ DO
                    //WITH PeField(df^.FieldList.Items[exN2])^ DO
                      IF Felttype<>ftQuestion THEN
                        BEGIN
                          IF (StrID) AND (Felttype in [ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt])  
                          THEN ExpRecLin:=ExpRecLin+'"'+FFieldText+'"'+Seperator
                          ELSE ExpRecLin:=ExpRecLin+FFieldText+Seperator;
                        END;  //if
                  END;  //if write field
              END;  //for exN2
            IF ExpRecLin[Length(ExpRecLin)]=Seperator
            THEN ExpRecLin:=Copy(ExpRecLin,1,Length(ExpRecLin)-1);
            INC(NumRecordsExported);
            ExportLin.Append(ExpRecLin);
          END;  //if CurRecDeleted
        //Application.ProcessMessages;
        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN
              BEGIN
                ExportLin.Free;
                CloseFile(ReadOnlyRecFile);
                Exit;
              END
            ELSE UserAborts:=False;
          END;
      END;  //for exN
  EXCEPT
    ErrorMsg(Format(Lang(22304),[exN]));   //'Error occured during export of record #%d'
    ExportLin.Free;
    CloseFile(ReadOnlyRecFile);
    Exit;
  END;  //try..Except
  ExportLin.SaveToFile(ExpFilename);
  ExportLin.Free;
  CloseFile(ReadOnlyRecFile);
END;  //procedure ExportToTextFile


Procedure ExportToDBaseFile(VAR df:PDatafileInfo; CONST dbFilename:String);
VAR
  dBaseFile:FILE OF BYTE;
  NumberOfFields,dbRecLength,eN:Integer;
  RecordsWritten:Longint;
  eW:Byte;
  tmpS:String;
  DeD:Boolean;
  ReadOnlyRecFile:TextFile;
  InStr: String[MaxRecLineLength+3];
  FromRecNo,ToRecNo: Integer;
  UseFilter,FilterOK: Boolean;
  UseIndex: Boolean;
  E:IValue;

  Procedure dWrite(s:String);
  VAR
  t,dN:BYTE;
  BEGIN
    FOR dN:=1 TO Length(s) DO
      BEGIN
        t:=ORD(s[dN]);
        Write(dBaseFile,t);
      END;  //for
  END;  //procedure dWrite

  Procedure dWriteInt(i:Integer);
  VAR
    t:Byte;
  BEGIN
    t:=LO(i);
    Write(dBaseFile,t);
    t:=HI(i);
    Write(dBaseFile,t);
  END;   //procedure dWriteInt

BEGIN  //ExportToDBaseFile
  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with

  {Initialize inputfile}
  //CloseFile(df^.DatFile);
  df^.Datfile.Free;   //§§§
  df^.Datfile:=NIL;  //§§§
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR eN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}

  {Create exportfile}
  {$I-}
  AssignFile(dBaseFile,dbFilename);
  ReWrite(dBaseFile);
  eN:=IOResult;
  {$I+}
  NumberOfFields:=0;
  dbRecLength:=0;
  WITH ExportForm DO
    BEGIN
      Ded:=SkipDeletedCheck.Checked;
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with

  {Calculate recordlength as it is in dBase format}
  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
  //FOR eN:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO BEGIN
          //WITH PeField(df^.FieldList.Items[eN])^ DO BEGIN
            IF FeltType<>ftQuestion THEN INC(NumberOfFields);
            CASE FeltType OF
              ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday: INC(dbRecLength,8);  
            ELSE
              INC(dbRecLength,FLength);
            END;  //case
          END;  //with
        END;  //if write field
    END;  //for eN
  NumFieldsExported:=NumberOfFields;

  DecodeDate(Date,eYear,eMonth,eDay);
  IF eYear>100 THEN eYear:=eYear MOD 100;

  {Write fileheader}
  dWrite(Chr(3));           //header offset 0 - dBase III identifier
  dWrite(Chr(eYear));     //header offset 1 - year of last update
  dWrite(Chr(eMonth));    //header offset 2 - month of last update
  dWrite(Chr(eDay));      //header offset 3 - date of last update
  {header offset 4 - Number of records - longint}
  dWriteInt(df^.NumRecords MOD $10000);  //Write low dWord
  dWriteInt(df^.NumRecords DIV $10000);  //Write hi dWord
  eN:=32+(NumberOfFields*32)+1;
  dWriteInt(eN);           //header offset 8 - Header size in bytes
  dWriteInt(dbRecLength+1);   // offset 10 - Record size in bytes
//  eW:=0;
  FOR eN:=1 TO 20 DO
    dWrite(Chr(0));          //header offset 12 - 20 x unused bytes

  {Write field descriptions}
  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
  //FOR eN:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
          //WITH PeField(df^.FieldList.Items[eN])^ DO
            BEGIN
              IF FeltType<>ftQuestion THEN
                BEGIN
                  tmpS:=MakeName(FName);
                  While Length(tmpS)<11 DO tmpS:=tmpS+#0;
                  dWrite(tmpS);
                  CASE FeltType of
                    ftInteger:                       dWrite('N');
                    ftIDNUM:                         dWrite('N');
                    ftSoundex:                       dWrite('C');
                    ftAlfa,ftUpperAlfa,ftCrypt:      dWrite('C');
                    ftDate,ftToday,ftYMDDate,ftYMDToday,           
                    ftEuroDate,ftEuroToday:          dWrite('D');
                    ftBoolean:                       dWrite('L');
                    ftFloat:                         dWrite('N');
                  ELSE
                    dWrite('X');
                  END;
                  dWrite(#0#0#0#0);
                  IF (FeltType in [ftDate,ftToday,ftEuroDate,ftEuroToday,ftYMDDate,ftYMDToday])  
                  THEN dWrite(Chr(8))
                  ELSE dWrite(Chr(FLength));   //all dates are length 8 in dBase
                  dWrite(Chr(FNumDecimals));
                  FOR eW:=1 TO 5 DO dWrite(#0);
                  dWrite(chr(1));
                  FOR eW:=1 TO 8 DO dWrite(#0);
                END;  //if felttype<>ftQuestion
            END;  //with
        END;  //if write field
    END;  //for
  dWrite(Chr(13));   //write Header Terminator

  {write records}
  RecordsWritten:=0;
  UserAborts:=False;
  FilterOK:=True;
  HandleVarsDf:=df;
  UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
  IF UseIndex THEN
    BEGIN
      ApplyIndex(df);
      InitSortIndex(df);
    END;
  TRY
    FOR eN:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,eN) THEN
          BEGIN
            ProgressForm.pBar.Position:=eN;
            ProgressForm.pLabel.Caption:=Format(Lang(22300),[eN]);  //'Exporting record no. %d'
            Application.ProcessMessages;
          END;
        //eReadOnlyNextRecord(df,ReadOnlyRecFile);
        IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,eN))
        ELSE eReadOnlyRecord(df,ReadOnlyRecFile,eN);


        IF UseFilter THEN
          BEGIN
            TRY
              E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
              IF Assigned(E) THEN
                BEGIN
                  IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                  ELSE
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      CloseFile(dBaseFile);
                      DeleteFile(dbFilename);
                      CloseFile(ReadOnlyRecFile);
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //if assigned(E)
            EXCEPT
              On Er:EExpression do
                BEGIN
                  ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                  CloseFile(dBaseFile);
                  DeleteFile(dbFilename);
                  CloseFile(ReadOnlyRecFile);
                  UserAborts:=True;
                  Exit;
                END;
            END;  //try..except
          END;  //if UseFilter

        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
        //IF ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) THEN
          BEGIN
            INC(RecordsWritten);
            IF df^.CurRecDeleted THEN dWrite('*') ELSE dWrite(' ');

            FOR eW:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
            //FOR eW:=0 TO df^.FieldList.Count-1 DO
              BEGIN
                IF ExportForm.FieldCheckList.Checked[eW] THEN
                  BEGIN
                    WITH PeField(ExportForm.FieldCheckList.items.Objects[eW])^ DO
                    //WITH PeField(df^.FieldList.Items[eW])^ DO
                      BEGIN
                        tmpS:=FFieldText;
                        CASE FeltType of
                          ftInteger,ftIDNUM: IF trim(tmpS)<>''
                            THEN dWrite(FormatInt(StrToInt(tmpS),Flength))
                            ELSE dWrite(FormatStr(tmpS,FLength));
                          ftAlfa,ftUpperAlfa,ftCrypt,        
                          ftBoolean,ftSoundex: dWrite(FormatStr(tmpS,FLength));
                          ftDate,ftToday,ftEuroDate,ftEuroToday,ftYMDDate,ftYMDToday:    
                            BEGIN
                              IF (trim(tmpS)<>'') AND (NOT mibIsDate(tmpS,FeltType)) THEN
                                BEGIN
                                  ErrorMsg(Format(Lang(22306),[eN,trim(PeField(df^.FieldList.Items[eW])^.FName)]));   //'Illegal date found in record # %d, field %s~Export terminates.'
                                  CloseFile(dBaseFile);
                                  DeleteFile(dbFilename);
                                  CloseFile(ReadOnlyRecFile);
                                  UserAborts:=True;
                                  Exit;
                                END;
                              dWrite(FormatDate(tmpS,FeltType,FLength));
                            END;  //case date
                          ftFloat: IF trim(tmpS)<>''
                            THEN dWrite(FormatFloating(tmpS,FLength))
                            ELSE dWrite(FormatStr(tmpS,FLength));
                        END;   //Case
                      END;  //with
                  END;  //if write field
              END;  //for eW
          END;  //if Deleted record should be written
        //Application.ProcessMessages;
        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN
              BEGIN
                CloseFile(dBaseFile);
                DeleteFile(dbFilename);
                CloseFile(ReadOnlyRecFile);
                Exit;
              END
            ELSE UserAborts:=False;
          END;
      END;  //for eN
  EXCEPT
    ErrorMsg(Format(Lang(22304),[eN]));  //'Error occured during export of record #%d'
    CloseFile(dBaseFile);
    DeleteFile(dbFilename);
    CloseFile(ReadOnlyRecFile);
    Exit;
  END;  //try..except
  IF (RecordsWritten<>df^.NumRecords) AND (NOT UserAborts) THEN
    BEGIN
      Seek(dBaseFile,4);  //find Header offset 4 - Number of records - longint
      dWriteInt(RecordsWritten MOD $10000);  //Write low dWord
      dWriteInt(RecordsWritten DIV $10000);  //Write hi dWord
    END;  //if
  NumRecordsExported:=RecordsWritten;
  CloseFile(dBaseFile);
  CloseFile(ReadOnlyRecFile);
END;   //procedure ExportToDBASEIII


Procedure ExportToExcelFile(VAR df:PDatafileInfo; CONST xlsFilename:String);
VAR
  XlsFile,eN,eW:Integer;
  CurCol,CurRow:Integer;
  Ded:Boolean;
  TmpS:String;
  tmpDateTime:Double;
  ReadOnlyRecFile: TextFile;
  InStr: String[MaxRecLineLength+3];
  FromRecNo,ToRecNo: Integer;
  UseFilter,FilterOK: Boolean;
  UseIndex: Boolean;
  E:IValue;

  Function ExtractDate(eF:TFeltTyper;eL:Integer;s:String):DOUBLE;
  VAR
    tYear,tMonth,tDay:Word;
    tmpDate:TDateTime;
  BEGIN
    DecodeDate(Date,tYear,tMonth,tDay);
    CASE eL OF
      8:  IF StrToInt(Copy(s,7,2))<50
          THEN tYear:=2000+StrToInt(Copy(s,7,2))
          ELSE tYear:=1900+StrToInt(Copy(s,7,2));
      10: IF (eF=ftYMDDate) or (eF=ftYMDToday)
          THEN tYear:=StrToInt(Copy(s,1,4))
          ELSE tYear:=StrToInt(Copy(s,7,4));
    END;  //case
    IF (eF=ftDate) OR (eF=ftToday) THEN
      BEGIN
        tMonth:=StrToInt(Copy(s,1,2));
        tDay:=StrToInt(Copy(s,4,2));
        CASE eL OF
          5:  Xls_SetAttributeByte2(0, 21);
          8:  Xls_SetAttributeByte2(0, 22);
          10: Xls_SetAttributeByte2(0, 23);
        END;  //case
      END;
    IF (eF=ftEuroDate) OR (eF=ftEuroToday) THEN
      BEGIN
        tMonth:=StrToInt(Copy(s,4,2));
        tDay:=StrToInt(Copy(s,1,2));
        CASE eL OF
          5:  Xls_SetAttributeByte2(0, 24);
          8:  Xls_SetAttributeByte2(0, 25);
          10: Xls_SetAttributeByte2(0, 26);
        END;  //case
      END;
    IF (eF=ftYMDDate) or (eF=ftYMDToday) THEN   
      BEGIN
        tMonth:=StrToInt(Copy(s,6,2));
        tDay:=StrToInt(Copy(s,9,2));
        Xls_SetAttributeByte2(0, 26);
      END;
    tmpDate:=EncodeDate(tYear,tMonth,tDay);
    Result:=tmpDate;
  END;  //extractDate

BEGIN  //exportToExcelFile
  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with

  {Initialize inputfile}
  //CloseFile(df^.DatFile);
  df^.Datfile.Free;   //§§§
  df^.Datfile:=NIL;  //§§§
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR eN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}

  XlsFile:=Xls_Create(xlsFilename);
  WITH ExportForm DO
    BEGIN
      Ded:=SkipDeletedCheck.Checked;
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with

  {Prepare dateformats}
  Xls_SetFormat(XlsFile,'mm/dd');        //US short date #21
  Xls_SetFormat(XlsFile,'mm/dd/yy');     //US medium date #22
  Xls_SetFormat(XlsFile,'mm/dd/yyyy');   //US long date #23
  Xls_SetFormat(XlsFile,'dd/mm');        //EU Short date #24
  Xls_SetFormat(XlsFile,'dd/mm/yy');     //EU medium date #25
  Xls_SetFormat(XlsFile,'dd/mm/yyyy');   //EU long date #26


  Xls_SetAttributeByte2(0, 0);  // reset format
  {Write fieldnames}
  CurCol:=0;
  CurRow:=0;

  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
  //FOR eN:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
          //WITH PeField(df^.FieldList.Items[eN])^ DO
            IF Felttype<>ftQuestion THEN
              BEGIN
                INC(NumFieldsExported);
                Xls_SetString(XlsFile,0,CurCol,MakeName(FName));
                INC(CurCol);
              END;
        END;  //if write field
    END;  //for

  {Write data}
  TRY
    UserAborts:=False;
    FilterOK:=True;
    HandleVarsDf:=df;
    UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
    IF UseIndex THEN
      BEGIN
        ApplyIndex(df);
        InitSortIndex(df);
      END;

    FOR eN:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,eN) THEN
          BEGIN
            ProgressForm.pBar.Position:=eN;
            ProgressForm.pLabel.Caption:=Format(' '+Lang(22300),[eN]);  //'Exporting record no. '
            Application.ProcessMessages;
          END;

        //eReadOnlyNextRecord(df,ReadOnlyRecFile);
        IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,eN))
        ELSE eReadOnlyRecord(df,ReadOnlyRecFile,eN);

        IF UseFilter THEN
          BEGIN
            TRY
              E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
              IF Assigned(E) THEN
                BEGIN
                  IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                  ELSE
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      Xls_Close(XlsFile);
                      CloseFile(ReadOnlyRecFile);
                      DeleteFile(xlsFilename);
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //if assigned(E)
            EXCEPT
              On Er:EExpression do
                BEGIN
                  ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                  Xls_Close(XlsFile);
                  CloseFile(ReadOnlyRecFile);
                  DeleteFile(xlsFilename);
                  UserAborts:=True;
                  Exit;
                END;
            END;  //try..except
          END;  //if UseFilter

        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
        //IF ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) THEN
          BEGIN
            INC(NumRecordsExported);
            INC(CurRow);
            CurCol:=0;

            FOR eW:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
            //FOR eW:=0 TO df^.FieldList.Count-1 DO
              BEGIN
                IF ExportForm.FieldCheckList.Checked[eW] THEN
                  BEGIN
                    WITH PeField(ExportForm.FieldCheckList.Items.Objects[eW])^ DO
                    //WITH PeField(df^.FieldList.Items[eW])^ DO
                      IF Felttype<>ftQuestion THEN
                        BEGIN
                          tmpS:=FFieldText;
                          CASE FeltType of
                            ftInteger,ftIDNUM: IF trim(tmpS)<>''
                              THEN XLS_SetDouble(XlsFile,CurRow,CurCol,StrToFloat(tmps));
                            ftAlfa,ftUpperAlfa,ftCrypt,                 
                              ftSoundex: Xls_SetString(XlsFile,CurRow,CurCol,Trim(tmpS));
                            ftBoolean: IF trim(tmpS)='Y'
                              THEN Xls_SetBoolean(XlsFile,CurRow,CurCol,True)
                              ELSE Xls_SetBoolean(XlsFile,CurRow,CurCol,False);
                            ftDate,ftToday,ftEuroDate,ftEuroToday,ftYMDDate,ftYMDToday:   
                              BEGIN
                                IF (trim(tmpS)<>'') AND (NOT mibIsDate(tmpS,FeltType)) THEN
                                  BEGIN
                                    ErrorMsg(Format(Lang(22306),[eN,trim(FName)]));  //Illegal date found in record # %d, field %s~Export terminates.
                                    Xls_Close(XlsFile);
                                    CloseFile(ReadOnlyRecFile);
                                    DeleteFile(xlsFilename);
                                    UserAborts:=True;
                                    Exit;
                                  END;
                                IF (FeltType=ftDate) or (FeltType=ftToday)
                                THEN Xls_SetAttributeByte2(0, 23)
                                ELSE Xls_SetAttributeByte2(0, 26);
                                IF trim(tmpS)<>'' THEN
                                  BEGIN
                                    tmpDateTime:=ExtractDate(FeltType,FLength,tmpS);
                                    Xls_SetDouble(XlsFile,CurRow,CurCol,tmpDateTime);
                                  END;
                                Xls_SetAttributeByte2(0, 0);  // reset format
                              END;  //case date
                            ftFloat: IF trim(tmpS)<>''
                              THEN
                                BEGIN
                                  IF DecimalSeparator<>'.'
                                  THEN tmpS[pos('.',tmpS)]:=DecimalSeparator;
                                  IF DecimalSeparator<>','
                                  THEN tmpS[pos(',',tmpS)]:=DecimalSeparator;
                                  Xls_SetDouble(XlsFile,CurRow,CurCol,StrToFloat(tmpS));
                                END;
                          END;   //Case
                          INC(CurCol);
                        END;  //if
                  ENd;  //if write field
              END;  //for eW
          END;  //if CurRecDeleted
        //Application.ProcessMessages;
        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN
              BEGIN
                Xls_Close(XlsFile);
                CloseFile(ReadOnlyRecFile);
                DeleteFile(xlsFilename);
                Exit;
              END
            ELSE UserAborts:=False;
          END;
      END;  //for eN
  EXCEPT
    ErrorMsg(Format(Lang(22304),[eN]));  //'Error occured during export of record #%d'
    Xls_Close(XlsFile);
    CloseFile(ReadOnlyRecFile);
    DeleteFile(xlsFilename);
    UserAborts:=True;
    Exit;
  END;
  Xls_Close(XlsFile);
  CloseFile(ReadOnlyRecFile);
END;   //procedure ExportToExcelFile


Procedure ExportToStataFile(VAR df:PDatafileInfo; CONST StataFilename:String);
VAR
  StataFile, eN, eN2, eN3,eN4:Integer;
  RecordsWritten: Longint;
  NVar,tmpNVar:Integer;     //Number of Variables
  Buffer:PBuffer;
  BuffPointer:Integer;
  s,tmpStr: String;
  InStr: String[MaxRecLineLength+3];
  tempName: String[40];
  TmpStatafile: FILE of Byte;
  ReadOnlyRecFile: TextFile;
  tmpC: Char;
  CurVar:Integer;
  CurObs:Longint;
  tmpByte: Byte;
  tmpInt: Integer;
  tmpLongInt: Longint;
  tmpDouble: Double;
  IsMissing,ok, LabelsTruncated: Boolean;
  DeD:Boolean;
  ValueLabelList:TStrings;
  tmpLabelRec: PLabelRec;
  EntriesInLabel, CommentedEntries, txtTableLength, txtTableStart,ValueLabelTableLength: Integer;
  FromRecNo,ToRecNo: Integer;
  UseFilter,FilterOK: Boolean;
  UseIndex: Boolean;
  E:IValue;
  NameLength: Integer;
  StrBaseNumber: Byte;
  ByteChar,intChar,LongChar,FloatChar,DoubleChar: Char;
  MisVal: String;


  {
  Fields are exported to stata in the this format:
  *ftInteger,ftIDNUM - Flength<3:  Byte
                       FLength<5:  Integer
                       FLength<10: Longint
                       FLength>9:  Double real
  *ftFloat -           Double real
  *ftBoolean -         Byte (0=false, 1=true)
  *ftDate,ftToday,
   ftEurodate,
   ftEuroToday -       FLength>5: double real (formatcode=%d)
                       FLength=5: String
  *ftAlfa,
   ftUpperAlfa -       String
  *ftSoundex -         String (Length=5)
  }


  Procedure PutStringInBuffer(position:Integer; s:String);
  VAR
    pN:Integer;
  BEGIN
    FOR pN:=1 TO Length(s) DO
      Buffer^[Position+(pN-1)]:=ORD(s[pN]);
  END;

  Procedure PutLongIntInBuffer(position:Integer; AInt:Longint);
  VAR
    tmpValue:LongInt;
    Buffer2:Array[0..3] of Byte Absolute tmpValue;
    n:Integer;
  BEGIN
    tmpValue:=AInt;
    FOR n:=0 TO 3 DO
      Buffer^[Position+n]:=Buffer2[n];
  END;

  Procedure PutWordInBuffer(position:Integer; AWord:Word);
  BEGIN
    Buffer^[Position]:=LO(AWord);
    Buffer^[Position+1]:=HI(AWord);
  END;

  Procedure sWriteByte(FileHandle:Integer; Value:Byte);
  Var
    Buffer : Array[0..0] of Byte;
  Begin
    Buffer[0]:=Value;
    FileWrite(FileHandle, Buffer, 1);
  end;



  Procedure sWriteWord(FileHandle:Integer; Value:Word);
  Var
    Buffer : Array[0..1] of Byte;
  Begin
    Buffer[0]:=Lo(Value);   //Byteorder is LOHI
    Buffer[1]:=Hi(Value);
    FileWrite(FileHandle, Buffer, 2);
  end;

  Procedure sWriteDoubleWord(FileHandle:Integer; Value:Longint);
  VAR
    tmpValue:LongInt;
    Buffer:Array[0..3] of Byte Absolute tmpValue;
  Begin
    tmpValue:=Value;
    FileWrite(FileHandle, Buffer, 4);
  END;


  Procedure sWriteDouble(FileHandle:Integer; Value:Double);
  Var
    tmpValue:Double;
    Buffer:Array[0..7] of Byte ABSOLUTE tmpValue;
  Begin
    tmpValue:=Value;
    FileWrite(FileHandle, Buffer, 8);
  end;

  Procedure sWriteDoubleMissing(FileHandle:Integer; Value:String);
  Var
    tmpValue:Double;
    Buffer:Array[0..7] of Byte ABSOLUTE tmpValue;
  Begin
    //This function handles writing missing values to stata8 files
    tmpValue:=0;
    Buffer[6]:=$E0;
    Buffer[7]:=$7F;
    IF Value='.a' THEN Buffer[5]:=1
    ELSE IF Value='.b' THEN Buffer[5]:=2
    ELSE IF Value='.c' THEN Buffer[5]:=3
    ELSE Buffer[5]:=0;     //last one write standard missing value, i.e. a dot
    FileWrite(FileHandle, Buffer, 8);
  end;

  Procedure sWriteString(FileHandle:Integer; Value:String; Len:Byte);
  Var
    Buffer : Array[0..255] of Char;
    i : Integer;
  Begin
    FillChar(Buffer, Len, 0);    //Put zeros in buffer
    For i := 1 To Length(Value) do
      Buffer[i-1] := Value[i];
    FileWrite(FileHandle, Buffer, Len);
  end;

  FUNCTION NameIsUnique:BOOLEAN;
  VAR
    TempBool, StillLooking:BOOLEAN;
    NumStr:STRING[3];
    i, Number: Integer;
    AlfaStr:STRING[10];

  BEGIN
    TempBool:=True;
    IF Assigned(ValueLabelList) THEN
      IF  ValueLabelList.IndexOf(TempName)>-1 THEN TempBool:=False;
    IF TempBool=False THEN
      BEGIN  //a dublicate name is found
        IF Length(TempName)>8 THEN TempName:=COPY(TempName,1,8);
        WHILE (Length(TempName)<8) DO TempName:=TempName+' ';
        NumStr:='';
        StillLooking:=TRUE;
        i:=8;
        WHILE (i>0) AND (Length(NumStr)<3) AND StillLooking DO
          IF (TempName[i] in NumChars) THEN
            BEGIN
              NumStr:=TempName[i]+NumStr;
              TempName[i]:=' ';
            END
          ELSE IF (TempName[i] in AlfaChars) THEN StillLooking:=FALSE
               ELSE DEC(i);
        IF (i=0) OR (NumStr='') THEN Number:=1
        ELSE Number:=StrToInt(NumStr);
        INC(Number);
        IF (Number>999) THEN TempName:='LABEL1'
        ELSE
          BEGIN
            NumStr:=IntToStr(Number);
            AlfaStr:=COPY(TempName,1,i);
            WHILE (Length(AlfaStr)+Length(NumStr)>8) DO
              AlfaStr:=COPY(AlfaStr,1,Length(AlfaStr)-1);
            TempName:=AlfaStr+NumStr;
          END;   //if new number<1000
        WHILE (Length(TempName)<8) DO TempName:=TempName+' ';
      END;   //a dublicate name is found
    NameIsUnique:=TempBool;
  END;   //NameIsUnique


BEGIN  //procdure ExportToStataFile
  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with
  WITH ExportForm DO
    BEGIN
      Ded:=SkipDeletedCheck.Checked;
      CASE StataVerCombo.ItemIndex OF
        0: StataVersion:=4;
        1: StataVersion:=6;
        2: StataVersion:=7;
        3: StataVersion:=8;  //&&
      ELSE
        StataVersion:=6;
      END;  //case
      CASE StataLetterCaseRadio.ItemIndex OF
        0: StataLetterCase:=fcUpper;
        1: StataLetterCase:=fcLower;
        2: StataLetterCase:=fcDontChange;
      END;
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with



  {Calculate NVar = Number of variables}
  NVar:=0;
  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    IF ExportForm.FieldCheckList.Checked[eN] THEN INC(NVar);

  NumFieldsExported:=NVar;

  df^.Datfile.Free;
  df^.Datfile:=NIL;
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR eN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}

  StataFile:= FileCreate(StataFileName);
  New(Buffer);
  FillChar(Buffer^,SizeOf(Buffer^),0);

  {WRITE HEADER}
  CASE StataVersion OF                      //Stata Release number ($69=ver.4/5, $6C=ver.6)
    4: Buffer^[0]:=$69;
    6: Buffer^[0]:=$6C;
    7: Buffer^[0]:=$6E;
    8: Buffer^[0]:=$71;
  ELSE
    Buffer^[0]:=$6C;
    StataVersion:=6;
  END;  //case;
  Buffer^[1]:=2;                             //Use LOHI order of data
  Buffer^[2]:=1;                             //Filetype - only 1 is legal value
  Buffer^[3]:=0;                             //Unused
  Buffer^[4]:=LO(NVar);                      //Low byte of number of variables
  Buffer^[5]:=HI(NVar);                      //High byte of number of variables
  Buffer^[6]:=LO(df^.NumRecords);            //Low byte of low word of NumRec.
  Buffer^[7]:=HI(df^.NumRecords);            //High byte of low word of NumRec.
  Buffer^[8]:=0;                             //Low byte of high word of NumRec.
  Buffer^[9]:=0;                             //High byte of high word of Numrec.
  IF StataVersion=4 THEN tmpInt:=31 ELSE tmpInt:=80;  //Length of datafilelabel varies with stataversion
  IF trim(df^.FileLabel)<>'' THEN tmpStr:=trim(df^.FileLabel)
  ELSE
    BEGIN
      tmpStr:=Format(Lang(22308),[ExtractFilename(df^.RECFilename)]);  //'Datafile created by EpiData based on %s'
      IF Length(tmpStr)>tmpInt THEN tmpStr:=Lang(22310);  //'Datafile created by EpiData'
    END;
  IF Length(tmpStr)>tmpInt THEN tmpStr:=Copy(tmpStr,1,tmpInt);
  PutStringInBuffer(10,tmpStr);              //Dataset label (i.e. title)
  PutStringInBuffer(tmpInt+11,Copy(FormatDateTime('dd mmm yyyy hh":"nn',now),1,17)); //Time_stamp
  FileWrite(StataFile, Buffer^, 29+tmpInt);
  FillChar(Buffer^, 29+tmpInt, 0);                 //Clear header info

  {WRITE DESCRIPTOR
   Descriptor includes typlist - field types
                       varlist - field names
                       srtlist - sortorder of fields
                       fmtlist - formats of fields
                       lbllist - labellist, i.e. names of value formats}

  {Write typlist - field types}
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
  BuffPointer:=0;
  IF StataVersion=8 THEN StrBaseNumber:=0 ELSE StrBaseNumber:=$7F;  //&&
  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
  //FOR eN:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          tmpC:=#0;
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
          //WITH PeField(df^.FieldList.Items[eN])^ DO
            BEGIN
              CASE FeltType OF
                ftInteger,ftIDNUM: BEGIN
                             IF FLength<3   THEN tmpC:=ByteChar   //&&
                               ELSE IF FLength<5   THEN tmpC:=IntChar  //&&
                                 ELSE IF FLength<10  THEN tmpC:=LongChar   //&&
                                   ELSE IF FLength>=10 THEN tmpC:=DoubleChar;  //&&
                             END;
                ftAlfa,ftUpperAlfa,ftCrypt: IF FLength>80 THEN tmpC:=Chr(207)
                                      ELSE tmpC:=Chr(StrBaseNumber+FLength);  //&&
                ftSoundex: tmpC:=CHR(StrBaseNumber+5);   //&&
                ftBoolean: tmpC:=ByteChar;                        //byte  &&
                ftDate,ftToday,ftEuroDate,ftEuroToday,ftYMDDate,ftYMDToday:
                  BEGIN
                    Case FLength of
                      5: tmpC:=CHR(StrBaseNumber+FLength);     //Short dates is string  &&
                      8,10: tmpC:=LongChar;               //med. and long dates: longint  &&
                    END;  //case FLength
                  END;  //case date
                ftFloat: BEGIN
                      IF FNumDecimals=0 THEN
                        BEGIN
                          IF FLength<3 THEN tmpC:=ByteChar   //&&
                          ELSE IF FLength<5 THEN tmpC:=IntChar   //&&
                          ELSE IF FLength<10 THEN tmpC:=LongChar     //&&
                          ELSE tmpC:=DoubleChar;                         //&&
                        END
                      ELSE tmpC:=DoubleChar;                                 //&&
                      END;  //case ftFloat
              ELSE
                tmpC:=#0;
              END;  //Case
              IF tmpC<>#0 THEN
                BEGIN
                  Buffer^[BuffPointer]:=ORD(tmpC);
                  INC(BuffPointer);
                END;
            END;  //with
        END;  //if write field
    END;  //for
  IF BuffPointer<>NVar THEN
    BEGIN
      eDlg(Lang(22312),mtError,[mbOK],0);  //'Unknown fieldtype used in datafile.~~Export terminated.'
      FileClose(Statafile);
      Exit;
    END;
  FileWrite(StataFile, Buffer^, NVar);
  FillChar(Buffer^,NVar,0);               //Clear typlist data

  {write varlist - names of fields}
  IF StataVersion>=7 THEN NameLength:=33 ELSE NameLength:=9;  //&&
  tmpNVar:=0;

  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
            BEGIN
              IF FeltType<>ftQuestion THEN
                BEGIN
                  INC(tmpNVar);
                  tmpStr:=MakeName(FName);
                  tmpStr:=Trim(FName);
                  CASE StataLetterCase OF
                    fcUpper: tmpStr:=ANSIUpperCase(tmpStr);
                    fcLower: tmpStr:=ANSILowerCase(tmpStr);
                  END;  //Case
                  IF Length(tmpStr)>NameLength-1 THEN tmpStr:=Copy(tmpStr,1,NameLength-1);
                  PutStringInBuffer(NameLength*(tmpNVar-1),tmpStr);
                END;  //if felttype<>ftQuestion
            END;   //with
        END;  //if write field
    END;  //for eN
  FileWrite(StataFile, Buffer^, NameLength*NVar);
  FillChar(Buffer^, NameLength*NVar, 0);           //Clear varlist data

  {write srtlist - sortorder of fields}
  {No sortorder is written, only zeros to indicated end of list}
  FileWrite(StataFile, Buffer^, 2*(NVar+1));

  {write fmtlist - formats of fields}
  tmpNVar:=0;

  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
            BEGIN
              CASE FeltType OF
                ftInteger,ftIDNUM: tmpStr:='%'+IntToStr(FLength)+'.0f';
                ftFloat: tmpStr:='%'+IntToStr(FLength)+'.'+IntToStr(FNumDecimals)+'f';
                ftBoolean: tmpStr:='%1.0f';
                ftAlfa,ftUpperAlfa,ftCrypt: tmpStr:='%'+IntToStr(FLength)+'s';
                ftSoundex: tmpStr:='%5s';
                ftToday,ftDate,ftEuroToday,ftEuroDate,ftYMDDate,ftYMDToday:
                  BEGIN
                    Case FLength of
                      5:     tmpStr:='%5s';
                      8,10:  tmpStr:='%d';
                    END;  //case FLength
                  END;  //case date
              ELSE
                tmpStr:='';
              END;   //case FeltType
              IF tmpStr<>'' THEN
                BEGIN
                  INC(tmpNVar);
                  PutStringInBuffer(12*(tmpNVar-1),tmpStr)
                END
              ELSE IF FeltType<>ftQuestion THEN
                BEGIN
                   eDlg(Lang(22312),mtError,[mbOK],0);  //Unknown fieldtype used in datafile.~~Export terminated.
                   FileClose(Statafile);
                   Exit;
                END;
            END;  //with
        END;   //if write Field
    END;  //for eN
  FileWrite(StataFile, Buffer^, 12*NVar);
  FillChar(Buffer^, 12*NVar, 0);           //Clear fmtlist data

  {write lbllist - names of value labels accociated with the variables}
  {Make list of ValueLabels in use - ONLY ValueLabels used with Integerfields!}
  TRY
    ValueLabelList:=TStringList.Create;
    FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
      BEGIN
        IF ExportForm.FieldCheckList.Checked[eN] THEN
          BEGIN
            WITH PeField(ExportForm.FieldCheckList.items.Objects[eN])^ DO
              BEGIN
                FieldN:=-1;
                IF (FeltType=ftInteger) OR ((FeltType=ftFloat) AND (FNumDecimals=0)) THEN
                  BEGIN
                    IF (FValueLabel<>'') THEN
                      BEGIN
                        TempName:=AnsiUpperCase(FValueLabel);
                        eN2:=ValueLabelList.IndexOf(TempName);
                        {Check if all values are integers}
                        ok:=true;
                        tmpLabelRec:=FCommentLegalRec;
                        WHILE (tmpLabelRec<>NIL) AND (ok) DO
                          BEGIN
                            //IF (tmpLabelRec^.Value[1]<>'*') AND (NOT (IsInteger(tmpLabelRec^.Value))) THEN ok:=False;
                            IF NOT (IsInteger(tmpLabelRec^.Value)) THEN ok:=False;
                            tmpLabelRec:=tmpLabelRec^.Next;
                          END;  //while
                        {is label allready added to list and are all values integers?}
                        IF (eN2=-1) AND (ok) THEN
                          BEGIN
                            ValueLabelList.AddObject(TempName,TObject(FCommentLegalRec));
                            FieldN:=ValueLabelList.Count-1;
                          END
                        ELSE FieldN:=eN2;
                      END;
                  END;  //if not ftQuestion
              END;  //with
          END;  //if write field
      END;  //for
  EXCEPT
    ValueLabelList.Free;
    ErrorMsg(Format(Lang(20204),[831]));   //'Out of memory (ref.code 831)'
    FileClose(Statafile);
    Exit;
  END;

  {Make valuelabel names a maximum of 8 chars}
  {Change 29/6-00: Labels are given the name epdX where X is a running number}
  {Change 19/8-02: Keep valuelabel's name in Stata 7}
  IF ValueLabelList.Count>0 THEN
    BEGIN
      IF StataVersion>=7 THEN   //&&
        BEGIN
          FOR eN:=0 TO ValueLabelList.Count-1 DO
            BEGIN
              IF (Length(trim(ValueLabelList[eN]))>32) or (pos(' ',trim(ValueLabelList[eN]))>0) THEN
                BEGIN
                  ok:=true;
                  s:=trim(ValueLabelList[eN]);
                  FOR eN2:=1 TO Length(s) DO
                    IF (s[eN2]=' ') or (s[eN2]='$') THEN s[eN2]:='_';
                  eN2:=0;
                  IF Length(s)>32 THEN s:=copy(s,1,32);
                  REPEAT
                    IF ValueLabelList.IndexOf(s)<>-1 THEN
                      BEGIN
                        INC(eN2);
                        s:=copy(s,1,32-Length(IntToStr(eN2)))+IntToStr(eN2);
                        ok:=false;
                      END
                    ELSE ok:=true;
                  UNTIL ok;
                  ValueLabelList[eN]:=s;
                END;  //if length>32
            END;  //for
        END
      ELSE
        BEGIN
          FOR eN:=0 TO ValueLabelList.Count-1 DO
            ValueLabelList[eN]:='epd'+IntToStr(eN+1);
        END;
    END;  //if valueLabelList.Count>0

  {Write list of valuelabels}
  tmpNVar:=0;

  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
            BEGIN
              IF FieldN<>-1 THEN PutStringInBuffer(tmpNVar*NameLength,ValueLabelList[FieldN]);
              IF FeltType<>ftQuestion THEN INC(tmpNVar);
            END;  //with
        END;  //if write field
    END;  //for
  FileWrite(StataFile, Buffer^, NameLength*NVar);
  FillChar(Buffer^, NameLength*NVar, 0);           //Clear lbllist data

  {WRITE VARIABLE LABELS}
  IF StataVersion=4 THEN tmpInt:=31 ELSE tmpInt:=80;   //Length of variable label varies with stataversion
  FOR eN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[eN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[eN])^ DO
            BEGIN
              IF FeltType<>ftQuestion THEN
                BEGIN
                  tmpStr:=trim(FVariableLabel);
                  IF Length(tmpStr)>tmpInt THEN tmpStr:=Copy(tmpStr,1,tmpInt);
                  sWriteString(StataFile,tmpStr,tmpInt+1);   //tmpInt+1 to make string 0-terminated
                END;  //if felttype
            END;  //with
        END;  //if write field
    END;  //for eN


  {WRITE EXPANSION FIELDS}
  {No data are written - only 3 zeros to indicate end of list}
  IF StataVersion>=7 THEN FileWrite(StataFile, Buffer^, 5)  //&&
  ELSE FileWrite(StataFile,Buffer^,3);

  {WRITE DATA}
  RecordsWritten:=0;
  UserAborts:=False;
  FilterOK:=True;
  HandleVarsDf:=df;
  UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
  IF UseIndex THEN
    BEGIN
      ApplyIndex(df);
      InitSortIndex(df);
    END;
  TRY
    FOR CurObs:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,CurObs) THEN
          BEGIN
            ProgressForm.pBar.Position:=CurObs;
            ProgressForm.pLabel.Caption:=' '+Format(Lang(22300),[CurObs]);  //'Exporting record no. %d'
            Application.ProcessMessages;
          END;

        //eReadOnlyNextRecord(df,ReadOnlyRecFile);
        IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,CurObs))
        ELSE eReadOnlyRecord(df,ReadOnlyRecFile,CurObs);


        IF UseFilter THEN
          BEGIN
            TRY
              E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
              IF Assigned(E) THEN
                BEGIN
                  IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                  ELSE
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      sWriteByte(StataFile,$1A);
                      FileClose(StataFile);
                      Dispose(Buffer);
                      DeleteFile(StataFilename);
                      CloseFile(ReadOnlyRecFile);
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //if assigned(E)
            EXCEPT
              On Er:EExpression do
                BEGIN
                  ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                  sWriteByte(StataFile,$1A);
                  FileClose(StataFile);
                  Dispose(Buffer);
                  DeleteFile(StataFilename);
                  CloseFile(ReadOnlyRecFile);
                  UserAborts:=True;
                  Exit;
                END;
            END;  //try..except
          END;  //if UseFilter

        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
          BEGIN
            INC(RecordsWritten);
            FOR CurVar:=0 TO ExportForm.FieldCheckList.items.Count-1 DO
              BEGIN
                IF ExportForm.FieldCheckList.Checked[CurVar] THEN
                  BEGIN
                    WITH PeField(ExportForm.FieldCheckList.Items.Objects[CurVar])^ DO
                      BEGIN
                        tmpStr:=FFieldText;
                        IF trim(tmpStr)='' THEN
                          BEGIN
                            IsMissing:=True;
                            MisVal:='.';
                          END
                        ELSE
                          BEGIN
                            IsMissing:=False;
                            MisVal:='';
                          END;
                        IF (StataVersion>=8) AND (FeltType in [ftInteger,ftIDNUM,ftFloat])
                        AND (FNumDecimals=0) AND (FLength<10) AND (NOT IsMissing) THEN
                          BEGIN
                            IF FFieldText=df^.GlobalMissingValues[0] THEN MisVal:='.a'
                            ELSE IF FFieldText=df^.GlobalMissingValues[1] THEN MisVal:='.b'
                            ELSE IF FFieldText=df^.GlobalMissingValues[2] THEN MisVal:='.c';
                            IF FFieldText=FMissingValues[0] THEN MisVal:='.a'
                            ELSE IF FFieldText=FMissingValues[1] THEN MisVal:='.b'
                            ELSE IF FFieldText=FMissingValues[2] THEN MisVal:='.c';
                          END;
                        IF FeltType=ftFloat THEN
                          BEGIN
                            IF DecimalSeparator<>'.'
                            THEN WHILE Pos('.',tmpStr)>0 DO tmpStr[Pos('.',tmpStr)]:=DecimalSeparator;
                            IF DecimalSeparator<>',' THEN
                            WHILE Pos(',',tmpStr)>0 DO tmpStr[Pos('.',tmpStr)]:=DecimalSeparator;
                          END;
                        CASE FeltType of
                          ftInteger,ftIDNUM: BEGIN
                            IF NOT (IsInteger(tmpStr)) THEN IsMissing:=True;
                            CASE FLength OF
                              1,2: BEGIN
                                     IF StataVersion<8 THEN
                                       BEGIN
                                         IF IsMissing THEN tmpByte:=$7F ELSE tmpByte:=StrToInt(tmpStr);
                                       END
                                     ELSE
                                       BEGIN
                                         IF MisVal='.a' THEN tmpByte:=102
                                         ELSE IF MisVal='.b' THEN tmpByte:=103
                                         ELSE IF MisVal='.c' THEN tmpByte:=104
                                         ELSE IF MisVal='.' THEN tmpByte:=101
                                         ELSE tmpByte:=StrToInt(tmpStr);
                                       END;
                                     sWriteByte(StataFile,tmpByte);
                                   END;
                              3,4: BEGIN
                                     IF StataVersion<8 THEN
                                       BEGIN
                                         IF IsMissing THEN tmpInt:=$7FFF ELSE tmpInt:=StrToInt(tmpStr);
                                       END
                                     ELSE
                                       BEGIN
                                         IF MisVal='.a' THEN tmpInt:=$7FE6
                                         ELSE IF MisVal='.b' THEN tmpInt:=$7FE7
                                         ELSE IF MisVal='.c' THEN tmpInt:=$7FE8
                                         ELSE IF MisVal='.' THEN tmpInt:=$7FE5
                                         ELSE tmpInt:=StrToInt(tmpStr);
                                       END;
                                     sWriteWord(StataFile,tmpInt);
                                   END;
                              5,6,7,8,9: BEGIN
                                     IF StataVersion<8 THEN
                                       BEGIN
                                         IF IsMissing THEN tmpLongInt:=$7FFFFFFF ELSE tmpLongInt:=StrToInt(tmpStr);
                                       END
                                     ELSE
                                       BEGIN
                                         IF MisVal='.a' THEN tmpLongInt:=$7FFFFFE6
                                         ELSE IF MisVal='.b' THEN tmpLongInt:=$7FFFFFE7
                                         ELSE IF MisVal='.c' THEN tmpLongInt:=$7FFFFFE8
                                         ELSE IF MisVal='.' THEN tmpLongInt:=$7FFFFFE5
                                         ELSE tmpLongInt:=StrToInt(tmpStr);
                                       END;
                                     sWriteDoubleWord(StataFile,tmpLongInt);
                                   END;
                              ELSE   BEGIN
                                       IF StataVersion<8 THEN
                                         BEGIN
                                           IF IsMissing THEN tmpDouble:=Power(2,1023) ELSE tmpDouble:=StrToFloat(tmpStr);
                                           sWriteDouble(StataFile,tmpDouble);
                                         END
                                       ELSE
                                         BEGIN
                                           IF MisVal<>'' THEN sWriteDoubleMissing(StataFile,MisVal)
                                           ELSE
                                             BEGIN
                                               tmpDouble:=StrToFloat(tmpStr);
                                               sWriteDouble(StataFile,tmpDouble);
                                             END;
                                         END;
                                     END;
                            END;   //case FLength
                            END;  //case ftInteger,ftIDNUM
                          ftFloat: BEGIN
                            IF (FNumDecimals>0) OR (FLength>=10) THEN
                              BEGIN
                                FOR eN:=1 TO Length(tmpStr) DO
                                  IF NOT (tmpStr[eN] in FloatChars) THEN IsMissing:=True;
                                IF StataVersion<8 THEN
                                  BEGIN
                                    IF IsMissing THEN tmpDouble:=Power(2,1023) ELSE tmpDouble:=StrToFloat(tmpStr);
                                    sWriteDouble(StataFile,tmpDouble);
                                  END
                                ELSE
                                  BEGIN
                                    IF MisVal<>'' THEN sWriteDoubleMissing(StataFile,MisVal)
                                    ELSE
                                      BEGIN
                                        tmpDouble:=StrToFloat(tmpStr);
                                        sWriteDouble(StataFile,tmpDouble);
                                      END;
                                  END;    //if stataversion<8
                              END  //if numdecimals>0
                            ELSE
                              BEGIN
                                CASE FLength OF
                                  1,2: BEGIN
                                         IF StataVersion<8 THEN
                                           BEGIN
                                             IF IsMissing THEN tmpByte:=$7F ELSE tmpByte:=StrToInt(tmpStr);
                                           END
                                         ELSE
                                           BEGIN
                                             IF MisVal='.a' THEN tmpByte:=102
                                             ELSE IF MisVal='.b' THEN tmpByte:=103
                                             ELSE IF MisVal='.c' THEN tmpByte:=104
                                             ELSE IF MisVal='.' THEN tmpByte:=101
                                             ELSE tmpByte:=StrToInt(tmpStr);
                                           END;
                                         sWriteByte(StataFile,tmpByte);
                                       END;
                                  3,4: BEGIN
                                         IF StataVersion<8 THEN
                                           BEGIN
                                             IF IsMissing THEN tmpInt:=$7FFF ELSE tmpInt:=StrToInt(tmpStr);
                                           END
                                         ELSE
                                           BEGIN
                                             IF MisVal='.a' THEN tmpInt:=$7FE6
                                             ELSE IF MisVal='.b' THEN tmpInt:=$7FE7
                                             ELSE IF MisVal='.c' THEN tmpInt:=$7FE8
                                             ELSE IF MisVal='.' THEN tmpInt:=$7FE5
                                             ELSE tmpInt:=StrToInt(tmpStr);
                                           END;
                                         sWriteWord(StataFile,tmpInt);
                                       END;
                                  5,6,7,8,9: BEGIN
                                         IF StataVersion<8 THEN
                                           BEGIN
                                             IF IsMissing THEN tmpLongInt:=$7FFFFFFF ELSE tmpLongInt:=StrToInt(tmpStr);
                                           END
                                         ELSE
                                           BEGIN
                                             IF MisVal='.a' THEN tmpLongInt:=$7FFFFFE6
                                             ELSE IF MisVal='.b' THEN tmpLongInt:=$7FFFFFE7
                                             ELSE IF MisVal='.c' THEN tmpLongInt:=$7FFFFFE8
                                             ELSE IF MisVal='.' THEN tmpLongInt:=$7FFFFFE5
                                             ELSE tmpLongInt:=StrToInt(tmpStr);
                                           END;
                                         sWriteDoubleWord(StataFile,tmpLongInt);
                                       END;
                                END;  //case
                              END;  //else
                            END;  //case ftFloat
                          ftAlfa,ftUpperAlfa,ftCrypt: sWriteString(StataFile,tmpStr,FLength);
                          ftDate,ftToday,ftEuroDate,ftEuroToday,
                            ftYMDDate,ftYMDToday: BEGIN
                            IF (trim(tmpStr)<>'') AND (NOT mibIsDate(tmpStr,FeltType)) THEN
                              BEGIN
                                ErrorMsg(Format(Lang(22306),   //Illegal date found in record # %d, field %s~Export terminates.
                                [CurObs,trim(PeField(df^.FieldList.Items[CurVar])^.FName)]));
                                sWriteByte(StataFile,$1A);
                                FileClose(StataFile);
                                Dispose(Buffer);
                                DeleteFile(StataFilename);
                                CloseFile(ReadOnlyRecFile);
                                UserAborts:=True;
                                Exit;
                              END;
                            IF FLength=5 THEN sWriteString(StataFile,tmpStr,5)
                            ELSE
                              BEGIN
                                IF StataVersion<8 THEN
                                  BEGIN
                                    IF IsMissing THEN tmpLongInt:=$7FFFFFFF
                                    ELSE tmpLongInt:=Round(ftDateToDateTime(tmpStr,
                                    FeltType,FLength)-21916);  {Date is converted from
                                                               Delphi's 30/12-1899 base
                                                               to Stata's 1/1-1960 base
                                                               by substracting 21916 days}
                                  END
                                ELSE
                                  BEGIN
                                    IF MisVal='.a' THEN tmpLongInt:=$7FFFFFE6
                                    ELSE IF MisVal='.b' THEN tmpLongInt:=$7FFFFFE7
                                    ELSE IF MisVal='.c' THEN tmpLongInt:=$7FFFFFE8
                                    ELSE IF MisVal='.' THEN tmpLongInt:=$7FFFFFE5
                                    ELSE tmpLongInt:=Round(ftDateToDateTime(tmpStr,FeltType,FLength)-21916);
                                  END;
                                sWriteDoubleWord(StataFile,tmpLongInt);
                              END;
                            END;  //Case ftDate
                          ftBoolean: BEGIN
                            IF IsMissing THEN
                              BEGIN
                                IF StataVersion<8 THEN tmpByte:=$7F
                                ELSE tmpByte:=$66;
                              END
                            ELSE IF tmpStr='Y' THEN tmpByte:=1
                              ELSE tmpByte:=0;
                            sWriteByte(StataFile,tmpByte);
                            END;  //case ftBoolean
                          ftSoundex: BEGIN
                            IF Length(tmpStr)>5 THEN tmpStr:=Copy(tmpStr,1,5);
                            sWriteString(StataFile,tmpStr,5);
                            END;  //case ftSoundex
                        END;   //Case
                      END;  //with
                  END;  //if write field
              END;  //for CurVar
          END;   //if write data
        //Application.ProcessMessages;
        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN
              BEGIN
                sWriteByte(StataFile,$1A);
                FileClose(StataFile);
                Dispose(Buffer);
                DeleteFile(StataFilename);
                CloseFile(ReadOnlyRecFile);
                Exit;
              END
            ELSE UserAborts:=False;
          END;
      END;  //for CurObs
  EXCEPT
    ErrorMsg(Format(Lang(22304),[CurObs]));  //'Error occured during export of record #%d'
    sWriteByte(StataFile,$1A);
    FileClose(StataFile);
    Dispose(Buffer);
    DeleteFile(StataFilename);
    CloseFile(ReadOnlyRecFile);
    Exit;
  END;  //try..Except
  NumRecordsExported:=RecordsWritten;

  {WRITE EOF-marker here if no valuelabels are to be written}
//  sWriteByte(StataFile,$1A);

  {Write VALUE-LABELS}
  LabelsTruncated:=False;
  IF ValueLabelList.Count>0 THEN
    BEGIN
      FOR eN:=0 TO ValueLabelList.Count-1 DO
        BEGIN
          {Count no. of entries in label}
          EntriesInLabel:=0;
          tmpLabelRec:=PLabelRec(ValueLabelList.Objects[eN]);
          CommentedEntries:=0;
          WHILE tmpLabelRec<>NIL DO
            BEGIN
              INC(EntriesInLabel);
              //IF tmpLabelRec^.Value[1]='*' THEN INC(CommentedEntries);
              tmpLabelRec:=tmpLabelRec^.Next;
            END;  //while
          IF (EntriesInLabel-CommentedEntries)>0 THEN
            BEGIN
              IF StataVersion=4 THEN
                BEGIN   //write value labels in Stata ver. 4/5 format
                  {Fill out value label header}
                  PutWordInBuffer(0,Word(EntriesInLabel-CommentedEntries));
                  PutStringInBuffer(2,ValueLabelList[eN]);
                  {Fill out entries}
                  tmpLabelRec:=PLabelRec(ValueLabelList.Objects[eN]);
                  //eN4:=-1;
                  FOR eN2:=0 TO EntriesInLabel-1 DO
                    BEGIN
                      IF tmpLabelRec<>NIL THEN
                        BEGIN
                          //IF tmpLabelRec^.Value[1]<>'*' THEN
                          IF true THEN
                            BEGIN
                              //INC(eN4);
                              PutWordInBuffer(12+(eN2*2),Word(StrToInt(tmpLabelRec^.Value)));
                              tmpStr:=tmpLabelRec^.Text;
                              IF Length(tmpStr)>8 THEN
                                BEGIN
                                  tmpStr:=Copy(tmpStr,1,8);
                                  LabelsTruncated:=True;
                                END;
                              PutStringInBuffer(12+(EntriesInLabel*2)+(eN2*8),tmpStr);
                            END;
                          tmpLabelRec:=tmpLabelRec^.Next;
                        END;
                    END;  //for eN2
                  {Write buffer to file and clear buffer}
                  FileWrite(StataFile, Buffer^, 12+(EntriesInLabel*2)+(EntriesInLabel*8));
                  FillChar(Buffer^, 12+(EntriesInLabel*2)+(EntriesInLabel*8), 0);
                END
              ELSE
                BEGIN  //write value labels in Stata ver. 6 format
                  {Fill out value label header}
                  PutStringInBuffer(4,ValueLabelList[eN]);  //Labelname
                  PutLongIntInBuffer(NameLength+7,LongInt(EntriesInLabel-CommentedEntries));  //Number of entries in label
                  TxtTableLength:=0;
                  TxtTableStart:=4+4+(4*(EntriesInLabel-CommentedEntries))+(4*(EntriesInLabel-CommentedEntries))+NameLength+7;
                  {Fill out value_label_table - iterate on every entry}
                  tmpLabelRec:=PLabelRec(ValueLabelList.Objects[eN]);
                  eN4:=-1;
                  FOR eN2:=0 TO EntriesInLabel-1 DO
                    BEGIN
                      //IF tmpLabelRec^.Value[1]<>'*' THEN
                      IF true THEN
                        BEGIN
                          INC(eN4);
                          PutLongintInBuffer(15+NameLength+(4*eN2),LongInt(TxtTableLength));  //write off[entry]
                          PutLongIntInBuffer(15+NameLength+(4*(EntriesInLabel-CommentedEntries))+(4*eN2),LongInt(StrToInt(tmpLabelRec^.Value)));  //write val[entry]
                          IF tmpLabelRec<>NIL THEN tmpStr:=trim(tmpLabelRec^.Text) ELSE tmpStr:='';
                          FOR eN3:=1 TO Length(tmpStr) DO
                            BEGIN
                              Buffer^[TxtTableStart+TxtTableLength]:=ORD(tmpStr[eN3]);  //write txt[entry]
                              INC(TxtTableLength);
                            END;  //for eN3
                          INC(TxtTableLength);   //put a #0 in end of entry-text
                        END;
                      IF tmpLabelRec<>NIL THEN tmpLabelRec:=tmpLabelRec^.Next;
                    END;  //for eN2
                  {Write length of txt[]}
                  PutLongintInBuffer(11+NameLength,LongInt(TxtTableLength));
                  {Write length of value_label_table}
                  ValueLabelTableLength:=4+4+(4*(EntriesInLabel-CommentedEntries))+(4*(EntriesInLabel-CommentedEntries))+TxtTableLength;
                  PutLongIntInBuffer(0,LongInt(ValueLabelTableLength));
                  {Write buffer to file and clear buffer}
                  FileWrite(StataFile, Buffer^, NameLength+7+ValueLabelTableLength);
                  FillChar(Buffer^, sizeOf(Buffer^), 0);
                END;  //write value labels in stata 6 version
            END;  //if EntriesInLabel>0
        END;  //for eN
    END;  //if ValueLabelList.Count>0

  {WRITE EOF-marker}
  sWriteByte(StataFile,$1A);

  ValueLabelList.Free;
  CloseFile(ReadOnlyRecFile);
  FileClose(StataFile);
  Dispose(Buffer);

  IF RecordsWritten<>df^.NumRecords THEN
    BEGIN
      Assign(tmpStataFile,StataFilename);
      Reset(tmpStataFile);
      Seek(tmpStataFile,6);
      tmpByte:=LO(RecordsWritten);  //Low byte of low word of RecordsWritten
      Write(tmpStataFile,tmpByte);
      tmpByte:=HI(RecordsWritten);  //High byte of low word of RecordsWritten
      Write(tmpStataFile,tmpByte);
      CloseFile(tmpStataFile);
    END;

  IF LabelsTruncated THEN
  eDlg(Lang(22314)    //'Stata version 4 and 5 can only handle value labels up~to a length of 8 characters.'
  +#13#13+Format(Lang(22316),    //%s contains value labels with a length of more~than 8 characters and these have been truncated to 8 characters.
  [df^.RECFilename]), mtWarning,[mbOK],0);
END;   //procedure ExportToStataFile


procedure ExportToSPSSFile(VAR df:PDatafileInfo; CONST ExpFilename:String);
CONST
  CardWidth=80;
  MaxAlfa=80;
VAR
  ExLin,ValueLabelList,FieldsInValueLabel:TStringList;
  s,ExpRecLin,InStr,tmpS:String;
  exN, exN2, FSize, Column, RecSize,I,n,intFieldN,RecCount:Integer;
  DeD:Boolean;
  ReadOnlyRecFile,DataOutFile:TextFile;
  DataOutFilename: String;
  FromRecNo,ToRecNo: Integer;
  UseFilter,FilterOK,tmpBool,FirstField: Boolean;
  UseIndex: Boolean;
  E:IValue;
  tmpLabelRec: PLabelRec;
  HasLongNamesInFields:Boolean;
  tmpDate: TDateTime;
BEGIN
  HasLongNamesInFields:=False;
  //Reduce length of fieldnames to 8 chars
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      IF PeField(df^.FieldList.Items[n])^.Felttype<>ftQuestion THEN
        BEGIN
          s:=trim(PeField(df^.FieldList.Items[n])^.FName);
          IF Length(s)>8 THEN
            BEGIN
              HasLongNamesInFields:=True;
              s:=Copy(s,1,8);
              IF NOT NameIsUnique(s,df,8) THEN REPEAT UNTIL NameIsUnique(s,df,8);
              PeField(df^.FieldList.Items[n])^.FName:=s;
            END;  //if long fieldname
        END;  //if
    END;  //for n
{  n:=0;
  WHILE (HasLongNamesInFields=False) AND (n<df^.FieldList.Count-1) DO
    BEGIN
      IF (PeField(df^.FieldList.Items[n])^.Felttype<>ftQuestion)
      AND (Length(trim(Pefield(df^.FieldList.Items[n])^.FName))>8) THEN HasLongNamesInFields:=True;
      INC(n);
    END;  //while
  IF HasLongNamesInFields THEN
    BEGIN
      ErrorMsg(Format(Lang(22354)+#13+   //'The datafile %s contains long fieldnames (more than 8 characters) and cannot be exported to %s.'
      Lang(22356),[df^.RECFilename,'SPSS','SPSS']));  //'Please change the long fieldsnames before exporting to %s-format'
      UserAborts:=True;
      Exit;
    END;
}
  DataOutFilename:=ChangeFileExt(ExpFilename,'.txt');
  IF FileExists(DataOutFilename) THEN
    BEGIN
      IF WarningDlg(Format(Lang(21500),[DataOutFilename]))<>mrOK THEN  //21500=A file with name %s already exists.~~Overwrite existing file?
        BEGIN
          UserAborts:=True;
          Exit;
        END
      ELSE tmpBool:=DeleteFile(DataOutFilename);
      IF tmpBool=False THEN
        BEGIN
          ErrorMsg(Format(Lang(23358),[DataOutFilename]));  //'The file %s cannot be deleted.'
          Exit;
        END;
    END;  //if fileexists

  Ded:=ExportForm.SkipDeletedCheck.Checked;
  ExLin:=TStringList.Create;
  WITH ExportForm DO
    BEGIN
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with

  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with

  {Initialize inputfile}
  //CloseFile(df^.DatFile);
  df^.Datfile.Free;   //§§§
  df^.Datfile:=NIL;  //§§§
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR exN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}


  {Write header}
  ExLin.Append('* '+Lang(22360)+'   .');   //'EpiData created two files by exporting'
  ExLin.Append('* '+df^.RECFilename+' .');
  ExLin.Append('* .');
  ExLin.Append('* 1. '+ExpFilename+' .');
  ExLin.append(Format('*    '+Lang(22362)+'.',['SPSS']));   //'is this %s command file'
  ExLin.Append('* 2. '+DataOutFilename+' .');
  ExLin.Append('*    '+Lang(22364)+'.');   //'is an ASCII text file with the raw data'
  ExLin.Append('*');
  ExLin.Append('* '+Lang(22366)+'.');   //'You may modify the commands before running it'
  ExLin.Append('* '+Lang(22368)+'  .');   //'Uncomment (remove the *) the last command (SAVE) if the'
  ExLin.Append('* '+Lang(22370)+'.');   //'command file should save the data as a SPSS datafile'
  ExLin.Append('');
  ExLin.Append('SET DECIMAL=dot.');  //added 9apr04
  ExLin.Append('DATA LIST');
  ExLin.append('  FILE = "'+DataOutFilename+'"');
  i:=1;
  intfieldN:=1;
  RecCount:=1;
  FirstField:=True;
  FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[exN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
            BEGIN
              IF Felttype<>ftQuestion THEN
                BEGIN
                  IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                  IF intFieldN+FSize-1>CardWidth THEN
                    BEGIN
                      //Begin new record
                      INC(RecCount);
                      FieldN:=1;
                      intFieldN:=FSize+1;
                    END
                  ELSE
                    BEGIN
                      IF FirstField THEN
                        BEGIN
                          FirstField:=False;
                          FieldN:=-1;
                        END
                      ELSE FieldN:=intFieldN;
                      intFieldN:=intFieldN+FSize;
                    END;
                  //IF (FeltType in [ftInteger,ftFloat,ftIDNUM]) THEN FSize:=FLength
                  //ELSE IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                  //IF (I Mod CardWidth)+FSize < CardWidth THEN INC(I,FSize)
                  //ELSE I := (I Div CARDWIDTH + 1) * CARDWIDTH + FSize;
                END;  //if not ftQuestion
             END;  //with
        END;  //if Checked
    END;  //for exN

  ExLin.Append('  RECORDS='+IntToStr(RecCount));              //I DIV CardWidth+1));
  s:='  / ';
  Column:=28;
  RecSize:=1;
  FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[exN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
            BEGIN
              IF Felttype<>ftQuestion THEN
                BEGIN
                  IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                  //IF ((RecSize MOD CardWidth)+FSize+1>=CardWidth) OR (recSize MOD CardWidth=0) THEN
                  //IF NOT ((Recsize Mod CardWidth)+FSize<CardWidth) THEN
                  //IF (RecSize MOD CardWidth)+FSize>CardWidth THEN    //Fra version 2.0
                  IF FieldN=1 THEN
                    BEGIN
                      ExLin.Append(s);
                      Column:=17;
                      s:='  / ';
                      RecSize:=(RecSize DIV CardWidth+1)*CardWidth+1;
                    END;  //if
                  IF Column+38>CardWidth THEN
                    BEGIN
                      ExLin.Append(s);
                      s:='    ';
                      Column:=16;
                    END;
                  //s:=s+AnsiUpperCase(trim(FName))+' '+IntToStr(RecSize MOD CardWidth);
                  s:=s+AnsiUpperCase(trim(FName));
                  IF FieldN=-1 THEN s:=s+' 1' ELSE s:=s+' '+IntToStr(FieldN);
                  Column := Column + Length(trim(FName)) + 1;
                  IF FSize > 1 THEN
                    BEGIN
                      //s:=s+'-'+IntToStr( (RecSize+FSize-1) MOD CardWidth);
                      IF FieldN=-1 THEN s:=s+'-'+IntToStr(FSize)
                      ELSE s:=s+'-'+IntToStr( FieldN+FSize-1 );
                      INC(Column,4);
                    END;
                  INC(Column,2);
                  IF (FeltType in [ftToday,ftDate,ftYMDDate,ftYMDToday])  THEN s:=s+'(ADATE)'   
                  ELSE IF (Felttype=ftEuroDate) or (Felttype=ftEuroToday) THEN s:=s+'(EDATE)'
                  ELSE IF NOT (FeltType in [ftInteger,ftFloat,ftIDNUM]) THEN s:=s+'(A)';
                  IF (Felttype=ftFloat) AND (FNumDecimals>0) THEN s:=s+'('+IntToStr(FNumDecimals)+')';
                  RecSize:=RecSize+FSize;
                  INC(Column);
                  s:=s+' ';
                END;  //if not ftQuestion
            END;  //with
        END;  //if Checked
    END; //for exN
  s[Length(s)]:='.';
  ExLin.Append(s);
  ExLin.Append('');

  {Write Data}
  AssignFile(DataOutFile,DataoutFilename);
  Rewrite(DataOutFile);
  UserAborts:=False;
  FilterOK:=True;
  HandleVarsDf:=df;
  UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
  IF UseIndex THEN
    BEGIN
      ApplyIndex(df);
      InitSortIndex(df);
    END;

  TRY
    FOR exN:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,exN) THEN
          BEGIN
            ProgressForm.pBar.Position:=exN;
            ProgressForm.pLabel.Caption:=Format(Lang(22300),[exN]);   //' Exporting record no. %d'
            Application.ProcessMessages;
          END;
        //eReadOnlyNextRecord(df,ReadOnlyRecFile);
        IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,exN))
        ELSE eReadOnlyRecord(df,ReadOnlyRecFile,exN);

        IF UseFilter THEN
          BEGIN
            TRY
              E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
              IF Assigned(E) THEN
                BEGIN
                  IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                  ELSE
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      ExLin.Free;
                      CloseFile(DataOutFile);
                      tmpBool:=DeleteFile(DataOutFilename);
                      CloseFile(ReadOnlyRecFile);
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //if assigned(E)
            EXCEPT
              On Er:EExpression do
                BEGIN
                  ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                  DisposeDatafilePointer(df);
                  ExLin.Free;
                  CloseFile(DataOutFile);
                  tmpBool:=DeleteFile(DataOutFilename);
                  CloseFile(ReadOnlyRecFile);
                  UserAborts:=True;
                  Exit;
                END;
            END;  //try..except
          END;  //if UseFilter

        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
          BEGIN
            ExpRecLin:='';
            Column:=1;
            FOR exN2:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
              BEGIN
                IF ExportForm.FieldCheckList.Checked[exN2] THEN
                  BEGIN
                    WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN2])^ DO
                      IF Felttype<>ftQuestion THEN
                        BEGIN
                          FSize:=FLength;
                          Case FeltType of
                            ftInteger,ftIDNUM,ftFloat:
                              BEGIN
                                s:=trim(FFieldText);
                                IF Length(s)<FLength THEN s:=cFill(' ',FLength-Length(s))+s;
                              END;
                            ftYMDDate,ftYMDToday:
                              BEGIN
                                s:=trim(FFieldText);
                                IF s<>'' THEN
                                  BEGIN
                                    tmpDate:=mibStrToDate(s,FeltType);
                                    s:=mibDateToStr(tmpDate,ftDate);
                                  END
                                ELSE s:=cFill(' ',FLength);
                              END;
                          ELSE
                            Begin
                              s:=FitLength(trim(FFieldText),FLength);
                              IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                            END;
                          END;  //case
                          //IF Column+FSize>=CardWidth THEN
                          IF FieldN=1 THEN
                            BEGIN
                              WriteLn(DataOutFile,ExpRecLin);
                              //ExLin.Append(ExpRecLin);
                              ExpRecLin:='';
                              Column:=1;
                            END;
                          IF FSize>0 THEN ExpRecLin:=ExpRecLin+s;
                          INC(Column,FSize);
                        END;  //if not ftQuestion
                  END;  //if write field
              END;  //for exN2
            WriteLn(DataOutFile,ExpRecLin);
            //ExLin.Append(ExpRecLin);
            ExpRecLin:='';
            INC(NumRecordsExported);
          END;  //if CurRecDeleted
        //IF (exN-1) MOD 10 = 0 THEN Application.ProcessMessages;
        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN
              BEGIN
                ExLin.Free;
                CloseFile(ReadOnlyRecFile);
                CloseFile(DataOutFile);
                tmpBool:=DeleteFile(DataOutFilename);
                Exit;
              END
            ELSE UserAborts:=False;
          END;
      END;  //for exN
    CloseFile(DataOutFile);

    {write file label}
    IF trim(df^.FileLabel)<>'' THEN
      BEGIN
        ExLin.Append('FILE LABEL '+df^.FileLabel+'.');
        ExLin.Append('');
      END;

    {Write variable labels}
    s:='VARIABLE LABELS';
    FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
      BEGIN
        IF ExportForm.FieldCheckList.Checked[exN] THEN
          BEGIN
            WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
              BEGIN
                IF (Felttype<>ftQuestion) AND (trim(FVariableLabel)<>'')
                AND (AnsiUpperCase(trim(FName))<>AnsiUpperCase(trim(FVariableLabel))) THEN
                  BEGIN
                    ExLin.Append(s);
                    s:=Format('  %12s "%s"',[FName,trim(FVariableLabel)]);
                  END;
               END;  //with
          END;  //if Checked
      END;  //for exN
    IF s<>'VARIABLE LABELS' THEN
      BEGIN
        ExLin.Append(s+'.');
        ExLin.Append('');
      END;

    {Write value labels}

    {Make list of ValueLabels in use - ONLY ValueLabels used with numeric fields}
    {FieldsInValueLabel contains a list of the variables that use a specific valuelabel}
    TRY
      ValueLabelList:=TStringList.Create;
      FieldsInValueLabel:=TStringList.Create;
      FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
        BEGIN
          IF ExportForm.FieldCheckList.Checked[exN] THEN
            BEGIN
              WITH PeField(ExportForm.FieldCheckList.items.Objects[exN])^ DO
                BEGIN
                  IF (FeltType in [ftInteger,ftFloat]) AND (trim(FValueLabel)<>'') THEN
                    BEGIN
                      s:=AnsiUpperCase(FValueLabel);
                      exN2:=ValueLabelList.IndexOf(s);
                      IF exN2=-1 THEN
                        BEGIN
                          ValueLabelList.AddObject(s,TObject(FCommentLegalRec));
                          FieldsInValueLabel.Append(AnsiUpperCase(trim(FName)));
                        END
                      ELSE
                        BEGIN
                          FieldsInValueLabel[exN2]:=FieldsInValueLabel[exN2]+' '+AnsiUpperCase(trim(FName));
                        END;
                    END;  //if numeric and has FValueLabel
                END;  //with
            END;  //if write field
        END;  //for

      IF ValueLabelList.Count>0 THEN
        BEGIN
          ExLin.Append('VALUE LABELS');
          FOR exN:=0 TO ValueLabelList.Count-1 DO
            BEGIN
              {write names of fields that use the valuelabel}
              IF exN=0 THEN s:='  '+FieldsInValueLabel[exN]
              ELSE          s:=' /'+FieldsInValueLabel[exN];
              WHILE Length(s)>80 DO
                BEGIN
                  exN2:=Length(s);
                  REPEAT
                    DEC(exN2);
                  UNTIL s[exN2]=' ';
                  ExLin.Append(Copy(s,1,exN2));
                  Delete(s,1,exN2);
                  s:='  '+s;
                END;  //while
              ExLin.Append(s);
              {Write the value labels}
              tmpLabelRec:=PLabelRec(ValueLabelList.Objects[exN]);
              WHILE tmpLabelRec<>NIL DO
                BEGIN
                  ExLin.Append('    '+trim(tmpLabelRec^.Value)+'  "'+trim(tmpLabelRec^.Text)+'"');
                  tmpLabelRec:=tmpLabelRec^.Next;
                END;
            END;  //for exN
          ExLin[ExLin.Count-1]:=ExLin[ExLin.Count-1]+'.';
          ExLin.Append('');
        END;  //if ValueLabelList.Count>0

      ExLin.Append('execute.');
      ExLin.Append('*********** '+Lang(22372)+' ******************.');  //'Uncomment next line to save file'
      ExLin.Append('* SAVE OUTFILE="'+ChangeFileExt(ExpFilename,'.sav')+'".');
      ExLin.Append('***************************************************************.');
      ExLin.Append('*.');
      {ExLin.Append('* Note for European users:.');
      ExLin.Append('*      The decimal separator MUST be . (period) not , (comma).');
      ExLin.Append('*      Change from , to . in your set up of windows:.');
      ExLin.Append('*      Settings are chosen from the Windows start button by:.');
      ExLin.Append('*      Settings ? Control Panel ? International ? Numbers.');
      ExLin.Append('*      after inputting data you can change back to comma.');}
      ExLin.Append('');

    FINALLY
      ValueLabelList.Free;
      FieldsInValueLabel.Free;
    END;

  EXCEPT
    ErrorMsg(Format(Lang(22304),[exN]));   //'Error occured during export of record #%d'
    ExLin.Free;
    CloseFile(ReadOnlyRecFile);
    CloseFile(DataOutFile);
    Exit;
  END;  //try..Except
  ExLin.SaveToFile(ExpFilename);
  ExLin.Free;
  CloseFile(ReadOnlyRecFile);
END;  //procedure ExportToSPSSFile


procedure ExportToSASFile(VAR df:PDatafileInfo; CONST ExpFilename:String);
CONST
  CardWidth=80;
  MaxAlfa=80;
VAR
  ExLin,ValueLabelList,FieldsInValueLabel:TStringList;
  s,s2,ExpRecLin,InStr:String;
  exN, exN2, FSize, Column, RecSize,I,n:Integer;
  DeD:Boolean;
  ReadOnlyRecFile,DataOutFile:TextFile;
  DataOutFilename: String;
  FromRecNo,ToRecNo,LabelCounter: Integer;
  UseFilter,FilterOK,tmpBool,HasDates: Boolean;
  UseIndex: Boolean;
  E:IValue;
  tmpLabelRec: PLabelRec;
  HasLongNamesInFields: Boolean;
BEGIN
  HasDates:=False;
  HasLongNamesInFields:=False;
  //Reduce length of fieldnames to 8 chars
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      IF PeField(df^.FieldList.Items[n])^.Felttype<>ftQuestion THEN
        BEGIN
          s:=trim(PeField(df^.FieldList.Items[n])^.FName);
          IF Length(s)>8 THEN
            BEGIN
              HasLongNamesInFields:=True;
              s:=Copy(s,1,8);
              IF NOT NameIsUnique(s,df,8) THEN REPEAT UNTIL NameIsUnique(s,df,8);
              PeField(df^.FieldList.Items[n])^.FName:=s;
            END;  //if long fieldname
        END;  //if
    END;  //for n
{  n:=0;
  WHILE (HasLongNamesInFields=False) AND (n<df^.FieldList.Count-1) DO
    BEGIN
      IF (PeField(df^.FieldList.Items[n])^.Felttype<>ftQuestion)
      AND (Length(trim(Pefield(df^.FieldList.Items[n])^.FName))>8) THEN HasLongNamesInFields:=True;
      INC(n);
    END;  //while
  IF HasLongNamesInFields THEN
    BEGIN
      ErrorMsg(Format(Lang(22354)+#13+   //'The datafile %s contains long fieldnames (more than 8 characters) and cannot be exported to %s.'
      Lang(22356),[df^.RECFilename,'SAS','SAS']));  //'Please change the long fieldsnames before exporting to %s-format'
      UserAborts:=True;
      Exit;
    END;}
  DataOutFilename:=ChangeFileExt(ExpFilename,'.txt');
  IF FileExists(DataOutFilename) THEN
    BEGIN
      IF WarningDlg(Format(Lang(21500),[DataOutFilename]))<>mrOK THEN  //21500=A file with name %s already exists.~~Overwrite existing file?
        BEGIN
          UserAborts:=True;
          Exit;
        END
      ELSE tmpBool:=DeleteFile(DataOutFilename);
      IF tmpBool=False THEN
        BEGIN
          ErrorMsg(Format(Lang(22358),[DataOutFilename]));  //22358=The file %s cannot be deleted.
          Exit;
        END;
    END;  //if fileexists

  Ded:=ExportForm.SkipDeletedCheck.Checked;
  ExLin:=TStringList.Create;
  WITH ExportForm DO
    BEGIN
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with

  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with

  {Initialize inputfile}
  //CloseFile(df^.DatFile);
  df^.Datfile.Free;   //§§§
  df^.Datfile:=NIL;  //§§§
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR exN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}


  {Write header}
  ExLin.Append('* '+Lang(22360));   //'EpiData created two files by exporting'
  ExLin.Append('* '+df^.RECFilename);
  ExLin.Append('*');
  ExLin.Append('* 1. '+ExpFilename);
  ExLin.append('*    '+Format(Lang(22362),['SAS']));  //22362=is this %s command file
  ExLin.Append('* 2. '+DataOutFilename);
  ExLin.Append('*    '+Lang(22364)+'.');   //'is an ASCII text file with the raw data'
  ExLin.Append('*');
  ExLin.Append('* '+Lang(22374)+'   ;');  //'You may modify the statements file before submitting them.'
  ExLin.Append('');


  {Write value labels}

  {Make list of ValueLabels in use - ONLY ValueLabels used with numeric fields}
  {FieldsInValueLabel contains a list of the variables that use a specific valuelabel}
  TRY
    LabelCounter:=0;
    ValueLabelList:=TStringList.Create;
    FieldsInValueLabel:=TStringList.Create;
    FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
      BEGIN
        IF ExportForm.FieldCheckList.Checked[exN] THEN
          BEGIN
            WITH PeField(ExportForm.FieldCheckList.items.Objects[exN])^ DO
              BEGIN
                IF (FeltType in [ftInteger,ftFloat]) AND (trim(FValueLabel)<>'') THEN
                  BEGIN
                    s:=AnsiUpperCase(FValueLabel);
                    IF (Pos(' ',s)>0) OR (Length(s)>8) THEN
                      BEGIN
                        INC(LabelCounter);
                        s:='Label'+IntToStr(LabelCounter)+'n';
                        FValueLabel:=s;
                      END;
                    exN2:=ValueLabelList.IndexOf(s);
                    IF exN2=-1 THEN
                      BEGIN
                        ValueLabelList.AddObject(s,TObject(FCommentLegalRec));
                        FieldsInValueLabel.Append(AnsiUpperCase(trim(FName)));
                      END
                    ELSE
                      BEGIN
                        FieldsInValueLabel[exN2]:=FieldsInValueLabel[exN2]+' '+AnsiUpperCase(trim(FName));
                      END;
                  END;  //if numeric and has FValueLabel
              END;  //with
          END;  //if write field
      END;  //for

    IF ValueLabelList.Count>0 THEN
      BEGIN
        ExLin.Append('PROC FORMAT;');
        FOR exN:=0 TO ValueLabelList.Count-1 DO
          BEGIN
            ExLin.Append('  VALUE '+ValueLabelList[exN]);

            {Write the value labels}
            tmpLabelRec:=PLabelRec(ValueLabelList.Objects[exN]);
            WHILE tmpLabelRec<>NIL DO
              BEGIN
                ExLin.Append('    '+trim(tmpLabelRec^.Value)+'="'+trim(tmpLabelRec^.Text)+'"');
                tmpLabelRec:=tmpLabelRec^.Next;
              END;
            ExLin[ExLin.Count-1]:=ExLin[ExLin.Count-1]+';';
          END;  //for exN
        ExLin.Append('');
        ExLin.Append('run;');
        ExLin.Append('');
      END;
  EXCEPT
    ValueLabelList.Free;
    FieldsInValueLabel.Free;
  END;


  s:=ExtractFilename(df^.RECFilename);
  s:=Copy(s,1,Pos('.',s)-1);
  IF trim(s)='' THEN s:='NEWDATA';
  s2:='        ';
  exN:=1;
  n:=1;
  WHILE (exN<Length(s)) ANd (exN<Length(s2)) DO
    BEGIN
      IF (s[exN] in AlfaChars) OR (s[exN] in NumChars) THEN
        BEGIN
          s2[n]:=s[exN];
          INC(n);
        END;
      INC(exN);
    END;
  s2:=trim(s2);
  IF trim(df^.FileLabel)<>'' THEN s2:=s2+'(LABEL="'+trim(df^.FileLabel)+'")';
  ExLin.Append('DATA '+s2+';');
  ExLin.append('  INFILE "'+DataOutFilename+'";');
  i:=0;
  FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[exN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
            BEGIN
              IF Felttype<>ftQuestion THEN
                BEGIN
                  IF (FeltType in [ftInteger,ftFloat,ftIDNUM]) THEN FSize:=FLength
                  ELSE IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                  IF (I Mod CardWidth)+FSize < CardWidth
                  THEN INC(I,FSize)
                  ELSE I := (I Div CARDWIDTH + 1) * CARDWIDTH + FSize;
                END;  //if not ftQuestion
             END;  //with
        END;  //if Checked
    END;  //for exN

  ExLin.Append('  INPUT');
  s:='    ';
  Column:=28;
  RecSize:=1;
  FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[exN] THEN
        BEGIN
          WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
            BEGIN
              IF Felttype<>ftQuestion THEN
                BEGIN
                  FSize:=FLength;
                  CASE Felttype OF
                    ftInteger,ftFloat,ftIDNUM: FSize:=FLength;
                  ELSE
                    IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                  END;  //case
                  IF (RecSize MOD CardWidth)+FSize>=CardWidth THEN
                    BEGIN
                      ExLin.Append(s);
                      Column:=17;
                      s:='  / ';
                      RecSize:=(RecSize DIV CardWidth+1)*CardWidth+1;
                    END;  //if
                  IF Column+38>CardWidth THEN
                    BEGIN
                      ExLin.Append(s);
                      s:='    ';
                      Column:=16;
                    END;
                  IF NOT (FeltType in [ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday]) THEN  
                    BEGIN
                      IF (FeltType in [ftAlfa,ftUpperAlfa,ftBoolean,ftSoundex,ftCrypt])  
                      THEN s:=s+AnsiUpperCase(trim(FName))+' $ '+IntToStr(RecSize MOD CardWidth)
                      ELSE s:=s+AnsiUpperCase(trim(FName))+' '+IntToStr(RecSize MOD CardWidth);
                      Column := Column + Length(trim(FName)) + 1;
                      IF FSize > 1 THEN
                        BEGIN
                          IF FSize=80      //MIB221
                          THEN s:=s+'-'+IntToStr(FSize)
                          ELSE s:=s+'-'+IntToStr( (RecSize+FSize-1) MOD CardWidth);
                          INC(Column,4);
                        END;
                      INC(Column,2);
                    END
                  ELSE
                    BEGIN
                      s:=s+'@'+IntToStr(RecSize MOD CardWidth)+' '+AnsiUpperCase(trim(FName));
                      INC(Column,10);
                    END;
                  IF (FeltType=ftToday) OR (Felttype=ftDate) THEN
                    BEGIN
                      s:=s+' mmddyy10.';
                      HasDates:=True;
                    END
                  ELSE IF (Felttype=ftEuroDate) or (Felttype=ftEuroToday) THEN
                    BEGIN
                      s:=s+' ddmmyy10.';
                      HasDates:=True;
                    END
                  ELSE IF (Felttype=ftYMDDate) or (Felttype=ftYMDToday) THEN
                    BEGIN
                      s:=s+' yymmdd10.';
                      HasDates:=True;
                    END;
                  IF (Felttype=ftFloat) AND (FNumDecimals>0) THEN s:=s+' .'+IntToStr(FNumDecimals);
                  RecSize:=RecSize+FSize;
                  INC(Column);
                  s:=s+' ';
                END;  //if not ftQuestion
            END;  //with
        END;  //if Checked
    END; //for exN
  s[Length(s)]:=';';
  ExLin.Append(s);
  ExLin.Append('');

  {Write Data}
  AssignFile(DataOutFile,DataoutFilename);
  Rewrite(DataOutFile);
  UserAborts:=False;
  FilterOK:=True;
  HandleVarsDf:=df;
  UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
  IF UseIndex THEN
    BEGIN
      ApplyIndex(df);
      InitSortIndex(df);
    END;

  TRY
    FOR exN:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,exN) THEN
          BEGIN
            ProgressForm.pBar.Position:=exN;
            ProgressForm.pLabel.Caption:=Format(Lang(22300),[exN]);   //' Exporting record no. %d'
            Application.ProcessMessages;
          END;
        //eReadOnlyNextRecord(df,ReadOnlyRecFile);
        IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,exN))
        ELSE eReadOnlyRecord(df,ReadOnlyRecFile,exN);

        IF UseFilter THEN
          BEGIN
            TRY
              E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
              IF Assigned(E) THEN
                BEGIN
                  IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                  ELSE
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      ExLin.Free;
                      CloseFile(DataOutFile);
                      tmpBool:=DeleteFile(DataOutFilename);
                      CloseFile(ReadOnlyRecFile);
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //if assigned(E)
            EXCEPT
              On Er:EExpression do
                BEGIN
                  ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                  DisposeDatafilePointer(df);
                  ExLin.Free;
                  CloseFile(DataOutFile);
                  tmpBool:=DeleteFile(DataOutFilename);
                  CloseFile(ReadOnlyRecFile);
                  UserAborts:=True;
                  Exit;
                END;
            END;  //try..except
          END;  //if UseFilter

        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
          BEGIN
            ExpRecLin:='';
            Column:=1;
            FOR exN2:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
              BEGIN
                IF ExportForm.FieldCheckList.Checked[exN2] THEN
                  BEGIN
                    WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN2])^ DO
                      IF Felttype<>ftQuestion THEN
                        BEGIN
                          FSize:=FLength;
                          Case FeltType of
                            ftInteger,ftIDNUM,ftFloat:
                              BEGIN
                                s:=trim(FFieldText);
                                IF Length(s)<FLength THEN s:=cFill(' ',FLength-Length(s))+s;
                              END;
                          ELSE
                            Begin
                              s:=FitLength(trim(FFieldText),FLength);
                              IF FLength>MaxAlfa THEN FSize:=MaxAlfa ELSE FSize:=FLength;
                            END;
                          END;  //case
                          IF Column+FSize>=CardWidth THEN
                            BEGIN
                              WriteLn(DataOutFile,ExpRecLin);
                              //ExLin.Append(ExpRecLin);
                              ExpRecLin:='';
                              Column:=1;
                            END;
                          IF FSize>0 THEN ExpRecLin:=ExpRecLin+s;
                          INC(Column,FSize);
                        END;  //if not ftQuestion
                  END;  //if write field
              END;  //for exN2
            WriteLn(DataOutFile,ExpRecLin);
            //ExLin.Append(ExpRecLin);
            ExpRecLin:='';
            INC(NumRecordsExported);
          END;  //if CurRecDeleted
        //IF (exN-1) MOD 10 = 0 THEN Application.ProcessMessages;
        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN
              BEGIN
                ExLin.Free;
                CloseFile(ReadOnlyRecFile);
                CloseFile(DataOutFile);
                tmpBool:=DeleteFile(DataOutFilename);
                Exit;
              END
            ELSE UserAborts:=False;
          END;
      END;  //for exN
    CloseFile(DataOutFile);

    {Write variable labels}
    s:='LABEL';
    FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
      BEGIN
        IF ExportForm.FieldCheckList.Checked[exN] THEN
          BEGIN
            WITH PeField(ExportForm.FieldCheckList.Items.Objects[exN])^ DO
              BEGIN
                IF (Felttype<>ftQuestion) AND (trim(FVariableLabel)<>'')
                AND (AnsiUpperCase(trim(FName))<>AnsiUpperCase(trim(FVariableLabel))) THEN
                  BEGIN
                    ExLin.Append(s);
                    s:='  '+trim(FName)+'="'+trim(FVariableLabel)+'"';
                  END;
               END;  //with
          END;  //if Checked
      END;  //for exN
    IF s<>'LABEL' THEN
      BEGIN
        ExLin.Append(s+';');
        ExLin.Append('');
      END;

    {Write formats}
    TRY
      IF (ValueLabelList.Count>0) OR (HasDates) THEN
        BEGIN
          {Assign value labels to variables}
          ExLin.Append('FORMAT');
          FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
            BEGIN
              IF ExportForm.FieldCheckList.Checked[exN] THEN
                BEGIN
                  WITH PeField(ExportForm.FieldCheckList.items.Objects[exN])^ DO
                    BEGIN
                      IF (FeltType in [ftInteger,ftFloat]) AND (trim(FValueLabel)<>'') THEN
                        BEGIN
                          ExLin.Append('  '+trim(FName)+' '+trim(FValueLabel)+'.');
                        END;  //if numeric and has FValueLabel
                      IF (FeltType in [ftDate,ftToday]) THEN ExLin.Append('  '+trim(FName)+' mmddyy10.');
                      IF (FeltType in [ftEuroDate,ftEuroToday]) THEN ExLin.Append('  '+trim(FName)+' ddmmyy10.');
                      IF (FeltType in [ftYMDDate,ftYMDToday]) THEN ExLin.Append('  '+trim(FName)+' yymmdd10.');
                    END;  //with
                END;  //if write field
            END;  //for
          ExLin[ExLin.Count-1]:=ExLin[ExLin.Count-1]+';';
        END;  //if ValueLabelList.Count>0


      ExLin.Append('');
      ExLin.Append('run;');

    FINALLY
      ValueLabelList.Free;
      FieldsInValueLabel.Free;
    END;

  EXCEPT
    ErrorMsg(Format(Lang(22304),[exN]));   //'Error occured during export of record #%d'
    ExLin.Free;
    CloseFile(ReadOnlyRecFile);
    CloseFile(DataOutFile);
    Exit;
  END;  //try..Except
  ExLin.SaveToFile(ExpFilename);
  ExLin.Free;
  CloseFile(ReadOnlyRecFile);
END;  //procedure ExportToSASFile





procedure ExportToEpiData(VAR df:PDatafileInfo; CONST ExpFilename:String);
VAR
  ChkLin:TStringList;
  InStr:String;
  exN, exN2:Integer;
  DeD:Boolean;
  ReadOnlyRecFile,Outfile:TextFile;
  FromRecNo,ToRecNo: Integer;
  UseFilter,FilterOK, UseIndex: Boolean;
  E:IValue;
  NewDf: PDatafileInfo;
  OldField,NewField: PeField;
BEGIN
  IF NOT GetDatafilePointer(NewDf) THEN
    BEGIN
      UserAborts:=True;
      Exit;
    END;
  Ded:=ExportForm.SkipDeletedCheck.Checked;
  WITH ExportForm DO
    BEGIN
      FromRecNo:=1;
      ToRecNo:=df^.NumRecords;
      IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
      THEN UseFilter:=True ELSE UseFilter:=False;
      IF SelRecordsCheck.Checked THEN
        BEGIN
          IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
            THEN FromRecNo:=StrToInt(FromRecEdit.Text)
            ELSE FromRecNo:=1;
          IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
            THEN ToRecNo:=StrToInt(ToRecEdit.Text)
            ELSE ToRecNo:=df^.NumRecords;
        END;
    END;  //with

  WITH ProgressForm.pBar DO BEGIN
    IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
    Position:=0;
  END;  //with

  NewDf^.RECFilename:=ExpFilename;
  NewDf^.FileLabel:=df^.Filelabel;
  NewDf^.EpiInfoFieldNaming:=df^.EpiInfoFieldNaming;

  {Transfer fields from df to NewDf}
  FOR exN:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
    BEGIN
      IF ExportForm.FieldCheckList.Checked[exN] THEN
        BEGIN
          OldField:=PeField(ExportForm.FieldCheckList.Items.Objects[exN]);
          IF OldField^.Felttype<>ftQuestion THEN
            BEGIN
              New(NewField);
              NewField^:=OldField^;
              NewField^.FOriginalQuest:=OldField^.FQuestion;
              ResetCheckProperties(NewField);
              //NewField^.FValueLabel:=OldField^.FValueLabel;
              //NewField^.FCommentLegalRec:=OldField^.FCommentLegalRec;
              CopyCheckProperties(OldField,NewField);
              ResetCheckProperties(OldField);
              NewDf^.FieldList.Add(NewField);
              OldField^.FieldN:=NewDf^.FieldList.Count-1;
            END;  //if not ftQuestion
        END;  //if Checked
    END;  //for exN

  NewDf^.NumFields:=NewDf^.FieldList.Count;
  IF NOT PeekCreateDatafile(NewDf) THEN
    BEGIN
      ErrorMsg(Format(Lang(22348),[NewDf^.RECFilename])+#13+    //22348=A file with the name %s cannot be created.
        Lang(22376));   //22376=Export terminates
      UserAborts:=True;
      DisposeDatafilePointer(NewDf);
      Exit;
    END;

  AssignFile(OutFile,NewDf^.RECFilename);
  Append(OutFile);

  {Write Data}
  UserAborts:=False;
  FilterOK:=True;
  HandleVarsDf:=df;
  UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked);
  IF UseIndex THEN
    BEGIN
      ApplyIndex(df);
      InitSortIndex(df);
    END;
  {Initialize inputfile}
  //CloseFile(df^.DatFile);
  df^.Datfile.Free;   //§§§
  df^.Datfile:=NIL;  //§§§
  AssignFile(ReadOnlyRecfile,df^.RECFilename);
  Reset(ReadOnlyRecfile);
  FOR exN:=0 TO df^.FieldList.Count DO
    ReadLn(ReadOnlyRecFile,InStr);
  {filepointer in ReadOnlyRecFile now points to first record}
   
  TRY
    FOR exN:=1 TO df^.NumRecords DO
      BEGIN
        IF ProgressStep(df^.NumRecords,exN) THEN
          BEGIN
            ProgressForm.pBar.Position:=exN;
            ProgressForm.pLabel.Caption:=Format(Lang(22300),[exN]);   //' Exporting record no. %d'
            Application.ProcessMessages;
          END;
        IF ((exN>=FromRecNo) AND (exN<=ToRecNo)) THEN
          BEGIN
            //eReadOnlyrecord(df,ReadOnlyRecFile,exN);
            IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,exN))
            ELSE eReadOnlyRecord(df,ReadOnlyRecFile,exN);

            IF UseFilter THEN
              BEGIN
                TRY
                  E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
                  IF Assigned(E) THEN
                    BEGIN
                      IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                      ELSE
                        BEGIN
                          ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                          UserAborts:=True;
                          Exit;
                        END;
                    END;  //if assigned(E)
                EXCEPT
                  On Er:EExpression do
                    BEGIN
                      ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                      UserAborts:=True;
                      Exit;
                    END;
                END;  //try..except
              END;  //if UseFilter

            IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
            AND (FilterOK) THEN
              BEGIN
                FOR exN2:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
                  BEGIN
                    IF ExportForm.FieldCheckList.Checked[exN2] THEN
                      BEGIN
                        OldField:=PeField(ExportForm.FieldCheckList.Items.Objects[exN2]);
                        IF Oldfield^.Felttype<>ftQuestion THEN
                          BEGIN
                            //NewField:=Getfield(OldField^.FName,NewDf);
                            PeField(NewDf^.FieldList.Items[OldField^.FieldN])^.FFieldText:=OldField^.FFieldtext;
                            //NewField^.FFieldText:=OldField^.FFieldText;
                          END;
                      END;  //if write field
                  END;  //for exN2
                NewDf^.CurRecDeleted:=df^.CurRecDeleted;  
                WriteNextRecord(NewDf,OutFile);
                INC(NumRecordsExported);
              END;  //if CurRecDeleted
          END;  //if recordnum within bounds

        IF UserAborts THEN
          BEGIN
            IF eDlg(Lang(22302),mtConfirmation,[mbYes,mbNo],0)=mrYes   //'Abort export?'
            THEN Exit ELSE UserAborts:=False;
          END;
      END;  //for exN

    NewDf^.ValueLabels.Free;
    NewDf^.ValueLabels:=df^.ValueLabels;
    NewDf^.BeforeFileCmds:=df^.BeforeFileCmds;
    NewDf^.AfterFileCmds:=df^.AfterFileCmds;
    NewDf^.BeforeRecordCmds:=df^.BeforeRecordCmds;
    NewDf^.AfterRecordCmds:=df^.AfterRecordCmds;
    Newdf^.RecodeCmds:=df^.RecodeCmds;
    NewDf^.AssertList:=df^.AssertList;
    NewDf^.GlobalMissingValues[0]:=df^.globalMissingValues[0];
    NewDf^.GlobalMissingValues[1]:=df^.globalMissingValues[1];
    NewDf^.GlobalMissingValues[2]:=df^.globalMissingValues[2];
    TRY
      ChkLin:=TStringList.Create;
      ChecksToStrings(NewDf,ChkLin);
      ChkLin.SaveToFile(ChangeFileExt(NewDf^.RECFilename,'.chk'));
    FINALLY
      ChkLin.Free;
      NewDf^.ValueLabels:=NIL;
      NewDf^.BeforeFileCmds:=NIL;
      NewDf^.AfterFileCmds:=NIL;
      NewDf^.BeforeRecordCmds:=NIL;
      NewDf^.AfterRecordCmds:=NIL;
      NewDf^.RecodeCmds:=NIL;
      NewDf^.AssertList:=NIL;
    END;

  FINALLY
    CloseFile(OutFile);
    CloseFile(ReadOnlyRecFile);
    AddToRecentFiles(NewDf^.RECFilename);
    DisposeDatafilePointer(NewDf);
  END;  //try..Except
END;  //procedure ExportToEpiData




procedure ExportDatafile;
VAR
  n:Integer;
  df:PDatafileInfo;
  tmpS:String;
  WindowList:Pointer;
  ok:Boolean;
  AField: PeField;
BEGIN
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(22102),[MaxNumberOfDatafiles]));  //'Only %d datafiles can be open at the same time.'
      Exit;
    END;
  NumFieldsExported:=0;
  NumRecordsExported:=0;

  MainForm.OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  MainForm.OpenDialog1.InitialDir:=GetRecentFileDir;
  MainForm.OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT MainForm.OpenDialog1.Execute THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=MainForm.OpenDialog1.Filename;
  AddToRecentFiles(df^.RECFilename);

  IF NOT PeekDatafile(df) THEN
    BEGIN
      ErrorMsg(Format(Lang(20108),[df^.RECFilename]));  //20108=Datafile %s could not be opened.
      DisposeDatafilePointer(df);
      Exit;
    END;

  ExportForm:=TExportForm.Create(Application);
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[n]);
      IF AField^.FeltType<>ftQuestion THEN
        BEGIN
          ExportForm.FieldCheckList.Items.AddObject(trim(AField^.FName),TObject(AField));
          ExportForm.FieldCheckList.Checked[ExportForm.FieldCheckList.Items.Count-1]:=True;
        END;
    END;

  CASE ExportType OF
    etTxt:   ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.txt');
    etDBase: ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.dbf');
    etXLS:   ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.xls');
    etStata: ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.dta');
    etRecToQes: ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.qes');
    etSPSS:  ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.sps');
    etSAS:   ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.sas');
    etEpiData: ExportForm.ExportFilenameEdit.Text:=ChangeFileExt(df^.RECFilename,'.new')+'.rec';
  END;  //Case

  //Disable options connected to ListData
  WITH ExportForm DO
    BEGIN
      MaxWidthLabel.Enabled:=False;
      WidthEdit.Enabled:=False;
      NumColsLabel.Enabled:=False;
      ColEdit.Enabled:=False;
      SpinButton1.Enabled:=False;
      WriteLabelsCheckBox.Enabled:=False;
      ListDataGroup.Enabled:=False;
      ListDataGroup.Visible:=False;
      CodebookGroup.Visible:=False;
      NumCharsLabel.Enabled:=False;
      ToRecEdit.Text:=IntToStr(df^.NumRecords);
      AllRecordsCheck.Checked:=True;
    END;

  CASE ExportType OF
    etDBase: BEGIN
               ExportForm.FieldSepCombo.Visible:=False;
               ExportForm.UseTextIdentifierCheck.Visible:=False;
               ExportForm.FieldSepText.Visible:=False;
               ExportForm.Caption:=Lang(22318);   //'Export datafile to dBase III file';
               ExportForm.StataGroup.Visible:=False;
               ExportForm.TextFileGroup.Visible:=False;
               ExportForm.OptionsSheet.TabVisible:=False;
             END;
    etXLS:   BEGIN
               ExportForm.FieldSepCombo.Visible:=False;
               ExportForm.UseTextIdentifierCheck.Visible:=False;
               ExportForm.FieldSepText.Visible:=False;
               ExportForm.Caption:=Lang(22320);   //'Export datafile to Excel file';
               ExportForm.StataGroup.Visible:=False;
               ExportForm.TextFileGroup.Visible:=False;
               ExportForm.OptionsSheet.TabVisible:=False;
             END;
    etStata: BEGIN
               ExportForm.FieldSepCombo.Visible:=False;
               ExportForm.UseTextIdentifierCheck.Visible:=False;
               ExportForm.FieldSepText.Visible:=False;
               ExportForm.Caption:=Lang(22322);   //'Export datafile to Stata file';
               ExportForm.TextFileGroup.Visible:=False;
               ExportForm.StataVerCombo.Visible:=True;
               CASE StataVersion OF
                 4: ExportForm.StataVerCombo.ItemIndex:=0;
                 6: ExportForm.StataVerCombo.ItemIndex:=1;
                 7: ExportForm.StataVerCombo.ItemIndex:=2;
                 8: ExportForm.StataVerCombo.ItemIndex:=3;
               ELSE
                 ExportForm.StataVerCombo.ItemIndex:=1;
               END;
               CASE StataLetterCase OF
                 fcUpper:      ExportForm.StataLetterCaseRadio.ItemIndex:=0;
                 fcLower:      ExportForm.StataLetterCaseRadio.ItemIndex:=1;
                 fcDontChange: ExportForm.StataLetterCaseRadio.ItemIndex:=2;
               ELSE
                 ExportForm.StataLetterCaseRadio.ItemIndex:=1;
               END;

               ExportForm.StataGroup.Left:=(ExportForm.PageControl1.ClientWidth DIV 2)-(ExportForm.StataGroup.Width DIV 2);
               ExportForm.StataGroup.Top:=24;
             END;

    etSPSS,etSAS:  ExportForm.OptionsSheet.TabVisible:=False;

    etEpiData: BEGIN
                 ExportForm.OptionsSheet.TabVisible:=False;
                 ExportForm.TextFileGroup.Visible:=False;
                 ExportForm.StataGroup.Visible:=False;
               END;

    etTxt:   BEGIN
               ExportForm.Caption:=Lang(22324);   //'Export datafile to text file';
               ExportForm.StataGroup.Visible:=False;
               ExportForm.TextFileGroup.Left:=(ExportForm.PageControl1.ClientWidth DIV 2)-(ExportForm.TextFileGroup.Width DIV 2);
             END;
    etRecToQes: BEGIN
                  ExportForm.FieldSepCombo.Visible:=False;
                  ExportForm.UseTextIdentifierCheck.Visible:=False;
                  ExportForm.FieldSepText.Visible:=False;
                  ExportForm.SkipDeletedCheck.Visible:=False;
                  ExportForm.Caption:=Lang(22326);   //'Create QES-file from datafile';
                END;
  END;   //Case

  IF ExportForm.ShowModal=mrCancel THEN
    BEGIN
      DisposeDatafilePointer(df);
      ExportForm.Free;
      Exit;
    END;
  TRY
    AddToRecentFiles(df^.RECFilename);
    NoUpDateCurRecEdit:=True;
    df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
    df^.HasCheckFile:=FileExists(df^.CHKFilename);
    ok:=True;

    IF (df^.HasCheckFile) AND (ok) THEN
      BEGIN
        IF NOT PeekApplyCheckFile(df,tmpS) THEN
          BEGIN
            CheckErrorForm:=TCheckErrorForm.Create(MainForm);
            CheckErrorForm.CheckBox1.Checked:=ShowCheckFileCheckMark;
            IF CheckErrorForm.ShowModal=mrYes THEN
              BEGIN
                LockWindowUpdate(MainForm.handle);
                WITH TEdForm.Create(MainForm) DO
                  BEGIN
                    Caption:=format(Lang(20502),[df^.CHKFilename]); //'Errors found in checkfile %s'
                    Ed.Lines.Text:=tmpS;
                    Ed.SelStart:=0;
                  END;  //with
                IF CheckErrorForm.CheckBox1.Checked THEN
                  BEGIN
                    WITH TEdForm.Create(MainForm) DO Open(df^.CHKFilename);
                    MainForm.TileMode:=tbVertical;
                    MainForm.Tile;
                  END;
                LockWindowUpdate(0);
              END;
            ShowCheckFileCheckMark:=CheckErrorForm.CheckBox1.Checked;
            CheckErrorForm.Free;
            ok:=False;
          END;
      END;
    IF ok THEN
      BEGIN  //datafile was opened
        IF df^.NumRecords>0 THEN
          BEGIN
            TRY
              ProgressForm:=TProgressForm.Create(MainForm);
              ProgressForm.Caption:=Lang(22328);  //'Exporting';
              ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
              ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
              WindowList:=DisableTaskWindows(ProgressForm.Handle);
              ProgressForm.Show;
              NumRecordsExported:=0;
              CASE ExportType OF
                etTxt:   ExportToTextFile(df,ExportForm.ExportFilenameEdit.Text);
                etDBase: ExportToDBaseFile(df,ExportForm.ExportFilenameEdit.Text);
                etXLS:   ExportToExcelFile(df,ExportForm.ExportFilenameEdit.Text);
                etStata: ExportToStataFile(df,ExportForm.ExportFilenameEdit.Text);
                etSPSS:  ExportToSPSSFile(df,ExportForm.ExportFilenameEdit.Text);
                etSAS:   ExportToSASFile(df,ExportForm.ExportFilenameEdit.Text);
                etEpiData: ExportToEpiData(df,ExportForm.ExportFilenameEdit.Text);
              END;  //Case
              EnableTaskWindows(WindowList);
              ProgressForm.Free;
              IF NOT UserAborts THEN
                BEGIN
                  IF NumRecordsExported<>df^.NumRecords
                  THEN eDlg(Format(Lang(22330),  //Datafile %s has been exported to %s.~~%d records were exported~%d records were skipped
                    [df^.RECFilename,ExportForm.ExportFilenameEdit.Text,
                    NumRecordsExported,df^.NumRecords-NumRecordsExported]),
                    mtInformation,[mbOK],0)
                  ELSE eDlg(Format(Lang(22332),   //'Datafile %s has been exported to %s.~~%d records were exported'
                    [df^.RECFilename,ExportForm.ExportFilenameEdit.Text,
                    NumRecordsExported]),
                    mtInformation,[mbOK],0)
                END;  //if Not UserAborts
            EXCEPT
              EnableTaskWindows(WindowList);
              ProgressForm.Free;
            END;  //try..except
          END  //if NumRecords>0
        ELSE
          BEGIN
            ErrorMsg(Format(Lang(22334),[df^.RecFilename]));    //'The datafile %s contains no records.'
          END;
      END;  //datafile was opened
  FINALLY
    MainForm.StatPanel2.Caption:='';
    DisposeDatafilePointer(df);
    ExportForm.Free;
  END;   //try..finally
  NoUpDateCurRecEdit:=False;
  UserAborts:=False;
END;   //procedure ExportDatafile



procedure TExportForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
VAR
  Mess,s,ExpExtension: String;
  AllUnChecked:Boolean;
  tmpWidth,tmpCol,n: Integer;
  QQ: Textfile;
begin
  CASE ExportType OF
    etTxt:      ExpExtension:='.TXT';
    etDBase:    ExpExtension:='.DBF';
    etXLS:      ExpExtension:='.XLS';
    etStata:    ExpExtension:='.DTA';
    etRecToQes: ExpExtension:='.QES';
    etSPSS:     ExpExtension:='.SPS';
    etSAS:      ExpExtension:='.SAS';
    etEpiData:  ExpExtension:='.REC';
  END;   //case
  CanClose:=True;
  IF ModalResult=mrOK THEN
    BEGIN

      s:=AnsiUpperCase(filterEdit.Text);
      IF (pos('AND',s)>0) OR (pos('OR',s)>0) THEN
        BEGIN
          IF (pos('(',s)=0) OR (pos(')',s)=0) THEN
            BEGIN
              ErrorMsg(Lang(22384));   //22384=Please use brackets in filters containing AND or OR~E.g. (field1=2) AND (field44=2)
              FilterEdit.SetFocus;
              CanClose:=False;
            END;
        END;

      AllUnChecked:=True;
      FOR n:=0 TO FieldCheckList.Items.Count-1 DO
        IF FieldCheckList.Checked[n]=True THEN AllUnChecked:=False;
      IF AllUnChecked THEN
        BEGIN
          CanClose:=False;
          ErrorMsg(Lang(22604));   //'No fields are selected for list of data.~Please select at least one field.'
          Exit;
        END;

      IF ExportType=etListData THEN
        BEGIN
          IF WidthEdit.Text='' THEN tmpWidth:=0 ELSE tmpWidth:=StrToInt(WidthEdit.Text);
          IF ColEdit.Text='' THEN tmpCol:=1 ELSE tmpCol:=StrToInt(ColEdit.Text);
          IF tmpCol=0 THEN tmpCol:=1;
          n:=((tmpWidth-(4*(tmpCol-1))) DIV tmpCol)-10;
          IF (CanClose) AND (n<2) THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Lang(22606));   //'Width of data columns are to small.~Please change dimensions of list.'
            END
          ELSE IF CanClose THEN
            BEGIN
              WidthEdit.Text:=IntToStr(tmpWidth);
              ColEdit.Text:=IntToStr(tmpCol);
            END;
        END
      ELSE IF ExportType=etCodebook THEN CanClose:=True
      ELSE
        BEGIN   //if ExportType<>etListData
          IF (ExportFilenameEdit.Text='') AND (CanClose) THEN
            BEGIN
              IF ExportType=etRecToQes
              THEN Mess:=Lang(22338)   //'Please enter a name for the QES-file'
              ELSE Mess:=Lang(22340);   //'Please enter a name for the exportfile.';
              eDlg(Mess,MtError,[mbOK],0);
              CanClose:=False;
            END;
          IF ExtractFileExt(ExportFilenameEdit.Text)=''
          THEN ExportFilenameEdit.Text:=ExportFilenameEdit.text+ExpExtension;
          IF (AnsiUpperCase(ExtractFileExt(ExportFilenameEdit.Text))<>ExpExtension)
          AND (CanClose) THEN
            BEGIN
              eDlg(Format(Lang(22344),[ExpExtension]),   //'Exportfile must have the extension %s'
              MtError,[mbOK],0);
              CanClose:=False;
            END;
          IF (FileExists(ExportFileNameEdit.Text)) AND (CanClose) THEN
            BEGIN
              IF eDlg(Format(Lang(22346),[ExportFileNameEdit.Text]),  //'Exportfile %s allready exists.~~Overwrite existing file?'
                 MtWarning,[mbYes,mbNo],0)=mrNo
                 THEN CanClose:=False
              ELSE  DeleteFile(ExportFilenameEdit.Text);
            END;  //if Exportfile allready exists
          IF CanClose THEN
            BEGIN
              {$I-}
              AssignFile(DataFile,ExportFilenameEdit.Text);
              Rewrite(DataFile);
              IF IOResult<>0 THEN  //Exportfile cannot be created
                BEGIN
                  eDlg(Format(Lang(22348),[ExportFileNameEdit.Text])+#13#13   //'A file with the name %s cannot be created.'
                    +Lang(20206),MtError,[mbOK],0);   //Please check if the filename is legal or if the disk is writeprotected or full.
                  CanClose:=False;
                END
              ELSE CloseFile(Datafile);
              {$I+}
            END;  //if canClose
        END;  //if not etListData
    END;   //If modalresult=mrOK
end;   //function ExportForm.FormCloseQuery


procedure TExportForm.SearchExpFileBtnClick(Sender: TObject);
VAR
  ExpExtension: String;
begin
  CASE ExportType OF
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
    etSPSS:  BEGIN
               OpenDialog1.Filter:=Lang(2122)+'|*.sps|'+Lang(2112)+'|*.*';   //'SPSS file  (*.sps)'
               OpenDialog1.DefaultExt:='sps';
               ExpExtension:='.SPS';
             END;
    etSAS:   BEGIN
               OpenDialog1.Filter:=Lang(2124)+'|*.sas|'+Lang(2112)+'|*.*';   //'SAS file  (*.sas)'
               OpenDialog1.DefaultExt:='sas';
               ExpExtension:='.SAS';
             END;
    etRecToQes: BEGIN
                  OpenDialog1.Filter:=Lang(2102)+'|*.qes|'+Lang(2112)+'|*.*';  //'EpiData Questionnaire  (*.qes)|*.qes|All files  (*.*)|*.*';
                  OpenDialog1.DefaultExt:='qes';
                  ExpExtension:='.QES';
                END;
  END;   //Case
  OpenDialog1.FilterIndex:=1;    //set filter to exportfiletype-extension
  OpenDialog1.Options:=OpenDialog1.Options-[ofFileMustExist];
  IF AnsiUpperCase(ExtractFileExt(ExportFilenameEdit.Text))=ExpExtension THEN
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(ExportFilenameEdit.Text);
      OpenDialog1.FileName:=ExtractFileName(ExportFilenameEdit.Text);
    END
  ELSE OpenDialog1.Filename:='';
  IF OpenDialog1.Execute THEN
    ExportFilenameEdit.Text:=OpenDialog1.Filename;
end;


procedure MakeQesFromRec;
VAR
  df:PDatafileInfo;
  Rec2qesFilename,QESFilename,RECFilename:TFilename;
  QESLines:TStrings;
  tmpS:String;
BEGIN
  TRY
    SelectFilesform:=TSelectFilesForm.Create(MainForm);
    WITH SelectFilesForm DO
      BEGIN
        Caption:=Lang(22326);   //'Create qes-file from datafile'
        File1Label.Caption:=Lang(22378);  //'Create from datafile:'
        File2Label.Caption:=Lang(22380);  //'Name of new QES-file:'
        Ext1:='.rec';
        Ext2:='.qes';
        File2MustExist:=False;
        WarnOverWrite2:=True;
        UpdateFile2Text:=True;
        IF LastSelectFilestype=sfRec2Qes THEN
          BEGIN
            File1Edit.Text:=LastSelectFile1;
            File2Edit.Text:=LastSelectFile2;
          END
        ELSE File1Edit.Text:=GetRecentFilename('.rec');
        IF ShowModal<>mrOK THEN Exit;
        RECfilename:=File1Edit.Text;
        QESFilename:=File2Edit.Text;
        LastSelectFilestype:=sfRec2Qes;
        LastSelectFile1:=File1Edit.Text;
        LastSelectFile2:=File2Edit.Text;
      END;  //with
  FINALLY
    SelectFilesForm.Free;
  END;  //try..finally

  TRY
    IF NOT GetDatafilePointer(df) THEN Exit;
    df^.RECFilename:=RECFilename;
    Screen.Cursor:=crHourGlass;
    df^.DontGetPassword:=True;
    IF NOT PeekDatafile(df) THEN Exit
    ELSE
      BEGIN
        {Datafile's fields are now read into df^.FieldList
        Now translate FieldList to qes-lines}
        IF NOT FieldListToQes(df,tmpS,True) THEN
          BEGIN
            Screen.Cursor:=crDefault;
            ErrorMsg(Format(Lang(20112),[df^.RECFilename]));   //Incorrect format of datafile %s.
          END
        ELSE
          BEGIN
            {tmpS now contains the qes-lines}
            QESLines:=TStringList.Create;
            QESLines.Text:=tmpS;
            TRY
              Screen.Cursor:=crDefault;
              QESLines.SaveToFile(QESFilename);
              eDlg(Format(Lang(22350),[Rec2QesFilename]),  //'QES-file %s created'
              mtInformation,[mbOK],0);
              AddToRecentFiles(RECFilename);
              AddToRecentFiles(QESFilename);
            EXCEPT
              Screen.Cursor:=crDefault;
              ErrorMsg(Format(Lang(22352),[QESFilename])+    //'The QES-file %s could not be saved.'
                #13#13+Lang(20206));   //Please check if the filename is legal or if the disk is writeprotected or full.
            END;
            QESLines.Free;
          END;
      END;
  FINALLY
    Screen.Cursor:=crDefault;
    DisposeDatafilePointer(df);
  END;  //try..finally
END;   //procedure MakeQesFromRec


procedure TExportForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  FieldSepCombo.ItemIndex:=0;
  VarLabel.Caption:='';
end;

procedure TExportForm.FieldSepComboChange(Sender: TObject);
begin
  IF FieldSepCombo.Items[FieldSepCombo.ItemIndex]='Other' THEN   //***
    BEGIN
      WITH CreateMessageDialog(Lang(22382),mtCustom, []) do  //'Press a key to enter the field separator character'
        TRY
          onKeyPress:=FieldSepKeyPress;
          IF ShowModal=mrOK THEN
            BEGIN
              FieldSepCombo.Items.Add(' '+CHR(Tag)+' ');
              FieldSepCombo.ItemIndex:=FieldSepCombo.Items.Count-1;
            END
          ELSE FieldSepCombo.ItemIndex:=0;
        FINALLY
          Free;
        END;
    END;
END;

procedure TExportForm.FieldSepKeyPress(Sender: TObject; var Key: Char);
BEGIN
  IF Key=#27 THEN TForm(Sender).ModalResult:=mrCancel
  ELSE
    BEGIN
      TForm(Sender).Tag:=ORD(Key);
      TForm(Sender).ModalResult:=mrOK;
    END;
END;


procedure TExportForm.AllBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  FOR n:=0 TO FieldCheckList.Items.Count-1 DO
    FieldCheckList.Checked[n]:=True;
end;

procedure TExportForm.NoneBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  FOR n:=0 TO FieldCheckList.Items.Count-1 DO
    FieldCheckList.Checked[n]:=False;
end;

procedure TExportForm.WidthEditChange(Sender: TObject);
VAR
  n,tmpCol,tmpWidth:Integer;
begin
  IF WidthEdit.Text='' THEN tmpWidth:=0 ELSE tmpWidth:=StrToInt(WidthEdit.Text);
  IF ColEdit.Text='' THEN tmpCol:=1 ELSE tmpCol:=StrToInt(ColEdit.Text);
  IF tmpCol=0 THEN tmpCol:=1;
  n:=((tmpWidth-(4*(tmpCol-1))) DIV tmpCol)-10;
  IF n>=2 THEN
    BEGIN
      NumCharsLabel.Caption:=Format(Lang(22600),[n]);  //'Width of data colums: %d'
      NumCharsLabel.Font.Color:=clWindowText;
    END
  ELSE
    BEGIN
      NumCharsLabel.Caption:=Format(Lang(22602),[n]);  //'Warning: Width of data colums is too small (%d)'
      NumCharsLabel.Font.Color:=clRed;
    END;
end;

procedure TExportForm.WidthEditKeyPress(Sender: TObject; var Key: Char);
begin
  IF NOT(Key in NumChars) AND (Key<>#8) THEN
    BEGIN
      Beep;
      Key:=#0;
    END;
end;

procedure TExportForm.SpinButton1DownClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF ColEdit.Text='' THEN ColEdit.Text:='1';
  n:=StrToInt(ColEdit.Text);
  IF n>1 THEN DEC(n);
  ColEdit.Text:=IntToStr(n);
end;

procedure TExportForm.SpinButton1UpClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF ColEdit.Text='' THEN ColEdit.Text:='1';
  n:=StrToInt(ColEdit.Text);
  INC(n);
  ColEdit.Text:=IntToStr(n);
end;


Procedure ListData;
VAR
  n,CurRec,CurObs,CurField,CurCol,FromRecNo,ToRecNo:Integer;
  Cols,FieldWidth,MaxWidth: Integer;
  AField: PeField;
  df:PDatafileInfo;
  Lin:TStrings;
  ReadOnlyRecFile,OutFile:TextFile;
  InStr: String[MaxRecLineLength];
  tmpS,tmpS2: String;
  AEdForm: TEdForm;
  ErrorInCheckFile,Found, UseIndex, tmpBool: Boolean;
  ALabelRec: PLabelRec;
  WindowList:Pointer;
  UseFilter,FilterOK: Boolean;
  E: IValue;
begin
  MainForm.DocumentBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),[MaxNumberOfDatafiles]));   //'Only %d datafiles can be open at the same time.'
      MainForm.MakeDatafileBtn.Down:=False;
      Exit;
    END;
  MainForm.OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  MainForm.OpenDialog1.InitialDir:=GetRecentFileDir;
  MainForm.OpenDialog1.Filename:=GetRecentFilename('.rec');
  IF NOT MainForm.OpenDialog1.Execute THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=MainForm.OpenDialog1.Filename;
  AddToRecentFiles(df^.RECFilename);
  ExportType:=etListData;
  IF PeekDatafile(df) THEN
    BEGIN
      ExportForm:=TExportForm.Create(MainForm);
      ExportForm.Caption:=Format(Lang(22622),[ExtractFilename(df^.RECFilename)]);  //'List data of %s'
      WITH ExportForm DO
        BEGIN
          ToRecEdit.Text:=IntToStr(df^.NumRecords);
          AllRecordsCheck.Checked:=True;
          WidthEdit.Text:=IntToStr(ListDataWidth);
          ColEdit.Text:=IntToStr(ListDataCols);
          WriteLabelsCheckBox.Checked:=ListDataLabels;
          SkipDeletedCheck.Checked:=ListDataSkipDel;
          ExportToLabel.Visible:=False;
          ExportFilenameEdit.Visible:=False;
          SearchExpFileBtn.Visible:=False;
          UseTextIdentifierCheck.Enabled:=False;
          FieldSepText.Enabled:=False;
          FieldSepCombo.Enabled:=False;
          StataVerCombo.Enabled:=False;
          TextFileGroup.Enabled:=False;
          StataGroup.Enabled:=False;
          TextFileGroup.Visible:=False;
          CodebookGroup.Visible:=False;
          StataGroup.Visible:=False;
          ListDataGroup.Left:=(PageControl1.ClientWidth DIV 2) - (ListDataGroup.Width DIV 2);
        END;  //with
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.Items[n]);
          IF AField^.FeltType<>ftQuestion THEN
            BEGIN
              ExportForm.FieldCheckList.Items.AddObject(trim(AField^.FName),TObject(AField));
              ExportForm.FieldCheckList.Checked[ExportForm.FieldCheckList.Items.Count-1]:=True;
            END;
        END;
      IF ExportForm.ShowModal=mrOK THEN
        BEGIN
          WITH ExportForm DO
            BEGIN
              TRY
                ListDataWidth:=StrToInt(WidthEdit.Text);
                ListDataCols:=StrToInt(ColEdit.Text);
                ListDataLabels:=WriteLabelsCheckBox.Checked;
                ListDataSkipDel:=SkipDeletedCheck.Checked;
                FromRecNo:=1;
                ToRecNo:=df^.NumRecords;
                IF (UseFilterCheck.Checked) AND (trim(FilterEdit.Text)<>'')
                THEN UseFilter:=True ELSE UseFilter:=False;
                IF SelRecordsCheck.Checked THEN
                  BEGIN
                    IF (trim(FromRecEdit.Text)<>'') AND (IsInteger(FromRecEdit.Text))
                      THEN FromRecNo:=StrToInt(FromRecEdit.Text)
                      ELSE FromRecNo:=1;
                    IF (trim(ToRecEdit.Text)<>'') AND (IsInteger(ToRecEdit.Text))
                      THEN ToRecNo:=StrToInt(ToRecEdit.Text)
                      ELSe ToRecNo:=df^.NumRecords;
                  END;
              EXCEPT
                ListDataWidth:=80;
                ListDataCols:=3;
              END;
            END;  //WITH
          IF (ListDataLabels) OR (ExportForm.chkExpSortIndex.Checked) THEN
            BEGIN
              {User wants to write value labels instead of values}
              ErrorInCheckFile:=False;
              df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
              df^.HasCheckFile:=FileExists(df^.CHKFilename);
              IF df^.HasCheckFile THEN ErrorInCheckFile:=NOT PeekApplyCheckFile(df,tmpS);
              IF ErrorInCheckFile THEN
                BEGIN
                  IF eDlg(format(Lang(20800),[df^.CHKFilename])+   //'The checkfile %s contains errors and cannot be applied.'
                    #13#13+Lang(22608)+#13#13+Lang(22610),mtWarning,[mbYes,mbNo],0)=mrNo THEN
                    {22608='If you continue to list data then the values of the fields will be shown and not the value labels.'
                     22610='Do you want to continue to list data?'}
                  BEGIN
                    ExportForm.Free;
                    DisposeDatafilePointer(df);
                    Exit;
                  END;  //if users aborts
                END  //if errorInCheckFile
              ELSE ApplyIndex(df);
            END;  //if WriteLabelsCheckBox

          {Initialize progressform}
          TRY
            UserAborts:=False;
            ProgressForm:=TProgressForm.Create(MainForm);
            ProgressForm.Caption:=Lang(22612);   //'Creating list of data';
            ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
            ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
            WITH ProgressForm.pBar DO BEGIN
              IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
              Position:=0;
            END;  //with
            WindowList:=DisableTaskWindows(ProgressForm.Handle);
            ProgressForm.Show;

            {Initialize outputfile}
            AssignFile(OutFile,ChangeFileExt(df^.RECFilename,'.lo$'));
            Rewrite(OutFile);

            {Initialize inputfile}
            //CloseFile(df^.DatFile);
            df^.Datfile.Free;   //§§§
            df^.Datfile:=NIL;  //§§§
            AssignFile(ReadOnlyRecfile,df^.RECFilename);
            Reset(ReadOnlyRecfile);
            FOR n:=0 TO df^.FieldList.Count DO
              ReadLn(ReadOnlyRecFile,InStr);
            {filepointer in ReadOnlyRecFile now points to first record}

            Lin:=TStringList.Create;
            Cols:=ListDataCols;
            MaxWidth:=ListDataWidth;
            FieldWidth:=((MaxWidth-(4*(Cols-1))) DIV Cols)-10;
            CurObs:=0;
            WriteLn(OutFile);
            WriteLn(OutFile,Format(Lang(22614),[df^.RECFilename]));  //'List of observations in %s'
            WriteLn(OutFile,Format(Lang(22616),[FormatDateTime('d. mmm. yyyy t',Now)]));  //'List created %s'
            WriteLn(OutFile);
            WriteLn(OutFile,Format(Lang(22624),[df^.NumRecords]));  //'Records in file: %d'
            IF ExportForm.AllRecordsCheck.Checked THEN tmpS:=Lang(22626)  //'Records in list: All'
            ELSE tmpS:=Format(Lang(22628),[FromRecNo,ToRecNo]);   //'Records in list: %d-%d'
            WriteLn(OutFile,tmpS);
            IF UseFilter THEN WriteLn(OutFile,Lang(22630)+' '+   //'Records in list limited by filter:'
            ExportForm.FilterEdit.Text);
            IF ListDataSkipDel THEN WriteLn(OutFile,Lang(22632));   //'Deleted records are skipped.'
            WriteLn(OutFile);
            WriteLn(OutFile);
            UserAborts:=False;
            FilterOK:=True;
            UseIndex:=(df^.IndexCount>0) AND (ExportForm.chkExpSortIndex.Checked) AND (NOT ErrorInCheckFile);
            IF UseIndex THEN InitSortIndex(df);
            HandleVarsDf:=df;
            FOR CurRec:=1 TO df^.NumRecords DO
              BEGIN
                IF ProgressStep(df^.NumRecords,CurRec) THEN
                  BEGIN
                    ProgressForm.pBar.Position:=CurRec;
                    ProgressForm.pLabel.Caption:=Format(Lang(20942),[CurRec,df^.NumRecords]);  //20942=Writing record no. %d of %d
                    Application.ProcessMessages;
                  END;
                IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,CurRec))
                ELSE eReadOnlyRecord(df,ReadOnlyRecFile,CurRec);

                IF UseFilter THEN
                  BEGIN
                    TRY
                      E:= CreateExpression(ExportForm.FilterEdit.Text,MainForm.HandleVars);
                      IF Assigned(E) THEN
                        BEGIN
                          IF E.CanReadAs(ttBoolean) THEN FilterOK:=E.AsBoolean
                          ELSE
                            BEGIN
                              ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                              CloseFile(Outfile);
                              tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.lo$'));
                              Lin.Free;
                              ExportForm.Free;
                              DisposeDatafilepointer(df);
                              Exit;
                            END;
                        END;  //if assigned(E)
                    EXCEPT
                      On Er:EExpression do
                        BEGIN
                          ErrorMsg(ExportForm.FilterEdit.Text+#13+Lang(23318));  //'is not a valid boolean expression'
                          CloseFile(Outfile);
                          tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.lo$'));
                          Lin.Free;
                          ExportForm.Free;
                          DisposeDatafilePointer(df);
                          Exit;
                        END;
                    END;  //try..except
                  END;  //if UseFilter


                IF ( NOT ((ListDataSkipDel) AND (df^.CurRecDeleted)) )
                AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
                AND (FilterOK) THEN
                  BEGIN
                    INC(CurObs);
                    IF UseIndex
                    THEN WriteLn(OutFile,Format(Lang(22618),[CurObs,ReadIndexNoFromSortIndex(df,CurRec)]))
                    ELSE WriteLn(OutFile,Format(Lang(22618),[CurObs,CurRec]));
                    WriteLn(OutFile);
//                    THEN Lin.Append(Format(Lang(22618),[CurObs,ReadIndexNoFromSortIndex(df,CurRec)]))  //'Observation %d  (record #%d)'
  //                  ELSE Lin.Append(Format(Lang(22618),[CurObs,CurRec]));  //'Observation %d  (record #%d)'
    //                Lin.Append('');
                    CurCol:=1;
                    tmpS:='';
                    FOR CurField:=0 TO ExportForm.FieldCheckList.Items.Count-1 DO
                      BEGIN
                        IF ExportForm.FieldCheckList.Checked[CurField] THEN
                          BEGIN
                            AField:=PeField(ExportForm.FieldCheckList.Items.Objects[CurField]);
                            {Write name of field}
                            IF CurCol>1 THEN tmpS:=tmpS+'    ';
                            tmpS:=tmpS+Format('%10s',[trim(AField^.FName)])+'  ';

                            {Write value of field}
                            IF (ListDataLabels) AND (NOT ErrorInCheckFile) THEN
                              BEGIN
                                {User wants value labels, if present}
                                IF trim(AField^.FFieldText)='' THEN tmpS2:='.'
                                ELSE
                                  BEGIN
                                    //Field is not missing - find a value label or a missing value
                                    IF AField^.FCommentLegalRec<>NIL THEN
                                      BEGIN
                                        tmpS2:=GetCommentLegalText(trim(AField^.FFieldText),AField^.FCommentLegalRec);
                                        IF tmpS2='' THEN tmpS2:='.';
                                      END
                                    ELSE
                                      BEGIN
                                        //No value label was found, now check for Missing values
                                        {If MissingValues defined and user wants to see labels}
                                        IF AField^.FMissingValues[0]<>'' THEN
                                          BEGIN
                                            IF (AField^.FFieldText=AField^.FMissingValues[0])
                                            OR (AField^.FFieldText=AField^.FMissingValues[1])
                                            OR (AField^.FFieldText=AField^.FMissingValues[2])
                                            THEN tmpS2:='.' ELSE tmpS2:=trim(AField^.FFieldText);
                                            IF tmpS2='' THEN tmpS2:='.';
                                          END
                                        ELSE IF (df^.GlobalMissingValues[0]<>'') AND ( (AField^.Felttype=ftInteger) OR ((AField^.Felttype=ftFloat) AND (AField^.FNumDecimals=0)) ) THEN
                                          BEGIN
                                            IF (AField^.FFieldText=df^.GlobalMissingValues[0])
                                            OR (AField^.FFieldText=df^.GlobalMissingValues[1])
                                            OR (AField^.FFieldText=df^.GlobalMissingValues[2])
                                            THEN tmpS2:='.' ELSE tmpS2:=trim(AField^.FFieldText);
                                            IF tmpS2='' THEN tmpS2:='.';
                                          END
                                        ELSE tmpS2:=trim(AField^.FFieldText);
                                      END;
                                  END;  //if fiels is not missing
                              END
                            ELSE
                              BEGIN
                                IF trim(AField^.FFieldText)='' THEN tmpS2:='.'
                                ELSE tmpS2:=trim(AField^.FFieldText);
                              END;

                            WHILE Length(tmpS2)<FieldWidth DO tmpS2:=' '+tmpS2;
                            IF Length(tmpS2)>FieldWidth
                              THEN tmpS2:=Copy(tmpS2,1,FieldWidth-2)+'--';
                            tmpS:=tmpS+tmpS2;
                            INC(CurCol);
                            IF CurCol>Cols THEN
                              BEGIN
                                WriteLn(OutFile,tmpS);
                                //Lin.Append(tmpS);
                                tmpS:='';
                                CurCol:=1;
                              END;
                          END;  //if field should be written
                      END;  //for CurField
                    WriteLn(OutFile,tmpS);
                    WriteLn(OutFile);
                    WRiteLn(OutFile);
//                    Lin.Append(tmpS);
  //                  Lin.Append('');
    //                Lin.Append('');
                  END;  //if not skip record

                IF UserAborts THEN
                  BEGIN
                    IF eDlg(Lang(22620),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort List Data?'
                    THEN
                      BEGIN
                        CloseFile(Outfile);
                        tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.lo$'));
                        Lin.Free;
                        ExportForm.Free;
                        DisposeDatafilePointer(df);
                        Exit;
                      END
                    ELSE UserAborts:=False;
                  END;  //if UserAborts
              END;  //for CurRecord
          FINALLY
            CloseFile(ReadOnlyRecFile);
            EnableTaskWindows(WindowList);
            ProgressForm.Free;
          END;  //try..finally
          CloseFile(outFile);
          AEdForm:=TEdForm.Create(MainForm);
          WITH AEdForm DO
            BEGIN
              Open(ChangeFileExt(df^.RECFilename,'.lo$'));
              CloseFile(BlockFile);
              PathName:=DefaultFilename+IntToStr(WindowNum);
              Caption:=Format(Lang(22614),[df^.RECFilename]);
              MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                IndexOfObject(TObject(AEdForm))]:=DefaultFilename+IntToStr(WindowNum);
              FormType:=ftDocumentation;
              Ed.Font.Assign(epiDocuFont);
              Ed.SelStart:=0;
              Ed.Modified:=True;
            END;  //with
          tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.lo$'));
{          IF Length(Lin.Text)>65500 THEN
            BEGIN
              tmpS:=ExtractFileDir(ParamStr(0))+'\~EpdLog';
              n:=1;
              WHILE FileExists(tmpS+IntToStr(n)+'.tmp') DO INC(n);
              tmpS:=tmpS+IntToStr(n)+'.tmp';
              Lin.SaveToFile(tmpS);
              AEdForm:=TEdForm.Create(MainForm);
              WITH AEdForm DO
                BEGIN
                  Open(tmpS);
                  CloseFile(BlockFile);
                  PathName:=DefaultFilename;
                  Caption:=Format(Lang(22614),[df^.RECFilename]);  //'List of observations in %s'
                  MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                    IndexOfObject(TObject(AEdForm))]:=DefaultFilename;
                  FormType:=ftDocumentation;
                  Ed.Font:=epiDocuFont;
                  Ed.SelStart:=0;
                  Ed.Modified:=True;
                END;  //with
              tmpBool:=DeleteFile(tmpS);
            END
          ELSE
            BEGIN
              {Lin.Text < 65500 chars}
{              Screen.Cursor:=crHourGlass;
              LockWindowUpdate(MainForm.Handle);
              AEdForm:=TEdForm.Create(MainForm);
              WITH AEdForm DO
                BEGIN
                  Ed.Visible:=False;
                  FormType:=ftDocumentation;
                  Caption:=Format(Lang(22614),[df^.RECFilename]);  //'List of observations in %s'
                  Ed.Font:=epiDocuFont;
                  Ed.Color:=DocuColor;
                  Ed.ScrollBars:=ssBoth;
                  Ed.Lines.Capacity:=Lin.Count;
                  Ed.Lines.Text:=Lin.Text;
                  Ed.ScrollBars:=ssBoth;
                  Ed.Visible:=True;
                  Ed.SelStart:=0;
                END;
//              MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
//              IndexOfObject(TObject(AEdForm))]:=ExtractFilename(AEdForm.PathName);
//              AddToRecentFiles(AEdForm.PathName);
              LockWindowUpDate(0);
              Screen.Cursor:=crDefault;
            END;  //Lin.Text < 65500 chars}
          Lin.Free;
        END;   //Run List Data (ModalResult=mrOK)
      ExportForm.Free;
      DisposeDatafilePointer(df);
    END;  //Datafile opened with succes
end;   //procedure Listdata




procedure TExportForm.FromRecEditChange(Sender: TObject);
begin
  SelRecordsCheck.Checked:=True;
end;

procedure TExportForm.FilterEditChange(Sender: TObject);
begin
  UseFilterCheck.Checked:=True;
end;

procedure TExportForm.FieldCheckListMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
VAR
  pos: TPoint;
  n: Integer;
  tmpS:String;
  AField: PeField;
begin
  pos.x:=X;
  pos.y:=Y;
  n:=FieldCheckList.ItemAtPos(Pos,True);
  IF n<>-1 THEN
    BEGIN
      IF (FieldCheckList.Items.Objects[n]<>NIL) THEN
        BEGIN
          AField:=PeField(FieldCheckList.Items.Objects[n]);
          IF trim(AField^.FVariableLabel)<>''
          THEN tmpS:=trim(AField^.FName)+': '+trim(AField^.FVariableLabel)
          ELSE tmpS:='';
          VarLabel.Caption:=tmpS;
          IF Canvas.TextWidth(tmpS)>VarLabel.Width THEN DotsLabel.Visible:=True
          ELSE DotsLabel.Visible:=False;
        END
      ELSE
        BEGIN
          VarLabel.Caption:='';
          DotsLabel.Visible:=False;
        END;
    END
  ELSE
    BEGIN
      VarLabel.Caption:='';
      DotsLabel.Visible:=False;
    END;
end;

procedure TExportForm.FilterEditExit(Sender: TObject);
VAR
  s: String;
begin
  s:=AnsiUpperCase(filterEdit.Text);
  IF (pos('AND',s)>0) OR (pos('OR',s)>0) THEN
    BEGIN
      IF (pos('(',s)=0) OR (pos(')',s)=0) THEN
        BEGIN
          ErrorMsg(Lang(22384));  //22384=Please use brackets in filters containing AND or OR~E.g. (field1=2) AND (field44=2)
          FilterEdit.SetFocus;
        END;
    END;
end;

end.
