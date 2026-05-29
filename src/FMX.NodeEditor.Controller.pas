unit FMX.NodeEditor.Controller;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Types,
  System.UITypes, System.JSON, FMX.NodeEditor.Node, FMX.NodeEditor.Node.Graph,
  FMX.NodeEditor.Types, FMX.NodeEditor.Selection;

type
  TNodeClipboardService = class
  public
    function NodesToJSONText(ANodes: TObjectList<TCustomNode>; AGraph: TNodeGraph): string;
    procedure PasteNodesFromJSONText(const AJSON: string; AGraph: TNodeGraph; AX, AY: single; ASelection: TNodeSelectionModel);
  end;

  TNodeEditorController = class
    FDragStartWorldPos: TPointF;
    FShowDragCoordinates: boolean;
  private
    FGraph: TNodeGraph;
    FSelection: TNodeSelectionModel;
    FPinSelection: TPinSelectionModel;
    FClipboard: TNodeClipboardService;
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

    procedure DeleteSelection;
    procedure CopySelectionToClipboard;
    procedure PasteFromClipboard(AX, AY: Single);
    procedure DuplicateSelection(AX, AY: Single);

    function SaveToJSONText(AZoom: Double; AOffsetX, AOffsetY: Double): string;
    procedure LoadFromJSONText(const JSON: string; out AZoom: Double; out AOffsetX, AOffsetY: Double);
    procedure SaveToFile(const AFileName: string; AZoom: Double; AOffsetX, AOffsetY: Double);
    procedure LoadFromFile(const AFileName: string; out AZoom: Double; out AOffsetX, AOffsetY: Double);

    function ValidateGraphToStrings(AStrings: TStrings): Boolean;

    function AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = pkData): TNodePin;
    function AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = pkData): TNodePin;
    function RemovePinFromNode(APin: TNodePin): Boolean;

    function CreateCompatibleNodeForPin(APin: TNodePin; AX, AY: Single): TCustomNode;

    function InsertRerouteOnLink(ALink: TNodeLink; AX, AY: Single): TCustomNode;
    function AddCommentNode(AX, AY: Single): TCustomNode;

    property Graph: TNodeGraph read FGraph;
    property Selection: TNodeSelectionModel read FSelection;
    property PinSelection: TPinSelectionModel read FPinSelection;
    property ClipboardService: TNodeClipboardService read FClipboard;
  end;

implementation

uses
  System.Math, FMX.Types, FMX.Clipboard, FMX.Platform, System.IOUtils,
  FMX.NodeEditor.Node.Command;

{ TNodeEditorController }

constructor TNodeEditorController.Create(AGraph: TNodeGraph);
begin
  inherited Create;
  FGraph := AGraph;
  FSelection := TNodeSelectionModel.Create;
  FPinSelection := TPinSelectionModel.Create;
  FClipboard := TNodeClipboardService.Create;
end;

destructor TNodeEditorController.Destroy;
begin
  FClipboard.Free;
  FSelection.Free;
  FPinSelection.Free;
  inherited Destroy;
end;

procedure TNodeEditorController.AddNode(ANode: TCustomNode; Silent: Boolean);
begin
  if (FGraph = nil) or (ANode = nil) then
    Exit;

  FGraph.ExecuteCommand(TAddNodeCommand.Create(FGraph, ANode), Silent);
end;

procedure TNodeEditorController.RemoveNode(ANode: TCustomNode);
begin
  if (FGraph = nil) or (ANode = nil) then
    Exit;

  var BeforeJSON := FGraph.CaptureJSONText;

  FSelection.RemoveNode(ANode);
  FGraph.RemoveNode(ANode);

  var AfterJSON := FGraph.CaptureJSONText;
  FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Remove node');
end;

procedure TNodeEditorController.RemoveLink(ALink: TNodeLink);
begin
  if (FGraph = nil) or (ALink = nil) then
    Exit;

  FSelection.RemoveLinkFromSelection(ALink);
  FGraph.ExecuteCommand(TRemoveLinkCommand.Create(FGraph, ALink));
end;

