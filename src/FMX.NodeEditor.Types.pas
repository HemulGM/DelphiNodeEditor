unit FMX.NodeEditor.Types;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Types, System.Rtti,
  System.UITypes, FMX.Graphics, System.Math.Vectors, System.NetEncoding;

{$SCOPEDENUMS ON}

type
  ENodeEditorException = class(Exception);

  { Execution and debugging }

  TDebugStepMode = (None, StepOver, StepInto);

  TDebugState = (Stopped, Running, Paused, Error);

  //TExecutionMode = (DataFlow, ControlFlow, Mixed);

  TGraphExecutionError = (None, GraphIsNil, InvalidStartNode, DataCycleDetected, NodeEvaluationFailed, PinEvaluationFailed, ExecStepLimitExceeded);

  TNodeValueState = (Missing, Evaluating, Ready);

  { View }

  TGridType = (Lines, Dots);

  TLinkVisualType = (Bezier, Line, PolyLine, Rect);

  { Graph }

  TGraphValidationIssueKind = (Error, Warning);

  { Nodes }

  TNodeVisualKind = (Normal, Reroute, Comment);

  TNodeValueKind = (Null, Float, Integer, &String, Boolean, JSON, Bitmap, Color, Point);

  TNodeValueKindHelper = record helper for TNodeValueKind
    function ToString: string;
  end;

  { Pins }

  TPinDirection = (Input, Output);

  TPinTypeFlag = (Any, &Array, List, Map, &Object, Nullable, Optional, Generic, Wildcard);

  TPinTypeFlags = set of TPinTypeFlag;

  TPinKind = (Data, Exec);

  TPinCompatible = (Undefined, True, False);

  { Alignment }

  TAlignMode = (Left, Right, Top, Bottom, CenterHorizontal, CenterVertical);

  TDistributeMode = (Horizontal, Vertical);

  TMatchSizeMode = (Width, Height, Both);

  { Controls }

  TMoveDirection = (Left, Up, Right, Down);

  IBitmapNodeObject = interface
    ['{A6EF944A-8D2D-4301-A378-9A708868A3AC}']
    function GetBitmap: TBitmap;
    procedure SetBitmap(Bitmap: TBitmap);
    function GetIsEmpty: Boolean;
  end;

  TBitmapObject = class(TInterfacedObject, IBitmapNodeObject)
  protected
    FBitmap: TBitmap;
  public
    function GetBitmap: TBitmap;
    procedure SetBitmap(Bitmap: TBitmap);
    function GetIsEmpty: Boolean;
    destructor Destroy; override;
  end;

function NodeValueKindToStr(AKind: TNodeValueKind): string;

function StrToNodeValueKind(const S: string): TNodeValueKind;

function IntToTypeFlags(AValue: integer): TPinTypeFlags;

function TypeFlagsToInt(AFlags: TPinTypeFlags): integer;

//

function PinKindToStr(AKind: TPinKind): string;

function StrToPinKind(const S: string): TPinKind;

function PinDirectionToStr(ADir: TPinDirection): string;

function StrToPinDirection(const S: string): TPinDirection;

//

function NewId: string;

//

procedure DrawPlus(const Canvas: TCanvas; const PositionCenter: TPointF; const Size: Single; const Opacity: Single);

procedure DrawShadowedRect(Canvas: TCanvas; const R: TRectF; Radius, Zoom, Opacity: Single); inline;

procedure DrawGlowLine(Canvas: TCanvas; const P1, P2: TPointF; Color: TAlphaColor; Opacity: Single); inline;

function ScaleRectFFromCenter(const R: TRectF; const ScaleX, ScaleY: Single): TRectF; inline;

procedure GetGradientPoints(const P1, P2: TPointF; out StartPos, StopPos: TPointF); inline;

function MakeColor(const Color: TAlphaColor; Alpha: Single): TAlphaColor; inline;

function AddGradientPoint(Gradient: TGradient; Offset: Single; Color: TAlphaColor): TGradientPoint; inline;

function ColorToAlphaColor(Color: TColor): TAlphaColor; inline;

function ChangeAlpha(Color: TAlphaColor; Alpha: Byte): TAlphaColor; inline;

procedure Log(const Text: string); inline;

function ScreenToWorld(X, Y: Double; Zoom, OffsetX, OffsetY: Double): TPointF; inline;

