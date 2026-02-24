{==========================================================}
{ core.pas                                                 }
{                                                          }
{ Created: 19/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 19/02/2026 - Initial Version                             }
{==========================================================}
unit Core;

interface

type
	TFileName = String[128];

{ File handling routines }

function FileExists(const vFileName: TFileName): Boolean;
function FilePath(const vFileName: TFileName): String;
function FileExt(const vFileName: TFileName): String;
function FileName(const vFileName: TFileName): String;
function FullFileName(const vFileName: TFileName): String;
function SwapFileExt(const vFileName: TFileName; const vNewExt: String): TFileName;
function PathCombine(const vBasePath, vPath: TFileName): TFileName;

{ String handling routines }

function IsEmpty(value: String): Boolean;
procedure FillString(var value: String);
function LastPos(const c: Char; const value: String): Byte;
function Spaces(const num: Byte): String;

function UCase(const value: String): String;
function LCase(const value: String): String;

function RightTrim(const value: String; const ch: Char): String;
function LeftTrim(const value: String; const ch: Char): String;
function Trim(const value: String; const ch: Char): String;

function MidStr(const value: String; const startPos, numChars: Byte): String;
function LeftStr(const value: String; const numChars: Byte): String;
function RightStr(const value: String; const numChars: Byte): String;

function CommaString(const value: LongInt): String;
function FormatStr(const value, fmtString: String): String;
function FormatReal(value: Real; const fmtString: String): String;

function StartsWith(const subStr, vValue: String): Boolean;
function EndsWith(const subStr, vValue: String): Boolean;

{ Boolean handling routines }

function StrToBool(const value: String): Boolean;
function BoolToStr(const value: Boolean): String;

implementation

uses
	Dos, Strings;

const
	PathSeparator: Char = '\';
  FilePoint: Char = '.';

{ Boolean handling routines -------------------------------}

function BoolToStr(const value: Boolean): String;
begin
	BoolToStr := 'False';

  if value then
  	BoolToStr := 'True';
end;

function StrToBool(const value: String): Boolean;
var
	upValue: String;
begin
	upValue := UCase(value);

  StrToBool := False;
  if (upValue = 'TRUE') or (upValue = 'YES') or (upValue = '1') then
  	StrToBool := True;
end;

{ String handling routines --------------------------------}

function StartsWith(const subStr, vValue: String): Boolean;
var
	len: Integer;
  startValue: String;
begin
	if IsEmpty(vValue) or IsEmpty(subStr) then
  begin
  	StartsWith := False;
    Exit;
  end;

	len := Length(subStr);
  startValue := LeftStr(vValue, len);

  StartsWith := False;
  if UCase(subStr) = UCase(startValue) then
  	StartsWith := True;
end;

function EndsWith(const subStr, vValue: String): Boolean;
var
	len: Integer;
  endValue: String;
begin
	if IsEmpty(vValue) or IsEmpty(subStr) then
  begin
  	EndsWith := False;
    Exit;
  end;

	len := Length(subStr);
  endValue := RightStr(vValue, len);

  EndsWith := False;
  if UCase(subStr) = UCase(endValue) then
  	EndsWith := True;
end;

function CommaString(const value: LongInt): String;
var
	tempStr: String;
  orgLen: Byte;
begin
	Str(value, tempstr);
  orgLen := Length(tempstr);

  if orgLen > 3 then
  	begin
    	if orgLen < 7 then
      	Insert(',', tempstr, Length(tempstr) - 2);

      if orgLen >= 7 then
      	begin
        	Insert(',', tempstr, Length(tempstr) - 5);
          Insert(',', tempstr, Length(tempstr) - 2);
        end;
    end;
  CommaString := tempstr;
end;

function FormatStr(const value, fmtString: String): String;
var
	tempStr : String;
	i, j : Byte;
begin
	tempStr := '';

  if (Pos(',', fmtString) > 0) then
  	begin
    	FormatStr := value;

    	if Length(value) <= 3 then
				Exit;

    	j := 0;
    	for i := Length(value) downto 1 do
        begin
        	tempStr := value[i] + tempStr;
        	Inc(j);

        	if (j mod 3 = 0) and (tempStr[1] <> '.') then
						tempStr := ',' + tempStr;
        end;

    	while tempStr [1] = ',' do
          tempStr := Copy(tempStr, 2, Length(tempStr));
    end
	else
    begin
    	j := 0;

      for i := 1 to length(fmtString) do
        begin
        	if not (fmtString[I] in ['#', '!', '@', '*']) then
            begin
            	tempStr[i] := fmtString[i];
              j := Succ(j);
            end
          else
            begin
            	if i - j <= Length(value) then
              	tempStr[i] := value[i - j]
              else
              	tempStr[i] := ' ';
            end;
        end;

    	tempStr[0] := Char(Length(fmtString));
  	end;

	FormatStr := tempStr;
end;

function FormatReal(value: Real; const fmtString: String): String;
var
	tmp : String;
begin
  Str(value:12:2, tmp);

  while (not (tmp[1] in ['0'..'9', '.'])) and (tmp > '') do
		Delete(tmp, 1, 1);

  FormatReal := FormatStr(tmp, fmtString);
end;

function MidStr(const value: String; const startPos, numChars: Byte): String;
begin
	MidStr := Copy(value, startPos, numChars);
