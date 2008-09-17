unit ColorTabelUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

type
  TColorTabelForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Pages: TPageControl;
    EpiDataColorPage: TTabSheet;
    EpiInfoColorPage: TTabSheet;
    EpiDataPaintBox: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure EpiDataPaintBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ColorTabelForm: TColorTabelForm;

implementation

USES
  EpiTypes;

{$R *.DFM}


procedure TColorTabelForm.EpiDataPaintBoxPaint(Sender: TObject);
VAR
  w,h,x,y,n,t,q,HorSpace,VerSpace,HalfHigh: Integer;
  ARect: TRect;
begin
  w:=120;
  h:=20;
  HalfHigh:=(High(Colornames) DIV 2)+1;
  FOR q:=0 TO 1 DO
    FOR t:=1 TO HalfHigh DO
      BEGIN
        With EpiDataPaintBox.Canvas DO
          BEGIN
            Brush.Style:=bsSolid;
            n:=(q*HalfHigh)+t;
            IF q=0 THEN ARect.Left:=(Width DIV 2)-w-(w DIV 3)
            ELSE ARect.Left:=(Width DIV 2)+(w div 3);
            ARect.Top:=(t*((h*6) DIV 5));
            ARect.Right:=ARect.Left+w;
            Arect.Bottom:=ARect.Top+h;
            brush.Color:=ColorValues[(q*HalfHigh)+t-1];
            FillRect(ARect);
            Font.color:=clBlack;
            Rectangle(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom);
            Brush.Style:=bsClear;
            TextOut(ARect.Left-TextWidth(ColorNames[(q*halfHigh)+t-1])-5,ARect.Top+3,ColorNames[(q*halfHigh)+t-1]);
          END;  //with
      END;  //for
end;

procedure TColorTabelForm.FormCreate(Sender: TObject);
VAR
  curBg,curT: Integer;
  ALabel: TLabel;
  Verdi,Hojde, Bredde: Integer;
begin
  {$IFNDEF epidat}
  TranslateForm(self);
  {$ENDIF}
  label2.caption:='';
  label5.caption:='';
  FOR curBg := 0 TO 7 DO
    FOR CurT:= 0 TO 15 DO
      BEGIN
        ALabel:=TLabel.Create(self);
        ALabel.Parent:=EpiInfoColorPage;
        ALabel.font.name:='Courier New';
        ALabel.font.Size:=10;
        ALabel.font.Style:=[fsBold];
        Hojde:=ALabel.Canvas.TextHeight('X');
        Bredde:=ALabel.canvas.textwidth('9999');
        ALabel.Top:=60+(Hojde*CurBg);
        ALabel.Left:=10+(Bredde*CurT);
        verdi:=(16*CurBg)+CurT;
        ALabel.Caption:=Format('%4d',[verdi]);
        ALabel.Color:=BgColors[CurBg];
        ALabel.Font.Color:=TextColors[CurT];
        ALabel.Tag:=Verdi;
        ALabel.OnClick:=Label1Click;
      END;
end;

procedure TColorTabelForm.Label1Click(Sender: TObject);
VAr
  n,bg,tx:Integer;
begin
  n:=(sender as tlabel).tag;
  n:=n AND $7F;
  bg:=(n AND $F0) SHR 4;
  tx:=(n AND $0F);
  label1.color:=Bgcolors[bg];
  Label1.font.color:=TextColors[tx];
  Label2.Caption:=Lang(8014)+' '+IntToStr(n);   //8014=Color code
  Label5.Caption:=Format(Lang(8016),[Copy(ColorToString(BgColors[bg]),3,50),
     Copy(ColorToString(TextColors[tx]),3,50)]);      //8016=Background color is %s.   Text color is %s
end;

end.
