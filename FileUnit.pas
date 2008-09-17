unit FileUnit;

//{$DEFINE epidat}

interface

USES
  SysUtils, Classes, Forms, Dialogs, Controls, EpiTypes, Windows, Graphics;


Function  CanOpenFile(CONST filename:String):Boolean;
Function  FormatInt(Num,Len:Integer):String;
Function  FormatFloating(s:String;Len:Integer):String;
Function  FormatStr(s:String;Len:Integer):String;
Function  FormatDate(s:String;Typ:TFelttyper;Len:Integer):String;
Function  ftDateToDateTime(s:String;Typ:TFelttyper;Len:Integer):TDateTime;
{$IFNDEF epidat}
Procedure peNewRecord(VAR df:PDatafileInfo);
Procedure pSetUpLastField(df:PDatafileInfo);
{$ENDIF}
procedure WriteNextRecord(VAR df:PDatafileInfo; VAR F: TextFile);
Procedure peWriteRecord(VAR df:PDatafileInfo; RecNum:LongInt);
Procedure peReadRecord(VAR df:PDatafileInfo; RecNum:LongInt);
Function  FieldListToQes(VAR df:PDatafileInfo; VAR ReturnQesStr:String; InsertFieldname: Boolean):Boolean;
Function  PeekDataFile(df:PDatafileInfo):Boolean;

Function  TranslateQes(VAR df:PDatafileInfo; VAR LineIn:String):Boolean;
Function  PeekCreateDataFile(VAR df:PDatafileInfo):Boolean;
Procedure eReadOnlyNextRecord(VAR df: PDatafileInfo; VAR f:Textfile);
Procedure eReadOnlyRecord(VAR df: PDatafileInfo; VAR f:Textfile; pos: Longint);
Function MakeIndexFile(VAR df: PDatafileInfo):Boolean;
Function  ApplyIndex(VAR df: PDatafileInfo):Boolean;
Function DoRebuildIndex(VAR df: PDatafileInfo): Boolean;

implementation

{$IFNDEF epidat}
USES
  MainUnit, EdUnit, DataFormUnit, PasswordUnit, PeekCheckUnit;
{$ELSE}
USES
  PeekCheckUnit;
{$ENDIF}


TYPE
  TReadError=(reNoError,reEOFReached,reIOError);
  str10=String[10];

VAR
  NextChar:CHAR;
  eLine:String;
  eByte:BYTE;
  eReadError:TReadError;


Function CanOpenFile(CONST Filename:String):Boolean;
VAR
  f:File;
