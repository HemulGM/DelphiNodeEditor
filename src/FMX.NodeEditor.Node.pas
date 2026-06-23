unit FMX.NodeEditor.Node;

interface

uses
  System.Classes, System.SysUtils, System.UITypes, System.Types, System.JSON,
  System.Math, System.Generics.Collections, System.Generics.Defaults, FMX.Types,
  FMX.Graphics, FMX.NodeEditor.Types, FMX.TextLayout, FMX.NodeEditor.VisualLink;

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
    Bitmap: IBitmapNodeObject;

    constructor Create(const AName: string = ''; AKind: TNodeValueKind = TNodeValueKind.Null);

    destructor Destroy; override;
    procedure SaveToJSON(AObj: TJSONObject);
    procedure LoadFromJSON(AObj: TJSONValue);
  end;

  TNodePin = class
  protected
    FTextLayout: TTextLayout;
    procedure CreateTextLayout(Canvas: TCanvas);
  public
    Id: string;
    Name: string;
    DisplayName: string;
    Kind: TPinKind;
    Direction: TPinDirection;
    Selected: Boolean;

    // Legacy
    DataType: string;

    PinType: TNodePinType;

    LocalY: Integer;
    OwnerNode: TCustomNode;

    IsRequired: Boolean;
    DefaultValue: string;
    Tooltip: string;
    Hidden: Boolean;
    Advanced: Boolean;
    AllowMultipleConnections: Boolean;
    SortIndex: Integer;
    Connected: Boolean;
    Highlight: Boolean;

    constructor Create(AName: string; ADir: TPinDirection; AKind: TPinKind; ALocalY: integer);
    destructor Destroy; override;
    function CanAcceptMoreConnections: Boolean;
    function EffectiveDisplayName: string; inline;
    function GetPinWorldPosition: TPointF; inline;
    procedure SetTypeId(const ATypeId: string); inline;
    procedure Paint(Canvas: TCanvas; Zoom: Double; const Center: TPointF; Radius: Single); virtual;
  end;

  TNodeLink = class
    class var
      VisualClass: TLinkVisualObjectClass;
      UseGradient: Boolean;
      DefaultColor: TAlphaColor;
      Thickness: Single;
  public
    Id: string;
    FromPin: TNodePin;
    ToPin: TNodePin;
    OnScreen: Boolean;
    constructor Create(AFrom, ATo: TNodePin);
    function HitTest(AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean; virtual;
    function IsInsideWorldRect(const R: TRectF): Boolean; virtual;
    function IsMouseNearLinkStart(SX, SY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
    function GetScreenBounds(Zoom, OffsetX, OffsetY: Double): TRectF; overload; virtual;
    function BoundsRect: TRectF; overload; virtual;
    procedure Paint(Canvas: TCanvas; Zoom: Double; OffsetX, OffsetY: Double; Selected, Hovered: Boolean; Opacity: Single); virtual;
  end;

  TCustomNode = class abstract
    class var
      DrawIcon: Boolean;
    const
      HeaderHeight = 28;
      BottomPad = 10;
      PinRadius = 8;
      ResizeEdgeSize = 16;
      RectCornerRadius = 10; //10
      ZoomDetailLimit = 0.4;
      ZoomDetailLimitExt = 0.15;
      TextFontSize = 12;
      DrawShadow = True;
  protected
    FInputs: TObjectList<TNodePin>;
    FOutputs: TObjectList<TNodePin>;
    FValues: TObjectList<TNodeValue>;
    FWidth: Integer;
    FHeight: Integer;
    FIconPath: string;
    FIconPathData: TPathData;
    FTextLayout: TTextLayout;
    FTextLayoutComment: TTextLayout;
    FNodeType: string;
  protected
    procedure SetHeight(const Value: Integer); virtual;
    procedure SetWidth(const Value: Integer); virtual;
    function GetDefaultHeaderColor: TAlphaColor; virtual;
    function GetDefaultBodyColor: TAlphaColor; virtual;
  protected
    function GetHeight: Integer; virtual;
  public
    Id: string;
    Title: string;
    X, Y: Single;
    MinWidth, MinHeight: Integer;
    HeaderColor: TAlphaColor;
    BodyColor: TAlphaColor;
    Selected: Boolean;

    VisualKind: TNodeVisualKind;
    CommentText: string;
    Hovered: Boolean;
    HoveredPinId: string;
    HoveredPinCompatible: TPinCompatible;
    // On pin hover
    Highlighted: Boolean;
    FixedSize: Boolean;

    Collapsed: Boolean;
    ZOrder: integer;
    Connected: Boolean;

    constructor Create; overload; virtual;
    constructor Create(const ATitle: string; AX, AY: Single; AWidth, AHeight: integer); overload; virtual;
    constructor Create(const ATitle: string; AX, AY: Single); overload; virtual;
    destructor Destroy; override;

    procedure SetupPins; virtual;

    procedure ClearPins;
    function AddInputPin(const AName, ADataType: string; AKind: TPinKind = TPinKind.Data; ALocalY: integer = -1): TNodePin;
    function AddOutputPin(const AName, ADataType: string; AKind: TPinKind = TPinKind.Data; ALocalY: integer = -1): TNodePin;
    function RemovePin(APin: TNodePin): Boolean; inline;
    procedure ReindexPins; inline;
    procedure AutoLayoutPins; virtual;

    function InputCount: integer;
    function OutputCount: integer;
    function GetInput(Index: integer): TNodePin;
    function GetOutput(Index: integer): TNodePin;
    function FindPinById(const AId: string): TNodePin;
    function FindPinByName(const AName: string): TNodePin;
    function OutputsIsBusy: Boolean; inline;
    function InputsIsBusy: Boolean; inline;

    function GetPinScreenPosition(APin: TNodePin; Zoom: Double; OffsetX, OffsetY: Double): TPointF; inline;
    function GetPinWorldPosition(APin: TNodePin): TPointF; inline;

    function HitTest(WX, WY: Single): Boolean; virtual;
    function ResizeHandleHitTest(WX, WY: Single; Zoom: Double; OffsetX, OffsetY: Double): Boolean; virtual;
    function GetScreenBounds(Zoom: Double; OffsetX, OffsetY: Double): TRectF; inline;
    function GetResizeHandleRect(Zoom, OffsetX, OffsetY: Double): TRectF; inline;

    procedure ClearValues;
    function AddValue(const AName: string; AKind: TNodeValueKind): TNodeValue;
    function FindValue(const AName: string): TNodeValue;
    function ValueCount: integer;
    function GetValue(Index: integer): TNodeValue;

    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;

    procedure SaveToJSON(AObj: TJSONObject); virtual;
    procedure LoadFromJSON(AObj: TJSONValue; DataOnly: Boolean; UseAlphaColor: Boolean); virtual;
  protected
    function GetPinLocalPosition(APin: TNodePin): TPoint; virtual;
    function TextHeight(Canvas: TCanvas; const AText: string): Single;
    function TextWidth(Canvas: TCanvas; const AText: string): Single;
    procedure SortPinsBySortIndex;

    function FindExistingPinForLoad(AObj: TJSONValue): TNodePin; virtual;
    function FindPinBySignature(const AName: string; ADirection: TPinDirection; AKind: TPinKind): TNodePin; virtual;
    procedure AssignPinFromJSON(APin: TNodePin; AObj: TJSONValue); virtual;
    procedure LoadPinsFromJSON(APinsArr: TJSONArray); virtual;
    procedure LoadValuesFromJSON(AValuesArr: TJSONArray); virtual;
    procedure RebindPins; virtual;
    procedure SetNodeType(const Value: string); virtual;
  private
    procedure DrawGrip(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; const AOpacity: Single = 1.0);
    procedure SetIconPath(const Value: string);
    procedure UpdateIconPath;
    procedure CreateTextLayout(Canvas: TCanvas); inline;
    procedure FillText(Canvas: TCanvas; ALayout: TTextLayout; AZoom: Double; const ARect: TRectF; const AText: string; const WordWrap: Boolean; const AOpacity: Single; const Flags: TFillTextFlags; const ATextAlign: TTextAlign; const AVTextAlign: TTextAlign = TTextAlign.Center);
    procedure DrawNodePins(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; const AOpacity: Single);
    procedure MeasureText(Canvas: TCanvas; var ARect: TRectF; const AText: string; const WordWrap: Boolean; const Flags: TFillTextFlags; const ATextAlign, AVTextAlign: TTextAlign);
  public
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double); virtual;
    property IconPath: string read FIconPath write SetIconPath;
    property NodeType: string read FNodeType write SetNodeType;
  end;

  TDefaultNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  TRerouteNode = class(TCustomNode)
  public
    function GetPinLocalPosition(APin: TNodePin): TPoint; override;
    constructor Create; override;
    procedure SetupPins; override;
    procedure AutoLayoutPins; override;
  public
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double); override;
  end;

  TCommentNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
    procedure AutoLayoutPins; override;
  public
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double); override;
  end;

