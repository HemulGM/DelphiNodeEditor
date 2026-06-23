unit FMX.NodeEditor.Controller;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Types,
  System.UITypes, System.JSON, FMX.NodeEditor.Node, FMX.NodeEditor.Graph,
  FMX.NodeEditor.Types, FMX.NodeEditor.Selection;

type
  ENodeEditorControllerException = class(ENodeEditorException);

  TNodeEditorController = class
    FDragStartWorldPos: TPointF;
    FShowDragCoordinates: boolean;
  private
    FGraph: TNodeGraph;
    FSelection: TNodeSelectionModel;
    FOnChanged: TNotifyEvent;
    FOnSelectionChanged: TNotifyEvent;
    function NodesToJSONText(ANodes: TList<TCustomNode>): string;
    procedure PasteNodesFromJSONText(const AJSON: string; const Position: TPointF);
    procedure SetOnChanged(const Value: TNotifyEvent);
    procedure SyncNodesFlags;
    procedure SelectionChanged(Sender: TObject);
    procedure SetOnSelectionChanged(const Value: TNotifyEvent);
  protected
    procedure DoChanged; virtual;
  public
    constructor Create(AGraph: TNodeGraph);
    destructor Destroy; override;

    procedure ExecuteCommand(ACmd: TGraphCommand; Silent: Boolean = False);
    procedure Undo;
    procedure Redo;
    procedure ClearUndoRedo;
    function CanUndo: Boolean;
    function CanRedo: Boolean;

    procedure AddNode(ANode: TCustomNode; Silent: Boolean = False);
    procedure RemoveNode(ANode: TCustomNode);
    procedure AddLink(FromPin, ToPin: TNodePin);
    procedure RemoveLink(ALink: TNodeLink);
    function CanConnect(P1, P2: TNodePin): Boolean;
    procedure ReconnectLink(ALink: TNodeLink; AOldPin, ANewPin: TNodePin);
    procedure ResizeNode(ANode: TCustomNode; AOldWidth, AOldHeight, ANewWidth, ANewHeight: Integer);
    procedure MoveNodes(ANodes: TList<TCustomNode>; const AOldPositions, ANewPositions: TArray<TPointF>);
    function LinkExists(FromPin, ToPin: TNodePin): Boolean;
    procedure Clear;
    procedure FrameSelected;
    procedure AutoLayoutSelected;
    function CanConnectSelectedPins: Boolean;
    procedure SendNodeToBack(ANode: TCustomNode);
    procedure BringNodeToFront(ANode: TCustomNode);
    procedure ConnectSelectedPins;

    procedure DeleteSelection;
    procedure AlignSelectedNodes(Mode: TAlignMode);
    procedure DistributeSelectedNodes(Mode: TDistributeMode);
    procedure MakeSelectedNodesSameSize(Mode: TMatchSizeMode);
    procedure CutSelectionToClipboard;
    procedure CopySelectionToClipboard;
    procedure PasteFromClipboard(const Position: TPointF);
    function CanPaste: Boolean;
    procedure DuplicateSelection(const Position: TPointF);

    function SaveToJSONText(AZoom: Double; AOffsetX, AOffsetY: Double): string;
    procedure LoadFromJSONText(const JSON: string; var AZoom, AOffsetX, AOffsetY: Double);
    procedure SaveToFile(const AFileName: string; AZoom: Double; AOffsetX, AOffsetY: Double);
    procedure LoadFromFile(const AFileName: string; var AZoom, AOffsetX, AOffsetY: Double);

    function ValidateGraphToStrings(AStrings: TStrings): Boolean;

    function AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function RemovePinFromNode(APin: TNodePin): Boolean;

    function CreateCompatibleNodeForPin(APin: TNodePin; const Position: TPointF): TCustomNode;

    function InsertRerouteOnLink(ALink: TNodeLink; const Position: TPointF): TCustomNode;
    function AddCommentNode(const Position: TPointF): TCustomNode;

    property Graph: TNodeGraph read FGraph;
    property Selection: TNodeSelectionModel read FSelection;
    property OnChanged: TNotifyEvent read FOnChanged write SetOnChanged;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write SetOnSelectionChanged;
  end;

