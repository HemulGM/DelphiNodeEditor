unit FMX.NodeEditor.Node.Engineering;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Rtti, System.UITypes,
  FMX.Types, FMX.NodeEditor.Types, FMX.NodeEditor.Node,
  FMX.NodeEditor.Executor.Runtime, FMX.NodeEditor.Graph;

type
  TExecMathNode = class(TExecutableNode)
  protected
    FExecIn: TNodePin;
    FExecOut: TNodePin;
    procedure AddExecPins;
  end;

  TIntConstNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TIntRandomNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
    FFrom, FTo: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TFloatRandomNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TFloatConstNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TColorConstNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TColorRGBAConstNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
    FValueR: TNodePin;
    FValueG: TNodePin;
    FValueB: TNodePin;
    FValueA: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TBoolConstNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TStringConstNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSetVariableNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FNamePin, FValuePin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TGetVariableNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FNamePin: TNodePin;
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TAddExecNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSubExecNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TMulExecNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TDivExecNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TModExecNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TPowExecNode = class(TExecMathNode)
  private
    FBasePin, FExpPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TNegativeExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSinExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TCosExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TTanExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSqrtExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TAbsExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TLogExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TLnExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TFloorExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TCeilExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TRoundExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TGreaterNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TGreaterOrEqualNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TLessOrEqualNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TLessNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TEqualNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TNotEqualNode = class(TExecMathNode)
  private
    FA, FB, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TNotExecNode = class(TExecMathNode)
  private
    FValuePin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TAndExecNode = class(TExecMathNode)
  private
    FAPin, FBPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TNotAndExecNode = class(TExecMathNode)
  private
    FAPin, FBPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TOrExecNode = class(TExecMathNode)
  private
    FAPin, FBPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TNotOrExecNode = class(TExecMathNode)
  private
    FAPin, FBPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TXOrExecNode = class(TExecMathNode)
  private
    FAPin, FBPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TXNotOrExecNode = class(TExecMathNode)
  private
    FAPin, FBPin, FResult: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TIsPrimeFlagNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FIndexPin: TNodePin;
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TSetPrimeFlagNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FIndexPin, FValuePin: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TCollectPrimeNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FPrimePin: TNodePin;
    FListOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

procedure RegisterEngineeringNodes(ARegistry: TNodeRegistry);

implementation

{ TExecMathNode }

procedure TExecMathNode.AddExecPins;
begin
  FExecIn := AddInputPin('Exec', TNodeValueKind.Null, False, TPinKind.Exec);
  FExecOut := AddOutputPin('Next', TNodeValueKind.Null, False, TPinKind.Exec);
end;

{ TIntRandomNode }

constructor TIntRandomNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'intrandom';
  HeaderColor := $FF008C5E;
  IconPath := 'M4 17V9H2V7h4v10zm18-2a2 2 0 0 1-2 2h-4v-2h4v-2h-2v-2h2V9h-4V7h4a2 2 0 0 1 2 2v1.5a1.5 1.5 0 0 1-1.5 1.5a1.5 1.5 0 0 1 1.5 1.5zm-8 0v2H8v-4a2 2 0 0 1 2-2h2V9H8V7h4a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2h-2v2z';
end;

procedure TIntRandomNode.Execute(AContext: TNodeExecutionContext);
begin
  var FFrom := AContext.GetInputValueOrVar(FFrom);
  var FTo := AContext.GetInputValueOrVar(FTo);

  if not FFrom.IsEmpty and not FTo.IsEmpty then
    AContext.SetOutputValue(FValueOut, MakeIntValue(RandomRange(FFrom.AsInteger, FTo.AsInteger)))
  else
    AContext.SetOutputValue(FValueOut, MakeIntValue(0));
end;

procedure TIntRandomNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Integer, False, TPinKind.Data);
  FFrom := AddInputPinAndValue('From', TNodeValueKind.Integer, False, TPinKind.Data, 1);
  FTo := AddinputPin('To', TNodeValueKind.Integer, False, TPinKind.Data);

  if FindValue('To') = nil then
  begin
    var V := AddValue('To', TNodeValueKind.Integer);
    V.IntegerValue := 100;
  end;
end;

{ TIntConstNode }

constructor TIntConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'intconst';
  HeaderColor := $FF008C5E;
  IconPath := 'M4 17V9H2V7h4v10zm18-2a2 2 0 0 1-2 2h-4v-2h4v-2h-2v-2h2V9h-4V7h4a2 2 0 0 1 2 2v1.5a1.5 1.5 0 0 1-1.5 1.5a1.5 1.5 0 0 1 1.5 1.5zm-8 0v2H8v-4a2 2 0 0 1 2-2h2V9H8V7h4a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2h-2v2z';
end;

procedure TIntConstNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Integer, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;
end;

procedure TIntConstNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := FindValue('Value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeIntValue(V.IntegerValue))
  else
    AContext.SetOutputValue(FValueOut, MakeIntValue(0));
end;

{ TFloatRandomNode }

constructor TFloatRandomNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'floatrandom';
  HeaderColor := $FF008C5E;
  IconPath := 'M276.625 384v-36.938q52.688-48.375 80.25-78.937q25.313-27.938 34.875-44.813q9.75-16.875 9.75-33.187q0-17.25-11.813-27.563q-13.312-11.436-33.562-11.437q-27.75 0-63.75 20.063l-11.25-38.626q39.562-18.561 80.062-18.562q39.375 0 62.25 17.812q24.938 19.5 24.938 55.688q0 24.375-11.438 46.5q-11.437 22.125-40.687 54q-25.688 28.313-58.313 58.5h112.5V384zm-155.167 0V169.875L72.896 202.5L53.02 165.938l73.5-47.626h40.125V384zm117.209-41.667q-7.5-7.666-18.834-7.666q-11.166 0-18.833 7.5q-7.5 7.5-7.5 18.666q0 11.834 7.333 19.5q7.5 7.5 19.167 7.5q11.166 0 18.667-7.5q7.5-7.667 7.5-19.166q0-11.334-7.5-18.834';
end;

procedure TFloatRandomNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FValueOut, MakeFloatValue(Random));
end;

procedure TFloatRandomNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
end;

{ TFloatConstNode }

constructor TFloatConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'floatconst';
  HeaderColor := $FF008C5E;
  IconPath := 'M276.625 384v-36.938q52.688-48.375 80.25-78.937q25.313-27.938 34.875-44.813q9.75-16.875 9.75-33.187q0-17.25-11.813-27.563q-13.312-11.436-33.562-11.437q-27.75 0-63.75 20.063l-11.25-38.626q39.562-18.561 80.062-18.562q39.375 0 62.25 17.812q24.938 19.5 24.938 55.688q0 24.375-11.438 46.5q-11.437 22.125-40.687 54q-25.688 28.313-58.313 58.5h112.5V384zm-155.167 0V169.875L72.896 202.5L53.02 165.938l73.5-47.626h40.125V384zm117.209-41.667q-7.5-7.666-18.834-7.666q-11.166 0-18.833 7.5q-7.5 7.5-7.5 18.666q0 11.834 7.333 19.5q7.5 7.5 19.167 7.5q11.166 0 18.667-7.5q7.5-7.667 7.5-19.166q0-11.334-7.5-18.834';
end;

