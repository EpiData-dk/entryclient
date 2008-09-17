{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: VCLUnZip.pas                                                      }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, boylank@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }
unit VCLUnZip;

{$P-}                                                   { turn off open parameters }
{$R-}                                                   { 3/10/98 2.03 }
{$Q-}                                                   { 3/10/98 2.03 }
{$B-} { turn off complete boolean eval }                { 12/24/98  2.17 }

{$I KPDEFS.INC}

interface

uses
   {$IFDEF WIN32}
   Windows,
   {$ELSE}
   WinTypes, WinProcs,
   {$ENDIF}
   SysUtils, Classes,
   {$IFDEF KPSMALL}
   kpSmall,
   {$ELSE}
   Controls, Forms, Dialogs, FileCtrl,
   {$ENDIF}
   kpCntn, kpMatch, KpLib, kpZipObj{$IFNDEF NO_RES}, kpzcnst{$ENDIF};


const
   kpThisVersion         = 222; {added this constant 3/1/98 for version 2.03}

   {$IFDEF WIN32}
   DEF_BUFSTREAMSIZE      = 8192;   { Changed back to 8192 7/20/01  2.21+ }
   {$ELSE}                          { Larger values can cause memory problems }
   DEF_BUFSTREAMSIZE      = 8192;   { Changed back to 8192 7/20/01  2.21+ }
   {$ENDIF}

