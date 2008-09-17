unit BackUpUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, Buttons, FmxUtils;

type
  TBackupForm = class(TForm)
    DatafileNameEdit: TEdit;
    Label1: TLabel;
    OpenDatafileBtn: TBitBtn;
    Label2: TLabel;
    DistDirEdit: TEdit;
    OpenDistDirBtn: TBitBtn;
    GroupBox1: TGroupBox;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure OpenDatafileBtnClick(Sender: TObject);
    procedure OpenDistDirBtnClick(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure DriveComboBox1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BackupForm: TBackupForm;

Procedure BackUpDataFile;
Procedure BackupCommand(VAR Liste: TStringList);

implementation

uses MainUnit, EPITypes;

{$R *.DFM}

VAR
//  OldDir:String;
  OldDrive:Char;

Procedure BackUpDataFile;
VAR
  opN:Integer;
  DriveLet:Char;
  tmpStr:String;
  FromFilename,ToFilename:TFilename;
  OverWriteAll:Boolean;

  Procedure DoCopy;
  BEGIN
    IF FileExists(FromFilename) THEN
      BEGIN
        IF (FileExists(ToFilename)) AND (NOT OverWriteAll) THEN
          BEGIN
            opN:=eDlg(Format(Lang(21500),   //'A file with name %s allready exists.~~Overwrite existing file?'
              [ToFilename]),mtWarning,[mbYes,mbAll,mbNo],0);
            IF opN=mrAll THEN OverWriteAll:=True;
            IF (opN=mrYes) or (opN=mrAll)
            THEN CopyFile(FromFilename,Tofilename);
          END  //if Tofile exists
        ELSE CopyFile(FromFilename,ToFilename);
      END;  //if FromFile exists
  END;


BEGIN  //procedure BackUpDatafile
  TRY
//    OldDrive:='c';
    OverWriteAll:=False;
    BackupForm:=TBackupForm.Create(MainForm);
    opN:=1;
    WHILE (opN<8) AND
      (AnsiUpperCase(ExtractFileExt(RecentFiles[opN]))<>'.REC') DO INC(opN);
    IF AnsiUpperCase(ExtractFileExt(RecentFiles[opN]))='.REC'
    THEN BackupForm.DataFilenameEdit.Text:=RecentFiles[opN]
    ELSE BackupForm.DataFilenameEdit.Text:='';
    tmpStr:=ExtractFileDrive(BackUpDir);
    DriveLet:=tmpStr[1];
    IF IsDriveReady(DriveLet) THEN
      BEGIN
        BackUpForm.DistDirEdit.Text:=BackUpDir;
        BackUpForm.DirectoryListBox1.Directory:=BackUpDir;
      END
    ELSE
      BEGIN
        BackUpForm.DistDirEdit.Text:='C:\';
        BackUpForm.DirectoryListBox1.Directory:='C:\';
      END;
    BackUpForm.DriveComboBox1.Drive:=BackUpForm.DirectoryListBox1.Drive;
    IF BackUpForm.ShowModal=mrCancel THEN Exit;

    FromFilename:=BackUpForm.DatafilenameEdit.Text;
    //IF FileExists(FromFilename) THEN AddToRecentFiles(FromFilename);
    ToFilename:=BackupForm.DistDirEdit.Text;
    IF ToFilename[Length(ToFilename)]<>'\' THEN ToFilename:=ToFilename+'\';
    BackUpDir:=ToFilename;
    ToFilename:=ToFilename+ExtractFilename(FromFilename);
    {Copy Rec file}
    DoCopy;
    {Copy CHK file}
    FromFilename:=ChangeFileExt(FromFilename,'.chk');
    ToFilename:=ChangeFileExt(ToFilename,'.chk');
    DoCopy;
    {Copy QES file}
    FromFilename:=ChangeFileExt(FromFilename,'.qes');
    ToFilename:=ChangeFileExt(ToFilename,'.qes');
    DoCopy;
    {Copy NOT file}
    FromFilename:=ChangeFileExt(FromFilename,'.not');
    ToFilename:=changeFileExt(Tofilename,'.not');
    DoCopy;

    eDlg(Lang(21502),mtInformation,[mbOK],0);   //'Back-up completed'
  Finally
    BackUpForm.Free;
  END;  //try..finally
END;  //procedure BackupDatafile;


procedure TBackupForm.OpenDatafileBtnClick(Sender: TObject);
begin
  OpenDialog1.Filter:=Lang(2104)+'|*.rec|'+Lang(2112)+'|*.*';  //EpiData Datafile (*.rec)  All (*.*)
  OpenDialog1.FilterIndex:=1;    //set filter to *.rec
  OpenDialog1.Options:=OpenDialog1.Options+[ofFileMustExist];
  IF AnsiUpperCase(ExtractFileExt(DataFilenameEdit.Text))='.REC' THEN
    BEGIN
      OpenDialog1.InitialDir:=ExtractFileDir(DataFilenameEdit.Text);
      OpenDialog1.FileName:=ExtractFileName(DataFilenameEdit.Text);
    END
  ELSE OpenDialog1.Filename:='';
  IF OpenDialog1.Execute THEN
    DataFilenameEdit.Text:=OpenDialog1.Filename;
end;

procedure TBackupForm.OpenDistDirBtnClick(Sender: TObject);
begin
  IF BackUpForm.Height<300 THEN
    BEGIN
      IF BackUpForm.Top-81 < 0 THEN BackUpForm.Top:=5
      ELSE BackUpForm.Top:=BackUpForm.Top-81;
      BackUpForm.Height:=300;
      DirectoryListBox1.Enabled:=True;
      DriveComboBox1.Enabled:=True;
      IF DirectoryExists(DistDirEdit.Text) THEN
        BEGIN
          BackUpForm.DirectoryListBox1.Directory:=DistDirEdit.Text;
          BackUpForm.DriveComboBox1.Drive:=BackUpForm.DirectoryListBox1.Drive;
        END;
    END
  ELSE
    BEGIN
      BackUpForm.Height:=138;
      BackUpForm.Top:=BackUpForm.Top+81;
      DirectoryListBox1.Enabled:=False;
      DriveComboBox1.Enabled:=False;
    END;
end;

procedure TBackupForm.DirectoryListBox1Change(Sender: TObject);
begin
  DistDirEdit.Text:=DirectoryListBox1.Directory;
end;

procedure TBackupForm.DriveComboBox1Change(Sender: TObject);
VAR
  CancelSelected:Boolean;
begin
  IF NOT IsDriveReady(DriveComboBox1.Drive) THEN
    BEGIN
      CancelSelected:=False;
      REPEAT
        IF eDlg(Format(Lang(21504),[UpCase(DriveComboBox1.Drive)]),   //'Drive %s: is not ready'
          mtError,[mbRetry,mbCancel],0)=mrCancel THEN CancelSelected:=True;
      UNTIL (CancelSelected) OR (IsDriveReady(DriveComboBox1.Drive));
      IF CancelSelected THEN DriveComboBox1.Drive:=OldDrive
      ELSE OldDrive:=DriveComboBox1.Drive;
    END
  ELSE OldDrive:=DriveComboBox1.Drive;
  DirectoryListBox1.Drive:=DriveComboBox1.Drive;
end;

procedure TBackupForm.FormCloseQuery(Sender: TObject;var CanClose: Boolean);
VAR
  DistDrive,DatafileDrive:Char;
  tmpS:String[2];
begin
  {
  Check for
  - No datafile
  - Non-existing datafile
  - No backup path
  - Non-existing path
  - Drive not ready in datafile or path
  }
  IF ModalResult=mrOK THEN
    BEGIN
      CanClose:=True;
      tmpS:=ExtractFileDrive(DatafilenameEdit.Text);
      IF tmpS<>'' THEN DatafileDrive:=tmpS[1] ELSE DatafileDrive:=#20;
      tmpS:=ExtractFileDrive(DistDirEdit.Text);
      IF tmpS<>'' THEN DistDrive:=tmpS[1] ELSE DistDrive:=#20;
      IF (trim(DatafilenameEdit.Text)='')
      OR (AnsiUpperCase(ExtractFileExt(DatafilenameEdit.Text))<>'.REC') THEN
        BEGIN
          eDlg(Lang(21506),mtError,[mbOK],0);  //'Please specify a datafile to backup.'
          CanClose:=False;
        END;
      IF (CanClose) AND (DatafileDrive<>#20)
      AND (NOT IsDriveReady(DatafileDrive)) THEN
        BEGIN
          eDlg(Format(Lang(21504),[AnsiUpperCase(DatafilenameEdit.Text[1])]),mtError,[mbOK],0);  //Drive %s: is not ready
          CanClose:=False;
        END;
      IF (CanClose) AND (NOT FileExists(DatafilenameEdit.Text)) THEN
        BEGIN
          eDlg(Format(Lang(20110),[DatafilenameEdit.Text]),mtError,[mbOK],0);  //Datafile %s does not exist.
          CanClose:=False;
        END;
      IF (CanClose) AND (trim(DistDirEdit.Text)='') THEN
        BEGIN
          eDlg(Lang(21508),mtError,[mbOK],0);  //'Please specify a distination directory.'
          CanClose:=False;
        END;
      IF (CanClose) AND (DistDrive<>#20) AND (NOT IsDriveReady(DistDrive)) THEN
        BEGIN
          eDlg(Format(Lang(21504),[AnsiUpperCase(DistDirEdit.Text[1])]),mtError,[mbOK],0);  //Drive %s: is not ready
          CanClose:=False;
        END;
      IF (CanClose) AND (NOT DirectoryExists(DistDirEdit.Text)) THEN
        BEGIN
          eDlg(Lang(21510),mtError,[mbOK],0);  //'Distination directory does not exist.'
          CanClose:=False;
        END;
    END;
end;

procedure TBackupForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
end;

Procedure BackupCommand(VAR Liste: TStringList);
VAR
  n:Integer;
  s,FraFil,TilFil: String;
  backuppath,relpath,pathmainfile,pathsubfile: String;
BEGIN
  IF NOT DirectoryExists(Liste[0]) THEN
    BEGIN
      {$I-}
      ForceDirectories(Liste[0]);
      n:=IOResult;
      {$I+}
      IF n<>0 THEN
        BEGIN
          ErrorMsg(Format(Lang(21512),[Liste[0]]));  //'Can't create backup directory %s'
          Exit;
        END;
    END;
  backuppath:=Liste[0];
  IF backuppath[length(backuppath)]<>'\' THEN backuppath:=backuppath+'\';
  pathmainfile:=backuppath+extractfilename(Liste[1]);
  TRY
    eDlg(Format(Lang(21514),[Liste[1],Liste[0]]),mtInformation,[mbOK],0);  //'Starting backup of %s to %s'
    FOR n:=1 TO Liste.Count-1 DO
      BEGIN
        //s:=Liste[0];
        //IF s[Length(s)]<>'\' THEN s:=s+'\';
        relpath:=ExtractFilePath(ExtractRelativePath(Liste[1],Liste[n]));
        IF (pos('..',relpath)>0) or (pos(':',relpath)>0) then relpath:='';
        pathsubfile:=backuppath+relpath+ExtractFilename(Liste[n]);
        IF NOT DirectoryExists(backuppath+relpath) THEN ForceDirectories(backuppath+relpath);
        FraFil:=Liste[n];
        TilFil:=pathsubfile;
        IF FileExists(FraFil) THEN CopyFile(FraFil,TilFil);
        IF FileExists(ChangefileExt(FraFil,'.chk')) THEN CopyFile(changeFileExt(FraFil,'.chk'),ChangeFileExt(TilFil,'.chk'));
        IF FileExists(ChangefileExt(FraFil,'.qes')) THEN CopyFile(changeFileExt(FraFil,'.qes'),ChangeFileExt(TilFil,'.qes'));
        IF FileExists(ChangefileExt(FraFil,'.not')) THEN CopyFile(changeFileExt(FraFil,'.not'),ChangeFileExt(TilFil,'.not'));
      END;  //for n
    eDlg(Format(Lang(21502),[Liste[1],Liste[0]]),mtInformation,[mbOK],0);  //'Backup completed
  EXCEPT
    ErrorMsg(Format(Lang(21516),[Liste[1]])+#13#13+Lang(21520));  //'Error in backup of %s'   21520=Backup not completed
  END;
END;


end.
