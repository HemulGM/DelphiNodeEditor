unit FMX.NodeEditor.Node.Command;

interface

uses
  System.Classes, System.Generics.Collections, System.Generics.Defaults,
  System.Types, System.SysUtils, System.JSON, FMX.NodeEditor,
  FMX.NodeEditor.Node, FMX.NodeEditor.Types, FMX.NodeEditor.Node.Graph;

type
  TJSONSnapshotCommand = class(TGraphCommand)
  private
    FBeforeJSON: string;
    FAfterJSON: string;
  public
    constructor Create(AGraph: TNodeGraph; const ABeforeJSON, AAfterJSON: string; const ADescription: string = 'Snapshot'); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TAddNodeCommand = class(TGraphCommand)
  private
    FNode: TCustomNode;
    FOwnsNode: Boolean;
  public
    constructor Create(AGraph: TNodeGraph; ANode: TCustomNode); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TRemoveNodeCommand = class(TGraphCommand)
  private
    FNodeId: string;
    FNodeJSON: string;
    FGraphBeforeJSON: string;
    FGraphAfterJSON: string;
  public
    constructor Create(AGraph: TNodeGraph; ANode: TCustomNode); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TAddLinkCommand = class(TGraphCommand)
  private
    FFromPinId: string;
    FToPinId: string;
    FLinkId: string;
  public
    constructor Create(AGraph: TNodeGraph; AFromPin, AToPin: TNodePin); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TReconnectLinkCommand = class(TGraphCommand)
  private
    FOldPinId: string;
    FNewPinId: string;
    FLinkId: string;
    FFrom: Boolean;
  public
    constructor Create(AGraph: TNodeGraph; ALink: TNodeLink; AOldPin, ANewPin: TNodePin); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TRemoveLinkCommand = class(TGraphCommand)
  private
    FFromPinId: string;
    FToPinId: string;
    FLinkId: string;
  public
    constructor Create(AGraph: TNodeGraph; ALink: TNodeLink); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TMoveNodesCommand = class(TGraphCommand)
  private
    FNodeIds: TStringList;
    FOldX: array of single;
    FOldY: array of single;
    FNewX: array of single;
    FNewY: array of single;
  public
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; const AOldPositions, ANewPositions: TArray<TPointF>); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TResizeNodeCommand = class(TGraphCommand)
  private
    FNodeId: string;
    FOldWidth: integer;
    FOldHeight: integer;
    FNewWidth: integer;
    FNewHeight: integer;
  public
    constructor Create(AGraph: TNodeGraph; ANode: TCustomNode; AOldWidth, AOldHeight, ANewWidth, ANewHeight: integer); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TAlignNodesCommand = class(TGraphCommand)
  private
    FNodeIds: TStringList;
    FOldX: TArray<Single>;
    FOldY: TArray<Single>;
    FNewX: TArray<Single>;
    FNewY: TArray<Single>;
  public
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; Mode: TAlignMode); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TResizeNodesCommand = class(TGraphCommand)
  private
    FNodeIds: TStringList;
    FOldWidths: TArray<Integer>;
    FOldHeights: TArray<Integer>;
    FNewWidths: TArray<Integer>;
    FNewHeights: TArray<Integer>;
  public
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; const AOldW, AOldH, ANewW, ANewH: TArray<Integer>); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TDistributeNodesCommand = class(TGraphCommand)
  private
    FNodeIds: TStringList;
    FOldX: TArray<Single>;
    FOldY: TArray<Single>;
    FNewX: TArray<Single>;
    FNewY: TArray<Single>;
  public
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; Mode: TDistributeMode); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TMakeSameSizeCommand = class(TGraphCommand)
  private
    FNodeIds: TStringList;
    FOldWidths: TArray<Integer>;
    FOldHeights: TArray<Integer>;
    FNewWidths: TArray<Integer>;
    FNewHeights: TArray<Integer>;
  public
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; Mode: TMatchSizeMode); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TChangeNodePropertyCommand = class(TGraphCommand)
  private
    FNodeId: string;
    FOldJSON: string;
    FNewJSON: string;
  public
    constructor Create(AGraph: TNodeGraph; ANode: TCustomNode; const AOldNodeJSON, ANewNodeJSON: string); reintroduce;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TFrameSelectedCommand = class(TGraphCommand)
  private
    FCommentId: string;
    FCommentJSON: string;
    FSelectedNodeIds: TStringList;
  public
    constructor Create(AGraph: TNodeGraph; ASelectedNodes: TList<TCustomNode>); reintroduce;
    destructor Destroy; override;

    procedure DoExecute; override;
    procedure Undo; override;
  end;

  TAutoLayoutSelectedCommand = class(TGraphCommand)
  private
    FNodeIds: TStringList;
    FOldX, FOldY: array of single;
    FNewX, FNewY: array of single;
  public
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>); reintroduce;
    destructor Destroy; override;
    procedure DoExecute; override;
    procedure Undo; override;
  end;

