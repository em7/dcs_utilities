unit AltimeterGauge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Controls, Graphics, LCLType, Math, QnhQfeCalc;

type

  { TAltimeterGauge }

  TAltimeterGauge = class(TGraphicControl)
  private
    FAltitude: Double;        // feet
    FPressureInHg: Double;    // canonical unit; mb derived via InHgToHpa
    procedure SetAltitude(AValue: Double);
    procedure SetPressureInHg(AValue: Double);
    procedure DrawDialFace(ACanvas: TCanvas; const ARect: TRect);
    procedure DrawDialNumbers(ACanvas: TCanvas; const ARect: TRect);
    procedure DrawDialNumbersTwoRing(ACanvas: TCanvas; const ARect: TRect);
    procedure DrawNeedle(ACanvas: TCanvas; const ARect: TRect);
    procedure DrawOneNeedle(ACanvas: TCanvas; const ARect: TRect; ANeedleFraction, ATipRadiusFactor, ATailRadiusFactor: Double);
    procedure DrawDoubleNeedle(ACanvas: TCanvas; const ARect: TRect);
    procedure DrawDrumReadout(ACanvas: TCanvas; const ARect: TRect);
    procedure DrawKollsmanWindow(ACanvas: TCanvas; const ARect: TRect; const AText: string);
    function FitFontToRect(ACanvas: TCanvas; ATargetWidth, ATargetHeight: Integer; const AText: string): TSize;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Altitude: Double read FAltitude write SetAltitude;
    property PressureInHg: Double read FPressureInHg write SetPressureInHg;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

procedure Register;

implementation

constructor TAltimeterGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAltitude := 0;
  FPressureInHg := 29.92;
  Width := 400;
  Height := 200;
end;

procedure TAltimeterGauge.SetAltitude(AValue: Double);
begin
  if SameValue(FAltitude, AValue) then
    Exit;
  FAltitude := AValue;
  Invalidate;
end;

procedure TAltimeterGauge.SetPressureInHg(AValue: Double);
begin
  if SameValue(FPressureInHg, AValue) then
    Exit;
  FPressureInHg := AValue;
  Invalidate;
end;

function TAltimeterGauge.FitFontToRect(ACanvas: TCanvas; ATargetWidth, ATargetHeight: Integer; const AText: string): TSize;
const
  RefFontHeight = -100; // large reference size used to derive a scale ratio from a single measurement
var
  RefSize: TSize;
  Scale: Double;
  NewHeight: Integer;
begin
  Result := Size(0, 0);
  if (ATargetWidth <= 0) or (ATargetHeight <= 0) then
    Exit;

  ACanvas.Font.Height := RefFontHeight;
  RefSize := ACanvas.TextExtent(AText);
  if (RefSize.cx <= 0) or (RefSize.cy <= 0) then
    Exit;

  Scale := Min(ATargetWidth / RefSize.cx, ATargetHeight / RefSize.cy);
  NewHeight := Round(RefFontHeight * Scale);
  if NewHeight >= 0 then
    NewHeight := -1;
  ACanvas.Font.Height := NewHeight;
  Result := ACanvas.TextExtent(AText);

  // single confirming pass: rounding of the ratio estimate can slightly overshoot the target
  if (Result.cx > ATargetWidth) or (Result.cy > ATargetHeight) then
  begin
    // NewHeight = -1 is already the smallest shrinking height; don't cross into >= 0
    if NewHeight + 1 >= 0 then
      Exit;
    ACanvas.Font.Height := NewHeight + 1;
    Result := ACanvas.TextExtent(AText);
  end;
end;

procedure TAltimeterGauge.DrawDialFace(ACanvas: TCanvas; const ARect: TRect);
var
  DialSize, BezelWidth: Integer;
  CenterX, CenterY: Integer;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  DialSize := Min(ARect.Width, ARect.Height);
  BezelWidth := Max(1, DialSize div 40);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;

  ACanvas.Pen.Color := clSilver;
  ACanvas.Pen.Width := BezelWidth;
  ACanvas.Brush.Color := RGBToColor(30, 30, 30);
  ACanvas.Ellipse(CenterX - DialSize div 2, CenterY - DialSize div 2,
                  CenterX + DialSize div 2, CenterY + DialSize div 2);
  ACanvas.Pen.Width := 1;
