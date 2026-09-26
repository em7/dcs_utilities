unit AirspeedCalc;

{$mode ObjFPC}{$H+}

interface

function KnotsToMph(AKnots: Double): Double;
function MphToKnots(AMph: Double): Double;
function KnotsToKmh(AKnots: Double): Double;
function KmhToKnots(AKmh: Double): Double;
function ClampAirspeedKnots(AKnots: Double): Double;
function KnotsDialFraction(AKnots: Double): Double;
function KmhDialFraction(AKmh: Double): Double;

implementation

uses
  Math;

const
  KilometersPerNauticalMile = 1.852;
  KilometersPerMile = 1.609344;

function KnotsToMph(AKnots: Double): Double;
begin
  Result := AKnots * KilometersPerNauticalMile / KilometersPerMile;
end;

function MphToKnots(AMph: Double): Double;
begin
  Result := AMph * KilometersPerMile / KilometersPerNauticalMile;
end;

function KnotsToKmh(AKnots: Double): Double;
begin
  Result := AKnots * KilometersPerNauticalMile;
end;

function KmhToKnots(AKmh: Double): Double;
begin
  Result := AKmh / KilometersPerNauticalMile;
end;

function ClampSpeed(ASpeed, AMaximum: Double): Double;
begin
  // Check NaN before comparing: floating-point comparisons with NaN can trap.
  if IsNan(ASpeed) then
    Exit(0);
  if ASpeed < 0 then
    Exit(0);
  if ASpeed > AMaximum then
    Exit(AMaximum);
  Result := ASpeed;
end;

function ClampAirspeedKnots(AKnots: Double): Double;
begin
  Result := ClampSpeed(AKnots, 900);
end;

function KnotsDialFraction(AKnots: Double): Double;
begin
  Result := ClampAirspeedKnots(AKnots) / 900;
end;

function KmhDialFraction(AKmh: Double): Double;
begin
  Result := ClampSpeed(AKmh, 1670) / 1670;
end;

end.
