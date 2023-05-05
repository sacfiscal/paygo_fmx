unit uFuncoesDB;

interface

uses

  uDataModule,
  System.DateUtils,
  System.PushNotification,
  System.Notification,
  System.IOUtils,

{$IFDEF VER330 }
  System.Permissions,
{$ENDIF}
{$IFDEF ANDROID}
  FMX.PushNotification.Android,
  FMX.Platform.Android,
  FMX.Platform,
  Androidapi.Helpers,
  Androidapi.JNI.os,
  Androidapi.JNI.Widget,
  Androidapi.JNI.Telephony,
  Androidapi.JNI.Provider,
  Androidapi.JNIBridge,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  FMX.Helpers.Android,
  FMX.VirtualKeyboard,
{$ENDIF}
  System.SysUtils, System.Types, System.UITypes, System.UIConsts,
  System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uFormBase, FMX.Layouts, FMX.Objects, FMX.MultiView, FMX.Controls.Presentation,
  FMX.ListBox,
  System.Actions, FMX.ActnList, FMX.Gestures, Data.DB, System.ImageList,
  FMX.ImgList, FMX.Ani, FMX.Effects, FMX.TabControl, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ListView, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors,
  Data.Bind.Components, Data.Bind.DBScope, FMX.ComboEdit,
  FMX.Edit, FMX.DateTimeCtrls;

type

  TModo = (Open, Execute);
  TTipo = (Texto, Data, Hora, DataHora, Inteiro, Numerico, Nenhum);
  TTipoLogin = (tlInvalido, tlCliente, tlUsuario);

function fncObterDadosEmpresa(Campo: string): variant;

function obterOrigemBancoDeDados(): string;
function abrirConexaoDB(): Boolean;
function limparTabelas(): Boolean;
function atualizarTabelas(): Boolean;

function ultimoValorRegistro(nomeTabela,campo:string; proximo: Boolean=true): integer;

function proximaNFCe(): integer;

function FDCOpenQry(Sender: TFDQuery): Boolean; OVERLOAD;
function FDCOpenQry(NomeQUERY: STRING): Boolean; OVERLOAD;
function FDCExecQry(Sender: TFDQuery): Boolean; OVERLOAD;
function FDCExecQry(NomeQUERY: STRING): Boolean; OVERLOAD;
function FDCCloseQry(Sender: TFDQuery): Boolean; OVERLOAD;
function FDCCloseQry(NomeQUERY: STRING): Boolean; OVERLOAD;
function FDCCreateQry(NomeQUERY: STRING): Boolean;
function FDCAddQry(Sender: TFDQuery; Texto: STRING): Boolean; OVERLOAD;
function FDCAddQry(NomeQUERY: STRING; Texto: STRING): Boolean; OVERLOAD;
function FDCClearQry(Sender: TFDQuery): Boolean; OVERLOAD;
function FDCClearQry(NomeQUERY: STRING): Boolean; OVERLOAD;
function FDCDestroyQry(NomeQUERY: STRING): Boolean;
function FDCGetQry(NomeQUERY: STRING): TFDQuery;
function FDCQryIsNull(Sender: TFDQuery): Boolean; OVERLOAD;
function FDCQryIsNull(NomeQUERY: STRING): Boolean; OVERLOAD;
function FDCSql(Select: STRING; Modo: TModo): STRING;
function FDCGetField(Qry, Field: string; Tipo: TTipo): Variant;

function FDCSqlAdd(ObjQry: TFDQuery; Tipo: TTipo; Conteudo: Variant; TextoSql: String): Boolean ; OVERLOAD;
function FDCSqlAdd(ObjQry: String; Tipo: TTipo; Conteudo: Variant; TextoSql: String): Boolean; OVERLOAD;

implementation

uses
  uFuncoesGerais;

function fncObterDadosEmpresa(Campo: string): variant;
begin

  FDCCreateQry('qryDadosEmpresa');

  try

    try

      FDCCloseQry('qryDadosEmpresa');
      FDCClearQry('qryDadosEmpresa');
      FDCAddQry('qryDadosEmpresa','select ' + Campo + ' FROM emitente WHERE id=1 ');
      FDCGetQry('qryDadosEmpresa').Open;

      Result := FDCGetQry('qryDadosEmpresa').FieldByName(Campo).Value;

    except
      on e:exception do
      begin
        raise Exception.Create(e.Message);
      end;
    end;

  finally
    FDCCloseQry('qryDadosEmpresa');
    FDCDestroyQry('qryDadosEmpresa');
  end;

