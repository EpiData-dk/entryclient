unit ShellBrowser;

interface

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,ShellAPI;

type
    TBrowseSelectionChanged = procedure (Sender: TObject; var NewFolder: String; var Accept: Boolean) of Object;

    TShellDomain = ( sdDesktop, sdPrograms, sdControlPanel, sdPrinters, sdMyDocuments,
                     sdFavorites, sdStartup, sdRecent, sdSendTo, sdRecycleBin,
                     sdStartMenu, sdDrives, sdNetwork, sdNetHood, sdFonts );

    TBrowseOptions = ( FileSystemDirsOnly, DontGoBelowDomain,
                       IncludeStatusText, ReturnSFAncestors,
                       BrowseComputers, BrowsePrinters,
                       BrowseFiles );

    TBrowseOptionSet = set of TBrowseOptions;

    TShellBrowser = class(TComponent)
    private
        { Private declarations }
        fLabelTitle: String;
        fFolderPath: String;
        fWindowTitle: String;
        fImageIndex: Integer;
        fStartDir: String;
        fReadOnlyStrProp: String;
        fReadOnlyIntProp: Integer;
        fDomain: TShellDomain;
        fCentred: Boolean;
        fOptions: TBrowseOptionSet;
        fSelectionChanged: TBrowseSelectionChanged;
        function DomainToIDL: Pointer;
        function GetFlags: UINT;
        procedure UpdateStatusText (Wnd: hWnd; const Selection: String);
    protected
        { Protected declarations }
    public
        { Public declarations }
        constructor Create (AOwner: TComponent); override;
        function Execute: Boolean;
    published
        { Published declarations }
        property LabelTitle: String read fLabelTitle write fLabelTitle;
        property Centred: Boolean read fCentred write fCentred default True;
        property FolderPath: String read fFolderPath write fReadOnlyStrProp;
        property WindowTitle: String read fWindowTitle write fWindowTitle;
        property StartDirectory: String read fStartDir write fStartDir;
        property ImageIndex: Integer read fImageIndex write fReadOnlyIntProp;
        property Domain: TShellDomain read fDomain write fDomain default sdDesktop;
        property Options: TBrowseOptionSet read fOptions write fOptions default [FileSystemDirsOnly];
        property OnSelectionChanged: TBrowseSelectionChanged read fSelectionChanged write fSelectionChanged;
    end;

  TFileOp = (foCopy, foDelete, foMove, foRename);
  TFileOpFlag = (fofAllowUndo, fofConfirmMouse, fofFilesOnly,
    fofMultiDestFiles, fofNoConfirmation, fofNoConfirmMkDir,
    fofRenameOnCollision, fofSilent, fofSimpleProgress);
  TFileOpFlags = set of TFileOpFlag;

  TSMFileOperation=record
  FileFrom, FileTo:string;
  Flags: TFileOpFlags;
  Operation: TFileOp;
  end;


  TFileOperation = class(TComponent)
  private
    FOperation: TFileOp;
    FFrom: string;
    FTo: string;
    FFlags: TFileOpFlags;
    FOperationAborted: Boolean;
    FProgressTitle: string;
    procedure SetFrom(Value: string);
    procedure SetTo(Value: string);
  protected
//    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;
  public
    function Execute : Boolean;
  published
    property FilesFrom: string read FFrom write FFrom;
    property FilesTo: string read FTo write FTo;
    property Flags: TFileOpFlags read FFlags write FFlags;
    property Operation: TFileOp read FOperation write FOperation;
    property OperationAborted: Boolean read FOperationAborted;
    property ProgressTitle: string read FProgressTitle write FProgressTitle;
  end;


function BrowseFolder(var FolderName:string ;const title:string;pOptions: TBrowseOptionSet=[FileSystemDirsOnly]):boolean;
function FileOperation(FileOp:TSMFileOperation):Boolean;
function showFileProp(fn: string; hwnd:HWND):boolean;

implementation

uses FileCtrl, ShlObj, ActiveX;

type
  PSHNameMapping = ^TSHNameMapping;


function showFileProp(fn: string; hwnd:HWND):boolean;
var
 SEI : SHELLEXECUTEINFO;
begin
 SEI.cbSize :=sizeof(SEI);
 SEI.fmask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
 SEI.wnd := hwnd;
 SEI.lpVerb := 'properties';
 SEI.lpFile := pchar(fn);
 SEI.lpParameters:= nil;
 SEI.lpDirectory :=nil;
 SEI.nShow :=0;
 SEI.hInstApp :=0;
 SEI.lpIDList :=0;
 shellExecuteEx(@SEI);
end;


function BrowseFolder(var FolderName:string ;const title:string;pOptions: TBrowseOptionSet=[FileSystemDirsOnly]):boolean;
var
 shb :TShellBrowser;
