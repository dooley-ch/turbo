(*--------------------------------------------------------*)
(*   JDSTRING.PAS                                         *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   04/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit JDString;

interface

type
  CompareType = (Less, Equal, Greater);

{-------- Numeric conversion -----------}

function HexPtr(P: Pointer): String;
	{-Return hex String for pointer}

function Str2Int(S: String; var I: Integer): Boolean;
  {-Convert a string to an integer, returning true if successful}

function Str2Word(S: String; var I: Word): Boolean;
  {-Convert a string to a word, returning true if successful}

function Str2Long(S: String; var I: LongInt): Boolean;
  {-Convert a string to an longint, returning true if successful}

function Str2Real(S: String; var R: Real): Boolean;
  {-Convert a string to a real, returning true if successful}

function Long2Str(L: LongInt): String;
  {-Convert a longint/word/integer/byte/shortint to a string}

function Real2Str(R: Real; Width, Places: Byte): String;
  {-Convert a real to a string}

{-------- General purpose string manipulation --------}

function IsEmpty(value: String): Boolean;
function LastPos(const c: Char; const value: String): Byte;
function Spaces(const num: Byte): String;

function MidString(const value: String; const startPos, numChars: Byte): String;
function LeftString(const value: String; const numChars: Byte): String;
function RightString(const value: String; const numChars: Byte): String;

function StartsWith(const subStr, vValue: String): Boolean;
function EndsWith(const subStr, vValue: String): Boolean;

function UpCaseMac(Ch: Char): Char;
  {-Uppercase character macro, no international character support}
  inline(
    $58/                     {POP  AX}
    $3C/$61/                 {CMP    AL,'a'}
    $72/$06/                 {JB     No}
    $3C/$7A/                 {CMP    AL,'z'}
    $77/$02/                 {JA     No}
    $24/$DF);                {AND    AL,$DF}
                             {No:}

function LoCaseMac(Ch: Char): Char;
  {-Lowercase character macro, no international character support}
  inline(
    $58/                     {POP  AX}
    $3C/$41/                 {CMP    AL,'A'}
    $72/$06/                 {JB     No}
    $3C/$5A/                 {CMP    AL,'Z'}
    $77/$02/                 {JA     No}
    $0C/$20);                {OR     AL,$20}
                             {No:}

function Upcase(Ch: Char): Char;
  {-Return uppercase of char, with international character support}

function StUpcase(S: String): String;
  {-Convert lower case letters in string to uppercase, with intl chars}

function LoCase(Ch: Char): Char;
  {-Return lowercase of char, with international character support}

function StLocase(S: String): String;
  {-Convert upper case letters in string to lowercase, with intl chars}

function CharStr(Ch: Char; Len: Byte) : String;
  {-Return a string of length len filled with ch}

function PadCh(S: String; Ch: Char; Len: Byte): String;
  {-Return a string right-padded to length len with ch}

function Pad(S: String; Len: Byte): String;
  {-Return a string right-padded to length len with blanks}

function LeftPadCh(S: String; Ch: Char; Len: Byte): String;
  {-Return a string left-padded to length len with ch}

function LeftPad(S: String; Len: Byte): String;
  {-Return a string left-padded to length len with blanks}

function TrimLead(S: String): String;
  {-Return a string with leading white space removed}

function TrimTrail(S: String): string;
  {-Return a string with trailing white space removed}

function Trim(S: String): String;
  {-Return a string with leading and trailing white space removed}

function CenterCh(S: String; Ch: Char; Width: Byte): String;
  {-Return a string centered in a string of Ch with specified width}

function Center(S: String; Width: Byte): String;
  {-Return a string centered in a blank string of specified width}

{--------------- String comparison and searching -----------------}

function CompString(S1, S2: String): CompareType;
  {-Return less, equal, greater if s1<s2, s1=s2, or s1>s2}

function CompUCString(S1, S2: String): CompareType;
  {-Compare two strings in a case insensitive manner}

function CompStruct(var S1, S2; Size: Word): CompareType;
  {-Compare two fixed size structures}

{--------------- DOS pathname parsing -----------------}

function DefaultExtension(Name, Ext: String): String;
  {-Return a file name with a default extension attached}

function ForceExtension(Name, Ext: String): String;
  {-Force the specified extension onto the file name}

function JustFilename(PathName: String): String;
  {-Return just the filename and extension of a pathname}

function JustExtension(Name: String): String;
  {-Return just the extension of a pathname}

function JustPathname(PathName: String): String;
  {-Return just the drive:directory portion of a pathname}

function AddBackSlash(DirName: String): String;
  {-Add a default backslash to a directory name}

function CleanPathName(PathName: String): String;
  {-Return a pathname cleaned up as DOS will do it}

function FullPathName(FName: String): String;
  {-Given FName (known to exist), return a full pathname}

{--------------- Boolean support -----------------}

function StrToBool(const value: String): Boolean;
function BoolToStr(const value: Boolean): String;

(******************)
(* Implementation *)
(******************)
implementation

const
  Digits: array[0..$F] of Char = '0123456789ABCDEF';
	DosDelimSet : set of Char = ['\', ':', #0];

  {used by CompareLetterSets for estimating word similarity}
  LetterValues : array['A'..'Z'] of Byte = (
    3 {A} , 6 {B} , 5 {C} , 4 {D} , 3 {E} , 5 {F} , 5 {G} , 4 {H} , 3 {I} ,
    8 {J} , 7 {K} , 4 {L} , 5 {M} , 3 {N} , 3 {O} , 5 {P} , 7 {Q} , 4 {R} ,
    3 {S} , 3 {T} , 4 {U} , 6 {V} , 5 {W} , 8 {X} , 8 {Y} , 9 {Z} );

{$L JDCASE.OBJ}
{$L JDCOMP.OBJ}

function HexW(W: Word): String;
	{-Return hex string for word}
begin
	HexW[0] := #4;
  HexW[1] := Digits[hi(W) shr 4];
  HexW[2] := Digits[hi(W) and $F];
  HexW[3] := Digits[lo(W) shr 4];
  HexW[4] := Digits[lo(W) and $F];
end;

function HexPtr(P: Pointer): String;
	{-Return hex string for pointer}
begin
	HexPtr := HexW(Seg(P^)) + ':' + HexW(Ofs(P^));
end;

function Str2Int(S: String; var I: Integer): Boolean;
	{-Convert a string to an integer, returning true if successful}
var
	code: Word;
  SLen: Byte absolute S;
begin
	while S[SLen] = ' ' do
  	Dec(SLen);

  Val(S, I, code);
  if code <> 0 then
		begin
      I := code;
      Str2Int := False;
    end
	else
  	Str2Int := True;
end;

function Str2Word(S: String; var I: Word): Boolean;
	{-Convert a string to a word, returning true if successful}
var
	code: Word;
  SLen: Byte absolute S;
begin
	while S[SLen] = ' ' do
  	Dec(SLen);

  Val(S, I, code);
  if code <> 0 then
		begin
      I := code;
      Str2Word := False;
    end
	else
  	Str2Word := True;
end;

function Str2Long(S: String; var I: LongInt): Boolean;
	{-Convert a string to a longint, returning true if successful}
var
	code: Word;
  SLen: Byte absolute S;
begin
	while S[SLen] = ' ' do
  	Dec(SLen);

  Val(S, I, code);

  if code <> 0 then
		begin
      I := code;
      Str2Long := False;
    end
	else
  	Str2Long := True;
end;

function Str2Real(S: String; var R: Real): Boolean;
	{-Convert a string to a real, returning true if successful}
var
	Code, I: Word;
  SLen: Byte absolute S;
begin
	while S[SLen] = ' ' do
  	Dec(SLen);

  Val(S, R, Code);

  if Code <> 0 then
		begin
      R := Code;
      Str2Real := False;
  	end
	else
    Str2Real := True;
end;

function Long2Str(L: LongInt): String;
	{-Convert a long/word/integer/byte/shortint to a string}
var
  S: String;
begin
  Str(L, S);
  Long2Str := S;
end;

function Real2Str(R: Real; Width, Places: Byte): String;
  {-Convert a real to a string}
var
  S: String;
begin
  Str(R:Width:Places, S);
  Real2Str := S;
end;

(* In TPCASE.OBJ *)
procedure UpCasePrim; external;
procedure LoCasePrim; external;
function Upcase(Ch : Char): Char; external;
function LoCase(Ch : Char): Char; external;
function StUpcase(S : string): string; external;
function StLocase(S : string): string; external;

function CharStr(Ch: Char; Len: Byte): String;
	{-Return a string of length len filled with ch}
var
	S: String;
begin
	if Len = 0 then
  	CharStr[0] := #0
  else
		begin
      S[0] := Chr(Len);
      FillChar(S[1], Len, Ch);
      CharStr := S;
    end;
end;

function PadCh(S: String; Ch: Char; Len: Byte): String;
	{-Return a string right-padded to length len with ch}
var
	o: String;
  SLen: Byte absolute S;
begin
	if Length(S) >= Len then
  	PadCh := S
  else
		begin
      o[0] := Chr(Len);
      Move(S[1], o[1], SLen);
      if SLen < 255 then
        FillChar(o[Succ(SLen)], Len-SLen, Ch);
      PadCh := o;
  	end;
end;

function Pad(S: String; Len: Byte): String;
	{-Return a string right-padded to length len with blanks}
begin
	Pad := PadCh(S, ' ', Len);
end;

function LeftPadCh(S: String; Ch: Char; Len: Byte): String;
	{-Return a string left-padded to length len with ch}
var
	o: String;
  SLen: Byte absolute S;
begin
	if Length(S) >= Len then
  	LeftPadCh := S
  else if SLen < 255 then
		begin
      o[0] := Chr(Len);
      Move(S[1], o[Succ(Word(Len))-SLen], SLen);
      FillChar(o[1], Len-SLen, Ch);
      LeftPadCh := o;
    end;
end;

function LeftPad(S : String; Len : Byte): String;
	{-Return a string left-padded to length len with blanks}
begin
	LeftPad := LeftPadCh(S, ' ', Len);
end;

function TrimLead(S : String): String;
	{-Return a string with leading white space removed}
var
	I: Word;
begin
	I := 1;

  while (I <= Length(S)) and (S[I] <= ' ') do
  	Inc(I);

  Dec(I);

  if I > 0 then
  	Delete(S, 1, I);

	TrimLead := S;
end;

function TrimTrail(S : String) : String;
	{-Return a string with trailing white space removed}
var
	SLen: Byte absolute S;
begin
	while (SLen > 0) and (S[SLen] <= ' ') do
  	Dec(SLen);
  TrimTrail := S;
end;

function Trim(S : String) : String;
	{-Return a string with leading and trailing white space removed}
var
	I: Word;
  SLen: Byte absolute S;
begin
	while (SLen > 0) and (S[SLen] <= ' ') do
  	Dec(SLen);

  I := 1;
  while (I <= SLen) and (S[I] <= ' ') do
  	Inc(I);

  Dec(I);

  if I > 0 then
  	Delete(S, 1, I);

  Trim := S;
end;

function CenterCh(S: String; Ch: Char; Width: Byte): String;
	{-Return a string centered in a string of Ch with specified width}
var
	o: String;
	SLen: Byte absolute S;
begin
	if SLen >= Width then
  	CenterCh := S
  else
		if SLen < 255 then
			begin
      	o[0] := Chr(Width);
      	FillChar(o[1], Width, Ch);
      	Move(S[1], o[Succ((Width-SLen) shr 1)], SLen);
      	CenterCh := o;
    	end;
end;

function Center(S: String; Width: Byte): String;
	{-Return a string centered in a blank string of specified width}
begin
	Center := CenterCh(S, ' ', Width);
end;

(* In TPCOMP.OBJ *)
function CompString(S1, S2 : String) : CompareType; external;
function CompUCString(S1, S2 : String) : CompareType; external;
function CompStruct(var S1, S2; Size : Word) : CompareType; external;

function HasExtension(Name: String; var DotPos : Word) : Boolean;
  {-Return whether and position of extension separator dot in a pathname}
var
  I : Word;
begin
  DotPos := 0;
  for I := Length(Name) downto 1 do
    if (Name[I] = '.') and (DotPos = 0) then
      DotPos := I;
  HasExtension := (DotPos > 0) and (Pos('\', Copy(Name, Succ(DotPos), 64)) = 0);
end;

function DefaultExtension(Name, Ext: String): String;
  {-Return a pathname with the specified extension attached}
var
  DotPos : Word;
begin
  if HasExtension(Name, DotPos) then
    DefaultExtension := Name
  else
    DefaultExtension := Name+'.'+Ext;
end;

function ForceExtension(Name, Ext: String): String;
  {-Return a pathname with the specified extension attached}
var
  DotPos : Word;
begin
  if HasExtension(Name, DotPos) then
    ForceExtension := Copy(Name, 1, DotPos)+Ext
  else
    ForceExtension := Name+'.'+Ext;
end;

function JustExtension(Name: String): String;
  {-Return just the extension of a pathname}
var
  DotPos : Word;
begin
  if HasExtension(Name, DotPos) then
    JustExtension := Copy(Name, Succ(DotPos), 3)
  else
    JustExtension[0] := #0;
end;

function JustFilename(PathName: String): String;
  {-Return just the filename of a pathname}
var
  I : Word;
begin
  I := Succ(Word(Length(PathName)));

  repeat
    Dec(I);
  until (PathName[I] in DosDelimSet) or (I = 0);

  JustFilename := Copy(PathName, Succ(I), 64);
end;

function JustPathname(PathName: String): String;
  {-Return just the drive:directory portion of a pathname}
var
  I : Word;
begin
  I := Succ(Word(Length(PathName)));
  repeat
    Dec(I);
  until (PathName[I] in DosDelimSet) or (I = 0);

  if I = 0 then
    {Had no drive or directory name}
    JustPathname[0] := #0
  else
		if I = 1 then
    	{Either the root directory of default drive or invalid pathname}
    	JustPathname := PathName[1]
  	else
			if (PathName[I] = '\') then
				begin
    			if PathName[Pred(I)] = ':' then
      			{Root directory of a drive, leave trailing backslash}
      			JustPathname := Copy(PathName, 1, I)
    			else
      			{Subdirectory, remove the trailing backslash}
      			JustPathname := Copy(PathName, 1, Pred(I));
  			end
			else
    		{Either the default directory of a drive or invalid pathname}
    		JustPathname := Copy(PathName, 1, I);
end;

function AddBackSlash(DirName: String): String;
  {-Add a default backslash to a directory name}
begin
  if DirName[Length(DirName)] in DosDelimSet then
    AddBackSlash := DirName
  else
    AddBackSlash := DirName+'\';
end;

function CleanFileName(FileName: String): String;
  {-Return filename with at most 8 chars of name and 3 of extension}
var
  DotPos : Word;
  namelen : Word;
begin
  if HasExtension(FileName, DotPos) then
		begin
    	{Take the first 8 chars of name and first 3 chars of extension}
    	namelen := Pred(DotPos);

    	if namelen > 8 then
      	namelen := 8;
    	CleanFileName := Copy(FileName, 1, namelen)+Copy(FileName, DotPos, 4);
  	end
	else
    {Take the first 8 chars of name}
    CleanFileName := Copy(FileName, 1, 8);
end;

function CleanPathName(PathName: String): String;
  {-Return a pathname cleaned up as DOS will do it}
var
  I : Word;
  oname: String;
begin
  oname[0] := #0;
  I := Succ(Word(Length(PathName)));

  repeat
    {Get the next directory or drive portion of pathname}
    repeat
      Dec(I);
    until (PathName[I] in DosDelimSet) or (I = 0);

    {Clean it up and prepend it to output String}
    oname := CleanFileName(Copy(PathName, Succ(I), 64))+oname;
    if I > 0 then
			begin
      	oname := PathName[I]+oname;
      	Delete(PathName, I, 255);
    	end;
  until I <= 0;

  CleanPathName := oname;
end;

function FullPathName(FName: String): String;
  {-Given FName (known to exist), return a full pathname}
var
  CurDir: String[64];
  Cpos: Byte;
begin
  Cpos := Pos(':', FName);

  if Cpos <> 0 then
		begin
    	{Drive letter specified}
    	if FName[Succ(Cpos)] = '\' then
      	{Complete path already specified}
      	FullPathName := FName
    	else
				begin
      		{Drive specified, but incomplete path}
      		GetDir(Pos(Upcase(FName[1]), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), CurDir);
      		FullPathName := AddBackSlash(CurDir)+Copy(FName, Succ(Cpos), 100);
    		end;
  	end
	else
		begin
    	{No drive specified}
    	GetDir(0, CurDir);

    	if FName[1] = '\' then
      	{Complete path but no drive}
      	FullPathName := Copy(CurDir, 1, 2)+FName
    	else
      	{No drive, incomplete path}
      	FullPathName := AddBackSlash(CurDir)+FName;
  	end;
end;

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
	upValue := StUpcase(value);

  StrToBool := False;
  if (upValue = 'TRUE') or (upValue = 'YES') or (upValue = '1') then
  	StrToBool := True;
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

function MidString(const value: String; const startPos, numChars: Byte): String;
begin
	MidString := Copy(value, startPos, numChars);
end;

function LeftString(const value: String; const numChars: Byte): String;
begin
	LeftString := Copy(value, 1, numChars);
end;

function RightString(const value: String; const numChars: Byte): String;
begin
	RightString := Copy(value, (Length(value) - (numChars - 1)), numChars);
end;

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
  startValue := LeftString(vValue, len);

  StartsWith := False;
  if StUpcase(subStr) = StUpcase(startValue) then
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
  endValue := RightString(vValue, len);

  EndsWith := False;
  if StUpcase(subStr) = StUpcase(endValue) then
  	EndsWith := True;
end;

end.

