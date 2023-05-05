unit uFormProdutos;

interface

uses
  uDataModule, uFrameItemListaProdutos, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.ListBox, FMX.Edit;

type
  TfFormProdutos = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    qryPesquisa: TFDQuery;
    Layout1: TLayout;
    pesquisar: TRectangle;
    edtBusca: TEdit;
    Layout2: TLayout;
    listaPesquisa: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    fFrameItemListaProdutos1: TfFrameItemListaProdutos;
    fFrameItemListaProdutos2: TfFrameItemListaProdutos;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnIncluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
  private

    { Private declarations }

    idSelecionado: integer;
    frameSelecionado: TfFrameItemListaProdutos;

    procedure FrameClick(Sender: TObject);

  public

    { Public declarations }

    arrayItensPesquisa: array[0..9999] of TListBoxItem;
    qtdItensPesquisa: Integer;

    procedure prcCarregarPesquisa();
    procedure executarBusca(valor: string);

    procedure ajustaBotao();

  end;

var
  fFormProdutos: TfFormProdutos;

implementation

uses
  uFormProdutosCadastro, uFuncoesGerais, uFuncoesDB, uFuncoesINI;


{$R *.fmx}

procedure TfFormProdutos.FormActivate(Sender: TObject);
begin

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

end;

procedure TfFormProdutos.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  qtdItensPesquisa := 0;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

end;

procedure TfFormProdutos.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaProdutos(Sender).produtoId) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaProdutos(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaProdutos(Sender).produtoId;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaProdutos(Sender);
    TfFrameItemListaProdutos(Sender).setSelected(true);

  end;

  ajustaBotao();

end;

procedure TfFormProdutos.ajustaBotao;
begin

  if idSelecionado > 0 then
  begin
    lblLabelBotao.Text := 'Editar';
  end
  else
  begin
    lblLabelBotao.Text := 'Incluir';
  end;

end;

procedure TfFormProdutos.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormProdutos.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();

end;

procedure TfFormProdutos.executarBusca(valor: string);
begin

  self.qryPesquisa.close;
  self.qryPesquisa.SQL.Clear;
  self.qryPesquisa.SQL.Add('select produto.*');
  self.qryPesquisa.SQL.Add('  from produto');
  self.qryPesquisa.SQL.Add(' where (1=1)');

  if Trim(valor) <> '' then
    self.qryPesquisa.SQL.Add('   and produto.descricao like ''%'' || ' + QuotedStr(valor) + ' || ''%'' ');

  self.qryPesquisa.Open();

end;

procedure TfFormProdutos.prcCarregarPesquisa;
var
  MyFrame: TfFrameItemListaProdutos;
  i: Integer;
  item: TListBoxItem;
  frame: TfFrameItemListaProdutos;
  strFiltro: string;
begin

  inherited;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaProdutos(self.FindComponent('frame_' + IntToStr(i))).DisposeOf;
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
    item.Height := 137;
    item.Tag := i;
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 5;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaProdutos.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.produtoId := TI(qryPesquisa.FieldByName('id').value);
    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'Código: ' + TS(qryPesquisa.FieldByName('codigo').value).PadLeft(5, '0');
    frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('descricao').value);
    frame.lblLinha3.Text := 'EAN: ' + TS(qryPesquisa.FieldByName('cean').value);
    frame.lblLinha4.Text := 'Preço: ' + FormatFloat('#########,0.00', qryPesquisa.FieldByName('valor').value);
    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

end;

procedure TfFormProdutos.btnIncluirClick(Sender: TObject);
begin

  inherited;

  ApplicationParmTemp.AddParmV('produtoId', TI(idSelecionado));

  if Assigned(fFormProdutosCadastro) then
    FreeAndNil(fFormProdutosCadastro);

  if not Assigned(fFormProdutosCadastro) then
    fFormProdutosCadastro := TfFormProdutosCadastro.Create(Application);

  fFormProdutosCadastro.Show;

end;

initialization
  RegisterClass(TfFormProdutos);


finalization
  UnRegisterClass(TfFormProdutos);

end.

