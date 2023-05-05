unit uFormLogin;

interface

uses
  uFormBase, uGlobal, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types, FMX.Graphics,
  FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.Effects,
  FMX.TabControl;

type
  TTipoTelaLogin = (ttlIdentificacao, ttlLogin);

  TfFormLogin = class(TfFormBase)
    tabFormPages: TTabControl;
    tabIdentificacao: TTabItem;
    tabLogin: TTabItem;
    tabIdentificacao_content: TLayout;
    tabIdentificacao_Informacoes: TLayout;
    lblInformacoes1: TText;
    lblInformacoes2: TText;
    btnIniciar: TRectangle;
    btnIniciarCaption: TText;
    lblInformacoes3: TText;
    lblInformacoes4: TText;
    lblLinkNuvemFiscal: TText;
    cnpjEmpresa: TRectangle;
    edtCnpjEmpresa: TEdit;
    lblCnpjEmpresa: TText;
    tabIdentificacao_Logos: TLayout;
    tabIdentificacao_GridLogos: TGridPanelLayout;
    Image2: TImage;
    Image1: TImage;
    tabLogin_content: TLayout;
    tabLogin_Informacoes: TLayout;
    Rectangle1: TRectangle;
    Text1: TText;
    ShadowEffect1: TShadowEffect;
    Text2: TText;
    Text3: TText;
    nomeUsuario: TRectangle;
    edtNomeUsuario: TEdit;
    lblNomeUsuario: TText;
    senhaUsuario: TRectangle;
    edtSenhaUsuario: TEdit;
    lblSenhaUsuario: TText;
    tabLogin_Logos: TLayout;
    tabLogin_GridLogos: TGridPanelLayout;
    Image3: TImage;
    Text4: TText;
    GridPanelLayout1: TGridPanelLayout;
    switchManterLogin: TSwitch;
    Label4: TLabel;
    Layout1: TLayout;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure switchManterLoginSwitch(Sender: TObject);
    procedure edtCnpjEmpresaTyping(Sender: TObject);
    procedure Layout1Click(Sender: TObject);
  private

    { Private declarations }

    tipoTelaLogin: TTipoTelaLogin;
    qtdCliques: integer;

  public

    { Public declarations }

    function fncTipoTelaLogin(value: TTipoTelaLogin): Boolean;

  end;

var
  fFormLogin: TfFormLogin;

implementation

uses
  uFormMain, ufuncoesGerais, uFuncoesDB, uFuncoesINI, uFuncoesNuvemFiscalAPI;

{$R *.fmx}
{ TfFormLogin }

procedure TfFormLogin.btnIniciarClick(Sender: TObject);
var
  cnpjSemMascara: string;
begin

  inherited;

  cnpjSemMascara := edtCnpjEmpresa.Text;

  cnpjSemMascara := StringReplace(cnpjSemMascara, '#', '', [rfReplaceAll, rfIgnoreCase]);
  cnpjSemMascara := StringReplace(cnpjSemMascara, '.', '', [rfReplaceAll, rfIgnoreCase]);
  cnpjSemMascara := StringReplace(cnpjSemMascara, '-', '', [rfReplaceAll, rfIgnoreCase]);
  cnpjSemMascara := StringReplace(cnpjSemMascara, '/', '', [rfReplaceAll, rfIgnoreCase]);

  if not empresaIdentificada then
  begin

    try

      if nuvemFiscalVaidarEmpresaAPI(cnpjSemMascara) then
      begin
        ufuncoesGerais.empresaIdentificada := true;
        iniGravarBoleano('Config', 'empresaIdentificada', ufuncoesGerais.empresaIdentificada);
      end;

    except
      on e: exception do
      begin
        Toast(e.message);
      end;
    end;

  end;

  if empresaIdentificada then
    fncTipoTelaLogin(ttlLogin);

end;

procedure TfFormLogin.edtCnpjEmpresaTyping(Sender: TObject);
begin

  inherited;

  TThread.Queue(Nil,
    procedure
    begin
      edtCnpjEmpresa.Text := AplicarMascaraSimples('##.###.###/####-##', edtCnpjEmpresa.Text);
      edtCnpjEmpresa.CaretPosition := edtCnpjEmpresa.Text.Length;
    end);

end;

function TfFormLogin.fncTipoTelaLogin(value: TTipoTelaLogin): Boolean;
begin

  self.tipoTelaLogin := value;

  case self.tipoTelaLogin of
    ttlIdentificacao:
      tabFormPages.ActiveTab := tabIdentificacao;
    ttlLogin:
      tabFormPages.ActiveTab := tabLogin;
  else
    tabFormPages.ActiveTab := tabIdentificacao;
  end;

end;

procedure TfFormLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  inherited;

  if ufuncoesGerais.empresaIdentificada = false then
    Application.Terminate;

  if ufuncoesGerais.aplicativoLogado = false then
    Application.Terminate;

end;

procedure TfFormLogin.FormCreate(Sender: TObject);
begin

  self.tipoTelaLogin := ttlIdentificacao;
  self.switchManterLogin.IsChecked := ufuncoesGerais.manterLogin;

  qtdCliques := 0;

  inherited;

end;

procedure TfFormLogin.Layout1Click(Sender: TObject);
begin

  inherited;

  if (qtdCliques < 10) then
    qtdCliques := qtdCliques + 1;

  if (qtdCliques > 3) then
  begin

    if qtdCliques = 10 then
    begin

      MessageDlg('Deseja realmente zerar os dados da aplicação?' + #13 + #13 +
        'Esta operação irá solicitar uma nova identificação da empresa um novo login.', System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes,
        System.UITypes.TMsgDlgBtn.mbNo], 0,
        procedure(const AResult: System.UITypes.TModalResult)
        begin
          case AResult of
            mrYES:
              begin

                iniGravarBoleano('Config', 'empresaIdentificada', false);
                iniGravarBoleano('Config', 'aplicativoLogado', false);

                FreeAndNil(uGlobal.globalConfiguracoes);

                empresaIdentificada := false;
                aplicativoLogado := false;

                iniGravarInteiro('emitente', 'id', 0);
                iniGravarString('emitente', 'cnpj', '');

                limparTabelas();

                fncTipoTelaLogin(ttlIdentificacao);

                qtdCliques := 0;

              end;
          end;
        end);

    end
    else
    begin
      {$IFDEF ANDROID}
      Toast('Clique mais ' + TS(10 - qtdCliques) + ' vezes para zerar os dados da aplicação.');
      {$ENDIF}
    end;

  end;

end;

procedure TfFormLogin.Rectangle1Click(Sender: TObject);
begin

  inherited;

  if ufuncoesGerais.loginUsuario(edtNomeUsuario.Text, edtSenhaUsuario.Text) then
  begin
    self.Close;
    fFormMain.Show();
  end;

end;

procedure TfFormLogin.switchManterLoginSwitch(Sender: TObject);
begin

  inherited;

  manterLogin := switchManterLogin.IsChecked;
  iniGravarBoleano('Config', 'manterLogin', manterLogin);

end;

initialization
  RegisterClass(TfFormLogin);


finalization
  UnRegisterClass(TfFormLogin);

end.

