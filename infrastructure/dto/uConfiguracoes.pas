unit uConfiguracoes;

interface

uses

  uDataModule,
  uEmitente,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFormBase, FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Controls.Presentation,
  FMX.Edit, FMX.ListBox, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  {
    Ambiente de emissão da NFCe
    Manual de Integração TAG<tpAmb>
      1=Produção
      2=Homologação
  }

  TNFConfiguracoesAmbiente = ( TNFProducao, TNFHomologacao );

  TNFConfiguracoes = class(TObject)
  private

    Fid: integer;
    FemitenteId: integer;
    FserieNfce: integer;
    FultimaNfce: integer;
    FarquivoCertificado: string;
    Fambiente: string;
    FEmitente: TEmitente;

  public

    constructor Create;
    procedure refresh;
    procedure save;

    {SET}

    function id(const Value: Integer): TNFConfiguracoes; overload;
    function emitenteId(const Value: Integer): TNFConfiguracoes; overload;
    function serieNfce(const Value: Integer): TNFConfiguracoes; overload;
    function ultimaNfce(const Value: Integer): TNFConfiguracoes; overload;
    function arquivoCertificado(const Value: string): TNFConfiguracoes; overload;
    function ambiente(const Value: string): TNFConfiguracoes; overload;

    {GET}

    function id: Integer; overload;
    function emitenteId: Integer; overload;
    function serieNfce: Integer; overload;
    function ultimaNfce: Integer; overload;
    function proximaNfce: Integer;
    function arquivoCertificado: string; overload;
    function ambiente: string; overload;

    function emitente: TEmitente;

  end;

  function strToTNFConfiguracoesAmbiente(value: string):TNFConfiguracoesAmbiente;

  function TNFConfiguracoesAmbienteToStr(value: TNFConfiguracoesAmbiente):String;

implementation

uses
  uFuncoesGerais,
  uFuncoesDB;

function strToTNFConfiguracoesAmbiente(value: string):TNFConfiguracoesAmbiente;
begin
  if Trim(value)='1' then
   Result := TNFConfiguracoesAmbiente.TNFProducao
  else
   Result := TNFConfiguracoesAmbiente.TNFHomologacao;
end;

function TNFConfiguracoesAmbienteToStr(value: TNFConfiguracoesAmbiente):String;
begin
  case value of
    TNFConfiguracoesAmbiente.TNFProducao: result := '1';
    TNFConfiguracoesAmbiente.TNFHomologacao: result := '2';
  else
    result := '2';
  end;
end;

function TNFConfiguracoes.id(const Value: Integer): TNFConfiguracoes;
begin
   self.Fid := Value;
   Result := self;
end;

function TNFConfiguracoes.emitenteId(const Value: Integer): TNFConfiguracoes;
begin

   self.FemitenteId := Value;

   if self.FEmitente<>nil then
     FreeAndNil(self.FEmitente);

   self.FEmitente := TEmitente.Create(self.FemitenteId);

   Result := self;

end;

function TNFConfiguracoes.serieNfce(const Value: Integer): TNFConfiguracoes;
begin
   self.FserieNfce := Value;
   Result := self;
end;

function TNFConfiguracoes.ultimaNfce(const Value: Integer): TNFConfiguracoes;
begin
   self.FultimaNfce := Value;
   Result := self;
end;

function TNFConfiguracoes.arquivoCertificado(const Value: string): TNFConfiguracoes;
begin
   self.FarquivoCertificado := Value;
   Result := self;
end;

function TNFConfiguracoes.ambiente(const Value: string): TNFConfiguracoes;
begin

  {
    Ambiente de emissão da NFCe
    Manual de Integração TAG<tpAmb>
      1=Produção
      2=Homologação
  }

  if TI(value)=0 then
  begin

    {Se informado "ZERO" ou "NULO", adotar homologação como padrão}

    self.Fambiente := '2';

  end
  else
    self.Fambiente := Value;

  Result := self;

end;

function TNFConfiguracoes.id: Integer;
begin
  result := self.Fid;
end;

function TNFConfiguracoes.emitenteId: Integer;
begin
  result := self.FemitenteId;
end;

function TNFConfiguracoes.serieNfce: Integer;
begin
  result := self.FserieNfce;
end;

function TNFConfiguracoes.ultimaNfce: Integer;
begin
  result := self.FultimaNfce;
end;

function TNFConfiguracoes.proximaNfce: Integer;
var
  ultimoNFCe: integer;
