unit FMX.NodeEditor.Controller;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Types,
  System.UITypes, System.JSON, FMX.NodeEditor.Node, FMX.NodeEditor.Node.Graph,
  FMX.NodeEditor.Types, FMX.NodeEditor.Selection;

type
  TNodeEditorController = class
    FDragStartWorldPos: TPointF;
    FShowDragCoordinates: boolean;
  private
    FGraph: TNodeGraph;
    FSelection: TNodeSelectionModel;
    function NodesToJSONText(ANodes: TObjectList<TCustomNode>): string;
    procedure PasteNodesFromJSONText(const AJSON: string; const Position: TPointF);
  public
    constructor Create(AGraph: TNodeGraph);
    destructor Destroy; override;

    procedure ExecuteCommand(ACmd: TGraphCommand);
    procedure Undo;
    procedure Redo;
    procedure ClearUndoRedo;

    procedure AddNode(ANode: TCustomNode; Silent: Boolean = False);
    procedure RemoveNode(ANode: TCustomNode);
    procedure RemoveLink(ALink: TNodeLink);
    procedure Clear;
    function CanConnectSelectedPins: Boolean;
    procedure ConnectSelectedPins;

    procedure DeleteSelection;
    procedure CutSelectionToClipboard;
    procedure CopySelectionToClipboard;
    procedure PasteFromClipboard(const Position: TPointF);
    procedure DuplicateSelection(const Position: TPointF);

    function SaveToJSONText(AZoom: Double; AOffsetX, AOffsetY: Double): string;
    procedure LoadFromJSONText(const JSON: string; out AZoom: Double; out AOffsetX, AOffsetY: Double);
    procedure SaveToFile(const AFileName: string; AZoom: Double; AOffsetX, AOffsetY: Double);
    procedure LoadFromFile(const AFileName: string; out AZoom: Double; out AOffsetX, AOffsetY: Double);

    function ValidateGraphToStrings(AStrings: TStrings): Boolean;

    function AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function RemovePinFromNode(APin: TNodePin): Boolean;

    function CreateCompatibleNodeForPin(APin: TNodePin; const Position: TPointF): TCustomNode;

    function InsertRerouteOnLink(ALink: TNodeLink; const Position: TPointF): TCustomNode;
    function AddCommentNode(const Position: TPointF): TCustomNode;

    property Graph: TNodeGraph read FGraph;
    property Selection: TNodeSelectionModel read FSelection;
  end;

implementation

uses
  System.Math, FMX.Types, FMX.Clipboard, FMX.Platform, System.IOUtils,
  FMX.NodeEditor.Node.Command;

{ TNodeEditorController }

constructor TNodeEditorController.Create(AGraph: TNodeGraph);
begin
  inherited Create;
  if AGraph = nil then
    raise Exception.Create('Graph can''t be nil');
  FGraph := AGraph;
  FSelection := TNodeSelectionModel.Create;
end;

destructor TNodeEditorController.Destroy;
begin
  FSelection.Free;
  inherited Destroy;
end;

procedure TNodeEditorController.AddNode(ANode: TCustomNode; Silent: Boolean);
begin
  if ANode = nil then
    Exit;

  FGraph.ExecuteCommand(TAddNodeCommand.Create(FGraph, ANode), Silent);
end;

procedure TNodeEditorController.RemoveNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  var BeforeJSON := FGraph.CaptureJSONText;

  FSelection.RemoveNode(ANode);
  FGraph.RemoveNode(ANode);

  var AfterJSON := FGraph.CaptureJSONText;
  FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Remove node');
end;