implementation

uses
  FMX.Types, System.Math;

function CompareNodeByX(const A, B: TCustomNode): integer;
begin
  if A = B then
    Exit(0);
  if A = nil then
    Exit(-1);
  if B = nil then
    Exit(1);

  if A.X < B.X then
    Result := -1
  else if A.X > B.X then
    Result := 1
  else
    Result := 0;
end;

function CompareNodeByY(const A, B: TCustomNode): integer;
begin
  if A = B then
    Exit(0);
  if A = nil then
    Exit(-1);
  if B = nil then
    Exit(1);

  if A.Y < B.Y then
    Result := -1
  else if A.Y > B.Y then
    Result := 1
  else
    Result := 0;
end;

{ TJSONSnapshotCommand }

constructor TJSONSnapshotCommand.Create(AGraph: TNodeGraph; const ABeforeJSON, AAfterJSON: string; const ADescription: string);
begin
  inherited Create(AGraph, ADescription);
  FBeforeJSON := ABeforeJSON;
  FAfterJSON := AAfterJSON;
end;

procedure TJSONSnapshotCommand.DoExecute;
begin
  LoadGraphFromJSONText(FGraph, FAfterJSON, True);
end;

procedure TJSONSnapshotCommand.Undo;
begin
  LoadGraphFromJSONText(FGraph, FBeforeJSON, True);
end;

{ TAddNodeCommand }

constructor TAddNodeCommand.Create(AGraph: TNodeGraph; ANode: TCustomNode);
begin
  inherited Create(AGraph, Translate('Add node'));
  FNode := ANode;
  FOwnsNode := True;
end;

destructor TAddNodeCommand.Destroy;
begin
  if FOwnsNode and (FNode <> nil) then
    FNode.Free;

  inherited Destroy;
end;

procedure TAddNodeCommand.DoExecute;
begin
  if (FGraph = nil) or (FNode = nil) then
    Exit;

  if not FGraph.Nodes.Contains(FNode) then
  begin
    FGraph.AddNode(FNode);
    FOwnsNode := False;
  end;
end;

procedure TAddNodeCommand.Undo;
begin
  if (FGraph = nil) or (FNode = nil) then
    Exit;

  if FGraph.DetachNode(FNode) then
    FOwnsNode := True;
end;

{ TRemoveNodeCommand }

constructor TRemoveNodeCommand.Create(AGraph: TNodeGraph; ANode: TCustomNode);
begin
  inherited Create(AGraph, Translate('Remove node'));

  if ANode <> nil then
    FNodeId := ANode.Id;

  if AGraph <> nil then
  begin
    var Obj := AGraph.SaveGraphToJSON;
    try
      FGraphBeforeJSON := Obj.ToJSON;
    finally
      Obj.Free;
    end;
  end;

  FNodeJSON := '';
end;

procedure TRemoveNodeCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  if FGraphAfterJSON <> '' then
  begin
    LoadGraphFromJSONText(FGraph, FGraphAfterJSON, True);
    Exit;
  end;

  var N := FGraph.FindNodeById(FNodeId);
  if N <> nil then
    FGraph.RemoveNode(N);

  FGraphAfterJSON := FGraph.CaptureJSONText;
