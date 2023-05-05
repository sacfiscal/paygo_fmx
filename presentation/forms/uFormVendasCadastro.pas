unit uFormVendasCadastro;

interface

uses
  uFormVendasPagamento, System.SysUtils, System.Types, System.UITypes,
  System.Classes, System.Variants, System.ImageList, FMX.Types, FMX.Platform,
  FMX.Controls, FMX.VirtualKeyboard, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Edit, FMX.SpinBox, FMX.StdCtrls, FMX.ListBox, FMX.Layouts, FMX.ScrollBox,
  FMX.Memo, FMX.ImgList, FMX.Objects, FMX.ComboEdit, FMX.DateTimeCtrls,
  FMX.TabControl, FMX.EditBox, FMX.Controls.Presentation, FMX.DialogService,
  FMX.Ani, FMX.Memo.Types,

{$IFDEF ANDROID}
  Androidapi.JNI.GraphicsContentViewText,
  ACBrPosPrinterElginE1Service,
  ACBrPosPrinterElginE1Lib,
  ACBrPosPrinterGEDI,
  ACBrPosPrinterTecToySunmiLib,
{$ENDIF}
  ACBrTEFAndroid, ACBrTEFComum,
  ACBrBase, ACBrPosPrinter, ACBrTEFAPIComum, uGlobal, uFormBase, FMX.Effects,
  uFrameItemListaVendas, uFrameItemListaItemVenda, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfFormVendasCadastro = class(TfFormBase)
    cabecalhoVenda: TRectangle;
    PageToolBarShadow: TShadowEffect;
    buttonContent: TRectangle;
    Line1: TLine;
    Layout1: TLayout;
    Layout3: TLayout;
    Layout22: TLayout;
    Layout24: TLayout;
    edt_numero: TText;
    edt_serie: TText;
    edt_dhemissao: TText;
    Layout23: TLayout;
    Layout25: TLayout;
    Text10: TText;
    edt_cnpj_cpf: TEdit;
    listaPesquisa: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    qryPesquisa: TFDQuery;
    fFrameItemListaItemVenda1: TfFrameItemListaItemVenda;
    fFrameItemListaItemVenda2: TfFrameItemListaItemVenda;
    Layout2: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Text2: TText;
    Layout6: TLayout;
    lbl_valorProdutos: TText;
    Layout7: TLayout;
    Layout8: TLayout;
    Text4: TText;
    Layout9: TLayout;
    lbl_valorTotal: TText;
    Layout10: TLayout;
    Layout11: TLayout;
    Text3: TText;
    Layout12: TLayout;
    lbl_ValorDesconto: TText;
    Line3: TLine;
    Line7: TLine;
    ListBoxItem3: TListBoxItem;
    fFrameItemListaItemVenda3: TfFrameItemListaItemVenda;
    StyleBook1: TStyleBook;
    ImageList1: TImageList;
    ShadowEffect1: TShadowEffect;
    pnlInformarCPF: TRectangle;
    ShadowEffect3: TShadowEffect;
    Layout13: TLayout;
    Layout16: TLayout;
    Text1: TText;
    edtInformarCPF: TEdit;
    Rectangle4: TRectangle;
    Text5: TText;
    ShadowEffect6: TShadowEffect;
    Text6: TText;
    Rectangle1: TRectangle;
    Text7: TText;
    ShadowEffect4: TShadowEffect;
    barraNF_Pendente: TRectangle;
    GridPanelLayout2: TGridPanelLayout;
    GridPanelLayout5: TGridPanelLayout;
    GridPanelLayout6: TGridPanelLayout;
    Layout14: TLayout;
    Layout15: TLayout;
    Layout17: TLayout;
    Layout18: TLayout;
    Layout20: TLayout;
    Rectangle2: TRectangle;
    btnFinalizar: TCornerButton;
    btnExcluir: TCornerButton;
    btnMenu: TCircle;
    ShadowEffect2: TShadowEffect;
    btnAddPedidoMinus: TImage;
    btnAddPedidoPlus: TImage;
    btnIdentificar: TCornerButton;
    btnSair: TCornerButton;
    barraNF_Autorizada: TRectangle;
    GridPanelLayout1: TGridPanelLayout;
    btnCancelar: TCornerButton;
    btnImprimir1: TCornerButton;
    btnSair1: TCornerButton;
    lblStatusNFCe: TText;
    lvlChaveNFCe: TText;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    lblInfoPagamento: TText;
    TabItem4: TTabItem;
    mLogNFCe: TMemo;
    pnlImpressao: TRectangle;
    ShadowEffect5: TShadowEffect;
    Layout21: TLayout;
    Rectangle5: TRectangle;
    Text9: TText;
    ShadowEffect7: TShadowEffect;
    Rectangle6: TRectangle;
    Text12: TText;
    ShadowEffect8: TShadowEffect;
    TabItem2: TTabItem;
    TabControl2: TTabControl;
    TabItem3: TTabItem;
    TabItem5: TTabItem;
    Comprovante1Via: TMemo;
    Comprovante2Via: TMemo;
    ACBrPosPrinter1: TACBrPosPrinter;
    procedure btnCancelarClick(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure btnIdentificarClick(Sender: TObject);
    procedure btnInutilizarClick(Sender: TObject);
    procedure btnSair1Click(Sender: TObject);
    procedure edtInformarCPFTyping(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Rectangle1Click(Sender: TObject);
    procedure Rectangle4Click(Sender: TObject);
    procedure btnImprimir1Click(Sender: TObject);
    procedure Rectangle6Click(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);

  private

    { Private declarations }

    fVKService: IFMXVirtualKeyboardService;

    function GetValorVenda: Double;
    procedure SetValorVenda(const Value: Double);

  public

    { Public declarations }

    idSelecionado: integer;
    frameSelecionado: TfFrameItemListaItemVenda;
    vendaID: integer;
    chaveUnicaNuvemFiscal: string;

    strViaEstabelecimento: string;
    strViaCliente: string;

    vendaProtocolo: string;

    nfceStatus: integer;

    arrayItensPesquisa: array [0 .. 9999] of TListBoxItem;
    qtdItensPesquisa: integer;

    procedure FrameClick(Sender: TObject);
    procedure prcAjustaBotoes();

    procedure prcNovaVenda();
    procedure prcCarregarRegistro();
    procedure prcCalcularVenda(ajustarData: boolean = false);
    procedure atualizarVenda(ajustarData: boolean = false);
    procedure Imprimir(ops: integer);

  public

    { Public declarations }

    property ValorVenda: Double read GetValorVenda write SetValorVenda;

  end;

var
  fFormVendasCadastro: TfFormVendasCadastro;

implementation

uses
  Math, StrUtils, IniFiles, DateUtils, System.TypInfo, System.IOUtils,
  uFuncoesINI, uFuncoesACBr,

{$IFDEF ANDROID}
  Androidapi.JNI.Widget,
  Androidapi.Helpers,
  FMX.Helpers.Android,
  ACBrTEFAndroidPayGo,
{$ENDIF}
  ACBrTEFPayGoComum, ACBrUtil, ACBrValidador,
  uFormVendasIdentificarCliente, uFormVendasIncluirProduto, uFuncoesGerais,
  uFuncoesNuvemFiscalAPI, uFuncoesDB;

{$R *.fmx}

function TfFormVendasCadastro.GetValorVenda: Double;
begin
  Result := StrToIntDef(OnlyNumber(lbl_valorTotal.Text), 0) / 100;
end;

procedure TfFormVendasCadastro.SetValorVenda(const Value: Double);
var
  AValor: Double;
begin
  AValor := min(max(0, Value), 999999);
  lbl_valorTotal.Text := 'R$ ' + FormatFloatBr(AValor);
end;

procedure TfFormVendasCadastro.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaItemVenda(Sender).itemId) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaItemVenda(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaItemVenda(Sender).itemId;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaItemVenda(Sender);
    TfFrameItemListaItemVenda(Sender).setSelected(true);

  end;

  prcAjustaBotoes();

end;

procedure TfFormVendasCadastro.prcAjustaBotoes;
begin

  if idSelecionado > 0 then
  begin
    btnAddPedidoPlus.Visible := false;
    btnAddPedidoMinus.Visible := true;
    btnMenu.Fill.Color := TAlphaColorRec.Tomato;
  end
  else
  begin
    btnAddPedidoPlus.Visible := true;
    btnAddPedidoMinus.Visible := false;
    btnMenu.Fill.Color := TAlphaColorRec.White;
  end;

end;

procedure TfFormVendasCadastro.prcNovaVenda;
var
  proximoNumero: integer;
begin

  inherited;

  proximoNumero := TI(uGlobal.globalConfiguracoes.proximaNfce);

  FDCCreateQry('qryAdd');

  try

    try

      vendaID := ultimoValorRegistro('documentoNfce', 'id');

      FDCCloseQry('qryAdd');
      FDCClearQry('qryAdd');
      FDCSqlAdd('qryAdd', Nenhum, '', 'INSERT INTO documentoNfce');

      FDCSqlAdd('qryAdd', Nenhum, '', '(');

      FDCSqlAdd('qryAdd', Nenhum, '', 'id,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'emitenteId,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'dhemissao,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'serie,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'numero,');

      FDCSqlAdd('qryAdd', Nenhum, '', 'tipoEmissao,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'tipoImpressao,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'finalidade,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'indicadorOperacao,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'indicadorPresenca,');

      FDCSqlAdd('qryAdd', Nenhum, '', 'valorProdutos,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'valorFrete,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'valorSeguro,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'valoroutros,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'valorDesconto,');
      FDCSqlAdd('qryAdd', Nenhum, '', 'valorTotal');

      FDCSqlAdd('qryAdd', Nenhum, '', ')');

      FDCSqlAdd('qryAdd', Nenhum, '', 'VALUES');

      FDCSqlAdd('qryAdd', Nenhum, '', '(');

      FDCSqlAdd('qryAdd', inteiro, vendaID, '{},');
      FDCSqlAdd('qryAdd', Nenhum, '', '1,');
      FDCSqlAdd('qryAdd', Nenhum, '', ' datetime(''now'',''localtime'') ,');

      FDCSqlAdd('qryAdd', Texto,
        TS(uGlobal.globalConfiguracoes.serieNfce), '{},');

      FDCSqlAdd('qryAdd', inteiro, proximoNumero, '{},');

      FDCSqlAdd('qryAdd', Nenhum, '', '1,');
      FDCSqlAdd('qryAdd', Nenhum, '', '4,');
      FDCSqlAdd('qryAdd', Nenhum, '', '1,');
      FDCSqlAdd('qryAdd', Nenhum, '', '1,');
      FDCSqlAdd('qryAdd', Nenhum, '', '1,');

      FDCSqlAdd('qryAdd', Nenhum, '', '0,');
      FDCSqlAdd('qryAdd', Nenhum, '', '0,');
      FDCSqlAdd('qryAdd', Nenhum, '', '0,');
      FDCSqlAdd('qryAdd', Nenhum, '', '0,');
      FDCSqlAdd('qryAdd', Nenhum, '', '0,');
      FDCSqlAdd('qryAdd', Nenhum, '', '0');

      FDCSqlAdd('qryAdd', Nenhum, '', ');');

      FDCGetQry('qryAdd').ExecSQL;

      self.Close;

    except
      on e: exception do
      begin
        raise exception.Create(e.Message);
      end;
    end;

    uGlobal.globalConfiguracoes.ultimaNfce(proximoNumero);
    uGlobal.globalConfiguracoes.save;

  finally
    FDCCloseQry('qryAdd');
    FDCDestroyQry('qryAdd');
  end;

end;

procedure TfFormVendasCadastro.prcCalcularVenda(ajustarData: boolean = false);
begin

  FDCCreateQry('qryAddProduto');

  try

    try

      FDCCloseQry('qryAddProduto');
      FDCClearQry('qryAddProduto');

      FDCSqlAdd('qryAddProduto', Nenhum, '', 'update documentoNfce     ');
      FDCSqlAdd('qryAddProduto', Nenhum, '', '   set valorProdutos = 0,');
      FDCSqlAdd('qryAddProduto', Nenhum, '', '       valorFrete = 0,');
      FDCSqlAdd('qryAddProduto', Nenhum, '', '       valorSeguro = 0,');
      FDCSqlAdd('qryAddProduto', Nenhum, '', '       valorOutros = 0,');
      FDCSqlAdd('qryAddProduto', Nenhum, '', '       valorDesconto = 0,');
      FDCSqlAdd('qryAddProduto', Nenhum, '', '       valorTotal = 0 ');
      FDCSqlAdd('qryAddProduto', inteiro, vendaID, 'where id = {}');

      FDCGetQry('qryAddProduto').ExecSQL;

      FDCCloseQry('qryAddProduto');
      FDCClearQry('qryAddProduto');

      FDCSqlAdd('qryAddProduto', Nenhum, '', 'update documentoNfce');
      FDCSqlAdd('qryAddProduto', Nenhum, '',
        '   set valorProdutos = ( select sum(itemDocumento.quantidade*itemDocumento.valorProdutos) from itemDocumento where itemDocumento.documentoId = documentoNfce.id  ),');
      FDCSqlAdd('qryAddProduto', Nenhum, '',
        '       valorFrete    = ( select sum(itemDocumento.valorFrete) from itemDocumento where itemDocumento.documentoId = documentoNfce.id  ),');
      FDCSqlAdd('qryAddProduto', Nenhum, '',
        '       valorSeguro   = ( select sum(itemDocumento.valorSeguro) from itemDocumento where itemDocumento.documentoId = documentoNfce.id  ),');
      FDCSqlAdd('qryAddProduto', Nenhum, '',
        '       valorOutros   = ( select sum(itemDocumento.valorOutros) from itemDocumento where itemDocumento.documentoId = documentoNfce.id  ),');
      FDCSqlAdd('qryAddProduto', Nenhum, '',
        '       valorDesconto = ( select sum(itemDocumento.valorDesconto) from itemDocumento where itemDocumento.documentoId = documentoNfce.id  )');
      FDCSqlAdd('qryAddProduto', inteiro, vendaID, 'where id = {}');

      FDCGetQry('qryAddProduto').ExecSQL;

      FDCCloseQry('qryAddProduto');
      FDCClearQry('qryAddProduto');

      FDCSqlAdd('qryAddProduto', Nenhum, '', 'update documentoNfce');
      FDCSqlAdd('qryAddProduto', Nenhum, '',
        '   set  valorTotal = ( valorProdutos + valorFrete - valorSeguro - valorDesconto ) ');

      if ajustarData then
        FDCSqlAdd('qryAddProduto', Nenhum, '',
          '       ,dhemissao  = datetime(''now'',''localtime'') ');

      FDCSqlAdd('qryAddProduto', inteiro, vendaID, 'where id = {}');

      FDCGetQry('qryAddProduto').ExecSQL;

    except
      on e: exception do
        raise exception.Create(e.Message);
    end;

  finally
    FDCCloseQry('qryAddProduto');
    FDCDestroyQry('qryAddProduto');
  end;

end;

procedure TfFormVendasCadastro.prcCarregarRegistro;
begin

  FDCCreateQry('qryload');

  try

    try

      FDCCloseQry('qryload');
      FDCClearQry('qryload');

      FDCSqlAdd('qryload', Nenhum, '', '         select documentoNfce.*,');
      FDCSqlAdd('qryload', Nenhum, '',
        '                destinatario.*, pagamentoNfce.paygo_comprovante1via, pagamentoNfce.paygo_comprovante2via  ');
      FDCSqlAdd('qryload', Nenhum, '', '           from documentoNfce   ');
      FDCSqlAdd('qryload', Nenhum, '',
        'left outer join destinatario on ( destinatario.id = documentoNfce.destinatarioId  )');
      FDCSqlAdd('qryload', Nenhum, '',
        'left outer join pagamentoNfce on ( pagamentoNfce.documentoid = documentoNfce.id  )');

      FDCSqlAdd('qryload', inteiro, TI(vendaID),
        ' WHERE documentoNfce.id = {} and documentoNfce.emitenteId = 1');

      FDCOpenQry('qryload');

      edt_numero.Text := 'NF: #' + TS(FDCGetQry('qryload').FieldByName('numero')
        .Text).PadLeft(9, '0');
      edt_serie.Text := 'Série: ' + TS(FDCGetQry('qryload').FieldByName('serie')
        .Text).PadLeft(3, '0');
      edt_dhemissao.Text := 'Emissão: ' + FDCGetQry('qryload')
        .FieldByName('dhemissao').Text;

      if TI(FDCGetQry('qryload').FieldByName('destinatarioId').Value) > 0 then
        edt_cnpj_cpf.Text :=
          TS(FDCGetQry('qryload').FieldByName('cnpj_cpf').Text)
      else
        edt_cnpj_cpf.Text :=
          TS(FDCGetQry('qryload').FieldByName('cnpjcpf').Text);

      nfceStatus :=
        TI(FDCGetQry('qryload').FieldByName('nuvemFiscal_status').Value);

      mLogNFCe.Text :=
        TS(FDCGetQry('qryload')
        .FieldByName('nuvemFiscal_JsonAutorizacao').Value);
      Comprovante1Via.Text :=
        TS(FDCGetQry('qryload').FieldByName('paygo_comprovante1via').Value);
      Comprovante2Via.Text :=
        TS(FDCGetQry('qryload').FieldByName('paygo_comprovante2via').Value);

      lbl_valorProdutos.Text := FormatFloat('#########,0.00',
        FDCGetQry('qryload').FieldByName('valorProdutos').AsCurrency);
      lbl_ValorDesconto.Text := FormatFloat('#########,0.00',
        FDCGetQry('qryload').FieldByName('ValorDesconto').AsCurrency);
      lbl_valorTotal.Text := FormatFloat('#########,0.00',
        FDCGetQry('qryload').FieldByName('valorTotal').AsCurrency);
      vendaProtocolo := FDCGetQry('qryload')
        .FieldByName('protocoloAutorizacao').Text;

      chaveUnicaNuvemFiscal := FDCGetQry('qryload')
        .FieldByName('nuvemFiscal_idUnico').Text;

      if Trim(vendaProtocolo) <> '' then
      begin
        barraNF_Autorizada.Visible := true;
        barraNF_Pendente.Visible := false;
        lvlChaveNFCe.Text := 'Chave de Acesso: ' + FDCGetQry('qryload')
          .FieldByName('nuvemFiscal_ChaveNFe').Text;
      end
      else
      begin
        barraNF_Autorizada.Visible := false;
        barraNF_Pendente.Visible := true;
        lvlChaveNFCe.Text := '';
      end;

      if Trim(FDCGetQry('qryload').FieldByName('nuvemFiscal_Status').Text) = '100'
      then
      begin
        lblStatusNFCe.Text := 'NFCe Autorizada';
      end;

      if Trim(FDCGetQry('qryload').FieldByName('nuvemFiscal_Status').Text) = '101'
      then
      begin
        lblStatusNFCe.Text := 'NFCe Cancelada';
      end;

      if Trim(FDCGetQry('qryload').FieldByName('nuvemFiscal_Status').Text) = '135'
      then
      begin
        lblStatusNFCe.Text := 'NFCe Cancelada';
      end;

      if Trim(FDCGetQry('qryload').FieldByName('nuvemFiscal_Status').Text) = '102'
      then
      begin
        lblStatusNFCe.Text := 'NFCe Inutilizada';
      end;

      FDCCreateQry('qryVerificaPagamento');

      try

        try

          FDCCloseQry('qryVerificaPagamento');
          FDCClearQry('qryVerificaPagamento');
          FDCSqlAdd('qryVerificaPagamento', Nenhum, '',
            'select * from pagamentoNFCe ');
          FDCSqlAdd('qryVerificaPagamento', inteiro, vendaID,
            'where documentoId = {}');
          FDCOpenQry('qryVerificaPagamento');

          if not FDCGetQry('qryVerificaPagamento').IsEmpty then
          begin

            cabecalhoVenda.Height := 148;
            lblInfoPagamento.Visible := true;

            lblInfoPagamento.Text := 'Pagamento Realizado - Código: ' +
              TS(FDCGetQry('qryVerificaPagamento')
              .FieldByName('codigoAutorizacao').Value) + ' - Valor : R$ ' +
              FormatFloat('#########,0.00',
              TN(FDCGetQry('qryVerificaPagamento')
              .FieldByName('valorPagamento').Value));

          end
          else
          begin

            cabecalhoVenda.Height := 130;
            lblInfoPagamento.Visible := false;

          end;

        except
          on e: exception do
          begin
          end;
        end;

      finally
        FDCCloseQry('qryVerificaPagamento');
        FDCDestroyQry('qryVerificaPagamento');
      end;

    except
      on e: exception do
        raise exception.Create(e.Message);
    end;

  finally
    FDCCloseQry('qryload');
    FDCDestroyQry('qryload');
  end;

end;

procedure TfFormVendasCadastro.atualizarVenda(ajustarData: boolean = false);
var
  MyFrame: TfFrameItemListaItemVenda;
  i: integer;
  item: TListBoxItem;
  frame: TfFrameItemListaItemVenda;
  strFiltro: string;
begin

  inherited;

  prcCalcularVenda(ajustarData);
  prcCarregarRegistro;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaItemVenda(self.FindComponent('frame_' + IntToStr(i)))
          .DisposeOf;
        self.arrayItensPesquisa[i].DisposeOf;
      end;
    end;

  end;

  self.listaPesquisa.Clear;

  self.qryPesquisa.Close;
  self.qryPesquisa.SQL.Clear;
  self.qryPesquisa.SQL.Add('     select');
  self.qryPesquisa.SQL.Add('			documentoNfce.id as vendaID,');
  self.qryPesquisa.SQL.Add('			itemDocumento.*,');
  self.qryPesquisa.SQL.Add('			produto.descricao,');
  self.qryPesquisa.SQL.Add('			produto.cean,');
  self.qryPesquisa.SQL.Add('			produto.codigo,');
  self.qryPesquisa.SQL.Add('			produto.cbarra');
  self.qryPesquisa.SQL.Add('       from documentoNfce');
  self.qryPesquisa.SQL.Add
    (' inner join itemDocumento ON ( itemDocumento.documentoId = documentoNfce.id  )');
  self.qryPesquisa.SQL.Add
    (' inner join produto on ( produto.id = itemDocumento.produtoId )');
  self.qryPesquisa.SQL.Add(' where (1=1)');

  FDCSqlAdd(qryPesquisa, inteiro, vendaID, ' and vendaID = {} ');

  self.qryPesquisa.Open();

  if self.qryPesquisa.IsEmpty then
    Exit;

  i := 0;
  qtdItensPesquisa := self.qryPesquisa.RecordCount;

  self.qryPesquisa.First;

  while not self.qryPesquisa.Eof do
  begin

    Inc(i);

    item := TListBoxItem.Create(listaPesquisa);
    item.Selectable := false;
    item.Height := 89;
    item.Tag := i;
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 2;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaItemVenda.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.vendaID := vendaID;
    frame.itemId := TI(qryPesquisa.FieldByName('id').Value);
    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'Código: ' +
      TS(qryPesquisa.FieldByName('codigo').Value).PadLeft(5, '0');
    frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('descricao').Value);
    frame.lblLinha3.Text := 'EAN: ' + TS(qryPesquisa.FieldByName('cean').Value);
    frame.lblLinha4.Text := 'Qtde x Preço: ' + FormatFloat('#########,0.00',
      qryPesquisa.FieldByName('quantidade').Value) + ' x ' +
      FormatFloat('#########,0.00',
      qryPesquisa.FieldByName('valorProdutos').Value);
    frame.lblLinha5.Text := 'Valor Total: ' + FormatFloat('#########,0.00',
      qryPesquisa.FieldByName('totalItem').Value);

    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

  prcAjustaBotoes();

end;

procedure TfFormVendasCadastro.btnCancelarClick(Sender: TObject);
var
  msg: string;
begin

  inherited;

  msg := 'Deseja realmente CANCELAR a venda?';

  MessageDlg(msg, System.UITypes.TMsgDlgType.mtConfirmation,
    [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      case AResult of
        mrYES:
          begin

            nuvemFiscalCancelarNFCe(chaveUnicaNuvemFiscal,
              'Nota fiscal emitida de forma incorreta!');

            atualizarVenda();
            prcCarregarRegistro();
            prcAjustaBotoes();

          end;
      end;
    end);

end;

procedure TfFormVendasCadastro.FormActivate(Sender: TObject);
begin

  inherited;

  atualizarVenda();
  prcCarregarRegistro();
  prcAjustaBotoes();

end;

procedure TfFormVendasCadastro.FormCreate(Sender: TObject);
begin

  inherited;

  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(fVKService));

  vendaID := TI(FormParmLocal.GetParmS('vendaId'));

  if TI(vendaID) > 0 then
  begin
    prcCarregarRegistro();
  end
  else
  begin
    prcNovaVenda();
    prcCarregarRegistro();
  end;

  atualizarVenda();

end;

procedure TfFormVendasCadastro.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  prcAjustaBotoes();

end;

procedure TfFormVendasCadastro.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormVendasCadastro.btnExcluirClick(Sender: TObject);
var
  msg: string;
begin

  inherited;

  msg := 'Deseja realmente EXCLUIR a venda?';

  MessageDlg(msg, System.UITypes.TMsgDlgType.mtConfirmation,
    [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      case AResult of
        mrYES:
          begin

            FDCCreateQry('qryAddProduto');

            try

              try

                FDCCloseQry('qryAddProduto');
                FDCClearQry('qryAddProduto');
                FDCSqlAdd('qryAddProduto', Nenhum, '',
                  'delete from pagamentoNFCe');
                FDCSqlAdd('qryAddProduto', inteiro, vendaID,
                  'where documentoId = {}');
                FDCGetQry('qryAddProduto').ExecSQL;

                FDCCloseQry('qryAddProduto');
                FDCClearQry('qryAddProduto');
                FDCSqlAdd('qryAddProduto', Nenhum, '',
                  'delete from itemDocumento');
                FDCSqlAdd('qryAddProduto', inteiro, vendaID,
                  'where documentoId = {}');
                FDCGetQry('qryAddProduto').ExecSQL;

                FDCCloseQry('qryAddProduto');
                FDCClearQry('qryAddProduto');
                FDCSqlAdd('qryAddProduto', Nenhum, '',
                  'delete from documentoNFCe');
                FDCSqlAdd('qryAddProduto', inteiro, vendaID, 'where id = {}');
                FDCGetQry('qryAddProduto').ExecSQL;

              except
                on e: exception do
                  raise exception.Create(e.Message);
              end;

              self.Close;

            finally
              FDCCloseQry('qryAddProduto');
              FDCDestroyQry('qryAddProduto');
            end;

          end;
      end;
    end);

end;

procedure TfFormVendasCadastro.btnFinalizarClick(Sender: TObject);
var
  IdentificadorTransacao: string;
  ValTransacao: Double;
  TipoCartao: TACBrTEFTiposCartao;
  ModPagto: TACBrTEFModalidadePagamento;
  ModFinanc: TACBrTEFModalidadeFinanciamento;
  Parcelas: Byte;
  DataPre: TDate;
  DocumentoPago: boolean;
  Erro: boolean;
  ErroMsg: string;
  msg: string;
begin

  inherited;

  if Assigned(fFormVendasPagamento) then
    FreeAndNil(fFormVendasPagamento);

  if not Assigned(fFormVendasPagamento) then
    fFormVendasPagamento := TfFormVendasPagamento.Create(Application);

  fFormVendasPagamento.vendaID := vendaID;
  fFormVendasPagamento.vendaValor := self.GetValorVenda();

  fFormVendasPagamento.Show;

end;

procedure TfFormVendasCadastro.btnIdentificarClick(Sender: TObject);
begin

  inherited;

  { }

  edtInformarCPF.Text := edt_cnpj_cpf.Text;

  formOverlay.Visible := true;
  pnlInformarCPF.Visible := true;

  edtInformarCPF.SetFocus;

end;

procedure TfFormVendasCadastro.btnImprimir1Click(Sender: TObject);
begin

  inherited;

  formOverlay.Visible := true;
  pnlImpressao.Visible := true;

end;

procedure TfFormVendasCadastro.btnInutilizarClick(Sender: TObject);
var
  msg: string;
begin

  inherited;

  msg := 'Deseja realmente INUTILIZAR a venda?';

  MessageDlg(msg, System.UITypes.TMsgDlgType.mtConfirmation,
    [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      case AResult of
        mrYES:
          begin

          end;
      end;
    end);

end;

procedure TfFormVendasCadastro.btnMenuClick(Sender: TObject);
begin

  inherited;

  if (idSelecionado = 0) then
  begin

    if Assigned(fFormVendasIncluirProduto) then
      FreeAndNil(fFormVendasIncluirProduto);

    if not Assigned(fFormVendasIncluirProduto) then
      fFormVendasIncluirProduto := TfFormVendasIncluirProduto.Create
        (Application);

    fFormVendasIncluirProduto.vendaID := vendaID;
    fFormVendasIncluirProduto.Show;

  end
  else
  begin

    MessageDlg('Deseja realmente excluir este produto?',
      System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
      procedure(const AResult: System.UITypes.TModalResult)
      begin
        case AResult of
          mrYES:
            begin

              FDCCreateQry('qryAddProduto');

              try

                try

                  FDCCloseQry('qryAddProduto');
                  FDCClearQry('qryAddProduto');

                  FDCSqlAdd('qryAddProduto', Nenhum, '',
                    'delete from itemDocumento');
                  FDCSqlAdd('qryAddProduto', inteiro, vendaID,
                    'where documentoId = {}');
                  FDCSqlAdd('qryAddProduto', inteiro, idSelecionado,
                    '   and id = {}');
                  FDCGetQry('qryAddProduto').ExecSQL;

                except
                  on e: exception do
                    raise exception.Create(e.Message);
                end;

              finally
                FDCCloseQry('qryAddProduto');
                FDCDestroyQry('qryAddProduto');
              end;

              idSelecionado := 0;
              frameSelecionado := nil;

              atualizarVenda();
              prcCarregarRegistro();
              prcAjustaBotoes();

            end;
        end;
      end);

  end

end;

procedure TfFormVendasCadastro.btnSairClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormVendasCadastro.btnSair1Click(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormVendasCadastro.edtInformarCPFTyping(Sender: TObject);
var
  valorSemFormatacao: string;
  Mascara: string;
begin

  inherited;

  valorSemFormatacao := TEdit(Sender).Text;
  valorSemFormatacao := StringReplace(valorSemFormatacao, ' ', '',
    [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '#', '',
    [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '/', '',
    [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '.', '',
    [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '-', '',
    [rfReplaceAll, rfIgnoreCase]);

  TEdit(Sender).Text := AplicarMascaraSimples('###.###.###-##',
    valorSemFormatacao);
  TEdit(Sender).CaretPosition := TEdit(Sender).Text.Length;

end;

procedure TfFormVendasCadastro.FormKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin

  if Key = vkHardwareBack then
  begin

    if pnlInformarCPF.Visible then
    begin
      pnlInformarCPF.Visible := false;
      formOverlay.Visible := false;
    end;

    if pnlImpressao.Visible then
    begin
      pnlImpressao.Visible := false;
      formOverlay.Visible := false;
    end;

  end;

  inherited;

end;

procedure TfFormVendasCadastro.Rectangle1Click(Sender: TObject);
begin

  inherited;

  { Consultar Cliente }

  pnlInformarCPF.Visible := false;
  formOverlay.Visible := false;

  if Assigned(fFormVendasIdentificarCliente) then
    FreeAndNil(fFormVendasIdentificarCliente);

  if not Assigned(fFormVendasIdentificarCliente) then
    fFormVendasIdentificarCliente := TfFormVendasIdentificarCliente.Create
      (Application);

  fFormVendasIdentificarCliente.vendaID := vendaID;
  fFormVendasIdentificarCliente.Show;

end;

procedure TfFormVendasCadastro.Rectangle4Click(Sender: TObject);
begin

  inherited;

  { Informar CPF }

  FDCCreateQry('qryAddProduto');

  try

    try

      FDCCloseQry('qryAddProduto');
      FDCClearQry('qryAddProduto');

      FDCSqlAdd('qryAddProduto', Nenhum, '', 'update documentoNFCe');
      FDCSqlAdd('qryAddProduto', Texto, edtInformarCPF.Text,
        '   set cnpjcpf = {}, destinatarioId = NULL');
      FDCSqlAdd('qryAddProduto', inteiro, vendaID, ' where id = {}');
      FDCGetQry('qryAddProduto').ExecSQL;

      pnlInformarCPF.Visible := false;
      formOverlay.Visible := false;

      atualizarVenda();
      prcCarregarRegistro();
      prcAjustaBotoes();

    except
      on e: exception do
        raise exception.Create(e.Message);
    end;

  finally
    FDCCloseQry('qryAddProduto');
    FDCDestroyQry('qryAddProduto');
  end;

end;

procedure TfFormVendasCadastro.Imprimir(ops: integer);
var
  EscPos: string;
  ComandoInicial, ComandoFinal: string;
begin

  inherited;

  atualizarVenda();
  prcCarregarRegistro();
  prcAjustaBotoes();

  EscPos := nuvemFiscalObterEscPos(chaveUnicaNuvemFiscal);

  ACBrPosPrinter1.Porta := iniLerString('Impressao', 'porta');
  ACBrPosPrinter1.Modelo := IntToPosPrinterModelo(iniLerInteiro('Impressao',
    'modelo'));
  ACBrPosPrinter1.PaginaDeCodigo := IntToPosPaginaCodigo
    (iniLerInteiro('Impressao', 'paginaCodigo'));
  ACBrPosPrinter1.ColunasFonteNormal := iniLerInteiro('Impressao',
    'colunasFonteNormal');
  ACBrPosPrinter1.EspacoEntreLinhas := iniLerInteiro('Impressao',
    'espacoEntreLinhas');
  ACBrPosPrinter1.LinhasEntreCupons := iniLerInteiro('Impressao',
    'linhasEntreCupons');
  ACBrPosPrinter1.ConfigLogo.KeyCode1 := iniLerInteiro('Impressao',
    'configLogoKeyCode1');
  ACBrPosPrinter1.ConfigLogo.KeyCode2 := iniLerInteiro('Impressao',
    'configLogoKeyCode2');
  ACBrPosPrinter1.ControlePorta := iniLerBooleano('Impressao', 'controlePorta');

  ACBrPosPrinter1.Ativar;

  ComandoInicial := '</zera>';
  ComandoInicial := ComandoInicial + '<c>';
  ComandoFinal := '</lf>';
  ACBrPosPrinter1.Imprimir(ComandoInicial + Comprovante1Via.Text +
    ComandoFinal);

  MessageDlg('Deseja imprimir a via do cliente?',
    System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes,
    System.UITypes.TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      case AResult of
        mrYES:
          begin

            ComandoInicial := '</zera>';
            ComandoInicial := ComandoInicial + '<c>';
            ComandoFinal := '</lf>';
            ACBrPosPrinter1.Imprimir(ComandoInicial + Comprovante2Via.Text +
              ComandoFinal);

          end;
      end;
    end);

  if (ops = 2) then
  begin
    MessageDlg('Deseja imprimir o cupom?',
      System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
      procedure(const AResult: System.UITypes.TModalResult)
      begin
        case AResult of
          mrYES:
            begin

              ComandoInicial := '</zera>';
              ComandoInicial := ComandoInicial + '<c>';
              ComandoFinal := '</lf>';
              ACBrPosPrinter1.Imprimir(ComandoInicial + EscPos + ComandoFinal);

            end;
        end;
      end);
  end;

end;

procedure TfFormVendasCadastro.Rectangle5Click(Sender: TObject);
begin
  Imprimir(2);
end;

procedure TfFormVendasCadastro.Rectangle6Click(Sender: TObject);
begin

  inherited;

  nuvemFiscalGerarDanfe(chaveUnicaNuvemFiscal);

  formOverlay.Visible := false;
  pnlImpressao.Visible := false;

end;

initialization

RegisterClass(TfFormVendasCadastro);

finalization

UnRegisterClass(TfFormVendasCadastro);

end.
