unit uFuncoesINI;

interface

uses

  uFormBase,

  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,

  IniFiles,

  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Effects,
  FMX.Controls.Presentation;

function getIniPath(): String;

procedure iniGravarString(group: string; key: string; value: string);
procedure iniGravarInteiro(group: string; key: string; value: Integer);
procedure iniGravarReal(group: string; key: string; value: Currency);
procedure iniGravarBoleano(group: string; key: string; value: Boolean);

function iniLerString(group: string; key: string): String;
function iniLerInteiro(group: string; key: string): Integer;
function iniLerReal(group: string; key: string): Currency;
function iniLerBooleano(group: string; key: string): Boolean;

implementation

function getIniPath(): String;
var
  origemBandoDeDados: string;
begin

  try

{$IFDEF ANDROID}
    origemBandoDeDados := System.IOUtils.TPath.Combine
      (System.IOUtils.TPath.GetDocumentsPath, 'PayGO.INI');
{$ENDIF}
{$IFDEF MSWINDOWS}
    origemBandoDeDados := System.IOUtils.TPath.Combine
      (System.SysUtils.GetCurrentDir, 'PayGO.INI');
{$ENDIF}
    Result := origemBandoDeDados;

  except
    Result := '';
  end;

end;

procedure iniGravarString(group: string; key: string; value: string);
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      arquivoIni.WriteString(group, key, value);
    except

    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

procedure iniGravarInteiro(group: string; key: string; value: Integer);
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      arquivoIni.WriteInteger(group, key, value);
    except

    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

procedure iniGravarReal(group: string; key: string; value: Currency);
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      arquivoIni.WriteFloat(group, key, value);
    except

    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

procedure iniGravarBoleano(group: string; key: string; value: Boolean);
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      arquivoIni.WriteBool(group, key, value);
    except

    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

function iniLerString(group: string; key: string): String;
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      Result := arquivoIni.ReadString(group, key, '');
    except
      Result := '';
    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

function iniLerInteiro(group: string; key: string): Integer;
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      Result := arquivoIni.ReadInteger(group, key, 0);
    except
      Result := 0;
    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

function iniLerReal(group: string; key: string): Currency;
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      Result := arquivoIni.ReadFloat(group, key, 0);
    except
      Result := 0;
    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

function iniLerBooleano(group: string; key: string): Boolean;
var
  caminhoIni: String;
  arquivoIni: TIniFile;
begin

  caminhoIni := getIniPath();
  arquivoIni := TIniFile.Create(caminhoIni);

  try

    try
      Result := arquivoIni.ReadBool(group, key, false);
    except
      Result := false;
    end;

  finally
    FreeAndNil(arquivoIni);
  end;

end;

end.
