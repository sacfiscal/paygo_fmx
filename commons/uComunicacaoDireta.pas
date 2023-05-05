unit uComunicacaoDireta;

interface

uses

  InterfaceAutomacao_v1_6_0_0,
  GEDIPrinter,    //Esta unit inicializa o Modulo de impressao G700.
  G700Interface,

  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  Androidapi.Log,

  FMX.Platform.Android,
  FMX.Dialogs,
  FMX.DialogService,

  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  Androidapi.JNIBridge,
  Androidapi.JNI.App,
  Androidapi.Jni.GraphicsContentViewText,
  Androidapi.JNI.Util,
  Androidapi.Jni.OS;

  procedure efetuaOperacao(operacoes : JOperacoes;
                            NumeroOperacao: integer;
                            TipoCartao: JCartoes;
                            TipoFinanciamento: JFinanciamentos;
                            Parcelas: integer;
                            Adquirente: string;
                            mudacor: Boolean;
                            ViaDeferenciada: Boolean;
                            ViaReduzida: Boolean;
                            ValorTotal: string);
  procedure iniPayGoInterface(mudacor : Boolean; ViaDeferenciada : Boolean; ViaReduzida: Boolean);
  procedure LogAplicacao(msg: String);
  procedure traduzResultadoOperacao(ConfirmacaoManual: Boolean; nsu, codigoAutorizacao, valorOperacao : string);
  procedure mensagemFim(mensagem : string);
  procedure trataComprovante(DuplaVia: boolean);
  procedure ImpressaoComprovantes(titulo, cupom : string);
  procedure ConfirmaOperacao;
  procedure existeTransacaoPendente;

  function resultadoOperacacao : JRunnable;
  function trataMensagemResultado : string;
  function setPersonalizacao(mudacor : Boolean): JPersonalizacao;

  var
  mHandler          : JHandler;
  mConfimacoes      : JConfirmacoes;
  mDadosAutomacao   : JDadosAutomacao;
  mPersonalizacao   : JPersonalizacao;
  mTransacoes       : JTransacoes;
  mSaidaTransacao   : JSaidaTransacao;
  mEntradaTransacao : JEntradaTransacao;
  mViasImpressao    : JViasImpressao;

implementation

procedure efetuaOperacao(operacoes : JOperacoes;
                          NumeroOperacao: integer;
                          TipoCartao: JCartoes;
                          TipoFinanciamento: JFinanciamentos;
                          Parcelas: integer;
                          Adquirente: string;
                          mudacor: Boolean;
                          ViaDeferenciada: Boolean;
                          ViaReduzida: Boolean;
                          ValorTotal: string);

var
  mensagemErro : string;
