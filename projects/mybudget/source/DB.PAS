(*--------------------------------------------------------*)
(*   DB.PAS                                               *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   06/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit Db;

interface

uses
	Filer, BTBase, BTIsBase,
	Dos, Objects;

type
	PDatabase = ^TDatabase;
  TDatabase = object(TObject)
  private
  	FPPS: LongInt;
    FDataFolder: PathStr;

    pVersion,
		pGenerator,
		pCategory,
		pSubCategory,
		pImpStatement,
		pImpTransaction,
		pBudget,
		pBudgetItem,
		pTransaction,
		pAllocation: IsamFileBlockPtr;

    procedure CreateVersion;
    procedure CreateGeneratorId;
    procedure CreateCategory;
    procedure CreateSubCategory;
    procedure CreateImpStatement;
    procedure CreateImpTransaction;
    procedure CreateTransaction;
    procedure CreateAllocation;
    procedure CreateBudget;
    procedure CreateBudgetItem;

    function GetNextId(const tableName: String): Byte;
		procedure DoCrashExit(const exitCode: Byte;
													const errorMessage: String);
  public
  	constructor Init(const folderName: PathStr);
    destructor Done; virtual;
  end;

implementation

uses
	IsamTool, DbUtils, CrashOut, JDString, JDDates, JDUtils;

const
	(* Database Version Supported *)
  DB_VERSION_MAJOR: Byte = 1;
  DB_VERSION_MINOR: Byte = 0;
  DB_VERSION_BUILD: Byte = 1;

	(* Table Names *)
  Version_Table        : NameStr = 'VERSION';
  Generator_Table      : NameStr = 'GENID';
  Imp_Statement_Table  : NameStr = 'IMPSTMT';
	Imp_Transaction_Table: NameStr = 'IMPTRANS';
  Category_Table       : NameStr = 'CATEGORY';
  Sub_Category_Table   : NameStr = 'SUBCAT';
  Budget_Table         : NameStr = 'BUDGET';
  Budget_Item_Table    : NameStr = 'BUDITEM';
  Allocation_Table     : NameStr = 'ALLOC';
  Transaction_Table    : NameStr = 'TRANSACT';

  (* Index IDs *)
  PK_Index: Byte = 1;
  FK_Index: Byte = 2;

  (* Index Key Lengths *)
  PK_Index_Len: Byte = 2;
  FK_Index_Len: Byte = 2;
  FK_Index_Name_Len: Byte = 30;

  (* Id Keys *)
  ID_ImpStatement  : NameStr = 'IMP_STATEMENT';
	ID_ImpTransaction: NameStr = 'IMP_TRANSACTION';
  ID_Category      : NameStr = 'CATEGORY';
  ID_Sub_Category  : NameStr = 'SUB_CATEGORY';
  ID_Budget        : NameStr = 'BUDGET';
  ID_Budget_Item   : NameStr = 'BUDGET_ITEM';
  ID_Allocation    : NameStr = 'ALLOCATION';
  ID_Transaction	 : NameStr = 'TRANSACTION';

{$I SHARED.INC}

type
	TVersionRecord = record
  	Ctrl: LongInt;
  	Major,
    Minor,
    Build: Byte;
    Comment: TField30S;
    Created: LongInt;
  end;

  TIdGeneratorRecord = record
  	Ctrl: LongInt;
  	Key: TField20S;
    Value: Word;
  	Created,
    Updated: LongInt;
  end;

  TImpTransRecord = record
		Ctrl: LongInt;
    Id: Word;
		BookingDate: Word;
    Description: TMemoField;
    CreditAmount,
    DebitAmount: LongInt;
    StmtId: Word;
    Workflow: TFlagField;
  	Created,
    Updated: LongInt;
	end;

  TImpStmtRecord = record
		Ctrl: LongInt;
    Id: Word;
    FromDate,
    ToDate: Word;
    Account: TField15S;
    Workflow: TFlagField;
  	Created,
    Updated: LongInt;
	end;

  TCategoryRecord = record
		Ctrl: LongInt;
    Id: Word;
    Name: TNameField;
    Description: TShortMemoField;
  	Created,
    Updated: LongInt;
  end;

  TSubCategoryRecord = record
		Ctrl: LongInt;
    Id: Word;
    Name: TNameField;
    Description: TShortMemoField;
    CategoryId: Word;
  	Created,
    Updated: LongInt;
  end;

  TTransactionRecord = record
		Ctrl: LongInt;
    Id: Word;
		BookingDate: Word;
    Description: TMemoField;
    CreditAmount,
    DebitAmount: LongInt;
    Report:TFlagField;
    SubCatId: Word;
  	Created,
    Updated: LongInt;
	end;

  TAllocationRecord = record
		Ctrl: LongInt;
    Id,
		ImpTransId,
		TransId: Word;
    StmtType: TFlagField;
    Comment: TShortMemoField;
  	Created,
    Updated: LongInt;
	end;

  TBudgetRecord = record
		Ctrl: LongInt;
    Id,
    FromDate,
    ToDate: Word;
    Title: TField30S;
    Comment: TShortMemoField;
		Workflow: TFlagField;
  	Created,
    Updated: LongInt;
	end;

  TBudgetItemRecord = record
		Ctrl: LongInt;
    Id,
    Period,
    FromDate,
    ToDate: Word;
    BudgetId,
    SubCatId: Word;
    BudgetedAmount,
    ActualAmount: LongInt;
    Comment: TShortMemoField;
		Workflow: TFlagField;
  	Created,
    Updated: LongInt;
	end;

(*************)
(* TDatabase *)
(*************)

constructor TDatabase.Init(const folderName: PathStr);
var
	fileBaseName: PathStr;
begin
	inherited Init;

  FPPS := BTInitIsam(NoNet, MinimizeUseOfNormalHeap, 0);
  ExtendHandles(50);

  FDataFolder := folderName;

  (* Create the tables, if they don't exist *)
  CreateVersion;
  CreateGeneratorId;
	CreateCategory;
  CreateSubCategory;
  CreateImpStatement;
  CreateImpTransaction;
  CreateTransaction;
	CreateAllocation;
  CreateBudget;
  CreateBudgetItem;

  (* Open the tables *)
  fileBaseName := ConCat(AddBackSlash(FDataFolder), Version_Table);
  BTOpenFileBlock(pVersion, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Version_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Generator_Table);
  BTOpenFileBlock(pGenerator, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Generator_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Category_Table);
  BTOpenFileBlock(pCategory, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
									'Failed to open file: ' + Category_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Sub_Category_Table);
  BTOpenFileBlock(pSubCategory, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Sub_Category_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Imp_Statement_Table);
  BTOpenFileBlock(pImpStatement, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Imp_Statement_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Imp_Transaction_Table);
  BTOpenFileBlock(pImpTransaction, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Imp_Transaction_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Budget_Table);
  BTOpenFileBlock(pBudget, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Budget_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Budget_Item_Table);
  BTOpenFileBlock(pBudgetItem, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Budget_Item_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Transaction_Table);
  BTOpenFileBlock(pTransaction, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Transaction_Table);

  fileBaseName := ConCat(AddBackSlash(FDataFolder), Allocation_Table);
  BTOpenFileBlock(pAllocation, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_OPEN_TABLE,
								'Failed to open file: ' + Allocation_Table);
end;

destructor TDatabase.Done;
begin
	(* Close tables *)
  BTFlushAllFileBlocks;
  BTCloseAllFileBlocks;

  (* Close down BTree Engine *)
	BTExitIsam;

	inherited Done;
end;

Procedure TDatabase.DoCrashExit(const exitCode: Byte;
																const errorMessage: String);
var
  errorClass, errorNumber: Integer;
  clsStr, numStr: String;
begin
	errorClass := BTIsamErrorClass;
  errorNumber := IsamError;

  Str(errorClass: 1, clsStr);
  Str(errorNumber: 4, numStr);

  LogFatal(errorMessage + ' [' + clsStr + ', ' + numStr + ']');
  Crash(exitCode);
end;

function TDatabase.GetNextId(const tableName: String): Byte;
var
	recId: LongInt;
  rec: TIdGeneratorRecord;
  stamp: TTimeStamp;
  id: Byte;
begin
	recId := 0;
  FillChar(rec, SizeOf(TIdGeneratorRecord), #0);
  stamp.Init;

	BTClearKey(pGenerator, PK_Index);

  BTFindKey(pGenerator, PK_Index, recId, tableName);
  if (IsamError = 10200) or (recId = 0) then
  	DoCrashExit(ERR_GEN_KEY_MISSING,
								'Failed to find ID key: ' + tableName);

  BTGetRec(pGenerator, recId, rec, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_LOAD_REC,
								'Failed to load ID key record: ' + tableName);

  id := rec.Value;
  Inc(id);

  rec.Value := id;
  rec.Updated := stamp.Pack;

  BTPutRec(pGenerator, recId, rec, False);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_UPDATE_REC,
								'Failed to update ID key record: ' + tableName);
end;

procedure TDatabase.CreateVersion;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
  rec: TVersionRecord;
  stamp: TTimeStamp;
  pFile: IsamFileBlockPtr;
  refId: LongInt;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Version_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  BTCreateFileBlock(fileBaseName, SizeOf(TVersionRecord), 0, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Version_Table);

  LogInfo('Created file: ' + Version_Table);

  (* Create the version number entry *)
  stamp.Init;

  FillChar(rec, SizeOf(TVersionRecord), #0);
  with rec do
  	begin
    	Major := DB_VERSION_MAJOR;
      Minor := DB_VERSION_MINOR;
      Build := DB_VERSION_BUILD;
      Created := stamp.Pack;
    end;

  BTOpenFileBlock(pFile, fileBaseName, False, False, False, False);
  if IsamOK then
  	begin
    	BTAddRec(pFile, refId, rec);
      if not IsamOK then
      	DoCrashExit(ERR_FAILED_TO_ADD_RECORD,
										'Failed to insert database version number');

    	BTCloseFileBlock(pFile);
    end;
end;

procedure TDatabase.CreateGeneratorId;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
  rec: TVersionRecord;
  stamp: TTimeStamp;
  pFile: IsamFileBlockPtr;
  refId: LongInt;
  index: Byte;

  procedure AddIdGenertor(const key: String);
  var
  	rec: TIdGeneratorRecord;
    stamp: TTimeStamp;
    refId: LongInt;
  begin
  	stamp.Init;
  	FillChar(rec, SizeOf(TIdGeneratorRecord), #0);

		with rec do
    	begin
      	Key := key;
        Value := 0;
        Created := stamp.Pack;
        Updated := stamp.Pack;
      end;

    BTAddRec(pFile, refId, rec);
    if not IsamOK then
    	DoCrashExit(ERR_FAILED_TO_ADD_RECORD,
									'Failed to ID Record for: ' + Key);

    BTAddKey(pFile, PK_Index, refId, key);
    if not IsamOK then
    	DoCrashExit(ERR_FAILED_TO_ADD_KEY,
										'Failed to ID Record index for: ' + Key);
	end;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Generator_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := FK_Index_Name_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TIdGeneratorRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Generator_Table);

  LogInfo('Created file: ' + Generator_Table);

  (* Create a zero record for each id *)
  BTOpenFileBlock(pFile, fileBaseName, False, False, False, False);
  if IsamOK then
  	begin
    	AddIdGenertor(ID_ImpStatement);
      AddIdGenertor(ID_ImpTransaction);
      AddIdGenertor(ID_Category);
      AddIdGenertor(ID_Sub_Category);
      AddIdGenertor(ID_Budget);
      AddIdGenertor(ID_Budget_Item);
      AddIdGenertor(ID_Allocation);
      AddIdGenertor(ID_Transaction);

  		BTCloseFileBlock(pFile);
  	end
  else
  	DoCrashExit(ERR_FAILED_TO_INSERT_SEED_DATA,
									'Failed to open table and create seed ID data');
end;

procedure TDatabase.CreateCategory;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Category_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TCategoryRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Category_Table);

  LogInfo('Created file: ' + Category_Table);
end;

procedure TDatabase.CreateSubCategory;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Sub_Category_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TSubCategoryRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Sub_Category_Table);

  LogInfo('Created file: ' + Sub_Category_Table);
end;

procedure TDatabase.CreateImpStatement;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Imp_Statement_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TImpStmtRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Imp_Statement_Table);

  LogInfo('Created file: ' + Imp_Statement_Table);
