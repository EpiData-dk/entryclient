unit SearchUnit;

interface

USES
  Dialogs,Forms,SysUtils,Windows,Classes,Graphics,EpiTypes;

  Procedure ResetFindExOptions(VAR df:PDatafileInfo);
  Procedure FindByExample(VAR df:PDatafileInfo; ShowOldCrit:Boolean; Scope:TScopeStyle; ClearSearch:Boolean);
  Procedure QuitFindByExample(VAR df:PDatafileInfo);



implementation

USES
  MainUnit,FileUnit,DataFormUnit,ProgressUnit;


//VAR
  //FindByExOptions: TFindByExOptions;

Procedure ResetFindExOptions(VAR df:PDatafileInfo);
VAR
  n:Integer;
BEGIN
  IF df^.FindOpt=NIL THEN Exit;
  WITH df^.FindOpt^ DO
    BEGIN
      StartRecord:=-1;
      NumCrites:=0;
      CanUseIndex:=False;
      IF Assigned(FoundRecs) THEN FoundRecs.Free;
      FoundRecs:=NIL;
      Scope:=ssForward;
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
              IF (AField^.Felttype in [ftToday,ftEuroToday, ftYMDtoday,ftIDNUM]) THEN Enabled:=False;
              MaxLength:=AField^.FLength;
              IF AField^.Felttype=ftCrypt THEN MaxLength:=AField^.FCryptEntryLength;
              Color:=FieldColor;
            END;
          IF df^.FieldText<>COLOR_ENDCOLORS THEN TEntryField(AField^.EntryField).Font.Color:=df^.FieldText;
          IF df^.FieldBg<>COLOR_ENDCOLORS THEN TEntryField(AField^.EntryField).Color:=df^.FieldBg;
        END;
    END;
  IF df^.FindOpt^.StartRecord=NewRecord THEN peNewRecord(df)
  ELSE peReadRecord(df,df^.FindOpt^.StartRecord);
  ADatForm.ScrollBox1.Color:=df^.FindOpt^.BckColor;
  df^.IsFinding:=False;
  df^.IsInSearchForm:=False;
  ADatForm.File1.Visible:=True;
  ADatForm.Goto1.Visible:=True;
  ADatForm.Filter1.Visible:=True;
  ADatForm.Fields1.Visible:=False;
  ADatForm.Fields1.Enabled:=False;
  //ADatForm.BorderIcons:=[biSystemMenu, biMinimize, biMaximize];
  MainForm.StatPanel6.Caption:='';
  ADatForm.Invalidate;
END;  //procedure QuitFindByExample

Procedure FindByExample(VAR df:PDatafileInfo; ShowOldCrit:Boolean; Scope:TScopeStyle; ClearSearch:Boolean);
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
    WITH df^.FindOpt^.Crites[cr] DO
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

  Procedure ClearAllSearchFields;
  VAR
    nn: Integer;
  BEGIN
    //Enable and clear all fields
    FOR nn:=0 TO df^.FieldList.Count-1 DO
      BEGIN
        AField:=PeField(df^.FieldList.Items[nn]);
        IF AField^.Felttype<>ftQuestion THEN
          BEGIN
            TEntryField(AField^.EntryField).Text:='';
            TEntryField(AField^.EntryField).MaxLength:=0;
            TEntryField(AField^.EntryField).Enabled:=True;
            IF df^.FieldBg<>COLOR_ENDCOLORS
            THEN TEntryField(AField^.EntryField).Color:=df^.FieldBg ELSE TEntryField(AField^.EntryField).Color:=FieldColor;
          END;
      END;
  END;  //procedure ClearAllSearchFields

  Procedure SetUpSearchForm;
  BEGIN
    IF ClearSearch THEN ResetFindExOptions(df);
    ADatForm:=TDataForm(df^.DatForm);
    df^.FindOpt^.BckColor:=ADatForm.ScrollBox1.Color;
    ADatForm.ScrollBox1.Color:=clAqua;
    df^.FindOpt^.StartRecord:=df^.CurRecord;
    df^.IsFinding:=True;
    df^.IsInSearchForm:=True;
    ADatForm.File1.Visible:=False;
    ADatForm.Goto1.Visible:=False;
    ADatForm.Filter1.Visible:=False;
    ADatForm.Fields1.Visible:=True;
    ADatForm.Fields1.Enabled:=True;
    ADatForm.TypePanel.Caption:=' Press CTRL-F to search, F10 to quit';
    ADatForm.BorderIcons:=[biSystemMenu, biMinimize, biMaximize];
    MainForm.Invalidate;
    ClearAllSearchFields;
  END;  //procedure SetUpSearchForm

