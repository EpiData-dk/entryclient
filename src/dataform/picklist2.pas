unit picklist2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, laz.VirtualTrees, epidatafiles, epivaluelabels, epicustombase;

type

  { TValueLabelsPickListForm2 }

  TValueLabelsPickListForm2 = class(TForm)
    FilterEdit: TEdit;
    Panel1: TPanel;
    procedure FilterEditChange(Sender: TObject);
    procedure FilterEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Filter Edit }
    procedure FilterEditEnter(Sender: TObject);
    procedure FilterEditExit(Sender: TObject);
    procedure UpdateFilter;
  private
    { VST }
    VST: TLazVirtualStringTree;
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
  public
    constructor Create(TheOwner: TComponent; Const AField: TEpiField);
    class procedure RestoreDefaultPos;
    procedure   SetInitialValue(Const S: string);
    property    SelectedValueLabel: TEpiCustomValueLabel read FSelectedValueLabel;
  end;

var
  ValueLabelsPickListForm2: TValueLabelsPickListForm2;

resourcestring
  rsPickListFilter = '(filter)';
  rsPickListFormCaptionDefault = 'Value Labels';
  rsPickListFormCaptionNoValue = 'Value Labels: Illegal value, delete to see all';

implementation

{$R *.lfm}

uses
  LazUTF8, LCLType, LCLIntf, LMessages, LCLMessageGlue;

const
  FilterColor = clGrayText;

{ TValueLabelsPickListForm2 }

procedure TValueLabelsPickListForm2.FilterEditChange(Sender: TObject);
begin
  UpdateFilter;
end;

procedure TValueLabelsPickListForm2.FilterEditEnter(Sender: TObject);
begin
  if FilterEdit.Text = rsPickListFilter then
  with FilterEdit do
    begin
      Text := '';
      Font.Color := clDefault;
    end;
end;

procedure TValueLabelsPickListForm2.FilterEditExit(Sender: TObject);
begin
  if FilterEdit.Text = '' then
  with FilterEdit do
    begin
      Text := rsPickListFilter;
      Font.Color := FilterColor;
    end;
end;

procedure TValueLabelsPickListForm2.UpdateFilter;
var
  Node: PVirtualNode;
  T: String;
  S0: String;
  S1: String;
  FocusNode: PVirtualNode;
begin
  T := UTF8LowerString(FilterEdit.Text);

  FocusNode := VST.FocusedNode;

  VST.BeginUpdate;
  Node := VST.GetFirst();
  if (T = '') or (T = rsPickListFilter) then
    begin
      while Assigned(Node) do
      begin
        VST.IsVisible[Node] := true;
        Node := VST.GetNext(Node);
      end;
    end
  else
    begin
      while Assigned(Node) do
      begin
        S0 := UTF8LowerString(VST.Text[Node, 0]);
        S1 := UTF8LowerString(VST.Text[Node, 1]);

        VST.IsVisible[Node] := (UTF8Pos(T, S1) > 0) or (UTF8Pos(T, S0) > 0);

        Node := VST.GetNext(Node);
      end;
    end;

  if (not VST.IsVisible[FocusNode]) then
    FocusNode := VST.GetNextVisible(FocusNode);

  if (not Assigned(FocusNode)) then
    FocusNode := VST.GetFirstVisible();

  if Assigned(FocusNode) then
    Caption := rsPickListFormCaptionDefault
  else
    Caption := rsPickListFormCaptionNoValue;

  SelectNode(FocusNode);
  VST.Invalidate;
  VST.EndUpdate;
end;

procedure TValueLabelsPickListForm2.FilterEditKeyDown(Sender: TObject;
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
        if Assigned(FSelectedValueLabel) then
          ModalResult := mrOK;
      end;
  end;
end;

procedure TValueLabelsPickListForm2.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
    ModalResult := mrCancel;
end;

procedure TValueLabelsPickListForm2.SelectNode(Node: PVirtualNode);
begin
  VST.Selected[Node] := true;
  VST.FocusedNode    := Node;
end;

procedure TValueLabelsPickListForm2.VSTDblClick(Sender: TObject);
begin
  if Assigned(FSelectedValueLabel) then
    ModalResult := mrOK;
end;

procedure TValueLabelsPickListForm2.VSTFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if Assigned(Node) then
    FSelectedValueLabel := FField.ValueLabelSet[Node^.Index]
  else
    FSelectedValueLabel := nil;
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
      if Assigned(FSelectedValueLabel) then
        ModalResult := mrOk;
      DoDefault := false;
    end;
end;

constructor TValueLabelsPickListForm2.Create(TheOwner: TComponent; const AField: TEpiField);
begin
  inherited Create(TheOwner);
  FField := AField;
  FValueLabelSet := FField.ValueLabelSet;

  with FilterEdit do
  begin
    OnEnter    := @FilterEditEnter;
    OnExit     := @FilterEditExit;
  end;

  VST := TLazVirtualStringTree.Create(self);
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

    OnDblClick     := @VSTDblClick;
    OnFocusChanged := @VSTFocusChanged;
    OnGetText      := @VSTGetText;
    OnKeyAction    := @VSTKeyAction;

    RootNodeCount := AField.ValueLabelSet.Count;

    EndUpdate;
  end;

  UpdateFilter;
end;

class procedure TValueLabelsPickListForm2.RestoreDefaultPos;
begin

end;

procedure TValueLabelsPickListForm2.SetInitialValue(const S: string);
begin
  FilterEdit.Text := S;
end;

end.

