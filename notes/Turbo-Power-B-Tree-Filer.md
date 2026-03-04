# B-Tree Filer

## Introduction

The documentation on this library is excellent, but extenxive - over 500 pages!  This note just
lists the main units and functions needed to create single user applications.

## Units

Add the following units to yur project:

```
Filer, BTBase, BTIsBase;
```
## Files

The file extensions are defined in the library configuration file: FILER.CFG.

| Extension     | Size      | Value |
| ------------- | --------- |------ |
| DatExtension  | String[3] |  DAT  |
| IxExtension   | String[3] |  IX   |
| DiaExtension  | String[3] |  DIA  |
| SavExtension  | String[3] |  SAV  |
| MsgExtension  | String[3] |  MSG  |

## Support Functions

The library includes some useful support functions including:

```
procedure IsamClearOK;;
{-Resets all status variables }

procedure IsamDelete;(var F : IsamFile);
{-Deletes the file F}

function IsamExists;(Name : IsamFileName) : Boolean;
{-Returns True if the specified file exists}

procedure IsamFlush;(var F : IsamFile; var WithDUP : Boolean; NetUsed
: Boolean);
{-Flushes the buffers of F to disk }

procedure IsamRename;(var F : IsamFile; FName : IsamFileName);
{-Renames the unopened file F to FName}
```

## Initialization

```
function BTInitIsam;(ExpectedNet : NetSupportType; Free : LongInt; NrOfEMSTreePages : Word) : LongInt;
{- nitialize B-Tree Filer and allocate memory from the normal heap and/or the EMS heap. }
```

## CRUD

```
procedure BTGetRec;(IFBPtr : IsamFileBlockPtr; RefNr : LongInt; var Dest; var ISOLock : Boolean);
{- Read the data record with the specified reference number. }

procedure BTPutRec;(IFBPtr : IsamFileBlockPtr; RefNr : LongInt; var source; ISOLock : Boolean);
{- Write a data record back to the data file. }
```

## Find Records 

```
procedure BTClearKey;(IFBPtr : IsamFileBlockPtr; Key : Word);
{- Reset the sequential pointer. }

procedure BTFindKey;(IFBPtr : IsamFileBlockPtr; Key : Word; var UserDatRef : LongInt; UserKey : IsamKeyStr);
{- Search for a specific key. }
```

## Finalisation

```
procedure BTCloseAllFileBlocks;
{- Close all currently opened fileblocks. }

procedure BTCloseFileBlock;(var IFBPtr : IsamFileBlockPtr);
{- Close the specified fileblock. }

procedure BTDeleteFileBlock;(FName : IsamFileBlockName);
{- Delete a fileblock. }

procedure BTExitIsam;
{- Finish working with B-Tree Filer. }

procedure BTFlushAllFileBlocks;
{- Write buffered data for all open fileblocks to disk. }

procedure BTFlushFileBlock;(IFBPtr : IsamFileBlockPtr);
{- Write buffered data for the specified fileblock to disk. }
```

## Error Handling

Error handling can be based on the following variables:

| Variable     | Type    | Comment                                                                                                                           |
| ------------ | ------- |---------------------------------------------------------------------------------------------------------------------------------- |
| IsamDOSError | Word    | This variable contains a non-zero value if there was a DOS error during a call to a B-Tree Filer routine.                         |
| IsamError    | Integer | This variable is set by every B-Tree Filer routine. If IsamOK is False, IsamError corresponds to the type of error that occurred. |
| IsamOK       | Boolean | If IsamOK is True when the routine returns, the requested operation was successfully completed.                                   |

The following function can be used to obtain the error class:

```
function BTIsamErrorClass; : Integer;
```

| Return Value | Explaination                                                                                                      |
| ------------ | ----------------------------------------------------------------------------------------------------------------- |
|      0       | No error (IsamError is zero)                                                                                      |
|      1       | User error.  This is more of a warning than an error. The previous operation could not be successfully completed. |  
|.     2       | Locking error (only on a network).  Errors of this class occur when a file access couldn't be completed.          |  
|      3       | Operation did not succeed in save mode.  This error class deals with serious errors and occurs only in save mode. |
|      4       | Hard error.  An immediate correction of the error condition is required.                                          |

A complete list of error codes is given in Appendix A of the manual.
