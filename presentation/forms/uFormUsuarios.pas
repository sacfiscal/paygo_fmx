unit uFormUsuarios;

interface

uses
  uDataModule, uFrameItemListaPadraoTresLinhas, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfFormUsuarios = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    Layout1: TLayout;
    Layout2: TLayout;
    listaPesquisa: TListBox;
    qryPesquisa: TFDQuery;
    pesquisar: TRectangle;
    edtBusca: TEdit;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    fFrameItemListaPadraoTresLinhas1: TfFrameItemListaPadraoTresLinhas;
    fFrameItemListaPadraoTresLinhas2: TfFrameItemListaPadraoTresLinhas;
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
  private

    { Private declarations }

    idSelecionado: integer;
    frameSelecionado: TfFrameItemListaPadraoTresLinhas;

    procedure FrameClick(Sender: TObject);

  public

    { Public declarations }

    arrayItensPesquisa: array[0..9999] of TListBoxItem;
    qtdItensPesquisa: Integer;

    procedure prcCarregarPesquisa();
    procedure executarBusca(valor: string);

  end;

var
  fFormUsuarios: TfFormUsuarios;

implementation

uses
  uFuncoesGerais, uFuncoesDB, uFuncoesINI;

{$R *.fmx}

procedure TfFormUsuarios.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  qtdItensPesquisa := 0;
  prcCarregarPesquisa();

end;

procedure TfFormUsuarios.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  Self.close;

end;

procedure TfFormUsuarios.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  prcCarregarPesquisa();

end;

procedure TfFormUsuarios.executarBusca(valor: string);
begin

  self.qryPesquisa.close;
  self.qryPesquisa.SQL.Clear;
  self.qryPesquisa.SQL.Add('select usuario.*');
  self.qryPesquisa.SQL.Add('  from usuario');
  self.qryPesquisa.SQL.Add(' where (1=1)');

  if Trim(valor) <> '' then
    self.qryPesquisa.SQL.Add('   and usuario.nome like ''%'' || ' + QuotedStr(valor) + ' || ''%'' ');

  self.qryPesquisa.Open();

end;

procedure TfFormUsuarios.prcCarregarPesquisa;
var
  MyFrame: TfFrameItemListaPadraoTresLinhas;
  i: Integer;
  item: TListBoxItem;
  frame: TfFrameItemListaPadraoTresLinhas;
  strFiltro: string;
begin

  inherited;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaPadraoTresLinhas(self.FindComponent('frame_' + IntToStr(i))).DisposeOf;
        self.arrayItensPesquisa[i].DisposeOf;
      end;
    end;

  end;

  self.listaPesquisa.Clear;

  executarBusca(edtBusca.Text);

  if self.qryPesquisa.IsEmpty then
    Exit;

  i := 0;
  qtdItensPesquisa := self.qryPesquisa.RecordCount;

  self.qryPesquisa.First;

  while not self.qryPesquisa.Eof do
  begin

    Inc(i);

    item := TListBoxItem.Create(listaPesquisa);
    item.Selectable := False;
    item.Height := 90;
    item.Tag := i;
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 1;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaPadraoTresLinhas.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.itemId := TI(qryPesquisa.FieldByName('id').value);
    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'Código: ' + TS(qryPesquisa.FieldByName('id').value).PadLeft(5, '0');
    frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('nome').value);
    frame.lblLinha3.Text := 'Login: ' + TS(qryPesquisa.FieldByName('login').value);
    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

  if frame <> nil then
    frame.Line1.Visible := false;

end;

procedure TfFormUsuarios.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaPadraoTresLinhas(Sender).itemId) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaPadraoTresLinhas(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaPadraoTresLinhas(Sender).itemId;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaPadraoTresLinhas(Sender);
    TfFrameItemListaPadraoTresLinhas(Sender).setSelected(true);

  end;

end;

initialization
  RegisterClass(TfFormUsuarios);


finalization
  UnRegisterClass(TfFormUsuarios);

end.

