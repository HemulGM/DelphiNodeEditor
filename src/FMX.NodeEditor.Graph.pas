unit FMX.NodeEditor.Graph;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.UITypes,
  System.Types, System.JSON, FMX.NodeEditor.Node, FMX.NodeEditor.Types,
  FMX.NodeEditor.DAG;

type
  ENodeEditorGraphException = class(ENodeEditorException);

  TNodeGraph = class;

  TNodeDAG = TObjectDAG<TCustomNode>;

  TGraphNodeEvent = procedure(Sender: TObject; ANode: TCustomNode) of object;

  TGraphLinkEvent = procedure(Sender: TObject; ALink: TNodeLink) of object;

  TGraphChangedEvent = procedure(Sender: TObject) of object;

  TGraphCommand = class
  protected
    FId: string;
    FGraph: TNodeGraph;
    FDescription: string;
    FTimeStamp: TDateTime;
  public
    constructor Create(AGraph: TNodeGraph; const ADescription: string = ''); reintroduce; virtual;
    destructor Destroy; override;

    procedure DoExecute; virtual; abstract;
    procedure Undo; virtual; abstract;

    property Description: string read FDescription;
    property TimeStamp: TDateTime read FTimeStamp;
    property Id: string read FId;
  end;

  TGraphValidationIssue = class
  public
    Kind: TGraphValidationIssueKind;
    MessageText: string;
    Node: TCustomNode;
    Link: TNodeLink;
  end;

  TNodeDefinition = class
  public
    NodeType: string;
    Caption: string;
    Category: string;
    Description: string;
    Tags: TStringList;
    NodeClass: TCustomNodeClass;
    Version: integer;
    Hidden: boolean;
    IsDeprecated: boolean;
    Color: TAlphaColor;
    IconPath: string;

    constructor Create;
    destructor Destroy; override;

    function MatchesFilter(const AFilter: string): boolean;
  end;

  TNodeRegistryItem = TNodeDefinition;

  TNodeRegistry = class(TObjectList<TNodeRegistryItem>)
  public
    constructor Create; reintroduce;
    procedure RegisterNode(const ANodeType, ACaption: string; AClass: TCustomNodeClass);
    procedure RegisterNodeEx(const ANodeType, ACaption, ACategory, ADescription, ATags, AIconPath: string; AClass: TCustomNodeClass; AColor: TAlphaColor = TAlphaColors.Null; AHidden: boolean = False; ADeprecated: boolean = False; AVersion: integer = 1);
    function CreateNode(const ANodeType: string; const Position: TPointF): TCustomNode;
    function FindItem(const ANodeType: string): TNodeRegistryItem;
    procedure SortByCategory;
  end;

  TNodeGraph = class
    class var
      UndoLimit: Integer;
  private
    FNodes: TNodeDAG;
    FLinks: TObjectList<TNodeLink>;
    FRegistry: TNodeRegistry;
    FUndoStack: TObjectList<TGraphCommand>;
    FRedoStack: TObjectList<TGraphCommand>;
    FUndoLock: boolean;
    FUpdateLock: Integer;
    FExecutingCommand: boolean;
    FOnNodeAdded: TGraphNodeEvent;
    FOnNodeRemoved: TGraphNodeEvent;
    FOnLinkAdded: TGraphLinkEvent;
    FOnLinkRemoved: TGraphLinkEvent;
    FOnGraphChanged: TGraphChangedEvent;
    FCommandBeforeJson: string;
    FCommandDescription: string;

    procedure RemoveLinksToInput(APin: TNodePin);
    procedure TruncateUndo; inline;

  protected
    function PinHasIncomingLink(APin: TNodePin): boolean;
    function PinHasOutgoingLink(APin: TNodePin): boolean;
    procedure PushExecutedCommand(ACommand: TGraphCommand; Silent: Boolean = False);

    function HasLinksBetweenNodes(ANodeA, ANodeB: TCustomNode): boolean;
    class function CompareNodeById(const A, B: TCustomNode): integer; static;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure AddNode(ANode: TCustomNode; SkipChecking: Boolean = False);
    function DetachNode(ANode: TCustomNode): boolean;
    procedure RemoveNode(ANode: TCustomNode);
    procedure AddLink(ALink: TNodeLink; SkipChecking: Boolean = False);
    procedure RemoveLink(ALink: TNodeLink);

    function CheckInvariants(AErrors: TStrings = nil): boolean;
    function IsNodeIdUnique(const AId: string; AExcept: TCustomNode = nil): boolean;
    function IsPinIdUnique(const AId: string; AExcept: TNodePin = nil): boolean;

    function TopologicalSortDataNodes(AList: TList<TCustomNode>): integer;
    function AddDynamicInputPin(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function AddDynamicOutputPin(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function RemoveDynamicPin(APin: TNodePin): boolean;
    procedure DoGraphChanged;

    function FindNodeById(const AId: string): TCustomNode;
    function FindPinById(const AId: string): TNodePin;
    function FindLinkById(const AId: string): TNodeLink;
    function CanConnect(P1, P2: TNodePin): Boolean;
    function LinkExists(FromPin, ToPin: TNodePin): Boolean;

    procedure Clear;
    procedure Undo;
    procedure Redo;

    function SaveGraphToJSON: TJSONObject;
    procedure LoadGraphFromJSON(AObj: TJSONObject; UseAlphaColor: Boolean);

    function ValidateGraph: boolean;
    function ValidateGraphIssues(AIssues: TObjectList<TGraphValidationIssue>): boolean;
    function HasCycle: boolean;
    function CreateRerouteForLink(ALink: TNodeLink; const Position: TPointF): TCustomNode;
    function GetCompatibleNodesForPin(APin: TNodePin): TStringList;

    procedure ExecuteCommand(ACommand: TGraphCommand; Silent: Boolean = False);
    procedure ExecuteJSONSnapshotCommand(const ABeforeJSON, AAfterJSON, ADescription: string);
    procedure ExecuteBegin(const ADescription: string);
    procedure ExecuteEnd;
    procedure ExecuteCancel;
    procedure ClearUndoRedo;
    function CaptureJSONText: string;

    function NextZOrder: integer;
    procedure BringNodeToFront(ANodes: TList<TCustomNode>);
    procedure SendNodeToBack(ANodes: TList<TCustomNode>);

    property Nodes: TNodeDAG read FNodes;
    property Links: TObjectList<TNodeLink> read FLinks;
    property Registry: TNodeRegistry read FRegistry;
    property OnNodeAdded: TGraphNodeEvent read FOnNodeAdded write FOnNodeAdded;
    property OnNodeRemoved: TGraphNodeEvent read FOnNodeRemoved write FOnNodeRemoved;
    property OnLinkAdded: TGraphLinkEvent read FOnLinkAdded write FOnLinkAdded;
    property OnLinkRemoved: TGraphLinkEvent read FOnLinkRemoved write FOnLinkRemoved;
    property OnGraphChanged: TGraphChangedEvent read FOnGraphChanged write FOnGraphChanged;
    property UndoStack: TObjectList<TGraphCommand> read FUndoStack;
    property RedoStack: TObjectList<TGraphCommand> read FRedoStack;
  end;

procedure LoadGraphFromJSONText(AGraph: TNodeGraph; const S: string; UseAlphaColor: Boolean);

implementation

uses
  System.Math, FMX.NodeEditor.Node.Defaults, FMX.Types,
  FMX.NodeEditor.Graph.Command, System.Generics.Defaults;

procedure LoadGraphFromJSONText(AGraph: TNodeGraph; const S: string; UseAlphaColor: Boolean);
begin
  if AGraph = nil then
    Exit;

  if S.Trim.IsEmpty then
    Exit;

  var Data := TJSONValue.ParseJSONValue(S);
  try
    if Data is TJSONObject then
      AGraph.LoadGraphFromJSON(TJSONObject(Data), UseAlphaColor);
  finally
    Data.Free;
  end;
end;

{ TGraphCommand }

constructor TGraphCommand.Create(AGraph: TNodeGraph; const ADescription: string);
begin
  inherited Create;
  FId := NewId;
  FGraph := AGraph;
  FTimeStamp := Now;
  FDescription := ADescription;
end;

destructor TGraphCommand.Destroy;
begin
  inherited Destroy;
end;

{ TNodeGraph }

constructor TNodeGraph.Create;
begin
  inherited Create;
  FNodes := TNodeDAG.Create(True);
  FLinks := TObjectList<TNodeLink>.Create;
  FRegistry := TNodeRegistry.Create;
  FUndoStack := TObjectList<TGraphCommand>.Create;
  FRedoStack := TObjectList<TGraphCommand>.Create;
                    {
  FRegistry.RegisterNodeEx('default', 'Default Node', 'Basic',
    'Generic test node.', 'default,test',
    'M5.73 15.885h12.54v-1H5.73zm0-3.385h12.54v-1H5.73zm0-3.384h8.77v-1H5.73zM4.616 19q-.69 0-1.153-.462T3 17.384V6.616q0-.691.463-1.153T4.615 5h14.77q.69 0 1.152.463T21 6.616v10.769q0 .69-.463 1.153T19.385 19zm0-1h14.77q.23 0 .423-.192t.192-.424V6.616q0-.231-.192-.424T19.385 6H4.615q-.23 0-.423.192T4 6.616v10.769q0 .23.192.423t.423.192M4 18V6z',
    TDefaultNode, $FF1D8EA7);    }

  FRegistry.RegisterNodeEx('reroute', 'Reroute', 'Utility',
    'Reroute connection wire.', 'reroute,wire',
    'M5 12c0 3.859 3.14 7 7 7s7-3.141 7-7s-3.141-7-7-7s-7 3.141-7 7m12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5s2.243-5 5-5s5 2.243 5 5',
    TRerouteNode, $FF646464);

  FRegistry.RegisterNodeEx('reroute_data', 'Reroute Data', 'Utility',
    'Reroute connection wire.', 'reroute,wire',
    'M5 12c0 3.859 3.14 7 7 7s7-3.141 7-7s-3.141-7-7-7s-7 3.141-7 7m12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5s2.243-5 5-5s5 2.243 5 5',
    TRerouteDataNode, $FF646464);

  FRegistry.RegisterNodeEx('reroute_exec', 'Reroute Exec', 'Utility',
    'Reroute connection wire.', 'reroute,wire',
    'M5 12c0 3.859 3.14 7 7 7s7-3.141 7-7s-3.141-7-7-7s-7 3.141-7 7m12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5s2.243-5 5-5s5 2.243 5 5',
    TRerouteExecNode, $FF646464);

  FRegistry.RegisterNodeEx('comment', 'Comment / Frame', 'Utility',
    'Visual comment frame.', 'comment,frame,group',
    'M5.73 15.885h12.54v-1H5.73zm0-3.385h12.54v-1H5.73zm0-3.384h8.77v-1H5.73zM4.616 19q-.69 0-1.153-.462T3 17.384V6.616q0-.691.463-1.153T4.615 5h14.77q.69 0 1.152.463T21 6.616v10.769q0 .69-.463 1.153T19.385 19zm0-1h14.77q.23 0 .423-.192t.192-.424V6.616q0-.231-.192-.424T19.385 6H4.615q-.23 0-.423.192T4 6.616v10.769q0 .23.192.423t.423.192M4 18V6z',
    TCommentNode, $FF646464);
end;

destructor TNodeGraph.Destroy;
begin
  Clear;
  FUndoStack.Free;
  FRedoStack.Free;
  FRegistry.Free;
  FLinks.Free;
  FNodes.Free;
  inherited Destroy;
end;

procedure TNodeGraph.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TNodeGraph.EndUpdate;
begin
  if FUpdateLock > 0 then
    Dec(FUpdateLock);

  if FUpdateLock = 0 then
    DoGraphChanged;
end;

procedure TNodeGraph.AddNode(ANode: TCustomNode; SkipChecking: Boolean = False);
begin
  if ANode = nil then
    Exit;

  if SkipChecking then
    if FNodes.Contains(ANode) then
      Exit;

  if ANode.ZOrder = 0 then
    ANode.ZOrder := NextZOrder;

  FNodes.Add(ANode);

  if Assigned(FOnNodeAdded) then
    FOnNodeAdded(Self, ANode);

  DoGraphChanged;
end;

function TNodeGraph.DetachNode(ANode: TCustomNode): boolean;
begin
  Result := False;

  if ANode = nil then
    Exit;

  if not FNodes.Contains(ANode) then
    Exit;

  for var i := FLinks.Count - 1 downto 0 do
  begin
    var L := FLinks[i];

    if (((L.FromPin <> nil) and (L.FromPin.OwnerNode = ANode)) or
      ((L.ToPin <> nil) and (L.ToPin.OwnerNode = ANode))) then
    begin
      if Assigned(FOnLinkRemoved) then
        FOnLinkRemoved(Self, L);

      FLinks.Delete(i);
    end;
  end;

  if Assigned(FOnNodeRemoved) then
    FOnNodeRemoved(Self, ANode);

  FNodes.Extract(ANode);

  Result := True;
  DoGraphChanged;
end;

procedure TNodeGraph.RemoveNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  for var i := FLinks.Count - 1 downto 0 do
  begin
    var L := FLinks[i];

    if (((L.FromPin <> nil) and (L.FromPin.OwnerNode = ANode)) or
      ((L.ToPin <> nil) and (L.ToPin.OwnerNode = ANode))) then
    begin
      if Assigned(FOnLinkRemoved) then
        FOnLinkRemoved(Self, L);
      FLinks.Delete(i);
    end;
  end;

  if FNodes.Contains(ANode) then
  begin
    if Assigned(FOnNodeRemoved) then
      FOnNodeRemoved(Self, ANode);
    FNodes.Remove(ANode);
    DoGraphChanged;
  end;
end;

procedure TNodeGraph.AddLink(ALink: TNodeLink; SkipChecking: Boolean);
var
  OutPin, InPin: TNodePin;
  OutNode, InNode: TCustomNode;
begin
  if ALink = nil then
    Exit;

  if (ALink.FromPin = nil) or (ALink.ToPin = nil) then
  begin
    ALink.Free;
    Exit;
  end;

  if not CanConnect(ALink.FromPin, ALink.ToPin) then
  begin
    ALink.Free;
    Exit;
  end;

  if ALink.FromPin.Direction = TPinDirection.Output then
  begin
    OutPin := ALink.FromPin;
    InPin := ALink.ToPin;
  end
  else
  begin
    OutPin := ALink.ToPin;
    InPin := ALink.FromPin;
  end;

  ALink.FromPin := OutPin;
  ALink.ToPin := InPin;

  OutNode := OutPin.OwnerNode;
  InNode := InPin.OwnerNode;

  if not SkipChecking then
    if LinkExists(OutPin, InPin) then
    begin
      ALink.Free;
      Exit;
    end;

  if not InPin.AllowMultipleConnections then
    RemoveLinksToInput(InPin);

  if not SkipChecking then
  begin
    if FNodes.Contains(OutNode) and FNodes.Contains(InNode) then
    begin
      if not FNodes.HasEdge(OutNode, InNode) then
      begin
        if FNodes.CanCreateCycle(OutNode, InNode) then
        begin
          ALink.Free;
          Exit;
        end;
        FNodes.AddEdge(OutNode, InNode);
      end;
    end;
  end
  else
    FNodes.AddEdge(OutNode, InNode, True);

  FLinks.Add(ALink);

  if Assigned(FOnLinkAdded) then
    FOnLinkAdded(Self, ALink);

  DoGraphChanged;
end;

procedure TNodeGraph.RemoveLink(ALink: TNodeLink);
var
  NFrom, NTo: TCustomNode;
begin
  if ALink = nil then
    Exit;

  NFrom := nil;
  NTo := nil;

  if FLinks.Remove(ALink) <= 0 then
    Exit;

  if Assigned(FOnLinkRemoved) then
    FOnLinkRemoved(Self, ALink);

  if (ALink.FromPin <> nil) and (ALink.FromPin.OwnerNode <> nil) then
    NFrom := ALink.FromPin.OwnerNode;

  if (ALink.ToPin <> nil) and (ALink.ToPin.OwnerNode <> nil) then
    NTo := ALink.ToPin.OwnerNode;

  if (NFrom <> nil) and (NTo <> nil) then
    if not HasLinksBetweenNodes(NFrom, NTo) then
      FNodes.RemoveEdge(NFrom, NTo);

  DoGraphChanged;
end;

function TNodeGraph.HasLinksBetweenNodes(ANodeA, ANodeB: TCustomNode): boolean;
begin
  Result := False;
  if (ANodeA = nil) or (ANodeB = nil) then
    Exit;

  for var i := 0 to FLinks.Count - 1 do
  begin
    var L := FLinks[i];
    if (L.FromPin = nil) or (L.ToPin = nil) then
      Continue;

    var OwnerA := L.FromPin.OwnerNode;
    var OwnerB := L.ToPin.OwnerNode;

    if (OwnerA = ANodeA) and (OwnerB = ANodeB) then
      Exit(True);
  end;
end;

class function TNodeGraph.CompareNodeById(const A, B: TCustomNode): integer;
begin
  if A = B then
    Exit(0);
  if A = nil then
    Exit(-1);
  if B = nil then
    Exit(1);
  Result := CompareText(A.Id, B.Id);
end;

function TNodeGraph.CheckInvariants(AErrors: TStrings): boolean;

  procedure AddError(const S: string);
  begin
    Result := False;
    if AErrors <> nil then
      AErrors.Add(S);
  end;

var
  i, j: integer;
  N: TCustomNode;
  P: TNodePin;
  L: TNodeLink;
  NodeIds: TStringList;
  PinIds: TStringList;
begin
  Result := True;

  if AErrors <> nil then
    AErrors.Clear;

  NodeIds := TStringList.Create;
  PinIds := TStringList.Create;
  try
    NodeIds.CaseSensitive := False;
    PinIds.CaseSensitive := False;

    for i := 0 to FNodes.Count - 1 do
    begin
      N := FNodes[i];

      if N = nil then
      begin
        AddError(Translate('Node list contains nil node.'));
        Continue;
      end;

      if N.Id = '' then
        AddError(Format(Translate('Node "%s" has empty Id.'), [N.Title]));

      if NodeIds.IndexOf(N.Id) >= 0 then
        AddError(Format(Translate('Duplicate node Id: %s'), [N.Id]))
      else
        NodeIds.Add(N.Id);

      for j := 0 to N.InputCount - 1 do
      begin
        P := N.GetInput(j);

        if P = nil then
        begin
          AddError(Format(Translate('Node "%s" contains nil input pin.'), [N.Title]));
          Continue;
        end;

        if P.OwnerNode <> N then
          AddError(Format(Translate('Input pin "%s" has invalid OwnerNode.'), [P.Name]));

        if P.Direction <> TPinDirection.Input then
          AddError(Format(Translate('Pin "%s" in input list has non-input direction.'), [P.Name]));

        if P.SortIndex <> j then
          AddError(Format(Translate('Input pin "%s" has invalid SortIndex.'), [P.Name]));

        if P.Id = '' then
          AddError(Format(Translate('Input pin "%s" has empty Id.'), [P.Name]));

        if PinIds.IndexOf(P.Id) >= 0 then
          AddError(Format(Translate('Duplicate pin Id: %s'), [P.Id]))
        else
          PinIds.Add(P.Id);
      end;

      for j := 0 to N.OutputCount - 1 do
      begin
        P := N.GetOutput(j);

        if P = nil then
        begin
          AddError('Node "' + N.Title + '" contains nil output pin.');
          Continue;
        end;

        if P.OwnerNode <> N then
          AddError('Output pin "' + P.Name + '" has invalid OwnerNode.');

        if P.Direction <> TPinDirection.Output then
          AddError('Pin "' + P.Name + '" in output list has non-output direction.');

        if P.SortIndex <> j then
          AddError('Output pin "' + P.Name + '" has invalid SortIndex.');

        if P.Id = '' then
          AddError('Output pin "' + P.Name + '" has empty Id.');

        if PinIds.IndexOf(P.Id) >= 0 then
          AddError('Duplicate pin Id: ' + P.Id)
        else
          PinIds.Add(P.Id);
      end;
    end;

    for i := 0 to FLinks.Count - 1 do
    begin
      L := FLinks[i];

      if L = nil then
      begin
        AddError('Link list contains nil link.');
        Continue;
      end;

      if L.FromPin = nil then
        AddError('Link has nil FromPin.');

      if L.ToPin = nil then
        AddError('Link has nil ToPin.');

      if (L.FromPin <> nil) and (L.FromPin.Direction <> TPinDirection.Output) then
        AddError('Link FromPin is not output.');

      if (L.ToPin <> nil) and (L.ToPin.Direction <> TPinDirection.Input) then
        AddError('Link ToPin is not input.');

      if (L.FromPin <> nil) and ((L.FromPin.OwnerNode = nil) or
        (not FNodes.Contains(TCustomNode(L.FromPin.OwnerNode)))) then
        AddError('Link FromPin points to pin outside graph.');

      if (L.ToPin <> nil) and ((L.ToPin.OwnerNode = nil) or
        (not FNodes.Contains(TCustomNode(L.ToPin.OwnerNode)))) then
        AddError('Link ToPin points to pin outside graph.');

      if (L.FromPin <> nil) and (L.ToPin <> nil) and
        (not CanConnect(L.FromPin, L.ToPin)) then
        AddError('Link violates CanConnect rule.');
    end;
  finally
    PinIds.Free;
    NodeIds.Free;
  end;
end;

function TNodeGraph.IsNodeIdUnique(const AId: string; AExcept: TCustomNode): boolean;
begin
  Result := True;

  if AId = '' then
    Exit(False);

  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];

    if N = AExcept then
      Continue;

    if SameText(N.Id, AId) then
      Exit(False);
  end;
end;

function TNodeGraph.IsPinIdUnique(const AId: string; AExcept: TNodePin): boolean;
begin
  Result := True;

  if AId = '' then
    Exit(False);

  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];

    for var j := 0 to N.InputCount - 1 do
    begin
      var P := N.GetInput(j);

      if P = AExcept then
        Continue;

      if SameText(P.Id, AId) then
        Exit(False);
    end;

    for var j := 0 to N.OutputCount - 1 do
    begin
      var P := N.GetOutput(j);

      if P = AExcept then
        Continue;

      if SameText(P.Id, AId) then
        Exit(False);
    end;
  end;
