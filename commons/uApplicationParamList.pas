{
    Esta classe est� apta a trabalhar com as seguintes hierarquias de registros:

      1 - Registros sem Grupo:
        <RG> <ID>1</ID> <TAG>VALOR 1</TAG> </RG>
        <RG> <ID>2</ID> <TAG>VALOR 2</TAG> </RG>
        <RG> <ID>3</ID> <TAG>VALOR 3</TAG> </RG>

      2 - Registros Agrupados:
        <GR ID="GRUPO1">
          <RG> <ID>1</ID> <TAG>VALOR 1</TAG> </RG>
          <RG> <ID>2</ID> <TAG>VALOR 2</TAG> </RG>
          <RG> <ID>3</ID> <TAG>VALOR 3</TAG> </RG>
        </GR>
        <GR ID="GRUPO2">
          <RG> <ID>1</ID> <TAG>VALOR 1</TAG> </RG>
          <RG> <ID>2</ID> <TAG>VALOR 2</TAG> </RG>
          <RG> <ID>3</ID> <TAG>VALOR 3</TAG> </RG>
        </GR>

    - A manipula��o de Registros SEM GRUPO � realizada pelos m�todos: "AddXml()" e "GetXml()";
    - A manipula��o de Registros AGRUPADOS � realizada pelos m�todos: "AddXml2()" e "GetXml2()";

    OBS.: As duas hierarquias de registro n�o est�o habilitadas a trabalharem de
          maneira simultanea.

}

unit uApplicationParamList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.StrUtils,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Controls.Presentation,
  FMX.ListBox, FMX.Edit, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
   TStringArray = array of string;

   TApplicationParamList = class(TStringList)
   private
     FUnique: string;
     procedure prcValidarDuplicidade(Conteudo: string);
   public
     // Lista de TAGs, separados por v�rgula, de valores que n�o pode se repetir
     property Unique: string read FUnique write FUnique;

     constructor Create; overload;
     constructor Create(Unique: string); overload;

     function Add(const S: string): Integer; override;

     // Adicionar parametro tipo Variant como String
     Procedure AddParmV(ParamName: String; ParamValue: Variant);

     // Adicionar parametro tipo TComponent como String (Propriedade Name)
     Procedure AddParmC(ParamName: String; ParamValue: TComponent);

     // Adicionar parametro indexado por item (Matriz de Parametros com mesmo nome)
     Procedure AddParmItem(ParamName: String; Item: Integer; ParamValue: Variant);

     //Retorna conteudo de um Parametro RECEBIDO da lista - Tipo String
     Function GetParmS(ParamName: String ) : String;

     //Retorna conteudo de um Parametro RECEBIDO da lista - Tipo TForm
     Function GetParmF(ParamName: String ) : TForm;

     //Retorna conteudo de um Parametro RECEBIDO da lista - Tipo TComponent
     Function GetParmC(ParamName: String ) : TComponent;

     //Retorna conteudo de um Parametro[item] RECEBIDO da lista - Tipo String
     Function GetParmItem(ParamName: String; Item: Integer) : String;

     //Retorna total de itens de determinado parametro
     Function GetParmItemCount(ParamName: String) : Integer;

     // Modo XML
     // Adiciona uma propriedade da String XML <RG> <ID>identidade do registro</ID> <P1>=propriedad1</P1> <P2>propriedade1</P2>... </RG>
     Procedure AddXml(ID: String; Propriedade: String; Conteudo: String=''; Agregar: Integer = 0);

     // Adiciona uma propriedade da String XML COM GRUPO <RG> <ID>identidade do registro</ID> <P1>=propriedad1</P1> <P2>propriedade1</P2>... </RG>
     procedure AddXml2(GR: string; ID: String; Propriedade: String; Conteudo: String=''; Agregar: Integer = 0);

     // Retorna uma propriedade da String XML <RG> <ID>identidade do registro</ID> <P1>=propriedad1</P1> <P2>propriedade1</P2>... </RG>
     Function GetXml(ID: String; Propriedade: String; RG: String='') : String;

     // Retorna uma propriedade da String XML  COM GRUPO <RG> <ID>identidade do registro</ID> <P1>=propriedad1</P1> <P2>propriedade1</P2>... </RG>
     function GetXml2(GR: string; ID: String; Propriedade: String; RG: String='') : String;

     // Retorna um array com os IDs dos grupos existentes
     function GetGrupos(): TStringArray;

     // Obtendo Cont�do L�quido de uma Tag XML
     Function GetValorTagL(StringP1: String; StringP2: String; StringDeBusca: String) : String;

     // Obtendo Cont�do Bruto de uma Tag XML
     Function GetValorTagB(StringP1: String; StringP2: String; StringDeBusca: String) : String;

     // Efetua troca de string
     Function TrocaString(StrDE: String; StrPARA: String; StrLinha: String) : String;

   end;

