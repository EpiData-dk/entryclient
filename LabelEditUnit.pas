unit LabelEditUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ToolWin, Menus, RichEdit, EpiTypes, ExtCtrls;

type
  TActions=(acNewLabel,acCheckFileLabelChanged,acLabelFileLabelChanged,
  acFieldBlockLabelChanged,acCancel,acNone);
  TErrorsFound=(errNoError,errNoLabelIdentifier,errLabelnameFoundInCheckfile,
  errLabelnameFoundInLabelFile,errMissingValue,errMissingText,errNoLabelName,
  errNoCommentLegal,errCommentTooLong);
  TLabelEditForm = class(TForm)
    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    Copy2: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    Undo1: TMenuItem;
    N3: TMenuItem;
    Closeandsave1: TMenuItem;
    Cancel1: TMenuItem;
    Memo2: TMemo;
    Splitter1: TSplitter;
    N1: TMenuItem;
    Autoindent1: TMenuItem;
    Help1: TMenuItem;
    Selectall1: TMenuItem;
    Memo1: TRichEdit;
    procedure Undo1Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Memo11KeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Closeandsave1Click(Sender: TObject);
    procedure Cancel1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Memo2DblClick(Sender: TObject);
    procedure Memo2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Memo2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit1Click(Sender: TObject);
    procedure Autoindent1Click(Sender: TObject);
    procedure Contens1Click(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UseAsEditor: Boolean;
    ContainsLabel: Boolean;
    LblFileLabel:Boolean;
    FieldBlockLabel:Boolean;
    LabelName:String[20];
    LabelPointer:PLabelRec;
    df:PDatafileInfo;
    ActionDone:TActions;
  end;

var
  LabelEditForm: TLabelEditForm;

implementation

{$R *.DFM}

USES
  MainUnit,CheckObjUnit,PeekCheckUnit;

VAR
  DblClicked:Boolean;
  leAutoIndent:Boolean;

procedure TLabelEditForm.Undo1Click(Sender: TObject);
begin
  with Memo1 do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TLabelEditForm.Copy2Click(Sender: TObject);
begin
  Memo1.CopyToClipboard;
end;

procedure TLabelEditForm.Cut1Click(Sender: TObject);
begin
  Memo1.CutToClipboard;
end;

procedure TLabelEditForm.Paste1Click(Sender: TObject);
begin
  Memo1.PasteFromClipboard;
end;



procedure TLabelEditForm.Memo11KeyPress(Sender: TObject; var Key: Char);
VAR
  tmpS:String;
  CurLine,n: Integer;
begin
  CurLine:=SendMessage(Memo1.Handle, EM_LINEFROMCHAR, Memo1.SelStart, 0);
  IF (CurLine=0) AND (NOT ContainsLabel) THEN Key:=#0
  ELSE
    BEGIN
      IF (Key=#8) AND (CurLine=1)
      AND (Memo1.Selstart-SendMessage(Memo1.Handle, EM_LINEINDEX, CurLine, 0)=0)
      THEN Key:=#0;  //Disable BackSpace in line 1, first position
      IF (Key=#13) AND (leAutoIndent) THEN
        BEGIN
          {Find indention i foregående linie}
          tmpS:=Memo1.Lines[CurLine];
          n:=0;
          IF Length(tmpS)>0 THEN
            BEGIN
              WHILE tmpS[n+1]=' ' DO INC(n);
            END;
          {Indsæt indention i den ny linie}
          tmpS:='';
          WHILE Length(tmpS)<n DO tmpS:=tmpS+' ';
          Memo1.SelText:=#13#10+tmpS;
          Key:=#0;
        END;
    END;


  IF Key=#9 THEN
    BEGIN  //TAB Key pressed
      Memo1.SelText:='  ';
      Key:=#0;
    END;
end;

procedure TLabelEditForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

{TYPE
  nwTypes=(nwAny,nwSameLine);}

VAR
  CurLin,CurCommand,ErrorList:String;
  CurLinIndex:Integer;
  EndOfLabel:Boolean;
  CheckObj: TCheckObj;

{  Function NextWord(nwType:nwTypes):String;
  VAR
    n:Integer;
  BEGIN
    IF (trim(CurLin)='') AND (nwType=nwAny) THEN
      BEGIN
        INC(CurLinIndex);
        IF CurLinIndex<Memo1.Lines.Count
        THEN CurLin:=Trim(Memo1.Lines[CurLinIndex])+' '
        ELSE EndOfLabel:=True;
      END;
    IF (trim(CurLin)<>'') THEN
      BEGIN
        Result:=Copy(CurLin,1,Pos(' ',CurLin)-1);
        IF Result[1]='"' THEN
          BEGIN
            n:=Pos(' ',CurLin);
            While (n<=Length(CurLin)) AND (CurLin[n]<>'"') DO
              BEGIN
                Result:=Result+CurLin[n];
                INC(n);
              END;
            Delete(CurLin,1,n);
          END
        ELSE Delete(CurLin,1,Pos(' ',CurLin));
        CurLin:=trim(CurLin)+' ';
      END
    ELSE Result:='';
  END;  //function NextWord
}


  Function TestLabel:Boolean;
  {Reads a LABEL..END block in Memo1}
  VAR
    tmpLabelRec,NextLabelRec:PLabelRec;
    ok,StopRead,FirstLabel:Boolean;
    ErrorFound:TErrorsfound;
    AParser: TParser;
    s:String;
  BEGIN
    TRY
      AParser:=TParser.Create(memo1.Lines.text);
      CurLin:='';
      EndOfLabel:=False;
      CurLinIndex:=-1;
      ok:=True;
      FirstLabel:=True;
      LabelPointer:=NIL;
      tmpLabelRec:=NIL;
      ActionDone:=acNone;
      ErrorFound:=errNoError;
      CurCommand:=AParser.GetLowerToken(nwAny);   //  CurCommand:=AnsiLowerCase(NextWord(nwAny));
      IF (NOT FieldBlockLabel) AND (CurCommand<>'label')
        THEN ErrorFound:=errNoLabelIdentifier;
      IF (FieldBlockLabel) AND (CurCommand<>'comment')
        THEN ErrorFound:=errNoCommentLegal;
      IF ErrorFound=errNoError THEN
        BEGIN
          CurCommand:=AParser.GetLowerToken(nwSameLine);   //CurCommand:=AnsiLowerCase(NextWord(nwSameLine));   //Get Labelname
          IF (NOT FieldBlockLabel) AND (trim(CurCommand)='')
            THEN ErrorFound:=errNoLabelName;
          IF (FieldBlockLabel) AND (trim(CurCommand)<>'legal')
            THEN ErrorFound:=errNoCommentLegal;
          IF ErrorFound=errNoError THEN
            BEGIN
              IF FieldBlockLabel THEN ActionDone:=acFieldBlockLabelChanged
              ELSE IF df^.ValueLabels.IndexOf(CurCommand)<>-1 THEN
                BEGIN
                  ActionDone:=acCheckFileLabelChanged;
                  Labelname:=CurCommand;
                END
              ELSE IF df^.ValueLabels.IndexOf(CurCommand+'¤')<>-1 THEN
                BEGIN
                  ActionDone:=acLabelFileLabelChanged;
                  Labelname:=CurCommand+'¤';
                END
             ELSE
               BEGIN
                 ActionDone:=acNewLabel;
                 Labelname:=CurCommand;
               END;

              StopRead:=False;
              REPEAT
                {Read value}
                CurCommand:=AParser.GetToken(nwAny);   //CurCommand:=NextWord(nwAny);
                IF Trim(CurCommand)='' THEN
                  BEGIN
                    ErrorFound:=errMissingValue;
                    StopRead:=True;
                  END;
                IF AnsiUpperCase(CurCommand)='END' THEN StopRead:=True
                ELSE IF trim(CurCommand)<>'' THEN
                  BEGIN
                    s:=trim(CurCommand);
                    IF s[1]='*' THEN     //###
                      BEGIN
                        s:=trim(AParser.GetWholeLine);
                        IF Length(s)>(30+80) THEN
                          BEGIN
                            ErrorFound:=errCommentTooLong;
                            StopRead:=True;
                          END
                      END;
                    NextLabelRec:=tmpLabelRec;
                    New(tmpLabelRec);
                    tmpLabelRec^.Next:=NIL;
                    IF FirstLabel THEN
                      BEGIN
                        LabelPointer:=tmpLabelRec;
                        FirstLabel:=False;
                      END
                    ELSE NextLabelRec^.Next:=tmpLabelRec;
                    IF Length(CurCommand)>14
                    THEN CurCommand:=Copy(CurCommand,1,14);
                    IF s[1]='*' THEN
                      BEGIN
                        tmpLabelRec^.Value:=Copy(s,1,30);
                        IF Length(s)>30 THEN tmpLabelRec^.Text:=Copy(s,31,Length(s));
                      END
                    ELSE
                      BEGIN
                        tmpLabelRec^.Value:=CurCommand;
                        {Read text}
                        CurCommand:=AParser.GetToken(nwSameLine);   //CurCommand:=NextWord(nwSameLine);
                        IF trim(CurCommand)='' THEN
                          BEGIN
                            StopRead:=True;
                            ErrorFound:=errMissingText;
                          END
                        ELSE
                          BEGIN
                            IF Length(CurCommand)>32
                            THEN CurCommand:=Copy(CurCommand,1,32);
                            WHILE pos('"',CurCommand)>0 DO
                              Delete(CurCommand,Pos('"',CurCommand),1);
                            tmpLabelRec^.Text:=CurCommand;
                          END;
                      END
                  END  //if ValueExist
                ELSE stopRead:=True;
              UNTIL StopRead;
            END;  //if label name was found
        END;  //if Identifier 'Label' was found

      CASE ErrorFound OF
        errNoLabelIdentifier: ErrorMsg(Lang(22500));  //'The labeldefinition must begin with the word LABEL'
        errNoCommentLegal:    ErrorMsg(Lang(22502));  //'A labeldefinition in a fieldblock must begin with COMMENT LEGAL'
        errMissingValue:      ErrorMsg(Lang(22504));  //'No legal values are specified.'
        errMissingText:       ErrorMsg(Lang(22506));  //'A label is missing to a specified value.'
        errNoLabelName:       ErrorMsg(Lang(22508));  //'Please specify a name for the label.'
      END;  //Case

      IF ErrorFound=errNoError THEN
        BEGIN
          CASE ActionDone OF
            acCheckFileLabelChanged:
              BEGIN
                IF eDlg(Format(Lang(22510),[AnsiUpperCase(Labelname)]),  //'A label with the name %s allready exists.~~Replace existing label?'
                mtWarning,[mbOK,mbCancel],0)=mrCancel
                THEN
                  BEGIN
                    ActionDone:=acNone;
                    ErrorFound:=errLabelNameFoundInCheckFile;
                  END;
              END;
            acLabelFileLabelChanged:
              BEGIN  //Label name already used in labelfile
                IF eDlg(Format(Lang(22512),   //'A label with the name %s exists in the label library file.~~Should the the new label be used instead?'
                [AnsiUpperCase(Copy(Labelname,1,Length(Labelname)-1))]),
                mtWarning,[mbOK,mbCancel],0)=mrCancel
                THEN
                  BEGIN
                    ActionDone:=acNone;
                    ErrorFound:=errLabelNameFoundInLabelFile;
                  END;
              END;
          END;  //case
        END;  //if

      IF ErrorFound=errNoError THEN Result:=True
      ELSE
        BEGIN
          Result:=False;
          LabelName:='';
          DisposeLabelRec(LabelPointer);
          LabelPointer:=NIL;
        END;
    FINALLY
      AParser.Free;
    END;
  END;  //TestLabel

begin  //TLabelEditForm.FormCloseQuery
  IF UseAsEditor THEN
    BEGIN
      IF (Memo1.Modified) AND (ModalResult=mrCancel) THEN
        BEGIN
          IF eDlg(Lang(22514),mtConfirmation,[mbYes,mbNo],0)=mrNo   //'Abandon changes?'
          THEN CanClose:=False
          ELSE CanClose:=True;
        END
      ELSE CanClose:=True
    END
  ELSE
    BEGIN
      IF (ModalResult=mrOK) AND (Memo1.Modified) THEN
        BEGIN
          IF ContainsLabel THEN CanClose:=TestLabel
          ELSE
            BEGIN  //a check-field block is being edited
              ErrorList:=Memo1.Lines.Text;
              //CanClose:=StringsToChecks(df, ErrorList);
              TRY
                CheckObj:=TCheckObj.Create;
                CheckObj.MultiLineError:=False;
                CheckObj.ChkFileMode:=True;
                CheckObj.OnTranslate:=MainForm.TranslateEvent;
                CanClose:=CheckObj.ApplyChecks(df,ErrorList);
                ErrorList:=CheckObj.ErrorList;
              Finally
                CheckObj.Free;
              END;
              IF NOT CanClose THEN
                BEGIN
                  Memo2.visible:=true;
                  Memo1.Align:=alTop;
                  Memo1.Height:=ClientHeight-50;
                  Splitter1.Top:=ClientHeight-50;
                  Splitter1.Align:=alTop;
                  Memo2.Lines.Text:=ErrorList;
                END;
            END;
        END
      ELSE IF Memo1.Modified THEN
        BEGIN
          IF eDlg(Lang(22514),mtConfirmation,[mbYes,mbNo],0)=mrNo  //'Abandon changes?'
          THEN CanClose:=False ELSE
            BEGIN
              CanClose:=True;
              ActionDone:=acCancel;
            END;
        END
      ELSE
        BEGIN
          CanClose:=True;
          ActionDone:=acCancel;
        END;
      IF NOT CanClose THEN Memo1.SetFocus;
    END;  //if not UseAsEditor
end;

{
1. Ny label oprettes
   Gælder også hvis eksisterende labels ændrer navn
   Tilføj labelsnavn+PLabelRec til ValueLabels
   + tilbud om tilføjelse til Lbl-fil?

2. Eksisterende label fra Lbl ændres
   Slet eksisterende label fra Valuelabels
   Tilføj labelnavn+PLabelRec til ValueLabels

3. Eksisterende label fra Chk ændres
   Som 2
   + tilbud om opdatering af lbl-fil?

}
procedure TLabelEditForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  LblFileLabel:=False;
  FieldBlockLabel:=False;
  UseAsEditor:=False;
  LabelPointer:=NIL;
  Memo2.visible:=false;
  Memo1.Align:=alClient;
  leAutoIndent:=True;
end;

procedure TLabelEditForm.Closeandsave1Click(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TLabelEditForm.Cancel1Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TLabelEditForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF Key=VK_ESCAPE THEN ModalResult:=mrCancel;
end;

procedure TLabelEditForm.Memo2DblClick(Sender: TObject);
begin
  DblClicked:=True;
end;

procedure TLabelEditForm.Memo2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
VAR
  ClickedLine: LongInt;
  n:Integer;
  tmpStr: String;
  LinNumberStr: String[5];
begin
  IF Key<>VK_RETURN THEN Exit;
  ClickedLine:=SendMessage(Memo2.Handle, EM_LINEFROMCHAR, Memo2.SelStart, 0);
  tmpStr:=Memo2.Lines[ClickedLine];
  n:=Pos(' ',tmpStr)+1;
  LinNumberStr:='';
  WHILE tmpStr[n]<>':' DO
    BEGIN
      LinNumberStr:=LinNumberStr+tmpStr[n];
      INC(n);
    END;
  TRY
    n:=StrToInt(LinNumberStr);
  EXCEPT
    Exit;
  END;  //try..excpet
  DEC(n);
  IF (n<0) or (n>(Memo1.Lines.Count-1)) THEN Exit;
  Memo2.SelStart:=SendMessage(Memo2.Handle, EM_LINEINDEX, ClickedLine, 0);
  Memo2.SelLength:=Length(tmpStr);
  Memo1.SetFocus;
  Memo1.SelLength:=0;
  Memo1.SelStart:=SendMessage(Memo1.Handle, EM_LINEINDEX, n, 0);
  SendMessage(Memo1.Handle, EM_SCROLLCARET,0,0);
end;

procedure TLabelEditForm.Memo2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
VAR
  ClickedLine: LongInt;
  n:Integer;
  tmpStr: String;
  LinNumberStr: String[5];
begin
  IF NOT DblClicked THEN Exit;
  DblClicked:=False;
  ClickedLine:=SendMessage(Memo2.Handle,EM_CHARFROMPOS,0,MAKELPARAM(x,y));
  IF ClickedLine=-1 THEN Exit;
  ClickedLine:=HIWORD(ClickedLine);
  tmpStr:=Memo2.Lines[ClickedLine];
  IF trim(tmpStr)='' THEN Exit;
  n:=Pos(' ',tmpStr)+1;
  LinNumberStr:='';
  WHILE tmpStr[n]<>':' DO
    BEGIN
      LinNumberStr:=LinNumberStr+tmpStr[n];
      INC(n);
    END;
  TRY
    n:=StrToInt(LinNumberStr);
  EXCEPT
    Exit;
  END;  //try..excpet
  DEC(n);
  IF (n<0) or (n>(Memo1.Lines.Count-1)) THEN Exit;
  Memo2.SelStart:=SendMessage(Memo2.Handle, EM_LINEINDEX, ClickedLine, 0);
  Memo2.SelLength:=Length(tmpStr);
  Memo1.SetFocus;
  Memo1.SelLength:=0;
  Memo1.SelStart:=SendMessage(Memo1.Handle, EM_LINEINDEX, n, 0);
  SendMessage(Memo1.Handle, EM_SCROLLCARET,0,0);
end;

procedure TLabelEditForm.Edit1Click(Sender: TObject);
begin
  AutoIndent1.Checked:=leAutoIndent;
end;

procedure TLabelEditForm.Autoindent1Click(Sender: TObject);
begin
  leAutoIndent:=NOT leAutoIndent;
end;

procedure TLabelEditForm.Contens1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_FINDER,0);
end;

procedure TLabelEditForm.Selectall1Click(Sender: TObject);
begin
  Memo1.SelectAll;
end;

end.
