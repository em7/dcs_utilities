unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Spin,
  StdCtrls, AltimeterGauge, QnhQfeCalc, AirspeedGauge, AirspeedCalc, Types;

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
    procedure QnhQfeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);

  private
    // Stops updating UI to distinguish between update made by user
    // and auto-updates from the code.
    StopUiUpdate: boolean;
    procedure UpdateQnhQfeControls(AQnhHpa, AQfeHpa: double);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

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

procedure TMainForm.QnhQfeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StopUiUpdate := False;
  QnhPressureSpinEditChange(QnhPressureSpinEdit);
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
  if StopUiUpdate then
    Exit;

  StopUiUpdate := True;
  PressureMmSpinEdit.Value := QnhQfeCalc.HpaToMmHg(PressureHpaSpinEdit.Value);
  PressureInSpinEdit.Value := QnhQfeCalc.HpaToInHg(PressureHpaSpinEdit.Value);
  AltimeterGaugeCtrl.PressureInHg := PressureInSpinEdit.Value;
  StopUIUpdate := False;
end;

procedure TMainForm.PressureInSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
    Exit;

  StopUiUpdate := True;
  PressureHpaSpinEdit.Value := QnhQfeCalc.InHgToHpa(PressureInSpinEdit.Value);
  PressureMmSpinEdit.Value := QnhQfeCalc.HpaToMmHg(PressureHpaSpinEdit.Value);
  AltimeterGaugeCtrl.PressureInHg := PressureInSpinEdit.Value;
  StopUIUpdate := False;
end;

procedure TMainForm.PressureMmSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
    Exit;

  StopUiUpdate := True;
  PressureHpaSpinEdit.Value := QnhQfeCalc.MmHgToHpa(PressureMmSpinEdit.Value);
  PressureInSpinEdit.Value := QnhQfeCalc.HpaToInHg(PressureHpaSpinEdit.Value);
  AltimeterGaugeCtrl.PressureInHg := PressureInSpinEdit.Value;
  StopUIUpdate := False;
end;

initialization
  RegisterClass(TSpinEdit);

end.
