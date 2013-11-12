unit documentfile_ext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_documentfile;

type

  { TEntryDocumentFile }

  TEntryDocumentFile = class(TDocumentFile)
  public
    function SaveEndBackupFile: boolean;
  end;

implementation

uses
  LazFileUtils, settings;

{ TEntryDocumentFile }

function TEntryDocumentFile.SaveEndBackupFile: boolean;
var
  Y: word;
  M: word;
  D: word;
  S: String;
  Prefix: String;
  FileNameNoExt: String;
begin
  Result := False;
  if (not IsSaved) then exit;

  Prefix := EntrySettings.BackupDirUTF8;
  FileNameNoExt := ExtractFileNameOnly(FileName);
  if EntrySettings.PerProjectBackup then
    Prefix := Prefix + DirectorySeparator + FileNameNoExt + DirectorySeparator;

  if not DirectoryExistsUTF8(Prefix) then
    if not CreateDirUTF8(Prefix) then exit;

  DecodeDate(Now, Y, M, D);
  S := Prefix + FileNameNoExt +                    // <backupdir>[/<projectfilename>]
       '_' + Format('%d-%.2d-%.2d', [Y,M,D]) +     // _<date>
       '_' + IntToStr(Document.CycleNo) +          // _<cycle>
       '.epz';                                     // eg:  ./backupdir/myproject/test_2013-24-10_2.epz

  try
    DoSaveFile(S);
    Result := true;
  finally
  end;
end;

end.