end;

procedure TDatabase.CreateImpTransaction;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Imp_Transaction_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TImpTransRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Imp_Transaction_Table);

  LogInfo('Created file: ' + Imp_Transaction_Table);
end;

procedure TDatabase.CreateTransaction;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Transaction_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TTransactionRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Transaction_Table);

	LogInfo('Created file: ' + Transaction_Table);
end;

procedure TDatabase.CreateBudget;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Budget_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TBudgetRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Budget_Table);

	LogInfo('Created file: ' + Budget_Table);
end;

procedure TDatabase.CreateBudgetItem;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Budget_Item_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TBudgetItemRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Budget_Item_Table);

	LogInfo('Created file: ' + Budget_Item_Table);
end;

procedure TDatabase.CreateAllocation;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);
  IsamClearOK;

	fileBaseName := ConCat(AddBackSlash(FDataFolder), Allocation_Table);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if IsamExists(fileName) then
  	Exit;

  indexDefs[PK_Index].KeyL := PK_Index_Len;
  indexDefs[PK_Index].AllowDupK := False;

  BTCreateFileBlock(fileBaseName, SizeOf(TAllocationRecord), 1, indexDefs);
  if not IsamOK then
  	DoCrashExit(ERR_FAILED_TO_CREATE_TABLE,
								'Failed to create file: ' + Allocation_Table);

  LogInfo('Created file: ' + Allocation_Table);
end;

end.