procedure TNodeEditorController.Clear;
begin
  if FGraph = nil then
    Exit;

  FGraph.Clear;
  FSelection.Clear;
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

  if (FGraph = nil) or (JSON.Trim.IsEmpty) then
    Exit;

  var Data := TJSONValue.ParseJSONValue(JSON) as TJSONObject;
  try
    var UseAlphaColor := Data.GetValue<Boolean>('alpha', False);
    AZoom := Data.GetValue<Double>('zoom', 1.0);
    AOffsetX := Data.GetValue<Double>('offsetX', 0.0);
    AOffsetY := Data.GetValue<Double>('offsetY', 0.0);

    var GraphObj := Data.GetValue<TJSONObject>('graph', nil);
    if GraphObj <> nil then
    begin
      var BeforeJSON := FGraph.CaptureJSONText;
      FGraph.LoadGraphFromJSON(GraphObj, UseAlphaColor);
      var AfterJSON := FGraph.CaptureJSONText;

      FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Load graph'));
    end;

    FSelection.Clear;
  finally
    Data.Free;
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

  if (FGraph = nil) or (ANode = nil) then
    Exit;

  Result := FGraph.AddDynamicInputPin(ANode, AName, ADataType, AKind);
end;

function TNodeEditorController.AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if (FGraph = nil) or (ANode = nil) then
    Exit;

  Result := FGraph.AddDynamicOutputPin(ANode, AName, ADataType, AKind);
end;

function TNodeEditorController.RemovePinFromNode(APin: TNodePin): boolean;
begin
  Result := False;

  if (FGraph = nil) or (APin = nil) then
    Exit;

  Result := FGraph.RemoveDynamicPin(APin);
end;

function TNodeEditorController.CreateCompatibleNodeForPin(APin: TNodePin; AX, AY: single): TCustomNode;
begin
  Result := nil;

  if APin = nil then
    Exit;

  var NeedDir: TPinDirection;
  if APin.Direction = pdOutput then
    NeedDir := pdInput
  else
    NeedDir := pdOutput;

  if APin.OwnerNode.VisualKind = TNodeVisualKind.nvReroute then
  begin
    Result := FGraph.Registry.CreateNode(APin.OwnerNode.NodeType, AX, AY);
    Exit;
  end;

  for var It in FGraph.Registry do
  begin
    if APin.OwnerNode.VisualKind = TNodeVisualKind.nvComment then
      Continue;

    var TestNode := FGraph.Registry.CreateNode(It.NodeType, AX, AY);
    try
      if NeedDir = pdInput then
      begin
        for var j := 0 to TestNode.InputCount - 1 do
        begin
          var TestPin := TestNode.GetInput(j);
          if FGraph.CanConnect(APin, TestPin) then
            Exit(FGraph.Registry.CreateNode(It.NodeType, AX, AY));
        end;
      end
      else
      begin
        for var j := 0 to TestNode.OutputCount - 1 do
        begin
          var TestPin := TestNode.GetOutput(j);
          if FGraph.CanConnect(TestPin, APin) then
            Exit(FGraph.Registry.CreateNode(It.NodeType, AX, AY));
        end;
      end;
    finally
      TestNode.Free;
    end;
  end;
end;

function TNodeEditorController.InsertRerouteOnLink(ALink: TNodeLink; AX, AY: single): TCustomNode;
begin
  Result := nil;

  if (FGraph = nil) or (ALink = nil) then
    Exit;

  var BeforeJSON := FGraph.CaptureJSONText;
  Result := FGraph.CreateRerouteForLink(ALink, AX, AY);
  var AfterJSON := FGraph.CaptureJSONText;

  FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Insert reroute');

  FSelection.Clear;
  if Result <> nil then
    FSelection.SelectNode(Result, False);
end;

function TNodeEditorController.AddCommentNode(AX, AY: single): TCustomNode;
begin
  Result := nil;

  if FGraph = nil then
    Exit;

  Result := FGraph.Registry.CreateNode('comment', AX, AY);
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

  if FGraph = nil then
  begin
    ACmd.Free;
    Exit;
  end;

  FGraph.ExecuteCommand(ACmd);
end;

procedure TNodeEditorController.Undo;
begin
  if FGraph <> nil then
    FGraph.Undo;
end;

procedure TNodeEditorController.Redo;
begin
  if FGraph <> nil then
    FGraph.Redo;
end;

procedure TNodeEditorController.ClearUndoRedo;
begin
  if FGraph <> nil then
    FGraph.ClearUndoRedo;
end;

procedure TNodeEditorController.DeleteSelection;
var
  i: integer;
  BeforeJSON, AfterJSON: string;
  NodeToRemove: TCustomNode;
  LinkToRemove: TNodeLink;
  LinksToDelete: TObjectList<TNodeLink>;
