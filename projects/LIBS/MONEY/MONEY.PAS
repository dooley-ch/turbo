(**********************************************************)
(* MONEY.PAS	                                            *)
(*                                                        *)
(* 03/03/2026                                             *)
(*                                                        *)
(* Copyright (C) 2026 James Dooley <james@dooley.ch>      *)
(**********************************************************)
unit Money;

interface

uses
	Objects;

type
	TMoneyCompare = (mcHigher, mcLower, mcEqual);

	TMoney = object(TObject)
  private
  	FCents: LongInt;

    function Power(const aBase, aExponent: LongInt): LongInt;
  public
  	constructor Init;
    destructor Done; virtual;

    procedure Assign(const aValue: TMoney);
    function AssignString(const aValue: String): Boolean;
    procedure AssignCents(const aValue: LongInt);

    function Compare(const aValue: TMoney): TMoneyCompare;
    function IsNegative: Boolean;
    function IsOne: Boolean;
    function IsPositive: Boolean;
    function IsZero: Boolean;

    procedure SetToZero;
    procedure SetToOne;

    procedure Add(const aValue: TMoney);
    procedure Subtract(const aValue: TMoney);

    function AsString: String;
    function AsCents: LongInt;
  end;

(******************)
(* Implementation *)
(******************)
implementation

uses
	JDString;

function TMoney.Power(const aBase, aExponent: LongInt): LongInt;
var
	i,
  value: LongInt;
begin
	value := 1;

  for i := 1 to aExponent do
  	value := value * aBase;

  Power := value;
end;

procedure TMoney.Assign(const aValue: TMoney);
begin
	FCents := aValue.FCents;
end;

function TMoney.AssignString(const aValue: String): Boolean;
var
	value: Real;
begin
	if not Str2Real(aValue, value) then
  	begin
    	AssignString := False;
      Exit;
    end;

  FCents := Round(value * Power(10, 2));
end;

procedure TMoney.AssignCents(const aValue: LongInt);
begin
	FCents := aValue;
end;

function TMoney.Compare(const aValue: TMoney): TMoneyCompare;
begin
	if FCents > aValue.FCents then
  	Compare := mcHigher
	else if FCents < aValue.FCents then
		Compare := mcLower
	else
		Compare := mcEqual;
end;

function TMoney.IsNegative: Boolean;
begin
	IsNegative := (FCents < 0);
end;

function TMoney.IsOne: Boolean;
begin
	IsOne := (FCents = 1)
end;

function TMoney.IsPositive: Boolean;
begin
	IsPositive := (FCents >= 0);
end;

function TMoney.IsZero: Boolean;
begin
	IsZero := (FCents = 0);
end;

procedure TMoney.SetToZero;
begin
  FCents := 0;
end;

procedure TMoney.SetToOne;
begin
  FCents := 1;
end;

procedure TMoney.Add(const aValue: TMoney);
begin
	FCents := FCents + aValue.FCents;
end;

procedure TMoney.Subtract(const aValue: TMoney);
begin
	FCents := FCents - aValue.FCents;
end;

function TMoney.AsString: String;
var
	value,
	leftPart, rightPart: String;
  digits, len: Byte;
begin
	if IsOne then
  	begin
    	AsString := '0.01';
      Exit;
    end;

  if IsZero then
  	begin
    	AsString := '0.00';
    	Exit;
    end;

  Str(FCents, value);
  len := Length(value);
  leftPart := Copy(value, 1, len - 2);
  rightPart := Copy(value, len - 2, 2);

  AsString := leftPart + '.' + rightPart;
end;

function TMoney.AsCents: LongInt;
begin
	AsCents := FCents;
end;

constructor TMoney.Init;
begin
	inherited Init;
	SetToZero;
end;

destructor TMoney.Done;
begin
	inherited Done;
end;

end.