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

  TBitmapFilterNode = class(TExecutableNode)
  private
    FValueOut: TNodePin;
    FValueIn: TNodePin;
    FExecIn: TNodePin;
    FExecOut: TNodePin;
    FResult: IBitmapNodeObject;
    FFilter: TFilter;
  protected
    procedure CreateFilter; virtual;
    procedure SetNodeType(const Value: string); override;
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
  var CategoryList := TStringList.Create;
  try
    TFilterManager.FillCategory(CategoryList);
    for var Category in CategoryList do
    begin
      var CatFilters := TStringList.Create;
      try
        TFilterManager.FillFiltersInCategory(Category, CatFilters);
        var CategoryName: string;
        for var FilterName in CatFilters do
        begin
          CategoryName := 'Bitmap ' + Category;
          Registry.RegisterNodeEx('bitmapfilter_' + FilterName, FilterName, CategoryName,
            'Bitmap filter: ' + FilterName,
            'value,bitmap,' + FilterName, '',
            TBitmapFilterNode, TAlphaColors.Null);
        end;
      finally
        CatFilters.Free;
      end;
    end;
  finally
    CategoryList.Free;
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
  HeaderColor := $FF3E6492;
  IconPath := 'M12 2.75a5.25 5.25 0 1 0 0 10.5a5.25 5.25 0 0 0 0-10.5M5.25 8a6.75 6.75 0 1 1 13.274 1.738A6.752 6.752 0 1 1 12 21.438a6.75 6.75 0 1 1-6.524-11.7A6.8 6.8 0 0 1 5.25 8m.77 3.136A5.252 5.252 0 0 0 8 21.25a5.25 5.25 0 0 0 5.079-6.586a6.75 6.75 0 0 1-7.058-3.529m8.504 3.126c.148.555.226 1.138.226 1.738a6.72 6.72 0 0 1-1.625 4.393a5.25 5.25 0 1 0 4.855-9.258a6.78 6.78 0 0 1-3.456 3.127';
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

