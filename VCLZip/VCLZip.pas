{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: VCLZip.pas                                                        }
{     Description: VCLZip component - native Delphi unzip component.                 }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, boylank@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }
unit VCLZip;

{$I KPDEFS.INC}

{$P-} { turn off open parameters }
{$R-}   { 3/10/98 2.03 }
{$Q-}   { 3/10/98 2.03 }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }

interface

uses
{$IFDEF WIN32}
 Windows,
{$ELSE}
 WinTypes, WinProcs, kpSHuge,
{$ENDIF}
  SysUtils, Messages, Classes,
  {$IFDEF KPSMALL}
   kpSmall,
  {$ELSE}
  Dialogs, Forms, Controls,
  {$ENDIF}
  KpLib, VCLUnZip, kpZipObj, kpMatch {$IFNDEF NO_RES}, kpzcnst {$ENDIF};

{$IFNDEF WIN32}
  {$DEFINE WIN16}
{$ELSE}
  {$IFOPT C+}
     {$DEFINE ASSERTS}
  {$ENDIF}
{$ENDIF}

type
  usigned = word;
  WPos = WORD;
  IPos = usigned;
  uch = Byte;
  EInvalidMatch = Class( Exception );
  ct_dataPtr = ^ct_data;
  ct_data = packed Record
     fc: Record
           Case Integer of
              0: (freq:   WORD );
              1: (code:   WORD );
         end;
     dl: Record
           Case Integer of
              0: (dad:    WORD );
              1: (len:    WORD );
         end;
  end;
  ct_dataArrayPtr = ^ct_dataArray;
 ct_dataArray = array [0..(MAX_USHORT div SizeOf(ct_data))-1] of ct_data;
  static_ltreePtr = ^static_ltree_type;
  static_dtreePtr = ^static_dtree_type;
  static_ltree_type = array [0..L_CODES+1] of ct_data;
  static_dtree_type = array [0..D_CODES-1] of ct_data;

  windowtypePtr = ^windowtype;
  prevtypePtr = ^prevtype;
  headtypePtr = ^headtype;
  l_buftypePtr = ^l_buftype;
  d_buftypePtr = ^d_buftype;
  flag_buftypePtr = ^flag_buftype;

  {$IFDEF WIN32}
  windowtype = array[0..2*WSIZE-1] of uch;
  prevtype = array[0..WSIZE-1] of WPos;
  headtype =  array[0..HASH_SIZE-1] of WPos;
  l_buftype = array [0..LIT_BUFSIZE-1] of Byte;
  d_buftype = array [0..DIST_BUFSIZE-1] of WORD;
  flag_buftype = array [0..(LIT_BUFSIZE div 8)-1] of Byte;
  {$ELSE}
  windowtype = array[0..0] of Byte;
  prevtype = array[0..0] of Word;
  headtype = array[0..0] of Word;
  l_buftype = array[0..0] of Byte;
  d_buftype = array[0..0] of Word;
  flag_buftype = array[0..0] of Byte;
  {$ENDIF}

  TZipAction = (zaUpdate, zaReplace, zaFreshen);

  TStartZipInfo = procedure( Sender: TObject; NumFiles: Integer; TotalBytes: Comp;
              var EndCentralRecord: TEndCentral; var StopNow: Boolean ) of Object;
  TStartZipEvent = procedure( Sender: TObject; FName: String;
                 var ZipHeader: TZipHeaderInfo; var Skip: Boolean ) of Object;
  TEndZipFileEvent = procedure( Sender: TObject; FName: String; UncompressedSize,
                             CompressedSize, CurrentZipSize: LongInt ) of Object;
  TDisposeEvent = procedure( Sender: TObject; FName: String; var Skip: Boolean ) of Object;
  TDeleteEvent = procedure( Sender: TObject; FName: String ; var Skip: Boolean ) of Object;
  TNoSuchFileEvent = procedure( Sender: TObject; FName: String ) of Object;
  TZipComplete = procedure( Sender : TObject; FileCount : Integer) of Object;
  TUpdateAction = (uaReplacing, uaKeeping);   { 7/5/99  2.18+ }
  TUpdateEvent = procedure( Sender: TObject; UDAction: TUpdateAction;
                             FileIndex: Integer ) of Object; { 7/5/99  2.18+ }
  TPrepareNextDisk = procedure( Sender: TObject; DiskNum: Integer ) of Object; { 7/9/00 2.21b3+ }
  TOnRecursingFile = procedure( Sender: TObject; FName: String ) of Object; { 7/9/01 2.21+ }

 TMultiZipInfo = class(TPersistent)
  private
    FBlockSize: LongInt;
    FFirstBlockSize: LongInt;
    FSaveOnFirstDisk: LongInt; { 8/15/99 2.18+ }
    FSaveZipInfo: Boolean;     { 8/15/99 2.18+ }
    FMultiMode: TMultiMode;
    FCheckDiskLabels: Boolean;
    FWriteDiskLabels: Boolean;

  public
    Constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BlockSize: LongInt read FBlockSize write FBlockSize default 1457600;
    property FirstBlockSize: LongInt read FFirstBlockSize write FFirstBlockSize default 1457600;
    property SaveOnFirstDisk: LongInt read FSaveOnFirstDisk write FSaveOnFirstDisk default 0;
    property SaveZipInfoOnFirstDisk: Boolean read FSaveZipInfo write FSaveZipInfo default False;
    property MultiMode: TMultiMode read FMultiMode write FMultiMode default mmNone;
    property CheckDiskLabels: Boolean read FCheckDiskLabels write FCheckDiskLabels default True;
    property WriteDiskLabels: Boolean read FWriteDiskLabels write FWriteDiskLabels default True;
 end;

 TVCLZip = class(TVCLUnZip)
  private
     FPackLevel:    Integer;
     FRecurse:      Boolean;
     FDispose:      Boolean;
     FStorePaths:   Boolean;
     FRelativePaths: Boolean;
     FStoreVolumes: Boolean;
     FZipAction:    TZipAction;
     FBlockSize:    LongInt;
     FMultiZipInfo: TMultiZipInfo;
     FStore83Names: Boolean;
     FTempPath:     String;
     FSkipIfArchiveBitNotSet: Boolean; { 7/4/98 2.13 }
     FResetArchiveBitOnZip: Boolean; { Added 4-Jun-98 SPF 2.13 }
     FExcludeList: TStrings;    { 9/27/98  2.15 }
     FNoCompressList: TStrings; { 9/27/98  2.15 }
     FOnZipComplete: TZipComplete;
     {$IFDEF UNDER_DEVELOPMENT}
     FOtherVCLZip:  TVCLZip;    { 10/24/99 2.20b3+ }
     {$ENDIF}

     FOnStartZipInfo: TStartZipInfo;
     FOnStartZip:   TStartZipEvent;
     FOnDisposeFile: TDisposeEvent;
     FOnEndZip: TEndZipFileEvent;
     FOnDeleteEntry: TDeleteEvent;
     FOnNoSuchFile: TNoSuchFileEvent;
     FOnUpdate: TUpdateEvent; { 7/5/99  2.18+ }
     FOnPrepareNextDisk: TPrepareNextDisk; { 7/9/00 2.21b3+ }
     FOnRecursingFile: TOnRecursingFile;  { 7/9/01 2.21+ }

     AmountWritten: BIGINT;
     AmountToWrite: BIGINT;
     UsingTempFile: Boolean;
     CreatingSFX: Boolean;
     SFXStubFile: TLFNFileStream;
     FPreserveStubs: Boolean;
     FAddDirEntries: Boolean;
     FFileOpenMode: Word;

  protected
    { Protected declarations }
     zfile:         TStream; { output compression file }
     IFile:         TStream; { input file to compress }
     mfile:         TStream; { temporary file during spanned file creation }
     IFileName:     String;
     isize:         LongInt;
     tmpfiles:      TSortedZip;
     tmpfiles2:     TSortedZip;
     tmpecrec:      TEndCentral;
     tmpfile_info:  TZipHeaderInfo;
     tmpZipName:    String;
     mZipName:      String;
     Deleting:      Boolean;
     FileBytes:     LongInt;
     SaveNewName:   String;

  static_ltree:  static_ltree_type;
  static_dtree:  static_dtree_type;
  bl_count:      array [0..MAX_ZBITS] of WORD;
  base_dist:     array [0..D_CODES-1] of Integer;
  length_code:   array [0..MAX_MATCH-MIN_MATCH] of Byte;
  dist_code:     array [0..511] of Byte;
  base_length:   array [0..LENGTH_CODES-1] of Integer;
  TRInitialized: Boolean;
  {$IFDEF WIN16}
  windowObj:     TkpHugeByteArray;
  prevObj:       TkpHugeWordArray;
  headObj:       TkpHugeWordArray;
  l_bufObj:      TkpHugeByteArray;
  d_bufObj:      TkpHugeWordArray;
  flag_bufObj:   TkpHugeByteArray;
  {$ENDIF}
  window:        windowtypePtr;
  prev:          prevtypePtr;
  head:          headtypePtr;
  l_buf:         l_buftypePtr;
  d_buf:         d_buftypePtr;
  flag_buf:      flag_buftypePtr;

    function zfwrite(buf: BytePtr; item_size, nb: Integer): LongInt;
    function zencode(c: Byte): Byte;
    function file_read( w: BytePtr; size: usigned ): LongInt;
    procedure CreateTempZip;
    function Deflate: LongInt;
    function ProcessFiles: Integer;
    function AddFileToZip( FName: String ): Boolean;
    {procedure MoveExistingFiles;}
    procedure MoveFile( Index: Integer );
    procedure MoveTempFile;
    procedure StaticInit;
    procedure CryptHead( passwrd: String );

    procedure SetZipName( ZName: String ); override;
    function GetIsModified: Boolean;
    procedure SetMultiZipInfo(Value: TMultiZipInfo);
    function GetCheckDiskLabels: Boolean; override;
    procedure SetStoreVolumes( Value: Boolean );
    function GetMultiMode: TMultiMode; override;
    procedure SetCheckDiskLabels( Value: Boolean ); override;
    procedure SetMultiMode( Value: TMultiMode ); override;
    procedure ResetArchiveBit(AFileName: string); { Added 4-Jun-98 SPF 2.13? }
    function DiskRoom: BIGINT;
    function RoomLeft: BIGINT;
    procedure NextPart;
    procedure LabelDisk;
    procedure SaveZipInfoToFile( Filename: String );   { 8/14/99 2.18+ }

    procedure SetDateTime(Index: Integer; DT: TDateTime );
    procedure SetPathname(Index: Integer; Value: TZipPathname);
    procedure SetFilename(Index: Integer; Value: String);
    procedure SetStorePaths(Value: Boolean);
    procedure SetRelativePaths(Value: Boolean);

    function  TemporaryPath: String;
    procedure SetExcludeList(Value: TStrings);             { 9/27/98  2.15 }
    procedure SetNoCompressList(Value: TStrings);          { 9/27/98  2.15 }
    function IsInExcludeList( N: String ): Boolean;        { 9/27/98  2.15 }
    function IsInNoCompressList( N: String ): Boolean;     { 9/27/98  2.15 }

    procedure Loaded; override;

  public
    { Public declarations }
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;  { 6/27/99 2.18+ }
    function Zip: Integer;
    function DeleteEntries: Integer;
    procedure SaveModifiedZipFile;
    function ZipFromStream( theStream: TStream; FName: String ): Integer;
    function FixZip( InputFile, OutputFile: String): Integer;
    procedure MakeSFX( SFXStub: String; ModHeaders: Boolean );
    function MakeNewSFX( SFXStub: String; FName: String; Options: PChar;
                                                      OptionsLen: Integer): Integer;
    function ZipFromBuffer( Buffer: PChar; Amount: Longint; FName: String ): Integer;
    procedure SFXToZip(DeleteSFX: Boolean);

    {$IFDEF UNDER_DEVELOPMENT}
    { 10/24/99 2.20b3+ }
    procedure GetRawCompressedFile( Index: Integer; var Header: TZipHeaderInfo; ZippedStream: TStream );
    procedure InsertRawCompressedFile( Header: TZipHeaderInfo; ZippedStream: TStream );
    {$ENDIF}

    property DateTime[Index: Integer]: TDateTime read GetDateTime write SetDateTime;
    property FileComment[Index: Integer]: String read GetFileComment write SetFileComment;
    property ZipComment: String read GetZipComment write SetZipComment;
    property IsModified: Boolean read GetIsModified;
    property CheckDiskLabels: Boolean read GetCheckDiskLabels write SetCheckDiskLabels;
    property MultiMode: TMultiMode read GetMultiMode write SetMultiMode;

    property Pathname[Index: Integer]: TZipPathname read GetPathname write SetPathname;
    property Filename[Index: Integer]: String read GetFilename write SetFilename;
    property PreserveStubs: Boolean read FPreserveStubs write FPreserveStubs default False;
    property FileOpenMode: Word read FFileOpenMode write FFileOpenMode default fmShareDenyNone;
    {$IFDEF UNDER_DEVELOPMENT}
    property OtherVCLZip: TVCLZip read FOtherVCLZip write FOtherVCLZip;   { 10/24/99 2.20b3+ }
    {$ENDIF}

  published
    { Published declarations }
    property PackLevel: Integer read FPackLevel write FPackLevel default 6;
    property Recurse: Boolean read FRecurse write FRecurse default False;
    property Dispose: Boolean read FDispose write FDispose default False;
    property StorePaths: Boolean read FStorePaths write SetStorePaths default False;
    property RelativePaths: Boolean read FRelativePaths write SetRelativePaths default False;
    property StoreVolumes: Boolean read FStoreVolumes write SetStoreVolumes default False;
    property ZipAction: TZipAction read FZipAction write FZipAction default zaUpdate;
    property MultiZipInfo: TMultiZipInfo read FMultiZipInfo write SetMultiZipInfo;
    property Store83Names: Boolean read FStore83Names write FStore83Names default False;
    property TempPath: String read FTempPath write FTempPath;  { 5/5/98  2.12 }
    property SkipIfArchiveBitNotSet: Boolean read FSkipIfArchiveBitNotSet
              write FSkipIfArchiveBitNotSet default False; { 7/4/98  2.13 }
    property ResetArchiveBitOnZip: Boolean read FResetArchiveBitOnZip
              write FResetArchiveBitOnZip default False; { Added 4-Jun-98 SPF 2.13? }
    property ExcludeList: TStrings read FExcludeList write SetExcludeList;  { 9/27/98  2.15 }
    property NoCompressList: TStrings read FNoCompressList write SetNoCompressList;  { 9/27/98  2.15 }
    property AddDirEntriesOnRecurse: Boolean read FAddDirEntries write FAddDirEntries default False;

    { Event Properties }
    property OnStartZip: TStartZipEvent read FOnStartZip write FOnStartZip;
    property OnStartZipInfo: TStartZipInfo read FOnStartZipInfo write FOnStartZipInfo;
    property OnEndZip: TEndZipFileEvent read FOnEndZip write FOnEndZip;
    property OnDisposeFile: TDisposeEvent read FOnDisposeFile write FOnDisposeFile;
    property OnDeleteEntry: TDeleteEvent read FOnDeleteEntry write FOnDeleteEntry;
    property OnNoSuchFile: TNoSuchFileEvent read FOnNoSuchFile write FOnNoSuchFile;
    property OnZipComplete: TZipComplete read FOnZipComplete write FOnZipComplete;
    property OnUpdate: TUpdateEvent read FOnUpdate write FOnUpdate;  { 7/5/99  2.18+ }
    property OnPrepareNextDisk: TPrepareNextDisk read FOnPrepareNextDisk write FOnPrepareNextDisk;
    property OnRecursingFile: TOnRecursingFile read FOnRecursingFile write FOnRecursingFile;
  end;

  {$IFNDEF FULLPACK}
  procedure Register;
  {$ENDIF}

