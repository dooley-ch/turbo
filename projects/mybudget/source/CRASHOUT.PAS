unit CrashOut;

interface

procedure Crash(const exitCode: Byte);

(******************)
(* Implementation *)
(******************)
implementation

uses
	Crt;

const
  Width = 55;
  Height = 5;

type
  Rectangle = record
  	X1, Y1,
		X2, Y2 : byte;
  end;

  WindowRec = record
  	Border,
    Vis : Rectangle;
    ForeColor,
    BackColor,
    BorderColor : byte;
    WTitle : String;
  end;

function Center(len, left, right: Integer): Integer;
begin
  Center := (Succ(right - left) Div 2) - (len Div 2);
end;

procedure Box(var w: WindowRec);
const
  UpLeft  = #201;
  UpRight = #187;
  LoLeft  =  #200;
  LoRight = #188;
  HWall   = #205;
  VWall   = #186;
var
  x, y : Integer;
begin
  with w, Border do
  begin
    Window(X1, Y1, X2, Y2);
    TextBackground(BackColor);
    ClrScr;
    TextColor(BorderColor);

    if BorderColor <> BackColor then
    	begin
      	Window(1, 1, 80, 25);
      	GotoXY(X1, Y1);
      	Write(UpLeft);

      	for x := succ(X1) to pred(X2) do
        	Write(HWall);

      	GotoXY(X2, Y1);
      	Write(UpRight);

      	for Y := succ(Y1) to pred(Y2) do
      		begin
        		GotoXY(X2, y);
        		Write(VWall);
      		end;

      	GotoXY(X1, Y2);
      	Write(LoLeft);

      	for x := succ(X1) to pred(X2) do
        	Write(HWall);

      	Write(LoRight);

      	for Y := pred(Y2) downto succ(Y1) do
      		begin
        		GotoXY(X1, y);
        		Write(VWall);
      		end;

      	Window(X1, Y1, X2, Y2);
     	 	GotoXY(Center(Length(WTitle) + 2, X1, X2), 1);
      	TextColor(White);
      	Write(' ', WTitle, ' ');
    	end;

    TextColor(W.ForeColor);
    TextBackground(W.BackColor);
 	end;
end;

procedure DisplayWindow(var w: WindowRec);
begin
  with w, Vis do
  begin
    Box(w);
    Window(X1, Y1, X2, Y2);
    GotoXY(1, 1);
  end;
end;

procedure NewWindow(var w: windowRec; title: String;
                    r: Rectangle; fore, back, borderC: Byte;
                    display: boolean);
begin
  FillChar(w, SizeOf(w), #0);

  with w, r do
  	begin
    	Border.X1 := X1; Border.Y1 := Y1;
    	Border.X2 := x2; Border.Y2 := Y2;

    	Vis.X1 := X1;
			Vis.X2 := x2;
    	Vis.Y1 := y1;
    	Vis.Y2 := y2;

    	if borderC <> back then
    		with Vis do
    			begin
      			Inc(x1, 2);
      			Dec(x2, 2);
      			Inc(y1, 1);

      			if Y2 > Succ(Vis.Y1) then
        			Dec(Y2, 1);
    			end;

    	ForeColor := fore;
    	BackColor := back;
    	BorderColor := borderC;

    	WTitle := title;
    	if Display then
      	DisplayWindow(W);
  	end;
end;

procedure SetRect(var r: Rectangle; width, height: Byte);
begin
  with R do
  	begin
    	X1 := Center(width, 1, 80);
    	X2 := X1 + Width;
    	Y1 := 8 + Center(height, 1, 25);
    	Y2 := Y1 + height;
  	end;
end;

procedure Crash(const exitCode: Byte);
const
	ErrorMessage: String = 'Unexpected fatal error';
  InfoMessage: String = 'Check log for details.  Press any key to exit';
var
	dimensions: Rectangle;
  errorWindow: WindowRec;
  wait: char;
  i: Integer;
begin
	TextBackground(Black);
  ClrScr;

  SetRect(Dimensions, Width, Height);
  NewWindow(ErrorWindow, 'My Budget - 1.0.1', Dimensions,
            White, Red, White, True);
  (*GotoXY(2,2)*)

  with ErrorWindow.Vis do
    GotoXY(Center(Length(ErrorMessage), 1, (X2 - X1)), 2);
	Write(ErrorMessage);

  with ErrorWindow.Vis do
    GotoXY(Center(Length(InfoMessage), 1, (X2 - X1)), 4);
  Write(InfoMessage);

  Wait := ReadKey;
  Window(1, 1, 80, 25);
  GotoXY(1, 1);
  LowVideo;

  TextColor(White);
  TextBackground(Black);
  ClrScr;

  Halt(exitCode);
end;

end.
