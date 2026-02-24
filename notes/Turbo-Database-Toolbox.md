# Turbo Pascal Database Toolbox

## Introduction

Unfortunately I was unable to locate a copy of the manual for version 4.0.  However a useful manual
from an earlier version (1985) is included as I found it useful.

## Building TACCESS.TPU

The TABUILD.EXE provided with the software does not seem to work on the emmulator.  However the included
README file contains an alternative way of doing the build, which is documented here.

### Create Table Definition File

As documented in the available manual and samples the first step in working with the toolbox is to create
the table definitions include file.  You need to create a file something similar to this:

```
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
  TIdField = String[2];
  TDateField = String[10];
  TDTField = String[19];
  TWorkFlowField = Char;
  TVersionField = String[2];
  TAccountField = String[20];
  TTitleField = String[50];
  TDescField = String[200];
  TCurrField = String[16];

  TVersionRecord = record     { 27 }
  	Id			: TIdField; 			{ String[2] }
    Major		: TVersionField; 	{ String[2] }
    Minor		: TVersionField; 	{ String[2] }
    Build		: TVersionField; 	{ String[2] }
    Created	: TDTField; 			{ String[19] }
  end;

  TGeneratorRecord = record { 62 }
  	Id				: TIdField; 	{ String[2] }
    TableName	: String[20]; { String[20] }
    LastId		: TIdField;		{ String[2] }
    Created,    						{ String[19] }
    Updated		: TDTField;		{ String[19] }
  end;

  TBankStatementRecord = record { 130 }
  	Id				: TIdField;				{ String[2] }
    FromDate,  									{ String[10] }
    ToDate		: TDateField; 		{ String[10] }
    Title			: TTitleField; 		{ String[50] }
    Account		: TAccountField; 	{ String[20] }
    Created, 										{ String[19] }
    Updated		: TDTField;				{ String[19] }
  end;

  TBankTransactionRecord = record { 282 }
  	Id					: TIdField; 			{ String[2] }
    BookingDate	: TDateField;			{ String[10] }
    Description	: TDescField; 		{ String[200] }
    Credit,     									{ String[16] }
    Debit				: TCurrField; 		{ String[16] }
    Created, 											{ String[19] }
    Updated			: TDTField;				{ String[19] }
	end;

  TCreditCardStatementRecord = record { 130 }
  	Id				: TIdField; 						{ String[2] }
    FromDate,  												{ String[10] }
    ToDate		: TDateField; 					{ String[10] }
    Title			: TTitleField; 					{ String[50] }
    Account		: TAccountField; 				{ String[20] }
    Created,       										{ String[19] }
    Updated		: TDTField;							{ String[19] }
	end;

  TCreditCartTransactionRecord = record { 282 }
  	Id					: TIdField;  						{ String[2] }
    BookingDate	: TDateField; 					{ String[10] }
    Description	: TDescField; 					{ String[200] }
    Credit,     												{ String[16] }
    Debit				: TCurrField; 					{ String[16] }
    Created,       											{ String[19] }
    Updated			: TDTField;							{ String[19] }
	end;

  MaxDataType = TBankTransactionRecord;
  MaxKeyType = TIdField;
```

In particular note the two final type definitions!  MaxDataType should point to the largest record
definition in the file and MaxKeyType should point to the longest field used in as a key in an index.

### Create Standard Constants File

In order to build the TACCESS.TPU unit needed for your project you need to generate a standard include
file the the TACCESS.PAS file called TACCESS.DEF.  The file looks something like this:

```
Const
  MaxDataRecSize = 289;
  MaxKeyLen      =   2;
  PageSize       =  16;
  Order          =   8;
  PageStackSize  =   5;
  MaxHeight      =   5;
```

The following program can be used to generate this file:

```
rogram GenTAConstants;

{$I  MYBUDGET.TYP}

var
  OutFile : text;
begin
  Assign(OutFile, 'TACCESS.DEF');
  Rewrite(OutFile);
  Writeln(OutFile, 'Const');
  Writeln(OutFile, '  MaxDataRecSize = ', SizeOf(MaxDataType):3,';');
  Writeln(OutFile, '  MaxKeyLen      = ', SizeOf(MaxKeyType) - 1:3,';');
  Writeln(OutFile, '  PageSize       =  16',';');
  Writeln(OutFile, '  Order          =   8',';');
  Writeln(OutFile, '  PageStackSize  =   5',';');
  Writeln(OutFile, '  MaxHeight      =   5',';');
  Close(OutFile);
end.
```

### Compile The Units

Once this file has been generated, the units can be compiled. Copy the files: TACCESS.PAS, TSIZES.PAS and 
TAHIGH.PAS to the same folder as the above files and then use the command line compiler to build the units.

Use the following command to build the TACCESS.TPU file:

```
 >TPC TACCESS /Q /DGENERIC /DTADebug
```

**/DGENERIC** defines the symbol Generic which is used to make sure that only the "Generic" pieces of code in 
Turbo Access will be compiled.

**/DTADebug** defines the symbol TADebug which means that extra error handling/reporting code will be compiled in.
Make sure to define this while developing your database.  When you are all done, you may want to recompile 
Turbo Access to create smaller/faster code.

Use the same command to build the TAHIGH.TPU:

```
>TPC TAHIGH /Q /DGENERIC /DTADebug
```

Afterwards copy the resulting TPUs to your project folder.
