{==========================================================}
{ currutil.pas                                             }
{                                                          }
{ Created: 17/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 17/02/2026 - Initial Version                             }
{==========================================================}

{ Defines the currenc class and associated routines }

unit CurrUtil;

interface

uses
  objects;

var
  DigitSeparator: Char;

type
  PCurrency = ^TCurrency;
  TCurrency = object(TObject)
  private
    FCents: Integer;
    FDigits: Byte;
	public
    function Cents: Integer;
    function Digits: Byte;

    constructor Init;
		destructor Done; virtual;

    procedure SetValue(const vCents: Integer; vDigits: Byte);
    procedure Clone(var pValue: PCurrency);
    procedure CopyValues(const pValue: PCurrency);
    function ToString: String;
  end;

function ParseCurrency(const vValue: String;
							var cents: Integer; var digits: Byte): Boolean;

{******************}
{* Implementation *}
{******************}
implementation

uses
  core;

function ParseCurrency(const vValue: String;
							var cents: Integer; var digits: Byte): Boolean;
var
  index: Integer;
  francsStr, centsStr, value: String;
  f, c, code: Integer;

	function ValidValues(const value: String): Boolean;
  var
  	i, len: Byte;
  begin
  	ValidValues := True;
    len := Length(value);

    for i := 1 to len do
      if not (value[i] in ['0'..'9', '.', ',', '-', '+']) then
      	ValidValues := False;
  end;
begin
	if not ValidValues(vValue) then
  begin
  	ParseCurrency := False;
    Exit;
  end;

  digits := 2;
  cents := 0;
  ParseCurrency := True;

  if vValue = '0' then
  	begin
    	cents := 0;
      Exit;
    end
  else
  	value := vValue;

  index := Pos('.', value);

  if index = 0 then
  	begin
  		value := value + '.00';
      index := Pos('.', value);
    end;

	francsStr := Copy(value, 1, index - 1);
  centsStr := Copy(value, index + 1, 2);

  Val(francsStr, f, code);
  Val(centsStr, c, code);

  f := f * 100;
  cents := f + c;
end;

{ TCurrency -----------------------------------------------}

function TCurrency.Cents: Integer;
{ Returns the cents part of the instance }
begin
	Cents := FCents;
end;

function TCurrency.Digits: Byte;
{ Returns the number of positions after the separator }
begin
	Digits := FDigits;
end;

constructor TCurrency.Init;
{ Sets the instance values to known defaults }
begin
	FCents := 0;
  FDigits := 2;
end;

destructor TCurrency.Done;
{ Releases instance resorces on disposal }
begin
	inherited Done;
end;

procedure TCurrency.SetValue(const vCents: Integer; vDigits: Byte);
{ Sets the instance variables to the given values }
begin
	FCents := vCents;
  FDigits := vDigits;
end;

procedure TCurrency.Clone(var pValue: PCurrency);
{ Creates a new instance, based on the instance variables }
begin
	if Assigned(pValue) then
  	Dispose(pValue, Done);
  New(pValue, Init);

  pValue^.SetValue(FCents, FDigits);
end;

procedure TCurrency.CopyValues(const pValue: PCurrency);
{ Sets the instance variables to the those of the given instance }
begin
	FCents := pValue^.Cents;
  FDigits := pValue^.Digits;
end;

function TCurrency.ToString: String;
{ Returns a string representation of the currency value }
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
  Insert(DigitSeparator, value, index);

	ToString := value;
end;

{ Initialization ------------------------------------------}

begin
	DigitSeparator := '.';
end.