{
  Copyright (c) 2026 Aleksandr Vorobev aka CynicRus (CynicRus@gmail.com)

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
}
unit FMX.NodeEditor.Executor;

interface

uses
  Classes, SysUtils, Rtti, FMX.NodeEditor.Types, FMX.NodeEditor.Node,
  FMX.NodeEditor.Node.Graph, FMX.NodeEditor.Runtime, FMX.NodeEditor.Debugger;

{$SCOPEDENUMS ON}

type
  //TExecutionMode = (DataFlow, ControlFlow, Mixed);

  TGraphExecutionError = (
    None,
    GraphIsNil,
    InvalidStartNode,
    DataCycleDetected,
    NodeEvaluationFailed,
    PinEvaluationFailed,
    ExecStepLimitExceeded
    );

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

    function ExecuteAllDataFlow: boolean;
    function ExecuteFromNode(ANode: TCustomNode): boolean;
    function ExecuteFromExecPin(APin: TNodePin): boolean;

    function EvaluatePin(APin: TNodePin; out AValue: TValue): boolean;
    function EvaluateNodeOutputs(ANode: TCustomNode): boolean;

    procedure ResetContext;
  end;

implementation

constructor TGraphExecutor.Create(AGraph: TNodeGraph);
begin
  inherited Create;
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

function TGraphExecutor.ExecuteAllDataFlow: boolean;
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

function TGraphExecutor.ExecuteFromNode(ANode: TCustomNode): boolean;
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

function TGraphExecutor.ExecuteFromExecPin(APin: TNodePin): boolean;
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

function TGraphExecutor.EvaluatePin(APin: TNodePin; out AValue: TValue): boolean;
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

function TGraphExecutor.EvaluateNodeOutputs(ANode: TCustomNode): boolean;
var
  i: Integer;
  V: TValue;
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
    for i := 0 to ANode.OutputCount - 1 do
      V := FGraph.EvaluatePinValue(ANode.GetOutput(i), Context);
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

