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
unit FMX.NodeEditor.JSON;

interface

uses
  System.Classes, System.SysUtils, FMX.Controls, FMX.Dialogs, System.JSON,
  FMX.NodeEditor, FMX.NodeEditor.Node, System.Generics.Collections,
  FMX.NodeEditor.Types;

type
  TJSONNodeKind = (
    jnkObject,
    jnkArray,
    jnkString,
    jnkNumber,
    jnkBoolean,
    jnkNull
    );

  TJsonNode = class(TCustomNode)
  private
    FJsonKind: TJSONNodeKind;
  public
    JsonName: string;

    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 220; AHeight: integer = 120); override;

    procedure SetupPins; override;

    function AddJsonChildOutput(const AName: string): TNodePin;
    function AddJsonInput: TNodePin;
    function GetMainOutput: TNodePin;

    procedure SaveToJSON(AObj: TJSONObject); override;
    procedure LoadFromJSON(AObj: TJSONObject); override;

    property JsonKind: TJSONNodeKind read FJsonKind write FJsonKind;
  end;

  TJsonObjectNode = class(TJsonNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 240; AHeight: integer = 120); override;
    procedure SetupPins; override;
  end;

  TJsonArrayNode = class(TJsonNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 240; AHeight: integer = 120); override;
    procedure SetupPins; override;
  end;

  TJsonStringNode = class(TJsonNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 220; AHeight: integer = 95); override;
    procedure SetupPins; override;
  end;

  TJsonNumberNode = class(TJsonNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 220; AHeight: integer = 95); override;
    procedure SetupPins; override;
  end;

  TJsonBooleanNode = class(TJsonNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 220; AHeight: integer = 95); override;
    procedure SetupPins; override;
  end;

  TJsonNullNode = class(TJsonNode)
  public
    constructor Create(ATitle: string; AX, AY: single; AWidth: integer = 200; AHeight: integer = 80); override;
    procedure SetupPins; override;
  end;

  TJsonEditorChangedEvent = procedure(Sender: TObject) of object;

  TJsonNodeEditor = class(TComponent)
  private
    FNodeEditor: TNodeEditor;
    FOnChanged: TJsonEditorChangedEvent;

    procedure RegisterJsonNodes;

    function JsonKindToNodeType(AData: TJSONValue): string;
    function CreateNodeFromJSONData(const AName: string; AData: TJSONValue; AX, AY: single; ADepth, AIndex: integer): TJsonNode;

    procedure BuildGraphFromJSONData(AParent: TJsonNode; AData: TJSONValue; ADepth: integer; var ARow: integer);

    function FindLinkedChildNode(AFromPin: TNodePin): TJsonNode;
    function BuildJSONFromNode(ANode: TJsonNode): TJSONValue;
    function GetRootJsonNode: TJsonNode;

    procedure DoChanged;
    procedure SetNodeEditor(const Value: TNodeEditor);
  public
    constructor Create(AOwner: TComponent); override;

    procedure Clear;

    procedure LoadJSONText(const AText: string);
    function SaveJSONText(AFormatted: boolean = True): string;

    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string; AFormatted: boolean = True);

    property NodeEditor: TNodeEditor read FNodeEditor write SetNodeEditor;
  published
    property OnChanged: TJsonEditorChangedEvent read FOnChanged write FOnChanged;
  end;

implementation

function JsonKindToStr(AKind: TJSONNodeKind): string;
begin
  case AKind of
    jnkObject:
      Result := 'object';
    jnkArray:
      Result := 'array';
    jnkString:
      Result := 'string';
    jnkNumber:
      Result := 'number';
    jnkBoolean:
      Result := 'boolean';
    jnkNull:
      Result := 'null';
  else
    Result := 'null';
  end;
end;

function StrToJsonKind(const S: string): TJSONNodeKind;
begin
  if SameText(S, 'object') then
    Result := jnkObject
  else if SameText(S, 'array') then
    Result := jnkArray
  else if SameText(S, 'string') then
    Result := jnkString
  else if SameText(S, 'number') then
    Result := jnkNumber
  else if SameText(S, 'boolean') then
    Result := jnkBoolean
  else
    Result := jnkNull;
