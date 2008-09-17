unit GridUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Grids, EpiTypes, Menus, Clipbrd;

type
  TGridContent=(gcChangeNames,gcAutosearch,gcViewer);

  TGridForm = class(TForm)
    Grid1: TStringGrid;
    Panel1: TPanel;
    btnSaveAndClose: TBitBtn;
    btnClose: TBitBtn;
    GridMenu: TMainMenu;
    Filer1: TMenuItem;
    New1: TMenuItem;
    ben1: TMenuItem;
    Gem1: TMenuItem;
    Gemsom1: TMenuItem;
    Close1: TMenuItem;
    CloseAll1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    Printsettings1: TMenuItem;
    N2: TMenuItem;    Options1: TMenuItem;
    RecentDivider1: TMenuItem;
    Recent1: TMenuItem;
    Recent2: TMenuItem;
    Recent3: TMenuItem;
    Recent4: TMenuItem;
    Recent5: TMenuItem;
    Recent6: TMenuItem;
    Recent7: TMenuItem;
    Recent8: TMenuItem;
    N3: TMenuItem;
    Afslut1: TMenuItem;
    Edit1: TMenuItem;
    Showvalues1: TMenuItem;
    Showlabels1: TMenuItem;
    N4: TMenuItem;
    Sortbykey1: TMenuItem;
    Sortbyrecordno1: TMenuItem;
    Opencheckfile1: TMenuItem;
    Document1: TMenuItem;
    Documentdatafile1: TMenuItem;
    Notes1: TMenuItem;
    N12: TMenuItem;
    Viewdata1: TMenuItem;
    Listdata1: TMenuItem;
    Codebook1: TMenuItem;
    N13: TMenuItem;
    ValDup1: TMenuItem;
    Assertdatafile1: TMenuItem;
    CountRec1: TMenuItem;
    Tools1: TMenuItem;
    Tools_REC2QES1: TMenuItem;
    Tools_Pack1: TMenuItem;
    Tools_compress1: TMenuItem;
    Tools_RebuildIndex1: TMenuItem;
    Tools_RevDatafile1: TMenuItem;
    N14: TMenuItem;
    Tools_rename1: TMenuItem;
    Tools_DatafileLabel1: TMenuItem;
    Tools_CopyStruc1: TMenuItem;
    tool_color1: TMenuItem;
    N15: TMenuItem;
    Tool_Recode1: TMenuItem;
    Copy1: TMenuItem;
    N5: TMenuItem;
    SelectAll1: TMenuItem;
    procedure Grid1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Grid1SelectCell(Sender: TObject; Col, Row: Integer; var CanSelect: Boolean);
    Function  TestEntry(tmpS:String):Boolean;
    Function  NoDuplicates:Boolean;
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Grid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Grid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCloseClick(Sender: TObject);
    procedure Grid1DblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Filer1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure ben1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Recent1Click(Sender: TObject);
    procedure Afslut1Click(Sender: TObject);
    procedure Documentdatafile1Click(Sender: TObject);
    procedure Tools_REC2QES1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Showvalues1Click(Sender: TObject);
    procedure Sortbykey1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Grid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Opencheckfile1Click(Sender: TObject);

  private
    { Private declarations }
    MemFile: TMemoryStream;
    gc: TGridContent;
    Fdf: PDatafileInfo;
    FSelectedRecord: String;
    FdfTextFile: TextFile;
    FFieldOrder: TStringList;   //each item is a record no.
    FSortByRec: Boolean;   //if true: sort by recordnumber else sort by key
    FShowLabels: Boolean;   //if true: show valuelabels where applicable else show values
    procedure SetGridContent(value: TGridContent);
    Procedure SetDatafile(Adf: PDatafileInfo);
    Function  ReadFromMem(AField:PeField; RecNo:LongInt; VAR RecIsDeleted:Boolean):String;
  public
    { Public declarations }
    property GridContent: TGridContent read gc write SetGridContent;
    property df: PDatafileInfo read Fdf write SetDatafile;
    property Selected: String read FSelectedRecord;
    property FieldOrder: TStringList read FFieldOrder write FFieldOrder;
    property ShowLabels: Boolean read FShowLabels write FShowLabels;
    property SortByRec: Boolean read FSortByRec write FSortByRec;
    Procedure AssignTxtFile;
    Procedure AddRecord(recnum: LongInt);
    Procedure StopAdding;
  end;

var
  GridForm: TGridForm;

Procedure ChangeFieldNames(df:PDatafileInfo);

implementation

uses MainUnit,PeekCheckUnit, FileUnit, DataFormUnit;

{$R *.DFM}

VAR
  Oldcol,OldRow: Integer;

Procedure ChangeFieldNames(df:PDatafileInfo);
VAR
  n,RowNum,NumberOfFields,CurField,ft:Integer;
  AField: PeField;
  InputRec,OutputRec: TextFile;
  s,s2: String;
  tmpBool:Boolean;
  Checks: TStringList;

