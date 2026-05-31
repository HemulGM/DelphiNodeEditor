unit FMX.NodeEditor.Types;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Types, System.UITypes,
  FMX.Graphics;

{$SCOPEDENUMS ON}

type
  TGridType = (Lines, Dots);

  TPinDirection = (Input, Output);

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

  TLinkVisualType = (Bezier, Direct, Rect);

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

function PointInRectInclusive(const R: TRect; X, Y: integer): boolean; inline;

function Cross(const AX, AY, BX, BY, CX, CY: integer): Int64; inline;

function OnSegment(const AX, AY, BX, BY, PX, PY: integer): boolean; inline;

function SegmentsIntersect(AX, AY, BX, BY, CX, CY, DX, DY: integer): boolean; inline;

function LineIntersectsRect(X1, Y1, X2, Y2: integer; const R: TRect): boolean; inline;

function CubicBezierPoint(const P0, P1, P2, P3: TPoint; T: Double): TPointF; inline;

function DistancePointToSegment(const P, A, B: TPointF): Single; inline;

procedure DrawCubicBezier(Canvas: TCanvas; const P0, P1, P2, P3: TPoint; Opacity: Single); inline;

procedure DrawDirectLine(C: TCanvas; const P0, P1, P2, P3: TPoint; Opacity: Single); inline;

procedure DrawShadowedRect(Canvas: TCanvas; const R: TRectF; Radius, Zoom: Single); inline;

procedure DrawGlowLine(Canvas: TCanvas; const P1, P2: TPointF; Color: TAlphaColor); inline;

