program Project1;

uses
  Vcl.Forms,
  TZDB in 'TZDB\TZDB.pas',
  Unit1 in 'Unit1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
