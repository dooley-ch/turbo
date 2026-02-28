{==========================================================}
{ exitoner.pas                                             }
{                                                          }
{ Created: 24/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 24/02/2026 - Initial Version                             }
{==========================================================}
unit ExitOnEr;

interface

procedure ExitOnFatalError(const message, fileName: String;
									const lineNo, errCode: Word);

implementation

procedure ExitOnFatalError(const message, fileName: String;
									const lineNo, errCode: Word);
begin
end;

end.