begin
   shb :=TShellBrowser.create(nil);
   try
     if FolderName<>'' then
          shb.StartDirectory := FolderName;
     shb.Options:=pOptions;
     shb.LabelTitle :=title;
     result:=shb.Execute;
     if result then
        folderName:=shb.FolderPath;
   finally
     shb.free;
   end;
end;

procedure CentreWindow (Wnd: HWnd);
var
    Rect: TRect;
begin
    GetWindowRect (Wnd, Rect);
    SetWindowPos (Wnd, 0,
        (Screen.Width - Rect.Right + Rect.Left) div 2,
        (Screen.Height - Rect.Bottom + Rect.Top) div 2,
        0, 0, swp_NoActivate or swp_NoSize or swp_NoZOrder);
end;

procedure TShellBrowser.UpdateStatusText (Wnd: hWnd; const Selection: String);
var
    R: TRect;
    S: String;
    StatusWnd: hWnd;
begin
    // Have we got a status label?
    if IncludeStatusText in fOptions then begin
        // WARNING: This requires carnal knowledge of SHELL32.DLL !
        // If Microsoft change the ID of the status label, the code
        // simply won't be able to trim the text to fit.
        S := Selection;
        StatusWnd := GetDlgItem (Wnd, $3743);
        if (StatusWnd <> 0) and IsWindowVisible (StatusWnd) then begin
            // We've got a status window.  Should we trim the text?
            GetWindowRect (StatusWnd, R);
            S := MinimizeName (S, Application.MainForm.Canvas, R.Right - R.Left);
        end;

        SendMessage (Wnd, bffm_SetStatusText, 0, Integer (PChar (S)));
    end;
end;

function BrowserCallbackProc (Wnd: hWnd; uMsg: UINT; lParam, lpData: LPARAM): Integer; stdcall;
var
    Accept: Boolean;
    Selection: String;
    Buff: array [0..255] of Char;
    Self: TShellBrowser absolute lpData;
begin
    with Self do case uMsg of
        bffm_Initialized:

        // This is the initialization call from the browse dialog.
        begin
            // Centre the dialog on screen if fCentred is True.
            if fCentred then CentreWindow (Wnd);
            // Set a custom dialog title if desired.
            if fWindowTitle <> '' then SetWindowText (Wnd, PChar (fWindowTitle));
            // Set an initial directory selection if desired
            if fStartDir <> '' then
                SendMessage (Wnd, bffm_SetSelection, Ord(True), Integer (PChar (fStartDir)));
        end;

        bffm_SelChanged:

        // This message is received whenever the folder changes
        // in the browser dialog.  lParam is a pidl to the newly
        // selected folder.
        begin
            Accept := True;

            // Retrieve the current selection
            SHGetPathFromIDList (PItemIDList (lParam), Buff);
            Selection := StrPas (Buff);

            // Notify application of selection change?
            if Assigned (fSelectionChanged) then
                fSelectionChanged (Self, Selection, Accept);

            // Update status text
            UpdateStatusText (Wnd, Selection);

            // Enable/disable OK button as requested
            SendMessage (Wnd, bffm_EnableOK, 0, Ord (Accept));
        end;
    end;

    Result := 0;
end;

constructor TShellBrowser.Create (AOwner: TComponent);
begin
    Inherited Create (AOwner);
    fCentred := True;
    fOptions := [FileSystemDirsOnly];
end;

function TShellBrowser.DomainToIDL: Pointer;
var
    FolderNum: Integer;
begin
    case fDomain of
        sdPrograms:         FolderNum := csidl_Programs;
        sdControlPanel:     FolderNum := csidl_Controls;
        sdPrinters:         FolderNum := csidl_Printers;
        sdMyDocuments:      FolderNum := csidl_Personal;
        sdFavorites:        FolderNum := csidl_Favorites;
        sdStartup:          FolderNum := csidl_Startup;
        sdRecent:           FolderNum := csidl_Recent;
        sdSendTo:           FolderNum := csidl_SendTo;
        sdRecycleBin:       FolderNum := csidl_BitBucket;
        sdStartMenu:        FolderNum := csidl_StartMenu;
        sdDrives:           FolderNum := csidl_Drives;
        sdNetwork:          FolderNum := csidl_Network;
        sdNetHood:          FolderNum := csidl_NetHood;
        sdFonts:            FolderNum := csidl_Fonts;
        else                FolderNum := 0;
    end;

    if FolderNum = 0 then Result := Nil else
        SHGetSpecialFolderLocation (Application.Handle, FolderNum, PItemIDList (Result));
end;

