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
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure RestoreDefaultPos;
  end;

implementation

{$R *.lfm}

uses
  settings, main;

{ TNotesForm }

procedure TNotesForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
//  if ManagerSettings.SaveWindowPositions then
  SaveFormPosition(Self, 'NotesForm');
end;

procedure TNotesForm.FormDestroy(Sender: TObject);
var
  B: Boolean;
begin
  B:=true;
  FormCloseQuery(nil, B);
end;

procedure TNotesForm.FormShow(Sender: TObject);
begin
//  if ManagerSettings.SaveWindowPositions then
  LoadFormPosition(Self, 'NotesForm');
end;

procedure TNotesForm.RestoreDefaultPos;
begin
  BeginFormUpdate;
  Width := 340;
  Height := 350;
  Top := MainForm.Top;
  Left := MainForm.Left + MainForm.Width + 10;
  EndFormUpdate;
  SaveFormPosition(Self, 'NotesForm');
end;

{ TNotesForm }

end.

