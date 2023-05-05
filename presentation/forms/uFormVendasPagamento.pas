unit uFormVendasPagamento;

interface

uses

  {$IFDEF ANDROID}
    Androidapi.JNI.GraphicsContentViewText,
    ACBrPosPrinterElginE1Service,
    ACBrPosPrinterElginE1Lib,
    ACBrPosPrinterGEDI,
    ACBrPosPrinterTecToySunmiLib,
  {$ENDIF}

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.ImageList, FMX.Types, FMX.Platform, FMX.Controls, FMX.VirtualKeyboard,
  FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit, FMX.SpinBox, FMX.StdCtrls,
  FMX.ListBox, FMX.Layouts, FMX.ScrollBox, FMX.Memo, FMX.ImgList, FMX.Objects,
  FMX.ComboEdit, FMX.DateTimeCtrls, FMX.TabControl, FMX.EditBox,
  FMX.Controls.Presentation, FMX.DialogService, FMX.Ani, FMX.Memo.Types,
  ACBrTEFAndroid, ACBrTEFComum,
  ACBrBase, ACBrPosPrinter, ACBrTEFAPIComum,
  uGlobal, uFormBase, FMX.Effects, uFrameItemListaVendas,
  uFrameItemListaItemVenda, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfFormVendasPagamento = class(TfFormBase)
    layoutCabecalhoPagamento: TLayout;
    Layout2: TLayout;
    layoutValorVenda: TLayout;
    lnInfoValorVenda: TLine;
    lblValorVenda: TText;
    lblInfoValorVenda: TText;
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    Layout4: TLayout;
    btnDinheiro: TRectangle;
    lblDinheiro: TText;
    shadowDinheiro: TShadowEffect;
    btnTefPayGO: TRectangle;
    lblTefPayGO: TText;
    shadowTefPauGO: TShadowEffect;
    tabIdentificacao_Logos: TLayout;
    tabIdentificacao_GridLogos: TGridPanelLayout;
    Image2: TImage;
    Image1: TImage;
    tbcPagamento: TTabControl;
    tabPagamento: TTabItem;
    tabLog: TTabItem;
    tabUltimaTransacao: TTabItem;
    memoLog: TMemo;
    memoDadosUltimaTransacao: TMemo;
    ACBrTEF: TACBrTEFAndroid;

    procedure FormCreate(Sender: TObject);
    procedure ACBrTEFQuandoFinalizarOperacao(RespostaTEF: TACBrTEFResp);
    procedure ACBrTEFQuandoDetectarTransacaoPendente(RespostaTEF: TACBrTEFResp; const MsgErro: string);
    procedure ACBrTEFQuandoFinalizarTransacao(RespostaTEF: TACBrTEFResp; AStatus:
        TACBrTEFStatusTransacao);
    procedure ACBrTEFQuandoGravarLog(const ALogLine: string; var Tratado: Boolean);

    {$IFDEF ANDROID}
      procedure ACBrTEFQuandoIniciarTransacao(AIntent: JIntent);
    {$ENDIF}

    procedure btnDinheiroClick(Sender: TObject);

    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure btnTefPayGOClick(Sender: TObject);
  private

    { Private declarations }

    function GetValorVenda: Double;
    procedure SetValorVenda(const Value: Double);

    procedure InicializarTEF;
    procedure AplicarConfiguracaoPersonalizacao;
    procedure AplicarConfiguracaoTransacao;

  public

    { Public declarations }

    vendaID: integer;
    strViaEstabelecimento: string;
    strViaCliente: string;
    nfceStatus: integer;
    vendaValor: Currency;

    property ValorVenda: Double read GetValorVenda write SetValorVenda;

  end;

var
  fFormVendasPagamento: TfFormVendasPagamento;

implementation

uses

  Math, StrUtils, IniFiles, DateUtils, System.TypInfo, System.IOUtils,

  {$IFDEF ANDROID}
    Androidapi.JNI.Widget,
    Androidapi.Helpers,
    FMX.Helpers.Android,
    ACBrTEFAndroidPayGo,
  {$ENDIF}

  ACBrTEFPayGoComum, ACBrUtil, ACBrValidador,
  uFormVendasIdentificarCliente, uFormVendasIncluirProduto, uFuncoesGerais,
  uFuncoesNuvemFiscalAPI, uFuncoesDB, uFuncoesINI, uFormVendasCadastro;

