unit CountValuesUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TCountForm = class(TForm)
    EvalList: TListBox;
    FieldList: TListBox;
    FilenameEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SearchBtn: TBitBtn;
    AddBtn: TBitBtn;
    RemoveBtn: TBitBtn;
    Label3: TLabel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    BitBtn1: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure MakeFieldList;
    procedure AddBtnClick(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CountForm: TCountForm;

Procedure CountValues;

implementation

{$R *.DFM}

USES EpiTypes, MainUnit, FileUnit, EdUnit;

CONST
  MaxFiles=25;

TYPE
  PCountRec=^TCountRec;
  TCountRec=Array[1..MaxFiles] OF Integer;

VAR
  tmpList,Res:   TStringList;
  Filenames:     Array[1..MaxFiles] of TFilename;
  Fields:        Array[1..MaxFiles] of TStringList;
  IsActive:      Array[1..MaxFiles] of Boolean;
  MaxValueWidth: Array[0..MaxFiles] of Integer;
  EvalField:     String;
  CountRec:      PCountRec;
  AField:        PeField;
  df:            PDatafileInfo;
  F:             TextFile;
  LastDir:       String;

Procedure CountValues;
VAR
  CurDf,CurRec,FileNum: Integer;
  ok,tmpBool:Boolean;
  n,t,n2,LineWidth:Integer;
  s,tmpS,FormStr:String;
  AEdForm: TEdForm;
BEGIN
  tmpList:=TStringList.Create;
  CountForm:=TCountForm.Create(MainForm);
  IF CountForm.ShowModal=mrOK THEN
    BEGIN
      TRY
        Screen.Cursor:=crHourGlass;
        tmpList.Clear;
        df:=NIL;
        Res:=TStringList.Create;
        Res.Append(Lang(23700)+' '+EvalField);  //'Count of records based on field'
        Res.Append('');
        Res.Append(Lang(23702));   //'Selected files:'
        FileNum:=0;
        FOR CurDf:=1 TO MaxFiles DO
          BEGIN
            IF IsActive[CurDf] THEN
              BEGIN
                INC(FileNum);
                MaxValueWidth[CurDf]:=0;
                tmpS:=Filenames[CurDf];
                ok:=GetDatafilePointer(df);
                IF ok THEN
                  BEGIN
                    df^.RECFilename:=tmpS;
                    ok:=PeekDatafile(df);
                  END;
                IF NOT ok THEN tmpS:=tmpS+'  '+Lang(23704)     //'COULD NOT BE OPENED'
                ELSE IF df^.NumRecords=0 THEN tmpS:=tmpS+'  '+Lang(23706)    //'CONTAINS NO RECORDS'
                ELSE
                  BEGIN
                    //CloseFile(df^.Datfile);
                    df^.Datfile.Free;   //§§§
                    df^.Datfile:=NIL;  //§§§
                    AssignFile(F,df^.RECFilename);
                    Reset(F);
                    FOR n:=0 TO df^.FieldList.Count DO ReadLn(F,s);
                    AField:=GetField(EvalField,df);
                    FOR CurRec:=1 TO df^.NumRecords DO
                      BEGIN
                        eReadOnlyNextRecord(df,F);
                        s:=trim(AField^.FFieldText);
                        IF (AField^.Felttype in [ftInteger,ftFloat,ftIDNUM])
                        THEN s:=Format('%30s',[s]);
                        n:=tmpList.IndexOf(s);
                        IF n=-1 THEN
                          BEGIN
                            {Value encountered for the first time}
                            New(CountRec);
                            FOR t:=1 TO MaxFiles DO CountRec^[t]:=0;
                            CountRec^[CurDf]:=1;
                            tmpList.AddObject(s,TObject(CountRec));
                            IF Length(trim(s))>MaxValueWidth[0] THEN MaxValueWidth[0]:=Length(trim(s));
                            MaxValueWidth[CurDf]:=1;
                          END
                        ELSE
                          BEGIN
                            CountRec:=PCountRec(tmpList.Objects[n]);
                            INC(CountRec^[CurDf]);
                            IF Length(IntToStr(CountRec^[CurDf]))>MaxValueWidth[CurDf]
                            THEN MaxValueWidth[CurDf]:=Length(IntToStr(CountRec^[CurDf]));
                          END;
                      END;  //for CurRec
                    CloseFile(F);
                    DisposeDatafilePointer(df);
                  END;  //if datafile was opened
                tmpS:=Format(Lang(23708),[FileNum,tmpS]);  //'File %d = %-s'
                Res.Append(tmpS);
              END;  //if IsActive
          END;  //for CurDf
        Res.Append('');
        Res.Append(Format(Lang(23710),[tmpList.Count,EvalField]));   //'%d different values for %s found'
        Res.Append('');
        IF MaxValueWidth[0]<10 THEN MaxValueWidth[0]:=10;
        IF MaxValueWidth[0]>30 THEN MaxValueWidth[0]:=30;
        FormStr:='%-'+IntToStr(MaxValueWidth[0])+'s ';
        LineWidth:=maxValueWidth[0]+1;
        n2:=0;
        FOR n:=1 TO MaxFiles DO
          BEGIN
            IF IsActive[n] THEN
              BEGIN
                INC(n2);
                IF MaxValueWidth[n]<4 THEN MaxValueWidth[n]:=4;
                IF MaxValueWidth[n]>12 THEN MaxValueWidth[n]:=12;
                FormStr:='%'+IntToStr(MaxValueWidth[n])+'s ';
                LineWidth:=LineWidth+MaxValueWidth[n]+1;
              END;
          END;
        tmpList.Sort;
        {write tabel heading}
        Res.Append(cFill(' ',MaxValueWidth[0]+MaxValueWidth[1])+Lang(23712));  //'Files'
        s:=Format('%-'+IntToStr(MaxValueWidth[0])+'s ',[EvalField]);
        n2:=0;
        FOR n:=1 TO MaxFiles DO
          BEGIN
            IF IsActive[n] THEN
              BEGIN
                INC(n2);
                s:=s+Format('%'+IntToStr(MaxValueWidth[n])+'d ',[n2]);
              END;
          END;
        Res.Append(s);
        Res.Append(cFill('-',LineWidth));
        {write count list}
        FOR n:=0 TO tmpList.Count-1 DO
          BEGIN
            s:=Format('%-'+IntToStr(MaxValueWidth[0])+'s ',[trim(tmpList[n])]);
            CountRec:=PCountRec(tmpList.Objects[n]);
            FOR t:=1 TO MaxFiles DO
              BEGIN
                IF IsActive[t] THEN
                  BEGIN
                    IF CountRec^[t]=0
                    THEN s:=s+Format('%'+IntToStr(MaxValueWidth[t])+'s ',['.'])
                    ELSE s:=s+Format('%'+IntToStr(MaxValueWidth[t])+'d ',[CountRec^[t]]);
                  END;
              END;  //for t
            Res.Append(s);
          END;  //for n
        Res.Append(cFill('-',LineWidth));
        Res.SaveToFile('resoutput.lo$');
        AEdForm:=TEdForm.Create(MainForm);
        WITH AEdForm DO
          BEGIN
            Open('resoutput.lo$');
            CloseFile(BlockFile);
            PathName:=DefaultFilename+IntToStr(WindowNum);
            Caption:=Lang(23714);    //'Count values'
            MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
              IndexOfObject(TObject(AEdForm))]:=DefaultFilename+IntToStr(WindowNum);
            FormType:=ftDocumentation;
            Ed.Font.Assign(epiDocuFont);
            Ed.SelStart:=0;
            Ed.Modified:=True;
          END;  //with
        tmpBool:=DeleteFile('resoutput.lo$');
      FINALLY
        Screen.Cursor:=crDefault;
        FOR n:=0 TO tmpList.Count-1 DO
          IF Assigned(tmpList.Objects[n]) THEN Dispose(PCountRec(tmpList.Objects[n]));
        {$I-}
        CloseFile(F);
        n:=IOResult;
        {$I+}
        DisposeDatafilePointer(df);
        Res.Free;
      END;  //try..finally
    END;  //if mrOK
  tmpList.Free;
  CountForm.Free;
