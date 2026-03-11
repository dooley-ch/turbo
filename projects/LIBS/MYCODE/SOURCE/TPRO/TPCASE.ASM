;******************************************************
;		   TPCASE.ASM 5.05
;	       String handling routines
;	 Copyright (c) TurboPower Software 1987.
; Portions copyright (c) Sunny Hill Software 1985, 1986
;     and used under license to	TurboPower Software
;		 All rights reserved.
;******************************************************

	INCLUDE	TPCOMMON.ASM

;******************************************************	Code

CODE	SEGMENT	BYTE PUBLIC

	ASSUME	CS:CODE

	PUBLIC	Upcase,	Locase
	PUBLIC	StUpcase, StLocase
	PUBLIC	UpCasePrim, LoCasePrim

;******************************************************	UpcasePrim

;Entry : character to upcase in	AL
;Exit  : uppercase in AL
;	 BX wiped out

UpCaseMap LABEL	BYTE			;Maps international characters
					;Starting with #129
	DB	'ö', 'ê', 'A', 'é', 'A', 'è', 'Ä', 'E',	'E', 'E'
	DB	'I', 'I', 'I', 'é', 'è', 'ê', 'í', 'í',	'O', 'ô'
	DB	'O', 'U', 'U', 'Y', 'ô', 'ö', 'õ', 'ú',	'ù', 'û'
	DB	'ü', 'A', 'I', 'O', 'U', '•', '•', 'A',	'O'

UpCasePrim PROC	FAR
	CMP	AL,'a'
	JB	UpCaseDone		;Done if AL < 'a'
	CMP	AL,167
	JA	UpCaseDone		;Done if AL > #164
	CMP	AL,'z'
	JA	ExtUpCase		;Jump if extended uppercase
	SUB	AL,32			;Convert to uppercase
UpCaseDone:
	RET
ExtUpCase:				;International uppercase
	CMP	AL,129
	JB	UpCaseDone		;Done if AL < #129
	SUB	AL,129			;Reduce	to range of map	table
	MOV	BX,OFFSET UpCaseMap
	XLAT	CS:[BX]			;Use map table
	RET
UpCasePrim ENDP

;******************************************************	Upcase

;function UpCase(Ch : Char) : Char;
;Return	uppercase of char, with	international character	support

UpCase	PROC	FAR
	MOV	BX,SP
	MOV	AL,SS:[BX+4]		;AL = input character
	CALL	UpcasePrim
	RET	2
UpCase	ENDP

;******************************************************	LocasePrim

;Entry : character to locase in	AL
;Exit  : lowercase in AL
;	 BX wiped out

LoCaseMap LABEL	BYTE			;Maps international characters
					;Starting with #128
	DB	'á', 'Å', 'Ç', 'É', 'Ñ', 'Ö', 'Ü', 'á',	'à', 'â'
	DB	'ä', 'ã', 'å', 'ç', 'Ñ', 'Ü', 'Ç', 'ë',	'ë', 'ì'
	DB	'î', 'ï', 'ñ', 'ó', 'ò', 'î', 'Å', 'õ',	'ú', 'ù'
	DB	'û', 'ü', '†', '°', '¢', '£', '§', '§'

LoCasePrim PROC	FAR
	CMP	AL,'A'
	JB	LoCaseDone		;Done if AL < 'a'
	CMP	AL,165
	JA	LoCaseDone		;Done if AL > #165
	CMP	AL,'Z'
	JA	ExtLoCase		;Jump if extended lowercase
	ADD	AL,32			;Convert to lowercase
LoCaseDone:
	RET
ExtLoCase:				;International lowercase
	CMP	AL,128
	JB	LoCaseDone		;Done if AL < #128
	SUB	AL,128			;Reduce	to range of map	table
	MOV	BX,OFFSET LoCaseMap
	XLAT	CS:[BX]			;Use map table
	RET
LoCasePrim ENDP

;******************************************************	Locase

;function Locase(Ch : Char) : Char;
;Return	lowercase of char, with	international character	support

LoCase	PROC	FAR
	MOV	BX,SP
	MOV	AL,SS:[BX+4]		;AL = input character
	CALL	LoCasePrim		;Lowercase
	RET	2
LoCase	ENDP

;******************************************************	StCase
;Convert string	to one case or another,	depending on DX
StCase	PROC	FAR
StCaseNear:
	StackFrame
	PUSH	DS
	CLD				;go forward
	LDS	SI,SS:[BX+4]		;DS:SI => S
	LES	DI,SS:[BX+8]		;ES:DI => function result
	LODSB				;AL = Length(S)
	STOSB				;Set length of result
	SetZero	CH			;CH = 0
	MOV	CL,AL			;CX = Length(S)
	JCXZ	SUDone			;Done if CX is 0
SUNext:
	LODSB				;Next char into	AL
	PUSH	CS			;Fake a	FAR CALL
	CALL	DX			;Uppercase it
	STOSB				;Store char in result
	LOOP	SUNext			;repeat
SUDone:
	POP	DS
	RET	4
StCase	ENDP

;******************************************************	StUpcase

;function StUpcase(S : string) : string;
;Convert lower case letters in string to upper case

StUpcase PROC FAR
	MOV	DX,OFFSET UpcasePrim
	JMP	StCaseNear
StUpcase ENDP

;******************************************************	StLocase

;function StLocase(S : string) : string;
;Convert upper case letters in string to lower case

StLocase PROC FAR
	MOV	DX,OFFSET LocasePrim
	JMP	StCaseNear
StLocase ENDP


CODE	ENDS

	END