end;

function TNodeGraph.FindLinkById(const AId: string): TNodeLink;
begin
  Result := nil;
  for var i := 0 to FLinks.Count - 1 do
  begin
    var L := FLinks[i];
    if (L <> nil) and SameText(L.Id, AId) then
      Exit(L);
  end;
end;

function TNodeGraph.FindNodeById(const AId: string): TCustomNode;
begin
  Result := nil;
  if AId = '' then
    Exit;

  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];
    if (N <> nil) and SameText(N.Id, AId) then
      Exit(N);
  end;
end;

function TNodeGraph.FindPinById(const AId: string): TNodePin;
begin
  Result := nil;
  for var i := 0 to FNodes.Count - 1 do
  begin
    Result := FNodes[i].FindPinById(AId);
    if Result <> nil then
      Exit;
  end;
end;

function TNodeGraph.CanConnect(P1, P2: TNodePin): Boolean;
var
  OutPin, InPin: TNodePin;
begin
  Result := False;

  if not Assigned(P1) or not Assigned(P2) then
    Exit;

  if P1 = P2 then
    Exit;

  if P1.Direction = P2.Direction then
    Exit;

  if P1.OwnerNode = nil then
    Exit;

  if P2.OwnerNode = nil then
    Exit;

  if P1.OwnerNode = P2.OwnerNode then
    Exit;

  if P1.Kind <> P2.Kind then
    Exit;

  if P1.Direction = TPinDirection.Output then
  begin
    OutPin := P1;
    InPin := P2;
  end
  else
  begin
    OutPin := P2;
    InPin := P1;
  end;

  if OutPin.Direction <> TPinDirection.Output then
    Exit;

  if InPin.Direction <> TPinDirection.Input then
    Exit;

  if OutPin.Kind = TPinKind.Exec then
  begin
    Result := True;
    Exit;
  end;

  if (OutPin.PinType <> nil) and (InPin.PinType <> nil) then
  begin
    Result := OutPin.PinType.IsCompatibleWith(InPin.PinType);
    Exit;
  end;

  Result :=
    SameText(OutPin.DataType, InPin.DataType) or SameText(OutPin.DataType, 'any') or
    SameText(InPin.DataType, 'any') or (OutPin.DataType = '') or
    (InPin.DataType = '');
