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
unit FMX.NodeEditor.Node.Engineering;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Rtti,
  FMX.NodeEditor.Types, FMX.NodeEditor.Node, FMX.NodeEditor.Runtime,
  FMX.NodeEditor.Node.Graph;

type
  { executable math node }
  TExecMathNode = class(TExecutableNode)
  protected
    FExecIn: TNodePin;
    FExecOut: TNodePin;
    procedure AddExecPins;
  end;

  { Константы / переменные }

  TIntConstNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TBoolConstNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
    FValueOut: TNodePin;
  protected
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TStringConstNode = class(TExecutableNode)
  private
    FExecIn, FExecOut: TNodePin;
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

  { Арифметика }

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

  { Тригонометрия }

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

  { Инженерные функции }

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

  { Сравнения }

  TGreaterNode = class(TExecMathNode)
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

  { Узлы под решето }

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

procedure TExecMathNode.AddExecPins;
begin
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
end;

{ TIntConstNode }

constructor TIntConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'intconst';
  HeaderColor := $FFC8E6C9;
end;

procedure TIntConstNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueOut := AddOutputPin('Value', 'integer', TPinKind.Data);

  if FindValue('value') = nil then
  begin
    V := AddValue('value', TNodeValueKind.Integer);
    V.IntegerValue := 0;
  end;
end;

procedure TIntConstNode.Execute(AContext: TNodeExecutionContext);
var
  V: TNodeValue;
begin
  V := FindValue('value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeIntValue(V.IntegerValue))
  else
    AContext.SetOutputValue(FValueOut, MakeIntValue(0));
  AContext.SelectExecOutput(FExecOut);
end;

{ TBoolConstNode }

constructor TBoolConstNode.Create;
begin
  inherited;
  Width := 180;
  Height := 110;
  NodeType := 'boolconst';
  HeaderColor := $FFFFF59D;
end;

procedure TBoolConstNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueOut := AddOutputPin('Value', 'bool', TPinKind.Data);

  if FindValue('value') = nil then
  begin
    V := AddValue('value', TNodeValueKind.Boolean);
    V.BooleanValue := False;
  end;
end;

procedure TBoolConstNode.Execute(AContext: TNodeExecutionContext);
var
  V: TNodeValue;
begin
  V := FindValue('value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeBoolValue(V.BooleanValue))
  else
    AContext.SetOutputValue(FValueOut, MakeBoolValue(False));
  AContext.SelectExecOutput(FExecOut);
end;

{ TStringConstNode }

constructor TStringConstNode.Create;
begin
  inherited;
  Width := 200;
  Height := 110;
  NodeType := 'stringconst';
  HeaderColor := $FFB3E5FC;
end;

procedure TStringConstNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueOut := AddOutputPin('Value', 'string', TPinKind.Data);

  if FindValue('value') = nil then
  begin
    V := AddValue('value', TNodeValueKind.string);
    V.StringValue := '';
  end;
end;

procedure TStringConstNode.Execute(AContext: TNodeExecutionContext);
var
  V: TNodeValue;
begin
  V := FindValue('value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeStringValue(V.StringValue))
  else
    AContext.SetOutputValue(FValueOut, MakeStringValue(''));
  AContext.SelectExecOutput(FExecOut);
end;

{ TSetVariableNode }

constructor TSetVariableNode.Create;
begin
  inherited;
  Width := 220;
  Height := 130;
  NodeType := 'setvar';
  HeaderColor := $FFD1C4E9;
end;

procedure TSetVariableNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FNamePin := AddInputPin('Name', 'string', TPinKind.Data);
  FValuePin := AddInputPin('Value', 'any', TPinKind.Data);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
end;

procedure TSetVariableNode.Execute(AContext: TNodeExecutionContext);
var
  N: string;
  V: TValue;
begin
  N := NodeValueToStringDef(AContext.GetInputValue(FNamePin), '');
  V := AContext.GetInputValue(FValuePin);
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
  HeaderColor := $FFD1C4E9;
end;

procedure TGetVariableNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FNamePin := AddInputPin('Name', 'string', TPinKind.Data);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueOut := AddOutputPin('Value', 'any', TPinKind.Data);
end;

procedure TGetVariableNode.Execute(AContext: TNodeExecutionContext);
var
  N: string;
begin
  N := NodeValueToStringDef(AContext.GetInputValue(FNamePin), '');
  AContext.SetOutputValue(FValueOut, AContext.GetVariableValue(N));
  AContext.SelectExecOutput(FExecOut);
end;

{ Арифметика }

constructor TAddExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'addexec';
  HeaderColor := $FFD0A0FF;
end;

procedure TAddExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TAddExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0) +
      NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TSubExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'subexec';
  HeaderColor := $FFD0A0FF;
end;

procedure TSubExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TSubExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0) -
      NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TMulExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'mulexec';
  HeaderColor := $FFD0A0FF;
end;

procedure TMulExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TMulExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0) *
      NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TDivExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'divexec';
  HeaderColor := $FFD0A0FF;
