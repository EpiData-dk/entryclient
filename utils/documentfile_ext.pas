unit documentfile_ext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_documentfile;

type

  { TEntryDocumentFile }

  TEntryDocumentFile = class(TDocumentFile)
  private
    function GetEndBackFilename: string;
  public
    function SaveEndBackupFile: boolean;
    function IsEndBackupFileWriteable(out AFileName: string): boolean;
  end;

implementation

uses
  LazFileUtils, settings;

{ TEntryDocumentFile }

function TEntryDocumentFile.GetEndBackFilename: string;
var
  Y: word;
  M: word;
  D: word;
  Prefix: String;
  FileNameNoExt: String;
begin
  if EntrySettings.BackupDirUTF8 = '' then
    Prefix := ExtractFilePath(FileName) + DirectorySeparator + 'backup' + DirectorySeparator
  else
    Prefix := EntrySettings.BackupDirUTF8 + DirectorySeparator;

  FileNameNoExt := ExtractFileNameOnly(FileName);
  Prefix := ExpandFileNameUTF8(Prefix);

  DecodeDate(Now, Y, M, D);
  Result := Prefix + FileNameNoExt +                    // <backupdir>/[<projectfilename>/]projectfilename
       '_' + Format('%d-%.2d-%.2d', [Y,M,D]) +     // _<date>
       '_' + IntToStr(Document.CycleNo) +          // _<cycle>
       '.epz';                                     // eg:  ./backupdir/test/test_2013-24-10_2.epz
                                                   // or:  ./backupdir/test_2013-24-10_2.epz
end;

function TEntryDocumentFile.SaveEndBackupFile: boolean;
var
  Fn: String;
begin
  Result := False;
  if (not IsSaved) then exit;

  try
    Result := IsEndBackupFileWriteable(Fn);

    if Result then
      DoSaveFile(Fn);
  finally
  end;
end;

function TEntryDocumentFile.IsEndBackupFileWriteable(out AFileName: string
  ): boolean;
var
  BaseDir: String;
begin
  AFileName := GetEndBackFilename;
  BaseDir := ExtractFilePath(AFileName);
  Result := true;

  if not DirectoryExistsUTF8(BaseDir) then
    Result := Result and CreateDirUTF8(BaseDir);

  Result := Result and DirectoryIsWritable(BaseDir);

  if FileExistsUTF8(AFileName) then
    Result := Result and FileIsWritable(AFileName);
end;

end.