implementation

uses
  uFuncoesGerais;

constructor TApplicationParamList.Create;
begin
  inherited Create;
end;

constructor TApplicationParamList.Create(Unique: string);
begin
  inherited Create;

  FUnique := Unique;
end;

procedure TApplicationParamList.prcValidarDuplicidade(Conteudo: string);
var
  Tag, Valor: string;
begin

  // Verifica se utiliza valor unico
  if Trim(FUnique) = EmptyStr then
    Exit;

  // Verifica se TAG controlada foi informada
  Tag := Copy(Conteudo, 2, Pos('>', Conteudo)-2);
  if Pos(Tag, FUnique) = 0 then
    Exit;

  if Conteudo <> EmptyStr then
  begin
    if Pos(Conteudo, Self.Text) > 0 then
    begin
      Valor := GetValorTagL('<' + Tag + '>', '</' + Tag + '>', Conteudo);
      raise Exception.Create('J� foi informado "' + Valor + '" para "' + Tag + '"');
    end;
  end;

end;

function TApplicationParamList.Add(const S: string): Integer;
var
  Tag, Conteudo: string;
  I: Integer;
begin

  // Verifica se utiliza valor unico
  if Trim(FUnique) <> EmptyStr then
  begin
    // Verifica se conteudo � XML
    if Pos('<RG>', S) > 0 then
    begin
      //
      for I := 1 to fncInfoCount(FUnique) do
      begin
        Tag := fncItemLista(FUnique, I, ',');
        Conteudo := GetValorTagB('<' + Tag + '>', '</' + Tag + '>', S);
        if Trim(Conteudo) <> EmptyStr then
          prcValidarDuplicidade(Conteudo);
      end;
    end;
  end;

  Result := inherited Add(S);

end;

// Obtendo Cont�do Liquido de uma Tag XML
Function TApplicationParamList.GetValorTagL(StringP1: String; StringP2: String; StringDeBusca: String) : String;
var S : String;
    P : Integer;
begin
  Result := '';
  P := Pos(UpperCase(StringP1),UpperCase(StringDeBusca)) + Length(StringP1);
  if P > 0 then
  begin
    S := Copy(StringDeBusca,P,length(StringDeBusca)-P+1);
    P := Pos(UpperCase(StringP2),UpperCase(S)) -1;
    if P > 0 then
      Result := Copy(S,1,P);
  end;
end;

// Obtendo Cont�do Bruto de uma Tag XML
Function TApplicationParamList.GetValorTagB(StringP1: String; StringP2: String; StringDeBusca: String) : String;
var S : String;
    P : Integer;
begin
  Result := '';
  P := Pos(UpperCase(StringP1),UpperCase(StringDeBusca));
  if P > 0 then
  begin
    S := Copy(StringDeBusca,P,length(StringDeBusca)-P+1);
    P := Pos(UpperCase(StringP2),UpperCase(S)) -1;
    if P > 0 then
      Result := Copy(S,1,P+Length(StringP2));
  end;
end;

