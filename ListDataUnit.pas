unit ListDataUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, checklst, Spin;

type
  TListDataForm = class(TForm)
    DimensionsGroupBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    WidthEdit: TEdit;
    ColEdit: TEdit;
    SpinButton1: TSpinButton;
    NumCharsLabel: TLabel;
    DataGroupBox: TGroupBox;
    WriteLabelsCheckBox: TCheckBox;
    SkipDeletedCheck: TCheckBox;
    FieldsGroupBox: TGroupBox;
    FieldCheckList: TCheckListBox;
    AllBtn: TButton;
    NoneBtn: TButton;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    UseIndexcheck: TCheckBox;
    procedure WidthEditKeyPress(Sender: TObject; var Key: Char);
    procedure WidthEditChange(Sender: TObject);
    procedure AllBtnClick(Sender: TObject);
    procedure NoneBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListDataForm: TListDataForm;
//  ListDataWidth, ListDataCols: Integer;
//  ListDataLabels, ListDataSkipDel: Boolean;


//Procedure Listdata;

implementation

{$R *.DFM}

USES
  EpiTypes, FileUnit, MainUnit, ProgressUnit, EdUnit, PeekCheckUnit;

VAR
  ListDataWidth, ListDataCols: Integer;
  ListDataLabels, ListDataSkipDel: Boolean;

