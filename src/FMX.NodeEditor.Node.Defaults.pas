unit FMX.NodeEditor.Node.Defaults;

interface

uses
  FMX.NodeEditor.Node, System.Types, System.UITypes, FMX.Graphics,
  FMX.NodeEditor.Types, FMX.NodeEditor.Executor.Runtime, FMX.NodeEditor.Graph;

type
  TRerouteExecNode = class(TExecutableNode)
  public
    function GetPinLocalPosition(APin: TNodePin): TPoint; override;
    constructor Create; override;
    procedure SetupPins; override;
    procedure AutoLayoutPins; override;
  public
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double; Opacity: Single); override;
  end;

  TRerouteDataNode = class(TExecutableNode)
  public
    function GetPinLocalPosition(APin: TNodePin): TPoint; override;
    constructor Create; override;
    procedure SetupPins; override;
    procedure AutoLayoutPins; override;
  public
    procedure Execute(AContext: TNodeExecutionContext); override;
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double; Opacity: Single); override;
  end;

implementation

uses
  System.Math, FMX.Types;

{ TRerouteExecNode }

function TRerouteExecNode.GetPinLocalPosition(APin: TNodePin): TPoint;
begin
  if APin = nil then
    Exit(Point(0, 0));

  Result := Rect(0, 0, Width, Height).CenterPoint;
end;

procedure TRerouteExecNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double; Opacity: Single);
begin
  if Zoom < ZoomDetailLimitExt then
    Exit;

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
    Canvas.FillEllipse(SelRect, Opacity * 0.3);
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

  case HoveredPinCompatible of
    TPinCompatible.Undefined:
      ;
    TPinCompatible.True:
      Canvas.Fill.Color := $FF00C251;
    TPinCompatible.False:
      Canvas.Fill.Color := $FFCF5600;
  end;

  var BodyRect := RectF(Center.X - Radius, Center.Y - Radius, Center.X + Radius, Center.Y + Radius);

  // Highlight frame
  Canvas.DrawEllipse(BodyRect, Opacity);

  // Body
  BodyRect.Inflate(-Radius * 0.4, -Radius * 0.4);
  Canvas.FillEllipse(BodyRect, Opacity);

  case HoveredPinCompatible of
    TPinCompatible.Undefined:
      ;
    TPinCompatible.True:
      begin
        BodyRect.Inflate(-Radius * 0.3, -Radius * 0.3);
        Canvas.Fill.Color := TAlphaColors.White;
        CachePathObject.Data := 'M9.765 3.205a.75.75 0 0 1 .03 1.06l-4.25 4.5a.75.75 0 0 1-1.075.015L2.22 6.53a.75.75 0 0 1 1.06-1.06l1.705 1.704l3.72-3.939a.75.75 0 0 1 1.06-.03';
        CachePathObject.FitToRect(BodyRect);
        Canvas.FillPath(CachePathObject, Opacity);
      end;
    TPinCompatible.False:
      begin
        BodyRect.Inflate(-Radius * 0.3, -Radius * 0.3);
        Canvas.Fill.Color := TAlphaColors.White;
        CachePathObject.Data := 'm1.897 2.054l.073-.084a.75.75 0 0 1 .976-.073l.084.073L6 4.939l2.97-2.97a.75.75 0 1 1 1.06 1.061L7.061 6l2.97 2.97a.75.75 0 0 1 .072.976l-.073.084a.75.75 0 0 1-.976.073l-.084-.073L6 7.061l-2.97 2.97A.75.75 0 1 1 1.97 8.97L4.939 6l-2.97-2.97a.75.75 0 0 1-.072-.976l.073-.084z';
        CachePathObject.FitToRect(BodyRect);
        Canvas.FillPath(CachePathObject, Opacity);
      end;
  end;
end;

procedure TRerouteExecNode.AutoLayoutPins;
begin
  for var i := 0 to FInputs.Count - 1 do
    FInputs[i].LocalY := Height div 2;

  for var i := 0 to FOutputs.Count - 1 do
    FOutputs[i].LocalY := Height div 2;
end;

constructor TRerouteExecNode.Create;
begin
  inherited;
  MinWidth := 20;
  MinHeight := 20;
  FixedSize := True;
  FWidth := 20;
  FHeight := 20;
  NodeType := 'reroute_exec';
  VisualKind := TNodeVisualKind.Reroute;
  Title := '';
  HeaderColor := $FF737373;
  BodyColor := $FF737373;
