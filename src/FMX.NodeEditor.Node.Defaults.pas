unit FMX.NodeEditor.Node.Defaults;

interface

uses
  FMX.NodeEditor.Node, System.Types, System.UITypes, FMX.NodeEditor.Types;

type
  TDefaultNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 180; AHeight: integer = 120); override;
    procedure SetupPins; override;
  end;

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

  TRerouteNode = class(TCustomNode)
  public
    function GetPinLocalPosition(APin: TNodePin): TPoint; override;
    constructor Create(ATitle: string; AX, AY: single); override;
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 20; AHeight: integer = 20); override;
    procedure SetupPins; override;
  end;

  TCommentNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 320; AHeight: integer = 200); override;
    procedure SetupPins; override;
  end;

implementation

uses
  System.Math;

{ TDefaultNode }

constructor TDefaultNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'default';
end;

procedure TDefaultNode.SetupPins;
begin
  ClearPins;
  AddInput('In', 'float', pkData, 45);
  AddOutput('Out', 'float', pkData, 45);
end;

{ TFloatNode }

constructor TFloatNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'float';
  HeaderColor := TAlphaColors.MoneyGreen;
end;

procedure TFloatNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  AddOutput('Value', 'float', pkData, 45);

  if FindValue('value') = nil then
  begin
    V := AddValue('value', nvkFloat);
    V.FloatValue := 0.0;
  end;
end;

{ TAddNode }

constructor TAddNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'add';
  HeaderColor := $FFD0A0FF;
end;

procedure TAddNode.SetupPins;
begin
  ClearPins;

  AddInput('A', 'float', pkData, 45);
  GetInput(InputCount - 1).IsRequired := True;

  AddInput('B', 'float', pkData, 75);
  GetInput(InputCount - 1).IsRequired := True;

  AddOutput('Result', 'float', pkData, 60);
end;

{ TRerouteNode }

constructor TRerouteNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, Max(10, AWidth), Max(10, AHeight));
  MinWidth := 20;
  MinHeight := 20;
  NodeType := 'reroute';
  VisualKind := nvReroute;
  Title := '';
  HeaderColor := $FF737373;
  BodyColor := $FF737373;
end;

function TRerouteNode.GetPinLocalPosition(APin: TNodePin): TPoint;
begin
  if APin = nil then
    Exit(Point(0, 0));

  if APin.Direction = pdInput then
    Result := TRect.Create(0, 0, Width, Height).CenterPoint
  else
    Result := TRect.Create(0, 0, Width, Height).CenterPoint;
end;

constructor TRerouteNode.Create(ATitle: string; AX, AY: single);
begin
  Create(ATitle, AX, AY, 20, 20);
end;

procedure TRerouteNode.SetupPins;
begin
  ClearPins;
  AddOutput('', 'any', pkData, Height div 2);
  AddInput('', 'any', pkData, Height div 2);

  if InputCount > 0 then
    GetInput(0).AllowMultipleConnections := False;

  if OutputCount > 0 then
    GetOutput(0).AllowMultipleConnections := False;
end;

{ TCommentNode }

constructor TCommentNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'comment';
  VisualKind := nvComment;
  HeaderColor := $FFB0B0B0;
  BodyColor := $FFFFFFCC;
  CommentText := 'Comment';
end;

procedure TCommentNode.SetupPins;
begin
  ClearPins;
end;

end.

