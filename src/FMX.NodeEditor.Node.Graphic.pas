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
unit FMX.NodeEditor.Node.Graphic;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, System.UITypes,
  System.Generics.Collections, FMX.NodeEditor.Node, FMX.Graphics, System.Types,
  FMX.NodeEditor.Graph, FMX.NodeEditor.Executor.Runtime, FMX.NodeEditor.Types,
  System.UIConsts, FMX.Effects, FMX.Filter, FMX.Filter.Custom;

type
  TBitmapValueNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure AutoLayoutPins; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double); override;
  end;

  TBitmapPrintNode = class(TExecutableNode)
  private
    FValuePin: TNodePin;
    FExecIn: TNodePin;
  protected
    FExecutedValue: IBitmapNodeObject;
  public
    procedure AutoLayoutPins; override;
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
    procedure Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom: Double; OffsetX, OffsetY: Double); override;
  end;

  TBitmapSaveToFileNode = class(TExecutableNode)
  private
    FValuePin: TNodePin;
    FFileName: TNodePin;
    FExecIn: TNodePin;
  public
    procedure SetupPins; override;
    constructor Create; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TBitmapRotateNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
    FValueIn: TNodePin;
    FRotateValue: TNodePin;
    FExecIn: TNodePin;
    FExecOut: TNodePin;
    FResult: IBitmapNodeObject;
  public
    procedure SetupPins; override;
    constructor Create; override;
    destructor Destroy; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TBitmapBlurNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
    FValueIn: TNodePin;
    FSoftnessValue: TNodePin;
    FExecIn: TNodePin;
    FExecOut: TNodePin;
    FResult: IBitmapNodeObject;
  public
    procedure SetupPins; override;
    constructor Create; override;
    destructor Destroy; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

  TBitmapFilterNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
    FValueIn: TNodePin;
    FExecIn: TNodePin;
    FExecOut: TNodePin;
    FResult: IBitmapNodeObject;
    FFilter: TFilter;
  protected
    procedure CreateFilter;
  public
    procedure SetupPins; override;
    constructor Create; override;
    destructor Destroy; override;
    procedure Execute(AContext: TNodeExecutionContext); override;
  end;

procedure RegisterGraphicNodes(Registry: TNodeRegistry);

implementation

uses
  System.Math, System.IOUtils;

procedure FilterGraphicNodes(Registry: TNodeRegistry);
begin
  var Filters := TStringList.Create;
  try
    var CategoryList := TStringList.Create;
    try
      TFilterManager.FillCategory(CategoryList);
      for var Category in CategoryList do
      begin
        var CatFilters := TStringList.Create;
        try
          TFilterManager.FillFiltersInCategory(Category, CatFilters);
          Filters.AddStrings(CatFilters);
        finally
          CatFilters.Free;
        end;
      end;
    finally
      CategoryList.Free;
    end;

    for var FilterName in Filters do
    begin
      Registry.RegisterNodeEx('bitmapfilter_' + FilterName, FilterName, 'Bitmap Filters',
        'Bitmap filter: ' + FilterName,
        'value,bitmap,' + FilterName, '',
        TBitmapFilterNode, TAlphaColors.Null);
    end;
  finally
    Filters.Free;
  end;
end;

{ TBitmapFilterNode }

constructor TBitmapFilterNode.Create;
begin
  inherited;
  FResult := nil;
  Width := 280;
  Height := 160;
  NodeType := '';
  HeaderColor := $FF955900;
end;

procedure TBitmapFilterNode.CreateFilter;
begin
  FFilter.Free;
  FFilter := nil;
  var FilterName := NodeType.Replace('bitmapfilter_', '');
  FFilter := TFilterManager.FilterByName(FilterName);
end;

destructor TBitmapFilterNode.Destroy;
begin
  FResult := nil;
  FFilter.Free;
  inherited;
end;

