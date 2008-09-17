unit KpLib;

{$P-}                                                   { turn off open parameters }
{$R-}                                                   { 12/24/98 2.17 }
{$Q-}                                                   { 12/24/98 2.17 }
{$B-} { turn off complete boolean eval }                { 12/24/98  2.17 }
{$V-} { turn off strict var strings }                   { 02/10/99  2.17+ }

interface

{$I KPDEFS.INC}

uses
   {$IFNDEF WIN32}
   WinProcs,
   WinTypes,
   {$IFNDEF NOLONGNAMES}
   kpLName,
   {$ENDIF}
   {$ELSE}
   Windows,
   {$ENDIF}
   {$IFNDEF NOSTREAMBUFF}
   kpSStrm,
   {$ENDIF}
   SysUtils,
   {$IFDEF KPSMALL}
   kpSmall,
   {$ELSE}
   FileCtrl,
   {$ENDIF}
   Classes,
   kpMatch, kpZipObj{$IFNDEF NO_RES}, kpzcnst{$ENDIF};

const
   WILDCARD_RECURSE           = '>';
   WILDCARD_NORECURSE         = '|';

type
   BYTEPTR = ^Byte;
   PSearchRec = ^TSearchRec;
   {$IFNDEF WIN32}
   DWord = LongInt;
   {$ENDIF}

   {$IFDEF NODISKUTILS}
   str11 = string[11];
   {$ENDIF}

   {$IFDEF ISBCB}
   Comp = Double;
   {$ENDIF}

   {$IFNDEF NOSTREAMBUFF}
   TLFNFileStream = class(TS_BufferStream)
      theFile: TFileStream;
      function GetHandle: Integer;
      {$ELSE}
   TLFNFileStream = class(TFileStream)
      {$ENDIF}
   PUBLIC
      constructor CreateFile(const FileName: string; Mode: Word; FlushOut: Boolean;
                             BufSize: Integer);
      destructor Destroy; OVERRIDE;
      {$IFNDEF NOSTREAMBUFF}
      property Handle: Integer READ GetHandle;
      {$ENDIF}
   end;

   TConversionOperation = (SHORTEN, LENGTHEN);

   TSearchData = class(TObject)
   PUBLIC
      Directory: string;
      Pattern: string;
      SearchResult: Integer;
      SearchRec: TSearchRec;
      NoFiles: Boolean;
      procedure Next;
      constructor Create(Path, MatchPattern: string);
      destructor Destroy; OVERRIDE;
   end;

   TDirSearch = class
   PRIVATE
      FDirStack: array[0..20] of TSearchData;
      FCurrentLevel: Integer;
      FPattern: string;
      FRecurse: Boolean;
      FWildDirStack: TStrings;
      FNumWildDirs: Integer;
      FWildDirID: Integer;

      function IsChildDir(SR: TSearchRec): Boolean;
      function IsDir(SR: TSearchRec): Boolean;
   PUBLIC
      constructor Create(const StartingDir, Pattern: string; RecurseDirs: Boolean);
      destructor Destroy; OVERRIDE;
      function NextFile(var SR: TSearchRec): string;
      property Recurse: Boolean READ FRecurse WRITE FRecurse DEFAULT False;
   end;


function kpmin(a, b: BIGINT): BIGINT;
function kpmax(a, b: BIGINT): BIGINT;


function CRate(uc, c: LongInt): LongInt;
function CBigRate(uc, c: Comp): LongInt;
function BlockCompare(const Buf1, Buf2; Count: Integer): Boolean;
function DOSToUnixFilename(fn: PChar): PChar;
function UnixToDOSFilename(fn: PChar): PChar;
function RightStr(str: string; count: Integer): string;
function LeftStr(str: string; count: Integer): string;
function IsWildCard(fname: string): Boolean;
function FileDate(fname: string): TDateTime;
function GoodTimeStamp(theTimeStamp: LongInt): LongInt;

procedure ForceDirs(Dir: string);
function DirExists(Dir: string): Boolean;
function File_Exists(const FileName: string): Boolean;
procedure GetDirectory(D: Byte; var S: string);
procedure ChDirectory(const S: string);
function DoRenameCopy(const FromFile, ToFile: string): boolean;
procedure FileCopy(const FromFile, ToFile: string);
function PCharToStr(CStr: PChar): string;
function StrToPChar(Str: string): PChar;

function GetVolumeLabel(Disk: string): string;
function SetVolLabel(Disk, NewLabel: string): LongBool;

function TempFileName(Pathname: string): string;
procedure OemFilter(var fname: string);

{$IFNDEF Ver100}
procedure Assert(Value: Boolean; Msg: string);
{$ENDIF}

{$IFDEF WIN32}
function StringAsPChar(var S: string): PChar;
{$ELSE}
procedure SetLength(var S: string; NewLength: Integer);
function Trim( const S: string ): String;
procedure ZeroMemory(p: Pointer; count: LongInt);
procedure MoveMemory(dest, source: Pointer; count: Integer);
function GetEnvVar(EnvVar: string): string;
function GetTempPath(BufferSize: Integer; PathBuffer: PChar): LongInt;
function StringAsPChar(var S: OpenString): PChar;
function ExtractFileDir(FName: string): string;
function ExtractFileDrive(FName: string): string;       { 3/29/98 2.1 }

{$IFNDEF NOLONGNAMES}
function LFN_CreateFile(FName: string): LongBool;
function LFN_FileExists(LName: string): Boolean;
function LFN_GetShortFileName(LName: string): string;
{$ENDIF}
function LFN_Shorten(LName: string): string;
function LFN_WIN31LongPathToShort(LName: string): string;
{$ENDIF}

{$IFNDEF NOLONGNAMES}
function LFN_ConvertLFName(LName: string; ConvertOperation: TConversionOperation): string;
{$ENDIF}

{$IFNDEF WIN32}                                         { 4/22/98 2.11 }
var
   OSVersion                  : LongInt;
   IsNT                       : Boolean;
{$ENDIF}

implementation

{$IFNDEF KPSMALL}
uses
   Dialogs
   {$IFNDEF WIN32}
   {$IFNDEF NODISKUTILS}
   , kpDUtil
   {$ENDIF}
   {$ENDIF};
{$ENDIF}

