unit PeekCheckUnit;

//{$DEFINE epidat}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, EpiTypes;

type
  TpCheckForm = class(TForm)
    Panel1: TPanel;
    FieldTypeLabel: TLabel;
    Panel2: TPanel;
    FieldNamesCombo: TComboBox;
    RangeEdit: TEdit;
    MustEnterCombo: TComboBox;
    RepeatCombo: TComboBox;
    RangeLabel: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    SaveBtn: TBitBtn;
    ExitBtn: TBitBtn;
    JumpsLabel: TStaticText;
    CornerImage: TImage;
    VarLabel: TLabel;
    GenerateLabel: TButton;
    ValLabelCombo: TComboBox;
    StaticText1: TStaticText;
    EditChecksBtn: TBitBtn;
    JumpsEdit: TEdit;
    Procedure SaveCheckFile;
    Procedure UpDateCheckForm(Sender: TObject);
    procedure RangeEditExit(Sender: TObject);
    procedure JumpsEditExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MustEnterComboChange(Sender: TObject);
    procedure RepeatComboChange(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FieldNamesComboChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RangeEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure JumpsEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RepeatComboKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SaveBtnClick(Sender: TObject);
    procedure MustEnterComboKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    Procedure pToggleMustEnter;
    Procedure pToggleRepeat;
    Procedure pCopyChecks;
    Procedure pInsertChecks;
    Procedure pCutChecks;
    procedure RangeEditKeyPress(Sender: TObject; var Key: Char);
    procedure RepeatComboKeyPress(Sender: TObject; var Key: Char);
    Procedure UpdateValLabelCombo;
    procedure GenerateLabelClick(Sender: TObject);
    procedure ValLabelComboDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ValLabelComboChange(Sender: TObject);
    procedure JumpsEditKeyPress(Sender: TObject; var Key: Char);
    procedure EditChecksBtnClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    TheDatafile:PDatafileInfo;
    CheckFileModified:Boolean;
  end;


var
  pCheckForm: TpCheckForm;
  CheckFormRect: TRect;
  GetFieldnameForJump:Boolean;
  tmpField:PeField;


//Function  RemoveQuotes(s:String):String;
{$IFNDEF epidat}
Procedure pNewCheckFile(VAR df:PDatafileInfo);
{$ENDIF}
Function  PeekApplyCheckFile(df:PDatafileInfo; VAR ErrList:String):Boolean;
//Function  StringsToChecks(df:PDatafileInfo; VAR ErrorList:String):Boolean;
Procedure AddCommandList(VAR df:PDatafileInfo; VAR sList:TStringList; VAR CmdList:TList; Indent:Byte);
Procedure FieldBlockToStrings(VAR df:PDatafileInfo; VAR sList:TStringList; FieldNo:Integer; Indent:Byte);
Procedure ChecksToStrings(VAR df:PDatafileInfo; VAR sList:TStringList);
Function  LoadAsserts(CONST AssertFilename:TFilename;
          VAR AssList: TList; VAR df:PDataFileInfo; VAR ReportField:Integer):Boolean;


implementation

{$R *.DFM}

USES
  {$IFNDEF epidat}
  CheckObjUnit,FileUnit, MainUnit, DataFormUnit, LabelEditUnit, UExtUDF, epiUDFTypes;
  {$ELSE}
  CheckObjUnit,FileUnit,UExtUDF,epiUDFTypes;
  {$ENDIF}

TYPE
  TtmpChecks=RECORD
               FNoEnter:Boolean;
               FLegal:String;
               FValueLabel:String;
               FRangeDefined:Boolean;
               FMin,FMax:String;
               FJumps:String;
               FJumpResetChar:Char;
               FMustEnter:Boolean;
               FRepeat:Boolean;
               FDefaultValue:string;
               FConfirm:Boolean;
               FTypeComments:Boolean;
               FTypeColor:TColor;
               FTypeCommentField:Integer;
               Empty:Boolean;
             END;
  nwTypes=(nwAny,nwSameLine,nwSameKeepQuotes,nwKeepSpaces);

VAR
  LegalList: TStrings;
  tmpChecks: TtmpChecks;
  FieldComments: TStrings;
  CommentsAddedToCheckFile: Boolean;
  ChkLin,ErrorLin: TStrings;
  CurLin, CurCommand: String;
  CurLinIndex: Integer;
  EndOfChkFile,ReadingLabelLibrary: Boolean;
  InIfBlock: Boolean;
  MultiLineError: Boolean;
//  FocusedField: Integer;




Function Label2Text(CONST ALabelName:String; ALabelRec:PLabelRec; NumSpc:Byte):String;
VAR
  s:String;
  spc:String[100];
BEGIN
  spc:=cFill(' ',NumSpc);
  s:=spc+'LABEL '+ALabelName;
  IF s[Length(s)]='¤' THEN s:=Copy(s,1,Length(s)-1);
  WHILE ALabelRec<>NIL DO
    BEGIN
      IF ALabelRec^.Value[1]='*' THEN    //###
        BEGIN
          s:=s+#13+spc+'  '+ALabelRec^.Value+ALabelRec^.Text;
        END
      ELSE
        BEGIN
          IF Pos(' ',ALabelRec^.Value)>0
            THEN s:=s+#13+spc+'  "'+ALabelRec^.Value+'"'
            ELSE s:=s+#13+spc+'  '+ALabelRec^.Value;
          IF Pos(' ',ALabelRec^.Text)>0
            THEN s:=s+'  "'+ALabelRec^.Text+'"'
            ELSE s:=s+'  '+ALabelRec^.Text;
        END;
      ALabelRec:=ALabelRec^.Next;
    END;  //while
  s:=s+#13+spc+'END';
  Result:=s;
END;  //Label2Text


Function NexttWord(nwType:nwTypes):String;
VAR
  n:Integer;
  Stop:Boolean;
BEGIN
  IF (trim(CurLin)='') AND (nwType=nwAny) THEN
    BEGIN
      INC(CurLinIndex);
      IF CurLinIndex<ChkLin.Count
      THEN CurLin:=Trim(ChkLin[CurLinIndex])+' '
      ELSE EndOfChkFile:=True;
    END;
  IF (trim(CurLin)<>'') THEN
    BEGIN
      IF Copy(trim(CurLin),1,1)='*' THEN
        BEGIN
          Result:=CurLin;
          CurLin:='';
        END
      ELSE
        BEGIN
          Result:=Copy(CurLin,1,Pos(' ',CurLin)-1);
          IF (Result[1]='"') THEN
            BEGIN
              IF (Result[Length(Result)]='"')  AND (Length(Result)>1) THEN
                BEGIN
                  {Only one word is found in quotationmarks}
                  IF NOT (nwType=nwSameKeepQuotes) THEN Result:=Copy(Result,2,Length(Result)-2);
                  Delete(CurLin,1,Pos(' ',Curlin));
                END
              ELSE
                BEGIN
                  {Multiple words found in quotationsmarks}
                  n:=1;
                  Result:='';
                  Stop:=False;
                  REPEAT
                    Result:=Result+CurLin[n];
                    INC(n);
                    IF n>Length(CurLin) THEN Stop:=True
                    ELSE IF CurLin[n]='"' THEN Stop:=True;
                  UNTIL Stop;
                  Result:=Result+'"';

{                  n:=Pos(' ',CurLin);
                  IF n>0 THEN
                    BEGIN
                      While (n<=Length(CurLin)) AND (CurLin[n]<>'"') DO
                        BEGIN
                          Result:=Result+CurLin[n];
                          INC(n);
                        END;
                    END;}
                  IF NOT (nwType=nwKeepSpaces) THEN Result:=trim(Result);
                  IF NOT (nwType=nwSameKeepQuotes) THEN
                    BEGIN
                      Delete(Result,1,1);
                      Delete(CurLin,1,n);
                      IF Result[Length(Result)]='"' THEN Delete(Result,Length(Result),1);
                    END
                  ELSE Delete(CurLin,1,n);
                END;
            END
          ELSE Delete(CurLin,1,Pos(' ',CurLin));
          CurLin:=trim(CurLin)+' ';
        END;
    END
  ELSE Result:='';
END;  //function NextWord

Procedure RetrieveLabel(VAR df:PDatafileInfo);
//Reads a LABEL..END block
VAR
  FirstLabelRec,tmpLabelRec,NextLabelRec:PLabelRec;
  tmpLabelName:String[80];
  ok,StopRead,FirstLabel:Boolean;
BEGIN
  ok:=True;
  FirstLabel:=True;
  tmpLabelRec:=NIL;
  FirstLabelRec:=NIL;
  CurCommand:=AnsiLowerCase(NexttWord(nwSameLine));   //Get Labelname
  IF trim(CurCommand)<>'' THEN
    BEGIN
      IF (df^.ValueLabels.IndexOf(CurCommand)=-1)
      AND (df^.ValueLabels.IndexOf(CurCommand+'¤')=-1) THEN
        BEGIN
          StopRead:=False;
          tmpLabelName:=trim(CurCommand);
          IF ReadingLabelLibrary THEN
            BEGIN
              IF Length(tmpLabelName)=40 THEN tmpLabelName[40]:='¤'
              ELSE tmpLabelName:=tmpLabelName+'¤';
            END;
          REPEAT
            //Read value
            CurCommand:=NexttWord(nwAny);
            IF Trim(CurCommand)='' THEN
              BEGIN
                StopRead:=True;
                ok:=False;
              END;
            IF AnsiUpperCase(CurCommand)='END' THEN StopRead:=True
            ELSE IF trim(CurCommand)<>'' THEN
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
                IF Length(CurCommand)>30 THEN CurCommand:=Copy(CurCommand,1,30);
                tmpLabelRec^.Value:=CurCommand;
                //Read text
                CurCommand:=NexttWord(nwSameLine);
                IF trim(CurCommand)='' THEN
                  BEGIN
                    StopRead:=True;
                    ok:=False;
                  END
                ELSE
                  BEGIN
                    IF Length(CurCommand)>80 THEN CurCommand:=Copy(CurCommand,1,80);
                    WHILE pos('"',CurCommand)>0 DO Delete(CurCommand,Pos('"',CurCommand),1);
                    tmpLabelRec^.Text:=CurCommand;
                  END;
              END
            ELSE stopRead:=True;
          UNTIL StopRead;
        END  //if label name didn't exist
      ELSE ok:=False;
    END  //if label name was found
  ELSE ok:=False;
  IF ok THEN df^.ValueLabels.AddObject(tmpLabelname,TObject(FirstLabelRec))
  ELSE
    BEGIN
      tmpLabelRec:=FirstLabelRec;
      DisposeLabelRec(tmpLabelRec);
    END;
  CurCommand:='';
END;  //retrieveLabel


{$IFNDEF epidat}
Procedure pNewCheckFile(VAR df:PDatafileInfo);
VAR
  nN:Integer;
  ACheckForm:TpCheckForm;
  LblFilename: TFilename;
BEGIN
  TRY
    {Datafile has now been opened and the dataform is created}
    ACheckForm:=TpCheckForm.Create(Application);
    ACheckForm.TheDatafile:=df;
    df^.ChkForm:=TObject(ACheckForm);
    df^.CheckFormCreated:=True;
    ACheckForm.Caption:=ExtractFilename(df^.CHKFilename);
    ACheckForm.ValLabelCombo.Items.AddObject(' '+Lang(20604)+' ',NIL);   //'[none]'
    Lblfilename:=ExtractFileDir(df^.RECFilename)+'\EpiData.Lbl';
    IF NOT FileExists(LblFilename) THEN LblFilename:=ExtractFileDir(ParamStr(0))+'\EpiData.Lbl';
    IF FileExists(LblFilename) THEN
    BEGIN   //Read label library
      ChkLin:=TStringList.Create;
      ChkLin.LoadFromFile(ExtractFileDir(ParamStr(0))+'\EpiData.Lbl');
      CurLin:='';
      CurLinIndex:=-1;
      EndOfChkFile:=False;
      IF ChkLin.Count>0 THEN
        BEGIN
          ReadingLabelLibrary:=True;
          REPEAT
            CurCommand:=NexttWord(nwAny);
            IF AnsiUpperCase(CurCommand)='LABEL' THEN RetrieveLabel(df);
          UNTIL EndOfChkFile;
          ReadingLabelLibrary:=False;
        END;  //if chkLin.Count>0
      ChkLin.Free;
    END;  //Read Label Library
    ACheckForm.ValLabelCombo.Items.AddStrings(df^.ValueLabels);
    AcheckForm.ValLabelCombo.ItemIndex:=0;
    FOR nN:=0 TO df^.FieldList.Count-1 DO
      WITH PeField(df^.FieldList.Items[nN])^ DO
        BEGIN
          IF (FeltType<>ftQuestion) AND (FeltType<>ftIDNUM)
            AND (FeltType<>ftToday) AND (FeltType<>ftEuroToday) AND (FeltType<>ftYMDToday)    //&&
          THEN ACheckForm.FieldNamesCombo.Items.
            AddObject(AnsiUpperCase(trim(FName)),TObject(EntryField));
          IF (FeltType<>ftQuestion) THEN TEntryField(EntryField).ReadOnly:=True;
        END;
    ACheckForm.CheckFileModified:=False;
    ACheckForm.SaveBtn.Enabled:=False;
  EXCEPT
    ErrorMsg(Format(Lang(20204),[532]));  //'Out of memory (ref-code 532)'
    ChkLin.Free;
  END;  //try..Except
END;
{$ENDIF}

{Function StringsToChecks(df:PDatafileInfo; VAR ErrorList:String):Boolean;
VAR
  FieldnameList, LegList: TStrings;
  aN,n,n2:Integer;
  TempResult,aFound: Boolean;
  FirstTopFlaw,SaveTopFlawsAsComments: Boolean;
  FirstFieldFlaw,SaveFieldFlawsAsComments: Boolean;
  tmpS,s: String;

  Procedure ReportError(CONST ErrStr:String);
  VAR
    n:Integer;
  BEGIN
    IF EndOfChkFile THEN n:=ChkLin.Count ELSE n:=CurLinIndex+1;
    {$IFNDEF epidat}
{    IF MultiLineError THEN
      BEGIN
        ErrorLin.Append(Format(Lang(22700),[ErrStr,n]));  //'%s in line %d:'
        ErrorLin.Append(ChkLin[CurLinIndex]);
        ErrorLin.Append('');
      END
    ELSE ErrorLin.Append(Format(Lang(22702),[n,ErrStr]));  //'Line %d: %s'
    {$ENDIF}
{  END;  //procedure ReportError
}

{  Procedure RetrieveLegals;
  VAR
    StopGet,LegalResult,UsedUse,FirstLegalResult:Boolean;
  BEGIN
    UsedUse:=False;
    StopGet:=False;
    LegalResult:=True;
    FirstLegalResult:=True;
    LegList.Clear;
    REPEAT   //until StopGet
      IF NOT EndOfChkFile THEN CurCommand:=NextWord(nwAny)
      ELSE
        BEGIN   //EndOfChkFile found before END
          {$IFNDEF epidat}
//          ReportError(Lang(22704));   //'Missing END of LEGAL-block.'
//          {$ENDIF}
{          LegalResult:=False;
          StopGet:=True;
        END;
      IF AnsiUpperCase(CurCommand)='END' THEN StopGet:=True
//***********
      ELSE IF AnsiUpperCase(CurCommand)='USE' THEN
        BEGIN
          //LEGAL USE structure
          CurCommand:=AnsiLowerCase(NextWord(nwSameLine));
          s:='';
          {$IFNDEF epidat}
{          IF CurCommand='' THEN s:=Lang(22706);  //'LEGAL USE command without fieldname'
          n:=FieldNameList.IndexOf(AnsiUpperCase(CurCommand));
          IF n=-1 THEN s:=Lang(22708);  //'Unknown fieldname'
          {$ELSE}
{          IF CurCommand='' THEN s:='LEGAL USE command without fieldname';
          n:=FieldNameList.IndexOf(AnsiUpperCase(CurCommand));
          IF n=-1 THEN s:='Unknown fieldname';
          {$ENDIF}
{          IF s<>'' THEN
            BEGIN
              ReportError(s);
              TempResult:=False;
            END
          ELSE
            BEGIN    //Fieldname came after the USE command
              IF PeField(df^.FieldList.Items[n])^.FRangeDefined THEN
                BEGIN
                  LegList.CommaText:=PeField(df^.FieldList.Items[n])^.FLegal;
                  LegList.Delete(0);
                  tmpField^.FLegal:=RemoveQuotes(LegList.Commatext);
                END
              ELSE tmpField^.FLegal:=PeField(df^.FieldList.Items[n])^.FLegal;
              UsedUse:=True;
              StopGet:=True;
            END;
        END  //the word USE was found
//***********

      ELSE IF CurCommand<>'' THEN
        BEGIN
          IF IsCompliant(CurCommand,PeField(df^.FieldList.Items[df^.FocusedField])^.FeltType)
          THEN LegList.Add(CurCommand)
          ELSE
            BEGIN
//              {$IFNDEF epidat}
//              ReportError(Lang(22710));  //'Legal value is not compatible with this fieldtype'
//              {$ENDIF}
//              LegalResult:=False;
{            END;
        END;  //else
    UNTIL StopGet;

    IF LegalResult THEN
      BEGIN
        WITH tmpField^ DO
          BEGIN
            IF NOT UsedUse THEN
              BEGIN
                IF FLegal='' THEN FLegal:=LegList.CommaText
                ELSE FLegal:=FLegal+','+LegList.CommaText;
                FLegal:=RemoveQuotes(FLegal);
              END;
          END;  //with
      END
    ELSE TempResult:=False;
    CurCommand:='';
  END;  //function RetrieveLegals


  Procedure RetrieveRange;
  VAR
    tmpS:String;
    RangeResult:Boolean;
  BEGIN
    RangeResult:=True;
    {Get minimum value}
//    CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
{    IF CurCommand='' THEN
      BEGIN
//        {$IFNDEF epidat}
//        ReportError(Lang(22712));   //'RANGE command without mininum value'
//        {$ENDIF}
{        RangeResult:=False;
      END
    ELSE tmpField^.FMin:=CurCommand;
    IF tmpField^.FMin='-INFINITY' THEN tmpField^.FMin:='';
    {Get maxinum value}
{    CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
    IF CurCommand='' THEN
      BEGIN
//        {$IFNDEF epidat}
//        ReportError(Lang(22714));  //'RANGE command without maximum value'
//        {$ENDIF}
//        RangeResult:=False;
{      END
    ELSE tmpField^.FMax:=CurCommand;
    IF tmpField^.FMax='INFINITY' THEN tmpField^.FMax:='';

    //Check if range values are compliant with fieldtype
    IF (tmpField^.FMin<>'') AND (NOT IsCompliant(tmpField^.FMin,tmpField^.Felttype)) THEN
      BEGIN
//        {$IFNDEF epidat}
//        ReportError(Lang(22716));  //'Minimum value is not compatible with this type of field'
//        {$ENDIF}
{        RangeResult:=False;
      END;
    IF (RangeResult) AND (tmpField^.FMax<>'') AND (NOT IsCompliant(tmpField^.FMax,tmpField^.Felttype)) THEN
      BEGIN
//        {$IFNDEF epidat}
//        ReportError(Lang(22718));  //'Maximum value is not compatible with this type of field'
//        {$ENDIF}
{        RangeResult:=False;
      END;

    IF RangeResult THEN
      BEGIN
        WITH tmpField^ DO
          BEGIN
            IF FMin='' THEN tmpS:='-INF-' ELSE tmpS:=FMin+'-';
            IF FMax='' THEN tmpS:=tmpS+'INF' ELSE tmpS:=tmpS+FMax;
            FRangeDefined:=True;
            IF FLegal='' THEN FLegal:=tmpS
            ELSE FLegal:=tmpS+','+FLegal;
            FLegal:=RemoveQuotes(FLegal);
          END;
      END
    ELSE TempResult:=False;
    CurCommand:='';
  END;  //function RetrieveRange


  Procedure RetrieveJumps;
  VAR
    JumpsResult,StopGet:Boolean;
    tmpS: String;
  BEGIN
    StopGet:=False;
    JumpsResult:=True;
    LegList.Clear;
    REPEAT   //until StopGet
      tmpS:='';
      //Check if a RESET command exists after JUMPS
      CurCommand:=NextWord(nwSameLine);
      IF CurCommand<>'' THEN
        BEGIN
          IF AnsiUpperCase(CurCommand)<>'RESET' THEN
            BEGIN
//              {$IFNDEF epidat}
//              ReportError(Format(Lang(22830),[CurCommand]));   //'RESET expected but %s found'
//              {$ENDIF}
{              Jumpsresult:=False;
              StopGet:=True;
            END
          ELSE
            BEGIN
              tmpField^.FJumpResetChar:=#32;
              CurCommand:=NextWord(nwSameLine);
              IF Length(CurCommand)=1 THEN tmpField^.FJumpResetChar:=CurCommand[1];
            END;
        END;
      //Read value
      IF NOT EndOfChkFile THEN CurCommand:=AnsiUpperCase(NextWord(nwAny))
      ELSE
        BEGIN   //EndOfChkFile found before END
//          {$IFNDEF epidat}
//          ReportError(Lang(22720));  //'Missing END of JUMPS-block'
//          {$ENDIF}
{          JumpsResult:=False;
          StopGet:=True;
        END;
      IF CurCommand='END' THEN StopGet:=True
      ELSE IF CurCommand<>'' THEN
        BEGIN
          CASE tmpField^.FeltType OF
            ftInteger,ftIDNUM: IF IsInteger(CurCommand)
                               THEN tmpS:=trim(CurCommand)+'>'
                               ELSE JumpsResult:=False;

            ftFloat:           IF IsFloat(CurCommand)
                               THEN tmpS:=trim(CurCommand)+'>'
                               ELSE JumpsResult:=False;

            ftYMDDate,                  //&&
            ftDate,ftEuroDate: BEGIN
                                 tmpS:=CurCommand;
                                 IF mibIsDate(tmpS,tmpField^.Felttype)
                                 THEN tmpS:=tmpS+'>'
                                 ELSE JumpsResult:=False;
                               END;

            ftBoolean:         IF (Length(Curcommand)=1) AND (CurCommand[1] in BooleanChars)
                               THEN tmpS:=CurCommand+'>'
                               ELSE JumpsResult:=False;

            ftToDay,ftYMDToday,
            ftEuroToday:       JumpsResult:=False;
          ELSE
            tmpS:=trim(CurCommand)+'>';
          END;  //Case

//          {$IFNDEF epidat}
//          IF NOT JumpsResult THEN ReportError(Lang(22722));  //'Illegal datatype'
//          {$ENDIF}

          //Get name of field to jump to
{          IF NOT EndOfChkFile THEN CurCommand:=NextWord(nwSameLine)
          ELSE
            BEGIN   //EndOfChkFile found before END
//              {$IFNDEF epidat}
//              ReportError(Lang(22724));  //'Jumps command without field to jump to'
//              {$ENDIF}
{              JumpsResult:=False;
              StopGet:=True;
            END;

          IF (JumpsResult) AND (FieldNameList.IndexOf(CurCommand)=-1) THEN
            BEGIN
              IF AnsiLowerCase(CurCommand)='end' THEN CurCommand:='END'
              ELSE IF AnsiLowerCase(CurCommand)='write' THEN CurCommand:='WRITE'
              ELSE IF AnsiLowerCase(CurCommand)='skipnextfield' THEN Curcommand:='SKIPNEXTFIELD';
              IF (CurCommand<>'END') AND (CurCommand<>'WRITE') AND (CurCommand<>'SKIPNEXTFIELD') THEN
                BEGIN
//                  {$IFNDEF epidat}
//                  ReportError(Lang(22726));  //'Unknown fieldname in JUMP block'
//                  {$ENDIF}
//                  JumpsResult:=False;
{                  StopGet:=True;
                END;
            END;

          IF JumpsResult THEN
            BEGIN
              tmpS:=tmpS+CurCommand;
              LegList.Add(tmpS);
            END;
        END;  //else
    UNTIL StopGet;

    IF JumpsResult THEN tmpField^.FJumps:=RemoveQuotes(LegList.CommaText)
    ELSE TempResult:=False;
    CurCommand:='';
  END;  //Procedure RetrieveJumps

  Procedure RetrieveAutoJump;
  BEGIN
    CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
    IF CurCommand='' THEN
      BEGIN
        ReportError(Lang(22728));  //'AUTOJUMP command without name of field to jump to'
        TempResult:=False;
      END;

    IF (FieldNameList.IndexOf(CurCommand)=-1) AND (CurCommand<>'END')
    AND (CurCommand<>'WRITE') AND (CurCommand<>'SKIPNEXTFIELD') THEN
      BEGIN
        ReportError(Lang(22730));  //'Unknown fieldname in AUTOJUMP command'
        TempResult:=False;
      END
    ELSE tmpField^.FJumps:='AUTOJUMP '+CurCommand;
    CurCommand:='';
  END;  //procedure RetrieveAutojump


  Procedure RetrieveCommentLegal(VAR AValueLabel:ShortString; VAR ACommentLegalRec: PLabelRec; VAR ShowList:Boolean; AsCommand:Boolean);
  VAR
    s,s2,LabelName,tmpS2,peekErrors: String;       //&&
    n,CurRec: Integer;
    ValueField,TextField: PeField;
    ALabelRec, FirstLabelRec,NextLabelRec,tmpLabelRec: PLabelRec;
    ok,StopRead,FirstLabel:Boolean;
    ComLegDf: PDatafileInfo;
    F: TIndexFile;
    F2:TextFile;
    s30: Str30;
    TooLong,NotCompatible:Boolean;
    tmpStrings: TStrings;
  BEGIN
    {Four kinds of COMMENT LEGAL possible:
    1. COMMENT LEGAL
         1  ...
         2  ...
       END
       Name in ValueLabels has a $ in the end

    2. COMMENT LEGAL USE labelname
       FValueLabel has has ¤ in the end

    3. COMMENT LEGAL USE fieldname

    4. COMMENT LEGAL datafilename    }

{    ShowList:=False;
    CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
    IF CurCommand<>'LEGAL' THEN
      BEGIN
        ReportError(Lang(22732));  //'Unknown command in line');
        TempResult:=False;
      END
    ELSE
      BEGIN
        CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
        IF (CurCommand='') OR (CurCommand='SHOW') THEN
          BEGIN
            //1. scenario: COMMENT LEGAL...END Structure
            IF CurCommand='SHOW' THEN ShowList:=True;
            StopRead:=False;
            ok:=True;
            FirstLabel:=true;
            tmpLabelRec:=NIL;
            FirstLabelRec:=NIL;
            REPEAT
              //Read value
              CurCommand:=NextWord(nwAny);
              IF AnsiUpperCase(CurCommand)='END' THEN StopRead:=True
              ELSE IF trim(CurCommand)<>'' THEN
                BEGIN
                  IF Length(trim(CurCommand))>tmpField^.FLength THEN
                    BEGIN
                      StopRead:=True;
                      TempResult:=False;
                      ReportError(Lang(22852));   //22852=Value is too wide for field
                    END
                  ELSE IF IsCompliant(trim(CurCommand),tmpField^.Felttype) THEN
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
                      IF Length(CurCommand)>30 THEN CurCommand:=Copy(CurCommand,1,30);
                      tmpLabelRec^.Value:=trim(CurCommand);
                      //Read text
                      CurCommand:=NextWord(nwSameLine);
                      IF trim(CurCommand)='' THEN
                        BEGIN
                          StopRead:=True;
                          ok:=False;
                        END
                      ELSE
                        BEGIN
                          IF Length(CurCommand)>45 THEN CurCommand:=Copy(CurCommand,1,45);
                          WHILE pos('"',CurCommand)>0 DO Delete(CurCommand,Pos('"',CurCommand),1);
                          tmpLabelRec^.Text:=CurCommand;
                        END;
                    END  //if value is compliant with fieldtype
                  ELSE
                    BEGIN
                      StopRead:=True;
                      TempResult:=False;
                      ReportError(Lang(22710));  //'Value is not compatible with this fieldtype');
                    END;
                END  //if curCommand<>END and CurCommand<>''
              ELSE
                BEGIN
                  StopRead:=True;
                  TempResult:=False;
                  ReportError(Lang(22734));  //'Unexpected end of COMMENT LEGAL'
                END;
            UNTIL StopRead;
            IF TempResult THEN
              BEGIN
                IF AsCommand THEN
                  BEGIN
                    INC(ComLegalCounter);
                    s:='ComLegal'+IntToStr(ComLegalCounter)+'$';
                  END
                ELSE
                  s:=Lang(22736)+' '+   //'labels in field'
                  trim(PeField(df^.FieldList.Items[df^.FocusedField])^.FName)+'$';
                s:=AnsiLowerCase(s);
                n:=df^.ValueLabels.IndexOf(s);
                IF n>-1 THEN
                  BEGIN
                    tmpLabelRec:=PLabelRec(df^.ValueLabels.Objects[n]);
                    DisposeLabelRec(tmpLabelRec);
                    df^.ValueLabels.Delete(n);
                  END;
                df^.ValueLabels.AddObject(s,TObject(FirstLabelRec));
                AValueLabel:=s;
                ACommentLegalRec:=FirstLabelRec;
              END  //if ok
            ELSE
              BEGIN
                tmpLabelRec:=FirstLabelRec;
                DisposeLabelRec(tmpLabelRec);
              END;
          END  //if COMMENT LEGAL...END Structure
        ELSE IF CurCommand='USE' THEN
          BEGIN
            //COMMENT LEGAL USE structure
            CurCommand:=AnsiLowerCase(NextWord(nwSameLine));
            s:='';
            IF CurCommand='' THEN s:=Lang(22738);  //'COMMENT LEGAL USE command without labelname or fieldname'
            n:=df^.ValueLabels.IndexOf(CurCommand);
            IF n=-1 THEN
              BEGIN
                n:=FieldNameList.IndexOf(AnsiUpperCase(CurCommand));
                IF n=-1 THEN s:=Lang(22740) ELSE n:=n+10000;   //'Unknown labelname or fieldname'
              END;
            IF s<>'' THEN
              BEGIN
                ReportError(s);
                TempResult:=False;
              END
            ELSE
              BEGIN
                s2:=CurCommand;
                CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
                IF CurCommand='SHOW' THEN ShowList:=True;
                CurCommand:=s2;
                //if n<10000 then value label else use fieldname
                //FocusedField.Fvaluelabel:=n-10000.FValueLabel
                //FocusedField.FLabelRec:=n-10000.FLabelRec
                IF n<10000 THEN
                  BEGIN    //Valuelabel came after the USE command
                    AValueLabel:=CurCommand;
                    ALabelRec:=PLabelRec(df^.ValueLabels.Objects[n]);
                    ACommentLegalRec:=ALabelRec;
                  END
                ELSE
                  BEGIN    //Fieldname came after the USE command
                    AValueLabel:=
                      PeField(df^.FieldList.Items[n-10000])^.FValueLabel;
                    ACommentLegalRec:=
                      PeField(df^.FieldList.Items[n-10000])^.FCommentLegalRec;
                  END;
                //check is labels are compatible with current field
                ALabelRec:=ACommentLegalRec;
                TooLong:=False;
                NotCompatible:=False;
                WHILE (ALabelRec<>NIL) AND (NOT TooLong) AND (NOT NotCompatible) DO
                  BEGIN
                    IF Length(trim(ALabelRec^.Value))>tmpField^.FLength THEN TooLong:=True;
                    IF (NOT IsCompliant(trim(ALabelRec^.Value),tmpField^.Felttype)) THEN NotCompatible:=True;
                    ALabelRec:=ALabelRec^.Next
                  END;
                IF NotCompatible THEN
                  BEGIN
                    StopRead:=True;
                    TempResult:=False;
                    ReportError(Lang(22710));  //'Value is not compatible with this fieldtype');
                  END  //if NotCompatible
                ELSE IF TooLong THEN
                  BEGIN
                    StopRead:=True;
                    TempResult:=False;
                    ReportError(Lang(22852));   //22852=Value is too wide for field
                  END  //if TooLong
              END;
          END  //the word USE was found
        ELSE
          BEGIN  //Not Comment legal..end and not comment legal use
            IF ExtractFileExt(Curcommand)='' THEN s:=CurCommand+'.rec' ELSE s:=CurCommand;
            tmpS2:=GetCurrentDir;   //&&
            SetCurrentDir(ExtractFileDir(df^.RECFilename));
            s:=ExpandFilename(s);              //&&
            SetCurrentDir(tmpS2);
            //s:=ExpandFilename(s);
            //IF ExtractFilePath(s)='' THEN s:=ExtractFilePath(df^.RECFilename)+s;
            //tmpS:=AnsiLowerCase(tmpS);

            IF NOT FileExists(s) THEN
              BEGIN
                ReportError(Format(Lang(20110),[s]));   //20110=Datafile %s does not exist.
                TempResult:=False;
                //ReportError(Lang(22742));  //'USE expected after COMMENT LEGAL'   //*** Obsolete
              END
            ELSE
              BEGIN
                //Comment Legal datafilename structure found
                CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
                IF CurCommand='SHOW' THEN ShowList:=True;
                TRY
                  ComLegDf:=NIL;
                  TempResult:=GetDatafilePointer(ComLegDf);
                  IF TempResult THEN
                    BEGIN
                      ComLegDf^.RECFilename:=s;
                      ComLegDf^.IndexFilename:=ChangeFileExt(s,'.eix');
                      ComLegDf^.CHKFilename:=ChangefileExt(s,'.chk');
                      TempResult:=PeekDatafile(ComLegDf);
                    END;
                  IF NOT TempResult THEN ReportError(Format(Lang(20108),[s]));  //'Datafile %s could not be opened'
                  IF (TempResult) AND (ComLegDf^.NumRecords=0) THEN
                    BEGIN
                      TempResult:=False;
                      ReportError(Format(Lang(22334),[s]));   //'Datafile %s does not contain any records'
                    END;
                  IF (TempResult) AND (NOT FileExists(ComLegDf^.IndexFilename)) THEN
                    BEGIN
                      TempResult:=False;
                      ReportError(Format(Lang(20122),[s]));  //'Indexfile not found for the datafile %s'
                    END;
                  IF TempResult THEN
                    BEGIN
                      Labelname:=AnsiLowerCase('Labels from '+ExtractFileName(ComLegDf^.RECFilename));
                      n:=df^.ValueLabels.IndexOf(Labelname);
                      IF n>-1 THEN
                        BEGIN
                          //Labels are already loaded
                          AValueLabel:=df^.ValueLabels[n];
                          ACommentLegalRec:=PLabelRec(df^.ValueLabels.Objects[n]);
                        END
                      ELSE
                        BEGIN
                          //Applyindex, sort index and read records into PLabelRec
                          AssignFile(F,ComLegdf^.IndexFilename);
                          Reset(F);
                          Read(F,s30);
                          CloseFile(F);
                          //Get number of index fields
                          s30:=s30+'@';
                          s2:=Copy(s30,1,Pos('@',s30)-1);
                          IF (Length(s2)>0) AND (IsInteger(s2))
                            THEN ComLegDf^.IndexCount:=StrToInt(s2) ELSE TempResult:=False;
                          IF (ComLegDf^.IndexCount<2) OR (NOT TempResult) THEN
                            BEGIN
                              TempResult:=False;
                              ReportError(Format(Lang(22832),[s]));  //'Datafile %s must contain two KEY-fields'
                            END
                          ELSE
                            BEGIN
                              n:=0;
                              REPEAT
                                INC(n);
                                Delete(s30,1,Pos('@',s30));
                                s2:=Copy(s30,1,Pos('@',s30)-1);
                                IF (Length(s2)=0) OR (NOT IsInteger(s2)) THEN TempResult:=False;
                                IF TempResult THEN ComLegDf^.IndexFields[n]:=StrToInt(s2);
                              UNTIL (n=ComLegDf^.IndexCount) or (NOT TempResult);
                              IF TempResult THEN
                                BEGIN
                                  ValueField:=PeField(ComLegDf^.FieldList.Items[ComLegDf^.IndexFields[1]]);
                                  TextField:= PeField(ComLegDf^.FieldList.Items[ComLegDf^.IndexFields[2]]);
                                END
                              ELSE ReportError(Format(Lang(20128)+#13+Lang(22834),[ComLegDf^.RECFilename]));   //'Error in indexfile of %s. Rebuild index.'
                            END;
                          IF TempResult THEN
                            BEGIN
                              TempResult:=ApplyIndex(ComLegDf);
                              IF NOT TempResult THEN ReportError(Format(Lang(20128)+#13+Lang(22834),[ComLegDf^.RECFilename]))   //'Error in indexfile of %s. Rebuild index.'
                              ELSE
                                BEGIN
                                  InitSortIndex(ComLegDf);
                                  //CloseFile(ComLegDf^.DatFile);
                                  ComLegDf^.Datfile.Free;   //§§§
                                  ComLegDf^.Datfile:=NIL;  //§§§
                                  AssignFile(F2,ComLegDf^.RECFilename);
                                  Reset(F2);
                                  FOR n:=0 TO ComLegDf^.FieldList.Count DO ReadLn(F2,s);
                                  FirstLabel:=true;
                                  tmpLabelRec:=NIL;
                                  FirstLabelRec:=NIL;
                                  FOR CurRec:=1 TO ComLegDf^.NumRecords DO
                                    BEGIN
                                      //eReadOnlyNextRecord(ComLegDf,F2);
                                      eReadOnlyRecord(ComLegDf,F2,ReadIndexNoFromSortIndex(ComLegDf,CurRec));
                                      NextLabelRec:=tmpLabelRec;
                                      New(tmpLabelRec);
                                      tmpLabelRec^.Next:=NIL;
                                      IF FirstLabel THEN
                                        BEGIN
                                          FirstLabelRec:=tmpLabelRec;
                                          FirstLabel:=False;
                                        END
                                      ELSE NextLabelRec^.Next:=tmpLabelRec;
                                      tmpLabelRec^.Value:=Copy(ValueField^.FFieldText,1,30);
                                      tmpLabelRec^.Text:= Copy(TextField^.FFieldText,1,45);
                                    END;  //for CurRec
                                  df^.ValueLabels.AddObject(Labelname,TObject(FirstLabelRec));
                                  AValueLabel:=Labelname;
                                  ACommentLegalRec:=FirstLabelRec;
                                  CloseFile(F2);
                                END;
                            END;
                        END;  //if apply index
                    END;  //if indexfile could be opened
{                  IF TempResult THEN
                    BEGIN
                          {Load labels from datafile}
{                          CloseFile(ComLegDf^.DatFile);
                          AssignFile(F2,ComLegDf^.RECFilename);
                          Reset(F2);
                          FOR n:=0 TO ComLegDf^.FieldList.Count DO ReadLn(F2,s);
                          FirstLabel:=true;
                          tmpLabelRec:=NIL;
                          FirstLabelRec:=NIL;
                          FOR CurRec:=1 TO ComLegDf^.NumRecords DO
                            BEGIN
                              eReadOnlyNextRecord(ComLegDf,F2);
                              NextLabelRec:=tmpLabelRec;
                              New(tmpLabelRec);
                              tmpLabelRec^.Next:=NIL;
                              IF FirstLabel THEN
                                BEGIN
                                  FirstLabelRec:=tmpLabelRec;
                                  FirstLabel:=False;
                                END
                              ELSE NextLabelRec^.Next:=tmpLabelRec;
                              tmpLabelRec^.Value:=Copy(ValueField^.FFieldText,1,14);
                              tmpLabelRec^.Text:= Copy(TextField^.FFieldText,1,32);
                            END;  //for CurRec
                          s:=AnsiLowerCase('Labels from '+ExtractFileName(ComLegDf^.RECFilename));
                          df^.ValueLabels.AddObject(s,TObject(FirstLabelRec));
                          AValueLabel:=s;
                          ACommentLegalRec:=FirstLabelRec;
                          CloseFile(F2);
                        END;
                    END;  //if tempResult}
{                  DisposeDatafilePointer(ComLegDf);
                EXCEPT
                  ReportError(Format(Lang(22836),[s]));   //'Datafile %s could not be applied as a comment legal.~This could be caused by low memory'
//                  {$I-}
//                  CloseFile(F);
//                  n:=IOResult;
//                  {$I+}
{                  TempResult:=False;
                  CurCommand:='';
                  DisposeDatafilePointer(ComLegDf);
                  Exit;
                END;
              END;  //if Comment Legal Datafilename
          END;
      END;  //the word LEGAL was found
    CurCommand:='';
  END;   //RetrieveCommentLegal

  Procedure RetrieveType;
  VAR
    rN:Integer;
  BEGIN
    //Handles TYPE COMMENT, TYPE COMMENT fieldname, TYPE STATUSBAR
    CurCommand:=NextWord(nwSameLine);
    IF CurCommand='' THEN
      BEGIN
        ReportError(Lang(22744));  //'Illegal syntax in TYPE command'
        TempResult:=False;
      END
    ELSE
      BEGIN
        IF AnsiUpperCase(CurCommand)='STATUSBAR' THEN
          BEGIN
            tmpField^.FIsTypeStatusBar:=True;
            CurCommand:=NextWord(nwSameLine);
            df^.TypeStatusBarText:=CurCommand;
            df^.TypeStatusBarColor:=2;   //clBlue;
            CurCommand:=NextWord(nwSameLine);
            IF CurCommand<>'' THEN
              BEGIN
                CurCommand:=AnsiUpperCase(CurCommand);
                FOR rn:=0 TO 17 DO
                  IF CurCommand=ColorNames[rn] THEN df^.TypeStatusBarColor:=rn;
              END;  //if
            df^.TypeStatusBarField:=df^.FocusedField;
          END
        ELSE IF AnsiUpperCase(CurCommand)='COMMENT' THEN
          BEGIN
            {Syntaxes: TYPE COMMENT
                       TYPE COMMENT colour
                       TYPE COMMENT fieldname}
{            tmpField^.FTypeComments:=True;
            tmpField^.FTypeColor:=2;   //clBlue
            //Next word can be either a fieldname or a colour
            //if not a fieldname then next word is interpreted as a colour
            CurCommand:=NextWord(nwSameLine);
            rN:=GetFieldNumber(CurCommand,df);
            IF rN<>-1 THEN
              BEGIN
                {IF (PeField(df^.FieldList.Items[rN])^.Felttype<>ftAlfa)
                AND (PeField(df^.FieldList.Items[rN])^.Felttype<>ftUpperAlfa) THEN
                  BEGIN
                    ReportError(Lang(22838));   //'Can only TYPE COMMENTs to textfields'
                    TempResult:=False;
                  END;}
{                tmpField^.FTypeCommentField:=rN;
                tmpField^.FTypeComments:=False;
                CurCommand:='';
              END;
            IF CurCommand<>'' THEN
              BEGIN
                tmpField^.FTypecolor:=-1;
                FOR rn:=0 TO 17 DO
                  IF AnsiUppercase(CurCommand)=ColorNames[rn] THEN tmpField^.FTypeColor:=rn;
{                IF tmpField^.FTypeColor=-1 THEN
                  BEGIN
                    ReportError(Lang(22745));    //'Unknown fieldname or colour'
                    TempResult:=False;
                  END;}
{              END;  //if CurCommand<>''
            //Read rest of line - compatibility with Epi Info
            REPEAT
              CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
              tmpS:=tmpS+CurCommand;
            UNTIL CurCommand='';
          END  //if Type Comment
        ELSE
          BEGIN
            ReportError(Lang(22744));  //'Illegal syntax in TYPE command'
            TempResult:=False;
          END;
      END;
    CurCommand:='';
  END;   //RetrieveType;

  Procedure RetrieveKeys;
  VAR
    Number,n: Integer;
    IsUnique,Found: Boolean;
  BEGIN
    {Can be KEY
            KEY UNIQUE
            KEY n
            KEY UNIQUE n}
{    IsUnique:=False;
    Number:=0;
    CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
    IF CurCommand='UNIQUE' THEN
      BEGIN
        IsUnique:=True;
        CurCommand:=NextWord(nwSameLine);
        IF CurCommand<>'' THEN
          BEGIN
            IF IsInteger(CurCommand) THEN Number:=StrToInt(CurCommand)
            ELSE
              BEGIN
                ReportError(Lang(22747));   //'Illegal syntax in KEY UNIQUE command'
                TempResult:=False;
              END;
          END;
      END  //if Unique found
    ELSE IF IsInteger(CurCommand) THEN Number:=StrToInt(CurCommand)
    ELSE IF CurCommand<>'' THEN
      BEGIN
        ReportError(Lang(22748));  //'Illegal syntax in KEY command'
        TempResult:=False;
      END;
    IF TempResult THEN
      BEGIN
        //Test if Key number is already used ny FocusedField
        IF (Number>0) AND (Number<=MaxIndices)
          THEN IF df^.IndexFields[Number]=df^.FocusedField THEN
            BEGIN
              tmpField^.FIndex:=Number;
              Exit;
            END;
        //Test if FocusedField occupies a Index-slot
        IF (Number=0) AND (df^.IndexCount=MaxIndices) THEN
          BEGIN
            Found:=False;
            n:=0;
            REPEAT
              INC(n);
              IF df^.IndexFields[n]=df^.FocusedField THEN Found:=True;
            UNTIL (Found) OR (n=MaxIndices);
            IF Found THEN
              BEGIN
                df^.IndexFields[n]:=-1;
                DEC(df^.IndexCount);
              END
            ELSE
              BEGIN
                ReportError(Format(Lang(22750),[MaxIndices]));   //'Only %d KEYs are permitted'
                TempResult:=False;
              END;
          END;
        //Test if Number is within limit
        IF (Number>MaxIndices) OR (Number<0) THEN
          BEGIN
            ReportError(Format(Lang(22752),[MaxIndices]));   //'Illegal KEY number. Only key numbers from 1 to %d are permitted'
            TempResult:=False;
          END;
        IF (Number>=1) AND (Number<=MaxIndices) AND (df^.IndexFields[Number]<>-1) THEN
          BEGIN
            ReportError(Lang(22754));   //'KEY number already used'
            TempResult:=False;
          END;
      END;  //if tempResult
    IF TempResult THEN
      BEGIN
        IF Number=0 THEN
          BEGIN  //Find a slot
            n:=1;
            REPEAT
              IF df^.IndexFields[n]=-1 THEN Number:=n;
              INC(n);
            UNTIL (Number<>0) OR (n>MaxIndices);
            IF Number=0 THEN
              BEGIN
                Number:=1;
                DEC(df^.IndexCount);
              END;
          END;
        INC(df^.IndexCount);
        tmpField^.FIndex:=Number;
        df^.IndexFields[Number]:=df^.FocusedField;
        df^.IndexIsUnique[Number]:=IsUnique;
{        TRY
          df^.Index[Number]:=TStringList.Create;
        EXCEPT
          ErrorMsg(Format(Lang(20204),[664]));  //'Out of memory (ref.code 664)');
          TempResult:=False;
          Exit;
        END;
        IF IsUnique THEN
          BEGIN
            df^.Index[Number].Sorted:=True;
            df^.Index[Number].Duplicates:=dupError;
          END
        ELSE df^.Index[Number].Sorted:=False;}
{      END;  //if TempResult
  END;   //RetrieveKeys


  Procedure AddFieldComment;
  BEGIN
    CurLin:='';
    IF CheckFileMode THEN
      BEGIN
        FieldComments.Text:=tmpField^.FFieldComments;
        FieldComments.Append(ChkLin[CurLinIndex]);
        tmpField^.FFieldComments:=FieldComments.Text;
      END;
  END;  //Procedure AddFieldComment


  Procedure AddFieldFlawComment;
  BEGIN
    IF NOT CheckFileMode THEN TempResult:=False;
    IF NOT MultiLineError THEN TempResult:=False;
    CommentsAddedToCheckFile:=True;
    CurLin:='';
    ReportError(Lang(22733));   //'Unknown command'
//    {$IFNDEF epidat}
{    IF (FirstFieldFlaw) AND (CheckFileMode) AND (MultiLineError) THEN
      BEGIN
        FirstFieldFlaw:=False;
        IF eDlg(Format(Lang(22820),    //Unknown command found in fieldblock in checkfile %s
           [ExtractFilename(df^.CHKFilename)])+#13#13+
           Lang(22822)+#13+      //'Do you want to save unknown checkcommands found in fieldblocks'
           Lang(22824)+#13#13+   //'as commentlines in the fieldblock?'
           Lang(22826)+#13+      //'If you choose No then unknown commands in fieldblocks will'
           Lang(22828),         //'be deleted when the revised checks are saved.'
           mtWarning,[mbYes,mbNo],0)=mrYes THEN SaveFieldFlawsAsComments:=True;
        Screen.Cursor:=crHourGlass;
      END;  //FirstTopFlaw
    {$ENDIF}
{    IF SaveFieldFlawsAsComments THEN
      BEGIN
        ChkLin[CurLinIndex]:='* '+ChkLin[CurLinIndex];
        AddFieldComment;
      END;
  END;  //procedure AddFieldFlawComment

  Procedure HandleBooleanConditions(VAR s:String);
  VAR
    ts,FieldS: String;
    Hn,Hn2: Integer;
    tmpFieldType: TFeltTyper;
    HtmpDefVar: PDefVar;
    HFound: Boolean;

  BEGIN
    REPEAT
      ts:='';
      IF pos('="Y"',s)>0 THEN ts:='="Y"';
      IF pos('= "Y"',s)>0 THEN ts:='= "Y"';
      IF pos('="N"',s)>0 THEN ts:='="N"';
      IF pos('= "N"',s)>0 THEN ts:='= "N"';
      IF ts<>'' THEN
        BEGIN
          Hn:=pos(ts,s);
          fieldS:='';
          //Get name of field that is assigned to
          Hn2:=Hn;
          REPEAT
            HFound:=False;
            DEC(Hn2);
            IF Hn2>0 THEN
              BEGIN
                IF (s[Hn2] in AlfaNumChars) OR (s[Hn2]=' ') THEN
                  BEGIN
                    fieldS:=s[Hn2]+FieldS;
                    HFound:=True;
                  END;
              END;
          UNTIL (not HFound) or (Hn2<1);
          HFound:=False;
          FieldS:=Trim(FieldS);
          IF FieldS<>'' THEN
            BEGIN
              //is FieldS a boolean field?
              tmpFieldType:=ftInteger;
              Hn2:=GetFieldNumber(FieldS,df);
              IF Hn2<>-1 THEN tmpFieldtype:=PeField(df^.FieldList.Items[Hn2])^.Felttype
              ELSE
                BEGIN
                  HtmpDefVar:=GetDefField(FieldS,df);
                  IF HtmpDefVar<>NIL THEN tmpFieldtype:=HtmpDefVar^.Felttype;
                END;
              IF tmpFieldType=ftBoolean THEN
                BEGIN
                  //Found a boolean field that is testet against "Y" or "N"
                  Delete(s,Hn,Length(ts));
                  IF ts='="Y"'  THEN insert('=True',s,Hn);
                  IF ts='= "Y"' THEN insert('= True',s,Hn);
                  IF ts='="N"'  THEN insert('=False',s,Hn);
                  IF ts='= "N"' THEN insert('= False',s,Hn);
                  HFound:=True;
                END;  //if tmpFieldType=ftBoolean
            END;  //if FieldS<>'
          IF NOT HFound THEN s[Hn]:=#254;
        END;  //if ts<>''
    UNTIL (ts='');
    WHILE Pos(Chr(254),s)>0 DO s[Pos(#254,s)]:='=';
  END;  //procedure HandleBooleanConditions



  Procedure GetCommand(VAR CmdList:TList);
  VAR
    cmd:Commands;
    tmpCmdRec:TCmds;
    SeenElse,ok,found,IsEpiInfo,ImplicitLet,glob_dub:Boolean;
    tmpCmdPtr:PCmds;
    n,n2:Integer;
    tmpStr:String[20];
    s1,s2:String[200];
    tmpS,tmpS2:String;   //&&
    tmpDefVar: PDefVar;
    AInfo,BInfo: PRelateInfo;
    bb,bb2,bb3:byte;
    tmpTxtColor,tmpBgColor: TColor;
  BEGIN
    {Legal commands are
      IF <boolean expr.> THEN  <cmds> [ELSE <cmds>] ENDIF
      HELP "..." [Type=Information|Warning|Confirmation|Error]
      HIDE [fieldname]
      UNHIDE [fieldname]
      CLEAR [fieldname]
      GOTO [fieldname]
      COMMENT LEGAL
      EXIT
      DEFINE
      AUTOSAVE
      CONFIRM [fieldname]
      IGNOREMISSING
      TYPE "kjkj"
      RELATE fieldname filename [1]
      BACKUP dest_library
      BACKGROUNDCOLOUR
      BEEP [WARNING|CONFIRMATION]
      [LET] Fieldname=expression
      * (Comments)
    }
{    IF (AnsiUpperCase(CurCommand)='END')
    or (AnsiUpperCase(CurCommand)='ENDIF')
    or (AnsiUpperCase(CurCommand)='ELSE') or (CurCommand='') THEN Exit;
    ok:=True;
    IF CurCommand[1]='*' THEN
      BEGIN
        cmd:=cmdComment;
        tmpCmdRec.Command:=cmd;
      END
    ELSE
      BEGIN
        cmd:=cmdIF;
        WHILE (cmd<cmdLET) AND (CommandNames[Cmd]<>AnsiUpperCase(CurCommand)) DO cmd:=Succ(Cmd);
        IF (CommandNames[Cmd]<>AnsiUpperCase(CurCommand))
        or (AnsiUpperCase(CurCommand)='LET') THEN
          BEGIN
            //check if unknown CurCommand is implicit LET
            //s1:=AnsiUppercase(trim(CurCommand+' '+CurLin));
            s1:=trim(CurCommand+' '+CurLin);
            CurLin:='';
            IF AnsiUpperCase(Copy(s1,1,3))='LET' THEN
              BEGIN
                Delete(s1,1,3);  //remove LET
                ImplicitLET:=FALSE;
              END
            ELSE ImplicitLET:=True;
            {Rules for valid LET:
             1. A '=' is present
             2. A fieldname or var-name is present before '='
             3. A valid expression is found after '='}
{            n:=1;
            s2:=s1;
            n:=pos('=',s2);
            IF n=0 THEN ok:=False
            ELSE IF n=1 THEN
              BEGIN
                ReportError(Lang(22756));  //'Missing field- or variablename to the left of the equal-sign'
                ok:=False
              END
            ELSE
              BEGIN
                tmpStr:=trim(Copy(s2,1,n-1));
                //Check if tmpStr contains a fieldname or variablename
                n:=GetFieldNumber(tmpStr,df);
                tmpDefVar:=NIL;
                IF n=-1 THEN tmpDefVar:=GetDefField(tmpStr,df);
                IF (n=-1) AND (tmpDefVar=NIL) THEN
                  BEGIN
                    ReportError(Lang(22758));  //'Unknown field- or variablename to the left of the equal-sign'
                    ok:=False;
                  END
              END; //if '=' found in a legal position
            IF ok THEN
              BEGIN
                WITH tmpCmdRec DO
                  BEGIN
                    Command:=cmdLET;
                    CodedWithLET:=NOT ImplicitLET;
                    IF GetDefField(tmpStr,df)=NIL THEN VarIsField:=True ELSE VarIsField:=False;
                    VarNumber:=n;
                    VarName:=tmpStr;
                    tmpS:=trim(Copy(s2,Pos('=',s2)+1,Length(s2)));
                    Double2SingleQuotes(tmpS);
//                    IF tmpS='.' THEN tmpS:='_M';
                    LetExpr:=tmpS;
                  END;  //with
                cmd:=cmdLET;
                ImplicitLet:=True;
              END
            ELSE
              BEGIN  // Unknown command was not a LET
                AddFieldFlawComment;
                Exit;
              END;
          END
        ELSE tmpCmdRec.Command:=cmd;
      END;  //else

    ok:=true;
    CASE cmd OF
      cmdIF:
        BEGIN
          tmpCmdRec.IfExpr:='';
          tmpCmdRec.IfCmds:=NIL;
          tmpCmdRec.ElseCmds:=NIL;
          REPEAT
            CurCommand:=NextWord(nwSameKeepQuotes);
            tmpCmdRec.IfExpr:=tmpCmdRec.IfExpr+' '+CurCommand;
          UNTIL (AnsiUpperCase(CurCommand)='THEN') or (CurCommand='');
          IF AnsiUpperCase(CurCommand)='THEN' THEN
            BEGIN
             tmpCmdRec.IfExpr:=tmpCmdRec.IfExpr+' ';
             Delete(tmpCmdRec.IfExpr,
             Pos(' THEN ',AnsiUpperCase(tmpCmdRec.IfExpr)),6);
            END
          ELSE
            BEGIN  //no THEN was found in same line as expression
              CurCommand:=NextWord(nwAny);
              IF AnsiUpperCase(CurCommand)<>'THEN' THEN
                BEGIN
                  ReportError(Lang(22760));  //'No THEN found after IF'
                  ok:=False;
                END;
            END;
          tmpS:=trim(tmpCmdRec.IfExpr);
          tmpCmdRec.IfShowExpr:=tmpS;
          HandleBooleanConditions(tmpS);
          Double2SingleQuotes(tmpS);
          //Assign If-expression
          tmpCmdRec.IfExpr:='('+trim(tmpS)+')';
          IF ok THEN
            BEGIN
              SeenElse:=False;
              REPEAT
                CurCommand:=NextWord(nwAny);
                IF AnsiUpperCase(CurCommand)='ELSE' THEN
                  BEGIN
                    SeenElse:=True;
                    CurCommand:='ELSE'
                  END;
                IF SeenElse THEN GetCommand(tmpCmdRec.ElseCmds)
                ELSE GetCommand(tmpCmdRec.IfCmds);
              UNTIL (AnsiUpperCase(CurCommand)='ENDIF') OR (EndOfChkFile)
              OR (AnsiUpperCase(CurCommand)='END');
              IF (EndOfChkFile) AND (AnsiUpperCase(CurCommand)<>'ENDIF') THEN
                BEGIN
                  ReportError(Lang(22762));   //'IF..THEN command without ENDIF'
                  ok:=False;
                END;
              IF AnsiUpperCase(CurCommand)='END' THEN
                BEGIN
                  ReportError(Lang(22764));  //'ENDIF expected but END found'
                  ok:=False;
                END;
              CurCommand:='';
            END;
        END;
      cmdHelp:
        BEGIN
          CurCommand:=NextWord(nwSameLine);
          REPEAT
            n:=pos('\n',CurCommand);
            IF n=0 THEN n:=pos('\N',CurCommand);
            IF n>0 THEN
              BEGIN
                CurCommand[n]:=' ';
                CurCommand[n+1]:=#13;
              END;
          UNTIL n=0;
          tmpCmdRec.HelpString:=CurCommand;
          tmpCmdRec.HelpType:=mtInformation;
          tmpCmdRec.HelpKeys:='';
          CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
          IF CurCommand<>'' THEN
            BEGIN
              IF (Copy(CurCommand,1,6)='KEYS="')
              AND (Length(CurCommand)>7)
              AND (CurCommand[Length(CurCommand)]='"') THEN
                BEGIN
                  tmpS:=Copy(CurCommand,7,Length(CurCommand)-7);
                  tmpCmdRec.HelpKeys:=Copy(tmpS,1,10);
                END;
            END;
          IF AnsiUpperCase(Copy(CurCommand,1,4))<>'TYPE'
          THEN CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
          tmpS:='';
          WHILE CurCommand<>'' DO
            BEGIN
              tmpS:=tmpS+CurCommand;
              CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
            END;
          IF (tmpS='TYPE=ERROR') OR (tmpS='TYPE=E') THEN tmpCmdRec.HelpType:=mtError
          ELSE IF (tmpS='TYPE=WARNING') OR (tmpS='TYPE=W') THEN tmpCmdRec.HelpType:=mtWarning
          ELSE IF (tmpS='TYPE=CONFIRMATION') OR (tmpS='TYPE=C') THEN tmpCmdRec.HelpType:=mtConfirmation;
          CurCommand:='';
        END;  //case cmdHelp
      cmdHide,cmdUnhide,cmdClear,cmdGoto:
        BEGIN
          //Check if a fieldname exists after command
          ok:=True;
          CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
          IF CurCommand<>'' THEN
            BEGIN
              n:=-1;
              Found:=False;
              IF ( (CurCommand='WRITE') OR (CurCommand='WRITEREC') ) AND (cmd=cmdGoto) THEN
                BEGIN
                  tmpCmdRec.HideVarName:='WRITE';
                  tmpCmdRec.HideVarNumber:=-1;
                END
              ELSE
                BEGIN
                  WHILE (n<df^.FieldList.Count-1) AND (NOT Found) DO
                    BEGIN
                      INC(n);
                      IF CurCommand=AnsiUpperCase(trim(
                        PeField(df^.FieldList.Items[n])^.FName))
                      THEN Found:=True;
                    END;
                  IF (NOT Found) AND (CurCommand='COMMENT') THEN
                    BEGIN
                      CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
                      IF CurCommand='LEGAL' THEN
                        BEGIN
                          Found:=True;
                          tmpCmdRec.HideVarName:='$$COMLEG';
                          tmpCmdRec.HideVarNumber:=df^.FocusedField;
                        END;
                    END;
                  IF NOT Found THEN
                    BEGIN
                      ok:=False;
                      ReportError(Lang(22708));  //'Unknow fieldname.'
                    END
                  ELSE IF tmpCmdRec.HideVarName<>'$$COMLEG' THEN
                    BEGIN
                      tmpCmdRec.HideVarName:=trim(PeField(df^.FieldList.Items[n])^.FName);
                      tmpCmdRec.HideVarNumber:=n;
                    END;  //else
                END;  //if not GOTO WRITE | GOTO END
            END  //if a word was found after Hide/Unhide
          ELSE
            BEGIN
              tmpCmdRec.HideVarNumber:=df^.FocusedField;
              tmpCmdRec.HideVarName:=
                trim(PeField(df^.FieldList.Items[df^.FocusedField])^.FName);
            END;
        END;  //case cmdHide or cmdUnhide
      cmdComLegal:
        BEGIN
          tmpCmdRec.CommentLegalRec:=NIL;
          RetrieveCommentLegal(tmpCmdRec.ValueLabel,tmpCmdRec.CommentLegalRec,tmpCmdRec.ShowList,True);
          tmpCmdRec.clVarNumber:=df^.FocusedField;
//          IF tmpCmdRec.CommentLegalRec=NIL THEN ok:=False;
        END;  //case cmdComLegal
      cmdComment:
        BEGIN
          IF Length(CurCommand)>200 THEN CurCommand:=Copy(CurCommand,1,200);
          tmpCmdRec.Comment:=CurCommand;
        END;
      cmdDefine:
        BEGIN
          //get variable name
          CurCommand:=NextWord(nwSameLine);
          IF CurCommand='' THEN
            BEGIN
              ok:=False;
              ReportError(Lang(22766));  //'DEFINE without variablename'
            END
          ELSE IF Length(CurCommand)>16 THEN
            BEGIN
              ok:=False;
              ReportError(Lang(22768));  //'Variablename can be only 16 characters in DEFINE'
            END
          ELSE IF GetFieldNumber(CurCommand,df)<>-1 THEN
            BEGIN
              ok:=False;
              ReportError(Lang(22770));  //'Dublicate name: The variablename is used by a entryfield'
            END;
          {ELSE IF (GetDefField(CurCommand,df)<>NIL) AND (MultiLineError) THEN
            BEGIN
              ok:=False;
              ReportError(Lang(22772));  //'Dublicate name: The variablename is allready used'
            END;}
{          IF ok THEN
            BEGIN
              tmpCmdRec.FName:=CurCommand;
              tmpCmdRec.FNumDecimals:=0;
              //Variable name passed all tests - now get the fieldtype
              CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
              IF CurCommand='' THEN
                BEGIN
                  ok:=False;
                  ReportError(Lang(22774));  //'Fieldtype missing in DEFINE command'
                END
              ELSE
                BEGIN
                  tmpCmdRec.FLength:=Length(CurCommand);
                  IF CurCommand[1]='#' THEN
                    BEGIN
                      n2:=0;
                      FOR n:=1 TO Length(CurCommand) DO
                        BEGIN
                          IF (CurCommand[n]<>'#') AND (CurCommand[n]<>'.') THEN ok:=False;
                          IF CurCommand[n]='.' THEN INC(n2);
                        END;
                      IF (NOT ok) OR (n2>1) THEN
                        BEGIN
                          ok:=False;
                          ReportError(Lang(22776));  //'Error in fieldtype. Use # and maximum one . to define numeric'
                        END
                      ELSE
                        BEGIN
                          IF (n2>0) OR (Length(CurCommand)>4) THEN tmpCmdRec.Felttype:=ftFloat
                          ELSE tmpCmdRec.Felttype:=ftInteger;
                          IF n2>0 THEN tmpCmdRec.FNumDecimals:=Length(CurCommand)-Pos('.',CurCommand)
                          ELSE tmpCmdRec.FNumDecimals:=0;
                        END;
                    END  //if numeric
                  ELSE IF CurCommand[1]='_' THEN tmpCmdRec.Felttype:=ftAlfa
                  ELSE IF CurCommand='<MM/DD/YYYY>' THEN tmpCmdRec.Felttype:=ftDate
                  ELSE IF Copy(CurCommand,1,2)='<A' THEN
                    BEGIN
                      tmpCmdRec.Felttype:=ftUpperAlfa;
                      tmpCmdRec.FLength:=Length(CurCommand)-2;
                    END
                  ELSE IF Copy(Curcommand,1,2)='<S' THEN
                    BEGIN
                      tmpCmdRec.Felttype:=ftSoundex;
                      tmpCmdRec.FLength:=Length(CurCommand)-2;
                    END
                  ELSE IF CurCommand='<Y>' THEN tmpCmdRec.Felttype:=ftBoolean
                  ELSE IF CurCommand='<DD/MM/YYYY>' THEN tmpCmdRec.Felttype:=ftEuroDate
                  ELSE IF CurCommand='<YYYY/MM/DD>' THEN tmpCmdRec.Felttype:=ftYMDDate    //&&
                  ELSE
                    BEGIN
                      //No legal fieldtype found
                      ok:=False;
                      ReportError(Lang(22778));  //'Illegal fieldtype in DEFINE command'
                    END;
                  IF ok THEN
                    BEGIN
                      CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
                      IF CurCommand='' THEN tmpCmdRec.FScope:=scLocal
                      ELSE IF CurCommand[1]='G' THEN tmpCmdRec.FScope:=scGlobal
                      ELSE IF CurCommand[1]='C' THEN tmpCmdRec.FScope:=scCumulative
                      ELSE
                        BEGIN
                          ok:=False;
                          ReportError(Lang(22780));  //'Illegal scope in DEFINE command. Use GLOBAL or CUMULATIVE'
                        END;
                      IF ok THEN
                        BEGIN
                          //All data concerning the DEFINE is read
                          //Now check is DEF-name is allready used
                          //Ignore the DEF if DEF is global and a global def-field with the
                          //same fieldtype exists
                          glob_dub:=False;
                          tmpDefVar:=GetDefField(tmpCmdRec.FName,df);
                          IF tmpDefVar<>NIL THEN
                            BEGIN
                              //a DEF-var with same name exists
                              IF (tmpCmdRec.FScope<>scGlobal) OR (tmpDefVar^.FScope<>scGlobal) AND (MultiLineError) THEN
                                BEGIN
                                  ok:=False;
                                  ReportError(Lang(22772));  //'Dublicate name: The variablename is allready used'
                                END;
                              IF (tmpCmdRec.FScope=scGlobal) AND (tmpDefVar^.FScope=scGlobal) THEN
                                BEGIN
                                  IF NOT ( (tmpCmdRec.Felttype=tmpDefVar^.Felttype)       AND
                                       (tmpCmdRec.FLength=tmpDefVar^.FLength)             AND
                                       (tmpCmdRec.FNumDecimals=tmpDefVar^.FNumDecimals) ) THEN
                                    BEGIN
                                      ok:=False;
                                      ReportError('A global DEFINE with same fieldname but different fieldtype or length is allready defined');
                                    END;
                                END;
                            END;
                          IF (df^.DefList=NIL) AND (tmpCmdRec.FScope<>scGlobal) THEN df^.DefList:=TStringList.Create;
//                          tmpDefVar:=GetDefField(tmpCmdRec.FName,df);
//                          IF (NOT MultiLineError) AND (tmpDefVar<>NIL)
//                          THEN tmpDefVar:=PDefVar(df^.DefList.Objects[n])
                          n:=-1;
                          IF tmpDefVar=NIL THEN New(tmpDefVar) ELSE n:=0;
                          tmpDefVar^.FName:=        tmpCmdRec.FName;
                          tmpDefVar^.Felttype:=     tmpCmdRec.Felttype;
                          tmpDefVar^.FLength:=      tmpCmdRec.FLength;
                          tmpDefVar^.FNumDecimals:= tmpCmdRec.FNumDecimals;
                          tmpDefVar^.FScope:=       tmpCmdRec.FScope;
                          tmpDefVar^.FFieldText:=   '';
                          IF n=-1 THEN
                            BEGIN
                              IF tmpCmdRec.FScope<>scGlobal
                              THEN df^.DefList.AddObject(tmpCmdRec.FName,TObject(tmpDefVar))
                              ELSE GlobalDefList.AddObject(tmpCmdRec.FName,TObject(tmpDefVar));
                            END;
                        END;
                    END;  //if ok - look for scope
                END;  //if fieldtype was present
            END;  //if (variablename is) ok
        END;  //case cmdDefine.
      cmdAutosave: df^.AutoSave:=True;
      cmdConfirm:  df^.Confirm:=True;
      cmdIgnoreMissing: MissingAction:=maIgnoreMissing;
      cmdTypeString:
        BEGIN
          //Syntax: TYPE "text" [colour]
          CurCommand:=NextWord(nwSameLine);
          IF (AnsiUpperCase(CurCommand)='COMMENT') OR (AnsiUpperCase(CurCommand)='STATUSBAR') THEN
            BEGIN
              ReportError(Lang(22741));    //'Command not legal in IF, AFTER ENTRY, and BEFORE ENTRY blocks'
              ok:=False;
            END
          ELSE IF CurCommand='' THEN
            BEGIN
              ReportError(Lang(22746));   //'Text to TYPE is missing'
              ok:=False;
            END
          ELSE
            BEGIN
              tmpCmdRec.tsVarNumber:=df^.FocusedField;
              IF Length(CurCommand)>40 THEN tmpCmdRec.TypeText:=Copy(CurCommand,1,40)
              ELSE tmpCmdRec.TypeText:=CurCommand;
              //Get a colour - if present
              CurCommand:=NextWord(nwSameLine);
              tmpCmdRec.TypeColor:=2;
              IF CurCommand<>'' THEN
                BEGIN
                  tmpCmdRec.TypeColor:=-1;
                  FOR n:=0 TO 17 DO
                    IF AnsiUppercase(CurCommand)=ColorNames[n] THEN tmpCmdRec.TypeColor:=n;
                  IF tmpCmdRec.TypeColor=-1 THEN
                    BEGIN
                      ReportError(Lang(22743));   //'Unknown colour'
                      ok:=False;
                    END;
                  //Read rest of line - compatibility with Epi Info
                  REPEAT
                    CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
                    tmpS:=tmpS+CurCommand;
                  UNTIL CurCommand='';
                END;  //if CurCommand<>''
              IF ok THEN tmpField.FTypeString:=True;
            END;
        END;  //case cmdTypeString
      cmdBeep:
        BEGIN
          CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
          tmpCmdRec.BeepType:=btStandard;
          IF CurCommand<>'' THEN
            BEGIN
              IF (CurCommand='WARNING') OR (CurCommand='W') THEN tmpCmdRec.BeepType:=btWarning
              ELSE IF (CurCommand='CONFIRMATION') OR (CurCommand='C') THEN tmpCmdRec.BeepType:=btConfirmation;
            END;
        END;  //cmdBeep
      cmdLoad:
        BEGIN
          //Syntax: LOAD [path\]dllname[.dll]
          CurCommand:=NextWord(nwSameLine);
          IF Length(Curcommand)>200 THEN CurCommand:=Copy(CurCommand,1,200);
          IF CurCommand='' THEN
            BEGIN
              ReportError(Format(Lang(22126),[CurCommand]));   //22126=The file %s does not exist.
              ok:=False;
            END
          ELSE
            BEGIN
              IF ExtractFileExt(CurCommand)='' THEN CurCommand:=CurCommand+'.DLL';
              IF ExtractFilePath(CurCommand)='' THEN
                BEGIN
                  //No path specified - search for file in rec-file's dir. and in EpiData.exe's dir
                  tmpS:=ExtractFilePath(df^.RECFilename)+CurCommand;
                  IF (NOT FileExists(tmpS)) THEN tmpS:=ExtractFilePath(Application.ExeName)+CurCommand;
                END
              ELSE tmpS:=CurCommand;
              IF (NOT FileExists(tmpS)) THEN
                BEGIN
                  ReportError(Format(Lang(22126),[tmpS]));   //22126=The file %s does not exist.
                  ok:=False;
                END;
            END;
          IF ok THEN
            BEGIN
              // DLL file found either by path or in REC-dir og EXE-dir
              // Now save the DLLname and call the function that loads the DLL
              // CHECK IF DLL IS ALREADY LOADED ?
              tmpCmdRec.DLLName:=tmpS;
              // salah entry point here!
              EpiLoadModule(tmpCmdRec.DLLName,df^.ModuleInfo);
              // 1. Create UDF List Structure
              df^.UDFList:=TEpiExternalUDFList.Create;
              // 2. 'Interview module' - call fill....
              df^.UDFList.FillFromDLLHandle(df^.ModuleInfo);
            END;
        END;
      cmdWriteNote:
        BEGIN
          //Syntax: WRITENOTE "notetext" [SHOW]
          CurCommand:=NextWord(nwSameLine);
          IF Length(CurCommand)>200 THEN CurCommand:=Copy(CurCommand,1,200);
          REPEAT
            n:=pos('\n',CurCommand);
            IF n=0 THEN n:=pos('\N',CurCommand);
            IF n>0 THEN
              BEGIN
                CurCommand[n]:=' ';
                CurCommand[n+1]:=#13;
              END;
          UNTIL n=0;
          tmpCmdRec.FNote:=CurCommand;
          CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
          IF CurCommand='SHOW' THEN tmpCmdRec.ShowNotes:=True ELSE tmpCmdRec.ShowNotes:=False;
        END;
      cmdExecute:
        BEGIN
          {Syntax: EXECUTE "exe-file name"|* "Parameters"|* NOWAIT|WAIT [HIDE]   }
          {
          Execute bla.htm WAIT
          Execute opera bla.htm WAIT

          }
{          CurCommand:=NextWord(nwSameLine);
          IF CurCommand='' THEN
            BEGIN
              ReportError(Lang(22854));  //22854=Exe-filename or document-filename is required
              OK:=False;
            END;
          tmpCmdRec.ExecCmdLine:=CurCommand;    //=InsertFieldContents(df,CurCommand);
          //Read next: can be parameters or NOWAIT|WAIT
          CurCommand:=NextWord(nwSameLine);
          tmpCmdRec.ExecParams:='';
          IF (AnsiUpperCase(CurCommand)<>'WAIT') AND (AnsiUpperCase(CurCommand)<>'NOWAIT') THEN
            BEGIN
              //Assume CurCommand contains parameter(s)
              tmpCmdRec.ExecParams:=CurCommand;
              CurCommand:=NextWord(nwSameLine);
            END;
          CurCommand:=AnsiUpperCase(CurCommand);
          IF (CurCommand<>'WAIT') AND (CurCommand<>'NOWAIT') THEN
            BEGIN
              ReportError(Lang(22856));  //22856=WAIT or NOWAIT is required
              ok:=False;
            END
          ELSE tmpCmdRec.ExecWait:=(CurCommand='WAIT');

          IF ok THEN
            BEGIN
              CurCommand:=ANSIupperCase(NextWord(nwSameLine));
              tmpCmdRec.ExecHide:=(CurCommand='HIDE');
            END;
        END;
      cmdColor:
        BEGIN
          {Syntax: COLOR QUESTION colors
                   COLOR DATA colors
                   COLOR BACKGROUND color
                   COLOR fieldname datacolors questioncolors

                   Colors can be Epi Info color codes
                   or EpiData color words}

{          CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
          tmpCmdRec.TxtColor:=255;
          tmpCmdRec.BgColor:=255;
          IF CurCommand='QUESTION' THEN tmpCmdRec.ColorCmd:=1
          ELSE IF CurCommand='DATA' THEN tmpCmdRec.ColorCmd:=2
          ELSE IF CurCommand='BACKGROUND' THEN tmpCmdRec.ColorCmd:=3
          ELSE
            BEGIN
              //could be COLOR fieldname
              //will be added later
              ReportError(Lang(22858));  //22858=Unknown COLOR command
              ok:=False;
            END;
          IF tmpCmdRec.ColorCmd=3 THEN
            BEGIN
              //command is BACKGROUND
              CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
              IF IsInteger(CurCommand) THEN
                BEGIN
                  tmpCmdRec.IsEpiInfoNo:=True;
                  n:=StrToInt(CurCommand);
                  IF (n<0) OR (n>7) THEN
                    BEGIN
                      ReportError(Lang(22860));   //22860=Illegal COLOR number
                      ok:=False;
                    END
                  ELSE tmpCmdRec.BgColor:=n;
                END
              ELSE
                BEGIN
                  tmpCmdRec.IsEpiInfoNo:=False;
                  tmpCmdRec.BgColor:=255;
                  FOR n:=0 TO 17 DO
                    IF CurCommand=ColorNames[n] THEN tmpCmdRec.BgColor:=n;
                  IF tmpCmdRec.BgColor=255 THEN
                    BEGIN
                      ReportError(Lang(22858));  //22858=Unknown COLOR command
                      ok:=False;
                    END;
                END;
            END
          ELSE
            BEGIN
              //read rest of line
              tmpS:='';
              REPEAT
                CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
                tmpS:=tmpS+CurCommand+' ';
              UNTIL CurCommand='';
              IF GetColors(tmpS,bb,bb2,bb3,IsEpiInfo) THEN
                BEGIN
                  tmpCmdRec.TxtColor:=bb;
                  tmpCmdRec.BgColor:=bb2;
                  tmpCmdRec.IsEpiInfoNo:=IsEpiInfo;
                  IF bb3<>255 THEN
                    BEGIN
                      //highlightcolor specified
                      df^.FieldHighlightAct:=True;
                      df^.FieldHighlightCol:=ColorValues[bb3];
                    END;
                END
              ELSE
                BEGIN
                  ReportError(Lang(22862));  //22862=Unknown color in COLOR command
                  ok:=False;
                END;
            END;
        END;
      cmdBackup:
        BEGIN
          //syntax: BACKUP "destination-libray"
          IF (CheckFileMode) AND (cmdList<>df^.AfterFileCmds) THEN
            BEGIN
              ReportError(Lang(22864));  //22864=BACKUP command only legal in AFTER FILE blocks
              ok:=False;
            END
          ELSE
            BEGIN
              CurCommand:=NextWord(nwSameLine);
              IF CurCommand='' THEN
                BEGIN
                  ReportError(Lang(22866));  //22866=BACKUP command without destination directory
                  ok:=False;
                END
              ELSE IF (df^.BackupList=NIL) AND (NOT df^.IsRelateFile) THEN
                BEGIN
                  tmpCmdRec.DestLib:=CurCommand;
                  df^.BackupList:=TStringList.Create;
                  df^.BackupList.Append(CurCommand);
                  df^.BackupList.Append(df^.RECFilename);
                END;
            END;
        END;
      cmdRelate:
        BEGIN
          //Syntax: RELATE fieldname filename [1]
          //Get fieldname
          CurCommand:=NextWord(nwSameLine);
          IF CurCommand='' THEN
            BEGIN
              ReportError(Lang(22840));   //'Error in RELATE command'
              ok:=False;
            END
          ELSE
            BEGIN
              n:=GetFieldNumber(CurCommand,df);
              IF n=-1 THEN
                BEGIN
                  ReportError(Lang(22708));   //'Unknown fieldname'
                  ok:=False;
                END
              ELSE
                BEGIN
                  //Check if field is KEY UNIQUE
                  IF n=df^.FocusedField THEN
                    BEGIN
                      n2:=tmpField^.FIndex;
                      IF n2=0 THEN ok:=FALSE
                      ELSE IF df^.IndexIsUnique[n2]=False THEN ok:=False;
                    END
                  ELSE
                    BEGIN
                      n2:=PeField(df^.FieldList.Items[n])^.FIndex;
                      IF n2=0 THEN ok:=False
                      ELSE IF df^.IndexIsUnique[n2]=False THEN ok:=False;
                    END;
                  IF NOT ok THEN ReportError(Lang(22842));  //'RELATE field must be KEY UNIQUE'
                END;
            END;
          IF ok THEN
            BEGIN
              //Get relatefile name
              tmpCmdRec.RelField:=PeField(df^.FieldList.Items[n])^.FName;  //save fieldname
              n2:=n;  //save fieldnumber to use with relateinfo
              Curcommand:=NextWord(nwSameLine);
              IF CurCommand='' THEN
                BEGIN
                  ReportError(Lang(22840));   //'Error in RELATE command'
                  ok:=False;
                END
              ELSE
                BEGIN
                  tmpS:=CurCommand;
                  IF ExtractFileExt(tmpS)='' THEN tmpS:=tmpS+'.rec';
                  IF ExtractFileExt(tmpS)<>'.REC' THEN ChangeFileExt(tmpS,'.rec');
                  tmpS2:=GetCurrentDir;   //&&
                  SetCurrentDir(ExtractFileDir(df^.RECFilename));
                  tmpS:=ExpandFilename(tmpS);              //&&
                  SetCurrentDir(tmpS2);
                  //IF ExtractFilePath(tmpS)='' THEN tmpS:=ExtractFilePath(df^.RECFilename)+tmpS;
                  tmpS:=AnsiLowerCase(tmpS);
                  IF (NOT FileExists(tmpS)) AND (MultiLineError) THEN
                    BEGIN
                      ReportError(Format(Lang(22126),[tmpS]));   //22126=The file %s does not exist.
                      ok:=False;
                    END
                  ELSE
                    BEGIN
                      IF NOT Assigned(RelateFiles) THEN RelateFiles:=TStringList.Create;
                      IF NOT Assigned(RelateMothers) THEN RelateMothers:=TList.Create;
                      n:=RelateFiles.IndexOf(Curcommand);
                      IF n=-1 THEN
                        BEGIN
                          RelateFiles.AddObject(tmpS,NIL);
                          RelateMothers.Add(Pointer(df));
                        END
                      ELSE RelateMothers.Items[n]:=Pointer(df);
                      tmpCmdRec.RelFileNo:=RelateFiles.IndexOf(tmpS);
                      tmpCmdRec.RelFileStr:=CurCommand;
                      New(AInfo);
                      //Fill out relatefile information
                      AInfo^.RelFileNo:=tmpCmdRec.RelFileNo;
                      AInfo^.RelFieldNo:=n2;
                      AInfo^.CmdInFieldNo:=df^.FocusedField;
                      AInfo^.Next:=NIL;
                      //Link relatefile information to chain of relatefile infos
                      IF df^.RelateInfo=NIL THEN df^.RelateInfo:=AInfo
                      ELSE
                        BEGIN
                          BInfo:=df^.RelateInfo;
                          WHILE BInfo^.Next<>NIL DO BInfo:=BInfo^.Next;
                          BInfo^.Next:=AInfo;
                        END;
                      //df^.RelateInfo:=df^.RelateInfo+'"Relates to '+ExtractFilename(tmpS)+'","'+
                      //'via '+tmpCmdRec.RelField+'","",';
                      df^.HasRelate:=True;
                    END;
                END;
            END;
          IF ok THEN
            BEGIN
              //Get One2One marker
              CurCommand:=NextWord(nwSameLine);
              tmpCmdRec.One2One:=(CurCommand='1');
              AInfo^.One2One:=tmpCmdRec.One2One;
            END;
          CurCommand:='';
        END;   //case cmdRelate
    END;  //Case
    IF ok THEN
      BEGIN
        IF CmdList=NIL THEN CmdList:=TList.Create;
        New(tmpCmdPtr);
        tmpCmdPtr^:=tmpCmdRec;
        CmdList.Add(tmpCmdPtr);
        IF (CmdList=df^.BeforeFileCmds) AND (tmpCmdRec.Command=cmdColor) THEN
          BEGIN
            IF tmpCmdRec.IsEpiInfoNo THEN
              BEGIN
                IF tmpCmdRec.TxtColor<>255 THEN tmpTxtColor:=TextColors[tmpCmdRec.TxtColor] ELSE tmpTxtColor:=COLOR_ENDCOLORS;
                IF tmpCmdRec.BgColor<>255 THEN tmpBgColor:=BgColors[tmpCmdRec.BgColor] ELSE tmpBgColor:=COLOR_ENDCOLORS;
              END
            ELSE
              BEGIN
                IF tmpCmdRec.TxtColor<>255 THEN tmpTxtColor:=ColorValues[tmpCmdRec.TxtColor] ELSE tmpTxtColor:=COLOR_ENDCOLORS;
                IF tmpCmdRec.BgColor<>255 THEN tmpBgColor:=ColorValues[tmpCmdRec.BgColor] ELSE tmpBgColor:=COLOR_ENDCOLORS;
              END;
            CASE tmpCmdRec.ColorCmd OF
              1: BEGIN
                   IF tmpTxtColor<>COLOR_ENDCOLORS THEN df^.QuestionText:=tmpTxtColor;
                   IF tmpBgColor<>COLOR_ENDCOLORS THEN df^.QuestionBg:=tmpBgColor;
                 END;
              2: BEGIN
                   IF tmpTxtColor<>COLOR_ENDCOLORS THEN df^.FieldText:=tmpTxtColor;
                   IF tmpBgColor<>COLOR_ENDCOLORS THEN df^.FieldBg:=tmpBgColor;
                 END;
              3: IF tmpBgColor<>COLOR_ENDCOLORS THEN df^.Background:=tmpBgColor;
            END;  //case
          END;  //if
      END
    ELSE
      BEGIN
        tempResult:=False;
        IF cmd=cmdIF THEN
          BEGIN
            IF tmpCmdRec.IfCmds<>NIL THEN DestroyFieldList(tmpCmdRec.IfCmds);
            IF tmpCmdRec.ElseCmds<>NIL THEN DestroyFieldList(tmpCmdRec.ElseCmds);
          END;
      END;
  END;  //GetCommand

  Procedure GetCommandList(VAR CmdList:TList);
  BEGIN
    REPEAT
      CurCommand:=NextWord(nwAny);
      IF AnsiUpperCase(CurCommand)<>'END' THEN GetCommand(CmdList);
    UNTIL (AnsiUpperCase(CurCommand)='END') OR (EndOfChkFile);
    CurCommand:='';
  END;  //GetCommandList

  Procedure RetrieveFieldBlock;
  VAR
    n:Integer;
  BEGIN
    {Legal commands in fieldblocks are
      RANGE
      LEGAL
      COMMENT LEGAL
      MUSTENTER
      REPEAT
      JUMPS [RESET [x]]
      NOENTER
      IF
      LET eller et feltnavn
      AFTER ENTRY
      BEFORE ENTRY
      TYPE STATUSBAR "..."
      TYPE COMMENT
      KEY [UNIQUE] [n]
      ENTER
      CONFIRMFIELD
      TOPOFSCREEN
    }
{    IF PeField(df^.FieldList.Items[df^.FocusedField])^.Felttype<>ftQuestion THEN
      BEGIN
        New(tmpField);
        ResetCheckProperties(tmpField);
        tmpField^.Felttype:=PeField(df^.FieldList.Items[df^.FocusedField])^.Felttype;
        tmpField^.FLength:=PeField(df^.FieldList.Items[df^.FocusedField])^.FLength;
        REPEAT
          CurCommand:=AnsiUpperCase(NextWord(nwAny));
          n:=FieldNameList.IndexOf(CurCommand);
          IF CurCommand='RANGE'            THEN RetrieveRange
          ELSE IF CurCommand='LEGAL'       THEN RetrieveLegals
          ELSE IF CurCommand='MUSTENTER'   THEN tmpField^.FMustEnter:=True
          ELSE IF CurCommand='NOENTER'     THEN tmpField^.FNoEnter:=True
          ELSE IF CurCommand='TOPOFSCREEN' THEN
            BEGIN
              tmpField^.FTopOfScreen:=True;
              tmpField^.FTopOfScreenLines:=0;
              CurCommand:=NextWord(nwSameLine);
              IF (CurCommand<>'') AND (IsInteger(CurCommand))
              THEN tmpField^.FTopOfScreenLines:=StrToInt(CurCommand);
            END
          ELSE IF CurCommand='REPEAT'      THEN
            BEGIN
              tmpField^.FRepeat:=True;
              df^.HasRepeatField:=True;
            END
          ELSE IF (CurCommand='CODEFIELD') OR (CurCommand='CODES') THEN
            BEGIN
              ReportError(Lang(22782));  //'CODEFIELD/CODES not supported. Please use TYPE COMMENT fieldname instead.'
              TempResult:=False;
            END
          ELSE IF CurCommand='AUTOJUMP'     THEN RetrieveAutoJump
          ELSE IF CurCommand='JUMPS'        THEN RetrieveJumps
          ELSE IF CurCommand='COMMENT'      THEN RetrieveCommentLegal(tmpField^.FValueLabel,tmpField^.FCommentLegalRec,tmpField^.FShowLegalPickList,False)
          ELSE IF CurCommand='TYPE'         THEN RetrieveType
          ELSE IF CurCommand='KEY'          THEN RetrieveKeys
          ELSE IF CurCommand='CONFIRMFIELD' THEN tmpField^.FConfirm:=True
          ELSE IF CurCommand='ENTER'        THEN
            BEGIN
              ReportError(Lang(22784));  //'ENTER command not supported. Please use BEFORE/AFTER ENTRY instead.'
              TempResult:=False;
            END
          ELSE IF CurCommand='BEFORE'       THEN
            BEGIN
              CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
              IF CurCommand='ENTRY' THEN
              GetCommandList(tmpField^.BeforeCmds)
              ELSE
                BEGIN
                  ReportError(Lang(22786));  //'ENTRY expected'
                  TempResult:=False;
                END;
            END
          ELSE IF CurCommand='AFTER' THEN
            BEGIN
              CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
              IF CurCommand='ENTRY' THEN GetCommandList(tmpField^.AfterCmds)
              ELSE
                BEGIN
                  ReportError(Lang(22786));  //'ENTRY expected'
                  TempResult:=False;
                END;
            END
          ELSE IF CurCommand<>'' THEN GetCommand(tmpField^.AfterCmds);
  {            BEGIN
              IF CurCommand[1]='*' THEN AddFieldComment
              ELSE IF CurCommand<>'END' THEN AddFieldFlawComment;
            END;}
{        UNTIL (EndOfChkFile) OR (CurCommand='END');
        IF TempResult THEN
          BEGIN
            WITH PeField(df^.FieldList[df^.FocusedField])^ DO
              BEGIN
                IF AfterCmds<>NIL THEN DisposeCommandList(AfterCmds);
                IF BeforeCmds<>NIL THEN DisposeCommandList(BeforeCmds);
                FMin:=tmpField^.FMin;
                FMax:=tmpField^.FMax;
                FLegal:=tmpField^.FLegal;
                FValueLabel:=tmpField^.FValueLabel;
                FMustEnter:=tmpField^.FMustEnter;
                FRepeat:=tmpField^.FRepeat;
                FJumps:=tmpField^.FJumps;
                FJumpResetChar:=tmpField^.FJumpResetChar;
                FRangeDefined:=tmpField^.FRangeDefined;
                FFieldComments:=tmpField^.FFieldComments;
                FNoEnter:=tmpField^.FNoEnter;
                FIndex:=tmpField^.FIndex;
                FIsTypeStatusBar:=tmpField^.FIsTypeStatusBar;
                FTypeComments:=tmpField^.FTypeComments;
                FTypeString:=tmpField^.FTypeString;
                FTypeCommentField:=tmpField^.FTypeCommentField;
                FTypeColor:=tmpField^.FTypeColor;
                FConfirm:=tmpField^.FConfirm;
                FCommentLegalRec:=tmpField^.FCommentLegalRec;
                FTopOfScreen:=tmpField^.FTopOfScreen;
                FTopOfScreenLines:=tmpField^.FTopOfScreenLines;
                FShowLegalPickList:=tmpField^.FShowLegalPickList;
                FPickListNoSelect:=tmpField^.FPickListNoSelect;
                AfterCmds:=tmpField^.AfterCmds;
                BeforeCmds:=tmpField^.BeforeCmds;
              END;  //with
          END  //if TempResult
        ELSE
          BEGIN
            IF tmpField^.AfterCmds<>NIL THEN DisposeCommandList(tmpField^.AfterCmds);
            IF tmpField^.BeforeCmds<>NIL THEN DisposeCommandList(tmpField^.BeforeCmds);
          END;  //if NOT TempResult
      END;
    df^.FocusedField:=-1;
    CurCommand:='';
  END;   //procedure RetrieveFieldBlock


  Procedure AddTopComment;
  BEGIN
    CurLin:='';
    IF (CheckFileMode) AND (Assigned(df^.ChkTopComments))
    THEN df^.ChkTopComments.Append(ChkLin[CurLinIndex]);
  END;  //Procedure AddTopComment


  Procedure RetrieveFlawBlock;
  BEGIN
    IF NOT CheckFileMode THEN TempResult:=False;
    CommentsAddedToCheckFile:=True;
    CurLin:='';
    ReportError(Lang(22732));  //'Unknown command in line'
    IF (FirstTopFlaw) AND (CheckFileMode) AND (MultiLineError) THEN
      BEGIN
        FirstTopFlaw:=False;
//        {$IFNDEF epidat}
{        IF eDlg(Format(Lang(22788),   //'Unknown fieldname found in checkfile %s'
           [ExtractFilename(df^.CHKFilename)])+#13#13+
           Lang(22790)+#13#13+  //'Do you want to save the checks of the unknown fieldname~as commentlines in the checkfile?'
           Lang(22792),   //'If you choose No the checks of the unknown fieldname will~be deleted when the revised checks are saved.'
           mtWarning,[mbYes,mbNo],0)=mrYes THEN SaveTopFlawsAsComments:=True;
        Screen.Cursor:=crHourGlass;
//        {$ENDIF}
{      END;  //FirstTopFlaw
    REPEAT
      IF SaveTopFlawsAsComments THEN
        BEGIN
          ChkLin[CurLinIndex]:='* '+ChkLin[CurLinIndex];
          AddTopComment;
        END;
      CurCommand:=NextWord(nwAny);
      CurLin:='';
    UNTIL (EndOfChkFile) or (AnsiUpperCase(CurCommand)='END');
    IF AnsiUpperCase(CurCommand)='END' THEN
      BEGIN
        ChkLin[CurLinIndex]:='* '+ChkLin[CurLinIndex];
        AddTopComment;
      END;
  END;  //procedure RetrieveFlawBlock



  Procedure RetrieveLabelBlock;
  //Reads the LABELBLOCK..END block in the checkfile
  BEGIN
    REPEAT
      CurCommand:=AnsiUpperCase(NextWord(nwAny));
      IF CurCommand='LABEL' THEN RetrieveLabel(df);
    UNTIL (CurCommand='END') OR (EndOfChkFile);
    CurCommand:='';
  END;  //RetrieveLabelBlock

  Procedure RetrieveAssertBlock;
  //Reads the CONSISTENCYBLOCK..END block - and ignores it...
  BEGIN
    IF NOT Assigned(df^.AssertList) THEN df^.AssertList:=TStringList.Create;
    REPEAT
      CurCommand:=AnsiUpperCase(nextWord(nwAny));
      IF (CurCommand='CHECK') OR (CurCommand='REPORT') THEN
        BEGIN
          CurLin:='';
          df^.AssertList.Append(ChkLin[CurLinIndex]);
        END;
    UNTIL (CurCommand='END') OR (EndOfChkFile);
    CurCommand:='';
  END;

BEGIN  //function StringsToChecks
  TRY
    ChkLin:=TStringList.Create;
    FieldnameList:=TStringList.Create;
    ErrorLin:=TStringList.Create;
    LegList:=TStringList.Create;
    FieldComments:=TStringList.Create;
    IF CheckFileMode THEN df^.ChkTopComments:=TStringList.Create;
  EXCEPT
//    {$IFNDEF epidat}
//    ErrorMsg(Format(Lang(20204),[342]));  //'Out of memory (reference-code 342)'
//    {$ENDIF}
{    ChkLin.Free;
    FieldnameList.Free;
    ErrorLin.Free;
    LegList.Free;
    FieldComments.Free;
    IF CheckFileMode THEN df^.ChkTopComments.Free;
    Result:=False;
    Exit;
  END;  //try..Except
  FirstTopFlaw:=True;
  SaveTopFlawsAsComments:=False;
  FirstFieldFlaw:=True;
  SaveFieldFlawsAsComments:=False;
  CommentsAddedToCheckFile:=False;
  InIfBlock:=False;
  IF MultiLineError THEN
    BEGIN
      ErrorLin.Add('');
      ErrorLin.Add(Format(Lang(22794),[df^.CHKFilename]));  //'The check-file %s contains the following errors:'
      ErrorLin.Add('');
      ErrorLin.Add('');
    END;
  FOR aN:=0 TO df^.FieldList.Count-1 DO
    FieldnameList.Add(AnsiUpperCase(trim(PeField(df^.FieldList.Items[aN])^.FName)));
  ChkLin.Text:=ErrorList;
  CurLin:='';
  CurLinIndex:=-1;
  TempResult:=True;
  EndOfChkFile:=False;
  IF CheckFileMode THEN df^.ChkTopComments.Append('* '+Lang(22796)+' '+  //'Revised'
    FormatDateTime('dd mmm yyyy hh":"nn',now));
  REPEAT    //Read top-level check commands
    aFound:=False;
    CurCommand:=AnsiUpperCase(NextWord(nwAny));

    {Legal commands outside fieldblock are
      Fieldname..End
      Comments (*)
      LabelBlock..End
      AssertBlock..End
      Before File..End
      After File..End
      Before Record..End
      After Record..End
    }

{    df^.FocusedField:=FieldnameList.IndexOf(CurCommand);
    IF df^.FocusedField>-1 THEN RetrieveFieldBlock
    ELSE IF CurCommand='LABELBLOCK' THEN RetrieveLabelBlock
    ELSE IF CurCommand='CONSISTENCYBLOCK' THEN RetrieveAssertBlock
    ELSE IF CurCommand='BEFORE' THEN
      BEGIN
        CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
        IF CurCommand='FILE' THEN GetCommandList(df^.BeforeFileCmds)
        ELSE IF CurCommand='RECORD' THEN GetCommandList(df^.BeforeRecordCmds)
        ELSE
          BEGIN
            ReportError(Lang(22798));  //'Unknown command after BEFORE'
            TempResult:=False;
          END;
      END
    ELSE IF CurCommand='AFTER' THEN
      BEGIN
        CurCommand:=AnsiUpperCase(NextWord(nwSameLine));
        IF CurCommand='FILE' THEN GetCommandList(df^.AfterFileCmds)
        ELSE IF CurCommand='RECORD' THEN GetCommandList(df^.AfterRecordCmds)
        ELSE
          BEGIN
            ReportError(Lang(22800));  //'Unknown command after AFTER'
            TempResult:=False;
          END;
      END
    ELSE IF CurCommand='RECODEBLOCK' THEN GetCommandList(df^.RecodeCmds)
    ELSE IF CurCommand<>'' THEN
      BEGIN
        IF CurCommand[1]='*' THEN AddTopComment ELSE RetrieveFlawBlock;
      END;
  UNTIL EndOfChkFile;
  //Pack indexfield list
  IF df^.IndexCount>0 THEN
    BEGIN
      REPEAT
        FOR n:=1 TO MaxIndices-1 DO
          BEGIN
            IF df^.IndexFields[n]=-1 THEN
              BEGIN
                FOR n2:=n+1 TO MaxIndices DO
                  BEGIN
                    IF df^.Indexfields[n2]<>-1
                    THEN DEC(PeField(df^.FieldList.Items[df^.IndexFields[n2]])^.FIndex);
                    df^.IndexFields[n2-1]:=df^.IndexFields[n2];
                    df^.IndexIsUnique[n2-1]:=df^.IndexIsUnique[n2];
                    df^.IndexFields[n2]:=-1;
                    df^.IndexIsUnique[n2]:=False;
                  END;
              END;
          END;
      UNTIL df^.IndexFields[1]<>-1;
    END;  //if indexCount>0
  ErrorList:=ErrorLin.Text;
  ChkLin.Free;
  FieldnameList.Free;
  ErrorLin.Free;
  LegList.Free;
  Result:=TempResult;
END;  //Function StringsToChecks
}

Function PeekApplyCheckFile(df:PDatafileInfo; VAR ErrList:String):Boolean;
VAR
  tmpChecks:TStrings;
  CheckObj: TCheckObj;
  s:String;
BEGIN
  //edlg('PeekApplyCheckfile',mtInformation,[mbOK],0);
  TRY
    tmpChecks:=TStringList.Create;
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Format(Lang(20204),[344]));   //'Out of memory (ref.-code 344)');
    {$ENDIF}
    Result:=False;
    ErrList:='';
    Exit;
  END;  //try..except
  TRY
    tmpChecks.LoadFromFile(df^.CHKFilename);
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Format(Lang(20130),[df^.CHKFilename]));  //'Error reading the checkfile %s'
    {$ENDIF}
    tmpChecks.Free;
    Result:=False;
    Exit;
  END;  //try..Except
  s:=tmpChecks.Text;
  tmpChecks.Free;
  TRY
    CheckObj:=TCheckObj.Create;
    CheckObj.ChkFileMode:=CheckFileMode;
    CheckObj.OnTranslate:=MainForm.TranslateEvent;
    Result:=CheckObj.ApplyChecks(df,s);
    ErrList:=CheckObj.ErrorList;
  Finally
    CheckObj.Free;
    //tmpChecks.Free;
  END;
{
  ErrorList:=tmpChecks.Text;
  tmpChecks.Free;
  MultiLineError:=True;
  Result:=StringsToChecks(df, ErrorList);
  MultiLineError:=False;
}
END;  //peekApplyCheckFile


// *******************************************************


Procedure AddCommandList(VAR df:PDatafileInfo; VAR sList:TStringList; VAR CmdList:TList; Indent:Byte);
VAR
  CmdCounter,n:Integer;
  Cmd:PCmds;
  tmpStr:String[250];
  IndStr:String[50];
  LabelList: TStrings;
  s,tmpFieldStr:String;
BEGIN
  IF CmdList=NIL THEN Exit;
  IF CmdList.Count=0 THEN Exit;
  IndStr:=cFill(' ',Indent);
  FOR CmdCounter:=0 TO CmdList.Count-1 DO
    BEGIN
      Cmd:=PCmds(CmdList.Items[CmdCounter]);
      CASE Cmd^.Command OF
        cmdIF:
          BEGIN
            s:=cmd^.IfShowExpr;
//            Single2DoubleQuotes(s);
{            REPEAT
              n:=Pos('_M',s);
              IF n>0 THEN
                BEGIN
                  s[n]:=' ';
                  s[n+1]:='.';
                END;
            UNTIL n=0;}
            tmpStr:=s;
{            IF (tmpStr[1]='(') AND (tmpStr[Length(tmpStr)]=')') THEN
              BEGIN
                tmpStr[1]:=' ';
                tmpStr[Length(tmpStr)]:=' ';
              END;}
            sList.Append(IndStr+'IF '+trim(tmpStr)+' THEN');
            AddCommandList(df,sList,cmd^.IfCmds,Indent+2);
            IF cmd^.ElseCmds<>NIL THEN
              BEGIN
                sList.Append(IndStr+'ELSE');
                AddCommandList(df,sList,cmd^.ElseCmds,Indent+2);
              END;
            sList.Append(IndStr+'ENDIF');
          END;  //case cmdIF
        cmdHelp:
          BEGIN
            tmpStr:='"'+cmd^.HelpString+'"';
            REPEAT
              n:=pos(#13,tmpStr);
              IF n>0 THEN
                BEGIN
                  tmpStr[n]:='n';
                  tmpStr[n-1]:='\';
                END;
            UNTIL n=0;
            IF trim(cmd^.HelpKeys)<>''
            THEN tmpStr:=tmpStr+' KEYS="'+trim(AnsiUpperCase(cmd^.HelpKeys))+'"';
            CASE cmd^.HelpType OF
              mtError: tmpStr:=tmpStr+' TYPE=ERROR';
              mtWarning: tmpStr:=tmpStr+' TYPE=WARNING';
              mtConfirmation: tmpStr:=tmpStr+' TYPE=CONFIRMATION';
            END;
            sList.Append(IndStr+'HELP '+tmpStr);
          END;  //case cmdHelp
        cmdWriteNote:
          BEGIN
            tmpStr:='"'+cmd^.FNote+'"';
            REPEAT
              n:=pos(#13,tmpStr);
              IF n>0 THEN
                BEGIN
                  tmpStr[n]:='n';
                  tmpStr[n-1]:='\';
                END;
            UNTIL n=0;
            IF cmd^.ShowNotes THEN tmpStr:=tmpStr+' SHOW';
            sList.Append(IndStr+'WRITENOTE '+tmpStr);
          END;  //case cmdWriteNote
        cmdCopyToClipboard:
          BEGIN
            sList.Append(IndStr+'COPYTOCLIPBOARD "'+cmd^.CopyStr+'"');
          END;
        cmdHide:
          BEGIN
            tmpStr:=IndStr+'HIDE';
            tmpStr:=tmpStr+' '+cmd^.HideVarName;
            sList.Append(tmpStr);
          END;  //case cmdHide
        cmdUnHide:
          BEGIN
            tmpStr:=IndStr+'UNHIDE';
            tmpStr:=tmpStr+' '+cmd^.HideVarName;
            sList.Append(tmpStr);
          END;  //case cmdUnHide
        cmdClear:
          BEGIN
            tmpStr:=IndStr+'CLEAR';
            IF cmd^.HideVarName='$$COMLEG' THEN tmpStr:=tmpStr+' COMMENT LEGAL'
            ELSE tmpStr:=tmpStr+' '+cmd^.HideVarName;
            sList.Append(tmpStr);
          END;  //case cmdClear
        cmdGoto: sList.Append(IndStr+'GOTO '+cmd^.HideVarName);
        cmdExit: sList.Append(IndStr+'EXIT');
        cmdQuit: sList.Append(IndStr+'QUIT');    //###
        cmdTypeString:
          BEGIN
            IF cmd^.TypeText='¤¤typecommentlegalallfields¤¤' THEN
              BEGIN
                tmpStr:=IndStr+'TYPE COMMENT ALLFIELDS';
                IF df^.GlobalTypeComColor<>0 THEN tmpStr:=tmpStr+' '+ColorNames[df^.globalTypeComColor];
              END
            ELSE
              BEGIN
                tmpStr:=IndStr+'TYPE "'+cmd^.TypeText+'"';
                IF cmd^.TypeColor<>2 THEN tmpStr:=tmpStr+' '+ColorNames[cmd^.TypeColor];
              END;
            sList.Append(tmpStr);
          END;
        cmdBackup:
          BEGIN
            sList.Append(IndStr+'BACKUP '+cmd^.DestLib);
          END;
        cmdLoad:
          BEGIN
            tmpStr:=cmd^.DLLName;
            IF pos(' ',tmpStr)>0 THEN tmpStr:='"'+tmpStr+'"';
            sList.Append(IndStr+'LOAD '+tmpStr);
          END;
        cmdExecute:
          BEGIN
            IF pos(' ',cmd^.ExecCmdLine)>0
            THEN tmpStr:='EXECUTE '+'"'+cmd^.ExecCmdLine+'"'
            ELSE tmpStr:='EXECUTE '+cmd^.ExecCmdLine;
            IF cmd^.ExecParams<>'' THEN
              BEGIN
                IF pos(' ',cmd^.ExecParams)>0
                THEN tmpStr:=tmpStr+' "'+cmd^.ExecParams+'"'
                ELSE tmpStr:=tmpStr+' '+cmd^.ExecParams;
              END;
            IF cmd^.ExecWait THEN tmpStr:=tmpStr+' WAIT' ELSE tmpStr:=tmpStr+' NOWAIT';
            IF cmd^.ExecHide THEN tmpStr:=tmpStr+' HIDE';
            sList.Append(IndStr+tmpStr);
          END;
        cmdBeep:
          BEGIN
            tmpStr:=IndStr+'BEEP';
            IF cmd^.Beeptype=btWarning THEN tmpStr:=tmpStr+' Warning';
            IF cmd^.BeepType=btConfirmation THEN tmpStr:=tmpStr+' Confirmation';
            sList.Append(tmpStr);
          END;
        cmdRelate:
          BEGIN
            tmpStr:=IndStr+'RELATE '+trim(cmd^.RelField)+' ';
            IF Pos(' ',cmd^.RelFileStr)>0 THEN tmpStr:=tmpStr+'"'+cmd^.RelFileStr+'"'
            ELSE tmpStr:=tmpStr+cmd^.RelFileStr;
            IF cmd^.One2One THEN tmpStr:=tmpStr+' 1';
            sList.Append(tmpStr);
          END;
        cmdComLegal:
          BEGIN
            IF Cmd^.ValueLabel<>'' THEN
              BEGIN
                tmpStr:=AnsiLowerCase(trim(Cmd^.ValueLabel));
                IF tmpStr[Length(tmpStr)]='$' THEN
                  BEGIN  //write comment legal..end block
                    n:=df^.ValueLabels.IndexOf(tmpStr);
                    IF n<>-1 THEN
                      BEGIN
                        LabelList:=TStringList.Create;
                        LabelList.Text:=Label2Text(tmpStr,
                          PLabelRec(df^.ValueLabels.Objects[n]),Indent);
                        LabelList[0]:=IndStr+'COMMENT LEGAL';
                        IF Cmd^.ShowList THEN LabelList[0]:=LabelList[0]+' SHOW';
                        sList.Addstrings(LabelList);
                      END;
                  END
                ELSE
                  BEGIN  //write Comment Legal Use ...
                    IF Copy(tmpStr,1,12)='labels from ' THEN
                      BEGIN
                        Delete(tmpStr,1,12);
                        IF Cmd^.ShowList THEN tmpStr:=tmpStr+' SHOW';
                        sList.Add('  COMMENT LEGAL '+tmpStr);
                      END
                    ELSE
                      BEGIN
                        IF tmpStr[Length(tmpStr)]='¤' THEN tmpStr:=Copy(tmpStr,1,Length(tmpStr)-1);
                        IF df^.ValueLabels.IndexOf(Cmd^.ValueLabel)<>-1 THEN
                          BEGIN
                            IF Cmd^.ShowList THEN tmpStr:=tmpStr+' SHOW';
                            sList.Add(IndStr+'COMMENT LEGAL USE '+trim(tmpStr));
                          END;
                      END;
                  END;
              END;
          END;  //case cmdComLegal
        cmdLet:
          BEGIN
            IF cmd^.CodedWithLet THEN tmpStr:='LET ' ELSE tmpStr:='';
            s:=trim(cmd^.LetExpr);
            Single2DoubleQuotes(s);
            REPEAT
              n:=Pos('_M',s);
              IF n>0 THEN
                BEGIN
                  s[n]:=' ';
                  s[n+1]:='.';
                END;
            UNTIL n=0;
            tmpStr:=tmpStr+cmd^.VarName+'='+s;
            sList.Append(IndStr+tmpStr);
          END;  //case cmdLet
        cmdDefine:
          BEGIN
            CASE cmd^.Felttype OF
              ftInteger: tmpFieldStr:=cFill('#',cmd^.FLength);
              ftAlfa: tmpFieldStr:=cFill('_',cmd^.FLength);
              ftDate: tmpFieldStr:='<MM/DD/YYYY>';
              ftYMDDate: tmpFieldStr:='<YYYY/MM/DD>';          //&&
              ftUpperAlfa: tmpFieldStr:='<A'+cFill('a',cmd^.FLength-1)+'>';
              ftSoundex: tmpFieldStr:='<S'+cFill('s',cmd^.FLength-1)+'>';
              ftBoolean: tmpFieldStr:='<Y>';
              ftFloat: BEGIN
                  tmpFieldStr:=cFill('#',cmd^.FLength-1-cmd^.FNumDecimals);
                  IF cmd^.FNumDecimals=0 THEN tmpFieldStr:=tmpFieldStr+'#'
                  ELSE tmpFieldStr:=tmpFieldStr+'.'+cFill('#',cmd^.FNumDecimals);
                END;   //Case FeltType of ftFloat
              ftEuroDate: tmpFieldStr:='<DD/MM/YYYY>';
            END;  //Case FeltType
            tmpStr:='DEFINE '+cmd^.FName+' '+tmpFieldStr;
            IF cmd^.FScope=scGlobal THEN tmpStr:=tmpStr+' GLOBAL';
            IF cmd^.FScope=scCumulative THEN tmpStr:=tmpStr+' CUMULATIVE';
            sList.Append(IndStr+tmpStr);
          END;  //case cmdDefine
        cmdAutoSave: sList.Append(IndStr+'AUTOSAVE');
        cmdConfirm:  sList.Append(IndStr+'CONFIRM');
        cmdIgnoreMissing: sList.Append(IndStr+'IGNOREMISSING');
        //cmdBgColour: sList.Append(IndStr+'BACKGROUNDCOLOUR '+ColorNames[cmd^.BgColour]);
        cmdColor:
          BEGIN
            tmpStr:=IndStr+'COLOR ';
            CASE cmd^.ColorCmd OF
              1: tmpStr:=tmpStr+'QUESTION ';
              2: tmpStr:=tmpStr+'DATA ';
              3: tmpStr:=tmpStr+'BACKGROUND ';
            END;  //case
            IF cmd^.IsEpiInfoNo THEN
              BEGIN
                IF cmd^.ColorCmd=3 THEN tmpStr:=tmpStr+IntToStr(cmd^.BgColor)
                ELSE
                  BEGIN
                    n:=(cmd^.BgColor SHL 4);
                    n:=n AND cmd^.TxtColor;
                    tmpStr:=tmpStr+IntToStr(n);
                  END;
              END
            ELSE
              BEGIN
                IF cmd^.ColorCmd=3 THEN tmpStr:=tmpStr+ColorNames[cmd^.BgColor]
                ELSE
                  BEGIN
                    tmpStr:=tmpStr+ColorNames[cmd^.txtcolor];
                    IF cmd^.BgColor<>255 THEN tmpStr:=tmpStr+' '+ColorNames[cmd^.bgcolor];
                  END;
              END;
            sList.Append(tmpstr);
          END;
        cmdComment: sList.Append(IndStr+cmd^.Comment);
        cmdLeaveField:
          BEGIN
            tmpStr:='cmdLeaveField -';
            IF cmd^.IsLastField THEN tmpStr:=tmpStr+'LastField';
            sList.Append(tmpStr);
          END;
      END;  //Case
    END;  //for
END;  //Procedure AddCommandList

Procedure FieldBlockToStrings(VAR df:PDatafileInfo; VAR sList:TStringList; FieldNo:Integer; Indent:Byte);
VAR
  LegalList: TStrings;
  Autolist: TStringList;
  tmpS,IndStr: String;
  sN2,sN3:Integer;
  AField,AField2: PeField;
BEGIN
  IndStr:=cFill(' ',Indent);
  LegalList:=TStringList.Create;
  AField:=PeField(df^.FieldList.Items[FieldNo]);
  WITH AField^ DO
  BEGIN
    FMin:=Trim(FMin);
    FMax:=Trim(FMax);
    IF HasCheckProperties(AField) THEN
      BEGIN
        sList.Add(IndStr+trim(FName));
        {Write fieldblock comments}
        IF FFieldComments<>'' THEN
        BEGIN
          FieldComments.Text:=FFieldComments;
          sList.AddStrings(FieldComments);
        END;

        {Write index key}
        IF FIndex>0 THEN
          BEGIN
            tmpS:=IndStr+'  KEY ';
            IF df^.IndexIsUnique[FIndex] THEN tmpS:=tmpS+'UNIQUE ';
            tmpS:=tmpS+IntToStr(FIndex);
            sList.Add(tmpS);
          END;
        {Write autosearch}
        IF FAutosearch THEN
          BEGIN
            tmpS:=IndStr+'  Autosearch ';
            IF FAutoList THEN tmpS:=tmpS+' LIST ';
            TRY
              autolist:=TStringList.Create;
              autolist.CommaText:=FAutoFields;
              FOR sN2:=0 TO autolist.count-1 DO
                BEGIN
                  AField2:=PeField(df^.FieldList.Items[StrToInt(autoList[sN2])]);
                  tmpS:=tmpS+trim(AField2^.FName)+' ';
                END;
            FINALLY
              autolist.Free;
            END;
            sList.Add(tmpS);
          END;

        {Write NoEnter}
        IF FNoEnter THEN sList.Add(IndStr+'  NOENTER');
        {Write TopOfScreen}
        IF FTopOfScreen THEN
          BEGIN
            tmpS:=IndStr+'  TOPOFSCREEN';
            IF FTopOfScreenLines>0 THEN tmpS:=tmpS+' '+IntToStr(FTopOfScreenLines);
            sList.Add(IndStr+tmpS);
          END;
        {Write RANGE}
        tmpS:='';
        IF FMin<>'' THEN tmpS:=FMin+' '
        ELSE tmpS:='-INFINITY ';
        IF FMax<>'' THEN tmpS:=tmpS+FMax
        ELSE tmpS:=tmpS+'INFINITY';
        IF (FMin<>'') OR (FMax<>'')
        THEN sList.Add(IndStr+'  RANGE '+tmpS);
        {Write LEGAL block}
        IF FLegal<>'' THEN
          BEGIN
            IF FRangeDefined THEN sN3:=1 ELSE sN3:=0;
            LegalList.CommaText:=FLegal;
            IF LegalList.Count>sN3 THEN
              BEGIN
                sList.Add(IndStr+'  LEGAL');
                LegalList.CommaText:=FLegal;
                FOR sN2:=sN3 TO LegalList.Count-1 DO
                  IF Pos(' ',LegalList[sN2])>0
                  THEN sList.Add(IndStr+'    "'+LegalList[sN2]+'"')
                  ELSE sList.Add(IndStr+'    '+LegalList[sN2]);
                sList.Add(IndStr+'  END');
              END;
          END;
        {Write Comment Legal}
        IF FValueLabel<>'' THEN
          BEGIN
            tmpS:=AnsiLowerCase(trim(FValueLabel));
            IF tmpS[Length(tmpS)]='$' THEN
              BEGIN  //write comment legal..end block
                sN2:=df^.ValueLabels.IndexOf(tmpS);
                IF sN2<>-1 THEN
                  BEGIN
                    LegalList.Clear;
                    LegalList.Text:=Label2Text(tmpS,
                      PLabelRec(df^.ValueLabels.Objects[sN2]),Indent+2);
                    LegalList[0]:=IndStr+'  COMMENT LEGAL';
                    IF FShowLegalPickList THEN LegalList[0]:=LegalList[0]+' SHOW';
                    sList.Addstrings(LegalList);
                  END;
              END
            ELSE
              BEGIN  //write Comment Legal Use ...
                IF Copy(tmpS,1,12)='labels from ' THEN
                  BEGIN
                    Delete(tmpS,1,12);
                    IF FShowLegalPickList THEN tmpS:=tmpS+' SHOW';
                    sList.Add(IndStr+'  COMMENT LEGAL '+tmpS);
                  END
                ELSE
                  BEGIN
                    IF tmpS[Length(tmpS)]='¤' THEN tmpS:=Copy(tmpS,1,Length(tmpS)-1);
                    IF df^.ValueLabels.IndexOf(FValueLabel)<>-1 THEN
                      BEGIN
                        IF FShowLegalPickList THEN tmpS:=tmpS+' SHOW';
                        sList.Add(IndStr+'  COMMENT LEGAL USE '+trim(tmpS));
                      END;
                  END;
              END;
          END;
        {Write JUMPS block}
        IF FJumps<>'' THEN
          BEGIN
            LegalList.CommaText:=FJumps;
            IF LegalList[0]='AUTOJUMP'
            THEN sList.Add(IndStr+'  AUTOJUMP '+trim(LegalList[1]))
            ELSE
              BEGIN
                tmpS:=IndStr+'  JUMPS';
                IF FJumpResetChar<>#0 THEN tmpS:=IndStr+'  JUMPS RESET';
                IF (FJumpResetChar<>#0) AND (FJumpResetChar<>#32)
                THEN tmpS:=tmpS+' "'+FJumpResetchar+'"';
                sList.Add(tmpS);
                FOR sN2:=0 TO LegalList.Count-1 DO
                  BEGIN
                    tmpS:=LegalList[sN2];
                    tmpS[Pos('>',tmpS)]:=' ';
                    sList.Add(IndStr+'    '+tmpS);
                  END;
                sList.Add(IndStr+'  END');
              END;
          END;
        {Write MUSTENTER, REPEAT}
        IF FMustEnter THEN sList.Add(IndStr+'  MUSTENTER');
        IF FRepeat THEN sList.Add(IndStr+'  REPEAT');
        IF FConfirm THEN sList.Add(IndStr+'  CONFIRMFIELD');

        {Write Missingvalues}
        tmpS:='';
        IF FMissingValues[0]<>'' THEN tmpS:=FMissingValues[0];
        IF FMissingValues[1]<>'' THEN tmpS:=tmpS+' '+FMissingValues[1];
        IF FMissingValues[2]<>'' THEN tmpS:=tmpS+' '+FMissingValues[2];
        IF tmpS<>'' THEN sList.Add(IndStr+'  MISSINGVALUE '+tmpS);

        {Write DEFAULTVALUE}
        IF FDefaultValue<>'' THEN sList.Add(IndStr+'  DEFAULTVALUE '+FDefaultValue);


        {Write TYPE STATUSBAR}
        IF FIsTypeStatusBar THEN
          BEGIN
            tmpS:=IndStr+'  TYPE STATUSBAR';
            IF df^.TypeStatusBarText<>'' THEN tmpS:=tmpS+' "'+df^.TypeStatusBarText+'"';
            IF df^.TypeStatusBarColor<>2 THEN tmpS:=tmpS+' '+ColorNames[df^.TypeStatusbarcolor];
            sList.Add(tmpS);
          END;

        {Write TYPE COMMENT}
        tmpS:=IndStr+'  TYPE COMMENT ';
        IF FTypeComments THEN
          BEGIN
            IF FTypeColor<>2 THEN tmpS:=tmpS+ColorNames[FTypeColor];
            sList.Add(tmpS);
          END
        ELSE IF (df^.GlobalTypeCom) AND (FTypeCommentField=-2) THEN
          BEGIN
            tmpS:=tmpS + 'ALLFIELDS';
            IF df^.GlobalTypeComColor<>0 THEN tmpS:=tmpS+' '+ColorNames[df^.globalTypeComColor];
            sList.Add(tmpS);
          END
        ELSE IF FTypeCommentField<>-1 THEN
          BEGIN
            tmpS:=tmpS+trim(PeField(df^.FieldList.Items[FTypeCommentField])^.FName);
            sList.Add(tmpS);
          END;

        {Write Before Entry commands}
        IF BeforeCmds<>NIL THEN
          BEGIN
            sList.Add(IndStr+'  BEFORE ENTRY');
            AddCommandList(df,sList,BeforeCmds,Indent+4);
            sList.Add(IndStr+'  END');
          END;  //if Before commands

        {Write After Entry commands}
        IF AfterCmds<>NIL THEN
          BEGIN
            sList.Add(IndStr+'  AFTER ENTRY');
            AddCommandList(df,sList,AfterCmds,Indent+4);
            sList.Add(IndStr+'  END');
          END;  //if After commands

        {End fieldblock}
        sList.Add(IndStr+'END');
        sList.Add('');
      END;  //if field has checks attached
  END;  //With
  LegalList.Free;
END;  //procedure FieldBlockToStrings

Procedure ChecksToStrings(VAR df:PDatafileInfo; VAR sList:TStringList);
VAR
  sN,sN2: Integer;
  tmpS:String;
  LegalList:TStrings;
  AField: PeField;

  procedure LabelsInCommands(cmdList: TList);
  VAR
    n,w:Integer;
    Cmd:PCmds;
  BEGIN
    IF CmdList=NIL THEN Exit;
    IF CmdList.Count=0 THEN Exit;
    FOR n:=0 TO cmdList.Count-1 DO
      BEGIN
        Cmd:=PCmds(CmdList.Items[n]);
        Case cmd^.Command OF
          cmdIF:
            BEGIN
              IF cmd^.IfCmds<>NIL THEN LabelsInCommands(cmd^.IfCmds);
              IF cmd^.ElseCmds<>NIL THEN LabelsInCommands(cmd^.ElseCmds);
            END;
          cmdComLegal:
            BEGIN
              tmpS:=AnsiLowerCase(cmd^.ValueLabel);
              w:=df^.ValueLabels.IndexOf(tmpS);
              IF (w<>-1) AND (LegalList.IndexOf(tmpS)=-1)
              AND (tmpS[Length(tmpS)]<>'$') AND (Copy(tmpS,1,12)<>'labels from ')
              THEN LegalList.AddObject(tmpS,df^.ValueLabels.Objects[w]);
            END;
        END;  //case
      END;  //for
  END;  //procedure LabelsInCommands

BEGIN  //ChecksToStrings
  LegalList:=TStringList.Create;
  IF Assigned(df^.ChkTopComments)
  THEN IF df^.ChkTopComments.Count>0 THEN
    BEGIN
      sList.AddStrings(df^.ChkTopComments);
      sList.Append('');
    END;
  {Write LabelBlock}
  FOR sN:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[sN]);
      tmpS:=AnsiLowerCase(trim(AField^.FValueLabel));
      sN2:=df^.ValueLabels.IndexOf(tmpS);
      IF (sN2<>-1) AND (LegalList.IndexOf(tmpS)=-1)
      AND (tmpS[Length(tmpS)]<>'$') AND (Copy(tmpS,1,12)<>'labels from ')
      THEN LegalList.AddObject(tmpS,df^.ValueLabels.Objects[sN2]);
      {Check if fields has commands that contains comment legals}
      IF AField^.AfterCmds<>NIL THEN LabelsInCommands(AField^.AfterCmds);
      IF AField^.BeforeCmds<>NIL THEN LabelsInCommands(AField^.BeforeCmds);
    END;  //for sN
  {Legallist now contains all used value labels}
  IF LegalList.Count>0 THEN
    BEGIN
      sList.Append('LABELBLOCK');
      FOR sN:=0 TO LegalList.Count-1 DO
        sList.Append(Label2Text(LegalList[sN],PLabelRec(LegalList.Objects[sN]),2));
      sList.Append('END');  //of labelblock
      sList.Append('');
    END;  //if LegalList.Count>0
  LegalList.Clear;
  {Write assertblock}
  IF Assigned(df^.AssertList) THEN
    BEGIN
      sList.Append('CONSISTENCYBLOCK');
      sList.AddStrings(df^.AssertList);
      sList.Append('END');
      sList.Append('');
    END;
  {Write recodeblock}
  IF df^.RecodeCmds<>NIL THEN
    BEGIN
      sList.Append('RECODEBLOCK');
      AddCommandList(df,sList,df^.RecodeCmds,2);
      sList.Append('END');
      sList.Append('');
    END;
  {Write before/after file and before/after record}
  IF (df^.BeforeFileCmds<>NIL) OR (df^.GlobalMissingValues[0]<>'') OR (df^.GlobalDefaultValue<>'') THEN
    BEGIN
      sList.Append('BEFORE FILE');
      tmpS:='';
      IF df^.GlobalMissingValues[0]<>'' THEN tmpS:=df^.globalMissingValues[0];
      IF df^.GlobalMissingValues[1]<>'' THEN tmpS:=tmpS+' '+df^.GlobalMissingValues[1];
      IF df^.GlobalMissingValues[2]<>'' THEN tmpS:=tmpS+' '+df^.GlobalMissingValues[2];
      IF tmpS<>'' THEN sList.Append('  MISSINGVALUE ALL '+tmpS);
      IF df^.GlobalDefaultValue<>'' THEN sList.Append('  DEFAULTVALUE ALL '+df^.GlobalDefaultValue);
      AddCommandList(df,sList,df^.BeforeFileCmds,2);
      sList.Append('END');
      sList.Append('');
    END;
  IF df^.AfterFileCmds<>NIL THEN
    BEGIN
      sList.Append('AFTER FILE');
      AddCommandList(df,sList,df^.AfterFileCmds,2);
      sList.Append('END');
      sList.Append('');
    END;
  IF df^.BeforeRecordCmds<>NIL THEN
    BEGIN
      sList.Append('BEFORE RECORD');
      AddCommandList(df,sList,df^.BeforeRecordCmds,2);
      sList.Append('END');
      sList.Append('');
    END;
  IF df^.AfterRecordCmds<>NIL THEN
    BEGIN
      sList.Append('AFTER RECORD');
      AddCommandList(df,sList,df^.AfterRecordCmds,2);
      sList.Append('END');
      sList.Append('');
    END;

  {Write field blocks}
  FOR sN:=0 TO df^.FieldList.Count-1 DO FieldBlockToStrings(df,sList,sN,0);
  LegalList.Free;
END;  //procedure ChecksToStrings

Procedure TpCheckForm.SaveCheckFile;
VAR
  Checks:TStringList;
BEGIN
  Screen.Cursor:=crHourGlass;
  Checks:=TStringList.Create;
  ChecksToStrings(TheDatafile, Checks);
  Checks.SaveToFile(TheDatafile.CHKFilename);
  CheckFileModified:=False;
  SaveBtn.Enabled:=False;
  Checks.Free;
  Screen.Cursor:=crDefault;
END;  //procedure TpCheckForm.SaveCheckFile


Procedure TpCheckForm.UpdateCheckForm(Sender: TObject);
VAR
  AField: PeField;
//  HasOtherChecks:Boolean;
BEGIN
  {$IFNDEF epidat}
  ChangeGoingOn:=True;
  TheDataFile^.CurField:=TheDatafile^.FieldList.IndexOf(TEntryField(TheDatafile^.LatestActiveControl).dfField);
  AField:=PeField(TheDatafile^.FieldList.Items[TheDataFile^.CurField]);
  WITH AField^ DO
    BEGIN
      FieldNamesCombo.ItemIndex:=FieldNamesCombo.Items.IndexOf(trim(FName));
      FieldTypeLabel.Caption:=FieldTypeNames[ORD(FeltType)];
      VarLabel.Caption:=FVariableLabel;
      RangeEdit.Text:=FLegal;
      IF RangeEdit.Text='' THEN RangeEdit.Hint:=Lang(22802)  //'Define range, legal: e.g. 1-3,5,7,9'
      ELSE RangeEdit.Hint:=RangeEdit.Text;
      JumpsEdit.Text:=FJumps;
      IF FJumps='' THEN JumpsEdit.Hint:=Lang(22804)   //'Define jumps: e.g. 1>V2, 2>V8, 3>WRITE'
      ELSE JumpsEdit.Hint:=JumpsEdit.Text;
      IF HasSpecialChecks(AField)
      THEN EditChecksBtn.Font.Color:=clBlue
      ELSE EditChecksBtn.Font.Color:=clWindowText;
      ValLabelCombo.ItemIndex:=ValLabelCombo.Items.IndexOf(FValueLabel);
      MustEnterCombo.ItemIndex:=ORD(FMustEnter);
      RepeatCombo.ItemIndex:=ORD(FRepeat);
    END;   //with
  ChangeGoingOn:=False;
  {$ENDIF}
END;  //procedure TCheckForm.UpdateCheckForm


procedure TpCheckForm.RangeEditExit(Sender: TObject);
VAR
  rN,rN2:Integer;
  tmpS:String;
  tmpResult:Boolean;
  AField: PeField;
begin
  {$IFNDEF epidat}
  tmpResult:=True;
  TheDataFile^.CurField:=TheDatafile^.FieldList.IndexOf(TEntryField(TheDatafile^.LatestActiveControl).dfField);
  AField:=Pefield(TheDatafile^.FieldList.Items[Thedatafile^.CurField]);
  LegalList:=TStringList.Create;
  LegalList.CommaText:=Trim(RangeEdit.Text);
  rN:=0;
  IF (LegalList.Count>0) AND (Trim(RangeEdit.Text)<>'') THEN
    BEGIN
      {Check first element - is it a range?}
      tmpS:=LegalList[0];
      IF tmpS[1]='-' THEN tmpS[1]:='¤';   //Change minus-sign
      IF Pos('-',tmpS)>1 THEN
        BEGIN    //first element is a range
          {Check lower limit of range}
          tmpS:=Copy(tmpS,1,Pos('-',tmpS)-1);
          IF tmpS[1]='¤' THEN tmpS[1]:='-';  //Change minus-sign back to minus
          IF tmpS='-INF' THEN AField^.FMin:=''
          ELSE IF IsCompliant(tmpS,AField^.Felttype) OR (trim(tmpS)='') THEN AField^.FMin:=tmpS ELSE tmpResult:=False;
          {Check upper limit of range}
          tmpS:=LegalList[0];
          IF tmpS[1]='-' THEN tmpS[1]:='¤';   //Change minus-sign
          Delete(tmpS,1,Pos('-',tmpS));
          IF tmpS='INF' THEN AField^.FMax:=''
          ELSE IF IsCompliant(tmpS,AField^.Felttype) OR (trim(tmpS)='') THEN AField^.FMax:=tmpS ELSE tmpResult:=False;
          IF tmpResult THEN
            BEGIN
              AField^.FRangeDefined:=True;
              rN:=1;
            END
          ELSE AField^.FRangeDefined:=False;
        END;  //decoding of range
      IF (LegalList.Count>rN) AND (tmpResult) THEN
        FOR rN2:=rN TO LegalList.Count-1 DO
          IF (NOT IsCompliant(LegalList[rN2],AField^.Felttype)) THEN tmpResult:=False;
      IF tmpResult THEN
        BEGIN
          RangeEdit.Text:=RemoveQuotes(LegalList.CommaText);
          AField^.FLegal:=RangeEdit.Text;
          IF RangeEdit.Text=''
          THEN RangeEdit.Hint:=Lang(22802)   //'Define range, legal: e.g. 1-3,5,7,9'
          ELSE RangeEdit.Hint:=RangeEdit.Text;
          CheckFileModified:=True;
          SaveBtn.Enabled:=True;
        END
      ELSE
        BEGIN
          ErrorMsg(Lang(22806));  //'Error in range/legal definition.~~Illegal value(s) entered.'
          RangeEdit.SetFocus;
        END;
    END  //if LegalList.Count>0
  ELSE
    BEGIN
      WITH AField^ DO
        BEGIN
          FRangeDefined:=False;
          FMin:='';
          FMax:='';
          FLegal:='';
        END;  //with
      RangeEdit.Hint:=Lang(22802);  //'Define range, legal: e.g. 1-3,5,7,9';
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
    END;
  LegalList.Free;
  {$ENDIF}
end;   //Procedure RangeEditExit


procedure TpCheckForm.JumpsEditExit(Sender: TObject);
VAR
  tmpNameError,tmpDatatypeError:Boolean;
  tmpDividerMissing:Boolean;
  tmpS,tmpS2:String;
  jN:Integer;
  AField:PeField;
begin
  {$IFNDEF epidat}
  {Legal format is 1>v1,2>v2  etc.
  meaning a value of 1 jumps to v1, a value of 2 jumps to v2}
  tmpNameError:=False;
  tmpDatatypeError:=False;
  tmpDividerMissing:=False;
  TheDatafile^.CurField:=TheDatafile^.FieldList.IndexOf(TEntryField(TheDatafile^.LatestActiveControl).dfField);
  AField:=PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField]);
  LegalList:=TStringList.Create;
  tmpS:=JumpsEdit.text;
  WHILE Pos(' >',tmpS)>0 DO Delete(tmpS,Pos(' >',tmpS),1);
  WHILE Pos('> ',tmpS)>0 DO Delete(tmpS,Pos('> ',tmpS)+1,1);
  LegalList.CommaText:=tmpS;
  IF (LegalList.Count>0) AND (Trim(JumpsEdit.Text)<>'') THEN
    BEGIN
      IF (LegalList.Count=2) AND (AnsiUpperCase(LegalList[0])='AUTOJUMP') THEN
        BEGIN    //Autojump command specified
          tmpS:=AnsiUpperCase(LegalList[1]);
          IF (FieldNamesCombo.Items.IndexOf(tmpS)=-1) AND (trim(tmpS)<>'END')
          AND (trim(tmpS)<>'WRITE') AND (trim(tmpS)<>'SKIPNEXTFIELD') THEN
            BEGIN
              tmpNameError:=True;
              ErrorMsg(Lang(22808));  //'Error in jumps definition. Fieldname does not exist.'
              JumpsEdit.SetFocus;
            END
          ELSE
            BEGIN
              tmpS:='AUTOJUMP '+trim(LegalList[1]);
              PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FJumps:=tmpS;
              JumpsEdit.Text:=tmpS;
              CheckFileModified:=True;
              SaveBtn.Enabled:=True;
            END;
        END
      ELSE IF (LegalList.Count=1) AND (AnsiUpperCase(LegalList[0])='AUTOJUMP') AND (GetFieldnameForJump) THEN
        BEGIN
          tmpDividerMissing:=False;
        END
      ELSE
        BEGIN   //ordinary jump commands
          FOR jN:=0 TO LegalList.Count-1 DO
            BEGIN
              IF Pos('>',LegalList[jN])=0 THEN tmpDividerMissing:=True
              ELSE
                BEGIN
                  tmpS:=AnsiUpperCase(LegalList[jN]);
                  tmpS2:=Copy(tmpS,1,Pos('>',tmpS)-1);  //get value part
                  IF NOT IsCompliant(tmpS2,AField^.Felttype) THEN tmpDatatypeError:=True;
                  Delete(tmpS,1,Pos('>',tmpS));   //get fieldname part
                  IF (trim(tmpS)='END') OR (trim(tmpS)='WRITE')
                  OR (trim(tmpS)='SKIPNEXTFIELD') THEN tmpNameError:=FALSE
                  ELSE
                    IF FieldNamesCombo.Items.IndexOf(tmpS)=-1
                    THEN tmpNameError:=true;
                END;  //Else
            END;  //for
          IF (tmpNameError=False) AND (tmpDividerMissing=False)
          AND (tmpDatatypeError=False) THEN
            BEGIN
              JumpsEdit.Text:=RemoveQuotes(LegalList.CommaText);
              PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FJumps:=JumpsEdit.Text;
              IF JumpsEdit.Text='' THEN JumpsEdit.Hint:=Lang(22804)   //'Define jumps: e.g. 1>V2, 2>V8, 3>WRITE'
              ELSE JumpsEdit.Hint:=JumpsEdit.Text;
              CheckFileModified:=True;
              SaveBtn.Enabled:=True;
            END
          ELSE
            BEGIN
              IF tmpDatatypeError THEN tmpS:=Lang(22710);    //'Value is not compatible with this fieldtype'
              IF tmpNameError THEN tmpS:=Lang(22708);  //'Unknown fieldname'
              IF tmpDividerMissing THEN tmpS:=Lang(22812);  //'Arrowsign (>) is missing.'
              ErrorMsg(Lang(22814)+#13#13+tmpS);  //'Error in jumps definition.'
              JumpsEdit.SetFocus;
            END;
        END;  //if ordinary jump commands
    END   //IF legalList.Count>0
  ELSE
    BEGIN
      AField^.FJumps:='';
      JumpsEdit.Hint:=Lang(22804);   //'Define jumps: e.g. 1>V2, 2>V8, 3>WRITE'
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
    END;
  LegalList.Free;
  {$ENDIF}
end;   //JumpsEditExit



procedure TpCheckForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFNDEF epidat}
  CheckFormRect:=BoundsRect;
//  IF Assigned(LegalList) THEN LegalList.Free;
  IF Assigned(FieldComments) THEN FieldComments.Free;
  CheckFileMode:=False;
  IF Assigned(TheDatafile^.ChkTopComments) THEN TheDatafile^.ChkTopComments.Free;
  TheDatafile^.CheckFormCreated:=False;
  MainForm.StatPanel1.Caption:='';
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel3.Caption:='';
  MainForm.StatPanel4.Caption:='';
  {$ENDIF}
end;

procedure TpCheckForm.MustEnterComboChange(Sender: TObject);
begin
  {$IFNDEF epidat}
  TheDatafile^.CurField:=TheDatafile^.FieldList.IndexOf(TEntryField(TheDatafile^.LatestActiveControl).dfField);
  PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FMustEnter:=
  Boolean(MustEnterCombo.ItemIndex);
  IF NOT ChangeGoingOn THEN
    BEGIN
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
    END;
  {$ENDIF}
end;

procedure TpCheckForm.RepeatComboChange(Sender: TObject);
begin
  {$IFNDEF epidat}
  TheDatafile^.CurField:=TheDatafile^.FieldList.IndexOf(TEntryField(TheDatafile^.LatestActiveControl).dfField);
  PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FRepeat:=
  Boolean(RepeatCombo.ItemIndex);
  IF NOT ChangeGoingOn THEN
    BEGIN
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
    END;
  {$ENDIF}
end;


procedure TpCheckForm.ExitBtnClick(Sender: TObject);
begin
  {$IFNDEF epidat}
  TDataForm(TheDatafile^.DatForm).Close;
  {$ENDIF}
end;

procedure TpCheckForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  {$IFNDEF epidat}
  IF (CheckFileModified) OR (CommentsAddedToCheckFile) THEN
    BEGIN
      CASE eDlg(Format(Lang(22108),   //'Save changes to %s?'
          [TheDatafile^.CHKFileName]), mtConfirmation,[mbYes, mbNo, mbCancel], 0) OF
        idNo: CanClose:=True;
        idCancel: CanClose := False;
        idYes: BEGIN
          {Save existing Checkfile as checkfile.bak}
          IF FileExists(ChangeFileExt(TheDatafile^.CHKFilename,'.bak'))
          THEN DeleteFile(ChangeFileExt(TheDatafile^.CHKFilename,'.bak'));
          IF FileExists(TheDatafile^.CHKFilename)
          THEN RenameFile(TheDatafile^.CHKFilename,ChangeFileExt(TheDatafile^.CHKFilename,'.bak'));
          {Save new CheckFile}
          SaveCheckFile;
          CanClose:=True;
          END;  //case save change=idYes
      end;  //case save changes
    end;  //end if checkFileModified

  IF (CanClose) AND (TheDatafile^.DataFormCreated=False)
  THEN CanClose:=True ELSE CanClose:=False;
  {$ENDIF}
end; //FormCloseQuery

procedure TpCheckForm.FieldNamesComboChange(Sender: TObject);
begin
  {$IFNDEF epidat}
  TEntryField(FieldNamesCombo.Items.Objects[FieldNamesCombo.ItemIndex]).SetFocus;
  Self.SetFocus;
  {$ENDIF}
end;

procedure TpCheckForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$IFNDEF epidat}
  {F5 or Ctrl-VK_LEFT selects indtastningsForm}
  IF (Key=VK_F6) OR ( (Key=VK_LEFT) AND (Shift=[ssCtrl]) ) THEN
    BEGIN
      MainForm.SetFocus;
      Key:=0;
    END;

  {PgUp selects privious field}
  IF (Key=VK_UP) AND (Shift=[ssCtrl]) THEN
    BEGIN
      IF FieldNamesCombo.ItemIndex>0 THEN
      FieldNamesCombo.ItemIndex:=FieldNamesCombo.ItemIndex-1;
      TEntryField(FieldNamesCombo.Items.Objects[FieldNamesCombo.ItemIndex]).SetFocus;
      Self.SetFocus;
      Key:=0;
    END;

  {PgDn selects next field}
  IF (Key=VK_DOWN) AND (Shift=[ssCtrl]) THEN
    BEGIN
      IF FieldNamesCombo.ItemIndex<FieldNamesCombo.Items.Count-1
      THEN FieldNamesCombo.ItemIndex:=FieldNamesCombo.ItemIndex+1;
      TEntryField(FieldNamesCombo.Items.Objects[FieldNamesCombo.ItemIndex]).SetFocus;
      Self.SetFocus;
      Key:=0;
    END;
  {$ENDIF}
end;

procedure TpCheckForm.RangeEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {Arrow-up-key for last field}
  IF (Key=VK_UP) THEN
    BEGIN
      Key:=0;
      ValLabelCombo.SetFocus;
    END;
  {Arrow-down-key for next field}
  IF (Key=VK_DOWN) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;
end;

procedure TpCheckForm.JumpsEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {Arrow-up-key for previous field}
  IF (Key=VK_UP) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.handle,WM_NextDlgCtl,1,0);
    END;
  {Arrow-down-key for next field}
  IF (Key=VK_DOWN) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;
end;

procedure TpCheckForm.RepeatComboKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {Arrow-up-key for previous field}
  IF (Key=VK_UP) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,1,0);
    END;
  {Arrow-down-key for first field}
  IF (Key=VK_DOWN) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;

end;

procedure TpCheckForm.SaveBtnClick(Sender: TObject);
begin
  SaveCheckFile;
end;


procedure TpCheckForm.MustEnterComboKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF (Key=VK_DOWN) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;
  {Arrow-up-key for previous field}
  IF (Key=VK_UP) THEN
    BEGIN
      Key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,1,0);
    END;
end;

procedure TpCheckForm.FormCreate(Sender: TObject);
begin
  {$IFNDEF epidat}
  TranslateForm(self);
  {$ENDIF}
  BoundsRect:=CheckFormRect;
  tmpChecks.Empty:=True;
  CheckFileModified:=False;
end;

procedure TpCheckForm.FormResize(Sender: TObject);
begin
  Height:=290;
  IF Width<215 THEN Width:=215;
  IF Left+Width>Screen.Width THEN Left:=Screen.Width-10-Width;
  Panel1.Width:=ClientWidth-20;
  FieldnamesCombo.Width:=Panel1.Width-15;
  Panel2.Width:=ClientWidth-20;
  RangeEdit.Width:=Panel2.Width-116;
  ValLabelCombo.Width:=Panel2.Width-116;
  JumpsEdit.Width:=Panel2.Width-116;
  MustEnterCombo.Width:=Panel2.Width-116;
  RepeatCombo.Width:=Panel2.Width-116;
  GenerateLabel.Left:=Panel2.Width-22;
  IF Width>308 THEN
    BEGIN
      ExitBtn.Top:=203;
      ExitBtn.Left:=206;
    END
  ELSE
    BEGIN
      ExitBtn.Top:=235;
      ExitBtn.Left:=106;
    END;
end;

Procedure TpCheckForm.pToggleMustEnter;
BEGIN
  PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FMustEnter:=
  NOT PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FMustEnter;
  CheckFileModified:=True;
  SaveBtn.Enabled:=True;
  UpDateCheckForm(TObject(TheDatafile^.FieldList.Items[TheDatafile^.CurField]));
END;

Procedure TpCheckForm.pToggleRepeat;
BEGIN
  PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FRepeat:=
  NOT PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FRepeat;
  CheckFileModified:=True;
  SaveBtn.Enabled:=True;
  UpDateCheckForm(TObject(TheDatafile^.FieldList.Items[TheDatafile^.CurField]));
END;

Procedure TpCheckForm.pCopyChecks;
BEGIN
  WITH PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^ DO
    BEGIN
      tmpChecks.FNoEnter:=FNoEnter;
      tmpChecks.FLegal:=FLegal;
      tmpChecks.FValueLabel:=FValueLabel;
      tmpChecks.FRangeDefined:=FRangeDefined;
      tmpChecks.FMin:=FMin;
      tmpChecks.FMax:=FMax;
      tmpChecks.FJumps:=FJumps;
      tmpChecks.FJumpresetchar:=FJumpResetchar;
      tmpChecks.FMustEnter:=FMustEnter;
      tmpChecks.FRepeat:=FRepeat;
      tmpChecks.FDefaultValue:=FDefaultValue;
      tmpChecks.FConfirm:=FConfirm;
      tmpChecks.FTypeComments:=FTypeComments;
      tmpChecks.FTypeColor:=FTypeColor;
      tmpChecks.FTypeCommentField:=FTypeCommentField;
      tmpChecks.Empty:=False;
    END;  //with
END;  //procedure pCopyChecks

Procedure TpCheckForm.pInsertChecks;
BEGIN
  IF NOT tmpChecks.Empty THEN
    BEGIN
      WITH PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^ DO
        BEGIN
          IF RangeEdit.Enabled THEN
            BEGIN
              FLegal:=tmpChecks.FLegal;
              FRangeDefined:=tmpChecks.FRangeDefined;
              FMin:=tmpChecks.FMin;
              FMax:=tmpChecks.FMax;
            END;
          FValueLabel:=tmpChecks.FValueLabel;
          FJumps:=tmpChecks.FJumps;
          FJumpResetChar:=tmpChecks.FJumpResetChar;
          FMustEnter:=tmpChecks.FMustEnter;
          FRepeat:=tmpChecks.FRepeat;
          FDefaultValue:=tmpChecks.FDefaultValue;
          FNoEnter:=tmpChecks.FNoEnter;
          FConfirm:=tmpChecks.FConfirm;
          FTypeComments:=tmpChecks.FTypeComments;
          FTypeColor:=tmpChecks.FTypeColor;
          FTypeCommentField:=tmpChecks.FTypeCommentField;
        END;  //with
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
      UpDateCheckForm(TObject(TheDatafile^.FieldList.Items[TheDatafile^.CurField]));
    END;  //if NOT tmpChecks.empty
END;  //procedure pInsertChecks


Procedure TpCheckForm.pCutChecks;
BEGIN
  WITH PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^ DO
    BEGIN
      tmpChecks.FNoEnter:=FNoEnter;
      tmpChecks.FLegal:=FLegal;
      tmpChecks.FValueLabel:=FValueLabel;
      tmpChecks.FRangeDefined:=FRangeDefined;
      tmpChecks.FMin:=FMin;
      tmpChecks.FMax:=FMax;
      tmpChecks.FJumps:=FJumps;
      tmpChecks.FJumpResetChar:=FJumpResetChar;
      tmpChecks.FMustEnter:=FMustEnter;
      tmpChecks.FRepeat:=FRepeat;
      tmpChecks.FDefaultValue:=FDefaultValue;
      tmpChecks.FConfirm:=FConfirm;
      tmpChecks.FTypeComments:=FTypeComments;
      tmpChecks.FTypeColor:=FTypeColor;
      tmpChecks.FTypeCommentField:=FTypeCommentField;
      tmpChecks.Empty:=False;
      FNoEnter:=False;
      FLegal:='';
      FValueLabel:='';
      FRangeDefined:=False;
      FJumps:='';
      FJumpResetChar:=#0;
      FMustEnter:=False;
      FRepeat:=False;
      FDefaultValue:='';
      FConfirm:=False;
      FTypeComments:=False;
      FTypeColor:=0;
      FTypeCommentField:=-1
    END;  //with
  CheckFileModified:=True;
  SaveBtn.Enabled:=True;
  UpDateCheckForm(TObject(TheDatafile^.FieldList.Items[TheDatafile^.CurField]));
END;  //procedure pCutChecks

procedure TpCheckForm.RangeEditKeyPress(Sender: TObject; var Key: Char);
begin
  IF Key=#13 THEN
    BEGIN
      Key:=#0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;
end;

procedure TpCheckForm.RepeatComboKeyPress(Sender: TObject; var Key: Char);
begin
  IF Key=#13 THEN
    BEGIN
      Key:=#0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;
end;

Procedure TpCheckForm.UpdateValLabelCombo;
BEGIN
  WITH ValLabelCombo DO
    BEGIN
      Items.Clear;
      Items.AddObject(' '+Lang(20604),NIL);   //'[none]'
      Items.AddStrings(TheDatafile^.ValueLabels);
    END;
END;  //UpdateValLabelCombo


procedure TpCheckForm.GenerateLabelClick(Sender: TObject);
VAR
  s:String[40];
  n:Integer;
  ALabelRec: PLabelRec;
begin
  {$IFNDEF epidat}
  LabelEditForm:=TLabelEditForm.Create(MainForm);
  LabelEditForm.ContainsLabel:=True;
  LabelEditForm.df:=TheDatafile;
  IF ValLabelCombo.ItemIndex<1 THEN
    BEGIN
      WITH LabelEditForm.Memo1 DO
        BEGIN
          s:=Lang(20852)+'_'+trim(PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FName);  //'Label'
          Lines.Text:='LABEL '+s+#13'  '#13'END';  //*** Lang(22816) obsolete
          SelStart:=10+Length(s);
          SelLength:=0;
        END;  //with
    END
  ELSE
    BEGIN
      WITH LabelEditForm DO
        BEGIN
          s:=ValLabelCombo.Items[ValLabelCombo.ItemIndex];
          FieldBlockLabel:=False;
          LblFileLabel:=False;
          IF s[Length(s)]='¤' THEN
            BEGIN
              Delete(s,Length(s),1);
              LblFileLabel:=True;
            END
          ELSE
            BEGIN
              LblFileLabel:=False;
              IF s[Length(s)]='$' THEN
                BEGIN
                  Delete(s,Length(s),1);
                  FieldBlockLabel:=True;
                END
              ELSE FieldBlockLabel:=False;
            END;
          Memo1.Lines.Text:=Label2Text(s,
            PLabelRec(ValLabelCombo.Items.Objects[ValLabelCombo.ItemIndex]),0);
          IF FieldBlockLabel THEN Memo1.Lines[0]:='COMMENT LEGAL';
          Memo1.Selstart:=0;
        END;  //with
    END;
  LabelEditForm.Memo1.Modified:=False;
  LabelEditForm.ShowModal;
  IF (LabelEditForm.ActionDone<>acCancel) AND (LabelEditForm.ActionDone<>acNone) THEN
    BEGIN
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
    END;
  CASE LabelEditForm.ActionDone OF
    acNewLabel:BEGIN
        TheDatafile^.ValueLabels.AddObject(LabelEditForm.Labelname,
          TObject(LabelEditForm.LabelPointer));
        UpdateValLabelCombo;
        ValLabelCombo.ItemIndex:=
          ValLabelCombo.Items.IndexOf(LabelEditForm.Labelname);
        PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FValueLabel:=
          LabelEditForm.Labelname;
      END;  //case acNewLabel
    acCheckFileLabelChanged:BEGIN
        {Dispose existing label, add new, update combo}
        n:=TheDatafile^.ValueLabels.IndexOf(LabelEditForm.Labelname);
        ALabelRec:=PLabelRec(TheDatafile^.ValueLabels.Objects[n]);
        DisposeLabelRec(ALabelRec);
        TheDatafile^.ValueLabels.Objects[n]:=TObject(LabelEditForm.LabelPointer);
        UpdateValLabelCombo;
        ValLabelCombo.ItemIndex:=ValLabelCombo.Items.IndexOf(LabelEditForm.Labelname);
        PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FValueLabel:=
          LabelEditForm.Labelname;
      END;  //case acCheckFileLabelChanged
    acFieldBlockLabelChanged:BEGIN
        n:=TheDatafile^.ValueLabels.IndexOf(s+'$');
        ALabelRec:=PLabelRec(TheDatafile^.ValueLabels.Objects[n]);
        DisposeLabelRec(ALabelRec);
        TheDatafile^.ValueLabels.Objects[n]:=TObject(LabelEditForm.LabelPointer);
        ValLabelCombo.ItemIndex:=ValLabelCombo.Items.IndexOf(s+'$');
        ValLabelCombo.Items.Objects[ValLabelCombo.ItemIndex]:=TObject(LabelEditForm.LabelPointer);
      END;
    acLabelFileLabelChanged:BEGIN
        n:=TheDatafile^.ValueLabels.IndexOf(LabelEditForm.Labelname);
        ALabelRec:=PLabelRec(TheDatafile^.ValueLabels.Objects[n]);
        DisposeLabelRec(ALabelRec);
        TheDatafile^.ValueLabels.Objects[n]:=TObject(LabelEditForm.LabelPointer);
        s:=TheDatafile^.ValueLabels[n];
        Delete(s,Length(s),1);  //Remove ¤-char from ValueLabels
        TheDatafile^.ValueLabels[n]:=s;
        UpdateValLabelCombo;
        ValLabelCombo.ItemIndex:=ValLabelCombo.Items.IndexOf(s);
        PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FValueLabel:=s;
    END;  //case acLabelFileLabelChanged
  END;  //case

  LabelEditForm.Free;
  {$ENDIF}
end;

procedure TpCheckForm.ValLabelComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
VAR
  s:String[40];
begin
  s:=ValLabelCombo.Items[Index];
  IF (s[Length(s)]='¤') or (s=' '+Lang(20604)) OR (s[Length(s)]='$') THEN  //'[none]
    BEGIN
      ValLabelCombo.Canvas.Font.Style:=[];
      IF s<>(' '+Lang(20604)) THEN s:=Copy(s,1,Length(s)-1);  //'[none]'
    END
  ELSE ValLabelCombo.Canvas.Font.Style:=[fsBold];
  ValLabelCombo.Canvas.TextRect(Rect,Rect.Left,Rect.Top,s);
end;

procedure TpCheckForm.ValLabelComboChange(Sender: TObject);
VAR
  s:String[40];
begin
  {$IFNDEF epidat}
  IF NOT ChangeGoingOn THEN
    BEGIN
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
      TheDatafile^.CurField:=TheDatafile^.FieldList.IndexOf(TEntryField(TheDatafile^.LatestActiveControl).dfField);
      s:=ValLabelCombo.Items[ValLabelCombo.ItemIndex];
      IF s=' '+Lang(20604) THEN s:='';   //'[none]'
      PeField(TheDatafile^.FieldList.Items[TheDatafile^.CurField])^.FValueLabel:=s;
    END;
  {$ENDIF}
end;

procedure TpCheckForm.JumpsEditKeyPress(Sender: TObject; var Key: Char);
VAR
  s: String;
begin
  IF Key=#13 THEN
    BEGIN
      Key:=#0;
      PostMessage(Self.Handle,WM_NextDlgCtl,0,0);
    END;
  IF Key='>' THEN GetFieldnameForJump:=True
  ELSE IF (Key=' ') AND (AnsiUpperCase(JumpsEdit.Text)='AUTOJUMP') THEN GetFieldnameForJump:=True
  ELSE GetFieldnameForJump:=False;
  s:=JumpsEdit.Text;
  IF trim(JumpsEdit.Text)<>'' THEN
    BEGIN
      IF (JumpsEdit.Text[Length(JumpsEdit.Text)]='>')
      OR (Copy(JumpsEdit.Text,Length(JumpsEdit.Text)-1,2)='> ') THEN GetFieldnameForJump:=True;
      IF Key=#8 THEN
        BEGIN
          IF (JumpsEdit.Text[Length(JumpsEdit.Text)-1]='>')
          OR (Copy(JumpsEdit.Text,Length(JumpsEdit.Text)-2,2)='> ')
          OR (AnsiUpperCase(Copy(JumpsEdit.Text,1,9))='AUTOJUMP ') THEN GetFieldnameForJump:=True;
        END;
    END;

end;

procedure TpCheckForm.EditChecksBtnClick(Sender: TObject);
VAR
  ChkLines:TStringList;
begin
  {$IFNDEF epidat}
  ChkLines:=TStringList.Create;
  LabelEditForm:=TLabelEditForm.Create(MainForm);
  LabelEditForm.Caption:=Lang(22818);   //'Edit checks for this field'
  LabelEditForm.ContainsLabel:=False;
  LabelEditForm.df:=TheDatafile;
  FieldBlockToStrings(TheDatafile, ChkLines, TheDatafile^.CurField,0);
  IF ChkLines.Count=0 THEN
    BEGIN
      ChkLines.Append(PeField(TheDatafile^.FieldList[TheDatafile^.CurField])^.FName);
      ChkLines.Append('  ');
      ChkLines.Append('END');
    END;
  LabelEditForm.Memo1.Lines.Text:=ChkLines.Text;
  LabelEditForm.Memo1.SelStart:=
    SendMessage(LabelEditForm.Memo1.Handle, EM_LINEINDEX, 1, 0)+2;
  ChkLines.Free;
  MultiLineError:=False;
  LabelEditForm.Memo1.Modified:=False;
  IF LabelEditForm.ShowModal=mrOK THEN
    BEGIN
      CheckFileModified:=True;
      SaveBtn.Enabled:=True;
    END;
  LabelEditForm.Free;
  UpdateCheckForm(TObject(TheDatafile^.FieldList.Items[TheDatafile^.CurField]));
  {$ENDIF}
end;


Function LoadAsserts(CONST AssertFilename:TFilename;
         VAR AssList: TList; VAR df:PDataFileInfo; VAR ReportField:Integer):Boolean;
VAR
  tmpAss: TAssert;
  PtmpAss: PAssert;
  tmpS: String;
BEGIN
  {Loads logical consistency checks (asserts) from the specified AssertFilename and puts the
   assert into AssList. Returns True if succesfull.
   Syntax of asserts:
     ASSERT assertname assertexpression  }

  ChkLin:=NIL;
  ReportField:=-1;   //Means that Assert-funktion reports back the record-number
  TRY
    ChkLin:=TStringList.Create;
    CurLin:='';
    CurLinIndex:=-1;
    Result:=False;
    EndOfChkFile:=False;
    ChkLin.LoadFromFile(AssertFilename);
    IF ChkLin.Count=0 THEN Exit;
    REPEAT
      INC(CurLinIndex);
    UNTIL (AnsiUppercase(trim(ChkLin[CurLinIndex]))='CONSISTENCYBLOCK') OR (CurLinIndex=ChkLin.Count-1);
    IF CurLinIndex=ChkLin.Count-1 THEN
      BEGIN
        {$IFNDEF epidat}
        ErrorMsg(Format(Lang(22844),[AssertFilename]));  //'No consistencyblock found in %s'
        {$ENDIF}
        Exit;
      END;
    CurCommand:='';
    WHILE (AnsiUpperCase(CurCommand)<>'END') AND (NOT EndOfChkFile) DO
      BEGIN
        tmpAss.AssName:='';
        tmpAss.AssExpr:='';
        tmpAss.ViolCount:=0;
        tmpAss.Violaters:='';
        CurCommand:=AnsiUpperCase(NexttWord(nwAny));
        IF CurCommand='REPORT' THEN
          BEGIN
            CurCommand:=NexttWord(nwSameLine);
            ReportField:=GetFieldNumber(CurCommand,df);
            IF ReportField=-1 THEN
              BEGIN
                {$IFNDEF epidat}
                ErrorMsg(Format(Lang(22846),  //'Error in file %s~Unknown fieldname %s found after REPORT in line %d'
                [AssertFilename,CurCommand,CurLinIndex+1]));
                {$ENDIF}
                Exit;
              END;
          END
        ELSE IF CurCommand='CHECK' THEN
          BEGIN
            //Get name of assert
            tmpAss.AssName:=NexttWord(nwSameLine);
            IF trim(tmpAss.AssName)='' THEN
              BEGIN
                {$IFNDEF epidat}
                ErrorMsg(Format(Lang(22848),  //'Error in file %s~No name found for consistency check in line %d'
                [AssertFilename,CurLinIndex+1]));
                {$ENDIF}
                Exit;
              END;

            //Get asssert expression
            REPEAT
              CurCommand:=NexttWord(nwSameKeepQuotes);
              tmpAss.AssExpr:=tmpAss.AssExpr+' '+CurCommand;
            UNTIL CurCommand='';
            tmpS:=trim(tmpAss.AssExpr);
            IF tmpAss.AssExpr='' THEN
              BEGIN
                {$IFNDEF epidat}
                ErrorMsg(Format(Lang(22850),  //'Error in file %s~No consistency check expression found in line %d'
                [AssertFilename,CurLinIndex+1]));
                {$ENDIF}
                Exit;
              END;
            tmpAss.OrigExpr:=tmpS;
            //HandleBooleanConditions(tmpS);
            Double2SingleQuotes(tmpS);
            tmpAss.AssExpr:='('+trim(tmpS)+')';
            New(PtmpAss);
            PtmpAss^:=tmpAss;
            AssList.Add(PtmpAss);
          END;  //if Assert found
      END;  //while not EndOfChkFile
    Result:=True;
  FINALLY
    ChkLin.Free;
  END;
END;


procedure TpCheckForm.FormDeactivate(Sender: TObject);
begin
  IF self.ActiveControl=RangeEdit THEN RangeEditExit(sender)
  ELSE IF (self.ActiveControl=JumpsEdit) AND (Length(JumpsEdit.Text)>0) THEN
    BEGIN
      IF JumpsEdit.Text[Length(JumpsEdit.Text)]<>'>' THEN JumpsEditExit(sender);
    END;
end;

Initialization
  GetFieldnameForJump:=False;


end.
