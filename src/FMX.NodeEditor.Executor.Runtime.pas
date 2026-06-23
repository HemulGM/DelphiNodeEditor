unit FMX.NodeEditor.Executor.Runtime;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Rtti,
  System.UITypes, FMX.NodeEditor.Types, FMX.NodeEditor.Node,
  FMX.NodeEditor.Graph, FMX.Graphics, FMX.NodeEditor.Debug.Intf;

type
  TNodeExecutionContext = class;

  TExecutableNode = class;

  ENodeExecutionError = class(ENodeEditorException);

  ENodeBreakSignal = class(ENodeExecutionError);

  ENodeContinueSignal = class(ENodeExecutionError);

  ENodeStepLimit = class(ENodeExecutionError);

  ENodeDebuggerPause = class(ENodeExecutionError);

  ENodeCycleDetected = class(ENodeExecutionError);

  ENodeExecutionStopped = class(ENodeExecutionError);

  TNodeExecutedEvent = procedure(AContext: TNodeExecutionContext; ANode: TExecutableNode) of object;

  TExecutableNode = class(TCustomNode)
  public
    function GetExecInputPin: TNodePin; virtual;
    procedure Execute(AContext: TNodeExecutionContext); virtual;
  end;

  TPinRuntimeValue = class
  public
    State: TNodeValueState;
    Value: TValue;
    constructor Create;
  end;

  TNodeExecutionContext = class(TNoRefCountObject, INodeExecutionContext)
  private
    FGraph: TNodeGraph;
    FPinValues: TObjectDictionary<TNodePin, TPinRuntimeValue>;
    FVariables: TDictionary<string, TValue>;
    FEventQueue: TDictionary<string, TValue>;
    FEventListeners: TDictionary<string, string>;
    FTriggeredListeners: TDictionary<string, TValue>;
    FStepCounter: Integer;
    FMaxStepCount: Integer;
    FLastExecutedNode: TCustomNode;
    FLastExecOutputPin: TNodePin;
    FDebugger: IGraphDebugger;
    FOnNodeExecuted: TNodeExecutedEvent;
    function GetPinEntry(APin: TNodePin; ACreate: Boolean): TPinRuntimeValue;
    function GetStepCounter: Integer;
  public
    constructor Create(AGraph: TNodeGraph);
    destructor Destroy; override;

    procedure Clear;

    property Graph: TNodeGraph read FGraph;
    property LastExecutedNode: TCustomNode read FLastExecutedNode write FLastExecutedNode;
    property LastExecOutputPin: TNodePin read FLastExecOutputPin write FLastExecOutputPin;
    property StepCounter: Integer read FStepCounter;
    property MaxStepCount: Integer read FMaxStepCount write FMaxStepCount;

    property Debugger: IGraphDebugger read FDebugger write FDebugger;
    property OnNodeExecuted: TNodeExecutedEvent read FOnNodeExecuted write FOnNodeExecuted;

    function HasPinValue(APin: TNodePin): Boolean;
    function TryGetPinValue(APin: TNodePin; out AValue: TValue): Boolean;
    procedure SetPinValue(APin: TNodePin; const AValue: TValue);

    function GetPinState(APin: TNodePin): TNodeValueState;
    procedure SetPinState(APin: TNodePin; AState: TNodeValueState);

    function TryGetVariable(const AName: string; out AValue: TValue): Boolean;
    procedure SetVariable(const AName: string; const AValue: TValue);

    function GetVariableValue(const AName: string): TValue;
    function GetVariableStr(const AName, ADefault: string): string;
    function GetVariableFloat(const AName: string; const ADefault: Double = 0.0): Double;
    function GetVariableBool(const AName: string; const ADefault: Boolean = False): Boolean;

    procedure SetVariableStr(const AName, AValue: string);
    procedure SetVariableFloat(const AName: string; const AValue: Double);
    procedure SetVariableBool(const AName: string; const AValue: Boolean);

    function GetInputValue(APin: TNodePin): TValue;
    function GetInputValueOrVar(APin: TNodePin; const VarName: string): TValue;
    procedure SetOutputValue(APin: TNodePin; const AValue: TValue);

    procedure RaiseEvent(const AEventName: string; const AData: TValue);
    procedure RegisterEventListener(const AListenerId, AEventName: string);
    function WasListenerTriggered(const AListenerId: string; out AData: TValue): Boolean;

    procedure IncStep;
    procedure SelectExecOutput(APin: TNodePin);
    procedure Print(const Text: string);
  end;

  TNodeGraphRuntimeHelper = class helper for TNodeGraph
  public
    function FindIncomingLink(APin: TNodePin): TNodeLink;
    function FindOutgoingLinks(APin: TNodePin; AList: TList<TNodeLink>): integer;

    function EvaluatePinValue(APin: TNodePin; AContext: TNodeExecutionContext): TValue;
    function EvaluateNodeOutput(ANode: TCustomNode; APin: TNodePin; AContext: TNodeExecutionContext): TValue;

    function GetInputPinValue(APin: TNodePin; AContext: TNodeExecutionContext): TValue;
    function GetInputPinValueByIndex(ANode: TCustomNode; AIndex: integer; AContext: TNodeExecutionContext): TValue;

    function ExecuteDataFlow(AContext: TNodeExecutionContext = nil): boolean;
    function FindExecOutgoingLinks(APin: TNodePin; AList: TList<TNodeLink>): integer;
    function FindFirstConnectedExecOutput(ANode: TCustomNode): TNodePin;
    function ExecuteExecPin(APin: TNodePin; AContext: TNodeExecutionContext): boolean;
    function ExecuteFromNode(ANode: TCustomNode; AContext: TNodeExecutionContext): boolean;
  end;

