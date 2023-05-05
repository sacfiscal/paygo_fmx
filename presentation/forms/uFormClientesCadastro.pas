unit uFormClientesCadastro;

interface

uses
  System.MaskUtils, uDataModule, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.FMXUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageXML, FireDAC.Phys.SQLite, FireDAC.Stan.StorageBin, FireDAC.Comp.UI, FireDAC.Comp.Client,
  Data.DB, FireDAC.Comp.DataSet, FMX.Edit, FMX.ListBox;

type
  TfFormClientesCadastro = class(TfFormBase)
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
    edt_idEstrangeiro: TEdit;
    Text1: TText;
    Layout1: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Text2: TText;
    edt_municipio: TEdit;
    Text3: TText;
    edt_uf: TEdit;
    Layout6: TLayout;
    edt_razao_social: TEdit;
    Text4: TText;
    Layout7: TLayout;
    edt_cnpj_cpf: TEdit;
    Text5: TText;
    Layout8: TLayout;
    edt_ie: TEdit;
    Text6: TText;
    Layout9: TLayout;
    edt_nome_fantasia: TEdit;
    Text7: TText;
    Layout10: TLayout;
    edt_cep: TEdit;
    Text8: TText;
    Layout11: TLayout;
    edt_bairro: TEdit;
    Text9: TText;
    Layout12: TLayout;
    edt_complemento: TEdit;
    Text10: TText;
    Layout13: TLayout;
    Layout14: TLayout;
    Text11: TText;
    edt_logradouro: TEdit;
    Layout15: TLayout;
    Text12: TText;
    edt_numero: TEdit;
    Layout16: TLayout;
    edt_fone: TEdit;
    Text13: TText;
    Layout17: TLayout;
    edt_email: TEdit;
    Text14: TText;
    Image1: TImage;
    Layout18: TLayout;
    btnBusca: TLayout;
    Layout20: TLayout;
    Text15: TText;
    edtTipoCadastro: TComboBox;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnExcluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure edt_cnpj_cpfTyping(Sender: TObject);
    procedure edt_cepTyping(Sender: TObject);
    procedure edt_foneTyping(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBuscaClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure edtTipoCadastroChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

    { Private declarations }

    destinatarioId: integer;
    codigoIbgeMunicipio: string;

  public

    { Public declarations }

    procedure prcCarregarRegistro();

  end;

var
  fFormClientesCadastro: TfFormClientesCadastro;

implementation

uses
  NuvemFiscalClient, NuvemFiscalDTOs, OpenApiRest, uFuncoesNuvemFiscalAPI, uFuncoesGerais, uFuncoesINI, uFuncoesDB;

{$R *.fmx}

procedure TfFormClientesCadastro.edt_cnpj_cpfTyping(Sender: TObject);
var
  valorSemFormatacao: string;
  Mascara: string;
begin

  inherited;

  valorSemFormatacao := TEdit(Sender).Text;
  valorSemFormatacao := StringReplace(valorSemFormatacao, ' ', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '#', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '/', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '.', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '-', '', [rfReplaceAll, rfIgnoreCase]);

  if edtTipoCadastro.ItemIndex = 0 then
    TThread.Queue(Nil,
      procedure
      begin
        TEdit(Sender).Text := AplicarMascaraSimples('###.###.###-##', valorSemFormatacao);
        TEdit(Sender).CaretPosition := TEdit(Sender).Text.Length;
      end)
  else
    TThread.Queue(Nil,
      procedure
      begin
        TEdit(Sender).Text := AplicarMascaraSimples('##.###.###/####-##', valorSemFormatacao);
        TEdit(Sender).CaretPosition := TEdit(Sender).Text.Length;
      end);

end;

procedure TfFormClientesCadastro.edt_foneTyping(Sender: TObject);
var
  valorSemFormatacao: string;
begin

  inherited;

  valorSemFormatacao := TEdit(Sender).Text;
  valorSemFormatacao := StringReplace(valorSemFormatacao, ' ', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '#', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '(', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, ')', '', [rfReplaceAll, rfIgnoreCase]);
  valorSemFormatacao := StringReplace(valorSemFormatacao, '-', '', [rfReplaceAll, rfIgnoreCase]);

  if valorSemFormatacao.Length <= 10 then
    TThread.Queue(Nil,
      procedure
      begin
        TEdit(Sender).Text := AplicarMascaraSimples('(##) ####-####', valorSemFormatacao);
        TEdit(Sender).CaretPosition := TEdit(Sender).Text.Length;
      end)
  else
    TThread.Queue(Nil,
      procedure
      begin
        TEdit(Sender).Text := AplicarMascaraSimples('(##) #####-####', valorSemFormatacao);
        TEdit(Sender).CaretPosition := TEdit(Sender).Text.Length;
      end);

end;

procedure TfFormClientesCadastro.FormCreate(Sender: TObject);
begin

  inherited;

  destinatarioId := TI(FormParmLocal.GetParmS('destinatarioId'));

  if TI(destinatarioId) > 0 then
  begin
    prcCarregarRegistro();
    buttonContent.Visible := True;
  end
  else
  begin
    buttonContent.Visible := false;
  end;

  if edt_cnpj_cpf.Visible then
    edt_cnpj_cpf.SetFocus;

end;

procedure TfFormClientesCadastro.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

end;

procedure TfFormClientesCadastro.btnBuscaClick(Sender: TObject);
const
  qryEmitente: string = 'qryEmitente';
var
  Client: INuvemFiscalClient;
  Empresa: TCnpjEmpresa;
  ConfigNFCe: TEmpresaConfigNfce;
  infoMsg: string;
  emitenteId: integer;
begin

  inherited;

  {Buscar Empresa na API da Nuvem Fiscal}

  emitenteId := 0;

  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  Empresa := Client.Cnpj.ConsultarCnpj(edt_cnpj_cpf.Text);

  edt_razao_social.Text := Empresa.razao_social;
  edt_nome_fantasia.Text := Empresa.razao_social;
  edt_ie.Text := '';
  edt_idEstrangeiro.Text := '';
  edt_cep.Text := Empresa.endereco.cep;
  edt_logradouro.Text := Empresa.endereco.logradouro;
  edt_numero.Text := Empresa.endereco.numero;
  edt_complemento.Text := Empresa.endereco.complemento;
  edt_bairro.Text := Empresa.endereco.bairro;
  codigoIbgeMunicipio := Empresa.endereco.municipio.codigo_ibge;
  edt_municipio.Text := Empresa.endereco.municipio.descricao;
  edt_uf.Text := Empresa.endereco.uf;

  if Empresa.telefones.Count > 0 then
    edt_fone.Text := Empresa.telefones[0].ddd + Empresa.telefones[0].numero;

  edt_email.Text := Empresa.email;

end;

procedure TfFormClientesCadastro.btnExcluirClick(Sender: TObject);
begin

  inherited;

  MessageDlg('Deseja realmente excluir este cliente?', System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes,
    System.UITypes.TMsgDlgBtn.mbNo], 0,
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

                FDCSqlAdd('qryAddProduto', Nenhum, '', 'delete from destinatario');
                FDCSqlAdd('qryAddProduto', Inteiro, destinatarioId, 'where id = {}');
                FDCGetQry('qryAddProduto').ExecSQL;

              except
                on e: exception do
                  raise Exception.Create(e.Message);
              end;

            finally
              FDCCloseQry('qryAddProduto');
              FDCDestroyQry('qryAddProduto');
            end;

            self.close;

          end;
      end;
    end);

