(*--------------------------------------------------------*)
(*   CLASSES.PAS                                          *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   09/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)
unit Classes;

interface

uses
	Objects;

type
	PBaseDataClass = ^TBaseDataClass;
	TBaseDataClass = object(TObject)
  public
  	Id: LongInt;

    constructor Init;
    destructor Done; virtual;
  end;

  TBaseCollection = object(TSortedCollection)
  private
  	function Compare(Key1, Key2: Pointer): Integer; virtual;
  public
  end;

  TCategory = object(TBaseDataClass)
  public
  	Name,
    Comment: String;

    constructor Init;
    destructor Done; virtual;
  end;

  TSubCategory = object(TCategory)
  public
		CategoryId: LongInt;

    constructor Init;
    destructor Done; virtual;
  end;

implementation

(******************)
(* TBaseDataClass *)
(******************)

constructor TBaseDataClass.Init;
begin
	inherited Init;
  Id := 0;
end;

destructor TBaseDataClass.Done;
begin
	inherited Done;
end;

(*******************)
(* TBaseCollection *)
(*******************)

function TBaseCollection.Compare(Key1, Key2: Pointer): Integer;
var
	id1, id2: LongInt;
begin
	id1 := PBaseDataClass(Key1)^.Id;
	id2 := PBaseDataClass(Key2)^.Id;

	if id1 < id2 then
    Compare := -1
  else if id1 > id2 then
  	Compare := 1
  else
  	Compare := 0;
end;

(*************)
(* TCategory *)
(*************)

constructor TCategory.Init;
begin
	inherited Init;

  Name := '';
  Comment := '';
end;

destructor TCategory.Done;
begin
	inherited Done;
end;

(****************)
(* TSubCategory *)
(****************)

constructor TSubCategory.Init;
begin
	inherited Init;

  CategoryId := 0;
end;

destructor TSubCategory.Done;
begin
	inherited Done;
end;

end.
