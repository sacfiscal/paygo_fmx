unit uFormProdutosCadastro;

interface

uses
  uFormUnidades, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types, FMX.Graphics, FMX.Controls,
  FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Controls.Presentation, FMX.ListBox,
  FMX.Edit;

type
  TfFormProdutosCadastro = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    ScrollContent: TVertScrollBox;
    Layout1: TLayout;
    edt_cfop: TEdit;
    Text1: TText;
    Layout6: TLayout;
    edt_cean: TEdit;
    Text4: TText;
    Layout7: TLayout;
    Layout18: TLayout;
    Text5: TText;
    edt_codigo: TEdit;
    Layout8: TLayout;
    edt_Descricao: TEdit;
    Text6: TText;
    Layout9: TLayout;
    edt_ncm: TEdit;
    Text7: TText;
    Layout10: TLayout;
    edt_cest: TEdit;
    CEST: TText;
    Layout11: TLayout;
    edt_Valor: TEdit;
    Text9: TText;
    Layout16: TLayout;
    edt_codigoAnp: TEdit;
    Text13: TText;
    Layout17: TLayout;
    edt_origem: TEdit;
    Text14: TText;
    Layout2: TLayout;
    edt_cstIcms: TEdit;
    Text2: TText;
    Layout3: TLayout;
    edt_cstpiscofins: TEdit;
    Text3: TText;
    Layout5: TLayout;
    Layout12: TLayout;
    Text10: TText;
    edt_Unidade: TEdit;
    btnBusca: TLayout;
    Image1: TImage;
    Layout4: TLayout;
    edt_cbarra: TEdit;
    Text8: TText;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnExcluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    procedure btnBuscaClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

    { Private declarations }

    produtoId: integer;

  public

    { Public declarations }

    procedure prcCarregarRegistro();

  end;

var
  fFormProdutosCadastro: TfFormProdutosCadastro;

implementation

uses
  NuvemFiscalClient, NuvemFiscalDTOs, OpenApiRest, uFuncoesNuvemFiscalAPI, uFuncoesGerais, uFuncoesINI, uFuncoesDB;

{$R *.fmx}

procedure TfFormProdutosCadastro.btnBuscaClick(Sender: TObject);
begin

  inherited;

  ApplicationParmTemp.AddParmV('produtoId', TI(produtoId));

  if Assigned(fFormUnidades) then
    FreeAndNil(fFormUnidades);

  if not Assigned(fFormUnidades) then
    fFormUnidades := TfFormUnidades.Create(Application);

  fFormUnidades.produtoId := produtoId;
  fFormUnidades.Show;

end;