function ComparePinsBySortIndex(const Item1, Item2: TNodePin): integer; inline;

function NodeOrderCompare(const Item1, Item2: TCustomNode): Integer; inline;

implementation

uses
  System.Math.Vectors, System.NetEncoding;

function ComparePinsBySortIndex(const Item1, Item2: TNodePin): integer; inline;
begin
  Result := Item1.SortIndex - Item2.SortIndex;
end;

function NodeOrderCompare(const Item1, Item2: TCustomNode): Integer; inline;
begin
  if (Item1.ZOrder < Item2.ZOrder) then
    Result := -1
  else if Item1.ZOrder > Item2.ZOrder then
    Result := 1
  else
    Result := 0;
end;

{ TCustomNode }

constructor TCustomNode.Create;
begin
  inherited;

  FTextLayout := nil;
  FTextLayoutComment := nil;

  FIconPathData := TPathData.Create;
  FInputs := TObjectList<TNodePin>.Create;
  FOutputs := TObjectList<TNodePin>.Create;
  FValues := TObjectList<TNodeValue>.Create;

  MinWidth := 40;
  MinHeight := 28;
  Id := NewId;
  NodeType := 'default';

  HeaderColor := GetDefaultHeaderColor;
  BodyColor := GetDefaultBodyColor;

  Selected := False;

  VisualKind := TNodeVisualKind.Normal;
  CommentText := '';
  Hovered := False;
  Highlighted := False;
  Collapsed := False;
  FixedSize := False;
  ZOrder := 0;
end;