procedure TBitmapFilterNode.SetNodeType(const Value: string);
begin
  inherited;
  var FilterName := NodeType.Replace('bitmapfilter_', '');
  if FilterName.EndsWith('Blur') then
    IconPath := 'M2.65 14.35Q2.5 14.2 2.5 14t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-4Q2.5 10.2 2.5 10t.15-.35T3 9.5t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m2.638 8.363Q5 18.425 5 18t.288-.712T6 17t.713.288T7 ' +
      '18t-.288.713T6 19t-.712-.288m0-4Q5 14.425 5 14t.288-.712T6 13t.713.288T7 14t-.288.713T6 15t-.712-.288m0-4Q5 10.426 5 10t.288-.712T6 9t.713.288T7 10t-.288.713T6 11t-.712-.288m0-4Q5 6.426 5 6t.288-.712T6 ' +
      '5t.713.288T7 6t-.288.713T6 7t-.712-.288m3.65 8.35Q8.5 14.626 8.5 14t.438-1.062T10 12.5t1.063.438T11.5 14t-.437 1.063T10 15.5t-1.062-.437m0-4Q8.5 10.625 8.5 10t.438-1.062T10 8.5t1.063.438T11.5 10t-.437 ' +
      '1.063T10 11.5t-1.062-.437m.35 7.65Q9 18.425 9 18t.288-.712T10 17t.713.288T11 18t-.288.713T10 19t-.712-.288m0-12Q9 6.425 9 6t.288-.712T10 5t.713.288T11 6t-.288.713T10 7t-.712-.288M9.65 21.35Q9.5 21.2 9.5 ' +
      '21t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-18Q9.5 3.2 9.5 3t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m3.288 11.713Q12.5 14.625 12.5 14t.438-1.062T14 12.5t1.063.438T15.5 14t-.437 ' +
      '1.063T14 15.5t-1.062-.437m0-4Q12.5 10.625 12.5 10t.438-1.062T14 8.5t1.063.438T15.5 10t-.437 1.063T14 11.5t-1.062-.437m.35 7.65Q13 18.425 13 18t.288-.712T14 17t.713.288T15 18t-.288.713T14 19t-.712-.288m0-12Q13 ' +
      '6.425 13 6t.288-.712T14 5t.713.288T15 6t-.288.713T14 7t-.712-.288m.362 14.638q-.15-.15-.15-.35t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-18Q13.5 3.2 13.5 3t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m3.638 ' +
      '15.363Q17 18.425 17 18t.288-.712T18 17t.713.288T19 18t-.288.713T18 19t-.712-.288m0-4Q17 14.425 17 14t.288-.712T18 13t.713.288T19 14t-.288.713T18 15t-.712-.288m0-4Q17 10.426 17 10t.288-.712T18 9t.713.288T19 ' +
      '10t-.288.713T18 11t-.712-.288m0-4Q17 6.426 17 6t.288-.712T18 5t.713.288T19 6t-.288.713T18 7t-.712-.288m3.362 7.638q-.15-.15-.15-.35t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15m0-4q-.15-.15-.15-.35t.15-.35t.35-.15t.35.15t.15.35t-.15.35t-.35.15t-.35-.15'
  else if FilterName.EndsWith('Transition') then
    IconPath := 'M4.616 19q-.691 0-1.153-.462T3 17.384V6.616q0-.691.463-1.153T4.615 5h14.77q.69 0 1.152.463T21 6.616v10.769q0 .69-.463 1.153T19.385 19zm.201-1h14.568q.23 0 .423-.192t.192-.424V6.616q0-.231-.192-.424T19.385 6h-4.23l2.249 8.692z'
  else if FilterName.Equals('Bands') then
    IconPath := 'M20 19V3H4v16H2v2h20v-2zM13 5h1.5v14H13zm-2 14H9.5V5H11zM6 5h1.5v14H6zm10.5 14V5H18v14z'
  else if FilterName.EndsWith('ColorKeyAlpha') then
    IconPath := 'M9 12.5L6.5 15L9 17.5l2.5-2.5zm6-10a6.5 6.5 0 0 0-6.482 6.018a6.5 6.5 0 1 0 6.964 6.964A6.5 6.5 0 0 0 15 2.5m.323 10.989a6.51 6.51 0 0 0-4.812-4.812a4.5 4.5 0 1 1 4.812 4.812M13.5 15a4.5 4.5 0 1 1-9 0a4.5 4.5 0 0 1 9 0M3 7a4 4 0 0 1 4-4h1.5v2H7a2 2 0 0 0-2 2v1.5H3zm16 10v-1.5h2V17a4 4 0 0 1-4 4h-1.5v-2H17a2 2 0 0 0 2-2'
  else if FilterName.EndsWith('GlowFilter') or FilterName.EndsWith('InnerGlowFilter') then
    IconPath := 'M1.616 14.5v-1H5v1zm5.08-5.096l-2.421-2.44l.689-.695l2.42 2.447zM7.5 17v-2h9v2zm4-10V2.616h1V7zm5.766 2.385l-.689-.708l2.44-2.402l.695.708zM19 14.5v-1h3.385v1z'
  else if FilterName.EndsWith('AffineTransform') then
    IconPath := 'M927.998 768q13 0 22.5 9.5t9.5 22.5v128q0 13-9.5 22.5t-22.5 9.5h-128q-13 0-22.5-9.5t-9.5-22.5v-32h-192v32q0 13-9.5 22.5t-22.5 9.5h-128q-13 0-22.5-9.5t-9.5-22.5v-32h-192v32q0 13-9.5 22.5t-22.5 9.5h-128q-13 ' +
      '0-22.5-9.5t-9.5-22.5V800q0-13 9.5-22.5t22.5-9.5h32V576h-32q-13 0-22.5-9.5t-9.5-22.5V416q0-13 9.5-22.5t22.5-9.5h32V192h-32q-13 0-22.5-9.5t-9.5-22.5V32q0-13 9.5-22.5t22.5-9.5h128q13 0 22.5 9.5t9.5 22.5v32h192V32q0-13 ' +
      '9.5-22.5t22.5-9.5h128q13 0 22.5 9.5t9.5 22.5v32h192V32q0-13 9.5-22.5t22.5-9.5h128q13 0 22.5 9.5t9.5 22.5v128q0 13-9.5 22.5t-22.5 9.5h-32v192h32q13 0 22.5 9.5t9.5 22.5v128q0 13-9.5 22.5t-22.5 9.5h-32v192zm-480 ' +
      '112q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5v-32q0-7-4.5-11.5t-11.5-4.5h-32q-7 0-11.5 4.5t-4.5 11.5zm-384 0q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5v-32q0-7-4.5-11.5t-11.5-4.5h-32q-7 0-11.5 ' +
      '4.5t-4.5 11.5zm0-384q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5v-32q0-7-4.5-11.5t-11.5-4.5h-32q-7 0-11.5 4.5t-4.5 11.5zm64-416q0-7-4.5-11.5t-11.5-4.5h-32q-7 0-11.5 4.5t-4.5 11.5v32q0 7 4.5 11.5t11.5 ' +
      '4.5h32q7 0 11.5-4.5t4.5-11.5zm384 0q0-7-4.5-11.5t-11.5-4.5h-32q-7 0-11.5 4.5t-4.5 11.5v32q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5zm256 80v-32h-192v32q0 13-9.5 22.5t-22.5 9.5h-128q-13 0-22.5-9.5t-9.5-22.5v-32h-192v32q0 ' +
      '13-9.5 22.5t-22.5 9.5h-32v192h32q13 0 22.5 9.5t9.5 22.5v128q0 13-9.5 22.5t-22.5 9.5h-32v192h32q13 0 22.5 9.5t9.5 22.5v32h192v-32q0-13 9.5-22.5t22.5-9.5h128q13 0 22.5 9.5t9.5 22.5v32h192v-32q0-13 9.5-22.5t22.5-9.5h32V576h-32q-13 ' +
      '0-22.5-9.5t-9.5-22.5V416q0-13 9.5-22.5t22.5-9.5h32V192h-32q-13 0-22.5-9.5t-9.5-22.5m128-80q0-7-4.5-11.5t-11.5-4.5h-32q-7 0-11.5 4.5t-4.5 11.5v32q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5zm0 384q0-7-4.5-11.5t-11.5-4.5h-32q-7 ' +
      '0-11.5 4.5t-4.5 11.5v32q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5zm-16 368h-32q-7 0-11.5 4.5t-4.5 11.5v32q0 7 4.5 11.5t11.5 4.5h32q7 0 11.5-4.5t4.5-11.5v-32q0-7-4.5-11.5t-11.5-4.5m-384-320h-32q-7 ' +
      '0-11.5-4.5t-4.5-11.5v-32q0-7 4.5-11.5t11.5-4.5h32q7 0 11.5 4.5t4.5 11.5v32q0 7-4.5 11.5t-11.5 4.5'
  else if FilterName.Equals('Contrast') then
    IconPath := 'M12 22c5.52 0 10-4.48 10-10S17.52 2 12 2S2 6.48 2 12s4.48 10 10 10m1-17.93c3.94.49 7 3.85 7 7.93s-3.05 7.44-7 7.93z'
  else if FilterName.Equals('HueAdjust') then
    IconPath := 'M20.672 9.6c-2.043 0-3.505 1.386-3.682 3.416h-.664c-.247 0-.395.144-.395.384s.148.384.395.384h.661c.152 2.09 1.652 3.423 3.915 3.423c.944 0 1.685-.144 2.332-.453c.158-.075.337-.217.292-.471a.33.33 0 0 ' +
      '0-.15-.242c-.104-.065-.25-.072-.422-.02a8 8 0 0 0-.352.12c-.414.146-.771.273-1.599.273c-1.75 0-2.908-1.023-2.952-2.605v-.025h5.444c.313 0 .492-.164.505-.463v-.058C23.994 9.865 21.452 9.6 20.672 9.6m2.376 ' +
      '3.416h-5l.004-.035c.121-1.58 1.161-2.601 2.649-2.601c1.134 0 2.347.685 2.347 2.606zM9.542 10.221c0-.335-.195-.534-.52-.534s-.52.2-.52.534v2.795h1.04zm4.29 3.817c0 1.324-.948 2.361-2.16 2.361c-1.433 0-2.13-.763-2.13-2.333v-.282h-1.04v.34c0 ' +
      '2.046.965 3.083 2.868 3.083c1.12 0 1.943-.486 2.443-1.445l.02-.036v.861c0 .334.193.534.519.534c.325 0 .52-.2.52-.534v-2.803h-1.04zm.52-4.351c-.326 0-.52.2-.52.534v2.795h1.04v-2.795c0-.335-.195-.534-.52-.534M3.645 ' +
      '9.6c-1.66 0-2.31 1.072-2.471 1.4l-.135.278V7.355c0-.347-.199-.562-.52-.562c-.32 0-.519.215-.519.562v5.661h1.039v-.015c0-1.249.72-2.592 2.304-2.592c1.29 0 2.001.828 2.001 2.332v.275h1.04v-.246c0-2.044-.973-3.17-2.739-3.17M0 ' +
      '16.558c0 .347.199.563.52.563c.32 0 .519-.216.519-.563v-2.774H0zm5.344 0c0 .347.2.563.52.563s.52-.216.52-.563v-2.774h-1.04z'
  else if FilterName.Equals('Invert') then
    IconPath := 'M896.428 1024h-768q-53 0-90.5-37.5T.428 896V128q0-53 37.5-90.5t90.5-37.5h768q53 0 90.5 37.5t37.5 90.5v768q0 53-37.5 90.5t-90.5 37.5m0-768q0-53-38-91l-120 121q-44-45-102.5-69.5t-123.5-24.5q-87 0-160.5 43t-116.5 116.5t-43 160.5q0 65 24.5 123.5t69.5 102.5l-121 121q38 37 91 37h512q53 0 90.5-37.5t37.5-90.5zm-384 576q-133 0-226-94l452-452q45 44 69.5 102.5t24.5 123.5q0 87-43 160.5T672.928 789t-160.5 43'
  else if FilterName.Equals('Tiler') then
    IconPath := 'M0 204h190V14H0zm238 0h190V14H238zm237 0h191V14H475zM0 442h190V252H0zm238 0h190V252H238zm237 0h191V252H475zM0 680h190V489H0zm238 0h190V489H238zm237 0h191V489H475z'
  else if FilterName.Equals('Swirl') or FilterName.Equals('BandedSwirl') then
    IconPath := 'M306.72 22.688c-87.212.763-181.58 53.14-238.19 140.406c-.944 1.46-1.677 3.068-2.593 4.53c.455-.397.86-.917 1.313-1.31c-40.253 56.984-35.183 136.503 15.813 187.5c54.553 54.552 141.745 56.65 199.093 6.78c-4.676 ' +
      '6.576-9.916 13.137-15.812 19.03c-57 57-149.53 57-206.53 0c-17.814-17.81-30.103-38.73-36.783-61.312c2.928 65.605 34.97 122.74 93.907 151.97c103.593 51.374 250.2-2.8 326.875-121C510.904 245.856 502.47 127.374 ' +
      '429.938 65c-10.36-8.91-22.206-16.483-35.156-22.906c-25.897-12.844-54.454-19.11-83.905-19.407c-1.38-.013-2.772-.012-4.156 0zm1.06 62.406c47.14-.705 82.63 23.414 90.376 58.906v.03c1.417 6.492 1.806 13.565 ' +
      '1.344 21.032c-3.682 59.742-68.786 126.655-145.438 149.563c-.945.282-1.872.422-2.812.688l.938-.47c-37.843 12.718-74.086-.708-84.438-33.624c-7.03-22.36-.468-48.544 15.25-70.408c-1.695 7.2-.05 13.91 5.344 ' +
      '18.375c10.643 8.816 31.83 5.575 47.312-7.25c15.483-12.824 19.394-30.37 8.75-39.187c-6.294-5.214-16.287-6.21-26.594-3.5l.532-.313c-.755.257-1.52.54-2.28.813c-.344.123-.69.217-1.033.344a54 54 0 0 0-8 3.344c-.656.307-1.315.61-1.968.937c-42.374 ' +
      '21.24-83.226 68.335-71.656 105.125c3.616 11.497 10.213 20.614 19.094 27.094c-30.253-10.44-48.35-34.526-46.563-68.53c3.682-70.837 83.193-133.31 159.844-156.22c14.673-4.385 28.802-6.553 42-6.75z'
  else if FilterName.Equals('Sepia') then
    IconPath := 'M49.064 397c-60 42-24 95 26 98c50 4 92 38 80 79c-22 70-8 128 106 70c58-29 97-101 172 30c44 77 156 26 141-62c-7-43 17-69 101-94c153-45 88-172 12-204s-87-87-60-143c26-54-48-141-113-83c-52 46-117 4-118-12s-57-133-90-34c-22 63 13 172-181 59c-123-72-183 113-49 178c63 31 33 77-27 118'
  else if FilterName.Equals('Wrap') then
    IconPath :=
      'M24 5C15.677 5 10.593 7.698 7.91 9.752c-.089.069-.205.252-.142.547c.043.206.192.434.468.59c3.487 1.982 9.102 6.2 9.102 13.111s-5.615 11.129-9.102 13.11c-.276.157-.425.385-.468.59c-.063.296.053.48.143.548C10.593 40.3 15.677 43 24 43s13.407-2.698 16.09-4.752c.089-.069.204-.252.142-.547c-.043-.206-.192-.434-.468-.59c-3.487-1.982-9.102-6.2-9.102-13.111s5.615-11.129 9.102-13.11c.276-.157.425-.385.468-.59c.062-.296-.053-.48-.143-.548C37.408 7.698 32.323 5 24 5M5.48 6.576C8.806 4.03 14.734 1 24 1s15.195 3.029 18.522 5.576c1.46 1.118 1.965 2.934 1.625 4.547c-.3 1.43-1.228 2.575-2.406 3.244c-3.318 1.886-7.078 5.077-7.078 9.633s3.76 7.747 7.078 9.633c1.177.669 2.105 1.814 2.406 3.244c.34 1.613-.166 3.43-1.625 4.547C39.195 43.97 33.267 47 24 47S8.806 43.971 5.48 41.424c-1.46-1.118-1.965-2.934-1.626-4.547c.301-1.43 1.23-2.575 2.407-3.244c3.318-1.886 7.078-5.077 7.078-9.633s-3.76-7.747-7.078-9.633c-1.178-.669-2.106-1.814-2.407-3.244c-.34-1.613.166-3.43 1.626-4.547'
  else if FilterName.Equals('Bloom') then
    IconPath := 'M20.077 19.131a33.1 33.1 0 0 1-8.772-6.337A32 32 0 0 1 4.88 3.939a.418.418 0 0 1 .491-.569a8 8 0 0 1 1.9.778A37.6 37.6 0 0 1 19.9 16.744a7.2 7.2 0 0 1 .752 1.927a.413.413 0 0 1-.575.46M21 16.146A38.6 38.6 0 0 0 7.867 3.048A7.3 7.3 0 0 0 4.521 2a2.7 2.7 0 0 0-.909.151c-1.035.447-1.6 1.672-1.6 4.362A14.73 14.73 0 0 0 5.5 15.621l-3.354 5.058a.834.834 0 0 0 .69 1.3l5.5-.02a1.67 1.67 0 0 0 1.381-.741l.838-1.257A14.1 14.1 0 0 0 17.531 22a5.47 5.47 0 0 0 4.114-1.324c.487-.456.64-2.163-.649-4.53'
  else if FilterName.Equals('Pinch') then
    IconPath := 'M29.083 14.585a3.923 3.923 0 0 0-5.568-.78l-.093.071l.023-2.025q0-.042.002-.074c0-.034.002-.058-.002-.072c.333-.03.668.01.985.115a3.65 3.65 0 0 0 4.359-2.809a3.59 3.59 0 0 0-1.906-4.324C23.1 3.1 19.667 ' +
      '3.981 17.265 7.094a4 4 0 0 0-.431-.347q-.033-.024-.062-.052l-.057-.048a4 4 0 0 0-.437-.237l-.088-.048q-.064-.04-.13-.068a4 4 0 0 0-.436-.136q-.053-.016-.105-.034q-.085-.031-.176-.051a3.82 3.82 0 0 0-3.226.824a3.72 ' +
      '3.72 0 0 0-5.331.567A3.9 3.9 0 0 0 4.922 7a3.75 3.75 0 0 0-3.813 3.675v3.65q0 .354.069.7l.072 3.926c0 7.284 4.379 11.992 11.156 11.992a12.46 12.46 0 0 0 8.745-3.646c.664-.6 1.279-1.206 1.929-1.853l.088-.086a86 ' +
      '86 0 0 1 2.193-2.128c.289-.3.7-.652 1.137-1.024l.008-.006c1.92-1.643 5.12-4.38 2.577-7.615m-25.974-3.91A1.75 1.75 0 0 1 4.922 9a1.86 1.86 0 0 1 1.1.347A5 5 0 0 0 6 9.813v4.296c0 .478.08.952.21 1.386A1.85 ' +
      '1.85 0 0 1 4.921 16a1.79 1.79 0 0 1-1.773-1.33a1.5 1.5 0 0 1-.04-.345zM8 9.812c0-.18.017-.333.04-.46q.016-.04.027-.08a1.723 1.723 0 0 1 3.097-.462q-.03.256-.029.534c0 .345-.011 1.168-.024 2.077l-.004.264a237 ' +
      '237 0 0 0-.029 2.62c0 .294.022.61.078.927a1.72 1.72 0 0 1-2.92-.092a1 1 0 0 0-.079-.117A3 3 0 0 1 8 14.11zm5.329 5.643a1 1 0 0 1-.127-.268a2.9 2.9 0 0 1-.124-.882c0-.546.014-1.584.029-2.592l.004-.273c.012-.899.024-1.736.024-2.096c0-.616.16-.817.186-.845v-.001a1.79 ' +
      '1.79 0 0 1 1.764-.419l.026.008q.042.011.084.026q.229.08.429.215l.036.03q.014.014.032.026a1.8 1.8 0 0 1 .318.314q.03.034.056.073c.22.311.342.682.347 1.064v4.3a1.83 1.83 0 0 1-3.084 1.32m11.872 5.22c-.474.4-.923.786-1.241 ' +
      '1.119c-.862.8-1.564 1.5-2.2 2.136l-.087.086a50 50 0 0 1-1.854 1.782a10.47 10.47 0 0 1-7.41 3.135c-5.648 0-9.156-3.829-9.156-10.01L3.226 17.6a3.86 3.86 0 0 0 4.131-.45q.259.212.552.374l-.08.016q-.042.007-.08.017a1 ' +
      '1 0 0 0 .5 1.936a16 16 0 0 1 4.584-.344c.349.02.688.057 1.025.1a12.2 12.2 0 0 0-5.54 4.2a1 1 0 1 0 1.625 1.166A10.36 10.36 0 0 1 15 20.948a12.6 12.6 0 0 1 2.074-.537a10 10 0 0 1 .753-.097h.033a1 1 0 0 ' +
      '0 .431-1.875a9.3 9.3 0 0 0-2.177-.806a3.83 3.83 0 0 0 2.288-3.5V9.83q0-.391-.079-.773c1.365-2.167 3.784-4.2 7.736-2.544a1.666 1.666 0 0 1 .793 1.975c-.125.457-.746 1.7-1.937 1.394a3.19 3.19 0 0 0-2.729.246a2.05 ' +
      '2.05 0 0 0-.752 1.712l-.031 2.652c0 .535 0 1.649.876 2.029c.821.357 1.494-.272 2-.747q.195-.192.411-.36a1.935 1.935 0 0 1 2.807.407c1.177 1.479.241 2.695-2.297 4.859z'
  else if FilterName.Equals('Wave') then
    IconPath := 'M18.75 8.65q-.675.675-1.55 1.025t-1.75.35t-1.725-.337T12.2 8.65l-1.875-1.875q-.375-.375-.85-.562T8.5 6.025t-.975.188t-.85.562L4.8 8.65L3.375 7.225L5.25 5.35q.675-.675 1.525-1.012T8.5 4t1.713.338t1.512 1.012L13.6 7.225q.4.4.875.588T15.45 8t.988-.187t.887-.588L19.2 5.35l1.425 1.425zm0 5q-.675.675-1.537 1.013T15.474 15t-1.737-.337T12.2 13.65l-1.875-1.875q-.375-.375-.85-.562t-.975-.188t-.975.188t-.85.562L4.8 13.65l-1.425-1.4l1.875-1.9q.675-.675 1.525-1.012T8.5 9t1.713.338t1.512 1.012l1.875 1.875q.4.4.875.588t.975.187t.988-.187t.887-.588L19.2 10.35l1.425 1.425zm-.025 5q-.675.675-1.525 1.013T15.475 20t-1.737-.337T12.2 18.65l-1.9-1.875q-.375-.375-.85-.562t-.975-.188t-.975.188t-.85.562L4.775 18.65l-1.4-1.4l1.875-1.9q.675-.675 1.525-1.012T8.5 14t1.713.338t1.512 1.012l1.875 1.875q.4.4.888.588t.987.187t.975-.187t.875-.588L19.2 15.35l1.4 1.425z'
  else if FilterName.Equals('MaskToAlpha') then
    IconPath := 'M7.94 1.857c2.594-.185 6.394-.357 11.56-.357s8.966.172 11.56.357c3.3.236 5.847 2.782 6.083 6.084c.185 2.593.357 6.393.357 11.559s-.172 8.966-.357 11.56c-.236 3.3-2.782 5.847-6.084 6.083c-2.593.185-6.393.357-11.559.357s-8.966-.172-11.56-.357c-3.3-.236-5.847-2.782-6.083-6.084C1.672 ' +
      '28.466 1.5 24.666 1.5 19.5s.172-8.966.357-11.56c.236-3.3 2.782-5.847 6.084-6.083m18.69 8.65q.903-.007 1.87-.007c2.061 0 3.905.027 5.541.072a1.5 1.5 0 1 1-.082 2.999q-1.958-.055-4.335-.068l5.937 5.936a1.5 ' +
      '1.5 0 0 1-2.122 2.122l-8.038-8.039c-3.547.052-6.27.187-8.247.328a3.7 3.7 0 0 0-.98.202L33.06 30.94a1.5 1.5 0 0 1-2.122 2.122L14.052 16.174a3.7 3.7 0 0 0-.202.98c-.141 1.977-.277 4.7-.328 8.247l8.039 8.038a1.5 ' +
      '1.5 0 0 1-2.122 2.122l-5.936-5.937q.013 2.378.068 4.335a1.5 1.5 0 0 1-2.999.082a203 203 0 0 1-.064-7.412l-7.069-7.068a1.5 1.5 0 0 1 2.122-2.122l5.025 5.026c.068-2.24.168-4.071.271-5.524a6.6 6.6 0 0 1 .957-3.006L5.939 ' +
      '8.061a1.5 1.5 0 1 1 2.122-2.122l5.874 5.875c.878-.54 1.9-.878 3.006-.957c1.453-.103 3.285-.203 5.524-.27L17.439 5.56a1.5 1.5 0 0 1 2.122-2.122zM19.5 40c5.222 0 9.081-.174 11.738-.364c4.541-.324 8.074-3.857 ' +
      '8.399-8.399c.19-2.656.363-6.516.363-11.737c0-3.454-.076-6.312-.182-8.62c3.175.347 5.595 2.846 5.825 6.06c.185 2.594.357 6.394.357 11.56s-.172 8.966-.357 11.56c-.236 3.3-2.782 5.847-6.083 6.082c-2.594.186-6.394.358-11.56.358s-8.966-.172-11.56-.358c-3.3-.235-5.847-2.781-6.082-6.083l-.02-.268c2.399.12 ' +
      '5.433.209 9.162.209'
  else if FilterName.Equals('Fill') then
    IconPath := 'M20 14c-.092.064-2 2.083-2 3.5c0 1.494.949 2.448 2 2.5c.906.044 2-.891 2-2.5c0-1.5-1.908-3.436-2-3.5zM9.586 20c.378.378.88.586 1.414.586s1.036-.208 1.414-.586l7-7l-.707-.707L11 4.586L8.707 2.293L7.293 3.707L9.586 6L4 11.586c-.378.378-.586.88-.586 1.414s.208 1.036.586 1.414L9.586 20zM11 7.414L16.586 13H5.414L11 7.414z'
  else if FilterName.Equals('FillRGB') then
    IconPath := 'm441 336.2l-.06-.05c-9.93-9.18-22.78-11.34-32.16-12.92l-.69-.12c-9.05-1.49-10.48-2.5-14.58-6.17c-2.44-2.17-5.35-5.65-5.35-9.94s2.91-7.77 5.34-9.94l30.28-26.87c25.92-22.91 40.2-53.66 40.2-86.59s-14.25-63.68-40.2-86.6c-35.89-31.59-85-49-138.37-49C223.72 48 162 71.37 116 112.11c-43.87 38.77-68 90.71-68 146.24s24.16 107.47 68 146.23c21.75 19.24 47.49 34.18 76.52 44.42a266.2 266.2 0 0 0 86.87 15h1.81c61 0 119.09-20.57 159.39-56.4c9.7-8.56 15.15-20.83 15.34-34.56c.21-14.17-5.37-27.95-14.93-36.84M112 208a32 32 0 1 1 32 32a32 32 0 0 1-32-32m40 135a32 32 0 1 1 32-32a32 32 0 0 1-32 32m40-199a32 32 0 1 1 32 32a32 32 0 0 1-32-32m64 271a48 48 0 1 1 48-48a48 48 0 0 1-48 48m72-239a32 32 0 1 1 32-32a32 32 0 0 1-32 32'
  else if FilterName.Equals('Magnify') then
    IconPath := 'M11.25 5.75a.75.75 0 0 0 0 1.5A4.75 4.75 0 0 1 16 12a.75.75 0 0 0 1.5 0a6.25 6.25 0 0 0-6.251-6.25' +
      'M2 11.999C2 6.89 6.142 2.75 11.25 2.75s9.25 4.14 9.25 9.248a9.2 9.2 0 0 1-2.202 5.99l3.481 3.48a.75.75 0 1 1-1.06 1.061l-3.482-3.481a9.2 9.2 0 0 1-5.987 2.198c-5.108 0-9.25-4.14-9.25-9.248m9.25-7.748a7.749 ' +
      '7.749 0 1 0 0 15.496a7.749 7.749 0 1 0 0-15.496'
  else if FilterName.Equals('SmoothMagnify') then
    IconPath := 'M11 2c4.968 0 9 4.032 9 9a8.96 8.96 0 0 1-1.969 5.617l4.283 4.282l-1.415 1.415l-4.282-4.283A8.96 8.96 0 0 1 11 20c-4.968 0-9-4.032-9-9s4.032-9 9-9m0 2c-3.867 0-7 3.132-7 7s3.133 7 7 7a6.98 6.98 0 0 0 4.875-1.975l.15-.15A6.98 6.98 0 0 0 18 11c0-3.868-3.133-7-7-7m-.47 3.319a.507.507 0 0 1 .94 0l.254.611a4.37 4.37 0 0 0 2.25 2.327l.718.319a.53.53 0 0 1 0 .963l-.76.338a4.36 4.36 0 0 0-2.218 2.25l-.247.566a.506.506 0 0 1-.934 0l-.246-.565a4.36 4.36 0 0 0-2.22-2.251l-.76-.338a.53.53 0 0 1 0-.963l.718-.32a4.37 4.37 0 0 0 2.251-2.326z'
  else if FilterName.Equals('Pixelate') then
    IconPath := 'M2 2h20v20H2zm2 2v4h4v4H4v4h4v4h4v-4h4v4h4v-4h-4v-4h4V8h-4V4h-4v4H8V4zm8 8H8v4h4zm0-4v4h4V8z'
  else if FilterName.Equals('Monochrome') then
    IconPath := 'M12 17.5q1.875 0 3.188-1.312T16.5 13t-1.312-3.187T12 8.5T8.813 9.813T7.5 13t1.313 3.188T12 17.5m0-2q-1.05 0-1.775-.725T9.5 13t.725-1.775T12 10.5t1.775.725T14.5 13t-.725 1.775T12 15.5M4 21q-.825 0-1.412-.587T2 19V7q0-.825.588-1.412T4 5h3.15L9 3h6l1.85 2H20q.825 0 1.413.588T22 7v12q0 .825-.587 1.413T20 21zm8-2h8V7h-4.05l-1.825-2H12z'
  else if FilterName.Equals('PaperSketch') then
    IconPath := 'M10.036 7.698c-1.651 1.861-3.523 4.546-5.141 7.784a1 1 0 1 1-1.79-.895c1.692-3.383 3.66-6.215 5.434-8.216c.886-.999 1.74-1.81 2.506-2.38c.382-.285.76-.523 1.123-.693c.351-.166.753-.298 1.166-.298a1.24 ' +
      '1.24 0 0 1 1.116.69c.157.312.174.645.17.87c-.008.477-.135 1.073-.298 1.68c-.335 1.243-.923 2.891-1.507 4.518l-.082.228c-.566 1.574-1.123 3.123-1.485 4.36q-.146.501-.239.895c.694-.557 1.55-1.396 2.457-2.288l.03-.029c.881-.866 ' +
      '1.814-1.782 2.6-2.411c.391-.312.812-.609 1.218-.78c.34-.145 1.12-.38 1.727.227c.384.384.49.884.518 1.256c.03.39-.016.81-.087 1.21c-.14.8-.424 1.733-.683 2.575l-.041.135c-.232.751-.438 1.422-.555 1.96c.26-.26.58-.674.954-1.285a1 ' +
      '1 0 1 1 1.706 1.045c-.543.886-1.105 1.606-1.701 2.053c-.624.468-1.44.732-2.266.319c-.608-.305-.746-.91-.777-1.246c-.033-.363.02-.759.089-1.115c.13-.673.385-1.497.625-2.276l.055-.178c.267-.868.51-1.679.625-2.334l.024-.145l-.181.14c-.698.559-1.561 ' +
      '1.405-2.478 2.306l-.03.03c-.881.865-1.814 1.782-2.6 2.41c-.391.313-.812.61-1.218.781c-.34.145-1.12.38-1.727-.227c-.309-.309-.388-.699-.413-.936a3.5 3.5 0 0 1 .023-.803c.068-.528.226-1.17.426-1.85c.38-1.298.955-2.9 ' +
      '1.512-4.449l.092-.255c.593-1.652 1.149-3.214 1.457-4.36l.074-.286a7 7 0 0 0-.224.16c-.623.464-1.377 1.17-2.204 2.103'
  else if FilterName.Equals('PencilStroke') then
    IconPath := 'M15.275 12.475L11.525 8.7L14.3 5.95l-.725-.725L8.8 10q-.3.3-.7.3t-.7-.3t-.3-.712t.3-.713l4.75-4.75q.6-.6 1.413-.6t1.412.6l.725.725l1.25-1.25q.3-.3.713-.3t.712.3L20.7 5.625q.3.3.3.713t-.3.712zM4 21q-.425 0-.712-.288T3 20v-1.925q0-.4.15-.763t.425-.637l6.525-6.55l3.775 3.75l-6.55 6.55q-.275.275-.637.425t-.763.15z'
  else if FilterName.Equals('PerspectiveTransform') then
    IconPath := 'M240 120h-16V48a16 16 0 0 0-18.86-15.74l-160 29.09A16 16 0 0 0 32 77.09V120H16a8 8 0 0 0 0 16h16v42.91a16 16 0 0 0 13.14 15.74l160 29.09a16.5 16.5 0 0 0 2.86.26a16 16 0 0 0 16-16v-72h16a8 8 0 0 0 0-16M48 77.09L208 48v72H48ZM208 208L48 178.91V136h160Z'
  else if FilterName.Equals('ReflectionFilter') then
    IconPath := 'M16.25 7.75a1.25 1.25 0 1 1-2.5 0a1.25 1.25 0 0 1 2.5 0m.667 9.242a2 2 0 0 1-.167.008h-1a.75.75 0 0 0 0 1.5h1c.966 0 1.75.784 1.75 1.75V21a.75.75 0 0 0 1.5 0v-.75a3.24 3.24 0 0 0-1.173-2.5A3.24 3.24 0 ' +
      '0 0 20 15.25v-9A3.25 3.25 0 0 0 16.75 3h-9.5A3.25 3.25 0 0 0 4 6.25v9c0 1.005.456 1.904 1.173 2.5A3.24 3.24 0 0 0 4 20.25V21a.75.75 0 0 0 1.5 0v-.75c0-.966.784-1.75 1.75-1.75h1a.75.75 0 0 0 0-1.5h-1q-.086 ' +
      '0-.168-.008l4.394-4.284a.75.75 0 0 1 1.047 0zM7.25 4.5h9.5c.966 0 1.75.784 1.75 1.75v9c0 .342-.098.66-.267.93l-4.663-4.546a2.25 2.25 0 0 0-3.14 0l-4.663 4.545a1.74 1.74 0 0 1-.267-.929v-9c0-.966.784-1.75 ' +
      '1.75-1.75m4 12.5a.75.75 0 0 0 0 1.5h1.5a.75.75 0 0 0 0-1.5z'
  else if FilterName.Equals('Ripple') then
    IconPath := 'M490.594 16.5C475.867 89.867 453.31 155.58 422.5 214.063c-21.152 25.636-62.322 41.665-103.53 34.375c43.72-60.817 65.875-137.485 56.75-217.813c-16.566 59.05-35.182 107.876-58.876 150.063c-15.774 16.782-43.006 ' +
      '26.035-71.03 17.562c32.043-43.75 48.387-99.21 41.78-157.375c-10.346 33.145-23.852 63.82-40.313 92.094c-14.07 15.776-39.033 24.72-64.843 17.186c21.468-29.682 32.4-67.153 27.938-106.437c-8.185 18.823-17.562 ' +
      '36.73-28.063 53.718c-13.755 11.638-44.94 9.03-68.406.906l-1.03-.78c12.087-18.074 16.897-41.415 11.655-66.783a207 207 0 0 1-15.186 31.94c-10.587 17.13-38.888 3.862-57.5-8.782c15.907 14.915 32.82 40.912 ' +
      '17.375 58.53c-8.39 7.818-17.43 15.142-27.095 21.938c23.353-.655 43.408-8.87 58.125-22.22c22.488 19.768 27.623 50.15 16.688 65.876a424 424 0 0 1-40.657 34.188c37.302-4.225 69.916-21.612 93.75-47l1.407 1.125c11.843 ' +
      '22.98 8.502 48.584-3.718 65.188c-23.105 21.13-48.766 40.03-76.876 56.687c57.276-6.488 107.018-34.138 142.344-74.25l1.03.813c13.878 25.61 10.338 54.48-3.312 73.062c-35.078 31.465-77.614 59.935-130.312 88.625c80.3-9.095 ' +
      '150.015-47.894 199.437-104.22c19.344 39.258 12.064 82.842-10.25 109.47c-49.987 43.37-108.914 79.872-177.217 109.97C348.12 465.035 517.375 252.265 490.592 16.5z'
  else if FilterName.Equals('Sharpen') then
    IconPath := 'M6 21q-1.125 0-2.225-.55T2 19q.65 0 1.325-.513T4 17q0-1.25.875-2.125T7 14t2.125.875T10 17q0 1.65-1.175 2.825T6 21m5.75-6L9 12.25l9.65-9.65l2.75 2.75z'
  else if FilterName.Equals('Crop') then
    IconPath := 'M17.5 22v-3.5H7.116q-.691 0-1.153-.462T5.5 16.884V6.5H2q-.213 0-.356-.144T1.5 5.999t.144-.356T2 5.5h3.5V2q0-.213.144-.356t.357-.144t.356.144T6.5 2v14.885q0 .23.192.423t.423.192H22q.213 0 .356.144t.144.357t-.144.356T22 18.5h-3.5V22q0 .213-.144.356t-.357.144t-.356-.144T17.5 22m0-5.5V7.116q0-.231-.192-.424t-.424-.192H7.5v-1h9.385q.69 0 1.153.463t.462 1.153V16.5z'
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

end.