procedure TfFormProdutosCadastro.btnExcluirClick(Sender: TObject);
begin

  inherited;

  MessageDlg('Deseja realmente excluir este produto?', System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes,
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

                FDCSqlAdd('qryAddProduto', Nenhum, '', 'delete from produto');
                FDCSqlAdd('qryAddProduto', Inteiro, produtoId, 'where id = {}');
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

procedure TfFormProdutosCadastro.FormActivate(Sender: TObject);
var
  unidade: string;
begin

  unidade := TS(ApplicationParmTemp.GetParmS('unidade'));

  inherited;

  if Trim(unidade) <> '' then
    edt_Unidade.Text := unidade;

end;

procedure TfFormProdutosCadastro.FormCreate(Sender: TObject);
begin

  inherited;

  produtoId := TI(FormParmLocal.GetParmS('produtoId'));

  if TI(produtoId) > 0 then
  begin
    prcCarregarRegistro();
    buttonContent.Visible := True;
  end
  else
  begin
    buttonContent.Visible := false;
    edt_codigo.Text := TS(ultimoValorRegistro('produto', 'codigo'));
  end;

  if edt_Descricao.Visible then
    edt_Descricao.SetFocus;

end;

procedure TfFormProdutosCadastro.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

end;

procedure TfFormProdutosCadastro.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.close;

end;

procedure TfFormProdutosCadastro.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  FDCCreateQry('qryAdd');

  try

    try

      if TI(produtoId) = 0 then
      begin

        FDCCloseQry('qryAdd');
        FDCClearQry('qryAdd');
        FDCSqlAdd('qryAdd', Nenhum, '', 'INSERT INTO produto');

        FDCSqlAdd('qryAdd', Nenhum, '', '(');

        FDCSqlAdd('qryAdd', Nenhum, '', 'id,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'emitenteId,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'codigo,');

        FDCSqlAdd('qryAdd', Nenhum, '', 'cean,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'cbarra,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'descricao,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'ncm,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'cest,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'cfop,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'unidade,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'valor,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'codigoanp,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'origem,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'csticms,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'cstpiscofins,');
        FDCSqlAdd('qryAdd', Nenhum, '', 'ativo');

        FDCSqlAdd('qryAdd', Nenhum, '', ')');

        FDCSqlAdd('qryAdd', Nenhum, '', 'VALUES');

        FDCSqlAdd('qryAdd', Nenhum, '', '(');

        FDCSqlAdd('qryAdd', inteiro, ultimoValorRegistro('produto', 'id'), '{},');
        FDCSqlAdd('qryAdd', Nenhum, '', '1,');
        FDCSqlAdd('qryAdd', inteiro, ultimoValorRegistro('produto', 'codigo'), '{},');

        FDCSqlAdd('qryAdd', Texto, edt_cean.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_cbarra.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_descricao.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_ncm.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_cest.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_cfop.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_unidade.text, '{},');
        FDCSqlAdd('qryAdd', Numerico, TN(edt_valor.text), '{},');
        FDCSqlAdd('qryAdd', Texto, edt_codigoanp.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_origem.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_csticms.text, '{},');
        FDCSqlAdd('qryAdd', Texto, edt_cstpiscofins.text, '{},');
        FDCSqlAdd('qryAdd', Nenhum, '', '1');

        FDCSqlAdd('qryAdd', Nenhum, '', ');');

        FDCGetQry('qryAdd').ExecSQL;

      end
      else
      begin

        FDCCloseQry('qryAdd');
        FDCClearQry('qryAdd');
        FDCSqlAdd('qryAdd', Nenhum, '', 'UPDATE produto');

        FDCSqlAdd('qryAdd', Nenhum, '', 'SET');

        FDCSqlAdd('qryAdd', Texto, edt_cean.text, 'cean={},');
        FDCSqlAdd('qryAdd', Texto, edt_cbarra.text, 'cbarra={},');
        FDCSqlAdd('qryAdd', Texto, edt_descricao.text, 'descricao={},');
        FDCSqlAdd('qryAdd', Texto, edt_ncm.text, 'ncm={},');
        FDCSqlAdd('qryAdd', Texto, edt_cest.text, 'cest={},');
        FDCSqlAdd('qryAdd', Texto, edt_cfop.text, 'cfop={},');
        FDCSqlAdd('qryAdd', Texto, edt_unidade.text, 'unidade={},');
        FDCSqlAdd('qryAdd', numerico, TN(edt_valor.text), 'valor={},');
        FDCSqlAdd('qryAdd', Texto, edt_codigoanp.text, 'codigoanp={},');
        FDCSqlAdd('qryAdd', Texto, edt_origem.text, 'origem={},');
        FDCSqlAdd('qryAdd', Texto, edt_csticms.text, 'csticms={},');
        FDCSqlAdd('qryAdd', Texto, edt_cstpiscofins.text, 'cstpiscofins={}');

        FDCSqlAdd('qryAdd', inteiro, TI(produtoId), 'where id = {} ');
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

procedure TfFormProdutosCadastro.prcCarregarRegistro;
begin

  FDCCreateQry('qryload');

  try

    try

      FDCCloseQry('qryload');
      FDCClearQry('qryload');
      FDCSqlAdd('qryload', Inteiro, TI(produtoId), 'SELECT * FROM produto WHERE id = {} and emitenteId = 1');
      FDCOpenQry('qryload');

      edt_codigo.text := FDCGetQry('qryload').FieldByName('codigo').Text;

      edt_Descricao.text := FDCGetQry('qryload').FieldByName('Descricao').Text;
      edt_cean.text := FDCGetQry('qryload').FieldByName('cean').Text;
      edt_cbarra.text := FDCGetQry('qryload').FieldByName('cbarra').Text;

      edt_ncm.text := FDCGetQry('qryload').FieldByName('ncm').Text;
      edt_cest.text := FDCGetQry('qryload').FieldByName('cest').Text;
      edt_cfop.text := FDCGetQry('qryload').FieldByName('cfop').Text;
      edt_Unidade.text := FDCGetQry('qryload').FieldByName('Unidade').Text;
      edt_Valor.Text := FDCGetQry('qryload').FieldByName('Valor').Text;
      edt_codigoAnp.text := FDCGetQry('qryload').FieldByName('codigoAnp').Text;
      edt_origem.text := FDCGetQry('qryload').FieldByName('origem').Text;
      edt_cstIcms.text := FDCGetQry('qryload').FieldByName('cstIcms').Text;
      edt_cstpiscofins.text := FDCGetQry('qryload').FieldByName('cstpiscofins').Text;

    except

    end;

  finally
    FDCCloseQry('qryload');
    FDCDestroyQry('qryload');
  end;

end;

initialization
  RegisterClass(TfFormProdutosCadastro);


finalization
  UnRegisterClass(TfFormProdutosCadastro);

end.