procedure TFloatConstNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := FindValue('Value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeFloatValue(V.FloatValue))
  else
    AContext.SetOutputValue(FValueOut, MakeFloatValue(0));
end;

procedure TFloatConstNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

{ TColorConstNode }

constructor TColorConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'colorconst';
  HeaderColor := $FFA73E84;
  IconPath := 'm441 336.2l-.06-.05c-9.93-9.18-22.78-11.34-32.16-12.92l-.69-.12c-9.05-1.49-10.48-2.5-14.58-6.17c-2.44-2.17-5.35-5.65-5.35-9.94s2.91-7.77 5.34-9.94l30.28-26.87c25.92-22.91 40.2-53.66 40.2-86.59s-14.25-63.68-40.2-86.6c-35.89-31.59-85-49-138.37-49C223.72 48 162 71.37 116 112.11c-43.87 38.77-68 90.71-68 146.24s24.16 107.47 68 146.23c21.75 19.24 47.49 34.18 76.52 44.42a266.2 266.2 0 0 0 86.87 15h1.81c61 0 119.09-20.57 159.39-56.4c9.7-8.56 15.15-20.83 15.34-34.56c.21-14.17-5.37-27.95-14.93-36.84M112 208a32 32 0 1 1 32 32a32 32 0 0 1-32-32m40 135a32 32 0 1 1 32-32a32 32 0 0 1-32 32m40-199a32 32 0 1 1 32 32a32 32 0 0 1-32-32m64 271a48 48 0 1 1 48-48a48 48 0 0 1-48 48m72-239a32 32 0 1 1 32-32a32 32 0 0 1-32 32';
end;

procedure TColorConstNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := FindValue('Value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeColorValue(V.ColorValue))
  else
    AContext.SetOutputValue(FValueOut, MakeColorValue(TAlphaColors.Null));
end;

procedure TColorConstNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Color, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Color);
    V.ColorValue := TAlphaColors.Null;
  end;
end;

{ TColorRGBAConstNode }

constructor TColorRGBAConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 180;
  NodeType := 'colorrgbaconst';
  HeaderColor := $FFA73E84;
  IconPath := 'm441 336.2l-.06-.05c-9.93-9.18-22.78-11.34-32.16-12.92l-.69-.12c-9.05-1.49-10.48-2.5-14.58-6.17c-2.44-2.17-5.35-5.65-5.35-9.94s2.91-7.77 5.34-9.94l30.28-26.87c25.92-22.91 40.2-53.66 40.2-86.59s-14.25-63.68-40.2-86.6c-35.89-31.59-85-49-138.37-49C223.72 48 162 71.37 116 112.11c-43.87 38.77-68 90.71-68 146.24s24.16 107.47 68 146.23c21.75 19.24 47.49 34.18 76.52 44.42a266.2 266.2 0 0 0 86.87 15h1.81c61 0 119.09-20.57 159.39-56.4c9.7-8.56 15.15-20.83 15.34-34.56c.21-14.17-5.37-27.95-14.93-36.84M112 208a32 32 0 1 1 32 32a32 32 0 0 1-32-32m40 135a32 32 0 1 1 32-32a32 32 0 0 1-32 32m40-199a32 32 0 1 1 32 32a32 32 0 0 1-32-32m64 271a48 48 0 1 1 48-48a48 48 0 0 1-48 48m72-239a32 32 0 1 1 32-32a32 32 0 0 1-32 32';
end;

procedure TColorRGBAConstNode.Execute(AContext: TNodeExecutionContext);
begin
  var R := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValueR), 1);
  var G := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValueG), 1);
  var B := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValueB), 1);
  var A := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValueA), 1);

  AContext.SetOutputValue(FValueOut, MakeColorValue(TAlphaColorF.Create(R, G, B, A).ToAlphaColor));
end;

procedure TColorRGBAConstNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Color, False, TPinKind.Data);

  FValueR := AddInputPin('Red', TNodeValueKind.Float, False, TPinKind.Data);
  FValueG := AddInputPin('Green', TNodeValueKind.Float, False, TPinKind.Data);
  FValueB := AddInputPin('Blue', TNodeValueKind.Float, False, TPinKind.Data);
  FValueA := AddInputPin('Alpha', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Red') = nil then
  begin
    var V := AddValue('Red', TNodeValueKind.Float);
    V.FloatValue := 1;
    V.Min := 0;
    V.Max := 1;
  end;

  if FindValue('Green') = nil then
  begin
    var V := AddValue('Green', TNodeValueKind.Float);
    V.FloatValue := 1;
    V.Min := 0;
    V.Max := 1;
  end;

  if FindValue('Blue') = nil then
  begin
    var V := AddValue('Blue', TNodeValueKind.Float);
    V.FloatValue := 1;
    V.Min := 0;
    V.Max := 1;
  end;

  if FindValue('Alpha') = nil then
  begin
    var V := AddValue('Alpha', TNodeValueKind.Float);
    V.FloatValue := 1;
    V.Min := 0;
    V.Max := 1;
  end;
end;

{ TBoolConstNode }

constructor TBoolConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'boolconst';
  HeaderColor := $FF760E0E;
  IconPath := 'M4 12.25a4 4 0 1 1 8 0a4 4 0 0 1-8 0m4-2.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 0 0 0-5 M12 12.25a4 4 0 1 1 8 0a4 4 0 0 1-8 0';
end;

procedure TBoolConstNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

procedure TBoolConstNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := FindValue('Value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeBoolValue(V.BooleanValue))
  else
    AContext.SetOutputValue(FValueOut, MakeBoolValue(False));
end;

{ TStringConstNode }

constructor TStringConstNode.Create;
begin
  inherited;
  Width := 200;
  Height := 110;
  NodeType := 'stringconst';
  HeaderColor := $FF8C4300;
  IconPath := 'M6 11a2 2 0 0 1 2 2v4H4a2 2 0 0 1-2-2v-2a2 2 0 0 1 2-2zm-2 2v2h2v-2zm16 0v2h2v2h-2a2 2 0 0 1-2-2v-2a2 2 0 0 1 2-2h2v2zm-8-6v4h2a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2h-2a2 2 0 0 1-2-2V7zm0 8h2v-2h-2z';
end;

procedure TStringConstNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', TNodeValueKind.string, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.string);
    V.StringValue := '';
  end;
end;

procedure TStringConstNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := FindValue('Value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeStringValue(V.StringValue))
  else
    AContext.SetOutputValue(FValueOut, MakeStringValue(''));
end;

{ TSetVariableNode }

constructor TSetVariableNode.Create;
begin
  inherited;
  Width := 220;
  Height := 130;
  NodeType := 'setvar';
  HeaderColor := $FF5E28C1;
  IconPath := 'M26 28h-4v-2h4V6h-4V4h4a2 2 0 0 1 2 2v20a2 2 0 0 1-2 2m-6-17h-2l-2 3.897L14 11h-2l2.905 5L12 21h2l2-3.799L18 21h2l-2.902-5zM10 28H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h4v2H6v20h4z';
end;

procedure TSetVariableNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', TNodeValueKind.Null, False, TPinKind.Exec);
  FNamePin := AddInputPin('Name', TNodeValueKind.string, False, TPinKind.Data);
  FValuePin := AddInputPin('Value', TNodeValueKind.Null, True, TPinKind.Data);
  FExecOut := AddOutputPin('Next', TNodeValueKind.Null, False, TPinKind.Exec);

  if FindValue('Name') = nil then
  begin
    var V := AddValue('Name', TNodeValueKind.string);
    V.StringValue := '';
  end;
end;

procedure TSetVariableNode.Execute(AContext: TNodeExecutionContext);
begin
  var N := NodeValueToStringDef(AContext.GetInputValueOrVar(FNamePin), '');
  var V := AContext.GetInputValue(FValuePin);
  if N <> '' then
    AContext.SetVariable(N, V);
  AContext.SelectExecOutput(FExecOut);
end;

{ TGetVariableNode }

constructor TGetVariableNode.Create;
begin
  inherited;
  Width := 220;
  Height := 130;
  NodeType := 'getvar';
  HeaderColor := $FF5E28C1;
  IconPath := 'M26 28h-4v-2h4V6h-4V4h4a2 2 0 0 1 2 2v20a2 2 0 0 1-2 2m-6-17h-2l-2 3.897L14 11h-2l2.905 5L12 21h2l2-3.799L18 21h2l-2.902-5zM10 28H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h4v2H6v20h4z';
end;

procedure TGetVariableNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', TNodeValueKind.Null, False, TPinKind.Exec);
  FNamePin := AddInputPin('Name', TNodeValueKind.string, False, TPinKind.Data);
  FExecOut := AddOutputPin('Next', TNodeValueKind.Null, False, TPinKind.Exec);
  FValueOut := AddOutputPin('Value', TNodeValueKind.Null, True, TPinKind.Data);

  if FindValue('Name') = nil then
  begin
    var V := AddValue('Name', TNodeValueKind.string);
    V.StringValue := '';
  end;
end;

procedure TGetVariableNode.Execute(AContext: TNodeExecutionContext);
begin
  var N := NodeValueToStringDef(AContext.GetInputValueOrVar(FNamePin), '');
  AContext.SetOutputValue(FValueOut, AContext.GetVariableValue(N));
  AContext.SelectExecOutput(FExecOut);
end;

{ TAddExecNode }

constructor TAddExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'addexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M12 4a1 1 0 0 0-1 1v6H5a1 1 0 1 0 0 2h6v6a1 1 0 1 0 2 0v-6h6a1 1 0 1 0 0-2h-6V5a1 1 0 0 0-1-1';
end;

procedure TAddExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TAddExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) +
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TSubExecNode }

constructor TSubExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'subexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M4 12a1 1 0 0 1 1-1h14a1 1 0 1 1 0 2H5a1 1 0 0 1-1-1';
end;

procedure TSubExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TSubExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) -
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TMulExecNode }