end;

procedure TRemoveNodeCommand.Undo;
begin
  if (FGraph = nil) or (FGraphBeforeJSON = '') then
    Exit;

  var Data := TJSONValue.ParseJSONValue(FGraphBeforeJSON);
  try
    if Data is TJSONObject then
      FGraph.LoadGraphFromJSON(TJSONObject(Data), True);
  finally
    Data.Free;
  end;
end;

constructor TResizeNodesCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; const AOldW, AOldH, ANewW, ANewH: TArray<Integer>);
begin
  inherited Create(AGraph, 'Resize nodes');

  FNodeIds := TStringList.Create;
  if ANodes = nil then
    Exit;

  SetLength(FOldWidths, ANodes.Count);
  SetLength(FOldHeights, ANodes.Count);
  SetLength(FNewWidths, ANodes.Count);
  SetLength(FNewHeights, ANodes.Count);

  for var i := 0 to ANodes.Count - 1 do
  begin
    FNodeIds.Add(ANodes[i].Id);
    FOldWidths[i] := AOldW[i];
    FOldHeights[i] := AOldH[i];
    FNewWidths[i] := ANewW[i];
    FNewHeights[i] := ANewH[i];
  end;
end;

destructor TResizeNodesCommand.Destroy;
begin
  FNodeIds.Free;
  inherited Destroy;
end;

procedure TResizeNodesCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.Width := FNewWidths[i];
      N.Height := FNewHeights[i];
    end;
  end;
end;

procedure TResizeNodesCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.Width := FOldWidths[i];
      N.Height := FOldHeights[i];
    end;
  end;
end;

{ TAlignNodesCommand }

constructor TAlignNodesCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; Mode: TAlignMode);
var
  i: integer;
  N: TCustomNode;
  MinX, MinY, MaxX, MaxY: single;
  CenterX, CenterY: single;
begin
  inherited Create(AGraph, 'Align nodes');
  FNodeIds := TStringList.Create;

  if (ANodes = nil) or (ANodes.Count < 2) then
    Exit;

  SetLength(FOldX, ANodes.Count);
  SetLength(FOldY, ANodes.Count);
  SetLength(FNewX, ANodes.Count);
  SetLength(FNewY, ANodes.Count);

  MinX := ANodes[0].X;
  MinY := ANodes[0].Y;
  MaxX := ANodes[0].X + ANodes[0].Width;
  MaxY := ANodes[0].Y + ANodes[0].Height;

  for i := 1 to ANodes.Count - 1 do
  begin
    N := ANodes[i];
    if N.X < MinX then
      MinX := N.X;
    if N.Y < MinY then
      MinY := N.Y;
    if N.X + N.Width > MaxX then
      MaxX := N.X + N.Width;
    if N.Y + N.Height > MaxY then
      MaxY := N.Y + N.Height;
  end;

  CenterX := (MinX + MaxX) * 0.5;
  CenterY := (MinY + MaxY) * 0.5;

  for i := 0 to ANodes.Count - 1 do
  begin
    N := ANodes[i];
    FNodeIds.Add(N.Id);
    FOldX[i] := N.X;
    FOldY[i] := N.Y;

    FNewX[i] := N.X;
    FNewY[i] := N.Y;

    case Mode of
      TAlignMode.Left:
        FNewX[i] := MinX;
      TAlignMode.Right:
        FNewX[i] := MaxX - N.Width;
      TAlignMode.Top:
        FNewY[i] := MinY;
      TAlignMode.Bottom:
        FNewY[i] := MaxY - N.Height;
      TAlignMode.CenterHorizontal:
        FNewX[i] := CenterX - N.Width / 2;
      TAlignMode.CenterVertical:
        FNewY[i] := CenterY - N.Height / 2;
    end;
  end;
end;

destructor TAlignNodesCommand.Destroy;
begin
  FNodeIds.Free;
  inherited Destroy;
end;

procedure TAlignNodesCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FNewX[i];
      N.Y := FNewY[i];
    end;
  end;
end;