implementation

uses
  System.Math, FMX.Types, FMX.Clipboard, FMX.Platform, System.IOUtils,
  FMX.NodeEditor.Graph.Command;

{ TNodeEditorController }

constructor TNodeEditorController.Create(AGraph: TNodeGraph);
begin
  inherited Create;
  if AGraph = nil then
    raise ENodeEditorControllerException.Create('Graph can''t be nil');
  FGraph := AGraph;
  FSelection := TNodeSelectionModel.Create;
  FSelection.OnChanged := SelectionChanged;
end;

destructor TNodeEditorController.Destroy;
begin
  FSelection.Free;
  inherited Destroy;
end;

procedure TNodeEditorController.SelectionChanged(Sender: TObject);
begin
  SyncNodesFlags;
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self);
end;

procedure TNodeEditorController.AddNode(ANode: TCustomNode; Silent: Boolean);
begin
  if ANode = nil then
    Exit;

  ExecuteCommand(TAddNodeCommand.Create(FGraph, ANode), Silent);
end;

procedure TNodeEditorController.AlignSelectedNodes(Mode: TAlignMode);
begin
  if FSelection.NodeCount < 2 then
    Exit;

  ExecuteCommand(TAlignNodesCommand.Create(FGraph, FSelection.Nodes, Mode));
end;

procedure TNodeEditorController.BringNodeToFront(ANode: TCustomNode);
begin
  if ANode <> nil then
  begin
    var List := TList<TCustomNode>.Create;
    try
      List.Add(ANode);
      ExecuteCommand(TReorderSelectedCommand.Create(FGraph, List, True));
    finally
      List.Free;
    end;
  end
  else if FSelection.Nodes.Count > 0 then
    ExecuteCommand(TReorderSelectedCommand.Create(FGraph, FSelection.Nodes, True));
end;

procedure TNodeEditorController.SendNodeToBack(ANode: TCustomNode);
begin
  if ANode <> nil then
  begin
    var List := TList<TCustomNode>.Create;
    try
      List.Add(ANode);
      ExecuteCommand(TReorderSelectedCommand.Create(FGraph, List, False));
    finally
      List.Free;
    end;
  end
  else if FSelection.Nodes.Count > 0 then
    ExecuteCommand(TReorderSelectedCommand.Create(FGraph, FSelection.Nodes, False));
end;

procedure TNodeEditorController.DistributeSelectedNodes(Mode: TDistributeMode);
begin
  if FSelection.NodeCount < 3 then
    Exit;

  ExecuteCommand(TDistributeNodesCommand.Create(FGraph, FSelection.Nodes, Mode));
end;

procedure TNodeEditorController.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TNodeEditorController.MakeSelectedNodesSameSize(Mode: TMatchSizeMode);
begin
  if FSelection.NodeCount < 2 then
    Exit;

  ExecuteCommand(TMakeSameSizeCommand.Create(FGraph, FSelection.Nodes, Mode));
end;

procedure TNodeEditorController.SetOnChanged(const Value: TNotifyEvent);
begin
  FOnChanged := Value;
end;

procedure TNodeEditorController.SetOnSelectionChanged(const Value: TNotifyEvent);
begin
  FOnSelectionChanged := Value;
end;

procedure TNodeEditorController.RemoveNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  FSelection.RemoveNode(ANode);
  ExecuteCommand(TRemoveNodeCommand.Create(FGraph, ANode));
end;