function WorldToScreen(X, Y: Single; Zoom, OffsetX, OffsetY: Double): TPointF; inline; overload;

function WorldToScreen(const Point: TPointF; Zoom, OffsetX, OffsetY: Double): TPointF; inline; overload;

function WorldToScreen(const Rect: TRectF; Zoom, OffsetX, OffsetY: Double): TRectF; inline; overload;

function BuildTriangle(const Center: TPointF; Radius: Single; StartAngle: Single): TPolygon;

//

function BitmapToBase64(Bitmap: IBitmapNodeObject): string;

function Base64ToBitmap(const Base64: string): IBitmapNodeObject;

//

function NodeValueToFloatDef(const AValue: TValue; const ADefault: Double = 0.0): Double;

function NodeValueToStringDef(const AValue: TValue; const ADefault: string = ''): string;

function NodeValueToColorDef(const AValue: TValue; const ADefault: TAlphaColor = TAlphaColors.Null): TAlphaColor;

function NodeValueToBoolDef(const AValue: TValue; const ADefault: Boolean = False): Boolean;

function NodeValueToPointDef(const AValue: TValue; const ADefault: TPointF): TPointF;

function NodeValueToBitmapDef(const AValue: TValue; const ADefault: IBitmapNodeObject = nil): IBitmapNodeObject;

function NodeValueToIntDef(const AValue: TValue; const ADefault: Int64 = 0): Int64;

//

function MakeFloatValue(const AValue: Double): TValue;

function MakeColorValue(const AValue: TAlphaColor): TValue;

function MakeBoolValue(const AValue: Boolean): TValue;

function MakeIntValue(const AValue: int64): TValue;

function MakeBitmapValue(const AValue: IBitmapNodeObject): TValue;

function MakeStringValue(const AValue: string): TValue;

function MakePointValue(const AValue: TPointF): TValue;

var
  CachePathObject: TPathData;

implementation

uses
  FMX.Types;

function MakeFloatValue(const AValue: double): TValue;
begin
  Result := AValue;
end;

function MakeColorValue(const AValue: TAlphaColor): TValue;
begin
  Result := AValue;
end;

function MakeBoolValue(const AValue: boolean): TValue;
begin
  Result := AValue;
end;

function MakeIntValue(const AValue: int64): TValue;
begin
  Result := AValue;
end;

function MakeBitmapValue(const AValue: IBitmapNodeObject): TValue;
begin
  Result := TValue.From<IBitmapNodeObject>(AValue);
end;

function MakeStringValue(const AValue: string): TValue;
begin
  Result := AValue;
end;

function MakePointValue(const AValue: TPointF): TValue;
begin
  Result := TValue.From<TPointF>(AValue);
end;

function NodeValueToBitmapDef(const AValue: TValue; const ADefault: IBitmapNodeObject = nil): IBitmapNodeObject;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  if AValue.IsType<IBitmapNodeObject>then
    Result := AValue.AsType<IBitmapNodeObject>
  else
    Result := ADefault;
end;

function NodeValueToPointDef(const AValue: TValue; const ADefault: TPointF): TPointF;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  if AValue.IsType<TPointF>then
    Result := AValue.AsType<TPointF>
  else
    Result := ADefault;
end;

function NodeValueToBoolDef(const AValue: TValue; const ADefault: Boolean): Boolean;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkInteger:
      Result := AValue.AsInteger <> 0;
    tkInt64:
      Result := AValue.AsInt64 <> 0;
    tkFloat:
      Result := Abs(AValue.AsExtended) > 1e-12;
    tkString, tkLString, tkWString, tkUString:
      begin
        var S := AValue.AsString.ToLower.Trim;
        Result := (S = 'true') or (S = '1') or (S = 'yes');
      end;
  else
    var B: Boolean;
    if AValue.TryAsType<Boolean>(B, False) then
      Exit(B);
    Result := ADefault;
  end;
end;

function NodeValueToIntDef(const AValue: TValue; const ADefault: Int64): Int64;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkInteger:
      Result := AValue.AsInteger;
    tkInt64:
      Result := AValue.AsInt64;
    tkFloat:
      Result := Trunc(AValue.AsExtended);
    tkString, tkLString, tkWString, tkUString:
      begin
        if not TryStrToInt64(AValue.AsString, Result) then
          Result := ADefault;
      end;
  else
    var B: Boolean;
    if AValue.TryAsType<Boolean>(B, False) then
      if B then
        Exit(1)
      else
        Exit(0);
    Result := ADefault;
  end;
