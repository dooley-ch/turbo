{==========================================================}
{ config.pas                                               }
{                                                          }
{ Created: 22/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 22/02/2026 - Initial Version                             }
{==========================================================}

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
	Core, IniFile, ErrMSg, LogFile;

var
	iniFileName, vValue, errMsgStr: String;
  pFile: PIniFile;
begin
	iniFileName := SwapFileExt(ParamStr(0), '.INI');

  if not FileExists(iniFileName) then
  begin
    errMsgStr := GetErrorString(ConfigFileNotFoundError);
    LogFatal(errMsgStr);

  	Halt(ConfigFileNotFoundError);
  end;

  New(pFile, Init(iniFileName));

  pFile^.GetString('Folders', 'DB', vValue);
  ConfigInfo.DatabaseFolder := vValue;

  pFile^.GetString('Folders', 'Temp', vValue);
  ConfigInfo.TempFolder := vValue;

  pFile^.GetString('Folders', 'ImportCards', vValue);
  ConfigInfo.ImportCardFolder := vValue;

  pFile^.GetString('Folders', 'ImportBanks', vValue);
  ConfigInfo.ImportBankFolder := vValue;

  pFile^.GetString('Folders', 'Logs', vValue);
  ConfigInfo.LogsFolder := vValue;

  Dispose(pFile, Done);
end.
