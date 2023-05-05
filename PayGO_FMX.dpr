program PayGO_FMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  uApplicationParamList in 'commons\uApplicationParamList.pas',
  uFuncoesDB in 'commons\uFuncoesDB.pas',
  uFuncoesGerais in 'commons\uFuncoesGerais.pas',
  uFuncoesINI in 'commons\uFuncoesINI.pas',
  uFuncoesNuvemFiscalAPI in 'commons\uFuncoesNuvemFiscalAPI.pas',
  vkbdhelper in 'commons\vkbdhelper.pas',
  uDataModule in 'infrastructure\connection\uDataModule.pas' {DM: TDataModule},
  uFrameButton in 'presentation\components\buttons\uFrameButton.pas' {tFrameButton: TFrame},
  uFrameMainMenuButton in 'presentation\components\buttons\uFrameMainMenuButton.pas' {fFrameMainMenuButton: TFrame},
  uFrameItemLista in 'presentation\components\listViewItem\uFrameItemLista.pas' {fFrameItemLista: TFrame},
  uFrameItemListaClientes in 'presentation\components\listViewItem\uFrameItemListaClientes.pas' {fFrameItemListaClientes: TFrame},
  uFrameItemListaIncluirProdutos in 'presentation\components\listViewItem\uFrameItemListaIncluirProdutos.pas' {fFrameItemListaIncluirProdutos: TFrame},
  uFrameItemListaItemVenda in 'presentation\components\listViewItem\uFrameItemListaItemVenda.pas' {fFrameItemListaItemVenda: TFrame},
  uFrameItemListaPadraoDuasLinhas in 'presentation\components\listViewItem\uFrameItemListaPadraoDuasLinhas.pas' {fFrameItemListaPadraoDuasLinhas: TFrame},
  uFrameItemListaPadraoTresLinhas in 'presentation\components\listViewItem\uFrameItemListaPadraoTresLinhas.pas' {fFrameItemListaPadraoTresLinhas: TFrame},
  uFrameItemListaProdutos in 'presentation\components\listViewItem\uFrameItemListaProdutos.pas' {fFrameItemListaProdutos: TFrame},
  uFrameItemListaVendas in 'presentation\components\listViewItem\uFrameItemListaVendas.pas' {fFrameItemListaVendas: TFrame},
  uFormBase in 'presentation\forms\uFormBase.pas' {fFormBase},
  uFormClientes in 'presentation\forms\uFormClientes.pas' {fFormClientes},
  uFormClientesCadastro in 'presentation\forms\uFormClientesCadastro.pas' {fFormClientesCadastro},
  uFormConfiguracoes in 'presentation\forms\uFormConfiguracoes.pas' {fFormConfiguracoes},
  uFormFormaPagamento in 'presentation\forms\uFormFormaPagamento.pas' {fFormFormaPagamento},
  uFormLogin in 'presentation\forms\uFormLogin.pas' {fFormLogin},
  uFormProdutos in 'presentation\forms\uFormProdutos.pas' {fFormProdutos},
  uFormProdutosCadastro in 'presentation\forms\uFormProdutosCadastro.pas' {fFormProdutosCadastro},
  uFormUnidades in 'presentation\forms\uFormUnidades.pas' {fFormUnidades},
  uFormUsuarios in 'presentation\forms\uFormUsuarios.pas' {fFormUsuarios},
  uFormVendas in 'presentation\forms\uFormVendas.pas' {fFormVendas},
  uFormVendasCadastro in 'presentation\forms\uFormVendasCadastro.pas' {fFormVendasCadastro},
  uFormVendasIncluirProduto in 'presentation\forms\uFormVendasIncluirProduto.pas' {fFormVendasIncluirProduto},
  uFormVendasIdentificarCliente in 'presentation\forms\uFormVendasIdentificarCliente.pas' {fFormVendasIdentificarCliente},
  uConfiguracoes in 'infrastructure\dto\uConfiguracoes.pas',
  uGlobal in 'commons\uGlobal.pas',
  uEmitente in 'infrastructure\dto\uEmitente.pas',
  XSuperJSON in 'commons\XSuperJSON.pas',
  XSuperObject in 'commons\XSuperObject.pas',
  uFormVendasPagamento in 'presentation\forms\uFormVendasPagamento.pas' {fFormVendasPagamento},
  ACBrTEFPayGoAndroidAPI in 'commons\ACBrTEFPayGoAndroidAPI.pas',
  uFormInutilizacao in 'presentation\forms\uFormInutilizacao.pas' {fFormInutilizacao},
  uFuncoesACBr in 'commons\uFuncoesACBr.pas',
  G700Interface in 'commons\G700Interface.pas',
  GEDIPrinter in 'commons\GEDIPrinter.pas',
  InterfaceAutomacao_v1_6_0_0 in 'commons\InterfaceAutomacao_v1_6_0_0.pas',
  uFormMain in 'presentation\forms\uFormMain.pas' {fFormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait, TFormOrientation.InvertedPortrait, TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;

end.

