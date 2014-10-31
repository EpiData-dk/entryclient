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
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { VST }
    VST: TVirtualStringTree;
    procedure SelectNode(Node: PVirtualNode);
    procedure VSTDblClick(Sender: TObject);
    procedure VSTFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VSTKeyAction(Sender: TBaseVirtualTree; var CharCode: Word;
      var Shift: TShiftState; var DoDefault: Boolean);
  private
    FSelectedValueLabel: TEpiCustomValueLabel;
    FField: TEpiField;
    FValueLabelSet: TEpiValueLabelSet;
    procedure IndexOfText(Const S: string; out Index: integer);
    procedure NodeByIndex(Const Index: Integer; Out Node: PVirtualNode);
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
  LazUTF8, LCLType, LCLIntf, LMessages, LCLMessageGlue;

{ TValueLabelsPickListForm2 }

procedure TValueLabelsPickListForm2.Edit1Change(Sender: TObject);
var
  I: Integer;
  Node: PVirtualNode;
begin
  IndexOfText(TEdit(Sender).Text, I);
  if I < 0 then
    exit;

  NodeByIndex(I, Node);

  if Assigned(Node) then
    SelectNode(Node);
end;

procedure TValueLabelsPickListForm2.Edit1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  NextNode: PVirtualNode;
  I: integer;
  Node: PVirtualNode;
begin
  case Key of
    // Pass Up/Down PageUp/PageDown on to VST for convinience.
    VK_DOWN,
    VK_UP,
    VK_PRIOR,
    VK_NEXT:
      begin
        LCLSendKeyDownEvent(VST,
          Key,
          ShiftStateToKeys(Shift),
          false,
          false
        );

        Key := VK_UNKNOWN;
      end;

    VK_RETURN:
      begin
        if (Shift <> []) then exit;

        IndexOfText(Edit1.Text, I);
        if I < 0 then Exit;

        NodeByIndex(I, Node);
        SelectNode(Node);

        ModalResult := mrOK;
      end;
  end;
end;

procedure TValueLabelsPickListForm2.SelectNode(Node: PVirtualNode);
begin
  VST.Selected[Node] := true;
  VST.FocusedNode    := Node;
end;

procedure TValueLabelsPickListForm2.VSTDblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TValueLabelsPickListForm2.VSTFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  FSelectedValueLabel := FField.ValueLabelSet[Node^.Index];
  Edit1.Text := FSelectedValueLabel.ValueAsString;
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

procedure TValueLabelsPickListForm2.VSTKeyAction(Sender: TBaseVirtualTree;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
begin
  if (CharCode = VK_RETURN) and (Shift = []) then
    begin
      ModalResult := mrOk;
      DoDefault := false;
    end;
end;

procedure TValueLabelsPickListForm2.IndexOfText(const S: string; out
  Index: integer);
var
  VL: TEpiCustomValueLabel;
begin
  Index := 0;
  for VL in FValueLabelSet do
  begin
    if Pos(UTF8UpperCase(S), UTF8UpperCase(VL.ValueAsString)) = 1 then
      Break;

    if Pos(UTF8UpperCase(S), UTF8UpperCase(VL.TheLabel.Text)) >= 1 then
      Break;

    Inc(Index);
  end;

  if Index >= FValueLabelSet.Count then
    Index := -1;
end;

procedure TValueLabelsPickListForm2.NodeByIndex(const Index: Integer; out
  Node: PVirtualNode);
begin
  Node := VST.GetFirst();
  while Assigned(Node) do
  begin
    if Node^.Index = Index then
      Exit
    else
      Node := VST.GetNext(Node);
  end;
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
    OnDblClick     := @VSTDblClick;
    OnKeyAction := @VSTKeyAction;

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