constructor TMulExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'mulexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M12.74 27.25L16.58 19.97L25.12 19.97L18.16 32.84L25.46 46.39L16.87 46.39L12.72 38.57L8.64 46.39L0 46.39L7.32 32.84L0.39 19.97L9.03 19.97L12.74 27.25ZM38.33 34.86L42.72 19.97L51.54 19.97L40.77 50.81L40.31 51.93Q38.01 57.06 32.20 57.06Q30.59 57.06 28.81 56.57L28.81 50.68L29.88 50.68Q31.62 50.68 32.53 50.18Q33.45 49.68 33.89 48.39L34.55 46.63L25.37 19.97L34.16 19.97L38.33 34.86Z';
end;

procedure TMulExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TMulExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) *
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TDivExecNode }

constructor TDivExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'divexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M14 7a2 2 0 1 1-4 0a2 2 0 0 1 4 0M3 12a1 1 0 0 1 1-1h16a1 1 0 1 1 0 2H4a1 1 0 0 1-1-1m9 7a2 2 0 1 0 0-4a2 2 0 0 0 0 4';
end;

procedure TDivExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TDivExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var B := NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0);
  if Abs(B) < 1e-12 then
    raise ENodeExecutionError.Create('Division by zero');
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) / B
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TModExecNode }

constructor TModExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'modexec';
  HeaderColor := $FF342C8F;
  IconPath :=
    'M4.25 2.5a.84.84 0 0 0-.837.921l.2 2.096A2.4 2.4 0 0 1 2.04 8a2.4 2.4 0 0 1 1.571 2.483l-.2 2.096a.84.84 0 0 0 .838.921a.75.75 0 0 1 0 1.5a2.34 2.34 0 0 1-2.33-2.563l.199-2.096a.9.9 0 0 0-.677-.957l-.139-.035a1.39 1.39 0 0 1 0-2.698l.14-.035a.9.9 0 0 0 .676-.957l-.2-2.096A2.34 2.34 0 0 1 4.25 1a.75.75 0 0 1 0 1.5m4.805 2.639a.78.78 0 0 1 .989-.668a.75.75 0 1 0 .412-1.442a2.28 2.28 0 0 0-2.892 1.953L7.456 6H6.5a.75.75 0 0 0 0 1.5h.798l-.353 3.361a.78.78 0 0 1-.989.668a.75.75 0 1 0-.412 1.442a2.28 2.28 0 0 0 2.892-1.953l.37-3.518h.944a.75.75 0 0 0 0-1.5h-.785zm3.533 7.44a.84.84 0 0 1-.838.921a.75.75 0 0 0 0 1.5a2.34 2.34 0 0 0 2.33-2.563l-.199-2.096a.9.9 0 0 1 .677-.957l.139-.035a1.39 1.39 0 0 0 0-2.698l-.14-.035a.9.9 0 0 1-.676-.957l.2-2.096A2.34 2.34 0 0 0 11.75 1a.75.75 0 0 0 0 1.5c.496 0 .884.427.838.921l-.2 2.096A2.4 2.4 0 0 0 13.959 8a2.4 2.4 0 0 0-1.571 2.483z';
end;

procedure TModExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Integer, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Integer, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Integer, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;
end;

procedure TModExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var AInt := NodeValueToIntDef(AContext.GetInputValueOrVar(FA), 0);
  var BInt := NodeValueToIntDef(AContext.GetInputValueOrVar(FB), 1);
  if BInt = 0 then
    raise ENodeExecutionError.Create('Modulo by zero');
  AContext.SetOutputValue(FResult, MakeIntValue(AInt mod BInt));
  AContext.SelectExecOutput(FExecOut);
end;

{ TPowExecNode }

constructor TPowExecNode.Create;
begin
  inherited;
  Width := 200;
  Height := 140;
  NodeType := 'powexec';
  HeaderColor := $FF342C8F;
  IconPath := 'm15.38 3l2.39 5.75c-.22.93-.5 1.57-.77 1.95c-.33.48-.56.55-.81.55v1.5c.75 0 1.55-.4 2.05-1.19C19.87 8.94 22 3 22 3h-1.62l-1.69 4.05L17 3zM3.42 8.59L2 10l4.79 4.79L2 19.59L3.41 21l4.8-4.79L13 21l1.41-1.41l-4.79-4.8L14.41 10L13 8.59l-4.79 4.79l-4.8-4.79z';
end;