end;

procedure TDivExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TDivExecNode.Execute(AContext: TNodeExecutionContext);
var
  B: Double;
begin
  B := NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0);
  if Abs(B) < 1e-12 then
    raise ENodeExecutionError.Create('Division by zero');
  AContext.SetOutputValue(FResult, MakeFloatValue(
      NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0) / B
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TModExecNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'modexec';
  HeaderColor := $FFD0A0FF;
end;

procedure TModExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'integer', TPinKind.Data);
  FB := AddInputPin('B', 'integer', TPinKind.Data);
  FResult := AddOutputPin('Result', 'integer', TPinKind.Data);
end;

procedure TModExecNode.Execute(AContext: TNodeExecutionContext);
var
  AInt, BInt: Int64;
begin
  AInt := NodeValueToIntDef(AContext.GetInputValue(FA), 0);
  BInt := NodeValueToIntDef(AContext.GetInputValue(FB), 1);
  if BInt = 0 then
    raise ENodeExecutionError.Create('Modulo by zero');
  AContext.SetOutputValue(FResult, MakeIntValue(AInt mod BInt));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TPowExecNode.Create;
begin
  inherited;
  Width := 200;
  Height := 140;
  NodeType := 'powexec';
  HeaderColor := $FFD0A0FF;
end;

procedure TPowExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FBasePin := AddInputPin('Base', 'float', TPinKind.Data);
  FExpPin := AddInputPin('Exponent', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TPowExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Power(
        NodeValueToFloatDef(AContext.GetInputValue(FBasePin), 0.0),
        NodeValueToFloatDef(AContext.GetInputValue(FExpPin), 0.0)
      )
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ trig }

constructor TSinExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'sinexec';
  HeaderColor := $FFFFCC80;
end;

procedure TSinExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Radians', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TSinExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Sin(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TCosExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'cosexec';
  HeaderColor := $FFFFCC80;
end;

procedure TCosExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Radians', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TCosExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Cos(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TTanExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'tanexec';
  HeaderColor := $FFFFCC80;
end;

procedure TTanExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Radians', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TTanExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Tan(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ engineering }

constructor TSqrtExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'sqrtexec';
  HeaderColor := $FFAED581;
end;

procedure TSqrtExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TSqrtExecNode.Execute(AContext: TNodeExecutionContext);
var
  V: Double;
begin
  V := NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0);
  if V < 0 then
    raise ENodeExecutionError.Create('SQRT from negative number');
  AContext.SetOutputValue(FResult, MakeFloatValue(Sqrt(V)));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TAbsExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'absexec';
  HeaderColor := $FFAED581;
end;

procedure TAbsExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TAbsExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeFloatValue(
      Abs(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TLogExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'logexec';
  HeaderColor := $FFAED581;
end;

procedure TLogExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TLogExecNode.Execute(AContext: TNodeExecutionContext);
var
  V: Double;
begin
  V := NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 1.0);
  if V <= 0 then
    raise ENodeExecutionError.Create('LOG10 argument must be > 0');
  AContext.SetOutputValue(FResult, MakeFloatValue(Log10(V)));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TLnExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'lnexec';
  HeaderColor := $FFAED581;
end;

procedure TLnExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'float', TPinKind.Data);
end;

procedure TLnExecNode.Execute(AContext: TNodeExecutionContext);
var
  V: Double;
begin
  V := NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 1.0);
  if V <= 0 then
    raise ENodeExecutionError.Create('LN argument must be > 0');
  AContext.SetOutputValue(FResult, MakeFloatValue(Ln(V)));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TFloorExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'floorexec';
  HeaderColor := $FFAED581;
end;

procedure TFloorExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'integer', TPinKind.Data);
end;

procedure TFloorExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeIntValue(
      Floor(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TCeilExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'ceilexec';
  HeaderColor := $FFAED581;
end;

procedure TCeilExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'integer', TPinKind.Data);
end;

procedure TCeilExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeIntValue(
      Ceil(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TRoundExecNode.Create;
begin
  inherited;
  Width := 180;
  Height := 130;
  NodeType := 'roundexec';
  HeaderColor := $FFAED581;
end;

procedure TRoundExecNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FValuePin := AddInputPin('Value', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'integer', TPinKind.Data);
end;

procedure TRoundExecNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeIntValue(
      Round(NodeValueToFloatDef(AContext.GetInputValue(FValuePin), 0.0))
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ compare }

constructor TGreaterNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'greater';
  HeaderColor := $FFEF9A9A;
end;

procedure TGreaterNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'bool', TPinKind.Data);
end;

procedure TGreaterNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0) >
      NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TLessNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'less';
  HeaderColor := $FFEF9A9A;
end;

procedure TLessNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'bool', TPinKind.Data);
end;

