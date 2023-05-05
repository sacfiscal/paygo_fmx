unit uFormBase;

interface

uses
  uDataModule, uApplicationParamList, uFuncoesGerais, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.FMXUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageXML, FireDAC.Phys.SQLite, FireDAC.Stan.StorageBin,
  FireDAC.Comp.UI, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet, FMX.Objects, FMX.Layouts;

type
  {Tipo para controle do status do Keyboard}
  TKeyboardStatus = (kbsShow, kbsHide);

  TfFormBase = class(TForm)
    formBackground: TImage;
    formContent: TLayout;
    formOverlay: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
  private
    { Private declarations }

    {Variável para manter o status atual do Keyboard}
    formKeyboardStatus: TKeyboardStatus;

    {Função para ajuste inicial dos componentes do form}
    procedure prcAjustaComponentes;

  public
    { Public declarations }

    {Variável para receber parâmetros do form que invocou a tela}
    FormParmLocal: TApplicationParamList;

    {Variável que Ativa ou Desativa o uso do BackButton}
    useBackButton: Boolean;

    {Função para conrtrolar o overlay}
    function Overlay(value: Boolean): Boolean;

    {Função para aplicar máscaras simples aos edits}
    function AplicarMascaraSimples(aMask, aValue: string): string;

  end;

var
  fFormBase: TfFormBase;

implementation
{$R *.fmx}

function TfFormBase.Overlay(value: Boolean): Boolean;
begin

  {
    Função para setar o overlay
    Esta função ativa ou desativa o elemento de
    overlay, facilitando o efeito de escurecer por traz
    de alguns elementos
  }

  formOverlay.Visible := value;

end;

procedure TfFormBase.FormCreate(Sender: TObject);
begin

  inherited;

    {
    Instancia Objeto FormParmLocal
    Este elemento serve para troca de parâmetros de forma fácil
    entre as telas, neste código ele Recebe parametros de
    ApplicationParmTemp que é enviado do form que invoca
    o novo form
  }

  FormParmLocal := TApplicationParamList.Create();
  FormParmLocal.Text := ApplicationParmTemp.Text;

  useBackButton := True;
  prcAjustaComponentes();

  formKeyboardStatus := kbsHide;

end;

procedure TfFormBase.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin

  {
    Trocar o ENTER pelo TAB
  }

  if Key = vkReturn then
  begin
    Key := vkTab;
    KeyDown(Key, KeyChar, Shift);
  end;

end;

procedure TfFormBase.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin

  {
    Controle para inibir o backButton
    Se definido como false, ele ignora o botão backbutton do aparelho
    no caso do kayboard estar em hide
  }

  if formKeyboardStatus = kbsHide then
    if useBackButton = false then
      if Key = vkHardwareBack then
      begin
        Key := 0;
      end;

end;

procedure TfFormBase.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin

  {
    Mantem um status do kayboard no form,
    informando que ele foi ocultado
  }

  formKeyboardStatus := kbsHide;

end;

procedure TfFormBase.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin

  {
    Mantem um status do kayboard no form,
    informando que ele foi apresentado
  }

  formKeyboardStatus := kbsShow;

end;

procedure TfFormBase.prcAjustaComponentes;
var
  i: Integer;
begin

  {
    Ajuste das conexões das querys para evitar
    falhas no link com o DataModule
  }

  for i := 0 to pred(self.ComponentCount) do
  begin
    if (self.Components[i] is TFDQuery) then
    begin
      TFDQuery(self.Components[i]).Connection := DM.PayGODB;
    end;
  end;

end;

function TfFormBase.AplicarMascaraSimples(aMask, aValue: string): string;
var
  M, V: Integer;
  Texto: string;
begin

  {
    Aplica uma máscara simples no Edit
    Ex:
      Cpf: ###.###.###-##
      Cnpj: ##.###.###/####-##
  }

  Result := '';
  Texto := '';
  aMask := aMask.ToUpper;
  for V := 0 to aValue.Length - 1 do
    if aValue.Chars[V] in ['0'..'9'] then
      Texto := Texto + aValue.Chars[V];
  M := 0;
  V := 0;
  while (V < Texto.Length) and (M < aMask.Length) do
  begin
    while aMask.Chars[M] <> '#' do
    begin
      Result := Result + aMask.Chars[M];
      Inc(M);
    end;
    Result := Result + Texto.Chars[V];
    Inc(M);
    Inc(V);
  end;

end;

initialization
  RegisterClass(TfFormBase);


finalization
  UnRegisterClass(TfFormBase);

end.

