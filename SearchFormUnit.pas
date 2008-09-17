unit SearchFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, EpiTypes, ExtCtrls, Grids;

type
  TSearchForm = class(TForm)
    btnClose: TBitBtn;
    sg: TStringGrid;
    OptionsGroup: TGroupBox;
    CaseCheck: TCheckBox;
    WordsOnlyCheck: TCheckBox;
    IgnoreDeletedCheck: TCheckBox;
    ScopeRadioBox: TRadioGroup;
    ResetBtn: TBitBtn;
    OkBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnClearClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure ShowCritiriasInMemo;
    procedure btnFindForwardClick(Sender: TObject);
    procedure btnFindBackClick(Sender: TObject);
    procedure btnFindForwardKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    //procedure btnHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sgKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure sgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ResetBtnClick(Sender: TObject);
    Procedure ClearCritSamples;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    { Private declarations }
    CritSamplesShown: Boolean;
  public
    { Public declarations }
    theDf: PDataFileInfo;
    chFindNext,chFindPrev,chEdit,chClearAll,chCancel,chHelp: char;
    CallingFieldName: String;
  end;

var
  SearchForm: TSearchForm;

Procedure EnterSearchMode(VAR df:PDatafileInfo);
Procedure ResetFindOptions(VAR df:PDatafileInfo);
Function  Search(Var df:PDatafileInfo; Autosearch: Boolean):Longint;

implementation

{$R *.DFM}

USES
  MainUnit,DataFormUnit,FileUnit,ProgressUnit, LabelEditUnit;

procedure TSearchForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

Procedure ResetFindOptions(VAR df:PDatafileInfo);
VAR
  n:Integer;
BEGIN
  IF df^.FindOpt=NIL THEN Exit;
  WITH df^.FindOpt^ DO
    BEGIN
      //StartRecord:=-1;
      NumCrites:=0;
      CanUseIndex:=False;
      IF Assigned(FoundRecs) THEN FoundRecs.Free;
      FoundRecs:=NIL;
      Scope:=ssAll;
      CurFoundRec:=-1;
      //IgnoreDeleted:=True;
      FOR n:=1 TO MaxFindExCrites DO
        BEGIN
          Crites[n].FieldNo:=-1;
          Crites[n].Opr:=opNone;
          Crites[n].SearchText:='';
        END;  //for
    END;  //with
END;  //procedure ResetFindOptions


Procedure ClearAllSearchFields(VAR df:PDatafileInfo);
VAR
  nn: Integer;
  AField: PeField;
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
          //IF df^.FieldBg<>COLOR_ENDCOLORS
          //THEN TEntryField(AField^.EntryField).Color:=df^.FieldBg ELSE TEntryField(AField^.EntryField).Color:=FieldColor;
        END;
    END;
END;  //procedure ClearAllSearchFields

Procedure DisableAllEntryFields(VAR df:PDatafileInfo);
VAR
  nn: Integer;
  AField: PeField;
BEGIN
  FOR nn:=0 TO df^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[nn]);
      IF AField^.Felttype<>ftQuestion THEN TEntryField(AField^.EntryField).Enabled:=False;
    END;  //for
END;  //procedure DisableAllEntryFields

Procedure ShowCritiriasInFields(VAR df:PDataFileInfo);
VAR
  n:Integer;
  AField: PeField;
  s: String;
BEGIN
  IF df^.FindOpt^.NumCrites>0 THEN
    BEGIN
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
    END;  //if
END;


Procedure SetUpSearchForm(VAR df:PDatafileInfo);
VAR
  ADatForm: TDataForm;
