unit uFormVendasIncluirProduto;

interface

uses
  uFormVendasCadastro, uDataModule, uFrameItemListaIncluirProdutos, System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts,
  FMX.Effects, FMX.Controls.Presentation, FMX.Edit, uFrameItemListaVendas, FMX.ListBox, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfFormVendasIncluirProduto = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    Layout1: TLayout;
    pesquisar: TRectangle;
    edtBusca: TEdit;
    Layout2: TLayout;
    listaPesquisa: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnIncluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    qryPesquisa: TFDQuery;
    fFrameItemListaIncluirProdutos1: TfFrameItemListaIncluirProdutos;
    fFrameItemListaIncluirProdutos2: TfFrameItemListaIncluirProdutos;
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
  private

    { Private declarations }

    idSelecionado: integer;
    frameSelecionado: TfFrameItemListaIncluirProdutos;

    procedure FrameClick(Sender: TObject);

  public

    { Public declarations }

    vendaID: integer;

    arrayItensPesquisa: array[0..9999] of TListBoxItem;
    qtdItensPesquisa: Integer;

    procedure prcCarregarPesquisa();
    procedure executarBusca(valor: string);

    procedure ajustaBotao();

  end;

var
  fFormVendasIncluirProduto: TfFormVendasIncluirProduto;

implementation

uses
  uFuncoesGerais, uFuncoesDB, uFuncoesINI;

{$R *.fmx}

procedure TfFormVendasIncluirProduto.FormShow(Sender: TObject);
begin

  inherited;

  qtdItensPesquisa := 0;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

end;

procedure TfFormVendasIncluirProduto.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaIncluirProdutos(Sender).produtoId) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaIncluirProdutos(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaIncluirProdutos(Sender).produtoId;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaIncluirProdutos(Sender);
    TfFrameItemListaIncluirProdutos(Sender).setSelected(true);

  end;

  ajustaBotao();

end;

procedure TfFormVendasIncluirProduto.ajustaBotao;
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

procedure TfFormVendasIncluirProduto.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormVendasIncluirProduto.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();

end;

procedure TfFormVendasIncluirProduto.executarBusca(valor: string);
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

procedure TfFormVendasIncluirProduto.prcCarregarPesquisa;
var
  MyFrame: TfFrameItemListaIncluirProdutos;
  i: Integer;
  item: TListBoxItem;
  frame: TfFrameItemListaIncluirProdutos;
  strFiltro: string;
begin

  inherited;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaIncluirProdutos(self.FindComponent('frame_' + IntToStr(i))).DisposeOf;
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
    item.Height := 130;
    item.Tag := i;
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 1;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaIncluirProdutos.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.produtoId := TI(qryPesquisa.FieldByName('id').value);
    frame.vendaID := vendaID;

    frame.qtdItem := 0;
    frame.lblQtdeItemValor.Text := FormatFloat('#########,0.00####', frame.qtdItem);

    frame.vlrItem := TN(qryPesquisa.FieldByName('valor').value);

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

procedure TfFormVendasIncluirProduto.btnIncluirClick(Sender: TObject);
var
  i: Integer;
  item: TListBoxItem;
  frame: TfFrameItemListaIncluirProdutos;
  strFiltro: string;
begin

  inherited;

  try

    for i := 1 to self.qtdItensPesquisa do
    begin

      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin

        item := TListBoxItem(listaPesquisa.FindComponent('item_' + IntToStr(i)));

        if item.FindComponent('frame_' + IntToStr(i)) <> nil then
          frame := TfFrameItemListaIncluirProdutos(item.FindComponent('frame_' + IntToStr(i)));

        if frame.qtdItem > 0 then
        begin

          FDCCreateQry('qryAddProduto');

          try

            try

              FDCCloseQry('qryAddProduto');
              FDCClearQry('qryAddProduto');

              FDCSqlAdd('qryAddProduto', Nenhum, '', 'insert into itemDocumento');

              FDCSqlAdd('qryAddProduto', Nenhum, '', '(');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'id,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'documentoId,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'produtoid,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'quantidade,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'valorProdutos,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'valorFrete,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'valorSeguro,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'valorDesconto,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'valoroutros,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', 'totalItem');
              FDCSqlAdd('qryAddProduto', Nenhum, '', ')');

              FDCSqlAdd('qryAddProduto', Nenhum, '', 'values');

              FDCSqlAdd('qryAddProduto', Nenhum, '', '(');

              FDCSqlAdd('qryAddProduto', Inteiro, ultimoValorRegistro('ITEMDOCUMENTO', 'ID'), '{},');
              FDCSqlAdd('qryAddProduto', Inteiro, vendaID, '{},');
              FDCSqlAdd('qryAddProduto', Inteiro, frame.produtoId, '{},');
              FDCSqlAdd('qryAddProduto', numerico, frame.qtdItem, '{},');
              FDCSqlAdd('qryAddProduto', numerico, frame.vlrItem, '{},');
              FDCSqlAdd('qryAddProduto', Nenhum, '', '0,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', '0,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', '0,');
              FDCSqlAdd('qryAddProduto', Nenhum, '', '0,');
              FDCSqlAdd('qryAddProduto', numerico, (frame.qtdItem * frame.vlrItem), '{}');

              FDCSqlAdd('qryAddProduto', Nenhum, '', ');');

              FDCGetQry('qryAddProduto').ExecSQL;

            except
              on e: exception do
                raise Exception.Create(e.Message);
            end;

          finally
            FDCCloseQry('qryAddProduto');
            FDCDestroyQry('qryAddProduto');
          end;

        end;

      end;

    end;

    self.Close;

  except
    on e: exception do
      raise Exception.Create(e.Message);
  end;

end;

initialization
  RegisterClass(TfFormVendasIncluirProduto);


finalization
  UnRegisterClass(TfFormVendasIncluirProduto);

end.