END;



procedure TCountForm.FormCreate(Sender: TObject);
VAR
  n:Integer;
begin
  TranslateForm(self);
  OpenDialog1.Filter:=Lang(2104)+'|*.rec|'+Lang(2112)+'|*.*';
  OpenDialog1.Filterindex:=1;
  LastDir:=GetRecentFiledir;   {2104=EpiData Datafile (*.rec)  2112=All (*.*)}
  FOR n:=1 TO MaxFiles DO
    BEGIN
      Fields[n]:=NIL;
      Filenames[n]:='';
      IsActive[n]:=False;
    END;
end;



Procedure TCountForm.MakeFieldList;
VAR
  n,n2,t: Integer;
  s: String;
  Found,ok: Boolean;
BEGIN
  FieldList.Items.Clear;
  IF EvalList.Items.Count=0 THEN Exit;
  FOR n:=1 TO MaxFiles DO IsActive[n]:=False;
  FOR n:=0 TO EvalList.Items.Count-1 DO
    BEGIN
      s:=AnsiLowerCase(EvalList.Items[n]);
      FOR n2:=1 TO MaxFiles DO IF s=Filenames[n2] THEN IsActive[n2]:=True;
    END;
  FOR n:=0 TO EvalList.Items.Count-1 DO
    BEGIN
      s:=AnsiLowerCase(EvalList.Items[n]);
      Found:=False;
      FOR n2:=1 TO MaxFiles DO IF s=Filenames[n2] THEN Found:=True;
      IF NOT Found THEN
        BEGIN
          {Open datafile and add fieldnames to Fields}
          n2:=0;
          REPEAT INC(n2) UNTIL (n2=MaxFiles) OR (IsActive[n2]=False);
          Filenames[n2]:=s;
          IsActive[n2]:=True;
          IF Fields[n2]=NIL THEN Fields[n2]:=TStringList.Create ELSE Fields[n2].Clear;
          GetDatafilePointer(df);
          df^.RECFilename:=s;
          ok:=PeekDatafile(df);
          IF NOT ok THEN
            BEGIN
              IsActive[n2]:=False;
              ErrorMsg(Format(Lang(20108),[EvalList.Items[n]]));  //20108=Datafile %s could not be opened.
            END
          ELSE
            BEGIN
              FOR t:=0 TO df^.FieldList.Count-1 DO
                IF PeField(df^.FieldList.Items[t])^.Felttype<>ftQuestion
                THEN Fields[n2].Append(AnsiUpperCase(trim(PeField(df^.FieldList.Items[t])^.FName)));
            END;
          DisposeDatafilePointer(df);
        END;  //if not found
    END;  //for n
  {Make list of common fields}
  {Find first active}
  n:=0;
  REPEAT INC(n) UNTIL (IsActive[n]) OR (n=MaxFiles);
  IF NOT IsActive[n] THEN Exit;
  FOR n2:=0 TO Fields[n].Count-1 DO
    BEGIN
      s:=Fields[n].Strings[n2];
      Found:=True;
      t:=0;
      REPEAT
        INC(t);
        IF IsActive[t] THEN
          IF Fields[t].IndexOf(s)=-1 THEN Found:=False;
      UNTIL (t=MaxFiles) OR (Found=False);
      IF Found THEN FieldList.Items.Append(s);
    END;  //for n2
