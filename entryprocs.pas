unit entryprocs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, epidatafilestypes, epistringutils;

const
  IntegerChars:    TCharSet=['0'..'9','-','+'];
  FloatChars:      TCharSet=['0'..'9', '.', ',', '-', '+'];
  DateChars:       TCharSet=['0'..'9','/', '-', '.'];
  TimeChars:       TCharSet=['0'..'9',':','.'];
  BooleanChars:    TCharSet=['y','Y','n','N','1','0'];

  BooleanYesChars: TCharSet=['Y','y','1'];
  BooleanNoChars:  TCharSet=['N','n','0'];

type
  TCharArray = array of char;

procedure LoadIniFile;
function GetRandomComponentName: string;

implementation

uses
  lclproc, strutils, epidatafiles, FileUtil, settings, forms;

procedure LoadIniFile;
const
  IniName = 'epidataentry.ini';
begin
  // TODO : Settings can be loaded from commandline?
  if LoadSettingsFromIni(GetAppConfigFileUTF8(false)) then exit;

  // Todo - this is not optimal on Non-windows OS's. Do some checks for writeability first.
  if LoadSettingsFromIni(ExtractFilePath(Application.ExeName) + IniName) then exit;

  if not DirectoryExistsUTF8(ExtractFilePath(GetAppConfigFileUTF8(false))) then
    ForceDirectoriesUTF8(ExtractFilePath(GetAppConfigFileUTF8(false)));
  EntrySettings.IniFileName := GetAppConfigFileUTF8(false);
end;

function GetRandomComponentName: string;
var
  GUID: TGUID;
begin
  // Hack: Create a GUID to use as Component name.
  //  - the comp. name is not used in other parts of the program anyway,
  //  - so using GUID is a valid way to create random components names... :)
  //  - And the chance of creating to equal component name are very-very-very unlikely.
  CreateGUID(GUID);
  Result := '_' + StringsReplace(GUIDToString(GUID), ['{','}','-'], ['','',''], [rfReplaceAll]);
end;

end.

