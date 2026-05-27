unit FMX.NodeEditor.Node;

interface

uses
  System.Classes, System.SysUtils, System.UITypes, System.Types, System.JSON,
  System.Generics.Collections, FMX.Graphics, FMX.NodeEditor.Types;

type
  TCustomNode = class;

  TCustomNodeClass = class of TCustomNode;

  TNodePinType = class
  public
    TypeId: string;
    Category: string;
    DisplayName: string;
    Color: TAlphaColor;
    Flags: TNodePinTypeFlags;

    constructor Create(const ATypeId: string = 'any'; const ACategory: string = ''; AColor: TAlphaColor = $FF69CCF8);

    function IsAny: boolean;
    function IsCompatibleWith(AOther: TNodePinType): boolean;
    function Clone: TNodePinType;

    procedure SaveToJSON(AObj: TJSONObject);
    procedure LoadFromJSON(AObj: TJSONObject; UseAlphaColor: Boolean);
  end;

  TNodeValue = class
  public
    Name: string;
    Kind: TNodeValueKind;
    FloatValue: double;
    IntegerValue: int64;
    StringValue: string;
    BooleanValue: boolean;
    JSONValue: string;

    constructor Create(const AName: string = ''; AKind: TNodeValueKind = nvkNull);

    procedure SaveToJSON(AObj: TJSONObject);
    procedure LoadFromJSON(AObj: TJSONObject);
  end;

  TNodePin = class
  public
    Id: string;
    Name: string;
    DisplayName: string;
    Kind: TPinKind;
    Direction: TPinDirection;

    // Legacy
    DataType: string;

    PinType: TNodePinType;

    LocalY: integer;
    OwnerNode: TCustomNode;

    IsRequired: boolean;
    DefaultValue: string;
    Tooltip: string;
    Hidden: boolean;
    Advanced: boolean;
    AllowMultipleConnections: boolean;
    SortIndex: integer;
    Connected: boolean;

    constructor Create(AName: string; ADir: TPinDirection; AKind: TPinKind; ALocalY: integer);
    destructor Destroy; override;

    function EffectiveDisplayName: string;
    procedure SetTypeId(const ATypeId: string);
  end;

  TNodeLink = class
  public
    Id: string;
    FromPin: TNodePin;
    ToPin: TNodePin;
    constructor Create(AFrom, ATo: TNodePin);
  end;

  TCustomNode = class abstract
    const
      HeaderHeight = 28;
      BottomPad = 10;
      PinRadius = 8;
      ResizeEdgeSize = 6;
  private
    FInputs: TObjectList<TNodePin>;
    FOutputs: TObjectList<TNodePin>;
    FValues: TObjectList<TNodeValue>;
    FWidth: Integer;
    FHeight: Integer;
  protected
    procedure SetHeight(const Value: Integer); virtual;
    procedure SetWidth(const Value: Integer); virtual;
    function GetDefaultHeaderColor: TAlphaColor; virtual;
    function GetDefaultBodyColor: TAlphaColor; virtual;
  private
    function GetHeight: Integer;
  public
    Id: string;
    NodeType: string;
    Title: string;
    IconPath: string;
    X, Y: Single;
    MinWidth, MinHeight: Integer;
    HeaderColor: TAlphaColor;
    BodyColor: TAlphaColor;
    Selected: boolean;

    VisualKind: TNodeVisualKind;
    CommentText: string;
    Hovered: boolean;
    HoveredPinId: string;
    // On pin hover
    Highlighted: boolean;
    FixedSize: Boolean;

    Collapsed: boolean;
    ZOrder: integer;
    Connected: boolean;

    constructor Create(ATitle: string; AX, AY: single); overload; virtual;
    constructor Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer); overload; virtual;
    destructor Destroy; override;

    procedure SetupPins; virtual;

    procedure ClearPins;
    function AddInputPin(const AName, ADataType: string; AKind: TPinKind = pkData; ALocalY: integer = -1): TNodePin;
    function AddOutputPin(const AName, ADataType: string; AKind: TPinKind = pkData; ALocalY: integer = -1): TNodePin;
    function RemovePin(APin: TNodePin): boolean;
    procedure ReindexPins;
    procedure AutoLayoutPins;

    function InputCount: integer;
    function OutputCount: integer;
    function GetInput(Index: integer): TNodePin;
    function GetOutput(Index: integer): TNodePin;
    function FindPinById(const AId: string): TNodePin;
    function OutputsIsBusy: Boolean;
    function InputsIsBusy: Boolean;

    function GetPinScreenPosition(APin: TNodePin; Zoom: Double; OffsetX, OffsetY: Double): TPoint;
    function GetPinWorldPosition(APin: TNodePin): TPointF;

    function HitTest(WX, WY: single): boolean;
    function GetScreenBounds(Zoom: double; OffsetX, OffsetY: Double): TRect;

    procedure ClearValues;
    function AddValue(const AName: string; AKind: TNodeValueKind): TNodeValue;
    function FindValue(const AName: string): TNodeValue;
    function ValueCount: integer;
    function GetValue(Index: integer): TNodeValue;

    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;

    procedure SaveToJSON(AObj: TJSONObject); virtual;
    procedure LoadFromJSON(AObj: TJSONObject; UseAlphaColor: Boolean); virtual;
  protected
    function GetPinLocalPosition(APin: TNodePin): TPoint; virtual;
  private
    function GetPinScreenRect(APin: TNodePin; Zoom: Double; OffsetX, OffsetY: Double; Radius: integer = 8): TRect;
    function GetPinAt(LocalX, LocalY: integer): TNodePin;
    procedure DrawGrip(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; const AOpacity: Single = 1.0);
    function GetResizeHandleRect(Zoom, OffsetX, OffsetY: Double): TRect;
  public
    procedure ApplyPropertiesFromJSON(AObj: TJSONObject); virtual;
    procedure Paint(Canvas: TCanvas; Zoom: Double; OffsetX, OffsetY: Double); virtual;
  end;

  TDefaultNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 180; AHeight: integer = 120); override;
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