BEGIN
  TRY
    GridForm:=TGridForm.Create(MainForm);
    GridForm.Grid1.options:=GridForm.Grid1.Options+[goEditing];
    GridForm.Caption:=Format(Lang(23800),[ExtractFilename(df^.RECFilename)]);    //'Change fieldnames of %s'
    WITH GridForm.Grid1 DO
      BEGIN
        RowCount:=df^.NumFields+1;
        ColCount:=3;
        cells[0,0]:=Lang(23802);  //'Fieldname'
        cells[1,0]:=Lang(20852);  //'Label';
        cells[2,0]:=Lang(23804);  //'New fieldname'
        RowNum:=0;
        FOR n:=0 TO df^.FieldList.Count-1 DO
          BEGIN
            AField:=PeField(df^.FieldList.Items[n]);
            IF AField^.Felttype<>ftQuestion THEN
              BEGIN
                INC(RowNum);
                Cells[0,RowNum]:=trim(AField^.FName);
                Cells[1,RowNum]:=trim(AField^.FVariableLabel);
              END;
          END;
      END;  //with
    GridForm.ActiveControl:=GridForm.Grid1;
    IF GridForm.ShowModal=mrOK THEN
      BEGIN
        TRY
          Screen.Cursor:=crHourGlass;
          AssignFile(InputRec,df^.RECFilename);
          Reset(InputRec);
          AssignFile(OutputRec,ChangeFileExt(df^.RECFilename,'.re$'));
          Rewrite(OutputRec);

          {Read number of fields}
          ReadLn(InputRec,s);
          s2:=COPY(s,1,POS(' ',s)-1);
          NumberOfFields:=StrToInt(s2);
          WriteLn(OutputRec,s);

          {Read the fields}
          RowNum:=0;
          FOR CurField:=1 TO NumberOfFields DO
            BEGIN
              ReadLn(InputRec,s);
              ft:=StrToInt(Copy(s,37,4));
              IF ft<>0 THEN
                BEGIN
                  INC(RowNum);
                  s2:=trim(GridForm.Grid1.Cells[2,RowNum]);
                  IF s2<>'' THEN
                    BEGIN
                      s2:=FitLength(s2,10);
                      FOR n:=1 TO 10 DO
                        s[n+1]:=s2[n];
                      AField:=PeField(df^.FieldList.Items[CurField-1]);
                      AField^.FName:=s2;
                    END;
                END;  //if not ftQuestion
              WriteLn(OutputRec,s);
            END;  //for CurField

          {Write data}
          WHILE NOT EOF(InputRec) DO
            BEGIN
              ReadLn(InputRec,s);
              WriteLn(OutputRec,s);
            END;

          CloseFile(InputRec);
          CloseFile(OutputRec);

          {Save new version of Checkfile}
          IF df^.HasCheckFile THEN
            BEGIN
              tmpBool:=RenameFile(df^.CHKFilename,ChangeFileExt(df^.CHKFilename,'.bak'));
              Checks:=TStringList.Create;
              ChecksToStrings(df, Checks);
              Checks.SaveToFile(df^.CHKFilename);
              Checks.Free;
            END;  //if hascheckfile

          IF FileExists(ChangeFileExt(df^.RECFilename,'.old')+'.rec')
          THEN tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.old')+'.rec');
          s:=ChangeFileExt(df^.RECFilename,'.old')+'.rec';
          Rename(InputRec,s);                   //rename *.rec to *.old.rec
          Rename(OutputRec,df^.RECFilename);    //rename *.re$ to *.rec

          Screen.Cursor:=crDefault;
          s:=Format(Lang(23806),[df^.RECFilename,s]);     //'Fieldnames has been changed in the datafile %s~~Backup of original datafile saved as %s
          IF df^.HasCheckFile
          THEN s:=s+#13#13+Format(Lang(23808),[df^.CHKFilename,ChangeFileExt(df^.CHKFilename,'.bak')]);  //'Checkfile %s adapted to new fieldnames~Original checkfile saved as %s'

          eDlg(s,mtInformation,[mbOK],0);

        EXCEPT
          CloseFile(InputRec);
          CloseFile(OutputRec);
        END;  //try..Except
      END;

  FINALLY
    Screen.Cursor:=crDefault;
    GridForm.Free;
  END;  //try..finally
END;


procedure TGridForm.Grid1KeyPress(Sender: TObject; var Key: Char);
begin
  IF Key=#13 THEN
    BEGIN
      FSelectedRecord:=Grid1.Cells[0,Grid1.Row];
      ModalResult:=mrOK;
    END;
end;

procedure TGridForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  IF gc=gcChangeNames THEN
    BEGIN
      CanClose:=TestEntry(Grid1.Cells[Grid1.Col,Grid1.Row]);
      Grid1.SetFocus;
    END
  ELSE CanClose:=True;
end;

procedure TGridForm.Grid1SelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
VAR
  tmpS: String;
begin
  IF gc=gcChangeNames THEN
    BEGIN
      tmpS:=trim(Grid1.Cells[OldCol,OldRow]);
      CanSelect:=TestEntry(tmpS);
      IF CanSelect THEN
        BEGIN
          OldRow:=Row;
          OldCol:=Col;
        END;
    END
  ELSE CanSelect:=True;
end;

Function TGridForm.TestEntry(tmpS:String):Boolean;
VAR
  n:Integer;
