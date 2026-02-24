{==========================================================}
{ transcls.pas                                             }
{                                                          }
{ Created: 21/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 21/02/2026 - Initial Version                             }
{==========================================================}
unit TransCls;

interface

uses
	DateUtil, CurrUtil, Objects;

type
  TTransactionBase = object(TObject)
  private
  	FDate: TDate;
    FDescription: PString;
    FDebit, FCredit: TCurrency;
  public
    function Date: String;
    function Description: String;
    function Debit: String;
    function Credit: String;

    constructor Init;
    destructor Done; virtual;
  end;

  PImportTransaction = ^TImportTransaction;
  TImportTransaction = object(TTransactionBase)
  public
    constructor Init(const vDate, vDescription, vCredit, vDebit: String);
    destructor Done; virtual;
  end;

implementation

{ TImportTransaction --------------------------------------}

constructor TImportTransaction.Init(const vDate, vDescription, vCredit, vDebit: String);
var
	vDay, vMonth, vYear: Word;
  vCents: Integer;
  vDigits: Byte;
begin
	inherited Init;

  If ParseDate(vDate, vDay, vMonth, vYear) then
  begin
  	FDate.SetValue(vDay, vMonth, vYear);
  end;

  FDescription := NewStr(vDescription);

  if ParseCurrency(vCredit, vCents, vDigits) then
  	FCredit.SetValue(vCents, vDigits);

  if ParseCurrency(vDebit, vCents, vDigits) then
  	FDebit.SetValue(vCents, vDigits);
end;

destructor TImportTransaction.Done;
begin
	inherited Done;
end;

{ TTransactionBase ----------------------------------------}

function TTransactionBase.Date: String;
begin
	Date := FDate.ToString;
end;

function TTransactionBase.Description: String;
begin
	Description := FDescription^;
end;

function TTransactionBase.Debit: String;
begin
	Debit := FDebit.ToString;
end;

function TTransactionBase.Credit: String;
begin
	Credit := FCredit.ToString;
end;

constructor TTransactionBase.Init;
begin
	inherited Init;

  FDate.Init;
  FCredit.Init;
  FDebit.Init;
  FDescription := Nil;
end;

destructor TTransactionBase.Done;
begin
	inherited Done;
end;

end.