function PointNearPath(const P: TPointF; P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean; inline;

function PointNearPathDirect(const P, P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean; inline;

function ScaleRectFFromCenter(const R: TRectF; const ScaleX, ScaleY: Single): TRectF; inline;

procedure GetGradientPoints(const P1, P2: TPointF; out StartPos, StopPos: TPointF); inline;

function MakeColor(const Color: TAlphaColor; Alpha: Single): TAlphaColor; inline;

function AddGradientPoint(Gradient: TGradient; Offset: Single; Color: TAlphaColor): TGradientPoint; inline;

function ColorToAlphaColor(Color: TColor): TAlphaColor; inline;

function LineIntersectsRectF(const P1, P2: TPointF; const R: TRectF): Boolean; inline;

function CubicBezierPointF(const P0, P1, P2, P3: TPointF; T: single): TPointF; inline;

function ChangeAlpha(Color: TAlphaColor; Alpha: Byte): TAlphaColor; inline;

var
  CachePathObject: TPathData;

implementation

uses
  FMX.Types, System.Math.Vectors;

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

function RectIntersects(const A, B: TRect): boolean;
begin
  Result := not ((A.Right < B.Left) or (A.Left > B.Right) or
    (A.Bottom < B.Top) or (A.Top > B.Bottom));
end;

function PointInRectInclusive(const R: TRect; X, Y: integer): boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

function Cross(const AX, AY, BX, BY, CX, CY: integer): Int64;
begin
  Result := Int64(BX - AX) * Int64(CY - AY) - Int64(BY - AY) * Int64(CX - AX);
end;

function OnSegment(const AX, AY, BX, BY, PX, PY: integer): boolean;
begin
  Result :=
    (Min(AX, BX) <= PX) and (PX <= Max(AX, BX)) and
    (Min(AY, BY) <= PY) and (PY <= Max(AY, BY));
end;

function SegmentsIntersect(AX, AY, BX, BY, CX, CY, DX, DY: integer): boolean;
var
  C1, C2, C3, C4: Int64;
begin
  C1 := Cross(AX, AY, BX, BY, CX, CY);
  C2 := Cross(AX, AY, BX, BY, DX, DY);
  C3 := Cross(CX, CY, DX, DY, AX, AY);
  C4 := Cross(CX, CY, DX, DY, BX, BY);

  if (((C1 > 0) and (C2 < 0)) or ((C1 < 0) and (C2 > 0))) and
    (((C3 > 0) and (C4 < 0)) or ((C3 < 0) and (C4 > 0))) then
    Exit(True);

  if (C1 = 0) and OnSegment(AX, AY, BX, BY, CX, CY) then
    Exit(True);
  if (C2 = 0) and OnSegment(AX, AY, BX, BY, DX, DY) then
    Exit(True);
  if (C3 = 0) and OnSegment(CX, CY, DX, DY, AX, AY) then
    Exit(True);
  if (C4 = 0) and OnSegment(CX, CY, DX, DY, BX, BY) then
    Exit(True);

  Result := False;
end;

function LineIntersectsRect(X1, Y1, X2, Y2: integer; const R: TRect): boolean;
begin
  if PointInRectInclusive(R, X1, Y1) or PointInRectInclusive(R, X2, Y2) then
    Exit(True);

  Result :=
    SegmentsIntersect(X1, Y1, X2, Y2, R.Left, R.Top, R.Right, R.Top) or
    SegmentsIntersect(X1, Y1, X2, Y2, R.Right, R.Top, R.Right, R.Bottom) or
    SegmentsIntersect(X1, Y1, X2, Y2, R.Right, R.Bottom, R.Left, R.Bottom) or
    SegmentsIntersect(X1, Y1, X2, Y2, R.Left, R.Bottom, R.Left, R.Top);
end;

function NewId: string;
begin
  Result := TGUID.NewGuid.ToString;
end;

function LengthSquared(const V: TPointF): Single; inline;
begin
  Result := V.X * V.X + V.Y * V.Y;
end;

function DistancePointToSegment(const P, A, B: TPointF): Single;
var
  AB, AP: TPointF;
  T: Single;
  Closest: TPointF;
begin
  AB := B - A;
  AP := P - A;

  T := AP.DotProduct(AB) / LengthSquared(AB);

  T := EnsureRange(T, 0, 1);

  Closest := A + AB * T;

  Result := P.Distance(Closest);
end;

function CubicBezierPointF(const P0, P1, P2, P3: TPointF; T: single): TPointF;
var
  U, TT, UU, UUU, TTT: single;
begin
  U := 1 - T;
  TT := T * T;
  UU := U * U;
  UUU := UU * U;
  TTT := TT * T;

  Result.X := UUU * P0.X +
    3 * UU * T * P1.X +
    3 * U * TT * P2.X +
    TTT * P3.X;

  Result.Y := UUU * P0.Y +
    3 * UU * T * P1.Y +
    3 * U * TT * P2.Y +
    TTT * P3.Y;
end;

function LineIntersectsRectF(const P1, P2: TPointF; const R: TRectF): Boolean;
var
  N: TRectF;
  Dx, Dy: Single;
  T0, T1: Single;

  function ClipTest(P, Q: Single; var T0, T1: Single): Boolean; inline;
  var
    Rr: Single;
  begin
    if Abs(P) < 1e-6 then
      Exit(Q >= 0);

    Rr := Q / P;
    if P < 0 then
    begin
      if Rr > T1 then
        Exit(False);
      if Rr > T0 then
        T0 := Rr;
    end
    else
    begin
      if Rr < T0 then
        Exit(False);
      if Rr < T1 then
        T1 := Rr;
    end;
    Result := True;
  end;

begin
  N := R;
  N.NormalizeRect;

  if N.Contains(P1) or N.Contains(P2) then
    Exit(True);

  Dx := P2.X - P1.X;
  Dy := P2.Y - P1.Y;
  T0 := 0.0;
  T1 := 1.0;

  Result :=
    ClipTest(-Dx, P1.X - N.Left, T0, T1) and
    ClipTest(Dx, N.Right - P1.X, T0, T1) and
    ClipTest(-Dy, P1.Y - N.Top, T0, T1) and
    ClipTest(Dy, N.Bottom - P1.Y, T0, T1);
end;

function PointNearPath(const P: TPointF; P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean;
begin
  Result := False;

  var Prev := P0;
  for var k := 1 to 20 do
  begin
    var Cur := CubicBezierPointF(P0, P1, P2, P3, k / 20);
    if DistancePointToSegment(P, Prev, Cur) <= Tolerance then
      Exit(True);
    Prev := Cur;
  end;
end;

function PointNearPathDirect(const P, P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean;
begin
  Result := False;
  if DistancePointToSegment(P, P0, P1) <= Tolerance then
    Exit(True);
  if DistancePointToSegment(P, P1, P2) <= Tolerance then
    Exit(True);
  if DistancePointToSegment(P, P2, P3) <= Tolerance then
    Exit(True);
end;

function CubicBezierPoint(const P0, P1, P2, P3: TPoint; T: Double): TPointF;
var
  it, t2, t3, it2, it3: double;
begin
  it := 1 - T;
  t2 := T * T;
  t3 := t2 * T;
  it2 := it * it;
  it3 := it2 * it;

  Result.X := it3 * P0.X + 3 * it2 * T * P1.X + 3 * it * t2 * P2.X + t3 * P3.X;
  Result.Y := it3 * P0.Y + 3 * it2 * T * P1.Y + 3 * it * t2 * P2.Y + t3 * P3.Y;
end;

procedure DrawCubicBezier(Canvas: TCanvas; const P0, P1, P2, P3: TPoint; Opacity: Single);
var
  t, it, t2, it2, t3, it3, x, y: Double;
begin
  //var Steps := 32;
  var Len := P0.Distance(P1) + P1.Distance(P2) + P2.Distance(P3);

  var Steps := EnsureRange(Round(Len / 20), 10, 64);
  var Bounds := TRectF.Create(0, 0, Canvas.Width, Canvas.Height);
  Bounds.Inflate(100, 100);

  CachePathObject.Clear;

  var Prev := TPointF.Create(P0.X, P0.Y);
  CachePathObject.MoveTo(Prev);
  for var i := 1 to Steps do
  begin
    t := i / Steps;
    it := 1 - t;
    t2 := t * t;
    it2 := it * it;
    t3 := t2 * t;
    it3 := it2 * it;

    x := it3 * P0.X + 3 * it2 * t * P1.X + 3 * it * t2 * P2.X + t3 * P3.X;
    y := it3 * P0.Y + 3 * it2 * t * P1.Y + 3 * it * t2 * P2.Y + t3 * P3.Y;

    var Cur := TPointF.Create(x, y);
    if (not Bounds.Contains(Prev)) and (not Bounds.Contains(Cur)) and (i <> Steps) then
    begin
      Prev := Cur;
      Continue;
    end;

    CachePathObject.LineTo(Cur);
    Prev := Cur;
  end;
  Canvas.DrawPath(CachePathObject, Opacity);
end;

procedure DrawCubicBezier1(C: TCanvas; const P0, P1, P2, P3: TPoint; Opacity: Single);
begin
  CachePathObject.Clear;
  CachePathObject.MoveTo(P0);
  CachePathObject.CurveTo(P1, P2, P3);
  C.DrawPath(CachePathObject, Opacity);
end;

procedure DrawDirectLine(C: TCanvas; const P0, P1, P2, P3: TPoint; Opacity: Single);
begin
  CachePathObject.Clear;
  CachePathObject.MoveTo(P0);
  CachePathObject.LineTo(P1);
  CachePathObject.LineTo(P2);
  CachePathObject.LineTo(P3);
  C.DrawPath(CachePathObject, Opacity);
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

