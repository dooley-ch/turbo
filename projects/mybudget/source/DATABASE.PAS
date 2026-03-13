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

    function IsCategoryDefined(const AName: String): Boolean;
    function CategoryExists(const id: LongInt): Boolean;

    function IsSubCategoryDefined(const aCategoryId: LongInt;
																		const aName: String): Boolean;
  public
  	constructor Init(const aFolder: PathStr);
    destructor Done; virtual;

    (* --- Category -- *)
    function AddCategory(var rec: TCategory): Boolean;
    function GetCategory(const id: LongInt; var rec: TCategory): Boolean;
    function GetCategoryByName(const aName: String; var rec: TCategory): Boolean;
    function UpdateCategory(const rec: TCategory): Boolean;
    function DeleteCategory(const id: LongInt): Boolean;

    (* --- Sub Category --- *)
    function AddSubCategory(var rec: TSubCategory): Boolean;
    function GetSubCategory(const id: LongInt; var rec: TSubCategory): Boolean;
    function UpdateSubCategory(const rec: TSubCategory): Boolean;
    function DeleteSubCategory(const id: LongInt; var errCode: Byte): Boolean;
  end;

var
	DbError: LongInt;
  DbErrorMessage: String;

implementation

uses
	BTBase, BTIsBase, IsamTool, NumKeys,
  TPString,
  JDUtils, JDDates, JDString,
	DBUtils, CrashOut;

const
  MAX_FILE_HANDLES = 50;

  (* Index Key Lens *)
  NDX_LEN_FK           = 10;
  NDX_LEN_CAT_NAME     = 30;
  NDX_LEN_SUB_CAT_NAME = 40;

	(* Table Names *)
  VERSION_FILE			: NameStr = 'VERSION';
	CAT_TABLE_FILE		: NameStr = 'CATEGORY';
  SUB_CAT_TABLE_FILE: NameStr = 'CAT_SUB';

  (* Index Handles *)
  NDX_CAT_NAME      : Byte = 1;
  NDX_SUB_CAT_NAME  : Byte = 1;
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

procedure ClearErrors; forward;
procedure SetSystemError; forward;
procedure LogSystemError(const message: String); forward;
procedure LogFatalError(const exitCode: Byte; const message: String); forward;
function BuildNameKey(const aName: String): String; forward;
function BuildSubNameKey(const aId: LongInt; const aName: String): String; forward;
function BuildIdKey(const aId: LongInt): String; forward;




procedure DoLogFatalError(const exitCode: Byte; const message: String);
var
  errClass, errNum: Integer;
  strClass, strNum, errMsg: String;
begin
	errClass := BTIsamErrorClass;
  errNum := IsamError;

  Str(errClass: 1, strClass);
  Str(errNum: 5, strNum);

  if errClass < 10 then
  	strClass := '0' + strClass;

  if errNum < 10000 then
  	strNum := '0' + strNum;

  errMsg := IsamErrorMessage(errNum);

  LogFatal(message + ' [' + strClass + ',' + strNum + ']');
  LogAddInfo(errMsg);

  Crash(exitCode);
end;

procedure DoLogError(const message: String);
var
  errClass, errNum: Integer;
  strClass, strNum, errMsg: String;
begin
	errClass := BTIsamErrorClass;
  errNum := IsamError;

  Str(errClass: 1, strClass);
  Str(errNum: 5, strNum);

  if errClass < 10 then
  	strClass := '0' + strClass;

  if errNum < 10000 then
  	strNum := '0' + strNum;

  errMsg := IsamErrorMessage(errNum);

  LogError(message + ' [' + strClass + ',' + strNum + ']');
  LogAddInfo(errMsg);
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

  stamp.Done;
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
  		indexDefs[NDX_CAT_NAME].KeyL := NDX_LEN_CAT_NAME;
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
  		indexDefs[NDX_SUB_CAT_NAME].KeyL := NDX_LEN_SUB_CAT_NAME;
  		indexDefs[NDX_SUB_CAT_NAME].AllowDupK := False;

  		indexDefs[NDX_SUB_CAT_CAT_ID].KeyL := NDX_LEN_FK;
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

function TDatabase.CategoryExists(const id: LongInt): Boolean;
var
	data: TCategoryRecord;
