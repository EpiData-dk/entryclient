unit RelateTreeUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ImgList;

type
  TRelateTreeForm = class(TForm)
    RelateTree: TTreeView;
    RelateTreeImages: TImageList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure RelateTreeChange(Sender: TObject; Node: TTreeNode);
    procedure RelateTreeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RelateTreeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RelateTreeForm: TRelateTreeForm;

implementation

{$R *.DFM}

USES
  EpiTypes,MainUnit,dataFormUnit,HintFormUnit;

VAR
  HintFormOn: Boolean;
  HintNode: TTreeNode;



Procedure FillMemo(AList:TStrings; df:PDatafileInfo);
VAR
  RelDf:PDatafileInfo;
  AInfo: PRelateInfo;
BEGIN
  AInfo:=df^.RelateInfo;
  AList.Clear;
  WHILE AInfo<>NIL DO
    BEGIN
      RelDf:=PDatafileInfo(RelateFiles.Objects[AInfo^.RelFileNo]);
      AList.Append(Format(' '+Lang(7002),
      [trim(PeField(df^.FieldList.Items[AInfo^.CmdInFieldNo])^.FName),ExtractFilename(RelDf^.RECFilename)]));
      //7002=Relates in %s to %s
      AList.Append(Format(' '+Lang(7004),[trim(PeField(df^.FieldList.Items[AInfo^.RelFieldNo])^.FName)]));
      //7004=via keyfield %s
      AList.Append('');
      AInfo:=AInfo^.Next;
    END;
END;

procedure TRelateTreeForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  s:string;
begin
  //IF HostDocksite=NIL THEN s:='Ingen hostDock' ELSE s:='Har hostDock';
  //s:=s+#13+'Højde='+IntToStr(UnDockHeight)+#13+'Bredde='+IntToStr(UndockWidth);
  //s:=s+#13+'Top='+IntToStr(top)+#13+'Left='+IntToStr(left);
  //ShowMessage(s);
  RelateTreeRect:=self.BoundsRect;
  IF HostDockSite=NIL THEN RelateTreeDock:=0
  ELSE
    BEGIN
      RelateTreeRect.Bottom:=self.UnDockHeight+RelateTreeRect.Top;
      RelateTreeRect.Right:=self.UnDockWidth+RelateTreeRect.Left;
      IF HostDockSite=MainForm.RightDockPanel
      THEN RelateTreeDock:=2
      ELSE RelateTreeDock:=1;
    END;
  WITH MainForm DO
    BEGIN
      LeftDockPanel.Width:=0;
      RightDockPanel.Width:=0;
      LeftSplitter.Visible:=False;
      RightSplitter.Visible:=False;
    END;
  RelateNodes.Free;
  RelateNodes:=NIL;
  DEC(RelateTreeCount);
  Action:=caFree;
end;

procedure TRelateTreeForm.FormShow(Sender: TObject);
begin
  RelateTree.FullExpand;
  RelateTree.Items.Item[0].StateIndex:=2;
end;

procedure TRelateTreeForm.RelateTreeChange(Sender: TObject; Node: TTreeNode);
begin
  IF NOT changeGoingOn THEN
    BEGIN
      IF Node=NIL THEN Exit;
      TForm(PDatafileInfo(Node.Data)^.DatForm).Show;
    END;
end;



procedure TRelateTreeForm.RelateTreeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
VAR
  ANode: TTreeNode;
  df: PdatafileInfo;
  aPoint: TPoint;
begin
  IF Button=mbRight THEN
    BEGIN
      IF HintFormOn=True THEN Exit;
      ANode:=RelateTree.GetNodeAt(x,y);
      IF ANode=NIL THEN Exit;
      df:=PDatafileInfo(ANode.Data);
      ANode:=NIL;
      HintForm:=THintForm.Create(Self);
      aPoint.x:=x+4;
      aPoint.y:=y+32;
      aPoint:=ClientToScreen(aPoint);
      HintForm.Top:=aPoint.y;
      HintForm.Left:=aPoint.x;
      HintForm.Label1.Caption:=ExtractFilename(df^.RECFilename);
      IF df^.HasRelate THEN FillMemo(HintForm.Memo1.Lines,df)
      ELSE HintForm.Memo1.Text:=' '+Lang(7006);   //7006=Has no relates
      HintForm.AjustSize;
      HintForm.Show;
      HintFormOn:=True;
      HintNode:=ANode;
      Self.SetFocus;
      SetCapture(relatetree.Handle);
    END;
end;

procedure TRelateTreeForm.RelateTreeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
VAR
  aPoint:TPoint;
  ANode: TTreeNode;
  df: PDatafileInfo;
begin
  IF (HintFormOn) AND ((x>Self.ClientWidth-10) or (y>Self.ClientHeight-10) or (x<2) or (y<2))
  THEN BEGIN
    HintForm.Free;
    HintFormOn:=False;
    ReleaseCapture;
  END;
  IF HintformOn THEN
    BEGIN
      aPoint.x:=x+4;
      aPoint.y:=y+32;
      aPoint:=ClientToScreen(aPoint);
      HintForm.Top:=aPoint.y;
      HintForm.Left:=aPoint.x;
      ANode:=RelateTree.GetNodeAt(x,y);
      IF ANode=NIL THEN Exit;
      IF ANode<>HintNode THEN
        BEGIN
          df:=PDatafileInfo(ANode.Data);
          HintNode:=ANode;
          HintForm.Label1.Caption:=ExtractFilename(df^.RECFilename);
          IF df^.HasRelate THEN FillMemo(HintForm.Memo1.Lines,df)
          //HintForm.Memo1.Lines.CommaText:=df^.RelateInfo
          ELSE HintForm.Memo1.Text:=Lang(7006);   //7006=Has no relates
          HintForm.AjustSize;
        END;
    END;
end;


procedure TRelateTreeForm.FormUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
  IF Client.Parent=NIL THEN Client.Parent:=MainForm;
end;

procedure TRelateTreeForm.FormCreate(Sender: TObject);
begin
  {$IFNDEF epidat}
  TranslateForm(self);
  {$ENDIF}
end;

end.
