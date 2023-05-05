unit uEmitente;

interface

uses

  uDataModule,
  uFrameItemListaPadraoDuasLinhas,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Controls.Presentation,
  FMX.Edit, FMX.ListBox, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TEmitente = class(TObject)
  private
    Fid: Integer;
    FrazaoSocial: string;
    FnomeFantasia: string;
    Fcnpjcpf: string;
  public

    constructor Create(emitenteId: integer); overload;
    constructor Create; overload;
    procedure refresh;

    {SET}

    function id(const Value: Integer): TEmitente; overload;
    function razaoSocial(const Value: String): TEmitente; overload;
    function nomeFantasia(const Value: String): TEmitente; overload;
    function cnpjCpf(const Value: String): TEmitente; overload;

    {GET}

    function id: Integer; overload;
    function razaoSocial: string; overload;
    function nomeFantasia: string; overload;
    function cnpjCpf: string; overload;

  end;

implementation

uses
  uFuncoesGerais,
  uFuncoesDB;

{Set}

function TEmitente.id(const Value: Integer): TEmitente;
begin
  self.Fid := value;
  Result := self;
end;

function TEmitente.razaoSocial(const Value: String): TEmitente;
begin
  self.FrazaoSocial := value;
  Result := self;
end;

function TEmitente.nomeFantasia(const Value: String): TEmitente;
begin
  self.FnomeFantasia := value;
  Result := self;
end;

function TEmitente.cnpjCpf(const Value: String): TEmitente;
begin
  self.Fcnpjcpf := value;
  Result := self;
end;


{Get}

function TEmitente.id: Integer;
begin
  result := self.Fid;
end;

function TEmitente.razaoSocial: string;
begin
  result := self.FrazaoSocial;
end;

function TEmitente.nomeFantasia: string;
begin
  result := self.FnomeFantasia;
end;

function TEmitente.cnpjCpf: string;
begin
  result := self.Fcnpjcpf;
end;

{Class}

constructor TEmitente.Create(emitenteId: integer);
const
  qryNome: string = 'qryObterEmitente';
begin

  self.Create;

  FDCCreateQry(qryNome);

  try

    try

      FDCCloseQry(qryNome);
      FDCClearQry(qryNome);
      FDCSqlAdd  (qryNome, Inteiro, emitenteId, 'SELECT * FROM emitente WHERE id = {}' );
      FDCOpenQry (qryNome);

      self
        .id(TI(FDCGetQry(qryNome).FieldByName('id').Value))
        .razaoSocial(TS(FDCGetQry(qryNome).FieldByName('razao_social').Value))
        .nomeFantasia(TS(FDCGetQry(qryNome).FieldByName('nome_fantasia').Value))
        .cnpjCpf(TS(FDCGetQry(qryNome).FieldByName('cnpj_cpf').Value));

    except
      on e:exception do
        raise Exception.Create(e.Message);
    end;

  finally
    FDCCloseQry(qryNome);
    FDCDestroyQry(qryNome);
  end;

end;

constructor TEmitente.Create;
begin
  inherited;
  // TODO -cMM: TEmitente.Create default body inserted
end;

procedure TEmitente.refresh;
const
  qryNome: string = 'qryObterEmitente';
begin

  inherited;

  FDCCreateQry(qryNome);

  try

    try

      FDCCloseQry(qryNome);
      FDCClearQry(qryNome);
      FDCSqlAdd  (qryNome, Inteiro, Self.id, 'SELECT * FROM emitente WHERE id = {}' );
      FDCOpenQry (qryNome);

      self
        .id(TI(FDCGetQry(qryNome).FieldByName('id').Value))
        .razaoSocial(TS(FDCGetQry(qryNome).FieldByName('razao_social').Value))
        .nomeFantasia(TS(FDCGetQry(qryNome).FieldByName('nome_fantasia').Value))
        .cnpjCpf(TS(FDCGetQry(qryNome).FieldByName('cnpj_cpf').Value));

    except
      on e:exception do
        raise Exception.Create(e.Message);
    end;

  finally
    FDCCloseQry(qryNome);
    FDCDestroyQry(qryNome);
  end;

end;

end.
