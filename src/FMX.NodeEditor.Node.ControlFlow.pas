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
unit FMX.NodeEditor.Node.ControlFlow;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, System.Generics.Collections,
  FMX.NodeEditor.Types, FMX.NodeEditor.Node, FMX.NodeEditor.Graph,
  FMX.NodeEditor.Executor.Runtime;

type
  TBranchNode = class(TExecutableNode)
  private
    FConditionPin: TNodePin;
    FTrueExecPin, FFalseExecPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TLoopNode = class(TExecutableNode)
  private
    FConditionPin: TNodePin;
    FBodyExecPin, FExitExecPin: TNodePin;
    FIndexPin, FFirstIterationPin, FLastIterationPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TForLoopNode = class(TExecutableNode)
  private
    FStartPin, FEndPin, FStepPin: TNodePin;
    FBodyExecPin, FExitExecPin: TNodePin;
    FIndexPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSequenceNode = class(TExecutableNode)
  private
    FSteps: array of TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
    procedure AddStep;
    procedure RemoveLastStep;
    function StepCount: integer;
  end;

  TBreakNode = class(TExecutableNode)
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TContinueNode = class(TExecutableNode)
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSwitchNode = class(TExecutableNode)
  private
    FValuePin: TNodePin;
    FCases: array of record
      ValuePin: TNodePin;
      ExecPin: TNodePin;
    end;
    FDefaultExecPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
    procedure AddCase;
  end;

  TWaitNode = class(TExecutableNode)
  private
    FDurationPin: TNodePin;
    FDoneExecPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TEventNode = class(TExecutableNode)
  private
    FTriggerExecPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Trigger(AContext: TNodeExecutionContext = nil);
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TEventCallNode = class(TExecutableNode)
  private
    FEventNamePin: TNodePin;
    FDataPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TEventListenerNode = class(TExecutableNode)
  private
    FEventNamePin: TNodePin;
    FDataOutputPin: TNodePin;
    FTriggeredExecPin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

procedure RegisterControlFlowNodes(Registry: TNodeRegistry);

implementation

procedure RegisterControlFlowNodes(Registry: TNodeRegistry);
begin
  if Registry = nil then
    Exit;

  Registry.RegisterNodeEx('branch', 'Branch', 'Control Flow',
    'Conditional branch by boolean condition',
    'if,branch,condition,true,false', '',
    TBranchNode, $FFFFE082);

  Registry.RegisterNodeEx('loop', 'Loop', 'Control Flow',
    'While-like loop with condition input and body/exit exec outputs',
    'loop,while,cycle,iteration', '',
    TLoopNode, $FFFFCC80);

  Registry.RegisterNodeEx('forloop', 'For Loop', 'Control Flow',
    'For loop with start, end and step',
    'for,loop,cycle,iteration,index', '',
    TForLoopNode, $FFFFCC80);

  Registry.RegisterNodeEx('sequence', 'Sequence', 'Control Flow',
    'Executes several exec outputs one by one',
    'sequence,steps,order,exec', '',
    TSequenceNode, $FFB39DDB);

  Registry.RegisterNodeEx('break', 'Break', 'Control Flow',
    'Break current loop',
    'break,loop,stop', '',
    TBreakNode, $FFEF9A9A);

  Registry.RegisterNodeEx('continue', 'Continue', 'Control Flow',
    'Continue current loop iteration',
    'continue,loop,skip', '',
    TContinueNode, $FF90CAF9);

  Registry.RegisterNodeEx('switch', 'Switch', 'Control Flow',
    'Selects exec output by input value',
    'switch,case,branch,select', '',
    TSwitchNode, $FFCE93D8);

  Registry.RegisterNodeEx('wait', 'Wait', 'Control Flow',
    'Wait for specified duration in milliseconds',
    'wait,delay,sleep,timer', '',
    TWaitNode, $FFA5D6A7);

  Registry.RegisterNodeEx('event', 'Event', 'Events',
    'Event source node',
    'event,trigger,signal', '',
    TEventNode, $FF80CBC4);

  Registry.RegisterNodeEx('eventcall', 'Call Event', 'Events',
    'Raise named event with payload',
    'event,call,emit,signal', '',
    TEventCallNode, $FF80CBC4);

  Registry.RegisterNodeEx('eventlistener', 'Event Listener', 'Events',
    'Listen named event and output payload when triggered',
    'event,listener,subscribe,signal', '',
    TEventListenerNode, $FF80CBC4);