Function TApplicationParamList.TrocaString(StrDE: String; StrPARA: String; StrLinha: String) : String;
begin
  if Pos(UpperCase(StrDE), UpperCase(StrLinha))>0 then
  begin
    Result := StringReplace(StrLinha, StrDE, StrPARA, [rfReplaceAll, rfIgnoreCase]);
  end else
  begin
    Result := StrLinha;
  end;
end;

// Adicionar parametro tipo Variant como String
Procedure TApplicationParamList.AddParmV(ParamName: String; ParamValue: Variant);
var
  a, b, c, d : String;
begin
  a := '<' + UpperCase(ParamName) + '>';
  b := '</' + UpperCase(ParamName) + '>';
  c := GetValorTagB(a, b, Self.Text);
  d := a + String(ParamValue) + b;
  if c = EmptyStr then
  begin
    // Nova Tag
    Self.Add(d)
  end else
  begin
    // Altera Tag
    Self.Text := TrocaString(c, d, Self.Text);
  end;
end;

// Adicionar parametro tipo TComponent como String (Propriedade Name)
Procedure TApplicationParamList.AddParmC(ParamName: String; ParamValue: TComponent);
begin
  if ParamValue <> nil then
     AddParmV(ParamName, ParamValue.Name)
  else
     AddParmV(ParamName, '');
end;

// Adicionar parametro indexado por item (Matriz de Parametros com mesmo nome)
Procedure TApplicationParamList.AddParmItem(ParamName: String; Item: Integer; ParamValue: Variant);
var
  s : String;
begin
  s:= (ParamName + '[' + IntToStr(Item) + ']');
  AddParmV(s, ParamValue);
end;

//Retorna conteudo de um ParamRtro RECEBIDO da lista - Tipo String
Function TApplicationParamList.GetParmS(ParamName: String ) : String;
var
  a, b : String;
begin
  a := '<' + UpperCase(ParamName) + '>';
  b := '</' + UpperCase(ParamName) + '>';
  Result := GetValorTagL(a, b, Self.Text);
end;

//Retorna conteudo de um ParamRtro RECEBIDO da lista - Tipo TForm
Function TApplicationParamList.GetParmF(ParamName: String ) : TForm;
begin
  Result := nil;
  if GetParmS(ParamName) <> '' then
  begin
    if Application.FindComponent(GetParmS(ParamName)) <> nil then
    begin
      // Busca na Aplicacao
      Result := TForm(Application.FindComponent(GetParmS(ParamName)));
    end else
    if Screen.FindComponent(GetParmS(ParamName)) <> nil then
    begin
      // Busca no Screen
      Result := TForm(Screen.FindComponent(GetParmS(ParamName)));
    end else
    if Application.MainForm.FindComponent(GetParmS(ParamName)) <> nil then
    begin
      // Busca no Form Principal
      Result := TForm(Application.FindComponent(GetParmS(ParamName)));
    end;
  end;
end;

//Retorna conteudo de um ParamRtro RECEBIDO da lista - Tipo TComponent
Function TApplicationParamList.GetParmC(ParamName: String ) : TComponent;
begin
  Result := nil;
  // Busca componente dentro do form ParamRtro padr�o AOwner
  if GetParmF('AOwner') <> nil then
  begin
    if GetParmS(ParamName)<>'' then
    begin
      Result := GetParmF('AOwner').FindComponent(GetParmS(ParamName));
    end;
  end
end;

//Retorna conteudo de um Parametro[item] RECEBIDO da lista - Tipo String
Function TApplicationParamList.GetParmItem(ParamName: String; Item: Integer) : String;
var
 s : String;
begin
  s := (ParamName + '[' + IntToStr(Item) + ']');
  Result := GetParmS(s);
end;

//Retorna total de itens de determinado parametro
Function TApplicationParamList.GetParmItemCount(ParamName: String) : Integer;
var p, t: Integer;
    s, Text: String;
begin
  Result := 0;
  Text := Self.Text;
  s := ( '<' + UpperCase(ParamName) + '[' );
  p := Pos(s, Text);
  while p>0 do
  begin
    Result := Result + 1;
    t := p + length(s);
    Text := Copy(Text, t, (Length(Text) - t - 1) );
    p := Pos(s, Text);
  end;
