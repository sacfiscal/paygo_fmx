unit uFuncoesNuvemFiscalAPI;

interface

uses
  uGlobal, uConfiguracoes, xSuperJson, XSuperObject, System.SysUtils,
  System.Types, System.UITypes, System.Classes, System.IOUtils, uFuncoesGerais,
  uFuncoesDB, uFuncoesINI, NuvemFiscalClient, NuvemFiscalDTOs, OpenApiRest;

var
  TokenProvider: IClientCredencialsTokenProvider;
  TokenData: ITokenData;

function nuvemFiscalRefreshToken(): Boolean;

function nuvemFiscalVaidarEmpresaAPI(cnpj: string): Boolean;

function nuvemFiscalEmitirNFCe(nfceId: integer): integer;

function nuvemFiscalGerarDanfe(chaveNFe: string): boolean;

function nuvemFiscalInutilizarSequencia(ano: integer; nInincial, nFinal: Integer; justificativa: string): Boolean;

function nuvemFiscalCancelarNFCe(id, justificativa: string): Boolean;

function nuvemFiscalObterXml(id: string): string;

function nuvemFiscalObterEscPos(id: string): String;

implementation

function nuvemFiscalRefreshToken(): Boolean;
var
  Token, DataExpiracao: string;
begin

  {
    Função para obter/atualizar o token da API
    - Token valido por 30 dias
  }

  try

    try

      DataExpiracao := iniLerString('NuvemFiscal', 'DataExpiracao');

      if Trim(DataExpiracao) = '' then
        DataExpiracao := '01/01/2000 00:00:01';

      if StrToDateTime(DataExpiracao) < Now() then
      begin

        TokenProvider := TClientCredentialsTokenProvider.Create;
        TokenProvider.TokenEndpoint := 'https://auth.nuvemfiscal.com.br/oauth/token';

        TokenProvider.ClientId := 'ClaloOc8Sd8eVxUgytk7';
        TokenProvider.ClientSecret := 'aPg9W29s0R0T0jlbHc3wvbMM9MoCGPO8LnIirufb';
        TokenProvider.Scope := 'cep cnpj empresa nfse';
        TokenData := TokenProvider.RetrieveToken;

        Token := TokenData.AccessToken;
        DataExpiracao := DateTimeToStr(TokenData.ExpirationTime);

        iniGravarString('NuvemFiscal', 'Token', Token);
        iniGravarString('NuvemFiscal', 'DataExpiracao', DataExpiracao);

      end;

    except
      on e: exception do
      begin
        Toast(e.Message);
        Result := false;
      end;
    end;

  finally

  end;

end;

function nuvemFiscalVaidarEmpresaAPI(cnpj: string): Boolean;
const
  qryEmitente: string = 'qryEmitente';
var
  Client: INuvemFiscalClient;
  Empresa: TEmpresa;
  ConfigNFCe: TEmpresaConfigNfce;
  infoMsg: string;
  emitenteId: integer;
