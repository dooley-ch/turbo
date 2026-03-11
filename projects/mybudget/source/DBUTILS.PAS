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

type
	TStringField030 = String[30];
  TStringField100 = String[100];

  TCommentField = TStringField100;
  TTimeStampField = LongInt;
  TDateField = Word;
  TMoneyField = LongInt;
  TNameField = TStringField030;
  TFlagField = Byte;


  function IDToStr(const aValue: Word): String;
  function StrToID(const aValue: String): Word;

implementation

function IDToStr(const aValue: Word): String;
begin
	IDToStr := Chr(Hi(aValue)) + Chr(Lo(aValue));
end;

function StrToID(const aValue: String): Word;
begin
	StrToID := Swap(Ord(aValue[1])) + Ord(aValue[2]);
end;

end.