unit unitGCPAdmin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ComCtrls, Grids, ExtCtrls;

type
  TformGCPAdmin = class(TForm)
    PageControl1: TPageControl;
    tabProject: TTabSheet;
    tabUsers: TTabSheet;
    Label1: TLabel;
    editProjectName: TEdit;
    Label2: TLabel;
    editAdminUsername: TEdit;
    Label3: TLabel;
    editAdminPw1: TEdit;
    Label4: TLabel;
    editAdminPw2: TEdit;
    GroupBox1: TGroupBox;
    checkEncryptChk: TCheckBox;
    checkEncryptRec: TCheckBox;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    comboLogWhere: TComboBox;
    editLogFilename: TEdit;
    checkLogNew: TCheckBox;
    checkLogEdit: TCheckBox;
    checkLogDel: TCheckBox;
    checkLogRead: TCheckBox;
    checkLogFind: TCheckBox;
    tabFiles: TTabSheet;
    sg: TStringGrid;
    Label7: TLabel;
    FilenameEdit: TEdit;
    SearchBtn: TBitBtn;
    AddBtn: TBitBtn;
    RemoveBtn: TBitBtn;
    EvalList: TListBox;
    Panel1: TPanel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    Label9: TLabel;
    editProjectDesc: TEdit;
    combo: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure EvalListClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure comboChange(Sender: TObject);
    procedure sgSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FFilename: string;
    FIsNew: Boolean;
    IntroDone: boolean;
    procedure SetFilename(filename: string);
    procedure CMDialogKey(var msg: TCMDialogKey);  message CM_DIALOGKEY;
  public
    { Public declarations }
    property filename:string read FFilename write SetFilename;
  end;

var
  formGCPAdmin: TformGCPAdmin;



implementation

{$R *.DFM}

USES
  EpiTypes,unitGCPClasses,uCredentials;

CONST
  MaxFiles=50;


var
  Filenames:     Array[1..MaxFiles] of TFilename;
  Fields:        Array[1..MaxFiles] of TStringList;
  IsActive:      Array[1..MaxFiles] of Boolean;
  MaxValueWidth: Array[0..MaxFiles] of Integer;
  EvalField:     String;
  LastDir:       String;

procedure TformGCPAdmin.FormCreate(Sender: TObject);
var
  n,t: integer;
begin
  IntroDone:=false;
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

  sg.DefaultRowHeight:=combo.Height;
  sg.RowCount:=MAXGCPUSERS+1;
  sg.Cells[1,0]:='Username';
  sg.Cells[2,0]:='Type';
  sg.Cells[3,0]:='Password';
  sg.Cells[4,0]:='Notes';
  for n:=1 to sg.RowCount-1 do
    sg.Cells[0,n]:='User '+IntToStr(n);
  PageControl1.ActivePage:=tabProject;

  comboLogWhere.ItemIndex:=0;
  FIsNew:=True;
end;


procedure TformGCPAdmin.CMDialogKey(var msg: TCMDialogKey);
begin
if (ActiveControl = combo) then
  begin
    if (msg.CharCode = VK_TAB) or (msg.CharCode = VK_LEFT) or (msg.CharCode = VK_RIGHT) then
    begin
      //set focus back to the grid and pass the tab key to it
      combo.visible:=false;
      //combo.Perform(WM_KEYDOWN, msg.CharCode, msg.KeyData);
      if (msg.CharCode=VK_LEFT) then sg.col:=2 else sg.col:=3;
      sg.SetFocus;
      msg.result := 1;
      Exit;
    end;
  end;

  inherited;
end;

procedure TformGCPAdmin.SearchBtnClick(Sender: TObject);
begin
  OpenDialog1.InitialDir:=LastDir;
  IF OpenDialog1.Execute THEN
    BEGIN
      FilenameEdit.Text:=OpenDialog1.Files.CommaText;
      AddBtnClick(Sender);
    END;
end;

procedure TformGCPAdmin.AddBtnClick(Sender: TObject);
VAR
  n:Integer;
  tmplist: TStringList;
  basename: string;
begin
  basename:=extractfilepath(ExpandFilename(editProjectname.text));
  tmplist:=TStringList.create;
  try
    IF trim(FilenameEdit.Text)='' THEN Exit;
    tmpList.Clear;
    tmpList.CommaText:=FilenameEdit.Text;
    IF tmpList.Count+EvalList.Items.Count > MaxFiles THEN
      BEGIN
        ErrorMsg(Format(Lang(23716),[MaxFiles]));  //'A maximum of %d files can be evaluated'
        Exit;
      END;
    for n:=0 to tmpList.Count-1 do
      tmpList[n]:=ExtractRelativePath(basename,ExpandFilename(tmpList[n]));
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
        IF NOT FileExists(basename+EvalList.Items[n]) THEN
          BEGIN
            ErrorMsg(Format(Lang(20110),[basename+EvalList.Items[n]]));   //20110=Datafile %s does not exist.
            EvalList.Items.Delete(n);
            Continue;
          END;
      END;  //for
    IF EvalList.Items.Count>0 THEN LastDir:=ExtractFileDir(EvalList.Items[EvalList.Items.Count-1]);
  finally
    tmplist.free;
  end;
