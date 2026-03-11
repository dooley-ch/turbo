(*--------------------------------------------------------*)
(*   CONFIG.PAS                                           *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   09/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
{ The Config unit provides access to the application
  configuration information stored in the application's
	INI file (located in the same folder as the application) }

unit Config;

interface

type
	TConfigInfo = record
  	ImportBankFolder,
    ImportCardFolder,
    DatabaseFolder,
    LogsFolder,
		TempFolder: String;
  end;

var
	ConfigInfo: TConfigInfo;

implementation

uses
	Dos, TPString, JDUtils, JDString;

{$I SHARED.INC}

var
	iniFileName, vValue, errMsgStr: String;
  iniFile: TIniFile;
  appName: ComStr;
begin
	appName := ParamStr(0);
	iniFileName := ForceExtension(ParamStr(0), 'INI');

  if not FileExists(iniFileName) then
  begin
    LogFatal('Configuration file not found: ' + iniFileName);
  	Halt(ERR_CONFIG_FILE_NOT_FOUND);
  end;

  iniFile.Init(iniFileName);

  iniFile.GetString('Folders', 'DB', vValue);
  ConfigInfo.DatabaseFolder := vValue;

  iniFile.GetString('Folders', 'Temp', vValue);
  ConfigInfo.TempFolder := vValue;

  iniFile.GetString('Folders', 'ImportCards', vValue);
  ConfigInfo.ImportCardFolder := vValue;

  iniFile.GetString('Folders', 'ImportBanks', vValue);
  ConfigInfo.ImportBankFolder := vValue;

  iniFile.GetString('Folders', 'Logs', vValue);
  ConfigInfo.LogsFolder := vValue;

  iniFile.Done;
end.