end;

function obterOrigemBancoDeDados(): string;
var
  origemBandoDeDados: string;
begin

  try

{$IFDEF ANDROID}
    origemBandoDeDados := System.IOUtils.TPath.Combine
      (System.IOUtils.TPath.GetDocumentsPath, 'PayGO.db');
{$ENDIF}
{$IFDEF MSWINDOWS}
    origemBandoDeDados := System.IOUtils.TPath.Combine
      (System.SysUtils.GetCurrentDir, 'PayGO.db');
{$ENDIF}
    Result := origemBandoDeDados;

  except
    Result := '';
  end;

end;

function abrirConexaoDB(): Boolean;
begin

  try

    if DM.PayGODB.Connected = false then
      DM.PayGODB.Connected := True;

    Result := DM.PayGODB.Connected;

  except
    Result := false;
  end;

end;

function limparTabelas(): Boolean;
begin

  FDCCreateQry('qryZerarTabelas');

  try

    try

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCAddQry('qryZerarTabelas','DELETE FROM INUTILIZACAONFCE;');
      FDCGetQry('qryZerarTabelas').ExecSQL;

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCAddQry('qryZerarTabelas','DELETE FROM PAGAMENTONFCE;');
      FDCGetQry('qryZerarTabelas').ExecSQL;

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCAddQry('qryZerarTabelas','DELETE FROM ITEMDOCUMENTO;');
      FDCGetQry('qryZerarTabelas').ExecSQL;

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCAddQry('qryZerarTabelas','DELETE FROM DOCUMENTONFCE;');
      FDCGetQry('qryZerarTabelas').ExecSQL;

//      FDCCloseQry('qryZerarTabelas');
//      FDCClearQry('qryZerarTabelas');
//      FDCAddQry('qryZerarTabelas','DELETE FROM PRODUTO;');
//      FDCGetQry('qryZerarTabelas').ExecSQL;
//
//      FDCCloseQry('qryZerarTabelas');
//      FDCClearQry('qryZerarTabelas');
//      FDCAddQry('qryZerarTabelas','DELETE FROM DESTINATARIO;');
//      FDCGetQry('qryZerarTabelas').ExecSQL;

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCAddQry('qryZerarTabelas','DELETE FROM CONFIGURACOES;');
      FDCGetQry('qryZerarTabelas').ExecSQL;

//      FDCCloseQry('qryZerarTabelas');
//      FDCClearQry('qryZerarTabelas');
//      FDCAddQry('qryZerarTabelas','DELETE FROM USUARIO;');
//      FDCGetQry('qryZerarTabelas').ExecSQL;

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCAddQry('qryZerarTabelas','DELETE FROM EMITENTE;');
      FDCGetQry('qryZerarTabelas').ExecSQL;

      Result := True;

    except
      Result := false;
    end;

  finally
    FDCCloseQry('qryZerarTabelas');
    FDCDestroyQry('qryZerarTabelas');
  end;

end;

function atualizarTabelas():Boolean;
begin

//  FDCCreateQry('qryAlter');
//
//  try
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE documentoNfce ADD nuvemFiscal_idUnico TEXT(250);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE documentoNfce ADD nuvemFiscal_ChaveNFe TEXT(250);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE documentoNfce ADD nuvemFiscal_status INTEGER;');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE documentoNfce ADD nuvemFiscal_StatusMotivo TEXT(500);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE documentoNfce ADD nuvemFiscal_JsonAutorizacao TEXT(5000);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE inutilizacaoNfce ADD nuvemFiscal_JsonInutilização TEXT(5000);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE documentoNfce ADD nuvemFiscal_JsonCancelamento TEXT(5000);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE pagamentoNfce ADD paygo_recibo TEXT(5000);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE pagamentoNfce ADD paygo_comprovante1via TEXT(5000);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//    try
//
//      FDCCloseQry('qryAlter');
//      FDCClearQry('qryAlter');
//      FDCAddQry  ('qryAlter','ALTER TABLE pagamentoNfce ADD paygo_comprovante2via TEXT(5000);');
//      FDCExecQry ('qryAlter');
//
//    except
//    end;
//
//  finally
//    FDCCloseQry('qryAlter');
//    FDCDestroyQry('qryAlter');
//  end;

