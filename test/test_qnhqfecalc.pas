unit test_qnhqfecalc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, QnhQfeCalc;

type

  TQnhQfeCalc= class(TTestCase)
  published
    procedure SeaLevelQnhEqualsQfe;
    procedure SeaLevelQfeEqualsQnh;
    procedure QnhToQfeAndBackRoundTrips;
    procedure NegativeElevationIncreasesQfe;
    procedure QfeToQnhMatchesExpectedAtPositiveElevation;
    procedure QfeToQnhMatchesExpectedAtNegativeElevation;
    procedure PressureUnitConversions;
    procedure InHgToHpaRoundTrips;
    procedure MmHgToHpaRoundTrips;
    procedure FeetToMetersConversion;
    procedure MetersToFeetConversion;
  end;

implementation

procedure TQnhQfeCalc.SeaLevelQnhEqualsQfe;
begin
  AssertEquals(1013.25, QnhToQfe(1013.25, 0), 0.01);
end;

procedure TQnhQfeCalc.SeaLevelQfeEqualsQnh;
begin
  AssertEquals(1013.25, QfeToQnh(1013.25, 0), 0.01);
end;

procedure TQnhQfeCalc.QnhToQfeAndBackRoundTrips;
const
  ExpectedQfeHpa = 977.17;
  ExpectedQfeMagnitude = 36.08;
var
  ElevationFeet: Double;
  QnhHpa: Double;
  QfeHpa: Double;
begin
  QnhHpa := 1013.25;
  ElevationFeet := 1000;

  QfeHpa := QnhToQfe(QnhHpa, ElevationFeet);
  AssertEquals(ExpectedQfeHpa, QfeHpa, 0.01);
  AssertEquals(ExpectedQfeMagnitude, Abs(QnhHpa - QfeHpa), 0.01);
  AssertEquals(QnhHpa, QfeToQnh(QfeHpa, ElevationFeet), 0.01);
end;

procedure TQnhQfeCalc.NegativeElevationIncreasesQfe;
const
  ExpectedQfeHpa = 1031.69;
  ExpectedQfeMagnitude = 18.44;
var
  ElevationFeet: Double;
  QnhHpa: Double;
  QfeHpa: Double;
begin
  QnhHpa := 1013.25;
  ElevationFeet := -500;

  QfeHpa := QnhToQfe(QnhHpa, ElevationFeet);
  AssertTrue('QFE should be greater than QNH below sea level', QfeHpa > QnhHpa);
  AssertEquals(ExpectedQfeHpa, QfeHpa, 0.01);
  AssertEquals(ExpectedQfeMagnitude, Abs(QnhHpa - QfeHpa), 0.01);
  AssertEquals(QnhHpa, QfeToQnh(QfeHpa, ElevationFeet), 0.01);
end;

procedure TQnhQfeCalc.QfeToQnhMatchesExpectedAtPositiveElevation;
var
  ElevationFeet: Double;
  InputQfeHpa: Double;
  ExpectedQnhHpa: Double;
begin
  InputQfeHpa := 977.17;
  ElevationFeet := 1000;
  ExpectedQnhHpa := 1013.25;

  AssertEquals(ExpectedQnhHpa, QfeToQnh(InputQfeHpa, ElevationFeet), 0.01);
end;

procedure TQnhQfeCalc.QfeToQnhMatchesExpectedAtNegativeElevation;
var
  ElevationFeet: Double;
  InputQfeHpa: Double;
  ExpectedQnhHpa: Double;
begin
  InputQfeHpa := 1031.69;
  ElevationFeet := -500;
  ExpectedQnhHpa := 1013.25;

  AssertEquals(ExpectedQnhHpa, QfeToQnh(InputQfeHpa, ElevationFeet), 0.01);
end;

procedure TQnhQfeCalc.PressureUnitConversions;
begin
  AssertEquals(29.92, HpaToInHg(1013.25), 0.01);
  AssertEquals(760.0, HpaToMmHg(1013.25), 0.1);
end;

procedure TQnhQfeCalc.InHgToHpaRoundTrips;
begin
  AssertEquals(1013.25, InHgToHpa(29.92), 0.5);
  AssertEquals(1013.25, InHgToHpa(HpaToInHg(1013.25)), 0.01);
end;

procedure TQnhQfeCalc.MmHgToHpaRoundTrips;
begin
  AssertEquals(1013.25, MmHgToHpa(760.0), 0.5);
  AssertEquals(1013.25, MmHgToHpa(HpaToMmHg(1013.25)), 0.01);
end;

procedure TQnhQfeCalc.FeetToMetersConversion;
begin
  AssertEquals(304.8, FeetToMeters(1000), 0.01);
  AssertEquals(0.0, FeetToMeters(0), 0.0001);
end;

procedure TQnhQfeCalc.MetersToFeetConversion;
begin
  AssertEquals(1000, MetersToFeet(304.8), 0.01);
  AssertEquals(0.0, MetersToFeet(0), 0.0001);
end;

initialization

  RegisterTest(TQnhQfeCalc);
end.