end;

{ TBranchNode }

constructor TBranchNode.Create;
begin
  inherited;
  Width := 180;
  Height := 120;
  NodeType := 'branch';
end;

procedure TBranchNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Exec', 'exec', TPinKind.Exec);
  FConditionPin := AddInputPin('Condition', 'bool', TPinKind.Data);
  FTrueExecPin := AddOutputPin('True', 'exec', TPinKind.Exec);
  FFalseExecPin := AddOutputPin('False', 'exec', TPinKind.Exec);
end;

procedure TBranchNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  var Cond := NodeValueToBoolDef(AContext.GetInputValue(FConditionPin), False);
  AContext.SetVariableBool('BranchResult_' + Self.Id, Cond);

  if Cond then
    AContext.SelectExecOutput(FTrueExecPin)
  else
    AContext.SelectExecOutput(FFalseExecPin);
end;

{ TLoopNode }

constructor TLoopNode.Create;
begin
  inherited;
  Width := 220;
  Height := 160;
  NodeType := 'loop';
end;

procedure TLoopNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Enter', 'exec', TPinKind.Exec);
  FConditionPin := AddInputPin('Condition', 'bool', TPinKind.Data);
  FBodyExecPin := AddOutputPin('Body', 'exec', TPinKind.Exec);
  FExitExecPin := AddOutputPin('Exit', 'exec', TPinKind.Exec);
  FIndexPin := AddOutputPin('Index', 'integer', TPinKind.Data);
  FFirstIterationPin := AddOutputPin('First', 'bool', TPinKind.Data);
  FLastIterationPin := AddOutputPin('Last', 'bool', TPinKind.Data);
end;

procedure TLoopNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  var Iter: Int64 := 0;
  while True do
  begin
    CheckThreadStopped;

    if not NodeValueToBoolDef(AContext.GetInputValue(FConditionPin), False) then
      Break;

    AContext.SetOutputValue(FIndexPin, MakeIntValue(Iter));
    AContext.SetOutputValue(FFirstIterationPin, MakeBoolValue(Iter = 0));
    AContext.SetOutputValue(FLastIterationPin, MakeBoolValue(False));

    try
      AContext.Graph.ExecuteExecPin(FBodyExecPin, AContext);
    except
      on E: ENodeContinueSignal do
      begin
      end;
      on E: ENodeBreakSignal do
        Break;
    end;

    Inc(Iter);
  end;

  AContext.SetOutputValue(FLastIterationPin, MakeBoolValue(True));
  AContext.SelectExecOutput(FExitExecPin);
end;

{ TForLoopNode }

constructor TForLoopNode.Create;
begin
  inherited;
  Width := 200;
  Height := 150;
  NodeType := 'forloop';
end;

procedure TForLoopNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Enter', 'exec', TPinKind.Exec);
  FStartPin := AddInputPin('Start', 'integer', TPinKind.Data);
  FEndPin := AddInputPin('End', 'integer', TPinKind.Data);
  FStepPin := AddInputPin('Step', 'integer', TPinKind.Data);
  FBodyExecPin := AddOutputPin('Body', 'exec', TPinKind.Exec);
  FExitExecPin := AddOutputPin('Exit', 'exec', TPinKind.Exec);
  FIndexPin := AddOutputPin('Index', 'integer', TPinKind.Data);
end;

