unit CheckObjUnit;

//{$DEFINE epidat}


interface

USES Controls,Windows, Messages, Forms,Dialogs,Graphics,SysUtils,Classes,EpiTypes;

type
  nwTypess=(nwAny,nwSameLine,nwSameKeepQuotes,nwKeepSpaces);

  TParser = class(TObject)
  private
    FLines:       TStringList;
    FCurLin:      String;
    FCurLinIndex: Integer;
    FEndOfLines:  Boolean;
    function      FGetCurLinIndex:Integer;         
  public
    Constructor   Create(inputlines:String);
    Destructor    Destroy;  override;
    Function      GetToken(nwType: nwTypess):string;
    Function      GetUpperToken(nwType: nwTypess):String;
    Function      GetLowerToken(nwType: nwTypess):string;
    Function      GetLineAndFlush:string;
    Function      GetWholeLine:String;
    Procedure     CommentCurLine;
    property      EndOfLines: Boolean read FEndOfLines write FEndOfLines;
    property      GetCurLinIndex: Integer read FGetCurLinIndex write FCurLinIndex;
  end;

  TTranslateEvent = procedure(stringnumber:Integer; origstring:string; VAR transstring:string) of object;

  TCheckObj = class(TObject)
  private
    FParser:         TParser;
    FErrorList:      TStringList;
    FFieldNameList:  TStrings;
    LegList:         TStrings;
    FEndOfChk:       Boolean;
    FMultiLineError: Boolean;
    FTempResult:     Boolean;
    FCheckFileMode:  Boolean;
    df:              PDataFileInfo;
    FirstTopFlaw,SaveTopFlawsAsComments: Boolean;
    FirstFieldFlaw,SaveFieldFlawsAsComments: Boolean;
    CommentsAddedToCheckFile: Boolean;
    ReadingLabelLibrary: Boolean;
    InIfBlock:       Boolean;
    CurCommand:      String;
    tmpField:        PeField;
    FOnTranslate:    TTranslateEvent;
    Function  GetErrorList: String;
    Procedure ReportError(CONST ErrStr:String);
    Procedure RetrieveFieldBlock;
    Procedure RetrieveLabelBlock;
    Procedure RetrieveLabel;
    Procedure RetrieveAssertBlock;
    Procedure GetCommandList(VAR CmdList:TList);
    Procedure GetCommand(VAR CmdList:TList);
    Procedure AddTopComment;
    Procedure RetrieveFlawBlock;
    Procedure RetrieveRange;
    Procedure RetrieveLegals;
    Procedure RetrieveAutoJump;
    Procedure RetrieveJumps;
    Procedure RetrieveMissingValues;
    Procedure RetrieveDefaultValue;
    Procedure RetrieveAutosearch;
    Procedure RetrieveCommentLegal(VAR AValueLabel:ShortString; VAR ACommentLegalRec: PLabelRec; VAR ShowList:Boolean; AsCommand:Boolean);
    Procedure RetrieveType;
    Procedure RetrieveKeys;
    Procedure AddFieldFlawComment;
    Procedure HandleBooleanConditions(VAR s:String);
    Procedure AddFieldComment;
    Function  Translate(stringnumber:Integer; origstring:string):string;
  public
    Constructor Create;
    Destructor  Destroy; override;
    Function    ApplyChecks(ADatafile: PDatafileInfo; chkLines: String): Boolean;
    property    ErrorList: String read GetErrorList;
    property    MultiLineError: Boolean read FMultiLineError write FMultiLineError;
    property    EndOfChk: Boolean read FEndOfChk;
    property    ChkFileMode: Boolean read FCheckFileMode write FCheckFileMode;
    Property OnTranslate: TTranslateEvent read FOnTranslate write FOnTranslate;
  end;


implementation

USES
  {$IFNDEF epidat}
  FileUnit,UExtUDF, epiUDFTypes;
  {$ELSE}
  FileUnit,UExtUDF,epiUDFTypes;
  {$ENDIF}


// ==============================  TParser =======================================

Constructor TParser.Create(inputlines:String);
BEGIN
  inherited create;
  FLines:=TStringList.Create;
  FLines.Text:=inputLines;
  FCurLin:='';
  FCurLinIndex:=-1;
  FEndOfLines:=False;
END;  //tparser.create

Destructor TParser.Destroy;
BEGIN
  FLines.Free;
  inherited destroy;
END;  //tparser.destroy

Function TParser.GetToken(nwType: nwTypess):string;
VAR
  n: Integer;
  Stop: Boolean;
BEGIN
  IF (trim(FCurLin)='') AND (nwType=nwAny) THEN
    BEGIN
      INC(FCurLinIndex);
      IF FCurLinIndex<FLines.Count
      THEN FCurLin:=Trim(FLines[FCurLinIndex])+' '
      ELSE FEndOfLines:=True;
    END;
  IF (trim(FCurLin)<>'') THEN
    BEGIN
      IF Copy(trim(FCurLin),1,1)='*' THEN
        BEGIN
          Result:=FCurLin;
          FCurLin:='';
        END
      ELSE
        BEGIN
          Result:=Copy(FCurLin,1,Pos(' ',FCurLin)-1);
          IF (Result[1]='"') THEN
            BEGIN
              IF (Result[Length(Result)]='"')  AND (Length(Result)>1) THEN
                BEGIN
                  {Only one word is found in quotationmarks}
                  IF NOT (nwType=nwSameKeepQuotes) THEN Result:=Copy(Result,2,Length(Result)-2);
                  Delete(FCurLin,1,Pos(' ',FCurlin));
                END
              ELSE
                BEGIN
                  {Multiple words found in quotationsmarks}
                  n:=1;
                  Result:='';
                  Stop:=False;
                  REPEAT
                    Result:=Result+FCurLin[n];
                    INC(n);
                    IF n>Length(FCurLin) THEN Stop:=True
                    ELSE IF FCurLin[n]='"' THEN Stop:=True;
                  UNTIL Stop;
                  Result:=Result+'"';
                  IF NOT (nwType=nwKeepSpaces) THEN Result:=trim(Result);
                  IF NOT (nwType=nwSameKeepQuotes) THEN
                    BEGIN
                      Delete(Result,1,1);
                      Delete(FCurLin,1,n);
                      IF Result[Length(Result)]='"' THEN Delete(Result,Length(Result),1);
                    END
                  ELSE Delete(FCurLin,1,n);
                END;
            END
          ELSE Delete(FCurLin,1,Pos(' ',FCurLin));
          FCurLin:=trim(FCurLin)+' ';
        END;
    END
  ELSE Result:='';
END;  //tparser.GetToken

Function TParser.GetUpperToken(nwType: nwTypess):string;
BEGIN
  Result:=AnsiUpperCase(GetToken(nwType));
END;

Function TParser.GetLowerToken(nwType: nwTypess):string;
BEGIN
  Result:=AnsiLowerCase(GetToken(nwType));
END;

Function TParser.GetLineAndFlush:String;
BEGIN
  Result:=FCurLin;
  FCurLin:='';
END;   //TParser.GetLineAndFlush

Function TParser.GetWholeLine:String;
BEGIN
  Result:=FLines[FCurLinIndex];
  FCurLin:='';
END;

Function TParser.FGetCurLinIndex: Integer;
BEGIN
  IF FEndOfLines THEN Result:=FLines.Count ELSE Result:=FCurLinIndex;
END;

Procedure TParser.CommentCurLine;
BEGIN
  FLines[FCurLinIndex]:='* '+FLines[FCurLinIndex];
END;


// ==============================  TCheckObj =======================================


Constructor TCheckObj.create;
BEGIN
  inherited create;
  FErrorList:=TStringList.Create;
  FParser:=NIL;
  FFieldNameList:=NIL;
  LegList:=TStringList.Create;
  FMultiLineError:=True;
  FCheckFileMode:=False;
  CommentsAddedToCheckFile:=False;
  ReadingLabelLibrary:=False;
  df:=NIL;
END;   //create

Destructor TCheckObj.Destroy;
begin
  FErrorList.Free;
  IF Assigned(FParser) THEN FParser.Free;
  IF Assigned(LegList) THEN LegList.Free;
  IF Assigned(FFieldNameList) THEN FFieldNameList.Free;
  Inherited Destroy;
end;   //destroy

Function TCheckObj.GetErrorList: String;
begin
  Result:=FErrorList.Text;
end;

Function TCheckObj.ApplyChecks(ADatafile: PDatafileInfo; chkLines: String): Boolean;
VAR
  aN,n,n2: Integer;
  aFound: Boolean;
  tmpString,NewChkLines,IncludeStrings: TStringList;
  s: string;
begin
  Result:=False;
  df:=ADatafile;
  FErrorList.Clear;
  IF FMultiLineError THEN
    BEGIN
      FErrorList.Add('');
      FErrorList.Add(Format(translate(22794,'The check-file %s contains the following errors:'),[df^.CHKFilename]));  //'The check-file %s contains the following errors:'
      FErrorList.Add('');
      FErrorList.Add('');
    END;
  //Check if checkfile uses INCLUDE command
  IF pos('INCLUDE',AnsiUpperCase(chkLines))>0 THEN
    BEGIN
      //checkfile might contain INCLUDE command
      TRY
        tmpString:=TStringList.Create;
        IncludeStrings:=TStringList.Create;
        NewChkLines:=TStringList.Create;
        tmpString.Text:=chkLines;
        FOR n:=0 TO tmpString.Count-1 DO
          BEGIN
            IF copy(AnsiUpperCase(trim(tmpString[n])),1,8)='INCLUDE ' THEN
              BEGIN
                //Include command found
                df^.HasIncludeCmd:=True;
                IF FCheckFileMode THEN
                  BEGIN
                    ReportError(translate(22868,'Checkfiles with INCLUDE commands cannot be revised with the Add/Revise function'));  //22868=Checkfiles with INCLUDE commands cannot be revised with the Add/Revise function
                    Result:=False;
                    Exit;
                  END;
                s:=trim(copy(trim(tmpString[n]),9,Length(tmpString[n])));
                //IF ExtractFileExt(s)='' THEN s:=ChangeFileExt(s,'.chk');
                IF (s[1]='"') AND (s[Length(s)]='"') THEN s:=Copy(s,2,Length(s)-2);
                IF NOT FileExists(s) THEN
                  BEGIN
                    ReportError(Format(translate(22870,'Includefile %s not found'),[s]));  //22870=Includefile %s not found
                    Result:=False;
                    Exit;
                  END
                ELSE
                  BEGIN
                    TRY
                      IncludeStrings.Clear;
                      IncludeStrings.LoadFromFile(s);
                      FOR n2:=0 TO IncludeStrings.Count-1 DO
                        NewChkLines.Append(IncludeStrings[n2])
                    EXCEPT
                      ReportError(Format(translate(22872,'Error reading includefile %s'),[s]));  //22872=Error reading includefile %s
                      Result:=False;
                      Exit;
                    END;  //try..except
                  END;  //else
              END  //if include word found
            ELSE NewChkLines.Append(tmpString[n]);
          END;  //for
        chkLines:=NewChkLines.Text;
      FINALLY
        tmpString.Free;
        IncludeStrings.Free;
        NewChkLines.Free;
      END;  //try..finally
    END;  //if chklines has include
  IF Assigned(FParser) THEN FParser.Free;
  FParser:=TParser.Create(chkLines);
  FirstTopFlaw:=True;
  SaveTopFlawsAsComments:=False;
  FirstFieldFlaw:=True;
  SaveFieldFlawsAsComments:=False;
  CommentsAddedToCheckFile:=False;
  InIfBlock:=False;
  IF Assigned(FFieldNameList) THEN FFieldNameList.Free;
  FFieldNameList:=TStringList.Create;
  FOR aN:=0 TO df^.FieldList.Count-1 DO
    FFieldnameList.Add(AnsiUpperCase(trim(PeField(df^.FieldList.Items[aN])^.FName)));
  FTempResult:=True;
  IF (FCheckFileMode) AND (Assigned(df^.ChkTopComments)) THEN df^.ChkTopComments.Append('* '+translate(22796,'Revised')+' '+  //'Revised'
    FormatDateTime('dd mmm yyyy hh":"nn',now));
  REPEAT    //Read top-level check commands
    aFound:=False;
    CurCommand:=FParser.GetUpperToken(nwAny);   //  AnsiUpperCase(NextWord(nwAny));

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

    df^.FocusedField:=FFieldnameList.IndexOf(CurCommand);
    IF df^.FocusedField>-1 THEN RetrieveFieldBlock
    ELSE IF CurCommand='LABELBLOCK' THEN RetrieveLabelBlock
    ELSE IF CurCommand='CONSISTENCYBLOCK' THEN RetrieveAssertBlock
    ELSE IF CurCommand='BEFORE' THEN
      BEGIN
        CurCommand:=FParser.GetUpperToken(nwSameLine);  //AnsiUpperCase(NextWord(nwSameLine));
        IF CurCommand='FILE' THEN GetCommandList(df^.BeforeFileCmds)
        ELSE IF CurCommand='RECORD' THEN GetCommandList(df^.BeforeRecordCmds)
        ELSE
          BEGIN
            ReportError(translate(22798,'Unknown command after BEFORE'));  //'Unknown command after BEFORE'
            FTempResult:=False;
          END;
      END
    ELSE IF CurCommand='AFTER' THEN
      BEGIN
        CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
        IF CurCommand='FILE' THEN GetCommandList(df^.AfterFileCmds)
        ELSE IF CurCommand='RECORD' THEN GetCommandList(df^.AfterRecordCmds)
        ELSE
          BEGIN
            ReportError(translate(22800,'Unknown command after AFTER'));  //'Unknown command after AFTER'
            FTempResult:=False;
          END;
      END
    ELSE IF CurCommand='RECODEBLOCK' THEN GetCommandList(df^.RecodeCmds)
    ELSE IF CurCommand<>'' THEN
      BEGIN
        IF CurCommand[1]='*' THEN AddTopComment ELSE RetrieveFlawBlock;
      END;
  UNTIL FParser.EndOfLines;
  {Pack indexfield list}
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
  Result:=FTempResult;