function TShellBrowser.GetFlags: UINT;
begin
    Result := 0;
    if FileSystemDirsOnly in fOptions then Result := Result or bif_ReturnOnlyFSDirs;
    if DontGoBelowDomain in fOptions then Result := Result or bif_DontGoBelowDomain;
    if IncludeStatusText in fOptions then Result := Result or bif_StatusText;
    if ReturnSFAncestors in fOptions then Result := Result or bif_ReturnFSAncestors;
    if BrowseComputers in fOptions then Result := Result or bif_BrowseForComputer;
    if BrowsePrinters in fOptions then Result := Result or bif_BrowseForPrinter;
    if BrowseFiles in fOptions then Result := Result or bif_BrowseIncludeFiles;
end;

function TShellBrowser.Execute: Boolean;
var
    pidl: PItemIDList;
    ShellMalloc: IMalloc;
    BrowseInfo: TBrowseInfo;
    Buff: array [0..255] of Char;
begin
    Result := False;
    if (ShGetMalloc (ShellMalloc) = S_OK) and (ShellMalloc <> Nil) then begin
        BrowseInfo.hwndOwner := Application.Handle;
        BrowseInfo.pidlRoot := DomainToIDL;
        BrowseInfo.pszDisplayName := Nil;
        BrowseInfo.lpszTitle := PChar (fLabelTitle);
        BrowseInfo.ulFlags := GetFlags;
        BrowseInfo.lpfn := BrowserCallbackProc;
        BrowseInfo.lParam := Integer (Self);

        pidl := SHBrowseForFolder (BrowseInfo);
        if pidl = Nil then fFolderPath := '' else begin
            Result := SHGetPathFromIDList (pidl, Buff);
            fFolderPath := StrPas (Buff);
            fImageIndex := BrowseInfo.iImage;
            ShellMalloc.Free (pidl);
        end;
    end;
end;



procedure TFileOperation.SetFrom(Value: string);
begin
  FFrom := ExpandFileName(Value)
end;

procedure TFileOperation.SetTo(Value: string);
begin
  FTo := ExpandFileName(Value)
end;

function TFileOperation.Execute : Boolean;
const
  OperationToSH: array[TFileOp] of Integer =
    (FO_COPY, FO_DELETE, FO_MOVE, FO_RENAME);
  FileOpToSH: array[TFileOpFlag] of FILEOP_FLAGS =
    (FOF_ALLOWUNDO, FOF_CONFIRMMOUSE, FOF_FILESONLY,
     FOF_MULTIDESTFILES, FOF_NOCONFIRMATION, FOF_NOCONFIRMMKDIR,
     FOF_RENAMEONCOLLISION, FOF_SILENT, FOF_SIMPLEPROGRESS);
var
  lpFileOp: TSHFileOpStruct;
  AFrom, ATo: string;
  i: Integer;
begin
  with lpFileOp do
  begin
    if Owner is TForm then Wnd := TForm(Owner).Handle
                      else Wnd := Application.Handle;
    wFunc := OperationToSH[FOperation];

    AFrom := FFrom + #0#0;
    for i := 1 to Length(AFrom) do if AFrom[i] = ';' then AFrom[i] := #0;
    pFrom := PChar(AFrom);

    ATo   := FTo + #0#0;
    for i := 1 to Length(ATo) do if ATo[i] = ';' then ATo[i] := #0;
    pTo   := PChar(ATo);

    fFlags := 0;
    if fofAllowUndo         in Flags then fFlags := fFlags or FOF_ALLOWUNDO;
    if fofConfirmMouse      in Flags then fFlags := fFlags or FOF_CONFIRMMOUSE;
    if fofFilesOnly         in Flags then fFlags := fFlags or FOF_FILESONLY;
    if fofMultiDestFiles    in Flags then fFlags := fFlags or FOF_MULTIDESTFILES;
    if fofNoConfirmation    in Flags then fFlags := fFlags or FOF_NOCONFIRMATION;
    if fofNoConfirmMkDir    in Flags then fFlags := fFlags or FOF_NOCONFIRMMKDIR;
    if fofRenameOnCollision in Flags then fFlags := fFlags or FOF_RENAMEONCOLLISION;
    if fofSilent            in Flags then fFlags := fFlags or FOF_SILENT;
    if fofSimpleProgress    in Flags then fFlags := fFlags or FOF_SIMPLEPROGRESS;
    lpszProgressTitle := PChar(FProgressTitle)
  end;
  Result := not Boolean(SHFileOperation(lpFileOp));
  FOperationAborted := lpFileOp.fAnyOperationsAborted
end;

function FileOperation(FileOp:TSMFileOperation):Boolean;
var
 fo : TFileOperation;
begin
try
fo :=TFileOperation.create(nil);
fo.FilesFrom:=fileop.FileFrom ;
fo.FilesTo :=fileOp.FileTo ;
fo.Flags :=fileop.Flags;
fo.Operation:=fileop.Operation;
result:=fo.execute;
finally
 fo.free;
end;
end;

end.
