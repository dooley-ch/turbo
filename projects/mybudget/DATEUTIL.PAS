{==========================================================}
{ dateutil.pas                                             }
{                                                          }
{ Created: 21/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 21/02/2026 - Initial Version                             }
{==========================================================}
unit DateUtil;

{ Defines the Date class and associated routines }

interface

uses
  Objects;

const
	Days : array [0..6] of String[3] = ('Sun','Mon','Tues', 'Wed','Thu','Fri','Sat');

	Months: array [0..11] of string[3] = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
																				'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
	TDateFormat = (dfDayMonthYear, dfMonthDayYear);

	PDate = ^TDate;
  TDate = object(TObject)
  private
  	FDate: LongInt;

    function ToSerial(vDay, vMonth, vYear: Integer): LongInt;
    procedure FromSerial(const vDate: LongInt; var vDay, vMonth, vYear: Integer);
    function LeapYear(const vYear: Integer): Integer;
  	function OrdinalDay: integer;
		procedure FromOrdinalDay(od, vYear: integer; var vDay, vMonth: integer);
  public
  	function Day: Integer;
    function Month: Integer;
    function Year: Integer;

    function IsLeapYear: Boolean;
    procedure AddDays(const days: Integer);
    function DayDiff(const vDate: TDate): LongInt;
		function DayOfWeek: integer;

  	procedure SetValue(const vDay, vMonth, vYear: Integer);
    function ToString: String;

  	constructor Init;
    destructor Done; virtual;
  end;

var
	DateSeparator: Char;
  TimeSeparator: Char;
  DateFormat: TDateFormat;

function DateStr: String;
function TimeStr: String;
function DateTimeStr: String;
function FormatDateStr(const vDay, vMonth, vYear: Word): String;
function ParseDate(const value: String; var vDay, vMonth, vYear: Word): Boolean;
function ParseDateEx(const value: String; const separator: Char;
										const format: TDateFormat; var vDay, vMonth, vYear: Word): Boolean;

implementation

uses
 Dos, Core;

const
  DefDateSep: Char = '/';
  DefTimeSep: Char = ':';

{ Date & Time Strings -------------------------------------}

function ParseDate(const value: String; var vDay, vMonth, vYear: Word): Boolean;
begin
	ParseDate := ParseDateEx(value, DateSeparator, DateFormat, vDay, vMonth, vYear);
end;

function ParseDateEx(const value: String; const separator: Char;
											const format: TDateFormat;
											var vDay, vMonth, vYear: Word): Boolean;
var
	vPart1, vPart2, vPart3: String[4];
  index1, index2: Byte;
  code, len: Integer;

  function AreDigits(const value: String): Boolean;
  var
  	len, i: Byte;
  begin
  	len := Length(value);

  	for i := 1 to len do
     	if not (value[i] in ['0'..'9']) then
      	begin
        	AreDigits := False;
          Exit;
        end;

    AreDigits := True;
  end;
begin
	len := Length(value);
  if len <> 10 then
  	begin
    	ParseDateEx := False;
      Exit;
    end;

	index1 := Pos(separator, value);
  index2 := LastPos(separator, value);

  vPart1 := LeftStr(value, index1 - 1);
  vPart2 := MidStr(value, index1 + 1, index2 - index1 - 1);
  vPart3 := RightStr(value, Length(value) - index2);

  if not AreDigits(vPart1) then
  	begin
    	ParseDateEx := False;
      Exit;
    end;

  if not AreDigits(vPart2) then
  	begin
    	ParseDateEx := False;
      Exit;
    end;

  if not AreDigits(vPart3) then
  	begin
    	ParseDateEx := False;
      Exit;
    end;

  Val(vPart3, vYear, code);

  if format = dfDayMonthYear then
  	begin
    	Val(vPart1, vDay, code);
      Val(vPart2, vMonth, code);
    end
  else
  	begin
    	Val(vPart2, vDay, code);
      Val(vPart1, vMonth, code);
    end;

	ParseDateEx := True;
end;

function FormatDateStr(const vDay, vMonth, vYear: Word): String;
var
	day, month, year, vValue: String;
begin
  Str(vDay:2, day);
  Str(vMonth:2, month);
  Str(vYear:4, year);

  day := TrimChar(day, ' ');
  month := TrimChar(month, ' ');

  if Length(day) = 1 then
  	day := '0' + day;
  if Length(month) = 1 then
  	month := '0' + month;

  if DateFormat = dfDayMonthYear then
  	vValue := day + DateSeparator + month + DateSeparator + year
  else
    vValue := month  + DateSeparator + day + DateSeparator + year;

  FormatDateStr := vValue;
end;

function DateStr: String;
var
	d, m, y, dow: Word;
begin
	GetDate(y, m, d, dow);
  DateStr := FormatDateStr(d, m, y);
end;

function TimeStr: String;
var
	h, m, s, mil: Word;
  hours, mins, secs: String;
begin
	GetTime(h, m, s, mil);

  Str(h:2, hours);
  Str(m:2, mins);
  Str(s:2, secs);

  hours := TrimChar(hours, ' ');
  mins := TrimChar(mins, ' ');
  secs := TrimChar(secs, ' ');

  if Length(hours) = 1 then
  	hours := '0' + hours;
  if Length(mins) = 1 then
  	mins := '0' + mins;
  if Length(secs) = 1 then
  	secs := '0' + secs;

  TimeStr := hours + TimeSeparator + mins + TimeSeparator + secs;
end;

function DateTimeStr: String;
begin
	DateTimeStr := DateStr + ' ' + TimeStr;
