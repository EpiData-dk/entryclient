unit picklist2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, VirtualTrees, epidatafiles, epivaluelabels, epicustombase;

type

  { TValueLabelsPickListForm2 }

  TValueLabelsPickListForm2 = class(TForm)
    Edit1: TEdit;
    Panel1: TPanel;
    procedure Edit1Change(Sender: TObject);
  private
    { VST }
    VST: TVirtualStringTree;
    procedure VSTDblClick(Sender: TObject);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VSTFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
  private
    FSelectedValueLabel: TEpiCustomValueLabel;
    FField: TEpiField;
    FValueLabelSet: TEpiValueLabelSet;
  public
    constructor Create(TheOwner: TComponent; Const AField: TEpiField);
    class procedure RestoreDefaultPos;
    procedure   SetInitialValue(Const S: string);
    property    SelectedValueLabel: TEpiCustomValueLabel read FSelectedValueLabel;
  end;

var
  ValueLabelsPickListForm2: TValueLabelsPickListForm2;

implementation

{$R *.lfm}

uses
  LazUTF8;

const
  PICKLIST_KEY = '$PICKLIST_KEY';

{ TValueLabelsPickListForm2 }

procedure TValueLabelsPickListForm2.Edit1Change(Sender: TObject);
var
  S: String;
  VL: TEpiCustomValueLabel;
  I: Integer;
  Node: PVirtualNode;
begin
  S := UTF8UpperCase(TEdit(Sender).Text);

  I := -1;
  for VL in FValueLabelSet do
  begin
    Inc(i);

    if Pos(S, UTF8UpperCase(VL.ValueAsString)) = 1 then
      Break;

    if Pos(S, UTF8UpperCase(VL.TheLabel.Text)) >= 1 then
      Break;
  end;

  if I >= FValueLabelSet.Count then exit;

  Node := VST.GetFirst();
  while Assigned(Node) do
  begin
    if Node^.Index = I then
      break
    else
      Node := VST.GetNext(Node);
  end;

  if Assigned(Node) then
    begin
      VST.Selected[Node] := true;
      VST.FocusedNode := Node;
    end;
end;

procedure TValueLabelsPickListForm2.VSTDblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TValueLabelsPickListForm2.VSTGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  VL: TEpiCustomValueLabel;
begin
  VL := FField.ValueLabelSet[Node^.Index];

  case Column of
    0: CellText := VL.ValueAsString;
    1: CellText := VL.TheLabel.Text;
  end;
end;

procedure TValueLabelsPickListForm2.VSTFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  FSelectedValueLabel := FField.ValueLabelSet[Node^.Index];
end;

constructor TValueLabelsPickListForm2.Create(TheOwner: TComponent; const AField: TEpiField);
begin
  inherited Create(TheOwner);
  FField := AField;
  FValueLabelSet := FField.ValueLabelSet;

  VST := TVirtualStringTree.Create(self);
  with VST do
  begin
    BeginUpdate;

    Align := alClient;
    Parent := Self;

    with TreeOptions do
    begin
      AnimationOptions  := [];
      AutoOptions       := [];
      ExportMode        := emAll;
      MiscOptions       := [toFullRepaintOnResize, toGridExtensions];
      PaintOptions      := [toShowHorzGridLines, toShowVertGridLines, toThemeAware, toFullVertGridLines];
      SelectionOptions  := [toExtendedFocus, toFullRowSelect];
      StringOptions     := [];
    end;

    with Header do
    begin
      Options := [hoAutoResize, hoColumnResize, hoDblClickResize, hoVisible, hoFullRepaintOnResize];

      with Columns.Add do
      begin
        Text := 'Value';
        Width := 120;
      end;

      with Columns.Add do
        Text := 'Label';

      MainColumn := 0;
      AutoSizeIndex := 1;
    end;

    OnGetText      := @VSTGetText;
    OnFocusChanged := @VSTFocusChanged;
    OnDblClick := @VSTDblClick;

    RootNodeCount := AField.ValueLabelSet.Count;

    EndUpdate;
  end;
end;

class procedure TValueLabelsPickListForm2.RestoreDefaultPos;
begin

end;

procedure TValueLabelsPickListForm2.SetInitialValue(const S: string);
begin
  Edit1.Text := S;
  Edit1Change(Edit1);
end;

end.