procedure TNodeEditorController.RemoveLink(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  FSelection.RemoveLinkFromSelection(ALink);
  ExecuteCommand(TRemoveLinkCommand.Create(FGraph, ALink));
end;

procedure TNodeEditorController.Clear;
begin
  FSelection.Clear;
  FGraph.Clear;
  ClearUndoRedo;

  DoChanged;
end;

function TNodeEditorController.SaveToJSONText(AZoom: Double; AOffsetX, AOffsetY: Double): string;
begin
  var Root := TJSONObject.Create;
  try
    Root.AddPair('version', 2);
    Root.AddPair('zoom', AZoom);
    Root.AddPair('offsetX', AOffsetX);
    Root.AddPair('offsetY', AOffsetY);
    Root.AddPair('alpha', True);

    var GraphObj := FGraph.SaveGraphToJSON;
    Root.AddPair('graph', GraphObj);

    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

procedure TNodeEditorController.LoadFromJSONText(const JSON: string; var AZoom, AOffsetX, AOffsetY: Double);
begin
  AZoom := 1.0;
  AOffsetX := 0;
  AOffsetY := 0;
  Clear;

  if JSON.Trim.IsEmpty then
    Exit;

  try
    var Data := TJSONValue.ParseJSONValue(JSON);
    try
      if Data is not TJSONObject then
        raise ENodeEditorControllerException.Create(Translate('Unknown version'));

      var Version: Integer := 0;
      if not Data.TryGetValue<Integer>('version', Version) then
        raise ENodeEditorControllerException.Create(Translate('Unknown version'));

      var GraphObj := Data.GetValue<TJSONObject>('graph', nil);
      if GraphObj = nil then
        raise ENodeEditorControllerException.Create(Translate('Graph data is missing'));

      var UseAlphaColor := Data.GetValue<Boolean>('alpha', False);

      FGraph.LoadGraphFromJSON(GraphObj, UseAlphaColor);

      AZoom := Data.GetValue<Double>('zoom', 1.0);
      AOffsetX := Data.GetValue<Double>('offsetX', 0.0);
      AOffsetY := Data.GetValue<Double>('offsetY', 0.0);
    finally
      Data.Free;
    end;
  except
    on E: Exception do
      raise ENodeEditorControllerException.Create(Translate('Couldn''t load graph') + ':'#13#10 + E.Message);
  end;

  DoChanged;
end;

procedure TNodeEditorController.SaveToFile(const AFileName: string; AZoom: Double; AOffsetX, AOffsetY: Double);
begin
  TFile.WriteAllText(AFileName, SaveToJSONText(AZoom, AOffsetX, AOffsetY));
end;

function TNodeEditorController.LinkExists(FromPin, ToPin: TNodePin): Boolean;
begin
  Result := FGraph.LinkExists(FromPin, ToPin);
end;

procedure TNodeEditorController.LoadFromFile(const AFileName: string; var AZoom, AOffsetX, AOffsetY: Double);
begin
  LoadFromJSONText(TFile.ReadAllText(AFileName), AZoom, AOffsetX, AOffsetY);
end;

function TNodeEditorController.ValidateGraphToStrings(AStrings: TStrings): Boolean;
begin
  var Issues := TObjectList<TGraphValidationIssue>.Create;
  try
    Result := FGraph.ValidateGraphIssues(Issues);

    if AStrings <> nil then
    begin
      AStrings.Clear;

      if Issues.Count = 0 then
        AStrings.Add(Translate('Graph is valid.'))
      else
        for var Issue in Issues do
        begin
          var Prefix: string;
          if Issue.Kind = TGraphValidationIssueKind.Error then
            Prefix := Translate('Error') + ': '
          else
            Prefix := Translate('Warning') + ': ';

          AStrings.Add(Prefix + Issue.MessageText);
        end;
    end;
  finally
    Issues.Free;
  end;
end;

function TNodeEditorController.AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if ANode = nil then
    Exit;

  Result := FGraph.AddDynamicInputPin(ANode, AName, ADataType, AKind);

  DoChanged;
end;

procedure TNodeEditorController.AddLink(FromPin, ToPin: TNodePin);
begin
  if (FromPin = nil) or (ToPin = nil) then
    Exit;

  ExecuteCommand(TAddLinkCommand.Create(FGraph, FromPin, ToPin));

  DoChanged;
end;

function TNodeEditorController.AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if ANode = nil then
    Exit;

  Result := FGraph.AddDynamicOutputPin(ANode, AName, ADataType, AKind);

  DoChanged;
end;

function TNodeEditorController.RemovePinFromNode(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  Result := FGraph.RemoveDynamicPin(APin);

  DoChanged;
end;

procedure TNodeEditorController.MoveNodes(ANodes: TList<TCustomNode>; const AOldPositions, ANewPositions: TArray<TPointF>);
begin
  if ANodes = nil then
    Exit;

  ExecuteCommand(TMoveNodesCommand.Create(FGraph, ANodes, AOldPositions, ANewPositions));
end;

procedure TNodeEditorController.ResizeNode(ANode: TCustomNode; AOldWidth, AOldHeight, ANewWidth, ANewHeight: Integer);
begin
  if ANode = nil then
    Exit;

  ExecuteCommand(TResizeNodeCommand.Create(FGraph, ANode, AOldWidth, AOldHeight, ANewWidth, ANewHeight));
end;

function TNodeEditorController.CreateCompatibleNodeForPin(APin: TNodePin; const Position: TPointF): TCustomNode;
begin
  Result := nil;

  if APin = nil then
    Exit;

  var NeedDir: TPinDirection;
  if APin.Direction = TPinDirection.Output then
    NeedDir := TPinDirection.Input
  else
    NeedDir := TPinDirection.Output;

  if APin.OwnerNode.VisualKind = TNodeVisualKind.Reroute then
  begin
    Result := FGraph.Registry.CreateNode(APin.OwnerNode.NodeType, Position);
    Exit;
  end;

  for var It in FGraph.Registry do
  begin
    if APin.OwnerNode.VisualKind = TNodeVisualKind.Comment then
      Continue;

    var TestNode := FGraph.Registry.CreateNode(It.NodeType, Position);
    try
      if NeedDir = TPinDirection.Input then
      begin
        for var j := 0 to TestNode.InputCount - 1 do
        begin
          var TestPin := TestNode.GetInput(j);
          if FGraph.CanConnect(APin, TestPin) then
            Exit(FGraph.Registry.CreateNode(It.NodeType, Position));
        end;
      end
      else
      begin
        for var j := 0 to TestNode.OutputCount - 1 do
        begin
          var TestPin := TestNode.GetOutput(j);
          if FGraph.CanConnect(TestPin, APin) then
            Exit(FGraph.Registry.CreateNode(It.NodeType, Position));
        end;
      end;
    finally
      TestNode.Free;
    end;
  end;
end;

function TNodeEditorController.InsertRerouteOnLink(ALink: TNodeLink; const Position: TPointF): TCustomNode;
begin
  Result := nil;

  if ALink = nil then
    Exit;

  FGraph.ExecuteBegin('Insert reroute');
  try
    Result := FGraph.CreateRerouteForLink(ALink, Position);
    FGraph.ExecuteEnd;
  except
    FGraph.ExecuteCancel;
    raise;
  end;

  FSelection.SelectNode(Result, False);

  DoChanged;
end;

function TNodeEditorController.AddCommentNode(const Position: TPointF): TCustomNode;
begin
  Result := FGraph.Registry.CreateNode('comment', Position);
  if Result = nil then
    Exit;
  ExecuteCommand(TAddNodeCommand.Create(FGraph, Result));

  FSelection.SelectNode(Result, False);

  DoChanged;
end;

procedure TNodeEditorController.ExecuteCommand(ACmd: TGraphCommand; Silent: Boolean);
begin
  if ACmd = nil then
    Exit;

  FGraph.ExecuteCommand(ACmd, Silent);

  DoChanged;
end;

procedure TNodeEditorController.FrameSelected;
begin
  if (FSelection = nil) or (FSelection.NodeCount = 0) then
    Exit;

  ExecuteCommand(TFrameSelectedCommand.Create(FGraph, FSelection.Nodes));
end;

procedure TNodeEditorController.Undo;
begin
  FGraph.Undo;

  DoChanged;
end;

procedure TNodeEditorController.ReconnectLink(ALink: TNodeLink; AOldPin, ANewPin: TNodePin);
begin
  if (ALink = nil) or (AOldPin = nil) or (ANewPin = nil) or (AOldPin = ANewPin) then
    Exit;

  ExecuteCommand(TReconnectLinkCommand.Create(FGraph, ALink, AOldPin, ANewPin));
end;

procedure TNodeEditorController.AutoLayoutSelected;
begin
  if (FSelection = nil) or (FSelection.NodeCount < 2) then
    Exit;

  ExecuteCommand(TAutoLayoutSelectedCommand.Create(FGraph, FSelection.Nodes));
end;

procedure TNodeEditorController.Redo;
begin
  FGraph.Redo;
  DoChanged;
end;

procedure TNodeEditorController.ClearUndoRedo;
begin
  FGraph.ClearUndoRedo;
  DoChanged;
end;

procedure TNodeEditorController.DeleteSelection;
begin
  if (FSelection.NodeCount = 0) and (FSelection.LinkCount = 0) then
    Exit;

  if (FSelection.NodeCount = 1) and (FSelection.LinkCount = 0) then
  begin // Remove single node
    RemoveNode(FSelection.GetNode(0));
  end
  else if (FSelection.NodeCount = 0) and (FSelection.LinkCount = 1) then
  begin // Remove single link
    RemoveLink(FSelection.GetLink(0))
  end
  else
  begin // Remove batch
    FGraph.ExecuteBegin(Translate('Delete selection'));
    try
      for var i := 0 to FSelection.LinkCount - 1 do
        FGraph.RemoveLink(FSelection.GetLink(i));

      for var i := FSelection.NodeCount - 1 downto 0 do
        FGraph.RemoveNode(FSelection.GetNode(i));

      FGraph.ExecuteEnd;
    except
      FGraph.ExecuteCancel;
      raise;
    end;
    DoChanged;
  end;

  FSelection.Clear;
end;

procedure TNodeEditorController.CopySelectionToClipboard;
begin
  if FSelection.NodeCount = 0 then
    Exit;
  var Clipboard: IFMXExtendedClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, Clipboard) then
  begin
    Clipboard.SetText(NodesToJSONText(FSelection.Nodes));
  end;
end;

procedure TNodeEditorController.CutSelectionToClipboard;
begin
  if FSelection.NodeCount = 0 then
    Exit;
  var Clipboard: IFMXExtendedClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, Clipboard) then
  begin
    Clipboard.SetText(NodesToJSONText(FSelection.Nodes));
    DeleteSelection;
  end;
end;

procedure TNodeEditorController.PasteFromClipboard(const Position: TPointF);
begin
  var Clipboard: IFMXExtendedClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, Clipboard) then
  begin
    var ClipboardText := Clipboard.GetText;
    if ClipboardText.Trim.IsEmpty then
      Exit;

    FGraph.ExecuteBegin(Translate('Paste nodes'));
    try
      PasteNodesFromJSONText(ClipboardText, Position);
      FGraph.ExecuteEnd;
    except
      FGraph.ExecuteCancel;
      raise;
    end;

    DoChanged;
  end;