procedure TAlignNodesCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FOldX[i];
      N.Y := FOldY[i];
    end;
  end;
end;

constructor TDistributeNodesCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; Mode: TDistributeMode);
var
  i: Integer;
  N: TCustomNode;
  Sorted: TList<TCustomNode>;
  MinCenter, MaxCenter, Step, Center: Single;
begin
  inherited Create(AGraph, 'Distribute nodes');
  FNodeIds := TStringList.Create;

  if (ANodes = nil) or (ANodes.Count < 3) then
    Exit;

  Sorted := TList<TCustomNode>.Create;
  try
    for i := 0 to ANodes.Count - 1 do
      Sorted.Add(ANodes[i]);

    if Mode = TDistributeMode.Horizontal then
      Sorted.Sort(TComparer<TCustomNode>.Construct(CompareNodeByX))
    else
      Sorted.Sort(TComparer<TCustomNode>.Construct(CompareNodeByY));

    SetLength(FOldX, Sorted.Count);
    SetLength(FOldY, Sorted.Count);
    SetLength(FNewX, Sorted.Count);
    SetLength(FNewY, Sorted.Count);

    if Mode = TDistributeMode.Horizontal then
    begin
      MinCenter := Sorted[0].X + Sorted[0].Width / 2;
      MaxCenter := Sorted[Sorted.Count - 1].X + Sorted[Sorted.Count - 1].Width / 2;
    end
    else
    begin
      MinCenter := Sorted[0].Y + Sorted[0].Height / 2;
      MaxCenter := Sorted[Sorted.Count - 1].Y + Sorted[Sorted.Count - 1].Height / 2;
    end;

    Step := (MaxCenter - MinCenter) / (Sorted.Count - 1);

    for i := 0 to Sorted.Count - 1 do
    begin
      N := Sorted[i];
      FNodeIds.Add(N.Id);
      FOldX[i] := N.X;
      FOldY[i] := N.Y;

      FNewX[i] := N.X;
      FNewY[i] := N.Y;

      Center := MinCenter + i * Step;

      if Mode = TDistributeMode.Horizontal then
        FNewX[i] := Center - N.Width / 2
      else
        FNewY[i] := Center - N.Height / 2;
    end;
  finally
    Sorted.Free;
  end;
end;

destructor TDistributeNodesCommand.Destroy;
begin
  FNodeIds.Free;
  inherited Destroy;
end;

procedure TDistributeNodesCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FNewX[i];
      N.Y := FNewY[i];
    end;
  end;
end;

procedure TDistributeNodesCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FOldX[i];
      N.Y := FOldY[i];
    end;
  end;
end;

constructor TMakeSameSizeCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; Mode: TMatchSizeMode);
begin
  inherited Create(AGraph, 'Make same size');

  FNodeIds := TStringList.Create;
  if (ANodes = nil) or (ANodes.Count < 2) then
    Exit;

  SetLength(FOldWidths, ANodes.Count);
  SetLength(FOldHeights, ANodes.Count);
  SetLength(FNewWidths, ANodes.Count);
  SetLength(FNewHeights, ANodes.Count);

  var MaxW: integer := 0;
  var MaxH: integer := 0;
  for var i := 0 to ANodes.Count - 1 do
  begin
    var N := ANodes[i];
    if N.Width > MaxW then
      MaxW := N.Width;
    if N.Height > MaxH then
      MaxH := N.Height;
  end;

  for var i := 0 to ANodes.Count - 1 do
  begin
    var N := ANodes[i];
    FNodeIds.Add(N.Id);
    FOldWidths[i] := N.Width;
    FOldHeights[i] := N.Height;

    case Mode of
      TMatchSizeMode.Width:
        begin
          FNewWidths[i] := MaxW;
          FNewHeights[i] := N.Height;
        end;
      TMatchSizeMode.Height:
        begin
          FNewWidths[i] := N.Width;
          FNewHeights[i] := MaxH;
        end;
      TMatchSizeMode.Both:
        begin
          FNewWidths[i] := MaxW;
          FNewHeights[i] := MaxH;
        end;
    end;
  end;
