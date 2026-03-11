(*--------------------------------------------------------*)
(*   DATBASE.PAS                                          *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   10/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit Database;

interface

uses
	Objects, Dos,
	Filer,
	Classes;

type
	PDatabase = ^TDatabase;
  TDatabase = object(TObject)
  private
  	FDataFolder: PathStr;

    FCategoryTable,
    FSubCategoryTable: IsamFileBlockPtr;

    procedure CreateDatabase;
    procedure OpenDatabase;
    procedure InsertVersionNumber;
    procedure CheckVersion;

    function CatNameExists(const AName: String): Boolean;
  public
  	constructor Init(const aFolder: PathStr);
    destructor Done; virtual;

    function AddCategory(var rec: TCategory; var errCode: Byte): Boolean;
    function GetCategory(const id: LongInt;
										var rec: TCategory; var errCode: Byte): Boolean;
    function GetCategoryByName(const aName: String;
										var rec: TCategory; var errCode: Byte): Boolean;
    function UpdateCategory(const rec: TCategory;
										var errCode: Byte): Boolean;
    function DeleteCategory(const id: LongInt): Boolean;
  end;

implementation

uses
	BTBase, BTIsBase, IsamTool, NumKeys,
  TPString,
  JDUtils, JDDates, JDString,
	DBUtils, CrashOut;

const
  MAX_FILE_HANDLES = 50;
	NDX_FIELD_MIN_LEN: Byte =  2;
	NDX_FIELD_MAX_LEN: Byte = 30;

	(* Table Names *)
  VERSION_FILE			: NameStr = 'VERSION';
	CAT_TABLE_FILE		: NameStr = 'CATEGORY';
  SUB_CAT_TABLE_FILE: NameStr = 'CAT_SUB';

  (* Index Handles *)
  NDX_CAT_NAME: Byte = 1;
  NDX_SUB_CAT_NAME: Byte = 1;
  NDX_SUB_CAT_CAT_ID: Byte = 2;

	(* Database Version Supported *)
  DB_VERSION_MAJOR: Byte = 1;
  DB_VERSION_MINOR: Byte = 0;
  DB_VERSION_BUILD: Byte = 1;

{$I SHARED.INC}

type
	TVersionRecord = record
  	SystemInfo: LongInt; (* Used internally by the BTree Lib*)
    Major,
    Minor,
    Build: Byte;
    Comment: TCommentField; (* Needed to pass the minimum size for a record *)
    Created: LongInt;
  end;

	TCategoryRecord = record
  	SystemInfo: LongInt; (* Used internally by the BTree Lib*)
    Name: TNameField;
    Comment: TCommentField;
    Created,
    Updated: LongInt;
  end;

	TSubCategoryRecord = record
  	SystemInfo: LongInt; (* Used internally by the BTree Lib*)
    Name: TNameField;
    Comment: TCommentField;
    CategoryId,
    Created,
    Updated: LongInt;
  end;

(*********************)
(* Support functions *)
(*********************)

procedure DoLogFatalError(const exitCode: Byte; const message: String);
var
  errClass, errNum: Integer;
  strClass, strNum: String;
begin
	errClass := BTIsamErrorClass;
  errNum := IsamError;

  Str(errClass: 1, strClass);
  Str(errNum: 5, strNum);

  if errClass < 10 then
  	strClass := '0' + strClass;

  if errNum < 10000 then
  	strNum := '0' + strNum;

  LogFatal(message + ' [' + strClass + ',' + strNum + ']');
  Crash(exitCode);
end;

procedure DoLogError(const message: String);
var
  errClass, errNum: Integer;
  strClass, strNum: String;
begin
	errClass := BTIsamErrorClass;
  errNum := IsamError;

  Str(errClass: 1, strClass);
  Str(errNum: 5, strNum);

  if errClass < 10 then
  	strClass := '0' + strClass;

  if errNum < 10000 then
  	strNum := '0' + strNum;

  LogError(message + ' [' + strClass + ',' + strNum + ']');
end;

function GetCatNameKey(const aName: String): String;
begin
	GetCatNameKey := Pack6BitKey(aName, NDX_FIELD_MAX_LEN);
end;

(*************)
(* TDatabase *)
(*************)

procedure TDatabase.CheckVersion;
var
	versionFile: IsamFileBlockPtr;
  data: TVersionRecord;
  fileBaseName: PathStr;
begin
	fileBaseName := ConCat(AddBackSlash(FDataFolder), VERSION_FILE);
  FillChar(data, SizeOf(TVersionRecord), #0);

  BTOpenFileBlock(versionFile, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoLogFatalError(DBE_NO_OPEN_TABLE, 'Failed to open version table');

  BTGetRec(versionFile, 1, data, False);
  if not IsamOK then
  	DoLogFatalError(CRUD_NO_GET_REC, 'Failed to load version record');

  BTCloseFileBlock(versionFile);

  if (data.Major <> DB_VERSION_MAJOR)
			and (data.Minor <> DB_VERSION_MINOR) then
  	DoLogFatalError(DBE_INVALID_VERSION, 'Invalid database version number');
end;

procedure TDatabase.InsertVersionNumber;
var
	fileName,
	fileBaseName: PathStr;
	versionFile: IsamFileBlockPtr;
  data: TVersionRecord;
  stamp: TTimeStamp;
  refId: LongInt;
begin
	fileBaseName := ConCat(AddBackSlash(FDataFolder), VERSION_FILE);
  FillChar(data, SizeOf(TVersionRecord), #0);
  stamp.Init;

  with data do
  	begin
    	Major := DB_VERSION_MAJOR;
      Minor := DB_VERSION_MINOR;
      Build := DB_VERSION_BUILD;
      Created := stamp.Pack;
    end;

  BTOpenFileBlock(versionFile, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoLogFatalError(DBE_NO_OPEN_TABLE, 'Failed to open version table');

  BTAddRec(versionFile, refId, data);
  if not IsamOK then
  	DoLogFatalError(CRUD_NO_ADD_REC, 'Failed to insert version number');

  BTCloseFileBlock(versionFile);
end;

procedure TDatabase.CreateDatabase;
var
	fileName,
	fileBaseName: PathStr;
  indexDefs: IsamIndDescr;
begin
	(* Create Version Table *)
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);

	fileBaseName := ConCat(AddBackSlash(FDataFolder), VERSION_FILE);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if Not IsamExists(fileName) then
  	begin
  		BTCreateFileBlock(fileBaseName, SizeOf(TVersionRecord), 0, indexDefs);
  		if not IsamOK then
  			DoLogFatalError(DBE_NO_CREATE_TABLE,
								'Failed to create files for table: Version (' + VERSION_FILE + ')');

      LogInfo('Version table created');

      InsertVersionNumber;
    end;

	(* Create Category Table *)
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);

	fileBaseName := ConCat(AddBackSlash(FDataFolder), CAT_TABLE_FILE);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if Not IsamExists(fileName) then
  	begin
  		indexDefs[NDX_CAT_NAME].KeyL := NDX_FIELD_MAX_LEN;
  		indexDefs[NDX_CAT_NAME].AllowDupK := False;

  		BTCreateFileBlock(fileBaseName, SizeOf(TCategoryRecord), 1, indexDefs);
  		if not IsamOK then
  			DoLogFatalError(DBE_NO_CREATE_TABLE,
								'Failed to create files for table: Category (' + CAT_TABLE_FILE + ')');

      LogInfo('Category table created');
    end;

  (* Create SubCategory Table *)
	FillChar(indexDefs, SizeOf(IsamIndDescr), #0);

	fileBaseName := ConCat(AddBackSlash(FDataFolder), SUB_CAT_TABLE_FILE);
  fileName := IsamForceExtension(fileBaseName, DatExtension);

  if Not IsamExists(fileName) then
  	begin
  		indexDefs[NDX_SUB_CAT_NAME].KeyL := NDX_FIELD_MAX_LEN;
  		indexDefs[NDX_SUB_CAT_NAME].AllowDupK := False;

  		indexDefs[NDX_SUB_CAT_CAT_ID].KeyL := NDX_FIELD_MIN_LEN;
  		indexDefs[NDX_SUB_CAT_CAT_ID].AllowDupK := True;

  		BTCreateFileBlock(fileBaseName, SizeOf(TSubCategoryRecord), 2, indexDefs);
  		if not IsamOK then
  			DoLogFatalError(DBE_NO_CREATE_TABLE,
								'Failed to create files for table: SubCategory (' + SUB_CAT_TABLE_FILE + ')');

      LogInfo('Sub Category table created');
    end;
end;

procedure TDatabase.OpenDatabase;
var
	fileBaseName: PathStr;
begin
	{ Open the category table }
	fileBaseName := ConCat(AddBackSlash(FDataFolder), CAT_TABLE_FILE);

  BTOpenFileBlock(FCategoryTable, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoLogFatalError(DBE_NO_OPEN_TABLE, 'Failed to open category table');

  { Open the sub-category table }
	fileBaseName := ConCat(AddBackSlash(FDataFolder), SUB_CAT_TABLE_FILE);

  BTOpenFileBlock(FSubCategoryTable, fileBaseName, False, False, False, False);
  if not IsamOK then
  	DoLogFatalError(DBE_NO_OPEN_TABLE, 'Failed to open sub-category table');
end;

constructor TDatabase.Init(const aFolder: PathStr);
begin
	inherited Init;

  FDataFolder := aFolder;

  (* Setup the DB Engine *)
  BTInitIsam(NoNet, MinimizeUseOfNormalHeap, 0);
  if not IsamOK then
  	DoLogFatalError(DBE_INIT_FAILED, 'Failed to init the database engine');

  ExtendHandles(MAX_FILE_HANDLES);

  (* Create the database *)
  CreateDatabase;

  (* Check version number *)
  CheckVersion;

  (* Open the tables *)
  OpenDatabase;
end;

destructor TDatabase.Done;
begin
	(* Flush the buffers, close the files,
			close the DB Engine *)
  BTFlushAllFileBlocks;
  BTCloseAllFileBlocks;
  BTExitIsam;

	inherited Done;
end;

(* --- Category --- *)

function TDatabase.CatNameExists(const aName: String): Boolean;
var
	nameKey: String;
begin
	nameKey := GetCatNameKey(aName);
	CatNameExists := False;

	if BTKeyExists(FCategoryTable, NDX_CAT_NAME, 0, nameKey) then
    CatNameExists := True;
end;

function TDatabase.AddCategory(var rec: TCategory; var errCode: Byte): Boolean;
var
	data: TCategoryRecord;
  refId: LongInt;
  stamp: TTimeStamp;
  nameKey: String;
begin
	errCode := NO_ERROR;
  AddCategory := True;

	if CatNameExists(rec.Name) then
  	begin
    	errCode := CRUD_REC_EXISTS;
      AddCategory := False;
      Exit;
    end;

	FillChar(data, SizeOf(TCategoryRecord), #0);
  refId := 0;
  stamp.Init;

  data.Name := rec.Name;
  data.Comment := rec.Comment;
  data.Updated := stamp.Pack;
  data.Created := stamp.Pack;

  BTAddRec(FCategoryTable, refId, data);
  if not IsamOk then
  	begin
    	errCode := CRUD_NO_ADD_REC;
      AddCategory := False;
      DoLogError('Failed to insert category: ' + rec.Name);
      Exit;
    end;

  rec.Id := refId;

  nameKey := GetCatNameKey(rec.Name);
  BTAddKey(FCategoryTable, NDX_CAT_NAME, refId, nameKey);
end;

function TDatabase.UpdateCategory(const rec: TCategory; var errCode: Byte): Boolean;
var
	data: TCategoryRecord;
  oldName: String;
  stamp: TTimeStamp;
  refId: LongInt;
  nameKey: String;
begin
	errCode := NO_ERROR;
  UpdateCategory := True;

	FillChar(data, SizeOf(TCategoryRecord), #0);

  BTGetRec(FCategoryTable, rec.id, data, False);
  if not IsamOK then
  	begin
    	errCode := QRY_REC_NOT_FOUND;
      UpdateCategory := False;
      Exit;
    end;

  (* Check if the name has changed *)
  oldName := '';
  if CompString(data.Name, rec.Name) <> Equal then
    	oldName := data.Name;

  (* Update the record *)
  stamp.Init;
  refId := rec.Id;

  data.Name := rec.Name;
  data.Comment := rec.Comment;
  data.Updated := stamp.Pack;

  BTPutRec(FCategoryTable, refId, data, False);
  if not IsamOK then
  	begin
    	errCode := CRUD_NO_UPDATE;
      UpdateCategory := False;
      DoLogError('Failed to update category: ' + rec.Name);
      Exit;
    end;

  if not IsEmpty(oldName) then
  	begin
    	nameKey := GetCatNameKey(oldName);
    	BTDeleteKey(FCategoryTable, NDX_CAT_NAME, refId, nameKey);

      nameKey := GetCatNameKey(rec.Name);
      BTAddKey(FCategoryTable, NDX_CAT_NAME, refId, nameKey);
    end;
end;

function TDatabase.GetCategory(const id: LongInt;
							var rec: TCategory; var errCode: Byte): Boolean;
var
	data: TCategoryRecord;
begin
	errCode := NO_ERROR;
  GetCategory := True;

	FillChar(data, SizeOf(TCategoryRecord), #0);

  BTGetRec(FCategoryTable, id, data, False);
  if not IsamOK then
  	begin
    	errCode := QRY_REC_NOT_FOUND;
      GetCategory := False;
      Exit;
    end;

  rec.Id := id;
  rec.Name := data.Name;
  rec.Comment := data.Comment;
end;

function TDatabase.GetCategoryByName(const aName: String;
								var rec: TCategory; var errCode: Byte): Boolean;
var
	data: TCategoryRecord;
  refId: LongInt;
  nameKey: String;
begin
	errCode := NO_ERROR;
  GetCategoryByName := True;

	FillChar(data, SizeOf(TCategoryRecord), #0);
  refId := 0;
  nameKey := GetCatNameKey(aName);

  (* Find the physical id for the record *)
  BTClearKey(FCategoryTable, NDX_CAT_NAME);
  BTFindKey(FCategoryTable, NDX_CAT_NAME, refId, nameKey);
  if not IsamOK then
  	begin
    	errCode := QRY_REC_NOT_FOUND;
      GetCategoryByName := False;
      Exit;
    end;

  (* Load Record *)
  BTGetRec(FCategoryTable, refId, data, False);
  if not IsamOK then
  	begin
    	errCode := CRUD_NO_GET_REC;
      GetCategoryByName := False;
      DoLogError('Failed to load category record - ' + aName);
      Exit;
    end;

  rec.Id := refId;
  rec.Name := data.Name;
  rec.Comment := data.Comment;
end;

function TDatabase.DeleteCategory(const id: LongInt): Boolean;
begin
	DeleteCategory := True;

	BTDeleteRec(FCategoryTable, id);

  if not IsamOK then
  	begin
    	DeleteCategory := False;
      DoLogError('Failed to delete category: ' + Long2Str(id));
    end;
end;

end.