end;

procedure TAltimeterGauge.DrawDialNumbers(ACanvas: TCanvas; const ARect: TRect);
var
  DialSize: Integer;
  CenterX, CenterY: Integer;
  D: Integer;
  AngleDeg, AngleRad, LabelRadius: Double;
  PX, PY: Integer;
  DigitText: string;
  TextSize: TSize;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  DialSize := Min(ARect.Width, ARect.Height);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;
  LabelRadius := DialSize / 2 * 0.78;

  ACanvas.Font.Name := 'Default';
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := clSilver;
  ACanvas.Font.Height := -Round(DialSize * 0.08);
  ACanvas.Brush.Style := bsClear;

  for D := 0 to 9 do
  begin
    // -90 offset puts D=0 at 12 o'clock; +36 deg/digit sweeps clockwise so D=5 lands at 6 o'clock, D=9 at 11 o'clock
    AngleDeg := -90 + D * 36;
    AngleRad := DegToRad(AngleDeg);
    PX := CenterX + Round(LabelRadius * Cos(AngleRad));
    PY := CenterY + Round(LabelRadius * Sin(AngleRad));
    DigitText := IntToStr(D);
    TextSize := ACanvas.TextExtent(DigitText);
    ACanvas.TextOut(PX - TextSize.cx div 2, PY - TextSize.cy div 2, DigitText);
  end;

  ACanvas.Brush.Style := bsSolid;
end;

procedure TAltimeterGauge.DrawDialNumbersTwoRing(ACanvas: TCanvas; const ARect: TRect);
var
  DialSize: Integer;
  CenterX, CenterY: Integer;
  D: Integer;
  AngleDeg, AngleRad, OuterRadius, InnerRadius: Double;
  PX, PY: Integer;
  DigitText: string;
  TextSize: TSize;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  DialSize := Min(ARect.Width, ARect.Height);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;
  OuterRadius := DialSize / 2 * 0.85;
  // InnerRadius=0.33: south-most digit extent ~0.19*DialSize, clears the meters
  // Kollsman window top (0.38*DialSize) with ~0.19*DialSize margin
  InnerRadius := DialSize / 2 * 0.33;

  ACanvas.Font.Name := 'Default';
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := clSilver;
  ACanvas.Brush.Style := bsClear;

  // outer ring: hundreds-of-meters pointer scale
  ACanvas.Font.Height := -Round(DialSize * 0.08);
  for D := 0 to 9 do
  begin
    AngleDeg := -90 + D * 36;
    AngleRad := DegToRad(AngleDeg);
    PX := CenterX + Round(OuterRadius * Cos(AngleRad));
    PY := CenterY + Round(OuterRadius * Sin(AngleRad));
    DigitText := IntToStr(D);
    TextSize := ACanvas.TextExtent(DigitText);
    ACanvas.TextOut(PX - TextSize.cx div 2, PY - TextSize.cy div 2, DigitText);
  end;

  // inner ring: 20 km per revolution, labeled every 2 km; 20 at top, 10 at bottom
  ACanvas.Font.Height := -Round(DialSize * 0.05);
  for D := 0 to 9 do
  begin
    AngleDeg := -90 + D * 36;
    AngleRad := DegToRad(AngleDeg);
    PX := CenterX + Round(InnerRadius * Cos(AngleRad));
    PY := CenterY + Round(InnerRadius * Sin(AngleRad));
    if D = 0 then
      DigitText := '20'
    else
      DigitText := IntToStr(D * 2);
    TextSize := ACanvas.TextExtent(DigitText);
    ACanvas.TextOut(PX - TextSize.cx div 2, PY - TextSize.cy div 2, DigitText);
  end;

  ACanvas.Brush.Style := bsSolid;
end;

