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
  IconPath := 'm5.79 21.61l-1.58-1.22l14-18l1.58 1.22zM4 2v2h2v8h2V2zm11 10v2h4v2h-2c-1.1 0-2 .9-2 2v4h6v-2h-4v-2h2c1.11 0 2-.89 2-2v-2a2 2 0 0 0-2-2z';
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
  IconPath := 'M11 13H5v-2h6V5h2v6h6v2h-6v6h-2z';
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

