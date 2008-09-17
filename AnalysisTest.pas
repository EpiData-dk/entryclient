unit AnalysisTest;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, EpiTypes, ExtCtrls, Buttons;

type
  TAnalysisForm = class(TForm)
    FieldsListBox: TListBox;
    DatafileLabel: TLabel;
    NumRecLabel: TLabel;
    FuncRadio: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnalysisForm: TAnalysisForm;

Procedure DoAnalysisTest(VAR VarDf:PDatafileInfo);

implementation

{$R *.DFM}

USES
  MainUnit,EdUnit;

TYPE
  EField = class(Exception);

VAR
  df: PDatafileInfo;
  SelFields,Res:TStringList;
  m: TMemoryStream;
  CurRecDeleted,IsMissing: Boolean;


procedure TAnalysisForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  IF ModalResult=mrOK THEN
    BEGIN
      IF FieldsListBox.SelCount=0 THEN
        BEGIN
          eDlg('No fields are selected',mtWarning,[mbOK],0);
          CanClose:=False;
        END
      ELSE CanClose:=True;
    END
  ELSE CanClose:=True;
end;



{********************************************************************************************

   Functions to information on specified fields/variables in specified records

********************************************************************************************}

Function GetValueLabel(CONST FieldName,ValueStr:String):String;
VAR
  AField: PeField;
  tmpS:   String;
BEGIN
  {Returns as a string the valuelabel for the value ValueStr of the field FieldName.
   Please notice that ValueStr is a string!  }
  Result:='';
  AField:=GetField(Fieldname,df);
  IF AField=NIL THEN raise EField.CreateFmt('Unknown field %s',[Fieldname]);
  IF (AField^.Felttype=ftInteger) or (AField^.Felttype=ftFloat) or (Afield^.Felttype=ftIDNUM)
  THEN tmpS:=format('%'+IntToStr(AField^.FLength)+'s',[trim(ValueStr)])
  ELSE tmpS:=format('%-'+IntTostr(AField^.FLength)+'s',[trim(ValueStr)]);
  Result:=GetCommentLegalText(tmpS,AField^.FCommentLegalRec);
END;

Function GetFieldWidth(CONST FieldName:String):Integer;
VAR
  AField: PeField;
BEGIN
  {Returns the width in characters of the specified field FieldName}
  AField:=GetField(Fieldname,df);
  IF AField=NIL THEN raise EField.CreateFmt('Unknown field %s',[Fieldname]);
  Result:=AField^.FLength;
ENd;


Function GetFieldType(CONST FieldName:String):TFeltTyper;
VAR
  AField: PeField;