procedure TPowExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FBasePin := AddInputPin('Base', TNodeValueKind.Float, False, TPinKind.Data);
  FExpPin := AddInputPin('Exponent', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Base') = nil then
  begin
    var V := AddValue('Base', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('Exponent') = nil then
  begin
    var V := AddValue('Exponent', TNodeValueKind.Float);
    V.FloatValue := 2;
  end;
end;

procedure TPowExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Power(
        NodeValueToFloatDef(AContext.GetInputValueOrVar(FBasePin), 0.0),
        NodeValueToFloatDef(AContext.GetInputValueOrVar(FExpPin), 0.0)
      )
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TNegativeExecNode }

constructor TNegativeExecNode.Create;
begin
  inherited;
  Width := 200;
  Height := 140;
  NodeType := 'negative';
  HeaderColor := $FF342C8F;
  IconPath := 'M11 7.998H8v3a1 1 0 0 1-2 0v-3H3a1 1 0 1 1 0-2h3v-3a1 1 0 1 1 2 0v3h3a1 1 0 0 1 0 2m10 10h-6a1 1 0 0 1 0-2h6a1 1 0 0 1 0 2M17.793 4.707L4.707 17.793a1 1 0 0 0 0 1.414l.086.086a1 1 0 0 0 1.414 0L19.293 6.207a1 1 0 0 0 0-1.414l-.086-.086a1 1 0 0 0-1.414 0';
end;

procedure TNegativeExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      -NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TNegativeExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('-Value', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

{ TSinExecNode }

constructor TSinExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'sinexec';
  HeaderColor := $FF955900;
  IconPath := 'M4 7a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h2v2H2v2h4a2 2 0 0 0 2-2v-2a2 2 0 0 0-2-2H4V9h4V7zm10 0v2h-1v6h1v2h-4v-2h1V9h-1V7zm2 0v10h2v-5l2 5h2V7h-2v5l-2-5z';
end;

procedure TSinExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Radians', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Radians') = nil then
  begin
    var V := AddValue('Radians', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TSinExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Sin(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TCosExecNode }

constructor TCosExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'cosexec';
  HeaderColor := $FF955900;
  IconPath := 'M4 7a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2v-1H6v1H4V9h2v1h2V9a2 2 0 0 0-2-2zm7 0a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2zm0 2h2v6h-2zm7-2a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h2v2h-4v2h4a2 2 0 0 0 2-2v-2a2 2 0 0 0-2-2h-2V9h4V7z';
end;

procedure TCosExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Radians', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Radians') = nil then
  begin
    var V := AddValue('Radians', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TCosExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Cos(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TTanExecNode }

constructor TTanExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'tanexec';
  HeaderColor := $FF955900;
  IconPath := 'M2 7v2h2v8h2V9h2V7zm9 0a2 2 0 0 0-2 2v8h2v-4h2v4h2V9a2 2 0 0 0-2-2zm0 2h2v2h-2zm5-2v10h2v-5l2 5h2V7h-2v5l-2-5z';
end;

procedure TTanExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Radians', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Radians') = nil then
  begin
    var V := AddValue('Radians', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TTanExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Tan(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TSqrtExecNode }

constructor TSqrtExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'sqrtexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M11.76 16.83L14.59 14l-2.83-2.83l1.41-1.41L16 12.59l2.83-2.83l1.41 1.41L17.41 14l2.83 2.83l-1.41 1.41L16 15.41l-2.83 2.83zM2 11h3l2.29 5.4L10 6h12v2H11.55L8.68 19H6.22l-2.54-6H2z';
end;

procedure TSqrtExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TSqrtExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0);
  if V < 0 then
    raise ENodeExecutionError.Create('SQRT from negative number');
  AContext.SetOutputValue(FResult, MakeFloatValue(Sqrt(V)));
  AContext.SelectExecOutput(FExecOut);
end;

{ TAbsExecNode }

constructor TAbsExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'absexec';
  HeaderColor := $FF342C8F;
  IconPath :=
    'M4.25 2.5a.84.84 0 0 0-.837.921l.2 2.096A2.4 2.4 0 0 1 2.04 8a2.4 2.4 0 0 1 1.571 2.483l-.2 2.096a.84.84 0 0 0 .838.921a.75.75 0 0 1 0 1.5a2.34 2.34 0 0 1-2.33-2.563l.199-2.096a.9.9 0 0 0-.677-.957l-.139-.035a1.39 1.39 0 0 1 0-2.698l.14-.035a.9.9 0 0 0 .676-.957l-.2-2.096A2.34 2.34 0 0 1 4.25 1a.75.75 0 0 1 0 1.5m4.805 2.639a.78.78 0 0 1 .989-.668a.75.75 0 1 0 .412-1.442a2.28 2.28 0 0 0-2.892 1.953L7.456 6H6.5a.75.75 0 0 0 0 1.5h.798l-.353 3.361a.78.78 0 0 1-.989.668a.75.75 0 1 0-.412 1.442a2.28 2.28 0 0 0 2.892-1.953l.37-3.518h.944a.75.75 0 0 0 0-1.5h-.785zm3.533 7.44a.84.84 0 0 1-.838.921a.75.75 0 0 0 0 1.5a2.34 2.34 0 0 0 2.33-2.563l-.199-2.096a.9.9 0 0 1 .677-.957l.139-.035a1.39 1.39 0 0 0 0-2.698l-.14-.035a.9.9 0 0 1-.676-.957l.2-2.096A2.34 2.34 0 0 0 11.75 1a.75.75 0 0 0 0 1.5c.496 0 .884.427.838.921l-.2 2.096A2.4 2.4 0 0 0 13.959 8a2.4 2.4 0 0 0-1.571 2.483z';
end;

procedure TAbsExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TAbsExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Abs(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TLogExecNode }

constructor TLogExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'logexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M18 7c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h2c1.1 0 2-.9 2-2v-4h-2v4h-2V9h4V7zM2 7v10h6v-2H4V7zm9 0c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h2c1.1 0 2-.9 2-2V9c0-1.1-.9-2-2-2zm0 2h2v6h-2z';
end;

procedure TLogExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TLogExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 1.0);
  if V <= 0 then
    raise ENodeExecutionError.Create('LOG10 argument must be > 0');
  AContext.SetOutputValue(FResult, MakeFloatValue(Log10(V)));
  AContext.SelectExecOutput(FExecOut);
end;

{ TLnExecNode }

constructor TLnExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'lnexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M18 7c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h2c1.1 0 2-.9 2-2v-4h-2v4h-2V9h4V7zM2 7v10h6v-2H4V7zm9 0c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h2c1.1 0 2-.9 2-2V9c0-1.1-.9-2-2-2zm0 2h2v6h-2z';
end;

procedure TLnExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Float, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TLnExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 1.0);
  if V <= 0 then
    raise ENodeExecutionError.Create('LN argument must be > 0');
  AContext.SetOutputValue(FResult, MakeFloatValue(Ln(V)));
  AContext.SelectExecOutput(FExecOut);
end;

{ TFloorExecNode }

constructor TFloorExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'floorexec';
  HeaderColor := $FF342C8F;
  IconPath := 'M6.5 20v-3.5q0-.425.288-.712T7.5 15.5H11V12q0-.425.288-.712T12 11h3.5V7.5q0-.425.288-.712T16.5 6.5H20V4q0-.425.288-.712T21 3t.713.288T22 4v3.5q0 .425-.288.713T21 8.5h-3.5V12q0 .425-.288.713T16.5 13H13v3.5q0 .425-.288.713T12 17.5H8.5V21q0 .425-.288.713T7.5 22H4q-.425 0-.712-.288T3 21t.288-.712T4 20z';
