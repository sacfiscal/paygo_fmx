unit uFrameItemListaVendas;

interface

uses

  DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Effects;

type
  TfFrameItemListaVendas = class(TFrame)
    content: TRectangle;
    layer: TRectangle;
    lblLinha2: TLabel;
    lblLinha1: TLabel;
    lblLinha3: TLabel;
    lblLinha4: TLabel;
    ShadowEffect1: TShadowEffect;
    lblLinha1_1: TLabel;
    lblLinha1_2: TLabel;
    procedure FrameClick(Sender: TObject);
  private

    { Private declarations }

  public

    { Public declarations }

    vendaId : integer;
    autorizado: Boolean;

    listItemName: string;

    procedure setSelected(value:boolean);

  end;

implementation


uses
  System.UIConsts,
  uFuncoesGerais;

{$R *.fmx}

procedure TfFrameItemListaVendas.FrameClick(Sender: TObject);
begin

  ShowMessage('A');

end;

procedure TfFrameItemListaVendas.setSelected(value: boolean);
begin

  if value then
    content.Fill.Color := StringToAlphaColor('#FFEFDA70')
  else
    content.Fill.Color := StringToAlphaColor('#B4FFFFFF');

end;


end.
