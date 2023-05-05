unit uFormConfiguracoes;

interface

uses

  {$IFDEF ANDROID}
    Androidapi.JNI.GraphicsContentViewText,
    ACBrPosPrinterElginE1Service,
    ACBrPosPrinterElginE1Lib,
    ACBrPosPrinterGEDI,
    ACBrPosPrinterTecToySunmiLib,
  {$ENDIF}

  uDataModule, uGlobal, uConfiguracoes, System.SysUtils, System.Types,
  System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase,
  FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, ACBrBase, ACBrPosPrinter,
  FMX.TabControl, ACBrTEFAPIComum, ACBrTEFAndroid, ACBrTEFComum, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo;

type
  TfFormConfiguracoes = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    Layout2: TLayout;
    ScrollContent: TVertScrollBox;
    ACBrPosPrinter1: TACBrPosPrinter;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    layout_ambiente: TLayout;
    lbl_ambiente: TText;
    edt_ambiente: TComboBox;
    layout_emitenteId: TLayout;
    edt_emitenteId: TEdit;
    lbl_emitenteId: TText;
    layout_impressao: TLayout;
    btBuscarImpressoras: TCornerButton;
    Layout1: TLayout;
    edt_impressora: TComboBox;
    Text1: TText;
    layout_serieNfce: TLayout;
    edt_serieNfce: TEdit;
    lbl_serieNfce: TText;
    layout_ultimaNfce: TLayout;
    edt_ultimaNfce: TEdit;
    lbl_ultimaNfce: TText;
    Layout3: TLayout;
    CornerButton1: TCornerButton;
    ACBrTEF: TACBrTEFAndroid;
    TabControl2: TTabControl;
    TabItem3: TTabItem;
    TabItem5: TTabItem;
    Layout4: TLayout;
    btnAdministracao: TCornerButton;
    Layout5: TLayout;
    btnTesteComunicacao: TCornerButton;
    Layout6: TLayout;
    btnExibeVersao: TCornerButton;
    memoDadosUltimaTransacao: TMemo;

    procedure ACBrTEFQuandoDetectarTransacaoPendente(RespostaTEF: TACBrTEFResp; const MsgErro: string);
    procedure ACBrTEFQuandoFinalizarOperacao(RespostaTEF: TACBrTEFResp);
    procedure ACBrTEFQuandoFinalizarTransacao(RespostaTEF: TACBrTEFResp; AStatus: TACBrTEFStatusTransacao);
    procedure ACBrTEFQuandoGravarLog(const ALogLine: string; var Tratado: Boolean);

    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure btBuscarImpressorasClick(Sender: TObject);
    procedure InicializarPosPrinter;
    procedure AplicarConfiguracaoPosPrinter;
    procedure btnAdministracaoClick(Sender: TObject);
    procedure btnExibeVersaoClick(Sender: TObject);
    procedure btnTesteComunicacaoClick(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure ImprimirRelatorio(ATexto: String);
  private

    { Private declarations }

    procedure InicializarTEF;
    procedure AplicarConfiguracaoPersonalizacao;
    procedure AplicarConfiguracaoTransacao;

  public

    { Public declarations }

    procedure popularComboImpressoras(var combo: TComboBox);
    procedure CarregarImpressorasBth;

  end;

var
  fFormConfiguracoes: TfFormConfiguracoes;

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
  uFuncoesGerais,
  uFuncoesNuvemFiscalAPI, uFuncoesDB, uFuncoesINI,
  uFuncoesACBr;

{$R *.fmx}

procedure TfFormConfiguracoes.ACBrTEFQuandoDetectarTransacaoPendente(
    RespostaTEF: TACBrTEFResp; const MsgErro: string);
begin

  {TO-DO}
  inherited;

end;

procedure TfFormConfiguracoes.ACBrTEFQuandoFinalizarOperacao(RespostaTEF:
    TACBrTEFResp);
var
  i, nINFO: Integer;
  TheKey, TheValue: string;
  MsgFinal: string;
  CNPJ, Rede: string;
  reciboTef: TStringList;
begin

  try

    with memoDadosUltimaTransacao.Lines do
    begin

      Clear;

      MsgFinal := RespostaTEF.TextoEspecialOperador;

      Add('');
      Add('');
      Add('------ Resultado da Operação ------');
      Add('');
      Add('Operação: .... ' + RespostaTEF.LeInformacao(PWINFO_OPERATION, 0).AsString);
      Add('Sucesso: ..... ' + IfThen(RespostaTEF.Sucesso, 'SIM', 'NÃO'));
      Add('Resultado: ... ' + MsgFinal);
      Add('ReqNum: ...... ' + RespostaTEF.LeInformacao(PWINFO_REQNUM, 0).AsString);
      Add('PosID: ....... ' + RespostaTEF.LeInformacao(PWINFO_POSID, 0).AsString);

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

      { Lendo um Campo Específico }

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

    end;

  except
    on e: Exception do
    begin
      Toast(e.Message);
    end;
  end;

end;

procedure TfFormConfiguracoes.ACBrTEFQuandoFinalizarTransacao(RespostaTEF:
    TACBrTEFResp; AStatus: TACBrTEFStatusTransacao);
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

      Add('');
      Add('');
      Add('------ Resultado da Operação ------');
      Add('');
      Add('Operação: .... ' + RespostaTEF.LeInformacao(PWINFO_OPERATION, 0).AsString);
      Add('Sucesso: ..... ' + IfThen(RespostaTEF.Sucesso, 'SIM', 'NÃO'));
      Add('Resultado: ... ' + MsgFinal);
      Add('ReqNum: ...... ' + RespostaTEF.LeInformacao(PWINFO_REQNUM, 0).AsString);
      Add('PosID: ....... ' + RespostaTEF.LeInformacao(PWINFO_POSID, 0).AsString);

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

      { Lendo um Campo Específico }

      Add('- PWINFO_REQNUM: ' + RespostaTEF.LeInformacao(PWINFO_REQNUM, 0).AsString);

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

    { Exemplo de como processar a Impressão dos comprovantes }

    if RespostaTEF.Sucesso then
    begin

      memoDadosUltimaTransacao.Lines.Add( RespostaTEF.StatusTransacao );
      memoDadosUltimaTransacao.Lines.Add( RespostaTEF.CodigoAutorizacaoTransacao );
      memoDadosUltimaTransacao.Lines.Add( RespostaTEF.ToString );

    end;

  except
    on e: Exception do
    begin
      Toast(e.Message);
    end;
  end;

end;

procedure TfFormConfiguracoes.ACBrTEFQuandoGravarLog(const ALogLine: string;
    var Tratado: Boolean);
begin

  {TO-DO}
  inherited;

end;

procedure TfFormConfiguracoes.InicializarTEF;
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

procedure TfFormConfiguracoes.AplicarConfiguracaoPersonalizacao;
begin

  ACBrTEF.Personalizacao.Clear;

end;

procedure TfFormConfiguracoes.AplicarConfiguracaoTransacao;
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

procedure TfFormConfiguracoes.AplicarConfiguracaoPosPrinter;
begin
  if Assigned(edt_impressora.Selected) then
    ACBrPosPrinter1.Porta := edt_impressora.Selected.Text
  else if edt_impressora.ItemIndex = edt_impressora.Items.IndexOf('NULL') then
    edt_impressora.ItemIndex := -1;

  ACBrPosPrinter1.Modelo := ppEscPosEpson;

  if Assigned(edt_impressora.Selected) then
    ACBrPosPrinter1.Porta := edt_impressora.Selected.Text
  else if edt_impressora.ItemIndex = edt_impressora.Items.IndexOf('NULL') then
    edt_impressora.ItemIndex := -1;

  ACBrPosPrinter1.PaginaDeCodigo := pc850;

  ACBrPosPrinter1.ColunasFonteNormal := 32;
  ACBrPosPrinter1.EspacoEntreLinhas := 0;
  ACBrPosPrinter1.LinhasEntreCupons := 0;
  ACBrPosPrinter1.ConfigLogo.KeyCode1 := 1;
  ACBrPosPrinter1.ConfigLogo.KeyCode2 := 0;
  ACBrPosPrinter1.ControlePorta := true;
end;

procedure TfFormConfiguracoes.btBuscarImpressorasClick(Sender: TObject);
begin

  inherited;

  // Solicita a atualização da lista de dispositivos
  CarregarImpressorasBth;

  edt_impressora.DropDown;

end;

procedure TfFormConfiguracoes.btnAdministracaoClick(Sender: TObject);
var
  IdentificadorTransacao: string;
  ValTransacao: Double;
  DocumentoPago: Boolean;
  Erro: Boolean;
  ErroMsg: string;
  msg: string;
begin

  InicializarTEF;
  AplicarConfiguracaoTransacao;
  IdentificadorTransacao := FormatDateTime('hhnnss', now);
  ACBrTEF.EfetuarAdministrativa(TACBrTEFOperacao.tefopAdministrativo);

end;

procedure TfFormConfiguracoes.btnExibeVersaoClick(Sender: TObject);
var
  IdentificadorTransacao: string;
  ValTransacao: Double;
  DocumentoPago: Boolean;
  Erro: Boolean;
  ErroMsg: string;
  msg: string;
begin

  InicializarTEF;
  AplicarConfiguracaoTransacao;
  IdentificadorTransacao := FormatDateTime('hhnnss', now);
  ACBrTEF.EfetuarAdministrativa(TACBrTEFOperacao.tefopVersao);

end;

procedure TfFormConfiguracoes.btnTesteComunicacaoClick(Sender: TObject);
var
  IdentificadorTransacao: string;
  ValTransacao: Double;
  DocumentoPago: Boolean;
  Erro: Boolean;
  ErroMsg: string;
  msg: string;
begin

  InicializarTEF;
  AplicarConfiguracaoTransacao;
  IdentificadorTransacao := FormatDateTime('hhnnss', now);
  ACBrTEF.EfetuarAdministrativa(TACBrTEFOperacao.tefopTesteComunicacao);

end;

procedure TfFormConfiguracoes.CarregarImpressorasBth;
begin

  // transformando a função em generica, para reutilizaçao
  popularComboImpressoras(edt_impressora);

end;

procedure TfFormConfiguracoes.CornerButton1Click(Sender: TObject);
var
  SL: TStringList;
begin
  inherited;
  AplicarConfiguracaoPosPrinter;

  SL := TStringList.Create;
  try
    SL.Add('  *** DEMO PayGO NFCe - ANDROID ***');
    SL.Add('        PayGO - Nuvem Fiscal');
    SL.Add('          SACFiscal - ACBr');
    SL.Add('');
    SL.Add('Teste de Impressão');
    SL.Add('99.999.999/9999-99');
    SL.Add('');
    SL.Add('#####:$$$$$$  VALOR 000000000100');
    SL.Add('--------------------------------------');
    SL.Add('12345 EC:0000000123 REF:0000001234');

    ImprimirRelatorio(SL.Text);
  finally
    SL.Free;
  end;

end;

procedure TfFormConfiguracoes.FormShow(Sender: TObject);
begin

  if uGlobal.globalConfiguracoes = nil then
    uGlobal.globalConfiguracoes := TNFConfiguracoes.Create
  else
    uGlobal.globalConfiguracoes.refresh;

  useBackButton := false;

  inherited;

  // Ao entrar na tela, ja popula o combo.....
  popularComboImpressoras(edt_impressora);

  if TI(uGlobal.globalConfiguracoes.ambiente) = 1 then
    edt_ambiente.ItemIndex := 0
  else
    edt_ambiente.ItemIndex := 1;

  edt_emitenteId.Text :=
    formatCPFCNPJ(TS(uGlobal.globalConfiguracoes.emitente.cnpjCpf));

  edt_serieNfce.Text := TS(uGlobal.globalConfiguracoes.serieNfce);
  edt_ultimaNfce.Text := TS(uGlobal.globalConfiguracoes.ultimaNfce);

  if(iniLerString('Impressao','impressora') <> '') then
  begin

   // IndexOf - tem que estar populado
   edt_impressora.ItemIndex            := edt_impressora.Items.IndexOf(iniLerString('Impressao','impressora'));

   ACBrPosPrinter1.Porta               := iniLerString('Impressao','porta');
   ACBrPosPrinter1.Modelo              := IntToPosPrinterModelo(iniLerInteiro('Impressao','modelo'));
   ACBrPosPrinter1.PaginaDeCodigo      := IntToPosPaginaCodigo(iniLerInteiro('Impressao','paginaCodigo'));
   ACBrPosPrinter1.ColunasFonteNormal  := iniLerInteiro('Impressao','colunasFonteNormal');
   ACBrPosPrinter1.EspacoEntreLinhas   := iniLerInteiro('Impressao','espacoEntreLinhas');
   ACBrPosPrinter1.LinhasEntreCupons   := iniLerInteiro('Impressao','linhasEntreCupons');
   ACBrPosPrinter1.ConfigLogo.KeyCode1 := iniLerInteiro('Impressao','configLogoKeyCode1');
   ACBrPosPrinter1.ConfigLogo.KeyCode2 := iniLerInteiro('Impressao','configLogoKeyCode2');
   ACBrPosPrinter1.ControlePorta       := iniLerBooleano('Impressao','controlePorta');
  end;

end;

procedure TfFormConfiguracoes.ImprimirRelatorio(ATexto: String);
var
  ComandoInicial, ComandoFinal: string;
begin
  InicializarPosPrinter;

  ComandoInicial := '</zera>';
  ComandoInicial := ComandoInicial + '<c>';
  ComandoFinal := '</lf>';
  ACBrPosPrinter1.Imprimir(ComandoInicial + ATexto + ComandoFinal);
end;

procedure TfFormConfiguracoes.InicializarPosPrinter;
begin
  if ACBrPosPrinter1.Ativo then
    Exit;

  if (edt_impressora.Selected = nil) then
  begin
    Toast('Configurar a Impressora');
    // MostrarTelaConfiguracao(1);
    Abort;
  end;

  ACBrPosPrinter1.Ativar;

end;

procedure TfFormConfiguracoes.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormConfiguracoes.PageToolBarButtonRightClick(Sender: TObject);
var
  tpAmb: string;
begin

  inherited;

  try

    if edt_ambiente.ItemIndex = 0 then
      tpAmb := '1'
    else
      tpAmb := '2';

    uGlobal.globalConfiguracoes.ambiente(tpAmb).serieNfce(TI(edt_serieNfce.Text)).ultimaNfce(TI(edt_ultimaNfce.Text)).save;

    if Assigned(edt_impressora.Selected) then
    begin
      iniGravarString('Impressao', 'impressora',
        edt_impressora.Items[edt_impressora.ItemIndex]);
      iniGravarString('Impressao', 'porta', ACBrPosPrinter1.Porta);
      iniGravarInteiro('Impressao', 'modelo',
        PosPrinterModeloToInt(ACBrPosPrinter1.Modelo));
      iniGravarInteiro('Impressao', 'paginaCodigo',
        PaginaCodigoToInt(ACBrPosPrinter1.PaginaDeCodigo));
      iniGravarInteiro('Impressao','colunasFonteNormal', ACBrPosPrinter1.ColunasFonteNormal);
      iniGravarInteiro('Impressao','espacoEntreLinhas', ACBrPosPrinter1.EspacoEntreLinhas);
      iniGravarInteiro('Impressao','linhasEntreCupons', ACBrPosPrinter1.LinhasEntreCupons);
      iniGravarInteiro('Impressao','configLogoKeyCode1', ACBrPosPrinter1.ConfigLogo.KeyCode1);
      iniGravarInteiro('Impressao','configLogoKeyCode2', ACBrPosPrinter1.ConfigLogo.KeyCode2);
      iniGravarBoleano('Impressao','controlePorta', ACBrPosPrinter1.ControlePorta);
    end;

    self.Close;

  except
    on e: exception do
    begin
      Toast(e.Message);
    end;
  end;

end;

procedure TfFormConfiguracoes.popularComboImpressoras(var combo: TComboBox);
begin

  combo.Items.Clear;
  try
    ACBrPosPrinter1.Device.AcharPortasBlueTooth(combo.Items, true);
    combo.Items.Add('NULL');
  except
    on e: exception do
    begin
      Toast(e.Message);
    end;
  end;

end;

initialization

RegisterClass(TfFormConfiguracoes);

finalization

UnRegisterClass(TfFormConfiguracoes);

end.
