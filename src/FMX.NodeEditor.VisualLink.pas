unit FMX.NodeEditor.VisualLink;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Types, System.UITypes,
  FMX.Graphics, FMX.NodeEditor.Types;

type
  TLinkVisualObjectClass = class of TLinkVisualObject;

  TLinkVisualObject = class
  protected
    class function DistancePointToSegment(const P, A, B: TPointF): Single; inline; static;
    class function LineIntersectsRectF(const P1, P2: TPointF; const R: TRectF): Boolean; inline; static;
    class function PointNearLine(const P, P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean; inline; static;
  public
    class procedure GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF); virtual; abstract;
    class function IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean; virtual; abstract;
    class function HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean; virtual; abstract;
    class procedure DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single); overload; virtual; abstract;
    class procedure DrawLink(Canvas: TCanvas; const PFrom, PTo: TPointF; Zoom, OffsetX, OffsetY: Double; Opacity: Single); overload; virtual;
  end;

  TLinkVisualBezier = class(TLinkVisualObject)
  private
    class function CubicBezierPoint(const P0, P1, P2, P3: TPointF; T: Single): TPointF; inline; static;
    class function PointNearPath(const P: TPointF; P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean; inline; static;
  public
    class procedure GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF); override;
    class function IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean; override;
    class function HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean; override;
    class procedure DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single); override;
  end;

  TLinkVisualPolyLine = class(TLinkVisualObject)
  public
    class procedure GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF); override;
    class function IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean; override;
    class function HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean; override;
    class procedure DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single); override;
  end;

  TLinkVisualRect = class(TLinkVisualObject)
  public
    class procedure GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF); override;
    class function IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean; override;
    class function HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean; override;
    class procedure DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single); override;
  end;

  TLinkVisualLine = class(TLinkVisualObject)
  public
    class procedure GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF); override;
    class function IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean; override;
    class function HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean; override;
    class procedure DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single); override;
  end;

implementation

uses
  FMX.Types, System.Math.Vectors;

{ TLinkVisualBezier }

class function TLinkVisualBezier.CubicBezierPoint(const P0, P1, P2, P3: TPointF; T: Single): TPointF;
begin
  var U := 1 - T;
  var TT := T * T;
  var UU := U * U;
  var UUU := UU * U;
  var TTT := TT * T;

  Result.X := UUU * P0.X + 3 * UU * T * P1.X + 3 * U * TT * P2.X + TTT * P3.X;
  Result.Y := UUU * P0.Y + 3 * UU * T * P1.Y + 3 * U * TT * P2.Y + TTT * P3.Y;
end;

class procedure TLinkVisualBezier.DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single);
begin
  var Len := P0.Distance(P1) + P1.Distance(P2) + P2.Distance(P3);

  var Steps := EnsureRange(Round(Len / 20), 16, 64);
  var Bounds := TRectF.Create(0, 0, Canvas.Width, Canvas.Height);
  Bounds.Inflate(100, 100);

  CachePathObject.Clear;

  var Prev := TPointF.Create(P0.X, P0.Y);
  CachePathObject.MoveTo(Prev);
  for var i := 1 to Steps do
  begin
    var Cur := CubicBezierPoint(P0, P1, P2, P3, i / Steps);
    if (not Bounds.Contains(Prev)) and (not Bounds.Contains(Cur)) and (i <> Steps) then
    begin
      Prev := Cur;
      Continue;
    end;

    CachePathObject.LineTo(Cur);
    Prev := Cur;
  end;
  Canvas.DrawPath(CachePathObject, Opacity);

  // analogue
  {
  CachePathObject.Clear;
  CachePathObject.MoveTo(P0);
  CachePathObject.CurveTo(P1, P2, P3);
  C.DrawPath(CachePathObject, Opacity);
  }
end;

class procedure TLinkVisualBezier.GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF);
begin
  P0 := PFrom;
  P3 := PTo;

  // Divide by FZoom to keep the visual curve consistent
  //var D := Hypot(P3.X - P0.X, P3.Y - P0.Y);
  //var D := 50;
  var D := EnsureRange(Hypot(P3.X - P0.X, P3.Y - P0.Y) * 0.35, 0, 150 / Zoom);
  //var D := Max(Hypot(P3.X - P0.X, P3.Y - P0.Y) * 0.35, 0);

  P1 := P0;
  P1.X := P1.X + D;

  P2 := P3;
  P2.X := P2.X - D;
end;