begin

  emitenteId := 0;

  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  // '14063822000126'
  Empresa := Client.Empresa.ConsultarEmpresa(cnpj);

  if Empresa = nil then
    raise exception.Create('Empresa não cadastrada na API');

  FDCCreateQry(qryEmitente);

  try

    try

      FDCCloseQry(qryEmitente);
      FDCClearQry(qryEmitente);
      FDCSqlAdd(qryEmitente, texto, TS(Empresa.cpf_cnpj), 'select * from emitente where cnpj_cpf = {}');
      FDCOpenQry(qryEmitente);

      if FDCGetQry(qryEmitente).IsEmpty then
      begin

        emitenteId := ultimoValorRegistro('emitente', 'id');

        FDCCloseQry(qryEmitente);
        FDCClearQry(qryEmitente);
        FDCSqlAdd(qryEmitente, Nenhum, '', 'INSERT INTO emitente');
        FDCSqlAdd(qryEmitente, Nenhum, '', '(');

        FDCSqlAdd(qryEmitente, Nenhum, '', '  id,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  razao_social,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  nome_fantasia,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  cnpj_cpf,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  logradouro,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  numero,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  complemento,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  bairro,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  codigo_municipio,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  municipio,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  uf,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  cep,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  fone,');
        FDCSqlAdd(qryEmitente, Nenhum, '', '  ie');

        FDCSqlAdd(qryEmitente, Nenhum, '', ')');

        FDCSqlAdd(qryEmitente, Nenhum, '', 'VALUES');

        FDCSqlAdd(qryEmitente, Nenhum, '', '(');

        FDCSqlAdd(qryEmitente, Inteiro, emitenteId, '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.nome_razao_social), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.nome_fantasia), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.cpf_cnpj), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.logradouro), '{},');

        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.numero), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.complemento), '{},');

        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.bairro), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.codigo_municipio), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.cidade), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.uf), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.endereco.cep), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.fone), '{},');
        FDCSqlAdd(qryEmitente, texto, TS(Empresa.inscricao_estadual), '{}');

        FDCSqlAdd(qryEmitente, Nenhum, '', ');');

        FDCGetQry(qryEmitente).ExecSQL;

        ConfigNFCe := Client.Empresa.ConsultarConfigNfce(cnpj);

        if ConfigNFCe <> nil then
        begin

          FDCCloseQry(qryEmitente);
          FDCClearQry(qryEmitente);
          FDCSqlAdd(qryEmitente, Nenhum, '', 'UPDATE emitente');
          FDCSqlAdd(qryEmitente, texto, TS(ConfigNFCe.CRT), '   SET crt   = {},');
          FDCSqlAdd(qryEmitente, texto, TS(ConfigNFCe.sefaz.id_csc), '       idCsc = {},');
          FDCSqlAdd(qryEmitente, texto, TS(ConfigNFCe.sefaz.csc), '       csc   = {}');
          FDCSqlAdd(qryEmitente, texto, TS(cnpj), ' where cnpj_cpf = {}');
          FDCGetQry(qryEmitente).ExecSQL;

          FDCCloseQry(qryEmitente);
          FDCClearQry(qryEmitente);
          FDCSqlAdd(qryEmitente, Nenhum, '', 'insert into usuario');
          FDCSqlAdd(qryEmitente, Nenhum, '', '(id,emitenteid,nome,login,senha)');
          FDCSqlAdd(qryEmitente, Nenhum, '', 'values');
          FDCSqlAdd(qryEmitente, Nenhum, '', '(1,1,''admin'',''admin'',''admin'')');
          FDCGetQry(qryEmitente).ExecSQL;

        end;

      end;

      iniGravarInteiro('emitente', 'id', emitenteId);
      iniGravarString('emitente', 'cnpj', cnpj);

      Result := true;

    except
      on e: exception do
      begin
        Toast('Falha ao tentar validar o cadastro da empresa.');
        Result := false;
      end;
    end;

  finally
    FDCCloseQry(qryEmitente);
    FDCDestroyQry(qryEmitente);
  end;

end;

function nuvemFiscalEmitirNFCe(nfceId: integer): integer;
const
  qryEmitente: string = 'qryEmitente';
var
  Client: INuvemFiscalClient;
  pedidoNFce: TNfePedidoEmissao;
  detPro: TNfeSefazDet;
  detPag: TNfeSefazDetPag;
  ItemID: Integer;
  resNFe: TDfe;
