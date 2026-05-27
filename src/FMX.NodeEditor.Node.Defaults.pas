unit FMX.NodeEditor.Node.Defaults;

interface

uses
  FMX.NodeEditor.Node, System.Types, System.UITypes, FMX.Graphics,
  FMX.NodeEditor.Types;

type
  TFloatNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 180; AHeight: integer = 100); override;
    procedure SetupPins; override;
  end;

  TAddNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 180; AHeight: integer = 130); override;
    procedure SetupPins; override;
  end;

implementation

uses
  System.Math, FMX.Types;

{ TFloatNode }

constructor TFloatNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'float';
  HeaderColor := TAlphaColors.Green;
end;

procedure TFloatNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('Value', 'float', pkData, 45);

  if FindValue('value') = nil then
    AddValue('value', nvkFloat).FloatValue := 0.0;
end;

{ TAddNode }

constructor TAddNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'add';
  HeaderColor := $FF7339AC;
end;

procedure TAddNode.SetupPins;
begin
  ClearPins;

  AddInputPin('A', 'float', pkData, 45).IsRequired := True;
  AddInputPin('B', 'float', pkData, 75).IsRequired := True;
  AddOutputPin('Result', 'float', pkData, 60);
end;

end.