end;

function TNodeGraph.LinkExists(FromPin, ToPin: TNodePin): Boolean;
var
  L: TNodeLink;
  AFrom, ATo: TNodePin;
begin
  Result := False;

  if (FromPin = nil) or (ToPin = nil) then
    Exit;

  if FromPin.Direction = TPinDirection.Output then
  begin
    AFrom := FromPin;
    ATo := ToPin;
  end
  else
  begin
    AFrom := ToPin;
    ATo := FromPin;
  end;

  for var i := 0 to FLinks.Count - 1 do
  begin
    L := FLinks[i];
    if (L.FromPin = AFrom) and (L.ToPin = ATo) then
      Exit(True);
  end;
end;

procedure TNodeGraph.DoGraphChanged;
begin
  if FUpdateLock > 0 then
    Exit;

  if Assigned(FOnGraphChanged) then
    FOnGraphChanged(Self);
end;

procedure TNodeGraph.RemoveLinksToInput(APin: TNodePin);
begin
  if APin = nil then
    Exit;

  for var i := FLinks.Count - 1 downto 0 do
    if FLinks[i].ToPin = APin then
    begin
      var Link := FLinks[i];
      FLinks.Delete(i);

      if Assigned(FOnLinkRemoved) then
        FOnLinkRemoved(Self, Link);

      var NFrom: TCustomNode := nil;
      var NTo: TCustomNode := nil;
      if (Link.FromPin <> nil) and (Link.FromPin.OwnerNode <> nil) then
        NFrom := Link.FromPin.OwnerNode;

      if (Link.ToPin <> nil) and (Link.ToPin.OwnerNode <> nil) then
        NTo := Link.ToPin.OwnerNode;

      if (NFrom <> nil) and (NTo <> nil) then
        if not HasLinksBetweenNodes(NFrom, NTo) then
          FNodes.RemoveEdge(NFrom, NTo);
    end;

  DoGraphChanged;