begin

  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  pedidoNFce := TNfePedidoEmissao.Create;

  if uGlobal.globalConfiguracoes = nil then
    uGlobal.globalConfiguracoes := TNFConfiguracoes.Create;

  FDCCreateQry('qryDocumentoNfce');
  FDCCreateQry('qryEmitente');
  FDCCreateQry('qryItemDocumento');
  FDCCreateQry('qryPagamentoNfce');

  try

    try

      {ambiente}

      if uGlobal.globalConfiguracoes.ambiente = '1' then
        pedidoNFce.ambiente := 'producao'
      else
        pedidoNFce.ambiente := 'homologacao';

      {infNFe}

      FDCCloseQry('qryDocumentoNfce');
      FDCClearQry('qryDocumentoNfce');

      FDCSqlAdd('qryDocumentoNfce', nenhum, '', '   SELECT documentoNfce.*, ');
      FDCSqlAdd('qryDocumentoNfce', nenhum, '', '          emitente.codigo_municipio, destinatario.email ');
      FDCSqlAdd('qryDocumentoNfce', nenhum, '', '     FROM documentoNfce ');
      FDCSqlAdd('qryDocumentoNfce', nenhum, '', 'LEFT JOIN emitente on ( emitente.id = documentoNfce.emitenteId ) ');
      FDCSqlAdd('qryDocumentoNfce', nenhum, '', 'LEFT JOIN destinatario on ( destinatario.id = documentoNfce.destinatarioId ) ');

      FDCSqlAdd('qryDocumentoNfce', Inteiro, nfceId, '    WHERE documentoNfce.id = {}');

      FDCOpenQry('qryDocumentoNfce');

      {versao}

      pedidoNFce.infNFe.versao := '4.00';

      {ide}

      {Informar}
      pedidoNFce.infNFe.ide.cUF := TI(Copy(TS(FDCGetQry('qryDocumentoNfce').FieldByName('codigo_municipio').value), 1, 2));

      //pedidoNFce.infNFe.ide.cNF := TS(Random(99999999));
      pedidoNFce.infNFe.ide.natOp := 'VENDA';
      pedidoNFce.infNFe.ide.&mod := 65;

      {Informar}
      pedidoNFce.infNFe.ide.serie := TI(FDCGetQry('qryDocumentoNfce').FieldByName('serie').value);

      {Informar}
      pedidoNFce.infNFe.ide.nNF := TI(FDCGetQry('qryDocumentoNfce').FieldByName('numero').value);

      {Informar}
      pedidoNFce.infNFe.ide.dhEmi := Now();

      {Informar}
      pedidoNFce.infNFe.ide.dhSaiEnt := Now();

      pedidoNFce.infNFe.ide.tpNF := 1;
      pedidoNFce.infNFe.ide.idDest := 1;

      {Informar}
      pedidoNFce.infNFe.ide.cMunFG := TS(FDCGetQry('qryDocumentoNfce').FieldByName('codigo_municipio').value);

      pedidoNFce.infNFe.ide.tpImp := 4;
      pedidoNFce.infNFe.ide.tpEmis := 1;
      pedidoNFce.infNFe.ide.cDV := 0;

      {Informar}
      pedidoNFce.infNFe.ide.tpAmb := TI(uGlobal.globalConfiguracoes.ambiente);

      pedidoNFce.infNFe.ide.finNFe := 1;
      pedidoNFce.infNFe.ide.indFinal := 1;
      pedidoNFce.infNFe.ide.indPres := 1;
      pedidoNFce.infNFe.ide.indIntermed := 0;
      pedidoNFce.infNFe.ide.procEmi := 0;
      pedidoNFce.infNFe.ide.verProc := 'PayGO_FMX';

      if TI(FDCGetQry('qryDocumentoNfce').FieldByName('emitenteId').value) > 0 then
      begin

        {emit}

        FDCCloseQry('qryEmitente');
        FDCClearQry('qryEmitente');
        FDCSqlAdd('qryEmitente', Inteiro, TI(FDCGetQry('qryDocumentoNfce').FieldByName('emitenteId').value), 'SELECT * FROM emitente WHERE id = {}');
        FDCOpenQry('qryEmitente');

        pedidoNFce.infNFe.emit.CNPJ := TS(FDCGetQry('qryEmitente').FieldByName('cnpj_cpf').value);
        pedidoNFce.infNFe.emit.xNome := TS(FDCGetQry('qryEmitente').FieldByName('razao_social').value);
        pedidoNFce.infNFe.emit.xFant := TS(FDCGetQry('qryEmitente').FieldByName('nome_fantasia').value);

        pedidoNFce.infNFe.emit.enderEmit := TNfeSefazEnderEmi.Create;

        pedidoNFce.infNFe.emit.enderEmit.xLgr := TS(FDCGetQry('qryEmitente').FieldByName('logradouro').value);
        pedidoNFce.infNFe.emit.enderEmit.nro := TS(FDCGetQry('qryEmitente').FieldByName('numero').value);
        pedidoNFce.infNFe.emit.enderEmit.xCpl := TS(FDCGetQry('qryEmitente').FieldByName('complemento').value);
        pedidoNFce.infNFe.emit.enderEmit.xBairro := TS(FDCGetQry('qryEmitente').FieldByName('bairro').value);
        pedidoNFce.infNFe.emit.enderEmit.cMun := TS(FDCGetQry('qryEmitente').FieldByName('codigo_municipio').value);
        pedidoNFce.infNFe.emit.enderEmit.xMun := TS(FDCGetQry('qryEmitente').FieldByName('municipio').value);
        pedidoNFce.infNFe.emit.enderEmit.UF := TS(FDCGetQry('qryEmitente').FieldByName('uf').value);
        pedidoNFce.infNFe.emit.enderEmit.CEP := TS(FDCGetQry('qryEmitente').FieldByName('cep').value);
        pedidoNFce.infNFe.emit.enderEmit.cPais := '1058';
        pedidoNFce.infNFe.emit.enderEmit.xPais := 'BRASIL';
        pedidoNFce.infNFe.emit.enderEmit.fone := TS(FDCGetQry('qryEmitente').FieldByName('fone').value);

        pedidoNFce.infNFe.emit.IE := TS(FDCGetQry('qryEmitente').FieldByName('ie').value);

        pedidoNFce.infNFe.emit.IE := StringReplace(pedidoNFce.infNFe.emit.IE, '.', '', [rfReplaceAll, rfIgnoreCase]);
        pedidoNFce.infNFe.emit.IE := StringReplace(pedidoNFce.infNFe.emit.IE, ',', '', [rfReplaceAll, rfIgnoreCase]);
        pedidoNFce.infNFe.emit.IE := StringReplace(pedidoNFce.infNFe.emit.IE, '-', '', [rfReplaceAll, rfIgnoreCase]);
        pedidoNFce.infNFe.emit.IE := StringReplace(pedidoNFce.infNFe.emit.IE, '/', '', [rfReplaceAll, rfIgnoreCase]);

        pedidoNFce.infNFe.emit.CRT := TI(FDCGetQry('qryEmitente').FieldByName('crt').value);

      end;

      if trim(TS(FDCGetQry('qryDocumentoNfce').FieldByName('cnpjcpf').value)) <> '' then
      begin

        pedidoNFce.infNFe.dest := TNfeSefazDest.Create;

        pedidoNFce.infNFe.dest.indIEDest := 9;
        pedidoNFce.infNFe.dest.CPF := TS(FDCGetQry('qryDocumentoNfce').FieldByName('cnpjcpf').value);

        if trim(TS(FDCGetQry('qryDocumentoNfce').FieldByName('email').value)) <> '' then
          pedidoNFce.infNFe.dest.email := TS(FDCGetQry('qryDocumentoNfce').FieldByName('email').value);

      end;

      {det}

      FDCCloseQry('qryItemDocumento');
      FDCClearQry('qryItemDocumento');
      FDCSqlAdd('qryItemDocumento', Inteiro, nfceId, 'SELECT ItemDocumento.*, produto.* FROM ItemDocumento join produto on ( produto.id = ItemDocumento.produtoId ) WHERE ItemDocumento.documentoId = {}');
      FDCOpenQry('qryItemDocumento');

      FDCGetQry('qryItemDocumento').First;

      ItemID := 0;

      while not FDCGetQry('qryItemDocumento').Eof do
      begin

        detPro := TNfeSefazDet.Create;

        detPro.nItem := ItemID + 1;

        detPro.prod := TNfeSefazProd.Create;

        detPro.prod.cProd := TS(FDCGetQry('qryItemDocumento').FieldByName('codigo').value);
        detPro.prod.cEAN := TS(FDCGetQry('qryItemDocumento').FieldByName('cean').value);
        detPro.prod.xProd := TS(FDCGetQry('qryItemDocumento').FieldByName('descricao').value);
        detPro.prod.NCM := TS(FDCGetQry('qryItemDocumento').FieldByName('ncm').value);
        detPro.prod.CEST := TS(FDCGetQry('qryItemDocumento').FieldByName('cest').value);
        detPro.prod.CFOP := TS(FDCGetQry('qryItemDocumento').FieldByName('cfop').value);
        detPro.prod.uCom := TS(FDCGetQry('qryItemDocumento').FieldByName('unidade').value);
        detPro.prod.qCom := TN(FDCGetQry('qryItemDocumento').FieldByName('quantidade').value);
        detPro.prod.vUnCom := TN(FDCGetQry('qryItemDocumento').FieldByName('valorProdutos').value);
        detPro.prod.vProd := TN(FDCGetQry('qryItemDocumento').FieldByName('totalItem').value);
        detPro.prod.cEANTrib := TS(FDCGetQry('qryItemDocumento').FieldByName('cean').value);
        detPro.prod.uTrib := TS(FDCGetQry('qryItemDocumento').FieldByName('unidade').value);
        detPro.prod.qTrib := TN(FDCGetQry('qryItemDocumento').FieldByName('quantidade').value);
        detPro.prod.vUnTrib := TN(FDCGetQry('qryItemDocumento').FieldByName('valorProdutos').value);
        detPro.prod.indTot := 1;

        detPro.imposto := TNfeSefazImposto.Create;

        detPro.imposto.vTotTrib := 0;

        detPro.imposto.ICMS := TNfeSefazICMS.Create;

        detPro.imposto.ICMS.ICMSSN102 := TNfeSefazICMSSN102.Create;

        detPro.imposto.ICMS.ICMSSN102.orig := TI(FDCGetQry('qryItemDocumento').FieldByName('origem').value);
        detPro.imposto.ICMS.ICMSSN102.CSOSN := TS(FDCGetQry('qryItemDocumento').FieldByName('csticms').value);

        pedidoNFce.infNFe.det.Add(detPro);

        inc(ItemID);
        FDCGetQry('qryItemDocumento').Next;

      end;

      {total}

      pedidoNFce.infNFe.total.ICMSTot.vBC := 0;
      pedidoNFce.infNFe.total.ICMSTot.vICMS := 0;
      pedidoNFce.infNFe.total.ICMSTot.vICMSDeson := 0;
      pedidoNFce.infNFe.total.ICMSTot.vFCPUFDest := 0;
      pedidoNFce.infNFe.total.ICMSTot.vICMSUFDest := 0;
      pedidoNFce.infNFe.total.ICMSTot.vICMSUFRemet := 0;
      pedidoNFce.infNFe.total.ICMSTot.vFCP := 0;
      pedidoNFce.infNFe.total.ICMSTot.vBCST := 0;
      pedidoNFce.infNFe.total.ICMSTot.vST := 0;
      pedidoNFce.infNFe.total.ICMSTot.vFCPST := 0;
      pedidoNFce.infNFe.total.ICMSTot.vFCPSTRet := 0;

      {Informar}
      pedidoNFce.infNFe.total.ICMSTot.vProd := TN(FDCGetQry('qryDocumentoNfce').FieldByName('valorProdutos').value);

      {Informar}
      pedidoNFce.infNFe.total.ICMSTot.vFrete := TN(FDCGetQry('qryDocumentoNfce').FieldByName('valorFrete').value);

      {Informar}
      pedidoNFce.infNFe.total.ICMSTot.vSeg := TN(FDCGetQry('qryDocumentoNfce').FieldByName('valorSeguro').value);

      {Informar}
      pedidoNFce.infNFe.total.ICMSTot.vDesc := TN(FDCGetQry('qryDocumentoNfce').FieldByName('valorDesconto').value);

      pedidoNFce.infNFe.total.ICMSTot.vII := 0;
      pedidoNFce.infNFe.total.ICMSTot.vIPI := 0;
      pedidoNFce.infNFe.total.ICMSTot.vIPIDevol := 0;
      pedidoNFce.infNFe.total.ICMSTot.vPIS := 0;
      pedidoNFce.infNFe.total.ICMSTot.vCOFINS := 0;

      {Informar}
      pedidoNFce.infNFe.total.ICMSTot.vOutro := TN(FDCGetQry('qryDocumentoNfce').FieldByName('valorOutros').value);

      {Informar}
      pedidoNFce.infNFe.total.ICMSTot.vNF := TN(FDCGetQry('qryDocumentoNfce').FieldByName('valorTotal').value);

      pedidoNFce.infNFe.total.ICMSTot.vTotTrib := 0;

      {transp}

      pedidoNFce.infNFe.transp.modFrete := 9;

      {pag}

      FDCCloseQry('qryPagamentoNfce');
      FDCClearQry('qryPagamentoNfce');
      FDCSqlAdd('qryPagamentoNfce', Inteiro, nfceId, 'SELECT * FROM PagamentoNfce WHERE documentoId = {}');
      FDCOpenQry('qryPagamentoNfce');

      detPag := TNfeSefazDetPag.Create;
      detPag.tPag := TS(FDCGetQry('qryPagamentoNfce').FieldByName('tipoPagamento').value).PadLeft(2, '0');
      detPag.vPag := TN(FDCGetQry('qryPagamentoNfce').FieldByName('valorPagamento').value);

      pedidoNFce.infNFe.pag.detPag.Add(detPag);

      pedidoNFce.infNFe.pag.vTroco := 0;

      {infAdic}

      pedidoNFce.infNFe.infAdic := TNfeSefazInfAdic.Create;

      pedidoNFce.infNFe.infAdic.infCpl := '.';

      resNFe := Client.Nfce.EmitirNfce(pedidoNFce);

      if resNFe.autorizacao.codigo_status = 100 then
      begin

        FDCCreateQry('qryEmitirNFCe');

        try

          try

            FDCCloseQry('qryEmitirNFCe');
            FDCClearQry('qryEmitirNFCe');

            FDCSqlAdd('qryEmitirNFCe',   Nenhum, '', 'update documentoNfce              ');
            FDCSqlAdd('qryEmitirNFCe',    Texto, resNFe.id, '   set  nuvemFiscal_idUnico  = {} ');
            FDCSqlAdd('qryEmitirNFCe',    Texto, resNFe.autorizacao.chave_acesso, '       ,nuvemFiscal_ChaveNFe = {} ');
            FDCSqlAdd('qryEmitirNFCe',  Inteiro, resNFe.autorizacao.codigo_status, '       ,nuvemFiscal_status   = {} ');
            FDCSqlAdd('qryEmitirNFCe',    Texto, resNFe.autorizacao.motivo_status, '       ,nuvemFiscal_StatusMotivo   = {} ');
            FDCSqlAdd('qryEmitirNFCe',    Texto, resNFe.autorizacao.numero_protocolo, '       ,protocoloAutorizacao = {} ');
            FDCSqlAdd('qryEmitirNFCe', DataHora, resNFe.autorizacao.data_recebimento, '       ,dhAutorizacao        = {} ');
            FDCSqlAdd('qryEmitirNFCe',    Texto, resNFe.autorizacao.AsJSON(false), '   ,nuvemFiscal_JsonAutorizacao        = {} ');
            FDCSqlAdd('qryEmitirNFCe',  Inteiro, nfceId, 'where id = {}');

            FDCGetQry('qryEmitirNFCe').ExecSQL;

            // impressao nfce endpoint escpos


          except
            on e: Exception do
              raise Exception.Create(e.Message);
          end;

        finally
          FDCCloseQry('qryEmitirNFCe');
          FDCDestroyQry('qryEmitirNFCe');
        end;

        Result := resNFe.autorizacao.codigo_status;

      end
      else
      begin

        FDCCreateQry('qryEmitirNFCe');

        try

          try

            FDCCloseQry('qryEmitirNFCe');
            FDCClearQry('qryEmitirNFCe');

            FDCSqlAdd('qryEmitirNFCe', Nenhum, '', 'update documentoNfce              ');
            FDCSqlAdd('qryEmitirNFCe', Texto, resNFe.id, '   set  nuvemFiscal_idUnico  = {} ');
            FDCSqlAdd('qryEmitirNFCe', Texto, resNFe.autorizacao.chave_acesso, '       ,nuvemFiscal_ChaveNFe = {} ');
            FDCSqlAdd('qryEmitirNFCe', Inteiro, resNFe.autorizacao.codigo_status, '       ,nuvemFiscal_status   = {} ');
            FDCSqlAdd('qryEmitirNFCe',    Texto, resNFe.autorizacao.motivo_status, '       ,nuvemFiscal_StatusMotivo   = {} ');
            FDCSqlAdd('qryEmitirNFCe', Texto, resNFe.autorizacao.AsJSON(false), '   ,nuvemFiscal_JsonAutorizacao        = {} ');
            FDCSqlAdd('qryEmitirNFCe', Inteiro, nfceId, 'where id = {}');

            FDCGetQry('qryEmitirNFCe').ExecSQL;

          except
            on e: Exception do
            begin
              Toast(e.Message);
              raise Exception.Create(e.Message);
            end;
          end;

        finally
          FDCCloseQry('qryEmitirNFCe');
          FDCDestroyQry('qryEmitirNFCe');
        end;

        Result := resNFe.autorizacao.codigo_status;

      end;

    except
      on e: Exception do
      begin
        Toast(e.Message);
        raise Exception.Create(e.Message);
      end;
    end;

  finally

    FDCCloseQry('qryDocumentoNfce');
    FDCCloseQry('qryEmitente');
    FDCCloseQry('qryItemDocumento');
    FDCCloseQry('qryPagamentoNfce');

    FDCDestroyQry('qryDocumentoNfce');
    FDCDestroyQry('qryEmitente');
    FDCDestroyQry('qryItemDocumento');
    FDCDestroyQry('qryPagamentoNfce');

  end;

