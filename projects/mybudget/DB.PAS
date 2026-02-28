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

type
	PDatabase = ^TDatabase;
	TDatabase = object
  private
  	FDbFolder: String;

    FConfig,
		FGenerator,
		FStatement,
		FImportTrans: DataFile;

		FConfigPK,
		FConfigKey,
		FGeneratorPK,
		FGeneratorTable,
		FStatementPK,
		FStatementWorkflow,
		FImportTransPK,
    FImportTransStmt,
		FImportTransWorkflow: IndexFile;

    procedure OpenTable(var hFile: DataFile; fileName: String; recLen: word);
		procedure OpenNdx(var hFile: IndexFile; fileName: String; keyLen, S: Byte);
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
	{ File Names }
  File_Config				 : String[12] = 'MYBUD100.DAT';
  File_Config_PK_NDX : String[12] = 'MYBUD101.NDX';
  File_Config_Key_NDX: String[12] = 'MYBUD102.NDX';

  File_Generator					: String[12] = 'MYBUD200.DAT';
  File_Generator_PK_NDX 	: String[12] = 'MYBUD201.NDX';
  File_Generator_Table_NDX: String[12] = 'MYBUD202.NDX';

  File_Statement						 : String[12] = 'MYBUD300.DAT';
  File_Statement_PK_NDX			 : String[12] = 'MYBUD301.NDX';
  File_Statement_Workflow_NDX: String[12] = 'MYBUD302.NDX';

  File_ImportTrans						 : String[12] = 'MYBUD400.DAT';
  File_ImportTrans_PK_NDX			 : String[12] = 'MYBUD401.NDX';
  File_ImportTrans_Workflow_NDX: String[12] = 'MYBUD402.NDX';
  File_ImportTrans_Stmt_NDX		 : String[12] = 'MYBUD403.NDX';

  { Record types }
{$I DB.TYP}

{ TDatabase ----------------------------------------------}

procedure TDatabase.OpenTable(var hFile: DataFile; fileName: String; recLen: word);
begin
	OpenFile(hFile, fileName, recLen);
  If not OK then
  	begin
  		MakeFile(hFile, fileName, recLen);
  		if OK then
  			LogInfo('Database file created: ' + JustFileName(fileName));
      (* TODO - Exit if can't create table *)
    end;
end;

procedure TDatabase.OpenNdx(var hFile: IndexFile; fileName: String; keyLen, S: Byte);
begin
	OpenIndex(hFile, fileName, keyLen, S);
  if not OK then
  	begin
    	MakeIndex(hFile, fileName, keyLen, S);
  		if OK then
  			LogInfo('Database index created: ' + JustFileName(fileName));
      (* TODO - Exit if can't create index *)
    end;
end;

constructor TDatabase.Init(const dbFolder: String);
var
	fileName: String;
begin
	FDbFolder := dbFolder;

  { Open config table }
	fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Config);
  OpenTable(FConfig, fileName, SizeOf(TConfigRecord));
	fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Config_PK_NDX);
  OpenNdx(FConfigPK, fileName, SizeOf(TIdField) - 1, 0);
  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Config_Key_NDX);
  OpenNdx(FConfigKey, fileName, SizeOf(TNameField) - 1, 0);

  { Open Generator table }
	fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Generator);
  OpenTable(FGenerator, fileName, SizeOf(TGenKey));

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Generator_PK_NDX);
  OpenNdx(FGeneratorPK, fileName, SizeOf(TIdField) - 1, 0);

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Generator_Table_NDX);
  OpenNdx(FGeneratorTable, fileName, SizeOf(TNameField) - 1, 0);

  { Open Statement Table }
  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Statement);
  OpenTable(FStatement, fileName, SizeOf(TImpStmt));

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Statement_PK_NDX);
  OpenNdx(FStatementPK, fileName, SizeOf(TIdField) - 1, 0);

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_Statement_Workflow_NDX);
  OpenNdx(FStatementWorkflow, fileName, SizeOf(TWorkflowField) - 1, 1);

  { Open Transaction Table }
  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_ImportTrans);
  OpenTable(FImportTrans, fileName, SizeOf(TImpTrans));

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_ImportTrans_PK_NDX);
  OpenNdx(FImportTransPK, fileName, SizeOf(TIdField) - 1, 0);

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_ImportTrans_Workflow_NDX);
  OpenNdx(FImportTransWorkflow, fileName, SizeOf(TWorkflowField) - 1, 1);

  fileName := PathCombine(ConfigInfo.DatabaseFolder, File_ImportTrans_Stmt_NDX);
  OpenNdx(FImportTransStmt, fileName, SizeOf(TIdField) - 1, 1);

	{ Set up index handling }
  InitIndex;
end;

destructor TDatabase.Done;
begin
	{ Close the tables }
	CloseIndex(FConfigPK);
	CloseIndex(FConfigKey);
	CloseIndex(FGeneratorPK);
	CloseIndex(FGeneratorTable);
	CloseIndex(FStatementPK);
	CloseIndex(FStatementWorkflow);
	CloseIndex(FImportTransPK);
  CloseIndex(FImportTransStmt);
	CloseIndex(FImportTransWorkflow);

  CloseFile(FConfig);
	CloseFile(FGenerator);
	CloseFile(FStatement);
	CloseFile(FImportTrans);
end;

{ FinaliseDb ---------------------------------------------}

procedure FinaliseDb;
begin
	Dispose(pData, Done);
end;

{ InitDb -------------------------------------------------}

function InitDb: Boolean;
begin
	InitDb := True;
  New(pData, Init(ConfigInfo.DatabaseFolder));
end;

end.