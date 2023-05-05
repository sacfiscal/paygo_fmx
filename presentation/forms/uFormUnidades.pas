unit uFormUnidades;

interface

uses
  uDataModule, uFrameItemListaPadraoDuasLinhas, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors,
  Data.Bind.EngExt, FMX.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, FMX.Edit, FMX.ListBox;

type
  TfFormUnidades = class(TfFormBase)
    qryPesquisa: TFDQuery;
    Layout1: TLayout;
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
    pesquisar: TRectangle;
    edtBusca: TEdit;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnIncluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    fFrameItemListaPadraoDuasLinhas1: TfFrameItemListaPadraoDuasLinhas;
    fFrameItemListaPadraoDuasLinhas2: TfFrameItemListaPadraoDuasLinhas;
    procedure btnIncluirClick(Sender: TObject);
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
  private

    { Private declarations }

    idSelecionado: integer;
    unidade: string;
    frameSelecionado: TfFrameItemListaPadraoDuasLinhas;

    procedure FrameClick(Sender: TObject);

  public

    { Public declarations }

    produtoId: integer;

    arrayItensPesquisa: array[0..9999] of TListBoxItem;
    qtdItensPesquisa: Integer;

    procedure prcCarregarPesquisa();
    procedure executarBusca(valor: string);

  end;

var
  fFormUnidades: TfFormUnidades;

implementation

uses
  uFuncoesGerais, uFuncoesDB, uFuncoesINI;

{$R *.fmx}

procedure TfFormUnidades.btnIncluirClick(Sender: TObject);
begin

  inherited;

  if TI(produtoId) > 0 then
  begin

//    FDCCreateQry('qryAddProduto');
//
//    try
//
//      try
//
//        FDCCloseQry('qryAddProduto');
//        FDCClearQry('qryAddProduto');
//
//        FDCSqlAdd('qryAddProduto',  Nenhum,         '', 'update produto');
//        FDCSqlAdd('qryAddProduto',   texto,    unidade, '   set unidade = {}');
//        FDCSqlAdd('qryAddProduto', Inteiro,  produtoId, ' where id = {}');
//        FDCGetQry('qryAddProduto').ExecSQL;
//
//      except
//        on e: exception do
//          raise Exception.Create(e.Message);
//      end;
//
//    finally
//      FDCCloseQry('qryAddProduto');
//      FDCDestroyQry('qryAddProduto');
//    end;

    ApplicationParmTemp.AddParmV('unidade', ts(unidade));

    self.Close;

  end;

end;

procedure TfFormUnidades.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  qtdItensPesquisa := 0;
  prcCarregarPesquisa();

  if TI(produtoId) > 0 then
    buttonContent.Visible := True
  else
    buttonContent.Visible := False;

end;

procedure TfFormUnidades.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  Self.Close;

end;

procedure TfFormUnidades.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  prcCarregarPesquisa();

end;

procedure TfFormUnidades.executarBusca(valor: string);
begin

  self.qryPesquisa.close;
  self.qryPesquisa.SQL.Clear;
  self.qryPesquisa.SQL.Add('select unidadeMedida.*');
  self.qryPesquisa.SQL.Add('  from unidadeMedida');
  self.qryPesquisa.SQL.Add(' where (1=1)');

  if Trim(valor) <> '' then
    self.qryPesquisa.SQL.Add('   and unidadeMedida.unidade like ''%'' || ' + QuotedStr(valor) + ' || ''%'' ');

  self.qryPesquisa.Open();

end;

procedure TfFormUnidades.prcCarregarPesquisa;
var
  MyFrame: TfFrameItemListaPadraoDuasLinhas;
  i: Integer;
  item: TListBoxItem;
  frame: TfFrameItemListaPadraoDuasLinhas;
  strFiltro: string;
begin

  inherited;

  if self.qtdItensPesquisa > 0 then
  begin

    for i := 1 to self.qtdItensPesquisa do
    begin
      if listaPesquisa.FindComponent('item_' + IntToStr(i)) <> nil then
      begin
        TfFrameItemListaPadraoDuasLinhas(self.FindComponent('frame_' + IntToStr(i))).DisposeOf;
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
    item.Selectable := False;
    item.Height := 80;
    item.Tag := i;
    item.TagString := 'item_tag_' + IntToStr(i);
    item.Margins.Bottom := 1;
    item.Name := 'item_' + IntToStr(i);
    item.Text := '';

    frame := TfFrameItemListaPadraoDuasLinhas.Create(item);
    frame.Parent := item;
    frame.Align := TAlignLayout.Client;
    frame.HitTest := true;
    frame.content.Fill.Color := TAlphaColorRec.Null;
    frame.Name := 'frame_' + IntToStr(i);

    frame.itemId := TI(qryPesquisa.FieldByName('id').value);
    frame.valorString := TS(qryPesquisa.FieldByName('unidade').value);
    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'Código: ' + TS(qryPesquisa.FieldByName('id').value).PadLeft(5, '0');
    frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('unidade').value);
    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

  if frame <> nil then
    frame.Line1.Visible := false;

end;

procedure TfFormUnidades.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaPadraoDuasLinhas(Sender).itemId) then
  begin

    idSelecionado := 0;
    unidade := '';
    frameSelecionado := nil;
    TfFrameItemListaPadraoDuasLinhas(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaPadraoDuasLinhas(Sender).itemId;
    unidade := TfFrameItemListaPadraoDuasLinhas(Sender).valorString;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaPadraoDuasLinhas(Sender);
    TfFrameItemListaPadraoDuasLinhas(Sender).setSelected(true);

  end;

end;

initialization
  RegisterClass(TfFormUnidades);


finalization
  UnRegisterClass(TfFormUnidades);

end.

