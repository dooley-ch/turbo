{==========================================================}
{ mybudget.pas                                             }
{                                                          }
{ Created: 08/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 08/02/2026 - Initial Version                             }
{==========================================================}

program MyBudget;

uses
	Crt, Core, Config, LogFile, ErrMsg, ImpFile, Db;

const
  BANK_FILE: String = 'C:\PROJECTS\MYBUDGET\DATA\IMPORT\BANK\01-2025.CSV';
  CARD_FILE: String = 'C:\PROJECTS\MYBUDGET\DATA\IMPORT\CARD\01-2025.CSV';

{***********************}
{* Custom Exit Routine *}
{***********************}
var
	sysExitProc: Pointer;	{ Holds a reference to the system exit proc }
  vFileName: String;
  hBank: PBankFile;
  hCard: PCreditCardFile;

{$F+}procedure AppExitProc;{$F-}
{ This routine is called by the system when
  the application terminates }
begin
  LogEnd;
  ExitProc := sysExitProc;
end;

{***************}
{* Main        *}
{***************}
begin
  { Set up the exit routine }
	sysExitProc := ExitProc;
  ExitProc := @AppExitProc;

	{ Configure the application }
  vFileName := PathCombine(ConfigInfo.LogsFolder, 'APP.LOG');
  LogFileName := vFileName;

  { Log start up}
  LogStart;

  { Init the database }
  InitDb;

{  New(hBank, Init(BANK_FILE));
  New(hCard, Init(CARD_FILE));

  Dispose(hBank);
  Dispose(hCard); }

  { Run the application }
  ReadLn;
end.