constructor TCustomNode.Create(ATitle: string; AX, AY: single);
begin
  Create(ATitle, AX, AY, 180, 120);
end;

constructor TCustomNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create;

  FInputs := TObjectList<TNodePin>.Create;
  FOutputs := TObjectList<TNodePin>.Create;
  FValues := TObjectList<TNodeValue>.Create;

  MinWidth := 40;
  MinHeight := 28;
  Id := NewId;
  NodeType := 'default';
  Title := ATitle;

  X := AX;
  Y := AY;
  FWidth := AWidth;
  FHeight := AHeight;

  HeaderColor := GetDefaultHeaderColor;
  BodyColor := GetDefaultBodyColor;

  Selected := False;

  VisualKind := nvNormal;
  CommentText := '';
  Hovered := False;
  Highlighted := False;
  Collapsed := False;
  FixedSize := False;
  ZOrder := 0;
end;

destructor TCustomNode.Destroy;
begin
  ClearValues;
  ClearPins;
  FValues.Free;
  FInputs.Free;
  FOutputs.Free;
  inherited Destroy;
end;

function TCustomNode.GetDefaultHeaderColor: TAlphaColor;
begin
  Result := $FF1D8EA7;
end;

function TCustomNode.GetHeight: Integer;
begin
  if Collapsed and (VisualKind <> TNodeVisualKind.nvReroute) then
    Result := HeaderHeight
  else
    Result := FHeight;
end;

function TCustomNode.GetDefaultBodyColor: TAlphaColor;
begin
  Result := TAlphaColors.White;
end;

procedure TCustomNode.SetHeight(const Value: Integer);
begin
  if Collapsed or FixedSize then
    Exit;
  if VisualKind <> TNodeVisualKind.nvReroute then
    FHeight := Max(60, Max(Max(InputCount, OutputCount) * 30 + HeaderHeight + BottomPad, Value))
  else
    FHeight := Value;
  AutoLayoutPins;
end;

procedure TCustomNode.SetupPins;
begin

end;

procedure TCustomNode.SetWidth(const Value: Integer);
begin
  if FixedSize then
    Exit;
  if VisualKind <> TNodeVisualKind.nvReroute then
    FWidth := Max(100, Value)
  else
    FWidth := Value;
  AutoLayoutPins;
end;

procedure TCustomNode.ClearPins;
begin
  FInputs.Clear;
  FOutputs.Clear;
end;

function TCustomNode.AddInputPin(const AName, ADataType: string; AKind: TPinKind; ALocalY: integer): TNodePin;
begin
  if ALocalY < 0 then
    ALocalY := (HeaderHeight + 16) + FInputs.Count * 26;

  Result := TNodePin.Create(AName, pdInput, AKind, ALocalY);
  Result.OwnerNode := Self;
  Result.SetTypeId(ADataType);
  Result.AllowMultipleConnections := False;
  Result.SortIndex := FInputs.Count;
  FInputs.Add(Result);

  ReindexPins;
  AutoLayoutPins;
end;

function TCustomNode.AddOutputPin(const AName, ADataType: string; AKind: TPinKind; ALocalY: integer): TNodePin;
begin
  if ALocalY < 0 then
    ALocalY := (HeaderHeight + 16) + FOutputs.Count * 26;

  Result := TNodePin.Create(AName, pdOutput, AKind, ALocalY);
  Result.OwnerNode := Self;
  Result.SetTypeId(ADataType);
  Result.AllowMultipleConnections := True;
  Result.SortIndex := FOutputs.Count;
  FOutputs.Add(Result);

  ReindexPins;
  AutoLayoutPins;
