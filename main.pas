unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Spin,
  StdCtrls, ExtCtrls, Math, AltimeterGauge, QnhQfeCalc, AirspeedGauge,
  AirspeedCalc, GroundAttackCalc, Types;

type

  { TMainForm }

  TMainForm = class(TForm)
    AirfieldElevationLabel: TLabel;
    AirfieldElevationSpinEdit: TSpinEdit;
    Airspeed: TTabSheet;
    AirspeedGaugeCtrl: TAirspeedGauge;
    AirspeedKnotsLabel: TLabel;
    AirspeedMphLabel: TLabel;
    AirspeedKmhLabel: TLabel;
    AirspeedKnotsSpinEdit: TSpinEdit;
    AirspeedMphSpinEdit: TSpinEdit;
    AirspeedKmhSpinEdit: TSpinEdit;
    Altimeter: TTabSheet;
    AltimeterGaugeCtrl: TAltimeterGauge;
    AltitudeLabel: TLabel;
    AltitudeSpinEdit: TSpinEdit;
    AltitudeMLabel: TLabel;
    PressureMmLabel: TLabel;
    MainPageCtrl: TPageControl;
    PressureInLabel: TLabel;
    PressureHpaLabel: TLabel;
    PressureInSpinEdit: TFloatSpinEdit;
    QfeAltimeterGauge: TAltimeterGauge;
    QfePressureLabel: TLabel;
    QfePressureSpinEdit: TSpinEdit;
    QnhQfe: TTabSheet;
    QnhAltimeterGauge: TAltimeterGauge;
    QnhPressureLabel: TLabel;
    QnhPressureSpinEdit: TSpinEdit;
    PressureHpaSpinEdit: TSpinEdit;
    AltitudeMSpinEdit: TSpinEdit;
    PressureMmSpinEdit: TSpinEdit;
    QnhPressureInHgLabel: TLabel;
    QnhPressureInHgSpinEdit: TFloatSpinEdit;
    QnhPressureMmHgLabel: TLabel;
    QnhPressureMmHgSpinEdit: TSpinEdit;
    QfePressureInHgLabel: TLabel;
    QfePressureInHgSpinEdit: TFloatSpinEdit;
    QfePressureMmHgLabel: TLabel;
    QfePressureMmHgSpinEdit: TSpinEdit;
    AirfieldElevationMLabel: TLabel;
    AirfieldElevationMSpinEdit: TSpinEdit;
    AttackDirectionLabel: TLabel;
    AttackDirectionSpinEdit: TSpinEdit;
    AttackProfileComboBox: TComboBox;
    AttackProfileLabel: TLabel;
    DiveInitiationResultLabel: TLabel;
    DiveInitiationSpeedResultLabel: TLabel;
    GroundAttack: TTabSheet;
    GroundAttackAircraftLabel: TLabel;
    GroundAttackInputsGroupBox: TGroupBox;
    GroundAttackPatternPaintBox: TPaintBox;
    GroundAttackSummaryGroupBox: TGroupBox;
    PatternAltitudeResultLabel: TLabel;
    PatternComboBox: TComboBox;
    PatternLabel: TLabel;
    ReleaseResultLabel: TLabel;
    ReleaseSpeedResultLabel: TLabel;
    ReticleResultLabel: TLabel;
    TargetMslAltitudeLabel: TLabel;
    TargetMslAltitudeSpinEdit: TSpinEdit;

    procedure AirfieldElevationSpinEditChange(Sender: TObject);
    procedure AltitudeMSpinEditChange(Sender: TObject);
    procedure AirspeedSpinEditChange(Sender: TObject);
    procedure AltitudeSpinEditChange(Sender: TObject);
    procedure MainPageCtrlChange(Sender: TObject);
    procedure PressureHpaSpinEditChange(Sender: TObject);
    procedure PressureInSpinEditChange(Sender: TObject);
    procedure PressureMmSpinEditChange(Sender: TObject);
    procedure QfePressureSpinEditChange(Sender: TObject);
    procedure QnhPressureSpinEditChange(Sender: TObject);
    procedure QnhPressureInHgSpinEditChange(Sender: TObject);
    procedure QnhPressureMmHgSpinEditChange(Sender: TObject);
    procedure QfePressureInHgSpinEditChange(Sender: TObject);
    procedure QfePressureMmHgSpinEditChange(Sender: TObject);
    procedure AirfieldElevationMSpinEditChange(Sender: TObject);
    procedure GroundAttackInputsChange(Sender: TObject);
    procedure GroundAttackPatternPaintBoxPaint(Sender: TObject);
    procedure QnhQfeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);

  private
    // Stops updating UI to distinguish between update made by user
    // and auto-updates from the code.
    StopUiUpdate: boolean;

    // Ground attack profile for dive bombing calculations.
    GroundAttackProfile: TDiveBombingProfile;

    // Array of headings for ground attack inputs.
    GroundAttackHeadings: THeadingArray;

    // Altitude in meters for ground attack pattern calculation.
    GroundAttackPatternAltitude: Integer;
    
    procedure DrawArrow(ACanvas: TCanvas; const AFrom, ATo: TPoint);
    //Updates the altimeter pressure controls in hPa, inHg, and mmHg and applies
    // the pressure to the altimeter gauge.
    procedure UpdatePressureControls(APressureHpa: double);
    // Updates the QNH and QFE controls in hPa, inHg, and mmHg and configures their
    //altimeter gauges for airfield elevation and zero elevation respectively.
    procedure UpdateQnhQfeControls(AQnhHpa, AQfeHpa: double);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StopUiUpdate := False;
  QnhPressureSpinEditChange(QnhPressureSpinEdit);
  AttackProfileComboBox.ItemIndex := 0;
  PatternComboBox.ItemIndex := 0;
  GroundAttackInputsChange(nil);
