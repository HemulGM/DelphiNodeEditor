unit FMX.NodeEditor.Node.Command;

interface

uses
  System.Classes, System.Generics.Collections, System.Types, System.SysUtils,
  System.JSON, FMX.NodeEditor, FMX.NodeEditor.Node, FMX.NodeEditor.Node.Graph;

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
    FOwnsNode: boolean;
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
    constructor Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; const AOldPositions, ANewPositions: array of TPointF); reintroduce;
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

implementation

uses
  FMX.NodeEditor.Types;

{ TJSONSnapshotCommand }

constructor TJSONSnapshotCommand.Create(AGraph: TNodeGraph; const ABeforeJSON, AAfterJSON: string; const ADescription: string);
begin
  inherited Create(AGraph, ADescription);
  FBeforeJSON := ABeforeJSON;
  FAfterJSON := AAfterJSON;
end;

procedure TJSONSnapshotCommand.DoExecute;
begin
  LoadGraphFromJSONText(FGraph, FAfterJSON);
end;

procedure TJSONSnapshotCommand.Undo;
begin
  LoadGraphFromJSONText(FGraph, FBeforeJSON);
end;

{ TAddNodeCommand }

constructor TAddNodeCommand.Create(AGraph: TNodeGraph; ANode: TCustomNode);
begin
  inherited Create(AGraph, 'Add node');
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

  if FGraph.Nodes.IndexOf(FNode) < 0 then
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
  inherited Create(AGraph, 'Remove node');

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
var
  N: TCustomNode;
begin
  if FGraph = nil then
    Exit;

  if FGraphAfterJSON <> '' then
  begin
    LoadGraphFromJSONText(FGraph, FGraphAfterJSON);
    Exit;
  end;

  N := FGraph.FindNodeById(FNodeId);
  if N <> nil then
    FGraph.RemoveNode(N);

  FGraphAfterJSON := FGraph.CaptureJSONText;
end;

procedure TRemoveNodeCommand.Undo;
var
  Data: TJSONValue;
begin
  if (FGraph = nil) or (FGraphBeforeJSON = '') then
    Exit;

  Data := TJSONValue.ParseJSONValue(FGraphBeforeJSON);
  try
    if Data is TJSONObject then
      FGraph.LoadGraphFromJSON(TJSONObject(Data));
  finally
    Data.Free;
  end;
end;

{ TAddLinkCommand }

constructor TAddLinkCommand.Create(AGraph: TNodeGraph; AFromPin, AToPin: TNodePin);
begin
  inherited Create(AGraph, 'Add link');

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

{ TRemoveLinkCommand }

constructor TRemoveLinkCommand.Create(AGraph: TNodeGraph; ALink: TNodeLink);
begin
  inherited Create(AGraph, 'Remove link');

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

constructor TMoveNodesCommand.Create(AGraph: TNodeGraph; ANodes: TList<TCustomNode>; const AOldPositions, ANewPositions: array of TPointF);
begin
  inherited Create(AGraph, 'Move nodes');

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
    var N := TCustomNode(ANodes[i]);
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
  inherited Create(AGraph, 'Resize node');

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
  inherited Create(AGraph, 'Change node property');

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
      ApplyNodePropertiesFromJSON(N, TJSONObject(Data));
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
      ApplyNodePropertiesFromJSON(N, TJSONObject(Data));
  finally
    Data.Free;
  end;

  FGraph.DoGraphChanged;
end;

end.

