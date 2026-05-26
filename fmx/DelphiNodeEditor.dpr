program DelphiNodeEditor;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  FMX.Types,
  NodeEditor.Main in 'NodeEditor.Main.pas' {FormMain},
  FMX.NodeEditor in '..\src\FMX.NodeEditor.pas',
  FMX.NodeEditor.Form.Search in '..\src\FMX.NodeEditor.Form.Search.pas' {FormNodeEditorSearch},
  FMX.NodeEditor.Node in '..\src\FMX.NodeEditor.Node.pas',
  FMX.NodeEditor.Node.Defaults in '..\src\FMX.NodeEditor.Node.Defaults.pas',
  FMX.NodeEditor.Node.Command in '..\src\FMX.NodeEditor.Node.Command.pas',
  FMX.NodeEditor.Node.Graph in '..\src\FMX.NodeEditor.Node.Graph.pas',
  FMX.NodeEditor.JSON in '..\src\FMX.NodeEditor.JSON.pas',
  FMX.NodeEditor.Types in '..\src\FMX.NodeEditor.Types.pas',
  FMX.NodeEditor.Controller in '..\src\FMX.NodeEditor.Controller.pas',
  FMX.NodeEditor.DAG in '..\src\FMX.NodeEditor.DAG.pas',
  FMX.NodeEditor.Selection in '..\src\FMX.NodeEditor.Selection.pas';

{$R *.res}

begin
  //GlobalUseSkia := True;
  //GlobalUseDX := False;
  //GlobalUseGPUCanvas := False;
  //GlobalUseDirect2D := False;
  //GlobalUseDXSoftware := False;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
