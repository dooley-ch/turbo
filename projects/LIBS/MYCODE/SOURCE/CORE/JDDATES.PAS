(*--------------------------------------------------------*)
(*   JDDATES.PAS                                          *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   04/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit JDDates;

interface

uses
	Dos, Objects;

type
	Date = Word;
  UnixTimeStamp = LongInt;

	TDateFormat = (dfMMDDYY, dfDDMMYY, dfMMDDYYYY, dfDDMMYYYY);

	TDate = object(TObject)
  public
  	Day,
    Month,
    Year: Word;

    constructor Init;
    destructor Done; virtual;

    procedure Assign(const aValue: TDate);
    procedure AssignValues(const aDay, aMonth, aYear: Word);
    function AssignString(const aValue: String; const format: TDateFormat): Boolean;

    function Pack: Date;
    function AsString: String;
  end;

  TTimeStamp = object(TObject)
  public
  	Day,
    Month,
    Year,
    Hour,
    Mins,
    Secs: Word;

    constructor Init;
    destructor Done; virtual;

    function Pack: UnixTimeStamp;
    procedure Assign(const aValue: UnixTimeStamp);
    function AsString: String;
  end;

procedure UnPackUnix(var yy, mm, dd, hh, min, sec: Word; const uts: UnixTimeStamp);
function UnixTime(const yy, mm, dd, hh, min, sec: Word): UnixTimeStamp;

function PackedDate(const yy, mm, dd: Word): Date;
procedure UnPackDate(var yy, mm, dd: Word; const value: Date);

function ValidDate(const yr, mth, d: Word; var errorCode : Byte): Boolean;

function ParseDate(const aValue: String; var yy, mm, dd: Word;
										const format: TDateFormat): Boolean;
function DateStr(const yy, mm, dd: Word; Format: TDateFormat): String;

(******************)
(* Implementation *)
(******************)
implementation

const
	TDays: Array[Boolean,0..12] of Word =
  	((0,31,59,90,120,151,181,212,243,273,304,334,365),
    (0,31,60,91,121,152,182,213,244,274,305,335,366));

  UnixDatum	= LongInt(25568);
  SecsPerDay  = 86400;
  SecsPerHour = LongInt(3600);
  SecsPerMin  = LongInt(60);
  MinsPerHour = 60;

  DateSep: Char = '/';
  TimeSep: Char = ':';

type
	TDateTimeRecord = record
  	Day,
    Month,
    Year,
    Hour,
    Mins,
    Secs,
    Sec100,
		DOW: Word;
  end;

procedure GetDateTime(var value: TDateTimeRecord);
var
	dd,
  mm,
  yy,
  hh,
  min,
  sec,
  sec100s,
	dayOfWeek: Word;
begin
  GetDate(yy, mm, dd, dayOfWeek);
  GetTime(hh, min, sec, sec100s);

  with value do
  	begin
  		Day	:= dd;
    	Month := mm;
    	Year := yy;
    	Hour := hh;
    	Mins := mins;
    	Secs := sec;
    	Sec100 := sec100s;
			DOW := dayOfWeek;
    end;
end;

(**************************)
(* Functions & Procedures *)
(**************************)

procedure UnPackUnix(var yy, mm, dd, hh, min, sec: Word; const uts: UnixTimeStamp);
{
  Unpacks a UnixTimeStamp Variable into its Component parts.
}
Var
  temp : UnixTimeStamp;
begin
  UnPackDate(yy, mm, dd, Date(uts div SecsPerDay) + UnixDatum);
  temp := uts mod SecsPerDay;
  hh := temp div SecsPerHour;
  min := (temp mod SecsPerHour) div MinsPerHour;
  sec := temp mod SecsPerMin;
end;

function UnixTime(const yy, mm, dd, hh, min, sec: Word): UnixTimeStamp;
{
  Packs a date and time into a four Byte unix style Variable which
  represents the number of seconds that have elapsed since midnight
  on Jan 1st 1970.
}
begin
  UnixTime := SecsPerDay * (PackedDate(yy, mm, dd) - UnixDatum) +
              SecsPerHour * hh + SecsPerMin * min + sec;
end;

function PackedDate(const yy, mm, dd: Word): Date;
{
	Packs a date into a Word which represents the
	number of days since Dec 31,1899, 01-01-1900 = 1.
	Valid For all years 1901 to 2078
}
var
	yr, temp: Word;
  leap: Boolean;
begin
	yr := yy;
	leap := (yy mod 4 = 0);

  if yy >= 1900 then
  	Dec(yr, 1900);

  temp := yr * Word(365) + (yr div 4) - Ord(leap);
  Inc(temp, TDays[leap][mm - 1]);
  Inc(temp, dd);
  PackedDate := temp;
end;

procedure UnPackDate(var yy, mm, dd: Word; const value: Date);
{
	Unpacks a Word returned by the Function PackedDate
	into its respective parts of year, month and day.
	Valid For all years 1901 to 2078.
}
Var
	julian: Word;
  leap: Boolean;
begin
	dd := value;
  yy := (LongInt(dd) * 4) div 1461;
  julian := dd - (yy * 365 + (yy div 4));
  Inc(yy, 1900);
	leap := (yy mod 4 = 0);
  Inc(julian, Ord(leap));
  mm := 0;

  while julian > TDays[leap][mm] do
  	Inc(mm);

  dd := julian - TDays[leap][mm - 1];
end;


function DateStr(const yy, mm, dd: Word; format: TDateFormat): String;
{
	Returns a String Formatted according to the specifications required.
}
var
  yrStr    : String[4];
  mthStr   : String[2];
  dayStr   : String[2];
begin
  str(yy, YrStr);
  str(mm, MthStr);
  str(dd, DayStr);

  if mm < 10 then
  	mthStr := '0'+ mthStr;

  if dd < 10 then
  	dayStr := '0'+ dayStr;

  if yy < 100 then
    yrStr := '20' + yrStr;

  if (format = dfDDMMYY) or (format = dfMMDDYY) then
  	yrStr := Copy(yrStr, 3, 2);

  Case format of
    dfDDMMYY, dfDDMMYYYY: DateStr := dayStr + DateSep + mthStr + DateSep + yrStr;
  	dfMMDDYY, dfMMDDYYYY: DateStr := mthStr + DateSep + dayStr + DateSep + yrStr;
  end;
end;

function ValidDate(const yr, mth, d: Word; var errorCode : Byte): Boolean;
{
  Validates the date and time data to ensure no out of range errors
  can occur and returns an error code to the calling Procedure. A
  errorcode of zero is returned if no invalid parameter is detected.
  Errorcodes are as follows:

   Year out of range (< 1901 or > 2078) bit 0 of errorcode is set.
   Month < 1 or > 12                    bit 1 of errorcode is set.
   Day < 1 or > 31                      bit 2 of errorcode is set.
   Day out of range For month           bit 2 of errorcode is set.
}
begin
  errorCode := 0;

  if (yr < 1901) or (yr > 2078) then
    errorCode := (errorCode or 1);
  if (d < 1) or (d > 31) then
    errorCode := (errorCode or 2);
  if (mth < 1) or (mth > 12) then
    errorCode := (errorCode or 4);

  Case mth of
    4,6,9,11: if d > 30 then errorCode := (errorCode or 2);
           2: if d > (28 + ord((yr mod 4) = 0)) then
                errorCode := (errorCode or 2);
  end;

  ValidDate := (errorCode = 0);
end;

function ParseDate(const aValue: String; var yy, mm, dd: Word;
										const format: TDateFormat): Boolean;
{ Parses a date String in several Formats into its Component parts }
Var
	target:String;
	parts: array[1..3] of String[4];
  index: Byte;
  left, middle: Word;
  errCode: Integer; (* For conversion *)
  errorCode: Byte; (* For validation *)
begin
	(* Extract the date elements *)
  FillChar(parts, SizeOf(parts), #0);

  target := aValue;
  index := Pos(DateSep, target);
  parts[1] := Copy(target, 1, index - 1);

  target := Copy(target, index + 1, Length(target) - index);
  index := Pos(DateSep, target);
  parts[2] := Copy(target, 1, index - 1);

  target := Copy(target, index + 1, Length(target) - index);
  parts[3] := target;

  (* Convert the values *)
  Val(parts[1], left, errCode);
  Val(parts[2], middle, errCode);
  Val(parts[3], yy, errCode);

  (* Map the elements *)
  Case Format of
    dfDDMMYY, dfDDMMYYYY: begin
         										dd := left;
         										mm := middle;
       										end;
    dfMMDDYY, dfMMDDYYYY: begin
         										dd := middle;
         										mm := left;
       										end;
  end;

  (* Ensure it's valid *)
  ParseDate := ValidDate(yy, mm, dd, errorCode);
end;

(* Needed Internally *)
function JulianDay(const yy, mm, dd: Word): LongInt;
{
	procedure JDAY from CACM Alorithm 199
  Computes Julian day number for any Gregorian Calendar date
  Given:   yy - year
           mm - month
           dd - day
  Returns: Julian day number (astronomically, for the day
  beginning at noon) on the given date.
}
var
	Tmp1, Tmp2, Tmp3, Tmp4, Tmp5: LongInt;
begin
	if mm > 2 then
  	begin
    	Tmp1 := mm - 3;
      Tmp2 := yy
    end
  else
  	begin
    	Tmp1 := mm + 9;
      Tmp2 := yy - 1
    end;

  Tmp3 := Tmp2 div 100;
  Tmp4 := Tmp2 mod 100;
  Tmp5 := dd;

  JulianDay := (146097 * Tmp3) div 4 + (1461 * Tmp4) div 4 +
  							(153 * Tmp1 + 2) div 5 + Tmp5 + 1721119
end;

(* Needed Internally *)
Procedure JulianDayToDate(const nd: LongInt; var yy, mm, dd: Word);
{
	procedure JDATE from CACM Algorithm 199
  Computes calendar date from a given Julian day number for any
  valid Gregorian calendar date

  Given: nd - Julian day number (2440000 --> 1968 5 23)
  Returns: yy - year
           mm - month
           dd - day
}
Var
	Tmp1, Tmp2, Tmp3 : LongInt;
begin
	Tmp1 := nd - 1721119;
  Tmp3 := (4 * Tmp1 - 1) div 146097;
  Tmp1 := (4 * Tmp1 - 1) mod 146097;
  Tmp2 := Tmp1 div 4;
  Tmp1 := (4 * Tmp2 + 3) div 1461;
  Tmp2 := (4 * Tmp2 + 3) mod 1461;
  Tmp2 := (Tmp2 + 4) div 4;
  mm := ((5 * Tmp2 - 3) div 153);
  Tmp2 := (5 * Tmp2 - 3) mod 153;
  dd := ((Tmp2 + 5) div 5);
  yy := (100 * Tmp3 + Tmp1);

  if mm < 10 then
  	mm := mm + 3
  else
  	begin
    	mm := mm - 9;
      yy := yy + 1
    end;
end;

procedure AddDays(const yy, mm, dd: Word; plus : LongInt;
										var newYY, newMM, newDD: Word);
{
	Computes the date <newYY>, <newMM>, <newDD> resulting from
	the addition of <plus> days to the calendar date
	<yy>, <mm>, <dd>
}
var
	JulDay: LongInt;
begin
	JulDay := JulianDay (yy, mm, dd) + plus;
  JulianDayToDate (JulDay, newYY, newMM, newDD);
end;

(**************)
(* TTimeStamp *)
(**************)

constructor TTimeStamp.Init;
var
	rec: TDateTimeRecord;
begin
	inherited Init;

  FillChar(rec, SizeOf(TDateTimeRecord), 0);

  GetDateTime(rec);

  Day := rec.Day;
  Month := rec.Month;
	Year := rec.Year;
  Hour := rec.Hour;
  Mins := rec.Mins;
  Secs := rec.Secs;
end;

destructor TTimeStamp.Done;
begin
	inherited Done;
end;

function TTimeStamp.Pack: UnixTimeStamp;
begin
	Pack := UnixTime(Year, Month, Day, Hour, Mins, Secs);
end;

procedure TTimeStamp.Assign(const aValue: UnixTimeStamp);
begin
	UnPackUnix(Year, Month, Day, Hour, Mins, Secs, aValue);
end;

function TTimeStamp.AsString: String;
var
	yrStr: String[4];
  mtStr: String[2];
  dyStr: String[2];
  hrStr: String[2];
  minStr: String[2];
  secsStr: String[2];
begin
	Str(Year, yrStr);
  Str(Month, mtStr);
  Str(Day, dyStr);
  Str(Hour, hrStr);
  Str(Mins, minStr);
  Str(Secs, secsStr);

  if Month < 10 then
  	mtStr := '0' + mtStr;
  if Day < 10 then
  	dyStr := '0' + dyStr;
  if Hour < 10 then
  	hrStr := '0' + hrStr;
  if Mins < 10 then
  	minStr := '0' + minStr;
  if Secs < 10 then
  	secsStr := '0' + secsStr;

  AsString := dyStr + DateSep + mtStr + DateSep + yrStr + ' ' +
  						hrStr + TimeSep + minStr + TimeSep + secsStr;
end;

(*********)
(* TDate *)
(*********)

constructor TDate.Init;
var
	dow: Word;
begin
	inherited Init;

  GetDate(Year, Month, Day, dow);
end;

destructor TDate.Done;
begin
	inherited Done;
end;

function TDate.Pack: Date;
begin
	Pack := PackedDate(Year, Month, Day);
end;

function TDate.AsString: String;
begin
  AsString := DateStr(Year, Month, Day, dfDDMMYY);
end;

procedure TDate.Assign(const aValue: TDate);
begin
	Day := aValue.Day;
  Month := aValue.Month;
  Year := aValue.Year;
end;

procedure TDate.AssignValues(const aDay, aMonth, aYear: Word);
begin
	Day := aDay;
  Month := aMonth;
  Year := aYear;
end;

function TDate.AssignString(const aValue: String; const format: TDateFormat): Boolean;
begin
	AssignString := ParseDate(aValue, Year, Month, Day, format);
end;

end.
