unit FMX.NodeEditor.Parser;

interface

uses
  System.SysUtils, System.Classes, FMX.NodeEditor.Controller;

type
  TGraphParser = class abstract
  protected
    FController: TNodeEditorController;
  public
    procedure LoadFromFile(const FileName: string); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure LoadFromString(const Value: string); virtual; abstract;
    function SaveToString: string; virtual; abstract;

    constructor Create(AController: TNodeEditorController); reintroduce;
  end;

implementation

uses
  System.IOUtils;

{ TGraphParser }

constructor TGraphParser.Create(AController: TNodeEditorController);
begin
  inherited Create;
  FController := AController;
end;

procedure TGraphParser.LoadFromFile(const FileName: string);
begin
  LoadFromString(TFile.ReadAllText(FileName));
end;

procedure TGraphParser.SaveToFile(const FileName: string);
begin
  TFile.WriteAllText(FileName, SaveToString);
end;

end.