BEGIN
  Result:=True;
  IF tmpS<>'' THEN
    BEGIN
      IF Length(tmpS)>FieldNameLen THEN
        BEGIN
          ErrorMsg(Lang(23810));  //'New fieldname is too long'
          Result:=False;
        END
      ELSE IF NOT (tmpS[1] in AlfaChars) THEN
        BEGIN
          ErrorMsg(Lang(23812));  //'Fieldnames must begin with a letter'
          Result:=False;
        END
      ELSE
        BEGIN
          Result:=True;
          FOR n:=1 TO Length(tmpS) DO
            IF (NOT (tmpS[n] in AlfaChars)) AND (NOT (tmpS[n] in NumChars)) THEN Result:=False;
            IF NOT Result THEN ErrorMsg(Lang(23814));  //'Illegal fieldname'
        END;
      IF Result THEN Result:=NoDuplicates;
    END;
END;


Function TGridForm.NoDuplicates:Boolean;
VAR
  tmpS: String;
  n,n2: Integer;
BEGIN
  Result:=True;
  FOR n:=1 TO Grid1.RowCount-2 DO
    BEGIN
      tmpS:=AnsiUpperCase(trim(Grid1.Cells[2,n]));
      IF tmpS<>'' THEN
        BEGIN
          FOR n2:=n+1 TO Grid1.RowCount-1 DO
            BEGIN
              IF (tmpS=AnsiUpperCase(trim(Grid1.Cells[2,n2]))) THEN
                BEGIN
                  ErrorMsg(Format(Lang(23816),[tmpS]));  //'Duplicate fieldname: %s'
                  Result:=False;
                END;
            END;
          FOR n2:=1 TO Grid1.RowCount-1 DO
            BEGIN
              IF tmpS=AnsiUpperCase(trim(Grid1.Cells[0,n2])) THEN
                BEGIN
                  ErrorMsg(Format(Lang(23818),[tmpS]));  //'Fieldname %s already exists in the datafile'
                  Result:=False;
                END;
            END;
        END;
    END;
END;

procedure TGridForm.FormResize(Sender: TObject);
begin
  IF gc=gcChangeNames THEN Grid1.ColWidths[1]:=ClientWidth-Grid1.ColWidths[0]-Grid1.ColWidths[2]-10;
end;

procedure TGridForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF Key=VK_ESCAPE THEN ModalResult:=mrCancel;
  IF gc=gcViewer THEN
    BEGIN
      IF (Key=ORD('1')) AND (Shift=[ssAlt])
      AND (MainForm.WorkProcessToolbar.Visible=True) THEN
        BEGIN
          MainForm.ProcessBtnClick(MainForm.DefinedataBtn);
          Key:=0;
        END;

      IF (Key=ORD('2')) AND (Shift=[ssAlt])
      AND (MainForm.WorkProcessToolbar.Visible=True) THEN
        BEGIN
          MainForm.ProcessBtnClick(MainForm.MakeDatafileBtn);
          Key:=0;
        END;

      IF (Key=ORD('5')) AND (Shift=[ssAlt])
      AND (MainForm.WorkProcessToolbar.Visible=True) THEN
        BEGIN
          MainForm.ProcessBtnClick(MainForm.DocumentBtn);
          Key:=0;
        END;
    END;  //if gcViewer
end;

procedure TGridForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  gc:=gcChangeNames;
  Fdf:=NIL;
  MemFile:=NIL;
  FFieldOrder:=TStringList.Create;
  FSortByRec:=True;
  FShowLabels:=true;
end;

procedure TGridForm.SetGridContent(value: TGridContent);
BEGIN
  IF value=gc THEN Exit;
  gc:=value;
  CASE gc OF
    gcChangeNames: BEGIN
                  END;
    gcAutosearch,gcViewer: BEGIN
                    //self.FormStyle:=fsMDIChild;
                    //IF gc=gcViewer THEN self.WindowState:=wsMaximized;
                    //self.Height:=400;
                    //self.Width:=500;
                    //self.left:=100;
                    //self.top:=80;
                    WITH self.Grid1 DO
                      BEGIN
                        RowCount:=2;
                        ctl3d:=True;
                        FixedColor:=clBtnFace;
                        FixedCols:=1;
                        FixedRows:=1;
                        Options:=Options+[goColSizing,goColMoving,goThumbTracking]-[goRangeSelect,goEditing,goAlwaysshoweditor];
                        IF gc=gcViewer THEN Options:=Options+[goRangeSelect];
                        canvas.font.Assign(self.font);
                      END;
                    self.btnSaveAndClose.Visible:=False;
                    self.btnClose.Visible:=False;
                    IF (gc=gcViewer) OR (gc=gcAutosearch) THEN self.Panel1.Visible:=False;
                    self.Caption:='';
                    self.Grid1.ColWidths[0]:=self.Grid1.Canvas.TextWidth(' '+Lang(5552)+' ');   //5552=Rec.no.
                    IF gc=gcViewer THEN
                      BEGIN
                        Menu:=GridMenu;
                        Grid1.onMouseDown:=Grid1MouseDown;
                        IF MainForm.TabCtrl.Visible=False THEN MainForm.TabCtrl.Visible:=True;
                        MainForm.TabCtrl.Tabs.AddObject(lang(5550),TObject(Self));   //5550=Viewer
                        MainForm.TabCtrl.TabIndex:=MainForm.TabCtrl.Tabs.Count-1;
                      END;
                  END;
  END;  //case