end;

// Adiciona uma propriedade da String XML <RG> <ID>identidade do registro</ID> <P1>=propriedad1</P1> <P2>propriedade1</P2>... </RG>
Procedure TApplicationParamList.AddXml(ID: String; Propriedade: String; Conteudo: String =''; Agregar: Integer = 0);
var
  a, b, c, d : String;
  x, y, w, n : String;
begin
  {
   LEGENDA:
   ID: Tag de Identifica��o do Registro
   Propriedade: Tag que represenda a propriedade (campo do registro)
   Conteudo: Conteudo da propriedade
   Agregar: 0 = Se propriedade j� exisitir, o conteudo � Substituido
            1 = Se propriedade j� exisitir, o conteudo � Agregado
  }

  // Se existe grupo, o ID do grupo dever� ser informado
  if Pos('</GR>', Self.Text) > 0 then
    raise Exception.Create('� necess�rio informar o Grupo!');

  prcValidarDuplicidade(' <'+Propriedade+'>' + Conteudo + '</'+Propriedade+'> ');

  a := '<RG> <ID>' + ID + '</ID>';
  b := '</RG>';
  c := GetValorTagB(a, b, Self.Text);
  if c = EmptyStr then
  begin
    if Propriedade <> 'ID' then
    begin
      // Novo Registro com nova propriedade
      d := (a + ' <'+Propriedade+'>' + Conteudo + '</'+Propriedade+'> ' + b);
    end else
    begin
      // Novo Registro Somente Implementa��o do ID
      d := (a +' ' + b);
    end;
    Self.Add(d)
  end else
  begin
    // Altera Registro, Adicionando Propriedade ou Alterando conteudo da propriedade
    x := '<'+Propriedade+'>';
    y := '</'+Propriedade+'>';
    w := GetValorTagB(x, y, c);
    if w = EmptyStr then
    begin
      // Nova propriedade
      n := a + GetValorTagL(a, b, c);
      d := (n + '<'+Propriedade+'>' + Conteudo + '</'+Propriedade+'> ' + b);
    end else
    begin
      // Altera��o de Conteudo da Propriedade
      if Agregar = 1 then
      begin
        // Agrega conteudo a propriedade
        n := '<'+Propriedade+'>' + GetValorTagL(x, y, w) + Conteudo + '</'+Propriedade+'>';
      end else
      begin
        // Troca o conteudo da propriedade
        n := '<'+Propriedade+'>' + Conteudo + '</'+Propriedade+'>';
      end;
      d := TrocaString(w, n, c);
    end;
    if c<>d then
    begin
      Self.Text := TrocaString(c, d, Self.Text);
    end;
  end;
end;

procedure TApplicationParamList.AddXml2(GR: string; ID: String; Propriedade: String; Conteudo: String=''; Agregar: Integer = 0);
var
  strAux, strTemp, strGrupo, strATagGrupo, strFTagGrupo: string;
  intPosIni, intPosFim: Integer;