type

   TMultiMode = (mmNone, mmSpan, mmBlocks);
   TIncompleteZipMode = (izAssumeMulti, izAssumeBad, izAssumeNotAZip);
   TUZOverwriteMode = (Prompt, Always, Never, ifNewer, ifOlder);  { added ifNewer,ifOlder 8/2/98  2.14 }
   TSkipReason = (srBadPassword, srNoOverwrite, srFileOpenError, srCreateError);

   {Decryption}

   DecryptKey = array[0..2] of LongInt;
   DecryptHeaderPtr = ^DecryptHeaderType;
   DecryptHeaderType = array[0..11] of BYTE;

   { Exceptions }
   EBadZipFile = class(Exception);
   EFileNotAllThere = class(Exception);
   EIncompleteZip = class(Exception);
   ENotAZipFile = class(Exception);
   EFatalUnzipError = class(Exception);
   EUserCanceled = class(Exception);
   EInvalidPassword = class(Exception);
   EBiggerThanUncompressed = class(Exception);          { 4/16/98 2.11 }
   ENotEnoughRoom = class(Exception);
   ECantWriteUCF = class(Exception);

   { Event types }

   TStartUnzipInfo = procedure(Sender: TObject; NumFiles: Integer;
      TotalBytes: Comp; var StopNow: Boolean) of object;
   TStartUnZipEvent = procedure(Sender: TObject; FileIndex: Integer;
      var FName: string; var Skip: Boolean) of object;
   TEndUnZipEvent = procedure(Sender: TObject; FileIndex: Integer; FName: string) of object;
   TFilePercentDone = procedure(Sender: TObject; Percent: LongInt) of object;
   TTotalPercentDone = procedure(Sender: TObject; Percent: LongInt) of object;
   TPromptForOverwrite = procedure(Sender: TObject; var OverWriteIt: Boolean;
      FileIndex: Integer; var FName: string) of object;
   TSkippingFile = procedure(Sender: TObject; Reason: TSkipReason; FName: string;
      FileIndex: Integer; var Retry: Boolean) of object;
   TBadPassword = procedure(Sender: TObject; FileIndex: Integer; var NewPassword: string) of
      object;
   TBadCRC = procedure(Sender: TObject; CalcCRC, StoredCRC: LongInt;
      FileIndex: Integer) of object;
   TIncompleteZip = procedure(Sender: TObject; var IncompleteMode: TIncompleteZipMode) of
      object;
   TGetNextDisk = procedure(Sender: TObject; NextDisk: Integer; var FName: string) of object;
   TUnZipComplete = procedure(sender: TObject; FileCount: Integer) of object;
   TGetNextBuffer = procedure(Sender: TObject; var Buffer: PChar; FName: string; AmountUsed:
      LongInt;
      BufferNum: Integer; var Quit: Boolean) of object;

   {$IFNDEF WIN32}
   DWORD = LongInt;
   {$ENDIF}

   TVCLUnZip = class(TComponent)
   PRIVATE
      { Private declarations }
      FZipName: string;
      FDestDir: string;
      FSortMode: TZipSortMode;
      FReCreateDir: Boolean;
      FOverwriteMode: TUZOverwriteMode;
      FFilesList: TStrings;
      FDoAll: Boolean;
      FPassword: string;
      FIncompleteZipMode: TIncompleteZipMode;
      FKeepZipOpen: Boolean;
      FDoProcessMessages: Boolean;
      FNumDisks: Integer;
      FRetainAttributes: Boolean;
      FThisVersion: Integer;
      FReplaceReadOnly: Boolean;
      FNumSelected: Integer;
      FBufferLength: LongInt;                           { 8/23/99  2.18+ }
      FImproperZip: Boolean;                            { 2/19/00  2.20+ }

      { Event variables }
      FOnStartUnzipInfo: TStartUnzipInfo;
      FOnStartUnZip: TStartUnZipEvent;
      FOnEndUnZip: TEndUnZipEvent;
      FOnPromptForOverwrite: TPromptForOverwrite;
      FOnBadPassword: TBadPassword;
      FOnBadCRC: TBadCRC;
      FOnInCompleteZip: TInCompleteZip;
      FOnUnzipComplete: TUnZipComplete;
      FOnGetNextBuffer: TGetNextBuffer;

      function ProcessIntegrityCheck(Index: Integer): Boolean; { 8/15/99 2.18+ }

      { Decrypt }
   PROTECTED
      FOnFilePercentDone: TFilePercentDone;
      FOnTotalPercentDone: TTotalPercentDone;
      FOnSkippingFile: TSkippingFile;
      FOnGetNextDisk: TGetNextDisk;
      FArchiveStream: TStream;
      FBusy: Boolean;
      FRootDir: string;
      FTestMode: Boolean;                               { 12/3/98  2.17P+ }
      FFlushFilesOnClose: Boolean;                      { 10/11/99 2.18+ }
      FBufferedStreamSize: Integer;                    { 05/13/00 2.20+ }
      ArchiveIsStream: Boolean;
      FCheckDiskLabels: Boolean;
      FMultiMode: TMultiMode;
      file_info: TZipHeaderInfo;
      files: TSortedZip;
      sortfiles: TSortedZip;
      filesDate: TDateTime;
      ZipIsBad: Boolean;
      CurrentDisk: Integer;
      theZipFile: TStream;
      Crc32Val: U_LONG;
      lrec: local_file_header;
      crec: central_file_header;
      ecrec: TEndCentral;
      ZipCommentPos: LongInt;
      UnZippingSelected: Boolean;                       { 6/27/99 2.18+ }

      tmpMStr: string;
      Key: DecryptKey;
      CancelOperation: Boolean;
      ZipStream: TStream;
      StreamZipping: Boolean;
      MemZipping: Boolean;
      MemBuffer: PChar;
      MemLen: LongInt;
      MemLeft: LongInt;
      CurrMem: PChar;
      Fixing: Boolean;
      DR: Boolean;

      TotalUncompressedSize: Comp;
      TotalBytesDone: Comp;

      procedure OpenZip;
      procedure CloseZip;
      function GetCount: Integer;
      procedure GetFileInfo(infofile: TStream);
      function GetZipName: string;
      procedure SetZipName(ZName: string); VIRTUAL;
      procedure SetArchiveStream(theStream: TStream);
      function GetDestDir: string;
      procedure SetDestDir(DDir: string);
      procedure SetRootDir(Value: string);
      function UnZipFiles(zip_in_file: TStream): Integer;
      function UpdCRC(Octet: Byte; Crc: U_LONG): U_LONG;
      function SwapDisk(NewDisk: Integer): TStream;
      procedure SetFileComment(Index: Integer; theComment: string);
      procedure SetZipComment(theComment: string);
      procedure WriteNumDisks(NumberOfDisks: Integer);
      procedure NewDiskEvent(Sender: TObject; var S: TStream);
      procedure SetThisVersion(v: Integer);
      function GetCheckDiskLabels: Boolean; VIRTUAL;
      procedure SetCheckDiskLabels(Value: Boolean); VIRTUAL;

      { GetMultiMode and SetMultiMode added 3/10/98 for 2.03}
      function GetMultiMode: TMultiMode; VIRTUAL;
      procedure SetMultiMode(Value: TMultiMode); VIRTUAL;

      { List functions }
      procedure SetFilesList(Value: TStrings);
      function GetFilename(Index: Integer): TZipFilename;
      function GetPathname(Index: Integer): TZipPathname;
      function GetFullname(Index: Integer): string;
      function GetCompressMethod(Index: Integer): WORD;
      function GetCompressMethodStr(Index: Integer): string;
      function GetDateTime(Index: Integer): TDateTime;
      function GetCrc(Index: Integer): U_LONG;
      function GetCompressedSize(Index: Integer): LongInt;
      function GetUnCompressedSize(Index: Integer): LongInt;
      function GetExternalFileAttributes(Index: Integer): U_LONG;
      function GetIsEncrypted(Index: Integer): Boolean;
      function GetHasComment(Index: Integer): Boolean;
      function GetFileComment(Index: Integer): string;
      function GetFileIsOK(Index: Integer): Boolean;    { 12/3/98  2.17P+ }
      function GetDiskNo(Index: Integer): Integer;
      function GetSelected(Index: Integer): Boolean;    {6/27/99 2.18+ }
      procedure SetSelected(Index: Integer; Value: Boolean);
      {$IFDEF ISDELPHI}
      function GetDecryptHeader(Index: Integer): DecryptHeaderType;
      {$ENDIF}
      function GetZipHasComment: Boolean;
      function GetZipComment: string;
      function GetZipSize: LongInt;

      {Decryption}
      function DecryptTheHeader(Passwrd: string; zfile: TStream): BYTE;
      procedure update_keys(ch: char);
      function decrypt_byte: BYTE;
      procedure Init_Keys(Passwrd: string);
      procedure decrypt_buff(bufptr: BYTEPTR; num_to_decrypt: LongInt);
      procedure Update_CRC_buff(bufptr: BYTEPTR; num_to_update: LongInt);

      procedure DefaultGetNextDisk(Sender: TObject; NextDisk: Integer; var FName: string);

      procedure Loaded; OVERRIDE;

   PUBLIC
      { Public declarations }
      constructor Create(AOwner: TComponent); OVERRIDE;
      destructor Destroy; OVERRIDE;
      procedure Assign(Source: TPersistent); OVERRIDE;  { 6/27/99 2.18+ }
      procedure ReadZip;
      function UnZip: Integer;
      function UnZipSelected: Integer;
      procedure ClearSelected;
      procedure ClearZip;
      procedure FillList(FilesList: TStrings);
      procedure Sort(SMode: TZipSortMode);
      procedure CancelTheOperation;
      procedure AskForNewDisk(NewDisk: Integer);
      function UnZipToStream(theStream: TStream; FName: string): Integer;
      function UnZipToStreamByIndex(theStream: TStream; Index: Integer): Integer;
      function UnZipToBuffer(var Buffer: PChar; FName: string): Integer;
      function UnZipToBufferByIndex(var Buffer: PChar; Index: Integer): Integer;
      procedure ResetFileIsOK(Index: Integer);
      function CheckArchive: Boolean;
      function DecryptHeaderByte(Passwrd: string; dh: DecryptHeaderType): BYTE;
      { The following two are for BCB because of difficulties passing the DecryptHeaderType }
      procedure GetDecryptHeaderPtr(Index: Integer; dhPtr: BytePtr); { 8/8/99  2.18+ }
      function DecryptHeaderByteByPtr(Passwrd: string; dh: BytePtr): Byte; { 8/8/99  2.18+ }
      { -------- }
      property ArchiveStream: TStream READ theZipFile WRITE SetArchiveStream;
      property Count: Integer READ GetCount;
      property Filename[Index: Integer]: TZipFilename READ GetFilename;
      property Pathname[Index: Integer]: TZipPathname READ GetPathname;
      property FullName[Index: Integer]: string READ GetFullName;
      property CompressMethod[Index: Integer]: WORD READ GetCompressMethod;
      property CompressMethodStr[Index: Integer]: string READ GetCompressMethodStr;
      property DateTime[Index: Integer]: TDateTime READ GetDateTime;
      property Crc[Index: Integer]: U_LONG READ GetCrc;
      property CompressedSize[Index: Integer]: LongInt READ GetCompressedSize;
      property UnCompressedSize[Index: Integer]: LongInt READ GetUnCompressedSize;
      property ExternalFileAttributes[Index: Integer]: U_LONG READ GetExternalFileAttributes;
      property IsEncrypted[Index: Integer]: Boolean READ GetIsEncrypted;
      property FileHasComment[Index: Integer]: Boolean READ GetHasComment;
      property FileComment[Index: Integer]: string READ GetFileComment;
      property FileIsOK[Index: Integer]: Boolean READ GetFileIsOK; { 12/3/98 2.17P+ }
      property DiskNo[Index: Integer]: Integer READ GetDiskNo;
      property Selected[Index: Integer]: Boolean READ GetSelected WRITE SetSelected;  { 6/27/99 2.18+ }
      property ZipComment: string READ GetZipComment;
      property Password: string READ FPassword WRITE FPassword;
      property ZipHasComment: Boolean READ GetZipHasComment;
      property NumDisks: Integer READ FNumDisks;
      property ZipSize: LongInt READ GetZipSize;
      property CheckDiskLabels: Boolean READ GetCheckDiskLabels WRITE SetCheckDiskLabels DEFAULT
         True;
      property MultiMode: TMultiMode READ GetMultiMode WRITE SetMultiMode DEFAULT mmNone;
      property Busy: Boolean READ FBusy DEFAULT False;
      {$IFDEF ISDELPHI}
      property DecryptHeader[Index: Integer]: DecryptHeaderType READ GetDecryptHeader;
      {$ENDIF}
      property NumSelected: Integer READ FNumSelected;
      property BufferLength: LongInt READ FBufferLength WRITE FBufferLength DEFAULT 0;
      property ImproperZip: Boolean READ FImproperZip DEFAULT False;  { 2/19/00  2.20+ }
      property BufferedStreamSize: Integer READ FBufferedStreamSize
                 WRITE FBufferedStreamSize DEFAULT DEF_BUFSTREAMSIZE;

   PUBLISHED
      { Published declarations }
      property ThisVersion: Integer READ FThisVersion WRITE SetThisVersion DEFAULT
         kpThisVersion;
      property ZipName: string READ GetZipName WRITE SetZipName;
      property DestDir: string READ GetDestDir WRITE SetDestDir;
      property RootDir: string READ FRootDir WRITE SetRootDir;
      property SortMode: TZipSortMode READ FSortMode WRITE FSortMode DEFAULT ByNone;
      property RecreateDirs: Boolean READ FRecreateDir WRITE FRecreateDir DEFAULT False;
      property OverwriteMode: TUZOverwriteMode READ FOverwriteMode
         WRITE FOverwriteMode DEFAULT Prompt;
      property FilesList: TStrings READ FFilesList WRITE SetFilesList;
      property DoAll: Boolean READ FDoAll WRITE FDoAll DEFAULT False;
      property IncompleteZipMode: TIncompleteZipMode READ FIncompleteZipMode
         WRITE FIncompleteZipMode DEFAULT izAssumeMulti;
      property KeepZipOpen: Boolean READ FKeepZipOpen WRITE FKeepZipOpen DEFAULT False;
      property DoProcessMessages: Boolean READ FDoProcessMessages WRITE FDoProcessMessages
         DEFAULT True;
      property RetainAttributes: Boolean READ FRetainAttributes WRITE FRetainAttributes DEFAULT
         True;
      property ReplaceReadOnly: Boolean READ FReplaceReadOnly WRITE FReplaceReadOnly DEFAULT
         False;
      property FlushFilesOnClose: Boolean READ FFlushFilesOnClose WRITE FFlushFilesOnClose
         DEFAULT False;
      { Event Properties }
      property OnStartUnZipInfo: TStartUnzipInfo READ FOnStartUnzipInfo
         WRITE FOnStartUnzipInfo;
      property OnFilePercentDone: TFilePercentDone READ FOnFilePercentDone
         WRITE FOnFilePercentDone;
      property OnTotalPercentDone: TTotalPercentDone READ FOnTotalPercentDone
         WRITE FOnTotalPercentDone;
      property OnStartUnZip: TStartUnZipEvent READ FOnStartUnZip WRITE FOnStartUnZip;
      property OnEndUnZip: TEndUnZipEvent READ FOnEndUnZip WRITE FOnEndUnZip;
      property OnPromptForOverwrite: TPromptForOverwrite READ FOnPromptForOverwrite
         WRITE FOnPromptForOverwrite;
      property OnSkippingFile: TSkippingFile READ FOnSkippingFile WRITE FOnSkippingFile;
      property OnBadPassword: TBadPassword READ FOnBadPassword WRITE FOnBadPassword;
      property OnBadCRC: TBadCRC READ FOnBadCRC WRITE FOnBadCRC;
      property OnInCompleteZip: TInCompleteZip READ FOnInCompleteZip WRITE FOnInCompleteZip;
      property OnGetNextDisk: TGetNextDisk READ FOnGetNextDisk WRITE FOnGetNextDisk;
      property OnUnZipComplete: TUnZipComplete READ FOnUnZipComplete WRITE FOnUnZipComplete;
      property OnGetNextBuffer: TGetNextBuffer READ FOnGetNextBuffer WRITE FOnGetNextBuffer;
   end;

   {$IFNDEF KPSMALL}
var
   OpenZipDlg            : TOpenDialog;
   {$ENDIF}

{$IFNDEF FULLPACK}
procedure Register;
{$ENDIF}
{$IFDEF KPDEMO}
function DelphiIsRunning: Boolean;
{$ENDIF}

implementation
{$I kpUnzipp.Pas}

{******************************************************************}

constructor TVCLUnZip.Create(AOwner: TComponent);
{$IFDEF KPDEMO}
{$IFNDEF NO_RES}
var
   tmpMstr2              : string;
   {$ENDIF}
   {$ENDIF}