function NodeValueToFloatDef(const AValue: TValue; const ADefault: double = 0.0): double;

function NodeValueToStringDef(const AValue: TValue; const ADefault: string = ''): string;

function NodeValueToColorDef(const AValue: TValue; const ADefault: TAlphaColor = TAlphaColors.Null): TAlphaColor;

function MakeFloatValue(const AValue: double): TValue;

function MakeColorValue(const AValue: TAlphaColor): TValue;

function MakeBoolValue(const AValue: boolean): TValue;

function MakeIntValue(const AValue: int64): TValue;

function MakeBitmapValue(const AValue: IBitmapNodeObject): TValue;

function MakeStringValue(const AValue: string): TValue;

function NodeValueToBoolDef(const AValue: TValue; const ADefault: boolean = False): boolean;

function NodeValueToBitmapDef(const AValue: TValue; const ADefault: IBitmapNodeObject = nil): IBitmapNodeObject;

function NodeValueToIntDef(const AValue: TValue; const ADefault: Int64 = 0): Int64;

procedure CheckThreadStopped;

implementation

function NodeValueToColorDef(const AValue: TValue; const ADefault: TAlphaColor = TAlphaColors.Null): TAlphaColor;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  if AValue.IsType<TAlphaColor>then
    Result := AValue.AsType<TAlphaColor>
  else
    Result := ADefault;
end;

function NodeValueToFloatDef(const AValue: TValue; const ADefault: double): double;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkFloat:
      Result := AValue.AsExtended;
    tkInteger:
      Result := AValue.AsInteger;
    tkInt64:
      Result := AValue.AsInt64;
    tkLString, tkWString, tkUString, tkString:
      begin
        if not TryStrToFloat(AValue.AsString, Result, FormatSettings) then
          Result := ADefault;
      end;
  else
    Result := ADefault;
  end;
end;

function NodeValueToStringDef(const AValue: TValue; const ADefault: string): string;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkString, tkLString, tkWString, tkUString:
      Result := AValue.AsString;
    tkInteger:
      Result := AValue.AsInteger.ToString;
    tkInt64:
      Result := AValue.AsInt64.ToString;
    tkChar:
      Result := AValue.AsString;
    tkFloat:
      Result := AValue.AsExtended.ToString;
  else
    var B: Boolean;
    if AValue.TryAsType<Boolean>(B, False) then
      if B then
        Exit('True')
      else
        Exit('False');
    Result := ADefault;
  end;
end;

function MakeFloatValue(const AValue: double): TValue;
begin
  Result := AValue;
