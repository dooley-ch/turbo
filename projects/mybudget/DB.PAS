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

type
	PDatabase = ^TDatabase;
	TDatabase = object
  private
  	FDbFolder: String;

    hVersion,
    hGenerator,
    hBankStmt,
    hBankTrans,
    hCardStmt,
    hCardTrans: DataFile;

    hGeneratorPK,
    hBankStmtPK,
    hBankTransPK,
    hBankTransStmtFK,
    hCardStmtPK,
    hCardTransPK,
    hCardTransStmtFK: IndexFile;

    procedure OpenTable(var hFile: DataFile; fileName: String; recLen: word);
		procedure OpenIndex(var hFile: IndexFile; fileName: String; keyLen, S: Byte);
  public
  	constructor init(const dbFolder: String);
    destructor Done; virtual;
  end;

function InitDb: Boolean;
procedure FinaliseDb;

var
	pData: PDatabase;

(******************)
(* Implementation *)
(******************)
implementation

uses
	Core, Config, LogFile, ErrMsg, TPString;

const
	VersionTbl: String = 'VERSION.DAT';
  GeneratorTbl: String = 'GENIDS.DAT';
  GeneratorPKNdx: String = 'GENIDS.IPK';
  BankStmtTbl: String = 'BANKSTMT.DAT';
  BankStmtPKNdx: String = 'BANKSTMT.IPK';
	BankTransTbl: String = 'BANKTRNS.DAT';
  BankTransPKNdx: String = 'BANKTRNS.IPK';
  BankTransFKStmtNdx: String = 'BKTRNS01.IFK';
  CardStmtTbl: String = 'CARDSTMT.DAT';
  CardStmtPKNdx: String = 'CARDSTMT.IPK';
	CardTransTbl: String = 'CARDTRNS.DAT';
  CardTransPKNdx: String = 'CARDTRNS.IPK';
  CardTransFKStmtNdx: String = 'CDTRNS01.IFK';

{ TDatabase ----------------------------------------------}

procedure TDatabase.OpenTable(var hFile: DataFile; fileName: String; recLen: word);
begin
end;

procedure TDatabase.OpenIndex(var hFile: IndexFile; fileName: String; keyLen, S: Byte);
begin
end;

constructor TDatabase.Init(const dbFolder: String);
var
	fileName: String;
begin
	FDbFolder := dbFolder;

	{ Open the tables }
  fileName := PathCombine(ConfigInfo.DatabaseFolder, VersionTbl);
  OpenTable(hVersion, fileName, SizeOf(TVersionRecord));

	fileName := PathCombine(ConfigInfo.DatabaseFolder, GeneratorTbl);
  OpenTable(hGenerator, fileName, SizeOf(TGeneratorRecord));
	fileName := PathCombine(ConfigInfo.DatabaseFolder, GeneratorPKNdx);
  OpenIndex(hGeneratorPK, fileName, SizeOf(TIdField) - 1, 0);

	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankStmtTbl);
  OpenTable(hBankStmt, fileName, SizeOf(TBankStatementRecord));
	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankStmtPKNdx);
  OpenIndex(hBankStmtPK, fileName, SizeOf(TIdField) - 1, 0);

	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankTransTbl);
  OpenTable(hBankTrans, fileName, SizeOf(TBankTransactionRecord));
	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankTransPKNdx);
  OpenIndex(hBankTransPK, fileName, SizeOf(TIdField) - 1, 0);
	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankTransFKStmtNdx);
  OpenIndex(hBankTransStmtFK, fileName, SizeOf(TIdField) - 1, 0);

	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardStmtTbl);
  OpenTable(hCardStmt, fileName, SizeOf(TCreditCardStatementRecord));
	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardStmtPKNdx);
  OpenIndex(hCardStmtPK, fileName, SizeOf(TIdField) - 1, 0);

	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardTransTbl);
  OpenTable(hCardTrans, fileName, SizeOf(TCreditCartTransactionRecord));
	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardTransPKNdx);
  OpenIndex(hCardTransPK, fileName, SizeOf(TIdField) - 1, 0);
	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardTransFKStmtNdx);
  OpenIndex(hCardTransStmtFK, fileName, SizeOf(TIdField) - 1, 0);

	{ Set up index handling }
  InitIndex;
end;

destructor TDatabase.Done;
begin
	{ Close the tables }
end;

{ FinaliseDb ---------------------------------------------}

procedure FinaliseDb;
begin
	Dispose(pData, Done);
end;

{ InitDb -------------------------------------------------}

function CreateTable(var hFile: DataFile;
											fileName: String; recLen: word): Boolean;
begin
	CreateTable := True;

  MakeFile(hFile, fileName, recLen);
  if OK then
  begin
  	LogInfo('Database file created: ' + JustFileName(fileName));
    Exit
  end;

  LogError('Failed to create database file: ' + JustFileName(fileName));
	CreateTable := False;
end;

function CreateIndex(var hFile: IndexFile; fileName: String;
											keyLen, S: Byte): Boolean;
begin
	CreateIndex := True;

  MakeIndex(hFile, fileName, keyLen, S);
  if OK then
  begin
  	LogInfo('Database index created: ' + JustFileName(fileName));
    Exit
  end;

  LogError('Failed to create database index: ' + JustFileName(fileName));
	CreateIndex := False;
end;

function InitDb: Boolean;
var
	fileName: String;
  dbFile: DataFile;
  ndxFile: IndexFile;
begin
	InitDb := True;

	(* Version Table *)
  fileName := PathCombine(ConfigInfo.DatabaseFolder, VersionTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TVersionRecord)) then
    	Halt(DbInitError);
  end;

  (* Generator Table *)
	fileName := PathCombine(ConfigInfo.DatabaseFolder, GeneratorTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TGeneratorRecord)) then
    	Halt(DbInitError);
    CloseFile(dbFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, GeneratorPKNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TNameField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

  (* Bank Statement Table *)
	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankStmtTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TBankStatementRecord)) then
    	Halt(DbInitError);
    CloseFile(dbFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankStmtPKNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TIdField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

  (* Bank Transaction Table *)
	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankTransTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TBankTransactionRecord)) then
    	Halt(DbInitError);
    CloseFile(dbFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankTransPKNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TIdField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, BankTransFKStmtNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TIdField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

  (* Credit Card Statement Table *)
	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardStmtTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TCreditCardStatementRecord)) then
    	Halt(DbInitError);
    CloseFile(dbFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardStmtPKNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TIdField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

  (* Card Transaction Table *)
	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardTransTbl);
  if not FileExists(fileName) then
  begin
  	if not CreateTable(dbFile, fileName, SizeOf(TCreditCartTransactionRecord)) then
    	Halt(DbInitError);
    CloseFile(dbFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardTransPKNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TIdField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

	fileName := PathCombine(ConfigInfo.DatabaseFolder, CardTransFKStmtNdx);
  if not FileExists(fileName) then
  begin
  	if not CreateIndex(ndxFile, fileName, SizeOf(TIdField) - 1, 0) then
    	Halt(DbInitError);
    CloseIndex(ndxFile);
  end;

  New(pData, Init(ConfigInfo.DatabaseFolder));
end;

end.