begin
  // OK
  tthread.CreateAnonymousThread(
    procedure
    begin

      iniPayGoInterface(mudacor, ViaDeferenciada, ViaReduzida);

      mEntradaTransacao := TJEntradaTransacao.JavaClass.init(operacoes, StringToJString(IntToStr(NumeroOperacao)));

      // Start da operação

      // Se for venda informa o número da operação
      if operacoes = TJOperacoes.JavaClass.VENDA then
        mEntradaTransacao.informaDocumentoFiscal(StringToJString(IntToStr(NumeroOperacao)));

      // Valor Total da Operação
      mEntradaTransacao.informaValorTotal(StringToJString(ValorTotal.Replace(',', '').Replace('.','')));

      // Case seja um cancelamento
      if operacoes = TJOperacoes.JavaClass.CANCELAMENTO then
      begin
//         mEntradaTransacao.informaNsuTransacaoOriginal(cancelamentoFragment.getNSU());
//         mEntradaTransacao.informaCodigoAutorizacaoOriginal(cancelamentoFragment.getCodigoAutorizacao());
//         mEntradaTransacao.informaDataHoraTransacaoOriginal(cancelamentoFragment.getData());
//        //Informa novamente o valor para realizar a operação de cancelamento
//         mEntradaTransacao.informaValorTotal(cancelamentoFragment.getValorTrans());
      end;

      mEntradaTransacao.informaTipoCartao(TJCartoes.JavaClass.CARTAO_DEBITO);

      // Defini o tipo de cartão que vai ser usado na operação
      if TipoCartao = TipoCartao.CARTAO_DESCONHECIDO then
        begin
          mEntradaTransacao.informaTipoCartao(TJCartoes.JavaClass.CARTAO_DESCONHECIDO);
        end
      else if TipoCartao = TipoCartao.CARTAO_CREDITO then
        begin
          mEntradaTransacao.informaTipoCartao(TJCartoes.JavaClass.CARTAO_CREDITO);
        end

      else if TipoCartao = TipoCartao.CARTAO_DEBITO then
        begin
          mEntradaTransacao.informaTipoCartao(TJCartoes.JavaClass.CARTAO_DEBITO);
        end

      else if TipoCartao = TipoCartao.CARTAO_VOUCHER then
        begin
          mEntradaTransacao.informaTipoCartao(TJCartoes.JavaClass.CARTAO_VOUCHER);
        end;

      mEntradaTransacao.informaTipoFinanciamento(TJFinanciamentos.JavaClass.A_VISTA);

      // Define o tipo de parcelamento ou se a operação vai ser A Vista
      if TipoFinanciamento = TipoFinanciamento.FINANCIAMENTO_NAO_DEFINIDO then
        begin
          mEntradaTransacao.informaTipoFinanciamento(TJFinanciamentos.JavaClass.FINANCIAMENTO_NAO_DEFINIDO);
        end
      else if TipoFinanciamento = TipoFinanciamento.A_VISTA then
        begin
          mEntradaTransacao.informaTipoFinanciamento(TJFinanciamentos.JavaClass.A_VISTA);
        end

      else if TipoFinanciamento = TipoFinanciamento.PARCELADO_EMISSOR then
        begin
          mEntradaTransacao.informaTipoFinanciamento(TJFinanciamentos.JavaClass.PARCELADO_EMISSOR);
          mEntradaTransacao.informaNumeroParcelas(Parcelas);
        end

      else if TipoFinanciamento = TipoFinanciamento.PARCELADO_ESTABELECIMENTO then
        begin
          mEntradaTransacao.informaTipoFinanciamento(TJFinanciamentos.JavaClass.PARCELADO_ESTABELECIMENTO);
          mEntradaTransacao.informaNumeroParcelas(Parcelas);
        end;

      // Define o provedor que sera usado
      if Adquirente = '' then
        // OK
      else if Adquirente = 'PROVEDOR DESCONHECIDO' then
        // OK
      else
        mEntradaTransacao.informaNomeProvedor(StringToJString(Adquirente));

      try
        try
          begin
            // Moeda que esta sendo usada na operação
            mEntradaTransacao.informaCodigoMoeda(StringToJString('986')); // Real
            mConfimacoes := TJConfirmacoes.Create;

            mSaidaTransacao := mTransacoes.realizaTransacao(mEntradaTransacao);

            if mSaidaTransacao = nil then
                LogAplicacao('mSaidaTransacao esta NIL');

            mConfimacoes.informaIdentificadorConfirmacaoTransacao(
                  mSaidaTransacao.obtemIdentificadorConfirmacaoTransacao
                );
          end;
        except
          on e : EJNIException do
          begin
            mensagemErro := e.Message;
          end;
          on e : Exception do
          begin
            mensagemErro := e.Message;
          end;

        end;
      finally
        mHandler.post(resultadoOperacacao);
      end;
    end
  ).Start;

end;

procedure iniPayGoInterface(mudacor : Boolean; ViaDeferenciada : Boolean; ViaReduzida: Boolean);
var
  versao : JString;
begin

  versao := MainActivity.getPackageManager.getPackageInfo(MainActivity.getPackageName, 0).versionName;

  mPersonalizacao := setPersonalizacao(mudacor);

  mDadosAutomacao := TJDadosAutomacao.JavaClass.init(
                                         StringToJString('Gertec'),             // Empresa Automação
                                         StringToJString('Automação Demo'),     // Nome Automação
                                         versao,                                // Versão
                                         true,                                  // Suporta Troco
                                         true,                                  // Suporta Desconto
                                         ViaDeferenciada,                       // Via Diferenciada
                                         ViaReduzida,                           // Via Reduzida
                                         mPersonalizacao);                      // Personaliza Tela

  mTransacoes := TJTransacoes.JavaClass.obtemInstancia(mDadosAutomacao, MainActivity);

end;

procedure LogAplicacao(msg: String);
var
  M: TMarshaller;
begin
  LOGW(M.AsUtf8(msg).ToPointer);