BEGIN
  IF FileExists(Filename) THEN
    BEGIN
      AssignFile(f,filename);
      {$I-}
      Reset(f);
      {$I+}
      IF IOResult=0 THEN
        BEGIN
          Result:=True;
          CloseFile(f);
        END
      ELSE
        BEGIN
          Result:=False;
          {$IFNDEF epidat}
          ErrorMsg(Format(Lang(22104),[Filename])+#13+Lang(20208));  //'The file %s cannot be opened.' Please check if the file is in use and that the filename is legal.
          {$ELSE}
          epiErrorCode:=epi_OPEN_FILE_ERROR;
          {$ENDIF}
        END;
    END
  {$IFNDEF epidat}
  ELSE ErrorMsg(Format(Lang(22126),[Filename]));   //The file %s does not exist.
  {$ELSE}
  ELSE epiErrorCode:=epi_FILE_NOT_EXISTS;
  {$ENDIF}
END;  //function CanOpenFile


Function TextPos(var F:Textfile):Longint;
BEGIN
  With TTextRec(F) DO
    BEGIN
      Result:=SetFilePointer(Handle,0,nil,FILE_CURRENT);
      IF Mode=FMOutput THEN INC(Result, BufPos)
      ELSE IF BufEnd<>0 THEN Dec(Result, BufEnd-BufPos);
    END;
END;


Function FormatInt(Num,Len:Integer):String;
VAR
  TempStr:String;
BEGIN
  TempStr:=IntToStr(Num);
  WHILE Length(TempStr)<Len DO TempStr:=' '+TempStr;
  IF Length(TempStr)>Len THEN TempStr:=COPY(TempStr,1,Len);
  FormatInt:=TempStr;
END;  //function FormatInt

Function FormatFloating(s:String;Len:Integer):String;
BEGIN
  WHILE Length(s)<Len DO s:=' '+s;
  IF Length(s)>Len THEN s:=COPY(s,1,Len);
  Result:=s;
END;

Function FormatStr(s:String;Len:Integer):String;
BEGIN
  WHILE Length(s)<Len DO s:=s+' ';
  IF Length(s)>Len THEN s:=COPY(s,1,Len);
  FormatStr:=s;
END;  //function FormatStr

Function FormatDate(s:String;Typ:TFelttyper;Len:Integer):String;
  {Takes a epiData datestring and makes it into a dBase datestring (8 chars yyyymmdd)}
BEGIN
  try
    DecodeDate(Date,eYear,eMonth,eDay);
    Result:='        ';   //8 spaces
    IF trim(s)<>'' THEN
      BEGIN
        CASE Len OF
          5:  Result:=IntToStr(eYear);
          8:  IF StrToInt(Copy(s,7,2))<50
              THEN Result:='20'+Copy(s,7,2)
              ELSE Result:='19'+Copy(s,7,2);
          10: Result:=Copy(s,7,4);
        END;  //case
        IF (Typ=ftDate) OR (Typ=ftToday) THEN Result:=Result+Copy(s,1,2)+Copy(s,4,2)
        ELSE Result:=Result+Copy(s,4,2)+Copy(s,1,2);
        IF (Typ=ftYMDDate) OR (Typ=ftYMDToday) THEN Result:=Copy(s,1,4)+copy(s,6,2)+copy(s,9,2);  //&&
      END;
  EXCEPT
    Result:='        ';
  END;  //try..except
END;  //FormatDate

Function ftDateToDateTime(s:String;Typ:TFelttyper;Len:Integer):TDateTime;
{IF s contains a ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday a TDateTime is returned}
BEGIN
  DecodeDate(Date,eYear,eMonth,eDay);
  Case Len OF
    8:  IF StrToInt(Copy(s,7,2))<50
        THEN eYear:=2000+StrToInt(Copy(s,7,2))
        ELSE eYear:=1900+StrToInt(Copy(s,7,2));
    10: IF (typ=ftYMDDate) or (typ=ftYMDToday)
        THEN eYear:=StrToInt(Copy(s,1,4))
        ELSE eYear:=StrToInt(Copy(s,7,4));   //&&
  END;  //case
  TRY
    CASE typ OF
      ftDate,ftToday: BEGIN
        eMonth:=StrToInt(Copy(s,1,2));
        eDay:=StrToInt(Copy(s,4,2));
        END;
      ftEuroDate,ftEuroToday: BEGIN
        eMonth:=StrToInt(Copy(s,4,2));
        eDay:=StrToInt(Copy(s,1,2));
        END;
      ftYMDDate, ftYMDToday: BEGIN   //&&
        eMonth:=StrToInt(Copy(s,6,2));
        eDay:=StrToInt(Copy(s,9,2));
        END;
    END;  //case
    Result:=EncodeDate(eYear,eMonth,eDay);
  EXCEPT
    Result:=0;
  END;
END;

{$IFNDEF epidat}
Procedure peNewRecord(VAR df:PDatafileInfo);
VAR
  AField:PeField;
BEGIN
  TDataForm(df^.DatForm).ClearFields;
  WITH df^ DO
    BEGIN
      CurRecord:=NewRecord;
      CurRecModified:=False;
      CurRecDeleted:=False;
      CurRecVerified:=False;
      IF df^.DoubleEntry THEN
        BEGIN
          df^.dbKeyfieldvalue:='';
          IF Assigned(df^.dbdf) THEN df^.dbDf^.CurRecord:=-1;
          ResetVarifiedFlag(df);
        END;
      IF df^.IDNUMField<>-1 THEN
        BEGIN
          AField:=PeField(FieldList.Items[IDNUMField]);
          AField^.FFieldText:=IntToStr(CurIDNumber);
          ChangeGoingOn:=True;
          TEntryField(AField^.EntryField).Text:=AField^.FFieldText;
          ChangeGoingOn:=False;
        END;
      TDataForm(df^.DatForm).UpdateCurRecEdit(CurRecord,NumRecords);
    END;  //with
END;  //procedure peNewRecord
{$ENDIF}


Procedure peWrite(VAR f:ByteFile; Const s:String);
VAR
  t,n:Byte;
BEGIN
  FOR n:=1 TO Length(s) DO
    BEGIN
      t:=ORD(s[n]);
      Write(f,t);
    END;  //for
END;  //procedure peWrite


Procedure peWriteEOLN(VAR f:ByteFile);
BEGIN
  Write(f,NewLine);
  Write(f,LineFeed);
END;  //procedure peWriteEOLN



procedure peWriteRecord(VAR df:PDatafileInfo; RecNum:LongInt);
CONST
  EOLchars: array[0..2] of char = '!'#13#10;

VAR
  wrN,n,repcounter,ecode:Integer;
  TempS:String[80];
  s:Str30;
  eRecString,s2:String;
  ABuf: PRecBuf;
  BufCount,LineCharCount: Integer;
  ok:Boolean;
BEGIN
  ABuf:=df^.RecBuf;
  IF RecNum=NewRecord THEN
    BEGIN
      IF df^.HasEOFMarker THEN
        BEGIN
          df^.HasEOFMarker:=False;
          df^.Datfile.Position:=df^.Datfile.Size-1;  //§§§
        END
      ELSE df^.Datfile.Position:=df^.DatFile.Size;  //§§§
      INC(df^.NumRecords);
      //Add empty record to indexfile and resize index
      IF df^.IndexCount>0 THEN
        BEGIN
          repcounter:=0;
          REPEAT
            ok:=True;
            INC(repcounter);
            TRY
              s:='';
              Seek(df^.IndexFile,Filesize(df^.IndexFile));
              FOR n:=1 TO df^.IndexCount DO Write(df^.Indexfile,s);
            EXCEPT
              ok:=False;
              IF repcounter>=3 THEN
                {$IFNDEF epidat}
                IF eDlg(Format(Lang(20460),[repcounter]),     //20460=%d attempts of writing current record failed~~Retry?
                mtWarning,[mbYes,mbNo],0)=mrNo THEN
                  BEGIN
                    ok:=True;
                    repcounter:=-1;
                  END;
                {$ELSE}
                   epiErrorCode:=epi_WRITE_ERROR;
                {$ENDIF}
            END;  //try..except
          UNTIL ok;
          IF repcounter=-1 THEN raise EWriteError.Create(Lang(20462));  //20462=Current record not saved!

          df^.Index.SetSize(df^.Index.Size+(df^.IndexCount*31));
          //If assigned(df^.SortIndex) THEN....
        END;
    END
  ELSE df^.Datfile.position:=df^.Offset+((RecNum-1)*df^.RecLength);  //§§§
  eRecString:='';
  BufCount:=0;
  LineCharCount:=MaxRecLineLength;
  FOR wrN:=0 TO df^.FieldList.Count-1 DO    //Iterate through all fields
    BEGIN
      WITH PeField(df^.FieldList.Items[wrN])^ DO
        BEGIN
          IF (FeltType in [ftToday,ftEuroToday,ftYMDToday]) THEN    //&&
          FFieldText:=mibDateToStr(now,FeltType);
          //Add indices
          IF FIndex>0 THEN
            BEGIN
              IF RecNum=NewRecord THEN n:=df^.NumRecords ELSE n:=RecNum;
              IF Felttype=ftCrypt THEN s:=Copy(FFieldText,1,21)
              ELSE s:=Copy(FFieldText,1,30);    //&&
              CASE Felttype OF
                ftInteger,ftFloat: s:=FormatNumberToIndex(s);
                ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:  //&&
                  s:=Format('%30s',[FloatToStr(mibStrToDate(s,Felttype))]);
               ELSE
                 s:=Format('%-30s',[s]);
              END;  //case
              WriteToIndex(df,FIndex,n,s);
              //WriteToSortIndex ???
              //Write to indexfile
              repcounter:=0;
              ok:=True;
              REPEAT
                INC(repcounter);
                TRY
                  Seek(df^.IndexFile,((n-1)*df^.IndexCount)+FIndex);
                  IF Felttype=ftCrypt THEN    //&&
                    BEGIN
                      s2:=s;
                      s:=EncryptString(trim(s2),df^.Key);
                    END;
                  Write(df^.IndexFile,s);   //&&
                EXCEPT
                  ok:=False;
                  IF repcounter>=3 THEN
                    {$IFNDEF epidat}
                    IF eDlg(Format(Lang(20460),[repcounter]),     //20460=%d attempts of writing current record failed~~Retry?
                    mtWarning,[mbYes,mbNo],0)=mrNo THEN
                      BEGIN
                        ok:=True;
                        repcounter:=-1;
                      END;
                    {$ELSE}
                      epiErrorCode:=epi_WRITE_ERROR;
                    {$ENDIF}
                END;  //try..except
              UNTIL ok;
              IF repcounter=-1 THEN raise EWriteError.Create(Lang(20462));  //20462=Current record not saved!
            END;
          //Make RecString
          TempS:=FFieldText;
          IF (Felttype=ftCrypt) AND (df^.Key<>'') THEN TempS:=EncryptString(trim(TempS),df^.Key);   //&&
          IF ((Felttype=ftInteger) or (Felttype=ftFloat))
            AND (Trim(TempS)<>'') THEN
            BEGIN
              IF Felttype=ftFloat THEN
                BEGIN
                  WHILE pos(',',TempS)<>0 DO TempS[Pos(',',TempS)]:='.';
                  TempS:=FormatFloating(TempS,FLength);
                END  //if ftFloat
              ELSE
                TempS:=FormatInt(strToInt(TempS),FLength);
            END   //if ftInteger or ftFloat
          ELSE IF Felttype<>ftQuestion THEN TempS:=FormatStr(TempS,Flength);
          FOR n:=1 TO FLength DO
            BEGIN
              ABuf^[BufCount]:=TempS[n];
              DEC(LineCharCount);
              INC(BufCount);
              IF LinecharCount=0 THEN
                BEGIN
                  Move(EOLchars, ABuf^[BufCount], length(EOLChars));
                  INC(BufCount, sizeof(EOLchars));
                  LinecharCount:=MaxRecLineLength;
                END;
            END;
        END;  //with
    END;  //for wrN - iterate through fields
  IF (LineCharCount<>MaxRecLineLength)
  THEN Move(EOLchars, ABuf^[BufCount], sizeof(EOLchars));
  if (df^.DoubleEntry) AND (NOT df^.CurRecDeleted) THEN
    BEGIN
      WHILE ABuf^[BufCount]<>'!' DO Dec(BufCount);
      ABuf^[BufCount]:='^';
    END;
  IF df^.CurRecDeleted THEN
    BEGIN
      WHILE ABuf^[BufCount]<>'!' DO Dec(BufCount);
      ABuf^[BufCount]:='?';
    END;
  repcounter:=0;
  REPEAT
    ok:=True;
    INC(repcounter);
    TRY
      df^.DatFile.WriteBuffer(ABuf^,df^.RecLength);
    EXCEPT
      ok:=False;
      IF repcounter>=3 THEN
        {$IFNDEF epidat}
        IF eDlg(Format(Lang(20460),[repcounter]),     //20460=%d attempts of writing current record failed~~Retry?
        mtWarning,[mbYes,mbNo],0)=mrNo THEN
         BEGIN
            ok:=True;
            repcounter:=-1;
          END;
        {$ELSE}
          epiErrorCode:=epi_WRITE_ERROR;
        {$ENDIF}
    END;
  UNTIL ok;
  IF repcounter=-1 THEN raise EWriteError.Create(Lang(20462));  //20462=Current record not saved!
  df^.CurRecModified:=False;
  df^.dfModified:=True;
  IF (df^.IDNUMField<>-1) AND (RecNum=NewRecord) THEN INC(df^.CurIDNumber);
END;  //procedure peWriteRecord





procedure WriteNextRecord(VAR df:PDatafileInfo; VAR F: TextFile);
{Appends a new record to an open Textfile}
VAR
  wrN:Integer;
  TempS:String;
  eRecString:String;
BEGIN
  eRecString:='';
  FOR wrN:=0 TO df^.FieldList.Count-1 DO    //Iterate through all fields
    BEGIN
      WITH PeField(df^.FieldList.Items[wrN])^ DO
        BEGIN
          {Make RecString}
          TempS:=FFieldText;
          IF (Felttype=ftCrypt) AND (df^.Key<>'') THEN TempS:=EncryptString(trim(TempS),df^.Key);   //&&
          IF ((Felttype=ftInteger) or (Felttype=ftFloat))
            AND (Trim(TempS)<>'') THEN
            BEGIN
              IF Felttype=ftFloat THEN
                BEGIN
                  WHILE pos(',',TempS)<>0 DO TempS[Pos(',',TempS)]:='.';
                  eRecString:=eRecString+FormatFloating(TempS,FLength);
                END  //if ftFloat
              ELSE eRecString:=eRecString+FormatInt(StrToInt(TempS),FLength);
            END   //if ftInteger or ftFloat
          ELSE IF Felttype<>ftQuestion THEN eRecString:=eRecString+FormatStr(TempS,FLength);
        END;  //with
    END;  //for wrN - iterate through fields
  WHILE Length(eRecString)>MaxRecLineLength DO
    BEGIN
      {$I-}
      WriteLN(F,Copy(eRecString,1,MaxRecLineLength)+'!');
      wrn:=IOResult;
      {$I+}
      IF wrn<>0 THEN
        BEGIN
          {$IFNDEF epidat}
          IF wrn=112 THEN ErrorMsg('Disk full!')
          ELSE ErrorMsg('Error writing to disk  (I/O error '+InttoStr(wrn)+')');
          {$ELSE}
          epiErrorCode:=epi_WRITE_ERROR;
          {$ENDIF}
        END;
      Delete(eRecString,1,MaxRecLineLength)
    END;  //while
  Write(F,eRecString);
  IF df^.CurRecDeleted THEN WriteLN(F,'?')
  ELSE IF df^.CurRecVerified THEN WriteLN(F,'^')
  ELSE WriteLN(F,'!');
  INC(df^.NumRecords);
  df^.CurRecModified:=False;
  IF (df^.IDNUMField<>-1) THEN INC(df^.CurIDNumber);
END;  //procedure WriteNextRecord




{Procedure eReadByte(IncOffset2:Boolean);
BEGIN
  {$I-}
{  Read(Datafile,eByte);
  {$I+}
{  IF IOResult<>0 THEN eReadError:=reIOError
  ELSE IF IncOffSet2 THEN INC(DatafileInfo.Offset);
  IF EOF(DataFile) THEN eReadError:=reEOFReached;
END;  //procedure eReadByte}

Procedure peReadByte(VAR f:Bytefile);
BEGIN
  {$I-}
  Read(f,eByte);
  {$I+}
  IF IOResult<>0 THEN eReadError:=reIOError;
  IF EOF(f) THEN eReadError:=reEOFReached;
END;  //procedure peReadByte

{Procedure eReadLine(IncOffset:Boolean);
BEGIN
  eReadError:=reNoError;
  IF NextChar<>#0 THEN eLine:=NextChar ELSE eLine:='';
  REPEAT
    eReadByte(IncOffset);
    IF (eReadError=reNoError) AND (eByte<>13) AND (eByte<>10)
    THEN eLine:=eLine+CHR(eByte);
  UNTIL (EOF(Datafile)) OR (eByte=13) or (eByte=10) or (eReadError<>reNoError);
  IF EOF(Datafile) THEN eReadError:=reEOFReached
  ELSE
    IF eReadError=reNoError THEN
      BEGIN  //Get beyond EOL markers
        eReadByte(IncOffset);
        IF (eReadError=reNoError) THEN
          BEGIN
            IF (eByte<>13) and (eByte<>10) THEN NextChar:=CHR(eByte)
            ELSE
              BEGIN
                eReadByte(IncOffset);
                IF (eReadError=reNoError) THEN NextChar:=CHR(eByte);
              END;
          END;
      END;  //get beyond EOL markers
END;  //procedure eReadLine}

Procedure peReadLine(VAR f:Bytefile);
BEGIN
  eReadError:=reNoError;
  IF NextChar<>#0 THEN eLine:=NextChar ELSE eLine:='';
  REPEAT
    peReadByte(f);
    IF (eReadError=reNoError) AND (eByte<>13) AND (eByte<>10)
    THEN eLine:=eLine+CHR(eByte);
  UNTIL (EOF(f)) OR (eByte=13) or (eByte=10) or (eReadError<>reNoError);
  IF EOF(f) THEN eReadError:=reEOFReached
  ELSE
    IF eReadError=reNoError THEN
      BEGIN  //Get beyond EOL markers
        peReadByte(f);
        IF (eReadError=reNoError) THEN
          BEGIN
            IF (eByte<>13) and (eByte<>10) THEN NextChar:=CHR(eByte)
            ELSE
              BEGIN
                peReadByte(f);
                IF (eReadError=reNoError) THEN NextChar:=CHR(eByte);
              END;
          END;
      END;  //get beyond EOL markers
END;  //procedure peReadLine

{procedure eReadRecord(RecNum:LongInt);
VAR
  rdN:Integer;
  eRecString:String;
BEGIN
  IF RecNum<=DatafileInfo.NumRecords THEN
    BEGIN
      Seek(Datafile,DatafileInfo.Offset+((RecNum-1)*DatafileInfo.RecLength));
      NextChar:=#0;
      eRecString:='';
      WHILE (eReadError<>reIOError) AND (Length(eRecString)<DatafileInfo.ShortRecLength) DO
        BEGIN
          eReadLine(False);    //Read line i datafile
          IF (NOT (eLine[Length(eLine)] in TerminatorChars)) or (eReadError=reIOError)
          THEN eReadError:=reIOError ELSE eRecString:=eRecString+Copy(eLine,1,Length(eLine)-1);
        END;  //While

      {Record is now read into eRecString}
{      IF (NOT (eReadError=reIOError)) AND (Length(eRecString)=DatafileInfo.ShortRecLength) THEN
        BEGIN
          FOR rdN:=0 TO FeltListe.Count-1 DO    //Iterate through all fields
            BEGIN
              WITH TFelt(FeltListe.Items[rdN]) DO
                BEGIN
                  IF Felttype<>ftQuestion THEN
                    BEGIN
                      ChangeGoingOn:=True;
                      Text:=Trim(COPY(eRecString,1,FLength));
                      Modified:=False;
                      ChangeGoingOn:=False;
                      Delete(eRecString,1,FLength);
                    END;  //if felttype<>ftQuestion
                END;  //with Feltliste.Items
            END;  //For rdN
          DatafileInfo.Modified:=False;
          DatafileInfo.CurRecord:=RecNum;
          IF eLine[Length(eLine)]='?'
          THEN DatafileInfo.CurRecDeleted:=True
          ELSE DatafileInfo.CurRecDeleted:=False;
          IndtastningsForm.UpdateCurRecEdit(RecNum, DatafileInfo.NumRecords);
        END;  //if no read errors
    END;  //if RecNum<=NumRecords
END;  //procedure eReadRecord}

procedure peReadRecord(VAR df:PDatafileInfo; RecNum:LongInt);
VAR
  rdN,n,LineCharCount,BufCount:Integer;
  ABuf: PRecBuf;
  ok: Boolean;
  ss: String;
BEGIN
  IF (RecNum<=df^.NumRecords) AND (RecNum>0) THEN
    BEGIN
      ABuf:=df^.RecBuf;
      df^.DatFile.Position:=df^.Offset+((RecNum-1)*df^.RecLength);  //§§§
      n:=0;
      REPEAT
        INC(n);
        ok:=True;
        TRY
          df^.DatFile.ReadBuffer(ABuf^,df^.RecLength);  //§§§
        EXCEPT
          ok:=False;
          IF n>=3 THEN raise Exception.Create(Lang(20464));  //20464=Error reading record
        END;  //try..except
      UNTIL ok;
      IF n>=3 THEN raise Exception.Create(Lang(20464));    //20464=Error reading record
      LineCharCount:=MaxRecLineLength;
      BufCount:=0;
      {$IFNDEF epidat}
      LockWindowUpdate(MainForm.Handle);
      {$ENDIF}
      FOR rdN:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          WITH PeField(df^.FieldList.Items[rdN])^ DO
            BEGIN
              IF Felttype<>ftQuestion THEN
                BEGIN
                  FFieldText:=cFill(' ',FLength);
                  FOR n:=1 TO FLength DO
                    BEGIN
                      FFieldText[n]:=ABuf^[BufCount];
                      INC(BufCount);
                      DEC(LineCharCount);
                      IF LineCharCount<=0 THEN
                        BEGIN
                          LineCharCount:=MaxRecLineLength;
                          INC(BufCount,3);
                        END;
                    END;  //for
                  FFieldText:=trim(FFieldText);
                  IF (Felttype=ftCrypt) AND (df^.Key<>'') THEN
                    BEGIN
                      ss:=FFieldText;
                      ss:=DecryptString(ss,df^.Key);  //&&
                      FFieldtext:=ss;
                    END;
                  {$IFNDEF epidat}
                  IF Assigned(df^.DatForm) THEN
                    BEGIN
                      ChangeGoingOn:=True;
                      TEntryField(EntryField).Text:=FFieldText;
                      TEntryField(EntryField).Modified:=False;
                      ChangeGoingOn:=False;
                      IF (FTypeComments) OR (FTypeString) THEN FTypeField.Caption:='';
                    END;  //if assigned
                  {$ENDIF}
                END;  //if not ftQuestion
            END;  //with
        END;  //for
      {$IFNDEF epidat}
      LockWindowUpdate(0);
      {$ENDIF}
      df^.CurRecModified:=False;
      IF df^.DoubleEntry THEN
        BEGIN
          df^.dbKeyfieldvalue:='';
          IF Assigned(df^.dbdf) THEN df^.dbDf^.CurRecord:=-1;
          SetVarifiedFlag(df);
          //ResetVarifiedFlag(df);
        END;
      df^.CurRecord:=RecNum;
      IF LineCharCount=MaxRecLineLength THEN DEC(BufCount,3);
      df^.CurRecDeleted:=(ABuf^[BufCount]='?');
      df^.CurRecVerified:=(ABuf^[BufCount]='^');
      {$IFNDEF epidat}
      IF NOT NoUpDateCurRecEdit THEN
        BEGIN
          IF Assigned(df^.DatForm) THEN TDataForm(df^.DatForm).UpdateCurRecEdit(RecNum, df^.NumRecords);
        END;
      {$ENDIF}
    END;  //if RecNum<=NumRecords
END;  //procedure peReadRecord


Procedure eReadOnlyNextRecord(VAR df: PDatafileInfo; VAR f:Textfile);
{Procedure reads the next record in the TEXTFILE df^.RecTextFile}
{df must be initialized and PeedDatafile must be called before this proc.}
{f:Textfile must be initialized and filepointer must point to first record}
VAR
  n: Integer;
  NumLines: Integer;
  tmpS: String;
  InStr:String[MaxRecLineLength+3];
BEGIN
  IF df^.CurRecord>df^.NumRecords THEN Exit;
  NumLines:=((df^.ShortRecLength-1) DIV MaxRecLineLength)+1;
  tmpS:='';
  FOR n:=1 TO NumLines DO
    BEGIN
      ReadLN(f,InStr);
      IF (n=NumLines) AND (InStr[Length(InStr)]='?')
      THEN df^.CurRecDeleted:=True ELSE df^.CurRecDeleted:=False;
      InStr:=Copy(InStr,1,Length(InStr)-1);   //Remove terminator
      tmpS:=tmpS+InStr;
    END;
  {tmpS now contains the full record without terminators}
  FOR n:=0 TO df^.FieldList.Count-1 DO    //Iterate through all fields
    BEGIN
      WITH PeField(df^.FieldList.Items[n])^ DO
        BEGIN
          IF Felttype<>ftQuestion THEN
            BEGIN
              FFieldText:=Trim(COPY(tmpS,1,FLength));
              IF (Felttype=ftCrypt) AND (df^.Key<>'')
              THEN FFieldText:=DecryptString(FFieldText,df^.Key);  //&&
              Delete(tmpS,1,FLength);
            END;  //if felttype<>ftQuestion
        END;  //with
    END;  //For n
  df^.CurRecModified:=False;
  INC(df^.CurRecord);
END;

Procedure eReadOnlyRecord(VAR df: PDatafileInfo; VAR F:Textfile; pos: Longint);
{Procedure reads the record # pos in the TEXTFILE F}
{df must be initialized and PeekDatafile must be called before this proc.}
BEGIN
  IF pos>df^.NumRecords THEN Exit;
  WITH TTextRec(F) DO
    BEGIN
      BufEnd:=0;
      SetFilePointer(Handle,df^.Offset+((Pos-1)*df^.RecLength),nil,FILE_BEGIN);
    END;
  df^.CurRecord:=Pos-1;
  eReadOnlyNextRecord(df,F);
END;  //procedure eReadOnlyRecord


Function PeekCountRecords(df:PDatafileInfo):LongInt;
VAR
  b: PRecBuf;
BEGIN
  IF df^.Datfile.size=df^.Offset THEN Result:=0  //§§§
  ELSE
    BEGIN
      GetMem(b,3);
      Result:=df^.Datfile.Size-df^.Offset;  //§§§
      df^.Datfile.Position:=df^.Datfile.size-3;  //§§§
      df^.Datfile.ReadBuffer(b^,3);  //§§§
      IF b^[2]<>#26 THEN   //is b3=EOF mark?
        BEGIN
          IF (b^[1]<>#13) or (b^[2]<>#10) THEN INC(Result,2);
        END
      ELSE
        BEGIN
          Dec(Result);
          df^.HasEOFMarker:=True;
          IF (b^[0]<>#13) or (b^[1]<>#10) THEN INC(Result,2);
        END;
      IF Result MOD df^.RecLength <> 0 THEN Result:=-1
      ELSE Result:=Result DIV df^.RecLength;
      FreeMem(b);
    END;
END;  //function PeekCountRecords



Function FieldListToQes(VAR df:PDatafileInfo; VAR ReturnQesStr:String; InsertFieldname:Boolean):Boolean;
VAR
  CurField,rN,Lx,Indent,PrevIndent,nc,qc:Integer;
  TempStr,tmpFieldStr,s,q,tmpFName:String;
  QES: TStrings;
  InBracket: Boolean;
BEGIN
  TRY
    QES:=TStringList.Create;

    Result:=True;
    Indent:=0;
    PrevIndent:=0;
    FOR CurField:=0 TO df^.FieldList.Count-1 DO
      BEGIN
        WITH PeField(df^.FieldList.Items[CurField])^ DO
          BEGIN
            Indent:=0;
            IF FQuestY<>QES.Count THEN PrevIndent:=0;
            q:=FQuestion;
            tmpFName:=trim(FName);
            IF (InsertFieldname) AND (Felttype<>ftQuestion) THEN
              BEGIN
                IF trim(FQuestion)<>'' THEN
                  BEGIN
                    IF df^.EpiInfoFieldNaming THEN
                      BEGIN
                        IF NOT (AnsiUpperCase(tmpFName)=AnsiUpperCase(trim(q))) THEN
                          BEGIN
                            //test if fieldname can be made from question
                            nc:=1;
                            qc:=1;
                            WHILE (nc<=Length(tmpFName)) AND (qc<Length(q)) DO
                              BEGIN
                                IF UpCase(q[qc])=UpCase(tmpFName[nc]) THEN INC(nc);
                                INC(qc);
                              END;  //while
                            IF nc=Length(tmpFName)+1 THEN
                              BEGIN
                                //Fieldname can be made from question
                                nc:=1;
                                qc:=1;
                                InBracket:=False;
                                s:='';
                                WHILE qc<=Length(q) DO
                                  BEGIN
                                    IF nc<=Length(tmpFName)+1 THEN
                                      BEGIN
                                        IF UpCase(q[qc])=UpCase(tmpFName[nc]) THEN
                                          BEGIN
                                            INC(nc);
                                            IF NOT InBracket THEN
                                              BEGIN
                                                InBracket:=True;
                                                s:=s+'{';
                                                INC(Indent);
                                              END;
                                          END  //if fieldname letter found
                                        ELSE IF InBracket THEN
                                          BEGIN
                                            s:=s+'}';
                                            INC(Indent);
                                            InBracket:=False;
                                          END;
                                      END;  //if parts of fieldname is still missing
                                    s:=s+q[qc];
                                    INC(qc)
                                  END;  //while qc<=Length(q)
                                IF InBracket THEN
                                  BEGIN
                                    s:=s+'}';
                                    INC(Indent);
                                  END;
                                q:=s;
                              END   //if question contains fieldname
                            ELSE
                              BEGIN
                                //question does not contain fieldname
                                nc:=1;
                                WHILE q[nc]=' ' DO INC(nc);
                                Insert('{'+tmpFName+'} ',q,nc);
                                Indent:=Length(tmpFName)+3;
                              END;
                          END;  //if question<>fname
                      END  //if EpiInfoFieldNaming
                    ELSE
                      BEGIN
                        //First word is used as fieldname
                        IF AnsiUpperCase(FirstWord(q))<>AnsiUpperCase(tmpFName) THEN
                          BEGIN
                            nc:=1;
                            WHILE q[nc]=' ' DO INC(nc);
                            Insert(tmpFName+' ',q,nc);
                            Indent:=Length(tmpFName)+1;
                          END;
                      END;
                  END  //if there is a question
                ELSE
                  BEGIN
                    IF q='' THEN
                      BEGIN
                        q:=tmpFName+' ';
                        FQuestY:=FFieldY;
                        FQuestX:=FFieldX;
                      END
                    ELSE
                      BEGIN
                        nc:=1;
                        WHILE q[nc]=' ' DO INC(nc);
                        Insert(tmpFName+' ',q,nc);
                      END;
                    Indent:=Length(tmpFName)+1;
                  END;
              END;  //if InsertFieldname
            IF trim(q)<>'' THEN   //is there a question?
              BEGIN
                {Get the nessary number of lines}
                WHILE FQuestY>QES.Count DO QES.Append('');
                Lx:=FQuestY-1;
                tempStr:=QES[Lx];
                {Get the nessaray number of chars in the line}
                WHILE Length(tempStr) < FQuestX-1+Length(q)+PrevIndent DO
                  tempStr:=tempStr+' ';
                {put FQuestion in tempStr}
                FOR rN:=1 TO Length(q) DO
                  tempStr[FQuestX-1+rN+PrevIndent]:=q[rN];
                QES[Lx]:=tempStr;
              END;  //if trim(FQuestion)<>''
            PrevIndent:=PrevIndent+Indent;
            IF FLength>0 THEN  //is there a field?
              BEGIN
                WHILE FFieldY>QES.Count DO QES.Append('');
                Lx:=FFieldY-1;
                tmpFieldStr:='';
                CASE FeltType of
                  ftInteger: tmpFieldStr:=cFill('#',FLength);
                  ftAlfa: tmpFieldStr:=cFill('_',FLength);
                  ftDate:BEGIN
                    CASE FLength of
                      5: tmpFieldStr:='<mm/dd>';
                      8: tmpFieldStr:='<mm/dd/yy>';
                      10: tmpFieldStr:='<mm/dd/yyyy>';
                    ELSE Result:=False;
                    END;  //case FLength
                    END;  //Case FeltType of ftDate
                  ftUpperAlfa: tmpFieldStr:='<A'+cFill(' ',FLength-1)+'>';
                  ftCrypt:     tmpFieldStr:='<E'+cFill(' ',FCryptEntryLength-1)+'>';   //&&
                  ftIDNUM: tmpFieldStr:='<IDNUM'+cFill(' ',FLength-5)+'>';
                  ftBoolean: tmpFieldStr:='<Y>';
                  ftFloat: BEGIN
                    tmpFieldStr:=cFill('#',FLength-1-FNumDecimals);
                    IF FNumDecimals=0 THEN tmpFieldStr:=tmpFieldStr+'#'
                    ELSE tmpFieldStr:=tmpFieldStr+'.'+cFill('#',FNumDecimals);
                    END;   //Case FeltType of ftFloat
                  ftYMDToday: tmpFieldStr:='<TODAY-YMD>';     //&&
                  ftYMDDate:  tmpFieldStr:='<yyyy/mm/dd>';    //&&
                  ftToday: BEGIN
                    CASE FLength of
                      5: tmpFieldStr:='<TODAY>';
                      8: tmpFieldStr:='<TODAY/YY>';
                      10: tmpFieldStr:='<TODAY-MDY>';
                    END;  //Case FLength
                    END;  //Case FeltType of ftToday;
                  ftEuroDate: BEGIN
                    CASE FLength of
                      5: tmpFieldStr:='<dd/mm>';
                      8: tmpFieldStr:='<dd/mm/yy>';
                      10: tmpFieldStr:='<dd/mm/yyyy>';
                    ELSE Result:=False;
                    END;  //case FLength
                    END;  //Case FeltType of ftEuroDate
                  ftEuroToday: IF FLength=10 THEN tmpFieldStr:='<today-dmy>'
                               ELSE Result:=False;
                  ftSoundex: tmpFieldStr:='<S'+cFill(' ',FLength-1)+'>';
                  ELSE  Result:=False;
                END;  //Case FeltType

                IF Result THEN
                  BEGIN
                    tempStr:=QES[Lx];
                    WHILE Length(tempStr) < FFieldX-1+Length(tmpFieldStr)+PrevIndent DO
                      tempStr:=tempStr+' ';

                    FOR rN:=1 TO Length(tmpFieldStr) DO
                      tempStr[FFieldX-1+rN+PrevIndent]:=tmpFieldStr[rN];

                    QES[Lx]:=Tempstr;

                  END;  //if legal field found
              END;  //is there a field?
          END;   //with TempField
      END;   //for CurField
    ReturnQesStr:=QES.Text;
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Format(Lang(20204),[124]));  //'Out of memory (reference-code 124).'
    {$ELSE}
    epiErrorCode:=EPI_NO_MEMORY;
    {$ENDIF}
    Result:=False;
  END;  //try..except
  QES.Free;
END;   //function FieldListToQes




Function PeekCreateDataFile(VAR df:PDatafileInfo):Boolean;
VAR
  TempResult:Boolean;
  N,TempInt,colorN:Integer;
  ff:ByteFile;

BEGIN
  IF (NOT Assigned(df^.FieldList)) OR (df^.NumFields=0) THEN
    BEGIN
      Result:=False;
      Exit;
    END;
  TempResult:=True;
  AssignFile(ff,df^.RECFilename);
  {$I-}
  Rewrite(ff);
  TempInt:=IOResult;
  {$I+}
  IF TempInt=0 THEN
    BEGIN
      {Check if datafile contains encrypt-field}    //&&
      n:=0;
      REPEAT
        IF PeField(df^.FieldList.Items[n])^.Felttype=ftCrypt THEN df^.HasCrypt:=True;
        INC(n);
      UNTIL (n=df^.FieldList.Count) OR (df^.HasCrypt);
      IF df^.HasCrypt THEN
        BEGIN
          IF df^.Key='' THEN
            BEGIN
              {$IFNDEF epidat}
              TRY
                PasswordForm:=TPasswordForm.Create(application);
                PasswordForm.lbDatafile.Caption:=ExtractFilename(df^.RECFilename);
                n:=PasswordForm.ShowModal;
                IF n=mrOK THEN df^.Key:=PasswordForm.edPW1.Text;
                IF n=mrCancel THEN
                  BEGIN
                    CloseFile(ff);
                    TempResult:=sysutils.Deletefile(df^.RECFilename);
                    df^.Key:='User Cancelled';
                    Exit;
                  END;
              FINALLY
                PasswordForm.Free;
              END;  //try..finally
              {$ELSE}
                df^.Key:='';
              {$ENDIF}
            END;  //if key already assigned
        END  //if HasCrypt
      ELSE df^.Key:='';
      {Write No of fields + background colour + FileLabel}
      peWrite(ff,IntToStr(df^.FieldList.Count)+' 1');
      IF NOT df^.EpiInfoFieldNaming THEN peWrite(ff,' VLAB');
      IF df^.Key<>'' THEN peWrite(ff,' ~kq:'+EncryptString(df^.Key,df^.Key)+':kq~');   //&&
      IF trim(df^.FileLabel)<>'' THEN peWrite(ff,' Filelabel: '+df^.Filelabel);
      peWriteEOLN(ff);
      df^.RecLength:=0;
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          WITH PeField(df^.FieldList.Items[n])^ DO
            BEGIN
              {write fieldchar}
              IF (FeltType=ftInteger) OR (FeltType=ftFloat) OR (FeltType=ftIDNUM)
              THEN peWrite(ff,'#') ELSE peWrite(ff,'_');
              peWrite(ff,FormatStr(FName,10));   //Name of field
              peWrite(ff,' ');                   //Space required for some unknown reason
              peWrite(ff,FormatInt(FQuestX,4));  //Question X-position
              peWrite(ff,FormatInt(FQuestY,4));  //Question Y-position
              peWrite(ff,FormatInt(30,4));       //Question colorcode
              peWrite(ff,FormatInt(FFieldX,4));  //Entry X-position
              peWrite(ff,FormatInt(FFieldY,4));  //Entry Y-position
              {Write FieldType
               0=Question without entryfield, i.e. text only
               100+Number of decimals = Floating point number
               For all other: use the fieldtype-code (FeltType)}
              IF FeltType=ftQuestion THEN peWrite(ff,FormatInt(0,4))
                ELSE IF (FeltType=ftFloat) AND (FNumDecimals>0) THEN peWrite(ff,FormatInt(100+fNumDecimals,4))
                  ELSE peWrite(ff,FormatInt(ORD(FeltType),4));
              {Write length of field - use 0 for text only}
              IF FeltType=ftQuestion THEN peWrite(ff,FormatInt(0,4))
              ELSE
                BEGIN
                  peWrite(ff,FormatInt(FLength,4));
                  df^.RecLength:=df^.RecLength+FLength;
                END;
              {write entry colorcode - special use in encrypted fields (holds entrylength of field)}
              IF FeltType<>ftCrypt THEN colorN:=112   //&&
              ELSE
                BEGIN
                  IF FCryptEntryLength<15 THEN colorN:=111+FCryptEntryLength ELSE colorN:=FCryptEntryLength;
                END;  //else
              peWrite(ff,FormatInt(colorN,4));         //Entry colorcode
              peWrite(ff,' ');                      //Another unnescessary blank
              peWrite(ff,FOriginalQuest);
              peWriteEOLN(ff);
            END;  //with
        END;  //for n
      WITH df^ DO BEGIN
        Offset:=Filesize(ff);
        CurRecModified:=False;
        ShortRecLength:=RecLength;
        RecLength:=RecLength+((RecLength DIV MaxRecLineLength)+1)*3;  //Add NewLine+LineFeed+Terminatorchar.
        NumRecords:=0;
        CurRecord:=NewRecord;
        HasEOFMarker:=False;
      END;  //with
      CloseFile(ff);
    END  //if TempInt=0
  ELSE TempResult:=False;
  Result:=TempResult;
END;   //function PeekCreateDataFile



// *******************************************************
Function PeekDataFile(df:PDatafileInfo):Boolean;
VAR
  TempResult:Boolean;
  TempInt,TempInt2,nn:Integer;
  NumFields,CurField:Integer;
  TempStr,ss1,ss2,ss3:String;
  FieldChar,Dummy: Char;
  QuestColor,FieldColor,ft: Integer;
  F:TextFile;
  stop: Boolean;
  tmpPassword: String;

BEGIN
  NumFields:=0;
  df^.FieldCheckSum:=0;
  TempResult:=True;
  AssignFile(F,df^.RECFilename);
  {$I-}
  Reset(F);
  TempInt:=IOResult;
  {$I+}
  IF TempInt=0 THEN   //datafile could be opened
    BEGIN
      df^.Offset:=0;
      {Read first line i datafile - number of fields}
      ReadLn(F,eLine);
      eLine:=eLine+' ';
      TempStr:=COPY(eLine,1,POS(' ',eLine)-1);
      IF IsInteger(TempStr) THEN NumFields:=StrToInt(TempStr)
      ELSE
        BEGIN
          CloseFile(F);
          {$IFNDEF epidat}
          ErrorMsg(Format(Lang(20112),[df^.RECfilename]));  //Incorrect format of datafile %s.
          {$ELSE}
          epiErrorCode:=epi_DATAFILE_FORMAT_ERROR;
          {$ENDIF}
          Exit;
        END;
      IF TempResult THEN   //Begin reading the field-info
        BEGIN
          TempInt:=pos('~kq:',eLine);    //&&
          IF TempInt>0 THEN
            BEGIN
              //Datafile contains a crypt-key
              TempInt2:=pos(':kq~',eLine);
              {$IFNDEF epidat}
              IF (TempInt2>0) AND (TempInt2>TempInt) THEN df^.Key:=copy(eLine,TempInt+4,TempInt2-TempInt-4);
              {$ELSE}
              //if used in EpidataIO.DLL then the user-entered password is supplied in df^.Key - therefore use tmpPassword to store password collected from .rec-file
              IF (TempInt2>0) AND (TempInt2>TempInt) THEN tmpPassword:=copy(eLine,TempInt+4,TempInt2-TempInt-4);
              {$ENDIF}
            END;
          TempInt:=Pos('FILELABEL: ',AnsiUpperCase(eLine));
          IF TempInt<>0 THEN df^.Filelabel:=
            Copy(eLine,TempInt+Length('FILELABEL: '),Length(eLine));
          IF Pos(' VLAB',eLine)>0 THEN df^.EpiInfoFieldNaming:=False
            ELSE df^.EpiInfoFieldNaming:=True;
          df^.FieldList.Capacity:=NumFields;
          df^.RecLength:=0;
          df^.IDNumField:=-1;
          {$IFNDEF epidat}
          WITH MainForm.ProgressBar DO BEGIN
            IF NumFields>2 THEN Max:=NumFields-2 ELSE Max:=2;
            Position:=0;
            Visible:=True;
          END;  //with
          MainForm.StatPanel2.Caption:=' '+Lang(20114);  //Reading field information';
          {$ENDIF}
          FOR CurField:=1 to NumFields DO
            BEGIN
              {$IFNDEF epidat}
              MainForm.ProgressBar.Position:=CurField;
              {$ENDIF}
              New(eField);
              TRY
                WITH eField^ DO
                  BEGIN
                    ReadLn(F,FieldChar,FName,FQuestX,FQuestY,QuestColor,FFieldX,FFieldY,
                           ft,FLength,FieldColor,dummy,FQuestion);
                    IF Length(trim(FName))>8 THEN df^.HasLongFieldNames:=True;
                    WHILE Pos('_',FQuestion)>0 DO FQuestion[Pos('_',FQuestion)]:='-';
                    FNumDecimals:=0;
                    IF ft>=100 THEN BEGIN
                      FNumDecimals:=ft-100;
                      Felttype:=ftFloat;
                    END  //if ftFloat
                    ELSE BEGIN
                      FeltType:=ftInteger;
                      FNumDecimals:=0;
                      WHILE ft>ORD(FeltType) DO FeltType:=Succ(FeltType);
                    END;
                    IF FLength=0 THEN FeltType:=ftQuestion;
                    IF (FeltType=ftPhoneNum) or (FeltType=ftLocalNum) THEN FeltType:=ftAlfa;

                    IF (FeltType in [ftCheckBox,ftPhoneNum,ftTime,ftLocalNum,ftRes4,ftRes5]) THEN
                      BEGIN
                        {$IFNDEF epidat}
                        ErrorMsg(Format(Lang(20144),[df^.RECFilename,FieldTypeNames[ORD(FeltType)]]));   //20144=Datafile %s contains a field of the type %s~This fieldtype is not supported by EpiData.
                        MainForm.ProgressBar.Visible:=False;
                        MainForm.StatPanel2.Caption:='';
                        {$ELSE}
                        epiErrorCode:=epi_DATAFILE_FORMAT_ERROR;
                        {$ENDIF}
                        CloseFile(F);
                        Result:=False;
                        Exit;
                      END;
                    FCryptEntryLength:=0;   //&&
                    IF (FeltType=ftCrypt) AND (df^.HasCrypt=False) AND (df^.DontGetPassword=False) THEN   //&&
                      BEGIN
                        {$IFNDEF epidat}
                        df^.HasCrypt:=True;
                        IF FieldColor>111 THEN FCryptEntryLength:=FieldColor-111
                        ELSE FCryptEntryLength:=FieldColor;
                        stop:=False;
                        TempInt2:=0;
                        ss3:=GetPw(df^.RECFilename);
                        IF ss3<>'' THEN df^.Key:=ss3 ELSE
                          BEGIN
                            REPEAT
                              INC(TempInt2);
                              TRY
                                PasswordForm:=TPasswordForm.Create(Application);
                                PasswordForm.lbDatafile.Caption:=ExtractFilename(df^.RECFilename);
                                PasswordForm.DoubleEntry:=False;
                                nn:=PasswordForm.ShowModal;
                                IF nn=mrCancel THEN
                                  BEGIN
                                    df^.Key:='';
                                    stop:=True;
                                  END
                                ELSE
                                  BEGIN
                                    //Check password
                                    TRY
                                      IF PasswordForm.edPW1.text=DecryptString(df^.Key,PasswordForm.edPw1.Text) THEN
                                        BEGIN
                                          df^.Key:=PasswordForm.edPW1.Text;
                                          stop:=True;
                                        END
                                      ELSE ErrorMsg(Lang(9020));   //9020=Incorrect password entered
                                    EXCEPT
                                      ErrorMsg(Lang(9022));   //9022=Error encouted during decryption of password
                                      nn:=mrCancel;
                                      stop:=true;
                                    END;  //try..except
                                  END;
                              FINALLY
                                PasswordForm.Free;
                              END;
                              IF ((TempInt2=3) AND (NOT stop)) or (nn=mrCancel) THEN
                                BEGIN
                                  {$IFNDEF epidat}
                                  MainForm.ProgressBar.Visible:=False;
                                  MainForm.StatPanel2.Caption:='';
                                  {$ELSE}
                                  epiErrorCode:=epi_DATAFILE_FORMAT_ERROR;
                                  {$ENDIF}
                                  stop:=True;
                                  df^.Key:='';
                                  Result:=False;
                                  CloseFile(F);
                                  Exit;
                                END;
                            UNTIL stop;
                          END;  //if password is remembered
                          StorePw(df^.RECFilename,df^.Key);
                        {$ELSE}
                          IF df^.Key<>DecryptString(tmpPassword,df^.Key) THEN
                            BEGIN
                              epiErrorCode:=EPI_INVALID_PASSWORD;
                              Result:=False;
                              CloseFile(F);
                              Exit;
                            END;
                        {$ENDIF}
                      END;   //if Crypt and HasCrypt=False
                    IF FeltType=ftCrypt THEN
                      BEGIN
                        IF FieldColor>111 THEN FCryptEntryLength:=FieldColor-111
                        ELSE FCryptEntryLength:=FieldColor;
                      END;
                    FStartPos:=df^.RecLength+(df^.RecLength DIV MaxRecLineLength)*3;
                    df^.RecLength:=df^.RecLength+FLength;
                    FVariableLabel:=FQuestion;
                    IF NOT (df^.EpiInfoFieldNaming)
                    AND (trim(FVariableLabel)<>'') THEN
                      BEGIN
                        TempStr:=FirstWord(FVariableLabel);
                        Delete(FVariableLabel,Pos(TempStr,FVariableLabel),Length(TempStr));
                      END;

                    ResetCheckProperties(eField);
                    df^.FieldCheckSum:=df^.FieldCheckSum+ORD(eField^.Felttype)
                      +Length(eField^.FQuestion)+eField^.FLength;
                  END;  //with eField
                df^.FieldList.Add(eField);
              EXCEPT
                {$IFNDEF epidat}
                ErrorMsg(Format(Lang(20116),[df^.RECfilename,CurField+1]));  //Error in the datafile %s.~~The field definition in line %d could not be read or interpreted.
                MainForm.ProgressBar.Visible:=False;
                MainForm.StatPanel2.Caption:='';
                {$ELSE}
                epiErrorCode:=epi_DATAFILE_FORMAT_ERROR;
                {$ENDIF}
                CloseFile(F);
                Result:=False;
                Exit;
              END;  //try..except
            END;  //for CurField
          {$IFNDEF epidat}
          MainForm.ProgressBar.Visible:=False;
          MainForm.StatPanel2.Caption:='';
          {$ENDIF}

          WITH df^ DO BEGIN
            ShortRecLength:=RecLength;
            RecLength:=RecLength+(((RecLength-1) DIV MaxRecLineLength)+1)*3;  //Add NewLine+LineFeed+Terminatorchar.
            OffSet:=TextPos(F);
          END;  //with
          GetMem(df^.RecBuf,df^.RecLength);
          CloseFile(F);
          //Assign(df^.Datfile,df^.RECFilename);
          //Reset(df^.Datfile,df^.RecLength);
          df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);   //§§§
          df^.NumFields:=0;
          FOR CurField:=0 TO df^.FieldList.Count-1 DO
            BEGIN
              IF PeField(df^.FieldList.Items[CurField])^.FeltType=ftIDNUM
              THEN df^.IDNUMField:=CurField;
              IF PeField(df^.FieldList.Items[CurField])^.FeltType<>ftQuestion
              THEN INC(df^.NumFields);
            END;
          df^.NumRecords:=PeekCountRecords(df);
          IF df^.NumRecords=-1 THEN
            BEGIN
              {$IFNDEF epidat}
              ErrorMsg(Format(Lang(20118),[df^.RECFilename]));  //'Error in datafile %s.~~One or more records are corrupted.'
              {$ELSE}
              epiErrorCode:=epi_DATAFILE_FORMAT_ERROR;
              {$ENDIF}
              Result:=False;
              Exit;
            END;
        END;  //if fieldinfo can be read
    END //if datafile could be opened
  ELSE
    BEGIN
      {$IFNDEF epidat}
      ErrorMsg(Format(Lang(20108),[df^.RECFilename])+#13+Lang(20208));
      {$ELSE}
      epiErrorCode:=epi_DATAFILE_FORMAT_ERROR;
      {$ENDIF}
      TempResult:=False;
    END;
  PeekDataFile:=TempResult;
END;  //PeekDataFile

// *******************************************************

Function MakeIndexFile(VAR df: PDatafileInfo):Boolean;
VAR
  tmpS: Str30;
  s: String;
  n: Integer;
  CurRec: LongInt;
  tmpRecFile: TextFile;
  AField: PeField;
  HasKeyUnique,ok: Boolean;
BEGIN
  {This function requires datafile to be open and check-file to be read}
  {It leaves the datafile open but the indexfile closed}
  TRY
    AssignFile(df^.IndexFile,df^.IndexFilename);
    Rewrite(df^.IndexFile);
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Lang(21112));   //'Index file could not be created
    {$ELSE}
    epiErrorCode:=epi_CREATE_FILE_ERROR;
    {$ENDIF}
    Result:=False;
    Exit;
  END;  //try..Except

  {Initialize inputfile}
  TRY
    //CloseFile(df^.DatFile);
    df^.Datfile.Free;   //§§§
    df^.Datfile:=NIL;  //§§§
    AssignFile(tmpRecFile,df^.RECFilename);
    Reset(tmpRecFile);
    FOR n:=0 TO df^.FieldList.Count DO
      ReadLn(tmpRecFile,s);
    {filepointer in tmpRecFile now points to first record}
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Format(Lang(20120),[df^.RECFilename]));  //Error reading the datafile %s.
    {$ELSE}
    epiErrorCode:=epi_READ_FILE_ERROR;
    {$ENDIF}
    Result:=False;
    {$I-}
    CloseFile(tmpRecFile);
    n:=IOResult;
    {$I+}
    Exit;
  END;
  {$IFNDEF epidat}
  MainForm.StatPanel2.Caption:=' '+Lang(21114);   //'Building index...'
  MainForm.StatPanel2.Repaint;
  {$ENDIF}
  tmpS:=IntToStr(df^.IndexCount);
  FOR n:=1 TO df^.IndexCount DO
    tmpS:=tmpS+'@'+IntToStr(df^.IndexFields[n]);
  Write(df^.IndexFile,tmpS);
  IF df^.NumRecords>0 THEN
    BEGIN
      FOR CurRec:=1 TO df^.NumRecords DO
        BEGIN
           eReadOnlyNextRecord(df,tmpRecFile);
           FOR n:=1 TO df^.IndexCount DO
             BEGIN
               AField:=PeField(df^.FieldList.Items[df^.IndexFields[n]]);
               IF AField^.Felttype=ftCrypt THEN s:=EncryptString(trim(Copy(AField^.FFieldText,1,21)),df^.Key)
               ELSE s:=trim(Copy(AField^.FFieldText,1,30));    //&&
               tmpS:=s;
               //s:=AField^.FFieldText;    //&&
               //tmpS:=trim(Copy(s,1,30));    //&&
               CASE AField^.Felttype OF
                 ftInteger,ftFloat: tmpS:=FormatNumberToIndex(tmpS); //Format('%30s',[tmpS]);
                 ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday:   //&&
                   tmpS:=Format('%30s',[FloatToStr(mibStrToDate(tmpS,AField^.Felttype))]);
               ELSE
                 tmpS:=Format('%-30s',[tmpS]);
               END;  //case
               Write(df^.IndexFile,tmpS);
             END;  //for n
        END;  //for CurRec
    END;  //if NumRecords>0
  CloseFile(df^.IndexFile);
  CloseFile(tmpRecFile);
  //AssignFile(df^.Datfile,df^.RECFilename);
  //Reset(df^.Datfile);
  df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);   //§§§
  {$IFNDEF epidat}
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel2.Repaint;
  {$ENDIF}
  Result:=True;

  //Check KEY UNIQUE
  FOR n:=1 TO df^.IndexCount DO
    IF df^.IndexIsUnique[n] THEN HasKeyUnique:=True;
  IF HasKeyUnique THEN
    BEGIN
      TRY
        df^.Index:=TMemoryStream.Create;
        df^.Index.LoadFromFile(df^.Indexfilename);
        n:=1;
        ok:=True;
        WHILE (n<=df^.IndexCount) AND (ok) DO
          BEGIN
            IF df^.IndexIsUnique[n] THEN ok:=IndexHasDuplicates(df,n);
            INC(n);
          END;
        Result:=ok;
        IF NOT Result THEN ok:=Sysutils.DeleteFile(df^.Indexfilename);
      FINALLY
        df^.Index.Free;
        df^.Index:=NIL;
      END;  //try..Except
    END;  //if HasKeyUnique
END;  //procedure MakeIndexFile


Function ApplyIndex(VAR df: PDatafileInfo):Boolean;
VAR
  n: Integer;
  tmpS: Str30;
  s:String;
  ok: Boolean;
  iStr: str30;
  piStr: Array[0..30] of byte absolute iStr;
BEGIN
  Result:=True;
  IF df^.IndexCount=0 THEN Exit;
  df^.IndexFilename:=ChangeFileExt(df^.RECFilename,'.eix');
  IF NOT FileExists(df^.IndexFilename) THEN Result:=MakeIndexFile(df);
  IF NOT Result THEN Exit;

  TRY
    df^.Index:=TMemoryStream.Create;
    df^.Index.LoadFromFile(df^.Indexfilename);
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Format(Lang(20122),[df^.IndexFileName]));  //'Index file %s is in use or does not exist.'
    {$ELSE}
    epiErrorCode:=epi_OPEN_FILE_ERROR;
    {$ENDIF}
    Result:=False;
    Exit;
  END;  //try..Except

  IF df^.Index.Size<>(df^.NumRecords*df^.IndexCount*31)+31 THEN
    BEGIN
      df^.Index.Clear;
      Result:=MakeIndexFile(df);
      IF Result THEN
        BEGIN
          TRY
            df^.Index:=TMemoryStream.Create;
            df^.Index.LoadFromFile(df^.Indexfilename);
          EXCEPT
            Result:=False;
          END;  //try..except
        END;
      IF NOT Result THEN
        BEGIN
          df^.Index.Clear;
          Exit;
        END;
    END;

  {Read header record from indexfile}
  TRY
    AssignFile(df^.IndexFile,df^.IndexFilename);
    Reset(df^.IndexFile);
    Seek(df^.IndexFile,FileSize(df^.IndexFile));
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(Format(Lang(20122),[df^.IndexFileName]));  //'Index file %s is in use or does not exist.'
    {$ELSE}
    epiErrorCode:=epi_OPEN_FILE_ERROR;
    {$ENDIF}
    Result:=False;
    Exit;
  END;  //try..Except
  ok:=True;
  df^.Index.Position:=0;
  df^.Index.Read(piStr,31);
  tmpS:=iStr;

//  Read(df^.IndexFile,tmpS);
  tmpS:=tmpS+'@';
  s:=Copy(tmpS,1,Pos('@',tmpS)-1);
  IF (Length(s)=0) or (NOT IsInteger(s)) THEN ok:=False;
  IF ok THEN
    BEGIN
      IF df^.IndexCount<>StrToInt(s) THEN ok:=False;
      IF ok THEN
        BEGIN
          n:=0;
          REPEAT
            INC(n);
            Delete(tmpS,1,Pos('@',tmpS));
            s:=Copy(tmpS,1,Pos('@',tmpS)-1);
            IF (Length(s)=0) OR (NOT IsInteger(s)) THEN ok:=False;
            IF ok THEN IF StrToInt(s)<>df^.IndexFields[n] THEN ok:=False;
          UNTIL (n=df^.IndexCount) or (NOT ok);
        END;  //if ok
    END;  //if ok
  IF NOT ok THEN
    BEGIN
      df^.Index.Clear;
      CloseFile(df^.IndexFile);
      Result:=MakeIndexFile(df);
      IF NOT Result THEN Exit
      ELSE
        BEGIN
          TRY
            df^.Index:=TMemoryStream.Create;
            df^.Index.LoadFromFile(df^.IndexFilename);
            AssignFile(df^.IndexFile,df^.IndexFilename);
            Reset(df^.IndexFile);
          EXCEPT
            Result:=False;
            df^.Index.Clear;
            Exit;
          END;
        END;
    END;
  IF Result THEN DecryptIndex(df);
END;  //procedure ApplyIndex


{$IFNDEF epidat}
Procedure pSetUpLastField(df:PDatafileInfo);
VAR
  T:Integer;
  TStop:Boolean;
BEGIN
  T:=df^.FieldList.Count;
  IF T>0 THEN
    BEGIN
      TStop:=False;
      REPEAT
        DEC(T);
        WITH PeField(df^.FieldList.Items[T])^ DO
          BEGIN
            IF (FeltType <> ftQuestion)
              THEN IF TEntryField(EntryField).CanFocus THEN
                BEGIN
                  LastField:=True;
                  TStop:=True;
                END;  //if CanFocus
          END;  //with
      UNTIL (TStop) or (T=0);
    END;  //if T>0
END;   //procedure pSetUpLastField
{$ENDIF}



FUNCTION TranslateQes(VAR df:PDatafileInfo; VAR LineIn:String):Boolean;

VAR
  n,t,LinNum,FeltStart,FeltSlut,AntalKomma,AntalDecimaler,FeltNr:INTEGER;
  FoersteTegn, LabelNo:Integer;
  L, Indhold, CodeFound:STRING;
  Feltnavn:str10;
  CurTop, CurLeft, CurX: INTEGER;
  ObjWidth,ObjHeight,Tallest:INTEGER;
  TabsInNextField:Integer;
  Lin,MidLin: TStrings;
  OldFont: TFont;

  Procedure ResetField(VAR Afield:PeField);
  BEGIN
    ResetCheckProperties(AField);
    WITH AField^ DO
      BEGIN
        FName:='';
        Felttype:=ftInteger;
        FLength:=0;
        FNumDecimals:=0;
        FQuestion:='';
        FQuestTop:=0;
        FQuestLeft:=0;
        FFieldTop:=0;
        FFieldLeft:=0;
        FFieldWidth:=0;
        LastField:=False;
        FFieldX:=0;
        FFieldY:=0;
        FQuestX:=0;
        FQuestY:=0;
        FOriginalQuest:='';
        FFieldText:='';
        EntryField:=NIL;
      END;
  END;  //procedure ResetField


  FUNCTION GetFieldName(q:STRING):str10;

  VAR
    NoName,TempName2:Str10;
    TempName: String;
    gfN:Integer;
    NameIndex, QIndex:Integer;
    q2:String;
    qChar:String[2];
    FoundName:Boolean;

    procedure GetNameFromCurly;
    VAR
      InBrack:Boolean;

    BEGIN   //GetNameFromCurly
      InBrack:=FALSE;
      NameIndex:=0;
      QIndex:=0;
      while(QIndex<Length(q)) AND (NameIndex<FieldNameLen) DO
        BEGIN
        Inc(QIndex);
        IF q[QIndex] = '{' THEN InBrack:=True
        ELSE IF q[QIndex]='}' THEN InBrack:=False
             ELSE IF InBrack THEN
              if (q[QIndex] in AlfaChars)
                 OR ((NameIndex>0) AND (q[QIndex] in NumChars)) THEN
                BEGIN
                  INC(NameIndex);
                  TempName[NameIndex]:=q[QIndex];
                END;
      END; //While
    END;   //GetNameFromCurly


    procedure StripCommonWords;

    CONST
      NumCommon=27;
      ComWords:packed array[1..NumCommon] of String[10]=
      ('OF',      'AND',    'IF NO',    'IF YES',   'WHO',
       'WHERE',   'WHAT',   'DID',      'WHEN',     'HOW MANY',
       'THE',     'TO',     'IF',       'ARE',      'A',
       'AF',      'OG',     'HVIS IKKE','HVIS',     'HVEM',
       'HVOR',    'HVAD',   'HVORNÅR',  'HVOR MANGE',
       'EN',      'ET',     'ER');
      ComDelims      : set of Char = [' ', ',',':',';'];

    VAR
      ComPosition,ComIndex:Integer;
      OldQuestion:String;

    BEGIN
      OldQuestion:=q;
      ComIndex:=0;
      WHILE(ComIndex<NumCommon) AND (Length(q)>0) DO  //remove common words
        BEGIN
          INC(ComIndex);
          ComPosition:=Pos(ComWords[ComIndex],ANSIUpperCase(q));
          IF ComPosition>0 THEN
          IF
            ((q[ComPosition+Length(ComWords[ComIndex])] in ComDelims) OR
            (ComPosition+Length(ComWords[ComIndex]) = 1+Length(q))) AND
            (((q[ComPosition-1] in ComDelims) OR(ComPosition = 1)) AND
            (Length(q) > 1))
          THEN Delete(q,ComPosition,Length(ComWords[ComIndex])+1);
      END;  //While
      ComPosition:=1;
      WHILE (ComPosition<=Length(q)) DO   //remove non-alfanum chars
        BEGIN
          IF NOT (q[ComPosition] in AlfaNumChars)
            THEN Delete(q,ComPosition,1)
          ELSE INC(ComPosition);
      END;   //while
      IF Length(q)=0 THEN q:=OldQuestion
      ELSE IF (q[1] in NumChars) THEN q:='n'+q;
    END; //StripCommonWords

    FUNCTION NumValidChars(CONST s:String):Integer;
    VAR
      TempNum,TempN:Integer;
    BEGIN
      TempNum:=0;
      FOR TempN:=1 TO Length(s) DO
        IF (s[TempN] in AlfaNumChars) THEN INC(TempNum);
      NumValidChars:=TempNum;
    END;   //NumValidChars



  BEGIN   //GetFieldName
    IF DontMakeFieldNames THEN Exit;
    NoName:=cFill(' ',FieldnameLen);
    TempName:=NoName;
    IF q='' THEN q:=' ';
    q2:='';
    FOR gfN:=1 TO Length(q) DO
      BEGIN
        qChar:=q[gfN];
        IF qChar='ø' THEN qChar:='oe';
        IF qChar='Ø' THEN qChar:='OE';
        IF qChar='æ' THEN qChar:='ae';
        IF qChar='Æ' THEN qChar:='AE';
        IF qChar='å' THEN qChar:='aa';
        IF qChar='Å' THEN qChar:='AA';
        q2:=q2+qChar;
      END;
    q:=q2;

    IF (NOT df^.EpiInfoFieldNaming) AND (trim(q)<>'') THEN
      BEGIN
        {Get fieldname from the first word in the question}
        TempName:=FirstWord(q);
        IF NumValidChars(TempName)=0 THEN TempName:='FIELD1';
        TempName2:=TempName;
        TempName:='';
        FOR gfN:=1 TO Length(TempName2) DO
          IF (TempName2[gfN] in AlfaNumChars) THEN TempName:=TempName+TempName2[gfN];
        IF (TempName[1] in NumChars) THEN TempName:='N'+TempName;
      END;

    IF TempName=NoName THEN
      BEGIN   //Derive fieldname from question
        IF Pos('{',q)>0 THEN GetNameFromCurly;
        IF TempName=NoName THEN  //There were no curly brackets in question
          BEGIN
            StripCommonWords;
            IF NumValidChars(q)=0 THEN
              BEGIN
                IF df^.FieldList.Count>0 THEN
                  BEGIN   //Try to find a name in prev. non-label field
                    gfN:=df^.FieldList.Count;
                    FoundName:=False;
                    WHILE (gfN>0) AND (NOT FoundName) DO
                      BEGIN
                        IF (PeField(df^.FieldList.Items[gfN-1])^.Felttype<>ftQuestion)
                        THEN FoundName:=True;
                        IF NOT FoundName THEN DEC(gfN);
                      END;  //While
                    IF FoundName
                    THEN TempName:=PeField(df^.FieldList.Items[gfN-1])^.FName
                    ELSE TempName:='FIELD1';
                    WHILE Length(TempName)<FieldNameLen DO TempName:=TempName+' ';
                  END;  //if feltliste.count>0
              END    //if numvalidchars=0
            ELSE
              BEGIN   //Construct name from question
                QIndex:=0;
                NameIndex:=0;
                WHILE (QIndex<Length(q)) AND (NameIndex<FieldNameLen) DO
                  BEGIN
                    INC(QIndex);
                    IF (q[QIndex] in AlfaNumChars) THEN
                      BEGIN
                        INC(NameIndex);
                        TempName[NameIndex]:=q[QIndex];
                      END;  //if char in AlfaNumChars
                  END;   //while
              END;   //construct name from question
          END;  //if there were no curly brackets
      END;  //if tempName=NoName

    IF (TempName=' ') or (TempName=Noname) then tempname:='FIELD1';
    //IF AnsiLowercase(TempName)='date' THEN TempName:=TempName+'1';     Funktion fjernet 080404 - bør erstattes med warning
    WHILE Length(TempName)<FieldNameLen DO TempName:=TempName+' ';
    IF Length(TempName)>FieldNameLen THEN TempName:=Copy(TempName,1,FieldNameLen);
    IF NOT NameIsUnique(Tempname,df,FieldNameLen) THEN REPEAT UNTIL NameIsUnique(TempName,df,FieldNameLen);
    Case FieldNameCase OF
      fcUpper: TempName:=AnsiUpperCase(TempName);
      fcLower: TempName:=AnsiLowerCase(TempName);
    END;  //case;
    GetFieldName:=TempName;
  END;   //GetFieldName;

  FUNCTION RemoveCurly(q:STRING):STRING;
  BEGIN
    IF NOT EpiInfoFieldNaming THEN Exit;
    WHILE pos('{',q)>0 DO Delete(q,pos('{',q),1);
    WHILE pos('}',q)>0 DO Delete(q,pos('}',q),1);
    RemoveCurly:=q;
  END;


  PROCEDURE LavLabel;
  BEGIN
    INC(FeltNr);
    FeltNavn:=GetFieldName('Label'+IntToStr(LabelNo));
    INC(LabelNo);
    New(eField);
    ResetField(eField);
    WITH eField^ DO
      BEGIN
        FName:=FeltNavn;
        FeltType:=ftQuestion;
        FLength:=0;
        FQuestion:=L;
        FOriginalQuest:=L;
        FQuestTop:=CurTop+2;
        FQuestLeft:=CurLeft;
        FQuestY:=LinNum+1;
        FQuestX:=CurX;
        {$IFNDEF epidat}
        ObjHeight:=MainForm.Canvas.TextHeight(FQuestion);
        ObjWidth:=MainForm.Canvas.TextWidth(FQuestion);
        {$ENDIF}
        INC(CurLeft,ObjWidth);
        IF ObjHeight>Tallest THEN Tallest:=ObjHeight;
      END;   //with
    df^.FieldList.Add(eField);
    IF Length(L)>80 THEN
      BEGIN
        Delete(L,1,80);
        INC(CurX,80);
       END
    ELSE L:='';
  END;   //procedure LavLabel i procedure Overset



  PROCEDURE LavNrFelt;
  VAR
    tt:Integer;
    s:String[80];
  BEGIN
    FeltStart:=pos('#',L);
    n:=FeltStart;
    WHILE ((L[n]='#') OR (L[n]=',') OR (L[n]='.'))
      AND (n<=LENGTH(L)) DO INC(n);
    DEC(n);
    FeltSlut:=n;
    IF FeltSlut-FeltStart+1>18 THEN    //is numberfield longer than 18 chars?
      BEGIN
        {$IFNDEF epidat}
        MidLin.Append(Format(Lang(20420),[LinNum+1]));  //'Number field in line %d exceeds maximum length of 18 characters:'
        {$ELSE}
        MidLin.Append(Format('Number field in line %d exceeds maximum length of 18 characters:',[LinNum+1]));
        {$ENDIF}
        MidLin.Append(Lin[LinNum]);
        MidLin.Append(' ');
        CreateIndtastningsFormError:=TRUE;
        Delete(L,1,FeltSlut);
        INC(CurX,FeltSlut);
        Exit;
      END;

    Indhold:=COPY(L,FeltStart,FeltSlut-Feltstart+1);
    AntalKomma:=0;
    //Check if number is decimalnumber
    FOR tt:=1 TO Length(Indhold) DO
      IF (Indhold[tt]='.') OR (Indhold[tt]=',') THEN INC(AntalKomma);
    IF (AntalKomma>1) OR (Indhold[Length(Indhold)]='.') OR (Indhold[Length(Indhold)]='.') THEN
      BEGIN
        {$IFNDEF epidat}
        MidLin.Append(Format(Lang(20422),[LinNum+1]));    //'Error in floating point field in line %d:'
        {$ELSE}
        MidLin.Append(Format('Error in floating point field in line %d:',[LinNum+1]));
        {$ENDIF}
        MidLin.Append(Lin[LinNum]);
        MidLin.Append(' ');
        CreateIndtastningsFormError:=TRUE;
        Delete(L,1,FeltSlut);
        INC(CurX,FeltSlut);
      END
    ELSE
      BEGIN
        INC(FeltNr);
        FeltNavn:=GetFieldName(COPY(L,1,FeltStart-1));
        New(eField);
        ResetField(eField);
        AntalDecimaler:=0;
        IF AntalKomma=1 THEN
          BEGIN
            AntalDecimaler:=Length(Indhold)-Pos('.',Indhold);
            IF Pos('.',Indhold)=0 THEN
              AntalDecimaler:=Length(Indhold)-Pos(',',Indhold);
          END;
        WITH eField^ DO
          BEGIN
            FName:=FeltNavn;
            FLength:=FeltSlut-FeltStart+1;
            FNumDecimals:=AntalDecimaler;
            IF (AntalKomma=1) OR (FLength>9) THEN Felttype:=ftFloat
            ELSE Felttype:=ftInteger;
            IF FeltStart>1 THEN    //is there question before the field?
              BEGIN
                FQuestTop:=CurTop+2;
                FQuestLeft:=CurLeft;
                FQuestion:=RemoveCurly(COPY(L,1,FeltStart-1));
                FOriginalQuest:=FQuestion;
                TabsInNextField:=0;
                WHILE FQuestion[Length(FQuestion)]='@' DO
                  BEGIN
                    INC(TabsInNextField);
                    FQuestion:=COPY(FQuestion,1,Length(FQuestion)-1);
                  END;  //While
                FVariableLabel:=trim(FQuestion);
                IF (NOT df^.EpiInfoFieldNaming) AND (trim(FQuestion)<>'') THEN
                  BEGIN
                    s:=FirstWord(FVariableLabel);
                    Delete(FVariableLabel,Pos(s,FVariableLabel),Length(s));
                    FVariableLabel:=trim(FVariableLabel);
                    IF df^.UpdateFieldnameInQuestion THEN
                      BEGIN
                        s:=trim(FirstWord(FQuestion));
                        tt:=Pos(s,FQuestion);
                        Delete(FQuestion,tt,Length(s));
                        Insert(trim(FName),FQuestion,tt);
                        s:=trim(FirstWord(FOriginalQuest));
                        tt:=Pos(s,FOriginalQuest);
                        Delete(FOriginalQuest,tt,Length(s));
                        Insert(trim(FName),FOriginalQuest,tt);
                      END;
                  END;
                FQuestY:=LinNum+1;
                FQuestX:=CurX;
                INC(CurX,Length(FOriginalQuest));  // tidligere FQuestion
                {$IFNDEF epidat}
                ObjHeight:=MainForm.Canvas.TextHeight(FQuestion);
                ObjWidth:=MainForm.Canvas.TextWidth(FQuestion);
                {$ENDIF}
                INC(CurLeft,ObjWidth);
                IF ObjHeight>Tallest THEN Tallest:=ObjHeight;
              END;   //if label before field
            FLength:=FeltSlut-FeltStart+1;
            {$IFNDEF epidat}
            FFieldWidth:=(MainForm.Canvas.TextWidth('9')*(FLength+2))+6;
            {$ENDIF}
            FFieldTop:=CurTop;
            IF TabsInNextField>0 THEN
              BEGIN
                CurLeft:=((Curleft DIV EvenTabValue)+
                      TabsInNextField)*EvenTabValue;
                TabsInNextField:=0;
              END;
            FFieldLeft:=CurLeft;
            FFieldY:=LinNum+1;
            FFieldX:=CurX;
            FFieldText:='';
            INC(CurLeft,FFieldWidth);
            t:=FLength;
          END;   //with eField do
        df^.FieldList.Add(eField);
        Delete(L,1,FeltSlut);
        INC(CurX,t);
      END;  //if AntalKomma>1
  END;  //procedure LavNrFelt i procedure Overset

  PROCEDURE LavTextFelt;
  VAR
    s:String[80];
    tt:Integer;
  BEGIN
    FeltStart:=pos('_',L);
    n:=FeltStart;
    WHILE (L[n]='_') AND (n<=LENGTH(L)) DO INC(n);
    DEC(n);
    FeltSlut:=n;
    IF FeltSlut-FeltStart+1>80 THEN    //is textfield longer than 80 chars?
      BEGIN
        {$IFNDEF epidat}
        MidLin.Append(Format(Lang(20424),[LinNum+1]));  //'Text field in line %d exceeds maximum length of 80 characters:'
        {$ELSE}
        MidLin.Append(Format('Text field in line %d exceeds maximum length of 80 characters:',[LinNum+1]));
        {$ENDIF}
        MidLin.Append(Lin[LinNum]);
        MidLin.Append(' ');
        CreateIndtastningsFormError:=TRUE;
        Delete(L,1,FeltSlut);
        INC(CurX,FeltSlut);
        Exit;
      END;
    INC(FeltNr);
    FeltNavn:=GetFieldName(COPY(L,1,FeltStart-1));
    New(eField);
    ResetField(eField);
    WITH eField^ DO
      BEGIN
        IF FeltStart>1 THEN    //Check for label before field
          BEGIN
            FQuestion:=RemoveCurly(COPY(L,1,FeltStart-1));
            FOriginalQuest:=FQuestion;
            FQuestTop:=CurTop+2;
            FQuestLeft:=CurLeft;
            FQuestY:=LinNum+1;
            FQuestX:=CurX;
            TabsInNextField:=0;
            WHILE FQuestion[Length(FQuestion)]='@' DO
              BEGIN
                INC(TabsInNextField);
                FQuestion:=COPY(FQuestion,1,Length(FQuestion)-1);
              END;  //While
            FVariableLabel:=trim(FQuestion);
            IF (NOT df^.EpiInfoFieldNaming) AND (trim(FQuestion)<>'') THEN
              BEGIN
                s:=FirstWord(FVariableLabel);
                Delete(FVariableLabel,Pos(s,FVariableLabel),Length(s));
                FVariableLabel:=trim(FVariableLabel);
                IF df^.UpdateFieldnameInQuestion THEN
                  BEGIN
                    s:=FirstWord(FQuestion);
                    tt:=Pos(s,FQuestion);
                    Delete(FQuestion,tt,Length(s));
                    Insert(trim(Feltnavn),FQuestion,tt);
                    s:=trim(FirstWord(FOriginalQuest));
                    tt:=Pos(s,FOriginalQuest);
                    Delete(FOriginalQuest,tt,Length(s));
                    Insert(trim(Feltnavn),FOriginalQuest,tt);
                  END;
              END;
            {$IFNDEF epidat}
            ObjHeight:=MainForm.Canvas.TextHeight(FQuestion);
            ObjWidth:=MainForm.Canvas.TextWidth(FQuestion);
            {$ENDIF}
            INC(CurLeft,ObjWidth);
            INC(CurX,Length(FOriginalQuest));  // var tidligere FQuestion
            IF ObjHeight>Tallest THEN Tallest:=ObjHeight;
          END;   //if feltstart>1
        FName:=FeltNavn;
        FLength:=FeltSlut-FeltStart+1;
        {$IFNDEF epidat}
        FFieldWidth:=(MainForm.Canvas.TextWidth('W')*(FLength+2))+6;
        {$ENDIF}
        IF FFieldWidth>450 THEN FFieldWidth:=450;
        FeltType:=ftAlfa;
        FFieldTop:=CurTop;
        IF TabsInNextField>0 THEN
          BEGIN
            CurLeft:=((Curleft DIV EvenTabValue)+TabsInNextField)*EvenTabValue;
            TabsInNextField:=0;
          END;
        FFieldLeft:=CurLeft;
        FFieldX:=CurX;
        FFieldY:=LinNum+1;
        INC(CurLeft,FFieldWidth);
        t:=FLength;
      END;   //with eField do
    df^.FieldList.Add(eField);
    Delete(L,1,FeltSlut);
    INC(CurX,t);
  END;  //procedure LavTextFelt


  PROCEDURE LavAndetFelt;

    procedure AddBasicParameters;
    VAR
      s:String[80];
      tt:Integer;
    BEGIN
      INC(FeltNr);
      FeltNavn:=GetFieldName(COPY(L,1,FeltStart-1));
      New(eField);
      ResetField(eField);
      WITH eField^ DO
        BEGIN
          IF FeltStart>1 THEN    //Check for label before field
            BEGIN
              FQuestion:=RemoveCurly(COPY(L,1,FeltStart-1));
              FOriginalQuest:=FQuestion;
              WHILE FQuestion[Length(FQuestion)]='@' DO
                BEGIN
                  INC(TabsInNextField);
                  FQuestion:=COPY(FQuestion,1,Length(FQuestion)-1);
                END;  //While
              FVariableLabel:=trim(FQuestion);
                IF (NOT df^.EpiInfoFieldNaming) AND (trim(FQuestion)<>'') THEN
                  BEGIN
                    s:=FirstWord(FVariableLabel);
                    Delete(FVariableLabel,Pos(s,FVariableLabel),Length(s));
                    FVariableLabel:=trim(FVariableLabel);
                    IF df^.UpdateFieldnameInQuestion THEN
                      BEGIN
                        s:=FirstWord(FQuestion);
                        tt:=Pos(s,FQuestion);
                        Delete(FQuestion,tt,Length(s));
                        Insert(trim(Feltnavn),FQuestion,tt);
                        s:=trim(FirstWord(FOriginalQuest));
                        tt:=Pos(s,FOriginalQuest);
                        Delete(FOriginalQuest,tt,Length(s));
                        Insert(trim(Feltnavn),FOriginalQuest,tt);
                      END;
                  END;
              FQuestTop:=CurTop+2;
              FQuestLeft:=CurLeft;
              FQuestY:=LinNum+1;
              FQuestX:=CurX;
              {$IFNDEF epidat}
              ObjHeight:=MainForm.Canvas.TextHeight(FQuestion);
              ObjWidth:=MainForm.Canvas.TextWidth(FQuestion);
              {$ENDIF}
              INC(CurLeft,ObjWidth);
              INC(CurX,Length(FOriginalQuest));  // var tidligere FQuestion
              IF ObjHeight>Tallest THEN Tallest:=ObjHeight;
            END;   //if feltstart>1
          FName:=FeltNavn;
          FFieldTop:=CurTop;
          IF TabsInNextField>0 THEN
            BEGIN
              CurLeft:=((Curleft DIV EvenTabValue)+
                    TabsInNextField)*EvenTabValue;
              TabsInNextField:=0;
            END;
          FFieldLeft:=CurLeft;
          FFieldX:=CurX;
          FFieldY:=LinNum+1;
        END;   //with eField do
      df^.FieldList.Add(eField);
      Delete(L,1,FeltSlut);
      CodeFound:='Done';
    END;  //AddBasicParameters


    procedure SetEvenTab;
    VAR
      midstr:STRING;
      SetEvenTabN:INTEGER;
    BEGIN
      midstr:='';
      FOR SetEVenTabN:=1 TO Length(CodeFound) DO
        IF (CodeFound[SetEvenTabN]>='0') AND (CodeFound[SetEvenTabN]<='9')
        THEN midstr:=midstr+CodeFound[SetEvenTabN];
      IF midstr<>'' THEN EvenTabValue:=StrToInt(midstr)
      ELSE
        BEGIN
          {$IFNDEF epidat}
          MidLin.Append(Format(Lang(20426),[LinNum+1]));  //'Error in <TAB EVERY n> command. Number required in line %d:'
          {$ELSE}
          MidLin.Append(Format('Error in <TAB EVERY n> command. Number required in line %d:',[LinNum+1]));
          {$ENDIF}
          MidLin.Append(Lin[LinNum]);
          MidLin.Append(' ');
          CreateIndtastningsFormError:=TRUE;
        END;
      Delete(L,FeltStart,Length(CodeFound));
      CodeFound:='Done';
    END;  //SetEvenTab


    procedure MakeBoolean;
    BEGIN
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FeltType:=ftBoolean;
          FLength:=1;
          {$IFNDEF epidat}
          FFieldWidth:=MainForm.Canvas.TextWidth('W ')+6;
          {$ENDIF}
          INC(CurLeft,FFieldWidth);
          INC(CurX,FLength+2);
        END;  //with
    END;   //makeboolean

    procedure MakeUpperAlfa;
    BEGIN
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FeltType:=ftUpperAlfa;
          FLength:=FeltSlut-FeltStart-1;
          IF FLength>80 THEN
            BEGIN
              FLength:=80;
              {$IFNDEF epidat}
              MidLin.Append(Format(Lang(20428),[LinNum]));  //'Upper-case text field in line %d exceeds maximum length of 80 characters:'
              {$ELSE}
              MidLin.Append(Format('Upper-case text field in line %d exceeds maximum length of 80 characters:',[LinNum]));
              {$ENDIF}
              MidLin.Append(Lin[LinNum]);
              MidLin.Append(' ');
              CreateIndtastningsFormError:=TRUE;
            END;   //if MaxLength>80
          {$IFNDEF epidat}
          FFieldWidth:=(MainForm.Canvas.TextWidth('W')*(FLength+2))+6;
          {$ENDIF}
          IF FFieldWidth>450 THEN FFieldWidth:=450;
          INC(CurLeft,FFieldWidth);
          INC(CurX,FLength+2);
        END;  //with
    END;   //MakeUpperAlfa

    procedure MakeIDNum;
    BEGIN
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FeltType:=ftIDNUM;
          FLength:=FeltSlut-FeltStart-1;
          IF FLength>18 THEN
            BEGIN
              FLength:=18;
              {$IFNDEF epidat}
              MidLin.Append(Format(Lang(20430),[LinNum+1]));  //'IDNUM field in line %d exceeds maximum length of 18 characters:'
              {$ELSE}
              MidLin.Append(Format('IDNUM field in line %d exceeds maximum length of 18 characters:',[LinNum+1]));
              {$ENDIF}
              MidLin.Append(Lin[LinNum]);
              MidLin.Append(' ');
              CreateIndtastningsFormError:=TRUE;
            END;   //if MaxLength>80
          {$IFNDEF epidat}
          FFieldWidth:=(MainForm.Canvas.TextWidth('9')*(FLength+2))+6;
          {$ENDIF}
          IF FFieldWidth>450 THEN FFieldWidth:=450;
          INC(CurLeft,FFieldWidth);
          INC(CurX,FLength+2);
          TRY
            FFieldText:=IntToStr(FirstIDNumber);
          EXCEPT
            FFieldTExt:='1';
          END;
        END;  //with
    END;   //MakeIDNum


    procedure MakeDate;
    VAR
      LengthStr:String[10];
      TempLen:Integer;
      TempType:TFelttyper;
    BEGIN
      TempLen:=Length(CodeFound);
      IF COPY(CodeFound,1,6)='<MM/DD' THEN TempType:=ftDate
      ELSE IF Copy(CodeFound,1,6)='<DD/MM' THEN TempType:=ftEuroDate
      ELSE TempType:=ftYMDDate;     //&&
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FeltType:=TempType;
          FLength:=TempLen-2;
          IF (Flength>10) OR (CreatingFromQesFile) THEN FLength:=10;
          LengthStr:='';
          WHILE Length(LengthStr)<Flength-2 DO LengthStr:=LengthStr+'9';
          {$IFNDEF epidat}
          FFieldWidth:=MainForm.Canvas.TextWidth('//  '+LengthStr)+10;
          {$ENDIF}
          INC(CurLeft,FFieldWidth);
          INC(CurX,FLength+2);
        END;  //with
    END;  //procedure MakeDate

    procedure MakeToday;
    VAR
      TempCode:String;
    BEGIN
      TempCode:=CodeFound;
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FLength:=0;
          IF TempCode='<TODAY-DMY>' THEN BEGIN FeltType:=ftEuroToday;  FLength:=10;  END;
          IF TempCode='<TODAY-MDY>' THEN BEGIN FeltType:=ftToday;  FLength:=10;  END;
          IF TempCode='<TODAY-YMD>' THEN BEGIN FeltType:=ftYMDToday;  FLength:=10;  END;   //&&
          IF TempCode='<TODAY>' THEN BEGIN  FeltType:=ftToday;  FLength:=5;  END;
          IF TempCode='<TODAY/YY>' THEN BEGIN  FeltType:=ftToday;  FLength:=8;  END;
          IF TempCode='<TODAY/YYYY>' THEN BEGIN  FeltType:=ftToday;  FLength:=10;  END;
          IF CreatingFromQesFile THEN FLength:=10;
//          IF TempCode='<TODAY DD/MM>' THEN BEGIN  FeltType:=ftEuroToday;  FLength:=5;  END;
//          IF TempCode='<TODAY DD/MM/YY>' THEN BEGIN  FeltType:=ftEuroToday;  FLength:=8;  END;
//          IF TempCode='<TODAY DD/MM/YYYY>'THEN BEGIN FeltType:=ftEuroToday;  FLength:=10; END;
          IF FLength=0 THEN BEGIN  FeltType:=ftEuroToday;   FLength:=10;  END;
          TempCode:='';
          WHILE Length(TempCode)<Flength-2 DO TempCode:=TempCode+'9';
          {$IFNDEF epidat}
          FFieldWidth:=MainForm.Canvas.TextWidth('//  '+TempCode)+10;
          {$ENDIF}
          INC(CurLeft,FFieldWidth);
          INC(CurX,FLength+2);
          DecodeDate(Date,eYear,eMonth,eDay);
          IF FeltType=ftYMDToday THEN TempCode:=ZeroFormatInteger(eYear)+'/'+ZeroFormatInteger(eMonth)+'/'+ZeroFormatInteger(eDay)    //&&
          ELSE
            BEGIN
              IF FeltType=ftToday THEN TempCode:=ZeroFormatInteger(eMonth)+
                                  '/'+ZeroFormatInteger(eDay)
              ELSE TempCode:=ZeroFormatInteger(eDay)+'/'+ZeroFormatInteger(eMonth);
              IF FLength=8 THEN TempCode:=TempCode+'/'+ZeroFormatInteger(eYear MOD 100);
              IF FLength=10 THEN TempCode:=TempCode+'/'+ZeroFormatInteger(eYear);
            END;
          FFieldText:=TempCode;
        END;  //with
    END;  //procedure MakeToday

    procedure MakeSoundex;
    BEGIN
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FeltType:=ftSoundex;
          FLength:=FeltSlut-FeltStart-1;
          IF FLength>80 THEN FLength:=80;
          {$IFNDEF epidat}
          FFieldWidth:=MainForm.Canvas.TextWidth('W-9999')+4;
          {$ENDIF}
          INC(CurLeft,FFieldWidth);
          INC(CurX,FLength+2);
        END;   //with
    END;   //MakeSoundex

    procedure MakeCrypt;   //&&
    BEGIN
      AddBasicParameters;
      WITH PeField(df^.FieldList.Items[df^.FieldList.Count-1])^ DO
        BEGIN
          FeltType:=ftCrypt;
          FCryptEntryLength:=FeltSlut-FeltStart-1;
          FLength:=GetEncodedLength(FCryptEntryLength);
          IF FCryptEntryLength>60 THEN
            BEGIN
              FCryptEntryLength:=60;
              FLength:=80;
              {$IFNDEF epidat}
              //MidLin.Append(Format(Lang(20428),[LinNum]));  //'Upper-case text field in line %d exceeds maximum length of 80 characters:'
              MidLin.append(Format(Lang(20429),[LinNum]));   //20429=Encrypt field in line %d exceeds maximum length of 60 characters:
              {$ELSE}
              MidLin.Append(Format(Lang(20429),[LinNum]));
              {$ENDIF}
              MidLin.Append(Lin[LinNum]);
              MidLin.Append(' ');
              CreateIndtastningsFormError:=TRUE;
            END;   //if MaxLength>80
          {$IFNDEF epidat}
          FFieldWidth:=(MainForm.Canvas.TextWidth('W')*(FCryptEntryLength+2))+6;
          {$ENDIF}
          IF FFieldWidth>450 THEN FFieldWidth:=450;
          INC(CurLeft,FFieldWidth);
          INC(CurX,FCryptEntryLength+2);
        END;  //with
    END;  //MakeCrypt


  BEGIN   //LavAndetFelt
    FeltStart:=pos('<',L);
    IF pos('>',L)<FeltStart THEN    //Error- < without ending
      BEGIN
        {$IFNDEF epidat}
        MidLin.Append(Format(Lang(20432),[LinNum+1]));  //'A <...> field without closing-bracket in line %d:'
        {$ELSE}
        MidLin.Append(Format('A <...> field without closing-bracket in line %d:',[LinNum+1]));
        {$ENDIF}
        MidLin.Append(Lin[LinNum]);
        MidLin.Append(' ');
        L:='';
        CreateIndtastningsFormError:=TRUE;
      END
    ELSE
      BEGIN
        FeltSlut:=pos('>',L);
        CodeFound:=ANSIUpperCase(COPY(L,FeltStart,FeltSlut-FeltStart+1));
        IF (CodeFound='<Y>') THEN MakeBoolean;
        IF COPY(CodeFound,1,2)='<A' THEN MakeUpperAlfa;
        IF COPY(CodeFound,1,6)='<IDNUM' THEN MakeIDNum;
        IF (COPY(CodeFound,1,6)='<MM/DD') OR
           (COPY(CodeFound,1,6)='<DD/MM') OR
           (CodeFound='<YYYY/MM/DD>') THEN MakeDate;  //&&
        IF COPY(CodeFound,1,6)='<TODAY' THEN MakeToday;
        IF COPY(CodeFound,1,2)='<S' THEN MakeSoundex;
        IF COPY(CodeFound,1,2)='<E' THEN MakeCrypt;  //&&
        IF CodeFound<>'Done' THEN
          BEGIN
            {$IFNDEF epidat}
            MidLin.Append(Format(Lang(20434),[LinNum+1]));  //'Unknown code found in line %d:'
            {$ELSE}
            MidLin.Append(Format('Unknown code found in line %d:',[LinNum+1]));
            {$ENDIF}
            MidLin.Append(Lin[LinNum]);
            MidLin.Append(' ');
            CreateIndtastningsFormError:=TRUE;
            Delete(L,1,FeltSlut);
          END;   //if CodeFound not Done
      END;  //if slut-tegn mangler
  END;  //procedure LavAndetFelt i procedure overset

BEGIN    //procedure TranslateQes
  CreateIndtastningsFormError:=False;
  df^.NumFields:=0;
  Lin:=TStringList.Create;
  Lin.Text:=LineIn;
  {$IFNDEF epidat}
  OldFont:=TFont.Create;
  OldFont.Assign(MainForm.Canvas.Font);
  MainForm.Canvas.Font.Assign(epiDataFormFont);
  {$ENDIF}
  FeltNr:=0;
  MidLin:=TStringList.Create;
  MidLin.Append(' ');
  {$IFNDEF epidat}
  MidLin.Append(Lang(20436));   //'The QES-file contains errors.'
  MidLin.Append(Lang(20438));   //'The following errors were found:');
  {$ELSE}
  MidLin.Append('The QES-file contains errors.'#13'The following errors were found:');
  {$ENDIF}
  MidLin.Append(' ');
  IF lin.Count>999 THEN
    BEGIN
      result:=false;
      CreateIndtastningsFormError:=True;
      MidLin.Append(Lang(20466));  //'The qes-file is too long. Only 999 lines are allowed.'
      lin.Free;
      LineIn:=MidLin.Text;
      MidLin.Free;
      exit;
    END;
  LabelNo:=1;
  TabsInNextField:=0;
  CurTop:=TopMargin;
  {$IFNDEF epidat}
  WITH MainForm.ProgressBar DO BEGIN
    IF Lin.Count>2 THEN Max:=Lin.Count-2 ELSE Max:=Lin.Count;
    Position:=0;
    Visible:=True;
  END;  //with
  {$ENDIF}
  Screen.Cursor:=crHourGlass;
  FOR LinNum:=0 TO Lin.Count-1 DO
    BEGIN
      {$IFNDEF epidat}
      MainForm.ProgressBar.Position:=LinNum;
      //MainForm.StatPanel2.Caption:=' '+Format(Lang(20440),[LinNum]);  //'Building dataform line %d'
      //MainForm.StatPanel2.Repaint;
      {$ENDIF}
      L:=Lin[LinNum];
      CurLeft:=LeftMargin;
      CurX:=1;
      {$IFNDEF epidat}
      Tallest:=MainForm.Canvas.TextHeight('Wg');
      {$ELSE}
      Tallest:=10;
      {$ENDIF}
      IF Trim(L)='' THEN L:='';
      WHILE Length(L)>0 DO
        BEGIN
        //Check which code is first in the line
          FoersteTegn:=9999;
          n:=pos('#',L);
          IF (n<>0) AND (n<FoersteTegn) THEN FoersteTegn:=n;
          n:=pos('_',L);
          IF (n<>0) AND (n<FoersteTegn) THEN FoersteTegn:=n;
          n:=pos('<',L);
          IF (n<>0) AND (n<FoersteTegn) THEN FoersteTegn:=n;
          IF (FoersteTegn=9999) AND (Trim(L)<>'') THEN LavLabel
          ELSE
            BEGIN
              CASE L[FoersteTegn] OF
                '#': LavNrFelt;
                '_': LavTextFelt;
                '<': LavAndetFelt;
              END;  //Case
            END;  //if
          IF trim(L)='' THEN L:='';
        END;  //while
      CurTop:=CurTop+(Tallest DIV 2);
      CASE LineHeight OF
        0: CurTop:=CurTop+Tallest;              //lineheight=1
        1: CurTop:=CurTop+((Tallest*3) DIV 2);  //Lineheight=1½
        2: CurTop:=CurTop+Tallest+Tallest;      //LineHeight=2
      END;
    END;  //for LinNum
  IF df^.FieldList.Count=0 THEN
    BEGIN
      {$IFNDEF epidat}
      MidLin.Append(Lang(20442));   //'No fields found in QES-file.'
      {$ELSE}
      MidLin.Append('No fields found in QES-file');
      {$ENDIF}
      CreateIndtastningsFormError:=TRUE;
    END
  ELSE
    FOR n:=0 TO df^.FieldList.Count-1 DO
      BEGIN
//        ResetField(df^.FieldList.Items[n]);
        IF PeField(df^.FieldList.Items[n])^.FeltType<>ftQuestion
        THEN INC(df^.NumFields);
      END;  //for
  {$IFNDEF epidat}
  MainForm.ProgressBar.Visible:=False;
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel2.Repaint;
  MainForm.Canvas.Font.Assign(OldFont);
  {$ENDIF}
  LineIn:=Midlin.text;
  MidLin.Free;
  Lin.Free;
  OldFont.Free;
  Screen.Cursor:=crDefault;
  Result:=NOT CreateIndtastningsFormError;
END;  //procedure TranslateQes


Function DoRebuildIndex(VAR df: PDatafileInfo): Boolean;
VAR
  tmpStr:String;
  tmpBool:Boolean;
BEGIN
  Result:=False;
  df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
  df^.IndexFilename:=ChangeFileExt(df^.RECFilename,'.eix');
  df^.HasCheckFile:=FileExists(df^.CHKFilename);
  Screen.Cursor:=crHourGlass;
  CheckFileMode:=False;
  IF NOT PeekDatafile(df) THEN
    BEGIN
      Screen.Cursor:=crDefault;
      Exit;
    END;

  IF df^.HasCheckFile THEN
    BEGIN
      IF NOT PeekApplyCheckFile(df,tmpStr) THEN
        BEGIN
          Screen.Cursor:=crDefault;
          {$IFNDEF epidat}
          ErrorMsg(Format(Lang(20800),[df^.CHKFilename])   //The checkfile %s contains errors and cannot be applied.
          +#13#13+Lang(21102));   //'Rebuild Index terminates.'
          {$ELSE}
            epiErrorCode:=EPI_CHECKFILE_ERROR;
          {$ENDIF}
          Exit;
        END;
      IF df^.IndexCount=0 THEN
        BEGIN
          Screen.Cursor:=crDefault;
          {$IFNDEF epidat}
          ErrorMsg(Lang(21104)+#13#13+Lang(21102));  //'No key fields found.~~In order to build an index one or more fields need to have the command KEY in a checkfile.'
          {$ELSE}
            epiErrorCode:=EPI_CHECKFILE_ERROR;
          {$ENDIF}
          Exit;
        END;
      tmpBool:=MakeIndexfile(df);
      Screen.Cursor:=crDefault;
      IF tmpBool THEN
        BEGIN
          Result:=True;
          Exit;
        END
      ELSE
        BEGIN
          {$IFNDEF epidat}
          ErrorMsg(Format(Lang(21108),[df^.RECFilename]));  //Could not create index for %s
          {$ELSE}
          epiErrorCode:=EPI_CHECKFILE_ERROR;
          {$ENDIF}
          Exit;
        END;
    END
  ELSE
    BEGIN
      Screen.Cursor:=crDefault;
      {$IFNDEF epidat}
      ErrorMsg(Lang(21110)    //'Checkfile not found.~~In order to build an index one or more fields need to have the command KEY in a checkfile.'
        +#13#13+Lang(21102));   //'Rebuild Index terminates.')
      {$ELSE}
        epiErrorCode:=EPI_CHECKFILE_ERROR;
      {$ENDIF}
      Exit;
    END;
END;  //function DoRebuildIndex


end.
