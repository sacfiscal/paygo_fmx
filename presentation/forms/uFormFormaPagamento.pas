unit uFormFormaPagamento;

interface

uses
  uDataModule, uFrameItemListaPadraoDuasLinhas, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfFormFormaPagamento = class(TfFormBase)
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    Layout1: TLayout;
    Layout2: TLayout;
    listaPesquisa: TListBox;
    qryPesquisa: TFDQuery;
    pesquisar: TRectangle;
    edtBusca: TEdit;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    fFrameItemListaPadraoDuasLinhas1: TfFrameItemListaPadraoDuasLinhas;
    fFrameItemListaPadraoDuasLinhas2: TfFrameItemListaPadraoDuasLinhas;
    procedure PageToolBarButtonRightClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
  private

    { Private declarations }

    idSelecionado: integer;
    frameSelecionado: TfFrameItemListaPadraoDuasLinhas;

    procedure FrameClick(Sender: TObject);

  public

    { Public declarations }

    arrayItensPesquisa: array[0..9999] of TListBoxItem;
    qtdItensPesquisa: Integer;

    procedure prcCarregarPesquisa();
    procedure executarBusca(valor: string);

  end;

var
  fFormFormaPagamento: TfFormFormaPagamento;

implementation

uses
  uFuncoesGerais, uFuncoesDB, uFuncoesINI;

{$R *.fmx}

{ TfFormFormaPagamento }

procedure TfFormFormaPagamento.FormShow(Sender: TObject);
begin

  useBackButton := false;

  inherited;

  qtdItensPesquisa := 0;
  prcCarregarPesquisa();

end;

procedure TfFormFormaPagamento.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  Self.Close;

end;

procedure TfFormFormaPagamento.PageToolBarButtonRightClick(Sender: TObject);
begin

  inherited;

  prcCarregarPesquisa();

end;

procedure TfFormFormaPagamento.executarBusca(valor: string);
begin

  self.qryPesquisa.close;
  self.qryPesquisa.SQL.Clear;
  self.qryPesquisa.SQL.Add('select formaPagto.*');
  self.qryPesquisa.SQL.Add('  from formaPagto');
  self.qryPesquisa.SQL.Add(' where (1=1)');

  if Trim(valor) <> '' then
    self.qryPesquisa.SQL.Add('   and formaPagto.descricao like ''%'' || ' + QuotedStr(valor) + ' || ''%'' ');

  self.qryPesquisa.Open();

end;

procedure TfFormFormaPagamento.prcCarregarPesquisa;
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
    frame.listItemName := item.Name;
    frame.setSelected(false);

    frame.lblLinha1.Text := 'C�digo: ' + TS(qryPesquisa.FieldByName('id').value).PadLeft(5, '0');
    frame.lblLinha2.Text := TS(qryPesquisa.FieldByName('descricao').value);
    frame.OnClick := FrameClick;

    listaPesquisa.AddObject(item);

    self.qryPesquisa.Next;

  end;

  if frame <> nil then
    frame.Line1.Visible := false;

end;

procedure TfFormFormaPagamento.FrameClick(Sender: TObject);
begin

  if (idSelecionado = TfFrameItemListaPadraoDuasLinhas(Sender).itemId) then
  begin

    idSelecionado := 0;
    frameSelecionado := nil;
    TfFrameItemListaPadraoDuasLinhas(Sender).setSelected(false);

  end
  else
  begin

    idSelecionado := TfFrameItemListaPadraoDuasLinhas(Sender).itemId;

    if frameSelecionado <> nil then
      frameSelecionado.setSelected(false);

    frameSelecionado := TfFrameItemListaPadraoDuasLinhas(Sender);
    TfFrameItemListaPadraoDuasLinhas(Sender).setSelected(true);

  end;

end;

initialization
  RegisterClass(TfFormFormaPagamento);


finalization
  UnRegisterClass(TfFormFormaPagamento);

end.