END;

Procedure TGridForm.AddRecord(recnum: LongInt);
VAR
  n,n2:Integer;
  AField: PeField;
  FieldNo: Integer;
BEGIN
  IF recnum<>NewRecord THEN eReadOnlyRecord(Fdf,FdfTextfile,recnum);
  Grid1.RowCount:=Grid1.RowCount+1;
  IF recnum<>NewRecord
  THEN Grid1.Cells[0,Grid1.RowCount-2]:=IntToStr(recnum)
  ELSE Grid1.Cells[0,Grid1.RowCount-2]:=Lang(11020);    //'New';
  Grid1.Objects[0,Grid1.RowCount-2]:=NIL;
  n2:=0;
  FOR n:=0 TO Fdf^.FieldList.Count-1 DO
    Pefield(Fdf^.FieldList.Items[n])^.FieldN:=-1;
  IF FFieldOrder.Count>0 THEN
    BEGIN
      FOR n:=0 TO FFieldOrder.Count-1 DO
        BEGIN
          FieldNo:=StrToInt(FFieldOrder[n]);
          AField:=PeField(Fdf^.FieldList.Items[FieldNo]);
          IF AField^.FieldN<>100 THEN
            BEGIN
              INC(n2);
              IF (AField^.FCommentLegalRec<>NIL) AND (FShowLabels)
              THEN Grid1.Cells[n2,Grid1.RowCount-2]:=trim(GetCommentLegalText(AField^.FFieldText,AField^.FCommentLegalRec))
              ELSE Grid1.Cells[n2,Grid1.RowCount-2]:=trim(AField^.FFieldText);
              AField^.FieldN:=100;
            END;
        END;
    END;
  FOR n:=0 TO Fdf^.FieldList.Count-1 DO
    BEGIN
      AField:=PeField(Fdf^.FieldList.Items[n]);
      IF (AField^.Felttype<>ftQuestion) AND (AField^.FieldN<>100) THEN
        BEGIN
          INC(n2);
          IF (AField^.FCommentLegalRec<>NIL) AND (FShowLabels)
          THEN Grid1.Cells[n2,Grid1.RowCount-2]:=trim(GetCommentLegalText(AField^.FFieldText,AField^.FCommentLegalRec))
          ELSE Grid1.Cells[n2,Grid1.RowCount-2]:=trim(AField^.FFieldText);
        END;
    END;
END;

Procedure TGridForm.AssignTxtFile;
BEGIN
  Fdf^.Datfile.Free;
  Fdf^.Datfile:=NIL;
  AssignFile(FdfTextfile,Fdf^.RECFilename);
  Reset(FdfTextfile);
END;

Procedure TGridForm.StopAdding;
BEGIN
  CloseFile(FdfTextFile);
END;


Procedure TGridForm.SetDatafile(Adf: PDatafileInfo);
VAR
  n,n2,n3,FieldNo:Integer;
  AField: PeField;
  s: String;
BEGIN
  IF Fdf<>NIL THEN DisposeDatafilePointer(Fdf);
  Fdf:=Adf;
  //Peekdatafile(Fdf);
  IF NOT (gc=gcViewer) THEN
    BEGIN
      Fdf^.Datfile.Free;
      Fdf^.Datfile:=NIL;
      AssignFile(FdfTextfile,Fdf^.RECFilename);
      Reset(FdfTextfile);
    END
  ELSE
    BEGIN
      FDf^.DatFile.Free;
      FDf^.DatFile:=NIL;
      MemFile:=TMemoryStream.Create;
      MemFile.LoadFromFile(FDf^.RECFilename);
    END;
  CASE gc OF
    gcViewer:
      BEGIN
        self.Caption:=ExtractFileName(Fdf^.RecFilename);
        MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.IndexOfObject(TObject(self))]:=ExtractFilename(Fdf^.RecFilename);
      END;
    gcAutoSearch: self.Caption:=Format(lang(21704),[ExtractFileName(Fdf^.RecFilename)]);  //21704=Select record in %s
  END;  //case

  n2:=0;
  FOR n:=0 TO Fdf^.FieldList.Count-1 DO
    BEGIN
      IF PeField(Fdf^.FieldList.Items[n])^.FeltType<>ftQuestion THEN INC(n2);
      PeField(Fdf^.FieldList.Items[n])^.FieldN:=-1;
    END;
  Grid1.ColCount:=n2+1;
  FOR n:=0 TO Grid1.ColCount-1 DO
    Grid1.Objects[n,0]:=NIL;
  n2:=0;
  Grid1.Cells[0,0]:=Lang(5552);   //5552=Rec.no.
  Grid1.Objects[0,0]:=NIL;
  IF FFieldOrder.Count>0 THEN
    BEGIN
      FOR n:=0 TO FFieldOrder.Count-1 DO
        BEGIN
          FieldNo:=StrToInt(FFieldOrder[n]);
          AField:=PeField(Fdf^.FieldList.Items[FieldNo]);
          IF AField^.FieldN<>100 THEN
            BEGIN
              INC(n2);
              WITH AField^ DO
                BEGIN
                  n3:=Grid1.Canvas.TextWidth(trim(FName)+'  ');
                  IF NOT (Felttype in [ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt]) THEN
                    BEGIN
                      IF Grid1.canvas.TextWidth(cFill('9',FLength+1)) > n3
                      THEN n3:=Grid1.Canvas.TextWidth(cFill('9',FLength+1));
                      Grid1.ColWidths[n2]:=n3+6;
                    END;
                  Grid1.Cells[n2,0]:=' '+trim(FName)+' ';
                  Grid1.Objects[n2,0]:=TObject(Afield);
                  FieldN:=100;
                END;
            END;
        END;
    END;
  FOR n:=0 TO Fdf^.FieldList.Count-1 DO
    BEGIN
      WITH PeField(Fdf^.FieldList.Items[n])^ DO
        BEGIN
          IF (Felttype<>ftQuestion) AND (FieldN<>100) THEN
            BEGIN
              INC(n2);
              n3:=Grid1.canvas.TextWidth(trim(FName)+'  ');
              IF NOT (Felttype in [ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt]) THEN
                BEGIN
                  IF Grid1.canvas.textwidth(cfill('9',FLength+1)) > n3
                  THEN n3:=Grid1.canvas.textwidth(cfill('9',FLength+1));
                  Grid1.ColWidths[n2]:=n3+6;
                END;
              Grid1.Cells[n2,0]:=' '+trim(FName)+' ';
              Grid1.Objects[n2,0]:=TObject(PeField(Fdf^.FieldList.Items[n]));
            END;
        END;
    END;