end;

procedure TformGCPAdmin.RemoveBtnClick(Sender: TObject);
VAR
  n:Integer;
begin
  IF EvalList.SelCount=0 THEN Exit;
  FOR n:=EvalList.Items.Count-1 DOWNTO 0 DO
    IF EvalList.Selected[n] THEN EvalList.Items.Delete(n);
  RemoveBtn.Enabled:=false;
end;

procedure TformGCPAdmin.EvalListClick(Sender: TObject);
begin
  RemoveBtn.Enabled:=(EvalList.SelCount>0);
end;

procedure TformGCPAdmin.SetFilename(filename: string);
begin
  FFilename:=ExpandFilename(filename);
  if AnsiLowerCase(ExtractFileExt(FFilename))<>'.sec' then FFilename:=ChangeFileExt(FFilename,'.sec');
  FIsNew:=false;
end;

procedure TformGCPAdmin.FormCloseQuery(Sender: TObject;  var CanClose: Boolean);
var
  tmpFilename,s,username,usertype,userpw,usernote,masterpw:string;
  maxlen,n,t: integer;
  lin: TStringList;
  secfile: TGCPsecfile;
  F:TextFile;
  eline, filelabel,cryptkey: string;
  NumFields,TempInt,TempInt2: integer;
  vlab: boolean;