end;

function nuvemFiscalGerarDanfe(chaveNFe: string): boolean;
const
  qryEmitente: string = 'qryEmitente';
var
  Client: INuvemFiscalClient;
  pedidoNFce: TNfePedidoEmissao;
  detPro: TNfeSefazDet;
  detPag: TNfeSefazDetPag;
  ItemID: Integer;
  resNFe: TDfe;
  fStream: TFileStream;
  sFile: string;
  pdf: TBytes;
begin

  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  pdf := Client.Nfce.BaixarPDFNfce(chaveNFe);

  sFile := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, (chaveNFe + '.pdf'));

  fStream := TFileStream.Create(sFile, fmCreate);

  try
    if pdf <> nil then
      fStream.WriteBuffer(pdf[0], Length(pdf));
  finally
    fStream.Free;
  end;

  AbrirPDF(sFile);

end;

function nuvemFiscalObterXml(id: string): string;
var
  Client: INuvemFiscalClient;
  Xml: TBytes;
  fStream: TFileStream;
  sFile: string;
begin
  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  Xml := Client.Nfce.BaixarXmlNfce(id);
  sFile := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, (id + '.xml'));
  fStream := TFileStream.Create(sFile, fmCreate);

  try
    if Xml <> nil then
      fStream.WriteBuffer(Xml[0], Length(Xml));
  finally
    fStream.Free;
  end;
