unit DataFormUnit;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ExtCtrls, ComCtrls, Buttons, EPITypes, Menus, Math,
  prExpr, Printers, ToolWin, ImgList, Clipbrd;

type
  TDataForm = class(TForm)
    DataFormStatusBar: TStatusBar;
    RecNavPanel: TPanel;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    FirstRecButton: TSpeedButton;
    PrevRecButton: TSpeedButton;
    CurRecEdit: TEdit;
    NextRecButton: TSpeedButton;
    LastRecButton: TSpeedButton;
    Panel2: TPanel;
    MainMenu1: TMainMenu;
    Goto1: TMenuItem;
    Nextrecord1: TMenuItem;
    Previousrecord1: TMenuItem;
    Firstrecord1: TMenuItem;
    Lastrecord1: TMenuItem;
    GotoRecord1: TMenuItem;
    N1: TMenuItem;
    Markrecordfordeletion1: TMenuItem;
    Newrecord1: TMenuItem;
    Panel3: TPanel;
    NewRecButton: TSpeedButton;
    DeleteRecButton: TSpeedButton;
    DeletePanel: TPanel;
    File1: TMenuItem;
    Closeform1: TMenuItem;
    Exit1: TMenuItem;
    N3: TMenuItem;
    Firstfield1: TMenuItem;
    Lastfield1: TMenuItem;
    N2: TMenuItem;
    Fields1: TMenuItem;
    Firstfield2: TMenuItem;
    Lastfield2: TMenuItem;
    ScrollUp1: TMenuItem;
    ScrollDown1: TMenuItem;
    ScrollUp2: TMenuItem;
    ScrollDown2: TMenuItem;
    EditChecks1: TMenuItem;
    TypePanel: TPanel;
    ShowIndexfile1: TMenuItem;
    Dataentrynotes1: TMenuItem;
    N4: TMenuItem;
    Filter1: TMenuItem;
    Setfilter1: TMenuItem;
    Deactivatefilter1: TMenuItem;
    Printdataform1: TMenuItem;
    PrintDialog1: TPrintDialog;
    Saverelatelist1: TMenuItem;
    Findfield1: TMenuItem;
    Findfield2: TMenuItem;
    Findrelatefield1: TMenuItem;
    Findrecord2: TMenuItem;
    Findagain1: TMenuItem;
    Exporttotextfile1: TMenuItem;
    procedure CMDialogKey(var Msg: TCMDialogKey);  message CM_DIALOGKEY;
    procedure PutQuestionOnForm(q:STRING; pTop,pLeft:Integer);
    Procedure PutFieldsOnForm;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure ClearFields;
    procedure onChangeEvent(Sender: TObject);
    procedure onEnterEvent(Sender: TObject);
    procedure HandleBoolean(Sender: TObject);
    Function  HandleDates(Sender: TObject):Boolean;
    Function  HandleInteger(Sender: TObject):Boolean;
    Function  HandleFloat(Sender: TObject):Boolean;
    Function  HandleSoundex(Sender: TObject):Boolean;
    Function  HandleLegal(Sender: TObject):Boolean;
    Function  HandleCommentLegal(Sender: TObject):Boolean;
    Function  HandleJumps(dfField:PeField):Boolean;
    procedure OnKeyPressEvent(Sender: TObject; var Key: Char);