end;

function ultimoValorRegistro(nomeTabela,campo:string; proximo: Boolean=true): integer;
begin

  FDCCreateQry('qryZerarTabelas');

  try

    try

      FDCCloseQry('qryZerarTabelas');
      FDCClearQry('qryZerarTabelas');
      FDCSqlAdd  ('qryZerarTabelas', Nenhum,         '','select max( ' + campo + ' ) as ultimoId');
      FDCSqlAdd  ('qryZerarTabelas',  Texto, nomeTabela,'   from {}');
      FDCOpenQry ('qryZerarTabelas');

      if FDCGetQry('qryZerarTabelas').IsEmpty then
        Result := 1
      else
      begin
        if proximo=true then
          Result := TI(FDCGetField('qryZerarTabelas','ultimoId',Inteiro)) + 1
        else
          Result := TI(FDCGetField('qryZerarTabelas','ultimoId',Inteiro));
      end;

    except
      raise Exception.Create('Falha ao buscar ID da tabela ' + QuotedStr(nomeTabela) );
    end;

  finally
    FDCCloseQry('qryZerarTabelas');
    FDCDestroyQry('qryZerarTabelas');
  end;

end;

function proximaNFCe(): integer;
VAR
  ultimaSequencia: integer;
  ultimaInutilizacao: integer;
begin

  ultimaSequencia := ultimoValorRegistro('documentoNFce','numero');
  ultimaInutilizacao := ultimoValorRegistro('inutilizacaoNFCe','numeroFinal',false);

  if ultimaInutilizacao > ultimaSequencia  then
    Result := ultimaInutilizacao + 1
  else
    Result := ultimaSequencia;

end;

function FDCOpenQry(Sender: TFDQuery): Boolean;
VAR
  strSQL: STRING;
BEGIN

  Result := True;

  // Abrindo DataSet
  TRY

    IF Sender.Active THEN
      Sender.Close;

    strSQL := Sender.SQL.text;
    Sender.Open;

  EXCEPT
    ON E: Exception DO
    BEGIN
      RAISE Exception.create(E.Message);
      Result := false;
    END;
  END;

END;

function FDCOpenQry(NomeQUERY: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  Result := True;

  // Encontrando o objeto TFDQuery
  IF DM.FindComponent(NomeQUERY) <> nil THEN
  BEGIN
    Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);
  END
  ELSE
    Result := false;

  // Abrindo DataSet
  IF Result THEN
  BEGIN

    IF NOT FDCOpenQry(Sender) THEN
      Result := false;

  END;

END;

function FDCExecQry(Sender: TFDQuery): Boolean;
BEGIN

  Result := True;

  // Executando DataSet
  TRY

    IF Sender.Active THEN
      Sender.Close;

    Sender.ExecSQL;

  EXCEPT

    ON E: EDatabaseError DO
    BEGIN

      Result := false;

    END;

  END;

END;

function FDCExecQry(NomeQUERY: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  Result := True;

  // Encontrando o objeto TFDQuery
  IF DM.FindComponent(NomeQUERY) <> nil THEN
  BEGIN
    Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);
  END
  ELSE
    Result := false;

  // Abrindo DataSet
  IF Result THEN
  BEGIN

    IF NOT FDCExecQry(Sender) THEN
      Result := false;

  END;

END;

function FDCCloseQry(Sender: TFDQuery): Boolean;
BEGIN

  Result := True;

  // Fechando DataSet
  TRY

    IF Sender.Active THEN
      Sender.Close;

  EXCEPT
    Result := false;
  END;

END;

function FDCCloseQry(NomeQUERY: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  Result := True;

  // Encontrando o objeto TFDQuery
  IF DM.FindComponent(NomeQUERY) <> nil THEN
  BEGIN
    Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);
  END
  ELSE
    Result := false;

  // Fechando DataSet
  IF Result THEN
  BEGIN

    IF NOT FDCCloseQry(Sender) THEN
      Result := false;

  END;

END;