procedure TListDataForm.WidthEditKeyPress(Sender: TObject; var Key: Char);
begin
  IF NOT(Key in NumChars) AND (Key<>#8) THEN
    BEGIN
      Beep;
      Key:=#0;
    END;
end;

procedure TListDataForm.WidthEditChange(Sender: TObject);
VAR
  n:Integer;
  tmpCol,tmpWidth:Integer;
begin
  IF WidthEdit.Text='' THEN tmpWidth:=0 ELSE tmpWidth:=StrToInt(WidthEdit.Text);
  IF ColEdit.Text='' THEN tmpCol:=1 ELSE tmpCol:=StrToInt(ColEdit.Text);
  IF tmpCol=0 THEN tmpCol:=1;
  n:=((tmpWidth-(4*(tmpCol-1))) DIV tmpCol)-10;
  IF n>=2 THEN
    BEGIN
      NumCharsLabel.Caption:=Format(Lang(22600),[n]);  //'Width of data colums: %d'
      NumCharsLabel.Font.Color:=clWindowText;
    END
  ELSE
    BEGIN
      NumCharsLabel.Caption:=Format(Lang(22602),[n]);  //'Warning: Width of data colums is too small (%d)'
      NumCharsLabel.Font.Color:=clRed;
    END;
end;

procedure TListDataForm.AllBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  FOR n:=0 TO FieldCheckList.Items.Count-1 DO
    FieldCheckList.Checked[n]:=True;
end;

procedure TListDataForm.NoneBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  FOR n:=0 TO FieldCheckList.Items.Count-1 DO
    FieldCheckList.Checked[n]:=False;
end;

procedure TListDataForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
VAR
  n:Integer;
  AllUnChecked:Boolean;
  tmpWidth,tmpCol: Integer;
begin
  IF ModalResult=mrOK THEN
    BEGIN
      AllUnChecked:=True;
      FOR n:=0 TO FieldCheckList.Items.Count-1 DO
        IF FieldCheckList.Checked[n]=True THEN AllUnChecked:=False;
      IF AllUnChecked THEN
        BEGIN
          CanClose:=False;
          ErrorMsg(Lang(22604));   //'No fields are selected for list of data.~Please select at least one field.'
        END;
      IF WidthEdit.Text='' THEN tmpWidth:=0 ELSE tmpWidth:=StrToInt(WidthEdit.Text);
      IF ColEdit.Text='' THEN tmpCol:=1 ELSE tmpCol:=StrToInt(ColEdit.Text);
      IF tmpCol=0 THEN tmpCol:=1;
      n:=((tmpWidth-(4*(tmpCol-1))) DIV tmpCol)-10;
      IF (CanClose) AND (n<2) THEN
        BEGIN
          CanClose:=False;
          ErrorMsg(Lang(22606));   //'Width of data columns are to small.~Please change dimensions of list.'
        END
      ELSE IF CanClose THEN
        BEGIN
          WidthEdit.Text:=IntToStr(tmpWidth);
          ColEdit.Text:=IntToStr(tmpCol);
        END;
    END;  //if ModalResult=mrOK
end;

procedure TListDataForm.SpinButton1DownClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF ColEdit.Text='' THEN ColEdit.Text:='1';
  n:=StrToInt(ColEdit.Text);
  IF n>1 THEN DEC(n);
  ColEdit.Text:=IntToStr(n);
end;

procedure TListDataForm.SpinButton1UpClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF ColEdit.Text='' THEN ColEdit.Text:='1';
  n:=StrToInt(ColEdit.Text);
  INC(n);
  ColEdit.Text:=IntToStr(n);
end;

Procedure OldListData;
VAR
  n,CurRec,CurObs,CurField,CurCol:Integer;
  Cols,FieldWidth,MaxWidth: Integer;
  AField: PeField;
  df:PDatafileInfo;
  Lin:TStrings;
  ReadOnlyRecFile,OutFile:TextFile;
  InStr: String[MaxRecLineLength];
  tmpS,tmpS2: String;
  AEdForm: TEdForm;
  ErrorInCheckFile,Found, UseIndex, tmpBool: Boolean;
  ALabelRec: PLabelRec;
  WindowList:Pointer;
begin
  MainForm.DocumentBtn.Down:=False;
  IF NumberOfOpenDatafiles>=MaxNumberOfDatafiles THEN
    BEGIN
      ErrorMsg(Format(Lang(20102),[MaxNumberOfDatafiles]));   //'Only %d datafiles can be open at the same time.'
      MainForm.MakeDatafileBtn.Down:=False;
      Exit;
    END;
  MainForm.OpenDialog1.FilterIndex:=2;    //set filter to *.rec
  n:=1;
  WHILE (n<8) AND
    (AnsiUpperCase(ExtractFileExt(RecentFiles[n]))<>'.REC') DO INC(n);
  IF AnsiUpperCase(ExtractFileExt(RecentFiles[n]))='.REC' THEN
    BEGIN
      MainForm.OpenDialog1.InitialDir:=ExtractFileDir(RecentFiles[n]);
      MainForm.OpenDialog1.Filename:=ExtractFileName(RecentFiles[n]);
    END
  ELSE MainForm.OpenDialog1.Filename:='';
  IF NOT MainForm.OpenDialog1.Execute THEN Exit;
  IF NOT GetDatafilePointer(df) THEN Exit;
  df^.QESFileName:='';
  df^.RECFilename:=MainForm.OpenDialog1.Filename;
  AddToRecentFiles(df^.RECFilename);
  IF PeekDatafile(df) THEN
    BEGIN
      ListDataForm:=TListDataForm.Create(MainForm);
      WITH ListDataForm DO
        BEGIN
          WidthEdit.Text:=IntToStr(ListDataWidth);
          ColEdit.Text:=IntToStr(ListDataCols);
          WriteLabelsCheckBox.Checked:=ListDataLabels;
          SkipDeletedCheck.Checked:=ListDataSkipDel;
        END;  //with
      FOR n:=0 TO df^.FieldList.Count-1 DO
        BEGIN
          AField:=PeField(df^.FieldList.Items[n]);
          IF AField^.FeltType<>ftQuestion THEN
            BEGIN
              ListDataForm.FieldCheckList.Items.AddObject(trim(AField^.FName),TObject(AField));
              ListDataForm.FieldCheckList.Checked[ListDataForm.FieldCheckList.Items.Count-1]:=True;
            END;
        END;
      IF ListDataForm.ShowModal=mrOK THEN
        BEGIN
          WITH ListDataForm DO
            BEGIN
              TRY
                ListDataWidth:=StrToInt(WidthEdit.Text);
                ListDataCols:=StrToInt(ColEdit.Text);
                ListDataLabels:=WriteLabelsCheckBox.Checked;
                ListDataSkipDel:=SkipDeletedCheck.Checked;
              EXCEPT
                ListDataWidth:=80;
                ListDataCols:=3;
              END;
            END;  //WITH
          IF (ListDataLabels) OR (ListDataForm.UseIndexcheck.Checked) THEN
            BEGIN
              {User wants to write value labels instead of values}
              ErrorInCheckFile:=False;
              df^.CHKFilename:=ChangeFileExt(df^.RECFilename,'.chk');
              df^.HasCheckFile:=FileExists(df^.CHKFilename);
              IF df^.HasCheckFile THEN ErrorInCheckFile:=NOT PeekApplyCheckFile(df,tmpS);
              IF ErrorInCheckFile THEN
                BEGIN
                  IF eDlg(format(Lang(20800),[df^.CHKFilename])+   //'The checkfile %s contains errors and cannot be applied.'
                    #13#13+Lang(22608)+#13#13+Lang(22610),mtWarning,[mbYes,mbNo],0)=mrNo THEN
                    {22608='If you continue to list data then the values of the fields will be shown and not the value labels.'
                     22610='Do you want to continue to list data?'}
                  BEGIN
                    ListDataForm.Free;
                    DisposeDatafilePointer(df);
                    Exit;
                  END;  //if users aborts
                END  //if errorInCheckFile
              ELSE ApplyIndex(df);
            END;  //if WriteLabelsCheckBox

          {Initialize progressform}
          TRY
            UserAborts:=False;
            ProgressForm:=TProgressForm.Create(MainForm);
            ProgressForm.Caption:=Lang(22612);   //'Creating list of data';
            ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
            ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
            WITH ProgressForm.pBar DO BEGIN
              IF df^.NumRecords>2 THEN Max:=df^.NumRecords-2 ELSE Max:=2;
              Position:=0;
            END;  //with
            WindowList:=DisableTaskWindows(ProgressForm.Handle);
            ProgressForm.Show;

            {Initialize outputfile}
            AssignFile(OutFile,ChangeFileExt(df^.RECFilename,'.lo$'));
            Rewrite(OutFile);

            {Initialize inputfile}
            CloseFile(df^.DatFile);
            AssignFile(ReadOnlyRecfile,df^.RECFilename);
            Reset(ReadOnlyRecfile);
            FOR n:=0 TO df^.FieldList.Count DO
              ReadLn(ReadOnlyRecFile,InStr);
            {filepointer in ReadOnlyRecFile now points to first record}

            Lin:=TStringList.Create;
            Cols:=ListDataCols;
            MaxWidth:=ListDataWidth;
            FieldWidth:=((MaxWidth-(4*(Cols-1))) DIV Cols)-10;
            CurObs:=0;
            WriteLn(OutFile);
            WriteLn(OutFile,Format(Lang(22614),[df^.RECFilename]));
            WriteLn(OutFile,Format(Lang(22616),[FormatDateTime('d. mmm. yyyy t',Now)]));
            WriteLn(OutFile);
            WriteLn(OutFile);
//            Lin.Append('');
  //          Lin.Append(Format(Lang(22614),[df^.RECFilename]));  //'List of observations in %s'
    //        Lin.Append(Format(Lang(22616),[FormatDateTime('d. mmm. yyyy t',Now)]));  //'List created %s'
      //      Lin.Append('');
        //    Lin.Append('');
            UserAborts:=False;
            UseIndex:=(df^.IndexCount>0) AND (ListDataForm.UseIndexcheck.Checked) AND (NOT ErrorInCheckFile);
            IF UseIndex THEN InitSortIndex(df);
            FOR CurRec:=1 TO df^.NumRecords DO
              BEGIN
                IF (CurRec MOD 20)=0 THEN
                  BEGIN
                    ProgressForm.pBar.Position:=CurRec;
                    ProgressForm.pLabel.Caption:=Format(Lang(20828),[CurRec,df^.NumRecords]);  //Writing field no. %d of %d
                    Application.ProcessMessages;
                  END;
                IF UseIndex THEN eReadOnlyRecord(df,ReadOnlyRecFile,ReadIndexNoFromSortIndex(df,CurRec))
                ELSE eReadOnlyRecord(df,ReadOnlyRecFile,CurRec);
                IF NOT ((ListDataSkipDel) AND (df^.CurRecDeleted)) THEN
                  BEGIN
                    INC(CurObs);
                    IF UseIndex
                    THEN WriteLn(OutFile,Format(Lang(22618),[CurObs,ReadIndexNoFromSortIndex(df,CurRec)]))
                    ELSE WriteLn(OutFile,Format(Lang(22618),[CurObs,CurRec]));
                    WriteLn(OutFile);
//                    THEN Lin.Append(Format(Lang(22618),[CurObs,ReadIndexNoFromSortIndex(df,CurRec)]))  //'Observation %d  (record #%d)'
  //                  ELSE Lin.Append(Format(Lang(22618),[CurObs,CurRec]));  //'Observation %d  (record #%d)'
    //                Lin.Append('');
                    CurCol:=1;
                    tmpS:='';
                    FOR CurField:=0 TO ListDataForm.FieldCheckList.Items.Count-1 DO
                      BEGIN
                        IF ListDataForm.FieldCheckList.Checked[CurField] THEN
                          BEGIN
                            AField:=PeField(ListDataForm.FieldCheckList.Items.Objects[CurField]);
                            {Write name of field}
                            IF CurCol>1 THEN tmpS:=tmpS+'    ';
                            tmpS:=tmpS+Format('%8s',[trim(AField^.FName)])+'  ';

                            {Write value of field}
                            IF (AField^.FCommentLegalRec<>NIL) AND (ListDataLabels)
                            AND (NOT ErrorInCheckFile) THEN
                              BEGIN
                                {The field has value labels and the user want to see them}
                                IF trim(AField^.FFieldText)='' THEN tmpS2:='.'
                                ELSE tmpS2:=GetCommentLegalText(trim(AField^.FFieldText),AField^.FCommentLegalRec);
                                IF tmpS2='' THEN tmpS2:='.';
                              END  //if Field has value labels
                            ELSE
                              BEGIN
                                IF trim(AField^.FFieldText)='' THEN tmpS2:='.'
                                ELSE tmpS2:=trim(AField^.FFieldText);
                              END;

                            WHILE Length(tmpS2)<FieldWidth DO tmpS2:=' '+tmpS2;
                            IF Length(tmpS2)>FieldWidth
                              THEN tmpS2:=Copy(tmpS2,1,FieldWidth-2)+'--';
                            tmpS:=tmpS+tmpS2;
                            INC(CurCol);
                            IF CurCol>Cols THEN
                              BEGIN
                                WriteLn(OutFile,tmpS);
                                //Lin.Append(tmpS);
                                tmpS:='';
                                CurCol:=1;
                              END;
                          END;  //if field should be written
                      END;  //for CurField
                    WriteLn(OutFile,tmpS);
                    WriteLn(OutFile);
                    WRiteLn(OutFile);
//                    Lin.Append(tmpS);
  //                  Lin.Append('');
    //                Lin.Append('');
                  END;  //if not skip record

                IF UserAborts THEN
                  BEGIN
                    IF eDlg(Lang(22620),mtConfirmation,[mbYes,mbNo],0)=mrYes  //'Abort List Data?'
                    THEN
                      BEGIN
                        CloseFile(Outfile);
                        tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.lo$'));
                        Lin.Free;
                        ListDataForm.Free;
                        DisposeDatafilePointer(df);
                        Exit;
                      END
                    ELSE UserAborts:=False;
                  END;  //if UserAborts
              END;  //for CurRecord
          FINALLY
            CloseFile(ReadOnlyRecFile);
            EnableTaskWindows(WindowList);
            ProgressForm.Free;
          END;  //try..finally
          CloseFile(outFile);
          AEdForm:=TEdForm.Create(MainForm);
          WITH AEdForm DO
            BEGIN
              Open(ChangeFileExt(df^.RECFilename,'.lo$'));
              CloseFile(BlockFile);
              PathName:=DefaultFilename;
              Caption:=Format(Lang(22614),[df^.RECFilename]);
              MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                IndexOfObject(TObject(AEdForm))]:=DefaultFilename;
              FormType:=ftDocumentation;
              Ed.Font:=epiDocuFont;
              Ed.SelStart:=0;
              Ed.Modified:=True;
            END;  //with
          tmpBool:=DeleteFile(ChangeFileExt(df^.RECFilename,'.lo$'));
{          IF Length(Lin.Text)>65500 THEN
            BEGIN
              tmpS:=ExtractFileDir(ParamStr(0))+'\~EpdLog';
              n:=1;
              WHILE FileExists(tmpS+IntToStr(n)+'.tmp') DO INC(n);
              tmpS:=tmpS+IntToStr(n)+'.tmp';
              Lin.SaveToFile(tmpS);
              AEdForm:=TEdForm.Create(MainForm);
              WITH AEdForm DO
                BEGIN
                  Open(tmpS);
                  CloseFile(BlockFile);
                  PathName:=DefaultFilename;
                  Caption:=Format(Lang(22614),[df^.RECFilename]);  //'List of observations in %s'
                  MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
                    IndexOfObject(TObject(AEdForm))]:=DefaultFilename;
                  FormType:=ftDocumentation;
                  Ed.Font:=epiDocuFont;
                  Ed.SelStart:=0;
                  Ed.Modified:=True;
                END;  //with
              tmpBool:=DeleteFile(tmpS);
            END
          ELSE
            BEGIN
              {Lin.Text < 65500 chars}
{              Screen.Cursor:=crHourGlass;
              LockWindowUpdate(MainForm.Handle);
              AEdForm:=TEdForm.Create(MainForm);
              WITH AEdForm DO
                BEGIN
                  Ed.Visible:=False;
                  FormType:=ftDocumentation;
                  Caption:=Format(Lang(22614),[df^.RECFilename]);  //'List of observations in %s'
                  Ed.Font:=epiDocuFont;
                  Ed.Color:=DocuColor;
                  Ed.ScrollBars:=ssBoth;
                  Ed.Lines.Capacity:=Lin.Count;
                  Ed.Lines.Text:=Lin.Text;
                  Ed.ScrollBars:=ssBoth;
                  Ed.Visible:=True;
                  Ed.SelStart:=0;
                END;
//              MainForm.TabCtrl.Tabs[MainForm.TabCtrl.tabs.
//              IndexOfObject(TObject(AEdForm))]:=ExtractFilename(AEdForm.PathName);
//              AddToRecentFiles(AEdForm.PathName);
              LockWindowUpDate(0);
              Screen.Cursor:=crDefault;
            END;  //Lin.Text < 65500 chars}
          Lin.Free;
        END;   //Run List Data (ModalResult=mrOK)
      ListDataForm.Free;
      DisposeDatafilePointer(df);
    END;  //Datafile opened with succes
end;   //procedure Listdata


procedure TListDataForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
end;

end.