end;

{ TDate ---------------------------------------------------}

constructor TDate.Init;
var
	m, d, y, dw: Word;
begin
	inherited Init;

  GetDate(y, m, d, dw);
  FDate := ToSerial(d, m, y);
end;

destructor TDate.Done;
begin
  inherited Done;
end;

function TDate.ToString: String;
var
	vDay, vMonth, vYear: Integer;

begin
	FromSerial(FDate, vDay, vMonth, vYear);
  ToString := FormatDateStr(vDay, vMonth, vYear);
end;

procedure TDate.SetValue(const vDay, vMonth, vYear: Integer);
begin
	FDate := ToSerial(vDay, vMonth, vYear);
end;

function TDate.ToSerial(vDay, vMonth, vYear: Integer): LongInt;
var
	mth, yr: LongInt;
begin
	if vMonth > 2 then
  	begin
    	mth := vMonth - 3;
      yr := vYear;
    end
  else
  	begin
    	mth := vMonth + 9;
      yr := vYear - 1;
    end;

  ToSerial := ((yr div 100) * 146097) div 4 +
  						((yr mod 100) * 1461) div 4 +
              (153 * mth + 2) div 5 + vDay;
end;

procedure TDate.FromSerial(const vDate: LongInt; var vDay, vMonth, vYear: Integer);
var
	j, d: LongInt;
begin
	j := vDate * 4 - 1;
  d := ((j mod 146097) div 4) * 4 + 3;
  vYear := (j div 146097) * 100 + (d div 1461);
  d := (((d mod 1461) + 4) div 4) * 5 - 3;
  vMonth := d div 153;
  vDay := ((d mod 153) + 5) div 5;

  if vMonth < 10 then
  	vMonth := vMonth + 3
  else
  	begin
    	vMonth := vMonth - 9;
      vYear := vYear + 1;
    end;
end;

function TDate.Day: Integer;
var
	vDay, vMonth, vYear: Integer;
begin
	FromSerial(FDate, vDay, vMonth, vYear);
  Day := vDay;
end;

function TDate.Month: Integer;
var
	vDay, vMonth, vYear: Integer;
begin
	FromSerial(FDate, vDay, vMonth, vYear);
  Month := Month;
end;

function TDate.Year: Integer;
var
	vDay, vMonth, vYear: Integer;
begin
	FromSerial(FDate, vDay, vMonth, vYear);
  Year := vYear;
end;

function TDate.IsLeapYear: Boolean;
begin
	IsLeapYear := False;
	if LeapYear(Year) = 1 then
  	IsLeapYear := True;
end;

function TDate.LeapYear(const vYear: Integer): Integer;
begin
	if vYear and 3 <> 0 then
		LeapYear := 0
  else if vYear mod 100 <> 0 then
		LeapYear := 1
  else if vYear mod 400 <> 0 then
		LeapYear := 0
  else
		LeapYear := 1;
end;

procedure TDate.AddDays(const days: Integer);
var
	vDay, vMonth, vYear: Integer;
begin
	FromSerial(FDate + days, vDay, vMonth, vYear);
  FDate := ToSerial(vDay, vMonth, vYear);
end;

function TDate.DayDiff(const vDate: TDate): LongInt;
var
	vSerial: LongInt;
begin
	vSerial := ToSerial(vDate.Day, vDate.Month, vDate.Year);
  DayDiff := vSerial - FDate;
end;

function TDate.OrdinalDay: integer;
{ Returns ordinal day of year (1-366)}
var
	vDay, vMonth, vYear, od: Integer;
begin
	vDay := Day;
  vMonth := Month;
  vYear := Year;

	if vMonth < 3 then
  	vMonth := vMonth + 10
  else
  	vMonth :=vMonth - 2;

  od := (306 * vMonth - 2) div 10 - 30;

  if od < 306 then
  	OrdinalDay := od + 59 + LeapYear(vYear) + vDay
  else
  	OrdinalDay := od - 306 + vDay;
end;

procedure TDate.FromOrdinalDay(od, vYear: integer; var vDay, vMonth: integer);
{ Returns day and month for ordinal day of a year }
var
	leapYearFlag, monthAdj: integer;
begin
	leapYearFlag := LeapYear(vYear) + 60;

  if od < leapYearFlag then
  	od := od + 305
  else
  	od := od - leapYearFlag;

  monthAdj := (od * 10 + 4) div 306 + 1;
  vDay := od - ((monthAdj * 306 - 2) div 10 - 30) + 1;

  if monthAdj < 11 then
  	vMonth := monthAdj + 2
  else
  	vMonth := monthAdj - 10;
end;

function TDate.DayOfWeek: integer;
{ Returns integer day of week for date.
  0 = Sunday, 6 = Saturday Uses Zeller's congruence.}
var
	vDay, vMonth, vYear,
	century, yr, dw: integer;
begin
	vDay := Day;
  vMonth := Month;
  vYear := Year;

	if vMonth < 3 then
		begin
    	vMonth := vMonth + 10;
      vYear := vYear -1
    end
  else
		vMonth := vMonth - 2;

  century := vYear div 100;
  yr := vYear mod 100;

  dw := (((26 * vMonth - 2) div 10) + vDay + yr +(yr div 4) +
  			(century div 4) - (2 * century)) mod 7;

  if dw < 0 then
		DayOfWeek := dw + 7
	else
		DayOfWeek := dw;
end;

begin
	DateSeparator := DefDateSep;
  DateFormat := dfDayMonthYear;
  TimeSeparator := DefTimeSep;
end.