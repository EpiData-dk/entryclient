unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    OpenDialog1: TOpenDialog;
    FindFile1: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    pBar: TProgressBar;
    procedure FindFile1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

Procedure ErrorMsg(CONST s: String);
BEGIN
  MessageDlg(s,mtError,[mbOK],0);
END;

procedure TForm1.FindFile1Click(Sender: TObject);
begin
  IF Edit1.Text<>'' THEN OpenDialog1.Filename:=Edit1.Text;
  IF Opendialog1.Execute THEN Edit1.Text:=OpenDialog1.Filename;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  IF Edit2.Text<>'' THEN OpenDialog1.Filename:=Edit2.Text;
  IF Opendialog1.Execute THEN Edit2.Text:=OpenDialog1.Filename;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
VAR
  CLin,Lin,NewLin: TStringList;
  Cp,Lp: Integer;
  n,CVal,LVal: Integer;
  Stop: Boolean;
  s,s2: String;
begin
  IF NOT FileExists(Edit1.Text) THEN
    BEGIN
      ErrorMsg('File '+Edit1.Text+' does not exist.');
      Exit;
    END;
  IF FileExists(Edit2.Text) THEN
    BEGIN
      IF MessageDlg('File '+Edit2.Text+' already exists.'+
      #13#13+'Overwrite existing file?',mtWarning,[mbOK,mbCancel],0)<>mrOK
      THEN Exit;
    END;
  IF NOT FileExists('LangChanges20.txt') THEN
    BEGIN
      ErrorMsg('File LangChanges20.txt not found.');
      Exit;
    END;
  TRY
    CLin:=TStringList.Create;
    Lin:=TStringList.Create;
    NewLin:=TStringList.Create;
    TRY
      CLin.LoadFromFile('LangChanges20.txt');
      Lin.LoadFromFile(Edit1.Text);
    EXCEPT
      ErrorMsg('Error loading LangChanges20.txt or '+Edit1.Text);
      Exit
    END;
    IF CLin.Count=0 THEN
      BEGIN
        ErrorMsg('LangChanges20.txt is empty');
        Exit;
      END;
    IF Lin.Count=0 THEN
      BEGIN
        ErrorMsg(Edit1.Text+' is empty');
        Exit;
      END;
    NewLin.Capacity:=CLin.Count+Lin.Count;
    pBar.Visible:=True;
    pBar.Max:=CLin.Count-1;
    Cp:=0;
    Lp:=0;
    Stop:=False;
    CVal:=-1;

    TRY
      REPEAT
        //Get next wait value for CLin
        IF (CVal=-1) AND (Cp<CLin.Count) THEN
          BEGIN
            WHILE (Cp<CLin.Count) AND (CLin[Cp]='') DO INC(Cp);
            IF Cp<CLin.Count THEN
              BEGIN
                IF CLin[Cp][1]='[' THEN s:=CLin[Cp+1] ELSE s:=CLin[Cp];
                s:=Copy(s,1,Pos('=',s)-1);
                CVal:=StrToInt(s);
              END;
          END;

        //What is val of current line in Lin?
        WHILE (Lp<Lin.Count) AND (Lin[Lp]='') DO
          BEGIN
            NewLin.Append('');
            INC(Lp);
          END;
        IF Lp<Lin.Count THEN
          BEGIN
            IF Lin[Lp][1]='[' THEN
              BEGIN
                n:=0;
                REPEAT
                  INC(n);
                UNTIL pos('=',Lin[Lp+n])>0;
                s:=Lin[Lp+n];
              END
            ELSE s:=Lin[Lp];
            s:=Copy(s,1,Pos('=',s)-1);
            LVal:=StrToInt(s);
            IF ((LVal>=10000) AND (LVal<20000)) THEN LVal:=0;
          END
        ELSE LVal:=0;

        IF (Lp=Lin.Count) OR (LVal>=CVal) THEN
          BEGIN
            IF Cp<CLin.Count THEN
              BEGIN
                IF CLin[Cp][1]='[' THEN
                  BEGIN
                    NewLin.Append('');
                    NewLin.Append(CLin[Cp]);
                  END
                ELSE NewLin.Append('***'+CLin[Cp]);
                CVal:=-1;
                INC(Cp);
              END;
          END
        ELSE IF Lp<Lin.Count THEN
          BEGIN
            NewLin.Append(Lin[Lp]);
            INC(Lp);
          END;
      UNTIL (Lp>=Lin.Count) AND (Cp>=CLin.Count);
    EXCEPT
      pBar.Visible:=False;
      ErrorMsg('Error while handling'+#13+
               'line '+IntToStr(Cp+1)+' in LangChange20.txt'+#13+
               'line '+IntToStr(Lp+1)+' in '+Edit1.Text);
      Exit;
    END;
    NewLin.SaveToFile(Edit2.Text);
    pBar.Visible:=False;
    MessageDlg('Merge finished'#13#13'Merged language file saved as '+Edit2.Text,mtInformation,[mbOK],0);
    Close;
  FINALLY
    pBar.Visible:=False;
    CLin.Free;
    Lin.Free;
    NewLin.Free;
  END;
end;

end.