end;

function NodeValueToColorDef(const AValue: TValue; const ADefault: TAlphaColor = TAlphaColors.Null): TAlphaColor;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  if AValue.IsType<TAlphaColor>then
    Result := AValue.AsType<TAlphaColor>
  else
    Result := ADefault;
end;

function NodeValueToFloatDef(const AValue: TValue; const ADefault: Double): Double;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkFloat:
      Result := AValue.AsExtended;
    tkInteger:
      Result := AValue.AsInteger;
    tkInt64:
      Result := AValue.AsInt64;
    tkLString, tkWString, tkUString, tkString:
      begin
        if not TryStrToFloat(AValue.AsString, Result, FormatSettings) then
          Result := ADefault;
      end;
  else
    Result := ADefault;
  end;
end;

function NodeValueToStringDef(const AValue: TValue; const ADefault: string): string;
begin
  if AValue.IsEmpty then
    Exit(ADefault);

  case AValue.Kind of
    tkString, tkLString, tkWString, tkUString:
      Result := AValue.AsString;
    tkInteger:
      Result := AValue.AsInteger.ToString;
    tkInt64:
      Result := AValue.AsInt64.ToString;
    tkChar:
      Result := AValue.AsString;
    tkFloat:
      Result := AValue.AsExtended.ToString;
  else
    var B: Boolean;
    if AValue.TryAsType<Boolean>(B, False) then
      if B then
        Exit('True')
      else
        Exit('False');
    Result := ADefault;
  end;
end;

function BitmapToBase64(Bitmap: IBitmapNodeObject): string;
begin
  if not Assigned(Bitmap) or Bitmap.GetIsEmpty then
    Exit('');
  var Stream := TBytesStream.Create;
  try
    Bitmap.GetBitmap.SaveToStream(Stream);
    Result := TNetEncoding.Base64String.EncodeBytesToString(Stream.Bytes);
  finally
    Stream.Free;
  end;
end;

function Base64ToBitmap(const Base64: string): IBitmapNodeObject;
begin
  if Base64.IsEmpty then
    Exit(nil);
  var Stream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(Base64));
  try
    Stream.Position := 0;
    Result := TBitmapObject.Create;
    Result.SetBitmap(TBitmap.CreateFromStream(Stream));
  finally
    Stream.Free;
  end;
end;

procedure Log(const Text: string);
begin
  {$IFDEF LOG}
  Writeln(Text);
  {$ENDIF}
end;

function BuildTriangle(const Center: TPointF; Radius: Single; StartAngle: Single): TPolygon;
begin
  SetLength(Result, 3);

  for var i := 0 to 2 do
  begin
    var Angle := DegToRad(StartAngle + i * 120);
    Result[i] := PointF(Center.X + Radius * Cos(Angle), Center.Y + Radius * Sin(Angle));
  end;
end;

function ChangeAlpha(Color: TAlphaColor; Alpha: Byte): TAlphaColor;
begin
  Result := TAlphaColorF.Create(TAlphaColorRec(Color).R / 255, TAlphaColorRec(Color).G / 255, TAlphaColorRec(Color).B / 255, Alpha / 255).ToAlphaColor;
end;

function ColorToAlphaColor(Color: TColor): TAlphaColor;
begin
  Result := TAlphaColorF.Create(TColorRec(Color).R / 255, TColorRec(Color).G / 255, TColorRec(Color).B / 255, 1).ToAlphaColor;
end;

function MakeColor(const Color: TAlphaColor; Alpha: Single): TAlphaColor;
var
  C: TAlphaColorRec;
begin
  C.Color := Color;
  C.A := Round(255 * Alpha);
  Result := C.Color;
end;

procedure GetGradientPoints(const P1, P2: TPointF; out StartPos, StopPos: TPointF);
var
  DX, DY, Len: Single;
begin
  DX := P2.X - P1.X;
  DY := P2.Y - P1.Y;

  Len := Sqrt(DX * DX + DY * DY);

  if Len = 0 then
  begin
    StartPos := PointF(0.5, 0.5);
    StopPos := PointF(0.5, 0.5);
    Exit;
  end;

  DX := DX / Len;
  DY := DY / Len;

  // центрируем относительно 0.5
  StartPos := PointF(
    0.5 - DX * 0.5,
    0.5 - DY * 0.5);

  StopPos := PointF(
    0.5 + DX * 0.5,
    0.5 + DY * 0.5);
