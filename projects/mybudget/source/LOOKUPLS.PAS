(*--------------------------------------------------------*)
(*   LOOKUPLS.PAS                                         *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   15/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit LookUpLs;

interface

uses
	Objects;

type
	TLookupSortOrder = (ByIdAsc, ByIdDesc, ByNameAsc, ByNameDesc);

	PLookupItem = ^TLookupItem;
  TLookupItem = object(TObject)
  private
  	FId: LongInt;
    FName: String;
  public
  	function Id: LongInt;
    function Name: String;

  	constructor Init(const aId: LongInt; aName: String);
    destructor Done; virtual;
  end;

  PLookupList = ^TLookupList;
  TLookupList = object(TSortedCollection)
  private
  	FOrder: TLookupSortOrder;

  	function Compare(Key1, Key2: Pointer): Integer; virtual;

    function CompareNameAsc(const name1, name2: String): Integer;
    function CompareNameDesc(const name1, name2: String): Integer;
    function CompareIdAsc(const id1, id2: LongInt): Integer;
    function CompareIdDesc(const id1, id2: LongInt): Integer;

  public
  	constructor Init(const aLimit, aDelta: Integer;
											const aOrderBy: TLookupSortOrder);
    destructor Done; virtual;
  end;

implementation

uses
	TPString;

(***************)
(* TLookupList *)
(***************)

constructor TLookupList.Init(const aLimit, aDelta: Integer;
															const aOrderBy: TLookupSortOrder);
begin
	inherited Init(aLimit, aDelta);

  FOrder := aOrderBy;
end;

destructor TLookupList.Done;
begin
	inherited Done;
end;

function TLookupList.CompareIdAsc(const id1, id2: LongInt): Integer;
begin
	if id1 < id2 then
    CompareIdAsc := -1
  else if id1 > id2 then
  	CompareIdAsc := 1
  else
  	CompareIdAsc := 0;
end;

function TLookupList.CompareIdDesc(const id1, id2: LongInt): Integer;
begin
	if id1 < id2 then
    CompareIdDesc := 1
  else if id1 > id2 then
  	CompareIdDesc := -1
  else
  	CompareIdDesc := 0;
end;

function TLookupList.CompareNameAsc(const name1, name2: String): Integer;
var
	result: CompareType;
begin
  result := CompString(name1, name2);
  if result = Less then
		CompareNameAsc := -1
	else if result = Greater  then
		CompareNameAsc := 1
	else
		CompareNameAsc := 0;
end;

function TLookupList.CompareNameDesc(const name1, name2: String): Integer;
var
	result: CompareType;
begin
  result := CompString(name1, name2);
  if result = Less then
		CompareNameDesc := 1
	else if result = Greater  then
		CompareNameDesc := -1
	else
		CompareNameDesc := 0;
end;

function TLookupList.Compare(Key1, Key2: Pointer): Integer;
var
	pKey1, pKey2: PLookupItem;
  name1, name2: String;
  result: CompareType;
begin
	pKey1 := PLookupItem(Key1);
  pKey2 := PLookupItem(Key2);

  case FOrder of
  	ByNameAsc:
    	Compare := CompareNameAsc(pKey1^.Name, pKey2^.Name);
		ByNameDesc:
    	Compare := CompareNameDesc(pKey1^.Name, pKey2^.Name);
  	ByIdAsc:
    	Compare := CompareIdAsc(pKey1^.Id, pKey2^.Id);
		ByIdDesc:
    	Compare := CompareIdDesc(pKey1^.Id, pKey2^.Id);
  end;
end;

(***************)
(* TLookupItem *)
(***************)

constructor TLookupItem.Init(const aId: LongInt; aName: String);
begin
	inherited Init;

  FId := aId;
  FName := aName;
end;

destructor TLookupItem.Done;
begin
	inherited Done;
end;

function TLookupItem.Id: LongInt;
begin
	Id := FId;
end;

function TLookupItem.Name: String;
begin
	Name := FName;
end;

end.