end;

procedure TFloorExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Integer, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TFloorExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeIntValue(
      Floor(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TCeilExecNode }

constructor TCeilExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'ceilexec';
  HeaderColor := $FF342C8F;
  IconPath :=
    'M4.25 2.5a.84.84 0 0 0-.837.921l.2 2.096A2.4 2.4 0 0 1 2.04 8a2.4 2.4 0 0 1 1.571 2.483l-.2 2.096a.84.84 0 0 0 .838.921a.75.75 0 0 1 0 1.5a2.34 2.34 0 0 1-2.33-2.563l.199-2.096a.9.9 0 0 0-.677-.957l-.139-.035a1.39 1.39 0 0 1 0-2.698l.14-.035a.9.9 0 0 0 .676-.957l-.2-2.096A2.34 2.34 0 0 1 4.25 1a.75.75 0 0 1 0 1.5m4.805 2.639a.78.78 0 0 1 .989-.668a.75.75 0 1 0 .412-1.442a2.28 2.28 0 0 0-2.892 1.953L7.456 6H6.5a.75.75 0 0 0 0 1.5h.798l-.353 3.361a.78.78 0 0 1-.989.668a.75.75 0 1 0-.412 1.442a2.28 2.28 0 0 0 2.892-1.953l.37-3.518h.944a.75.75 0 0 0 0-1.5h-.785zm3.533 7.44a.84.84 0 0 1-.838.921a.75.75 0 0 0 0 1.5a2.34 2.34 0 0 0 2.33-2.563l-.199-2.096a.9.9 0 0 1 .677-.957l.139-.035a1.39 1.39 0 0 0 0-2.698l-.14-.035a.9.9 0 0 1-.676-.957l.2-2.096A2.34 2.34 0 0 0 11.75 1a.75.75 0 0 0 0 1.5c.496 0 .884.427.838.921l-.2 2.096A2.4 2.4 0 0 0 13.959 8a2.4 2.4 0 0 0-1.571 2.483z';
end;

procedure TCeilExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Integer, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TCeilExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeIntValue(
      Ceil(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TRoundExecNode }

constructor TRoundExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'roundexec';
  HeaderColor := $FF342C8F;
  IconPath :=
    'M4.25 2.5a.84.84 0 0 0-.837.921l.2 2.096A2.4 2.4 0 0 1 2.04 8a2.4 2.4 0 0 1 1.571 2.483l-.2 2.096a.84.84 0 0 0 .838.921a.75.75 0 0 1 0 1.5a2.34 2.34 0 0 1-2.33-2.563l.199-2.096a.9.9 0 0 0-.677-.957l-.139-.035a1.39 1.39 0 0 1 0-2.698l.14-.035a.9.9 0 0 0 .676-.957l-.2-2.096A2.34 2.34 0 0 1 4.25 1a.75.75 0 0 1 0 1.5m4.805 2.639a.78.78 0 0 1 .989-.668a.75.75 0 1 0 .412-1.442a2.28 2.28 0 0 0-2.892 1.953L7.456 6H6.5a.75.75 0 0 0 0 1.5h.798l-.353 3.361a.78.78 0 0 1-.989.668a.75.75 0 1 0-.412 1.442a2.28 2.28 0 0 0 2.892-1.953l.37-3.518h.944a.75.75 0 0 0 0-1.5h-.785zm3.533 7.44a.84.84 0 0 1-.838.921a.75.75 0 0 0 0 1.5a2.34 2.34 0 0 0 2.33-2.563l-.199-2.096a.9.9 0 0 1 .677-.957l.139-.035a1.39 1.39 0 0 0 0-2.698l-.14-.035a.9.9 0 0 1-.676-.957l.2-2.096A2.34 2.34 0 0 0 11.75 1a.75.75 0 0 0 0 1.5c.496 0 .884.427.838.921l-.2 2.096A2.4 2.4 0 0 0 13.959 8a2.4 2.4 0 0 0-1.571 2.483z';
end;

procedure TRoundExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Integer, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TRoundExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeIntValue(
      Round(NodeValueToFloatDef(AContext.GetInputValueOrVar(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TGreaterNode }

constructor TGreaterNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'greater';
  HeaderColor := $FFB9075C;
  IconPath := 'M98.9 114.6c-7.4 16-.4 35.1 15.6 42.5L467.6 320l-353 163c-16 7.4-23.1 26.4-15.6 42.5s26.4 23 42.5 15.6l416-192c11.3-5.2 18.6-16.6 18.6-29.1s-7.3-23.8-18.6-29.1L141.4 99c-16-7.4-35.1-.4-42.5 15.6';
end;

procedure TGreaterNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TGreaterNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) >
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TGreaterOrEqualNode }

constructor TGreaterOrEqualNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'greaterorequal';
  HeaderColor := $FFB9075C;
  IconPath := 'M117.9 158.4c-16.8-5.6-25.8-23.8-20.2-40.5s23.7-25.8 40.4-20.3l384 128C535.2 230 544 242.2 544 256s-8.8 26-21.9 30.4l-384 128c-16.8 5.6-34.9-3.5-40.5-20.2s3.5-34.9 20.2-40.5l293-97.7zM512 480c17.7 0 32 14.3 32 32s-14.3 32-32 32H128c-17.7 0-32-14.3-32-32s14.3-32 32-32z';
end;

procedure TGreaterOrEqualNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) >=
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TGreaterOrEqualNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

{ TLessOrEqualNode }

constructor TLessOrEqualNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'lessorequal';
  HeaderColor := $FFB9075C;
  IconPath := 'M522.1 158.4c16.8-5.6 25.8-23.7 20.2-40.5s-23.7-25.8-40.5-20.2l-384 128C104.8 230 96 242.2 96 256s8.8 26 21.9 30.4l384 128c16.8 5.6 34.9-3.5 40.5-20.2s-3.5-34.9-20.2-40.5l-293-97.7zM128 480c-17.7 0-32 14.3-32 32s14.3 32 32 32h384c17.7 0 32-14.3 32-32s-14.3-32-32-32z';
end;

procedure TLessOrEqualNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) <=
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TLessOrEqualNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

{ TLessNode }

constructor TLessNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'less';
  HeaderColor := $FFB9075C;
  IconPath := 'M541.1 114.6c7.4 16 .4 35.1-15.6 42.5L172.4 320l353 163c16 7.4 23 26.4 15.6 42.5s-26.4 23-42.5 15.6l-416-192C71.3 343.8 64 332.5 64 320s7.3-23.8 18.6-29l416-192c16-7.4 35.1-.4 42.5 15.6';
end;

procedure TLessNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TLessNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0) <
      NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TEqualNode }

constructor TEqualNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'equal';
  HeaderColor := $FFB9075C;
  IconPath := 'M128 192c-17.7 0-32 14.3-32 32s14.3 32 32 32h384c17.7 0 32-14.3 32-32s-14.3-32-32-32zm0 192c-17.7 0-32 14.3-32 32s14.3 32 32 32h384c17.7 0 32-14.3 32-32s-14.3-32-32-32z';