implementation

{$I kpDFLT.PAS}

constructor TMultiZipInfo.Create;
begin
  Inherited Create;
  MultiMode := mmNone;
  FBlockSize := 1457600;
  FFirstBlockSize := 1457600;
  FSaveOnFirstDisk := 0;
  FSaveZipInfo := False;
  CheckDiskLabels := True;
  FWriteDiskLabels := True;
end;

procedure TMultiZipInfo.Assign(Source: TPersistent);
var
  Src: TMultiZipInfo;
begin
  If Source is TMultiZipInfo then
   begin
     Src := TMultiZipInfo(Source);
     FMultiMode := Src.MultiMode;
     FBlockSize := Src.BlockSize;
     FFirstBlockSize := Src.FirstBlockSize;
     FSaveOnFirstDisk := Src.SaveOnFirstDisk;
     FSaveZipInfo := Src.FSaveZipInfo;
     FCheckDiskLabels := Src.CheckDiskLabels;
     FWriteDiskLabels := Src.WriteDiskLabels;
   end
 else inherited Assign(Source);
end;

constructor TVCLZip.Create( AOwner: TComponent );
begin
  inherited Create(AOwner);
  FMultiZipInfo := TMultiZipInfo.Create;
  FPackLevel := 6;
  FRecurse := False;
  FDispose := False;
  FStorePaths := False;
  FStoreVolumes := False;
  FZipAction := zaUpdate;  {update only if newer}
  FBlockSize := 1457600;
  FRelativePaths := False;
  FStore83Names := False;
  FTempPath := '';
  Deleting := False;
  zfile := nil;
  tmpfiles := nil;
  tmpecrec := nil;
  TRInitialized := False;
  SaveNewName := '';
  {$IFDEF UNDER_DEVELOPMENT}
  FOtherVCLZip := nil;   { 10/24/99 2.20b3+ }
  {$ENDIF}
  StaticInit;
  CreatingSFX := False;
  FSkipIfArchiveBitNotSet := False; { 7/4/98 2.13 }
  FResetArchiveBitOnZip := False; { Added 4-Jun-98 SPF 2.13? }
  FExcludeList := TStringList.Create;  { 9/27/98  2.15 }
  FnoCompressList := TStringList.Create;  { 9/27/98  2.15 }
  FPreserveStubs := False; { 01/12/99  2.17 }
  FAddDirEntries := False; { 06/09/99 2.18+ }
  FFileOpenMode := fmShareDenyNone; { 10/17/99 2.18+ }  { changed back to fmShareDenyNone }
                                                        { 05/13/00 2.20+  }
end;

destructor TVCLZip.Destroy;
begin
  FMultiZipInfo.Free;
  FMultiZipInfo := nil; { 4/25/98  2.11 }
  If (FExcludeList <> nil) then
     FExcludeList.Free;  { 9/27/98  2.15 }
  If (FNoCompressList <> nil) then
     FNoCompressList.Free;  { 9/27/98  2.15 }
  inherited Destroy;
end;

procedure TVCLZip.Loaded;
begin
  inherited Loaded;
  SetCheckDiskLabels( FMultiZipInfo.CheckDiskLabels );
  SetMultiMode( FMultiZipInfo.MultiMode );
end;
procedure TVCLZip.StaticInit;
begin
  ZeroMemory( @static_ltree, SizeOf(static_ltree) );
  ZeroMemory( @static_dtree,  SizeOf(static_dtree) );
  ZeroMemory( @bl_count, SizeOf(bl_count) );
  ZeroMemory( @base_dist, SizeOf(base_dist) );
  ZeroMemory( @length_code, SizeOf(length_code) );
  ZeroMemory( @dist_code, SizeOf(dist_code) );
  ZeroMemory( @base_length, SizeOf(base_length) );
end;

procedure TVCLZip.Assign(Source: TPersistent);  { 6/27/99 2.18+ }
begin
  if source is TVCLZip then
  begin
    inherited Assign(Source);
    FPackLevel:= TVCLZip(Source).PackLevel;
    FRecurse:= TVCLZip(Source).Recurse;
    FDispose:= TVCLZip(Source).Dispose;
    FStorePaths:= TVCLZip(Source).StorePaths;
    FRelativePaths:= TVCLZip(Source).RelativePaths;
    FStoreVolumes:= TVCLZip(Source).StoreVolumes;
    FZipAction:= TVCLZip(Source).ZipAction;
    FMultiZipInfo.Assign(TVCLZip(Source).MultiZipInfo);
    FStore83Names:= TVCLZip(Source).Store83Names;
    FTempPath:= TVCLZip(Source).TempPath;  { 5/5/98  2.12 }
    FSkipIfArchiveBitNotSet:= TVCLZip(Source).SkipIfArchiveBitNotSet; {
7/4/98  2.13 }
    FResetArchiveBitOnZip:= TVCLZip(Source).ResetArchiveBitOnZip; {
Added 4-Jun-98 SPF 2.13? }
    FExcludeList.Assign(TVCLZip(Source).ExcludeList);  { 9/27/98  2.15 }

    FNoCompressList.Assign(TVCLZip(Source).NoCompressList);  { 9/27/98
2.15 }

     FPreserveStubs := TVCLZip(Source).PreserveStubs; { 01/12/99  2.17 }
     FAddDirEntries := TVCLZip(Source).AddDirEntriesOnRecurse; { 06/09/99 2.18+ }
    { Event Properties }
    FOnStartZip:= TVCLZip(Source).OnStartZip;
    FOnStartZipInfo:= TVCLZip(Source).OnStartZipInfo;
    FOnEndZip:= TVCLZip(Source).OnEndZip;
    FOnDisposeFile:= TVCLZip(Source).OnDisposeFile;
    FOnDeleteEntry:= TVCLZip(Source).OnDeleteEntry;
    FOnNoSuchFile:= TVCLZip(Source).OnNoSuchFile;
    FOnZipComplete:= TVCLZip(Source).OnZipComplete;
    FOnUpdate := TVCLZip(Source).OnUpdate;
  end
  else
    inherited Assign(Source);

end;

procedure TVClZip.SetPathname( Index: Integer; Value: TZipPathname );
var
 finfo: TZipHeaderInfo;
  tmpValue: String;
begin
 If (Index > -1) and (Index < Count) then
   begin
    finfo := sortfiles.Items[Index] as TZipHeaderInfo;
     If (Length(Value) > 0) and (Value[Length(Value)] <> '\') then
        tmpValue := Value + '\'
     Else
        tmpValue := Value;
     If tmpValue <> finfo.directory then
      begin
        finfo.directory := tmpValue;
        ecrec.Modified := True;
      end;
   end
  else
     {$IFDEF NO_RES}
      Raise EListError.CreateFmt('Index %d is out of range',[Index]);
     {$ELSE}
      Raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE),[Index]);
     {$ENDIF}
end;

procedure TVClZip.SetFilename( Index: Integer; Value: TZipPathname );
var
 finfo: TZipHeaderInfo;
begin
 If (Index > -1) and (Index < Count) then
   begin
    finfo := sortfiles.Items[Index] as TZipHeaderInfo;
     If Value <> finfo.filename then
      begin
        finfo.filename := Value;
        ecrec.Modified := True;
      end;
   end
  else
     {$IFDEF NO_RES}
      Raise EListError.CreateFmt('Index %d is out of range',[Index]);
     {$ELSE}
      Raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE),[Index]);
     {$ENDIF}
end;

procedure TVCLZip.SetMultiZipInfo(Value: TMultiZipInfo);
begin
  FMultiZipInfo.Assign(Value);
end;

function TVCLZip.GetMultiMode: TMultiMode;
begin
  Result := FMultiZipInfo.FMultiMode;