begin
	FillChar(data, SizeOf(TCategoryRecord), #0);
  CategoryExists := False;

  BTGetRec(FCategoryTable, id, data, False);
  if IsamOK then
    CategoryExists := True;
end;

function TDatabase.IsCategoryDefined(const aName: String): Boolean;
var
	nameKey: String;
begin
	nameKey := BuildNameKey(aName);
	IsCategoryDefined := False;

	if BTKeyExists(FCategoryTable, NDX_CAT_NAME, 0, nameKey) then
    IsCategoryDefined := True;
end;

function TDatabase.AddCategory(var rec: TCategory): Boolean;
var
	data: TCategoryRecord;
  refId: LongInt;
  stamp: TTimeStamp;
  nameKey: String;
begin
	ClearErrors;
  AddCategory := True;

	if IsCategoryDefined(rec.Name) then
  	begin
    	DbError := DUPLICATE_RECORD;
      DbErrorMessage := 'Category already defined: ' + rec.Name;

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
    	SetSystemError;
      LogSystemError('Failed to insert category: ' + rec.Name);

      AddCategory := False;
      Exit;
    end;

  rec.Id := refId;
  stamp.Done;

  nameKey := BuildNameKey(rec.Name);
  BTAddKey(FCategoryTable, NDX_CAT_NAME, refId, nameKey);
  if not IsamOk then
  	begin
    	SetSystemError;
      LogSystemError('Failed to insert UK for category: ' + rec.Name);

      AddCategory := False;
    end;
end;

function TDatabase.UpdateCategory(const rec: TCategory): Boolean;
var
	data: TCategoryRecord;
  oldName: String;
  stamp: TTimeStamp;
  nameKey: String;
begin
	ClearErrors;
  UpdateCategory := True;

	FillChar(data, SizeOf(TCategoryRecord), #0);

  BTGetRec(FCategoryTable, rec.id, data, False);
  if not IsamOK then
  	begin
      if BTIsamErrorClass <> BT_ERROR_CLS_USER then
      	begin
      		SetSystemError;
          LogSystemError('Failed to find category - ' + Long2Str(rec.Id));
        end
      else
      	DbError := RECORD_NOT_FOUND;
      UpdateCategory := False;
      Exit;
    end;

  (* Check if the name has changed *)
  oldName := '';
  if CompString(data.Name, rec.Name) <> Equal then
  	begin
  		oldName := data.Name;

			if IsCategoryDefined(rec.Name) then
  			begin
    			DbError := DUPLICATE_RECORD;
      		DbErrorMessage := 'Category already defined: ' + rec.Name;

      		UpdateCategory := False;
      		Exit;
    		end;
  	end;

  (* Update the record *)
  stamp.Init;

  data.Name := rec.Name;
  data.Comment := rec.Comment;
  data.Updated := stamp.Pack;

  BTPutRec(FCategoryTable, rec.Id, data, False);
  if not IsamOK then
  	begin
    	SetSystemError;
      LogSystemError('Failed to find category - ' + Long2Str(rec.Id));

      UpdateCategory := False;
      Exit;
    end;

  stamp.Done;

  if not IsEmpty(oldName) then
  	begin
    	nameKey := BuildNameKey(oldName);
    	BTDeleteKey(FCategoryTable, NDX_CAT_NAME, rec.Id, nameKey);
  		if not IsamOK then
  			begin
    			SetSystemError;
      		LogSystemError('Failed to delete key for category - ' + oldName);

      		UpdateCategory := False;
      		Exit;
    		end;

      nameKey := BuildNameKey(rec.Name);
      BTAddKey(FCategoryTable, NDX_CAT_NAME, rec.Id, nameKey);
  		if not IsamOK then
  			begin
    			SetSystemError;
      		LogSystemError('Failed to add key for category - ' + rec.Name);

      		UpdateCategory := False;
    		end;
    end;
end;

function TDatabase.GetCategory(const id: LongInt; var rec: TCategory): Boolean;
var
	data: TCategoryRecord;
begin
	ClearErrors;
  GetCategory := True;

	FillChar(data, SizeOf(TCategoryRecord), #0);

  BTGetRec(FCategoryTable, id, data, False);
  if not IsamOK then
  	begin
      if BTIsamErrorClass <> BT_ERROR_CLS_USER then
      	begin
      		SetSystemError;
          LogSystemError('Failed to find category - ' + Long2Str(id));
        end
      else
      	DbError := RECORD_NOT_FOUND;
      GetCategory := False;
      Exit;
    end;

  rec.Id := id;
  rec.Name := data.Name;
  rec.Comment := data.Comment;
end;

function TDatabase.GetCategoryByName(const aName: String; var rec: TCategory): Boolean;
var
	data: TCategoryRecord;
  refId: LongInt;
  nameKey: String;
begin
	ClearErrors;
  GetCategoryByName := True;

	FillChar(data, SizeOf(TCategoryRecord), #0);
  refId := 0;
  nameKey := BuildNameKey(aName);

  (* Find the physical id for the record *)
  BTClearKey(FCategoryTable, NDX_CAT_NAME);
  BTFindKey(FCategoryTable, NDX_CAT_NAME, refId, nameKey);
  if not IsamOK then
  	begin
    	if BTIsamErrorClass <> BT_ERROR_CLS_USER then
      	begin
      		SetSystemError;
          LogSystemError('Failed to find category - ' + aName);
        end
      else
      	DbError := RECORD_NOT_FOUND;
      GetCategoryByName := False;
      Exit;
    end;

  (* Load Record *)
  BTGetRec(FCategoryTable, refId, data, False);
  if not IsamOK then
  	begin
      if BTIsamErrorClass <> BT_ERROR_CLS_USER then
      	begin
      		SetSystemError;
          LogSystemError('Failed to find category - ' + aName);
        end
      else
      	DbError := RECORD_NOT_FOUND;
      GetCategoryByName := False;
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
    	begin
      	SetSystemError;
        LogSystemError('Failed to delete category - ' + Long2Str(id));
      end
    end;
end;

{ --- Sub Category --- }

function TDatabase.IsSubCategoryDefined(const aCategoryId: LongInt;
																					const aName: String): Boolean;
var
	nameKey: String;
begin
	nameKey := BuildSubNameKey(aCategoryId, aName);
	IsSubCategoryDefined := False;

	if BTKeyExists(FSubCategoryTable, NDX_SUB_CAT_NAME, 0, nameKey) then
    IsSubCategoryDefined := True;
end;

function TDatabase.AddSubCategory(var rec: TSubCategory): Boolean;
var
	data: TSubCategoryRecord;
  nameKey: String;
  stamp: TTimeStamp;
  refId: LongInt;
begin
	ClearErrors;
  AddSubCategory := True;

  (* Check owning category exists *)
  if not CategoryExists(rec.CategoryId) then
  	begin
      AddSubCategory := False;
      DbError := FOREIGN_KEY_NOT_FOUND;
      Exit;
    end;

	(* Check that it's not a duplicate *)
  if IsSubCategoryDefined(rec.CategoryId, rec.Name) then
  	begin
    	DbError := DUPLICATE_RECORD;
      AddSubCategory := False;
      Exit;
    end;

  (* Insert the record *)
  FillChar(data, SizeOf(TSubCategoryRecord), #0);
  stamp.Init;

  data.Name := rec.Name;
  data.Comment := rec.Comment;
  data.CategoryId := rec.CategoryId;
  data.Created := stamp.Pack;
  data.Updated := stamp.Pack;

  BTAddRec(FSubCategoryTable, refId, data);
  if not IsamOk then
  	begin
    	SetSystemError;
      LogSystemError('Failed to insert sub-category: ' + rec.Name);

      AddSubCategory := False;
      Exit;
    end;

  rec.Id := refId;
  stamp.Done;

  (* Create the keys *)
  nameKey := BuildSubNameKey(rec.CategoryId, rec.Name);
  BTAddKey(FSubCategoryTable, NDX_SUB_CAT_NAME, refId, nameKey);
  if not IsamOk then
  	begin
    	SetSystemError;
      LogSystemError('Failed to add sub-category name key: ' + rec.Name);

      AddSubCategory := False;
      Exit;
    end;

	BTAddKey(FSubCategoryTable, NDX_SUB_CAT_CAT_ID, refId, BuildIdKey(rec.CategoryId));
  if not IsamOk then
  	begin
    	SetSystemError;
      LogSystemError('Failed to add sub-category category key: ' + rec.Name);

      AddSubCategory := False;
      Exit;
    end;
end;

function TDatabase.GetSubCategory(const id: LongInt; var rec: TSubCategory): Boolean;
var
	data: TSubCategoryRecord;
begin
	ClearErrors;
  GetSubCategory := True;

  FillChar(data, SizeOf(TSubCategoryRecord), #0);

  BTGetRec(FSubCategoryTable, id, data, False);
  if not IsamOK then
  	begin
      if BTIsamErrorClass <> BT_ERROR_CLS_USER then
      	begin
      		SetSystemError;
          LogSystemError('Failed to find sub-category - ' + Long2Str(id));
        end
      else
      	DbError := RECORD_NOT_FOUND;
      GetSubCategory := False;
      Exit;
    end;

  rec.Id := id;
  rec.Name := data.Name;
  rec.Comment := data.Comment;
  rec.CategoryId := data.CategoryId;
end;

function TDatabase.UpdateSubCategory(const rec: TSubCategory): Boolean;
var
	data: TSubCategoryRecord;
  oldName, nameKey: String;
  oldCatId: LongInt;
  stamp: TTimeStamp;
begin
	ClearErrors;
  UpdateSubCategory := True;

	(* Load current record *)
  FillChar(data, SizeOf(TSubCategoryRecord), #0);

  BTGetRec(FSubCategoryTable, rec.Id, data, False);
  if not IsamOK then
  	begin
      if BTIsamErrorClass <> BT_ERROR_CLS_USER then
      	begin
      		SetSystemError;
          LogSystemError('Failed to find sub-category - ' + Long2Str(rec.Id));
        end
      else
      	DbError := RECORD_NOT_FOUND;
      UpdateSubCategory := False;
      Exit;
    end;

  (* Check owning category exists *)
  if not CategoryExists(rec.CategoryId) then
  	begin
      UpdateSubCategory := False;
      DbError := FOREIGN_KEY_NOT_FOUND;
      Exit;
    end;

  (* Check for duplicate record *)
  oldName := '';
  oldCatId := 0;
  if CompString(data.Name, rec.Name) <> Equal then
  	begin
    	oldName := data.Name;
      oldCatId := data.CategoryId;

  		if IsSubCategoryDefined(rec.CategoryId, rec.Name) then
  			begin
    			DbError := DUPLICATE_RECORD;
      		UpdateSubCategory := False;
      		Exit;
    		end;
    end;

  if data.CategoryId <> rec.CategoryId then
  	oldCatId := data.CategoryId;

  (* Update record *)
  stamp.Init;

  data.Name := rec.Name;
  data.Comment := rec.Comment;
  data.CategoryId := rec.CategoryId;
  data.Updated := stamp.Pack;

  BTPutRec(FSubCategoryTable, rec.Id, data, False);
  if not IsamOK then
  	begin
    	SetSystemError;
      LogSystemError('Failed to find category - ' + Long2Str(rec.Id));

      UpdateSubCategory := False;
      Exit;
    end;

  stamp.Done;

  if not IsEmpty(oldName) then
  	begin
    	nameKey := BuildSubNameKey(oldCatId, oldName);
    	BTDeleteKey(FSubCategoryTable, NDX_SUB_CAT_NAME, rec.Id, nameKey);
  		if not IsamOK then
  			begin
    			SetSystemError;
      		LogSystemError('Failed to delete old sub-category key - ' + oldName);

      		UpdateSubCategory := False;
      		Exit;
    		end;

      nameKey := BuildSubNameKey(rec.CategoryId, rec.Name);
      BTAddKey(FSubCategoryTable, NDX_SUB_CAT_NAME, rec.Id, nameKey);
  		if not IsamOK then
  			begin
    			SetSystemError;
      		LogSystemError('Failed to add sub-category key - ' + rec.Name);

      		UpdateSubCategory := False;
      		Exit;
    		end;

    end;

  if oldCatId <> 0 then
  	begin
			BTDeleteKey(FSubCategoryTable, NDX_SUB_CAT_CAT_ID, rec.Id, BuildIdKey(oldCatId));
  		if not IsamOK then
  			begin
    			SetSystemError;
      		LogSystemError('Failed to delete FK Category on sub-category - ' + rec.Name);

      		UpdateSubCategory := False;
      		Exit;
    		end;

			BTAddKey(FSubCategoryTable, NDX_SUB_CAT_CAT_ID, rec.Id, BuildIdKey(rec.CategoryId));
  		if not IsamOK then
  			begin
    			SetSystemError;
      		LogSystemError('Failed to add FK Category on sub-category - ' + rec.Name);

      		UpdateSubCategory := False;
      		Exit;
    		end;
    end
end;

function TDatabase.DeleteSubCategory(const id: LongInt;
																		var errCode: Byte): Boolean;
begin
	errCode := NO_ERROR;
  DeleteSubCategory := True;

	BTDeleteRec(FSubCategoryTable, id);

  if not IsamOK then
  	begin
    	DeleteSubCategory := False;
      DoLogError('Failed to delete sub-category: ' + Long2Str(id));
    end;
end;

(********************)
(* Support Routines *)
(********************)

procedure ClearErrors;
begin
	DbError := NO_ERROR;
  DbErrorMessage := '';
end;

procedure SetSystemError;
begin
	DbError := IsamError;
  DbErrorMessage := IsamErrorMessage(IsamError);
end;

procedure LogSystemError(const message: String);
var
  errNumStr: String;
begin
	errNumStr := Long2Str(IsamError);
  LogError(message + ' (' + errNumStr + ')');
  LogAddInfo(IsamErrorMessage(IsamError));
end;

procedure LogFatalError(const exitCode: Byte; const message: String);
begin
	LogSystemError(message);
  Crash(exitCode);
end;

function BuildIdKey(const aId: LongInt): String;
begin
	BuildIdKey := LeftPadCh(Long2Str(aId), '0', 10);
end;

function BuildNameKey(const aName: String): String;
begin
	BuildNameKey := StUpcase(aName);
end;

function BuildSubNameKey(const aId: LongInt; const aName: String): String;
begin
	BuildSubNameKey := BuildNameKey(aName) + BuildIdKey(aId);
end;

end.