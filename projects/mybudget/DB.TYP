{==========================================================}
{ db.typ   			                                           }
{                                                          }
{ Created: 27/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 27/02/2026 - Initial Version                             }
{==========================================================}

{ Defines the database table records }

type
	TIdField = String[4];
  TNameField = String[30];
  TDateTimeField = String[19];
  TTimeStampField = String[23];
  TDateField = String[10];
  TWorkflowField = String[2];
  TMoneyField = String[12];
  TVersionField = Byte;

  PConfigRecord = ^TConfigRecord;
  TConfigRecord = record
  	ID: TIdField;
    Key: TNameField;
    Value: String[50];
    Created,
		Updated: TTimeStampField;
  end;

  PGenKey = ^TGenKey;
  TGenKey = record
  	ID: TIdField;
    Key: TNameField;
    Value: String[2];
    Created,
		Updated: TTimeStampField;
  end;

  PImpStmt = ^TImpStmt;
  TImpStmt = record
  	ID: TIdField;
    FromDate,
    ToDate: TDateField;
    Account: String[20];
    StmtType: Char;
    Workflow: TWorkflowField;
    Created,
		Updated: TTimeStampField;
  end;

  PImpTrans = ^TImpTrans;
  TImpTrans = record
  	ID: TIdField;
    BookDate: TDateField;
    Desc: String[200];
    Credit,
    Debit: TMoneyField;
    Workflow: TWorkflowField;
    Created,
		Updated: TTimeStampField;
  end;

  MaxDataType = TImpTrans;
  MaxKeyType = TNameField;