{$R *.fmx}

procedure TfFormVendasPagamento.AplicarConfiguracaoPersonalizacao;
begin
  ACBrTEF.Personalizacao.Clear;
end;

procedure TfFormVendasPagamento.AplicarConfiguracaoTransacao;
var
  MoedaISO: Integer;
begin

  {$IFDEF ANDROID}

  try

    MoedaISO := 986;

    ACBrTEF.DadosAutomacao.MoedaISO4217 := MoedaISO;

    if ACBrTEF.TEF is TACBrTEFAndroidPayGoClass then
    begin
      with TACBrTEFAndroidPayGoClass(ACBrTEF.TEF) do
      begin
        Autorizador := '';
      end;
    end;

  except
    on e: Exception do
    begin
      Toast(e.Message);
    end;
  end;

  {$ENDIF}

end;

procedure TfFormVendasPagamento.InicializarTEF;
begin

  try

    if ACBrTEF.Inicializado then
      Exit;

    ACBrTEF.DesInicializar;
    ACBrTEF.Modelo := tefPayGo;
    ACBrTEF.DiretorioTrabalho := TPath.Combine(TPath.GetPublicPath, 'tef');
    ACBrTEF.ArqLOG := TPath.Combine(ACBrTEF.DiretorioTrabalho, 'acbrtefandroid.log');

    if not DirectoryExists(ACBrTEF.DiretorioTrabalho) then
      ForceDirectories(ACBrTEF.DiretorioTrabalho);

    ACBrTEF.DadosAutomacao.NomeSoftwareHouse := 'SacFiscal';
    ACBrTEF.DadosAutomacao.CNPJSoftwareHouse := TS(fncObterDadosEmpresa('cnpj_cpf'));
    ACBrTEF.DadosAutomacao.NomeAplicacao := 'PayGo_FMX';
    ACBrTEF.DadosAutomacao.VersaoAplicacao := '1.0.0.0';
    ACBrTEF.DadosAutomacao.SuportaSaque := true;
    ACBrTEF.DadosAutomacao.SuportaDesconto := true;
    ACBrTEF.DadosAutomacao.SuportaViasDiferenciadas := false;
    ACBrTEF.DadosAutomacao.ImprimeViaClienteReduzida := false;
    ACBrTEF.DadosAutomacao.UtilizaSaldoTotalVoucher := false;

    ACBrTEF.DadosEstabelecimento.RazaoSocial := TS(fncObterDadosEmpresa('razao_social'));
    ACBrTEF.DadosEstabelecimento.CNPJ := TS(fncObterDadosEmpresa('cnpj_cpf'));

    ACBrTEF.ConfirmarTransacaoAutomaticamente := false;

    AplicarConfiguracaoPersonalizacao;
    AplicarConfiguracaoTransacao;

    if FileExists(ACBrTEF.ArqLOG) then
      DeleteFile(ACBrTEF.ArqLOG);

    ACBrTEF.Inicializar;

  except
    on e: Exception do
    begin
      Toast(e.Message);
    end;
  end;

end;

procedure TfFormVendasPagamento.FormCreate(Sender: TObject);
begin

  {$IFDEF ANDROID}
  ACBrTEF.QuandoIniciarTransacao := ACBrTEFQuandoIniciarTransacao;
  {$ENDIF}

  inherited;

end;

function TfFormVendasPagamento.GetValorVenda: Double;
begin
  Result := StrToIntDef(OnlyNumber(lblValorVenda.Text), 0) / 100;
end;

procedure TfFormVendasPagamento.SetValorVenda(const Value: Double);
var
  AValor: Double;
begin
  AValor := min(max(0, Value), 999999);
  lblValorVenda.Text := 'R$ ' + FormatFloatBr(AValor);
end;

procedure TfFormVendasPagamento.ACBrTEFQuandoFinalizarOperacao(RespostaTEF: TACBrTEFResp);
var
  i, nINFO: Integer;
  TheKey, TheValue: string;
  MsgFinal: string;
  CNPJ, Rede: string;
  reciboTef: TStringList;
