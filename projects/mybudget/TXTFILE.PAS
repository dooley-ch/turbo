{==========================================================}
{ txtfile.pas                                             }
{                                                          }
{ Created: 14/02/2026                                      }
{                                                          }
{ Copyright (C) 2026 James Dooley <james@dooley.ch>        }
{                                                          }
{ History                                                  }
{ 14/02/2026 - Initial Version                             }
{==========================================================}

{ Standard class used to load text files }

unit txtfile;

interface

type
  TTextLine = String[255];

  PTextLines = ^TTextLines;
  TTextLines = array[0..0] of TTextLine;

  PTextFile = ^TTextFile;
  TTextFile = object
  private
    FLines: PTextLines;
    FCount: Byte;
    FName: String;
    FAllocatedMem: Integer;

    function GetFileLineCount: Byte;
    procedure Load;
	public
    function Name: String;
    function Count: Byte;
    function Line(const index: Integer): String;

    constructor Init(const fileName: String);
    destructor Done; virtual;
    procedure Dump; virtual;
  end;

implementation

{ TTextFile }

function TTextFile.Name: String;
{ Returns the file name }
begin
  Name := FName;
end;

function TTextFile.Count: Byte;
{ Returns the number of lines in the file }
begin
  Count := FCount;
end;

function TTextFile.Line(const index: Integer): String;
{ Returns a line of text from the file based on
  the given index. }
begin
  Line := FLines^[index];
end;

constructor TTextFile.Init(const fileName: String);
{ Initialises an instance by load the file
  contents into the object. }
begin
  FName := fileName;
  FCount := GetFileLineCount;
  FAllocatedMem := FCount * SizeOf(TTextLine);
  GetMem(FLines, FAllocatedMem);
  Load;
end;

destructor TTextFile.Done;
{ Releases the object's resources, when the
  instance is no longer needed. }
begin
  FName := '';
  FreeMem(FLines, FAllocatedMem);
end;

function TTextFile.GetFileLineCount: Byte;
{ Counts the number of lines in the given file }
var
  inFile: Text;
  lineCount: Byte;
  row: String;
begin
  lineCount := 0;

  Assign(inFile, FName);
  Reset(inFile);

  while not EOF(inFile) do
  begin
    ReadLn(inFile, row);
    Inc(lineCount);
  end;

  Close(inFile);

  GetFileLineCount := lineCount;
end;

procedure TTextFile.Load;
{ This procedure loads the file contents into the object }
var
  inFile: Text;
  index: Byte;
  row: String;
begin
  index := 0;

  Assign(inFile, FName);
  Reset(inFile);

  while not EOF(inFile) do
  begin
    ReadLn(inFile, row);
    FLines^[index] := row;
    Inc(index);
  end;

  Close(inFile);
end;

procedure TTextFile.Dump;
{ Displays the file contents on screen }
var
	index: Byte;
  row: String;
begin
	row := '';

	WriteLn;

  for index := 0 to FCount - 1 do
  begin
    row := FLines^[index];
    WriteLn(row);
  end;

  WriteLn;
end;

end.
