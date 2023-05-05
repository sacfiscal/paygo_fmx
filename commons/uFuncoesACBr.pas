unit uFuncoesACBr;

interface

uses
  uDataModule, uGlobal, uConfiguracoes, System.SysUtils, System.Types,
  System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uFormBase,
  FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, ACBrBase, ACBrPosPrinter;

function PosPrinterModeloToInt(Modelo: TACBrPosPrinterModelo): Integer;
function IntToPosPrinterModelo(IntValor: Integer): TACBrPosPrinterModelo;
function PaginaCodigoToInt(Modelo: TACBrPosPaginaCodigo): Integer;
function IntToPosPaginaCodigo(IntValor: Integer): TACBrPosPaginaCodigo;

implementation

function PosPrinterModeloToInt(Modelo: TACBrPosPrinterModelo): Integer;
begin
  Result := Ord(Modelo);
end;

function IntToPosPrinterModelo(IntValor: Integer): TACBrPosPrinterModelo;
begin
  Result := TACBrPosPrinterModelo(IntValor);
end;

function PaginaCodigoToInt(Modelo: TACBrPosPaginaCodigo): Integer;
begin
  Result := Ord(Modelo);
end;

function IntToPosPaginaCodigo(IntValor: Integer): TACBrPosPaginaCodigo;
begin
  Result := TACBrPosPaginaCodigo(IntValor);
end;

end.