end;

function LeftStr(const value: String; const numChars: Byte): String;
begin
	LeftStr := Copy(value, 1, numChars);
end;

function RightStr(const value: String; const numChars: Byte): String;
begin
	RightStr := Copy(value, (Length(value) - (numChars - 1)), numChars);
end;

function UCase(const value: String): String; assembler;
asm
		PUSH	DS
    CLD
    LDS		SI, value
    XOR		AX, AX
    LODSB
    XCHG	AX, CX
    LES		DI, @Result
    MOV		BYTE PTR ES:[DI], CL
    JCXZ	@@3
    INC 	DI

@@1:	LODSB
			CMP		AL, 'a'
      JB		@@2
      CMP		AL, 'z'
      JA		@@2
      OR		AL, $20

@@2:	STOSB
      LOOP	@@1

@@3:  POP		DS
end;

function LCase(const value: String): String; assembler;
asm
		PUSH	DS
    CLD
    LDS		SI, value
    XOR		AX, AX
    LODSB
    XCHG	AX, CX
    LES		DI, @Result
    MOV		BYTE PTR ES:[DI], CL
    JCXZ	@@3

@@1:	LODSB
			CMP		AL, 'A'
      JB		@@2
      CMP		AL, 'Z'
      JA		@@2
      OR		AL, $20

@@2:	STOSB
      LOOP	@@1

@@3:  POP		DS
end;

function IsEmpty(value: String): Boolean; assembler;
asm
			CLD
  		XOR		CH, CH
  		LES		DI, value
  		MOV		CL, BYTE PTR ES:[DI]
  		JCXZ	@@1
  		INC		DI
  		MOV		AL, ' '
  		REPE	SCASB
  		JZ		@@1
  		MOV		AL, False
  		JMP		@@2
@@1:  MOV   AL, True
@@2:
end;

function Spaces(const num: Byte): String; assembler;
asm
	LES		DI, @Result
  CLD
  MOV		AL, num
  XOR		AH, AH
  STOSB
  XCHG	AX, CX
  JCXZ  @Exit
  MOV		AL, ' '
  SHR		CX, 1
  JNC		@Even
  STOSB
@Even: 	REP	STOSW
@Exit:
end;

function LastPos(const c: Char; const value: String): Byte;
var
	i: Word;
  len: Byte absolute value;
begin
	i := Succ(len);
  repeat
  	Dec(i);
  until (i = 0) or (value[i] = c);

	LastPos := i;
end;

procedure FillString(var value: String);
begin
	FillChar(value, SizeOf(value), 0);
end;

function RightTrim(const value: String; const ch: Char): String;
{ Trims trailing characters from a given string }
var
	len: Byte;
begin
	RightTrim := value;
  len := Ord(value[0]);

  while value[len] = ch do
  	Dec(len);

  RightTrim[0] := Chr(len);
end;

function LeftTrim(const value: String; const ch: Char): String;
{ Trims the leading characters from a given string }
var
	cnt: Byte;
begin
	cnt := 1;

  while value[cnt] = ch do
  	Inc(cnt);

  LeftTrim := Copy(value, cnt, Length(value) - Pred(cnt));
end;

function Trim(const value: String; const ch: Char): String;
{ Trims the leading and trailing characters of the string }
begin
	Trim := LeftTrim(RightTrim(value, ch), ch);
end;

{ File handling routines ----------------------------------}

function PathCombine(const vBasePath, vPath: TFileName): TFileName;
var
  vValue: String;
begin
	vValue := vBasePath;

	If not EndsWith(PathSeparator, vValue) then
  begin
  	vValue := vValue + PathSeparator;
  end;

  vValue := vValue + vPath;
  PathCombine := vValue;
end;

function FileExists(const vFileName: TFileName): Boolean;
{ This function checks if the file exists }
var
  inFile: Text;
  attr: Word;
begin
  Assign(inFile, vFileName);
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

function SwapFileExt(const vFileName: TFileName; const vNewExt: String): TFileName;
{ Returns a new file name with the new extension }
var
	d: DirStr;
  n: NameStr;
  e: ExtStr;
  vValue: String;
begin
	FSplit(vFileName, d, n, e);

  vValue := d + n;
  vValue := vValue + vNewExt;

  SwapFileExt := vValue;
end;

function FilePath(const vFileName: TFileName): String;
{ Extracts the path element from a qualified file name }
var
	d: DirStr;
  n: NameStr;
  e: ExtStr;
begin
	FSplit(vFileName, d, n, e);
  FilePath := d;
end;

function FileExt(const vFileName: TFileName): String;
{ Extracts the ext element from a qualified file name }
var
	d: DirStr;
  n: NameStr;
  e: ExtStr;
begin
	FSplit(vFileName, d, n, e);
  FileExt := e;
end;

function FileName(const vFileName: TFileName): String;
{ Extracts the name element from a qualified file name }
var
	d: DirStr;
  n: NameStr;
  e: ExtStr;
begin
	FSplit(vFileName, d, n, e);
  FileName := n;
end;

function FullFileName(const vFileName: TFileName): String;
{ Extracts the name and extension elements from a qualified file name }
var
	d: DirStr;
  n: NameStr;
  e: ExtStr;
begin
	FSplit(vFileName, d, n, e);
  FullFileName := n + e;
end;
end.
