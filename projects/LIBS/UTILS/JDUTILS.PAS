(*--------------------------------------------------------*)
(*   JDUTILS.PAS                                          *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   05/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit JDUtils;

interface

uses
	Dos;

function IsDir(const path: DirStr): Boolean;
function FileExists(const aName: PathStr): Boolean;
function PathCombine(const aBasePath, aPath: PathStr): PathStr;

implementation

uses
	JDString;

function IsDir(const path: DirStr): Boolean;
var
  hFile: File;
  attr: Word;
begin
  Assign(hFile, path);
  GetFAttr(hFile, attr);
  IsDir := (DosError = 0) and ((attr AND Directory) = Directory);
end;

function PathCombine(const aBasePath, aPath: PathStr): PathStr;
var
  aValue: String;
begin
	aValue := aBasePath;
  aValue := AddBackSlash (aValue);

  PathCombine := ConCat(aValue, aPath);
end;

function FileExists(const aName: PathStr): Boolean;
{ This function checks if the file exists }
var
  inFile: Text;
  attr: Word;
begin
  Assign(inFile, aName);
  GetFAttr(inFile, attr);

  if DosError <> 0 then
  begin
  	FileExists := False;
    Exit;
  end;

  if attr and VolumeID <> 0 then
  begin
  	FileExists := False;
    Exit;
	end;

  if attr and Directory <> 0 then
  begin
  	FileExists := False;
    Exit;
	end;

  FileExists := True;
end;

end.
