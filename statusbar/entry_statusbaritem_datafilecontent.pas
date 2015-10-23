unit entry_statusbaritem_datafilecontent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, epiv_custom_statusbar, entry_statusbar,
  StdCtrls, epitools_statusbarparser, epidatafiles;

type

  { TEntryClientStatusBarDatafileContent }

  TEntryClientStatusBarDatafileContent = class(TEntryClientStatusBarItem)
  private
    FLabel: TLabel;
    FParser: TEpiStatusbarStringParser;
    procedure ParseContentString;
    procedure IdentFound(Sender: TObject; IdentType: TEpiSBSIdentType;
      const IdentName: string);
    procedure TextFound(Sender: TObject; const S: string);
  protected
    procedure Update(Condition: TEpiVCustomStatusbarUpdateCondition); override;
    procedure Update(Condition: TEntryClientStatusbarUpdateCondition); override;
  public
    constructor Create(AStatusBar: TEpiVCustomStatusBar); override;
    destructor Destroy; override;
    function GetPreferedWidth: Integer; override;
  end;

implementation

uses
  Controls;

{ TEntryClientStatusBarDatafileContent }

procedure TEntryClientStatusBarDatafileContent.ParseContentString;
begin
  if (not Assigned(DataForm)) then exit;

  Panel.DisableAutoSizing;
  FLabel.Caption := '';
  FParser.ParseString(Dataform.DataFile.StatusbarContentString);
  Panel.EnableAutoSizing;
end;

procedure TEntryClientStatusBarDatafileContent.IdentFound(Sender: TObject;
  IdentType: TEpiSBSIdentType; const IdentName: string);
var
  F: TEpiField;
begin
  F := Dataform.DataFile.Fields.FieldByName[IdentName];
  if (not Assigned(F)) then
    Exit;

  case IdentType of
    esiData:
      FLabel.Caption := FLabel.Caption + Dataform.FieldEditFromField(F).Text;
    esiField:
      FLabel.Caption := FLabel.Caption + F.Name;
    esiCaption:
      FLabel.Caption := FLabel.Caption + F.Question.Text;
  end;
end;

procedure TEntryClientStatusBarDatafileContent.TextFound(Sender: TObject;
  const S: string);
begin
  FLabel.Caption := FLabel.Caption + S;
end;

procedure TEntryClientStatusBarDatafileContent.Update(
  Condition: TEpiVCustomStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    sucDefault:
      ParseContentString;
    sucDocFile: ;
    sucDataFile:
      ParseContentString;
    sucSelection:
      ParseContentString;
    sucSave: ;
  end;
end;

procedure TEntryClientStatusBarDatafileContent.Update(
  Condition: TEntryClientStatusbarUpdateCondition);
begin
  inherited Update(Condition);

  case Condition of
    esucDataform:
      ParseContentString;
  end;
end;

constructor TEntryClientStatusBarDatafileContent.Create(
  AStatusBar: TEpiVCustomStatusBar);
begin
  inherited Create(AStatusBar);

  Resizable := true;

  FParser := TEpiStatusbarStringParser.Create;
  FParser.OnIdentifierFound := @IdentFound;
  FParser.OnTextFound := @TextFound;

  FLabel := TLabel.Create(Panel);
  FLabel.AnchorParallel(akLeft, 2, Panel);
  FLabel.AnchorVerticalCenterTo(Panel);
  FLabel.Caption := '';
  FLabel.Parent := Panel;
end;

destructor TEntryClientStatusBarDatafileContent.Destroy;
begin
  FParser.Free;
  inherited Destroy;
end;

function TEntryClientStatusBarDatafileContent.GetPreferedWidth: Integer;
begin
  if not Panel.HandleAllocated then
    begin
      Result := inherited GetPreferedWidth;
      Exit;
    end;

  Result := FLabel.Left + FLabel.Width + 2;
end;

initialization
  EpiV_RegisterCustomStatusBarItem(TEntryClientStatusBarDatafileContent);

end.

