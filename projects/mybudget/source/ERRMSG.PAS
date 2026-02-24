{==========================================================}
{ errmsg.pas                                               }
{                                                          }
{ Created: 08/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 08/02/2026 - Initial Version                             }
{==========================================================}
unit ErrMsg;

interface

const
	UnexpectedError: Integer = 1000;
  ConfigFileNotFoundError: Integer = 1001;
  FileNotFoundError: Integer = 1002;

function GetErrorString(const errNum: Integer): String;

implementation

const
	msgStrings: array[1000..1002] of String =  (
  	'1000 - An unexpected error occurred, see log file for details',
  	'1001 - Unable to locate config file (mybudget.ini) - Fatal Error',
    '1002 - File not found, see log for details'
	);

function GetErrorString(const errNum: Integer): String;
begin
	GetErrorString := msgStrings[errNum];
end;

end.