end;

Procedure TCheckObj.ReportError(CONST ErrStr:String);
VAR
  n:Integer;
BEGIN
  IF Assigned(Fparser) THEN n:=FParser.GetCurLinIndex+1 ELSE n:=0;
  {$IFNDEF epidat}
  IF FMultiLineError THEN
    BEGIN
      FErrorList.Append(Format(translate(22700,'%s in line %d:'),[ErrStr,n]));  //'%s in line %d:'
      IF Assigned(FParser) THEN FErrorList.Append(FParser.GetWholeLine);
      FErrorList.Append('');
    END
  ELSE FErrorList.Append(Format(translate(22702,'Line %d: %s'),[n,ErrStr]));  //'Line %d: %s'
  {$ENDIF}
END;  //procedure ReportError

Procedure TCheckObj.RetrieveFieldBlock;
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
    MISSINGVALUE n [n [n]]
    DEFAULTVALUE x
    AUTOSEARCH [LIST] [SOUNDEX] FIELD1 [FIELD2 [FIELD3...]]
  }
  IF PeField(df^.FieldList.Items[df^.FocusedField])^.Felttype<>ftQuestion THEN
    BEGIN
      New(tmpField);
      ResetCheckProperties(tmpField);
      tmpField^.Felttype:=PeField(df^.FieldList.Items[df^.FocusedField])^.Felttype;
      tmpField^.FLength:=PeField(df^.FieldList.Items[df^.FocusedField])^.FLength;
      REPEAT
        CurCommand:=FParser.GetUpperToken(nwAny);  //  AnsiUpperCase(NextWord(nwAny));
        //n:=FFieldNameList.IndexOf(CurCommand);   HVORFOR ER DET TILFØJET??
        IF      CurCommand='RANGE'       THEN RetrieveRange
        ELSE IF CurCommand='LEGAL'       THEN RetrieveLegals
        ELSE IF CurCommand='MISSINGVALUE' THEN RetrieveMissingValues
        ELSE IF CurCommand='DEFAULTVALUE' THEN RetrieveDefaultValue
        ELSE IF CurCommand='AUTOSEARCH'   THEN RetrieveAutosearch
        ELSE IF CurCommand='MUSTENTER'   THEN tmpField^.FMustEnter:=True
        ELSE IF CurCommand='NOENTER'     THEN tmpField^.FNoEnter:=True
        ELSE IF CurCommand='TOPOFSCREEN' THEN
          BEGIN
            tmpField^.FTopOfScreen:=True;
            tmpField^.FTopOfScreenLines:=0;
            CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
            IF (CurCommand<>'') AND (IsInteger(CurCommand)) THEN tmpField^.FTopOfScreenLines:=StrToInt(CurCommand);
          END
        ELSE IF CurCommand='REPEAT'      THEN
          BEGIN
            tmpField^.FRepeat:=True;
            df^.HasRepeatField:=True;
          END
        ELSE IF (CurCommand='CODEFIELD') OR (CurCommand='CODES') THEN
          BEGIN
            ReportError(translate(22782,'CODEFIELD/CODES not supported. Please use TYPE COMMENT fieldname instead.'));  //'CODEFIELD/CODES not supported. Please use TYPE COMMENT fieldname instead.'
            FTempResult:=False;
          END
        ELSE IF CurCommand='AUTOJUMP'     THEN RetrieveAutoJump
        ELSE IF CurCommand='JUMPS'        THEN RetrieveJumps
        ELSE IF CurCommand='COMMENT'      THEN RetrieveCommentLegal(tmpField^.FValueLabel,tmpField^.FCommentLegalRec,tmpField^.FShowLegalPickList,False)
        ELSE IF CurCommand='TYPE'         THEN RetrieveType
        ELSE IF CurCommand='KEY'          THEN RetrieveKeys
        ELSE IF CurCommand='CONFIRMFIELD' THEN tmpField^.FConfirm:=True
        ELSE IF CurCommand='ENTER'        THEN FTempResult:=True
//          BEGIN
//            ReportError(translate(22784));  //'ENTER command not supported. Please use BEFORE/AFTER ENTRY instead.'
//            FTempResult:=False;
//          END
        ELSE IF CurCommand='BEFORE'       THEN
          BEGIN
            CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
            IF CurCommand='ENTRY' THEN
            GetCommandList(tmpField^.BeforeCmds)
            ELSE
              BEGIN
                ReportError(translate(22786,'ENTRY expected'));  //'ENTRY expected'
                FTempResult:=False;
              END;
          END
        ELSE IF CurCommand='AFTER' THEN
          BEGIN
            CurCommand:=Fparser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
            IF CurCommand='ENTRY' THEN GetCommandList(tmpField^.AfterCmds)
            ELSE
              BEGIN
                ReportError(translate(22786,'ENTRY expected'));  //'ENTRY expected'
                FTempResult:=False;
              END;
          END
        ELSE IF CurCommand<>'' THEN GetCommand(tmpField^.AfterCmds);
{            BEGIN
            IF CurCommand[1]='*' THEN AddFieldComment
            ELSE IF CurCommand<>'END' THEN AddFieldFlawComment;
          END;}
      UNTIL (FParser.EndOfLines) OR (CurCommand='END');
      IF FTempResult THEN
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
              FDefaultValue:=tmpField^.FDefaultValue;
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
              IF NOT FHasGlobalMissing THEN
                BEGIN
                  FMissingValues[0]:=tmpField^.FMissingValues[0];
                  FMissingValues[1]:=tmpField^.FMissingValues[1];
                  FMissingValues[2]:=tmpField^.FMissingValues[2];
                END;
              FAutosearch:=tmpField^.FAutosearch;
              FAutoFields:=tmpField^.FAutoFields;
              FAutoList:=tmpField^.FAutoList;
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
END;   //procedure TCheckObj.RetrieveFieldBlock

Procedure TCheckObj.RetrieveLabelBlock;
{Reads the LABELBLOCK..END block in the checkfile}
BEGIN
  REPEAT
    CurCommand:=FParser.GetUpperToken(nwAny);  //  AnsiUpperCase(NextWord(nwAny));
    IF CurCommand='LABEL' THEN RetrieveLabel;
  UNTIL (CurCommand='END') OR (FParser.EndOfLines);
  CurCommand:='';
END;  //RetrieveLabelBlock

Procedure TCheckObj.RetrieveLabel;
{Reads a LABEL..END block}
VAR
  FirstLabelRec,tmpLabelRec,NextLabelRec:PLabelRec;
  tmpLabelName:String[80];
  ok,StopRead,FirstLabel:Boolean;
  s: String;
BEGIN
  ok:=True;
  FirstLabel:=True;
  tmpLabelRec:=NIL;
  FirstLabelRec:=NIL;
  CurCommand:=AnsiLowerCase(FParser.GetToken(nwSameLine));  //AnsiLowerCase(NextWord(nwSameLine));   //Get Labelname
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
            {Read value}
            CurCommand:=FParser.GetToken(nwAny);  //  NextWord(nwAny);
            IF Trim(CurCommand)='' THEN
              BEGIN
                StopRead:=True;
                ok:=False;
              END;
            IF AnsiUpperCase(CurCommand)='END' THEN StopRead:=True
            ELSE IF trim(CurCommand)<>'' THEN
              BEGIN
                s:=trim(CurCommand);
                IF s[1]='*' THEN     //###
                  BEGIN
                    s:=trim(FParser.GetWholeLine);
                    IF NOT FCheckFileMode THEN Continue;
                    IF Length(s)>(30+80) THEN
                      BEGIN
                        ReportError(translate(22874,'Commented line is too long'));   //22874=Commented line is too long
                        StopRead:=True;
                        ok:=False;
                      END
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
                IF s[1]='*' THEN
                  BEGIN
                    tmpLabelRec^.Value:=Copy(s,1,30);
                    IF Length(s)>30 THEN tmpLabelRec^.Text:=Copy(s,31,Length(s));
                  END  //if reading a commented-out label
                ELSE
                  BEGIN
                    IF Length(CurCommand)>30 THEN CurCommand:=Copy(CurCommand,1,30);
                    tmpLabelRec^.Value:=CurCommand;
                    {Read text}
                    CurCommand:=FParser.GetToken(nwSameLine);   //NextWord(nwSameLine);
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
                  END  //if reading a proper label
              END  //if line is not empty
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
END;  //TCheckObj.RetrieveLabel


Procedure TCheckObj.RetrieveAssertBlock;
{Reads the CONSISTENCYBLOCK..END block - and ignores it...}
BEGIN
  IF NOT Assigned(df^.AssertList) THEN df^.AssertList:=TStringList.Create;
  REPEAT
    CurCommand:=FParser.GetUpperToken(nwAny);  //AnsiUpperCase(nextWord(nwAny));
    IF (CurCommand='CHECK') OR (CurCommand='REPORT') THEN
      BEGIN
        df^.AssertList.Append(FParser.GetWholeLine);
      END;
  UNTIL (CurCommand='END') OR (FParser.EndOfLines);
  CurCommand:='';
END;  //TCheckObj.RetrieveAssertBlock