end;

procedure TEqualNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

procedure TEqualNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      SameValue(
        NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0),
        NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0),
        1e-9
      )
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ TNotEqualNode }

constructor TNotEqualNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'notequal';
  HeaderColor := $FFB9075C;
  IconPath := 'M474.6 145.8c9.8-14.7 5.8-34.6-8.9-44.4s-34.6-5.8-44.4 8.9L366.9 192H128c-17.7 0-32 14.3-32 32s14.3 32 32 32h196.2l-85.3 128H128c-17.7 0-32 14.3-32 32s14.3 32 32 32h68.2l-30.8 46.2c-9.8 14.7-5.8 34.6 8.9 44.4s34.6 5.8 44.4-8.9l54.4-81.7H512c17.7 0 32-14.3 32-32s-14.3-32-32-32H315.8l85.3-128H512c17.7 0 32-14.3 32-32s-14.3-32-32-32h-68.2z';
end;

procedure TNotEqualNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      not SameValue(
        NodeValueToFloatDef(AContext.GetInputValueOrVar(FA), 0.0),
        NodeValueToFloatDef(AContext.GetInputValueOrVar(FB), 0.0),
        1e-9
      )
    ));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TNotEqualNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', TNodeValueKind.Float, False, TPinKind.Data);
  FB := AddInputPin('B', TNodeValueKind.Float, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Float);
    V.FloatValue := 0;
  end;
end;

{ TIsPrimeFlagNode }

constructor TIsPrimeFlagNode.Create;
begin
  inherited;
  Width := 220;
  Height := 130;
  NodeType := 'isprimeflag';
  HeaderColor := $FF4F3B73;
  IconPath := 'M21 7.25h-3l.77-3.07a.75.75 0 0 0-1.46-.36l-.86 3.43H10l.77-3.07a.75.75 0 0 0-1.46-.36l-.9 3.43H5a.75.75 0 0 0 0 1.5h3l-1.63 6.5H3a.75.75 0 0 0 0 1.5h3l-.77 3.07a.75.75 0 0 0 1.46.36l.86-3.43H14l-.77 3.07a.75.75 0 0 0 1.46.36l.86-3.43H19a.75.75 0 0 0 0-1.5h-3l1.63-6.5H21a.75.75 0 0 0 0-1.5m-5 1.5l-1.63 6.5H8l1.63-6.5Z';
end;

