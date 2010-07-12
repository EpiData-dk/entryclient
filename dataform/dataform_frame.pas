unit dataform_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, epidatafiles,
  epicustombase, StdCtrls;

type

  { TDataFormFrame }

  TDataFormFrame = class(TFrame)
    DataFormScroolBox: TScrollBox;
  private
    FDataFile: TEpiDataFile;
    procedure SetDataFile(const AValue: TEpiDataFile);

  private
    { DataForm Control }
    function  NewSectionControl(EpiControl: TEpiCustomControlItem): TControl;
    function  NewFieldControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
    function  NewHeadingControl(EpiControl: TEpiCustomControlItem;
      AParent: TWinControl): TControl;
  public
    property  DataFile: TEpiDataFile read FDataFile write SetDataFile;
  end; 

implementation

{$R *.lfm}

{ TDataFormFrame }

procedure TDataFormFrame.SetDataFile(const AValue: TEpiDataFile);
var
  i: Integer;
  TheParent: TWinControl;
  j: Integer;
begin
  if FDataFile = AValue then exit;
  FDataFile := AValue;

  // Create components.
  Name := DataFile.Id;

  // Register the visual feedback hook.
  DataFile.BeginUpdate;
{  DataFile.RegisterOnChangeHook(@VisualFeedbackHook);
  DataFile.Sections.RegisterOnChangeHook(@VisualFeedbackHook);
  DataFile.Fields.RegisterOnChangeHook(@VisualFeedbackHook);
  DataFile.Headings.RegisterOnChangeHook(@VisualFeedbackHook);  }

  with DataFile do
  begin
    if not ((Fields.Count = 0) and (Headings.Count = 0)) then
    begin
      for i := 0 to Sections.Count - 1 do
      begin
        if Section[i] <> MainSection then
          TheParent := TWinControl(NewSectionControl(Section[i]))
        else
          TheParent := DataFormScroolBox;

        with Section[i] do
        begin
          for j := 0 to Fields.Count - 1 do
            NewFieldControl(Field[j], TheParent);
          for j := 0 to Headings.Count - 1 do
            NewHeadingControl(Heading[j], TheParent);
        end;
      end;
    end;
  end;
  DataFile.EndUpdate;
end;

function TDataFormFrame.NewSectionControl(EpiControl: TEpiCustomControlItem
  ): TControl;
begin
  result := TGroupBox.Create(DataFormScroolBox);

  with EpiControl do
  begin
    Result.Top := Top;
    Result.Left := Left;
    Result.Width := TEpiSection(EpiControl).Width;
    Result.Height := TEpiSection(EpiControl).Height;
  end;
  Result.Parent := DataFormScroolBox;
end;

function TDataFormFrame.NewFieldControl(EpiControl: TEpiCustomControlItem;
  AParent: TWinControl): TControl;
var
  Lbl: TLabel;
begin
  Result := TEdit.Create(AParent);
  Lbl    := TLabel.Create(Result);

  With TEpiField(EpiControl) do
  begin
    Result.Top  := Top;
    Result.Left := Left;
    Result.Width := Length * DataFormScroolBox.Canvas.TextWidth('W');
    Lbl.Left    := Question.Left;
    Lbl.Top     := Question.Top;
    Lbl.Caption := Question.Caption.Text;
  end;
  Result.Parent := AParent;
  Lbl.Parent    := AParent;
end;

function TDataFormFrame.NewHeadingControl(EpiControl: TEpiCustomControlItem;
  AParent: TWinControl): TControl;
begin
  Result := TLabel.Create(AParent);

  With TEpiHeading(EpiControl) do
  begin
    Result.Top := Top;
    Result.Left := Left;
    Result.Caption := Caption.Text;
  end;
  Result.Parent := AParent;
end;


end.