end;

procedure TNodeEditorController.DuplicateSelection(const Position: TPointF);
begin
  if FSelection.NodeCount = 0 then
    Exit;

  var NodeCopy := NodesToJSONText(FSelection.Nodes);
  if NodeCopy.Trim.IsEmpty then
    Exit;

  FGraph.ExecuteBegin(Translate('Duplicate selection'));
  try
    PasteNodesFromJSONText(NodeCopy, Position);
    FGraph.ExecuteEnd;
  except
    FGraph.ExecuteCancel;
    raise;
  end;

  DoChanged;
end;

function TNodeEditorController.CanConnect(P1, P2: TNodePin): Boolean;
begin
  Result := FGraph.CanConnect(P1, P2);
end;

function TNodeEditorController.CanConnectSelectedPins: Boolean;
begin
  Result := False;
  if Selection.PinCount <> 2 then
    Exit;

  var P1 := Selection.GetPin(0);
  var P2 := Selection.GetPin(1);

  if (P1 = nil) or (P2 = nil) then
    Exit;

  if not P1.CanAcceptMoreConnections then
    Exit;

  if not P2.CanAcceptMoreConnections then
    Exit;

  Result := FGraph.CanConnect(P1, P2);
end;

function TNodeEditorController.CanPaste: Boolean;
begin
  Result := False;
  var Clipboard: IFMXExtendedClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, Clipboard) then
  begin
    var ClipboardText := Clipboard.GetText;
    if ClipboardText.Trim.IsEmpty then
      Exit;
    try
      var Root := TJSONObject.ParseJSONValue(ClipboardText);
      if Assigned(Root) then
      try
        var NodesArr := Root.GetValue<TJSONArray>('nodes', nil);
        if NodesArr <> nil then
          Exit(True);
      finally
        Root.Free;
      end;
    except
      Exit;
    end;
  end;
