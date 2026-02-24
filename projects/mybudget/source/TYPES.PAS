{==========================================================}
{ types.pas                                                }
{                                                          }
{ Created: 13/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 13/02/2026 - Initial Version                             }
{==========================================================}
unit types;

interface

type
  { TDate }

  PDate = ^TDate;
  TDate = object
		function Day: Byte;
    function Month: Byte;
    function Year: Integer;

    constructor Init;

    procedure Parse(const value: String);
    procedure Values(const vDay: Byte; vMonth: Byte; vYear: Integer);

    function ToString: String;
  private
    FDay: 1..31;
    FMonth: 1..12;
    FYear : 2000..2050;
  end;

  { TCurrency }

  PCurrency = ^TCurrency;
  TCurrency = object
    function Cents: Integer;
    function Digits: Byte;

    constructor Init;

    procedure Parse(const value: String);
    procedure Values(const vCents: Integer; vDigits: Byte);

    function ToString: String;
  private
    FCents: Integer;
    FDigits: Byte;
  end;

implementation

uses
  sysutils;

{ TCurrency }

function TCurrency.Cents: Integer;
begin
	Cents := FCents;
end;

function TCurrency.Digits: Byte;
begin
	Digits := FDigits;
end;

constructor TCurrency.Init;
{ Sets the instance values to known defaults }
begin
	FCents := 0;
  FDigits := 2;
end;

procedure TCurrency.Parse(const value: String);
{ Parses the given string into the instance
  values. }
var
  index: Byte;
  francsStr, centsStr: String;
  f, c, code: Integer;
begin
  index := Pos('.', value);
  francsStr := Copy(value, 1, index - 1);
  centsStr := Copy(value, index + 1, 2);

  Val(francsStr, f, code);
  Val(centsStr, c, code);
  f := f * 100;

  if f < 0 then
    begin
      FCents := (f * -1) + c;
    end
  else
  	FCents := f + c;

  FDigits := 2;
end;

procedure TCurrency.Values(const vCents: Integer; vDigits: Byte);
begin
	FCents := vCents;
  FDigits := vDigits;
end;

function TCurrency.ToString: String;
{ Returns a string representation of the values }
var
  value: String;
  index: Byte;
begin
	if FCents = 0 then
  begin
  	ToString := '0.00';
    Exit;
  end;

  value := '';
  index := 0;

	Str(FCents, value);
  index := Length(value) - FDigits + 1;
  Insert('.', value, index);

	ToString := value;
end;

{ TDate }

function TDate.Day: Byte;
begin
	Day := FDay;
end;

function TDate.Month: Byte;
begin
	Month := FMonth;
end;

function TDate.Year: Integer;
begin
	Year := FYear;
end;

procedure TDate.Parse(const value: String);
{ This routine parses the given string
  into the instance values }
var
  d, m: String[2];
  y: String[4];
  code: Integer;
begin
  d := Copy(value, 1, 2);
  m := Copy(value, 4, 2);
  y := Copy(value, 7, 4);

  Val(d, FDay, code);
  Val(m, FMonth, code);
  Val(y, FYear, code);
end;

procedure TDate.Values(const vDay: Byte; vMonth: Byte; vYear: Integer);
{ Initialises the instance with given values}
begin
  FDay := vDay;
  FMonth := vMonth;
  FYear := vYear;
end;

constructor TDate.Init;
{ Initialises the instance with default values}
begin
  FDay := 1;
  FMonth := 1;
  FYear := 2000;
end;

function TDate.ToString: String;
{ Returns a string representation of the given date }
var
  d, m, y, dateStr: String;
begin
  Str(FDay, d);
  If Length(d) = 1 then
    d := ConCat('0', d);

  Str(FMonth, m);
  If Length(d) = 1 then
    m := ConCat('0', m);

  Str(FYear, y);

  dateStr := ConCat(d, '/');
  dateStr := ConCat(dateStr, m);
  dateStr := ConCat(dateStr, '/');
  ToString := ConCat(dateStr, y);
end;

end.