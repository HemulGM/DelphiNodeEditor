unit FMX.NodeEditor.Executor;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, FMX.NodeEditor.Types,
  FMX.NodeEditor.Node, FMX.NodeEditor.Graph, FMX.NodeEditor.Executor.Runtime,
  FMX.NodeEditor.Debugger;

type
  ENodeEditorExecutorException = class(ENodeEditorException);

  TGraphExecutor = class
  private
    FGraph: TNodeGraph;
    FContext: TNodeExecutionContext;
    FLastError: TGraphExecutionError;
    FLastErrorMessage: string;
    FDebugger: TGraphDebugger;

    procedure SetError(AError: TGraphExecutionError; const AMsg: string);
    procedure ClearError;
    function GetContext: TNodeExecutionContext;
  public
    constructor Create(AGraph: TNodeGraph);
    destructor Destroy; override;

    property Context: TNodeExecutionContext read GetContext;
    property Debugger: TGraphDebugger read FDebugger write FDebugger;
    property LastError: TGraphExecutionError read FLastError;
    property LastErrorMessage: string read FLastErrorMessage;

    function ExecuteAllDataFlow: Boolean;
    function ExecuteFromNode(ANode: TCustomNode): Boolean;
    function ExecuteFromExecPin(APin: TNodePin): Boolean;

    function EvaluatePin(APin: TNodePin; out AValue: TValue): Boolean;
    function EvaluateNodeOutputs(ANode: TCustomNode): Boolean;

    procedure ResetContext;
  end;

implementation

{ TGraphExecutor }

constructor TGraphExecutor.Create(AGraph: TNodeGraph);
begin
  inherited Create;
  if AGraph = nil then
    raise ENodeEditorExecutorException.Create('Graph can''t be nil');

  FGraph := AGraph;
  FContext := nil;
  FDebugger := nil;
  ClearError;
end;

destructor TGraphExecutor.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

procedure TGraphExecutor.SetError(AError: TGraphExecutionError; const AMsg: string);
begin
  FLastError := AError;
  FLastErrorMessage := AMsg;
end;

procedure TGraphExecutor.ClearError;
begin
  FLastError := TGraphExecutionError.None;
  FLastErrorMessage := '';
end;

function TGraphExecutor.GetContext: TNodeExecutionContext;
begin
  if FContext = nil then
    FContext := TNodeExecutionContext.Create(FGraph);

  FContext.Debugger := FDebugger;
  Result := FContext;
end;

function TGraphExecutor.ExecuteAllDataFlow: Boolean;
begin
  Result := False;
  ClearError;

  if FGraph = nil then
  begin
    SetError(TGraphExecutionError.GraphIsNil, 'Graph is nil');
    Exit;
  end;

  try
    Context.Clear;
    Context.Debugger := FDebugger;
    if FDebugger <> nil then
      FDebugger.ResetSession;

    Result := FGraph.ExecuteDataFlow(Context);
  except
    on E: ENodeCycleDetected do
    begin
      SetError(TGraphExecutionError.DataCycleDetected, E.Message);
      Exit(False);
    end;
    on E: ENodeDebuggerPause do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: ENodeExecutionError do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: Exception do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
  end;
end;

function TGraphExecutor.ExecuteFromNode(ANode: TCustomNode): Boolean;
begin
  Result := False;
  ClearError;

  if FGraph = nil then
  begin
    SetError(TGraphExecutionError.GraphIsNil, 'Graph is nil');
    Exit;
  end;

  if ANode = nil then
  begin
    SetError(TGraphExecutionError.InvalidStartNode, 'Start node is nil');
    Exit;
  end;

  try
    Context.Debugger := FDebugger;
    if FDebugger <> nil then
      FDebugger.ResetSession;

    Result := FGraph.ExecuteFromNode(ANode, Context);
  except
    on E: ENodeDebuggerPause do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: ENodeStepLimit do
    begin
      SetError(TGraphExecutionError.ExecStepLimitExceeded, E.Message);
      Exit(False);
    end;
    on E: ENodeExecutionError do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: Exception do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
  end;
end;

function TGraphExecutor.ExecuteFromExecPin(APin: TNodePin): Boolean;
begin
  Result := False;
  ClearError;

  if FGraph = nil then
  begin
    SetError(TGraphExecutionError.GraphIsNil, 'Graph is nil');
    Exit;
  end;

  if (APin = nil) or (APin.Kind <> TPinKind.Exec) or (APin.Direction <> TPinDirection.Output) then
  begin
    SetError(TGraphExecutionError.InvalidStartNode, 'Exec output pin expected');
    Exit;
  end;

  try
    Context.Debugger := FDebugger;
    if FDebugger <> nil then
      FDebugger.ResetSession;

    Result := FGraph.ExecuteExecPin(APin, Context);
  except
    on E: ENodeDebuggerPause do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: ENodeStepLimit do
    begin
      SetError(TGraphExecutionError.ExecStepLimitExceeded, E.Message);
      Exit(False);
    end;
    on E: ENodeExecutionError do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: Exception do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
  end;
end;

function TGraphExecutor.EvaluatePin(APin: TNodePin; out AValue: TValue): Boolean;
begin
  Result := False;
  ClearError;
  AValue := Default(TValue);

  if FGraph = nil then
  begin
    SetError(TGraphExecutionError.GraphIsNil, 'Graph is nil');
    Exit;
  end;

  try
    Context.Debugger := FDebugger;
    AValue := FGraph.EvaluatePinValue(APin, Context);
    Result := True;
  except
    on E: ENodeExecutionError do
    begin
      SetError(TGraphExecutionError.PinEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: Exception do
    begin
      SetError(TGraphExecutionError.PinEvaluationFailed, E.Message);
      Exit(False);
    end;
  end;
end;

function TGraphExecutor.EvaluateNodeOutputs(ANode: TCustomNode): Boolean;
begin
  Result := False;
  ClearError;

  if FGraph = nil then
  begin
    SetError(TGraphExecutionError.GraphIsNil, 'Graph is nil');
    Exit;
  end;

  if ANode = nil then
  begin
    SetError(TGraphExecutionError.NodeEvaluationFailed, 'Node is nil');
    Exit;
  end;

  try
    Context.Debugger := FDebugger;
    for var i := 0 to ANode.OutputCount - 1 do
      FGraph.EvaluatePinValue(ANode.GetOutput(i), Context);
    Result := True;
  except
    on E: ENodeExecutionError do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
    on E: Exception do
    begin
      SetError(TGraphExecutionError.NodeEvaluationFailed, E.Message);
      Exit(False);
    end;
  end;
end;

procedure TGraphExecutor.ResetContext;
begin
  FreeAndNil(FContext);
end;

end.