function FDCCreateQry(NomeQUERY: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  Result := True;

  TRY

    IF DM.FindComponent(NomeQUERY) <> nil THEN
    BEGIN

      Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);

      IF Sender.Active THEN
        Sender.Close;

      Sender.SQL.Clear;

    END
    ELSE
    BEGIN

      Sender := TFDQuery.create(DM);
      Sender.Name := NomeQUERY;

      TFDQuery(Sender).FormatOptions.StrsEmpty2Null := true;
      TFDQuery(Sender).FormatOptions.StrsTrim := true;
      TFDQuery(Sender).FormatOptions.StrsTrim2Len := true;

      // Sender.FetchOptions.Unidirectional := True;
      Sender.Connection := DM.PayGODB;

    END;

  EXCEPT
    Result := false;
  END;

END;

function FDCAddQry(Sender: TFDQuery; Texto: STRING): Boolean;
BEGIN

  Result := True;

  // Adicionando SQL ao DataSet
  TRY
    Sender.SQL.Add(Texto);
  EXCEPT
    Result := false;
  END;

END;

function FDCAddQry(NomeQUERY: STRING; Texto: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  Result := True;

  IF (DM.FindComponent(NomeQUERY) <> nil) THEN
  BEGIN
    Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);
  END;

  // Adicionando SQL ao DataSet
  IF Result THEN
  BEGIN

    IF NOT FDCAddQry(Sender, Texto) THEN
      Result := false;

  END;

END;

function FDCClearQry(Sender: TFDQuery): Boolean;
BEGIN

  Result := True;

  TRY
    Sender.SQL.Clear;
  EXCEPT
    Result := false;
  END;

END;

function FDCClearQry(NomeQUERY: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  Result := True;
  IF DM.FindComponent(NomeQUERY) <> nil THEN
  BEGIN
    Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);
  END;

  // Adicionando SQL ao DataSet
  IF Result THEN
  BEGIN

    IF NOT FDCClearQry(Sender) THEN
      Result := false;

  END;

END;

function FDCDestroyQry(NomeQUERY: STRING): Boolean;
BEGIN

  IF DM.FindComponent(NomeQUERY) <> nil THEN
  BEGIN

    (DM.FindComponent(NomeQUERY) AS TFDQuery).destroy;
    Result := True;

  END
  ELSE
    Result := True;

END;

function FDCGetQry(NomeQUERY: STRING): TFDQuery;
BEGIN

  IF DM.FindComponent(NomeQUERY) <> nil THEN
    Result := (DM.FindComponent(NomeQUERY) AS TFDQuery)
  ELSE
    Result := nil;

END;

function FDCQryIsNull(Sender: TFDQuery): Boolean;
BEGIN

  IF (Sender.RecordCount IN [0, 1]) AND (Sender.FieldCount IN [0, 1]) AND
    (Sender.Fields[0].IsNull) THEN
    Result := True
  ELSE
    Result := false;

END;

function FDCQryIsNull(NomeQUERY: STRING): Boolean;
VAR
  Sender: TFDQuery;
BEGIN

  IF DM.FindComponent(NomeQUERY) <> nil THEN
  BEGIN
    Sender := (DM.FindComponent(NomeQUERY) AS TFDQuery);
  END;

  Result := FDCQryIsNull(Sender);

END;

function FDCSql(Select: STRING; Modo: TModo): STRING;
VAR
  qryDBMSql: TFDQuery;
  RetStr: STRING;
  x: Integer;
BEGIN

  // Executa comandos Insert, Update e Delete no modo Execute e
  // retorna campos de um select para apenas um registro no modo Open

  qryDBMSql := TFDQuery.create(Application);
  qryDBMSql.Connection := DM.PayGODB;

  qryDBMSql.SQL.Add(Select);

  TRY

    IF Modo = Open THEN
    BEGIN

      RetStr := '';
      qryDBMSql.Open;

      FOR x := 0 TO (qryDBMSql AS TFDQuery).FieldCount - 1 DO
        RetStr := RetStr + (qryDBMSql AS TFDQuery).Fields.Fields[x]
          .AsString + ';';

      Result := RetStr;

    END
    ELSE
      qryDBMSql.ExecSQL;

  FINALLY
    FreeAndNil(qryDBMSql);
  END;

END;

