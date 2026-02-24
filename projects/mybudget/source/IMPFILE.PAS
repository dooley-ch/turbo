{==========================================================}
{ impfile.pas                                              }
{                                                          }
{ Created: 23/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 23/02/2026 - Initial Version                             }
{==========================================================}
unit ImpFile;

interface

uses
	Objects, DateUtil, TransCls, TxtFile;

type
	TStatementFile = object(TCollection)
  private
  	FFileName: PString;
    FFromDate,
    FToDate: TDate;
    FTitle: PString;
    FAccount: PString;

    procedure Load(const pFile: PTextFile); virtual;
  public
  	function FileName: String;
    function FromDate: String;
    function ToDate: String;
    function Account: String;
    function Title: String;

    function Item(const index: Integer): PImportTransaction;

    constructor Init(const vFileName: String);
    destructor Done; virtual;
  end;

  PBankFile = ^TBankFile;
  TBankFile = object(TStatementFile)
  private
    procedure Load(const pFile: PTextFile); virtual;
  public
    constructor Init(const vFileName: String);
    destructor Done; virtual;
  end;

  PCreditCardFile = ^TCreditCardFile;
  TCreditCardFile = object(TStatementFile)
  private
    procedure Load(const pFile: PTextFile); virtual;
  public
    constructor Init(const vFileName: String);
    destructor Done; virtual;
  end;

{******************}
{* Implementation *}
{******************}
implementation

uses
	Core, LogFile;

{ TStatementFile ------------------------------------------}

procedure TStatementFile.Load(const pFile: PTextFile);
begin
	RunError(211);
end;

function TStatementFile.FileName: String;
begin
	FileName := FFileName^;
end;

function TStatementFile.FromDate: String;
begin
	FromDate := FFromDate.ToString;
end;

function TStatementFile.ToDate: String;
begin
	ToDate := FToDate.ToString;
end;

function TStatementFile.Account: String;
begin
	Account := FAccount^;
end;

function TStatementFile.Title: String;
begin
	Title := FTitle^;
end;

function TStatementFile.Item(const index: Integer): PImportTransaction;
begin
	Item := PImportTransaction(At(index));
end;

constructor TStatementFile.Init(const vFileName: String);
var
	pFile: PTextFile;
begin
  inherited Init(50, 10);

  FFileName := NewStr(vFileName);

  FFromDate.Init;
  FToDate.Init;
  FTitle := Nil;
  FAccount := Nil;

  New(pFile, Init(vFileName));
  Load(pFile);
  Dispose(pFile, Done);
end;

destructor TStatementFile.Done;
begin
	DisposeStr(FFileName);

  if FTitle <> Nil then
  	DisposeStr(FTitle);
  if FAccount <> Nil then
  	DisposeStr(FAccount);

  inherited Done;
end;

{ TBankFile -----------------------------------------------}

procedure TBankFile.Load(const pFile: PTextFile);
const
 	FromDate_Line: Integer    = 0;
 	ToDate_Line: Integer      = 1;
 	Account_Line: Integer     = 3;
 	Transaction_Line: Integer = 8;

var
	vBookDate, vDesc, vCr, vDr,
	line, vValue: String;
  vDay, vMonth, vYear: Word;
  index: Integer;
  pTransaction: PImportTransaction;

  function ExtractValue(const value: String): String;
  var
  	len,
  	charPos: Byte;
  begin
  	vValue := '';
    len := Length(value);
    charPos := Pos('=', value);

  	if charPos <> 0 then
  		begin
    		vValue := Copy(line, charPos + 1, len - charPos);
      	vValue := Trim(vValue, '"');
      end;

    ExtractValue := vValue;
  end;

  procedure ExtractTransValues(const line: String;
  															var vBookDate, vDesc, vDr, vCr: String);
  var
  	subLine, vValue: String;
    len: Byte;
    charPos: Byte;
  begin
  	vValue := '';
  	subLine := '';
    charPos := 0;
  	vBookDate := '';
    vDesc := '';
    vDr := '';
    vCr := '';
    len := Length(line);

    { Booking Date }
  	vBookDate := Copy(line, 1, 10);
    subLine := Copy(line, 18, len - 18);

    { Description }
    charPos := Pos(';', subLine);
    vValue := Copy(subLine, 1, charPos - 1);
    vValue := Trim(vValue, '"');
    vDesc := vValue;
    len := Length(subLine);
    subLine := Copy(subLine, charPos + 1, len - charPos);

    { Credit Amount }
    charPos := Pos(';', subLine);
    if charPos = 1 then
    	begin
      	vCr := '0';
        len := Length(subLine);
        subLine := Copy(subLine, 2, len - 1);
      end
    else
    	begin
      	vCr := Copy(subLine, 1, charPos - 1);
        len := Length(subLine);
        subLine := Copy(subLine, charPos + 1, len - charPos);
      end;

    { Debit Amount }
    charPos := Pos(';', subLine);
    if charPos = 1 then
    	vDr := '0'
    else
    	vDr := Copy(subLine, 1, charPos - 1);
	end;
