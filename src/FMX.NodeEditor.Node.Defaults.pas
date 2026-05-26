unit FMX.NodeEditor.Node.Defaults;

interface

uses
  FMX.NodeEditor.Node, System.Types, System.UITypes, FMX.Graphics,
  FMX.NodeEditor.Types;

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
  public
    procedure Paint(Canvas: TCanvas; Zoom: Double; OffsetX, OffsetY: Double); override;
  end;

  TCommentNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 320; AHeight: integer = 200); override;
    procedure SetupPins; override;
  public
    procedure Paint(Canvas: TCanvas; Zoom: Double; OffsetX, OffsetY: Double); override;
  end;

implementation

uses
  System.Math, FMX.Types;

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

procedure TRerouteNode.Paint(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double);
begin
  var NodeBounds: TRectF := GetScreenBounds(Zoom, OffsetX, OffsetY);
  var Radius := PinRadius * Zoom;
  var Center := NodeBounds.CenterPoint;

  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Stroke.Kind := TBrushKind.Solid;

  // Frame
  if Selected then
  begin
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.White;
    var SelRect := NodeBounds;
    SelRect.Inflate(3 * Zoom, 3 * Zoom);
    Canvas.FillEllipse(SelRect, 0.3);
  end;

  // Body
  if Hovered or Highlighted then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    if Highlighted then
      Canvas.Fill.Color := GetInput(0).PinType.Color
    else
      Canvas.Fill.Color := $FFFFD740;
    Canvas.Stroke.Color := $FFFFD740;
    Canvas.Stroke.Thickness := 2 * Zoom;
  end
  else
  begin
    Canvas.Fill.Color := GetInput(0).PinType.Color;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := HeaderColor;
    Canvas.Stroke.Thickness := 2 * Zoom;
    Radius := Radius * 0.8;
  end;

  var BodyRect := TRectF.Create(Center.X - Radius, Center.Y - Radius, Center.X + Radius, Center.Y + Radius);

  // Highlight frame
  Canvas.DrawEllipse(BodyRect, 1);

  // Body
  BodyRect.Inflate(-Radius * 0.4, -Radius * 0.4);
  Canvas.FillEllipse(BodyRect, 1);
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

procedure TCommentNode.Paint(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double);
begin
  var ScaledHeaderHeight := HeaderHeight * Zoom;

  var NodeBounds: TRectF := GetScreenBounds(Zoom, OffsetX, OffsetY);

  var NodeHead := TRectF.Create(NodeBounds.Left, NodeBounds.Top, NodeBounds.Right, NodeBounds.Top + ScaledHeaderHeight);
  var NodeHeadText := NodeHead;
  NodeHeadText.Inflate(-10 * Zoom, 0);

  var NodeBody := TRectF.Create(NodeBounds.Left, NodeBounds.Top + ScaledHeaderHeight, NodeBounds.Right, NodeBounds.Bottom);
  var NodeBodyText := NodeBody;
  NodeBodyText.Inflate(-10 * Zoom, -10 * Zoom);

  var CornerRadius := 10 * Zoom;

  // Fill
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := $FF1E2125; //BodyColor;
  Canvas.FillRect(NodeBounds, CornerRadius, CornerRadius, AllCorners, 1);

  // Head
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := HeaderColor;
  if Collapsed then
    Canvas.FillRect(NodeHead, CornerRadius, CornerRadius, AllCorners, 1)
  else
    Canvas.FillRect(NodeHead, CornerRadius, CornerRadius, [TCorner.TopLeft, TCorner.TopRight], 1);

  // Frame
  if Selected then
  begin
    Canvas.Stroke.Color := $FFFFD740;
    Canvas.Stroke.Thickness := 1 * Zoom;
  end
  else if Highlighted then
  begin
    Canvas.Stroke.Color := TAlphaColors.Red;
    Canvas.Stroke.Thickness := 1 * Zoom;
  end
  else if Hovered then
  begin
    Canvas.Stroke.Color := HeaderColor;//TAlphaColors.Blue;
    Canvas.Stroke.Thickness := 1 * Zoom;
  end
  else
  begin
    Canvas.Stroke.Color := HeaderColor;
    Canvas.Stroke.Thickness := 1 * Zoom;
  end;
  Canvas.DrawRect(NodeBounds, CornerRadius, CornerRadius, AllCorners, 1);

  // Text Head
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.Font.Size := (10 * Zoom);
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.FillText(NodeHeadText, Title, False, 1, [], TTextAlign.Leading, TTextAlign.Center);

  // Text Body
  if (CommentText <> '') and (not Collapsed) then
    Canvas.FillText(NodeBodyText, CommentText, True, 1, [], TTextAlign.Leading, TTextAlign.Leading);
end;

procedure TCommentNode.SetupPins;
begin
  ClearPins;
end;

end.