end;

destructor TMakeSameSizeCommand.Destroy;
begin
  FNodeIds.Free;
  inherited Destroy;
end;

procedure TMakeSameSizeCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.Width := FNewWidths[i];
      N.Height := FNewHeights[i];
    end;
  end;
end;

procedure TMakeSameSizeCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.Width := FOldWidths[i];
      N.Height := FOldHeights[i];
    end;
  end;
end;

{ TAddLinkCommand }

constructor TAddLinkCommand.Create(AGraph: TNodeGraph; AFromPin, AToPin: TNodePin);
begin
  inherited Create(AGraph, Translate('Add link'));

  if AFromPin <> nil then
    FFromPinId := AFromPin.Id;

  if AToPin <> nil then
    FToPinId := AToPin.Id;

  FLinkId := NewId;
end;

procedure TAddLinkCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  var FromPin := FGraph.FindPinById(FFromPinId);
  var ToPin := FGraph.FindPinById(FToPinId);

  if (FromPin = nil) or (ToPin = nil) then
    Exit;

  var L := TNodeLink.Create(FromPin, ToPin);
  L.Id := FLinkId;
  FGraph.AddLink(L);
end;

procedure TAddLinkCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  for var i := FGraph.Links.Count - 1 downto 0 do
  begin
    var L := FGraph.Links[i];
    if L.Id = FLinkId then
    begin
      FGraph.RemoveLink(L);
      Break;
    end;
  end;
end;

{ TReconnectLinkCommand }

constructor TReconnectLinkCommand.Create(AGraph: TNodeGraph; ALink: TNodeLink; AOldPin, ANewPin: TNodePin);
begin
  inherited Create(AGraph, Translate('Reconnect link'));

  if (AOldPin = nil) or (ANewPin = nil) then
    Exit;

  FFrom := ALink.FromPin = AOldPin;

  FOldPinId := AOldPin.Id;
  FNewPinId := ANewPin.Id;

  FLinkId := ALink.Id;
end;

procedure TReconnectLinkCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  var NewPin := FGraph.FindPinById(FNewPinId);

  if NewPin = nil then
    Exit;

  var L := FGraph.FindLinkById(FLinkId);
  if L = nil then
    Exit;

  if FFrom then
    L.FromPin := NewPin
  else
    L.ToPin := NewPin;
end;

procedure TReconnectLinkCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  var OldPin := FGraph.FindPinById(FOldPinId);

  if OldPin = nil then
    Exit;

  var L := FGraph.FindLinkById(FLinkId);
  if L = nil then
    Exit;

  if FFrom then
    L.FromPin := OldPin
  else
    L.ToPin := OldPin;
end;

{ TRemoveLinkCommand }

constructor TRemoveLinkCommand.Create(AGraph: TNodeGraph; ALink: TNodeLink);
begin
  inherited Create(AGraph, Translate('Remove link'));

  if ALink <> nil then
  begin
    FLinkId := ALink.Id;

    if ALink.FromPin <> nil then
      FFromPinId := ALink.FromPin.Id;

    if ALink.ToPin <> nil then
      FToPinId := ALink.ToPin.Id;
  end;
end;

procedure TRemoveLinkCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  for var i := FGraph.Links.Count - 1 downto 0 do
  begin
    var L := FGraph.Links[i];
    if L.Id = FLinkId then
    begin
      FGraph.RemoveLink(L);
      Break;
    end;
  end;
end;

procedure TRemoveLinkCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  var FromPin := FGraph.FindPinById(FFromPinId);
  var ToPin := FGraph.FindPinById(FToPinId);

  if (FromPin = nil) or (ToPin = nil) then
    Exit;

  var L := TNodeLink.Create(FromPin, ToPin);
  L.Id := FLinkId;
  FGraph.AddLink(L);
end;

{ TMoveNodesCommand }

