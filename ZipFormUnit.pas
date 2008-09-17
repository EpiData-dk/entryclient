unit ZipFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, FileCtrl, kpZipObj,ShellBrowser,LabelEditUnit;

type
  TZipForm = class(TForm)
    Panel1: TPanel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    PageControl1: TPageControl;
    Zippage: TTabSheet;
    Unzippage: TTabSheet;
    ZipPanel: TPanel;
    ZipGroup: TGroupBox;
    lblDir: TLabel;
    Label2: TLabel;
    edDirToZip: TEdit;
    btnSelDirectory: TBitBtn;
    chkIncludeSub: TCheckBox;
    edZipfilename: TEdit;
    BtnSelZipfilename: TBitBtn;
    EncryptGroup: TGroupBox;
    lblPW1: TLabel;
    lblPW2: TLabel;
    chkEncrypt: TCheckBox;
    edPW1: TEdit;
    edPW2: TEdit;
    radioZipall: TRadioButton;
    radioZipEpiData: TRadioButton;
    Label3: TLabel;
    edUnzipfilename: TEdit;
    btnSelUnzipfilename: TBitBtn;
    OpenDialog: TOpenDialog;
    Label4: TLabel;
    radioZipSingle: TRadioButton;
    chkDecrypt: TCheckBox;
    lblDecryptPW: TLabel;
    edDecryptPW: TEdit;
    chkUnzipFile: TCheckBox;
    lblUnzipTo: TLabel;
    edUnzipDirectory: TEdit;
    btnUnzipTo: TBitBtn;
    chkReplace: TCheckBox;
    procedure chkEncryptClick(Sender: TObject);
    procedure radioZipallClick(Sender: TObject);
    procedure chkDecryptClick(Sender: TObject);
    procedure chkUnzipFileClick(Sender: TObject);
    procedure btnSelDirectoryClick(Sender: TObject);
    procedure BtnSelZipfilenameClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edZipfilenameExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edDirToZipExit(Sender: TObject);
    procedure OnTotalPercentDoneEvent(Sender: TObject; Percent: LongInt);
    procedure OnPromptForOverwriteEvent(Sender: TObject; var OverWriteIt:Boolean; FileIndex:Integer; var FName:String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ZipForm: TZipForm;

Procedure DoZip;
Procedure DoUnZip;
Procedure PerformZip(sourcedir,filename:String; DoEncrypt,AddDate:Boolean; pass:String);

implementation

{$R *.DFM}

uses
  MainUnit,EpiTypes, VCLZip, VCLUnZip, Rijndael, Base64, DCPCrypt, SHA1,ProgressUnit;


VAR
  z: TVCLZip;
  z2: TVclUnZip;
  SkippedList: TStringList;


Procedure PerformZip(sourcedir,filename:String; DoEncrypt,AddDate:Boolean; pass:String);
VAR
  Source, Dest: file;
  Buffer: array[0..8191] of byte;
  Hash: TDCP_sha1;
  HashDigest: array[0..31] of byte;
  Encrypt:   TDCP_Rijndael;
  ReadN,n: integer;
  inputfilename,outputfilename,keyparam,s: string;
  tmpBool: Boolean;
  WindowList:Pointer;
BEGIN
  TRY
    z:=TVclZip.Create(nil);
    z.DoProcessMessages:=True;
    ZipForm:=TZipForm.Create(NIL);
    z.OnTotalPercentDone:=ZipForm.OnTotalPercentDoneEvent;
    TRY
      UserAborts:=False;
      ProgressForm:=TProgressForm.Create(MainForm);
      ProgressForm.Caption:=Lang(9200);   //9200=Create archive
      ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
      ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
      ProgressForm.pBar.Max:=100;
      ProgressForm.pLabel.Caption:=Lang(9200);   //9200=Create archive
      WindowList:=DisableTaskWindows(ProgressForm.Handle);
      ProgressForm.Show;

      s:=trim(sourcedir);
      IF s[Length(s)]<>'\' THEN s:=s+'\';
      IF AddDate THEN z.ZipName:=ChangeFileExt(filename+'_'+formatDateTime('ddmmmyy',Now),'.zip')
      ELSE z.ZipName:=ChangeFileExt(filename,'.zip');
      filename:=z.Zipname;
      if FileExists(z.ZipName) THEN tmpBool:=deletefile(z.ZipName);
      z.FilesList.Append(s+'*.rec');
      z.FilesList.Append(s+'*.qes');
      z.FilesList.Append(s+'*.chk');
      z.FilesList.Append(s+'*.not');
      z.FilesList.Append(s+'*.log');
      z.FilesList.Append(s+'*.inc');
      z.PackLevel:=7;
      z.RelativePaths:=True;
      z.RootDir:=s;
      TRY
        IsZipping:=True;
        n:=z.Zip;
      EXCEPT
        on EUserCanceled do exit;
      else
        BEGIN
          ErrorMsg(Lang(24300));    //'Error during zip operation'
          Exit;
        END;
      END;   //try..except
    FINALLY
      EnableTaskWindows(WindowList);
      ProgressForm.Free;
    END;
  FINALLY
    IsZipping:=False;
    z.Free;
    ZipForm.Free;
  END;  //try..finally
  IF DoEncrypt THEN
    BEGIN
      //Encrypt the zip-file and delete it.
      keyparam:=pass;
      inputfilename:=ChangeFileExt(filename,'.zip');
      outputfilename:=ChangeFileExt(filename,'.zky');
      AssignFile(source,inputFilename);
      TRY
        Reset(source,1);
      EXCEPT
        ErrorMsg(Format(Lang(24302),[InputFilename]));   //Error during encryption:~Cannot open %s
      END;  //try..except
      AssignFile(dest,outputFilename);
      TRY
        Rewrite(dest,1);
      EXCEPT
        CloseFile(source);
        ErrorMsg(Format(Lang(24304),[outputFilename]));   //Error during encryption:~Cannot create %s
      END;  //try..except
      TRY
        TRY
          FillChar(HashDigest,Sizeof(HashDigest),$FF);   // fill the digest with $FF as the actual digest may not fill the entire digest
          Hash:= TDCP_sha1.Create(NIL);
          Hash.Init;
          Hash.UpdateStr(keyparam);           // hash the passphrase to get the key
          Hash.Final(HashDigest);
          Hash.Free;
          Encrypt:= TDCP_Rijndael.create(NIL);
          if (Sizeof(HashDigest)*8)> Encrypt.MaxKeySize then
            Encrypt.Init(HashDigest,Encrypt.MaxKeySize,nil)        // make sure the key isn't too big
          else
            Encrypt.Init(HashDigest,Sizeof(HashDigest)*8,nil);     // initialize the cipher with the digest, IV= nil to generate one automatically (note: size in bits ie. sizeof(x)*8)
          Encrypt.EncryptCBC(HashDigest,HashDigest,Sizeof(HashDigest));  // encrypt the hash and write it to the file to use as passphrase
          Encrypt.Reset;                                                 // confirmation
          BlockWrite(Dest,HashDigest,Sizeof(HashDigest));
          repeat
            BlockRead(Source,Buffer,Sizeof(Buffer),ReadN);
            Encrypt.EncryptCBC(Buffer,Buffer,ReadN);                      // read from the source encrypt and write out the result
            BlockWrite(Dest,Buffer,ReadN);
          until ReadN<> Sizeof(Buffer);
          Encrypt.Burn;
        EXCEPT
          ErrorMsg(Lang(24306));    //Error during encryption.
        END;  //try..except
      FINALLY
        CloseFile(Source);
        CloseFile(Dest);
        tmpBool:=Deletefile(inputFilename);
        Encrypt.Free;
      END;  //try..finally
    END;
  s:=Format(Lang(24308),[sourcedir]);   //Files in %s ~has been archived
  IF DoEncrypt THEN s:=s+' '+Lang(24310)+#13#13+     //' and encrypted.'
  Format(Lang(24312),[ChangeFileExt(filename,'.zky')])    //'Result saved as %s'
  ELSE s:=s+'.'#13#13+Format(Lang(24312),[changeFileExt(filename,'.zip')]);     //'Result saved as %s'
  eDlg(s,mtInformation,[mbOK],0);
END;  //procedure performzip

Procedure DoZip;
VAR
  Source, Dest: file;
  Buffer: array[0..8191] of byte;
  Hash: TDCP_sha1;
  HashDigest: array[0..31] of byte;
  Encrypt:   TDCP_Rijndael;
  ReadN,n: integer;
  inputfilename,outputfilename,keyparam,s: string;
  tmpBool: Boolean;
  WindowList:Pointer;
BEGIN
  TRY
    ZipForm:=TZipForm.Create(NIL);
    ZipForm.PageControl1.ActivePage:=ZipForm.Zippage;
    IF ZipForm.ShowModal<>mrOK THEN Exit;
    TRY
      z:=TVclZip.Create(nil);
      z.DoProcessMessages:=True;
      z.OnTotalPercentDone:=ZipForm.OnTotalPercentDoneEvent;
      TRY
        UserAborts:=False;
        ProgressForm:=TProgressForm.Create(MainForm);
        ProgressForm.Caption:=Lang(9200);   //9200=Create archive
        ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
        ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
        ProgressForm.pBar.Max:=100;
        ProgressForm.pLabel.Caption:=Lang(9200);   //9200=Create archive
        WindowList:=DisableTaskWindows(ProgressForm.Handle);
        ProgressForm.Show;

        s:=trim(ZipForm.edDirToZip.Text);
        IF s[Length(s)]<>'\' THEN s:=s+'\';
        //IF ExtractFileExt(ZipForm.edZipFilename.Text)='.key'
        //THEN z.ZipName:=Copy(ZipForm.edZipfilename.Text,1,Length(ZipForm.edZipfilename.Text)-4)
        //ELSE z.ZipName:=ZipForm.edZipfilename.Text;
        z.ZipName:=ChangeFileExt(ZipForm.edZipfilename.Text,'.zip');
        IF ZipForm.radioZipSingle.checked THEN z.FilesList.Append(ZipForm.edDirToZip.Text)
        ELSE IF ZipForm.radioZipAll.Checked THEN z.FilesList.Append(s+'*.*')
        ELSE
          BEGIN
            z.FilesList.Append(s+'*.rec');
            z.FilesList.Append(s+'*.qes');
            z.FilesList.Append(s+'*.chk');
            z.FilesList.Append(s+'*.not');
            z.FilesList.Append(s+'*.log');
            z.FilesList.Append(s+'*.inc');
          END;
        z.PackLevel:=7;
        IF (ZipForm.radioZipSingle.Checked=FALSE) AND (ZipForm.chkIncludeSub.Checked) THEN
          BEGIN
            z.RelativePaths:=True;
            z.RootDir:=s;
          END;
        TRY
          IsZipping:=True;
          n:=z.Zip;
        EXCEPT
          on EUserCanceled do exit;
        else
          BEGIN
            ErrorMsg(Lang(24300));    //'Error during zip operation'
            Exit;
          END;
        END;   //try..except
      FINALLY
        EnableTaskWindows(WindowList);
        ProgressForm.Free;
      END;
    FINALLY
      IsZipping:=False;
      z.Free;
    END;  //try..finally
    IF ZipForm.chkEncrypt.Checked THEN
      BEGIN
        //Encrypt the zip-file and delete it.
        keyparam:=ZipForm.edPW1.Text;
        inputfilename:=ChangeFileExt(ZipForm.edZipfilename.Text,'.zip');
        outputfilename:=ChangeFileExt(ZipForm.edZipfilename.Text,'.zky');
        //IF ExtractFileExt(inputfilename)<>'.zky' THEN outputfilename:=ChangeFileExt(inputfilename,'.zky')
        //ELSE
        //  BEGIN
        //    outputfilename:=inputfilename;
        //    inputfilename:=copy(inputfilename,1,Length(inputfilename)-4);
        //  END;
        AssignFile(source,inputFilename);
        TRY
          Reset(source,1);
        EXCEPT
          ErrorMsg(Format(Lang(24302),[InputFilename]));   //Error during encryption:~Cannot open %s
        END;  //try..except
        AssignFile(dest,outputFilename);
        TRY
          Rewrite(dest,1);
        EXCEPT
          CloseFile(source);
          ErrorMsg(Format(Lang(24304),[outputFilename]));   //Error during encryption:~Cannot create %s
        END;  //try..except
        TRY
          TRY
            FillChar(HashDigest,Sizeof(HashDigest),$FF);   // fill the digest with $FF as the actual digest may not fill the entire digest
            Hash:= TDCP_sha1.Create(NIL);
            Hash.Init;
            Hash.UpdateStr(keyparam);           // hash the passphrase to get the key
            Hash.Final(HashDigest);
            Hash.Free;
            Encrypt:= TDCP_Rijndael.create(NIL);
            if (Sizeof(HashDigest)*8)> Encrypt.MaxKeySize then
              Encrypt.Init(HashDigest,Encrypt.MaxKeySize,nil)        // make sure the key isn't too big
            else
              Encrypt.Init(HashDigest,Sizeof(HashDigest)*8,nil);     // initialize the cipher with the digest, IV= nil to generate one automatically (note: size in bits ie. sizeof(x)*8)
            Encrypt.EncryptCBC(HashDigest,HashDigest,Sizeof(HashDigest));  // encrypt the hash and write it to the file to use as passphrase
            Encrypt.Reset;                                                 // confirmation
            BlockWrite(Dest,HashDigest,Sizeof(HashDigest));
            repeat
              BlockRead(Source,Buffer,Sizeof(Buffer),ReadN);
              Encrypt.EncryptCBC(Buffer,Buffer,ReadN);                      // read from the source encrypt and write out the result
              BlockWrite(Dest,Buffer,ReadN);
            until ReadN<> Sizeof(Buffer);
            Encrypt.Burn;
          EXCEPT
            ErrorMsg(Lang(24306));    //Error during encryption.
          END;  //try..except
        FINALLY
          CloseFile(Source);
          CloseFile(Dest);
          tmpBool:=Deletefile(inputFilename);
          Encrypt.Free;
        END;  //try..finally
      END;
    s:=Format(Lang(24308),[ZipForm.edDirToZip.Text]);   //Files in %s ~has been archived
    IF ZipForm.chkEncrypt.Checked THEN s:=s+' '+Lang(24310)+#13#13+     //' and encrypted.'
    Format(Lang(24312),[ZipForm.edZipFilename.Text])    //'Result saved as %s'
    ELSE s:=s+'.'#13#13+Format(Lang(24312),[ZipForm.edZipFilename.Text]);     //'Result saved as %s'
    eDlg(s,mtInformation,[mbOK],0);
  FINALLY
    ZipForm.Free;
  END;  //try..finally
END;

Procedure DoUnzip;
VAR
  Source, Dest: file;
  Buffer: array[0..8191] of byte;
  Hash: TDCP_sha1;
  HashDigest, HashRead: array[0..31] of byte;
  Decrypt: TDCP_Rijndael;
  ReadN,n: integer;
  filename,s : string;
  inputfilename,outputfilename,zipfilename,keyparam: string;
  useReplace,tmpBool: Boolean;
  WindowList:Pointer;
BEGIN
  TRY
    ZipForm:=TZipForm.Create(NIL);
    ZipForm.PageControl1.ActivePage:=ZipForm.UnZipPage;
    ZipForm.Caption:=Lang(9202);   //'Unzip/decrypt files';
    IF ZipForm.ShowModal<>mrOK THEN Exit;
    IF (ZipForm.chkDecrypt.Checked=false) AND (ZipForm.chkUnzipFile.Checked=false) THEN Exit;
    InputFilename:=ZipForm.edUnzipFilename.Text;
    IF Assigned(SkippedList) THEN SkippedList.Free;
    SkippedList:=TStringList.Create;
    IF ZipForm.chkDecrypt.Checked THEN
      BEGIN
        //Decrypt file
        keyparam:=ZipForm.edDecryptPW.Text;
        //outputfilename:=copy(inputfilename,1,Length(inputfilename)-4);
        outputfilename:=changeFileExt(inputfilename,'.zip');
        AssignFile(Source,inputfilename);
        TRY
          Reset(Source,1);
        EXCEPT
          ErrorMsg(Format(Lang(22104),[inputfilename]));      //22104=The file %s cannot be opened.
        END;

        AssignFile(Dest,outputfilename);
        TRY
          Rewrite(Dest,1);
        EXCEPT
          CloseFile(Source);
          ErrorMsg(Format(Lang(22348),[outputfilename]));  //22348=A file with the name %s cannot be created.
        END;

        TRY
          TRY
            FillChar(HashDigest,Sizeof(HashDigest),$FF);         // fill the digest with $FF as the actual digest may not fill the entire digest
            Hash:= TDCP_sha1.Create(NIL);
            Hash.Init;                                           // hash the passphrase to get the key
            Hash.UpdateStr(keyparam);
            Hash.Final(HashDigest);
            Hash.Free;
            DEcrypt:= TDCP_Rijndael.create(NIL);
            if (Sizeof(HashDigest)*8)> Decrypt.MaxKeySize then
              Decrypt.Init(HashDigest,Decrypt.MaxKeySize,nil)                    // make sure the key isn't too big
            else
            Decrypt.Init(HashDigest,Sizeof(HashDigest)*8,nil);                   // initialize the cipher with the digest, IV= nil to generate one automatically (note: size in bits ie. sizeof(x)*8)
            Decrypt.EncryptCBC(HashDigest,HashDigest,Sizeof(HashDigest));        // encrypt the hash to use as confirmation
            Decrypt.Reset;
            BlockRead(Source,HashRead,Sizeof(HashRead));                         // read the other hash from the file and compare it
            if not CompareMem(@HashRead,@HashDigest,Sizeof(HashRead)) then
            begin
              tmpBool:=sysutils.DeleteFile(outputfilename);
              Decrypt.Burn;
              ErrorMsg(Lang(9020));   //9020=Incorrect password entered
              Exit;
            end;
            repeat
              BlockRead(Source,Buffer,Sizeof(Buffer),ReadN);
              Decrypt.DecryptCBC(Buffer,Buffer,ReadN);                            // read from the source decrypt and write out the result
              BlockWrite(Dest,Buffer,ReadN);
            until ReadN <> Sizeof(Buffer);
            Decrypt.Burn;
          EXCEPT
            ErrorMsg(Format(Lang(24314),[inputfilename]));    //Error during decryption of %s
          END;
        FINALLY
          CloseFile(Source);
          CloseFile(Dest);
          Decrypt.Free;
        END;
      END;  //if decrypt
    IF ZipForm.chkUnzipFile.Checked THEN
      BEGIN
        //Do an unzip
        IF ZipForm.chkDecrypt.checked THEN zipfilename:=outputfilename ELSE zipfilename:=ZipForm.edUnzipfilename.Text;
        try
          UserAborts:=False;
          ProgressForm:=TProgressForm.Create(MainForm);
          ProgressForm.Caption:=Lang(9202);   //9202=Restore archive
          ProgressForm.Top:=(MainForm.ClientHeight DIV 2)-(ProgressForm.Height DIV 2);
          ProgressForm.Left:=(MainForm.ClientWidth DIV 2)-(ProgressForm.Width DIV 2);
          ProgressForm.pBar.Max:=100;
          ProgressForm.pLabel.Caption:=Lang(9202);   //9202=Restore archive
          WindowList:=DisableTaskWindows(ProgressForm.Handle);
          ProgressForm.Show;

          z2:=TVclUnZip.Create(nil);
          z2.DoProcessMessages:=True;
          z2.OnTotalPercentDone:=ZipForm.OnTotalPercentDoneEvent;
          z2.ZipName:=zipfilename;
          z2.DestDir:=ZipForm.edUnzipDirectory.Text;
          IF ZipForm.chkReplace.Checked
          THEN z2.OverwriteMode:=always
          ELSE
            BEGIN
              z2.OverwriteMode:=prompt;
              z2.OnPromptForOverwrite:=ZipForm.OnPromptForOverwriteEvent;
            END;
          z2.DoAll:=True;
          z2.RecreateDirs:=True;
          z2.ReplaceReadOnly:=True;
          try
            IsZipping:=True;
            n:=z2.UnZip;
          except
            on EUserCanceled do exit;
          else
            BEGIN
              ErrorMsg(Lang(24316));    //Error during unzip operation
              Exit;
            END;
          end;
        finally
          EnableTaskWindows(WindowList);
          ProgressForm.Free;
          IsZipping:=False;;
          z2.Free;
        end;  //try..finally
        IF ZipForm.chkDecrypt.checked THEN tmpBool:=sysutils.DeleteFile(zipfilename);
      END;  //if unzip
    s:=Format(Lang(24318),[inputfilename])+#13;    //%s has been
    IF (ZipForm.chkDecrypt.Checked) AND (ZipForm.chkUnzipFile.Checked) THEN s:=s+Format(Lang(24320),[ZipForm.edUnzipDirectory.Text])  //'decrypted and unzipped to ~%s
    ELSE IF ZipForm.chkDecrypt.Checked THEN s:=s+Format(Lang(24322),[outputfilename])    //decrypted to ~%s
    ELSE IF ZipForm.chkUnzipFile.Checked THEN s:=s+Format(Lang(24324),[ZipForm.edUnzipDirectory.Text]);   //'unzipped to ~%s
    eDlg(s,mtInformation,[mbOK],0);
    IF SkippedList.Count>0 THEN
      BEGIN
        TRY
          s:=Lang(24334)+#13#13;    //'The following files already existed and has not been replaced:'
          FOR n:=0 TO SkippedList.Count-1 DO
            s:=s+SkippedList[n]+#13;
          LabelEditForm:=TLabelEditForm.Create(MainForm);
          LabelEditForm.UseAsEditor:=True;
          LabelEditForm.Caption:=Lang(4900);   //Warning
          LabelEditform.Memo1.Lines.Append(s);
          LabelEditForm.Memo1.ReadOnly:=True;
          LabelEditForm.Memo1.Modified:=False;
          LabelEditForm.Menu:=NIL;
          LabelEditForm.ShowModal;
        FINALLY
          LabelEditForm.Free;
        END;  //try..finally
      END;  //if files were skipped
  FINALLY
    SkippedList.Free;
    ZipForm.Free;
  END;  //try..finally
END;

procedure TZipForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
VAR
  s:String;
begin
  IF ModalResult=mrOK THEN
    BEGIN
      IF PageControl1.ActivePage=UnzipPage THEN
        BEGIN
          IF (NOT FileExists(edUnzipfilename.Text)) THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Format(Lang(22114),[edUnzipfilename.Text]));   //22114='%s' not found
              edUnzipFilename.SetFocus;
              Exit;
            END;
          IF (chkDecrypt.Checked) AND (edDecryptPW.Text='') THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Lang(24326));   //Please enter password for the encrypted file
              edDecryptPW.SetFocus;
              Exit;
            END;
          IF (chkUnzipFile.Checked) AND (NOT DirectoryExists(edUnzipDirectory.Text)) THEN
            BEGIN
              ForceDirectories(edUnzipDirectory.Text);
              IF (NOT DirectoryExists(edUnzipDirectory.Text)) THEN
                BEGIN
                  CanClose:=False;
                  ErrorMsg(Format(Lang(21512),[edUnzipDirectory.Text]));   //21512=Can't create backup directory %s
                  edUnzipDirectory.SetFocus;
                  Exit;
                END;
            END;
        END;  //if unzipping
      IF PageControl1.ActivePage=Zippage THEN
        BEGIN
          IF radioZipSingle.Checked THEN
            BEGIN
              IF (trim(edDirToZip.Text)='') or (NOT FileExists(edDirToZip.Text)) THEN
                BEGIN
                  CanClose:=False;
                  ErrorMsg(Format(Lang(22114),[edDirToZip.Text]));  //22114='%s' not found
                  ZipForm.edDirToZip.SetFocus;
                  Exit;
                END;
            END    //if ZipSingle
          ELSE
            BEGIN
              IF (trim(edDirToZip.Text)='') or (NOT DirectoryExists(edDirToZip.Text)) THEN
                BEGIN
                  CanClose:=False;
                  ErrorMsg(Lang(24328));    //The directory does not exist
                  ZipForm.edDirToZip.SetFocus;
                  Exit;
                END;
            END;  //if not ZipSingle
          IF (trim(edZipfilename.Text)='') THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Lang(24330));   //'Please specify a file name for the archive
              ZipForm.edZipfilename.SetFocus;
              Exit;
            END;

          IF (NOT DirectoryExists(ExtractFileDir(edZipfilename.Text))) THEN
            BEGIN
              CanClose:=False;
              ErrorMsg(Format(Lang(21512),[ExtractFileDir(edZipfilename.Text)]));  //21512=Can't create backup directory %s
              ZipForm.edZipfilename.SetFocus;
              Exit;
            END;
          IF FileExists(edZipfilename.text) THEN
            BEGIN
              s:=edZipfilename.Text;
              IF chkEncrypt.Checked THEN s:=ChangeFileExt(s,'.zky');
              IF eDlg(s+' '+Lang(20446)+#13#13+Lang(20448),mtWarning,[mbYes,mbNo],0)<>mrYes THEN   //20446=already exists.   20448=Overwrite existing file?
                BEGIN
                  CanClose:=False;
                  ZipForm.edZipfilename.SetFocus;
                  Exit;
                END;
            END;
          IF ZipForm.chkEncrypt.Checked THEN
            BEGIN
              ZipForm.edPW1.Text:=trim(ZipForm.edPW1.Text);
              ZipForm.edPW2.Text:=trim(ZipForm.edPW2.Text);
              IF (ZipForm.edPW1.Text='') OR (ZipForm.edPW2.Text='')
              OR (ZipForm.edPW1.Text<>ZipForm.edPW2.Text) THEN
                BEGIN
                  CanClose:=False;
                  ErrorMsg(Lang(24332));    //'Error in password. The same password must be entered twice.
                  ZipForm.edPW1.SetFocus;
                  Exit;
                END;
              IF Length(ZipForm.edPW1.Text)<6 THEN
                BEGIN
                  CanClose:=False;
                  ErrorMsg(Lang(9026));   //'Password must be 6 characters or longer
                  ZipForm.edPW1.SetFocus;
                  Exit;
                END;
            END;  //if encrypt selected
        END;  //if ZipPage
    END;  //if ModalResult
end;


procedure TZipForm.chkEncryptClick(Sender: TObject);
begin
  edPW1.Enabled:=chkEncrypt.Checked;
  edPW2.Enabled:=chkEncrypt.Checked;
  lblPW1.Enabled:=chkEncrypt.Checked;
  lblPW2.Enabled:=chkEncrypt.Checked;
  IF chkEncrypt.Checked THEN
    BEGIN
      //IF (edZipfilename.Text<>'') AND (AnsiLowerCase(ExtractFileExt(edZipfilename.Text))<>'.key')
      //THEN edZipfilename.Text:=edZipfilename.text+'.key';
      IF (edZipfilename.Text<>'') THEN edZipfilename.Text:=ChangefileExt(edZipfilename.Text,'.zky');
      edPW1.SetFocus;
    END
  ELSE
    BEGIN
      //IF (edZipfilename.Text<>'') AND (AnsiLowerCase(ExtractFileExt(edZipfilename.Text))='.key')
      //THEN edZipfilename.Text:=Copy(edZipfilename.Text,1,Length(edZipfilename.Text)-4);
      IF (edZipfilename.Text<>'') THEN edZipfilename.Text:=ChangefileExt(edZipfilename.Text,'.zip');
    END;
end;

procedure TZipForm.radioZipallClick(Sender: TObject);
VAR
  s:String;
begin
  IF sender<>radioZipEpiData THEN radioZipEpiData.Checked:=False;
  IF sender<>radioZipAll THEN radioZipAll.Checked:=False;
  IF sender<>radioZipSingle THEN radioZipsingle.Checked:=False;
  //(Sender AS TRadioButton).Checked:=True;
  chkIncludeSub.Enabled:=NOT (Sender=radioZipSingle);
  IF Sender=radioZipSingle THEN
    BEGIN
      WITH OpenDialog DO
        BEGIN
          Filter:=Lang(2112)+'|*.*';  //2112=All (*.*)
          FilterIndex:=1;
          IF edDirToZip.text<>'' THEN
            BEGIN
              IF ExtractFileExt(edDirToZip.text)='' THEN InitialDir:=edDirToZip.text
              ELSE InitialDir:=ExtractFileDir(edDirToZip.text);
            END;
          IF (InitialDir='') OR (NOT DirectoryExists(InitialDir)) THEN InitialDir:=GetRecentFileDir;
          Options:=[ofPathMustExist,ofFileMustExist,ofEnableSizing];
          IF Execute THEN
            BEGIN
              edDirToZip.Text:=Filename;
              lblDir.Caption:=Lang(3312);   //'File name:'
              s:=ExtractFilename(Filename);
              s:=ChangeFileExt(Filename,'');
              s:=s+'_'+FormatDateTime('dmmmyyyy',now)+'.zip';
              IF chkEncrypt.Checked THEN s:=ChangeFileext(s,'.zky');
              edZipFilename.Text:=s;
            END;  //if execute
        END;  //with
    END  //if
  ELSE
    BEGIN
      IF edDirToZip.Text<>'' THEN
        BEGIN
          IF (edDirtoZip.Text<>'') AND (ExtractFileext(edDirToZip.Text)<>'')
          THEN edDirToZip.Text:=ExtractFileDir(edDirToZip.Text);
        END;
      lblDir.Caption:=Lang(9206);   //Directory:
      edDirToZipExit(Sender);
    END;
end;

procedure TZipForm.chkDecryptClick(Sender: TObject);
begin
  lblDecryptPW.Enabled:=chkDecrypt.Checked;
  edDecryptPW.Enabled:=chkDecrypt.Checked;
  IF chkDecrypt.Checked THEN edDecryptPW.SetFocus;
end;

procedure TZipForm.chkUnzipFileClick(Sender: TObject);
begin
  lblUnzipTo.Enabled:=chkUnzipFile.Checked;
  edUnzipDirectory.Enabled:=chkUnzipFile.Checked;
  btnUnzipTo.Enabled:=chkUnzipFile.Checked;
  chkReplace.Enabled:=chkUnzipFile.Checked;
  IF chkUnzipFile.Checked THEN
    BEGIN
      edUnzipDirectory.SetFocus;
      edUnzipDirectory.Text:='';
    END;
  //ELSE edUnzipDirectory.Text:=copy(edUnzipfilename.text,1,Length(edUnzipfilename.text)-4);
end;

procedure TZipForm.btnSelDirectoryClick(Sender: TObject);
VAR
  dir: String;
begin
  IF Sender=btnSelDirectory THEN dir:=edDirToZip.Text ELSE dir:=edUnzipDirectory.Text;
  IF (dir='') or (NOT DirectoryExists(dir)) THEN dir:=GetRecentFiledir;
  IF (Sender=btnSelDirectory) AND (radioZipSingle.Checked) THEN
    BEGIN
      radioZipallClick(radioZipSingle);
    END
  ELSE
    BEGIN
      //IF selectdirectory(dir,[],0) THEN
      IF BrowseFolder(dir,'Select folder') THEN
        BEGIN
          IF Sender=btnSelDirectory THEN
            BEGIN
              edDirToZip.Text:=dir;
              edDirToZipExit(sender);
            END;
          IF Sender=btnUnzipTo THEN
            BEGIN
              edUnzipDirectory.Text:=dir;
              IF (NOT directoryExists(dir)) THEN ForceDirectories(dir);
            END;
        END;  //if
    END;  //else
end;




procedure TZipForm.BtnSelZipfilenameClick(Sender: TObject);
VAR
  s: String;
begin
  IF Sender=btnSelZipfilename THEN s:=edZipfilename.Text;
  IF Sender=btnSelUnzipfilename THEN s:=edUnzipFilename.Text;
  WITH OpenDialog DO
    BEGIN
      Filter:=Lang(2126)+'|*.zip; *.key; *.zky|'+Lang(2112)+'|*.*';  //2126=Zip files and encrypted files   2112=All (*.*)
      //Filter:='Zip files and encrypted files|*.zip; *.key|All files|*.*';
      FilterIndex:=1;
      DefaultExt:='zip';
      InitialDir:=ExtractFileDir(s);
      IF Sender=btnSelZipfilename THEN Filename:=edZipfilename.text;
      IF (InitialDir='') OR (NOT DirectoryExists(InitialDir)) THEN InitialDir:=GetRecentFileDir;
    END;

  IF Sender=btnSelZipfilename THEN
    BEGIN
      WITH OpenDialog DO
        BEGIN
          Options:=[ofOverwritePrompt,ofHideReadOnly,ofEnableSizing];
          IF Execute THEN
            BEGIN
              edZipFilename.Text:=Filename;
              IF (NOT DirectoryExists(ExtractFileDir(Filename)))
              THEN ForceDirectories(ExtractFileDir(Filename));
            END;
        END;  //with
    END; //if
  IF Sender=btnSelUnzipfilename THEN
    BEGIN
      WITH OpenDialog DO
        BEGIN
          Options:=[ofHideReadOnly,ofPathMustExist,ofFileMustExist,ofEnableSizing];
          IF Execute THEN edUnzipFilename.Text:=Filename;
        END;  //with
    END;  //if
end;

procedure TZipForm.edZipfilenameExit(Sender: TObject);
begin
  IF ExtractFileExt(edZipfilename.text)='' THEN edZipfilename.text:=ChangeFileExt(edZipfilename.text,'.zip');
  edZipfilename.Text:=ExpandFilename(edZipfilename.text);
end;

procedure TZipForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  SkippedList:=NIL;
end;

procedure TZipForm.edDirToZipExit(Sender: TObject);
VAR
  s:String;
begin
  IF trim(edDirToZip.Text)='' THEN Exit;
  IF radioZipSingle.Checked THEN
    BEGIN
      s:=edDirToZip.Text;
      IF ExtractFileExt(s)<>'' THEN s:=ChangeFileExt(s,'');
    END
  ELSE s:=edDirToZip.Text;
  s:=s+'_'+FormatDateTime('dmmmyyyy',now)+'.zip';
  IF chkEncrypt.Checked THEN s:=ChangeFileExt(s,'zky');
  edZipFilename.Text:=s;
end;


procedure TZipForm.OnTotalPercentDoneEvent(Sender: TObject; Percent: LongInt);
BEGIN
  ProgressForm.pBar.Position:=Percent;
  IF UserAborts THEN (Sender As TVCLUnZip).CancelTheOperation;
END;

procedure TZipForm.OnPromptForOverwriteEvent(Sender: TObject; var OverWriteIt:Boolean; FileIndex:Integer; var FName:String);
BEGIN
  //SkippedList.Append(ExtractFilename(FName));
  SkippedList.Append(FName);
END;

end.