end;

procedure TMainForm.GroundAttackInputsChange(Sender: TObject);
var
  ProfileId: TDiveBombingProfileId;
  TurnDirection: TSquareTurnDirection;
  ReleaseMsl: Integer;
begin
  if (csLoading in ComponentState) or (AttackProfileComboBox.ItemIndex < 0) or
    (PatternComboBox.ItemIndex < 0) then
    Exit;

  if AttackProfileComboBox.ItemIndex = 0 then
    ProfileId := dbp20Degree
  else
    ProfileId := dbp30Degree;
  if PatternComboBox.ItemIndex = 0 then
    TurnDirection := stdLeft
  else
    TurnDirection := stdRight;

  GroundAttackProfile := GetDiveBombingProfile(ProfileId);
  GroundAttackPatternAltitude := CalculateMslAltitude(
    TargetMslAltitudeSpinEdit.Value,
    GroundAttackProfile.DiveInitiationAglFeet);
  ReleaseMsl := CalculateMslAltitude(TargetMslAltitudeSpinEdit.Value,
    GroundAttackProfile.ReleaseAglFeet);
  GroundAttackHeadings := CalculateSquareHeadings(AttackDirectionSpinEdit.Value,
    TurnDirection);

  DiveInitiationResultLabel.Caption := Format(
    'Dive initiation: %d ft MSL (%d ft AGL)',
    [GroundAttackPatternAltitude, GroundAttackProfile.DiveInitiationAglFeet]);
  DiveInitiationSpeedResultLabel.Caption := Format(
    'Dive initiation speed: %d knots',
    [GroundAttackProfile.DiveInitiationSpeedKnots]);
  ReleaseResultLabel.Caption := Format('Release: %d ft MSL (%d ft AGL)',
    [ReleaseMsl, GroundAttackProfile.ReleaseAglFeet]);
  ReleaseSpeedResultLabel.Caption := Format('Release speed: %d to %d knots',
    [GroundAttackProfile.ReleaseSpeedMinKnots,
    GroundAttackProfile.ReleaseSpeedMaxKnots]);
  ReticleResultLabel.Caption := Format('Reticle depression: %d mils',
    [GroundAttackProfile.ReticleDepressionMils]);
  PatternAltitudeResultLabel.Caption := Format('Pattern altitude: %d ft MSL',
    [GroundAttackPatternAltitude]);
  GroundAttackPatternPaintBox.Invalidate;