end;

function TNodeGraph.PinHasIncomingLink(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  for var i := 0 to FLinks.Count - 1 do
    if FLinks[i].ToPin = APin then
      Exit(True);
end;

function TNodeGraph.PinHasOutgoingLink(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  for var i := 0 to FLinks.Count - 1 do
    if FLinks[i].FromPin = APin then
      Exit(True);
end;

procedure TNodeGraph.PushExecutedCommand(ACommand: TGraphCommand; Silent: Boolean);
begin
  if ACommand = nil then
    Exit;

  if FUndoLock or Silent then
  begin
    ACommand.Free;
    Exit;
  end;

  FUndoStack.Add(ACommand);
  FRedoStack.Clear;

  TruncateUndo;

  DoGraphChanged;
end;

procedure TNodeGraph.ExecuteBegin(const ADescription: string);
begin
  if not FCommandBeforeJson.IsEmpty then
    raise ENodeEditorGraphException.Create('The execution has already started');
  FCommandBeforeJson := CaptureJSONText;
  FCommandDescription := ADescription;
end;

procedure TNodeGraph.ExecuteCancel;
begin
  FCommandBeforeJson := '';
  FCommandDescription := '';
end;

procedure TNodeGraph.ExecuteEnd;
begin
  try
    ExecuteJSONSnapshotCommand(FCommandBeforeJson, CaptureJSONText, FCommandDescription);
  finally
    ExecuteCancel;
  end;
end;

procedure TNodeGraph.ExecuteCommand(ACommand: TGraphCommand; Silent: Boolean);
begin
  if ACommand = nil then
    Exit;

  FExecutingCommand := True;
  try
    ACommand.DoExecute;
  finally
    FExecutingCommand := False;
  end;

  if FUndoLock or Silent then
  begin
    ACommand.Free;
    Exit;
  end;

  FUndoStack.Add(ACommand);
  FRedoStack.Clear;

  TruncateUndo;

  DoGraphChanged;
end;

procedure TNodeGraph.Clear;
begin
  FLinks.Clear;
  FNodes.Clear;
  DoGraphChanged;
end;

procedure TNodeGraph.ClearUndoRedo;
begin
  FUndoStack.Clear;
  FRedoStack.Clear;
end;

procedure TNodeGraph.TruncateUndo;
begin
  while FUndoStack.Count > UndoLimit do
    FUndoStack.Delete(0);
end;

function TNodeGraph.CaptureJSONText: string;
begin
  var Obj := SaveGraphToJSON;
  try
    Result := Obj.ToJSON;
  finally
    Obj.Free;
  end;
end;

procedure TNodeGraph.ExecuteJSONSnapshotCommand(const ABeforeJSON, AAfterJSON, ADescription: string);
begin
  if ABeforeJSON = AAfterJSON then
    Exit;

  PushExecutedCommand(TJSONSnapshotCommand.Create(Self, ABeforeJSON, AAfterJSON, ADescription));
end;

function TNodeGraph.NextZOrder: integer;
begin
  Result := 1;
  for var i := 0 to FNodes.Count - 1 do
    Result := Max(Result, FNodes[i].ZOrder + 1);
end;

procedure TNodeGraph.BringNodeToFront(ANodes: TList<TCustomNode>);
begin
  if ANodes = nil then
    Exit;
  ExecuteCommand(TReorderSelectedCommand.Create(Self, ANodes, True));
end;

procedure TNodeGraph.SendNodeToBack(ANodes: TList<TCustomNode>);
begin
  if ANodes = nil then
    Exit;
  ExecuteCommand(TReorderSelectedCommand.Create(Self, ANodes, False));
end;

procedure TNodeGraph.Undo;
begin
  if FUndoStack.Count = 0 then
    Exit;

  FUndoLock := True;
  try
    var Cmd := FUndoStack.ExtractAt(FUndoStack.Count - 1);
    Cmd.Undo;
    FRedoStack.Add(Cmd);
  finally
    FUndoLock := False;
  end;

  DoGraphChanged;
end;

procedure TNodeGraph.Redo;
begin
  if FRedoStack.Count = 0 then
    Exit;

  FUndoLock := True;
  try
    var Cmd := FRedoStack.ExtractAt(FRedoStack.Count - 1);
    Cmd.DoExecute;
    FUndoStack.Add(Cmd);
  finally
    FUndoLock := False;
  end;

  DoGraphChanged;
end;

function TNodeGraph.SaveGraphToJSON: TJSONObject;
var
  NodesArr, LinksArr: TJSONArray;
  NodeObj, LinkObj: TJSONObject;
  i: integer;
  N: TCustomNode;
  L: TNodeLink;
begin
  Result := TJSONObject.Create;
  try
    NodesArr := TJSONArray.Create;
    for i := 0 to FNodes.Count - 1 do
    begin
      N := FNodes[i];
      NodeObj := TJSONObject.Create;
      N.SaveToJSON(NodeObj);
      NodesArr.Add(NodeObj);
    end;
    Result.AddPair('nodes', NodesArr);

    LinksArr := TJSONArray.Create;
    for i := 0 to FLinks.Count - 1 do
    begin
      L := FLinks[i];
      if (L.FromPin = nil) or (L.ToPin = nil) then
        Continue;

      LinkObj := TJSONObject.Create;
      LinkObj.AddPair('id', L.Id);
      LinkObj.AddPair('fromPinId', L.FromPin.Id);
      LinkObj.AddPair('toPinId', L.ToPin.Id);
      LinksArr.Add(LinkObj);
    end;
    Result.AddPair('links', LinksArr);
  except
    Result.Free;
    raise;
  end;
end;

procedure TNodeGraph.LoadGraphFromJSON(AObj: TJSONObject; UseAlphaColor: Boolean);
begin
  BeginUpdate;
  try
    Clear;

    var NodesArr := AObj.GetValue<TJSONArray>('nodes', nil);
    if NodesArr <> nil then
    begin
      for var i := 0 to NodesArr.Count - 1 do
      begin
        var NodeObj := NodesArr.Items[i] as TJSONObject;
        var NodeType := NodeObj.GetValue('type', 'default');

        var N := FRegistry.CreateNode(NodeType, PointF(NodeObj.GetValue<Single>('x', 0.0), NodeObj.GetValue<Single>('y', 0.0)));
        N.LoadFromJSON(NodeObj, False, UseAlphaColor);
        FNodes.Add(N);
      end;
    end;

    var LinksArr := AObj.GetValue<TJSONArray>('links', nil);
    if LinksArr <> nil then
    begin
      for var i := 0 to LinksArr.Count - 1 do
      begin
        var LinkObj := LinksArr.Items[i] as TJSONObject;
        var FromPin := FindPinById(LinkObj.GetValue('fromPinId', ''));
        var ToPin := FindPinById(LinkObj.GetValue('toPinId', ''));

        if (FromPin <> nil) and (ToPin <> nil) and CanConnect(FromPin, ToPin) then
        begin
          var L := TNodeLink.Create(FromPin, ToPin);
          L.Id := LinkObj.GetValue('id', L.Id);
          // AddLink handles FLinks and FNodes sync
          AddLink(L);
        end;
      end;
    end;
  finally
    EndUpdate;
    DoGraphChanged;
  end;
end;

function TNodeGraph.TopologicalSortDataNodes(AList: TList<TCustomNode>): integer;
var
  InDegree: TDictionary<TCustomNode, integer>;
  Queue: TList<TCustomNode>;
  i, j, Deg: integer;
  N, FromNode, ToNode: TCustomNode;
  L: TNodeLink;
begin
  Result := 0;
  if AList = nil then
    Exit;

  AList.Clear;

  InDegree := TDictionary<TCustomNode, integer>.Create;
  Queue := TList<TCustomNode>.Create;
  try
    for i := 0 to FNodes.Count - 1 do
    begin
      N := FNodes[i];
      if N <> nil then
        InDegree.AddOrSetValue(N, 0);
    end;

    for i := 0 to FLinks.Count - 1 do
    begin
      L := FLinks[i];
      if (L = nil) or (L.FromPin = nil) or (L.ToPin = nil) then
        Continue;

      if (L.FromPin.Kind <> TPinKind.Data) or (L.ToPin.Kind <> TPinKind.Data) then
        Continue;

      FromNode := L.FromPin.OwnerNode;
      ToNode := L.ToPin.OwnerNode;
      if (FromNode = nil) or (ToNode = nil) then
        Continue;

      if InDegree.TryGetValue(ToNode, Deg) then
        InDegree.AddOrSetValue(ToNode, Deg + 1);
    end;

    for i := 0 to FNodes.Count - 1 do
    begin
      N := FNodes[i];
      if (N <> nil) and InDegree.TryGetValue(N, Deg) and (Deg = 0) then
        Queue.Add(N);
    end;

    i := 0;
    while i < Queue.Count do
    begin
      N := Queue[i];
      Inc(i);

      AList.Add(N);

      for j := 0 to FLinks.Count - 1 do
      begin
        L := FLinks[j];
        if (L = nil) or (L.FromPin = nil) or (L.ToPin = nil) then
          Continue;

        if (L.FromPin.Kind <> TPinKind.Data) or (L.ToPin.Kind <> TPinKind.Data) then
          Continue;

        FromNode := L.FromPin.OwnerNode;
        ToNode := L.ToPin.OwnerNode;

        if (FromNode = N) and (ToNode <> nil) then
        begin
          if InDegree.TryGetValue(ToNode, Deg) then
          begin
            Dec(Deg);
            InDegree.AddOrSetValue(ToNode, Deg);
            if Deg = 0 then
              Queue.Add(ToNode);
          end;
        end;
      end;
    end;

    Result := AList.Count;
  finally
    Queue.Free;
    InDegree.Free;
  end;
end;

function TNodeGraph.AddDynamicInputPin(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
var
  BeforeJSON, AfterJSON: string;
begin
  Result := nil;

  if ANode = nil then
    Exit;

  BeforeJSON := CaptureJSONText;
  Result := ANode.AddInputPin(AName, ADataType, AKind);
  AfterJSON := CaptureJSONText;

  ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Add input pin');
  DoGraphChanged;
end;

function TNodeGraph.AddDynamicOutputPin(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
var
  BeforeJSON, AfterJSON: string;
begin
  Result := nil;

  if ANode = nil then
    Exit;

  BeforeJSON := CaptureJSONText;
  Result := ANode.AddOutputPin(AName, ADataType, AKind);
  AfterJSON := CaptureJSONText;

  ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Add output pin');
  DoGraphChanged;
end;

function TNodeGraph.RemoveDynamicPin(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  var N := APin.OwnerNode;
  if N = nil then
    Exit;

  var BeforeJSON := CaptureJSONText;

  for var i := FLinks.Count - 1 downto 0 do
  begin
    var L := TNodeLink(FLinks[i]);
    if (L.FromPin = APin) or (L.ToPin = APin) then
      FLinks.Delete(i);
  end;

  Result := N.RemovePin(APin);

  var AfterJSON := CaptureJSONText;
  ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Remove pin');

  DoGraphChanged;
end;

function TNodeGraph.ValidateGraph: boolean;
begin
  Result := ValidateGraphIssues(nil);
end;

function TNodeGraph.ValidateGraphIssues(AIssues: TObjectList<TGraphValidationIssue>): boolean;

  procedure AddIssue(AKind: TGraphValidationIssueKind; const AMsg: string; ANode: TCustomNode; ALink: TNodeLink);
  begin
    var Issue := TGraphValidationIssue.Create;
    AIssues.Add(Issue);
    Issue.Kind := AKind;
    Issue.MessageText := AMsg;
    Issue.Node := ANode;
    Issue.Link := ALink;
  end;

begin
  Result := True;

  for var i := 0 to FLinks.Count - 1 do
  begin
    var L := FLinks[i];

    if (L.FromPin = nil) or (L.ToPin = nil) then
    begin
      if AIssues <> nil then
        AddIssue(TGraphValidationIssueKind.Error, 'Broken link: nil pin.', nil, L);
      Result := False;
      Continue;
    end;

    if not CanConnect(L.FromPin, L.ToPin) then
    begin
      if AIssues <> nil then
        AddIssue(TGraphValidationIssueKind.Error, 'Invalid link type/direction.', nil, L);
      Result := False;
    end;
  end;

  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];

    for var j := 0 to N.InputCount - 1 do
    begin
      var P := N.GetInput(j);

      if P.IsRequired then
      begin
        if not PinHasIncomingLink(P) and (Trim(P.DefaultValue) = '') then
        begin
          if AIssues <> nil then
            AddIssue(
              TGraphValidationIssueKind.Warning,
              'Required input "' + P.Name + '" is not connected on node "' +
              N.Title + '".',
              N,
              nil);
        end;
      end;
    end;
  end;

  if HasCycle then
  begin
    if AIssues <> nil then
      AddIssue(TGraphValidationIssueKind.Error, 'Graph contains cycle.', nil, nil);
    Result := False;
  end;
end;

function TNodeGraph.HasCycle: boolean;
begin
  // Using DAG cycle check
  Result := not FNodes.IsAcyclic;
end;

function TNodeGraph.CreateRerouteForLink(ALink: TNodeLink; const Position: TPointF): TCustomNode;
var
  N: TCustomNode;
  OldFrom: TNodePin;
  OldTo: TNodePin;
begin
  Result := nil;

  if (ALink = nil) or (ALink.FromPin = nil) or (ALink.ToPin = nil) then
    Exit;

  OldFrom := ALink.FromPin;
  OldTo := ALink.ToPin;
  N := nil;
  case OldFrom.Kind of
    TPinKind.Data:
      N := FRegistry.CreateNode('reroute_data', Position);
    TPinKind.Exec:
      N := FRegistry.CreateNode('reroute_exec', Position);
  end;
  if not Assigned(N) then
    Exit;

  N.X := N.X - N.Width / 2;
  N.Y := N.Y - N.Height / 2;

  if (N.InputCount > 0) and (N.OutputCount > 0) then
  begin
    N.GetInput(0).Kind := OldFrom.Kind;
    N.GetInput(0).DataType := OldFrom.DataType;
    N.GetInput(0).SetTypeId(OldFrom.DataType);

    if OldFrom.PinType <> nil then
    begin
      N.GetInput(0).PinType.Free;
      N.GetInput(0).PinType := OldFrom.PinType.Clone;
    end;

    N.GetOutput(0).Kind := OldFrom.Kind;
    N.GetOutput(0).DataType := OldFrom.DataType;
    N.GetOutput(0).SetTypeId(OldFrom.DataType);

    if OldFrom.PinType <> nil then
    begin
      N.GetOutput(0).PinType.Free;
      N.GetOutput(0).PinType := OldFrom.PinType.Clone;
    end;
  end;

  RemoveLink(ALink);
  AddNode(N);

  AddLink(TNodeLink.Create(OldFrom, N.GetInput(0)));
  AddLink(TNodeLink.Create(N.GetOutput(0), OldTo));

  Result := N;
end;

function TNodeGraph.GetCompatibleNodesForPin(APin: TNodePin): TStringList;
begin
  Result := TStringList.Create;
  try
    for var Item in FRegistry do
      Result.Add(Item.NodeType);
  except
    Result.Free;
    raise;
  end;
end;

{ TNodeDefinition }

constructor TNodeDefinition.Create;
begin
  inherited Create;
  Tags := TStringList.Create;
  Version := 1;
  Hidden := False;
  IsDeprecated := False;
  Color := TAlphaColors.Null;
end;

destructor TNodeDefinition.Destroy;
begin
  Tags.Free;
  inherited Destroy;
end;

function TNodeDefinition.MatchesFilter(const AFilter: string): boolean;
var
  F: string;
  i: integer;
begin
  F := Trim(AFilter).ToLower;

  if F = '' then
    Exit(True);

  Result :=
    (Pos(F, NodeType.ToLower) > 0) or (Pos(F, Caption.ToLower) > 0) or
    (Pos(F, Category.ToLower) > 0) or (Pos(F, Description.ToLower) > 0);

  if Result then
    Exit;

  for i := 0 to Tags.Count - 1 do
    if Pos(F, Tags[i].ToLower) > 0 then
      Exit(True);
end;

{ TNodeRegistry }

constructor TNodeRegistry.Create;
begin
  inherited Create(True);
end;

procedure TNodeRegistry.RegisterNode(const ANodeType, ACaption: string; AClass: TCustomNodeClass);
begin
  RegisterNodeEx(ANodeType, ACaption, '', '', '', '', AClass);
end;

procedure TNodeRegistry.RegisterNodeEx(const ANodeType, ACaption, ACategory, ADescription, ATags, AIconPath: string; AClass: TCustomNodeClass; AColor: TAlphaColor; AHidden: boolean; ADeprecated: boolean; AVersion: integer);
begin
  if FindItem(ANodeType) <> nil then
    Exit;

  var It := TNodeDefinition.Create;
  It.NodeType := ANodeType;
  It.Caption := ACaption;
  It.Category := ACategory;
  It.Description := ADescription;
  It.NodeClass := AClass;
  It.Hidden := AHidden;
  It.IsDeprecated := ADeprecated;
  It.Version := AVersion;
  It.Tags.AddStrings(ATags.Split([',']));
  if AIconPath.IsEmpty or (AColor = TAlphaColors.Null) then
  begin
    var TMP := AClass.Create;
    try
      TMP.NodeType := ANodeType;
      if AIconPath.IsEmpty then
        It.IconPath := TMP.IconPath;
      if AColor = TAlphaColors.Null then
        It.Color := TMP.HeaderColor;
    finally
      TMP.Free;
    end;
  end
  else
  begin
    It.IconPath := AIconPath;
    It.Color := AColor;
  end;
  Add(It);
end;

procedure TNodeRegistry.SortByCategory;
begin
  Sort(TComparer<TNodeDefinition>.Construct(
    function(const Left, Right: TNodeDefinition): Integer
    begin
      Result := CompareStr(Left.Category, Right.Category);
      if Result = 0 then
        Result := CompareStr(Left.Caption, Right.Caption);
    end));
end;

function TNodeRegistry.FindItem(const ANodeType: string): TNodeRegistryItem;
begin
  for var Item in Self do
    if Item.NodeType.Equals(ANodeType) then
      Exit(Item);
  Result := nil;
end;

function TNodeRegistry.CreateNode(const ANodeType: string; const Position: TPointF): TCustomNode;
begin
  var It := FindItem(ANodeType);

  if It <> nil then
  begin
    Result := It.NodeClass.Create;
    if not It.Caption.IsEmpty then
      Result.Title := It.Caption;
    Result.X := Position.X;
    Result.Y := Position.Y;
    Result.NodeType := It.NodeType;
    if not It.IconPath.IsEmpty then
      Result.IconPath := It.IconPath;
    Result.SetupPins;
  end
  else
  begin
    Result := TDefaultNode.Create;
    Result.Title := Translate('Unknown') + ': ' + ANodeType;
    Result.X := Position.X;
    Result.Y := Position.Y;
    Result.NodeType := ANodeType;
    Result.IconPath := '';
    Result.SetupPins;
  end;
end;

initialization
  TNodeGraph.UndoLimit := 100;

end.