end;

procedure TVCLZip.SetMultiMode( Value: TMultiMode );
begin
  If FMultiZipInfo = nil then  { 4/26/98  2.11 }
     exit;  { to avoid illegal pointer operation error during Destroy method }
  If Value <> FMultiZipInfo.FMultiMode then
     FMultiZipInfo.FMultiMode := Value;
  FMultiMode := Value;
end;

function TVCLZip.GetCheckDiskLabels: Boolean;
begin
  Result := FMultiZipInfo.CheckDiskLabels;
end;

procedure TVCLZip.SetCheckDiskLabels( Value: Boolean );
begin
  If Value <> FMultiZipInfo.CheckDiskLabels then
     FMultiZipInfo.CheckDiskLabels := Value;
  FCheckDiskLabels := Value;
end;

procedure TVCLZip.SetStoreVolumes( Value: Boolean );
begin
  If Value <> FStoreVolumes then
   begin
     FStoreVolumes := Value;
     If Value = True then
        FStorePaths := True;
   end;
end;

procedure TVCLZip.SetStorePaths( Value: Boolean);
begin
  If Value <> FStorePaths then
   begin
     If Value = False then
      begin
        FStoreVolumes := False;
        FRelativePaths := False;
      end;
     FStorePaths := Value;
   end;
end;

procedure TVCLZip.SetRelativePaths( Value: Boolean );
begin
  If Value <> FRelativePaths then
   begin
     If Value = True then
      begin
        FStorePaths := True;
        FRecurse := True;
      end;
     FRelativePaths := Value;
   end;
end;

{ Added 4-Jun-98 SPF 2.13? }
procedure TVCLZip.ResetArchiveBit(AFileName: string);
begin
    FileSetAttr(AFileName, (FileGetAttr(AFileName) and not faArchive));
end;

function TVCLZip.ZipFromStream( theStream: TStream; FName: String ): Integer;
begin
  if (Trim(FName)='') or (TheStream=Nil) then
   begin
     result:=0;
     exit;
   end;
  CancelOperation := False;
  StreamZipping := True;
  ZipStream := theStream;
  ZipStream.Position := 0;
  FilesList.Clear;
  FilesList.Add( FName );
  try
     Result := Zip;
  finally
     StreamZipping := False;
     CloseZip;
  end;
end;

function TVCLZip.ZipFromBuffer( Buffer: PChar; Amount: LongInt; FName: String ): Integer;
begin
  Result := 0;
  If (Trim(FName)='') or (Amount = 0) then
     exit;
  MemBuffer := Buffer;
  CurrMem := Buffer;
  MemLen := Amount;
  MemLeft := Amount;
  MemZipping := True;
  FilesList.Clear;
  FilesList.Add(Fname);
  try
     Result := Zip;
  finally
     MemZipping := False;
     CloseZip;
  end;
end;

function TVCLZip.Zip: Integer;
begin
  Result := ProcessFiles;
  If Assigned(FOnZipComplete) then FOnZipComplete(self, Result);
end;

function TVCLZip.IsInExcludeList( N: String ): Boolean;
var
  i: Integer;
  M,M1,M2: String;  { 11/27/98  2.16+}