end;

function nuvemFiscalObterEscPos(id: string): String;
var
  Client: INuvemFiscalClient;
  Xml: String;
  fStream: TStream;
  sFile: string;
  aux: TStringlist;
begin

  aux := TStringlist.Create;

  nuvemFiscalRefreshToken();
  sFile := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, (id + '.txt'));

  if not FileExists(sfile) then
  begin

    Client := TNuvemFiscalClient.Create;
    Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

    Xml := Client.Nfce.BaixarEscPosNfce(id);

    aux.Text := xml;
    aux.SaveToFile(sFile);

  end
  else
  begin

    aux.LoadFromFile(sfile);

  end;

  result := aux.Text;

end;

function nuvemFiscalInutilizarSequencia(ano: integer; nInincial, nFinal: Integer; justificativa: string): Boolean;
const
  qryEmitente: string = 'qryEmitente';
var
  Client: INuvemFiscalClient;
  pedidoNFce: TNfePedidoEmissao;
  detPro: TNfeSefazDet;
  detPag: TNfeSefazDetPag;
  ItemID: Integer;
  resNFe: TDfe;
  fStream: TFileStream;
  sFile: string;
  pdf: TBytes;
  PedidoInutilizacao: TDfePedidoInutilizacao;
  inutilizacao: TDfeInutilizacao;