END;



procedure TGridForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IF (gc=gcAutosearch) OR (gc=gcViewer) THEN Action:=caFree;
  IF gc=gcViewer THEN
    BEGIN
      MainForm.TabCtrl.Tabs.Delete(MainForm.TabCtrl.Tabs.IndexOfObject(TObject(self)));
      IF MainForm.TabCtrl.Tabs.Count=0 THEN MainForm.TabCtrl.Visible:=False;
    END;
  FFieldOrder.Free;
  IF gc=gcViewer THEN
    BEGIN
      DisposeDatafilePointer(FDf);
      MemFile.Free;
    END;
end;

Function TGridForm.ReadFromMem(AField:PeField; RecNo:LongInt; VAR RecIsDeleted:Boolean):String;
VAR
  RecordPos:LongInt;
  CharPointer: ^CHAR;
  FieldT:PChar;
  FieldText:String;
BEGIN
  New(CharPointer);
  TRY
    Result:='';
    IF (RecNo<1) OR (RecNo>Fdf^.NumRecords) THEN Exit;
    IF AField=NIL THEN Exit;
    IF NOT Assigned(MemFile) THEN Exit;

    RecordPos:=Fdf^.Offset+((RecNo-1)*Fdf^.RecLength);
    MemFile.Position:=RecordPos+FDf^.RecLength-3;
    MemFile.Read(CharPointer^,1);
    IF CharPointer^='?' THEN RecIsDeleted:=True ELSE RecIsDeleted:=False;
    IF AField^.FeltType<>ftQuestion THEN
      BEGIN
        {Read value of field}
        FieldT:=PChar(cFill(#0,AField^.FLength+3));
        MemFile.Position:=RecordPos+AField^.FStartPos;
        MemFile.ReadBuffer(FieldT^,AField^.FLength);
        FieldText:=FieldT;
        IF Pos('!',FieldText)>0 THEN
          BEGIN
            MemFile.Position:=RecordPos+AField^.FStartPos;
            MemFile.ReadBuffer(FieldT^, AField^.FLength+3);
            FieldText:=FieldT;
            Delete(FieldText,Pos('!',FieldText),3);
          END;
        Result:=trim(FieldText);
      END;
  FINALLY
    Dispose(CharPointer);
  END;
END;



procedure TGridForm.Grid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
VAR
  AField: PeField;
  s: String;
  CurRecDel: Boolean;
begin
  WITH (Sender AS TStringGrid) DO
    BEGIN
      IF NOT (gc=gcViewer) THEN s:=Cells[ACol,ARow]
      ELSE
        BEGIN
          IF ARow=0 THEN s:=Cells[ACol,ARow]
          ELSE IF ACol=0 THEN
            BEGIN
              IF FSortByRec THEN s:=IntToStr(ARow) ELSE s:=IntToStr(ReadIndexNoFromSortIndex(Fdf,ARow));
            END
          ELSE
            BEGIN
              AField:=PeField(Objects[ACol,0]);
              IF AField<>NIL THEN
                BEGIN
                  IF FSortByRec THEN s:=IntToStr(ARow) ELSE s:=IntToStr(ReadIndexNoFromSortIndex(Fdf,ARow));
                  s:=ReadFromMem(AField,StrToInt(s),CurRecDel);
                  IF AField^.Felttype=ftCrypt THEN s:=DecryptString(s,Fdf^.Key);
                  IF (FShowLabels) AND (AField^.FCommentLegalRec<>NIL) THEN s:=GetCommentLegalText(s,AField^.FCommentLegalRec);
                END;
            END;
        END;
      IF NOT (gdFixed in State) THEN
        BEGIN
          Canvas.Font.Assign(self.font);
          IF (gdSelected in State) THEN
            BEGIN
              Canvas.font.Color:=clHighLightText;
              Canvas.Brush.Color:=clHighlight;
              Canvas.FillRect(Rect);
            END
          ELSE
            BEGIN
              Canvas.font.color:=clWindowText;
              Canvas.Brush.Color:=clWindow;
            END;
          AField:=PeField(Objects[ACol,0]);
          IF Assigned(AField) THEN
            BEGIN
              IF (AField^.Felttype in [ftAlfa,ftUpperAlfa,ftSoundex,ftCrypt])
              THEN Canvas.TextRect(Rect,rect.left+2,rect.top+2,s)
              ELSE Canvas.TextRect(Rect,rect.Right-2-canvas.textwidth(s),rect.top+2,s);
            END;
        END  //if
      ELSE
        BEGIN
          Canvas.Font.Assign(self.font);
          Canvas.font.color:=clWindowText;
          Canvas.Brush.Color:=clBtnFace;
          Canvas.TextRect(Rect,Rect.Left+(Rect.Right-Rect.Left-Canvas.TextWidth(s)) DIV 2,rect.top+2,s);
          //IF s='ID' THEN
          //  showmessage('s='+s);
          //Canvas.TextRect(Rect,((Rect.Right-Rect.Left) DIV 2) - (Canvas.TextWidth(Cells[ACol,ARow]) DIV 2),rect.top+2,Cells[ACol,ARow]);
        END;
    END;  //with
end;


procedure TGridForm.Grid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF Key=VK_F8 THEN Grid1.LeftCol:=Grid1.LeftCol+1;
end;

procedure TGridForm.btnCloseClick(Sender: TObject);
begin
  Beep;
  UserAborts:=True;
end;

procedure TGridForm.Grid1DblClick(Sender: TObject);
begin
  FSelectedRecord:=Grid1.Cells[0,Grid1.Row];
  ModalResult:=mrOK;
end;

procedure TGridForm.FormActivate(Sender: TObject);
begin
  IF gc=gcViewer THEN
    BEGIN
      ChangeGoingOn:=True;
      MainForm.TabCtrl.TabIndex:=MainForm.TabCtrl.tabs.IndexOfObject(TObject(self));
      ChangeGoingOn:=False;
    END;
end;

procedure TGridForm.Filer1Click(Sender: TObject);
VAR
  NoRecent,NoQes:BYTE;
  e:String[20];
begin
  IF Fdf^.HasCheckFile THEN Opencheckfile1.Enabled:=True ELSE OpenCheckFile1.Enabled:=False;
  {Make list of recent qes-files}
  NoQes:=0;
  FOR NoRecent:=1 TO 8 DO
    RecentQes[NoRecent]:='';

  FOR NoRecent:=1 TO 8 DO
    BEGIN
      e:=AnsiUpperCase(ExtractFileExt(RecentFiles[NoRecent]));
      IF (e<>'.REC') THEN
        BEGIN
          Inc(NoQes);
          RecentQes[NoQes]:=RecentFiles[NoRecent];
        END;  //if
    END;  //for

  IF RecentQes[1]<>'' THEN
    BEGIN
      RecentDivider1.Visible:=True;
      Recent1.Caption:='&1. '+ExtractFileName(RecentQes[1]);
      Recent1.Visible:=True;
    END
  ELSE
    BEGIN
      RecentDivider1.Visible:=False;
      Recent1.Visible:=False;
    END;
  IF RecentQes[2]<>'' THEN
    BEGIN
      Recent2.Caption:='&2. '+ExtractFileName(RecentQes[2]);
      Recent2.Visible:=True;
    END
  ELSE Recent2.Visible:=False;
  IF RecentQes[3]<>'' THEN
    BEGIN
      Recent3.Caption:='&3. '+ExtractFileName(RecentQes[3]);
      Recent3.Visible:=True;
    END
  ELSE Recent3.Visible:=False;
  IF RecentQes[4]<>'' THEN
    BEGIN
      Recent4.Caption:='&4. '+ExtractFileName(RecentQes[4]);
      Recent4.Visible:=True;
    END
  ELSE Recent4.Visible:=False;
  IF RecentQes[5]<>'' THEN
    BEGIN
      Recent5.Caption:='&5. '+ExtractFileName(RecentQes[5]);
      Recent5.Visible:=True;
    END
  ELSE Recent5.Visible:=False;
  IF RecentQes[6]<>'' THEN
    BEGIN
      Recent6.Caption:='&6. '+ExtractFileName(RecentQes[6]);
      Recent6.Visible:=True;
    END
  ELSE Recent6.Visible:=False;
  IF RecentQes[7]<>'' THEN
    BEGIN
      Recent7.Caption:='&7. '+ExtractFileName(RecentQes[7]);
      Recent7.Visible:=True;
    END
  ELSE Recent7.Visible:=False;
  IF RecentQes[8]<>'' THEN
    BEGIN
      Recent8.Caption:='&8. '+ExtractFileName(RecentQes[8]);
      Recent8.Visible:=True;
    END
  ELSE Recent8.Visible:=False;
end;

procedure TGridForm.New1Click(Sender: TObject);
begin
  MainForm.New1Click(Sender);
end;

procedure TGridForm.ben1Click(Sender: TObject);
begin
  MainForm.Open1Click(Sender);
end;

procedure TGridForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TGridForm.CloseAll1Click(Sender: TObject);
begin
  MainForm.CloseAll;
end;

procedure TGridForm.Options1Click(Sender: TObject);
begin
  MainForm.Options1Click(Sender);
end;

procedure TGridForm.Recent1Click(Sender: TObject);
VAR
  rN:Integer;
begin
  rN:=0;
  IF Sender=Recent1 THEN rN:=1;
  IF Sender=Recent2 THEN rN:=2;
  IF Sender=Recent3 THEN rN:=3;
  IF Sender=Recent4 THEN rN:=4;
  IF Sender=Recent5 THEN rN:=5;
  IF Sender=Recent6 THEN rN:=6;
  IF Sender=Recent7 THEN rN:=7;
  IF Sender=Recent8 THEN rN:=8;

  IF rN<>0
  THEN
    BEGIN
      IF (FileExists(RecentQes[rN]))
        THEN MainForm.DoOpenQesFile(RecentQes[rN])
      ELSE ErrorMsg(Format(Lang(22126),[RecentQes[rN]]));   //'The file %s does not exist.'
    END;
end;

procedure TGridForm.Afslut1Click(Sender: TObject);
begin
  MainForm.Afslut1Click(Sender);
end;

procedure TGridForm.Documentdatafile1Click(Sender: TObject);
begin
  IF Sender=DocumentDatafile1 THEN   MainForm.VariableInfo1Click(sender)
  ELSE IF Sender=Notes1 THEN   MainForm.Studydescription1Click(sender)
  ELSE IF Sender=ViewData1 THEN   MainForm.Viewer1Click(Sender)
  ELSE IF Sender=ListData1 THEN   MainForm.ListData1Click(sender)
  ELSE IF Sender=Codebook1 THEN   MainForm.Codebook1Click(sender)
  ELSE IF Sender=ValDup1 THEN   MainForm.Validate1Click(Sender)
  ELSE IF Sender=AssertDatafile1 THEN   MainForm.Assertdatafile1Click(Sender)
  ELSE IF Sender=CountRec1 THEN   MainForm.Countvalues1Click(sender);
end;

procedure TGridForm.Tools_REC2QES1Click(Sender: TObject);
begin
  IF TestDataFormCreated THEN TDataForm(TestDf^.DatForm).Close;
  IF Sender=Tools_REC2QES1 THEN MainForm.Makeqesfilefromdatafile1Click(Sender)
  ELSE IF Sender=Tools_RevDatafile1 THEN MainForm.RevisedatafilefromrevisedQESfile1Click(Sender)
  ELSE IF Sender=Tools_Pack1 THEN MainForm.Packdatafile1Click(Sender)
  ELSE IF Sender=Tools_compress1 THEN MainForm.Compressdatafile1Click(Sender)
  ELSE IF Sender=Tools_RebuildIndex1 THEN MainForm.Rebuildindex1Click(Sender)
  ELSE IF Sender=Tools_rename1 THEN MainForm.Changefieldnames1Click(Sender)
  ELSE IF Sender=Tools_DatafileLabel1 THEN MainForm.Datafilelabel2Click(Sender)
  ELSE IF Sender=Tools_CopyStruc1 THEN MainForm.Copydatafilestructure1Click(Sender)
  ELSE IF Sender=Tool_Recode1 THEN MainForm.Recodedatafile1Click(Sender)
  ELSE IF Sender=tool_color1 THEN MainForm.Colortable1Click(Sender);

end;

procedure TGridForm.Edit1Click(Sender: TObject);
begin
  ShowLabels1.Checked:=FShowLabels;
  ShowValues1.Checked:=NOT FShowLabels;
  SortByKey1.Checked:=NOT FSortByRec;
  SortByRecordNo1.Checked:=FSortByRec;
  IF Assigned(Fdf) THEN IF Fdf^.IndexCount=0 THEN
    BEGIN
      SortByKey1.Enabled:=False;
      SortbyRecordNo1.Enabled:=False;
    END;
end;

procedure TGridForm.Showvalues1Click(Sender: TObject);
VAR
  AField: PeField;
  col,row: Integer;
begin
  IF gc=gcViewer THEN
    BEGIN
      FShowLabels:=NOT FShowLabels;
      Grid1.Invalidate;
      Exit;
    END;
  FOR col:=1 TO Grid1.ColCount-1 DO
    BEGIN
      AField:=PeField(Grid1.Objects[col,0]);
      IF AField^.FCommentLegalRec<>NIL THEN
        BEGIN
          FOR row:=1 TO Grid1.RowCount-1 DO
            BEGIN
              IF FShowLabels
              THEN Grid1.Cells[col,row]:=GetValueFromCommentLegal(Grid1.Cells[col,row],AField^.FCommentLegalRec)
              ELSE Grid1.Cells[col,row]:=GetCommentLegalText(Grid1.Cells[col,row],AField^.FCommentLegalRec);
            END;  //for row
        END;  //if
    END;   //for col
  FShowLabels:=NOT FShowLabels;
end;

procedure TGridForm.Sortbykey1Click(Sender: TObject);
VAR
  n: Integer;
begin
  IF Fdf^.IndexCount=0 THEN Exit;
  ViewerSortByRec:=NOT ViewerSortByRec;
  FSortByRec:=NOT FSortByRec;

  IF gc=gcViewer THEN
    BEGIN
      //FOR n:=1 TO Fdf^.NumRecords DO
      //  IF FSortByRec THEN Grid1.Cells[0,n]:=IntToStr(n)   //  AGrid.AddRecord(n)
      //  ELSE Grid1.Cells[0,n]:=IntToStr(ReadIndexNoFromSortIndex(Fdf,n));     //AGrid.AddRecord(ReadIndexNoFromSortIndex(df,n));
      Grid1.Invalidate;
    END
  ELSE
    BEGIN
      AssignTxtFile;    
      Grid1.RowCount:=2;
      IF FSortByRec THEN AddRecord(n)
      ELSE AddRecord(ReadIndexNoFromSortIndex(Fdf,n));
      StopAdding;
      Grid1.RowCount:=Grid1.RowCount-1;
    END;
end;

procedure TGridForm.Copy1Click(Sender: TObject);
VAR
  c: TClipboard;
  col,row: Integer;
  s,cellText: String;
  AField: PeField;
  CurRecDel:Boolean;
begin
  try
    c:=clipboard;
    c.open;
    c.clear;
    s:='';
    FOR col:=Grid1.Selection.Left TO Grid1.Selection.Right-1 DO
      s:=s+Grid1.Cells[col,0]+#9;
    s:=s+Grid1.Cells[Grid1.Selection.Right,0]+#13#10;

    FOR row:=Grid1.Selection.Top TO Grid1.Selection.Bottom DO
      BEGIN
        FOR col:=Grid1.Selection.Left TO Grid1.Selection.Right DO
          BEGIN
            IF NOT (gc=gcViewer) THEN CellText:=Grid1.Cells[Col,Row]
            ELSE
              BEGIN
                IF Row=0 THEN CellText:=Grid1.Cells[Col,Row]
                ELSE IF Col=0 THEN
                  BEGIN
                    IF FSortByRec THEN CellText:=IntToStr(Row) ELSE CellText:=IntToStr(ReadIndexNoFromSortIndex(Fdf,Row));
                  END
                ELSE
                  BEGIN
                    AField:=PeField(Grid1.Objects[Col,0]);
                    IF AField<>NIL THEN
                      BEGIN
                        IF FSortByRec THEN CellText:=IntToStr(Row) ELSE CellText:=IntToStr(ReadIndexNoFromSortIndex(Fdf,Row));
                        CellText:=ReadFromMem(AField,StrToInt(CellText),CurRecDel);
                        IF AField^.Felttype=ftCrypt THEN CellText:=DecryptString(CellText,Fdf^.Key);
                        IF (FShowLabels) AND (AField^.FCommentLegalRec<>NIL) THEN CellText:=GetCommentLegalText(CellText,AField^.FCommentLegalRec);
                      END;
                  END;
              END;
            s:=s+CellText+#9;
          END;
        s[Length(s)]:=#13;
        s:=s+#10;
      END;
    c.AsText:=s;
  finally
    c.close;
  end;   //try..finally
end;

procedure TGridForm.SelectAll1Click(Sender: TObject);
VAR
  g: TGridRect;
begin
  WITH g DO
    BEGIN
      top:=1;
      Left:=1;
      Bottom:=Grid1.RowCount-1;
      Right:=Grid1.ColCount-1;
    END;
  Grid1.Selection:=g;
end;

procedure TGridForm.Grid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
VAR
  cellx,celly: Integer;
  g: TGridRect;
begin
  Grid1.MouseToCell(x,y,cellx,celly);
  IF (cellx=0) AND (celly=0) THEN SelectAll1Click(Sender)
  ELSE IF cellx=0 THEN
    BEGIN
      //row selected
      g.top:=celly;
      g.Bottom:=celly;
      g.Left:=1;
      g.Right:=Grid1.ColCount-1;
      Grid1.Selection:=g;
    END
  ELSE IF celly=0 THEN
    BEGIN
      //column selected
      g.Left:=cellx;
      g.Right:=cellx;
      g.Top:=1;
      g.Bottom:=Grid1.RowCount-1;
      Grid1.Selection:=g;
    END;
end;

procedure TGridForm.Opencheckfile1Click(Sender: TObject);
begin
  IF Assigned(Fdf) THEN
    BEGIN
      IF Fdf^.HasCheckFile THEN
        BEGIN
          IF FileExists(Fdf^.CHKFilename)
           THEN MainForm.DoOpenQesFile(Fdf^.CHKFilename)
          ELSE ErrorMsg(Format(Lang(22126),[Fdf^.CHKFilename]));   //'The file %s does not exist.'
        END;
    END;
end;

Initialization
  OldRow:=1;
  OldCol:=0;

end.