end;

procedure TRerouteExecNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('', TNodeValueKind.Null, True, TPinKind.Exec);
  AddInputPin('', TNodeValueKind.Null, True, TPinKind.Exec);

  if InputCount > 0 then
    GetInput(0).AllowMultipleConnections := False;

  if OutputCount > 0 then
    GetOutput(0).AllowMultipleConnections := False;
end;

{ TRerouteDataNode }

function TRerouteDataNode.GetPinLocalPosition(APin: TNodePin): TPoint;
begin
  if APin = nil then
    Exit(Point(0, 0));

  Result := Rect(0, 0, Width, Height).CenterPoint;
end;

procedure TRerouteDataNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double; Opacity: Single);
begin
  if Zoom < ZoomDetailLimitExt then
    Exit;

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
    Canvas.FillEllipse(SelRect, Opacity * 0.3);
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

  case HoveredPinCompatible of
    TPinCompatible.Undefined:
      ;
    TPinCompatible.True:
      Canvas.Fill.Color := $FF00C251;
    TPinCompatible.False:
      Canvas.Fill.Color := $FFCF5600;
  end;

  var BodyRect := RectF(Center.X - Radius, Center.Y - Radius, Center.X + Radius, Center.Y + Radius);

  // Highlight frame
  Canvas.DrawEllipse(BodyRect, Opacity);

  // Body
  BodyRect.Inflate(-Radius * 0.4, -Radius * 0.4);
  Canvas.FillEllipse(BodyRect, Opacity);

  case HoveredPinCompatible of
    TPinCompatible.Undefined:
      ;
    TPinCompatible.True:
      begin
        BodyRect.Inflate(-Radius * 0.3, -Radius * 0.3);
        Canvas.Fill.Color := TAlphaColors.White;
        CachePathObject.Data := 'M9.765 3.205a.75.75 0 0 1 .03 1.06l-4.25 4.5a.75.75 0 0 1-1.075.015L2.22 6.53a.75.75 0 0 1 1.06-1.06l1.705 1.704l3.72-3.939a.75.75 0 0 1 1.06-.03';
        CachePathObject.FitToRect(BodyRect);
        Canvas.FillPath(CachePathObject, Opacity);
      end;
    TPinCompatible.False:
      begin
        BodyRect.Inflate(-Radius * 0.3, -Radius * 0.3);
        Canvas.Fill.Color := TAlphaColors.White;
        CachePathObject.Data := 'm1.897 2.054l.073-.084a.75.75 0 0 1 .976-.073l.084.073L6 4.939l2.97-2.97a.75.75 0 1 1 1.06 1.061L7.061 6l2.97 2.97a.75.75 0 0 1 .072.976l-.073.084a.75.75 0 0 1-.976.073l-.084-.073L6 7.061l-2.97 2.97A.75.75 0 1 1 1.97 8.97L4.939 6l-2.97-2.97a.75.75 0 0 1-.072-.976l.073-.084z';
        CachePathObject.FitToRect(BodyRect);
        Canvas.FillPath(CachePathObject, Opacity);
      end;
  end;
end;

procedure TRerouteDataNode.AutoLayoutPins;
begin
  for var i := 0 to FInputs.Count - 1 do
    FInputs[i].LocalY := Height div 2;

  for var i := 0 to FOutputs.Count - 1 do
    FOutputs[i].LocalY := Height div 2;
end;

constructor TRerouteDataNode.Create;
begin
  inherited;
  MinWidth := 20;
  MinHeight := 20;
  FixedSize := True;
  FWidth := 20;
  FHeight := 20;
  NodeType := 'reroute_data';
  VisualKind := TNodeVisualKind.Reroute;
  Title := '';
  HeaderColor := $FF737373;
  BodyColor := $FF737373;
end;

procedure TRerouteDataNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('', TNodeValueKind.Null, True, TPinKind.Data);
  AddInputPin('', TNodeValueKind.Null, True, TPinKind.Data);

  if InputCount > 0 then
    GetInput(0).AllowMultipleConnections := False;

  if OutputCount > 0 then
    GetOutput(0).AllowMultipleConnections := False;
end;

procedure TRerouteDataNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FOutputs[0], AContext.GetInputValue(FInputs[0]));
end;

end.

