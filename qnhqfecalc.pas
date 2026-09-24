unit QnhQfeCalc;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math;

function QnhToQfe(AQnhHpa, AElevationFeet: Double): Double;
function QfeToQnh(AQfeHpa, AElevationFeet: Double): Double;
function HpaToInHg(APressureHpa: Double): Double;
function HpaToMmHg(APressureHpa: Double): Double;

implementation

const
  MetersPerFoot = 0.3048;
  InHgPerHpa = 0.0295299830714;
  MmHgPerHpa = 0.750061683;
  IsaSeaLevelTempKelvin = 288.15;
  IsaTempLapseRate = 0.0065;
  IsaPressureExponent = 5.2558797;

function ElevationPressureFactor(AElevationFeet: Double): Double;
var
  ElevationMeters: Double;
begin
  ElevationMeters := AElevationFeet * MetersPerFoot;
  Result := Power(1 - (IsaTempLapseRate * ElevationMeters / IsaSeaLevelTempKelvin), IsaPressureExponent);
end;

function QnhToQfe(AQnhHpa, AElevationFeet: Double): Double;
begin
  Result := AQnhHpa * ElevationPressureFactor(AElevationFeet);
end;

function QfeToQnh(AQfeHpa, AElevationFeet: Double): Double;
begin
  Result := AQfeHpa / ElevationPressureFactor(AElevationFeet);
end;

function HpaToInHg(APressureHpa: Double): Double;
begin
  Result := APressureHpa * InHgPerHpa;
end;

function HpaToMmHg(APressureHpa: Double): Double;
begin
  Result := APressureHpa * MmHgPerHpa;
end;

end.

