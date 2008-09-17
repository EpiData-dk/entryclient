unit ValDupUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, checklst;

type
  TValDupForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    FilenameLabel1: TLabel;
    DatafileLabel1: TLabel;
    RecordsLabel1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SelectKeyGroup: TGroupBox;
    FieldSelectList1: TCheckListBox;
    GroupBox4: TGroupBox;
    IgnoreDeleted: TCheckBox;
    IgnoreTextFields: TCheckBox;
    IgnoreLetterCase: TCheckBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    FilenameLabel2: TLabel;
    DatafileLabel2: TLabel;
    RecordsLabel2: TLabel;
    HelpBtn: TBitBtn;
    VarLabel: TLabel;
    DotsLabel: TLabel;
    ReportDifFieldType: TCheckBox;
    IgnoreMissingRec2: TCheckBox;
    procedure AllBtn1Click(Sender: TObject);
    procedure NoneBtn1Click(Sender: TObject);
    procedure FieldSelectList1MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure FieldSelectList1DrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FieldSelectList1ClickCheck(Sender: TObject);
    procedure IgnoreTextFieldsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SelectKeyGroupMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Procedure DoValidate;


var
  ValDupForm: TValDupForm;

implementation

{$R *.DFM}


USES
  EpiTypes, SelectFilesUnit, MainUnit, FileUnit, PeekCheckUnit,
  ProgressUnit, EdUnit;

VAR
  KeyBitMap: TBitMap;

procedure TValDupForm.AllBtn1Click(Sender: TObject);
VAR
  n:Integer;
begin
  FOR n:=0 TO (Sender AS TCheckListBox).Items.Count-1 DO
    (Sender As TCheckListBox).Checked[n]:=True;
end;

procedure TValDupForm.NoneBtn1Click(Sender: TObject);
VAR
  n:Integer;
begin
  FOR n:=0 TO (Sender AS TCheckListBox).Items.Count-1 DO
    (Sender As TCheckListBox).Checked[n]:=False;
end;


procedure TValDupForm.FieldSelectList1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
VAR
  pos: TPoint;
  n: Integer;
  tmpS:String;
  AField: PeField;
begin
  pos.x:=X;
  pos.y:=Y;
  n:=FieldSelectList1.ItemAtPos(Pos,True);
  IF n<>-1 THEN
    BEGIN
      IF (FieldSelectList1.Items.Objects[n]<>NIL) THEN
        BEGIN
          AField:=PeField(FieldSelectList1.Items.Objects[n]);
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

procedure TValDupForm.FieldSelectList1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
VAR
  bmCenterOffset:Integer;
  txtCenterOffset:Integer;
  tmpS:String;
begin
  WITH (Control AS TCheckListBox).Canvas DO
    BEGIN
      FillRect(Rect);
      bmCenterOffset:=((Rect.Bottom-Rect.Top) DIV 2)-(KeyBitMap.Height DIV 2);
      txtCenterOffset:=((Rect.Bottom-Rect.Top) DIV 2)-(TextHeight(FieldSelectList1.Items[Index]) DIV 2);
      tmpS:=FieldSelectList1.Items[Index];
      IF tmpS[1]='$' THEN
        BEGIN
          TextOut(Rect.Left,Rect.Top+txtCenterOffset,Copy(tmpS,2,Length(tmpS)));
          BrushCopy(Bounds(Rect.Left+TextWidth(Copy(tmpS,2,Length(tmpS)))+5,
            Rect.Top+bmCenterOffset,KeyBitMap.Width,KeyBitMap.Height),KeyBitMap,
            Bounds(0,0,KeyBitMap.Width,KeyBitMap.Height),clWhite);
        END
      ELSE
        BEGIN
          TextOut(Rect.Left,Rect.Top+txtCenterOffset,tmpS);
        END;
    END;
end;

procedure TValDupForm.FieldSelectList1ClickCheck(Sender: TObject);
VAR
  n:Integer;
  CheckCount: Integer;
begin
  CheckCount:=0;
  FOR n:=0 TO FieldSelectList1.Items.Count-1 DO
    IF FieldSelectList1.Checked[n] THEN INC(CheckCount);
  IF CheckCount>3 THEN
    BEGIN
      FieldSelectList1.Checked[FieldSelectList1.ItemIndex]:=False;
      eDlg(Format(Lang(23100),[3]),mtWarning,[mbOK],0);  //'A maximum of %d can be selected.'
    END;
end;

procedure TValDupForm.IgnoreTextFieldsClick(Sender: TObject);
begin
  IgnoreLetterCase.Enabled:=NOT IgnoreTextFields.Checked;
end;

procedure TValDupForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  KeyBitMap:=TBitMap.Create;
  KeyBitMap.LoadFromResourceName(hInstance,'KEYBITMAP');
  VarLabel.Caption:='';
  DotsLabel.Visible:=False;
end;

procedure TValDupForm.FormDestroy(Sender: TObject);
begin
  KeyBitMap.Free;
end;

procedure TValDupForm.SelectKeyGroupMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  VarLabel.Caption:='';
  DotsLabel.Visible:=FAlse;
end;

