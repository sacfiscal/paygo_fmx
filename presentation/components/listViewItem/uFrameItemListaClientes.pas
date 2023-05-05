unit uFrameItemListaClientes;

interface

uses

  DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Effects;

type
  TfFrameItemListaClientes = class(TFrame)
    content: TRectangle;
    layer: TRectangle;
    lblLinha2: TLabel;
    lblLinha1: TLabel;
    lblLinha3: TLabel;
    lblLinha4: TLabel;
    lblLinha5: TLabel;
    ShadowEffect1: TShadowEffect;
  private

    { Private declarations }

  public

    { Public declarations }

    destinatarioId : integer;
    destinatarioCPF: string;
    listItemName: string;

    procedure setSelected(value:boolean);

  end;

implementation

uses
  System.UIConsts,
  uFuncoesGerais;

{$R *.fmx}


procedure TfFrameItemListaClientes.setSelected(value: boolean);
begin

  if value then
    content.Fill.Color := StringToAlphaColor('#FFEFDA70')
  else
    content.Fill.Color := StringToAlphaColor('#B4FFFFFF');

end;

end.