end;

function JSONTypeToJsonKind(AData: TJSONValue): TJSONNodeKind;
begin
  if AData = nil then
    Exit(jnkNull);

  if AData is TJSONObject then
    Exit(jnkObject)
  else if AData is TJSONArray then
    Exit(jnkArray)
  else if AData is TJSONString then
    Exit(jnkString)
  else if AData is TJSONNumber then
    Exit(jnkNumber)
  else if AData is TJSONBool then
    Exit(jnkBoolean)
  else if AData is TJSONNull then
    Exit(jnkNull)
  else
    Result := jnkNull;
end;

{ TJsonNode }

constructor TJsonNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.base';
  JsonName := '';
  FJsonKind := jnkNull;
  HeaderColor := $FFD8D8D8;
  BodyColor := $FFFFFFFF;
end;

procedure TJsonNode.SetupPins;
begin
  ClearPins;
end;

function TJsonNode.AddJsonInput: TNodePin;
begin
  Result := AddInputPin('In', 'json', pkData);
  Result.DisplayName := 'In';
  Result.PinType.Color := $FFFFAA44;
end;

function TJsonNode.GetMainOutput: TNodePin;
begin
  if OutputCount > 0 then
    Result := GetOutput(0)
  else
    Result := AddOutputPin('Value', 'json', pkData);

  Result.PinType.Color := $FFFFAA44;
end;

function TJsonNode.AddJsonChildOutput(const AName: string): TNodePin;
begin
  Result := AddOutputPin(AName, 'json', pkData);
  Result.DisplayName := AName;
  Result.PinType.Color := $FFFFAA44;
end;

procedure TJsonNode.SaveToJSON(AObj: TJSONObject);
begin
  inherited SaveToJSON(AObj);
  AObj.AddPair('jsonName', JsonName);
  AObj.AddPair('jsonKind', JsonKindToStr(FJsonKind));
end;

procedure TJsonNode.LoadFromJSON(AObj: TJSONObject);
begin
  inherited LoadFromJSON(AObj);
  JsonName := AObj.GetValue('jsonName', '');
  FJsonKind := StrToJsonKind(AObj.GetValue('jsonKind', 'null'));
end;

{ TJsonObjectNode }

constructor TJsonObjectNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.object';
  FJsonKind := jnkObject;
  HeaderColor := $FFFFD28A;
end;

procedure TJsonObjectNode.SetupPins;
begin
  ClearPins;
  AddJsonInput;
  AddOutputPin('Object', 'json', pkData).PinType.Color := $FFFFAA44;
end;

{ TJsonArrayNode }

constructor TJsonArrayNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.array';
  FJsonKind := jnkArray;
  HeaderColor := $FFB8D7FF;
end;

procedure TJsonArrayNode.SetupPins;
begin
  ClearPins;
  AddJsonInput;
  AddOutputPin('Array', 'json', pkData).PinType.Color := $FFFFAA44;
end;

{ TJsonStringNode }

constructor TJsonStringNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.string';
  FJsonKind := jnkString;
  HeaderColor := $FFB8FFB8;
end;

procedure TJsonStringNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  AddJsonInput;
  AddOutputPin('String', 'json', pkData).PinType.Color := $FFFFAA44;

  V := AddValue('value', nvkString);
  V.StringValue := '';
end;

{ TJsonNumberNode }

constructor TJsonNumberNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.number';
  FJsonKind := jnkNumber;
  HeaderColor := $FFD0A0FF;
end;

procedure TJsonNumberNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  AddJsonInput;
  AddOutputPin('Number', 'json', pkData).PinType.Color := $FFFFAA44;

  V := AddValue('value', nvkFloat);
  V.FloatValue := 0;
end;

{ TJsonBooleanNode }

constructor TJsonBooleanNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.boolean';
  FJsonKind := jnkBoolean;
  HeaderColor := $FFFFFFB8;