Procedure TCheckObj.GetCommandList(VAR CmdList:TList);
BEGIN
  REPEAT
    CurCommand:=FParser.GetToken(nwAny);  //   NextWord(nwAny);
    IF AnsiUpperCase(CurCommand)<>'END' THEN GetCommand(CmdList);
  UNTIL (AnsiUpperCase(CurCommand)='END') OR (FParser.EndOfLines);
  CurCommand:='';
END;  //GetCommandList



Procedure TCheckObj.GetCommand(VAR CmdList:TList);
VAR
  cmd:Commands;
  tmpCmdRec:TCmds;
  SeenElse,ok,found,IsEpiInfo,ImplicitLet,glob_dub:Boolean;
  tmpCmdPtr:PCmds;
  n,n2,n3,fieldFrom,fieldTo:Integer;
  tmpStr:String[20];
  s1,s2:String[200];
  tmpS,tmpS2:String;   //&&
  tmpDefVar: PDefVar;
  AInfo,BInfo: PRelateInfo;
  bb,bb2,bb3:byte;
  tmpTxtColor,tmpBgColor: TColor;
  tmpStr10: str10;
  tmpList1,tmpList2: TStringList;
  NumValues: Integer;
  //MisValues: Array[0..2] of String[10];
  mv1, mv2, mv3: str15;
  AField: PeField;
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
    QUIT
    COPYTOCLIPBOARD
    SHOWLASTRECORD
    [LET] Fieldname=expression
    * (Comments)
  }
  IF (AnsiUpperCase(CurCommand)='END')
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
          {check if unknown CurCommand is implicit LET}
          //s1:=AnsiUppercase(trim(CurCommand+' '+CurLin));
          s1:=trim(CurCommand+' '+FParser.GetLineAndFlush);
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
          n:=1;
          s2:=s1;
          n:=pos('=',s2);
          IF n=0 THEN ok:=False
          ELSE IF n=1 THEN
            BEGIN
              ReportError(translate(22756,'Missing field- or variablename to the left of the equal-sign'));  //'Missing field- or variablename to the left of the equal-sign'
              ok:=False
            END
          ELSE
            BEGIN
              tmpStr:=trim(Copy(s2,1,n-1));
              {Check if tmpStr contains a fieldname or variablename}
              n:=GetFieldNumber(tmpStr,df);
              tmpDefVar:=NIL;
              IF n=-1 THEN tmpDefVar:=GetDefField(tmpStr,df);
              IF (n=-1) AND (tmpDefVar=NIL) THEN
                BEGIN
                  ReportError(translate(22758,'Unknown field- or variablename to the left of the equal-sign'));  //'Unknown field- or variablename to the left of the equal-sign'
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
          CurCommand:=FParser.GetToken(nwSameKeepQuotes);  //  NextWord(nwSameKeepQuotes);
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
            CurCommand:=FParser.GetToken(nwAny);  //  NextWord(nwAny);
            IF AnsiUpperCase(CurCommand)<>'THEN' THEN
              BEGIN
                ReportError(translate(22760,'No THEN found after IF'));  //'No THEN found after IF'
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
              CurCommand:=FParser.GetToken(nwAny);  //NextWord(nwAny);
              IF AnsiUpperCase(CurCommand)='ELSE' THEN
                BEGIN
                  SeenElse:=True;
                  CurCommand:='ELSE'
                END;
              IF SeenElse THEN GetCommand(tmpCmdRec.ElseCmds)
              ELSE GetCommand(tmpCmdRec.IfCmds);
            UNTIL (AnsiUpperCase(CurCommand)='ENDIF') OR (FParser.EndOfLines)
            OR (AnsiUpperCase(CurCommand)='END');
            IF (FParser.EndOfLines) AND (AnsiUpperCase(CurCommand)<>'ENDIF') THEN
              BEGIN
                ReportError(translate(22762,'IF..THEN command without ENDIF'));   //'IF..THEN command without ENDIF'
                ok:=False;
              END;
            IF AnsiUpperCase(CurCommand)='END' THEN
              BEGIN
                ReportError(translate(22764,'ENDIF expected but END found'));  //'ENDIF expected but END found'
                ok:=False;
              END;
            CurCommand:='';
          END;
      END;
    cmdHelp:
      BEGIN
        CurCommand:=FParser.GetToken(nwSameLine);  // NextWord(nwSameLine);
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
        CurCommand:=FParser.GetUpperToken(nwSameLine); //   AnsiUpperCase(NextWord(nwSameLine));
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
        THEN CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
        tmpS:='';
        WHILE CurCommand<>'' DO
          BEGIN
            tmpS:=tmpS+CurCommand;
            CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
          END;
        IF (tmpS='TYPE=ERROR') OR (tmpS='TYPE=E') THEN tmpCmdRec.HelpType:=mtError
        ELSE IF (tmpS='TYPE=WARNING') OR (tmpS='TYPE=W') THEN tmpCmdRec.HelpType:=mtWarning
        ELSE IF (tmpS='TYPE=CONFIRMATION') OR (tmpS='TYPE=C') THEN tmpCmdRec.HelpType:=mtConfirmation;
        CurCommand:='';
      END;  //case cmdHelp
    cmdHide,cmdUnhide,cmdClear,cmdGoto:
      BEGIN
        {Check if a fieldname exists after command}
        ok:=True;
        CurCommand:=FParser.GetUpperToken(nwSameLine); // AnsiUpperCase(NextWord(nwSameLine));
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
                    IF CurCommand=AnsiUpperCase(trim(PeField(df^.FieldList.Items[n])^.FName))
                    THEN Found:=True;
                  END;
                IF (NOT Found) AND (CurCommand='COMMENT') THEN
                  BEGIN
                    CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
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
                    ReportError(translate(22708,'Unknow fieldname.'));  //'Unknow fieldname.'
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
        CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
        IF CurCommand='' THEN
          BEGIN
            ok:=False;
            ReportError(translate(22766,'DEFINE without variablename'));  //'DEFINE without variablename'
          END
        ELSE IF Length(CurCommand)>16 THEN
          BEGIN
            ok:=False;
            ReportError(translate(22768,'Variablename can be only 16 characters in DEFINE'));  //'Variablename can be only 16 characters in DEFINE'
          END
        ELSE IF GetFieldNumber(CurCommand,df)<>-1 THEN
          BEGIN
            ok:=False;
            ReportError(translate(22770,'Dublicate name: The variablename is used by a entryfield'));  //'Dublicate name: The variablename is used by a entryfield'
          END;
        {ELSE IF (GetDefField(CurCommand,df)<>NIL) AND (MultiLineError) THEN
          BEGIN
            ok:=False;
            ReportError(translate(22772,'Dublicate name: The variablename is allready used'));  //'Dublicate name: The variablename is allready used'
          END;}
        IF ok THEN
          BEGIN
            tmpCmdRec.FName:=CurCommand;
            tmpCmdRec.FNumDecimals:=0;
            //Variable name passed all tests - now get the fieldtype
            CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
            IF CurCommand='' THEN
              BEGIN
                ok:=False;
                ReportError(translate(22774,'Fieldtype missing in DEFINE command'));  //'Fieldtype missing in DEFINE command'
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
                        ReportError(translate(22776,'Error in fieldtype. Use # and maximum one . to define numeric'));  //'Error in fieldtype. Use # and maximum one . to define numeric'
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
                    ReportError(translate(22778,'Illegal fieldtype in DEFINE command'));  //'Illegal fieldtype in DEFINE command'
                  END;
                IF ok THEN
                  BEGIN
                    CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
                    IF CurCommand='' THEN tmpCmdRec.FScope:=scLocal
                    ELSE IF CurCommand[1]='G' THEN tmpCmdRec.FScope:=scGlobal
                    ELSE IF CurCommand[1]='C' THEN tmpCmdRec.FScope:=scCumulative
                    ELSE
                      BEGIN
                        ok:=False;
                        ReportError(translate(22780,'Illegal scope in DEFINE command. Use GLOBAL or CUMULATIVE'));  //'Illegal scope in DEFINE command. Use GLOBAL or CUMULATIVE'
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
                            IF (tmpCmdRec.FScope<>scGlobal) OR (tmpDefVar^.FScope<>scGlobal) AND (FMultiLineError) THEN
                              BEGIN
                                ok:=False;
                                ReportError(translate(22772,'Dublicate name: The variablename is allready used'));  //'Dublicate name: The variablename is allready used'
                              END;
                            IF (tmpCmdRec.FScope=scGlobal) AND (tmpDefVar^.FScope=scGlobal) THEN
                              BEGIN
                                IF NOT ( (tmpCmdRec.Felttype=tmpDefVar^.Felttype)       AND
                                     (tmpCmdRec.FLength=tmpDefVar^.FLength)             AND
                                     (tmpCmdRec.FNumDecimals=tmpDefVar^.FNumDecimals) ) THEN
                                  BEGIN
                                    ok:=False;
                                    ReportError(translate(22773,'A global DEFINE with same fieldname but different fieldtype or length is allready defined'));   //22773=A global DEFINE with same fieldname but different fieldtype or length is allready defined
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
    cmdDefaultAll:
      BEGIN
        //Syntax DEFAULTVALUE ALL|ALLSTRINGS|ALLSTRING|ALLNUMERIC x    eller
        //       DEFAULTVALUE field-field, field, field  X
        CurCommand:=FParser.GetUpperToken(nwSameLine);
        IF (CurCommand='ALL') OR (CurCommand='ALLSTRINGS') OR (CurCommand='ALLSTRING') or (CurCommand='ALLNUMERIC') THEN
          BEGIN
            tmpS:=CurCommand;
            CurCommand:=FParser.GetToken(nwSameLine);
            IF CurCommand='' THEN
              BEGIN
                ok:=false;
                ReportError('The default value must follow DEFAULTVALUE ALL');
              END
            ELSE
              BEGIN
                df^.GlobalDefaultValue:=CurCommand;
                for n:=0 TO df^.FieldList.Count-1 DO
                  BEGIN
                    IF (PeField(df^.FieldList.items[n])^.Felttype in [ftInteger,ftAlfa,ftUpperAlfa,ftFloat,ftCrypt]) THEN
                      BEGIN
                        IF (tmpS='ALL') THEN PeField(df^.FieldList.Items[n])^.FHasGlobalDefaultValue:=true
                        ELSE IF (PeField(df^.FieldList.Items[n])^.Felttype in [ftAlfa,ftUpperAlfa,ftCrypt]) AND ((tmpS='ALLSTRINGS') OR (tmpS='ALLSTRING')) THEN PeField(df^.FieldList.Items[n])^.FHasGlobalDefaultValue:=true
                        ELSE IF (PeField(df^.FieldList.Items[n])^.Felttype in [ftInteger,ftFloat]) AND (tmpS='ALLNUMERIC') THEN PeField(df^.FieldList.Items[n])^.FHasGlobalDefaultValue:=true;
                      END;   //if relevant fieldtype
                  END;  //for
              END
          END
        ELSE
          BEGIN
            //Syntax DEFAULTVALUE field-field, field, field X Y Z is used
            s1:=trim(FParser.GetWholeLine);
            s1:=copy(s1,14,length(s1));    //remove the word DEFAULTVALUE
            TRY
              tmpList1:=TStringList.Create;
              tmpList1.CommaText:=s1;
              IF (tmpList1.Count<2) THEN
                begin
                  ok:=false;
                  ReportError('DEFAULTVALUE must be followed by ALL or at least one fieldname and a default value');
                end
              else
                begin
                  tmpS:=tmpList1[tmpList1.count-1];
                  df^.GlobalDefaultValue:=tmpS;
                end;
              IF ok THEN
                BEGIN
                  FOR n:=0 TO tmpList1.Count-2 DO
                    BEGIN
                      //Traverse the list of fields
                      IF pos('-',tmpList1[n])>0 THEN   //is element a field-interval?
                        BEGIN
                          s1:=copy(tmpList1[n],1,pos('-',tmpList1[n])-1);  //get interval start
                          s2:=copy(tmpList1[n],pos('-',tmpList1[n])+1,length(tmpList1[n]));  //get interval end
                          fieldFrom:=GetFieldNumber(s1,df);
                          fieldTo:=GetFieldNumber(s2,df);
                          IF (fieldFrom=-1) OR (fieldTo=-1) THEN
                            BEGIN
                              IF fieldFrom=-1 THEN ReportError(translate(22708,'Unknown field name')+' '+s1);  //22708=Unknown field name
                              IF fieldTo=-1 THEN ReportError(translate(22708,'Unknown field name')+' '+s2);
                              ok:=False;
                              break;
                            END
                          ELSE
                            BEGIN
                              FOR n2:=fieldFrom TO fieldTo DO
                                BEGIN
                                  AField:=PeField(df^.FieldList.Items[n2]);
                                  IF (AField^.Felttype<>ftQuestion) THEN
                                    BEGIN
                                      AField^.FDefaultValue:=tmpS;
                                      AField^.FHasGlobalDefaultValue:=true;
                                    END;  //if not question field
                                END;  //for
                            END;  //if all fields are known
                        END  //if interval
                      ELSE
                        BEGIN    //element is a single fieldname
                          fieldFrom:=GetFieldNumber(tmpList1[n],df);
                          IF fieldFrom=-1 THEN
                            BEGIN
                              ReportError(translate(22708,'Unknown field name')+' '+tmpList1[n]);   //22708=Unknown field name
                              ok:=False;
                            END
                          ELSE
                            BEGIN
                              AField:=PeField(df^.fieldList.Items[fieldFrom]);
                              IF (AField^.Felttype<>ftQuestion) THEN
                                BEGIN
                                  Afield^.FHasGlobalDefaultValue:=True;
                                  AField^.FDefaultValue:=tmpS;
                                END;  //if not question field
                            END;  //if field is found
                        END;  //if single fieldname
                    END;  //for
                END;  //if ok
            FINALLY
              tmpList1.Free;
            END;  //try..finally
          END;
      END;
    cmdMissingAll:
      BEGIN
        //Syntax MISSINGVALUE ALL x [x [x]]
        CurCommand:=FParser.GetUpperToken(nwSameLine);
        IF CurCommand='ALL' THEN
          BEGIN
            CurCommand:=FParser.GetToken(nwSameLine);
            IF CurCommand<>'' THEN
              BEGIN
                IF (NOT IsInteger(CurCommand)) THEN ok:=False
                ELSE df^.GlobalMissingValues[0]:=CurCommand;
              END;
            CurCommand:=FParser.GetToken(nwSameLine);
            IF CurCommand<>'' THEN
              BEGIN
                IF (NOT IsInteger(CurCommand)) THEN ok:=False
                ELSE df^.GlobalMissingValues[1]:=CurCommand;
              END;
            CurCommand:=FParser.GetToken(nwSameLine);
            IF CurCommand<>'' THEN
              BEGIN
                IF (NOT IsInteger(CurCommand)) THEN ok:=False
                ELSE df^.GlobalMissingValues[2]:=CurCommand;
              END;
            IF (NOT ok) THEN ReportError(translate(22876,'Only numbers can be used as MISSINGVALUES ALL'));   //22876=Only numbers can be used as MISSINGVALUES ALL
          END
        ELSE
          BEGIN
            //Syntax MISSINGVALUE field-field, field, field X Y Z is used
            s1:=trim(FParser.GetWholeLine);
            s1:=copy(s1,14,length(s1));    //remove the word MISSINGVALUE
            TRY
              tmpList1:=TStringList.Create;
              tmpList1.CommaText:=s1;
              NumValues:=0;
              n:=tmpList1.Count-1;
              Found:=False;
              REPEAT
                IF IsInteger(tmpList1[n]) THEN INC(NumValues) ELSE Found:=True;
                DEC(n);
              UNTIL (Found=True) OR (n<0);
              IF (NumValues>3) OR (NumValues=0) THEN
                BEGIN
                  ReportError(translate(22878,'One to three MISSINGVALUEs can be defined'));   //22878=One to three MISSINGVALUEs can be defined
                  ok:=False;
                END;
              IF NumValues=tmpList1.Count THEN
                BEGIN
                  ReportError(translate(22880,'ALL or fieldnames must follow MISSINGVALUE'));     //'ALL or fieldnames must follow MISSINGVALUE'
                  ok:=False;
                END;
              IF ok THEN
                BEGIN
                  n2:=0;
                  CASE NumValues OF
                    1: mv1:=tmpList1[tmpList1.count-1];
                    2: BEGIN
                         mv1:=tmpList1[tmpList1.count-2];
                         mv2:=tmpList1[tmpList1.count-1];
                       END;
                    3: BEGIN
                         mv1:=tmpList1[tmpList1.Count-3];
                         mv2:=tmpList1[tmpList1.Count-2];
                         mv3:=tmpList1[tmpList1.Count-1];
                       END;
                  END;  //case
                  //FOR n:=tmpList1.Count-NumValues TO tmpList1.Count-1 DO
                  //  BEGIN
                  //    MisValues[n2]:=tmpList1[n];
                  //    INC(n2);
                  //  END;  //for
                  //Get the fieldnames / fieldintervals
                  FOR n:=0 TO tmpList1.Count-NumValues-1 DO
                    BEGIN
                      //Traverse the list of fields
                      IF pos('-',tmpList1[n])>0 THEN   //is element a field-interval?
                        BEGIN
                          s1:=copy(tmpList1[n],1,pos('-',tmpList1[n])-1);  //get interval start
                          s2:=copy(tmpList1[n],pos('-',tmpList1[n])+1,length(tmpList1[n]));  //get interval end
                          fieldFrom:=GetFieldNumber(s1,df);
                          fieldTo:=GetFieldNumber(s2,df);
                          IF (fieldFrom=-1) OR (fieldTo=-1) THEN
                            BEGIN
                              IF fieldFrom=-1 THEN ReportError(translate(22708,'Unknown field name')+' '+s1);  //22708=Unknown field name
                              IF fieldTo=-1 THEN ReportError(translate(22708,'Unknown field name')+' '+s2);
                              ok:=False;
                              break;
                            END
                          ELSE
                            BEGIN
                              FOR n2:=fieldFrom TO fieldTo DO
                                BEGIN
                                  AField:=PeField(df^.FieldList.Items[n2]);
                                  IF (AField^.Felttype in [ftInteger,ftFloat]) THEN
                                    BEGIN
                                      Afield^.FHasGlobalMissing:=True;
                                      CASE NumValues OF
                                        1: AField^.FMissingValues[0]:=mv1;
                                        2: BEGIN
                                             AField^.FMissingValues[1]:=mv2;
                                             AField^.FMissingValues[0]:=mv1;
                                           END;
                                        3: BEGIN
                                             AField^.FMissingValues[2]:=mv3;
                                             AField^.FMissingValues[1]:=mv2;
                                             AField^.FMissingValues[0]:=mv1;
                                           END;
                                      END;  //case
                                      //FOR n3:=0 TO NumValues DO
                                      //  AField^.FMissingValues[n3]:=MisValues[n3];
                                    END;  //if numeric field
                                END;  //for
                            END;  //if all fields are known
                        END  //if interval
                      ELSE
                        BEGIN    //element is a single fieldname
                          fieldFrom:=GetFieldNumber(tmpList1[n],df);
                          IF fieldFrom=-1 THEN
                            BEGIN
                              ReportError(translate(22708,'Unknown field name')+' '+tmpList1[n]);   //22708=Unknown field name
                              ok:=False;
                            END
                          ELSE
                            BEGIN
                              AField:=PeField(df^.fieldList.Items[fieldFrom]);
                              IF (AField^.Felttype in [ftInteger,ftFloat]) THEN
                                BEGIN
                                  //FOR n3:=0 TO NumValues DO
                                  //  AField^.FMissingValues[n3]:=MisValues[n3];
                                  Afield^.FHasGlobalMissing:=True;
                                  CASE NumValues OF
                                    1: AField^.FMissingValues[0]:=mv1;
                                    2: BEGIN
                                         AField^.FMissingValues[1]:=mv2;
                                         AField^.FMissingValues[0]:=mv1;
                                       END;
                                    3: BEGIN
                                         AField^.FMissingValues[2]:=mv3;
                                         AField^.FMissingValues[1]:=mv2;
                                         AField^.FMissingValues[0]:=mv1;
                                       END;
                                  END;  //case

                                END;  //if numeric field
                            END;  //if field is found
                        END;  //if single fieldname
                    END;  //for
                END;  //if ok
            FINALLY
              tmpList1.Free;
            END;  //try..finally
          END;
      END;  //case cmdMissingAll
    cmdIgnoreMissing: MissingAction:=maIgnoreMissing;
    cmdTypeString:
      BEGIN
        {  Syntax: TYPE "text" [colour]  }
        CurCommand:=FParser.GetToken(nwSameLine);  // NextWord(nwSameLine);
        IF AnsiUpperCase(CurCommand)='COMMENT' THEN
          BEGIN
            CurCommand:=FParser.GetUpperToken(nwSameLine);
            IF CurCommand='ALLFIELDS' THEN
              BEGIN
                df^.GlobalTypeCom:=True;
                tmpCmdRec.TypeText:='¤¤typecommentlegalallfields¤¤';
                tmpCmdRec.tsVarNumber:=-1;
                CurCommand:=FParser.GetUpperToken(nwSameLine);   //Get the color
                IF CurCommand<>'' THEN
                  BEGIN
                    FOR n2:=0 TO 17 DO
                      IF CurCommand=ColorNames[n2] THEN df^.GlobalTypeComColor:=n2;
                  END;
              END
            ELSE
              BEGIN
                ReportError(translate(22741,'Command not legal in IF, AFTER ENTRY, and BEFORE ENTRY blocks'));    //'Command not legal in IF, AFTER ENTRY, and BEFORE ENTRY blocks'
                ok:=False;
              END;
          END
        ELSE
          BEGIN
            IF AnsiUpperCase(CurCommand)='STATUSBAR' THEN
              BEGIN
                ReportError(translate(22741,'Command not legal in IF, AFTER ENTRY, and BEFORE ENTRY blocks'));    //'Command not legal in IF, AFTER ENTRY, and BEFORE ENTRY blocks'
                ok:=False;
              END
            ELSE IF CurCommand='' THEN
              BEGIN
                ReportError(translate(22746,'Text to TYPE is missing'));   //'Text to TYPE is missing'
                ok:=False;
              END
            ELSE
              BEGIN
                tmpCmdRec.tsVarNumber:=df^.FocusedField;
                IF Length(CurCommand)>40 THEN tmpCmdRec.TypeText:=Copy(CurCommand,1,40)
                ELSE tmpCmdRec.TypeText:=CurCommand;
                //Get a colour - if present
                CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
                tmpCmdRec.TypeColor:=2;
                IF CurCommand<>'' THEN
                  BEGIN
                    tmpCmdRec.TypeColor:=-1;
                    FOR n:=0 TO 17 DO
                      IF AnsiUppercase(CurCommand)=ColorNames[n] THEN tmpCmdRec.TypeColor:=n;
                    IF tmpCmdRec.TypeColor=-1 THEN
                      BEGIN
                        ReportError(translate(22743,'Unknown colour'));   //'Unknown colour'
                        ok:=False;
                      END;
                    {Read rest of line - compatibility with Epi Info}
                    REPEAT
                      CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
                      tmpS:=tmpS+CurCommand;
                    UNTIL CurCommand='';
                  END;  //if CurCommand<>''
                IF ok THEN tmpField.FTypeString:=True;
              END;
          END;
      END;  //case cmdTypeString
    cmdBeep:
      BEGIN
        CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
        tmpCmdRec.BeepType:=btStandard;
        IF CurCommand<>'' THEN
          BEGIN
            IF (CurCommand='WARNING') OR (CurCommand='W') THEN tmpCmdRec.BeepType:=btWarning
            ELSE IF (CurCommand='CONFIRMATION') OR (CurCommand='C') THEN tmpCmdRec.BeepType:=btConfirmation;
          END;
      END;  //cmdBeep
    cmdLoad:
      BEGIN
        {Syntax: LOAD [path\]dllname[.dll]}
        CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
        IF Length(Curcommand)>200 THEN CurCommand:=Copy(CurCommand,1,200);
        IF CurCommand='' THEN
          BEGIN
            ReportError(Format(translate(22126,'The file %s does not exist.'),[CurCommand]));   //22126=The file %s does not exist.
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
                ReportError(Format(translate(22126,'The file %s does not exist.'),[tmpS]));   //22126=The file %s does not exist.
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
        {Syntax: WRITENOTE "notetext" [SHOW]}
        CurCommand:=FParser.GetToken(nwSameLine);   //NextWord(nwSameLine);
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
        CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
        IF CurCommand='SHOW' THEN tmpCmdRec.ShowNotes:=True ELSE tmpCmdRec.ShowNotes:=False;
      END;
    cmdCopyToClipboard:
      BEGIN
        {Syntax: COPYTOCLIPBOARD "text @variable"}
        CurCommand:=FParser.GetToken(nwSameLine);
        IF CurCommand='' THEN
          BEGIN
            ReportError(translate(23028,'Invalid parameters'));  //23028=Invalid parameters
            OK:=False;
          END;
        tmpCmdRec.CopyStr:=Copy(CurCommand,1,200);
      END;
    cmdShowLastRecord:
      BEGIN
        df^.ShowLastRecord:=True;
      END;
    cmdExecute:
      BEGIN
        {Syntax: EXECUTE "exe-file name"|* "Parameters"|* NOWAIT|WAIT [HIDE]   }
        {
        Execute bla.htm WAIT
        Execute opera bla.htm WAIT

        }
        CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
        IF CurCommand='' THEN
          BEGIN
            ReportError(translate(22854,'Exe-filename or document-filename is required'));  //22854=Exe-filename or document-filename is required
            OK:=False;
          END;
        tmpCmdRec.ExecCmdLine:=CurCommand;    //=InsertFieldContents(df,CurCommand);
        //Read next: can be parameters or NOWAIT|WAIT
        CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
        tmpCmdRec.ExecParams:='';
        IF (AnsiUpperCase(CurCommand)<>'WAIT') AND (AnsiUpperCase(CurCommand)<>'NOWAIT') THEN
          BEGIN
            //Assume CurCommand contains parameter(s)
            tmpCmdRec.ExecParams:=CurCommand;
            CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
          END;
        CurCommand:=AnsiUpperCase(CurCommand);
        IF (CurCommand<>'WAIT') AND (CurCommand<>'NOWAIT') THEN
          BEGIN
            ReportError(translate(22856,'WAIT or NOWAIT is required'));  //22856=WAIT or NOWAIT is required
            ok:=False;
          END
        ELSE tmpCmdRec.ExecWait:=(CurCommand='WAIT');

        IF ok THEN
          BEGIN
            CurCommand:=FParser.GetUpperToken(nwSameLine);  //  ANSIupperCase(NextWord(nwSameLine));
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

        CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
        tmpCmdRec.TxtColor:=255;
        tmpCmdRec.BgColor:=255;
        IF CurCommand='QUESTION' THEN tmpCmdRec.ColorCmd:=1
        ELSE IF CurCommand='DATA' THEN tmpCmdRec.ColorCmd:=2
        ELSE IF CurCommand='BACKGROUND' THEN tmpCmdRec.ColorCmd:=3
        ELSE
          BEGIN
            //could be COLOR fieldname
            //will be added later
            ReportError(translate(22858,'Unknown COLOR command'));  //22858=Unknown COLOR command
            ok:=False;
          END;
        IF tmpCmdRec.ColorCmd=3 THEN
          BEGIN
            //command is BACKGROUND
            CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
            IF IsInteger(CurCommand) THEN
              BEGIN
                tmpCmdRec.IsEpiInfoNo:=True;
                n:=StrToInt(CurCommand);
                IF (n<0) OR (n>7) THEN
                  BEGIN
                    ReportError(translate(22860,'Illegal COLOR number'));   //22860=Illegal COLOR number
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
                    ReportError(translate(22858,'Unknown COLOR command'));  //22858=Unknown COLOR command
                    ok:=False;
                  END;
              END;
          END
        ELSE
          BEGIN
            //read rest of line
            tmpS:='';
            REPEAT
              CurCommand:=FParser.GetUpperToken(nwSameLine);  //  AnsiUpperCase(NextWord(nwSameLine));
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
                ReportError(translate(22862,'Unknown color in COLOR command'));  //22862=Unknown color in COLOR command
                ok:=False;
              END;
          END;
      END;
    cmdBackup:
      BEGIN
        {syntax: BACKUP "destination-library" [ZIP filename [date]]
         or      BACKUP "destination-library" [ENCRYPT filname password [date]] }
        IF (CheckFileMode) AND (cmdList<>df^.AfterFileCmds) THEN
          BEGIN
            ReportError(translate(22864,'BACKUP command only legal in AFTER FILE blocks'));  //22864=BACKUP command only legal in AFTER FILE blocks
            ok:=False;
          END
        ELSE
          BEGIN
            CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
            IF CurCommand='' THEN
              BEGIN
                ReportError(translate(22866,'BACKUP command without destination directory'));  //22866=BACKUP command without destination directory
                ok:=False;
              END
            ELSE IF (df^.BackupList=NIL) AND (NOT df^.IsRelateFile) THEN
              BEGIN
                tmpCmdRec.zipit:=False;
                tmpCmdrec.encryptit:=False;
                tmpCmdRec.DestLib:=CurCommand;
                CurCommand:=FParser.GetUpperToken(nwSameLine);
                IF (CurCommand<>'ZIP') AND (CurCommand<>'ENCRYPT') THEN
                  BEGIN
                    df^.BackupList:=TStringList.Create;
                    df^.BackupList.Append(tmpCmdRec.DestLib);
                    df^.BackupList.Append(df^.RECFilename);
                  END
                ELSE
                  BEGIN
                    //ZIP or ENCRYPT added as parameters
                    IF CurCommand='ZIP' THEN
                      BEGIN
                        CurCommand:=FParser.GetToken(nwSameLine);   //get the filename
                        IF CurCommand='' THEN
                          BEGIN
                            ReportError(translate(22884,'Filename needed after ZIP'));   //'Filename needed after ZIP'
                            ok:=False;
                          END
                        ELSE
                          BEGIN
                            df^.BackupList:=TStringList.Create;
                            df^.BackupList.Append(tmpCmdRec.DestLib);
                            tmpCmdRec.zipit:=True;
                            tmpCmdrec.filename:=ExtractFilename(CurCommand);
                            CurCommand:=FParser.GetUpperToken(nwSameLine);   //get date parameter
                            IF CurCommand='DATE' THEN tmpCmdRec.dateit:=True;
                          END;
                      END
                    ELSE
                      BEGIN
                        //encrypt it
                        CurCommand:=FParser.GetToken(nwSameLine);   //get the filename
                        IF CurCommand='' THEN
                          BEGIN
                            ReportError(translate(22886,'Filename needed after ENCRYPT'));   //'Filename needed after ENCRYPT'
                            ok:=False;
                          END
                        ELSE
                          BEGIN
                            tmpCmdRec.encryptit:=True;
                            tmpCmdRec.filename:=ExtractFilename(CurCommand);
                            CurCommand:=FParser.GetToken(nwSameLine);   //get the password
                            IF CurCommand='' THEN
                              BEGIN
                                ReportError(translate(22888,'Password must follow ENCRYPT and filename'));  //'Password must follow ENCRYPT and filename'
                                ok:=False;
                              END
                            ELSE
                              BEGIN
                                df^.BackupList:=TStringList.Create;
                                df^.BackupList.Append(tmpCmdRec.DestLib);
                                tmpCmdRec.pw:=CurCommand;
                                CurCommand:=FParser.GetUpperToken(nwSameLine);  //get date parameter
                                IF CurCommand='DATE' THEN tmpCmdRec.dateit:=True;
                              END;
                          END;
                      END;
                  END;  //if zip or encrypt
              END;  //if ok to create backuplist
          END;  //if in afterfile
      END;  //end case cmdBackup
    cmdRelate:
      BEGIN
        //Syntax: RELATE fieldname filename [1]
        //Get fieldname
        CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
        IF CurCommand='' THEN
          BEGIN
            ReportError(translate(22840,'Error in RELATE command'));   //'Error in RELATE command'
            ok:=False;
          END
        ELSE
          BEGIN
            n:=GetFieldNumber(CurCommand,df);
            IF n=-1 THEN
              BEGIN
                ReportError(translate(22708,'Unknown fieldname'));   //'Unknown fieldname'
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
                    IF tmpField^.Felttype=ftIDNUM THEN tmpS2:='. IDNUM fields must also be declared KEY UNIQUE' ELSE tmpS2:='';
                  END
                ELSE
                  BEGIN
                    n2:=PeField(df^.FieldList.Items[n])^.FIndex;
                    IF n2=0 THEN ok:=False
                    ELSE IF df^.IndexIsUnique[n2]=False THEN ok:=False;
                    IF PeField(df^.FieldList.Items[n])^.Felttype=ftIDNUM THEN tmpS2:='. IDNUM fields must also be declared KEY UNIQUE' ELSE tmpS2:='';
                  END;
                IF NOT ok THEN
                  begin
                    tmpS:=translate(22842,'RELATE field must be KEY UNIQUE')+'. Key Unique command must preceed relate command'+tmpS2;
                    ReportError(tmpS);  //'RELATE field must be KEY UNIQUE'
                  end;
              END;
          END;
        IF ok THEN
          BEGIN
            //Get relatefile name
            tmpCmdRec.RelField:=PeField(df^.FieldList.Items[n])^.FName;  //save fieldname
            n2:=n;  //save fieldnumber to use with relateinfo
            Curcommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
            IF CurCommand='' THEN
              BEGIN
                ReportError(translate(22840,'Error in RELATE command'));   //'Error in RELATE command'
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
                IF (NOT FileExists(tmpS)) AND (FMultiLineError) THEN
                  BEGIN
                    ReportError(Format(translate(22126,'The file %s does not exist.'),[tmpS]));   //22126=The file %s does not exist.
                    ok:=False;
                  END
                ELSE
                  BEGIN
                    IF NOT Assigned(RelateFiles) THEN RelateFiles:=TStringList.Create;
                    IF NOT Assigned(RelateMothers) THEN RelateMothers:=TList.Create;
                    n:=RelateFiles.IndexOf(tmpS);    //mib 10jan06
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
            CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
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
      FTempResult:=False;
      IF cmd=cmdIF THEN
        BEGIN
          IF tmpCmdRec.IfCmds<>NIL THEN DestroyFieldList(tmpCmdRec.IfCmds);
          IF tmpCmdRec.ElseCmds<>NIL THEN DestroyFieldList(tmpCmdRec.ElseCmds);
        END;
    END;