end;

function TNodeEditorController.CanRedo: Boolean;
begin
  Result := FGraph.RedoStack.Count > 0;
end;

function TNodeEditorController.CanUndo: Boolean;
begin
  Result := FGraph.UndoStack.Count > 0;
end;

procedure TNodeEditorController.SyncNodesFlags;
begin
  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    var N := FGraph.Nodes[i];
    if N <> nil then
      N.Selected := Selection.ContainsNode(N);
    for var j := 0 to N.InputCount - 1 do
      N.GetInput(j).Highlight := False;
    for var j := 0 to N.OutputCount - 1 do
      N.GetOutput(j).Highlight := False;
  end;
  for var L in Selection.Links do
  begin
    L.FromPin.Highlight := True;
    L.ToPin.Highlight := True;
  end;
end;

procedure TNodeEditorController.ConnectSelectedPins;
begin
  if Selection.PinCount <> 2 then
    Exit;
  var P1 := Selection.GetPin(0);
  var P2 := Selection.GetPin(1);
  if (P1 = nil) or (P2 = nil) then
    Exit;

  var FromPin: TNodePin;
  var ToPin: TNodePin;
  if P1.Direction = TPinDirection.Output then
  begin
    FromPin := P1;
    ToPin := P2;
  end
  else
  begin
    FromPin := P2;
    ToPin := P1;
  end;

  if not FromPin.CanAcceptMoreConnections or not ToPin.CanAcceptMoreConnections then
    Exit;

  var Allow := True;
  //if Assigned(FOnBeforeConnectPins) then
  //  FOnBeforeConnectPins(Self, FromPin, ToPin, Allow);
  if not Allow then
    Exit;
  if not FGraph.CanConnect(FromPin, ToPin) then
    Exit;

  if not FGraph.LinkExists(FromPin, ToPin) then
    ExecuteCommand(TAddLinkCommand.Create(FGraph, FromPin, ToPin));

  //if Assigned(FOnAfterConnectPins) then
  //  FOnAfterConnectPins(Self, FromPin, ToPin);

  Selection.Clear;
