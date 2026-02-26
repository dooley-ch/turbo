{==========================================================}
{ dbtypes.typ                                              }
{                                                          }
{ Created: 19/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 19/02/2026 - Initial Version                             }
{==========================================================}

type
  TIdField       = String[2];
  TDateField     = String[10];
	TDTField       = String[19];
  TWorkFlowField = Char;
  TVersionField  = String[2];
  TAccountField  = String[20];
  TTitleField    = String[50];
  TDescField     = String[200];
  TCurrField     = String[16];
  TNameField     = String[30];

  TVersionRecord = record     { 29 }
  	Id			: TIdField; 			{ String[2] }
    Major		: TVersionField; 	{ String[2] }
    Minor		: TVersionField; 	{ String[2] }
    Build		: TVersionField; 	{ String[2] }
    Created	: TDTField; 			{ String[19] }
    Status  : Integer;        { Integer [2] }
  end;

  TGeneratorRecord = record { 62 }
  	Id				: TIdField; 	{ String[2] }
    TableName	: TNameField; { String[20] }
    LastId		: TIdField;		{ String[2] }
    Created,    						{ String[19] }
    Updated		: TDTField;		{ String[19] }
  end;

  TBankStatementRecord = record { 131 }
  	Id				: TIdField;				{ String[2] }
    FromDate,  									{ String[10] }
    ToDate		: TDateField; 		{ String[10] }
    Title			: TTitleField; 		{ String[50] }
    Account		: TAccountField; 	{ String[20] }
    Imported, 									{ String[19] }
    Updated		: TDTField;				{ String[19] }
    Workflow 	: TWorkFlowField; { Char [1] }
  end;

  TBankTransactionRecord = record { 285 }
  	Id					: TIdField; 			{ String[2] }
    BookingDate	: TDateField;			{ String[10] }
    Description	: TDescField; 		{ String[200] }
    Credit,     									{ String[16] }
    Debit				: TCurrField; 		{ String[16] }
    Imported, 											{ String[19] }
    Updated			: TDTField;				{ String[19] }
    StatementId : TIdField;       { String[2] }
    Workflow 		: TWorkFlowField; { Char [1] }
	end;

  TCreditCardStatementRecord = record { 131 }
  	Id				: TIdField; 						{ String[2] }
    FromDate,  												{ String[10] }
    ToDate		: TDateField; 					{ String[10] }
    Title			: TTitleField; 					{ String[50] }
    Account		: TAccountField; 				{ String[20] }
    Created,       										{ String[19] }
    Updated		: TDTField;							{ String[19] }
    Workflow 	: TWorkFlowField; 			{ Char [1] }
	end;

  TCreditCartTransactionRecord = record { 285 }
  	Id					: TIdField;  						{ String[2] }
    BookingDate	: TDateField; 					{ String[10] }
    Description	: TDescField; 					{ String[200] }
    Credit,     												{ String[16] }
    Debit				: TCurrField; 					{ String[16] }
    Created,       											{ String[19] }
    Updated			: TDTField;							{ String[19] }
    StatementId : TIdField;        			{ String[2] }
    Workflow 		: TWorkFlowField; 			{ Char [1] }
	end;

  MaxDataType = TBankTransactionRecord;
  MaxKeyType = TNameField;
