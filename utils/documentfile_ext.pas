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
  FileUtil;

{ TEntryDocumentFile }

function TEntryDocumentFile.SaveEndBackupFile: boolean;
var
  Y: word;
  M: word;
  D: word;
  S: String;
begin
  if FileName = '' then exit;

  DecodeDate(Now, Y, M, D);
  S := ExtractFileNameWithoutExt(FileName) + '.' +
       Format('%d-%.2d-%.2d', [Y,M,D]) + '.epz';
  DoSaveFile(S);
end;

end.