END;

procedure TCountForm.AddBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF trim(FilenameEdit.Text)='' THEN Exit;
  tmpList.Clear;
  tmpList.CommaText:=FilenameEdit.Text;
  IF tmpList.Count+EvalList.Items.Count > MaxFiles THEN
    BEGIN
      ErrorMsg(Format(Lang(23716),[MaxFiles]));  //'A maximum of %d files can be evaluated'
      Exit;
    END;
  EvalList.Items.AddStrings(tmpList);
  FilenameEdit.Text:='';
  FOR n:=EvalList.Items.Count-1 DOWNTO 0 DO
    BEGIN
      IF ExtractFileExt(EvalList.Items[n])='' THEN EvalList.Items[n]:=ChangeFileExt(EvalList.Items[n],'.rec');
      IF lowercase(ExtractFileExt(EvalList.Items[n]))<>'.rec' THEN
        BEGIN
          ErrorMsg(Lang(23718));  //'Only REC-files can be evaluated'
          EvalList.Items.Delete(n);
          Continue;
        END;
      EvalList.Items[n]:=ExpandFilename(EvalList.items[n]);
      IF NOT FileExists(EvalList.Items[n]) THEN
        BEGIN
          ErrorMsg(Format(Lang(20110),[EvalList.Items[n]]));   //20110=Datafile %s does not exist.
          EvalList.Items.Delete(n);
          Continue;
        END;
    END;  //for
  IF EvalList.Items.Count>0 THEN LastDir:=ExtractFileDir(EvalList.Items[EvalList.Items.Count-1]);
  MakeFieldList;
end;

procedure TCountForm.RemoveBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF EvalList.SelCount=0 THEN Exit;
  FOR n:=EvalList.Items.Count-1 DOWNTO 0 DO
    IF EvalList.Selected[n] THEN EvalList.Items.Delete(n);
  MakeFieldList;
end;

procedure TCountForm.SearchBtnClick(Sender: TObject);
begin
  OpenDialog1.InitialDir:=LastDir;
  IF OpenDialog1.Execute THEN
    BEGIN
      FilenameEdit.Text:=OpenDialog1.Files.CommaText;
      AddBtnClick(Sender);
    END;
end;

procedure TCountForm.FormClose(Sender: TObject; var Action: TCloseAction);
VAR
  n:Integer;
begin
  FOR n:=1 TO MaxFiles DO
    IF Fields[n]<>NIL THEN Fields[n].Free;
end;

procedure TCountForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  IF ModalResult=mrOK THEN
    BEGIN
      CanClose:=False;
      IF EvalList.Items.Count=0 THEN
        BEGIN
          ErrorMsg(Lang(23720));  //'No files are selected for evaluation'
          Exit;
        END;
      IF FieldList.Items.Count=0 THEN
        BEGIN
          ErrorMsg(Lang(23722));  //'No fields common to all the files were found'
          Exit;
        END;
      IF FieldList.ItemIndex=-1 THEN
        BEGIN
          IF FieldList.Items.Count>1 THEN
            BEGIN
              eDlg(Lang(23724),mtWarning,[mbOK],0);   //'Please select a field to evaluate'
              Exit;
            END
          ELSE FieldList.ItemIndex:=0;
        END;
      EvalField:=FieldList.Items[FieldList.ItemIndex];
      CanClose:=True;
    END
  ELSE CanClose:=True;
end;

procedure TCountForm.BitBtn1Click(Sender: TObject);
begin
  Application.HelpContext(160);
end;

end.