constructor TCustomNode.Create(const ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  Create;

  Title := ATitle;
  X := AX;
  Y := AY;
  FWidth := AWidth;
  FHeight := AHeight;
end;

constructor TCustomNode.Create(const ATitle: string; AX, AY: Single);
begin
  Create;

  Title := ATitle;
  X := AX;
  Y := AY;
end;

destructor TCustomNode.Destroy;
begin
  Log('Destroy: ' + Id);
  ClearValues;
  ClearPins;
  FValues.Free;
  FInputs.Free;
  FOutputs.Free;
  FIconPathData.Free;
  FTextLayout.Free;
  FTextLayoutComment.Free;
  inherited Destroy;
end;

procedure TCustomNode.SortPinsBySortIndex;
begin
  FInputs.Sort(TComparer<TNodePin>.Construct(ComparePinsBySortIndex));
  FOutputs.Sort(TComparer<TNodePin>.Construct(ComparePinsBySortIndex));
end;

function TCustomNode.FindPinBySignature(const AName: string; ADirection: TPinDirection; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if ADirection = TPinDirection.Input then
    for var P in FInputs do
    begin
      if SameText(P.Name, AName) and (P.Kind = AKind) then
        Exit(P);
    end
  else
    for var P in FOutputs do
    begin
      if SameText(P.Name, AName) and (P.Kind = AKind) then
        Exit(P);
    end;
end;

function TCustomNode.FindExistingPinForLoad(AObj: TJSONValue): TNodePin;
begin
  Result := nil;

  if AObj = nil then
    Exit;

  var PinId := AObj.GetValue('id', '');
  if PinId <> '' then
  begin
    Result := FindPinById(PinId);
    if Result <> nil then
      Exit;
  end;

  var PinName := AObj.GetValue('name', '');
  var Dir := StrToPinDirection(AObj.GetValue('direction', 'input'));
  var Kind := StrToPinKind(AObj.GetValue('kind', 'data'));

  Result := FindPinBySignature(PinName, Dir, Kind);
end;

procedure TCustomNode.AssignPinFromJSON(APin: TNodePin; AObj: TJSONValue);
begin
  if (APin = nil) or (AObj = nil) then
    Exit;

  APin.Id := AObj.GetValue('id', APin.Id);
  APin.Name := AObj.GetValue('name', APin.Name);
  APin.DisplayName := AObj.GetValue('displayName', APin.DisplayName);
  //APin.Side := TPinSide(AObj.GetValue('side', Ord(APin.Side)));
  APin.LocalY := AObj.GetValue('localY', APin.LocalY);
  APin.IsRequired := AObj.GetValue('isRequired', APin.IsRequired);
  APin.DefaultValue := AObj.GetValue('defaultValue', APin.DefaultValue);
  APin.Tooltip := AObj.GetValue('tooltip', APin.Tooltip);
  APin.Hidden := AObj.GetValue('hidden', APin.Hidden);
  APin.Advanced := AObj.GetValue('advanced', APin.Advanced);
  APin.AllowMultipleConnections := AObj.GetValue('allowMultipleConnections', APin.AllowMultipleConnections);
  APin.SortIndex := AObj.GetValue('sortIndex', APin.SortIndex);

  APin.SetTypeId(AObj.GetValue('dataType', APin.DataType));

  var PinTypeObj := AObj.GetValue<TJSONObject>('pinType', nil);
  if PinTypeObj <> nil then
  begin
    if APin.PinType = nil then
      APin.PinType := TNodePinType.Create(APin.DataType);
    APin.PinType.LoadFromJSON(PinTypeObj, True);
    APin.DataType := APin.PinType.TypeId;
  end;
end;

procedure TCustomNode.LoadPinsFromJSON(APinsArr: TJSONArray);
begin
  if APinsArr = nil then
    Exit;

  for var PinObj in APinsArr do
  begin
    var P := FindExistingPinForLoad(PinObj);

    if P = nil then
    begin
      var Dir := StrToPinDirection(PinObj.GetValue('direction', 'input'));
      var Kind := StrToPinKind(PinObj.GetValue('kind', 'data'));
      var Name := PinObj.GetValue('name', '');
      var DataType := PinObj.GetValue('dataType', '');
      var LocalY := PinObj.GetValue<Integer>('localY', 40);

      if Dir = TPinDirection.Input then
        P := AddInputPin(Name, DataType, Kind, LocalY)
      else
        P := AddOutputPin(Name, DataType, Kind, LocalY);
    end;

    AssignPinFromJSON(P, PinObj);
    P.OwnerNode := Self;
  end;

  SortPinsBySortIndex;
  AutoLayoutPins;
end;

procedure TCustomNode.LoadValuesFromJSON(AValuesArr: TJSONArray);
begin
  for var Item in AValuesArr do
  begin
    var V := FindValue(Item.GetValue('name', ''));
    if V = nil then
    begin
      V := TNodeValue.Create;
      FValues.Add(V);
    end;

    V.LoadFromJSON(Item);
  end;
end;

procedure TCustomNode.RebindPins;
begin
  // Descendants can override to update
  // specific fields like FExecIn, FValueOut, etc.
end;

function TCustomNode.GetDefaultHeaderColor: TAlphaColor;
begin
  Result := $FF1D8EA7;
end;

function TCustomNode.GetHeight: Integer;
begin
  if Collapsed and (VisualKind <> TNodeVisualKind.Reroute) then
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
  if VisualKind <> TNodeVisualKind.Reroute then
    FHeight := Max(60, Max(Max(InputCount, OutputCount) * 30 + HeaderHeight + BottomPad, Value))
  else
    FHeight := Value;
  AutoLayoutPins;
end;

procedure TCustomNode.UpdateIconPath;
begin
  FIconPathData.Data := IconPath;
end;

procedure TCustomNode.SetIconPath(const Value: string);
begin
  FIconPath := Value;
  UpdateIconPath;
end;

procedure TCustomNode.SetNodeType(const Value: string);
begin
  FNodeType := Value;
end;

procedure TCustomNode.SetupPins;
begin

end;

procedure TCustomNode.SetWidth(const Value: Integer);
begin
  if FixedSize then
    Exit;
  if VisualKind <> TNodeVisualKind.Reroute then
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

  Result := TNodePin.Create(AName, TPinDirection.Input, AKind, ALocalY);
  FInputs.Add(Result);
  Result.OwnerNode := Self;
  Result.SetTypeId(ADataType);
  Result.AllowMultipleConnections := False;
  Result.SortIndex := FInputs.Count;

  ReindexPins;
  AutoLayoutPins;
end;

function TCustomNode.AddOutputPin(const AName, ADataType: string; AKind: TPinKind; ALocalY: integer): TNodePin;
begin
  if ALocalY < 0 then
    ALocalY := (HeaderHeight + 16) + FOutputs.Count * 26;

  Result := TNodePin.Create(AName, TPinDirection.Output, AKind, ALocalY);
  FOutputs.Add(Result);
  Result.OwnerNode := Self;
  Result.SetTypeId(ADataType);
  Result.AllowMultipleConnections := True;
  Result.SortIndex := FOutputs.Count;

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

  if APin.Direction = TPinDirection.Input then
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

function TCustomNode.ResizeHandleHitTest(WX, WY: Single; Zoom: Double; OffsetX, OffsetY: Double): Boolean;
begin
  Result := GetResizeHandleRect(Zoom, OffsetX, OffsetY).Contains(PointF(WX, WY));
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
  var MaxCount := Max(FInputs.Count, FOutputs.Count);
  if MaxCount <= 0 then
    Exit;

  var CntInExec := 0;
  var CntOutExec := 0;
  var Top := HeaderHeight;
  var TopData := Top;
  var ItemH := 26;

  for var i := 0 to FInputs.Count - 1 do
    if FInputs[i].Kind = TPinKind.Exec then
    begin
      FInputs[i].LocalY := Top + CntInExec * ItemH + 16;
      TopData := Max(TopData, FInputs[i].LocalY);
      Inc(CntInExec);
    end;

  for var i := 0 to FOutputs.Count - 1 do
    if FOutputs[i].Kind = TPinKind.Exec then
    begin
      FOutputs[i].LocalY := Top + CntOutExec * ItemH + 16;
      TopData := Max(TopData, FOutputs[i].LocalY);
      Inc(CntOutExec);
    end;

  var WorkH := Height - TopData - BottomPad;

  var c := 0;
  for var i := 0 to FInputs.Count - 1 do
    if FInputs[i].Kind = TPinKind.Data then
    begin
      FInputs[i].LocalY := TopData + (c + 1) * WorkH div (FInputs.Count + 1 - CntInExec);
      Inc(c);
    end;

  c := 0;
  for var i := 0 to FOutputs.Count - 1 do
    if FOutputs[i].Kind = TPinKind.Data then
    begin
      FOutputs[i].LocalY := TopData + (c + 1) * WorkH div (FOutputs.Count + 1 - CntOutExec);
      Inc(c);
    end;
end;

function TCustomNode.InputCount: integer;
begin
  Result := FInputs.Count;
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
  Result := FOutputs.Count;
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
  for var Item in FInputs do
    if Item.Id = AId then
      Exit(Item);

  for var Item in FOutputs do
    if Item.Id = AId then
      Exit(Item);

  Result := nil;
end;

function TCustomNode.FindPinByName(const AName: string): TNodePin;
begin
  for var Item in FInputs do
    if Item.Name = AName then
      Exit(Item);

  for var Item in FOutputs do
    if Item.Name = AName then
      Exit(Item);

  Result := nil;
end;

function TCustomNode.GetPinLocalPosition(APin: TNodePin): TPoint;
begin
  if APin.Direction = TPinDirection.Input then
  begin
    if Collapsed then
      Result := Point(0, HeaderHeight div 2)
    else
      Result := Point(0, APin.LocalY);
  end
  else
  begin
    if Collapsed then
      Result := Point(Width, HeaderHeight div 2)
    else
      Result := Point(Width, APin.LocalY);
  end;
end;

function TCustomNode.GetPinScreenPosition(APin: TNodePin; Zoom: Double; OffsetX, OffsetY: Double): TPointF;
begin
  if (APin = nil) or (APin.OwnerNode <> Self) then
    Exit(Point(0, 0));

  var P := GetPinLocalPosition(APin);
  Result.X := (X + P.X) * Zoom + OffsetX;
  Result.Y := (Y + P.Y) * Zoom + OffsetY;
end;

function TCustomNode.GetPinWorldPosition(APin: TNodePin): TPointF;
begin
  if (APin = nil) or (APin.OwnerNode <> Self) then
    Exit(PointF(0, 0));

  var LocalPos := GetPinLocalPosition(APin);
  Result := PointF(X + LocalPos.X, Y + LocalPos.Y);
end;

function TCustomNode.HitTest(WX, WY: Single): boolean;
var
  CX, CY, RX, RY: single;
  DX, DY: single;
  RX2, RY2: single;
  L, T, R, B: single;
begin
  if VisualKind = TNodeVisualKind.Reroute then
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

function TCustomNode.GetScreenBounds(Zoom: Double; OffsetX, OffsetY: Double): TRectF;
begin
  Result.Left := X * Zoom + OffsetX;
  Result.Top := Y * Zoom + OffsetY;
  Result.Right := Result.Left + Width * Zoom;
  Result.Bottom := Result.Top + Height * Zoom;
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

procedure TCustomNode.FillText(Canvas: TCanvas; ALayout: TTextLayout; AZoom: Double; const ARect: TRectF; const AText: string; const WordWrap: Boolean; const AOpacity: Single; const Flags: TFillTextFlags; const ATextAlign, AVTextAlign: TTextAlign);
begin        //Exit;
  if //(ALayout.TopLeft <> ARect.TopLeft) or
    not (SameValue(ALayout.MaxSize.Y, ARect.Height, TEpsilon.Position)) or
    not (SameValue(ALayout.MaxSize.X, ARect.Width, TEpsilon.Position)) or
    (ALayout.Text <> AText) or
    (ALayout.WordWrap <> WordWrap) or
    (ALayout.Opacity <> AOpacity) or
    (ALayout.HorizontalAlign <> ATextAlign) or
    (ALayout.VerticalAlign <> AVTextAlign) or
    (ALayout.Font.Size <> Canvas.Font.Size) or
    (ALayout.Color <> Canvas.Fill.Color) or
    (ALayout.RightToLeft <> (TFillTextFlag.RightToLeft in Flags))
    then
  begin
    ALayout.BeginUpdate;
    ALayout.MaxSize := PointF(ARect.Width, ARect.Height);
    ALayout.Text := AText;
    ALayout.WordWrap := WordWrap;
    ALayout.Opacity := AOpacity;
    ALayout.HorizontalAlign := ATextAlign;
    ALayout.VerticalAlign := AVTextAlign;
    ALayout.Font := Canvas.Font;
    ALayout.Color := Canvas.Fill.Color;
    ALayout.RightToLeft := TFillTextFlag.RightToLeft in Flags;
    ALayout.EndUpdate;
  end;
  ALayout.TopLeft := ARect.TopLeft;

  if AZoom < ZoomDetailLimit then
  begin
    var R := ALayout.TextRect;
    R.Inflate(0, -3 * AZoom);
    R.TopLeft := R.TopLeft.Truncate;
    R.TopLeft.Offset(0.5, 0.5);
    //AZoom  ZoomDetailLimit - 100% (0.5)  ZoomDetailLimitExt - 0% (0)
    Canvas.FillRect(R, AOpacity * EnsureRange(0.5 * (AZoom - ZoomDetailLimitExt) / (ZoomDetailLimit - ZoomDetailLimitExt), 0.0, 0.5));
  end
  else
    ALayout.RenderLayout(Canvas);
end;

function TCustomNode.TextWidth(Canvas: TCanvas; const AText: string): Single;
begin
  var R := RectF(0, 0, 10000, 20);
  MeasureText(Canvas, R, AText, False, [], TTextAlign.Leading, TTextAlign.Center);
  Result := R.Right;
end;

function TCustomNode.TextHeight(Canvas: TCanvas; const AText: string): Single;
begin
  var R := RectF(0, 0, 10000, 10000);
  MeasureText(Canvas, R, AText, False, [], TTextAlign.Leading, TTextAlign.Leading);
  Result := R.Bottom;
end;

procedure TCustomNode.MeasureText(Canvas: TCanvas; var ARect: TRectF; const AText: string; const WordWrap: Boolean; const Flags: TFillTextFlags; const ATextAlign, AVTextAlign: TTextAlign);
begin
  if AText.IsEmpty then
  begin
    ARect.Right := ARect.Left;
    ARect.Bottom := ARect.Top;
    Exit;
  end;

  FTextLayout.BeginUpdate;
  try
    FTextLayout.TopLeft := ARect.TopLeft;
    FTextLayout.MaxSize := PointF(ARect.Width, ARect.Height);
    FTextLayout.Text := AText;
    FTextLayout.WordWrap := WordWrap;
    FTextLayout.HorizontalAlign := ATextAlign;
    FTextLayout.VerticalAlign := AVTextAlign;
    FTextLayout.Font := Canvas.Font;
    FTextLayout.Color := Canvas.Fill.Color;
    FTextLayout.RightToLeft := TFillTextFlag.RightToLeft in Flags;
  finally
    FTextLayout.EndUpdate;
  end;
  ARect := FTextLayout.TextRect;
end;

procedure TCustomNode.CreateTextLayout(Canvas: TCanvas);
begin
  FTextLayout := TTextLayoutManager.TextLayoutByCanvas(Canvas.ClassType).Create(Canvas);
  FTextLayoutComment := TTextLayoutManager.TextLayoutByCanvas(Canvas.ClassType).Create(Canvas);
end;

procedure TCustomNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double);
begin
  if Zoom < 0.05 then
  begin
    // Fill Body
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := HeaderColor;
    Canvas.Stroke.Kind := TBrushKind.None;
    Canvas.FillRect(NodeBounds, 0, 0, [], 1);
    Exit;
  end;

  if FTextLayout = nil then
    CreateTextLayout(Canvas);

  var ScaledHeaderHeight := HeaderHeight * Zoom;

  var NodeHead := RectF(NodeBounds.Left, NodeBounds.Top, NodeBounds.Right, NodeBounds.Top + ScaledHeaderHeight);
  var NodeHeadText := NodeHead;
  NodeHeadText.Inflate(-10 * Zoom, 0);

  var NodeBody := RectF(NodeBounds.Left, NodeBounds.Top + ScaledHeaderHeight, NodeBounds.Right, NodeBounds.Bottom);
  var NodeBodyText := NodeBody;
  NodeBodyText.Inflate(-10 * Zoom, -10 * Zoom);

  var CornerRadius := RectCornerRadius * Zoom;
  if Zoom < ZoomDetailLimit then
    CornerRadius := 0;

  // Shadow
  if DrawShadow and (Zoom > ZoomDetailLimit) then
    DrawShadowedRect(Canvas, NodeBounds, CornerRadius, Zoom);

  // Fill Body
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := $FF1E2125;  //BodyColor
  Canvas.Stroke.Kind := TBrushKind.None;
  Canvas.FillRect(NodeBody, CornerRadius, CornerRadius, [TCorner.BottomLeft, TCorner.BottomRight], 1);

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

  if Zoom < TCustomNode.ZoomDetailLimitExt then
    Exit;

  // Head icon
  if DrawIcon and (not IconPath.IsEmpty) then
  begin
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.White;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := TAlphaColors.White;
    Canvas.Stroke.Thickness := 1 * Zoom;

    var LocalRect := NodeHeadText;
    LocalRect.Left := LocalRect.Left - 5 * Zoom;
    LocalRect.Width := LocalRect.Height;
    LocalRect.Inflate(-7 * Zoom, -7 * Zoom);
    if Zoom < ZoomDetailLimit then
    begin
      Canvas.FillEllipse(LocalRect, 0.5);
    end
    else
    begin
      FIconPathData.FitToRect(LocalRect);
      Canvas.FillPath(FIconPathData, 1);
    end;
    NodeHeadText.Left := NodeHeadText.Left + NodeHeadText.Height;
  end;

  // Head Text
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.Font.Size := TextFontSize * Zoom;
  FillText(Canvas, FTextLayout, Zoom, NodeHeadText, Title, False, 1, [], TTextAlign.Leading, TTextAlign.Center);

  // Pins
  if (not Collapsed) and (VisualKind = TNodeVisualKind.Normal) then
    DrawNodePins(Canvas, Zoom, OffsetX, OffsetY, 1);

  // Size grip
  if (Selected or Hovered) and (VisualKind <> TNodeVisualKind.Reroute) and (not Collapsed) and (not FixedSize) then
    DrawGrip(Canvas, Zoom, OffsetX, OffsetY, 1);
end;

function TCustomNode.GetResizeHandleRect(Zoom, OffsetX, OffsetY: Double): TRectF;
begin
  Result := TRectF.Empty;
  if VisualKind = TNodeVisualKind.Reroute then
    Exit;
  if FixedSize then
    Exit;

  var R := GetScreenBounds(Zoom, OffsetX, OffsetY);
  var S := ResizeEdgeSize * Zoom;
  Result := RectF(R.Right - S, R.Bottom - S, R.Right + 1, R.Bottom + 1);
end;

procedure TCustomNode.DrawGrip(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; const AOpacity: Single);
begin
  var R := GetResizeHandleRect(Zoom, OffsetX, OffsetY);
  R.Left := R.Left + R.Width / 2;
  R.Top := R.Top + R.Height / 2;
  var GripSize := Min(R.Width, R.Height);
  R.Offset(-GripSize, -GripSize);

  var Margin := GripSize * 0.18;
  var Step := GripSize * 0.28;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Cap := TStrokeCap.Round;
  Canvas.Stroke.Thickness := Max(1.5, GripSize * 0.08);
  Canvas.Stroke.Color := TAlphaColors.White;

  for var i := 0 to 2 do
  begin
    var X1 := R.Left + Margin + i * Step;
    var Y1 := R.Bottom - Margin;

    var X2 := R.Right - Margin;
    var Y2 := R.Top + Margin + i * Step;

    // Bright line
    Canvas.DrawLine(PointF(X1, Y1), PointF(X2, Y2), 0.85 * AOpacity);
  end;
end;

procedure TCustomNode.DrawNodePins(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; const AOpacity: Single);
begin
  var PinRadiusScaled := PinRadius * Zoom;
  Canvas.Font.Size := TextFontSize * Zoom;

  for var P in FInputs do
  begin
    if (P = nil) or P.Hidden then
      Continue;

    var PX := X * Zoom + OffsetX;
    var PY := (Y + P.LocalY) * Zoom + OffsetY;
    var Center := PointF(PX, PY);

    P.Paint(Canvas, Zoom, Center, PinRadiusScaled);

    // Text
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.White;

    var TextSize := PointF((Width / 2 - 5) * Zoom, 20 * Zoom);
    FillText(Canvas, P.FTextLayout, Zoom,
      RectF(
        Center.X + (PinRadius + 6) * Zoom,
        Center.Y - TextSize.Y / 2,
        Center.X + Width * Zoom / 2,
        Center.Y + TextSize.Y / 2),
      P.EffectiveDisplayName, False, AOpacity, [], TTextAlign.Leading, TTextAlign.Center);
  end;

  for var P in FOutputs do
  begin
    if (P = nil) or P.Hidden then
      Continue;

    var Center := PointF((X + Width) * Zoom + OffsetX, (Y + P.LocalY) * Zoom + OffsetY);

    P.Paint(Canvas, Zoom, Center, PinRadiusScaled);

    // Text
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.White;
    var TextSize := PointF((Width / 2 - 5) * Zoom, 20 * Zoom);
    FillText(Canvas, P.FTextLayout, Zoom, RectF(
        Center.X - TextSize.X - (PinRadius + 6) * Zoom,
        Center.Y - TextSize.Y / 2,
        Center.X - (PinRadius + 6) * Zoom,
        Center.Y + TextSize.Y / 2),
      P.EffectiveDisplayName, False, AOpacity, [], TTextAlign.Trailing, TTextAlign.Center);
  end;
end;

procedure TCustomNode.SaveToJSON(AObj: TJSONObject);
var
  PinsArr, ValuesArr: TJSONArray;
  PinObj, ValueObj, PinTypeObj: TJSONObject;
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
  AObj.AddPair('pins', PinsArr);
  for var P in FInputs do
  begin
    PinObj := TJSONObject.Create;
    PinsArr.Add(PinObj);

    PinObj.AddPair('id', P.Id);
    PinObj.AddPair('name', P.Name);
    PinObj.AddPair('displayName', P.DisplayName);
    PinObj.AddPair('kind', PinKindToStr(P.Kind));
    PinObj.AddPair('direction', PinDirectionToStr(P.Direction));
    //PinObj.AddPair('side', Ord(P.Side));
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
      PinObj.AddPair('pinType', PinTypeObj);
      P.PinType.SaveToJSON(PinTypeObj);
    end;
  end;

  for var P in FOutputs do
  begin
    PinObj := TJSONObject.Create;
    PinsArr.Add(PinObj);

    PinObj.AddPair('id', P.Id);
    PinObj.AddPair('name', P.Name);
    PinObj.AddPair('displayName', P.DisplayName);
    PinObj.AddPair('kind', PinKindToStr(P.Kind));
    PinObj.AddPair('direction', PinDirectionToStr(P.Direction));
    //PinObj.AddPair('side', Ord(P.Side));
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
      PinObj.AddPair('pinType', PinTypeObj);
      P.PinType.SaveToJSON(PinTypeObj);
    end;
  end;

  // Values
  ValuesArr := TJSONArray.Create;
  AObj.AddPair('values', ValuesArr);
  for var V in FValues do
  begin
    ValueObj := TJSONObject.Create;
    ValuesArr.Add(ValueObj);
    V.SaveToJSON(ValueObj);
  end;
end;

procedure TCustomNode.LoadFromJSON(AObj: TJSONValue; DataOnly: Boolean; UseAlphaColor: Boolean);
var
  PinsArr, ValuesArr: TJSONArray;
begin
  if AObj = nil then
    Exit;

  if not DataOnly then
  begin
    Id := AObj.GetValue('id', Id);
    NodeType := AObj.GetValue('type', NodeType);
    VisualKind := TNodeVisualKind(AObj.GetValue('visualKind', Ord(VisualKind)));
    ZOrder := AObj.GetValue('zOrder', ZOrder);
  end;

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
  Collapsed := AObj.GetValue('collapsed', Collapsed);
  CommentText := AObj.GetValue('commentText', CommentText);

  // Pins
  //ClearPins;
  if not DataOnly then
  begin
    PinsArr := AObj.GetValue<TJSONArray>('pins', nil);
    if PinsArr <> nil then
    begin
      LoadPinsFromJSON(PinsArr);
    end
    else if (InputCount = 0) and (OutputCount = 0) then
    begin
      SetupPins;
      SortPinsBySortIndex;
    end;
    RebindPins;
  end;

  // Values
  //ClearValues;
  ValuesArr := AObj.GetValue<TJSONArray>('values', nil);
  if ValuesArr <> nil then
    LoadValuesFromJSON(ValuesArr);
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
    Include(Flags, TNodePinTypeFlag.Any);
end;

function TNodePinType.IsAny: boolean;
begin
  Result := SameText(TypeId, 'any') or (TNodePinTypeFlag.Any in Flags) or (TNodePinTypeFlag.Wildcard in Flags);
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

  if (TNodePinTypeFlag.Nullable in Flags) and SameText(TypeId, AOther.TypeId) then
    Exit(True);

  if (TNodePinTypeFlag.Nullable in AOther.Flags) and SameText(TypeId, AOther.TypeId) then
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
    TNodeValueKind.Float:
      AObj.AddPair('value', FloatValue);
    TNodeValueKind.Integer:
      AObj.AddPair('value', IntegerValue);
    TNodeValueKind.string:
      AObj.AddPair('value', StringValue);
    TNodeValueKind.Boolean:
      AObj.AddPair('value', BooleanValue);
    TNodeValueKind.JSON:
      AObj.AddPair('value', JSONValue);
    TNodeValueKind.Bitmap:
      AObj.AddPair('value', BitmapToBase64(Bitmap));
  else
    AObj.AddPair('value', '');
  end;
end;

destructor TNodeValue.Destroy;
begin
  Bitmap := nil;
  inherited;
end;

procedure TNodeValue.LoadFromJSON(AObj: TJSONValue);
begin
  if AObj = nil then
    Exit;

  Name := AObj.GetValue('name', Name);
  Kind := StrToNodeValueKind(AObj.GetValue('kind', 'null'));

  case Kind of
    TNodeValueKind.Float:
      FloatValue := AObj.GetValue('value', FloatValue);
    TNodeValueKind.Integer:
      IntegerValue := AObj.GetValue('value', IntegerValue);
    TNodeValueKind.string:
      StringValue := AObj.GetValue('value', StringValue);
    TNodeValueKind.Boolean:
      BooleanValue := AObj.GetValue('value', BooleanValue);
    TNodeValueKind.JSON:
      JSONValue := AObj.GetValue('value', JSONValue);
    TNodeValueKind.Bitmap:
      Bitmap := Base64ToBitmap(AObj.GetValue('value', ''));
  end;
end;

{ TNodePin }

function TNodePin.CanAcceptMoreConnections: Boolean;
begin
  Result := (not Connected) or AllowMultipleConnections;
end;

constructor TNodePin.Create(AName: string; ADir: TPinDirection; AKind: TPinKind; ALocalY: integer);
begin
  inherited Create;

  FTextLayout := nil;

  Id := NewId;
  Name := AName;
  DisplayName := '';

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
  AllowMultipleConnections := ADir = TPinDirection.Output;
  SortIndex := 0;
end;

procedure TNodePin.CreateTextLayout(Canvas: TCanvas);
begin
  FTextLayout := TTextLayoutManager.TextLayoutByCanvas(Canvas.ClassType).Create(Canvas);
end;

destructor TNodePin.Destroy;
begin
  PinType.Free;
  FTextLayout.Free;
  inherited Destroy;
end;

function TNodePin.EffectiveDisplayName: string;
begin
  if DisplayName <> '' then
    Result := DisplayName
  else
    Result := Name;
  Result := Result + if Kind = TPinKind.Data then ': ' + DataType else '';
end;

procedure TNodePin.Paint(Canvas: TCanvas; Zoom: Double; const Center: TPointF; Radius: Single);
begin
  if FTextLayout = nil then
    CreateTextLayout(Canvas);

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := TAlphaColors.Black;
  Canvas.Stroke.Thickness := 1 * Zoom;

  if not Connected then
  begin
    if Kind = TPinKind.Exec then
      Canvas.Fill.Color := TAlphaColors.White
    else if PinType <> nil then
      Canvas.Fill.Color := PinType.Color
    else
      Canvas.Fill.Color := TAlphaColors.Green;
  end
  else
    Canvas.Fill.Color := OwnerNode.HeaderColor;

  if Id = OwnerNode.HoveredPinId then
    case OwnerNode.HoveredPinCompatible of
      TPinCompatible.Undefined:
        ;
      TPinCompatible.True:
        Canvas.Fill.Color := $FF00C251;
      TPinCompatible.False:
        Canvas.Fill.Color := $FFCF5600;
    end;

  var SRadius: Single := Radius;
  if (Id = OwnerNode.HoveredPinId) or Selected or Highlight then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := $FFFFD740;
    Canvas.Stroke.Thickness := 2 * Zoom;
    if not ((Id = OwnerNode.HoveredPinId) or Selected) then
      SRadius := SRadius * 0.8;
                {
    if Id = OwnerNode.HoveredPinId then
      case OwnerNode.HoveredPinCompatible of
        TPinCompatible.Undefined:
          ;
        TPinCompatible.True:
          Canvas.Stroke.Color := $FF00C251;
        TPinCompatible.False:
          Canvas.Stroke.Color := $FFCF5600;
      end;}
  end
  else
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := OwnerNode.HeaderColor;
    Canvas.Stroke.Thickness := 2 * Zoom;
    SRadius := SRadius * 0.8;
  end;

  // Highlight frame
  Canvas.Fill.Kind := TBrushKind.Solid;
  var RE := RectF(Center.X - SRadius, Center.Y - SRadius, Center.X + SRadius, Center.Y + SRadius);
  case Kind of
    TPinKind.Data:
      Canvas.DrawEllipse(RE, 1);
    TPinKind.Exec:
      Canvas.DrawRect(RE, 1);
  end;

  // Body
  if not Connected then
    RE.Inflate(-SRadius * 0.4, -SRadius * 0.4)
  else
    RE.Inflate(-SRadius * 0.2, -SRadius * 0.2);
  case Kind of
    TPinKind.Data:
      Canvas.FillEllipse(RE, 1);
    TPinKind.Exec:
      Canvas.FillRect(RE, 1);
  end;

  if Id = OwnerNode.HoveredPinId then
    case OwnerNode.HoveredPinCompatible of
      TPinCompatible.Undefined:
        ;
      TPinCompatible.True:
        begin
          RE.Inflate(-SRadius * 0.3, -SRadius * 0.3);
          Canvas.Fill.Color := TAlphaColors.White;
          CachePathObject.Data := 'M9.765 3.205a.75.75 0 0 1 .03 1.06l-4.25 4.5a.75.75 0 0 1-1.075.015L2.22 6.53a.75.75 0 0 1 1.06-1.06l1.705 1.704l3.72-3.939a.75.75 0 0 1 1.06-.03';
          CachePathObject.FitToRect(RE);
          Canvas.FillPath(CachePathObject, 1);
        end;
      TPinCompatible.False:
        begin
          RE.Inflate(-SRadius * 0.3, -SRadius * 0.3);
          Canvas.Fill.Color := TAlphaColors.White;
          CachePathObject.Data := 'm1.897 2.054l.073-.084a.75.75 0 0 1 .976-.073l.084.073L6 4.939l2.97-2.97a.75.75 0 1 1 1.06 1.061L7.061 6l2.97 2.97a.75.75 0 0 1 .072.976l-.073.084a.75.75 0 0 1-.976.073l-.084-.073L6 7.061l-2.97 2.97A.75.75 0 1 1 1.97 8.97L4.939 6l-2.97-2.97a.75.75 0 0 1-.072-.976l.073-.084z';
          CachePathObject.FitToRect(RE);
          Canvas.FillPath(CachePathObject, 1);
        end;
    end;

  if Highlight then
  begin
    var C := Center;
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := $FFFFD740;
    case Direction of
      TPinDirection.Input:
        begin
          C.Offset(-SRadius * 2, 0);
          Canvas.FillPolygon(BuildTriangle(C, SRadius, 0), 1);
        end;
      TPinDirection.Output:
        begin
          C.Offset(+SRadius * 2, 0);
          Canvas.FillPolygon(BuildTriangle(C, SRadius, 180), 1);
        end;
    end;
  end;
end;

function TNodePin.GetPinWorldPosition: TPointF;
begin
  if OwnerNode = nil then
    Exit(PointF(0, 0));
  Result := OwnerNode.GetPinWorldPosition(Self);
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
      Include(PinType.Flags, TNodePinTypeFlag.Any);
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

function TNodeLink.BoundsRect: TRectF;
begin
  var P0, P1, P2, P3: TPointF;
  VisualClass.GetLinkWorldPoints(1,
    FromPin.OwnerNode.GetPinWorldPosition(FromPin),
    ToPin.OwnerNode.GetPinWorldPosition(ToPin),
    P0, P1, P2, P3);

  Result := TRectF.Create(P0, P3, True);
end;

function TNodeLink.GetScreenBounds(Zoom, OffsetX, OffsetY: Double): TRectF;
begin
  //Result := WorldToScreen(BoundsRect, Zoom, OffsetX, OffsetY);
  var P0, P1, P2, P3: TPointF;
  VisualClass.GetLinkWorldPoints(1,
    FromPin.OwnerNode.GetPinWorldPosition(FromPin),
    ToPin.OwnerNode.GetPinWorldPosition(ToPin),
    P0, P1, P2, P3);

  var W0 := WorldToScreen(P0.X, P0.Y, Zoom, OffsetX, OffsetY);
  var W3 := WorldToScreen(P3.X, P3.Y, Zoom, OffsetX, OffsetY);

  Result := TRectF.Create(W0, W3, True);
end;

function TNodeLink.IsMouseNearLinkStart(SX, SY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
begin
  Result := False;

  if (FromPin = nil) or (ToPin = nil) then
    Exit;

  var MouseW := ScreenToWorld(SX, SY, Zoom, OffsetX, OffsetY);
  var P0 := FromPin.OwnerNode.GetPinWorldPosition(FromPin);
  var P1 := ToPin.OwnerNode.GetPinWorldPosition(ToPin);

  var D0 := Hypot(MouseW.X - P0.X, MouseW.Y - P0.Y);
  var D1 := Hypot(MouseW.X - P1.X, MouseW.Y - P1.Y);

  Result := D0 <= D1;
end;

function TNodeLink.IsInsideWorldRect(const R: TRectF): Boolean;
begin
  if (FromPin = nil) or (ToPin = nil) then
    Exit(False);

  if (FromPin.OwnerNode = nil) or (ToPin.OwnerNode = nil) then
    Exit(False);

  Result := VisualClass.IsLinkInsideRect(R, 1,
    FromPin.OwnerNode.GetPinWorldPosition(FromPin),
    ToPin.OwnerNode.GetPinWorldPosition(ToPin));
end;

function TNodeLink.HitTest(AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
begin
  Result := VisualClass.HitTestLink(
    FromPin.OwnerNode.GetPinWorldPosition(FromPin),
    ToPin.OwnerNode.GetPinWorldPosition(ToPin),
    AX, AY, Zoom, OffsetX, OffsetY);
end;

procedure TNodeLink.Paint(Canvas: TCanvas; Zoom, OffsetX, OffsetY: Double; Selected, Hovered: Boolean; Opacity: Single);
begin
  var P0, P1, P2, P3: TPointF;
  VisualClass.GetLinkWorldPoints(1,
    FromPin.OwnerNode.GetPinWorldPosition(FromPin),
    ToPin.OwnerNode.GetPinWorldPosition(ToPin),
    P0, P1, P2, P3);

  var W0 := WorldToScreen(P0.X, P0.Y, Zoom, OffsetX, OffsetY);
  var W1 := WorldToScreen(P1.X, P1.Y, Zoom, OffsetX, OffsetY);
  var W2 := WorldToScreen(P2.X, P2.Y, Zoom, OffsetX, OffsetY);
  var W3 := WorldToScreen(P3.X, P3.Y, Zoom, OffsetX, OffsetY);
                         {
  Canvas.DrawEllipse(TRectF.Create(W0, 4, 4), 1);
  Canvas.DrawEllipse(TRectF.Create(W1, 4, 4), 1);
  Canvas.DrawEllipse(TRectF.Create(W2, 4, 4), 1);
  Canvas.DrawEllipse(TRectF.Create(W3, 4, 4), 1); }

  var LinkOpacity := 1.0 * Opacity;
  if Hovered then
    LinkOpacity := LinkOpacity * 0.8;

  if Selected then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := $FFC97200;
    Canvas.Stroke.Thickness := Thickness * 4 * Zoom;
    VisualClass.DrawLink(Canvas, W0, W1, W2, W3, LinkOpacity * 0.5);
  end;

  // Draw gradient bezier
  if UseGradient and (Zoom > TCustomNode.ZoomDetailLimitExt) then
  begin
    // Gradient colors
    Canvas.Stroke.Kind := TBrushKind.Gradient;
    Canvas.Stroke.Gradient.Points.Clear;
    TGradientPoint(Canvas.Stroke.Gradient.Points.Add).Offset := 0;
    TGradientPoint(Canvas.Stroke.Gradient.Points.Add).Offset := 1;
    Canvas.Stroke.Gradient.Color := FromPin.OwnerNode.HeaderColor;
    Canvas.Stroke.Gradient.Color1 := ToPin.OwnerNode.HeaderColor;
    // Gradient angle
    var S0 := FromPin.OwnerNode.GetPinScreenPosition(FromPin, Zoom, OffsetX, OffsetY);
    var S1 := ToPin.OwnerNode.GetPinScreenPosition(ToPin, Zoom, OffsetX, OffsetY);
    var Start: TPointF;
    var Stop: TPointF;
    GetGradientPoints(S0, S1, Start, Stop);
    Canvas.Stroke.Gradient.StartPosition.Point := Start;
    Canvas.Stroke.Gradient.StopPosition.Point := Stop;
  end
  else // Solid
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    if DefaultColor = TAlphaColors.Null then
      Canvas.Stroke.Color := ToPin.OwnerNode.HeaderColor
    else
      Canvas.Stroke.Color := DefaultColor;
  end;
  // Line width
  Canvas.Stroke.Thickness := Thickness * Zoom;

  // Draw bezier
  VisualClass.DrawLink(Canvas, W0, W1, W2, W3, LinkOpacity);
  Canvas.Stroke.Kind := TBrushKind.Solid;
end;

{ TDefaultNode }

constructor TDefaultNode.Create;
begin
  inherited;
  NodeType := 'default';
  Width := 180;
  Height := 120;
end;

procedure TDefaultNode.SetupPins;
begin
  ClearPins;
  AddInputPin('In', 'float', TPinKind.Data, 45);
  AddOutputPin('Out', 'float', TPinKind.Data, 45);
end;

{ TRerouteNode }

function TRerouteNode.GetPinLocalPosition(APin: TNodePin): TPoint;
begin
  if APin = nil then
    Exit(Point(0, 0));

  Result := Rect(0, 0, Width, Height).CenterPoint;
end;

procedure TRerouteNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double);
begin
  if Zoom < ZoomDetailLimitExt then
    Exit;
  if FTextLayout = nil then
    CreateTextLayout(Canvas);

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

  var BodyRect := RectF(Center.X - Radius, Center.Y - Radius, Center.X + Radius, Center.Y + Radius);

  // Highlight frame
  Canvas.DrawEllipse(BodyRect, 1);

  // Body
  BodyRect.Inflate(-Radius * 0.4, -Radius * 0.4);
  Canvas.FillEllipse(BodyRect, 1);
end;

procedure TRerouteNode.AutoLayoutPins;
begin
  for var i := 0 to FInputs.Count - 1 do
    FInputs[i].LocalY := Height div 2;

  for var i := 0 to FOutputs.Count - 1 do
    FOutputs[i].LocalY := Height div 2;
end;

constructor TRerouteNode.Create;
begin
  inherited;
  MinWidth := 20;
  MinHeight := 20;
  FixedSize := True;
  FWidth := 20;
  FHeight := 20;
  NodeType := 'reroute';
  VisualKind := TNodeVisualKind.Reroute;
  Title := '';
  HeaderColor := $FF737373;
  BodyColor := $FF737373;
end;

procedure TRerouteNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('', 'any', TPinKind.Data, Height div 2);
  AddInputPin('', 'any', TPinKind.Data, Height div 2);

  if InputCount > 0 then
    GetInput(0).AllowMultipleConnections := False;

  if OutputCount > 0 then
    GetOutput(0).AllowMultipleConnections := False;
end;

{ TCommentNode }

procedure TCommentNode.AutoLayoutPins;
begin
  // do nothing
end;

constructor TCommentNode.Create;
begin
  inherited;
  NodeType := 'comment';
  VisualKind := TNodeVisualKind.Comment;
  HeaderColor := $FF646464;
  BodyColor := $FFFFFFCC;
  CommentText := '';
  Width := 320;
  Height := 200;
end;

procedure TCommentNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double);
begin
  if Zoom < 0.05 then
  begin
    // Fill Body
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := HeaderColor;
    Canvas.Stroke.Kind := TBrushKind.None;
    Canvas.FillRect(NodeBounds, 0, 0, [], 1);
    Exit;
  end;

  if FTextLayout = nil then
    CreateTextLayout(Canvas);

  var ScaledHeaderHeight := HeaderHeight * Zoom;

  var NodeHead := RectF(NodeBounds.Left, NodeBounds.Top, NodeBounds.Right, NodeBounds.Top + ScaledHeaderHeight);
  var NodeHeadText := NodeHead;
  NodeHeadText.Inflate(-10 * Zoom, 0);

  var NodeBody := RectF(NodeBounds.Left, NodeBounds.Top + ScaledHeaderHeight, NodeBounds.Right, NodeBounds.Bottom);
  var NodeBodyText := NodeBody;
  NodeBodyText.Inflate(-10 * Zoom, -10 * Zoom);

  var CornerRadius := RectCornerRadius * Zoom;
  if Zoom < ZoomDetailLimit then
    CornerRadius := 0;

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
    Canvas.Stroke.Thickness := 2 * Zoom;
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

  if Zoom < TCustomNode.ZoomDetailLimitExt then
    Exit;

  // Head icon
  if DrawIcon and (not IconPath.IsEmpty) then
  begin
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.White;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := TAlphaColors.White;
    Canvas.Stroke.Thickness := 1 * Zoom;

    var LocalRect := NodeHeadText;
    LocalRect.Left := LocalRect.Left - 5 * Zoom;
    LocalRect.Width := LocalRect.Height;
    LocalRect.Inflate(-7 * Zoom, -7 * Zoom);
    if Zoom < ZoomDetailLimit then
    begin
      Canvas.FillEllipse(LocalRect, 0.5);
    end
    else
    begin
      FIconPathData.FitToRect(LocalRect);
      Canvas.FillPath(FIconPathData, 1);
    end;
    NodeHeadText.Left := NodeHeadText.Left + NodeHeadText.Height;
  end;

  // Text Head
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.Font.Size := TextFontSize * Zoom;
  Canvas.Fill.Kind := TBrushKind.Solid;
  FillText(Canvas, FTextLayout, Zoom, NodeHeadText, Title, False, 1, [], TTextAlign.Leading, TTextAlign.Center);

  // Text Body
  if (CommentText <> '') and (not Collapsed) then
    FillText(Canvas, FTextLayoutComment, Zoom, NodeBodyText, CommentText, True, 1, [], TTextAlign.Leading, TTextAlign.Leading);

  // Size grip
  if (Selected or Hovered) and (VisualKind <> TNodeVisualKind.Reroute) and (not Collapsed) and (not FixedSize) then
    DrawGrip(Canvas, Zoom, OffsetX, OffsetY, 1);
end;

procedure TCommentNode.SetupPins;
begin
  ClearPins;
end;

initialization
  TNodeLink.UseGradient := True;
  TNodeLink.VisualClass := TLinkVisualBezier;
  TNodeLink.Thickness := 3;
  TNodeLink.DefaultColor := TAlphaColors.Null;

  TCustomNode.DrawIcon := False;

end.

