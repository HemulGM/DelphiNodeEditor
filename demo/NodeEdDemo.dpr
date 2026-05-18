program NodeEdDemo;

uses
  Forms,
  laznodeeditor in '..\src\laznodeeditor.pas',
  unit1 in 'unit1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

