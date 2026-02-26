{==========================================================}
{ inifile.pas                                              }
{                                                          }
{ Created: 17/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 17/02/2026 - Initial Version                             }
{==========================================================}

{ Defines the class used to load the application ini file }

unit IniFile;

interface

uses
	Objects, Strings;

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

    function ToString: String;
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

  procedure DumpIniFile(const vFile: PIniFile);

implementation

uses
	Core;

procedure DumpIniFile(const vFile: PIniFile);
var
	i, j: Integer;
  pSector: PIniSection;
  pEntry: PIniEntry;
begin
	WriteLn;
  WriteLn('File Name: ' + vFile^.FileName);
  WriteLn;

  for i := 0 to vFile^.Count - 1 do
  begin
    pSector := PIniSection(vFile^.At(i));
    WriteLn(pSector^.ToString);

    for j := 0 to pSector^.Count - 1 do
    begin
    	pEntry := PIniEntry(pSector^.At(j));
      WriteLn(pEntry^.ToString);
    end;

    WriteLn;
  end;
end;

{ TIniFile ------------------------------------------------}

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
    	sectionName := TrimChar(line, '[');
      sectionName := TrimChar(sectionName, ']');

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

{ TIniSection ---------------------------------------------}

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

{ TIniEntry -----------------------------------------------}

function TIniEntry.ToString: String;
begin
	ToString := Name + '=' + Value;
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

      vValue := TrimChar(vValue, #32);
      vValue := TrimChar(vValue, #9);
      vValue := TrimChar(vValue, '"');
      vValue := TrimChar(vValue, '''');
      vValue := TrimChar(vValue, ' ');

      vKey := TrimChar(vKey, #32);
      vKey := TrimChar(vKey, #9);
      vKey := TrimChar(vKey, '"');
      vKey := TrimChar(vKey, '''');
      vKey := TrimChar(vKey, ' ');

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

end.