END;  //GetCommand


Procedure TCheckObj.AddTopComment;
VAR
  s: String;
BEGIN
  s:=FParser.GetWholeLine;
  IF (FCheckFileMode) AND (Assigned(df^.ChkTopComments)) THEN df^.ChkTopComments.Append(s);
END;  //Procedure AddTopComment


Procedure TCheckObj.RetrieveFlawBlock;
VAR
  s: String;
BEGIN
  IF NOT FCheckFileMode THEN FTempResult:=False;
  CommentsAddedToCheckFile:=True;
  s:=FParser.GetLineAndFlush;
  ReportError(translate(22732,'Unknown command in line'));  //'Unknown command in line'
  IF (FirstTopFlaw) AND (FCheckFileMode) AND (FMultiLineError) THEN
    BEGIN
      FirstTopFlaw:=False;
      {$IFNDEF epidat}
      IF eDlg(Format(translate(22788,'Unknown fieldname found in checkfile %s'),   //'Unknown fieldname found in checkfile %s'
         [ExtractFilename(df^.CHKFilename)])+#13#13+
         translate(22790,'Do you want to save the checks of the unknown fieldname~as commentlines in the checkfile?')+#13#13+  //'Do you want to save the checks of the unknown fieldname~as commentlines in the checkfile?'
         translate(22792,'If you choose No the checks of the unknown fieldname will~be deleted when the revised checks are saved.'),   //'If you choose No the checks of the unknown fieldname will~be deleted when the revised checks are saved.'
         mtWarning,[mbYes,mbNo],0)=mrYes THEN SaveTopFlawsAsComments:=True;
      Screen.Cursor:=crHourGlass;
      {$ENDIF}
    END;  //FirstTopFlaw
  REPEAT
    IF SaveTopFlawsAsComments THEN
      BEGIN
        FParser.CommentCurLine;
        AddTopComment;
      END;
    CurCommand:=FParser.GetToken(nwAny);  // NextWord(nwAny);
    s:=FParser.GetLineAndFlush;
  UNTIL (FParser.EndOfLines) or (AnsiUpperCase(CurCommand)='END');
  IF AnsiUpperCase(CurCommand)='END' THEN
    BEGIN
      FParser.CommentCurLine;
      AddTopComment;
    END;
