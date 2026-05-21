unit FMX.NodeEditor.Node.Graph;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.UITypes,
  System.Types, System.JSON, FMX.NodeEditor.Node, FMX.NodeEditor.Types;

type
  TNodeGraph = class;

  TGraphNodeEvent = procedure(Sender: TObject; ANode: TCustomNode) of object;

  TGraphLinkEvent = procedure(Sender: TObject; ALink: TNodeLink) of object;

  TGraphChangedEvent = procedure(Sender: TObject) of object;

  TGraphValidationIssueKind = (gviError, gviWarning);

  TGraphCommand = class
  protected
    FGraph: TNodeGraph;
    FDescription: string;
  public
    constructor Create(AGraph: TNodeGraph; const ADescription: string = ''); virtual;
    destructor Destroy; override;

    procedure DoExecute; virtual; abstract;
    procedure Undo; virtual; abstract;

    property Description: string read FDescription;
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

    constructor Create;
    destructor Destroy; override;

    function MatchesFilter(const AFilter: string): boolean;
  end;

  TNodeRegistryItem = TNodeDefinition;

  TNodeRegistry = class
  private
    FItems: TObjectList<TNodeRegistryItem>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterNode(const ANodeType, ACaption: string; AClass: TCustomNodeClass);
    procedure RegisterNodeEx(const ANodeType, ACaption, ACategory, ADescription, ATags: string; AClass: TCustomNodeClass; AColor: TAlphaColor = TAlphaColors.Null; AHidden: boolean = False; ADeprecated: boolean = False; AVersion: integer = 1);
    function CreateNode(const ANodeType: string; AX, AY: single): TCustomNode;
    function FindItem(const ANodeType: string): TNodeRegistryItem;
    function Count: integer;
    function Item(Index: integer): TNodeRegistryItem;
  end;

  TNodeGraph = class
  private
    FNodes: TObjectList<TCustomNode>;
    FLinks: TObjectList<TNodeLink>;
    FRegistry: TNodeRegistry;
    FUndoStack: TObjectList<TGraphCommand>;
    FRedoStack: TObjectList<TGraphCommand>;
    FUndoLock: boolean;
    FExecutingCommand: boolean;
    FOnNodeAdded: TGraphNodeEvent;
    FOnNodeRemoved: TGraphNodeEvent;
    FOnLinkAdded: TGraphLinkEvent;
    FOnLinkRemoved: TGraphLinkEvent;
    FOnGraphChanged: TGraphChangedEvent;

    procedure RemoveLinksToInput(APin: TNodePin);

  protected
    function PinHasIncomingLink(APin: TNodePin): boolean;
    function PinHasOutgoingLink(APin: TNodePin): boolean;
    procedure PushExecutedCommand(ACommand: TGraphCommand);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddNode(ANode: TCustomNode);
    function DetachNode(ANode: TCustomNode): boolean;
    procedure RemoveNode(ANode: TCustomNode);
    procedure AddLink(ALink: TNodeLink);
    procedure RemoveLink(ALink: TNodeLink);

    function CheckInvariants(AErrors: TStrings = nil): boolean;
    procedure NormalizeGraph;
    function IsNodeIdUnique(const AId: string; AExcept: TCustomNode = nil): boolean;
    function IsPinIdUnique(const AId: string; AExcept: TNodePin = nil): boolean;

    function AddDynamicInputPin(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = pkData): TNodePin;
    function AddDynamicOutputPin(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = pkData): TNodePin;
    function RemoveDynamicPin(APin: TNodePin): boolean;
    procedure DoGraphChanged;

    function FindNodeById(const AId: string): TCustomNode;
    function FindPinById(const AId: string): TNodePin;
    function CanConnect(P1, P2: TNodePin): boolean;
    function LinkExists(FromPin, ToPin: TNodePin): boolean;

    procedure Clear;
    procedure PushUndoSnapshot;
    procedure Undo;
    procedure Redo;

    function SaveGraphToJSON: TJSONObject;
    procedure LoadGraphFromJSON(AObj: TJSONObject);

    function ValidateGraph: boolean;
    function ValidateGraphIssues(AIssues: TObjectList<TGraphValidationIssue>): boolean;
    function HasCycle: boolean;
    function CreateRerouteForLink(ALink: TNodeLink; AX, AY: single): TCustomNode;
    function GetCompatibleNodesForPin(APin: TNodePin): TStringList;

    procedure ExecuteCommand(ACommand: TGraphCommand);
    procedure ClearUndoRedo;
    function CaptureJSONText: string;
    procedure ExecuteJSONSnapshotCommand(const ABeforeJSON, AAfterJSON, ADescription: string);

    function NextZOrder: integer;
    procedure BringNodeToFront(ANode: TCustomNode);
    procedure SendNodeToBack(ANode: TCustomNode);

    property Nodes: TObjectList<TCustomNode> read FNodes;
    property Links: TObjectList<TNodeLink> read FLinks;
    property Registry: TNodeRegistry read FRegistry;
    property OnNodeAdded: TGraphNodeEvent read FOnNodeAdded write FOnNodeAdded;
    property OnNodeRemoved: TGraphNodeEvent read FOnNodeRemoved write FOnNodeRemoved;
    property OnLinkAdded: TGraphLinkEvent read FOnLinkAdded write FOnLinkAdded;
    property OnLinkRemoved: TGraphLinkEvent read FOnLinkRemoved write FOnLinkRemoved;
    property OnGraphChanged: TGraphChangedEvent read FOnGraphChanged write FOnGraphChanged;
  end;

