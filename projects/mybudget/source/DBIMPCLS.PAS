(*--------------------------------------------------------*)
(*   DBIMPCLS.PAS                                         *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   06/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit DbImpCls;

interface

uses
	Objects, JDDates, JDMoney, DbUtils;

type
	TStatementType = (stBank, stCard, stUnknown);

  PImpStatementRecord = ^TImpStatementRecord;
	TImpStatementRecord = object(TDatabaseRecord)
  private
  public
    FromDate,
    ToDate: TDate;
    Account: TField15S;
    StatementType: TStatementType;

    function Title: String;

  	constructor Init;
    destructor Done; virtual;
  end;

  PImpTransactionRecord = ^TImpTransactionRecord;
  TImpTransactionRecord = object(TDatabaseRecord)
  private
  public
    BookingDate: TDate;
    Description: TMemoField;
    CreditAmount,
    DebitAmount: TMoney;

  	constructor Init;
    destructor Done; virtual;
  end;

implementation

(***********************)
(* TImpStatementRecord *)
(***********************)

constructor TImpStatementRecord.Init;
begin
	inherited Init;

  Id.Init;
  FromDate.Init;
  ToDate.Init;
  Account := '';
  StatementType := stUnknown;
end;

destructor TImpStatementRecord.Done;
begin
	Id.Done;
  FromDate.Done;
  ToDate.Done;

  inherited Done;
end;

function TImpStatementRecord.Title: String;
var
	value: String;
begin
	value := 'Unknown Statement: ';

  if StatementType = stBank then
  	value := 'Bank Statement: ';

  if StatementType = stCard then
  	value := 'Credit Card Statement: ';

  Title := value + ' ' + FromDate.AsString + ' - ' + ToDate.AsString;
end;

(*************************)
(* TImpTransactionRecord *)
(*************************)

constructor TImpTransactionRecord.Init;
begin
	inherited Init;

  BookingDate.Init;
  Description := '';
  CreditAmount.Init;
  DebitAmount.Init;
end;

destructor TImpTransactionRecord.Done;
begin
	inherited Done;
end;

end.