procedure TLessNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0) <
      NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0)
    ));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TEqualNode.Create;
begin
  inherited;
  Width := 190;
  Height := 140;
  NodeType := 'equal';
  HeaderColor := $FFEF9A9A;
end;

procedure TEqualNode.SetupPins;
begin
  ClearPins;
  AddExecPins;
  FA := AddInputPin('A', 'float', TPinKind.Data);
  FB := AddInputPin('B', 'float', TPinKind.Data);
  FResult := AddOutputPin('Result', 'bool', TPinKind.Data);
end;

procedure TEqualNode.Execute(AContext: TNodeExecutionContext);
begin
  AContext.SetOutputValue(FResult, MakeBoolValue(
      SameValue(
        NodeValueToFloatDef(AContext.GetInputValue(FA), 0.0),
        NodeValueToFloatDef(AContext.GetInputValue(FB), 0.0),
        1e-9
      )
    ));
  AContext.SelectExecOutput(FExecOut);
end;

{ решето }

constructor TIsPrimeFlagNode.Create;
begin
  inherited;
  Width := 220;
  Height := 130;
  NodeType := 'isprimeflag';
  HeaderColor := $FFB2DFDB;
end;

procedure TIsPrimeFlagNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FIndexPin := AddInputPin('Index', 'integer', TPinKind.Data);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueOut := AddOutputPin('IsPrime', 'bool', TPinKind.Data);
end;

procedure TIsPrimeFlagNode.Execute(AContext: TNodeExecutionContext);
var
  Idx: Int64;
  B: Boolean;
begin
  Idx := NodeValueToIntDef(AContext.GetInputValue(FIndexPin), 0);
  B := AContext.GetVariableBool('prime_' + IntToStr(Idx), False);

  AContext.SetVariable('last_prime_check_index', MakeIntValue(Idx));
  AContext.SetVariableBool('last_prime_check_value', B);

  AContext.SetOutputValue(FValueOut, MakeBoolValue(B));
  AContext.SelectExecOutput(FExecOut);
end;

constructor TSetPrimeFlagNode.Create;
begin
  inherited;
  Width := 220;
  Height := 140;
  NodeType := 'setprimeflag';
  HeaderColor := $FFB2DFDB;
end;

procedure TSetPrimeFlagNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FIndexPin := AddInputPin('Index', 'integer', TPinKind.Data);
  FValuePin := AddInputPin('Value', 'bool', TPinKind.Data);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
end;

procedure TSetPrimeFlagNode.Execute(AContext: TNodeExecutionContext);
var
  Idx: Int64;
  B: Boolean;
begin
  Idx := NodeValueToIntDef(AContext.GetInputValue(FIndexPin), 0);
  B := NodeValueToBoolDef(AContext.GetInputValue(FValuePin), False);

  AContext.SetVariable('last_set_prime_index', MakeIntValue(Idx));
  AContext.SetVariableBool('last_set_prime_value', B);

  AContext.SetVariableBool('prime_' + IntToStr(Idx), B);
  AContext.SelectExecOutput(FExecOut);
end;

constructor TCollectPrimeNode.Create;
begin
  inherited;
  Width := 230;
  Height := 140;
  NodeType := 'collectprime';
  HeaderColor := $FFB39DDB;
end;

procedure TCollectPrimeNode.SetupPins;
begin
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FPrimePin := AddInputPin('Prime', 'integer', TPinKind.Data);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FListOut := AddOutputPin('List', 'string', TPinKind.Data);
end;

procedure TCollectPrimeNode.Execute(AContext: TNodeExecutionContext);
var
  P: Int64;
  S: string;
begin
  P := NodeValueToIntDef(AContext.GetInputValue(FPrimePin), 0);
  S := AContext.GetVariableStr('primes', '');

  if S = '' then
    S := IntToStr(P)
  else
    S := S + ', ' + IntToStr(P);

  AContext.SetVariable('last_collected_prime', MakeIntValue(P));
  AContext.SetVariableStr('primes', S);
  AContext.SetOutputValue(FListOut, MakeStringValue(S));
  AContext.SelectExecOutput(FExecOut);
end;