procedure TIsPrimeFlagNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', TNodeValueKind.Null, False, TPinKind.Exec);
  FIndexPin := AddInputPin('Index', TNodeValueKind.Integer, False, TPinKind.Data);
  FExecOut := AddOutputPin('Next', TNodeValueKind.Null, False, TPinKind.Exec);
  FValueOut := AddOutputPin('IsPrime', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('Index') = nil then
  begin
    var V := AddValue('Index', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;
end;

procedure TIsPrimeFlagNode.Execute(AContext: TNodeExecutionContext);
begin
  var Idx := NodeValueToIntDef(AContext.GetInputValueOrVar(FIndexPin), 0);
  var B := AContext.GetVariableBool('prime_' + IntToStr(Idx), False);

  AContext.SetVariable('last_prime_check_index', MakeIntValue(Idx));
  AContext.SetVariableBool('last_prime_check_value', B);

  AContext.SetOutputValue(FValueOut, MakeBoolValue(B));
  AContext.SelectExecOutput(FExecOut);
end;

{ TSetPrimeFlagNode }

constructor TSetPrimeFlagNode.Create;
begin
  inherited;
  Width := 220;
  Height := 140;
  NodeType := 'setprimeflag';
  HeaderColor := $FF4F3B73;
  IconPath := 'M21 7.25h-3l.77-3.07a.75.75 0 0 0-1.46-.36l-.86 3.43H10l.77-3.07a.75.75 0 0 0-1.46-.36l-.9 3.43H5a.75.75 0 0 0 0 1.5h3l-1.63 6.5H3a.75.75 0 0 0 0 1.5h3l-.77 3.07a.75.75 0 0 0 1.46.36l.86-3.43H14l-.77 3.07a.75.75 0 0 0 1.46.36l.86-3.43H19a.75.75 0 0 0 0-1.5h-3l1.63-6.5H21a.75.75 0 0 0 0-1.5m-5 1.5l-1.63 6.5H8l1.63-6.5Z';
end;

procedure TSetPrimeFlagNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', TNodeValueKind.Null, False, TPinKind.Exec);
  FIndexPin := AddInputPin('Index', TNodeValueKind.Integer, False, TPinKind.Data);
  FValuePin := AddInputPin('Value', TNodeValueKind.Boolean, False, TPinKind.Data);
  FExecOut := AddOutputPin('Next', TNodeValueKind.Null, False, TPinKind.Exec);

  if FindValue('Index') = nil then
  begin
    var V := AddValue('Index', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Boolean);
    V.BooleanValue := True;
  end;
end;

procedure TSetPrimeFlagNode.Execute(AContext: TNodeExecutionContext);
begin
  var Idx := NodeValueToIntDef(AContext.GetInputValueOrVar(FIndexPin), 0);
  var B := NodeValueToBoolDef(AContext.GetInputValueOrVar(FValuePin), False);

  AContext.SetVariable('last_set_prime_index', MakeIntValue(Idx));
  AContext.SetVariableBool('last_set_prime_value', B);

  AContext.SetVariableBool('prime_' + IntToStr(Idx), B);
  AContext.SelectExecOutput(FExecOut);
end;

{ TCollectPrimeNode }

constructor TCollectPrimeNode.Create;
begin
  inherited;
  Width := 230;
  Height := 140;
  NodeType := 'collectprime';
  HeaderColor := $FF4F3B73;
  IconPath := 'M21 7.25h-3l.77-3.07a.75.75 0 0 0-1.46-.36l-.86 3.43H10l.77-3.07a.75.75 0 0 0-1.46-.36l-.9 3.43H5a.75.75 0 0 0 0 1.5h3l-1.63 6.5H3a.75.75 0 0 0 0 1.5h3l-.77 3.07a.75.75 0 0 0 1.46.36l.86-3.43H14l-.77 3.07a.75.75 0 0 0 1.46.36l.86-3.43H19a.75.75 0 0 0 0-1.5h-3l1.63-6.5H21a.75.75 0 0 0 0-1.5m-5 1.5l-1.63 6.5H8l1.63-6.5Z';
end;

procedure TCollectPrimeNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', TNodeValueKind.Null, False, TPinKind.Exec);
  FPrimePin := AddInputPin('Prime', TNodeValueKind.Integer, False, TPinKind.Data);
  FExecOut := AddOutputPin('Next', TNodeValueKind.Null, False, TPinKind.Exec);
  FListOut := AddOutputPin('List', TNodeValueKind.string, False, TPinKind.Data);

  if FindValue('Prime') = nil then
  begin
    var V := AddValue('Prime', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;
end;

procedure TCollectPrimeNode.Execute(AContext: TNodeExecutionContext);
begin
  var P := NodeValueToIntDef(AContext.GetInputValueOrVar(FPrimePin), 0);
  var S := AContext.GetVariableStr('primes', '');

  S := if S = '' then P.ToString else S + ', ' + P.ToString;

  AContext.SetVariable('last_collected_prime', MakeIntValue(P));
  AContext.SetVariableStr('primes', S);
  AContext.SetOutputValue(FListOut, MakeStringValue(S));
  AContext.SelectExecOutput(FExecOut);
end;

{ TNotExecNode }

constructor TNotExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'boolnot';
  HeaderColor := $FFB9075C;
  IconPath := 'M105 111.3v289.4L365.5 256ZM16 247v18h71v-18zm400-14c-12.8 0-23 10.2-23 23s10.2 23 23 23s23-10.2 23-23s-10.2-23-23-23m40 14c.6 2.9 1 5.9 1 9s-.4 6.1-1 9h40v-18z';
end;

procedure TNotExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    not
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FValuePin), False);
  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TNotExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('Value') = nil then
  begin
    var V := AddValue('Value', TNodeValueKind.Boolean);
    V.BooleanValue := True;
  end;
end;

{ TAndExecNode }

constructor TAndExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'booland';
  HeaderColor := $FFB9075C;
  IconPath := 'M105 105v302h151c148 0 148-302 0-302zm-89 46v18h71v-18zm368.8 96q.3 9 0 18H496v-18zM16 343v18h71v-18z';
end;

procedure TAndExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FAPin), False)
    and
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FBPin), False);

  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TAndExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FAPin := AddInputPin('A', TNodeValueKind.Boolean, False, TPinKind.Data);
  FBPin := AddInputPin('B', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

{ TNotAndExecNode }

constructor TNotAndExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'boolnand';
  HeaderColor := $FFB9075C;
  IconPath := 'M105 105v302h151c148 0 148-302 0-302zm-89 46v18h71v-18zm400 82c-12.8 0-23 10.2-23 23s10.2 23 23 23s23-10.2 23-23s-10.2-23-23-23m40 14c.6 2.9 1 5.9 1 9s-.4 6.1-1 9h40v-18zM16 343v18h71v-18z';
end;

procedure TNotAndExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    not
    (
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FAPin), False)
    and
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FBPin), False)
    );

  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TNotAndExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FAPin := AddInputPin('A', TNodeValueKind.Boolean, False, TPinKind.Data);
  FBPin := AddInputPin('B', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

{ TOrExecNode }

constructor TOrExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'boolor';
  HeaderColor := $FFB9075C;
  IconPath := 'M116.6 407c40-45.9 60.4-98.4 60.4-151s-20.4-105.1-60.4-151H192c34.1 0 81.9 34 119.3 71.4c18.7 18.6 35.1 37.9 46.6 53.3c5.8 7.6 10.4 14.4 13.4 19.4c1.4 2.5 2.5 4.7 3.2 6.1c.1.4.2.5.2.8s-.1.5-.2.9c-.6 1.4-1.7 3.5-3.2 6c-3 5.1-7.5 11.8-13.2 19.5c-11.3 15.4-27.5 34.6-46.1 53.2C274.8 373 227.1 407 192 407zM16 361v-18h122.2q-4.5 9.15-9.9 18zm374.5-96c.2-.3.4-.7.5-1c1.1-2.4 2-4.4 2-8s-1-5.6-2-8c-.1-.3-.3-.7-.5-1H496v18zM16 169v-18h112.3q5.4 8.85 9.9 18z';
end;

procedure TOrExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FAPin), False)
    or
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FBPin), False);

  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TOrExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FAPin := AddInputPin('A', TNodeValueKind.Boolean, False, TPinKind.Data);
  FBPin := AddInputPin('B', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

{ TNotOrExecNode }

constructor TNotOrExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'boolnor';
  HeaderColor := $FFB9075C;
  IconPath := 'M116.6 105c40 45.9 60.4 98.4 60.4 151s-20.4 105.1-60.4 151H192c34.1 0 81.9-34 119.3-71.4c18.7-18.6 35.1-37.9 46.6-53.3c5.8-7.6 10.4-14.4 13.4-19.4c1.4-2.5 2.5-4.7 3.2-6.1c.1-.4.2-.5.2-.8s-.1-.5-.2-.9c-.6-1.4-1.7-3.5-3.2-6c-3-5.1-7.5-11.8-13.2-19.5c-11.3-15.4-27.5-34.6-46.1-53.2C274.8 139 227.1 105 192 105zM16 151v18h122.2q-4.5-9.15-9.9-18zm400 82c-12.8 0-23 10.2-23 23s10.2 23 23 23s23-10.2 23-23s-10.2-23-23-23m40 14c.6 2.9 1 5.9 1 9s-.4 6.1-1 9h40v-18zM16 343v18h112.3q5.4-8.85 9.9-18z';
end;

procedure TNotOrExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    not
    (
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FAPin), False)
    or
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FBPin), False)
    );

  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TNotOrExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FAPin := AddInputPin('A', TNodeValueKind.Boolean, False, TPinKind.Data);
  FBPin := AddInputPin('B', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

{ TXOrExecNode }

constructor TXOrExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'boolxor';
  HeaderColor := $FFB9075C;
  IconPath := 'M53.86 89.17L42.14 102.8c17.99 15.4 32.89 31.6 44.81 48.2H16v18h82.58C114.9 197.3 123 226.7 123 256s-8.1 58.7-24.42 87H16v18h70.95c-11.92 16.6-26.82 32.8-44.81 48.2l11.72 13.6c22.59-19.4 40.85-40.1 54.74-61.8h19.7q5.4-8.85 9.9-18H119c14.6-28.2 22-57.5 22-87s-7.4-58.8-22-87h19.2q-4.5-9.15-9.9-18h-19.7c-13.88-21.7-32.15-42.5-54.74-61.83M116.6 105c40 45.9 60.4 98.4 60.4 151s-20.4 105.1-60.4 151H192c34.1 0 81.9-34 119.3-71.4c18.7-18.6 35.1-37.9 46.6-53.3c5.8-7.6 10.4-14.4 13.4-19.4c1.4-2.5 2.5-4.7 3.2-6.1c.1-.4.2-.5.2-.8s-.1-.5-.2-.9c-.6-1.4-1.7-3.5-3.2-6c-3-5.1-7.5-11.8-13.2-19.5c-11.3-15.4-27.5-34.6-46.1-53.2C274.8 139 227.1 105 192 105zm273.9 142c.2.3.4.7.5 1c1.1 2.4 2 4.4 2 8s-1 5.6-2 8c-.1.3-.3.7-.5 1H496v-18z';
end;

procedure TXOrExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FAPin), False)
    xor
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FBPin), False);

  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TXOrExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FAPin := AddInputPin('A', TNodeValueKind.Boolean, False, TPinKind.Data);
  FBPin := AddInputPin('B', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

{ TXNotOrExecNode }

constructor TXNotOrExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'boolxnor';
  HeaderColor := $FFB9075C;
  IconPath :=
    'M53.86 89.17L42.14 102.8c17.99 15.4 32.89 31.6 44.81 48.2H16v18h82.58C114.9 197.3 123 226.7 123 256s-8.1 58.7-24.42 87H16v18h70.95c-11.92 16.6-26.82 32.8-44.81 48.2l11.72 13.6c22.59-19.4 40.85-40.1 54.74-61.8h19.7q5.4-8.85 9.9-18H119c14.6-28.2 22-57.5 22-87s-7.4-58.8-22-87h19.2q-4.5-9.15-9.9-18h-19.7c-13.88-21.7-32.15-42.5-54.74-61.83M116.6 105c40 45.9 60.4 98.4 60.4 151s-20.4 105.1-60.4 151H192c34.1 0 81.9-34 119.3-71.4c18.7-18.6 35.1-37.9 46.6-53.3c5.8-7.6 10.4-14.4 13.4-19.4c1.4-2.5 2.5-4.7 3.2-6.1c.1-.4.2-.5.2-.8s-.1-.5-.2-.9c-.6-1.4-1.7-3.5-3.2-6c-3-5.1-7.5-11.8-13.2-19.5c-11.3-15.4-27.5-34.6-46.1-53.2C274.8 139 227.1 105 192 105zM416 233c-12.8 0-23 10.2-23 23s10.2 23 23 23s23-10.2 23-23s-10.2-23-23-23m40 14c.6 2.9 1 5.9 1 9s-.4 6.1-1 9h40v-18z';
end;

procedure TXNotOrExecNode.Execute(AContext: TNodeExecutionContext);
begin
  var Value :=
    not
    (
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FAPin), False)
    xor
    NodeValueToBoolDef(AContext.GetInputValueOrVar(FBPin), False)
    );

  AContext.SetOutputValue(FResult, MakeBoolValue(Value));
  AContext.SelectExecOutput(FExecOut);
