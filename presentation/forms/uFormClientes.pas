unit uFormClientes;

interface

uses
  uDataModule, uFrameItemListaClientes, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfFormClientes = class(TfFormBase)
    Layout1: TLayout;
    pesquisar: TRectangle;
    edtBusca: TEdit;
    Layout2: TLayout;
    listaPesquisa: TListBox;
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    qryPesquisa: TFDQuery;
    ListBoxItem1: TListBoxItem;
    fFrameItemListaClientes1: TfFrameItemListaClientes;
    ListBoxItem2: TListBoxItem;
    fFrameItemListaClientes2: TfFrameItemListaClientes;
    qryPesquisaid: TIntegerField;
    qryPesquisaemitenteId: TIntegerField;
    qryPesquisacnpj_cpf: TWideStringField;
    qryPesquisaidEstrangeiro: TWideStringField;
    qryPesquisarazao_social: TWideStringField;
    qryPesquisanome_fantasia: TWideStringField;
    qryPesquisalogradouro: TWideStringField;
    qryPesquisanumero: TWideStringField;
    qryPesquisacomplemento: TWideStringField;
    qryPesquisabairro: TWideStringField;
    qryPesquisacodigo_municipio: TWideStringField;
    qryPesquisamunicipio: TWideStringField;
    qryPesquisauf: TWideStringField;
    qryPesquisacep: TWideStringField;
    qryPesquisafone: TWideStringField;
    qryPesquisaindIeDest: TWideStringField;
    qryPesquisaie: TWideStringField;
    qryPesquisaemail: TWideStringField;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnIncluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
  private
    { Private declarations }

    idSelecionado: integer;
    frameSelecionado: TfFrameItemListaClientes;

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
  fFormClientes: TfFormClientes;

implementation

uses
  uFormClientesCadastro, uFuncoesGerais, uFuncoesDB, uFuncoesINI;
{$R *.fmx}

procedure TfFormClientes.FormActivate(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

end;

procedure TfFormClientes.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  qtdItensPesquisa := 0;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();
  ajustaBotao();

end;

procedure TfFormClientes.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaClientes(Sender).destinatarioID) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaClientes(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaClientes(Sender).destinatarioID;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaClientes(Sender);
    TfFrameItemListaClientes(Sender).setSelected(true);

  end;

  ajustaBotao();

end;

procedure TfFormClientes.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

procedure TfFormClientes.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  idSelecionado := 0;
  frameSelecionado := nil;

  prcCarregarPesquisa();

end;

procedure TfFormClientes.ajustaBotao;
begin

  if idSelecionado > 0 then
  begin
    lblLabelBotao.Text := 'Editar';
  end
  else
  begin
    lblLabelBotao.Text := 'Incluir';
  end;

end;

procedure TfFormClientes.executarBusca(valor: string);
begin

  self.qryPesquisa.Close;
  self.qryPesquisa.SQL.Clear;
  self.qryPesquisa.SQL.Add('select destinatario.*');
  self.qryPesquisa.SQL.Add('  from destinatario');
  self.qryPesquisa.SQL.Add(' where (1=1)');

  if Trim(valor) <> '' then
    self.qryPesquisa.SQL.Add('   and destinatario.razao_social like ''%'' || ' + QuotedStr(valor) + ' || ''%'' ');

  self.qryPesquisa.Open();

end;

procedure TfFormClientes.prcCarregarPesquisa;
var
  MyFrame: TfFrameItemListaClientes;
  i: integer;
  item: TListBoxItem;
  frame: TfFrameItemListaClientes;
  strFiltro: string;
begin

  inherited;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaClientes(self.FindComponent('frame_' + IntToStr(i))).DisposeOf;
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
//    item.Hint := TS(qryPesquisa.FieldByName('id').value);
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 2;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaClientes.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.destinatarioID := TI(qryPesquisa.FieldByName('id').value);
    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'Código: ' + TS(qryPesquisa.FieldByName('id').value).PadLeft(5, '0');
    frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('razao_social').value);
    frame.lblLinha3.Text := 'CPF/CNPJ: ' + TS(qryPesquisa.FieldByName('cnpj_cpf').value);
    frame.lblLinha4.Text := 'Contato: ' + TS(qryPesquisa.FieldByName('fone').value);
    frame.lblLinha5.Text := 'E-mail: ' + TS(qryPesquisa.FieldByName('email').value);
    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

end;

procedure TfFormClientes.btnIncluirClick(Sender: TObject);
begin

  inherited;

  ApplicationParmTemp.AddParmV('destinatarioid', TI(idSelecionado));

  if Assigned(fFormClientesCadastro) then
    FreeAndNil(fFormClientesCadastro);

  if not Assigned(fFormClientesCadastro) then
    fFormClientesCadastro := TfFormClientesCadastro.Create(Application);

  fFormClientesCadastro.Show;

end;

initialization
  RegisterClass(TfFormClientes);


finalization
  UnRegisterClass(TfFormClientes);

end.