procedure TAltimeterGauge.DrawNeedle(ACanvas: TCanvas; const ARect: TRect);
var
  DialSize: Integer;
  CenterX, CenterY: Integer;
  NeedleFraction: Double;
  NeedleAngleDeg, NeedleAngleRad, TailAngleRad: Double;
  NeedleRadius, TailRadius, PivotRadius: Double;
  TipX, TipY, TailX, TailY: Integer;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  DialSize := Min(ARect.Width, ARect.Height);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;

  NeedleFraction := (Round(FAltitude) mod 1000) / 1000.0;
  if NeedleFraction < 0 then
    NeedleFraction := NeedleFraction + 1.0;
  NeedleAngleDeg := -90 + NeedleFraction * 360;
  NeedleAngleRad := DegToRad(NeedleAngleDeg);
  TailAngleRad := DegToRad(NeedleAngleDeg + 180);

  NeedleRadius := DialSize / 2 * 0.64;
  TailRadius := DialSize / 2 * 0.10;
  PivotRadius := DialSize * 0.03;

  TipX := CenterX + Round(NeedleRadius * Cos(NeedleAngleRad));
  TipY := CenterY + Round(NeedleRadius * Sin(NeedleAngleRad));
  TailX := CenterX + Round(TailRadius * Cos(TailAngleRad));
  TailY := CenterY + Round(TailRadius * Sin(TailAngleRad));

  ACanvas.Pen.Color := clRed;
  ACanvas.Pen.Width := Max(2, DialSize div 60);
  ACanvas.MoveTo(TailX, TailY);
  ACanvas.LineTo(TipX, TipY);
  ACanvas.Pen.Width := 1;

  ACanvas.Pen.Color := clRed;
  ACanvas.Brush.Color := clRed;
  ACanvas.Ellipse(CenterX - Round(PivotRadius), CenterY - Round(PivotRadius),
                  CenterX + Round(PivotRadius), CenterY + Round(PivotRadius));
end;

procedure TAltimeterGauge.DrawOneNeedle(ACanvas: TCanvas; const ARect: TRect; ANeedleFraction, ATipRadiusFactor, ATailRadiusFactor: Double);
var
  DialSize: Integer;
  CenterX, CenterY: Integer;
  NeedleAngleDeg, NeedleAngleRad, TailAngleRad: Double;
  NeedleRadius, TailRadius: Double;
  TipX, TipY, TailX, TailY: Integer;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  DialSize := Min(ARect.Width, ARect.Height);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;

  NeedleAngleDeg := -90 + ANeedleFraction * 360;
  NeedleAngleRad := DegToRad(NeedleAngleDeg);
  TailAngleRad := DegToRad(NeedleAngleDeg + 180);

  NeedleRadius := DialSize / 2 * ATipRadiusFactor;
  TailRadius := DialSize / 2 * ATailRadiusFactor;

  TipX := CenterX + Round(NeedleRadius * Cos(NeedleAngleRad));
  TipY := CenterY + Round(NeedleRadius * Sin(NeedleAngleRad));
  TailX := CenterX + Round(TailRadius * Cos(TailAngleRad));
  TailY := CenterY + Round(TailRadius * Sin(TailAngleRad));

  ACanvas.Pen.Color := clRed;
  ACanvas.Pen.Width := Max(2, DialSize div 60);
  ACanvas.MoveTo(TailX, TailY);
  ACanvas.LineTo(TipX, TipY);
  ACanvas.Pen.Width := 1;
end;

procedure TAltimeterGauge.DrawDoubleNeedle(ACanvas: TCanvas; const ARect: TRect);
var
  DialSize: Integer;
  CenterX, CenterY: Integer;
  MetersAltitude: Double;
  RoundedMeters: Int64;
  LongFraction, ShortFraction: Double;
  PivotRadius: Double;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  DialSize := Min(ARect.Width, ARect.Height);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;

  MetersAltitude := FeetToMeters(FAltitude);
  RoundedMeters := Round(MetersAltitude);

  ShortFraction := (RoundedMeters mod 20000) / 20000.0;
  if ShortFraction < 0 then
    ShortFraction := ShortFraction + 1.0;
  LongFraction := (RoundedMeters mod 1000) / 1000.0;
  if LongFraction < 0 then
    LongFraction := LongFraction + 1.0;

  // Long needle tip factor 0.64 -> max downward extent 0.32*DialSize; Kollsman window
  // top at 0.38*DialSize; margin 0.06*DialSize, absorbs pen stroke width + rounding
  DrawOneNeedle(ACanvas, ARect, ShortFraction, 0.28, 0.06);
  DrawOneNeedle(ACanvas, ARect, LongFraction, 0.64, 0.10);

  PivotRadius := DialSize * 0.03;
  ACanvas.Pen.Color := clRed;
  ACanvas.Brush.Color := clRed;
  ACanvas.Ellipse(CenterX - Round(PivotRadius), CenterY - Round(PivotRadius),
                  CenterX + Round(PivotRadius), CenterY + Round(PivotRadius));
