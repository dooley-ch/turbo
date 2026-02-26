# Turbo Professional 5.02

## Introduction

Turbo Professional is a library of utilities, source, and documentation for turbo Pascal programmers. 
Includes TSR management, BCD arithmetic, windowing, menuing, EMS and XMS access routines, large arrays, 
macros, runtime error recovery.

## Documentation

I was unable to find documentation for this package, but going through the source code I found the following
units to be of particular use to me in developing my programs.

| Unit         | Comments                                                |
| ------------ | ------------------------------------------------------- |
| COLORDEF.PAS | Constands used to define various colours                |
| TPSTRING.PAS | Basic string manipulation routines                      |
| TPTIMER.PAS  | Allows events to be timed with 1 microsecond resolution |

I placed the compiled units in Turbo Pascal's Units folder.

## TPSTRING.PAS

This unit includes the following useful string handling routines:

```
function HexPtr(P : Pointer) : string;
  {-Return hex string for pointer}

function Str2Int(S : string; var I : Integer) : Boolean;
  {-Convert a string to an integer, returning true if successful}

function Str2Word(S : string; var I : Word) : Boolean;
  {-Convert a string to a word, returning true if successful}

function Str2Long(S : string; var I : LongInt) : Boolean;
  {-Convert a string to an longint, returning true if successful}

function Str2Real(S : string; var R : Float) : Boolean;
  {-Convert a string to a real, returning true if successful}

function Long2Str(L : LongInt) : string;
  {-Convert a longint/word/integer/byte/shortint to a string}

function Real2Str(R : Float; Width, Places : Byte) : string;
  {-Convert a real to a string}

function Form(Mask : string; R : Float) : string;
  {-Returns a formatted string with digits from R merged into the Mask}

function StUpcase(S : string) : string;
  {-Convert lower case letters in string to uppercase, with intl chars}

function LoCase(Ch : Char) : Char;
  {-Return lowercase of char, with international character support}

function StLocase(S : string) : string;
  {-Convert upper case letters in string to lowercase, with intl chars}

function CharStr(Ch : Char; Len : Byte) : string;
  {-Return a string of length len filled with ch}

function PadCh(S : string; Ch : Char; Len : Byte) : string;
  {-Return a string right-padded to length len with ch}

function Pad(S : string; Len : Byte) : string;
  {-Return a string right-padded to length len with blanks}

function LeftPadCh(S : string; Ch : Char; Len : Byte) : string;
  {-Return a string left-padded to length len with ch}

function LeftPad(S : string; Len : Byte) : string;
  {-Return a string left-padded to length len with blanks}

function TrimLead(S : string) : string;
  {-Return a string with leading white space removed}

function TrimTrail(S : string) : string;
  {-Return a string with trailing white space removed}

function Trim(S : string) : string;
  {-Return a string with leading and trailing white space removed}

function CompString(S1, S2 : string) : CompareType;
  {-Return less, equal, greater if s1<s2, s1=s2, or s1>s2}

function CompUCString(S1, S2 : string) : CompareType;
  {-Compare two strings in a case insensitive manner}

function DefaultExtension(Name, Ext : string) : string;
  {-Return a file name with a default extension attached}

function ForceExtension(Name, Ext : string) : string;
  {-Force the specified extension onto the file name}

function JustFilename(PathName : string) : string;
  {-Return just the filename and extension of a pathname}

function JustExtension(Name : string) : string;
  {-Return just the extension of a pathname}

function JustPathname(PathName : string) : string;
  {-Return just the drive:directory portion of a pathname}

function AddBackSlash(DirName : string) : string;
  {-Add a default backslash to a directory name}

function CleanPathName(PathName : string) : string;
  {-Return a pathname cleaned up as DOS will do it}

function FullPathName(FName : string) : string;
  {-Given FName (known to exist), return a full pathname}

```