//    function  CanExitField(Sender: TObject):Boolean;
//    Function  ValidateField(Action:TChangeFieldActions):Boolean;
    Function  CheckDoubleEntry(AField:PeField):Boolean;
    Procedure LeaveField(LeaveStyle: TLeaveStyles);
    procedure onExitEvent(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure UpdateCurRecEdit(CurRec,TotalRec:Integer);
    Function  FieldListModfied:Boolean;
    procedure PrevRecButtonClick(Sender: TObject);
    procedure NextRecButtonClick(Sender: TObject);
    procedure FirstRecButtonClick(Sender: TObject);
    procedure LastRecButtonClick(Sender: TObject);
    procedure Newrecord1Click(Sender: TObject);
    procedure DeleteRecButtonClick(Sender: TObject);
    procedure GotoRecord1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ShowLegalPickList(ACaption: String);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    Procedure FocusFirstField;
    Procedure FocusLastField;
    procedure Firstfield1Click(Sender: TObject);
    procedure Lastfield1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SearchRecords(Sender: TObject);
    Procedure FindEditClick(Sender: TObject);
    Procedure FindNewClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    Procedure ShowFieldInfo;
    Procedure ShowVarInfo;
    procedure ScrollUp1Click(Sender: TObject);
    procedure ScrollDown1Click(Sender: TObject);
{    Function  HandleVars( const Identifier: String; ParameterList: TParameterList): IValue;}
    Procedure ExecCommandList(VAR CmdList:TList);
    procedure EditChecks1Click(Sender: TObject);
    procedure ShowIndexfile1Click(Sender: TObject);
    Function  SaveRecord:Boolean;
    procedure Dataentrynotes1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure SetToReadOnly;
    Procedure RestoreReadOnly;
    Procedure ChangeRec(RecNo:LongInt; direction:TDirections);
    procedure Setfilter1Click(Sender: TObject);
    procedure Deactivatefilter1Click(Sender: TObject);
    procedure Filter1Click(Sender: TObject);
    procedure HelpBoxKeyPress(Sender: TObject; var Key: Char);
    procedure Printdataform1Click(Sender: TObject);
//    Procedure ShowLastCmds(VAR df:PDatafileInfo);
    procedure FormShow(Sender: TObject);
    procedure Saverelatelist1Click(Sender: TObject);
    Function  ShowFieldSelect(VAR AField:PeField): Integer;
    procedure Findfield1Click(Sender: TObject);
    function  ChangeRelateLevel(FromDf,ToDf: PDatafileInfo; RelFieldName: string;
              One2One: Boolean; EmptyWarning:Boolean):Integer;
    procedure Findrelatefield1Click(Sender: TObject);
    procedure Goto1Click(Sender: TObject);
    procedure ActivateRelateFile(Adf: PDatafileInfo);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Findagain1Click(Sender: TObject);
    procedure Exporttotextfile1Click(Sender: TObject);
    //Procedure Notification(AComponent: TComponent;  Operation: TOperation);  override;
   private
    { Private declarations }
    QuitEpiData: Boolean;    //###
  public
    df: PDatafileInfo;
    RelateOne2One: Boolean;
  end;

  TEntryField = class(TEdit)
  Public
    df:PDatafileInfo;       //Pointer to the datafile that contains the field
    dfField:Pointer;        //Pointer to the PeField record in the datafile
  END;

var
  DataForm: TDataForm;

  CloseWithOutChecks:Boolean;
  DbCheckFailed:Boolean;

implementation

USES
  FileUnit, MainUnit, ExportFormUnit, PeekCheckUnit,
  LegalPickListUnit, LabelEditUnit,RelateTreeUnit, fmxUtils, BackUpUnit,
  SearchFormUnit,searchunit,GridUnit, ZipFormUnit;

VAR
  FieldInfoTrigger:Byte;   //used for testing purposes
  VarInfoTrigger:Byte;
  IgnoreJumps:Boolean;    //used to avoid jumps when using Arrow-up key
  DidJump:Boolean;
  IsClosingCheckFilemode: Boolean;


{$R *.DFM}


procedure TDataForm.CMDialogKey(var Msg: TCMDialogKey);
BEGIN
  IF Msg.CharCode=VK_TAB THEN Exit;
  Inherited;
END;


procedure TDataForm.PutQuestionOnForm(q:STRING; pTop,pLeft:Integer);
VAR
  pLabel: TLabel;
BEGIN
  pLabel:=TLabel.Create(DataForm);
  pLabel.Caption:=q;
  pLabel.SetBounds(pLeft,pTop,pLabel.Width,pLabel.Height);
  //pLabel.Top:=pTop;
  //pLabel.Left:=pLeft;
  pLabel.Transparent:=True;
  pLabel.parent:=ScrollBox1;
  IF df^.QuestionText<>COLOR_ENDCOLORS THEN pLabel.Font.Color:=df^.QuestionText;
  IF df^.QuestionBg<>COLOR_ENDCOLORS THEN
    BEGIN
      pLabel.Transparent:=False;
      pLabel.Color:=df^.QuestionBg;
    END;
END;  //putQuestionOnForm

Procedure TDataForm.PutFieldsOnForm;
VAR
  n,ttop,lleft:Integer;
  AEntryField: TEntryField;
  dfF:PeField;
  MaxTop:Integer;
  S: string;
BEGIN
  IF df=NIL THEN Exit;
  IF df^.BackGround<>COLOR_ENDCOLORS THEN ScrollBox1.Color:=df^.BackGround;
  MaxTop:=0;
  WITH MainForm.ProgressBar DO BEGIN
    IF df^.FieldList.Count>2 THEN Max:=df^.FieldList.Count-2 ELSE Max:=2;
    Min:=0;
    Position:=0;
    Visible:=True;
  END;  //with
  s:=Lang(21600);   //Adding entryfield no.
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      MainForm.ProgressBar.Position:=n;
      //MainForm.StatPanel2.Caption:=' '+Lang(21600)+' '+IntToStr(n);  //Adding entryfield no.
      //MainForm.StatPanel2.Repaint;
      dfF:=PeField(df^.FieldList.Items[n]);
      WITH dfF^ DO
        BEGIN
          {Does the field have a question?}
          IF trim(FQuestion)<>'' THEN
            BEGIN
              PutQuestionOnForm(FQuestion,FQuestTop,FQuestLeft);
              IF FQuestTop>MaxTop THEN MaxTop:=FQuestTop;
            END;
          {Does the field have entryfield?}
          IF FLength>0 THEN
            BEGIN
              AEntryField:=TEntryField.Create(DataForm);
              EntryField:=Pointer(AEntryField);
              WITH AEntryField DO
                BEGIN
                  Parent:=ScrollBox1;
                  AEntryField.dfField:=Pointer(dfF);
                  MaxLength:=FLength;
                  IF Felttype=ftCrypt THEN MaxLength:=FCryptEntryLength;    //&&  Make room for base64 encryption
                  onChange:=OnChangeEvent;
                  onEnter:=OnEnterEvent;
                  onKeyPress:=onKeyPressEvent;
                  onExit:=onExitEvent;
                  Width:=FFieldWidth;
                  Top:=FFieldTop;
                  Color:=FieldColor;
                  IF self.df^.FieldText<>COLOR_ENDCOLORS THEN AentryField.Font.Color:=self.df^.FieldText;
                  IF self.df^.FieldBg<>COLOR_ENDCOLORS THEN AEntryField.Color:=self.df^.FieldBg;
                  CASE FieldStyle OF
                    0: BEGIN
                         Ctl3D:=True;
                         BorderStyle:=bsSingle;
                       END;
                    1: BEGIN
                         Ctl3D:=False;
                         BorderStyle:=bsSingle;
                       END;
                    2: BEGIN
                         Ctl3D:=False;
                         BorderStyle:=bsNone;
                       END;
                  END;
                  IF FFieldTop>MaxTop THEN MaxTop:=FFieldTop;
                  Left:=FFieldLeft;
                  Enabled:=((NOT FNoEnter) OR CheckFileMode);
                  CASE FeltType OF
                    ftSoundex:   Width:=Canvas.TextWidth('W-999')+4;
                    ftUpperAlfa: CharCase:=ecUpperCase;
                    ftToday,ftEuroToday, ftYMDtoday,     //&&
                    ftIDNUM:     Enabled:=False;
                  END;  //Case
                  ChangeGoingOn:=True;
                  Text:=trim(FFieldText);
                  ChangeGoingOn:=False;
                END;  //with EntryField
              {Does field have a Type label next to it?}
              IF (FTypeComments) or (FTypeString)
              OR ((df^.GlobalTypeCom) AND (FCommentLegalRec<>NIL)) THEN
                BEGIN
                  FTypeField:=TLabel.Create(DataForm);
                  WITH FTypeField DO
                    BEGIN
                      Caption:='';
                      Font.Assign(epiDataFormFont);
                      IF df^.GlobalTypeCom
                      THEN Font.Color:=ColorValues[df^.GlobalTypeComColor]
                      ELSE Font.Color:=ColorValues[FTypeColor];
                      Top:=FFieldTop+(AEntryField.Height DIV 2)-(FTypeField.Height DIV 2);
                      Left:=FFieldLeft+FFieldWidth+10;
                      tag:=99;  //used with cmdColor to identify TypeComment labels
//                      transparent:=true;
                      Parent:=ScrollBox1;
                    END;  //with
                END;  //if FTypeComments
            END;  //if Flength>0
        END;  //With Field
    END;  //for
  PutQuestionOnForm(' ',MaxTop+20,10);   //Make buttom margin
  MainForm.ProgressBar.Visible:=False;
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel2.Repaint;
  ScrollBox1.Visible:=True;
END;

procedure TDataForm.FormClose(Sender:TObject; var Action:TCloseAction);
VAR
  n:Integer;
  HasRelate: Boolean;
begin
  ResetFindExOptions(df);
  IF df^.IsrelateTop or df^.IsRelateFile THEN HasRelate:=True ELSE HasRelate:=False;
  IF df^.IsRelateTop THEN
    BEGIN
      PaintProperWorkbar:=True;
      IF RelateTreeCount>0 THEN
        BEGIN
          RelateTreeForm.Close;
        END;
      FOR n:=0 TO RelateFiles.Count-1 DO
        BEGIN
          PDataFileInfo(RelateFiles.Objects[n])^.CanActivate:=True;
          TDataForm(PDataFileInfo(RelateFiles.Objects[n])^.DatForm).RestoreReadOnly;
          PDataFileInfo(RelateFiles.Objects[n])^.IsRelateFile:=False;
          TDataForm(PDataFileInfo(RelateFiles.Objects[n])^.DatForm).Close;
        END;
      RelateFiles.Free;
      RelateFiles:=NIL;
      RelateMothers.Free;
      RelateMothers:=NIL;
      DoUseSounds:=False;
      //IF RelateTreeCount>0 THEN RelateTreeForm.Close;
      MainForm.ShowRelateTreeMenuItem.Enabled:=False;
      MainForm.ShowRelateTreeMenuItem.Visible:=False;
    END;
  IF NOT IsClosingCheckFilemode THEN df^.OKToBackup:=True;
  SaveScreenCoords(df);
  //****************************** move from FormCloseQuery 24/08/02
  IF (NOT TestingDataForm) AND (NOT CheckFileMode) AND (Assigned(df^.AfterFileCmds)) THEN
    BEGIN
      df^.DatFile.Free;
      df^.DatFile:=NIL;
      ExecCommandList(df^.AfterFileCmds);
    END;
  //****************************** end of move *******
  IF df<>NIL THEN DisposeDatafilePointer(df);
  IF TestDataFormCreated THEN TestDataFormCreated:=False;
  IF (TestingDataform) OR (OpenWithRelate) THEN
    BEGIN
      MainForm.TabCtrl.Tabs.Delete(MainForm.TabCtrl.Tabs.IndexOfObject(TObject(self)));
      IF MainForm.TabCtrl.Tabs.Count=0 THEN MainForm.TabCtrl.Visible:=False;
    END;

  IF (HideToolBarsDuringDataEntry) AND (NOT TestingDataForm) THEN
    BEGIN
      MainForm.EditorToolBar.Visible:=OldEditorToolbar;
      MainForm.WorkProcessToolBar.Visible:=OldWorkProcessToolBar;
    END;
  TestingDataForm:=False;
  MainForm.StatPanel1.Caption:='';
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel3.Caption:='';
  MainForm.StatPanel4.Caption:='';
  MainForm.StatPanel5.Caption:='';
  MainForm.StatPanel6.Caption:='';
  MainForm.UpdateButtonStatus(sender);
//  IF QuitEpiData THEN MainForm.Close;   //###
  Action:=caFree;
end;   //procedure FormClose


Procedure TDataForm.ClearFields;
VAR
  n:Integer;
  s:string;
BEGIN
  ChangeGoingOn:=True;
  FOR n:=0 TO df^.FieldList.Count-1 DO
    WITH PeField(df^.FieldList.Items[n])^ DO
      BEGIN
        IF  (Felttype<>ftToday)    AND (Felttype<>ftEuroToday) AND (Felttype<>ftYMDToday)  //&&
        AND (Felttype<>ftQuestion) AND (Felttype<>ftIDNUM)
        AND (FRepeat=False)        AND (NOT ((df^.UseFilter) AND (n=df^.FilterField)))   THEN
          BEGIN
            FFieldText:='';
            TEntryField(EntryField).Text:='';
            IF (FTypeComments) or (FTypeString)
            OR ((df^.GlobalTypeCom) AND (FCommentLegalRec<>NIL)) THEN FTypeField.Caption:='';
          END;
        IF (Felttype<>ftQuestion) AND ((FDefaultValue<>'') OR (FHasGlobalDefaultValue))
        AND (FRepeat=False) AND (NOT ((df^.UseFilter) AND (n=df^.FilterField))) THEN
          BEGIN
            IF (FDefaultValue<>'') THEN s:=FDefaultValue
            ELSE IF (FHasGlobalDefaultValue) THEN s:=df^.GlobalDefaultValue;
            FFieldText:=s;
            TEntryField(EntryField).Text:=s;
            IF (FTypeComments) or (FTypeString)
            OR ((df^.GlobalTypeCom) AND (FCommentLegalRec<>NIL)) THEN FTypeField.Caption:='';
          END;
      END;  //with
  ChangeGoingOn:=False;
END;  //procedure ClearFields

// ************************** FIELDEVENTS ****************************

procedure TDataForm.HandleBoolean(Sender: TObject);
VAR
  MidText:STRING;
BEGIN
  ChangeGoingOn:=TRUE;
  WITH Sender AS TEntryField DO
    BEGIN
      MidText:=Text;
      IF (Midtext='y') or (Midtext='1') or (Midtext='Y') THEN Midtext:='Y';
      IF (Midtext='n') or (Midtext='0') or (Midtext='N') THEN Midtext:='N';
      IF (Midtext<>'Y') AND (Midtext<>'N') THEN Midtext:='';
      Text:=MidText;
      PeField(dfField)^.FFieldText:=MidText;
      IF text<>'' THEN SelStart:=1;
  END;   //with
  ChangeGoingOn:=FALSE;
END;   //handleboolean

Function TDataForm.HandleDates(Sender: TObject):Boolean;

VAR
  qq,TempLen:Integer;
  TempT,eMonthStr,eDayStr,eYearStr:String;   //&&
  eDay2,eMonth2:Word;
  afield: PeField;
BEGIN
  Result:=True;
  WITH Sender AS TEntryField DO
    BEGIN
      TempT:=Text;
      afield:=PeField(dfField);
      IF (TempT='-') AND (afield^.FMissingValues[0]<>'') THEN
        BEGIN
          TempT:=afield^.FMissingValues[0];
          ChangeGoingOn:=True;
          Text:=TempT;
          ChangeGoingOn:=False;
        END
      ELSE
        IF (TempT='-') AND (df^.GlobalMissingValues[0]<>'') THEN
          BEGIN
            TempT:=df^.GlobalMissingValues[0];
            ChangeGoingOn:=True;
            Text:=TempT;
            ChangeGoingOn:=False;
          END;

      IF trim(text)<>'' THEN
        BEGIN
          IF pos('/',TempT)<>0 THEN
            BEGIN
              IF (PeField(dfField)^.Felttype=ftYMDDate) THEN  //&&
                BEGIN
                  qq:=pos('/',TempT);
                  TempT[qq]:='¤';
                  IF pos('/',TempT)>0 THEN
                    BEGIN
                      //String has two slashes meaning year is included
                      eYearStr:=Copy(TempT,1,pos('¤',TempT)-1);
                      Delete(TempT,1,pos('¤',TempT));    //deletes year and separator
                      eMonthStr:=copy(TempT,1,pos('/',TempT)-1);
                      Delete(TempT,1,pos('/',TempT));   //deletes month and second separator
                      eDayStr:=TempT;
                    END
                  ELSE
                    BEGIN
                      //String has one slash meaning year is not included
                      eYearStr:='';
                      eMonthStr:=copy(TempT,1,pos('¤',TempT)-1);
                      Delete(TempT,1,pos('¤',TempT));  //deletes month and separator
                      eDayStr:=TempT;
                    END;
                END  //if ftYMDDate
              ELSE
                BEGIN
                  //string is not ftYMDDate
                  eMonthStr:=Copy(TempT,1,pos('/',TempT)-1);
                  Delete(TempT,1,pos('/',TempT));
                  IF pos('/',TempT)<>0 THEN
                    BEGIN
                      eDayStr:=Copy(TempT,1,pos('/',TempT)-1);
                      Delete(TempT,1,pos('/',TempT));
                      eYearStr:=TempT;
                      IF trim(eYearStr)='' THEN eYearStr:='';
                    END
                  ELSE
                    BEGIN
                      eDayStr:=TempT;
                      IF trim(eDayStr)='' THEN eDayStr:='';
                      eYearStr:='';
                    END;   //if there is a second slash
                END  //if not YMDDate
            END   //if there is a first slash
          ELSE
            BEGIN   //the string contains no slash
              IF (PeField(dfField)^.Felttype=ftYMDDate) THEN  //&&
                BEGIN
                  eMonthStr:='';
                  eDayStr:='';
                  eYearStr:='';
                  CASE Length(TempT) OF
                    1,2: eDayStr:=trim(TempT);
                    4:   BEGIN
                           eMonthStr:=Copy(TempT,1,2);
                           eDayStr:=Copy(TempT,3,2);
                         END;
                    6:   BEGIN
                           eYearStr:=Copy(TempT,1,2);
                           eMonthStr:=Copy(TempT,3,2);
                           eDayStr:=Copy(TempT,5,2);
                         END;
                    8:   BEGIN
                           eYearStr:=Copy(TempT,1,4);
                           eMonthStr:=Copy(TempT,5,2);
                           eDayStr:=Copy(TempT,7,2);
                         END;
                  ELSE
                    result:=False;
                  END;  //case
                END  //if ftYMDDate
              ELSE
                BEGIN
                  WHILE Length(TempT)<8 DO TempT:=TempT+' ';
                  eMonthStr:=Copy(TempT,1,2);
                  eDayStr:=Copy(TempT,3,2);
                  eYearStr:=Copy(TempT,5,4);
                END;
            END;
          {Is only a day given without month and year?}
          IF PeField(dfField)^.Felttype<>ftYMDDate THEN
            BEGIN
              IF (trim(eMonthStr)<>'') AND (trim(eDayStr)='') AND (trim(eYearStr)='') THEN
                BEGIN
                  DecodeDate(Date,eYear,eMonth2,eDay2);
                  eYearStr:=IntToStr(eYear);
                  IF PeField(dfField)^.Felttype=ftDate THEN
                    BEGIN
                      eDayStr:=eMonthStr;
                      eMonthStr:=IntToStr(eMonth2);
                    END
                  ELSE eDayStr:=IntToStr(eMonth2);
                END;
            END
          ELSE
            BEGIN
              //type is ftYMDDate
              IF (trim(eDayStr)<>'') AND (trim(eMonthStr)='') AND (trim(eYearStr)='') THEN
                BEGIN
                  DecodeDate(Date,eYear,eMonth2,eDay2);
                  eYearStr:=IntToStr(eYear);
                  eMonthStr:=IntToStr(eMonth2);
                END;
            END;
          IF (trim(eMonthStr)<>'') AND (isInteger(eMonthStr))
            THEN eMonth:=StrToInt(trim(eMonthStr)) ELSE Result:=False;
          IF (trim(eDayStr)<>'') AND (IsInteger(eDayStr))
            THEN eDay:=StrToInt(trim(eDayStr)) ELSE Result:=False;
          IF (trim(eYearStr)='') THEN
            BEGIN
              DecodeDate(Date,eYear,eMonth2,eDay2);
              eYearStr:=IntToStr(eYear);
            END
          ELSE
            IF IsInteger(eYearStr)
              THEN eYear:=StrToInt(trim(eYearStr))
            ELSE
              BEGIN
                Result:=False;
                eYear:=0;
              END;
          IF PeField(dfField)^.Felttype=ftEuroDate THEN
            BEGIN
              TempLen:=eMonth;
              eMonth:=eDay;
              eDay:=TempLen;
            END;
          IF (eYear>=0) AND (eYear<50) THEN eYear:=eYear+2000;
          IF (eYear>=50) AND (eYear<100) THEN eYear:=eYear+1900;
          IF (eMonth>12) OR (eMonth<1) THEN Result:=False
          ELSE
            BEGIN
              IF (eDay>DaysInMonth[eMonth]) OR (eDay<1) THEN Result:=False;
              IF (eDay=29) AND (eMonth=2) AND (PeField(dfField)^.FLength>5)
                THEN IF IsLeapYear(eYear) THEN Result:=True ELSE Result:=False;
            END;
          {Formatter output}
          IF Result THEN  //legal date entered
            BEGIN
              TempT:='';
              IF PeField(dfField)^.Felttype<>ftYMDDate THEN
                BEGIN
                  IF PeField(dfField)^.Felttype=ftDate
                    THEN TempT:=ZeroFormatInteger(eMonth)+'/'+ZeroFormatInteger(eDay)
                    ELSE TempT:=ZeroFormatInteger(eDay)+'/'+ZeroFormatInteger(eMonth);
                  IF PeField(dfField)^.FLength=8 THEN TempT:=TempT+'/'+ZeroFormatInteger(eYear MOD 100);
                  IF PeField(dfField)^.FLength=10 THEN TempT:=TempT+'/'+ZeroFormatInteger(eYear);
                END
              ELSE TempT:=ZeroFormatInteger(eYear)+'/'+ZeroFormatInteger(eMonth)+'/'+ZeroFormatInteger(eDay);  //&&
              ChangeGoingOn:=True;
              Text:=TempT;
              PeField(dfField)^.FFieldText:=TempT;
              ChangeGoingOn:=False;
            END
          ELSE
            BEGIN
              TempT:=Lang(21602)+#13#13;   //'Illegal date entered.'
              WITH PeField(dfField)^ DO
                BEGIN
                  CASE Felttype of
                    ftDate:     TempT:=Lang(21604);  //'"mmddyyyy" or "mm/dd/yyyy"'
                    ftEuroDate: TempT:=Lang(21606);  //'"ddmmyyyy" or "dd/mm/yyyy"'
                    ftYMDDate:  TempT:=Lang(21607);   //21607='yyyymmdd' or 'yyyy/mm/dd'
                  END;  //case
                END;  //with PeField
              TempT:=Lang(21602)   //'Illegal date entered.'
              +#13#13+Lang(21608)+' '+TempT;  //'Please enter dates in this field as '
              ErrorMsg(TempT);
            END;  //if illegal date entered
        END;  //if Text<>''
    END;  //with sender as TEntryField
END;  //function HandleDates


Function TDataForm.HandleInteger(Sender: TObject):Boolean;
VAR
  SenderField: TEntryField;
  dfField: PeField;
BEGIN
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  IF (trim(SenderField.Text)='') OR (IsInteger(SenderField.Text)) THEN Result:=True ELSE Result:=False;
  IF NOT Result THEN ErrorMsg(Format(Lang(21610),[SenderField.Text]));   //'%s is not a valid integer value'
END;  //function HandleInteger

Function TDataForm.HandleFloat(Sender: TObject):Boolean;
Var
  NumDec: Byte;
  TempT: String;
  FLen,hfN:Integer;
  TempNum:Double;
  SenderField:TEntryField;
  dfField: PeField;
BEGIN
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  Result:=True;
  NumDec:=0;
  TempT:=Trim(SenderField.Text);
  IF (TempT='-') AND (dfField^.FMissingValues[0]<>'') THEN TempT:=dfField^.FMissingValues[0]
  ELSE IF (TempT='-') AND (df^.GlobalMissingValues[0]<>'') THEN TempT:=df^.GlobalMissingValues[0];
  IF Length(TempT)>dfField^.FLength THEN TempT:='';
  IF TempT<>'' THEN
    BEGIN
      FOR hfN:=1 TO Length(TempT) DO
        BEGIN
          IF TempT[hfN]=',' THEN TempT[hfN]:=DecimalSeparator;
          IF TempT[hfN]='.' THEN TempT[hfN]:=DecimalSeparator;
          IF TempT[hfN]=DecimalSeparator THEN INC(NumDec);
        END;
      IF NumDec>1 THEN
        BEGIN
          Result:=False;
          ErrorMsg(Lang(21612));   //'Too many decimalpoints entered.'
        END
      ELSE
        BEGIN    //max one decimalpoint entered
          NumDec:=dfField^.FNumDecimals;
          Flen:=dfField^.FLength;
          FOR hfN:=1 TO Length(TempT) DO
            IF NOT (TempT[hfN] in FloatChars) THEN Result:=False;
          IF NOT Result THEN
            ErrorMsg(Lang(21614))    //'Only numbers and decimalspoint allowed in this field.'
          ELSE
            BEGIN   //only legal chars is entered
              TempNum:=StrToFloat(TempT);
              IF (NumDec>0)
              AND (ABS(INT(TempNum))>( Power(10,Flen-1-NumDec)-1)) THEN
                BEGIN
                  Result:=False;
                  ErrorMsg(Lang(21616));  //'The entered number is to big.'
                END
              ELSE
                BEGIN   //The entered number fits the length of the field
                  Str(TempNum:Flen:NumDec,TempT);
                  ChangeGoingOn:=True;
                  SenderField.Text:=Trim(TempT);
                  dfField^.FFieldText:=SenderField.Text;
                  ChangeGoingOn:=False;
                END;  //else
            END;  //only legal chars entered
        END;  //max one decimalpoint entered
    END;  //if entry<>''
END;  //Function HandleFloat


Function TDataForm.HandleSoundex(Sender: TObject):Boolean;
VAR
  SenderField:TEntryField;
  dfField: PeField;
  s: String;
BEGIN   //function handleSoundex
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  IF SenderField.Modified THEN
    BEGIN
      IF (SenderField.Text='-') AND (dfField^.FMissingValues[0]<>'') THEN s:=dfField^.FMissingValues[0]
      ELSE IF (SenderField.Text='-') AND (df^.GlobalMissingValues[0]<>'') THEN s:=df^.GlobalMissingValues[0]
      ELSE s:=Soundex(SenderField.Text);
      IF Length(s)>dfField^.FLength THEN s:='';
      ChangeGoingOn:=True;
      SenderField.Text:=s;
      dfField.FFieldText:=SenderField.Text;
      SenderField.Modified:=False;
      ChangeGoingOn:=False;
    END;
  Result:=True;
END;   //function handleSoundex


Function  TDataForm.HandleLegal(Sender: TObject):Boolean;
VAR
  Value,LegalStr:String;
  NumValue:Double;
  NumField,RangeResult,LegalResult,ValueError:Boolean;
  LegalVals:TStrings;
  n:Integer;
  SenderField:TEntryField;
  dfField: PeField;
BEGIN
  TRY
    LegalVals:=TStringList.Create;
  EXCEPT
    LegalVals.Free;
    ErrorMsg(Format(Lang(20204),[231]));   //'Out of memory (reference-code 231).'
    Result:=False;
    Exit;
  END;  //try..except
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  Value:=trim(SenderField.Text);
  IF Value='' THEN
    BEGIN
      Result:=True;
      LegalVals.Free;
      Exit;
    END;
  Result:=False;
  NumValue:=0;
  LegalStr:=dfField^.FLegal;
  WHILE Pos('"',LegalStr)>0 DO Delete(LegalStr,Pos('"',LegalStr),1);
  ValueError:=True;
  NumField:=False;
  CASE dfField^.Felttype OF
    ftInteger,ftFloat:
      BEGIN
        NumField:=True;
        IF IsFloat(Value) THEN
          BEGIN
            ValueError:=False;
            NumValue:=eStrToFloat(Value);
          END;
      END;
    ftDate,ftEuroDate,ftYMDDate:  //&&
      BEGIN
        NumField:=True;
        IF mibIsDate(Value,dfField^.FeltType) THEN
          BEGIN
            ValueError:=False;
            NumValue:=mibStrToDate(Value,dfField^.Felttype);
          END;
      END;
  ELSE ValueError:=False;
  END;  //case

  {Test if value is in defined range}
  RangeResult:=False;
  IF dfField^.FRangedefined THEN
    BEGIN
      RangeResult:=True;
      {Test if >= minimum}
      IF dfField^.FMin<>'' THEN
        BEGIN
          CASE dfField^.FeltType OF
            ftInteger,ftFloat: IF NOT (NumValue>=eStrToFloat(dfField^.FMin)) THEN RangeResult:=False;
            ftDate,ftEuroDate,ftYMDDate: IF NOT (NumValue>=mibStrToDate(dfField^.FMin,dfField^.FeltType)) THEN RangeResult:=False;  //&&
          ELSE IF NOT(Value >= dfField^.FMin) THEN RangeResult:=False;
          END;  //case
{          IF NumField THEN
            BEGIN
              IF NOT (NumValue>=eStrToFloat(dfField^.FMin)) THEN RangeResult:=False;
            END
          ELSE IF NOT(Value >= dfField^.FMin) THEN RangeResult:=False;}
        END;  //if Minimum defined
      IF dfField^.FMax<>'' THEN
        BEGIN
          CASE dfField^.FeltType OF
            ftInteger,ftFloat: IF NOT (NumValue<=eStrToFloat(dfField^.FMax)) THEN RangeResult:=False;
            ftDate,ftEuroDate,ftYMDDate: IF NOT (NumValue<=mibStrToDate(dfField^.FMax,dfField^.FeltType)) THEN RangeResult:=False;  //&&
          ELSE IF NOT(Value <= dfField^.FMax) THEN RangeResult:=False;
          END;  //case
{          IF NumField THEN
            BEGIN
              IF NOT (NumValue<=eStrToFloat(dfField^.FMax)) THEN RangeResult:=False;
            END
          ELSE IF NOT(Value <= dfField^.FMax) THEN RangeResult:=False;}
        END;  //if Maximum defined
    END  //If range defined
  ELSE RangeResult:=False;

  {Test if legals are defined}
  LegalResult:=False;
  LegalVals.CommaText:=dfField^.FLegal;
  IF ( (LegalVals.Count>0) AND (NOT dfField^.FRangeDefined) )
    OR ( (LegalVals.Count>1) AND (dfField^.FRangeDefined) ) THEN
    BEGIN  //Legals are defined
      IF dfField^.FRangeDefined THEN LegalVals.Delete(0);
      FOR n:=0 TO LegalVals.Count-1 DO
        BEGIN
          CASE dfField^.Felttype OF
            ftInteger,ftFloat: IF NumValue=eStrToFloat(LegalVals[n]) THEN LegalResult:=True;
            ftDate,ftEuroDate,ftYMDDate: IF NumValue=mibStrToDate(LegalVals[n],dfField^.FeltType) THEN LegalResult:=True;  //&&
          ELSE IF Value=LegalVals[n] THEN LegalResult:=True;
          END;  //Case
        END;  //for
    END;  //if legals defined

  Result:=ValueError OR LegalResult OR RangeResult;
  LegalVals.Free;
END;  //function HandleLegal


Function  TDataForm.HandleCommentLegal(Sender: TObject):Boolean;
VAR
  Value:String;
  LegalResult:Boolean;
  n:Integer;
  SenderField:TEntryField;
  dfField: PeField;
  ALabelRec:PLabelRec;
BEGIN
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  Value:=trim(SenderField.Text);
  IF Value='' THEN
    BEGIN
      Result:=True;
      Exit;
    END;
  Result:=False;

  LegalResult:=False;
  n:=0;
  ALabelRec:=dfField^.FCommentLegalRec;
  WHILE (ALabelRec<>NIL) AND (NOT LegalResult) DO
    BEGIN
      IF ALabelRec^.Value=Value THEN LegalResult:=True;
      ALabelRec:=ALabelRec^.Next;
    END;  //while

  Result:=LegalResult OR Result;
END;  //function HandleCommentLegal


Function TDataForm.HandleJumps(dfField:PeField):boolean;
VAR
  FoundValue,tmpBool:Boolean;
  tmpS:String;
  oeN:Integer;
  gpStrings:TStrings;
  SenderField:TEntryField;
  ResetFrom,ResetTo: Integer;
  AField: PeField;
  NumSkipped: Integer;
BEGIN
  result:=true;
  SenderField:=TEntryField(dfField^.EntryField);
  ResetFrom:=GetFieldNumber(dfField^.FName,df)+1;
  ResetTo:=-1;
  gpStrings:=TStringList.Create;
  gpStrings.commatext:=dfField^.FJumps;
  IF gpStrings.Count>0 THEN
    BEGIN
      IF (gpStrings.Count=2) AND (gpStrings[0]='AUTOJUMP') THEN
        BEGIN
          {Handle autojump}
          IF gpStrings[1]='END' THEN
            BEGIN
              FocusLastField;
              DidJump:=True;
            END
          ELSE IF gpStrings[1]='SKIPNEXTFIELD' THEN
            BEGIN
              NumSkipped:=0;
              oeN:=df^.fieldList.IndexOf(dfField);
              IF oeN<>-1 THEN
                BEGIN
                  INC(oeN,2);
                  IF oeN>df^.FieldList.Count-1 THEN oeN:=df^.FieldList.count-1;
                  WHILE (oeN<=df^.FieldList.Count-1)
                  AND (PeField(df^.FieldList.Items[oeN])^.Felttype=ftQuestion) DO INC(oeN);
                  IF (Pefield(df^.FieldList.Items[oeN])^.Felttype<>ftQuestion)
                  AND (TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).CanFocus)
                  THEN TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).SetFocus;
                  DidJump:=True;
                END;
            END
          ELSE IF gpStrings[1]='WRITE' THEN
            BEGIN
              df^.LeaveStyle:=lsChangeRec;
              onExitEvent(df^.LatestActiveControl);
              IF df^.CanExit THEN
                BEGIN
                  IF SaveRecord THEN
                    BEGIN
                      ChangeRec(df^.CurRecord+1,dirForward);
{                      IF (df^.CurRecord=df^.NumRecords) OR (df^.CurRecord=NewRecord) THEN
                        BEGIN
                          peNewRecord(df);
                          FocusFirstField;
                        END
                      ELSE peReadRecord(df,df^.CurRecord+1);}
                      DidJump:=True;
                    END;  //if Save record
                END;  //if CanExit
            END
          ELSE
            BEGIN  //autojump to a field
              oeN:=0;
              FoundValue:=False;
              WHILE (oeN<df^.FieldList.Count) AND (NOT FoundValue) DO
              IF AnsiUpperCase(trim(PeField(df^.FieldList.Items[oeN])^.FName))=
              AnsiUpperCase(gpStrings[1])
              THEN FoundValue:=True ELSE INC(oeN);
              IF FoundValue THEN
                BEGIN
                  DidJump:=True;
                  if TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).CanFocus
                  then TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).SetFocus;
                  DidJump:=True;
                END;
            END;  //if autojump to a field
        END  //if AUTOJUMP
      ELSE
        BEGIN  //ordinary JUMP
          tmpS:=trim(SenderField.Text);
          oeN:=0;
          FoundValue:=False;
          WHILE (oeN<gpStrings.Count) AND (Not FoundValue) DO
            IF (Copy(gpStrings[oeN],1,Pos('>',gpStrings[oeN])-1)=tmpS)
            OR ((Copy(gpStrings[oeN],1,Pos('>',gpStrings[oeN])-1)='*') AND
            (tmpS<>''))
            THEN FoundValue:=True ELSE INC(oeN);
          IF FoundValue THEN
            BEGIN
              tmpS:=Copy(gpStrings[oeN],Pos('>',gpStrings[oeN])+1,
              Length(gpStrings[oeN])-Pos('>',gpStrings[oeN]));
              tmpS:=AnsiUpperCase(tmpS);
              FoundValue:=False;
              oeN:=0;
              IF trim(tmpS)='END' THEN
                BEGIN
                  FocusLastField;
                  ResetTo:=df^.FieldList.Count-2;
                  DidJump:=True;
                END
              ELSE IF trim(tmpS)='SKIPNEXTFIELD' THEN
                BEGIN
                  oeN:=df^.fieldList.IndexOf(dfField);
                  NumSkipped:=0;
                  IF oeN<>-1 THEN
                    BEGIN
                      REPEAT
                        INC(oeN);
                        IF oeN<=df^.fieldList.Count-1 THEN
                          BEGIN
                            IF PeField(df^.FieldList.Items[oeN])^.Felttype<>ftQuestion
                            THEN INC(NumSkipped);
                          END;
                      UNTIL (oeN>df^.FieldList.Count-1) OR (NumSkipped=2);
                      IF oeN>df^.FieldList.Count-1 THEN oeN:=df^.FieldList.Count-1;
                      ResetTo:=oeN-1;
                      IF (PeField(df^.FieldList.Items[oeN])^.Felttype<>ftQuestion)
                      AND (TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).CanFocus)
                      THEN TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).SetFocus;
                      DidJump:=True;

                      //INC(oeN,2);
                      //WHILE (oeN<=df^.FieldList.Count-1) AND (PeField(df^.FieldList.Items[oeN])^.Felttype=ftQuestion) DO INC(oeN);
                      //IF oeN>df^.FieldList.Count-1 THEN oeN:=df^.FieldList.count-1;
                      //ResetTo:=oeN-1;
                      //IF Pefield(df^.FieldList.Items[oeN])^.Felttype<>ftQuestion
                      //THEN TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).SetFocus;
                      //DidJump:=True;
                    END;
                END
              ELSE
                IF trim(tmpS)='WRITE' THEN
                  BEGIN
                    df^.LeaveStyle:=lsChangeRec;
                    onExitEvent(df^.LatestActiveControl);
                    IF df^.CanExit THEN
                      BEGIN
                        IF SaveRecord THEN
                          BEGIN
                            ChangeRec(df^.CurRecord+1,dirForward);
                            DidJump:=True;
                          END;  //if SaveRecord
                      END;  //if CanExit
                  END
                ELSE
                  BEGIN
                    WHILE (oeN<df^.FieldList.Count) AND (NOT FoundValue) DO
                    IF AnsiUpperCase(trim(PeField(df^.FieldList.Items[oeN])^.FName))=tmpS
                    THEN FoundValue:=True ELSE INC(oeN);
                    IF FoundValue THEN
                      BEGIN
                        ResetTo:=oeN-1;
                        if TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).CanFocus
                        THEN TEntryField(PeField(df^.FieldList.Items[oeN])^.EntryField).SetFocus;
                        DidJump:=True;
                      END;
                  END;
            END;  //if FoundValue
        END;  //if ordinary JUMP
    END;  //if gpStrings.Count>0
  gpStrings.Free;
  IF (dfField^.FJumpResetChar<>#0) AND (ResetTo<>-1) AND(ResetTo>=ResetFrom) THEN
    BEGIN
      {Reset fields between dfField+1 and targetfield-1}
      FOR oeN:=ResetFrom to ResetTo DO
        BEGIN
          AField:=PeField(df^.FieldList.Items[oeN]);
          IF NOT (AField^.Felttype in [ftQuestion,ftToday,ftEuroToday,ftYMDToday,ftIDNUM]) THEN  //&&
            BEGIN
              df^.CurRecModified:=True;
              IF (dfField^.FJumpResetChar=#32) OR (AField^.Felttype in [ftDate,ftEuroDate,ftYMDDate])  //&&
              OR ( (NOT (dfField^.FJumpResetChar in NumChars)) AND (AField^.Felttype in [ftInteger,ftFloat]) ) THEN
                BEGIN
                  AField^.FFieldText:='';
                  ChangeGoingOn:=True;
                  TEntryField(AField^.EntryField).Text:='';
                  ChangeGoingOn:=False;
                END
              ELSE
                BEGIN
                  AField^.FFieldText:=cFill(dfField^.FJumpResetChar,AField^.FLength);
                  ChangeGoingOn:=True;
                  TEntryField(AField^.EntryField).Text:=AField^.FFieldText;
                  ChangeGoingOn:=False;
                END;
            END;  //if fields can be reset
        END;  //for
    END;  //if reset should be done
  if (df^.DoubleEntry) AND (DidJump) AND (ResetTo<>-1) and (ResetTo>=ResetFrom) then   //MIB131205
    begin
      oeN:=ResetFrom;
      WHILE (oeN<=ResetTo) AND (result) DO
        begin
          AField:=PeField(df^.FieldList.Items[oeN]);
          if (AField^.Felttype<>ftQuestion) then
            begin
              tmpBool:=CheckDoubleEntry(AField);
              IF (result) then
                begin
                  result:=tmpBool;
                  dbcheckfailed:=(not result);
                end;
            end;
          INC(oeN);
        end;  //for
    end;
END;  //procedure HandleJumps


procedure TDataForm.onChangeEvent(Sender: TObject);
VAR
  SenderField:TEntryField;
  dfField: PeField;
  s: String;
BEGIN
  IF df^.IsFinding THEN Exit;
  IF NOT ChangeGoingOn THEN
    BEGIN
      SenderField:=Sender AS TEntryField;
      dfField:=PeField(SenderField.dfField);
      IF (NOT df^.CurRecModified) AND (NOT df^.IsReadOnly) THEN
        BEGIN
          df^.CurRecModified:=True;
          CurRecEdit.Text:=CurRecEdit.Text+' *';
        END;
      CASE dfField^.FeltType OF
        ftBoolean: HandleBoolean(sender);
      END;  //case
      dfField^.FFieldText:=SenderField.Text;
      dfField^.FIsVarified:=False;
      IF dfField^.FIsTypeStatusBar THEN
          TypePanel.Caption:=df^.TypeStatusBarText+' '+dfField^.FFieldText;
      //IF (Length(SenderField.text)=dfField^.FLength)
      IF Length(SenderField.Text)=SenderField.MaxLength THEN
        BEGIN
          IF (SenderField.Text='-') AND ((dfField^.FMissingValues[0]<>'') OR (df^.GlobalMissingValues[0]<>'')) THEN
            BEGIN
              IF dfField^.FMissingValues[0]<>'' THEN s:=dfField^.FMissingValues[0]
              ELSE IF df^.GlobalMissingValues[0]<>'' THEN s:=df^.GlobalMissingValues[0];
              IF Length(s)>dfField^.FLength THEN s:='';
              ChangeGoingOn:=True;
              SenderField.Text:=s;
              dfField^.FFieldText:=s;
              ChangeGoingOn:=False;
            END;
          IF NOT ((df^.Confirm) OR (dfField^.FConfirm)) THEN LeaveField(lsEnter);
        END;  //if MaxLength
    END;  //if not ChangeGoingOn
END;   //onchangeevent

procedure TDataForm.onEnterEvent(Sender: TObject);
VAR
  midstr:STRING;
  SenderField:TEntryField;
  dfField: PeField;
  n: Integer;
BEGIN
  df^.LeaveStyle:=lsNone;
  DidJump:=False;
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);

  IF (CheckFileMode) AND (GetFieldnameForJump) THEN
    BEGIN
      {Handles point-and-click for fieldnames during Add/Revise Checks}
      IF (Sender AS TWinControl)=df^.LatestActiveControl THEN Exit
      ELSE
        BEGIN
          WITH TpCheckForm(df^.ChkForm) DO
            BEGIN
              JumpsEdit.Text:=JumpsEdit.Text+trim(dfField^.FName);
              (df^.LatestActiveControl AS TEntryField).SetFocus;
              JumpsEdit.SetFocus;
              JumpsEdit.SelStart:=Length(JumpsEdit.Text);
              GetFieldnameForJump:=False;
            END;
          Exit;
        END;
    END;
  df^.LatestActiveControl:=Sender AS TWinControl;
  IF (NOT df^.Isfinding) THEN
    BEGIN
      IF CheckFileMode THEN
        BEGIN
          TpCheckForm(df^.ChkForm).UpdateCheckForm(Sender);
          SenderField.Color:=clAqua;
        END
      ELSE IF df^.FieldHighlightAct THEN SenderField.Color:=df^.FieldHighlightCol;
    END;
  IF df^.IsFinding THEN IF df^.FieldHighlightAct THEN SenderField.Color:=df^.FieldHighlightCol;
  WITH dfField^ DO
    BEGIN
      MainForm.StatPanel1.Caption:=' '+FName;
      CASE FeltType OF
        ftInteger:   midstr:=' '+Lang(21618);    //' Integer: 0-9 allowed'
        ftFloat:     midstr:=' '+Lang(21620);    //' Floating Point: 0-9 and commas allowed'
        ftAlfa:      midstr:=' '+Lang(21622);    //' Alpha: All entries allowed'
        ftUpperAlfa: midstr:=' '+Lang(21624);    //' Uppercase Alpha: All entries allowed'
        ftIDNUM:     midstr:=' '+Lang(21626);    //' ID number: 0-9 allowed'
        ftBoolean:   midstr:=' '+Lang(21628);    //' Boolean: Y,1,N,0 allowed'
        ftDate:      midstr:=' '+Lang(21630);    //' Date (mdy): 0-9 and / allowed'
        ftEuroDate:  midstr:=' '+Lang(21632);    //' Date (dmy): 0-9 and / allowed'
        ftSoundex:   midstr:=' '+Lang(21634);    //' Soundex: All entries allowed'
        ftCrypt:     midstr:=' '+Lang(21635);    //' Encryptfield: All entries allowed
        ftYMDDate:   midstr:=' '+Lang(21633);    //' Date (ymd): 0-9 and / allowed
      ELSE
        midstr:='';
      END;  //case
      IF FLegal<>''
        THEN midstr:=Copy(midStr,1,Pos(':',midStr)+1)+FLegal+' '+Lang(21636);  //' allowed'
      IF FMustEnter
        THEN MainForm.StatPanel3.Caption:='Must enter'
        ELSE MainForm.StatPanel3.Caption:='';
      IF Felttype=ftCrypt
      THEN MainForm.StatPanel4.Caption:=' '+Lang(21638)+' '+IntToStr(FCryptEntryLength)  //' Length: '
      ELSE MainForm.StatPanel4.Caption:=' '+Lang(21638)+' '+IntToStr(FLength);  //' Length: '
      IF df^.IsReadOnly THEN MainForm.StatPanel5.Caption:=Lang(21674) ELSE MainForm.StatPanel5.Caption:='';  //'Read only'
      IF df^.UseFilter THEN MainForm.StatPanel6.Caption:=' '+Lang(21676)+' '     //'Filter:'
        +trim(PeField(df^.FieldList.Items[df^.FilterField])^.FName)+'="'+df^.Filtertext+'"'
      ELSE MainForm.StatPanel6.Caption:='';
      IF FCommentLegalRec<>NIL
        THEN midstr:=Copy(midStr,1,Pos(':',midStr)+1)+' '+Lang(21640);  //'Press + or F9 to see legal values'
      MainForm.StatPanel2.Caption:=midStr;
      IF (BeforeCmds<>NIL) AND (NOT CheckFilemode) AND (NOT IsClosingCheckFilemode) THEN
        BEGIN
          ExitExecutionBlock:=False;
          ExecCommandList(dfField^.BeforeCmds);
        END;
    END;  //with dfField
  IF SenderField.Text<>'' THEN
    BEGIN
      SenderField.SelStart:=0;
      SenderField.SelLength:=Length(SenderField.Text);
    END;
  IF ((dfField^.FLegal<>'') OR (dfField^.FCommentLegalRec<>NIL)) AND (NOT IsClosingCheckFilemode)
  AND (dfField^.FShowLegalPickList) AND (NOT CheckFileMode) AND (trim(dfField^.FFieldText)='') THEN
    BEGIN
      Self.ScrollBox1.ScrollInView(SenderField);
      ShowLegalPickList(dfField^.FName);
    END;
  {Handle TopOfScreen property}
  IF (NOT CheckFileMode) AND (dfField^.FTopOfScreen) THEN
    BEGIN
      n:=TEntryField(dfField^.EntryField).Height;
      CASE LineHeight OF
        0: n:=n;              //lineheight=1
        1: n:=(n*3) DIV 2;  //Lineheight=1½
        2: n:=n*2;      //LineHeight=2
      END;
      Self.ScrollBox1.VertScrollBar.Position:=dfField^.FFieldTop-(dfField^.FTopOfScreenLines*n);
    END;

END;   //onEnterEvent

procedure TDataForm.OnKeyPressEvent(Sender: TObject; var Key: Char);
VAR
  KeyOK:BOOLEAN;
  SenderField:TEntryField;
  dfField: PeField;
  tmpS:String;
begin
  IF df^.IsreadOnly THEN Exit;
  KeyOK:=TRUE;
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  IF NOT df^.IsFinding THEN
    BEGIN
      IF (Key='+') AND ((dfField^.FCommentLegalRec<>NIL) or (dfField^.FLegal<>'')) AND (NOT CheckFileMode) THEN
        BEGIN
          Key:=#0;
          Exit;
        END;
      WITH dfField^ DO
        BEGIN
          IF (FeltType=ftInteger)  AND NOT(Key in IntegerChars) THEN KeyOK:=FALSE;
          IF (FeltType=ftBoolean)  AND NOT(Key in BooleanChars) THEN KeyOK:=FALSE;
          IF (FeltType=ftDate)     AND NOT(Key in DateChars)    THEN KeyOK:=FALSE;
          IF (FeltType=ftEuroDate) AND NOT(Key in DateChars)    THEN KeyOK:=FALSE;
          IF (FeltType=ftYMDDate)  AND NOT(Key in DateChars)    THEN KeyOK:=FALSE;  //&&
          IF (FeltType=ftFloat) THEN
            BEGIN
              IF NOT(Key in FloatChars) THEN KeyOK:=False;
              IF KeyOK THEN
                BEGIN
                  tmpS:=SenderField.Text;
                  IF FNumDecimals>0 THEN
                    BEGIN
                      IF (Length(tmpS)=FLength-1-FNumDecimals) AND
                         (Pos('.',tmpS)=0) AND (Pos(',',tmpS)=0) AND
                         (ORD(Key)<>8) AND (Key<>',') AND (Key<>'.') THEN
                        BEGIN
                          ChangeGoingOn:=True;
                          SenderField.Text:=tmpS+DecimalSeparator;
                          FFieldText:=SenderField.Text;
                          SenderField.SelStart:=Length(SenderField.Text);
                          ChangeGoingOn:=False;
                        END;  //if
                    END;
                END;  //if keyOK
            END;  //if FeltType=ftFloat
          IF key='-' THEN
            BEGIN
              //Allow minus-char if missing is defined
              IF (FMissingValues[0]<>'') THEN KeyOK:=True
              ELSE IF (df^.GlobalMissingValues[0]<>'') THEN KeyOK:=True;
            END;
        END;  //with
    END;  //if isFinding
  IF (ORD(Key)=8) OR (ORD(Key)=3) OR (ORD(Key)=22) THEN KeyOK:=TRUE;   //BackSpace, CTRL+V, CTRL+C is OK
  IF (ORD(Key)=13) THEN   //Enter pressed: Give focus to next dialogcontrol
    BEGIN
      Key:=#0;
      KeyOK:=TRUE;
      LeaveField(lsEnter);
    END;
  IF (ORD(Key)<>9) AND (NOT KeyOK) THEN
  BEGIN
    beep;
    Key:=#0;
  END;
  IF ORD(Key)=9 THEN Key:=#0;
end;    //onKeyPressEvent


Function TDataForm.CheckDoubleEntry(AField:PeField):Boolean;
VAR
  n:Integer;

  Function CheckOneField(dfField:PeField):Boolean;
  VAR
    dbField: PeField;
    PerformDbTest:Boolean;
    n:Integer;
  BEGIN
    result:=true;
    PerformDbTest:=False;
    dbField:=GetField(dfField^.FName,df^.dbDf);
    IF dbField=NIL THEN
      BEGIN
        Result:=False;
        ErrorMsg(Format(Lang(25022),[ExtractFilename(df^.dbDf^.RECFilename)]));  //'Double entry error:~~Current field does not exist in original data file %s'+
        Exit;
      END
    ELSE
      BEGIN
        IF (df^.dbOrigKeyfieldno<>-1) AND (df^.dbKeyfieldvalue='') THEN
          BEGIN
            //Uses keyfield, but keyfield value has not yet been entered
            IF dbField=PeField(df^.dbDf^.FieldList.Items[df^.dbOrigKeyfieldno]) THEN
              BEGIN
                //User has just entered value in keyfield
                IF trim(dfField^.FFieldText)<>'' THEN
                  BEGIN
                    df^.dbKeyfieldvalue:=dfField^.FFieldText;
                    //Find matching record so df^.dbdf^.currecord becomes <> -1
                    IF df^.dbDf^.FindOpt=NIL THEN
                      BEGIN
                        New(df^.dbDf^.FindOpt);
                        WITH df^.dbDf^.FindOpt^ DO
                          BEGIN
                            FoundRecs:=NIL;
                            IgnoreDeleted:=True;
                            CaseSensitive:=False;
                            WholeWordsOnly:=True;
                          END;  //with
                      END;
                    ResetFindOptions(df^.dbDf);
                    WITH df^.dbDf^.FindOpt^ DO
                      BEGIN
                        StartRecord:=df^.dbDf^.CurRecord;
                        NumCrites:=1;
                        Scope:=ssForward;
                        IgnoreDeleted:=True;
                        CaseSensitive:=False;
                        WholeWordsOnly:=True;
                        CanUseIndex:=False;
                        Crites[1].Fieldno:=df^.dbOrigKeyfieldno;
                        Crites[1].Opr:=opEq;
                        Crites[1].SearchText:=AnsiUpperCase(dfField^.FFieldText);
                        IF (dbField^.Felttype in [ftInteger,ftFloat,ftIDNUM])
                        THEN IF isFloat(dfField^.FFieldText) THEN Crites[1].SearchValue:=eStrToFloat(dfField^.FFieldText);
                      END;  //with
                    n:=Search(df^.dbDf,true);
                    IF n>0 THEN
                      BEGIN
                        //a matching record was found in dbDf
                        peReadRecord(df^.dbDf,n);
                      END
                    ELSE
                      BEGIN
                        IF AddEditDlg(Format(Lang(25024),[ExtractFilename(df^.dbdf^.RECFilename)]),mtWarning,[mbAbort,mbAll],0)=mrAll THEN   //'Double entry error:~~No matching record in %s'
                          BEGIN
                            //Add-buttom selected
                            df^.dbKeyfieldvalue:='';
                            Result:=True;
                          END
                        ELSE
                          BEGIN
                            Result:=False;
                            df^.dbKeyfieldvalue:='';
                          END;
                      END;
                  END;  //if entered keyfield value is not empty
              END  //if user has just entered value in keyfield
            ELSE
              BEGIN
                Result:=True;
                dfField^.FIsVarified:=True;
              END;
          END  //if uses keyfield but keyfield value has not yet been entered
        ELSE
          BEGIN
            IF df^.dbOrigKeyfieldno<>-1 THEN
              BEGIN
                //uses keyfield and keyfield value has previously been entered and therefore dbdf-record is loaded
                PerformDbTest:=True;
              END
            ELSE
              BEGIN
                //uses record-to-record validation
                IF df^.CurRecord=NewRecord THEN n:=df^.Numrecords+1 ELSE n:=df^.CurRecord;
                IF n>df^.dbDf^.NumRecords THEN
                  BEGIN
                    IF AddEditDlg(Format(Lang(25024),[ExtractFilename(df^.dbdf^.RECFilename)]),mtWarning,[mbAbort,mbAll],0)=mrAll THEN   //25024=Double entry error:~~No matching record in %s
                      BEGIN
                        //Add-buttom selected
                        Result:=True
                      END
                    ELSE
                      BEGIN
                        //Edit bottom selected
                        Result:=False;
                      END;
                  END
                ELSE
                  BEGIN
                    IF n<>df^.dbDf^.CurRecord THEN peReadRecord(df^.dbDf,n);
                    PerformDbTest:=True;
                  END;
              END;  //uses record-to-record validation
          END;  //if dbKeyfieldno<>-1 and dbKeyfieldvalue<>''
        IF PerformDbTest THEN
          BEGIN
            IF dfField^.FIsVarified THEN
              BEGIN
                Result:=True;
                Exit;
              END;
            IF (df^.dbIgnoretext) AND (dfField^.Felttype in [ftAlfa,ftUpperAlfa,ftSoundex]) THEN
              BEGIN
                TEntryField(dfField^.EntryField).Text:=dbField^.FFieldText;
                Result:=True;
                //SenderField.Text:=dbField^.FFieldText;
              END
            ELSE
              BEGIN
                IF dfField^.FFieldText<>dbField^.FFieldText THEN
                  BEGIN
                    CASE OriginalNewEditDlg(Format(Lang(25026),[trim(dfField^.FName)])   //25026=Non matching value in %s
                         +#13#13+Format(Lang(25028),[dbField^.FFieldtext])               //25028=Original value = %s
                         +#13+Format(Lang(25030),[dfField^.FFieldText]),mtWarning,[mbIgnore,mbAbort,mbAll],0) OF    //25030=New value = %s
                      mrAbort:
                        BEGIN
                          Result:=False;   //Edit bottom
                          TEntryField(dfField^.EntryField).SetFocus;
                        END;
                      mrAll:
                        BEGIN
                          ChangeGoingOn:=true;
                          TEntryField(dfField^.EntryField).Text:=dbField^.FFieldText;  //Use original value
                          dfField^.FFieldText:=dbField^.FFieldText;   //MIB 120106
                          ChangeGoingOn:=false;
                          dfField^.FIsVarified:=True;
                        END;
                      mrIgnore:
                        BEGIN
                          Result:=True;  //Use new value
                          dfField^.FIsVarified:=True;
                        END;
                    END;  //case
                  END  //if values differ
                ELSE Result:=True;
              END;
          END;  //PerformDbTest
      END;  //if dbField was found
  END;  //function checkonefield
BEGIN
  IF AField<>NIL THEN Result:=CheckOneField(AField)
  ELSE
    BEGIN
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          IF (NOT CheckOneField(PeField(df^.FieldList.Items[n]))) THEN
            BEGIN
              Result:=False;
              Exit;
            END;  //if
        END;  //for
    END;  //else
END;  //Check db-entry

Procedure TDataForm.LeaveField(LeaveStyle: TLeaveStyles);
VAR
  SenderField:TEntryField;
  dfField,dbField: PeField;
  CanExit,PerformDbTest: Boolean;
  tmpCmdPtr:PCmds;
  RangeLegalResult,CommentLegalResult: Boolean;
  tmpS, s, LegalStr: String;
  n, n2: Integer;
BEGIN
{Handle mustenter, after entry og jumps}
  dbCheckFailed:=false;
  IF df^.LatestActiveControl=NIL THEN Exit;
  SenderField:=df^.LatestActiveControl AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  CanExit:=True;
  DidJump:=False;
  IF (NOT CheckFileMode) AND (NOT df^.IsFinding) THEN
    BEGIN
      df^.LeaveStyle:=LeaveStyle;
      WITH dfField^ DO
        BEGIN
          {Handle MustEnter}
          IF (FMustEnter) AND (trim(SenderField.Text)='') THEN
            BEGIN
              eDlg(Lang(21642),mtWarning,[mbOK],0);  //'Data must be entered in this field.'
              CanExit:=False;
              SenderField.SelStart:=0;
              SenderField.SelLength:=Length(SenderField.Text);
              SenderField.SetFocus;
              Exit;
            END;

          {Check keys}
          IF (FIndex>0) THEN
            BEGIN
              s:=Copy(FFieldText,1,30);
              IF (trim(s)='') AND (df^.IndexIsUnique[FIndex]) THEN
                BEGIN
                  //field is KEY UNIQUE and empty
                  eDlg(Lang(21642),mtWarning,[mbOK],0);  //'Data must be entered in this field.'
                  CanExit:=False;
                END
              ELSE
                BEGIN
                  CASE Felttype OF
                    ftInteger,ftFloat: s:=FormatNumberToIndex(s);  //    Format('%30s',[s]);
                    ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:   //&&
                      s:=Format('%30s',[FloatToStr(mibStrToDate(s,Felttype))]);
                  ELSE
                    s:=Format('%-30s',[s]);
                  END;  //case
                  n:=SearchIndex(df,FIndex,s);    //Tidligere: n:=df^.Index[FIndex].IndexOf(s);
                  IF (n<>-1)
                  AND (n<>df^.CurRecord)   //Tidligere:  (Integer(df^.Index[FIndex].Objects[n])<>df^.CurRecord)
                  AND (df^.IndexIsUnique[FIndex]) THEN
                    BEGIN
                      tmpS:=Format(Lang(21651),[trim(FName),n,n]);   //21651=Duplicate key in %s~Value already entered in record #%d~~Goto record #%d?
                      n2:=eDlg(tmpS,mtWarning,[mbYes,mbNo],0);
                      IF n2=mrYes THEN
                        BEGIN
                          ChangeRec(n,dirAbsolute);
                        END;
                      Exit;
                    END;  //if dublicate is entered in unique key
                END;  //if not key unique and empty
            END;  //if field has index

          {Check dates, float and soundex}
          CASE FeltType OF
            ftDate,ftEuroDate,ftYMDdate: CanExit:=HandleDates(SenderField);  //&&
            ftFloat:                     CanExit:=HandleFloat(SenderField);
            ftSoundex:                   CanExit:=HandleSoundex(SenderField);
          END;  //case

          IF (FMissingValues[0]<>'') OR (FMissingValues[1]<>'') OR (FMissingValues[2]<>'')
          OR (df^.GlobalMissingValues[0]<>'') OR (df^.GlobalMissingValues[1]<>'') OR (df^.GlobalMissingValues[2]<>'') THEN
            BEGIN
              //Field has defined missingvalues
              IF (FeltType in [ftInteger,ftFloat,ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt]) THEN
                BEGIN
                  IF SenderField.Text='-' THEN
                    BEGIN
                      IF FMissingValues[0]<>'' THEN SenderField.Text:=FMissingValues[0]
                      ELSE IF df^.GlobalMissingValues[0]<>'' THEN SenderField.Text:=df^.GlobalMissingValues[0];
                      IF Length(SenderField.Text)>FLength THEN SenderField.Text:='';
                    END;
                END;
            END;

          {Check range/legal/commentlegal}
          IF (CanExit) AND ((FLegal<>'') OR (FCommentLegalRec<>NIL)) THEN
            BEGIN
              IF FLegal<>'' THEN RangeLegalResult:=HandleLegal(SenderField) ELSE RangeLegalResult:=False;
              IF FCommentLegalRec<>NIL THEN CommentLegalResult:=HandleCommentLegal(SenderField) ELSE CommentLegalResult:=False;
              //Test for Missing values
              IF (FMissingValues[0]<>'') OR (FMissingValues[1]<>'') OR (FMissingValues[2]<>'')
              OR (df^.GlobalMissingValues[0]<>'') OR (df^.GlobalMissingValues[1]<>'') OR (df^.GlobalMissingValues[2]<>'') THEN
                BEGIN
                  //Field has defined missingvalues
                  IF (FeltType in [ftDate,ftEurodate,ftYMDDate,ftInteger,ftFloat,ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt]) THEN
                    BEGIN
                      IF SenderField.Text='-' THEN
                        BEGIN
                          IF FMissingValues[0]<>'' THEN SenderField.Text:=FMissingValues[0]
                          ELSE IF df^.GlobalMissingValues[0]<>'' THEN SenderField.Text:=df^.GlobalMissingValues[0];
                          IF Length(SenderField.Text)>FLength THEN SenderField.Text:='';
                        END;
                      IF (SenderField.Text=FMissingValues[0])
                      OR (SenderField.Text=FMissingValues[1])
                      OR (SenderField.Text=FMissingValues[2])
                      OR (SenderField.Text=df^.GlobalMissingValues[0])
                      OR (SenderField.Text=df^.GlobalMissingValues[1])
                      OR (SenderField.Text=df^.GlobalMissingValues[2])
                      THEN RangeLegalResult:=True;
                    END;  //if relevant fieldtype
                END; //if has defined missingvalues
              //Test for Default value
              IF (FDefaultValue<>'') THEN
                BEGIN
                  IF (SenderField.Text=FDefaultValue) THEN RangeLegalResult:=True;
                END
              ELSE IF (FHasGlobalDefaultValue) THEN
                BEGIN
                  IF (SenderField.Text=df^.GlobalDefaultValue) THEN RangeLegalResult:=True;
                END;
              IF NOT ((RangeLegalResult=True) OR (CommentLegalResult=True)) THEN
                BEGIN
                  CanExit:=False;
                  tmpS:=Lang(21644)+#13#13;   //'Illegal entry.'
                  IF (NOT RangeLegalResult) AND (FLegal<>'') THEN
                    BEGIN
                      LegalStr:=RemoveQuotes(dfField^.FLegal);
                      IF Length(LegalStr)>50 THEN LegalStr:=Copy(LegalStr,1,47)+'...';
                      tmpS:=tmpS+Format(Lang(21646),[LegalStr]);  //'Legal values are %s'
                      IF (NOT CommentLegalResult) AND (FCommentLegalRec<>NIL) THEN tmpS:=tmpS+#13+
                      Lang(21648);  //'and the values defined by comment legal (press + or F9 to see list)'
                    END;
                  IF (NOT CommentLegalResult) AND(FLegal='') AND (FCommentLegalRec<>NIL)
                  THEN tmpS:=tmpS+Lang(21640);   //Press + or F9 to see legal values
                  ErrorMsg(tmpS);
                END;  //if not result
            END;  //if has Legal/Range or CommentLegal

          {Handle double Entry}
          IF (CanExit) AND (df^.DoubleEntry) THEN
            BEGIN
              CanExit:=CheckDoubleEntry(dfField);
            END;  //if double entry

          {Handle After Entry}
          IF (CanExit) AND (dfField^.AfterCmds<>NIL) THEN
            BEGIN
              ExitExecutionBlock:=False;
              ExecCommandList(dfField^.AfterCmds);
              IF df^.RelateCalled THEN
                BEGIN
                  New(tmpCmdPtr);
                  tmpCmdPtr^.Command:=cmdLeaveField;
                  tmpCmdPtr^.cLeaveStyle:=LeaveStyle;
                  tmpCmdPtr^.IsLastField:=dfField^.LastField;
                  df^.LastCommands.Add(tmpCmdPtr);
                  //ShowLastCmds('Handle after Entry of '+Extractfilename(df^.RECFilename)+#13,df);
                END;
            END;

          {Handle Jumps}
          IF (CanExit) AND (dfField^.FJumps<>'') AND (NOT DidJump) AND (NOT df^.RelateCalled) THEN CanExit:=HandleJumps(dfField);
        END;  //with dfField
    END;  //if NOT CheckFileMode

  IF (NOT CanExit) AND (NOT dbCheckFailed) THEN
    BEGIN
      SenderField.SelStart:=0;
      SenderField.SelLength:=Length(SenderField.Text);
      SenderField.SetFocus;
    END;
  dbCheckFailed:=false;

  IF (CanExit) AND (NOT DidJump) AND (NOT df^.RelateCalled) THEN
    CASE LeaveStyle OF
      lsEnter:     PostMessage(Self.Handle,WM_NextDlgCtl,0,0);   //Next field
      lsBrowse:    PostMessage(Self.Handle,WM_NextDlgCtl,1,0);   //Previous field
      lsJumpFirst: FocusFirstField;
      lsJumpLast:  FocusLastField;
    END;  //case
END;  //procedure LeaveField


procedure TDataForm.onExitEvent(Sender: TObject);
VAR
  SenderField:TEntryField;
  dfField, AField2: PeField;
  CanExit,stop: Boolean;
  RangeLegalResult,CommentLegalResult: Boolean;
  n,n2:Integer;
  tmpS,LegalStr,s:String;
  tmpList,saveFieldsList: TStringList;
  dlgAnswer: Word;
  FoundRec: Longint;
  AGrid: TGridForm;
  WindowList: Pointer;
BEGIN
  IF (CheckFileMode) AND (GetFieldnameForJump) THEN Exit;
  SenderField:=Sender AS TEntryField;
  dfField:=PeField(SenderField.dfField);

  IF df^.IsFinding THEN
    BEGIN
      IF df^.FieldBg<>COLOR_ENDCOLORS THEN SenderField.Color:=df^.FieldBg ELSE SenderField.Color:=FieldColor;
      Exit;
    END;

  IF CheckFileMode THEN
    BEGIN
      IF df^.FieldBg<>COLOR_ENDCOLORS THEN SenderField.Color:=df^.FieldBg ELSE SenderField.Color:=FieldColor;
      Exit;
    END;

  IF NOT df^.CurRecModified THEN
    BEGIN
      df^.CanExit:=True;
      IF df^.FieldBg<>COLOR_ENDCOLORS THEN SenderField.Color:=df^.FieldBg ELSE SenderField.Color:=FieldColor;
      //SenderField.Color:=FieldColor;
      IF (dfField^.FTypeComments) OR ((df^.GlobalTypeCom) AND (dfField^.FCommentLegalRec<>NIL))
        THEN dfField^.FTypeField.Caption:=GetCommentLegalText(dfField^.FFieldText,dfField^.FCommentLegalRec);
      IF ((df^.IsRelateTop) OR (df^.IsRelateFile)) AND (dfField^.LastField) AND (df^.LeaveStyle<>lsBrowse)
      THEN IF (RelateOne2One) AND (NOT df^.IsRelateTop) THEN Close
      ELSE IF NOT DidJump THEN ChangeRec(df^.CurRecord+1,dirForward);
      df^.LeaveStyle:=lsNone;
      Exit;
    END;

  IF (df^.LeaveStyle=lsNone) AND (NOT HasShownMouseWarning) THEN ShowMouseWarning:=True;

  CanExit:=True;
//  DidJump:=False;
  WITH dfField^ DO
    BEGIN

      {Handle MustEnter}
{      IF (FMustEnter) AND (NOT DidJump) AND (trim(SenderField.Text)='') THEN
        BEGIN
          eDlg(Lang(21642),mtWarning,[mbOK],0);  //'Data must be entered in this field.'
          df^.CanExit:=False;
          SenderField.SelStart:=0;
          SenderField.SelLength:=Length(SenderField.Text);
          SenderField.SetFocus;
          Exit;
        END;}


      {Check dates, float and soundex}
      Case FeltType OF
        ftDate,ftEuroDate,ftYMDDate: CanExit:=HandleDates(SenderField);  //&&
        ftFloat:                     CanExit:=HandleFloat(SenderField);
        ftSoundex:                   CanExit:=HandleSoundex(SenderField);
        ftInteger:                   CanExit:=HandleInteger(SenderField);
      END;  //case

      {Check range/legal/commentlegal}
      IF (CanExit) AND ((FLegal<>'') OR (FCommentLegalRec<>NIL)) THEN
        BEGIN
          IF FLegal<>'' THEN RangeLegalResult:=HandleLegal(SenderField) ELSE RangeLegalResult:=False;
          IF FCommentLegalRec<>NIL THEN CommentLegalResult:=HandleCommentLegal(SenderField) ELSE CommentLegalResult:=False;
          //Test for Missing values
          IF (FMissingValues[0]<>'') OR (FMissingValues[1]<>'') OR (FMissingValues[2]<>'')
          OR (df^.GlobalMissingValues[0]<>'') OR (df^.GlobalMissingValues[1]<>'') OR (df^.GlobalMissingValues[2]<>'') THEN
            BEGIN
              //Field has defined missingvalues
              IF (FeltType in [ftDate,ftEurodate,ftYMDDate,ftInteger,ftFloat,ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt]) THEN
                BEGIN
                  IF SenderField.Text='-' THEN
                    BEGIN
                      IF FMissingValues[0]<>'' THEN SenderField.Text:=FMissingValues[0]
                      ELSE IF df^.GlobalMissingValues[0]<>'' THEN SenderField.Text:=df^.GlobalMissingValues[0];
                      IF Length(SenderField.Text)>FLength THEN SenderField.Text:='';
                    END;
                  IF (SenderField.Text=FMissingValues[0])
                  OR (SenderField.Text=FMissingValues[1])
                  OR (SenderField.Text=FMissingValues[2])
                  OR (SenderField.Text=df^.GlobalMissingValues[0])
                  OR (SenderField.Text=df^.GlobalMissingValues[1])
                  OR (SenderField.Text=df^.GlobalMissingValues[2])
                  THEN RangeLegalResult:=True;
                END;  //if relevant fieldtype
            END; //if has defined missingvalues
          //Test for default value
          IF (FDefaultValue<>'') THEN
            BEGIN
              IF (SenderField.Text=FDefaultValue) THEN RangeLegalResult:=True;
            END
          ELSE IF (FHasGlobalDefaultValue) THEN
            BEGIN
              IF (SenderField.Text=df^.GlobalDefaultValue) THEN RangeLegalResult:=True;
            END;

          IF NOT ((RangeLegalResult=True) OR (CommentLegalResult=True)) THEN
            BEGIN
              CanExit:=False;
              tmpS:=Lang(21644)+#13#13;   //'Illegal entry.'
              IF (NOT RangeLegalResult) AND (FLegal<>'') THEN
                BEGIN
                  LegalStr:=RemoveQuotes(dfField^.FLegal);
                  IF Length(LegalStr)>50 THEN LegalStr:=Copy(LegalStr,1,47)+'...';
                  tmpS:=tmpS+Format(Lang(21646),[LegalStr]);  //'Legal values are %s'
                  IF (NOT CommentLegalResult) AND (FCommentLegalRec<>NIL) THEN tmpS:=tmpS+#13+
                  Lang(21648);  //'and the values defined by comment legal (press + or F9 to see list)'
                END;
              IF (NOT CommentLegalResult) AND(FLegal='') AND (FCommentLegalRec<>NIL)
              THEN tmpS:=tmpS+Lang(21640);   //Press + or F9 to see legal values
              ErrorMsg(tmpS);
            END;  //if not result
        END;  //if has Legal/Range or CommentLegal

      {Validate keys}
      IF (CanExit) AND (FIndex>0) THEN
        BEGIN
          s:=Copy(FFieldText,1,30);
          IF (trim(s)='') AND (df^.IndexIsUnique[FIndex]) THEN
            BEGIN
              //field is KEY UNIQUE and empty
              eDlg(Lang(21642),mtWarning,[mbOK],0);  //'Data must be entered in this field.'
              CanExit:=False;
            END
          ELSE
            BEGIN
              CASE Felttype OF
                ftInteger,ftFloat: s:=FormatNumberToIndex(s);  //    Format('%30s',[s]);
                ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:   //&&
                  s:=Format('%30s',[FloatToStr(mibStrToDate(s,Felttype))]);
              ELSE
                s:=Format('%-30s',[s]);
              END;  //case
              n:=SearchIndex(df,FIndex,s);    //Tidligere: n:=df^.Index[FIndex].IndexOf(s);
              IF (n<>-1)
              AND (n<>df^.CurRecord)   //Tidligere:  (Integer(df^.Index[FIndex].Objects[n])<>df^.CurRecord)
              AND (df^.IndexIsUnique[FIndex]) THEN
                BEGIN
                  tmpS:=Format(Lang(21651),[trim(FName),n,n]);   //21651=Duplicate key in %s~Value already entered in record #%d~~Goto record #%d?
                  n2:=eDlg(tmpS,mtWarning,[mbYes,mbNo],0);
                  IF n2=mrYes THEN
                    BEGIN
                      ChangeRec(n,dirAbsolute);
                    END;
                  CanExit:=False;
                END;  //if dublicate is entered in unique key
            END;  //if not key unique and empty
        END;  //if field has index

      {Handle autosearch}
      IF (FAutoSearch) AND (df^.CurRecord=Newrecord) AND (df^.NumRecords>0) AND (trim(dfField^.FFieldText)<>'') THEN
        BEGIN
          TRY
            saveFieldsList:=TStringList.Create;

            IF df^.FindOpt=NIL THEN
              BEGIN
                New(df^.FindOpt);
                df^.FindOpt^.FoundRecs:=NIL;
                df^.FindOpt^.IgnoreDeleted:=True;
                df^.FindOpt^.CaseSensitive:=False;
                df^.FindOpt^.WholeWordsOnly:=True;
              END;
            {set up search critirias}
            TRY
              tmpList:=TStringList.Create;
              tmpList.CommaText:=FAutoFields;
              ResetFindOptions(df);
              WITH df^.FindOpt^ DO
                BEGIN
                  StartRecord:=df^.CurRecord;
                  NumCrites:=tmpList.Count;
                  Scope:=ssForward;
                  IF FoundRecs<>NIL THEN
                    BEGIN
                      FoundRecs.Free;
                      FoundRecs:=NIL;
                    END;
                  IgnoreDeleted:=True;
                  CaseSensitive:=False;
                  WholeWordsOnly:=True;
                  CanUseIndex:=True;
                  FOR n:=0 TO tmpList.Count-1 DO
                    BEGIN
                      AField2:=PeField(df^.FieldList.Items[StrToInt(tmpList[n])]);
                      IF AField2^.FIndex=0 THEN CanUseIndex:=False;
                      Crites[n+1].Fieldno:=StrToInt(tmpList[n]);
                      Crites[n+1].Opr:=opEq;
                      Crites[n+1].SearchText:=AField2^.FFieldText;
                      IF (AField2^.Felttype in [ftInteger,ftFloat,ftIDNUM]) THEN
                        BEGIN
                          IF (AField2^.FFieldText='') THEN Crites[n+1].SearchValue:=MinNumber
                          ELSE IF isFloat(AField2^.FFieldText) THEN Crites[n+1].SearchValue:=eStrToFloat(AField2^.FFieldText);
                        END;
                      IF df^.FindOpt^.NumCrites=MaxFindExCrites THEN Break;
                    END;  //for
                END;  //with
            FINALLY
              tmpList.Free;
            END;  //try..finally
            IF df^.FieldBg<>COLOR_ENDCOLORS THEN SenderField.Color:=df^.FieldBg ELSE SenderField.Color:=FieldColor;

            //Save values entered so far in fields in the new record
            saveFieldsList.Capacity:=df^.FieldList.Count;
            FOR n:=0 TO df^.FieldList.Count-1 DO
              saveFieldsList.Append(TEntryField(peField(df^.FieldList.Items[n])^.EntryField).Text);

            FoundRec:=Search(df,true);
            IF FoundRec>0 THEN
              BEGIN
                //a autosearch match is found!
                IF NOT FAutoList THEN
                  BEGIN
                    REPEAT
                      peReadRecord(df,FoundRec);
                      dlgAnswer:=eDlg(Lang(21702),mtInformation,[mbYes,mbNo,mbCancel],0);  //21702=Record exists.~~Edit this record?
                      IF dlgAnswer=mrNo THEN FoundRec:=Search(df,true);
                    UNTIL (FoundRec<0) OR (dlgAnswer<>mrNo);
                    IF (dlgAnswer=mrCancel) OR (FoundRec<0) THEN
                      BEGIN
                        peNewRecord(df);
                        FOR n:=0 TO df^.FieldList.Count-1 DO
                          BEGIN
                            AField2:=PeField(df^.FieldList.Items[n]);
                            IF AField2^.Felttype<>ftQuestion THEN
                              BEGIN
                                ChangeGoingOn:=True;
                                AField2^.FFieldText:=saveFieldsList[n];
                                TentryField(AField2^.EntryField).Text:=saveFieldsList[n];
                                ChangeGoingOn:=False;
                              END;
                          END;
                        df^.CurRecModified:=True;
                      END;
                  END  //if not FAutoList
                ELSE
                  BEGIN    //if Autosearch has LIST parameter
                    TRY
                      AGrid:=TGridForm.Create(NIL);
                      AGrid.Width:=(MainForm.ClientWidth*8) DIV 10;
                      AGrid.Height:=(MainForm.ClientHeight*8) DIV 10;
                      AGrid.Left:=(MainForm.ClientWidth DIV 2)-(AGrid.Width DIV 2);
                      AGrid.Top:=20;
                      AGrid.Grid1.OnDrawCell:=AGrid.Grid1DrawCell;
                      AGrid.GridContent:=gcAutoSearch;
                      UserAborts:=False;
                      //Set order of fields
                      //Append IDNUMber field
                      IF df^.IDNUMField<>-1 THEN AGrid.FieldOrder.Append(IntToStr(df^.IDNUMField));
                      //Append fields used in autosearch
                      FOR n:=1 TO df^.findOpt^.NumCrites DO
                        AGrid.FieldOrder.Append(IntToStr(df^.FindOpt^.Crites[n].Fieldno));
                      //Append key fields
                      FOR n:=1 TO df^.IndexCount DO
                        AGrid.fieldOrder.Append(IntToStr(df^.indexfields[n]));

                      AGrid.df:=df;
                      FOR n:=0 TO df^.FieldList.Count-1 DO
                        BEGIN
                          AField2:=PeField(df^.FieldList.Items[n]);
                          IF AField2^.Felttype<>ftQuestion THEN
                            BEGIN
                              ChangeGoingOn:=True;
                              AField2^.FFieldText:=saveFieldsList[n];
                              TentryField(AField2^.EntryField).Text:=saveFieldsList[n];
                              ChangeGoingOn:=False;
                            END;
                        END;
                      AGrid.AddRecord(NewRecord);
                      IF df^.FindOpt^.CanUseIndex THEN
                        BEGIN
                          FOR n:=0 TO df^.findopt^.FoundRecs.Count-1 DO
                            BEGIN
                              AGrid.AddRecord(StrToInt(df^.FindOpt^.FoundRecs[n]));
                            END;
                          AGrid.StopAdding;
                          AGrid.Grid1.RowCount:=AGrid.Grid1.RowCount-1;
                          n:=AGrid.ShowModal;
                          IF n=mrCancel THEN UserAborts:=True;
                        END
                      ELSE
                        BEGIN
                          AGrid.AddRecord(FoundRec);
                          AGrid.StopAdding;
                          REPEAT
                            if FoundRec=df^.NumRecords then FoundRec:=-1
                            else
                              begin
                                df^.FindOpt^.StartRecord:=FoundRec;
                                FoundRec:=Search(df,true);
                                IF FoundRec>0 THEN
                                  BEGIN
                                    AGrid.AssignTxtFile;
                                    AGrid.AddRecord(FoundRec);
                                    AGrid.StopAdding;
                                  END;
                              end;
                          UNTIL FoundRec<=0;
                          AGrid.Grid1.RowCount:=AGrid.Grid1.RowCount-1;
                          df^.CurRecord:=NewRecord;
                          n:=AGrid.ShowModal;
                          IF n=mrCancel THEN UserAborts:=True;
                        END;

                      //Restore datafile as normal datafile
                      IF NOT Assigned(df^.Datfile) THEN df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);
                      df^.CurRecord:=NewRecord;
                      IF n=mrOK THEN
                        BEGIN
                          s:=AGrid.Selected;
                          IF s=Lang(11020) THEN UserAborts:=True    //'New';
                          ELSE peReadRecord(df,StrToInt(s));
                        END;
                    FINALLY
                      AGrid.Free;
                      IF UserAborts THEN
                        BEGIN
                          peNewRecord(df);
                          FOR n:=0 TO df^.FieldList.Count-1 DO
                            BEGIN
                              AField2:=PeField(df^.FieldList.Items[n]);
                              IF AField2^.Felttype<>ftQuestion THEN
                                BEGIN
                                  ChangeGoingOn:=True;
                                  AField2^.FFieldText:=saveFieldsList[n];
                                  TentryField(AField2^.EntryField).Text:=saveFieldsList[n];
                                  ChangeGoingOn:=False;
                                END;
                            END;
                          df^.CurRecModified:=True;
                        END;
                    END;
                  END;
              END  //if autosearch found a match
            ELSE
              BEGIN   //autosearch match not found
                //restore original data
                peNewRecord(df);
                FOR n:=0 TO df^.FieldList.Count-1 DO
                  BEGIN
                    AField2:=PeField(df^.FieldList.Items[n]);
                    IF AField2^.Felttype<>ftQuestion THEN
                      BEGIN
                        ChangeGoingOn:=True;
                        AField2^.FFieldText:=saveFieldsList[n];
                        TEntryField(AField2^.EntryField).Text:=saveFieldsList[n];
                        ChangeGoingOn:=False;
                      END;  //if
                  END;  //for
                df^.CurRecModified:=True;
                UpdateCurRecEdit(df^.CurRecord,df^.NumRecords);
              END;  //else (ie auosearch match not found)
          FINALLY
            saveFieldsList.Free;
          END;  //try..Finally
      END;  //if FAutoSearch

    END;  //with dfField

{  IF ShowMouseWarning THEN
    BEGIN
      ShowMouseWarning:=False;
      HasShownMouseWarning:=True;
      eDlg(Lang(50218)+#13#13+Lang(50220),mtWarning,[mbOK],0);
        //50218=It is recommended that you use the ENTER key to go to the next field during dataentry.
        //50220=If the TAB key or the mouse is used then only the most basic validation is done.
      CanExit:=False;
    END;}

  IF NOT CanExit THEN
    BEGIN
      IF (dfField^.FTypeComments) or (dfField^.FTypeString)
      OR ((df^.GlobalTypeCom) AND (dfField^.FCommentLegalRec<>NIL)) THEN dfField^.FTypeField.Caption:='';
      SenderField.SelStart:=0;
      SenderField.SelLength:=Length(SenderField.Text);
      SenderField.SetFocus;
    END
  ELSE
    BEGIN  //Field can be exited
      IF df^.LeaveStyle<>lsChangeRec THEN
        BEGIN
          IF df^.FieldBg<>COLOR_ENDCOLORS THEN SenderField.Color:=df^.FieldBg ELSE SenderField.Color:=FieldColor;
          //SenderField.Color:=FieldColor;
          {Handle TYPE COMMENT}
          IF (dfField^.FTypeComments) OR ((df^.GlobalTypeCom) AND (dfField^.FCommentLegalRec<>NIL))
          THEN dfField^.FTypeField.Caption:=GetCommentLegalText(dfField^.FFieldText,dfField^.FCommentLegalRec);
          {Handle TYPE COMMENT fieldname}
          IF dfField^.FTypeCommentField>-1 THEN
            BEGIN
              AField2:=PeField(df^.FieldList.items[dfField^.FTypeCommentField]);
              s:=GetCommentLegalText(dfField^.FFieldText,dfField^.FCommentLegalRec);
              IF IsCompliant(s,AField2^.Felttype) THEN
                BEGIN
                  ChangeGoingOn:=True;
                  AField2^.FFieldText:=s;
                  TEntryField(AField2^.EntryField).Text:=AField2^.FFieldText;
                  ChangeGoingOn:=False;
                  IF AField2^.FIsTypeStatusBar
                  THEN TypePanel.Caption:=df^.TypeStatusBarText+' '+AField2^.FFieldText;
                END;
            END;

          IF (df^.CurRecModified) AND (df^.LeaveStyle=lsEnter) AND (NOT DidJump) THEN
            BEGIN
              IF dfField^.LastField THEN
                BEGIN
                  IF Saverecord THEN ChangeRec(df^.CurRecord+1,dirForward);
//                    IF (df^.CurRecord=df^.NumRecords) OR (df^.CurRecord=NewRecord)
//                    THEN peNewRecord(df) ELSE peReadRecord(df,df^.CurRecord+1);
                END;  //if LastField
            END;  //if CurRecModified
        END;  //if not lsChangeRec
    END;   //Field can be exited
  df^.LeaveStyle:=lsNone;
  df^.CanExit:=CanExit;
  DidJump:=False;
END;  //procedure OnExitEvent


procedure TDataForm.Exit1Click(Sender: TObject);
begin
  MainForm.Close;
end;


procedure TDataForm.Close1Click(Sender: TObject);
begin
  Close;
end;


procedure TDataForm.UpdateCurRecEdit(CurRec,TotalRec:Integer);
VAR
  updateStr:String;
  n: Integer;
  tmpDefVar: PDefVar;
BEGIN
  updateStr:='';
  IF (TestingDataForm) or (CheckFileMode) THEN NewRecord1.Enabled:=False;
  IF CurRec=NewRecord THEN
    BEGIN
      updateStr:=' '+Lang(21652);   //'New';
      Markrecordfordeletion1.Enabled:=False;
      DeleteRecButton.Enabled:=False;
    END
  ELSE
    BEGIN
      updateStr:=' '+IntToStr(CurRec);
      MarkRecordForDeletion1.Enabled:=True;
      DeleteRecButton.Enabled:=True;
      NewRecButton.Enabled:=True;
      NewRecord1.Enabled:=True;
    END;
  updateStr:=updateStr+'/'+IntToStr(TotalRec);
  CurRecEdit.Text:=updateStr;
  IF (TotalRec>0) AND (NOT TestingDataForm) THEN
    BEGIN
      FirstRecButton.Enabled:=True;
      LastRecButton.Enabled:=True;
      MarkRecordForDeletion1.Enabled:=True;
      GotoRecord1.Enabled:=True;
    END
  ELSE
    BEGIN
      FirstRecButton.Enabled:=False;
      LastRecButton.Enabled:=False;
      MarkRecordForDeletion1.Enabled:=False;
      GotoRecord1.Enabled:=False;
    END;
  IF (TotalRec>0) AND (NOT TestingDataForm) THEN
    BEGIN
      FindRecord2.Enabled:=True;
      IF df^.FindOpt<>NIL THEN FindAgain1.Enabled:=True;
    END
  ELSE
    BEGIN
      FindRecord2.Enabled:=False;
      FindAgain1.Enabled:=False;
    END;
  //IF CurRec=NewRecord THEN FindAgain1.Enabled:=False;
  IF ((CurRec>1) OR ( (CurRec=NewRecord) AND (TotalRec>0) ))
    AND (NOT TestingDataForm) THEN PrevRecButton.Enabled:=True
    ELSE PrevRecButton.Enabled:=False;
  IF (CurRec<=TotalRec) AND (NOT TestingDataForm)
    THEN NextRecButton.Enabled:=True ELSE NextRecButton.Enabled:=False;
  FirstRecord1.Enabled:=FirstRecButton.Enabled;
  PreviousRecord1.Enabled:=PrevRecButton.Enabled;
  NextRecord1.Enabled:=NextRecButton.Enabled;
  LastRecord1.Enabled:=LastRecButton.Enabled;
  IF df^.CurRecDeleted THEN
    BEGIN
      DeletePanel.Caption:='DEL';
      MarkRecordForDeletion1.Caption:=Lang(21654);  //'Undelete record'
      DeleteRecButton.Hint:=MarkRecordForDeletion1.Caption;
    END
  ELSE IF df^.CurRecVerified THEN
    BEGIN
      DeletePanel.Caption:='VER';
      MarkRecordForDeletion1.Caption:=Lang(21656);  //'Delete record'
      DeleteRecButton.Hint:=MarkRecordForDeletion1.Caption;
    END
  ELSE
    BEGIN
      DeletePanel.Caption:='';
      MarkRecordForDeletion1.Caption:=Lang(21656);  //'Delete record'
      DeleteRecButton.Hint:=MarkRecordForDeletion1.Caption;
    END;
  IF df^.TypeStatusBarField>-1 THEN
    BEGIN
      TypePanel.Font.Color:=ColorValues[df^.TypeStatusBarColor];
      TypePanel.Caption:=df^.TypeStatusBarText+' '+
      trim(PeField(df^.FieldList.Items[df^.TypeStatusBarField])^.FFieldText);
    END
  ELSE TypePanel.Caption:='';
  {Reset local Define-variables}
  IF df^.DefList<>NIL THEN
    FOR n:=0 TO df^.DefList.Count-1 DO
      BEGIN
        tmpDefVar:=PDefVar(df^.DefList.Objects[n]);
        IF tmpDefVar^.FScope=scLocal THEN tmpDefVar^.FFieldText:='';
      END;
  {Actions to be done before entering a record}
  IF (NOT TestingDataForm) AND (NOT CheckFileMode) AND (Assigned(df^.BeforeRecordCmds)) THEN
    BEGIN
      df^.IsInBeforeCmds:=True;  //&&
      ExitExecutionBlock:=False;
      ExecCommandList(df^.BeforeRecordCmds);
      df^.CurRecModified:=False;
      df^.IsInBeforeCmds:=False;
    END;
END;  //procedure updateCurRecEdit

Function TDataForm.FieldListModfied:Boolean;
VAR
  n:Integer;
BEGIN
  Result:=False;
  FOR n:=0 to df^.FieldList.Count-1 DO
    IF PeField(df^.FieldList.Items[n])^.FeltType<>ftQuestion THEN
      IF TEntryField(PeField(df^.FieldList.Items[n])^.EntryField).Modified
        THEN Result:=True;
END;  //Function FeltListeModified


procedure TDataForm.PrevRecButtonClick(Sender: TObject);
begin
  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF df^.CanExit THEN
        BEGIN
          SaveRecord;
          IF NOT DidJump THEN ChangeRec(df^.CurRecord-1,dirBackward);
//            IF df^.CurRecord=NewRecord
//            THEN peReadRecord(df,df^.NumRecords) ELSE peReadRecord(df,df^.CurRecord-1);
        END;   //if canExitField
    END  //if modified
  ELSE
    BEGIN
      ChangeRec(df^.CurRecord-1,dirBackward);
//      IF df^.CurRecord=NewRecord
//      THEN peReadRecord(df,df^.NumRecords) ELSE peReadRecord(df,df^.CurRecord-1);
    END;
end;   //procedure PrevRecButtonClick

procedure TDataForm.NextRecButtonClick(Sender: TObject);
begin
  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF df^.CanExit THEN
        BEGIN
          SaveRecord;
          IF NOT DidJump THEN ChangeRec(df^.CurRecord+1,dirForward);
{            BEGIN
              IF (df^.CurRecord=df^.NumRecords) OR (df^.CurRecord=NewRecord) THEN
                BEGIN
                  peNewRecord(df);
                  FocusFirstField;
                END
              ELSE peReadRecord(df,df^.CurRecord+1);
            END;}
        END;  //if CanExitField
    END    //modified
  ELSE
    BEGIN
      ChangeRec(df^.CurRecord+1,dirForward);
{      IF (df^.CurRecord=df^.NumRecords) THEN
        BEGIN
          peNewRecord(df);
          FocusFirstField;
        END
      ELSE IF (df^.CurRecord<>NewRecord) THEN peReadRecord(df,df^.CurRecord+1);}
    END;
end;   //procedure NextRecButtonClick

procedure TDataForm.FirstRecButtonClick(Sender: TObject);
begin
  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF df^.CanExit THEN
        BEGIN
          SaveRecord;
          IF NOT DidJump THEN ChangeRec(1,dirFirst);   //peReadRecord(df,1);
        END;  //if CanExitField
    END   //if modified
  ELSE ChangeRec(1,dirFirst);   //peReadRecord(df,1);
end;

procedure TDataForm.LastRecButtonClick(Sender: TObject);
begin
  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF df^.CanExit THEN
        BEGIN
          SaveRecord;
          IF NOT DidJump THEN ChangeRec(df^.NumRecords,dirLast);  //peReadRecord(df,df^.NumRecords);
        END;  //if CanExitField
    END   //if modified
  ELSE ChangeRec(df^.NumRecords,dirLast);    //peReadRecord(df,df^.NumRecords);
end;

procedure TDataForm.Newrecord1Click(Sender: TObject);
begin
  IF df^.IsReadOnly THEN Exit;
  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF df^.CanExit THEN
        BEGIN
          SaveRecord;
          IF NOT DidJump THEN
            BEGIN
              peNewRecord(df);
              FocusFirstField;
            END;
        END;  //if CanExitField
    END   //if modified
  ELSE
    BEGIN
      peNewRecord(df);
      FocusFirstField;
    END;
end;



procedure TDataForm.DeleteRecButtonClick(Sender: TObject);
begin
  IF df^.IsReadOnly THEN Exit;
  IF (NOT df^.CurRecDeleted) AND (df^.HasRelate) THEN
    BEGIN
      IF eDlg(Lang(21692),mtWarning,[mbOK,mbCancel],0)=mrCancel THEN Exit;   //21692=Deleting this record might result in orphaned records in the files related to this file
    END;
  df^.CurRecDeleted:=NOT (df^.CurRecDeleted);
  df^.CurRecModified:=True;
  IF df^.CurRecDeleted THEN
  BEGIN
    DeletePanel.Caption:='DEL';
    MarkRecordForDeletion1.Caption:=Lang(21654);   //'Undelete record';
    DeleteRecButton.Hint:=MarkRecordForDeletion1.Caption;
  END
ELSE
  BEGIN
    DeletePanel.Caption:='';
    MarkRecordForDeletion1.Caption:=Lang(21656);   //'Delete record'
    DeleteRecButton.Hint:=MarkRecordForDeletion1.Caption;
  END;
end;

procedure TDataForm.GotoRecord1Click(Sender: TObject);
VAR
  InputStr:String;
  InputNum:Integer;
begin
  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF NOT df^.CanExit THEN Exit;
    END;
  IF df^.NumRecords>0 THEN
    BEGIN
      IF df^.CurRecModified THEN SaveRecord;
      IF NOT DidJump THEN
        BEGIN
          InputStr:=eInputBox(Lang(21658),Lang(21660),'');  //'Goto record', 'Please enter record number'
          InputStr:=trim(InputStr);
          IF (IsInteger(InputStr)) AND (InputStr<>'') THEN
            BEGIN
              InputNum:=StrToInt(InputStr);
              IF (InputNum<1) or (InputNum>df^.NumRecords)
              THEN ErrorMsg(Lang(21662))    //'The entered number exceeds the total number of records.'
              ELSE ChangeRec(InputNum,dirAbsolute);   //peReadRecord(df,InputNum);
            END;
        END;  //if not didJump
    END;
end;

procedure TDataForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
VAR
  MessRes:Integer;
  n:Integer;
  dfRelateMother: PDatafileInfo;
begin
  IF ((CloseWithOutChecks) OR (CreateIndtastningsFormError)
  OR (TestingDataForm)) AND (df^.CheckFormCreated=False) THEN CanClose:=True
  ELSE
    BEGIN
      CanClose:=True;    //Assume that DataForm can be closed
      IF df=NIL THEN Exit;
      IF (df^.CurRecModified) THEN
        BEGIN
          df^.LeaveStyle:=lsChangeRec;
          onExitEvent(df^.LatestActiveControl);
          CanClose:=df^.CanExit;
        END;
      IF (df^.CurRecModified) AND (CanClose) THEN
        BEGIN
          IF df^.AutoSave THEN
            BEGIN
              ExitExecutionBlock:=False;
              IF Assigned(df^.AfterRecordCmds) THEN ExecCommandList(df^.AfterRecordCmds);
              IF DidJump THEN CanClose:=False ELSE
                BEGIN
                  peWriteRecord(df,df^.CurRecord);
                  CanClose:=True;
                END;  //if DidJump
              IF eDlg(Format(Lang(21664),[df^.RECFilename]),   //Close dataform for %s
              mtConfirmation,[mbYes,mbNo],0)=mrYes
              THEN CanClose:=True ELSE CanClose:=False;
            END  //if autosave
          ELSE
            BEGIN
              IF (df^.IsRelatefile) or (df^.IsRelateTop)
{                THEN MessRes:=eDlg(ExtractFilename(df^.RECFilename)+#13#13+Lang(21666),mtConfirmation,[mbYes,mbNo],0)
              ELSE IF (df^.IsRelatetop)
                //THEN MessRes:=eDlg(ExtractFilename(df^.RECFilename)+#13#13+Lang(21666),mtConfirmation,[mbYes,mbNo,mbCancel],0)  //'Save record to disk?'}
                THEN MessRes:=SaveDlg(ExtractFilename(df^.RECFilename)+#13#13+Lang(21666),[mbYes,mbNo,mbCancel])   //'Save record to disk?'
              ELSE MessRes:=SaveDlg(Lang(21666),[mbYes,mbNo,mbCancel]);  //'Save record to disk?'
              Case MessRes OF
                mrYes: BEGIN
                         ExitExecutionBlock:=False;
                         IF Assigned(df^.AfterRecordCmds) THEN ExecCommandList(df^.AfterRecordCmds);
                         IF DidJump THEN CanClose:=False ELSE
                           BEGIN
                             peWriteRecord(df,df^.CurRecord);
                             CanClose:=True;
                           END;  //if DidJump
                       END;
                mrNo: CanClose:=True;
                mrCancel: CanClose:=False;
              END;   //Case
            END;  //if not autosave
        END;    //if modified
      //IF (CanClose) AND (df^.CheckFormCreated) THEN IsClosingcheckFilemode:=True;
      //IF NOT IsClosingCheckFilemode THEN df^.OKToBackup:=True;
      //IF (CanClose) AND (NOT TestingDataForm) AND (NOT CheckFileMode)
      //AND (Assigned(df^.AfterFileCmds)) THEN ExecCommandList(df^.AfterFileCmds);
    END;  //if not CloseWithOutChecks

  IF (CanClose) AND (df^.CheckFormCreated) THEN
    BEGIN
      df^.DataFormCreated:=False;
      IsClosingCheckFilemode:=True;
      TpCheckForm(df^.ChkForm).Close;
      {Check if CheckForm still exists -
      if yes then keep IndtastningsForm
      if no  then close IndtastningsForm}
      IF df^.CheckFormCreated THEN
        BEGIN
          df^.DataFormCreated:=True;
          IsClosingCheckFilemode:=False;
          CanClose:=False
        END
      ELSE CanClose:=True;
    END;

  IF (CanClose) AND (df^.IsRelateFile) THEN
    BEGIN
      IF df^.IsInRelate THEN
        BEGIN
          SetToReadOnly;
          df^.CanActivate:=False;
          df^.UseFilter:=False;
          MainForm.StatPanel6.Caption:='';
          TEntryField(df^.RelateField^.EntryField).Enabled:=df^.OldEnabledState;
          dfRelateMother:=PDatafileInfo(df^.RelateMother);
          TDataForm(dfRelateMother^.DatForm).RestoreReadOnly;
          TDataForm(dfRelateMother^.DatForm).Show;
          IF dfRelateMother^.CurRecord<>df^.MotherRecNum
          THEN peReadRecord(dfRelateMother,df^.MotherRecNum);

          //Run rest of commands in RelateMother
          ExitExecutionBlock:=False;
          PDatafileInfo(df^.RelateMother)^.RelateCalled:=False;
          df^.IsInRelate:=False;
          //ActiveRelateFile:=df^.RelateMother;
          ActivateRelateFile(df^.RelateMother);
          IF Assigned(dfRelateMother^.LastCommands) THEN
            BEGIN
              //ShowLastCmds('ExecCommandList of RelateMother of '+ExtractFilename(df^.RECFilename),dfRelateMother);
              dfRelateMother^.RelateCalled:=False;
              TDataForm(dfRelateMother^.DatForm).ExecCommandList(dfRelateMother^.LastCommands);
              //Remove cmdLeaveField - other cmds are part of an After Entry (or the like) structure
              //and will be freed later
              FOR n:=0 TO dfRelateMother^.LastCommands.Count-1 DO
                IF PCmds(dfRelateMother^.LastCommands.Items[n])^.Command=cmdLeaveField
                THEN Dispose(dfRelateMother^.LastCommands.Items[n]);
              dfRelateMother^.LastCommands.Free;
              dfRelateMother^.LastCommands:=NIL;
              IF dfRelateMother^.RelateCalled THEN
                BEGIN
                  //Move commands in tmpLastCmds to LastCommands
                  dfRelateMother^.LastCommands:=TList.Create;
                  FOR n:=0 TO dfRelateMother^.tmpLastCmds.Count-1 DO
                    dfRelateMother^.LastCommands.Add(dfRelateMother^.tmpLastCmds.Items[n]);
                  dfRelateMother^.tmpLastCmds.Free;
                END;
            END;
        END
      ELSE TDataForm(PDatafileInfo(df^.RelateMother)^.DatForm).Show;
      CanClose:=False;
    END;
end;  //FormCloseQuery

{Procedure TDataForm.ShowLastCmds(VAR df:PDatafileInfo);
VAR
  listen: TStringList;
BEGIN
  TRY
    Listen:=TStringList.Create;
    IF FileExists('Listen.txt') THEN Listen.LoadFromFile('Listen.txt');
    Listen.Append('Aktiverer '+ExtractFilename(df^.RECFilename));
    Listen.SaveTofile('Listen.txt');
  Finally
    Listen.Free;
  END;
END;}

Procedure TDataForm.ShowFieldInfo;
VAR
  s:String;
  CurField:Integer;
BEGIN
  s:='';
  CurField:=df^.FieldList.IndexOf(TEntryField(df^.LatestActiveControl).dfField);
  WITH PeField(df^.FieldList.Items[CurField])^ DO
    BEGIN
      s:='FName="'+FName+'"'+#13+
      'Missing 1 = '+FMissingValues[0]+#13+
      'Missing 2 = '+FMissingValues[1]+#13+
      'Missing 3 = '+FMissingValues[2]+#13+
      'CurRecModified='+IntToStr(ORD(df^.CurRecModified))+#13+
      'Active relatefile='+Extractfilename(ActiveRelateFile^.RECFilename)+#13+
      'df isInrelate='+IntToStr(ORD(df^.IsInRelate))+#13+
      'df isReadOnly='+IntToStr(ORD(df^.IsReadOnly))+#13+
      'Felttype='+IntToStr(ORD(Felttype))+#13+
      'FShowLegalPickList='+IntToStr(ORD(FShowLegalPickList))+#13+
      'FLength='+IntToStr(FLength)+#13+
      'FNumDecimals='+IntToStr(FNumDecimals)+#13+
      'FMustEnter='+IntToStr(ORD(FMustEnter))+#13+
      'FRepeat='+IntToStr(ORD(FRepeat))+#13+
      'FMin="'+FMin+'"'+#13+
      'FMax="'+FMax+'"'+#13+
      'FLegal="'+FLegal+'"'+#13+
      'FRangeDefined='+IntToStr(ORD(FRangeDefined))+#13+
      'FJumps="'+FJumps+'"'+#13+
      //'FJumpResetChar="'+FJumpResetChar+'"'+#13+
      'FValueLabel="'+FValueLabel+'"'+#13+
      'FQuestion="'+FQuestion+'"'+#13+
//      'FQuestTop='+IntToStr(FQuestTop)+#13+
//      'FQuestLeft='+IntToStr(FQuestLeft)+#13+
//      'FFieldTop='+IntToStr(FFieldTop)+#13+
//      'FFieldLeft='+IntToStr(FFieldLeft)+#13+
//      'FFieldWidth='+IntToStr(FFieldWidth)+#13+
      'LastField='+IntToStr(ORD(LastField))+#13+
//      'FFieldX='+IntToStr(FFieldX)+#13+
//      'FFieldY='+IntToStr(FFieldY)+#13+
//      'FQuestX='+IntToStr(FQuestX)+#13+
//      'FQuestY='+IntToStr(FQuestY)+#13+
      'FOriginalQuest="'+FOriginalQuest+'"'+#13+
      'FFieldText="'+FFieldText+'"'+#13+
      'Text="'+TEntryField(EntryField).Text+'"'+#13+
      'ReadOnly='+IntToStr(ORD(TEntryField(EntryField).ReadOnly))+#13+
      'FIndex='+IntToStr(FIndex)+#13+
      'FConfirm='+IntToStr(ORD(FConfirm))+#13+
      'MaxLength='+IntToStr(TEntryField(EntryField).MaxLength);
    END;
  ShowMessage(s);
  FieldInfoTrigger:=0;
END;

Procedure TDataForm.ShowVarInfo;   //&&
VAR
  ALabelEdit: TLabelEditForm;
  n,NumFiles,CurMum: Integer;
  AVar: PDefVar;
  qu: String;
  s: String;
  Mumdf,bdf: PDatafileInfo;
  AField: PeField;
  ADataForm: TDataForm;

  Procedure AddDfInfo(filenumber:Integer; Var adf: PDatafileInfo);
  VAR
    nn:Integer;
    RelDf:PDatafileInfo;
    AInfo: PRelateInfo;
  BEGIN
    With ALabelEdit.Memo1.Lines DO
      BEGIN
        Append('');
        Append(Format(Lang(50222),[filenumber,adf^.RECFilename]));  //50222=DATAFILE %2d: %s
        Append(format('  '+Lang(50224),[adf^.indexcount]));  //50224=%d keyfields defined.
        IF adf^.IndexCount>0 THEN
          BEGIN
            FOR nn:=1 TO MaxIndices DO
              BEGIN
                IF adf^.IndexFields[nn]<>-1 THEN
                  BEGIN
                    AField:=PeField(adf^.FieldList.Items[adf^.Indexfields[nn]]);
                    s:=Format('    %-10s: Key %d',[trim(AField^.FName),nn]);
                    IF adf^.IndexIsUnique[nn] THEN s:=s+' (unique)';
                    Append(s);
                  END;  //if indexslot used
              END;  //for nn
          END;  //if  indexcount>0
        IF adf^.HasRelate THEN
          BEGIN
            Append('');
            AInfo:=adf^.RelateInfo;
            WHILE AInfo<>NIL DO
              BEGIN
                RelDf:=PDatafileInfo(RelateFiles.Objects[AInfo^.RelFileNo]);
                Append(Format('    '+Lang(7002),
                [trim(PeField(adf^.FieldList.Items[AInfo^.CmdInFieldNo])^.FName),ExtractFilename(RelDf^.RECFilename)]));
                //7002=Relates in %s to %s
                Append(Format('    '+Lang(7004),[trim(PeField(adf^.FieldList.Items[AInfo^.RelFieldNo])^.FName)]));
                //7004=via keyfield %s
                Append('');
                AInfo:=AInfo^.Next;
              END;
          END;  //if HasRelate

      END;  //with  AlabelEdit.Memo1.Lines
  END;  //procedure AddDfInfo

BEGIN
  TRY
    ALabelEdit:=TLabelEditForm.Create(MainForm);
    //IF DataentryNotesPos.Top<>-1 THEN LabelEditForm.BoundsRect:=DataEntryNotesPos;
    ALabelEdit.Caption:=Format(Lang(50218),[ExtractFilename(df^.RECFilename)]);   //50218=Temporary variables in %s
    WITH ALabelEdit DO
      BEGIN
        UseAsEditor:=True;
        //fyld indhold i
        n:=-1;
        Memo1.Lines.Append('');
        Memo1.Lines.Append('EpiData '+EpiDataVersion+' (build '+BuildNo+')');
        Memo1.Lines.Append('');
        Memo1.Lines.Append('');        
        {Search list of global vars}
        Memo1.Lines.Append(Lang(50220));   //50220=Global temporary variables:
        IF (GlobalDefList<>NIL) AND (GlobalDefList.Count>0) THEN
          BEGIN
            FOR n:=0 TO GlobalDefList.Count-1 DO
              BEGIN
                AVar:=PDefVar(GlobalDefList.Objects[n]);
                IF (AVar^.Felttype in [ftAlfa,ftUpperAlfa,ftCrypt,ftSoundex]) THEN qu:='"' ELSE qu:='';
                IF trim(AVar^.FFieldText)='' THEN
                  BEGIN
                    s:='.';
                    qu:='';
                  END
                ELSE s:=trim(AVar^.FFieldText);
                Memo1.Lines.Append(Format('%16s = '+qu+'%s'+qu+'   (%s, length %d)',
                [GlobalDefList[n],s,FieldtypeNames[ORD(AVar^.Felttype)],AVar^.FLength]));
              END;  //for
          END  //if has Globals
        ELSE Memo1.Lines.Append(Lang(50226));    //50226=No global variables defined.
        Memo1.Lines.Append('');
        Memo1.Lines.Append(Format(Lang(50228),[Extractfilename(self.df^.RECFilename)]));  //50228=Local variables in %s:

        {search local variables}
        IF (self.df^.DefList<>NIL) AND (self.df^.DefList.Count<>0) THEN
          BEGIN
            FOR n:=0 TO self.df^.DefList.Count-1 DO
              BEGIN
                AVar:=PDefVar(self.df^.DefList.Objects[n]);
                IF (AVar^.Felttype in [ftAlfa,ftUpperAlfa,ftCrypt,ftSoundex]) THEN qu:='"' ELSE qu:='';
                IF trim(AVar^.FFieldText)='' THEN
                  BEGIN
                    s:='.';
                    qu:='';
                  END
                ELSE s:=trim(AVar^.FFieldText);
                Memo1.Lines.Append(Format('%16s = '+qu+'%s'+qu+'   (%s, length %d)',
                [self.df^.DefList[n],s,FieldtypeNames[ORD(AVar^.Felttype)],AVar^.FLength]));
              END;  //for
          END  //if has Globals
        ELSE Memo1.Lines.Append(Lang(50230));  //50230=No local variables defined.


        Memo1.Lines.append('');
        IF RelateMothers=NIL THEN NumFiles:=1 ELSE NumFiles:=RelateMothers.Count;
        Memo1.Lines.Append(Format(Lang(50232),[NumFiles+1]));   //50232=%d files open.
        Memo1.Lines.Append('');
        IF Numfiles=1 THEN AddDfInfo(1,self.df)
        ELSE
          BEGIN
            ADataForm:=TDataForm(MainForm.TabCtrl.tabs.objects[MainForm.TabCtrl.TabIndex]);
            bdf:=ADataForm.df;
            Memo1.Lines.Append(Lang(50234)+' '+bdf^.RECFilename);  //50234=Current datafile:
            IF bdf^.CurRecord=-1 THEN s:=Lang(13468) ELSE s:=IntToStr(bdf^.CurRecord);   //13468=New Record
            Memo1.Lines.Append(Lang(50236)+'   '+s);   //50236=Current record:
            Memo1.Lines.Append(Lang(20818)+'    '+Inttostr(bdf^.NumRecords));  //20818=Records total:
            Memo1.Lines.Append('');
            MumDf:=PDatafileInfo(RelateMothers.Items[0]);
            bdf:=PDatafileInfo(Relatefiles.Objects[0]);
            AddDfInfo(1,MumDf);
            FOR CurMum:=0 TO RelateMothers.Count-1 DO
              BEGIN
                bdf:=PDatafileInfo(Relatefiles.Objects[curMum]);
                AddDfInfo(CurMum+2,bdf);
              END;  //for CurMum
          END;  //else


        Memo1.Modified:=False;
        Memo1.SelStart:=0;
        Memo1.SelLength:=0;
        //PostMessage(Memo1.Handle,EM_SCROLLCARET,0,0);
        n:=ShowModal;
        //DataEntryNotesPos:=LabelEditForm.BoundsRect;
      END;  //with
    FINALLY
      LabelEditForm.Free;
    END;
END;


procedure TDataForm.ShowLegalPickList(ACaption: String);
VAR
  n:Integer;
  dfField:PeField;
  SenderField:TEntryField;
  ALabelRec:PLabelRec;
  s:String;
  LegalVals: TStringList;
  MaxTextWidth,w: Integer;
  OnlyOneChar,OnlyNumbers: Boolean;
BEGIN
  SenderField:=df^.LatestActiveControl AS TEntryField;
  dfField:=PeField(SenderField.dfField);
  IF (dfField^.FLegal<>'') OR (dfField^.FCommentLegalRec<>NIL) THEN
    BEGIN
      TRY
        LegalVals:=TStringList.Create;
        IF Assigned(LegalPickForm) THEN LegalPickForm.Free;
        LegalPickForm:=TLegalPickForm.Create(Application);
        LegalPickForm.Caption:=trim(ACaption)+' - '+Lang(21678);  //'Select value'
        MaxTextWidth:=170;

        //Add legal values to the list - but exclude ranges
        IF dfField^.FLegal<>'' THEN
          BEGIN
            LegalVals.CommaText:=dfField^.FLegal;
            IF ( (LegalVals.Count>0) AND (NOT dfField^.FRangeDefined) )
              OR ( (LegalVals.Count>1) AND (dfField^.FRangeDefined) )
            THEN IF dfField^.FRangeDefined THEN LegalVals.Delete(0);
          END;  //if Legal defined
        IF (LegalVals.Count=1) AND (dfField^.FRangeDefined) THEN LegalVals.Clear;
        OnlyOneChar:=False;

        //Add comment legal values
        w:=0;
        IF dfField^.FCommentLegalRec<>NIL THEN
          BEGIN
            OnlyNumbers:=True;
            w:=0;
            ALabelRec:=dfField^.FCommentLegalRec;
            WHILE ALabelRec<>NIL DO
              BEGIN
                s:=trim(ALabelRec^.Value);    //###
                IF s<>'' THEN
                  begin
                    IF s[1]<>'*' THEN
                      BEGIN
                        IF Length(trim(ALabelRec^.Value))>w THEN w:=Length(trim(ALabelRec^.Value));
                        IF (NOT IsInteger(ALabelRec^.Value)) THEN OnlyNumbers:=False;
                      END;
                  end;
                ALabelRec:=ALabelRec^.Next;
              END;  //while

            OnlyOneChar:=True;
            ALabelRec:=dfField^.FCommentLegalRec;
            WHILE ALabelRec<>NIL DO
              BEGIN
                //s:=ALabelRec^.Value+'  -  '+ALabelRec^.Text;
                s:=trim(ALabelRec^.Value);
                if s='' then s:='.';
                IF s[1]<>'*' THEN
                  BEGIN
                    s:=Format('%-'+IntToStr(w)+'s  -  %s',[ALabelRec^.Value,ALabelRec^.Text]);
                    IF Length(trim(ALabelRec^.Value))<>1 THEN OnlyOneChar:=False;
                    LegalVals.Append(s);
                    n:=LegalPickForm.ListBox1.Canvas.TextWidth(s);
                  END;
                ALabelRec:=ALabelRec^.Next;
              END;  //While
          END;  //if commentlegals defined

        //Add Missing values
        IF (dfField^.FMissingValues[0]<>'') OR (dfField^.FMissingValues[1]<>'') OR (dfField^.FMissingValues[2]<>'') THEN
          BEGIN
            //Missing values are defined for the field
            IF Length(dfField^.FMissingValues[0])>w THEN w:=Length(dfField^.FMissingValues[0]);
            IF Length(dfField^.FMissingValues[1])>w THEN w:=Length(dfField^.FMissingValues[1]);
            IF Length(dfField^.FMissingValues[2])>w THEN w:=Length(dfField^.FMissingValues[2]);
            IF dfField^.FMissingValues[0]<>'' THEN
              BEGIN
                s:=Format('%-'+IntToStr(w)+'s  -  %s',[dfField^.FMissingValues[0],Lang(20838)]);
                IF Length(dfField^.FMissingValues[0])<>1 THEN OnlyOneChar:=False;
                LegalVals.Append(s);
                IF dfField^.FMissingValues[1]<>'' THEN
                  BEGIN
                    s:=Format('%-'+IntToStr(w)+'s  -  %s',[dfField^.FMissingValues[1],Lang(20838)]);
                    IF Length(dfField^.FMissingValues[1])<>1 THEN OnlyOneChar:=False;
                    LegalVals.Append(s);
                      IF dfField^.FMissingValues[2]<>'' THEN
                        BEGIN
                          s:=Format('%-'+IntToStr(w)+'s  -  %s',[dfField^.FMissingValues[2],Lang(20838)]);
                          IF Length(dfField^.FMissingValues[2])<>1 THEN OnlyOneChar:=False;
                          LegalVals.Append(s);
                        END;  //miss 2
                  END;  //miss 1
              END;  //miss 0
          END;
        IF (dfField^.FDefaultValue<>'') THEN
          BEGIN
            s:=Format('%-'+IntToStr(w)+'s  -  %s', [dfField^.FDefaultValue,'Default']);
            IF Length(dfField^.FDefaultValue)<>1 THEN OnlyOneChar:=false;
            LegalVals.Append(s);
          END
        ELSE IF (dfField^.FHasGlobalDefaultValue) THEN
          BEGIN
            s:=Format('%-'+IntToStr(w)+'s  -  %s', [df^.GlobalDefaultValue,'Default']);
            IF Length(dfField^.FMissingValues[2])<>1 THEN OnlyOneChar:=False;
            LegalVals.Append(s);
          END;
        IF LegalVals.Count=0 THEN Exit;
        LegalPickForm.Width:=LegalPickFormWidth;
        LegalPickForm.Height:=LegalPickFormHeight;
        IF PickListPos.x>=0 THEN LegalPickForm.Left:=PickListPos.x;
        IF PickListPos.y>=0 THEN LegalPickForm.Top:=PickListPos.y;
        LegalPickForm.ListBox1.Items.Assign(LegalVals);
        LegalPickForm.CloseonKeydown:=OnlyOneChar;
        IF dfField^.FPickListNoSelect THEN LegalPickForm.ListBox1.ItemIndex:=-1
        ELSE
          BEGIN
            LegalPickForm.Edit1.Text:=LegalPickForm.ListBox1.Items[0];
            LegalPickForm.ListBox1.ItemIndex:=0;
          END;
        IF LegalPickForm.ShowModal=mrOK THEN
          BEGIN
            n:=LegalPickForm.ListBox1.ItemIndex;
            IF n>-1 THEN
              BEGIN
                s:=LegalPickForm.ListBox1.Items[n];
                IF Pos('  -  ',s)>0 THEN s:=Copy(s,1,Pos('  -  ',s)-1);
                //LegalPickForm.Free;
                TEntryField(df^.LatestActiveControl).Text:=trim(s);
              END;  //if ItemIndex>-1
          END;  //if mrOK
{        ELSE
          BEGIN
            LegalPickForm.Free;
          END;}
      FINALLY
        LegalVals.Free;
        LegalVals:=NIL;
        IF Assigned(LegalPickForm) THEN
          BEGIN
            LegalPickFormWidth:=LegalPickForm.Width;
            LegalPickFormHeight:=LegalPickForm.Height;
            PickListPos.x:=LegalPickForm.Left;
            PickListPos.y:=LegalPickForm.Top;
            LegalPickForm.Free;
            LegalPickForm:=NIL;
          END;
      END;  //try..Finally
    END  //if FLegal or FCommentLegal
  ELSE Beep;
END;  //procedure ShowLegalPickList


procedure TDataForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
VAR
  AField: PeField;
  AEntryField: TEntryField;
  s:String;
  ASearchForm: TSearchForm;
begin
  IF (Key=VK_F2) AND (shift=[ssCtrl,ssAlt]) THEN
    BEGIN
      IF FieldInfoTrigger<2 THEN INC(FieldInfoTrigger) ELSE ShowFieldInfo;
    END
  ELSE FieldInfoTrigger:=0;

  IF (Key=VK_F2) AND (shift=[]) THEN
    BEGIN
      IF VarInfoTrigger<1 THEN INC(VarInfoTrigger) ELSE ShowVarInfo;
    END
  ELSE VarInfoTrigger:=0;


{  IF (df^.IsFinding) AND (Shift=[ssAlt]) THEN
    BEGIN
      IF Key=ORD(TSearchForm(df^.SearchForm).chFindNext) THEN TSearchForm(df^.SearchForm).btnFindForwardClick(Sender)
      ELSE IF Key=ORD(TSearchForm(df^.SearchForm).chFindPrev) THEN TSearchForm(df^.SearchForm).btnFindBackClick(Sender)
      ELSE IF Key=ORD(TSearchForm(df^.SearchForm).chEdit) THEN TSearchForm(df^.SearchForm).btnEditClick(Sender)
      ELSE IF Key=ORD(TSearchForm(df^.SearchForm).chClearAll) THEN TSearchForm(df^.SearchForm).btnClearClick(Sender)
      ELSE IF Key=ORD(TSearchForm(df^.SearchForm).chCancel) THEN TSearchForm(df^.SearchForm).Close
      ELSE IF Key=ORD(TSearchForm(df^.SearchForm).chHelp) THEN TSearchForm(df^.SearchForm).btnHelpClick(Sender);
    END;

  IF (df^.IsFinding) AND (Shift=[ssCtrl]) AND (Key=ORD('F')) THEN TSearchForm(df^.SearchForm).btnFindForwardClick(Sender);
}
  IgnoreJumps:=False;

  {CTRL-Arrow-left-key for horiz-scrollbar to position zero}
  IF (Key=VK_LEFT) THEN ScrollBox1.HorzScrollBar.Position:=0;

  IF (Key=VK_F7) AND (NOT CheckFileMode) AND (Previousrecord1.Enabled) THEN PrevRecButtonClick(Sender);

  IF (Key=VK_F8) AND (NOT CheckFileMode) AND (NextRecord1.Enabled) THEN NextRecButtonClick(Sender);

  IF df^.IsReadOnly THEN Exit;

  {Arrow-up-key for prev. field}
  IF (Key=VK_UP) OR ( (Key=VK_TAB) AND (Shift=[ssShift]) ) THEN
    BEGIN
      df^.LeaveStyle:=lsBrowse;
      key:=0;
      PostMessage(Self.Handle,WM_NextDlgCtl,1,0);
      Key:=0;
    END;

  {Arrow-down-key for next field}
  IF (Key=VK_DOWN) OR ( (Key=VK_TAB) AND (Shift=[]) ) THEN LeaveField(lsEnter);


  IF (Key=VK_F5) AND (NOT CheckFileMode) THEN Dataentrynotes1Click(Sender);

  IF (df^.IsInRelate) AND ( (Key=VK_F10) OR ( (Key=ORD('R')) AND (Shift=[ssCtrl]) ) ) THEN
    BEGIN
      Key:=0;
      Close;
    END;

  IF (Key=VK_F10) THEN
    BEGIN
      Key:=0;
      Close;
    END;

  IF ((Key=VK_F9) OR (Key=VK_ADD) OR (Key=$BB)) AND (NOT CheckFileMode) THEN
    BEGIN
      Key:=0;
      ShowLegalPickList(PeField(TEntryField(df^.LatestActiveControl).dfField)^.FName);
    END;

  IF CheckFileMode THEN
    BEGIN
      //IF (Key=VK_F4) THEN Findfield1Click(Sender);
      IF (Key=VK_ADD) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).GenerateLabelClick(Sender);
        END;
      IF (Key=VK_F6) OR ( (Key=VK_RIGHT) AND (Shift=[ssCtrl]) ) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).SetFocus;
        END;
      IF (Key=ORD('A')) AND (Shift=[ssCtrl]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).ValLabelCombo.SetFocus;
        END;
      IF (Key=ORD('L')) AND (Shift=[ssCtrl])
      AND (TpCheckForm(df^.ChkForm).RangeEdit.Enabled) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).RangeEdit.SetFocus;
        END;
      IF (Key=ORD('J')) AND (Shift=[ssCtrl])THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).JumpsEdit.SetFocus;
        END;
      IF (Key=ORD('E')) AND (Shift=[ssCtrl]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).pToggleMustEnter;
        END;
      IF (Key=ORD('R')) AND (Shift=[ssCtrl]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).pToggleRepeat;
        END;
      IF (Key=ORD('C')) AND (Shift=[ssCtrl]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).pCopyChecks;
        END;
      IF (Key=ORD('V')) AND (Shift=[ssCtrl]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).pInsertChecks;
        END;
      IF (Key=ORD('X')) AND (Shift=[ssCtrl])THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).pCutChecks;
        END;
      IF ( (Key=ORD('D')) AND (Shift=[ssAlt]) ) OR (Key=VK_F9) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).EditChecksBtnClick(Sender);
        END;
      IF (Key=ORD('S')) AND (Shift=[ssAlt]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).SaveBtnClick(Sender);
        END;
      IF (Key=ORD('C')) AND (Shift=[ssAlt]) THEN
        BEGIN
          Key:=0;
          TpCheckForm(df^.ChkForm).ExitBtnClick(Sender);
        END;
    END; //if CheckFileMode