begin

  ultimoNFCe := ultimoValorRegistro('documentoNfce','numero');

  if TI(ultimoNFCe)<=self.FultimaNfce then
    ultimoNFCe := self.FultimaNfce;

  if TI(ultimoNFCe)<=ultimoValorRegistro('inutilizacaoNFCe','numeroFinal',false) then
    ultimoNFCe := ultimoValorRegistro('inutilizacaoNFCe','numeroFinal',true);

  result := ultimoNFCe;

end;

function TNFConfiguracoes.arquivoCertificado: string;
begin
  result := self.FarquivoCertificado;
end;

function TNFConfiguracoes.ambiente: string;
begin
  result := self.Fambiente;
end;

function TNFConfiguracoes.emitente: TEmitente;
begin
  result := self.FEmitente;
end;

constructor TNFConfiguracoes.Create;
const
  qryNome: string = 'qryObterConfiguracoes';
begin

  inherited;

  FDCCreateQry(qryNome);

  try

    try

      FDCCloseQry(qryNome);
      FDCClearQry(qryNome);
      FDCSqlAdd  (qryNome, Nenhum, '', 'SELECT * FROM configuracoes' );
      FDCOpenQry (qryNome);

      if (FDCGetQry(qryNome).IsEmpty) then
      begin

        self
          .id(1)
          .emitenteId(1)
          .serieNfce(0)
          .ultimaNfce(0)
          .ambiente('2')
          .save;

        self.refresh();

      end
      else
      begin

        self
          .id(TI(FDCGetQry(qryNome).FieldByName('id').Value))
          .emitenteId(TI(FDCGetQry(qryNome).FieldByName('emitenteId').Value))
          .serieNfce(TI(FDCGetQry(qryNome).FieldByName('serieNfce').Value))
          .ultimaNfce(TI(FDCGetQry(qryNome).FieldByName('ultimaNfce').Value))
          .arquivoCertificado(TS(FDCGetQry(qryNome).FieldByName('arquivoCertificado').Value))
          .ambiente(TS(FDCGetQry(qryNome).FieldByName('ambiente').Value));

      end;

    except
      on e:exception do
        raise Exception.Create(e.Message);
    end;

  finally
    FDCCloseQry(qryNome);
    FDCDestroyQry(qryNome);
  end;

end;

procedure TNFConfiguracoes.refresh;
const
  qryNome: string = 'qryObterConfiguracoes';
begin

  inherited;

  FDCCreateQry(qryNome);

  try

    try

      FDCCloseQry(qryNome);
      FDCClearQry(qryNome);
      FDCSqlAdd  (qryNome, Nenhum, '', 'SELECT * FROM configuracoes' );
      FDCOpenQry (qryNome);

      self
        .id(TI(FDCGetQry(qryNome).FieldByName('id').Value))
        .emitenteId(TI(FDCGetQry(qryNome).FieldByName('emitenteId').Value))
        .serieNfce(TI(FDCGetQry(qryNome).FieldByName('serieNfce').Value))
        .ultimaNfce(TI(FDCGetQry(qryNome).FieldByName('ultimaNfce').Value))
        .arquivoCertificado(TS(FDCGetQry(qryNome).FieldByName('arquivoCertificado').Value))
        .ambiente(TS(FDCGetQry(qryNome).FieldByName('ambiente').Value));

    except
      on e:exception do
        raise Exception.Create(e.Message);
    end;

  finally
    FDCCloseQry(qryNome);
    FDCDestroyQry(qryNome);
  end;

end;

procedure TNFConfiguracoes.save;
const
  qryNome: string = 'qrySalvarConfiguracoes';
begin

  inherited;

  FDCCreateQry(qryNome);

  try

    try

      FDCCloseQry(qryNome);
      FDCClearQry(qryNome);
      FDCSqlAdd  (qryNome, Nenhum, '', 'SELECT * FROM configuracoes' );
      FDCOpenQry (qryNome);

      FDCGetQry(qryNome).edit;

      FDCGetQry(qryNome).FieldByName('id').Value                  := self.id;
      FDCGetQry(qryNome).FieldByName('emitenteId').Value          := self.emitenteId;
      FDCGetQry(qryNome).FieldByName('serieNfce').Value           := self.serieNfce;
      FDCGetQry(qryNome).FieldByName('ultimaNfce').Value          := self.ultimaNfce;
      FDCGetQry(qryNome).FieldByName('arquivoCertificado').Value  := self.arquivoCertificado;
      FDCGetQry(qryNome).FieldByName('ambiente').Value            := self.ambiente;

      FDCGetQry(qryNome).post;

    except
      on e:exception do
        raise Exception.Create(e.Message);
    end;

  finally
    self.refresh;
    FDCCloseQry(qryNome);
    FDCDestroyQry(qryNome);
  end;

end;

end.
