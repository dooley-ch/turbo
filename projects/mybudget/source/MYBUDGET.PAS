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
  catRec: TCategory;
  subCatRec: TSubCategory;
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
(*
  catRec.Init;
  catRec.Name := 'Travel';
  catRec.Comment := 'No Comment';
  dBase.AddCategory(catRec);


  subCatRec.Init;
  subCatRec.Name := 'Apples & Bananas';
  subCatRec.Comment := 'No Comment';
  subCatRec.CategoryId := 1;

  if not dBase.AddSubCategory(subCatRec) then
  	begin
    	WriteLn('Failed to insert Sub Category: ', errCode);
    end;
*)
  subCatRec.Init;
  dBase.GetSubCategory(1, subCatRec);

  subCatRec.Comment := 'New Comment';
  dBase.UpdateCategory(subCatRec);

  ReadLn;

  { Clean up }
  dBase.Done;
end.
