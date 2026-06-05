unit FMX.NodeEditor.Node.Defaults;

interface

uses
  FMX.NodeEditor.Node, System.Types, System.UITypes, FMX.Graphics,
  FMX.NodeEditor.Types;

type
  TFloatNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  TAddNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

implementation

uses
  System.Math, FMX.Types;

{ TFloatNode }

constructor TFloatNode.Create;
begin
  inherited;
  NodeType := 'float';
  HeaderColor := $FF00C080;
  HeaderColor := TAlphaColors.Green;
  Width := 180;
  Height := 100;
end;

procedure TFloatNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('Value', 'float', TPinKind.Data, 45);

  if FindValue('value') = nil then
    AddValue('value', TNodeValueKind.Float).FloatValue := 0.0;
end;

{ TAddNode }

constructor TAddNode.Create;
begin
  inherited;
  NodeType := 'add';
  HeaderColor := $FF7339AC;
  Width := 180;
  Height := 130;
end;

procedure TAddNode.SetupPins;
begin
  ClearPins;

  AddInputPin('A', 'float', TPinKind.Data, 45).IsRequired := True;
  AddInputPin('B', 'float', TPinKind.Data, 75).IsRequired := True;
  AddOutputPin('Result', 'float', TPinKind.Data, 60);
end;

end.

