unit test_airspeedcalc;

{$mode objfpc}{$H+}

interface

uses
  Math, fpcunit, testregistry, AirspeedCalc;

type
  TAirspeedCalc = class(TTestCase)
  published
    procedure ConvertsKnownSpeeds;
    procedure ConversionsRoundTrip;
    procedure BoundsCanonicalSpeed;
    procedure MapsDialFractions;
    procedure HandlesNonFiniteSpeeds;
  end;

implementation

procedure TAirspeedCalc.ConvertsKnownSpeeds;
begin
  AssertEquals(517.850751610594, KnotsToMph(450), 0.000000001);
  AssertEquals(833.4, KnotsToKmh(450), 0.000000001);
  AssertEquals(1666.8, KnotsToKmh(900), 0.000000001);
  AssertEquals(0.0, KnotsToMph(0), 0.000000001);
  AssertEquals(0.0, KnotsToKmh(0), 0.000000001);
end;

procedure TAirspeedCalc.ConversionsRoundTrip;
var
  Speed: Integer;
begin
  for Speed := 0 to 900 do
  begin
    AssertEquals(Speed, MphToKnots(KnotsToMph(Speed)), 0.000000001);
    AssertEquals(Speed, KmhToKnots(KnotsToKmh(Speed)), 0.000000001);
  end;
end;

procedure TAirspeedCalc.BoundsCanonicalSpeed;
begin
  AssertEquals(0.0, ClampAirspeedKnots(-1), 0.000000001);
  AssertEquals(0.0, ClampAirspeedKnots(0), 0.000000001);
  AssertEquals(450.25, ClampAirspeedKnots(450.25), 0.000000001);
  AssertEquals(900.0, ClampAirspeedKnots(900), 0.000000001);
  AssertEquals(900.0, ClampAirspeedKnots(901), 0.000000001);
end;

procedure TAirspeedCalc.MapsDialFractions;
begin
  AssertEquals(0.0, KnotsDialFraction(-100), 0.000000001);
  AssertEquals(0.5, KnotsDialFraction(450), 0.000000001);
  AssertEquals(1.0, KnotsDialFraction(900), 0.000000001);
  AssertEquals(1.0, KnotsDialFraction(1000), 0.000000001);
  AssertEquals(0.0, KmhDialFraction(-100), 0.000000001);
  AssertEquals(0.5, KmhDialFraction(835), 0.000000001);
  AssertEquals(1.0, KmhDialFraction(1670), 0.000000001);
  AssertEquals(1.0, KmhDialFraction(1700), 0.000000001);
  AssertTrue('900 knots remains below the 1670 km/h endpoint',
    KmhDialFraction(KnotsToKmh(900)) < 1);
  AssertEquals(KnotsDialFraction(450),
    KnotsDialFraction(MphToKnots(KnotsToMph(450))), 0.000000001);
end;

procedure TAirspeedCalc.HandlesNonFiniteSpeeds;
begin
  AssertEquals(0.0, ClampAirspeedKnots(NaN), 0.000000001);
  AssertEquals(0.0, ClampAirspeedKnots(NegInfinity), 0.000000001);
  AssertEquals(900.0, ClampAirspeedKnots(Infinity), 0.000000001);
  AssertEquals(0.0, KnotsDialFraction(NaN), 0.000000001);
  AssertEquals(0.0, KnotsDialFraction(NegInfinity), 0.000000001);
  AssertEquals(1.0, KnotsDialFraction(Infinity), 0.000000001);
  AssertEquals(0.0, KmhDialFraction(NaN), 0.000000001);
  AssertEquals(0.0, KmhDialFraction(NegInfinity), 0.000000001);
  AssertEquals(1.0, KmhDialFraction(Infinity), 0.000000001);
end;

initialization
  RegisterTest(TAirspeedCalc);
end.