end;

procedure TXNotOrExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FAPin := AddInputPin('A', TNodeValueKind.Boolean, False, TPinKind.Data);
  FBPin := AddInputPin('B', TNodeValueKind.Boolean, False, TPinKind.Data);
  FResult := AddOutputPin('Result', TNodeValueKind.Boolean, False, TPinKind.Data);

  if FindValue('A') = nil then
  begin
    var V := AddValue('A', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;

  if FindValue('B') = nil then
  begin
    var V := AddValue('B', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

procedure RegisterEngineeringNodes(ARegistry: TNodeRegistry);
begin
  if ARegistry = nil then
    Exit;

  ARegistry.RegisterNodeEx('intconst', 'Int Constant', 'Variable',
    'Integer constant node', 'int,constant,number', '', TIntConstNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('floatconst', 'Float Constant', 'Variable',
    'Float constant node', 'float,constant,number', '', TFloatConstNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('boolconst', 'Bool Constant', 'Variable',
    'Boolean constant node', 'bool,constant,logic', '', TBoolConstNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('stringconst', 'String Constant', 'Variable',
    'String constant node', 'string,text,constant', '', TStringConstNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('colorconst', 'Color Constant', 'Variable',
    'Color constant node', 'color,constant', '', TColorConstNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('colorrgbaconst', 'Color RGBA Constant', 'Variable',
    'Color rgba constant node', 'color,constant,rgba', '', TColorRGBAConstNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('intrandom', 'Int Random', 'Variable',
    'Integer random node', 'int,random,number', '', TIntRandomNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('floatrandom', 'Float Random', 'Variable',
    'Float random node', 'float,random,number', '', TFloatRandomNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('setvar', 'Set Variable', 'Variable',
    'Set runtime variable', 'variable,set,assign', '', TSetVariableNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('getvar', 'Get Variable', 'Variable',
    'Get runtime variable', 'variable,get,read', '', TGetVariableNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('addexec', 'Add', 'Math',
    'A + B', 'math,add,sum,pluse', '', TAddExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('subexec', 'Subtract', 'Math',
    'A - B', 'math,sub', '', TSubExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('mulexec', 'Multiply', 'Math',
    'A * B', 'math,mul', '', TMulExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('divexec', 'Divide', 'Math',
    'A / B', 'math,div', '', TDivExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('modexec', 'Modulo', 'Math',
    'A mod B', 'math,mod', '', TModExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('powexec', 'Power', 'Math',
    'Base ^ Exponent', 'math,pow', '', TPowExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('sqrtexec', 'Sqrt', 'Math',
    'sqrt(x)', 'math,sqrt', '', TSqrtExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('absexec', 'Abs', 'Math',
    'abs(x)', 'math,abs', '', TAbsExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('logexec', 'Log10', 'Math',
    'log10(x)', 'math,log', '', TLogExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('lnexec', 'Ln', 'Math',
    'ln(x)', 'math,ln', '', TLnExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('floorexec', 'Floor', 'Math',
    'floor(x)', 'math,floor', '', TFloorExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('ceilexec', 'Ceil', 'Math',
    'ceil(x)', 'math,ceil', '', TCeilExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('roundexec', 'Round', 'Math',
    'round(x)', 'math,round', '', TRoundExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('negative', 'Negative', 'Math',
    '-(x)', 'math,negative,minus', '', TNegativeExecNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('sinexec', 'Sin', 'Geometry',
    'sin(x)', 'math,trig,sin', '', TSinExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('cosexec', 'Cos', 'Geometry',
    'cos(x)', 'math,trig,cos', '', TCosExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('tanexec', 'Tan', 'Geometry',
    'tan(x)', 'math,trig,tan', '', TTanExecNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('greater', 'Greater', 'Logic Сomparison',
    'A > B', 'compare,greater', '', TGreaterNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('less', 'Less', 'Logic Сomparison',
    'A < B', 'compare,less', '', TLessNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('greaterorequal', 'Greater Or Equal', 'Logic Сomparison',
    'A >= B', 'compare,greater,equal', '', TGreaterOrEqualNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('lessorequal', 'Less Or Equal', 'Logic Сomparison',
    'A <= B', 'compare,less,equal', '', TLessOrEqualNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('equal', 'Equal', 'Logic Сomparison',
    'A = B', 'compare,equal', '', TEqualNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('notequal', 'Not Equal', 'Logic Сomparison',
    'A <> B (A != B)', 'compare,not,equal', '', TNotEqualNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('boolnot', 'NOT', 'Logic',
    'not Value', 'bool,not', '', TNotExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('booland', 'AND', 'Logic',
    'A and B', 'bool,and', '', TAndExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('boolor', 'OR', 'Logic',
    'A or B', 'bool,or', '', TOrExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('boolxor', 'XOR', 'Logic',
    'A xor B', 'bool,xor', '', TXOrExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('boolnand', 'NAND', 'Logic',
    'not (A and B)', 'bool,not,and', '', TNotAndExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('boolnor', 'NOR', 'Logic',
    'not (A or B) ', 'bool,not,or', '', TNotOrExecNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('boolxnor', 'XNOR', 'Logic',
    'not (A xor B)', 'bool,not,xor', '', TXNotOrExecNode, TAlphaColors.Null);

  ARegistry.RegisterNodeEx('isprimeflag', 'Is Prime Flag', 'Engineering',
    'Read prime_i variable', 'prime,sieve,bool', '', TIsPrimeFlagNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('setprimeflag', 'Set Prime Flag', 'Engineering',
    'Write prime_i variable', 'prime,sieve,set', '', TSetPrimeFlagNode, TAlphaColors.Null);
  ARegistry.RegisterNodeEx('collectprime', 'Collect Prime', 'Engineering',
    'Append prime to list', 'prime,sieve,collect', '', TCollectPrimeNode, TAlphaColors.Null);
end;

initialization
  Randomize;

end.

