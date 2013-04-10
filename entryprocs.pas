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
  lclproc, strutils, epidatafiles, FileUtil, settings, forms,
  LCLVersion;

procedure LoadIniFile;
const
  IniName = 'epidataentry.ini';
var
  Fn: String;
  S: String;
begin
  Fn := GetAppConfigFileUTF8(false,
    {$IFDEF windows}
    false
    {$ELSE}
    true
    {$ENDIF}
    {$IF ((lcl_major = 1) and (lcl_minor >= 1))}
    , true
    {$ENDIF}
    );

  if not LoadSettingsFromIni(Fn)
  then
    begin
      // TODO : This is not optimal on Non-windows OS'Fn. Do some checks for writeability first.
      S := ExtractFilePath(Application.ExeName) + IniName;
      if (not FileIsReadOnlyUTF8(S)) then
         LoadSettingsFromIni(S)
    end;

  EntrySettings.IniFileName := Fn;

  FN := ExpandFileNameUTF8(GetAppConfigDirUTF8(False) + '..' + PathDelim + 'epidatarecentfiles.ini');
  LoadRecentFilesIni(Fn);
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

