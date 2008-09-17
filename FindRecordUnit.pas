unit FindRecordUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, EpiTypes, Grids;

type
  TFindRecordForm = class(TForm)
    FindTextEdit1: TEdit;
    OptionsGroup: TGroupBox;
    CaseCheck: TCheckBox;
    WordsOnlyCheck: TCheckBox;
    ScopeRadioBox: TRadioGroup;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    SearchStyleCombo1: TComboBox;
    IgnoreDeletedCheck: TCheckBox;
    FieldNameCombo1: TComboBox;
    FieldnameCombo2: TComboBox;
    SearchStyleCombo2: TComboBox;
    FindTextEdit2: TEdit;
    FieldnameCombo3: TComboBox;
    SearchStyleCombo3: TComboBox;
    FindTextEdit3: TEdit;
    ResetBtn: TBitBtn;
    AndButton1: TSpeedButton;
    AndButton2: TSpeedButton;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure AndButton1Click(Sender: TObject);
    procedure AndButton2Click(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FindRecordForm: TFindRecordForm;

  Procedure pFindAgain(VAR df:PDatafileInfo);
  Procedure pDoFindRecord(VAR df:PDatafileInfo);
  Procedure FindByExample(VAR df:PDatafileInfo; FindAgain:Boolean);
  Procedure QuitFindByExample(VAR df:PDatafileInfo);
  Procedure ResetFindRecOptions;

implementation

USES
  MainUnit, FileUnit, DataFormUnit, ProgressUnit;

{$R *.DFM}

CONST
  MaxFindExCrites=10;

TYPE
  TSearchStyle=(ssEquals,ssBeginsWith,ssContains);
  TScopeStyle=(ssForward,ssBackWard,ssAll);
  TFindRecOptions=Record
    FieldNo1:           Integer;
    NameListNo1:        Integer;
    SearchStyle1:       TSearchStyle;
    FindText1:          String;

    FieldNo2:           Integer;
    NameListNo2:        Integer;
    SearchStyle2:       TSearchStyle;
    FindText2:          String;

    FieldNo3:           Integer;
    NameListNo3:        Integer;
    SearchStyle3:       TSearchStyle;
    FindText3:          String;

    CaseSensitive:      Boolean;
    WholeWordsOnly:     Boolean;
    IgnoreDeleted:      Boolean;
    Scope:              TScopeStyle;
    StartRecord:        LongInt;
    CallingField:       Integer;

    CanUseIndex:        Boolean;
    FoundRecs:          TStringList;
    CurFoundRec:        Integer;
  END;

  TFindOperators = (opNone,opEq,opNEq,opGT,opLT,opBW,opEW,opCON);

  TCrites=Record
    Fieldno: Integer;
    Opr: TFindOperators;
    SearchText: String;
    SearchValue: Double;
  END;

  TFindByExOptions=Record
    StartRecord:         LongInt;
    BckColor:            TColor;
    NumCrites:           Integer;
    Crites:              Array[1..MaxFindExCrites] of TCrites;
    CanUseIndex:         Boolean;
    FoundRecs:           TStringList;
    Scope:               TScopeStyle;
    CurFoundRec:         Integer;
    IgnoreDeleted:       Boolean;
  END;

VAR
  FindRecOptions: TFindRecOptions;
  FindByExOptions: TFindByExOptions;

Procedure pFindAgain(VAR df:PDatafileInfo);
VAR
  fCurRec: Integer;
  fStop,found:Boolean;
  TestText1, TestText2,TestText3,tmpFindText1, tmpFindText2, tmpFindText3:String;
  WindowList:Pointer;
  AField1,AField2,AField3: PeField;
  roDat: TextFile;
//  CanUseIndex: Boolean;
  pStep:Integer;
BEGIN
  TRY
    IF (FindRecOptions.FieldNo1<>-1) AND (trim(FindRecOptions.FindText1)<>'') THEN
      BEGIN
        ProgressForm:=TProgressForm.Create(MainForm);
        ProgressForm.Caption:=Lang(22400);  //'Searching record'
        ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
        ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
        IF df^.NumRecords>60 THEN pStep:=df^.NumRecords DIV 20 ELSE pStep:=20;
        ProgressForm.pBar.Step:=pStep;
        WindowList:=DisableTaskWindows(ProgressForm.Handle);
        WITH FindRecOptions DO
          BEGIN
            AField1:=PeField(df^.FieldList.Items[FieldNo1]);
            tmpFindText1:=trim(FindText1);

            IF (FieldNo2<>-1) AND (trim(FindText2)<>'')
            THEN AField2:=PeField(df^.FieldList.Items[FieldNo2]) ELSE AField2:=NIL;
            tmpFindText2:=trim(FindText2);

            IF (FieldNo3<>-1) AND (trim(FindText3)<>'') AND (AField2<>NIL)
            THEN AField3:=PeField(df^.FieldList.Items[FieldNo3]) ELSE AField3:=NIL;
            tmpFindText2:=trim(FindText2);

            StartRecord:=df^.CurRecord;
            fCurRec:=StartRecord;
            fStop:=False;
            CASE Scope OF
              ssForward: BEGIN
                INC(fCurRec);
                IF fCurRec>df^.NumRecords THEN fStop:=True;
                ProgressForm.pBar.Max:=df^.NumRecords-fCurRec;
                END;
              ssBackWard: BEGIN
                DEC(fCurRec);
                IF fCurRec=0 THEN fStop:=True;
                ProgressForm.pBar.Max:=fCurRec;
                END;
              ssAll: BEGIN
                INC(fCurRec);
                IF fCurRec>df^.NumRecords THEN fCurRec:=1;
                ProgressForm.pBar.Max:=df^.NumRecords;
                END;
            END;  //case Scope
//            ProgressForm.pBar.Step:=20;
            IF fStop THEN
              BEGIN
                eDlg(Lang(22402),mtInformation,[mbOK],0);  //'Search string(s) not found.'
                Exit;
              END;

            IF NOT CaseSensitive THEN
              BEGIN
                tmpFindText1:=AnsiUpperCase(tmpFindText1);
                tmpFindText2:=AnsiUpperCase(tmpFindText2);
                tmpFindText3:=AnsiUpperCase(tmpFindText3);
              END;
            IF WholeWordsOnly THEN
              BEGIN
                tmpFindText1:=' '+tmpFindText1+' ';
                tmpFindText2:=' '+tmpFindText2+' ';
                tmpFindText3:=' '+tmpFindText3+' ';
              END;

          END;  //with

        {Prepare datafile for readonly}
        //CloseFile(df^.DatFile);
        df^.Datfile.Free;   //§§§
        df^.Datfile:=NIL;  //§§§
        AssignFile(roDat,df^.RECFilename);
        Reset(roDat);

        WITH FindRecOptions DO
          BEGIN
            IF AField1^.FIndex=0 THEN CanUseIndex:=False ELSE CanUseIndex:=True;
            IF AField2<>NIL THEN IF AField2^.FIndex=0 THEN CanUseIndex:=False;
            IF AField3<>NIL THEN IF AField3^.FIndex=0 THEN CanUseIndex:=False;
            IF NOT CanUseIndex THEN eReadOnlyRecord(df,roDat,fCurRec);
            CurFoundRec:=-1;
          END;
        Found:=False;
        fStop:=False;
        UserAborts:=False;
        ProgressForm.Show;


        IF (FindRecOptions.CanUseIndex) AND (FindRecOptions.FoundRecs<>NIL) THEN
          BEGIN
            //search using index
            ProgressForm.pBar.Position:=ProgressForm.pBar.Max;
            IF FindRecOptions.FoundRecs.Count=0 THEN
              BEGIN
                fStop:=True;
                Found:=False;
              END
            ELSE
              BEGIN
                //One or more records were found
                //Find relevant entry in FoundRecs
                WITH FindRecOptions DO
                  BEGIN
                    CurFoundRec:=0;
                    Found:=False;
                    CASE Scope OF
                      ssForward:  CurFoundRec:=0;
                      ssBackWard: CurFoundRec:=FoundRecs.Count-1;
                      ssAll:      CurFoundRec:=0;
                    END;  //case
                    IF Scope=ssBackWard THEN
                      BEGIN
                        REPEAT
                          IF StrToInt(FoundRecs[FindRecOptions.CurFoundRec])<fCurRec THEN Found:=True
                          ELSE DEC(CurFoundRec);
                        UNTIL (CurFoundRec<0) OR (Found);
                      END
                    ELSE
                      BEGIN
                        REPEAT
                          IF StrToInt(FoundRecs[CurFoundRec])>fCurRec THEN Found:=True
                          ELSE INC(CurFoundRec);
                        UNTIL (CurFoundRec>FoundRecs.Count-1) OR (Found);
                        IF (NOT Found) AND (FindRecOptions.Scope=ssAll) THEN
                          BEGIN
                            Found:=True;
                            FindRecOptions.CurFoundRec:=0;
                          END;
                      END;
                  END;  //with
                IF NOT Found THEN fStop:=True
                ELSE
                  BEGIN
                    //There is a record with a higher recnumber than fCurRec (ssForward) or lower (ssBackWard)
                    Found:=True;
                    REPEAT
                      eReadOnlyRecord(df,roDat,StrToInt(FindRecOptions.FoundRecs[FindRecOptions.CurFoundRec]));
                      IF (FindRecOptions.IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;
                      IF NOT Found THEN
                        CASE FindRecOptions.Scope OF
                          ssForward,ssAll:  INC(FindRecOptions.CurFoundRec);
                          ssBackWard:       DEC(FindRecOptions.CurFoundRec);
                        END;  //case
                    UNTIL (FindRecOptions.CurFoundRec>FindRecOptions.FoundRecs.Count-1)
                      OR  (FindRecOptions.CurFoundRec<0)
                      OR  (Found);
                    IF NOT Found THEN fStop:=True
                    ELSE fCurRec:=StrToInt(FindRecOptions.FoundRecs[FindRecOptions.CurFoundRec]);
                  END;   //if there is a relevant entry in FoundRecs
              END;  //if one or more recs were found
          END  //search using index
        ELSE
          BEGIN
            //Search without using index
            REPEAT    //until fStop or Found
              {compare relevant field with FindText}
              WITH FindRecOptions DO
                BEGIN
                  IF CanUseIndex THEN
                    BEGIN
{                      TestText1:=df^.Index[AField1^.FIndex].Strings[df^.Index[AField1^.FIndex].IndexOfObject(TObject(fCurRec))];
                      IF AField2<>NIL THEN TestText2:=df^.Index[AField2^.FIndex].Strings[df^.Index[AField2^.FIndex].IndexOfObject(TObject(fCurRec))];
                      IF AField3<>NIL THEN TestText3:=df^.Index[AField3^.FIndex].Strings[df^.Index[AField3^.FIndex].IndexOfObject(TObject(fCurRec))];
}
                      TestText1:=ReadFromIndex(df,AField1^.FIndex,fCurRec);
                      IF AField2<>NIL THEN TestText2:=ReadFromIndex(df,AField2^.FIndex,fCurRec);
                      IF AField3<>NIL THEN TestText3:=ReadFromIndex(df,AField3^.FIndex,fCurRec);
                    END
                  ELSE
                    BEGIN
                      TestText1:=AField1^.FFieldText;
                      IF AField2<>NIL THEN TestText2:=AField2^.FFieldText ELSE TestText2:='';
                      IF AField3<>NIL THEN TestText3:=AField3^.FFieldText ELSE TestText3:='';
                    END;

                  TestText1:=trim(TestText1);
                  IF AField2<>NIL THEN TestText2:=trim(TestText2);
                  IF AField3<>NIL THEN TestText3:=trim(TestText3);

                  IF NOT CaseSensitive THEN
                    BEGIN
                      TestText1:=AnsiUpperCase(TestText1);
                      IF AField2<>NIL THEN TestText2:=AnsiUpperCase(TestText2);
                      IF AField3<>NIL THEN TestText3:=AnsiUpperCase(TestText3);
                    END;
                  IF WholeWordsOnly THEN
                    BEGIN
                      TestText1:=' '+TestText1+' ';
                      IF AField2<>NIL THEN TestText2:=' '+TestText2+' ';
                      IF AField3<>NIL THEN TestText3:=' '+TestText3+' ';
                    END;

                  CASE SearchStyle1 OF
                    ssEquals:       Found:=(TestText1=tmpFindText1) OR ( (trim(TestText1)='') AND (trim(tmpFindText1)='.') );
                    ssBeginsWith:   Found:=(Copy(TestText1,1,Length(tmpFindText1))=tmpFindText1);
                    ssContains:     Found:=(Pos(tmpFindText1,TestText1)<>0);
                  END;
                  IF AField2<>NIL THEN
                    CASE SearchStyle2 OF
                      ssEquals:     Found:=Found AND ( (TestText2=tmpFindText2) OR ( (trim(TestText2)='') AND (trim(tmpFindText2)='.') ) );
                      ssBeginsWith: Found:=Found AND (Copy(TestText2,1,Length(tmpFindText2))=tmpFindText2);
                      ssContains:   Found:=Found AND (Pos(tmpFindText2,TestText2)<>0);
                    END;
                  IF AField3<>NIL THEN
                    CASE SearchStyle3 OF
                      ssEquals:     Found:=Found AND ( (TestText3=tmpFindText3) OR ( (trim(TestText3)='') AND (trim(tmpFindText3)='.') ) );
                      ssBeginsWith: Found:=Found AND (Copy(TestText3,1,Length(tmpFindText3))=tmpFindText3);
                      ssContains:   Found:=Found AND (Pos(tmpFindText3,TestText3)<>0);
                    END;

                  IF (Found) AND (NOT CanUseIndex) THEN eReadOnlyRecord(df,roDat,fCurRec);  //to make check of DEL possible
                  IF (IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;
                  IF NOT Found THEN
                    BEGIN
                      CASE Scope OF
                        ssForward: BEGIN
                          INC(fCurRec);
                          IF fCurRec>df^.NumRecords THEN fStop:=True;
                          END;
                        ssBackWard: BEGIN
                          DEC(fCurRec);
                          IF fCurRec=0 THEN fStop:=True;
                          END;
                        ssAll: BEGIN
                          INC(fCurRec);
                          IF fCurRec>df^.NumRecords THEN fCurRec:=1;
                          IF fCurRec=StartRecord THEN fStop:=True;
                          END;
                      END;  //case Scope
                      IF (NOT fStop) AND (NOT CanUseIndex) THEN eReadOnlyRecord(df,roDat,fCurRec);
                      IF (fCurRec MOD 20)=0 THEN
                        BEGIN
                          ProgressForm.pBar.StepIt;
                          ProgressForm.pLabel.Caption:=Format(Lang(22404),[fCurRec]);  //'Searching in record %d'
                          Application.ProcessMessages;
                        END;
                    END;  //if not found
                END;  //with
            UNTIL (Found) or (fStop) or (UserAborts);
          END;  //if search witout index

        EnableTaskWindows(WindowList);
        ProgressForm.Free;

        {Leave datafile as normal file}
        CloseFile(roDat);
        //Assign(df^.Datfile,df^.RECFilename);
        //Reset(df^.Datfile);
        df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);   //§§§

        IF Found THEN
          BEGIN
            peReadRecord(df,fCurRec);
            IF TEntryField(AField1^.EntryField).CanFocus
            THEN TEntryField(Afield1^.EntryField).SetFocus;
          END;

        IF fStop THEN
          BEGIN
            peReadRecord(df,FindRecOptions.StartRecord);
            eDlg(Lang(22402),mtInformation,[mbOK],0);  //'Search string(s) not found.'
          END;
        IF UserAborts THEN peReadRecord(df,FindRecOptions.StartRecord);
      END;   //if FindText<>''

  EXCEPT
    ErrorMsg(Lang(22406));  //'Error during search. Search terminates.'
  END;  //try..finally}
END;   //procedure pFindAgain;



Procedure pDoFindRecord(VAR df:PDatafileInfo);
VAR
  fN,n,fCurRec,SelField: Integer;
  fStop,found:Boolean;
  TestText1,TestText2,TestText3,tmpFindText1,tmpFindText2,tmpFindText3:ShortString;
  WindowList:Pointer;
  AField1,AField2,AField3, BField: PeField;
  roDat: TextFile;
//  starttid,endtid:tDatetime;
//  Hour,Min,Sec,MSec: Word;
  pStep:Integer;
BEGIN
  {Find fieldnumber of the current entryfield}
  fN:=df^.FieldList.IndexOf(TEntryField(df^.LatestActiveControl).dfField);
  IF fN=-1 THEN Exit;
  AField1:=PeField(df^.FieldList.Items[fN]);
  IF df^.FieldNames=NIL THEN
    BEGIN
      {List of Fieldnames is not created - make it}
      df^.FieldNames:=TStringList.Create;
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          BField:=PeField(df^.FieldList.Items[n]);
          IF BField^.FeltType<>ftQuestion THEN
            BEGIN
              df^.FieldNames.AddObject(BField^.FName,TObject(BField));
              IF fN=n THEN SelField:=df^.FieldNames.Count-1;
            END;
        END;
    END  //if FieldNames=NIL
  ELSE SelField:=df^.FieldNames.IndexOfObject(TObject(AField1));
  FindRecOptions.CallingField:=SelField;

  TRY
    FindRecordForm:=TFindRecordForm.Create(MainForm);
    WITH FindRecordForm DO
      BEGIN
        FieldnameCombo1.Items.Assign(df^.Fieldnames);
        FieldnameCombo2.Items.Assign(df^.Fieldnames);
        FieldnameCombo3.Items.Assign(df^.Fieldnames);

        {Is there is previous search in FindRecOptions?}
        IF (trim(FindRecOptions.FindText1)<>'') AND (FindRecOptions.NameListNo1<>-1) THEN
          BEGIN
            FieldnameCombo1.ItemIndex:=FindRecOptions.NameListNo1;
            SearchStyleCombo1.ItemIndex:=ORD(FindrecOptions.SearchStyle1);
            FindTextEdit1.Text:=FindRecOptions.Findtext1;
            IF (trim(FindRecOptions.FindText2)<>'') AND (FindRecOptions.NameListNo2<>-1) THEN
              BEGIN
                FieldnameCombo2.ItemIndex:=FindRecOptions.NameListNo2;
                SearchStyleCombo2.ItemIndex:=ORD(FindrecOptions.SearchStyle2);
                FindTextEdit2.Text:=FindRecOptions.Findtext2;
                IF (trim(FindRecOptions.Findtext3)<>'') AND (FindRecOptions.NameListNo3<>-1) THEN
                  BEGIN
                    FieldnameCombo3.ItemIndex:=FindRecOptions.NameListNo3;
                    SearchStyleCombo3.ItemIndex:=ORD(FindrecOptions.SearchStyle3);
                    FindTextEdit3.Text:=FindRecOptions.Findtext3;
                  END;
              END;
          END
        ELSE
          BEGIN
            FieldnameCombo1.ItemIndex:=FindRecOptions.CallingField;
            FieldnameCombo2.ItemIndex:=-1;
            FieldnameCombo3.ItemIndex:=-1;
            SearchStyleCombo1.ItemIndex:=0;
            SearchStyleCombo2.ItemIndex:=0;
            SearchStyleCombo3.ItemIndex:=0;
            FindTextEdit1.Text:='';
            FindTextEdit2.Text:='';
            FindtextEdit3.Text:='';
          END;
      END;  //with

    IF FindRecordForm.ShowModal=mrOK THEN
      BEGIN
        IF trim(FindRecordForm.FindTextEdit1.Text)<>'' THEN
          BEGIN
            {Prepare datafile for readonly}
            df^.Datfile.Free;
            df^.Datfile:=NIL;
            AssignFile(roDat,df^.RECFilename);
            Reset(roDat);

            ProgressForm:=TProgressForm.Create(MainForm);
            ProgressForm.Caption:=Lang(22400);   //'Searching record'
            ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
            ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
            IF df^.NumRecords>60 THEN pStep:=df^.NumRecords DIV 20 ELSE pStep:=20;
            ProgressForm.pBar.Step:=pStep;
            WindowList:=DisableTaskWindows(ProgressForm.Handle);

            SelField:=FindRecordForm.FieldnameCombo1.ItemIndex;
            AField1:=PeField(FindRecordForm.FieldnameCombo1.Items.Objects[SelField]);

            {Test if field2 is used}
            SelField:=FindRecordForm.FieldnameCombo2.ItemIndex;
            IF (SelField=-1) OR (trim(FindRecordForm.FindTextEdit2.Text)='')
            OR (FindRecordForm.FieldnameCombo2.Visible=False) THEN AField2:=NIL
            ELSE AField2:=PeField(FindRecordForm.FieldnameCombo2.Items.Objects[SelField]);

            {Test if field3 is used}
            SelField:=FindRecordForm.FieldnameCombo3.ItemIndex;
            IF (SelField=-1) OR (trim(FindRecordForm.FindTextEdit3.Text)='') OR (AField2=NIL)
            OR (FindRecordForm.FieldnameCombo3.Visible=False) THEN AField3:=NIL
            ELSE AField3:=PeField(FindRecordForm.FieldnameCombo3.Items.Objects[SelField]);

            WITH FindRecOptions DO
              BEGIN
                Case FindRecordForm.SearchStyleCombo1.ItemIndex OF
                  0: SearchStyle1:=ssEquals;
                  1: SearchStyle1:=ssBeginsWith;
                  2: SearchStyle1:=ssContains;
                END;
                CASE FindRecordForm.SearchStyleCombo2.ItemIndex OF
                  0: SearchStyle2:=ssEquals;
                  1: SearchStyle2:=ssBeginsWith;
                  2: SearchStyle2:=ssContains;
                END;
                CASE FindRecordForm.SearchStyleCombo3.ItemIndex OF
                  0: SearchStyle3:=ssEquals;
                  1: SearchStyle3:=ssBeginsWith;
                  2: SearchStyle3:=ssContains;
                END;
                NameListNo1:=FindrecordForm.FieldNameCombo1.ItemIndex;
                NameListNo2:=FindrecordForm.FieldNameCombo2.ItemIndex;
                NameListNo3:=FindrecordForm.FieldNameCombo3.ItemIndex;
                FindText1:=trim(FindRecordForm.FindTextEdit1.Text);
                FindText2:=trim(FindRecordForm.FindTextEdit2.Text);
                FindText3:=trim(FindRecordForm.FindTextEdit3.Text);
                tmpFindText1:=FindText1;
                tmpFindText2:=FindText2;
                tmpFindText3:=FindText3;
                CaseSensitive:=FindRecordForm.CaseCheck.Checked;
                WholeWordsOnly:=FindRecordForm.WordsOnlyCheck.Checked;
                IgnoreDeleted:=FindRecordForm.IgnoreDeletedCheck.Checked;
                CASE FindRecordForm.ScopeRadioBox.ItemIndex OF
                  0: Scope:=ssForward;
                  1: Scope:=ssBackward;
                  2: Scope:=ssAll;
                END;
                StartRecord:=df^.CurRecord;
                IF StartRecord=NewRecord THEN ProgressForm.pBar.Max:=df^.NumRecords
                ELSE
                  CASE Scope OF
                    ssForward: ProgressForm.pBar.Max:=df^.NumRecords-StartRecord;
                    ssBackWard: ProgressForm.pBar.Max:=StartRecord;
                    ssAll: ProgressForm.pBar.Max:=df^.NumRecords;
                  END;  //case Scope
                FieldNo1:=df^.FieldList.IndexOf(AField1);
                IF AField2<>NIL THEN FieldNo2:=df^.FieldList.IndexOf(AField2) ELSE FieldNo2:=-1;
                IF AField3<>NIL THEN FieldNo3:=df^.FieldList.IndexOf(AField3) ELSE FieldNo3:=-1;
                IF NOT CaseSensitive THEN
                  BEGIN
                    tmpFindText1:=AnsiUpperCase(tmpFindText1);
                    tmpFindText2:=AnsiUpperCase(tmpFindText2);
                    tmpFindText3:=AnsiUpperCase(tmpFindText3);
                  END;
                IF WholeWordsOnly THEN
                  BEGIN
                    tmpFindText1:=' '+tmpFindText1+' ';
                    tmpFindText2:=' '+tmpFindText2+' ';
                    tmpFindText3:=' '+tmpFindText3+' ';
                  END;
              END;  //with

            fCurRec:=df^.CurRecord;
            IF fCurRec=NewRecord THEN
              BEGIN
                CASE FindRecOptions.Scope OF
                  ssForward,ssAll: fCurRec:=1;
                  ssBackWard: fCurRec:=df^.Numrecords;
                END;
              END
            ELSE
              BEGIN
                CASE FindRecOptions.Scope OF
                  ssForward,ssAll:
                    BEGIN
                      INC(fCurRec);
                      IF fCurRec>df^.NumRecords THEN fCurrec:=1;
                    END;
                  ssBackWard:
                    BEGIN
                      DEC(fCurRec);
                      IF fCurRec<1 THEN fCurRec:=df^.NumRecords;
                    END;
                END;  //case
              END;  //else

            Found:=False;
            fStop:=False;
            UserAborts:=False;
            ProgressForm.Show;
//            Starttid:=Now;
            WITH FindRecOptions DO
              BEGIN
                IF AField1^.FIndex=0 THEN CanUseIndex:=False ELSE CanUseIndex:=True;
                IF AField2<>NIL THEN IF AField2^.FIndex=0 THEN CanUseIndex:=False;
                IF AField3<>NIL THEN IF AField3^.FIndex=0 THEN CanUseIndex:=False;
                IF Assigned(FoundRecs) THEN
                  BEGIN
                    FoundRecs.Free;
                    Foundrecs:=NIL;
                  END;
                CurFoundRec:=-1;
              END;

            IF FindRecOptions.CanUseIndex THEN
              BEGIN
                ProgressForm.pBar.Position:=ProgressForm.pBar.Max;
                FindRecOptions.FoundRecs:=TStringList.Create;
                FindRecOptions.FoundRecs.Duplicates:=dupAccept;
                //Make list of found values in TStringList:FoundRecs
                FOR n:=1 TO df^.NumRecords DO
                  BEGIN
                    Found:=False;
{                    TestText1:=Trim(Copy(df^.ComIndex[n-1],((AField1^.FIndex-1)*30)+1,30));
                    IF AField2<>NIL THEN TestText2:=trim(Copy(df^.ComIndex[n-1],((AField2^.FIndex-1)*30)+1,30));
                    IF AField3<>NIL THEN TestText3:=trim(Copy(df^.ComIndex[n-1],((AField3^.FIndex-1)*30)+1,30));
}
                    TestText1:=trim(ReadFromIndex(df,AField1^.FIndex,n));
                    IF AField2<>NIL THEN TestText2:=trim(ReadFromIndex(df,AField2^.FIndex,n));
                    IF AField3<>NIL THEN TestText3:=trim(ReadFromIndex(df,AField3^.FIndex,n));
                    IF NOT FindRecOptions.CaseSensitive THEN
                      BEGIN
                        TestText1:=AnsiUpperCase(TestText1);
                        IF AField2<>NIL THEN TestText2:=AnsiUpperCase(TestText2);
                        IF AField3<>NIL THEN TestText3:=AnsiUpperCase(TestText3);
                      END;
                    IF FindRecOptions.WholeWordsOnly THEN
                      BEGIN
                        TestText1:=' '+TestText1+' ';
                        IF AField2<>NIL THEN TestText2:=' '+TestText2+' ';
                        IF AField3<>NIL THEN TestText3:=' '+TestText3+' ';
                      END;
                    CASE FindRecOptions.SearchStyle1 OF
                      ssEquals:       Found:=(TestText1=tmpFindText1) OR ( (trim(TestText1)='') AND (trim(tmpFindText1)='.') );
                      ssBeginsWith:   Found:=(Copy(TestText1,1,Length(tmpFindText1))=tmpFindText1);
                      ssContains:     Found:=(Pos(tmpFindText1,TestText1)<>0);
                    END;
                    IF AField2<>NIL THEN
                      CASE FindRecOptions.SearchStyle2 OF
                        ssEquals:     Found:=Found AND ( (TestText2=tmpFindText2)  OR ( (trim(TestText2)='') AND (trim(tmpFindText2)='.') ) );
                        ssBeginsWith: Found:=Found AND (Copy(TestText2,1,Length(tmpFindText2))=tmpFindText2);
                        ssContains:   Found:=Found AND (Pos(tmpFindText2,TestText2)<>0);
                      END;
                    IF AField3<>NIL THEN
                      CASE FindRecOptions.SearchStyle3 OF
                        ssEquals:     Found:=Found AND ( (TestText3=tmpFindText3)  OR ( (trim(TestText3)='') AND (trim(tmpFindText3)='.') ) );
                        ssBeginsWith: Found:=Found AND (Copy(TestText3,1,Length(tmpFindText3))=tmpFindText3);
                        ssContains:   Found:=Found AND (Pos(tmpFindText3,TestText3)<>0);
                      END;
//                  IF Found THEN FindRecOptions.FoundRecs.Add(Format('%30d',[Integer(df^.ComIndex.Objects[n-1])]));
                    IF Found THEN FindRecOptions.FoundRecs.Add(Format('%30d',[n]));
                  END;  //for n
                IF FindRecOptions.FoundRecs.Count=0 THEN
                  BEGIN
                    fStop:=True;
                    Found:=False;
                  END
                ELSE
                  BEGIN
                    //One or more records were found
                    WITH FindRecOptions DO
                      BEGIN
                        FoundRecs.Sort;
                        CurFoundRec:=0;
                        Found:=False;
                        CASE Scope OF
                          ssForward:  CurFoundRec:=0;
                          ssBackWard: CurFoundRec:=FoundRecs.Count-1;
                          ssAll:      CurFoundRec:=0;
                        END;  //case Scope
                      END;  //with
                    IF FindRecOptions.Scope=ssBackWard THEN
                      BEGIN
                        REPEAT
                          IF StrToInt(FindRecOptions.FoundRecs[FindRecOptions.CurFoundRec])<fCurRec THEN Found:=True
                          ELSE DEC(FindRecOptions.CurFoundRec);
                        UNTIL (FindRecOptions.CurFoundRec<0) OR (Found);
                      END
                    ELSE
                      BEGIN
                        REPEAT
                          IF StrToInt(FindRecOptions.FoundRecs[FindRecOptions.CurFoundRec])>=fCurRec THEN Found:=True
                          ELSE INC(FindRecOptions.CurFoundRec);
                        UNTIL (FindRecOptions.CurFoundRec>FindRecOptions.FoundRecs.Count-1) OR (Found);
                        IF (NOT Found) AND (FindRecOptions.Scope=ssAll) THEN
                          BEGIN
                            Found:=True;
                            FindRecOptions.CurFoundRec:=0;
                          END;
                      END;
                    IF NOT Found THEN fStop:=True
                    ELSE
                      BEGIN
                        //There is a record with a higher recnumber than fCurRec (ssForward) or lower (ssBackWard)
                        Found:=True;
                        REPEAT
                          eReadOnlyRecord(df,roDat,StrToInt(FindRecOptions.FoundRecs[FindRecOptions.CurFoundRec]));
                          IF (FindRecOptions.IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;
                          IF NOT Found THEN
                            CASE FindRecOptions.Scope OF
                              ssForward,ssAll: INC(FindRecOptions.CurFoundRec);
                              ssBackWard:      DEC(FindRecOptions.CurFoundRec);
                            END;  //case
                        UNTIL (FindRecOptions.CurFoundRec>FindRecOptions.FoundRecs.Count-1)
                           OR (FindRecOptions.CurFoundRec<0)
                           OR (Found);
                        IF NOT Found THEN fStop:=True
                        ELSE fCurRec:=StrToInt(FindRecOptions.FoundRecs[FindRecOptions.CurFoundRec]);
                      END;
                  END;  //one or more recs were found
              END  //if canUseIndex
            ELSE
              BEGIN
                //Cannot use index
                eReadOnlyRecord(df,roDat,fCurRec);
                REPEAT    //until fStop or Found
                  {compare relevant field with FindText}
                  WITH FindRecOptions DO
                    BEGIN
                      TestText1:=trim(AField1^.FFieldText);
                      IF AField2<>NIL THEN TestText2:=trim(AField2^.FFieldText) ELSE TestText2:='';
                      IF AField3<>NIL THEN TestText3:=trim(AField3^.FFieldText) ELSE TestText3:='';
                      IF NOT CaseSensitive THEN
                        BEGIN
                          TestText1:=AnsiUpperCase(TestText1);
                          IF AField2<>NIL THEN TestText2:=AnsiUpperCase(TestText2);
                          IF AField3<>NIL THEN TestText3:=AnsiUpperCase(TestText3);
                        END;
                      IF WholeWordsOnly THEN
                        BEGIN
                          TestText1:=' '+TestText1+' ';
                          IF AField2<>NIL THEN TestText2:=' '+TestText2+' ';
                          IF AField3<>NIL THEN TestText3:=' '+TestText3+' ';
                        END;
                      CASE SearchStyle1 OF
                        ssEquals:       Found:=(TestText1=tmpFindText1) OR ( (trim(TestText1)='') AND (trim(tmpFindText1)='.') );
                        ssBeginsWith:   Found:=(Copy(TestText1,1,Length(tmpFindText1))=tmpFindText1);
                        ssContains:     Found:=(Pos(tmpFindText1,TestText1)<>0);
                      END;
                      IF AField2<>NIL THEN
                        CASE SearchStyle2 OF
                          ssEquals:     Found:=Found AND ( (TestText2=tmpFindText2)  OR ( (trim(TestText2)='') AND (trim(tmpFindText2)='.') ) );
                          ssBeginsWith: Found:=Found AND (Copy(TestText2,1,Length(tmpFindText2))=tmpFindText2);
                          ssContains:   Found:=Found AND (Pos(tmpFindText2,TestText2)<>0);
                        END;
                      IF AField3<>NIL THEN
                        CASE SearchStyle3 OF
                          ssEquals:     Found:=Found AND ( (TestText3=tmpFindText3)  OR ( (trim(TestText3)='') AND (trim(tmpFindText3)='.') ) );
                          ssBeginsWith: Found:=Found AND (Copy(TestText3,1,Length(tmpFindText3))=tmpFindText3);
                          ssContains:   Found:=Found AND (Pos(tmpFindText3,TestText3)<>0);
                        END;
                      IF (IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;

                      IF NOT Found THEN
                        BEGIN
                          CASE Scope OF
                            ssForward: BEGIN
                              IF fCurRec=NewRecord THEN fCurRec:=1 ELSE INC(fCurRec);
                              IF fCurRec>df^.NumRecords THEN fStop:=True;
                              END;
                            ssBackWard: BEGIN
                              IF fCurRec=NewRecord THEN fCurRec:=df^.NumRecords
                              ELSE DEC(fCurRec);
                              IF fCurRec=0 THEN fStop:=True;
                              END;
                            ssAll: BEGIN
                              IF fCurRec=NewRecord THEN fCurRec:=1 ELSE INC(fCurRec);
                              IF fCurRec>df^.NumRecords THEN
                                BEGIN
                                  fCurRec:=1;
                                  IF StartRecord=NewRecord THEN fStop:=True;
                                END;
                              IF fCurRec=StartRecord THEN fStop:=True;
                              END;
                          END;  //case Scope
                          IF (NOT fStop) AND (NOT CanUseIndex) THEN eReadOnlyRecord(df,roDat,fCurRec);
                          IF (fCurRec MOD pStep)=0 THEN
                            BEGIN
                              ProgressForm.pBar.StepIt;
                              ProgressForm.pLabel.Caption:=Format(Lang(22404),[fCurRec]);  //'Searching in record %d'
                              Application.ProcessMessages;
                            END;
                        END;  //if not found
                    END;  //with
                UNTIL (Found) or (fStop) or (UserAborts);
              END;  //if not canUseIndex

//            EndTid:=Now;
            EnableTaskWindows(WindowList);
            ProgressForm.Free;

            {Leave datafile as normal file}
            CloseFile(roDat);
            //Assign(df^.Datfile,df^.RECFilename);
            //Reset(df^.Datfile);
            df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);  //§§§

            IF Found THEN
              BEGIN
                peReadRecord(df,fCurRec);
                IF TEntryField(AField1^.EntryField).CanFocus
                THEN TEntryField(Afield1^.EntryField).SetFocus;
              END;

            IF fStop THEN
              BEGIN
                IF FindRecOptions.StartRecord=NewRecord THEN peNewRecord(df)
                ELSE peReadRecord(df,FindRecOptions.StartRecord);
                eDlg(Lang(22402),mtInformation,[mbOK],0);  //'Search string(s) not found.'
              END;
            IF UserAborts THEN peReadRecord(df,FindRecOptions.StartRecord);
          END;   //if FindText<>''
      END;  //if FindRecordForm=mrOK
  FINALLY
    FindRecordForm.Free;
  END;  //try..finally
//  DecodeTime(EndTid-StartTid,Hour,Min,Sec,MSec);
//  ShowMessage(FloatToStr(Int(Sec)+(Int(MSec)/1000)));
END;   //procedure pDoFindRecord;

Procedure ResetFindExOptions;
VAR
  n:Integer;
BEGIN
  WITH FindByExOptions DO
    BEGIN
      StartRecord:=-1;
      NumCrites:=0;
      CanUseIndex:=False;
      IF Assigned(FoundRecs) THEN FoundRecs.Free;
      FoundRecs:=NIL;
      Scope:=ssAll;
      CurFoundRec:=-1;
      IgnoreDeleted:=True;
      FOR n:=1 TO MaxFindExCrites DO
        BEGIN
          Crites[n].FieldNo:=-1;
          Crites[n].Opr:=opNone;
          Crites[n].SearchText:='';
        END;  //for
    END;  //with
END;  //procedure ResetFindExOptions


Procedure QuitFindByExample(VAR df: PDatafileInfo);
VAR
  n:Integer;
  ADatForm: TDataForm;
  AField: PeField;
  AEntryField: TEntryField;
BEGIN
  //set old enabled state for fields
  ADatForm:=TDataForm(df^.DatForm);
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[n]);
      IF AField^.Felttype<>ftQuestion THEN
        BEGIN
          WITH TEntryField(AField^.EntryField) DO
            BEGIN
              Enabled:=(NOT AField^.FNoEnter);
              MaxLength:=AField^.FLength;
              IF AField^.Felttype=ftCrypt THEN MaxLength:=AField^.FCryptEntryLength;
            END;
        END;
    END;
  IF FindByExOptions.StartRecord=NewRecord THEN peNewRecord(df)
  ELSE peReadRecord(df,FindByExOptions.StartRecord);
  ADatForm.ScrollBox1.Color:=FindByExOptions.BckColor;
  df^.IsFinding:=False;
  ADatForm.File1.Visible:=True;
  ADatForm.Goto1.Visible:=True;
  ADatForm.Filter1.Visible:=True;
  ADatForm.Fields1.Visible:=False;
  ADatForm.Fields1.Enabled:=False;
  //ADatForm.BorderIcons:=[biSystemMenu, biMinimize, biMaximize];
  MainForm.StatPanel6.Caption:='';
  ADatForm.Invalidate;
END;  //procedure QuitFindByExample

Procedure FindByExample(VAR df:PDatafileInfo; FindAgain:Boolean);
VAR
  n,n2,t,fCurRec:Integer;
  tmpColor: TColor;
  ADatForm: TDataForm;
  AField: PeField;
  AEntryField: TEntryField;
  s: String;
  ok,found,fStop:Boolean;
  tmpValue: Double;
  roDat: TextFile;
  pStep:Integer;
  WindowList:Pointer;

  Function DoTest(ss:String; cr:Integer; TheField:PeField):Boolean;
  VAR
    tValue: Double;
  BEGIN
    Result:=False;
    WITH FindByExOptions.Crites[cr] DO
      BEGIN
        CASE Opr OF
          opEq:  Result:=(ss=SearchText) OR ( (ss='') AND (SearchText='.') );
          opNEq: Result:=NOT ( (ss=SearchText) OR ( (ss='') AND (SearchText='.') ) );
          opBW:  Result:=(Copy(ss,1,Length(SearchText))=SearchText);
          opEW:  Result:=(Copy(ss,Length(ss)-Length(SearchText)+1,Length(SearchText))=SearchText);
          opCON: Result:=(Pos(SearchText,ss)>0);
          opGT,opLT:
            BEGIN
              IF (TheField^.Felttype in [ftInteger,ftFloat,ftIDNUM]) THEN
                BEGIN
                  IF ss='' THEN tValue:=MinNumber
                  ELSE tValue:=eStrToFloat(ss);
                  IF Opr=opGT THEN Result:=(tValue>SearchValue)
                  ELSE Result:=(tValue<SearchValue);
                END
              ELSE
                BEGIN
                  IF Opr=opGT THEN Result:=(ss>SearchText)
                  ELSE Result:=(ss<SearchText);
                END;
            END;  //case opGT, opLT
        END;  //case
    END;  //with
  END;  //function DoTest

BEGIN
  IF (FindAgain) AND (FindByExOptions.NumCrites=0) THEN FindAgain:=False;
  IF (NOT df^.IsFinding) AND (NOT FindAgain) THEN
    BEGIN
      ResetFindExOptions;
      ADatForm:=TDataForm(df^.DatForm);
      FindByExOptions.BckColor:=ADatForm.ScrollBox1.Color;
      ADatForm.ScrollBox1.Color:=clAqua;
      df^.IsFinding:=True;
      FindByExOptions.StartRecord:=df^.CurRecord;
      ADatForm.File1.Visible:=False;
      ADatForm.Goto1.Visible:=False;
      ADatForm.Filter1.Visible:=False;
      ADatForm.Fields1.Visible:=True;
      ADatForm.Fields1.Enabled:=True;
      ADatForm.TypePanel.Caption:=' Press CTRL-F to search, F10 to quit';
      MainForm.Invalidate;
      TRY
        //Enable and clear all fields
        FOR n:=0 TO df^.FieldList.Count-1 DO
          BEGIN
            AField:=PeField(df^.FieldList.Items[n]);
            IF AField^.Felttype<>ftQuestion THEN
              BEGIN
                TEntryField(AField^.EntryField).Text:='';
                TEntryField(AField^.EntryField).MaxLength:=0;
                TEntryField(AField^.EntryField).Enabled:=True;
                IF df^.FieldBg<>COLOR_ENDCOLORS
                THEN TEntryField(AField^.EntryField).Color:=df^.FieldBg ELSE TEntryField(AField^.EntryField).Color:=FieldColor;
              END;
          END;
      EXCEPT
        QuitFindByExample(df);
      END;  //try..finally
    END  //if not df^.isfinding
  ELSE
    BEGIN
      IF (NOT FindAgain) THEN
        BEGIN
          //Read search criteria from dataform
          FindByExOptions.CanUseIndex:=True;
          FOR n:=0 TO df^.FieldList.Count-1 DO
            BEGIN
              AField:=PeField(df^.FieldList.Items[n]);
              IF AField^.Felttype<>ftQuestion THEN
                BEGIN
                  AEntryField:=TEntryField(AField^.EntryField);
                  s:=AnsiUpperCase(trim(AEntryField.Text));
                  IF s<>'' THEN
                    BEGIN
                      INC(FindByExOptions.NumCrites);
                      IF AField^.FIndex=0 THEN FindByExOptions.CanUseIndex:=False;
                      WITH FindByExOptions.Crites[FindByExOptions.NumCrites] DO
                        BEGIN
                          FieldNo:=n;
                          IF      s[1]='='         THEN Opr:=opEq
                          ELSE IF copy(s,1,2)='<>' THEN Opr:=opNEq
                          ELSE IF s[1]='<'         THEN Opr:=opLT
                          ELSE IF s[1]='>'         THEN Opr:=opGT;
                          IF Opr=opNone THEN
                            BEGIN
                              Opr:=opEq;
                              SearchText:=s;
                            END
                          ELSE
                            BEGIN
                              delete(s,1,1);
                              IF Opr=opNEq THEN delete(s,1,1);
                              SearchText:=s;
                            END;
                          ok:=True;
                          IF pos('*',s)>0 THEN
                            BEGIN
                              IF Opr<>opEq THEN ok:=False;
                              t:=0;
                              FOR n2:=0 TO Length(SearchText) DO
                                IF SearchText[n2]='*' THEN INC(t);
                              IF (SearchText[1]='*') AND (SearchText[Length(SearchText)]='*') THEN Opr:=opCON
                              ELSE IF (SearchText[1]='*') THEN Opr:=opEW
                              ELSE IF (SearchText[Length(SearchText)]='*') THEN Opr:=opBW
                              ELSE ok:=False;
                              IF ( (Opr=opCon) AND (t>2) )
                              OR ( (Opr=opBW) AND (t>1) )
                              OR ( (Opr=opEW) AND (t>1) ) THEN ok:=False;
                              IF NOT ok THEN
                                BEGIN
                                  ErrorMsg(Format('Error in field %s'#13#13'The wildcard "*" can only be used with this syntax:'#13+
                                    '= *text'#13'= *text*'#13'= text*'#13#13'The =-sign can be omitted.',[PeField(df^.FieldList.Items[n])^.FName]));
                                  ResetFindExOptions;
                                  TEntryField(PeField(df^.FieldList.Items[n])^.EntryField).SetFocus;
                                  Exit;
                                END;
                              //Remove *-character(s)
                              IF (Opr=opCon) OR (Opr=opEW) THEN delete(SearchText,1,1);
                              IF (Opr=opCon) OR (Opr=opBW) THEN delete(SearchText,Length(SearchText),1);
                            END;  //if wildcards
                          IF (AField^.Felttype in [ftInteger,ftFloat,ftIDNUM]) THEN
                            BEGIN
                              IF (SearchText='.') THEN SearchValue:=MinNumber
                              ELSE IF isFloat(SearchText) THEN SearchValue:=eStrToFloat(SearchText)
                              ELSE
                                BEGIN
                                  ErrorMsg(Format('Error in field %s'#13#13'Field is numeric',[PeField(df^.FieldList.Items[n])^.FName]));
                                  ResetFindExOptions;
                                  TEntryField(PeField(df^.FieldList.Items[n])^.EntryField).SetFocus;
                                  Exit;
                                END;
                            END;
                        END;  //with
                    END;  //if field is not empty
                END;  //if not ftQuestion
              IF FindByExOptions.NumCrites=MaxFindExCrites THEN Break;
            END;  //for
            IF FindByExOptions.NumCrites=0 THEN
              BEGIN
                ResetFindExOptions;
                Exit;
              END;
          QuitFindByExample(df);
        END;  //if not FindAgain


      //Begin the search

      TRY
        {Prepare datafile for readonly}
        df^.Datfile.Free;
        df^.Datfile:=NIL;
        AssignFile(roDat,df^.RECFilename);
        Reset(roDat);

        ProgressForm:=TProgressForm.Create(MainForm);
        ProgressForm.Caption:=Lang(22400);   //'Searching record'
        ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
        ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
        IF df^.NumRecords>60 THEN pStep:=df^.NumRecords DIV 20 ELSE pStep:=20;
        ProgressForm.pBar.Step:=pStep;
        WindowList:=DisableTaskWindows(ProgressForm.Handle);

        FindByExOptions.StartRecord:=df^.CurRecord;        
        fCurRec:=df^.CurRecord;
        IF fCurRec=NewRecord THEN
          BEGIN
            CASE FindByExOptions.Scope OF
              ssForward,ssAll: fCurRec:=1;
              ssBackWard: fCurRec:=df^.Numrecords;
            END;
          END
        ELSE
          BEGIN
            CASE FindByExOptions.Scope OF
              ssForward,ssAll:
                BEGIN
                  INC(fCurRec);
                  IF fCurRec>df^.NumRecords THEN fCurrec:=1;
                END;
              ssBackWard:
                BEGIN
                  DEC(fCurRec);
                  IF fCurRec<1 THEN fCurRec:=df^.NumRecords;
                END;
            END;  //case
          END;  //else
        Found:=False;
        fStop:=False;
        UserAborts:=False;
        ProgressForm.Show;
        WITH FindByExOptions DO
          BEGIN
            IF Assigned(FoundRecs) THEN
              BEGIN
                FoundRecs.Free;
                Foundrecs:=NIL;
              END;
            CurFoundRec:=-1;
          END;  //with

        IF FindByExOptions.CanUseIndex THEN
          BEGIN
            ProgressForm.pBar.Position:=ProgressForm.pBar.Max;
            FindByExOptions.FoundRecs:=TStringList.Create;
            FindByExOptions.FoundRecs.Duplicates:=dupAccept;
            //Make list of found values in TStringList:FoundRecs
            FOR n:=1 TO df^.NumRecords DO
              BEGIN
                Found:=False;
                t:=0;
                REPEAT
                  INC(t);
                  WITH FindByExOptions.Crites[t] DO
                    BEGIN
                      AField:=PeField(df^.FieldList.Items[FieldNo]);
                      s:=AnsiUpperCase(trim(ReadFromIndex(df,AField^.FIndex,n)));
                      Found:=DoTest(s,t,AField);
                    END;  //with
                UNTIL (NOT found) OR (t=FindByExOptions.NumCrites);
                IF Found THEN FindByExOptions.FoundRecs.Add(Format('%30d',[n]));
              END;  //for
            IF FindByExOptions.FoundRecs.Count=0 THEN
              BEGIN
                fStop:=True;
                Found:=False;
              END
            ELSE
              BEGIN
                //One or more records were found
                WITH FindByExOptions DO
                  BEGIN
                    FoundRecs.Sort;
                    CurFoundRec:=0;
                    Found:=False;
                    CASE Scope OF
                      ssForward:  CurFoundRec:=0;
                      ssBackWard: CurFoundRec:=FoundRecs.Count-1;
                      ssAll:      CurFoundRec:=0;
                    END;  //case Scope
                  END;  //with
                IF FindByExOptions.Scope=ssBackWard THEN
                  BEGIN
                    REPEAT
                      IF StrToInt(FindByExOptions.FoundRecs[FindByExOptions.CurFoundRec])<fCurRec THEN Found:=True
                      ELSE DEC(FindByExOptions.CurFoundRec);
                    UNTIL (FindByExOptions.CurFoundRec<0) OR (Found);
                  END
                ELSE
                  BEGIN
                    REPEAT
                      IF StrToInt(FindByExOptions.FoundRecs[FindByExOptions.CurFoundRec])>=fCurRec THEN Found:=True
                      ELSE INC(FindByExOptions.CurFoundRec);
                    UNTIL (FindByExOptions.CurFoundRec>FindByExOptions.FoundRecs.Count-1) OR (Found);
                    IF (NOT Found) AND (FindByExOptions.Scope=ssAll) THEN
                      BEGIN
                        Found:=True;
                        FindByExOptions.CurFoundRec:=0;
                      END;
                  END;
                IF NOT Found THEN fStop:=True
                ELSE
                  BEGIN
                    //There is a record with a higher recnumber than fCurRec (ssForward) or lower (ssBackWard)
                    Found:=True;
                    REPEAT
                      eReadOnlyRecord(df,roDat,StrToInt(FindByExOptions.FoundRecs[FindByExOptions.CurFoundRec]));
                      IF (FindByExOptions.IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;
                      IF NOT Found THEN
                        CASE FindByExOptions.Scope OF
                          ssForward,ssAll: INC(FindByExOptions.CurFoundRec);
                          ssBackWard:      DEC(FindByExOptions.CurFoundRec);
                        END;  //case
                    UNTIL (FindByExOptions.CurFoundRec>FindByExOptions.FoundRecs.Count-1)
                       OR (FindByExOptions.CurFoundRec<0)
                       OR (Found);
                    IF NOT Found THEN fStop:=True
                    ELSE fCurRec:=StrToInt(FindByExOptions.FoundRecs[FindByExOptions.CurFoundRec]);
                  END;
              END;  //one or more recs were found
          END  //if CanUseIndex
        ELSE
          BEGIN
            //Cannot use index
            eReadOnlyRecord(df,roDat,fCurRec);
            REPEAT    //until fStop or Found
              {compare searchtexts in all criterias with the field's text}
              t:=0;
              REPEAT
                INC(t);
                WITH FindByExOptions.Crites[t] DO
                  BEGIN
                    AField:=PeField(df^.FieldList.Items[FieldNo]);
                    s:=AnsiUpperCase(trim(AField^.FFieldText));
                    Found:=DoTest(s,t,AField);
                  END;  //with
              UNTIL (NOT found) OR (t=FindByExOptions.NumCrites);

              WITH FindByExOptions DO
                BEGIN
                  IF (IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;

                  IF NOT Found THEN
                    BEGIN
                      CASE Scope OF
                        ssForward: BEGIN
                          IF fCurRec=NewRecord THEN fCurRec:=1 ELSE INC(fCurRec);
                          IF fCurRec>df^.NumRecords THEN fStop:=True;
                          END;
                        ssBackWard: BEGIN
                          IF fCurRec=NewRecord THEN fCurRec:=df^.NumRecords
                          ELSE DEC(fCurRec);
                          IF fCurRec=0 THEN fStop:=True;
                          END;
                        ssAll: BEGIN
                          IF fCurRec=NewRecord THEN fCurRec:=1 ELSE INC(fCurRec);
                          IF fCurRec>df^.NumRecords THEN
                            BEGIN
                              fCurRec:=1;
                              IF StartRecord=NewRecord THEN fStop:=True;
                            END;
                          IF fCurRec=StartRecord THEN fStop:=True;
                          END;
                      END;  //case Scope
                      IF (NOT fStop) AND (NOT CanUseIndex) THEN eReadOnlyRecord(df,roDat,fCurRec);
                      IF (fCurRec MOD pStep)=0 THEN
                        BEGIN
                          ProgressForm.pBar.StepIt;
                          ProgressForm.pLabel.Caption:=Format(Lang(22404),[fCurRec]);  //'Searching in record %d'
                          Application.ProcessMessages;
                        END;
                    END;  //if not found
                END;  //with
            UNTIL (Found) or (fStop) or (UserAborts);
          END;  //if not CanUseIndex

        EnableTaskWindows(WindowList);
        ProgressForm.Free;

        {Leave datafile as normal file}
        CloseFile(roDat);
        df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);  //§§§

        IF Found THEN peReadRecord(df,fCurRec);

        IF fStop THEN
          BEGIN
            IF FindByExOptions.StartRecord=NewRecord THEN peNewRecord(df)
            ELSE peReadRecord(df,FindByExOptions.StartRecord);
            eDlg(Lang(22402),mtInformation,[mbOK],0);  //'Search string(s) not found.'
          END;
        IF UserAborts THEN peReadRecord(df,FindByExOptions.StartRecord);

      EXCEPT
        EnableTaskWindows(WindowList);
        ProgressForm.Free;
        {Leave datafile as normal file}
        CloseFile(roDat);
        df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);
      END;  //try..finally

    END;  //if df^.IsFinding
END;  //Procedure DoFindByExample




Procedure ResetFindRecOptions;
BEGIN
  WITH FindRecOptions DO
    BEGIN
      FieldNo1:=-1;
      SearchStyle1:=ssEquals;
      FindText1:='';
      FieldNo2:=-1;
      SearchStyle2:=ssEquals;
      FindText2:='';
      FieldNo3:=-1;
      SearchStyle3:=ssEquals;
      FindText3:='';
      CaseSensitive:=False;
      WholeWordsOnly:=False;
      IgnoreDeleted:=True;
      Scope:=ssAll;
      StartRecord:=-1;
      CanUseIndex:=False;
      IF Assigned(FoundRecs) THEN FoundRecs.Free;
      FoundRecs:=NIL;
      CurFoundRec:=-1;
    END;
END;  //procedure ResetFindRecOptions


procedure TFindRecordForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  IF copy(Lang(3840),1,2)='**' THEN
    BEGIN
      SearchStyleCombo1.Items[0]:='equals';
      SearchStyleCombo1.Items[1]:='begins with';
      SearchStyleCombo1.Items[2]:='contains';
      SearchStyleCombo2.Items[0]:='equals';
      SearchStyleCombo2.Items[1]:='begins with';
      SearchStyleCombo2.Items[2]:='contains';
      SearchStyleCombo3.Items[0]:='equals';
      SearchStyleCombo3.Items[1]:='begins with';
      SearchStyleCombo3.Items[2]:='contains';
    END;
  WITH FindRecOptions DO
    BEGIN
      SearchStyleCombo1.ItemIndex:=ORD(SearchStyle1);
      FindTextEdit1.Text:=FindText1;
      SearchStyleCombo2.ItemIndex:=ORD(SearchStyle2);
      FindTextEdit2.Text:=FindText2;
      SearchStyleCombo3.ItemIndex:=ORD(SearchStyle3);
      FindTextEdit3.Text:=FindText3;

      CaseCheck.Checked:=CaseSensitive;
      WordsOnlyCheck.Checked:=WholeWordsOnly;
      IgnoreDeletedCheck.Checked:=IgnoreDeleted;
      ScopeRadioBox.ItemIndex:=ORD(Scope);

      IF trim(FindText2)<>'' THEN
        BEGIN
          AndBtn1:=True;
          FieldnameCombo2.Enabled:=AndBtn1;
          FieldnameCombo2.Visible:=AndBtn1;
          SearchStyleCombo2.Enabled:=AndBtn1;
          SearchStyleCombo2.Visible:=AndBtn1;
          FindTextEdit2.Enabled:=AndBtn1;
          FindTextEdit2.Visible:=AndBtn1;
          AndButton2.Enabled:=AndBtn1;
          AndButton2.Visible:=AndBtn1;
          AndButton1.Down:=AndBtn1;
        END;

      IF trim(FindText3)<>'' THEN
        BEGIN
          AndBtn2:=True;
          FieldnameCombo3.Enabled:=AndBtn2;
          FieldnameCombo3.Visible:=AndBtn2;
          SearchStyleCombo3.Enabled:=AndBtn2;
          SearchStyleCombo3.Visible:=AndBtn2;
          FindTextEdit3.Enabled:=AndBtn2;
          FindTextEdit3.Visible:=AndBtn2;
          AndButton2.Down:=AndBtn2;
        END;
    END;  //with
end;





procedure TFindRecordForm.AndButton1Click(Sender: TObject);
begin
  AndBtn1:=NOT AndBtn1;
  FieldnameCombo2.Enabled:=AndBtn1;
  FieldnameCombo2.Visible:=AndBtn1;
  SearchStyleCombo2.Enabled:=AndBtn1;
  SearchStyleCombo2.Visible:=AndBtn1;
  FindTextEdit2.Enabled:=AndBtn1;
  FindTextEdit2.Visible:=AndBtn1;
  AndButton2.Enabled:=AndBtn1;
  AndButton2.Visible:=AndBtn1;
  IF NOT AndBtn1 THEN
    BEGIN
      FieldnameCombo3.Enabled:=False;
      FieldnameCombo3.Visible:=False;
      SearchStyleCombo3.Enabled:=False;
      SearchStyleCombo3.Visible:=False;
      FindTextEdit3.Enabled:=False;
      FindTextEdit3.Visible:=False;
      AndButton2.Down:=False;
      AndBtn2:=False;
    END;
  AndButton1.Down:=AndBtn1;
  IF (AndButton1.Down) AND (FieldNameCombo2.CanFocus) THEN FieldNameCombo2.SetFocus;
end;


procedure TFindRecordForm.AndButton2Click(Sender: TObject);
begin
  AndBtn2:=NOT AndBtn2;
  FieldnameCombo3.Enabled:=AndBtn2;
  FieldnameCombo3.Visible:=AndBtn2;
  SearchStyleCombo3.Enabled:=AndBtn2;
  SearchStyleCombo3.Visible:=AndBtn2;
  FindTextEdit3.Enabled:=AndBtn2;
  FindTextEdit3.Visible:=AndBtn2;
  AndButton2.Down:=AndBtn2;
  IF (AndButton1.Down) AND (FieldNameCombo3.CanFocus) THEN FieldNameCombo3.SetFocus;
end;

procedure TFindRecordForm.ResetBtnClick(Sender: TObject);
begin
  ResetFindRecOptions;
  FieldnameCombo1.ItemIndex:=FindrecOptions.CallingField;
  FieldnameCombo2.ItemIndex:=-1;
  FieldnameCombo3.ItemIndex:=-1;
  SearchStyleCombo1.ItemIndex:=0;
  SearchStyleCombo2.ItemIndex:=0;
  SearchStyleCombo3.ItemIndex:=0;
  FindTextEdit1.Text:='';
  FindTextEdit2.Text:='';
  FindtextEdit3.Text:='';
  AndBtn1:=False;
  FieldnameCombo2.Enabled:=AndBtn1;
  FieldnameCombo2.Visible:=AndBtn1;
  SearchStyleCombo2.Enabled:=AndBtn1;
  SearchStyleCombo2.Visible:=AndBtn1;
  FindTextEdit2.Enabled:=AndBtn1;
  FindTextEdit2.Visible:=AndBtn1;
  AndButton2.Enabled:=AndBtn1;
  AndButton2.Visible:=AndBtn1;
  AndButton1.Down:=AndBtn1;
  AndBtn2:=False;
  FieldnameCombo3.Enabled:=AndBtn2;
  FieldnameCombo3.Visible:=AndBtn2;
  SearchStyleCombo3.Enabled:=AndBtn2;
  SearchStyleCombo3.Visible:=AndBtn2;
  FindTextEdit3.Enabled:=AndBtn2;
  FindTextEdit3.Visible:=AndBtn2;
  AndButton2.Down:=AndBtn2;

  FieldNameCombo1.SetFocus;
end;

INITIALIZATION
  ResetFindExOptions;
  WITH FindRecOptions DO
    BEGIN
      SearchStyle1:=ssEquals;
      FindText1:='';
      SearchStyle2:=ssEquals;
      FindText2:='';
      SearchStyle3:=ssEquals;
      FindText3:='';
      CaseSensitive:=False;
      WholeWordsOnly:=False;
      IgnoreDeleted:=True;
      Scope:=ssAll;
      FieldNo1:=-1;
      FieldNo2:=-1;
      FieldNo3:=-1;
      CallingField:=-1;
      StartRecord:=-1;
      CanUseIndex:=False;
      FoundRecs:=NIL;
      CurFoundRec:=-1;
    END;

end.

