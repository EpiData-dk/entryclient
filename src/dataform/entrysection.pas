unit entrysection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, control_types, epidatafiles;

type
  { TEntrySection }

  TEntrySection = class(TGroupBox, IEntryControl)
  private
    FSection: TEpiSection;
    procedure SetSection(AValue: TEpiSection);
  public
    procedure UpdateSettings;
    property Section: TEpiSection read FSection write SetSection;
  end;

implementation

uses
  settings;

{ TEntrySection }

procedure TEntrySection.SetSection(AValue: TEpiSection);
begin
  if FSection = AValue then Exit;
  FSection := AValue;

  with AValue do
  begin
    Self.Top := Top;
    Self.Left := Left;
    Self.Width := Width;
    Self.Height := Height;
    Self.Caption := Caption.Text;
  end;
  UpdateSettings;
end;

procedure TEntrySection.UpdateSettings;
begin
  Self.Font.Assign(EntrySettings.SectionFont)
end;

end.

