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
	TBaseClass = object(TObject)
  public
  	Id: LongInt;

    constructor Init;
    destructor Done; virtual;
  end;

  TCategory = object(TBaseClass)
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

(**************)
(* TBaseClass *)
(**************)

constructor TBaseClass.Init;
begin
	inherited Init;
  Id := 0;
end;

destructor TBaseClass.Done;
begin
	inherited Done;
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
