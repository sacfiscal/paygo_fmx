unit uFuncoesGerais;

interface

uses

  System.PushNotification,
  System.Notification,
  System.IOUtils,
  uApplicationParamList,

  {$IFDEF ANDROID}

    FMX.PushNotification.Android,
    FMX.Platform.Android,
    FMX.Helpers.Android,

    Androidapi.Helpers,
    Androidapi.JNI.os,
    Androidapi.JNI.Widget,
    Androidapi.JNI.Telephony,
    Androidapi.JNI.Provider,
    Androidapi.JNIBridge,
    Androidapi.JNI.GraphicsContentViewText,
    Androidapi.JNI.JavaTypes,
    Androidapi.JNI.Net,
    Androidapi.JNI.App,

  {$ENDIF}

  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Actions, FMX.ActnList, System.ImageList,
  FMX.ImgList, FMX.Objects, FMX.Effects, FMX.Controls.Presentation,
  FMX.Layouts, FMX.TabControl, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, FMX.TextLayout;

var
  ApplicationParmTemp: uApplicationParamList.TApplicationParamList;
  databasePath: string;
  empresaIdentificada: boolean;
  manterLogin: boolean;
  aplicativoLogado: boolean;

const
  APPNAME: string = 'PAYGO';

procedure Toast(const Msg: string; Duration: Integer = 5);
function loginUsuario(login, Senha: String): boolean;

function infoToString(AValor: Variant): string;
function infoToNumeric(AValor: Variant): Double;
function infoToInteger(AValor: Variant): Integer;
function infoToDate(AValor: Variant): TDatetime;
function infoToLongInt(AValor: Variant): LongInt;
function DIVIDIR(DIVIDENDO: Double; DIVIDOR: Double): Double;
function infoToInt64(AValor: Variant): Int64;
function fncCopyText(Texto: String; Indice: Integer;
  Field: Integer = 0): Variant;
function fncInfoCount(Texto: String; Separador: String = ';'; Aspas: Boolean = False): Integer;
function fncInfoPos(Texto, Conteudo, Separador: String): Integer;
function fncAjustaTextoBusca(AValor: string): string;
FUNCTION PONTO(VALOR: STRING): STRING;
FUNCTION VIRGULA(VALOR: STRING): STRING;
FUNCTION TS(VVAR: Variant): STRING;
FUNCTION TN(VVAR: Variant): Double;
FUNCTION TI(VVAR: Variant): Integer;
FUNCTION TD(VVAR: Variant): TDatetime;
FUNCTION TLI(VVAR: Variant): LongInt;
FUNCTION TI64(VVAR: Variant): Int64;
function GetTextHeight(const D: TListItemText; const Width: single;
  const Text: string): Integer;
Function TiraMascara(lConteudo: String): String;
function FileToString(arquivo: string): string;
function incluirZerosEsquerda(codigo: string; tamanho: Integer): string;
function formatCPFCNPJ(VALOR: string): string;

function fncItemLista(Texto: String; Indice: Integer; Separador: String = ';'; Aspas: Boolean = False): String;

procedure AbrirPDF(const AFileName: string);

implementation

uses
  uFuncoesDB,
  uFuncoesINI;

//Retorna conteudo String de uma posicao de uma lista separada conforme separador
function fncItemLista(Texto: String; Indice: Integer; Separador: String = ';'; Aspas: Boolean = False): String;
var
  StrAnt: String;
  X, Y: Integer;