begin

  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  PedidoInutilizacao := TDfePedidoInutilizacao.Create;

  PedidoInutilizacao.ambiente := 'homologacao';

  PedidoInutilizacao.cnpj := globalConfiguracoes.emitente.cnpjCpf;
  PedidoInutilizacao.ano := ano;
  PedidoInutilizacao.serie := globalConfiguracoes.serieNfce;
  PedidoInutilizacao.numero_inicial := nInincial;
  PedidoInutilizacao.numero_final := nFinal;
  PedidoInutilizacao.justificativa := justificativa;

  inutilizacao := Client.Nfce.InutilizarNumeracaoNfce(PedidoInutilizacao);

  if TI(inutilizacao.codigo_status) = 102 then
  begin

    FDCCreateQry('qryInutilizacao');

    try

      try

        FDCCloseQry('qryInutilizacao');
        FDCClearQry('qryInutilizacao');

        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'insert into inutilizacaoNFCe');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', '( ');

        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'id, ');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'serie, ');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'numeroInicial, ');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'numeroFinal, ');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'dhInutilizacao, ');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'nuvemFiscal_JsonInutilização, ');
        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'protocoloInutilizacao ');

        FDCSqlAdd('qryInutilizacao', Nenhum, '', ')');

        FDCSqlAdd('qryInutilizacao', Nenhum, '', 'values ');

        FDCSqlAdd('qryInutilizacao', Nenhum, '', '(');

        FDCSqlAdd('qryInutilizacao', inteiro, ultimoValorRegistro('inutilizacaoNFCe', 'id'), '{},');
        FDCSqlAdd('qryInutilizacao', inteiro, inutilizacao.serie, '{},');
        FDCSqlAdd('qryInutilizacao', inteiro, inutilizacao.numero_inicial, '{},');
        FDCSqlAdd('qryInutilizacao', inteiro, inutilizacao.numero_final, '{},');
        FDCSqlAdd('qryInutilizacao', datahora, inutilizacao.data_recebimento, '{}, ');
        FDCSqlAdd('qryInutilizacao', texto, inutilizacao.AsJSON(false), '{}, ');
        FDCSqlAdd('qryInutilizacao', inteiro, inutilizacao.numero_protocolo, '{}');

        FDCSqlAdd('qryInutilizacao', Nenhum, '', ');');

        FDCGetQry('qryInutilizacao').ExecSQL;

      except
        on e: exception do
          raise Exception.Create(e.Message);
      end;

    finally
      FDCCloseQry('qryInutilizacao');
      FDCDestroyQry('qryInutilizacao');
    end;

    result := true;

  end
  else
  begin

    Toast(inutilizacao.motivo_status);
    result := false;

  end;

