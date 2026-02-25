{==========================================================}
{ logfile.pas                                              }
{                                                          }
{ Created: 10/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 10/02/2026 - Initial Version                             }
{==========================================================}

{ Defines the class used to write entries to the applicatoin
	log file }

unit LogFile;

interface

uses
	Core;

procedure LogDebug(const message: String);
procedure LogInfo(const message: String);
procedure LogWarning(const message: String);
procedure LogError(const message: String);
procedure LogFatal(const message: String);

procedure LogStart;
procedure LogEnd;

var
	LogFileName: TFileName;

{******************}
{* Implementation *}
{******************}
implementation

uses
	Crt, Dos, DateUtil;

const
  LOG_DEBUG_MSG = 1;
  LOG_INFO_MSG  = 2;
  LOG_WARN_MSG  = 3;
  LOG_ERROR_MSG = 4;
  LOG_FATAL_MSG = 5;

procedure WriteLine(const line: String);
var
	outFile: Text;
begin
  Assign(outFile, LogFileName);

  if not FileExists(LogFileName) then
  	Rewrite(outFile)
  else
  	Append(outFile);

  WriteLn(outFile, line);

  Close(outFile);
end;

procedure WriteMessage(const level: Integer; const msg: String);
var
	typeStr,
  line: String;
begin
  case level of
  	LOG_DEBUG_MSG: typeStr := 'DEBUG';
  	LOG_INFO_MSG: typeStr  := 'INFO ';
  	LOG_WARN_MSG: typeStr  := 'WARN ';
  	LOG_ERROR_MSG: typeStr := 'ERROR';
  	LOG_FATAL_MSG: typeStr := 'FATAL';
  else
  	typeStr := '*****';
  end;

  line := DateTimeStr + ' | ' + typestr + ' | ' + msg;
  WriteLine(line);
end;

{ ========== Public Interface ========== }

procedure LogDebug(const message: String);
begin
  WriteMessage(LOG_DEBUG_MSG, message);
end;

procedure LogInfo(const message: String);
begin
  WriteMessage(LOG_INFO_MSG, message);
end;

procedure LogWarning(const message: String);
begin
  WriteMessage(LOG_WARN_MSG, message);
end;

procedure LogError(const message: String);
begin
  WriteMessage(LOG_ERROR_MSG, message);
end;

procedure LogFatal(const message: String);
begin
  WriteMessage(LOG_FATAL_MSG, message);

  ClrScr;
  WriteLn('*** ' + message + '***');
  WriteLn;
  WriteLn('Press any key to exit.');
end;

procedure LogStart;
var
	line: String;
begin
	line := DateTimeStr + ' | === Start ===============================';
  WriteLine(line);
end;

procedure LogEnd;
var
	line: String;
begin
	line := DateTimeStr + ' | --- End ---------------------------------';
  WriteLine(line);
end;

end.
