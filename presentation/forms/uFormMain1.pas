unit uFormMain1;

interface

uses
  uDataModule, uGlobal, uConfiguracoes, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.FMXUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageXML, FireDAC.Phys.SQLite, FireDAC.Stan.StorageBin, FireDAC.Comp.UI, FireDAC.Comp.Client,
  Data.DB, FireDAC.Comp.DataSet, uFrameMainMenuButton, uFrameButton;

type
  TfFormMain1 = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarTitle: TText;
    PageToolBarLeftImage: TImage;
    opcoesMenu: TLayout;
    lblInfoUsuario: TText;
    Line1: TLine;
    logomarcasProjeto: TLayout;
    agrupadorLogomarcasProjeto: TLayout;
    gridLogomarcas: TGridPanelLayout;
    logoPaygo: TImage;
    logoNuvemFiscal: TImage;
    listaOpcoesMenu: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarContent: TLayout;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnClientes: TfFrameMainMenuButton;
    btnProdutos: TfFrameMainMenuButton;
    btnUnidades: TfFrameMainMenuButton;
    btnFormaPagamento: TfFrameMainMenuButton;
    btnConfiguracoes: TfFrameMainMenuButton;
    btnUsuarios: TfFrameMainMenuButton;
    btnVendas: TfFrameMainMenuButton;
    btnSair: TtFrameButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnUnidadesClick(Sender: TObject);
    procedure btnFormaPagamentoClick(Sender: TObject);
    procedure btnUsuariosClick(Sender: TObject);
    procedure btnConfiguracoesClick(Sender: TObject);
    procedure btnVendasClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnSairClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

    { Private declarations }

    sairDoAplicativo: Boolean;

  public

    { Public declarations }

  end;

var
  fFormMain1: TfFormMain1;

implementation

uses
  uFormLogin, uFormClientes, uFormProdutos, uFormUnidades, uFormFormaPagamento, uFormUsuarios, uFormConfiguracoes, uFormVendas,
  uFuncoesGerais, uFuncoesDB, uFuncoesINI, uFormMain;

{$R *.fmx}

procedure TfFormMain1.btnClientesClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormClientes) then
    FreeAndNil(fFormClientes);

  if not Assigned(fFormClientes) then
    fFormClientes := TfFormClientes.Create(Application);

  fFormClientes.Show;

end;

procedure TfFormMain1.btnConfiguracoesClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormConfiguracoes) then
    FreeAndNil(fFormConfiguracoes);

  if not Assigned(fFormConfiguracoes) then
    fFormConfiguracoes := TfFormConfiguracoes.Create(Application);

  fFormConfiguracoes.Show;

end;

procedure TfFormMain1.btnFormaPagamentoClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormFormaPagamento) then
    FreeAndNil(fFormFormaPagamento);

  if not Assigned(fFormFormaPagamento) then
    fFormFormaPagamento := TfFormFormaPagamento.Create(Application);

  fFormFormaPagamento.Show;

end;

procedure TfFormMain1.btnProdutosClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormProdutos) then
    FreeAndNil(fFormProdutos);

  if not Assigned(fFormProdutos) then
    fFormProdutos := TfFormProdutos.Create(Application);

  fFormProdutos.Show;

end;

procedure TfFormMain1.btnUnidadesClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormUnidades) then
    FreeAndNil(fFormUnidades);

  if not Assigned(fFormUnidades) then
    fFormUnidades := TfFormUnidades.Create(Application);

  fFormUnidades.Show;

end;

procedure TfFormMain1.btnUsuariosClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormUsuarios) then
    FreeAndNil(fFormUsuarios);

  if not Assigned(fFormUsuarios) then
    fFormUsuarios := TfFormUsuarios.Create(Application);

  fFormUsuarios.Show;

end;

procedure TfFormMain1.btnVendasClick(Sender: TObject);
begin

  inherited;

  if Assigned(fFormVendas) then
    FreeAndNil(fFormVendas);

  if not Assigned(fFormVendas) then
    fFormVendas := TfFormVendas.Create(Application);

  fFormVendas.Show;

end;

procedure TfFormMain1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  if (CanClose = true) and (sairDoAplicativo = false) then
  begin

    CanClose := False;
    Exit;

  end;

  inherited;

end;

procedure TfFormMain1.FormCreate(Sender: TObject);
begin

  if uGlobal.globalConfiguracoes = nil then
    uGlobal.globalConfiguracoes := TNFConfiguracoes.Create
  else
    uGlobal.globalConfiguracoes.refresh;

  useBackButton := false;

  sairDoAplicativo := false;

  empresaIdentificada := iniLerBooleano('Config', 'empresaIdentificada');
  manterLogin := iniLerBooleano('Config', 'manterLogin');
  aplicativoLogado := iniLerBooleano('Config', 'aplicativoLogado');

  inherited;

  lblInfoUsuario.Text := 'Olá, ' + iniLerString('Usuario', 'loginUsuario');

end;

procedure TfFormMain1.FormShow(Sender: TObject);
begin

  try
    atualizarTabelas();
  except
  end;

  if uFuncoesGerais.empresaIdentificada = false then
  begin

    fFormMain.Hide;

    if Assigned(fFormLogin) then
      FreeAndNil(fFormLogin);

    if not Assigned(fFormLogin) then
      fFormLogin := TfFormLogin.Create(Application);

    fFormLogin.fncTipoTelaLogin(uFormLogin.ttlIdentificacao);
    fFormLogin.Show;

  end
  else
  begin

    if uFuncoesGerais.aplicativoLogado = false then
    begin

      fFormMain.Hide;

      if Assigned(fFormLogin) then
        FreeAndNil(fFormLogin);

      if not Assigned(fFormLogin) then
        fFormLogin := TfFormLogin.Create(Application);

      fFormLogin.fncTipoTelaLogin(uFormLogin.ttlLogin);
      fFormLogin.Show;

    end;

  end;

  inherited;

end;

procedure TfFormMain1.btnSairClick(Sender: TObject);
begin

  inherited;

  aplicativoLogado := false;
  iniGravarBoleano('config', 'aplicativoLogado', aplicativoLogado);

  if uFuncoesGerais.aplicativoLogado = false then
  begin

    fFormMain.Hide;

    if Assigned(fFormLogin) then
      FreeAndNil(fFormLogin);

    if not Assigned(fFormLogin) then
      fFormLogin := TfFormLogin.Create(Application);

    fFormLogin.fncTipoTelaLogin(uFormLogin.ttlLogin);
    fFormLogin.Show;

  end;

end;

procedure TfFormMain1.FormActivate(Sender: TObject);
begin

  inherited;

  if uGlobal.globalConfiguracoes = nil then
    uGlobal.globalConfiguracoes := TNFConfiguracoes.Create
  else
    uGlobal.globalConfiguracoes.refresh;

end;

initialization
  RegisterClass(TfFormMain1);


finalization
  UnRegisterClass(TfFormMain1);

end.

