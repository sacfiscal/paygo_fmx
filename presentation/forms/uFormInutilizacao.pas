unit uFormInutilizacao;

interface

uses
  uGlobal, DateUtils, uFuncoesGerais, uFuncoesDB, uFuncoesNuvemFiscalAPI,
  uFuncoesINI, uConfiguracoes, System.SysUtils, System.Types, System.UITypes,
  System.Classes, System.Variants, FMX.Types, FMX.Graphics, FMX.Controls,
  FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, FMX.Edit, FMX.Effects;

type
  TfFormInutilizacao = class(TfFormBase)
    Layout2: TLayout;
    ScrollContent: TVertScrollBox;
    layout_ano: TLayout;
    edt_ano: TEdit;
    lbl_ano: TText;
    layout_serie: TLayout;
    edt_serieNfce: TEdit;
    lbl_serieNfce: TText;
    layout_numeroInicial: TLayout;
    edt_numeroInicial: TEdit;
    lbl_numeroInicial: TText;
    layout_numeroFinal: TLayout;
    edt_numeroFinal: TEdit;
    lbl_numeroFinal: TText;
    layout_justificativa: TLayout;
    edt_justificativa: TEdit;
    lbl_justificativa: TText;
    PageToolBar: TToolBar;
    PageToolBarShadow: TShadowEffect;
    PageToolBarContent: TLayout;
    PageToolBarButtonLeft: TLayout;
    PageToolBarLeftImage: TImage;
    PageToolBarTitle: TText;
    PageToolBarButtonRight: TLayout;
    PageToolBarRightImage: TImage;
    buttonContent: TRectangle;
    ShadowEffect1: TShadowEffect;
    btnExcluir: TRectangle;
    lblLabelBotao: TText;
    ShadowEffect2: TShadowEffect;
    procedure btnExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageToolBarButtonLeftClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFormInutilizacao: TfFormInutilizacao;

implementation

{$R *.fmx}

procedure TfFormInutilizacao.btnExcluirClick(Sender: TObject);
var
  msg: string;
begin

  inherited;

  msg := 'Deseja realmente inutilizar a sequencia informada?';

  MessageDlg(msg, System.UITypes.TMsgDlgType.mtConfirmation, [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      case AResult of
        mrYES:
          begin

            nuvemFiscalInutilizarSequencia(TI(edt_ano.Text), TI(edt_numeroInicial.Text), TI(edt_numeroFinal.Text), edt_justificativa.Text);

            self.Close;
          end;
      end;
    end);

end;

procedure TfFormInutilizacao.FormShow(Sender: TObject);
begin

  if uGlobal.globalConfiguracoes = nil then
    uGlobal.globalConfiguracoes := TNFConfiguracoes.Create
  else
    uGlobal.globalConfiguracoes.refresh;

  useBackButton := false;

  inherited;

  edt_ano.Text := TS(YearOf(Now()));
  edt_serieNfce.text := TS(uGlobal.globalConfiguracoes.serieNfce);

  inherited;

  edt_numeroInicial.SetFocus;

end;

procedure TfFormInutilizacao.PageToolBarButtonLeftClick(Sender: TObject);
begin

  inherited;

  self.Close;

end;

initialization
  RegisterClass(TfFormInutilizacao);


finalization
  UnRegisterClass(TfFormInutilizacao);

end.