end;

procedure TfFormClientesCadastro.edtTipoCadastroChange(Sender: TObject);
begin

  inherited;

  if TComboBox(Sender).ItemIndex = 0 then
  begin
    edt_cnpj_cpf.TextPrompt := '000.000.000-00';
    edt_cnpj_cpf.SetFocus;
    btnBusca.Visible := false;
  end
  else
  begin
    edt_cnpj_cpf.TextPrompt := '00.000.000/0000-00';
    edt_cnpj_cpf.SetFocus;
    btnBusca.Visible := true;
  end;

end;

procedure TfFormClientesCadastro.edt_cepTyping(Sender: TObject);
begin

  inherited;

  TThread.Queue(Nil,
    procedure
    begin
      TEdit(Sender).Text := AplicarMascaraSimples('#####-###', TEdit(Sender).Text);
      TEdit(Sender).CaretPosition := TEdit(Sender).Text.Length;
    end);

end;

procedure TfFormClientesCadastro.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormClientesCadastro.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  FDCCreateQry('qryAdd');

  try

    try

      if TI(destinatarioId) = 0 then
      begin

        FDCCloseQry('qryAdd');
        FDCClearQry('qryAdd');
        FDCSqlAdd('qryAdd', Nenhum, '', 'INSERT INTO destinatario');

        FDCSqlAdd('qryAdd', Nenhum, '', '(');

        FDCSqlAdd('qryAdd', Nenhum, '', 'id,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'emitenteId,');

        FDCSqlAdd('qryAdd', Nenhum, '', 'cnpj_cpf,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'idEstrangeiro,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'razao_social,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'nome_fantasia,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'logradouro,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'numero,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'complemento,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'bairro,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'codigo_municipio,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'municipio,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'uf,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'cep,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'fone,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'indIeDest,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'ie,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'email');

        FDCSqlAdd('qryAdd', Nenhum, '', ')');

        FDCSqlAdd('qryAdd', Nenhum, '', 'VALUES');

        FDCSqlAdd('qryAdd', Nenhum, '', '(');

        FDCSqlAdd('qryAdd', inteiro, ultimoValorRegistro('destinatario', 'id'), '{},');
        FDCSqlAdd('qryAdd', Nenhum, '', '1,');

        FDCSqlAdd('qryAdd', Texto, TiraMascara(edt_cnpj_cpf.text), '{},');
        FDCSqlAdd('qryAdd', Texto, edt_idEstrangeiro.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_razao_social.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_nome_fantasia.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_logradouro.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_numero.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_complemento.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_bairro.text, '{},');
        FDCSqlAdd('qryAdd', Texto, codigoIbgeMunicipio, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_municipio.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_uf.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_cep.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_fone.text, '{},');
        FDCSqlAdd('qryAdd', Texto, '', '''9'',');
        FDCSqlAdd('qryAdd', Texto, edt_ie.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_email.text, '{}');

        FDCSqlAdd('qryAdd', Nenhum, '', ');');

        FDCGetQry('qryAdd').ExecSQL;

      end
      else
      begin

        FDCCloseQry('qryAdd');
        FDCClearQry('qryAdd');
        FDCSqlAdd('qryAdd', Nenhum, '', 'UPDATE destinatario');

        FDCSqlAdd('qryAdd', Nenhum, '', 'SET');

        FDCSqlAdd('qryAdd', Texto, TiraMascara(edt_cnpj_cpf.text), 'cnpj_cpf = {}');

        FDCSqlAdd('qryAdd', Texto, edt_idEstrangeiro.text, ', idEstrangeiro = {}');
        FDCSqlAdd('qryAdd', Texto, edt_razao_social.text, ', razao_social = {}');
        FDCSqlAdd('qryAdd', Texto, edt_nome_fantasia.text, ', nome_fantasia = {}');
        FDCSqlAdd('qryAdd', Texto, edt_logradouro.text, ', logradouro = {}');
        FDCSqlAdd('qryAdd', Texto, edt_numero.text, ', numero = {}');
        FDCSqlAdd('qryAdd', Texto, edt_complemento.text, ', complemento = {}');
        FDCSqlAdd('qryAdd', Texto, edt_bairro.text, ', bairro = {}');
        FDCSqlAdd('qryAdd', Texto, codigoIbgeMunicipio, ', codigo_municipio = {}');
        FDCSqlAdd('qryAdd', Texto, edt_municipio.text, ', municipio = {}');
        FDCSqlAdd('qryAdd', Texto, edt_uf.text, ', uf = {}');
        FDCSqlAdd('qryAdd', Texto, edt_cep.text, ', cep = {}');
        FDCSqlAdd('qryAdd', Texto, edt_fone.text, ', fone = {}');
        FDCSqlAdd('qryAdd', Nenhum, '', ', indIeDest = ''9''');
        FDCSqlAdd('qryAdd', Texto, edt_ie.text, ', ie = {}');
        FDCSqlAdd('qryAdd', Texto, edt_email.text, ', email = {}');

        FDCSqlAdd('qryAdd', inteiro, TI(destinatarioId), 'where id = {} ');
        FDCSqlAdd('qryAdd', Nenhum, '', '  and emitenteId = 1 ');

        FDCGetQry('qryAdd').ExecSQL;

      end;

      self.Close;

    except
      on e: exception do
      begin
        raise Exception.Create(e.Message);
      end;
    end;

  finally
    FDCCloseQry('qryAdd');
    FDCDestroyQry('qryAdd');
  end;

end;

procedure TfFormClientesCadastro.prcCarregarRegistro;
begin

  FDCCreateQry('qryload');

  try

    try

      FDCCloseQry('qryload');
      FDCClearQry('qryload');
      FDCSqlAdd('qryload', Inteiro, TI(destinatarioId), 'SELECT * FROM destinatario WHERE id = {} and emitenteId = 1');
      FDCOpenQry('qryload');

      if Trim(FDCGetQry('qryload').FieldByName('cnpj_cpf').Text).Length <= 11 then
        edtTipoCadastro.ItemIndex := 0
      else
        edtTipoCadastro.ItemIndex := 1;

      edt_cnpj_cpf.text := formatCPFCNPJ(FDCGetQry('qryload').FieldByName('cnpj_cpf').Text);

      edt_idEstrangeiro.text := FDCGetQry('qryload').FieldByName('idEstrangeiro').Text;
      edt_razao_social.text := FDCGetQry('qryload').FieldByName('razao_social').Text;
      edt_nome_fantasia.text := FDCGetQry('qryload').FieldByName('nome_fantasia').Text;
      edt_logradouro.text := FDCGetQry('qryload').FieldByName('logradouro').Text;
      edt_numero.text := FDCGetQry('qryload').FieldByName('numero').Text;
      edt_complemento.text := FDCGetQry('qryload').FieldByName('complemento').Text;
      edt_bairro.text := FDCGetQry('qryload').FieldByName('bairro').Text;
      codigoIbgeMunicipio := FDCGetQry('qryload').FieldByName('codigo_municipio').Text;
      edt_municipio.text := FDCGetQry('qryload').FieldByName('municipio').Text;
      edt_uf.text := FDCGetQry('qryload').FieldByName('uf').Text;
      edt_cep.text := FDCGetQry('qryload').FieldByName('cep').Text;
      edt_fone.text := FDCGetQry('qryload').FieldByName('fone').Text;
      edt_ie.text := FDCGetQry('qryload').FieldByName('ie').Text;
      edt_email.text := FDCGetQry('qryload').FieldByName('email').Text;

    except

    end;

  finally
    FDCCloseQry('qryload');
    FDCDestroyQry('qryload');
  end;

end;

initialization
  RegisterClass(TfFormClientesCadastro);


finalization
  UnRegisterClass(TfFormClientesCadastro);

end.