Procedure DoValidate;
VAR
  Rec1Name,Rec2Name: TFilename;
  Rec1,Rec2: PDatafileInfo;
  TxtFile1,TxtFile2: TextFile;
  n,n2,n3: Integer;
  CurRec, CurRec1, CurRec2, LastRec1, FirstRec1: LongInt;
  AField1,AField2: PeField;
  UsesIndex: Boolean;
  tmpBool: Boolean;
  tmpS,tmpS2,FormStr,s1,s2, BlankStr: String;
  Found,ok, IgnoreDel, FirstErrorInRecord, ErrorsFound, DifFound: Boolean;
  Fields1,Fields2,CommonFields,ValReport: TStringList;
  Excluded1,Excluded2, YesStr,NoStr: String;
  NumIndexFields,CurField: Integer;
  IndexFieldNames: ARRAY[0..MaxIndices] OF ShortString;
  OnlyIndexedFieldsSelected: Boolean;
  Index1,Index2:TMemoryStream;
  Buff: Array[0..91] OF Char;
  AEdForm: TEdForm;
  RecsMissing1,RecsMissing2,RecsWithError,FieldsWithError,RecsTested,FieldsTested: Integer;
  ResultsStartLine: Integer;
  //Language-strings:
  Lang23136: String;   //Lang(23136)='Record key fields: (Rec.#%d)'
  Lang23138: String;   //Lang(23138)='Record #%d'
  Lang23140: String;   //Lang(23140)='Record not found in datafile 2'
  Lang23142: String;   //Lang(23142)='Record not found'
  Lang23144: String;   //Lang(23144)='Record not found in datafile 1'
  MainStartTid,MainSlutTid,StartTid,SlutTid: TDateTime;
  Hour,Min,Sec,MSec:Word;
  TimeReport: STring;
  OldDecimalSep: Char;
  WindowList:Pointer;


  Procedure MakeReportFieldHeader;
  VAR
    mrN,mrN2: Integer;
    tmpField: PeField;
  BEGIN
    With ValReport DO
      BEGIN
        FOR mrN:=1 TO NumIndexFields DO
          BEGIN
            mrN2:=Fields1.IndexOf(IndexFieldNames[mrN]);
            tmpField:=PeField(Fields1.Objects[mrN2]);
            s1:=Format('%-10s = %-s',[trim(tmpField^.FName),trim(tmpField^.FFieldText)]);
            IF Length(s1)>37 THEN s1:=Copy(s1,1,34)+'...';
            Append(Format(FormStr,[s1,'']));
          END;  //for mrN
        Append(BlankStr);
      END;  //with ValReport
    FirstErrorInRecord:=False;
  END;  //procedure MakeReportFieldHeader

