unit LegalPickListUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TLegalPickForm = class(TForm)
    ListBox1: TListBox;
    Panel1: TPanel;
    Edit1: TEdit;
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListBox1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBox1KeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  public
    CloseOnKeyDown: Boolean;
    { Public declarations }
  end;

var
  LegalPickForm: TLegalPickForm;

implementation

{$R *.DFM}

USES
  EpiTypes;

VAR
  DontChange: Boolean;

procedure TLegalPickForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF Key=VK_ESCAPE THEN ModalResult:=mrCancel;
  IF Key=VK_RETURN THEN ModalResult:=mrOK;
end;

procedure TLegalPickForm.ListBox1DblClick(Sender: TObject);
begin
  IF ListBox1.ItemIndex>-1 THEN ModalResult:=mrOK;
end;

procedure TLegalPickForm.FormCreate(Sender: TObject);
begin
  TranslateForm(self);
  Dontchange:=False;
  CloseOnKeyDown:=False;
end;

procedure TLegalPickForm.Edit1Change(Sender: TObject);
var
  n:integer;
  AnItem: TListItem;
BEGIN
  IF NOT DontChange THEN
    BEGIN
      IF Edit1.Text='' THEN
        BEGIN
          Listbox1.itemIndex:=-1;
          Exit;
        END;
      n:=0;
      WHILE (Pos(AnsiLowerCase(Edit1.Text),AnsiLowercase(ListBox1.Items[n]))<>1)
      AND (n<ListBox1.Items.Count-1) DO INC(n);
      IF Pos(ansiLowerCase(Edit1.Text),AnsiLowerCase(ListBox1.Items[n]))<>1 THEN n:=-1;
      Listbox1.itemindex:=n;
      IF (CloseOnKeyDown) AND (n<>-1) THEN ModalResult:=mrOK;
    END;
END;

procedure TLegalPickForm.ListBox1Click(Sender: TObject);
begin
  Edit1.Text:=ListBox1.Items[ListBox1.ItemIndex];
  Edit1.SetFocus;
end;

procedure TLegalPickForm.FormResize(Sender: TObject);
begin
  Edit1.Width:=Panel1.Width;
end;

procedure TLegalPickForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
VAR
  n,NumItems:Integer;
begin
  IF Key=VK_ESCAPE THEN ModalResult:=mrCancel;
  IF (Key=VK_RETURN) AND (ListBox1.ItemIndex<>-1) THEN ModalResult:=mrOK;
  IF Key=VK_F4 THEN ModalResult:=mrAll;

  IF Key=VK_DOWN THEN
    BEGIN
      IF ListBox1.ItemIndex<ListBox1.Items.Count-1 THEN
        BEGIN
          ListBox1.ItemIndex:=ListBox1.ItemIndex+1;
          DontChange:=True;
          Edit1.Text:=ListBox1.Items[ListBox1.ItemIndex];
          Edit1.SelStart:=0;
          Edit1.SelLength:=Length(Edit1.Text);
          DontChange:=False;
          Key:=0;
        END
      ELSE Key:=0;
    END;

  IF KEY=VK_NEXT THEN    //PgDn pressed
    BEGIN
      NumItems:=ListBox1.ClientHeight DIV ListBox1.ItemHeight;
      n:=ListBox1.ItemIndex+NumItems-1;
      IF n>ListBox1.Items.Count-1 THEN n:=ListBox1.Items.Count-1;
      ListBox1.ItemIndex:=n;
      DontChange:=True;
      Edit1.Text:=ListBox1.Items[ListBox1.ItemIndex];
      Edit1.SelStart:=0;
      Edit1.SelLength:=Length(Edit1.Text);
      DontChange:=False;
      Key:=0;
    END;

  IF (KEY=VK_PRIOR) OR (KEY=VK_HOME) OR (KEY=VK_END) THEN    //PgUp pressed
    BEGIN
      NumItems:=ListBox1.ClientHeight DIV ListBox1.ItemHeight;
      IF KEY=VK_PRIOR THEN n:=ListBox1.ItemIndex-NumItems+1
      ELSE IF KEY=VK_END THEN n:=ListBox1.Items.Count-1
      ELSE n:=0;
      IF n<0 THEN n:=0;
      ListBox1.ItemIndex:=n;
      DontChange:=True;
      Edit1.Text:=ListBox1.Items[ListBox1.ItemIndex];
      Edit1.SelStart:=0;
      Edit1.SelLength:=Length(Edit1.Text);
      DontChange:=False;
      Key:=0;
    END;

  IF Key=VK_UP THEN
    BEGIN
      IF ListBox1.ItemIndex>0 THEN
        BEGIN
          DontChange:=True;
          ListBox1.ItemIndex:=ListBox1.ItemIndex-1;
          Edit1.Text:=ListBox1.Items[ListBox1.ItemIndex];
          Edit1.SelStart:=0;
          Edit1.SelLength:=Length(Edit1.Text);
          DontChange:=False;
          Key:=0;
        END
      ELSE Key:=0;
    END;
end;

procedure TLegalPickForm.ListBox1KeyPress(Sender: TObject; var Key: Char);
begin
  IF (Key in ['a'..'z','A'..'Z','æ','ø','å','Æ','Ø','Å','0'..'9']) THEN
    BEGIN
      Edit1.Text:=Key;
      Edit1.SetFocus;
    END;
end;


end.