end;

function PinKindToStr(AKind: TPinKind): string;
begin
  if AKind = TPinKind.Exec then
    Result := 'exec'
  else
    Result := 'data';
end;

function StrToPinKind(const S: string): TPinKind;
begin
  if SameText(S, 'exec') then
    Result := TPinKind.Exec
  else
    Result := TPinKind.Data;
end;

function PinDirectionToStr(ADir: TPinDirection): string;
begin
  if ADir = TPinDirection.Input then
    Result := 'input'
  else
    Result := 'output';
end;

function StrToPinDirection(const S: string): TPinDirection;
begin
  if SameText(S, 'output') then
    Result := TPinDirection.Output
  else
    Result := TPinDirection.Input;
end;

function NodeValueKindToStr(AKind: TNodeValueKind): string;
begin
  case AKind of
    TNodeValueKind.Float:
      Result := 'float';
    TNodeValueKind.Integer:
      Result := 'integer';
    TNodeValueKind.string:
      Result := 'string';
    TNodeValueKind.Boolean:
      Result := 'boolean';
    TNodeValueKind.JSON:
      Result := 'json';
    TNodeValueKind.Bitmap:
      Result := 'bitmap';
    TNodeValueKind.Color:
      Result := 'color';
    TNodeValueKind.Point:
      Result := 'point';
  else
    Result := 'null';
  end;
end;

function StrToNodeValueKind(const S: string): TNodeValueKind;
begin
  if SameText(S, 'float') then
    Result := TNodeValueKind.Float
  else if SameText(S, 'integer') then
    Result := TNodeValueKind.Integer
  else if SameText(S, 'string') then
    Result := TNodeValueKind.string
  else if SameText(S, 'boolean') then
    Result := TNodeValueKind.Boolean
  else if SameText(S, 'json') then
    Result := TNodeValueKind.JSON
  else if SameText(S, 'bitmap') then
    Result := TNodeValueKind.Bitmap
  else if SameText(S, 'color') then
    Result := TNodeValueKind.Color
  else if SameText(S, 'point') then
    Result := TNodeValueKind.Point
  else
    Result := TNodeValueKind.Null;
end;

function TypeFlagsToInt(AFlags: TPinTypeFlags): Integer;
begin
  Result := 0;
  for var F := Low(TPinTypeFlag) to High(TPinTypeFlag) do
    if F in AFlags then
      Result := Result or (1 shl Ord(F));
end;

function IntToTypeFlags(AValue: integer): TPinTypeFlags;
begin
  Result := [];
  for var F := Low(TPinTypeFlag) to High(TPinTypeFlag) do
    if (AValue and (1 shl Ord(F))) <> 0 then
      Include(Result, F);
end;

function ScaleRectFFromCenter(const R: TRectF; const ScaleX, ScaleY: Single): TRectF;
var
  C: TPointF;
  W, H: Single;
begin
  C := R.CenterPoint;

  W := R.Width * ScaleX * 0.5;
  H := R.Height * ScaleY * 0.5;

  Result := RectF(C.X - W, C.Y - H, C.X + W, C.Y + H);
end;

function NewId: string;
begin
  Result := TGUID.NewGuid.ToString;
end;

function WorldToScreen(X, Y: Single; Zoom, OffsetX, OffsetY: Double): TPointF;
begin
  Result.X := X * Zoom + OffsetX;
  Result.Y := Y * Zoom + OffsetY;
end;

function WorldToScreen(const Point: TPointF; Zoom, OffsetX, OffsetY: Double): TPointF;
begin
  Result.X := Point.X * Zoom + OffsetX;
  Result.Y := Point.Y * Zoom + OffsetY;
end;

function WorldToScreen(const Rect: TRectF; Zoom, OffsetX, OffsetY: Double): TRectF;
begin
  Result.Left := Rect.Left * Zoom + OffsetX;
  Result.Top := Rect.Top * Zoom + OffsetY;
  Result.Right := Rect.Right * Zoom + OffsetX;
  Result.Bottom := Rect.Bottom * Zoom + OffsetY;
