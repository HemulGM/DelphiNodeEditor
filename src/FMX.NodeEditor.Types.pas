unit FMX.NodeEditor.Types;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Types, System.UITypes,
  FMX.Graphics, System.Math.Vectors;

{$SCOPEDENUMS ON}

type
  TGridType = (Lines, Dots);

  TPinDirection = (Input, Output);

  TAlignMode = (Left, Right, Top, Bottom, CenterHorizontal, CenterVertical);

  TDistributeMode = (Horizontal, Vertical);

  TMatchSizeMode = (Width, Height, Both);

  TMoveDirection = (Left, Up, Right, Down);

  TNodeValueKind = (
    Null,
    Float,
    Integer,
    &String,
    Boolean,
    JSON
    );

  TNodePinTypeFlag = (
    Any,
    &Array,
    List,
    Map,
    &Object,
    Nullable,
    Optional,
    Generic,
    Wildcard
    );

  TNodePinTypeFlags = set of TNodePinTypeFlag;

  TPinKind = (Data, Exec);

  TPinCompatible = (Undefined, True, False);

  TNodeVisualKind = (Normal, Reroute, Comment);

  TLinkVisualType = (Bezier, Line, PolyLine, Rect);

function NodeValueKindToStr(AKind: TNodeValueKind): string;

function StrToNodeValueKind(const S: string): TNodeValueKind;

function IntToTypeFlags(AValue: integer): TNodePinTypeFlags;

function TypeFlagsToInt(AFlags: TNodePinTypeFlags): integer;

//

function PinKindToStr(AKind: TPinKind): string;

function StrToPinKind(const S: string): TPinKind;

function PinDirectionToStr(ADir: TPinDirection): string;

function StrToPinDirection(const S: string): TPinDirection;

//

function NewId: string;

//

procedure DrawShadowedRect(Canvas: TCanvas; const R: TRectF; Radius, Zoom: Single); inline;

procedure DrawGlowLine(Canvas: TCanvas; const P1, P2: TPointF; Color: TAlphaColor); inline;

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

var
  CachePathObject: TPathData;

implementation

uses
  FMX.Types;

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
  else
    Result := TNodeValueKind.Null;
end;

function TypeFlagsToInt(AFlags: TNodePinTypeFlags): Integer;
begin
  Result := 0;
  for var F := Low(TNodePinTypeFlag) to High(TNodePinTypeFlag) do
    if F in AFlags then
      Result := Result or (1 shl Ord(F));
end;

function IntToTypeFlags(AValue: integer): TNodePinTypeFlags;
begin
  Result := [];
  for var F := Low(TNodePinTypeFlag) to High(TNodePinTypeFlag) do
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

procedure DrawShadowedRect(Canvas: TCanvas; const R: TRectF; Radius, Zoom: Single);
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
  Canvas.FillRect(S, Radius + sL * Zoom, Radius + sL * Zoom, AllCorners, 1);

  // Mid
  S := R;
  InflateRect(S, sM * Zoom, sM * Zoom);
  OffsetRect(S, 0, sS * Zoom);

  Canvas.Fill.Color := $18000000;
  Canvas.FillRect(S, Radius + sM * Zoom, Radius + sM * Zoom, AllCorners, 1);

  // Small
  S := R;
  OffsetRect(S, 0, sR * Zoom);

  Canvas.Fill.Color := $30000000;
  Canvas.FillRect(S, Radius, Radius, AllCorners, 1);

  // Rect
  Canvas.Fill.Color := $FF2B2B2B;
  Canvas.FillRect(R, Radius, Radius, AllCorners, 1);
end;

procedure DrawGlowLine(Canvas: TCanvas; const P1, P2: TPointF; Color: TAlphaColor);
begin
  // outer glow
  Canvas.Stroke.Kind := TBrushKind.Solid;

  Canvas.Stroke.Color := MakeColor(Color, 0.08);
  Canvas.Stroke.Thickness := 10;
  Canvas.DrawLine(P1, P2, 1);

  Canvas.Stroke.Color := MakeColor(Color, 0.15);
  Canvas.Stroke.Thickness := 6;
  Canvas.DrawLine(P1, P2, 1);

  Canvas.Stroke.Color := MakeColor(Color, 0.25);
  Canvas.Stroke.Thickness := 3;
  Canvas.DrawLine(P1, P2, 1);
              {
  // core line
  Canvas.Stroke.Color := MakeColor(Color, 1.0);
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawLine(P1, P2, 1);   }
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

