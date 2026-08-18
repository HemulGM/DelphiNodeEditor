unit FMX.NodeEditor.Parser;

interface

uses
  System.SysUtils, System.Classes, FMX.NodeEditor;

type
  TGraphParser = class abstract(TComponent)
  protected
    FEditor: TNodeEditor;
    FProgress: Single;
    FProgressMsg: string;
    procedure SetProgress(Value: Single; const Msg: string = ''); virtual;
  public
    procedure LoadFromFile(const FileName: string); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure LoadFromString(const Value: string); virtual; abstract;
    function SaveToString(const Formatted: Boolean = True): string; virtual; abstract;
    procedure Clear; virtual; abstract;
    function GetProgress: Single; virtual;
    function GetProgressMsg: string; virtual;
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

function TGraphParser.GetProgress: Single;
begin
  Result := FProgress;
end;

function TGraphParser.GetProgressMsg: string;
begin
  Result := FProgressMsg;
end;

procedure TGraphParser.LoadFromFile(const FileName: string);
begin
  LoadFromString(TFile.ReadAllText(FileName));
end;

procedure TGraphParser.SaveToFile(const FileName: string);
begin
  TFile.WriteAllText(FileName, SaveToString);
end;

procedure TGraphParser.SetProgress(Value: Single; const Msg: string);
begin
  FProgress := Value;
  if not Msg.IsEmpty then
    FProgressMsg := Msg;
end;

end.