procedure LoadGraphFromJSONText(AGraph: TNodeGraph; const S: string);

procedure ApplyNodePropertiesFromJSON(ANode: TCustomNode; AObj: TJSONObject);

implementation

uses
  System.Math, FMX.NodeEditor.Node.Defaults, FMX.NodeEditor.Node.Command;

procedure LoadGraphFromJSONText(AGraph: TNodeGraph; const S: string);
var
  Data: TJSONValue;
begin
  if AGraph = nil then
    Exit;

  if Trim(S) = '' then
    Exit;

  Data := TJSONValue.ParseJSONValue(S);
  try
    if Data is TJSONObject then
      AGraph.LoadGraphFromJSON(TJSONObject(Data));
  finally
    Data.Free;
  end;
end;

procedure ApplyNodePropertiesFromJSON(ANode: TCustomNode; AObj: TJSONObject);
var
  i: integer;
  ValuesArr: TJSONArray;
  VObj: TJSONObject;
  V: TNodeValue;
  S: string;
begin
  if (ANode = nil) or (AObj = nil) then
    Exit;

  ANode.Title := AObj.GetValue('title', ANode.Title);
  ANode.X := AObj.GetValue('x', ANode.X);
  ANode.Y := AObj.GetValue('y', ANode.Y);
  ANode.Width := AObj.GetValue('width', ANode.Width);
  ANode.Height := AObj.GetValue('height', ANode.Height);
  ANode.HeaderColor := TColor(AObj.GetValue('headerColor', integer(ANode.HeaderColor)));
  ANode.BodyColor := TColor(AObj.GetValue('bodyColor', integer(ANode.BodyColor)));
  ANode.Collapsed := AObj.GetValue('collapsed', ANode.Collapsed);
  ANode.CommentText := AObj.GetValue('comment', ANode.CommentText);

  ValuesArr := AObj.GetValue<TJSONArray>('values', nil);
  if ValuesArr <> nil then
  begin
    for i := 0 to Min(ANode.ValueCount, ValuesArr.Count) - 1 do
    begin
      V := ANode.GetValue(i);
      VObj := ValuesArr.Items[i] as TJSONObject;
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
          begin
            S := VObj.GetValue('value', V.JSONValue);
            V.JSONValue := S;
          end;
      end;
    end;
  end;
end;

{ TGraphCommand }