end;

function MakeColorValue(const AValue: TAlphaColor): TValue;
begin
  Result := AValue;
end;

function MakeBoolValue(const AValue: boolean): TValue;
begin
  Result := AValue;
end;

function MakeIntValue(const AValue: int64): TValue;
begin
  Result := AValue;
end;

function MakeBitmapValue(const AValue: IBitmapNodeObject): TValue;
begin
  Result := TValue.From<IBitmapNodeObject>(AValue);
end;

function MakeStringValue(const AValue: string): TValue;
begin
  Result := AValue;
end;

function NodeValueToBitmapDef(const AValue: TValue; const ADefault: IBitmapNodeObject = nil): IBitmapNodeObject;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  if AValue.IsType<IBitmapNodeObject>then
    Result := AValue.AsType<IBitmapNodeObject>
  else
    Result := ADefault;
end;

function NodeValueToBoolDef(const AValue: TValue; const ADefault: boolean): boolean;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkInteger:
      Result := AValue.AsInteger <> 0;
    tkInt64:
      Result := AValue.AsInt64 <> 0;
    tkFloat:
      Result := Abs(AValue.AsExtended) > 1e-12;
    tkString, tkLString, tkWString, tkUString:
      begin
        var S := Trim(LowerCase(AValue.AsString));
        Result := (S = 'true') or (S = '1') or (S = 'yes');
      end;
  else
    var B: Boolean;
    if AValue.TryAsType<Boolean>(B, False) then
      Exit(B);
    Result := ADefault;
  end;
end;

function NodeValueToIntDef(const AValue: TValue; const ADefault: Int64): Int64;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkInteger:
      Result := AValue.AsInteger;
    tkInt64:
      Result := AValue.AsInt64;
    tkFloat:
      Result := Trunc(AValue.AsExtended);
    tkString, tkLString, tkWString, tkUString:
      begin
        if not TryStrToInt64(AValue.AsString, Result) then
          Result := ADefault;
      end;
  else
    var B: Boolean;
    if AValue.TryAsType<Boolean>(B, False) then
      if B then
        Exit(1)
      else
        Exit(0);
    Result := ADefault;
  end;
end;

procedure CheckThreadStopped;
begin
  if (TThread.CurrentThread <> nil) and TThread.CurrentThread.CheckTerminated then
    raise ENodeExecutionStopped.Create('Execution stopped');
end;

{ TPinRuntimeValue }

constructor TPinRuntimeValue.Create;
begin
  inherited Create;
  State := TNodeValueState.Missing;
  Value := Default(TValue);
end;

{ TNodeExecutionContext }

constructor TNodeExecutionContext.Create(AGraph: TNodeGraph);
begin
  inherited Create;
  FGraph := AGraph;
  FPinValues := TObjectDictionary<TNodePin, TPinRuntimeValue>.Create([doOwnsValues]);
  FVariables := TDictionary<string, TValue>.Create;
  FEventQueue := TDictionary<string, TValue>.Create;
  FEventListeners := TDictionary<string, string>.Create;
  FTriggeredListeners := TDictionary<string, TValue>.Create;
  FMaxStepCount := 10000;
  FStepCounter := 0;
  FLastExecutedNode := nil;
  FLastExecOutputPin := nil;
  FDebugger := nil;
  FOnNodeExecuted := nil;
end;

destructor TNodeExecutionContext.Destroy;
begin
  FTriggeredListeners.Free;
  FEventListeners.Free;
  FEventQueue.Free;
  FVariables.Free;
  FPinValues.Free;
  inherited Destroy;
end;

procedure TNodeExecutionContext.Clear;
begin
  FPinValues.Clear;
  FVariables.Clear;
  FEventQueue.Clear;
  FEventListeners.Clear;
  FTriggeredListeners.Clear;
  FStepCounter := 0;
  FLastExecutedNode := nil;
  FLastExecOutputPin := nil;
end;

function TNodeExecutionContext.GetPinEntry(APin: TNodePin; ACreate: Boolean): TPinRuntimeValue;
begin
  Result := nil;
  if APin = nil then
    Exit;

  if not FPinValues.TryGetValue(APin, Result) then
  begin
    if ACreate then
    begin
      Result := TPinRuntimeValue.Create;
      FPinValues.Add(APin, Result);
    end;
  end;
