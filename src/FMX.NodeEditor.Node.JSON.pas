unit FMX.NodeEditor.Node.JSON;

interface

uses
  FMX.NodeEditor.Node, System.SysUtils, System.Types, System.UITypes,
  FMX.Graphics, FMX.NodeEditor.Types, FMX.NodeEditor.Executor.Runtime,
  FMX.NodeEditor.Graph, System.Rtti;

type
  TJSONValueNode = class(TExecutableNode)
    FInput: TNodePin;
  public
    constructor Create; override;
    procedure SetupPins; override;
    procedure UpdateNodeData; override;
  public
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

procedure RegisterJSONValueNodes(ARegistry: TNodeRegistry);

implementation

uses
  System.Math, System.JSON, FMX.Types;

{ TJSONValueNode }

constructor TJSONValueNode.Create;
begin
  inherited;
  Width := 200;
  Height := 200;
  NodeType := 'json_value';
  HeaderColor := $FF737373;
end;

procedure TJSONValueNode.SetupPins;
begin
  ClearPins;
  FInput := AddInputPinAndValue('JSON', TNodeValueKind.JSON, False, TPinKind.Data, '');
end;

procedure TJSONValueNode.UpdateNodeData;
begin
  inherited;
  SetupPins;
  var Value := GetValue('JSON');
  if Assigned(Value) then
  begin
    try
      var JSON := TJSONValue.ParseJSONValue(Value.JSONValue);
      if Assigned(JSON) then
      try
        if JSON is TJSONObject then
        begin
          var JO := TJSONObject(JSON);
          for var Pair in JO do
          begin
            if Pair.JsonValue is TJSONString then
            begin
              var PinName := Pair.JsonString.Value;
              AddOutputPin(PinName, TNodeValueKind.string, False, TPinKind.Data);
            end
            else if Pair.JsonValue is TJSONNumber then
            begin
              var PinName := Pair.JsonString.Value;
              AddOutputPin(PinName, TNodeValueKind.Float, False, TPinKind.Data);
            end
            else if Pair.JsonValue is TJSONBool then
            begin
              var PinName := Pair.JsonString.Value;
              AddOutputPin(PinName, TNodeValueKind.Boolean, False, TPinKind.Data);
            end
            else if Pair.JsonValue is TJSONObject then
            begin
              var PinName := Pair.JsonString.Value;
              AddOutputPin(PinName, TNodeValueKind.JSON, False, TPinKind.Data);
            end
            else if Pair.JsonValue is TJSONArray then
            begin
              var PinName := Pair.JsonString.Value;
              AddOutputPin(PinName, TNodeValueKind.string, False, TPinKind.Data);
            end;
          end;
        end;
      finally
        JSON.Free;
      end;
    except
      //
    end;
  end;
end;

procedure TJSONValueNode.Execute(AContext: TNodeExecutionContext);
begin
  //AContext.SetOutputValue(FOutputs[0], AContext.GetInputValue(FInputs[0]));

  var JSONValue := NodeValueToStringDef(AContext.GetInputValueOrVar(FInput), '');
  if JSONValue.IsEmpty then
    Exit;
  var JSON := TJSONValue.ParseJSONValue(JSONValue);
  if not Assigned(JSON) then
    Exit;
  try
    for var Output in FOutputs do
    begin
      case Output.PinType.TypeId of
        TNodeValueKind.Null:
          AContext.SetOutputValue(Output, TValue.Empty);
        TNodeValueKind.Float:
          AContext.SetOutputValue(Output, MakeFloatValue(JSON.GetValue<Double>(Output.Name, 0)));
        TNodeValueKind.Integer:
          AContext.SetOutputValue(Output, MakeIntValue(JSON.GetValue<Int64>(Output.Name, 0)));
        TNodeValueKind.string:
          AContext.SetOutputValue(Output, MakeStringValue(JSON.GetValue<string>(Output.Name, '')));
        TNodeValueKind.Boolean:
          AContext.SetOutputValue(Output, MakeBoolValue(JSON.GetValue<Boolean>(Output.Name, False)));
        TNodeValueKind.JSON:
          begin
            var Value := JSON.FindValue(Output.Name);
            if Assigned(Value) then
              AContext.SetOutputValue(Output, MakeStringValue(Value.ToString));
          end;
      end;
    end;
  finally
    JSON.Free;
  end;
end;

procedure RegisterJSONValueNodes(ARegistry: TNodeRegistry);
begin
  if ARegistry = nil then
    Exit;
                {
  ARegistry.RegisterNodeEx('json_value', 'JSON Value', 'JSON',
    'JSON Value', 'json', '', TJSONValueNode, TAlphaColors.Null);  }
end;

end.

