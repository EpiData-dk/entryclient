unit EdUnit;

interface

uses
  Windows, Messages, SysUtils, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Menus, Classes, Buttons, ToolWin;

type
  TFormTypes=(ftEditor,ftDocumentation,ftErrorList);
  TEdForm = class(TForm)
    Ed: TRichEdit;
    MainMenu1: TMainMenu;
    Filer1: TMenuItem;
    Afslut1: TMenuItem;
    Rediger1: TMenuItem;
    Copy1: TMenuItem;
    Insert1: TMenuItem;
    Run1: TMenuItem;
    SelectAll1: TMenuItem;
    SaveFileDialog: TSaveDialog;
    ben1: TMenuItem;
    N1: TMenuItem;
    Gem1: TMenuItem;
    Gemsom1: TMenuItem;
    Cut1: TMenuItem;
    EditorPopupMenu: TPopupMenu;
    Copy2: TMenuItem;
    Cut2: TMenuItem;
    Insert2: TMenuItem;
    N2: TMenuItem;
    Testdataform1: TMenuItem;
    Markeralt2: TMenuItem;
    New1: TMenuItem;
    Undo1: TMenuItem;
    N3: TMenuItem;
    Close1: TMenuItem;
    N4: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    Print1: TMenuItem;
    N5: TMenuItem;
    PrinterSetupDialog: TPrinterSetupDialog;
    Printsettings1: TMenuItem;
    Dataform1: TMenuItem;
    N6: TMenuItem;
    Fieldpicklist1: TMenuItem;
    FontDialog1: TFontDialog;
    GotoLine1: TMenuItem;
    RecentDivider: TMenuItem;
    Recent11: TMenuItem;
    Recent21: TMenuItem;
    Recent31: TMenuItem;
    Recent41: TMenuItem;
    N7: TMenuItem;
    Options2: TMenuItem;
    Gotoline2: TMenuItem;
    N8: TMenuItem;
    CodeWriter1: TMenuItem;
    Autoindent1: TMenuItem;
    Makedatafile1: TMenuItem;
    CloseAll1: TMenuItem;
    Document1: TMenuItem;
    Documentdatafile1: TMenuItem;
    Notes1: TMenuItem;
    Listdata1: TMenuItem;
    Codebook1: TMenuItem;
    Recent51: TMenuItem;
    Recent61: TMenuItem;
    Recent71: TMenuItem;
    Recent81: TMenuItem;
    PrintDialog1: TPrintDialog;
    Alignentryfields1: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    ValDup1: TMenuItem;
    Assertdatafile1: TMenuItem;
    CountRec1: TMenuItem;
    Tools1: TMenuItem;
    Tools_REC2QES: TMenuItem;
    Tools_RevDatafile: TMenuItem;
    Tools_Pack: TMenuItem;
    Tools_RebuildIndex: TMenuItem;
    N12: TMenuItem;
    Tools_rename: TMenuItem;
    Tools_DatafileLabel: TMenuItem;
    Tools_CopyStruc: TMenuItem;
    N13: TMenuItem;
    Tool_Recode: TMenuItem;
    Tools_compress: TMenuItem;
    tool_color: TMenuItem;
    Viewdata1: TMenuItem;
    Clearallchecks1: TMenuItem;
    N14: TMenuItem;
    Zipfiles1: TMenuItem;
    Unzipfiles1: TMenuItem;
    procedure Afslut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Insert1Click(Sender: TObject);
    procedure Run1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure AAben1Click(Sender: TObject);
    procedure Gem1Click(Sender: TObject);
    procedure Gemsom1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Cut1Click(Sender: TObject);
    procedure EdSelectionChange(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Open(const Filename:STRING);
    procedure Close1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure Replace1Click(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Printsettings1Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Fieldpicklist1Click(Sender: TObject);
    procedure GotoLine1Click(Sender: TObject);
    procedure Recent11Click(Sender: TObject);
    procedure Filer1Click(Sender: TObject);
    procedure Options2Click(Sender: TObject);
    procedure CodeWriter1Click(Sender: TObject);
    procedure Rediger1Click(Sender: TObject);
    procedure EdKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure Autoindent1Click(Sender: TObject);
    procedure Makedatafile1Click(Sender: TObject);
    procedure EdKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CloseAll1Click(Sender: TObject);
    procedure Documentdatafile1Click(Sender: TObject);
    procedure Notes1Click(Sender: TObject);
    procedure Datafilelabel1Click(Sender: TObject);
    procedure Listdata1Click(Sender: TObject);
    procedure Codebook1Click(Sender: TObject);
    procedure DisposeTabChars;
    procedure Alignentryfields1Click(Sender: TObject);
    procedure ValDup1Click(Sender: TObject);
    procedure Assertdatafile1Click(Sender: TObject);
    procedure CountRec1Click(Sender: TObject);
    procedure Tools_REC2QESClick(Sender: TObject);
    procedure Viewdata1Click(Sender: TObject);

  private

  public
    PathName:STRING;
    FormType:TFormTypes;
    BlockFile:TextFile;
  end;

var
  EdForm: TEdForm;
  RapForm: TEdForm;
  AutoIndent: Boolean;
  DefaultFilename: String;


implementation

{$R *.DFM}

Uses
  Clipbrd, MainUnit, ShellAPI, RichEdit, EPITypes, PickListUnit,
  DataFormUnit, FileUnit, ZipFormUnit;



VAR
  OtherFieldBegun:Boolean;

procedure DoCompiling(Trsp_string:STRING; PathName:STRING);
VAR
  ADataForm: TDataForm;
begin
  IF RapFormCreated THEN
    BEGIN
      RapForm.Free;
      RapFormCreated:=FALSE;
    END;

  IF TestDataFormCreated THEN TDataForm(TestDf^.DatForm).Close;
  IF NOT GetDatafilePointer(TestDf) THEN Exit;
  TestDataFormCreated:=True;
  TestDf^.QESFilename:=PathName;
  TestDf^.EpiInfoFieldNaming:=EpiInfoFieldNaming;
  TestDf^.UpdateFieldnameInQuestion:=UpdateFieldnameInQuestion;
  CreatingFromQesFile:=True;
  IF NOT TranslateQes(TestDf,Trsp_string) THEN
    BEGIN
      LockWindowUpdate(MainForm.Handle);
      TRY
        RapForm:=TEdform.Create(MainForm);
        RapFormCreated:=TRUE;
        RapForm.FormType:=ftErrorList;
        RapForm.Caption:=Lang(22102);   //'Errors in QES-file';
        RapForm.Ed.Text:=Trsp_string;
        RapForm.Ed.Modified:=FALSE;
      EXCEPT
        RapForm.Free;
        RapFormCreated:=FALSE;
      END;  //try..except
      LockWindowUpdate(0);
      TestDataFormCreated:=False;
      DisposeDatafilePointer(TestDf);
    END
  ELSE
    BEGIN
      LockWindowUpdate(MainForm.Handle);
      TestingDataForm:=True;
      ADataForm:=TDataForm.Create(MainForm);
      ADataForm.Filter1.Visible:=False;
      LockWindowUpDate(0);
      ADataForm.df:=TestDf;
      TestDf^.DatForm:=TObject(ADataForm);
      LockWindowUpdate(ADataForm.ScrollBox1.Handle);
      ADataForm.PutFieldsOnForm;
      LockWindowUpdate(0);
      Screen.Cursor:=crDefault;
      WITH TestDf^ DO
        BEGIN
          CurRecord:=NewRecord;
          CurRecModified:=False;
          NumRecords:=0;
          ADataForm.UpdateCurRecEdit(CurRecord,NumRecords);
        END;  //with
      ADataForm.FocusFirstField;
    END;
  CreatingFromQesFile:=False;
end;  //procedure DoCompiling

{procedure DoCompiling(Trsp_string:STRING; PathName:STRING);

begin
  IF RapFormCreated THEN
    BEGIN
      RapForm.Free;
      RapFormCreated:=FALSE;
    END;

  IF IndtastningsFormCreated THEN BEGIN
    IndtastningsForm.Close;
  END;
  IF FeltlisteCreated THEN FeltListe.Clear
  ELSE
    BEGIN
      FeltListe:=TList.Create;
      FeltListeCreated:=TRUE;
    END;
  LockWindowUpdate(MainForm.Handle);
  TestingDataForm:=True;
  IndtastningsForm:=TIndtastningsForm.Create(MainForm);
  IndtastningsForm.Caption:=ExtractFilename(PathName)+' - Test dataform';
  IndtastningsForm.RecNavPanel.Visible:=False;
  IndtastningsFormCreated:=TRUE;
  IndtastningsForm.WindowState:=wsMinimized;
  LockWindowUpdate(0);
  CreateIndtastningsFormError:=FALSE;
  CreatingFromQesFile:=True;
  IndtastningsForm.OverSet(Trsp_string);
  CreatingFromQesFile:=False;
  IF NOT CreateIndtastningsFormError THEN
    BEGIN
      IndtastningsForm.WindowState:=wsMaximized;
      WITH DataFileInfo DO
        BEGIN
          CurRecord:=NewRecord;
          Modified:=False;
          NumRecords:=0;
          IndtastningsForm.UpdateCurRecEdit(CurRecord,NumRecords);
        END;  //with
      IndtastningsForm.FocusFirstField;
    END
  ELSE
    BEGIN
      IndtastningsForm.Close;
      LockWindowUpdate(MainForm.Handle);
      TRY
        RapForm:=TEdform.Create(MainForm);
        RapFormCreated:=TRUE;
        RapForm.FormType:=ftErrorList;
        RapForm.Caption:='Errors in qes-file';
        RapForm.Ed.ReadOnly:=True;
        RapForm.Ed.Text:=Trsp_string;
        RapForm.Ed.Modified:=FALSE;
      EXCEPT
        RapForm.Free;
        RapFormCreated:=FALSE;
      END;  //try..except
      LockWindowUpdate(0);
    END;
end;  //procedure DoCompiling}


procedure TEdForm.Afslut1Click(Sender: TObject);
begin
  MainForm.Afslut1Click(Sender);
end;

procedure TEdForm.Copy1Click(Sender: TObject);
begin
  Ed.CopyToClipboard;
end;

procedure TEdForm.Insert1Click(Sender: TObject);
begin
  Ed.PasteFromClipboard;
  IF Ed.FindText(#9,0,Length(Ed.Lines.Text),[])>-1
  THEN DisposeTabChars;
end;

procedure TEdForm.Cut1Click(Sender: TObject);
begin
  Ed.CutToClipboard;
end;

procedure TEdForm.Run1Click(Sender: TObject);
BEGIN
  DoCompiling(Ed.text, PathName);
END;

procedure TEdForm.SelectAll1Click(Sender: TObject);
begin
  Ed.SelectAll;
end;

procedure TEdForm.AAben1Click(Sender: TObject);
begin
  MainForm.Open1Click(Sender);
END;

PROCEDURE TEdForm.Open(const Filename:STRING);
VAR
  tmpStr:TFilename;
BEGIN
  WITH Ed DO
    BEGIN
      TRY
        Lines.LoadFromFile(FileName);
        PathName:=FileName;
        Caption:=ExtractFileName(FileName);
        MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
          IndexOfObject(TObject(self))]:=ExtractFilename(Filename);
        tmpStr:=AnsiLowerCase(ExtractFileExt(Filename));
        IF tmpStr='.log' THEN FormType:=ftDocumentation
          ELSE FormType:=ftEditor;
        CASE FormType OF
          ftEditor: Font.Assign(epiEdFont);
          ftDocumentation: Font.Assign(epiDocuFont);
        END;  //case
        SelStart:=0;
        Modified:=FALSE;
        AssignFile(BlockFile,Filename);
        Reset(BlockFile);
      EXCEPT
        LockWindowUpdate(0);
        ErrorMsg(Format(Lang(22104),[Filename])+#13#13+Lang(20208));   //'The file %s cannot be opened.'
                                                                       //'Please check if the file is in use and that the filename is legal.'
        Close;
        MainForm.Repaint;
      END;  //try..except
    END;  //with
  LockWindowUpdate(0);
  MainForm.Repaint;
  IF Ed.FindText(#9,0,Length(Ed.Lines.Text),[])>-1 THEN DisposeTabChars;
end;

procedure TEdForm.Gem1Click(Sender: TObject);
VAR
  n,n2:Integer;
  f:TextFile;
begin
  IF Copy(PathName,1,Length(DefaultFilename))=DefaultFileName THEN
    Gemsom1Click(Sender)
  ELSE
    BEGIN
      {$I-}
      CloseFile(BlockFile);
      n:=IOResult;
      {$I+}
      n:=mrNo;
{      IF (AnsiLowerCase(ExtractFileExt(PathName))='.log')
      AND FileExists(PathName) THEN
        BEGIN
          n:=MessageDlg(Format('A documentation file with the name %s allready exists.'+
          #13#13+'Do you want to append this documentation to the existing file?'+
          #13#13+'If you answer No the existing file will be deleted.',[PathName]),
          mtWarning,[mbYes,mbNo],0);
        END;}

      IF n=mrNO THEN
        BEGIN
          TRY
            Ed.Lines.SaveToFile(PathName);
            AssignFile(BlockFile,PathName);
            Reset(BlockFile);
            AddToRecentFiles(PathName);
            Ed.Modified:=FALSE;
          EXCEPT
            ErrorMsg(Format(Lang(22106),[PathName]));   //'Error saving %s'
          END;
        END
      ELSE
        BEGIN
          TRY
            AssignFile(f,PathName);
            Append(f);
            WriteLN(f);
            WriteLN(f);
            FOR n2:=0 TO Ed.Lines.Count-1 DO WriteLn(f,Ed.Lines[n2]);
            CloseFile(f);
            AssignFile(BlockFile,PathName);
            Reset(BlockFile);
            AddToRecentFiles(PathName);
            Ed.Modified:=False;
          EXCEPT
            ErrorMsg(Format(Lang(22106),[PathName]));  //'Error saving %s'
          END;  //try..except
        END;
    END;  //else
end;  //procedure Gem1Click

procedure TEdForm.Gemsom1Click(Sender: TObject);
VAR
  s:String[40];
begin
  WITH SaveFileDialog DO
    BEGIN
      Filename:=PathName;
      s:=AnsiLowerCase(ExtractFileExt(PathName));
      IF s='.qes' THEN FilterIndex:=1
      ELSE IF s='.chk' THEN FilterIndex:=2
      ELSE IF s='.log' THEN FilterIndex:=3
      ELSE IF s='.not' THEN FilterIndex:=4
      ELSE FilterIndex:=1;

      IF Copy(PathName,1,Length(DefaultFilename))=DefaultFilename THEN
        BEGIN
          CASE FormType OF
            ftEditor: FilterIndex:=1;
            ftDocumentation: FilterIndex:=3;
          ELSE
            FilterIndex:=5;
          END;  //case
        END;

      CASE FilterIndex OF
        1: DefaultExt:='qes';
        2: DefaultExt:='chk';
        3: DefaultExt:='log';
        4: DefaultExt:='not';
        5: DefaultExt:='';
      END;  //case
    END;  //with

  IF SaveFileDialog.Execute THEN
    BEGIN
      PathName:=SaveFileDialog.FileName;
      Caption:=' '+ExtractFileName(PathName);
      Gem1Click(Sender);
      MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
        IndexOfObject(TObject(self))]:=ExtractFilename(PathName);
      Ed.Modified:=FALSE;
    END;   //if fil skal gemmes
end;

procedure TEdForm.FormClose(Sender: TObject; var Action: TCloseAction);
VAR
  n: Integer;
BEGIN
  TRY
    Ed.SelLength:=0;
    IF Sender=RapForm THEN RapFormCreated:=FALSE;
    LastActiveEd:=nil;
    MainForm.TabCtrl.Tabs.Delete(MainForm.TabCtrl.Tabs.IndexOfObject(TObject(self)));
    IF MainForm.TabCtrl.Tabs.Count=0 THEN MainForm.TabCtrl.Visible:=False;
    MainForm.StatPanel1.Caption:='';
    MainForm.StatPanel2.Caption:='';
    Action:=caFree;
    {$I-}
    CloseFile(BlockFile);
    n:=IOResult;
    {$I+}
  EXCEPT
  END;
end;

procedure TEdForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
BEGIN
  CanClose:=True;
  IF (Ed.Modified) AND (Sender<>RapForm)
  AND (Caption<>'Information to testers') THEN
  BEGIN
    CASE eDlg(Format(Lang(22108), [PathName]), mtConfirmation,  //'Save changes to %s?'
      [mbYes, mbNo, mbCancel], 0) of
      idYes: Gem1Click(Self);
      idCancel: CanClose := False;
    END;
  END;
  IF Sender=RapForm THEN CanClose:=TRUE;
END;

procedure TEdForm.EdSelectionChange(Sender: TObject);
var
  CurrChar,CurrLin: Integer;
begin
  CurrLin:=SendMessage(Ed.Handle, EM_EXLINEFROMCHAR,0,Ed.SelStart)+1;
  CurrChar:=1+Ed.Selstart-SendMessage(Ed.Handle, EM_LINEINDEX, CurrLin-1, 0);
  MainForm.StatPanel1.Caption:=Format(' '+Lang(22110), [CurrChar,CurrLin]);  //'Pos %d  Line %d'
  IF Ed.SelLength>0 THEN MainForm.StatPanel2.Caption:=
    ' '+IntToStr(Ed.SelLength)+' '+Lang(22112)    //'characters selected'
  ELSE MainForm.StatPanel2.Caption:='';
  Copy1.Enabled:=Ed.SelLength>0;
  Copy2.Enabled:=Copy1.Enabled;
  Cut1.Enabled:=Copy1.Enabled;
  Cut2.Enabled:=Copy1.Enabled;
  MainForm.CopyBtn.Enabled:=Copy1.Enabled;
  MainForm.CutBtn.Enabled:=Copy1.Enabled;
end;


procedure TEdForm.Undo1Click(Sender: TObject);
begin
  with Ed do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TEdForm.New1Click(Sender: TObject);
begin
  MainForm.New1Click(Sender);
end;

procedure TEdForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TEdForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  DefaultFileName:=Lang(22100)+' ';   //'Untitled'
  Inc(WindowNum);
  PathName:=DefaultFileName+IntToStr(WindowNum);
  Caption:=' '+PathName;
  FormType:=ftEditor;
  Ed.SelStart:=0;
  Ed.Modified:=FALSE;
  Ed.Font.Assign(epiEdFont);
  Ed.Color:=EdColor;
  IF MainForm.TabCtrl.Visible=False THEN MainForm.TabCtrl.Visible:=True;
  MainForm.TabCtrl.Tabs.AddObject(PathName,TObject(Self));
  MainForm.TabCtrl.TabIndex:=MainForm.TabCtrl.Tabs.Count-1;
  SaveFileDialog.Filter:=Lang(2102)+'|*.qes|'+
                         Lang(2106)+'|*.chk|'+
                         Lang(2108)+'|*.not|'+
                         Lang(2110)+'|*.log|'+
                         Lang(2112)+'|*.*';

    {2102=EpiData Questionnaire (*.qes)
    2106=EpiData Checkfile  (*.chk)
    2108=Dataentry notes  (*.not)
    2110=Datafile documentation (*.log)
    2112=All (*.*)}
end;


procedure TEdForm.Find1Click(Sender: TObject);
begin
  FindNextPointer:=FindDialog1Find;
  FindDialog1.onFind:=FindNextPointer;
  FindDialog1.Execute;
end;

procedure TEdForm.Replace1Click(Sender: TObject);
begin
  FindNextPointer:=FindDialog1Find;
  ReplacePointer:=ReplaceDialog1Replace;
  ReplaceDialog1.onFind:=FindNextPointer;
  ReplaceDialog1.onReplace:=ReplacePointer;
  ReplaceDialog1.Execute;
end;


procedure TEdForm.FindDialog1Find(Sender: TObject);
var
  FoundAt: LongInt;
  SearchParam: TSearchTypes;
  FindTextStr:String;
begin
  SearchParam:=[];
  IF Sender=FindDialog1 THEN
    BEGIN
      IF (frMatchCase in FindDialog1.Options) THEN SearchParam:=[stMatchCase];
      IF (frWholeWord in FindDialog1.Options) THEN SearchParam:=SearchParam+[stWholeWord];
      FindTextStr:=FindDialog1.FindText;
    END
  ELSE
    BEGIN   //Sender is ReplaceDialog
      IF (frMatchCase in ReplaceDialog1.Options) THEN SearchParam:=[stMatchCase];
      IF (frWholeWord in ReplaceDialog1.Options) THEN SearchParam:=SearchParam+[stWholeWord];
      FindTextStr:=ReplaceDialog1.FindText;
    END;
  FoundAt:=Ed.FindText(FindtextStr,Ed.Selstart+Ed.SelLength,
           Length(Ed.Lines.text),SearchParam);
  IF (FoundAt<>-1) THEN
    BEGIN
      WITH Ed DO
        BEGIN
          SetFocus;
          SelStart:=FoundAt;
          SelLength:=Length(FindTextStr);
        END;  //With
    END
  ELSE eDlg(Format(Lang(22114),[FindTextStr]), mtInformation,[mbOk], 0);  //'"%s" not found'
end;   //Procedure FindDialog1Find

Procedure TEdForm.ReplaceDialog1Replace(Sender: TObject);
VAR
  FoundAt:Integer;
  SearchParam: TSearchTypes;
  NumReplacements:Integer;
BEGIN
  SearchParam:=[];
  NumReplacements:=0;
  WITH ReplaceDialog1 DO
    BEGIN
      IF (frMatchCase in Options) THEN SearchParam:=[stMatchCase];
      IF (frWholeWord in Options) THEN SearchParam:=SearchParam+[stWholeWord];
      IF (frReplace in Options) THEN    //user clicked on Replace button
        BEGIN
          IF (Ed.SelLength>0) AND (Ed.SelText=FindText) THEN
            BEGIN
              Ed.SelText:=ReplaceText;
              FoundAt:=Ed.FindText(Findtext,Ed.Selstart+Ed.SelLength,
                Length(Ed.Lines.text),SearchParam);
                IF (FoundAt<>-1) THEN
                  BEGIN
                    WITH Ed DO
                      BEGIN
                        SetFocus;
                        SelStart:=FoundAt;
                        SelLength:=Length(ReplaceDialog1.FindText);
                      END;  //With
                  END  //If Text found
                ELSE eDlg(Lang(22116), mtInformation,[mbOk], 0);  //'No more occurences found.'
            END  //if SelLength>0 and SelText=FindText
          ELSE
            BEGIN
              //user clicked Replace without using Find Next first
              FindDialog1Find(sender);
            END;
        END   //If user clicked Replace
      ELSE       //user clicked ReplaceAll button
        BEGIN
          FoundAt:=Ed.FindText(Findtext,1,
                   Length(Ed.Lines.text),SearchParam);
          WHILE FoundAt<>-1 DO
            BEGIN
              Ed.SetFocus;
              Ed.SelStart:=FoundAt;
              Ed.SelLength:=Length(FindText);
              Ed.SelText:=ReplaceText;
              INC(NumReplacements);
              FoundAt:=Ed.FindText(Findtext,Ed.Selstart+Ed.SelLength,
                       Length(Ed.Lines.text),SearchParam);
            END;   //while
          eDlg(Format(Lang(22118),[NumReplacements]),    //'%d replacements made'
                     mtInformation,[mbOk], 0);
        END;   //If user click ReplaceAll
    END;   //with replaceDialog1
END;

procedure TEdForm.Print1Click(Sender: TObject);
VAR
  Ed2: TRichEdit;
begin
//  IF MessageDlg(Format(Lang(22120),[ExtractFileName(PathName)]), mtConfirmation,   //'Print %s?'
//      [mbYes, mbNo], 0)=idYes THEN Ed.Print(ExtractFileName(PathName));

  IF Ed.SelLength>0 THEN
    BEGIN
      PrintDialog1.PrintRange:=prSelection;
      Printdialog1.Options:=Printdialog1.Options+[poSelection];
    END
  ELSE
    BEGIN
      PrintDialog1.PrintRange:=prAllPages;
      PrintDialog1.Options:=Printdialog1.Options-[poSelection];
    ENd;
  IF PrintDialog1.Execute THEN
    BEGIN
      IF PrintDialog1.PrintRange=prAllPages THEN Ed.Print(ExtractFileName(PathName))
      ELSE
        BEGIN   //print selection
          TRY
            Ed2:=TRichEdit.Create(Self);
            Ed2.Visible:=False;
            Ed2.Font.Assign(epiEdFont);
            Ed2.Parent:=Self;
            Ed2.Visible:=False;
            Ed2.Lines.Text:=Ed.SelText;
            Ed2.Print(ExtractFileName(PathName));
          FINALLY
            Ed2.Free;
          END;
        END;
    END;  //if execute
end;

procedure TEdForm.Printsettings1Click(Sender: TObject);
begin
  PrinterSetupDialog.Execute;
end;


procedure TEdForm.FormDeactivate(Sender: TObject);
begin
  LastActiveEd:=Ed;
  MainForm.StatPanel1.Caption:='';
  MainForm.StatPanel2.Caption:='';
end;


procedure TEdForm.Fieldpicklist1Click(Sender: TObject);
begin
  IF PickListCreated THEN PickListForm.SetFocus
  ELSE MainForm.PickListBtnClick(sender);
end;

procedure TEdForm.GotoLine1Click(Sender: TObject);
VAR
  tmpS:String;
begin
  tmpS:=eInputBox(Lang(22122),Lang(22124),'');   //'Goto line number...','Please enter linenumber'
  IF (trim(tmpS)='') or (NOT IsInteger(tmpS)) THEN Exit;
  IF StrToInt(tmpS)>Ed.Lines.Count THEN Exit;
  Ed.SelStart:=SendMessage(Ed.Handle, EM_LINEINDEX, StrToInt(tmpS)-1, 0);
end;

procedure TEdForm.Recent11Click(Sender: TObject);
VAR
  rN:Integer;
//  e:String[20];
begin
  rN:=0;
  IF Sender=Recent11 THEN rN:=1;
  IF Sender=Recent21 THEN rN:=2;
  IF Sender=Recent31 THEN rN:=3;
  IF Sender=Recent41 THEN rN:=4;
  IF Sender=Recent51 THEN rN:=5;
  IF Sender=Recent61 THEN rN:=6;
  IF Sender=Recent71 THEN rN:=7;
  IF Sender=Recent81 THEN rN:=8;

//  e:=ANSIUpperCase(ExtractFileExt(RecentQes[rN]));
  IF rN<>0
  THEN
    BEGIN
      IF (FileExists(RecentQes[rN]))
        THEN MainForm.DoOpenQesFile(RecentQes[rN])
      ELSE ErrorMsg(Format(Lang(22126),[RecentQes[rN]]));   //'The file %s does not exist.'
    END;
END;

procedure TEdForm.Filer1Click(Sender: TObject);
VAR
  NoRecent,NoQes:BYTE;
  e:String[20];
begin
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
      RecentDivider.Visible:=True;
      Recent11.Caption:='&1. '+ExtractFileName(RecentQes[1]);
      Recent11.Visible:=True;
    END
  ELSE
    BEGIN
      RecentDivider.Visible:=False;
      Recent11.Visible:=False;
    END;
  IF RecentQes[2]<>'' THEN
    BEGIN
      Recent21.Caption:='&2. '+ExtractFileName(RecentQes[2]);
      Recent21.Visible:=True;
    END
  ELSE Recent21.Visible:=False;
  IF RecentQes[3]<>'' THEN
    BEGIN
      Recent31.Caption:='&3. '+ExtractFileName(RecentQes[3]);
      Recent31.Visible:=True;
    END
  ELSE Recent31.Visible:=False;
  IF RecentQes[4]<>'' THEN
    BEGIN
      Recent41.Caption:='&4. '+ExtractFileName(RecentQes[4]);
      Recent41.Visible:=True;
    END
  ELSE Recent41.Visible:=False;
  IF RecentQes[5]<>'' THEN
    BEGIN
      Recent51.Caption:='&5. '+ExtractFileName(RecentQes[5]);
      Recent51.Visible:=True;
    END
  ELSE Recent51.Visible:=False;
  IF RecentQes[6]<>'' THEN
    BEGIN
      Recent61.Caption:='&6. '+ExtractFileName(RecentQes[6]);
      Recent61.Visible:=True;
    END
  ELSE Recent61.Visible:=False;
  IF RecentQes[7]<>'' THEN
    BEGIN
      Recent71.Caption:='&7. '+ExtractFileName(RecentQes[7]);
      Recent71.Visible:=True;
    END
  ELSE Recent71.Visible:=False;
  IF RecentQes[8]<>'' THEN
    BEGIN
      Recent81.Caption:='&8. '+ExtractFileName(RecentQes[8]);
      Recent81.Visible:=True;
    END
  ELSE Recent81.Visible:=False;
end;

procedure TEdForm.Options2Click(Sender: TObject);
begin
  MainForm.Options1Click(Sender);
end;

procedure TEdForm.CodeWriter1Click(Sender: TObject);
begin
  MainForm.CodeHelpBtnClick(Sender);
end;

procedure TEdForm.Rediger1Click(Sender: TObject);
begin
  CodeWriter1.Checked:=CodeHelpOn;
  FieldPickList1.Checked:=PickListCreated;
  AutoIndent1.Checked:=AutoIndent;
end;

procedure TEdForm.EdKeyPress(Sender: TObject; var Key: Char);
VAR
  tmpS:String;
  numIn,NumIn2:String[10];
  NumInVal:Byte;
  CurLine, n: Integer;
begin
  IF (Key=#13) AND (AutoIndent) THEN
    BEGIN
      {Handle autoindention}
      CurLine:=SendMessage(Ed.Handle, EM_LINEFROMCHAR, Ed.SelStart, 0);
      tmpS:=Ed.Lines[CurLine];
      n:=0;
      IF Length(tmpS)>0 THEN
        BEGIN
          WHILE tmpS[n+1]=' ' DO INC(n);
        END;
      tmpS:='';
      WHILE Length(tmpS)<n DO tmpS:=tmpS+' ';
      Ed.SelText:=#13#10+tmpS;
      Key:=#0;
    END;
  IF Key=#9 THEN
    BEGIN
      Ed.SelText:=cFill(' ',NumberOfTabChars);
      Key:=#0;
    END;
  {Num, Text, UpperText, date dmy-mdy, today dmy-mdy, IDNUM, Bool, Soundex}
  IF CodeHelpOn THEN
    BEGIN
      IF (Key='#') or (Key='_') THEN
        BEGIN
          NumIn:=eInputBox('',Lang(22128),'');  //'Enter length of field:'
          IF (Pos('.',NumIn)>0) or (Pos(',',NumIn)>0) THEN
            BEGIN
              WHILE Pos('.',NumIn)>0 DO NumIn[Pos('.',NumIn)]:=',';
              NumIn2:=Copy(NumIn,Pos(',',NumIn)+1,Length(NumIn));
              NumIn:=Copy(NumIn,1,Pos(',',NumIn)-1);
              TRY
                tmpS:=cFill('#',StrToInt(NumIn))+
                '.'+cFill('#',StrToInt(NumIn2));
              EXCEPT
                tmpS:='';
              END;  //try..except
            END
          ELSE
            BEGIN
              TRY
                NumInVal:=StrToInt(NumIn);
              EXCEPT
                NumInVal:=0;
              END;  //try..Except
              tmpS:='';
              IF NumInVal>0 THEN tmpS:=cFill(Key,NumInVal);
            END;
          Ed.SelText:=tmpS;
          Key:=#0;
        END;  //if # or _ entered
      IF ((UpCase(Key)='A') OR (UpCase(Key)='S') OR (UpCase(Key)='E')) AND (OtherFieldBegun) THEN
        BEGIN
          NumIn:=eInputBox('',Lang(22128),'');   //'Enter length of field:'
          TRY
            NumInVal:=StrToInt(NumIn);
          EXCEPT
            NumInVal:=0;
          END;  //try..except
          IF NumInVal>0 THEN
            BEGIN
              tmpS:=UpCase(Key)+cFill(' ',NumInVal-1)+'>';
              Ed.SelText:=tmpS;
            END;
          Key:=#0;
          OtherFieldBegun:=False;
        END;  //if <A was entered
      IF (UpCase(Key)='D') AND (OtherFieldBegun) THEN
        BEGIN
          Ed.SelText:='dd/mm/yyyy>';
          Key:=#0;
          OtherFieldBegun:=False;
        END;  //if <D was entered
      IF (UpCase(Key)='M') AND (OtherFieldBegun) THEN
        BEGIN
          Ed.SelText:='mm/dd/yyyy>';
          Key:=#0;
          OtherFieldBegun:=False;
        END;  //if <M was entered
      IF (UpCase(Key)='I') AND (OtherFieldBegun) THEN
        BEGIN
          NumIn:=eInputBox('',Lang(22128),'5');   //'Enter length of field:'
          TRY
            NumInVal:=StrToInt(NumIn);
          EXCEPT
            NumInVal:=0;
          END;  //try..except
          IF NumInVal>0 THEN
            BEGIN
              IF NumInVal<5 THEN NumInVal:=5;
              tmpS:='IDNUM'+cFill(' ',NumInVal-5)+'>';
              Ed.SelText:=tmpS;
            END;
          Key:=#0;
          OtherFieldBegun:=False;
        END;  //if <I was entered
      IF (UpCase(Key)='Y') AND (OtherFieldBegun) THEN
        BEGIN
          Ed.SelText:='Y>';
          Key:=#0;
          OtherFieldBegun:=False;
        END;  //if <Y was entered
      IF (OtherFieldBegun) AND (NOT (UpCase(Key) in ['A','S','D','M','I','Y','E']))
      THEN OtherFieldBegun:=False;
      IF (Key='<') THEN OtherFieldBegun:=NOT OtherFieldBegun;
    END;  //if CodeHelpOn
end;  //EdKeyPress

procedure TEdForm.FormActivate(Sender: TObject);
begin
  ChangeGoingOn:=True;
  MainForm.TabCtrl.TabIndex:=MainForm.TabCtrl.tabs.IndexOfObject(TObject(self));
  ChangeGoingOn:=False;
  EdSelectionChange(Sender);
end;


procedure TEdForm.Autoindent1Click(Sender: TObject);
begin
  AutoIndent:=NOT AutoIndent;
end;

procedure TEdForm.Makedatafile1Click(Sender: TObject);
begin
  MainForm.MakeDatafileBtnClick(Sender);
end;

procedure TEdForm.EdKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
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
end;

procedure TEdForm.CloseAll1Click(Sender: TObject);
begin
  MainForm.CloseAll;
end;

procedure TEdForm.Documentdatafile1Click(Sender: TObject);
begin
  MainForm.VariableInfo1Click(sender);
end;

procedure TEdForm.Notes1Click(Sender: TObject);
begin
  MainForm.Studydescription1Click(sender);
end;

procedure TEdForm.Datafilelabel1Click(Sender: TObject);
begin
  MainForm.Datafilelabel2Click(sender);
end;

procedure TEdForm.Listdata1Click(Sender: TObject);
begin
  MainForm.ListData1Click(sender);
end;

procedure TEdForm.Codebook1Click(Sender: TObject);
begin
  MainForm.Codebook1Click(sender);
end;

procedure TEdForm.DisposeTabChars;
VAR
  OldPosition,OldSelLength,FoundAt:LongInt;
  TabStr:ShortString;
  OrgColor: TColor;
BEGIN
  OrgColor:=MainForm.StatPanel2.Font.Color;
  MainForm.StatPanel2.Font.Color:=clRed;
  MainForm.StatPanel2.Caption:=' '+Lang(22130);   //'Replacing TAB-characters. Please wait.'
  MainForm.StatPanel2.Repaint;
  Screen.Cursor:=crHourGlass;
  OldPosition:=Ed.SelStart;
  OldSelLength:=Ed.SelLength;
  LockWindowUpdate(MainForm.Handle);
  FoundAt:=-1;
  TabStr:=cFill(' ',NumberOfTabChars);
  REPEAT
    FoundAt:=Ed.FindText(#9,FoundAt+1,Length(Ed.Lines.Text),[]);
    IF FoundAt>-1 THEN
      BEGIN
        Ed.SelStart:=FoundAt;
        Ed.SelLength:=1;
        Ed.SelText:=TabStr;
      END;
  UNTIL FoundAt=-1;
  LockWindowUpDate(0);
  Ed.SelStart:=OldPosition;
  Ed.SelLength:=OldSelLength;
  MainForm.StatPanel2.Caption:='';
  MainForm.StatPanel2.Font.Color:=OrgColor;
  Screen.Cursor:=crDefault;
END;  //disposeTabChars



procedure TEdForm.Alignentryfields1Click(Sender: TObject);
VAR
  LinNum:Integer;
  FieldPos,n,WidestFieldname: Integer;
  FormStr:String;
  FName,FLabel,RestOfLine:String;

  Function FieldPosInLine(li:Integer):Integer;
  VAR
    t:Integer;
  BEGIN
    Result:=9999;
    t:=Pos('#',Ed.Lines[li]);
    IF (t<>0) AND (t<Result) THEN Result:=t;
    t:=Pos('_',Ed.Lines[li]);
    IF (t<>0) AND (t<Result) THEN Result:=t;
    t:=Pos('<',Ed.Lines[li]);
    IF (t<>0) AND (t<Result) THEN Result:=t;
    IF Result=9999 THEN Result:=-1;
  END;

  Function CountCurly(tmpS: String):Integer;
  VAR
    t:Integer;
  BEGIN
    Result:=0;
    FOR t:=1 TO Length(tmpS) DO
      IF (tmpS[t]='{') or (tmpS[t]='}') THEN INC(Result);
  END;


begin
  LinNum:=SendMessage(Ed.Handle, EM_EXLINEFROMCHAR,0,Ed.SelStart);
  FieldPos:=FieldPosInLine(LinNum);
  IF FieldPos=-1 THEN
    BEGIN
      ErrorMsg(Lang(22132));   //'The current line has no entryfield.'
      Exit;
    END;
  IF EpiInfoFieldNaming THEN FormStr:='%'+IntToStr(FieldPos-2)+'s %-s'
  ELSE
    BEGIN
      WidestFieldname:=0;
      FOR LinNum:=0 TO Ed.Lines.Count-1 DO
        BEGIN
          n:=FieldPosInLine(LinNum);
          IF n<>-1 THEN
            BEGIN
              FLabel:=Copy(Ed.Lines[LinNum],1,n-1);
              IF FLabel<>'' THEN FName:=firstWord(FLabel);
              IF Length(FName)>WidestFieldname THEN WidestFieldname:=Length(FName);
            END;  //if n<>-1
        END;  //for
      IF WidestFieldname=0 THEN WidestFieldname:=10;
      //FormStr:='%-10s %'+IntToStr(FieldPos-10-3)+'s %-s';
      FormStr:='%-'+IntToStr(Widestfieldname)+'s %'+IntToStr(FieldPos-WidestFieldname-3)+'s %-s';
    END;  //if NOT EpiInfoFieldnaming
  FOR LinNum:=0 TO Ed.Lines.Count-1 DO
    BEGIN
      n:=FieldPosInLine(LinNum);
      IF n<>-1 THEN
        BEGIN   //Line has a field
          FLabel:=Copy(Ed.Lines[LinNum],1,n-1);
          RestOfLine:=Copy(Ed.Lines[LinNum],n,Length(Ed.Lines[LinNum]));
          IF NOT (EpiInfoFieldNaming) AND (FLabel<>'') THEN
            BEGIN
              FName:=FirstWord(FLabel);
              Delete(FLabel,Pos(FName,FLabel),Length(FName));
            END;
          IF EpiInfoFieldNaming THEN
            BEGIN
//              FLabel:=cFill(' ',CountCurly(FLabel))+trim(FLabel);
              Ed.Lines[LinNum]:=cFill(' ',CountCurly(FLabel))+Format(FormStr,[trim(FLabel),Trim(RestOfLine)])
            END
          ELSE Ed.Lines[LinNum]:=Format(FormStr,[trim(FName),trim(FLabel),trim(RestOfLine)]);
        END;  //if
    END;  //for
  Ed.SelStart:=0;
  Ed.SelLength:=0;
end;

procedure TEdForm.ValDup1Click(Sender: TObject);
begin
  MainForm.Validate1Click(Sender);
end;

procedure TEdForm.Assertdatafile1Click(Sender: TObject);
begin
  MainForm.Assertdatafile1Click(Sender);
end;

procedure TEdForm.CountRec1Click(Sender: TObject);
begin
  MainForm.Countvalues1Click(sender);
end;

procedure TEdForm.Tools_REC2QESClick(Sender: TObject);
begin
  IF TestDataFormCreated THEN TDataForm(TestDf^.DatForm).Close;
  IF Sender=Tools_REC2QES THEN MainForm.Makeqesfilefromdatafile1Click(Sender)
  ELSE IF Sender=Tools_RevDatafile THEN MainForm.RevisedatafilefromrevisedQESfile1Click(Sender)
  ELSE IF Sender=Tools_Pack THEN MainForm.Packdatafile1Click(Sender)
  ELSE IF Sender=Tools_compress THEN MainForm.Compressdatafile1Click(Sender)
  ELSE IF Sender=Tools_RebuildIndex THEN MainForm.Rebuildindex1Click(Sender)
  ELSE IF Sender=Tools_rename THEN MainForm.Changefieldnames1Click(Sender)
  ELSE IF Sender=Tools_DatafileLabel THEN MainForm.Datafilelabel2Click(Sender)
  ELSE IF Sender=Tools_CopyStruc THEN MainForm.Copydatafilestructure1Click(Sender)
  ELSE IF Sender=Tool_Recode THEN MainForm.Recodedatafile1Click(Sender)
  ELSE IF Sender=tool_color THEN MainForm.Colortable1Click(Sender)
  ELSE IF Sender=Clearallchecks1 THEN  MainForm.ClearChecks1Click(Sender)
  ELSE IF Sender=Zipfiles1 THEN DoZip
  ELSE IF Sender=Unzipfiles1 THEN DoUnZip;
end;

procedure TEdForm.Viewdata1Click(Sender: TObject);
begin
  MainForm.Viewer1Click(Sender);
end;


end.