constructor TGraphCommand.Create(AGraph: TNodeGraph; const ADescription: string);
begin
  inherited Create;
  FGraph := AGraph;
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
  FNodes := TObjectList<TCustomNode>.Create;
  FLinks := TObjectList<TNodeLink>.Create;
  FRegistry := TNodeRegistry.Create;
  FUndoStack := TObjectList<TGraphCommand>.Create;
  FRedoStack := TObjectList<TGraphCommand>.Create;

  FRegistry.RegisterNodeEx('default', 'Default Node', 'Basic',
    'Generic test node.', 'default,test', TDefaultNode);

  FRegistry.RegisterNodeEx('float', 'Float Value', 'Values',
    'Constant float value.', 'float,number,value,const', TFloatNode);

  FRegistry.RegisterNodeEx('add', 'Add Float', 'Math',
    'Adds two float values.', 'add,plus,math,float', TAddNode);

  FRegistry.RegisterNodeEx('reroute', 'Reroute', 'Utility',
    'Reroute connection wire.', 'reroute,wire', TRerouteNode);

  FRegistry.RegisterNodeEx('comment', 'Comment / Frame', 'Utility',
    'Visual comment frame.', 'comment,frame,group', TCommentNode);
end;

destructor TNodeGraph.Destroy;
begin
  Clear;
  ClearUndoRedo;
  FUndoStack.Free;
  FRedoStack.Free;
  FRegistry.Free;
  FLinks.Free;
  FNodes.Free;
  inherited Destroy;
end;

procedure TNodeGraph.AddNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;
  if FNodes.IndexOf(ANode) >= 0 then
    Exit;

  if ANode.ZOrder = 0 then
    ANode.ZOrder := NextZOrder;

  FNodes.Add(ANode);

  if Assigned(FOnNodeAdded) then
    FOnNodeAdded(Self, ANode);

  DoGraphChanged;
end;

function TNodeGraph.DetachNode(ANode: TCustomNode): boolean;
var
  i: integer;
  L: TNodeLink;
begin
  Result := False;

  if ANode = nil then
    Exit;

  if FNodes.IndexOf(ANode) < 0 then
    Exit;

  for i := FLinks.Count - 1 downto 0 do
  begin
    L := FLinks[i];

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
var
  i: integer;
  L: TNodeLink;
begin
  if ANode = nil then
    Exit;

  for i := FLinks.Count - 1 downto 0 do
  begin
    L := FLinks[i];

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

procedure TNodeGraph.AddLink(ALink: TNodeLink);
var
  OutPin, InPin: TNodePin;
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

  if ALink.FromPin.Direction = pdOutput then
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

  if LinkExists(OutPin, InPin) then
  begin
    ALink.Free;
    Exit;
  end;

  if not InPin.AllowMultipleConnections then
    RemoveLinksToInput(InPin);

  FLinks.Add(ALink);

  if Assigned(FOnLinkAdded) then
    FOnLinkAdded(Self, ALink);

  DoGraphChanged;
end;