begin
  {
   LEGENDA:
   GR: Tag de Identifica��o do Grupo
   ID: Tag de Identifica��o do Registro
   Propriedade: Tag que represenda a propriedade (campo do registro)
   Conteudo: Conteudo da propriedade
   Agregar: 0 = Se propriedade j� exisitir, o conteudo � Substituido
            1 = Se propriedade j� exisitir, o conteudo � Agregado
  }


  // Se n�o existe grupo e existe conte�do, n�o � permitido adicionar grupos
  if (Pos('</GR>', Self.Text) = 0) and (Trim(Self.Text) <> EmptyStr) then
     raise Exception.Create('N�o � permitido adicionar Grupo!');


  // Tag de abertura e fechamento
  strATagGrupo := '<GR ID="' + GR + '">';
  strFTagGrupo := '</GR>';

  // Recebe o conte�do do grupo
  strGrupo := GetValorTagB(strATagGrupo, strFTagGrupo, Self.Text);
  strGrupo := GetValorTagL(strATagGrupo, strFTagGrupo, strGrupo);

  // Salva o conte�do atual
  strTemp := Self.Text;

  // Trabalha apenas com o grupo
  Self.Text := strGrupo;

  // Cria ou adiciona a propriedade
  AddXml(ID, Propriedade, Conteudo, Agregar);

  // Se n�o existir grupo, o cria
  if strGrupo = EmptyStr then
    strTemp := strTemp + strATagGrupo + #13 + Trim(Self.Text) + #13 + strFTagGrupo
  else
  begin
    // Inicio do Grupo
    intPosIni := Pos(strATagGrupo, strTemp) - 1;

    // Fim do grupo
    strAux := DupeString(' ', intPosIni) + Copy(strTemp, intPosIni+1, Length(strTemp));
    intPosFim := Pos(strFTagGrupo, strAux) + Length(strFTagGrupo) + 1;

    // Monta o XML completo
    strTemp := Copy(strTemp, 1, intPosIni) +              // Inicio do conte�do preexistente
               strATagGrupo + #13 +                       // Abertura de Tag do Grupo
               Trim(Self.Text) + #13 +                    // Novo Conteudo
               strFTagGrupo +                             // Fechamento da Tag do Grupo
               Copy(strTemp, intPosFim, Length(strTemp)); // T�rmino do conte�do preexistente
  end;

  // Restaura o conte�do original
  Self.Text := strTemp;

end;

// Retorna uma propriedade da String XML <RG> <ID>identidade do registro</ID> <P1>=propriedad1</P1> <P2>propriedade1</P2>... </RG>
Function TApplicationParamList.GetXml(ID: String; Propriedade: String; RG: String='') : String;
var
  a, b, c : String;
begin
  Result := '';
  if RG='' then
  begin
    // Buscando Registro
    a := '<RG> <ID>' + ID + '</ID>';
    b := '</RG>';
    c := GetValorTagB(a, b, Self.Text);
  end else
  begin
    // Registro recebido por parametro
    c := RG;
  end;
  if (Propriedade = 'RG') then
  begin
    // Retorna o registro
    Result := c;
  end else
  if c <> EmptyStr then
  begin
    // Retorna a Propriedade do Registro ID
    Result := GetValorTagL('<'+Propriedade+'>', '</'+Propriedade+'>', c);
  end;
end;

function TApplicationParamList.GetXml2(GR: string; ID: String; Propriedade: String; RG: String='') : String;
var
  strRetorno, strTemp, strGrupo, strATagGrupo, strFTagGrupo: string;
begin

  Result := '';

  // Tag de abertura e fechamento
  strATagGrupo := '<GR ID="' + GR + '">';
  strFTagGrupo := '</GR>';

  // Recebe o conte�do do grupo
  strGrupo := GetValorTagB(strATagGrupo, strFTagGrupo, Self.Text);
  strGrupo := GetValorTagL(strATagGrupo, strFTagGrupo, strGrupo);

  // Salva o conte�do atual
  strTemp := Self.Text;

  // Trabalha apenas com o grupo
  Self.Text := strGrupo;

  // Busca o cont�do requisitado
  strRetorno := GetXml(ID, Propriedade, RG);

  // Restaura o conte�do original
  Self.Text := strTemp;

  Result := strRetorno;

end;

// Retorna um array com os IDs dos grupos existentes
function TApplicationParamList.GetGrupos(): TStringArray;
var
  I, X: Integer;
  strATagGrupo: string;
begin

  strATagGrupo := '<GR ID="';

  for I := 0 to Self.Count -1 do
  begin

    X := Pos(strATagGrupo, Self[I]);
    if X > 0 then
    begin

      X := X + Length(strATagGrupo);

      SetLength(Result, Length(Result)+1);
      Result[High(Result)] := Copy(Self[I], X, LastDelimiter('"', Self[I]) - X);

    end;

  end;

end;

end.