procedure TBitmapFilterNode.Execute(AContext: TNodeExecutionContext);
begin
  var Original := NodeValueToBitmapDef(AContext.GetInputValue(FValueIn), nil);
  FResult := nil;
  if (Original <> nil) and (not Original.GetIsEmpty) then
  begin
    var TMP := TBitmap.Create;
    try
      for var FilterAttr in FFilter.FilterAttr.Values do
      begin
        var Pin := FindPinByName(FilterAttr.Name);
        if not Assigned(Pin) then
          Continue;
        case FilterAttr.ValueType of
          TFilterValueType.Float:
            FFilter.ValuesAsFloat[FilterAttr.Name] := NodeValueToFloatDef(AContext.GetInputValueOrVar(Pin, FilterAttr.Name), FilterAttr.Default.AsExtended);
          TFilterValueType.Point:
            begin
              var Pt: TPointF := FilterAttr.Default.AsType<TPointF>;
              Pt.X := NodeValueToFloatDef(AContext.GetInputValueOrVar(Pin, FilterAttr.Name + '.X'), Pt.X);
              Pt.Y := NodeValueToFloatDef(AContext.GetInputValueOrVar(Pin, FilterAttr.Name + '.Y'), Pt.Y);
              FFilter.ValuesAsPoint[FilterAttr.Name] := Pt;
            end;
          TFilterValueType.Color:
            begin
              var Color: TAlphaColor := FilterAttr.Default.AsType<TAlphaColor>;
              Color := StringToAlphaColor(NodeValueToStringDef(AContext.GetInputValueOrVar(Pin, FilterAttr.Name), AlphaColorToString(Color)));
              FFilter.ValuesAsColor[FilterAttr.Name] := Color;
            end;
          TFilterValueType.Bitmap:
            begin
              var Bitmap := NodeValueToBitmapDef(AContext.GetInputValueOrVar(Pin, FilterAttr.Name), nil);
              if Assigned(Bitmap) and not Bitmap.GetIsEmpty then
                FFilter.ValuesAsBitmap[FilterAttr.Name] := Bitmap.GetBitmap
              else
                FFilter.ValuesAsBitmap[FilterAttr.Name] := nil;
            end;
        end;
      end;

      // Original
      FFilter.ValuesAsBitmap['Input'] := Original.GetBitmap;
      // Apply
      TMP.Assign(FFilter.ValuesAsBitmap['output']);
    except
      TMP.Free;
      raise;
    end;
    FResult := TBitmapObject.Create;
    FResult.SetBitmap(TMP);
    AContext.SetOutputValue(FValueOut, MakeBitmapValue(FResult));
  end;
  AContext.SelectExecOutput(FExecOut);
end;

procedure TBitmapFilterNode.SetupPins;
begin
  inherited;
  CreateFilter;
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueIn := AddInputPin('Original', 'bitmap', TPinKind.Data);
  FValueOut := AddOutputPin('Result', 'bitmap', TPinKind.Data);

  for var FilterAttr in FFilter.FilterAttr.Values do
  begin
    case FilterAttr.ValueType of
      TFilterValueType.Float:
        begin
          AddInputPin(FilterAttr.Name, 'float');
          if FindValue(FilterAttr.Name) = nil then
          begin
            var V := AddValue(FilterAttr.Name, TNodeValueKind.Float);
            V.FloatValue := FilterAttr.Default.AsExtended;
          end;
        end;
      TFilterValueType.Point:
        begin
          AddInputPin(FilterAttr.Name + '.X', 'float');
          if FindValue(FilterAttr.Name + '.X') = nil then
          begin
            var V := AddValue(FilterAttr.Name + '.V', TNodeValueKind.Float);
            var X := FilterAttr.Default.AsType<TPointF>.X;
            V.FloatValue := X;
          end;
          AddInputPin(FilterAttr.Name + '.Y', 'float');

          if FindValue(FilterAttr.Name + '.Y') = nil then
          begin
            var V := AddValue(FilterAttr.Name + '.Y', TNodeValueKind.Float);
            var Y := FilterAttr.Default.AsType<TPointF>.Y;
            V.FloatValue := Y;
          end;
        end;
      TFilterValueType.Color:
        begin
          AddInputPin(FilterAttr.Name, 'string');
          if FindValue(FilterAttr.Name) = nil then
          begin
            var V := AddValue(FilterAttr.Name, TNodeValueKind.string);
            V.StringValue := AlphaColorToString(FilterAttr.Default.AsType<TAlphaColor>);
          end;
        end;
      TFilterValueType.Bitmap:
        begin
          AddInputPin(FilterAttr.Name, 'bitmap');
          if FindValue(FilterAttr.Name) = nil then
          begin
            var V := AddValue(FilterAttr.Name, TNodeValueKind.Bitmap);
            V.Bitmap := nil;
          end;
        end;
    end;
  end;
  SetHeight(Height);