end;

procedure TAltimeterGauge.DrawDrumReadout(ACanvas: TCanvas; const ARect: TRect);
var
  DrumText, LeadingText, TrailingText: string;
  LeadingSize, TrailingSize: TSize;
  DrumWidth, DrumHeight: Integer;
  DrumRect, LeadingRect, TrailingRect: TRect;
  CenterX, CenterY: Integer;
  LeadingWidth: Integer;
  ClampedAltitude: Integer;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  ClampedAltitude := Max(0, Min(99999, Round(RoundTo(FAltitude, 2))));
  DrumText := Format('%.5d', [ClampedAltitude]);
  LeadingText := Copy(DrumText, 1, 2);
  TrailingText := Copy(DrumText, 3, 3);
  CenterX := (ARect.Left + ARect.Right) div 2;
  CenterY := (ARect.Top + ARect.Bottom) div 2;

  DrumWidth := Round(Min(ARect.Width, ARect.Height) * 0.6);
  DrumHeight := Round(Min(ARect.Width, ARect.Height) * 0.16);
  DrumRect := Rect(CenterX - DrumWidth div 2, CenterY - DrumHeight div 2,
                    CenterX + DrumWidth div 2, CenterY + DrumHeight div 2);

  LeadingWidth := Round(DrumRect.Width * 0.42);
  LeadingRect := Rect(DrumRect.Left, DrumRect.Top, DrumRect.Left + LeadingWidth, DrumRect.Bottom);
  TrailingRect := Rect(DrumRect.Left + LeadingWidth, DrumRect.Top, DrumRect.Right, DrumRect.Bottom);

  ACanvas.Font.Name := 'Monospace'; // resolves to Courier New on Windows, DejaVu Sans Mono/similar elsewhere
  ACanvas.Font.Pitch := fpFixed;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := clBlack;

  ACanvas.Pen.Color := clBlack;
  ACanvas.Brush.Color := clLtGray;
  ACanvas.Rectangle(DrumRect);

  ACanvas.Brush.Style := bsClear;

  // leading digits (ten-thousands/thousands) rendered larger than trailing (hundreds/tens/units)
  LeadingSize := FitFontToRect(ACanvas, Round(LeadingRect.Width * 0.85), Round(DrumRect.Height * 0.95), LeadingText);
  if (LeadingSize.cx > 0) and (LeadingSize.cy > 0) then
    ACanvas.TextOut(LeadingRect.Left + (LeadingRect.Width - LeadingSize.cx) div 2,
                    DrumRect.Top + (DrumRect.Height - LeadingSize.cy) div 2, LeadingText);

  TrailingSize := FitFontToRect(ACanvas, Round(TrailingRect.Width * 0.85), Round(DrumRect.Height * 0.65), TrailingText);
  if (TrailingSize.cx > 0) and (TrailingSize.cy > 0) then
    ACanvas.TextOut(TrailingRect.Left + (TrailingRect.Width - TrailingSize.cx) div 2,
                    DrumRect.Top + (DrumRect.Height - TrailingSize.cy) div 2, TrailingText);

  ACanvas.Brush.Style := bsSolid;
end;

procedure TAltimeterGauge.DrawKollsmanWindow(ACanvas: TCanvas; const ARect: TRect; const AText: string);
var
  TextSize: TSize;
  CornerRadius: Integer;