end;


Procedure TDataForm.FocusFirstField;
VAR
  fN:Integer;
  stop:Boolean;
  AField: PeField;
  AEntryField: TEntryField;
BEGIN
  fN:=0;
  Stop:=False;
  IF Assigned(ScrollBox1.VertScrollBar)
  THEN ScrollBox1.VertScrollBar.Position:=0;
  WHILE (fN<=df^.FieldList.Count-1) AND (Stop=False) DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[fN]);
      IF AField^.FeltType<>ftQuestion THEN
        BEGIN
          AEntryField:=TEntryField(AField^.EntryField);
          IF AEntryField.CanFocus THEN Stop:=True ELSE Inc(fN);
        END
      ELSE INC(fN);
    END;  //while
  IF Stop THEN AEntryField.SetFocus;
END;   //procedure FocusFirstField

Procedure TDataForm.FocusLastField;
VAR
  fN:Integer;
  stop:Boolean;
  AField: PeField;
  AEntryField: TEntryField;
BEGIN
  fN:=df^.FieldList.Count-1;
  Stop:=False;
  IF Assigned(ScrollBox1.VertScrollBar)
  THEN ScrollBox1.VertScrollBar.Position:=ScrollBox1.VertScrollBar.Range;
  WHILE (fN>0) AND (Stop=False) DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[fN]);
      IF AField^.FeltType<>ftQuestion THEN
        BEGIN
          AEntryField:=TEntryField(AField^.EntryField);
          IF AEntryField.CanFocus THEN Stop:=True ELSE Dec(fN);
        END
      ELSE Dec(fN);
    END;  //While
  IF Stop THEN AEntryField.SetFocus;
