unit FMX.NodeEditor.Parser;

interface

uses
  System.SysUtils, System.Classes, FMX.NodeEditor;

type
  TGraphParser = class abstract(TComponent)
  protected
    FEditor: TNodeEditor;
  public
    procedure LoadFromFile(const FileName: string); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure LoadFromString(const Value: string); virtual; abstract;
    function SaveToString(const Formatted: Boolean = True): string; virtual; abstract;
    procedure Clear; virtual; abstract;

    constructor Create(AEditor: TNodeEditor); reintroduce; virtual;
  end;

implementation

uses
  System.IOUtils;

{ TGraphParser }

constructor TGraphParser.Create(AEditor: TNodeEditor);
begin
  inherited Create(AEditor);
  FEditor := AEditor;
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