procedure TForLoopNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  var StartVal := NodeValueToIntDef(AContext.GetInputValue(FStartPin), 0);
  var EndVal := NodeValueToIntDef(AContext.GetInputValue(FEndPin), 0);
  var StepVal := NodeValueToIntDef(AContext.GetInputValue(FStepPin), 1);

  if StepVal = 0 then
    StepVal := 1;

  var I := StartVal;
  while (((StepVal > 0) and (I <= EndVal)) or ((StepVal < 0) and (I >= EndVal))) do
  begin
    CheckThreadStopped;

    AContext.SetVariable('last_for_index_' + Self.Id, MakeIntValue(I));
    AContext.SetVariable('last_for_index', MakeIntValue(I));
    AContext.SetOutputValue(FIndexPin, MakeIntValue(I));
    try
      AContext.Graph.ExecuteExecPin(FBodyExecPin, AContext);
    except
      on E: ENodeContinueSignal do
      begin
      end;
      on E: ENodeBreakSignal do
        Break;
    end;

    Inc(I, StepVal);
  end;

  AContext.SelectExecOutput(FExitExecPin);
end;

{ TSequenceNode }

constructor TSequenceNode.Create;
begin
  inherited;
  Width := 200;
  Height := 140;
  NodeType := 'sequence';
end;

procedure TSequenceNode.SetupPins;
begin
  ClearPins;
  SetLength(FSteps, 0);
  AddInputPin('Exec', 'exec', TPinKind.Exec);
  AddStep;
  AddStep;
  AddStep;
end;

procedure TSequenceNode.AddStep;
begin
  var NewPin := AddOutputPin('Step ' + IntToStr(Length(FSteps) + 1), 'exec', TPinKind.Exec);
  SetLength(FSteps, Length(FSteps) + 1);
  FSteps[High(FSteps)] := NewPin;
end;

procedure TSequenceNode.RemoveLastStep;
begin
  if Length(FSteps) = 0 then
    Exit;
  RemovePin(FSteps[High(FSteps)]);
  SetLength(FSteps, Length(FSteps) - 1);
end;

function TSequenceNode.StepCount: integer;
begin
  Result := Length(FSteps);
end;

procedure TSequenceNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  for var I := 0 to High(FSteps) do
  begin
    CheckThreadStopped;
    if FSteps[I] <> nil then
      AContext.Graph.ExecuteExecPin(FSteps[I], AContext);
  end;

  AContext.SelectExecOutput(nil);
end;

{ TBreakNode }

constructor TBreakNode.Create;
begin
  inherited;
  Width := 140;
  Height := 80;
  NodeType := 'break';
end;

procedure TBreakNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Exec', 'exec', TPinKind.Exec);
end;

procedure TBreakNode.Execute(AContext: TNodeExecutionContext);
begin
  raise ENodeBreakSignal.Create('Break');
end;

{ TContinueNode }

constructor TContinueNode.Create;
begin
  inherited;
  Width := 140;
  Height := 80;
  NodeType := 'continue';
end;

procedure TContinueNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Exec', 'exec', TPinKind.Exec);
end;

procedure TContinueNode.Execute(AContext: TNodeExecutionContext);
begin
  raise ENodeContinueSignal.Create('Continue');
end;

{ TSwitchNode }

constructor TSwitchNode.Create;
begin
  inherited;
  Width := 220;
  Height := 180;
  NodeType := 'switch';
end;

procedure TSwitchNode.SetupPins;
begin
  ClearPins;
  SetLength(FCases, 0);
  AddInputPin('Exec', 'exec', TPinKind.Exec);
  FValuePin := AddInputPin('Value', 'any', TPinKind.Data);
  FDefaultExecPin := AddOutputPin('Default', 'exec', TPinKind.Exec);
  AddCase;
  AddCase;
end;

procedure TSwitchNode.AddCase;
begin
  var Idx := Length(FCases);
  SetLength(FCases, Idx + 1);
  FCases[Idx].ValuePin := AddInputPin('CaseValue' + IntToStr(Idx), 'any', TPinKind.Data);
  FCases[Idx].ExecPin := AddOutputPin('Case' + IntToStr(Idx), 'exec', TPinKind.Exec);
end;

