{==========================================================}
{ mybudget.pas                                             }
{                                                          }
{ Created: 24/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 24/02/2026 - Initial Version                             }
{==========================================================}
unit DB;

interface

uses
	TAccess, TAHigh;

{$I MYBUDGET.TYP }

function InitDb: Boolean;

implementation

uses
	Core, Config, LogFile, ErrMsg;

const
	FVersionTbl: String = 'VERSION.DAT';

function CreateTable(var hFile: DataFile;
											fileName: String; recLen: word): Boolean;
begin
	CreateTable := True;

  MakeFile(hFile, fileName, recLen);
  if OK then
  begin
  	LogInfo('Database file created: ' + fileName);
    Exit
  end;

  LogError('Failed to create database file: ' + fileName);
	CreateTable := False;
end;

function InitDb: Boolean;
var
	fileName: String;
  dbFile: DataFile;
  ndxFile: IndexFile;
begin
	InitDb := True;

	(* Version Table *)
  fileName := PathCombine(ConfigInfo.DatabaseFolder, FVersionTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TVersionRecord)) then
    	Halt(DbInitError);
  end;

end;

end.