constructor TMoveNodesCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; const AOldPositions, ANewPositions: TArray<TPointF>);
begin
  inherited Create(AGraph, Translate('Move nodes'));

  FNodeIds := TStringList.Create;

  if ANodes = nil then
    Exit;

  var C := ANodes.Count;

  SetLength(FOldX, C);
  SetLength(FOldY, C);
  SetLength(FNewX, C);
  SetLength(FNewY, C);

  for var i := 0 to C - 1 do
  begin
    var N := ANodes[i];
    FNodeIds.Add(N.Id);

    FOldX[i] := AOldPositions[i].x;
    FOldY[i] := AOldPositions[i].y;
    FNewX[i] := ANewPositions[i].x;
    FNewY[i] := ANewPositions[i].y;
  end;
end;

destructor TMoveNodesCommand.Destroy;
begin
  FNodeIds.Free;
  inherited Destroy;
end;

procedure TMoveNodesCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FNewX[i];
      N.Y := FNewY[i];
    end;
  end;

  FGraph.DoGraphChanged;
end;

procedure TMoveNodesCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FOldX[i];
      N.Y := FOldY[i];
    end;
  end;

  FGraph.DoGraphChanged;
end;

{ TResizeNodeCommand }

constructor TResizeNodeCommand.Create(AGraph: TNodeGraph; ANode: TCustomNode; AOldWidth, AOldHeight, ANewWidth, ANewHeight: integer);
begin
  inherited Create(AGraph, Translate('Resize node'));

  if ANode <> nil then
    FNodeId := ANode.Id;

  FOldWidth := AOldWidth;
  FOldHeight := AOldHeight;
  FNewWidth := ANewWidth;
  FNewHeight := ANewHeight;
end;

procedure TResizeNodeCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  var N := FGraph.FindNodeById(FNodeId);
  if N = nil then
    Exit;

  N.Width := FNewWidth;
  N.Height := FNewHeight;

  FGraph.DoGraphChanged;
end;

procedure TResizeNodeCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  var N := FGraph.FindNodeById(FNodeId);
  if N = nil then
    Exit;

  N.Width := FOldWidth;
  N.Height := FOldHeight;

  FGraph.DoGraphChanged;
end;

{ TChangeNodePropertyCommand }

constructor TChangeNodePropertyCommand.Create(AGraph: TNodeGraph; ANode: TCustomNode; const AOldNodeJSON, ANewNodeJSON: string);
begin
  inherited Create(AGraph, Translate('Change node property'));

  if ANode <> nil then
    FNodeId := ANode.Id;

  FOldJSON := AOldNodeJSON;
  FNewJSON := ANewNodeJSON;
end;

procedure TChangeNodePropertyCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  var N := FGraph.FindNodeById(FNodeId);
  if N = nil then
    Exit;

  var Data := TJSONValue.ParseJSONValue(FNewJSON);
  try
    if Data is TJSONObject then
      N.ApplyPropertiesFromJSON(TJSONObject(Data));
  finally
    Data.Free;
  end;

  FGraph.DoGraphChanged;
end;

procedure TChangeNodePropertyCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  var N := FGraph.FindNodeById(FNodeId);
  if N = nil then
    Exit;

  var Data := TJSONValue.ParseJSONValue(FOldJSON);
  try
    if Data is TJSONObject then
      N.ApplyPropertiesFromJSON(TJSONObject(Data));
  finally
    Data.Free;
  end;

  FGraph.DoGraphChanged;
end;

{ TFrameSelectedCommand }

constructor TFrameSelectedCommand.Create(AGraph: TNodeGraph; ASelectedNodes: TList<TCustomNode>);
var
  i: integer;
  N: TCustomNode;
  MinX, MinY, MaxX, MaxY: single;
  Comment: TCommentNode;
  Obj: TJSONObject;