end;

procedure TJsonBooleanNode.SetupPins;
var
  V: TNodeValue;
begin
  ClearPins;
  AddJsonInput;
  AddOutputPin('Boolean', 'json', pkData).PinType.Color := $FFFFAA44;

  V := AddValue('value', nvkBoolean);
  V.BooleanValue := False;
end;

{ TJsonNullNode }

constructor TJsonNullNode.Create(ATitle: string; AX, AY: single; AWidth: integer; AHeight: integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'json.null';
  FJsonKind := jnkNull;
  HeaderColor := $FFCCCCCC;
end;

procedure TJsonNullNode.SetupPins;
begin
  ClearPins;
  AddJsonInput;
  AddOutputPin('Null', 'json', pkData).PinType.Color := $FFFFAA44;
end;

{ TJsonNodeEditor }

constructor TJsonNodeEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TJsonNodeEditor.RegisterJsonNodes;
begin
  FNodeEditor.Graph.Registry.RegisterNodeEx(
    'json.object',
    'JSON Object',
    'JSON',
    'JSON object node.',
    'json,object,dictionary,map',
    TJsonObjectNode,
    $FFFFD28A
  );

  FNodeEditor.Graph.Registry.RegisterNodeEx(
    'json.array',
    'JSON Array',
    'JSON',
    'JSON array node.',
    'json,array,list',
    TJsonArrayNode,
    $FFB8D7FF
  );

  FNodeEditor.Graph.Registry.RegisterNodeEx(
    'json.string',
    'JSON String',
    'JSON',
    'JSON string value.',
    'json,string,text',
    TJsonStringNode,
    $FFB8FFB8
  );

  FNodeEditor.Graph.Registry.RegisterNodeEx(
    'json.number',
    'JSON Number',
    'JSON',
    'JSON number value.',
    'json,number,float,int',
    TJsonNumberNode,
    $FFD0A0FF
  );

  FNodeEditor.Graph.Registry.RegisterNodeEx(
    'json.boolean',
    'JSON Boolean',
    'JSON',
    'JSON boolean value.',
    'json,bool,boolean,true,false',
    TJsonBooleanNode,
    $FFFFFFB8
  );

  FNodeEditor.Graph.Registry.RegisterNodeEx(
    'json.null',
    'JSON Null',
    'JSON',
    'JSON null value.',
    'json,null',
    TJsonNullNode,
    $FFCCCCCC
  );
end;

procedure TJsonNodeEditor.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TJsonNodeEditor.Clear;
begin
  FNodeEditor.Clear;
end;

function TJsonNodeEditor.JsonKindToNodeType(AData: TJSONValue): string;
begin
  case JSONTypeToJsonKind(AData) of
    jnkObject:
      Result := 'json.object';
    jnkArray:
      Result := 'json.array';
    jnkString:
      Result := 'json.string';
    jnkNumber:
      Result := 'json.number';
    jnkBoolean:
      Result := 'json.boolean';
    jnkNull:
      Result := 'json.null';
  else
    Result := 'json.null';
  end;
end;

function TJsonNodeEditor.CreateNodeFromJSONData(const AName: string; AData: TJSONValue; AX, AY: single; ADepth, AIndex: integer): TJsonNode;
var
  NodeType: string;
  V: TNodeValue;
  TitleText: string;
begin
  NodeType := JsonKindToNodeType(AData);

  if AName <> '' then
    TitleText := AName
  else if ADepth = 0 then
    TitleText := 'root'
  else
    TitleText := '[' + IntToStr(AIndex) + ']';

  Result := TJsonNode(FNodeEditor.Graph.Registry.CreateNode(NodeType, AX, AY));
  Result.JsonName := AName;

  case Result.JsonKind of
    jnkObject:
      Result.Title := TitleText + ' { }';
    jnkArray:
      Result.Title := TitleText + ' [ ]';
    jnkString:
      begin
        Result.Title := TitleText + ' : string';
        V := Result.FindValue('value');
        if V <> nil then
          V.StringValue := TJSONString(AData).Value;
      end;
    jnkNumber:
      begin
        Result.Title := TitleText + ' : number';
        V := Result.FindValue('value');
        if V <> nil then
        try
          V.FloatValue := TJSONNumber(AData).AsDouble;
        except
          V.FloatValue := 0;
        end;
      end;
    jnkBoolean:
      begin
        Result.Title := TitleText + ' : boolean';
        V := Result.FindValue('value');
        if V <> nil then
          V.BooleanValue := TJSONBool(AData).AsBoolean;
      end;
    jnkNull:
      Result.Title := TitleText + ' : null';
  end;

  FNodeEditor.AddNode(Result);
end;

procedure TJsonNodeEditor.BuildGraphFromJSONData(AParent: TJsonNode; AData: TJSONValue; ADepth: integer; var ARow: integer);
var
  Obj: TJSONObject;
  Arr: TJSONArray;
  I: integer;
  ChildData: TJSONValue;
  ChildNode: TJsonNode;
  ParentOut: TNodePin;
  ChildIn: TNodePin;
  FieldName: string;
  X, Y: single;
begin
  if (AParent = nil) or (AData = nil) then
    Exit;

  if AData is TJSONObject then
  begin
    Obj := TJSONObject(AData);

    for I := 0 to Obj.Count - 1 do
    begin
      FieldName := Obj.Pairs[I].JsonString.Value;
      ChildData := Obj.Pairs[I].JsonValue;

      X := 80 + ADepth * 280;
      Y := 60 + ARow * 140;
      Inc(ARow);

      ChildNode := CreateNodeFromJSONData(FieldName, ChildData, X, Y, ADepth + 1, I);

      ParentOut := AParent.AddJsonChildOutput(FieldName);
      ChildIn := ChildNode.GetInput(0);

      FNodeEditor.Graph.AddLink(TNodeLink.Create(ParentOut, ChildIn));

      BuildGraphFromJSONData(ChildNode, ChildData, ADepth + 1, ARow);
    end;
  end
  else if AData is TJSONArray then
  begin
    Arr := TJSONArray(AData);

    for I := 0 to Arr.Count - 1 do
    begin
      FieldName := IntToStr(I);
      ChildData := Arr.Items[I];

      X := 80 + ADepth * 280;
      Y := 60 + ARow * 140;
      Inc(ARow);

      ChildNode := CreateNodeFromJSONData(FieldName, ChildData, X, Y, ADepth + 1, I);

      ParentOut := AParent.AddJsonChildOutput(FieldName);
      ParentOut.DisplayName := '[' + IntToStr(I) + ']';

      ChildIn := ChildNode.GetInput(0);

      FNodeEditor.Graph.AddLink(TNodeLink.Create(ParentOut, ChildIn));

      BuildGraphFromJSONData(ChildNode, ChildData, ADepth + 1, ARow);
    end;
  end;
end;

procedure TJsonNodeEditor.LoadJSONText(const AText: string);
var
  Data: TJSONValue;
  RootNode: TJsonNode;
  Row: integer;
begin
  Clear;

  if Trim(AText) = '' then
    Exit;

  Data := TJSONValue.ParseJSONValue(AText);
  try
    Row := 0;

    RootNode := CreateNodeFromJSONData('root', Data, 40, 60, 0, 0);
    BuildGraphFromJSONData(RootNode, Data, 1, Row);

    FNodeEditor.FrameAll;
    DoChanged;
  finally
    Data.Free;
  end;
end;

function TJsonNodeEditor.FindLinkedChildNode(AFromPin: TNodePin): TJsonNode;
var
  I: integer;
  L: TNodeLink;
begin
  Result := nil;

  if AFromPin = nil then
    Exit;

  for I := 0 to FNodeEditor.Graph.Links.Count - 1 do
  begin
    L := FNodeEditor.Graph.Links[I];

    if L.FromPin = AFromPin then
    begin
      if (L.ToPin <> nil) and (L.ToPin.OwnerNode is TJsonNode) then
        Exit(TJsonNode(L.ToPin.OwnerNode));
    end;
  end;
end;

function TJsonNodeEditor.BuildJSONFromNode(ANode: TJsonNode): TJSONValue;
var
  Obj: TJSONObject;
  Arr: TJSONArray;
  I: integer;
  P: TNodePin;
  ChildNode: TJsonNode;
  V: TNodeValue;
begin
  Result := nil;

  if ANode = nil then
    Exit(TJSONNull.Create);

  case ANode.JsonKind of
    jnkObject:
      begin
        Obj := TJSONObject.Create;

        for I := 1 to ANode.OutputCount - 1 do
        begin
          P := ANode.GetOutput(I);
          ChildNode := FindLinkedChildNode(P);

          if ChildNode <> nil then
            Obj.AddPair(P.Name, BuildJSONFromNode(ChildNode))
          else
            Obj.AddPair(P.Name, TJSONNull.Create);
        end;

        Result := Obj;
      end;
    jnkArray:
      begin
        Arr := TJSONArray.Create;

        for I := 1 to ANode.OutputCount - 1 do
        begin
          P := ANode.GetOutput(I);
          ChildNode := FindLinkedChildNode(P);

          if ChildNode <> nil then
            Arr.AddElement(BuildJSONFromNode(ChildNode))
          else
            Arr.AddElement(TJSONNull.Create);
        end;

        Result := Arr;
      end;
    jnkString:
      begin
        V := ANode.FindValue('value');
        if V <> nil then
          Result := TJSONString.Create(V.StringValue)
        else
          Result := TJSONString.Create('');
      end;
    jnkNumber:
      begin
        V := ANode.FindValue('value');
        if V <> nil then
          Result := TJSONNumber.Create(V.FloatValue)
        else
          Result := TJSONNumber.Create(0);
      end;
    jnkBoolean:
      begin
        V := ANode.FindValue('value');
        if V <> nil then
          Result := TJSONBool.Create(V.BooleanValue)
        else
          Result := TJSONBool.Create(False);
      end;
    jnkNull:
      Result := TJSONNull.Create;
  end;

  if Result = nil then
    Result := TJSONNull.Create;
end;

function TJsonNodeEditor.GetRootJsonNode: TJsonNode;
var
  I: integer;
  N: TCustomNode;
begin
  Result := nil;

  for I := 0 to FNodeEditor.Graph.Nodes.Count - 1 do
  begin
    N := FNodeEditor.Graph.Nodes[I];

    if N is TJsonNode then
    begin
      if SameText(TJsonNode(N).JsonName, 'root') then
        Exit(TJsonNode(N));
    end;
  end;

  for I := 0 to FNodeEditor.Graph.Nodes.Count - 1 do
  begin
    N := FNodeEditor.Graph.Nodes[I];

    if N is TJsonNode then
      Exit(TJsonNode(N));
  end;
end;

function TJsonNodeEditor.SaveJSONText(AFormatted: boolean): string;
var
  RootNode: TJsonNode;
  Data: TJSONValue;
begin
  Result := '';

  RootNode := GetRootJsonNode;
  if RootNode = nil then
    Exit;

  Data := BuildJSONFromNode(RootNode);
  try
    if AFormatted then
      Result := Data.Format
    else
      Result := Data.ToJSON;
  finally
    Data.Free;
  end;
end;

procedure TJsonNodeEditor.LoadFromFile(const AFileName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(AFileName);
    LoadJSONText(SL.Text);
  finally
    SL.Free;
  end;
end;

procedure TJsonNodeEditor.SaveToFile(const AFileName: string; AFormatted: boolean);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Text := SaveJSONText(AFormatted);
    SL.SaveToFile(AFileName);
  finally
    SL.Free;
  end;
end;

procedure TJsonNodeEditor.SetNodeEditor(const Value: TNodeEditor);
begin
  FNodeEditor := Value;
  RegisterJsonNodes;
end;

end.