end;

function TCustomNode.RemovePin(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  if APin.OwnerNode <> Self then
    Exit;

  if APin.Direction = pdInput then
  begin
    if FInputs.Remove(APin) >= 0 then
      Result := True;
  end
  else
  begin
    if FOutputs.Remove(APin) >= 0 then
      Result := True;
  end;

  if Result then
  begin
    ReindexPins;
    AutoLayoutPins;
  end;
end;

procedure TCustomNode.ReindexPins;
begin
  for var i := 0 to FInputs.Count - 1 do
    FInputs[i].SortIndex := i;

  for var i := 0 to FOutputs.Count - 1 do
    FOutputs[i].SortIndex := i;
end;

procedure TCustomNode.AutoLayoutPins;
begin
  if VisualKind = nvReroute then
  begin
    for var i := 0 to FInputs.Count - 1 do
      FInputs[i].LocalY := Height div 2;

    for var i := 0 to FOutputs.Count - 1 do
      FOutputs[i].LocalY := Height div 2;

    Exit;
  end;

  if VisualKind = nvComment then
    Exit;

  var MaxCount := Max(FInputs.Count, FOutputs.Count);
  if MaxCount <= 0 then
    Exit;

  var WorkH := Height - HeaderHeight - BottomPad;

  for var i := 0 to FInputs.Count - 1 do
    FInputs[i].LocalY := HeaderHeight + (i + 1) * WorkH div (FInputs.Count + 1);

  for var i := 0 to FOutputs.Count - 1 do
    FOutputs[i].LocalY := HeaderHeight + (i + 1) * WorkH div (FOutputs.Count + 1);
end;

function TCustomNode.InputCount: integer;
begin
  if FInputs <> nil then
    Result := FInputs.Count
  else
    Result := 0;
end;

function TCustomNode.InputsIsBusy: Boolean;
begin
  Result := True;
  for var Pin in FInputs do
    if not Pin.Connected then
      Exit(False);
end;

function TCustomNode.OutputCount: integer;
begin
  if FOutputs <> nil then
    Result := FOutputs.Count
  else
    Result := 0;
end;

function TCustomNode.OutputsIsBusy: Boolean;
begin
  Result := True;
  for var Pin in FOutputs do
    if not Pin.Connected then
      Exit(False);
end;

function TCustomNode.GetInput(Index: integer): TNodePin;
begin
  if (Index >= 0) and (Index < FInputs.Count) then
    Result := FInputs[Index]
  else
    Result := nil;
end;

function TCustomNode.GetOutput(Index: integer): TNodePin;
begin
  if (Index >= 0) and (Index < FOutputs.Count) then
    Result := FOutputs[Index]
  else
    Result := nil;
end;

function TCustomNode.FindPinById(const AId: string): TNodePin;
begin
  Result := nil;

  for var i := 0 to InputCount - 1 do
    if GetInput(i).Id = AId then
      Exit(GetInput(i));

  for var i := 0 to OutputCount - 1 do
    if GetOutput(i).Id = AId then
      Exit(GetOutput(i));
end;

function TCustomNode.GetPinLocalPosition(APin: TNodePin): TPoint;
begin
  if APin.Direction = pdInput then
  begin
    if Collapsed then
      Result := TPoint.Create(0, HeaderHeight div 2)
    else
      Result := TPoint.Create(0, APin.LocalY);
  end
  else
  begin
    if Collapsed then
      Result := TPoint.Create(Width, HeaderHeight div 2)
    else
      Result := TPoint.Create(Width, APin.LocalY);
  end;
end;

function TCustomNode.GetPinScreenPosition(APin: TNodePin; Zoom: Double; OffsetX, OffsetY: Double): TPoint;
begin
  if (APin = nil) or (APin.OwnerNode <> Self) then
    Exit(TPoint.Create(0, 0));

  var P := GetPinLocalPosition(APin);
  Result.X := Round((X + P.X) * Zoom + OffsetX);
  Result.Y := Round((Y + P.Y) * Zoom + OffsetY);
end;

function TCustomNode.GetPinWorldPosition(APin: TNodePin): TPointF;
begin
  if (APin = nil) or (APin.OwnerNode <> Self) then
    Exit(TPointF.Create(0, 0));

  var LocalPos := GetPinLocalPosition(APin);
  Result := TPointF.Create(X + LocalPos.X, Y + LocalPos.Y);
end;

function TCustomNode.GetPinScreenRect(APin: TNodePin; Zoom: Double; OffsetX, OffsetY: Double; Radius: integer): TRect;
begin
  var P := GetPinScreenPosition(APin, Zoom, OffsetX, OffsetY);
  var R := if VisualKind = nvReroute then Max(5, Radius)else Radius;
  Result := TRect.Create(P.X - R, P.Y - R, P.X + R, P.Y + R);
end;

function TCustomNode.GetPinAt(LocalX, LocalY: integer): TNodePin;
begin
  Result := nil;

  if VisualKind = nvReroute then
  begin
    var R: Integer := 10;

    for var i := 0 to FInputs.Count - 1 do
    begin
      var p := FInputs[i];
      var CX: Integer := 0;
      var CY := p.LocalY;
      if Sqrt(Sqr(LocalX - CX) + Sqr(LocalY - CY)) <= R then
        Exit(p);
    end;

    for var i := 0 to FOutputs.Count - 1 do
    begin
      var p := FOutputs[i];
      var CX := Width;
      var CY := p.LocalY;
      if Sqrt(Sqr(LocalX - CX) + Sqr(LocalY - CY)) <= R then
        Exit(p);
    end;

    Exit;
  end;

  for var i := 0 to FInputs.Count - 1 do
  begin
    var P := FInputs[i];
    if (Abs(LocalX) < 14) and (Abs(LocalY - P.LocalY) < 14) then
      Exit(P);
  end;

  for var i := 0 to FOutputs.Count - 1 do
  begin
    var P := FOutputs[i];
    if (Abs(LocalX - Width) < 14) and (Abs(LocalY - P.LocalY) < 14) then
      Exit(P);
  end;
end;

function TCustomNode.HitTest(WX, WY: single): boolean;
var
  CX, CY, RX, RY: single;
  DX, DY: single;
  RX2, RY2: single;
  L, T, R, B: single;
begin
  if VisualKind = nvReroute then
  begin
    CX := X + Width * 0.5;
    CY := Y + Height * 0.5;
    RX := Max(16, Width * 0.5 + 8);
    RY := Max(16, Height * 0.5 + 8);

    L := CX - RX;
    T := CY - RY;
    R := CX + RX;
    B := CY + RY;

    if (WX < L) or (WY < T) or (WX > R) or (WY > B) then
      Exit(False);

    DX := WX - CX;
    DY := WY - CY;
    RX2 := RX * RX;
    RY2 := RY * RY;

    Result := (DX * DX * RY2 + DY * DY * RX2) <= (RX2 * RY2);
    Exit;
  end;
  if Collapsed then
    Result := (WX >= X) and (WY >= Y) and (WX <= X + Width) and (WY <= Y + HeaderHeight)
  else
    Result := (WX >= X) and (WY >= Y) and (WX <= X + Width) and (WY <= Y + Height);
end;

function TCustomNode.GetScreenBounds(Zoom: double; OffsetX, OffsetY: Double): TRect;
begin
  Result.Left := Round(x * Zoom + OffsetX);
  Result.Top := Round(y * Zoom + OffsetY);
  Result.Right := Result.Left + Round(Width * Zoom);
  Result.Bottom := Result.Top + Round(Height * Zoom);
end;

procedure TCustomNode.ClearValues;
begin
  FValues.Clear;
end;

function TCustomNode.AddValue(const AName: string; AKind: TNodeValueKind): TNodeValue;
begin
  Result := FindValue(AName);

  if Result <> nil then
  begin
    Result.Kind := AKind;
    Exit;
  end;

  Result := TNodeValue.Create(AName, AKind);
  FValues.Add(Result);
end;

function TCustomNode.FindValue(const AName: string): TNodeValue;
begin
  Result := nil;

  for var i := 0 to FValues.Count - 1 do
  begin
    var V := FValues[i];
    if SameText(V.Name, AName) then
      Exit(V);
  end;
end;

function TCustomNode.ValueCount: integer;
begin
  Result := FValues.Count;
end;

function TCustomNode.GetValue(Index: integer): TNodeValue;
begin
  if (Index >= 0) and (Index < FValues.Count) then
    Result := FValues[Index]
  else
    Result := nil;
end;

procedure TCustomNode.Paint(Canvas: TCanvas; Zoom: Double; OffsetX, OffsetY: Double);
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

  // Shadow
  DrawShadowedRect(Canvas, NodeBounds, CornerRadius, Zoom);

  // Fill Body
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := $FF1E2125;  //BodyColor
  Canvas.Stroke.Kind := TBrushKind.None;
  Canvas.FillRect(NodeBody, CornerRadius, CornerRadius, AllCorners, 1);

  // Fill Head
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := HeaderColor;
  Canvas.Stroke.Kind := TBrushKind.None;
  if Collapsed then
    Canvas.FillRect(NodeHead, CornerRadius, CornerRadius, AllCorners, 1)
  else
    Canvas.FillRect(NodeHead, CornerRadius, CornerRadius, [TCorner.TopLeft, TCorner.TopRight], 1);

  // Frame
  Canvas.Fill.Kind := TBrushKind.None;
  Canvas.Stroke.Kind := TBrushKind.Solid;

  if Selected then
  begin
    Canvas.Stroke.Color := $FFFFD740;
    Canvas.Stroke.Thickness := 2 * Zoom;
  end
  else if Highlighted then
  begin
    Canvas.Stroke.Color := HeaderColor;
    Canvas.Stroke.Thickness := 2 * Zoom;
  end
  else if Hovered then
  begin
    Canvas.Stroke.Color := HeaderColor;
    Canvas.Stroke.Thickness := 2 * Zoom;
  end
  else
  begin // default
    Canvas.Stroke.Color := HeaderColor;
    Canvas.Stroke.Thickness := 1 * Zoom;
  end;

  Canvas.DrawRect(NodeBounds, CornerRadius, CornerRadius, AllCorners, 1);

  // Head Text
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.Font.Size := 10 * Zoom;
  Canvas.FillText(NodeHeadText, Title, False, 1, [], TTextAlign.Leading, TTextAlign.Center);

  // Size grip
  if Selected and (VisualKind <> TNodeVisualKind.nvReroute) and (not Collapsed) then
    DrawGrip(Canvas, Zoom, OffsetX, OffsetY, 1);
end;

function TCustomNode.GetResizeHandleRect(Zoom, OffsetX, OffsetY: Double): TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if VisualKind = TNodeVisualKind.nvReroute then
    Exit;
  if FixedSize then
    Exit;

  var R := GetScreenBounds(Zoom, OffsetX, OffsetY);
  var S := Round(ResizeEdgeSize * Zoom);
  Result := Rect(R.Right - S, R.Bottom - S, R.Right + 1, R.Bottom + 1);
end;

procedure TCustomNode.DrawGrip(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; const AOpacity: Single);
begin
  var R := GetResizeHandleRect(Zoom, OffsetX, OffsetY);
  var GripSize := Min(R.Width, R.Height);
  R.Offset(-GripSize, -GripSize);

  var Margin := GripSize * 0.18;
  var Step := GripSize * 0.28;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Cap := TStrokeCap.Round;
  Canvas.Stroke.Thickness := Max(1.5, GripSize * 0.08);

  for var i := 0 to 2 do
  begin
    var X1 := R.Left + Margin + i * Step;
    var Y1 := R.Bottom - Margin;

    var X2 := R.Right - Margin;
    var Y2 := R.Top + Margin + i * Step;

    // Dark shadow
    Canvas.Stroke.Color := TAlphaColorF.Create(0, 0, 0, 0.55 * AOpacity).ToAlphaColor;
    Canvas.DrawLine(PointF(X1 + 1, Y1 + 1), PointF(X2 + 1, Y2 + 1), 1);

    // Bright line
    Canvas.Stroke.Color := TAlphaColorF.Create(1, 1, 1, 0.85 * AOpacity).ToAlphaColor;
    Canvas.DrawLine(PointF(X1, Y1), PointF(X2, Y2), 1);
  end;
end;

procedure TCustomNode.SaveToJSON(AObj: TJSONObject);
var
  PinsArr, ValuesArr: TJSONArray;
  PinObj, ValueObj, PinTypeObj: TJSONObject;
  i: integer;
  P: TNodePin;
  V: TNodeValue;
begin
  if AObj = nil then
    Exit;

  AObj.AddPair('id', Id);
  AObj.AddPair('type', NodeType);
  AObj.AddPair('title', Title);
  AObj.AddPair('icon', IconPath);
  AObj.AddPair('x', x);
  AObj.AddPair('y', y);
  AObj.AddPair('width', Width);
  AObj.AddPair('height', Height);
  AObj.AddPair('headerColor', Cardinal(HeaderColor));
  AObj.AddPair('bodyColor', Cardinal(BodyColor));
  AObj.AddPair('visualKind', Ord(VisualKind));
  AObj.AddPair('commentText', CommentText);
  AObj.AddPair('collapsed', Collapsed);
  AObj.AddPair('zOrder', ZOrder);

  // Pins
  PinsArr := TJSONArray.Create;
  for i := 0 to InputCount - 1 do
  begin
    P := GetInput(i);
    PinObj := TJSONObject.Create;

    PinObj.AddPair('id', P.Id);
    PinObj.AddPair('name', P.Name);
    PinObj.AddPair('displayName', P.DisplayName);
    PinObj.AddPair('kind', PinKindToStr(P.Kind));
    PinObj.AddPair('direction', PinDirectionToStr(P.Direction));
    PinObj.AddPair('dataType', P.DataType);
    PinObj.AddPair('localY', P.LocalY);

    PinObj.AddPair('isRequired', P.IsRequired);
    PinObj.AddPair('defaultValue', P.DefaultValue);
    PinObj.AddPair('tooltip', P.Tooltip);
    PinObj.AddPair('hidden', P.Hidden);
    PinObj.AddPair('advanced', P.Advanced);
    PinObj.AddPair('allowMultipleConnections', P.AllowMultipleConnections);
    PinObj.AddPair('sortIndex', P.SortIndex);

    if P.PinType <> nil then
    begin
      PinTypeObj := TJSONObject.Create;
      P.PinType.SaveToJSON(PinTypeObj);
      PinObj.AddPair('pinType', PinTypeObj);
    end;

    PinsArr.Add(PinObj);
  end;

  for i := 0 to OutputCount - 1 do
  begin
    P := GetOutput(i);
    PinObj := TJSONObject.Create;

    PinObj.AddPair('id', P.Id);
    PinObj.AddPair('name', P.Name);
    PinObj.AddPair('displayName', P.DisplayName);
    PinObj.AddPair('kind', PinKindToStr(P.Kind));
    PinObj.AddPair('direction', PinDirectionToStr(P.Direction));
    PinObj.AddPair('dataType', P.DataType);
    PinObj.AddPair('localY', P.LocalY);
    PinObj.AddPair('allowMultipleConnections', P.AllowMultipleConnections);
    PinObj.AddPair('sortIndex', P.SortIndex);

    if P.PinType <> nil then
    begin
      PinTypeObj := TJSONObject.Create;
      P.PinType.SaveToJSON(PinTypeObj);
      PinObj.AddPair('pinType', PinTypeObj);
    end;

    PinsArr.Add(PinObj);
  end;

  AObj.AddPair('pins', PinsArr);

  // Values
  ValuesArr := TJSONArray.Create;
  for i := 0 to ValueCount - 1 do
  begin
    V := GetValue(i);
    ValueObj := TJSONObject.Create;
    V.SaveToJSON(ValueObj);
    ValuesArr.Add(ValueObj);
  end;
  AObj.AddPair('values', ValuesArr);
end;

procedure TCustomNode.LoadFromJSON(AObj: TJSONObject; UseAlphaColor: Boolean);
var
  PinsArr, ValuesArr: TJSONArray;
  PinObj, PinTypeObj, ValueObj: TJSONValue;
  P: TNodePin;
  V: TNodeValue;
  Dir: TPinDirection;
  Kind: TPinKind;
begin
  if AObj = nil then
    Exit;

  Id := AObj.GetValue('id', Id);
  NodeType := AObj.GetValue('type', NodeType);

  Title := AObj.GetValue('title', Title);
  IconPath := AObj.GetValue('icon', IconPath);
  X := AObj.GetValue('x', X);
  Y := AObj.GetValue('y', Y);
  Width := AObj.GetValue('width', Width);
  Height := AObj.GetValue('height', Height);
  if UseAlphaColor then
  begin
    HeaderColor := TAlphaColor(AObj.GetValue('headerColor', Cardinal(HeaderColor)));
    BodyColor := TAlphaColor(AObj.GetValue('bodyColor', Cardinal(BodyColor)));
  end
  else
  begin
    HeaderColor := ColorToAlphaColor(TColor(AObj.GetValue('headerColor', Integer(HeaderColor))));
    BodyColor := ColorToAlphaColor(TColor(AObj.GetValue('bodyColor', Integer(BodyColor))));
  end;
  Collapsed := AObj.GetValue('collapsed', False);
  CommentText := AObj.GetValue('commentText', CommentText);

  VisualKind := TNodeVisualKind(AObj.GetValue('visualKind', Ord(nvNormal)));
  ZOrder := AObj.GetValue<Integer>('zOrder', 0);

  // Pins
  ClearPins;
  PinsArr := AObj.GetValue<TJSONArray>('pins', nil);
  if PinsArr <> nil then
  begin
    for var i := 0 to PinsArr.Count - 1 do
    begin
      PinObj := PinsArr.Items[i];

      Dir := StrToPinDirection(PinObj.GetValue('direction', 'input'));
      Kind := StrToPinKind(PinObj.GetValue('kind', 'data'));

      P := TNodePin.Create(PinObj.GetValue('name', ''), Dir, Kind, PinObj.GetValue<Integer>('localY', 40));

      P.Id := PinObj.GetValue('id', P.Id);
      P.DisplayName := PinObj.GetValue('displayName', P.Name);
      P.DataType := PinObj.GetValue('dataType', '');
      P.SetTypeId(P.DataType);

      PinTypeObj := PinObj.GetValue<TJSONObject>('pinType', nil);
      if PinTypeObj <> nil then
        P.PinType.LoadFromJSON(TJSONObject(PinTypeObj), UseAlphaColor);

      P.IsRequired := PinObj.GetValue('isRequired', False);
      P.DefaultValue := PinObj.GetValue('defaultValue', '');
      P.Tooltip := PinObj.GetValue('tooltip', '');
      P.Hidden := PinObj.GetValue('hidden', False);
      P.Advanced := PinObj.GetValue('advanced', False);
      P.AllowMultipleConnections := PinObj.GetValue('allowMultipleConnections', Dir = pdOutput);
      P.SortIndex := PinObj.GetValue<Integer>('sortIndex', 0);

      P.OwnerNode := Self;

      if Dir = pdInput then
        FInputs.Add(P)
      else
        FOutputs.Add(P);
    end;
    AutoLayoutPins;
  end
  else
    SetupPins;

  // Values
  ClearValues;
  ValuesArr := AObj.GetValue<TJSONArray>('values');
  if ValuesArr <> nil then
    for var i := 0 to ValuesArr.Count - 1 do
    begin
      ValueObj := ValuesArr.Items[i];
      V := TNodeValue.Create;
      V.LoadFromJSON(TJSONObject(ValueObj));
      FValues.Add(V);
    end;
end;

procedure TCustomNode.ApplyPropertiesFromJSON(AObj: TJSONObject);
begin
  if AObj = nil then
    Exit;

  Title := AObj.GetValue('title', Title);
  IconPath := AObj.GetValue('icon', IconPath);
  X := AObj.GetValue('x', X);
  Y := AObj.GetValue('y', Y);
  Width := AObj.GetValue('width', Width);
  Height := AObj.GetValue('height', Height);
  HeaderColor := TAlphaColor(AObj.GetValue('headerColor', Cardinal(HeaderColor)));
  BodyColor := TAlphaColor(AObj.GetValue('bodyColor', Cardinal(BodyColor)));
  Collapsed := AObj.GetValue('collapsed', Collapsed);
  CommentText := AObj.GetValue('comment', CommentText);

  var ValuesArr := AObj.GetValue<TJSONArray>('values', nil);
  if ValuesArr <> nil then
  begin
    for var i := 0 to Min(ValueCount, ValuesArr.Count) - 1 do
    begin
      var V := GetValue(i);
      var VObj := ValuesArr.Items[i] as TJSONObject;
      if (V = nil) or (VObj = nil) then
        Continue;

      case V.Kind of
        nvkFloat:
          V.FloatValue := VObj.GetValue('value', V.FloatValue);
        nvkInteger:
          V.IntegerValue := VObj.GetValue('value', V.IntegerValue);
        nvkString:
          V.StringValue := VObj.GetValue('value', V.StringValue);
        nvkBoolean:
          V.BooleanValue := VObj.GetValue('value', V.BooleanValue);
        nvkJSON:
          V.JSONValue := VObj.GetValue('value', V.JSONValue);
      end;
    end;
  end;
end;

{ TNodePinType }

constructor TNodePinType.Create(const ATypeId: string; const ACategory: string; AColor: TAlphaColor);
begin
  inherited Create;

  TypeId := ATypeId.Trim.ToLower;
  if TypeId = '' then
    TypeId := 'any';

  Category := ACategory;
  DisplayName := TypeId;
  Color := AColor;
  Flags := [];

  if SameText(TypeId, 'any') then
    Include(Flags, ptfAny);
end;

function TNodePinType.IsAny: boolean;
begin
  Result := SameText(TypeId, 'any') or (ptfAny in Flags) or (ptfWildcard in Flags);
end;

function TNodePinType.IsCompatibleWith(AOther: TNodePinType): boolean;
begin
  Result := False;

  if AOther = nil then
    Exit;

  if IsAny or AOther.IsAny then
    Exit(True);

  if SameText(TypeId, AOther.TypeId) then
    Exit(True);

  if SameText(TypeId, 'integer') and SameText(AOther.TypeId, 'float') then
    Exit(True);

  if SameText(TypeId, 'float') and SameText(AOther.TypeId, 'integer') then
    Exit(True);

  if (ptfNullable in Flags) and SameText(TypeId, AOther.TypeId) then
    Exit(True);

  if (ptfNullable in AOther.Flags) and SameText(TypeId, AOther.TypeId) then
    Exit(True);
end;

function TNodePinType.Clone: TNodePinType;
begin
  Result := TNodePinType.Create(TypeId, Category, Color);
  Result.DisplayName := DisplayName;
  Result.Flags := Flags;
end;

procedure TNodePinType.SaveToJSON(AObj: TJSONObject);
begin
  if AObj = nil then
    Exit;

  AObj.AddPair('typeId', TypeId);
  AObj.AddPair('category', Category);
  AObj.AddPair('displayName', DisplayName);
  AObj.AddPair('color', Cardinal(Color));
  AObj.AddPair('flags', TypeFlagsToInt(Flags));
end;

procedure TNodePinType.LoadFromJSON(AObj: TJSONObject; UseAlphaColor: Boolean);
begin
  if AObj = nil then
    Exit;

  TypeId := AObj.GetValue('typeId', TypeId);
  Category := AObj.GetValue('category', Category);
  DisplayName := AObj.GetValue('displayName', DisplayName);   {
  if UseAlphaColor then
    Color := TAlphaColor(AObj.GetValue('color', Cardinal(Color)))
  else
    Color := ColorToAlphaColor(AObj.GetValue('color', Integer(Color)));   }
  Flags := IntToTypeFlags(AObj.GetValue('flags', TypeFlagsToInt(Flags)));

  if TypeId = '' then
    TypeId := 'any';
end;

{ TNodeValue }

constructor TNodeValue.Create(const AName: string; AKind: TNodeValueKind);
begin
  inherited Create;

  Name := AName;
  Kind := AKind;
  FloatValue := 0;
  IntegerValue := 0;
  StringValue := '';
  BooleanValue := False;
  JSONValue := '';
end;

procedure TNodeValue.SaveToJSON(AObj: TJSONObject);
begin
  if AObj = nil then
    Exit;

  AObj.AddPair('name', Name);
  AObj.AddPair('kind', NodeValueKindToStr(Kind));

  case Kind of
    nvkFloat:
      AObj.AddPair('value', FloatValue);
    nvkInteger:
      AObj.AddPair('value', IntegerValue);
    nvkString:
      AObj.AddPair('value', StringValue);
    nvkBoolean:
      AObj.AddPair('value', BooleanValue);
    nvkJSON:
      AObj.AddPair('value', JSONValue);
  else
    AObj.AddPair('value', '');
  end;
end;

procedure TNodeValue.LoadFromJSON(AObj: TJSONObject);
begin
  if AObj = nil then
    Exit;

  Name := AObj.GetValue('name', Name);
  Kind := StrToNodeValueKind(AObj.GetValue('kind', 'null'));

  case Kind of
    nvkFloat:
      FloatValue := AObj.GetValue('value', FloatValue);
    nvkInteger:
      IntegerValue := AObj.GetValue('value', IntegerValue);
    nvkString:
      StringValue := AObj.GetValue('value', StringValue);
    nvkBoolean:
      BooleanValue := AObj.GetValue('value', BooleanValue);
    nvkJSON:
      JSONValue := AObj.GetValue('value', JSONValue);
  end;
end;

{ TNodePin }

constructor TNodePin.Create(AName: string; ADir: TPinDirection; AKind: TPinKind; ALocalY: integer);
begin
  inherited Create;

  Id := NewId;
  Name := AName;
  DisplayName := AName;

  Direction := ADir;
  Kind := AKind;
  LocalY := ALocalY;

  DataType := '';
  PinType := TNodePinType.Create('any', '');

  OwnerNode := nil;

  IsRequired := False;
  DefaultValue := '';
  Tooltip := '';
  Hidden := False;
  Advanced := False;
  AllowMultipleConnections := ADir = pdOutput;
  SortIndex := 0;
end;

destructor TNodePin.Destroy;
begin
  PinType.Free;
  inherited Destroy;
end;

function TNodePin.EffectiveDisplayName: string;
begin
  if DisplayName <> '' then
    Result := DisplayName
  else
    Result := Name;
end;

procedure TNodePin.SetTypeId(const ATypeId: string);
begin
  DataType := ATypeId;

  if PinType = nil then
    PinType := TNodePinType.Create(ATypeId)
  else
  begin
    PinType.TypeId := LowerCase(Trim(ATypeId));
    if PinType.TypeId = '' then
      PinType.TypeId := 'any';

    PinType.DisplayName := PinType.TypeId;
    PinType.Flags := [];

    if SameText(PinType.TypeId, 'any') then
      Include(PinType.Flags, ptfAny);
  end;
end;

{ TNodeLink }

constructor TNodeLink.Create(AFrom, ATo: TNodePin);
begin
  inherited Create;
  Id := NewId;
  FromPin := AFrom;
  ToPin := ATo;
end;

{ TDefaultNode }

constructor TDefaultNode.Create(ATitle: string; AX, AY: single; AWidth, AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'default';
end;

procedure TDefaultNode.SetupPins;
begin
  ClearPins;
  AddInputPin('In', 'float', pkData, 45);
  AddOutputPin('Out', 'float', pkData, 45);
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
  AddOutputPin('', 'any', pkData, Height div 2);
  AddInputPin('', 'any', pkData, Height div 2);

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
  HeaderColor := $FF646464;
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

