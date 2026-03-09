(*--------------------------------------------------------*)
(*   DBUTILS.PAS                                          *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   06/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit DbUtils;

interface

uses
	Objects, JDDates;

type
	TRecIdField = String[2];
  TTimeStampField = LongInt;
  TDateField = Word;
  TNameField = String[30];
  TMemoField = String[200];
  TShortMemoField = String[100];
  TMoneyField = LongInt;
  TFlagField = Byte;
  TField10S = String[10];
  TField15S = String[15];
  TField20S = String[20];
  TField30S = String[30];


	TRecordId = object(TObject)
  private
  	FId: Word;

    function WordToStr(const aValue: Word): TRecIdField;
    function StrToWord(const aValue: String): Word;
  public
  	constructor Init;
    destructor Done; virtual;

    function AsValue: Word;
    function AsString: TRecIdField;

    procedure Assign(const aValue: TRecordId);
    procedure AssignValue(const aValue: Word);
    procedure AssignString(const aValue: String);
  end;

	TDatabaseRecord = object(TObject)
  public
  	Id: TRecordId;
    CreatedAt,
    UpdatedAt: TTimeStamp;

  	constructor Init;
    destructor Done; virtual;
  end;

implementation

(*************)
(* TRecordId *)
(*************)

constructor TRecordId.Init;
begin
	inherited Init;
  FId := 0;
end;

destructor TRecordId.Done;
begin
	inherited Done;
end;

function TRecordId.WordToStr(const aValue: Word): TRecIdField;
begin
	WordToStr := Chr(Hi(aValue)) + Chr(Lo(aValue));
end;

function TRecordId.StrToWord(const aValue: String): Word;
begin
	StrToWord := Swap(Ord(aValue[1])) + Ord(aValue[2]);
end;

function TRecordId.AsValue: Word;
begin
	AsValue := FId;
end;

function TRecordId.AsString: TRecIdField;
begin
	AsString := WordToStr(FId);
end;

procedure TRecordId.Assign(const aValue: TRecordId);
begin
	FId := aValue.FId;
end;

procedure TRecordId.AssignValue(const aValue: Word);
begin
	FId := aValue;
end;

procedure TRecordId.AssignString(const aValue: String);
begin
	FId := StrToWord(aValue);
end;

(*******************)
(* TDatabaseRecord *)
(*******************)

constructor TDatabaseRecord.Init;
begin
	inherited Init;

  Id.Init;
  CreatedAt.Init;
  UpdatedAt.Init;
end;

destructor TDatabaseRecord.Done;
begin
  Id.Done;
  CreatedAt.Done;
  UpdatedAt.Done;

	inherited Done;
end;

end.