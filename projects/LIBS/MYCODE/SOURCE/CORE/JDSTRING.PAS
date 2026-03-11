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

uses
	Dos;

function IsEmpty(value: String): Boolean;
function LastPos(const c: Char; const value: String): Byte;
function Spaces(const num: Byte): String;

function MidString(const value: String; const startPos, numChars: Byte): String;
function LeftString(const value: String; const numChars: Byte): String;
function RightString(const value: String; const numChars: Byte): String;

function StartsWith(const subStr, vValue: String): Boolean;
function EndsWith(const subStr, vValue: String): Boolean;

function TrimChars(const aValue: String; const ch: Char): String;

{--------------- Boolean support -----------------}

function StrToBool(const value: String): Boolean;
function BoolToStr(const value: Boolean): String;

(******************)
(* Implementation *)
(******************)
implementation

uses
	TPString;

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

function TrimChars(const aValue: String; const ch: Char): String;
var
	value: String;
  len: Byte;
begin
	value := aValue;
  len := Length(value);

  if value[1] = ch then
  	begin
    	value := Copy(value, 2, len);
      len := Length(value);
    end;

  if value[len] = ch then
  	value := Copy(value, 1, len - 1);

  TrimChars := value;
end;

end.