begin
   inherited Create(AOwner);
   FSortMode := ByNone;
   FDoAll := False;
   RecreateDirs := False;
   FFilesList := TStringList.Create;
   file_info := TZipHeaderInfo.Create;
   Password := '';
   ZipIsBad := False;
   theZipFile := nil;
   files := nil;
   sortfiles := nil;
   FIncompleteZipMode := izAssumeMulti;
   ecrec := TEndCentral.Create;
   CancelOperation := False;
   FKeepZipOpen := False;
   FDoProcessMessages := True;
   FCheckDiskLabels := True;
   StreamZipping := False;
   MemZipping := False;
   MemBuffer := nil;
   MemLen := 0;
   ArchiveIsStream := False;
   Fixing := False;
   FNumDisks := 1;
   CurrentDisk := 0;
   FRetainAttributes := True;
   FBusy := False;
   FTestMode := False;
   FThisVersion := kpThisVersion;
   FReplaceReadOnly := False;                           { 03/09/99  2.17+ }
   FNumSelected := 0;
   FBufferLength := 0;
   FImproperZip := False;
   FBufferedStreamSize := DEF_BUFSTREAMSIZE;
   if not (csDesigning in ComponentState) then          { added this line 03/09/99 2.17+ }
      FOnGetNextDisk := DefaultGetNextDisk;
   {$IFDEF KPDEMO}
   if not (csDesigning in ComponentState) then
   begin
      DR := DelphiIsRunning;
      if not DelphiIsRunning then
      begin
         {$IFDEF NO_RES}
         MessageBox(0,
            'This unregistered verion of VCLZip will only run while the Delphi IDE is running',
            'Warning', mb_OK);
         {$ELSE}
         tmpMStr := LoadStr(IDS_NOTREGISTERED);
         tmpMStr2 := LoadStr(IDS_WARNING);
         MessageBox(0, StringAsPChar(tmpMStr), StringAsPChar(tmpMStr2), mb_OK);
         {$ENDIF}
         Abort;
      end;
   end;
   {$ENDIF}
end;

destructor TVCLUnZip.Destroy;
begin
   ClearZip;
   if (file_info <> nil) then
      file_info.Free;
   if (ecrec <> nil) then
      ecrec.Free;
   { Moved folowing down two lines 7/10/98  2.13 }
   { Due to a user's reporting that it stopped him from getting "Invalid Pointer Operation"
   { errors.  I was unable to duplicate the problem but the move is safe enough  }
   if (FFilesList <> nil) then
      FFilesList.Free;
   inherited Destroy;
end;

procedure TVCLUnZip.Loaded;
begin
   inherited Loaded;
   FThisVersion := kpThisVersion; { Moved here from constructor 4/22/98 2.11 }
end;

procedure TVCLUnZip.Assign(Source: TPersistent);        { 6/27/99 2.18+ }
begin
   if source is TVCLUnZip then
   begin
      FZipName := TVCLUnZip(Source).GetZipName;
      FDestDir := TVCLUnZip(Source).GetDestDir;
      FRootDir := TVCLUnZip(Source).FRootDir;
      FSortMode := TVCLUnZip(Source).SortMode;
      FRecreateDir := TVCLUnZip(Source).RecreateDirs;
      FOverwriteMode := TVCLUnZip(Source).OverwriteMode;
      FFilesList.Assign(TVCLUnZip(Source).FilesList);
      FDoAll := TVCLUnZip(Source).DoAll;
      FIncompleteZipMode := TVCLUnZip(Source).IncompleteZipMode;
      FKeepZipOpen := TVCLUnZip(Source).KeepZipOpen;
      FDoProcessMessages := TVCLUnZip(Source).DoProcessMessages;
      FRetainAttributes := TVCLUnZip(Source).RetainAttributes;
      FReplaceReadOnly := TVCLUnZip(Source).ReplaceReadOnly;

      FOnStartUnZipInfo := TVCLUnZip(Source).OnStartUnzipInfo;
      FOnFilePercentDone := TVCLUnZip(Source).OnFilePercentDone;
      FOnTotalPercentDone := TVCLUnZip(Source).OnTotalPercentDone;
      FOnStartUnZip := TVCLUnZip(Source).OnStartUnZip;
      FOnEndUnZip := TVCLUnZip(Source).OnEndUnZip;
      FOnPromptForOverwrite := TVCLUnZip(Source).OnPromptForOverwrite;
      FOnSkippingFile := TVCLUnZip(Source).OnSkippingFile;
      FOnBadPassword := TVCLUnZip(Source).OnBadPassword;
      FOnBadCRC := TVCLUnZip(Source).OnBadCRC;
      FOnInCompleteZip := TVCLUnZip(Source).OnInCompleteZip;
      FOnGetNextDisk := TVCLUnZip(Source).OnGetNextDisk;
      FOnUnzipComplete := TVCLUnzip(Source).OnUnZipComplete;
      FOnGetNextBuffer := TVCLUnzip(Source).OnGetNextBuffer;
   end
   else
      inherited Assign(Source);
end;

procedure TVCLUnZip.SetZipName(ZName: string);
var
   tempZipName           : string;
   Canceled              : Boolean;
begin
   if (csDesigning in ComponentState) then
   begin                                                { 4/20/98 2.11 }
      FZipName := ZName;
      exit;
   end;
   if AnsiCompareText(ZName, FZipName) = 0 then
      exit;
   Canceled := False;
   {$IFNDEF KPSMALL}
   if (ZName <> '') and (ZName[Length(ZName)] = '?') then
   begin
      OpenZipDlg := TOpenDialog.Create(Application);
      try
         {$IFDEF NO_RES}
         OpenZipDlg.Title := 'Open a Zip File';
         OpenZipDlg.Filter := 'Zip Files (*.ZIP)|*.zip|SFX Files (*.EXE)|*.exe|' +
            'Jar Files (*.JAR)|*.jar|All Files (*.*)|*.*';
         {$ELSE}
         OpenZipDlg.Title := LoadStr(IDS_OPENZIP);
         OpenZipDlg.Filter := LoadStr(IDS_ZIPNAMEFILTER);
         {$ENDIF}
         if DirExists(ExtractFilePath(ZName)) then
            OpenZipDlg.InitialDir := ExtractFilePath(ZName)
         else
            OpenZipDlg.InitialDir := 'C:\';
         if OpenZipDlg.Execute then
            tempZipName := OpenZipDlg.Filename
         else
            Canceled := True;
      finally
         OpenZipDlg.Free;
      end;
   end
   else
      {$ENDIF}
      tempZipName := ZName;

   if not Canceled then
   begin
      FZipName := tempZipName;
      if (sortfiles <> nil) and (FSortMode <> ByNone) then
         sortfiles.Free;
      sortfiles := nil;
      files.Free;
      files := nil;
      filesDate := 0;
      ecrec.Clear;
      theZipFile.Free;
      theZipFile := nil;
      ZipIsBad := False;
      ArchiveIsStream := False;
   end
   else
      {$IFDEF NO_RES}
      raise EUserCanceled.Create('User canceled setting zip file name.');
   {$ELSE}
      raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPNAME));
   {$ENDIF}
end;

function TVCLUnZip.GetZipName: string;
begin
   Result := FZipName;
end;

procedure TVCLUnZip.SetArchiveStream(theStream: TStream);
begin
   if theStream = nil then
      theZipFile := nil;
   ClearZip;
   theZipFile := theStream;
   if theZipFile <> nil then
   begin
      FKeepZipOpen := True;
      ArchiveIsStream := True;
   end
   else
      ArchiveIsStream := False;
end;

procedure TVCLUnZip.SetDestDir(DDir: string);
{$IFNDEF KPSMALL}
var
   theDir                : string;
   {$ENDIF}