function FDCGetField(Qry, Field: string; Tipo: TTipo): Variant;
begin

  // Retorna um campo da Query

  try

    case Tipo of

      Inteiro:
        Result := TI(FDCGetQry(Qry).FieldByName(Field).AsInteger);
      Numerico:
        Result := TN(FDCGetQry(Qry).FieldByName(Field).AsFloat);
      Texto:
        Result := FDCGetQry(Qry).FieldByName(Field).AsString;
      Data:
        Result := FDCGetQry(Qry).FieldByName(Field).AsDateTime;
      DataHora:
        Result := FDCGetQry(Qry).FieldByName(Field).AsDateTime;
      Hora:
        Result := StrToTime(FDCGetQry(Qry).FieldByName(Field).AsString);
      Nenhum:
        Result := FDCGetQry(Qry).FieldByName(Field).Value;

    else
      Result := FDCGetQry(Qry).FieldByName(Field).Value;
    end;

  except
    Result := FDCGetQry(Qry).FieldByName(Field).Value;
  end;

end;

{ Função para Adicionar um Parâmetro a Query dado o Tipo de Dados Selecionado }
function FDCSqlAdd(ObjQry: TFDQuery; Tipo: TTipo; Conteudo: Variant;
  TextoSql: String): Boolean;
var
  SqlPart1, SqlPart2, SqlFinal: String;
  SqlAplica: Boolean;
begin

  Result := true;

  try

    // Adiciona uma linha a propriedade SQL de um TQuery
    // ObjQry    : Query de pesquisa que está sendo montada
    // Tipo      : Enumeração : Texto, D\ata, Hora, DataHora, Inteiro, Numerico, Nenhum
    // Conteudo  : Componente.Propriedade, usado para fazer o filtro na where ( )
    // TextoSql  : Texto sql com macro-substituição pelo conteúdo do componente
    // Obs: usar {} para especificar o ponto de entrada do conteúdo do conteudo
    // o conteudo é do tipo variant então podemos fazer compo.date, compo.text, compo.value, ...

    if (Tipo = Data) and (TS(Conteudo) = '  /  /    ') then
      Conteudo := '';

    if Tipo <> Nenhum then
    begin

      if (Tipo = Texto) or ((Tipo <> Texto) and (TS(Conteudo) <> '')) then
      begin

        SqlPart1 := Copy(TextoSql, 1, Pos('{', TextoSql) - 1);
        SqlPart2 := Copy(TextoSql, Pos('}', TextoSql) + 1, Length(TextoSql));
        SqlFinal := '';

        // veriricar se o campo em questão é a chave primária - navegação otmizada

        if Tipo = Texto then
          // somente texto
          SqlFinal := SqlPart1 + '''' + Conteudo + '''' + SqlPart2
        else if Tipo = Data then
          // data formatada como texto no formato yyyy-mm-dd
          SqlFinal := SqlPart1 + '''' + FormatDateTime('YYYY-MM-DD', Conteudo) +
            '''' + SqlPart2
        else if Tipo = DataHora then
          // data formatada como texto no formato yyyy-mm-dd : hh-mm-ss
          SqlFinal := SqlPart1 + '''' + FormatDateTime('YYYY-MM-DD HH:MM:SS',
            Conteudo) + '''' + SqlPart2
        else if (Tipo = Hora) and (FormatDateTime('HH:MM:SS', Conteudo) <>
          '00:00:00') then
          // data formatada como texto no formato yyyy-mm-dd : hh-mm-ss
          SqlFinal := SqlPart1 + '''' + FormatDateTime('HH:MM:SS', Conteudo) +
            '''' + SqlPart2
        else if Tipo = Inteiro then
          // valores inteiros
          SqlFinal := SqlPart1 + TS(Conteudo) + SqlPart2
        else if Tipo = Numerico then
          // valores monetários
          SqlFinal := SqlPart1 + Ponto(Conteudo) + SqlPart2;

      end;

    end
    else
    begin
      SqlFinal := TextoSql;
    end;

    if SqlFinal <> '' then
    begin
      Try
        (ObjQry as TFDQuery).SQL.Add(SqlFinal);
      Except
        on e:exception do
        begin
          Result := false;
          raise Exception.Create(e.message);
        end;
      end;
    end;

    Result := true;

  except
    Result := false;
  end;

end;

{ Função para Adicionar um Parâmetro a Query dado o Tipo de Dados Selecionado }
function FDCSqlAdd(ObjQry: String; Tipo: TTipo; Conteudo: Variant;
  TextoSql: String): Boolean;
var
  SqlPart1, SqlPart2, SqlFinal: String;
  SqlAplica: Boolean;
begin

  Result := true;

  try
    Result := FDCSqlAdd(FDCGetQry(ObjQry), Tipo, Conteudo, TextoSql);
  except
    Result := false;
  end;

end;

end.