END;   //procedure FocusLastField


procedure TDataForm.Firstfield1Click(Sender: TObject);
begin
  FocusFirstField;
end;

procedure TDataForm.Lastfield1Click(Sender: TObject);
begin
  FocusLastField;
end;

Function TDataForm.ShowFieldSelect(VAR AField:PeField): Integer;
VAR
  n,w,ModResult:Integer;
  s,FormStr: String;
  NewCol: TListColumn;
  ListItem: TListItem;
  HasVarlabels:Boolean;
  GotoRelateList: Boolean;
BEGIN
  GotoRelateList:=False;
  IF df^.FieldNamesList=NIL THEN
    BEGIN
      {List of Fieldnames is not created - make it}
      w:=0;
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.Items[n]);
          IF AField^.Felttype<>ftQuestion THEN
            BEGIN
              IF Length(trim(AField^.FName))>w THEN w:=Length(trim(AField^.FName));
              IF (trim(AField^.FVariableLabel)<>'')
              AND (LowerCase(trim(AField^.FVariableLabel))<>LowerCase(trim(AField^.FName))) THEN HasVarLabels:=True;
            END;
        END;
      df^.FieldNamesList:=TStringList.Create;
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.Items[n]);
          IF AField^.FeltType<>ftQuestion THEN
            BEGIN
              IF HasVarLabels
              THEN s:=Format('%-'+IntToStr(w)+'s - %s',[trim(Afield^.FName),trim(AField^.FVariableLabel)])
              ELSE s:=Format('%-'+IntToStr(w)+'s  ',[trim(AField^.FName)]);
              IF AField^.FIndex>0 THEN s:=s+' (KEY '+IntToStr(AField^.FIndex)+')';
              df^.FieldNamesList.AddObject(s,TObject(AField));
            END;
        END;
    END;  //if FieldNames=NIL
  TRY
    LegalPickForm:=TLegalPickForm.Create(NIL);
    LegalPickForm.Caption:=Lang(4102);    //4102=Select field to jump to
    LegalPickForm.ListBox1.Items.Assign(df^.FieldNamesList);
    LegalPickForm.ListBox1.ItemIndex:=0;
    IF PickListPos.x>=0 THEN LegalPickForm.Left:=PickListPos.x;
    IF PickListPos.y>=0 THEN LegalPickForm.Top:=PickListPos.y;
    LegalPickForm.Width:=FieldNamesListWidth;

    Result:=LegalPickForm.ShowModal;
    IF Result=mrOK THEN
      BEGIN
        n:=LegalPickForm.ListBox1.ItemIndex;
        IF n>-1 THEN AField:=PeField(LegalPickForm.ListBox1.Items.Objects[n]);
          //BEGIN
            AField:=PeField(LegalPickForm.ListBox1.Items.Objects[n]);
            //AEntryField:=TEntryField(AField^.EntryField);
            //IF AEntryField.CanFocus THEN AEntryField.SetFocus
            //ELSE Self.ScrollBox1.VertScrollBar.Position:=AEntryField.Top;
          //END;
      END;  //if mrOK
  FINALLY
    PickListPos.x:=LegalPickForm.Left;
    PickListPos.y:=LegalPickForm.Top;
    FieldNamesListWidth:=LegalPickForm.Width;
    LegalPickForm.Free;
    LegalPickForm:=NIL;
    //IF ModResult=mrAll THEN Findrelatefield1Click(Sender);
  END;