end;

procedure TMainForm.DrawArrow(ACanvas: TCanvas; const AFrom, ATo: TPoint);
const
  ArrowLength = 10;
  ArrowAngle = Pi / 7;
var
  DirectionAngle: Double;
  ArrowHead: array[0..2] of TPoint;
begin
  ACanvas.Line(AFrom, ATo);
  DirectionAngle := ArcTan2(ATo.Y - AFrom.Y, ATo.X - AFrom.X);
  ArrowHead[0] := ATo;
  ArrowHead[1] := Point(
    ATo.X - Round(ArrowLength * Cos(DirectionAngle - ArrowAngle)),
    ATo.Y - Round(ArrowLength * Sin(DirectionAngle - ArrowAngle)));
  ArrowHead[2] := Point(
    ATo.X - Round(ArrowLength * Cos(DirectionAngle + ArrowAngle)),
    ATo.Y - Round(ArrowLength * Sin(DirectionAngle + ArrowAngle)));
  ACanvas.Polygon(ArrowHead);
end;

procedure TMainForm.GroundAttackPatternPaintBoxPaint(Sender: TObject);
var
  PaintCanvas: TCanvas;
  Center: TPoint;
  LocalPoints: array[0..3] of TPoint;
  Points: array[0..3] of TPoint;
  EntryPoints: array[0..3] of TPoint;
  ExitPoints: array[0..3] of TPoint;
  Index: Integer;
  NextIndex: Integer;
  PreviousIndex: Integer;
  HalfSize: Integer;
  CornerRadius: Integer;
  CurveStep: Integer;
  CurveSteps: Integer;
  CurveT: Double;
  CurvePoint: TPoint;
  EdgeLength: Double;
  Rotation: Double;
  LocalX, LocalY: Integer;
  MidPoint: TPoint;
  HeadingText: string;
  TargetPoint: TPoint;