BEGIN
  ADatForm:=TDataForm(df^.DatForm);
  df^.FindOpt^.BckColor:=ADatForm.ScrollBox1.Color;
  //ADatForm.ScrollBox1.Color:=clAqua;
  df^.FindOpt^.StartRecord:=df^.CurRecord;
  ADatForm.File1.Visible:=False;
  ADatForm.Goto1.Visible:=False;
  ADatForm.FindRecord2.Enabled:=False;
  ADatForm.NewRecord1.Enabled:=False;
  ADatForm.Filter1.Visible:=False;
  ADatForm.Fields1.Visible:=True;
  ADatForm.Fields1.Enabled:=True;
  //ADatForm.TypePanel.Caption:=' Press CTRL-F to search, F10 to quit';
  //ADatForm.BorderIcons:=[biSystemMenu, biMinimize, biMaximize];
END;  //procedure SetUpSearchForm


Procedure ReadCritirias(VAR df:PDatafileInfo);
VAR
  n,n2,t:Integer;
  AEntryField: TEntryField;
  AField: PeField;
  s:String;
  ok: Boolean;
BEGIN
  ResetFindOptions(df);
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
                          ResetFindOptions(df);
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
                          ResetFindOptions(df);
                          TEntryField(PeField(df^.FieldList.Items[n])^.EntryField).SetFocus;
                          Exit;
                        END;
                    END;
                END;  //with
            END;  //if field is not empty
        END;  //if not ftQuestion
      IF df^.FindOpt^.NumCrites=MaxFindExCrites THEN Break;
    END;  //for
  IF df^.FindOpt^.NumCrites=0 THEN ResetFindOptions(df);
END;  //procedure ReadCritirias


Function Search(Var df:PDatafileInfo; Autosearch: Boolean):Longint;
VAR
  roDat: TextFile;
  n,t,pStep:Integer;
  WindowList:Pointer;
  fCurRec:Integer;
  fStop,found: Boolean;
  AField,FilterField: PeField;
  s: String;

  Function DoTest(ss:String; cr:Integer; TheField:PeField):Boolean;
  VAR
    tValue: Double;
  BEGIN
    Result:=False;
    WITH df^.FindOpt^.Crites[cr] DO
      BEGIN
        //IF df^.FindOpt^.WholeWordsOnly THEN ss:=AnsiUpperCase(ss);
        IF (NOT df^.FindOpt^.CaseSensitive) THEN ss:=AnsiUpperCase(ss);
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
  //Begin the search
  IF df^.FindOpt^.NumCrites>0 THEN
    BEGIN
      TRY
        {Prepare datafile for readonly}
        df^.Datfile.Free;
        df^.Datfile:=NIL;
        AssignFile(roDat,df^.RECFilename);
        Reset(roDat);

        IF NOT AutoSearch THEN
          BEGIN
            ProgressForm:=TProgressForm.Create(MainForm);
            ProgressForm.Caption:=Lang(22400);   //'Searching record'
            ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
            ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
            IF df^.NumRecords>60 THEN pStep:=df^.NumRecords DIV 20 ELSE pStep:=20;
            ProgressForm.pBar.Step:=pStep;
            WindowList:=DisableTaskWindows(ProgressForm.Handle);
          END;

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
        IF NOT Autosearch THEN ProgressForm.Show;
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
            IF NOT Autosearch THEN ProgressForm.pBar.Position:=ProgressForm.pBar.Max;
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
                      s:=trim(ReadFromIndex(df,AField^.FIndex,n));
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
                      IF (df^.UseFilter) then
                        begin
                          FilterField:=PeField(df^.FieldList.items[df^.FilterField]);
                          if FilterField^.FFieldText<>df^.FilterText then Found:=false;
                        end;

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
                    s:=trim(AField^.FFieldText);
                    Found:=DoTest(s,t,AField);
                  END;  //with
              UNTIL (NOT found) OR (t=df^.FindOpt^.NumCrites);

              WITH df^.FindOpt^ DO
                BEGIN
                  IF (IgnoreDeleted) AND (df^.CurRecDeleted) THEN Found:=False;
                  IF (df^.UseFilter) then
                    begin
                      FilterField:=PeField(df^.FieldList.items[df^.FilterField]);
                      if FilterField^.FFieldText<>df^.FilterText then Found:=false;
                    end;

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
                      IF (NOT Autosearch) AND ((fCurRec MOD pStep)=0) THEN
                        BEGIN
                          ProgressForm.pBar.StepIt;
                          ProgressForm.pLabel.Caption:=Format(Lang(22404),[fCurRec]);  //'Searching in record %d'
                          Application.ProcessMessages;
                        END;
                    END;  //if not found
                END;  //with
            UNTIL (Found) or (fStop) or (UserAborts);
          END;  //if not CanUseIndex

        IF NOT Autosearch THEN
          BEGIN
            EnableTaskWindows(WindowList);
            ProgressForm.Free;
          END;

        {Leave datafile as normal file}
        CloseFile(roDat);
        df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);  //§§§

        IF Found THEN
          BEGIN
            IF Autosearch THEN Result:=fCurRec
            ELSE
              BEGIN
                peReadRecord(df,fCurRec);
                df^.FindOpt^.StartRecord:=fCurRec;
              END;
          END;

        IF fStop THEN
          BEGIN
            IF (NOT Autosearch) THEN
              BEGIN
                IF df^.FindOpt^.StartRecord=NewRecord THEN peNewRecord(df)
                ELSE peReadRecord(df,df^.FindOpt^.StartRecord);
                eDlg(Lang(22402),mtInformation,[mbOK],0);  //'Search string(s) not found.'
              END
            ELSE Result:=-1;
          END;
        IF UserAborts THEN
          BEGIN
            IF Autosearch THEN Result:=-2
            ELSE peReadRecord(df,df^.FindOpt^.StartRecord);
          END;

      EXCEPT
        IF NOT Autosearch THEN EnableTaskWindows(WindowList);
        IF NOT Autosearch THEN ProgressForm.Free;
        {Leave datafile as normal file}
        CloseFile(roDat);
        df^.Datfile:=TFileStream.Create(df^.RECFilename,fmOpenReadWrite OR fmShareExclusive);
      END;  //try..finally
    END;  //begin search
