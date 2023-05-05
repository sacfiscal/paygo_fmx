unit uFrameItemListaIncluirProdutos;

interface

uses

  DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Effects;

type
  TfFrameItemListaIncluirProdutos = class(TFrame)
    content: TRectangle;
    left_layer: TRectangle;
    lblLinha2: TLabel;
    lblLinha1: TLabel;
    lblLinha3: TLabel;
    lblLinha4: TLabel;
    ShadowEffect1: TShadowEffect;
    left: TLayout;
    right: TLayout;
    right_top: TLayout;
    right_bottom: TLayout;
    lblQtdeItemValor: TLabel;
    gridBotoes: TGridPanelLayout;
    ButtonPlus: TLayout;
    PageToolBarRightImage: TImage;
    ButtonMinus: TLayout;
    Image1: TImage;
    Line1: TLine;
    Layout1: TLayout;
    Label1: TLabel;
    procedure FrameClick(Sender: TObject);
    procedure ButtonPlusClick(Sender: TObject);
    procedure ButtonMinusClick(Sender: TObject);
  private

    { Private declarations }

  public

    { Public declarations }

    vendaID: integer;
    produtoId : integer;
    listItemName: string;

    qtdItem: integer;
    vlrItem: Currency;

    procedure setSelected(value:boolean);

  end;

implementation


uses
  System.UIConsts,
  uFuncoesGerais;

{$R *.fmx}

procedure TfFrameItemListaIncluirProdutos.FrameClick(Sender: TObject);
begin

  ShowMessage('A');

end;

procedure TfFrameItemListaIncluirProdutos.ButtonMinusClick(Sender: TObject);
begin

  if qtdItem>0 then
    qtdItem := qtdItem - 1;
  
  lblQtdeItemValor.Text := FormatFloat( '#########,0.00####', qtdItem);

end;

procedure TfFrameItemListaIncluirProdutos.ButtonPlusClick(
  Sender: TObject);
begin

  qtdItem := qtdItem + 1;
  lblQtdeItemValor.Text := FormatFloat( '#########,0.00####', qtdItem);

end;

procedure TfFrameItemListaIncluirProdutos.setSelected(value: boolean);
begin

  if value then
    content.Fill.Color := StringToAlphaColor('#FFEFDA70')
  else
    content.Fill.Color := StringToAlphaColor('#B4FFFFFF');

end;


end.