begin
  PaintCanvas := GroundAttackPatternPaintBox.Canvas;
  PaintCanvas.Brush.Style := bsSolid;
  PaintCanvas.Brush.Color := clWindow;
  PaintCanvas.FillRect(GroundAttackPatternPaintBox.ClientRect);
  PaintCanvas.Font.Color := clWindowText;
  PaintCanvas.TextOut(8, 6, Format('Square pattern at %d ft MSL',
    [GroundAttackPatternAltitude]));
  if PatternComboBox.ItemIndex = 0 then
    PaintCanvas.TextOut(8, 24, '90 degree left turns')
  else
    PaintCanvas.TextOut(8, 24, '90 degree right turns');

  HalfSize := Min(GroundAttackPatternPaintBox.Width,
    GroundAttackPatternPaintBox.Height - 45) div 3;
  if HalfSize < 30 then
    Exit;
  Center := Point(GroundAttackPatternPaintBox.Width div 2,
    45 + (GroundAttackPatternPaintBox.Height - 45) div 2);
  if PatternComboBox.ItemIndex = 0 then
  begin
    LocalPoints[0] := Point(HalfSize, HalfSize);
    LocalPoints[1] := Point(HalfSize, -HalfSize);
    LocalPoints[2] := Point(-HalfSize, -HalfSize);
    LocalPoints[3] := Point(-HalfSize, HalfSize);
  end
  else
  begin
    LocalPoints[0] := Point(-HalfSize, HalfSize);
    LocalPoints[1] := Point(-HalfSize, -HalfSize);
    LocalPoints[2] := Point(HalfSize, -HalfSize);
    LocalPoints[3] := Point(HalfSize, HalfSize);
  end;
  Rotation := DegToRad(GroundAttackHeadings[0]);
  for Index := Low(Points) to High(Points) do
  begin
    LocalX := LocalPoints[Index].X;
    LocalY := LocalPoints[Index].Y;
    Points[Index] := Point(
      Center.X + Round(LocalX * Cos(Rotation) - LocalY * Sin(Rotation)),
      Center.Y + Round(LocalX * Sin(Rotation) + LocalY * Cos(Rotation)));
  end;

  CornerRadius := Max(8, HalfSize div 5);
  CurveSteps := 6;
  for Index := 0 to 3 do
  begin
    PreviousIndex := (Index + 3) mod 4;
    NextIndex := (Index + 1) mod 4;
    EdgeLength := Sqrt(Sqr(Points[Index].X - Points[PreviousIndex].X) +
      Sqr(Points[Index].Y - Points[PreviousIndex].Y));
    EntryPoints[Index] := Point(
      Points[Index].X + Round((Points[PreviousIndex].X - Points[Index].X) *
        CornerRadius / EdgeLength),
      Points[Index].Y + Round((Points[PreviousIndex].Y - Points[Index].Y) *
        CornerRadius / EdgeLength));
    EdgeLength := Sqrt(Sqr(Points[NextIndex].X - Points[Index].X) +
      Sqr(Points[NextIndex].Y - Points[Index].Y));
    ExitPoints[Index] := Point(
      Points[Index].X + Round((Points[NextIndex].X - Points[Index].X) *
        CornerRadius / EdgeLength),
      Points[Index].Y + Round((Points[NextIndex].Y - Points[Index].Y) *
        CornerRadius / EdgeLength));
  end;

  PaintCanvas.Pen.Width := 2;
  PaintCanvas.Pen.Color := clHighlight;
  PaintCanvas.Brush.Color := clHighlight;
  for Index := 0 to 3 do
  begin
    NextIndex := (Index + 1) mod 4;
    DrawArrow(PaintCanvas, ExitPoints[Index], EntryPoints[NextIndex]);
  end;

  for Index := 0 to 3 do
  begin
    PaintCanvas.MoveTo(EntryPoints[Index].X, EntryPoints[Index].Y);
    for CurveStep := 1 to CurveSteps do
    begin
      CurveT := CurveStep / CurveSteps;
      CurvePoint := Point(
        Round(Sqr(1 - CurveT) * EntryPoints[Index].X +
          2 * (1 - CurveT) * CurveT * Points[Index].X +
          Sqr(CurveT) * ExitPoints[Index].X),
        Round(Sqr(1 - CurveT) * EntryPoints[Index].Y +
          2 * (1 - CurveT) * CurveT * Points[Index].Y +
          Sqr(CurveT) * ExitPoints[Index].Y));
      PaintCanvas.LineTo(CurvePoint.X, CurvePoint.Y);
    end;
  end;

  PaintCanvas.Brush.Style := bsClear;
  for Index := 0 to 3 do
  begin
    NextIndex := (Index + 1) mod 4;
    MidPoint := Point((ExitPoints[Index].X + EntryPoints[NextIndex].X) div 2,
      (ExitPoints[Index].Y + EntryPoints[NextIndex].Y) div 2);
    HeadingText := Format('Leg %d: %.3d° at %d ft MSL',
      [Index + 1, GroundAttackHeadings[Index], GroundAttackPatternAltitude]);
    PaintCanvas.TextOut(MidPoint.X - PaintCanvas.TextWidth(HeadingText) div 2,
      MidPoint.Y - PaintCanvas.TextHeight(HeadingText) - 3, HeadingText);
  end;

  TargetPoint := EntryPoints[1];
  EdgeLength := Sqrt(Sqr(EntryPoints[1].X - ExitPoints[0].X) +
    Sqr(EntryPoints[1].Y - ExitPoints[0].Y));
  if EdgeLength > 0 then
  begin
    TargetPoint.X := EntryPoints[1].X -
      Round(12 * (EntryPoints[1].X - ExitPoints[0].X) / EdgeLength);
    TargetPoint.Y := EntryPoints[1].Y -
      Round(12 * (EntryPoints[1].Y - ExitPoints[0].Y) / EdgeLength);
  end;
  PaintCanvas.Pen.Color := clRed;
  PaintCanvas.Pen.Width := 2;
  PaintCanvas.Line(TargetPoint.X - 7, TargetPoint.Y - 7,
    TargetPoint.X + 7, TargetPoint.Y + 7);
  PaintCanvas.Line(TargetPoint.X - 7, TargetPoint.Y + 7,
    TargetPoint.X + 7, TargetPoint.Y - 7);
  PaintCanvas.Font.Color := clRed;
  PaintCanvas.TextOut(TargetPoint.X + 9, TargetPoint.Y - 7,
    'Target / attack pass');