END;  //procedure RetrieveFlawBlock


Procedure TCheckObj.RetrieveRange;
VAR
  tmpS:String;
  RangeResult:Boolean;
BEGIN
  RangeResult:=True;
  {Get minimum value}
  CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
  IF CurCommand='' THEN
    BEGIN
      {$IFNDEF epidat}
      ReportError(translate(22712,'RANGE command without mininum value'));   //'RANGE command without mininum value'
      {$ENDIF}
      RangeResult:=False;
    END
  ELSE tmpField^.FMin:=CurCommand;
  IF tmpField^.FMin='-INFINITY' THEN tmpField^.FMin:='';
  {Get maxinum value}
  CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
  IF CurCommand='' THEN
    BEGIN
      {$IFNDEF epidat}
      ReportError(translate(22714,'RANGE command without maximum value'));  //'RANGE command without maximum value'
      {$ENDIF}
      RangeResult:=False;
    END
  ELSE tmpField^.FMax:=CurCommand;
  IF tmpField^.FMax='INFINITY' THEN tmpField^.FMax:='';

  {Check if range values are compliant with fieldtype}
  IF (tmpField^.FMin<>'') AND (NOT IsCompliant(tmpField^.FMin,tmpField^.Felttype)) THEN
    BEGIN
      {$IFNDEF epidat}
      ReportError(translate(22716,'Minimum value is not compatible with this type of field'));  //'Minimum value is not compatible with this type of field'
      {$ENDIF}
      RangeResult:=False;
    END;
  IF (RangeResult) AND (tmpField^.FMax<>'') AND (NOT IsCompliant(tmpField^.FMax,tmpField^.Felttype)) THEN
    BEGIN
      {$IFNDEF epidat}
      ReportError(translate(22718,'Maximum value is not compatible with this type of field'));  //'Maximum value is not compatible with this type of field'
      {$ENDIF}
      RangeResult:=False;
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
  ELSE FTempResult:=False;
  CurCommand:='';