class function TLinkVisualBezier.PointNearPath(const P: TPointF; P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean;
begin
  Result := False;

  var Prev := P0;
  var Len := P0.Distance(P1) + P1.Distance(P2) + P2.Distance(P3);

  var Steps := EnsureRange(Round(Len / 20), 16, 64);
  for var k := 1 to Steps do
  begin
    var Cur := CubicBezierPoint(P0, P1, P2, P3, k / Steps);
    if DistancePointToSegment(P, Prev, Cur) <= Tolerance then
      Exit(True);
    Prev := Cur;
  end;
end;

class function TLinkVisualBezier.HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
begin
  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);

  var M := ScreenToWorld(AX, AY, Zoom, OffsetX, OffsetY);
  var TolWorld := Max(4 / Zoom, 8 / Zoom);
 { var MinX := Min(Min(P0.X, P1.X), Min(P2.X, P3.X)) - TolWorld;
  var MaxX := Max(Max(P0.X, P1.X), Max(P2.X, P3.X)) + TolWorld;
  var MinY := Min(Min(P0.Y, P1.Y), Min(P2.Y, P3.Y)) - TolWorld;
  var MaxY := Max(Max(P0.Y, P1.Y), Max(P2.Y, P3.Y)) + TolWorld;

  if (M.X < MinX) or (M.X > MaxX) or (M.Y < MinY) or (M.Y > MaxY) then
    Exit(False);   }

  Result := PointNearPath(M, P0, P1, P2, P3, TolWorld);
end;

class function TLinkVisualBezier.IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean;
begin
  Result := False;
  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);
        {
  if not BR.IntersectsWith(R) then
    Exit(False);   }

  if R.Contains(P0) or R.Contains(P3) then
    Exit(True);

  var Prev := P0;
  var Len := P0.Distance(P1) + P1.Distance(P2) + P2.Distance(P3);

  var Steps := EnsureRange(Round(Len / 20), 16, 64);
  for var k := 1 to Steps do
  begin
    var Cur := CubicBezierPoint(P0, P1, P2, P3, k / Steps);

    if R.Contains(Cur) then
      Exit(True);

    if LineIntersectsRectF(Prev, Cur, R) then
      Exit(True);

    Prev := Cur;
  end;
end;

{ TLinkVisualDirect }

class procedure TLinkVisualPolyLine.DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single);
begin
  CachePathObject.Clear;
  CachePathObject.MoveTo(P0);
  CachePathObject.LineTo(P1);
  CachePathObject.LineTo(P2);
  CachePathObject.LineTo(P3);
  Canvas.DrawPath(CachePathObject, Opacity);
end;

class procedure TLinkVisualPolyLine.GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF);
begin
  P0 := PFrom;
  P3 := PTo;
  var D: Single := 15;

  P1 := P0;
  P1.X := P1.X + D;

  P2 := P3;
  P2.X := P2.X - D;
end;

class function TLinkVisualPolyLine.HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
begin
  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);

  var M := ScreenToWorld(AX, AY, Zoom, OffsetX, OffsetY);
  var TolWorld := Max(4 / Zoom, 8 / Zoom);
  var MinX := Min(Min(P0.X, P1.X), Min(P2.X, P3.X)) - TolWorld;
  var MaxX := Max(Max(P0.X, P1.X), Max(P2.X, P3.X)) + TolWorld;
  var MinY := Min(Min(P0.Y, P1.Y), Min(P2.Y, P3.Y)) - TolWorld;
  var MaxY := Max(Max(P0.Y, P1.Y), Max(P2.Y, P3.Y)) + TolWorld;

  if (M.X < MinX) or (M.X > MaxX) or (M.Y < MinY) or (M.Y > MaxY) then
    Exit(False);

  Result := PointNearLine(M, P0, P1, P2, P3, TolWorld);
end;

class function TLinkVisualPolyLine.IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean;
begin
  Result := False;

  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);
              {
  if not BR.IntersectsWith(R) then
    Exit(False);   }

  if R.Contains(P0) or R.Contains(P3) then
    Exit(True);

  if R.Contains(P1) or R.Contains(P2) then
    Exit(True);
  if LineIntersectsRectF(P0, P1, R) then
    Exit(True);
  if LineIntersectsRectF(P1, P2, R) then
    Exit(True);
  if LineIntersectsRectF(P2, P3, R) then
    Exit(True);
end;

{ TLinkVisualRect }

class procedure TLinkVisualRect.DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single);
begin
  CachePathObject.Clear;
  CachePathObject.MoveTo(P0);
  CachePathObject.LineTo(P1);
  CachePathObject.LineTo(P2);
  CachePathObject.LineTo(P3);
  Canvas.DrawPath(CachePathObject, Opacity);
end;

class procedure TLinkVisualRect.GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF);
begin
  P0 := PFrom;
  P3 := PTo;
  var D: Single := (P3.X - P0.X) / 2;

  P1 := P0;
  P1.X := P1.X + D;

  P2 := P3;
  P2.X := P2.X - D;
end;