end;

function resultadoOperacacao : JRunnable;
begin

  LogAplicacao('Ate aqui OK.');
  //traduzResultadoOperacao;

end;

procedure traduzResultadoOperacao(ConfirmacaoManual: Boolean; nsu, codigoAutorizacao, valorOperacao : string);
var

  mensagemAlert : string;
  mensagemErro, mensagemRetorno : string;

  resultado : Integer;

  confirmaOperacaoManual : Boolean;
  TransacaoPendente : Boolean;

begin

  resultado := -999999;

  if mSaidaTransacao = nil then
    resultado := -999999
  else
    begin

      confirmaOperacaoManual := false;
      TransacaoPendente := false;

      resultado := mSaidaTransacao.obtemResultadoTransacao();

      if resultado = 0 then
        begin
          if mSaidaTransacao.obtemInformacaoConfirmacao() then
            begin
              if ConfirmacaoManual then
                begin
                  LogAplicacao('CONFIRMADO_MANUAL');
                  confirmaOperacaoManual := true;
                end
              else
                begin
                  LogAplicacao('CONFIRMADO_AUTOMATICO');
                  mConfimacoes.informaStatusTransacao(TJStatusTransacao.JavaClass.CONFIRMADO_AUTOMATICO);
                  mTransacoes.confirmaTransacao(mConfimacoes);
                end;

            end
          else if mSaidaTransacao.existeTransacaoPendente then
            begin
              LogAplicacao('Tratar');
            end

        end

      else if mSaidaTransacao.existeTransacaoPendente then
        begin
          LogAplicacao('Existe Transação Pendente');
          mConfimacoes := TJConfirmacoes.Create;
          TransacaoPendente := true
        end

      else
        begin
          LogAplicacao('Aconteceu algum erro no processo');
          mensagemAlert := 'Erro';
        end;

      mensagemRetorno := JStringToString(TJString.Wrap(mSaidaTransacao.obtemMensagemResultado.intern));

      if mensagemRetorno.length > 0 then
        begin
          LogAplicacao('Até aqui esta tudo certo');
          LogAplicacao(mensagemRetorno);
          if resultado = 0 then
            begin
              nsu        := JStringToString(mSaidaTransacao.obtemNsuHost);
              codigoAutorizacao := JStringToString(mSaidaTransacao.obtemCodigoAutorizacao);
              //valorOperacao     := editValor.Text;

              mensagemAlert := mensagemRetorno;
              mensagemAlert := mensagemAlert + #13#10 + #13#10 + trataMensagemResultado();

            end
          else
            mensagemAlert := mensagemAlert + #13#10 + #13#10 +  mensagemRetorno;

        end
      else if (mensagemErro.length = 0) then
        begin
          if resultado = 0 then
            mensagemAlert := 'Operação OK'
          else
            mensagemAlert := 'Erro: ' + IntToStr(resultado);
        end

      else
        begin
          mensagemAlert := mensagemRetorno;
        end;


      if resultado = 0 then
        begin
          if(confirmaOperacaoManual) then
            begin
              mensagemFim(mensagemAlert);
              ConfirmaOperacao;
            end
          else
            begin
              trataComprovante;
              mensagemFim(mensagemAlert);
            end
        end
      else
        if(TransacaoPendente) then
          existeTransacaoPendente
        else
          mensagemFim(mensagemAlert);

    end;

end;

function trataMensagemResultado : string;
var
  mensagem : string;