END;  //function RetrieveRange


Procedure TCheckObj.RetrieveLegals;
VAR
  StopGet,LegalResult,UsedUse,FirstLegalResult:Boolean;
  n: Integer;
  s: string;
BEGIN
  UsedUse:=False;
  StopGet:=False;
  LegalResult:=True;
  FirstLegalResult:=True;
  LegList.Clear;
  REPEAT   //until StopGet
    IF NOT FParser.EndOfLines THEN CurCommand:=FParser.GetToken(nwAny)  //  NextWord(nwAny)
    ELSE
      BEGIN   //EndOfChkFile found before END
        {$IFNDEF epidat}
        ReportError(translate(22704,'Missing END of LEGAL-block.'));   //'Missing END of LEGAL-block.'
        {$ENDIF}
        LegalResult:=False;
        StopGet:=True;
      END;
    IF AnsiUpperCase(CurCommand)='END' THEN StopGet:=True
    ELSE IF AnsiUpperCase(CurCommand)='USE' THEN
      BEGIN
        //LEGAL USE structure
        CurCommand:=AnsiLowerCase(FParser.GetToken(nwSameLine));  //AnsiLowerCase(NextWord(nwSameLine));
        s:='';
        {$IFNDEF epidat}
        IF CurCommand='' THEN s:=translate(22706,'LEGAL USE command without fieldname');  //'LEGAL USE command without fieldname'
        n:=FFieldNameList.IndexOf(AnsiUpperCase(CurCommand));
        IF n=-1 THEN s:=translate(22708,'Unknown fieldname');  //'Unknown fieldname'
        {$ELSE}
        IF CurCommand='' THEN s:='LEGAL USE command without fieldname';
        n:=FFieldNameList.IndexOf(AnsiUpperCase(CurCommand));
        IF n=-1 THEN s:='Unknown fieldname';       //22708=Unknown field name
        {$ENDIF}
        IF s<>'' THEN
          BEGIN
            ReportError(s);
            FTempResult:=False;
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
    ELSE IF CurCommand<>'' THEN
      BEGIN
        IF IsCompliant(CurCommand,PeField(df^.FieldList.Items[df^.FocusedField])^.FeltType)
        THEN LegList.Add(CurCommand)
        ELSE
          BEGIN
            {$IFNDEF epidat}
            ReportError(translate(22710,'Legal value is not compatible with this fieldtype'));  //'Legal value is not compatible with this fieldtype'
            {$ENDIF}
            LegalResult:=False;
          END;
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
  ELSE FTempResult:=False;
  CurCommand:='';
END;  //function RetrieveLegals


Procedure TCheckObj.RetrieveAutoJump;
BEGIN
  CurCommand:=FParser.GetUpperToken(nwSameLine);   // AnsiUpperCase(NextWord(nwSameLine));
  IF CurCommand='' THEN
    BEGIN
      ReportError(translate(22728,'AUTOJUMP command without name of field to jump to'));  //'AUTOJUMP command without name of field to jump to'
      FTempResult:=False;
    END;

  IF (FFieldNameList.IndexOf(CurCommand)=-1) AND (CurCommand<>'END')
  AND (CurCommand<>'WRITE') AND (CurCommand<>'SKIPNEXTFIELD') THEN
    BEGIN
      ReportError(translate(22730,'Unknown fieldname in AUTOJUMP command'));  //'Unknown fieldname in AUTOJUMP command'
      FTempResult:=False;
    END
  ELSE tmpField^.FJumps:='AUTOJUMP '+CurCommand;
  CurCommand:='';
END;  //procedure RetrieveAutojump


Procedure TCheckObj.RetrieveJumps;
VAR
  JumpsResult,StopGet:Boolean;
  tmpS: String;
BEGIN
  StopGet:=False;
  JumpsResult:=True;
  LegList.Clear;
  REPEAT   //until StopGet
    tmpS:='';
    {Check if a RESET command exists after JUMPS}
    CurCommand:=FParser.GetToken(nwSameLine);   //  NextWord(nwSameLine);
    IF CurCommand<>'' THEN
      BEGIN
        IF AnsiUpperCase(CurCommand)<>'RESET' THEN
          BEGIN
            {$IFNDEF epidat}
            ReportError(Format(translate(22830,'RESET expected but %s found'),[CurCommand]));   //'RESET expected but %s found'
            {$ENDIF}
            Jumpsresult:=False;
            StopGet:=True;
          END
        ELSE
          BEGIN
            tmpField^.FJumpResetChar:=#32;
            CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
            IF Length(CurCommand)=1 THEN tmpField^.FJumpResetChar:=CurCommand[1];
          END;
      END;
    {Read value}
    IF NOT FParser.EndOfLines THEN CurCommand:=FParser.GetUpperToken(nwAny)  //AnsiUpperCase(NextWord(nwAny))
    ELSE
      BEGIN   //EndOfChkFile found before END
        {$IFNDEF epidat}
        ReportError(translate(22720,'Missing END of JUMPS-block'));  //'Missing END of JUMPS-block'
        {$ENDIF}
        JumpsResult:=False;
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

        {$IFNDEF epidat}
        IF NOT JumpsResult THEN ReportError(translate(22722,'Illegal datatype'));  //'Illegal datatype'
        {$ENDIF}

        {Get name of field to jump to}
        IF NOT FParser.EndOfLines THEN CurCommand:=FParser.GetToken(nwSameLine)  // NextWord(nwSameLine)
        ELSE
          BEGIN   //EndOfChkFile found before END
            {$IFNDEF epidat}
            ReportError(translate(22724,'Jumps command without field to jump to'));  //'Jumps command without field to jump to'
            {$ENDIF}
            JumpsResult:=False;
            StopGet:=True;
          END;

        IF (JumpsResult) AND (FFieldNameList.IndexOf(CurCommand)=-1) THEN
          BEGIN
            IF AnsiLowerCase(CurCommand)='end' THEN CurCommand:='END'
            ELSE IF AnsiLowerCase(CurCommand)='write' THEN CurCommand:='WRITE'
            ELSE IF AnsiLowerCase(CurCommand)='skipnextfield' THEN Curcommand:='SKIPNEXTFIELD';
            IF (CurCommand<>'END') AND (CurCommand<>'WRITE') AND (CurCommand<>'SKIPNEXTFIELD') THEN
              BEGIN
                {$IFNDEF epidat}
                ReportError(translate(22726,'Unknown fieldname in JUMP block'));  //'Unknown fieldname in JUMP block'
                {$ENDIF}
                JumpsResult:=False;
                StopGet:=True;
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
  ELSE FTempResult:=False;
  CurCommand:='';
END;  //Procedure RetrieveJumps

procedure TCheckObj.RetrieveMissingValues;
VAR
  s1,s2,s3: str15;
