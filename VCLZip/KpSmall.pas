unit KpSmall;

interface

function  DirExists(Dir: String): Boolean;
procedure ForceCreateDirectories(Dir: string);
function  PMsgDlg(Msg, Caption: String; TextType: Word): Integer;
function  StripBackSlash(const S: String): String;
function  YieldProcess: Boolean;

implementation

uses SysUtils, WinTypes, WinProcs, Messages;

{This will see if a directory exists without using the FileCtrl unit.}
function DirExists(Dir: String): Boolean;
var
  OldDir: String;
begin
  {$I-}
  GetDir(0, OldDir);
  ChDir(Dir);
  Result:= IOResult = 0;
  ChDir(OldDir);
  {$I+}
end;

{This will force the creation of the entire directory string. This is
a substitute for the ForceDirectories function in the FileCtrl unit.}
procedure ForceCreateDirectories(Dir: string);
begin
  Dir:= StripBackSlash(Dir);
  if (Length(Dir) < 3) or DirExists(Dir) then EXIT;
  ForceCreateDirectories(ExtractFilePath(Dir));
  {$I-}
  MkDir(Dir);
  if IOResult <> 0 then EXIT;
  {$I+}
end;

{This will display a message box with the appropiate strings. It serves
as a sort of replacement for the MessageDlg function in Dialogs.}
function PMsgDlg(Msg, Caption: String; TextType: Word): Integer;
var
  C, M: PChar;
begin
  {See if we should overwrite the caption.}
  if Caption = '' then Caption:= ExtractFileName(ParamStr(0));
  {Allocate the strings.}
  C:= StrAlloc(Length(Caption) + 1);
  M:= StrAlloc(Length(Msg) + 1);
  try
    StrPCopy(C, Caption);
    StrPCopy(M, Msg);
    Result:= MessageBox(0, M, C, TextType or MB_TASKMODAL);
  finally
    {Free the strings.}
    StrDispose(C);
    StrDispose(M);
  end;
end;

{Removes trailing backslash from S, if one exists }
function StripBackSlash(const S: String): String;
begin
  Result:= S;
  if (Result <> '') and (Result[Length(Result)] = '\') then
    Delete(Result, Length(Result), 1);
end;

{This is essentially the same as Application.ProcessMessage, except that it
does not require either the Forms or Dialogs units.}
function YieldProcess: Boolean;
var
  msg: TMsg;
begin
  while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
    begin
      if msg.message = WM_QUIT then
        begin
          PostQuitMessage(msg.wParam);
          Result:= True;
          EXIT;
        end
      else
        begin
          TranslateMessage(msg);
          DispatchMessage(msg)
        end
    end;
  Result:= False;
end;




end.