END;   //procedure Search


Procedure EnterSearchMode(VAR df:PDatafileInfo);
BEGIN
  SearchForm:=TSearchForm.Create(TDataForm(df^.DatForm));
  IF SearchBoxPos.x>=0 THEN SearchForm.Left:=SearchBoxPos.x;
  IF SearchBoxPos.y>=0 THEN SearchForm.Top:=SearchBoxPos.y;
  SearchForm.theDf:=df;
  df^.SearchForm:=TObject(SearchForm);
  SearchForm.Show;
  IF df^.FindOpt=NIL THEN
    BEGIN
      New(df^.FindOpt);
      df^.FindOpt^.FoundRecs:=NIL;
    END;
  df^.IsFinding:=True;
  df^.IsInSearchForm:=True;
  ResetFindOptions(df);
  df^.FindOpt^.StartRecord:=df^.CurRecord;
  SetUpSearchForm(df);
  ClearAllSearchFields(df);
  MainForm.SetFocus;
END;        //procedure EnterSearchMode

procedure TSearchForm.FormClose(Sender: TObject; var Action: TCloseAction);
VAR
  n:Integer;
  ADatForm: TDataForm;
  AField: PeField;
  AEntryField: TEntryField;
BEGIN
  //set old enabled state for fields
{  ADatForm:=TDataForm(theDf^.DatForm);
  FOR n:=0 TO theDf^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(theDf^.FieldList.Items[n]);
      IF AField^.Felttype<>ftQuestion THEN
        BEGIN
          WITH TEntryField(AField^.EntryField) DO
            BEGIN
              Enabled:=(NOT AField^.FNoEnter);
              IF (AField^.Felttype in [ftToday,ftEuroToday, ftYMDtoday,ftIDNUM]) THEN Enabled:=False;
              MaxLength:=AField^.FLength;
              IF AField^.Felttype=ftCrypt THEN MaxLength:=AField^.FCryptEntryLength;
              Color:=FieldColor;
            END;  //with
        END;  //if not ftQuestion
    END;  //for
  ADatForm.ActiveControl:=TWinControl(theDf^.LatestActiveControl);
  theDf^.IsFinding:=False;
  theDf^.IsInSearchForm:=False;
  IF theDf^.FindOpt^.StartRecord=NewRecord THEN peNewRecord(theDf)
  ELSE peReadRecord(theDf,theDf^.FindOpt^.StartRecord);
  //ADatForm.ScrollBox1.Color:=theDf^.FindOpt^.BckColor;
  ADatForm.File1.Visible:=True;
  ADatForm.Goto1.Visible:=True;
  ADatForm.NewRecord1.Enabled:=True;
  ADatForm.FindRecord2.Enabled:=True;
  ADatForm.Filter1.Visible:=True;
  ADatForm.Fields1.Visible:=False;
  ADatForm.Fields1.Enabled:=False;
  //ADatForm.BorderIcons:=[biSystemMenu, biMinimize, biMaximize];
  //ADatForm.Invalidate;
  MainForm.SetFocus;
  SearchBoxPos.x:=Self.Left;
  SearchBoxPos.y:=Self.Top;}