BEGIN
  //Syntax:  MISSINGVALUE x [x [x]]  where x is str10
  s1:=FParser.GetToken(nwSameLine);
  s2:=FParser.GetToken(nwSameLine);
  s3:=FParser.GetToken(nwSameLine);
  IF (Length(s1)>tmpField^.FLength)
  OR (Length(s2)>tmpField^.FLength)
  OR (Length(s3)>tmpField^.FLength) THEN
    BEGIN
      FTempResult:=False;
      ReportError(translate(22852,'Value is too wide for field'));   //22852=Value is too wide for field
    END;
  IF FTempResult THEN
    BEGIN
      IF ((s1<>'') AND (NOT IsCompliant(s1,tmpField^.Felttype)))
      OR ((s2<>'') AND (NOT IsCompliant(s2,tmpField^.Felttype)))
      OR ((s3<>'') AND (NOT IsCompliant(s3,tmpField^.Felttype))) THEN
        BEGIN
          FTempResult:=False;
          ReportError(translate(22710,'Value is not compatible with this fieldtype'));  //'Value is not compatible with this fieldtype');
        END;
    END;
  IF FTempResult THEN
    BEGIN
      tmpField^.FMissingValues[0]:=s1;
      tmpField^.FMissingValues[1]:=s2;
      tmpField^.FMissingValues[2]:=s3;
    END;
END;  //procedure TCheckObj.RetrieveMissingValues


procedure TCheckObj.RetrieveDefaultValue;
VAR
  s1,s2,s3: str15;
BEGIN
  //Syntax:  DEFAULTVALUE x where x is string
  s1:=FParser.GetToken(nwSameLine);
  IF (length(s1)>tmpField^.FLength) THEN
    BEGIN
      FTempResult:=False;
      ReportError(translate(22852,'Value is too wide for field'));   //22852=Value is too wide for field
    END
  ELSE
    BEGIN
      IF ((s1<>'') AND (NOT IsCompliant(s1,tmpField^.Felttype))) THEN
        BEGIN
          FTempResult:=False;
          ReportError(translate(22710,'Value is not compatible with this fieldtype'));  //'Value is not compatible with this fieldtype');
        END;
    END;
  IF FTempResult THEN tmpField^.FDefaultValue:=s1;
END;  //procedure TCheckObj.RetrieveDefaultValues


Procedure TCheckObj.RetrieveAutosearch;
VAR
  n:Integer;
BEGIN
  tmpField^.FAutoFields:='';
  CurCommand:=FParser.GetUpperToken(nwSameLine);
  IF (CurCommand='LIST') OR (CurCommand='SOUNDEX') THEN
    BEGIN
      IF CurCommand='LIST' THEN tmpField^.FAutoList:=True;
      CurCommand:=FParser.GetUpperToken(nwSameLine);
      IF (CurCommand='LIST') OR (CurCommand='SOUNDEX') THEN
        BEGIN
          IF CurCommand='LIST' THEN tmpField^.FAutoList:=True;
          CurCommand:=FParser.GetUpperToken(nwSameLine);
        END;  //if
    END;  //if
  REPEAT
    IF CurCommand<>'' THEN n:=GetFieldNumber(CurCommand,df)
    ELSE n:=df^.FocusedField;
    IF n=-1 THEN
      BEGIN
        FTempResult:=False;
        ReportError(translate(22708,'Unknown fieldname'));   //'Unknown fieldname'
        Exit;
      END
    ELSE tmpField^.FAutoFields:=tmpField^.FAutoFields+IntToStr(n)+',';
    CurCommand:=FParser.GetToken(nwSameLine);
  UNTIL (CurCommand='') or (FTempResult=False);
  IF tmpField^.FAutoFields[Length(tmpField^.FAutoFields)]=','
  THEN tmpField^.FAutoFields:=Copy(tmpField^.FAutoFields,1,Length(tmpField^.FAutoFields)-1);
  tmpField^.FAutosearch:=True;
END;  //procedure TCheckObj.RetrieveAutosearch


