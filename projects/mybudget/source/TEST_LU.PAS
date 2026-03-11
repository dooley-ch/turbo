program Test;

uses
	LookUpLs;

procedure ListItems(pList: PLookupList);
	procedure PrintLookup(pItem: PLookupItem); far;
	begin
		WriteLn(pItem^.Id, ' ', pItem^.Name);
	end;
begin
	pList^.ForEach(@PrintLookup);
end;

var
	pItem: PLookupItem;
  pList: PLookupList;

begin
	pList := New(PLookupList, Init(50, 10, ByIdDesc));

  with pList^ do
  	begin
    	Insert(New(PLookupItem, Init(1, 'Banana')));
      Insert(New(PLookupItem, Init(2, 'Orange')));
      Insert(New(PLookupItem, Init(3, 'Apple')));
    end;

  ListItems(pList);

  ReadLn;

  Dispose(pList, Done);
end.