procedure TNodeGraph.RemoveLink(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  if FLinks.Contains(ALink) then
  begin
    if Assigned(FOnLinkRemoved) then
      FOnLinkRemoved(Self, ALink);

    FLinks.Remove(ALink);
    DoGraphChanged;
  end;
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
        AddError('Node list contains nil node.');
        Continue;
      end;

      if N.Id = '' then
        AddError('Node "' + N.Title + '" has empty Id.');

      if NodeIds.IndexOf(N.Id) >= 0 then
        AddError('Duplicate node Id: ' + N.Id)
      else
        NodeIds.Add(N.Id);

      for j := 0 to N.InputCount - 1 do
      begin
        P := N.GetInput(j);

        if P = nil then
        begin
          AddError('Node "' + N.Title + '" contains nil input pin.');
          Continue;
        end;

        if P.OwnerNode <> N then
          AddError('Input pin "' + P.Name + '" has invalid OwnerNode.');

        if P.Direction <> pdInput then
          AddError('Pin "' + P.Name + '" in input list has non-input direction.');

        if P.SortIndex <> j then
          AddError('Input pin "' + P.Name + '" has invalid SortIndex.');

        if P.Id = '' then
          AddError('Input pin "' + P.Name + '" has empty Id.');

        if PinIds.IndexOf(P.Id) >= 0 then
          AddError('Duplicate pin Id: ' + P.Id)
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

        if P.Direction <> pdOutput then
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

      if (L.FromPin <> nil) and (L.FromPin.Direction <> pdOutput) then
        AddError('Link FromPin is not output.');

      if (L.ToPin <> nil) and (L.ToPin.Direction <> pdInput) then
        AddError('Link ToPin is not input.');

      if (L.FromPin <> nil) and ((L.FromPin.OwnerNode = nil) or
        (FNodes.IndexOf(L.FromPin.OwnerNode) < 0)) then
        AddError('Link FromPin points to pin outside graph.');

      if (L.ToPin <> nil) and ((L.ToPin.OwnerNode = nil) or
        (FNodes.IndexOf(L.ToPin.OwnerNode) < 0)) then
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

procedure TNodeGraph.NormalizeGraph;
var
  i, j: integer;
  N: TCustomNode;
  P: TNodePin;
  L: TNodeLink;
  UsedNodeIds: TStringList;
  UsedPinIds: TStringList;
begin
  UsedNodeIds := TStringList.Create;
  UsedPinIds := TStringList.Create;
  try
    UsedNodeIds.CaseSensitive := False;
    UsedPinIds.CaseSensitive := False;

    for i := 0 to FNodes.Count - 1 do
    begin
      N := FNodes[i];

      if (N.Id = '') or (UsedNodeIds.IndexOf(N.Id) >= 0) then
        N.Id := NewId;

      UsedNodeIds.Add(N.Id);

      N.ReindexPins;

      for j := 0 to N.InputCount - 1 do
      begin
        P := N.GetInput(j);
        P.OwnerNode := N;
        P.Direction := pdInput;

        if (P.Id = '') or (UsedPinIds.IndexOf(P.Id) >= 0) then
          P.Id := NewId;

        UsedPinIds.Add(P.Id);
      end;

      for j := 0 to N.OutputCount - 1 do
      begin
        P := N.GetOutput(j);
        P.OwnerNode := N;
        P.Direction := pdOutput;

        if (P.Id = '') or (UsedPinIds.IndexOf(P.Id) >= 0) then
          P.Id := NewId;

        UsedPinIds.Add(P.Id);
      end;
    end;

    for i := FLinks.Count - 1 downto 0 do
    begin
      L := FLinks[i];

      if (L = nil) or (L.FromPin = nil) or (L.ToPin = nil) or
        (L.FromPin.OwnerNode = nil) or (L.ToPin.OwnerNode = nil) then
      begin
        FLinks.Delete(i);
        Continue;
      end;

      if (FNodes.IndexOf(L.FromPin.OwnerNode) < 0) or
        (FNodes.IndexOf(L.ToPin.OwnerNode) < 0) then
      begin
        FLinks.Delete(i);
        Continue;
      end;

      if (L.FromPin.Direction = pdInput) and (L.ToPin.Direction = pdOutput) then
      begin
        P := L.FromPin;
        L.FromPin := L.ToPin;
        L.ToPin := P;
      end;

      if (L.FromPin.Direction <> pdOutput) or (L.ToPin.Direction <> pdInput) or
        (not CanConnect(L.FromPin, L.ToPin)) then
      begin
        FLinks.Delete(i);
        Continue;
      end;
    end;
  finally
    UsedPinIds.Free;
    UsedNodeIds.Free;
  end;
end;

function TNodeGraph.IsNodeIdUnique(const AId: string; AExcept: TCustomNode): boolean;
var
  i: integer;
  N: TCustomNode;
begin
  Result := True;

  if AId = '' then
    Exit(False);

  for i := 0 to FNodes.Count - 1 do
  begin
    N := FNodes[i];

    if N = AExcept then
      Continue;

    if SameText(N.Id, AId) then
      Exit(False);
  end;
end;

function TNodeGraph.IsPinIdUnique(const AId: string; AExcept: TNodePin): boolean;
var
  i, j: integer;
  N: TCustomNode;
  P: TNodePin;
begin
  Result := True;

  if AId = '' then
    Exit(False);

  for i := 0 to FNodes.Count - 1 do
  begin
    N := FNodes[i];

    for j := 0 to N.InputCount - 1 do
    begin
      P := N.GetInput(j);

      if P = AExcept then
        Continue;

      if SameText(P.Id, AId) then
        Exit(False);
    end;

    for j := 0 to N.OutputCount - 1 do
    begin
      P := N.GetOutput(j);

      if P = AExcept then
        Continue;

      if SameText(P.Id, AId) then
        Exit(False);
    end;
  end;
end;

function TNodeGraph.FindNodeById(const AId: string): TCustomNode;
begin
  Result := nil;
  for var i := 0 to FNodes.Count - 1 do
    if FNodes[i].Id = AId then
      Exit(FNodes[i]);
end;

function TNodeGraph.FindPinById(const AId: string): TNodePin;
begin
  Result := nil;
  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];
    Result := N.FindPinById(AId);
    if Result <> nil then
      Exit;
  end;