end;

procedure RegisterGraphicNodes(Registry: TNodeRegistry);
begin
  if Registry = nil then
    Exit;

  Registry.RegisterNodeEx('bitmapvalue', 'Bitmap value', 'Variable',
    'Bitmap value',
    'value,bitmap', '',
    TBitmapValueNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('bitmapprint', 'Bitmap print', 'Common',
    'Bitmap value',
    'value,bitmap', '',
    TBitmapPrintNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('bitmapsavefile', 'Bitmap save file', 'Common',
    'Bitmap save to file',
    'save,bitmap,file', '',
    TBitmapSaveToFileNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('bitmaprotate', 'Bitmap rotate', 'Common',
    'Bitmap rotate',
    'value,bitmap,rotate', '',
    TBitmapRotateNode, TAlphaColors.Null);

  Registry.RegisterNodeEx('bitmapblur', 'Bitmap blur', 'Common',
    'Bitmap blur',
    'value,bitmap,blur', '',
    TBitmapBlurNode, TAlphaColors.Null);

  FilterGraphicNodes(Registry);
end;

{ TBitmapValueNode }

procedure TBitmapValueNode.AutoLayoutPins;
begin
  var MaxCount := Max(FInputs.Count, FOutputs.Count);
  if MaxCount <= 0 then
    Exit;

  var Cnt := 0;
  var Top := HeaderHeight;
  var TopData := Top;
  var ItemH := 26;

  for var i := 0 to FInputs.Count - 1 do
  begin
    FInputs[i].LocalY := Top + Cnt * ItemH + 16;
    TopData := Max(TopData, FInputs[i].LocalY);
    Inc(Cnt);
  end;

  Cnt := 0;
  for var i := 0 to FOutputs.Count - 1 do
  begin
    FOutputs[i].LocalY := Top + Cnt * ItemH + 16;
    TopData := Max(TopData, FOutputs[i].LocalY);
    Inc(Cnt);
  end;
end;

constructor TBitmapValueNode.Create;
begin
  inherited;
  Width := 200;
  Height := 250;
  HeaderColor := $FF843482;
  NodeType := 'bitmapvalue';
  IconPath := 'M5 21q-.825 0-1.412-.587T3 19V5q0-.825.588-1.412T5 3h14q.825 0 1.413.588T21 5v14q0 .825-.587 1.413T19 21zm0-2h14V5H5zm1-2h12l-3.75-5l-3 4L9 13zm-1 2V5zm4.563-9.437Q10 9.125 10 8.5t-.437-1.062T8.5 7t-1.062.438T7 8.5t.438 1.063T8.5 10t1.063-.437';
end;

procedure TBitmapValueNode.Execute(AContext: TNodeExecutionContext);
begin
  var V := FindValue('value');
  if V <> nil then
    AContext.SetOutputValue(FValueOut, MakeBitmapValue(V.Bitmap))
  else
    AContext.SetOutputValue(FValueOut, MakeBitmapValue(nil));
end;

procedure TBitmapValueNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double);
begin
  inherited;
  var ScaledHeaderHeight := HeaderHeight * Zoom;
  var NodeHead := RectF(NodeBounds.Left, NodeBounds.Top, NodeBounds.Right, NodeBounds.Top + ScaledHeaderHeight);
  var NodeBody := RectF(NodeBounds.Left, NodeBounds.Top + ScaledHeaderHeight, NodeBounds.Right, NodeBounds.Bottom);

  var V := FindValue('value');
  if (V <> nil) and (V.Bitmap <> nil) and (not V.Bitmap.GetIsEmpty) then
  begin
    NodeBody.Inflate(-20 * Zoom, -20 * Zoom);
    NodeBody.Top := NodeBody.Top + Max(FInputs.Count, FOutputs.Count) * 30 * Zoom;
    if NodeBody.Bottom <= NodeBody.Top then
      Exit;
    var R := V.Bitmap.GetBitmap.BoundsF;
    R := R.FitInto(NodeBody);
    Canvas.DrawBitmap(V.Bitmap.GetBitmap, V.Bitmap.GetBitmap.BoundsF, R, 1);
  end;
end;

procedure TBitmapValueNode.SetupPins;
begin
  ClearPins;
  FValueOut := AddOutputPin('Value', 'bitmap', TPinKind.Data);

  if FindValue('value') = nil then
  begin
    var V := AddValue('value', TNodeValueKind.Bitmap);
    V.Bitmap := nil;
  end;
end;

{ TBitmapPrintNode }

procedure TBitmapPrintNode.AutoLayoutPins;
begin
  var MaxCount := Max(FInputs.Count, FOutputs.Count);
  if MaxCount <= 0 then
    Exit;

  var Cnt := 0;
  var Top := HeaderHeight;
  var TopData := Top;
  var ItemH := 26;

  for var i := 0 to FInputs.Count - 1 do
  begin
    FInputs[i].LocalY := Top + Cnt * ItemH + 16;
    TopData := Max(TopData, FInputs[i].LocalY);
    Inc(Cnt);
  end;

  Cnt := 0;
  for var i := 0 to FOutputs.Count - 1 do
  begin
    FOutputs[i].LocalY := Top + Cnt * ItemH + 16;
    TopData := Max(TopData, FOutputs[i].LocalY);
    Inc(Cnt);
  end;
end;

constructor TBitmapPrintNode.Create;
begin
  inherited;
  Width := 200;
  Height := 275;
  HeaderColor := $FF843482;
  NodeType := 'bitmapprint';
  IconPath := 'M5 21q-.825 0-1.412-.587T3 19V5q0-.825.588-1.412T5 3h14q.825 0 1.413.588T21 5v14q0 .825-.587 1.413T19 21zm0-2h14V5H5zm1-2h12l-3.75-5l-3 4L9 13zm-1 2V5zm4.563-9.437Q10 9.125 10 8.5t-.437-1.062T8.5 7t-1.062.438T7 8.5t.438 1.063T8.5 10t1.063-.437';
end;

procedure TBitmapPrintNode.Execute(AContext: TNodeExecutionContext);
begin
  inherited;
  var Value := NodeValueToBitmapDef(AContext.GetInputValue(FValuePin), nil);
  FExecutedValue := Value;
end;

procedure TBitmapPrintNode.Paint(Canvas: TCanvas; const NodeBounds: TRectF; Zoom, OffsetX, OffsetY: Double);
begin
  inherited;
  var ScaledHeaderHeight := HeaderHeight * Zoom;
  var NodeHead := RectF(NodeBounds.Left, NodeBounds.Top, NodeBounds.Right, NodeBounds.Top + ScaledHeaderHeight);
  var NodeBody := RectF(NodeBounds.Left, NodeBounds.Top + ScaledHeaderHeight, NodeBounds.Right, NodeBounds.Bottom);

  if (FExecutedValue <> nil) and (not FExecutedValue.GetIsEmpty) then
  begin
    NodeBody.Inflate(-20 * Zoom, -20 * Zoom);
    NodeBody.Top := NodeBody.Top + Max(FInputs.Count, FOutputs.Count) * 30 * Zoom;
    if NodeBody.Bottom <= NodeBody.Top then
      Exit;
    var R := FExecutedValue.GetBitmap.BoundsF;
    R := R.FitInto(NodeBody);
    Canvas.DrawBitmap(FExecutedValue.GetBitmap, FExecutedValue.GetBitmap.BoundsF, R, 1);
  end;
end;

procedure TBitmapPrintNode.SetupPins;
begin
  inherited;
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FValuePin := AddInputPin('Value', 'bitmap', TPinKind.Data);
end;

{ TBitmapSaveToFileNode }

constructor TBitmapSaveToFileNode.Create;
begin
  inherited;
  Width := 200;
  Height := 120;
  HeaderColor := $FF843482;
  NodeType := 'bitmapsavefile';
  IconPath := 'M3 5.75A2.75 2.75 0 0 1 5.75 3h9.965a3.25 3.25 0 0 1 2.298.952l2.035 2.035c.61.61.952 1.437.952 2.299v9.964A2.75 2.75 0 0 1 18.25 21H5.75A2.75 2.75 0 0 1 3 18.25zM5.75 4.5c-.69 0-1.25.56-1.25 1.25v12.5c0 .69.56 1.25 1.25 1.25H6v-5.25A2.25 2.25 0 0 1 8.25 12h7.5A2.25 2.25 0 0 1 18 14.25v5.25h.25c.69 0 1.25-.56 1.25-1.25V8.286c0-.465-.184-.91-.513-1.238l-2.035-2.035a1.75 1.75 0 0 0-.952-.49V7.25a2.25 2.25 0 0 1-2.25 2.25h-4.5A2.25 2.25 0 0 1 7 7.25V4.5zm10.75 15v-5.25a.75.75 0 0 0-.75-.75h-7.5a.75.75 0 0 0-.75.75v5.25zm-8-15v2.75c0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75V4.5z';
end;

procedure TBitmapSaveToFileNode.Execute(AContext: TNodeExecutionContext);
begin
  inherited;
  var FileName := NodeValueToStringDef(AContext.GetInputValueOrVar(FFileName, 'filename'), '');
  if (FileName.IsEmpty) then
    Exit;
  var Value := NodeValueToBitmapDef(AContext.GetInputValue(FValuePin), nil);
  if (Value = nil) or Value.GetIsEmpty then
    Exit;
  Value.GetBitmap.SaveToFile(FileName);
end;

procedure TBitmapSaveToFileNode.SetupPins;
begin
  inherited;
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FValuePin := AddInputPin('Value', 'bitmap', TPinKind.Data);
  FFileName := AddInputPin('FileName', 'string', TPinKind.Data);

  if FindValue('filename') = nil then
  begin
    var V := AddValue('filename', TNodeValueKind.string);
    V.StringValue := '';
  end;
end;

{ TBitmapRotateNode }

constructor TBitmapRotateNode.Create;
begin
  inherited;
  FResult := nil;
  Width := 220;
  Height := 130;
  NodeType := 'bitmaprotate';
  HeaderColor := $FF955900;
  IconPath := 'M7.727 25.106c.539-.258.773-.657.75-1.313c-.07-.844-1.032-2.016-1.032-5.133c0-5.015 3.235-8.554 8.297-8.554h.07v3.234c0 1.851 1.454 2.273 2.86 1.219l6.398-4.664c1.078-.774 1.078-1.688 0-2.485l-6.398-4.687c-1.43-1.079-2.86-.656-2.86 1.242V7.41h-.093c-6.727 0-11.203 4.524-11.203 11.227c0 2.508.515 4.57 1.242 5.812c.398.68 1.242 1.008 1.968.657m37.734 29.25c4.008 0 6.023-1.922 6.023-6.024v-23.18c0-4.101-2.015-6.023-6.023-6.023H22.234c-4.008 0-6.023 1.922-6.023 6.023v23.18c0 4.102 2.016 6.024 6.023 6.024Z';
end;

destructor TBitmapRotateNode.Destroy;
begin
  FResult := nil;
  inherited;
end;

procedure TBitmapRotateNode.Execute(AContext: TNodeExecutionContext);
begin
  var Original := NodeValueToBitmapDef(AContext.GetInputValue(FValueIn), nil);
  FResult := nil;
  if (Original <> nil) and (not Original.GetIsEmpty) then
  begin
    var TMP := TBitmap.Create;
    try
      TMP.Assign(Original.GetBitmap);
      TMP.Rotate(NodeValueToFloatDef(AContext.GetInputValueOrVar(FRotateValue, 'angle'), 90));
      FResult := TBitmapObject.Create;
      FResult.SetBitmap(TMP);
      AContext.SetOutputValue(FValueOut, MakeBitmapValue(FResult));
    except
      TMP.Free;
      raise;
    end;
  end;
  AContext.SelectExecOutput(FExecOut);
end;

procedure TBitmapRotateNode.SetupPins;
begin
  inherited;
  ClearPins;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueIn := AddInputPin('Original', 'bitmap', TPinKind.Data);
  FValueOut := AddOutputPin('Rotated', 'bitmap', TPinKind.Data);
  FRotateValue := AddInputPin('Angle', 'float', TPinKind.Data);

  if FindValue('angle') = nil then
  begin
    var V := AddValue('angle', TNodeValueKind.Float);
    V.FloatValue := 90;
  end;
end;

{ TBitmapBlurNode }

constructor TBitmapBlurNode.Create;
begin
  inherited;
  FResult := nil;
  Width := 220;
  Height := 130;
  NodeType := 'bitmapblur';
  HeaderColor := $FF955900;
  IconPath := 'M2.65 14.35Q2.5 14.2 2.5 14t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-4Q2.5 10.2 2.5 10t.15-.35T3 9.5t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m2.638 8.363Q5 18.425 5 18t.288-.712T6 17t.713.288T7 ' +
    '18t-.288.713T6 19t-.712-.288m0-4Q5 14.425 5 14t.288-.712T6 13t.713.288T7 14t-.288.713T6 15t-.712-.288m0-4Q5 10.426 5 10t.288-.712T6 9t.713.288T7 10t-.288.713T6 11t-.712-.288m0-4Q5 6.426 5 6t.288-.712T6 ' +
    '5t.713.288T7 6t-.288.713T6 7t-.712-.288m3.65 8.35Q8.5 14.626 8.5 14t.438-1.062T10 12.5t1.063.438T11.5 14t-.437 1.063T10 15.5t-1.062-.437m0-4Q8.5 10.625 8.5 10t.438-1.062T10 8.5t1.063.438T11.5 10t-.437 ' +
    '1.063T10 11.5t-1.062-.437m.35 7.65Q9 18.425 9 18t.288-.712T10 17t.713.288T11 18t-.288.713T10 19t-.712-.288m0-12Q9 6.425 9 6t.288-.712T10 5t.713.288T11 6t-.288.713T10 7t-.712-.288M9.65 21.35Q9.5 21.2 9.5 ' +
    '21t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-18Q9.5 3.2 9.5 3t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m3.288 11.713Q12.5 14.625 12.5 14t.438-1.062T14 12.5t1.063.438T15.5 14t-.437 ' +
    '1.063T14 15.5t-1.062-.437m0-4Q12.5 10.625 12.5 10t.438-1.062T14 8.5t1.063.438T15.5 10t-.437 1.063T14 11.5t-1.062-.437m.35 7.65Q13 18.425 13 18t.288-.712T14 17t.713.288T15 18t-.288.713T14 19t-.712-.288m0-12Q13 ' +
    '6.425 13 6t.288-.712T14 5t.713.288T15 6t-.288.713T14 7t-.712-.288m.362 14.638q-.15-.15-.15-.35t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-18Q13.5 3.2 13.5 3t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m3.638 ' +
    '15.363Q17 18.425 17 18t.288-.712T18 17t.713.288T19 18t-.288.713T18 19t-.712-.288m0-4Q17 14.425 17 14t.288-.712T18 13t.713.288T19 14t-.288.713T18 15t-.712-.288m0-4Q17 10.426 17 10t.288-.712T18 9t.713.288T19 ' +
    '10t-.288.713T18 11t-.712-.288m0-4Q17 6.426 17 6t.288-.712T18 5t.713.288T19 6t-.288.713T18 7t-.712-.288m3.362 7.638q-.15-.15-.15-.35t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-4q-.15-.15-.15-.35t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15';
end;

destructor TBitmapBlurNode.Destroy;
begin
  FResult := nil;
  inherited;
end;

procedure TBitmapBlurNode.Execute(AContext: TNodeExecutionContext);
begin
  var Original := NodeValueToBitmapDef(AContext.GetInputValue(FValueIn), nil);
  FResult := nil;
  if (Original <> nil) and (not Original.GetIsEmpty) then
  begin
    var TMP := TBitmap.Create;
    try
      var Softness := NodeValueToFloatDef(AContext.GetInputValueOrVar(FSoftnessValue, 'softness'), 0.5);
      TMP.Assign(Original.GetBitmap);
      var Blur := TBlurEffect.Create(nil);
      try
        Blur.Softness := Softness;
        Blur.ProcessEffect(nil, TMP, 1);
      finally
        Blur.Free;
      end;
      FResult := TBitmapObject.Create;
      FResult.SetBitmap(TMP);
      AContext.SetOutputValue(FValueOut, MakeBitmapValue(FResult));
    except
      TMP.Free;
      raise;
    end;
  end;
  AContext.SelectExecOutput(FExecOut);
end;

procedure TBitmapBlurNode.SetupPins;
begin
  inherited;
  FExecIn := AddInputPin('Exec', 'exec', TPinKind.Exec);
  FExecOut := AddOutputPin('Next', 'exec', TPinKind.Exec);
  FValueIn := AddInputPin('Original', 'bitmap', TPinKind.Data);
  FValueOut := AddOutputPin('Blurred', 'bitmap', TPinKind.Data);
  FSoftnessValue := AddInputPin('Softness', 'float', TPinKind.Data);

  if FindValue('softness') = nil then
  begin
    var V := AddValue('softness', TNodeValueKind.Float);
    V.FloatValue := 0.5;
  end;
end;

end.

