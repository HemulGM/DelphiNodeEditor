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
  System.Classes, System.SysUtils, System.Rtti, System.UITypes,
  System.Generics.Collections, FMX.NodeEditor.Types, FMX.NodeEditor.Node,
  FMX.Graphics, System.Types, FMX.NodeEditor.Graph,
  FMX.NodeEditor.Executor.Runtime, FMX.Dialogs;

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

  TPrintNode = class(TExecutableNode)
  private
    FValuePin: TNodePin;
    FExecIn: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TPrintLogicNode = class(TExecutableNode)
  private
    FValuePin: TNodePin;
    FExecIn: TNodePin;
  protected
    FExecutedValue: Boolean;
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double); override;
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

  TSequenceNode = class abstract(TExecutableNode)
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

  TSequence3Node = class(TSequenceNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  TSequence5Node = class(TSequenceNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  TSequence10Node = class(TSequenceNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
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
    TBranchNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('loop', 'Loop', 'Control Flow',
    'While-like loop with condition input and body/exit exec outputs',
    'loop,while,cycle,iteration', '',
    TLoopNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('forloop', 'For Loop', 'Control Flow',
    'For loop with start, end and step',
    'for,loop,cycle,iteration,index', '',
    TForLoopNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('sequence', 'Sequence 3', 'Control Flow',
    'Executes several exec outputs one by one',
    'sequence,steps,order,exec', '',
    TSequence3Node, TAlphaColors.Null);

  Registry.RegisterNodeEx('sequence5', 'Sequence 5', 'Control Flow',
    'Executes several exec outputs one by one',
    'sequence,steps,order,exec', '',
    TSequence5Node, TAlphaColors.Null);

  Registry.RegisterNodeEx('sequence10', 'Sequence 10', 'Control Flow',
    'Executes several exec outputs one by one',
    'sequence,steps,order,exec', '',
    TSequence10Node, TAlphaColors.Null);

  Registry.RegisterNodeEx('break', 'Break', 'Control Flow',
    'Break current loop',
    'break,loop,stop', '',
    TBreakNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('continue', 'Continue', 'Control Flow',
    'Continue current loop iteration',
    'continue,loop,skip', '',
    TContinueNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('switch', 'Switch', 'Control Flow',
    'Selects exec output by input value',
    'switch,case,branch,select', '',
    TSwitchNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('wait', 'Wait', 'Control Flow',
    'Wait for specified duration in milliseconds',
    'wait,delay,sleep,timer', '',
    TWaitNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('event', 'Event', 'Events',
    'Event source node',
    'event,trigger,signal', '',
    TEventNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('eventcall', 'Call Event', 'Events',
    'Raise named event with payload',
    'event,call,emit,signal', '',
    TEventCallNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('eventlistener', 'Event Listener', 'Events',
    'Listen named event and output payload when triggered',
    'event,listener,subscribe,signal', '',
    TEventListenerNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('print', 'Print result', 'Common',
    'Show message with value',
    'print,message,value,string,text', '',
    TPrintNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('printboolvalue', 'Indicate bool', 'Common',
    'Show message and indicate with value',
    'print,value,bool,logic', '',
    TPrintLogicNode, TAlphaColors.Null);
end;

{ TBranchNode }

constructor TBranchNode.Create;
begin
  inherited;
  Width := 200;
  MinWidth := 200;
  Height := 120;
  NodeType := 'branch';
  HeaderColor := $FFC04000;
  IconPath := 'M416 160a64 64 0 1 0-96.27 55.24c-2.29 29.08-20.08 37-75 48.42c-17.76 3.68-35.93 7.45-52.71 13.93v-126.2a64 64 0 1 0-64 0v209.22a64 64 0 1 0 64.42.24c2.39-18 16-24.33 65.26-34.52c27.43-5.67 55.78-11.54 79.78-26.95c29-18.58 44.53-46.78 46.36-83.89A64 64 0 0 0 416 160M160 64a32 32 0 1 1-32 32a32 32 0 0 1 32-32m0 384a32 32 0 1 1 32-32a32 32 0 0 1-32 32m192-256a32 32 0 1 1 32-32a32 32 0 0 1-32 32';
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
  HeaderColor := $FFFF9C08;
  NodeType := 'loop';
  IconPath := 'M15.271 10v9.988H20V22h-6.999V10zM23 25h3.752A6.95 6.95 0 0 1 21 28H11c-3.9 0-7-3.1-7-7v-8H2v8c0 5 4 9 9 9h10a8.95 8.95 0 0 0 7-3.352V30h2v-7h-7zM21 2H11a8.95 8.95 0 0 0-7 3.352V2H2v7h7V7H5.248A6.95 6.95 0 0 1 11 4h10c3.9 0 7 3.1 7 7v8h2v-8c0-5-4-9-9-9';
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
  HeaderColor := $FFFF9C08;
  NodeType := 'forloop';
  IconPath := 'M23 23h7v7h-2v-3.352A8.95 8.95 0 0 1 21 30H11c-5 0-9-4-9-9v-8h2v8c0 3.9 3.1 7 7 7h10a6.95 6.95 0 0 0 5.752-3H23zM21 2H11a8.95 8.95 0 0 0-7 3.352V2H2v7h7V7H5.248A6.95 6.95 0 0 1 11 4h10c3.9 0 7 3.1 7 7v8h2v-8c0-5-4-9-9-9m-.279 10.012V10H13v12h2.27v-5.073h4.746v-2.012H15.27v-2.903z';
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
  HeaderColor := $FF2A5DAA;
  NodeType := 'sequence';
  IconPath := 'M2 4h8v6H7v10H5V10H2zm12 0h8v6h-3v10h-2V10h-3zm-1.364 8.086L16.385 16l-3.75 3.914l-1.444-1.384L12.657 17H8v-2h4.657l-1.466-1.53z';
end;

procedure TSequenceNode.SetupPins;
begin
  ClearPins;
  SetLength(FSteps, 0);
  AddInputPin('Exec', 'exec', TPinKind.Exec);
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
  HeaderColor := $FFDE3232;
  NodeType := 'break';
  IconPath := 'M1 7q-2-3 0-6l1 1Q0 4 2 6m5-5q2 3 0 6L6 6q2-2 0-4M3 1h2v3H3m0 1h2v2H3';
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
  HeaderColor := $FF00C35A;
  NodeType := 'continue';
  IconPath := 'M10 28a1 1 0 0 1-1-1V5a1 1 0 0 1 1.501-.865l19 11a1 1 0 0 1 0 1.73l-19 11A1 1 0 0 1 10 28m1-21.266v18.532L27 16zM4 4h2v24H4z';
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
  HeaderColor := $FFC04000;
  NodeType := 'switch';
  IconPath :=
    'M8 16.184V15.5c0-.848.512-1.595 1.287-2.047a7 7 0 0 1-1.822-1.131C6.561 13.136 6 14.26 6 15.5v.684A3 3 0 0 0 4 19c0 1.654 1.346 3 3 3s3-1.346 3-3a3 3 0 0 0-2-2.816M7 20a1.001 1.001 0 0 1 0-2a1.001 1.001 0 0 1 0 2m9-12.185v.351c0 .985-.535 1.852-1.345 2.36a7 7 0 0 1 1.823 1.1C17.414 10.748 18 9.524 18 8.167v-.351A3 3 0 0 0 20 5c0-1.654-1.346-3-3-3s-3 1.346-3 3c0 1.302.839 2.401 2 2.815M17 4a1.001 1.001 0 1 1-1 1c0-.551.448-1 1-1m.935 12.164C17.525 13.251 15.024 11 12 11a4.004 4.004 0 0 1-3.92-3.209A3 3 0 0 0 10 5c0-1.654-1.346-3-3-3S4 3.346 4 5c0 1.326.87 2.44 2.065 2.836C6.475 10.749 8.976 13 12 13a4.004 4.004 0 0 1 3.92 3.209A3 3 0 0 0 14 19c0 1.654 1.346 3 3 3s3-1.346 3-3c0-1.326-.87-2.44-2.065-2.836M7 4a1.001 1.001 0 1 1-1 1c0-.551.448-1 1-1m10 16a1.001 1.001 0 0 1 0-2a1.001 1.001 0 0 1 0 2';
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
  HeaderColor := $FF46756A;
  NodeType := 'wait';
  IconPath := 'M16.24 7.76A5.97 5.97 0 0 0 12 6v6l-4.24 4.24c2.34 2.34 6.14 2.34 8.49 0a5.99 5.99 0 0 0-.01-8.48M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m0 18c-4.42 0-8-3.58-8-8s3.58-8 8-8s8 3.58 8 8s-3.58 8-8 8';
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
  HeaderColor := $FF33958C;
  NodeType := 'event';
  IconPath := 'M7 1v2H3a1 1 0 0 0-1 1v16a1 1 0 0 0 1 1h7.755A8 8 0 0 1 22 9.755V4a1 1 0 0 0-1-1h-4V1h-2v2H9V1zm16 15a6 6 0 1 1-12 0a6 6 0 0 1 12 0m-7-4v4.414l2.293 2.293l1.414-1.414L18 15.586V12z';
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
  HeaderColor := $FF33958C;
  NodeType := 'eventcall';
  IconPath := 'M9 1v2h6V1h2v2h4a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h4V1zm11 7H4v11h16zm-4.964 2.136l1.414 1.414l-4.95 4.95l-3.536-3.536L9.38 11.55l2.121 2.122z';
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
  HeaderColor := $FF33958C;
  NodeType := 'eventlistener';
  IconPath := 'M9 1v2h6V1h2v2h4a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h4V1zm11 10H4v8h16zM8 14v2H6v-2zm10 0v2h-8v-2zM7 5H4v4h16V5h-3v2h-2V5H9v2H7z';
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

{ TPrintNode }

constructor TPrintNode.Create;
begin
  inherited;
  Width := 200;
  Height := 120;
  HeaderColor := $FF843482;
  NodeType := 'printvalue';
  IconPath := 'M16 8V5H8v3H6V3h12v5zM4 10h16zm14 2.5q.425 0 .713-.288T19 11.5t-.288-.712T18 10.5t-.712.288T17 11.5t.288.713t.712.287M16 19v-4H8v4zm2 2H6v-4H2v-6q0-1.275.875-2.137T5 8h14q1.275 0 2.138.863T22 11v6h-4zm2-6v-4q0-.425-.288-.712T19 10H5q-.425 0-.712.288T4 11v4h2v-2h12v2z';
end;

procedure TPrintNode.Execute(AContext: TNodeExecutionContext);
begin
  inherited;
  var Text := NodeValueToStringDef(AContext.GetInputValue(FValuePin), '');
  AContext.SetVariableStr('Print_' + Id, Text);
end;

procedure TPrintNode.SetupPins;
begin
  inherited;
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FValuePin := AddInputPin('Value', 'any', TPinKind.Data);
end;

{ TPrintLogicNode }

constructor TPrintLogicNode.Create;
begin
  inherited;
  Width := 200;
  Height := 120;
  HeaderColor := $FF843482;
  NodeType := 'printboolvalue';
  IconPath := 'M16 8V5H8v3H6V3h12v5zM4 10h16zm14 2.5q.425 0 .713-.288T19 11.5t-.288-.712T18 10.5t-.712.288T17 11.5t.288.713t.712.287M16 19v-4H8v4zm2 2H6v-4H2v-6q0-1.275.875-2.137T5 8h14q1.275 0 2.138.863T22 11v6h-4zm2-6v-4q0-.425-.288-.712T19 10H5q-.425 0-.712.288T4 11v4h2v-2h12v2z';
end;

procedure TPrintLogicNode.Execute(AContext: TNodeExecutionContext);
begin
  inherited;
  var Value := NodeValueToBoolDef(AContext.GetInputValue(FValuePin), False);
  FExecutedValue := Value;
  AContext.SetVariableBool('PrintBool_' + Id, Value);
end;

procedure TPrintLogicNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double);
begin
  inherited;
  var ScaledHeaderHeight := HeaderHeight * Zoom;
  var NodeHead := RectF(NodeBounds.Left, NodeBounds.Top, NodeBounds.Right, NodeBounds.Top + ScaledHeaderHeight);
  var NodeBody := RectF(NodeBounds.Left, NodeBounds.Top + ScaledHeaderHeight, NodeBounds.Right, NodeBounds.Bottom);

  NodeBody.Left := NodeBody.Left + NodeBody.Width / 2;
  var R := RectF(0, 0, 20 * Zoom, 20 * Zoom);
  R.SetLocation(NodeBody.Right - R.Width - 10 * Zoom, NodeBody.CenterPoint.Y - R.Height / 2);

  Canvas.Fill.Kind := TBrushKind.Solid;
  if FExecutedValue then
    Canvas.Fill.Color := TAlphaColors.Red
  else
    Canvas.Fill.Color := TAlphaColors.White;
  Canvas.FillEllipse(R, 1);
end;

procedure TPrintLogicNode.SetupPins;
begin
  inherited;
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FValuePin := AddInputPin('Value', 'bool', TPinKind.Data);
end;

{ TSequence3Node }

constructor TSequence3Node.Create;
begin
  inherited;
  Height := 140;
  MinHeight := Height;
  NodeType := 'sequence';
end;

procedure TSequence3Node.SetupPins;
begin
  inherited;
  AddStep;
  AddStep;
  AddStep;
end;

{ TSequence5Node }

constructor TSequence5Node.Create;
begin
  inherited;
  Height := 190;
  MinHeight := Height;
  NodeType := 'sequence5';
end;

procedure TSequence5Node.SetupPins;
begin
  inherited;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
end;

{ TSequence10Node }

constructor TSequence10Node.Create;
begin
  inherited;
  Height := 340;
  MinHeight := Height;
  NodeType := 'sequence10';
end;

procedure TSequence10Node.SetupPins;
begin
  inherited;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
  AddStep;
end;

end.

