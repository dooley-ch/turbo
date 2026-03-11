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
	Dos, JDUtils, Config, CrashOut, Database, Classes;

var
	pSysExitProc: Pointer;	{ Holds a reference to the system exit proc }
	aFileName: PathStr;
	dBase: TDatabase;
  rec: TCategory;
  errCode: Byte;

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
(*  rec.Init;
  rec.Name := 'Food & Drink';
  rec.Comment := 'Not Comment';

  if dBase.AddCategory(rec, errCode) then
  	WriteLn('Category added ', rec.Id);

  if dBase.GetCategoryByName('Food & Drink', rec, errCode) then
  	WriteLn('Category ', rec.Name);

  rec.Comment := 'New Comment';

  if dBase.UpdateCategory(rec, errCode) then
  	WriteLn('Record updated'); *)

  dBase.DeleteCategory(1);

  if Not dBase.GetCategoryByName('Food & Drink', rec, errCode) then
  	WriteLn('Failed to load record ', errCode);

  ReadLn;

  { Clean up }
  dBase.Done;
end.