end;

procedure TMainForm.AirfieldElevationSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  StopUiUpdate := True;
  try
    AirfieldElevationMSpinEdit.Value := FeetToMeters(AirfieldElevationSpinEdit.Value);
    UpdateQnhQfeControls(QnhPressureSpinEdit.Value,
      QnhToQfe(QnhPressureSpinEdit.Value, AirfieldElevationSpinEdit.Value));
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.QfePressureSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  StopUiUpdate := True;
  try
    UpdateQnhQfeControls(QfeToQnh(QfePressureSpinEdit.Value,
      AirfieldElevationSpinEdit.Value), QfePressureSpinEdit.Value);
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.QnhPressureSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  StopUiUpdate := True;
  try
    UpdateQnhQfeControls(QnhPressureSpinEdit.Value,
      QnhToQfe(QnhPressureSpinEdit.Value, AirfieldElevationSpinEdit.Value));
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.QnhPressureInHgSpinEditChange(Sender: TObject);
var
  QnhHpa: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  QnhHpa := InHgToHpa(QnhPressureInHgSpinEdit.Value);
  StopUiUpdate := True;
  try
    UpdateQnhQfeControls(QnhHpa,
      QnhToQfe(QnhHpa, AirfieldElevationSpinEdit.Value));
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.QnhPressureMmHgSpinEditChange(Sender: TObject);
var
  QnhHpa: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  QnhHpa := MmHgToHpa(QnhPressureMmHgSpinEdit.Value);
  StopUiUpdate := True;
  try
    UpdateQnhQfeControls(QnhHpa,
      QnhToQfe(QnhHpa, AirfieldElevationSpinEdit.Value));
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.QfePressureInHgSpinEditChange(Sender: TObject);
var
  QfeHpa: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  QfeHpa := InHgToHpa(QfePressureInHgSpinEdit.Value);
  StopUiUpdate := True;
  try
    UpdateQnhQfeControls(QfeToQnh(QfeHpa, AirfieldElevationSpinEdit.Value),
      QfeHpa);
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.QfePressureMmHgSpinEditChange(Sender: TObject);
var
  QfeHpa: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  QfeHpa := MmHgToHpa(QfePressureMmHgSpinEdit.Value);
  StopUiUpdate := True;
  try
    UpdateQnhQfeControls(QfeToQnh(QfeHpa, AirfieldElevationSpinEdit.Value),
      QfeHpa);
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.AirfieldElevationMSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  StopUiUpdate := True;
  try
    AirfieldElevationSpinEdit.Value := MetersToFeet(AirfieldElevationMSpinEdit.Value);
    UpdateQnhQfeControls(QnhPressureSpinEdit.Value,
      QnhToQfe(QnhPressureSpinEdit.Value, AirfieldElevationSpinEdit.Value));
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.UpdateQnhQfeControls(AQnhHpa, AQfeHpa: double);
begin
  QnhPressureSpinEdit.Value := Round(AQnhHpa);
  QnhPressureInHgSpinEdit.Value := HpaToInHg(AQnhHpa);
  QnhPressureMmHgSpinEdit.Value := Round(HpaToMmHg(AQnhHpa));
  QfePressureSpinEdit.Value := Round(AQfeHpa);
  QfePressureInHgSpinEdit.Value := HpaToInHg(AQfeHpa);
  QfePressureMmHgSpinEdit.Value := Round(HpaToMmHg(AQfeHpa));
  QnhAltimeterGauge.Altitude := AirfieldElevationSpinEdit.Value;
  QnhAltimeterGauge.PressureInHg := HpaToInHg(AQnhHpa);
  QfeAltimeterGauge.Altitude := 0;
  QfeAltimeterGauge.PressureInHg := HpaToInHg(AQfeHpa);