begin
  CanClose:=true;
  if ModalResult=mrCancel then exit;

  tmpFilename:=Expandfilename(editProjectname.text);
  if FileExists(tmpFilename) then
    begin
      if WarningDlg('Project file '+tmpFilename+' already exists'#13#13'Overwrite existing file?')=mrCancel then exit;
    end;

  //Validation
  if  trim(editProjectName.Text)='' then
    begin
      ErrorMsg('Please enter project file name');
      editProjectName.SetFocus;
      CanClose:=false;
      exit;
    end;

  s:=editAdminUsername.Text;
  if (trim(s)='') or (length(s)<4) then
    begin
      ErrorMsg('Administrator''s username must been 4 characters or more');
      CanClose:=false;
      exit;
    end;
  s:=editAdminPw1.text;
  if (not PasswordIsLegal(s)) then
    begin
      ErrorMsg('Administrator password must has 6 or more characters and must contain lower case and upper case letters and numbers.');
      Canclose:=False;
      exit;
    end;
  if (s<>editAdminPw2.text) then
    begin
      ErrorMsg('The two administrator passwords do not match');
      CanClose:=false;
      exit;
    end;
  masterpw:=s;
  if (comboLogWhere.ItemIndex=0) then
    begin
      //Logfile is local file
      if (trim(editLogFilename.text)='') then
        begin
          ErrorMsg('Please enter file name of logfile');
          editLogFilename.setFocus;
          CanClose:=false;
          exit;
        end;
    end
  else
    begin
      ErrorMsg('Only logfile as local file is implemented presently');
      CanClose:=false;
      exit;
    end;

  //Check userinfo
  for n:=1 to sg.RowCount-1 do
    begin
      username:=ansilowercase(trim(sg.Cells[1,n]));
      usertype:=sg.Cells[2,n];
      userpw:=trim(sg.Cells[3,n]);
      usernote:=trim(sg.Cells[4,n]);
      if ((username+userpw+usernote)<>'') then
        begin
          if (username='') or (userpw='') then
            begin
              CanClose:=false;
              ErrorMsg('Missing username og user password in user '+IntToStr(n));
              PageControl1.ActivePage:=tabUsers;
              exit;
            end;
          if (usertype='') then
            begin
              CanClose:=false;
              ErrorMsg('No user type selected in user '+IntToStr(n));
              PageControl1.ActivePage:=tabUsers;
              exit;
            end;
          if n>1 then
            begin
              for t:=1 to n-1 do
                if (ansilowerCase(sg.Cells[1,t])=username) then
                  begin
                    ErrorMsg('Dublicate username found in user '+IntToStr(n));
                    Canclose:=false;
                    PageControl1.ActivePage:=tabUsers;
                    exit;
                  end;
            end; //if n>1
          if (length(username)<4) then
            begin
              ErrorMsg('Username '+IntToStr(n)+' is too short.'#13#13'Usernames must be 4 or more characters');
              Canclose:=false;
              PageControl1.ActivePage:=tabUsers;
              exit;
            end;
          if (length(userpw)<6) or (not PasswordIslegal(userpw)) then
            begin
              ErrorMsg('Password for user '+InttoStr(n)+' is not legal.'#13#13'Passwords must be 6 or more characters and must contain lower case and upper case letters and numbers.');
              Canclose:=false;
              PageControl1.ActivePage:=tabUsers;
              exit;
            end;
        end;  //if userrow not empty
    end;  //for n

    if (evalList.Items.Count=0) then
      begin
        if WarningDlg('Project contains no data files'#13#13'Continue?')=mrCancel then
          begin
            CanClose:=false;
            exit;
          end;
      end
    else
      begin
        //Check if all files in project exists
        s:='';
        for n:=0 to evalList.Count-1 do
          if (not fileexists(evalList.Items[n])) then s:=s+evalList.Items[n]+#13;
        if s<>'' then
          begin
            ErrorMsg('One or more files in the project does not exist:'#13+s);
            CanClose:=false;
            exit;
          end;

        //check all recfiles on the list for encrypted fields
        lin:=TStringList.create;
        try
          for n:=0 to evalList.Count-1 do
            begin
              try
                lin.LoadFromFile(evalList.Items[n]);
              except
                ErrorMsg(format('The file %s cannot be opened',[evalList.Items[n]]));
                CanClose:=false;
                exit;
              end;
              eline:=lin[0]+' ';
              s:=COPY(eLine,1,POS(' ',eLine)-1);
              IF IsInteger(s) THEN NumFields:=StrToInt(s)
              else
                begin
                  ErrorMsg(format('The file %s is not a proper EpiData data file',[evalList.Items[n]]));
                  CanClose:=false;
                  exit;
                end;
              cryptkey:='';
              TempInt:=pos('~kq:',eLine);
              IF TempInt>0 THEN
                begin
                  //Datafile contains a crypt-key
                  TempInt2:=pos(':kq~',eLine);
                  if (TempInt2>0) AND (TempInt2>TempInt) THEN cryptkey:=copy(eLine,TempInt+4,TempInt2-TempInt-4);
                end;
              TempInt:=Pos('FILELABEL: ',AnsiUpperCase(eLine));
              IF TempInt<>0 THEN Filelabel:=Copy(eLine,TempInt+Length('FILELABEL: '),Length(eLine));
              IF Pos(' VLAB',eLine)>0 THEN vlab:=true ELSE vlab:=false;

              //TODO: håndtering af krypterede filer med data

              eline:=IntToStr(NumFields)+' 1';
              if vlab then eline:=eline+' VLAB';
              eline:=eline+' ~pf:'+ExtractFilename(editProjectname.text)+':pf~';
              if trim(Filelabel)<>'' then eline:=eline+' Filelabel: '+Filelabel;
              lin[0]:=eline;
              try
                lin.SaveToFile(evalList.Items[n]);
              except
                ErrorMsg(format('Error saving %s',[evalList.items[n]]));
                CanClose:=false;
                exit;
              end;
            end;  //for
        finally
          lin.Free;
        end;
      end;

  if AnsiLowerCase(ExtractFileExt(tmpFilename))<>'.sec' then tmpFilename:=ChangeFileExt(tmpfilename,'.sec');
  if ((FIsNew) AND (FileExists(tmpFilename)))
  or ((NOT FIsNew) AND (AnsiLowercase(tmpFilename)<>AnsiLowercase(FFilename)) AND (Fileexists(tmpFilename))) then
    begin
      if WarningDlg('A project file '+tmpFilename+' already exists'#13#13'Replace existing file?')=mrCancel then
        begin
          Canclose:=false;
          exit;
         end;
    end;      

    secfile:=TGCPsecfile.create;
    try
      secfile.MasterUsername:=editAdminusername.text;
      secfile.MasterPassword:=masterpw;
      for n:=1 to sg.RowCount-1 do
        secfile.AddUser(sg.Cells[1,n],sg.Cells[2,n],sg.Cells[3,n],sg.Cells[4,n]);
      secfile.ProjectDescription:=editProjectDesc.text;
      secfile.ProjectFilename:=tmpFilename;
      secfile.EncryptDataFile:=checkEncryptRec.Checked;
      secfile.EncryptCheckFile:=checkEncryptChk.Checked;
      if comboLogWhere.ItemIndex =1 then s:='webservice'
      else if comboLogWhere.ItemIndex=2 then s:='ftp'
      else s:='localfile';
      secfile.LogWhere:=s;
      secfile.Logfilename:=editLogFilename.Text;
      secfile.LogNew:=checkLogNew.Checked;
      secfile.LogEdit:=checkLogEdit.Checked;
      secfile.LogDel:=checkLogDel.Checked;
      secfile.LogRead:=checkLogRead.Checked;
      secfile.LogFind:=checkLogFind.Checked;
      for n:=0 to evalList.Items.Count-1 do
        secfile.Datafiles.Append(ExtractFilename(evalList.Items[n]));
      secfile.Save;
    finally
      secfile.free;
    end;
end;

procedure TformGCPAdmin.comboChange(Sender: TObject);
var intRow: Integer;
begin
  inherited;

  {Get the ComboBox selection and place in the grid}
  with combo do
  begin
    intRow := sg.Row;
    if (sg.Col = 2) then
      begin
        sg.Cells[2, intRow] := Items[ItemIndex];
        Visible := False;
      end;
  end;
  sg.SetFocus;
end;

procedure TformGCPAdmin.sgSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var R: TRect;
begin
  if ((ACol = 2) and (ARow <> 0)) then
  begin
    {Size and position the combo box to fit the cell}
    R := sg.CellRect(ACol, ARow);
    R.Left := R.Left + sg.Left;
    R.Right := R.Right + sg.Left;
    R.Top := R.Top + sg.Top;
    R.Bottom := R.Bottom + sg.Top;

    {Show the combobox}
    with combo do
    begin
      Left := R.Left + 1;
      Top := R.Top + 1;
      Width := (R.Right + 1) - R.Left;
      Height := (R.Bottom + 1) - R.Top;

      ItemIndex := Items.IndexOf(sg.Cells[ACol, ARow]);
      Visible := True;
      SetFocus;
    end;
  end
  else combo.visible:=false;
  CanSelect := True;
end;


procedure TformGCPAdmin.FormPaint(Sender: TObject);
var
  secfile: TGCPsecfile;
  n: integer;
begin
  if (not IntroDone) then
    begin
      IntroDone:=true;
      if FFilename<>'' then
        begin
          //Load existing sec-file
          formCredentials:=TformCredentials.Create(self);
          try
            n:=formCredentials.ShowModal;
            if n=mrCancel then
              begin
                ErrorMsg('Invalid username or password');
                exit;
              end;
            secfile:=TGCPsecfile.create;
            secfile.ProjectFilename:=FFilename;
            secfile.LoginUsername:=formCredentials.edUsername.text;
            secfile.LoginPassword:=formCredentials.edPassword.text;
            secfile.Load;
            if secfile.CurUserType=utUnknown then
              begin
                ErrorMsg('Invalid username or password');
                exit;
              end
            else if secfile.CurUserType<>utSuperAdmin then
              begin
                ErrorMsg('Only the project manager can edit the project settings');
                exit;
              end
            else
              begin
                editAdminUsername.text:=secfile.MasterUsername;
                editAdminPw1.Text:=secfile.MasterPassword;
                editAdminPw2.Text:=secfile.MasterPassword;
                editProjectDesc.Text:=secfile.ProjectDescription;
                editProjectName.Text:=secfile.ProjectFilename;
                checkEncryptRec.Checked:=secfile.EncryptDataFile;
                checkEncryptChk.Checked:=secfile.EncryptCheckFile;
                if secfile.LogWhere='localfile' then comboLogWhere.ItemIndex:=0
                else if secfile.LogWhere='webservice' then comboLogWhere.itemIndex:=1
                else if secfile.LogWhere='ftp' then comboLogWhere.ItemIndex:=2;
                editLogFilename.text:=secfile.Logfilename;
                checkLogNew.Checked:=secfile.LogNew;
                checkLogEdit.Checked:=secfile.LogEdit;
                checkLogDel.Checked:=secfile.LogDel;
                checkLogRead.Checked:=secfile.LogRead;
                checkLogFind.Checked:=secfile.LogFind;
                for n:=1 to secfile.numUsers do
                  begin
                    sg.Cells[1,n]:=secfile.Users[n].name;
                    sg.Cells[2,n]:=secfile.Users[n].utype;
                    sg.Cells[3,n]:=secfile.Users[n].pw;
                    sg.Cells[4,n]:=secfile.Users[n].note;
                  end;
                if secfile.Datafiles.Count>0 then
                  begin
                    for n:=0 to secfile.Datafiles.Count-1 do
                      evalList.Items.Append(secfile.Datafiles[n]);
                  end;
              end;
          finally
            formCredentials.Free;
          end;
        end;
    end;
end;

end.