Procedure TCheckObj.RetrieveCommentLegal(VAR AValueLabel:ShortString; VAR ACommentLegalRec: PLabelRec; VAR ShowList:Boolean; AsCommand:Boolean);
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

  ShowList:=False;
  CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
  IF CurCommand<>'LEGAL' THEN
    BEGIN
      ReportError(translate(22732,'Unknown command in line'));  //'Unknown command in line');
      FTempResult:=False;
    END
  ELSE
    BEGIN
      CurCommand:=FParser.GetUpperToken(nwSameLine);  // AnsiUpperCase(NextWord(nwSameLine));
      IF (CurCommand='') OR (CurCommand='SHOW') THEN
        BEGIN
          {1. scenario: COMMENT LEGAL...END Structure}
          IF CurCommand='SHOW' THEN ShowList:=True;
          StopRead:=False;
          ok:=True;
          FirstLabel:=true;
          tmpLabelRec:=NIL;
          FirstLabelRec:=NIL;
          REPEAT
            {Read value}
            CurCommand:=FParser.GetToken(nwAny);  // NextWord(nwAny);
            IF AnsiUpperCase(CurCommand)='END' THEN StopRead:=True
            ELSE IF trim(CurCommand)<>'' THEN
              BEGIN
                s:=trim(CurCommand);
                IF s[1]='*' THEN              //###
                  BEGIN
                    s:=trim(FParser.GetWholeLine);
                    IF NOT FCheckFileMode THEN Continue;
                    IF Length(s)>(30+80) THEN
                      BEGIN
                        ReportError(translate(22874,'Commented line is too long'));   //22874=Commented line is too long
                        StopRead:=True;
                        FTempResult:=False;
                      END
                    ELSE
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
                        tmpLabelRec^.Value:=Copy(s,1,30);
                        IF Length(s)>30 THEN tmpLabelRec^.Text:=Copy(s,31,length(s));
                      END
                  END
                ELSE IF Length(trim(CurCommand))>tmpField^.FLength THEN
                  BEGIN
                    StopRead:=True;
                    FTempResult:=False;
                    ReportError(translate(22852,'Value is too wide for field'));   //22852=Value is too wide for field
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
                    {Read text}
                    CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
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
                  END  //if value is compliant with fieldtype
                ELSE
                  BEGIN
                    StopRead:=True;
                    FTempResult:=False;
                    ReportError(translate(22710,'Value is not compatible with this fieldtype'));  //'Value is not compatible with this fieldtype');
                  END;
              END  //if curCommand<>END and CurCommand<>''
            ELSE
              BEGIN
                StopRead:=True;
                FTempResult:=False;
                ReportError(translate(22734,'Unexpected end of COMMENT LEGAL'));  //'Unexpected end of COMMENT LEGAL'
              END;
          UNTIL StopRead;
          IF FTempResult THEN
            BEGIN
              IF AsCommand THEN
                BEGIN
                  INC(ComLegalCounter);
                  s:='ComLegal'+IntToStr(ComLegalCounter)+'$';
                END
              ELSE
                s:=translate(22736,'labels in field')+' '+   //'labels in field'
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
          CurCommand:=AnsiLowerCase(FParser.GetToken(nwSameLine));  //  AnsiLowerCase(NextWord(nwSameLine));
          s:='';
          IF CurCommand='' THEN s:=translate(22738,'COMMENT LEGAL USE command without labelname or fieldname');  //'COMMENT LEGAL USE command without labelname or fieldname'
          n:=df^.ValueLabels.IndexOf(CurCommand);
          IF n=-1 THEN
            BEGIN
              n:=FFieldNameList.IndexOf(AnsiUpperCase(CurCommand));
              IF n=-1 THEN s:=translate(22740,'Unknown labelname or fieldname') ELSE n:=n+10000;   //'Unknown labelname or fieldname'
            END;
          IF s<>'' THEN
            BEGIN
              ReportError(s);
              FTempResult:=False;
            END
          ELSE
            BEGIN
              s2:=CurCommand;
              CurCommand:=FParser.GetUpperToken(nwSameLine);  //AnsiUpperCase(NextWord(nwSameLine));
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
                  IF ALabelRec^.Value[1]<>'*' THEN   //###
                    BEGIN
                      IF Length(trim(ALabelRec^.Value))>tmpField^.FLength THEN TooLong:=True;
                      IF (NOT IsCompliant(trim(ALabelRec^.Value),tmpField^.Felttype)) THEN NotCompatible:=True;
                    END;
                  ALabelRec:=ALabelRec^.Next
                END;
              IF NotCompatible THEN
                BEGIN
                  StopRead:=True;
                  FTempResult:=False;
                  ReportError(translate(22710,'Value is not compatible with this fieldtype'));  //'Value is not compatible with this fieldtype');
                END  //if NotCompatible
              ELSE IF TooLong THEN
                BEGIN
                  StopRead:=True;
                  FTempResult:=False;
                  ReportError(translate(22852,'Value is too wide for field'));   //22852=Value is too wide for field
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

          IF FCheckFileMode THEN
            BEGIN
              //Don't test if file exists and don't apply index
              CurCommand:=FParser.GetUpperToken(nwSameLine);
              IF CurCommand='SHOW' THEN ShowList:=True;
              AValueLabel:=AnsiLowerCase('Labels from '+ExtractFileName(s));
              New(tmpLabelRec);
              tmpLabelRec^.Next:=NIL;
              ACommentLegalRec:=tmpLabelRec;
            END
          ELSE
            BEGIN
              IF NOT FileExists(s) THEN
                BEGIN
                  ReportError(Format(translate(20110,'Datafile %s does not exist.'),[s]));   //20110=Datafile %s does not exist.
                  FTempResult:=False;
                  //ReportError(translate(22742,'USE expected after COMMENT LEGAL'));  //'USE expected after COMMENT LEGAL'   //*** Obsolete
                END
              ELSE
                BEGIN
                  {Comment Legal datafilename structure found}
                  CurCommand:=FParser.GetUpperToken(nwSameLine);  //AnsiUpperCase(NextWord(nwSameLine));
                  IF CurCommand='SHOW' THEN ShowList:=True;
                  TRY
                    ComLegDf:=NIL;
                    FTempResult:=GetDatafilePointer(ComLegDf);
                    IF FTempResult THEN
                      BEGIN
                        ComLegDf^.RECFilename:=s;
                        ComLegDf^.IndexFilename:=ChangeFileExt(s,'.eix');
                        ComLegDf^.CHKFilename:=ChangefileExt(s,'.chk');
                        FTempResult:=PeekDatafile(ComLegDf);
                      END;
                    IF NOT FTempResult THEN ReportError(Format(translate(20108,'Datafile %s could not be opened'),[s]));  //'Datafile %s could not be opened'
                    IF (FTempResult) AND (ComLegDf^.NumRecords=0) THEN
                      BEGIN
                        FTempResult:=False;
                        ReportError(Format(translate(22334,'Datafile %s does not contain any records'),[s]));   //'Datafile %s does not contain any records'
                      END;
                    IF (FTempResult) AND (NOT FileExists(ComLegDf^.IndexFilename)) THEN
                      BEGIN
                        DisposeDatafilePointer(ComLegDf);
                        GetDatafilePointer(ComLegDf);
                        ComLegDf^.RECFilename:=s;
                        IF NOT DoRebuildIndex(ComLegDf) THEN
                          BEGIN
                            FTempResult:=False;
                            ReportError(Format(translate(20122,'Indexfile not found for the datafile %s'),[s]));  //'Indexfile not found for the datafile %s'
                          END;
                      END;
                    IF FTempResult THEN
                      BEGIN
                        Labelname:=AnsiLowerCase('Labels from '+ExtractFileName(ComLegDf^.RECFilename));
                        n:=df^.ValueLabels.IndexOf(Labelname);
                        IF n>-1 THEN
                          BEGIN
                            {Labels are already loaded}
                            AValueLabel:=df^.ValueLabels[n];
                            ACommentLegalRec:=PLabelRec(df^.ValueLabels.Objects[n]);
                          END
                        ELSE
                          BEGIN
                            {Applyindex, sort index and read records into PLabelRec}
                            AssignFile(F,ComLegdf^.IndexFilename);
                            Reset(F);
                            Read(F,s30);
                            CloseFile(F);
                            {Get number of index fields}
                            s30:=s30+'@';
                            s2:=Copy(s30,1,Pos('@',s30)-1);
                            IF (Length(s2)>0) AND (IsInteger(s2))
                              THEN ComLegDf^.IndexCount:=StrToInt(s2) ELSE FTempResult:=False;
                            IF (ComLegDf^.IndexCount<2) OR (NOT FTempResult) THEN
                              BEGIN
                                FTempResult:=False;
                                ReportError(Format(translate(22832,'Datafile %s must contain two KEY-fields'),[s]));  //'Datafile %s must contain two KEY-fields'
                              END
                            ELSE
                              BEGIN
                                n:=0;
                                REPEAT
                                  INC(n);
                                  Delete(s30,1,Pos('@',s30));
                                  s2:=Copy(s30,1,Pos('@',s30)-1);
                                  IF (Length(s2)=0) OR (NOT IsInteger(s2)) THEN FTempResult:=False;
                                  IF FTempResult THEN ComLegDf^.IndexFields[n]:=StrToInt(s2);
                                UNTIL (n=ComLegDf^.IndexCount) or (NOT FTempResult);
                                IF FTempResult THEN
                                  BEGIN
                                    ValueField:=PeField(ComLegDf^.FieldList.Items[ComLegDf^.IndexFields[1]]);
                                    TextField:= PeField(ComLegDf^.FieldList.Items[ComLegDf^.IndexFields[2]]);
                                  END
                                ELSE ReportError(Format(translate(20128,'Error reading index file %s')+#13+translate(22834,'Rebuild index'),[ComLegDf^.RECFilename]));   //'Error in indexfile of %s. Rebuild index.'
                              END;
                            IF FTempResult THEN
                              BEGIN
                                FTempResult:=ApplyIndex(ComLegDf);
                                IF NOT FTempResult THEN ReportError(Format(translate(20128,'Error reading index file %s')+#13+translate(22834,'Rebuild index'),[ComLegDf^.RECFilename]))   //'Error in indexfile of %s. Rebuild index.'
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
                                        tmpLabelRec^.Text:= Copy(TextField^.FFieldText,1,80);
                                      END;  //for CurRec
                                    df^.ValueLabels.AddObject(Labelname,TObject(FirstLabelRec));
                                    AValueLabel:=Labelname;
                                    ACommentLegalRec:=FirstLabelRec;
                                    CloseFile(F2);
                                  END;
                              END;
                          END;  {if apply index}
                      END;  //if indexfile could be opened
                    DisposeDatafilePointer(ComLegDf);
                  EXCEPT
                    ReportError(Format(translate(22836,'Datafile %s could not be applied as a comment legal.~This could be caused by low memory'),[s]));   //'Datafile %s could not be applied as a comment legal.~This could be caused by low memory'
                    {$I-}
                    CloseFile(F);
                    n:=IOResult;
                    {$I+}
                    FTempResult:=False;
                    CurCommand:='';
                    DisposeDatafilePointer(ComLegDf);
                    Exit;
                  END;  //try..except
                END;  //if Comment Legal Datafilename
            END;  //if not in checkfilemode
        END;   //if Not Comment legal..end and not comment legal use
    END;  //the word LEGAL was found
  CurCommand:='';
END;   //RetrieveCommentLegal


Procedure TCheckObj.RetrieveType;
VAR
  rN,nn:Integer;
  tmpS: string;
BEGIN
  {Handles TYPE COMMENT, TYPE COMMENT fieldname, TYPE STATUSBAR}
  CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
  IF CurCommand='' THEN
    BEGIN
      ReportError(translate(22744,'Illegal syntax in TYPE command'));  //'Illegal syntax in TYPE command'
      FTempResult:=False;
    END
  ELSE
    BEGIN
      IF AnsiUpperCase(CurCommand)='STATUSBAR' THEN
        BEGIN
          tmpField^.FIsTypeStatusBar:=True;
          CurCommand:=FParser.GetToken(nwSameLine);  //  NextWord(nwSameLine);
          df^.TypeStatusBarText:=CurCommand;
          df^.TypeStatusBarColor:=2;   //clBlue;
          CurCommand:=FParser.GetToken(nwSameLine); //   NextWord(nwSameLine);
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
                     TYPE COMMENT fieldname
                     TYPE COMMENT ALLFIELDS}
          tmpField^.FTypeComments:=True;
          tmpField^.FTypeColor:=2;   //clBlue
          {Next word can be either a fieldname or a colour}
          {if not a fieldname then next word is interpreted as a colour}
          CurCommand:=FParser.GetToken(nwSameLine);  //NextWord(nwSameLine);
          IF AnsiUpperCase(CurCommand)='ALLFIELDS' THEN
            BEGIN
              df^.GlobalTypeCom:=True;
              tmpField^.FTypeCommentField:=-2;
              tmpField^.FTypeComments:=False;
              CurCommand:=FParser.GetUpperToken(nwSameLine);   //Get the color
              IF CurCommand<>'' THEN
                BEGIN
                  FOR rn:=0 TO 17 DO
                    IF CurCommand=ColorNames[rn] THEN df^.GlobalTypeComColor:=rn;
                END;
            END
          ELSE
            BEGIN
              //is type comment colour or fieldname
              rN:=GetFieldNumber(CurCommand,df);
              IF rN<>-1 THEN
                BEGIN
                  {IF (PeField(df^.FieldList.Items[rN])^.Felttype<>ftAlfa)
                  AND (PeField(df^.FieldList.Items[rN])^.Felttype<>ftUpperAlfa) THEN
                    BEGIN
                      ReportError(translate(22838));   //'Can only TYPE COMMENTs to textfields'
                      TempResult:=False;
                    END;}
                  tmpField^.FTypeCommentField:=rN;
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
                      ReportError(translate(22745));    //'Unknown fieldname or colour'
                      TempResult:=False;
                    END;}
                END;  //if CurCommand<>''
              {Read rest of line - compatibility with Epi Info}
              REPEAT
                CurCommand:=FParser.GetUpperToken(nwSameLine);   //AnsiUpperCase(NextWord(nwSameLine));
                tmpS:=tmpS+CurCommand;
              UNTIL CurCommand='';
            END;
        END  //if Type Comment
      ELSE
        BEGIN
          ReportError(translate(22744,'Illegal syntax in TYPE command'));  //'Illegal syntax in TYPE command'
          FTempResult:=False;
        END;
    END;
  CurCommand:='';
END;   //RetrieveType;


Procedure TCheckObj.RetrieveKeys;
VAR
  Number,n: Integer;
  IsUnique,Found: Boolean;
BEGIN
  {Can be KEY
          KEY UNIQUE
          KEY n
          KEY UNIQUE n}
  IsUnique:=False;
  Number:=0;
  CurCommand:=FParser.GetUpperToken(nwSameLine);   //AnsiUpperCase(NextWord(nwSameLine));
  IF CurCommand='UNIQUE' THEN
    BEGIN
      IsUnique:=True;
      CurCommand:=FParser.GetToken(nwSameLine);   //NextWord(nwSameLine);
      IF CurCommand<>'' THEN
        BEGIN
          IF IsInteger(CurCommand) THEN Number:=StrToInt(CurCommand)
          ELSE
            BEGIN
              ReportError(translate(22747,'Illegal syntax in KEY UNIQUE command'));   //'Illegal syntax in KEY UNIQUE command'
              FTempResult:=False;
            END;
        END;
    END  //if Unique found
  ELSE IF IsInteger(CurCommand) THEN Number:=StrToInt(CurCommand)
  ELSE IF CurCommand<>'' THEN
    BEGIN
      ReportError(translate(22748,'Illegal syntax in KEY command'));  //'Illegal syntax in KEY command'
      FTempResult:=False;
    END;
  IF FTempResult THEN
    BEGIN
      {Test if Key number is already used ny FocusedField}
      IF (Number>0) AND (Number<=MaxIndices)
        THEN IF df^.IndexFields[Number]=df^.FocusedField THEN
          BEGIN
            tmpField^.FIndex:=Number;
            Exit;
          END;
      {Test if FocusedField occupies a Index-slot}
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
              ReportError(Format(translate(22750,'Only %d KEYs are permitted'),[MaxIndices]));   //'Only %d KEYs are permitted'
              FTempResult:=False;
            END;
        END;
      {Test if Number is within limit}
      IF (Number>MaxIndices) OR (Number<0) THEN
        BEGIN
          ReportError(Format(translate(22752,'Illegal KEY number. Only key numbers from 1 to %d are permitted'),[MaxIndices]));   //'Illegal KEY number. Only key numbers from 1 to %d are permitted'
          FTempResult:=False;
        END;
      IF (Number>=1) AND (Number<=MaxIndices) AND (df^.IndexFields[Number]<>-1) THEN
        BEGIN
          ReportError(translate(22754,'KEY number already used'));   //'KEY number already used'
          FTempResult:=False;
        END;
    END;  //if tempResult
  IF FTempResult THEN
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
    END;  //if TempResult
END;   //RetrieveKeys


Procedure TCheckObj.AddFieldFlawComment;
VAR
  s: string;
BEGIN
  IF NOT FCheckFileMode THEN FTempResult:=False;
  IF NOT FMultiLineError THEN FTempResult:=False;
  CommentsAddedToCheckFile:=True;
  s:=FParser.GetLineAndFlush;
  ReportError(translate(22733,'Unknown command'));   //'Unknown command'
  {$IFNDEF epidat}
  IF (FirstFieldFlaw) AND (FCheckFileMode) AND (FMultiLineError) THEN
    BEGIN
      FirstFieldFlaw:=False;
      IF eDlg(Format(translate(22820,'Unknown command found in fieldblock in checkfile %s'),    //Unknown command found in fieldblock in checkfile %s
         [ExtractFilename(df^.CHKFilename)])+#13#13+
         translate(22822,'Do you want to save unknown checkcommands found in fieldblocks')+#13+      //'Do you want to save unknown checkcommands found in fieldblocks'
         translate(22824,'as commentlines in the fieldblock?')+#13#13+   //'as commentlines in the fieldblock?'
         translate(22826,'If you choose No then unknown commands in fieldblocks will')+#13+      //'If you choose No then unknown commands in fieldblocks will'
         translate(22828,'be deleted when the revised checks are saved.'),         //'be deleted when the revised checks are saved.'
         mtWarning,[mbYes,mbNo],0)=mrYes THEN SaveFieldFlawsAsComments:=True;
      Screen.Cursor:=crHourGlass;
    END;  //FirstTopFlaw
  {$ENDIF}
  IF SaveFieldFlawsAsComments THEN
    BEGIN
      FParser.CommentCurLine;
      AddFieldComment;
    END;
END;  //procedure AddFieldFlawComment


Procedure TCheckObj.HandleBooleanConditions(VAR s:String);
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


Procedure TCheckObj.AddFieldComment;
VAR
  s: String;
  FieldComments: TStrings;
BEGIN
  s:=FParser.GetLineAndFlush;
  IF FCheckFileMode THEN
    BEGIN
      FieldComments:=TStringList.Create;
      FieldComments.Text:=tmpField^.FFieldComments;
      FieldComments.Append(FParser.GetWholeLine);
      tmpField^.FFieldComments:=FieldComments.Text;
      Fieldcomments.Free;
    END;
END;  //Procedure AddFieldComment

Function TCheckObj.Translate(stringnumber: Integer; origstring:string):string;
VAR
  s:String;
BEGIN
  s:='';
  IF Assigned(FOnTranslate) THEN
    BEGIN
      FOnTranslate(stringnumber, origstring, s);
      Result:=s;
    END
  ELSE
    Result:=origstring;
END;

end.