begin

  reciboTef := TStringList.Create;

  try

    with memoDadosUltimaTransacao.Lines do
    begin

      Clear;

      MsgFinal := RespostaTEF.TextoEspecialOperador;

      MsgFinal := RespostaTEF.TextoEspecialOperador;

      Add('');
      Add('');
      Add('------ Resultado da Operação ------');
      Add('');
      Add('Sucesso: ..... ' + IfThen(RespostaTEF.Sucesso, 'SIM', 'NÃO'));
      Add('Resultado: ... ' + MsgFinal);
      Add('ReqNum: ...... ' + RespostaTEF.LeInformacao(PWINFO_REQNUM, 0).AsString);
      Add('PosID: ....... ' + RespostaTEF.LeInformacao(PWINFO_POSID, 0).AsString);

      Add('');
      Add('');
      Add('------ Transação Pendente ------');
      Add('');
      Add('Nome do Provedor Transação Pendente: ....... ' + RespostaTEF.LeInformacao(PWINFO_PNDAUTHSYST, 0).AsString);
      Add('Id Estabelecimento: ....... ' + RespostaTEF.LeInformacao(PWINFO_PNDVIRTMERCH, 0).AsString);
      Add('Local Transação: ....... ' + RespostaTEF.LeInformacao(PWINFO_PNDREQNUM, 0).AsString);
      Add('Referência PayGO: ....... ' + RespostaTEF.LeInformacao(PWINFO_PNDAUTLOCREF, 0).AsString);
      Add('Referência Provedor: ....... ' + RespostaTEF.LeInformacao(PWINFO_PNDAUTEXTREF, 0).AsString);

      { Usando as propriedades de TACBrTEFResp }

      Add('');
      Add('');
      Add('------ Dados Adicionais ------');
      Add('');

      Add('- Rede: ' + RespostaTEF.Rede);

      Rede := RespostaTEF.Rede;

      Add('- NSU: ' + RespostaTEF.NSU);
      Add('- Moeda: ' + TS(RespostaTEF.Moeda));
      Add('- CodigoAutorizacaoTransacao: ' + TS(RespostaTEF.CodigoAutorizacaoTransacao));
      Add('- CodigoBandeiraPadrao: ' + TS(RespostaTEF.CodigoBandeiraPadrao));
      Add('- CodigoRedeAutorizada: ' + TS(RespostaTEF.CodigoRedeAutorizada));
      Add('- NomeAdministradora: ' + TS(RespostaTEF.NomeAdministradora));
      Add('- StatusTransacao: ' + TS(RespostaTEF.StatusTransacao));
      Add('- Parcelas: ' + IntToStr(RespostaTEF.QtdParcelas) + ', parcelado por: ' + GetEnumName(TypeInfo(TACBrTEFRespParceladoPor), integer(RespostaTEF.ParceladoPor)));
      Add('- Tipo Cartão: ' + IfThen(RespostaTEF.Debito, 'Debito', IfThen(RespostaTEF.Credito, 'Crédito', '')));
      Add('- Valor: ' + FormatFloat(',0.00', RespostaTEF.ValorTotal));

      if (pos('bin', Rede) = 1) or (pos('sipag', Rede) = 1) then
        CNPJ := '02.038.232/0001-64'
      else if (pos('tribanco', Rede) = 1) then
        CNPJ := '17.351.180/0001-59'
      else if (pos('bigcard', Rede) = 1) then
        CNPJ := '04.627.085/0001-93'
      else if (pos('brasilcard', Rede) = 1) then
        CNPJ := '03.817.702/0001-50'
      else if (pos('cabal', Rede) = 1) then
        CNPJ := '03.766.873/0001-06'
      else if (pos('credpar', Rede) = 1) then
        CNPJ := '07.599.577/0004-53'
      else if (pos('ecx', Rede) = 1) then
        CNPJ := '71.225.700/0001-22'
      else if (pos('elavon', Rede) = 1) then
        CNPJ := '12.592.831/0001-89'
      else if (pos('ecofrotas', Rede) = 1) then
        CNPJ := '03.506.307/0001-57'
      else if (pos('jetpar', Rede) = 1) then
        CNPJ := '12.886.711/0002-75'
      else if (pos('usacard', Rede) = 1) then
        CNPJ := '08.011.683/0001-94'
      else if pos('rede', Rede) > 0 then
        CNPJ := '01.425.787/0001-04'
      else if (pos('repon', Rede) = 1) then
        CNPJ := '65.697.260/0001-03'
      else if (pos('senffnet', Rede) = 1) then
        CNPJ := '03.877.288/0001-75'
      else if (pos('siga', Rede) = 1) then
        CNPJ := '04.966.359/0001-79'
      else if (pos('sodexo', Rede) = 1) then
        CNPJ := '69.034.668/0001-56'
      else if (pos('stone', Rede) = 1) then
        CNPJ := '16.501.555/0001-57'
      else if (pos('tecban', Rede) = 1) then
        CNPJ := '51.427.102/0001-29'
      else if (pos('ticket', Rede) = 1) then
        CNPJ := '47.866.934/0001-74'
      else if (pos('valeshop', Rede) = 1) then
        CNPJ := '02.561.118/0001-14'
      else if (pos('visa', Rede) = 1) then
        CNPJ := '01.027.058/0001-91';

      reciboTef.Add(memoDadosUltimaTransacao.Text);

    end;

    strViaEstabelecimento := RespostaTEF.ImagemComprovante2aVia.Text;
    strViaCliente := RespostaTEF.ImagemComprovante1aVia.Text;

    { Exemplo de como processar a Impressão dos comprovantes }

    if not RespostaTEF.Sucesso then
    begin

    end
    else
    begin

      FDCCreateQry('qryPagamento');

      try

        try

          FDCCloseQry('qryPagamento');
          FDCClearQry('qryPagamento');

          FDCSqlAdd('qryPagamento', Nenhum, '', 'insert into pagamentoNFce ');
          FDCSqlAdd('qryPagamento', Nenhum, '', '( ');

          FDCSqlAdd('qryPagamento', Nenhum, '', 'id, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'documentoID, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'indicadorPagamento, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'tipoPagamento, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'tipoIntegracao, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'valorPagamento, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'codigoAutorizacao, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'cnpjPagador, ');

          FDCSqlAdd('qryPagamento', Nenhum, '', 'paygo_recibo, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'paygo_comprovante1via, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'paygo_comprovante2via, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'ReqNum, ');
          FDCSqlAdd('qryPagamento', Nenhum, '', 'Resultado ');

          FDCSqlAdd('qryPagamento', Nenhum, '', ')');

          FDCSqlAdd('qryPagamento', Nenhum, '', 'values ');

          FDCSqlAdd('qryPagamento', Nenhum, '', '(');

          FDCSqlAdd('qryPagamento', inteiro, ultimoValorRegistro('pagamentoNFce', 'id'), '{},');
          FDCSqlAdd('qryPagamento', inteiro, vendaID, '{},');
          FDCSqlAdd('qryPagamento', Nenhum, '', '1, ');

          if RespostaTEF.Debito then
            FDCSqlAdd('qryPagamento', Nenhum, '', ' ''04'', ')
          else
            FDCSqlAdd('qryPagamento', Nenhum, '', ' ''03'', ');

          FDCSqlAdd('qryPagamento', Nenhum, '', '1, ');
          FDCSqlAdd('qryPagamento', numerico, RespostaTEF.ValorTotal, '{}, ');
          FDCSqlAdd('qryPagamento', Texto, TS(RespostaTEF.CodigoAutorizacaoTransacao), '{}, ');
          FDCSqlAdd('qryPagamento', Texto, TS(CNPJ), '{}, ');

          FDCSqlAdd('qryPagamento', Texto, TS(reciboTef.Text), '{}, ');
          FDCSqlAdd('qryPagamento', Texto, TS(RespostaTEF.ImagemComprovante1aVia.Text), '{}, ');
          FDCSqlAdd('qryPagamento', Texto, TS(RespostaTEF.ImagemComprovante2aVia.Text), '{}, ');
          FDCSqlAdd('qryPagamento', Texto, TS(RespostaTEF.LeInformacao(PWINFO_REQNUM, 0).AsString), '{}, ');
          FDCSqlAdd('qryPagamento', Texto, TS(RespostaTEF.TextoEspecialOperador), '{} ');

          FDCSqlAdd('qryPagamento', Nenhum, '', ');');

          FDCGetQry('qryPagamento').ExecSQL;

        except
          on e: Exception do
          begin
            memoDadosUltimaTransacao.Lines.Add('Erro: ' + e.message );
          end;
        end;

      finally
        FDCCloseQry('qryEmitirNFCe');
        FDCDestroyQry('qryEmitirNFCe');
      end;

      nfceStatus := nuvemFiscalEmitirNFCe(vendaID);

      if TI(nfceStatus) = 100 then
      begin
        Toast('Venda Autorizada!');
        TfFormVendasCadastro(self.Owner).Imprimir(1);
        self.Close;
      end
      else
      begin
        memoDadosUltimaTransacao.Lines.Add('Erro: Rejeição ');
      end;

    end;

  except
    on e: Exception do
    begin
      Toast(e.Message);
      memoDadosUltimaTransacao.Lines.Add('Erro: ' + e.message );
    end;
  end;

end;

procedure TfFormVendasPagamento.ACBrTEFQuandoGravarLog(const ALogLine: string; var Tratado: Boolean);
begin

  {Livre implementação da SoftwareHouse}

end;

procedure TfFormVendasPagamento.ACBrTEFQuandoDetectarTransacaoPendente(RespostaTEF: TACBrTEFResp; const MsgErro: string);
begin

  {Livre implementação da SoftwareHouse}

end;

procedure TfFormVendasPagamento.ACBrTEFQuandoFinalizarTransacao(RespostaTEF:
    TACBrTEFResp; AStatus: TACBrTEFStatusTransacao);
begin
  inherited;
end;

{$IFDEF ANDROID}
procedure TfFormVendasPagamento.ACBrTEFQuandoIniciarTransacao(AIntent: JIntent);
begin

  try

    memoLog.Lines.Add('');
    memoLog.Lines.Add('Iniciando Comunicação com APK');
    memoLog.Lines.Add('');

  except
    on e: Exception do
    begin
      Toast(e.Message);
    end;
  end;

end;
{$ENDIF}

procedure TfFormVendasPagamento.btnDinheiroClick(Sender: TObject);
begin

  inherited;

  {
    Exemplo de Pagamento via Dinheiro
     - Gravação Simples do valor Pago na Tabela de Pagamentos da NFC-e
     - Livre implementação da SoftwareHouse
  }

  FDCCreateQry('qryPagamento');

  try

    try

      FDCCloseQry('qryPagamento');
      FDCClearQry('qryPagamento');

      FDCSqlAdd('qryPagamento', Nenhum, '', 'insert into pagamentoNFce ');
      FDCSqlAdd('qryPagamento', Nenhum, '', '( ');

      FDCSqlAdd('qryPagamento', Nenhum, '', 'id, ');
      FDCSqlAdd('qryPagamento', Nenhum, '', 'documentoID, ');
      FDCSqlAdd('qryPagamento', Nenhum, '', 'indicadorPagamento, ');
      FDCSqlAdd('qryPagamento', Nenhum, '', 'tipoPagamento, ');
      FDCSqlAdd('qryPagamento', Nenhum, '', 'tipoIntegracao, ');
      FDCSqlAdd('qryPagamento', Nenhum, '', 'valorPagamento ');

      FDCSqlAdd('qryPagamento', Nenhum, '', ')');

      FDCSqlAdd('qryPagamento', Nenhum, '', 'values ');

      FDCSqlAdd('qryPagamento', Nenhum, '', '(');

      FDCSqlAdd('qryPagamento', inteiro, ultimoValorRegistro('pagamentoNFce', 'id'), '{},');
      FDCSqlAdd('qryPagamento', inteiro, vendaID, '{},');
      FDCSqlAdd('qryPagamento', Nenhum, '', '1, ');
      FDCSqlAdd('qryPagamento', Nenhum, '', ' ''01'', ');
      FDCSqlAdd('qryPagamento', Nenhum, '', '1, ');
      FDCSqlAdd('qryPagamento', numerico, vendaValor, '{} ');

      FDCSqlAdd('qryPagamento', Nenhum, '', ');');

      FDCGetQry('qryPagamento').ExecSQL;

      nfceStatus := nuvemFiscalEmitirNFCe(vendaID);

      if TI(nfceStatus) = 100 then
      begin
        Toast('Venda Autorizada!');
        TfFormVendasCadastro(self.Owner).Imprimir(2);
        self.Close;
      end
      else
      begin
        Toast('Rejeição: ' + IntToStr(nfceStatus));
      end;

    except
      on e: Exception do
      begin
        Toast(e.Message);
      end;
    end;

  finally
    FDCCloseQry('qryPagamento');
    FDCDestroyQry('qryPagamento');
  end;

end;

procedure TfFormVendasPagamento.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  lblValorVenda.Text := FormatFloat('R$ #########,0.00', vendaValor);

end;

procedure TfFormVendasPagamento.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  Self.Close;

end;

procedure TfFormVendasPagamento.btnTefPayGOClick(Sender: TObject);
var
  IdentificadorTransacao: string;
  ValTransacao: Double;
  TipoCartao: TACBrTEFTiposCartao;
  ModPagto: TACBrTEFModalidadePagamento;
  ModFinanc: TACBrTEFModalidadeFinanciamento;
  Parcelas: Byte;
  DataPre: TDate;
  DocumentoPago: Boolean;
  Erro: Boolean;
  ErroMsg: string;
  msg: string;
begin

  inherited;

  try

    DocumentoPago := false;
    Erro := False;

    inherited;

    FDCCreateQry('qryVerificaPagamento');

    try

      try

        FDCCloseQry('qryVerificaPagamento');
        FDCClearQry('qryVerificaPagamento');
        FDCSqlAdd('qryVerificaPagamento', Nenhum, '', 'select * from pagamentoNFCe ');
        FDCSqlAdd('qryVerificaPagamento', Inteiro, vendaID, 'where documentoId = {}');
        FDCOpenQry('qryVerificaPagamento');

        if not FDCGetQry('qryVerificaPagamento').IsEmpty then
          DocumentoPago := true;

      except
        on e: exception do
        begin
          ErroMsg := e.Message;
          Erro := true;
        end;
      end;

    finally
      FDCCloseQry('qryVerificaPagamento');
      FDCDestroyQry('qryVerificaPagamento');
    end;

    if Erro then
    begin
      ShowMessage(ErroMsg);
      Exit;
    end;

    if DocumentoPago = false then
    begin

      ValTransacao := ValorVenda;

      if (ValTransacao <= 0) then
      begin
        Toast('DEFINA UM VALOR');
        Exit;
      end;

      InicializarTEF;
      AplicarConfiguracaoTransacao;

      IdentificadorTransacao := FormatDateTime('hhnnss', now);

      ModPagto := TACBrTEFModalidadePagamento.tefmpNaoDefinido;
      ModFinanc := TACBrTEFModalidadeFinanciamento.tefmfNaoDefinido;
      TipoCartao := [];
      Parcelas := 0;
      DataPre := 0;

      ACBrTEF.EfetuarPagamento(IdentificadorTransacao, ValTransacao, ModPagto, TipoCartao, ModFinanc, Parcelas, DataPre);

    end
    else
    begin

      msg := 'Este documento já possui pagamento registrado!' + #13 + 'Deseja emitir a NFCe?';

      MessageDlg(msg, System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
        procedure(const AResult: System.UITypes.TModalResult)
        begin
          case AResult of
            mrYES:
              begin

                nfceStatus := nuvemFiscalEmitirNFCe(vendaID);

                if TI(nfceStatus) = 100 then
                begin
                  Toast('Venda Autorizada!');
                  // impressao

                  self.Close;
                end
                else
                begin
                  Toast('Rejeição!');
                end;

              end;
          end;
        end);

    end;

  except
    on e: Exception do
    begin
      Toast(e.Message);
    end;
  end;

end;

initialization
  RegisterClass(TfFormVendasPagamento);


finalization
  UnRegisterClass(TfFormVendasPagamento);

end.