end;

procedure TSearchForm.btnClearClick(Sender: TObject);
begin
  ClearAllSearchFields(theDf);
  ResetFindOptions(theDf);
//  CritMemo.Lines.Clear;
end;

procedure TSearchForm.btnEditClick(Sender: TObject);
begin
  ClearAllSearchFields(theDf);
  ShowCritiriasInFields(theDf);
  theDf^.IsInSearchForm:=True;
end;

procedure TSearchForm.ShowCritiriasInMemo;
VAR
  n:Integer;
  AField: PeField;
  s: String;
BEGIN
//  CritMemo.Lines.Clear;
  IF theDf^.FindOpt^.NumCrites>0 THEN
    BEGIN
      FOR n:=1 TO theDf^.FindOpt^.NumCrites DO
        BEGIN
          WITH theDf^.FindOpt^.Crites[n] DO
            BEGIN
              AField:=PeField(theDf^.FieldList.Items[FieldNo]);
              s:=trim(AField^.FName)+' ';
              CASE Opr OF
                opEq:  s:=s+'='+SearchText;
                opNEq: s:=s+'<>'+SearchText;
                opBW:  s:=s+'='+SearchText+'*';
                opEW:  s:=s+'='+'*'+SearchText;
                opCON: s:=s+'=*'+SearchText+'*';
                opGT:  s:=s+'>'+SearchText;
                opLT:  s:=s+'<'+SearchText;
              END;  //case
            END;  //with
//          CritMemo.Lines.Append(s);
        END;  //for
      //CritMemo.Lines.Append('currec='+InttoStr(theDf^.CurRecord));
      //CritMemo.Lines.Append('Start='+IntToStr(theDf^.findopt^.StartRecord));
    END;  //if
END;

procedure TSearchForm.btnFindForwardClick(Sender: TObject);
begin
  IF theDf^.IsInSearchForm THEN
    BEGIN
      ReadCritirias(theDf);
      DisableAllEntryFields(theDf);
      theDf^.IsInSearchForm:=False;
      ShowCritiriasInMemo;
    END;
  Search(theDf,false);
end;

procedure TSearchForm.btnFindBackClick(Sender: TObject);
begin
  IF theDf^.IsInSearchForm THEN
    BEGIN
      ReadCritirias(theDf);
      DisableAllEntryFields(theDf);
      theDf^.IsInSearchForm:=False;
      ShowCritiriasInMemo;
    END;
  Search(theDf,false);
end;

procedure TSearchForm.btnFindForwardKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF Key=27 THEN Close;
end;




