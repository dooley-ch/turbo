(*--------------------------------------------------------*)
(*   JDUTILS.PAS                                          *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   05/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit JDUtils;

interface

uses
	Dos, Objects;

type
	{ TIniEntry }

  PIniEntry = ^TIniEntry;
  TIniEntry = object(TObject)
  private
  	FKey, FValue: PString;

    procedure ParseEntry(const vEntry: String);
  public
    function Name: String;
    function Value: String;
    function Key: PString;

    Constructor Init(const vEntry: String);
    Destructor Done; virtual;

    function AsString: String;
  end;

  { TIniSection }

  PIniSection = ^TIniSection;
  TIniSection = object(TSortedCollection)
  private
  	FKey: PString;
  public
    function Name: String;
    function Key: PString;

    Constructor Init(const vName: String);
    Destructor Done; virtual;

    function KeyOf(item: Pointer): Pointer; virtual;
    function Compare(key1, key2: Pointer): Integer; virtual;

    function ToString: String;
  end;

  { TIniFile }

  PIniFile = ^TIniFile;
  TIniFile = object(TSortedCollection)
  private
  	FFileName: PString;

    procedure Load;
  public
    function FileName: String;

    Constructor Init(const vFileName: String);
    Destructor Done; virtual;

    function KeyOf(item: Pointer): Pointer; virtual;
    function Compare(key1, key2: Pointer): Integer; virtual;

    function GetString(const section, key: String; var value: String): Boolean;
    function GetBoolean(const section, key: String; var value: Boolean): Boolean;
    function GetInteger(const section, key: String; var value: Integer): Boolean;
  end;

  { TTxtFile }

  TTxtFileLine = String[255];

  PTxtFileLines = ^TTxtFileLines;
  TTxtFileLines = array[0..0] of TTxtFileLine;

  PTxtFile = ^TTxtFile;
  TTxtFile = object(TObject)
  private
    FLines: PTxtFileLines;
    FCount: Byte;
    FName: String;
    FAllocatedMem: Integer;

    function GetFileLineCount: Byte;
    procedure Load;
	public
    function Name: String;
    function Count: Byte;
    function Lines(const index: Integer): String;

    constructor Init(const fileName: String);
    destructor Done; virtual;
  end;

procedure SetLogFile(const fileName: PathStr);

procedure LogDebug(const message: String);
procedure LogInfo(const message: String);
procedure LogWarning(const message: String);
procedure LogError(const message: String);
procedure LogFatal(const message: String);

procedure LogStart;
procedure LogEnd;

function IsDir(const path: DirStr): Boolean;
function FileExists(const aName: PathStr): Boolean;
function PathCombine(const aBasePath, aPath: PathStr): PathStr;

procedure Beep;

procedure DumpTxtFile(pFile: PTxtFile);

(******************)
(* Implementation *)
(******************)
implementation

uses
	Strings, Crt, TPString, JDString, JDDates;

const
  LOG_DEBUG_MSG = 1;
  LOG_INFO_MSG  = 2;
  LOG_WARN_MSG  = 3;
  LOG_ERROR_MSG = 4;
  LOG_FATAL_MSG = 5;

type
	TLogFile = object(TObject)
  private
    procedure WriteLine(const line: String);
    procedure WriteMessage(const level: Integer; const msg: String);
  public
  	LogFileName: PathStr;

		procedure Debug(const message: String);
		procedure Info(const message: String);
		procedure Warning(const message: String);
		procedure Error(const message: String);
		procedure Fatal(const message: String);

		procedure LogStart;
		procedure LogEnd;
  end;

var
	LogFile: TLogFile;

(************)
(* TLogFile *)
(************)

procedure TLogFile.WriteLine(const line: String);
var
	outFile: Text;
begin
  Assign(outFile, LogFileName);

  if not FileExists(LogFileName) then
  	Rewrite(outFile)
  else
  	Append(outFile);

  WriteLn(outFile, line);

  Close(outFile);
end;

procedure TLogFile.WriteMessage(const level: Integer; const msg: String);
var
	typeStr,
  line: String;
  stamp: TTimeStamp;
begin
  case level of
  	LOG_DEBUG_MSG: typeStr := 'DEBUG';
  	LOG_INFO_MSG: typeStr  := 'INFO ';
  	LOG_WARN_MSG: typeStr  := 'WARN ';
  	LOG_ERROR_MSG: typeStr := 'ERROR';
  	LOG_FATAL_MSG: typeStr := 'FATAL';
  else
  	typeStr := '*****';
  end;

  stamp.Init;

  line := stamp.AsString + ' | ' + typestr + ' | ' + msg;
  WriteLine(line);
end;

procedure TLogFile.Debug(const message: String);
begin
  WriteMessage(LOG_DEBUG_MSG, message);
end;

procedure TLogFile.Info(const message: String);
begin
  WriteMessage(LOG_INFO_MSG, message);
end;

procedure TLogFile.Warning(const message: String);
begin
  WriteMessage(LOG_WARN_MSG, message);
end;

procedure TLogFile.Error(const message: String);
begin
  WriteMessage(LOG_ERROR_MSG, message);
end;

procedure TLogFile.Fatal(const message: String);
begin
  WriteMessage(LOG_FATAL_MSG, message);
end;

procedure TLogFile.LogStart;
var
	line: String;
  stamp: TTimeStamp;
begin
	stamp.Init;

	line := stamp.AsString + ' | === Start ===============================';
  WriteLine(line);
end;

procedure TLogFile.LogEnd;
var
	line: String;
  stamp: TTimeStamp;
begin
	line := stamp.AsString + ' | --- End ---------------------------------';
  WriteLine(line);
end;

procedure SetLogFile(const fileName: PathStr);
begin
	LogFile.LogFileName := fileName;
end;

procedure LogDebug(const message: String);
begin
	LogFile.Debug(message);
end;

procedure LogInfo(const message: String);
begin
	LogFile.Info(message);
end;

procedure LogWarning(const message: String);
begin
	LogFile.Warning(message);
end;

procedure LogError(const message: String);
begin
	LogFile.Error(message);
end;

procedure LogFatal(const message: String);
begin
	LogFile.Fatal(message);
end;

procedure LogStart;
begin
	LogFile.LogStart;
end;

procedure LogEnd;
begin
	LogFile.LogEnd;
end;

(*************)
(* TIniEntry *)
(*************)

function TIniEntry.AsString: String;
begin
	AsString := Name + '=' + Value;
end;

procedure TIniEntry.ParseEntry(const vEntry: String);
var
	len: Byte;
  vValue, vKey: String;
begin
	FKey := Nil;
  FValue := Nil;
  vKey := '';
  vValue := '';

	len := Pos('=', vEntry);

  if len <> 0 then
  	begin
    	vValue := Copy(vEntry, Succ(len), Succ(Length(vEntry) - len));
      vKey := vEntry;
      vKey[0] := Chr(Pred(len));

      vValue := TrimChars(vValue, #32);
      vValue := TrimChars(vValue, #9);
      vValue := TrimChars(vValue, '"');
      vValue := TrimChars(vValue, '''');
      vValue := TrimChars(vValue, ' ');

      vKey := TrimChars(vKey, #32);
      vKey := TrimChars(vKey, #9);
      vKey := TrimChars(vKey, '"');
      vKey := TrimChars(vKey, '''');
      vKey := TrimChars(vKey, ' ');

      FKey := NewStr(vKey);
      FValue := NewStr(vValue);
  	end
end;

function TIniEntry.Name: String;
begin
	Name := FKey^;
end;

function TIniEntry.Value: String;
begin
	Value := FValue^;
end;

function TIniEntry.Key: PString;
begin
	Key := FKey;
end;

Constructor TIniEntry.Init(const vEntry: String);
begin
	inherited Init;
  ParseEntry(vEntry);
end;

Destructor TIniEntry.Done;
begin
	DisposeStr(FKey);
  DisposeStr(FValue);
  inherited Done;
end;

(***************)
(* TIniSection *)
(***************)

function TIniSection.ToString: String;
begin
	ToString := '[' + Name + ']';
end;

function TIniSection.Compare(key1, key2: Pointer): Integer;
var
	kVal1, kVal2: String;
  k1, k2: array [0..100] of Char;
  flag: Integer;
begin
  kVal1 := PString(key1)^;
  kVal2 := PString(key2)^;

  StrPCopy(k1, kVal1);
  StrPCopy(k2, kVal2);

  flag := StrComp(k1, k2);

  Compare := 0;
  If flag < 0 then
  	Compare := -1;
  if flag > 0 then
  	Compare := 1;
end;

function TIniSection.KeyOf(item: Pointer): Pointer;
begin
	KeyOf := PIniEntry(item)^.Key;
end;

function TIniSection.Name: String;
begin
	Name := FKey^;
end;

function TIniSection.Key: PString;
begin
  Key := FKey;
end;

Constructor TIniSection.Init(const vName: String);
begin
	inherited Init(50, 10);
  FKey := NewStr(vName);
end;

Destructor TIniSection.Done;
begin
	DisposeStr(FKey);
  inherited Done;
end;

(************)
(* TIniFile *)
(************)

function TIniFile.GetString(const section, key: String; var value: String): Boolean;
var
	pSection: PIniSection;
  pEntry: PIniEntry;
  pName: PString;
  index: Integer;
begin
	GetString := True;
  value := '';

	{ Find the section }
  pName := NewStr(section);
  if not Search(pName, index) then
  	begin
    	GetString := False;
      Exit;
    end;
  DisposeStr(pName);

  pSection := PIniSection(At(index));

  { Find the entry }
  pName := NewStr(key);
  if not pSection^.Search(pName, index) then
  	begin
    	GetString := False;
      Exit;
    end;
  DisposeStr(pName);

  pEntry :=  PIniEntry(pSection^.At(index));

  { Get the value }
  value := pEntry^.Value;
end;

function TIniFile.GetBoolean(const section, key: String; var value: Boolean): Boolean;
var
	strValue: String;
begin
	GetBoolean := True;
  value := False;

	if not GetString(section, key, strValue) then
  begin
		GetBoolean := False;
		Exit;
	end;

  value := StrToBool(strValue);
end;

function TIniFile.GetInteger(const section, key: String; var value: Integer): Boolean;
var
	strValue: String;
  code: Integer;
begin
	GetInteger := True;
  value := 0;

	if not GetString(section, key, strValue) then
  begin
		GetInteger := False;
		Exit;
	end;

  Val(strValue, value, code);
end;

function TIniFile.KeyOf(item: Pointer): Pointer;
begin
	KeyOf := PIniSection(item)^.Key;
end;

function TIniFile.Compare(key1, key2: Pointer): Integer;
var
	kVal1, kVal2: String;
  k1, k2: array [0..100] of Char;
  flag: Integer;
begin
  kVal1 := PString(key1)^;
  kVal2 := PString(key2)^;

  StrPCopy(k1, kVal1);
  StrPCopy(k2, kVal2);

  flag := StrComp(k1, k2);

  Compare := 0;
  If flag < 0 then
  	Compare := -1;
  if flag > 0 then
  	Compare := 1;
end;

procedure TIniFile.Load;
var
	pSection: PIniSection;
  pEntry: PIniEntry;
  inFile: Text;
  sectionName, line: String;

  function IsSection(const line: String): Boolean;
  begin
  	IsSection := False;

    if line[1] = '[' then
    	IsSection := True;
  end;

  function IsEntry(const line: String): Boolean;
  begin
  	IsEntry := False;

    If Pos('=', line) <> 0 then
    	IsEntry := True;
  end;
begin
	Assign(inFile, FileName);
  Reset(inFile);

  while not Eof(inFile) do
  begin
  	ReadLn(inFile, line);

    if IsSection(line) then
    begin
    	sectionName := TrimChars(line, '[');
      sectionName := TrimChars(sectionName, ']');

      New(pSection, Init(sectionName));

      Insert(pSection);
      Continue;
    end;

    if IsEntry(line) then
    begin
    	New(pEntry, Init(line));
      pSection^.Insert(pEntry);
      Continue;
    end;
  end;

  Close(inFile);
end;

function TIniFile.FileName: String;
begin
	FileName := FFileName^;
end;

Constructor TIniFile.Init(const vFileName: String);
begin
	inherited Init(50, 10);
  FFileName := NewStr(vFileName);
  Load;
end;

Destructor TIniFile.Done;
begin
	DisposeStr(FFileName);
  inherited Done;
end;

(***********)
(* TxtFile *)
(***********)

function TTxtFile.Name: String;
{ Returns the file name }
begin
  Name := FName;
end;

function TTxtFile.Count: Byte;
{ Returns the number of lines in the file }
begin
  Count := FCount;
end;

function TTxtFile.Lines(const index: Integer): String;
{ Returns a line of text from the file based on
  the given index. }
begin
  Lines := FLines^[index];
end;

constructor TTxtFile.Init(const fileName: String);
{ Initialises an instance by load the file
  contents into the object. }
begin
	inherited Init;

  FName := fileName;
  FCount := GetFileLineCount;
  FAllocatedMem := FCount * SizeOf(TTxtFileLine);
  GetMem(FLines, FAllocatedMem);
  Load;
end;

destructor TTxtFile.Done;
{ Releases the object's resources, when the
  instance is no longer needed. }
begin
  FName := '';
  FreeMem(FLines, FAllocatedMem);

  inherited Done;
end;

function TTxtFile.GetFileLineCount: Byte;
{ Counts the number of lines in the given file }
var
  inFile: Text;
  lineCount: Byte;
  row: String;
begin
  lineCount := 0;

  Assign(inFile, FName);
  Reset(inFile);

  while not EOF(inFile) do
  begin
    ReadLn(inFile, row);
    Inc(lineCount);
  end;

  Close(inFile);

  GetFileLineCount := lineCount;
end;

procedure TTxtFile.Load;
{ This procedure loads the file contents into the object }
var
  inFile: Text;
  index: Byte;
  row: String;
begin
  index := 0;

  Assign(inFile, FName);
  Reset(inFile);

  while not EOF(inFile) do
  begin
    ReadLn(inFile, row);
    FLines^[index] := row;
    Inc(index);
  end;

  Close(inFile);
end;

procedure DumpTxtFile(pFile: PTxtFile);
{ Displays the file contents on screen }
var
	index: Byte;
  row: String;
begin
	row := '';

	WriteLn;

  for index := 0 to pFile^.Count - 1 do
  begin
    row := pFile^.Lines(index);
    WriteLn(row);
  end;

  WriteLn;
end;

(****************************)
(* Functions and Procedures *)
(****************************)
function IsDir(const path: DirStr): Boolean;
var
  hFile: File;
  attr: Word;
begin
  Assign(hFile, path);
  GetFAttr(hFile, attr);
  IsDir := (DosError = 0) and ((attr AND Directory) = Directory);
end;

function PathCombine(const aBasePath, aPath: PathStr): PathStr;
var
  aValue: String;
begin
	aValue := aBasePath;
  aValue := AddBackSlash (aValue);

  PathCombine := ConCat(aValue, aPath);
end;

function FileExists(const aName: PathStr): Boolean;
{ This function checks if the file exists }
var
  inFile: Text;
  attr: Word;
begin
  Assign(inFile, aName);
  GetFAttr(inFile, attr);

  if DosError <> 0 then
  begin
  	FileExists := False;
    Exit;
  end;

  if attr and VolumeID <> 0 then
  begin
  	FileExists := False;
    Exit;
	end;

  if attr and Directory <> 0 then
  begin
  	FileExists := False;
    Exit;
	end;

  FileExists := True;
end;

procedure Beep;
begin
  Sound(220);
  Delay(200);
  NoSound;
end;

begin
	LogFile.Init;
end.