begin
  inherited Create(AGraph, 'Frame selected nodes');

  FSelectedNodeIds := TStringList.Create;
  FCommentId := NewId;

  if (ASelectedNodes = nil) or (ASelectedNodes.Count = 0) then
    Exit;

  MinX := Single.MaxValue;
  MinY := Single.MaxValue;
  MaxX := Single.MinValue;
  MaxY := Single.MinValue;

  for i := 0 to ASelectedNodes.Count - 1 do
  begin
    N := ASelectedNodes[i];
    FSelectedNodeIds.Add(N.Id);

    if N.X < MinX then
      MinX := N.X;
    if N.Y < MinY then
      MinY := N.Y;
    if N.X + N.Width > MaxX then
      MaxX := N.X + N.Width;
    if N.Y + N.Height > MaxY then
      MaxY := N.Y + N.Height;
  end;

  Comment := TCommentNode.Create('Frame', MinX - 20, MinY - 40, Round(MaxX - MinX + 60), Round(MaxY - MinY + 80));
  try
    Comment.Id := FCommentId;
    Comment.CommentText := 'Frame';

    Obj := TJSONObject.Create;
    try
      Comment.SaveToJSON(Obj);
      FCommentJSON := Obj.ToJSON;
    finally
      Obj.Free;
    end;
  finally
    Comment.Free;
  end;
end;

destructor TFrameSelectedCommand.Destroy;
begin
  FSelectedNodeIds.Free;
  inherited Destroy;
end;

procedure TFrameSelectedCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;

  var Comment := FGraph.Registry.CreateNode('comment', PointF(0, 0));
  if Comment <> nil then
  begin
    Comment.Id := FCommentId;
    Comment.LoadFromJSONText(FCommentJSON, True);

    FGraph.AddNode(Comment);
  end;
end;

procedure TFrameSelectedCommand.Undo;
begin
  if FGraph = nil then
    Exit;

  var Comment := FGraph.FindNodeById(FCommentId);
  if Comment <> nil then
    FGraph.RemoveNode(Comment);
end;

{ TAutoLayoutSelectedCommand }

constructor TAutoLayoutSelectedCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>);
var
  i, Cols: integer;
  N: TCustomNode;
  BaseX, BaseY, SpacingX, SpacingY: single;
  MaxWidth, MaxHeight: single;
begin
  inherited Create(AGraph, 'Auto layout selected');

  FNodeIds := TStringList.Create;
  if (ANodes = nil) or (ANodes.Count = 0) then
    Exit;

  SetLength(FOldX, ANodes.Count);
  SetLength(FOldY, ANodes.Count);
  SetLength(FNewX, ANodes.Count);
  SetLength(FNewY, ANodes.Count);

  for i := 0 to ANodes.Count - 1 do
  begin
    N := TCustomNode(ANodes[i]);
    FNodeIds.Add(N.Id);
    FOldX[i] := N.X;
    FOldY[i] := N.Y;
  end;

  Cols := Ceil(Sqrt(ANodes.Count));
  //Rows := (ANodes.Count + Cols - 1) div Cols;

  BaseX := ANodes[0].X;
  BaseY := ANodes[0].Y;
  SpacingX := 40;
  SpacingY := 40;

  MaxWidth := 0;
  MaxHeight := 0;
  for i := 0 to ANodes.Count - 1 do
  begin
    N := TCustomNode(ANodes[i]);
    if N.Width > MaxWidth then
      MaxWidth := N.Width;
    if N.Height > MaxHeight then
      MaxHeight := N.Height;
  end;

  for i := 0 to ANodes.Count - 1 do
  begin
    FNewX[i] := BaseX + (i mod Cols) * (MaxWidth + SpacingX);
    FNewY[i] := BaseY + (i div Cols) * (MaxHeight + SpacingY);
  end;
end;

destructor TAutoLayoutSelectedCommand.Destroy;
begin
  FNodeIds.Free;
  inherited Destroy;
end;

procedure TAutoLayoutSelectedCommand.DoExecute;
begin
  if FGraph = nil then
    Exit;
  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FNewX[i];
      N.Y := FNewY[i];
    end;
  end;
end;

procedure TAutoLayoutSelectedCommand.Undo;
begin
  if FGraph = nil then
    Exit;
  for var i := 0 to FNodeIds.Count - 1 do
  begin
    var N := FGraph.FindNodeById(FNodeIds[i]);
    if N <> nil then
    begin
      N.X := FOldX[i];
      N.Y := FOldY[i];
    end;
  end;
end;

end.

