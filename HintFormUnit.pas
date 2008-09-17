unit HintFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  THintForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Memo1: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure AjustSize;
  end;

var
  HintForm: THintForm;

implementation

{$R *.DFM}

Procedure THintForm.AjustSize;
VAR
  NumLines,h,w,n,t: Integer;
BEGIN
  //Ajust width
  w:=self.Width;
  n:=Label1.Left+Label1.Canvas.TextWidth(Label1.Caption);
  IF n>w THEN w:=n;
  FOR t:=0 TO Memo1.Lines.Count-1 DO
    IF Self.Canvas.TextWidth(Memo1.Lines[t])+5 > w THEN w:=Self.Canvas.TextWidth(Memo1.Lines[t])+5;
  self.Width:=w;
  //Ajust height
  h:=Panel1.Height + (self.canvas.TextHeight('X')*Memo1.Lines.Count);
  IF h+10>self.Height THEN self.Height:=h+10;
END;

end.