class function TLinkVisualRect.HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
begin
  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(Zoom, PFrom, PTo, P0, P1, P2, P3);

  var M := ScreenToWorld(AX, AY, Zoom, OffsetX, OffsetY);
  var TolWorld := Max(4 / Zoom, 8 / Zoom);
  var MinX := Min(Min(P0.X, P1.X), Min(P2.X, P3.X)) - TolWorld;
  var MaxX := Max(Max(P0.X, P1.X), Max(P2.X, P3.X)) + TolWorld;
  var MinY := Min(Min(P0.Y, P1.Y), Min(P2.Y, P3.Y)) - TolWorld;
  var MaxY := Max(Max(P0.Y, P1.Y), Max(P2.Y, P3.Y)) + TolWorld;

  if (M.X < MinX) or (M.X > MaxX) or (M.Y < MinY) or (M.Y > MaxY) then
    Exit(False);

  Result := PointNearLine(M, P0, P1, P2, P3, TolWorld);
end;

class function TLinkVisualRect.IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean;
begin
  Result := False;

  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);
              {
  if not BR.IntersectsWith(R) then
    Exit(False);   }

  if R.Contains(P0) or R.Contains(P3) then
    Exit(True);

  if R.Contains(P1) or R.Contains(P2) then
    Exit(True);
  if LineIntersectsRectF(P0, P1, R) then
    Exit(True);
  if LineIntersectsRectF(P1, P2, R) then
    Exit(True);
  if LineIntersectsRectF(P2, P3, R) then
    Exit(True);
end;

{ TLinkVisualObject }

class function TLinkVisualObject.DistancePointToSegment(const P, A, B: TPointF): Single;

  function LengthSquared(const V: TPointF): Single; inline;
  begin
    Result := V.X * V.X + V.Y * V.Y;
  end;

begin
  var AB := B - A;
  var LenSq := LengthSquared(AB);

  if SameValue(LenSq, 0) then
    Exit(P.Distance(A));

  var AP := P - A;

  Result := P.Distance(A + AB * EnsureRange(AP.DotProduct(AB) / LenSq, 0, 1));
end;

class procedure TLinkVisualObject.DrawLink(Canvas: TCanvas; const PFrom, PTo: TPointF; Zoom, OffsetX, OffsetY: Double; Opacity: Single);
begin
  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);

  var W0 := WorldToScreen(P0.X, P0.Y, Zoom, OffsetX, OffsetY);
  var W1 := WorldToScreen(P1.X, P1.Y, Zoom, OffsetX, OffsetY);
  var W2 := WorldToScreen(P2.X, P2.Y, Zoom, OffsetX, OffsetY);
  var W3 := WorldToScreen(P3.X, P3.Y, Zoom, OffsetX, OffsetY);

  DrawLink(Canvas, W0, W1, W2, W3, Opacity);
end;

class function TLinkVisualObject.PointNearLine(const P, P0, P1, P2, P3: TPointF; Tolerance: Single): Boolean;
begin
  Result := False;
  if DistancePointToSegment(P, P0, P1) <= Tolerance then
    Exit(True);
  if DistancePointToSegment(P, P1, P2) <= Tolerance then
    Exit(True);
  if DistancePointToSegment(P, P2, P3) <= Tolerance then
    Exit(True);
end;

class function TLinkVisualObject.LineIntersectsRectF(const P1, P2: TPointF; const R: TRectF): Boolean;
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

{ TLinkVisualLine }

class procedure TLinkVisualLine.DrawLink(Canvas: TCanvas; const P0, P1, P2, P3: TPointF; Opacity: Single);
begin
  Canvas.DrawLine(P0, P3, Opacity);
end;

class procedure TLinkVisualLine.GetLinkWorldPoints(Zoom: Double; const PFrom, PTo: TPointF; out P0, P1, P2, P3: TPointF);
begin
  P0 := PFrom;
  P3 := PTo;
  P1 := P0;
  P2 := P3;
end;

class function TLinkVisualLine.HitTestLink(const PFrom, PTo: TPointF; AX, AY: Single; Zoom, OffsetX, OffsetY: Double): Boolean;
begin
  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(Zoom, PFrom, PTo, P0, P1, P2, P3);

  var M := ScreenToWorld(AX, AY, Zoom, OffsetX, OffsetY);
  var TolWorld := Max(4 / Zoom, 8 / Zoom);
  var MinX := Min(P0.X, P3.X) - TolWorld;
  var MaxX := Max(P0.X, P3.X) + TolWorld;
  var MinY := Min(P0.Y, P3.Y) - TolWorld;
  var MaxY := Max(P0.Y, P3.Y) + TolWorld;

  if (M.X < MinX) or (M.X > MaxX) or (M.Y < MinY) or (M.Y > MaxY) then
    Exit(False);

  Result := PointNearLine(M, P0, P1, P2, P3, TolWorld);
end;

class function TLinkVisualLine.IsLinkInsideRect(const R: TRectF; Zoom: Single; PFrom, PTo: TPointF): Boolean;
begin
  Result := False;

  var P0, P1, P2, P3: TPointF;
  GetLinkWorldPoints(1, PFrom, PTo, P0, P1, P2, P3);
              {
  if not BR.IntersectsWith(R) then
    Exit(False);   }

  if R.Contains(P0) or R.Contains(P3) then
    Exit(True);

  if LineIntersectsRectF(P0, P3, R) then
    Exit(True);
end;

end.