procedure RegisterEngineeringNodes(ARegistry: TNodeRegistry);
begin
  if ARegistry = nil then
    Exit;

  ARegistry.RegisterNodeEx('intconst', 'Int Constant', 'Engineering',
    'Integer constant node', 'int,constant,number', '', TIntConstNode, $FFC8E6C9);
  ARegistry.RegisterNodeEx('boolconst', 'Bool Constant', 'Engineering',
    'Boolean constant node', 'bool,constant,logic', '', TBoolConstNode, $FFFFF59D);
  ARegistry.RegisterNodeEx('stringconst', 'String Constant', 'Engineering',
    'String constant node', 'string,text,constant', '', TStringConstNode, $FFB3E5FC);

  ARegistry.RegisterNodeEx('setvar', 'Set Variable', 'Engineering',
    'Set runtime variable', 'variable,set,assign', '', TSetVariableNode, $FFD1C4E9);
  ARegistry.RegisterNodeEx('getvar', 'Get Variable', 'Engineering',
    'Get runtime variable', 'variable,get,read', '', TGetVariableNode, $FFD1C4E9);

  ARegistry.RegisterNodeEx('addexec', 'Add', 'Engineering',
    'A + B', 'math,add,sum', '', TAddExecNode, $FFD0A0FF);
  ARegistry.RegisterNodeEx('subexec', 'Subtract', 'Engineering',
    'A - B', 'math,sub', '', TSubExecNode, $FFD0A0FF);
  ARegistry.RegisterNodeEx('mulexec', 'Multiply', 'Engineering',
    'A * B', 'math,mul', '', TMulExecNode, $FFD0A0FF);
  ARegistry.RegisterNodeEx('divexec', 'Divide', 'Engineering',
    'A / B', 'math,div', '', TDivExecNode, $FFD0A0FF);
  ARegistry.RegisterNodeEx('modexec', 'Modulo', 'Engineering',
    'A mod B', 'math,mod', '', TModExecNode, $FFD0A0FF);
  ARegistry.RegisterNodeEx('powexec', 'Power', 'Engineering',
    'Base ^ Exponent', 'math,pow', '', TPowExecNode, $FFD0A0FF);

  ARegistry.RegisterNodeEx('sinexec', 'Sin', 'Engineering',
    'sin(x)', 'math,trig,sin', '', TSinExecNode, $FFFFCC80);
  ARegistry.RegisterNodeEx('cosexec', 'Cos', 'Engineering',
    'cos(x)', 'math,trig,cos', '', TCosExecNode, $FFFFCC80);
  ARegistry.RegisterNodeEx('tanexec', 'Tan', 'Engineering',
    'tan(x)', 'math,trig,tan', '', TTanExecNode, $FFFFCC80);

  ARegistry.RegisterNodeEx('sqrtexec', 'Sqrt', 'Engineering',
    'sqrt(x)', 'math,sqrt', '', TSqrtExecNode, $FFAED581);
  ARegistry.RegisterNodeEx('absexec', 'Abs', 'Engineering',
    'abs(x)', 'math,abs', '', TAbsExecNode, $FFAED581);
  ARegistry.RegisterNodeEx('logexec', 'Log10', 'Engineering',
    'log10(x)', 'math,log', '', TLogExecNode, $FFAED581);
  ARegistry.RegisterNodeEx('lnexec', 'Ln', 'Engineering',
    'ln(x)', 'math,ln', '', TLnExecNode, $FFAED581);
  ARegistry.RegisterNodeEx('floorexec', 'Floor', 'Engineering',
    'floor(x)', 'math,floor', '', TFloorExecNode, $FFAED581);
  ARegistry.RegisterNodeEx('ceilexec', 'Ceil', 'Engineering',
    'ceil(x)', 'math,ceil', '', TCeilExecNode, $FFAED581);
  ARegistry.RegisterNodeEx('roundexec', 'Round', 'Engineering',
    'round(x)', 'math,round', '', TRoundExecNode, $FFAED581);

  ARegistry.RegisterNodeEx('greater', 'Greater', 'Engineering',
    'A > B', 'compare,greater', '', TGreaterNode, $FFEF9A9A);
  ARegistry.RegisterNodeEx('less', 'Less', 'Engineering',
    'A < B', 'compare,less', '', TLessNode, $FFEF9A9A);
  ARegistry.RegisterNodeEx('equal', 'Equal', 'Engineering',
    'A = B', 'compare,equal', '', TEqualNode, $FFEF9A9A);

  ARegistry.RegisterNodeEx('isprimeflag', 'Is Prime Flag', 'Engineering',
    'Read prime_i variable', 'prime,sieve,bool', '', TIsPrimeFlagNode, $FFB2DFDB);
  ARegistry.RegisterNodeEx('setprimeflag', 'Set Prime Flag', 'Engineering',
    'Write prime_i variable', 'prime,sieve,set', '', TSetPrimeFlagNode, $FFB2DFDB);
  ARegistry.RegisterNodeEx('collectprime', 'Collect Prime', 'Engineering',
    'Append prime to list', 'prime,sieve,collect', '', TCollectPrimeNode, $FFB39DDB);
end;

end.

