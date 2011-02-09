unit about;

{$mode objfpc}
{$h+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, ComCtrls, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    ButtonPanel: TPanel;
    CloseButton: TBitBtn;
    Image1: TImage;
    CoreVersionLabel: TLabel;
    PlatformLabel: TLabel;
    RevisionLabel: TLabel;
    VersionLabel: TLabel;
    AboutPageControl: TPageControl;
    AboutPage: TTabSheet;
    FPCVersionLabel: TLabel;
    VersionPage: TTabSheet;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

function GetProgramInfo: string;

implementation

{$R *.lfm}

uses
  settings, epiversionutils;

function EntryVersionCaption: string;
begin
  result := 'Program Version: ' + GetEntryVersion;
end;

function CoreVersionCaption: string;
begin
  result := 'Core version: ' + GetCoreVersionInfo;
end;

function RevisionCaption: string;
begin
  result := 'r' + RevisionStr;
end;

function CoreRevisionCaption: string;
begin
  result := 'r' + GetCoreRevision;
end;

function FPCCaption: string;
begin
  result := 'FPC Version: ' + {$I %FPCVERSION%};
end;

function PlatformCaption: string;
begin
  result := 'Platform: ' + {$I %FPCTARGETCPU%} + '-' + {$I %FPCTARGETOS%};
end;

function GetProgramInfo: string;
begin
  Result := 'EpiData Entry Client' + LineEnding +
            EntryVersionCaption + ' ' + RevisionCaption + LineEnding +
            CoreVersionCaption + ' ' + CoreRevisionCaption + LineEnding +
            FPCCaption + LineEnding +
            PlatformCaption;
end;

{ TAboutForm }

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  AboutPageControl.PageIndex := 0;

  VersionLabel.Caption     := EntryVersionCaption;;
  CoreVersionLabel.Caption := CoreVersionCaption;
  RevisionLabel.Caption    := RevisionCaption;
  FPCVersionLabel.Caption  := FPCCaption;
  PlatformLabel.Caption    := PlatformCaption;
end;

end.