end;

function TNodeExecutionContext.GetStepCounter: Integer;
begin
  Result := FStepCounter;
end;

function TNodeExecutionContext.HasPinValue(APin: TNodePin): Boolean;
begin
  var E := GetPinEntry(APin, False);
  Result := (E <> nil) and (E.State = TNodeValueState.Ready);
end;

function TNodeExecutionContext.TryGetPinValue(APin: TNodePin; out AValue: TValue): Boolean;
begin
  var E := GetPinEntry(APin, False);
  Result := (E <> nil) and (E.State = TNodeValueState.Ready);
  if Result then
    AValue := E.Value
  else
    AValue := Default(TValue);
end;

procedure TNodeExecutionContext.SetPinValue(APin: TNodePin; const AValue: TValue);
begin
  if APin = nil then
    Exit;
  var E := GetPinEntry(APin, True);
  E.Value := AValue;
  E.State := TNodeValueState.Ready;
end;

function TNodeExecutionContext.GetPinState(APin: TNodePin): TNodeValueState;
begin
  var E := GetPinEntry(APin, False);
  if E = nil then
    Result := TNodeValueState.Missing
  else
    Result := E.State;
end;

procedure TNodeExecutionContext.SetPinState(APin: TNodePin; AState: TNodeValueState);
begin
  if APin = nil then
    Exit;
  var E := GetPinEntry(APin, True);
  E.State := AState;
  if AState <> TNodeValueState.Ready then
    E.Value := Default(TValue);
end;

function TNodeExecutionContext.TryGetVariable(const AName: string; out AValue: TValue): Boolean;
begin
  Result := FVariables.TryGetValue(AName, AValue);
end;

procedure TNodeExecutionContext.SetVariable(const AName: string; const AValue: TValue);
begin
  if AName = '' then
    Exit;
  FVariables.AddOrSetValue(AName, AValue);
end;

function TNodeExecutionContext.GetVariableValue(const AName: string): TValue;
begin
  if not TryGetVariable(AName, Result) then
    Result := Default(TValue);
end;

function TNodeExecutionContext.GetVariableStr(const AName, ADefault: string): string;
begin
  Result := NodeValueToStringDef(GetVariableValue(AName), ADefault);
end;

function TNodeExecutionContext.GetVariableFloat(const AName: string; const ADefault: Double): Double;
begin
  Result := NodeValueToFloatDef(GetVariableValue(AName), ADefault);
end;

function TNodeExecutionContext.GetVariableBool(const AName: string; const ADefault: Boolean): Boolean;
begin
  var V := GetVariableValue(AName);
  if V.IsEmpty then
    Exit(ADefault);

  case V.Kind of
    tkInteger:
      Result := V.AsInteger <> 0;
    tkInt64:
      Result := V.AsInt64 <> 0;
    tkFloat:
      Result := Abs(V.AsExtended) > 1e-12;
    tkLString, tkWString, tkUString:
      begin
        var S := Trim(LowerCase(V.AsString));
        Result := (S = 'true') or (S = '1') or (S = 'yes');
      end;
  else
    if not V.TryAsType<Boolean>(Result) then
      Result := ADefault;
  end;
end;

procedure TNodeExecutionContext.SetVariableStr(const AName, AValue: string);
begin
  SetVariable(AName, MakeStringValue(AValue));
end;

procedure TNodeExecutionContext.SetVariableFloat(const AName: string; const AValue: Double);
begin
  SetVariable(AName, MakeFloatValue(AValue));
end;

procedure TNodeExecutionContext.SetVariableBool(const AName: string; const AValue: Boolean);
begin
  SetVariable(AName, MakeBoolValue(AValue));
end;

function TNodeExecutionContext.GetInputValue(APin: TNodePin): TValue;
begin
  if FGraph = nil then
    raise ENodeExecutionError.Create('Execution context has no graph');
  Result := FGraph.GetInputPinValue(APin, Self);
end;

