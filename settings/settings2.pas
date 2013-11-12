unit settings2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, ComCtrls;

type

  { TSettings2Form }

  TSettings2Form = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel1: TPanel;
    Splitter1: TSplitter;
    SettingsView: TTreeView;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure SettingsViewChange(Sender: TObject; Node: TTreeNode);
    procedure SettingsViewChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
  private
    { private declarations }
    FActiveFrame: TFrame;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    class procedure RestoreDefaultPos;
  end; 

procedure RegisterSettingFrame(const Order: byte;
  const AValue: TCustomFrameClass; const AName: string);

implementation

{$R *.lfm}

uses
  settings2_interface, settings, entryprocs;

var
  Frames: TStringList = nil;

procedure RegisterSettingFrame(const Order: byte;
  const AValue: TCustomFrameClass; const AName: string);
var
  i: LongInt;
begin
  if not Assigned(Frames) then
    Frames := TStringList.Create;

  if not Supports(AValue, ISettingsFrame) then
    Raise Exception.CreateFmt('Class %s does not support required interface', [AValue.ClassName]);


  for i := Frames.Count to Order do
    Frames.Add('');

  Frames.Strings[Order] := AName;
  Frames.Objects[Order] := TObject(AValue);
end;

procedure FinalizeFrames;
var
  i: integer;
begin
  for i := 0 to Frames.Count - 1 do
    Frames.Strings[i] := '';
  Frames.Free;
end;

{ TSettings2Form }

procedure TSettings2Form.SettingsViewChange(Sender: TObject; Node: TTreeNode);
begin
  // Happens after the change...
  if csDestroying in ComponentState then exit;

  FActiveFrame := TFrame(Node.Data);
  FActiveFrame.Show;
end;

procedure TSettings2Form.FormShow(Sender: TObject);
begin
  FActiveFrame := TFrame(SettingsView.Items[0].Data);
  SettingsView.Selected := SettingsView.Items[0];
  LoadFormPosition(Self, 'SettingsForm');

  TFrame(SettingsView.Items[0].Data).Show;
  SettingsView.SetFocus;
end;

procedure TSettings2Form.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if ModalResult = mrCancel then exit;

  CanClose := false;
  if not (FActiveFrame as ISettingsFrame).ApplySettings then exit;

  SaveSettingToIni(GetIniFileName);
  SaveFormPosition(Self, 'SettingsForm');
  CanClose := true;
end;

procedure TSettings2Form.SettingsViewChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  // Happens before the change...
  if csDestroying in ComponentState then exit;

  FActiveFrame := TFrame(Node.Data);
  AllowChange := (FActiveFrame as ISettingsFrame).ApplySettings;
  if not AllowChange then exit;

  FActiveFrame.Hide;
end;

constructor TSettings2Form.Create(TheOwner: TComponent);
var
  i: Integer;
  Frame: TCustomFrame;
  FrameClass: TCustomFrameClass;
begin
  inherited Create(TheOwner);

  for i := 0 to Frames.Count - 1 do
  begin
    FrameClass := TCustomFrameClass(Frames.Objects[i]);
    Frame := FrameClass.Create(Self);
    (Frame as ISettingsFrame).SetSettings(@EntrySettings);
    Frame.Hide;
    Frame.Align := alClient;
    Frame.Parent := Self;
    SettingsView.Items.AddObject(nil, Frames[i], Pointer(Frame));
  end;
end;

class procedure TSettings2Form.RestoreDefaultPos;
var
  Aform: TForm;
begin
  Aform := TForm.Create(nil);
  Aform.Width := 600;
  Aform.Height := 480;
  Aform.top := (Screen.Monitors[0].Height - Aform.Height) div 2;
  Aform.Left := (Screen.Monitors[0].Width - Aform.Width) div 2;
  SaveFormPosition(Aform, 'SettingsForm');
  AForm.free;
end;

{ TSettings2Form }

finalization
begin
  FinalizeFrames;
end;

end.