end;

function TNodeEditorController.NodesToJSONText(ANodes: TList<TCustomNode>): string;
begin
  Result := '';
  if (ANodes = nil) or (ANodes.Count = 0) then
    Exit;

  var Root := TJSONObject.Create;
  try
    Root.AddPair('version', 1);
    var NodesArr := TJSONArray.Create;
    Root.AddPair('nodes', NodesArr);
    for var N in ANodes do
    begin
      var NodeObj := TJSONObject.Create;
      NodesArr.Add(NodeObj);
      N.SaveToJSON(NodeObj);
    end;

    var LinksArr := TJSONArray.Create;
    Root.AddPair('links', LinksArr);
    for var L in FGraph.Links do
    begin
      if (L.FromPin = nil) or (L.ToPin = nil) then
        Continue;

      if (ANodes.IndexOf(L.FromPin.OwnerNode) >= 0) and (ANodes.IndexOf(L.ToPin.OwnerNode) >= 0) then
      begin
        var LinkObj := TJSONObject.Create;
        LinksArr.Add(LinkObj);
        LinkObj.AddPair('id', L.Id);
        LinkObj.AddPair('fromPinId', L.FromPin.Id);
        LinkObj.AddPair('toPinId', L.ToPin.Id);
      end;
    end;
    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

