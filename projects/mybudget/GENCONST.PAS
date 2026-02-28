program GenTAConstants;

{$I DB.TYP}

var
  OutFile : text;
begin
  Assign(OutFile, 'TACCESS.DEF');
  Rewrite(OutFile);
  Writeln(OutFile, 'Const');
  Writeln(OutFile, '  MaxDataRecSize = ', SizeOf(MaxDataType):3,';');
  Writeln(OutFile, '  MaxKeyLen      = ', SizeOf(MaxKeyType) - 1:3,';');
  Writeln(OutFile, '  PageSize       =  16',';');
  Writeln(OutFile, '  Order          =   8',';');
  Writeln(OutFile, '  PageStackSize  =   5',';');
  Writeln(OutFile, '  MaxHeight      =   5',';');
  Close(OutFile);
end.