procedure TSearchForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
VAR
  n,n2,t,FNum: Integer;
  s: String;
  AField: PeField;
  ok: Boolean;
begin
  CanClose:=True;
  IF ModalResult=mrOK THEN
    BEGIN
      IF CritSamplesShown THEN ClearCritSamples;
      ResetFindOptions(TheDf);
      theDf^.FindOpt^.CanUseIndex:=True;
      FOR n:=0 TO 9 DO
        BEGIN
          IF trim(sg.Cells[0,n])<>'' THEN
            BEGIN
              FNum:=GetFieldNumber(sg.Cells[0,n],theDf);
              IF FNum<>-1
              THEN AField:=Pefield(theDf^.FieldList.Items[FNum])
              ELSE AField:=NIL;
              IF AField=NIL THEN
                BEGIN
                  ErrorMsg(Lang(22708)+': '+sg.Cells[0,n]);   //22708=Unknown field name
                  sg.Col:=0;
                  sg.Row:=n;
                  CanClose:=False;
                  sg.SetFocus;
                  Exit;
                END;
            END;
          s:=trim(sg.Cells[1,n]);   //get the critiria
          IF (s='') AND (trim(sg.Cells[0,n])<>'') THEN
            BEGIN
              ErrorMsg(Format(Lang(22408),[sg.Cells[0,n]]));   //22408=Searchcritiria is missing for field %s
              sg.Col:=1;
              sg.Row:=n;
              CanClose:=False;
              sg.SetFocus;
              Exit;
            END
          ELSE IF s<>'' THEN
            BEGIN
              //Read search criteria
              s:=trim(sg.Cells[1,n]);
              IF NOT CaseCheck.Checked THEN s:=AnsiUpperCase(s);
              INC(theDf^.FindOpt^.NumCrites);
              IF AField^.FIndex=0 THEN theDf^.FindOpt^.CanUseIndex:=False;
              WITH theDf^.FindOpt^.Crites[theDf^.FindOpt^.NumCrites] DO
                BEGIN
                  FieldNo:=FNum;
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
                  IF (WordsOnlyCheck.Checked=False) AND (Opr=opEq) THEN
                    BEGIN
                      s:='*'+s+'*';
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
                          ErrorMsg(Format(Lang(22410)+#13+   //22410=Error in critiria %s~~The wildcard * can only be used with this syntax:
                                   '*abcd'#13'*abcd*'#13'abcd*',[s]));
                          ResetFindOptions(theDf);
                          sg.Col:=1;
                          sg.Row:=n;
                          CanClose:=False;
                          sg.SetFocus;
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
                          ErrorMsg(Format(Lang(22412),[s]));   //22412=Error in critiria %s~~Field is numeric
                          ResetFindOptions(theDf);
                          sg.Col:=1;
                          sg.Row:=n;
                          CanClose:=False;
                          sg.SetFocus;
                          Exit;
                        END;
                    END;  //if numeric
                END;  //with
            END;  //if critiria is not empty
          IF theDf^.FindOpt^.NumCrites=MaxFindExCrites THEN Break;
        END;  //for
      IF theDf^.FindOpt^.NumCrites=0 THEN ResetFindOptions(theDf);
      WITH theDF^.FindOpt^ DO
        BEGIN
          CaseSensitive:=CaseCheck.Checked;
          WholeWordsOnly:=WordsOnlyCheck.Checked;
          IgnoreDeleted:=IgnoreDeletedCheck.Checked;
          CASE ScopeRadioBox.ItemIndex OF
            0: Scope:=ssForward;
            1: Scope:=ssBackward;
            2: Scope:=ssAll;
          END;  //case
        END;  //with
    END;  //if mrOK
end;

procedure TSearchForm.sgKeyPress(Sender: TObject; var Key: Char);
begin
  IF Key=#13 THEN
    BEGIN
      IF (sg.Cells[0,0]<>'') AND (sg.Cells[1,0]<>'') THEN ModalResult:=mrOK;
      {IF sg.Cells[sg.Col,sg.Row]='' THEN ModalResult:=mrOK
      ELSE
        BEGIN
          IF (sg.Col=0) THEN sg.Col:=1
          ELSE IF (sg.Col=1) AND (sg.Row<9) THEN
            BEGIN
              sg.Col:=0;
              sg.Row:=sg.Row+1;
            END;

          sg.SetFocus;
        END;}
    END;
end;

procedure TSearchForm.FormActivate(Sender: TObject);
begin
  sg.SetFocus;
  sg.EditorMode:=True;
end;

procedure TSearchForm.sgKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
VAR
  AField: PeField;
  n,n2: Integer;
begin
  IF (Key=VK_F4) AND (sg.Col=0) THEN
    BEGIN
      Key:=0;
      n:=TDataForm(theDf^.DatForm).ShowFieldSelect(AField);
      IF n=mrOK THEN
        BEGIN
          //Find unused row
          n2:=0;
          REPEAT
            IF trim(sg.Cells[0,n2])=''
            THEN
              BEGIN
                sg.Cells[0,n2]:=trim(AField^.FName);
                sg.col:=1;
                sg.row:=n2;
              END
            ELSE INC(n2);
          UNTIL (sg.Cells[0,n2]=trim(Afield^.FName)) OR (n2=sg.RowCount);
        END;
    END;
end;

procedure TSearchForm.FormShow(Sender: TObject);
begin
  WITH theDF^.FindOpt^ DO
    BEGIN
      CaseCheck.Checked:=CaseSensitive;
      WordsOnlyCheck.Checked:=WholeWordsOnly;
      IgnoreDeletedCheck.Checked:=IgnoreDeleted;
      ScopeRadioBox.ItemIndex:=ORD(Scope);
    END;
end;

procedure TSearchForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  CritSamplesShown:=True;
  WITH sg DO
    BEGIN
      Cells[0,5]:=Lang(22414);   //22414=Criteria samples:
      Cells[0,6]:='abcd';
      Cells[0,7]:='=abcd';
      Cells[0,8]:='<1234';
      Cells[0,9]:='>1234';
      Cells[1,6]:='<>abcd';
      Cells[1,7]:='*abcd';
      Cells[1,8]:='abcd*';
      Cells[1,9]:='*abcd*';
    END;
end;

procedure TSearchForm.sgSelectCell(Sender: TObject; ACol, ARow: Integer;  var CanSelect: Boolean);
begin
  IF sg.row>=3 THEN ClearCritSamples;
  CanSelect:=True;
end;

procedure TSearchForm.ResetBtnClick(Sender: TObject);
VAR
  n: Integer;
begin
  FOR n:=0 TO 9 DO
    BEGIN
      sg.Cells[0,n]:='';
      sg.Cells[1,n]:='';
    END;
  IF CallingFieldName<>'' THEN sg.Cells[0,0]:=CallingfieldName;
  FormCreate(Sender);
  sg.Row:=0;
  sg.Col:=1;
end;

Procedure TSearchForm.ClearCritSamples;
VAR
  n:Integer;
BEGIN
  FOR n:=6 TO 9 DO
    BEGIN
      sg.Cells[0,n]:='';
      sg.Cells[1,n]:='';
    END;
  sg.Cells[0,5]:='';
  CritSamplesShown:=False;
END;

procedure TSearchForm.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
VAR
  n:Integer;
begin
  //sg.Col:=0;
  //sg.Row:=0;
  IF (Key=VK_F4) THEN
    BEGIN
      sg.Col:=0;
      sg.Row:=0;
      sgKeyDown(Sender,Key,[]);
      sg.SetFocus;
//      n:=TDataForm(theDf^.DatForm).ShowFieldSelect(AField);
//      IF n=mrOK THEN sg.Cells[sg.Col,sg.Row]:=trim(AField^.FName);
    END;

end;

end.