procedure TNodeEditorController.PasteNodesFromJSONText(const AJSON: string; const Position: TPointF);
var
  Root: TJSONValue;
  NodesArr, LinksArr: TJSONArray;
  NodeObj, LinkObj: TJSONObject;
  OldToNewNodeIds, OldToNewPinIds: TStringList;
  i, j: integer;
  N: TCustomNode;
  NodeType, OldNodeId, NewNodeId, NewPinId: string;
  P: TNodePin;
  MinX, MinY: single;
  First: boolean;
  FromPin, ToPin: TNodePin;
  NewFromId, NewToId: string;
begin
  if AJSON.Trim.IsEmpty then
    Exit;
  Selection.BeginUpdate;
  try
    Selection.Clear;

    Root := TJSONObject.ParseJSONValue(AJSON);
    try
      NodesArr := Root.GetValue<TJSONArray>('nodes', nil);
      if NodesArr = nil then
        Exit;

      OldToNewNodeIds := TStringList.Create;
      OldToNewPinIds := TStringList.Create;
      OldToNewNodeIds.NameValueSeparator := '=';
      OldToNewPinIds.NameValueSeparator := '=';

      try
        First := True;
        MinX := 0;
        MinY := 0;
        for i := 0 to NodesArr.Count - 1 do
        begin
          NodeObj := NodesArr.Items[i] as TJSONObject;
          if First then
          begin
            MinX := NodeObj.GetValue<Single>('x', 0.0);
            MinY := NodeObj.GetValue<Single>('y', 0.0);
            First := False;
          end
          else
          begin
            MinX := Min(MinX, NodeObj.GetValue<Single>('x', 0.0));
            MinY := Min(MinY, NodeObj.GetValue<Single>('y', 0.0));
          end;
        end;

        for i := 0 to NodesArr.Count - 1 do
        begin
          NodeObj := NodesArr.Items[i] as TJSONObject;
          NodeType := NodeObj.GetValue('type', 'default');
          OldNodeId := NodeObj.GetValue('id', '');

          N := FGraph.Registry.CreateNode(NodeType, PointF(NodeObj.GetValue<Single>('x', 0.0), NodeObj.GetValue<Single>('y', 0.0)));
          N.LoadFromJSON(NodeObj, False, True);
          NewNodeId := NewId;
          N.Id := NewNodeId;
          N.X := Position.X + (N.X - MinX);
          N.Y := Position.Y + (N.Y - MinY);

          OldToNewNodeIds.Values[OldNodeId] := NewNodeId;

          for j := 0 to N.InputCount - 1 do
          begin
            P := N.GetInput(j);
            NewPinId := NewId;
            OldToNewPinIds.Values[P.Id] := NewPinId;
            P.Id := NewPinId;
          end;
          for j := 0 to N.OutputCount - 1 do
          begin
            P := N.GetOutput(j);
            NewPinId := NewId;
            OldToNewPinIds.Values[P.Id] := NewPinId;
            P.Id := NewPinId;
          end;

          N.ZOrder := 0;
          FGraph.AddNode(N);

          Selection.SelectNode(N, True);
        end;

        LinksArr := Root.GetValue<TJSONArray>('links', nil);
        if LinksArr <> nil then
        begin
          for i := 0 to LinksArr.Count - 1 do
          begin
            LinkObj := LinksArr.Items[i] as TJSONObject;
            NewFromId := OldToNewPinIds.Values[LinkObj.GetValue('fromPinId', '')];
            NewToId := OldToNewPinIds.Values[LinkObj.GetValue('toPinId', '')];
            FromPin := FGraph.FindPinById(NewFromId);
            ToPin := FGraph.FindPinById(NewToId);

            if (FromPin <> nil) and (ToPin <> nil) and FGraph.CanConnect(FromPin, ToPin) then
              FGraph.AddLink(TNodeLink.Create(FromPin, ToPin));
          end;
        end;
      finally
        OldToNewNodeIds.Free;
        OldToNewPinIds.Free;
      end;
    finally
      Root.Free;
    end;
  finally
    Selection.EndUpdate;
  end;
end;

end.