begin
  Result := '';
  Y := 0;
  if Aspas then
  begin
    // Considerando Campos entre Aspas
    StrAnt := '';
    for X := 1 to Length(Texto) do
    begin
      if (StrAnt='"') or (StrAnt='''') then
      begin
        if (Copy(Texto, X, 1) <> Separador) and (X <= Length(Texto)) then Result := Result + Copy(Texto, X, 1);
      end else
      begin
        if (X <= Length(Texto)) then Result := Result + Copy(Texto, X, 1);
      end;
      //
      if ( ((StrAnt='"') or (StrAnt='''')) and (Copy(Texto, X, 1) = Separador) ) or (X >= Length(Texto)) then
      begin
        Y := Y + 1;
        if Y = Indice then Break else Result := '';
      end;
      if Copy(Texto, X, 1) <> ' ' then StrAnt := Copy(Texto, X, 1);
    end;
  end else
  begin
    // NÃO Considerando Campos entre Aspas
    for X := 1 to Length(Texto) do
    begin
      if (Copy(Texto, X, 1) <> Separador) and (X <= Length(Texto)) then Result := Result + Copy(Texto, X, 1);
      if (Copy(Texto, X, 1) = Separador) or (X >= Length(Texto)) then
      begin
        Y := Y + 1;
        if Y = Indice then Break else Result := '';
      end;
    end;
  end;
end;

procedure Toast(const Msg: string; Duration: Integer = 5);
begin

{$IFDEF ANDROID}
  CallInUiThread(
    procedure
    begin
      TJToast.JavaClass.makeText(TAndroidHelper.Context,
        StrToJCharSequence(Msg), Duration).show
    end);

{$ENDIF}
{$IFDEF MSWINDOWS}
  ShowMessage(Msg);

{$ENDIF}
end;

function loginUsuario(login, Senha: String): boolean;
const
  qryNome: string = 'qry_loginUsuario';
begin

  FDCCreateQry(qryNome);

  try

    try

      FDCCloseQry(qryNome);
      FDCClearQry(qryNome);

      FDCSqlAdd(qryNome, Texto, login, 'SELECT * FROM USUARIO WHERE NOME = {}');
      FDCOpenQry(qryNome);

      if FDCGetQry(qryNome).IsEmpty then
      begin

        aplicativoLogado := false;

        if manterLogin then
          iniGravarBoleano('Config', 'aplicativoLogado', aplicativoLogado);

        result := aplicativoLogado;

      end
      else
      begin

        aplicativoLogado := (FDCGetField(qryNome, 'senha', Texto) = Senha);

        if manterLogin then
          iniGravarBoleano('Config', 'aplicativoLogado', aplicativoLogado);

        result := aplicativoLogado;

        if aplicativoLogado then
          iniGravarString('Usuario', 'loginUsuario', login);

      end;

    except
      aplicativoLogado := false;

      if manterLogin then
        iniGravarBoleano('Config', 'aplicativoLogado', aplicativoLogado);

      result := aplicativoLogado;
    end;

  finally

    FDCCloseQry(qryNome);
    FDCDestroyQry(qryNome);

  end;

end;

function incluirZerosEsquerda(codigo: string; tamanho: Integer): string;
var
  forCount: Integer;
  retorno: string;
begin

  retorno := codigo;

  for forCount := 1 to tamanho do
  begin
    if Length(retorno) < 5 then
      retorno := '0' + retorno;
  end;

  result := retorno;

end;

function infoToString(AValor: Variant): string;
begin

  try
    result := AValor;
  except
    result := '';
  end;

end;

function infoToNumeric(AValor: Variant): Double;
begin

  try
    result := AValor;
  except
    result := 0;
  end;

end;

function infoToInteger(AValor: Variant): Integer;
begin

  try
    result := AValor;
  except
    result := 0;
  end;

end;

function infoToDate(AValor: Variant): TDatetime;
var
  DAT: TDatetime;
begin

  try

    if (AValor <> NULL) then
    begin
      DAT := StrToDate(infoToString(AValor));
      result := DAT;
    end
    else
      result := StrToDateTime('01/01/2000 00:00:01');

  except
    result := StrToDateTime('01/01/2000 00:00:01');
  end;

end;

function infoToLongInt(AValor: Variant): LongInt;
begin

  try
    result := AValor;
  except
    result := 0;
  end;

end;

function DIVIDIR(DIVIDENDO: Double; DIVIDOR: Double): Double;
begin
  try
    if (DIVIDENDO <> 0) and (DIVIDOR <> 0) then
      result := (DIVIDENDO / DIVIDOR)
    else
      result := 0;
  except
    result := 0;
  end;
end;

function infoToInt64(AValor: Variant): Int64;
begin

  try
    result := AValor;
  except
    result := 0;
  end;

end;

function fncCopyText(Texto: String; Indice: Integer;
Field: Integer = 0): Variant;
var
  retorno, RetFields: String;
  X, Y, XField, YField: Integer;
begin

  Y := 0;
  YField := 0;
  retorno := '';
  RetFields := '';

  For X := 1 to Length(Texto) do
  begin

    if (Copy(Texto, X, 1) <> ';') and (X <= Length(Texto)) then
      retorno := retorno + Copy(Texto, X, 1);

    if (Copy(Texto, X, 1) = ';') or (X >= Length(Texto)) then
    begin

      Y := Y + 1;

      if Y = Indice then
      begin

        if Field = 0 then
          Break
        else if Field > 0 then
        begin

          RetFields := retorno;
          retorno := '';

          if Field < 99 then
          begin

            For XField := 1 to Length(RetFields) do
            begin

              if (Copy(RetFields, XField, 1) <> ',') and
                (XField <= Length(RetFields)) then
                retorno := retorno + Copy(RetFields, XField, 1);

              if (Copy(RetFields, XField, 1) = ',') or
                (XField >= Length(RetFields)) then
              begin

                YField := YField + 1;

                if YField = Field then
                begin

                  result := retorno;
                  Texto := '';
                  Exit;

                end
                else
                  retorno := '';

              end;

            end;

          end
          else if Field = 99 then
          begin

            For XField := Length(RetFields) downto 1 do
            begin

              if (Copy(RetFields, XField, 1) <> ',') then
                retorno := Copy(RetFields, XField, 1) + retorno;

              if (Copy(RetFields, XField, 1) = ',') or (XField <= 1) then
              begin

                result := retorno;
                Texto := '';
                Exit;

              end;

            end;

          end;

        end;

      end
      else
        retorno := '';

    end;

  end;

  result := retorno;

end;

function fncInfoCount(Texto: String; Separador: String = ';'; Aspas: Boolean = False): Integer;
var
  StrAnt: String;
  x : integer;
  count : integer;
begin
  // Retorna o número de campos de uma lista string, separadas por um caracter
  // O Parametro Aspas determina uma exigencia que cada campo das lista esteja entre aspas
  Result := 0;
  if Texto <> EmptyStr then
  begin
    count := 0;
    StrAnt := '';
    for x := 1 to length(Texto) do
    begin
      if Aspas then
      begin
        // Considerando Campos entre Aspas
        if (StrAnt='"') or (StrAnt='''') then
        begin
          if Copy(Texto,x,1)=Separador then
          begin
            count := count + 1;
            StrAnt := '';
          end;
        end;
        if Copy(Texto,x,1) <> ' ' then StrAnt := Copy(Texto,x,1);
      end else
      begin
        // NÃO Considerando Campos entre Aspas
        if Copy(Texto,x,1)=Separador then count := count + 1;
      end;
    end;
    Result := Count + 1;
  end;
end;

function fncInfoPos(Texto, Conteudo, Separador: String): Integer;
var
  X, p: Integer;
  count: Integer;
begin

  p := pos(Conteudo, Texto);
  count := 0;

  for X := 1 to p do
    if Copy(Texto, X, 1) = Separador then
      count := count + 1;

  result := count + 1;

end;

function fncAjustaTextoBusca(AValor: string): string;
begin

  result := StringReplace(AValor, ' ', '%', [rfReplaceAll, rfIgnoreCase]);;

end;

FUNCTION PONTO(VALOR: STRING): STRING;
VAR
  cont: Integer;
BEGIN
  result := '';
  FOR cont := 1 TO Length(VALOR) DO
  BEGIN
    IF Copy(VALOR, cont, 1) = ',' THEN
      result := result + '.'
    ELSE
      result := result + Copy(VALOR, cont, 1);
  END;
END;

FUNCTION VIRGULA(VALOR: STRING): STRING;
VAR
  cont: Integer;
BEGIN
  result := '';
  FOR cont := 1 TO Length(VALOR) DO
  BEGIN
    IF Copy(VALOR, cont, 1) = '.' THEN
      result := result + ','
    ELSE
      result := result + Copy(VALOR, cont, 1);
  END;
END;

FUNCTION TS(VVAR: Variant): STRING;
BEGIN

  TRY
    result := VVAR;
  EXCEPT
    result := '';
  END;

END;

FUNCTION TN(VVAR: Variant): Double;
BEGIN

  TRY
    result := VVAR;
  EXCEPT
    result := 0;
  END;

END;

FUNCTION TI(VVAR: Variant): Integer;
BEGIN

  TRY

    if VVAR = NULL then
      result := 0
    else
      result := VVAR;

  EXCEPT
    result := 0;
  END;

END;

FUNCTION TD(VVAR: Variant): TDatetime;
VAR
  DAT: TDatetime;
BEGIN

  TRY

    IF (VVAR <> NULL) THEN
    BEGIN
      DAT := StrToDate(TS(VVAR));
      result := DAT;
    END
    ELSE
      result := NULL;

  EXCEPT
    result := NULL;
  END;

END;

FUNCTION TLI(VVAR: Variant): LongInt;
BEGIN

  TRY
    result := VVAR;
  EXCEPT
    result := 0;
  END;

END;

FUNCTION TI64(VVAR: Variant): Int64;
BEGIN

  TRY
    result := VVAR;
  EXCEPT
    result := 0;
  END;

END;

function GetTextHeight(const D: TListItemText; const Width: single;
const Text: string): Integer;
var
  Layout: TTextLayout;
begin

  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := D.WordWrap;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;
    result := Round(Layout.Height);
    Layout.Text := 'm';
    result := result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;

Function TiraMascara(lConteudo: String): String;
var
  LString: String;
  X: Integer;
begin
  LString := '';
  for X := 1 to Length(lConteudo) do
  begin
    if lConteudo[X] in ['0' .. '9'] then
      LString := LString + lConteudo[X];
  end;
  result := LString;
end;

function FileToString(arquivo: string): string;
var
  TextFile: TStringList;
begin

  arquivo := arquivo;
  TextFile := TStringList.Create;
  try
    try
      TextFile.LoadFromFile(arquivo);

      result := TextFile.Text;

    finally
      FreeAndNil(TextFile);
    end
  except

    on E: Exception do
      ShowMessage('Não foi possível abrir o arquivo!');
  end;
end;

function formatCPFCNPJ(VALOR: string): string;
var
  retorno: string;
begin

  retorno := VALOR;
  retorno := StringReplace(retorno, '.', '', [rfReplaceAll, rfIgnoreCase]);
  retorno := StringReplace(retorno, '-', '', [rfReplaceAll, rfIgnoreCase]);
  retorno := StringReplace(retorno, '/', '', [rfReplaceAll, rfIgnoreCase]);

  if Length(retorno) <= 11 then
    retorno := Copy(retorno, 1, 3) + '.' + Copy(retorno, 4, 3) + '.' +
      Copy(retorno, 7, 3) + '-' + Copy(retorno, 10, 2)
  else
    retorno := Copy(retorno, 1, 2) + '.' + Copy(retorno, 3, 3) + '.' +
      Copy(retorno, 6, 3) + '/' + Copy(retorno, 9, 4) + '-' +
      Copy(retorno, 13, 2);

  result := retorno;

end;

procedure AbrirPDF(const AFileName: string);
{$IFDEF ANDROID}
var
  IntentJ: JIntent;
  JArq: JFile;
{$ENDIF}
begin
  if not FileExists(AFileName) then
    Toast('Arquivo não encontrado: ' + AFileName)
  else
  begin
    {$IFDEF ANDROID}
    JArq := TJFile.JavaClass.init(StringToJString(AFileName));
    IntentJ := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
    IntentJ.setDataAndType(TAndroidHelper.JFileToJURI(JArq), StringToJString('application/pdf'));
    IntentJ.setFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
    TAndroidHelper.Activity.startActivity(IntentJ);
    {$ENDIF}
  end;
end;

initialization
  ApplicationParmTemp := uApplicationParamList.TApplicationParamList.Create;

end.