BEGIN
  {Returns the fieldtype of the field
   Possible returnvalues are:
     TFelttyper = (ftInteger,ftAlfa,ftDate,ftUpperAlfa,ftCheckBox,
                ftBoolean,ftFloat,ftPhoneNum,ftTime,ftLocalNum,
                ftToday,ftEuroDate,ftIDNUM,ftRes4,ftRes5,
                ftQuestion,ftEuroToday,ftSoundex)

   Please notice that integerfields (#####) with more than 4 characters in width
   have the type ftFloat and NOT the type ftInteger   }

  AField:=GetField(Fieldname,df);
  IF AField=NIL THEN raise EField.CreateFmt('Unknown field %s',[Fieldname]);
  Result:=AField^.Felttype;
END;


Function GetValue(CONST FieldName: String; RecNo: LongInt):Double;
VAR
  AField: PeField;
  RecordPos: Integer;
  FieldT:PChar;
  FieldText: String;
  CharPointer: ^Char;
BEGIN
  {Returns as a Double the value of a field with the name FieldName in Record #RecNo
   If the record is marked as deleted then the global variable CurRecDeleted is set to False.
   If the value is missing then the global variable IsMissing is set to True

   If field is unknown then an exception is raised }

  TRY
    New(CharPointer);
    Result:=0;
    IsMissing:=True;
    IF df=NIL THEN Exit;
    AField:=GetField(Fieldname,df);
    IF AField=NIL THEN raise EField.CreateFmt('Unknown field %s',[Fieldname]);

    {Test for record deleted}
    RecordPos:=df^.Offset+((RecNo-1)*df^.RecLength);
    M.Position:=RecordPos+df^.RecLength-3;
    M.Read(CharPointer^,1);
    IF CharPointer^='?' THEN CurRecDeleted:=True ELSE CurRecDeleted:=False;

    {Read value}
    RecordPos:=df^.Offset+((RecNo-1)*df^.RecLength);
    FieldT:=PChar(cFill(#0,AField^.FLength+3));
    M.Position:=RecordPos+AField^.FStartPos;
    M.ReadBuffer(FieldT^,AField^.FLength+3);
    FieldText:=FieldT;
    IF Pos('!',FieldText)>0 THEN Delete(FieldText,Pos('!',FieldText),3)
    ELSE FieldText:=Copy(FieldText,1,AField^.FLength);
    FieldText:=trim(FieldText);
    IF FieldText<>'' THEN
      BEGIN
        IsMissing:=False;
        CASE AField^.Felttype OF
          ftInteger,ftIDNUM: IF IsInteger(FieldText) THEN Result:=StrToFloat(FieldText);
          ftFloat:           IF IsFloat(FieldText)   THEN Result:=eStrToFloat(FieldText);
        ELSE
          IsMissing:=True;
        END;
      END;  //if not missing
  FINALLY
    Dispose(CharPointer);
  END;  //try..finally
END;


{********************************************************************************************

   Your own procedures that generates statistics


   When these are called from procedure DoAnalysisTest the following global variables
   can be used:

   SelFields: TStringList     is a list of fieldnames of the fields selected by
                              the user in the AnalysisForm.

   SelFields.Count            is the number of fields/variables passed to the procedure

   Res: TStringList           is used to produce text-output that will be shown
                              in an EpiData editor window when the statitics-procedure
                              returns. DoAnalysisTest handles the actual showing
                              of the contents of Res:TStringList.

   There is presently only one function that retrieves data from a variable: GetValue.
   GetValue returns the value of a specified variable in a specified record as a double.
   GetValue can ONLY be used with numeric fields, i.e. fields with the fieldtype
   ftInteger,ftFloat and ftIDNUM.

   After a call to GetValue these variables will be set:

     CurRecDeleted:Boolean    Indicates if the record read by GetValue is marked
                              as deleted

     IsMissing:Boolean        Indicates if the variable read by GetValue has the
                              value "missing".

   Other useful variables are:
     df^.NumRecords:Integer   Total number of records in the active datafile (including
                              deleted records)

     df^.Filelabel:String[50] Contains the filelabel of the active datafile



********************************************************************************************}



Procedure CalcMean;
VAR
  CurVar,CurRec,N:Integer;
  sumX,sumXsqr,tmpValue,MeanValue,StdDev: Double;
BEGIN
  Res.Append(Format('%-12s %15s %15s',['Fieldname','Mean','Std.dev.']));
  Res.Append(cFill('-',44));
  FOR CurVar:=0 TO SelFields.Count-1 DO
    BEGIN
      sumX:=0;
      sumXsqr:=0;
      N:=0;
      FOR CurRec:=1 TO df^.NumRecords DO
        BEGIN
          tmpValue:=GetValue(SelFields[CurVar],CurRec);
          IF NOT CurRecDeleted THEN
            BEGIN
              IF NOT IsMissing THEN
                BEGIN
                  INC(N);
                  SumX:=SumX+tmpValue;
                  sumXsqr:=sumXsqr+(tmpValue*tmpValue);
                END;  //if not missing
            END;  //if not CurRecDeleted
        END;  //for CurRec
      IF N>0 THEN
        BEGIN
          StdDev:=((N*SumXsqr)-(SumX*SumX)) / (N*N);
          StdDev:=Sqrt(StdDev);
          MeanValue:=SumX/N;
          Res.Append(Format('%-12s %15.4f %15.4f',[SelFields[CurVar],MeanValue,StdDev]));
        END
      ELSE Res.Append(SelFields[CurVar]);
    END;  //for CurVar
END;  //procedure CalcMean

Procedure FreqTable;
VAR
  UniqueList: TStringList;
  CurVar,CurRec,N,NumMissing:Integer;
  tmpValue: double;
  FormStr,tmpS,tmpS2,tmpS3: String;
  LongestUnique,UnDeletedRecs:Integer;
BEGIN
  TRY
    UniqueList:=TStringList.Create;
    UniqueList.Sorted:=True;
    UniqueList.Duplicates:=dupIgnore;
    FOR CurVar:=0 TO SelFields.Count-1 DO
      BEGIN
        IF (GetFieldType(SelFields[CurVar])<>ftInteger)
        AND (GetFieldType(SelFields[CurVar])<>ftFloat) THEN Continue;
        UniqueList.Clear;
        UnDeletedRecs:=0;
        FOR CurRec:=1 TO df^.NumRecords DO
          BEGIN
            tmpValue:=GetValue(SelFields[CurVar],CurRec);
            IF CurRecDeleted THEN Continue;
            INC(UnDeletedRecs);
            IF IsMissing THEN
              BEGIN
                INC(NumMissing);
                n:=UniqueList.IndexOf('.');
                IF n=-1 THEN UniqueList.AddObject('.',TObject(1))
                ELSE UniqueList.Objects[n]:=Tobject(Integer(UniqueList.Objects[n])+1);
              END
            ELSE
              BEGIN
                tmpS:=format('%'+IntToStr(GetfieldWidth(SelFields[CurVar]))+'s',[IntToStr(Round(tmpValue))]);
                n:=UniqueList.IndexOf(tmpS);
                IF n=-1 THEN UniqueList.AddObject(tmpS,TObject(1))
                ELSE UniqueList.Objects[n]:=TObject(Integer(UniqueList.Objects[n])+1);
              END;
          END;   //for CurRec
        Res.Append(SelFields[CurVar]);
        Res.Append('');

        IF UniqueList.Count<=10 THEN
          BEGIN
            LongestUnique:=0;
            FOR n:=0 TO UniqueList.Count-1 DO
              IF Length(trim(UniqueList[n]))>LongestUnique
              THEN LongestUnique:=Length(trim(UniqueList[n]));
            IF LongestUnique<6 THEN LongestUnique:=6;
            IF LongestUnique>20 THEN LongestUnique:=20;
            FormStr:='     %18s:  %6s  %6s  %-'+IntToStr(LongestUnique)+'s  %-s';
            Res.Append(Format(FormStr,[Lang(20844),Lang(20846),Lang(20848),Lang(20850),Lang(20852)]));
            {20844=tabulation
            20846=Freq.
            20848=Pct.
            20850=Value
            20852=Label}
            FormStr:='     %18s  %6d  %6s  %'+IntToStr(LongestUnique)+'s  %-s';
            FOR n:=0 TO UniqueList.Count-1 DO
              BEGIN
                tmpValue:=(Integer(UniqueList.Objects[n])/UnDeletedRecs)*100;
                tmpS:=Format('%5.1f',[tmpValue]);
                tmpS2:=GetValueLabel(SelFields[CurVar],trim(UniqueList[n]));
                tmpS3:=trim(UniqueList[n]);
                IF Length(tmpS3)>20 THEN tmpS3:=Copy(tmpS3,1,18)+'..';
                Res.Append(Format(FormStr,['',Integer(UniqueList.Objects[n]),tmpS,tmpS3,tmpS2]));
              END;  //for n
          END  //if max 10 unique values
        ELSE
          BEGIN
            //Field has more than 10 unique values
            FormStr:='      %18s  %-s';
            FOR n:=1 TO 10 DO
              IF n=1 THEN Res.Append(Format(FormStr,[Lang(20854),UniqueList[n]]))   //'Examples:'
              ELSE Res.Append(Format(FormStr,['',UniqueList[n]]));
          END;
        Res.append('');
        Res.Append('');
      END;  //for CurVar

  FINALLY
    UniqueList.Free;
  END;
END;  //procedure FreqTable


{********************************************************************************************

           DoAnalysisTest

           Is called when the menuitem Analysis Test is clicked.

********************************************************************************************}



Procedure DoAnalysisTest(VAR VarDf:PDatafileInfo);
VAR
  n:Integer;
  AEdForm: TEdForm;
BEGIN
  df:=VarDf;
  TRY
    {Læs recfilen ind i memorystream}
    M:=TMemoryStream.Create;
    M.LoadFromFile(df^.RECFilename);

    AnalysisForm:=TAnalysisForm.Create(MainForm);
    WITH AnalysisForm DO
      BEGIN
        DatafileLabel.Caption:='Datafile: '+df^.RECFilename;
        NumRecLabel.Caption:='Number of records: '+IntToStr(df^.NumRecords);
        FOR n:=0 TO df^.FieldList.Count-1 DO
          IF PeField(df^.FieldList.Items[n])^.Felttype<>ftQuestion
          THEN FieldsListBox.Items.Append(trim(PeField(df^.FieldList.Items[n])^.FName));
        IF ShowModal=mrCancel THEN Exit;
        SelFields:=TStringList.Create;
        Res:=TStringList.Create;
        FOR n:=0 TO FieldsListBox.Items.Count-1 DO
          IF FieldsListBox.Selected[n] THEN SelFields.append(FieldsListBox.Items[n]);

        {Nu indeholder SelFields en liste over den/de udvalgte feltnavne
         Den kaldte funktion skal skrive resultater til Res:TStringList}

        Case FuncRadio.ItemIndex OF
          0: CalcMean;
          1: FreqTable;
        END;  //case
      END;   //with

    AEdForm:=TEdForm.Create(MainForm);
    WITH AEdForm DO
      BEGIN
        PathName:=DefaultFilename;
        Caption:=Format('Results from analysistest',[ExtractFilename(df^.RECFilename)]);  //'Codebook based on %s'
        FormType:=ftDocumentation;
        Ed.Font.Assign(epiDocuFont);
        Ed.Lines.Assign(Res);
        Ed.SelStart:=0;
        Ed.Modified:=True;
      END;  //with

  FINALLY
    SelFields.Free;
    Res.Free;
    AnalysisForm.Free;
    m.Free;
  END;  //try..finally

END;



end.
