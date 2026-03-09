(*--------------------------------------------------------*)
(*   MYBUDGET.PAS                                         *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   07/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
program MyBudget;

uses
	Dos, JDUtils, Config, CrashOut, Db;

var
	pSysExitProc: Pointer;	{ Holds a reference to the system exit proc }
	aFileName: PathStr;
	dBase: TDatabase;

procedure AppExitProc; far;
{ This routine is called by the system when the application terminates }
begin
  LogEnd;
  ExitProc := pSysExitProc;
end;

(*************)
(*  M A I N  *)
(*************)

begin
	{ Configure the application }
  aFileName := PathCombine(ConfigInfo.LogsFolder, 'APP.LOG');
	SetLogFile(aFileName);

	pSysExitProc := ExitProc;
  ExitProc := @AppExitProc;

  LogStart;

  { Configure the database }
  dBase.Init(ConfigInfo.DatabaseFolder);

  { Load the UI }
  ReadLn;

  { Clean up }
  dBase.Done;
end.
