unit settings_general_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn, MaskEdit,
  ExtCtrls, Buttons, settings2_interface, settings;

type

  { TSettingsGeneralFrame }

  TSettingsGeneralFrame = class(TFrame, ISettingsFrame)
    AssociateBtn: TButton;
    AssociateLabel: TLabel;
    AutomaticUpdatesChkBox: TCheckBox;
    CheckUpdateGrpBox: TGroupBox;
    DaysBetweenUpdatedEdit: TMaskEdit;
    Label4: TLabel;
    ShowValuelabelsAsNoteChkBox: TCheckBox;
    FormatHlpBtn: TBitBtn;
    ClipBoardFormatCombo: TComboBox;
    Label3: TLabel;
    NotesGroupBox: TRadioGroup;
    ShowProcessToolBarChkBox: TCheckBox;
    HintTimeOutEdit: TMaskEdit;
    Label1: TLabel;
    Label2: TLabel;
    MultipleInstanceChkBox: TCheckBox;
    RecordsToSkipEdit: TMaskEdit;
    UnAssociateBtn: TButton;
    procedure AssociateBtnClick(Sender: TObject);
    procedure FormatHlpBtnClick(Sender: TObject);
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
  settings2, shortcuts, LCLIntf, epimiscutils;

{ TSettingsGeneralFrame }

procedure TSettingsGeneralFrame.AssociateBtnClick(Sender: TObject);
begin
{$IFDEF WINDOWS}
  AssociateFiles('EpiData EntryClient', 'Entry Tool', Application.ExeName);
{$ENDIF}
end;

procedure TSettingsGeneralFrame.FormatHlpBtnClick(Sender: TObject);
begin
  OpenURL('http://epidata.info/dokuwiki/doku.php?id=documentation:clipboardformat');
end;

procedure TSettingsGeneralFrame.UnAssociateBtnClick(Sender: TObject);
begin
{$IFDEF WINDOWS}
  UnAssociateFiles('EpiData EntryClient', 'Entry Tool', Application.ExeName);
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
    MultipleInstanceChkBox.Checked := MultipleInstances;
    ShowProcessToolBarChkBox.Checked := ShowWorkToolbar;
    RecordsToSkipEdit.Text := IntToStr(RecordsToSkip);
    HintTimeOutEdit.Text := IntToStr(HintTimeOut);
    NotesGroupBox.ItemIndex := NotesDisplay;
    ClipBoardFormatCombo.Text := CopyToClipBoardFormat;
    ShowValuelabelsAsNoteChkBox.Checked := ValueLabelsAsNotes;
    AutomaticUpdatesChkBox.Checked := CheckForUpdates;
    DaysBetweenUpdatedEdit.EditText := IntToStr(DaysBetweenChecks);
  end;
end;

function TSettingsGeneralFrame.ApplySettings: boolean;
begin
  result := false;
  if StrToInt(RecordsToSkipEdit.Text) < 1 then exit;
  if AutomaticUpdatesChkBox.Checked and
     (Trim(DaysBetweenUpdatedEdit.EditText) = '')
  then
    Exit(false);

  with FData^ do
  begin
    ShowWorkToolbar := ShowProcessToolBarChkBox.Checked;
    MultipleInstances := MultipleInstanceChkBox.Checked;
    RecordsToSkip := StrToInt(RecordsToSkipEdit.Text);
    HintTimeOut := StrToInt(HintTimeOutEdit.Text);
    NotesDisplay := NotesGroupBox.ItemIndex;
    CopyToClipBoardFormat := ClipBoardFormatCombo.Text;
    ValueLabelsAsNotes := ShowValuelabelsAsNoteChkBox.Checked;
    CheckForUpdates    := AutomaticUpdatesChkBox.Checked;
    if CheckForUpdates then
      DaysBetweenChecks   := StrToInt(Trim(DaysBetweenUpdatedEdit.EditText));;
  end;

  result := true;
end;

initialization

begin
  RegisterSettingFrame(0, TSettingsGeneralFrame, 'General');
end;

end.