function TNodeExecutionContext.GetInputValueOrVar(APin: TNodePin; const VarName: string): TValue;
begin
  Result := TValue.Empty;
  var FValue := GetInputValue(APin);
  if not FValue.IsEmpty then
    Result := FValue
  else
  begin
    var VFrom := APin.OwnerNode.FindValue(VarName);
    if VFrom <> nil then
    begin
      case VFrom.Kind of
        TNodeValueKind.Null:
          ;
        TNodeValueKind.Float:
          Result := VFrom.FloatValue;
        TNodeValueKind.Integer:
          Result := VFrom.IntegerValue;
        TNodeValueKind.string:
          Result := VFrom.StringValue;
        TNodeValueKind.Boolean:
          Result := VFrom.BooleanValue;
        TNodeValueKind.JSON:
          Result := VFrom.JSONValue;
        TNodeValueKind.Color:
          Result := VFrom.ColorValue;
        TNodeValueKind.Bitmap:
          Result := TValue.From<IBitmapNodeObject>(VFrom.BitmapValue);
        TNodeValueKind.Point:
          Result := TValue.From(VFrom.PointValue);
      end;
    end;
  end;
end;

procedure TNodeExecutionContext.SetOutputValue(APin: TNodePin; const AValue: TValue);
begin
  if APin = nil then
    Exit;
  if APin.Direction <> TPinDirection.Output then
    raise ENodeExecutionError.Create('SetOutputValue expects output pin');
  SetPinValue(APin, AValue);
end;

procedure TNodeExecutionContext.RaiseEvent(const AEventName: string; const AData: TValue);
begin
  if Trim(AEventName) = '' then
    Exit;

  FEventQueue.AddOrSetValue(AEventName, AData);

  for var Pair in FEventListeners do
    if SameText(Pair.Value, AEventName) then
      FTriggeredListeners.AddOrSetValue(Pair.Key, AData);
end;

procedure TNodeExecutionContext.RegisterEventListener(const AListenerId, AEventName: string);
begin
  if (Trim(AListenerId) = '') or (Trim(AEventName) = '') then
    Exit;

  FEventListeners.AddOrSetValue(AListenerId, AEventName);

  var Data: TValue;
  if FEventQueue.TryGetValue(AEventName, Data) then
    FTriggeredListeners.AddOrSetValue(AListenerId, Data);
end;

function TNodeExecutionContext.WasListenerTriggered(const AListenerId: string; out AData: TValue): Boolean;
begin
  Result := FTriggeredListeners.TryGetValue(AListenerId, AData);
end;

procedure TNodeExecutionContext.IncStep;
begin
  CheckThreadStopped;
  Inc(FStepCounter);
  if (FMaxStepCount > 0) and (FStepCounter > FMaxStepCount) then
    raise ENodeStepLimit.CreateFmt('Execution step limit exceeded (%d)', [FMaxStepCount]);
end;

procedure TNodeExecutionContext.Print(const Text: string);
begin
  //
end;

procedure TNodeExecutionContext.SelectExecOutput(APin: TNodePin);
begin
  if (APin <> nil) and (APin.Direction <> TPinDirection.Output) then
    raise ENodeExecutionError.Create('Selected exec output must be output pin');
  FLastExecOutputPin := APin;
end;

{ TExecutableNode }

function TExecutableNode.GetExecInputPin: TNodePin;
begin
  Result := nil;
  for var i := 0 to InputCount - 1 do
  begin
    var P := GetInput(i);
    if (P <> nil) and (P.Kind = TPinKind.Exec) then
      Exit(P);
  end;
end;

procedure TExecutableNode.Execute(AContext: TNodeExecutionContext);
begin
end;

{ TNodeGraphRuntimeHelper }

function TNodeGraphRuntimeHelper.FindIncomingLink(APin: TNodePin): TNodeLink;
begin
  Result := nil;
  if APin = nil then
    Exit;

  for var i := 0 to Links.Count - 1 do
  begin
    var L := Links[i];
    if (L <> nil) and (L.ToPin = APin) then
      Exit(L);
  end;
end;

