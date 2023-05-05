unit uFrameItemListaPadraoDuasLinhas;

interface

uses

  DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TfFrameItemListaPadraoDuasLinhas = class(TFrame)
    lblLinha2: TLabel;
    lblLinha1: TLabel;
    content: TRectangle;
    layer: TRectangle;
    Line1: TLine;
  private

    { Private declarations }

  public

    { Public declarations }

    itemId : integer;
    valorString : string;
    listItemName: string;

    procedure setSelected(value:boolean);

  end;

implementation


uses
  System.UIConsts,
  uFuncoesGerais;

{$R *.fmx}

procedure TfFrameItemListaPadraoDuasLinhas.setSelected(value: boolean);
begin

  if value then
    content.Fill.Color := StringToAlphaColor('#FFEFDA70')
  else
    content.Fill.Color := StringToAlphaColor('#B4FFFFFF');

end;

end.