begin
	line := '';
  vValue := '';

  { Extract the statement from date }
  line := pFile^.Line(FromDate_Line);
  vValue := ExtractValue(line);
  if ParseDateEx(vValue, '.', dfDayMonthYear,
												vDay, vMonth, vYear) then
  	FFromDate.SetValue(vDay, vMonth, vYear);

  { Extract the statement to date }
  line := pFile^.Line(ToDate_Line);
  vValue := ExtractValue(line);
  if ParseDateEx(vValue, '.', dfDayMonthYear,
												vDay, vMonth, vYear) then
  	FToDate.SetValue(vDay, vMonth, vYear);

  { Extract the statement account number }
  line := pFile^.Line(Account_Line);
  vValue := ExtractValue(line);
  FAccount := NewStr(vValue);

  { Create the title }
  vValue := 'Bank Statement: '
							+ FFromDate.ToString + ' - ' + FToDate.ToString;
  FTitle := NewStr(vValue);

  { Process the transactions }
  for index := Transaction_Line to pFile^.Count - 1 do
  	begin
      line := pFile^.Line(index);
      if IsEmpty(line) then
      	Break;

      ExtractTransValues(line, vBookDate, vDesc, vDr, vCr);

      if ParseDateEx(vBookDate, '.', dfDayMonthYear,
												vDay, vMonth, vYear) then
      	vBookDate := FormatDateStr(vDay, vMonth, vYear);

      New(pTransaction, Init(vBookDate, vDesc, vDr, vCr));
      Insert(pTransaction);
    end;
end;

constructor TBankFile.Init(const vFileName: String);
begin
	inherited Init(vFileName);
  LogInfo('Bank Statement loaded: ' + FullFileName(vFileName));
end;

destructor TBankFile.Done;
begin
	inherited Done;
end;

{ TCreditCardFile -----------------------------------------}

procedure TCreditCardFile.Load(const pFile: PTextFile);
const
 Account_Line: Integer     = 0;
 Transaction_Line: Integer = 6;

var
	vBookDate, vDesc, vCr, vDr,
	line, vValue: String;
  vDay, vMonth, vYear: Word;
  index: Integer;
  pTransaction: PImportTransaction;
	fromStr, toStr: String;

	procedure GetToFromDates(const line: String; var fromStr, toStr: String);
	var
  	index: Byte;
  	values: String;
	begin
  	index := Pos(';', line);
  	values := Copy(line, 1, index - 1);
  	fromStr := Copy(values, 1, 10);
  	toStr := Copy(values, index - 10, 10);
	end;

	function GetAccount(const line: String): String;
	var
  	index, lineLen: Byte;
	begin
  	lineLen := Length(line);
  	index := Pos(';', line);
  	GetAccount := Copy(line, index + 1, lineLen - index);
	end;

  procedure ExtractTransValues(const line: String;
  															var vBookDate, vDesc, vDr, vCr: String);
  var
  	subLine, vValue: String;
    len: Byte;
    charPos: Byte;
  begin
  	vValue := '';
  	subLine := '';
    charPos := 0;
  	vBookDate := '';
    vDesc := '';
    vDr := '';
    vCr := '';
    len := Length(line);

    { Booking Date }
    subLine := Copy(line, 25, len - 23);
  	vBookDate := Copy(subLine, 1, 10);

    len := Length(subLine);
    subLine := Copy(subLine, 23, len - 23);

    { Description }
    charPos := Pos(';', subLine);
    vValue := Copy(subLine, 1, charPos - 1);
    vValue := Trim(vValue, '"');
    vDesc := vValue;
    len := Length(subLine);
    subLine := Copy(subLine, charPos + 1, len - charPos);

    { Credit Amount }
    charPos := Pos(';', subLine);
    if charPos = 1 then
    	begin
      	vCr := '0';
        len := Length(subLine);
        subLine := Copy(subLine, 2, len - 1);
      end
    else
    	begin
      	vCr := Copy(subLine, 1, charPos - 1);
        len := Length(subLine);
        subLine := Copy(subLine, charPos + 1, len - charPos);
      end;

    { Debit Amount }
    charPos := Pos(';', subLine);
    if charPos = 1 then
    	vDr := '0'
    else
    	vDr := Copy(subLine, 1, charPos - 1);
	end;
begin
  { Extract the from and to dates }
  line := pFile^.Line(Transaction_Line);
  GetToFromDates(line, fromStr, toStr);

  if ParseDateEx(fromStr, '.', dfDayMonthYear,
												vDay, vMonth, vYear) then
  	FFromDate.SetValue(vDay, vMonth, vYear);

  if ParseDateEx(vValue, '.', dfDayMonthYear,
												vDay, vMonth, vYear) then
  	FToDate.SetValue(vDay, vMonth, vYear);

  { Extract the statement account number }
  line := pFile^.Line(Account_Line);
  vValue := GetAccount(line);
  FAccount := NewStr(vValue);

  { Create the title }
  vValue := 'Credit Card Statement: '
							+ FFromDate.ToString + ' - ' + FToDate.ToString;
  FTitle := NewStr(vValue);

  { Process the transactions }
  for index := Transaction_Line to pFile^.Count - 1 do
  	begin
      line := pFile^.Line(index);
      if IsEmpty(line) then
      	Break;

      ExtractTransValues(line, vBookDate, vDesc, vDr, vCr);

      if ParseDateEx(vBookDate, '.', dfDayMonthYear,
												vDay, vMonth, vYear) then
      	vBookDate := FormatDateStr(vDay, vMonth, vYear);

      New(pTransaction, Init(vBookDate, vDesc, vDr, vCr));
      Insert(pTransaction);
    end;
end;

constructor TCreditCardFile.Init(const vFileName: String);
begin
	inherited Init(vFileName);
  LogInfo('Credit Card Statement loaded: ' + FullFileName(vFileName));
end;

destructor TCreditCardFile.Done;
begin
	inherited Done;
end;

end.