end;

function TNodeGraph.CanConnect(P1, P2: TNodePin): boolean;
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

  if P1.Direction = pdOutput then
  begin
    OutPin := P1;
    InPin := P2;
  end
  else
  begin
    OutPin := P2;
    InPin := P1;
  end;

  if OutPin.Direction <> pdOutput then
    Exit;

  if InPin.Direction <> pdInput then
    Exit;

  if OutPin.Kind = pkExec then
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

function TNodeGraph.LinkExists(FromPin, ToPin: TNodePin): boolean;
var
  L: TNodeLink;
  AFrom, ATo: TNodePin;
begin
  Result := False;

  if (FromPin = nil) or (ToPin = nil) then
    Exit;

  if FromPin.Direction = pdOutput then
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
  if Assigned(FOnGraphChanged) then
    FOnGraphChanged(Self);
end;

procedure TNodeGraph.RemoveLinksToInput(APin: TNodePin);
begin
  if APin = nil then
    Exit;
  for var i := FLinks.Count - 1 downto 0 do
  begin
    var L := FLinks[i];
    if L.ToPin = APin then
      FLinks.Delete(i);
  end;
end;

function TNodeGraph.PinHasIncomingLink(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  for var i := 0 to FLinks.Count - 1 do
  begin
    var L := FLinks[i];
    if L.ToPin = APin then
      Exit(True);
  end;
end;

function TNodeGraph.PinHasOutgoingLink(APin: TNodePin): boolean;
begin
  Result := False;

  if APin = nil then
    Exit;

  for var i := 0 to FLinks.Count - 1 do
  begin
    var L := FLinks[i];
    if L.FromPin = APin then
      Exit(True);
  end;
end;

procedure TNodeGraph.PushExecutedCommand(ACommand: TGraphCommand);
begin
  if ACommand = nil then
    Exit;

  if FUndoLock then
  begin
    ACommand.Free;
    Exit;
  end;

  FUndoStack.Add(ACommand);
  FRedoStack.Clear;

  while FUndoStack.Count > 100 do
    FUndoStack.Delete(0);

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

procedure TNodeGraph.ExecuteCommand(ACommand: TGraphCommand);
begin
  if ACommand = nil then
    Exit;

  if FUndoLock then
  begin
    ACommand.DoExecute;
    ACommand.Free;
    Exit;
  end;

  FExecutingCommand := True;
  try
    ACommand.DoExecute;
  finally
    FExecutingCommand := False;
  end;

  FUndoStack.Add(ACommand);
  FRedoStack.Clear;

  while FUndoStack.Count > 100 do
    FUndoStack.Delete(0);

  DoGraphChanged;
end;

procedure TNodeGraph.PushUndoSnapshot;
begin
  if FUndoLock then
    Exit;

  var Obj := SaveGraphToJSON;
  try
    var Cmd := TJSONSnapshotCommand.Create(Self, Obj.ToJSON, Obj.ToJSON, 'Snapshot');
    FUndoStack.Add(Cmd);
  finally
    Obj.Free;
  end;

  while FUndoStack.Count > 100 do
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

  PushExecutedCommand(TJSONSnapshotCommand.Create(Self, ABeforeJSON,
      AAfterJSON, ADescription));
end;

function TNodeGraph.NextZOrder: integer;
begin
  Result := 1;

  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];
    Result := Max(Result, N.ZOrder + 1);
  end;
end;