procedure TNodeEditorController.RemoveLink(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  FSelection.RemoveLinkFromSelection(ALink);
  FGraph.ExecuteCommand(TRemoveLinkCommand.Create(FGraph, ALink));
end;

procedure TNodeEditorController.Clear;
begin
  FSelection.Clear;
  FGraph.Clear;
end;

function TNodeEditorController.SaveToJSONText(AZoom: Double; AOffsetX, AOffsetY: Double): string;
begin
  var Root := TJSONObject.Create;
  try
    Root.AddPair('version', 2);
    Root.AddPair('zoom', AZoom);
    Root.AddPair('offsetX', AOffsetX);
    Root.AddPair('offsetY', AOffsetY);

    var GraphObj := FGraph.SaveGraphToJSON;
    Root.AddPair('graph', GraphObj);

    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

procedure TNodeEditorController.LoadFromJSONText(const JSON: string; out AZoom: Double; out AOffsetX, AOffsetY: Double);
begin
  AZoom := 1.0;
  AOffsetX := 0;
  AOffsetY := 0;
  Clear;
  ClearUndoRedo;

  if JSON.Trim.IsEmpty then
    Exit;

  try
    var Data := TJSONValue.ParseJSONValue(JSON);
    try
      if Data is not TJSONObject then
        raise Exception.Create(Translate('Unknown version'));

      var Version: Integer := 0;
      if not Data.TryGetValue<Integer>('version', Version) then
        raise Exception.Create(Translate('Unknown version'));

      var GraphObj := Data.GetValue<TJSONObject>('graph', nil);
      if GraphObj = nil then
        raise Exception.Create(Translate('Graph data is missing'));

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
      raise Exception.Create(Translate('Couldn''t load graph') + ':'#13#10 + E.Message);
  end;
end;

procedure TNodeEditorController.SaveToFile(const AFileName: string; AZoom: Double; AOffsetX, AOffsetY: Double);
begin
  TFile.WriteAllText(AFileName, SaveToJSONText(AZoom, AOffsetX, AOffsetY));
end;

procedure TNodeEditorController.LoadFromFile(const AFileName: string; out AZoom: Double; out AOffsetX, AOffsetY: Double);
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
          if Issue.Kind = gviError then
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
end;

function TNodeEditorController.AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if ANode = nil then
    Exit;

  Result := FGraph.AddDynamicOutputPin(ANode, AName, ADataType, AKind);
end;

function TNodeEditorController.RemovePinFromNode(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  Result := FGraph.RemoveDynamicPin(APin);
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

  var BeforeJSON := FGraph.CaptureJSONText;
  Result := FGraph.CreateRerouteForLink(ALink, Position);
  var AfterJSON := FGraph.CaptureJSONText;

  FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Insert reroute');

  FSelection.Clear;
  if Result <> nil then
    FSelection.SelectNode(Result, False);
end;

function TNodeEditorController.AddCommentNode(const Position: TPointF): TCustomNode;
begin
  Result := nil;

  if FGraph = nil then
    Exit;

  Result := FGraph.Registry.CreateNode('comment', Position);
  if Result <> nil then
  begin
    AddNode(Result);

    FSelection.Clear;
    FSelection.SelectNode(Result, False);
  end;
end;

procedure TNodeEditorController.ExecuteCommand(ACmd: TGraphCommand);
begin
  if ACmd = nil then
    Exit;

  FGraph.ExecuteCommand(ACmd);
end;

procedure TNodeEditorController.Undo;
begin
  FGraph.Undo;
end;

procedure TNodeEditorController.Redo;
begin
  FGraph.Redo;
end;

procedure TNodeEditorController.ClearUndoRedo;
begin
  FGraph.ClearUndoRedo;
end;

procedure TNodeEditorController.DeleteSelection;
begin
  if (FSelection.NodeCount = 0) and (FSelection.LinkCount = 0) then
    Exit;

  var BeforeJSON := FGraph.CaptureJSONText;
  var LinksToDelete := TList<TNodeLink>.Create;
  try
    for var i := 0 to FSelection.LinkCount - 1 do
    begin
      var LinkToRemove := FSelection.GetLink(i);
      if LinkToRemove <> nil then
        LinksToDelete.Add(LinkToRemove);
    end;

    for var i := LinksToDelete.Count - 1 downto 0 do
      FGraph.RemoveLink(LinksToDelete[i]);

    for var i := FSelection.NodeCount - 1 downto 0 do
    begin
      var NodeToRemove := FSelection.GetNode(i);
      if NodeToRemove <> nil then
        FGraph.RemoveNode(NodeToRemove);
    end;

    FSelection.Clear;
    var AfterJSON := FGraph.CaptureJSONText;
    FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Delete selection'));
  finally
    LinksToDelete.Free;
  end;
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

    var BeforeJSON := FGraph.CaptureJSONText;
    PasteNodesFromJSONText(ClipboardText, Position);
    var AfterJSON := FGraph.CaptureJSONText;

    FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Paste nodes'));
  end;
end;

procedure TNodeEditorController.DuplicateSelection(const Position: TPointF);
begin
  if FSelection.NodeCount = 0 then
    Exit;

  var NodeCopy := NodesToJSONText(FSelection.Nodes);
  if NodeCopy.Trim.IsEmpty then
    Exit;

  var BeforeJSON := FGraph.CaptureJSONText;
  PasteNodesFromJSONText(NodeCopy, Position);
  var AfterJSON := FGraph.CaptureJSONText;

  FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Duplicate selection'));
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

  Result := (FGraph <> nil) and FGraph.CanConnect(P1, P2);
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
    FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, FromPin, ToPin));

  //if Assigned(FOnAfterConnectPins) then
  //  FOnAfterConnectPins(Self, FromPin, ToPin);

  Selection.ClearPins;
end;

function TNodeEditorController.NodesToJSONText(ANodes: TObjectList<TCustomNode>): string;
var
  Root: TJSONObject;
  NodesArr, LinksArr: TJSONArray;
  NodeObj, LinkObj: TJSONObject;
  i: integer;
  N: TCustomNode;
  L: TNodeLink;
begin
  Result := '';
  if (ANodes = nil) or (ANodes.Count = 0) then
    Exit;

  Root := TJSONObject.Create;
  try
    Root.AddPair('version', 1);
    NodesArr := TJSONArray.Create;
    for i := 0 to ANodes.Count - 1 do
    begin
      N := ANodes[i];
      NodeObj := TJSONObject.Create;
      N.SaveToJSON(NodeObj);
      NodesArr.Add(NodeObj);
    end;
    Root.AddPair('nodes', NodesArr);

    LinksArr := TJSONArray.Create;
    for i := 0 to FGraph.Links.Count - 1 do
    begin
      L := FGraph.Links[i];
      if (L.FromPin = nil) or (L.ToPin = nil) then
        Continue;
      if (ANodes.IndexOf(L.FromPin.OwnerNode) >= 0) and
        (ANodes.IndexOf(L.ToPin.OwnerNode) >= 0)
        then
      begin
        LinkObj := TJSONObject.Create;
        LinkObj.AddPair('id', L.Id);
        LinkObj.AddPair('fromPinId', L.FromPin.Id);
        LinkObj.AddPair('toPinId', L.ToPin.Id);
        LinksArr.Add(LinkObj);
      end;
    end;
    Root.AddPair('links', LinksArr);
    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

procedure TNodeEditorController.PasteNodesFromJSONText(const AJSON: string; const Position: TPointF);
var
  Data: TJSONObject;
  Root: TJSONObject;
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

    Data := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
    try
      Root := TJSONObject(Data);
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
          N.LoadFromJSON(NodeObj, True);
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
            if (FromPin <> nil) and (ToPin <> nil) and
              FGraph.CanConnect(FromPin, ToPin) then
              FGraph.AddLink(TNodeLink.Create(FromPin, ToPin));
          end;
        end;
      finally
        OldToNewNodeIds.Free;
        OldToNewPinIds.Free;
      end;
    finally
      Data.Free;
    end;
  finally
    Selection.EndUpdate;
  end;
end;

end.