{$IFNDEF WIN32}
var
  DOSChars                   : array[0..77] of char;
{$ENDIF}
const
   {$IFNDEF WIN32}
   FNameChars                 : set of Char =
      ['A'..'Z', 'a'..'z', '0'..'9', '_', '^', '$', '~', '!', '#', '%', '&', '-', '{', '}',
      '@',
      '`', '''', ')', '('];
   {$ENDIF}
   WildCardChars              : set of Char =
      ['*', '?', MATCH_CHAR_RANGE_OPEN, WILDCARD_RECURSE, WILDCARD_NORECURSE];  { Removed ] added > and <  7/24/98 }

constructor TLFNFileStream.CreateFile(const FileName: string; Mode: Word; FlushOut: Boolean;
                                      BufSize: Integer);
var
   FName                      : string;
begin
   FName := FileName;
   {$IFNDEF WIN32}
     {$IFNDEF NOLONGNAMES}
     if OSVersion > 3 then
     begin
      if (Mode = fmCreate) then
         LFN_CreateFile(FName);
      FName := LFN_ConvertLFName(FName, SHORTEN);
     end
     else
     {$ENDIF}
      FName := LFN_WIN31LongPathToShort(FName);
   {$ENDIF}
   {$IFNDEF NOSTREAMBUFF}
   theFile := TFileStream.Create(Fname, Mode);
   inherited Create(theFile, BufSize);
   {$IFDEF WIN32}
   { Only if one of the write mode bits are set }
   FlushOnDestroy := FlushOut and ((Mode and 3) > 0);
   {$ENDIF}
   {$ELSE}
   inherited Create(FName, Mode);
   {$ENDIF}
end;

destructor TLFNFileStream.Destroy;
begin
   inherited Destroy;
   {$IFNDEF NOSTREAMBUFF}
   theFile.Free; { Must Free after calling inherited Destroy so that }
   {$ENDIF} { buffers can be flushed out by Destroy }
end;

{$IFNDEF NOSTREAMBUFF}

function TLFNFileStream.GetHandle: Integer;
begin
   Result := theFile.Handle;
end;

{$ENDIF}

constructor TSearchData.Create(Path, MatchPattern: string);
begin
   NoFiles := False;
   Directory := Path;
   if RightStr(Directory, 1) <> '\' then
      Directory := Directory + '\';
   Pattern := MatchPattern;
   SearchResult := FindFirst(Directory + '*.*', faAnyFile, SearchRec);
   if SearchResult <> 0 then {This should never happen though since we always use *.*}
      NoFiles := True; {to avoid hanging on NT systems with empty directories}
end;

destructor TSearchData.Destroy;
begin
   if not NoFiles then
      SysUtils.FindClose(SearchRec); {don't call if FindFirst didn't find any files}
   inherited Destroy;
end;

procedure TSearchData.Next;
begin
   if (SearchResult = 0) then
      SearchResult := Findnext(SearchRec);
end;

constructor TDirSearch.Create(const StartingDir, Pattern: string; RecurseDirs: Boolean);

   procedure ParseWildDir(var wilddir: string);
   var
      i, j                    : Integer;
      Remaining               : string;
   begin
      i := 1;
      while (i <= Length(wilddir)) and not (wilddir[i] in WildCardChars) do
         Inc(i);
      j := i;
      while (wilddir[j] <> '\') do
         Dec(j);
      Remaining := RightStr(wilddir, Length(wilddir) - j);
      wilddir := LeftStr(wilddir, j);
      i := 1;
      j := 0;
      while (i <= Length(Remaining)) do
      begin
         if (Remaining[i] = '\') then
         begin
            FWildDirStack.Add(LeftStr(Remaining, i - 1));
            Remaining := RightStr(Remaining, Length(Remaining) - i);
            i := 1;
            Inc(j);
         end
         else
            Inc(i);
      end;
      FNumWildDirs := j;
   end;

var
   StartDir                   : string;
   thisPattern                : string;
begin
   inherited Create;
   StartDir := StartingDir;
   if RightStr(StartDir, 1) <> '\' then
      StartDir := StartDir + '\';
   if IsWildCard(StartDir) then
   begin
      FWildDirStack := TStringList.Create;
      ParseWildDir(StartDir);
      FWildDirID := 0;
   end
   else
   begin
      FWildDirID := -1;
      FNumWildDirs := 0;
      FWildDirStack := nil;
   end;
   FCurrentLevel := 0;
   FPattern := Pattern;
   if FNumWildDirs > 0 then
      thisPattern := FWildDirStack[0]
   else
      thisPattern := FPattern;
   FDirStack[FCurrentLevel] := TSearchData.Create(StartDir, thisPattern);
   FRecurse := RecurseDirs;
end;

destructor TDirSearch.Destroy;
begin
   FWildDirStack.Free;
end;

function TDirSearch.IsChildDir(SR: TSearchRec): Boolean;
begin
   Result := (SR.Attr and faDirectory > 0) and (SR.Name[1] <> '.');
end;

function TDirSearch.IsDir(SR: TSearchRec): Boolean;
begin
   Result := (SR.Attr and faDirectory > 0);
end;

function TDirSearch.NextFile(var SR: TSearchRec): string;
var
   FullDir                    : string;
   SData                      : TSearchData;
begin
   SData := FDirStack[FCurrentLevel];
   while True do
   begin
      if SData.SearchResult <> 0 then
      begin
         SData.Free;
         FDirStack[FCurrentLevel] := nil;
         if FCurrentLevel = 0 then
         begin
            Result := '';                               {Thats it folks!}
            break;
         end;
         Dec(FCurrentLevel);                            { Pop back up a level }
         SData := FDirStack[FCurrentLevel];
         {ChDirectory( SData.Directory );}
         {GetDirectory( 0, dbgFullDir );}
         if (FCurrentLevel < FNumWildDirs) then
            Dec(FWildDirID);
         SData.Next;
      end;
      { Added wildcards-in-paths feature 7/22/98  2.14 }
      if (FCurrentLevel < FNumWildDirs) then
      begin
         while ((SData.SearchResult = 0) and ((not IsChildDir(SData.SearchRec)) or
            (not IsMatch(FWildDirStack[FWildDirID], SData.SearchRec.Name)))) do
            SData.Next;
         if (SData.SearchResult = 0) then
         begin
            Inc(FCurrentLevel);
            {ChDirectory( SData.SearchRec.Name );}
            {GetDirectory( 0, FullDir );}{ Get full directory name }
            FullDir := SData.Directory + SData.SearchRec.Name;
            Inc(FWildDirID);
            if (FCurrentLevel < FNumWildDirs) then
               FDirStack[FCurrentLevel] := TSearchData.Create(FullDir,
                  FWildDirStack[FWildDirID])
            else
               FDirStack[FCurrentLevel] := TSearchData.Create(FullDir, FPattern);
            SData := FDirStack[FCurrentLevel];
            SData.Next;
         end;
         Continue;
      end;
      while ((SData.SearchResult = 0) and (IsDir(SData.SearchRec) and (not FRecurse))) do
         SData.Next;
      if (SData.SearchResult = 0) and (IsChildDir(SData.SearchRec)) and (FRecurse) then
      begin
         Inc(FCurrentLevel);
         {ChDirectory( SData.SearchRec.Name );}
         {GetDirectory( 0, FullDir );}{ Get full directory name }
         FullDir := SData.Directory + SData.SearchRec.Name;
         FDirStack[FCurrentLevel] := TSearchData.Create(FullDir, FPattern);
         {SData := FDirStack[FCurrentLevel];}
         Result := FullDir + '\';
         Break;
      end
      else
         if (SData.SearchResult = 0) and (not IsDir(SData.SearchRec)) then
         begin
            if ExtractFileExt(SData.SearchRec.Name) = '' then { this gets files with }
               SData.SearchRec.Name := SData.SearchRec.Name + '.'; { no extention         }
            if IsMatch(FPattern, SData.SearchRec.Name) then
            begin
               if SData.SearchRec.Name[Length(SData.SearchRec.Name)] = '.' then
                  SetLength(SData.SearchRec.Name, Length(SData.SearchRec.Name) - 1);
               SR.Size := SData.SearchRec.Size; { Modified for D2 mem leak 4/15/99  2.17+}
               Result := SData.Directory + SData.SearchRec.Name;
               SData.Next;
               Break;
            end
            else
               SData.Next;
         end
         else
            SData.Next;
   end;
end;

function kpmin(a, b: BIGINT): BIGINT;
begin
   if a < b then
      Result := a
   else
      Result := b;
end;

function kpmax(a, b: BIGINT): BIGINT;
begin
   if a > b then
      Result := a
   else
      Result := b;
end;

function CRate(uc, c: LongInt): LongInt;
var
   R, S                       : Extended;
begin
   if uc > 0 then
   begin
      S := c;
      S := S * 100;
      R := S / uc;
   end
   else
      R := 0;
   Result := kpmin(Round(R), 100);
end;

function CBigRate(uc, c: Comp): LongInt;
var
   R                          : Comp;
begin
   {$IFDEF ASSERTS}
   Assert(c <= uc, 'Total Done more than total');
   {$ENDIF}
   if uc > 0 then
   begin
      R := (c * 100) / uc;
   end
   else
      R := 0;
   Result := kpmin(Round(R), 100);
end;

function DOSToUnixFilename(fn: PChar): PChar;
var
   slash                      : PChar;
begin
   slash := StrScan(fn, '\');
   while (slash <> nil) do
   begin
      slash[0] := '/';
      slash := StrScan(fn, '\');
   end;
   Result := fn;
end;

function UnixToDOSFilename(fn: PChar): PChar;
var
   slash                      : PChar;
begin
   slash := StrScan(fn, '/');
   while (slash <> nil) do
   begin
      slash[0] := '\';
      slash := StrScan(fn, '/');
   end;
   Result := fn;
end;

function RightStr(str: string; count: Integer): string;
begin
   Result := Copy(str, kpmax(1, Length(str) - (count - 1)), count);
end;

function LeftStr(str: string; count: Integer): string;
begin
   Result := Copy(str, 1, count);
end;

function IsWildCard(fname: string): Boolean;
var
   i                          : Integer;
begin
   i := 1;
   while (i <= Length(fname)) and not (fname[i] in WildCardChars) do
      Inc(i);
   if i > Length(fname) then
      Result := False
   else
      Result := True;
end;

{ Added 4/21/98  2.11  to avoid date/time conversion exceptions }

function GoodTimeStamp(theTimeStamp: LongInt): LongInt;
var
   Hour, Min, Sec             : WORD;
   Year, Month, Day           : WORD;
   Modified                   : Boolean;
begin
   Result := theTimeStamp;
   Hour := LongRec(Result).Lo shr 11;
   Min := LongRec(Result).Lo shr 5 and 63;
   Sec := LongRec(Result).Lo and 31 shl 1;

   Year := LongRec(Result).Hi shr 9 + 1980;
   Month := LongRec(Result).Hi shr 5 and 15;
   Day := LongRec(Result).Hi and 31;

   Modified := False;
   if Hour > 23 then
   begin
      Modified := True;
      Hour := 23;
   end;
   if Min > 59 then
   begin
      Modified := True;
      Min := 59;
   end;
   if Sec > 59 then
   begin
      Modified := True;
      Sec := 59;
   end;
   if Year < 1980 then
   begin
      Modified := True;
      Year := 1980;
   end;
   if Year > 2099 then
   begin
      Modified := True;
      Year := 2099;
   end;
   if Month > 12 then
   begin
      Modified := True;
      Month := 12;
   end;
   if Month < 1 then
   begin
      Modified := True;
      Month := 1;
   end;
   if Day > 31 then
   begin
      Modified := True;
      Day := 31;
   end;
   if Day < 1 then
   begin
      Modified := True;
      Day := 1;
   end;

   if Modified then
   begin
      LongRec(Result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
      LongRec(Result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
   end;

end;

function FileDate(fname: string): TDateTime;
{
var
  f: Integer;
}
begin
   { Converted to using FileAge 3/29/98 2.1 }
   try
      Result := FileDateToDateTime(GoodTimeStamp(FileAge(fname)));
   except
      Result := Now;
   end;
   {$IFDEF SKIPCODE}
   f := FileOpen(fname, fmOpenRead);
   Result := FileDateToDateTime(FileGetDate(f));
   FileClose(f);
   {$ENDIF}
end;

procedure ForceDirs(Dir: string);
begin
   {$IFDEF WIN32}
   {$IFNDEF KPSMALL}
   ForceDirectories(Dir);
   {$ELSE}
   ForceCreateDirectories(Dir);
   {$ENDIF}
   {$ELSE}
   {$IFNDEF NOLONGNAMES}
   if OSVersion > 3 then
   begin
      if Dir[Length(Dir)] = '\' then
         SetLength(Dir, Length(Dir) - 1);
      if (Length(Dir) < 3) or DirectoryExists(Dir) then Exit;
      ForceDirs(ExtractFilePath(Dir));
      W32CreateDirectory(StringAsPChar(Dir), nil, id_W32CreateDirectory);
   end
   else
      {$ENDIF}
   begin
      Dir := LFN_WIN31LongPathToShort(Dir);
      {$IFNDEF KPSMALL}
      ForceDirectories(Dir);
      {$ELSE}
      ForceCreateDirectories(Dir);
      {$ENDIF}
   end;
   {$ENDIF}
end;

function File_Exists(const FileName: string): Boolean;
begin
   {$IFDEF WIN32}
   Result := FileExists(Filename);
   {$ELSE}
   {$IFNDEF NOLONGNAMES}
   if OSVersion > 3 then
      Result := LFN_FileExists(Filename)
   else
      {$ENDIF}
      Result := FileExists(LFN_WIN31LongPathToShort(Filename));
   {$ENDIF}
end;

function DirExists(Dir: string): Boolean;
begin
   {$IFDEF WIN32}
   {$IFDEF KPSMALL}
   Result := kpSmall.DirExists(Dir);
   {$ELSE}
   Result := DirectoryExists(Dir);
   {$ENDIF}
   {$ELSE}
   {$IFNDEF NOLONGNAMES}
   if OSVersion > 3 then
      Result := LFN_FileExists(Dir)
   else
      {$ENDIF}
   begin
      Dir := LFN_WIN31LongPathToShort(Dir);
      {$IFDEF KPSMALL}
      Result := kpSmall.DirExists(Dir);
      {$ELSE}
      Result := DirectoryExists(Dir);
      {$ENDIF}
   end;
   {$ENDIF}
end;

procedure GetDirectory(D: Byte; var S: string);
{$IFNDEF WIN32}
var
   Drive                      : array[0..3] of Char;
   DirBuf, SaveBuf            : array[0..259] of Char;
   {$ENDIF}
begin
   {$IFDEF WIN32}
   GetDir(D, S);
   {$ELSE}
   {$IFNDEF NOLONGNAMES}
   if OSVersion > 3 then
   begin
      if D <> 0 then
      begin
         Drive[0] := Chr(D + Ord('A') - 1);
         Drive[1] := ':';
         Drive[2] := #0;
         W32GetCurrentDirectory(SizeOf(SaveBuf), SaveBuf, id_W32GetCurrentDirectory);
         W32SetCurrentDirectory(Drive, id_W32SetCurrentDirectory);
      end;
      W32GetCurrentDirectory(SizeOf(DirBuf), DirBuf, id_W32GetCurrentDirectory);
      if D <> 0 then W32SetCurrentDirectory(SaveBuf, id_W32SetCurrentDirectory);
      S := StrPas(PChar(@DirBuf));
   end
   else
      {$ENDIF}
      GetDir(D, S); {We should never be Getting a long Dirname in Win31}
   {$ENDIF}
end;

procedure ChDirectory(const S: string);
{$IFNDEF WIN32}
var
   Dir                        : string;
   {$ENDIF}
begin
   {$IFDEF WIN32}
   ChDir(S);
   {$ELSE}
   {$IFNDEF NOLONGNAMES}
   {Added Check for NT 3/1/98 for version 2.03}
   if (OSVersion > 3) and (not IsNT) then
   begin
      Dir := S;
      W32SetCurrentDirectory(StringAsPChar(Dir), id_W32SetCurrentDirectory)
   end
   else
      if IsNT then
      begin
         {Dir := LFN_WIN31LongPathToShort(S);}
         Dir := LFN_ConvertLFName(S, SHORTEN);
         ChDir(Dir);
      end
      else
         {$ENDIF}
      begin
         Dir := s;
         if (length(Dir) > 3) and (Dir[length(Dir)] = '\') then
            Delete(Dir, length(Dir), 1);
         ChDir(Dir);
      end;
   {$ENDIF}
end;

{$IFDEF SKIP_CODE}

procedure FileCopy(const FromFile, ToFile: string);
var
   FromF, ToF                 : file;
   NumRead, NumWritten        : Integer;
   Buf                        : array[1..2048] of Char;
begin
  if DoRenameCopy(FromFile, ToFile) then exit;
   AssignFile(FromF, FromFile);
   Reset(FromF, 1);                                     { Record size = 1 }
   AssignFile(ToF, ToFile);                             { Open output file }
   Rewrite(ToF, 1);                                     { Record size = 1 }
   repeat
      BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
      BlockWrite(ToF, Buf, NumRead, NumWritten);
   until (NumRead = 0) or (NumWritten <> NumRead);
   CloseFile(FromF);
   CloseFile(ToF);
end;
{$ENDIF}

function DoRenameCopy(const FromFile, ToFile: string): boolean;
{ function to rename instead of copy a file if source and destination
  are on the same disk.  Thanks to Dennis Passmore.   11/27/00  2.21b4+
}
var
  fTempName: string;
  FromF: file;
  IOerr: integer;
  ecode: integer;
begin
  result := false;
  IOerr := IOResult;
{$undef IPlus}
{$ifopt I+}
{$define IPlus}
{$endif}
{$I-}
  if (AnsiCompareText(ExtractFileDrive(FromFile), ExtractFileDrive(ToFile)) = 0) then
  begin
    fTempName := '';
    ecode := SetErrormode(SEM_FAILCRITICALERRORS);
    if FileExists(ToFile) then
    begin
      fTempName := ToFile+'$$$';
      AssignFile(FromF, ToFile);
      System.Rename(FromF, fTempName);
      IOerr := IOresult;
    end;
    if (IOerr = 0) then
    begin
      AssignFile(FromF, FromFile);
      System.Rename(FromF, ToFile);
      Result := IOresult = 0;
      if Result and (fTempName <> '') and FileExists(fTempName) then
      begin
        AssignFile(FromF, fTempName);
        System.Erase(FromF);
        {if (IOresult <> 0) then;}
      end;
    end;
    SetErrormode(ecode);
  end;
{$ifdef IPlus}
{$I+}
{$undef IPlus}
{$endif}
end;

procedure FileCopy(const FromFile, ToFile: string);
var
   S, T                       : TFileStream;
   msg1, msg2                 : string;
begin
   if DoRenameCopy(FromFile, ToFile) then exit;  { 2.21b4+ }
   S := TFileStream.Create(FromFile, fmOpenRead);
   try
      T := TFileStream.Create(ToFile, fmOpenWrite or fmCreate);
      try
         if T.CopyFrom(S, 0) = 0 then
         begin
            {$IFDEF NO_RES}
            msg1 := 'Could not copy from ' + FromFile + ' to ' + ToFile;
            msg2 := 'Error';
            {$ELSE}
            msg1 := LoadStr(IDS_NOCOPY) + FromFile + ' -> ' + ToFile;
            msg2 := LoadStr(IDS_ERROR);
            {$ENDIF}
            MessageBox(0, StringAsPChar(msg1), StringAsPChar(msg2), MB_OK);
         end;
      finally
         T.Free;
      end;
   finally
      S.Free;
   end;
end;

function PCharToStr(CStr: PChar): string;
begin
   if CStr = nil then
      Result := ''
   else
   begin
      {$IFDEF WIN32}
      SetLength(Result, StrLen(CStr));
      Move(CStr^, Result[1], Length(Result));
      {$ELSE}
      Result := StrPas(CStr);
      {$ENDIF}
   end;
end;

function StrToPChar(Str: string): PChar;
begin
   if Str = '' then
      Result := nil
   else
   begin
      Result := StrAlloc(Length(Str) + 1);
      {$IFDEF WIN32}
      StrCopy(Result, PChar(Str));
      {$ELSE}
      StrPCopy(Result, Str);
      {$ENDIF}
   end;
end;

function SetVolLabel(Disk, NewLabel: string): LongBool;
{$IFNDEF WIN32}
var
   DiskLabel                  : Str11;
   Drive                      : Char;
   {$ENDIF}
begin
   {$IFNDEF NODISKUTILS}
   {$IFDEF WIN32}
   { Make sure label is deleted first }
   SetVolumeLabel(StringAsPChar(Disk), nil);
   { Set the new label }
   Result := SetVolumeLabel(StringAsPChar(Disk), StringAsPChar(NewLabel));
   {$ELSE}
   Drive := Chr(Ord(Disk[1]));                          { removed -64 on 3/9/98 2.03 }
   DiskLabel := NewLabel;
   SetDiskLabel(DiskLabel, Drive);
   Result := LongBool(True);
   {$ENDIF}
   {$ELSE}
   Result := False;
   {$ENDIF}
end;

function GetVolumeLabel(Disk: string): string;
{$IFNDEF NODISKUTILS}
{$IFNDEF WIN32}

   procedure PadVolumeLabel(var Name: Str11);
      { procedure pads Volume Label string with spaces }
   var
      i                       : integer;
   begin
      for i := Length(Name) + 1 to 11 do
         Name := Name + ' ';
   end;
   {$ENDIF}
var
   Dummy2, Dummy3             : DWORD;
   {$IFNDEF WIN32}
   SR                         : TSearchRec;
   DriveLetter                : Char;
   SearchString               : string[7];
   tmpResult                  : Str11;
   P                          : Byte;
   Dummy1                     : DWORD;
   Dummy4                     : string;
   DiskLabel                  : Str11;
   {$ELSE}
   DiskLabel                  : array[0..13] of char;
   {$ENDIF}
   {$ENDIF}
begin
   {$IFNDEF NODISKUTILS}
   {$IFDEF WIN32}
   GetVolumeInformation(StringAsPChar(Disk), DiskLabel, SizeOf(DiskLabel),
      nil, Dummy2, Dummy3, nil, 0);
   Result := StrPas(DiskLabel);
   {$ELSE}
   if OSVersion = 3 then
   begin
      { Replaced old call because INT call wasn't working correctly.  11/4/98  2.17 }
      SearchString := Disk[1] + ':\*.*';
      { find vol label }
      if FindFirst(SearchString, faVolumeID, SR) = 0 then
      begin
         P := Pos('.', SR.Name);
         if P > 0 then
         begin                                          { if it has a dot... }
            tmpResult := '           ';                 { pad spaces between name }
            Move(SR.Name[1], tmpResult[1], P - 1);      { and extension }
            Move(SR.Name[P + 1], tmpResult[9], 3);
         end
         else
         begin
            tmpResult := SR.Name;                       { otherwise, pad to end }
            PadVolumeLabel(tmpResult);
         end;
      end
      else
         tmpResult := '';

      Result := tmpResult;
      {DiskNum := Ord(Disk[1])-64;}
      {GetMediaID( DiskNum, info );}
      {Result := info.volName;}
   end
   else
   begin
      GetVolumeInformation(Disk, DiskLabel, Dummy1, Dummy2, Dummy3, Dummy4);
      Result := DiskLabel;
   end;
   {$ENDIF}
   {$ELSE}
   Result := '';
   {$ENDIF}
end;

{ Added 5/5/98  2.12 }

function TempFileName(Pathname: string): string;
var
   TmpFileName                : array[0..255] of Char;
begin
   {$IFNDEF WIN32}
   GetTempFileName('C', 'KPZ', 0, TmpFileName);
   if Pathname[Length(Pathname)] = '\' then
      Result := Pathname + ExtractFilename(PCharToStr(TmpFileName))
   else
      Result := Pathname + '\' + ExtractFilename(PCharToStr(TmpFileName))
         {$ELSE}
   GetTempFileName(StringAsPChar(Pathname), 'KPZ', 0, TmpFileName);
   Result := PCharToStr(TmpFileName);
   {$ENDIF}
end;

procedure OemFilter(var fname: string);
begin
   {$IFDEF WIN32}
   CharToOem(@fname[1], @fname[1]);
   {$ELSE}
   AnsiToOem(StringAsPChar(fname), StringAsPChar(fname));
   {$ENDIF}
   {$IFDEF WIN32}
   OemToChar(@fname[1], @fname[1]);
   {$ELSE}
   OemToAnsi(StringAsPChar(fname), StringAsPChar(fname));
   {$ENDIF}
end;

{$IFNDEF Ver100}
{ A very simple assert routine for D1 and D2 }

procedure Assert(Value: Boolean; Msg: string);
begin
   {$IFDEF ASSERTS}
   if not Value then
      ShowMessage(Msg);
   {$ENDIF}
end;
{$ENDIF}

{$IFDEF WIN32}

function BlockCompare(const Buf1, Buf2; Count: Integer): Boolean;
type
   BufArray = array[0..MaxInt - 1] of Char;
var
   I                          : Integer;
begin
   Result := False;
   for I := 0 to Count - 1 do
      if BufArray(Buf1)[I] <> BufArray(Buf2)[I] then Exit;
   Result := True;
end;

function StringAsPChar(var S: string): PChar;
begin
   Result := PChar(S);
end;

{$ELSE} { These functions are defined for 16 bit }

function BlockCompare(const Buf1, Buf2; Count: Integer): Boolean; ASSEMBLER;
asm
        PUSH    DS
        LDS     SI,Buf1
        LES     DI,Buf2
        MOV     CX,Count
        XOR     AX,AX
        CLD
        REPE    CMPSB
        JNE     @@1
        INC     AX
@@1:    POP     DS
end;

procedure SetLength(var S: string; NewLength: Integer);
begin
   S[0] := Char(LoByte(NewLength));
end;

function Trim( const S: string ): String;
var
  i,j: Integer;
begin
  if Length(s) = 0 then
     result := ''
  else
   begin
     i := 1;
     while (S[i]=' ') do
        inc(i);
     j := length(S);
     while (S[j]=' ')do
        dec(j);
     result := copy(S,i,j-i);
   end;
end;

procedure ZeroMemory(p: Pointer; count: LongInt);
var
   b                          : BYTEPTR;
   i                          : LongInt;
begin
   b := BYTEPTR(p);
   for i := 0 to count - 1 do
   begin
      b^ := 0;
      Inc(b);
   end;
end;

procedure MoveMemory(dest, source: Pointer; count: Integer);
var
   d, s                       : BYTEPTR;
   i                          : Integer;
begin
   d := BYTEPTR(dest);
   s := BYTEPTR(source);
   for i := 0 to count - 1 do
   begin
      d^ := s^;
      Inc(d);
      Inc(s);
   end;
end;

function StringAsPChar(var S: OpenString): PChar;
begin
   if Length(S) = High(S) then
      Dec(S[0]);
   S[Ord(Length(S)) + 1] := #0;
   Result := @S[1];
end;

function GetEnvVar(EnvVar: string): string;
var
   P                          : PChar;
begin
   Result := '';
   P := GetDOSEnvironment;
   if Length(EnvVar) > 253 then
      SetLength(EnvVar, 253);
   EnvVar := EnvVar + '=';
   StringAsPChar(EnvVar);
   while P^ <> #0 do
      if StrLIComp(P, @EnvVar[1], Length(EnvVar)) <> 0 then
         Inc(P, StrLen(P) + 1)
      else
      begin
         Inc(P, Length(EnvVar));
         Result := StrPas(P);
         break;
      end;
end;

function GetTempPath(BufferSize: Integer; PathBuffer: PChar): LongInt;
var
   thePath                    : string;
begin
   thePath := GetEnvVar('TMP');
   if thePath = '' then
      thePath := GetEnvVar('TEMP');
   if thePath = '' then
      GetDir(0, thePath);
   if thePath[Length(thePath)] <> '\' then
      thePath := thePath + '\';
   StrPCopy(PathBuffer, thePath);
   Result := Length(thePath);
end;

{ Added this function 3/29/98 2.1 }

function ExtractFileDir(FName: string): string;
{ExtractFileDir does not include the rightmost '\'}
begin
   Result := ExtractFilePath(FName);
   if (Result <> '') and (Result <> '\') and (not (RightStr(Result, 2) = ':\')) then
      SetLength(Result, Length(Result) - 1);
end;

function ExtractFileDrive(FName: string): string;
begin
   Result := '';
   if (Length(FName) < 2) or (FName[2] <> ':') then
      exit;
   Result := LeftStr(FName, 2);
end;

{$IFNDEF NOLONGNAMES}

function LFN_CreateFile(FName: string): LongBool;
const
   GENERIC_READ               = $80000000;
   GENERIC_WRITE              = $40000000;
   CREATE_NEW                 = 1;
   CREATE_ALWAYS              = 2;
   OPEN_EXISTING              = 3;
   OPEN_ALWAYS                = 4;
   TRUNCATE_EXISTING          = 5;
   FILE_ATTRIBUTE_NORMAL      = $00000080;
var
   theHandle                  : LongInt;
begin
   theHandle := W32CreateFile(StringAsPChar(FName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS,
      FILE_ATTRIBUTE_NORMAL, 0, id_W32CreateFile);
   Result := W32CloseHandle(theHandle, id_W32CloseHandle);
end;

function LFN_GetShortFileName(LName: string): string;
var
   ffd                        : WIN32_FIND_DATA;
   r                          : LongInt;
begin
   r := W32FindFirstFile(StringAsPChar(LName), ffd, id_W32FindFirstFile);
   if (r <> -1) and (StrPas(ffd.cAlternateFileName) <> '') then
      Result := ExtractFilePath(LName) + StrPas(ffd.cAlternateFileName)
   else
      Result := LName;
   if (r <> -1) then
      W32FindClose(r, id_W32FindClose);
end;
{$ENDIF}

function hash(S: string; M: LongInt): LongInt;
var
   i                          : Integer;
   g                          : LongInt;
begin
   Result := 0;
   for i := 1 to Length(S) do
   begin
      Result := (Result shl 4) + Byte(S[i]);
      g := Result and $F0000000;
      if (g <> 0) then
         Result := Result xor (g shr 24);
      Result := Result and (not g);
   end;
   Result := Result mod M;
end;

function LFN_Shorten(LName: string): string;
var
   i                          : Integer;
   Extent                     : string;
   HashChar                   : Char;
begin
   HashChar := #0;
   i := Length(LName);
   while (i > 0) do
   begin
      if LName[i] = '.' then
         break;
      Dec(i);
   end;
   if i > 0 then
   begin
      if Length(LName) - i > 3 then
         HashChar := DOSChars[hash(LName, 78)];
      Extent := Copy(LName, i, 4);
      if HashChar <> #0 then
      begin
         Extent[4] := HashChar;
         HashChar := #0;
      end;
      if i > 9 then
         HashChar := DOSChars[hash(LName, 78)];
      SetLength(LName, kpmin(i - 1, 8));
      if HashChar <> #0 then
         LName[8] := HashChar;
   end
   else
   begin
      Extent := '';
      if Length(LName) > 8 then
         HashChar := DOSChars[hash(LName, 78)];
      SetLength(LName, kpmin(Length(LName), 8));
   end;
   for i := 1 to Length(LName) do
      if not (LName[i] in FNameChars) then
         LName[i] := '_';
   Result := LName + Extent;
end;

function LFN_WIN31LongPathToShort(LName: string): string;
var
   tempShortPath              : string;
   tmpStr                     : string;
   p                          : PChar;
   count, r, i, j             : Integer;
   EndSlash                   : Boolean;
begin
   count := 0;
   EndSlash := False;
   tempShortPath := '';
   if (LName[2] = ':') and (LName[3] <> '\') then
      Insert('\', LName, 3);
   if (LName[Length(LName)] = '\') then
   begin
      EndSlash := True;
      Dec(LName[0]);
   end;
   if (LName[1] = '\') then
      j := 2
   else
      j := 1;

   for i := j to Length(LName) do
      if LName[i] = '\' then
      begin
         LName[i] := #0;
         Inc(count);
      end;
   LName[Length(LName) + 1] := #0;
   p := @LName[j];
   if p[1] = ':' then
   begin
      tempShortPath := StrPas(p) + '\';
      p := StrEnd(p);
      Inc(p);
      Dec(count);
   end;
   for i := 0 to count do
   begin
      tmpStr := StrPas(p);
      tmpStr := LFN_Shorten(tmpStr);
      tempShortPath := tempShortPath + tmpStr + '\';
      p := StrEnd(p);
      Inc(p);
   end;
   if not EndSlash then
      Dec(tempShortPath[0]);
   Result := tempShortPath;
end;

{$IFNDEF NOLONGNAMES}

function LFN_FileExists(LName: string): Boolean;
var
   ffd                        : WIN32_FIND_DATA;
   r                          : LongInt;
begin
   if LName[Length(LName)] = '\' then
      Dec(LName[0]);
   r := W32FindFirstFile(StringAsPChar(LName), ffd, id_W32FindFirstFile);
   if r <> -1 then
   begin
      Result := True;
      W32FindClose(r, id_W32FindClose);
   end
   else
      Result := False;

end;
{$ENDIF}
{$ENDIF}

{$IFNDEF NOLONGNAMES}

function LFN_ConvertLFName(LName: string; ConvertOperation: TConversionOperation): string;
var
   tempOrigPath               : array[0..255] of char;
   tempNewPath                : string;
   p                          : PChar;
   count, i, j                : Integer;
   r                          : LongInt;
   {$IFDEF WIN32}
   ffd                        : TWin32FindData;
   {$ELSE}
   ffd                        : WIN32_FIND_DATA;
   {$ENDIF}
   EndSlash                   : Boolean;
   HasDrive                   : Boolean;                { For UNC's 3/26/98  2.1 }
begin
   HasDrive := False;
   count := 0;
   EndSlash := False;
   tempNewPath := '';
   tempOrigPath[0] := #0;
   if (LName[2] = ':') and (LName[3] <> '\') then
      Insert('\', LName, 3);
   if (LName[Length(LName)] = '\') then
   begin
      EndSlash := True;
      SetLength(LName, Length(LName) - 1);
   end;
   if (LName[1] = '\') then
   begin
      tempNewPath := '\';
      j := 2
   end
   else
      if ExtractFileDrive(LName) <> '' then             { For UNC's 3/26/98  2.1 }
      begin
         j := Length(ExtractFileDrive(LName)) + 1;
         HasDrive := True;
      end
      else
         j := 1;
   for i := j to Length(LName) do
      if LName[i] = '\' then
      begin
         LName[i] := #0;
         Inc(count);
      end;
   LName[Length(LName) + 1] := #0;
   if HasDrive then
      j := 1;                                           { 4/12/98 2.11 }
   p := @LName[j];
   if HasDrive then
   begin
      StrCopy(tempOrigPath, p);
      StrCat(tempOrigPath, '\');
      tempNewPath := StrPas(p) + '\';
      p := StrEnd(p);
      p^ := '\';
      Inc(p);
      Dec(count);
   end;
   for i := 0 to count do
   begin
      StrCat(tempOrigPath, p);
      {$IFDEF WIN32}
      r := FindFirstFile(tempOrigPath, ffd);
      {$ELSE}
      r := W32FindFirstFile(tempOrigPath, ffd, id_W32FindFirstFile);
      {$ENDIF}
      if ConvertOperation = LENGTHEN then
      begin
         if (r <> -1) then
            tempNewPath := tempNewPath + StrPas(ffd.cFileName) + '\'
      end
      else
      begin
         if (r <> -1) and (StrPas(ffd.cAlternateFileName) <> '') then
            tempNewPath := tempNewPath + StrPas(ffd.cAlternateFileName) + '\'
         else
            tempNewPath := tempNewPath + StrPas(p) + '\';
      end;
      StrCat(tempOrigPath, '\');
      p := StrEnd(p);
      p^ := '\';
      Inc(p);
      if (r <> -1) then
         {$IFDEF WIN32}
         Windows.FindClose(r);
      {$ELSE}
         W32FindClose(r, id_W32FindClose);
      {$ENDIF}
   end;
   if not EndSlash then
      SetLength(tempNewPath, Length(tempNewPath) - 1);
   Result := tempNewPath;
end;
{$ENDIF}

{$IFNDEF WIN32}
const
   WF_WINNT                   = $4000;

var
   c                          : char;
   i                          : Integer;
begin
   { Added NT Check 3/1/98 for version 2.03 }
   IsNT := (GetWinFlags and WF_WINNT) <> 0;
   if IsNT then
      OSVersion := 4
   else
   begin
      OSversion := GetVersion;
      if (Lo(LOWORD(OSversion)) > 3) or
         ((Lo(LOWORD(OSversion)) = 3) and (Hi(LOWORD(OSversion)) = 95)) then
         OSversion := 4                                 { WIN95 or higher }
      else
         OSversion := 3;                                { WIN31 }
   end;

   {OSVersion := 3;}{ Uncomment these 2 lines to emulate WIN31 on WIN95 or NT }
   {IsNT := False;}{ Useful for testing WIN31 long filename support }
   for c := Low(Char) to High(Char) do
      if c in FNameChars then
      begin
         DOSChars[i] := c;
         Inc(i);
      end;
{$ENDIF}

   { $Id: KPLib.pas,v 1.28 2000-12-16 16:50:09-05 kp Exp kp $ }

   { $Log: KPLib.pas,v $
   { Revision 1.28  2000-12-16 16:50:09-05  kp
   { 2.21 Final Release 12/12/00
   {
   { Revision 1.27  2000-05-21 18:47:52-04  kp
   { - Moved declarations of signature globals out and into kpzipobj.
   {
   { Revision 1.26  2000-05-13 17:03:38-04  kp
   { - Added code to handle BufferedStreamSize property for TLFNFileStream
   { - Changed zip signature constants to real global variables.  Setting of these variables
   {   happens in kpzipobj.pas Initialization section
   {
   { Revision 1.25  1999-12-05 09:30:54-05  kp
   { - Added BIGINT def to kpmin and kpmax
   { - Got rid of kpDiskFree
   {
   { Revision 1.24  1999-10-17 12:08:16-04  kp
   { - Removed $IFNDEF ISBCB from kpmin and kpmax
   {
   { Revision 1.23  1999-10-17 12:00:50-04  kp
   { - Changed min and max to kpmin and kpmax
   {
   { Revision 1.22  1999-10-11 20:40:10-04  kp
   { - Added flushing parameter to TLFNFileStream
   {
   { Revision 1.21  1999-09-16 20:09:00-04  kp
   { - Moved defines to KPDEFS.INC
   {
   { Revision 1.20  1999-09-14 21:28:55-04  kp
   { - Removed FlushAlways stuff from this file
   { - Added Trim function for D1
   {
   { Revision 1.19  1999-09-01 18:26:44-04  kp
   { - Added capability to flush buffered stream to disk after every flush of the buffered streams
   {   buffer.  Used the OnFlushBuffer event to do it.
   {
   { Revision 1.18  1999-08-25 19:04:01-04  kp
   { - Fixes for D1
   {
   { Revision 1.17  1999-06-27 13:53:29-04  kp
   { - Minor fix to kpDiskFree  (changed Integer to DWORD)
   {
   { Revision 1.16  1999-06-18 16:45:59-04  kp
   { - Modified to handle adding directory entries when doing recursive zips (AddDirEntries property)
   {
   { Revision 1.15  1999-06-01 21:56:57-04  kp
   { - Ran through the formatter
   {
   { Revision 1.14  1999-04-24 21:12:58-04  kp
   { - Fixed D2 memory leak
   {
   { Revision 1.13  1999-04-10 10:20:53-04  kp
   { - Added conditionals so that NOLONGNAMES and NODISKUTILS wont get set in 32bit
   { - Added code to SetVolLabel to delete label before setting it.
   {
   { Revision 1.12  1999-03-30 19:43:22-05  kp
   { - Modified so that defining MAKESMALL will create a much smaller component.
   {
   { Revision 1.11  1999-03-23 17:43:40-05  kp
   { - added ifdef around DWord definition
   {
   { Revision 1.10  1999-03-22 17:35:29-05  kp
   { - moved comments to bottom
   { - removed dependency on kpDrvs (affects D1 only)
   { - added asserts ifdef to CBigRate
   {
   { Revision 1.9  1999-03-20 11:45:05-05  kp
   { - Fixed problem where setting ZipComment to '' caused an access violation
   {
   { Revision 1.8  1999-03-15 21:58:58-05  kp
   { <>
   {
   { Revision 1.7  1999-03-14 21:32:07-05  kp
   { - Fixed problem of With SData not working
   {
   { Revision 1.6  1999-02-10 18:12:26-05  kp
   { Added directive to turn off Strict Var Strings compiler option
   {
   { Revision 1.4  1999-01-25 19:13:01-05  kp
   { Modifed compiler directives
   { }

   { Sun 10 May 1998   16:58:46  Version: 2.12
   { - Added TempPath property
   { - Fixed RelativePaths bug
   { - Fixed bug related to files in FilesList that don't exist
   }
   {
   {  Mon 27 Apr 1998   18:37:41  Version: 2.11
   { Added ExtractDeviceDrive and GoodTimeStamp
   }
   {
   { Tue 24 Mar 1998   19:00:23
   { Modifications to allow files and paths to be stored in DOS
   { 8.3 filename format.  New property is Store83Names.
   }
   {
   { Wed 11 Mar 1998   21:10:16  Version: 2.03
   { Version 2.03 Files containing many fixes
   }

   { Sun 01 Mar 1998   10:25:17
   { Modified so that D1 would recognize NT.  Modified return
   { values for W32FindFirstFile to be LongInt instead of
   { Integer.
   }

end.

