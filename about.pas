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
    CoreRevisionLabel: TLabel;
    CoreVersionLabel: TLabel;
    FPCVersionLabel: TLabel;
    Image1: TImage;
    EntryRevisionLabel: TLabel;
    Memo1: TMemo;
    AboutPageControl: TPageControl;
    AboutPage: TTabSheet;
    Panel1: TPanel;
    PlatformLabel: TLabel;
    VersionLabel: TLabel;
    VersionPage: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure VersionPageResize(Sender: TObject);
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

function EntryRevisionCaption: string;
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
            EntryVersionCaption + ' ' + EntryRevisionCaption + LineEnding +
            CoreVersionCaption + ' ' + CoreRevisionCaption + LineEnding +
            FPCCaption + LineEnding +
            PlatformCaption;
end;

{ TAboutForm }

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  AboutPageControl.PageIndex := 0;

  VersionLabel.Caption       := EntryVersionCaption;
  EntryRevisionLabel.Caption := EntryRevisionCaption;
  CoreVersionLabel.Caption   := CoreVersionCaption;
  CoreRevisionLabel.Caption  := CoreRevisionCaption;
  FPCVersionLabel.Caption    := FPCCaption;
  PlatformLabel.Caption      := PlatformCaption;
end;

procedure TAboutForm.VersionPageResize(Sender: TObject);
begin
  Panel1.Left := (VersionPage.Width div 2) - (Panel1.Width div 2);
  Panel1.Top  := (VersionPage.Height div 2) - (Panel1.Height div 2);
end;

end.

