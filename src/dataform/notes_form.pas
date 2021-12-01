unit notes_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls;

type

  { TNotesForm }

  TNotesForm = class(TForm)
    BitBtn1: TBitBtn;
    NotesMemo: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    class procedure RestoreDefaultPos(F: TForm = nil);
  end;

implementation

{$R *.lfm}

uses
  settings, main, LCLType;

{ TNotesForm }

procedure TNotesForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  SaveFormPosition(Self, 'NotesForm');
end;

procedure TNotesForm.FormDestroy(Sender: TObject);
var
  B: Boolean;
begin
  B:=true;
  FormCloseQuery(nil, B);
end;

procedure TNotesForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
  begin
    Key := VK_UNKNOWN;
    Close;
  end;
end;

procedure TNotesForm.FormShow(Sender: TObject);
begin
  LoadFormPosition(Self, 'NotesForm');
end;

class procedure TNotesForm.RestoreDefaultPos(F: TForm);
var
  CreatedF: Boolean;
begin
  CreatedF := false;
  if not Assigned(F) then
  begin
    F := TForm.Create(nil);
    CreatedF := true;
  end;

  with F do
  begin
    LockRealizeBounds;
    Width := 340;
    Height := 350;
    Top := MainForm.Top;
    Left := MainForm.Left + MainForm.Width + 10;
    UnlockRealizeBounds;
  end;
  SaveFormPosition(F, 'NotesForm');
  if CreatedF then F.Free;
end;

{ TNotesForm }

end.