BEGIN
  IF df^.FindOpt=NIL THEN
    BEGIN
      New(df^.FindOpt);
      df^.FindOpt^.FoundRecs:=NIL;
      ResetFindExOptions(df);
    END;

  IF (NOT df^.IsFinding) AND (ShowOldCrit) AND (df^.FindOpt^.NumCrites>0) THEN
    BEGIN
      //Edit critiria is called - fill out searchfields with old critiria
      SetUpSearchForm;
      FOR n:=1 TO df^.FindOpt^.NumCrites DO
        BEGIN
          WITH df^.FindOpt^.Crites[n] DO
            BEGIN
              AField:=PeField(df^.FieldList.Items[FieldNo]);
              s:='';
              CASE Opr OF
                opEq:  s:=SearchText;
                opNEq: s:='<>'+SearchText;
                opBW:  s:=SearchText+'*';
                opEW:  s:='*'+SearchText;
                opCON: s:='*'+SearchText+'*';
                opGT:  s:='>'+SearchText;
                opLT:  s:='<'+SearchText;
              END;  //case
            END;  //with
          TEntryField(Afield^.EntryField).Text:=s;
        END;  //for
      Exit;
    END;  //if ShowOldCrit


  IF (NOT df^.IsFinding) AND
     (  (df^.FindOpt^.NumCrites=0)
     OR (ClearSearch)
     OR (ShowOldCrit)  ) THEN
       BEGIN
         SetUpSearchForm;
         IF NOT ShowOldCrit THEN Exit;
       END;


  IF (df^.IsFinding) AND (ClearSearch) THEN
    BEGIN
      ResetFindExOptions(df);
      df^.FindOpt^.StartRecord:=df^.CurRecord;
      ClearAllSearchFields;
      Exit;
    END;

  IF (NOT ShowOldCrit) AND (NOT ClearSearch) THEN
    BEGIN
      IF (df^.IsInSearchForm) THEN
        BEGIN
          //Read search criteria from dataform
          df^.FindOpt^.CanUseIndex:=True;
          FOR n:=0 TO df^.FieldList.Count-1 DO
            BEGIN
              AField:=PeField(df^.FieldList.Items[n]);
              IF AField^.Felttype<>ftQuestion THEN
                BEGIN
                  AEntryField:=TEntryField(AField^.EntryField);
                  s:=AnsiUpperCase(trim(AEntryField.Text));
                  IF s<>'' THEN
                    BEGIN
                      INC(df^.FindOpt^.NumCrites);
                      IF AField^.FIndex=0 THEN df^.FindOpt^.CanUseIndex:=False;
                      WITH df^.FindOpt^.Crites[df^.FindOpt^.NumCrites] DO
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
                                  ResetFindExOptions(df);
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
                                  ResetFindExOptions(df);
                                  TEntryField(PeField(df^.FieldList.Items[n])^.EntryField).SetFocus;
                                  Exit;
                                END;
                            END;
                        END;  //with
                    END;  //if field is not empty
                END;  //if not ftQuestion
              IF df^.FindOpt^.NumCrites=MaxFindExCrites THEN Break;
            END;  //for
            IF df^.FindOpt^.NumCrites=0 THEN
              BEGIN
                ResetFindExOptions(df);
                Exit;
              END;
          QuitFindByExample(df);
        END;  //if not FindAgain


      //Begin the search
      IF df^.FindOpt^.NumCrites>0 THEN
        BEGIN
          TRY
            df^.FindOpt^.Scope:=Scope;
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

            df^.FindOpt^.StartRecord:=df^.CurRecord;
            fCurRec:=df^.CurRecord;
            IF fCurRec=NewRecord THEN
              BEGIN
                CASE df^.FindOpt^.Scope OF
                  ssForward,ssAll: fCurRec:=1;
                  ssBackWard: fCurRec:=df^.Numrecords;
                END;
              END
            ELSE
              BEGIN
                CASE df^.FindOpt^.Scope OF
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
            WITH df^.FindOpt^ DO
              BEGIN
                IF Assigned(FoundRecs) THEN
                  BEGIN
                    FoundRecs.Free;
                    Foundrecs:=NIL;
                  END;
                CurFoundRec:=-1;
              END;  //with

            IF df^.FindOpt^.CanUseIndex THEN
              BEGIN
                ProgressForm.pBar.Position:=ProgressForm.pBar.Max;
                df^.FindOpt^.FoundRecs:=TStringList.Create;
                df^.FindOpt^.FoundRecs.Duplicates:=dupAccept;
                //Make list of found values in TStringList:FoundRecs
                FOR n:=1 TO df^.NumRecords DO
                  BEGIN
                    Found:=False;
                    t:=0;
                    REPEAT
                      INC(t);
                      WITH df^.FindOpt^.Crites[t] DO
                        BEGIN
                          AField:=PeField(df^.FieldList.Items[FieldNo]);
                          s:=AnsiUpperCase(trim(ReadFromIndex(df,AField^.FIndex,n)));
                          Found:=DoTest(s,t,AField);
                        END;  //with
                    UNTIL (NOT found) OR (t=df^.FindOpt^.NumCrites);
                    IF Found THEN df^.FindOpt^.FoundRecs.Add(Format('%30d',[n]));
                  END;  //for
                IF df^.FindOpt^.FoundRecs.Count=0 THEN
                  BEGIN
                    fStop:=True;
                    Found:=False;
                  END
                ELSE
                  BEGIN
                    //One or more records were found
                    WITH df^.FindOpt^ DO
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
                    IF df^.FindOpt^.Scope=ssBackWard THEN
                      BEGIN
                        REPEAT
                          IF StrToInt(df^.FindOpt^.FoundRecs[df^.FindOpt^.CurFoundRec])<fCurRec THEN Found:=True
                          ELSE DEC(df^.FindOpt^.CurFoundRec);
                        UNTIL (df^.FindOpt^.CurFoundRec<0) OR (Found);
                      END
                    ELSE
                      BEGIN
                        REPEAT
                          IF StrToInt(df^.FindOpt^.FoundRecs[df^.FindOpt^.CurFoundRec])>=fCurRec THEN Found:=True
                          ELSE INC(df^.FindOpt^.CurFoundRec);
                        UNTIL (df^.FindOpt^.CurFoundRec>df^.FindOpt^.FoundRecs.Count-1) OR (Found);
                        IF (NOT Found) AND (df^.FindOpt^.Scope=ssAll) THEN
                          BEGIN
                            Found:=True;
                            df^.FindOpt^.CurFoundRec:=0;
                          END;
                      END;
                    IF NOT Found THEN fStop:=True
                    ELSE
                      BEGIN
                        //There is a record with a higher recnumber than fCurRec (ssForward) or lower (ssBackWard)
                        Found:=True;
                        REPEAT
                          eReadOnlyRecord(df,roDat,StrToInt(df^.FindOpt^.FoundRecs[df^.FindOpt^.CurFoundRec]));
                          IF (df^.FindOpt^.IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;
                          IF NOT Found THEN
                            CASE df^.FindOpt^.Scope OF
                              ssForward,ssAll: INC(df^.FindOpt^.CurFoundRec);
                              ssBackWard:      DEC(df^.FindOpt^.CurFoundRec);
                            END;  //case
                        UNTIL (df^.FindOpt^.CurFoundRec>df^.FindOpt^.FoundRecs.Count-1)
                           OR (df^.FindOpt^.CurFoundRec<0)
                           OR (Found);
                        IF NOT Found THEN fStop:=True
                        ELSE fCurRec:=StrToInt(df^.FindOpt^.FoundRecs[df^.FindOpt^.CurFoundRec]);
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
                    WITH df^.FindOpt^.Crites[t] DO
                      BEGIN
                        AField:=PeField(df^.FieldList.Items[FieldNo]);
                        s:=AnsiUpperCase(trim(AField^.FFieldText));
                        Found:=DoTest(s,t,AField);
                      END;  //with
                  UNTIL (NOT found) OR (t=df^.FindOpt^.NumCrites);

                  WITH df^.FindOpt^ DO
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
                IF df^.FindOpt^.StartRecord=NewRecord THEN peNewRecord(df)
                ELSE peReadRecord(df,df^.FindOpt^.StartRecord);
                eDlg(Lang(22402),mtInformation,[mbOK],0);  //'Search string(s) not found.'
              END;
            IF UserAborts THEN peReadRecord(df,df^.FindOpt^.StartRecord);

          EXCEPT
            EnableTaskWindows(WindowList);
            ProgressForm.Free;
            {Leave datafile as normal file}
            CloseFile(roDat);
            df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);
          END;  //try..finally
        END;  //begin search

    END;  //if df^.IsFinding
END;  //Procedure DoFindByExample


end.