procedure TSwitchNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  CheckThreadStopped;
  var Value := NodeValueToStringDef(AContext.GetInputValue(FValuePin), '');

  for var I := 0 to High(FCases) do
  begin
    var CaseValue := NodeValueToStringDef(AContext.GetInputValue(FCases[I].ValuePin), '');
    if SameText(CaseValue, Value) then
    begin
      AContext.SetVariable('SwitchCase_' + Self.Id, MakeIntValue(I));
      AContext.SelectExecOutput(FCases[I].ExecPin);
      Exit;
    end;
  end;

  AContext.SetVariable('SwitchCase_' + Self.Id, MakeIntValue(-1));
  AContext.SelectExecOutput(FDefaultExecPin);
end;

{ TWaitNode }

constructor TWaitNode.Create;
begin
  inherited;
  Width := 160;
  Height := 100;
  NodeType := 'wait';
end;

procedure TWaitNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Exec', 'exec', TPinKind.Exec);
  FDurationPin := AddInputPin('Duration (ms)', 'float', TPinKind.Data);
  FDoneExecPin := AddOutputPin('Done', 'exec', TPinKind.Exec);
end;

procedure TWaitNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  var Duration := NodeValueToFloatDef(AContext.GetInputValue(FDurationPin), 0);
  if Duration > 0 then
  begin
    CheckThreadStopped;
    Sleep(Trunc(Duration));
    CheckThreadStopped;
  end;

  AContext.SetVariableFloat('WaitDuration_' + Self.Id, Duration);
  AContext.SelectExecOutput(FDoneExecPin);
end;

{ TEventNode }

constructor TEventNode.Create;
begin
  inherited;
  Width := 160;
  Height := 100;
  NodeType := 'event';
end;

procedure TEventNode.SetupPins;
begin
  ClearPins;
  FTriggerExecPin := AddOutputPin('Trigger', 'exec', TPinKind.Exec);
end;

procedure TEventNode.Trigger(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;
  AContext.SetVariableBool('EventFired_' + Self.Id, True);
  AContext.Graph.ExecuteExecPin(FTriggerExecPin, AContext);
end;

procedure TEventNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext <> nil then
    AContext.SetVariableBool('EventExecuted_' + Self.Id, True);
end;

{ TEventCallNode }

constructor TEventCallNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'eventcall';
end;

procedure TEventCallNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Exec', 'exec', TPinKind.Exec);
  FEventNamePin := AddInputPin('Event Name', 'string', TPinKind.Data);
  FDataPin := AddInputPin('Data', 'any', TPinKind.Data);
end;

procedure TEventCallNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  var EventName := NodeValueToStringDef(AContext.GetInputValue(FEventNamePin), '');
  var EventData := AContext.GetInputValue(FDataPin);

  if EventName <> '' then
    AContext.RaiseEvent(EventName, EventData);

  AContext.SelectExecOutput(nil);
end;

{ TEventListenerNode }

constructor TEventListenerNode.Create;
begin
  inherited;
  Width := 200;
  Height := 120;
  NodeType := 'eventlistener';
end;

procedure TEventListenerNode.SetupPins;
begin
  ClearPins;
  AddInputPin('Activate', 'exec', TPinKind.Exec);
  FEventNamePin := AddInputPin('Event Name', 'string', TPinKind.Data);
  FTriggeredExecPin := AddOutputPin('Triggered', 'exec', TPinKind.Exec);
  FDataOutputPin := AddOutputPin('Data', 'any', TPinKind.Data);
end;

procedure TEventListenerNode.Execute(AContext: TNodeExecutionContext);
begin
  if AContext = nil then
    Exit;

  var EventName := NodeValueToStringDef(AContext.GetInputValue(FEventNamePin), '');
  if EventName = '' then
    Exit;

  AContext.RegisterEventListener(Self.Id, EventName);

  var ReceivedData: TValue;
  if AContext.WasListenerTriggered(Self.Id, ReceivedData) then
  begin
    AContext.SetOutputValue(FDataOutputPin, ReceivedData);
    AContext.SetVariableBool('ListenerTriggered_' + Self.Id, True);
    AContext.SelectExecOutput(FTriggeredExecPin);
  end
  else
    AContext.SelectExecOutput(nil);
end;

end.

