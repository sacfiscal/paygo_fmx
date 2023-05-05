object DM: TDM
  Height = 756
  Width = 392
  object PayGODB: TFDConnection
    Params.Strings = (
      'Database=D:\sacfiscal\2023\PayGO\PayGO.db'
      'DriverID=PayGoSQLite')
    LoginPrompt = False
    BeforeConnect = PayGODBBeforeConnect
    Left = 56
    Top = 40
  end
  object PayGO_QryAux: TFDQuery
    Connection = PayGODB
    FormatOptions.AssignedValues = [fvSE2Null, fvStrsTrim2Len]
    FormatOptions.StrsEmpty2Null = True
    FormatOptions.StrsTrim2Len = True
    UpdateObject = PayGO_UpdAux
    SQL.Strings = (
      'SELECT * FROM EMITENTE')
    Left = 56
    Top = 96
  end
  object PayGO_UpdAux: TFDUpdateSQL
    Connection = PayGODB
    Left = 56
    Top = 152
  end
  object WaitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 56
    Top = 208
  end
  object StorageBinLink: TFDStanStorageBinLink
    Left = 56
    Top = 264
  end
  object SQLiteDriverLink: TFDPhysSQLiteDriverLink
    DriverID = 'PayGoSQLite'
    Left = 56
    Top = 320
  end
end
