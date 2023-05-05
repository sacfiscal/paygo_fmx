unit uDataModule;

interface

uses

  uFuncoesGerais,

  System.IOUtils,

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

  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.FMXUI.Wait,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.Stan.StorageBin,
  FireDAC.Comp.UI, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet;

type
  TDM = class(TDataModule)
    PayGODB: TFDConnection;
    PayGO_QryAux: TFDQuery;
    PayGO_UpdAux: TFDUpdateSQL;
    WaitCursor: TFDGUIxWaitCursor;
    StorageBinLink: TFDStanStorageBinLink;
    SQLiteDriverLink: TFDPhysSQLiteDriverLink;
    procedure PayGODBBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

uses
  uFuncoesDB;

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

procedure TDM.PayGODBBeforeConnect(Sender: TObject);
begin

  uFuncoesGerais.databasePath := uFuncoesDB.obterOrigemBancoDeDados();
  PayGODB.Params.Database := uFuncoesGerais.databasePath;

end;

end.