begin
  Result := False;
  i := 0;
  M1 := LowerCase(ExtractFilename(N));   { 10/23/98  2.16+ }
  M2 := LowerCase(N);
  While i < FExcludeList.Count do
   begin
     {If this exclude list item doesn't include path info then ignore
      path info for the file being tested too}
     If (Pos('\',FExcludeList[i]) = 0) then  { 11/27/98  2.16+}
        M := M1
     Else
        M := M2;
     If IsMatch(LowerCase(FExcludeList[i]),M) then
      begin
        Result := True;
        break;
      end;
     Inc(i);
   end;
end;

function TVCLZip.IsInNoCompressList( N: String ): Boolean;
var
  i: Integer;
  M,M1,M2: String;
begin
  Result := False;
  i := 0;
  M1 := LowerCase(ExtractFilename(N));   { 10/23/98  2.16+ }
  M2 := LowerCase(N);
  While i < FNoCompressList.Count do
   begin
     {If this exclude list item doesn't include path info then ignore
      path info for the file being tested too}
     If (Pos('\',FNoCompressList[i]) = 0) then  { 11/27/98  2.16+}
        M := M1
     Else
        M := M2;
     If IsMatch(LowerCase(FNoCompressList[i]),M) then
      begin
        Result := True;
        break;
      end;
     Inc(i);
   end;
end;

function TVCLZip.ProcessFiles: Integer;
var
  DisposeFiles: TStrings;

  procedure AddTheNewFile(i: Integer);
  begin
     Inc(Result);
     tmpecrec.num_entries := tmpecrec.num_entries + 1;
     tmpecrec.num_entries_this_disk := tmpecrec.num_entries_this_disk + 1;
     tmpfiles.AddObject( tmpfile_info );
     tmpfiles2.AddObject( tmpfile_info );
     If Dispose then
        DisposeFiles.Add(FilesList[i]);
  end;

  Procedure DisposeOfFiles;
  var
     x: Integer;
     Skip: Boolean;
  begin
     Skip := False;
     For x := 0 to DisposeFiles.Count-1 do
      begin
        If Assigned(FOnDisposeFile) then
         begin
           Skip := False;
           FOnDisposeFile( Self, DisposeFiles[x], Skip );
         end;
        If not Skip then
           SysUtils.DeleteFile(DisposeFiles[x]);
      end;
     DisposeFiles.Free;
     DisposeFiles := nil;
  end;

  function ComparePath( P: String ): String;
  { This function expects P and RootDir to include full path information
    including disk information.  Also it is assumed that if RelativePaths
    is True then the path information for P contains RootDir. }
  begin
     If StorePaths then
      begin
       Result := ExtractFilePath(P);
       If FRelativePaths then
           Delete(Result, 1, Length(FRootDir))
       Else
        begin
        { modified the following to handle UNC paths  3/26/98  2.1 }
           If (not FStoreVolumes) and (ExtractFileDrive(Result) <> '') {(Result[2] = ':')} then
           Result := RightStr(Result,Length(Result)-(Length(ExtractFileDrive(Result))+1));
           {Result := RightStr(Result,Length(Result)-3);}
        end;
      end
     Else
        Result := '';
  end;

  procedure MoveExistingFiles;

   function FilesListMatches(FName: String): Boolean;
   var
     tmpFName: String;
   begin
     OemFilter(Fname);
     tmpFName := LowerCase(FName);
     If (Deleting) and (IsWildCard( FName )) then
      begin    { Wildcards should only be there if deleting }
        If (Pos('\',FName) > 0) then
           Result := IsMatch(tmpFName,LowerCase(tmpfile_info.directory+tmpfile_info.filename))
        Else
           Result := IsMatch(tmpFName,LowerCase(tmpfile_info.filename));
      end
     Else
      begin
        If not Deleting then
         begin
           tmpFName := ComparePath(tmpFName) + ExtractFilename(tmpFName);
         end;
        Result := tmpFName = LowerCase(tmpfile_info.directory+tmpfile_info.filename);
      end;
   end;

  var
    i,j: Integer;
    MoveTheFile: Boolean;
    Skip, aMatch: Boolean;

  begin
  If files = nil then  { 3/28/98 2.1 }
     exit;             { fixed GPF when adding to empty archive }
  For i := 0 to files.Count-1 do  { Check each file in existing zip }
   begin
     tmpfile_info := TZipHeaderInfo.Create;
     tmpfile_info.Assign(files.Items[i] as TZipHeaderInfo);
     if ((i = 0) and (tmpfile_info.relative_offset > 0) and (FPreserveStubs)) then
      begin   { save sfx stub from beginning of file }
        theZipFile.Seek(0,soFromBeginning);
        zfile.CopyFrom(theZipFile, tmpfile_info.relative_offset);
      end;
     if (tmpfile_info.FileIsOK = 2) then  { skip files that are corrupted }
      begin
        tmpfile_info.Free;
        continue;
      end;
     If (tmpfile_info.file_comment_length > 0) and (tmpfile_info.filecomment = nil) then
        tmpfile_info.filecomment := StrToPChar(FileComment[i]);
     MoveTheFile := True;
     aMatch := False;

     If (Deleting) and (tmpfile_info.Selected) then
     begin
        aMatch := True;
        Skip := False;
        tmpfile_info.Selected := False;
        if (assigned(FOnDeleteEntry)) then
           FOnDeleteEntry(Self, tmpfile_info.directory+tmpfile_info.filename, Skip );
        if (not Skip) then
        begin
           Inc(Result);
           MoveTheFile := False;
        end;
     end
     else If (FilesList.Count > 0) then
     For j := 0 to FilesList.Count-1 do  { Compare to each file in FilesList }
      begin
        If (FilesListMatches(FilesList[j])) then
         begin  { This file is in zip file and fileslist too }
           aMatch := True;
           If  (StreamZipping) or (MemZipping) or (ZipAction = zaReplace) or
               (Deleting) or (((ZipAction = zaUpdate) or (ZipAction = zaFreshen))
               and (DateTime[i] < FileDate(FilesList[j]))) then
            begin                     { Don't move files that will be replaced }
              Skip := False;
              If (Deleting) and (Assigned(FOnDeleteEntry)) then
                 FOnDeleteEntry(Self, tmpfile_info.directory+tmpfile_info.filename, Skip );
              If (Deleting) and (not Skip) then
                 Inc(Result);  { 5/18/98  2.13 }
              If not Skip then
               begin
                 MoveTheFile := False;   { or deleted. }
                 If (Deleting) and (not IsWildcard(FilesList[j])) then
                    FilesList.Delete(j);  { We're deleting, not zipping }
                 If (not Deleting) then
                  begin
                    tmpfile_info.Free;
                    tmpfile_info := TZipHeaderInfo.Create;
                    If Assigned(FOnUpdate) then
                       FOnUpdate( self, uaReplacing, i );
                    try
                       If AddFileToZip(FilesList[j]) then
                          AddTheNewFile(j)
                       Else
                        begin
                          tmpfile_info.Free;
                          tmpfile_info := nil;
                        end;
                    except
                       tmpfile_info.Free;
                       tmpfile_info := nil;
                       raise;
                    end;
                    FilesList.Delete(j);
                  end;
               end
              Else
               begin
                 MoveTheFile := True;    { File should just be saved from current zip }
                 FilesList.Delete(j);    { because current file is not older }
               end;
            end
           Else
            begin
              If Dispose then                    { 11/23/00  2.21b4+ }
                 DisposeFiles.Add(FilesList[j]); { Dispose of original file anyway }
              MoveTheFile := True;    { File should just be saved from current zip }
              FilesList.Delete(j);    { because disk file is not newer }
            end;
           Break;
         end;
      end;

     If MoveTheFile then  { Save this old file into new zip }
      begin
        If (aMatch) and (Assigned(FOnUpdate)) then
           FOnUpdate( self, uaKeeping, i );
        MoveFile(i);
        tmpfiles.AddObject( tmpfile_info );  { Add info to new stuff }
        tmpfiles2.AddObject( tmpfile_info );
        tmpecrec.num_entries := tmpecrec.num_entries + 1;
        tmpecrec.num_entries_this_disk := tmpecrec.num_entries_this_disk + 1;
      end
     Else
        If (Deleting) then
           tmpfile_info.Free
   end;
   tmpfile_info := nil;
  end;


  Procedure ExpandForWildCards;
  var
     i: Integer;
     WildFiles: TStrings;
     DirSearch: TDirSearch;
     theFile, StartDir: String;
     SearchRec: TSearchRec;
     tmpsearchinfo: TZipHeaderInfo;
     tmpWildCard: String;
     Idx: Integer;
     IsAnEntry: Boolean;
     doRecurse: Boolean;
     tmpWildFile: String;
     tmpName: String;
  begin
     WildFiles := TStringList.Create;
     TotalUncompressedSize := 0;
     TotalBytesDone := 0;
     i := 0;
     If ZipAction = zaFreshen then
        Sort( ByName );  { so we can check FilesList agains whats there already }
     While (FilesList.Count > 0) and (i < FilesList.Count) do
      begin
        If (FilesList[i][Length(FilesList[i])] = '\') then
         begin
           Inc(i);
           continue;  { To explicitly add a plain directory entry  6/9/99 2.18+ }
         end;
        If IsWildcard(FilesList[i]) then
         begin
           WildFiles.Add( FilesList[i] );
           FilesList.Delete(i);
         end
        Else
         begin  { See if file exists }
          If ExtractFilePath(FilesList[i]) = '' then
           FilesList[i] := FRootDir + FilesList[i];
          If IsInExcludeList(FilesList[i]) then    { 9/28/98  2.15 }
           begin
              FilesList.Delete(i);
              Continue;
           end;
          If FindFirst( FilesList[i], faAnyFile, SearchRec ) = 0 then
           begin
              If ((FSkipIfArchiveBitNotSet) and ((FileGetAttr(FilesList[i]) and faArchive)=0)) then
               begin
                 FilesList.Delete(i);
                 Continue;  { Skip if only zipping files with archive bit set }
               end;
              If ZipAction = zaFreshen then
               begin
                { Ignore it if it's not already in the zip }
                tmpName := FilesList[i];
                OemFilter( tmpName );
                tmpsearchinfo := TZipHeaderInfo.Create;
                tmpsearchinfo.filename := ExtractFilename(tmpName);
                tmpsearchinfo.directory :=  ComparePath(tmpName);
                IsAnEntry := sortfiles.Search( Pointer(tmpsearchinfo), Idx );
                tmpsearchinfo.Free;
                If not IsAnEntry then { Delete this entry from fileslist }
                 begin
                    FilesList.Delete(i);
                    Continue;  { Skip if freshening and file's not in zip already }
                 end;
               end;
              TotalUncompressedSize := TotalUncompressedSize + SearchRec.Size;
              Inc(i);
              FindClose( SearchRec );  {1/28/98 moved inside here so wouldn't be called if}
           end                         {FindFirst didn't find anything    v2.00+}
          Else
           begin
					If Assigned( FOnNoSuchFile ) then
                 OnNoSuchFile( Self, FilesList[i] );
              { Moved following line down 1 to fix 'List out of bounds' error. 5/5/98 2.12 }
              FilesList.Delete(i);  { No such file to zip }
           end;
         end;
      end;

   If WildFiles.Count > 0 then
     For i := 0 to WildFiles.Count-1 do
      begin
        { Added recursion override feature 7/22/98  2.14 }
        If (WildFiles[i][1] = WILDCARD_NORECURSE) then  { No recursing }
         begin
           doRecurse := False;
           tmpWildFile := WildFiles[i];
           Delete(tmpWildFile,1,1);
           WildFiles[i] := tmpWildFile;
         end
        Else If (WildFiles[i][1] = WILDCARD_RECURSE) then  { Recurse }
         begin
           doRecurse := True;
           tmpWildFile := WildFiles[i];
           Delete(tmpWildFile,1,1);
           WildFiles[i] := tmpWildFile;
         end
        Else doRecurse := FRecurse;

        StartDir := ExtractFileDir(WildFiles[i]);
        If StartDir = '' then
           StartDir := FRootDir;
        If not DirExists(StartDir) then   { 10/23/98  2.16+ }
           continue;
        tmpWildCard := ExtractFilename(WildFiles[i]);
        { Convert *.* to * so that it will get all files in
          TDirSearch }
        if (tmpWildCard = '*.*') then   { 7/9/01  2.21+ }
           tmpWildCard := '*';
        DirSearch := TDirSearch.Create( StartDir, tmpWildCard, doRecurse );
        theFile := DirSearch.NextFile(SearchRec);
        While (theFile <> '') do
         begin
          If (Assigned(FOnRecursingFile)) then
              FOnRecursingFile(Self, theFile);
          If (theFile[Length(theFile)] = '\') then
           begin
              If (doRecurse) and (FAddDirEntries) then
                 FilesList.Add( theFile );
              theFile := DirSearch.NextFile(SearchRec);
              Continue;
           end;
          If IsInExcludeList(theFile) then   { 9/28/98  2.15 }
           begin
              theFile := DirSearch.NextFile(SearchRec);
              Continue;
           end;
          If (DoProcessMessages) then
           begin
              {$IFNDEF KPSMALL}
              Application.ProcessMessages;
              {$ELSE}
              YieldProcess;
              {$ENDIF}
              If CancelOperation then
               begin
                 CancelOperation := False;
                 {$IFDEF NO_RES}
                 raise EUserCanceled.Create('User Aborted Operation');
                 {$ELSE}
                 raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
                 {$ENDIF}
               end;
           end;
           {Don't archive the archive we are creating right now}
           If (ArchiveIsStream) or (AnsiCompareText(theFile,ZipName) <> 0) then
            begin
              If ((FSkipIfArchiveBitNotSet) and ((FileGetAttr(theFile) and faArchive)=0)) then
               begin
                 theFile := DirSearch.NextFile(SearchRec);
                 Continue;  { Skip if only zipping files with archive bit set }
               end;
              If ZipAction = zaFreshen then { skip if its not already in zip file }
               begin
                 { Ignore it if it's not already in the zip }
                 tmpName := theFile;
                 OemFilter( tmpName );
                 tmpsearchinfo := TZipHeaderInfo.Create;
                 tmpsearchinfo.filename := ExtractFilename(tmpName);
                 tmpsearchinfo.directory := ComparePath(tmpName);
                 IsAnEntry := sortfiles.Search( Pointer(tmpsearchinfo), Idx );
                 tmpsearchinfo.Free;
                 If not IsAnEntry then
                  begin
                    theFile := DirSearch.NextFile(SearchRec);
                    Continue;  { Skip if freshening and file's not in zip already }
                  end;
               end;
              FilesList.Add( theFile );
              TotalUncompressedSize := TotalUncompressedSize + SearchRec.Size;
            end;
           theFile := DirSearch.NextFile(SearchRec);
         end;
        DirSearch.Free;
      end;

     WildFiles.Free;
     If ZipAction = zaFreshen then
       Sort( ByNone );  { Set back }
  end;

  procedure AllocateZipArrays;
  begin
  {$IFDEF WIN16}
     If windowObj = nil then
      begin
        windowObj := TkpHugeByteArray.Create(2*WSIZE);
        window := windowtypePtr(windowObj.AddrOf[0]);
        prevObj := TkpHugeWordArray.Create(WSIZE);
        prev := prevtypePtr(prevObj.AddrOf[0]);
        headObj :=  TkpHugeWordArray.Create(HASH_SIZE);
        head := headtypePtr(headObj.AddrOf[0]);
        l_bufObj := TkpHugeByteArray.Create(LIT_BUFSIZE);
        l_buf := l_buftypePtr(l_bufObj.AddrOf[0]);
        d_bufObj := TkpHugeWordArray.Create(DIST_BUFSIZE);
        d_buf := d_buftypePtr(d_bufObj.AddrOf[0]);
        flag_bufObj := TkpHugeByteArray.Create(LIT_BUFSIZE div 8);
        flag_buf := flag_buftypePtr(flag_bufObj.AddrOf[0]);
      end;
  {$ELSE}
     If window = nil then
      begin
        New(window);
        New(prev);
        New(head);
        New(l_buf);
        New(d_buf);
        New(flag_buf);
      end;
  {$ENDIF}
  end;

  procedure DeAllocateZipArrays;
  begin
  {$IFDEF WIN16}
     windowObj.Free;
     windowObj := nil;
     prevObj.Free;
     prevObj := nil;
     headObj.Free;
     headObj := nil;
     l_bufObj.Free;
     l_bufObj := nil;
     d_bufObj.Free;
     d_bufObj := nil;
     flag_bufObj.Free;
     flag_bufObj := nil;
  {$ELSE}
     System.Dispose(window);
     window := nil;
     System.Dispose(prev);
     prev := nil;
     System.Dispose(head);
     head := nil;
     System.Dispose(l_buf);
     l_buf := nil;
     System.Dispose(d_buf);
     d_buf := nil;
     System.Dispose(flag_buf);
     flag_buf := nil;
  {$ENDIF}
  end;

var
  i: Integer;
  FinishedOK: Boolean;
  SaveSortedFiles: TSortedZip;
  SaveSortMode: TZipSortMode;
  SaveKeepZipOpen: Boolean;
  SaveZipName: String;
  StopNow: Boolean;
  TotalCentralSize: LongInt;
  SaveCentralPos: LongInt;
  tIncludePaths: Integer;

begin  {************** ProcessFiles Main Body ****************}
  Result := 0;
  CancelOperation := False;
  If FilesList = nil then
     exit;
  { Either ZipName or ArchiveStream should be set }
  if ((Trim(ZipName)='') and (ArchiveStream = nil)) then { 09/07/99 2.18+ }
     exit;
  FBusy := True;
  FinishedOK := False;
  CurrentDisk := 0;
  SaveSortedFiles := sortfiles;
  SaveSortMode := SortMode;
  SaveKeepZipOpen := KeepZipOpen;
  KeepZipOpen := True;
  sortfiles := files;
  SortMode := ByNone;

  If Dispose then
     DisposeFiles := TStringList.Create;
  If (not Deleting) and (not StreamZipping) and (not MemZipping) and (FilesList.Count > 0) then
     ExpandForWildCards;

  {  Guesstimate space needed for the Zip Configuration File that will go on first disk of
     a spanned zip file if SaveZipInfoOnFirstDisk is True }
  If (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk) then
   begin
     If StorePaths then
        tIncludePaths := 25 { Change this number to assume different average path length }
     Else
        tIncludePaths := 0;
     { We'll pad a little extra because comments aren't figured in and we want to make sure
       we allow for sector's being allocated on disk }
        MultiZipInfo.SaveOnFirstDisk :=
           MultiZipInfo.SaveOnFirstDisk +
           (FilesList.Count * (SizeOf(central_file_header)+12+tIncludePaths) ) +
           SizeOf(end_of_central) + ecrec.zip_comment_length + 2048; { + 2048 for some padding }
   end;

  If MultiZipInfo.MultiMode = mmSpan then
     AmountToWrite := DiskRoom - MultiZipInfo.SaveOnFirstDisk
  Else If MultiZipInfo.MultiMode = mmBlocks then
     AmountToWrite := MultiZipInfo.FirstBlockSize;

  try  { Moved up to here 4/12/98  2.11 }
  If ((ArchiveIsStream) and (Count > 0))
        or ((File_Exists(ZipName)) and (MultiZipInfo.MultiMode = mmNone)) then
   begin                          { Added Multimode check 06/11/00  2.21b3+ }
     AllocateZipArrays;
     { create new file in temporary directory }
     UsingTempFile := True;
     If not ArchiveIsStream then
      begin
        {PathSize := GetTempPath( SizeOf(tempPathPStr), @tempPathPStr[0] );}
        { Changed to TempFilename  5/5/98  2.12 }
        tmpZipName := TempFilename(TemporaryPath);
        {tmpZipName := StrPas(tempPathPStr) + ExtractFileName( ZipName );}
      end;
     CreateTempZip;
     OpenZip; { open existing zip so we can move existing files }
     MoveExistingFiles;  {Move those existing files}
   end
  Else
   begin
     AllocateZipArrays;
     If not ArchiveIsStream then
        tmpZipName := ZipName;
     UsingTempFile := False;
     CreateTempZip;
   end;

  If (not Deleting) and (FilesList.Count > 0) then
   begin
     StopNow := False;
     If Assigned(FOnStartZipInfo) then
        FOnStartZipInfo( Self, FilesList.Count, TotalUncompressedSize, tmpecrec, StopNow );
     If StopNow then
        {$IFDEF NO_RES}
         raise EUserCanceled.Create('User canceled Zip operation.');
        {$ELSE}
         raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPOPERATION));
        {$ENDIF}
   end;

  If MultiZipInfo.MultiMode <> mmNone then
     TotalUncompressedSize := TotalUnCompressedSize * 2;

  { For each file in the FilesList AddFileToZip }
  If (not Deleting) and (FilesList.Count > 0) then
   begin
     For i := 0 to FilesList.Count-1 do
      begin
        tmpfile_info := TZipHeaderInfo.Create;
        try
           If AddFileToZip(FilesList[i]) then
              AddTheNewFile(i)
           Else
            begin
              tmpfile_info.Free;
              tmpfile_info := nil;
            end;
        except
           tmpfile_info.Free;
           tmpfile_info := nil;
           raise;
        end;
      end;
   end;  { If not Deleting }
  tmpecrec.offset_central := zfile.Position;
  tmpecrec.start_central_disk := CurrentDisk;
  totalCentralSize := 0;
  saveCentralPos := tmpecrec.offset_central;
  For i := 0 to tmpfiles2.Count-1 do
   begin
     tmpfile_info := tmpfiles2.Items[i] as TZipHeaderInfo;
     If (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft < tmpfile_info.CentralSize) then
      begin
        Inc(TotalCentralSize,zfile.Position - saveCentralPos);
        saveCentralPos := 0;
        NextPart;
        If i = 0 then
         begin
           tmpecrec.offset_central := 0;
           tmpecrec.start_central_disk := CurrentDisk;
         end;
      end;
     tmpfile_info.SaveCentralToStream( zfile );
   end;
  Inc(TotalCentralSize,zfile.Position - saveCentralPos);
  tmpecrec.size_central := TotalCentralSize;
  If (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft < tmpecrec.EndCentralSize) then
     NextPart;
  tmpecrec.this_disk := CurrentDisk;
  tmpecrec.SaveToStream(zfile);
  If MultiZipInfo.MultiMode = mmSpan then
     LabelDisk;
  FinishedOK := True;
  finally
   DeAllocateZipArrays;
   If (not ArchiveIsStream) then
    begin
     zfile.Free;   { close the temp zip file }
     zfile := nil;
    end;
   If FinishedOK then
    begin
     If (not ArchiveIsStream) and (not CreatingSFX) then
        SaveZipName := ZipName;
     If (not CreatingSFX) and ((not ArchiveIsStream) and (UsingTempFile)) then
        ClearZip;
     If (MultiZipInfo.MultiMode = mmBlocks) then
      begin
        If (CurrentDisk > 0) then
           ZipName := ChangeFileExt(SaveZipName,'.'+Format('%3.3d',[CurrentDisk+1]))
        Else
         begin  { No need for the multi file extention so change back to .zip }
           ZipName := SaveZipName;
           SaveZipName := ChangeFileExt(SaveZipName,'.'+Format('%3.3d',[CurrentDisk+1]));
           RenameFile(SaveZipName, ZipName);
         end;
      end
     Else If (not ArchiveIsStream) and (not CreatingSFX) then
        ZipName := SaveZipName;
     If (UsingTempFile) then
        MoveTempFile
     Else If ArchiveIsStream then
        zfile := nil;  {2/11/98}
     If (Dispose) then
        DisposeOfFiles;

     If not CreatingSFX then
      begin    { We'll point everyting to the newly created information }
        ecrec.Assign( tmpecrec );
        files := tmpfiles2;
        sortfiles := files;
        SortMode := ByNone;
      end
     Else  { We're going back to the same zip file }
      begin
        tmpfiles2.Free;
        tmpfiles2 := nil;
        sortfiles := SaveSortedFiles;
      end;

     If (not ArchiveIsStream) and (not CreatingSFX) then
        filesDate := FileDate( ZipName );
     If (SaveSortMode <> ByName) and (not CreatingSFX) then
        Sort(SaveSortMode)
     Else If (not CreatingSFX) then
      begin
        sortfiles := tmpfiles;  { already sorted by name }
        tmpfiles := nil;
      end;
     WriteNumDisks( CurrentDisk+1 );

     If (MultiZipInfo.MultiMode <> mmNone) and (Assigned(FOnTotalPercentDone)) then
        OnTotalPercentDone(self, 100);   { To be sure. 5/23/99 2.18+}

     If (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk)
        and (ecrec.this_disk > 0) then
     begin
        If MultiZipInfo.MultiMode = mmSpan then
        begin
           AskForNewDisk(1);  { Ask for 1st disk }
           {$IFNDEF KPSMALL}
           Screen.Cursor := crHourGlass;
           {$ENDIF}
        end;
        SaveZipInfoToFile(ChangeFileExt(ZipName,'.zfc'));
        {$IFNDEF KPSMALL}
        If MultiZipInfo.MultiMode = mmSpan then
        Screen.Cursor := crDefault;
        {$ENDIF}
     end;

   end
   Else
    begin
     tmpfiles2.Free;
     tmpfiles2 := nil;
     SysUtils.DeleteFile( tmpZipName );
    end;

   SortMode := SaveSortMode;
   KeepZipOpen := SaveKeepZipOpen;
   tmpfiles.Free;
   tmpfiles := nil;
   tmpecrec.Free;
   tmpecrec := nil;
   CloseZip;
   If ArchiveIsStream then
     GetFileInfo(theZipFile);

   FBusy := False;
   FilesList.Clear;  { 6/27/99 2.18+ }
  end;
end;

procedure TVCLZip.CreateTempZip;
begin
  If MultiZipInfo.MultiMode = mmBlocks then
     tmpZipName := ChangeFileExt(tmpZipName,'.'+Format('%3.3d',[CurrentDisk+1]));
  If not ArchiveIsStream then
     zfile := TLFNFileStream.CreateFile( tmpZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize )
  Else
   begin
     If UsingTempFile then
        zfile := TMemoryStream.Create
     Else
        zfile := theZipFile;   {2/11/98}
   end;
  If CreatingSFX then
     zfile.CopyFrom( SFXStubFile, SFXStubFile.Size );
  tmpfiles := TSortedZip.Create( DupError );
  tmpfiles.SortMode := ByName;
  tmpfiles.DestroyObjects := False;
  tmpfiles2 := TSortedZip.Create( DupError );
  tmpfiles2.SortMode := ByNone;
  tmpecrec := TEndCentral.Create;
  If (UsingTempFile) or (ecrec.Modified) then
   begin
     tmpecrec.Assign( ecrec );
     If (tmpecrec.zip_comment_length > 0) and (tmpecrec.ZipComment = nil) then
        tmpecrec.ZipComment := StrToPChar(ZipComment);
     tmpecrec.num_entries := 0;
     tmpecrec.num_entries_this_disk := 0;
     tmpecrec.Modified := False;
   end;
end;

function TVCLZip.DiskRoom: BIGINT;
  var
     Disk: Byte;
  begin
     If ZipName[2] <> ':' then
        Disk := 0
     Else
      begin
        Disk := Ord(ZipName[1])-64;
        If Disk > 32 then
           Dec(Disk,32);
      end;
     Result := DiskFree(Disk);
  end;

function TVCLZip.RoomLeft: BIGINT;
begin
  Result := AmountToWrite - zfile.Size;
end;

procedure TVCLZip.LabelDisk;
var
  Disk: String;
  NewLabel: String;
  {Rslt: LongBool;}
begin
  If (MultiZipInfo.MultiMode = mmSpan) and  (MultiZipInfo.WriteDiskLabels) then
   begin
     Disk := ZipName[1];
     Disk := UpperCase(Disk);
     If (Disk = 'A') or (Disk = 'B') then  { Only label floppies }
      begin
        Disk := Disk + ':\';
        NewLabel := 'PKBACK# ' + Format('%3.3d',[CurrentDisk+1]);
   {Rslt :=} SetVolLabel(Disk, NewLabel);
      end;
   end;
end;

procedure TVCLZip.NextPart;
begin
 If MultiZipInfo.MultiMode <> mmNone then
 begin
  If MultiZipInfo.MultiMode = mmSpan then
   begin
     If Assigned(FOnGetNextDisk) then
      begin
        zfile.Free;
        zfile := nil;
        LabelDisk; { Label disk before they change it }
        OnGetNextDisk(Self, CurrentDisk+2, tmpZipName);
        If tmpZipName = '' then
           {$IFDEF NO_RES}
            raise EUserCanceled.Create('User canceled Zip operation.');
           {$ELSE}
            raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPOPERATION));
           {$ENDIF}
        Inc(CurrentDisk);
        if FileExists(tmpZipName) then
           SysUtils.DeleteFile(tmpZipName);  { 10/19/99  2.20b3+ }
        if Assigned(FOnPrepareNextDisk) then
           FOnPrepareNextDisk( self, CurrentDisk+1 );
        AmountToWrite := DiskRoom;
      end
   end
  Else
   begin
     zfile.Free;
     zfile := nil;
     Inc(CurrentDisk);
     tmpZipName := ChangeFileExt(tmpZipName, '.'+Format('%3.3d',[CurrentDisk+1]));
     AmountToWrite := MultiZipInfo.BlockSize;
   end;
  zfile := TLFNFileStream.CreateFile( tmpZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize );
  AmountWritten := 0;
  tmpecrec.num_entries_this_disk := 0;
 end;
end;

function TVCLZip.AddFileToZip( FName: String ): Boolean;
var
  SavePos: LongInt;
  tmpDir: String;
  Idx: Integer;
  Skip: Boolean;
  {tempPathPStr: array [0..PATH_LEN] of char;}
  {PathSize: LongInt;}

  procedure CalcFileCRC;
  { Modified to use a PChar for cbuffer 4/12/98  2.11 }
  const
      {BLKSIZ = OUTBUFSIZ;}
      BLKSIZ = DEF_BUFSTREAMSIZE;
  var
     cbuffer: PChar;
     AmountRead: LongInt;
     AmtLeft: LongInt;
  begin
     AmtLeft := 0;
     cbuffer := nil;

     If (not MemZipping) then
      GetMem(cbuffer,BLKSIZ);
     try
        Crc32Val := $FFFFFFFF;
        If (MemZipping) then
         begin
           cbuffer := MemBuffer;
           AmountRead := kpmin(MemLen,BLKSIZ);
           AmtLeft := MemLen - AmountRead;
         end
        Else
        AmountRead := IFile.Read(cbuffer^, BLKSIZ);
        While AmountRead <> 0 do
         begin
           Update_CRC_buff(BytePtr(cbuffer), AmountRead);
           If (MemZipping) then
            begin
              Inc(cbuffer, AmountRead);
              AmountRead := kpmin(AmtLeft, BLKSIZ);
              { Inc(cbuffer, AmountRead); } { Moved up 2 lines 5/15/00 2.20++ }
              Dec(AmtLeft, AmountRead);
            end
           Else
           AmountRead := IFile.Read(cbuffer^, BLKSIZ);
         end;
         If (not MemZipping) then
         IFile.Seek(0, soFromBeginning);
     finally
         If (not MemZipping) then
         FreeMem(cbuffer,BLKSIZ);
     end;
  end;

  procedure SaveMFile;
  var
     AmtToCopy: LongInt;
     TotalAmtToCopy: LongInt;
     progressAmt: LongInt;
     progressDone: LongInt;
     progressPartition: LongInt;
     Percent: LongInt;
  const
       SPAN_BUFFER_SIZE = $4000;
  begin
     progressDone := 0;
     progressAmt := 0;
     If RoomLeft <= 0 then  { changed to <= 05/23/00  2.21PR2+ }
        NextPart;
     If Assigned(FOnFilePercentDone) then
      begin
        progressAmt := tmpfile_info.uncompressed_size + mfile.Size;
        progressDone := tmpfile_info.uncompressed_size;
      end;
     If Assigned(FOnTotalPercentDone) then {Need to adjust for the diff since guessed}
       TotalUnCompressedSize := TotalUnCompressedSize-(tmpfile_info.uncompressed_size-mfile.Size);
     mfile.Seek(0, soFromBeginning);
     TotalAmtToCopy := mfile.Size;
     AmtToCopy := kpmin( RoomLeft, TotalAmtToCopy );
     If (mfile.Size = 0) then
        AmtToCopy := 0;
     While (TotalAmtToCopy > 0) and (AmtToCopy > 0) do
      begin
        Dec(TotalAmtToCopy,AmtToCopy);
        If Assigned(FOnFilePercentDone) or Assigned(FOnTotalPercentDone) then
         begin
           While (AmtToCopy > 0) do
            begin
              progressPartition := kpmin(SPAN_BUFFER_SIZE, AmtToCopy);
              zfile.CopyFrom( mfile, progressPartition );
              Inc(progressDone, progressPartition);
              If Assigned(FOnFilePercentDone) then
               begin
                 Percent := CRate( progressAmt, progressDone );
                 OnFilePercentDone( self, Percent );
               end;
              If Assigned(FOnTotalPercentDone) then
               begin
                 TotalBytesDone := TotalBytesDone + progressPartition;
                 Percent := CBigRate( TotalUncompressedSize, TotalBytesDone );
                 OnTotalPercentDone( self, Percent );
               end;
              Dec(AmtToCopy,progressPartition);
            end;
         end
        Else
           zfile.CopyFrom( mfile, AmtToCopy );
        If (TotalAmtToCopy > 0) or (RoomLeft <= 0) then
           NextPart;
        AmtToCopy := kpmin( RoomLeft, TotalAmtToCopy );
      end;
  end;

  procedure StoreFile;
  const
     BLKSIZ = OUTBUFSIZ;
  var
     storeBuf: BytePtr;
     bytesRead: LongInt;
  begin
     GetMem(storeBuf, BLKSIZ);
     try
         bytesRead := file_read(storeBuf,BLKSIZ);
         While bytesRead > 0 do
          begin
           zfwrite(storeBuf,1,bytesRead);
           bytesRead := file_read(storeBuf,BLKSIZ);
          end;
     finally
        FreeMem(storeBuf,BLKSIZ);
     end;
  end;

var
  tmpRootDir: String;
  DrivePart:  String;
  IsDir:      Boolean;
  tmpDirName: String;
  SearchRec:  TSearchRec;
  Retry:      Boolean;

begin   { ************* AddFileToZip Procedure ***************** }
  Result := False;
  FileBytes := 0;
  IFileName := FName;
  tmpRootDir := RootDir; { 5/3/98 2.12 }
  If FName[Length(FName)] = '\' then
     IsDir := True
  Else
     IsDir := False;

  If IsDir then
   begin
     If (StreamZipping) or (MemZipping) or (not DirExists(FName)) then
        tmpfile_info.last_mod_file_date_time := DateTimeToFileDate( Now )
     Else
      begin
        tmpDirName := Copy(FName,1,Length(FName)-1);
        If FindFirst( tmpDirName, faAnyFile, SearchRec ) = 0 then
           tmpfile_info.last_mod_file_date_time := SearchRec.Time
        Else
           tmpfile_info.last_mod_file_date_time := DateTimeToFileDate( Now );
      end;
     tmpfile_info.uncompressed_size := 0;
     tmpfile_info.compressed_size := 0;
     tmpfile_info.compression_method := STORED;
     tmpfile_info.internal_file_attributes := BINARY; { assume binary if STOREing - for now. 10/18/98 }
     tmpfile_info.crc32 := 0;
   end
  Else If (not StreamZipping) and (not MemZipping) and (not IsDir) then
   begin
     If not FileExists( FName ) then
        exit;
     tmpfile_info.external_file_attributes := FileGetAttr( FName );
     Retry := False;
     Repeat
     try
        {IFile := TLFNFileStream.CreateFile( FName, fmOpenRead or fmShareDenyNone, False );}
        IFile := TLFNFileStream.CreateFile( FName, fmOpenRead or FFileOpenMode, False, BufferedStreamSize );
        Retry := False;
     except
        Retry := False;
        If Assigned( FOnSkippingFile ) then
           FOnSkippingFile( self, srFileOpenError, FName, -1, Retry );
        If not Retry then
           exit;
     end;
     Until (Retry = False);
     tmpfile_info.last_mod_file_date_time := FileGetDate( TLFNFileStream(IFile).Handle );
  end
  Else
   begin
     If (StreamZipping) then
        IFile := ZipStream;
     tmpfile_info.last_mod_file_date_time := DateTimeToFileDate( Now );
   end;
  mfile := nil;
 try
  If (MemZipping) and (not IsDir) then
     tmpfile_info.uncompressed_size := MemLen
  Else If (not IsDir) then
     tmpfile_info.uncompressed_size := IFile.Size;
  {$IFDEF WIN32}
  If FStore83Names then
   begin
    FName := LFN_ConvertLFName(FName,SHORTEN);
    If tmpRootDir <> '' then
     tmpRootDir := LFN_ConvertLFName(RootDir,SHORTEN);
   end;
  {$ELSE}
  {$IFNDEF NOLONGNAMES}  { 4/12/98 2.11 }
  If (not FStore83Names) and (OSVersion > 3) then
   begin
     FName := LFN_ConvertLFName(FName,LENGTHEN);
     If tmpRootDir <> '' then
        tmpRootDir := LFN_ConvertLFName(RootDir,LENGTHEN);
   end;
  {$ENDIF}
  {$ENDIF}
  OEMFilter(FName);
  If (not IsDir) then
     tmpfile_info.filename := ExtractFileName(FName)
  Else
     tmpfile_info.filename := '';

     tmpfile_info.relative_offset := zfile.Position;

     tmpfile_info.internal_file_attributes := UNKNOWN;
     tmpfile_info.disk_number_start := CurrentDisk;
  If FStorePaths then
   begin
     tmpDir := ExtractFileDir(Fname) + '\';
     If RightStr( tmpDir, 2 ) = '\\' then      {Incase it's the root directory 3/10/98 2.03}
        SetLength(tmpDir, Length(tmpDir)-1);
     If (tmpRootDir <> '') and (RelativePaths) and (AnsiCompareText(LeftStr(tmpDir,Length(tmpRootDir)),tmpRootDir)=0) then
      begin
        If (AnsiCompareText(tmpRootDir,tmpDir)=0) then
           tmpDir := ''
        Else
           Delete( tmpDir, 1, Length(tmpRootDir));
      end;
     { added the following 3/26/98 to handle UNC paths. 2.1 }
     If {(not RelativePaths) and} (not FStoreVolumes) and (tmpDir <> '') then
      begin
        DrivePart := ExtractFileDrive(tmpdir);
        if DrivePart <> '' then
           Delete(tmpdir, 1, Length(DrivePart));
        if LeftStr(tmpdir,1) = '\' then
           Delete(tmpdir,1,1);
      end;
  tmpfile_info.directory := tmpDir;
     {The filename_length now gets set automatically when setting the directory
      or filename  Nov 16, 1997 KLB }
  {tmpfile_info.filename_length := Length(tmpfile_info.directory+tmpfile_info.filename);}
  end;
   {The filename_length now gets set automatically when setting the directory
    or filename  Nov 16, 1997 KLB }
 {Else
  tmpfile_info.filename_length := Length(tmpfile_info.filename);}

  { If a file by the same name is already archived then skip this one }
  If tmpfiles.Search( Pointer(tmpfile_info), Idx ) then
   begin
     Result := False;
     { This is sort of a cludge but it works for now }
     If Assigned( FOnSkippingFile ) then
      begin
        FOnSkippingFile( self, srNoOverwrite, FName, -1, Retry );
      end;
     If (not StreamZipping) and (not MemZipping) and (not IsDir) then
      begin
        TotalUncompressedSize := TotalUncompressedSize - IFile.Size;
        IFile.Free;
        IFile := nil;
      end;
     exit;
   end;

  Skip := False;
  If Assigned( FOnStartZip ) then
     FOnStartZip( Self, FName, tmpfile_info, Skip );
  If Skip then
   begin
     If (not StreamZipping) and (not MemZipping) and (not IsDir) then
      begin
        TotalUncompressedSize := TotalUncompressedSize - IFile.Size;
        IFile.Free;
        IFile := nil;
      end;
     Result := False;
     exit;
   end;

  {Save local header for now, will update when done}
  If (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft <= tmpfile_info.LocalSize) { and (not IsDir) } then
   begin                                  { 2/1/98 Changed the above from < to <= }
     NextPart;
     tmpfile_info.disk_number_start := CurrentDisk; { 2/1/98 }
     tmpfile_info.relative_offset := 0;  { Added 05/23/00 2.21PR2+ }
   end;
  If (MultiZipInfo.MultiMode <> mmNone) and (not IsDir) then
    begin
     {PathSize := GetTempPath( SizeOf(tempPathPStr), @tempPathPStr[0] );}
     { Changed to TempFilename  5/5/98  2.12 }
     mZipName := TempFilename(TemporaryPath);
     {mZipName := StrPas(tempPathPStr) + 'KPy76p09.tmp';}
     mfile := TLFNFileStream.CreateFile( mZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize );
    end
  else  { Added this else 2/5/00 2.20+ }
     tmpfile_info.SaveLocalToStream( zfile );
  {SavePos := zfile.Position;}
  If (IsDir) then
   begin
     If Assigned(FOnEndZip) then
        FOnEndZip( Self, FName, 0, 0, 0 );
     Result := True;
     exit;
   end;

  If (Password <> '') and (not IsDir) then
   begin
     CalcFileCRC;
     Crc32Val := not Crc32Val;
     tmpfile_info.crc32 := Crc32Val;
     crypthead( Password );
   end;
  Crc32Val := $FFFFFFFF;
  {$IFDEF KPDEMO}
     If not DR then
        tmpfile_info.filename := '';
  {$ENDIF}

  {*************** HERE IS THE CALL TO ZIP ************************}
  If (PackLevel = 0) or (IsInNoCompressList(tmpfile_info.filename)) then  { 10/23/98  2.16+ }
   begin
     StoreFile;
     tmpfile_info.compressed_size := tmpfile_info.uncompressed_size;
     tmpfile_info.compression_method := STORED;
     tmpfile_info.internal_file_attributes := BINARY; { assume binary if STOREing - for now. 10/18/98 }
   end
  Else
     tmpfile_info.compressed_size := Deflate;  { Compress the file!! }
  {****************************************************************}

{  Assert(  tmpfile_info.compressed_size = zfile.Seek(0, soFromCurrent) - SavePos, }
{           'Deflate returned wrong compressed size.');         }
  Crc32Val := not Crc32Val;
  SavePos := zfile.Position;
  zfile.Seek(tmpfile_info.relative_offset, soFromBeginning);
  tmpfile_info.crc32 := Crc32Val;
  If Password <> '' then
   begin  { Mark the file as encrypted and modify compressed size
            to take into account the 12 byte encryption header    }
     tmpfile_info.general_purpose_bit_flag := tmpfile_info.general_purpose_bit_flag or 1;
     tmpfile_info.compressed_size := tmpfile_info.compressed_size + 12;
   end;
  { Save the finalized local header }
  tmpfile_info.SaveLocalToStream( zfile );
  If MultiZipInfo.MultiMode <> mmNone then
     SaveMFile
  Else
     zfile.Seek(SavePos, soFromBeginning);
  Result := True;
 finally
  mfile.Free;
  mfile := nil;
  SysUtils.DeleteFile( mZipName );
  If (not StreamZipping) and (not MemZipping) then
   begin
     IFile.Free;
     IFile := nil;
   end;
 end;

 { Added 4-Jun-98 by SPF to support reset of archive bit after the file
      has been zipped }
 if FResetArchiveBitOnZip and (not StreamZipping) and (not MemZipping) then
  ResetArchiveBit(FName);

  If Assigned(FOnEndZip) then
     FOnEndZip( Self, FName, tmpfile_info.uncompressed_size,
                 tmpfile_info.compressed_size, zfile.Size );

end;

procedure TVCLZip.CryptHead( passwrd: String );
var
  i: Integer;
  c: Byte;
begin
  Init_Keys( passwrd );
  Randomize;
  For i := 1 to 10 do
   begin
     c := zencode( Byte(random($7FFF) shr 7) );
     If MultiZipInfo.MultiMode = mmNone then
        zfile.Write( c, 1 )
     Else
        mfile.Write( c, 1 );
   end;
  c := zencode(LOBYTE(HIWORD(tmpfile_info.crc32)));
  If MultiZipInfo.MultiMode = mmNone then
     zfile.Write(c,1)
  Else
     mfile.Write(c,1);
  c := zencode(HIBYTE(HIWORD(tmpfile_info.crc32)));
  If MultiZipInfo.MultiMode = mmNone then
     zfile.Write(c,1)
  Else
     mfile.Write(c,1);
end;


procedure TVCLZip.MoveFile( Index: Integer );
var
  lrc: local_file_header;
begin
  theZipFile.Seek( tmpfile_info.relative_offset, soFromBeginning );
  { Filename length may have changed from original so we have to get }
  { it from the original local file header - 10/29/97 KLB }
  theZipFile.Read( lrc, SizeOf(local_file_header));
  theZipFile.Seek( lrc.filename_length, soFromCurrent );
  tmpfile_info.Lextra_field_length := lrc.extra_field_length; { 11/04/99 2.20b4+ }
  tmpfile_info.relative_offset := zfile.Position;
  tmpfile_info.SaveLocalToStream( zfile );
  {Added following test for zero length because it was doubling archive size - 01/21/97 KLB}
  If (tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length) > 0 then
     zfile.CopyFrom(theZipFile, tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length);
end;

procedure TVCLZip.MoveTempFile;
begin
  If ArchiveIsStream then
   begin
     theZipFile.Free;
     theZipFile := zfile;
     zfile := nil;
   end
  Else
   begin
     If SaveNewName = '' then
      begin
        SysUtils.DeleteFile( ZipName );
        FileCopy( tmpZipName, ZipName );
      end
     Else
        FileCopy( tmpZipName, SaveNewName );
     SysUtils.DeleteFile( tmpZipName );
   end;
end;

function TVCLZip.DeleteEntries: Integer;
begin
  if NumSelected > 0 then
     FilesList.Clear;
  Deleting := True;
  Result := ProcessFiles;
  Deleting := False;
end;

procedure TVCLZip.SetZipName( ZName: String );
begin
  if not (csDesigning In ComponentState) then
   begin
     If AnsiCompareText(ZName,ZipName) = 0 then
        exit;
     If ecrec.Modified then
      begin
        FilesList.Clear;
        ProcessFiles;
        ecrec.Modified := False;
      end;
   end;
  inherited SetZipName( ZName );
end;

procedure TVCLZip.SetDateTime(Index: Integer; DT: TDateTime );
var
 finfo: TZipHeaderInfo;
begin
  If (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      finfo.SetDateTime(DT);
      ecrec.Modified := True;
   end
  else
     {$IFDEF NO_RES}
      Raise EListError.CreateFmt('Index %d is out of range',[Index]);
     {$ELSE}
      Raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE),[Index]);
     {$ENDIF}
end;

procedure TVCLZip.SaveModifiedZipFile;
begin
  If ecrec.Modified then
   begin
     FilesList.Clear;
     ProcessFiles;
     ecrec.Modified := False;
     ReadZip;
   end;
end;

function TVCLZip.GetIsModified: Boolean;
begin
  Result := ecrec.Modified;
end;

function TVCLZip.FixZip( InputFile, OutputFile: String ): Integer;
var
  Canceled: Boolean;
  tmpFilesList: TStrings;
  i: Integer;
  {$IFNDEF WIN32}
  j: Boolean;
  {$ENDIF}
begin
  Canceled := False;
  Result := 0;
  If InputFile <> '' then
     ZipName := InputFile
  Else
  If (Count = 0) or (not ZipIsBad) then
   begin
    try
     ZipName := ExtractFileDir(ZipName) + '\?';
    except
     On EUserCanceled do
      exit;
     Else
         raise;    { If not EUserCanceled then re-raise the exception }
    end;
     Fixing := True;
     {$IFNDEF KPSMALL}
     Screen.Cursor := crHourGlass;
     {$ENDIF}
     try
        ReadZip;
        for i := 0 to Count-1 do
           {$IFNDEF WIN32} j := {$ENDIF}  FileIsOK[i];
     finally
        {$IFNDEF KPSMALL}
        Screen.Cursor := crDefault;
        {$ENDIF}
     end;
     Fixing := False;
   end;
  SaveNewName := OutputFile;
  {$IFNDEF KPSMALL}
  If OutputFile <> '' then
     SaveNewName := OutputFile
  Else
  begin
  OpenZipDlg := TOpenDialog.Create(Application);
  try
     {$IFDEF NO_RES}
      OpenZipDlg.Title := 'Select a new name for the fixed file.';
      OpenZipDlg.Filter := 'Zip Files (*.ZIP)';
     {$ELSE}
      OpenZipDlg.Title := LoadStr(IDS_NEWFIXEDNAME);
      OpenZipDlg.Filter := LoadStr(IDS_ZIPFILESFILTER);
     {$ENDIF}
  If DirExists(ExtractFilePath(ZipName)) then
   OpenZipDlg.InitialDir := ExtractFilePath(ZipName)
  Else
      OpenZipDlg.InitialDir := 'C:\';
  If OpenZipDlg.Execute then
   SaveNewName := OpenZipDlg.Filename
  Else
   Canceled := True;
  finally
  OpenZipDlg.Free;
  end;
  end;
  {$ENDIF}
  If not Canceled then
   begin
     tmpFilesList := TStringList.Create;
     tmpFilesList.Assign(FilesList);
     FilesList.Clear;
     {$IFNDEF KPSMALL}
     Screen.Cursor := crHourGlass;
     {$ENDIF}
     try
        Result := ProcessFiles;
     finally
        {$IFNDEF KPSMALL}
        Screen.Cursor := crDefault;
        {$ENDIF}
        FilesList.Assign(tmpFilesList);
        tmpFilesList.Free;
     end;
     ZipName := SaveNewName;
   end;
  SaveNewName := '';
end;

function TVCLZip.MakeNewSFX( SFXStub: String; FName: String; Options: PChar; OptionsLen: Integer): Integer;
{ Assumed that FilesList will have files to be included in the newly created SFX }
var
  SFXFile: TLFNFileStream;
begin
  result := 0;
  If (FName = '') or (SFXStub = '') then
     exit;
  If FileExists(FName) and (AnsiCompareText(ExtractFileExt(FName),'.zip')=0) then
     SaveNewName := ChangeFileExt(FName, '.exe');
  ZipName := FName;
  if (OptionsLen > 0) then
   begin
     SFXFile := TLFNFileStream.CreateFile(SFXStub, fmOpenRead, False, BufferedStreamSize);  { Get the Stub }
     SFXStubFile := TLFNFileStream.CreateFile(TemporaryPath+'tmpstub.exe', fmCreate, FFlushFilesOnClose,
                                               BufferedStreamSize);
     SFXStubFile.CopyFrom(SFXFile,SFXFile.Size);
     SFXStubFile.Write(Options^,OptionsLen);
     SFXFile.Free;
     SFXStubFile.Seek(0,soFromBeginning);
   end
  else
     SFXStubFile := TLFNFileStream.CreateFile(SFXStub, fmOpenRead, False, BufferedStreamSize);

  try
     CreatingSFX := True;
     Result := Zip;
     If (AnsiCompareText(ExtractFilename(FName),'.zip') = 0) then
        ChangeFileExt(FName,'.exe');  
  finally
     CreatingSFX := False;
     SFXStubFile.Free;
     SFXStubFile := nil;
     SaveNewName := '';
     if (OptionsLen > 0) or (Options = nil) then
        SysUtils.DeleteFile(TemporaryPath+'tmpstub.exe');
  end;
end;

procedure TVCLZip.MakeSFX( SFXStub: String; ModHeaders: Boolean );
begin
  If ZipName = '' then
     exit;
  SFXStubFile := TLFNFileStream.CreateFile(SFXStub, fmOpenRead, False, BufferedStreamSize);
  try
     CreatingSFX := True;
     SaveNewName := ChangeFileExt( ZipName, '.EXE');
     ProcessFiles;
  finally
     CreatingSFX := False;
     SaveNewName := '';
     SFXStubFile.Free;
     SFXStubFile := nil;
  end;
end;

procedure TVCLZip.SFXToZip(DeleteSFX: Boolean);
var
  SaveZipName: String;
begin
  PreserveStubs := False;
  SaveZipName := ZipName;
  SaveNewName := ChangeFileExt(ZipName,'.zip');
  FilesList.Clear;
  ProcessFiles;
  ClearZip;
  ZipName := SaveNewName;
  SaveNewName := '';
  ReadZip;
  If DeleteSFX then
     DeleteFile(SaveZipName);
  PreserveStubs := True;
end;

procedure TVCLZip.SaveZipInfoToFile( Filename: String );
var
  saveFile: TFileStream;
  i: Integer;
begin
  try
     saveFile := TFileStream.Create(Filename, fmCreate);
  except
     {$IFNDEF KPSMALL}
     ShowMessage('Unable to create Zip Configuration File to disk');
     {$ELSE}
     pMsgDlg('Unable to save Zip Configuration File to disk','Create Error',MB_OK);
     {$ENDIF}
     exit;
  end;

  try
     try
        For i := 0 to files.Count-1 do
        begin
           tmpfile_info := tmpfiles2.Items[i] as TZipHeaderInfo;
           tmpfile_info.SaveCentralToStream( saveFile );
        end;
        ecrec.SaveToStream(saveFile);
     except
        {$IFNDEF KPSMALL}
        ShowMessage('Unable to save Zip Configuration File to disk');
        {$ELSE}
        pMsgDlg('Unable to save Zip Configuration File to disk','Create Error',MB_OK);
        {$ENDIF}
     end;
  finally
     saveFile.Free;
  end;
end;


{***********************************************************************
 * If requested, encrypt the data in buf, and in any case call fwrite()
 * with the arguments to zfwrite().  Return what fwrite() returns.
 *}
function TVCLZip.zfwrite(buf: BytePtr; item_size, nb: Integer): LongInt;
{    voidp *buf;               /* data buffer */
    extent item_size;         /* size of each item in bytes */
    extent nb;                /* number of items */
    FILE *f;                  /* file to write to */  }
var
  size:   LongInt;
  p:      BytePtr;
  tAmountToWrite: LongInt;
begin
    Result := 0;
    if (Password <> '') then       { key is the global password pointer }
     begin
        p := buf;               { steps through buffer }
        { Encrypt data in buffer }
        for size := item_size*nb downto 1 do
         begin
            p^ := zencode(p^);
            Inc(p);
         end;
     end;

    { Write the buffer out }
    tAmountToWrite := item_size*nb;
    If MultiZipInfo.MultiMode = mmNone then
     Inc(Result,zfile.Write( buf^, tAmountToWrite )) {return fwrite(buf, item_size, nb, f);}
    Else
     Inc(Result,mfile.Write( buf^, tAmountToWrite ));
    if (Result <> tAmountToWrite) then
     {$IFDEF NO_RES}
      Raise ENotEnoughRoom.Create('Not enough room to write archive');
     {$ELSE}
      Raise ENotEnoughRoom.Create(LoadStr(IDS_NOTENOUGHROOM));
     {$ENDIF}
    Inc(AmountWritten,Result);
    If DoProcessMessages then
      begin
        {$IFNDEF KPSMALL}
         Application.ProcessMessages;
        {$ELSE}
         YieldProcess;
        {$ENDIF}
        If CancelOperation then
         begin
           CancelOperation := False;
           {$IFDEF NO_RES}
            raise EUserCanceled.Create('User Aborted Operation');
           {$ELSE}
            raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
           {$ENDIF}
         end;
      end;
end;

function TVCLZip.zencode(c: Byte): Byte;
var
  temp: Byte;
begin
  temp := decrypt_byte;
  update_keys(Char(c));
  Result := temp xor c;
end;

function TVCLZip.file_read( w: BytePtr; size: usigned ): LongInt;
var
  Percent: LongInt;
begin
  If (MemZipping) then        { 7/13/98  2.14 }
   begin
     Result := kpmin(MemLeft,size);
     If (Result > 0) then
      begin
        MoveMemory(w,CurrMem,Result);
        Inc(CurrMem,Result);
        Dec(MemLeft,Result);
      end;
   end
  Else
  Result := IFile.Read( w^, size );
  If Result = 0 then
   begin
 {    If isize <> tmpfile_info.uncompressed_size then
        ShowMessage('isize <> amtread - ' + IFileName);  }
     exit;
   end;
 If Assigned(FOnFilePercentDone) then
   begin
     Inc(FileBytes, Result);
     Percent := CRate( tmpfile_info.uncompressed_size, FileBytes );
     If MultiZipInfo.MultiMode <> mmNone then
        Percent := Percent div 2;  {only half the work done, still have to copy to diskette}
     OnFilePercentDone( self, Percent );
   end;
  If Assigned(FOnTotalPercentDone) then
   begin
     TotalBytesDone := TotalBytesDone + Result;
     Percent := CBigRate( TotalUncompressedSize, TotalBytesDone );
     OnTotalPercentDone( self, Percent );
   end;
  Update_CRC_buff(w, Result);
  Inc(isize, Result);
end;

{ Added 5/5/98 2.12 }
function TVCLZip.TemporaryPath: String;
var
  tempPathPStr: array [0..300] of char;   {Changed to 300 from PATH_LEN  4/15/99  2.17+}
  {PathSize: LongInt;}
begin
  If (FTempPath = '') or (not DirExists(FTempPath)) then
   begin
     {PathSize :=} GetTempPath( SizeOf(tempPathPStr), @tempPathPStr[0] );
     Result := PCharToStr(tempPathPStr);
   end
  Else
     Result := FTempPath;
end;

procedure TVCLZip.SetExcludeList(Value: TStrings);
begin
  FExcludeList.Assign(Value);
end;

procedure TVCLZip.SetNoCompressList(Value: TStrings);
begin
  FNoCompressList.Assign(Value);
end;

{$IFDEF UNDER_DEVELOPMENT}
{ 10/24/99 2.20b3+ }
procedure TVCLZip.GetRawCompressedFile( Index: Integer; var Header: TZipHeaderInfo; ZippedStream: TStream );
var
 finfo: TZipHeaderInfo;
begin
 If (Index > -1) and (Index < Count) then
    finfo := sortfiles.Items[Index] as TZipHeaderInfo
  else
     {$IFDEF NO_RES}
      Raise EListError.CreateFmt('Index %d is out of range',[Index]);
     {$ELSE}
      Raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE),[Index]);
     {$ENDIF}
  Header := TZipHeaderInfo.Create;
  Header.Assign(finfo);
  OpenZip;

end;

{ 10/24/99 2.20b3+ }
procedure TVCLZip.InsertRawCompressedFile( Header: TZipHeaderInfo; ZippedStream: TStream );
begin
end;
{$ENDIF}

{$IFNDEF FULLPACK}
procedure Register;
begin
  RegisterComponents('VCLZip', [TVCLZip]);
end;
{$ENDIF}


{ $Id: VCLZip.pas,v 1.38 2000-12-16 16:50:09-05 kp Exp kp $ }

{ $Log: VCLZip.pas,v $
{ Revision 1.38  2000-12-16 16:50:09-05  kp
{ 2.21 Final Release 12/12/00
{
{ Revision 1.37  2000-06-04 15:51:57-04  kp
{ - Moved call to ExpandForWildcards to before the guess for space needed for zfc file
{ - Fixed so you could have FilePercentDone without needing TotalPercentDone when
{   creating spanned zip files
{ - Fixed so relative_offset set correctly for spanned zips.  Side effect of removing needless
{   write of header.
{
{ Revision 1.36  2000-05-21 18:43:31-04  kp
{ - Fixed bug where file being compressed with password wasn't getting crc checked properly
    in CalcFileCRC if file bigger then BLKSIZ
{ - Modified buffer size in SaveMFile
{
{ Revision 1.35  2000-05-13 16:50:41-04  kp
{ - Changed default for FileOpenMode back to fmShareDenyNone as it was for all versions
{   except for 2.20
{ - Added code to handle new BufferedStreamSize property
{ - Changed BLKSIZE in CalcFileCRC
{ - Fixed problem where driveparts weren't being stripped if relativepaths wat set true.
{ - Removed unnecessary write of header to floppy during spanned zip creation
{ - Added code to report not enough space to write zfc file with KPSMALL set.
{
{ Revision 1.34  1999-12-05 09:33:01-05  kp
{ - Added BIGINT
{ - Changed register to VCLZip palette
{
{ Revision 1.33  1999-11-09 19:40:16-05  kp
{ - Modified to correctly handle extra fields in headers
{
{ Revision 1.32  1999-11-03 17:34:17-05  kp
{ - Moved check for and deletion of existing file on new diskette to come before
{ determination of diskroom.
{
{ Revision 1.31  1999-10-28 17:56:52-04  kp
{ - Added SetDateTime[Index]
{
{ Revision 1.30  1999-10-24 11:01:17-04  kp
{ - Added some things that are still under development and ifdefed out right now.
{
{ Revision 1.29  1999-10-24 09:31:25-04  kp
{ - Added error checking and notification if zcf file can't be created or written to.
{
{ Revision 1.28  1999-10-20 18:14:19-04  kp
{ - added retry parameter to OnSkippingFile
{ - added delete of file if already exists on newly inserted spanned diskette (2.20b3+)
{
{ Revision 1.27  1999-10-17 12:00:30-04  kp
{ - Changed min and max to kpmin and kpmax
{
{ Revision 1.26  1999-10-17 09:29:05-04  kp
{ - Added FileOpenMode property
{
{ Revision 1.25  1999-10-11 20:10:44-04  kp
{ - Some mods and relocations to multizip operations
{ - Added FlushFilesOnClose property
{
{ Revision 1.24  1999-10-10 21:32:41-04  kp
{ - Added capability to Delete Selected files.
{ - Modified calculation for amount of space to save for SaveZipInfoOnFirstDisk
{ - Moved call to OnTotalPercent 100% for multivolume zipfiles
{
{ Revision 1.23  1999-09-16 20:04:23-04  kp
{ - Moved defines to KPDEFS.INC
{
{ Revision 1.22  1999-09-14 21:32:41-04  kp
{ - Added some checks to make sure that either ZipName or ArchiveStream is set.
{ - Moved guess for space to save for first spanned disk for Zip Configuration File
{   to where it would have and effect
{ - Changed name of local variable to tAmountToWrite in zfwrite since it was the same as
{   a class global.
{
{ Revision 1.21  1999-08-25 19:03:42-04  kp
{ - Fixes for D1
{ - Updated Assign methods
{
{ Revision 1.20  1999-08-25 18:00:03-04  kp
{ - Added capability to read multizip file from first disk
{ - Modified so MakeNewSFX could also add an already existing zip file.
{ - Guesstimate room needed on first disk for Zip Configuration File
{
{ Revision 1.19  1999-07-06 19:57:51-04  kp
{ - Added OnUpdate event
{
{ Revision 1.18  1999-07-05 11:24:25-04  kp
{ - Changed AddDirEntries to AddDirEntriesOnRecurse
{ - Modified so FilesList is cleared when zip operations are done
{ - Modifed so it is possible to assign zip comment when creating new archive without
{   having to do it from the OnStartZipInfo event
{
{ Revision 1.17  1999-06-27 10:16:12-04  kp
{ - Fixed problem with adding directories manually to FilesList
{ - Added Assign method
{
{ Revision 1.16  1999-06-18 16:45:58-04  kp
{ - Modified to handle adding directory entries when doing recursive zips (AddDirEntries property)
{
{ Revision 1.15  1999-06-01 21:59:41-04  kp
{ - Fixed SkipIfArchiveBitNotSet
{ - Added a call to OnTotalPercentDone with 100% done after spanning/block zip complete
{ - Added kpDiskFree to try to handle UNC paths but it won't help with that problem
{
{ Revision 1.14  1999-04-24 21:12:28-04  kp
{ - Added MakeNewSFX
{
{ Revision 1.13  1999-04-10 10:18:29-04  kp
{ - Added conditionals to make sure NOLONGNAMES and NODISKUTILS aren't turned on
{  in 32bit.
{ - Added OnZipComplete event
{ - Slight mod to make progress events work for blocked zip creation too
{
{ Revision 1.12  1999-03-30 19:43:24-05  kp
{ - Modified so that defining MAKESMALL will create a much smaller component.
{
{ Revision 1.11  1999-03-22 17:31:44-05  kp
{ - added support for BCB4
{ - moved comments to bottom
{ - moved strings to string table
{
{ Revision 1.10  1999-03-17 17:10:32-05  kp
{ - Changed the name of ExeToZip to SFXToZip.
{ - Added a Boolean parmeter to SFXToZip to tell whether to delete the old sfx file.
{ - Modified to make OnTotalPercentDone work correctly for spanned disk sets.
{
{ Revision 1.9  1999-03-16 20:13:51-05  kp
{ - Added ExeToZip procedure
{
{ Revision 1.8  1999-03-16 19:21:09-05  kp
{ - Modified to make OnFilePercentDone work across the copy of the compressed file to disk
{   when creating a spanned disk set.
{
{ Revision 1.7  1999-02-08 21:41:00-05  kp
{ Modified FixZip to work with D1.
{
{ Revision 1.6  1999-01-12 20:23:34-05  kp
{ -Slight modifications to the precompiler conditionals
{ -Added the PreserveStubs public property
{ }

{ Sat 04 Jul 1998   16:16:01
{ Added SkipIfArchiveBitNotSet property
{ Added ResetArchiveBitOnZip property
}
{
{  Sun 10 May 1998   16:58:46   Version: 2.12
{ - Added TempPath property
{ - Fixed RelativePaths bug
{ - Fixed bug related to files in FilesList that don't exist
}
{
{ Mon 27 Apr 1998   18:22:44   Version: 2.11
{ Added BCB 3 support
{ Invalid Pointer operation bug fix
{ CalcCRC for D1 bug fix
{ Quit during wildcard expansion bug fix
{ Straightened out some conditional directives
}
{
{  Sun 29 Mar 1998   10:51:35  Version: 2.1
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
{   Tue 24 Mar 1998   19:00:22
{ Modifications to allow files and paths to be stored in DOS 
{ 8.3 filename format.  New property is Store83Names.
}
{
{   Wed 11 Mar 1998   21:10:16  Version: 2.03
{ Version 2.03 Files containing many fixes
}

end.

