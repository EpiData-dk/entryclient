unit settings_general_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn, MaskEdit,
  ExtCtrls, settings2_interface, settings;

type

  { TSettingsGeneralFrame }

  TSettingsGeneralFrame = class(TFrame, ISettingsFrame)
    AssociateBtn: TButton;
    AssociateLabel: TLabel;
    NotesGroupBox: TRadioGroup;
    ShowProcessToolBarChkBox: TCheckBox;
    HintTimeOutEdit: TMaskEdit;
    Label1: TLabel;
    Label2: TLabel;
    MultipleInstanceChkBox: TCheckBox;
    RecordsToSkipEdit: TMaskEdit;
    ShowWelcomeChkBox: TCheckBox;
    UnAssociateBtn: TButton;
    procedure AssociateBtnClick(Sender: TObject);
    procedure UnAssociateBtnClick(Sender: TObject);
  private
    { private declarations }
    FData: PEntrySettings;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    procedure SetSettings(Data: PEntrySettings);
    function  ApplySettings: boolean;
  end;

implementation

{$R *.lfm}

uses
  settings2, shortcuts
  {$IFDEF WINDOWS}
  ,registry
  {$ENDIF};

{ TSettingsGeneralFrame }

procedure TSettingsGeneralFrame.AssociateBtnClick(Sender: TObject);
{$IFDEF WINDOWS}
var
  Reg: TRegistry;
const
  ExtA = '.epx';
  ExtB = '.epz';
  FileType = 'EpiDataProjectFile';
begin
  Reg:=TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    // File Extesion association - associate with "FileType" description!
    Reg.OpenKey(ExtA, True);
    Reg.WriteString('', FileType);
    Reg.CloseKey;
    Reg.OpenKey(ExtB, True);
    Reg.WriteString('', FileType);
    Reg.CloseKey;

    // File Type registration - set programm to execute, etc.
    Reg.OpenKey(FileType, True);
    Reg.WriteString('', 'EpiData Project File');
    Reg.CloseKey;
    // - icon
    Reg.OpenKey(Filetype + '\DefaultIcon', True);
    Reg.WriteString('', Application.ExeName + ',0');
    reg.CloseKey;
    // - executable.
    Reg.OpenKey(Filetype + '\Shell\Open\Command', True);
    Reg.Writestring('','"' + Application.ExeName + '" "%1"');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TSettingsGeneralFrame.UnAssociateBtnClick(Sender: TObject);
{$IFDEF WINDOWS}
var
  Reg: TRegistry;
const
  ExtA = '.epx';
  ExtB = '.epz';
  FileType = 'EpiDataProjectFile';
begin
  Reg:=TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    Reg.DeleteKey(ExtA);
    Reg.DeleteKey(ExtB);
    Reg.DeleteKey(FileType);
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

constructor TSettingsGeneralFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  {$IFNDEF WINDOWS}
  AssociateBtn.Visible := false;
  UnAssociateBtn.Visible := false;
  AssociateLabel.Visible := false;
  {$ENDIF}
end;


procedure TSettingsGeneralFrame.SetSettings(Data: PEntrySettings);
begin
  FData := Data;
  with FData^ do
  begin
    ShowWelcomeChkBox.Checked := ShowWelcome;
    MultipleInstanceChkBox.Checked := MultipleInstances;
    ShowProcessToolBarChkBox.Checked := ShowWorkToolbar;
    RecordsToSkipEdit.Text := IntToStr(RecordsToSkip);
    HintTimeOutEdit.Text := IntToStr(HintTimeOut);
    NotesGroupBox.ItemIndex := NotesDisplay;
  end;
end;

function TSettingsGeneralFrame.ApplySettings: boolean;
begin
  result := false;
  if StrToInt(RecordsToSkipEdit.Text) < 1 then exit;

  with FData^ do
  begin
    ShowWelcome := ShowWelcomeChkBox.Checked;
    ShowWorkToolbar := ShowProcessToolBarChkBox.Checked;
    MultipleInstances := MultipleInstanceChkBox.Checked;
    RecordsToSkip := StrToInt(RecordsToSkipEdit.Text);
    HintTimeOut := StrToInt(HintTimeOutEdit.Text);
    NotesDisplay := NotesGroupBox.ItemIndex;
  end;

  result := true;
end;

initialization

begin
  RegisterSettingFrame(0, TSettingsGeneralFrame, 'General');
end;

end.