begin

  mensagem := 'ID do Cartão: ' + JStringToString(mSaidaTransacao.obtemAidCartao);

  mensagem := mensagem + #13#10 + #13#10 + 'Nome Portador Cartão: ' + JStringToString( mSaidaTransacao.obtemNomePortadorCartao());
  mensagem := mensagem + #13#10 + 'Nome Cartão Padrão: ' + JStringToString( mSaidaTransacao.obtemNomeCartaoPadrao());
  mensagem := mensagem + #13#10 + 'Nome Estabelecimento: ' + JStringToString( mSaidaTransacao.obtemNomeEstabelecimento());

  mensagem := mensagem + #13#10 + #13#10 + 'Pan Mascarado Cartão: ' + JStringToString( mSaidaTransacao.obtemPanMascaradoPadrao());
  mensagem := mensagem + #13#10 + 'Pan Mascarado: ' + JStringToString( mSaidaTransacao.obtemPanMascarado());

  mensagem := mensagem + #13#10 + #13#10 + 'Identificador Transação: ' + JStringToString( mSaidaTransacao.obtemIdentificadorConfirmacaoTransacao());

  mensagem := mensagem + #13#10 + #13#10 + 'NSU Original: ' + JStringToString( mSaidaTransacao.obtemNsuLocalOriginal());
  mensagem := mensagem + #13#10 + 'NSU Local: ' + JStringToString( mSaidaTransacao.obtemNsuLocal());
  mensagem := mensagem + #13#10 + 'NSU Transação: ' + JStringToString( mSaidaTransacao.obtemNsuHost());

  mensagem := mensagem + #13#10 + #13#10 + 'Nome Cartão: ' + JStringToString( mSaidaTransacao.obtemNomeCartao());
  mensagem := mensagem + #13#10 + 'Nome Provedor: ' + JStringToString( mSaidaTransacao.obtemNomeProvedor());

  mensagem := mensagem + #13#10 + #13#10 + 'Modo Verificação Senha: ' + JStringToString( mSaidaTransacao.obtemModoVerificacaoSenha());

  mensagem := mensagem + #13#10 + #13#10 + 'Cod Autorização: ' + JStringToString( mSaidaTransacao.obtemCodigoAutorizacao());
  mensagem := mensagem + #13#10 + 'Cod Autorização Original: ' + JStringToString( mSaidaTransacao.obtemCodigoAutorizacaoOriginal());
  mensagem := mensagem + #13#10 + 'Ponto Captura: ' + JStringToString( mSaidaTransacao.obtemIdentificadorPontoCaptura());

  mensagem := mensagem + #13#10 + #13#10 + 'Valor da Operação: ' + JStringToString( mSaidaTransacao.obtemValorTotal());
  mensagem := mensagem + #13#10 + 'Salvo Voucher: ' + JStringToString( mSaidaTransacao.obtemSaldoVoucher());

  LogAplicacao(mensagem);

  result := mensagem;

end;

function setPersonalizacao(mudacor : Boolean): JPersonalizacao;
var
  pb : JPersonalizacao_Builder;
begin

  pb := TJPersonalizacao_Builder.Create;

  if mudacor then
  begin
    pb.informaCorFonte(StringToJString('#000000'));
    pb.informaCorFonteTeclado(StringToJString('#000000'));
    pb.informaCorFundoCaixaEdicao(StringToJString('#FFFFFF'));
    pb.informaCorFundoTela(StringToJString('#F4F4F4'));
    pb.informaCorFundoTeclado(StringToJString('#F4F4F4'));
    pb.informaCorFundoToolbar(StringToJString('#2F67F4'));
    pb.informaCorTextoCaixaEdicao(StringToJString('#000000'));
    pb.informaCorTeclaPressionadaTeclado(StringToJString('#e1e1e1'));
    pb.informaCorTeclaLiberadaTeclado(StringToJString('#dedede'));
    pb.informaCorSeparadorMenu(StringToJString('#2F67F4'));

  end;

  result := pb.build;

end;

procedure mensagemFim(mensagem : string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      TDialogService.MessageDialog
              (mensagem,
              System.UITypes.TMsgDlgType.mtConfirmation,
              [System.UITypes.TMsgDlgBtn.mbOK],
              System.UITypes.TMsgDlgBtn.mbOK, 0,
              procedure(const AResult: TModalResult)
              begin
                LogAplicacao('Mensagem FIM');
              end);
            end);
end;

procedure trataComprovante(DuplaVia: boolean);
var
  listCupom : JList;
  iter: JIterator;
  cupom : string;