begin
  if (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  CornerRadius := Max(2, ARect.Height div 4);

  ACanvas.Pen.Color := clBlack;
  ACanvas.Brush.Color := clLtGray;
  ACanvas.RoundRect(ARect, CornerRadius, CornerRadius);

  ACanvas.Font.Name := 'Default';
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := clBlack;
  TextSize := FitFontToRect(ACanvas, Round(ARect.Width * 0.8), ARect.Height - 2, AText);

  ACanvas.Brush.Style := bsClear;
  if (TextSize.cx > 0) and (TextSize.cy > 0) then
    ACanvas.TextOut(ARect.Left + (ARect.Width - TextSize.cx) div 2,
                    ARect.Top + (ARect.Height - TextSize.cy) div 2, AText);
  ACanvas.Brush.Style := bsSolid;
end;

procedure TAltimeterGauge.Paint;
var
  FullRect, LeftRect, RightRect: TRect;
  DialSize: Integer;
  CenterX, CenterY: Integer;
  KollsmanWidth, KollsmanHeight: Integer;
  LeftKollsmanRect, RightKollsmanRect, MetersKollsmanRect: TRect;
begin
  inherited Paint;

  FullRect := ClientRect;
  if (FullRect.Width <= 0) or (FullRect.Height <= 0) then
    Exit;

  LeftRect := Rect(FullRect.Left, FullRect.Top,
                    FullRect.Left + (FullRect.Width div 2) - 1, FullRect.Bottom);
  RightRect := Rect(LeftRect.Right + 1, FullRect.Top, FullRect.Right, FullRect.Bottom);

  // left dial: feet, unchanged behavior, just rendered into the left half-rect
  DrawDialFace(Canvas, LeftRect);
  DrawDialNumbers(Canvas, LeftRect);
  DrawNeedle(Canvas, LeftRect);
  DrawDrumReadout(Canvas, LeftRect);

  DialSize := Min(LeftRect.Width, LeftRect.Height);
  CenterX := (LeftRect.Left + LeftRect.Right) div 2;
  CenterY := (LeftRect.Top + LeftRect.Bottom) div 2;

  KollsmanWidth := Round(DialSize * 0.28);
  KollsmanHeight := Round(DialSize * 0.14);

  LeftKollsmanRect := Rect(CenterX - Round(DialSize * 0.36), CenterY + Round(DialSize * 0.18),
                            CenterX - Round(DialSize * 0.36) + KollsmanWidth,
                            CenterY + Round(DialSize * 0.18) + KollsmanHeight);
  DrawKollsmanWindow(Canvas, LeftKollsmanRect, Format('%.0f', [InHgToHpa(FPressureInHg)]));

  RightKollsmanRect := Rect(CenterX + Round(DialSize * 0.08), CenterY + Round(DialSize * 0.18),
                             CenterX + Round(DialSize * 0.08) + KollsmanWidth,
                             CenterY + Round(DialSize * 0.18) + KollsmanHeight);
  DrawKollsmanWindow(Canvas, RightKollsmanRect, Format('%.2f', [FPressureInHg]));

  // right dial: meters
  DrawDialFace(Canvas, RightRect);
  DrawDialNumbersTwoRing(Canvas, RightRect);
  DrawDoubleNeedle(Canvas, RightRect);

  DialSize := Min(RightRect.Width, RightRect.Height);
  CenterX := (RightRect.Left + RightRect.Right) div 2;
  CenterY := (RightRect.Top + RightRect.Bottom) div 2;

  MetersKollsmanRect := Rect(CenterX - KollsmanWidth div 2, CenterY + Round(DialSize * 0.30),
                              CenterX - KollsmanWidth div 2 + KollsmanWidth,
                              CenterY + Round(DialSize * 0.30) + Round(DialSize * 0.10));
  DrawKollsmanWindow(Canvas, MetersKollsmanRect, Format('%.0f', [HpaToMmHg(InHgToHpa(FPressureInHg))]));
end;

procedure Register;
begin
  RegisterComponents('DcsUtils', [TAltimeterGauge]);
end;

initialization
  RegisterClass(TAltimeterGauge); // required so TReader can resolve TAltimeterGauge when main.lfm is streamed

end.