end;

procedure TMainForm.UpdatePressureControls(APressureHpa: double);
begin
  PressureHpaSpinEdit.Value := Round(APressureHpa);
  PressureInSpinEdit.Value := HpaToInHg(APressureHpa);
  PressureMmSpinEdit.Value := Round(HpaToMmHg(APressureHpa));
  AltimeterGaugeCtrl.PressureInHg := HpaToInHg(APressureHpa);
end;

{ Reserved context-popup event handler for the QNH/QFE page; currently performs
  no action and leaves Handled unchanged. }
procedure TMainForm.QnhQfeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: boolean);
begin

end;

procedure TMainForm.AirspeedSpinEditChange(Sender: TObject);
var
  Knots: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;
  if Sender = AirspeedMphSpinEdit then
    Knots := MphToKnots(AirspeedMphSpinEdit.Value)
  else if Sender = AirspeedKmhSpinEdit then
    Knots := KmhToKnots(AirspeedKmhSpinEdit.Value)
  else
    Knots := AirspeedKnotsSpinEdit.Value;
  StopUiUpdate := True;
  try
    AirspeedGaugeCtrl.AirspeedKnots := Knots;
    Knots := AirspeedGaugeCtrl.AirspeedKnots;
    AirspeedKnotsSpinEdit.Value := Knots;
    AirspeedMphSpinEdit.Value := KnotsToMph(Knots);
    AirspeedKmhSpinEdit.Value := KnotsToKmh(Knots);
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.AltitudeSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
    Exit;

  StopUiUpdate := True;
  AltimeterGaugeCtrl.Altitude := AltitudeSpinEdit.Value;
  AltitudeMSpinEdit.Value := QnhQfeCalc.FeetToMeters(AltitudeSpinEdit.Value);
  StopUIUpdate := False;
end;

procedure TMainForm.AltitudeMSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
    Exit;

  StopUiUpdate := True;
  AltitudeSpinEdit.Value := QnhQfeCalc.MetersToFeet(AltitudeMSpinEdit.Value);
  AltimeterGaugeCtrl.Altitude := AltitudeSpinEdit.Value;
  StopUIUpdate := False;
end;

procedure TMainForm.MainPageCtrlChange(Sender: TObject);
begin

end;

procedure TMainForm.PressureHpaSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  StopUiUpdate := True;
  try
    UpdatePressureControls(PressureHpaSpinEdit.Value);
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.PressureInSpinEditChange(Sender: TObject);
var
  PressureHpa: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  PressureHpa := InHgToHpa(PressureInSpinEdit.Value);
  StopUiUpdate := True;
  try
    UpdatePressureControls(PressureHpa);
  finally
    StopUiUpdate := False;
  end;
end;

procedure TMainForm.PressureMmSpinEditChange(Sender: TObject);
var
  PressureHpa: double;
begin
  if StopUiUpdate or (csLoading in ComponentState) then
    Exit;

  PressureHpa := MmHgToHpa(PressureMmSpinEdit.Value);
  StopUiUpdate := True;
  try
    UpdatePressureControls(PressureHpa);
  finally
    StopUiUpdate := False;
  end;
end;

initialization
  RegisterClass(TSpinEdit);

end.
