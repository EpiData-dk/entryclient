unit entrylabel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, control_types, epidatafiles;

type
  { TEntryLabel }

  TEntryLabel = class(TLabel, IEntryControl)
  private
    FHeading: TEpiHeading;
    procedure SetHeading(AValue: TEpiHeading);
  public
    procedure UpdateSettings;
    property Heading: TEpiHeading read FHeading write SetHeading;
  end;

implementation

uses
  settings, epidatafilestypes;

{ TEntryLabel }

procedure TEntryLabel.SetHeading(AValue: TEpiHeading);
begin
  if FHeading = AValue then Exit;
  FHeading := AValue;

  With FHeading do
  begin
    Self.Top := Top;
    Self.Left := Left;
    Self.Caption := Caption.Text;
  end;
  UpdateSettings;
end;

procedure TEntryLabel.UpdateSettings;
begin
  case FHeading.HeadingType of
    htH1: Font.Assign(EntrySettings.HeadingFont1);
    htH2: Font.Assign(EntrySettings.HeadingFont2);
    htH3: Font.Assign(EntrySettings.HeadingFont3);
    htH4: Font.Assign(EntrySettings.HeadingFont4);
    htH5: Font.Assign(EntrySettings.HeadingFont5);
  end;
end;

end.