begin

  TimeReport:='';
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles-2 THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),[MaxNumberOfDatafiles]));  //'Only %d datafiles can be open at the same time.'
      Exit;
    END;
  SelectFilesForm:=TSelectFilesForm.Create(MainForm);
  WITH SelectFilesForm DO
    BEGIN
      Ext1:='.rec';
      Ext2:='.rec';
      Caption:=Lang(4800);  //'Validate duplicate datafiles';
      File1Label.Caption:=Lang(23102);   //'Name of first datafile'
      File2Label.Caption:=Lang(23104);   //'Name of second datafile'
      IF LastSelectFilestype=sfValDup THEN
        BEGIN
          File1Edit.Text:=LastSelectFile1;
          File2Edit.Text:=LastSelectFile2;
        END;
    END;
  IF SelectFilesForm.ShowModal<>mrOK THEN
    BEGIN
      SelectFilesForm.Free;
      Exit;
    END;
  LastSelectFilestype:=sfValDup;
  LastSelectFile1:=SelectFilesForm.File1Edit.Text;
  LastSelectFile2:=SelectFilesForm.File2Edit.Text;
  IF NOT GetDatafilePointer(Rec1) THEN
    BEGIN
      SelectFilesForm.Free;
      Exit;
    END;
  IF NOT GetDatafilePointer(Rec2) THEN
    BEGIN
      DisposeDatafilePointer(Rec1);
      SelectFilesForm.Free;
      Exit;
    END;
  Rec1^.RECFileName:=SelectFilesForm.File1Edit.Text;
  Rec2^.RECFilename:=SelectFilesForm.File2Edit.Text;
  SelectFilesForm.Free;
  IF ExtractFileDir(Rec1^.RECFilename)='' THEN Rec1^.RECFilename:=ExpandFilename(Rec1^.RECFilename);
  IF ExtractFileDir(Rec2^.RECFilename)='' THEN Rec2^.RECFilename:=ExpandFilename(Rec2^.RECFilename);
  AddToRecentFiles(Rec2^.RECFilename);
  AddToRecentFiles(Rec1^.RECFilename);
  IF NOT PeekDatafile(Rec1) THEN
    BEGIN
      DisposeDatafilePointer(Rec1);
      DisposeDatafilePointer(Rec2);
      Exit;
    END;
  IF NOT PeekDatafile(Rec2) THEN
    BEGIN
      DisposeDatafilePointer(Rec1);
      DisposeDatafilePointer(Rec2);
      Exit;
    END;
  IF Rec1^.NumRecords=0 THEN
    BEGIN
      ErrorMsg(Format(Lang(22334),[Rec1^.RECFilename])+#13#13+   //'The datafile %s contains no records.'
      Lang(23106));    //'Validate Duplicate Datafiles terminates.'
      DisposeDatafilePointer(Rec1);
      DisposeDatafilePointer(Rec2);
      Exit;
    END;
  IF Rec2^.NumRecords=0 THEN
    BEGIN
      ErrorMsg(Format(Lang(22334),[Rec2^.RECFilename])+#13#13+   //'The datafile %s contains no records.'
      Lang(23106));   //'Validate Duplicate Datafiles terminates.'
      DisposeDatafilePointer(Rec1);
      DisposeDatafilePointer(Rec2);
      Exit;
    END;

  Rec1.CHKFilename:=ChangeFileExt(Rec1.RECFilename,'.chk');
  Rec2.CHKFilename:=ChangeFileExt(Rec2.RECFilename,'.chk');
  Rec1.HasCheckFile:=FileExists(Rec1.CHKFilename);
  Rec2.HasCheckFile:=FileExists(Rec2.CHKFilename);
  IF Rec1.HasCheckFile THEN
    IF NOT PeekApplyCheckFile(Rec1,tmpS) THEN
      BEGIN
        ErrorMsg(Format(Lang(20800),[Rec1.RECFilename]));   //'The checkfile %s contains errors and cannot be applied.'
        DisposeDatafilePointer(Rec1);
        DisposeDatafilePointer(Rec2);
        Exit;
      END;
  IF Rec2.HasCheckFile THEN
    IF NOT PeekApplyCheckFile(Rec2,tmpS) THEN
      BEGIN
        ErrorMsg(Format(Lang(20800),[Rec2.RECFilename]));   //'The checkfile %s contains errors and cannot be applied.'
        DisposeDatafilePointer(Rec1);
        DisposeDatafilePointer(Rec2);
        Exit;
      END;
  TRY
    ValDupForm:=TValDupForm.Create(MainForm);
    Fields1:=TStringList.Create;
    Fields2:=TStringList.Create;
    CommonFields:=TStringList.Create;
    ValReport:=TStringList.Create;
  EXCEPT
    ValDupForm.Free;
    Fields1.Free;
    Fields2.Free;
    CommonFields.Free;
    ValReport.Free;
    ErrorMsg(Format(Lang(20204),[766]));  //'Out of memory (ref.code 766)'
    DisposeDatafilePointer(Rec1);
    DisposeDatafilePointer(Rec2);
    Exit;
  END;
  TRY
  Screen.Cursor:=crHourGlass;
  {Make list of fields}
  FOR n:=0 TO Rec1^.FieldList.Count-1 DO
    BEGIN
      AField1:=PeField(Rec1^.FieldList.Items[n]);
      IF AField1^.FeltType<>ftQuestion
      THEN Fields1.AddObject(AnsiUpperCase(trim(AField1^.FName)),TObject(AField1));
    END;

  FOR n:=0 TO Rec2^.FieldList.Count-1 DO
    BEGIN
      AField2:=PeField(Rec2^.FieldList.Items[n]);
      IF AField2^.FeltType<>ftQuestion
      THEN Fields2.AddObject(ANSIUpperCase(trim(AField2^.FName)),TObject(AField2));
    END;

  {Add fields that occur in both datafiles to FieldSelectList}
  {Mark fields that are indexed in both datafiles with $-character}
  FOR n:=0 TO Fields1.Count-1 DO
    BEGIN
      n2:=Fields2.IndexOf(Fields1[n]);
      IF n2>-1 THEN
        BEGIN
          ValDupForm.FieldSelectList1.Items.AddObject(Fields1[n],Fields1.Objects[n]);
          IF (PeField(Fields1.Objects[n])^.FIndex>0) AND
            (PeField(Fields2.Objects[n2])^.FIndex>0)
            THEN ValDupForm.FieldSelectList1.Items[ValDupForm.FieldSelectList1.Items.Count-1]:=
            '$'+ValDupForm.FieldSelectList1.Items[ValDupForm.FieldSelectList1.Items.Count-1];
        END;  //if n2>-1
    END;  //for

  WITH ValDupForm DO
    BEGIN
      FilenameLabel1.Caption:=Rec1^.RECFilename;
      FilenameLabel2.Caption:=Rec2^.RECFilename;
      IF trim(Rec1^.FileLabel)<>'' THEN DatafileLabel1.Caption:=trim(Rec1^.FileLabel)
      ELSE DatafileLabel1.Caption:=Lang(20604);   //'[none]'
      IF trim(Rec2^.FileLabel)<>'' THEN DatafileLabel2.Caption:=trim(Rec2^.FileLabel)
      ELSE DatafileLabel2.Caption:=Lang(20604);   //'[none]'
      RecordsLabel1.Caption:=IntToStr(Rec1^.NumRecords);
      RecordsLabel2.Caption:=IntToStr(Rec2^.NumRecords);
    END;  //with ValDupForm
  IF ValDupForm.ShowModal=mrOK THEN
    BEGIN
      Screen.Cursor:=crHourGlass;
      OldDecimalSep:=DecimalSeparator;
      DecimalSeparator:='.';
      IgnoreDel:=ValDupForm.IgnoreDeleted.Checked;

      {Make a list of names of fields that user checked to use as index}
      NumIndexFields:=0;
      OnlyIndexedfieldsSelected:=True;
      FOR n:=0 TO ValDupForm.FieldSelectList1.Items.Count-1 DO
        BEGIN
          tmps:=ValDupForm.FieldSelectList1.Items[n];
          IF ValDupForm.FieldSelectList1.Checked[n] THEN
            BEGIN
              INC(NumIndexFields);
              IF tmpS[1]<>'$' THEN
                BEGIN
                  OnlyIndexedFieldsSelected:=False;
                  IndexFieldNames[NumIndexFields]:=tmpS;
                END
              ELSE IndexFieldNames[NumIndexfields]:=Copy(tmpS,2,Length(tmpS));
            END;  //if field checked
          IF tmpS[1]='$' THEN
            BEGIN
              Delete(tmpS,1,1);
              ValDupForm.FieldSelectList1.Items[n]:=tmpS;
            END;
        END;  //For n
      UsesIndex:=(NumIndexFields>0);

      {Make lists of common fields (maybe without textfields), of excluded fields 1 and excluded fields2}
      IF NOT ValDupForm.IgnoreTextFields.Checked THEN
        BEGIN
          CommonFields.Capacity:=ValDupForm.FieldSelectList1.Items.Count;
          CommonFields.AddStrings(ValDupForm.FieldSelectList1.Items);
          Excluded1:='';
          FOR n:=0 TO Fields1.Count-1 DO
            IF CommonFields.IndexOf(Fields1[n])=-1 THEN Excluded1:=Excluded1+','+Fields1[n];
          Excluded2:='';
          FOR n:=0 TO Fields2.Count-1 DO
            IF CommonFields.IndexOf(Fields2[n])=-1 THEN Excluded2:=Excluded2+','+Fields2[n];
        END
      ELSE
        BEGIN
          {Exclude fields that are text fields in both datafiles}
          Excluded1:='';
          Excluded2:='';
          FOR n:=0 TO Fields1.Count-1 DO
            BEGIN
              n2:=Fields2.IndexOf(Fields1[n]);
              IF n2<>-1 THEN
                BEGIN
                  IF (ValDupForm.IgnoreTextFields.Checked)
                  AND ( (PeField(Fields1.Objects[n])^.Felttype=ftAlfa) OR (PeField(Fields1.Objects[n])^.Felttype=ftUpperAlfa) )
                  AND ( (PeField(Fields2.Objects[n2])^.Felttype=ftAlfa) OR (PeField(Fields2.Objects[n2])^.Felttype=ftUpperAlfa) )
                  THEN Excluded1:=Excluded1+','+Fields1[n]
                  ELSE CommonFields.Append(Fields1[n]);
                END  //if n2<>-1
              ELSE Excluded1:=Excluded1+','+Fields1[n];
            END;  //for n
          FOR n:=0 TO Fields2.Count-1 DO
            IF CommonFields.IndexOf(Fields2[n])=-1
            THEN Excluded2:=Excluded2+','+Fields2[n];
        END;  //if text fields should be excluded
      IF Excluded1='' THEN Excluded1:=Lang(2065);   //'None'
      IF Excluded1[1]=',' THEN Delete(Excluded1,1,1);
      IF Excluded2='' THEN Excluded2:=Lang(2065);   //'None';
      IF Excluded2[1]=',' THEN Delete(Excluded2,1,1);

      WITH ValReport DO
        BEGIN
          s1:=Lang(23108);   //'VALIDATE DUPLICATE DATAFILES REPORT'
          Append(s1);
          Append(cFill('=',Length(s1)));
          Append('');
          Append(Lang(20810)+' '+FormatDateTime('d. mmm yyyy t',Now));  //'Report generated
          Append('');

          Append(cFill('-',78));
          Append(Lang(4810)+':');  //'DATAFILE 1'
          Append(cFill('-',78));
          Append(FitLength(Lang(4812),14)+Rec1^.RECFilename);   //'Filename:     '
          Append(FitLength(Lang(20812),14)+Rec1^.FileLabel);    //'File label:   '
          s1:=FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(Rec1^.RECFilename)));
          Append(FitLength(Lang(20814),14)+s1);   //'File date:    '
          Append(FitLength(Lang(20818),14)+IntToStr(Rec1^.NumRecords));   //Records total:
          Append('');

          Append(cFill('-',78));
          Append(Lang(4820));    //'DATAFILE 2:'
          Append(cFill('-',78));
          Append(FitLength(Lang(4812),14)+Rec2^.RECFilename);   //'Filename:     '+
          Append(FitLength(Lang(20812),14)+Rec2^.FileLabel);    //'File label:   '
          s1:=FormatDateTime('d. mmm yyyy t',FileDateToDateTime(FileAge(Rec2^.RECFilename)));
          Append(FitLength(Lang(20814),14)+s1);    //'File date:    '
          Append(FitLength(Lang(20818),14)+IntToStr(Rec2^.NumRecords));   //'ecords total:'
          Append(cFill('-',78));
          Append('');

          Append(Lang(23110));   //'Options for validation:'
          FormStr:='  %-40s  %-5s';
          YesStr:=Lang(20210);   //'Yes'
          NoStr:=Lang(20212);    //'No'
          s1:=Lang(23112);    //'Ignore deleted records:'
          IF IgnoreDel THEN s2:=YesStr ELSE s2:=NoStr;
          Append(Format(FormStr,[s1,s2]));
          s1:=Lang(23114);   //'Ignore text fields:
          IF ValDupForm.IgnoreTextFields.Checked THEN s2:=YesStr ELSE s2:=NoStr;
          Append(Format(FormStr,[s1,s2]));
          s1:=Lang(23116);   //'Ignore letter-case in text fields:'
          IF ValDupForm.IgnoreLetterCase.Checked THEN s2:=YesStr ELSE s2:=NoStr;
          Append(Format(FormStr,[s1,s2]));
          s1:=Lang(23118);   //'Report differences in field types:'
          IF ValDupForm.ReportDifFieldType.Checked THEN s2:=YesStr ELSE s2:=NoStr;
          Append(Format(FormStr,[s1,s2]));
          s1:=Lang(23119);   //'Ignore missing records in datafile 2'
          IF ValDupForm.IgnoreMissingRec2.Checked THEN s2:=YesStr ELSE s2:=NoStr;
          Append(Format(FormStr,[s1,s2]));
          Append('');

          Append(Lang(23120));   //'Fields in both datafiles that were used in the validation:'
          s1:=CommonFields.CommaText;
          WHILE Pos('"',s1)>0 DO System.Delete(s1,Pos('"',s1),1);
          WHILE Length(s1)>70 DO
            BEGIN
              n:=70;
              WHILE (s1[n]<>',') AND (n>10) DO DEC(n);
              Append('  '+Copy(s1,1,n));
              System.Delete(s1,1,n);
            END;
          Append('  '+s1);
          Append('');

          Append(Lang(23122));   //'Fields excluded from datafile 1:'
          s1:=Excluded1;
          WHILE Length(s1)>70 DO
            BEGIN
              n:=70;
              WHILE (s1[n]<>',') AND (n>10) DO DEC(n);
              Append('  '+Copy(s1,1,n));
              System.Delete(s1,1,n);
            END;
          Append('  '+s1);
          Append('');

          Append(Lang(23124));   //'Fields excluded from datafile 2:'
          s2:=Excluded2;
          WHILE Length(s1)>70 DO
            BEGIN
              n:=70;
              WHILE (s1[n]<>',') AND (n>10) DO DEC(n);
              Append('  '+Copy(s1,1,n));
              System.Delete(s1,1,n);
            END;
          Append('  '+s1);
          Append('');

          IF NOT UsesIndex THEN
            BEGIN
              Append(Lang(23126));   //'Fields used as index keys:'
              Append('  '+Lang(2065));   //'None'
            END
          ELSE
            BEGIN
              Append(Lang(23126));   //'Fields used as index keys:'
              FOR n:=1 TO NumIndexFields DO
                Append('  '+IndexFieldNames[n]);
            END;
          Append('');
          Append(cFill('-',78));

          ResultsStartLine:=ValReport.Count;
          Append(Lang(23128));   //'RESULTS OF VALIDATION:'
          Append(cFill('-',78));
          Append('');    //+2 - Records missing in datafile 1: xxxxxx
          Append('');    //+3 - Records missing in datafile 2: xxxxxx
          Append('');    //+4 - Empty
          Append('');    //+5 - Number of records found in both datafiles: xxxxxx
          Append('');    //+6 - Number of tested fields pr. record: xxxxxx
          Append('');    //+7 - Total number of tested fields: xxxxxx
          Append('');    //+8 - Empty
          Append('');    //+9 - xxxxxx out of xxxxx records had errors (x.x pct.)
          Append('');    //+10 - xxxxxx out of yyyyy fields had errors (y.y pct.)
          Append('');
          Append('');

          FormStr:=' %-37s | %-37s';
          BlankStr:=Format(FormStr,['','']);
          Append(cFill('-',78));
          Append(Format(FormStr,[AnsiUpperCase(Lang(4810)),AnsiUpperCase(Lang(4820))]));   //'DATAFILE 1','DATAFILE 2'
          Append(cFill('-',78));
        END;  //with ValReport

      ErrorsFound:=False;
      RecsMissing1:=0;
      RecsMissing2:=0;
      RecsTested:=0;
      FieldsTested:=0;
      RecsWithError:=0;
      FieldsWithError:=0;

      {Report differences in datatypes if user has selected this function}
      IF (ValDupForm.ReportDifFieldType.Checked) THEN
        BEGIN
          ValReport.Append(Format(FormStr,[Lang(23130),'']));   //'Differences in datatypes:'
          DifFound:=False;
          FOR CurField:=0 TO CommonFields.Count-1 DO
            BEGIN
              n2:=Fields1.IndexOf(CommonFields[CurField]);
              n3:=Fields2.IndexOf(CommonFields[CurField]);
              AField1:=PeField(Fields1.Objects[n2]);
              AField2:=PeField(Fields2.Objects[n3]);
              IF AField1^.Felttype<>Afield2^.Felttype THEN
                BEGIN
                  IF NOT ( ( ( (AField1^.Felttype=ftInteger) AND (AField2^.Felttype=ftFloat) )
                          OR ( (AField2^.Felttype=ftInteger) AND (AField1^.Felttype=ftFloat) ) )
                         AND ( (AField1^.FNumDecimals=0) AND (AField2^.FNumDecimals=0) )  ) THEN
                    BEGIN
                      DifFound:=True;
                      s1:='  '+Format(Lang(23132),[trim(AField1^.FName),FieldTypeNames[ORD(AField1^.Felttype)]]);  //'%s is %s field'
                      s1:='  '+Format(Lang(23132),[trim(AField2^.FName),FieldTypeNames[ORD(AField2^.Felttype)]]);  //'%s is %s field'
                      ValReport.Append(Format(FormStr,[s1,s2]));
                    END;  //if not ftFloat and ftInteger
                END;  //if fields types are different
            END;  //for n
          IF NOT DifFound THEN ValReport.Append(Format(FormStr,['  '+Lang(2065),'  '+Lang(2065)]))  //'None'
          ELSE ErrorsFound:=True;
          ValReport.Append(BlankStr);
          ValReport.Append(cFill('-',78));
        END;  //if differences in datatypes should be reported

      {Prepare datafile to be textfiles}
      //CloseFile(Rec1^.DatFile);
      Rec1^.Datfile.Free;   //§§§
      Rec1^.Datfile:=NIL;  //§§§
      Assign(TxtFile1,Rec1^.RECFilename);
      Reset(TxtFile1);
      FOR n:=0 TO Rec1^.FieldList.Count DO
        ReadLn(TxtFile1,tmpS);  //Makes the filepointer in TxtFile1 point to the first record

      //CloseFile(Rec2^.DatFile);
      Rec2^.Datfile.Free;   //§§§
      Rec2^.Datfile:=NIL;  //§§§
      Assign(TxtFile2,Rec2^.RECFilename);
      Reset(TxtFile2);
      FOR n:=0 TO Rec2^.FieldList.Count DO
        ReadLn(TxtFile2,tmpS);  //Makes the filepointer in TxtFile1 point to the first record

      ok:=True;
      IF UsesIndex THEN
        BEGIN
          {Make index for datafile 1}
          Index1:=TMemoryStream.Create;
          Index1.SetSize(Rec1^.NumRecords*30*NumIndexFields);
          FillChar(buff,SizeOf(buff),0);

          CurRec:=0;
          ok:=True;
          WHILE (CurRec<Rec1^.NumRecords) AND (ok) DO
            BEGIN
              INC(CurRec);
              eReadOnlyNextRecord(Rec1,TxtFile1);
              IF (NOT Rec1^.CurRecDeleted) OR (NOT IgnoreDel) THEN
                BEGIN
                  tmpS:='';
                  FOR n:=1 TO NumIndexFields DO
                    BEGIN
                      n2:=Fields1.IndexOf(IndexFieldNames[n]);
                      AField1:=PeField(Fields1.Objects[n2]);
                      IF (AField1^.Felttype in [ftInteger,ftFloat,ftIDNUM])
                      THEN tmpS:=tmpS+Format('%30s', [trim(AField1^.FFieldText)])
                      ELSE tmpS:=tmpS+Format('%-30s',[trim(AField1^.FFieldText)]);
                    END;
                  n:=1;
                  StrPCopy(Buff,tmpS);
                  WHILE (n<CurRec) AND (ok) DO
                    BEGIN
                      //Check for duplicates
                      ok:=NOT CompareMem(Pointer(LongInt(Index1.Memory)+( 30*(n-1)*NumIndexFields )),@buff,30*NumIndexFields);
                      INC(n);
                    END;  //While n<CurRec and OK
                  IF NOT ok THEN
                    BEGIN
                      DEC(n);
                      ErrorMsg(Format(Lang(23134),[Rec1^.RECFilename,CurRec,n])+    //'Dublicate keys found in %s~Keys in record %d are the same as record %d'
                      #13#13+Lang(23106));   //Validate Duplicate Datafiles terminates.
                    END  //if not ok
                  ELSE
                    BEGIN
                      Index1.Position:=30*(CurRec-1)*NumIndexfields;
                      StrPCopy(Buff,tmpS);
                      Index1.Write(buff,30*NumIndexFields);
                    END;
                END  //if OK to add to index
              ELSE
                BEGIN
                  //Add blank index entry
                  FillChar(buff,SizeOf(buff),0);
                  Index1.Position:=30*(CurRec-1)*NumIndexFields;
                  Index1.Write(buff,30*NumIndexFields);
                END;
            END;  //While CurRec<NumRecords
          //Index1.SavetoFile(ExtractFileDir(Rec1^.RECFilename)+'\Index1.txt');

          {Make index for datafile 2}
          IF ok THEN
            BEGIN
              Index2:=TMemoryStream.Create;
              Index2.SetSize(Rec2^.NumRecords*30*NumIndexfields);
              FillChar(buff,SizeOf(buff),0);
              CurRec:=0;
              ok:=True;
              WHILE (CurRec<Rec2^.NumRecords) AND (ok) DO
                BEGIN
                  INC(CurRec);
                  eReadOnlyNextRecord(Rec2,TxtFile2);
                  IF (NOT Rec2^.CurRecDeleted) OR (NOT IgnoreDel) THEN
                    BEGIN
                      tmpS:='';
                      FOR n:=1 TO NumIndexFields DO
                        BEGIN
                          n2:=Fields2.IndexOf(IndexFieldNames[n]);
                          AField2:=PeField(Fields2.Objects[n2]);
                          IF (AField2^.Felttype=ftInteger) OR (AField2^.Felttype=ftFloat)
                          OR (AField2^.Felttype=ftIDNUM)
                          THEN tmpS:=tmpS+Format('%30s', [trim(AField2^.FFieldText)])
                          ELSE tmpS:=tmpS+Format('%-30s',[trim(AField2^.FFieldText)]);
                        END;

                      n:=1;
                      StrPCopy(Buff,tmpS);
                      WHILE (n<CurRec) AND (ok) DO
                        BEGIN
                          //Check for duplicates
                          ok:=NOT CompareMem(Pointer(LongInt(Index2.Memory)+( 30*(n-1)*NumIndexFields )),@buff,30*NumIndexFields);
                          INC(n);
                        END;  //While n<CurRec and OK
                      IF NOT ok THEN
                        BEGIN
                          DEC(n);
                          ErrorMsg(Format(Lang(23134),[Rec2^.RECFilename,CurRec,n])+    //'Dublicate keys found in %s~Keys in record %d are the same as record %d'
                          #13#13+Lang(23106));   //Validate Duplicate Datafiles terminates.
                        END  //if not ok
                      ELSE
                        BEGIN
                          Index2.Position:=30*(CurRec-1)*NumIndexFields;
                          StrPCopy(Buff,tmpS);
                          Index2.Write(buff,30*NumIndexFields);
                        END;
                    END  //if OK to add to index
                  ELSE
                    BEGIN
                      //Add blank index entry
                      FillChar(buff,SizeOf(Buff),0);
                      Index2.Position:=30*(CurRec-1)*NumIndexFields;
                      Index2.Write(buff,30*NumIndexFields);
                    END;
                END;  //While ok
              //Index2.SavetoFile(ExtractFileDir(Rec1^.RECFilename)+'\Index1.txt');
            END;  //if ok
        END;  //if UsesIndex, i.e. make indices

      {Set language strings}
      Lang23136:=Lang(23136);   //'Record key fields: (Rec.#%d)'
      Lang23138:=Lang(23138);   //'Record #%d'
      Lang23140:=Lang(23140);   //'Record not found in datafile 2'
      Lang23142:=Lang(23142);   //'Record not found'
      Lang23144:=Lang(23144);   //'Record not found in datafile 1'

      {Iterate from Index1 - Set a marker in index1 and index2 when record is validated}
      {when done - check if index2 has non-validated records}
      IF ok THEN
        BEGIN
          {Validation can begin}
          TRY
            UserAborts:=False;
            ProgressForm:=TProgressForm.Create(MainForm);
            ProgressForm.Caption:=Lang(23164);   //'Validating duplicate datafiles'
            ProgressForm.pLabel.Caption:=Lang(23164);  //'Validating duplicate datafiles'
            ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
            ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
            WITH ProgressForm.pBar DO BEGIN
              Max:=Rec1^.NumRecords+Rec2^.NumRecords;
              Step:=Max DIV 20;
              IF Step=0 THEN Step:=1;
              IF Step>5000 THEN Step:=5000;
              Position:=0;
            END;  //with
            WindowList:=DisableTaskWindows(ProgressForm.Handle);
            ProgressForm.Show;

            {Init recordcounters to load}
            IF UsesIndex THEN
              BEGIN
                FirstRec1:=1;   //Points to first entry in Index1
                LastRec1:=Rec1^.NumRecords;  //Points to last entry in Index1
              END
            ELSE
              BEGIN
                FirstRec1:=1;  //Points to first record no.
                LastRec1:=Rec1^.NumRecords;  //Points to last record no.
                CurRec2:=0;
              END;

            {Iterate records in Rec1}
            CurRec1:=FirstRec1-1;
            WHILE (CurRec1<LastRec1) AND (ok) DO
              BEGIN
                IF (CurRec1 MOD ProgressForm.pBar.Step)=0 THEN
                  BEGIN
                    ProgressForm.pBar.StepIt;
                    Application.ProcessMessages;
                    IF UserAborts THEN
                      BEGIN
                        IF eDlg(Lang(23166),mtConfirmation,[mbYes,mbNo],0)=mrYes  //Abort validation of duplicate datafiles?'
                        THEN Exit ELSE UserAborts:=False;
                      END;  //if UserAborts
                  END;
                FirstErrorInRecord:=True;
                IF UsesIndex THEN
                  BEGIN
                    REPEAT
                      INC(CurRec1);
                      //eReadOnlyRecord(Rec1,TxtFile1,Integer(Index1.Objects[CurRec1]));
                      eReadOnlyRecord(Rec1,TxtFile1,CurRec1);
                    UNTIL (CurRec1>LastRec1) OR (NOT Rec1^.CurRecDeleted) OR (NOT IgnoreDel);
                    IF CurRec1<=LastRec1 THEN
                      BEGIN
                        FillChar(buff,SizeOf(buff),0);
                        Index1.Position:=30*(CurRec1-1)*NumIndexFields;
                        Index1.Read(Buff,30*NumIndexFields);
                        tmpS:=String(Buff);
                        CurRec2:=0;
                        tmpBool:=False;
                        StrPCopy(Buff,tmpS);
                        WHILE (CurRec2<=Rec2^.NumRecords) AND (NOT tmpBool) DO
                          BEGIN
                            INC(CurRec2);
                            tmpBool:=CompareMem(Pointer(LongInt(Index2.Memory)+( 30*(CurRec2-1)*NumIndexFields )),@buff,30*NumIndexfields);
                          END;
                        IF tmpBool
                        THEN eReadOnlyRecord(rec2,TxtFile2,CurRec2)
                        ELSE CurRec2:=-1;
                        IF (IgnoreDel) AND (Rec2^.CurRecDeleted) THEN CurRec2:=-1;
  {                      CurRec2:=Index2.IndexOf(Index1[CurRec1]);
                        IF CurRec2<>-1 THEN eReadOnlyRecord(Rec2,TxtFile2,Integer(Index2.Objects[CurRec2]));
                        IF (IgnoreDel) AND (Rec2^.CurRecDeleted) THEN CurRec2:=-1;}
                      END
                    ELSE CurRec2:=-2;
                    IF CurRec2>=1 THEN
                      BEGIN
                        Index2.Position:=30*(CurRec2-1)*NumIndexFields;
                        Buff[0]:=#255;
                        Index2.Write(buff,1);
                      END;
                    //IF CurRec2>=0 THEN Index2.Objects[CurRec2]:=TObject(Integer(Index2.Objects[CurRec2])*-1);
                  END
                ELSE
                  BEGIN  //Read records sequentially
                    REPEAT
                      INC(CurRec1);
                      eReadOnlyNextRecord(Rec1,TxtFile1);
                    UNTIL (CurRec1>LastRec1) OR (NOT Rec1^.CurRecDeleted) OR (NOT IgnoreDel);
                    REPEAT
                      INC(CurRec2);
                      eReadOnlyNextRecord(Rec2,TxtFile2);
                    UNTIL (CurRec2>Rec2^.NumRecords) OR (NOT Rec2^.CurRecDeleted) OR (NOT IgnoreDel);
                    IF CurRec2>Rec2^.NumRecords THEN CurRec2:=-1;
                  END;  //if not UsesIndex

                IF (CurRec1<=LastRec1) THEN  //was a record found in Rec1?
                  BEGIN
                    IF CurRec2<>-1 THEN  //was a match found in Rec2?
                      BEGIN
                        INC(RecsTested);
                        {Iterate over common fields}
                        FOR CurField:=0 TO CommonFields.Count-1 DO
                          BEGIN
                            n2:=Fields1.IndexOf(CommonFields[CurField]);
                            n3:=Fields2.IndexOf(CommonFields[CurField]);
                            AField1:=PeField(Fields1.Objects[n2]);
                            AField2:=PeField(Fields2.Objects[n3]);
                            s1:=trim(AField1^.FFieldText);
                            s2:=trim(AField2^.FFieldText);
                            IF ValDupForm.IgnoreLetterCase.Checked THEN
                              BEGIN
                                s1:=ANSIUpperCase(s1);
                                s2:=ANSIUpperCase(s2);
                              END;
                            IF s1<>s2 THEN
                              BEGIN
                                INC(FieldsWithError);
                                IF FirstErrorInRecord THEN
                                  BEGIN
                                    FirstErrorInRecord:=False;
                                    INC(RecsWithError);
                                    IF UsesIndex THEN
                                      BEGIN
                                        ValReport.Append(Format(FormStr,[Format(Lang23136,[Rec1^.CurRecord]),  //'Record key fields: (Rec.#%d)'
                                          Format(Lang23138,[Rec2^.CurRecord])]));  //'Record #%d'
                                        MakeReportFieldHeader;
                                      END
                                    ELSE
                                      BEGIN
                                        s1:=Format(Lang23138,[Rec1^.CurRecord]);    //'Record #%d'
                                        s2:=Format(Lang23138,[Rec2^.CurRecord]);    //'Record #%d'
                                        ValReport.Append(Format(FormStr,[s1,s2]));
                                        ValReport.Append(BlankStr);
                                      END;
                                  END;
                                s1:='  '+trim(AField1^.FName)+' = '+trim(AField1^.FFieldText);
                                s2:='  '+trim(AField2^.FName)+' = '+trim(AField2^.FFieldText);
                                ValReport.Append(Format(FormStr,[s1,s2]));
                                ErrorsFound:=True;
                              END;  //if FFieldText does not compare
                          END;  //for CurField
                      END  //if a key-match was found in Rec2
                    ELSE IF NOT ValDupForm.IgnoreMissingRec2.Checked THEN
                      BEGIN
                        IF UsesIndex THEN
                          BEGIN
                            ValReport.Append(Format(FormStr,[Format(Lang23136,[Rec1^.CurRecord]),'']));  //'Record key fields: (Rec.#%d)'
                            MakeReportFieldHeader;
                          END
                        ELSE
                          BEGIN
                            ValReport.Append(Format(FormStr,[Format(Lang23138,[Rec1^.CurRecord]),'']));  //Record #%d
                            ValReport.Append(BlankStr);
                          END;
                        ValReport.Append(Format(FormStr,[Lang23140,Lang23142]));   //'Record not found in datafile 2'  'Record not found'
                        INC(RecsMissing2);
                        ErrorsFound:=True;
                      END;  //if Rec1 keys doesn't exist i Rec2
                  END;  //if a record was found in Rec1
                IF NOT FirstErrorInRecord THEN ValReport.Append(cFill('-',78));

              END;  //while CurRec1<LastRec1

            {Report if records in index2 wasn't validated}
            FillChar(Buff,SizeOf(buff),0);
            IF UsesIndex THEN
              BEGIN
                //FOR CurRec2:=0 TO Index2.Count-1 DO
                FOR CurRec2:=1 TO Rec2^.NumRecords DO
                  BEGIN
                    IF ((CurRec2+Rec1^.NumRecords) MOD ProgressForm.pBar.Step)=0 THEN
                      BEGIN
                        ProgressForm.pBar.StepIt;
                        Application.ProcessMessages;
                        IF UserAborts THEN
                          BEGIN
                            IF eDlg(Lang(23166),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort validation of duplicate datafiles?'
                            THEN Exit ELSE UserAborts:=False;
                          END;  //if UserAborts
                      END;
                    Index2.Position:=30*(CurRec2-1)*NumIndexFields;
                    Index2.Read(buff,1);
                    IF Buff[0]<>#255 THEN
                    //IF Integer(Index2.Objects[CurRec2])>=0 THEN
                      BEGIN
                        //eReadOnlyRecord(Rec2,TxtFile2,Integer(Index2.Objects[CurRec2]));
                        eReadOnlyRecord(Rec2,TxtFile2,CurRec2);
                        IF (NOT Rec2^.CurRecDeleted) OR (NOT IgnoreDel) THEN
                          BEGIN
                            With ValReport DO
                              BEGIN
                                Append(Format(FormStr,['',Format(Lang23136,[Rec2^.CurRecord])])); //Record key fields: (Rec.#%d)
                                FOR n:=1 TO NumIndexFields DO
                                  BEGIN
                                    n2:=Fields2.IndexOf(IndexFieldNames[n]);
                                    AField2:=PeField(Fields2.Objects[n2]);
                                    s2:=Format('%-10s = %s',[trim(AField2^.FName),trim(AField2^.FFieldText)]);
                                    IF Length(s2)>37 THEN s2:=Copy(s2,1,34)+'...';
                                    Append(Format(FormStr,['',s2]));
                                  END;  //for mrN
                                Append(BlankStr);
                                Append(Format(FormStr,[Lang23142,Lang23144]));   //'Record not found'  'Record not found in datafile 1'
                                Append(cFill('-',78));
                                INC(RecsMissing1);
                                ErrorsFound:=True;
                              END;  //with ValReport
                          END;  //if record can be reported
                      END;  //if record wasn't validated
                  END;  //for CurRec2
              END //if usesIndex
            ELSE
              BEGIN
                IF (CurRec2<>-1) AND (CurRec2<Rec2^.NumRecords) THEN
                  BEGIN
                    {Report on records in datafile 2 that wasn't validated}
                    REPEAT
                      IF ((CurRec2+Rec1^.NumRecords) MOD ProgressForm.pBar.Step)=0 THEN
                        BEGIN
                          ProgressForm.pBar.StepIt;
                          Application.ProcessMessages;
                          IF UserAborts THEN
                            BEGIN
                              IF eDlg(Lang(23166),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort validation of duplicate datafiles?'
                              THEN Exit ELSE UserAborts:=False;
                            END;  //if UserAborts
                        END;
                      INC(CurRec2);
                      eReadOnlyNextRecord(Rec2,TxtFile2);
                      IF (NOT Rec2^.CurRecDeleted) OR (NOT IgnoreDel) THEN
                        BEGIN
                          ValReport.Append(Format(FormStr,['',Lang(23168)+IntToStr(Rec2^.CurRecord)]));   //'Record #'
                          ValReport.Append(BlankStr);
                          ValReport.Append(Format(FormStr,['  '+Lang23142,'  '+Lang23144]));   //'Record not found'  'Record not found in datafile 1'
                          ValReport.Append(cFill('-',78));
                          INC(RecsMissing1);
                          ErrorsFound:=True;
                        END;  //if record can be reported
                    UNTIL (CurRec2=Rec2^.NumRecords)
                  END;  //If records in datafile 2 wasn't validated
              END;  //if not usesIndex


            IF NOT ErrorsFound THEN
              BEGIN
                ValReport.Append('');
                ValReport.Append(Lang(23146));  //'The data in the two datafiles are the same, given the selected options'
                ValReport.Append('');
              END;

            {Write report resume}
            FieldsTested:=CommonFields.Count * RecsTested;

            n:=ResultsStartLine;
            ValReport[n+2]:=Format(Lang(23148),[RecsMissing1]);   //'Records missing in datafile 1:      %6d'
            ValReport[n+3]:=Format(Lang(23150),[RecsMissing2]);   //'Records missing in datafile 2:      %6d'
            ValReport[n+5]:=Format(Lang(23152),[RecsTested]);     //'Number of common records found:     %6d'
            ValReport[n+6]:=Format(Lang(23154),[CommonFields.Count]);  //'Number of tested fields pr. record: %6d'
            ValReport[n+7]:=Format(Lang(23156),[FieldsTested]);        //'Total number of tested fields:      %6d'
            IF RecsTested>0 THEN
            ValReport[n+9]:=Format(Lang(23158),   //'%d out of %d records had errors (%5.2f pct.)'
              [RecsWithError,RecsTested,100*(Int(RecsWithError)/Int(RecsTested))])
            ELSE ValReport[n+9]:='';
            IF Fieldstested>0 THEN
            ValReport[n+10]:=Format(Lang(23160),  //'%d out of %d fields had errors (%5.2f pct.)'
              [FieldsWithError,FieldsTested,100*(Int(FieldsWithError)/Int(FieldsTested))])
            ELSE ValReport[n+10]:='';
          FINALLY
            EnableTaskWindows(WindowList);
            ProgressForm.Free;
          END;  //try..finally

          IF Length(ValReport.Text)>65500 THEN
            BEGIN
              TRY
                Screen.Cursor:=crHourGlass;
                tmpS:=ExtractFileDir(ParamStr(0))+'\~EpdLog';
                n:=1;
                WHILE FileExists(tmpS+IntToStr(n)+'.tmp') DO INC(n);
                tmpS:=tmpS+IntToStr(n)+'.tmp';
                ValReport.SaveToFile(tmpS);
                AEdForm:=TEdForm.Create(MainForm);
                WITH AEdForm DO
                  BEGIN
                    Open(tmpS);
                    CloseFile(BlockFile);
                    PathName:=DefaultFilename+IntToStr(WindowNum);
                    Caption:=Lang(23162);  //'Validation report'
                    MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                      IndexOfObject(TObject(AEdForm))]:=Defaultfilename+IntToStr(WindowNum);
                    FormType:=ftDocumentation;
                    Ed.Font.Assign(epiDocuFont);
                    Ed.SelStart:=0;
                    Ed.Modified:=True;
                  END;  //with
              FINALLY
                tmpBool:=DeleteFile(tmpS);
                Screen.Cursor:=crDefault;
              END;  //try..finally
            END
          ELSE
            BEGIN
              {ValReport.Text < 65500 chars}
              Screen.Cursor:=crHourGlass;
              LockWindowUpdate(MainForm.Handle);
              AEdForm:=TEdForm.Create(MainForm);
              WITH AEdForm DO
                BEGIN
                  Ed.Visible:=False;
                  FormType:=ftDocumentation;
                  Caption:=Lang(23162);   //'Validation report'
                  Ed.Font.Assign(epiDocuFont);
                  Ed.Color:=DocuColor;
                  Ed.ScrollBars:=ssBoth;
                  Ed.Lines.Capacity:=ValReport.Count;
                  Ed.Lines.Text:=ValReport.Text;
                  Ed.ScrollBars:=ssBoth;
                  Ed.Visible:=True;
                  Ed.SelStart:=0;
                END;
              LockWindowUpDate(0);
              Screen.Cursor:=crDefault;
            END;  //ValReport.Text < 65500 chars
        END;  //if ok to run validation
      //CloseFile(TxtFile1);
      //Closefile(TxtFile2);
      IF UsesIndex THEN
        BEGIN
          Index1.Free;
          Index2.Free;
        END;
      DecimalSeparator:=OldDecimalSep;

    END;  //if do make validation
  FINALLY
  Screen.Cursor:=crDefault;
  {$I-}
  CloseFile(TxtFile1);
  CloseFile(TxtFile2);
  n:=IOResult;
  {$I+}
  ValDupForm.Free;
  Fields1.Free;
  Fields2.Free;
  CommonFields.Free;
  ValReport.Free;
  DisposeDatafilePointer(Rec1);
  DisposeDatafilePointer(Rec2);
  END;  //try..finally
end;  //procedure DoValidate


procedure TValDupForm.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(140);
end;

end.
