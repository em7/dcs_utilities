unit AirspeedGauge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Controls, Graphics, Math, AirspeedCalc;

type
  { TAirspeedGauge }

  TAirspeedGauge = class(TGraphicControl)
  private
    FAirspeedKnots: Double;
    procedure SetAirspeedKnots(AValue: Double);
    procedure DrawDial(ACanvas: TCanvas; const ARect: TRect; AMetric: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AirspeedKnots: Double read FAirspeedKnots write SetAirspeedKnots;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

procedure Register;

implementation

constructor TAirspeedGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 400;
  Height := 200;
  FAirspeedKnots := 0;
end;

procedure TAirspeedGauge.SetAirspeedKnots(AValue: Double);
begin
  AValue := ClampAirspeedKnots(AValue);
  if FAirspeedKnots = AValue then
    Exit;
  FAirspeedKnots := AValue;
  Invalidate;
end;

procedure TAirspeedGauge.DrawDial(ACanvas: TCanvas; const ARect: TRect;
  AMetric: Boolean);
var
  DialSize, CenterX, CenterY, D, PivotRadius: Integer;
  Radius, Fraction: Double;

  function DialPoint(AFraction, ARadius: Double): TPoint;
  var
    A: Double;
  begin
    A := -Pi / 2 + AFraction * 2 * Pi;
    Result := Point(CenterX + Round(Radius * ARadius * Cos(A)),
      CenterY + Round(Radius * ARadius * Sin(A)));
  end;

  procedure Tick(AFraction, AInnerRadius, AOuterRadius: Double; AWidth: Integer);
  var
    P1, P2: TPoint;
  begin
    P1 := DialPoint(AFraction, AInnerRadius);
    P2 := DialPoint(AFraction, AOuterRadius);
    ACanvas.Pen.Width := AWidth;
    ACanvas.MoveTo(P1.X, P1.Y);
    ACanvas.LineTo(P2.X, P2.Y);
  end;

  procedure LabelAt(AFraction, ARadius: Double; const AText: string);
  var
    P: TPoint;
    S: TSize;
  begin
    P := DialPoint(AFraction, ARadius);
    S := ACanvas.TextExtent(AText);
    ACanvas.TextOut(P.X - S.cx div 2, P.Y - S.cy div 2, AText);
  end;

begin
  DialSize := Min(ARect.Width, ARect.Height) - 4;
  if DialSize < 8 then
    Exit;
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;
  Radius := DialSize / 2;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := RGBToColor(30, 30, 30);
  ACanvas.Pen.Color := clSilver;
  ACanvas.Pen.Width := Max(1, DialSize div 40);
  ACanvas.Ellipse(CenterX - DialSize div 2, CenterY - DialSize div 2,
    CenterX + DialSize div 2, CenterY + DialSize div 2);
  ACanvas.Font.Name := 'Default';
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := clSilver;
  ACanvas.Brush.Style := bsClear;
  if AMetric then
  begin
    ACanvas.Font.Height := -Max(1, Round(DialSize * 0.062));
    for D := 1 to 16 do
    begin
      Fraction := KmhDialFraction(D * 100);
      Tick(Fraction, 0.86, 0.94, Max(1, DialSize div 100));
      LabelAt(Fraction, 0.74, IntToStr(D));
    end;
    Tick(1, 0.86, 0.94, Max(1, DialSize div 100));
    // Endpoint label is moved inward to clear the nearby 1600 label.
    LabelAt(1, 0.59, '16.7');
    ACanvas.Font.Height := -Max(1, Round(DialSize * 0.055));
    LabelAt(0.5, 0.35, 'km/h x100');
    Fraction := KmhDialFraction(KnotsToKmh(FAirspeedKnots));
  end
  else
  begin
    ACanvas.Font.Height := -Max(1, Round(DialSize * 0.08));
    for D := 1 to 18 do
    begin
      Fraction := KnotsDialFraction(D * 50);
      if D mod 2 = 0 then
      begin
        Tick(Fraction, 0.86, 0.94, Max(1, DialSize div 100));
        LabelAt(Fraction, 0.74, IntToStr(D div 2));
      end
      else
        Tick(Fraction, 0.90, 0.94, 1);
    end;
    ACanvas.Font.Height := -Max(1, Round(DialSize * 0.055));
    for D := 1 to 20 do
    begin
      Fraction := KnotsDialFraction(MphToKnots(D * 50));
      if D mod 2 = 0 then
      begin
        Tick(Fraction, 0.52, 0.59, 1);
        LabelAt(Fraction, 0.43, IntToStr(D div 2));
      end
      else
        Tick(Fraction, 0.55, 0.59, 1);
    end;
    ACanvas.Font.Height := -Max(1, Round(DialSize * 0.045));
    LabelAt(0.5, 0.18, 'knots / mph');
    LabelAt(0.5, 0.29, 'x100');
    Fraction := KnotsDialFraction(FAirspeedKnots);
  end;
  ACanvas.Pen.Color := clRed;
  Tick(Fraction, -0.10, 0.84, Max(2, DialSize div 60));
  ACanvas.Pen.Width := 1;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := clRed;
  PivotRadius := Max(1, Round(DialSize * 0.025));
  ACanvas.Ellipse(CenterX - PivotRadius, CenterY - PivotRadius,
    CenterX + PivotRadius, CenterY + PivotRadius);
end;

procedure TAirspeedGauge.Paint;
var
  Middle: Integer;
begin
  inherited Paint;
  Middle := ClientWidth div 2;
  DrawDial(Canvas, Rect(0, 0, Middle, ClientHeight), False);
  DrawDial(Canvas, Rect(Middle, 0, ClientWidth, ClientHeight), True);
end;

procedure Register;
begin
  RegisterComponents('DcsUtils', [TAirspeedGauge]);
end;

initialization
  RegisterClass(TAirspeedGauge);

end.