function TNodeGraphRuntimeHelper.FindOutgoingLinks(APin: TNodePin; AList: TList<TNodeLink>): integer;
begin
  Result := 0;
  if (APin = nil) or (AList = nil) then
    Exit;

  AList.Clear;
  for var i := 0 to Links.Count - 1 do
  begin
    var L := Links[i];
    if (L <> nil) and (L.FromPin = APin) then
      AList.Add(L);
  end;
  Result := AList.Count;
end;

function TNodeGraphRuntimeHelper.GetInputPinValue(APin: TNodePin; AContext: TNodeExecutionContext): TValue;
begin
  Result := Default(TValue);

  if APin = nil then
    Exit;

  if APin.Direction <> TPinDirection.Input then
    raise ENodeExecutionError.Create('GetInputPinValue expects input pin: ' + APin.Name);

  var L := FindIncomingLink(APin);
  if (L <> nil) and (L.FromPin <> nil) then
    Exit(EvaluatePinValue(L.FromPin, AContext));

  if Trim(APin.DefaultValue) <> '' then
  begin
    if SameText(APin.DataType, 'float') then
    begin
      var DefValue: Double;
      if TryStrToFloat(APin.DefaultValue, DefValue, FormatSettings) then
        Exit(MakeFloatValue(DefValue));
    end
    else if SameText(APin.DataType, 'string') then
      Exit(MakeStringValue(APin.DefaultValue))
    else if SameText(APin.DataType, 'bool') then
      Exit(MakeBoolValue(SameText(APin.DefaultValue, 'true') or
          (APin.DefaultValue = '1')));
  end;
              {
  if SameText(APin.DataType, 'float') then
    Exit(MakeFloatValue(0.0));

  if SameText(APin.DataType, 'bool') then
    Exit(MakeBoolValue(False));

  if SameText(APin.DataType, 'string') then
    Exit(MakeStringValue(''));    }
end;

function TNodeGraphRuntimeHelper.GetInputPinValueByIndex(ANode: TCustomNode; AIndex: integer; AContext: TNodeExecutionContext): TValue;
begin
  if ANode = nil then
    raise ENodeExecutionError.Create('Node is nil');

  var P := ANode.GetInput(AIndex);
  if P = nil then
    raise ENodeExecutionError.CreateFmt('Input pin index %d out of range for node "%s"', [AIndex, ANode.Title]);

  Result := GetInputPinValue(P, AContext);
end;

function TNodeGraphRuntimeHelper.EvaluatePinValue(APin: TNodePin; AContext: TNodeExecutionContext): TValue;
begin
  CheckThreadStopped;
  Result := Default(TValue);

  if APin = nil then
    Exit;

  if AContext = nil then
    raise ENodeExecutionError.Create('Execution context is nil');

  var Cached: TValue;
  if AContext.TryGetPinValue(APin, Cached) then
    Exit(Cached);

  if AContext.GetPinState(APin) = TNodeValueState.Evaluating then
    raise ENodeCycleDetected.CreateFmt('Cycle detected while evaluating pin "%s" of node "%s"', [APin.Name, if APin.OwnerNode <> nil then TCustomNode(APin.OwnerNode).Title else '?']);

  if APin.Direction = TPinDirection.Input then
    Exit(GetInputPinValue(APin, AContext));

  var OwnerNode := APin.OwnerNode;
  if OwnerNode = nil then
    raise ENodeExecutionError.Create('Output pin has no owner node');

  AContext.SetPinState(APin, TNodeValueState.Evaluating);
  try
    Result := EvaluateNodeOutput(OwnerNode, APin, AContext);
    AContext.SetPinValue(APin, Result);
  except
    AContext.SetPinState(APin, TNodeValueState.Missing);
    raise;
  end;
end;