begin

  if DuplaVia then
    begin
      mViasImpressao := mSaidaTransacao.obtemViasImprimir();

      if ( mViasImpressao.equals(TJViasImpressao.JavaClass.VIA_CLIENTE) )
         or
          ( mViasImpressao.equals(TJViasImpressao.JavaClass.VIA_CLIENTE_E_ESTABELECIMENTO) ) then
         begin
          listCupom := mSaidaTransacao.obtemComprovanteDiferenciadoPortador;
          if listCupom.size > 0  then
            begin
              cupom := '';
              iter := listCupom.iterator;
              while iter.hasNext do
              begin
                cupom := cupom + JStringToString(TJString.Wrap(iter.next).intern);
              end;
              ImpressaoComprovantes('Via Cliente', cupom);

            end;

         end;

      if ( mViasImpressao.equals(TJViasImpressao.JavaClass.VIA_ESTABELECIMENTO) )
          or
         ( mViasImpressao.equals(TJViasImpressao.JavaClass.VIA_CLIENTE_E_ESTABELECIMENTO) ) then
        begin
          listCupom := mSaidaTransacao.obtemComprovanteDiferenciadoLoja;
          if listCupom.size > 0  then
          begin
            cupom := '';
            iter := listCupom.iterator;
            while iter.hasNext do
            begin
              cupom := cupom + JStringToString(TJString.Wrap(iter.next).intern);
            end;
            ImpressaoComprovantes('Via do Estabelecimento', cupom);

          end;

        end;

    end
  else
    begin
      listCupom := mSaidaTransacao.obtemComprovanteCompleto;
      if listCupom.size > 0  then
      begin
        iter := listCupom.iterator;
        while iter.hasNext do
        begin
          cupom := cupom + JStringToString(TJString.Wrap(iter.next).intern);
        end;
        ImpressaoComprovantes('Comprovante Full', cupom);
      end;
    end;

end;

procedure ImpressaoComprovantes(titulo, cupom : string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      TDialogService.MessageDialog
              ('Deseja imprimir ' + titulo + '?',
              System.UITypes.TMsgDlgType.mtConfirmation,
              [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
              System.UITypes.TMsgDlgBtn.mbYes, 0,
              procedure(const AResult: TModalResult)
              begin
                LogAplicacao('Imprimindo ' + titulo);
                if (AResult = mrYES) then
                  begin
                    GertecPrinter.textSize := 18;
                    GertecPrinter.FlagBold := true;
                    GertecPrinter.textFamily := 0;
                    GertecPrinter.PrintString(ESQUERDA, cupom);
                    GertecPrinter.printBlankLine(150);
                    GertecPrinter.printOutput;
                  end;
              end);
            end);
end;

procedure ConfirmaOperacao;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      TDialogService.MessageDialog
              ('Deseja confirmar a operação?',
              System.UITypes.TMsgDlgType.mtConfirmation,
              [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
              System.UITypes.TMsgDlgBtn.mbYes, 0,
              procedure(const AResult: TModalResult)
              begin
                LogAplicacao('CONFIRMADO_MANUAL');
                if (AResult = mrYES) then
                  begin
                    LogAplicacao('Operador acabou de confirmar a operação.');
                    mConfimacoes.informaStatusTransacao(TJStatusTransacao.JavaClass.CONFIRMADO_MANUAL);
                    mTransacoes.confirmaTransacao(mConfimacoes);
                    trataComprovante;
                  end
                else
                  begin
                    LogAplicacao('Operador acabou de cancelar a operação.');
                    mConfimacoes.informaStatusTransacao(TJStatusTransacao.JavaClass.DESFEITO_MANUAL);
                    mTransacoes.confirmaTransacao(mConfimacoes);
                    trataComprovante;
                  end;
              end);
            end);
end;

procedure existeTransacaoPendente;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      TDialogService.MessageDialog
              ('Deseja confirmar a transação que esta PENDENTE?',
              System.UITypes.TMsgDlgType.mtConfirmation,
              [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
              System.UITypes.TMsgDlgBtn.mbYes, 0,
              procedure(const AResult: TModalResult)
              begin
                LogAplicacao('CONFIRMADO_MANUAL');
                if (AResult = mrYES) then
                  begin
                    LogAplicacao('Transação Pendente foi CONFIRMADO_MANUAL.');
                    mConfimacoes.informaStatusTransacao(TJStatusTransacao.JavaClass.CONFIRMADO_MANUAL);
                    mTransacoes.resolvePendencia(mSaidaTransacao.obtemDadosTransacaoPendente, mConfimacoes);
                  end
                else
                  begin
                    LogAplicacao('Transação Pendente foi DESFEITO_ERRO_IMPRESSAO_AUTOMATICO.');
                    mConfimacoes.informaStatusTransacao(TJStatusTransacao.JavaClass.DESFEITO_ERRO_IMPRESSAO_AUTOMATICO);
                    mTransacoes.confirmaTransacao(mConfimacoes);
                  end;
              end);
            end);
end;

end.