END;

procedure TDataForm.Findfield1Click(Sender: TObject);
VAR
  n,w,ModResult:Integer;
  AField: PeField;
  AEntryField: TEntryField;
  s,FormStr: String;
  NewCol: TListColumn;
  ListItem: TListItem;
  HasVarlabels:Boolean;
begin
  ModResult:=ShowFieldSelect(AField);
  IF ModResult=mrOK THEN
    BEGIN
      AEntryField:=TEntryField(AField^.EntryField);
      IF AEntryField.CanFocus THEN AEntryField.SetFocus
      ELSE Self.ScrollBox1.VertScrollBar.Position:=AEntryField.Top;
    END;
  IF ModResult=mrAll THEN FindRelateField1Click(Sender);
end;


procedure TDataForm.FormCreate(Sender: TObject);
begin
  df:=NIL;
  QuitEpiData:=False;
  IsClosingCheckFilemode:=False;
  TranslateForm(self);
  ScrollBox1.Font.Assign(epiDataFormFont);
  Canvas.Font.Assign(epiDataFormFont);
  ScrollBox1.Color:=DataFormColor;
  IF (CheckFileMode) OR (TestingDataform) THEN RecNavPanel.Visible:=False
  ELSE DoUseSounds:=True;
  IF TestingDataform or OpenWithRelate THEN
    BEGIN
      MainForm.TabCtrl.Tabs.AddObject(Lang(11028),TObject(Self));  //'Preview dataform'
      MainForm.TabCtrl.TabIndex:=MainForm.TabCtrl.Tabs.Count-1;
    END;
  EnforceMustEnter:=False;
  IgnoreJumps:=False;
  TypePanel.Caption:='';
  LegalPickForm:=NIL;