function TNodeGraphRuntimeHelper.EvaluateNodeOutput(ANode: TCustomNode; APin: TNodePin; AContext: TNodeExecutionContext): TValue;
begin
  Result := Default(TValue);

  if (ANode = nil) or (APin = nil) then
    Exit;

  if AContext = nil then
    raise ENodeExecutionError.Create('Execution context is nil');

  if AContext.TryGetPinValue(APin, Result) then
    Exit;

  if ANode is TExecutableNode then
  begin
    var ExecNode := TExecutableNode(ANode);

    AContext.IncStep;
    AContext.LastExecutedNode := ANode;
    AContext.LastExecOutputPin := nil;

    ExecNode.Execute(AContext);

    if AContext.TryGetPinValue(APin, Result) then
      Exit;

    if APin.Kind = TPinKind.Data then
      raise ENodeExecutionError.CreateFmt('Node "%s" did not produce value for output pin "%s"', [ANode.Title, APin.Name]);

    Exit(Default(TValue));
  end;

  if SameText(ANode.NodeType, 'float') then
  begin
    if not SameText(APin.Name, 'Value') and (ANode.OutputCount > 0) and
      (APin <> ANode.GetOutput(0)) then
      raise ENodeExecutionError.CreateFmt('Unsupported output pin "%s" for node "%s"', [APin.Name, ANode.Title]);

    var V := ANode.FindValue('value');
    if V = nil then
      Exit(MakeFloatValue(0.0));

    case V.Kind of
      TNodeValueKind.Float:
        Result := MakeFloatValue(V.FloatValue);
      TNodeValueKind.Integer:
        Result := MakeIntValue(V.IntegerValue);
      TNodeValueKind.Boolean:
        Result := MakeBoolValue(V.BooleanValue);
      TNodeValueKind.string:
        Result := MakeStringValue(V.StringValue);
    else
      Result := MakeFloatValue(0.0);
    end;
    Exit;
  end;

  if SameText(ANode.NodeType, 'add') then
  begin
    var AValue := GetInputPinValueByIndex(ANode, 0, AContext);
    var BValue := GetInputPinValueByIndex(ANode, 1, AContext);

    var AFloat := NodeValueToFloatDef(AValue, 0.0);
    var BFloat := NodeValueToFloatDef(BValue, 0.0);

    Result := MakeFloatValue(AFloat + BFloat);
    Exit;
  end;

  if SameText(ANode.NodeType, 'reroute') then
  begin
    Result := GetInputPinValueByIndex(ANode, 0, AContext);
    Exit;
  end;

  if SameText(ANode.NodeType, 'default') then
  begin
    if ANode.InputCount > 0 then
      Result := GetInputPinValueByIndex(ANode, 0, AContext)
    else
      Result := Default(TValue);
    Exit;
  end;

  if SameText(ANode.NodeType, 'comment') then
  begin
    Result := Default(TValue);
    Exit;
  end;

  raise ENodeExecutionError.CreateFmt('Runtime evaluator for node type "%s" is not implemented', [ANode.NodeType]);
end;

function TNodeGraphRuntimeHelper.ExecuteDataFlow(AContext: TNodeExecutionContext): boolean;
begin
  if HasCycle then
    raise ENodeCycleDetected.Create('Graph contains cycle');

  var OwnContext := AContext = nil;
  var Ctx := if OwnContext then TNodeExecutionContext.Create(Self)else AContext;

  var Order := TList<TCustomNode>.Create;
  try
    TopologicalSortDataNodes(Order);

    for var i := 0 to Order.Count - 1 do
    begin
      CheckThreadStopped;
      var N := Order[i];
      if (N = nil) or (N.VisualKind = TNodeVisualKind.Comment) then
        Continue;

      if (Ctx.Debugger <> nil) and Ctx.Debugger.CheckPause(N, nil, Ctx) then
        raise ENodeDebuggerPause.Create('Execution paused by debugger');

      for var j := 0 to N.OutputCount - 1 do
      begin
        CheckThreadStopped;
        var P := N.GetOutput(j);
        if (P <> nil) and (P.Kind = TPinKind.Data) then
          EvaluatePinValue(P, Ctx);
      end;
    end;

    Result := True;
  finally
    Order.Free;
    if OwnContext then
      Ctx.Free;
  end;
end;