end;

function nuvemFiscalCancelarNFCe(id, justificativa: string): Boolean;
const
  qryEmitente: string = 'qryEmitente';
var
  Client: INuvemFiscalClient;
  pedidoNFce: TNfePedidoEmissao;
  detPro: TNfeSefazDet;
  detPag: TNfeSefazDetPag;
  ItemID: Integer;
  resNFe: TDfe;
  fStream: TFileStream;
  sFile: string;
  pdf: TBytes;
  pedidoCancelamento: TNfePedidoCancelamento;
  cancelamento: TDfeCancelamento;
begin

  nuvemFiscalRefreshToken();

  Client := TNuvemFiscalClient.Create;
  Client.Config.AccessToken := iniLerString('NuvemFiscal', 'Token');

  pedidoCancelamento := TNfePedidoCancelamento.Create;
  pedidoCancelamento.justificativa := justificativa;

  cancelamento := Client.Nfce.CancelarNfce(pedidoCancelamento,id);

  if TI(cancelamento.codigo_status) = 135 then
  begin

    FDCCreateQry('qryCancelamento');

    try

      try

        FDCCloseQry('qryCancelamento');
        FDCClearQry('qryCancelamento');
        FDCSqlAdd ('qryCancelamento',   Nenhum,                               '', 'update documentoNFCe');
        FDCSqlAdd ('qryCancelamento',    texto,    cancelamento.numero_protocolo, '   set  protocoloCancelamento    = {}');
        FDCSqlAdd ('qryCancelamento',    Texto,       cancelamento.motivo_status, '       ,nuvemFiscal_StatusMotivo = {} ');
        FDCSqlAdd ('qryCancelamento',    Texto,       cancelamento.AsJSON(false), '       , nuvemFiscal_JsonCancelamento = {} ');
        FDCSqlAdd ('qryCancelamento',  Inteiro,                              101, '       ,nuvemfiscal_status       = {}');
        FDCSqlAdd ('qryCancelamento',    texto,                               id, ' where nuvemfiscal_idUnico       = {}');
        FDCGetQry ('qryCancelamento').ExecSQL;

      except
        on e: exception do
          raise Exception.Create(e.Message);
      end;

    finally
      FDCCloseQry('qryCancelamento');
      FDCDestroyQry('qryCancelamento');
    end;

    result := true;

  end
  else
  begin

    result := false;

  end;

end;

end.

