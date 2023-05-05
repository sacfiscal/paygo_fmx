unit uFormVendas;

interface

uses
  uFormInutilizacao, System.UIConsts, uDataModule, uGlobal,
  uframeItemListaVendas, System.SysUtils, System.Types, System.UITypes,
  System.Classes, System.Variants, FMX.Types, FMX.Graphics, FMX.Controls,
  FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts,
  FMX.Effects, FMX.Controls.Presentation, FMX.ListBox, FMX.Edit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfFormVendas = class(TfFormBase)
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
    fFrameItemListaVendas1: TfFrameItemListaVendas;
    fFrameItemListaVendas2: TfFrameItemListaVendas;
    qryPesquisa: TFDQuery;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnIncluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    Layout3: TLayout;
    Layout20: TLayout;
    Text15: TText;
    edtTipoCadastro: TComboBox;
    btnExcluir: TRectangle;
    Text1: TText;
    ShadowEffect3: TShadowEffect;
    procedure btnExcluirClick(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
    procedure edtTipoCadastroChange(Sender: TObject);
  private

    { Private declarations }

    idSelecionado: integer;
    idSelecionadoAutorizado: boolean;

    frameSelecionado: TfFrameItemListaVendas;

    procedure FrameClick(Sender: TObject);

  public

    { Public declarations }

    arrayItensPesquisa: array[0..9999] of TListBoxItem;
    qtdItensPesquisa: integer;

    procedure prcCarregarPesquisa();
    procedure executarBusca(valor: string);

    procedure ajustaBotao();

  end;

var
  fFormVendas: TfFormVendas;

implementation

uses
  uFormVendasCadastro, uFuncoesGerais, uFuncoesDB, uFuncoesINI;


{$R *.fmx}

procedure TfFormVendas.FormActivate(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

end;

procedure TfFormVendas.FormShow(Sender: TObject);
var
  i: integer;
begin

  useBackButton := false;

  inherited;

  qtdItensPesquisa := 0;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

  for i := 0 to edtTipoCadastro.Count - 1 do
  begin
    edtTipoCadastro.ListItems[i].FontColor := TAlphaColors.White;
    edtTipoCadastro.ListItems[i].StyledSettings := edtTipoCadastro.ListItems[i].StyledSettings - [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.FontColor];
  end;

  edtTipoCadastro.ItemIndex := 0;

end;

procedure TfFormVendas.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaVendas(Sender).vendaId) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaVendas(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaVendas(Sender).vendaId;
    idSelecionadoAutorizado := TfFrameItemListaVendas(Sender).autorizado;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaVendas(Sender);
    TfFrameItemListaVendas(Sender).setSelected(true);

  end;

  ajustaBotao();

end;

procedure TfFormVendas.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormVendas.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();

end;

procedure TfFormVendas.ajustaBotao;
begin

  if idSelecionado > 0 then
  begin

    if idSelecionadoAutorizado then
      lblLabelBotao.Text := 'Visualizar'
    else
      lblLabelBotao.Text := 'Editar';

  end
  else
  begin
    lblLabelBotao.Text := 'Incluir';
  end;

end;

procedure TfFormVendas.btnExcluirClick(Sender: TObject);
var
  msg: string;
begin

  inherited;

  msg := 'Deseja inutilizar uma sequencia de NFCe?';

  MessageDlg(msg, System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      case AResult of
        mrYES:
          begin

            if Assigned(fFormInutilizacao) then
              FreeAndNil(fFormInutilizacao);

            if not Assigned(fFormInutilizacao) then
              fFormInutilizacao := TfFormInutilizacao.Create(Application);

            fFormInutilizacao.Show;

          end;
      end;
    end);

end;

procedure TfFormVendas.executarBusca(valor: string);
begin

  self.qryPesquisa.Close;
  self.qryPesquisa.SQL.Clear;

  self.qryPesquisa.SQL.Add('select documentoNfce.*,');
  self.qryPesquisa.SQL.Add('       destinatario.*');
  self.qryPesquisa.SQL.Add('  from documentoNfce');
  self.qryPesquisa.SQL.Add('  left outer join destinatario on ( destinatario.id = documentoNfce.destinatarioId  )');

  self.qryPesquisa.SQL.Add('   WHERE (1=1) ');

  case TI(edtTipoCadastro.ItemIndex) of
    0:
      self.qryPesquisa.SQL.Add('   AND ( ( nuvemFiscal_status IS NULL ) OR ( nuvemFiscal_status <> 100 and nuvemFiscal_status <> 101 and nuvemFiscal_status <> 135 ) ) ');
    1:
      self.qryPesquisa.SQL.Add('   AND ( nuvemFiscal_status = 100 ) ');
    2:
      self.qryPesquisa.SQL.Add('   AND ( nuvemFiscal_status = 101 or nuvemFiscal_status = 135 ) ');
  end;

  if Trim(valor) <> '' then
    self.qryPesquisa.SQL.Add('   and destinatario.razao_social like ''%'' || ' + QuotedStr(valor) + ' || ''%'' ');

  self.qryPesquisa.SQL.Add('order by documentoNfce.numero desc');

  self.qryPesquisa.Open();

end;

procedure TfFormVendas.prcCarregarPesquisa;
var
  MyFrame: TfFrameItemListaVendas;
  i: integer;
  item: TListBoxItem;
  frame: TfFrameItemListaVendas;
  strFiltro: string;
begin

  inherited;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaVendas(self.FindComponent('frame_' + IntToStr(i))).DisposeOf;
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
    item.Selectable := true;
    item.Height := 132;
    item.Tag := i;
    item.Hint := TS(qryPesquisa.FieldByName('id').value);
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 2;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaVendas.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.vendaId := TI(qryPesquisa.FieldByName('id').value);

    if Trim(TS(qryPesquisa.FieldByName('nuvemFiscal_status').value)) = '100' then
      frame.autorizado := true
    else
      frame.autorizado := false;

    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'NF.: ' + TS(qryPesquisa.FieldByName('numero').value).PadLeft(9, '0');

    if ((Trim(TS(qryPesquisa.FieldByName('nuvemFiscal_status').value)) = '101') or (Trim(TS(qryPesquisa.FieldByName('nuvemFiscal_status').value)) = '135')) then
    begin
      frame.lblLinha1_1.Text := 'Status: CANCELADO';
      frame.lblLinha1_1.TextSettings.FontColor := TAlphaColors.Tomato;
    end
    else if Trim(TS(qryPesquisa.FieldByName('protocoloAutorizacao').value)) = '' then
    begin
      frame.lblLinha1_1.Text := 'Status: NÃO AUTORIZADO';
      frame.lblLinha1_1.TextSettings.FontColor := TAlphaColors.Tomato;
    end
    else
    begin
      frame.lblLinha1_1.Text := 'Status: AUTORIZADO';
      frame.lblLinha1_1.TextSettings.FontColor := TAlphaColors.Green;
    end;

    frame.lblLinha1_2.Text := 'Data: ' + FormatDateTime('dd/mm/yyyyy hh:MM:ss', qryPesquisa.FieldByName('dhEmissao').value);

    if Trim(TS(qryPesquisa.FieldByName('cnpjcpf').value)) <> '' then
    begin
      frame.lblLinha2.Text := 'CLIENTE BALCÃO';
      frame.lblLinha3.Text := 'CPF/CNPJ: ' + formatCPFCNPJ(TS(qryPesquisa.FieldByName('cnpjcpf').value));
    end
    else
    begin
      if Trim(TS(qryPesquisa.FieldByName('destinatarioId').value)) <> '' then
      begin
        frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('razao_social').value);
        frame.lblLinha3.Text := 'CPF/CNPJ: ' + formatCPFCNPJ(TS(qryPesquisa.FieldByName('cnpj_cpf').value));
      end
      else
      begin
        frame.lblLinha2.Text := 'NÃO IDENTIFICADO';
        frame.lblLinha3.Text := 'Cliente não identificado';
      end;
    end;

    frame.lblLinha4.Text := 'Valor: ' + FormatFloat('#########,0.00', TN(qryPesquisa.FieldByName('valorTotal').value));
    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

end;

procedure TfFormVendas.btnIncluirClick(Sender: TObject);
begin

  inherited;

  ApplicationParmTemp.AddParmV('vendaId', TI(idSelecionado));

  if Assigned(fFormVendasCadastro) then
    FreeAndNil(fFormVendasCadastro);

  if not Assigned(fFormVendasCadastro) then
    fFormVendasCadastro := TfFormVendasCadastro.Create(Application);

  fFormVendasCadastro.Show;

end;

procedure TfFormVendas.edtTipoCadastroChange(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();

end;

initialization
  RegisterClass(TfFormVendas);


finalization
  UnRegisterClass(TfFormVendas);

end.