procedure TNodeGraph.BringNodeToFront(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  ANode.ZOrder := NextZOrder;
  DoGraphChanged;
end;

procedure TNodeGraph.SendNodeToBack(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  ANode.ZOrder := 1;

  for var i := 0 to FNodes.Count - 1 do
  begin
    var N := FNodes[i];
    if N <> ANode then
      Inc(N.ZOrder);
  end;

  DoGraphChanged;
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

procedure TNodeGraph.LoadGraphFromJSON(AObj: TJSONObject);
var
  NodesArr, LinksArr: TJSONArray;
  NodeObj, LinkObj: TJSONObject;
  i: integer;
  N: TCustomNode;
  L: TNodeLink;
  FromPin, ToPin: TNodePin;
  NodeType: string;
begin
  Clear;

  NodesArr := AObj.GetValue<TJSONArray>('nodes', nil);
  if NodesArr <> nil then
  begin
    for i := 0 to NodesArr.Count - 1 do
    begin
      NodeObj := NodesArr.Items[i] as TJSONObject;
      NodeType := NodeObj.GetValue('type', 'default');

      N := FRegistry.CreateNode(NodeType, NodeObj.GetValue('x', 0.0), NodeObj.GetValue('y', 0.0));
      N.LoadFromJSON(NodeObj);
      FNodes.Add(N);
    end;
  end;

  LinksArr := AObj.GetValue<TJSONArray>('links', nil);
  if LinksArr <> nil then
  begin
    for i := 0 to LinksArr.Count - 1 do
    begin
      LinkObj := LinksArr.Items[i] as TJSONObject;
      FromPin := FindPinById(LinkObj.GetValue('fromPinId', ''));
      ToPin := FindPinById(LinkObj.GetValue('toPinId', ''));

      if (FromPin <> nil) and (ToPin <> nil) and CanConnect(FromPin, ToPin) then
      begin
        L := TNodeLink.Create(FromPin, ToPin);
        L.Id := LinkObj.GetValue('id', L.Id);
        FLinks.Add(L);
      end;
    end;
  end;
  NormalizeGraph;
  DoGraphChanged;
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
var
  BeforeJSON, AfterJSON: string;
  N: TCustomNode;
  i: integer;
  L: TNodeLink;
begin
  Result := False;

  if APin = nil then
    Exit;

  N := APin.OwnerNode;
  if N = nil then
    Exit;

  BeforeJSON := CaptureJSONText;

  for i := FLinks.Count - 1 downto 0 do
  begin
    L := TNodeLink(FLinks[i]);
    if (L.FromPin = APin) or (L.ToPin = APin) then
      FLinks.Delete(i);
  end;

  Result := N.RemovePin(APin);

  AfterJSON := CaptureJSONText;
  ExecuteJSONSnapshotCommand(BeforeJSON, AfterJSON, 'Remove pin');

  DoGraphChanged;
end;

function TNodeGraph.ValidateGraph: boolean;
begin
  var Issues := TObjectList<TGraphValidationIssue>.Create;
  try
    Result := ValidateGraphIssues(Issues);
  finally
    Issues.Free;
  end;
end;

function TNodeGraph.ValidateGraphIssues(AIssues: TObjectList<TGraphValidationIssue>): boolean;

  procedure AddIssue(AKind: TGraphValidationIssueKind; const AMsg: string; ANode: TCustomNode; ALink: TNodeLink);
  begin
    var Issue := TGraphValidationIssue.Create;
    Issue.Kind := AKind;
    Issue.MessageText := AMsg;
    Issue.Node := ANode;
    Issue.Link := ALink;

    if AIssues <> nil then
      AIssues.Add(Issue)
    else
      Issue.Free;
  end;

begin
  Result := True;

  for var i := 0 to FLinks.Count - 1 do
  begin
    var L := FLinks[i];

    if (L.FromPin = nil) or (L.ToPin = nil) then
    begin
      AddIssue(gviError, 'Broken link: nil pin.', nil, L);
      Result := False;
      Continue;
    end;

    if not CanConnect(L.FromPin, L.ToPin) then
    begin
      AddIssue(gviError, 'Invalid link type/direction.', nil, L);
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
          AddIssue(
            gviWarning,
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
    AddIssue(gviError, 'Graph contains cycle.', nil, nil);
    Result := False;
  end;
end;

function TNodeGraph.HasCycle: boolean;
var
  Visited: TList<TCustomNode>;
  Stack: TList<TCustomNode>;

  function Visit(N: TCustomNode): boolean;
  begin
    Result := False;

    if Stack.IndexOf(N) >= 0 then
      Exit(True);

    if Visited.IndexOf(N) >= 0 then
      Exit(False);

    if N.VisualKind = nvComment then
      Exit(False);

    Visited.Add(N);
    Stack.Add(N);

    for var i := 0 to FLinks.Count - 1 do
    begin
      var L := FLinks[i];

      if (L.FromPin <> nil) and (L.ToPin <> nil) and (L.FromPin.OwnerNode = N) then
      begin
        var NextNode := L.ToPin.OwnerNode;

        if (NextNode <> nil) and (NextNode.VisualKind <> nvComment) then
        begin
          if Visit(NextNode) then
            Exit(True);
        end;
      end;
    end;

    Stack.Remove(N);
  end;

begin
  Result := False;

  Visited := TList<TCustomNode>.Create;
  Stack := TList<TCustomNode>.Create;
  try
    for var i := 0 to FNodes.Count - 1 do
    begin
      if Visit(FNodes[i]) then
        Exit(True);
    end;
  finally
    Stack.Free;
    Visited.Free;
  end;
end;

function TNodeGraph.CreateRerouteForLink(ALink: TNodeLink; AX, AY: single): TCustomNode;
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

  N := FRegistry.CreateNode('reroute', AX, AY);

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
  for var i := 0 to FRegistry.Count - 1 do
  begin
    var RegItem := FRegistry.Item(i);
    Result.Add(RegItem.NodeType);
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
  inherited Create;
  FItems := TObjectList<TNodeRegistryItem>.Create;
end;

destructor TNodeRegistry.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TNodeRegistry.RegisterNode(const ANodeType, ACaption: string; AClass: TCustomNodeClass);
begin
  RegisterNodeEx(ANodeType, ACaption, '', '', '', AClass);
end;

procedure TNodeRegistry.RegisterNodeEx(const ANodeType, ACaption, ACategory, ADescription, ATags: string; AClass: TCustomNodeClass; AColor: TAlphaColor; AHidden: boolean; ADeprecated: boolean; AVersion: integer);
begin
  if FindItem(ANodeType) <> nil then
    Exit;

  var It := TNodeDefinition.Create;
  It.NodeType := ANodeType;
  It.Caption := ACaption;
  It.Category := ACategory;
  It.Description := ADescription;
  It.NodeClass := AClass;
  It.Color := AColor;
  It.Hidden := AHidden;
  It.IsDeprecated := ADeprecated;
  It.Version := AVersion;

  var TagsSL := TStringList.Create;
  try
    TagsSL.Delimiter := ',';
    TagsSL.StrictDelimiter := True;
    TagsSL.DelimitedText := ATags;

    for var i := 0 to TagsSL.Count - 1 do
      if Trim(TagsSL[i]) <> '' then
        It.Tags.Add(Trim(TagsSL[i]));
  finally
    TagsSL.Free;
  end;

  FItems.Add(It);
end;

function TNodeRegistry.FindItem(const ANodeType: string): TNodeRegistryItem;
begin
  Result := nil;

  for var i := 0 to FItems.Count - 1 do
  begin
    var It := FItems[i];
    if SameText(It.NodeType, ANodeType) then
      Exit(It);
  end;
end;

function TNodeRegistry.CreateNode(const ANodeType: string; AX, AY: single): TCustomNode;
var
  It: TNodeRegistryItem;
begin
  It := FindItem(ANodeType);

  if It <> nil then
  begin
    Result := It.NodeClass.Create(It.Caption, AX, AY);
    Result.NodeType := It.NodeType;
    Result.SetupPins;
  end
  else
  begin
    Result := TDefaultNode.Create('Unknown: ' + ANodeType, AX, AY);
    Result.NodeType := ANodeType;
    Result.SetupPins;
  end;
end;

function TNodeRegistry.Count: integer;
begin
  Result := FItems.Count;
end;

function TNodeRegistry.Item(Index: integer): TNodeRegistryItem;
begin
  if (Index >= 0) and (Index < FItems.Count) then
    Result := FItems[Index]
  else
    Result := nil;
end;

end.

