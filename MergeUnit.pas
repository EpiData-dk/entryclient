unit MergeUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, Math, checklst;

type
  TMergeForm = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    AppendPage: TTabSheet;
    MergePage: TTabSheet;
    AppendImage: TImage;
    AppendSelCheck: TRadioButton;
    AppendAllCheck: TRadioButton;
    Label3: TLabel;
    MergeImage: TImage;
    MergeSelCheck: TRadioButton;
    Label4: TLabel;
    MergeAllCheck: TRadioButton;
    OKBtn: TBitBtn;
    Label5: TLabel;
    ResultFileEdit: TEdit;
    FindResultBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Label1: TLabel;
    FilenameA: TLabel;
    InfoA: TLabel;
    Label7: TLabel;
    FilenameB: TLabel;
    InfoB: TLabel;
    CopyCheckfileCheck: TCheckBox;
    AppendBCheckfileLabel: TLabel;
    SelectkeyGroup: TGroupBox;
    FieldSelectList1: TCheckListBox;
    VarLabel: TLabel;
    DotsLabel: TLabel;
    ComDataRadio: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure AppendSelCheckClick(Sender: TObject);
    procedure MergeSelCheckClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FindABtnClick(Sender: TObject);
    procedure FieldSelectList1ClickCheck(Sender: TObject);
    procedure FieldSelectList1MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MergeForm: TMergeForm;

Procedure AppendMergeDatafiles;

implementation

uses MainUnit,EpiTypes,FileUnit, InputFormUnit, SelectFilesUnit, PeekCheckUnit,
  ProgressUnit;

{$R *.DFM}

VAR
  AppendSel,AppendAll,MergeSelA,MergeAllA, MergeSelB, MergeAllB :TBitMap;

procedure TMergeForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  AppendSel:=TBitMap.Create;
  AppendSel.LoadFromResourceName(hInstance,'ADDSEL');
  AppendAll:=TBitMap.Create;
  AppendAll.LoadFromResourceName(hInstance,'ADDALL');
  MergeSelA:=TBitMap.Create;
  MergeSelA.LoadFromResourceName(hInstance,'MERGESELA');
  MergeSelB:=TBitMap.Create;
  MergeSelB.LoadFromResourceName(hInstance,'MERGESELB');
  MergeAllA:=TBitMap.Create;
  MergeAllA.LoadFromResourceName(hInstance,'MERGEALLA');
  MergeAllB:=TBitMap.Create;
  MergeAllB.LoadFromResourceName(hInstance,'MERGEALLB');

  AppendImage.Picture.Bitmap.Assign(AppendSel);
  MergeImage.Picture.Bitmap.Assign(MergeSelA);
end;

procedure TMergeForm.AppendSelCheckClick(Sender: TObject);
begin
  IF AppendSelCheck.Checked THEN
    BEGIN
      AppendImage.Picture.Bitmap.Assign(AppendSel);
      //AppendBCheckfileLabel.Visible:=False;
    END
  ELSE
    BEGIN
      AppendImage.Picture.Bitmap.Assign(AppendAll);
      //AppendBCheckfileLabel.Visible:=True;
    END;
end;

procedure TMergeForm.MergeSelCheckClick(Sender: TObject);
begin
  IF MergeSelCheck.Checked THEN
    BEGIN
      IF ComDataRadio.ItemIndex=0
      THEN MergeImage.Picture.Bitmap.Assign(MergeSelA)
      ELSE MergeImage.Picture.Bitmap.Assign(MergeSelB);
    END
  ELSE
    BEGIN
      IF ComDataRadio.itemIndex=0
      THEN MergeImage.Picture.Bitmap.Assign(MergeAllA)
      ELSE MergeImage.Picture.Bitmap.Assign(MergeAllB);
    END;
end;

procedure TMergeForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AppendSel.Free;
  AppendAll.Free;
  MergeSelA.Free;
  MergeSelB.Free;
  MergeAllA.Free;
  MergeAllB.Free;
end;

procedure TMergeForm.PageControl1Change(Sender: TObject);
begin
  IF PageControl1.ActivePage=AppendPage
  THEN OKBtn.Caption:=Lang(6008)  //'Append'
  ELSE OKBtn.Caption:=Lang(6010);  //'Merge'
end;

procedure TMergeForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
VAR
  F:TextFile;
  n,NumIndexFields:Integer;
begin
  IF ModalResult=mrOK THEN
    BEGIN
      IF (Trim(ResultfileEdit.Text)<>'') AND (ExtractFileExt(ResultFileEdit.Text)='') THEN ResultFileEdit.Text:=ChangeFileExt(ResultFileEdit.Text,'.rec');
      IF (AnsiUpperCase(FilenameA.Caption)=AnsiUpperCase(ResultFileEdit.Text))
      OR (AnsiUpperCase(FilenameB.Caption)=AnsiUpperCase(ResultFileEdit.Text))
      OR (AnsiUppercase(FilenameB.Caption)=AnsiUpperCase(FilenameA.Caption)) THEN
        BEGIN
          CanClose:=False;
          ErrorMsg(Lang(24000));   //'The three datafiles must all be different files'
          Exit;
        END;
      NumIndexFields:=0;
      IF Pagecontrol1.ActivePage=MergePage THEN
        BEGIN
          FOR n:=0 TO FieldSelectList1.Items.Count-1 DO
            IF FieldSelectList1.Checked[n] THEN INC(NumIndexFields);
          IF NumIndexFields=0 THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Lang(24002));  //'Please select one or more key fields'
              Exit;
            END;  //if 0 indexfields
          IF NumIndexFields>3 THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Lang(24004));  //'A maximum of 3 key fields can be selected'
              Exit;
            END;
        END;  //if merging
      IF FileExists(ResultFileEdit.Text) THEN
        BEGIN
          IF WarningDlg(Format(Lang(21500),[ResultFileEdit.Text]))=mrOK THEN   //21500=A file with name %s already exists.~~Overwrite existing file?
            BEGIN
              DeleteFile(ResultFileEdit.Text);
              CanClose:=True;
            END
          ELSE CanClose:=False;
        END
      ELSE
        BEGIN
          {$I-}
          AssignFile(F,ResultFileEdit.text);
          Rewrite(F);
          n:=IOResult;
          {$I+}
          IF n<>0 THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Format(Lang(20416),[ResultFileEdit.text]));   //20416=The datafile with the name %s cannot be created.
            END;
          {$I-}
          CloseFile(F);
          n:=IOResult;
          {$I-}
        END;
    END
  ELSE CanClose:=True;

