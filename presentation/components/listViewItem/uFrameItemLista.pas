unit uFrameItemLista;

interface

uses

  DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TfFrameItemLista = class(TFrame)
    lblLinha2: TLabel;
    lblLinha1: TLabel;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Line1: TLine;
  private

    { Private declarations }

  public

    { Public declarations }

  end;

implementation

uses
  uFuncoesGerais;

{$R *.fmx}


end.