begin
  if FGraph = nil then
    Exit;

  if (FSelection.NodeCount = 0) and (FSelection.LinkCount = 0) then
    Exit;

  BeforeJSON := FGraph.CaptureJSONText;
  LinksToDelete := TObjectList<TNodeLink>.Create(False);
  try
    for i := 0 to FSelection.LinkCount - 1 do
    begin
      LinkToRemove := FSelection.GetLink(i);
      if LinkToRemove <> nil then
        LinksToDelete.Add(LinkToRemove);
    end;

    for i := LinksToDelete.Count - 1 downto 0 do
      FGraph.RemoveLink(LinksToDelete[i]);

    for i := FSelection.NodeCount - 1 downto 0 do
    begin
      NodeToRemove := FSelection.GetNode(i);
      if NodeToRemove <> nil then
        FGraph.RemoveNode(NodeToRemove);
    end;

    FSelection.Clear;
    AfterJSON := FGraph.CaptureJSONText;
    FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Delete selection'));
  finally
    LinksToDelete.Free;
  end;
end;

procedure TNodeEditorController.CopySelectionToClipboard;
begin
  if (FGraph = nil) or (FSelection.NodeCount = 0) then
    Exit;
  var Clipboard: IFMXExtendedClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, Clipboard) then
  begin
    Clipboard.SetText(FClipboard.NodesToJSONText(FSelection.Nodes, FGraph));
  end;
end;

procedure TNodeEditorController.PasteFromClipboard(AX, AY: single);
begin
  if FGraph = nil then
    Exit;

  var Clipboard: IFMXExtendedClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, Clipboard) then
  begin
    if Trim(Clipboard.GetText) = '' then
      Exit;

    var BeforeJSON := FGraph.CaptureJSONText;
    FClipboard.PasteNodesFromJSONText(Clipboard.GetText, FGraph, AX, AY, FSelection);
    var AfterJSON := FGraph.CaptureJSONText;

    FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Paste nodes'));
  end;
end;

procedure TNodeEditorController.DuplicateSelection(AX, AY: single);
begin
  if (FGraph = nil) or (FSelection.NodeCount = 0) then
    Exit;

  var NodeCopy := FClipboard.NodesToJSONText(FSelection.Nodes, FGraph);
  if NodeCopy.Trim.IsEmpty then
    Exit;

  var BeforeJSON := FGraph.CaptureJSONText;
  FClipboard.PasteNodesFromJSONText(NodeCopy, FGraph, AX, AY, FSelection);
  var AfterJSON := FGraph.CaptureJSONText;

  FGraph.ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, Translate('Duplicate selection'));
end;

{ TNodeClipboardService }

function TNodeClipboardService.NodesToJSONText(ANodes: TObjectList<TCustomNode>; AGraph: TNodeGraph): string;
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
    for i := 0 to AGraph.Links.Count - 1 do
    begin
      L := AGraph.Links[i];
      if (L.FromPin = nil) or (L.ToPin = nil) then
        Continue;
      if (ANodes.IndexOf(L.FromPin.OwnerNode) >= 0) and
        (ANodes.IndexOf(L.ToPin.OwnerNode) >= 0) then
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

procedure TNodeClipboardService.PasteNodesFromJSONText(const AJSON: string; AGraph: TNodeGraph; AX, AY: single; ASelection: TNodeSelectionModel);
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
  if Trim(AJSON) = '' then
    Exit;

  if ASelection <> nil then
    ASelection.Clear;

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

        N := AGraph.Registry.CreateNode(NodeType, NodeObj.GetValue<Single>('x', 0.0), NodeObj.GetValue<Single>('y', 0.0));
        N.LoadFromJSON(NodeObj, True);
        NewNodeId := NewId;
        N.Id := NewNodeId;
        N.X := AX + (N.X - MinX);
        N.Y := AY + (N.Y - MinY);

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

        AGraph.AddNode(N);
        if ASelection <> nil then
          ASelection.SelectNode(N, True);
      end;

      LinksArr := Root.GetValue<TJSONArray>('links', nil);
      if LinksArr <> nil then
      begin
        for i := 0 to LinksArr.Count - 1 do
        begin
          LinkObj := LinksArr.Items[i] as TJSONObject;
          NewFromId := OldToNewPinIds.Values[LinkObj.GetValue('fromPinId', '')];
          NewToId := OldToNewPinIds.Values[LinkObj.GetValue('toPinId', '')];
          FromPin := AGraph.FindPinById(NewFromId);
          ToPin := AGraph.FindPinById(NewToId);
          if (FromPin <> nil) and (ToPin <> nil) and
            AGraph.CanConnect(FromPin, ToPin) then
            AGraph.AddLink(TNodeLink.Create(FromPin, ToPin));
        end;
      end;
    finally
      OldToNewNodeIds.Free;
      OldToNewPinIds.Free;
    end;
  finally
    Data.Free;
  end;
end;

end.