function TNodeGraphRuntimeHelper.FindExecOutgoingLinks(APin: TNodePin; AList: TList<TNodeLink>): integer;
begin
  Result := 0;
  if (APin = nil) or (AList = nil) then
    Exit;

  AList.Clear;
  for var i := 0 to Links.Count - 1 do
  begin
    var L := Links[i];
    if (L <> nil) and (L.FromPin = APin) and (L.FromPin.Kind = TPinKind.Exec) and
      (L.ToPin <> nil) and (L.ToPin.Kind = TPinKind.Exec) then
      AList.Add(L);
  end;
  Result := AList.Count;
end;

function TNodeGraphRuntimeHelper.FindFirstConnectedExecOutput(ANode: TCustomNode): TNodePin;
begin
  Result := nil;
  if ANode = nil then
    Exit;

  var Tmp := TList<TNodeLink>.Create;
  try
    for var i := 0 to ANode.OutputCount - 1 do
    begin
      var P := ANode.GetOutput(i);
      if (P <> nil) and (P.Kind = TPinKind.Exec) then
      begin
        if FindExecOutgoingLinks(P, Tmp) > 0 then
          Exit(P);
      end;
    end;
  finally
    Tmp.Free;
  end;
end;

function TNodeGraphRuntimeHelper.ExecuteExecPin(APin: TNodePin; AContext: TNodeExecutionContext): boolean;
begin
  CheckThreadStopped;
  Result := False;

  if (APin = nil) or (AContext = nil) then
    Exit;

  if APin.Kind <> TPinKind.Exec then
    raise ENodeExecutionError.Create('ExecuteExecPin expects exec output pin');

  AContext.LastExecOutputPin := APin;

  if AContext.Debugger <> nil then
    AContext.Debugger.AddTraceEntry('exec-out', APin.OwnerNode, APin, AContext);

  var L := TList<TNodeLink>.Create;
  try
    FindExecOutgoingLinks(APin, L);
    if L.Count = 0 then
      Exit(True);

    Result := True;
    for var i := 0 to L.Count - 1 do
    begin
      var Link := L[i];
      if (Link <> nil) and (Link.ToPin <> nil) then
      begin
        var NextNode := Link.ToPin.OwnerNode;
        if NextNode <> nil then
        begin
          if AContext.Debugger <> nil then
            AContext.Debugger.AddTraceEntry('exec-in', NextNode, Link.ToPin, AContext);
          if not ExecuteFromNode(NextNode, AContext) then
            Result := False;
        end;
      end;
    end;
  finally
    L.Free;
  end;
end;

function TNodeGraphRuntimeHelper.ExecuteFromNode(ANode: TCustomNode; AContext: TNodeExecutionContext): boolean;
begin
  CheckThreadStopped;
  Result := False;

  if (ANode = nil) or (AContext = nil) then
    Exit;

  if AContext.Debugger <> nil then
  begin
    if AContext.Debugger.CheckPause(ANode, nil, AContext) then
      raise ENodeDebuggerPause.Create('Execution paused by debugger');

    AContext.Debugger.PushNode(ANode);
    AContext.Debugger.AddTraceEntry('enter-node', ANode, nil, AContext);
  end;

  try
    AContext.IncStep;
    AContext.LastExecutedNode := ANode;
    AContext.LastExecOutputPin := nil;

    if not (ANode is TExecutableNode) then
      Exit(True);

    var ExecNode := TExecutableNode(ANode);
    ExecNode.Execute(AContext);

    if Assigned(AContext.OnNodeExecuted) then
      AContext.OnNodeExecuted(AContext, ExecNode);

    if AContext.Debugger <> nil then
      AContext.Debugger.AddTraceEntry('executed', ANode, nil, AContext);

    var NextExecPin := nil;
    if (AContext.LastExecOutputPin <> nil) and
      (AContext.LastExecOutputPin.OwnerNode <> nil) and
      (AContext.LastExecOutputPin.OwnerNode = ANode) then
      NextExecPin := AContext.LastExecOutputPin;

    if NextExecPin <> nil then
      Result := ExecuteExecPin(NextExecPin, AContext)
    else
      Result := True;
  finally
    if AContext.Debugger <> nil then
    begin
      AContext.Debugger.AddTraceEntry('leave-node', ANode, nil, AContext);
      AContext.Debugger.PopNode(ANode);
    end;
  end;
end;

end.