end;

function ScreenToWorld(X, Y: Double; Zoom, OffsetX, OffsetY: Double): TPointF;
begin
  Result.X := (X - OffsetX) / Zoom;
  Result.Y := (Y - OffsetY) / Zoom;
end;

function AddGradientPoint(Gradient: TGradient; Offset: Single; Color: TAlphaColor): TGradientPoint;
begin
  Result := TGradientPoint(Gradient.Points.Add);
  Result.Color := Color;
  Result.Offset := Offset;
end;

procedure DrawPlus(const Canvas: TCanvas; const PositionCenter: TPointF; const Size: Single; const Opacity: Single);
begin
  var HalfSize := Size * 0.5;

  // Horz
  Canvas.DrawLine(
    PointF(PositionCenter.X - HalfSize, PositionCenter.Y),
    PointF(PositionCenter.X + HalfSize, PositionCenter.Y),
    Opacity
  );

  // Vert
  Canvas.DrawLine(
    PointF(PositionCenter.X, PositionCenter.Y - HalfSize),
    PointF(PositionCenter.X, PositionCenter.Y + HalfSize),
    Opacity
  );
end;

procedure DrawShadowedRect(Canvas: TCanvas; const R: TRectF; Radius, Zoom, Opacity: Single);
const
  sL = 6;
  sM = 3;
  sS = 2;
  sR = 1;
begin
  // Large
  var S := R;//ScaleRectFFromCenter(R, -Zoom, -Zoom);
  InflateRect(S, sL * Zoom, sL * Zoom);
  OffsetRect(S, 0, sM * Zoom);

  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := $10000000;
  Canvas.FillRect(S, Radius + sL * Zoom, Radius + sL * Zoom, AllCorners, Opacity);

  // Mid
  S := R;
  InflateRect(S, sM * Zoom, sM * Zoom);
  OffsetRect(S, 0, sS * Zoom);

  Canvas.Fill.Color := $18000000;
  Canvas.FillRect(S, Radius + sM * Zoom, Radius + sM * Zoom, AllCorners, Opacity);

  // Small
  S := R;
  OffsetRect(S, 0, sR * Zoom);

  Canvas.Fill.Color := $30000000;
  Canvas.FillRect(S, Radius, Radius, AllCorners, Opacity);

  // Rect
  Canvas.Fill.Color := $FF2B2B2B;
  Canvas.FillRect(R, Radius, Radius, AllCorners, Opacity);
end;

procedure DrawGlowLine(Canvas: TCanvas; const P1, P2: TPointF; Color: TAlphaColor; Opacity: Single);
begin
  // outer glow
  Canvas.Stroke.Kind := TBrushKind.Solid;

  Canvas.Stroke.Color := MakeColor(Color, 0.08);
  Canvas.Stroke.Thickness := 10;
  Canvas.DrawLine(P1, P2, Opacity);

  Canvas.Stroke.Color := MakeColor(Color, 0.15);
  Canvas.Stroke.Thickness := 6;
  Canvas.DrawLine(P1, P2, Opacity);

  Canvas.Stroke.Color := MakeColor(Color, 0.25);
  Canvas.Stroke.Thickness := 3;
  Canvas.DrawLine(P1, P2, Opacity);
              {
  // core line
  Canvas.Stroke.Color := MakeColor(Color, 1.0);
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawLine(P1, P2, 1);   }
end;

{ TBitmapObject }

destructor TBitmapObject.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

function TBitmapObject.GetBitmap: TBitmap;
begin
  Result := FBitmap;
end;

function TBitmapObject.GetIsEmpty: Boolean;
begin
  Result := not Assigned(FBitmap);
end;

procedure TBitmapObject.SetBitmap(Bitmap: TBitmap);
begin
  FBitmap.Free;
  FBitmap := Bitmap;
end;

{ TNodeValueKindHelper }

function TNodeValueKindHelper.ToString: string;
begin
  Result := NodeValueKindToStr(Self);
end;

initialization
  CachePathObject := TPathData.Create;
  // Initiate private capacity for CachePathObject
  var TMP := TPathData.Create;
  try
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    TMP.MoveTo(TPointF.Create(0, 0));
    CachePathObject.AddPath(TMP);
  finally
    TMP.Free;
  end;

finalization
  CachePathObject.Free;

end.