end;

procedure TDataForm.SearchRecords(Sender: TObject);
VAR
  n,n2:Integer;
  AEntryField: TEntryField;
  AField: PeField;
  ALabelEdit: TLabelEditForm;
begin
  DidJump:=False;
  IF df^.NumRecords>0 THEN
    BEGIN
      IF df^.IsFinding THEN TSearchForm(df^.SearchForm).btnFindForwardClick(sender)
      ELSE
        BEGIN
          IF (df^.CurRecModified) THEN
            BEGIN
              df^.LeaveStyle:=lsChangeRec;
              onExitEvent(df^.LatestActiveControl);
              IF NOT df^.CanExit THEN Exit;
            END;
          IF df^.CurRecModified THEN SaveRecord;
          //IF NOT DidJump THEN EnterSearchMode(df);
          IF NOT DidJump THEN
            BEGIN
              IF df^.FieldNames=NIL THEN
                BEGIN
                  df^.FieldNames:=TStringList.Create;
                  FOR n:=0 TO df^.FieldList.Count-1 DO
                    IF PeField(df^.FieldList.Items[n])^.Felttype<>ftQuestion
                    THEN df^.FieldNames.Append(trim(PeField(df^.FieldList.Items[n])^.FName));
                END;
              AEntryField:=TEntryField(df^.LatestActiveControl);
              AField:=PeField(AEntryField.dfField);
              SearchForm:=TSearchForm.Create(NIL);
              IF SearchBoxPos.x>=0 THEN SearchForm.Left:=SearchBoxPos.x;
              IF SearchBoxPos.y>=0 THEN SearchForm.Top:=SearchBoxPos.y;
              SearchForm.sg.Cells[0,0]:=trim(AField^.FName);
              SearchForm.CallingFieldName:=trim(Afield^.FName);
              SearchForm.sg.col:=1;
              SearchForm.sg.row:=0;
              SearchForm.theDf:=df;
              IF df^.FindOpt=NIL THEN
                BEGIN
                  New(df^.FindOpt);
                  df^.FindOpt^.FoundRecs:=NIL;
                  df^.FindOpt^.Scope:=ssAll;
                  df^.FindOpt^.IgnoreDeleted:=True;
                  df^.FindOpt^.CaseSensitive:=False;
                  df^.FindOpt^.WholeWordsOnly:=True;
                END;
              ResetFindOptions(df);
              //SearchForm.sg.SetFocus;
              TRY
                n:=SearchForm.ShowModal;
                SearchBoxPos.x:=SearchForm.Left;
                SearchBoxPos.y:=SearchForm.Top;
              FINALLY
                SearchForm.Free;
              END;  //try..finally
              n2:=n;
              //vis søgekrit
{//***************************************************************************
  TRY
    ALabelEdit:=TLabelEditForm.Create(NIL);
    //IF DataentryNotesPos.Top<>-1 THEN LabelEditForm.BoundsRect:=DataEntryNotesPos;
    ALabelEdit.Caption:='How to use Find Record';
        //fyld indhold i
        n:=-1;
        With ALabelEdit.Memo1.Lines DO
          BEGIN
            append('Startrecord='+IntToStr(df^.FindOpt^.StartRecord));
            append('Numcrites='+IntToStr(df^.FindOPt^.NumCrites));
            append('');
            FOR n:=1 TO df^.FindOPt^.NumCrites DO
              BEGIN
                append(IntToStr(n)+'. kriterie:');
                append('Fieldno='+IntToStr(df^.FindOPt^.Crites[n].Fieldno));
                CASE df^.FindOPt^.Crites[n].Opr OF
                  opNone: Append('Opr= opNone');
                  opEq:   Append('Opr= opEq');
                  opNEq:  Append('Opr= opNEq');
                  opGT:   Append('Opr= opGT');
                  opLT:   Append('Opr= opLT');
                  opBW:   Append('Opr= opBW');
                  opEW:   Append('Opr= opEW');
                  opCON:  Append('Opr= opCON');
                END;  //case
                append('Searchtext= "'+df^.FindOPt^.Crites[n].SearchText+'"');
                Append('SearchValue= '+FloatToStr(df^.FindOPt^.Crites[n].SearchValue));
                Append('');
              END;  //for
          END;  //with

      WITH ALabelEdit DO
        BEGIN
        Memo1.Modified:=False;
        Memo1.ReadOnly:=True;
        Memo1.SelStart:=0;
        Memo1.SelLength:=0;
        //PostMessage(Memo1.Handle,EM_SCROLLCARET,0,0);
        n:=ShowModal;
        //DataEntryNotesPos:=LabelEditForm.BoundsRect;
      END;  //with
    FINALLY
      LabelEditForm.Free;
    END;
//***************************************************************************}
              n:=n2;
              IF n=mrOK THEN Search(df,False);
            END;  //if not didJump
        END;  //if not isFinding
    END; //if Numrecords>0
end;

procedure TDataForm.Findagain1Click(Sender: TObject);
begin
  IF (df^.CurRecModified) THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF NOT df^.CanExit THEN Exit;
    END;
  IF df^.CurRecModified THEN SaveRecord;
  Search(df,False);
end;


Procedure TDataForm.FindEditClick(Sender: TObject);
begin
  IF df^.NumRecords>0 THEN
    BEGIN
      IF (df^.CurRecModified) THEN
        BEGIN
          df^.LeaveStyle:=lsChangeRec;
          onExitEvent(df^.LatestActiveControl);
          IF NOT df^.CanExit THEN Exit;
        END;
      IF df^.CurRecModified THEN SaveRecord;
      IF NOT DidJump THEN FindByExample(df,True,ssForward,False);  //calls FindAgain in FindByExample
    END;
end;

Procedure TDataForm.FindNewClick(Sender: TObject);
BEGIN
  IF df^.NumRecords>0 THEN
    BEGIN
      IF (df^.CurRecModified) THEN
        BEGIN
          df^.LeaveStyle:=lsChangeRec;
          onExitEvent(df^.LatestActiveControl);
          IF NOT df^.CanExit THEN Exit;
        END;
      IF df^.CurRecModified THEN SaveRecord;
      IF NOT DidJump THEN FindByExample(df,True,ssForward,True);  //calls FindAgain in FindByExample
    END;
END;

procedure TDataForm.FormActivate(Sender: TObject);
VAR
  HasRelate,tmpOne2One: Boolean;
  n: Integer;
  RelDf,FromDf,ToDf: PDatafileInfo;
  FromForm,ToForm: TForm;
  AInfo: PRelateInfo;
  AField: PeField;
begin
  HasRelate:=False;
  IF Assigned(df) THEN IF (df^.IsRelateTop) OR (df^.IsRelateFile) THEN HasRelate:=True;
  IF HasRelate THEN Findrelatefield1.Enabled:=True;
  IF TestingDataform or HasRelate THEN
    BEGIN
      ChangeGoingOn:=True;
      //Handle tab-control position
      MainForm.TabCtrl.TabIndex:=MainForm.TabCtrl.tabs.IndexOfObject(TObject(self));
      //Handle RelateTree position
      IF (Assigned(RelateTreeForm)) AND (RelateTreeCount>0) THEN
        BEGIN
          WITH RelateTreeForm DO
            BEGIN
              IF Assigned(RelateTree) THEN
                BEGIN
                  FOR n:=0 TO RelateTree.Items.Count-1 DO
                    BEGIN
                      IF df=PDatafileInfo(RelateTree.Items.Item[n].Data)
                      THEN RelateTree.Selected:=RelateTree.Items[n];
                    END;
                END;
            END;  //with
        END;  //if relateTreeForm
      //Handle change of relate level
      {Perform change of relate level if:
       - user changes from the active relate file's form to a relatechild of the active relate file
       - the relevant relatefield is <> missing

      }
{      FromForm:=LatestViewedDataForm;
      LatestViewedDataForm:=self;
      ToForm:=self;
      IF (FromForm<>NIL) AND (df<>NIL) THEN
        BEGIN
          IF ActiveRelateFile^.DatForm=FromForm THEN
            BEGIN
              //Find the relevant relatefield
              IF (FromForm is TDataForm) AND (ToForm is TDataForm) THEN
                BEGIN
                  FromDf:=TDataForm(FromForm).df;
                  ToDf:=TDataForm(ToForm).df;
                  AInfo:=FromDf^.RelateInfo;
                  n:=-1;
                  WHILE (AInfo<>NIL) AND (n=-1) DO
                    BEGIN
                      IF ToDf=PDatafileInfo(RelateFiles.Objects[AInfo^.RelFileNo]) THEN
                        BEGIN
                          n:=AInfo^.RelFieldNo;
                          tmpOne2One:=AInfo^.One2One;
                        END;
                      AInfo:=AInfo^.Next;
                    END; //while
                  //If n<>-1 then n is the fieldlist-number of the field that relates
                  //FromDf to ToDf
                  IF n<>-1 THEN
                    BEGIN
                      AField:=PeField(FromDf^.FieldList.Items[n]);
                      IF trim(AField^.FFieldText)<>'' THEN
                        BEGIN
                          //All checks are in green: Perform the relate
                          ChangeRelateLevel(FromDf,ToDf,AField^.FName,tmpOne2One,False);
                        END;  //if FFieldText<>''
                    END;  //if n<>-1

                  //Showmessage('Skifter'+#13+'fra '+ExtractFilename(fradf^.RECFilename)+
                  //#13+'til '+ExtractFilename(tildf^.RECFilename)+
                  //#13+'Aktiv='+ExtractFilename(ActiveRelateFile^.RECFilename));
                END;
            END;
        END;}
      ChangeGoingOn:=False;
    END;
  IF Assigned(df) THEN
    BEGIN
      IF Assigned(df^.LatestActiveControl) THEN OnEnterEvent(df^.LatestActiveControl);
      IF df^.TypeStatusBarField>-1 THEN
        BEGIN
          TypePanel.Font.Color:=ColorValues[df^.TypeStatusBarColor];
          TypePanel.Caption:=df^.TypeStatusBarText+' '+
          trim(PeField(df^.FieldList.Items[df^.TypeStatusBarField])^.FFieldText);
        END
      ELSE TypePanel.Caption:='';
    END;
end;

procedure TDataForm.FormDeactivate(Sender: TObject);
begin
  LatestViewedDataForm:=self;
  MainForm.StatPanel1.Caption:='';
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel3.Caption:='';
  MainForm.StatPanel4.Caption:='';
  MainForm.StatPanel5.Caption:='';
  MainForm.StatPanel6.Caption:='';
end;

procedure TDataForm.ScrollUp1Click(Sender: TObject);
begin
  ScrollBox1.VertScrollBar.Position:=
  ScrollBox1.VertScrollBar.Position-((ScrollBox1.ClientHeight*85) DIV 100);
end;

procedure TDataForm.ScrollDown1Click(Sender: TObject);
begin
  ScrollBox1.VertScrollBar.Position:=
  ScrollBox1.VertScrollBar.Position+((ScrollBox1.ClientHeight*85) DIV 100);
end;

{Function TDataForm.HandleVars( const Identifier: String; ParameterList: TParameterList): IValue;
VAR
  n:Integer;
  AField:PeField;
  tmpStr: String;
  tmpFieldType: TFeltTyper;
  tmpDefVar: PDefVar;
BEGIN
  //Handle identifiers that requires parameters
  IF Identifier='DATE' THEN Result:=TDateExpr.Create(ParameterList)
  ELSE IF Identifier='YEAR' THEN Result:=TYearExpr.Create(ParameterList)
  ELSE IF Identifier='MONTH' THEN Result:=TMonthExpr.Create(ParameterList)
  ELSE IF Identifier='DAY' THEN Result:=TDayExpr.Create(ParameterList)
  ELSE IF Identifier='WEEKNUM' THEN Result:=TWeekNumExpr.Create(ParameterList)
  ELSE IF Identifier='DAYOFWEEK' THEN Result:=TDayOfWeekExpr.Create(ParameterList)
  ELSE IF Identifier='ISBLANK' THEN Result:=TIsBlankExpr.Create(ParameterList)
  ELSE IF Identifier='SOUNDEX' THEN Result:=TSoundexExpr.Create(ParameterList)
  ELSE
    BEGIN
      //Handle identifiers that does not require parameters
      if Assigned(ParameterList) then
        raise EExpression.CreateFmt(Lang(21668), [Identifier]);  //'Identifier %s does not require parameters'
      IF Identifier='MISSING' THEN Result:=TStringLiteral.Create('')
      ELSE IF Identifier='_M' THEN Result:=TStringLiteral.Create('')
      ELSE IF Identifier='TODAY' THEN Result:=TDateLiteral.Create(Int(now))
      ELSE IF (Identifier='RESULTVALUE') AND (ResultVar=0) THEN Result:=TStringLiteral.Create('')
      ELSE IF (Identifier='RESULTVALUE') AND (ResultVar>0) THEN Result:=TIntegerLiteral.Create(ResultVar)
      ELSE IF (Identifier='RESULTLETTER') AND (ResultVar=0) THEN Result:=TStringLiteral.Create('')
      ELSE IF (Identifier='RESULTLETTER') AND (ResultVar>0) THEN Result:=TStringLiteral.Create(HelpBoxLegalKeys[ResultVar])
      ELSE
        BEGIN
          //Test if Identifier is fieldname or variablename
          n:=GetFieldNumber(Identifier,df);
          IF n<>-1 THEN
            BEGIN
              //ordinary field
              AField:=PeField(df^.FieldList.Items[n]);
              tmpStr:=AField^.FFieldText;
              tmpFieldType:=AField^.Felttype;
            END
          ELSE
            BEGIN
              tmpDefVar:=GetDefField(Identifier,df);
              IF tmpDefVar<>NIL THEN
                BEGIN
                  //Identifier is DEFINEd variable
                  n:=1;
                  tmpStr:=tmpDefVar^.FFieldText;
                  tmpFieldType:=tmpDefVar^.Felttype;
                END;
            END;
          IF n<>-1 THEN
            BEGIN
              IF trim(tmpStr)='' THEN Result:=TStringLiteral.Create('')
              ELSE
              CASE tmpFieldType OF
                ftInteger,ftIDNUM:
                  Result:=TIntegerLiteral.Create(StrToInt(tmpStr));
                ftAlfa,ftUpperAlfa,ftSoundex:
                  Result:=TStringLiteral.Create(tmpStr);
                ftDate,ftEuroDate,ftToday,ftEuroToday:
                  Result:=TDateLiteral.Create(mibStrToDate(tmpStr,tmpFieldType));
                ftFloat: Result:=TFloatLiteral.Create(eStrToFloat(tmpStr));
                ftBoolean: Result:=TBooleanLiteral.Create(tmpStr='Y');
              END;  //Case;
            END;  //if Identifier is fieldname or variablename
        END;  //Test if identifier is fieldname or variablename
    END;  //Handle Identifiers that doesn't require parameters
END;  //HandleVars
}


Procedure TDataForm.ExecCommandList(VAR CmdList:TList);
VAR
  ok,ok2,changerecord:Boolean;
  tmpFloat:Double;
  tmpStr,tmpResult,s,s2:String;
  CmdCounter,n,t,Len:Integer;
  cmd,tmpCmd:PCmds;
  E:IValue;
  AField2,RelField1,RelField2:PeField;
  AEntryField:TEntryField;
  tmpDefVar: PDefVar;
  tmpFieldtype: TFelttyper;
  tmpNumDec,tmpFLength: Integer;
  RelDf: PDatafileInfo;
  DESFilename: TFilename;
  DesFile: TextFile;
  tmpCardinal: Cardinal;
  AControl: TControl;
  aHandle: THandle;
  c: TClipboard;

BEGIN  //ExecCommandList
  IF ExitExecutionBlock THEN Exit;
  IF CheckFileMode      THEN Exit;
  IF TestingDataForm    THEN Exit;
  IF CmdList=NIL        THEN Exit;
  IF CmdList.Count=0    THEN Exit;
  HandleVarsDf:=df;
  FOR CmdCounter:=0 TO CmdList.Count-1 DO
    BEGIN
      IF ExitExecutionBlock THEN Exit;
      Cmd:=PCmds(CmdList.Items[CmdCounter]);
      CASE Cmd^.Command OF
        cmdLET:
            BEGIN
              ChangeRecord:=False;
              TRY
                AField2:=NIL;
                E:= CreateExpression(Cmd^.LetExpr, MainForm.HandleVars);
                IF Assigned(E) THEN
                  BEGIN
                    //check if the result can be assigned to the field
                    ok:=true;
                    IF Cmd^.VarIsField THEN
                      BEGIN
                        AField2:=PeField(df^.FieldList.Items[Cmd^.VarNumber]);
                        tmpFieldtype:=AField2^.Felttype;
                        tmpNumDec:=AField2^.FNumDecimals;
                        tmpFLength:=AField2^.FLength;
                      END
                    ELSE
                      BEGIN
                        {Var is DEFINE-variable}
                        tmpDefVar:=GetDefField(cmd^.VarName,df);
                        tmpFieldType:=tmpDefVar^.Felttype;
                        tmpNumDec:=tmpDefVar^.FNumDecimals;
                        tmpFLength:=tmpDefVar^.FLength;
                      END;
                    s:=AnsiUpperCase(E.AsString);
                    IF ResultEqualsMissing THEN s:='';  //IF MissingAction=maRejectMissing THEN ResultEqualsMissing:=True;
                    IF (NumVariables>0) AND (NumVariables=NumMissingVariables) THEN s:='';   //result=missing if all variables are missing
                    IF (s='') OR (Cmd^.LetExpr='_M') THEN ok:=true
                    ELSE IF ((s='Y') OR (s='N')) AND (tmpFieldType=ftBoolean) THEN ok:=True
                    ELSE
                      CASE tmpFieldType OF
                        ftInteger,ftFloat:
                            IF NOT (E.CanReadAs(ttInteger) OR E.CanReadAs(ttFloat)) THEN ok:=False;
                        ftBoolean:
                            IF NOT E.CanReadAs(ttBoolean) THEN ok:=False;
                        ftAlfa,ftUpperAlfa,ftSoundex:
                            IF NOT E.CanReadAs(ttString) THEN ok:=False;
                        ftDate,ftEuroDate,ftYMDDate:    //&&
                            IF NOT E.CanReadAs(ttFloat) THEN ok:=False;
                      END;  //case
                    //Get the result
                    tmpResult:='';
                    IF (s='') OR (Cmd^.LetExpr='_M') THEN tmpResult:=''
                    ELSE
                    CASE tmpFieldType OF
                      ftDate,ftEuroDate,ftYMDDate:   //&&
                        tmpResult:=mibDateToStr(E.AsFloat,tmpFieldType);
                      ftBoolean:
                        BEGIN
                          IF E.CanReadAs(ttBoolean) THEN
                            BEGIN
                              IF E.AsBoolean=True THEN tmpResult:='Y' ELSE tmpResult:='N';
                            END
                          ELSE tmpResult:=E.AsString;
                        END;
                      ftFloat,ftInteger:
                        BEGIN
                          IF E.CanReadAs(ttInteger) THEN tmpFloat:=E.AsInteger
                          ELSE tmpFloat:=E.AsFloat;
                          //tmpFloat:=eStrToFloat(E.AsString);
                          Str(TmpFloat:tmpFLength:tmpNumDec,TmpStr);
                          tmpResult:=trim(tmpStr);
                        END;
                      ELSE tmpResult:=E.AsString;
                    END;  //case
                    //If field is key unique then check keys
                    IF (Cmd^.VarIsField) AND (Afield2^.FIndex>0) THEN
                      BEGIN
                        s:=Copy(tmpResult,1,30);
                        //IF (trim(s)='') AND (df^.IndexIsUnique[FIndex]) THEN
                        //  BEGIN
                        //    //field is KEY UNIQUE and empty
                        //    eDlg(Lang(21642),mtWarning,[mbOK],0);  //'Data must be entered in this field.'
                        //    CanExit:=False;
                        //  END
                        //ELSE
                        //  BEGIN
                        CASE AField2^.Felttype OF
                          ftInteger,ftFloat: s:=FormatNumberToIndex(s);  //    Format('%30s',[s]);
                          ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:  //&&
                            s:=Format('%30s',[FloatToStr(mibStrToDate(s,AField2^.Felttype))]);
                        ELSE
                          s:=Format('%-30s',[s]);
                        END;  //case
                        n:=SearchIndex(df,AField2^.FIndex,s);    //Tidligere: n:=df^.Index[FIndex].IndexOf(s);
                        IF (n<>-1)
                        AND (n<>df^.CurRecord)   //Tidligere:  (Integer(df^.Index[FIndex].Objects[n])<>df^.CurRecord)
                        AND (df^.IndexIsUnique[AField2^.FIndex]) THEN
                          BEGIN
                            s:=Format(Lang(21651),[trim(Afield2^.FName),n,n]);  //21651=Duplicate key in %s~Value already entered in record #%d~~Goto record #%d?
                            t:=eDlg(s,mtWarning,[mbYes,mbNo],0);
                            ChangeRecord:=True;
                            ok:=False;
                            didJump:=True;
                          END;  //if dublicate is entered in unique key
                        //END;  //if not key unique and empty
                      END;  //if field has index
                    IF ok THEN
                      BEGIN

                        IF Length(tmpResult)>tmpFLength THEN
                          BEGIN
                            IF ShowExprErrors
                            THEN ErrorMsg(Lang(21670)+#13+  //'Error in LET-expression:'
                            trim(Cmd^.VarName)+'='+Cmd^.LetExpr+#13#13+
                            Format(Lang(23502),[trim(cmd^.VarName)]));   //Result is too wide to fit %s
                          END
                        ELSE
                          BEGIN
                            IF Cmd^.VarIsField THEN
                              BEGIN
                                AField2^.FFieldText:=tmpResult;
                                ChangeGoingOn:=True;
                                TEntryField(AField2^.EntryField).Text:=AField2^.FFieldText;
                                IF AField2^.FIsTypeStatusBar THEN
                                  TypePanel.Caption:=df^.TypeStatusBarText+' '+AField2^.FFieldText;
                                ChangeGoingOn:=False;
                                IF NOT ((CmdList=df^.BeforeFileCmds) or (CmdList=df^.BeforeRecordCmds))
                                THEN df^.CurRecModified:=True;
                              END
                            ELSE tmpDefVar^.FFieldText:=tmpResult;
                          END;  //if result fits the resultfield
                      END  //if result is OK
                    ELSE
                      BEGIN
                        IF Cmd^.VarIsField THEN
                          BEGIN
                            AField2^.FFieldText:='';
                            ChangeGoingOn:=True;
                            TEntryField(AField2^.EntryField).Text:='';
                            IF AField2^.FIsTypeStatusBar THEN
                              TypePanel.Caption:=df^.TypeStatusBarText;
                            ChangeGoingOn:=False;
                            IF NOT ((CmdList=df^.BeforeFileCmds) or (CmdList=df^.BeforeRecordCmds))
                            THEN df^.CurRecModified:=True;
                          END
                        ELSE tmpDefVar^.FFieldText:='';
                        IF (t=mrYes) AND (ChangeRecord) THEN
                          BEGIN
                            ChangeRec(n,dirAbsolute);
                            DidJump:=True;
                            ExitExecutionBlock:=True;
                            Exit;
                          END;
                      END;
                  END;  //if assigned(E)
              EXCEPT
                On Er:EExpression do
                  IF ShowExprErrors THEN
                    BEGIN
                      ErrorMsg(Lang(21670)+#13+   //'Error in LET-expression:'
                      trim(Cmd^.VarName)+'='+Cmd^.LetExpr+#13#13+Er.Message);
                      IF Cmd^.VarIsField THEN
                        BEGIN
                          IF Assigned(AField2) THEN
                            BEGIN
                              AField2^.FFieldText:='';
                              ChangeGoingOn:=True;
                              TEntryField(AField2^.EntryField).Text:='';
                              IF AField2^.FIsTypeStatusBar THEN
                                TypePanel.Caption:=df^.TypeStatusBarText;
                              ChangeGoingOn:=False;
                            END;
                          IF NOT ((CmdList=df^.BeforeFileCmds) or (CmdList=df^.BeforeRecordCmds))
                          THEN df^.CurRecModified:=True;
                        END
                      ELSE tmpDefVar^.FFieldText:='';
                    END;
              END;  //try..except
            END;  //case cmdLET
        cmdIF:
            BEGIN
              TRY
                E:= CreateExpression(Cmd^.IfExpr, MainForm.HandleVars);
                IF Assigned(E) THEN
                  BEGIN
                    {Check om E kan læses som boolean
                    hvis E=True så udfør IfCmds
                    hvis E=False og ElseCmds<>NIL så udfør ElseCmds}
                    IF E.CanReadAs(ttBoolean) THEN
                      BEGIN
                        IF (E.AsBoolean=True) AND (cmd^.IfCmds<>NIL)
                        THEN ExecCommandList(cmd^.IfCmds)
                        ELSE IF (E.AsBoolean=False) AND (cmd^.ElseCmds<>NIL)
                        THEN ExecCommandList(cmd^.ElseCmds);
                      END;
                  END;  //if assigned(E)
              EXCEPT
                On Er:EExpression do
                  IF ShowExprErrors THEN ErrorMsg(Lang(21672)+#13+Er.Message);   //'Error in IF-expression:'
              END;  //try..except
            END;  //Case cmdIF
        cmdHelp:
            BEGIN
              tmpStr:=InsertFieldContents(df,Cmd^.HelpString);
              IF cmd^.HelpKeys='' THEN eDlgPos(tmpStr,Cmd^.HelpType,[mbOK],0,HelpBoxPos.x,HelpBoxPos.y)
              ELSE
                BEGIN
                  {Make a messagebox that closes when a legal key is pressed}
                  HelpBoxLegalKeys:=cmd^.HelpKeys;
                  with CreateMessageDialog(tmpStr, Cmd^.HelpType, []) do
                    try
                      onKeyPress:=HelpBoxKeyPress;
                      IF ShowModal=mrOK
                      THEN ResultVar:=Tag ELSE ResultVar:=0;
                    finally
                      Free;
                    end;
                END;

            END;  //case cmdHelp
        cmdComLegal:
            BEGIN
              AField2:=PeField(df^.FieldList.Items[Cmd^.clVarNumber]);
              AField2^.FCommentLegalRec:=Cmd^.CommentLegalRec;
              IF (Cmd^.ShowList) AND (Not CheckFileMode) THEN ShowLegalPickList(AField2^.FName);
            END;  //case cmdComLegal
        cmdExit:
            BEGIN
              ExitExecutionBlock:=True;
              Exit;
            END;
        cmdQuit:           //###
            BEGIN
              ExitExecutionBlock:=True;
              QuitEpiData:=True;
              MainForm.Close;
              Exit;
            END;
        cmdExecute:
            BEGIN
              s:=InsertFieldContents(df,cmd^.ExecCmdLine);
              s2:=InsertFieldContents(df,cmd^.ExecParams);
              IF NOT FileExec(s,s2,cmd^.ExecHide,cmd^.ExecWait,tmpCardinal) THEN
              ErrorMsg(Format(Lang(21694),[cmd^.ExecCmdLine]));  //21694=Error executing command:~%s

              //aHandle:=ExecuteFile(cmd^.ExecCmdLine,'','',SW_SHOW);
              //IF cmd^.ExecWait THEN
              //  BEGIN
              //    WaitForInputIdle(aHandle, INFINITE);
              //    WaitForSingleObject(aHandle, INFINITE);
              //    GetExitCodeProcess(aHandle,tmpCardinal);
              //  END;
              //ResultVar:=tmpCardinal;
            END;
        cmdTypeString:
            BEGIN
              IF Cmd^.TypeText<>'¤¤typecommentlegalallfields¤¤' THEN
                BEGIN
                  tmpStr:=InsertFieldContents(df,Cmd^.TypeText);
                  AField2:=PeField(df^.FieldList.Items[Cmd^.tsVarNumber]);
                  AField2^.FTypeField.Font.Color:=ColorValues[Cmd^.TypeColor];
                  AField2^.FTypeField.Caption:=tmpStr;
                END;
            END;
        cmdColor:
            BEGIN
              IF Cmd^.ColorCmd=3 THEN
                BEGIN
                  IF Cmd^.IsEpiInfoNo
                  THEN TDataForm(df^.DatForm).ScrollBox1.Color:=BgColors[Cmd^.BgColor]
                  ELSE TDataForm(df^.DatForm).ScrollBox1.Color:=ColorValues[Cmd^.BgColor];
                END;
              IF (Cmd^.ColorCmd=1) OR (Cmd^.ColorCmd=2) THEN
                BEGIN
                  FOR n:=0 TO TDataForm(df^.DatForm).ScrollBox1.ControlCount-1 DO
                    BEGIN
                      AControl:=TDataForm(df^.DatForm).ScrollBox1.controls[n];
                      IF Cmd^.ColorCmd=1 THEN
                        BEGIN
                          IF (AControl is TLabel) THEN
                            BEGIN
                              IF (AControl as TLabel).Tag<>99 THEN
                                BEGIN
                                  IF Cmd^.IsEpiInfoNo THEN
                                    BEGIN
                                      IF Cmd^.TxtColor<>255 THEN (AControl as TLabel).Font.Color:=TextColors[Cmd^.TxtColor];
                                      IF Cmd^.BgColor<>255 THEN (AControl as TLabel).Color:=BgColors[Cmd^.BgColor];
                                    END
                                  ELSE
                                    BEGIN
                                      IF Cmd^.TxtColor<>255 THEN (AControl as TLabel).Font.Color:=ColorValues[Cmd^.TxtColor];
                                      IF Cmd^.BgColor<>255 THEN (AControl as TLabel).Color:=ColorValues[Cmd^.BgColor];
                                    END;
                                END;  //if TLabel
                            END;
                        END;  //if command is 1
                    END;  //for
                END;  //if command is 1 or 2
            END;  //case cmdColor
        cmdRelate:
          BEGIN
            n:=cmd^.RelFileNo;
            RelDf:=PDataFileInfo(RelateFiles.Objects[n]);
            t:=GetFieldNumber(cmd^.RelField,df);
            IF t=-1 THEN
              BEGIN
                ErrorMsg(Format(Lang(21680),[trim(cmd^.RelField),df^.RECFilename]));  //'Relate error. The field %s does not exist in the datafile %s'
                Exit;
              END;
            RelField1:=PeField(df^.FieldList.Items[t]);
            t:=GetFieldNumber(cmd^.RelField,RelDf);
            IF t=-1 THEN
              BEGIN
                ErrorMsg(Format(Lang(21680),[trim(cmd^.RelField),RelDf^.RECFilename]));  //Relate error. The field %s does not exist in the datafile %s
                Exit;
              END;
            RelField2:=PeField(RelDf^.FieldList.Items[t]);

            IF trim(RelField1^.FFieldText)<>'' THEN
              BEGIN
                peWriteRecord(df,df^.CurRecord);
                IF df^.CurRecord=NewRecord THEN df^.CurRecord:=df^.NumRecords;
                SetToReadOnly;
                RelDf^.CanActivate:=True;
                WITH TDataForm(RelDf^.DatForm) DO
                  BEGIN
                    RelateOne2One:=cmd^.One2One;
                    RestoreReadOnly;
                    RelDf^.UseFilter:=True;
                    RelDf^.FilterText:=RelField1^.FFieldText;
                    RelDf^.FilterField:=t;
                    ChangeRec(1,dirFirst);
                    ChangeGoingOn:=True;
                    TEntryField(RelField2^.EntryField).Text:=RelField1^.FFieldText;
                    RelField2^.FFieldText:=RelField1^.FFieldText;
                    ChangeGoingOn:=False;
                    RelDf^.OldEnabledState:=TEntryField(RelField2^.EntryField).Enabled;
                    TEntryField(RelField2^.EntryField).Enabled:=False;
                    //ActiveRelateFile:=RelDf;
                    ActivateRelateFile(RelDf);
                    Show;
                    FocusFirstField;
                    IF Assigned(Reldf^.BeforeFileCmds) THEN ExecCommandList(Reldf^.BeforeFileCmds);
                    Reldf^.CurRecModified:=False;
                    IF Reldf^.TypeStatusBarField>-1 THEN
                      BEGIN
                        TypePanel.Font.Color:=ColorValues[Reldf^.TypeStatusBarColor];
                        TypePanel.Caption:=Reldf^.TypeStatusBarText+' '+
                        trim(PeField(Reldf^.FieldList.Items[Reldf^.TypeStatusBarField])^.FFieldText);
                      END
                    ELSE TypePanel.Caption:='';
                  END;  //with
                //ActiveRelateFile:=RelDf;
                ActivateRelateFile(RelDf);
                df^.RelateCalled:=True;
                Reldf^.MotherRecNum:=df^.CurRecord;
                RelDf^.IsInRelate:=True;
                RelDf^.RelateField:=RelField2;
                //ShowLastCmds('Executes cmdRelate of '+Extractfilename(df^.RECFilename)+#13+'Before LastCmds.Create',df);
                IF CmdList<>df^.LastCommands THEN
                  BEGIN
                    df^.LastCommands:=TList.Create;
                    IF CmdCounter<CmdList.Count-1 THEN
                      FOR t:=CmdCounter+1 TO CmdList.Count-1 DO
                        df^.LastCommands.Add(CmdList.Items[t]);
                  END
                ELSE
                  BEGIN
                    df^.tmpLastCmds:=TList.Create;
                    IF CmdCounter<CmdList.Count-1 THEN
                      BEGIN
                        FOR t:=CmdCounter+1 TO CmdList.Count-1 DO
                          BEGIN
                            IF PCmds(CmdList.Items[t])^.Command=cmdLeaveField THEN
                              BEGIN
                                New(tmpCmd);
                                tmpCmd^.Command:=cmdLeaveField;
                                tmpCmd^.cLeaveStyle:=PCmds(CmdList.Items[t])^.cLeaveStyle;
                                tmpCmd^.IsLastField:=PCmds(CmdList.Items[t])^.IsLastField;
                                df^.tmpLastCmds.Add(tmpCmd);
                              END
                            ELSE df^.tmpLastCmds.Add(CmdList.Items[t]);
                          END;  //for
                      END;  //if
                  END;  //else
                //ShowLastCmds('Executes cmdRelate of '+Extractfilename(df^.RECFilename)+#13+'After LastCmds.Create',df);
                ExitExecutionBlock:=True;
                Exit;
              END
            ELSE
              BEGIN
                s:=format(Lang(21696),[ExtractFilename(RelDf^.RECFilename),trim(RelField1^.FName)]);
                ErrorMsg(s);   //21696=Cannot perform relate to: %s~Relatefield %s is empty
                DidJump:=True;
              END;
          END;  //case cmdRelate
        cmdLeaveField:
          BEGIN
            IF NOT DidJump THEN
              df^.LeaveStyle:=cmd^.cLeaveStyle;
            CASE cmd^.cLeaveStyle OF
              lsEnter:     PostMessage(Self.Handle,WM_NextDlgCtl,0,0);   //Next field
              lsBrowse:    PostMessage(Self.Handle,WM_NextDlgCtl,1,0);   //Previous field
              lsJumpFirst: FocusFirstField;
              lsJumpLast:  FocusLastField;
            END;  //case
          END;  //case cmdLeaveField
        cmdWriteNote:
          BEGIN
            DESFilename:=ChangeFileExt(df^.RECFilename,'.not');
            IF NOT FileExists(DESFilename) THEN
              BEGIN
                TRY
                  AssignFile(DesFile,DESFilename);
                  ReWrite(DesFile);
                  WriteLN(DesFile,Format(Lang(22000),[df^.RECFilename]));   //Dataentry notes for %s
                  WriteLN(DesFile,cFill('-',80));
                  WriteLN(DesFile);
                  CloseFile(DesFile);
                EXCEPT
                  ErrorMsg(Format(Lang(22002),[DESFilename])+#13#13+Lang(20206));  //'A dataentry notes file by the name %s cannot be created.  / Check if the file is in use and that the filename is legal.'
                  Exit;
                  //LabelEditForm.Free;  ???
                END;  //try..Except
              END;  //if not fileExists
            AssignFile(DesFile,DESFilename);
            Append(DesFile);
            WriteLN(DesFile);
            s:=FormatDateTime('dd mmm yyyy hh":"nn',now);
            IF df^.CurRecord=NewRecord THEN s:=s+' '+Lang(21682) ELSE s:=s+' '+Lang(21684)+' '+IntToStr(df^.CurRecord);  //21682=Record: New  21684=Record:

            IF df^.TypeStatusBarField>-1 THEN
              BEGIN
                IF trim(df^.TypeStatusBarText)='' THEN s:=s+' ('+trim(PeField(df^.FieldList.Items[df^.TypeStatusBarField])^.FName)+' ='
                ELSE s:=s+' ('+df^.TypeStatusBarText+' ';
                s:=s+trim(PeField(df^.FieldList.Items[df^.TypeStatusBarField])^.FFieldText)+')';
              END;
            //s:=s+'  Field: '+trim(AField^.FName)+' = ';
            //IF trim(AField^.FFieldText)='' THEN s:=s+'.' ELSE s:=s+trim(AField^.FFieldText);


            //s:=FormatDateTime('dd mmm yyyy hh":"nn',now);
            IF df^.LatestActiveControl<>NIL THEN
              BEGIN
                AEntryField:=TEntryField(df^.LatestActiveControl);
                AField2:=PeField(AEntryField.dfField);
                //IF df^.CurRecord=NewRecord THEN s:=s+' '+Lang(21682) ELSE s:=s+' '+Lang(21684)+' '+IntToStr(df^.CurRecord);  //21682=Record: New  21684=Record:
                s:=s+'  Field: '+AField2^.FName;  //***
              END;
            WriteLN(DesFile,s);
            WriteLN(DesFile,InsertFieldContents(df,cmd^.FNote));
            CloseFile(DesFile);

            IF cmd^.ShowNotes THEN
              BEGIN
                LabelEditForm:=TLabelEditForm.Create(MainForm);
                IF DataentryNotesPos.Top<>-1 THEN LabelEditForm.BoundsRect:=DataEntryNotesPos;
                LabelEditForm.Caption:=Format(Lang(22000),[df^.RECFilename]);   //'Dataentry notes for %s'
                WITH LabelEditForm DO
                  BEGIN
                    UseAsEditor:=True;
                    TRY
                      Memo1.Lines.LoadFromFile(DESFilename);
                    EXCEPT
                      ErrorMsg(Format(Lang(22004),[DESFilename])+#13#13+  //'The dataentry notes %s cannot be opened.'
                      Lang(20208));   //'Please check if the file is in use and that the filename is legal.')
                      LabelEditForm.Free;
                      Exit;
                    END;  //try.Except
                    Memo1.Modified:=False;
                    Memo1.SelStart:=Length(Memo1.Lines.Text);
                    Memo1.SelLength:=0;
                    PostMessage(Memo1.Handle,EM_SCROLLCARET,0,0);
                    n:=ShowModal;
                    IF (Memo1.Modified) AND (n=mrOK) THEN Memo1.Lines.SaveToFile(DESFilename);
                    DataEntryNotesPos:=LabelEditForm.BoundsRect;
                  END;  //with
                LabelEditForm.Free;
              END;  //if ShowNotes
          END;  //case cmdWriteNote;
        cmdCopyToClipboard:   //¤¤
            BEGIN
              TRY
                c:=clipboard;
                c.Open;
                c.Clear;
                c.AsText:=InsertFieldContents(df,cmd^.CopyStr);
              FINALLY
                c.Close;
              END;
            END;  //case cmdCopyToClipboard
        cmdBeep:
            BEGIN
              CASE Cmd^.BeepType OF
                btWarning: MessageBeep(MB_ICONEXCLAMATION);
                btConfirmation: MessageBeep(MB_ICONQUESTION);
              ELSE
                MessageBeep(MB_OK);
              END;  //case
            END;  //case cmdBeep
        cmdBackUp:
            BEGIN
              IF df^.DatFile<>NIL THEN ErrorMsg(Lang(21518))  //21518=Cannot perform backup.~Place BACKUP command in AFTER FILE block
              ELSE
                BEGIN
                  IF df^.dfModified THEN
                    BEGIN
                      {$IFNDEF epidat}
                      IF (NOT df^.IsRelateFile) AND (df^.BackupList<>NIL) AND (df^.OKToBackup) THEN
                        BEGIN
                          IF (Cmd^.zipit=False) AND (Cmd^.encryptit=False) THEN BackupCommand(df^.BackupList)
                          ELSE
                            BEGIN
                              s:=Cmd^.DestLib;
                              IF s[Length(s)]<>'\' THEN s:=s+'\';
                              s:=s+Cmd^.filename;  //s now contains destination file including filepath
                              s2:=ExtractFilepath(df^.RECFilename);
                              PerformZip(s2,s,Cmd^.encryptit,Cmd^.dateit,Cmd^.pw);
                            END;
                        END;
                      {$ENDIF}
                    END;  //if dfModified
                END  //if datfile=NIL
            END;  //case cmdBackup
        cmdHide,cmdUnhide,cmdClear,cmdGoto:
            BEGIN
              IF Cmd^.HideVarNumber>=0 THEN
                BEGIN
                  AField2:=PeField(df^.FieldList.Items[Cmd^.HideVarNumber]);
                  AEntryField:=TEntryField(AField2^.EntryField);
                END;
              CASE Cmd^.Command OF
                cmdHide:
                  BEGIN
                    AEntryField.Color:=DataFormColor;
                    AEntryField.Enabled:=False;
                  END;
                cmdUnhide:
                  BEGIN
                    IF df^.FieldBg<>COLOR_ENDCOLORS THEN AEntryField.Color:=df^.FieldBg ELSE AEntryField.Color:=FieldColor;
                    //AEntryField.Color:=FieldColor;
                    AEntryField.Enabled:=True;
                  END;
                cmdClear:
                  BEGIN
                    IF cmd^.HideVarName='$$COMLEG' THEN
                      BEGIN
                        AField2.FCommentLegalRec:=NIL;
                      END
                    ELSE
                      BEGIN
                        AField2.FFieldText:='';
                        AEntryField.Text:='';
                        IF (AField2^.FTypeComments) OR (AField2^.FTypeString)
                        OR ((df^.GlobalTypeCom) AND (AField2^.FCommentLegalRec<>NIL)) THEN AField2^.FTypeField.Caption:='';
                      END;
                  END;
                cmdGoto:
                  BEGIN
                    IF NOT IgnoreJumps THEN
                      BEGIN
                        IF (Cmd^.HideVarNumber>=0) AND (NOT DidJump) THEN
                          BEGIN
                            DidJump:=True;
                            AEntryField.SetFocus;
                            DidJump:=True;
                          END
                        ELSE
                          CASE Cmd^.HideVarNumber OF
                            -1: BEGIN  //goto write
                                  df^.LeaveStyle:=lsChangeRec;
                                  onExitEvent(df^.LatestActiveControl);
                                  IF df^.CanExit THEN
                                    BEGIN
                                      IF SaveRecord THEN
                                        BEGIN
                                          ChangeRec(df^.CurRecord+1,dirForward);
{                                          IF (df^.CurRecord=df^.NumRecords) OR (df^.CurRecord=NewRecord) THEN
                                            BEGIN
                                              peNewRecord(df);
                                              FocusFirstField;
                                            END
                                          ELSE peReadRecord(df,df^.CurRecord+1);}
                                          DidJump:=True;
                                        END;  //if Save record
                                    END;  //if CanExit
                                END;
                            -2: BEGIN  //goto end
                                  FocusLastField;
                                  DidJump:=True;
                                END;
                          END;  //case
                      END;
                  END;
              END;  //case
            END;  //case cmdHide,cmdUnhide
      END;  //Case command
    END;  //for CmdCounter
END;  //procedure ExecCommandList

procedure TDataForm.EditChecks1Click(Sender: TObject);
begin
  TpCheckForm(df^.ChkForm).EditChecksBtnClick(Sender);
end;

procedure TDataForm.ShowIndexfile1Click(Sender: TObject);
VAR
  udlin: TStringList;
  s: str30;
  n,n2,CurIndexNo: Integer;
  ifile: TIndexFile;
begin
  IF df^.Indexcount>0 THEN
    BEGIN
      udlin:=TStringList.Create;
      udLin.Append('Index of '+df^.RECFilename);
      UdLin.Append('');
      Udlin.Append('Index in memory:');
      FOR CurIndexNo:=1 TO df^.Indexcount DO
        BEGIN
          Udlin.Append('Index felt nr. '+IntToStr(CurIndexNo));
          Udlin.Append('=================');
          FOR n:=1 TO df^.NumRecords DO
            BEGIN
              s:=ReadFromIndex(df,CurIndexNo,n);
              Udlin.Append(Format('Rec. %3d  Index="%s"',[n,s]));
            END;
          Udlin.Append('');
        END;
      UdLin.Append('Index in file:');
      Assignfile(ifile,df^.IndexFilename);
      reset(ifile);
      n:=-1;
      WHILE NOT EOF(ifile) DO
        BEGIN
          INC(n);
          Read(ifile,s);
          UdLin.Append(Format('Post %3d: "%s"',[n,s]));
        END;  //while
      Udlin.SaveToFile(df^.IndexFilename+'.txt');
      Udlin.Free;
      eDlg('Index file created',mtInformation,[mbOK],0);
    END;
end;

Function TDataForm.SaveRecord:Boolean;
VAR
  n:Integer;
  tmpS: String;
  filledfound:boolean;
BEGIN
  IF df^.IsReadOnly THEN Exit;
  IF (df^.IsRelateFile) AND (RelateOne2One) THEN
    BEGIN
      Close;
      Exit;
    END;
  //check if all fields are empty
  n:=0;
  filledfound:=false;
  repeat
    WITH PeField(df^.FieldList.Items[n])^ DO
      begin
        if (not (felttype in [ftQuestion,ftToday,ftEuroToday,ftYMDToday])) then
          if trim(FFieldtext)<>'' then filledfound:=true;
      end;  //with
    inc(n);
  until (n=df^.FieldList.Count) or (filledfound=true);

  if filledfound then
    begin
      IF (df^.IsrelateFile) OR (df^.IsRelateTop)
      THEN tmpS:=ExtractFilename(df^.RECFilename)+#13#13+Lang(21666)
      ELSE tmpS:=Lang(21666);   //'Save record to disk?'
      IF df^.AutoSave THEN n:=mrYes
      ELSE n:=SaveDlg(tmpS,[mbYes,mbNo]);
    end
  else n:=mrNo;
  IF n=mrYes THEN
    BEGIN
      IF (df^.DoubleEntry) and (not df^.CurRecDeleted) THEN
        BEGIN
          IF (NOT CheckDoubleEntry(nil)) THEN
            BEGIN
              Result:=False;
              DidJump:=False;
              Exit;
            END;
        END;    //if doubleentry
      //After Record!
      ExitExecutionBlock:=False;
      IF Assigned(df^.AfterRecordCmds) THEN ExecCommandList(df^.AfterRecordCmds);
      IF NOT DidJump THEN
        BEGIN
          peWriteRecord(df,df^.CurRecord);
          Result:=True;
          IF (df^.IsRelateFile) AND (RelateOne2One) THEN Close;
        END
      ELSE Result:=False;
    END
  ELSE
    BEGIN
      Result:=False;
      DidJump:=False;
      IF (df^.IsRelateFile) AND (RelateOne2One) THEN Close;
    END;
END;  //procedure SaveRecord

procedure TDataForm.Dataentrynotes1Click(Sender: TObject);
VAR
  DESFilename:TFilename;
  F:TextFile;
  n:Integer;
  AEntryField: TEntryField;
  AField: PeField;
  s: String;
begin
  {Open file with dataentry notes}
  IF CheckFileMode THEN Exit;
  LabelEditForm:=TLabelEditForm.Create(MainForm);
  IF DataentryNotesPos.Top<>-1 THEN LabelEditForm.BoundsRect:=DataEntryNotesPos;
  LabelEditForm.UseAsEditor:=True;
  LabelEditForm.Caption:=Format(Lang(22000),[df^.RECFilename]);   //'Dataentry notes for %s'
  DESFilename:=ChangeFileExt(df^.RECFilename,'.not');
  IF NOT FileExists(DESFilename) THEN
    BEGIN
      TRY
        AssignFile(F,DESFilename);
        ReWrite(F);
        WriteLN(F,Format(Lang(22000),[df^.RECFilename]));   //Dataentry notes for %s
        WriteLN(F,cFill('-',80));
        WriteLN(F);
        CloseFile(F);
      EXCEPT
        ErrorMsg(Format(Lang(22002),[DESFilename])+#13#13+Lang(20206));  //'A dataentry notes file by the name %s cannot be created.  / Check if the file is in use and that the filename is legal.'
        Exit;
        LabelEditForm.Free;
      END;  //try..Except
    END;  //if not fileExists
  TRY
    LabelEditForm.Memo1.Lines.LoadFromFile(DESFilename);
  EXCEPT
    ErrorMsg(Format(Lang(22004),[DESFilename])+#13#13+  //'The dataentry notes %s cannot be opened.'
    Lang(20208));   //'Please check if the file is in use and that the filename is legal.')
    LabelEditForm.Free;
    Exit;
  END;  //try.Except
  s:='';
  IF df^.LatestActiveControl<>NIL THEN
    BEGIN
      AEntryField:=TEntryField(df^.LatestActiveControl);
      AField:=PeField(AEntryField.dfField);
      IF df^.CurRecord=NewRecord THEN s:=s+' '+Lang(21682)+' ('+IntToStr(df^.NumRecords+1)+')'
      ELSE s:=s+' '+Lang(21684)+' '+IntToStr(df^.CurRecord);  //21682=Record: New  21684=Record:
      IF df^.TypeStatusBarField>-1 THEN
        BEGIN
          IF trim(df^.TypeStatusBarText)='' THEN s:=s+' ('+trim(PeField(df^.FieldList.Items[df^.TypeStatusBarField])^.FName)+' ='
          ELSE s:=s+' ('+df^.TypeStatusBarText+' ';
          s:=s+trim(PeField(df^.FieldList.Items[df^.TypeStatusBarField])^.FFieldText)+')';
        END;
      s:=s+'  Field: '+trim(AField^.FName)+' = ';
      IF trim(AField^.FFieldText)='' THEN s:=s+'.' ELSE s:=s+trim(AField^.FFieldText);
    END;

  WITH LabelEditForm.Memo1 DO
    BEGIN
      IF trim(Lines[Lines.Count-1])<>'' THEN Lines.Append('');
      Lines.Append('');
      Lines.Append(FormatDateTime('dd mmm yyyy hh":"nn',now)+s);
      Modified:=False;
      SelStart:=Length(LabelEditForm.Memo1.Lines.Text);
    END;  //with
  PostMessage(LabelEditForm.Memo1.Handle,EM_SCROLLCARET,0,0);
  n:=LabelEditForm.ShowModal;
  DataEntryNotesPos:=LabelEditForm.BoundsRect;
  IF (LabelEditForm.Memo1.Modified) AND (n=mrOK)
  THEN LabelEditForm.Memo1.Lines.SaveToFile(DESFilename);
  LabelEditForm.Free;
end;

procedure TDataForm.File1Click(Sender: TObject);
begin
  IF CheckFileMode THEN Dataentrynotes1.Enabled:=False;
end;

procedure TDataForm.SetToReadOnly;
VAR
  n:Integer;
  AField: PeField;
BEGIN
  df^.IsReadOnly:=True;
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[n]);
      IF AField^.FeltType<>ftQuestion THEN
        BEGIN
          AField^.OldReadOnly:=TEntryField(AField^.EntryField).ReadOnly;
          TEntryField(AField^.EntryField).ReadOnly:=True;
        END;
    END;
END;

Procedure TDataForm.RestoreReadOnly;
VAR
  n:Integer;
  AField: PeField;
BEGIN
  IF (df^.HasCrypt) AND (df^.Key='') THEN Exit;   //&&
  df^.IsReadOnly:=False;
  FOR n:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[n]);
      IF AField^.FeltType<>ftQuestion
      THEN TEntryField(AField^.EntryField).ReadOnly:=AField^.OldReadOnly;
    END;
END;


Procedure TDataForm.ChangeRec(RecNo:LongInt; direction:TDirections);
VAR
 AField: PeField;
 n:Integer;
BEGIN
  IF NOT df^.UseFilter THEN
    BEGIN
      CASE direction OF
        dirForward:
          BEGIN
            IF (df^.CurRecord=df^.NumRecords) OR (df^.CurRecord=NewRecord) THEN
              BEGIN
                peNewRecord(df);
                FocusFirstField;
              END
            ELSE peReadRecord(df,RecNo);
          END;
        dirBackWard:
          BEGIN
            IF df^.CurRecord=NewRecord THEN peReadRecord(df,df^.NumRecords)
            ELSE IF df^.CurRecord>1 THEN peReadRecord(df,RecNo);
          END;
        dirFirst:    peReadRecord(df,1);
        dirLast:     peReadRecord(df,df^.NumRecords);
        dirAbsolute: peReadRecord(df,RecNo);
      END;  //case
    END  //if NOT UseFilter
  ELSE
    BEGIN  //UseFilter
      AField:=PeField(df^.FieldList.Items[df^.FilterField]);
      IF AField^.FIndex=0 THEN Exit;
      IF (direction=dirForward) AND ( (df^.CurRecord=df^.NumRecords) OR (df^.CurRecord=NewRecord) ) THEN
        BEGIN
          peNewRecord(df);
          FocusFirstField;
          Exit;
        END;
      IF (direction=dirBackward) AND (df^.CurRecord=NewRecord) THEN RecNo:=df^.NumRecords;
      n:=SearchIndexFrom(df,AField^.FIndex,df^.FilterText,RecNo,direction);
      IF n<>-1 THEN peReadRecord(df,n)
      ELSE IF (direction=dirForward) OR (direction=dirFirst) THEN
        BEGIN
          peNewRecord(df);
          FocusFirstField;
        END
      ELSE ErrorMsg(Lang(23142));   //23142=Record not found
    END;   //if UseFilter

END;



procedure TDataForm.Setfilter1Click(Sender: TObject);
VAR
  s:String;
  fn:Integer;
  AField: PeField;
begin
  {Find fieldnumber of the current entryfield}
  fN:=df^.FieldList.IndexOf(TEntryField(df^.LatestActiveControl).dfField);
  IF fN=-1 THEN Exit;

  AField:=PeField(df^.FieldList.Items[fN]);
  IF AField^.FIndex=0 THEN
    BEGIN
      ErrorMsg(Lang(21686));  //'Filter can only be applied when KEY-fields are selected.'
      Exit;
    END;

  IF df^.CurRecModified THEN
    BEGIN
      df^.LeaveStyle:=lsChangeRec;
      onExitEvent(df^.LatestActiveControl);
      IF NOT df^.CanExit THEN Exit;
    END;

  IF df^.NumRecords>0 THEN
    BEGIN
      IF df^.CurRecModified THEN SaveRecord;
      IF NOT DidJump THEN
        BEGIN
          s:=df^.FilterText;
          IF InputQuery(Lang(21688),Lang(21690),s) THEN   //21688='Activate filter',21690='Enter filter string'
            BEGIN
              df^.UseFilter:=True;
              df^.FilterText:=s;
              df^.FilterField:=fn;
              MainForm.StatPanel6.Caption:=' Filter: '+
              trim(PeField(df^.FieldList.Items[df^.FilterField])^.FName)+'="'+df^.Filtertext+'"';
              ChangeRec(df^.CurRecord,dirForward);
            END;
        END;  //if not didJump
    END;
end;



procedure TDataForm.Deactivatefilter1Click(Sender: TObject);
begin
  df^.UseFilter:=False;
  MainForm.StatPanel6.Caption:='';
end;

procedure TDataForm.Filter1Click(Sender: TObject);
begin
  DeactivateFilter1.Enabled:=df^.UseFilter AND NOT df^.IsInRelate;
  SetFilter1.Enabled:=NOT df^.IsInRelate;
end;


procedure TDataForm.HelpBoxKeyPress(Sender: TObject; var Key: Char);
BEGIN
  IF Pos(UpCase(Key),HelpBoxLegalKeys)>0 THEN
    BEGIN
      TForm(Sender).Tag:=Pos(UpCase(Key),HelpBoxLegalKeys);
      TForm(Sender).ModalResult:=mrOK;
    END
  ELSE IF Key=#27 THEN TForm(Sender).ModalResult:=mrCancel;
END;



procedure TDataForm.Printdataform1Click(Sender: TObject);
VAR
  xscale,yscale: Double;
  ppix,ppiy,ppmmx,ppmmy,LeftMarg,TopMarg,BotMarg,pClientHeight: Integer;
  aQTop,aQBot,aFTop,aFBot,aLeft: Integer;
  Curfield: Integer;
  ChangePage: Boolean;
  ARect: TRect;
begin
  IF NOT PrintDialog1.Execute THEN Exit;
  WITH Printer DO
    BEGIN
      Title:='EpiData - '+ExtractFilename(df^.RECFilename);
      ppix:=GetDeviceCaps(Handle,LOGPIXELSX);  //pixels pr inch X
      ppiy:=GetDeviceCaps(Handle,LOGPIXELSY);  //pixels pr inch Y
      ppmmx:=Round(ppix/25.4);                 //pixels pr mm X
      ppmmy:=Round(ppiy/25.4);                 //pixels pr mm Y
      LeftMarg:=ppmmx*10;                      //Sets left margin to 2 cm
      TopMarg:=ppmmy*15;                       //Sets top margin to 1,5 cm
      BotMarg:=PageHeight-ppmmy*15;            //Sets bottom margin to 2 cm
      pClientHeight:=BotMarg-TopMarg;
      printer.canvas.Font.PixelsPerInch:=ppix;
      Printer.Canvas.Font.Name:=epiDataFormFont.Name;
      Printer.Canvas.Font.Size:=EpiDataFormFont.Size;
      Printer.Canvas.Font.Style:=EpiDataFormFont.Style;
      printer.canvas.Font.PixelsPerInch:=ppix;
      xscale:=ppix/Self.PixelsPerInch;
      yscale:=ppiy/Self.PixelsPerInch;
      ChangePage:=False;
      BeginDoc;
      FOR CurField:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          WITH PeField(df^.FieldList.Items[Curfield])^ DO
            BEGIN
              {Check if fields fits in the page}
              IF trim(FQuestion)<>'' THEN
                BEGIN
                  {Check if question fits the page}
                  aQTop:=Round((FQuestTop-2)*yscale)-((PageNumber-1)*pClientHeight);
                  aQTop:=aQTop+TopMarg;
                  aQBot:=aQTop+Canvas.TextHeight(FQuestion);
                  IF aQBot>BotMarg THEN ChangePage:=True;
                END;
              IF FLength>0 THEN
                BEGIN
                  {Check if field fits the page}
                  aFTop:=Round(FFieldTop*yscale)-((PageNumber-1)*pClientHeight)+TopMarg;
                  aFBot:=aFTop+Round(2*yscale)+Canvas.TextHeight(FFieldText);
                  IF aFBot>BotMarg THEN ChangePage:=True;
                END;
              IF ChangePage THEN
                BEGIN
                  NewPage;
                  ChangePage:=False;
                END;
              {Print the question and the field}
              IF trim(FQuestion)<>'' THEN
                BEGIN
                  aQTop:=Round((FQuestTop-2)*yscale)-((PageNumber-1)*pClientHeight)+TopMarg;
                  aLeft:=Round(FQuestLeft*xscale)+LeftMarg;
                  Canvas.TextOut(aLeft,aQTop,FQuestion);
                END;
              IF FLength>0 THEN
                BEGIN
{                  ARect.Top:=(FFieldTop-2-((PageNumber-1)*pClientHeight))*yscale;
                  ARect.Top:=ARect.Top+TopMarg;
                  ARect.Bottom:=aFTop+Canvas.TextHeight(FFieldText+'X')+(3*yscale);
                  ARect.Left:=((FFieldLeft-2)*xscale)+LeftMarg;
                  ARect.Right:=ARect.Left+(xscale*(FFieldWidth+2));
}
                  IF trim(FFieldText)<>'' THEN
                    BEGIN
                      ARect.Top:=Round(FFieldTop*yscale)-((PageNumber-1)*pClientHeight)+TopMarg;
                      //ARect.Bottom:=ARect.Top+Printer.Canvas.TextHeight(FFieldText+'X');
                      ARect.Left:=Round(FFieldLeft*xscale)+LeftMarg;
                      //ARect.Right:=ARect.Left+Round((xscale*FFieldWidth));
                      Canvas.TextOut(ARect.Left,ARect.Top,FFieldText);
                    END;

                  ARect.Top:=Round(FFieldTop*yscale)-((PageNumber-1)*pClientHeight)+topMarg;
                  ARect.Bottom:=ARect.Top+Printer.Canvas.TextHeight(FFieldText+'Xp_');
                  ARect.Left:=Round(FFieldLeft*xscale)+LeftMarg;
                  ARect.Right:=ARect.Left+Round(xscale*FFieldWidth)-4;
                  ARect.Top:=ARect.Top+((ARect.Bottom-ARect.Top) DIV 2);
                  Canvas.MoveTo(ARect.Left,ARect.top);
                  Canvas.LineTo(ARect.Left,ARect.Bottom);
                  Canvas.LineTo(ARect.Right,ARect.Bottom);
                  Canvas.LineTo(ARect.Right,ARect.top);

                END;
            END;  //with PeField
        END;  //for
      EndDoc;
    END;  //with printer
end;

procedure TDataForm.FormShow(Sender: TObject);
VAR n:Byte;
begin
  IF df=NIL THEN Exit;
  IF df^.HasRelate THEN Findrelatefield1.Enabled:=True;
end;

procedure TDataForm.Saverelatelist1Click(Sender: TObject);
VAR
  Mumdf,df: PDatafileInfo;
  n:Integer;
  L: TStringList;
begin
  TRY
    L:=TStringList.Create;
    Mumdf:=PDatafileInfo(RelateMothers.Items[0]);
    L.Append('Relate filer hvor '+Mumdf^.RECFilename+' er top:');
    L.Append('');
    L.Append('Mothers:');
    FOR n:=0 TO RelateMothers.Count-1 DO
      BEGIN
        MumDf:=PDatafileInfo(RelateMothers.Items[n]);
        df:=PDatafileInfo(RelateFiles.Objects[n]);
        L.Append(Format('%3d %-s er mor til %-s',[n,MumDf^.RecFilename,df^.RECFilename]));
      END;
    L.append(' ');
    L.append('Relatefiles:');
    FOR n:=0 TO RelateFiles.Count-1 DO
      BEGIN
        df:=PDatafileInfo(RelateFiles.Objects[n]);
        MumDf:=PDatafileInfo(RelateMothers.Items[n]);
        L.Append(Format('%3d %-s har denne mor: %-s',[n,df^.RECFilename,MumDf^.RECFilename]));
      END;
    L.SaveToFile('c:\pas\epidata\Relates.txt');
  FINALLY
    L.Free;
  END;
end;

function TDataForm.ChangeRelateLevel(FromDf,ToDf: PDatafileInfo; RelFieldName: string;
         One2One: Boolean;  EmptyWarning:Boolean):Integer;
VAR
  n,t: Integer;
  FromRelField, ToRelField: PeField;
BEGIN
  Result:=2;  //unspecified error
  IF NOT assigned(FromDf) THEN Exit;
  IF ToDf=NIL THEN Exit;
  IF RelFieldName='' THEN Exit;
  t:=GetFieldNumber(RelFieldName,FromDf);
  IF t=-1 THEN
    BEGIN
      Result:=3;  //Relatefield does not exist in FromDf
      Exit;
    END;
  FromRelField:=PeField(FromDf^.FieldList.Items[t]);
  t:=GetFieldNumber(RelFieldName,ToDf);
  IF t=-1 THEN
    BEGIN
      Result:=4;  //Relatefield does not exist in ToDf
      Exit;
    END;
  ToRelField:=PeField(ToDf^.FieldList.Items[t]);

  IF trim(FromRelField^.FFieldText)<>'' THEN
    BEGIN
      peWriteRecord(FromDf,FromDf^.CurRecord);
      IF FromDf^.CurRecord=NewRecord THEN FromDf^.CurRecord:=FromDf^.NumRecords;
      TDataForm(FromDf^.DatForm).SetToReadOnly;
      ToDf^.CanActivate:=True;
      WITH TDataForm(ToDf^.DatForm) DO
        BEGIN
          RelateOne2One:=One2One;
          RestoreReadOnly;
          ToDf^.UseFilter:=True;
          ToDf^.FilterText:=FromRelField^.FFieldText;
          ToDf^.FilterField:=t;
          ChangeRec(1,dirFirst);
          ChangeGoingOn:=True;
          TEntryField(ToRelField^.EntryField).Text:=FromRelField^.FFieldText;
          ToRelField^.FFieldText:=FromRelField^.FFieldText;
          ChangeGoingOn:=False;
          ToDf^.OldEnabledState:=TEntryField(ToRelField^.EntryField).Enabled;
          TEntryField(ToRelField^.EntryField).Enabled:=False;
          //ActiveRelateFile:=ToDf;
          ActivateRelateFile(ToDf);
          Show;
          FocusFirstField;
          IF Assigned(ToDf^.BeforeFileCmds) THEN ExecCommandList(ToDf^.BeforeFileCmds);
          ToDf^.CurRecModified:=False;
        END;  //with
      FromDf^.RelateCalled:=True;
      ToDf^.MotherRecNum:=df^.CurRecord;
      ToDf^.IsInRelate:=True;
      ToDf^.RelateField:=ToRelField;
      //ShowLastCmds('Executes cmdRelate of '+Extractfilename(df^.RECFilename)+#13+'Before LastCmds.Create',df);
      {IF CmdList<>df^.LastCommands THEN
        BEGIN
          df^.LastCommands:=TList.Create;
          IF CmdCounter<CmdList.Count-1 THEN
            FOR t:=CmdCounter+1 TO CmdList.Count-1 DO
              df^.LastCommands.Add(CmdList.Items[t]);
        END
      ELSE
        BEGIN
          df^.tmpLastCmds:=TList.Create;
          IF CmdCounter<CmdList.Count-1 THEN
            BEGIN
              FOR t:=CmdCounter+1 TO CmdList.Count-1 DO
                BEGIN
                  IF PCmds(CmdList.Items[t])^.Command=cmdLeaveField THEN
                    BEGIN
                      New(tmpCmd);
                      tmpCmd^.Command:=cmdLeaveField;
                      tmpCmd^.cLeaveStyle:=PCmds(CmdList.Items[t])^.cLeaveStyle;
                      tmpCmd^.IsLastField:=PCmds(CmdList.Items[t])^.IsLastField;
                      df^.tmpLastCmds.Add(tmpCmd);
                    END
                  ELSE df^.tmpLastCmds.Add(CmdList.Items[t]);
                END;  //for
            END;  //if
        END;  //else}
      //ShowLastCmds('Executes cmdRelate of '+Extractfilename(df^.RECFilename)+#13+'After LastCmds.Create',df);
      //ExitExecutionBlock:=True;
      Exit;
    END
  ELSE
    BEGIN
      IF EmptyWarning THEN
        BEGIN
          ErrorMsg(Format(Lang(21696),[ExtractFilename(ToDf^.RECFilename),trim(RelFieldName)]));   //21696=Cannot perform relate to: %s~Relatefield %s is empty
          DidJump:=True;
        END
      ELSE TForm(ToDf^.DatForm).Show;
      Result:=0;  //No error
    END;
END;  //ChangeRelateLevel

procedure TDataForm.Findrelatefield1Click(Sender: TObject);
VAR
  n,w:Integer;
  RelList: TStringList;
  RelDf:PDatafileInfo;
  AInfo: PRelateInfo;
  s,s2: String;
  AField: PeField;
  AEntryField: TEntryField;  
begin
  IF df=NIL THEN Exit;
  IF NOT df^.HasRelate THEN Exit;
  TRY
    RelList:=TStringList.Create;
    AInfo:=df^.RelateInfo;
    w:=0;
    WHILE AInfo<>NIL DO
      BEGIN
        s:=trim(Pefield(df^.FieldList.Items[AInfo^.CmdInFieldNo])^.FName);
        IF Length(s)>w THEN w:=Length(s);
        AInfo:=AInfo^.Next;
      END;

    AInfo:=df^.RelateInfo;
    WHILE AInfo<>NIL DO
      BEGIN
        RelDf:=PDatafileInfo(RelateFiles.Objects[AInfo^.RelFileNo]);
        s:=trim(PeField(df^.FieldList.Items[AInfo^.CmdInFieldNo])^.FName);
        s2:=format(Lang(21698),[trim(PeField(df^.FieldList.Items[AInfo^.RelFieldNo])^.FName),
          ExtractFilename(RelDf^.RECFilename)]);  //21698=relate via %s to %s
        s:=Format('%-'+IntToStr(w)+'s  %s',[s,s2]);
        RelList.AddObject(s,TObject(PeField(df^.FieldList.items[AInfo^.CmdInFieldNo])));
        AInfo:=AInfo^.Next;
      END;

    LegalPickForm:=TLegalPickForm.Create(Application);
    LegalPickForm.Caption:=Lang(21700);   //21700=Select relate field to jump to
    LegalPickForm.ListBox1.Items.Assign(RelList);
    LegalPickForm.ListBox1.ItemIndex:=0;
    IF PickListPos.x>=0 THEN LegalPickForm.Left:=PickListPos.x;
    IF PickListPos.y>=0 THEN LegalPickForm.Top:=PickListPos.y;
    LegalPickForm.Width:=FieldNamesListWidth;

    IF LegalPickForm.ShowModal=mrOK THEN
      BEGIN
        n:=LegalPickForm.ListBox1.ItemIndex;
        IF n>-1 THEN
          BEGIN
            AField:=PeField(LegalPickForm.ListBox1.Items.Objects[n]);
            AEntryField:=TEntryField(AField^.EntryField);
            IF AEntryField.CanFocus THEN AEntryField.SetFocus
            ELSE Self.ScrollBox1.VertScrollBar.Position:=AEntryField.Top;
          END;
      END;
  FINALLY
    PickListPos.x:=LegalPickForm.Left;
    PickListPos.y:=LegalPickForm.Top;
    FieldNamesListWidth:=LegalPickForm.Width;
    LegalPickForm.Free;
    LegalPickForm:=NIL;
    RelList.Free;
    RelList:=NIL;
  END;
end;

procedure TDataForm.Goto1Click(Sender: TObject);
begin
  IF df=NIL THEN Exit;
  Findrelatefield1.Enabled:=df^.HasRelate;
  NewRecord1.Enabled:=(NOT df^.IsReadOnly);
  Markrecordfordeletion1.Enabled:=(NOT df^.IsReadOnly);
end;

procedure TDataForm.ActivateRelateFile(Adf: PDatafileInfo);
VAR
  n: Integer;
BEGIN
  ActiveRelateFile:=Adf;
  IF (Assigned(RelateTreeForm)) AND (RelateTreeCount>0) THEN
    BEGIN
      WITH RelateTreeForm DO
        BEGIN
          IF Assigned(RelateTree) THEN
            BEGIN
              FOR n:=0 TO RelateTree.Items.Count-1 DO
                BEGIN
                  RelateTree.Items.Item[n].StateIndex:=-1;
                  IF Adf=PDatafileInfo(RelateTree.Items.Item[n].Data)
                  THEN RelateTree.items.Item[n].StateIndex:=2;
                END;
            END;
        END;  //with
    END;  //if relateTreeForm
END;


procedure TDataForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
VAR
  ASearchForm: TSearchForm;
begin
  IF (df^.IsFinding) AND (Key=27) THEN
    BEGIN
      ASearchForm:=TSearchForm(df^.SearchForm);
      ASearchForm.Close;
    END;
end;


{Procedure TDataForm.Notification(AComponent: TComponent;  Operation: TOperation);
BEGIN
  //kk
  inherited;
END;}

procedure TDataForm.Exporttotextfile1Click(Sender: TObject);
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
begin
  //asdf
  ChangeRec(1,dirFirst);
  //ChangeRec(df^.CurRecord+1,dirForward);

  Seperator:=#9;
  StrID:=True;
  Ded:=True;
  ExportLin:=TStringList.Create;
  FromRecNo:=1;
  ToRecNo:=df^.NumRecords;
  UseFilter:=False;

  {Write fieldnames}
  IF True THEN
    BEGIN
      ExpRecLin:='';
      FOR exN:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          IF true THEN
            BEGIN
              WITH PeField(df^.FieldList.Items[exN])^ DO
                IF Felttype<>ftQuestion THEN
                  BEGIN
                    IF StrID THEN ExpRecLin:=ExpRecLin+'"'+trim(FName)+'"'+Seperator
                    ELSE ExpRecLin:=ExpRecLin+trim(Fname)+Seperator;
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
  UseIndex:=False;
  TRY
    FOR exN:=1 TO df^.NumRecords DO
      BEGIN
        peReadRecord(df,exN);
        IF ( ((NOT df^.CurRecDeleted) AND (DeD)) OR (NOT Ded) )
        AND ( (df^.CurRecord>=FromRecNo) AND (df^.CurRecord<=ToRecNo) )
        AND (FilterOK) THEN
          BEGIN
            ExpRecLin:='';
            FOR exN2:=0 TO df^.FieldList.Count-1 DO
              BEGIN
                WITH PeField(df^.FieldList.Items[exN2])^ DO
                  IF Felttype<>ftQuestion THEN
                    BEGIN
                      IF (StrID) AND (Felttype in [ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt])
                      THEN ExpRecLin:=ExpRecLin+'"'+FFieldText+'"'+Seperator
                      ELSE ExpRecLin:=ExpRecLin+FFieldText+Seperator;
                    END;  //if
              END;  //for exN2
            IF ExpRecLin[Length(ExpRecLin)]=Seperator
            THEN ExpRecLin:=Copy(ExpRecLin,1,Length(ExpRecLin)-1);
            ExportLin.Append(ExpRecLin);
          END;  //if CurRecDeleted
      END;  //for exN
  EXCEPT
    ErrorMsg(Format(Lang(22304),[exN]));   //'Error occured during export of record #%d'
    ExportLin.Free;
    CloseFile(ReadOnlyRecFile);
    Exit;
  END;  //try..Except
  ExportLin.SaveToFile(ChangeFileExt(df^.RECFilename,'.txt'));
  ExportLin.Free;
end;

end.