begin
   {$IFNDEF KPSMALL}
   if DDir = '?' then
   begin
      theDir := FDestDir;
      if not DirExists(theDir + '\') then
         GetDirectory(0, theDir);
      {$IFNDEF WIN32}
      {$IFNDEF NOLONGNAMES}
      if OSVersion > 3 then
         theDir := LFN_ConvertLFName(theDir, SHORTEN);
      {$ENDIF}
      {$ENDIF}
      if SelectDirectory(theDir, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
         FDestDir := theDir
      else
         {$IFDEF NO_RES}
         raise EUserCanceled.Create('User canceled Set Desination Directory');
      {$ELSE}
         raise EUserCanceled.Create(LoadStr(IDS_CANCELDESTDIR));
      {$ENDIF}
   end
   else
      {$ENDIF}
      FDestDir := DDir;

   if (FDestDir <> '') and (FDestDir[Length(FDestDir)] = '\') then { Remove slash }
      SetLength(FDestDir, Length(FDestDir) - 1);
end;

function TVCLUnZip.GetDestDir: string;
begin
   Result := FDestDir;
end;

procedure TVCLUnZip.SetRootDir(Value: string);
begin
   if Length(Value) > 0 then
   begin
      if RightStr(Value, 1) <> '\' then
         FRootDir := Value + '\'
      else
         FRootDir := Value;
   end
   else
      FRootDir := '';
end;

procedure TVCLUnZip.SetFilesList(Value: TStrings);
begin
   FFilesList.Assign(Value);
end;

{ List Properties }

function TVCLUnZip.GetFilename(Index: Integer): TZipFilename;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.filename;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetPathname(Index: Integer): TZipPathname;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Directory;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetFullname(Index: Integer): string;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Directory + finfo.filename;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetCompressMethod(Index: Integer): WORD;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.compression_method;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetCompressMethodStr(Index: Integer): string;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := comp_method[finfo.compression_method];
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetDateTime(Index: Integer): TDateTime;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      try
         Result := FileDateToDateTime(finfo.last_mod_file_date_time)
      except
         Result := Now;
      end;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetCrc(Index: Integer): U_LONG;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Crc32;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetCompressedSize(Index: Integer): LongInt;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.compressed_size;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetUnCompressedSize(Index: Integer): LongInt;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.uncompressed_size;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetExternalFileAttributes(Index: Integer): U_LONG;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.external_file_attributes;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetIsEncrypted(Index: Integer): Boolean;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Encrypted;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetHasComment(Index: Integer): Boolean;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.HasComment;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetZipHasComment: Boolean;
begin
   Result := ecrec.zip_comment_length > 0;
end;

function TVCLUnZip.GetFileComment(Index: Integer): string;
var
   finfo                 : TZipHeaderInfo;
   crec                  : central_file_header;
   CommentLength         : LongInt;
   RememberModified      : Boolean;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      with finfo do
      begin
         if HasComment then
         begin
            if finfo.filecomment = nil then
            try
               OpenZip;
               theZipFile.Seek(central_offset, soFromBeginning);
               theZipFile.Read(crec, SizeOf(central_file_header));
               with crec do
               begin
                  theZipFile.Seek(filename_length + extra_field_length, soFromCurrent);
                  {$IFDEF WIN32}
                  CommentLength := file_comment_length;
                  {$ELSE}
                  CommentLength := kpmin(file_comment_length, 255);
                  {$ENDIF}
                  SetLength(Result, CommentLength);
                  theZipFile.Read(Result[1], CommentLength);
                  RememberModified := ecrec.Modified;
                  SetFileComment(Index, Result);        { Save it in central header }
                  ecrec.Modified := RememberModified;
               end;
            finally
               If (MultiMode = mmNone) then
                 CloseZip;
            end
            else
               Result := StrPas(finfo.filecomment);
         end
         else
            Result := '';                               { No comment }
      end;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

procedure TVCLUnZip.ResetFileIsOK(Index: Integer);
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      finfo.FileIsOK := icUNDEFINED;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.CheckArchive: Boolean;
var
   tmpDoAll              : Boolean;
begin
   tmpDoAll := DoAll;
   DoAll := True;
   Result := ProcessIntegrityCheck(-1);
   DoAll := tmpDoAll;
end;

function TVCLUnZip.GetFileIsOK(Index: Integer): Boolean;
var
   tmpDoAll              : Boolean;
begin
   tmpDoAll := DoAll;
   DoAll := False;
   Result := ProcessIntegrityCheck(Index);
   DoAll := tmpDoAll;
end;

function TVCLUnZip.ProcessIntegrityCheck(Index: Integer): Boolean;
var
   n, r                  : Integer;
   s                     : PChar;
   saveRecreateDirs      : Boolean;
   saveDestDir           : string;
   finfo                 : TZipHeaderInfo;
begin
   r := icUNDEFINED;
   finfo := nil;
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      r := finfo.FileIsOK;
   end
   else
      if (Index <> -1) then
         {$IFDEF NO_RES}
         raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
         raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}

   if (Index <> -1) and (r = icFILEOK) then
      Result := True
   else
      if (Index <> -1) and (r = icFILEBAD) then
         Result := False
      else                                              { r = icUNDEFINED }
      begin
         FTestMode := True;
         saveRecreateDirs := RecreateDirs;
         saveDestDir := DestDir;
         Result := False;
         if (Index <> -1) then
            finfo.FileIsOK := icFILEBAD;
         try
            RecreateDirs := True;
            DestDir := ''; { changed from 'c:\TestZip\' 2/14/99 2.17+ }
            s := PChar(1);                              { Just to be sure it's not nil }
            n := UnzipToBufferByIndex(s, Index);        { Dummy Buffer }
            if (n > 0) then
            begin
               Result := True;
               if (Index <> -1) then
                  finfo.FileIsOK := icFILEOK
               else
               begin
                  if DoAll then
                  begin
                     if (n < Count) then
                        Result := False;
                  end
                  else
                     if (n <> FNumSelected) then
                        Result := False;
               end;
            end;
         finally
            FTestMode := False;
            RecreateDirs := saveRecreateDirs;
            DestDir := saveDestDir;
         end;
      end;
end;

function TVCLUnZip.GetZipComment: string;
var
   CommentLength         : LongInt;
   RememberModified      : Boolean;
begin
   if ecrec.zip_comment_length = 0 then
      Result := ''
   else
      with ecrec do
      begin
         if ecrec.ZipComment = nil then
         begin
            OpenZip;
            try
               theZipFile.Seek(ZipCommentPos, soFromBeginning);
               {$IFDEF WIN32}
               CommentLength := zip_comment_length;
               {$ELSE}
               CommentLength := kpmin(zip_comment_length, 255);
               {$ENDIF}
               SetLength(Result, CommentLength);
               theZipFile.Read(Result[1], CommentLength);
               RememberModified := Modified;
               SetZipComment(Result);                   { Save it in ecrec }
               Modified := RememberModified;
            finally
               If (MultiMode = mmNone) then
                 CloseZip;
            end;
         end
         else
            Result := PCharToStr(ecrec.ZipComment);
      end;
end;

procedure TVCLUnZip.SetZipComment(theComment: string);
begin
   if ((ecrec.ZipComment = nil) and (theComment <> '')) or
      (StrComp(ecrec.ZipComment, StringAsPChar(theComment)) <> 0) then
   begin
      ecrec.SetNewZipComment(theComment);
      ecrec.Modified := True;
   end;
end;

procedure TVCLUnZip.SetFileComment(Index: Integer; theComment: string);
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      if ((finfo.filecomment = nil) and (theComment <> '')) or
         (StrComp(finfo.filecomment, StringAsPChar(theComment)) <> 0) then
      begin
         if finfo.filecomment <> nil then
            finfo.filecomment := nil;
         if theComment = '' then
            finfo.filecomment := nil
         else
         begin
            { Changed StrToPChar to StringAsPChar  7/16/98  2.14 }
            finfo.filecomment := StringAsPChar(theComment);
         end;
         ecrec.Modified := True;
      end;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

{ 3/10/98  2.03}
{ These are overriden in VCLZip }

function TVCLUnZip.GetMultiMode: TMultiMode;
begin
   Result := FMultiMode;
end;

{ 3/10/98  2.03}

procedure TVCLUnZip.SetMultiMode(Value: TMultiMode);
begin
   FMultiMode := Value;
end;

function TVCLUnZip.GetDiskNo(Index: Integer): Integer;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.disk_number_start + 1;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

function TVCLUnZip.GetSelected(Index: Integer): Boolean;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Selected;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

procedure TVCLUnZip.SetSelected(Index: Integer; Value: Boolean);
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      if (finfo.Selected <> Value) then
      begin
         finfo.Selected := Value;
         if (Value = True) then
            Inc(FNumSelected)
         else
            Dec(FNumSelected);
      end;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
end;

procedure TVCLUnZip.GetDecryptHeaderPtr(Index: Integer; dhPtr: BytePtr);
var
   dhTemp                : DecryptHeaderType;
   i                     : Integer;
   {$IFNDEF ISDELPHI}
   finfo                 : TZipHeaderInfo;
   lrec                  : local_file_header;
   {$ENDIF}
begin
   if (Index < 0) or (Index >= Count) then
   begin
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
      {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
      {$ENDIF}
      exit;
   end;
   if (not IsEncrypted[Index]) then
   begin
      for i := 0 to 11 do
      begin
         dhPtr^ := 0;
         Inc(dhPtr);
      end;
      exit;
   end;
   {$IFDEF ISDELPHI}
   dhTemp := GetDecryptHeader(Index);
   for i := 0 to 11 do
   begin
      dhPtr^ := dhTemp[i];
      Inc(dhPtr);
   end;
   {$ELSE}
   finfo := sortfiles.Items[Index] as TZipHeaderInfo;
   with finfo do
   begin
      try
         OpenZip;
         theZipFile.Seek(relative_offset, soFromBeginning);
         theZipFile.Read(lrec, SizeOf(local_file_header));
         with lrec do
         begin
            theZipFile.Seek(filename_length, soFromCurrent);
            theZipFile.Read(dhTemp, SizeOf(DecryptHeaderType));
         end;
         for i := 0 to 11 do                            { added this loop 10/23/99  2.20b3+ }
         begin
            dhPtr^ := dhTemp[i];
            Inc(dhPtr);
         end;
      finally
        If (MultiMode = mmNone) then
           CloseZip;
      end;
   end;
   {$ENDIF}
end;

{$IFDEF ISDELPHI}

function TVCLUnZip.GetDecryptHeader(Index: Integer): DecryptHeaderType;
var
   finfo                 : TZipHeaderInfo;
   lrec                  : local_file_header;
   i                     : Integer;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
   end
   else
      {$IFDEF NO_RES}
      raise EListError.CreateFmt('Index %d is out of range', [Index]);
   {$ELSE}
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   {$ENDIF}
   if (IsEncrypted[Index]) then
      with finfo do
      begin
         try
            OpenZip;
            theZipFile.Seek(relative_offset, soFromBeginning);
            theZipFile.Read(lrec, SizeOf(local_file_header));
            with lrec do
            begin
               theZipFile.Seek(filename_length, soFromCurrent);
               theZipFile.Read(Result, SizeOf(DecryptHeaderType));
            end;
         finally
           If (MultiMode = mmNone) then
              CloseZip;
         end
      end
   else
      for i := 0 to 11 do
         Result[i] := 0;
end;
{$ENDIF}

function TVCLUnZip.GetZipSize: LongInt;
begin
   Result := 0;
   if FZipName <> '' then
   begin
      OpenZip;
      try
         Result := theZipFile.Size;
      finally
        If (MultiMode = mmNone) then
           CloseZip;
      end;
   end;
end;

procedure TVCLUnZip.WriteNumDisks(NumberOfDisks: Integer);
begin
   FNumDisks := NumberOfDisks;
end;

{ Added these so that they could be overriden in VCLZip 3/11/98  2.03 }

function TVCLUnZip.GetCheckDiskLabels: Boolean;
begin
   Result := FCheckDiskLabels;
end;

procedure TVCLUnZip.SetCheckDiskLabels(Value: Boolean);
begin
   FCheckDiskLabels := Value;
end;

function TVCLUnZip.UnZip: Integer;
begin
   FBusy := True;
   CancelOperation := False;
   Result := 0;
   try
      if DestDir <> '?' then
      begin
         { Following Changed from OpenZip which was being bypassed. 03/15/01  2.21+ }
         ReadZip;
         OpenZip;  { Make sure it's open because ReadZip closes it again }
         Result := UnzipFiles(theZipFile);
         CloseZip;
      end;
   finally
      FBusy := False;
      CancelOperation := False;
   end;
end;

function TVCLUnZip.UnZipSelected: Integer;
begin
   UnZippingSelected := True;
   Result := UnZip;
   UnZippingSelected := False;
end;

procedure TVCLUnZip.ClearSelected;
var
   i                     : Integer;
begin
   for i := 0 to Count - 1 do
      Selected[i] := False;
   FNumSelected := 0;
end;

function TVCLUnZip.UnZipToStream(theStream: TStream; FName: string): Integer;
begin
   Result := 0;
   if (Trim(FName) = '') or (theStream = nil) then
      exit;
   FBusy := True;
   ZipStream := theStream;
   CancelOperation := False;
   StreamZipping := True;
   OpenZip;
   FilesList.Clear;
   FilesList.Add(FName);
   try
      Result := UnzipFiles(theZipFile);
   finally
      StreamZipping := False;
      CloseZip;
      FBusy := False;
      CancelOperation := False;
   end;
end;

function TVCLUnZip.UnZipToStreamByIndex(theStream: TStream; Index: Integer): Integer;
begin
   Result := 0;
   if (theStream = nil) then
      exit;
   FBusy := True;
   ZipStream := theStream;
   CancelOperation := False;
   StreamZipping := True;
   OpenZip;
   FilesList.Clear;
   try
      Selected[Index] := True;
      UnZippingSelected := True;
      Result := UnzipFiles(theZipFile);
   finally
      StreamZipping := False;
      CloseZip;
      FBusy := False;
      CancelOperation := False;
      UnZippingSelected := False;
   end;
end;

function TVCLUnZip.UnZipToBuffer(var Buffer: PChar; FName: string): Integer;
begin
   Result := 0;
   if (Trim(FName) = '') then
      exit;
   FBusy := True;
   MemZipping := True;
   OpenZip;                                             { 12/4/98  2.17P+ }
   FilesList.Clear;
   FilesList.Add(FName);
   if (Buffer = nil) then
      MemBuffer := nil
   else
      MemBuffer := Buffer;
   try
      Result := UnzipFiles(theZipFile);
      if (Buffer = nil) then
         Buffer := MemBuffer;
   finally
      MemZipping := False;
      CloseZip;
      FBusy := False;
      CancelOperation := False;
      MemBuffer := nil;
   end;
end;

function TVCLUnZip.UnZipToBufferByIndex(var Buffer: PChar; Index: Integer): Integer;
begin
   FBusy := True;
   MemZipping := True;
   OpenZip;                                             { 12/4/98  2.17P+ }
   FilesList.Clear;
   if (Buffer = nil) then
      MemBuffer := nil
   else
      MemBuffer := Buffer;
   try
      if Index > -1 then
         Selected[Index] := True;
      if not DoAll then
         UnZippingSelected := True;
      Result := UnzipFiles(theZipFile);
      if (Buffer = nil) then
         Buffer := MemBuffer;
   finally
      MemZipping := False;
      CloseZip;
      FBusy := False;
      CancelOperation := False;
      MemBuffer := nil;
      UnZippingSelected := False;
   end;
end;

procedure TVCLUnZip.OpenZip;
{$IFDEF KPDEMO}
{$IFNDEF NO_RES}
var
   tmpMStr2              : string;
   {$ENDIF}
   {$ENDIF}
begin
   {$IFDEF KPDEMO}
   if not (csDesigning in ComponentState) then
   begin
      if not DelphiIsRunning then
      begin
         {$IFDEF NO_RES}
         MessageBox(0,
            'This unregistered verion of VCLZip will only run while the Delphi IDE is running',
            'Warning', mb_OK);
         {$ELSE}
         tmpMStr := LoadStr(IDS_NOTREGISTERED);
         tmpMStr2 := LoadStr(IDS_WARNING);
         MessageBox(0, StringAsPChar(tmpMStr), StringAsPChar(tmpMStr2), mb_OK);
         {$ENDIF}
         Abort;
      end;
   end;
   {$ENDIF}
   if theZipFile = nil then
      theZipFile := TLFNFileStream.CreateFile(FZipName, fmOpenRead or fmShareDenyWrite,
         FFlushFilesOnClose, BufferedStreamSize);
   if files = nil then
      GetFileInfo(theZipFile)
   else
      if (not ArchiveIsStream) and
         (FileDateToDateTime(FileGetDate(TLFNFileStream(theZipFile).Handle)) <> filesDate) then
         GetFileInfo(theZipFile);
end;

procedure TVCLUnZip.CloseZip;
begin
   if not FKeepZipOpen then
   begin
      theZipFile.Free;
      theZipFile := nil;
   end;
end;

procedure TVCLUnZip.AskForNewDisk(NewDisk: Integer);
begin
   SwapDisk(NewDisk);
end;

function TVCLUnZip.SwapDisk(NewDisk: Integer): TStream;
{ NewDisk is the disk number that the user sees. Starts with 1 }
var
   tmpZipName            : string;

   function CurrentDiskLabel(NewDisk: Integer): Boolean;
   var
      VolName            : string[11];
      Disk               : string;
   begin
      {Need to check disk label here}
      if MultiMode = mmSpan then
      begin
         Disk := UpperCase(LeftStr(FZipName, 3));
         VolName := GetVolumeLabel(Disk);
         if RightStr(VolName, 3) = Format('%3.3d', [NewDisk]) then
            Result := True
         else
            Result := False;
      end
      else
         Result := True;
   end;

begin
   theZipFile.Free;
   theZipFile := nil; {1/27/98 to avoid GPF when Freeing file in CloseZip. v2.00+}
   tmpZipName := FZipName;
   repeat
      repeat
         FOnGetNextDisk(Self, NewDisk, tmpZipName);
      until (not CheckDiskLabels) or (tmpZipName = '') or (CurrentDiskLabel(NewDisk));
      if tmpZipName = '' then
         raise EUserCanceled.Create('User canceled loading new disk.');
   until FileExists(tmpZipName); {1/29/98 To avoid problem if file doesn't exist}
   theZipFile := TLFNFileStream.CreateFile(tmpZipName, fmOpenRead, False, BufferedStreamSize);
   CurrentDisk := NewDisk - 1;                          { CurrentDisk starts with 0 }
   filesDate := FileDateToDateTime(FileGetDate(TLFNFileStream(theZipFile).Handle));
   FZipName := tmpZipName;
   Result := theZipFile;
end;

procedure TVCLUnZip.NewDiskEvent(Sender: TObject; var S: TStream);
begin
   SwapDisk(CurrentDisk + 2);
   S := theZipFile;
end;

procedure TVCLUnZip.ClearZip;
var
   SaveKeepZipOpen       : Boolean;
begin
   SaveKeepZipOpen := FKeepZipOpen;
   FKeepZipOpen := False;
   CloseZip;
   FKeepZipOpen := SaveKeepZipOpen;
   if (sortfiles <> nil) and (sortfiles <> files) then
      sortfiles.Free;
   files.Free;
   files := nil;
   sortfiles := nil;
   ecrec.Clear;
   ZipIsBad := False;
   filesDate := 0;
   FNumDisks := 1;
   MultiMode := mmNone;
   if not ArchiveIsStream then
      FZipName := '';
end;

procedure TVCLUnZip.ReadZip;
var
   TryAgain              : Boolean;
   RememberKeepZipOpen   : Boolean;
begin
   CancelOperation := False;
   FImproperZip := False;
   repeat
      {$IFNDEF KPSMALL}
      Screen.Cursor := crHourGlass;
      {$ENDIF}
      TryAgain := False;
      try
         OpenZip;
      except
         on EIncompleteZip do
         begin
            {$IFNDEF KPSMALL}
            Screen.Cursor := crDefault;
            {$ENDIF}
            { zip file must be closed in this case  1/25/00 2.20+  }
            RememberKeepZipOpen := KeepZipOpen;
            KeepZipOpen := False;
            CloseZip;
            KeepZipOpen := RememberKeepZipOpen;
            if Assigned(FOnIncompleteZip) then
               tryagain := True;
         end;
      else
         begin
            ClearZip;
            {$IFNDEF KPSMALL}
            Screen.Cursor := crDefault;
            {$ENDIF}
            raise; { raise the exception so the application knows }
         end;
      end;
   until (TryAgain = False);
   CloseZip;
   {$IFNDEF KPSMALL}
   Screen.Cursor := crDefault;
   {$ENDIF}
end;

procedure TVCLUnZip.GetFileInfo(infoFile: TStream);
var
   finfo                 : TZipHeaderInfo;

   function ReadZipHardWay: Boolean;
   var
      sig                : Byte;
      AmtRead            : LongInt;
      CancelCheck        : LongInt;
      VerNeeded          : WORD;
   begin
      Result := False;
      if ZipIsBad then  { We've already called this procedure }
        exit;
      ZipIsBad := True;
      FImproperZip := True;
      CancelCheck := 0;
      if files <> nil then
      begin
         files.Free;
         files := nil;
      end;
      { 4/19/98  2.11  skip past any sigs in code if sfx }
      if (AnsiCompareText(ExtractFileExt(FZipName), '.EXE') = 0) then
         infoFile.Seek(14000, soFromBeginning)
      else
         infoFile.Seek(0, soFromBeginning);
      AmtRead := infoFile.Read(sig, SizeOf(sig));
      repeat
         repeat
            repeat
               repeat
                  while (AmtRead = SizeOf(sig)) and (sig <> LOC4) do
                  begin
                     Inc(CancelCheck);
                     if (DoProcessMessages) and (CancelCheck mod 10240 = 0) then
                     begin
                        {$IFNDEF KPSMALL}
                        Application.ProcessMessages;
                        {$ELSE}
                        YieldProcess;
                        {$ENDIF}
                        if CancelOperation then
                        begin
                           CancelOperation := False;
                           {$IFDEF NO_RES}
                           raise EUserCanceled.Create('User Aborted Operation');
                           {$ELSE}
                           raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
                           {$ENDIF}
                        end;
                     end;
                     AmtRead := infoFile.Read(sig, SizeOf(sig));
                  end;
                  if AmtRead <> SizeOf(sig) then
                     Result := False
                  else
                     AmtRead := infoFile.Read(sig, SizeOf(sig));
               until (AmtRead <> SizeOf(sig)) or (sig = LOC3);
               AmtRead := infoFile.Read(sig, SizeOf(sig));
            until (AmtRead <> SizeOf(sig)) or (sig = LOC2);
            AmtRead := infoFile.Read(sig, SizeOf(sig));
         until (AmtRead <> SizeOf(sig)) or (sig = LOC1);
         AmtRead := infoFile.Read(VerNeeded, SizeOf(VerNeeded));  { Make sure not a sig in SFX Code }
      until (AmtRead <> SizeOf(VerNeeded)) or (HIBYTE(VerNeeded) < 10);
      if (AmtRead <> SizeOf(VerNeeded)) or (HIBYTE(VerNeeded) > 10) then
         exit;
      infoFile.Seek(-6, soFromCurrent);
      files := TSortedZip.Create(DupError);
      files.SortMode := ByNone;                         { Force for later compare }
      sortfiles := files;                               { added 3/10/98 2.03 }
      finfo.Free;
      finfo := TZipHeaderInfo.Create;
      while finfo.ReadLocalFromStream(infoFile) do
      begin
         files.AddObject(finfo);
         if finfo.HasDescriptor then
            infoFile.Seek(finfo.compressed_size + finfo.Lextra_field_length +
               SizeOf(DataDescriptorType), soFromCurrent)
         else
            infoFile.Seek(finfo.compressed_size + finfo.Lextra_field_length, soFromCurrent);
         finfo := TZipHeaderInfo.Create;
      end;
      finfo.Free;
      finfo := nil;

      ecrec.this_disk := 0;
      CurrentDisk := 0;
      ecrec.offset_central := infoFile.Seek(0, soFromCurrent); {assume}
      ecrec.num_entries := Count;

      FNumDisks := ecrec.this_disk + 1;

      Result := True;
   end;

   procedure GetDescriptorInfo;
   var
      savepos            : LongInt;
      lrecord            : local_file_header;
      drecord            : DataDescriptorType;
   begin
      with finfo do
      begin
         savepos := infoFile.Seek(0, soFromCurrent);
         infoFile.Seek(relative_offset, soFromBeginning);
         infoFile.Read(lrecord, SizeOf(lrecord));
         infoFile.Seek(lrecord.filename_length + lrecord.compressed_size +
            lrecord.extra_field_length, soFromCurrent);
         infoFile.Read(drecord, SizeOf(drecord));
         infoFile.Seek(savepos, soFromBeginning);
      end;
   end;

var
   tmpfinfo, rem_info    : TZipHeaderInfo;
   i                     : Integer;
   Index                 : Integer;
   {sig                   : U_LONG;}
   saveOffset            : LongInt;
   RootPath              : string;
   tmpStream             : TStream;
   recOK                 : Boolean;
   InfoFromInfoFile      : Boolean;
   rem_efl               : Word;       {1/15/00 2.20+}
   CommentLength         : LongInt;    {2/7/00 2.20+}
   zcomment              : String;     {2/7/00 2.20+}
   trys                  : Integer;
   {$IFNDEF WIN32}
   Disk                  : Integer;
   {$ENDIF}
begin
   tmpStream := nil;
   rem_info := nil;
   InfoFromInfoFile := False;
   if (not ArchiveIsStream) then
      filesDate := FileDateToDateTime(FileGetDate(TLFNFileStream(infoFile).Handle))
   else
      filesDate := Now;
   if Count > 0 then
   begin
      if (sortfiles <> nil) and (FSortMode <> ByNone) then
      begin
         sortfiles.Free;
         sortfiles := nil;
      end;
      files.Free;
      files := nil;
   end;

   recOK := ecrec.ReadFromStream(infoFile);
   if (not recOK) then
   begin
      if (not ArchiveIsStream) and (FileExists(ChangeFileExt(ZipName, '.zfc'))) then
      begin
         tmpStream := infoFile;
         infoFile := TFileStream.Create(ChangeFileExt(ZipName, '.zfc'), fmOpenRead);
         recOK := ecrec.ReadFromStream(infoFile);
         if recOK then
            InfoFromInfoFile := True
         else
         begin
            infoFile.Free;
            infoFile := tmpStream;
         end;
      end;
   end;

   if (not recOK) then { False = couldn't find the end central directory }
   begin
      if not Fixing then
      begin
         if (Assigned(FOnIncompleteZip)) then
            FOnIncompleteZip(Self, FIncompleteZipMode);
         if (FIncompleteZipMode = izAssumeNotAZip) then
         {$IFDEF NO_RES}
            raise ENotAZipFile.Create('Not a valid zip file!');
         {$ELSE}
            raise ENotAZipFile.Create(LoadStr(IDS_INVALIDZIP));
         {$ENDIF}
         if (FIncompleteZipMode = izAssumeMulti) then
         begin { Just return and let them try again with the right disk }
            {$IFDEF NO_RES}
            raise EIncompleteZip.Create('Incomplete Zip File');
            {$ELSE}
            raise EIncompleteZip.Create(LoadStr(IDS_INCOMPLETEZIP));
            {$ENDIF}
         end;
      end;
      if ((FIncompleteZipMode = izAssumeBad) or (Fixing)) then
      begin
         if not ReadZipHardWay then { False = there's no central directories }
         begin
            {$IFNDEF KPSMALL}
            Screen.Cursor := crDefault;
            {$ENDIF}
            ClearZip;
            {$IFDEF NO_RES}
            raise EBadZipFile.Create('Not a valid zip file!');
            {$ELSE}
            raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
            {$ENDIF}
         end;
      end;
   end
   else
   begin                                                { ************* }
      CurrentDisk := ecrec.this_disk;
      if InfoFromInfoFile then
         CurrentDisk := 0;
      if ecrec.this_disk > 0 then
      begin
         RootPath := UpperCase(LeftStr(FZipName, 3));
         {$IFNDEF WIN32}
         Disk := Ord(RootPath[1]) - 65;                 { -65 for 16bit GetDriveType }
         {$ENDIF}
         if RootPath[2] <> ':' then
            MultiMode := mmBlocks
               {$IFDEF WIN32}
         else
            if (GetDriveType(StringAsPChar(RootPath)) = DRIVE_REMOVABLE) then
               {$ELSE}
         else
            if (GetDriveType(Disk) = DRIVE_REMOVABLE) then
               {$ENDIF}
               MultiMode := mmSpan
            else
               MultiMode := mmBlocks;
      end
      else
         MultiMode := mmNone;
      { Moved the following down lower 3/10/98  2.03 }
      {     if (ecrec.this_disk > 0) and (ecrec.ZipHasComment) then
         GetZipComment;  }
      { added check for MultiMode <> mmNone because of IMPLODED files that have this_disk = 0 but
      start_central_disk = 1   8/17/98 2.15 }
      if ecrec.num_entries > 0 then
      begin
         if ((not InfoFromInfoFile) and (MultiMode <> mmNone) and (ecrec.start_central_disk <>
            CurrentDisk)) then
            infoFile := SwapDisk(ecrec.start_central_disk + 1);
         if (InfoFromInfoFile) then
            infoFile.Seek(0, soFromBeginning)
         else
            infoFile.Seek(ecrec.offset_central, soFromBeginning);
{$IFDEF SKIPCODE}
         infoFile.Read(sig, SizeOf(sig));
         if sig <> CENTSIG then
         begin
            { The following added 11/17/99  2.20b5+ }
            if (Assigned(FOnIncompleteZip)) then
               FOnIncompleteZip(Self, FIncompleteZipMode);
            if ((FIncompleteZipMode = izAssumeBad) or (Fixing)) then
            begin
               if not ReadZipHardWay then
               begin
                  ClearZip;
                  {$IFDEF NO_RES}
                  raise EBadZipFile.Create('Not a valid zip file!');
                  {$ELSE}
                  raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
                  {$ENDIF}
               end;
            end
            else
            begin
               {$IFDEF NO_RES}
               raise EBadZipFile.Create('Not a valid zip file!');
               {$ELSE}
               raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
               {$ENDIF}
            end;
            {--------------------------  end of mod 11/17/99 2.20b5+}
         end
         else
            infoFile.Seek(-4, soFromCurrent);
{$ENDIF}
      end;
   end;                                                 { ************* }

   if (Count = 0) then                                  { added test 02/14/99  2.17+ }
   begin
      files := TSortedZip.Create(DupError);
      files.SortMode := ByNone;
      sortfiles := files;                               { added 3/10/98 2.03 }
   end;

   rem_efl := 0;  { Code to handle extra_field_len with no extra field  1/12/00 2.20+ }
   i := 0;
   while i < ecrec.num_entries do  {for i := 0 to ecrec.num_entries - 1 do}
   begin
      finfo := TZipHeaderInfo.Create;
      trys := 0;
      Repeat
        if (ZipIsBad) or (MultiMode = mmNone) then
           recOK := finfo.ReadCentralFromStream(infoFile, nil)
        else
           recOK := finfo.ReadCentralFromStream(infoFile, NewDiskEvent);
        Inc(trys);
        if (not recOK) and (trys = 1) and (rem_efl > 0) then
        begin
           if rem_info <> nil then
              rem_info.Cextra_field_length := 0;
           infoFile.Seek(-rem_efl, soFromCurrent);
           rem_info := nil;
        end;
      Until (recOK) or (trys = 2) or (rem_efl = 0);

      rem_efl := 0;
      if not recOK then
      begin
         if ZipIsBad then  { We've already called ReadZipHardWay }
          begin            { Must not be complete set of centrals }
           finfo.Free;
           finfo := nil;
           break;          { break from while loop }
          end;
         { The following added 11/17/99  2.20b5+ }
{$IFDEF SKIPCODE}   { 2/19/00  2.20+ }
         if (Assigned(FOnIncompleteZip)) then
            FOnIncompleteZip(Self, FIncompleteZipMode);
         if ((FIncompleteZipMode = izAssumeBad) or (Fixing)) then
         begin
{$ENDIF}
{ Since we are past looking for the end of central, we know we have a zip file.
  We'll go ahead and try to ReadZipHardWay and set the new flag property called
  ImproperZip so that it is known that something isn't quite kosher - since no
  call to IncompleteZip is made now.  A spanned zip set will always fail a call
  to ReadZipHardWay.  }
            if (MultiMode <> mmNone) or (not ReadZipHardWay) then
            begin
               finfo.Free;
               finfo := nil;
               ClearZip;
               {$IFDEF NO_RES}
               raise EBadZipFile.Create('Not a valid zip file!');
               {$ELSE}
               raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
               {$ENDIF}
            end
           else
            begin
              i := 0;    {calling ReadZipHardWay brings us back to 1st central again}
              continue;  {try reading centrals again}
            end;
{$IFDEF SKIPCODE}    { 2/19/00 2.20+ }
         end
         else
         begin
            {$IFDEF NO_RES}
            raise EBadZipFile.Create('Not a valid zip file!');
            {$ELSE}
            raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
            {$ENDIF}
         end;
{$ENDIF}
         {--------------------------  end of mod 11/17/99 2.20b5+}
      end;
      if ZipIsBad then
      begin
         if (files.Search(Pointer(finfo), Index)) then
         begin
            tmpfinfo := files.Items[Index] as TZipHeaderInfo;
            saveOffset := tmpfinfo.relative_offset;
            tmpfinfo.Assign(finfo);
            tmpfinfo.relative_offset := saveOffset;
            rem_info := tmpfinfo;
            { 3/28/00 2,21p1+ }
            infoFile.Seek(finfo.Cextra_field_length + crec.file_comment_length, soFromCurrent);
            finfo.Free;
            finfo := nil;
         end
         else { don't mess with it if there's no local header }
         begin
            finfo.Free;
            finfo := nil;
            Inc(i);
            continue;
         end;
      end;
      if not ZipIsBad then
       begin
        try
           files.AddObject(finfo); { If ZipIsBad then it has already been added }
        except
           if (ReadZipHardWay) then
            begin
              i := 0;
              continue;
            end
           else
            begin
               finfo.Free;
               finfo := nil;
               ClearZip;
               {$IFDEF NO_RES}
               raise EBadZipFile.Create('Not a valid zip file!');
               {$ELSE}
               raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
               {$ENDIF}
            end;
        end;
       end;
      if (ecrec.this_disk > 0) and (finfo.HasComment) then
         GetFileComment(i);
      if (finfo <> nil) then  { 3/28/00 2,21p1+ }
      begin
        infoFile.Seek(finfo.Cextra_field_length + crec.file_comment_length, soFromCurrent);
        if (finfo.Cextra_field_length > 0) then
        begin
           rem_efl := finfo.Cextra_field_length;
           rem_info := finfo;
        end;
      end
      else
         rem_efl := 0;
      Inc(i);
   end;                                                 { For loop }

   { Moved the following to here from further up since GetZipComment could not be called
     until the central directories were read  3/10/98  2.03 }
   if (ecrec.this_disk > 0) and (ecrec.ZipHasComment) then
   begin
      if (ecrec.this_disk <> CurrentDisk) and (not InfoFromInfoFile) then
         SwapDisk(ecrec.this_disk + 1);
      if (not InfoFromInfoFile) then
        GetZipComment
      else
       begin
        infoFile.Seek(ecrec.ZipCommentPos, soFromBeginning);
        {$IFDEF WIN32}
        CommentLength := ecrec.zip_comment_length;
        {$ELSE}
        CommentLength := kpmin(ecrec.zip_comment_length, 255);
        {$ENDIF}
        SetLength(zcomment, CommentLength);
        infoFile.Read(zcomment[1], CommentLength);
        SetZipComment(zcomment);  { Save it in ecrec }
        ecrec.Modified := False;
       end;
   end;
   FNumDisks := ecrec.this_disk + 1;
   if (not InfoFromInfoFile) then
      CurrentDisk := ecrec.this_disk
   else
      CurrentDisk := 0;
   Sort(FSortMode);
   if InfoFromInfoFile then
   begin                                                { Set things back correctly }
      infoFile.Free;
      infoFile := tmpStream;
   end;
end;


procedure TVCLUnZip.Sort(SMode: TZipSortMode);
var
   i                     : Integer;
begin
   if (sortfiles <> nil) and (sortfiles <> files) and (FSortMode <> ByNone) then
      sortfiles.Free;
   if SMode = ByNone then
      sortfiles := files
   else
   begin
      sortfiles := TSortedZip.Create(dupAccept);
      sortfiles.SortMode := SMode;
      sortfiles.DestroyObjects := False;
      for i := 0 to Count - 1 do
         sortfiles.AddObject(files.Items[i] as TZipHeaderInfo);
   end;
   FSortMode := SMode;
end;

procedure TVCLUnZip.CancelTheOperation;
begin
   CancelOperation := True;
end;

function TVCLUnZip.GetCount: Integer;
begin
   if files <> nil then
      Result := files.Count
   else
      Result := 0;
end;

procedure TVCLUnZip.FillList(FilesList: TStrings);
var
   AddBuffer             : string;
   i                     : Integer;
   ZipTimeStr            : string;
   ZipDate               : TDateTime;
   ZipDateStr            : string;
   finfo                 : TZipHeaderInfo;
   encryptmark, commentmark: string[1];
begin
   FilesList.Clear;
   for i := 0 to Count - 1 do
   begin
      finfo := sortfiles.Items[i] as TZipHeaderInfo;
      try
         ZipDate := FileDateToDateTime(finfo.last_mod_file_date_time)
      except
         ZipDate := Now;
      end;
      ZipDateStr := Format('%8s', [FormatDateTime('mm/dd/yy', ZipDate)]);
      ZipTimeStr := Format('%7s', [FormatDateTime('hh:mmam/pm', ZipDate)]);
      if (finfo.general_purpose_bit_flag and 1) <> 0 then
         encryptmark := '#'
      else
         encryptmark := '';
      if finfo.HasComment then
         commentmark := '@'
      else
         commentmark := '';
      with finfo do
         AddBuffer := filename + encryptmark + commentmark + #9 + ZipDateStr + #9 + ZipTimeStr
            + #9
            + Format('%8d', [uncompressed_size]) + #9 + Format('%8d', [compressed_size]) + #9
            + Format('%3d%s', [CRate(uncompressed_size, compressed_size), '%']) + #9
         + comp_method[compression_method] + #9 + Directory;
      FilesList.Add(LowerCase(AddBuffer));
   end;
end;

procedure TVCLUnZip.SetThisVersion(v: Integer);
begin
   FthisVersion := kpThisVersion;
end;

procedure TVCLUnZip.DefaultGetNextDisk(Sender: TObject;
   NextDisk: Integer; var FName: string);
var
   MsgArray              : array[0..255] of Char;
begin
   if MultiMode = mmSpan then
   begin
      {$IFNDEF KPSMALL}
      Screen.Cursor := crDefault;
      {$ENDIF}
      {$IFDEF NO_RES}
      StrPCopy(MsgArray, 'Please insert disk ' + IntToStr(NextDisk) +
         ' of the multi-disk set.');
      {$ELSE}
      StrPCopy(MsgArray, LoadStr(IDS_INSERTDISK) + IntToStr(NextDisk) +
         LoadStr(IDS_OFMULTISET));
      {$ENDIF}
      if MessageBox(0, MsgArray, '', MB_OKCANCEL) = IDCANCEL then
         FName := '';
      {$IFNDEF KPSMALL}
      Screen.Cursor := crHourGlass;
      {$ENDIF}
   end
   else
   begin
      FName := ChangeFileExt(FName, '.' + Format('%3.3d', [NextDisk]));
   end;
end;

{$IFDEF KPDEMO}

function DelphiIsRunning: Boolean;
const
   A1                    : array[0..12] of char = 'TApplication'#0;
   A2                    : array[0..15] of char = 'TAlignPalette'#0;
   {A3: array[0..18] of char = 'TPropertyInspector'#0;}
   A4                    : array[0..11] of char = 'TAppBuilder'#0;
   {$IFDEF WIN32}
   {$IFDEF VER130}
     {$IFDEF ISBCB5}
     T1                    : array[0..15] of char = 'C++Builder 5'#0;
     {$ENDIF}
     {$IFDEF ISDELPHI5}
     T1                    : array[0..15] of char = 'Delphi 5'#0;
     {$ENDIF}
   {$ENDIF}
   {$IFDEF VER140}
   T1                    : array[0..15] of char = 'Delphi 6'#0;
   {$ENDIF}
   {$IFDEF VER120}
   T1                    : array[0..15] of char = 'Delphi 4'#0;
   {$ENDIF}
   {$IFDEF VER100}
   T1                    : array[0..15] of char = 'Delphi 3'#0;
   {$ENDIF}
   {$IFDEF VER90}
   T1                    : array[0..15] of char = 'Delphi 2.0'#0;
   {$ENDIF}
   {$IFDEF VER93}
   T1                    : array[0..15] of char = 'C++Builder'#0;
   {$ENDIF}
   {$IFDEF VER110}
   T1                    : array[0..15] of char = 'C++Builder'#0;
   {$ENDIF}
   {$IFDEF VER125}
   T1                    : array[0..15] of char = 'C++Builder 4'#0;
   {$ENDIF}
   {$ELSE}
   T1                    : array[0..15] of char = 'Delphi'#0;
   {$ENDIF}
begin
   Result := (FindWindow(A1, T1) <> 0) and
      (FindWindow(A2, nil) <> 0) and
      {(FindWindow(A3,nil)<>0) and}
   (FindWindow(A4, nil) <> 0);
end;
{$ENDIF}

{$IFNDEF FULLPACK}
procedure Register;
begin
   RegisterComponents('VCLZip', [TVCLUnZip]);
end;
{$ENDIF}


{ $Id: VCLUnZip.pas,v 1.37 2000-12-16 16:50:08-05 kp Exp kp $ }

{ $Log: VCLUnZip.pas,v $
{ Revision 1.37  2000-12-16 16:50:08-05  kp
{ 2.21 Final Release 12/12/00
{
{ Revision 1.36  2000-06-04 15:54:21-04  kp
{ - added code to ReadZipHardWay if AddObject throws exception.  This one caused by
{   a zip with central file header that had a duplicate offset value.
{
{ Revision 1.35  2000-05-21 18:47:05-04  kp
{ - Changed DEF_BUFSTREAMSIZE to $4000 for 16bit.
{
{ Revision 1.34  2000-05-13 16:58:57-04  kp
{ - Added BufferedStreamSize property
{ - Added ECantWriteUCF exception
{ - Added ImproperZip property
{ - Fixed problem of when KeepZipOpen is True and trying to open next disks filepart when
{   doing spanned zip sets.
{ - Fixed problem of extra field, now will handle whether bogus or not.
{ - Improved handling of bad zips beyond the point of looking for end of central
{ - Fixed problem of not being able to get zip comments from zfc file
{
{ Revision 1.33  1999-12-05 09:32:08-05  kp
{ - ran through formatter
{
{ Revision 1.32  1999-11-21 08:49:02-05  kp
{ - added kp to min and max for D1
{ - added integrity checking in reading of zip file
{
{ Revision 1.31  1999-11-09 19:41:01-05  kp
{ - Modified to correctly handle extra fields in headers
{ - Removed check for Object Inspector window in IDE Check
{
{ Revision 1.30  1999-10-24 11:02:25-04  kp
{ - Shored up the GetDecryptHeaderPtr and GetDecryptHeader methods.
{
{ Revision 1.29  1999-10-24 09:34:24-04  kp
{ - Added ENotEnoughRoom exception
{ - Fixed up GetDecryptHeaderPtr a little, still needs some work
{ - Small fix in GetFileInfo for spanned zip files whos central dir doesnt start on last disk
{
{ Revision 1.28  1999-10-20 18:15:25-04  kp
{ - Added Retry parameter to OnSkippingFile
{
{ Revision 1.27  1999-10-11 20:11:11-04  kp
{ - Added FlushFilesOnClose property
{
{ Revision 1.26  1999-09-26 19:57:36-04  kp
{ - Removed defines that had already been moved to kpdefs.inc
{
{ Revision 1.25  1999-09-16 20:08:33-04  kp
{ - Moved defines to KPDEFS.INC
{
{ Revision 1.24  1999-09-14 21:27:27-04  kp
{ - Added compiler detection defines to this file
{ - Removed GetDecryptHeader function from BCB versions
{ - Added a few checks for proper arguments to a few methods
{
{ Revision 1.23  1999-09-01 18:30:01-04  kp
{ - Modified ReadZipHardWay to check for 0-10 right after the sig is found instead of
{   checking to be sure it is zero.
{
{ Revision 1.22  1999-08-25 19:03:42-04  kp
{ - Fixes for D1
{ - Updated Assign methods
{
{ Revision 1.21  1999-08-25 17:54:54-04  kp
{ - Added izAssumeNotAZip IncompleteZipMode and ENotAZipFile exception
{ - Added buffered memory unzipping
{ - Added CheckArchive
{ - Added ability to read zip info on first disk of multizip file
{ - Added DecryptHeader methods for BCB
{ - Added NumSelected
{
{ Revision 1.20  1999-07-06 20:08:10-04  kp
{ - Added the ClearSelected procedure
{
{ Revision 1.19  1999-06-27 13:55:22-04  kp
{ - Added Selected[Index] property and the UnZipSelected, UnZipToBufferByIndex, and
{  UnZipToStreamByIndex methods
{
{ Revision 1.18  1999-06-27 10:17:09-04  kp
{ - Added DecryptHeader property
{ - Added Assign method
{
{ Revision 1.17  1999-06-02 10:27:05-04  kp
{ - Added constants for header signatures
{
{ Revision 1.16  1999-04-24 21:15:11-04  kp
{ - Fixed small problem with IDE check in BCB 4
{
{ Revision 1.15  1999-04-10 10:19:38-04  kp
{ - Added conditionals so that NOLONGNAMES and NODISKUTILS wont get set in 32bit.
{ - Added OnUnZipComplete event.
{
{ Revision 1.14  1999-03-30 19:43:21-05  kp
{ - Modified so that defining MAKESMALL will create a much smaller component.
{
{ Revision 1.13  1999-03-22 17:33:06-05  kp
{ - modified for BCB4
{ - moved comments to bottom
{ - moved strings to string list resource
{
{ Revision 1.12  1999-03-20 18:22:11-05  kp
{ - Modified OnStartUnZip to have FName be a var parameter.
{ - Moved the OnStartUnZip call so that output filename could be changed
{
{ Revision 1.11  1999-03-20 11:45:06-05  kp
{ - Fixed problem where setting ZipComment to '' caused an access violation
{
{ Revision 1.10  1999-03-17 18:25:09-05  kp
{ - Added ReplaceReadOnly property
{
{ Revision 1.9  1999-03-09 21:59:26-05  kp
{ - Fixed problem of disappearing OnGetNextDisk event
{
{ Revision 1.8  1999-02-14 15:33:12-05  kp
{ - Fixed bug that caused a directory called c:\TestZip\ to be created when FileIsOK was called.
{ - Changed AnsiCompareStr to AnsiCompareText in ReadZipHardWay.
{ - Fixed bug that caused ReadZipHardWay's information to be inadvertantly deleted.
{
{ Revision 1.7  1999-01-25 19:08:34-05  kp
{ Added DefaultGetNextDisk
{ Added ResetFileIsOK
{ Removed IsAZipFile
{
{ Revision 1.6  1999-01-12 20:25:16-05  kp
{ -Slight modification to precompiler conditionals
{ -Tightened up CancelTheOperation some
{ }

{ 7/10/98 5:26:10 PM
{ Moved one line in Destroy method becasue a user said
{ that it stopped him from getting "Invalid Pointer
{ Operation" errors.
}
{
{ Sun 10 May 1998   16:58:45  SVersion: 2.12
{ - Added TempPath property
{ - Fixed RelativePaths bug
{ - Fixed bug related to files in FilesList that don't exist
}
{
{ Mon 27 Apr 1998   18:09:07 Version: 2.11
{ Added BCB 3 Support
{ Added kpThisVersion constant
}
{
{ Sun 29 Mar 1998   10:51:34  Version: 2.1
{ Version 2.1 additions
{
{ - Capability of 16bit VCLZip to store long filenames/paths
{ when running on 32 bit OS.
{ - New Store83Names property to force storing short
{ filenames and paths
{ - Better UNC path support.
{ - Fixed a bug to allow adding files to an empty archive.
}
{
{  Tue 24 Mar 1998   19:00:21
{ Modifications to allow files and paths to be stored in DOS
{ 8.3 filename format.  New property is Store83Names.
}
{
{ Wed 11 Mar 1998   21:10:15 Version: 2.03
{ Version 2.03 Files containing many fixes
}

end.