end;



Procedure AppendMergeDatafiles;
VAR
  dfA,dfB,dfC: PDatafileInfo;
  AField,BField,CField: PeField;
  n,CurField,LastYPos,IndentX,CurRec,CurLin,CurRecA,CurRecB,TotalNumRecords: Integer;
  ok,tmpBool,DecimalsError,DoAppend: Boolean;
  s,tmpS,Filename1,Filename2: String;
  F,CFile,AFile,BFile: TextFile;
  tmpValue: Double;
  ChecksC,ChecksB, ChkLin: TStringList;
  tmpDate: TDateTime;
  NumIndexFields: Integer;
  IndexFieldNames: Array[1..3] OF ShortString;
  IndexFields: Array[1..3] OF PeField;
  AIndex,BIndex: TMemoryStream;
  Buff: Array[0..91] OF Char;
  WindowList: Pointer;

  Function IsIndexField(s: ShortString):Boolean;
  BEGIN
    s:=AnsiUpperCase(trim(s));
    IF (s=AnsiUpperCase(IndexfieldNames[1]))
    OR (s=AnsiUpperCase(IndexfieldNames[2]))
    OR (s=AnsiUpperCase(IndexfieldNames[3]))
    THEN Result:=True ELSE Result:=False;
  END;


BEGIN  //AppendMergedatafiles
  dfA:=NIL;
  dfB:=NIL;
  dfC:=NIL;
  AIndex:=NIL;
  BIndex:=NIL;
  MergeForm:=NIL;
  TRY
    SelectFilesForm:=TSelectFilesForm.Create(MainForm);
    WITH SelectFilesForm DO
      BEGIN
        Ext1:='.rec';
        Ext2:='.rec';
        Caption:=Lang(6000);  //'Append/merge datafiles';
        File1Label.Caption:=Lang(23102);   //'Name of first datafile'
        File2Label.Caption:=Lang(23104);   //'Name of second datafile'
        IF LastSelectFilestype=sfMerge THEN
          BEGIN
            File1Edit.Text:=LastSelectFile1;
            File2Edit.Text:=LastSelectFile2;
          END;
      END;
    IF SelectFilesForm.ShowModal=mrCancel THEN
      BEGIN
        SelectFilesForm.Free;
        Exit;
      END;
  EXCEPT
    ErrorMsg('Could not create SelectFilesForm'); 
    SelectFilesForm.Free;
    Exit;
  END;  //try..Except
  Filename1:=SelectFilesForm.File1Edit.Text;
  Filename2:=SelectFilesForm.File2Edit.Text;
  SelectFilesForm.Free;
  LastSelectFilestype:=sfMerge;
  LastSelectFile1:=Filename1;
  LastSelectFile2:=Filename2;


  IF (NOT (GetDatafilePointer(dfA)))
  OR (NOT (GetDatafilePointer(dfB)))
  OR (NOT (GetDatafilePointer(dfC))) THEN
    BEGIN
      ErrorMsg('Memory error: the datafiles can not be opened');   //***
      DisposeDatafilePointer(dfA);
      DisposeDatafilePointer(dfB);
      DisposeDatafilePointer(dfC);
      Exit;
    END;

  dfA^.RECFilename:=ExpandFilename(Filename1);
  dfB^.RECFilename:=ExpandFilename(Filename2);
  ok:=True;
  IF NOT PeekDatafile(dfA) THEN ok:=False;
  IF NOT PeekDatafile(dfB) THEN ok:=False;
{  IF ok THEN
    BEGIN
      IF dfA^.NumRecords=0 THEN
        BEGIN
          ErrorMsg(Format(Lang(22334),[dfA^.RECFilename]));  //22334=The datafile %s contains no records.
          ok:=False;
        END;
      IF dfB^.NumRecords=0 THEN
        BEGIN
          ErrorMsg(Format(Lang(22334),[dfB^.RECFilename]));  //22334=The datafile %s contains no records.
          ok:=False;
        END;
    END;}

  IF ok THEN
    BEGIN
      dfA^.CHKFilename:=ChangeFileExt(dfA^.RECFilename,'.chk');
      IF FileExists(dfA^.CHKFilename) THEN
        BEGIN
          dfA^.HasCheckFile:=True;
          IF NOT PeekApplyCheckFile(dfA,tmpS) THEN
            BEGIN
              ErrorMsg(Format(Lang(20800),[dfA^.RECFilename]));  //20800=The checkfile %s contains errors and cannot be applied.
              ok:=False;
            END;
        END
      ELSE dfA^.HasCheckFile:=False;

      dfB^.CHKFilename:=ChangeFileExt(dfB^.RECFilename,'.chk');
      IF FileExists(dfB^.CHKFilename) THEN
        BEGIN
          dfB^.HasCheckFile:=True;
          IF NOT PeekApplyCheckFile(dfB,tmpS) THEN
            BEGIN
              ErrorMsg(Format(Lang(20800),[dfB^.RECFilename]));   //20800=The checkfile %s contains errors and cannot be applied.
              ok:=False;
            END;
        END
      ELSE dfB^.HasCheckFile:=False;
    END;

  IF NOT ok THEN
    BEGIN
      DisposeDatafilePointer(dfA);
      DisposeDatafilePointer(dfB);
      DisposeDatafilePointer(dfC);
      Exit;
    END;

  TRY
    MergeForm:=TMergeForm.Create(MainForm);
    WITH MergeForm DO
      BEGIN
        FilenameA.Caption:=dfA^.RECFilename;
        FilenameB.Caption:=dfB^.RECFilename;
        InfoA.Caption:=Format(Lang(24006),[dfA^.NumFields,dfA^.NumRecords]);   //'%d fields, %d records'
        InfoB.Caption:=Format(Lang(24006),[dfB^.NumFields,dfB^.NumRecords]);   //%d fields, %d records
        CopyCheckfileCheck.Enabled:=dfA^.HasCheckFile;
        AppendBCheckfileLabel.Visible:=False;
        VarLabel.Caption:='';
        PageControl1.ActivePage:=AppendPage;
      END;  //with

    {Put common fields on the FieldSelectList1}
    FOR CurField:=0 TO dfA^.FieldList.Count-1 DO
      BEGIN
        AField:=PeField(dfA^.FieldList.Items[Curfield]);
        IF AField^.Felttype<>ftQuestion THEN
          BEGIN
            BField:=GetField(Afield^.FName,dfB);
            IF BField<>NIL
            THEN MergeForm.FieldSelectList1.Items.AddObject(Trim(AField^.FName),TObject(AField));
          END;  //if
      END;  //For CurField

    DoAppend:=True;
    IF NOT (MergeForm.ShowModal=mrOK) THEN
      BEGIN
        DisposeDatafilePointer(dfA);
        DisposeDatafilePointer(dfB);
        DisposeDatafilePointer(dfC);
        Exit;
      END;
  EXCEPT
    DisposeDatafilePointer(dfA);
    DisposeDatafilePointer(dfB);
    DisposeDatafilePointer(dfC);
    Exit;
  END;  //try..except

  TRY
    IF MergeForm.PageControl1.ActivePage=MergeForm.AppendPage THEN DoAppend:=True ELSE DoAppend:=False;
    IF (NOT DoAppend) AND (dfB^.NumRecords=0) THEN
      BEGIN
        ErrorMsg(Lang(24046));  //'Datafile B must contain data.'
        DisposeDatafilePointer(dfA);
        DisposeDatafilePointer(dfB);
        DisposeDatafilePointer(dfC);
        Exit;
      END;

    dfC^.RECFilename:=ExpandFilename(MergeForm.ResultfileEdit.Text);
    dfC^.EpiInfoFieldNaming:=dfA^.EpiInfoFieldNaming;

    IF DoAppend THEN
      BEGIN
        {Test if fields from B can be saved in fields from A}
        FOR CurField:=0 TO dfA^.FieldList.Count-1 DO
          BEGIN
            AField:=PeField(dfA^.FieldList.items[CurField]);
            BField:=GetField(AField^.FName,dfB);
            IF BField<>NIL THEN
              BEGIN
                {A field with the same name as AField exists in dfB}
                ok:=False;
                CASE AField^.Felttype OF
                  ftInteger:  IF (BField^.Felttype=ftIDNUM) or (BField^.Felttype=ftFloat) THEN ok:=True;
                  ftFloat:    IF (BField^.Felttype=ftIDNUM) or (BField^.Felttype=ftInteger) THEN ok:=True;
                  ftIDNUM:    IF (BField^.Felttype=ftInteger) or (BField^.Felttype=ftFloat) THEN ok:=True;
                  ftDate,ftEuroDate,
                  ftToday,ftEuroToday,
                  ftYMDToday,
                  ftYMDDate: IF (BField^.Felttype in [ftDate,ftEuroDate,
                             ftYMDDate,ftToday,ftEuroToday,ftYMDToday]) THEN ok:=True;    //&&
                END;  //case
                IF AField^.Felttype=BField^.Felttype THEN ok:=True;
                IF (Afield^.Felttype in [ftAlfa,ftUpperAlfa,ftCrypt,ftSoundex]) THEN ok:=True;   //&&
                DecimalsError:=False;
                IF ((AField^.Felttype=ftInteger) OR (AField^.Felttype=ftFloat) OR (AField^.Felttype=ftIDNUM))
                AND (AField^.FNumDecimals<BField^.FNumDecimals) THEN
                  BEGIN
                    ok:=False;
                    DecimalsError:=True;
                  END;
                IF NOT ok THEN
                  BEGIN
                    IF DecimalsError
                    THEN tmpS:=Format(Lang(24008)+#13+   //'Append could lead to a loss of data in the field %s'
                      Lang(24010),[AField^.FName])  //'because the field in datafile A has fewer decimals than in datafile B'
                    ELSE tmpS:=Format(Lang(24012),[AField^.FName])+  //'The fields with the name %s are not compatible'
                      #13#13+Lang(6002)+' '+FieldTypeNames[ORD(AField^.Felttype)]+   //'Datafile A:'
                      #13+   Lang(6004)+' '+FieldTypeNames[ORD(BField^.Felttype)];   //'Datafile B:'
                    ErrorMsg(tmpS);
                    Exit;
                  END;  //if not compatible fields
              END;  //if field exists in dfB
          END;  //for CurField
      END;  //if DoAppend

    {Make datafile C}

    FOR CurField:=0 TO dfB^.FieldList.Count-1 DO
      PeField(dfB^.FieldList.Items[Curfield])^.FieldN:=0;

    LastYPos:=0;
    IndentX:=0;
    dfC^.NumFields:=0;

    {Copy fields from A + common fields A/B  to C}
    FOR CurField:=0 TO dfA^.FieldList.Count-1 DO
      BEGIN
        AField:=PeField(dfA^.FieldList.Items[Curfield]);
        IF (AField^.Felttype<>ftQuestion) AND (AField^.FFieldY<>LastYPos) THEN
          BEGIN
            LastYPos:=AField^.FFieldY;
            IndentX:=0;
          END;
        IF ( (Afield^.Felttype=ftQuestion)  AND (AField^.FQuestY<>LastYPos) ) THEN
          BEGIN
            LastYPos:=AField^.FQuestY;
            IndentX:=0;
          END;
        New(CField);
        ResetCheckProperties(CField);
        CField^:=AField^;
        //CField^.FValueLabel:=AField^.FValueLabel;
        //CField^.FIndex:=0;
        CField^.FOriginalQuest:=CField^.FQuestion;
        CField^.FFieldX:=CField^.FFieldX+IndentX;
        CField^.FQuestX:=Cfield^.FQuestX+IndentX;
        n:=GetFieldNumber(AField^.FName,dfB);
        IF n<>-1 THEN
          BEGIN
            BField:=PeField(dfB^.FieldList.Items[n]);
            CField^.FieldN:=MakeLong(CurField,n);
            BField^.FieldN:=1;
            IF (NOT DoAppend) AND (MergeForm.ComDataRadio.ItemIndex=1) THEN
              BEGIN
                //CField^.FValueLabel:=BField^.FValueLabel;
                CField^:=BField^;
                CField^.FOriginalQuest:=CField^.FQuestion;
              END;
            IF CField^.Felttype=ftFloat THEN
              BEGIN
                IF (AField^.FNumDecimals>0) OR (BField^.FNumDecimals>0) THEN
                  BEGIN
                    CField^.FLength:=MaxIntValue([AField^.FLength-1-AField^.FNumDecimals,BField^.FLength-1-BField^.FNumDecimals]);
                    CField^.FLength:=CField^.FLength + 1 + MaxIntValue([AField^.FNumDecimals,BField^.FNumDecimals]);
                    CField^.FNumDecimals:=MaxIntValue([AField^.FNumDecimals,BField^.FNumDecimals]);
                    IF CField^.FLength>14 THEN
                      BEGIN
                        tmpS:=Format(Lang(24014)+#13#13+  //'The numeric field %s too long (>14 characters)~Compress datafiles'
                        Lang(24016),    //'Append terminates'
                        [trim(AField^.FName)]);
                        ErrorMsg(tmpS);
                        Dispose(CField);
                        FOR n:=0 TO dfC^.FieldList.Count-1 DO
                          BEGIN
                            CField:=PeField(dfC^.FieldList.Items[n]);
                            ResetCheckProperties(CField);
                          END;
                        DisposeDatafilePointer(dfA);
                        DisposeDatafilePointer(dfB);
                        DisposeDatafilePointer(dfC);
                        Exit;
                      END;  //if FLength>14
                  END  //if has decimals after comma
                ELSE CField^.FLength:=MaxIntValue([AField^.FLength,BField^.FLength]);
              END
            ELSE CField^.FLength:=MaxIntValue([AField^.FLength,BField^.FLength]);
            IndentX:=CField^.FLength-AField^.FLength;
          END  //if BField<>NIL
        ELSE CField^.FieldN:=MakeLong(CurField,$FFFF);
        dfC^.FieldList.Add(CField);
        IF CField^.Felttype<>ftQuestion THEN INC(dfC^.NumFields);
      END;  //For Curfield
    INC(LastYPos);

    {Add B's unique fields to C - if the user has selected to do that or if merging}
    IF ( (DoAppend) AND (MergeForm.AppendAllCheck.Checked) ) OR (NOT DoAppend) THEN
      BEGIN
        FOR CurField:=0 TO dfB^.FieldList.Count-1 DO
          BEGIN
            BField:=PeField(dfB.FieldList.Items[CurField]);
            IF BField^.FieldN=0 THEN
              BEGIN
                {Append a field that didn't exist in A}
                New(CField);
                CField^:=BField^;
                //ResetCheckProperties(CField);
                //CField^.FValueLabel:=BField^.FValueLabel;
                //CField^.FIndex:=0;
                CField^.FOriginalQuest:=CField^.FQuestion;
                CField^.FQuestY:=LastYPos;
                CField^.FieldN:=MakeLong($FFFF,Curfield);
                IF CField^.Felttype<>ftQuestion THEN CField^.FFieldY:=LastYPos;
                INC(LastYPos);
                dfC^.FieldList.Add(CField);
                IF CField^.Felttype<>ftQuestion THEN INC(dfC^.NumFields);
                IF (CField^.FQuestY>999) OR (CField^.FFieldY>999) THEN
                  BEGIN
                    IF DoAppend THEN tmpS:=
                    Lang(24018)+  //'Appending the two files results in linenumbers higher than 999 which is not allowed in a datafile.'
                    #13#13+Lang(24016)      //'Append terminates.'
                    ELSE tmpS:=Lang(24020)+     //'Merging the two files results in linenumbers higher than 999 which is not allowed in a datafile.'
                    Lang(24022);    //'Merge terminates.'
                    ErrorMsg(tmpS);
                    Exit;
                  END;
              END;  //if Bfield^.FieldN=0
          END;  //for Curfield
      END;  //if AppendAllCheck.Checked
  EXCEPT
    FOR n:=0 TO dfC^.FieldList.Count-1 DO
      BEGIN
        CField:=PeField(dfC^.FieldList.Items[n]);
        ResetCheckProperties(CField);
      END;
    DisposeDatafilePointer(dfA);
    DisposeDatafilePointer(dfB);
    DisposeDatafilePointer(dfC);
    Exit;
  END;

    {Get datafile label for dfC}
  TRY
    TRY
      InputForm:=TInputForm.Create(Application);
    EXCEPT
      InputForm.Free;
      ErrorMsg(Format(Lang(20204),[751]));   //'Out of memory (reference code 751)');
      Exit;
    END;
    InputForm.Maxlength:=50;
    InputForm.LabelText:=Lang(20408);   //'Enter description of datafile (datafile label)'
    InputForm.Caption:=Lang(20410)+' '+ExtractFilename(dfC^.RECFilename);  //'Datafile label for'
    IF InputForm.ShowModal=mrOK
    THEN dfC^.Filelabel:=InputForm.UserInput ELSE dfC^.FileLabel:='';
    InputForm.Free;

    IF NOT PeekCreateDatafile(dfC) THEN
      BEGIN
        tmpS:=Lang(20416)+#13#13;    //20416=The datafile with the name %s cannot be created.
        IF DoAppend THEN tmpS:=tmpS+Lang(24016) ELSE tmpS:=tmpS+Lang(24022);  //append/merge terminates
        ErrorMsg(Format(tmpS,[dfC^.RECFilename]));
        Exit;
      END;

    {Write valuelabels to dfC's checkfile}
    dfC^.CHKFilename:=ChangeFileExt(dfC^.RECFilename,'.chk');
    DeleteFile(dfC^.CHKFilename);    
    IF (DoAppend) OR (MergeForm.ComDataRadio.ItemIndex=0) THEN
      BEGIN
        dfC^.ValueLabels.AddStrings(dfA^.ValueLabels);
        dfC^.ValueLabels.AddStrings(dfB^.ValueLabels);
      END
    ELSE
      BEGIN
        dfC^.ValueLabels.AddStrings(dfB^.ValueLabels);
        dfC^.ValueLabels.AddStrings(dfA^.ValueLabels);
      END;
    TRY
      ChkLin:=TStringList.Create;
      ChecksToStrings(dfC,ChkLin);
      IF ChkLin.Count>0 THEN ChkLin.SaveToFile(ChangeFileExt(dfC^.RECFilename,'.chk'));
    FINALLY
      ChkLin.Free;
      dfC^.ValueLabels:=NIL;
      dfC^.ValueLabels:=NIL;
    END;
  EXCEPT
    ErrorMsg('Error creating datafile C');
    DisposeDatafilePointer(dfA);
    DisposeDatafilePointer(dfB);
    DisposeDatafilePointer(dfC);
    Exit;
  END;

  TRY
    {Prepare CFile to WriteNextRecord}
    AssignFile(CFile,dfC^.RECFilename);
    Append(CFile);

    UserAborts:=False;
    ProgressForm:=TProgressForm.Create(MainForm);
    IF DoAppend
    THEN ProgressForm.Caption:=Lang(24024)   //'Appending datafiles'
    ELSE ProgressForm.Caption:=Lang(24026);  //'Merging datafile'
    ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
    ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
    ProgressForm.pBar.Position:=0;
    WindowList:=DisableTaskWindows(ProgressForm.Handle);
    ProgressForm.Show;

    IF DoAppend THEN
      BEGIN
        {append datafiles}
        ProgressForm.pBar.Max:=dfA^.NumRecords+dfB^.NumRecords;

        {Prepare dfA for readOnly}
        //CloseFile(dfA^.DatFile);
        dfA^.Datfile.Free;   //§§§
        dfA^.Datfile:=NIL;  //§§§
        AssignFile(F,dfA^.RECFilename);
        Reset(F);
        FOR n:=0 TO dfA^.FieldList.Count DO
          ReadLN(F);

        {Copy records from A to C}
        FOR CurRec:=1 TO dfA^.NumRecords DO
          BEGIN
            IF ProgressStep(dfA^.NumRecords+dfB^.NumRecords,CurRec) THEN
              BEGIN
                ProgressForm.pBar.Position:=CurRec;
                ProgressForm.pLabel.Caption:=Format(Lang(20942),[CurRec,dfA^.NumRecords+dfB^.NumRecords]);  //20942=Writing record no. %d of %d
                Application.ProcessMessages;
                IF UserAborts THEN
                  BEGIN
                    IF eDlg(Lang(24028),mtConfirmation,[mbYes,mbNo],0)=mrYes THEN    //'Abort append datafiles?'
                      BEGIN
                        CloseFile(F);
                        Exit;
                      END
                    ELSE UserAborts:=False;
                  END;
              END;
            eReadOnlyNextRecord(dfA,F);
            FOR CurField:=0 TO dfA^.FieldList.Count-1 DO
              BEGIN
                AField:=PeField(dfA^.FieldList.Items[CurField]);
                CField:=PeField(dfC^.FieldList.Items[CurField]);
                IF AField^.Felttype<>ftQuestion THEN
                  BEGIN
                    IF (AField^.Felttype=ftFloat) AND (trim(AField^.FFieldText)<>'') THEN
                      BEGIN
                        tmpValue:=eStrToFloat(AField^.FFieldText);
                        Str(tmpValue:CField^.FLength:CField^.FNumDecimals,tmpS);
                        CField^.FFieldText:=tmpS;
                      END  //if ftFloat
                    ELSE CField^.FFieldText:=trim(AField^.FFieldText);
                  END;  //if not ftQuestion
              END;  //for CurField
            //peWriteRecord(dfC,NewRecord);
            WriteNextRecord(dfC,CFile);
          END;  //for CurRec

        CloseFile(F);

        {Copy records from B to C}

        {Prepare dfB for readOnly}
        //CloseFile(dfB^.DatFile);
        dfB^.Datfile.Free;   //§§§
        dfB^.Datfile:=NIL;  //§§§
        AssignFile(F,dfB^.RECFilename);
        Reset(F);
        FOR n:=0 TO dfB^.FieldList.Count DO
          ReadLN(F);

        FOR CurField:=0 TO dfC^.FieldList.Count-1 DO
          BEGIN
            CField:=PeField(dfC^.FieldList.Items[CurField]);
            CField^.FieldN:=GetFieldNumber(CField^.FName,dfB);
          END;

        FOR CurRec:=1 TO dfB^.NumRecords DO
          BEGIN
            IF ProgressStep(dfA^.NumRecords+dfB^.NumRecords,CurRec+dfA^.NumRecords) THEN
              BEGIN
                ProgressForm.pBar.Position:=CurRec+dfA^.NumRecords;
                ProgressForm.pLabel.Caption:=Format(Lang(20942),[CurRec+dfA^.NumRecords,dfA^.NumRecords+dfB^.NumRecords]);  //20942=Writing record no. %d of %d
                Application.ProcessMessages;
                IF UserAborts THEN
                  BEGIN
                    IF eDlg(Lang(24028),mtConfirmation,[mbYes,mbNo],0)=mrYes THEN    //'Abort append datafiles?'
                      BEGIN
                        CloseFile(F);
                        Exit;
                      END
                    ELSE UserAborts:=False;
                  END;
              END;
            eReadOnlyNextRecord(dfB,F);
            FOR CurField:=0 TO dfC^.FieldList.Count-1 DO
              BEGIN
                CField:=PeField(dfC^.FieldList.Items[CurField]);
                IF CField^.Felttype<>ftQuestion THEN
                  BEGIN
                    //BField:=GetField(CField^.FName,dfB);
                    //IF BField<>NIL THEN
                    IF CField^.FieldN<>-1 THEN
                      BEGIN
                        BField:=PeField(dfB^.FieldList.Items[CField^.FieldN]);
                        IF (BField^.Felttype=ftFloat) AND (trim(BField^.FFieldText)<>'') THEN
                          BEGIN
                            tmpValue:=eStrToFloat(BField^.FFieldText);
                            Str(tmpValue:CField^.FLength:CField^.FNumDecimals,tmpS);
                            CField^.FFieldText:=tmpS;
                          END  //if ftFloat
                        ELSE IF (BField^.Felttype in [ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday]) AND    //&&
                         (trim(BField^.FFieldText)<>'') THEN
                           BEGIN
                             tmpDate:=mibStrToDate(BField^.FFieldText,BField^.Felttype);
                             tmpS:=mibDateToStr(tmpDate,CField^.Felttype);
                             CField^.FFieldText:=tmpS;
                           END  //if datefield
                        ELSE CField^.FFieldText:=trim(BField^.FFieldText);
                      END  //if BField<>NIL
                    ELSE CField^.FFieldText:='';
                  END;  //if not ftQuestion
              END;  //for CurField
            //peWriteRecord(dfC,NewRecord);
            WriteNextRecord(dfC,CFile);
          END;  //for CurRec
        CloseFile(F);
      END  //if append
    ELSE
      BEGIN
        {merge datafiles}
        IF MergeForm.MergeAllCheck.Checked
        THEN TotalNumRecords:=dfA^.NumRecords+dfB^.NumRecords
        ELSE TotalNumRecords:=dfA^.NumRecords;
        ProgressForm.pBar.Max:=TotalNumRecords;

        {Make list of index fields}
        NumIndexFields:=0;
        FOR n:=0 TO MergeForm.FieldSelectList1.Items.Count-1 DO
          IF MergeForm.FieldSelectList1.Checked[n] THEN
            BEGIN
              INC(NumIndexfields);
              IndexFieldNames[NumIndexFields]:=MergeForm.FieldSelectList1.Items[n];
            END;

        {Prepare dfA for readOnly}
        //CloseFile(dfA^.DatFile);
        dfA^.Datfile.Free;   //§§§
        dfA^.Datfile:=NIL;  //§§§
        AssignFile(AFile,dfA^.RECFilename);
        Reset(AFile);
        FOR n:=0 TO dfA^.FieldList.Count DO
          ReadLN(AFile);

        {Prepare dfB for readOnly}
        //CloseFile(dfB^.DatFile);
        dfB^.Datfile.Free;   //§§§
        dfB^.Datfile:=NIL;  //§§§
        AssignFile(BFile,dfB^.RECFilename);
        Reset(BFile);
        FOR n:=0 TO dfB^.FieldList.Count DO
          ReadLN(BFile);

        {Make index for file A}
        AIndex:=TMemoryStream.Create;
        AIndex.SetSize(dfA^.NumRecords*30*NumIndexFields);
        FillChar(buff,SizeOf(buff),0);
        CurRec:=0;
        ok:=True;
        FOR n:=1 TO NumIndexFields DO
          IndexFields[n]:=GetField(IndexFieldNames[n],dfA);

        WHILE (CurRec<dfA^.NumRecords) AND (ok) DO
          BEGIN
            INC(CurRec);
            eReadOnlyNextRecord(dfA,AFile);
            IF NOT dfA^.CurRecDeleted THEN
              BEGIN
                tmpS:='';
                FOR n:=1 TO NumIndexFields DO
                  BEGIN
                    //AField:=GetField(IndexFieldNames[n],dfA);
                    AField:=IndexFields[n];
                    IF (AField^.Felttype in [ftInteger,ftFloat,ftIDNUM])
                    THEN tmpS:=tmpS+Format('%30s', [trim(AField^.FFieldText)])
                    ELSE tmpS:=tmpS+Format('%-30s',[trim(AField^.FFieldText)]);
                  END;
                n:=1;
                StrPCopy(Buff,tmpS);
                WHILE (n<CurRec) AND (ok) DO
                  BEGIN
                    //Check for duplicates
                    ok:=NOT CompareMem(Pointer(LongInt(AIndex.Memory)+( 30*(n-1)*NumIndexFields )),@buff,30*NumIndexFields);
                    INC(n);
                  END;  //While n<CurRec and OK
                IF NOT ok THEN
                  BEGIN
                    DEC(n);
                    tmpS:=Format(Lang(23134),[dfA^.RECFilename,CurRec,n])+#13#13;  //'Dublicate keys found in %s~Keys in record %d are the same as record %d'
                    IF DoAppend THEN tmpS:=tmpS+Lang(24016)   //Append terminates
                    ELSE tmpS:=tmpS+Lang(24022);   //Merge terminates
                    ErrorMsg(tmpS);
                    Exit;
                  END  //if not ok
                ELSE
                  BEGIN
                    AIndex.Position:=30*(CurRec-1)*NumIndexfields;
                    StrPCopy(Buff,tmpS);
                    AIndex.Write(buff,30*NumIndexFields);
                  END;
              END  //if OK to add to index
            ELSE
              BEGIN
                //Add blank index entry
                FillChar(buff,SizeOf(buff),0);
                AIndex.Position:=30*(CurRec-1)*NumIndexFields;
                AIndex.Write(buff,30*NumIndexFields);
              END;
          END;  //While CurRec<NumRecords

        {Make index for file B}
        BIndex:=TMemoryStream.Create;
        BIndex.SetSize(dfB^.NumRecords*30*NumIndexFields);
        FillChar(buff,SizeOf(buff),0);
        CurRec:=0;
        ok:=True;
        FOR n:=1 TO NumIndexFields DO
          IndexFields[n]:=GetField(IndexFieldNames[n],dfB);

        WHILE (CurRec<dfB^.NumRecords) AND (ok) DO
          BEGIN
            INC(CurRec);
            eReadOnlyNextRecord(dfB,BFile);
            IF NOT dfB^.CurRecDeleted THEN
              BEGIN
                tmpS:='';
                FOR n:=1 TO NumIndexFields DO
                  BEGIN
                    //BField:=GetField(IndexFieldNames[n],dfB);
                    BField:=IndexFields[n];
                    IF (BField^.Felttype in [ftInteger,ftFloat,ftIDNUM])
                    THEN tmpS:=tmpS+Format('%30s', [trim(BField^.FFieldText)])
                    ELSE tmpS:=tmpS+Format('%-30s',[trim(BField^.FFieldText)]);
                  END;
                n:=1;
                StrPCopy(Buff,tmpS);
                WHILE (n<CurRec) AND (ok) DO
                  BEGIN
                    //Check for duplicates
                    ok:=NOT CompareMem(Pointer(LongInt(BIndex.Memory)+( 30*(n-1)*NumIndexFields )),@buff,30*NumIndexFields);
                    INC(n);
                  END;  //While n<CurRec and OK
                IF NOT ok THEN
                  BEGIN
                    DEC(n);
                    tmpS:=Format(Lang(23134),[dfB^.RECFilename,CurRec,n])+#13#13;  //'Dublicate keys found in %s~Keys in record %d are the same as record %d'
                    IF DoAppend THEN tmpS:=tmpS+Lang(24016)   //Append terminates
                    ELSE tmpS:=tmpS+Lang(24022);   //Merge terminates
                    ErrorMsg(tmpS);
                    Exit;
                  END  //if not ok
                ELSE
                  BEGIN
                    BIndex.Position:=30*(CurRec-1)*NumIndexfields;
                    StrPCopy(Buff,tmpS);
                    BIndex.Write(buff,30*NumIndexFields);
                  END;
              END  //if OK to add to index
            ELSE
              BEGIN
                //Add blank index entry
                FillChar(buff,SizeOf(buff),0);
                BIndex.Position:=30*(CurRec-1)*NumIndexFields;
                BIndex.Write(buff,30*NumIndexFields);
              END;
          END;  //While CurRec<NumRecords

        {Iterate records in datafile A}
        CurRecA:=0;
        WHILE CurRecA<dfA^.NumRecords DO
          BEGIN
            IF ProgressStep(TotalNumRecords,CurRecA) THEN
              BEGIN
                ProgressForm.pBar.Position:=CurRecA;
                ProgressForm.pLabel.Caption:=Format(Lang(24030),[CurRecA,TotalNumRecords]);  //'Examining record %d of %d'
                Application.ProcessMessages;
                IF UserAborts THEN
                  BEGIN
                    IF eDlg(Lang(24032),mtConfirmation,[mbYes,mbNo],0)=mrYes THEN Exit   //24032=Abort merge datafiles?
                    ELSE UserAborts:=False;
                  END;
              END;
            {Reset record in CFile}
            FOR n:=0 TO dfC^.FieldList.Count-1 DO
              IF PeField(dfC^.FieldList.Items[n])^.Felttype<>ftQuestion
              THEN PeField(dfC^.FieldList.Items[n])^.FFieldText:='';

            REPEAT
              INC(CurRecA);
              eReadOnlyRecord(dfA,AFile,CurRecA);
            UNTIL (NOT dfA^.CurRecDeleted) OR (CurRecA>=dfA^.NumRecords);
            IF (NOT dfA^.CurRecDeleted) THEN
              BEGIN
                FillChar(buff,SizeOf(buff),0);
                AIndex.Position:=30*(CurRecA-1)*NumIndexFields;
                AIndex.Read(Buff,30*NumIndexFields);
                CurRecB:=0;
                tmpBool:=False;
                //StrPCopy(Buff,tmpS);
                WHILE (CurRecB<=dfB^.NumRecords) AND (NOT tmpBool) DO
                  BEGIN
                    INC(CurRecB);
                    tmpBool:=CompareMem(Pointer(LongInt(BIndex.Memory)+( 30*(CurRecB-1)*NumIndexFields )),@buff,30*NumIndexfields);
                  END;
                IF tmpBool THEN eReadOnlyRecord(dfB,BFile,CurRecB) ELSE CurRecB:=-1;
                IF dfB^.CurRecDeleted THEN CurRecB:=-1;
                IF CurRecB>=1 THEN
                  BEGIN
                    {Mark the matching record i file B as copied}
                    BIndex.Position:=30*(CurRecB-1)*NumIndexFields;
                    Buff[0]:=#255;
                    BIndex.Write(Buff,1);
                  END;

                {Copy data from A and B to C}
                FOR CurField:=0 TO dfC^.FieldList.Count-1 DO
                  BEGIN
                    CField:=PeField(dfC^.FieldList.Items[CurField]);
                    IF CField^.Felttype<>ftQuestion THEN
                      BEGIN
                        //AField:=GetField(CField^.FName,dfA);
                        //BField:=GetField(CField^.FName,dfB);
                        n:=LOWORD(CField^.FieldN);
                        IF n=$FFFF THEN AField:=NIL ELSE AField:=PeField(dfA^.FieldList.Items[n]);
                        n:=HIWORD(CField^.FieldN);
                        IF n=$FFFF THEN BField:=NIL ELSE BField:=PeField(dfB^.FieldList.Items[n]);
                        IF (AField<>NIL) AND (BField<>NIL)
                        AND (MergeForm.ComDataRadio.ItemIndex=1)
                        AND (NOT IsIndexField(AField^.FName)) THEN AField:=NIL;  //Common field found - ComDataRadio decides where to take data from
                        IF AField<>NIL THEN
                          BEGIN
                            IF AField^.Felttype<>ftQuestion THEN
                              BEGIN
                                {Field exists in datafile A => copy data from datafile A}
                                IF (AField^.Felttype=ftFloat) AND (trim(AField^.FFieldText)<>'') THEN
                                  BEGIN
                                    tmpValue:=eStrToFloat(AField^.FFieldText);
                                    Str(tmpValue:AField^.FLength:AField^.FNumDecimals,tmpS);
                                    CField^.FFieldText:=tmpS;
                                  END  //if ftFloat
                                ELSE CField^.FFieldText:=trim(AField^.FFieldText);
                              END;  //if AField<>ftQuestion
                          END  //if AField<>NIL
                        ELSE
                          BEGIN
                            {Does does not exist in datafile A => copy data from datafile B}
                            {or is common field, but user selected to take data from B}
                            IF CurRecB>=1 THEN
                              BEGIN
                                {A matching record in file B was found - use it}
                                //BField:=GetField(Cfield^.FName,dfB);
                                IF BField^.Felttype<>ftQuestion THEN
                                  BEGIN
                                    IF (BField^.Felttype=ftFloat) AND (trim(BField^.FFieldText)<>'') THEN
                                      BEGIN
                                        tmpValue:=eStrToFloat(BField^.FFieldText);
                                        Str(tmpValue:BField^.FLength:BField^.FNumDecimals,tmpS);
                                        CField^.FFieldText:=tmpS;
                                      END  //if ftFloat
                                    ELSE CField^.FFieldText:=trim(BField^.FFieldText);
                                  END;  //if BField<>ftQuestion
                              END;  //if CurRecB>=1
                          END;  //if copy data from B
                      END;  //if CField<>ftQuestion
                  END;  //for CurField
                WriteNextRecord(dfC,CFile);
              END;  //if not dfA^.CurRecDeleted
          END;  //while CurRecA<dfA^.NumRecords

        {Copy non-copied records from B to C - if user has choosen to do that}
        IF MergeForm.MergeAllCheck.Checked THEN
          BEGIN
            FOR CurRecB:=1 TO dfB^.NumRecords DO
              BEGIN
              IF ProgressStep(TotalNumRecords,CurRecB) THEN
                BEGIN
                  ProgressForm.pBar.Position:=CurRecB+dfA^.NumRecords;
                  ProgressForm.pLabel.Caption:=Format(Lang(24030),[CurRecB+dfA^.NumRecords,TotalNumRecords]);  //'Examining record %d of %d'
                  Application.ProcessMessages;
                  IF UserAborts THEN
                    BEGIN
                      IF eDlg(Lang(24032),mtConfirmation,[mbYes,mbNo],0)=mrYes THEN Exit   //'Abort merge datafiles?'
                      ELSE UserAborts:=False;
                    END;
                END;
                BIndex.Position:=30*(CurRecB-1)*NumIndexFields;
                BIndex.Read(buff,1);
                IF Buff[0]<>#255 THEN
                  BEGIN
                    eReadOnlyRecord(dfB,BFile,CurRecB);
                    IF NOT dfB^.CurRecDeleted THEN
                      BEGIN
                        {CurRecB is not copied and is not deleted => copy record to C}
                        {Reset record in C}
                        FOR n:=0 TO dfC^.FieldList.Count-1 DO
                          IF PeField(dfC^.FieldList.Items[n])^.Felttype<>ftQuestion
                          THEN PeField(dfC^.FieldList.Items[n])^.FFieldText:='';
                        FOR CurField:=0 TO dfB^.FieldList.Count-1 DO
                          BEGIN
                            BField:=PeField(dfB^.FieldList.Items[CurField]);
                            AField:=GetField(BField^.FName,dfA);
                            IF BField^.Felttype<>ftQuestion THEN
                              BEGIN
                                IF (AField=NIL) OR (MergeForm.ComDataRadio.ItemIndex=1)
                                OR (IsIndexField(BField^.FName)) THEN
                                  BEGIN
                                    {field is unique to B or user selected that common fields' data are taken from B}
                                    CField:=GetField(BField^.FName,dfC);
                                    IF (BField^.Felttype=ftFloat) AND (trim(BField^.FFieldText)<>'') THEN
                                      BEGIN
                                        tmpValue:=eStrToFloat(BField^.FFieldText);
                                        Str(tmpValue:BField^.FLength:BField^.FNumDecimals,tmpS);
                                        CField^.FFieldText:=tmpS;
                                      END  //if ftFloat
                                    ELSE CField^.FFieldText:=trim(BField^.FFieldText);
                                  END; //if copy data
                              END;  //if not ftQuestion
                          END;  //for Curfield
                        WriteNextRecord(dfC,CFile);
                      END;  //if Not deleted
                  END; //if not copied
              END;  //for CurRecB
          END;  //if copy non-copied records from B to C

      END;  //if do a merge

    tmpS:=Lang(24034)+#13#13;  //'Files:~%s (%d records, %d fields)~%s (%d records, %d fields)'
    IF DoAppend THEN tmpS:=tmpS+Lang(24036) ELSE tmpS:=tmpS+Lang(24038);   //'Appended '  'Merged '
    tmpS:=tmpS+' '+Lang(24040);   //'and saved as:~%s (%d records, %d fields)'
    s:=Format(tmpS,[dfA^.RECFilename,dfA^.NumRecords,dfA^.NumFields,
                    dfB^.RECFilename,dfB^.NumRecords,dfB^.NumFields,
                    dfC^.RECFilename,dfC^.NumRecords,dfC^.NumFields]);
    IF MergeForm.ComDataRadio.ItemIndex=0
    THEN s:=s+#13#13+Format(Lang(24042),['A'])   //'Data in common fields (except key fields) are taken from file %s'
    ELSE s:=s+#13#13+Format(Lang(24042),['B']);   //'Data in common fields (except key fields) are taken from file %s'
    IF FileExists(changefileExt(dfC^.RECFilename,'.not'))
    THEN DeleteFile(ChangeFileExt(dfC^.RECFilename,'.not'));
    AddToNotesfile(dfC,s);
    s:=s+#13#13+Format(Lang(24044),[ChangeFileExt(dfC^.RECFilename,'.not')]);  //'This resumé is added to the notesfile~%s'
    eDlg(s,mtInformation,[mbOK],0);
    AddToRecentFiles(ChangeFileExt(dfC^.RECFilename,'.not'));
    AddToRecentFiles(dfC^.RECFilename);
  FINALLY
    EnableTaskWindows(WindowList);
    ProgressForm.Free;
    {$I-}
    CloseFile(CFile);
    IF NOT DoAppend THEN
      BEGIN
        CloseFile(AFile);
        CloseFile(BFile);
      END;
    n:=IOResult;
    {$I+}
    IF UserAborts THEN DeleteFile(dfC^.RECFilename);
    FOR n:=0 TO dfC^.FieldList.Count-1 DO
      BEGIN
        CField:=PeField(dfC^.FieldList.Items[n]);
        ResetCheckProperties(CField);
      END;
    DisposeDatafilePointer(dfA);
    DisposeDatafilePointer(dfB);
    DisposeDatafilePointer(dfC);
    IF Assigned(AIndex) THEN AIndex.Free;
    IF Assigned(BIndex) THEN BIndex.Free;
    IF Assigned(MergeForm) THEN MergeForm.Free;
  END;  //try..finally
END;





procedure TMergeForm.FindABtnClick(Sender: TObject);
begin
  MainForm.OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  IF trim(ResultFileEdit.Text)='' THEN
    BEGIN
      MainForm.OpenDialog1.InitialDir:=ExtractFiledir(FilenameA.Caption);
      MainForm.OpenDialog1.Filename:='';
    END
  ELSE
    BEGIN
      MainForm.OpenDialog1.InitialDir:=ExtractFileDir(ResultfileEdit.Text);
      MainForm.OpenDialog1.Filename:=ResultFileEdit.Text
    END;
  MainForm.OpenDialog1.Options:=MainForm.Opendialog1.Options-[ofFileMustExist];
  IF MainForm.OpenDialog1.Execute THEN ResultFileEdit.Text:=MainForm.OpenDialog1.Filename;
end;


procedure TMergeForm.FieldSelectList1ClickCheck(Sender: TObject);
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

procedure TMergeForm.FieldSelectList1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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

end.
